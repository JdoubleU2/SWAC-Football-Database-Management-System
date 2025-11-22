<?php include 'db.php'; ?>
<?php include 'includes/header.php'; ?>

<?php
if (isset($_GET['id'])) {
    $team_id = intval($_GET['id']);

    // Team Info
    $teamSql = "SELECT * FROM Team WHERE TeamID=$team_id";
    $teamResult = $conn->query($teamSql);

    if ($teamResult->num_rows > 0) {
        $team = $teamResult->fetch_assoc();
        echo "<h2>" . htmlspecialchars($team['Name']) . " (" . htmlspecialchars($team['Mascot']) . ")</h2>";
        echo "<p>Location: " . htmlspecialchars($team['City']) . ", " . htmlspecialchars($team['State']) . "</p>";
        echo "<p>Stadium: " . htmlspecialchars($team['Stadium']) . "</p>";

        // Coach Info
        $coachSql = "SELECT * FROM Coach WHERE CoachID = " . intval($team['CoachID']);
        $coachResult = $conn->query($coachSql);
        if ($coachResult->num_rows > 0) {
            $coach = $coachResult->fetch_assoc();
            echo "<h3>Coach: " . htmlspecialchars($coach['Name']) . "</h3>";
            echo "<p>Role: " . htmlspecialchars($coach['Role']) . "</p>";
            echo "<p>Wins: " . intval($coach['RecordWins']) . " | Losses: " . intval($coach['RecordLosses']) . "</p>";
        }

        // Players
        $playerSql = "SELECT PlayerID, Name, Position, JerseyNumber, Year FROM Player WHERE TeamID=$team_id ORDER BY JerseyNumber";
        $playerResult = $conn->query($playerSql);
        if ($playerResult->num_rows > 0) {
            echo "<h3>Players</h3><ul>";
            while ($player = $playerResult->fetch_assoc()) {
                echo '<li><a href="player.php?id=' . $player['PlayerID'] . '">#' . intval($player['JerseyNumber']) . ' ' .
                     htmlspecialchars($player['Name']) . " (" . htmlspecialchars($player['Position']) . ") - " .
                     htmlspecialchars($player['Year']) . "</a></li>";
            }
            echo "</ul>";
        } else {
            echo "<p>No players found.</p>";
        }
    } else {
        echo "<p>Team not found.</p>";
    }
} else {
    echo "<p>No team selected.</p>";
}
?>

<?php include 'includes/footer.php'; ?>
