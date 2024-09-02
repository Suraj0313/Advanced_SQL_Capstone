1. Represent the “book_date” column in “yyyy-mmm-dd” format using Bookings table 
Expected output: book_ref, book_date (in “yyyy-mmm-dd” format) , total amount 
Answer: 
    
SELECT 
book_ref, 
TO_CHAR(book_date, 'yyyy-mmm-dd') AS book_date,
total_amount
FROM bookings;


2. Get the following columns in the exact same sequence.
Expected columns in the output: ticket_no, boarding_no, seat_number, passenger_id, passenger_name.
Answer:
    
SELECT
t.ticket_no,
b.boarding_no,
b.seat_no AS seat_number,
t.passenger_id,
t.passenger_name
FROM tickets t
INNER JOIN  boarding_passes b
ON b.ticket_no = t.ticket_no;


3. Write a query to find the seat number which is least allocated among all the seats?
Answer: 
    
SELECT
s.seat_no,
COUNT(*) AS allocated_seat_count
FROM seats s 
LEFT JOIN boarding_passes b
ON s.seat_no = b.seat_no
GROUP BY 1
ORDER BY 2 ASC
LIMIT 3;


4. In the database, identify the month wise highest paying passenger name and passenger id.
Expected output: Month_name(“mmm-yy” format), passenger_id, passenger_name and total amount
Answer:
    
 WITH cte AS (SELECT
     TO_CHAR(book_date, 'mmm-yy') AS month_name,
     passenger_id,
     passenger_name,
     SUM(total_amount) AS total_amount
     FROM tickets t
     LEFT JOIN bookings b
     ON b.book_ref = t.book_ref
     GROUP BY 1,2,3),
 table2 AS (SELECT *,
     DENSE_RANK() OVER(PARTITION BY month_name ORDER BY total_amount DESC) AS rnk
     FROM cte)
 SELECT 
    month_name,
    passenger_id, 
    passenger_name,
    total_amount 
 FROM table2
 WHERE rnk = 1;


5. In the database, identify the month wise least paying passenger name and passenger id?
Expected output: Month_name(“mmm-yy” format), passenger_id, passenger_name and total amount
Answer:
    
 WITH cte AS (SELECT
    TO_CHAR(book_date, 'mmm-yy') AS month_name,
    passenger_id,
    passenger_name,
    SUM(total_amount) AS total_amount
    FROM tickets t
    LEFT JOIN bookings b
    ON b.book_ref = t.book_ref
    GROUP BY 1,2,3),
 table2 AS(SELECT *,
    DENSE_RANK() OVER(PARTITION BY month_name ORDER BY total_amount ASC) AS rnk
    FROM cte)
 SELECT
 month_name,
 passenger_id, 
 passenger_name,
 total_amount 
 FROM table2
 WHERE rnk = 1;


6. Identify the travel details of non stop journeys  or return journeys (having more than 1 flight).
Expected Output: Passenger_id, passenger_name, ticket_number and flight count.
Answer:
    
SELECT
passenger_id,
passenger_name, 
t.ticket_no AS ticket_number,
COUNT(flight_id) AS flight_count
FROM tickets t
INNER JOIN boarding_passes b
ON t.ticket_no = b.ticket_no
GROUP BY 1,2,3
HAVING COUNT(flight_id) > 1;


7. How many tickets are there without boarding passes?
Expected Output: just one number is required.
Answer:
    
SELECT 
COUNT(t.ticket_no)
FROM tickets t
LEFT JOIN boarding_passes b
ON t.ticket_no = b.ticket_no
WHERE boarding_no IS NULL;


8. Identify details of the longest flight (using flights table)?
Expected Output: Flight number, departure airport, arrival airport, aircraft code and durations.
Answer:
    
WITH cte AS (SELECT 
    flight_no, 
    departure_airport,
    arrival_airport,
    aircraft_code,
    scheduled_arrival - scheduled_departure AS durations
    FROM flights
    ORDER BY durations DESC),
table2 AS (SELECT *,
    DENSE_RANK() OVER(ORDER BY durations DESC) AS rnk
    FROM cte)
SELECT 
flight_no AS flight_number,
departure_airport,
arrival_airport, 
aircraft_code, durations
FROM table2
WHERE rnk = 1;


9. Identify details of all the morning flights (morning means between 6AM to 11 AM, using flights table)?
Expected output: flight_id, flight_number, scheduled_departure, scheduled_arrival and timings.
Answer:
    
SELECT 
flight_id, 
flight_no, 
scheduled_departure, 
scheduled_arrival,
CASE WHEN CAST(scheduled_departure AS time) BETWEEN '06:00:00' and '11:00:00' 
THEN 'morning flight' ELSE null END AS timings 
FROM flights
WHERE to_char(scheduled_departure, 'HH24:MI') BETWEEN '06:00:00' AND  '11:00:00';


10. Identify the earliest morning flight available from every airport.
Expected output: flight_id, flight_number, scheduled_departure, scheduled_arrival, departure airport and timings.
Answer:
    
WITH table1 AS (SELECT *,
    to_char(scheduled_departure, 'hh:mm:ss') as timings
    FROM flights
    WHERE EXTRACT(HOUR FROM scheduled_departure) BETWEEN 2 AND 5),
table2 as (SELECT *,
    row_number() OVER (PARTITION BY departure_airport ORDER BY timings) AS row_num
    FROM table1)
SELECT
flight_id,
flight_no as flight_number,
scheduled_departure,
scheduled_arrival,
departure_airport,
timings
FROM table2
WHERE row_num = 1;


11. Questions: Find list of airport codes in Europe/Moscow timezone
 Expected Output:  Airport_code. 
Answer:
    
SELECT 
airport_code
FROM airports
WHERE timezone = 'Europe/Moscow';


12. Write a query to get the count of seats in various fare condition for every aircraft code?
 Expected Outputs: Aircraft_code, fare_conditions ,seat count
Answer:
    
SELECT 
aircraft_code, fare_conditions,
COUNT(seat_no) AS seat_count
FROM seats
GROUP BY 1,2;


13. How many aircrafts codes have at least one Business class seats?
 Expected Output : Count of aircraft codes
Answer:
    
SELECT 
COUNT(DISTINCT aircraft_code) AS count_of_aircraft_codes
FROM seats
WHERE fare_conditions = 'Business';


14. Find out the name of the airport having maximum number of departure flight
 Expected Output : Airport_name 
Answer:
    
WITH cte AS(SELECT
    airport_name,
    COUNT(departure_airport)
    FROM airports a
    LEFT JOIN flights f
    ON a.airport_code = f.departure_airport
    GROUP BY 1
    ORDER BY 2 DESC)
SELECT
airport_name
FROM cte
LIMIT 1;


15.	Find out the name of the airport having least number of scheduled departure flights
 Expected Output : Airport_name 
Answer:
    
WITH cte AS(SELECT
    airport_name,
    COUNT(departure_airport)
    FROM airports a
    LEFT JOIN flights f
    ON a.airport_code = f.departure_airport
    GROUP BY 1
    ORDER BY 2 ASC)
SELECT 
airport_name
FROM cte
LIMIT 1;


16.	How many flights from ‘DME’ airport don’t have actual departure?
 Expected Output : Flight Count 
Answer:
    
SELECT
COUNT(flight_id) AS flight_count
FROM flights
WHERE departure_airport = 'DME'
AND actual_departure IS NULL;


17.	Identify flight ids having range between 3000 to 6000
 Expected Output : Flight_Number , aircraft_code, ranges 
Answer:
    
SELECT
DISTINCT flight_no AS flight_number,
a.aircraft_code, range
FROM flights f
INNER JOIN aircrafts a
ON f.aircraft_code = a.aircraft_code
WHERE range BETWEEN 3000 AND 6000;


18.	Write a query to get the count of flights flying between URS and KUF?
 Expected Output : Flight_count
Answer:
    
SELECT
COUNT(flight_id) AS flight_count
FROM flights
WHERE departure_airport IN ('URS','KUF') AND
arrival_airport IN ('URS','KUF'); 


19.	Write a query to get the count of flights flying from either from NOZ or KRR?
 Expected Output : Flight count 
Answer:
    
SELECT
COUNT(flight_id) AS flight_count
FROM flights
WHERE departure_airport IN ('NOZ','KRR');


20.	Write a query to get the count of flights flying from KZN,DME,NBC,NJC,GDX,SGC,VKO,ROV
Expected Output : Departure airport ,count of flights flying from these   airports.
Answer:
    
SELECT departure_airport,
COUNT(flight_id) AS flight_count
FROM flights
WHERE departure_airport IN ('KZN','DME','NBC','NJC','GDX','SGC','VKO','ROV') 
GROUP BY 1;


21.	Write a query to extract flight details having range between 3000 and 6000 and flying from DME
Expected Output :Flight_no,aircraft_code,range,departure_airport
Answer:
    
SELECT
DISTINCT flight_no, f.aircraft_code, range,
departure_airport
FROM flights f
INNER JOIN aircrafts a
ON f.aircraft_code = a.aircraft_code
WHERE range BETWEEN 3000 AND 6000
AND departure_airport = 'DME';


22.	Find the list of flight ids which are using aircrafts from “Airbus” company and got cancelled or delayed.
Expected Output : Flight_id,aircraft_model
Answer:
    
SELECT 
flight_id, 
model AS aircraft_model
FROM flights f
INNER JOIN aircrafts a
ON f.aircraft_code = a.aircraft_code
WHERE model LIKE '%Airbus%' AND 
status IN ('Cancelled','Delayed');


23.	Find the list of flight ids which are using aircrafts from “Boeing” company and got cancelled or delayed
Expected Output : Flight_id,aircraft_model
Answer: 
    
SELECT 
flight_id, 
model AS aircraft_model
FROM flights f
INNER JOIN aircrafts a
ON f.aircraft_code = a.aircraft_code
WHERE model LIKE '%Boeing%' AND 
status IN ('Cancelled','Delayed');


24.	Which airport(name) has most cancelled flights (arriving)?
Expected Output : Airport_name 
Answer: 
    
WITH cte AS (SELECT 
    airport_name, 
    COUNT(arrival_airport)
    FROM flights f
    LEFT JOIN airports a
    ON a.airport_code = f.departure_airport
    WHERE status = 'Cancelled'
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 1)
SELECT airport_name
FROM cte;


25.	Identify flight ids which are using “Airbus aircrafts”
Expected Output : Flight_id,aircraft_model
Answer:
    
SELECT
flight_id, 
model AS aircraft_model
FROM  flights f
INNER JOIN aircrafts a
ON a.aircraft_code = f.aircraft_code
WHERE model LIKE '%Airbus%';


26.	Identify date-wise last flight id flying from every airport?
Expected Output: Flight_id,flight_number,schedule_departure,departure_airport
Answer:

WITH table1 AS (SELECT
    flight_id,
    flight_no,
    scheduled_departure,
    departure_airport,
    DATE(scheduled_departure) AS departure_date,
    ROW_NUMBER() OVER (PARTITION BY departure_airport, DATE(scheduled_departure) 
    ORDER BY scheduled_departure DESC) AS row_num
    FROM flights)
SELECT
flight_id,
flight_no as flight_number,
scheduled_departure,
departure_airport
FROM table1
WHERE row_num = 1;


27.	Identify list of customers who will get the refund due to cancellation of the flights and how much amount they will get?
Expected Output : Passenger_name,total_refund.
Answer:
    
SELECT
t.passenger_name,
SUM(tf.amount) AS total_refund
FROM tickets t
LEFT JOIN ticket_flights tf
ON t.ticket_no = tf.ticket_no
LEFT JOIN flights f
ON tf.flight_id = f.flight_id
WHERE f.status = 'Cancelled'
GROUP BY 1;


28.	Identify date wise first cancelled flight id flying for every airport?
Expected Output : Flight_id,flight_number,schedule_departure,departure_airport
Answer:
    
WITH table1 AS (SELECT
    flight_id,
    flight_no,
    scheduled_departure,
    departure_airport,
    DATE(scheduled_departure) AS departure_date,
    DENSE_RANK() OVER (PARTITION BY departure_airport, DATE(scheduled_departure) 
    ORDER BY scheduled_departure DESC) AS rnk
    FROM flights
    WHERE status = 'Cancelled')
SELECT
flight_id,
flight_no as flight_number,
scheduled_departure,
departure_airport
FROM table1
WHERE rnk = 1;


29.	Identify list of Airbus flight ids which got cancelled.
Expected Output : Flight_id
Answer:
    
SELECT
flight_id
FROM flights f
LEFT JOIN aircrafts a
ON f.aircraft_code = a.aircraft_code
WHERE status = 'Cancelled' AND
model LIKE '%Airbus%';


30.	Identify list of flight ids having highest range.
 Expected Output : Flight_no, range
Answer: 
    
WITH table1 AS (SELECT
    flight_id,
    range,
    DENSE_RANK() OVER(ORDER BY range DESC) AS rnk
    FROM flights f
    LEFT JOIN aircrafts a
    ON f.aircraft_code = a.aircraft_code)
SELECT
flight_id,
range
FROM table1
WHERE rnk = 1;

