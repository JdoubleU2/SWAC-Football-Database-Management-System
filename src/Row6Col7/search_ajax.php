<?php
require_once 'db.php';

$q = $conn->real_escape_string($_GET['q']);
if (strlen($q) < 4) {
  echo json_encode([]);
  exit;
}

$results = [];

// Search players
$playerQuery = "SELECT PlayerID, Name FROM player WHERE Name LIKE '%$q%' LIMIT 5";
$resPlayers = $conn->query($playerQuery);
while ($row = $resPlayers->fetch_assoc()) {
  $results[] = [
    'type' => 'Player',
    'name' => $row['Name'],
    'url' => 'player.php?id=' . $row['PlayerID']
  ];
}

// Search teams
$teamQuery = "SELECT TeamID, Name FROM team WHERE Name LIKE '%$q%' LIMIT 5";
$resTeams = $conn->query($teamQuery);
while ($row = $resTeams->fetch_assoc()) {
  $results[] = [
    'type' => 'Team',
    'name' => $row['Name'],
    'url' => 'team.php?id=' . $row['TeamID']
  ];
}

echo json_encode($results);
?>
