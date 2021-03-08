USE `MovieLens`;
DROP procedure IF EXISTS `createCommonTags`;

DELIMITER $$
USE `MovieLens`$$
CREATE PROCEDURE `createCommonTags` ()

BEGIN
DROP TABLE IF EXISTS Common_Tags;
CREATE TABLE Common_Tags 
  SELECT tag, COUNT(tag) AS tag_count
  FROM Tags
  GROUP BY tag
  ORDER BY COUNT(tag) DESC;
END$$

DELIMITER ;


