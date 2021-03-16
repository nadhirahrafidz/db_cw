<?php
header("Access-Control-Allow-Origin: http://localhost:3000");
header("Access-Control-Allow-Headers: Content-Type");
$host = "db_cw_mySQLcontainer_1"; 
$user = "admin"; 
$password = "team11"; 
$dbname = "MovieLens"; 

$connection = mysqli_connect($host, $user, $password,$dbname)
        or die('Error connecting to MySQL server.' . mysqli_error());

$movie_ids;

if (isset($_GET['movie_id'])) {
  $movie_ids = json_decode($_GET['movie_id']);
} else {
  die('Error: No movie_id specified');
}

$query ='CALL use6(?)';

$stmt = mysqli_prepare($connection, $query);

$data = array();

foreach($movie_ids as &$movie_id) {
  mysqli_stmt_bind_param($stmt, "i", $movie_id);
  mysqli_stmt_execute($stmt);
  $result = mysqli_stmt_get_result($stmt);
  $data[] = mysqli_fetch_all($result, MYSQLI_ASSOC)[0];
  mysqli_next_result($connection);
}

$average_query ='SELECT AVG(openness) AS average_openness,
                  AVG(agreeableness) AS average_agreeableness,
                  AVG(emotional_stability) AS average_emotional_stability,
                  AVG(extraversion) AS average_extraversion,
                  AVG(conscientiousness) AS average_conscientiousness
                   FROM Personality';

$average_stmt = mysqli_prepare($connection, $average_query);

mysqli_stmt_execute($average_stmt);
$average_result = mysqli_stmt_get_result($average_stmt);
$averages = mysqli_fetch_all($average_result, MYSQLI_ASSOC)[0];

$all_data = array(
  "averages" => $averages,
  "predictions" => $data
);

echo json_encode($all_data);


mysqli_close($connection);
?>