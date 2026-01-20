CREATE TABLE `sdft_vehicles` (
  `plate` VARCHAR(60) NOT NULL,
  `owner` VARCHAR(120) NOT NULL,
  `trucktype` int(20) NOT NULL,
  `truckmodel` VARCHAR(60) NOT NULL,
  `addons` LONGTEXT NOT NULL,
  `storage` LONGTEXT NOT NULL,
  `blip` LONGTEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

ALTER TABLE `sdft_vehicles`
  ADD PRIMARY KEY (`plate`)
;
