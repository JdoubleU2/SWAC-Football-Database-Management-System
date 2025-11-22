# SWAC Football Database Management System

> **COMP-5314 Database Management Project**  
> A database system and web application for managing SWAC (Southwestern Athletic Conference) Football data.

## 📋 Table of Contents
- [Overview](#overview)
- [Team Members](#team-members)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Database Schema](#database-schema)
- [Advanced Database Features](#advanced-database-features)
- [Project Structure](#project-structure)
- [Demo](#demo)

## 🎯 Overview

The SWAC Football Database Management System is a full-stack web application designed to manage and display comprehensive football statistics for the Southwestern Athletic Conference. The system tracks teams, players, coaches, games, schedules, and detailed player statistics across the conference.

This project demonstrates advanced database design principles, complex SQL queries, stored procedures, triggers, and a user-friendly PHP-based web interface.

## 👥 Team Members

- **[Jabin Wade](https://github.com/JdoubleU2)** (JdoubleU2)
- **[Hemnarayan Sah](https://github.com/hemzz2020)** (hemzz2020)
- **[Khaliyl Peterson](https://github.com/KhaliylP)** (KhaliylP)
- **[Kolade Shofoluwe](https://github.com/koladeshofoluwe)** (koladeshofoluwe)

## ✨ Features

### Core Functionality
- **Team Management**: View all 12 SWAC conference teams with detailed information
- **Player Statistics**: Comprehensive player profiles with stats tracking
- **Game Scheduling**: Dynamic game schedule with real-time updates
- **Coach Information**: Detailed coaching staff records for each team
- **Live Statistics**: Real-time player and team statistics
- **Search Functionality**: AJAX-powered search for players and teams
- **Responsive Design**: Mobile-friendly interface with modern CSS styling

### Database Features
- **Stored Procedures**: Automated game score calculations and record updates
- **Triggers**: Automatic validation and data integrity enforcement
- **Functions**: Custom calculations for player efficiency and statistics
- **Cursors**: Advanced data processing for complex queries
- **Constraints**: Data validation and referential integrity

## 🛠 Technology Stack

### Frontend
- **HTML5/CSS3**: Modern, responsive design
- **JavaScript**: Dynamic content loading and AJAX interactions
- **Custom CSS**: Styled components for game cards and statistics displays

### Backend
- **PHP 8.0+**: Server-side logic and database interactions
- **MySQL/MariaDB 10.4**: Relational database management
- **phpMyAdmin**: Database administration interface

### Development Environment
- **Apache/XAMPP**: Local development server
- **Git**: Version control
- **GitHub**: Repository hosting and collaboration

## 🗄 Database Schema

The database consists of **7 main tables** with complex relationships:

### Tables

1. **`team`** - SWAC conference teams
   - TeamID (PK), Name, Mascot, School, Stadium, CoachID (FK), City, State, Division

2. **`player`** - Player information
   - PlayerID (PK), Name, TeamID (FK), Position, JerseyNumber, Year, Height, Weight, Birthdate, Hometown, HighSchool

3. **`coach`** - Coaching staff
   - CoachID (PK), Name, Role, TeamID (FK), StartDate, RecordWins, RecordLosses

4. **`game`** - Game records
   - GameID (PK), Date, HomeTeamID (FK), AwayTeamID (FK), Stadium, Attendance, SeasonYear, HomeScore, AwayScore, Result

5. **`schedule`** - Detailed game scheduling
   - ScheduleID (PK), GameID (FK), Week, Date, Time, Broadcaster, Location, HomeTeamID (FK), AwayTeamID (FK), ScoreHome, ScoreAway, GameStatus, Attendance, Referee, GameDuration, Weather

6. **`playerstats`** - Player performance statistics
   - StatID (PK), GameID (FK), PlayerID (FK), TeamID (FK), PassingYards, RushingYards, ReceivingYards, TDs, Interceptions, Tackles, Sacks

7. **`teamcoach`** - Team-Coach relationship table
   - TeamID (FK), CoachID (FK), Role

### Entity Relationships

- team (1) ----< (M) player
- team (1) ----< (M) coach
- team (1) ----< (M) game (Home)
- team (1) ----< (M) game (Away)
- game (1) ----< (M) playerstats
- player (1) ----< (M) playerstats
- game (1) ---- (1) schedule
- team (M) ----< (M) coach (via teamcoach)

### Main Pages

- **`index.php`** - Home page with upcoming games and top players
- **`teams.php`** - List of all SWAC teams
- **`team.php`** - Individual team details with roster
- **`player.php`** - Player profiles and statistics
- **`coach.php`** - Coaching staff directory
- **`coachdetails.php`** - Detailed coach information
- **`schedule.php`** - Complete game schedule
- **`stats.php`** - League-wide statistics and leaders

### Search Functionality

The application includes AJAX-powered search:
- Search for players by name
- Filter statistics by team
- Find upcoming games

## 🔧 Advanced Database Features

### Stored Procedures

1. **`UpdateTeamRecord(pTeamID INT)`**  
Calculates and updates a team's win-loss record

2. **`GetPlayerTotalTDs(pPlayerID INT, OUT totalTDs INT)`**  
Returns total touchdowns for a player

3. **`UpdateGameScores()`**  
Automatically calculates game scores based on player statistics

4. **`ListUpcomingGames()`**  
Lists all upcoming games using cursor iteration

5. **`PlayersWithHighTDs(minTDs INT)`**  
Finds players exceeding a touchdown threshold

### Functions

1. **`CalcPlayerEfficiency(pPlayerID INT) RETURNS DECIMAL(5,2)`**  
Calculates player efficiency rating based on yards

2. **`AvgTackles(pPlayerID INT) RETURNS DECIMAL(5,2)`**  
Computes average tackles per game for a player

### Triggers

1. **`before_game_insert`**  
Prevents scheduling games in the past

2. **`after_game_update`**  
Automatically updates team records when game results change

3. **`after_playerstats_insert`**  
Updates player's total touchdowns after new stats are inserted

4. **`CheckPlayerAgeBeforeInsert/Update`**  
Ensures players are at least 18 years old

5. **`CheckTeamScheduleBeforeInsert`**  
Prevents teams from having multiple games in the same week

### Constraints

- **Jersey Number Check**: Validates jersey numbers between 0-99
- **Foreign Key Constraints**: Maintains referential integrity across tables
- **NOT NULL Constraints**: Ensures required fields are populated
- **Date Validation**: Enforces proper date formats and logic

## 🎥 Demo

A video demonstration of the system is available in the repository:
- **File**: `20251113142643.mp4`
- Shows the full functionality of the web application
- Demonstrates database interactions and features

# 📊 Database Statistics

- **Teams**: 12 SWAC conference teams
- **Players**: 255+ player records
- **Coaches**: 48 coaching staff members
- **Games**: 38+ scheduled games for 2025 season
- **Player Stats**: Comprehensive statistics tracking across multiple games

## 🏈 SWAC Teams Included

**East Division:**
- Alabama A&M Bulldogs
- Alabama State Hornets
- Alcorn State Braves
- Bethune-Cookman Wildcats
- Florida A&M Rattlers
- Jackson State Tigers
- Mississippi Valley State Delta Devils
- Southern Jaguars
  
**West Division:**
- Arkansas-Pine Bluff Golden Lions
- Grambling State Tigers
- Prairie View A&M Panthers
- Texas Southern Tigers

## 📝 Notes

- The database is pre-populated with sample data for the 2025 season
- Game scores are calculated automatically based on player statistics
- The system includes data validation to maintain integrity
- All dates use the format YYYY-MM-DD
- Team mascot images are stored in `images/mascots/` directory

## 📧 Contact

For questions or issues, please contact the team members through their GitHub profiles or open an issue in the repository.

---

**Course**: COMP-5314 Database Management  
**Institution**: Prairie View A&M University  
**Semester**: Fall 2025  
**Project Name**: Row6Col7 - SWAC Football Database
