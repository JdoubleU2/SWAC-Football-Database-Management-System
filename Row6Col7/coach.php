<?php
require_once 'db.php';

$sql = "
SELECT tc.TeamID, t.Name AS TeamName, tc.CoachID, c.Name AS CoachName, tc.Role
FROM teamcoach tc
JOIN team t ON tc.TeamID = t.TeamID
JOIN coach c ON tc.CoachID = c.CoachID
ORDER BY t.Name, c.Name";

$result = $conn->query($sql);
if (!$result) {
    die('Query failed: ' . $conn->error);
}

$teams = [];
while ($row = $result->fetch_assoc()) {
    $teamId = $row['TeamID'];
    if (!isset($teams[$teamId])) {
        $teams[$teamId] = [
            'TeamName' => $row['TeamName'],
            'Coaches' => []
        ];
    }
    $teams[$teamId]['Coaches'][] = [
        'CoachID' => $row['CoachID'],
        'CoachName' => $row['CoachName'],
        'Role' => $row['Role']
    ];
}

include 'includes/header.php';
?>

<style>
#coach-details-popup {
    position: absolute;
    background: white;
    border: 1px solid #ccc;
    padding: 15px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    z-index: 1000;
    display: none;
    max-width: 250px;
    border-radius: 4px;
}
#coach-details-popup h3 {
    margin-top: 0;
}
#coach-details-popup .close-btn {
    cursor: pointer;
    color: #888;
    float: right;
    font-weight: bold;
    font-size: 16px;
}
</style>

<h1>Coaches</h1>

<?php foreach ($teams as $teamId => $team): ?>
    <h2>
        <img src="images/mascots/<?php echo htmlspecialchars($teamId); ?>.png" alt="Mascot for <?php echo htmlspecialchars($team['TeamName']); ?>" style="width:50px; height:auto; vertical-align: middle; margin-right: 10px;">
        <?php echo htmlspecialchars($team['TeamName']); ?>
    </h2>
    <ul>
        <?php foreach ($team['Coaches'] as $coach): ?>
            <li>
                <?php if ($coach['Role'] === 'Head Coach'): ?>
                    <a href="#" class="head-coach-link" data-coach-id="<?php echo (int)$coach['CoachID']; ?>"><?php echo htmlspecialchars($coach['CoachName']); ?></a> (<?php echo htmlspecialchars($coach['Role']); ?>)
                <?php else: ?>
                    <?php echo htmlspecialchars($coach['CoachName']) . ' (' . htmlspecialchars($coach['Role']) . ')'; ?>
                <?php endif; ?>
            </li>
        <?php endforeach; ?>
    </ul>
<?php endforeach; ?>

<div id="coach-details-popup">
    <span class="close-btn" title="Close">&times;</span>
    <div id="coach-details-content"></div>
</div>

<script>
const popup = document.getElementById('coach-details-popup');
const content = document.getElementById('coach-details-content');
const closeBtn = popup.querySelector('.close-btn');

document.querySelectorAll('.head-coach-link').forEach(link => {
    link.addEventListener('click', function(e) {
        e.preventDefault();
        const coachId = this.getAttribute('data-coach-id');

        fetch('coachdetails.php?coach_id=' + coachId)
            .then(res => res.json())
            .then(data => {
                if (data.error) {
                    alert(data.error);
                    return;
                }

                content.innerHTML = `
                    <h3>${data.Name}</h3>
                    <ul>
                        <li><strong>Start Date:</strong> ${data.StartDate}</li>
                        <li><strong>Record Wins:</strong> ${data.RecordWins}</li>
                        <li><strong>Record Losses:</strong> ${data.RecordLosses}</li>
                    </ul>
                `;

                const rect = this.getBoundingClientRect();
                popup.style.top = (window.scrollY + rect.bottom + 5) + 'px';
                popup.style.left = (window.scrollX + rect.left) + 'px';
                popup.style.display = 'block';
            })
            .catch(() => alert('Failed to load coach details'));
    });
});

closeBtn.addEventListener('click', () => {
    popup.style.display = 'none';
});

document.addEventListener('click', (e) => {
    if (!popup.contains(e.target) && !e.target.classList.contains('head-coach-link')) {
        popup.style.display = 'none';
    }
});
</script>

<?php
include 'includes/footer.php';
?>
