<?php
header("Access-Control-Allow-Origin: http://localhost:3000");
header("Access-Control-Allow-Headers: Content-Type");
$host = "db_cw_mySQLcontainer_1"; 
$user = "root"; 
$password = "team11"; 
$dbname = "MovieLens"; 

$connection = mysqli_connect($host, $user, $password,$dbname)
        or die('Error connecting to MySQL server.' . mysqli_error());

$method = $_SERVER['REQUEST_METHOD'];
// $request = explode('/', trim($_SERVER['PATH_INFO'],'/'));

switch ($method) {
    case 'GET':
      $offset = isset($_GET['offset']) ? $_GET['offset'] : 0;

      $movies_stmt;
      $count_stmt;

      if (isset($_GET['search'])) {
        $temp = $_GET['search'].'%';

        $movies_query = 'SELECT * FROM Movies WHERE title LIKE ? LIMIT 10 OFFSET ?';
        $movies_stmt = mysqli_prepare($connection, $movies_query);
        mysqli_stmt_bind_param($movies_stmt, "si", $temp, $offset);

        $count_query = 'SELECT COUNT(*) AS Total FROM Movies WHERE title LIKE ?';
        $count_stmt = mysqli_prepare($connection, $count_query);
        mysqli_stmt_bind_param($count_stmt, "s", $temp);

      } else {
        $movies_query = "SELECT * FROM Movies LIMIT 10 OFFSET ?";
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
      break;
}

mysqli_close($connection);
?>