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

if (isset($_GET['movie_id'])) {
  $movie_id = $_GET['movie_id'];
} else {
  die('Error: No movie_id specified');
}

$query =  'SELECT AVG(rating) FROM Ratings 
          WHERE movie_id = ?';

$stmt = mysqli_prepare($connection, $query);

mysqli_stmt_bind_param($stmt, "i", $movie_id);


mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
$rating = mysqli_fetch_all($result)[0][0]; 

echo json_encode($rating);

mysqli_close($connection);
?>