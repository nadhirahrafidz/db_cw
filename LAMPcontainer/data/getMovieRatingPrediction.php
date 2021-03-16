<?php
header("Access-Control-Allow-Origin: http://localhost:3000");
header("Access-Control-Allow-Headers: Content-Type");
$host = "db_cw_mySQLcontainer_1"; 
$user = "admin"; 
$password = "team11"; 
$dbname = "MovieLens"; 

$connection = mysqli_connect($host, $user, $password,$dbname)
        or die('Error connecting to MySQL server.' . mysqli_error());

$movie_id;
$panel_size;
$no_of_runs = isset($_GET['runs']) ? $_GET['runs'] : 1;

if (isset($_GET['movie_id'])) {
  $movie_id = $_GET['movie_id'];
} else {
  die('Error: No movie_id specified');
}

if (isset($_GET['panel_size'])) {
  $panel_size = $_GET['panel_size'];
} else {
  die('Error: No panel_size specified');
}

$query ='CALL use5(?, ?)';

$stmt = mysqli_prepare($connection, $query);

mysqli_stmt_bind_param($stmt, "ii", $panel_size, $movie_id);

$all_data = array();

for ($x = 0; $x < $no_of_runs; $x++) {
  mysqli_stmt_execute($stmt);
  $result = mysqli_stmt_get_result($stmt);

  $all_data[] = mysqli_fetch_all($result)[0][0];
  mysqli_next_result($connection);

} 

echo json_encode($all_data);

mysqli_close($connection);
?>