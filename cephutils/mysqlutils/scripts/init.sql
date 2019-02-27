-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: 10.19.140.200:31036
-- Generation Time: 2017-07-03 07:30:40
-- 服务器版本： 5.7.18
-- PHP Version: 7.0.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `grafana`
--
CREATE DATABASE IF NOT EXISTS `grafana` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

--
-- Database: `osticket`
--
CREATE DATABASE IF NOT EXISTS `osticket` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

--
-- Database: `prometheus`
--
CREATE DATABASE IF NOT EXISTS `prometheus` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
USE `prometheus`;

--
-- 表的结构 `alerts`
--

CREATE TABLE `alerts` (
  `id` int(11) NOT NULL,
  `_from` varchar(20) NOT NULL DEFAULT 'default' COMMENT '来自哪个渠道的报警',
  `status` varchar(20) NOT NULL,
  `cluster` varchar(20) NOT NULL,
  `namespace` varchar(50) NOT NULL,
  `type` varchar(20) NOT NULL,
  `alertname` varchar(20) NOT NULL DEFAULT 'unknown',
  `instance` varchar(100) NOT NULL,
  `fingerprint` bigint(64) UNSIGNED NOT NULL COMMENT '根据labelset生成',
  `labels` varchar(1024) NOT NULL,
  `annotations` text NOT NULL,
  `starts_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ends_at` datetime DEFAULT '0001-01-01 00:00:00',
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `alerts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fingerprint` (`fingerprint`),
  ADD KEY `starts_at` (`starts_at`),
  ADD KEY `ends_at` (`ends_at`),
  ADD KEY `cluster-namespace` (`cluster`),
  ADD KEY `_from` (`_from`);

ALTER TABLE `alerts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;COMMIT;

  --
  -- 表的结构 `clusters`
  --

  CREATE TABLE `clusters` (
    `id` int(11) NOT NULL,
    `name` varchar(255) DEFAULT NULL,
    `status` int(11) DEFAULT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  --
  -- 转存表中的数据 `clusters`
  --

  INSERT INTO `clusters` (`id`, `name`, `status`) VALUES
  (1, 'shanghai', 0),
  (2, 'yancheng', 0);

  --
  -- Indexes for dumped tables
  --

  --
  -- Indexes for table `clusters`
  --
  ALTER TABLE `clusters`
    ADD PRIMARY KEY (`id`);

  --
  -- 在导出的表使用AUTO_INCREMENT
  --

  --
  -- 使用表AUTO_INCREMENT `clusters`
  --
  ALTER TABLE `clusters`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;COMMIT;

  --
  -- 表的结构 `bizlines`
  --

  CREATE TABLE `bizlines` (
    `id` int(11) NOT NULL,
    `name` varchar(255) DEFAULT NULL,
    `status` int(11) DEFAULT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  --
  -- 转存表中的数据 `bizlines`
  --

  INSERT INTO `bizlines` (`id`, `name`, `status`) VALUES
  (1, 'common', 0),
  (2, 'bigdata', 0),
  (3, 'console', 0),
  (4, 'k8s', 0),
  (5, 'ops', 0),
  (6, 'ml', 0),
  (7, 'monitor', 0);

  --
  -- Indexes for dumped tables
  --

  --
  -- Indexes for table `bizlines`
  --
  ALTER TABLE `bizlines`
    ADD PRIMARY KEY (`id`);

  --
  -- 在导出的表使用AUTO_INCREMENT
  --

  --
  -- 使用表AUTO_INCREMENT `bizlines`
  --
  ALTER TABLE `bizlines`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;COMMIT;


  CREATE TABLE `scripts` (
    `id` int(11) NOT NULL,
    `type` varchar(255) DEFAULT NULL,
    `name` varchar(255) DEFAULT NULL,
    `filename` varchar(255) DEFAULT NULL,
    `description` varchar(255) DEFAULT NULL,
    `status` int(11) DEFAULT NULL,
    `created_at` timestamp NULL DEFAULT NULL,
    `updated_at` timestamp NULL DEFAULT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  --
  -- 转存表中的数据 `scripts`
  --

  INSERT INTO `scripts` (`id`, `type`, `name`, `filename`, `description`, `status`, `created_at`, `updated_at`) VALUES
  (1, 'check', 'check_service_status.sh', 'script.sh.1526389904840133049', 'check service status by curl and nc', 0, null, null),
  (2, 'check', 'check_prometheus_status.sh', 'script.sh.1526436540627334622', 'check prometheus status', 0, null, null),
  (3, 'check', 'check_hdfs_status.sh', 'script.sh.1526440272893725262', 'check hdfs status', 0, null, null),
  (4, 'check', 'check_ceph_clock_status.sh', 'script.sh.1526465658056343383', 'check ceph clock', 0, null, null),
  (5, 'check', 'check_mongo_status.sh', '', 'check mongo status', 0, null, null),
  (6, 'check', 'check_opentsdb_status.sh', 'script.sh.1526475124027445158', 'check opentsdb status', 0, null, null),
  (7, 'check', 'check_hbase_status.sh', 'script.sh.1526475538856661384', 'check hbase status', 0, null, null),
  (8, 'check', 'check_zookeeper_status.sh', 'script.sh.1526475864259316034', 'check zookeeper status', 0, null, null),
  (9, 'check', 'check_kafka_status.sh', 'script.sh.1526476346015010197', 'check kafka status', 0, null, null),
  (10, 'check', 'check_spark_status.sh', 'script.sh.1526537936926726843', 'check spark status', 0, null, null),
  (11, 'check', 'check_spark_job.sh', 'script.sh.1526538871388057655', 'check spark job', 0, null, null),
  (12, 'check', 'check_mongo_rs_status.sh', 'script.sh.1526543908076885780', 'check mongo replicaset status', 0, null, null),
  (13, 'check', 'fping.sh', 'script.sh.1526551526117540282', 'fping', 0, null, null),
  (14, 'check', 'check_Druid_status.sh', 'script.sh.1526611818470622160', 'check Druid status', 0, null, null),
  (15, 'check', 'check_rm_status.sh', 'script.sh.1526612395472252698', 'check rm status', 0, null, null),
  (16, 'check', 'check_impala_cluster_status.sh', 'script.sh.1526613115379119750', 'check impala cluster status', 0, null, null),
  (17, 'check', 'check_mysql_status.sh', 'script.sh.1526613823897417428', 'check mysql status', 0, null, null);

  --
  -- Indexes for dumped tables
  --

  --
  -- Indexes for table `scripts`
  --
  ALTER TABLE `scripts`
    ADD PRIMARY KEY (`id`);

  --
  -- 在导出的表使用AUTO_INCREMENT
  --

  --
  -- 使用表AUTO_INCREMENT `scripts`
  --
  ALTER TABLE `scripts`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;COMMIT;

    --
  -- 表的结构 `service_check_configs`
  --

  CREATE TABLE `service_check_configs` (
    `id` int(11) NOT NULL,
    `cluster` varchar(255) DEFAULT NULL,
    `bizline` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
    `name` varchar(255) DEFAULT NULL,
    `description` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
    `script_id` int(11) DEFAULT NULL,
    `timeout` int(11) DEFAULT NULL,
    `args` varchar(512) CHARACTER SET latin1 DEFAULT NULL,
    `automation` int(11) DEFAULT NULL,
    `extra_tags` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
    `status` int(11) DEFAULT NULL,
    `created_at` timestamp NULL DEFAULT NULL,
    `updated_at` timestamp NULL DEFAULT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  --
  -- 转存表中的数据 `service_check_configs`
  --

  INSERT INTO `service_check_configs` (`id`, `cluster`, `bizline`, `name`, `description`, `script_id`, `timeout`, `args`, `automation`, `extra_tags`, `status`, `created_at`, `updated_at`) VALUES
  (1, 'shanghai', 'monitor', 'baidu', '', 1, 6, '-servicename baidu -IP www.baidu1.com -getdatamethod curl', 0, '', 0, null, null);

  --
  -- Indexes for dumped tables
  --

  --
  -- Indexes for table `service_check_configs`
  --
  ALTER TABLE `service_check_configs`
    ADD PRIMARY KEY (`id`);

  --
  -- 在导出的表使用AUTO_INCREMENT
  --

  --
  -- 使用表AUTO_INCREMENT `service_check_configs`
  --
  ALTER TABLE `service_check_configs`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;COMMIT;

--
-- 表的结构 `email_servers`
--

CREATE TABLE `email_servers` (
  `smtp_smart_host` varchar(255) DEFAULT NULL,
  `smtp_from` varchar(255) DEFAULT NULL,
  `smtp_auth_username` varchar(255) DEFAULT NULL,
  `smtp_auth_password` varchar(255) DEFAULT NULL,
  `tls` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `email_servers`
--

INSERT INTO `email_servers` (`smtp_smart_host`, `smtp_from`, `smtp_auth_username`, `smtp_auth_password`, `tls`, `status`) VALUES
('10.19.248.200:30071', 'wst_casd@enncdata.cn', 'wst_casd@enncdata.cn', '123123', 0, 0);


--
-- 表的结构 `service_automation_configs`
--

CREATE TABLE `service_automation_configs` (
  `id` int(11) NOT NULL,
  `type` varchar(255) DEFAULT NULL,
  `service_check_config_id` int(11) DEFAULT NULL,
  `step` int(11) DEFAULT NULL,
  `action_code` int(11) DEFAULT NULL,
  `args` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `script_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


  --
  -- Indexes for dumped tables
  --

--
-- Indexes for table `service_automation_configs`
--
ALTER TABLE `service_automation_configs`
  ADD PRIMARY KEY (`id`);

--
-- 使用表AUTO_INCREMENT `service_automation_configs`
--
ALTER TABLE `service_automation_configs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;COMMIT;



--
-- 表的结构 `alert_receiver_configs`
--

CREATE TABLE `alert_receiver_configs` (
  `id` int(11) NOT NULL,
  `send_resolved` int(11) DEFAULT NULL,
  `receiver_name` varchar(255) DEFAULT NULL,
  `email_address` varchar(255) DEFAULT NULL,
  `slack_address` varchar(255) DEFAULT NULL,
  `webhook_address` varchar(255) DEFAULT NULL,
  `wechat_id` varchar(255) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `alert_receiver_configs`
--

INSERT INTO `alert_receiver_configs` (`id`, `send_resolved`, `receiver_name`, `email_address`, `slack_address`, `webhook_address`, `wechat_id`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'default', 'wst_casd@163.com', NULL, 'http://10.19.248.200:29300/api/v1/alert_hook', '', 0, NULL, NULL),
(2, 1, 'monitor_wst', 'wst_casd@163.com', NULL, NULL, NULL, 0, NULL, NULL),
(3, 1, 'monitor_wzy', 'wst_casd@163.com', NULL, 'http://10.19.248.200:29300/api/v1/alert_hook', '王钊扬', 0, NULL, NULL),
(4, 1, 'streaming_renyi', NULL, NULL, 'http://10.19.248.200:29300/api/v1/alert_hook', '任一', 0, NULL, NULL),
(5, 1, 'bigdata_zly', NULL, NULL, 'http://10.19.248.200:29300/api/v1/alert_hook', '张李晔', 0, NULL, NULL),
(6, 1, 'streaming_gjq', NULL, NULL, 'http://10.19.248.200:29300/api/v1/alert_hook', '高璟琦', 0, NULL, NULL),
(7, 1, 'console_zxm', '', NULL, 'http://10.19.248.200:29300/api/v1/alert_hook', '郑晓明', 0, NULL, NULL),
(8, 1, 'k8s_sj', NULL, NULL, 'http://10.19.248.200:29300/api/v1/alert_hook', '史杰', 0, NULL, NULL),
(9, 1, 'streaming_daiping', NULL, NULL, 'http://10.19.248.200:29300/api/v1/alert_hook', '戴平', 0, NULL, NULL),
(10, 1, 'k8s_msx', NULL, NULL, 'http://10.19.248.200:29300/api/v1/alert_hook', '缪士宣', 0, NULL, NULL);


--
-- Indexes for table `alert_receiver_configs`
--
ALTER TABLE `alert_receiver_configs`
  ADD PRIMARY KEY (`id`);

--
-- 使用表AUTO_INCREMENT `alert_receiver_configs`
--
ALTER TABLE `alert_receiver_configs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;COMMIT;
-- --------------------------------------------------------

--
-- 表的结构 `alert_route_configs`
--

CREATE TABLE `alert_route_configs` (
  `id` int(11) NOT NULL,
  `parent_id` int(11) NOT NULL,
  `group_by` varchar(255) DEFAULT NULL,
  `match_tags` varchar(255) DEFAULT NULL,
  `receiver` varchar(255) DEFAULT NULL,
  `group_wait` int(11) DEFAULT NULL,
  `repeat_interval` int(11) DEFAULT NULL,
  `group_interval` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `alert_route_configs`
--

INSERT INTO `alert_route_configs` (`id`, `parent_id`, `group_by`, `match_tags`, `receiver`, `group_wait`, `repeat_interval`, `group_interval`, `status`, `created_at`, `updated_at`) VALUES
(1, 0, 'clustername;bizline', 'clustername=shanghai;bizline=monitor', 'monitor_wst', 20, 0, 0, 0, NULL, NULL);


  --
  -- Indexes for dumped tables
  --

--
-- Indexes for table `alert_route_configs`
--
ALTER TABLE `alert_route_configs`
  ADD PRIMARY KEY (`id`);

-- 使用表AUTO_INCREMENT `alert_route_configs`
--
ALTER TABLE `alert_route_configs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;COMMIT;
-- --------------------------------------------------------
