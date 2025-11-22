<?php
require_once 'db.php';

$sql = "
SELECT t.TeamID, t.Name AS TeamName, SUM(ts.TotalPoints) AS TotalPoints
FROM team t
LEFT JOIN teamstats ts ON t.TeamID = ts.TeamID
GROUP BY t.TeamID, t.Name
ORDER BY TotalPoints DESC";

$result = $conn->query($sql);

if (!$result) {
    die('Query failed: ' . $conn->error);
}

include 'includes/header.php';

echo '<h1>Team Rankings by Total Points</h1>';

echo '<table border="1" cellpadding="5" cellspacing="0">';
echo '<tr><th>Rank</th><th>Team</th><th></th><th>Total Points</th></tr>';

$rank = 1;
while ($row = $result->fetch_assoc()) {
    $totalPoints = $row['TotalPoints'] ? $row['TotalPoints'] : 0;

    // Example: mascot image path by team ID: images/mascots/{TeamID}.png
    $mascotImg = "images/mascots/{$row['TeamID']}.png";

    echo "<tr>
        <td>{$rank}</td>
        <td>{$row['TeamName']}</td>
        <td><img src='{$mascotImg}' alt='Mascot' height='50'></td>
        <td>{$totalPoints}</td>
        </tr>";
    $rank++;
}

echo '</table>';

include 'includes/footer.php';
?>
