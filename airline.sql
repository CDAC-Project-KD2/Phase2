CREATE DATABASE airline;
USE airline;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role ENUM('ADMIN','STAFF','PASSENGER') NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    status ENUM('ACTIVE','INACTIVE') DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (role, full_name, email, password_hash, phone)
VALUES
('ADMIN','System Admin','admin@airline.com','hash123','9999999999'),
('STAFF','Rahul Sharma','rahul@airline.com','hash456','8888888888'),
('PASSENGER','Amit Verma','amit@gmail.com','hash789','7777777777');


CREATE TABLE staff_details (
    staff_id INT PRIMARY KEY,
    designation VARCHAR(50) NOT NULL,
    assigned_airport VARCHAR(50),
    CONSTRAINT fk_staff_user
        FOREIGN KEY (staff_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

INSERT INTO staff_details
VALUES (2,'Ground Staff','Mumbai Airport');


CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    source VARCHAR(50) NOT NULL,
    destination VARCHAR(50) NOT NULL,
    distance_km INT CHECK (distance_km > 0),
    duration_minutes INT CHECK (duration_minutes > 0),
    UNIQUE (source, destination)
);

INSERT INTO routes (source, destination, distance_km, duration_minutes)
VALUES
('Mumbai','Delhi',1400,120),
('Pune','Bangalore',840,100);


CREATE TABLE aircraft (
    aircraft_id INT AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(50) NOT NULL,
    total_seats INT CHECK (total_seats > 0)
);

INSERT INTO aircraft (model, total_seats)
VALUES
('Airbus A320',180),
('Boeing 737',160);


CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(20) NOT NULL UNIQUE,
    route_id INT NOT NULL,
    aircraft_id INT NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    base_price DECIMAL(10,2) CHECK (base_price > 0),
    status ENUM('ON_TIME','DELAYED','CANCELLED') DEFAULT 'ON_TIME',
    CONSTRAINT fk_flight_route FOREIGN KEY (route_id) REFERENCES routes(route_id),
    CONSTRAINT fk_flight_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id)
);

INSERT INTO flights
(flight_number, route_id, aircraft_id, departure_time, arrival_time, base_price)
VALUES
('AI101',1,1,'2026-02-01 10:00','2026-02-01 12:00',5500.00);


CREATE TABLE flight_staff (
    id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    staff_id INT NOT NULL,
    CONSTRAINT fk_fs_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    CONSTRAINT fk_fs_staff FOREIGN KEY (staff_id) REFERENCES staff_details(staff_id),
    UNIQUE (flight_id, staff_id)
);

INSERT INTO flight_staff (flight_id, staff_id)
VALUES (1,2);


CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    pnr VARCHAR(20) NOT NULL UNIQUE,
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('CONFIRMED','CANCELLED') DEFAULT 'CONFIRMED',
    total_amount DECIMAL(10,2) CHECK (total_amount >= 0),
    CONSTRAINT fk_booking_user FOREIGN KEY (passenger_id) REFERENCES users(user_id),
    CONSTRAINT fk_booking_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

INSERT INTO bookings (pnr, passenger_id, flight_id, total_amount)
VALUES ('PNR12345',3,1,5500.00);


CREATE TABLE passenger_details (
    passenger_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    age INT CHECK (age > 0),
    gender ENUM('M','F','O'),
    seat_number VARCHAR(5),
    CONSTRAINT fk_passenger_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

INSERT INTO passenger_details
(booking_id, name, age, gender, seat_number)
VALUES (1,'Amit Verma',30,'M','12A');


CREATE TABLE check_in (
    checkin_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    checked_in BOOLEAN DEFAULT FALSE,
    boarded BOOLEAN DEFAULT FALSE,
    checkin_time DATETIME,
    CONSTRAINT fk_checkin_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);
INSERT INTO check_in
(booking_id, checked_in, boarded, checkin_time)
VALUES (1,TRUE,FALSE,NOW());


CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    amount DECIMAL(10,2) CHECK (amount > 0),
    payment_method VARCHAR(50),
    payment_status ENUM('SUCCESS','FAILED') NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

INSERT INTO payments
(booking_id, amount, payment_method, payment_status)
VALUES (1,5500.00,'UPI','SUCCESS');


CREATE TABLE cancellations (
    cancellation_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    cancelled_by ENUM('PASSENGER','STAFF','ADMIN'),
    cancellation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    refund_amount DECIMAL(10,2) CHECK (refund_amount >= 0),
    CONSTRAINT fk_cancel_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

INSERT INTO cancellations
(booking_id, cancelled_by, refund_amount)
VALUES (1,'PASSENGER',5000.00);
