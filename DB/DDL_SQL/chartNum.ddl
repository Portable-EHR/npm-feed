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


DROP FUNCTION IF EXISTS CHART_NUMBER;

DELIMITER $$
CREATE FUNCTION CHART_NUMBER(id BIGINT(20) UNSIGNED)
    RETURNS VARCHAR(25)
    NO SQL
BEGIN
    DECLARE random16b SMALLINT UNSIGNED;
    DECLARE threshold BIGINT UNSIGNED;
    DECLARE nibbleCnt INTEGER;                                          --  16 nibbles in max BIGINT 64b
    DECLARE shift INTEGER;                                              --  nibbleCnt × 4

    DECLARE even4ofLo7b TINYINT UNSIGNED;
    DECLARE odd3OfLo7b  TINYINT UNSIGNED;

    DECLARE nibble INTEGER UNSIGNED;
    DECLARE random1b INTEGER UNSIGNED;
    DECLARE a CHAR(1);
    DECLARE hypenOrNot CHAR(1);

    DECLARE isLo000 BOOL;
    DECLARE any000 SMALLINT(3) ZEROFILL;

    DECLARE hi5bOf000 INTEGER UNSIGNED;
    DECLARE lo3bOf000 INTEGER UNSIGNED;
    DECLARE random2bOf000 INTEGER UNSIGNED;

    DECLARE encodedLo3bOf000 TINYINT UNSIGNED;
    DECLARE full8bOf000 SMALLINT UNSIGNED;
    DECLARE hi3bOf000   SMALLINT UNSIGNED;
    DECLARE mid2bOf000  SMALLINT UNSIGNED;

    DECLARE chartNum VARCHAR(25);

    SET random16b = FLOOR( RAND() * 0x10000);                           --  0x0000 - 0xffff     NOT DETERMINISTIC
    SET threshold = 0x1000;                                             --  3 nibbles -> shift 12b -> 4k
    SET nibbleCnt = 4;

    SET isLo000 = true;
    SET even4ofLo7b = ( ( id       & 0x1) |      --  b0
                        ((id >> 1) & 0x2) |      --  b2
                        ((id >> 2) & 0x4) |      --  b4
                        ((id >> 3) & 0x8)    );  --  b6

    SET  odd3ofLo7b = ( ((id >> 1) & 0x1) |      --  b1
                        ((id >> 2) & 0x2) |      --  b3
                        ((id >> 3) & 0x4)    );  --  b5

    addA: REPEAT

        SET random1b = (random16b >> nibbleCnt) & 0x1;

        SET nibble = IF(isLo000, even4ofLo7b, (id >> shift) & 0xf); --  IF isLo000:  shift not used, ELSE: shift >= 20b
        SET a = IF(   ((nibble >> 3) & 0x1),            --  b3 == 1
                    IF(   ((nibble >> 2) & 0x1),            --  b2 == 1
                        IF(   ((nibble >> 1) & 0x1),            --  b1 == 1
                            IF(   ( nibble       & 0x1),            --  b0 == 1     #   0xF => 0x8
                                IF( random1b,           'O',
                                                        'N'),
                        --  IF( ! ( nibble       & 0x1),            --  b0 == 0     #   0xE => 0xA
                                IF( random1b,           'R',
                                                        'Q')),
                    --  IF ( ! ((nibble >> 1) & 0x1),           --  b1 == 0
                            IF(   ( nibble       & 0x1),            --  b0 == 1     #   0xD => 0xB
                                IF( random1b,           'T',
                                                        'S'),
                        --  IF( ! ( nibble       & 0x1),            --  b0 == 0     #   0xC => 5
                                                        'P' )),
                --  IF( ! ((nibble >> 2) & 0x1),            --  b2 == 0
                        IF(   ((nibble >> 1) & 0x1),            --  b1 == 1
                            IF(   ( nibble       & 0x1),            --  b0 == 1     #   0xB => 0xD
                                                        'W',
                        --  IF( ! ( nibble       & 0x1),            --  b0 == 0     #   0xA => 0xF
                                                        'Z' ),
                    --  IF( ! ((nibble >> 1) & 0x1),            --  b1 == 0
                            IF(   ( nibble       & 0x1),            --  b0 == 1     #   0x9 => 0xE
                                IF( random1b,           'Y',
                                                        'X'),
                        --  IF( ! ( nibble       & 0x1),            --  b0 == 0     #   0x8 => 0xC
                                IF( random1b,           'V',
                                                        'U')))),
            --  IF( ! ((nibble >> 3) & 0x1),            --  b3 == 0
                    IF(   ((nibble >> 2) & 0x1),            --  b2 == 1
                        IF(   ((nibble >> 1) & 0x1),            --  b1 == 1
                            IF(   ( nibble       & 0x1),            --  b0 == 1     #   0x7 => 0x4
                                IF( random1b,           'H',
                                                        'G'),
                        --  IF( ! ( nibble       & 0x1),            --  b0 == 0     #   0x6 => 0x5
                                IF( random1b,           'J',
                                                        'I')),
                    --  IF ( ! ((nibble >> 1) & 0x1),           --  b1 == 0
                            IF(   ( nibble       & 0x1),            --  b0 == 1     #   0x5 => 0x7
                                IF( random1b,           'M',
                                                        'L'),
                        --  IF( ! ( nibble       & 0x1),            --  b0 == 0     #   0x4 => 0x6
                                                        'K' )),
                --  IF( ! ((nibble >> 2) & 0x1),            --  b2 == 0
                        IF(   ((nibble >> 1) & 0x1),            --  b1 == 1
                            IF(   ( nibble       & 0x1),            --  b0 == 1     #   0x3 => 0x2
                                IF( random1b,           'E',
                                                        'D'),
                        --  IF( ! ( nibble       & 0x1),            --  b0 == 0     #   0x2 => 0x3
                                                        'F' ),
                    --  IF( ! ((nibble >> 1) & 0x1),            --  b1 == 0
                            IF(   ( nibble       & 0x1),            --  b0 == 1     #   0x1 => 0x1
                                IF( random1b,           'C',
                                                        'B'),
                        --  IF( ! ( nibble       & 0x1),            --  b0 == 0     #   0x0 => 0x0
                                                        'A' ))));

        SET hypenOrNot = IF(nibbleCnt % 3, '', '-');

        SET nibbleCnt = nibbleCnt + 1;                      --  nibbleCnt : [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ]
        SET shift = nibbleCnt << 2;         --  × 4         --  shift :   [20b, 24b, ...                            64b]

        loAndHi000: WHILE threshold <= 0x1000 DO

            IF isLo000 THEN
                SET hi5bOf000 = (id >> 7) & 0x1f;
                SET lo3bOf000 = odd3OfLo7b;
                SET random2bOf000 = (random16b     ) & 0x3;
            ELSE -- isHi000
                SET hi5bOf000 = (id >> 15) & 0x1f;
                SET lo3bOf000 = (id >> 12) & 0x7;
                SET random2bOf000 = (random16b >> 2) & 0x3;
            END IF;

            SET encodedLo3bOf000 =  IF(   ((lo3bOf000 >> 2) & 0x1),         --  b2 == 1
                                        IF(   ((lo3bOf000 >> 1) & 0x1),         --  b1 == 1
                                            IF(   ( lo3bOf000      & 0x1),  4,      --  b0 == 1     #   7 -> 4
                                                                            6),     --  b0 == 0     #   6 -> 6
                                    --  IF( ! ((lo3bOf000 >> 1) & 0x1),         --  b1 == 0
                                            IF(   ( lo3bOf000      & 0x1),  7,      --  b0 == 1     #   5 -> 7
                                                                            5)),    --  b0 == 0     #   4 -> 5
                                --  IF( ! ((lo3bOf000 >> 2) & 0x1),         --  b2 == 0
                                        IF(   ((lo3bOf000 >> 1) & 0x1),         --  b1 == 1
                                            IF(  ( lo3bOf000       & 0x1),  1,      --  b0 == 1     #   3 -> 1
                                                                            3),     --  b0 == 0     #   2 -> 3
                                    --  IF( ! ((lo3bOf000 >> 1) & 0x1),         --  b1 == 0
                                            IF(  ( lo3bOf000       & 0x1),  2,      --  b0 == 1     #   1 -> 2
                                                                            0)));   --  b0 == 0     #   0 -> 0
            SET full8bOf000 = (hi5bOf000 << 3) | encodedLo3bOf000;
            SET hi3bOf000   = hi5bOf000 >> 2;
            SET mid2bOf000  = hi5bOf000       & 0x3;

            SET random2bOf000 = IF(mid2bOf000 <> 0x3, FLOOR( RAND() * 0x3), --  mid2b in {0,1,2}: random in [0:3] : ({0,1,2})
                                                      random2bOf000);       --  mid2b = 3       : random in [0:4] : ({0,1,2,3})

            SET any000 = (full8bOf000 << 2)  +  random2bOf000  -  hi5bOf000  +  hi3bOf000;
                                                        --     -    [0:32]   +    [0:8]  = -24 total adjustment on 1024 => 1000
            IF isLo000 THEN
                SET chartNum = CONCAT(a, CAST(any000 AS char(3)));              --  'A000'

                IF id < threshold THEN                              --  3 nibbles  ->  shift 12b  ->  0x_000    ->  4k
                    RETURN chartNum;
                END IF;

                SET isLo000 = false;    --  -> isHi000
                ITERATE loAndHi000;

            ELSE -- isHi000
                SET chartNum = INSERT(chartNum, 2, 0, CONCAT(any000, '-'));     --  'A000'  ->  'A111-000'

                SET threshold = 1 << shift;                         --  5 nibbles  ->  shift 20b  ->  0x10_0000  ->  1M


                IF id < threshold THEN
                    RETURN chartNum;
                END IF;

                ITERATE addA;
            END IF;
        END WHILE;

        SET chartNum = CONCAT(a, hypenOrNot, chartNum);
        SET threshold = 1 << shift;

    UNTIL (id < threshold  ||  nibbleCnt >= 16) END REPEAT;

    RETURN chartNum;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS ADD_CHARTNUM_IF_NOT_EXISTS;

DELIMITER $$
CREATE PROCEDURE ADD_CHARTNUM_IF_NOT_EXISTS(tbl_name VARCHAR(64),
                                            col_name VARCHAR(64),
                                            col_spec VARCHAR(256),
                                            idx_name VARCHAR(64),
                                            is_idx_unique BOOL)
BEGIN
    DECLARE has_idx_name BOOL;
    SET has_idx_name = (idx_name IS NOT NULL AND LENGTH(idx_name) > 0);

    IF (NOT COLUMN_EXISTS(tbl_name, col_name) AND (
            NOT has_idx_name OR NOT INDEX_EXISTS(tbl_name, idx_name)))
    THEN
        SET @add_stmt = CONCAT('ALTER TABLE `', tbl_name, '` ADD COLUMN `', col_name, '` ', col_spec);
        PREPARE stmt FROM @add_stmt;                --  @add_stmt CAN'T be a local variable such as add_stmt :
        EXECUTE stmt;                               --  it could go out of scope if EXECUTE was done elsewhere.

        SET @add_stmt = CONCAT('UPDATE `', tbl_name, '` AS p0\n  JOIN `', tbl_name,
                                '` AS p1 ON p0.`id` = p1.`id`\n   SET p0.`', col_name, '` = CHART_NUMBER(p1.`id`)');
        PREPARE stmt FROM @add_stmt;
        EXECUTE stmt;

        IF has_idx_name THEN                                        --  already tested NOT INDEX_EXISTS(), above.
            SET @add_stmt = CONCAT('ALTER TABLE `', tbl_name, '` ADD ', IF(is_idx_unique, 'UNIQUE ', ''),
                                   'KEY `', idx_name, '` (`', col_name, '`)');
            PREPARE stmt FROM @add_stmt;
            EXECUTE stmt;
        END IF;
    END IF;
END $$
DELIMITER ;

CALL DROP_COLUMN_IF_EXISTS('Patient', 'chart_number');
CALL ADD_CHARTNUM_IF_NOT_EXISTS('Patient', 'chart_number', 'VARCHAR(25) NOT NULL DEFAULT \'\'', 'idx_chart_number', TRUE);


DROP TRIGGER IF EXISTS `PatientVersion`;

DELIMITER $$
CREATE TRIGGER `PatientVersion` BEFORE UPDATE ON `Patient`
    FOR EACH ROW
BEGIN
    IF NEW.row_persisted = OLD.row_persisted  AND  NEW.chart_number = OLD.chart_number  THEN
        SET NEW.row_version = OLD.row_version + 1;
        SET NEW.row_persisted = CURRENT_TIMESTAMP(3);
    END IF;
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS `InsertPatientChartNumber`;

DELIMITER $$
CREATE TRIGGER `InsertPatientChartNumber` BEFORE INSERT ON `Patient`
    FOR EACH ROW
BEGIN
    DECLARE goodEnoughId BIGINT(20);
    SELECT AUTO_INCREMENT FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = SCHEMA() AND TABLE_NAME = 'Patient' INTO goodEnoughId;
    --  If there are concurrent INSERT of Patient, the random part should be enough to protect
    --  against .chart_number collision most of the time. When it's not enough, the already
    --  inserted row is NOT changed using INSERT ... ON DUPLICATE KEY UPDATE. The collision
    --  should be diagnosed from ER_DUP_ENTRY and the INSERT be retried after a small random
    --  delay. Two full INSERT can de done back-to-back with less than 30 ms on development
    --  laptop. So random delay in the 30-80ms range might do.
    --  An alternate solution is to INSERT with chartNumber = CAST(TIMESTAMP(3) AS VARCHAR(25))
    --  and update right after insert.
    SET NEW.`chart_number` = CHART_NUMBER(goodEnoughId);
END $$
DELIMITER ;


/*!40103 SET TIME_ZONE = @OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE = @OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT = @OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS = @OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION = @OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES = @OLD_SQL_NOTES */;
