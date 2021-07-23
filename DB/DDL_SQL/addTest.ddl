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


USE `Dispensary`;

DROP TABLE IF EXISTS `A`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `A`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `feed_alias`        varchar(128)                NOT NULL,
    `feed_item_id`      binary(16)                  NOT NULL,
    `backend_item_id`   binary(16)                  DEFAULT NULL,
    `a`                 varchar(128)                NOT NULL,

    `f_id`              bigint(20)                DEFAULT NULL,
    `j1_id`             bigint(20)                DEFAULT NULL,
    `j2_id`             bigint(20)                DEFAULT NULL,
    `p_id`              bigint(20)                DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_fitm` (`feed_item_id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),
    KEY `idx_feed` (`feed_alias`),
    KEY `idx_bitm` (`backend_item_id`),

    KEY `idx_f` (`f_id`),
    KEY `idx_j1` (`j1_id`),
    KEY `idx_j2` (`j2_id`),
    KEY `idx_p` (`p_id`),
    CONSTRAINT `fk_a_f` FOREIGN KEY (`f_id`) REFERENCES `F` (`id`),
    CONSTRAINT `fk_a_j1` FOREIGN KEY (`j1_id`) REFERENCES `J` (`id`),
    CONSTRAINT `fk_a_j2` FOREIGN KEY (`j2_id`) REFERENCES `J` (`id`),
    CONSTRAINT `fk_a_p` FOREIGN KEY (`p_id`) REFERENCES `P` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `B`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `B`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `b`                 varchar(128)                NOT NULL,

    `a_id`              bigint(20)                NOT NULL,
    `i_id`              bigint(20)                DEFAULT NULL,
    `j_id`              bigint(20)                DEFAULT NULL,
    `k_id`              bigint(20)                DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    KEY `idx_a` (`a_id`),
    KEY `idx_i` (`i_id`),
    KEY `idx_j` (`j_id`),
    KEY `idx_k` (`k_id`),
    CONSTRAINT `fk_b_a` FOREIGN KEY (`a_id`) REFERENCES `A` (`id`),
    CONSTRAINT `fk_b_i` FOREIGN KEY (`i_id`) REFERENCES `I` (`id`),
    CONSTRAINT `fk_b_j` FOREIGN KEY (`j_id`) REFERENCES `J` (`id`),
    CONSTRAINT `fk_b_k` FOREIGN KEY (`k_id`) REFERENCES `K` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `C`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `C`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `c`                 varchar(128)                NOT NULL,

    `j_id`              bigint(20)                NOT NULL,
    `d_id`              bigint(20)                DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    KEY `idx_j` (`j_id`),
    KEY `idx_d` (`d_id`),
    CONSTRAINT `fk_c_j` FOREIGN KEY (`j_id`) REFERENCES `J` (`id`),
    CONSTRAINT `fk_c_d` FOREIGN KEY (`d_id`) REFERENCES `D` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `D`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `D`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `d`                 varchar(128)                NOT NULL,

    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `E`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `E`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `e`                 varchar(128)                NOT NULL,

    `l_id`              bigint(20)                  NOT NULL,
    `m1_id`             bigint(20)                  DEFAULT NULL,
    `m2_id`             bigint(20)                  DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    KEY `idx_l` (`l_id`),
    KEY `idx_m1` (`m1_id`),
    KEY `idx_m2` (`m2_id`),
    CONSTRAINT `fk_e_l` FOREIGN KEY (`l_id`) REFERENCES `L` (`id`),
    CONSTRAINT `fk_e_m1` FOREIGN KEY (`m1_id`) REFERENCES `M` (`id`),
    CONSTRAINT `fk_e_m2` FOREIGN KEY (`m2_id`) REFERENCES `M` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `F`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `F`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `f`                 varchar(128)                NOT NULL,

    `g_id`              bigint(20)                  DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    KEY `idx_g` (`g_id`),
    CONSTRAINT `fk_f_g` FOREIGN KEY (`g_id`) REFERENCES `G` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `G`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `G`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `g`                 varchar(128)                NOT NULL,

    `i_id`              bigint(20)                  DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    KEY `idx_i` (`i_id`),
    CONSTRAINT `fk_g_i` FOREIGN KEY (`i_id`) REFERENCES `I` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `H`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `H`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `h`                 varchar(128)                NOT NULL,

    `g_id`              bigint(20)                  NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    KEY `idx_g` (`g_id`),
    CONSTRAINT `fk_h_g` FOREIGN KEY (`g_id`) REFERENCES `G` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `I`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `I`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `i`                 varchar(128)                NOT NULL,

    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`)

) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `J`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `J`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `j`                 varchar(128)                NOT NULL,

    `m_id`              bigint(20)                  DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    KEY `idx_m` (`m_id`),
    CONSTRAINT `fk_j_m` FOREIGN KEY (`m_id`) REFERENCES `M` (`id`)

) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `K`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `K`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `k`                 varchar(128)                NOT NULL,

    `i1_id`              bigint(20)                DEFAULT NULL,
    `i2_id`              bigint(20)                DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    KEY `idx_i1` (`i1_id`),
    KEY `idx_i2` (`i2_id`),
    CONSTRAINT `fk_k_i1` FOREIGN KEY (`i1_id`) REFERENCES `I` (`id`),
    CONSTRAINT `fk_k_i2` FOREIGN KEY (`i2_id`) REFERENCES `I` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;



DROP TABLE IF EXISTS `L`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `L`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `l`                 varchar(128)                NOT NULL,

    `a_id`              bigint(20)                  NOT NULL,
#     `a1_id`              bigint(20)                  NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    UNIQUE KEY `idx_a` (`a_id`),
#     UNIQUE KEY `idx_a1` (`a1_id`),
#     CONSTRAINT `fk_l_a1` FOREIGN KEY (`a1_id`) REFERENCES `A` (`id`),
    CONSTRAINT `fk_l_a` FOREIGN KEY (`a_id`) REFERENCES `A` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;



DROP TABLE IF EXISTS `M`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `M`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `m`                 varchar(128)                NOT NULL,

    `u_id`              bigint(20)                  DEFAULT NULL,
#     `u1_id`              bigint(20)                  DEFAULT NULL,

    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

     KEY `idx_u` (`u_id`),
#     KEY `idx_u1` (`u1_id`),
#     CONSTRAINT `fk_m_u1` FOREIGN KEY (`u1_id`) REFERENCES `U` (`id`),
    CONSTRAINT `fk_m_u` FOREIGN KEY (`u_id`) REFERENCES `U` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `N`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `N`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `n`                 varchar(128)                NOT NULL,

    `h_id`              bigint(20)                  NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    KEY `idx_h` (`h_id`),
    CONSTRAINT `fk_n_h` FOREIGN KEY (`h_id`) REFERENCES `H` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `O`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `O`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `o`                 varchar(128)                NOT NULL,

    `prev_g_id`         bigint(20)                  NOT NULL,
    `next_g_id`         bigint(20)                  DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    KEY `idx_prev_g` (`prev_g_id`),
    KEY `idx_next_g` (`next_g_id`),
    CONSTRAINT `fk_o_prev_g` FOREIGN KEY (`prev_g_id`) REFERENCES `G` (`id`),
    CONSTRAINT `fk_o_next_g` FOREIGN KEY (`next_g_id`) REFERENCES `G` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `P`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `P`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `p`                 varchar(128)                NOT NULL,

    `p_id`              bigint(20)                  DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    KEY `idx_p` (`p_id`),
    CONSTRAINT `fk_p_p` FOREIGN KEY (`p_id`) REFERENCES `P` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `Q`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Q`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,
    `q`                 varchar(128)                NOT NULL,

    `p_id`              bigint(20)                  NOT NULL,
    `i_id`              bigint(20)                  DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    KEY `idx_p` (`p_id`),
    KEY `idx_i` (`i_id`),
    CONSTRAINT `fk_q_p` FOREIGN KEY (`p_id`) REFERENCES `P` (`id`),
    CONSTRAINT `fk_q_i` FOREIGN KEY (`i_id`) REFERENCES `I` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;




DROP TABLE IF EXISTS `U`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `U`
(
    `id`                bigint(20)                  NOT NULL AUTO_INCREMENT,
    `row_version`       int(10) unsigned            NOT NULL DEFAULT 0,
    `row_created`       timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_persisted`     timestamp(3)                NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `row_retired`       timestamp(3)                DEFAULT NULL,

    `uuid`              binary(16)                  NOT NULL,
    `u`                 varchar(128)                NOT NULL,

    `m_id`              bigint(20)                  NOT NULL,
#     `m1_id`              bigint(20)                  NOT NULL,

    PRIMARY KEY (`id`),
    KEY `idx_ver` (`row_version`),
    KEY `idx_crea` (`row_created`),
    KEY `idx_per` (`row_persisted`),
    KEY `idx_ret` (`row_retired`),

    UNIQUE KEY `idx_m` (`m_id`),
#     UNIQUE KEY `idx_m1` (`m1_id`),
#     CONSTRAINT `fk_u_m1` FOREIGN KEY (`m1_id`) REFERENCES `M` (`id`),
    CONSTRAINT `fk_u_m` FOREIGN KEY (`m_id`) REFERENCES `M` (`id`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;



/*!40103 SET TIME_ZONE = @OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE = @OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT = @OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS = @OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION = @OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES = @OLD_SQL_NOTES */;
