IF object_id('conn_cashier_customer','U') is not null DROP TABLE conn_cashier_customer;
IF object_id('booking_ticket','U') is not null DROP TABLE booking_ticket;
IF object_id('customer','U') is not null DROP TABLE customer;
IF object_id('movie','U') is not null DROP TABLE movie;
IF object_id('cashier','U') is not null DROP TABLE cashier;
GO

--Creating table
CREATE TABLE cashier(
employee_id int primary key,
employee_name varchar(100),
employee_address varchar(100),
employee_bankaccount varchar(100),
employee_insurance varchar(100),
employee_salary int
);

CREATE TABLE movie(
movie_id int primary key,
movie_name varchar(100),
movie_language varchar(50),
movie_duration int,
movie_type varchar(100),
movie_date date
);

CREATE TABLE customer(
customer_id int primary key,
customer_name varchar(100),
customer_mobile varchar(30),
customer_email varchar(100),
customer_address varchar(100),
customer_discountPrice int
);

CREATE TABLE booking_ticket(
ticket_id int primary key,
ticket_date datetime,          
ticket_venue int,
ticket_number int,
customer_ticket int NOT NULL references customer(customer_id),
cashier_ticket int NOT NULL references cashier(employee_id),
movie_ticket int NOT NULL references movie(movie_id)
);

CREATE TABLE conn_cashier_customer(
conn_id int identity primary key,
conn_cashier int references cashier(employee_id),
conn_customer int references customer(customer_id),
CONSTRAINT	uq_conn_cashier_customer UNIQUE(conn_cashier,conn_customer)
);


--Insert
INSERT INTO cashier(employee_id ,employee_name,employee_address,employee_bankaccount,employee_insurance ,employee_salary )
VALUES(1,'Ally Smith','Csengery 82','5443213-5642219 ','A65B7',100000);
INSERT INTO cashier VALUES(2,'Meg WilL','Becsi 44','5643457-9876515','B98C6',10500);
INSERT INTO cashier VALUES(3,'Alan Johnson','Bertalan 67','1238765-1753457','N76M9',110000);
INSERT INTO cashier VALUES(4,'Alex Pitt','Will 54','1238765-1753459','H76M0',100000);
INSERT INTO cashier VALUES(5,'Bekbolsun Botoev','Sputni 16','1238765-2753457','M36M9',200000);

INSERT INTO movie VALUES(1,'Twilight','English', 90,'fantasy','2020-10-18');
INSERT INTO movie VALUES(2,'Hidden figures','German', 100,'drama','2020-10-14');
INSERT INTO movie VALUES(3,'Peculiar children','Russian', 120,'fantasy','2019-10-19');
INSERT INTO movie VALUES(4,'Darak yry','Kyrgyz', 120,'historical movie','2019-10-20');
INSERT INTO movie VALUES(5,'Kurmanjan Datka','Kyrgyz', 120,'historical movie','2021-10-21');


INSERT INTO customer VALUES(1,'Kate Wilson','706102030','kate@gmail.com','Istvan 10',1000);
INSERT INTO customer VALUES(2,'Anne Hath','708105030','anne@gmail.com','Deak 15',4000);
INSERT INTO customer VALUES(3,'Anton Pavel','709105010','anton@gmail.com','Dorothy 18',3000);
INSERT INTO customer VALUES(4,'Alymkan Botoeva','709809023','alymkan@gmail.com','Sputnik 17',4000);
INSERT INTO customer VALUES(5,'Anne Hath','708105030','anne@gmail.com','Deak 15',1000);

INSERT INTO booking_ticket VALUES(1,'2020-10-18 15:20:00',5,7,1,3,2);
INSERT INTO booking_ticket VALUES(2,'2020-10-14 11:00:00',9,8,3,2,1);
INSERT INTO booking_ticket VALUES(3,'2020-10-19 17:30:00',11,2,2,1,3);
INSERT INTO booking_ticket VALUES(4,'2020-10-19 12:10:00',18,9,5,4,4);
INSERT INTO booking_ticket VALUES(5,'2020-10-19 14:50:00',13,10,4,5,5);
INSERT INTO booking_ticket VALUES(6,'2020-10-19 17:30:00',18,7,4,2,3);
INSERT INTO booking_ticket VALUES(7,'2020-10-19 17:30:00',15,6,5,5,5);
INSERT INTO booking_ticket VALUES(8,'2020-10-19 17:30:00',19,12,3,5,2);
INSERT INTO booking_ticket VALUES(9,'2020-10-19 17:30:00',10,2,1,4,5);


INSERT INTO conn_cashier_customer (conn_cashier,conn_customer) VALUES
(1,1),(1,2),(1,3),(2,1),(2,3),(2,2),(3,2),(5,3),(4,3),(1,5),(3,5);

--Query 1: List cashiers and their data
SELECT * FROM cashier ;

--Query 2: List customers and their data
SELECT * FROM customer;

--Query 3: List movies and their data
SELECT * FROM movie;

--Query 4: List customer names with their average price of tickets 
SELECT customer_name, sum(customer_discountPrice) as summ
FROM customer
GROUP BY customer_name;

--Query 5: Using row level functions, 
SELECT movie_name,movie_date,
concat(datediff(month,movie_date,getdate()),'month(s)') as passed
FROM movie;
--Query 6: Count movies by their movie language
SELECT count(movie_name) as numberOfFilms,movie_language
FROM movie
GROUP BY movie_language;

--Query 7: Count movies by their year
SELECT count(1) as numOfmovie,year(movie_date) as years
FROM movie
GROUP BY datepart(year,movie_date);

--Query 8: Find the venue of customer whose name is Alymkan Botoeva
SELECT ticket_venue as venue
FROM customer INNER JOIN booking_ticket ON(customer_id=customer_ticket)
WHERE customer_name='Alymkan Botoeva';

--Query 9: List customer name and movie name where movie is Kyrgyz language
SELECT customer_name,movie_name
FROM booking_ticket INNER JOIN customer ON(customer_id=customer_ticket)
                    INNER JOIN movie ON(movie_id=movie_ticket)
WHERE movie_language like 'Kyrgyz';

--Query 10: List customer name and cashier name where ticket price is 1000 Forint
SELECT LOWER(customer_name),employee_name
FROM customer INNER JOIN conn_cashier_customer ON(customer_id=conn_customer)
              INNER JOIN cashier ON(employee_id=conn_cashier)
WHERE customer_discountPrice=1000;

--QUERY 11: List the customers who chose the fantasy movie and date 
--time and list the cashiers who served
SELECT distinct upper(customer_name) as customername,employee_name,movie_name, ticket_date
FROM conn_cashier_customer INNER JOIN customer ON(conn_customer=customer_id)
                           INNER JOIN cashier ON(conn_cashier=employee_id),
					movie  INNER JOIN booking_ticket ON(movie_id=movie_ticket)
WHERE movie_type='fantasy';

--Query 12: List customer name and cashier name where cashiers’ salary is 100000
SELECT customer_name, employee_name
FROM conn_cashier_customer INNER JOIN customer ON(conn_customer=customer_id)
                           INNER JOIN cashier ON(conn_cashier=employee_id)
WHERE employee_salary=100000;

--Query 13: List the cashiers whose salary is bigger than average 
SELECT employee_name, employee_salary
FROM cashier
WHERE employee_salary >(SELECT avg(employee_salary) FROM cashier);
--Query 14: Maximum number of customers who chose the fantasy movie
SELECT max(calculate.numberOfPeople) as maximum
FROM (SELECT customer_name,  count(1) as numberOfPeople,customer_id
      FROM conn_cashier_customer INNER JOIN customer ON(conn_customer=customer_id)
                                 INNER JOIN cashier ON(conn_cashier=employee_id),
					      movie  INNER JOIN booking_ticket ON(movie_id=movie_ticket)
	  WHERE movie_type='fantasy'
	  GROUP BY customer_name,customer_id  ) as calculate
	                             INNER JOIN customer ON(calculate.customer_id=customer.customer_id);

--Query 15: Minimum number of customers who chose the fantasy movie
SELECT min(calculate.numberOfPeople) as minimum
FROM (SELECT customer_name,  count(1) as numberOfPeople,customer_id
      FROM conn_cashier_customer INNER JOIN customer ON(conn_customer=customer_id)
                                 INNER JOIN cashier ON(conn_cashier=employee_id),
					      movie  INNER JOIN booking_ticket ON(movie_id=movie_ticket)
	  WHERE movie_type='fantasy'
	  GROUP BY customer_name,customer_id  ) as calculate
	                             INNER JOIN customer ON(calculate.customer_id=customer.customer_id);

--Query 16: Calculate average that how many customers chose that movie language is Kyrgyz or Russian
SELECT avg(numberOfPeople) as average
FROM (SELECT customer_name,  count(1) as numberOfPeople,customer_id
      FROM conn_cashier_customer INNER JOIN customer ON(conn_customer=customer_id)
                                 INNER JOIN cashier ON(conn_cashier=employee_id),
					      movie  INNER JOIN booking_ticket ON(movie_id=movie_ticket)
	  WHERE movie_language IN ('Kyrgyz','Russian')
	  GROUP BY customer_name,customer_id  ) as calculate
	                             INNER JOIN customer ON(calculate.customer_id=customer.customer_id);

--Query 17: Number of people who chose the film in the 2020-10-18
SELECT calculate.numberOfPeople as number
FROM (SELECT customer_name,  count(customer_id) as numberOfPeople,customer_id
      FROM conn_cashier_customer INNER JOIN customer ON(conn_customer=customer_id)
                                 INNER JOIN cashier ON(conn_cashier=employee_id),
					      movie  INNER JOIN booking_ticket ON(movie_id=movie_ticket)
	  WHERE movie_date='2020-10-18'
	  GROUP BY customer_name, customer_id ) as calculate
	                             INNER JOIN customer ON(calculate.customer_id=customer.customer_id);




--Query 18:Calculate the number of movies that a customer watched
SELECT customer_name, grouping(customer_name) as nameGrouping,  
count(customer_name) as numberOfWatching,movie_name, grouping(movie_name) as movieGrouping
      FROM conn_cashier_customer INNER JOIN customer ON(conn_customer=customer_id)
                                 INNER JOIN cashier ON(conn_cashier=employee_id),
					      movie  INNER JOIN booking_ticket ON(movie_id=movie_ticket)
	  WHERE movie_type='fantasy'
	  GROUP BY GROUPING SETS((customer_name,movie_name),(customer_name));

--Query 19: Listing number of watching of a customer the same movie, number of watching
--of each movie, number of watching of fantasy movies, number of watching of 
--each person that watched fantasy movie
SELECT customer_name, grouping(customer_name) as nameGrouping,  
count(customer_name) as numberOfWatching,movie_name, grouping(movie_name) as movieGrouping
      FROM conn_cashier_customer INNER JOIN customer ON(conn_customer=customer_id)
                                 INNER JOIN cashier ON(conn_cashier=employee_id),
					      movie  INNER JOIN booking_ticket ON(movie_id=movie_ticket)
	  WHERE movie_type='fantasy'
	  GROUP BY CUBE(customer_name,movie_name);

--Query 20: : Listing number of watching of a customer the same movie,
--number of watching of each person that watched fantasy movie
SELECT customer_name, grouping(customer_name) as nameGrouping,  
count(customer_name) as numberOfWatching,movie_name, grouping(movie_name) as movieGrouping
      FROM conn_cashier_customer INNER JOIN customer ON(conn_customer=customer_id)
                                 INNER JOIN cashier ON(conn_cashier=employee_id),
					      movie  INNER JOIN booking_ticket ON(movie_id=movie_ticket)
	  WHERE movie_type='fantasy'
	  GROUP BY ROLLUP(customer_name,movie_name);

--Query 21: Listing number of watching of a customer the same movie,
--number of watching of each movie, number of watching of fantasy movies
SELECT customer_name, grouping(customer_name) as nameGrouping,  
count(customer_name) as numberOfWatching,movie_name, grouping(movie_name) as movieGrouping
      FROM conn_cashier_customer INNER JOIN customer ON(conn_customer=customer_id)
                                 INNER JOIN cashier ON(conn_cashier=employee_id),
					      movie  INNER JOIN booking_ticket ON(movie_id=movie_ticket)
	  WHERE movie_type='fantasy'
	  GROUP BY ROLLUP(movie_name,customer_name);
	  
-- Query 22: List the number of movie by language, name, type
SELECT count(movie_name) as numberOfFilms,movie_language, GROUPING(movie_language)as languageGrouping,
movie_name, GROUPING(movie_name) as nameGrouping,movie_type, GROUPING(movie_type) as typeGrouping
FROM movie
GROUP BY GROUPING SETS (( movie_language,movie_name,movie_type),(movie_language));


--Query 23: update 1 adding random price 
UPDATE customer
SET customer_discountPrice= round(((4000+100-1)*rand()+100),0)
WHERE customer_id=2;
SELECT* FROM customer;
--Query 24 :update using subquery. 
--Update 2. Update cashiers’ salary that customers who watch “Kurmanjan Datka”

UPDATE cashier
SET employee_salary=employee_salary*2
WHERE employee_id IN
(
SELECT cashier.employee_id
FROM (
       SELECT employee_id, count(customer_email) as numberOfEmail
	   FROM cashier INNER JOIN conn_cashier_customer ON(conn_cashier=employee_id)
	                INNER JOIN customer ON(conn_customer=customer_id)
	   WHERE customer_email='alymkan@gmail.com' or customer_email='anton@gmail.com'
	   GROUP BY employee_id
     )as clients
	 INNER JOIN cashier ON(cashier.employee_id=clients.employee_id),
	 movie  INNER JOIN booking_ticket ON(movie_id=movie_ticket)
	 WHERE movie_name='Kurmanjan Datka'
)
SELECT *FROM cashier;
--Query 25
--Insert 1: Insert new row to the movie table

INSERT INTO movie VALUES(6,'Cinderella','English', 90,'cartoon','2019-10-21');
SELECT * FROM movie;
-- Query 26: Insert 2: Insert new record for customer
INSERT INTO customer(customer_id,customer_name,customer_discountPrice)
VALUES(6,'Begai Manas kyzy',
(SELECT distinct customer_discountPrice*2
FROM customer
WHERE customer_discountPrice=1000
));
SELECT * FROM customer;
--Query 27 : Deleting bookingticket where ticketid is 9

SELECT *FROM booking_ticket;
DELETE booking_ticket from booking_ticket WHERE ticket_id=9;
SELECT *FROM booking_ticket;

--Query 28:  Delete 2: Delete ticketId where ticket price is 1000 Forint

SELECT*FROM booking_ticket;
DELETE booking_ticket FROM booking_ticket
             INNER JOIN customer ON(customer_id=customer_ticket)
WHERE customer_id IN
(
SELECT ticket_id
FROM booking_ticket INNER JOIN customer ON(customer_id=customer_ticket)
WHERE customer_discountPrice=1000
)
SELECT*FROM booking_ticket;
         

