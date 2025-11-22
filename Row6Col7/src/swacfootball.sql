-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 13, 2025 at 08:59 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `swacfootball`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPlayerTotalTDs` (IN `pPlayerID` INT, OUT `totalTDs` INT)   BEGIN
  SELECT COALESCE(SUM(TDs),0) INTO totalTDs FROM playerstats WHERE PlayerID = pPlayerID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ListUpcomingGames` ()   BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE gid INT;
  DECLARE gdate DATE;
  DECLARE gHome VARCHAR(100);
  DECLARE gAway VARCHAR(100);
  DECLARE cur CURSOR FOR SELECT GameID, Date, HomeTeamID, AwayTeamID FROM game WHERE Date >= CURDATE() ORDER BY Date;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  
  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO gid, gdate, gHome, gAway;
    IF done THEN
      LEAVE read_loop;
    END IF;
    SELECT gid AS GameID, gdate AS Date, gHome AS HomeTeam, gAway AS AwayTeam;
  END LOOP;
  CLOSE cur;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PlayersWithHighTDs` (IN `minTDs` INT)   BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE pid INT;
  DECLARE pname VARCHAR(100);
  DECLARE cur CURSOR FOR 
    SELECT PlayerID, Name FROM player WHERE PlayerID IN 
      (SELECT PlayerID FROM playerstats GROUP BY PlayerID HAVING SUM(TDs) > minTDs);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  
  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO pid, pname;
    IF done THEN
      LEAVE read_loop;
    END IF;
    -- You can do processing or selecting here; example just output player name:
    SELECT pid AS PlayerID, pname AS PlayerName;
  END LOOP;
  CLOSE cur;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateGameScores` ()   BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE g_id INT;
  DECLARE gameDate DATE;
  DECLARE homeScore INT DEFAULT 0;
  DECLARE awayScore INT DEFAULT 0;
  DECLARE res VARCHAR(10);

  DECLARE cur CURSOR FOR SELECT GameID, Date FROM game WHERE Result IS NULL OR Result = '';
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO g_id, gameDate;
    IF done THEN
      LEAVE read_loop;
    END IF;

    IF CURRENT_DATE() >= gameDate THEN
      -- Calculate home score
      SELECT IFNULL(SUM(ps.TDs), 0) INTO homeScore
      FROM playerstats ps JOIN player p ON ps.PlayerID = p.PlayerID
      WHERE ps.GameID = g_id AND p.TeamID = (SELECT HomeTeamID FROM game WHERE GameID = g_id);

      -- Calculate away score
      SELECT IFNULL(SUM(ps.TDs), 0) INTO awayScore
      FROM playerstats ps JOIN player p ON ps.PlayerID = p.PlayerID
      WHERE ps.GameID = g_id AND p.TeamID = (SELECT AwayTeamID FROM game WHERE GameID = g_id);

      -- Determine result
      IF homeScore > awayScore THEN
        SET res = 'HomeWin';
      ELSEIF awayScore > homeScore THEN
        SET res = 'AwayWin';
      ELSE
        SET res = 'Draw';
      END IF;

      UPDATE game SET HomeScore = homeScore, AwayScore = awayScore, Result = res WHERE GameID = g_id;

    ELSE
      -- Future scheduled game
      UPDATE game SET HomeScore = NULL, AwayScore = NULL, Result = 'Scheduled' WHERE GameID = g_id;
    END IF;
  END LOOP;

  CLOSE cur;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateTeamRecord` (IN `pTeamID` INT)   BEGIN
  DECLARE winCount INT;
  DECLARE lossCount INT;
  
  SELECT COUNT(*) INTO winCount FROM game WHERE Result = 'HomeWin' AND HomeTeamID = pTeamID;
  SELECT COUNT(*) INTO lossCount FROM game WHERE Result = 'AwayWin' AND AwayTeamID = pTeamID;
  
  UPDATE team SET Wins = winCount, Losses = lossCount WHERE TeamID = pTeamID;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `AvgTackles` (`pPlayerID` INT) RETURNS DECIMAL(5,2)  BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE tac INT DEFAULT 0;
  DECLARE countGames INT DEFAULT 0;
  DECLARE cur CURSOR FOR SELECT Tackles FROM playerstats WHERE PlayerID = pPlayerID;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO tac;
    IF done THEN
      LEAVE read_loop;
    END IF;
    SET countGames = countGames + 1;
    SET tac = tac + tac; -- accumulate total
  END LOOP;
  CLOSE cur;

  IF countGames > 0 THEN
    RETURN tac/countGames;
  ELSE
    RETURN 0;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CalcPlayerEfficiency` (`pPlayerID` INT) RETURNS DECIMAL(5,2)  BEGIN
  DECLARE eff DECIMAL(5,2);
  
  SELECT IFNULL(AVG((PassingYards + RushingYards + ReceivingYards) / NULLIF(GamesPlayed,0)),0)
  INTO eff
  FROM playerstats
  WHERE PlayerID = pPlayerID;
  
  RETURN eff;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `coach`
--

CREATE TABLE `coach` (
  `CoachID` int(11) NOT NULL,
  `Name` varchar(100) DEFAULT NULL,
  `Role` varchar(50) DEFAULT NULL,
  `TeamID` int(11) DEFAULT NULL,
  `StartDate` date DEFAULT NULL,
  `RecordWins` int(11) DEFAULT NULL,
  `RecordLosses` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `coach`
--

INSERT INTO `coach` (`CoachID`, `Name`, `Role`, `TeamID`, `StartDate`, `RecordWins`, `RecordLosses`) VALUES
(1, 'Alvin Wyatt', 'Head Coach', 1, '2022-01-01', 20, 10),
(2, 'Eddie Robinson Jr.', 'Head Coach', 2, '2021-05-10', 15, 9),
(3, 'Fred McNair', 'Head Coach', 3, '2016-06-20', 50, 25),
(4, 'Solomon Bozeman', 'Head Coach', 4, '2023-03-15', 10, 5),
(5, 'Larry Little', 'Head Coach', 5, '2022-07-08', 12, 11),
(6, 'Billy Joe', 'Head Coach', 6, '2020-02-11', 68, 45),
(7, 'Dennis Winston', 'Head Coach', 7, '2024-01-01', 5, 2),
(8, 'Deion Sanders', 'Head Coach', 8, '2020-09-30', 30, 10),
(9, 'Vincent Dancy', 'Head Coach', 9, '2017-07-01', 14, 21),
(10, 'Eric Dooley', 'Head Coach', 10, '2021-11-11', 18, 12),
(11, 'Eric Dooley', 'Head Coach', 11, '2022-01-01', 25, 18),
(12, 'Clarence McKinney', 'Head Coach', 12, '2019-08-05', 22, 19),
(13, 'Alvin Wyatt', 'Offensive Coordinator', 1, '2021-02-15', NULL, NULL),
(14, 'John Matthews', 'Defensive Coordinator', 1, '2020-08-01', NULL, NULL),
(15, 'Mark Johnson', 'Assistant Coach', 1, '2022-06-10', NULL, NULL),
(16, 'Eddie Robinson Jr.', 'Offensive Coordinator', 2, '2019-05-20', NULL, NULL),
(17, 'James Brown', 'Defensive Coordinator', 2, '2020-01-15', NULL, NULL),
(18, 'Willie Harris', 'Assistant Coach', 2, '2021-09-30', NULL, NULL),
(19, 'Fred McNair', 'Offensive Coordinator', 3, '2016-06-20', NULL, NULL),
(20, 'Steve Carter', 'Defensive Coordinator', 3, '2017-03-14', NULL, NULL),
(21, 'Darryl Smith', 'Assistant Coach', 3, '2019-11-05', NULL, NULL),
(22, 'Solomon Bozeman', 'Offensive Coordinator', 4, '2023-03-15', NULL, NULL),
(23, 'Michael Thomas', 'Defensive Coordinator', 4, '2022-07-20', NULL, NULL),
(24, 'Terry Wilson', 'Assistant Coach', 4, '2023-01-10', NULL, NULL),
(25, 'Larry Little', 'Offensive Coordinator', 5, '2022-07-08', NULL, NULL),
(26, 'Ronald Davis', 'Defensive Coordinator', 5, '2021-04-17', NULL, NULL),
(27, 'Eddie Johnson', 'Assistant Coach', 5, '2022-10-01', NULL, NULL),
(28, 'Billy Joe', 'Offensive Coordinator', 6, '2020-02-11', NULL, NULL),
(29, 'Anthony Thomas', 'Defensive Coordinator', 6, '2019-08-05', NULL, NULL),
(30, 'George Harris', 'Assistant Coach', 6, '2020-12-15', NULL, NULL),
(31, 'Dennis Winston', 'Offensive Coordinator', 7, '2024-01-01', NULL, NULL),
(32, 'Kevin Martin', 'Defensive Coordinator', 7, '2023-06-15', NULL, NULL),
(33, 'Leroy Brown', 'Assistant Coach', 7, '2023-11-20', NULL, NULL),
(34, 'Deion Sanders', 'Offensive Coordinator', 8, '2020-09-30', NULL, NULL),
(35, 'Jason Turner', 'Defensive Coordinator', 8, '2021-10-15', NULL, NULL),
(36, 'Tyrone Davis', 'Assistant Coach', 8, '2022-05-22', NULL, NULL),
(37, 'Vincent Dancy', 'Offensive Coordinator', 9, '2017-07-01', NULL, NULL),
(38, 'Samuel Lewis', 'Defensive Coordinator', 9, '2018-03-27', NULL, NULL),
(39, 'Billy Williams', 'Assistant Coach', 9, '2019-09-18', NULL, NULL),
(40, 'Eric Dooley', 'Offensive Coordinator', 10, '2021-11-11', NULL, NULL),
(41, 'Mark Robinson', 'Defensive Coordinator', 10, '2020-10-10', NULL, NULL),
(42, 'Ron Smith', 'Assistant Coach', 10, '2021-05-28', NULL, NULL),
(43, 'Eric Dooley', 'Offensive Coordinator', 11, '2022-01-01', NULL, NULL),
(44, 'Larry Green', 'Defensive Coordinator', 11, '2021-08-07', NULL, NULL),
(45, 'Alfred Brown', 'Assistant Coach', 11, '2022-03-19', NULL, NULL),
(46, 'Clarence McKinney', 'Offensive Coordinator', 12, '2019-08-05', NULL, NULL),
(47, 'Donald Johnson', 'Defensive Coordinator', 12, '2020-04-24', NULL, NULL),
(48, 'Keith Williams', 'Assistant Coach', 12, '2020-11-13', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `game`
--

CREATE TABLE `game` (
  `GameID` int(11) NOT NULL,
  `Date` date NOT NULL,
  `HomeTeamID` int(11) DEFAULT NULL,
  `AwayTeamID` int(11) DEFAULT NULL,
  `Stadium` varchar(100) DEFAULT NULL,
  `Attendance` int(11) DEFAULT NULL,
  `SeasonYear` int(11) DEFAULT NULL,
  `HomeScore` int(11) DEFAULT NULL,
  `AwayScore` int(11) DEFAULT NULL,
  `Result` varchar(10) DEFAULT NULL
) ;

--
-- Dumping data for table `game`
--

INSERT INTO `game` (`GameID`, `Date`, `HomeTeamID`, `AwayTeamID`, `Stadium`, `Attendance`, `SeasonYear`, `HomeScore`, `AwayScore`, `Result`) VALUES
(101, '2025-08-30', 9, 11, 'Rice–Totten Stadium', 15000, 2025, 12, 18, 'AwayWin'),
(102, '2025-08-30', 5, 7, 'Eddie Robinson Stadium', 13000, 2025, 11, 12, 'AwayWin'),
(103, '2025-09-06', 2, 11, 'Hornet Stadium', 20000, 2025, 10, 13, 'AwayWin'),
(104, '2025-09-13', 9, 4, 'Jack Spinks Stadium', 17000, 2025, 9, 21, 'AwayWin'),
(106, '2025-09-20', 4, 8, 'C.A. Freeman Stadium', 16000, 2025, 19, 14, 'HomeWin'),
(107, '2025-09-27', 6, 10, 'Bragg Memorial Stadium', 14000, 2025, 21, 17, 'HomeWin'),
(108, '2025-10-04', 7, 9, 'Eddie Robinson Stadium', 18000, 2025, 16, 10, 'HomeWin'),
(109, '2025-10-11', 5, 2, 'HMS Ballpark', 15000, 2025, 19, 15, 'HomeWin'),
(110, '2025-10-18', 8, 6, 'Louis Crews Stadium', 19000, 2025, 13, 13, 'Draw'),
(111, '2025-10-25', 9, 5, 'Rice–Totten Stadium', 15500, 2025, 18, 20, 'AwayWin'),
(112, '2025-11-01', 2, 7, 'Hornet Stadium', 16000, 2025, 13, 22, 'AwayWin'),
(113, '2025-11-08', 5, 9, 'Eddie Robinson Stadium', 14000, 2025, 20, 10, 'HomeWin'),
(114, '2025-11-15', 8, 6, 'Louis Crews Stadium', 19000, 2025, 19, 14, 'HomeWin'),
(115, '2025-11-22', 4, 10, 'Jack Spinks Stadium', 0, 2025, 11, 15, 'AwayWin'),
(116, '2025-11-29', 3, 1, 'Alumni Stadium', 0, 2025, 0, 0, 'Draw'),
(117, '2025-12-06', 10, 8, 'Shell Energy Stadium', 0, 2025, 11, 17, 'AwayWin'),
(120, '2025-08-23', 6, 1, 'Jackson State Stadium', 18000, 2025, 17, 20, 'AwayWin'),
(121, '2025-08-30', 3, 7, 'Prairie View A&M Stadium', 16000, 2025, 16, 13, 'HomeWin'),
(122, '2025-09-06', 10, 5, 'Alabama State Stadium', 14000, 2025, 15, 11, 'HomeWin'),
(123, '2025-09-13', 2, 9, 'Southern University Stadium', 17000, 2025, 22, 11, 'HomeWin'),
(124, '2025-09-20', 8, 4, 'Alcorn State Stadium', 13500, 2025, 13, 16, 'AwayWin'),
(200, '2025-01-15', 1, 2, 'Alumni Stadium', 8000, 2025, 16, 14, 'HomeWin'),
(201, '2025-03-10', 3, 4, 'Rice–Totten Stadium', 9000, 2025, 15, 17, 'AwayWin'),
(202, '2025-05-20', 5, 6, 'Eddie Robinson Stadium', 7500, 2025, 21, 14, 'HomeWin'),
(203, '2025-07-05', 7, 8, 'Hornet Stadium', 7100, 2025, 15, 14, 'HomeWin'),
(204, '2025-08-18', 9, 10, 'C.A. Freeman Stadium', 8500, 2025, 19, 15, 'HomeWin'),
(301, '2025-05-05', 12, 1, 'Old Stadium', 15000, 2025, 16, 0, 'HomeWin'),
(302, '2025-05-12', 3, 12, 'Historic Field', 12000, 2025, 0, 16, 'AwayWin'),
(303, '2025-04-29', 12, 9, 'Classic Arena', 10000, 2025, 25, 0, 'HomeWin'),
(2011, '2025-12-08', 5, 12, 'Future Field', 0, 2025, 0, 0, 'Draw'),
(2012, '2025-12-15', 12, 7, 'Modern Arena', 0, 2025, 0, 0, 'Draw'),
(2013, '2025-12-22', 9, 12, 'Grand Grounds', 0, 2025, 0, 0, 'Draw'),
(3001, '2025-05-05', 12, 4, 'Old Stadium', 15000, 2025, 0, 0, 'Draw'),
(3002, '2025-05-12', 5, 12, 'Historic Field', 12000, 2025, 0, 0, 'Draw'),
(3003, '2025-04-29', 12, 7, 'Classic Arena', 10000, 2025, 0, 0, 'Draw');

--
-- Triggers `game`
--
DELIMITER $$
CREATE TRIGGER `after_game_update` AFTER UPDATE ON `game` FOR EACH ROW BEGIN
  IF NEW.Result = 'HomeWin' THEN
     UPDATE team SET Wins = Wins + 1 WHERE TeamID = NEW.HomeTeamID;
  ELSEIF NEW.Result = 'AwayWin' THEN
     UPDATE team SET Wins = Wins + 1 WHERE TeamID = NEW.AwayTeamID;
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_game_insert` BEFORE INSERT ON `game` FOR EACH ROW BEGIN
   IF NEW.Date < CURDATE() THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Game date cannot be in the past';
   END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `player`
--

CREATE TABLE `player` (
  `PlayerID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `TeamID` int(11) DEFAULT NULL,
  `Position` varchar(50) DEFAULT NULL,
  `JerseyNumber` int(11) DEFAULT NULL CHECK (`JerseyNumber` between 0 and 99),
  `Year` varchar(10) DEFAULT NULL,
  `Height` decimal(5,2) DEFAULT NULL,
  `Weight` decimal(5,2) DEFAULT NULL,
  `Birthdate` date DEFAULT NULL,
  `Hometown` varchar(100) DEFAULT NULL,
  `HighSchool` varchar(100) DEFAULT NULL
) ;

--
-- Dumping data for table `player`
--

INSERT INTO `player` (`PlayerID`, `Name`, `TeamID`, `Position`, `JerseyNumber`, `Year`, `Height`, `Weight`, `Birthdate`, `Hometown`, `HighSchool`) VALUES
(1, 'John Smith', 1, 'QB', 10, 'Sr', 6.03, 215.00, '2002-03-04', 'Normal, AL', 'Normal HS'),
(2, 'James Brown', 1, 'RB', 22, 'Jr', 5.11, 185.00, '2003-11-16', 'Normal, AL', 'Normal HS'),
(3, 'Eric Turner', 1, 'WR', 15, 'So', 6.01, 180.00, '2004-02-10', 'Normal, AL', 'Lincoln HS'),
(4, 'Mike Allen', 1, 'LB', 45, 'Jr', 6.02, 220.00, '2003-07-22', 'Huntsville, AL', 'Huntsville HS'),
(5, 'Derek Johnson', 1, 'DB', 28, 'Sr', 5.10, 190.00, '2002-06-18', 'Birmingham, AL', 'Birmingham HS'),
(6, 'David Wilson', 2, 'LB', 5, 'Sr', 6.01, 230.00, '2002-09-20', 'Montgomery, AL', 'Montgomery HS'),
(7, 'Michael Carter', 2, 'WR', 88, 'So', 6.00, 190.00, '2004-02-14', 'Montgomery, AL', 'Central HS'),
(8, 'James Wright', 2, 'QB', 12, 'Jr', 6.03, 215.00, '2003-04-06', 'Selma, AL', 'Selma HS'),
(9, 'Robert Green', 2, 'DB', 21, 'Jr', 5.11, 185.00, '2003-09-02', 'Montgomery, AL', 'Capitol HS'),
(10, 'Steven Davis', 2, 'RB', 22, 'Fr', 5.10, 180.00, '2005-01-20', 'Montgomery, AL', 'Montgomery HS'),
(11, 'Chris Lee', 3, 'QB', 12, 'Jr', 6.05, 220.00, '2002-11-01', 'Lorman, MS', 'Lorman HS'),
(12, 'Tyrone Hill', 3, 'WR', 85, 'Sr', 5.10, 190.00, '2001-04-22', 'Lorman, MS', 'Lorman HS'),
(13, 'Derrick White', 3, 'LB', 44, 'So', 6.02, 225.00, '2004-03-10', 'Lorman, MS', 'Lorman HS'),
(14, 'Marcus Young', 3, 'DB', 28, 'Sr', 5.11, 185.00, '2001-09-17', 'Lorman, MS', 'Lorman HS'),
(15, 'Larry Johnson', 3, 'RB', 22, 'Jr', 5.11, 195.00, '2003-08-05', 'Lorman, MS', 'Lorman HS'),
(21, 'David Wilson', 2, 'QB', 12, 'Sr', 6.03, 215.00, '2002-03-21', 'Montgomery, AL', 'Montgomery HS'),
(22, 'Michael Carter', 2, 'RB', 22, 'Jr', 5.11, 190.00, '2003-10-12', 'Montgomery, AL', 'Central HS'),
(23, 'James Wright', 2, 'WR', 84, 'So', 6.00, 185.00, '2004-01-25', 'Selma, AL', 'Selma HS'),
(24, 'Robert Green', 2, 'TE', 81, 'Sr', 6.04, 230.00, '2002-09-19', 'Montgomery, AL', 'Capitol HS'),
(25, 'Steven Davis', 2, 'C', 59, 'Jr', 6.02, 300.00, '2003-05-16', 'Montgomery, AL', 'Montgomery HS'),
(26, 'John Phillips', 2, 'OT', 75, 'Sr', 6.07, 315.00, '2001-12-01', 'Montgomery, AL', 'Eastside HS'),
(27, 'Kevin Jones', 2, 'OG', 66, 'Jr', 6.03, 310.00, '2003-04-22', 'Montgomery, AL', 'Eastside HS'),
(28, 'Larry Adams', 2, 'OG', 68, 'Sr', 6.01, 305.00, '2002-08-09', 'Montgomery, AL', 'Central HS'),
(29, 'Gary Brown', 2, 'OT', 78, 'Jr', 6.06, 315.00, '2003-03-04', 'Montgomery, AL', 'Eastside HS'),
(30, 'Derrick White', 2, 'DE', 92, 'Sr', 6.04, 275.00, '2002-01-17', 'Montgomery, AL', 'Eastside HS'),
(31, 'Benjamin Carter', 2, 'DT', 98, 'Jr', 6.02, 295.00, '2003-07-28', 'Montgomery, AL', 'Central HS'),
(32, 'Robert Lee', 2, 'LB', 55, 'Sr', 6.01, 235.00, '2001-12-15', 'Montgomery, AL', 'Montgomery HS'),
(33, 'Anthony Green', 2, 'LB', 52, 'Jr', 6.00, 230.00, '2003-05-02', 'Selma, AL', 'Selma HS'),
(34, 'Kevin Thomas', 2, 'CB', 24, 'Sr', 5.11, 190.00, '2002-09-04', 'Montgomery, AL', 'Central HS'),
(35, 'Michael Johnson', 2, 'SS', 31, 'Jr', 6.00, 195.00, '2003-02-10', 'Montgomery, AL', 'Eastside HS'),
(36, 'Steven Wright', 2, 'FS', 27, 'Sr', 6.01, 200.00, '2002-06-20', 'Montgomery, AL', 'Eastside HS'),
(37, 'Timothy Barnes', 2, 'K', 3, 'So', 5.11, 180.00, '2004-01-15', 'Montgomery, AL', 'Central HS'),
(38, 'Jason Clark', 2, 'P', 9, 'Jr', 6.00, 185.00, '2003-07-10', 'Selma, AL', 'Central HS'),
(39, 'Eric Davis', 2, 'WR', 85, 'Sr', 6.00, 190.00, '2001-11-06', 'Montgomery, AL', 'Eastside HS'),
(40, 'Larry Wilson', 2, 'RB', 23, 'Jr', 5.10, 185.00, '2003-03-29', 'Montgomery, AL', 'Montgomery HS'),
(41, 'Mark Davis', 1, 'TE', 83, 'Jr', 6.04, 230.00, '2003-08-01', 'Decatur, AL', 'Decatur HS'),
(42, 'Kevin Wilson', 1, 'C', 59, 'Sr', 6.02, 290.00, '2001-12-14', 'Montgomery, AL', 'Montgomery HS'),
(43, 'Larry Jackson', 1, 'OT', 74, 'Jr', 6.06, 300.00, '2002-10-25', 'Mobile, AL', 'Mobile HS'),
(44, 'Brian Lee', 1, 'OG', 66, 'Sr', 6.01, 310.00, '2001-11-19', 'Tuscaloosa, AL', 'Tuscaloosa HS'),
(45, 'Tim Brown', 1, 'OG', 67, 'Jr', 6.00, 305.00, '2003-05-09', 'Florence, AL', 'Florence HS'),
(46, 'Gary Thomas', 1, 'OT', 72, 'Sr', 6.07, 315.00, '2001-07-30', 'Montgomery, AL', 'Montgomery HS'),
(47, 'Willie Green', 1, 'DE', 91, 'Jr', 6.03, 270.00, '2003-04-11', 'Birmingham, AL', 'Birmingham HS'),
(48, 'Chris Johnson', 1, 'DT', 95, 'Sr', 6.02, 295.00, '2002-01-27', 'Huntsville, AL', 'Huntsville HS'),
(49, 'Steven White', 1, 'LB', 54, 'Jr', 6.00, 230.00, '2003-08-21', 'Mobile, AL', 'Mobile HS'),
(50, 'Donald Evans', 1, 'LB', 56, 'Sr', 6.01, 235.00, '2002-12-02', 'Tuscaloosa, AL', 'Tuscaloosa HS'),
(51, 'Anthony Clark', 1, 'CB', 24, 'Sr', 5.11, 190.00, '2002-02-18', 'Decatur, AL', 'Decatur HS'),
(52, 'Jason Wright', 1, 'SS', 31, 'Jr', 6.00, 195.00, '2003-06-05', 'Florence, AL', 'Florence HS'),
(53, 'Robert Lewis', 1, 'FS', 27, 'Sr', 6.01, 200.00, '2002-08-12', 'Huntsville, AL', 'Huntsville HS'),
(54, 'Matthew Hall', 1, 'K', 3, 'So', 5.11, 180.00, '2004-03-29', 'Birmingham, AL', 'Birmingham HS'),
(55, 'Jason Black', 1, 'P', 9, 'Jr', 6.00, 185.00, '2003-07-15', 'Mobile, AL', 'Mobile HS'),
(56, 'Chris Lee', 3, 'QB', 12, 'Jr', 6.05, 220.00, '2002-11-01', 'Lorman, MS', 'Lorman HS'),
(58, 'Derrick White', 3, 'LB', 44, 'So', 6.02, 225.00, '2004-03-10', 'Lorman, MS', 'Lorman HS'),
(59, 'Marcus Young', 3, 'DB', 28, 'Sr', 5.11, 185.00, '2001-09-17', 'Lorman, MS', 'Lorman HS'),
(60, 'Larry Johnson', 3, 'RB', 22, 'Jr', 5.11, 195.00, '2003-08-05', 'Lorman, MS', 'Lorman HS'),
(61, 'James Smith', 3, 'TE', 87, 'Sr', 6.03, 225.00, '2002-05-21', 'Lorman, MS', 'Lorman HS'),
(62, 'Robert Dow', 3, 'C', 60, 'Sr', 6.01, 300.00, '2001-10-18', 'Lorman, MS', 'Lorman HS'),
(63, 'Brian Collins', 3, 'OT', 77, 'Jr', 6.06, 310.00, '2002-12-02', 'Lorman, MS', 'Lorman HS'),
(64, 'Mike Adams', 3, 'OG', 76, 'Jr', 6.03, 305.00, '2003-03-15', 'Lorman, MS', 'Lorman HS'),
(65, 'Kevin Brown', 3, 'OG', 65, 'Sr', 6.02, 310.00, '2001-07-29', 'Lorman, MS', 'Lorman HS'),
(66, 'Steven Parker', 3, 'OT', 79, 'Sr', 6.07, 315.00, '2002-09-14', 'Lorman, MS', 'Lorman HS'),
(67, 'Timothy Rogers', 3, 'DE', 93, 'Jr', 6.03, 280.00, '2003-01-23', 'Lorman, MS', 'Lorman HS'),
(68, 'Jonathan Harris', 3, 'DT', 97, 'Sr', 6.05, 300.00, '2001-11-07', 'Lorman, MS', 'Lorman HS'),
(69, 'Damon Wright', 3, 'LB', 53, 'Sr', 6.02, 235.00, '2002-06-27', 'Lorman, MS', 'Lorman HS'),
(70, 'Scott Johnson', 3, 'LB', 54, 'Jr', 6.01, 230.00, '2003-08-11', 'Lorman, MS', 'Lorman HS'),
(71, 'Andre Miller', 3, 'CB', 25, 'Sr', 5.11, 190.00, '2002-04-22', 'Lorman, MS', 'Lorman HS'),
(72, 'Nick Walker', 3, 'SS', 31, 'Jr', 6.00, 195.00, '2003-05-10', 'Lorman, MS', 'Lorman HS'),
(73, 'Joel Baker', 3, 'FS', 29, 'Sr', 6.01, 200.00, '2001-12-11', 'Lorman, MS', 'Lorman HS'),
(74, 'Eric Thompson', 3, 'K', 4, 'So', 5.11, 180.00, '2004-03-22', 'Lorman, MS', 'Lorman HS'),
(75, 'Derek Wilson', 3, 'P', 6, 'Jr', 6.00, 185.00, '2003-06-17', 'Lorman, MS', 'Lorman HS'),
(76, 'Jason Ray', 4, 'LB', 6, 'Sr', 6.02, 225.00, '2002-07-15', 'Pine Bluff, AR', 'Pine Bluff HS'),
(77, 'Marcus Brown', 4, 'DB', 24, 'Jr', 5.11, 185.00, '2003-08-10', 'Pine Bluff, AR', 'Pine Bluff HS'),
(78, 'Anthony Smith', 4, 'QB', 14, 'Sr', 6.03, 215.00, '2001-10-05', 'Pine Bluff, AR', 'Pine Bluff HS'),
(79, 'Jerome Jackson', 4, 'RB', 22, 'Jr', 5.11, 190.00, '2003-04-17', 'Pine Bluff, AR', 'Pine Bluff HS'),
(80, 'Keith Wilson', 4, 'WR', 85, 'So', 6.00, 180.00, '2004-06-22', 'Pine Bluff, AR', 'Pine Bluff HS'),
(81, 'Michael Davis', 4, 'TE', 82, 'Sr', 6.04, 230.00, '2002-05-18', 'Pine Bluff, AR', 'Pine Bluff HS'),
(82, 'Andrew Harris', 4, 'OL', 70, 'Jr', 6.05, 300.00, '2003-03-12', 'Pine Bluff, AR', 'Pine Bluff HS'),
(83, 'Brandon Lee', 4, 'OL', 62, 'Sr', 6.02, 310.00, '2002-09-30', 'Pine Bluff, AR', 'Pine Bluff HS'),
(84, 'Chris Allen', 4, 'OL', 65, 'Jr', 6.03, 305.00, '2003-02-25', 'Pine Bluff, AR', 'Pine Bluff HS'),
(85, 'Derrick Thompson', 4, 'DE', 93, 'Sr', 6.03, 280.00, '2001-12-01', 'Pine Bluff, AR', 'Pine Bluff HS'),
(86, 'Eric Johnson', 4, 'DT', 95, 'Jr', 6.01, 295.00, '2003-06-07', 'Pine Bluff, AR', 'Pine Bluff HS'),
(87, 'Larry Scott', 4, 'LB', 55, 'Sr', 6.00, 230.00, '2002-11-20', 'Pine Bluff, AR', 'Pine Bluff HS'),
(88, 'Mark White', 4, 'CB', 25, 'Jr', 5.11, 190.00, '2003-05-15', 'Pine Bluff, AR', 'Pine Bluff HS'),
(89, 'Nathan Green', 4, 'SS', 31, 'Sr', 6.00, 195.00, '2001-07-10', 'Pine Bluff, AR', 'Pine Bluff HS'),
(90, 'Timothy Brown', 4, 'FS', 29, 'Jr', 6.01, 200.00, '2003-04-18', 'Pine Bluff, AR', 'Pine Bluff HS'),
(91, 'James Miller', 4, 'K', 3, 'So', 5.10, 180.00, '2004-03-22', 'Pine Bluff, AR', 'Pine Bluff HS'),
(92, 'Victor Anderson', 4, 'P', 8, 'Jr', 6.00, 185.00, '2003-01-10', 'Pine Bluff, AR', 'Pine Bluff HS'),
(93, 'Kevin Harris', 4, 'WR', 80, 'Sr', 6.00, 190.00, '2002-10-20', 'Pine Bluff, AR', 'Pine Bluff HS'),
(94, 'Patrick Lewis', 4, 'RB', 28, 'Jr', 5.11, 185.00, '2003-08-01', 'Pine Bluff, AR', 'Pine Bluff HS'),
(95, 'Douglas King', 4, 'QB', 11, 'So', 6.03, 215.00, '2004-02-14', 'Pine Bluff, AR', 'Pine Bluff HS'),
(96, 'Andre Johnson', 5, 'QB', 14, 'So', 6.04, 210.00, '2003-09-05', 'Daytona Beach, FL', 'Daytona HS'),
(97, 'Derek White', 5, 'RB', 33, 'Jr', 5.10, 195.00, '2002-01-12', 'Daytona Beach, FL', 'Daytona HS'),
(98, 'Marcus Thomas', 5, 'WR', 80, 'Sr', 6.02, 190.00, '2001-10-18', 'Daytona Beach, FL', 'Daytona HS'),
(99, 'James Harris', 5, 'TE', 88, 'Jr', 6.03, 230.00, '2003-05-10', 'Daytona Beach, FL', 'Daytona HS'),
(100, 'Timothy Brown', 5, 'C', 61, 'Sr', 6.01, 300.00, '2002-07-19', 'Daytona Beach, FL', 'Daytona HS'),
(101, 'William Clark', 5, 'OT', 77, 'Jr', 6.07, 310.00, '2003-02-15', 'Daytona Beach, FL', 'Daytona HS'),
(102, 'Stephen White', 5, 'OG', 66, 'Sr', 6.03, 305.00, '2002-08-05', 'Daytona Beach, FL', 'Daytona HS'),
(103, 'Brian Lee', 5, 'OG', 69, 'Jr', 6.02, 310.00, '2003-06-23', 'Daytona Beach, FL', 'Daytona HS'),
(104, 'Charles Green', 5, 'OT', 79, 'Sr', 6.06, 315.00, '2002-04-28', 'Daytona Beach, FL', 'Daytona HS'),
(105, 'Eric Harris', 5, 'DE', 92, 'Jr', 6.03, 280.00, '2003-09-04', 'Daytona Beach, FL', 'Daytona HS'),
(106, 'Derek Williams', 5, 'DT', 95, 'Sr', 6.04, 295.00, '2001-11-17', 'Daytona Beach, FL', 'Daytona HS'),
(107, 'Anthony Johnson', 5, 'LB', 55, 'Sr', 6.01, 235.00, '2002-02-18', 'Daytona Beach, FL', 'Daytona HS'),
(108, 'Michael Brown', 5, 'LB', 54, 'Jr', 6.00, 230.00, '2003-08-28', 'Daytona Beach, FL', 'Daytona HS'),
(109, 'Kevin White', 5, 'CB', 24, 'Sr', 5.11, 190.00, '2002-10-21', 'Daytona Beach, FL', 'Daytona HS'),
(110, 'Jason Wilson', 5, 'SS', 31, 'Jr', 6.00, 195.00, '2003-07-06', 'Daytona Beach, FL', 'Daytona HS'),
(111, 'Robert Clark', 5, 'FS', 29, 'Sr', 6.01, 200.00, '2002-01-15', 'Daytona Beach, FL', 'Daytona HS'),
(112, 'Matthew Walker', 5, 'K', 3, 'So', 5.11, 180.00, '2004-03-13', 'Daytona Beach, FL', 'Daytona HS'),
(113, 'Steven Lewis', 5, 'P', 8, 'Jr', 6.00, 185.00, '2003-05-29', 'Daytona Beach, FL', 'Daytona HS'),
(114, 'Eric Wilson', 5, 'WR', 81, 'Sr', 6.02, 190.00, '2001-12-24', 'Daytona Beach, FL', 'Daytona HS'),
(115, 'Justin Brown', 5, 'RB', 23, 'Jr', 5.10, 185.00, '2003-06-10', 'Daytona Beach, FL', 'Daytona HS'),
(116, 'Marquis Green', 6, 'WR', 11, 'Sr', 6.01, 195.00, '2001-12-07', 'Tallahassee, FL', 'Tallahassee HS'),
(117, 'Elijah Thomas', 6, 'DB', 21, 'So', 5.11, 185.00, '2003-06-29', 'Tallahassee, FL', 'Tallahassee HS'),
(118, 'Tyler Johnson', 6, 'QB', 14, 'Sr', 6.04, 215.00, '2001-07-19', 'Tallahassee, FL', 'Tallahassee HS'),
(119, 'Jordan Williams', 6, 'RB', 29, 'Jr', 5.10, 190.00, '2003-03-23', 'Tallahassee, FL', 'Tallahassee HS'),
(120, 'Isaiah Brown', 6, 'WR', 82, 'So', 6.01, 185.00, '2004-04-21', 'Tallahassee, FL', 'Tallahassee HS'),
(121, 'David Green', 6, 'TE', 88, 'Sr', 6.03, 230.00, '2001-11-11', 'Tallahassee, FL', 'Tallahassee HS'),
(122, 'Marcus Johnson', 6, 'C', 58, 'Jr', 6.02, 295.00, '2003-02-15', 'Tallahassee, FL', 'Tallahassee HS'),
(123, 'Robert Brown', 6, 'OT', 76, 'Sr', 6.07, 315.00, '2002-10-09', 'Tallahassee, FL', 'Tallahassee HS'),
(124, 'Kevin Wilson', 6, 'OG', 65, 'Jr', 6.03, 310.00, '2003-03-29', 'Tallahassee, FL', 'Tallahassee HS'),
(125, 'Steven Clark', 6, 'OG', 67, 'Sr', 6.01, 300.00, '2002-08-17', 'Tallahassee, FL', 'Tallahassee HS'),
(126, 'Charles Lewis', 6, 'OT', 75, 'Jr', 6.06, 310.00, '2003-01-26', 'Tallahassee, FL', 'Tallahassee HS'),
(127, 'Jason Allen', 6, 'DE', 94, 'Sr', 6.02, 275.00, '2002-11-04', 'Tallahassee, FL', 'Tallahassee HS'),
(128, 'Eric Turner', 6, 'DT', 96, 'Jr', 6.03, 290.00, '2003-07-19', 'Tallahassee, FL', 'Tallahassee HS'),
(129, 'Raymond White', 6, 'LB', 55, 'Sr', 6.01, 230.00, '2002-09-22', 'Tallahassee, FL', 'Tallahassee HS'),
(130, 'Marshall Harris', 6, 'CB', 25, 'Jr', 5.11, 190.00, '2003-03-15', 'Tallahassee, FL', 'Tallahassee HS'),
(131, 'Gregory Scott', 6, 'SS', 31, 'Sr', 6.00, 195.00, '2001-10-17', 'Tallahassee, FL', 'Tallahassee HS'),
(132, 'Timothy Johnson', 6, 'FS', 28, 'Jr', 6.01, 200.00, '2003-04-08', 'Tallahassee, FL', 'Tallahassee HS'),
(133, 'Albert Jackson', 6, 'K', 3, 'So', 5.11, 180.00, '2004-06-30', 'Tallahassee, FL', 'Tallahassee HS'),
(134, 'Samuel Brown', 6, 'P', 7, 'Jr', 6.00, 185.00, '2003-09-04', 'Tallahassee, FL', 'Tallahassee HS'),
(135, 'Darren Wilson', 6, 'WR', 81, 'Sr', 6.02, 190.00, '2002-01-14', 'Tallahassee, FL', 'Tallahassee HS'),
(136, 'Kelvin Davis', 7, 'QB', 7, 'Jr', 6.02, 205.00, '2002-03-01', 'Grambling, LA', 'Grambling HS'),
(137, 'Tyrone Smith', 7, 'LB', 45, 'Sr', 6.00, 230.00, '2001-11-20', 'Grambling, LA', 'Grambling HS'),
(138, 'Darnell Johnson', 7, 'RB', 22, 'So', 5.10, 190.00, '2003-04-10', 'Grambling, LA', 'Grambling HS'),
(139, 'Jamal Green', 7, 'WR', 88, 'Sr', 6.01, 185.00, '2002-07-19', 'Grambling, LA', 'Grambling HS'),
(140, 'Kevin Thompson', 7, 'TE', 82, 'Jr', 6.03, 230.00, '2003-06-15', 'Grambling, LA', 'Grambling HS'),
(141, 'Eric White', 7, 'C', 60, 'Sr', 6.01, 300.00, '2001-12-18', 'Grambling, LA', 'Grambling HS'),
(142, 'Anthony Brown', 7, 'OT', 75, 'Jr', 6.07, 310.00, '2003-05-28', 'Grambling, LA', 'Grambling HS'),
(143, 'Marquis Williams', 7, 'OG', 66, 'Sr', 6.03, 305.00, '2002-09-05', 'Grambling, LA', 'Grambling HS'),
(144, 'Brian Davis', 7, 'OG', 69, 'Jr', 6.01, 310.00, '2003-01-21', 'Grambling, LA', 'Grambling HS'),
(145, 'Chris Johnson', 7, 'OT', 79, 'Sr', 6.06, 315.00, '2002-10-15', 'Grambling, LA', 'Grambling HS'),
(146, 'Derek Williams', 7, 'DE', 93, 'Jr', 6.04, 280.00, '2003-02-07', 'Grambling, LA', 'Grambling HS'),
(147, 'Robert Hill', 7, 'DT', 95, 'Sr', 6.05, 295.00, '2001-11-30', 'Grambling, LA', 'Grambling HS'),
(148, 'Timothy Walker', 7, 'LB', 55, 'Sr', 6.02, 235.00, '2002-06-23', 'Grambling, LA', 'Grambling HS'),
(149, 'Gary Scott', 7, 'CB', 24, 'Jr', 5.11, 190.00, '2003-07-12', 'Grambling, LA', 'Grambling HS'),
(150, 'Jason White', 7, 'SS', 31, 'Sr', 6.00, 195.00, '2001-08-27', 'Grambling, LA', 'Grambling HS'),
(151, 'Kevin Lee', 7, 'FS', 29, 'Jr', 6.01, 200.00, '2003-03-14', 'Grambling, LA', 'Grambling HS'),
(152, 'Matthew Green', 7, 'K', 3, 'So', 5.11, 180.00, '2004-06-18', 'Grambling, LA', 'Grambling HS'),
(153, 'Jordan Brown', 7, 'P', 8, 'Jr', 6.00, 185.00, '2003-09-21', 'Grambling, LA', 'Grambling HS'),
(154, 'Larry Williams', 7, 'WR', 81, 'Sr', 6.02, 190.00, '2002-04-11', 'Grambling, LA', 'Grambling HS'),
(155, 'Tyrone Jackson', 7, 'RB', 23, 'Jr', 5.10, 185.00, '2003-06-30', 'Grambling, LA', 'Grambling HS'),
(156, 'Darius Jones', 8, 'QB', 9, 'Sr', 6.03, 220.00, '2001-05-16', 'Jackson, MS', 'Jackson HS'),
(157, 'Taj Williams', 8, 'DB', 28, 'Jr', 5.10, 185.00, '2002-08-24', 'Jackson, MS', 'Jackson HS'),
(158, 'Marcus Lewis', 8, 'RB', 22, 'So', 5.11, 190.00, '2003-06-01', 'Jackson, MS', 'Jackson HS'),
(159, 'Brandon White', 8, 'WR', 88, 'Sr', 6.01, 185.00, '2001-12-15', 'Jackson, MS', 'Jackson HS'),
(160, 'Henry Brown', 8, 'TE', 83, 'Jr', 6.03, 230.00, '2003-02-20', 'Jackson, MS', 'Jackson HS'),
(161, 'James King', 8, 'C', 61, 'Sr', 6.01, 300.00, '2002-11-11', 'Jackson, MS', 'Jackson HS'),
(162, 'Robert Green', 8, 'OT', 74, 'Jr', 6.07, 310.00, '2003-04-18', 'Jackson, MS', 'Jackson HS'),
(163, 'Michael Hall', 8, 'OG', 66, 'Sr', 6.03, 305.00, '2002-09-05', 'Jackson, MS', 'Jackson HS'),
(164, 'William Scott', 8, 'OG', 67, 'Jr', 6.01, 310.00, '2003-01-15', 'Jackson, MS', 'Jackson HS'),
(165, 'David Harris', 8, 'OT', 79, 'Sr', 6.06, 315.00, '2002-07-21', 'Jackson, MS', 'Jackson HS'),
(166, 'Charles Wilson', 8, 'DE', 90, 'Jr', 6.03, 280.00, '2003-04-09', 'Jackson, MS', 'Jackson HS'),
(167, 'Eric Thomas', 8, 'DT', 94, 'Sr', 6.02, 295.00, '2001-11-28', 'Jackson, MS', 'Jackson HS'),
(168, 'Kevin Martin', 8, 'LB', 55, 'Sr', 6.01, 235.00, '2002-06-30', 'Jackson, MS', 'Jackson HS'),
(169, 'Mark Williams', 8, 'CB', 25, 'Jr', 5.11, 190.00, '2003-05-10', 'Jackson, MS', 'Jackson HS'),
(170, 'Jason Lewis', 8, 'SS', 30, 'Sr', 6.00, 195.00, '2001-09-20', 'Jackson, MS', 'Jackson HS'),
(171, 'Timothy White', 8, 'FS', 28, 'Jr', 6.00, 200.00, '2003-01-22', 'Jackson, MS', 'Jackson HS'),
(172, 'Robert Adams', 8, 'K', 3, 'So', 5.11, 180.00, '2004-05-11', 'Jackson, MS', 'Jackson HS'),
(173, 'James Brown', 8, 'P', 8, 'Jr', 6.00, 185.00, '2003-08-05', 'Jackson, MS', 'Jackson HS'),
(174, 'Sean Parker', 8, 'WR', 84, 'Sr', 6.02, 190.00, '2002-01-12', 'Jackson, MS', 'Jackson HS'),
(175, 'Derek Carter', 8, 'RB', 24, 'Jr', 5.10, 180.00, '2003-04-24', 'Jackson, MS', 'Jackson HS'),
(176, 'Brandon Scott', 9, 'WR', 82, 'So', 6.00, 185.00, '2003-07-11', 'Itta Bena, MS', 'Itta Bena HS'),
(177, 'Jamel Harris', 9, 'RB', 20, 'Jr', 5.09, 190.00, '2002-11-29', 'Itta Bena, MS', 'Itta Bena HS'),
(178, 'Derrick Thomas', 9, 'QB', 10, 'Sr', 6.03, 215.00, '2001-10-02', 'Itta Bena, MS', 'Itta Bena HS'),
(179, 'Eric Johnson', 9, 'TE', 85, 'Jr', 6.04, 230.00, '2003-05-20', 'Itta Bena, MS', 'Itta Bena HS'),
(180, 'Marcus Lee', 9, 'C', 60, 'Sr', 6.02, 300.00, '2002-08-11', 'Itta Bena, MS', 'Itta Bena HS'),
(181, 'Brian Walker', 9, 'OT', 75, 'Jr', 6.07, 310.00, '2003-07-01', 'Itta Bena, MS', 'Itta Bena HS'),
(182, 'Kevin Martin', 9, 'OG', 66, 'Sr', 6.01, 305.00, '2002-09-22', 'Itta Bena, MS', 'Itta Bena HS'),
(183, 'James Davis', 9, 'OG', 67, 'Jr', 6.00, 310.00, '2003-06-18', 'Itta Bena, MS', 'Itta Bena HS'),
(184, 'John White', 9, 'OT', 79, 'Sr', 6.06, 315.00, '2002-12-06', 'Itta Bena, MS', 'Itta Bena HS'),
(185, 'Derek Wilson', 9, 'DE', 92, 'Jr', 6.03, 280.00, '2003-02-25', 'Itta Bena, MS', 'Itta Bena HS'),
(186, 'Nathan Scott', 9, 'DT', 95, 'Sr', 6.02, 295.00, '2001-11-18', 'Itta Bena, MS', 'Itta Bena HS'),
(187, 'Anthony Brown', 9, 'LB', 55, 'Sr', 6.01, 235.00, '2002-04-29', 'Itta Bena, MS', 'Itta Bena HS'),
(188, 'William Johnson', 9, 'CB', 25, 'Jr', 5.11, 190.00, '2003-05-10', 'Itta Bena, MS', 'Itta Bena HS'),
(189, 'Charles Lee', 9, 'SS', 31, 'Sr', 6.00, 195.00, '2001-07-16', 'Itta Bena, MS', 'Itta Bena HS'),
(190, 'Timothy Harris', 9, 'FS', 29, 'Jr', 6.01, 200.00, '2003-03-21', 'Itta Bena, MS', 'Itta Bena HS'),
(191, 'Jason Clark', 9, 'K', 3, 'So', 5.11, 180.00, '2004-02-11', 'Itta Bena, MS', 'Itta Bena HS'),
(192, 'Robert Davis', 9, 'P', 6, 'Jr', 6.00, 185.00, '2003-09-05', 'Itta Bena, MS', 'Itta Bena HS'),
(193, 'Larry Brown', 9, 'WR', 81, 'Sr', 6.02, 190.00, '2002-01-15', 'Itta Bena, MS', 'Itta Bena HS'),
(194, 'Michael Thomas', 9, 'RB', 24, 'Jr', 5.10, 185.00, '2003-06-22', 'Itta Bena, MS', 'Itta Bena HS'),
(195, 'Darren White', 9, 'QB', 11, 'So', 6.03, 215.00, '2004-05-30', 'Itta Bena, MS', 'Itta Bena HS'),
(196, 'Jakoby Banks', 10, 'WR', 1, 'Jr', 5.09, 178.00, '2003-05-12', 'Missouri City, TX', 'Fort Bend HS'),
(197, 'Cameron Franklin', 10, 'S', 2, 'Sr', 6.02, 200.00, '2002-07-10', 'Sweeny, TX', 'Van Vleck HS'),
(198, 'Bill Johnson', 10, 'QB', 14, 'Sr', 6.03, 210.00, '2002-01-17', 'Houston, TX', 'Houston HS'),
(199, 'Marcus Green', 10, 'RB', 22, 'Jr', 5.11, 190.00, '2003-03-19', 'Houston, TX', 'Houston HS'),
(200, 'Tyrone White', 10, 'WR', 83, 'Sr', 6.02, 185.00, '2001-09-07', 'Houston, TX', 'Houston HS'),
(201, 'Shawn Lee', 10, 'TE', 80, 'Jr', 6.04, 230.00, '2003-05-23', 'Missouri City, TX', 'Missouri City HS'),
(202, 'Jason Brown', 10, 'C', 59, 'Sr', 6.01, 300.00, '2002-08-14', 'Houston, TX', 'Houston HS'),
(203, 'Eric Davis', 10, 'OT', 77, 'Jr', 6.07, 310.00, '2003-04-18', 'Houston, TX', 'Houston HS'),
(204, 'Victor White', 10, 'OG', 65, 'Sr', 6.01, 305.00, '2001-10-30', 'Houston, TX', 'Houston HS'),
(205, 'Alex Wilson', 10, 'OG', 68, 'Jr', 6.02, 310.00, '2003-07-11', 'Missouri City, TX', 'Missouri City HS'),
(206, 'Steven Lee', 10, 'OT', 74, 'Sr', 6.06, 315.00, '2002-05-02', 'Houston, TX', 'Houston HS'),
(207, 'Brian Thompson', 10, 'DE', 92, 'Jr', 6.03, 280.00, '2003-03-07', 'Houston, TX', 'Houston HS'),
(208, 'Darren Johnson', 10, 'DT', 93, 'Sr', 6.02, 295.00, '2001-11-20', 'Houston, TX', 'Houston HS'),
(209, 'Leonard Smith', 10, 'LB', 54, 'Sr', 6.01, 235.00, '2002-07-25', 'Missouri City, TX', 'Missouri City HS'),
(210, 'Terry Williams', 10, 'CB', 23, 'Jr', 5.11, 190.00, '2003-01-19', 'Houston, TX', 'Houston HS'),
(211, 'Keith Harris', 10, 'SS', 30, 'Sr', 6.00, 195.00, '2002-04-08', 'Missouri City, TX', 'Missouri City HS'),
(212, 'Tony Carter', 10, 'FS', 28, 'Jr', 6.01, 200.00, '2003-07-29', 'Houston, TX', 'Houston HS'),
(213, 'Jimmy Brown', 10, 'K', 3, 'So', 5.11, 180.00, '2004-02-10', 'Houston, TX', 'Houston HS'),
(214, 'Eric Parker', 10, 'P', 5, 'Jr', 6.00, 185.00, '2003-06-16', 'Missouri City, TX', 'Missouri City HS'),
(215, 'Tyrone Jones', 10, 'WR', 81, 'Sr', 6.02, 190.00, '2001-12-22', 'Houston, TX', 'Houston HS'),
(216, 'Marcus Bell', 11, 'QB', 4, 'Jr', 6.04, 215.00, '2002-04-25', 'Baton Rouge, LA', 'Baton Rouge HS'),
(217, 'Terrence Hayes', 11, 'LB', 55, 'Sr', 6.01, 230.00, '2001-09-15', 'Baton Rouge, LA', 'Baton Rouge HS'),
(218, 'Derek Davis', 11, 'RB', 22, 'So', 5.11, 190.00, '2003-12-16', 'Baton Rouge, LA', 'Baton Rouge HS'),
(219, 'Kevin Allen', 11, 'WR', 83, 'Jr', 6.02, 185.00, '2003-07-11', 'Baton Rouge, LA', 'Baton Rouge HS'),
(220, 'Jared Johnson', 11, 'TE', 85, 'Sr', 6.03, 230.00, '2002-02-26', 'Baton Rouge, LA', 'Baton Rouge HS'),
(221, 'Caleb White', 11, 'C', 60, 'Jr', 6.02, 300.00, '2003-06-21', 'Baton Rouge, LA', 'Baton Rouge HS'),
(222, 'Marcus Green', 11, 'OT', 76, 'So', 6.06, 310.00, '2004-01-15', 'Baton Rouge, LA', 'Baton Rouge HS'),
(223, 'Robert Carter', 11, 'OG', 65, 'Sr', 6.00, 305.00, '2002-10-10', 'Baton Rouge, LA', 'Baton Rouge HS'),
(224, 'James Martin', 11, 'OG', 67, 'Jr', 6.01, 310.00, '2003-05-03', 'Baton Rouge, LA', 'Baton Rouge HS'),
(225, 'William Scott', 11, 'OT', 78, 'Sr', 6.04, 315.00, '2001-11-29', 'Baton Rouge, LA', 'Baton Rouge HS'),
(226, 'Jordan Brown', 11, 'DE', 97, 'Jr', 6.03, 280.00, '2003-03-13', 'Baton Rouge, LA', 'Baton Rouge HS'),
(227, 'Dustin Lee', 11, 'DT', 94, 'Sr', 6.02, 295.00, '2002-12-04', 'Baton Rouge, LA', 'Baton Rouge HS'),
(228, 'Nathaniel White', 11, 'LB', 54, 'Jr', 6.01, 230.00, '2003-06-20', 'Baton Rouge, LA', 'Baton Rouge HS'),
(229, 'Steven Harris', 11, 'CB', 24, 'Sr', 5.11, 190.00, '2001-08-17', 'Baton Rouge, LA', 'Baton Rouge HS'),
(230, 'Eric Parker', 11, 'SS', 30, 'Jr', 6.00, 195.00, '2003-04-03', 'Baton Rouge, LA', 'Baton Rouge HS'),
(231, 'Calvin Wilson', 11, 'FS', 27, 'Sr', 6.01, 200.00, '2002-09-08', 'Baton Rouge, LA', 'Baton Rouge HS'),
(232, 'Chad Allen', 11, 'K', 3, 'So', 5.11, 180.00, '2004-07-12', 'Baton Rouge, LA', 'Baton Rouge HS'),
(233, 'Jonathan Mitchell', 11, 'P', 6, 'Jr', 6.00, 185.00, '2003-01-06', 'Baton Rouge, LA', 'Baton Rouge HS'),
(234, 'Darren White', 11, 'WR', 81, 'Sr', 6.02, 190.00, '2001-09-20', 'Baton Rouge, LA', 'Baton Rouge HS'),
(235, 'Brandon Thomas', 11, 'RB', 20, 'Jr', 5.10, 185.00, '2003-06-25', 'Baton Rouge, LA', 'Baton Rouge HS'),
(236, 'Isaiah Johnson', 12, 'QB', 14, 'Sr', 6.03, 210.00, '2001-01-13', 'Houston, TX', 'Houston HS'),
(237, 'Derrick White', 12, 'DB', 26, 'So', 5.11, 180.00, '2003-04-08', 'Houston, TX', 'Houston HS'),
(238, 'Elijah Clark', 12, 'RB', 22, 'Jr', 5.10, 190.00, '2003-07-20', 'Houston, TX', 'Houston HS'),
(239, 'Marcus Rivers', 12, 'WR', 81, 'Sr', 6.01, 185.00, '2002-02-12', 'Houston, TX', 'Houston HS'),
(240, 'Tyler Brown', 12, 'TE', 85, 'Jr', 6.04, 230.00, '2003-05-30', 'Houston, TX', 'Houston HS'),
(241, 'Aaron Lewis', 12, 'C', 59, 'Sr', 6.01, 300.00, '2001-12-25', 'Houston, TX', 'Houston HS'),
(242, 'Nathan Green', 12, 'OT', 77, 'Jr', 6.07, 310.00, '2002-11-09', 'Houston, TX', 'Houston HS'),
(243, 'Caleb Johnson', 12, 'OG', 66, 'Sr', 6.03, 305.00, '2003-01-31', 'Houston, TX', 'Houston HS'),
(244, 'Sean Williams', 12, 'OG', 68, 'Jr', 6.02, 310.00, '2003-06-15', 'Houston, TX', 'Houston HS'),
(245, 'Jason Allen', 12, 'OT', 74, 'Sr', 6.06, 315.00, '2002-08-11', 'Houston, TX', 'Houston HS'),
(246, 'Michael Clark', 12, 'DE', 92, 'Jr', 6.03, 280.00, '2003-04-29', 'Houston, TX', 'Houston HS'),
(247, 'Robert Davis', 12, 'DT', 95, 'Sr', 6.02, 295.00, '2001-10-28', 'Houston, TX', 'Houston HS'),
(248, 'Eric Smith', 12, 'LB', 55, 'Sr', 6.01, 235.00, '2002-09-13', 'Houston, TX', 'Houston HS'),
(249, 'Kevin Brown', 12, 'CB', 25, 'Jr', 5.11, 190.00, '2003-07-20', 'Houston, TX', 'Houston HS'),
(250, 'Jonathan Lewis', 12, 'SS', 31, 'Sr', 6.00, 195.00, '2001-11-16', 'Houston, TX', 'Houston HS'),
(251, 'Timothy Johnson', 12, 'FS', 28, 'Jr', 6.01, 200.00, '2003-05-03', 'Houston, TX', 'Houston HS'),
(252, 'Jason White', 12, 'K', 3, 'So', 5.11, 180.00, '2004-01-05', 'Houston, TX', 'Houston HS'),
(253, 'Brandon Taylor', 12, 'P', 8, 'Jr', 6.00, 185.00, '2003-07-22', 'Houston, TX', 'Houston HS'),
(254, 'Marcus Harris', 12, 'WR', 82, 'Sr', 6.02, 190.00, '2002-03-30', 'Houston, TX', 'Houston HS'),
(255, 'Derrick Wilson', 12, 'RB', 24, 'Jr', 5.10, 185.00, '2003-09-18', 'Houston, TX', 'Houston HS');

--
-- Triggers `player`
--
DELIMITER $$
CREATE TRIGGER `CheckPlayerAgeBeforeInsert` BEFORE INSERT ON `player` FOR EACH ROW BEGIN
  IF (TIMESTAMPDIFF(YEAR, NEW.Birthdate, CURDATE()) < 18) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Player must be at least 18 years old.';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `CheckPlayerAgeBeforeUpdate` BEFORE UPDATE ON `player` FOR EACH ROW BEGIN
  IF (TIMESTAMPDIFF(YEAR, NEW.Birthdate, CURDATE()) < 18) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Player must be at least 18 years old.';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `playerstats`
--

CREATE TABLE `playerstats` (
  `StatID` int(11) NOT NULL,
  `GameID` int(11) DEFAULT NULL,
  `PlayerID` int(11) DEFAULT NULL,
  `TeamID` int(11) DEFAULT NULL,
  `PassingYards` int(11) DEFAULT NULL,
  `RushingYards` int(11) DEFAULT NULL,
  `ReceivingYards` int(11) DEFAULT NULL,
  `TDs` int(10) UNSIGNED DEFAULT 0,
  `Interceptions` int(11) DEFAULT NULL,
  `Tackles` int(11) DEFAULT NULL,
  `Sacks` int(11) DEFAULT NULL
) ;

--
-- Dumping data for table `playerstats`
--

INSERT INTO `playerstats` (`StatID`, `GameID`, `PlayerID`, `TeamID`, `PassingYards`, `RushingYards`, `ReceivingYards`, `TDs`, `Interceptions`, `Tackles`, `Sacks`) VALUES
(1000, 200, 54, 1, 0, 0, 0, 2, 0, 1, 0),
(1001, 200, 2, 1, 0, 70, 38, 2, 0, 0, 0),
(1002, 200, 55, 1, 0, 0, 0, 0, 0, 6, 0),
(1003, 200, 44, 1, 0, 0, 0, 1, 0, 5, 0),
(1004, 200, 46, 1, 0, 0, 0, 3, 0, 4, 0),
(1005, 200, 53, 1, 0, 0, 0, 2, 0, 7, 0),
(1006, 200, 42, 1, 0, 0, 0, 2, 0, 2, 0),
(1007, 200, 49, 1, 0, 0, 0, 0, 0, 8, 0),
(1008, 200, 5, 1, 0, 0, 0, 2, 0, 3, 0),
(1009, 200, 3, 1, 0, 0, 94, 0, 0, 0, 0),
(1010, 200, 41, 1, 0, 0, 0, 2, 0, 5, 0),
(1011, 200, 21, 2, 219, 9, 0, 1, 2, 0, 0),
(1012, 200, 8, 2, 323, 1, 0, 2, 0, 0, 0),
(1013, 200, 35, 2, 0, 0, 0, 1, 0, 8, 0),
(1014, 200, 32, 2, 0, 0, 0, 2, 0, 9, 0),
(1015, 200, 27, 2, 0, 0, 0, 0, 0, 7, 0),
(1016, 200, 38, 2, 0, 0, 0, 1, 0, 3, 0),
(1017, 200, 33, 2, 0, 0, 0, 0, 0, 9, 0),
(1018, 200, 40, 2, 0, 73, 50, 2, 0, 0, 0),
(1019, 200, 39, 2, 0, 0, 134, 1, 0, 0, 0),
(1020, 200, 30, 2, 0, 0, 0, 2, 0, 2, 0),
(1021, 200, 7, 2, 0, 0, 67, 2, 0, 0, 0),
(1022, 201, 65, 3, 0, 0, 0, 1, 0, 5, 0),
(1023, 201, 70, 3, 0, 0, 0, 1, 0, 12, 0),
(1024, 201, 14, 3, 0, 0, 0, 0, 0, 7, 0),
(1025, 201, 66, 3, 0, 0, 0, 3, 0, 2, 0),
(1026, 201, 72, 3, 0, 0, 0, 1, 0, 7, 0),
(1027, 201, 69, 3, 0, 0, 0, 0, 0, 10, 0),
(1028, 201, 62, 3, 0, 0, 0, 1, 0, 1, 0),
(1029, 201, 15, 3, 0, 110, 4, 2, 0, 0, 0),
(1030, 201, 13, 3, 0, 0, 0, 3, 0, 11, 0),
(1031, 201, 71, 3, 0, 0, 0, 3, 0, 6, 0),
(1032, 201, 58, 3, 0, 0, 0, 0, 0, 8, 0),
(1033, 201, 79, 4, 0, 51, 49, 2, 0, 0, 0),
(1034, 201, 92, 4, 0, 0, 0, 3, 0, 3, 0),
(1035, 201, 82, 4, 0, 0, 0, 2, 0, 6, 0),
(1036, 201, 86, 4, 0, 0, 0, 0, 0, 7, 0),
(1037, 201, 78, 4, 158, 7, 0, 0, 1, 0, 0),
(1038, 201, 90, 4, 0, 0, 0, 1, 0, 7, 0),
(1039, 201, 80, 4, 0, 0, 41, 0, 0, 0, 0),
(1040, 201, 93, 4, 0, 0, 101, 1, 0, 0, 0),
(1041, 201, 83, 4, 0, 0, 0, 3, 0, 1, 0),
(1042, 201, 77, 4, 0, 0, 0, 2, 0, 6, 0),
(1043, 201, 89, 4, 0, 0, 0, 3, 0, 3, 0),
(1044, 202, 108, 5, 0, 0, 0, 3, 0, 9, 0),
(1045, 202, 100, 5, 0, 0, 0, 3, 0, 6, 0),
(1046, 202, 114, 5, 0, 0, 78, 2, 0, 0, 0),
(1047, 202, 96, 5, 322, 14, 0, 3, 0, 0, 0),
(1048, 202, 105, 5, 0, 0, 0, 3, 0, 1, 0),
(1049, 202, 101, 5, 0, 0, 0, 0, 0, 1, 0),
(1050, 202, 99, 5, 0, 0, 0, 2, 0, 7, 0),
(1051, 202, 106, 5, 0, 0, 0, 1, 0, 2, 0),
(1052, 202, 97, 5, 0, 90, 47, 1, 0, 0, 0),
(1053, 202, 113, 5, 0, 0, 0, 2, 0, 7, 0),
(1054, 202, 103, 5, 0, 0, 0, 1, 0, 8, 0),
(1055, 202, 128, 6, 0, 0, 0, 2, 0, 4, 0),
(1056, 202, 120, 6, 0, 0, 73, 0, 0, 0, 0),
(1057, 202, 134, 6, 0, 0, 0, 2, 0, 6, 0),
(1058, 202, 116, 6, 0, 0, 77, 0, 0, 0, 0),
(1059, 202, 125, 6, 0, 0, 0, 2, 0, 6, 0),
(1060, 202, 121, 6, 0, 0, 0, 1, 0, 7, 0),
(1061, 202, 119, 6, 0, 93, 44, 0, 0, 0, 0),
(1062, 202, 126, 6, 0, 0, 0, 3, 0, 2, 0),
(1063, 202, 117, 6, 0, 0, 0, 2, 0, 12, 0),
(1064, 202, 133, 6, 0, 0, 0, 0, 0, 3, 0),
(1065, 202, 123, 6, 0, 0, 0, 2, 0, 7, 0),
(1066, 203, 150, 7, 0, 0, 0, 0, 0, 3, 0),
(1067, 203, 138, 7, 0, 57, 26, 1, 0, 0, 0),
(1068, 203, 137, 7, 0, 0, 0, 3, 0, 11, 0),
(1069, 203, 153, 7, 0, 0, 0, 1, 0, 4, 0),
(1070, 203, 140, 7, 0, 0, 0, 3, 0, 5, 0),
(1071, 203, 152, 7, 0, 0, 0, 0, 0, 4, 0),
(1072, 203, 142, 7, 0, 0, 0, 2, 0, 1, 0),
(1073, 203, 143, 7, 0, 0, 0, 0, 0, 7, 0),
(1074, 203, 151, 7, 0, 0, 0, 2, 0, 7, 0),
(1075, 203, 148, 7, 0, 0, 0, 2, 0, 11, 0),
(1076, 203, 145, 7, 0, 0, 0, 1, 0, 6, 0),
(1077, 203, 170, 8, 0, 0, 0, 1, 0, 4, 0),
(1078, 203, 158, 8, 0, 66, 49, 1, 0, 0, 0),
(1079, 203, 157, 8, 0, 0, 0, 0, 0, 6, 0),
(1080, 203, 173, 8, 0, 0, 0, 3, 0, 2, 0),
(1081, 203, 160, 8, 0, 0, 0, 3, 0, 5, 0),
(1082, 203, 172, 8, 0, 0, 0, 1, 0, 6, 0),
(1083, 203, 162, 8, 0, 0, 0, 0, 0, 8, 0),
(1084, 203, 163, 8, 0, 0, 0, 1, 0, 1, 0),
(1085, 203, 171, 8, 0, 0, 0, 1, 0, 5, 0),
(1086, 203, 168, 8, 0, 0, 0, 2, 0, 4, 0),
(1087, 203, 165, 8, 0, 0, 0, 1, 0, 5, 0),
(1088, 204, 195, 9, 334, 27, 0, 2, 0, 0, 0),
(1089, 204, 179, 9, 0, 0, 0, 3, 0, 4, 0),
(1090, 204, 194, 9, 0, 46, 34, 2, 0, 0, 0),
(1091, 204, 182, 9, 0, 0, 0, 3, 0, 7, 0),
(1092, 204, 189, 9, 0, 0, 0, 3, 0, 1, 0),
(1093, 204, 180, 9, 0, 0, 0, 1, 0, 5, 0),
(1094, 204, 176, 9, 0, 0, 124, 0, 0, 0, 0),
(1095, 204, 193, 9, 0, 0, 96, 0, 0, 0, 0),
(1096, 204, 188, 9, 0, 0, 0, 1, 0, 2, 0),
(1097, 204, 187, 9, 0, 0, 0, 1, 0, 8, 0),
(1098, 204, 191, 9, 0, 0, 0, 3, 0, 7, 0),
(1099, 204, 215, 10, 0, 0, 115, 2, 0, 0, 0),
(1100, 204, 199, 10, 0, 98, 6, 2, 0, 0, 0),
(1101, 204, 214, 10, 0, 0, 0, 0, 0, 2, 0),
(1102, 204, 202, 10, 0, 0, 0, 0, 0, 4, 0),
(1103, 204, 209, 10, 0, 0, 0, 2, 0, 11, 0),
(1104, 204, 200, 10, 0, 0, 95, 2, 0, 0, 0),
(1105, 204, 196, 10, 0, 0, 48, 2, 0, 0, 0),
(1106, 204, 213, 10, 0, 0, 0, 0, 0, 3, 0),
(1107, 204, 208, 10, 0, 0, 0, 3, 0, 3, 0),
(1108, 204, 207, 10, 0, 0, 0, 0, 0, 7, 0),
(1109, 204, 211, 10, 0, 0, 0, 2, 0, 3, 0),
(1110, 120, 118, 6, 197, 1, 0, 3, 0, 0, 0),
(1111, 120, 121, 6, 0, 0, 0, 0, 0, 6, 0),
(1112, 120, 133, 6, 0, 0, 0, 2, 0, 5, 0),
(1113, 120, 135, 6, 0, 0, 54, 1, 0, 0, 0),
(1114, 120, 128, 6, 0, 0, 0, 2, 0, 6, 0),
(1115, 120, 117, 6, 0, 0, 0, 1, 0, 6, 0),
(1116, 120, 127, 6, 0, 0, 0, 1, 0, 8, 0),
(1117, 120, 126, 6, 0, 0, 0, 2, 0, 7, 0),
(1118, 120, 129, 6, 0, 0, 0, 0, 0, 6, 0),
(1119, 120, 134, 6, 0, 0, 0, 2, 0, 6, 0),
(1120, 120, 123, 6, 0, 0, 0, 3, 0, 1, 0),
(1121, 120, 3, 1, 0, 0, 50, 0, 0, 0, 0),
(1122, 120, 41, 1, 0, 0, 0, 3, 0, 1, 0),
(1123, 120, 53, 1, 0, 0, 0, 0, 0, 1, 0),
(1124, 120, 55, 1, 0, 0, 0, 1, 0, 4, 0),
(1125, 120, 48, 1, 0, 0, 0, 3, 0, 1, 0),
(1126, 120, 2, 1, 0, 100, 28, 2, 0, 0, 0),
(1127, 120, 47, 1, 0, 0, 0, 3, 0, 3, 0),
(1128, 120, 46, 1, 0, 0, 0, 0, 0, 8, 0),
(1129, 120, 49, 1, 0, 0, 0, 3, 0, 12, 0),
(1130, 120, 54, 1, 0, 0, 0, 2, 0, 7, 0),
(1131, 120, 43, 1, 0, 0, 0, 3, 0, 2, 0),
(1132, 121, 73, 3, 0, 0, 0, 1, 0, 8, 0),
(1133, 121, 59, 3, 0, 0, 0, 2, 0, 4, 0),
(1134, 121, 56, 3, 220, 10, 0, 2, 1, 0, 0),
(1135, 121, 58, 3, 0, 0, 0, 3, 0, 7, 0),
(1136, 121, 60, 3, 0, 83, 47, 0, 0, 0, 0),
(1137, 121, 13, 3, 0, 0, 0, 2, 0, 8, 0),
(1138, 121, 69, 3, 0, 0, 0, 1, 0, 3, 0),
(1139, 121, 68, 3, 0, 0, 0, 3, 0, 3, 0),
(1140, 121, 15, 3, 0, 82, 18, 0, 0, 0, 0),
(1141, 121, 64, 3, 0, 0, 0, 2, 0, 6, 0),
(1142, 121, 70, 3, 0, 0, 0, 0, 0, 8, 0),
(1143, 121, 153, 7, 0, 0, 0, 0, 0, 4, 0),
(1144, 121, 143, 7, 0, 0, 0, 3, 0, 6, 0),
(1145, 121, 141, 7, 0, 0, 0, 2, 0, 8, 0),
(1146, 121, 142, 7, 0, 0, 0, 0, 0, 8, 0),
(1147, 121, 144, 7, 0, 0, 0, 1, 0, 8, 0),
(1148, 121, 138, 7, 0, 101, 4, 1, 0, 0, 0),
(1149, 121, 151, 7, 0, 0, 0, 1, 0, 8, 0),
(1150, 121, 150, 7, 0, 0, 0, 0, 0, 7, 0),
(1151, 121, 140, 7, 0, 0, 0, 3, 0, 8, 0),
(1152, 121, 147, 7, 0, 0, 0, 1, 0, 6, 0),
(1153, 121, 148, 7, 0, 0, 0, 1, 0, 4, 0),
(1154, 101, 177, 9, 0, 74, 46, 0, 0, 0, 0),
(1155, 101, 193, 9, 0, 0, 84, 1, 0, 0, 0),
(1156, 101, 178, 9, 171, 15, 0, 1, 1, 0, 0),
(1157, 101, 181, 9, 0, 0, 0, 2, 0, 5, 0),
(1158, 101, 187, 9, 0, 0, 0, 0, 0, 12, 0),
(1159, 101, 176, 9, 0, 0, 127, 0, 0, 0, 0),
(1160, 101, 194, 9, 0, 115, 40, 1, 0, 0, 0),
(1161, 101, 182, 9, 0, 0, 0, 1, 0, 7, 0),
(1162, 101, 189, 9, 0, 0, 0, 3, 0, 7, 0),
(1163, 101, 195, 9, 322, 16, 0, 0, 2, 0, 0),
(1164, 101, 186, 9, 0, 0, 0, 3, 0, 8, 0),
(1165, 101, 217, 11, 0, 0, 0, 3, 0, 9, 0),
(1166, 101, 233, 11, 0, 0, 0, 0, 0, 3, 0),
(1167, 101, 218, 11, 0, 75, 26, 2, 0, 0, 0),
(1168, 101, 221, 11, 0, 0, 0, 1, 0, 7, 0),
(1169, 101, 227, 11, 0, 0, 0, 0, 0, 6, 0),
(1170, 101, 216, 11, 190, 25, 0, 0, 1, 0, 0),
(1171, 101, 234, 11, 0, 0, 94, 2, 0, 0, 0),
(1172, 101, 222, 11, 0, 0, 0, 3, 0, 8, 0),
(1173, 101, 229, 11, 0, 0, 0, 2, 0, 1, 0),
(1174, 101, 235, 11, 0, 62, 25, 2, 0, 0, 0),
(1175, 101, 226, 11, 0, 0, 0, 3, 0, 3, 0),
(1176, 102, 103, 5, 0, 0, 0, 0, 0, 2, 0),
(1177, 102, 107, 5, 0, 0, 0, 0, 0, 5, 0),
(1178, 102, 102, 5, 0, 0, 0, 1, 0, 3, 0),
(1179, 102, 111, 5, 0, 0, 0, 2, 0, 6, 0),
(1180, 102, 114, 5, 0, 0, 57, 0, 0, 0, 0),
(1181, 102, 100, 5, 0, 0, 0, 2, 0, 7, 0),
(1182, 102, 108, 5, 0, 0, 0, 2, 0, 5, 0),
(1183, 102, 98, 5, 0, 0, 49, 0, 0, 0, 0),
(1184, 102, 109, 5, 0, 0, 0, 2, 0, 4, 0),
(1185, 102, 97, 5, 0, 77, 4, 2, 0, 0, 0),
(1186, 102, 112, 5, 0, 0, 0, 0, 0, 7, 0),
(1187, 102, 143, 7, 0, 0, 0, 1, 0, 6, 0),
(1188, 102, 147, 7, 0, 0, 0, 1, 0, 6, 0),
(1189, 102, 142, 7, 0, 0, 0, 1, 0, 5, 0),
(1190, 102, 151, 7, 0, 0, 0, 2, 0, 4, 0),
(1191, 102, 154, 7, 0, 0, 96, 0, 0, 0, 0),
(1192, 102, 140, 7, 0, 0, 0, 2, 0, 4, 0),
(1193, 102, 148, 7, 0, 0, 0, 2, 0, 12, 0),
(1194, 102, 138, 7, 0, 97, 0, 1, 0, 0, 0),
(1195, 102, 149, 7, 0, 0, 0, 0, 0, 4, 0),
(1196, 102, 137, 7, 0, 0, 0, 0, 0, 11, 0),
(1197, 102, 152, 7, 0, 0, 0, 2, 0, 1, 0),
(1198, 122, 199, 10, 0, 107, 54, 2, 0, 0, 0),
(1199, 122, 202, 10, 0, 0, 0, 3, 0, 8, 0),
(1200, 122, 203, 10, 0, 0, 0, 0, 0, 2, 0),
(1201, 122, 201, 10, 0, 0, 0, 1, 0, 3, 0),
(1202, 122, 212, 10, 0, 0, 0, 2, 0, 3, 0),
(1203, 122, 211, 10, 0, 0, 0, 2, 0, 6, 0),
(1204, 122, 198, 10, 310, 17, 0, 1, 2, 0, 0),
(1205, 122, 200, 10, 0, 0, 91, 1, 0, 0, 0),
(1206, 122, 205, 10, 0, 0, 0, 1, 0, 3, 0),
(1207, 122, 206, 10, 0, 0, 0, 0, 0, 2, 0),
(1208, 122, 214, 10, 0, 0, 0, 2, 0, 7, 0),
(1209, 122, 99, 5, 0, 0, 0, 2, 0, 1, 0),
(1210, 122, 102, 5, 0, 0, 0, 0, 0, 2, 0),
(1211, 122, 103, 5, 0, 0, 0, 1, 0, 2, 0),
(1212, 122, 101, 5, 0, 0, 0, 0, 0, 6, 0),
(1213, 122, 112, 5, 0, 0, 0, 1, 0, 6, 0),
(1214, 122, 111, 5, 0, 0, 0, 0, 0, 4, 0),
(1215, 122, 98, 5, 0, 0, 84, 0, 0, 0, 0),
(1216, 122, 100, 5, 0, 0, 0, 3, 0, 8, 0),
(1217, 122, 105, 5, 0, 0, 0, 2, 0, 1, 0),
(1218, 122, 106, 5, 0, 0, 0, 2, 0, 5, 0),
(1219, 122, 114, 5, 0, 0, 52, 0, 0, 0, 0),
(1220, 103, 21, 2, 234, 10, 0, 1, 0, 0, 0),
(1221, 103, 7, 2, 0, 0, 113, 1, 0, 0, 0),
(1222, 103, 29, 2, 0, 0, 0, 2, 0, 6, 0),
(1223, 103, 8, 2, 236, 22, 0, 0, 0, 0, 0),
(1224, 103, 28, 2, 0, 0, 0, 0, 0, 6, 0),
(1225, 103, 35, 2, 0, 0, 0, 0, 0, 5, 0),
(1226, 103, 30, 2, 0, 0, 0, 0, 0, 6, 0),
(1227, 103, 23, 2, 0, 0, 45, 2, 0, 0, 0),
(1228, 103, 27, 2, 0, 0, 0, 1, 0, 2, 0),
(1229, 103, 38, 2, 0, 0, 0, 0, 0, 5, 0),
(1230, 103, 9, 2, 0, 0, 0, 3, 0, 3, 0),
(1231, 103, 223, 11, 0, 0, 0, 0, 0, 6, 0),
(1232, 103, 226, 11, 0, 0, 0, 1, 0, 5, 0),
(1233, 103, 221, 11, 0, 0, 0, 3, 0, 3, 0),
(1234, 103, 222, 11, 0, 0, 0, 2, 0, 8, 0),
(1235, 103, 219, 11, 0, 0, 110, 0, 0, 0, 0),
(1236, 103, 234, 11, 0, 0, 48, 1, 0, 0, 0),
(1237, 103, 229, 11, 0, 0, 0, 1, 0, 2, 0),
(1238, 103, 218, 11, 0, 66, 16, 0, 0, 0, 0),
(1239, 103, 230, 11, 0, 0, 0, 0, 0, 6, 0),
(1240, 103, 224, 11, 0, 0, 0, 3, 0, 1, 0),
(1241, 103, 233, 11, 0, 0, 0, 2, 0, 7, 0),
(1242, 104, 179, 9, 0, 0, 0, 0, 0, 6, 0),
(1243, 104, 181, 9, 0, 0, 0, 1, 0, 1, 0),
(1244, 104, 186, 9, 0, 0, 0, 2, 0, 6, 0),
(1245, 104, 182, 9, 0, 0, 0, 2, 0, 6, 0),
(1246, 104, 190, 9, 0, 0, 0, 0, 0, 4, 0),
(1247, 104, 195, 9, 286, 1, 0, 0, 0, 0, 0),
(1248, 104, 191, 9, 0, 0, 0, 0, 0, 2, 0),
(1249, 104, 185, 9, 0, 0, 0, 0, 0, 4, 0),
(1250, 104, 194, 9, 0, 86, 60, 1, 0, 0, 0),
(1251, 104, 180, 9, 0, 0, 0, 1, 0, 3, 0),
(1252, 104, 187, 9, 0, 0, 0, 2, 0, 3, 0),
(1253, 104, 79, 4, 0, 44, 22, 0, 0, 0, 0),
(1254, 104, 81, 4, 0, 0, 0, 2, 0, 1, 0),
(1255, 104, 86, 4, 0, 0, 0, 3, 0, 6, 0),
(1256, 104, 82, 4, 0, 0, 0, 2, 0, 8, 0),
(1257, 104, 90, 4, 0, 0, 0, 2, 0, 1, 0),
(1258, 104, 95, 4, 163, 2, 0, 3, 0, 0, 0),
(1259, 104, 91, 4, 0, 0, 0, 1, 0, 6, 0),
(1260, 104, 85, 4, 0, 0, 0, 3, 0, 3, 0),
(1261, 104, 94, 4, 0, 65, 45, 2, 0, 0, 0),
(1262, 104, 80, 4, 0, 0, 124, 2, 0, 0, 0),
(1263, 104, 87, 4, 0, 0, 0, 1, 0, 9, 0),
(1264, 123, 35, 2, 0, 0, 0, 3, 0, 6, 0),
(1265, 123, 23, 2, 0, 0, 51, 0, 0, 0, 0),
(1266, 123, 34, 2, 0, 0, 0, 3, 0, 3, 0),
(1267, 123, 7, 2, 0, 0, 99, 2, 0, 0, 0),
(1268, 123, 31, 2, 0, 0, 0, 3, 0, 6, 0),
(1269, 123, 24, 2, 0, 0, 0, 3, 0, 1, 0),
(1270, 123, 10, 2, 0, 81, 21, 0, 0, 0, 0),
(1271, 123, 30, 2, 0, 0, 0, 3, 0, 4, 0),
(1272, 123, 38, 2, 0, 0, 0, 1, 0, 4, 0),
(1273, 123, 6, 2, 0, 0, 0, 2, 0, 3, 0),
(1274, 123, 26, 2, 0, 0, 0, 2, 0, 1, 0),
(1275, 123, 195, 9, 193, 20, 0, 0, 1, 0, 0),
(1276, 123, 189, 9, 0, 0, 0, 1, 0, 1, 0),
(1277, 123, 185, 9, 0, 0, 0, 2, 0, 3, 0),
(1278, 123, 183, 9, 0, 0, 0, 0, 0, 5, 0),
(1279, 123, 190, 9, 0, 0, 0, 2, 0, 4, 0),
(1280, 123, 192, 9, 0, 0, 0, 2, 0, 8, 0),
(1281, 123, 186, 9, 0, 0, 0, 0, 0, 6, 0),
(1282, 123, 184, 9, 0, 0, 0, 1, 0, 4, 0),
(1283, 123, 181, 9, 0, 0, 0, 3, 0, 8, 0),
(1284, 123, 180, 9, 0, 0, 0, 0, 0, 4, 0),
(1285, 123, 177, 9, 0, 74, 23, 0, 0, 0, 0),
(1286, 106, 87, 4, 0, 0, 0, 1, 0, 9, 0),
(1287, 106, 88, 4, 0, 0, 0, 3, 0, 8, 0),
(1288, 106, 76, 4, 0, 0, 0, 2, 0, 12, 0),
(1289, 106, 77, 4, 0, 0, 0, 3, 0, 4, 0),
(1290, 106, 84, 4, 0, 0, 0, 1, 0, 3, 0),
(1291, 106, 81, 4, 0, 0, 0, 1, 0, 2, 0),
(1292, 106, 83, 4, 0, 0, 0, 2, 0, 3, 0),
(1293, 106, 91, 4, 0, 0, 0, 2, 0, 8, 0),
(1294, 106, 90, 4, 0, 0, 0, 1, 0, 8, 0),
(1295, 106, 89, 4, 0, 0, 0, 2, 0, 5, 0),
(1296, 106, 79, 4, 0, 89, 44, 1, 0, 0, 0),
(1297, 106, 167, 8, 0, 0, 0, 1, 0, 2, 0),
(1298, 106, 168, 8, 0, 0, 0, 3, 0, 10, 0),
(1299, 106, 156, 8, 238, 16, 0, 3, 0, 0, 0),
(1300, 106, 157, 8, 0, 0, 0, 0, 0, 10, 0),
(1301, 106, 164, 8, 0, 0, 0, 0, 0, 1, 0),
(1302, 106, 161, 8, 0, 0, 0, 1, 0, 3, 0),
(1303, 106, 163, 8, 0, 0, 0, 0, 0, 8, 0),
(1304, 106, 171, 8, 0, 0, 0, 1, 0, 4, 0),
(1305, 106, 170, 8, 0, 0, 0, 2, 0, 3, 0),
(1306, 106, 169, 8, 0, 0, 0, 2, 0, 1, 0),
(1307, 106, 159, 8, 0, 0, 135, 1, 0, 0, 0),
(1308, 124, 175, 8, 0, 71, 4, 2, 0, 0, 0),
(1309, 124, 161, 8, 0, 0, 0, 1, 0, 4, 0),
(1310, 124, 158, 8, 0, 44, 10, 1, 0, 0, 0),
(1311, 124, 157, 8, 0, 0, 0, 3, 0, 12, 0),
(1312, 124, 160, 8, 0, 0, 0, 0, 0, 5, 0),
(1313, 124, 170, 8, 0, 0, 0, 0, 0, 4, 0),
(1314, 124, 159, 8, 0, 0, 48, 0, 0, 0, 0),
(1315, 124, 172, 8, 0, 0, 0, 0, 0, 6, 0),
(1316, 124, 173, 8, 0, 0, 0, 2, 0, 3, 0),
(1317, 124, 165, 8, 0, 0, 0, 2, 0, 2, 0),
(1318, 124, 169, 8, 0, 0, 0, 2, 0, 6, 0),
(1319, 124, 95, 4, 232, 25, 0, 2, 2, 0, 0),
(1320, 124, 81, 4, 0, 0, 0, 1, 0, 1, 0),
(1321, 124, 78, 4, 290, 9, 0, 1, 1, 0, 0),
(1322, 124, 77, 4, 0, 0, 0, 0, 0, 6, 0),
(1323, 124, 80, 4, 0, 0, 53, 1, 0, 0, 0),
(1324, 124, 90, 4, 0, 0, 0, 3, 0, 6, 0),
(1325, 124, 79, 4, 0, 72, 59, 2, 0, 0, 0),
(1326, 124, 92, 4, 0, 0, 0, 3, 0, 4, 0),
(1327, 124, 93, 4, 0, 0, 137, 1, 0, 0, 0),
(1328, 124, 85, 4, 0, 0, 0, 2, 0, 4, 0),
(1329, 124, 89, 4, 0, 0, 0, 0, 0, 3, 0),
(1330, 107, 135, 6, 0, 0, 76, 2, 0, 0, 0),
(1331, 107, 131, 6, 0, 0, 0, 1, 0, 3, 0),
(1332, 107, 119, 6, 0, 71, 50, 1, 0, 0, 0),
(1333, 107, 125, 6, 0, 0, 0, 3, 0, 2, 0),
(1334, 107, 120, 6, 0, 0, 43, 0, 0, 0, 0),
(1335, 107, 118, 6, 227, 8, 0, 3, 1, 0, 0),
(1336, 107, 126, 6, 0, 0, 0, 3, 0, 6, 0),
(1337, 107, 132, 6, 0, 0, 0, 3, 0, 4, 0),
(1338, 107, 129, 6, 0, 0, 0, 1, 0, 7, 0),
(1339, 107, 117, 6, 0, 0, 0, 1, 0, 5, 0),
(1340, 107, 122, 6, 0, 0, 0, 3, 0, 8, 0),
(1341, 107, 215, 10, 0, 0, 72, 1, 0, 0, 0),
(1342, 107, 211, 10, 0, 0, 0, 2, 0, 2, 0),
(1343, 107, 199, 10, 0, 79, 40, 1, 0, 0, 0),
(1344, 107, 205, 10, 0, 0, 0, 0, 0, 4, 0),
(1345, 107, 200, 10, 0, 0, 52, 1, 0, 0, 0),
(1346, 107, 198, 10, 196, 15, 0, 1, 2, 0, 0),
(1347, 107, 206, 10, 0, 0, 0, 3, 0, 4, 0),
(1348, 107, 212, 10, 0, 0, 0, 3, 0, 5, 0),
(1349, 107, 209, 10, 0, 0, 0, 0, 0, 5, 0),
(1350, 107, 197, 10, 0, 0, 0, 2, 0, 5, 0),
(1351, 107, 202, 10, 0, 0, 0, 3, 0, 2, 0),
(1352, 108, 139, 7, 0, 0, 45, 0, 0, 0, 0),
(1353, 108, 153, 7, 0, 0, 0, 1, 0, 7, 0),
(1354, 108, 152, 7, 0, 0, 0, 1, 0, 4, 0),
(1355, 108, 151, 7, 0, 0, 0, 3, 0, 7, 0),
(1356, 108, 148, 7, 0, 0, 0, 2, 0, 7, 0),
(1357, 108, 143, 7, 0, 0, 0, 1, 0, 1, 0),
(1358, 108, 142, 7, 0, 0, 0, 2, 0, 6, 0),
(1359, 108, 138, 7, 0, 42, 34, 1, 0, 0, 0),
(1360, 108, 144, 7, 0, 0, 0, 2, 0, 8, 0),
(1361, 108, 146, 7, 0, 0, 0, 2, 0, 4, 0),
(1362, 108, 136, 7, 278, 21, 0, 1, 1, 0, 0),
(1363, 108, 179, 9, 0, 0, 0, 1, 0, 6, 0),
(1364, 108, 193, 9, 0, 0, 60, 0, 0, 0, 0),
(1365, 108, 192, 9, 0, 0, 0, 1, 0, 1, 0),
(1366, 108, 191, 9, 0, 0, 0, 0, 0, 5, 0),
(1367, 108, 188, 9, 0, 0, 0, 0, 0, 1, 0),
(1368, 108, 183, 9, 0, 0, 0, 3, 0, 4, 0),
(1369, 108, 182, 9, 0, 0, 0, 0, 0, 4, 0),
(1370, 108, 178, 9, 158, 11, 0, 1, 2, 0, 0),
(1371, 108, 184, 9, 0, 0, 0, 2, 0, 6, 0),
(1372, 108, 186, 9, 0, 0, 0, 0, 0, 2, 0),
(1373, 108, 176, 9, 0, 0, 99, 2, 0, 0, 0),
(1374, 109, 110, 5, 0, 0, 0, 2, 0, 5, 0),
(1375, 109, 99, 5, 0, 0, 0, 3, 0, 3, 0),
(1376, 109, 98, 5, 0, 0, 96, 2, 0, 0, 0),
(1377, 109, 109, 5, 0, 0, 0, 3, 0, 4, 0),
(1378, 109, 101, 5, 0, 0, 0, 1, 0, 1, 0),
(1379, 109, 104, 5, 0, 0, 0, 3, 0, 5, 0),
(1380, 109, 108, 5, 0, 0, 0, 2, 0, 12, 0),
(1381, 109, 97, 5, 0, 62, 48, 1, 0, 0, 0),
(1382, 109, 106, 5, 0, 0, 0, 1, 0, 7, 0),
(1383, 109, 107, 5, 0, 0, 0, 0, 0, 12, 0),
(1384, 109, 103, 5, 0, 0, 0, 1, 0, 3, 0),
(1385, 109, 36, 2, 0, 0, 0, 2, 0, 6, 0),
(1386, 109, 6, 2, 0, 0, 0, 1, 0, 9, 0),
(1387, 109, 34, 2, 0, 0, 0, 1, 0, 3, 0),
(1388, 109, 35, 2, 0, 0, 0, 2, 0, 7, 0),
(1389, 109, 21, 2, 280, 22, 0, 2, 2, 0, 0),
(1390, 109, 27, 2, 0, 0, 0, 2, 0, 1, 0),
(1391, 109, 37, 2, 0, 0, 0, 1, 0, 7, 0),
(1392, 109, 38, 2, 0, 0, 0, 3, 0, 7, 0),
(1393, 109, 9, 2, 0, 0, 0, 1, 0, 6, 0),
(1394, 109, 8, 2, 318, 0, 0, 0, 2, 0, 0),
(1395, 109, 26, 2, 0, 0, 0, 0, 0, 4, 0),
(1396, 110, 159, 8, 0, 0, 51, 1, 0, 0, 0),
(1397, 110, 160, 8, 0, 0, 0, 0, 0, 3, 0),
(1398, 110, 175, 8, 0, 89, 5, 2, 0, 0, 0),
(1399, 110, 156, 8, 232, 25, 0, 2, 0, 0, 0),
(1400, 110, 168, 8, 0, 0, 0, 2, 0, 11, 0),
(1401, 110, 167, 8, 0, 0, 0, 1, 0, 5, 0),
(1402, 110, 162, 8, 0, 0, 0, 0, 0, 7, 0),
(1403, 110, 163, 8, 0, 0, 0, 2, 0, 2, 0),
(1404, 110, 165, 8, 0, 0, 0, 3, 0, 4, 0),
(1405, 110, 174, 8, 0, 0, 43, 0, 0, 0, 0),
(1406, 110, 157, 8, 0, 0, 0, 0, 0, 10, 0),
(1407, 110, 119, 6, 0, 112, 3, 0, 0, 0, 0),
(1408, 110, 120, 6, 0, 0, 110, 1, 0, 0, 0),
(1409, 110, 135, 6, 0, 0, 53, 0, 0, 0, 0),
(1410, 110, 116, 6, 0, 0, 64, 0, 0, 0, 0),
(1411, 110, 128, 6, 0, 0, 0, 2, 0, 5, 0),
(1412, 110, 127, 6, 0, 0, 0, 2, 0, 4, 0),
(1413, 110, 122, 6, 0, 0, 0, 3, 0, 7, 0),
(1414, 110, 123, 6, 0, 0, 0, 0, 0, 8, 0),
(1415, 110, 125, 6, 0, 0, 0, 2, 0, 4, 0),
(1416, 110, 134, 6, 0, 0, 0, 3, 0, 6, 0),
(1417, 110, 117, 6, 0, 0, 0, 0, 0, 3, 0),
(1418, 111, 183, 9, 0, 0, 0, 2, 0, 5, 0),
(1419, 111, 192, 9, 0, 0, 0, 1, 0, 2, 0),
(1420, 111, 189, 9, 0, 0, 0, 3, 0, 6, 0),
(1421, 111, 179, 9, 0, 0, 0, 0, 0, 3, 0),
(1422, 111, 185, 9, 0, 0, 0, 3, 0, 4, 0),
(1423, 111, 176, 9, 0, 0, 71, 2, 0, 0, 0),
(1424, 111, 180, 9, 0, 0, 0, 2, 0, 6, 0),
(1425, 111, 187, 9, 0, 0, 0, 2, 0, 4, 0),
(1426, 111, 188, 9, 0, 0, 0, 2, 0, 5, 0),
(1427, 111, 177, 9, 0, 64, 38, 1, 0, 0, 0),
(1428, 111, 181, 9, 0, 0, 0, 0, 0, 8, 0),
(1429, 111, 103, 5, 0, 0, 0, 3, 0, 4, 0),
(1430, 111, 112, 5, 0, 0, 0, 1, 0, 5, 0),
(1431, 111, 109, 5, 0, 0, 0, 2, 0, 7, 0),
(1432, 111, 99, 5, 0, 0, 0, 1, 0, 3, 0),
(1433, 111, 105, 5, 0, 0, 0, 3, 0, 7, 0),
(1434, 111, 96, 5, 164, 20, 0, 0, 0, 0, 0),
(1435, 111, 100, 5, 0, 0, 0, 2, 0, 5, 0),
(1436, 111, 107, 5, 0, 0, 0, 2, 0, 12, 0),
(1437, 111, 108, 5, 0, 0, 0, 3, 0, 3, 0),
(1438, 111, 97, 5, 0, 118, 19, 2, 0, 0, 0),
(1439, 111, 101, 5, 0, 0, 0, 1, 0, 8, 0),
(1440, 112, 35, 2, 0, 0, 0, 2, 0, 5, 0),
(1441, 112, 39, 2, 0, 0, 130, 1, 0, 0, 0),
(1442, 112, 28, 2, 0, 0, 0, 3, 0, 7, 0),
(1443, 112, 10, 2, 0, 112, 57, 2, 0, 0, 0),
(1444, 112, 34, 2, 0, 0, 0, 0, 0, 6, 0),
(1445, 112, 7, 2, 0, 0, 52, 0, 0, 0, 0),
(1446, 112, 29, 2, 0, 0, 0, 0, 0, 7, 0),
(1447, 112, 32, 2, 0, 0, 0, 3, 0, 8, 0),
(1448, 112, 38, 2, 0, 0, 0, 1, 0, 5, 0),
(1449, 112, 22, 2, 0, 52, 40, 1, 0, 0, 0),
(1450, 112, 33, 2, 0, 0, 0, 0, 0, 10, 0),
(1451, 112, 152, 7, 0, 0, 0, 3, 0, 2, 0),
(1452, 112, 149, 7, 0, 0, 0, 3, 0, 7, 0),
(1453, 112, 146, 7, 0, 0, 0, 2, 0, 4, 0),
(1454, 112, 140, 7, 0, 0, 0, 1, 0, 2, 0),
(1455, 112, 137, 7, 0, 0, 0, 3, 0, 8, 0),
(1456, 112, 150, 7, 0, 0, 0, 3, 0, 2, 0),
(1457, 112, 153, 7, 0, 0, 0, 3, 0, 4, 0),
(1458, 112, 148, 7, 0, 0, 0, 3, 0, 6, 0),
(1459, 112, 155, 7, 0, 69, 57, 1, 0, 0, 0),
(1460, 112, 141, 7, 0, 0, 0, 0, 0, 6, 0),
(1461, 112, 144, 7, 0, 0, 0, 0, 0, 3, 0),
(1462, 113, 103, 5, 0, 0, 0, 3, 0, 5, 0),
(1463, 113, 106, 5, 0, 0, 0, 0, 0, 5, 0),
(1464, 113, 115, 5, 0, 113, 6, 0, 0, 0, 0),
(1465, 113, 109, 5, 0, 0, 0, 3, 0, 8, 0),
(1466, 113, 101, 5, 0, 0, 0, 2, 0, 8, 0),
(1467, 113, 113, 5, 0, 0, 0, 2, 0, 7, 0),
(1468, 113, 114, 5, 0, 0, 89, 1, 0, 0, 0),
(1469, 113, 107, 5, 0, 0, 0, 3, 0, 4, 0),
(1470, 113, 102, 5, 0, 0, 0, 3, 0, 5, 0),
(1471, 113, 110, 5, 0, 0, 0, 2, 0, 7, 0),
(1472, 113, 97, 5, 0, 87, 26, 1, 0, 0, 0),
(1473, 113, 183, 9, 0, 0, 0, 3, 0, 8, 0),
(1474, 113, 186, 9, 0, 0, 0, 0, 0, 4, 0),
(1475, 113, 195, 9, 225, 18, 0, 0, 2, 0, 0),
(1476, 113, 189, 9, 0, 0, 0, 1, 0, 5, 0),
(1477, 113, 181, 9, 0, 0, 0, 0, 0, 7, 0),
(1478, 113, 193, 9, 0, 0, 106, 0, 0, 0, 0),
(1479, 113, 194, 9, 0, 82, 14, 2, 0, 0, 0),
(1480, 113, 187, 9, 0, 0, 0, 0, 0, 9, 0),
(1481, 113, 182, 9, 0, 0, 0, 2, 0, 8, 0),
(1482, 113, 190, 9, 0, 0, 0, 1, 0, 3, 0),
(1483, 113, 177, 9, 0, 57, 27, 1, 0, 0, 0),
(1484, 114, 166, 8, 0, 0, 0, 3, 0, 1, 0),
(1485, 114, 170, 8, 0, 0, 0, 3, 0, 6, 0),
(1486, 114, 173, 8, 0, 0, 0, 0, 0, 2, 0),
(1487, 114, 159, 8, 0, 0, 115, 2, 0, 0, 0),
(1488, 114, 157, 8, 0, 0, 0, 1, 0, 12, 0),
(1489, 114, 163, 8, 0, 0, 0, 2, 0, 3, 0),
(1490, 114, 161, 8, 0, 0, 0, 2, 0, 5, 0),
(1491, 114, 165, 8, 0, 0, 0, 1, 0, 2, 0),
(1492, 114, 169, 8, 0, 0, 0, 2, 0, 5, 0),
(1493, 114, 158, 8, 0, 58, 49, 1, 0, 0, 0),
(1494, 114, 174, 8, 0, 0, 72, 2, 0, 0, 0),
(1495, 114, 126, 6, 0, 0, 0, 0, 0, 8, 0),
(1496, 114, 130, 6, 0, 0, 0, 1, 0, 1, 0),
(1497, 114, 133, 6, 0, 0, 0, 1, 0, 4, 0),
(1498, 114, 119, 6, 0, 46, 56, 0, 0, 0, 0),
(1499, 114, 117, 6, 0, 0, 0, 0, 0, 3, 0),
(1500, 114, 123, 6, 0, 0, 0, 2, 0, 6, 0),
(1501, 114, 121, 6, 0, 0, 0, 3, 0, 3, 0),
(1502, 114, 125, 6, 0, 0, 0, 3, 0, 4, 0),
(1503, 114, 129, 6, 0, 0, 0, 2, 0, 4, 0),
(1504, 114, 118, 6, 159, 19, 0, 0, 2, 0, 0),
(1505, 114, 134, 6, 0, 0, 0, 2, 0, 2, 0),
(1506, 115, 76, 4, 0, 0, 0, 0, 0, 10, 0),
(1507, 115, 86, 4, 0, 0, 0, 0, 0, 4, 0),
(1508, 115, 78, 4, 266, 25, 0, 2, 2, 0, 0),
(1509, 115, 77, 4, 0, 0, 0, 1, 0, 11, 0),
(1510, 115, 80, 4, 0, 0, 130, 2, 0, 0, 0),
(1511, 115, 81, 4, 0, 0, 0, 0, 0, 5, 0),
(1512, 115, 90, 4, 0, 0, 0, 1, 0, 6, 0),
(1513, 115, 91, 4, 0, 0, 0, 1, 0, 6, 0),
(1514, 115, 79, 4, 0, 59, 38, 1, 0, 0, 0),
(1515, 115, 92, 4, 0, 0, 0, 0, 0, 5, 0),
(1516, 115, 83, 4, 0, 0, 0, 3, 0, 6, 0),
(1517, 115, 196, 10, 0, 0, 61, 0, 0, 0, 0),
(1518, 115, 206, 10, 0, 0, 0, 2, 0, 2, 0),
(1519, 115, 198, 10, 157, 16, 0, 2, 0, 0, 0),
(1520, 115, 197, 10, 0, 0, 0, 3, 0, 5, 0),
(1521, 115, 200, 10, 0, 0, 90, 2, 0, 0, 0),
(1522, 115, 201, 10, 0, 0, 0, 1, 0, 6, 0),
(1523, 115, 210, 10, 0, 0, 0, 1, 0, 2, 0),
(1524, 115, 211, 10, 0, 0, 0, 0, 0, 6, 0),
(1525, 115, 199, 10, 0, 88, 12, 2, 0, 0, 0),
(1526, 115, 212, 10, 0, 0, 0, 0, 0, 3, 0),
(1527, 115, 203, 10, 0, 0, 0, 2, 0, 6, 0),
(1550, 117, 209, 10, 0, 0, 0, 0, 0, 6, 0),
(1551, 117, 207, 10, 0, 0, 0, 1, 0, 3, 0),
(1552, 117, 198, 10, 203, 21, 0, 1, 2, 0, 0),
(1553, 117, 206, 10, 0, 0, 0, 1, 0, 5, 0),
(1554, 117, 202, 10, 0, 0, 0, 1, 0, 3, 0),
(1555, 117, 214, 10, 0, 0, 0, 3, 0, 3, 0),
(1556, 117, 212, 10, 0, 0, 0, 0, 0, 4, 0),
(1557, 117, 196, 10, 0, 0, 112, 0, 0, 0, 0),
(1558, 117, 199, 10, 0, 73, 35, 2, 0, 0, 0),
(1559, 117, 203, 10, 0, 0, 0, 0, 0, 2, 0),
(1560, 117, 197, 10, 0, 0, 0, 2, 0, 7, 0),
(1561, 117, 169, 8, 0, 0, 0, 3, 0, 8, 0),
(1562, 117, 167, 8, 0, 0, 0, 2, 0, 1, 0),
(1563, 117, 158, 8, 0, 43, 24, 2, 0, 0, 0),
(1564, 117, 166, 8, 0, 0, 0, 0, 0, 4, 0),
(1565, 117, 162, 8, 0, 0, 0, 1, 0, 7, 0),
(1566, 117, 174, 8, 0, 0, 121, 0, 0, 0, 0),
(1567, 117, 172, 8, 0, 0, 0, 0, 0, 2, 0),
(1568, 117, 156, 8, 215, 1, 0, 3, 1, 0, 0),
(1569, 117, 159, 8, 0, 0, 51, 2, 0, 0, 0),
(1570, 117, 163, 8, 0, 0, 0, 1, 0, 4, 0),
(1571, 117, 157, 8, 0, 0, 0, 3, 0, 12, 0),
(9001, 301, 236, 12, 129, 8, 16, 1, 0, 10, 1),
(9002, 301, 237, 12, 349, 74, 115, 1, 2, 12, 2),
(9003, 301, 238, 12, 60, 13, 82, 2, 0, 5, 3),
(9004, 301, 239, 12, 24, 79, 78, 1, 2, 9, 2),
(9005, 301, 240, 12, 347, 44, 14, 1, 3, 8, 3),
(9006, 301, 241, 12, 47, 98, 132, 1, 1, 0, 5),
(9007, 301, 242, 12, 324, 108, 27, 2, 1, 10, 2),
(9008, 301, 243, 12, 289, 21, 10, 1, 1, 8, 1),
(9009, 301, 244, 12, 288, 149, 25, 2, 3, 2, 1),
(9010, 301, 245, 12, 287, 97, 148, 0, 3, 7, 5),
(9011, 301, 246, 12, 7, 89, 140, 0, 3, 15, 2),
(9012, 301, 247, 12, 300, 13, 86, 4, 2, 2, 4),
(9013, 301, 76, 4, 240, 43, 74, 2, 0, 12, 4),
(9014, 301, 77, 4, 18, 8, 120, 1, 1, 13, 3),
(9015, 301, 78, 4, 7, 62, 129, 3, 3, 10, 5),
(9016, 301, 79, 4, 204, 10, 141, 2, 1, 12, 1),
(9017, 301, 80, 4, 231, 98, 139, 3, 2, 4, 2),
(9018, 301, 81, 4, 219, 60, 112, 3, 0, 0, 0),
(9019, 301, 82, 4, 260, 143, 92, 3, 1, 2, 2),
(9020, 301, 83, 4, 201, 66, 86, 3, 1, 15, 2),
(9021, 301, 84, 4, 98, 60, 67, 0, 2, 10, 0),
(9022, 301, 85, 4, 148, 18, 136, 2, 2, 5, 3),
(9023, 301, 86, 4, 194, 107, 55, 3, 0, 8, 4),
(9024, 301, 87, 4, 43, 134, 33, 2, 3, 3, 1),
(9025, 302, 96, 5, 49, 35, 106, 3, 3, 6, 1),
(9026, 302, 97, 5, 218, 77, 16, 1, 2, 1, 0),
(9027, 302, 98, 5, 283, 99, 89, 3, 2, 4, 2),
(9028, 302, 99, 5, 71, 136, 63, 1, 1, 9, 0),
(9029, 302, 100, 5, 96, 114, 141, 4, 0, 12, 5),
(9030, 302, 101, 5, 273, 76, 39, 2, 0, 15, 1),
(9031, 302, 102, 5, 10, 40, 76, 2, 0, 5, 5),
(9032, 302, 103, 5, 272, 75, 133, 2, 0, 12, 1),
(9033, 302, 104, 5, 280, 28, 13, 4, 3, 13, 3),
(9034, 302, 105, 5, 28, 147, 48, 4, 2, 7, 5),
(9035, 302, 106, 5, 89, 56, 112, 0, 1, 2, 5),
(9036, 302, 107, 5, 127, 93, 139, 3, 3, 9, 4),
(9037, 302, 236, 12, 275, 138, 26, 3, 0, 2, 5),
(9038, 302, 237, 12, 342, 22, 19, 1, 2, 7, 3),
(9039, 302, 238, 12, 283, 133, 10, 0, 0, 5, 4),
(9040, 302, 239, 12, 201, 133, 33, 0, 3, 9, 1),
(9041, 302, 240, 12, 279, 134, 97, 1, 0, 1, 0),
(9042, 302, 241, 12, 342, 86, 74, 2, 0, 3, 3),
(9043, 302, 242, 12, 308, 149, 88, 2, 1, 6, 4),
(9044, 302, 243, 12, 82, 120, 135, 2, 3, 0, 1),
(9045, 302, 244, 12, 152, 95, 99, 0, 1, 2, 0),
(9046, 302, 245, 12, 196, 4, 19, 0, 1, 7, 3),
(9047, 302, 246, 12, 31, 53, 121, 3, 3, 4, 0),
(9048, 302, 247, 12, 251, 103, 147, 2, 3, 15, 0),
(9049, 303, 236, 12, 300, 51, 144, 3, 2, 2, 2),
(9050, 303, 237, 12, 141, 66, 82, 3, 2, 6, 2),
(9051, 303, 238, 12, 48, 82, 83, 1, 0, 15, 1),
(9052, 303, 239, 12, 18, 85, 75, 0, 2, 10, 0),
(9053, 303, 240, 12, 320, 82, 139, 0, 1, 15, 2),
(9054, 303, 241, 12, 182, 116, 30, 4, 3, 6, 3),
(9055, 303, 242, 12, 186, 123, 19, 3, 1, 14, 0),
(9056, 303, 243, 12, 202, 136, 106, 3, 1, 10, 1),
(9057, 303, 244, 12, 50, 1, 68, 1, 0, 11, 2),
(9058, 303, 245, 12, 69, 21, 103, 3, 2, 8, 0),
(9059, 303, 246, 12, 302, 81, 30, 0, 3, 4, 3),
(9060, 303, 247, 12, 211, 98, 17, 4, 3, 15, 3),
(9061, 303, 136, 7, 201, 150, 18, 1, 3, 8, 3),
(9062, 303, 137, 7, 319, 57, 108, 0, 2, 2, 1),
(9063, 303, 138, 7, 135, 98, 109, 4, 3, 14, 5),
(9064, 303, 139, 7, 132, 9, 140, 0, 1, 12, 4),
(9065, 303, 140, 7, 325, 100, 38, 4, 0, 2, 5),
(9066, 303, 141, 7, 49, 34, 132, 1, 1, 8, 2),
(9067, 303, 142, 7, 205, 35, 56, 2, 3, 8, 1),
(9068, 303, 143, 7, 2, 19, 46, 2, 1, 10, 2),
(9069, 303, 144, 7, 39, 19, 97, 1, 2, 5, 5),
(9070, 303, 145, 7, 276, 88, 63, 2, 2, 6, 5),
(9071, 303, 146, 7, 314, 140, 20, 3, 1, 8, 1),
(9072, 303, 147, 7, 183, 39, 115, 0, 2, 3, 1);

--
-- Triggers `playerstats`
--
DELIMITER $$
CREATE TRIGGER `after_playerstats_insert` AFTER INSERT ON `playerstats` FOR EACH ROW BEGIN
   UPDATE player
   SET TotalTDs = TotalTDs + NEW.TDs
   WHERE PlayerID = NEW.PlayerID;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_playerstats_insert_update` AFTER INSERT ON `playerstats` FOR EACH ROW BEGIN
  CALL UpdateGameScores();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `schedule`
--

CREATE TABLE `schedule` (
  `ScheduleID` int(11) NOT NULL,
  `GameID` int(11) DEFAULT NULL,
  `Week` int(11) DEFAULT NULL,
  `Date` date DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `Broadcaster` varchar(100) DEFAULT NULL,
  `Location` varchar(255) DEFAULT NULL,
  `HomeTeamID` int(11) DEFAULT NULL,
  `AwayTeamID` int(11) DEFAULT NULL,
  `ScoreHome` int(11) DEFAULT NULL,
  `ScoreAway` int(11) DEFAULT NULL,
  `GameStatus` varchar(50) DEFAULT 'Scheduled',
  `Attendance` int(11) DEFAULT NULL,
  `Referee` varchar(100) DEFAULT NULL,
  `GameDuration` int(11) DEFAULT NULL,
  `Weather` varchar(100) DEFAULT NULL
) ;

--
-- Dumping data for table `schedule`
--

INSERT INTO `schedule` (`ScheduleID`, `GameID`, `Week`, `Date`, `Time`, `Broadcaster`, `Location`, `HomeTeamID`, `AwayTeamID`, `ScoreHome`, `ScoreAway`, `GameStatus`, `Attendance`, `Referee`, `GameDuration`, `Weather`) VALUES
(1, 101, 1, '2025-08-30', '16:00:00', 'SWAC TV', 'Rice–Totten Stadium', 9, 11, 29, 34, 'Completed', 15000, 'John Smith', 180, 'Clear'),
(2, 102, 1, '2025-08-30', '19:00:00', 'ESPN+', 'Eddie Robinson Stadium', 5, 7, 9, 42, 'Completed', 13000, 'Mike Brown', 180, 'Sunny'),
(3, 103, 2, '2025-09-06', '19:00:00', 'ESPN+', 'Hornet Stadium', 2, 11, 14, 17, 'Completed', 20000, 'Jeff Davis', 180, 'Cloudy'),
(4, 104, 3, '2025-09-13', '19:00:00', 'ESPNU', 'Jack Spinks Stadium', 9, 4, 10, 20, 'Completed', 17000, 'Tom Lee', 180, 'Rain'),
(6, 106, 4, '2025-09-20', '15:00:00', 'ESPNU', 'C.A. Freeman Stadium', 4, 8, 24, 21, 'Completed', 16000, 'Dan Carlson', 175, 'Partly Cloudy'),
(7, 107, 5, '2025-09-27', '18:30:00', 'ESPN+', 'Bragg Memorial Stadium', 6, 10, 28, 14, 'Completed', 14000, 'Sarah Lee', 180, 'Sunny'),
(8, 108, 6, '2025-10-04', '15:00:00', 'SWAC TV', 'Eddie Robinson Stadium', 7, 9, 34, 31, 'Completed', 18000, 'Mark Johnson', 190, 'Clear'),
(9, 109, 7, '2025-10-11', '19:00:00', 'ESPNU', 'HMS Ballpark', 5, 2, 20, 24, 'Completed', 15000, 'Rachel Adams', 180, 'Rain'),
(10, 110, 8, '2025-10-18', '16:00:00', 'ESPN+', 'Louis Crews Stadium', 8, 6, 27, 27, 'Completed', 19000, 'Tom Howard', 175, 'Sunny'),
(11, 111, 9, '2025-10-25', '14:00:00', 'SWAC TV', 'Rice–Totten Stadium', 9, 5, 31, 28, 'Completed', 15500, 'Alice Green', 180, 'Clear'),
(12, 112, 10, '2025-11-01', '18:00:00', 'ESPN+', 'Hornet Stadium', 2, 7, 24, 21, 'Completed', 16000, 'Michael Turner', 175, 'Cloudy'),
(13, 113, 11, '2025-11-08', '19:00:00', 'ESPNU', 'Eddie Robinson Stadium', 5, 9, 20, 35, 'Completed', 14000, 'Kelly Brown', 180, 'Sunny'),
(14, 114, 12, '2025-11-15', '16:00:00', 'ESPN2', 'Louis Crews Stadium', 8, 6, 28, 27, 'Completed', 19000, 'Chris White', 180, 'Partly Cloudy'),
(15, 115, 13, '2025-11-22', '15:00:00', 'SWAC TV', 'Jack Spinks Stadium', 4, 10, 0, 0, 'scheduled', 0, 'Jamie Clark', 0, 'Clear'),
(16, 116, 15, '2025-11-29', '15:00:00', 'SWAC TV', 'Alumni Stadium', 3, 1, 0, 0, 'scheduled', 0, 'Laura Mitchell', 0, 'Cloudy'),
(17, 117, 16, '2025-12-06', '18:00:00', 'ESPN2', 'Shell Energy Stadium', 10, 8, 0, 0, 'Scheduled', 0, '', 0, 'Clear'),
(201, 200, 1, '2025-01-15', '14:00:00', 'SWAC TV', 'Alumni Stadium', 1, 2, 21, 17, 'Completed', 8000, 'Referee A', 120, 'Clear'),
(202, 201, 10, '2025-03-10', '15:00:00', 'ESPN+', 'Rice–Totten Stadium', 3, 4, 14, 28, 'Completed', 9000, 'Referee B', 130, 'Cloudy'),
(203, 202, 20, '2025-05-20', '16:30:00', 'ESPNU', 'Eddie Robinson Stadium', 5, 6, 35, 22, 'Completed', 7500, 'Referee C', 140, 'Sunny'),
(204, 203, 28, '2025-07-05', '18:00:00', 'ESPN2', 'Hornet Stadium', 7, 8, 24, 24, 'scheduled', 7100, 'Referee D', 135, 'Partly Cloudy'),
(205, 204, 32, '2025-08-18', '19:30:00', 'SWAC TV', 'C.A. Freeman Stadium', 9, 10, 17, 20, 'Completed', 8500, 'Referee E', 125, 'Clear'),
(225, 2011, 16, '2025-12-07', '16:00:00', 'ESPN+', 'Future Field', 1, 12, NULL, NULL, 'Scheduled', 0, NULL, NULL, NULL),
(226, 2013, 18, '2025-12-22', '18:30:00', 'SWAC TV', 'Grand Grounds', 3, 12, NULL, NULL, 'Scheduled', 0, NULL, NULL, NULL);

--
-- Triggers `schedule`
--
DELIMITER $$
CREATE TRIGGER `CheckTeamScheduleBeforeInsert` BEFORE INSERT ON `schedule` FOR EACH ROW BEGIN
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
-- Table structure for table `team`
--

CREATE TABLE `team` (
  `TeamID` int(11) NOT NULL,
  `Name` varchar(100) DEFAULT NULL,
  `Mascot` varchar(50) DEFAULT NULL,
  `School` varchar(100) DEFAULT NULL,
  `Stadium` varchar(100) DEFAULT NULL,
  `CoachID` int(11) DEFAULT NULL,
  `City` varchar(100) DEFAULT NULL,
  `State` varchar(50) DEFAULT NULL,
  `Division` varchar(20) DEFAULT NULL
) ;

--
-- Dumping data for table `team`
--

INSERT INTO `team` (`TeamID`, `Name`, `Mascot`, `School`, `Stadium`, `CoachID`, `City`, `State`, `Division`) VALUES
(1, 'Alabama A&M', 'Bulldogs', 'Alabama A&M University', NULL, 1, 'Normal', 'Alabama', 'East'),
(2, 'Alabama State', 'Hornets', 'Alabama State University', NULL, 2, 'Montgomery', 'Alabama', 'East'),
(3, 'Alcorn State', 'Braves', 'Alcorn State University', NULL, 3, 'Lorman', 'Mississippi', 'West'),
(4, 'Arkansas-Pine Bluff', 'Golden Lions', 'University of Arkansas-Pine Bluff', NULL, 4, 'Pine Bluff', 'Arkansas', 'West'),
(5, 'Bethune-Cookman', 'Wildcats', 'Bethune-Cookman University', NULL, 5, 'Daytona Beach', 'Florida', 'East'),
(6, 'Florida A&M', 'Rattlers', 'Florida A&M University', NULL, 6, 'Tallahassee', 'Florida', 'East'),
(7, 'Grambling State', 'Tigers', 'Grambling State University', NULL, 7, 'Grambling', 'Louisiana', 'West'),
(8, 'Jackson State', 'Tigers', 'Jackson State University', NULL, 8, 'Jackson', 'Mississippi', 'East'),
(9, 'Mississippi Valley State', 'Delta Devils', 'Mississippi Valley State University', NULL, 9, 'Itta Bena', 'Mississippi', 'East'),
(10, 'Prairie View A&M', 'Panthers', 'Prairie View A&M University', NULL, 10, 'Prairie View', 'Texas', 'West'),
(11, 'Southern', 'Jaguars', 'Southern University', NULL, 11, 'Baton Rouge', 'Louisiana', 'East'),
(12, 'Texas Southern', 'Tigers', 'Texas Southern University', NULL, 12, 'Houston', 'Texas', 'West');

-- --------------------------------------------------------

--
-- Table structure for table `teamcoach`
--

CREATE TABLE `teamcoach` (
  `TeamID` int(11) NOT NULL,
  `CoachID` int(11) NOT NULL,
  `Role` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `teamcoach`
--

INSERT INTO `teamcoach` (`TeamID`, `CoachID`, `Role`) VALUES
(1, 1, 'Head Coach'),
(1, 13, 'Offensive Coordinator'),
(1, 14, 'Defensive Coordinator'),
(1, 15, 'Assistant Coach'),
(2, 2, 'Head Coach'),
(2, 16, 'Offensive Coordinator'),
(2, 17, 'Defensive Coordinator'),
(2, 18, 'Assistant Coach'),
(3, 3, 'Head Coach'),
(3, 19, 'Offensive Coordinator'),
(3, 20, 'Defensive Coordinator'),
(3, 21, 'Assistant Coach'),
(4, 4, 'Head Coach'),
(4, 22, 'Offensive Coordinator'),
(4, 23, 'Defensive Coordinator'),
(4, 24, 'Assistant Coach'),
(5, 5, 'Head Coach'),
(5, 25, 'Offensive Coordinator'),
(5, 26, 'Defensive Coordinator'),
(5, 27, 'Assistant Coach'),
(6, 6, 'Head Coach'),
(6, 28, 'Offensive Coordinator'),
(6, 29, 'Defensive Coordinator'),
(6, 30, 'Assistant Coach'),
(7, 7, 'Head Coach'),
(7, 31, 'Offensive Coordinator'),
(7, 32, 'Defensive Coordinator'),
(7, 33, 'Assistant Coach'),
(8, 8, 'Head Coach'),
(8, 34, 'Offensive Coordinator'),
(8, 35, 'Defensive Coordinator'),
(8, 36, 'Assistant Coach'),
(9, 9, 'Head Coach'),
(9, 37, 'Offensive Coordinator'),
(9, 38, 'Defensive Coordinator'),
(9, 39, 'Assistant Coach'),
(10, 10, 'Head Coach'),
(10, 40, 'Offensive Coordinator'),
(10, 41, 'Defensive Coordinator'),
(10, 42, 'Assistant Coach'),
(11, 11, 'Head Coach'),
(11, 43, 'Offensive Coordinator'),
(11, 44, 'Defensive Coordinator'),
(11, 45, 'Assistant Coach'),
(12, 12, 'Head Coach'),
(12, 46, 'Offensive Coordinator'),
(12, 47, 'Defensive Coordinator'),
(12, 48, 'Assistant Coach');

-- --------------------------------------------------------

--
-- Table structure for table `teamstats`
--

CREATE TABLE `teamstats` (
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
-- Dumping data for table `teamstats`
--

INSERT INTO `teamstats` (`TeamStatID`, `GameID`, `TeamID`, `TotalPoints`, `TotalYards`, `Turnovers`, `Penalties`, `TimeOfPossession`) VALUES
(1, 101, 9, 90, 362, 0, 0, '0'),
(2, 101, 9, 72, 1010, 3, 0, '0'),
(3, 101, 11, 108, 497, 1, 0, '0'),
(4, 102, 5, 66, 187, 0, 0, '0'),
(5, 102, 7, 72, 193, 0, 0, '0'),
(6, 103, 2, 60, 660, 0, 0, '0'),
(7, 103, 11, 78, 240, 0, 0, '0'),
(8, 104, 4, 126, 465, 0, 0, '0'),
(9, 104, 9, 54, 433, 0, 0, '0'),
(10, 106, 4, 114, 133, 0, 0, '0'),
(11, 106, 8, 84, 389, 0, 0, '0'),
(12, 107, 6, 126, 475, 1, 0, '0'),
(13, 107, 10, 102, 454, 2, 0, '0'),
(14, 108, 7, 96, 420, 1, 0, '0'),
(15, 108, 9, 60, 328, 2, 0, '0'),
(16, 109, 2, 90, 620, 4, 0, '0'),
(17, 109, 5, 114, 206, 0, 0, '0'),
(18, 110, 6, 78, 342, 0, 0, '0'),
(19, 110, 8, 78, 445, 0, 0, '0'),
(20, 111, 5, 120, 321, 0, 0, '0'),
(21, 111, 9, 108, 173, 0, 0, '0'),
(22, 112, 2, 78, 443, 0, 0, '0'),
(23, 112, 7, 132, 126, 0, 0, '0'),
(24, 113, 5, 120, 321, 0, 0, '0'),
(25, 113, 9, 60, 529, 2, 0, '0'),
(26, 114, 6, 84, 280, 2, 0, '0'),
(27, 114, 8, 114, 294, 0, 0, '0'),
(28, 115, 4, 66, 518, 2, 0, '0'),
(29, 115, 10, 90, 424, 0, 0, '0'),
(30, 116, 1, 108, 0, 0, 0, '0'),
(31, 116, 3, 60, 465, 1, 0, '0'),
(32, 117, 8, 102, 455, 1, 0, '0'),
(33, 117, 10, 66, 444, 2, 0, '0'),
(34, 120, 1, 120, 178, 0, 0, '0'),
(35, 120, 6, 102, 252, 0, 0, '0'),
(36, 121, 3, 96, 460, 1, 0, '0'),
(37, 121, 7, 78, 105, 0, 0, '0'),
(38, 122, 5, 66, 136, 0, 0, '0'),
(39, 122, 10, 90, 579, 2, 0, '0'),
(40, 123, 2, 132, 252, 0, 0, '0'),
(41, 123, 9, 66, 310, 1, 0, '0'),
(42, 124, 4, 96, 877, 3, 0, '0'),
(43, 124, 8, 78, 177, 0, 0, '0'),
(44, 200, 1, 96, 202, 0, 0, '0'),
(45, 200, 2, 84, 876, 2, 0, '0'),
(46, 201, 3, 90, 114, 0, 0, '0'),
(47, 201, 4, 102, 407, 1, 0, '0'),
(48, 202, 5, 126, 551, 0, 0, '0'),
(49, 202, 6, 84, 287, 0, 0, '0'),
(50, 203, 7, 90, 83, 0, 0, '0'),
(51, 203, 8, 84, 115, 0, 0, '0'),
(52, 204, 9, 114, 661, 0, 0, '0'),
(53, 204, 10, 90, 362, 0, 0, '0'),
(65, 101, 9, 72, 1010, 3, 0, '0'),
(66, 101, 11, 108, 497, 1, 0, '0'),
(67, 102, 5, 66, 187, 0, 0, '0'),
(68, 102, 7, 72, 193, 0, 0, '0'),
(69, 103, 2, 60, 660, 0, 0, '0'),
(70, 103, 11, 78, 240, 0, 0, '0'),
(71, 104, 4, 126, 465, 0, 0, '0'),
(72, 104, 9, 54, 433, 0, 0, '0'),
(73, 106, 4, 114, 133, 0, 0, '0'),
(74, 106, 8, 84, 389, 0, 0, '0'),
(75, 107, 6, 126, 475, 1, 0, '0'),
(76, 107, 10, 102, 454, 2, 0, '0'),
(77, 108, 7, 96, 420, 1, 0, '0'),
(78, 108, 9, 60, 328, 2, 0, '0'),
(79, 109, 2, 90, 620, 4, 0, '0'),
(80, 109, 5, 114, 206, 0, 0, '0'),
(81, 110, 6, 78, 342, 0, 0, '0'),
(82, 110, 8, 78, 445, 0, 0, '0'),
(83, 111, 5, 120, 321, 0, 0, '0'),
(84, 111, 9, 108, 173, 0, 0, '0'),
(85, 112, 2, 78, 443, 0, 0, '0'),
(86, 112, 7, 132, 126, 0, 0, '0'),
(87, 113, 5, 120, 321, 0, 0, '0'),
(88, 113, 9, 60, 529, 2, 0, '0'),
(89, 114, 6, 84, 280, 2, 0, '0'),
(90, 114, 8, 114, 294, 0, 0, '0'),
(91, 115, 4, 66, 518, 2, 0, '0'),
(92, 115, 10, 90, 424, 0, 0, '0'),
(93, 116, 1, 108, 0, 0, 0, '0'),
(94, 116, 3, 60, 465, 1, 0, '0'),
(95, 117, 8, 102, 455, 1, 0, '0'),
(96, 117, 10, 66, 444, 2, 0, '0'),
(97, 120, 1, 120, 178, 0, 0, '0'),
(98, 120, 6, 102, 252, 0, 0, '0'),
(99, 121, 3, 96, 460, 1, 0, '0'),
(100, 121, 7, 78, 105, 0, 0, '0'),
(101, 122, 5, 66, 136, 0, 0, '0'),
(102, 122, 10, 90, 579, 2, 0, '0'),
(103, 123, 2, 132, 252, 0, 0, '0'),
(104, 123, 9, 66, 310, 1, 0, '0'),
(105, 124, 4, 96, 877, 3, 0, '0'),
(106, 124, 8, 78, 177, 0, 0, '0'),
(107, 200, 1, 96, 202, 0, 0, '0'),
(108, 200, 2, 84, 876, 2, 0, '0'),
(109, 201, 3, 90, 114, 0, 0, '0'),
(110, 201, 4, 102, 407, 1, 0, '0'),
(111, 202, 5, 126, 551, 0, 0, '0'),
(112, 202, 6, 84, 287, 0, 0, '0'),
(113, 203, 7, 90, 83, 0, 0, '0'),
(114, 203, 8, 84, 115, 0, 0, '0'),
(115, 204, 9, 114, 661, 0, 0, '0'),
(116, 204, 10, 90, 362, 0, 0, '0'),
(117, 301, 4, 162, 3856, 16, 0, '0'),
(118, 301, 12, 96, 4117, 21, 0, '0'),
(119, 302, 5, 174, 3747, 17, 0, '0'),
(120, 302, 12, 96, 4780, 17, 0, '0'),
(121, 303, 7, 120, 3910, 21, 0, '0'),
(122, 303, 12, 150, 3867, 20, 0, '0');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `coach`
--
ALTER TABLE `coach`
  ADD PRIMARY KEY (`CoachID`),
  ADD KEY `fk_coach_team` (`TeamID`);

--
-- Indexes for table `game`
--
ALTER TABLE `game`
  ADD PRIMARY KEY (`GameID`),
  ADD KEY `fk_game_hometeam` (`HomeTeamID`),
  ADD KEY `fk_game_awayteam` (`AwayTeamID`);

--
-- Indexes for table `player`
--
ALTER TABLE `player`
  ADD PRIMARY KEY (`PlayerID`),
  ADD KEY `fk_player_team` (`TeamID`);

--
-- Indexes for table `playerstats`
--
ALTER TABLE `playerstats`
  ADD PRIMARY KEY (`StatID`),
  ADD KEY `fk_stats_game` (`GameID`),
  ADD KEY `fk_stats_player` (`PlayerID`),
  ADD KEY `fk_stats_team` (`TeamID`);

--
-- Indexes for table `schedule`
--
ALTER TABLE `schedule`
  ADD PRIMARY KEY (`ScheduleID`),
  ADD KEY `fk_schedule_game` (`GameID`),
  ADD KEY `fk_schedule_hometeam` (`HomeTeamID`),
  ADD KEY `fk_schedule_awayteam` (`AwayTeamID`);

--
-- Indexes for table `team`
--
ALTER TABLE `team`
  ADD PRIMARY KEY (`TeamID`),
  ADD KEY `fk_team_coach` (`CoachID`);

--
-- Indexes for table `teamcoach`
--
ALTER TABLE `teamcoach`
  ADD PRIMARY KEY (`TeamID`,`CoachID`),
  ADD KEY `fk_teamcoach_coach` (`CoachID`);

--
-- Indexes for table `teamstats`
--
ALTER TABLE `teamstats`
  ADD PRIMARY KEY (`TeamStatID`),
  ADD KEY `GameID` (`GameID`),
  ADD KEY `fk_teamstats_team` (`TeamID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `player`
--
ALTER TABLE `player`
  MODIFY `PlayerID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `teamstats`
--
ALTER TABLE `teamstats`
  MODIFY `TeamStatID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=128;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `coach`
--
ALTER TABLE `coach`
  ADD CONSTRAINT `fk_coach_team` FOREIGN KEY (`TeamID`) REFERENCES `team` (`TeamID`);

--
-- Constraints for table `game`
--
ALTER TABLE `game`
  ADD CONSTRAINT `fk_game_awayteam` FOREIGN KEY (`AwayTeamID`) REFERENCES `team` (`TeamID`),
  ADD CONSTRAINT `fk_game_hometeam` FOREIGN KEY (`HomeTeamID`) REFERENCES `team` (`TeamID`),
  ADD CONSTRAINT `game_ibfk_1` FOREIGN KEY (`HomeTeamID`) REFERENCES `team` (`TeamID`),
  ADD CONSTRAINT `game_ibfk_2` FOREIGN KEY (`AwayTeamID`) REFERENCES `team` (`TeamID`);

--
-- Constraints for table `player`
--
ALTER TABLE `player`
  ADD CONSTRAINT `fk_player_team` FOREIGN KEY (`TeamID`) REFERENCES `team` (`TeamID`),
  ADD CONSTRAINT `player_ibfk_1` FOREIGN KEY (`TeamID`) REFERENCES `team` (`TeamID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `playerstats`
--
ALTER TABLE `playerstats`
  ADD CONSTRAINT `FK_Game` FOREIGN KEY (`GameID`) REFERENCES `game` (`GameID`),
  ADD CONSTRAINT `FK_Player` FOREIGN KEY (`PlayerID`) REFERENCES `player` (`PlayerID`),
  ADD CONSTRAINT `FK_Team` FOREIGN KEY (`TeamID`) REFERENCES `team` (`TeamID`),
  ADD CONSTRAINT `fk_stats_game` FOREIGN KEY (`GameID`) REFERENCES `game` (`GameID`),
  ADD CONSTRAINT `fk_stats_player` FOREIGN KEY (`PlayerID`) REFERENCES `player` (`PlayerID`),
  ADD CONSTRAINT `fk_stats_team` FOREIGN KEY (`TeamID`) REFERENCES `team` (`TeamID`),
  ADD CONSTRAINT `playerstats_ibfk_1` FOREIGN KEY (`GameID`) REFERENCES `game` (`GameID`),
  ADD CONSTRAINT `playerstats_ibfk_2` FOREIGN KEY (`PlayerID`) REFERENCES `player` (`PlayerID`),
  ADD CONSTRAINT `playerstats_ibfk_3` FOREIGN KEY (`TeamID`) REFERENCES `team` (`TeamID`);

--
-- Constraints for table `schedule`
--
ALTER TABLE `schedule`
  ADD CONSTRAINT `fk_schedule_awayteam` FOREIGN KEY (`AwayTeamID`) REFERENCES `team` (`TeamID`),
  ADD CONSTRAINT `fk_schedule_game` FOREIGN KEY (`GameID`) REFERENCES `game` (`GameID`),
  ADD CONSTRAINT `fk_schedule_hometeam` FOREIGN KEY (`HomeTeamID`) REFERENCES `team` (`TeamID`),
  ADD CONSTRAINT `schedule_ibfk_1` FOREIGN KEY (`GameID`) REFERENCES `game` (`GameID`);

--
-- Constraints for table `team`
--
ALTER TABLE `team`
  ADD CONSTRAINT `fk_team_coach` FOREIGN KEY (`CoachID`) REFERENCES `coach` (`CoachID`),
  ADD CONSTRAINT `team_ibfk_1` FOREIGN KEY (`CoachID`) REFERENCES `coach` (`CoachID`);

--
-- Constraints for table `teamcoach`
--
ALTER TABLE `teamcoach`
  ADD CONSTRAINT `fk_teamcoach_coach` FOREIGN KEY (`CoachID`) REFERENCES `coach` (`CoachID`),
  ADD CONSTRAINT `fk_teamcoach_team` FOREIGN KEY (`TeamID`) REFERENCES `team` (`TeamID`),
  ADD CONSTRAINT `teamcoach_ibfk_1` FOREIGN KEY (`TeamID`) REFERENCES `team` (`TeamID`),
  ADD CONSTRAINT `teamcoach_ibfk_2` FOREIGN KEY (`CoachID`) REFERENCES `coach` (`CoachID`);

--
-- Constraints for table `teamstats`
--
ALTER TABLE `teamstats`
  ADD CONSTRAINT `fk_teamstats_team` FOREIGN KEY (`TeamID`) REFERENCES `team` (`TeamID`),
  ADD CONSTRAINT `teamstats_ibfk_1` FOREIGN KEY (`GameID`) REFERENCES `game` (`GameID`),
  ADD CONSTRAINT `teamstats_ibfk_2` FOREIGN KEY (`TeamID`) REFERENCES `team` (`TeamID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
