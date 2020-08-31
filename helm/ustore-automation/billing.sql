create database mangue_billing;

use mangue_billing;

CREATE TABLE summarizedPerformance (
    name varchar(100) NOT NULL,
    namespace varchar(40),
    sumCpuUsage float(50,5) NOT NULL,
    cpuPrice float(50,5) NOT NULL,
    sumMemoryUsage float(50,5) NOT NULL,
    memoryPrice float(50,5) NOT NULL,
    clusterId int(11) NOT NULL,
    totalRows int(255) NOT NULL,
    year int(5) NOT NULL, 
    month int(2) NOT NULL,
    day int(2) NOT NULL,
    hour int(2) NOT NULL,
    resourceParent VARCHAR(20),
    PRIMARY KEY(name, year, month, day, hour, cpuPrice, memoryPrice, clusterId)
);

CREATE TABLE podPerformance (
    id varchar(80) NOT NULL,
    name varchar(100) NOT NULL,
    namespace varchar(40) NOT NULL,
    clusterId int(11) NOT NULL,
    cpuUsage float(50,3) NOT NULL,
    memoryUsage float(50,3) NOT NULL,
    cpuPrice float(50,2) NOT NULL,
    memoryPrice float(50,2) NOT NULL,
    resourceParent VARCHAR(20),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW() ON UPDATE NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (id)
);

CREATE TABLE summarizedMonth (
    totalCpuPrice float(50,5) NOT NULL,
    totalMemoryPrice float(50,5) NOT NULL,
    totalPrice float(50,5) NOT NULL,
    clusterId int(11) NOT NULL,
    year int(5) NOT NULL, 
    month int(2) NOT NULL,
    PRIMARY KEY(year, month, totalCpuPrice, totalMemoryPrice, totalPrice, clusterId)
);

DELIMITER ;;
CREATE TRIGGER podPerformance_ins
AFTER INSERT ON podPerformance
FOR EACH ROW
BEGIN

  SET @old_cpuUsageSum = 0;
  SET @old_memoryUsage = 0;
  SET @old_totalRows = 0;

  SELECT IFNULL(sumCpuUsage, 0), IFNULL(sumMemoryUsage, 0), IFNULL(totalRows,0)
    FROM summarizedPerformance
   WHERE name = NEW.name and clusterId=NEW.clusterId and year=YEAR(CONVERT_TZ(NEW.created_at, @@session.time_zone, 'SYSTEM')) and month=MONTH(CONVERT_TZ(NEW.created_at, @@session.time_zone, 'SYSTEM')) 
   and day=DAY(CONVERT_TZ(NEW.created_at, @@session.time_zone, 'SYSTEM')) and hour=HOUR(CONVERT_TZ(NEW.created_at, @@session.time_zone, 'SYSTEM'))
   and memoryPrice= NEW.memoryPrice and cpuPrice= NEW.cpuPrice
    INTO @old_cpuUsageSum, @old_memoryUsage, @old_totalRows;

  SET @new_cpu_sum = @old_cpuUsageSum + NEW.cpuUsage;
  SET @new_memory_sum = @old_memoryUsage + NEW.memoryUsage;
  SET @new_totalRows = @old_totalRows + 1;

  REPLACE INTO `summarizedPerformance` set name=NEW.name, sumCpuUsage=@new_cpu_sum, cpuPrice=NEW.cpuPrice, sumMemoryUsage=@new_memory_sum, memoryPrice=NEW.memoryPrice, clusterId=NEW.clusterId, 
  totalRows=@new_totalRows, year=YEAR(CONVERT_TZ(NEW.created_at, @@session.time_zone, 'SYSTEM')), month=MONTH(CONVERT_TZ(NEW.created_at, @@session.time_zone, 'SYSTEM')),
  day=DAY(CONVERT_TZ(NEW.created_at, @@session.time_zone, 'SYSTEM')), hour=HOUR(CONVERT_TZ(NEW.created_at, @@session.time_zone, 'SYSTEM')), namespace=NEW.namespace, resourceParent=NEW.resourceParent;

END;
;;
DELIMITER ;
