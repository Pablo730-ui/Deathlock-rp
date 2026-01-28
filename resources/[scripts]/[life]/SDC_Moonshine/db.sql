CREATE TABLE `sdc_barrels` (
  `id` VARCHAR(60) NOT NULL,
  `owner` VARCHAR(140) NOT NULL,
  `barrel_data` LONGTEXT NOT NULL,
  `mashid` VARCHAR(60) NOT NULL,
  `timeleft` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `sdc_barrels`
  ADD PRIMARY KEY (`id`)
;

CREATE TABLE `sdc_stills` (
  `id` VARCHAR(60) NOT NULL,
  `owner` VARCHAR(140) NOT NULL,
  `still_data` LONGTEXT NOT NULL,
  `cook_data` LONGTEXT NOT NULL,
  `other_data` LONGTEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `sdc_stills`
  ADD PRIMARY KEY (`id`)
;

CREATE TABLE `sdc_moonshinesales` (
  `id` VARCHAR(60) NOT NULL,
  `bottles_sold` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `sdc_moonshinesales`
  ADD PRIMARY KEY (`id`)
;