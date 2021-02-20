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

$movies_stmt;
$count_stmt;

if (isset($_GET['search'])) {
  $temp = $_GET['search'].'%';
  
  $movies_query = 'SELECT Movies.movie_id, Movies.title, GROUP_CONCAT(Genres.genre) AS genres 
  FROM Movies, Genres WHERE Movies.title LIKE ? GROUP BY Movies.movie_id LIMIT 10 OFFSET ?';
  $movies_stmt = mysqli_prepare($connection, $movies_query);
  mysqli_stmt_bind_param($movies_stmt, "si", $temp, $offset);

  $count_query = 'SELECT COUNT(*) AS Total FROM Movies WHERE title LIKE ?';
  $count_stmt = mysqli_prepare($connection, $count_query);
  mysqli_stmt_bind_param($count_stmt, "s", $temp);

} else {
  $movies_query = 'SELECT Movies.movie_id, Movies.title, GROUP_CONCAT(Genres.genre) AS genres 
  FROM Movies, Genres GROUP BY Movies.movie_id LIMIT 10 OFFSET ?';
  // $movies_query = 'SELECT Movies.movie_id, Movies.title, GROUP_CONCAT(Genres.genre) AS genres, GROUP_CONCAT(Stars.star_name) as stars
  // FROM Movies, Genres, Stars GROUP BY Movies.movie_id LIMIT 10 OFFSET ?';

  // SELECT Movies.movie_id, Movies.title,
  // GROUP_CONCAT(Stars.star_name)
  // FROM Movies
  // INNER JOIN Stars
  // GROUP BY Movies.movie_id
  $movies_stmt = mysqli_prepare($connection, $movies_query);
  mysqli_stmt_bind_param($movies_stmt, "i", $offset);

  $count_query = "SELECT COUNT(*) AS Total FROM Movies";
  $count_stmt = mysqli_prepare($connection, $count_query);
}

mysqli_stmt_execute($movies_stmt);
$movies_result = (mysqli_stmt_get_result($movies_stmt));
$movies_data = mysqli_fetch_all($movies_result, MYSQLI_ASSOC);

mysqli_stmt_execute($count_stmt);
$count_result = (mysqli_stmt_get_result($count_stmt));
$count = mysqli_fetch_row($count_result);


$a = array(
  "total" => $count[0],
  "movies" => $movies_data
);

echo json_encode($a);

mysqli_close($connection);
?>