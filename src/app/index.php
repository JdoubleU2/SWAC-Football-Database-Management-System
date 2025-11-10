<?php
$link = mysqli_connect("localhost", "root", "", "SWACFootball");
if (!$link) {
    die("Connection failed: " . mysqli_connect_error());
}
$sql = "SELECT * FROM tablename";
$result = mysqli_query($link, $sql);
echo "<table>";
while ($row = mysqli_fetch_assoc($result)) {
    echo "<tr>";
    foreach ($row as $col) {
        echo "<td>" . htmlspecialchars($col) . "</td>";
    }
    echo "</tr>";
}
echo "</table>";
mysqli_close($link);
?>
