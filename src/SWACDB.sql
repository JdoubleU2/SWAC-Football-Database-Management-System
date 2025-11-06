-- Create Database
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
  JerseyNumber INT,
  Year VARCHAR(10),
  Height DECIMAL(5,2),
  Weight DECIMAL(5,2),
  Birthdate DATE,
  Hometown VARCHAR(100),
  HighSchool VARCHAR(100),
  FOREIGN KEY (TeamID) REFERENCES Team(TeamID)
);

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
