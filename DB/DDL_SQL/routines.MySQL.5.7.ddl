--
-- Current Database: `Dispensary`
--

CREATE DATABASE /*!32312 IF NOT EXISTS */ `Dispensary` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;

USE `Dispensary`;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT = @@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS = @@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION = @@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE = @@TIME_ZONE */;
/*!40103 SET TIME_ZONE = '+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS, UNIQUE_CHECKS = 0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0 */;
/*!40101 SET @OLD_SQL_MODE = @@SQL_MODE, SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES = @@SQL_NOTES, SQL_NOTES = 0 */;


DROP FUNCTION IF EXISTS BIN_TO_UUID;
DROP FUNCTION IF EXISTS UUID_TO_BIN;


DELIMITER $$
CREATE FUNCTION BIN_TO_UUID(b BINARY(16), f BOOLEAN)
    RETURNS CHAR(36)
    DETERMINISTIC
BEGIN
    DECLARE hexStr CHAR(32);
    SET hexStr = HEX(b);
    RETURN LOWER(
        IF(f,  CONCAT(
                SUBSTR(hexStr, 9, 8), '-',
                SUBSTR(hexStr, 5, 4), '-',
                SUBSTR(hexStr, 1, 4), '-',
                SUBSTR(hexStr, 17, 4), '-',
                SUBSTR(hexStr, 21)
            ), CONCAT(
                SUBSTR(hexStr, 1, 8), '-',
                SUBSTR(hexStr, 9, 4), '-',
                SUBSTR(hexStr, 13, 4), '-',
                SUBSTR(hexStr, 17, 4), '-',
                SUBSTR(hexStr, 21)
        )));
END$$
CREATE FUNCTION UUID_TO_BIN(uuid CHAR(36), f BOOLEAN)
    RETURNS BINARY(16)
    DETERMINISTIC
BEGIN
    RETURN UNHEX(
        IF(f,  CONCAT(
                SUBSTRING(uuid, 15, 4),
                SUBSTRING(uuid, 10, 4),
                SUBSTRING(uuid, 1, 8),
                SUBSTRING(uuid, 20, 4),
                SUBSTRING(uuid, 25)
            ), CONCAT(
                SUBSTRING(uuid, 1, 8),
                SUBSTRING(uuid, 10, 4),
                SUBSTRING(uuid, 15, 4),
                SUBSTRING(uuid, 20, 4),
                SUBSTRING(uuid, 25)
        )));
END$$
DELIMITER ;


-- thanks to here, finally a drop column if exists (wont fix for 15 yrs now, and counting)

DROP FUNCTION IF EXISTS COLUMN_EXISTS;

DELIMITER $$
CREATE FUNCTION COLUMN_EXISTS(tname VARCHAR(64),
                              cname VARCHAR(64))
    RETURNS BOOLEAN
    READS SQL DATA
BEGIN
    RETURN 0 < (SELECT COUNT(*)
                FROM `INFORMATION_SCHEMA`.`COLUMNS`
                WHERE `TABLE_SCHEMA` = SCHEMA()
                  AND `TABLE_NAME` = tname
                  AND `COLUMN_NAME` = cname);
END $$
DELIMITER ;


-- index_exists

DROP FUNCTION IF EXISTS INDEX_EXISTS;

DELIMITER $$
CREATE FUNCTION INDEX_EXISTS(tbl_name VARCHAR(64),
                             idx_name VARCHAR(64))
    RETURNS BOOLEAN
    READS SQL DATA
BEGIN
    RETURN EXISTS(SELECT NULL                                   --  EXISTS returns as soon as one row is found
                    FROM `INFORMATION_SCHEMA`.`STATISTICS`
                   WHERE `TABLE_SCHEMA` = SCHEMA()
                     AND `TABLE_NAME` = tbl_name
                     AND `INDEX_NAME` = idx_name);
END $$
DELIMITER ;


-- foreign key_exists


DROP FUNCTION IF EXISTS FOREIGN_KEY_EXISTS;

DELIMITER $$
CREATE FUNCTION FOREIGN_KEY_EXISTS(tbl_name VARCHAR(64),
                                   fk_symbol VARCHAR(64))
    RETURNS BOOLEAN
    READS SQL DATA
BEGIN
    RETURN EXISTS(SELECT 1                                      --  EXISTS returns as soon as one row is found
                    FROM `INFORMATION_SCHEMA`.`TABLE_CONSTRAINTS`
                   WHERE `CONSTRAINT_SCHEMA` = SCHEMA()
                     AND `TABLE_NAME` = tbl_name
                     AND `CONSTRAINT_NAME` = fk_symbol
                     AND `CONSTRAINT_TYPE` = 'FOREIGN KEY');
END $$
DELIMITER ;




-- add_column_if_exists:

DROP PROCEDURE IF EXISTS ADD_COLUMN_IF_NOT_EXISTS;

DELIMITER $$
CREATE PROCEDURE ADD_COLUMN_IF_NOT_EXISTS(tbl_name VARCHAR(64),
                                          col_name VARCHAR(64),
                                          col_spec VARCHAR(256))
BEGIN
    IF NOT COLUMN_EXISTS(tbl_name, col_name)
    THEN
        SET @add_stmt = CONCAT('ALTER TABLE `', tbl_name, '` ADD COLUMN `', col_name, '` ', col_spec);
        PREPARE stmt FROM @add_stmt;                --  @add_stmt CAN'T be a local variable such as add_stmt :
        EXECUTE stmt;                               --  it could go out of scope if EXECUTE was done elsewhere.
    END IF;
END $$
DELIMITER ;


-- add_column_with_index_if_none_exists:

DROP PROCEDURE IF EXISTS ADD_COLUMN_WITH_INDEX_IF_NONE_EXISTS;

DELIMITER $$
CREATE PROCEDURE ADD_COLUMN_WITH_INDEX_IF_NONE_EXISTS(tbl_name VARCHAR(64),
                                                      col_name VARCHAR(64),
                                                      col_spec VARCHAR(256),
                                                      col_indexname VARCHAR(64),
                                                      is_idx_unique BOOL)
BEGIN
    IF NOT COLUMN_EXISTS(tbl_name, col_name)
    THEN                                        --  @add_column CAN'T be a local variable such as add_column :
        SET @add_indexed_column =               --  it could go out of scope if EXECUTE was done elsewhere.
                CONCAT('ALTER TABLE `', tbl_name, '` ADD COLUMN `', col_name, '` ', col_spec);
        PREPARE add_indexed_column_query FROM @add_indexed_column;
        EXECUTE add_indexed_column_query;
        SET @add_column_index =
                CONCAT('ALTER TABLE `', tbl_name, '` ADD ', IF(is_idx_unique, 'UNIQUE ', ''),'KEY `', col_indexname, '`(`', col_name, '`)');
        PREPARE add_column_index_query FROM @add_column_index;
        EXECUTE add_column_index_query;
    END IF;
END $$
DELIMITER ;


-- add__index_if_none_exists:

DROP PROCEDURE IF EXISTS ADD_INDEX_IF_NONE_EXISTS;

DELIMITER $$
CREATE PROCEDURE ADD_INDEX_IF_NONE_EXISTS(tbl_name VARCHAR(64),
                                          col_name VARCHAR(64),
                                          idx_name VARCHAR(64),
                                          is_idx_unique BOOL)
BEGIN
    IF NOT INDEX_EXISTS(tbl_name, idx_name)
    THEN
        SET @add_new_index =
                CONCAT('ALTER TABLE `', tbl_name, '` ADD ', IF(is_idx_unique, 'UNIQUE ', ''),'KEY `', idx_name, '`(`', col_name, '`)');
        PREPARE add_new_index_query FROM @add_new_index;
        EXECUTE add_new_index_query;
    END IF;
END $$
DELIMITER ;


-- drop_index_if_exists:


DROP PROCEDURE IF EXISTS DROP_INDEX_IF_EXISTS;

DELIMITER $$
CREATE PROCEDURE DROP_INDEX_IF_EXISTS(tbl_name VARCHAR(64),
                                      idx_name VARCHAR(64))
BEGIN
    IF INDEX_EXISTS(tbl_name, idx_name)
    THEN
        SET @drop_index_if_it_exists =
                CONCAT('ALTER TABLE `', tbl_name, '` DROP INDEX `', idx_name, '`');
        PREPARE drop_index_query FROM @drop_index_if_it_exists;
        EXECUTE drop_index_query;
    END IF;
END $$
DELIMITER ;


-- drop_column_if_exists:


DROP PROCEDURE IF EXISTS DROP_COLUMN_IF_EXISTS;

DELIMITER $$
CREATE PROCEDURE DROP_COLUMN_IF_EXISTS(tname VARCHAR(64),
                                       cname VARCHAR(64))
BEGIN
    IF column_exists(tname, cname)
    THEN
        SET @drop_column_if_exists = CONCAT('ALTER TABLE `', tname, '` DROP COLUMN `', cname, '`');
        PREPARE drop_query FROM @drop_column_if_exists;
        EXECUTE drop_query;
    END IF;
END $$
DELIMITER ;


-- change_column_if_exists:


DROP PROCEDURE IF EXISTS CHANGE_COLUMN_IF_EXISTS;

DELIMITER $$
CREATE PROCEDURE CHANGE_COLUMN_IF_EXISTS(tname VARCHAR(64),
                                         cname VARCHAR(64),
                                         newname VARCHAR(64),
                                         cspec VARCHAR(256))
BEGIN
    IF column_exists(tname, cname)
    THEN
        SET @change_column_if_exists =
                CONCAT('ALTER TABLE `', tname, '` CHANGE `', cname, '`  `', newname, '` ', cspec);
        PREPARE change_column_query FROM @change_column_if_exists;
        EXECUTE change_column_query;
    END IF;
END $$
DELIMITER ;


-- change_indexed_column_if_exists:


DROP PROCEDURE IF EXISTS CHANGE_INDEXED_COLUMN_IF_EXISTS;

DELIMITER $$
CREATE PROCEDURE CHANGE_INDEXED_COLUMN_IF_EXISTS(tname VARCHAR(64),
                                                 cname VARCHAR(64),
                                                 newname VARCHAR(64),
                                                 cspec VARCHAR(256),
                                                 cindexname VARCHAR(64),
                                                 cindexnewname VARCHAR(64),
                                                 is_idx_unique BOOL)
BEGIN
    IF column_exists(tname, cname)
    THEN
        SET @drop_index_if_column_exists =
                CONCAT('ALTER TABLE `', tname, '` DROP INDEX `', cindexname, '`');
        PREPARE drop_index_query FROM @drop_index_if_column_exists;
        EXECUTE drop_index_query;

        SET @change_indexed_column_if_exists =
                CONCAT('ALTER TABLE `', tname, '` CHANGE `', cname, '`  `', newname, '` ', cspec);
        PREPARE change_indexed_column_query FROM @change_indexed_column_if_exists;
        EXECUTE change_indexed_column_query;

        SET @add_index_if_column_exists =
                CONCAT('ALTER TABLE `', tname, '` ADD ', IF(is_idx_unique, 'UNIQUE ', ''),'KEY `', cindexnewname, '`(`', newname, '`)');
        PREPARE add_index_query FROM @add_index_if_column_exists;
        EXECUTE add_index_query;
    END IF;
END $$
DELIMITER ;


-- drop_foreign_key_if_exists


DROP PROCEDURE IF EXISTS DROP_FOREIGN_KEY_IF_EXISTS;

DELIMITER $$
CREATE PROCEDURE DROP_FOREIGN_KEY_IF_EXISTS(IN tbl_name VARCHAR(64), IN fk_symbol VARCHAR(64))
BEGIN
    IF FOREIGN_KEY_EXISTS(tbl_name, fk_symbol)
    THEN
        SET @query = CONCAT('ALTER TABLE `', tbl_name, '` DROP FOREIGN KEY `', fk_symbol, '`');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;


-- add_foreign_key_if_none_exists


DROP PROCEDURE IF EXISTS ADD_FOREIGN_KEY_IF_NONE_EXISTS;

DELIMITER $$
CREATE PROCEDURE ADD_FOREIGN_KEY_IF_NONE_EXISTS(tbl_name VARCHAR(64),
                                                fk_symbol VARCHAR(64),
                                                col_name VARCHAR(64),
                                                ref_tbl_name VARCHAR(64),
                                                ref_col_name VARCHAR(64),
                                                fk_spec VARCHAR(256))
BEGIN
    IF NOT FOREIGN_KEY_EXISTS(tbl_name, fk_symbol)
    THEN
        SET @add_fk = CONCAT('ALTER TABLE `', tbl_name, '` ADD CONSTRAINT `', fk_symbol, '` FOREIGN KEY (`', col_name, '`) REFERENCES `', ref_tbl_name,'` (`', ref_col_name, '`) ', fk_spec);
        PREPARE add_fk_query FROM @add_fk;
        EXECUTE add_fk_query;
        DEALLOCATE PREPARE add_fk_query;
    END IF;
END$$
DELIMITER ;



/*!40103 SET TIME_ZONE = @OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE = @OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT = @OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS = @OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION = @OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES = @OLD_SQL_NOTES */;