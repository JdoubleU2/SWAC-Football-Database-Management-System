<!DOCTYPE html>
<html lang="en">
    
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="css/style.css" />
</head>
<body>

<header>
    <div class="logo">
         <a href="index.php">
            <img src="css/logo_main.svg" alt="SWAC Football Logo" style="height:50px;">
        </a>
    </div>
    <h1>SWAC Football</h1>
    <nav>
        <a href="index.php">Home</a> |
        <a href="teams.php">Teams</a> |
        <a href="coach.php">Coaches</a> |   
          <a href="player.php">Player</a> |
        <a href="schedule.php">Schedule</a> |
        <a href="stats.php">Stats</a>

        <div class="search-container" style="position:relative; display:inline-block; margin-left:10px;">
  <input 
     type="text" 
     id="searchBox" 
     placeholder="Search players or teams"
     autocomplete="off"
     style="padding:5px 30px 5px 10px; border-radius:4px; border:1px solid #ccc;"
  />
  <span style="position:absolute; right:8px; top:6px; pointer-events:none;">🔍</span>

  <div id="searchResults" 
       style="display:none; position:absolute; background:#fff; border:1px solid #ccc; width:100%; max-height:200px; overflow-y:auto; z-index:1000;">
  </div>
</div>

<script>
document.getElementById('searchBox').addEventListener('input', function() {
  const query = this.value.trim();
  if (query.length >= 4) {
    fetch('search_ajax.php?q=' + encodeURIComponent(query))
      .then(res => res.json())
      .then(data => {
        const resultsDiv = document.getElementById('searchResults');
        resultsDiv.innerHTML = '';
        if (data.length === 0) {
          resultsDiv.innerHTML = '<div style="padding:8px; font-style: italic;">No results found</div>';
        } else {
          data.forEach(item => {
            const div = document.createElement('div');
            div.style.padding = '8px';
            div.style.cursor = 'pointer';
            div.textContent = item.type + ': ' + item.name;
            div.onclick = () => { window.location.href = item.url; }
            resultsDiv.appendChild(div);
          });
        }
        resultsDiv.style.display = 'block';
      }).catch(e => {
        console.error('Search fetch error:', e);
      });
  } else {
    document.getElementById('searchResults').style.display = 'none';
  }
});

// Close results dropdown when clicking outside
document.addEventListener('click', function(e) {
  const resultsDiv = document.getElementById('searchResults');
  const searchBox = document.getElementById('searchBox');
  if (!searchBox.contains(e.target) && !resultsDiv.contains(e.target)) {
    resultsDiv.style.display = 'none';
  }
});
</script>




</div>


        
    </nav>
</header>
<main>
