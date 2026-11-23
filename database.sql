-- ==============================================================
-- DATABASE SCHEMA: Laporan Service Sistem Android & Casing
-- Multi-Database Terpisah (5 Database):
-- 1. laporan_hardware_hp     : Teknisi Hardware - Service HP, PC & Tab
-- 2. laporan_hardware_alat   : Teknisi Hardware - Service Alat Lain
-- 3. laporan_hardware_rusak  : Teknisi Hardware - Data Barang Rusak
-- 4. laporan_casing_admin    : Teknisi Casing   - Dari Admin Stock
-- 5. laporan_casing_paket    : Teknisi Casing   - Dari Paket
-- Cocok untuk MySQL 5.7+, MySQL 8.0+, dan MariaDB 10.3+
-- ==============================================================

-- ==============================================================
-- 1. DATABASE: Service HP, PC & Tab (Hardware)
-- ==============================================================
CREATE DATABASE IF NOT EXISTS `laporan_hardware_hp` 
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `laporan_hardware_hp`;

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
-- 2. DATABASE: Service Alat Lain (Hardware)
-- ==============================================================
CREATE DATABASE IF NOT EXISTS `laporan_hardware_alat` 
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `laporan_hardware_alat`;

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
-- 3. DATABASE: Data Barang Rusak (Hardware)
-- ==============================================================
CREATE DATABASE IF NOT EXISTS `laporan_hardware_rusak` 
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `laporan_hardware_rusak`;

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
  `kondisi` VARCHAR(50) DEFAULT 'Afkir / Rusak Total',
  `lamaHari` INT DEFAULT 0,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_tgl_masuk` (`tanggalMasuk`),
  INDEX `idx_lokasi` (`lokasiDari`),
  INDEX `idx_jenis` (`jenisAlatNama`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ==============================================================
-- 4. DATABASE: Dari Admin Stock (Casing)
-- ==============================================================
CREATE DATABASE IF NOT EXISTS `laporan_casing_admin` 
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `laporan_casing_admin`;

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
-- 5. DATABASE: Dari Paket (Casing)
-- ==============================================================
CREATE DATABASE IF NOT EXISTS `laporan_casing_paket` 
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `laporan_casing_paket`;

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
