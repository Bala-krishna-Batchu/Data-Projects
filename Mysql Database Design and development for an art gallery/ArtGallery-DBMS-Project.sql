create database artgallery;

use artgallery;

create table artists(
artist_id int(18) not null,
artist_name varchar(30),
artist_age int(11),
artist_birthplace varchar(30),
constraint artists_pk primary key (artist_id)
);

describe artists;

create table staff(
staff_id int(11) not null,
staff_name varchar(30) not null,
Staff_Address varchar(35),
staff_phone int(11),
staff_designation varchar(25),
constraint staff_pk primary key (staff_id)
);

describe staff;


create table gallery_info(
room_id int(11) not null,
no_of_arts int(11),
cameras_installed int(11),
staff_id int(11),
constraint gallery_info_pk primary key (room_id),
constraint gallery_info_fk1 foreign key (staff_id) REFERENCES staff(staff_id)
);

describe gallery_info;

create table artwork(
art_id int(11) not null,
year_developed int(11),
unique_art_title varchar(30),
type_of_art varchar(30),
colors_used varchar(20),
artist_id int(18),
room_id int(11),
constraint artwork_pk primary key (art_id),
constraint artwork_fk1 foreign key (artist_id) REFERENCES artists(artist_id),
constraint artwork_fk2 foreign key (room_id) REFERENCES gallery_info(room_id)
);

describe artwork;

create table customers(
customer_registration_id int(11) not null,
customer_name varchar(25),
customer_Address varchar(35),
customer_phone_number int(11),
customer_amount_spent double,
customer_interest varchar(30),
constraint customers_pk primary key (customer_registration_id)
);

describe customers;

create table transaction(
art_id int(11),
customer_registration_id int(11),
constraint transaction_pk primary key (art_id,customer_registration_id),
CONSTRAINT transaction_fk1 foreign key(art_id) references artwork(art_id),
CONSTRAINT transaction_fk2 foreign key(customer_registration_id) references customers(customer_registration_id)
);

describe transaction;

create table auction(
auction_id int(11) not null,
auc_startdate date,
auc_enddate date,
min_bidprice double,
auc_starttime time,
auc_endtime time,
customer_registration_id int(11),
art_id int(11),
constraint auction_pk primary key (auction_id),
CONSTRAINT auction_fk1 foreign key(customer_registration_id) references customers(customer_registration_id),
CONSTRAINT auction_fk2 foreign key(art_id) references artwork(art_id)
);

describe auction;

select * from transaction;

create table auction_management_staff(
auction_id int(11),
staff_id int(11),
constraint auction_mng_pk primary key (auction_id,staff_id),
CONSTRAINT auction_mng_fk1 foreign key(auction_id) references auction(auction_id),
CONSTRAINT auction_mng_fk2 foreign key(staff_id) references staff(staff_id)
);

describe auction_management_staff;

select * from auction_management_staff;

INSERT INTO artists(artist_id,artist_name,artist_age,artist_birthplace) VALUES ('101','Yang Fudong','33','sanfransisco'),('102','hussian','75','Mumbai'),('103','daVinci','45','Italy'),('104','GeorgesSeurat','65','ontario'),('105','Vermeer','56','Delhi'),('106','Giotto','78','London'),('107','DIEGO','43','spain'),('108','carlos','54','brazil'),('109','JohnWhite','49','Russia'),('110','jackson','23','losangeles');
SELECT * FROM artists;

INSERT INTO customers(customer_registration_id,customer_name,customer_Address,customer_phone_number,customer_amount_spent,customer_interest) VALUES 
('201','krishna','25200 carlos','34567890','33000','sculpture'),
('202','Rohit','25800 carlos','8032919','25000','painting'),
('203','chandu','mission bole','90722654','29000','architecture'),
('204','Rahul','central blvd','9324567','45000','literature'),
('205','Sandeep','lomdon avenue','55667890','85000','music'),
('206','Abhinav','mowry avenue','51349876','65000','cinema'),
('207','Suppu','sarkar avenue','45897345','87000','theater'),
('208','Dileep','louis avenue','98567896','67000','architecture'),
('209','Raja','grand avenue','98432719','87000','architecture'),
('210','mano','paseo padre','98023415','56000','painting');

SELECT * FROM customers;

INSERT INTO staff(staff_id,staff_name,Staff_Address,staff_phone,staff_designation) VALUES 
('301','ashish','25200 carlos','53467890','management'),
('302','vishu','25800 carlos','78695919','maintainance'),
('303','deepu','central blvd','789622654','working'),
('304','Rama','mission blvd','79324567','cleaning'),
('305','Sandy','mowry avenue','855667890','management'),
('306','Avinash','lomdon avenue','51349876','security'),
('307','Swetha','louis avenue','645897345','qualityassurance'),
('308','Dany','sarkar avenue','698567896','cleaning'),
('309','Raghu','paseo padre','78432719','cleaning'),
('310','mona','grand avenue','97023415','maintainance');

SELECT * FROM staff;

INSERT INTO gallery_info(room_id,no_of_arts,cameras_installed,staff_id) VALUES 
('401','15','4','302');

INSERT INTO gallery_info(room_id,no_of_arts,cameras_installed,staff_id) VALUES 
('402','10','5','301'),
('403','21','8','303'),
('404','33','6','304'),
('405','55','6','308'),
('406','22','7','306'),
('407','24','9','303'),
('408','32','8','307'),
('409','13','7','305'),
('410','12','7','303');

SELECT * FROM gallery_info;

INSERT INTO artwork(art_id,year_developed,unique_art_title,type_of_art,colors_used,artist_id,room_id) VALUES 
('501','2005','The Raft of the Medusa','Architecture','warmcolors','101','401'),
('502','2006','Clear Flippers','painting','neutralcolors','101','401'),
('503','2008','The Treachery of Images','sculpture','coolcolors','101','401'),
('504','2009','I Love You With My Ford','literature','warmcolors','102','402'),
('505','2007','In Advance of the Broken Arm','music','primarycolors','102','402'),
('506','2006','Are You Jealous','literature','neutralcolors','102','403'),
('507','2005','The New Yorker','painting','coolcolors','103','403'),
('508','2008','The Smithsonian','sculpture','neutralcolors','103','404'),
('509','2003','The Independent','Architecture','primarycolors','104','404'),
('510','2002','Impression','sculpture','coolcolors','104','405');

SELECT * FROM artwork;

INSERT INTO auction(auction_id,auc_startdate,auc_enddate,min_bidprice,auc_starttime,auc_endtime,customer_registration_id,art_id) VALUES 
('01','2019-08-01','2019-08-01','1000','09:05:00','11:05:00','201','501'),
('02','2020-05-01','2020-05-01','120','10:05:00','12:05:00','201','501'),
('03','2021-06-01','2021-06-01','1500','11:05:00','11:55:00','202','502'),
('04','2022-03-01','2022-03-01','1900','12:05:00','13:05:00','203','503'),
('05','2021-08-01','2021-08-01','1700','13:05:00','14:05:00','204','504'),
('06','2022-02-01','2022-02-01','1400','11:05:00','15:05:00','205','505'),
('07','2010-08-01','2010-08-01','1600','10:05:00','16:05:00','206','506'),
('08','2022-01-01','2022-01-01','1100','12:05:00','17:05:00','209','509'),
('09','2011-08-01','2011-08-01','1300','14:05:00','18:05:00','208','508'),
('10','2021-07-01','2021-07-01','1800','15:05:00','19:05:00','207','507');

SELECT * FROM auction;

INSERT INTO transaction(art_id,customer_registration_id) VALUES 
('501','201'),
('502','201'),
('502','202'),
('503','203'),
('504','204'),
('505','205'),
('506','206'),
('509','209'),
('508','208'),
('507','207');

SELECT * FROM transaction;

INSERT INTO auction_management_staff(auction_id,staff_id) VALUES 
('01','301'),
('02','302'),
('03','303'),
('04','304'),
('05','302'),
('06','303'),
('07','301'),
('08','304'),
('09','303'),
('10','301');

SELECT * FROM transaction;



#join1
SELECT customers.customer_name,customers.customer_interest,transaction.art_id
FROM customers
JOIN transaction ON customers.customer_registration_id=transaction.customer_registration_id;

# join2
SELECT room_id,no_of_arts,cameras_installed
FROM gallery_info
LEFT JOIN staff
ON gallery_info.staff_id = staff.staff_id;

#join 3
SELECT art_id,type_of_art
FROM artists
Right JOIN artwork
ON artists.artist_id = artwork.artist_id;

#view-1
CREATE VIEW customerAuction
AS 
SELECT customer_phone_number, 
    customer_amount_spent
    FROM customers
INNER JOIN
    Auction USING (customer_registration_id);

Select * from customerAuction;

#view2

CREATE VIEW test AS SELECT * FROM auction;

SELECT * FROM test;


#view3
CREATE VIEW auctArt AS
SELECT L1.year_developed, L1.type_of_art,L2.auction_id,L2.min_bidprice
FROM artwork L1, auction L2;

select * from auctArt;



#
#SELECT min_bidprice,staff_id
#FROM auction
#FULL JOIN auction_management_staff ON auction.auction_id = auction_management_staff.auction_id;



#procedure-1

DELIMITER //
CREATE PROCEDURE Getcustomers()
BEGIN
    select customer_name,customer_interest,customer_phone_number from customers;
END //
    
DELIMITER ;

CALL Getcustomers();

#DROP PROCEDURE art;

#procedure -2
DELIMITER $$
	CREATE PROCEDURE art()
			BEGIN 
			SELECT *, year(curdate())-year_developed as artold from artwork;
			END$$


CALL art();


call amountspent();
#procedure 3 to get to know about the customer amount spnt
DELIMITER $$
CREATE PROCEDURE amountspent()
BEGIN
SELECT customer_registration_id,customer_amount_spent
FROM customers
ORDER BY customer_amount_spent;    
END$$



#Trigger
DELIMITER $$
              CREATE TRIGGER UPPERCASE
              BEFORE INSERT on artists
              FOR EACH ROW
              BEGIN
              SET NEW.artist_name=UPPER(NEW.artist_name);
              END$$

SHOW TRIGGERS;


#CREATE PROCEDURE 
#BEGIN
#SELECT  cust_amount_spent,customer_Address
#FROM customers
#ORDER BY cust_amount_spent desc;
#END$$
#DELIMITER ;
#call GetCustomers;

select * from UPPERCASE;


