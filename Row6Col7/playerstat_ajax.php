<?php
require_once 'db.php';
$pid = intval($_GET['player_id']);

$nameQ = "SELECT Name FROM player WHERE PlayerID=$pid";
$nameRes = $conn->query($nameQ);
$nameRow = $nameRes->fetch_assoc();

$sql = "
SELECT 
    g.Date,
    ps.PassingYards,
    ps.RushingYards,
    ps.ReceivingYards,
    ps.TDs,
    ps.Interceptions,
    ps.Tackles,
    ps.Sacks
FROM playerstats ps
JOIN game g ON ps.GameID = g.GameID
WHERE ps.PlayerID = $pid
ORDER BY g.Date DESC
LIMIT 10";
$res = $conn->query($sql);

echo "<h2>Recent Stat Lines for " . htmlspecialchars($nameRow['Name']) . "</h2>";
echo "<table border='1' cellpadding='5' style='border-collapse:collapse;'>";
echo "<tr>
    <th>Date</th>
    <th>Pass Yards</th>
    <th>Rush Yards</th>
    <th>Rec Yards</th>
    <th>TD</th>
    <th>INT</th>
    <th>Tackles</th>
    <th>Sacks</th>
</tr>";
while ($row = $res->fetch_assoc()) {
    echo "<tr>
        <td>" . htmlspecialchars($row['Date']) . "</td>
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
?>
