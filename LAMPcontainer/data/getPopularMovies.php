<?php
//learned how to use/created cache from https://medium.com/@dylanwenzlau/500x-faster-caching-than-redis-memcache-apc-in-php-hhvm-dcd26e8447ad
function cache_set($key, $val) {
  $val = var_export($val, true);
  $val = str_replace('stdClass::__set_state', '(object)', $val);
  $tmp = "/tmp/$key." . uniqid('', true) . '.tmp';
  file_put_contents($tmp, '<?php $val = ' . $val . ';', LOCK_EX);
  rename($tmp, "/tmp/$key");
}

function cache_get($key) {
  @include "/tmp/$key";
  return isset($val) ? $val : false;
}

$cache_ttl = 3600;

$iscached = cache_get('iscached');
if ($iscached === null){
  $cached = false;
} else {
  //make sure that the cache does not become stale
  $lastupdated = cache_get("last_cached");
  if (gmmktime(true) - $lastupdated > $cache_ttl){
    $cached = false;
  } else {
    $cached = true;
  }
}



header("Access-Control-Allow-Origin: http://localhost:3000");
header("Access-Control-Allow-Headers: Content-Type");
$host = "db_cw_mySQLcontainer_1"; 
$user = "root"; 
$password = "team11"; 
$dbname = "MovieLens";



if ($cached == true){
  $starttime = microtime(true);
  $value = cache_get('popular_movies');
  $endtime = microtime(true);
  $duration = $endtime - $starttime;
  //echo $duration;
  echo $value;
} else {
 //echo "not cached";
  $connection = mysqli_connect($host, $user, $password,$dbname)
        or die('Error connecting to MySQL server.' . mysqli_error());


$timescale = isset($_GET['timescale']) ? $_GET['timescale'] : 7;
$offset = isset($_GET['offset']) ? $_GET['offset'] : 0;
$limit = 12;
$genre = isset($_GET['genre']) ? $_GET['genre']."\r" : "";

$movieID_query = 'CALL use3_popular(?, ?, ?, ?, @pCount)';
//$movieID_query = "/*qc=on*//*qc_ttl=86400*/" . 'CALL use3(1,?, ?, ?, ?, @pCount)';

$starttime = microtime(true);

$movieID_stmt = mysqli_prepare($connection, $movieID_query);
mysqli_stmt_bind_param($movieID_stmt, "iiis", $timescale, $offset, $limit, $genre);
mysqli_stmt_execute($movieID_stmt);

$movieID_result = mysqli_stmt_get_result($movieID_stmt);
$movies_data = mysqli_fetch_all($movieID_result, MYSQLI_ASSOC);
mysqli_next_result($connection);

$count_query = 'SELECT @pCount';
$count_stmt = mysqli_prepare($connection, $count_query);
mysqli_stmt_execute($count_stmt);
$count_result = mysqli_stmt_get_result($count_stmt);

$count = mysqli_fetch_all($count_result)[0][0];

$all_data = array(
  "total" => $count,
  "movies" => $movies_data
);

$endtime = microtime(true);
$duration = $endtime - $starttime;
//echo $duration;

echo json_encode($all_data);
cache_set('popular_movies', json_encode($all_data));
cache_set("last_cached", gmmktime(true));

mysqli_close($connection);

}


?>