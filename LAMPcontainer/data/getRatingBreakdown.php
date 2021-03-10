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


// part 2 for the different ratings
$procedure_query = "/*qc=on*//*qc_ttl=86400*/" . "CALL use2(?, @p1, @p2)";
$procedure_stmt = mysqli_prepare($connection, $procedure_query);
mysqli_stmt_bind_param($procedure_stmt, "i", $movie_id);
mysqli_stmt_execute($procedure_stmt);

$query = "SELECT @p1 as count , ROUND(@p2,1) as average";
$stmt = mysqli_prepare($connection, $query);
mysqli_stmt_execute($stmt);
$result = (mysqli_stmt_get_result($stmt));
$summary = mysqli_fetch_all($result, MYSQLI_ASSOC);


$query = "SELECT * FROM rating_breakdown";
$stmt = mysqli_prepare($connection, $query);
mysqli_stmt_execute($stmt);
$result = (mysqli_stmt_get_result($stmt));
$breakdown = mysqli_fetch_all($result, MYSQLI_ASSOC);

$all_data = array(
  "summary" => $summary,
  "breakdown" => $breakdown
);

echo json_encode($all_data);


?>