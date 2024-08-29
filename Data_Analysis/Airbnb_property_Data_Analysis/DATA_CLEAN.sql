--change type value
ALTER TABLE Airbnb_Data
ALTER COLUMN host_has_profile_pic VARCHAR(5);

ALTER TABLE Airbnb_Data
ALTER COLUMN host_identity_verified VARCHAR(5);

ALTER TABLE Airbnb_Data
ALTER COLUMN instant_bookable VARCHAR(5);

--replace value in host_has_profile_pic
UPDATE Airbnb_Data
SET host_has_profile_pic = 
    CASE 
        WHEN host_has_profile_pic = 't' THEN 'TRUE'
        WHEN host_has_profile_pic = 'f' THEN 'FALSE'
        ELSE host_has_profile_pic
    END;

--replace value in host_identity_verified
UPDATE Airbnb_Data
SET host_identity_verified = 
    CASE 
        WHEN host_has_profile_pic = 't' THEN 'TRUE'
        WHEN host_has_profile_pic = 'f' THEN 'FALSE'
        ELSE host_has_profile_pic
    END;

--replace value in instant_bookable
UPDATE Airbnb_Data
SET instant_bookable = 
    CASE 
        WHEN host_has_profile_pic = 't' THEN 'TRUE'
        WHEN host_has_profile_pic = 'f' THEN 'FALSE'
        ELSE host_has_profile_pic
    END;

-- delete null id
DELETE FROM Airbnb_Data
WHERE id IS NULL

--CREATE NEW COLUMN
ALTER TABLE Airbnb_Data
ADD order_roomtype INT NULL,
	order_bedtype INT NULL,
	order_cancellation_policy INT NULL

--SET VALUE TO THE NEW COLUMNS
UPDATE Airbnb_Data
SET order_roomtype = 
	CASE 
		WHEN room_type = 'Entire home/apt' THEN 1
		WHEN room_type = 'Private room' THEN 2
		WHEN room_type = 'Shared room' THEN 3
		ELSE 0
		END;

UPDATE Airbnb_Data
SET order_bedtype = 
	CASE
		WHEN bed_type =	'Real Bed' THEN 1
		WHEN bed_type =	'Futon' THEN 2
		WHEN bed_type =	'Pull-out Sofa' THEN 3
		WHEN bed_type =	'Couch' THEN 4
		WHEN bed_type =	'Airbed' THEN 5
		ELSE 0
		END;

UPDATE Airbnb_Data
SET order_cancellation_policy = 
	CASE
		WHEN cancellation_policy =	'flexible' THEN 1
		WHEN cancellation_policy =	'moderate' THEN 2
		WHEN cancellation_policy =	'strict' THEN 3
		WHEN cancellation_policy =	'super_strict_30' THEN 4
		WHEN cancellation_policy =	'super_strict_60' THEN 5
		ELSE 0
		END;

--CREATE NEW TABLE
CREATE TABLE Amenities (
    id INT,
    amenity VARCHAR(255)
);
--insert new value
INSERT INTO Amenities (id, amenity)
SELECT id,
	   TRIM(value) as amenity
FROM Airbnb_Data
CROSS APPLY STRING_SPLIT(amenities, ',');

--TEST
SELECT TOP 20 * FROM Amenities

--REPLACE 
UPDATE Amenities
SET amenity = REPLACE(REPLACE(amenity, '{', ''), '"', '');

UPDATE Amenities
SET amenity = REPLACE(amenity, '}', '')

--CREATE REF
ALTER TABLE Amenities
ADD CONSTRAINT FK_Amenities_Airbnb_Data FOREIGN KEY (id)
REFERENCES Airbnb_Data(id);

--update value of property_type
UPDATE Airbnb_Data
SET property_type = CASE 
    WHEN property_type IN ('Apartment', 'House', 'Condominium', 'Loft', 'Townhouse') THEN property_type
    ELSE 'Other'
END;

--TO CALCULETE THE COUNT AND PERSENTAGE OF EACH VALUE IN ONE COLUMN
SELECT 
    accommodates, 
    COUNT(*) AS Count,
    CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM Airbnb_Data) * 100 AS Percentage
FROM 
    Airbnb_Data
GROUP BY 
    accommodates
ORDER BY 
    Percentage;

SELECT 
    bedrooms, 
    COUNT(*) AS Count,
    CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM Airbnb_Data) * 100 AS Percentage
FROM 
    Airbnb_Data
GROUP BY 
    bedrooms
ORDER BY 
    Percentage;

--
SELECT 
    (CAST(COUNT(DISTINCT amenities) AS FLOAT) / COUNT(*)) * 100 AS Percentage
FROM 
    Airbnb_Data;

--set the count of accomodates, over 10 in a group
UPDATE Airbnb_Data
SET accommodates = 
	CASE 
    WHEN accommodates > 10  THEN 13
    ELSE accommodates
END;

--CALCULATE THE AVG OF THOSE ACCOMODATE > 10
SELECT AVG(accommodates)
FROM Airbnb_Data
WHERE accommodates > 10

--set the count of bedrooms, over 4 in a group
UPDATE Airbnb_Data
SET bedrooms = 
	CASE 
    WHEN bedrooms > 4  THEN 5
    ELSE bedrooms
END;

SELECT property_type, AVG(log_price)
FROM Airbnb_Data
group by property_type

-- Add a new column to store the average log price
ALTER TABLE Airbnb_Data
ADD avg_log_price_property_type FLOAT; 
--insert a now coloum avg_log_price_property_type
UPDATE Airbnb_Data
SET avg_log_price_property_type = avg.avg_log_price
FROM (
    SELECT property_type, AVG(log_price) AS avg_log_price
    FROM Airbnb_Data
    GROUP BY property_type
) AS avg
WHERE Airbnb_Data.property_type = avg.property_type;

--add new log_price_...
ALTER TABLE Airbnb_Data
ADD log_priceroom_type FLOAT,
	log_price_accommodates FLOAT,
	log_price_bathrooms FLOAT,
	log_price_beds FLOAT,
	log_price_roomtype FLOAT

-- INSERT DATA log_priceroom_type
UPDATE Airbnb_Data
SET log_priceroom_type = avg.avg_log_price
FROM (
    SELECT room_type, AVG(log_price) AS avg_log_price
    FROM Airbnb_Data
    GROUP BY room_type
) AS avg
WHERE Airbnb_Data.room_type = avg.room_type;
--2 log_price_accommodates
UPDATE Airbnb_Data
SET log_price_accommodates = avg.avg_log_price
FROM (
    SELECT accommodates, AVG(log_price) AS avg_log_price
    FROM Airbnb_Data
    GROUP BY accommodates
) AS avg
WHERE Airbnb_Data.accommodates = avg.accommodates;
--3 insert log_price_bathrooms
UPDATE Airbnb_Data
SET log_price_bathrooms = avg.avg_log_price
FROM (
    SELECT bathrooms, AVG(log_price) AS avg_log_price
    FROM Airbnb_Data
    GROUP BY bathrooms
) AS avg
WHERE Airbnb_Data.bathrooms = avg.bathrooms;
--4 log_price_beds
UPDATE Airbnb_Data
SET log_price_beds = avg.avg_log_price
FROM (
    SELECT beds, AVG(log_price) AS avg_log_price
    FROM Airbnb_Data
    GROUP BY beds
) AS avg
WHERE Airbnb_Data.beds = avg.beds;
--5 log_price_roomtype
UPDATE Airbnb_Data
SET log_price_roomtype = avg.avg_log_price
FROM (
    SELECT room_type, AVG(log_price) AS avg_log_price
    FROM Airbnb_Data
    GROUP BY room_type
) AS avg
WHERE Airbnb_Data.room_type = avg.room_type;

--insert log_bedrooms
ALTER TABLE Airbnb_Data
ADD log_price_bedrooms FLOAT

UPDATE Airbnb_Data
SET log_price_bedrooms = avg.avg_log_price
FROM (
    SELECT bedrooms, AVG(log_price) AS avg_log_price
    FROM Airbnb_Data
    GROUP BY bedrooms
) AS avg
WHERE Airbnb_Data.bedrooms = avg.bedrooms;

--INSERT NEW COLUMU TO CALCULATE DATE
ALTER TABLE Airbnb_Data
ADD days_BetweenReciews INT,
	host_period INT
	
UPDATE Airbnb_Data
SET days_BetweenReciews = DATEDIFF(DAY, first_review, '2017-12-31');

UPDATE Airbnb_Data
SET host_period  = DATEDIFF(DAY, host_since, '2017-12-31');

--
--CREATE NEW COLUMN
ALTER TABLE Airbnb_Data
ADD order_property_type INT NULL

select  distinct  property_type , count(*)
from Airbnb_Data
group by property_type


--SET VALUE TO THE NEW COLUMNS
UPDATE Airbnb_Data
SET order_property_type = 
	CASE 
		WHEN property_type = 'Apartment' THEN 1
		WHEN property_type = 'House' THEN 2
		WHEN property_type = 'Condominium' THEN 3
		WHEN property_type = 'Townhouse' THEN 4
		WHEN property_type = 'Loft' THEN 5
		WHEN property_type = 'Other' THEN 6
		ELSE 0
		END;

--ADD log_price_city
ALTER TABLE Airbnb_Data
ADD log_price_city FLOAT
UPDATE Airbnb_Data
SET log_price_city = avg.avg_log_price
FROM (
    SELECT city, AVG(log_price) AS avg_log_price
    FROM Airbnb_Data
    GROUP BY city
) AS avg
WHERE Airbnb_Data.city = avg.city;

--ADD reservation_evaluation
ALTER TABLE Airbnb_Data
ADD reservation_evaluation int
UPDATE Airbnb_Data
SET reservation_evaluation = CAST(number_of_reviews / 0.8 AS INT);

-- select top 16 -30
SELECT amenity,COUNT(*)
FROM Amenities
GROUP BY amenity
ORDER BY COUNT(*) DESC
OFFSET 9 ROWS 
FETCH NEXT 5 ROWS ONLY; 
