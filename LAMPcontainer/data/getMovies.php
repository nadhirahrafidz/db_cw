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

$movieID_stmt;
$count_stmt;

if (isset($_GET['search'])) {
  $temp = $_GET['search'].'%';
  
  $movieID_query = 'SELECT Movies.movie_id FROM Movies 
  WHERE Movies.title LIKE ? GROUP BY Movies.movie_id LIMIT 10 OFFSET ?';
  $movieID_stmt = mysqli_prepare($connection, $movieID_query);
  mysqli_stmt_bind_param($movieID_stmt, "si", $temp, $offset);

  $count_query = 'SELECT COUNT(*) AS Total FROM Movies WHERE title LIKE ?';
  $count_stmt = mysqli_prepare($connection, $count_query);
  mysqli_stmt_bind_param($count_stmt, "s", $temp);

} else {
  $movieID_query = 'SELECT Movies.movie_id FROM Movies
  GROUP BY Movies.movie_id LIMIT 10 OFFSET ?';
  $movieID_stmt = mysqli_prepare($connection, $movieID_query);
  mysqli_stmt_bind_param($movieID_stmt, "i", $offset);

  $count_query = "SELECT COUNT(*) AS Total FROM Movies";
  $count_stmt = mysqli_prepare($connection, $count_query);
}

mysqli_stmt_execute($movieID_stmt);
$movieID_result = (mysqli_stmt_get_result($movieID_stmt));
$movies_data = array();
while ($row = mysqli_fetch_row($movieID_result)) {
  $movies_data[] = $row[0];
}

$a = implode("','",$movies_data);

$movie_data_query = "SELECT Movies.movie_id, Movies.title, Movies.movieURL,
GROUP_CONCAT(DISTINCT Stars.star_name) AS stars, 
GROUP_CONCAT(DISTINCT Genres.genre) AS genres 
FROM Movies, Stars, Star_Movie, Genres, Genre_Movie
WHERE Movies.movie_id IN('".$a."')
AND Movies.movie_id = Star_Movie.movie_id
AND Star_Movie.star_id = Stars.star_id 
AND Movies.movie_id = Genre_Movie.movie_id
AND Genre_Movie.genre_id = Genres.genre_id
GROUP BY Movies.movie_id";

$movie_data_result = mysqli_query($connection,$movie_data_query);
$movie_data = mysqli_fetch_all($movie_data_result, MYSQLI_ASSOC);

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