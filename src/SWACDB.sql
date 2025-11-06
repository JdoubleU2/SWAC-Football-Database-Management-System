-- Create Database and Use It
CREATE DATABASE SWACFootball;
USE SWACFootball;

-- Coach Table
CREATE TABLE Coach (
  CoachID INT PRIMARY KEY,
  Name VARCHAR(100),
  Role VARCHAR(50),
  TeamID INT,
  StartDate DATE,
  RecordWins INT,
  RecordLosses INT
);

-- Team Table
CREATE TABLE Team (
  TeamID INT PRIMARY KEY,
  Name VARCHAR(100),
  Mascot VARCHAR(50),
  School VARCHAR(100),
  Stadium VARCHAR(100),
  CoachID INT,
  City VARCHAR(100),
  State VARCHAR(50),
  FOREIGN KEY (CoachID) REFERENCES Coach(CoachID)
);

-- Player Table
CREATE TABLE Player (
  PlayerID INT PRIMARY KEY,
  Name VARCHAR(100),
  TeamID INT,
  Position VARCHAR(50),
  JerseyNumber INT CHECK (JerseyNumber BETWEEN 0 AND 99),
  Year VARCHAR(10),
  Height DECIMAL(5,2),
  Weight DECIMAL(5,2),
  Birthdate DATE,
  Hometown VARCHAR(100),
  HighSchool VARCHAR(100),
  FOREIGN KEY (TeamID) REFERENCES Team(TeamID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

DELIMITER $$

CREATE TRIGGER CheckPlayerAgeBeforeInsert
BEFORE INSERT ON Player
FOR EACH ROW
BEGIN
  IF (TIMESTAMPDIFF(YEAR, NEW.Birthdate, CURDATE()) < 18) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Player must be at least 18 years old.';
  END IF;
END$$

CREATE TRIGGER CheckPlayerAgeBeforeUpdate
BEFORE UPDATE ON Player
FOR EACH ROW
BEGIN
  IF (TIMESTAMPDIFF(YEAR, NEW.Birthdate, CURDATE()) < 18) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Player must be at least 18 years old.';
  END IF;
END$$

DELIMITER ;

-- Game Table
CREATE TABLE Game (
  GameID INT PRIMARY KEY,
  Date DATE,
  HomeTeamID INT,
  AwayTeamID INT,
  Stadium VARCHAR(100),
  Attendance INT,
  SeasonYear INT,
  FOREIGN KEY (HomeTeamID) REFERENCES Team(TeamID),
  FOREIGN KEY (AwayTeamID) REFERENCES Team(TeamID)
);

-- Schedule Table
CREATE TABLE Schedule (
  ScheduleID INT PRIMARY KEY,
  GameID INT,
  Week INT,
  Date DATE,
  Time TIME,
  Broadcaster VARCHAR(100),
  FOREIGN KEY (GameID) REFERENCES Game(GameID)
);

DELIMITER $$

CREATE TRIGGER CheckTeamScheduleBeforeInsert 
BEFORE INSERT ON Schedule
FOR EACH ROW
BEGIN
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
END$$
DELIMITER ;

-- PlayerStats Table
CREATE TABLE PlayerStats (
  StatID INT PRIMARY KEY,
  GameID INT,
  PlayerID INT,
  TeamID INT,
  PassingYards INT,
  RushingYards INT,
  ReceivingYards INT,
  TDs INT,
  Interceptions INT,
  Tackles INT,
  Sacks INT,
  FOREIGN KEY (GameID) REFERENCES Game(GameID),
  FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID),
  FOREIGN KEY (TeamID) REFERENCES Team(TeamID)
);

-- TeamStats Table
CREATE TABLE TeamStats (
  TeamStatID INT PRIMARY KEY,
  GameID INT,
  TeamID INT,
  TotalPoints INT,
  TotalYards INT,
  Turnovers INT,
  Penalties INT,
  TimeOfPossession VARCHAR(20),
  FOREIGN KEY (GameID) REFERENCES Game(GameID),
  FOREIGN KEY (TeamID) REFERENCES Team(TeamID)
);

-- Example team inserts (see previous response for full SWAC list):
INSERT INTO Team (TeamID, Name, Mascot, School, Stadium, CoachID, City, State) VALUES
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
