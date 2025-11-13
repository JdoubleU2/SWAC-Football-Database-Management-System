<?php
include 'header.php';
require_once 'db.php';

// Fetch all teams
$teamsQuery = "SELECT TeamID, Name FROM team ORDER BY Name";
$teamsRes = $conn->query($teamsQuery);

// Get selected team, default to 0 (All Teams)
$selectedTeam = isset($_GET['team']) ? intval($_GET['team']) : 0;

// Reset result pointer for reuse
$teamsRes->data_seek(0);

// Fetch players for the selected team
$players = [];
if ($selectedTeam > 0) {
    $playerQ = "SELECT PlayerID, Name FROM player WHERE TeamID=$selectedTeam ORDER BY Name";
} else {
    $playerQ = "SELECT PlayerID, Name FROM player ORDER BY Name";
}
$playerRes = $conn->query($playerQ);
while ($row = $playerRes->fetch_assoc()) {
    $players[] = $row;
}

// Determine best player by total touchdowns for the selected team
$bestPlayerId = null;
if ($selectedTeam > 0) {
    $bestQ = "SELECT PlayerID, SUM(TDs) as TotalTDs FROM playerstats WHERE TeamID=$selectedTeam GROUP BY PlayerID ORDER BY TotalTDs DESC LIMIT 1";
    $bestRes = $conn->query($bestQ);
    if ($bestRes && $bestRow = $bestRes->fetch_assoc()) {
        $bestPlayerId = $bestRow['PlayerID'];
    }
}

// Determine selected player, fallback to best player or first player
$selectedPlayerId = isset($_GET['id']) ? intval($_GET['id']) : ($bestPlayerId ? $bestPlayerId : (count($players) > 0 ? $players[0]['PlayerID'] : 0));
?>

<h2>Players</h2>

<form method="GET" action="player.php">
    <label for="teamSelect">Filter by Team:</label>
    <select name="team" id="teamSelect" onchange="this.form.submit()">
        <option value="0"<?php if($selectedTeam === 0) echo " selected"; ?>>-- All Teams --</option>
        <?php
        while ($team = $teamsRes->fetch_assoc()) {
            $selected = ((int)$team['TeamID'] === $selectedTeam) ? ' selected' : '';
            echo "<option value='{$team['TeamID']}'$selected>" . htmlspecialchars($team['Name']) . "</option>";
        }
        ?>
    </select>
    <noscript><input type="submit" value="Filter"></noscript>
</form>

<div style="display:flex; gap:20px; align-items:flex-start; margin-top:20px;">
    <div style="flex:1;">
        <?php if (count($players) > 0): ?>
            <ul>
                <?php foreach ($players as $player): ?>
                    <li<?php echo ($player['PlayerID'] === $selectedPlayerId) ? ' style="font-weight:bold;"' : ''; ?>>
                        <a href="player.php?team=<?php echo $selectedTeam; ?>&id=<?php echo $player['PlayerID']; ?>">
                            <?php echo htmlspecialchars($player['Name']); ?>
                        </a>
                    </li>
                <?php endforeach; ?>
            </ul>
        <?php else: ?>
            <p>No players found for this team.</p>
        <?php endif; ?>
    </div>
    
    <div style="flex:1;">
        <?php
        if ($selectedPlayerId) {
            $sql = "SELECT * FROM player WHERE PlayerID=$selectedPlayerId";
            $playerRes = $conn->query($sql);
            if ($playerRes && $player = $playerRes->fetch_assoc()) {
                echo "<h3>Stats for " . htmlspecialchars($player['Name']) . "</h3>";
                $statsSql = "SELECT * FROM playerstats WHERE PlayerID=$selectedPlayerId ORDER BY GameID";
                $statsRes = $conn->query($statsSql);
                if ($statsRes->num_rows > 0) {
                    echo "<table border='1' cellpadding='5' cellspacing='0'>
                        <tr>
                          <th>GameID</th>
                          <th>Passing Yards</th>
                          <th>Rushing Yards</th>
                          <th>Receiving Yards</th>
                          <th>TDs</th>
                          <th>Interceptions</th>
                          <th>Tackles</th>
                          <th>Sacks</th>
                        </tr>";
                    while ($row = $statsRes->fetch_assoc()) {
                        echo "<tr>
                          <td>" . htmlspecialchars($row['GameID']) . "</td>
                          <td>" . htmlspecialchars($row['PassingYards']) . "</td>
                          <td>" . htmlspecialchars($row['RushingYards']) . "</td>
                          <td>" . htmlspecialchars($row['ReceivingYards']) . "</td>
                          <td>" . htmlspecialchars($row['TDs']) . "</td>
                          <td>" . htmlspecialchars($row['Interceptions']) . "</td>
                          <td>" . htmlspecialchars($row['Tackles']) . "</td>
                          <td>" . htmlspecialchars($row['Sacks']) . "</td>
                        </tr>";
                    }
                    echo "</table>";
                } else {
                    echo "<p>No stats available for this player.</p>";
                }
            } else {
                echo "<p>Player not found.</p>";
            }
        }
        ?>
    </div>
</div>

<?php include 'footer.php'; ?>
