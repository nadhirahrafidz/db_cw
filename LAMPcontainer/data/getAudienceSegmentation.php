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

//part 1 - getting the information for use case 4
//construct query
$query = "CALL use4(?, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9)";
//prepare the statement
$stmt = mysqli_prepare($connection, $query);
//bind parameters
mysqli_stmt_bind_param($stmt, "s", $movie_id);
//execute statement
mysqli_stmt_execute($stmt);
//get the result
$result = (mysqli_stmt_get_result($stmt));
//write a query to pull 'out' values in sql
$data_query = "SELECT @p1 as genres_string, @p2 as tags_string, @p3 as pCountMostLikely, @p4 as pCountLikely, @p5 as pCountLeastLikely, @p6 as pCountUsuallyHigh, @p7 as pCountUsuallyLow, @p8 as pTagsMostLikely, @p9 as pTagsLeastLikely";
$data_stmt = mysqli_prepare($connection, $data_query);
mysqli_stmt_execute($data_stmt);
$data_result = (mysqli_stmt_get_result($data_stmt));
$data = mysqli_fetch_all($data_result, MYSQLI_ASSOC);

echo json_encode($data);

?>