<?php
require_once 'db.php';
include 'includes/header.php';

// Today's date for filtering games
$today = date('Y-m-d');

// Fetch upcoming games (without Time column)
$gamesQ = "
SELECT g.GameID, g.Date, t1.Name AS HomeTeam, t2.Name AS AwayTeam, 
       t1.TeamID AS HomeTeamID, t2.TeamID AS AwayTeamID, g.Stadium
FROM game g
JOIN team t1 ON g.HomeTeamID = t1.TeamID
JOIN team t2 ON g.AwayTeamID = t2.TeamID
WHERE g.Date >= '$today'
ORDER BY g.Date ASC
LIMIT 5";
$gamesRes = $conn->query($gamesQ);
if (!$gamesRes) {
    die("Query for games failed: " . $conn->error);
}

// Fetch top 3 TD scorers league-wide
$topPlayersQ = "
SELECT p.Name, t.Name AS TeamName, SUM(ps.TDs) AS TotalTDs
FROM playerstats ps
JOIN player p ON p.PlayerID = ps.PlayerID
JOIN team t ON p.TeamID = t.TeamID
GROUP BY p.PlayerID
ORDER BY TotalTDs DESC
LIMIT 3";
$topPlayersRes = $conn->query($topPlayersQ);
if (!$topPlayersRes) {
    die("Query for top players failed: " . $conn->error);
}
?>

<style>
.game-cards {
  display: flex;
  flex-direction: column;
  gap: 24px;
  max-width: 900px;
  margin: 30px auto;
}
.game-card {
  display: flex;
  align-items: center;
  background: #6a6060ff;
  color: #fff;
  border-radius: 10px;
  padding: 18px 24px;
  box-shadow: 0 2px 8px rgba(57, 58, 52, 0.1);
  gap: 30px;
  min-height: 90px;
}
.game-dateblock {
  width: 70px;
  text-align: center;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
.game-date {
  font-size: 1.2em;
  font-weight: bold;
}
.game-type {
  font-size: .95em;
  background: rgba(41, 47, 43, 1);
  padding: 2px 8px;
  border-radius: 6px;
  margin: 8px 0 0 0;
}
.game-midblock {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 5px;
}
.game-mascots-names {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.13em;
  font-weight: 500;
  white-space: nowrap;
  min-height: 40px;
}
.game-mascot {
  height: 36px;
  width: auto;
  vertical-align: middle;
  background: #fff;
  border-radius: 4px;
}
.vs-text {
  margin: 0 7px;
  font-weight: bold;
  font-size: 1em;
  color: #bbb;
}
.game-team-name {
  margin: 0 3px;
}
.game-actions {
  display: flex;
  gap: 18px;
  align-items: center;
  min-width: 110px;
  justify-content: flex-end;
}
.game-icon {
  font-size: 1.3em;
  background: #222;
  border-radius: 50%;
  padding: 10px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
.clock-icon {
  margin-right: 6px;
}
</style>

<h1>Welcome to SWAC Football</h1>

<section>
  <h2>Top Players This Season (Touchdowns)</h2>
  <ol>
    <?php while ($player = $topPlayersRes->fetch_assoc()): ?>
    <li>
      <?= htmlspecialchars($player['Name']) ?> (<?= htmlspecialchars($player['TeamName']) ?>) - <?= $player['TotalTDs'] ?> TDs
    </li>
    <?php endwhile; ?>
  </ol>
</section>

<section>
  <div class="games-header">
 <a href="schedule.php"> <h2  class="section-title">Upcoming Games </h2></a>
</div>




  <div class="game-cards">
    <?php while ($game = $gamesRes->fetch_assoc()): ?>
    <div class="game-card">
      <div class="game-dateblock">
        <div class="game-date"><?= strtoupper(date('M d', strtotime($game['Date']))) ?></div>
        <div class="game-type">FB</div>
      </div>
      <div class="game-midblock">
        <div class="game-time-loc">
          <span class="clock-icon">&#128337;</span>
          TBD CT
        </div>
        <div class="game-mascots-names">
          <img class="game-mascot" src="images/mascots/<?= $game['HomeTeamID'] ?>.png" alt="<?= htmlspecialchars($game['HomeTeam']) ?>">
          <span class="game-team-name"><?= htmlspecialchars($game['HomeTeam']) ?></span>
          <span class="vs-text">vs</span>
          <img class="game-mascot" src="images/mascots/<?= $game['AwayTeamID'] ?>.png" alt="<?= htmlspecialchars($game['AwayTeam']) ?>">
          <span class="game-team-name"><?= htmlspecialchars($game['AwayTeam']) ?></span>
        </div>
      </div>
      <div class="game-actions">
         
      </div>
    </div>
    <?php endwhile; ?>
  </div>
</section>

<?php include 'includes/footer.php'; ?>
