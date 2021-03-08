USE `MovieLens`;

DELIMITER $$

CREATE EVENT updateTablesDaily
  ON SCHEDULE
    EVERY 1 DAY
    STARTS (CURRENT_TIMESTAMP + INTERVAL 1 MINUTE)
  DO BEGIN
  CALL createPopularityTable(30);
  CALL createPopularityTable(365);
  CALL createPopularityTable(0);
  CALL createCommonTags();
END$$

DELIMITER ;