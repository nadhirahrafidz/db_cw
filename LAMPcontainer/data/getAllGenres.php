<?php
header("Access-Control-Allow-Origin: http://localhost:3000");
header("Access-Control-Allow-Headers: Content-Type");
$host = "db_cw_mySQLcontainer_1"; 
$user = "root"; 
$password = "team11"; 
$dbname = "MovieLens"; 

$connection = mysqli_connect($host, $user, $password,$dbname)
        or die('Error connecting to MySQL server.' . mysqli_error());

$genre_query = 'SELECT genre FROM Genres ORDER BY genre ASC';

$genre_stmt = mysqli_prepare($connection, $genre_query);
mysqli_stmt_execute($genre_stmt);

$genre_result = mysqli_stmt_get_result($genre_stmt);
echo json_encode(mysqli_fetch_all($genre_result, MYSQLI_NUM));

mysqli_close($connection);
?>