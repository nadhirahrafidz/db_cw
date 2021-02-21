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

$movieID_query = 'SELECT DISTINCT Movies.movie_id FROM Movies';
$count_query = 'SELECT COUNT(DISTINCT Movies.movie_id) AS Total FROM Movies';
$search;
$genres;
$where_clause_started = false;

if (isset($_GET['genres'])) {
  $where_clause_started = true;
  $genres = json_decode($_GET['genres']);
  $genres = implode("\r,",$genres)."\r";
  $movieID_query = $movieID_query.", Genres, Genre_Movie 
  WHERE Movies.movie_id = Genre_Movie.movie_id 
  AND Genre_Movie.genre_id = Genres.genre_id 
  AND find_in_set(Genres.genre, ?)";
  $count_query = $count_query.", Genres, Genre_Movie 
  WHERE Movies.movie_id = Genre_Movie.movie_id 
  AND Genre_Movie.genre_id = Genres.genre_id 
  AND find_in_set(Genres.genre, ?)";
}

if (isset($_GET['search'])) {
  if (!$where_clause_started) {
    $movieID_query = $movieID_query.' WHERE ';
    $count_query = $count_query.' WHERE ';
    $where_clause_started = true;
  } else {
    $movieID_query = $movieID_query.' AND ';
    $count_query = $count_query.' AND ';
  }

  $search = $_GET['search'].'%';
  $movieID_query = $movieID_query.'Movies.title LIKE ?';
  $count_query = $count_query.'title LIKE ?';
  $where_clause_started = true;
}

$movieID_query = $movieID_query.' GROUP BY Movies.movie_id LIMIT 10 OFFSET ?';
$movieID_stmt = mysqli_prepare($connection, $movieID_query);
$count_stmt = mysqli_prepare($connection, $count_query);

if (isset($_GET['genres'])) {
  if (isset($_GET['search'])) {
    mysqli_stmt_bind_param($movieID_stmt, "ssi", $genres, $search, $offset);
    mysqli_stmt_bind_param($count_stmt, "ss", $genres, $search);
  } else {
    mysqli_stmt_bind_param($movieID_stmt, "si", $genres, $offset);
    mysqli_stmt_bind_param($count_stmt, "s", $genres);
  }
} else if (isset($_GET['search'])) {
  mysqli_stmt_bind_param($movieID_stmt, "si", $search, $offset);
  mysqli_stmt_bind_param($count_stmt, "s", $search);
} else {
  mysqli_stmt_bind_param($movieID_stmt, "i", $offset);
}

mysqli_stmt_execute($movieID_stmt);
$movieID_result = (mysqli_stmt_get_result($movieID_stmt));
$movies_data = array();
while ($row = mysqli_fetch_row($movieID_result)) {
  $movies_data[] = $row[0];
}

$movieIDs = implode("','",$movies_data);

$movie_data_query = "SELECT Movies.movie_id, Movies.title, Movies.movieURL,
GROUP_CONCAT(DISTINCT Stars.star_name) AS stars, 
GROUP_CONCAT(DISTINCT Genres.genre) AS genres,
ROUND(AVG(Ratings.rating),1) AS rating
FROM Movies, Stars, Star_Movie, Genres, Genre_Movie, Ratings
WHERE Movies.movie_id IN('".$movieIDs."')
AND Movies.movie_id = Star_Movie.movie_id
AND Star_Movie.star_id = Stars.star_id 
AND Movies.movie_id = Genre_Movie.movie_id
AND Genre_Movie.genre_id = Genres.genre_id
AND Ratings.movie_id = Movies.movie_id
GROUP BY Movies.movie_id
";

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