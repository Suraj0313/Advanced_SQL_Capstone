1.	Represent the “book_date” column in “yyyy-mmm-dd” format using Bookings table 
Expected output: book_ref, book_date (in “yyyy-mmm-dd” format) , total amount 
**Answer:**  
SELECT 
book_ref, 
TO_CHAR(book_date, 'yyyy-mmm-dd') AS book_date,
total_amount
FROM bookings


2.	Get the following columns in the exact same sequence.
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
ON b.ticket_no = t.ticket_no


3.	Write a query to find the seat number which is least allocated among all the seats?

Answer: 
select 
s.seat_no,
count(bp.seat_no) as allocation_count
from seats s 
left join boarding_passes bp 
on s.seat_no=bp.seat_no
group by 1 
order by 2 asc 
limit 3;


4.	In the database, identify the month wise highest paying passenger name and passenger id.
Expected output: Month_name(“mmm-yy” format), passenger_id, passenger_name and total amount

Answer:
with monthly_payment as (
    select 
    to_char(b.book_date,'MMM-YY') as month_name,
    t.passenger_id,
    t.passenger_name,
    b.total_amount,
    dense_rank() over(partition by to_char(b.book_date,'MMM-YY') order by b.total_amount desc) as rank
    from bookings as b 
    join tickets as t 
    on b.book_ref=t.book_ref 
)
select 
month_name,
passenger_id,
passenger_name,
total_amount
from monthly_payment
where rank=1;


5.	In the database, identify the month wise least paying passenger name and passenger id?
Expected output: Month_name(“mmm-yy” format), passenger_id, passenger_name and total amount

Answer: 
with monthly_payment as (
    select 
    to_char(b.book_date,'MMM-YY') as month_name,
    t.passenger_id,
    t.passenger_name,
    b.total_amount,
    dense_rank() over(partition by to_char(b.book_date,'MMM-YY') order by b.total_amount Asc) as rank
    from bookings as b 
    join tickets as t 
    on b.book_ref=t.book_ref 
)
select 
month_name,
passenger_id,
passenger_name,
total_amount
from monthly_payment
where rank=1;


6.	Identify the travel details of non stop journeys  or return journeys (having more than 1 flight).
Expected Output: Passenger_id, passenger_name, ticket_number and flight count.

Answer:
select 
t.passenger_id,
t.passenger_name,
t.ticket_no as ticket_number,
count(f.flight_id) as Flight_count
from tickets t 
join ticket_flights tf 
on t.ticket_no=tf.ticket_no
join flights f 
on f.flight_id=tf.flight_id
group by 1,2,3
having count(f.flight_id)>1;


7.	How many tickets are there without boarding passes?
Expected Output: just one number is required.

Answer:
select 
count(t.ticket_no) as tickets_without_boarding_passes
from tickets as t 
left join boarding_passes as b 
on t.ticket_no=b.ticket_no
where b.ticket_no is null;


8.	Identify details of the longest flight (using flights table)?
Expected Output: Flight number, departure airport, arrival airport, aircraft code and durations.

Answer:
select 
    distinct flight_no,
    departure_airport,
    arrival_airport,
    aircraft_code,
    scheduled_arrival-scheduled_departure as duration
 from flights
 where (scheduled_arrival-scheduled_departure) =
 ( select MAX(scheduled_arrival-scheduled_departure)
     from flights)
 order by 1;


9.	Identify details of all the morning flights (morning means between 6AM to 11 AM, using flights table)?
Expected output: flight_id, flight_number, scheduled_departure, scheduled_arrival and timings.

Answer:
select 
    flight_id,
    flight_no as flight_number,
    scheduled_departure,
    scheduled_arrival,
    cast(scheduled_departure as time) as timings 
 from flights
from flights 
where cast(scheduled_departure as time) between '06:00:00' and '11:00:00';


10.	Identify the earliest morning flight available from every airport.
Expected output: flight_id, flight_number, scheduled_departure, scheduled_arrival, departure airport and timings.
   
Answer:
WITH RankedFlights AS (
    SELECT Flight_ID,
           flight_no,
           Scheduled_Departure,
           Scheduled_Arrival,
           Departure_Airport,
           dense_rank() OVER (PARTITION BY Departure_Airport ORDER BY Scheduled_Departure) AS Flight_Rank
    FROM Flights
    WHERE extract(hour from scheduled_departure) > 2 and extract(hour from scheduled_departure) < 6)
SELECT Flight_ID,
       Flight_No,
       Scheduled_Departure,
       Scheduled_Arrival,
       Departure_Airport,
       cast(scheduled_departure as time) as timings 
FROM RankedFlights
WHERE Flight_Rank=1;


11.	Questions: Find list of airport codes in Europe/Moscow timezone
 Expected Output:  Airport_code. 

Answer:
select 
    airport_code
from airports
where timezone='Europe/Moscow';


12.	Write a query to get the count of seats in various fare condition for every aircraft code?
 Expected Outputs: Aircraft_code, fare_conditions ,seat count

Answer:
select 
    aircraft_code,
    fare_conditions,
    count(seat_no) as seat_count
from seats
group by 1,2;


13.	How many aircrafts codes have at least one Business class seats?
 Expected Output : Count of aircraft codes

Answer:
select 
   count(distinct aircraft_code) as count_of_aircraft_codes
from seats
where fare_conditions='Business';


14.	Find out the name of the airport having maximum number of departure flight
 Expected Output : Airport_name 

Answer:
select 
a.airport_name
from flights f 
join airports a 
on f.departure_airport=a.airport_code
group by 1
order by count(*) desc
limit 1;


15.	Find out the name of the airport having least number of scheduled departure flights
 Expected Output : Airport_name 

Answer:
select 
a.airport_name
from flights f 
join airports a 
on f.departure_airport=a.airport_code
group by 1
order by count(*) asc
limit 1;


16.	How many flights from ‘DME’ airport don’t have actual departure?
 Expected Output : Flight Count 
   
Answer:
select 
   count(flight_id) as flight_count 
from flights
where actual_departure is null 
AND departure_airport='DME';


17.	Identify flight ids having range between 3000 to 6000
 Expected Output : Flight_Number , aircraft_code, ranges 

Answer:
select 
 distinct f.flight_no as flight_number,
 a.aircraft_code,
 a.range 
from flights as f 
join aircrafts as a 
on f.aircraft_code=a.aircraft_code
where a.range between 3000 and 6000;


18.	Write a query to get the count of flights flying between URS and KUF?
 Expected Output : Flight_count

Answer:
SELECT 
    COUNT(*) AS flight_count
FROM 
    flights
WHERE 
    departure_airport IN ('URS', 'KUF') 
    AND arrival_airport IN ('URS', 'KUF') 
    AND departure_airport != arrival_airport;  


19.	Write a query to get the count of flights flying from either from NOZ or KRR?
 Expected Output : Flight count 

Answer:
select 
   count(*) as flight_count
from flights
where departure_airport in ('NOZ', 'KRR');


20.	Write a query to get the count of flights flying from KZN,DME,NBC,NJC,GDX,SGC,VKO,ROV
Expected Output : Departure airport ,count of flights flying from these   airports.

Answer:
select 
    departure_airport,
   count(*) as flight_count
from flights
where departure_airport in ('KZN','DME','NBC','NJC','GDX','SGC','VKO','ROV') 
group by 1;


21.	Write a query to extract flight details having range between 3000 and 6000 and flying from DME
Expected Output :Flight_no,aircraft_code,range,departure_airport

Answer:
select 
 distinct f.flight_no,
 a.aircraft_code,
 a.range,
 f.departure_airport 
from flights as f 
join aircrafts as a 
on f.aircraft_code=a.aircraft_code
where a.range between 3000 and 6000 
AND departure_airport='DME';


22.	Find the list of flight ids which are using aircrafts from “Airbus” company and got cancelled or delayed
 Expected Output : Flight_id,aircraft_model

Answer:
select 
f.flight_id,
a.model as aircraft_model
from flights as f 
join aircrafts as a 
on f.aircraft_code=a.aircraft_code
where a.model like '%Airbus%' 
AND f.status in('Cancelled', 'Delayed');


23.	Find the list of flight ids which are using aircrafts from “Boeing” company and got cancelled or delayed
Expected Output : Flight_id,aircraft_model

Answer: 
select 
f.flight_id,
a.model as aircraft_model
from flights as f 
join aircrafts as a 
on f.aircraft_code=a.aircraft_code
where (a.model like '%Boeing%' )
AND f.status in('Cancelled', 'Delayed');


24.	Which airport(name) has most cancelled flights (arriving)?
              Expected Output : Airport_name 

Answer: 
with T1 as (select 
    a.airport_name,
    count(*) as cancelled_flight_count,
    rank() over(order by count(*) desc) as rank
    from airports as a 
    join flights as f 
    on a.airport_code=f.arrival_airport
    where f.status='Cancelled'
    group by 1)
select 
airport_name
from T1
where rank=1;


25.	Identify flight ids which are using “Airbus aircrafts”
Expected Output : Flight_id,aircraft_model

Answer:
select 
f.flight_id,
a.model as aircraft_model
from flights as f 
join aircrafts as a 
on f.aircraft_code=a.aircraft_code
where (a.model like '%Airbus%' );


26.	Identify date-wise last flight id flying from every airport?
Expected Output: Flight_id,flight_number,schedule_departure,departure_airport

Answer:

WITH Last_flight_each_day AS (
    SELECT flight_id,
           flight_no as flight_number,
           scheduled_departure,
           departure_airport,
           ROW_NUMBER() OVER (PARTITION BY departure_airport, DATE(scheduled_departure) ORDER BY scheduled_departure DESC) AS flight_rank
    FROM flights
)
SELECT 
           flight_id,
           flight_number,
           scheduled_departure,
           departure_airport
FROM Last_flight_each_day
WHERE flight_rank = 1;


27.	Identify list of customers who will get the refund due to cancellation of the flights and how much amount they will get?
Expected Output : Passenger_name,total_refund.

Answer:
select 
t.passenger_name,
MAX(tf.amount) as total_refund
from flights f 
join ticket_flights tf 
on f.flight_id=tf.flight_id
join tickets t 
on tf.ticket_no=t.ticket_no
where f.status='Cancelled'
group by 1;


28.	Identify date wise first cancelled flight id flying for every airport?
Expected Output : Flight_id,flight_number,schedule_departure,departure_airport

Answer:
WITH first_cancelled_flight_each_day AS (
    SELECT flight_id,
           flight_no as flight_number,
           scheduled_departure,
           departure_airport,
           ROW_NUMBER() OVER (PARTITION BY departure_airport, DATE(scheduled_departure) ORDER BY scheduled_departure ASC) AS flight_rank
    FROM flights
    where status='Cancelled'
)
SELECT 
           flight_id,
           flight_number,
           scheduled_departure,
           departure_airport
FROM first_cancelled_flight_each_day
WHERE flight_rank = 1;


29.	Identify list of Airbus flight ids which got cancelled.
Expected Output : Flight_id

Answer:
select 
f.flight_id
from flights as f 
join aircrafts as a 
on f.aircraft_code=a.aircraft_code
where (a.model like '%Airbus%' ) AND f.status='Cancelled';


30.	Identify list of flight ids having highest range.
 Expected Output : Flight_no, range

Answer: 
select 
f.flight_id
from flights as f 
join aircrafts as a 
on f.aircraft_code=a.aircraft_code
where a.range= (
    select 
    MAX (range)
    from aircrafts ); 
