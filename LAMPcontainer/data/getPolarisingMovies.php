<?php
header("Access-Control-Allow-Origin: http://localhost:3000");
header("Access-Control-Allow-Headers: Content-Type");
$host = "db_cw_mySQLcontainer_1"; 
$user = "root"; 
$password = "team11"; 
$dbname = "MovieLens"; 

$connection = mysqli_connect($host, $user, $password,$dbname)
        or die('Error connecting to MySQL server.' . mysqli_error());


$timescale = isset($_GET['timescale']) ? $_GET['timescale'] : 7;
$offset = isset($_GET['offset']) ? $_GET['offset'] : 0;
$limit = 12;
$genre = isset($_GET['genre']) ? $_GET['genre']."\r" : "";

$movieID_query = "/*qc=on*//*qc_ttl=86400*/" . 'CALL use3_polarising(?, ?, ?, ?, @pCount)';
$starttime = microtime(true);
$movieID_stmt = mysqli_prepare($connection, $movieID_query);
mysqli_stmt_bind_param($movieID_stmt, "iiis", $timescale, $offset, $limit, $genre);
mysqli_stmt_execute($movieID_stmt);

$movieID_result = mysqli_stmt_get_result($movieID_stmt);
$movies_data = mysqli_fetch_all($movieID_result, MYSQLI_ASSOC);
mysqli_next_result($connection);

$count_query = 'SELECT @pCount';
$count_stmt = mysqli_prepare($connection, $count_query);
mysqli_stmt_execute($count_stmt);
$count_result = mysqli_stmt_get_result($count_stmt);

$count = mysqli_fetch_all($count_result)[0][0];

$all_data = array(
  "total" => $count,
  "movies" => $movies_data
);

$endtime = microtime(true);
$duration = $endtime - $starttime;
//echo $duration;

echo json_encode($all_data);

mysqli_close($connection);
?>