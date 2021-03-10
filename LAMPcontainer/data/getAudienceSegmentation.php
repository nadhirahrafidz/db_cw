<?php
header("Access-Control-Allow-Origin: http://localhost:3000");
header("Access-Control-Allow-Headers: Content-Type");
$host = "db_cw_mySQLcontainer_1"; 
$user = "root"; 
$password = "team11"; 
$dbname = "MovieLens"; 

$connection = mysqli_connect($host, $user, $password,$dbname)
        or die('Error connecting to MySQL server.' . mysqli_error());

$all_data = array();

$movie_id;
if (isset($_GET['movie_id'])) {
  $movie_id = $_GET['movie_id'];
} else {
  die('Error: No movie_id specified');
}

$query = "CALL use4(?)";
$stmt = mysqli_prepare($connection, $query);
mysqli_stmt_bind_param($stmt, "i", $movie_id);
mysqli_stmt_execute($stmt);
$result = (mysqli_stmt_get_result($stmt));

$all_data["overview"] = mysqli_fetch_all($result, MYSQLI_ASSOC)[0];
mysqli_next_result($connection);


$tables = array("users_already_rated", "users_not_rated", "similar_genre_ratings", "gWouldLikeTable", "gWouldLikeDidLikeTable",
"gWouldLikeDidDislikeTable", "gWouldDislikeTable", "gWouldDislikeDidDislikeTable","gWouldDislikeDidLikeTable",
"tWouldLikeTable", "tWouldLikeDidLikeTable", "tWouldLikeDidDislikeTable", "tWouldDislikeTable", "tWouldDislikeDidDislikeTable",
"tWouldDislikeDidLikeTable");

foreach ($tables as &$currentTable) {
  $query = "SELECT * FROM ".$currentTable;
  $stmt = mysqli_prepare($connection, $query);
  mysqli_stmt_execute($stmt);
  $result = (mysqli_stmt_get_result($stmt));

  $all_data[$currentTable] = mysqli_fetch_all($result, MYSQLI_ASSOC);
}

echo json_encode($all_data);

?>