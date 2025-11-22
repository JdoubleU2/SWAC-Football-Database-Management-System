<?php
require_once 'db.php';
include 'includes/header.php';

// Fetch all teams
$teamsQuery = "SELECT TeamID, Name FROM team ORDER BY Name";
$teamsRes = $conn->query($teamsQuery);

$teamsTopPlayers = [];
while ($team = $teamsRes->fetch_assoc()) {
    $teamId = $team['TeamID'];

    $topQ = "
    SELECT p.PlayerID, p.Name, SUM(ps.TDs) AS TotalTDs
    FROM player p
    JOIN playerstats ps ON p.PlayerID = ps.PlayerID
    WHERE p.TeamID = $teamId
    GROUP BY p.PlayerID
    ORDER BY TotalTDs DESC
    LIMIT 3
    ";
    $topRes = $conn->query($topQ);

    $topPlayers = [];
    while ($p = $topRes->fetch_assoc()) {
        $topPlayers[] = $p;
    }

    $teamsTopPlayers[] = [
        'TeamID' => $teamId,
        'TeamName' => $team['Name'],
        'TopPlayers' => $topPlayers
    ];
}
?>

<style>
.container { display: flex; gap: 2em; }
.teams-list { width: 300px; }
.teams-list h2 { margin-bottom: .3em; }
.teams-list ul { list-style:none; padding-left: 0; }
.teams-list li { margin-bottom: .5em; }
.teams-list a { cursor:pointer; color: #0275d8; text-decoration: underline; }
.teams-list a.active { font-weight: bold; color: #d9534f; text-decoration: none; }
#playerStats { flex-grow: 1; min-width: 400px; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: center; }
th { background-color: #f5f5f5; }
</style>

<div class="container">
    <div class="teams-list">
        <h1>Touchdown Achievers</h1>
        <?php foreach ($teamsTopPlayers as $team): ?>
            <h2><?= htmlspecialchars($team['TeamName']) ?></h2>
            <ul>
                <?php foreach ($team['TopPlayers'] as $player): ?>
                    <li>
                        <a href="#" class="player-link" data-pid="<?= $player['PlayerID'] ?>">
                            <?= htmlspecialchars($player['Name']) ?> (<?= $player['TotalTDs'] ?> TDs)
                        </a>
                    </li>
                <?php endforeach; ?>
            </ul>
        <?php endforeach; ?>
    </div>
    <div id="playerStats">
        <p>Select a player to see stats.</p>
    </div>
</div>

<script>
document.querySelectorAll('.player-link').forEach(link => {
    link.addEventListener('click', function(e) {
        e.preventDefault();
        document.querySelectorAll('.player-link').forEach(l => l.classList.remove('active'));
        this.classList.add('active');
        const pid = this.dataset.pid;

        fetch('playerstat_ajax.php?player_id=' + pid)
        .then(res => res.text())
        .then(html => {
            document.getElementById('playerStats').innerHTML = html;
        });
    });
});
</script>

<?php include 'includes/footer.php'; ?>
