USE SnapFoodDB;

DECLARE @Pay_Customers_LowerThan_AvgOfArea TABLE (AreaID INT, CustomerID INT, VendorID INT, ServiceID INT, AvgArea INT, AvgCustormer INT)

INSERT INTO @Pay_Customers_LowerThan_AvgOfArea
	SELECT * FROM (
					SELECT AreaID,
							CustomerID,
							VendorID,
							ServiceID,
							AVG(PayedByCustomer) OVER (PARTITION BY AreaID) AvgArea,
							AVG(PayedByCustomer) OVER (PARTITION BY CustomerID) AvgCustormer
					FROM CampaignDataSet
					WHERE AreaID IS NOT NULL
					) Customer_Pay_AvgOfArea
	WHERE Customer_Pay_AvgOfArea.AvgCustormer < Customer_Pay_AvgOfArea.AvgArea

DECLARE @Vendor_Candidate TABLE (VendorID INT)

INSERT INTO @Vendor_Candidate
SELECT DISTINCT VendorID FROM CampaignDataSet
		WHERE AreaID is not NULL 
				AND DeliveredAt is not NULL 
				AND AtRestaurant is not NULL
EXCEPT
SELECT VendorID FROM (
	SELECT DISTINCT VendorID , AVG(DATEDIFF(MINUTE, AtRestaurant, DeliveredAt)) as AvgDeliveryTime
	FROM CampaignDataSet
		WHERE AreaID is not NULL 
				AND DeliveredAt is not NULL 
				AND AtRestaurant is not NULL
				AND DATEPART(HOUR, AtRestaurant) BETWEEN 8 AND 9
				AND DATEPART(MINUTE, AtRestaurant) < 1
	GROUP BY VendorID
)as AvgVendorDeliveryTimeNearEftar
	WHERE AvgVendorDeliveryTimeNearEftar.AvgDeliveryTime >= 10
EXCEPT
SELECT VendorID FROM (
	SELECT DISTINCT VendorID, 
			AVG(DATEDIFF(MINUTE, AtRestaurant, DeliveredAt)) OVER (PARTITION BY VendorID) AvgVendorDeliveryTime,
			AVG(DATEDIFF(MINUTE, AtRestaurant, DeliveredAt)) OVER (PARTITION BY AreaID) AvgAreaDeliveryTime
	FROM CampaignDataSet
		WHERE AreaID is not NULL 
			AND DeliveredAt is not NULL 
			AND AtRestaurant is not NULL
)as AvgVendorDeliveryTimeInArea
	WHERE AvgVendorDeliveryTime > AvgAreaDeliveryTime


SELECT	DISTINCT 
		Pay_Customers_LowerThan_AvgOfArea.AreaID,
		Pay_Customers_LowerThan_AvgOfArea.CustomerID,
		Pay_Customers_LowerThan_AvgOfArea.VendorID,
		Pay_Customers_LowerThan_AvgOfArea.ServiceID
FROM
(
		--@Pay_Customers_LowerThan_AvgOfArea
		SELECT * FROM (
					SELECT AreaID,
							CustomerID,
							VendorID,
							ServiceID,
							AVG(PayedByCustomer) OVER (PARTITION BY AreaID) AvgArea,
							AVG(PayedByCustomer) OVER (PARTITION BY CustomerID) AvgCustormer
					FROM CampaignDataSet
					WHERE AreaID IS NOT NULL
					) Customer_Pay_AvgOfArea
		WHERE Customer_Pay_AvgOfArea.AvgCustormer < Customer_Pay_AvgOfArea.AvgArea
) Pay_Customers_LowerThan_AvgOfArea
INNER JOIN 
(
--@Ranking_Customer_Service_Usage
	SELECT CustomerID, ServiceID FROM
	(
		SELECT CustomerID,
				ServiceID,
				COUNT(ServiceID) as cnt,
				RANK() OVER (PARTITION BY CustomerID ORDER BY COUNT(ServiceID) DESC) as rank_numi
				FROM CampaignDataSet
				WHERE CustomerID IN (SELECT CustomerID FROM @Pay_Customers_LowerThan_AvgOfArea)
				GROUP BY CustomerID, ServiceID

	) as Custome_Service_Usage
	WHERE rank_numi = 1 AND cnt >= 2

)Ranking_Customer_Service_Usage
 ON Pay_Customers_LowerThan_AvgOfArea.CustomerID = Ranking_Customer_Service_Usage.CustomerID
WHERE Pay_Customers_LowerThan_AvgOfArea.VendorID 
			IN (
					--@Sell_Vendors_LowerThan_AvgOfArea
					(SELECT DISTINCT VendorID 
					FROM (
							SELECT AreaID,
							VendorID,
							AVG(PayedByCustomer) OVER (PARTITION BY AreaID) AvgArea,
							AVG(PayedByCustomer) OVER (PARTITION BY VendorID) AvgVendor
							FROM CampaignDataSet
							WHERE AreaID IS NOT NULL
						) Customer_Pay_AvgOfArea
					WHERE Customer_Pay_AvgOfArea.AvgVendor < Customer_Pay_AvgOfArea.AvgArea)
				UNION
					(SELECT VendorID FROM @Vendor_Candidate)
				)
