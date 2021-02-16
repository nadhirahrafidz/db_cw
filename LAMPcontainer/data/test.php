<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title></title>
  </head>
  <body>
    <h2>Movies List</h2>
    <?php
      $connection = mysqli_connect('db_cw_mySQLcontainer_1','root','team11','MovieLens', 3306)
        or die('Error connecting to MySQL server.' . mysqli_error());
      $query = "SELECT * FROM Movies";
      $result = mysqli_query($connection,$query)
        or die('Error making select users query' . mysqli_error());
      echo '<table border="1">';
      while ($row = mysqli_fetch_array($result))
      {
        echo '<tr><td>' . $row['movie_id']. '</td><td>' .
          $row['title']. '</tr></td>';
      }
      echo '</table>';

      mysqli_close($connection);
    ?>
  </body>
</html>