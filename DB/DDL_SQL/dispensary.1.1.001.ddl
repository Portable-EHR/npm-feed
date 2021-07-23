-- MySQL dump 10.13  Distrib 5.7.22, for Linux (x86_64)
--
-- Host: localhost    Database: FeedNode
-- ------------------------------------------------------
-- Server version	5.7.22-log

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

--
-- Current Database: `Dispensary`
--

CREATE DATABASE /*!32312 IF NOT EXISTS */ `Dispensary` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;

USE `Dispensary`;

--
-- Table structure for table `Configuration`
--

DROP TABLE IF EXISTS `Configuration`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Configuration`
(
    `db_version` varchar(11) DEFAULT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

INSERT INTO Configuration
set db_version='1.1.001';
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `WTF`
--

DROP TABLE IF EXISTS `WTF`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `WTF` (
    `id`            bigint(20) unsigned           NOT NULL AUTO_INCREMENT,
    `created_on`    timestamp                     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `occured_on`    datetime                      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `source`        enum ('dispensary','backend') NOT NULL DEFAULT 'dispensary',
    `dispensary_id` varchar(128)                  NOT NULL,
    `tx_status`     enum ('queued','accepted')    NOT NULL DEFAULT 'queued',
    `wtf`           varchar(4096)                          DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_disp` (`dispensary_id`),
    KEY `idx_co` (`created_on`),
    KEY `idx_oo` (`occured_on`),
    KEY `idx_source` (`source`)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `PractitionerLegitId`
--


DROP TABLE IF EXISTS `PractitionerLegitId`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

CREATE TABLE `PractitionerLegitId` (
    `id`                bigint(20) unsigned         NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    `practitioner_id`   bigint(20)  unsigned        NOT NULL,
    `feed_item_id`      binary(16)                  NOT NULL,
    `backend_item_id`   binary(16)                  DEFAULT NULL,

    `issuer_kind`       enum ('healthCare','socialSecurity','passport','driverLicense','practiceLicense','stateID','other')   NOT NULL,
    `issuer_alias`      varchar(128)                NOT NULL,
    `number`            varchar(128)                NOT NULL,
    `version`           varchar(128)                DEFAULT NULL,
    `expires_on`        date                        DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_fitm` (`feed_item_id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_pract` (`practitioner_id`),
    KEY `idx_nb` (`number`),
    CONSTRAINT `fk_practitionerlegitid_practitioner` FOREIGN KEY (`practitioner_id`) REFERENCES `Practitioner` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TRIGGER IF EXISTS `PractitionerLegitIdVersion`;
CREATE TRIGGER `PractitionerLegitIdVersion` BEFORE UPDATE ON `PractitionerLegitId`
    FOR EACH ROW    SET NEW.row_version = OLD.row_version + 1;


--
-- Table structure for table `Practitioner`
--


DROP TABLE IF EXISTS `Practitioner`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Practitioner` (
    `id`                bigint(20) unsigned         NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,

    `feed_alias`        varchar(128)                NOT NULL,
    `feed_item_id`      binary(16)                  NOT NULL,
    `backend_item_id`   binary(16)                  DEFAULT NULL,

    `family_name`       varchar(50)                 NOT NULL,
    `first_name`        varchar(50)                 NOT NULL,
    `middle_name`       varchar(50)                 DEFAULT NULL,
    `normalized_name`   varchar(152)                NOT NULL,

    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_fitm` (`feed_item_id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),
    KEY `idx_feed` (`feed_alias`),
    KEY `idx_bitm` (`backend_item_id`),
    KEY `idx_nnm` (`normalized_name`),
    KEY `idx_feed_alias_feed_item_id` (`feed_alias`, `feed_item_id`),
    KEY `idx_feed_alias_persisted` (`feed_alias`, `row_persisted`)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TRIGGER IF EXISTS `PractitionerVersion`;
DELIMITER $$
CREATE TRIGGER `PractitionerVersion` BEFORE UPDATE ON `Practitioner`
    FOR EACH ROW
    BEGIN
        IF NEW.row_persisted = OLD.row_persisted THEN
            SET NEW.row_version = OLD.row_version + 1;
            SET NEW.row_persisted = CURRENT_TIMESTAMP(3);
        END IF;
    END; $$
DELIMITER ;

DROP TRIGGER IF EXISTS `PractitionerLegitIdSeq`;

DROP TRIGGER IF EXISTS `PractitionerLegitIdPersistedPractitioner`;
CREATE TRIGGER `PractitionerLegitIdPersistedPractitioner` AFTER UPDATE ON `PractitionerLegitId`
    FOR EACH ROW UPDATE `Practitioner` SET `row_persisted` = CURRENT_TIMESTAMP(3) WHERE `id` = OLD.practitioner_id;

DROP TRIGGER IF EXISTS `DelPractitionerLegitIdPersistedPractitioner`;
CREATE TRIGGER `DelPractitionerLegitIdPersistedPractitioner` AFTER DELETE ON `PractitionerLegitId`
    FOR EACH ROW UPDATE `Practitioner` SET `row_persisted` = CURRENT_TIMESTAMP(3) WHERE `id` = OLD.practitioner_id;


CREATE OR REPLACE VIEW PractitionerUuid AS
    SELECT id,
           BIN_TO_UUID(feed_item_id, 1) AS feed_item_uuid,
           BIN_TO_UUID(backend_item_id, 1) AS backend_item_uuid,
           family_name,
           first_name
    FROM Practitioner;


--
-- Table structure for table `BirthPlace`
--

DROP TABLE IF EXISTS `BirthPlace`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `BirthPlace` (
    `id`            bigint(20) unsigned         NOT NULL AUTO_INCREMENT,
    `row_version`   int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`   timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted` timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    `street_1`      varchar(255)                DEFAULT NULL,
    `street_2`      varchar(255)                DEFAULT NULL,
    `city`          varchar(50)                 DEFAULT NULL,
    `zip`           varchar(20)                 DEFAULT NULL,
    `state`         varchar(50)                 DEFAULT NULL,
    `country`       char(2)                     NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_co` (`country`),
    CONSTRAINT `fk_birth_place_country` FOREIGN KEY (`country`) REFERENCES `Country` (`iso2`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TRIGGER IF EXISTS `BirthPlaceVersion`;
CREATE TRIGGER `BirthPlaceVersion` BEFORE UPDATE ON `BirthPlace`
    FOR EACH ROW    SET NEW.row_version = OLD.row_version + 1;


--
-- Table structure for table `CivicAddress`
--

DROP TABLE IF EXISTS `CivicAddress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CivicAddress` (
    `id`            bigint(20) unsigned         NOT NULL AUTO_INCREMENT,
    `row_version`   int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`   timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted` timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    `street_1`      varchar(255)                NOT NULL,
    `street_2`      varchar(255)                DEFAULT NULL,
    `city`          varchar(50)                 NOT NULL,
    `zip`           varchar(20)                 NOT NULL,
    `state`         varchar(50)                 NOT NULL,
    `country`       char(2)                     NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_co` (`country`),
    CONSTRAINT `fk_address_country` FOREIGN KEY (`country`) REFERENCES `Country` (`iso2`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TRIGGER IF EXISTS `CivicAddressVersion`;
CREATE TRIGGER `CivicAddressVersion` BEFORE UPDATE ON `CivicAddress`
    FOR EACH ROW    SET NEW.row_version = OLD.row_version + 1;


--
-- Table structure for table `MultiAddress`
--

DROP TABLE IF EXISTS `MultiAddress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MultiAddress` (
    `id`                bigint(20) unsigned     NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned        NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)            NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)            NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    `contact_id`        bigint(20) unsigned     NOT NULL,
    `feed_item_id`      binary(16)              NOT NULL,
    `backend_item_id`   binary(16)              DEFAULT NULL,

    `street_1`          varchar(255)            NOT NULL,
    `street_2`          varchar(255)            DEFAULT NULL,
    `city`              varchar(50)             NOT NULL,
    `zip`               varchar(20)             NOT NULL,
    `state`             varchar(50)             NOT NULL,
    `country`           char(2)                 NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_fitm` (`feed_item_id`),
    KEY `idx_co` (`country`),
    KEY `idx_contact` (`contact_id`),
    CONSTRAINT `fk_multi_address_country` FOREIGN KEY (`country`) REFERENCES `Country` (`iso2`),
    CONSTRAINT `fk_multi_address_contact` FOREIGN KEY (`contact_id`) REFERENCES `Contact` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TRIGGER IF EXISTS `MultiAddressVersion`;
CREATE TRIGGER `MultiAddressVersion` BEFORE UPDATE ON `MultiAddress`
    FOR EACH ROW    SET NEW.row_version = OLD.row_version + 1;


--
-- Table structure for table `Contact`
--

DROP TABLE IF EXISTS `Contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Contact` (
    `id`                bigint(20) unsigned         NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    `feed_item_id`      binary(16)                  NOT NULL,
    `backend_item_id`   binary(16)                  DEFAULT NULL,

    `first_name`        varchar(50)                 DEFAULT NULL,
    `last_name`         varchar(50)                 DEFAULT NULL,
    `middle_name`       varchar(50)                 DEFAULT NULL,
    `normalized_name`   varchar(152)                DEFAULT NULL,

    `preferred_gender`  enum('F','M', 'N')          DEFAULT NULL,
    `preferred_language`char(2)                     DEFAULT NULL,
    `email`             varchar(254)                DEFAULT NULL,
    `alternate_email`   varchar(254)                DEFAULT NULL,
    `land_phone`        varchar(30)                 DEFAULT NULL,
    `mobile_phone`      varchar(30)                 DEFAULT NULL,
    `fax`               varchar(30)                 DEFAULT NULL,
    `salutation`        varchar(12)                 DEFAULT NULL,
    `pro_salutation`    varchar(12)                 DEFAULT NULL,
    `titles`            varchar(50)                 DEFAULT NULL,

    `address_id`        bigint(20) unsigned         DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_fitm` (`feed_item_id`),
    KEY `idx_nnm` (`normalized_name`),
    KEY `idx_mobile` (`mobile_phone`),
    KEY `idx_land` (`land_phone`),
    KEY `idx_email` (`email`),
    KEY `idx_alt_email` (`alternate_email`),
    KEY `idx_language` (`preferred_language`),
    KEY `idx_addr` (`address_id`),
    CONSTRAINT `fk_contact_language` FOREIGN KEY (`preferred_language`) REFERENCES `Language` (`iso2`),
    CONSTRAINT `fk_contact_address` FOREIGN KEY (`address_id`) REFERENCES `CivicAddress` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TRIGGER IF EXISTS `ContactVersion`;
DELIMITER $$
CREATE TRIGGER `ContactVersion` BEFORE UPDATE ON `Contact`
    FOR EACH ROW
BEGIN
    IF NEW.row_persisted = OLD.row_persisted THEN
        SET NEW.row_version = OLD.row_version + 1;
        SET NEW.row_persisted = CURRENT_TIMESTAMP(3);
    END IF;
END; $$
DELIMITER ;

DROP TRIGGER IF EXISTS `CivivAddressPersistedContact`;
CREATE TRIGGER `CivivAddressPersistedContact` AFTER UPDATE ON `CivicAddress`
    FOR EACH ROW UPDATE `Contact` SET `row_persisted` = CURRENT_TIMESTAMP(3) WHERE `address_id` = OLD.id;


DROP TRIGGER IF EXISTS `ContactMultiAddressSeq`;

DROP TRIGGER IF EXISTS `MultiAddressPersistedContact`;
CREATE TRIGGER `MultiAddressPersistedContact` AFTER UPDATE ON `MultiAddress`
    FOR EACH ROW UPDATE `Contact` SET `row_persisted` = CURRENT_TIMESTAMP(3) WHERE `id` = OLD.contact_id;

DROP TRIGGER IF EXISTS `DelMultiAddressPersistedContact`;
CREATE TRIGGER `DelMultiAddressPersistedContact` AFTER DELETE ON `MultiAddress`
    FOR EACH ROW UPDATE `Contact` SET `row_persisted` = CURRENT_TIMESTAMP(3) WHERE `id` = OLD.contact_id;


--
-- Table structure for table `PatientLegitId`
--


DROP TABLE IF EXISTS `PatientLegitId`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PatientLegitId` (
    `id`                bigint(20) unsigned         NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    `patient_id`        bigint(20) unsigned         NOT NULL,
    `feed_item_id`      binary(16)                  NOT NULL,
    `backend_item_id`   binary(16)                  DEFAULT NULL,

    `issuer_kind`       enum ('healthCare','socialSecurity','passport','driverLicense','practiceLicense','stateID','other')   NOT NULL,
    `issuer_alias`      varchar(128)                NOT NULL,
    `number`            varchar(128)                NOT NULL,
    `version`           varchar(128)                DEFAULT NULL,
    `expires_on`        date                        DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_fitm` (`feed_item_id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_patient` (`patient_id`),
    KEY `idx_nb` (`number`),
    CONSTRAINT `fk_patientlegitid_patient` FOREIGN KEY (`patient_id`) REFERENCES `Patient` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TRIGGER IF EXISTS `PatientLegitIdVersion`;
CREATE TRIGGER `PatientLegitIdVersion` BEFORE UPDATE ON `PatientLegitId`
    FOR EACH ROW    SET NEW.row_version = OLD.row_version + 1;


--
-- Table structure for table `Patient`
--


DROP TABLE IF EXISTS `Patient`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Patient` (
    `id`                            bigint(20) unsigned     NOT NULL AUTO_INCREMENT,
    `row_version`                   int(10) unsigned        NOT NULL DEFAULT 0,
    `row_created`                   timestamp(3)            NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`                 timestamp(3)            NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`                   timestamp(3)            DEFAULT NULL,

    `feed_alias`                    varchar(128)            NOT NULL,
    `feed_item_id`                  binary(16)              NOT NULL,
    `backend_item_id`               binary(16)              DEFAULT NULL,

    `chart_number`                  varchar(25)             NOT NULL,
    `date_of_birth`                 date                    NOT NULL,
    `birth_place_id`                bigint(20) unsigned     DEFAULT NULL,
    `gender_at_birth`               enum('F','M', 'N')      NOT NULL,
    `gender`                        enum('F','M', 'N')      NOT NULL,

    `family_name_at_birth`          varchar(50)             NOT NULL,
    `first_name_at_birth`           varchar(50)             NOT NULL,
    `middle_name_at_birth`          varchar(50)             DEFAULT NULL,
    `normalized_name_at_birth`      varchar(152)            NOT NULL,

    `family_name`                   varchar(50)             NOT NULL,
    `first_name`                    varchar(50)             NOT NULL,
    `middle_name`                   varchar(50)             DEFAULT NULL,
    `normalized_name`               varchar(152)            NOT NULL,

    `mother_family_name_at_birth`   varchar(50)             DEFAULT NULL,
    `mother_first_name_at_birth`    varchar(50)             DEFAULT NULL,
    `mother_middle_name_at_birth`   varchar(50)             DEFAULT NULL,
    `mother_date_of_birth`          date                    DEFAULT NULL,
    `mother_birth_place_id`         bigint(20) unsigned     DEFAULT NULL,

    `is_pehr_reachable`             bool                    DEFAULT false,

    `self_contact_id`               bigint(20) unsigned     DEFAULT NULL,
    `emergency_contact_id`          bigint(20) unsigned     DEFAULT NULL,
    `primary_practitioner_id`       bigint(20) unsigned     DEFAULT NULL,

    `date_of_death`                 date                    DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_fitm` (`feed_item_id`),
    UNIQUE KEY `idx_chart_number` (`chart_number`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),
    KEY `idx_feed` (`feed_alias`),
    KEY `idx_bitm` (`backend_item_id`),
    KEY `idx_dob` (`date_of_birth`),
    KEY `idx_pob` (`birth_place_id`),
    KEY `idx_nbnm` (`normalized_name_at_birth`),
    KEY `idx_lnm` (`family_name`),
    KEY `idx_mnm` (`middle_name`),
    KEY `idx_fnm` (`first_name`),
    KEY `idx_nnm` (`normalized_name`),
    KEY `idx_mpob` (`mother_birth_place_id`),
    KEY `idx_reach` (`is_pehr_reachable`),
    KEY `idx_scid` (`self_contact_id`),
    KEY `idx_ecid` (`emergency_contact_id`),
    KEY `idx_ppid` (`primary_practitioner_id`),
    KEY `idx_feed_alias_feed_item_id` (`feed_alias`, `feed_item_id`),
    KEY `idx_feed_alias_persisted` (`feed_alias`, `row_persisted`),
    CONSTRAINT `fk_patient_placeofbirth` FOREIGN KEY (`birth_place_id`) REFERENCES `BirthPlace` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_patient_motherplaceofbirth` FOREIGN KEY (`mother_birth_place_id`) REFERENCES `BirthPlace` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_patient_self_contact` FOREIGN KEY (`self_contact_id`) REFERENCES `Contact` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_patient_emergency_contact` FOREIGN KEY (`emergency_contact_id`) REFERENCES `Contact` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_patient_primary_practitioner` FOREIGN KEY (`primary_practitioner_id`) REFERENCES `Practitioner` (`id`) ON DELETE SET NULL

) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TRIGGER IF EXISTS `PatientVersion`;
DELIMITER $$
CREATE TRIGGER `PatientVersion` BEFORE UPDATE ON `Patient`
    FOR EACH ROW
BEGIN
    IF NEW.row_persisted = OLD.row_persisted  AND  NEW.chart_number = OLD.chart_number  THEN
        SET NEW.row_version = OLD.row_version + 1;
        SET NEW.row_persisted = CURRENT_TIMESTAMP(3);
    END IF;
END; $$
DELIMITER ;

DROP TRIGGER IF EXISTS `ContactPersistedPatient`;
CREATE TRIGGER `ContactPersistedPatient` AFTER UPDATE ON `Contact`
    FOR EACH ROW UPDATE `Patient` SET `row_persisted` = CURRENT_TIMESTAMP(3) WHERE `self_contact_id` = OLD.id OR `emergency_contact_id` = OLD.id;

DROP TRIGGER IF EXISTS `BirthPlacePersistedPatient`;
CREATE TRIGGER `BirthPlacePersistedPatient` AFTER UPDATE ON `BirthPlace`
    FOR EACH ROW UPDATE `Patient` SET `row_persisted` = CURRENT_TIMESTAMP(3) WHERE `birth_place_id` = OLD.id OR `mother_birth_place_id` = OLD.id;


DROP TRIGGER IF EXISTS `PatientLegitIdSeq`;

DROP TRIGGER IF EXISTS `PatientLegitIdPersistedPatient`;
CREATE TRIGGER `PatientLegitIdPersistedPatient` AFTER UPDATE ON `PatientLegitId`
    FOR EACH ROW UPDATE `Patient` SET `row_persisted` = CURRENT_TIMESTAMP(3) WHERE `id` = OLD.patient_id;

DROP TRIGGER IF EXISTS `DelPatientLegitIdPersistedPatient`;
CREATE TRIGGER `DelPatientLegitIdPersistedPatient` AFTER DELETE ON `PatientLegitId`
    FOR EACH ROW UPDATE `Patient` SET `row_persisted` = CURRENT_TIMESTAMP(3) WHERE `id` = OLD.patient_id;


CREATE OR REPLACE VIEW PatientUuid AS
    SELECT Patient.id AS id,
           BIN_TO_UUID(Patient.feed_item_id, 1) AS feed_item_uuid,
           BIN_TO_UUID(Patient.backend_item_id, 1) AS backend_item_uuid,
           Patient.family_name AS family_name,
           Patient.first_name as first_name,
           Patient.gender AS gender,
           Patient.date_of_birth AS birth_date,
           Contact.email as email,
           Contact.mobile_phone AS mobile_phone
    FROM Patient
    LEFT JOIN Contact ON Patient.self_contact_id = Contact.id;


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

    SET random16b = FLOOR( RAND() * 0x10000);                          --  0x0000 - 0xffff     NOT DETERMINISTIC
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


--
-- Table structure for table `PrivateMessageAttachment`
--


DROP TABLE IF EXISTS `PrivateMessageAttachment`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

CREATE TABLE `PrivateMessageAttachment` (
    `id`                bigint(20) unsigned         NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    `message_id`        bigint(20)  unsigned        NOT NULL,
    `feed_item_id`      binary(16)                  NOT NULL,
    `backend_item_id`   binary(16)                  DEFAULT NULL,

    `name`              varchar(128)                DEFAULT NULL,
    `original_creation` datetime                    NOT NULL,
    `mime_type`         varchar(128)                NOT NULL,
    `doc_as_b64`        longtext                    NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_fitm` (`feed_item_id`),
    KEY `idx_pract` (`message_id`),
    CONSTRAINT `fk_privatemessageattachment_message` FOREIGN KEY (`message_id`) REFERENCES `PrivateMessage` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TRIGGER IF EXISTS `PrivateMessageAttachmentVersion`;
CREATE TRIGGER `PrivateMessageAttachmentVersion` BEFORE UPDATE ON `PrivateMessageAttachment`
    FOR EACH ROW    SET NEW.row_version = OLD.row_version + 1;


--
-- Table structure for table `PrivateMessage`
--


DROP TABLE IF EXISTS `PrivateMessage`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PrivateMessage` (
    `id`                bigint(20) unsigned         NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,

    `feed_alias`        varchar(128)                NOT NULL,
    `feed_item_id`      binary(16)                  NOT NULL,
    `backend_item_id`   binary(16)                  DEFAULT NULL,

    `message_context`   varchar(128)                DEFAULT NULL,
    `subject`           varchar(128)                DEFAULT NULL,
    `text`              longtext                    NOT NULL,

    `status`            enum('received','notified','sent','reminded','fallback','failed','acknowledged','seen') DEFAULT NULL,

    `practitioner_id`   bigint(20) unsigned         NOT NULL,
    `patient_id`        bigint(20) unsigned         NOT NULL,

    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_fitm` (`feed_item_id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),
    KEY `idx_feed` (`feed_alias`),
    KEY `idx_bitm` (`backend_item_id`),
    KEY `idx_prid` (`practitioner_id`),
    KEY `idx_paid` (`patient_id`),
    KEY `idx_stat` (`status`),
    KEY `idx_feed_alias_feed_item_id` (`feed_alias`, `feed_item_id`),
    KEY `idx_feed_alias_persisted` (`feed_alias`, `row_persisted`),
    CONSTRAINT `fk_message_practitioner` FOREIGN KEY (`practitioner_id`) REFERENCES `Practitioner` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_message_patient` FOREIGN KEY (`patient_id`) REFERENCES `Patient` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TRIGGER IF EXISTS `PrivateMessageVersion`;
DELIMITER $$
CREATE TRIGGER `PrivateMessageVersion` BEFORE UPDATE ON `PrivateMessage`
    FOR EACH ROW
BEGIN
    IF NEW.row_persisted = OLD.row_persisted THEN
        SET NEW.row_version = OLD.row_version + 1;
        SET NEW.row_persisted = CURRENT_TIMESTAMP(3);
    END IF;
END; $$
DELIMITER ;


DROP TRIGGER IF EXISTS `PrivateMessageAttachmentPersistedPrivateMessage`;
CREATE TRIGGER `PrivateMessageAttachmentPersistedPrivateMessage` AFTER UPDATE ON `PrivateMessageAttachment`
    FOR EACH ROW UPDATE `PrivateMessage` SET `row_persisted` = CURRENT_TIMESTAMP(3) WHERE `id` = OLD.message_id;

DROP TRIGGER IF EXISTS `DelPrivateMessageAttachmentPersistedPrivateMessage`;
CREATE TRIGGER `DelPrivateMessageAttachmentPersistedPrivateMessage` AFTER DELETE ON `PrivateMessageAttachment`
    FOR EACH ROW UPDATE `PrivateMessage` SET `row_persisted` = CURRENT_TIMESTAMP(3) WHERE `id` = OLD.message_id;


CREATE OR REPLACE VIEW PrivateMessageUuid AS
    SELECT PrivateMessage.id AS id,
           BIN_TO_UUID(PrivateMessage.feed_item_id, 1) AS feed_item_uuid,
           BIN_TO_UUID(PrivateMessage.backend_item_id, 1) AS backend_item_uuid,
           Patient.first_name AS first_name,
           Patient.family_name AS last_name,
           PrivateMessage.row_created AS date_created,
           PrivateMessage.subject AS subject
    FROM PrivateMessage
    LEFT JOIN Patient ON PrivateMessage.patient_id = Patient.id;



--
-- Table structure for table `Rdv`
--


DROP TABLE IF EXISTS `Rdv`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Rdv`
(
    `id`                    bigint(20) unsigned                         NOT NULL AUTO_INCREMENT,
    `row_version`           int(10) unsigned                            NOT NULL DEFAULT 0,
    `row_created`           timestamp(3)                                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`         timestamp(3)                                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`           timestamp(3)                                DEFAULT NULL,

    `feed_alias`            varchar(128)                                NOT NULL,
    `feed_item_id`          binary(16)                                  NOT NULL,
    `backend_item_id`       binary(16)                                  DEFAULT NULL,

    `practitioner_id`       bigint(20) unsigned                         NOT NULL,
    `patient_id`            bigint(20) unsigned                         NOT NULL,
    `location`              enum('clinic','home','video','telephone')   NOT NULL,
    `description`           varchar(128)                                NOT NULL,
    `start_time`            datetime                                    NOT NULL,
    `end_time`              datetime                                    NOT NULL,
    `notes`                 text CHARACTER SET utf8,

    `confirmation_status`   enum('pending','confirmed','cancelled')     DEFAULT 'pending',
    `patient_must_confirm`  boolean                                     DEFAULT true,
    `patient_confirmed`     datetime                                    DEFAULT NULL,
    `patient_unconfirmed`   datetime                                    DEFAULT NULL,
    `patient_cancelled`     datetime                                    DEFAULT NULL,

    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_fitm` (`feed_item_id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),
    KEY `idx_feed` (`feed_alias`),
    KEY `idx_bitm` (`backend_item_id`),
    KEY `idx_pat_id` (`patient_id`),
    KEY `idx_pra_id` (`practitioner_id`),
    KEY `idx_feed_alias_feed_item_id` (`feed_alias`, `feed_item_id`),
    KEY `idx_feed_alias_persisted` (`feed_alias`, `row_persisted`),
    CONSTRAINT `fk_rdv_patient` FOREIGN KEY (`patient_id`) REFERENCES `Patient` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_rdv_practitioner` FOREIGN KEY (`practitioner_id`) REFERENCES `Practitioner` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TRIGGER IF EXISTS `RdvVersion`;
DELIMITER $$
CREATE TRIGGER `RdvVersion` BEFORE UPDATE ON `Rdv`
    FOR EACH ROW
BEGIN
    IF NEW.row_persisted = OLD.row_persisted THEN
        SET NEW.row_version = OLD.row_version + 1;
        SET NEW.row_persisted = CURRENT_TIMESTAMP(3);
    END IF;
    IF NEW.patient_cancelled IS NOT NULL THEN
        SET NEW.confirmation_status = 'cancelled';
    ELSEIF NEW.patient_confirmed IS NOT NULL AND (
           NEW.patient_unconfirmed IS NULL OR
           NEW.patient_confirmed >  NEW.patient_unconfirmed) THEN
        SET NEW.confirmation_status = 'confirmed';
    ELSEIF NEW.patient_unconfirmed IS NOT NULL THEN
        SET NEW.confirmation_status = 'pending';
    END IF;
END; $$
DELIMITER ;


CREATE OR REPLACE VIEW RdvUuid AS
    SELECT Rdv.id AS id,
           Rdv.feed_alias AS feed_alias,
           BIN_TO_UUID(Rdv.feed_item_id, 1) AS feed_item_uuid,
           BIN_TO_UUID(Rdv.backend_item_id, 1) AS backend_item_uuid,
           BIN_TO_UUID(Patient.feed_item_id, 1) AS patient_uuid,
           Patient.first_name AS patient_first_name,
           Patient.family_name AS patient_last_name,
           BIN_TO_UUID(Practitioner.feed_item_id, 1) AS practitioner_uuid,
           Practitioner.first_name AS practitioner_first_name,
           Practitioner.family_name AS practitioner_last_name,
           Rdv.row_created AS date_created,
           Rdv.description AS description,
           Rdv.start_time AS start_time,
           Rdv.end_time AS end_time,
           Rdv.notes AS notes,
           Rdv.confirmation_status AS confirmation_status
    FROM Rdv
    LEFT JOIN Patient ON Rdv.patient_id = Patient.id
    LEFT JOIN Practitioner ON Rdv.practitioner_id = Practitioner.id;



--
-- Table structure for table `Country`
--

DROP TABLE IF EXISTS `Country`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Country` (
    `iso2`      char(2)         NOT NULL,
    `iso3`      char(3)         NOT NULL,
    `name`      varchar(50)     NOT NULL,
    PRIMARY KEY (`iso2`),
    KEY `idx_iso3` (`iso3`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `Country` SET `iso2` = 'AF', `iso3` = 'AFG', `name` = 'Afghanistan';
INSERT INTO `Country` SET `iso2` = 'AL', `iso3` = 'ALB', `name` = 'Albania';
INSERT INTO `Country` SET `iso2` = 'DZ', `iso3` = 'DZA', `name` = 'Algeria';
INSERT INTO `Country` SET `iso2` = 'AS', `iso3` = 'ASM', `name` = 'American Samoa';
INSERT INTO `Country` SET `iso2` = 'AD', `iso3` = 'AND', `name` = 'Andorra';
INSERT INTO `Country` SET `iso2` = 'AO', `iso3` = 'AGO', `name` = 'Angola';
INSERT INTO `Country` SET `iso2` = 'AI', `iso3` = 'AIA', `name` = 'Anguilla';
INSERT INTO `Country` SET `iso2` = 'AQ', `iso3` = 'ATA', `name` = 'Antarctica';
INSERT INTO `Country` SET `iso2` = 'AG', `iso3` = 'ATG', `name` = 'Antigua and Barbuda';
INSERT INTO `Country` SET `iso2` = 'AR', `iso3` = 'ARG', `name` = 'Argentina';
INSERT INTO `Country` SET `iso2` = 'AM', `iso3` = 'ARM', `name` = 'Armenia';
INSERT INTO `Country` SET `iso2` = 'AW', `iso3` = 'ABW', `name` = 'Aruba';
INSERT INTO `Country` SET `iso2` = 'AU', `iso3` = 'AUS', `name` = 'Australia';
INSERT INTO `Country` SET `iso2` = 'AT', `iso3` = 'AUT', `name` = 'Austria';
INSERT INTO `Country` SET `iso2` = 'AZ', `iso3` = 'AZE', `name` = 'Azerbaijan';
INSERT INTO `Country` SET `iso2` = 'BS', `iso3` = 'BHS', `name` = 'Bahamas';
INSERT INTO `Country` SET `iso2` = 'BH', `iso3` = 'BHR', `name` = 'Bahrain';
INSERT INTO `Country` SET `iso2` = 'BD', `iso3` = 'BGD', `name` = 'Bangladesh';
INSERT INTO `Country` SET `iso2` = 'BB', `iso3` = 'BRB', `name` = 'Barbados';
INSERT INTO `Country` SET `iso2` = 'BY', `iso3` = 'BLR', `name` = 'Belarus';
INSERT INTO `Country` SET `iso2` = 'BE', `iso3` = 'BEL', `name` = 'Belgium';
INSERT INTO `Country` SET `iso2` = 'BZ', `iso3` = 'BLZ', `name` = 'Belize';
INSERT INTO `Country` SET `iso2` = 'BJ', `iso3` = 'BEN', `name` = 'Benin';
INSERT INTO `Country` SET `iso2` = 'BM', `iso3` = 'BMU', `name` = 'Bermuda';
INSERT INTO `Country` SET `iso2` = 'BT', `iso3` = 'BTN', `name` = 'Bhutan';
INSERT INTO `Country` SET `iso2` = 'BO', `iso3` = 'BOL', `name` = 'Bolivia';
INSERT INTO `Country` SET `iso2` = 'BQ', `iso3` = 'BES', `name` = 'Bonaire';
INSERT INTO `Country` SET `iso2` = 'BA', `iso3` = 'BIH', `name` = 'Bosnia and Herzegovina';
INSERT INTO `Country` SET `iso2` = 'BW', `iso3` = 'BWA', `name` = 'Botswana';
INSERT INTO `Country` SET `iso2` = 'BV', `iso3` = 'BVT', `name` = 'Bouvet Island';
INSERT INTO `Country` SET `iso2` = 'BR', `iso3` = 'BRA', `name` = 'Brazil';
INSERT INTO `Country` SET `iso2` = 'IO', `iso3` = 'IOT', `name` = 'British Indian Ocean Territory';
INSERT INTO `Country` SET `iso2` = 'BN', `iso3` = 'BRN', `name` = 'Brunei Darussalam';
INSERT INTO `Country` SET `iso2` = 'BG', `iso3` = 'BGR', `name` = 'Bulgaria';
INSERT INTO `Country` SET `iso2` = 'BF', `iso3` = 'BFA', `name` = 'Burkina Faso';
INSERT INTO `Country` SET `iso2` = 'BI', `iso3` = 'BDI', `name` = 'Burundi';
INSERT INTO `Country` SET `iso2` = 'KH', `iso3` = 'KHM', `name` = 'Cambodia';
INSERT INTO `Country` SET `iso2` = 'CM', `iso3` = 'CMR', `name` = 'Cameroon';
INSERT INTO `Country` SET `iso2` = 'CA', `iso3` = 'CAN', `name` = 'Canada';
INSERT INTO `Country` SET `iso2` = 'CV', `iso3` = 'CPV', `name` = 'Cape Verde';
INSERT INTO `Country` SET `iso2` = 'KY', `iso3` = 'CYM', `name` = 'Cayman Islands';
INSERT INTO `Country` SET `iso2` = 'CF', `iso3` = 'CAF', `name` = 'Central African Republic';
INSERT INTO `Country` SET `iso2` = 'TD', `iso3` = 'TCD', `name` = 'Chad';
INSERT INTO `Country` SET `iso2` = 'CL', `iso3` = 'CHL', `name` = 'Chile';
INSERT INTO `Country` SET `iso2` = 'CN', `iso3` = 'CHN', `name` = 'China';
INSERT INTO `Country` SET `iso2` = 'CX', `iso3` = 'CXR', `name` = 'Christmas Island';
INSERT INTO `Country` SET `iso2` = 'CC', `iso3` = 'CCK', `name` = 'Cocos (Keeling) Islands';
INSERT INTO `Country` SET `iso2` = 'CO', `iso3` = 'COL', `name` = 'Colombia';
INSERT INTO `Country` SET `iso2` = 'KM', `iso3` = 'COM', `name` = 'Comoros';
INSERT INTO `Country` SET `iso2` = 'CG', `iso3` = 'COG', `name` = 'Congo';
INSERT INTO `Country` SET `iso2` = 'CD', `iso3` = 'COD', `name` = 'Democratic Republic of the Congo';
INSERT INTO `Country` SET `iso2` = 'CK', `iso3` = 'COK', `name` = 'Cook Islands';
INSERT INTO `Country` SET `iso2` = 'CR', `iso3` = 'CRI', `name` = 'Costa Rica';
INSERT INTO `Country` SET `iso2` = 'HR', `iso3` = 'HRV', `name` = 'Croatia';
INSERT INTO `Country` SET `iso2` = 'CU', `iso3` = 'CUB', `name` = 'Cuba';
INSERT INTO `Country` SET `iso2` = 'CW', `iso3` = 'CUW', `name` = 'Curacao';
INSERT INTO `Country` SET `iso2` = 'CY', `iso3` = 'CYP', `name` = 'Cyprus';
INSERT INTO `Country` SET `iso2` = 'CZ', `iso3` = 'CZE', `name` = 'Czech Republic';
INSERT INTO `Country` SET `iso2` = 'CI', `iso3` = 'CIV', `name` = 'Cote d\'Ivoire';
INSERT INTO `Country` SET `iso2` = 'DK', `iso3` = 'DNK', `name` = 'Denmark';
INSERT INTO `Country` SET `iso2` = 'DJ', `iso3` = 'DJI', `name` = 'Djibouti';
INSERT INTO `Country` SET `iso2` = 'DM', `iso3` = 'DMA', `name` = 'Dominica';
INSERT INTO `Country` SET `iso2` = 'DO', `iso3` = 'DOM', `name` = 'Dominican Republic';
INSERT INTO `Country` SET `iso2` = 'EC', `iso3` = 'ECU', `name` = 'Ecuador';
INSERT INTO `Country` SET `iso2` = 'EG', `iso3` = 'EGY', `name` = 'Egypt';
INSERT INTO `Country` SET `iso2` = 'SV', `iso3` = 'SLV', `name` = 'El Salvador';
INSERT INTO `Country` SET `iso2` = 'GQ', `iso3` = 'GNQ', `name` = 'Equatorial Guinea';
INSERT INTO `Country` SET `iso2` = 'ER', `iso3` = 'ERI', `name` = 'Eritrea';
INSERT INTO `Country` SET `iso2` = 'EE', `iso3` = 'EST', `name` = 'Estonia';
INSERT INTO `Country` SET `iso2` = 'ET', `iso3` = 'ETH', `name` = 'Ethiopia';
INSERT INTO `Country` SET `iso2` = 'FK', `iso3` = 'FLK', `name` = 'Falkland Islands (Malvinas)';
INSERT INTO `Country` SET `iso2` = 'FO', `iso3` = 'FRO', `name` = 'Faroe Islands';
INSERT INTO `Country` SET `iso2` = 'FJ', `iso3` = 'FJI', `name` = 'Fiji';
INSERT INTO `Country` SET `iso2` = 'FI', `iso3` = 'FIN', `name` = 'Finland';
INSERT INTO `Country` SET `iso2` = 'FR', `iso3` = 'FRA', `name` = 'France';
INSERT INTO `Country` SET `iso2` = 'GF', `iso3` = 'GUF', `name` = 'French Guiana';
INSERT INTO `Country` SET `iso2` = 'PF', `iso3` = 'PYF', `name` = 'French Polynesia';
INSERT INTO `Country` SET `iso2` = 'TF', `iso3` = 'ATF', `name` = 'French Southern Territories';
INSERT INTO `Country` SET `iso2` = 'GA', `iso3` = 'GAB', `name` = 'Gabon';
INSERT INTO `Country` SET `iso2` = 'GM', `iso3` = 'GMB', `name` = 'Gambia';
INSERT INTO `Country` SET `iso2` = 'GE', `iso3` = 'GEO', `name` = 'Georgia';
INSERT INTO `Country` SET `iso2` = 'DE', `iso3` = 'DEU', `name` = 'Germany';
INSERT INTO `Country` SET `iso2` = 'GH', `iso3` = 'GHA', `name` = 'Ghana';
INSERT INTO `Country` SET `iso2` = 'GI', `iso3` = 'GIB', `name` = 'Gibraltar';
INSERT INTO `Country` SET `iso2` = 'GR', `iso3` = 'GRC', `name` = 'Greece';
INSERT INTO `Country` SET `iso2` = 'GL', `iso3` = 'GRL', `name` = 'Greenland';
INSERT INTO `Country` SET `iso2` = 'GD', `iso3` = 'GRD', `name` = 'Grenada';
INSERT INTO `Country` SET `iso2` = 'GP', `iso3` = 'GLP', `name` = 'Guadeloupe';
INSERT INTO `Country` SET `iso2` = 'GU', `iso3` = 'GUM', `name` = 'Guam';
INSERT INTO `Country` SET `iso2` = 'GT', `iso3` = 'GTM', `name` = 'Guatemala';
INSERT INTO `Country` SET `iso2` = 'GG', `iso3` = 'GGY', `name` = 'Guernsey';
INSERT INTO `Country` SET `iso2` = 'GN', `iso3` = 'GIN', `name` = 'Guinea';
INSERT INTO `Country` SET `iso2` = 'GW', `iso3` = 'GNB', `name` = 'Guinea-Bissau';
INSERT INTO `Country` SET `iso2` = 'GY', `iso3` = 'GUY', `name` = 'Guyana';
INSERT INTO `Country` SET `iso2` = 'HT', `iso3` = 'HTI', `name` = 'Haiti';
INSERT INTO `Country` SET `iso2` = 'HM', `iso3` = 'HMD', `name` = 'Heard Island and McDonald Islands';
INSERT INTO `Country` SET `iso2` = 'VA', `iso3` = 'VAT', `name` = 'Holy See (Vatican City State)';
INSERT INTO `Country` SET `iso2` = 'HN', `iso3` = 'HND', `name` = 'Honduras';
INSERT INTO `Country` SET `iso2` = 'HK', `iso3` = 'HKG', `name` = 'Hong Kong';
INSERT INTO `Country` SET `iso2` = 'HU', `iso3` = 'HUN', `name` = 'Hungary';
INSERT INTO `Country` SET `iso2` = 'IS', `iso3` = 'ISL', `name` = 'Iceland';
INSERT INTO `Country` SET `iso2` = 'IN', `iso3` = 'IND', `name` = 'India';
INSERT INTO `Country` SET `iso2` = 'ID', `iso3` = 'IDN', `name` = 'Indonesia';
INSERT INTO `Country` SET `iso2` = 'IR', `iso3` = 'IRN', `name` = 'Iran, Islamic Republic of';
INSERT INTO `Country` SET `iso2` = 'IQ', `iso3` = 'IRQ', `name` = 'Iraq';
INSERT INTO `Country` SET `iso2` = 'IE', `iso3` = 'IRL', `name` = 'Ireland';
INSERT INTO `Country` SET `iso2` = 'IM', `iso3` = 'IMN', `name` = 'Isle of Man';
INSERT INTO `Country` SET `iso2` = 'IL', `iso3` = 'ISR', `name` = 'Israel';
INSERT INTO `Country` SET `iso2` = 'IT', `iso3` = 'ITA', `name` = 'Italy';
INSERT INTO `Country` SET `iso2` = 'JM', `iso3` = 'JAM', `name` = 'Jamaica';
INSERT INTO `Country` SET `iso2` = 'JP', `iso3` = 'JPN', `name` = 'Japan';
INSERT INTO `Country` SET `iso2` = 'JE', `iso3` = 'JEY', `name` = 'Jersey';
INSERT INTO `Country` SET `iso2` = 'JO', `iso3` = 'JOR', `name` = 'Jordan';
INSERT INTO `Country` SET `iso2` = 'KZ', `iso3` = 'KAZ', `name` = 'Kazakhstan';
INSERT INTO `Country` SET `iso2` = 'KE', `iso3` = 'KEN', `name` = 'Kenya';
INSERT INTO `Country` SET `iso2` = 'KI', `iso3` = 'KIR', `name` = 'Kiribati';
INSERT INTO `Country` SET `iso2` = 'KP', `iso3` = 'PRK', `name` = 'Korea, Democratic People\'s Republic of';
INSERT INTO `Country` SET `iso2` = 'KR', `iso3` = 'KOR', `name` = 'Korea, Republic of';
INSERT INTO `Country` SET `iso2` = 'KW', `iso3` = 'KWT', `name` = 'Kuwait';
INSERT INTO `Country` SET `iso2` = 'KG', `iso3` = 'KGZ', `name` = 'Kyrgyzstan';
INSERT INTO `Country` SET `iso2` = 'LA', `iso3` = 'LAO', `name` = 'Lao People\'s Democratic Republic';
INSERT INTO `Country` SET `iso2` = 'LV', `iso3` = 'LVA', `name` = 'Latvia';
INSERT INTO `Country` SET `iso2` = 'LB', `iso3` = 'LBN', `name` = 'Lebanon';
INSERT INTO `Country` SET `iso2` = 'LS', `iso3` = 'LSO', `name` = 'Lesotho';
INSERT INTO `Country` SET `iso2` = 'LR', `iso3` = 'LBR', `name` = 'Liberia';
INSERT INTO `Country` SET `iso2` = 'LY', `iso3` = 'LBY', `name` = 'Libya';
INSERT INTO `Country` SET `iso2` = 'LI', `iso3` = 'LIE', `name` = 'Liechtenstein';
INSERT INTO `Country` SET `iso2` = 'LT', `iso3` = 'LTU', `name` = 'Lithuania';
INSERT INTO `Country` SET `iso2` = 'LU', `iso3` = 'LUX', `name` = 'Luxembourg';
INSERT INTO `Country` SET `iso2` = 'MO', `iso3` = 'MAC', `name` = 'Macao';
INSERT INTO `Country` SET `iso2` = 'MK', `iso3` = 'MKD', `name` = 'Macedonia, the Former Yugoslav Republic of';
INSERT INTO `Country` SET `iso2` = 'MG', `iso3` = 'MDG', `name` = 'Madagascar';
INSERT INTO `Country` SET `iso2` = 'MW', `iso3` = 'MWI', `name` = 'Malawi';
INSERT INTO `Country` SET `iso2` = 'MY', `iso3` = 'MYS', `name` = 'Malaysia';
INSERT INTO `Country` SET `iso2` = 'MV', `iso3` = 'MDV', `name` = 'Maldives';
INSERT INTO `Country` SET `iso2` = 'ML', `iso3` = 'MLI', `name` = 'Mali';
INSERT INTO `Country` SET `iso2` = 'MT', `iso3` = 'MLT', `name` = 'Malta';
INSERT INTO `Country` SET `iso2` = 'MH', `iso3` = 'MHL', `name` = 'Marshall Islands';
INSERT INTO `Country` SET `iso2` = 'MQ', `iso3` = 'MTQ', `name` = 'Martinique';
INSERT INTO `Country` SET `iso2` = 'MR', `iso3` = 'MRT', `name` = 'Mauritania';
INSERT INTO `Country` SET `iso2` = 'MU', `iso3` = 'MUS', `name` = 'Mauritius';
INSERT INTO `Country` SET `iso2` = 'YT', `iso3` = 'MYT', `name` = 'Mayotte';
INSERT INTO `Country` SET `iso2` = 'MX', `iso3` = 'MEX', `name` = 'Mexico';
INSERT INTO `Country` SET `iso2` = 'FM', `iso3` = 'FSM', `name` = 'Micronesia, Federated States of';
INSERT INTO `Country` SET `iso2` = 'MD', `iso3` = 'MDA', `name` = 'Moldova, Republic of';
INSERT INTO `Country` SET `iso2` = 'MC', `iso3` = 'MCO', `name` = 'Monaco';
INSERT INTO `Country` SET `iso2` = 'MN', `iso3` = 'MNG', `name` = 'Mongolia';
INSERT INTO `Country` SET `iso2` = 'ME', `iso3` = 'MNE', `name` = 'Montenegro';
INSERT INTO `Country` SET `iso2` = 'MS', `iso3` = 'MSR', `name` = 'Montserrat';
INSERT INTO `Country` SET `iso2` = 'MA', `iso3` = 'MAR', `name` = 'Morocco';
INSERT INTO `Country` SET `iso2` = 'MZ', `iso3` = 'MOZ', `name` = 'Mozambique';
INSERT INTO `Country` SET `iso2` = 'MM', `iso3` = 'MMR', `name` = 'Myanmar';
INSERT INTO `Country` SET `iso2` = 'NA', `iso3` = 'NAM', `name` = 'Namibia';
INSERT INTO `Country` SET `iso2` = 'NR', `iso3` = 'NRU', `name` = 'Nauru';
INSERT INTO `Country` SET `iso2` = 'NP', `iso3` = 'NPL', `name` = 'Nepal';
INSERT INTO `Country` SET `iso2` = 'NL', `iso3` = 'NLD', `name` = 'Netherlands';
INSERT INTO `Country` SET `iso2` = 'NC', `iso3` = 'NCL', `name` = 'New Caledonia';
INSERT INTO `Country` SET `iso2` = 'NZ', `iso3` = 'NZL', `name` = 'New Zealand';
INSERT INTO `Country` SET `iso2` = 'NI', `iso3` = 'NIC', `name` = 'Nicaragua';
INSERT INTO `Country` SET `iso2` = 'NE', `iso3` = 'NER', `name` = 'Niger';
INSERT INTO `Country` SET `iso2` = 'NG', `iso3` = 'NGA', `name` = 'Nigeria';
INSERT INTO `Country` SET `iso2` = 'NU', `iso3` = 'NIU', `name` = 'Niue';
INSERT INTO `Country` SET `iso2` = 'NF', `iso3` = 'NFK', `name` = 'Norfolk Island';
INSERT INTO `Country` SET `iso2` = 'MP', `iso3` = 'MNP', `name` = 'Northern Mariana Islands';
INSERT INTO `Country` SET `iso2` = 'NO', `iso3` = 'NOR', `name` = 'Norway';
INSERT INTO `Country` SET `iso2` = 'OM', `iso3` = 'OMN', `name` = 'Oman';
INSERT INTO `Country` SET `iso2` = 'PK', `iso3` = 'PAK', `name` = 'Pakistan';
INSERT INTO `Country` SET `iso2` = 'PW', `iso3` = 'PLW', `name` = 'Palau';
INSERT INTO `Country` SET `iso2` = 'PS', `iso3` = 'PSE', `name` = 'Palestine, State of';
INSERT INTO `Country` SET `iso2` = 'PA', `iso3` = 'PAN', `name` = 'Panama';
INSERT INTO `Country` SET `iso2` = 'PG', `iso3` = 'PNG', `name` = 'Papua New Guinea';
INSERT INTO `Country` SET `iso2` = 'PY', `iso3` = 'PRY', `name` = 'Paraguay';
INSERT INTO `Country` SET `iso2` = 'PE', `iso3` = 'PER', `name` = 'Peru';
INSERT INTO `Country` SET `iso2` = 'PH', `iso3` = 'PHL', `name` = 'Philippines';
INSERT INTO `Country` SET `iso2` = 'PN', `iso3` = 'PCN', `name` = 'Pitcairn';
INSERT INTO `Country` SET `iso2` = 'PL', `iso3` = 'POL', `name` = 'Poland';
INSERT INTO `Country` SET `iso2` = 'PT', `iso3` = 'PRT', `name` = 'Portugal';
INSERT INTO `Country` SET `iso2` = 'PR', `iso3` = 'PRI', `name` = 'Puerto Rico';
INSERT INTO `Country` SET `iso2` = 'QA', `iso3` = 'QAT', `name` = 'Qatar';
INSERT INTO `Country` SET `iso2` = 'RO', `iso3` = 'ROU', `name` = 'Romania';
INSERT INTO `Country` SET `iso2` = 'RU', `iso3` = 'RUS', `name` = 'Russian Federation';
INSERT INTO `Country` SET `iso2` = 'RW', `iso3` = 'RWA', `name` = 'Rwanda';
INSERT INTO `Country` SET `iso2` = 'RE', `iso3` = 'REU', `name` = 'Reunion';
INSERT INTO `Country` SET `iso2` = 'BL', `iso3` = 'BLM', `name` = 'Saint Barthelemy';
INSERT INTO `Country` SET `iso2` = 'SH', `iso3` = 'SHN', `name` = 'Saint Helena';
INSERT INTO `Country` SET `iso2` = 'KN', `iso3` = 'KNA', `name` = 'Saint Kitts and Nevis';
INSERT INTO `Country` SET `iso2` = 'LC', `iso3` = 'LCA', `name` = 'Saint Lucia';
INSERT INTO `Country` SET `iso2` = 'MF', `iso3` = 'MAF', `name` = 'Saint Martin (French part)';
INSERT INTO `Country` SET `iso2` = 'PM', `iso3` = 'SPM', `name` = 'Saint Pierre and Miquelon';
INSERT INTO `Country` SET `iso2` = 'VC', `iso3` = 'VCT', `name` = 'Saint Vincent and the Grenadines';
INSERT INTO `Country` SET `iso2` = 'WS', `iso3` = 'WSM', `name` = 'Samoa';
INSERT INTO `Country` SET `iso2` = 'SM', `iso3` = 'SMR', `name` = 'San Marino';
INSERT INTO `Country` SET `iso2` = 'ST', `iso3` = 'STP', `name` = 'Sao Tome and Principe';
INSERT INTO `Country` SET `iso2` = 'SA', `iso3` = 'SAU', `name` = 'Saudi Arabia';
INSERT INTO `Country` SET `iso2` = 'SN', `iso3` = 'SEN', `name` = 'Senegal';
INSERT INTO `Country` SET `iso2` = 'RS', `iso3` = 'SRB', `name` = 'Serbia';
INSERT INTO `Country` SET `iso2` = 'SC', `iso3` = 'SYC', `name` = 'Seychelles';
INSERT INTO `Country` SET `iso2` = 'SL', `iso3` = 'SLE', `name` = 'Sierra Leone';
INSERT INTO `Country` SET `iso2` = 'SG', `iso3` = 'SGP', `name` = 'Singapore';
INSERT INTO `Country` SET `iso2` = 'SX', `iso3` = 'SXM', `name` = 'Sint Maarten (Dutch part)';
INSERT INTO `Country` SET `iso2` = 'SK', `iso3` = 'SVK', `name` = 'Slovakia';
INSERT INTO `Country` SET `iso2` = 'SI', `iso3` = 'SVN', `name` = 'Slovenia';
INSERT INTO `Country` SET `iso2` = 'SB', `iso3` = 'SLB', `name` = 'Solomon Islands';
INSERT INTO `Country` SET `iso2` = 'SO', `iso3` = 'SOM', `name` = 'Somalia';
INSERT INTO `Country` SET `iso2` = 'ZA', `iso3` = 'ZAF', `name` = 'South Africa';
INSERT INTO `Country` SET `iso2` = 'GS', `iso3` = 'SGS', `name` = 'South Georgia and the South Sandwich Islands';
INSERT INTO `Country` SET `iso2` = 'SS', `iso3` = 'SSD', `name` = 'South Sudan';
INSERT INTO `Country` SET `iso2` = 'ES', `iso3` = 'ESP', `name` = 'Spain';
INSERT INTO `Country` SET `iso2` = 'LK', `iso3` = 'LKA', `name` = 'Sri Lanka';
INSERT INTO `Country` SET `iso2` = 'SD', `iso3` = 'SDN', `name` = 'Sudan';
INSERT INTO `Country` SET `iso2` = 'SR', `iso3` = 'SUR', `name` = 'Suriname';
INSERT INTO `Country` SET `iso2` = 'SJ', `iso3` = 'SJM', `name` = 'Svalbard and Jan Mayen';
INSERT INTO `Country` SET `iso2` = 'SZ', `iso3` = 'SWZ', `name` = 'Swaziland';
INSERT INTO `Country` SET `iso2` = 'SE', `iso3` = 'SWE', `name` = 'Sweden';
INSERT INTO `Country` SET `iso2` = 'CH', `iso3` = 'CHE', `name` = 'Switzerland';
INSERT INTO `Country` SET `iso2` = 'SY', `iso3` = 'SYR', `name` = 'Syrian Arab Republic';
INSERT INTO `Country` SET `iso2` = 'TW', `iso3` = 'TWN', `name` = 'Taiwan';
INSERT INTO `Country` SET `iso2` = 'TJ', `iso3` = 'TJK', `name` = 'Tajikistan';
INSERT INTO `Country` SET `iso2` = 'TZ', `iso3` = 'TZA', `name` = 'United Republic of Tanzania';
INSERT INTO `Country` SET `iso2` = 'TH', `iso3` = 'THA', `name` = 'Thailand';
INSERT INTO `Country` SET `iso2` = 'TL', `iso3` = 'TLS', `name` = 'Timor-Leste';
INSERT INTO `Country` SET `iso2` = 'TG', `iso3` = 'TGO', `name` = 'Togo';
INSERT INTO `Country` SET `iso2` = 'TK', `iso3` = 'TKL', `name` = 'Tokelau';
INSERT INTO `Country` SET `iso2` = 'TO', `iso3` = 'TON', `name` = 'Tonga';
INSERT INTO `Country` SET `iso2` = 'TT', `iso3` = 'TTO', `name` = 'Trinidad and Tobago';
INSERT INTO `Country` SET `iso2` = 'TN', `iso3` = 'TUN', `name` = 'Tunisia';
INSERT INTO `Country` SET `iso2` = 'TR', `iso3` = 'TUR', `name` = 'Turkey';
INSERT INTO `Country` SET `iso2` = 'TM', `iso3` = 'TKM', `name` = 'Turkmenistan';
INSERT INTO `Country` SET `iso2` = 'TC', `iso3` = 'TCA', `name` = 'Turks and Caicos Islands';
INSERT INTO `Country` SET `iso2` = 'TV', `iso3` = 'TUV', `name` = 'Tuvalu';
INSERT INTO `Country` SET `iso2` = 'UG', `iso3` = 'UGA', `name` = 'Uganda';
INSERT INTO `Country` SET `iso2` = 'UA', `iso3` = 'UKR', `name` = 'Ukraine';
INSERT INTO `Country` SET `iso2` = 'AE', `iso3` = 'ARE', `name` = 'United Arab Emirates';
INSERT INTO `Country` SET `iso2` = 'GB', `iso3` = 'GBR', `name` = 'United Kingdom';
INSERT INTO `Country` SET `iso2` = 'US', `iso3` = 'USA', `name` = 'United States';
INSERT INTO `Country` SET `iso2` = 'UM', `iso3` = 'UMI', `name` = 'United States Minor Outlying Islands';
INSERT INTO `Country` SET `iso2` = 'UY', `iso3` = 'URY', `name` = 'Uruguay';
INSERT INTO `Country` SET `iso2` = 'UZ', `iso3` = 'UZB', `name` = 'Uzbekistan';
INSERT INTO `Country` SET `iso2` = 'VU', `iso3` = 'VUT', `name` = 'Vanuatu';
INSERT INTO `Country` SET `iso2` = 'VE', `iso3` = 'VEN', `name` = 'Venezuela';
INSERT INTO `Country` SET `iso2` = 'VN', `iso3` = 'VNM', `name` = 'Viet Nam';
INSERT INTO `Country` SET `iso2` = 'VG', `iso3` = 'VGB', `name` = 'British Virgin Islands';
INSERT INTO `Country` SET `iso2` = 'VI', `iso3` = 'VIR', `name` = 'US Virgin Islands';
INSERT INTO `Country` SET `iso2` = 'WF', `iso3` = 'WLF', `name` = 'Wallis and Futuna';
INSERT INTO `Country` SET `iso2` = 'EH', `iso3` = 'ESH', `name` = 'Western Sahara';
INSERT INTO `Country` SET `iso2` = 'YE', `iso3` = 'YEM', `name` = 'Yemen';
INSERT INTO `Country` SET `iso2` = 'ZM', `iso3` = 'ZMB', `name` = 'Zambia';
INSERT INTO `Country` SET `iso2` = 'ZW', `iso3` = 'ZWE', `name` = 'Zimbabwe';

/*!40101 SET character_set_client = @saved_cs_client */;



--
-- Table structure for table `SubCountryKind`
--

DROP TABLE IF EXISTS `SubCountryKind`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SubCountryKind` (
    `id`            bigint(20) unsigned     NOT NULL AUTO_INCREMENT,
    `country_iso2`  char(2)                 NOT NULL,
    `language_iso2` char(2)                 NOT NULL,
    `name`          varchar(50)             NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_country_iso2` (`country_iso2`),
    CONSTRAINT `fk_subcountrykind_country` FOREIGN KEY (`country_iso2`) REFERENCES `Country` (`iso2`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `SubCountryKind` SET `country_iso2` = 'CA', `language_iso2` = 'en', `name` = 'Province / Territory';
INSERT INTO `SubCountryKind` SET `country_iso2` = 'US', `language_iso2` = 'en', `name` = 'State';
INSERT INTO `SubCountryKind` SET `country_iso2` = 'CA', `language_iso2` = 'fr', `name` = 'Province / Territoire';
INSERT INTO `SubCountryKind` SET `country_iso2` = 'US', `language_iso2` = 'fr', `name` = 'État';

/*!40101 SET character_set_client = @saved_cs_client */;



--
-- Table structure for table `SubCountry`
--

DROP TABLE IF EXISTS `SubCountry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SubCountry` (
    `id`                bigint(20) unsigned     NOT NULL AUTO_INCREMENT,
    `country_iso2`      char(2)                 NOT NULL,
    `subcountry_code2`  char(2)                 NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_country_subcountry` (`country_iso2`, `subcountry_code2`),
    KEY `idx_country_iso2` (`country_iso2`),
    CONSTRAINT `fk_subcountrycountry` FOREIGN KEY (`country_iso2`) REFERENCES `Country` (`iso2`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `SubCountry` SET `country_iso2` = 'CA', `subcountry_code2` = 'QC';
INSERT INTO `SubCountry` SET `country_iso2` = 'CA', `subcountry_code2` = 'ON';
INSERT INTO `SubCountry` SET `country_iso2` = 'CA', `subcountry_code2` = 'AB';
INSERT INTO `SubCountry` SET `country_iso2` = 'CA', `subcountry_code2` = 'BC';
INSERT INTO `SubCountry` SET `country_iso2` = 'CA', `subcountry_code2` = 'MB';
INSERT INTO `SubCountry` SET `country_iso2` = 'CA', `subcountry_code2` = 'NB';
INSERT INTO `SubCountry` SET `country_iso2` = 'CA', `subcountry_code2` = 'NL';
INSERT INTO `SubCountry` SET `country_iso2` = 'CA', `subcountry_code2` = 'NS';
INSERT INTO `SubCountry` SET `country_iso2` = 'CA', `subcountry_code2` = 'NT';
INSERT INTO `SubCountry` SET `country_iso2` = 'CA', `subcountry_code2` = 'NU';
INSERT INTO `SubCountry` SET `country_iso2` = 'CA', `subcountry_code2` = 'PE';
INSERT INTO `SubCountry` SET `country_iso2` = 'CA', `subcountry_code2` = 'SK';
INSERT INTO `SubCountry` SET `country_iso2` = 'CA', `subcountry_code2` = 'YT';

INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'AK';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'AL';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'AR';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'AS';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'AZ';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'CA';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'CO';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'CT';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'DC';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'DE';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'FL';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'GA';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'GU';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'HI';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'IA';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'ID';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'IL';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'IN';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'KS';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'KY';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'LA';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'MA';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'MD';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'ME';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'MI';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'MN';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'MO';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'MS';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'MT';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'NC';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'ND';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'NE';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'NH';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'NJ';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'NM';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'NV';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'NY';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'OH';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'OK';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'OR';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'PA';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'PR';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'RI';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'SC';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'SD';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'TN';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'TX';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'UT';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'VA';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'VI';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'VT';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'WA';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'WI';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'WV';
INSERT INTO `SubCountry` SET `country_iso2` = 'US', `subcountry_code2` = 'WY';

/*!40101 SET character_set_client = @saved_cs_client */;



--
-- Table structure for table `SubCountryName`
--

DROP TABLE IF EXISTS `SubCountryName`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SubCountryName` (
    `id`                bigint(20) unsigned     NOT NULL AUTO_INCREMENT,
    `country_iso2`      char(2)                 NOT NULL,
    `subcountry_code2`  char(2)                 NOT NULL,
    `language_iso2`     char(2)                 NOT NULL,
    `name`              varchar(50)             NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_country_subcountry_language` (`country_iso2`, `subcountry_code2`, `language_iso2`),
    KEY `idx_country_subcountry` (`country_iso2`, `subcountry_code2`),
    CONSTRAINT `fk_subcountryname_subcountry` FOREIGN KEY (`country_iso2`, `subcountry_code2`) REFERENCES `SubCountry` (`country_iso2`, `subcountry_code2`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'QC', `language_iso2` = 'en', `name` = 'Quebec';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'ON', `language_iso2` = 'en', `name` = 'Ontario';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'AB', `language_iso2` = 'en', `name` = 'Alberta';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'BC', `language_iso2` = 'en', `name` = 'British Columbia';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'MB', `language_iso2` = 'en', `name` = 'Manitoba';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'NB', `language_iso2` = 'en', `name` = 'New Brunswick';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'NL', `language_iso2` = 'en', `name` = 'Newfoundland and Labrador';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'NS', `language_iso2` = 'en', `name` = 'Nova Scotia';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'NT', `language_iso2` = 'en', `name` = 'Northwest Territories';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'NU', `language_iso2` = 'en', `name` = 'Nunavut';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'PE', `language_iso2` = 'en', `name` = 'Prince Edward Island';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'SK', `language_iso2` = 'en', `name` = 'Saskatchewan';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'YT', `language_iso2` = 'en', `name` = 'Yukon';

INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'QC', `language_iso2` = 'fr', `name` = 'Québec';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'ON', `language_iso2` = 'fr', `name` = 'Ontario';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'AB', `language_iso2` = 'fr', `name` = 'Alberta';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'BC', `language_iso2` = 'fr', `name` = 'Colombie-Britannique';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'MB', `language_iso2` = 'fr', `name` = 'Manitoba';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'NB', `language_iso2` = 'fr', `name` = 'Nouveau-Brunswick';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'NL', `language_iso2` = 'fr', `name` = 'Terre-Neuve-et-Labrador';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'NS', `language_iso2` = 'fr', `name` = 'Nouvelle-Écosse';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'NT', `language_iso2` = 'fr', `name` = 'Territoires du Nord-Ouest';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'NU', `language_iso2` = 'fr', `name` = 'Nunavut';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'PE', `language_iso2` = 'fr', `name` = 'Île-du-Prince-Édouard';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'SK', `language_iso2` = 'fr', `name` = 'Saskatchewan';
INSERT INTO `SubCountryName` SET `country_iso2` = 'CA', `subcountry_code2` = 'YT', `language_iso2` = 'fr', `name` = 'Yukon';

INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'AK', `language_iso2` = 'en', `name` = 'Alaska';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'AL', `language_iso2` = 'en', `name` = 'Alabama';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'AR', `language_iso2` = 'en', `name` = 'Arkansas';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'AS', `language_iso2` = 'en', `name` = 'American Samoa';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'AZ', `language_iso2` = 'en', `name` = 'Arizona';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'CA', `language_iso2` = 'en', `name` = 'California';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'CO', `language_iso2` = 'en', `name` = 'Colorado';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'CT', `language_iso2` = 'en', `name` = 'Connecticut';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'DC', `language_iso2` = 'en', `name` = 'District of Columbia';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'DE', `language_iso2` = 'en', `name` = 'Delaware';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'FL', `language_iso2` = 'en', `name` = 'Florida';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'GA', `language_iso2` = 'en', `name` = 'Georgia';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'GU', `language_iso2` = 'en', `name` = 'Guam';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'HI', `language_iso2` = 'en', `name` = 'Hawaii';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'IA', `language_iso2` = 'en', `name` = 'Iowa';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'ID', `language_iso2` = 'en', `name` = 'Idaho';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'IL', `language_iso2` = 'en', `name` = 'Illinois';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'IN', `language_iso2` = 'en', `name` = 'Indiana';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'KS', `language_iso2` = 'en', `name` = 'Kansas';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'KY', `language_iso2` = 'en', `name` = 'Kentucky';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'LA', `language_iso2` = 'en', `name` = 'Louisiana';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MA', `language_iso2` = 'en', `name` = 'Massachusetts';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MD', `language_iso2` = 'en', `name` = 'Maryland';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'ME', `language_iso2` = 'en', `name` = 'Maine';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MI', `language_iso2` = 'en', `name` = 'Michigan';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MN', `language_iso2` = 'en', `name` = 'Minnesota';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MO', `language_iso2` = 'en', `name` = 'Missouri';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MP', `language_iso2` = 'en', `name` = 'Northern Mariana Islands';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MS', `language_iso2` = 'en', `name` = 'Mississippi';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MT', `language_iso2` = 'en', `name` = 'Montana';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NC', `language_iso2` = 'en', `name` = 'North Carolina';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'ND', `language_iso2` = 'en', `name` = 'North Dakota';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NE', `language_iso2` = 'en', `name` = 'Nebraska';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NH', `language_iso2` = 'en', `name` = 'New Hampshire';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NJ', `language_iso2` = 'en', `name` = 'New Jersey';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NM', `language_iso2` = 'en', `name` = 'New Mexico';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NV', `language_iso2` = 'en', `name` = 'Nevada';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NY', `language_iso2` = 'en', `name` = 'New York';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'OH', `language_iso2` = 'en', `name` = 'Ohio';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'OK', `language_iso2` = 'en', `name` = 'Oklahoma';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'OR', `language_iso2` = 'en', `name` = 'Oregon';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'PA', `language_iso2` = 'en', `name` = 'Pennsylvania';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'PR', `language_iso2` = 'en', `name` = 'Puerto Rico';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'RI', `language_iso2` = 'en', `name` = 'Rhode Island';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'SC', `language_iso2` = 'en', `name` = 'South Carolina';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'SD', `language_iso2` = 'en', `name` = 'South Dakota';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'TN', `language_iso2` = 'en', `name` = 'Tennessee';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'TX', `language_iso2` = 'en', `name` = 'Texas';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'UM', `language_iso2` = 'en', `name` = 'United-States Minor Outlying Islands';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'UT', `language_iso2` = 'en', `name` = 'Utah';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'VA', `language_iso2` = 'en', `name` = 'Virginia';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'VI', `language_iso2` = 'en', `name` = 'U.S. Virgin Islands';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'VT', `language_iso2` = 'en', `name` = 'Vermont';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'WA', `language_iso2` = 'en', `name` = 'Washington';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'WI', `language_iso2` = 'en', `name` = 'Wisconsin';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'WV', `language_iso2` = 'en', `name` = 'West Virginia';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'WY', `language_iso2` = 'en', `name` = 'Wyoming';

INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'AK', `language_iso2` = 'fr', `name` = 'Alaska';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'AL', `language_iso2` = 'fr', `name` = 'Alabama';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'AR', `language_iso2` = 'fr', `name` = 'Arkansas';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'AS', `language_iso2` = 'fr', `name` = 'Samoa américaines';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'AZ', `language_iso2` = 'fr', `name` = 'Arizona';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'CA', `language_iso2` = 'fr', `name` = 'Californie';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'CO', `language_iso2` = 'fr', `name` = 'Colorado';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'CT', `language_iso2` = 'fr', `name` = 'Connecticut';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'DC', `language_iso2` = 'fr', `name` = 'District de Columbia';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'DE', `language_iso2` = 'fr', `name` = 'Delaware';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'FL', `language_iso2` = 'fr', `name` = 'Floride';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'GA', `language_iso2` = 'fr', `name` = 'Géorgie';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'GU', `language_iso2` = 'fr', `name` = 'Guam';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'HI', `language_iso2` = 'fr', `name` = 'Hawaï';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'IA', `language_iso2` = 'fr', `name` = 'Iowa';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'ID', `language_iso2` = 'fr', `name` = 'Idaho';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'IL', `language_iso2` = 'fr', `name` = 'Illinois';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'IN', `language_iso2` = 'fr', `name` = 'Indiana';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'KS', `language_iso2` = 'fr', `name` = 'Kansas';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'KY', `language_iso2` = 'fr', `name` = 'Kentucky';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'LA', `language_iso2` = 'fr', `name` = 'Louisiane';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MA', `language_iso2` = 'fr', `name` = 'Massachusetts';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MD', `language_iso2` = 'fr', `name` = 'Maryland';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'ME', `language_iso2` = 'fr', `name` = 'Maine';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MI', `language_iso2` = 'fr', `name` = 'Michigan';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MN', `language_iso2` = 'fr', `name` = 'Minnesota';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MO', `language_iso2` = 'fr', `name` = 'Missouri';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MP', `language_iso2` = 'fr', `name` = 'Îles Mariannes du Nord';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MS', `language_iso2` = 'fr', `name` = 'Mississippi';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'MT', `language_iso2` = 'fr', `name` = 'Montana';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NC', `language_iso2` = 'fr', `name` = 'Caroline du Nord';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'ND', `language_iso2` = 'fr', `name` = 'Dakota du Nord';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NE', `language_iso2` = 'fr', `name` = 'Nebraska';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NH', `language_iso2` = 'fr', `name` = 'New Hampshire';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NJ', `language_iso2` = 'fr', `name` = 'New Jersey';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NM', `language_iso2` = 'fr', `name` = 'Nouveau-Mexico';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NV', `language_iso2` = 'fr', `name` = 'Nevada';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'NY', `language_iso2` = 'fr', `name` = 'New York';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'OH', `language_iso2` = 'fr', `name` = 'Ohio';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'OK', `language_iso2` = 'fr', `name` = 'Oklahoma';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'OR', `language_iso2` = 'fr', `name` = 'Oregon';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'PA', `language_iso2` = 'fr', `name` = 'Pennsylvanie';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'PR', `language_iso2` = 'fr', `name` = 'Porto Rico';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'RI', `language_iso2` = 'fr', `name` = 'Rhode Island';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'SC', `language_iso2` = 'fr', `name` = 'Caroline du Sud';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'SD', `language_iso2` = 'fr', `name` = 'Dakota du Sud';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'TN', `language_iso2` = 'fr', `name` = 'Tennessee';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'TX', `language_iso2` = 'fr', `name` = 'Texas';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'UM', `language_iso2` = 'fr', `name` = 'Îles mineures éloignées des États-Unis';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'UT', `language_iso2` = 'fr', `name` = 'Utah';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'VA', `language_iso2` = 'fr', `name` = 'Virginie';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'VI', `language_iso2` = 'fr', `name` = 'Îles Vierges américaines';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'VT', `language_iso2` = 'fr', `name` = 'Vermont';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'WA', `language_iso2` = 'fr', `name` = 'Washington';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'WI', `language_iso2` = 'fr', `name` = 'Wisconsin';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'WV', `language_iso2` = 'fr', `name` = 'Virginie-Occidentale';
INSERT INTO `SubCountryName` SET `country_iso2` = 'US', `subcountry_code2` = 'WY', `language_iso2` = 'fr', `name` = 'Wyoming';

/*!40101 SET character_set_client = @saved_cs_client */;



--
-- Table structure for table `Language`
--

DROP TABLE IF EXISTS `Language`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Language` (
    `iso2`      char(2)         NOT NULL,
    `name`      varchar(50)     NOT NULL,
    `endonyms`  varchar(50)     NOT NULL,
    `supported` tinyint(1)      NOT NULL DEFAULT 0,
    PRIMARY KEY (`iso2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT INTO `Language` SET `iso2` = 'fr', `name` = 'French', `endonyms` = 'français', `supported`=1;
INSERT INTO `Language` SET `iso2` = 'en', `name` = 'English', `endonyms` = 'English', `supported`=1;

INSERT INTO `Language` SET `iso2` = 'aa', `name` = 'Afar', `endonyms` = 'Afaraf';
INSERT INTO `Language` SET `iso2` = 'ab', `name` = 'Abkhazian', `endonyms` = 'аҧсшәа';
INSERT INTO `Language` SET `iso2` = 'ae', `name` = 'Avestan', `endonyms` = 'avesta';
INSERT INTO `Language` SET `iso2` = 'af', `name` = 'Afrikaans', `endonyms` = 'Afrikaans';
INSERT INTO `Language` SET `iso2` = 'ak', `name` = 'Akan', `endonyms` = 'Akan';
INSERT INTO `Language` SET `iso2` = 'am', `name` = 'Amharic', `endonyms` = 'አማርኛ';
INSERT INTO `Language` SET `iso2` = 'an', `name` = 'Aragonese', `endonyms` = 'aragonés';
INSERT INTO `Language` SET `iso2` = 'ar', `name` = 'Arabic', `endonyms` = 'العربية';
INSERT INTO `Language` SET `iso2` = 'as', `name` = 'Assamese', `endonyms` = 'অসমীয়া';
INSERT INTO `Language` SET `iso2` = 'av', `name` = 'Avaric', `endonyms` = 'авар мацӀ';
INSERT INTO `Language` SET `iso2` = 'ay', `name` = 'Aymara', `endonyms` = 'aymar aru';
INSERT INTO `Language` SET `iso2` = 'az', `name` = 'Azerbaijani', `endonyms` = 'azərbaycan dili';
INSERT INTO `Language` SET `iso2` = 'ba', `name` = 'Bashkir', `endonyms` = 'башҡорт теле';
INSERT INTO `Language` SET `iso2` = 'be', `name` = 'Belarusian', `endonyms` = 'беларуская мова';
INSERT INTO `Language` SET `iso2` = 'bg', `name` = 'Bulgarian', `endonyms` = 'български език';
INSERT INTO `Language` SET `iso2` = 'bh', `name` = 'Bihari languages', `endonyms` = 'भोजपुरी';
INSERT INTO `Language` SET `iso2` = 'bi', `name` = 'Bislama', `endonyms` = 'Bislama';
INSERT INTO `Language` SET `iso2` = 'bm', `name` = 'Bambara', `endonyms` = 'bamanankan';
INSERT INTO `Language` SET `iso2` = 'bn', `name` = 'Bengali', `endonyms` = 'বাংলা';
INSERT INTO `Language` SET `iso2` = 'bo', `name` = 'Tibetan', `endonyms` = 'བོད་ཡིག';
INSERT INTO `Language` SET `iso2` = 'br', `name` = 'Breton', `endonyms` = 'brezhoneg';
INSERT INTO `Language` SET `iso2` = 'bs', `name` = 'Bosnian', `endonyms` = 'bosanski jezik';
INSERT INTO `Language` SET `iso2` = 'ca', `name` = 'Catalan', `endonyms` = 'català';
INSERT INTO `Language` SET `iso2` = 'ce', `name` = 'Chechen', `endonyms` = 'нохчийн мотт';
INSERT INTO `Language` SET `iso2` = 'ch', `name` = 'Chamorro', `endonyms` = 'Chamoru';
INSERT INTO `Language` SET `iso2` = 'co', `name` = 'Corsican', `endonyms` = 'corsu';
INSERT INTO `Language` SET `iso2` = 'cr', `name` = 'Cree', `endonyms` = 'ᓀᐦᐃᔭᐍᐏᐣ';
INSERT INTO `Language` SET `iso2` = 'cs', `name` = 'Czech', `endonyms` = 'čeština';
INSERT INTO `Language` SET `iso2` = 'cu', `name` = 'Church Slavic', `endonyms` = 'ѩзыкъ словѣньскъ';
INSERT INTO `Language` SET `iso2` = 'cv', `name` = 'Chuvash', `endonyms` = 'чӑваш чӗлхи';
INSERT INTO `Language` SET `iso2` = 'cy', `name` = 'Welsh', `endonyms` = 'Cymraeg';
INSERT INTO `Language` SET `iso2` = 'da', `name` = 'Danish', `endonyms` = 'dansk';
INSERT INTO `Language` SET `iso2` = 'de', `name` = 'German', `endonyms` = 'Deutsch';
INSERT INTO `Language` SET `iso2` = 'dv', `name` = 'Divehi', `endonyms` = 'ދިވެހި';
INSERT INTO `Language` SET `iso2` = 'dz', `name` = 'Dzongkha', `endonyms` = 'རྫོང་ཁ';
INSERT INTO `Language` SET `iso2` = 'el', `name` = 'Greek', `endonyms` = 'ελληνικά';
INSERT INTO `Language` SET `iso2` = 'eo', `name` = 'Esperanto', `endonyms` = 'Esperanto';
INSERT INTO `Language` SET `iso2` = 'es', `name` = 'Spanish', `endonyms` = 'Español';
INSERT INTO `Language` SET `iso2` = 'et', `name` = 'Estonian', `endonyms` = 'eesti';
INSERT INTO `Language` SET `iso2` = 'ee', `name` = 'Ewe', `endonyms` = 'Eʋegbe';
INSERT INTO `Language` SET `iso2` = 'eu', `name` = 'Basque', `endonyms` = 'euskara';
INSERT INTO `Language` SET `iso2` = 'fa', `name` = 'Persian', `endonyms` = 'فارسی';
INSERT INTO `Language` SET `iso2` = 'ff', `name` = 'Fulah', `endonyms` = 'Fulfulde';
INSERT INTO `Language` SET `iso2` = 'fi', `name` = 'Finnish', `endonyms` = 'suomi';
INSERT INTO `Language` SET `iso2` = 'fj', `name` = 'Fijian', `endonyms` = 'vosa Vakaviti';
INSERT INTO `Language` SET `iso2` = 'fy', `name` = 'Western Frisian', `endonyms` = 'Frysk';
INSERT INTO `Language` SET `iso2` = 'fo', `name` = 'Faroese', `endonyms` = 'føroyskt';
INSERT INTO `Language` SET `iso2` = 'ga', `name` = 'Irish', `endonyms` = 'Gaeilge';
INSERT INTO `Language` SET `iso2` = 'gd', `name` = 'Gaelic, Scottish Gaelic', `endonyms` = 'Gàidhlig';
INSERT INTO `Language` SET `iso2` = 'gl', `name` = 'Galician', `endonyms` = 'Galego';
INSERT INTO `Language` SET `iso2` = 'gn', `name` = 'Guarani', `endonyms` = 'Avañe\'ẽ';
INSERT INTO `Language` SET `iso2` = 'gu', `name` = 'Gujarati', `endonyms` = 'ગુજરાતી';
INSERT INTO `Language` SET `iso2` = 'gv', `name` = 'Manx', `endonyms` = 'Gaelg';
INSERT INTO `Language` SET `iso2` = 'ha', `name` = 'Hausa', `endonyms` = 'هَوُسَ';
INSERT INTO `Language` SET `iso2` = 'he', `name` = 'Hebrew', `endonyms` = 'עברית';
INSERT INTO `Language` SET `iso2` = 'hi', `name` = 'Hindi', `endonyms` = 'हिन्दी, हिंदी';
INSERT INTO `Language` SET `iso2` = 'ho', `name` = 'Hiri Motu', `endonyms` = 'Hiri Motu';
INSERT INTO `Language` SET `iso2` = 'hr', `name` = 'Croatian', `endonyms` = 'hrvatski jezik';
INSERT INTO `Language` SET `iso2` = 'ht', `name` = 'Haitian', `endonyms` = 'Kreyòl ayisyen';
INSERT INTO `Language` SET `iso2` = 'hu', `name` = 'Hungarian', `endonyms` = 'magyar';
INSERT INTO `Language` SET `iso2` = 'hy', `name` = 'Armenian', `endonyms` = 'Հայերեն';
INSERT INTO `Language` SET `iso2` = 'hz', `name` = 'Herero', `endonyms` = 'Otjiherero';
INSERT INTO `Language` SET `iso2` = 'ia', `name` = 'Interlingua', `endonyms` = 'Interlingua';
INSERT INTO `Language` SET `iso2` = 'id', `name` = 'Indonesian', `endonyms` = 'Bahasa Indonesia';
INSERT INTO `Language` SET `iso2` = 'ie', `name` = 'Interlingue', `endonyms` = 'Interlingue';
INSERT INTO `Language` SET `iso2` = 'ig', `name` = 'Igbo', `endonyms` = 'Asụsụ Igbo';
INSERT INTO `Language` SET `iso2` = 'ii', `name` = 'Sichuan Yi', `endonyms` = 'Nuosuhxop';
INSERT INTO `Language` SET `iso2` = 'ik', `name` = 'Inupiaq', `endonyms` = 'Iñupiaq';
INSERT INTO `Language` SET `iso2` = 'io', `name` = 'Ido', `endonyms` = 'Ido';
INSERT INTO `Language` SET `iso2` = 'is', `name` = 'Icelandic', `endonyms` = 'Íslenska';
INSERT INTO `Language` SET `iso2` = 'it', `name` = 'Italian', `endonyms` = 'Italiano';
INSERT INTO `Language` SET `iso2` = 'iu', `name` = 'Inuktitut', `endonyms` = 'ᐃᓄᒃᑎᑐᑦ';
INSERT INTO `Language` SET `iso2` = 'ja', `name` = 'Japanese', `endonyms` = '日本語 (にほんご)';
INSERT INTO `Language` SET `iso2` = 'jv', `name` = 'Javanese', `endonyms` = 'Basa Jawa';
INSERT INTO `Language` SET `iso2` = 'ka', `name` = 'Georgian', `endonyms` = 'ქართული';
INSERT INTO `Language` SET `iso2` = 'kg', `name` = 'Kongo', `endonyms` = 'Kikongo';
INSERT INTO `Language` SET `iso2` = 'ki', `name` = 'Kikuyu', `endonyms` = 'Gĩkũyũ';
INSERT INTO `Language` SET `iso2` = 'kj', `name` = 'Kuanyama', `endonyms` = 'Kuanyama';
INSERT INTO `Language` SET `iso2` = 'kk', `name` = 'Kazakh', `endonyms` = 'қазақ тілі';
INSERT INTO `Language` SET `iso2` = 'kl', `name` = 'Kalaallisut', `endonyms` = 'kalaallisut';
INSERT INTO `Language` SET `iso2` = 'km', `name` = 'Central Khmer', `endonyms` = 'ខ្មែរ, ខេមរភាសា, ភាសាខ្មែរ';
INSERT INTO `Language` SET `iso2` = 'ko', `name` = 'Korean', `endonyms` = '한국어';
INSERT INTO `Language` SET `iso2` = 'kn', `name` = 'Kannada', `endonyms` = 'ಕನ್ನಡ';
INSERT INTO `Language` SET `iso2` = 'kr', `name` = 'Kanuri', `endonyms` = 'Kanuri';
INSERT INTO `Language` SET `iso2` = 'ks', `name` = 'Kashmiri', `endonyms` = 'कश्मीरी, كشميري‎';
INSERT INTO `Language` SET `iso2` = 'ku', `name` = 'Kurdish', `endonyms` = 'Kurdî, کوردی‎';
INSERT INTO `Language` SET `iso2` = 'kv', `name` = 'Komi', `endonyms` = 'коми кыв';
INSERT INTO `Language` SET `iso2` = 'kw', `name` = 'Cornish', `endonyms` = 'Kernewek';
INSERT INTO `Language` SET `iso2` = 'ky', `name` = 'Kirghiz', `endonyms` = 'Кыргызча';
INSERT INTO `Language` SET `iso2` = 'la', `name` = 'Latin', `endonyms` = 'latine';
INSERT INTO `Language` SET `iso2` = 'lb', `name` = 'Luxembourgish', `endonyms` = 'Lëtzebuergesch';
INSERT INTO `Language` SET `iso2` = 'lg', `name` = 'Ganda', `endonyms` = 'Luganda';
INSERT INTO `Language` SET `iso2` = 'li', `name` = 'Limburgan', `endonyms` = 'Limburgs';
INSERT INTO `Language` SET `iso2` = 'ln', `name` = 'Lingala', `endonyms` = 'Lingála';
INSERT INTO `Language` SET `iso2` = 'lo', `name` = 'Lao', `endonyms` = 'ພາສາລາວ';
INSERT INTO `Language` SET `iso2` = 'lt', `name` = 'Lithuanian', `endonyms` = 'lietuvių kalba';
INSERT INTO `Language` SET `iso2` = 'lu', `name` = 'Luba-Katanga', `endonyms` = 'Kiluba';
INSERT INTO `Language` SET `iso2` = 'lv', `name` = 'Latvian', `endonyms` = 'latviešu valoda';
INSERT INTO `Language` SET `iso2` = 'mg', `name` = 'Malagasy', `endonyms` = 'fiteny malagasy';
INSERT INTO `Language` SET `iso2` = 'mh', `name` = 'Marshallese', `endonyms` = 'Kajin M̧ajeļ';
INSERT INTO `Language` SET `iso2` = 'mi', `name` = 'Maori', `endonyms` = 'te reo Māori';
INSERT INTO `Language` SET `iso2` = 'mk', `name` = 'Macedonian', `endonyms` = 'македонски јазик';
INSERT INTO `Language` SET `iso2` = 'ml', `name` = 'Malayalam', `endonyms` = 'മലയാളം';
INSERT INTO `Language` SET `iso2` = 'mn', `name` = 'Mongolian', `endonyms` = 'Монгол хэл';
INSERT INTO `Language` SET `iso2` = 'ms', `name` = 'Malay', `endonyms` = 'Bahasa Melayu, بهاس ملايو‎';
INSERT INTO `Language` SET `iso2` = 'mr', `name` = 'Marathi', `endonyms` = 'मराठी';
INSERT INTO `Language` SET `iso2` = 'mt', `name` = 'Maltese', `endonyms` = 'Malti';
INSERT INTO `Language` SET `iso2` = 'my', `name` = 'Burmese', `endonyms` = 'ဗမာစာ';
INSERT INTO `Language` SET `iso2` = 'na', `name` = 'Nauru', `endonyms` = 'Dorerin Naoero';
INSERT INTO `Language` SET `iso2` = 'nb', `name` = 'Norwegian Bokmål', `endonyms` = 'Norsk Bokmål';
INSERT INTO `Language` SET `iso2` = 'nd', `name` = 'North Ndebele', `endonyms` = 'isiNdebele';
INSERT INTO `Language` SET `iso2` = 'ne', `name` = 'Nepali', `endonyms` = 'नेपाली';
INSERT INTO `Language` SET `iso2` = 'ng', `name` = 'Ndonga', `endonyms` = 'Owambo';
INSERT INTO `Language` SET `iso2` = 'nl', `name` = 'Dutch, Flemish', `endonyms` = 'Nederlands';
INSERT INTO `Language` SET `iso2` = 'nn', `name` = 'Norwegian Nynorsk', `endonyms` = 'Norsk Nynorsk';
INSERT INTO `Language` SET `iso2` = 'no', `name` = 'Norwegian', `endonyms` = 'Norsk';
INSERT INTO `Language` SET `iso2` = 'nr', `name` = 'South Ndebele', `endonyms` = 'isiNdebele';
INSERT INTO `Language` SET `iso2` = 'nv', `name` = 'Navajo, Navaho', `endonyms` = 'Diné bizaad';
INSERT INTO `Language` SET `iso2` = 'ny', `name` = 'Chichewa', `endonyms` = 'chiCheŵa, chinyanja';
INSERT INTO `Language` SET `iso2` = 'oc', `name` = 'Occitan', `endonyms` = 'occitan';
INSERT INTO `Language` SET `iso2` = 'oj', `name` = 'Ojibwa', `endonyms` = 'ᐊᓂᔑᓈᐯᒧᐎᓐ';
INSERT INTO `Language` SET `iso2` = 'om', `name` = 'Oromo', `endonyms` = 'Afaan Oromoo';
INSERT INTO `Language` SET `iso2` = 'or', `name` = 'Oriya', `endonyms` = 'ଓଡ଼ିଆ';
INSERT INTO `Language` SET `iso2` = 'os', `name` = 'Ossetian', `endonyms` = 'ирон æвзаг';
INSERT INTO `Language` SET `iso2` = 'pa', `name` = 'Punjabi', `endonyms` = 'ਪੰਜਾਬੀ, پنجابی‎';
INSERT INTO `Language` SET `iso2` = 'pi', `name` = 'Pali', `endonyms` = 'पालि, पाळि';
INSERT INTO `Language` SET `iso2` = 'pl', `name` = 'Polish', `endonyms` = 'polszczyzna';
INSERT INTO `Language` SET `iso2` = 'ps', `name` = 'Pashto', `endonyms` = 'پښتو';
INSERT INTO `Language` SET `iso2` = 'pt', `name` = 'Portuguese', `endonyms` = 'Português';
INSERT INTO `Language` SET `iso2` = 'qu', `name` = 'Quechua', `endonyms` = 'Kichwa';
INSERT INTO `Language` SET `iso2` = 'rm', `name` = 'Romansh', `endonyms` = 'Rumantsch Grischun';
INSERT INTO `Language` SET `iso2` = 'rn', `name` = 'Rundi', `endonyms` = 'Ikirundi';
INSERT INTO `Language` SET `iso2` = 'ro', `name` = 'Romanian, Moldavian, Moldovan', `endonyms` = 'Română';
INSERT INTO `Language` SET `iso2` = 'ru', `name` = 'Russian', `endonyms` = 'русский';
INSERT INTO `Language` SET `iso2` = 'rw', `name` = 'Kinyarwanda', `endonyms` = 'Ikinyarwanda';
INSERT INTO `Language` SET `iso2` = 'sa', `name` = 'Sanskrit', `endonyms` = 'संस्कृतम्';
INSERT INTO `Language` SET `iso2` = 'sc', `name` = 'Sardinian', `endonyms` = 'sardu';
INSERT INTO `Language` SET `iso2` = 'sd', `name` = 'Sindhi', `endonyms` = 'सिन्धी, سنڌي، سندھی‎';
INSERT INTO `Language` SET `iso2` = 'se', `name` = 'Northern Sami', `endonyms` = 'Davvisámegiella';
INSERT INTO `Language` SET `iso2` = 'sg', `name` = 'Sango', `endonyms` = 'yângâ tî sängö';
INSERT INTO `Language` SET `iso2` = 'si', `name` = 'Sinhala', `endonyms` = 'සිංහල';
INSERT INTO `Language` SET `iso2` = 'sk', `name` = 'Slovak', `endonyms` = 'Slovenčina';
INSERT INTO `Language` SET `iso2` = 'sl', `name` = 'Slovenian', `endonyms` = 'Slovenščina';
INSERT INTO `Language` SET `iso2` = 'sm', `name` = 'Samoan', `endonyms` = 'gagana fa\'a Samoa';
INSERT INTO `Language` SET `iso2` = 'sn', `name` = 'Shona', `endonyms` = 'chiShona';
INSERT INTO `Language` SET `iso2` = 'so', `name` = 'Somali', `endonyms` = 'Soomaaliga';
INSERT INTO `Language` SET `iso2` = 'sq', `name` = 'Albanian', `endonyms` = 'Shqip';
INSERT INTO `Language` SET `iso2` = 'sr', `name` = 'Serbian', `endonyms` = 'српски језик';
INSERT INTO `Language` SET `iso2` = 'ss', `name` = 'Swati', `endonyms` = 'SiSwati';
INSERT INTO `Language` SET `iso2` = 'st', `name` = 'Southern Sotho', `endonyms` = 'Sesotho';
INSERT INTO `Language` SET `iso2` = 'su', `name` = 'Sundanese', `endonyms` = 'Basa Sunda';
INSERT INTO `Language` SET `iso2` = 'sv', `name` = 'Swedish', `endonyms` = 'Svenska';
INSERT INTO `Language` SET `iso2` = 'sw', `name` = 'Swahili', `endonyms` = 'Kiswahili';
INSERT INTO `Language` SET `iso2` = 'ta', `name` = 'Tamil', `endonyms` = 'தமிழ்';
INSERT INTO `Language` SET `iso2` = 'te', `name` = 'Telugu', `endonyms` = 'తెలుగు';
INSERT INTO `Language` SET `iso2` = 'tg', `name` = 'Tajik', `endonyms` = 'тоҷикӣ, toçikī, تاجیکی‎';
INSERT INTO `Language` SET `iso2` = 'th', `name` = 'Thai', `endonyms` = 'ไทย';
INSERT INTO `Language` SET `iso2` = 'ti', `name` = 'Tigrinya', `endonyms` = 'ትግርኛ';
INSERT INTO `Language` SET `iso2` = 'tk', `name` = 'Turkmen', `endonyms` = 'Türkmen, Түркмен';
INSERT INTO `Language` SET `iso2` = 'tl', `name` = 'Tagalog', `endonyms` = 'Wikang Tagalog';
INSERT INTO `Language` SET `iso2` = 'tn', `name` = 'Tswana', `endonyms` = 'Setswana';
INSERT INTO `Language` SET `iso2` = 'to', `name` = 'Tonga (Tonga Islands)', `endonyms` = 'Faka Tonga';
INSERT INTO `Language` SET `iso2` = 'tr', `name` = 'Turkish', `endonyms` = 'Türkçe';
INSERT INTO `Language` SET `iso2` = 'ts', `name` = 'Tsonga', `endonyms` = 'Xitsonga';
INSERT INTO `Language` SET `iso2` = 'tt', `name` = 'Tatar', `endonyms` = 'татар теле';
INSERT INTO `Language` SET `iso2` = 'tw', `name` = 'Twi', `endonyms` = 'Twi';
INSERT INTO `Language` SET `iso2` = 'ty', `name` = 'Tahitian', `endonyms` = 'Reo Tahiti';
INSERT INTO `Language` SET `iso2` = 'ug', `name` = 'Uighur', `endonyms` = 'ئۇيغۇرچە‎';
INSERT INTO `Language` SET `iso2` = 'uk', `name` = 'Ukrainian', `endonyms` = 'Українська';
INSERT INTO `Language` SET `iso2` = 'ur', `name` = 'Urdu', `endonyms` = 'اردو';
INSERT INTO `Language` SET `iso2` = 'uz', `name` = 'Uzbek', `endonyms` = 'Oʻzbek, Ўзбек, أۇزبېك‎';
INSERT INTO `Language` SET `iso2` = 've', `name` = 'Venda', `endonyms` = 'Tshivenḓa';
INSERT INTO `Language` SET `iso2` = 'vi', `name` = 'Vietnamese', `endonyms` = 'Tiếng Việt';
INSERT INTO `Language` SET `iso2` = 'vo', `name` = 'Volapük', `endonyms` = 'Volapük';
INSERT INTO `Language` SET `iso2` = 'wa', `name` = 'Walloon', `endonyms` = 'Walon';
INSERT INTO `Language` SET `iso2` = 'wo', `name` = 'Wolof', `endonyms` = 'Wollof';
INSERT INTO `Language` SET `iso2` = 'xh', `name` = 'Xhosa', `endonyms` = 'isiXhosa';
INSERT INTO `Language` SET `iso2` = 'yi', `name` = 'Yiddish', `endonyms` = 'ייִדיש';
INSERT INTO `Language` SET `iso2` = 'yo', `name` = 'Yoruba', `endonyms` = 'Yorùbá';
INSERT INTO `Language` SET `iso2` = 'za', `name` = 'Zhuang', `endonyms` = 'Saɯ cueŋƅ, Saw cuengh';
INSERT INTO `Language` SET `iso2` = 'zh', `name` = 'Chinese', `endonyms` = '中文 (Zhōngwén), 汉语, 漢語';
INSERT INTO `Language` SET `iso2` = 'zu', `name` = 'Zulu', `endonyms` = 'isiZulu';

/*!40101 SET character_set_client = @saved_cs_client */;



--
-- Table structure for table `LanguageName`
--

DROP TABLE IF EXISTS `LanguageName`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `LanguageName` (
    `id`            bigint(20) unsigned     NOT NULL AUTO_INCREMENT,
    `iso2`          char(2)                 NOT NULL,
    `language_iso2` char(2)                 NOT NULL,
    `name`          varchar(50)             NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_language_language` (`iso2`, `language_iso2`),
    CONSTRAINT `fk_languagename_language` FOREIGN KEY (`iso2`) REFERENCES `Language` (`iso2`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT INTO `LanguageName` SET `iso2` = 'aa', `language_iso2` = 'fr', `name` = 'Afar';
INSERT INTO `LanguageName` SET `iso2` = 'ab', `language_iso2` = 'fr', `name` = 'Abkhaze';
INSERT INTO `LanguageName` SET `iso2` = 'ae', `language_iso2` = 'fr', `name` = 'Avestique';
INSERT INTO `LanguageName` SET `iso2` = 'af', `language_iso2` = 'fr', `name` = 'Afrikaans';
INSERT INTO `LanguageName` SET `iso2` = 'ak', `language_iso2` = 'fr', `name` = 'Akan';
INSERT INTO `LanguageName` SET `iso2` = 'am', `language_iso2` = 'fr', `name` = 'Amharique';
INSERT INTO `LanguageName` SET `iso2` = 'an', `language_iso2` = 'fr', `name` = 'Aragonais';
INSERT INTO `LanguageName` SET `iso2` = 'ar', `language_iso2` = 'fr', `name` = 'Arabe';
INSERT INTO `LanguageName` SET `iso2` = 'as', `language_iso2` = 'fr', `name` = 'Assamais';
INSERT INTO `LanguageName` SET `iso2` = 'av', `language_iso2` = 'fr', `name` = 'Avar';
INSERT INTO `LanguageName` SET `iso2` = 'ay', `language_iso2` = 'fr', `name` = 'Aymara';
INSERT INTO `LanguageName` SET `iso2` = 'az', `language_iso2` = 'fr', `name` = 'Azéri';
INSERT INTO `LanguageName` SET `iso2` = 'ba', `language_iso2` = 'fr', `name` = 'Bachkir';
INSERT INTO `LanguageName` SET `iso2` = 'be', `language_iso2` = 'fr', `name` = 'Biélorusse';
INSERT INTO `LanguageName` SET `iso2` = 'bg', `language_iso2` = 'fr', `name` = 'Bulgare';
INSERT INTO `LanguageName` SET `iso2` = 'bh', `language_iso2` = 'fr', `name` = 'Bihari';
INSERT INTO `LanguageName` SET `iso2` = 'bi', `language_iso2` = 'fr', `name` = 'Bichelamar';
INSERT INTO `LanguageName` SET `iso2` = 'bm', `language_iso2` = 'fr', `name` = 'Bambara';
INSERT INTO `LanguageName` SET `iso2` = 'bn', `language_iso2` = 'fr', `name` = 'Bengali';
INSERT INTO `LanguageName` SET `iso2` = 'bo', `language_iso2` = 'fr', `name` = 'Tibétain';
INSERT INTO `LanguageName` SET `iso2` = 'br', `language_iso2` = 'fr', `name` = 'Breton';
INSERT INTO `LanguageName` SET `iso2` = 'bs', `language_iso2` = 'fr', `name` = 'Bosnien';
INSERT INTO `LanguageName` SET `iso2` = 'ca', `language_iso2` = 'fr', `name` = 'Catalan';
INSERT INTO `LanguageName` SET `iso2` = 'ce', `language_iso2` = 'fr', `name` = 'Tchétchène';
INSERT INTO `LanguageName` SET `iso2` = 'ch', `language_iso2` = 'fr', `name` = 'Chamorro';
INSERT INTO `LanguageName` SET `iso2` = 'co', `language_iso2` = 'fr', `name` = 'Corse';
INSERT INTO `LanguageName` SET `iso2` = 'cr', `language_iso2` = 'fr', `name` = 'Cri';
INSERT INTO `LanguageName` SET `iso2` = 'cs', `language_iso2` = 'fr', `name` = 'Tchèque';
INSERT INTO `LanguageName` SET `iso2` = 'cu', `language_iso2` = 'fr', `name` = 'Vieux-slave';
INSERT INTO `LanguageName` SET `iso2` = 'cv', `language_iso2` = 'fr', `name` = 'Tchouvache';
INSERT INTO `LanguageName` SET `iso2` = 'cy', `language_iso2` = 'fr', `name` = 'Gallois';
INSERT INTO `LanguageName` SET `iso2` = 'da', `language_iso2` = 'fr', `name` = 'Danois';
INSERT INTO `LanguageName` SET `iso2` = 'de', `language_iso2` = 'fr', `name` = 'Allemand';
INSERT INTO `LanguageName` SET `iso2` = 'dv', `language_iso2` = 'fr', `name` = 'Maldivien';
INSERT INTO `LanguageName` SET `iso2` = 'dz', `language_iso2` = 'fr', `name` = 'Dzongkha';
INSERT INTO `LanguageName` SET `iso2` = 'ee', `language_iso2` = 'fr', `name` = 'Ewe';
INSERT INTO `LanguageName` SET `iso2` = 'el', `language_iso2` = 'fr', `name` = 'Grec moderne';
INSERT INTO `LanguageName` SET `iso2` = 'en', `language_iso2` = 'fr', `name` = 'Anglais';
INSERT INTO `LanguageName` SET `iso2` = 'eo', `language_iso2` = 'fr', `name` = 'Espéranto';
INSERT INTO `LanguageName` SET `iso2` = 'es', `language_iso2` = 'fr', `name` = 'Espagnol';
INSERT INTO `LanguageName` SET `iso2` = 'et', `language_iso2` = 'fr', `name` = 'Estonien';
INSERT INTO `LanguageName` SET `iso2` = 'eu', `language_iso2` = 'fr', `name` = 'Basque';
INSERT INTO `LanguageName` SET `iso2` = 'fa', `language_iso2` = 'fr', `name` = 'Persan';
INSERT INTO `LanguageName` SET `iso2` = 'ff', `language_iso2` = 'fr', `name` = 'Peul';
INSERT INTO `LanguageName` SET `iso2` = 'fi', `language_iso2` = 'fr', `name` = 'Finnois';
INSERT INTO `LanguageName` SET `iso2` = 'fj', `language_iso2` = 'fr', `name` = 'Fidjien';
INSERT INTO `LanguageName` SET `iso2` = 'fo', `language_iso2` = 'fr', `name` = 'Féroïen';
INSERT INTO `LanguageName` SET `iso2` = 'fr', `language_iso2` = 'fr', `name` = 'Français';
INSERT INTO `LanguageName` SET `iso2` = 'fy', `language_iso2` = 'fr', `name` = 'Frison occidental';
INSERT INTO `LanguageName` SET `iso2` = 'ga', `language_iso2` = 'fr', `name` = 'Irlandais';
INSERT INTO `LanguageName` SET `iso2` = 'gd', `language_iso2` = 'fr', `name` = 'Écossais';
INSERT INTO `LanguageName` SET `iso2` = 'gl', `language_iso2` = 'fr', `name` = 'Galicien';
INSERT INTO `LanguageName` SET `iso2` = 'gn', `language_iso2` = 'fr', `name` = 'Guarani';
INSERT INTO `LanguageName` SET `iso2` = 'gu', `language_iso2` = 'fr', `name` = 'Gujarati';
INSERT INTO `LanguageName` SET `iso2` = 'gv', `language_iso2` = 'fr', `name` = 'Mannois';
INSERT INTO `LanguageName` SET `iso2` = 'ha', `language_iso2` = 'fr', `name` = 'Haoussa';
INSERT INTO `LanguageName` SET `iso2` = 'he', `language_iso2` = 'fr', `name` = 'Hébreu';
INSERT INTO `LanguageName` SET `iso2` = 'hi', `language_iso2` = 'fr', `name` = 'Hindi';
INSERT INTO `LanguageName` SET `iso2` = 'ho', `language_iso2` = 'fr', `name` = 'Hiri motu';
INSERT INTO `LanguageName` SET `iso2` = 'hr', `language_iso2` = 'fr', `name` = 'Croate';
INSERT INTO `LanguageName` SET `iso2` = 'ht', `language_iso2` = 'fr', `name` = 'Créole haïtien';
INSERT INTO `LanguageName` SET `iso2` = 'hu', `language_iso2` = 'fr', `name` = 'Hongrois';
INSERT INTO `LanguageName` SET `iso2` = 'hy', `language_iso2` = 'fr', `name` = 'Arménien';
INSERT INTO `LanguageName` SET `iso2` = 'hz', `language_iso2` = 'fr', `name` = 'Héréro';
INSERT INTO `LanguageName` SET `iso2` = 'ia', `language_iso2` = 'fr', `name` = 'Interlingua';
INSERT INTO `LanguageName` SET `iso2` = 'id', `language_iso2` = 'fr', `name` = 'Indonésien';
INSERT INTO `LanguageName` SET `iso2` = 'ie', `language_iso2` = 'fr', `name` = 'Occidental';
INSERT INTO `LanguageName` SET `iso2` = 'ig', `language_iso2` = 'fr', `name` = 'Igbo';
INSERT INTO `LanguageName` SET `iso2` = 'ii', `language_iso2` = 'fr', `name` = 'Yi';
INSERT INTO `LanguageName` SET `iso2` = 'ik', `language_iso2` = 'fr', `name` = 'Inupiak';
INSERT INTO `LanguageName` SET `iso2` = 'io', `language_iso2` = 'fr', `name` = 'Ido';
INSERT INTO `LanguageName` SET `iso2` = 'is', `language_iso2` = 'fr', `name` = 'Islandais';
INSERT INTO `LanguageName` SET `iso2` = 'it', `language_iso2` = 'fr', `name` = 'Italien';
INSERT INTO `LanguageName` SET `iso2` = 'iu', `language_iso2` = 'fr', `name` = 'Inuktitut';
INSERT INTO `LanguageName` SET `iso2` = 'ja', `language_iso2` = 'fr', `name` = 'Japonais';
INSERT INTO `LanguageName` SET `iso2` = 'jv', `language_iso2` = 'fr', `name` = 'Javanais';
INSERT INTO `LanguageName` SET `iso2` = 'ka', `language_iso2` = 'fr', `name` = 'Géorgien';
INSERT INTO `LanguageName` SET `iso2` = 'kg', `language_iso2` = 'fr', `name` = 'Kikongo';
INSERT INTO `LanguageName` SET `iso2` = 'ki', `language_iso2` = 'fr', `name` = 'Kikuyu';
INSERT INTO `LanguageName` SET `iso2` = 'kj', `language_iso2` = 'fr', `name` = 'Kuanyama';
INSERT INTO `LanguageName` SET `iso2` = 'kk', `language_iso2` = 'fr', `name` = 'Kazakh';
INSERT INTO `LanguageName` SET `iso2` = 'kl', `language_iso2` = 'fr', `name` = 'Groenlandais';
INSERT INTO `LanguageName` SET `iso2` = 'km', `language_iso2` = 'fr', `name` = 'Khmer';
INSERT INTO `LanguageName` SET `iso2` = 'kn', `language_iso2` = 'fr', `name` = 'Kannada';
INSERT INTO `LanguageName` SET `iso2` = 'ko', `language_iso2` = 'fr', `name` = 'Coréen';
INSERT INTO `LanguageName` SET `iso2` = 'kr', `language_iso2` = 'fr', `name` = 'Kanouri';
INSERT INTO `LanguageName` SET `iso2` = 'ks', `language_iso2` = 'fr', `name` = 'Cachemiri';
INSERT INTO `LanguageName` SET `iso2` = 'ku', `language_iso2` = 'fr', `name` = 'Kurde';
INSERT INTO `LanguageName` SET `iso2` = 'kv', `language_iso2` = 'fr', `name` = 'Komi';
INSERT INTO `LanguageName` SET `iso2` = 'kw', `language_iso2` = 'fr', `name` = 'Cornique';
INSERT INTO `LanguageName` SET `iso2` = 'ky', `language_iso2` = 'fr', `name` = 'Kirghiz';
INSERT INTO `LanguageName` SET `iso2` = 'la', `language_iso2` = 'fr', `name` = 'Latin';
INSERT INTO `LanguageName` SET `iso2` = 'lb', `language_iso2` = 'fr', `name` = 'Luxembourgeois';
INSERT INTO `LanguageName` SET `iso2` = 'lg', `language_iso2` = 'fr', `name` = 'Ganda';
INSERT INTO `LanguageName` SET `iso2` = 'li', `language_iso2` = 'fr', `name` = 'Limbourgeois';
INSERT INTO `LanguageName` SET `iso2` = 'ln', `language_iso2` = 'fr', `name` = 'Lingala';
INSERT INTO `LanguageName` SET `iso2` = 'lo', `language_iso2` = 'fr', `name` = 'Lao';
INSERT INTO `LanguageName` SET `iso2` = 'lt', `language_iso2` = 'fr', `name` = 'Lituanien';
INSERT INTO `LanguageName` SET `iso2` = 'lu', `language_iso2` = 'fr', `name` = 'Luba';
INSERT INTO `LanguageName` SET `iso2` = 'lv', `language_iso2` = 'fr', `name` = 'Letton';
INSERT INTO `LanguageName` SET `iso2` = 'mg', `language_iso2` = 'fr', `name` = 'Malgache';
INSERT INTO `LanguageName` SET `iso2` = 'mh', `language_iso2` = 'fr', `name` = 'Marshallais';
INSERT INTO `LanguageName` SET `iso2` = 'mi', `language_iso2` = 'fr', `name` = 'Maori de Nouvelle-Zélande';
INSERT INTO `LanguageName` SET `iso2` = 'mk', `language_iso2` = 'fr', `name` = 'Macédonien';
INSERT INTO `LanguageName` SET `iso2` = 'ml', `language_iso2` = 'fr', `name` = 'Malayalam';
INSERT INTO `LanguageName` SET `iso2` = 'mn', `language_iso2` = 'fr', `name` = 'Mongol';
INSERT INTO `LanguageName` SET `iso2` = 'mr', `language_iso2` = 'fr', `name` = 'Marathi';
INSERT INTO `LanguageName` SET `iso2` = 'ms', `language_iso2` = 'fr', `name` = 'Malais';
INSERT INTO `LanguageName` SET `iso2` = 'mt', `language_iso2` = 'fr', `name` = 'Maltais';
INSERT INTO `LanguageName` SET `iso2` = 'my', `language_iso2` = 'fr', `name` = 'Birman';
INSERT INTO `LanguageName` SET `iso2` = 'na', `language_iso2` = 'fr', `name` = 'Nauruan';
INSERT INTO `LanguageName` SET `iso2` = 'nb', `language_iso2` = 'fr', `name` = 'Norvégien Bokmål';
INSERT INTO `LanguageName` SET `iso2` = 'nd', `language_iso2` = 'fr', `name` = 'Sindebele';
INSERT INTO `LanguageName` SET `iso2` = 'ne', `language_iso2` = 'fr', `name` = 'Népalais';
INSERT INTO `LanguageName` SET `iso2` = 'ng', `language_iso2` = 'fr', `name` = 'Ndonga';
INSERT INTO `LanguageName` SET `iso2` = 'nl', `language_iso2` = 'fr', `name` = 'Néerlandais';
INSERT INTO `LanguageName` SET `iso2` = 'nn', `language_iso2` = 'fr', `name` = 'Norvégien Nynorsk';
INSERT INTO `LanguageName` SET `iso2` = 'no', `language_iso2` = 'fr', `name` = 'Norvégien';
INSERT INTO `LanguageName` SET `iso2` = 'nr', `language_iso2` = 'fr', `name` = 'Nrebele';
INSERT INTO `LanguageName` SET `iso2` = 'nv', `language_iso2` = 'fr', `name` = 'Navajo';
INSERT INTO `LanguageName` SET `iso2` = 'ny', `language_iso2` = 'fr', `name` = 'Chichewa';
INSERT INTO `LanguageName` SET `iso2` = 'oc', `language_iso2` = 'fr', `name` = 'Occitan';
INSERT INTO `LanguageName` SET `iso2` = 'oj', `language_iso2` = 'fr', `name` = 'Ojibwé';
INSERT INTO `LanguageName` SET `iso2` = 'om', `language_iso2` = 'fr', `name` = 'Oromo';
INSERT INTO `LanguageName` SET `iso2` = 'or', `language_iso2` = 'fr', `name` = 'Oriya';
INSERT INTO `LanguageName` SET `iso2` = 'os', `language_iso2` = 'fr', `name` = 'Ossète';
INSERT INTO `LanguageName` SET `iso2` = 'pa', `language_iso2` = 'fr', `name` = 'Pendjabi';
INSERT INTO `LanguageName` SET `iso2` = 'pi', `language_iso2` = 'fr', `name` = 'Pali';
INSERT INTO `LanguageName` SET `iso2` = 'pl', `language_iso2` = 'fr', `name` = 'Polonais';
INSERT INTO `LanguageName` SET `iso2` = 'ps', `language_iso2` = 'fr', `name` = 'Pachto';
INSERT INTO `LanguageName` SET `iso2` = 'pt', `language_iso2` = 'fr', `name` = 'Portugais';
INSERT INTO `LanguageName` SET `iso2` = 'qu', `language_iso2` = 'fr', `name` = 'Quechua';
INSERT INTO `LanguageName` SET `iso2` = 'rm', `language_iso2` = 'fr', `name` = 'Romanche';
INSERT INTO `LanguageName` SET `iso2` = 'rn', `language_iso2` = 'fr', `name` = 'Kirundi';
INSERT INTO `LanguageName` SET `iso2` = 'ro', `language_iso2` = 'fr', `name` = 'Roumain';
INSERT INTO `LanguageName` SET `iso2` = 'ru', `language_iso2` = 'fr', `name` = 'Russe';
INSERT INTO `LanguageName` SET `iso2` = 'rw', `language_iso2` = 'fr', `name` = 'Kinyarwanda';
INSERT INTO `LanguageName` SET `iso2` = 'sa', `language_iso2` = 'fr', `name` = 'Sanskrit';
INSERT INTO `LanguageName` SET `iso2` = 'sc', `language_iso2` = 'fr', `name` = 'Sarde';
INSERT INTO `LanguageName` SET `iso2` = 'sd', `language_iso2` = 'fr', `name` = 'Sindhi';
INSERT INTO `LanguageName` SET `iso2` = 'se', `language_iso2` = 'fr', `name` = 'Same du Nord';
INSERT INTO `LanguageName` SET `iso2` = 'sg', `language_iso2` = 'fr', `name` = 'Sango';
INSERT INTO `LanguageName` SET `iso2` = 'si', `language_iso2` = 'fr', `name` = 'Cingalais';
INSERT INTO `LanguageName` SET `iso2` = 'sk', `language_iso2` = 'fr', `name` = 'Slovaque';
INSERT INTO `LanguageName` SET `iso2` = 'sl', `language_iso2` = 'fr', `name` = 'Slovène';
INSERT INTO `LanguageName` SET `iso2` = 'sm', `language_iso2` = 'fr', `name` = 'Samoan';
INSERT INTO `LanguageName` SET `iso2` = 'sn', `language_iso2` = 'fr', `name` = 'Shona';
INSERT INTO `LanguageName` SET `iso2` = 'so', `language_iso2` = 'fr', `name` = 'Somali';
INSERT INTO `LanguageName` SET `iso2` = 'sq', `language_iso2` = 'fr', `name` = 'Albanais';
INSERT INTO `LanguageName` SET `iso2` = 'sr', `language_iso2` = 'fr', `name` = 'Serbe';
INSERT INTO `LanguageName` SET `iso2` = 'ss', `language_iso2` = 'fr', `name` = 'Swati';
INSERT INTO `LanguageName` SET `iso2` = 'st', `language_iso2` = 'fr', `name` = 'Sotho du Sud';
INSERT INTO `LanguageName` SET `iso2` = 'su', `language_iso2` = 'fr', `name` = 'Soundanais';
INSERT INTO `LanguageName` SET `iso2` = 'sv', `language_iso2` = 'fr', `name` = 'Suédois';
INSERT INTO `LanguageName` SET `iso2` = 'sw', `language_iso2` = 'fr', `name` = 'Swahili';
INSERT INTO `LanguageName` SET `iso2` = 'ta', `language_iso2` = 'fr', `name` = 'Tamoul';
INSERT INTO `LanguageName` SET `iso2` = 'te', `language_iso2` = 'fr', `name` = 'Télougou';
INSERT INTO `LanguageName` SET `iso2` = 'tg', `language_iso2` = 'fr', `name` = 'Tadjik';
INSERT INTO `LanguageName` SET `iso2` = 'th', `language_iso2` = 'fr', `name` = 'Thaï';
INSERT INTO `LanguageName` SET `iso2` = 'ti', `language_iso2` = 'fr', `name` = 'Tigrigna';
INSERT INTO `LanguageName` SET `iso2` = 'tk', `language_iso2` = 'fr', `name` = 'Turkmène';
INSERT INTO `LanguageName` SET `iso2` = 'tl', `language_iso2` = 'fr', `name` = 'Tagalog';
INSERT INTO `LanguageName` SET `iso2` = 'tn', `language_iso2` = 'fr', `name` = 'Tswana';
INSERT INTO `LanguageName` SET `iso2` = 'to', `language_iso2` = 'fr', `name` = 'Tongien';
INSERT INTO `LanguageName` SET `iso2` = 'tr', `language_iso2` = 'fr', `name` = 'Turc';
INSERT INTO `LanguageName` SET `iso2` = 'ts', `language_iso2` = 'fr', `name` = 'Tsonga';
INSERT INTO `LanguageName` SET `iso2` = 'tt', `language_iso2` = 'fr', `name` = 'Tatar';
INSERT INTO `LanguageName` SET `iso2` = 'tw', `language_iso2` = 'fr', `name` = 'Twi';
INSERT INTO `LanguageName` SET `iso2` = 'ty', `language_iso2` = 'fr', `name` = 'Tahitien';
INSERT INTO `LanguageName` SET `iso2` = 'ug', `language_iso2` = 'fr', `name` = 'Ouïghour';
INSERT INTO `LanguageName` SET `iso2` = 'uk', `language_iso2` = 'fr', `name` = 'Ukrainien';
INSERT INTO `LanguageName` SET `iso2` = 'ur', `language_iso2` = 'fr', `name` = 'Ourdou';
INSERT INTO `LanguageName` SET `iso2` = 'uz', `language_iso2` = 'fr', `name` = 'Ouzbek';
INSERT INTO `LanguageName` SET `iso2` = 've', `language_iso2` = 'fr', `name` = 'Venda';
INSERT INTO `LanguageName` SET `iso2` = 'vi', `language_iso2` = 'fr', `name` = 'Vietnamien';
INSERT INTO `LanguageName` SET `iso2` = 'vo', `language_iso2` = 'fr', `name` = 'Volapük';
INSERT INTO `LanguageName` SET `iso2` = 'wa', `language_iso2` = 'fr', `name` = 'Wallon';
INSERT INTO `LanguageName` SET `iso2` = 'wo', `language_iso2` = 'fr', `name` = 'Wolof';
INSERT INTO `LanguageName` SET `iso2` = 'xh', `language_iso2` = 'fr', `name` = 'Xhosa';
INSERT INTO `LanguageName` SET `iso2` = 'yi', `language_iso2` = 'fr', `name` = 'Yiddish';
INSERT INTO `LanguageName` SET `iso2` = 'yo', `language_iso2` = 'fr', `name` = 'Yoruba';
INSERT INTO `LanguageName` SET `iso2` = 'za', `language_iso2` = 'fr', `name` = 'Zhuang';
INSERT INTO `LanguageName` SET `iso2` = 'zh', `language_iso2` = 'fr', `name` = 'Chinois';
INSERT INTO `LanguageName` SET `iso2` = 'zu', `language_iso2` = 'fr', `name` = 'Zoulou';



/*!40101 SET character_set_client = @saved_cs_client */;


/*!40103 SET TIME_ZONE = @OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE = @OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT = @OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS = @OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION = @OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES = @OLD_SQL_NOTES */;

