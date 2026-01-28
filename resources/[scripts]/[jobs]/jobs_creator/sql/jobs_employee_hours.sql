CREATE TABLE IF NOT EXISTS `jobs_employee_hours` (
	`job_name` VARCHAR(50) NOT NULL,
	`char_identifier` VARCHAR(100) NOT NULL,
	`total_minutes` INT(11) NOT NULL DEFAULT '0',
	`date` DATE NOT NULL,
	PRIMARY KEY (`job_name`, `char_identifier`, `date`)
) ENGINE=InnoDB;