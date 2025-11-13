<?php
require_once 'db.php';

$coachId = intval($_GET['coach_id']);

$sql = "SELECT Name, StartDate, RecordWins, RecordLosses FROM coach WHERE CoachID = $coachId LIMIT 1";
$result = $conn->query($sql);

header('Content-Type: application/json');

if ($result && $result->num_rows === 1) {
    $coach = $result->fetch_assoc();
    echo json_encode($coach);
} else {
    echo json_encode(['error' => 'Coach not found']);
}
?>
