<?php
require_once 'db.php';

$filter = $_GET['filter'] ?? 'upcoming';
$startDate = $_GET['startdate'] ?? '';
$endDate = $_GET['enddate'] ?? '';
$today = date('Y-m-d');
$whereClause = '';

if (!empty($startDate) && !empty($endDate)) {
    // Validate and enforce date limits as needed
    $whereClause = "WHERE s.Date BETWEEN '$startDate' AND '$endDate'";
} else {
    switch ($filter) {
        case 'lastweek':
            $startDate = date('Y-m-d', strtotime('last week monday'));
            $endDate = date('Y-m-d', strtotime('last week sunday'));
            $whereClause = "WHERE s.Date BETWEEN '$startDate' AND '$endDate'";
            break;
        case 'lastmonth':
            $startDate = date('Y-m-01', strtotime('first day of last month'));
            $endDate = date('Y-m-t', strtotime('last day of last month'));
            $whereClause = "WHERE s.Date BETWEEN '$startDate' AND '$endDate'";
            break;
        case 'upcoming':
        default:
            $whereClause = "WHERE s.Date >= '$today'";
            break;
    }
}

$sql = "
SELECT s.*, 
       ht.Name AS HomeTeamName,
       at.Name AS AwayTeamName
FROM schedule s
JOIN team ht ON s.HomeTeamID = ht.TeamID
JOIN team at ON s.AwayTeamID = at.TeamID
$whereClause
ORDER BY s.Date, s.Time";

$result = $conn->query($sql);

if (!$result) {
    die('Query failed: ' . $conn->error);
}

include 'includes/header.php';

echo '<h1>Schedule</h1>';

// Date range form and tabs
echo '<form method="GET" action="">';
echo 'Start Date: <input type="date" name="startdate" value="' . htmlspecialchars($startDate) . '"> ';
echo 'End Date: <input type="date" name="enddate" value="' . htmlspecialchars($endDate) . '"> ';
echo '<input type="submit" value="Filter">';
echo '</form>';

echo '<div class="tabs">';
$tabs = ['upcoming' => 'Upcoming', 'lastweek' => 'Last Week', 'lastmonth' => 'Last Month'];
foreach ($tabs as $key => $label) {
    $activeClass = ($filter == $key && empty($startDate) && empty($endDate)) ? 'active' : '';
    echo "<a href=\"?filter=$key\" class=\"$activeClass\">$label</a> ";
}
echo '</div>';

echo '<table border="1" cellpadding="5" cellspacing="0">';
echo '<tr><th>Date</th><th>Time</th><th>Home Team</th><th>Away Team</th><th>Location</th><th>Status</th></tr>';

while ($row = $result->fetch_assoc()) {
    echo '<tr>';
    echo '<td>' . htmlspecialchars($row['Date']) . '</td>';
    echo '<td>' . htmlspecialchars($row['Time']) . '</td>';
    echo '<td>' . htmlspecialchars($row['HomeTeamName']) . '</td>';
    echo '<td>' . htmlspecialchars($row['AwayTeamName']) . '</td>';
    echo '<td>' . htmlspecialchars($row['Location']) . '</td>';
    echo '<td>' . htmlspecialchars($row['GameStatus']) . '</td>';
    echo '</tr>';
}

echo '</table>';

include 'includes/footer.php';
?>
