USE SnapFoodDB;

select * from ShootOut

select AVG(DATEDIFF(MINUTE ,FirstAssign, Accepted)), STDEV(DATEDIFF(MINUTE ,FirstAssign, Accepted)) from ShootOut
	where SourceArea = DestinationArea

select AVG(DATEDIFF(MINUTE ,FirstAssign, Accepted)), STDEV(DATEDIFF(MINUTE ,FirstAssign, Accepted)) from ShootOut
	where SourceArea <> DestinationArea

select AVG(DATEDIFF(MINUTE ,FirstAssign, DeliveredAt)), STDEV(DATEDIFF(MINUTE ,FirstAssign, DeliveredAt)) from ShootOut
	where SourceArea = DestinationArea

select AVG(DATEDIFF(MINUTE ,FirstAssign, DeliveredAt)), STDEV(DATEDIFF(MINUTE ,FirstAssign, DeliveredAt)) from ShootOut
	where SourceArea <> DestinationArea

select 
	AVG(DATEDIFF(MINUTE ,At_Restaurant, DeliveredAt)) as avgtime,
	AVG(BikerToRestaurantDistance) avgdistance
	from ShootOut
	where SourceArea = DestinationArea

select 
	AVG(DATEDIFF(MINUTE ,At_Restaurant, DeliveredAt)) as avgtime,
	AVG(BikerToRestaurantDistance) as avgdistance
	from ShootOut
	where SourceArea <> DestinationArea