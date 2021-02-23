<?php
header("Access-Control-Allow-Origin: http://localhost:3000");
header("Access-Control-Allow-Headers: Content-Type");
$host = "db_cw_mySQLcontainer_1"; 
$user = "root"; 
$password = "team11"; 
$dbname = "MovieLens"; 

$connection = mysqli_connect($host, $user, $password,$dbname)
        or die('Error connecting to MySQL server.' . mysqli_error());

$offset = isset($_GET['offset']) ? $_GET['offset'] : 0;

$search = "";
$genres = "";
$order_by = 0;

if (isset($_GET['genres'])) {
  $genres = json_decode($_GET['genres']);
  $genres = implode("\r,",$genres)."\r";
}

if (isset($_GET['search'])) {
  $search = $_GET['search'].'%';
}

if (isset($_GET['sort'])) {
  $order_by = (int) $_GET['sort'];
}

$movieID_query = 'CALL getMovieIDs(10, ?, ?, ?, ?)';
$count_query = 'CALL countMovieIDs(?, ?)';
$movie_data_query = "CALL getMoviesInfo(?, ?)";

$movie_data_stmt = mysqli_prepare($connection, $movie_data_query);

$movieID_stmt = mysqli_prepare($connection, $movieID_query);
$count_stmt = mysqli_prepare($connection, $count_query);

mysqli_stmt_bind_param($movieID_stmt, "issi", $offset, $genres, $search, $order_by);
mysqli_stmt_bind_param($count_stmt, "ss", $genres, $search);

mysqli_stmt_execute($movieID_stmt);

$movieID_result = (mysqli_stmt_get_result($movieID_stmt));
$movies_data = array();
while ($row = mysqli_fetch_row($movieID_result)) {
  $movies_data[] = $row[0];
}
mysqli_next_result($connection);

$movieIDs = implode(",",$movies_data);

mysqli_stmt_bind_param($movie_data_stmt, "si", $movieIDs, $order_by);
mysqli_stmt_execute($movie_data_stmt);
$movie_data_result = (mysqli_stmt_get_result($movie_data_stmt));
$movie_data = mysqli_fetch_all($movie_data_result, MYSQLI_ASSOC);

mysqli_next_result($connection);

mysqli_stmt_execute($count_stmt);
$count_result = (mysqli_stmt_get_result($count_stmt));
$count = mysqli_fetch_row($count_result);

$all_data = array(
  "total" => $count[0],
  "movies" => $movie_data
);

echo json_encode($all_data);

mysqli_close($connection);
?>