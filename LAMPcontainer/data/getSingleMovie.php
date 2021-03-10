<?php
header("Access-Control-Allow-Origin: http://localhost:3000");
header("Access-Control-Allow-Headers: Content-Type");
$host = "db_cw_mySQLcontainer_1"; 
$user = "root"; 
$password = "team11"; 
$dbname = "MovieLens"; 

$connection = mysqli_connect($host, $user, $password,$dbname)
        or die('Error connecting to MySQL server.' . mysqli_error());


$movie_id;
if (isset($_GET['movie_id'])) {
  $movie_id = $_GET['movie_id'];
} else {
  die('Error: No movie_id specified');
}

$movie_query = "/*qc=on*//*qc_ttl=86400*/" . "CALL getMoviesInfo(?, 0)";

$movie_stmt = mysqli_prepare($connection, $movie_query);
mysqli_stmt_bind_param($movie_stmt, "i", $movie_id);
mysqli_stmt_execute($movie_stmt);

$movie_result = (mysqli_stmt_get_result($movie_stmt));
echo json_encode(mysqli_fetch_all($movie_result, MYSQLI_ASSOC));

mysqli_close($connection);
?>