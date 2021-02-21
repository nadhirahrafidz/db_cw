<?php
header("Access-Control-Allow-Origin: http://localhost:3000");
header("Access-Control-Allow-Headers: Content-Type");
$host = "db_cw_mySQLcontainer_1"; 
$user = "root"; 
$password = "team11"; 
$dbname = "MovieLens"; 

$connection = mysqli_connect($host, $user, $password,$dbname)
        or die('Error connecting to MySQL server.' . mysqli_error());

$movieID_query = 'SELECT genre FROM Genres';

$movieID_stmt = mysqli_prepare($connection, $movieID_query);
mysqli_stmt_execute($movieID_stmt);

$movieID_result = (mysqli_stmt_get_result($movieID_stmt));
echo json_encode(mysqli_fetch_all($movieID_result, MYSQLI_NUM));

mysqli_close($connection);
?>