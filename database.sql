-- ==============================================================
-- DATABASE SCHEMA: Laporan Service Sistem Android
-- Pemisahan Database: Hardware & Casing
-- Cocok untuk MySQL 5.7+, MySQL 8.0+, dan MariaDB 10.3+
-- ==============================================================

-- ==============================================================
-- 1. DATABASE TEKNISI HARDWARE
-- ==============================================================
CREATE DATABASE IF NOT EXISTS `laporan_service_hardware` 
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `laporan_service_hardware`;

CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT NOT NULL,
  `username` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `nama` VARCHAR(255) NOT NULL,
  `role` VARCHAR(100) NOT NULL DEFAULT 'Admin',
  `avatar` LONGTEXT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `users` (`id`, `username`, `password`, `nama`, `role`, `avatar`) VALUES
(1, 'hardware', 'hardware123', 'Teknisi Hardware', 'Teknisi Hardware', NULL),
(2, 'casing', 'casing123', 'Teknisi Casing', 'Teknisi Casing', NULL)
ON DUPLICATE KEY UPDATE `password` = VALUES(`password`), `nama` = VALUES(`nama`), `role` = VALUES(`role`);

CREATE TABLE IF NOT EXISTS `jenis_alat` (
  `id` BIGINT NOT NULL,
  `nama` VARCHAR(255) NOT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `kategori_lokasi` (
  `id` BIGINT NOT NULL,
  `nama` VARCHAR(255) NOT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `laporan` (
  `id` BIGINT NOT NULL,
  `no` VARCHAR(50) DEFAULT '',
  `tanggalMasuk` VARCHAR(50) DEFAULT '',
  `tanggalKeluar` VARCHAR(50) DEFAULT '',
  `jumlahAlat` INT DEFAULT 1,
  `keteranganPerbaikan` TEXT,
  `jenisAlatId` BIGINT DEFAULT NULL,
  `jenisAlatNama` VARCHAR(255) DEFAULT '',
  `lokasiDari` VARCHAR(255) DEFAULT '',
  `kondisi` VARCHAR(50) DEFAULT 'Lama',
  `lamaHari` INT DEFAULT 0,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_tgl_masuk` (`tanggalMasuk`),
  INDEX `idx_lokasi` (`lokasiDari`),
  INDEX `idx_jenis` (`jenisAlatNama`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ==============================================================
-- 2. DATABASE TEKNISI CASING
-- ==============================================================
CREATE DATABASE IF NOT EXISTS `laporan_service_casing` 
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `laporan_service_casing`;

CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT NOT NULL,
  `username` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `nama` VARCHAR(255) NOT NULL,
  `role` VARCHAR(100) NOT NULL DEFAULT 'Admin',
  `avatar` LONGTEXT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `users` (`id`, `username`, `password`, `nama`, `role`, `avatar`) VALUES
(1, 'hardware', 'hardware123', 'Teknisi Hardware', 'Teknisi Hardware', NULL),
(2, 'casing', 'casing123', 'Teknisi Casing', 'Teknisi Casing', NULL)
ON DUPLICATE KEY UPDATE `password` = VALUES(`password`), `nama` = VALUES(`nama`), `role` = VALUES(`role`);

CREATE TABLE IF NOT EXISTS `jenis_alat` (
  `id` BIGINT NOT NULL,
  `nama` VARCHAR(255) NOT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `kategori_lokasi` (
  `id` BIGINT NOT NULL,
  `nama` VARCHAR(255) NOT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `laporan` (
  `id` BIGINT NOT NULL,
  `no` VARCHAR(50) DEFAULT '',
  `tanggalMasuk` VARCHAR(50) DEFAULT '',
  `tanggalKeluar` VARCHAR(50) DEFAULT '',
  `jumlahAlat` INT DEFAULT 1,
  `keteranganPerbaikan` TEXT,
  `jenisAlatId` BIGINT DEFAULT NULL,
  `jenisAlatNama` VARCHAR(255) DEFAULT '',
  `lokasiDari` VARCHAR(255) DEFAULT '',
  `kondisi` VARCHAR(50) DEFAULT 'Lama',
  `lamaHari` INT DEFAULT 0,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_tgl_masuk` (`tanggalMasuk`),
  INDEX `idx_lokasi` (`lokasiDari`),
  INDEX `idx_jenis` (`jenisAlatNama`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
