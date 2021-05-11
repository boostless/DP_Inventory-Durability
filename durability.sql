

CREATE TABLE IF NOT EXISTS `inventory_durability` (
  `owner` text NOT NULL,
  `item` text NOT NULL,
  `durability` int(11) NOT NULL DEFAULT 10
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

