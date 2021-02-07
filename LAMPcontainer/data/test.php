<?php
include("imdb.php");
 
$imdb = new Imdb();
$movieArray = $imdb->getMovieInfo("The Godfather");
echo '<table cellpadding="3" cellspacing="2" border="1" width="80%" align="center">';
foreach ($movieArray as $key=>$value){
    $value = is_array($value)?implode("<br />", $value):$value;
    echo '<tr>';
    echo '<th align="left" valign="top">' . strtoupper($key) . '</th><td>' . $value . '</td>';
    echo '</tr>';
}
echo '</table>';
?>