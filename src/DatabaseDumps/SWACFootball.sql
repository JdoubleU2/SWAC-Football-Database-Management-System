-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 10, 2025 at 11:57 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `SWACDatabase`
--

-- --------------------------------------------------------

--
-- Table structure for table `Coach`
--

CREATE TABLE `Coach` (
  `CoachID` int(11) NOT NULL,
  `Name` varchar(100) DEFAULT NULL,
  `Role` varchar(50) DEFAULT NULL,
  `TeamID` int(11) DEFAULT NULL,
  `StartDate` date DEFAULT NULL,
  `RecordWins` int(11) DEFAULT NULL,
  `RecordLosses` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Coach`
--

INSERT INTO `Coach` (`CoachID`, `Name`, `Role`, `TeamID`, `StartDate`, `RecordWins`, `RecordLosses`) VALUES
(1, 'Connell Maynor', 'Head Coach', 1, '2018-01-16', 40, 32),
(2, 'Eddie Robinson Jr.', 'Head Coach', 2, '2022-01-01', 20, 14),
(3, 'Cedric Thomas', 'Head Coach', 3, '2024-01-01', 2, 6),
(4, 'Alonzo Hampton', 'Head Coach', 4, '2023-01-01', 3, 5),
(5, 'Raymond Woodie Jr.', 'Head Coach', 5, '2023-01-01', 4, 4),
(6, 'Willie Simmons', 'Head Coach', 6, '2018-01-01', 40, 12),
(7, 'Hue Jackson', 'Head Coach', 7, '2022-01-01', 11, 14),
(8, 'T.C. Taylor', 'Head Coach', 8, '2023-01-01', 5, 2),
(9, 'Kendrick Wade', 'Head Coach', 9, '2023-01-01', 1, 6),
(10, 'Tremaine Jackson', 'Head Coach', 10, '2025-01-01', 6, 2),
(11, 'Terrence Graves', 'Head Coach', 11, '2025-01-01', 1, 7),
(12, 'Clarence McKinney', 'Head Coach', 12, '2019-01-01', 12, 32),
(101, 'Chris Shelling', 'Assistant Head Coach / Defensive Coordinator', 1, '2024-01-01', NULL, NULL),
(102, 'Dennis Alexander', 'Offensive Coordinator / Offensive Line', 1, '2024-01-01', NULL, NULL),
(103, 'Marco Coleman', 'Defensive Line / Recruiting Coordinator', 1, '2024-01-01', NULL, NULL),
(104, 'Ronald McKinnon', 'Linebackers Coach', 1, '2024-01-01', NULL, NULL),
(105, 'Kenton Evans', 'Quarterbacks Coach', 1, '2024-01-01', NULL, NULL),
(106, 'Jamaal Fobbs', 'Running Backs Coach', 1, '2024-01-01', NULL, NULL),
(107, 'Antonio Carter', 'Wide Receivers Coach', 1, '2024-01-01', NULL, NULL),
(108, 'Lawann Latson', 'Tight Ends Coach', 1, '2024-01-01', NULL, NULL),
(109, 'Amos Jones', 'Special Teams Coordinator', 1, '2024-01-01', NULL, NULL),
(110, 'Trent Earley', 'Assistant Head Coach / Co-Defensive Coordinator', 10, '2024-01-01', NULL, NULL),
(111, 'Brandon Andersen', 'Defensive Coordinator', 10, '2024-01-01', NULL, NULL),
(112, 'Christopher Buckner', 'Offensive Coordinator', 10, '2024-01-01', NULL, NULL),
(113, 'Jackson Hadley', 'Special Teams Coordinator', 10, '2024-01-01', NULL, NULL),
(114, 'Brice Carlson', 'Run Game Coordinator', 10, '2024-01-01', NULL, NULL),
(115, 'Kapono Asuega', 'Defensive Line Coach', 10, '2024-01-01', NULL, NULL),
(116, 'Darren Garrigan', 'Defensive Backs Coach', 10, '2024-01-01', NULL, NULL),
(117, 'Jacoby Walker', 'Wide Receivers / Recruiting Coordinator', 10, '2024-01-01', NULL, NULL),
(118, 'Clifford Fedd', 'Running Backs Coach', 10, '2024-01-01', NULL, NULL),
(120, 'Justin Sanders', 'Defensive Backs Coach', 8, '2025-01-01', NULL, NULL),
(121, 'Aaron Jackson', 'Defensive Line Coach', 8, '2025-01-01', NULL, NULL),
(122, 'Mario Magana Jr.', 'Director of Player Personnel / Cornerbacks Coach', 8, '2025-01-01', NULL, NULL),
(123, 'Esaias Guthrie', 'Defensive Analyst', 8, '2025-01-01', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `Game`
--

CREATE TABLE `Game` (
  `GameID` int(11) NOT NULL,
  `Date` date DEFAULT NULL,
  `HomeTeamID` int(11) DEFAULT NULL,
  `AwayTeamID` int(11) DEFAULT NULL,
  `Stadium` varchar(100) DEFAULT NULL,
  `Attendance` int(11) DEFAULT NULL,
  `SeasonYear` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Game`
--

INSERT INTO `Game` (`GameID`, `Date`, `HomeTeamID`, `AwayTeamID`, `Stadium`, `Attendance`, `SeasonYear`) VALUES
(1, '2025-08-30', 9, 11, NULL, NULL, 2025),
(2, '2025-08-30', 12, 10, NULL, NULL, 2025),
(3, '2025-08-30', 1, 6, NULL, NULL, 2025),
(4, '2025-08-30', 4, 7, NULL, NULL, 2025),
(5, '2025-08-30', 3, 2, NULL, NULL, 2025),
(6, '2025-09-06', 1, 3, NULL, NULL, 2025),
(7, '2025-09-06', 11, 2, NULL, NULL, 2025),
(8, '2025-09-06', 10, 4, NULL, NULL, 2025),
(9, '2025-09-06', 7, 9, NULL, NULL, 2025),
(10, '2025-09-06', 12, 5, NULL, NULL, 2025),
(11, '2025-09-06', 8, 6, NULL, NULL, 2025),
(12, '2025-09-13', 2, 1, NULL, NULL, 2025),
(13, '2025-09-13', 6, 4, NULL, NULL, 2025),
(14, '2025-09-13', 5, 3, NULL, NULL, 2025),
(15, '2025-09-13', 7, 12, NULL, NULL, 2025),
(16, '2025-09-13', 11, 8, NULL, NULL, 2025),
(17, '2025-09-13', 9, 10, NULL, NULL, 2025);

-- --------------------------------------------------------

--
-- Table structure for table `Player`
--

CREATE TABLE `Player` (
  `PlayerID` int(11) NOT NULL,
  `Name` varchar(100) DEFAULT NULL,
  `TeamID` int(11) DEFAULT NULL,
  `Position` varchar(50) DEFAULT NULL,
  `JerseyNumber` int(11) DEFAULT NULL CHECK (`JerseyNumber` between 0 and 99),
  `Year` varchar(10) DEFAULT NULL,
  `Height` decimal(5,2) DEFAULT NULL,
  `Weight` decimal(5,2) DEFAULT NULL,
  `Birthdate` date DEFAULT NULL,
  `Hometown` varchar(100) DEFAULT NULL,
  `HighSchool` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Player`
--

INSERT INTO `Player` (`PlayerID`, `Name`, `TeamID`, `Position`, `JerseyNumber`, `Year`, `Height`, `Weight`, `Birthdate`, `Hometown`, `HighSchool`) VALUES
(1, 'Dillon Compton', 11, 'QB', 3, 'FR', 6.10, 200.00, '2006-05-14', 'Bunkie, LA', NULL),
(2, 'Cam\'Ron McCoy', 11, 'QB', 0, 'JR', 6.10, 195.00, '2004-09-21', 'St. Louis, MO', NULL),
(3, 'Ashton Strother', 11, 'QB', 15, 'JR', 6.30, 210.00, '2004-04-18', 'Memphis, TN', NULL),
(4, 'Jalen Woods', 11, 'QB', 2, 'SO', 6.10, 200.00, '2005-01-09', 'College Park, GA', NULL),
(5, 'Amariyon Asberry', 11, 'RB', 22, 'FR', 6.00, 210.00, '2006-11-08', 'Baton Rouge, LA', NULL),
(6, 'Princeton Cahee', 11, 'RB', 10, 'SO', 5.10, 190.00, '2005-08-21', 'Lafayette, LA', NULL),
(7, 'Zaccheus Cooper', 11, 'RB', 30, 'FR', 5.10, 210.00, '2006-03-15', 'Scottsdale, AZ', NULL),
(8, 'Mike Franklin', 11, 'RB', 7, 'SR', 6.20, 225.00, '2002-03-22', 'Daphne, AL', NULL),
(9, 'Jason Gabriel', 11, 'RB', 25, 'FR', 5.80, 190.00, '2006-07-11', 'New Orleans, LA', NULL),
(10, 'Trey Holly', 11, 'RB', 6, 'SO', 5.70, 192.00, '2005-09-27', 'Farmerville, LA', NULL),
(11, 'Barry Remo', 11, 'RB', 35, 'SO', 5.90, 195.00, '2005-12-02', 'Baton Rouge, LA', NULL),
(12, 'Christian Smith', 11, 'RB', 20, 'SO', 5.90, 195.00, '2005-10-22', 'Amite, LA', NULL),
(13, 'Herman Batiste', 11, 'WR', 16, 'FR', 6.00, 190.00, '2006-06-30', 'Clinton, LA', NULL),
(14, 'Kobe Brown', 11, 'WR', 14, 'SO', 5.10, 170.00, '2005-02-28', 'Vacherie, LA', NULL),
(15, 'Jordan Dupre', 11, 'WR', 81, 'JR', 5.10, 164.00, '2004-12-12', 'Baton Rouge, LA', NULL),
(16, 'Khalil Harris', 11, 'WR', 8, 'SR', 5.90, 180.00, '2002-11-04', 'Queens, NY', NULL),
(17, 'Jerrod Hicks', 11, 'WR', 11, 'FR', 5.10, 170.00, '2006-10-13', 'Killeen, TX', NULL),
(18, 'Malachi Jackson', 11, 'WR', 18, 'JR', 6.20, 200.00, '2004-03-15', 'Atlanta, GA', NULL),
(19, 'Cam Jefferson', 11, 'WR', 17, 'SO', 5.10, 190.00, '2005-07-16', 'Shreveport, LA', NULL),
(20, 'Damien Knighten', 11, 'WR', 88, 'SO', 5.10, 178.00, '2005-08-25', 'Baton Rouge, LA', NULL),
(21, 'Zackeus Malveaux', 11, 'WR', 80, 'FR', 5.11, 180.00, '2006-01-03', 'Opelousas, LA', NULL),
(22, 'Darren Morris', 11, 'WR', 4, 'JR', 6.20, 190.00, '2004-06-30', 'Baton Rouge, LA', NULL),
(101, 'Cornelious Brown IV', 1, 'QB', 10, 'SR', 6.50, 210.00, '2002-10-21', 'Birmingham, AL', NULL),
(102, 'JD Davis II', 1, 'QB', 7, 'FR', 6.20, 205.00, '2006-04-14', 'Loganville, GA', NULL),
(103, 'Eric Handley', 1, 'QB', 8, 'FR', 6.20, 200.00, '2006-07-11', 'Fultondale, AL', NULL),
(104, 'Ashley Tucker Jr.', 1, 'QB', 18, 'SO', 6.20, 190.00, '2005-02-02', 'Los Angeles, CA', NULL),
(105, 'Zavier Wright', 1, 'QB', 16, 'SR', 6.00, 212.00, '2002-11-18', 'Clarkston, GA', NULL),
(106, 'Antonio Adams', 1, 'RB', 29, 'SO', 5.90, 187.00, '2005-06-07', 'Memphis, TN', NULL),
(107, 'Kaden Dixon', 1, 'RB', 21, 'FR', 6.20, 187.00, '2006-01-15', 'Center, TX', NULL),
(108, 'Maurice Edwards IV', 1, 'RB', 20, 'JR', 5.11, 197.00, '2004-10-04', 'Gurnee, IL', NULL),
(109, 'Kadiphius Iverson', 1, 'RB', 33, 'FR', 5.11, 226.00, '2006-08-10', 'Macon, GA', NULL),
(110, 'EJ King Jr.', 1, 'RB', 34, 'FR', 5.90, 238.00, '2006-09-01', 'Mobile, AL', NULL),
(111, 'Ryan Morrow', 1, 'RB', 26, 'SO', 5.11, 213.00, '2005-05-27', 'Maplesville, AL', NULL),
(112, 'Kolton Nero', 1, 'RB', 32, 'FR', 5.11, 223.00, '2006-05-02', 'Foley, AL', NULL),
(113, 'Isaiah Nwokenkwo', 1, 'RB', 24, 'SR', 5.80, 199.00, '2002-12-11', 'Bradley, IL', NULL),
(114, 'Jordan Chambers-Smith', 1, 'WR', 12, 'FR', 5.11, 150.00, '2006-10-23', 'Madison, AL', NULL),
(115, 'Andre Craig Jr.', 1, 'WR', 11, 'SO', 6.00, 180.00, '2005-03-18', 'Duluth, GA', NULL),
(116, 'Jarvis Davis', 1, 'WR', 15, 'FR', 5.90, 171.00, '2006-04-01', 'Bossier City, LA', NULL),
(117, 'Jaquel Fells Jr.', 1, 'WR', 17, 'SR', 5.60, 201.00, '2002-06-29', 'Birmingham, AL', NULL),
(118, 'Jaden Gresham', 1, 'WR', 80, 'SR', 6.10, 185.00, '2002-09-09', 'Pomona, CA', NULL),
(119, 'Devin Herring', 1, 'WR', 82, 'FR', 6.00, 175.00, '2006-08-13', 'Jacksonville, FL', NULL),
(120, 'Justin Hill', 1, 'WR', 3, 'SR', 5.11, 185.00, '2002-12-29', 'Little Rock, AR', NULL),
(201, 'Montrell Campbell', 1, 'DB', 0, 'RS-SR', 5.10, 176.00, '2002-01-15', 'Madison, AL', 'North Alabama'),
(202, 'Kaleb Brown', 1, 'DB', 2, 'SO', 6.00, 188.00, '2005-02-22', 'Hollywood, SC', 'The Citadel'),
(203, 'Kiel Eldridge', 1, 'DL', 3, 'SO', 6.50, 245.00, '2005-04-07', 'Fort Wayne, IN', 'Toledo'),
(204, 'Anthony Fieldings', 1, 'DB', 5, 'RJ', 5.90, 180.00, '2004-05-11', 'Apopka, FL', 'Apopka HS'),
(205, 'Lynn Pettway', 1, 'DB', 6, 'RS-SR', 5.90, 170.00, '2002-03-12', 'Montgomery, AL', 'Park Crossing HS'),
(206, 'Devedrick Wilson', 1, 'DL', 7, 'RS-SR', 6.20, 300.00, '2002-06-10', 'Kathleen, GA', 'Fort Valley State'),
(207, 'Wyatt Wright', 1, 'LB', 9, 'RJ', 6.10, 202.00, '2004-02-20', 'Bridgeville, DE', 'Arkansas State'),
(208, 'Kylon Roberts', 1, 'DL', 10, 'RJ', 6.20, 250.00, '2004-10-01', 'Hanover, MD', 'Lackawanna College'),
(209, 'Wilburn Smallwood', 1, 'DL', 11, 'JR', 6.30, 224.00, '2003-08-16', 'Lufkin, TX', 'Stephen F. Austin'),
(210, 'Preston Clendenin', 1, 'DB', 13, 'JR', 5.11, 180.00, '2003-06-24', 'Evergreen, AL', 'Hinds CC'),
(211, 'Keon Handley Jr.', 1, 'DB', 14, 'SR', 5.90, 181.00, '2002-07-02', 'McCalla, AL', 'UAB'),
(212, 'Desmon James', 1, 'DB', 15, 'SO', 5.11, 175.00, '2005-08-05', 'Helena, AL', 'UT Martin'),
(213, 'Robert Iverson', 1, 'DB', 16, 'SR', 6.20, 210.00, '2002-02-21', 'Riverdale, GA', 'New Manchester HS'),
(214, 'Tervae Williams', 1, 'LB', 18, 'SR', 6.30, 210.00, '2002-11-17', 'Guthrie, OK', 'Northeastern Oklahoma'),
(215, 'Delbert Mayberry', 1, 'DB', 19, 'SR', 5.11, 170.00, '2002-10-30', 'Sperry, OK', 'Owasso HS'),
(216, 'Jordan Milton', 1, 'DB', 37, 'RS-SR', 6.10, 191.00, '2002-05-11', 'Batesville, MS', 'Itawamba CC'),
(217, 'Miles Gilmore', 1, 'DB', 39, 'FR', 5.80, 173.00, '2006-04-15', 'Detroit, MI', 'Cass Tech HS'),
(218, 'Kentrell Lawson', 1, 'LB', 28, 'RS-SR', 6.00, 230.00, '2002-10-08', 'Marianna, FL', 'Fort Valley State'),
(219, 'Cayden Williams', 1, 'LB', 40, 'FR', 6.20, 221.00, '2006-07-12', 'Daphne, AL', 'Daphne HS'),
(220, 'Marquel Patterson', 1, 'LB', 41, 'FR', 5.10, 205.00, '2006-11-30', 'Birmingham, AL', 'Ramsay HS'),
(301, 'Traven Green', 6, 'QB', 16, 'SO', 6.20, 170.00, '2005-03-09', 'Rockledge, FL', NULL),
(302, 'Tyler Jefferson', 6, 'QB', 3, 'SO', 6.00, 225.00, '2005-06-11', 'High Springs, FL', NULL),
(303, 'RJ Johnson III', 6, 'QB', 12, 'SO', 6.20, 210.00, '2005-02-16', 'Atlanta, GA', NULL),
(304, 'Bryson Martin', 6, 'QB', 15, 'JR', 6.30, 195.00, '2004-10-07', 'Clearwater, FL', NULL),
(305, 'Thad Franklin Jr.', 6, 'RB', 0, 'SR', 6.10, 230.00, '2002-04-14', 'West Park, FL', NULL),
(306, 'Jamal Hailey', 6, 'RB', 28, 'JR', 5.11, 185.00, '2003-08-13', 'Benton Harbor, MI', NULL),
(307, 'Willie Queen', 6, 'RB', 41, 'JR', 5.80, 180.00, '2003-10-10', 'Zephyrhills, FL', NULL),
(308, 'Levontai Summersett', 6, 'RB', 9, 'SO', 5.10, 190.00, '2005-07-17', 'Fort Myers, FL', NULL),
(309, 'Armand Burris', 6, 'WR', 87, 'FR', 6.10, 175.00, '2006-08-19', 'Lincolnshire, IL', NULL),
(310, 'Marquez Bell', 6, 'WR', 4, 'SR', 6.00, 180.00, '2002-12-12', 'Lake City, FL', NULL),
(311, 'Victor Jones Jr.', 6, 'WR', 11, 'SR', 6.10, 212.00, '2002-09-05', 'Orlando, FL', NULL),
(312, 'Ace Cobb', 6, 'WR', 5, 'JR', 6.30, 195.00, '2004-06-07', 'Orlando, FL', NULL),
(313, 'Jacob Brown', 6, 'DL', 96, 'SR', 6.20, 275.00, '2002-04-16', 'Tallahassee, FL', NULL),
(314, 'Isiah Davis', 6, 'LB', 11, 'JR', 6.10, 225.00, '2004-03-29', 'Ocala, FL', NULL),
(315, 'Adeon Farmer', 6, 'DB', 26, 'JR', 5.11, 195.00, '2003-11-22', 'Pensacola, FL', NULL),
(316, 'Ryan Hall', 6, 'LB', 35, 'SR', 6.20, 220.00, '2002-09-17', 'Tampa, FL', NULL),
(317, 'TJ Huggins', 6, 'DB', 21, 'JR', 5.10, 188.00, '2003-01-17', 'Miami, FL', NULL),
(318, 'Daryl Jones', 6, 'DL', 95, 'SR', 6.30, 295.00, '2002-08-11', 'Jacksonville, FL', NULL),
(319, 'Chase Lloyd', 6, 'DB', 12, 'SO', 6.00, 190.00, '2005-04-23', 'Sanford, FL', NULL),
(320, 'Jahon Myers', 6, 'DL', 58, 'JR', 6.20, 260.00, '2004-12-01', 'Fort Lauderdale, FL', NULL),
(321, 'Clyde Pinder', 6, 'DL', 99, 'SR', 6.40, 305.00, '2002-09-09', 'Miami, FL', NULL),
(322, 'Jason Riles', 6, 'DB', 27, 'JR', 5.10, 185.00, '2004-03-25', 'Orlando, FL', NULL),
(323, 'Jalik Thomas', 6, 'LB', 17, 'SO', 6.00, 217.00, '2005-07-13', 'Gainesville, FL', NULL),
(401, 'Trevahn Lawrence', 3, 'QB', 10, 'SR', 6.30, 195.00, '2002-11-12', 'Jacksonville, FL', NULL),
(402, 'Achilles Ringo', 3, 'QB', 19, 'FR', 6.30, 215.00, '2006-02-18', 'Pine Bluff, AR', NULL),
(403, 'Jaylon Tolbert', 3, 'QB', 11, 'JR', 6.20, 175.00, '2004-04-23', 'Fort Lauderdale, FL', NULL),
(404, 'Andre Washington', 3, 'QB', 17, 'JR', 6.40, 215.00, '2004-05-17', 'Hopkins, SC', NULL),
(405, 'Tylan Citizen', 3, 'RB', 23, 'SO', 5.10, 190.00, '2005-08-09', 'Duson, LA', NULL),
(406, 'Reggie Davis', 3, 'RB', 2, 'SR', 6.10, 205.00, '2002-09-30', 'Montgomery, AL', NULL),
(407, 'Kevin May', 3, 'RB', 24, 'SR', 5.10, 205.00, '2002-06-21', 'Jackson, MS', NULL),
(408, 'Carl McDonald Jr.', 3, 'RB', 22, 'FR', 5.80, 180.00, '2006-10-14', 'Natchez, MS', NULL),
(409, 'Traylon Minor', 3, 'RB', 20, 'JR', 5.90, 180.00, '2004-03-29', 'Natchez, MS', NULL),
(410, 'Jacorian Sewell', 3, 'RB', 28, 'SR', 5.90, 195.00, '2002-03-19', 'Natchez, MS', NULL),
(411, 'Camren Stewart', 3, 'RB', 29, 'SO', 5.70, 190.00, '2005-12-05', 'Zachary, LA', NULL),
(412, 'Omarion Blakes', 3, 'WR', 3, 'SO', 5.11, 192.00, '2005-04-09', 'Shaw, MS', NULL),
(413, 'Dylan Everett', 3, 'WR', 87, 'FR', 5.90, 160.00, '2006-02-01', 'Madison, MS', NULL),
(414, 'Joshua Good', 3, 'WR', 85, 'SO', 5.11, 175.00, '2004-09-25', 'Ridgeland, MS', NULL),
(415, 'Elijah Griffin', 3, 'WR', 14, 'SR', 6.40, 215.00, '2002-07-30', 'St. Louis, MO', NULL),
(416, 'Damien Jones', 3, 'WR', 8, 'SR', 5.11, 185.00, '2002-11-09', 'Port Isabel, TX', NULL),
(417, 'Jamar Kaho Jr.', 3, 'WR', 80, 'JR', 6.40, 195.00, '2004-08-17', 'Natchez, MS', NULL),
(418, 'Terrick Latham', 3, 'WR', 83, 'JR', 5.80, 160.00, '2004-03-04', 'Mound Bayou, MS', NULL),
(419, 'Bakari McCall', 3, 'DL', 1, 'SR', 6.20, 270.00, '2002-10-01', 'Jackson, MS', NULL),
(420, 'Geoffreyy Mckelton', 3, 'DB', 2, 'JR', 6.00, 180.00, '2004-01-21', 'Macon, GA', NULL),
(421, 'Orlandus McLaurin', 3, 'LB', 3, 'JR', 6.10, 215.00, '2004-08-30', 'Chicago, IL', NULL),
(422, 'Stemarion Edwards', 3, 'DL', 4, 'SO', 6.10, 265.00, '2005-02-19', 'Greenville, MS', NULL),
(423, 'Brent Barnes', 3, 'LB', 5, 'SR', 6.30, 230.00, '2002-01-07', 'Natchez, MS', NULL),
(424, 'Howard Atterberry', 3, 'DB', 6, 'FR', 6.00, 175.00, '2006-08-02', 'Baton Rouge, LA', NULL),
(425, 'Steve White Jr.', 3, 'LB', 7, 'SR', 6.00, 220.00, '2002-09-14', 'Jackson, MS', NULL),
(426, 'Kendall Fielder', 3, 'DB', 9, 'SO', 6.00, 170.00, '2005-10-11', 'Biloxi, MS', NULL),
(427, 'Sterling Moll', 3, 'DL', 92, 'FR', 6.10, 245.00, '2006-07-09', 'Olive Branch, MS', NULL),
(428, 'Markis Washington', 3, 'CB', 23, 'SO', 6.00, 177.00, '2005-03-25', 'Vicksburg, MS', NULL);

--
-- Triggers `Player`
--
DELIMITER $$
CREATE TRIGGER `CheckPlayerAgeBeforeInsert` BEFORE INSERT ON `Player` FOR EACH ROW BEGIN
  IF (TIMESTAMPDIFF(YEAR, NEW.Birthdate, CURDATE()) < 18) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Player must be at least 18 years old.';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `CheckPlayerAgeBeforeUpdate` BEFORE UPDATE ON `Player` FOR EACH ROW BEGIN
  IF (TIMESTAMPDIFF(YEAR, NEW.Birthdate, CURDATE()) < 18) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Player must be at least 18 years old.';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `PreventMultipleTeams` BEFORE INSERT ON `Player` FOR EACH ROW BEGIN
    -- Check if this player already exists on another team
    IF EXISTS (
        SELECT 1 
        FROM Player
        WHERE Name = NEW.Name
          AND TeamID <> NEW.TeamID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: This player is already assigned to another team.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `PlayerStats`
--

CREATE TABLE `PlayerStats` (
  `StatID` int(11) NOT NULL,
  `GameID` int(11) DEFAULT NULL,
  `PlayerID` int(11) DEFAULT NULL,
  `TeamID` int(11) DEFAULT NULL,
  `PassingYards` int(11) DEFAULT NULL,
  `RushingYards` int(11) DEFAULT NULL,
  `ReceivingYards` int(11) DEFAULT NULL,
  `TDs` int(11) DEFAULT NULL,
  `Interceptions` int(11) DEFAULT NULL,
  `Tackles` int(11) DEFAULT NULL,
  `Sacks` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `PlayerStats`
--

INSERT INTO `PlayerStats` (`StatID`, `GameID`, `PlayerID`, `TeamID`, `PassingYards`, `RushingYards`, `ReceivingYards`, `TDs`, `Interceptions`, `Tackles`, `Sacks`) VALUES
(1001, 1, 3, 11, 626, NULL, NULL, 5, 0, NULL, NULL),
(1002, 2, 10, 11, NULL, 690, NULL, 6, 0, NULL, NULL),
(1003, 3, 22, 11, NULL, NULL, 347, 4, 0, NULL, NULL),
(1004, 4, 20, 11, NULL, NULL, NULL, NULL, 3, 51, NULL),
(1005, 2, 2, 11, 215, 32, NULL, 3, 1, NULL, NULL),
(1006, 3, 5, 11, NULL, 110, NULL, 2, NULL, NULL, NULL),
(1007, 4, 13, 11, NULL, NULL, 131, 2, NULL, NULL, NULL),
(1008, 5, 15, 11, NULL, NULL, 192, 3, NULL, NULL, NULL),
(1009, 6, 16, 11, NULL, NULL, 60, 1, NULL, 5, NULL),
(1010, 6, 102, 1, 120, NULL, NULL, 1, NULL, NULL, NULL),
(1011, 7, 107, 1, NULL, 125, NULL, 2, NULL, NULL, NULL),
(1012, 8, 117, 1, NULL, NULL, 143, 2, NULL, NULL, NULL),
(1013, 9, 215, 1, NULL, NULL, NULL, NULL, 1, 32, NULL),
(1014, 10, 219, 1, NULL, NULL, NULL, NULL, 2, 44, NULL),
(1015, 11, 302, 6, 184, NULL, NULL, 2, 2, NULL, NULL),
(1016, 13, 306, 6, NULL, 138, NULL, 3, NULL, NULL, NULL),
(1017, 14, 312, 6, NULL, NULL, 212, 2, NULL, NULL, NULL),
(1018, 15, 317, 6, NULL, NULL, NULL, NULL, 3, 56, NULL),
(1019, 16, 403, 3, 957, 51, NULL, 6, 2, NULL, NULL),
(1020, 16, 405, 3, NULL, 250, NULL, 2, NULL, NULL, NULL),
(1021, 16, 413, 3, NULL, NULL, 158, 1, NULL, NULL, NULL),
(1022, 16, 425, 3, NULL, NULL, NULL, NULL, 2, 48, NULL),
(1023, 7, 17, 11, NULL, NULL, 59, 1, NULL, NULL, NULL),
(1024, 8, 8, 11, NULL, 56, NULL, 2, NULL, NULL, NULL),
(1025, 9, 18, 11, NULL, NULL, 122, 2, NULL, NULL, NULL),
(1026, 10, 21, 11, NULL, NULL, 100, 1, NULL, NULL, NULL),
(1027, 11, 103, 1, 96, NULL, NULL, 1, NULL, NULL, NULL),
(1028, 12, 108, 1, NULL, 73, NULL, 1, NULL, NULL, NULL),
(1029, 13, 118, 1, NULL, NULL, 119, 1, NULL, NULL, NULL),
(1030, 14, 212, 1, NULL, NULL, NULL, NULL, 1, 21, NULL),
(1031, 12, 304, 6, 78, 23, NULL, 1, NULL, NULL, NULL),
(1032, 13, 307, 6, NULL, 72, NULL, 2, NULL, NULL, NULL),
(1033, 14, 309, 6, NULL, NULL, 88, 1, NULL, NULL, NULL),
(1034, 15, 320, 6, NULL, NULL, NULL, NULL, 1, 23, NULL),
(1039, 7, 17, 11, NULL, NULL, 59, 1, NULL, NULL, NULL),
(1040, 8, 8, 11, NULL, 56, NULL, 2, NULL, NULL, NULL),
(1041, 9, 18, 11, NULL, NULL, 122, 2, NULL, NULL, NULL),
(1042, 10, 21, 11, NULL, NULL, 100, 1, NULL, NULL, NULL),
(1043, 11, 103, 1, 96, NULL, NULL, 1, NULL, NULL, NULL),
(1044, 12, 108, 1, NULL, 73, NULL, 1, NULL, NULL, NULL),
(1045, 13, 118, 1, NULL, NULL, 119, 1, NULL, NULL, NULL),
(1046, 14, 212, 1, NULL, NULL, NULL, NULL, 1, 21, NULL),
(1047, 12, 304, 6, 78, 23, NULL, 1, NULL, NULL, NULL),
(1048, 13, 307, 6, NULL, 72, NULL, 2, NULL, NULL, NULL),
(1049, 14, 309, 6, NULL, NULL, 88, 1, NULL, NULL, NULL),
(1050, 15, 320, 6, NULL, NULL, NULL, NULL, 1, 23, NULL),
(1101, 6, 101, 1, 1421, NULL, NULL, 11, 4, NULL, NULL),
(1102, 7, 106, 1, NULL, 483, NULL, 4, NULL, NULL, NULL),
(1103, 8, 117, 1, NULL, NULL, 287, 2, NULL, NULL, NULL),
(1104, 9, 201, 1, NULL, NULL, NULL, NULL, 2, 39, NULL),
(1201, 11, 301, 6, 2213, NULL, NULL, 10, 7, NULL, NULL),
(1202, 12, 305, 6, NULL, 884, NULL, 9, NULL, NULL, NULL),
(1203, 13, 311, 6, NULL, NULL, 457, 7, NULL, NULL, NULL),
(1204, 14, 315, 6, NULL, NULL, NULL, NULL, 4, 66, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `PlayerTransferLog`
--

CREATE TABLE `PlayerTransferLog` (
  `LogID` int(11) NOT NULL,
  `PlayerID` int(11) DEFAULT NULL,
  `OldTeamID` int(11) DEFAULT NULL,
  `NewTeamID` int(11) DEFAULT NULL,
  `ChangeDate` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Schedule`
--

CREATE TABLE `Schedule` (
  `ScheduleID` int(11) NOT NULL,
  `GameID` int(11) DEFAULT NULL,
  `Week` int(11) DEFAULT NULL,
  `Date` date DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `Broadcaster` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Schedule`
--

INSERT INTO `Schedule` (`ScheduleID`, `GameID`, `Week`, `Date`, `Time`, `Broadcaster`) VALUES
(1, 1, 1, '2025-08-30', '16:00:00', 'SWAC TV'),
(2, 2, 1, '2025-08-30', '19:00:00', 'SWAC TV'),
(3, 3, 1, '2025-08-30', '18:00:00', 'SWAC TV'),
(4, 4, 1, '2025-08-30', '18:00:00', 'SWAC TV'),
(5, 5, 1, '2025-08-30', '18:00:00', 'SWAC TV'),
(6, 6, 2, '2025-09-06', '19:00:00', 'HBCU GO'),
(7, 7, 2, '2025-09-06', '18:00:00', 'SWAC TV'),
(8, 8, 2, '2025-09-06', '17:00:00', 'ESPN+'),
(9, 9, 2, '2025-09-06', '16:00:00', 'SWAC TV'),
(10, 10, 2, '2025-09-06', '16:00:00', 'SWAC TV'),
(11, 11, 2, '2025-09-06', '19:00:00', 'SWAC TV'),
(12, 12, 3, '2025-09-13', '18:00:00', 'SWAC TV'),
(13, 13, 3, '2025-09-13', '19:00:00', 'SWAC TV'),
(14, 14, 3, '2025-09-13', '17:00:00', 'SWAC TV'),
(15, 15, 3, '2025-09-13', '16:00:00', 'SWAC TV'),
(16, 16, 3, '2025-09-13', '14:00:00', 'SWAC TV'),
(17, 17, 3, '2025-09-13', '14:00:00', 'SWAC TV');

--
-- Triggers `Schedule`
--
DELIMITER $$
CREATE TRIGGER `CheckTeamScheduleBeforeInsert` BEFORE INSERT ON `Schedule` FOR EACH ROW BEGIN
    -- Block multiple games for any team in the same week
    IF EXISTS (
        SELECT 1 FROM Schedule s
        JOIN Game g_existing ON s.GameID = g_existing.GameID
        JOIN Game g_new ON NEW.GameID = g_new.GameID
        WHERE s.Week = NEW.Week
          AND (
             g_existing.HomeTeamID = g_new.HomeTeamID OR
             g_existing.HomeTeamID = g_new.AwayTeamID OR
             g_existing.AwayTeamID = g_new.HomeTeamID OR
             g_existing.AwayTeamID = g_new.AwayTeamID
          )
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A team already has a game scheduled this week.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Team`
--

CREATE TABLE `Team` (
  `TeamID` int(11) NOT NULL,
  `Name` varchar(100) DEFAULT NULL,
  `Mascot` varchar(50) DEFAULT NULL,
  `School` varchar(100) DEFAULT NULL,
  `Stadium` varchar(100) DEFAULT NULL,
  `CoachID` int(11) DEFAULT NULL,
  `City` varchar(100) DEFAULT NULL,
  `State` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Team`
--

INSERT INTO `Team` (`TeamID`, `Name`, `Mascot`, `School`, `Stadium`, `CoachID`, `City`, `State`) VALUES
(1, 'Alabama A&M', 'Bulldogs', 'Alabama A&M University', NULL, NULL, 'Normal', 'Alabama'),
(2, 'Alabama State', 'Hornets', 'Alabama State University', NULL, NULL, 'Montgomery', 'Alabama'),
(3, 'Alcorn State', 'Braves', 'Alcorn State University', NULL, NULL, 'Lorman', 'Mississippi'),
(4, 'Arkansas-Pine Bluff', 'Golden Lions', 'University of Arkansas-Pine Bluff', NULL, NULL, 'Pine Bluff', 'Arkansas'),
(5, 'Bethune-Cookman', 'Wildcats', 'Bethune-Cookman University', NULL, NULL, 'Daytona Beach', 'Florida'),
(6, 'Florida A&M', 'Rattlers', 'Florida A&M University', NULL, NULL, 'Tallahassee', 'Florida'),
(7, 'Grambling State', 'Tigers', 'Grambling State University', NULL, NULL, 'Grambling', 'Louisiana'),
(8, 'Jackson State', 'Tigers', 'Jackson State University', NULL, NULL, 'Jackson', 'Mississippi'),
(9, 'Mississippi Valley State', 'Delta Devils', 'Mississippi Valley State University', NULL, NULL, 'Itta Bena', 'Mississippi'),
(10, 'Prairie View A&M', 'Panthers', 'Prairie View A&M University', NULL, NULL, 'Prairie View', 'Texas'),
(11, 'Southern', 'Jaguars', 'Southern University', NULL, NULL, 'Baton Rouge', 'Louisiana'),
(12, 'Texas Southern', 'Tigers', 'Texas Southern University', NULL, NULL, 'Houston', 'Texas');

-- --------------------------------------------------------

--
-- Table structure for table `TeamStats`
--

CREATE TABLE `TeamStats` (
  `TeamStatID` int(11) NOT NULL,
  `GameID` int(11) DEFAULT NULL,
  `TeamID` int(11) DEFAULT NULL,
  `TotalPoints` int(11) DEFAULT NULL,
  `TotalYards` int(11) DEFAULT NULL,
  `Turnovers` int(11) DEFAULT NULL,
  `Penalties` int(11) DEFAULT NULL,
  `TimeOfPossession` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Coach`
--
ALTER TABLE `Coach`
  ADD PRIMARY KEY (`CoachID`);

--
-- Indexes for table `Game`
--
ALTER TABLE `Game`
  ADD PRIMARY KEY (`GameID`),
  ADD KEY `HomeTeamID` (`HomeTeamID`),
  ADD KEY `AwayTeamID` (`AwayTeamID`);

--
-- Indexes for table `Player`
--
ALTER TABLE `Player`
  ADD PRIMARY KEY (`PlayerID`),
  ADD KEY `TeamID` (`TeamID`);

--
-- Indexes for table `PlayerStats`
--
ALTER TABLE `PlayerStats`
  ADD PRIMARY KEY (`StatID`),
  ADD KEY `GameID` (`GameID`),
  ADD KEY `PlayerID` (`PlayerID`),
  ADD KEY `TeamID` (`TeamID`);

--
-- Indexes for table `PlayerTransferLog`
--
ALTER TABLE `PlayerTransferLog`
  ADD PRIMARY KEY (`LogID`);

--
-- Indexes for table `Schedule`
--
ALTER TABLE `Schedule`
  ADD PRIMARY KEY (`ScheduleID`),
  ADD KEY `GameID` (`GameID`);

--
-- Indexes for table `Team`
--
ALTER TABLE `Team`
  ADD PRIMARY KEY (`TeamID`),
  ADD KEY `CoachID` (`CoachID`);

--
-- Indexes for table `TeamStats`
--
ALTER TABLE `TeamStats`
  ADD PRIMARY KEY (`TeamStatID`),
  ADD KEY `GameID` (`GameID`),
  ADD KEY `TeamID` (`TeamID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `PlayerTransferLog`
--
ALTER TABLE `PlayerTransferLog`
  MODIFY `LogID` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Game`
--
ALTER TABLE `Game`
  ADD CONSTRAINT `game_ibfk_1` FOREIGN KEY (`HomeTeamID`) REFERENCES `Team` (`TeamID`),
  ADD CONSTRAINT `game_ibfk_2` FOREIGN KEY (`AwayTeamID`) REFERENCES `Team` (`TeamID`);

--
-- Constraints for table `Player`
--
ALTER TABLE `Player`
  ADD CONSTRAINT `player_ibfk_1` FOREIGN KEY (`TeamID`) REFERENCES `Team` (`TeamID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
