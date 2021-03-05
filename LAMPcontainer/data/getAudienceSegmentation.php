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
$movie_query = "CALL use4(?, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9)";
//prepare the statement
$movie_stmt = mysqli_prepare($connection, $movie_query);
//bind parameters
mysqli_stmt_bind_param($movie_stmt, "s", $movie_id);
//execute statement
mysqli_stmt_execute($movie_stmt);
//get the result
$movie_result = (mysqli_stmt_get_result($movie_stmt));
//write a query to pull 'out' values in sql
$query = "SELECT @p1 as genres_string, @p2 as tags_string, @p3 as pCountMostLikely, @p4 as pCountLikely, @p5 as pCountLeastLikely, @p6 as pCountUsuallyHigh, @p7 as pCountUsuallyLow, @p8 as pTagsMostLikely, @p9 as pTagsLeastLikely";
$stmt = mysqli_prepare($connection, $query);
mysqli_stmt_execute($stmt);
$result = (mysqli_stmt_get_result($stmt));
$value = mysqli_fetch_all($result, MYSQLI_ASSOC);

// part 2 for the different ratings
// $movie_query = "CALL use2(?, @p1, @p2)";
// $movie_stmt = mysqli_prepare($connection, $movie_query);
// mysqli_stmt_bind_param($movie_stmt, "s", $movie_id);
// mysqli_stmt_execute($movie_stmt);

// $movie_result = (mysqli_stmt_get_result($movie_stmt));

// $query = "SELECT @p1 as genres_string, @p2 as tags_string, @p3 as pCountMostLikely, @p4 as pCountLikely, @p5 as pCountLeastLikely, @p6 as pCountUsuallyHigh, @p7 as pCountUsuallyLow, @p8 as pTagsMostLikely, @p9 as pTagsLeastLikely";
// $stmt = mysqli_prepare($connection, $query);

// mysqli_stmt_execute($stmt);
// $result = (mysqli_stmt_get_result($stmt));
// $secondvalue = mysqli_fetch_all($result, MYSQLI_ASSOC);

//part 3 converting the genres to names
$genre_string = $value[0]["genres_string"];
$genre_string_split = explode(",", $genre_string);


$movieID_query = 'SELECT genre, genre_id FROM Genres WHERE genre_id >= ' . $genre_string_split[0] . ' AND genre_id <= ' . end($genre_string_split);

$movieID_stmt = mysqli_prepare($connection, $movieID_query);
mysqli_stmt_execute($movieID_stmt);

$resultinter = (mysqli_stmt_get_result($movieID_stmt));
$result2 = mysqli_fetch_all($resultinter, MYSQLI_NUM);






// return statement
$value['genres'] = $result2;
echo json_encode($value);

// echo json_encode(mysqli_fetch_all($result, MYSQLI_ASSOC));

?>