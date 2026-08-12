-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 07 Agu 2026 pada 11.14
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bk_system`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `catatan_pelanggaran`
--

CREATE TABLE `catatan_pelanggaran` (
  `id` int(11) NOT NULL,
  `siswa_nis` varchar(10) NOT NULL,
  `siswa_nama` varchar(100) NOT NULL,
  `siswa_kelas` varchar(20) NOT NULL,
  `tanggal` date NOT NULL,
  `pelanggaran_id` int(11) NOT NULL,
  `poin` int(11) NOT NULL,
  `keterangan` text DEFAULT NULL,
  `dicatat_oleh` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Trigger `catatan_pelanggaran`
--
DELIMITER $$
CREATE TRIGGER `update_rekap_pelanggaran` AFTER INSERT ON `catatan_pelanggaran` FOR EACH ROW BEGIN
    DECLARE total_poin_baru INT;
    DECLARE total_jumlah INT;
    DECLARE level_baru ENUM('Teguran', 'Pembinaan', 'Peringatan', 'Panggilan Orang Tua', 'Skorsing');
    
    -- Hitung total poin dan jumlah pelanggaran
    SELECT SUM(poin), COUNT(*) INTO total_poin_baru, total_jumlah
    FROM catatan_pelanggaran
    WHERE siswa_nis = NEW.siswa_nis;
    
    -- Tentukan level berdasarkan total poin
    IF total_poin_baru >= 200 THEN
        SET level_baru = 'Skorsing';
    ELSEIF total_poin_baru >= 150 THEN
        SET level_baru = 'Panggilan Orang Tua';
    ELSEIF total_poin_baru >= 100 THEN
        SET level_baru = 'Peringatan';
    ELSEIF total_poin_baru >= 50 THEN
        SET level_baru = 'Pembinaan';
    ELSE
        SET level_baru = 'Teguran';
    END IF;
    
    -- Insert atau update rekap
    INSERT INTO rekap_pelanggaran_siswa 
    (siswa_nis, siswa_nama, siswa_kelas, total_poin, total_pelanggaran, level_pelanggaran)
    VALUES (NEW.siswa_nis, NEW.siswa_nama, NEW.siswa_kelas, total_poin_baru, total_jumlah, level_baru)
    ON DUPLICATE KEY UPDATE
        total_poin = total_poin_baru,
        total_pelanggaran = total_jumlah,
        level_pelanggaran = level_baru;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `chat_messages`
--

CREATE TABLE `chat_messages` (
  `id` int(11) NOT NULL,
  `session_id` varchar(150) NOT NULL,
  `sender_id` varchar(50) NOT NULL,
  `sender_name` varchar(100) DEFAULT NULL,
  `sender_type` enum('siswa','guru') NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `chat_messages`
--

INSERT INTO `chat_messages` (`id`, `session_id`, `sender_id`, `sender_name`, `sender_type`, `message`, `created_at`) VALUES
(1, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'halo', '2026-03-28 05:28:28'),
(2, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'p', '2026-03-28 05:28:32'),
(3, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'a', '2026-03-28 05:28:36'),
(4, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 's', '2026-03-28 05:28:42'),
(5, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'w', '2026-03-28 05:28:54'),
(6, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'asu', '2026-03-28 05:29:03'),
(7, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'kontol', '2026-03-28 05:29:15'),
(8, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'test', '2026-03-28 05:30:55'),
(9, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'saya di bully', '2026-03-28 05:31:28'),
(10, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'anjing', '2026-03-28 05:31:46'),
(11, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 's', '2026-03-28 05:33:12'),
(12, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'halo', '2026-03-28 05:40:02'),
(13, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 's', '2026-03-28 05:40:15'),
(14, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'asdsada', '2026-03-28 05:40:34'),
(15, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'halo', '2026-03-28 05:44:34'),
(16, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'aku', '2026-03-28 05:45:39'),
(17, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'bisa', '2026-03-28 05:45:44'),
(18, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky', 'cihuy', 'siswa', 'kakak', '2026-03-28 05:51:05'),
(19, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicka', 'sss', 'siswa', 'asslamualaikum', '2026-03-28 05:52:06'),
(20, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicka', 'sss', 'siswa', 'saya di bully pak', '2026-03-28 05:52:13'),
(21, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky_bk', 'dicky_bk', 'guru', 'gimana', '2026-03-28 06:11:45'),
(22, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky_bk', 'dicky_bk', 'guru', 'waduh bagaimana', '2026-03-28 06:15:51'),
(23, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky_bk', 'dicky_bk', 'guru', 'kok bisa', '2026-03-28 06:15:56'),
(24, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicka', 'sss', 'siswa', 'assalam', '2026-03-28 06:32:21'),
(25, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky_bk', 'dicky_bk', 'guru', 'waalaikum sallam', '2026-03-28 06:32:29'),
(26, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicka', 'sss', 'siswa', 'pak', '2026-03-28 06:36:00'),
(27, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky_bk', 'dicky_bk', 'guru', 'iya nak', '2026-03-28 06:36:05'),
(28, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky_bk', 'dicky_bk', 'guru', 'bos', '2026-03-28 06:44:47'),
(29, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicka', 'sss', 'siswa', 's', '2026-03-28 06:50:58'),
(30, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky_bk', 'dicky_bk', 'guru', 'woi', '2026-03-28 06:53:21'),
(31, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicka', 'sss', 'siswa', 'cihuy', '2026-03-28 07:04:40'),
(32, 'session_dicka_Dicky_Ardiansyah_S.Pd_2026-03-28', 'dicky_bk', 'dicky_bk', 'guru', 'bapak kau cihuy', '2026-03-28 07:04:54'),
(33, 'session_joh_Dicky_Ardiansyah_S.Pd_2026-03-28', 'joh', 'asdasd', 'siswa', 'a', '2026-03-28 06:44:14'),
(34, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-29', 'dicky', 'dicky ganteng', 'siswa', 'p', '2026-03-29 11:50:44'),
(35, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-29', 'dicky', 'dicky ganteng', 'siswa', 'assalamualaikum', '2026-03-29 11:51:40'),
(36, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-29', 'dicky', 'dicky ganteng', 'siswa', 'woi dicky', '2026-03-29 11:51:57'),
(37, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-03-29', 'dicky_bk', 'dicky_bk', 'guru', 'halo', '2026-03-29 11:52:02'),
(38, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-16', 'dicky_bk', 'dicky_bk', 'guru', 'halo nak', '2026-04-16 12:06:59'),
(39, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-16', 'dicky', 'dika kontol', 'siswa', 'woi kontol', '2026-04-16 12:07:07'),
(40, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-16', 'dicky', 'dika kontol', 'siswa', 'saya mau ewe', '2026-04-16 12:07:16'),
(41, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-16', 'dicky_bk', 'dicky_bk', 'guru', '150k per jam', '2026-04-16 12:07:30'),
(42, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-16', 'dicky', 'dika kontol', 'siswa', 'gas', '2026-04-16 12:07:39'),
(43, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-16', 'dicky_bk', 'dicky_bk', 'guru', 'gimana masalahnya nak', '2026-04-16 12:07:48'),
(44, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-16', 'dicky_bk', 'dicky_bk', 'guru', 'gabung zoom saya ya', '2026-04-16 12:07:57'),
(45, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-16', 'dicky_bk', 'dicky_bk', 'guru', 'pencet linknya xnxx.com', '2026-04-16 12:08:10'),
(46, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky_bk', 'dicky_bk', 'guru', 'halo', '2026-04-17 04:00:14'),
(47, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky', 'dika kontol', 'siswa', 'halo', '2026-04-17 04:00:25'),
(48, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky', 'dika kontol', 'siswa', 'gimana bos', '2026-04-17 04:00:31'),
(49, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky_bk', 'dicky_bk', 'guru', 'nak', '2026-04-17 04:01:02'),
(50, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky', 'dika kontol', 'siswa', 'apa pak', '2026-04-17 04:01:06'),
(51, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky_bk', 'dicky_bk', 'guru', 's', '2026-04-17 04:01:25'),
(52, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky', 'dika kontol', 'siswa', 'i', '2026-04-17 04:01:28'),
(53, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky_bk', 'dicky_bk', 'guru', 's', '2026-04-17 04:01:39'),
(54, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky_bk', 'dicky_bk', 'guru', 'dsad', '2026-04-17 04:01:42'),
(55, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky_bk', 'dicky_bk', 'guru', 'sad', '2026-04-17 04:01:43'),
(56, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky_bk', 'dicky_bk', 'guru', 'asd', '2026-04-17 04:01:54'),
(57, 'session_dicky_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky', 'dika kontol', 'siswa', 'woi kontol', '2026-04-17 04:03:00'),
(58, 'session_dickaa_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky_bk', 'dicky_bk', 'guru', 'halo', '2026-04-17 07:35:59'),
(59, 'session_dickaa_Dicky_Ardiansyah_S.Pd_2026-04-17', 'dicky_bk', 'dicky_bk', 'guru', 'sya diki', '2026-04-17 07:38:52'),
(60, 'session_2020_Dicky_Ardiansyah_S.Pd_2026-04-20', 'dicky_bk', 'dicky_bk', 'guru', 'woi kontol', '2026-04-20 11:54:00'),
(61, 'session_2020_Dicky_Ardiansyah_S.Pd_2026-04-20', '2020', 'dwi ahmad yesus', 'siswa', 'apa asu', '2026-04-20 11:54:17'),
(62, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', 'dicky_bk', 'dicky_bk', 'guru', 'hey antek', '2026-06-28 16:23:42'),
(63, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', '1234', 'maulana', 'siswa', 'woi kontol', '2026-06-28 16:24:01'),
(64, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', 'dicky_bk', 'dicky_bk', 'guru', 'asuuu anjing babi', '2026-06-28 16:24:09'),
(65, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', '1234', 'maulana', 'siswa', 'puki memek ajgggggggggggggg', '2026-06-28 16:24:18'),
(66, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', 'dicky_bk', 'dicky_bk', 'guru', 'dasssssssssssssssss', '2026-06-28 16:24:22'),
(67, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', 'dicky_bk', 'dicky_bk', 'guru', 'dsaaaaaaaa', '2026-06-28 16:24:38'),
(68, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', 'dicky_bk', 'dicky_bk', 'guru', 'a', '2026-06-28 16:24:42'),
(69, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', 'dicky_bk', 'dicky_bk', 'guru', 'asddddddddddd', '2026-06-28 16:24:45'),
(70, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', 'dicky_bk', 'dicky_bk', 'guru', 'dassssssssss', '2026-06-28 16:24:47'),
(71, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', 'dicky_bk', 'dicky_bk', 'guru', 'sadddddddd', '2026-06-28 16:24:49'),
(72, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', '1234', 'maulana', 'siswa', 'sad', '2026-06-28 16:24:53'),
(73, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', '1234', 'maulana', 'siswa', 'sadddddd', '2026-06-28 16:24:54'),
(74, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', '1234', 'maulana', 'siswa', 'asdddddddddd', '2026-06-28 16:24:56'),
(75, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', '1234', 'maulana', 'siswa', 'asddddddd', '2026-06-28 16:24:58'),
(76, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', '1234', 'maulana', 'siswa', 'asddddddddddddddd', '2026-06-28 16:25:00'),
(77, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-06-28', '1234', 'maulana', 'siswa', 'sadddddddddddd', '2026-06-28 16:25:02'),
(78, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-05', '1234', 'maulana', 'siswa', 'halo', '2026-08-05 06:56:51'),
(79, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-05', '1234', 'maulana', 'siswa', 'halo pak dicky', '2026-08-05 07:06:44'),
(80, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-05', 'dicky_bk', 'dicky_bk', 'guru', 'halo mas', '2026-08-05 07:06:49'),
(81, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-05', '1234', 'maulana', 'siswa', 'halo pak jadi gini', '2026-08-05 07:07:52'),
(82, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-05', 'dicky_bk', 'dicky_bk', 'guru', 'gimana', '2026-08-05 07:07:59'),
(83, 'session_5606_Dicky_Ardiansyah_S.Pd_2026-08-06', '5606', 'A.ROISYA SYARIF', 'siswa', 'halo', '2026-08-06 02:27:58'),
(84, 'session_5606_Dicky_Ardiansyah_S.Pd_2026-08-06', 'dicky_bk', 'dicky_bk', 'guru', 'halo gimana', '2026-08-06 02:28:07'),
(85, 'session_5606_Dicky_Ardiansyah_S.Pd_2026-08-06', '5606', 'A.ROISYA SYARIF', 'siswa', 'p', '2026-08-06 02:28:37'),
(86, 'session_5606_Dicky_Ardiansyah_S.Pd_2026-08-06', 'dicky_bk', 'dicky_bk', 'guru', 'p', '2026-08-06 02:28:41'),
(87, 'session_5606_Dicky_Ardiansyah_S.Pd_2026-08-06', '5606', 'A.ROISYA SYARIF', 'siswa', 'halo pak', '2026-08-06 02:30:34'),
(88, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-06', '1234', 'maulana', 'siswa', 'halo', '2026-08-06 23:29:40'),
(89, 'session_5606_Dicky_Ardiansyah_S.Pd_2026-08-06', 'dicky_bk', 'dicky_bk', 'guru', 'p', '2026-08-06 23:29:47'),
(90, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-06', '1234', 'maulana', 'siswa', 'halo pak', '2026-08-06 23:30:20'),
(91, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-06', '1234', 'maulana', 'siswa', 'p', '2026-08-06 23:31:08'),
(92, 'session_5606_Dicky_Ardiansyah_S.Pd_2026-08-06', 'dicky_bk', 'dicky_bk', 'guru', 'ss', '2026-08-06 23:31:17'),
(93, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-06', '1234', 'maulana', 'siswa', 'asd', '2026-08-06 23:31:35'),
(94, 'session_5606_Dicky_Ardiansyah_S.Pd_2026-08-06', 'dicky_bk', 'dicky_bk', 'guru', 'sda', '2026-08-06 23:31:38'),
(95, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-06', '1234', 'maulana', 'siswa', 'halo', '2026-08-06 23:32:32'),
(96, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-06', 'dicky_bk', 'dicky_bk', 'guru', 'halo juga', '2026-08-06 23:32:38'),
(97, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-06', '1234', 'maulana', 'siswa', 'pak', '2026-08-06 23:33:47'),
(98, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-06', 'dicky_bk', 'dicky_bk', 'guru', 'halo nak kenapa', '2026-08-06 23:33:54'),
(99, 'session_1234_Dicky_Ardiansyah_S.Pd_2026-08-06', '1234', 'maulana', 'siswa', 'anda keren pak', '2026-08-06 23:34:01'),
(100, 'session_5969_Dicky_Ardiansyah_S.Pd_2026-08-06', '5969', 'ABDUL AZIZ', 'siswa', 'halo pak', '2026-08-06 23:35:23'),
(101, 'session_5969_Dicky_Ardiansyah_S.Pd_2026-08-06', 'dicky_bk', 'dicky_bk', 'guru', 'halo nak', '2026-08-06 23:35:28'),
(102, 'session_5969_Dicky_Ardiansyah_S.Pd_2026-08-06', 'dicky_bk', 'dicky_bk', 'guru', 'bisa makan?', '2026-08-06 23:36:53'),
(103, 'session_5969_Dicky_Ardiansyah_S.Pd_2026-08-06', '5969', 'ABDUL AZIZ', 'siswa', 'kena hiv saya', '2026-08-06 23:36:58'),
(104, 'session_5973_Dicky_Ardiansyah_S.Pd_2026-08-07', '5973', 'ACHMAD NAWAF DANIEL HUDA', 'siswa', 'halo', '2026-08-07 09:12:06'),
(105, 'session_5973_Dicky_Ardiansyah_S.Pd_2026-08-07', 'dicky_bk', 'dicky_bk', 'guru', 'halo dek', '2026-08-07 09:12:13');

-- --------------------------------------------------------

--
-- Struktur dari tabel `informasi_bk`
--

CREATE TABLE `informasi_bk` (
  `id` int(11) NOT NULL,
  `judul` varchar(150) NOT NULL,
  `kategori` varchar(50) NOT NULL,
  `isi` text NOT NULL,
  `guru_bk` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `informasi_bk`
--

INSERT INTO `informasi_bk` (`id`, `judul`, `kategori`, `isi`, `guru_bk`, `created_at`, `updated_at`) VALUES
(1, 'beasiswa bidikmisi 2026', 'Beasiswa', 'Bagi pelajar SMA/SMK yang memiliki mimpi besar namun terkendala ekonomi, kata \"Bidikmisi\" memang sudah melegenda sebagai kunci pembuka gerbang kuliah gratis.\n\nNamun, ada satu info krusial yang WAJIB kamu tahu sebelum mulai mencari persyaratan: Program Bidikmisi secara resmi sudah tidak ada.\n\nEits, jangan panik dulu!\n\nSejak tahun 2020, pemerintah telah menyempurnakan dan mengganti nama program Bidikmisi menjadi KIP Kuliah Merdeka (Kartu Indonesia Pintar Kuliah).\n\nKabar baiknya? Transformasi ini justru membawa angin segar. Jika dulu uang saku Bidikmisi dipukul rata (dan seringkali pas-pasan), kini di KIP Kuliah, bantuan biaya hidup jauh lebih besar karena disesuaikan dengan klaster wilayah tempat kamu kuliah. Biaya pendidikan pun ditanggung penuh, bahkan untuk prodi Kedokteran sekalipun.\n\nJadi, meskipun namanya berubah, semangatnya tetap sama: Memutus mata rantai kemiskinan lewat pendidikan.\n\nBingung harus mulai dari mana? Di artikel ini, kita akan kupas tuntas syarat terbaru, cara mendaftar, dan strategi agar kamu lolos mendapatkan beasiswa pengganti Bidikmisi ini.', 'Dicky Ardiansyah S.Pd', '2026-08-01 16:54:28', '2026-08-01 16:54:28'),
(4, 'jadwal', 'Informasi Sekolah', 'senin : makan makan cihuy', 'Dicky Ardiansyah S.Pd', '2026-08-03 05:44:14', '2026-08-03 05:44:14'),
(5, 'perguruan tinggi', 'Pendaftaran Perguruan Tinggi', 'poliwangi buka kuliah 2027', 'Dicky Ardiansyah S.Pd', '2026-08-03 05:46:15', '2026-08-03 05:46:15');

-- --------------------------------------------------------

--
-- Struktur dari tabel `konseling`
--

CREATE TABLE `konseling` (
  `id` int(11) NOT NULL,
  `siswa_id` int(11) NOT NULL,
  `guru_bk` varchar(100) DEFAULT NULL,
  `tanggal` date DEFAULT NULL,
  `jam` time DEFAULT NULL,
  `jenis` varchar(20) DEFAULT NULL,
  `kategori` varchar(50) DEFAULT NULL,
  `deskripsi` text DEFAULT NULL,
  `kelas_siswa` varchar(20) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Proses',
  `status_konfirmasi` varchar(30) NOT NULL DEFAULT 'Belum Dikonfirmasi',
  `tanggal_konfirmasi` date DEFAULT NULL,
  `jam_konfirmasi` time DEFAULT NULL,
  `laporan` text DEFAULT NULL,
  `laporan_tanggal` date DEFAULT NULL,
  `laporan_waktu` time DEFAULT NULL,
  `laporan_dibuat_oleh` varchar(100) DEFAULT NULL,
  `laporan_kesimpulan` text DEFAULT NULL,
  `laporan_rekomendasi` text DEFAULT NULL,
  `laporan_status_penanganan` varchar(50) DEFAULT NULL,
  `laporan_catatan_tambahan` text DEFAULT NULL,
  `laporan_created_at` timestamp NULL DEFAULT NULL,
  `input_manual` tinyint(1) NOT NULL DEFAULT 0,
  `catatan_walkin` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `konseling`
--

INSERT INTO `konseling` (`id`, `siswa_id`, `guru_bk`, `tanggal`, `jam`, `jenis`, `kategori`, `deskripsi`, `kelas_siswa`, `status`, `status_konfirmasi`, `tanggal_konfirmasi`, `jam_konfirmasi`, `laporan`, `laporan_tanggal`, `laporan_waktu`, `laporan_dibuat_oleh`, `laporan_kesimpulan`, `laporan_rekomendasi`, `laporan_status_penanganan`, `laporan_catatan_tambahan`, `laporan_created_at`, `input_manual`, `catatan_walkin`, `created_at`) VALUES
(15, 12, 'Dicky Ardiansyah S.Pd', '2026-08-01', '15:00:00', 'Luring', 'Akademik', 'asddddddddddddddddddddddd', '10 IPA 1', 'Selesai', 'Terkonfirmasi', '2026-08-01', '15:00:00', NULL, '2026-08-03', '14:01:16', 'Dicky Ardiansyah S.Pd', 'mantap', 'sesi lanjutan', 'Monitoring', '-', '2026-08-03 07:01:16', 0, NULL, '2026-08-01 06:32:18'),
(16, 12, 'Dicky Ardiansyah S.Pd', '2026-08-04', '13:30:00', 'Luring', 'Keluarga', 'jadi saya ada permasalahan dengan orang tua saya sehingga menyebabkan untuk terhambat pergi ke sekolah', '10 IPA 1', 'Proses', 'Belum Dikonfirmasi', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2026-08-04 03:13:02'),
(17, 12, 'Dicky Ardiansyah S.Pd', '2026-08-05', '13:00:00', 'Daring', 'Akademik', 'jadi gini bu saya sudah bayar spp kemarin berhubungan bukti hilang jadi tidak ada yang percaya', '10 IPA 1', 'Proses', 'Terkonfirmasi', '2026-08-05', '13:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2026-08-05 06:55:32'),
(18, 833, 'Dicky Ardiansyah S.Pd', '2026-08-06', '15:00:00', 'Daring', 'Bullying', 'hallo pak jadi saya di bully pada saat kelas di mulai', 'XII - 8', 'Proses', 'Terkonfirmasi', '2026-08-06', '15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2026-08-06 02:27:32'),
(19, 12, 'Dicky Ardiansyah S.Pd', '2026-08-07', '07:00:00', 'Daring', 'Sosial', 'astaga ya allah aku anngis', '10 IPA 1', 'Proses', 'Terkonfirmasi', '2026-08-07', '07:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2026-08-06 23:32:03'),
(20, 12, 'Dicky Ardiansyah S.Pd', '2026-08-07', '15:00:00', 'Daring', 'Bullying', 'pakkk tolongggggggggggggggggggggggggggggg', '10 IPA 1', 'Proses', 'Terkonfirmasi', '2026-08-07', '15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2026-08-06 23:33:24'),
(21, 310, 'Dicky Ardiansyah S.Pd', '2026-08-07', '16:00:00', 'Daring', 'Keluarga', 'ada masalah sama keluara', 'XI - 2', 'Proses', 'Terkonfirmasi', '2026-08-07', '16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2026-08-06 23:35:01'),
(22, 310, 'Dicky Ardiansyah S.Pd', '2026-08-07', '14:00:00', 'Daring', 'Sosial', 'jadi ada masalah sosial untuk indonesia', 'XI - 2', 'Proses', 'Belum Dikonfirmasi', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2026-08-06 23:37:30'),
(23, 310, 'Dicky Ardiansyah S.Pd', '2026-08-07', '12:30:00', 'Daring', 'Bullying', 'saya di bully di pukul', 'XI - 2', 'Proses', 'Terkonfirmasi', '2026-08-07', '12:30:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2026-08-06 23:38:26'),
(24, 382, 'Dicky Ardiansyah S.Pd', '2026-08-07', '10:00:00', 'Daring', 'Akademik', 'kenapa saya di surh membayar ukt lagi', 'XI - 4', 'Proses', 'Terkonfirmasi', '2026-08-07', '10:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2026-08-07 02:09:24'),
(25, 382, 'Dicky Ardiansyah S.Pd', '2026-08-07', '16:00:00', 'Daring', 'Keluarga', 'saddddddddddddddddddddddddd', 'XI - 4', 'Proses', 'Belum Dikonfirmasi', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2026-08-07 02:10:48'),
(26, 558, 'Dicky Ardiansyah S.Pd', '2026-08-07', '17:00:00', 'Daring', 'Bullying', 'pak tolong pak tolong', 'XI - 9', 'Selesai', 'Terkonfirmasi', '2026-08-07', '17:00:00', NULL, '2026-08-07', '16:12:28', 'Dicky Ardiansyah S.Pd', 'mantep ini', 'bisa', 'Selesai - Masalah Teratasi', '-', '2026-08-07 09:12:28', 0, NULL, '2026-08-07 09:10:07');

-- --------------------------------------------------------

--
-- Struktur dari tabel `master_pelanggaran`
--

CREATE TABLE `master_pelanggaran` (
  `id` int(11) NOT NULL,
  `kategori` enum('Ringan','Sedang','Berat') NOT NULL,
  `jenis_pelanggaran` varchar(100) NOT NULL,
  `poin` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `master_pelanggaran`
--

INSERT INTO `master_pelanggaran` (`id`, `kategori`, `jenis_pelanggaran`, `poin`, `created_at`) VALUES
(1, 'Ringan', 'Terlambat masuk sekolah', 5, '2026-04-20 12:22:46'),
(2, 'Ringan', 'Tidak memakai atribut lengkap', 5, '2026-04-20 12:22:46'),
(3, 'Ringan', 'Rambut tidak sesuai aturan', 10, '2026-04-20 12:22:46'),
(4, 'Ringan', 'Tidak mengerjakan tugas', 10, '2026-04-20 12:22:46'),
(5, 'Ringan', 'Makan di kelas saat pelajaran', 5, '2026-04-20 12:22:46'),
(6, 'Sedang', 'Bolos 1 hari', 25, '2026-04-20 12:22:46'),
(7, 'Sedang', 'Berbicara kasar kepada teman', 30, '2026-04-20 12:22:46'),
(8, 'Sedang', 'Tidak mengikuti upacara tanpa alasan', 25, '2026-04-20 12:22:46'),
(9, 'Sedang', 'Membawa HP tanpa izin', 30, '2026-04-20 12:22:46'),
(10, 'Sedang', 'Mencontek saat ujian', 50, '2026-04-20 12:22:46'),
(11, 'Berat', 'Berkelahi', 75, '2026-04-20 12:22:46'),
(12, 'Berat', 'Merokok di lingkungan sekolah', 75, '2026-04-20 12:22:46'),
(13, 'Berat', 'Vandalisme (merusak fasilitas)', 75, '2026-04-20 12:22:46'),
(14, 'Berat', 'Bullying / perundungan', 100, '2026-04-20 12:22:46'),
(15, 'Berat', 'Membawa barang terlarang', 100, '2026-04-20 12:22:46'),
(16, 'Berat', 'Pelecehan seksual', 100, '2026-04-20 12:22:46'),
(17, 'Berat', 'Hamil diluar nikah', 100, '2026-04-20 12:22:46');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pelanggaran`
--

CREATE TABLE `pelanggaran` (
  `id` int(11) NOT NULL,
  `siswa_id` int(11) NOT NULL,
  `jenis_pelanggaran` varchar(100) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `poin` int(11) DEFAULT 1,
  `tanggal` timestamp NOT NULL DEFAULT current_timestamp(),
  `dicatat_oleh` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `rekap_pelanggaran`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `rekap_pelanggaran` (
`id` int(11)
,`nis` varchar(10)
,`nama` varchar(100)
,`kelas` varchar(20)
,`total_pelanggaran` bigint(21)
,`total_poin` decimal(32,0)
,`terakhir_pelanggaran` timestamp
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `rekap_pelanggaran_siswa`
--

CREATE TABLE `rekap_pelanggaran_siswa` (
  `id` int(11) NOT NULL,
  `siswa_nis` varchar(10) NOT NULL,
  `siswa_nama` varchar(100) NOT NULL,
  `siswa_kelas` varchar(20) NOT NULL,
  `total_poin` int(11) DEFAULT 0,
  `total_pelanggaran` int(11) DEFAULT 0,
  `level_pelanggaran` enum('Teguran','Pembinaan','Peringatan','Panggilan Orang Tua','Skorsing') DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `riwayat_kelas`
--

CREATE TABLE `riwayat_kelas` (
  `id` int(11) NOT NULL,
  `nis` varchar(20) NOT NULL,
  `tahun_ajaran` varchar(9) NOT NULL COMMENT 'Format: 2024/2025',
  `kelas` varchar(20) NOT NULL,
  `status` enum('aktif','arsip') DEFAULT 'aktif',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `riwayat_kelas`
--

INSERT INTO `riwayat_kelas` (`id`, `nis`, `tahun_ajaran`, `kelas`, `status`, `created_at`, `updated_at`) VALUES
(1, '4321', '2025/2026', '11 IPA 1', 'arsip', '2026-06-03 18:54:56', '2026-06-03 18:55:45'),
(2, '4321', '2026/2027', '12 IPA 1', 'aktif', '2026-06-03 18:55:45', '2026-06-03 18:55:45'),
(3, '6666', '2024/2025', '11 IPA 1', 'aktif', '2026-06-04 02:00:27', '2026-06-04 02:00:27');

-- --------------------------------------------------------

--
-- Struktur dari tabel `siswa`
--

CREATE TABLE `siswa` (
  `id` int(11) NOT NULL,
  `nis` varchar(10) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `kelas` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `jenis_kelamin` enum('Laki-laki','Perempuan') DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `no_telepon` varchar(15) DEFAULT NULL,
  `foto_profile` varchar(255) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `siswa`
--

INSERT INTO `siswa` (`id`, `nis`, `nama`, `kelas`, `password`, `created_at`, `jenis_kelamin`, `tanggal_lahir`, `alamat`, `no_telepon`, `foto_profile`, `updated_at`) VALUES
(12, '1234', 'maulana', '10 IPA 1', 'e10adc3949ba59abbe56e057f20f883e', '2026-07-26 04:48:50', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-26 04:48:50'),
(13, '0122381528', 'AFIKAH APRILIASARI', 'X - 2', '949fc19395b348218c2893f4aab74e27', '2026-07-28 01:33:59', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:33:59'),
(14, '0103766997', 'AHMAD RAFI TRI JUNICO', 'X - 2', 'e02c2bb61ea64e0c8be78d90f38a9b9f', '2026-07-28 01:33:59', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:33:59'),
(15, '0112895209', 'ALLINE KUSUMA WARDHANI', 'X - 2', 'c3582c020d7c43f16d342d20c8272e1e', '2026-07-28 01:33:59', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:33:59'),
(16, '0118773897', 'ANDIEN NINDITA MAHARANI', 'X - 2', '2050aab9e65d2b434db763e3b56263f9', '2026-07-28 01:33:59', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:33:59'),
(17, '0098012723', 'ARDANI FAHRI', 'X - 2', 'cbaf75f8a4e1447ff43f19c646795bbe', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(18, '0101895597', 'ARDITA RAHAYU', 'X - 2', '76d40c67a5f92a835812975d0da73582', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(19, '0112599180', 'AYU PUSPITA SARI', 'X - 2', '23c1e308e1356ec86e6ab3499f7ce597', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(20, '0109773181', 'BILQIS AZZAHRA', 'X - 2', '5b4589aaa82790b8ad780fe845a5fe45', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(21, '0103273307', 'CARINA AULIA MARETHA', 'X - 2', '667f21b371b165031bc2a292f9d02bab', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(22, '0103979057', 'CHOIRUL CHAESA RAMADHAN', 'X - 2', 'b9b741648ea101deb4b8cb057d82fa85', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(23, '0093250373', 'DIRGANZA AHMAD MAULANA', 'X - 2', 'd1d19aaa9de312cfed5cd22ad8a8551f', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(24, '0102537721', 'ERRA FAZIRA', 'X - 2', 'f19d7b24583776e20b51d7e62a68bcb2', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(25, '0109324990', 'FAZA ARMA CHOIRUL AZZAM', 'X - 2', 'afd898a2c1f1bbefe2dcd887342717fd', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(26, '0104716956', 'FLORETA DZAKIRAH SYAUQIYAH', 'X - 2', '7a056feced9a9f2c671301d27a62f613', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(27, '0111969316', 'ICHA MARTHALIA KHAINASHIRA', 'X - 2', 'd0a36524474387c65711e6a76f6798e5', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(28, '0104081178', 'JERY TRISTIYANTO', 'X - 2', '098a21ceb5c63bdac7e33c26116b5001', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(29, '0094742550', 'JULIA FARA IREND NATA', 'X - 2', '7e5bac949abaff3baa13d4ac34f87be4', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(30, '0102948914', 'KURNIA DUWI SAVITRI', 'X - 2', '6c0042ae01ad433eb7c42289eced83f6', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(31, '0106635454', 'MOHAMAD NIJAM LIYAN PRADITA', 'X - 2', '034056ae6fcb95580ced51032a1bb665', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(32, '0106508113', 'NADIN CAHYA RAMADHANY', 'X - 2', 'e9c0882d7cda78e3aaf3eec9d212b859', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(33, '0102441097', 'NAYLA PUSPITA DEWI', 'X - 2', 'f76dbd7268ba98caafd02279fa349dff', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(34, '0111612600', 'NIKEISHA ANINDITA BELYA PUTRI', 'X - 2', '422b391766cae3ff3b164e95420578c0', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(35, '0109130812', 'NUR HADI', 'X - 2', '1a0931e8bf9e1fac4c143b0a930cc1aa', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(36, '0103614130', 'RAFFAEL KENNATH ROSSI', 'X - 2', 'dbf71d5c48dcd97715ea3a123be045f3', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(37, '0104845292', 'REFFA LIVIANA PUTRI', 'X - 2', '30bf4ff7819340ad22b68f628c56a8a0', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(38, '0106286459', 'SAFIRA PUTRI CAHYANI', 'X - 2', 'c75bd7d83607f3532f6a8346fb66a0c8', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(39, '0102298204', 'SHIFA AGUSTIN', 'X - 2', 'eca545266926e91c649f115d7c3062c2', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(40, '3106929356', 'SYAFIKA NURUL ASKIA', 'X - 2', 'fec8bd16fb4887e43d17c989dee6e3ec', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(41, '0108134514', 'TAQIYAH SYIMA MAYSARAH', 'X - 2', '69f367bea45efa02f5328ee74d57a062', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(42, '0106124597', 'TIO KURNIAWAN', 'X - 2', '1670b2566dac4f860ec2f46a5f232bfd', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(43, '0108604862', 'VIRNA AURELYA HOSHI', 'X - 2', 'c1b025b2b528474d64f21db04c3b8f07', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(44, '3105479849', 'WILDAN IBNU BAITTURROHIM', 'X - 2', '05bf1df5da279f3ecb2f4d145da68452', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(45, '0113864175', 'ZASKIA FAKHIRA', 'X - 2', '9ea6497ec10cc44c3a305e148be8c588', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(46, '0119220304', 'AJENG ANGGRAINI PUSPANINGRUM', 'X - 3', '47a5749a0ba6464a52fd42deda94b1cd', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(47, '0105699394', 'AMALIA ZAHRO', 'X - 3', '145c763060a5765ff7e2d3932eb1153e', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(48, '0106611953', 'ANDIKA SYILA ARDIANSYAH', 'X - 3', '66b5621601f33925c9484c736d143df0', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(49, '0105445290', 'ANNISA KHUSNUL FATIMAH', 'X - 3', '91df822b82662730a1e76bf40071609f', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(50, '3102576348', 'ARKAN NAUFAL AL FATHIN SETIAWAN', 'X - 3', '17792a559597ff9b2851e4246d1063d8', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(51, '0112362234', 'AULIA KHOIRUNNISA', 'X - 3', '098f1240b035c5df19045418b316189f', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(52, '0106556248', 'BELLA DWI DARIYANTI', 'X - 3', 'b44116a893921387cd6224842fe7a0a8', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(53, '0103760297', 'BUNGA ANISSA ZAHRA', 'X - 3', 'e0c615da5bc05c78f077d5f2ff80afde', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(54, '0116570717', 'CHACA DEVANY AURA PUTRI', 'X - 3', '472a3e442cd370a1273b00ff83458e0e', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(55, '0102711617', 'DANIEL PRANANDA ALY AL FARABI', 'X - 3', '0666860cc27b387378af3c7ce6d75906', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(56, '0106736965', 'DZAKIRATUL FAIZAH', 'X - 3', '1f063aa409cf235ed28b99d06e15bce1', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(57, '0105968395', 'FAHAD AL BARRAA', 'X - 3', '5ac89eb4c5caf315b2778928ba58a184', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(58, '0106276446', 'FEBY APRILIA', 'X - 3', 'a3230e4c3ee1bb196ce77155fe421776', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(59, '0101859593', 'GALIH JOYORETNO', 'X - 3', 'e45006d83b0898ccfdb270c42f99ad79', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(60, '0102808572', 'HANI AFTONIA', 'X - 3', '8856ae3c6ea9bd60503355b1c97b5a9f', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(61, '0119197292', 'JUWITA MAYASARI', 'X - 3', '1dbb4ddecc1563b49301a4d650ac0155', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(62, '0115604903', 'KHOIRUS ZIDANE AL-FIRDAUS', 'X - 3', '1c1eeba5eb97f5747575207142364a5e', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(63, '0108998055', 'LAURA ARKANA SOFYAN', 'X - 3', 'beb8616d3c87040cdb72763290e39b07', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(64, '3107681313', 'MUHAMMAD JAVIER ALAND SYAH', 'X - 3', '2ede8f24b678be3acc5007350bcf00a0', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(65, '0106759857', 'NAJIHA FADHILATUN NISA', 'X - 3', '0a1888aa33f8629d7bd8853af92f271a', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(66, '0103032547', 'NEISYA MARLIANI ALVIRA', 'X - 3', '6eec207feca8c0ad2d6b8137c4dcccb5', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(67, '0106032890', 'OKKY ORUNVIANI', 'X - 3', '92e8f35bfe70998ce6b1d167c8bb4847', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(68, '0105201873', 'RADJA WAHYU FIRDAUS', 'X - 3', 'ba7b7dea1e1991e525a2745315d76a0b', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(69, '3108428834', 'RENNO REZNANDYA', 'X - 3', '43848f8dabe814c73d2802e281f41ae1', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(70, '0101146560', 'RIANTI DEA TRI AGUSTINA', 'X - 3', '2a0d18cdb12f65a36279036d4e8d98bb', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(71, '0103777021', 'SITIYANA AYUNINGTYAS', 'X - 3', '265643c158f436c1a50875a16060cf5b', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(72, '0107905251', 'SYAFIRA MURSID', 'X - 3', 'e86812e9c0f21b7359b8d873fb09c483', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(73, '0106611027', 'SYIFA RIZKIYA', 'X - 3', '6d9cc7ac3a15d7b6d0297190a83bc4b2', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(74, '0109404101', 'UMI BILQIS NABILA', 'X - 3', '0119565def6597b44a5afde1d62b089b', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(75, '0105357893', 'WENDI GALIH PRIYANTO', 'X - 3', '9cd18c5b49f11e399f5b88a4d3b26508', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(76, '0107507312', 'YALIKA ANA BELLA', 'X - 3', '38f111c436e1605f7005487c8ec21e41', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(77, '3105412342', 'ZIADATUL FARIHA', 'X - 3', 'e51fad1da892f90641b41d2bd9eb6982', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(78, '0104632260', 'AIDA FAIZA SHABIRA', 'X - 4', 'd333bfa1edafa9087142c6623bd34696', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(79, '0114787245', 'AMELIA ANGGRAENI', 'X - 4', '89ff4ed2f1949df9d600d4d7885b6d2d', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(80, '0119362590', 'ANISA CAHYA WARDANI', 'X - 4', '3a02a028daded01165d6ff187b83f69e', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(81, '0101117883', 'ATAYA FIKRI RIZQULLOH', 'X - 4', 'cb898b9f19b91a92a0f10ba977afab5b', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(82, '0117360254', 'AULIYA ALFI KHOMARIYAH', 'X - 4', 'b6595f0647dfbe8f4fb8d3d006883238', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(83, '0108722723', 'BERLIANA ROSALIN', 'X - 4', '55ecd4e73fc028e05056be965ffe8762', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(84, '0105477024', 'CINTA AGUSTIN SUCI RAMADHANI', 'X - 4', '1e7d40cbe1b59b09788c7f485606f071', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(85, '0105968485', 'DAVID JULIADI SYAH PUTRA', 'X - 4', 'daca15eee1de4600c3162392b0320291', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(86, '0116849654', 'ERLANGGA DWI PERMANA', 'X - 4', '06cf57c38b5e8a875d478f2d72108144', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(87, '0106969787', 'FANI JULIA AMANDA', 'X - 4', 'c219bb019831c3ba7834b53319cfd478', '2026-07-28 01:34:00', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(88, '3100516732', 'GAVIN SAKIMA LEYA AL FIRDAUS', 'X - 4', '82abead9d6aed78b53cec346b7d39981', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(89, '0108940631', 'GUMILANG ABIMANYU', 'X - 4', '324b014c8cce8752b5850bffb30651c1', '2026-07-28 01:34:00', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:00'),
(90, '0105565005', 'HELEN AURHA BERLIAN', 'X - 4', '33ac4b77fa6a075d2c84ee1fec0b07a7', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(91, '0108604478', 'HEYRU SISTYAWAN', 'X - 4', 'bf4d84ea6087082c0d561a3a2832321c', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(92, '0105839575', 'IRA PUTRI UTAMI', 'X - 4', '7fe5733e983371a1f5f8e3c4d14c04ed', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(93, '0104756347', 'LIDYA AGUSTINE', 'X - 4', '74aab18c9fe127d2406167c88a48307a', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(94, '0103346648', 'MASAYU MUSRIFA SABILILLAH', 'X - 4', 'd378be0db854d419c0eed7f08022a97b', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(95, '0104672118', 'MOHAMAD RIZQI RAFLIDIANSYAH', 'X - 4', '8d83816b85e28cad3afb6f7a48504920', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(96, '3118921614', 'MUH ABDY MUHTAROM', 'X - 4', '00be314f0d197b07719b9eb308eb17ad', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(97, '0101313243', 'NADIRA NABILA IHSAN PUTRI', 'X - 4', 'bed5fdcff3c69ce9bbd2b57ef06698bc', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(98, '0106791075', 'NATRA MEDINA SUGIANTO', 'X - 4', 'fa38358565ed036c30aa6e2eb9bf4a82', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(99, '0104461646', 'NINDY ARUMIZAHRA', 'X - 4', '9ad4002f2dfe325441fddbf5d9d6ee42', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(100, '0101569514', 'OCTAVIANA PUTRI LARASATI', 'X - 4', 'ebdc662c018ba2f02ba55589639fda62', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(101, '0105801734', 'RAFI FIRMANSYAH', 'X - 4', '30596ca6576011bf29179cf9ab4aaca6', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(102, '0108509396', 'REVAN ADITYA', 'X - 4', '1286499e4fdcd06a13ac778e263c019f', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(103, '0109589412', 'RIFI ANANDA PUTRI', 'X - 4', '2662ed263d3954cdfadf0343b881e84b', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(104, '0109850073', 'ROUDOTUL NURADILA', 'X - 4', '17f196a718e0e777fedc16e41776b22a', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(105, '0109351746', 'SAYYID AZKIYA TAUFIQ', 'X - 4', 'd0e017c306aec1377e6c4a99c9ac796a', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(106, '0106966298', 'SEILA ANGELINA', 'X - 4', '308db1af87ba3cbdcf5d50715129ddb7', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(107, '0104328530', 'SHERINA AULIA KASIH', 'X - 4', 'b51686eec944aa5cf7142ede6a56621c', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(108, '0101202869', 'SITI UMMI MAYSAROH', 'X - 4', 'ec76e36efec3f6817c48c3a07bf928d0', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(109, '0111061999', 'UFIA ADINATUZ ZAHIRO', 'X - 4', '69ffb1645c823f95d5379bb74af6e85b', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(110, '0102450720', 'ZAHIRAH NAZWA ARILOKA', 'X - 4', '1f577b291a11668bcd6d6b08f0571b25', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(111, '0107653996', 'ALEESYA NABILLA QISTHY RAMADANI', 'X - 5', 'f02830f4eb0fb304140d4ce55e066a6a', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(112, '0102129522', 'ANIRA EREN RAHMADINI', 'X - 5', '0a1a002b88ffd6b7fa0c35c2db3a63ec', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(113, '0118545506', 'ARBELA ANANDITA PUTRI', 'X - 5', 'bc289863d5909db8420336ed772960d6', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(114, '0102247904', 'AULIYA NAILAL HUSNA', 'X - 5', '7c9d3cc0a1689e8a0d3b6406d24cfecb', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(115, '0112737185', 'CAHAYA RAMAHDHANI', 'X - 5', 'fdb5e19d405836da41b32ee4d2709cab', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(116, '0109241466', 'CINTA WIDYA RANIM', 'X - 5', 'a185b8b06ca8eef906b99eb456ed1dd1', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(117, '0106812215', 'DANA AKSA MULYA NOVAL', 'X - 5', '82db867cd62f43b05660b79c99489ca6', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(118, '0118820953', 'DARA PUSPITA TRI ANINDYA', 'X - 5', '91b656aec92bb4ebebce7b1c09815835', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(119, '0105395608', 'DERBY MEI TRI CAHYO', 'X - 5', 'd960e90465244be9b9b31628d92de1b0', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(120, '3113189084', 'FATHUR RIDHO HAQIQI', 'X - 5', '0246cd188aa7e1a31e374bdaa53a2cff', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(121, '0102418611', 'FAYUMI ZIVANA TASYA', 'X - 5', 'ed5b92785147d0cbb39985ed57c40fbe', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(122, '3116006817', 'GIA ZIASKA MUHAMMAD SAMPURNO', 'X - 5', '26dbc06b1ce733349f28bf1435f34c65', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(123, '0111668286', 'HASTA KUSUMA', 'X - 5', '0a73806633ffcfffc42b2b8d760bceba', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(124, '0104584884', 'KEYLA SYAFIRA RAMADHINA', 'X - 5', '6842795d98fca11c587ad1e6fd2f2fac', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(125, '3116083420', 'LUTFIYANI', 'X - 5', '9e8669316676be9f0d73e6d0bdb98880', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(126, '3112041698', 'MOCH MARVEL WILYSANDY K', 'X - 5', '90a2b36c4d6085ebcf4cd798a026eac3', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(127, '0106878781', 'MOHFABIAN ANANDA', 'X - 5', 'eb027e381ad648a5db6b296328bef88a', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(128, '0102829863', 'MUHAMMAD ERWIN JULIANTO', 'X - 5', '13891600a2f1c686c7e3948b55d4e2eb', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(129, '0111055788', 'NADILLAH NUR AINI', 'X - 5', 'd2779175648b2a6593f0733307950da2', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(130, '0112212102', 'NAHZUA HILWA', 'X - 5', '705bb773a42a6705b62825c86f4f11b0', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(131, '3113174462', 'NAYLA SYIFA HASNAA', 'X - 5', 'c4958192376000a347003b989ee2b0f2', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(132, '0116525582', 'NURUL ISMIYA', 'X - 5', 'cda013c3cc08877c5354a9e7fde939bc', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(133, '0116165328', 'RARA APRILLIA PUTRI', 'X - 5', 'a8c5d5753f6f86c3331b77989bebee77', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(134, '0095506601', 'REFINDRA SATRIA KUSBIYANTO', 'X - 5', '495488bbd06acc4ae7bef06dc9548e6a', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(135, '0106799958', 'RINGGA ARDINATA PRATAMA', 'X - 5', '6d49b4f7891ee94009d847b0f9149f0f', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(136, '0115969244', 'RODHOTU HAQQI HAYIN', 'X - 5', '7495cf32a9a9b0febb59ec14f0b7196b', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(137, '0106392270', 'SHAFA MAULIDA ADHAWIYAH', 'X - 5', '05e23a1910fadb240bc5744487924480', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(138, '0106353240', 'SITI HAIRIRIN', 'X - 5', '37155c6f7a7aafabfecc661c982f3891', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(139, '3115094690', 'TIARA PUTRI AGUSTIN', 'X - 5', '4e7bc98f812cd50247e6986741451a68', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(140, '0108212167', 'VERA VERISMAYANI', 'X - 5', 'da6f7941580d3d39af954f8a2ebb901b', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(141, '0104722331', 'WINOTO RAMA SUGIARTO', 'X - 5', 'e39594db4f282beb3531143b8b19b93a', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(142, '0098427879', 'ZASKIA NURUL AMAL', 'X - 5', '1865a625a0a5e85808537f665c96fc5d', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(143, '0102389759', 'ZULFI KHAYANA RAHAYU', 'X - 5', '42a50ebc17a409fc4acd16ae73df62e9', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(144, '0103877514', 'ABURIZAL HAKIKI', 'X - 6', 'b8b51c1c9e2442a32590d05c1edf6431', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(145, '0107163088', 'ALDEVI NEYHILA ZILDHA', 'X - 6', '7d7ee64c7ef197df72de4326096f0c48', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(146, '0107890134', 'ANDRA SURYA ALAMSYAH', 'X - 6', '41b35e1544fe3b0c5cbaf13fee2824ad', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(147, '0111101699', 'AQILA ARMINTANA', 'X - 6', '4249393547783a3ef264712526bf6a8c', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(148, '0106268997', 'ASHWIN SISWANTO', 'X - 6', '09497871dfa71bd00e3906651dd8e489', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(149, '0101546836', 'ASYIFAH ALDINA WULANDARI', 'X - 6', 'f8c80165a26aa4184003122bb87f292a', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(150, '0108703855', 'AURELIA VIRASYA', 'X - 6', 'cba66accc4249d4b851e2132ac34ef2d', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(151, '0108061920', 'CINTA AURELLA MEYVIRRANDITA', 'X - 6', '0087b870bb4b415c5453d2968eaf740b', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(152, '0114306731', 'DEVINA MAYSYA PUTRI ALFIONITA ZUKNI', 'X - 6', '229d354bda3bc5ba91c97b23437b2fe1', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(153, '3109197714', 'DIELCO RAGAZAESPANA', 'X - 6', '59969596b0f1e9aeb57cbb7f5e44ea82', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(154, '0119826857', 'ELVIRA VIRNANDA', 'X - 6', '5027bbef8c0c3d64814704a60e33cb1c', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(155, '0101080058', 'FADHILAH NUR RAMADHANI', 'X - 6', '0148c53aad89c7dfc0188d39f8c91b3f', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(156, '0108819451', 'GALUH ETIKA SUHESTI', 'X - 6', '9667733e6a90bb7a22d8f36f760c6bd0', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(157, '0109216184', 'HABIBURRAHMAN AL ALY', 'X - 6', '1a56f30901f84bffb113c54d74e0b1e1', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(158, '0101210133', 'HIMAYATUL AMANAH DEWI', 'X - 6', '38f4b73968ee04a831598ab5b97d4944', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(159, '0103559012', 'IQBAL DWI SAPUTRA', 'X - 6', 'ff98fec8bace6125ca7f39943deb14bd', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(160, '0118654265', 'JEANE TALASSIA LOKA', 'X - 6', '04ec20029c04a8d9b321715e2974a5de', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(161, '0127117808', 'LILI KHOIRUNNISA', 'X - 6', '9bed480cf928a6b25e97cd8a857f6092', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(162, '0119861693', 'M KAFA RIZKY AINUN QOLBI', 'X - 6', '1b0790a4d4e84d26f13a6259e6367af6', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(163, '0103175819', 'MOHAMMAD RIONALDI ARJUNA N', 'X - 6', 'ec90353af9852a31ceee72d57b138e09', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(164, '0102756661', 'MUHAMAD NUR ABDILLAH', 'X - 6', 'dec20b78e68aec2ef248d1ce931ab319', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(165, '0104335794', 'MUHAMAD RAFKA RIZKY PRATAMA', 'X - 6', '2e09c33c81f96964bdbe58b1cf5225ba', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(166, '0101123532', 'MUHAMMAD RIZQY SURYANTO', 'X - 6', 'e1f853ae51950f0ef76eae6cec77de94', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(167, '0105350366', 'NADIN ALFULLAYLY', 'X - 6', '50bc81b4b7169bcff6e795bdbbb7519c', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(168, '0106693963', 'NATHAN MARCHEL PRATAMA', 'X - 6', '4a451a60405900fadce28dfde3c6d6b6', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(169, '0112650638', 'NIMAS RESTU YESLINNISA', 'X - 6', '76a0167e2b2440389a73fe1ff579456a', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(170, '0116834035', 'NIZAM TRY UBAIDILLAH', 'X - 6', 'df2b69ec8ae4871e4d27f6eea594d645', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(171, '0105877014', 'REGAN JAYA PRASETYA', 'X - 6', 'c4f852e25a28193b6d504991e0fa6b06', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(172, '0112535239', 'RISMA FIYONITA', 'X - 6', '1a16ff3aa50a9527c102a6f09dd96366', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(173, '3109963983', 'RISMA TRI OCTAVIA', 'X - 6', 'db02d56f364a57609547f79f45b8e0d9', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(174, '0102426732', 'SEPTIYA HARIYANI', 'X - 6', 'df616f18c01da5a5e7870f5745fc6483', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(175, '0113455456', 'VAYLERY FAYRENZIA ARKA DIFA', 'X - 6', '8a0671e2973fc1a494095617ae3b9552', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(176, '0119007150', 'YUDHA APRIL LEO RHEIVAN RIZKY PRATAMA', 'X - 6', '25f7ad7996e7382b2e5a7f36bfdc1a3a', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(177, '3106184786', 'AHMAD GHAZALY ALHAJAR', 'X - 7', '3ed071fbdba3944ba2bc1d350dee3ac0', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(178, '0113186756', 'ALUNA NAUFALIN FIKRIA RABBANI', 'X - 7', '296b1c2abd2af8f7ace04d8479c990a2', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(179, '0107830381', 'ANGGER RADITYA DWI PRASETYO', 'X - 7', 'bf40df88416a6843c76e048055d194e1', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(180, '0112334652', 'AQUILA VENYU ASQUEEN REIDA VALENTINA', 'X - 7', '7ea92959498ab61a254723e08fcb2494', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(181, '0102803212', 'AUREL KANAHAYA NAMIRA', 'X - 7', '5d19166456d20546878e0986d7f82a50', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(182, '0112581106', 'AZZKA ARBAIN ATAPUKAN', 'X - 7', '15d31da7712a4e2bd105cefb2ee66954', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(183, '0103642421', 'BHAKTI HARTITA MAHARANI', 'X - 7', '05e320383e458e96d22a859707ada796', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(184, '0108815211', 'DESI AYU ULANDARI', 'X - 7', '32b04589626947d22bc1cd9161d01c6b', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(185, '0116605218', 'DILLA JESIKA HERMAWATI', 'X - 7', 'd272334d895e5a25f086a3573c46fe44', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(186, '0109580162', 'ERLITA PUJI LESTARI', 'X - 7', 'e5562608ea03f934c99d4596608a6ff3', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(187, '0108127803', 'FAHRI ARDIYANSYAH', 'X - 7', 'd139f9c4b1570af39744033d1b61d1cc', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(188, '0109551843', 'FELICE KIRANA SANTOS', 'X - 7', '9619970d45c5272fda9777e6be687e62', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(189, '0104048326', 'GINA AYU LESTARI', 'X - 7', '21c23c8d3babe44e9379d703b1bda9f5', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(190, '0114638686', 'IHYA ILVA AULIA', 'X - 7', 'c843b81a73dc01effde5fbec5d6f59ed', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(191, '0108306838', 'IKHLASUL DWI RAHMAN', 'X - 7', 'e27852efe89be3ddd55c01a433c1d0c7', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(192, '0115534203', 'KESYA VIRGINIA HIDAYAT', 'X - 7', '90fa0d920b2ec6827eb3ef5ad4519005', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(193, '0095689884', 'LINDA ARISTA', 'X - 7', '04f421159f3c81357fc7fe7c4cd2eedd', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(194, '0104028867', 'M IKHSAN NUR FAUZI', 'X - 7', '9917fe1614a1c3b3f3d23a6946159be3', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(195, '0109995173', 'MOH BIRLY ATIQ', 'X - 7', 'ca0add1f5c0f41950ae0ee16efa297ac', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(196, '0115348202', 'MUHAMAD FAHRI AZAM', 'X - 7', 'f231c0ba4deae285d457b88b215a56cc', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(197, '0104837234', 'MUHAMAD RADHIATULLOH', 'X - 7', 'c73249bf930c25919fe873714b06ecb9', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(198, '0108227542', 'MUHAMAD WAHYU RIZKYANTO', 'X - 7', 'e964ef9f7d0057e812363758317f513d', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(199, '0107286032', 'NATALEAN QUEEZELLARAFEL', 'X - 7', '3b0e2978d674c735d7365a4595676d22', '2026-07-28 01:34:01', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(200, '0103632867', 'NAURA IFTINAH ATHA KAMAL', 'X - 7', '5a8512335aeb09f5cec4b264c74df416', '2026-07-28 01:34:01', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:01'),
(201, '0095845975', 'NAZA IDAM YANDIKA PUTRA', 'X - 7', '5c0acfb259687eecf1fda10c050c432e', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(202, '0105746109', 'OCTAFIYAND CAESA ARIYANA', 'X - 7', '681a8aec8856a1ab44be3041463b39a7', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(203, '0109087411', 'OKTAVIA AULIA SOLEHA', 'X - 7', '7f7cdf7b2705f1296f2157eca6df42c8', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(204, '0105258284', 'RISMA NUR AMIRA AZWARA', 'X - 7', '36a3e96acd7ec36646c6c1ec1931d49b', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(205, '0105977620', 'ROMEO PAKUSODEWO', 'X - 7', 'd473bd64f6a884fcaa840b1b29b65f9f', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(206, '0115084689', 'SASKYA AINIATUS SILFARA', 'X - 7', '5be1973397d7a85d7317c8a7269a618e', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(207, '0107602844', 'SYAKIRA', 'X - 7', '51a73f599b3eb2efc4cf29f5c9ae64a5', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(208, '0105442565', 'ZAHROH ANNISAA PUTRI', 'X - 7', 'fd1f3bfb43da9510165f18dd12cfbd6b', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(209, '0104265143', 'ZIVEN SYAFIQ', 'X - 7', '53ffe028ee55b568461e1004825d919d', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(210, '0101106378', 'ADIVA PUTRI SAMIRA', 'X - 8', '3e617677ce903f9b3ad83a9fc5538daf', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(211, '3098008481', 'AHMAD ZIDAN', 'X - 8', '1f414c32390e9f1b491064ab0c92ec5e', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(212, '0107866168', 'ANDIKA ARYAWIGUNA', 'X - 8', 'aff517eb9d7fbfdc73184b355a3a7030', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(213, '0108313935', 'ARIFATUL HAKIMAH', 'X - 8', '0554f649694472163ba3ca3cfdaf67ef', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(214, '0106122344', 'AURELIA KRISTIAN RAMADANI', 'X - 8', '57b2fd1fe7580140e4808579a7a6c177', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(215, '0113619919', 'AZKA ABIYASA RASTRA', 'X - 8', '8a247cd9f80dc32728d89287b4608024', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(216, '0105350662', 'DAVA ANGGARA', 'X - 8', '30b8ac112c8d58585dbc12db43380688', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(217, '0104209261', 'DESVITA AZYUROTUL MAZZIA', 'X - 8', 'a883f036f2c33d4bdddb70ba71818cb9', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(218, '0114934581', 'DIMAS HARDI PRASETYA', 'X - 8', 'cc0e9d7fb0e2acc707cd0f0d7172e979', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(219, '0112486201', 'DITA AINUN JAHIRA', 'X - 8', '8e52cdc97e3f3e6905d25722b466c925', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(220, '3115337747', 'FAJAR AULIA WIJAYA', 'X - 8', 'c595f7b48b01ea07b31495b966514860', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(221, '0105741337', 'FIRMANSYAH PUTRA KUSUMA', 'X - 8', 'cc9418bd84c934f713b4485f4b465eae', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(222, '0102402089', 'GISCHA MARETA FEBIOLA', 'X - 8', 'a93387928f91a223be15c64c4503c5b6', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(223, '0105738195', 'INOVA ADI PRAYOGA', 'X - 8', 'dcd57ee0345cd3d3e87932807515fe74', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(224, '0106271758', 'INTAN ROSIYANA VALENTIN', 'X - 8', 'b6a4bf1c483f90dc2a78e3f95af248f6', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(225, '3108399537', 'M ISMA ALY MAKI', 'X - 8', 'b1b1db10ab56c1bad786634105328fcc', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(226, '3116593699', 'MADA AKBAR GHANI', 'X - 8', '0a08f6c037e29d6f2e8137fc99428e48', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(227, '0107078692', 'MILA AMELIA', 'X - 8', '38e630c735af2e32fa92a2fff66493af', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(228, '0116887263', 'MOCH. AZZA AL FATHATI', 'X - 8', '5245280c6c4e2c01a50d8f1e9f1d755c', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(229, '0108912636', 'MOH. FARDHAN AFGHANI', 'X - 8', 'bc903989577819ebd06d3238e7da58a0', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(230, '3102392502', 'MOHAMMAD SOHIBUL FIRDAUS', 'X - 8', '92391b6c9c20990f5ded2e331784848b', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(231, '0106102902', 'MUHAMAD RAFA ARDIYANSYAH', 'X - 8', 'f0f80f3919254c6c4df03739d0c6427a', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(232, '0108335752', 'MUHAMMAD AZKA ALVIYANTO', 'X - 8', 'db4075e4f55171348941cebd73840e98', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(233, '0104397566', 'NATALEON QUEEZELLAFAREL', 'X - 8', '1bda113f4657d206241f26ccabe4f80b', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(234, '0109609714', 'NAZWA KHOLISATUL MASRUROH', 'X - 8', '04cbd65cb433e06af1086074c511b4e2', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(235, '0104667988', 'RINDU DIANNITA MASRUROH', 'X - 8', '5a47273347e4087f4c077b10184c7a84', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(236, '0114968963', 'SINDI AMELIA PUTRI', 'X - 8', 'f10e93a8938203caf1657b3e4c1d8aff', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(237, '0118055621', 'SYAFA SALSABILA ROSA', 'X - 8', 'abab963fc0ddd2678dbc64f84a2819a7', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(238, '0102316221', 'TRI VIRTA ANGGRAINI', 'X - 8', '3e0aa8ed6a4b871c184622435f90457c', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(239, '0104041025', 'YOGA PRATAMA', 'X - 8', '9a5cce06d0b6f203fa4c535b8a4d37a1', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(240, '0102494476', 'ZAMZAM PUTRA MADIKA', 'X - 8', '38fe9094b047e4eca4bdc8aee273dd19', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(241, '0102288804', 'ZIVARA QUROTUN NADA', 'X - 8', '4ac129a9bab95a8f86fd4d123d179f25', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(242, '0101079112', 'ALFATH ARYOGA PRATAMA', 'X - 9', '042c6dcb678f5345ea5effeba87b18a6', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(243, '0101136920', 'AMIRAH JIHAN KHALISHAH', 'X - 9', '70f808331f7bc635aa5ba4b21e345412', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(244, '0104370579', 'ARUM BUMI PARI', 'X - 9', '2bc919ab97f86931c1e1e1c3fb0244a4', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(245, '0108444553', 'ASSYIFA NASYWA CHAIRUNNISA', 'X - 9', '05044e6d3a18a86512977772dd911fd6', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(246, '0106239691', 'AYU SETYAWATI', 'X - 9', 'f3e7107ec0e603c3ba6383e8e7deb205', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(247, '3117155493', 'AZKA YUDA PRATAMA', 'X - 9', 'db3ae5dc71d873cda9b618e2d9e1c0be', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(248, '3111661788', 'DEDE RISKI ARSAVIN MAULANA', 'X - 9', '1344902ed4de2048bd4b55bdad72dec6', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(249, '0103557640', 'DENI KURNIAWAN', 'X - 9', 'b48b7c864b70d051337100e0bd146150', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(250, '0103292793', 'DEWI MEILINA PRATIWI', 'X - 9', 'e9ea67c985f3573c7929bf1e907acef4', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(251, '0128780464', 'EGA NIZAMSYAH ALFARIZI', 'X - 9', '3a625c00d32c7923c196f4c3dd53a94f', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(252, '3105710502', 'FEBRIAN MUCH NAZRIL QOLBY', 'X - 9', '6874660a93309ac1943ea413130af2de', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(253, '0104329299', 'I KD DWI ARYA JAGADITA ASTUNGKARA', 'X - 9', '8029f214f9806a343ce18235c4c49a09', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(254, '0106561400', 'INGGRID PRESILIA AGATA', 'X - 9', 'be5dab46a23a61b1c84624f2c89f8e0d', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(255, '0119657170', 'KARUNIA LAILATUL FATIMAH', 'X - 9', 'b9ac93966c5f1267ba10f4f4f7ea5123', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(256, '0105297027', 'KHOIRUL ROFIU EFENDI', 'X - 9', '39347d65cc99e93957976f7c6b2b10db', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(257, '0108287677', 'M RAJDA MAULANA FIRDAUS', 'X - 9', '7fdce9312bc2f2bc70d43f2f7d299661', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(258, '0109135259', 'MOCH RIZKY ANDIKA PRASETYO', 'X - 9', 'ccb618eb75836db494359b1b37a7f98a', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(259, '3095306033', 'MOH IWAN NUDIN', 'X - 9', '3195a16da3196a5c4bfbb67eeece17c0', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(260, '0105936407', 'MOHAMMAD DIAN FAHMI AL FIANSYAH', 'X - 9', 'e61a46f857849dd0c95486213341f3df', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(261, '0105709807', 'MOHHILMI YONO', 'X - 9', '86ab510aab390aa406f4dfff08d7efd8', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(262, '0109578964', 'MUHAMAD SOLEH', 'X - 9', '6854f63532548fff7617bc5d4561d7a2', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(263, '0119825541', 'NABILA MAULIDATUL AZIZAH', 'X - 9', '8a5d42df49097bda240cf6783d77bf9a', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(264, '0101356735', 'NAUFAL HANIF ASWAJA', 'X - 9', '842860b9cb234e97ab18b4a57b232d73', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(265, '0107809967', 'NAURA CALISTA WARDANA', 'X - 9', '60d8cad62fde50f84e80486147a3634e', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(266, '0107560328', 'NUR AZIZAH', 'X - 9', 'f5c02637715c18c6b27d406817051336', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(267, '0108654654', 'RAYHAN ZIDNI', 'X - 9', 'ab0428d2c1383e56df20760023c9f7c9', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(268, '0106367229', 'REYHAN RAMADANI', 'X - 9', '2b4b2107c661a5c7ef28c447d7687167', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(269, '3102699746', 'SERIL MONICA RAMADHANI', 'X - 9', 'f41984bcfbb45b9eef0ec30494114490', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(270, '0119449212', 'SYAFIRA DEA AYU PUTRI', 'X - 9', '05c455bf6ed8899815b5aa48aad41f7c', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(271, '3102827450', 'SYARQIATUS SABRINA', 'X - 9', '57d66dc22ab2bb362e0f005e3f71b9c7', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(272, '0108584217', 'VIRLA AURELYA HOSHI', 'X - 9', 'd6327114970941a7ae5520a4dc74aeeb', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(273, '0114036505', 'YUDA MUZIZAT JUNIARTA', 'X - 9', 'b3b9dce0647454642bb47ebe93425df9', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(274, '5975', 'ADELIA PUTRI KALISTA', 'XI - 1', '32cfdce9631d8c7906e8e9d6e68b514b', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(275, '5976', 'ADELIA SALSABELA PUTRI', 'XI - 1', 'e10534dd65cf727692c0f9c44ba613f8', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(276, '5983', 'AGNESI RADHIA NALA', 'XI - 1', '0cb82dbdcda47e2ad7b7aaf69573906e', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(277, '5998', 'ALIEF TIRTA MANDALA ENSE', 'XI - 1', 'b98a3773ecf715751d3cf0fb6dcba424', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(278, '6010', 'ANGGUN JUANITA LESTARI', 'XI - 1', 'c4c455df3c54f292ae22f6791fd2553e', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(279, '6023', 'AS ZHARA SASKIYA IMTIYAS', 'XI - 1', '3ba9af181751761d3b387f74ded2d783', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(280, '6030', 'AURIL RIMA CAHYANI', 'XI - 1', '3a24b25a7b092a252166a1641ae953e7', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(281, '6033', 'AZKA AULIA AZZAHRA', 'XI - 1', '317d17f10845da500bcf49780b7f35bf', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(282, '6051', 'CLARA ZUKHRUF ANNISA', 'XI - 1', '1d0932d7f57ce74d9d9931a2c6db8a06', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(283, '6057', 'DESPITA LENI ANTIKA PUTRI', 'XI - 1', '177db6acfe388526a4c7bff88e1feb15', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(284, '6064', 'DIANDRA OLIVIA ANNABEL PRASETYO', 'XI - 1', 'fb5c2bc1aa847f387022607d16adc510', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(285, '6092', 'FERLYZA WIDYA SAFITRI', 'XI - 1', '265c2b6a26807154013753637b68d01d', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(286, '6110', 'HARIEL RADITYA PUTRA', 'XI - 1', '5460b9ea1986ec386cb64df22dff37be', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(287, '6116', 'HESA RAHMATTULLAH GUNAWAN', 'XI - 1', '082a8bbf2c357c09f26675f9cf5bcba3', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(288, '6117', 'IKA RAMADHINA ARLIZA PUTRI', 'XI - 1', '84e2d85ac232c681a641da1ec663888c', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(289, '6134', 'KEISYA DWI NURINDA YUSUF', 'XI - 1', '1ca5c750a30312d1919ae6a4d636dcc4', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(290, '6163', 'MILA AISYAH ANUGERAH. M', 'XI - 1', 'a6e4f250fb5c56aaf215a236c64e5b0a', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(291, '6164', 'MOCH. RHASYA', 'XI - 1', '2d5951d1e3b31dfb7fd2dcc172df17fd', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(292, '6180', 'MUHAMMAD IRFAN ANAS EL-SIRAJI', 'XI - 1', 'dffa23e3f38973de8a5a2bce627e261b', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(293, '6188', 'NABILA KHOIRONISA', 'XI - 1', '30893a5eb454815e3bf4a3406b1b80c0', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(294, '6193', 'NANA SYAFIRA MUHTAR', 'XI - 1', '24bfde45b5790f04b1d096565157f6a4', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(295, '6224', 'QUEENIDZA NADJLA IGY', 'XI - 1', '69783ee76a92567d446143b811519068', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(296, '6229', 'RADEN MUHAMMAD NAFI ARSYA ZAHVA MAULANA', 'XI - 1', 'bce9abf229ffd7e570818476ee5d7dde', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(297, '6231', 'RADITYA RIZQY ANANDA', 'XI - 1', '0a17ad0fa0870b05f172deeb05efef8e', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(298, '6235', 'RAISSA CANTIKA WIDIYANTI', 'XI - 1', 'c5c64c10cfd77b16a03aa81f09499f25', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(299, '6238', 'RARA VEBRI ANGGRANI', 'XI - 1', '1fc30b9d4319760b04fab735fbfed9a9', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(300, '6240', 'RENO', 'XI - 1', '405075699f065e43581f27d67bb68478', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(301, '6241', 'REZA ARDIANSYAH', 'XI - 1', '154f596a0e4aec4cf23ee4b76ae3d34a', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(302, '6246', 'RIMA ANANTA', 'XI - 1', '0801a457294fafbd8fe3116176252636', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(303, '6253', 'SALSA DELFIA RAHMADHANI', 'XI - 1', 'b691334ccf10d4ab144d672f7783c8a3', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(304, '6266', 'SHOFIYATUL MILADIYAH', 'XI - 1', 'f0f254331b4693742ea6cc1379b84e73', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02');
INSERT INTO `siswa` (`id`, `nis`, `nama`, `kelas`, `password`, `created_at`, `jenis_kelamin`, `tanggal_lahir`, `alamat`, `no_telepon`, `foto_profile`, `updated_at`) VALUES
(305, '6268', 'SIGRA ASWANGGA KASUBUTAMA', 'XI - 1', '33235e3d066bad95b6eea457826f7507', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(306, '6275', 'SYAFIRA ARDANA PUTRI', 'XI - 1', '22c432f46fd86e1be5bc4429282eb65d', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(307, '6303', 'VIO VALENTINA SAFITRI', 'XI - 1', '141661fa46b11782745bb974d5140004', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(308, '6294', 'YOGI MAHARDIKA RAMADHAN', 'XI - 1', 'd8ad9beba48de682e6accacba8cdbe2d', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(309, '6300', 'ZHAECA ADELIYA PINOT', 'XI - 1', '42d02bd0c73cb27e4ffc7862910ea1f4', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(310, '5969', 'ABDUL AZIZ', 'XI - 2', '631e9c01c190fc1515b9fe3865abbb15', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(311, '5981', 'AERITH AMALINA SURYA', 'XI - 2', 'abb9d15b3293a96a3ea116867b2b16d5', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(312, '5982', 'AGHIEL BINTANG FAHLEVI', 'XI - 2', 'c23497bd62a8f8a0981fdc9cbd3c30d9', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(313, '6014', 'ANISA\'UL HASANAH', 'XI - 2', '3f68928ec5b6fae14708854b8fd0cf08', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(314, '6025', 'AULIA MUFIDAH', 'XI - 2', '5eed6c6e569d984796ebca9c1169451e', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(315, '6031', 'AVIDA EKA PERMADANI', 'XI - 2', 'b56ea7b6aa77f6f9008bc9362fab3597', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(316, '6045', 'CHELSA KHALILA PUTRI INDRAYANA', 'XI - 2', 'f449d27f42a9b2a25b247ac15989090f', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(317, '6046', 'CHELSEA REYDHA MANGGALA', 'XI - 2', '73a427badebe0e32caa2e1fc7530b7f3', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(318, '6055', 'DENISSA NUR LIASARI', 'XI - 2', '5cd7edbe7a1a668fdc63c138002cc43a', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(319, '6060', 'DHEA PUSPITA SARI', 'XI - 2', 'ba347fcc9a79fb74e95670b24848164f', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(320, '6062', 'DIAH AYU RAMADHANI', 'XI - 2', '09ccf3183d9e90e5ae1f425d5f9b2c00', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(321, '6079', 'ERRINA DANDARA MERAM', 'XI - 2', 'b1b20d09041289e6c3fbb81850c5da54', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(322, '6080', 'EVIKA KHAERANI PUTRI', 'XI - 2', '940392f5f32a7ade1cc201767cf83e31', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(323, '6082', 'FAHRI ABDILLAH', 'XI - 2', 'a6e38981ecdd65fe9dcdfcd8d1f58f05', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(324, '6089', 'FEBBY PUTRI PRIYANKASARI', 'XI - 2', '3bd318565e4adbe5f4b6abf2ffebf3a0', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(325, '6091', 'FERI KURNIAWAN', 'XI - 2', 'a4e858c15255e55d5e1e221bd151154f', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(326, '6099', 'GABRIEL ALINSKY', 'XI - 2', '80c0e8c4457441901351e4abbcf8c75c', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(327, '6120', 'IMELDA CAHAYANING RIZTA', 'XI - 2', 'cfa258af990f9cb188d36ddb5c6eb650', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(328, '6123', 'INGE VANESA TATA ARTIKA', 'XI - 2', '4ca82b2a861f70cd15d83085b000dbde', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(329, '6141', 'KHOIRUNNISA ISNI FATIMAH', 'XI - 2', '13d2b7361a27dbc9960ae158598a6a96', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(330, '6145', 'LATYFFATUN NISSA\'', 'XI - 2', 'd785bf9067f8af9e078b93cf26de2b54', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(331, '6151', 'LUTFI MAULIDIYAH', 'XI - 2', '761b42cfff120aac30045f7a110d0256', '2026-07-28 01:34:02', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(332, '6159', 'MEI DWI PRASETYO', 'XI - 2', 'ac1ae6a547bf25a11284c7595eff6df7', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(333, '6185', 'MUHAMMAD YUHAN DZIKRI AZIZI', 'XI - 2', '22eda830d1051274a2581d6466c06e6c', '2026-07-28 01:34:02', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:02'),
(334, '6194', 'NATANIEL AGATHA', 'XI - 2', 'af5baf594e9197b43c9f26f17b205e5b', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(335, '6197', 'NEYSA DWI FEBRIYANTI', 'XI - 2', '64ff7983a47d331b13a81156e2f4d29d', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(336, '6208', 'NURINDIRA KEILANI', 'XI - 2', '69dd2eff9b6a421d5ce262b093bdab23', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(337, '6210', 'OCTA AYU WARDANI', 'XI - 2', 'e564618b1a0f9a0e5b043f63d43fc065', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(338, '6252', 'SABI ICHISMI', 'XI - 2', 'fe74074593f21197b7b7be3c08678616', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(339, '6256', 'SASKIA ILMIATUS SHOLEHA', 'XI - 2', 'a87c11b9100c608b7f8e98cfa316ff7b', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(340, '6257', 'SAVA YATI NURHAYATI', 'XI - 2', 'd4cd91e80f36f8f3103617ded9128560', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(341, '6277', 'SYAQILLA SIFFA EKA ZAFITRI', 'XI - 2', 'e1f4fd6d0118b7b0797d7c1a0007b80a', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(342, '6293', 'YEGA MAULANA SAHDA', 'XI - 2', '1f87a3f9a9053ffc7ebfb8b779b010f7', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(343, '6298', 'ZAZQIRANA USMANOVA', 'XI - 2', '3487596cf54cb393afddaa965714ab1f', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(344, '6299', 'ZEYRA ZALFA NAIRANI', 'XI - 2', 'ff0abbcc0227c9124a804b084d161a2d', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(345, '6306', 'FAREL ARYASKA PUTRA NOVSELINO', 'XI - 2', '958ad0d05d3259750be0b041d10adbb1', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(346, '5978', 'ADINDA AGUSTI NINGTIAS', 'XI - 3', 'e5ae7b1f180083e8a49e55e4d488bbec', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(347, '5985', 'AHMAD EGA PRANEGALA', 'XI - 3', 'fccc64972a9468a11f125cadb090e89e', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(348, '5995', 'AJI NAUFAL PRABOWO', 'XI - 3', 'fcd4c889d516a54d5371f00e3fdd70dc', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(349, '6002', 'ALMEYRHA SAGITA ISLAMI PUTRI', 'XI - 3', '4b01078e96f65f2ad6573ce6fecc944d', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(350, '6017', 'ARFI ANDINA SIVIANY', 'XI - 3', 'fef6f971605336724b5e6c0c12dc2534', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(351, '6027', 'AULINDA AYU WULANDARI', 'XI - 3', '30f48cd3c7e73511070b95ee0a884c23', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(352, '6040', 'CAHAYA ANDIN NOVARIDA', 'XI - 3', '4c9d1fbce4890fc2731b6a61262313b1', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(353, '6056', 'DESITA AYU ROFIQOH', 'XI - 3', 'ee1abc6b5f7c6acb34ad076b05d40815', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(354, '6067', 'DINI RAMADHANI', 'XI - 3', '024d2d699e6c1a82c9ba986386f4d824', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(355, '6069', 'DISTA NUR ANGGRAININGSIH', 'XI - 3', '55312eec654a75a08dc83de96adde735', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(356, '6073', 'ELIZA TRI YANTI', 'XI - 3', '6c442e0e996fa84f344a14927703a8c1', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(357, '6094', 'FIERA ZAHRA RIZKIANI', 'XI - 3', 'ce5193a069bea027a60e06c57a106eb6', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(358, '6106', 'HABIB ZABIL MAULANA', 'XI - 3', '6933b5648c59d618bbb30986c84080fe', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(359, '6114', 'HENDRA ALFIANSYAH', 'XI - 3', '75c58d36157505a600e0695ed0b3a22d', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(360, '6124', 'INTAN NUR AINI', 'XI - 3', 'b16e8712b35e498857df08af3944b127', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(361, '6143', 'LAILY MAULIDINA', 'XI - 3', 'de9621d4c6fa69ce8aaa90f00e9110c5', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(362, '6152', 'M. PATRIALIS AKBAR', 'XI - 3', '92ae5cfef57d9ef9a523753e45fc9b0b', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(363, '6154', 'MAHARANI PUTRIANTI', 'XI - 3', '3bf07985bf8a5a37fcf65989269e8edc', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(364, '6158', 'MAYZHA ARDINATUS ZAHRA', 'XI - 3', '08ad21c6f9da6bdf51ae0b971f43d96d', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(365, '6162', 'MEYCINDA REFINA FERISCA PUTRI', 'XI - 3', '6aaba9a124857622930ca4e50f5afed2', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(366, '6172', 'MOHAMMAD FAHMI TRI HANSYAH', 'XI - 3', 'c5ef831f5d34faafc22a23a602cf6e40', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(367, '6174', 'MOHAMMAD SHEVA ROBINUR PUTRA', 'XI - 3', '65b0df23fd2d449ae1e4b2d27151d73b', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(368, '6186', 'MUHAMMAD ZIDNI FAHMI', 'XI - 3', 'fb3deea8bff8902a6a092a4b532b4a68', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(369, '6199', 'NIKITA SISKIA PURNAMASARI', 'XI - 3', 'c2f599841f21aaefeeabd2a60ef7bfe8', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(370, '6219', 'PRITA DIARA APRILLY', 'XI - 3', '852c296dfa59522f563aef29d8d0adf6', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(371, '6221', 'PUTRI DECHIMA SHIDQI HAZIZA', 'XI - 3', 'abd987257ff0eddc2bc6602538cb3c43', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(372, '6225', 'QUEENSHA CLAUDINA RAHMADANI', 'XI - 3', '9a0684d9dad4967ddd09594511de2c52', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(373, '6226', 'QUIINSA AQILA PUTRI', 'XI - 3', 'adfe565bb7839b83ea8812e860d73c79', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(374, '6247', 'RINES DIFA SEPTYASARI', 'XI - 3', '2e3ae207832305b6a0bff2dbc8a18b90', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(375, '6255', 'SANDRA AULIA NURHAYATI', 'XI - 3', 'eeea8c180c5dff16f68a6b7e2606b430', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(376, '6260', 'SELVIOLA ROSSA ANDITA', 'XI - 3', '091bc5440296cc0e41dd60ce22fbaf88', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(377, '6261', 'SENANDUNG NACITHA LATIF', 'XI - 3', 'aff82e881075d9c1ec306f86ae15c833', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(378, '6271', 'SITI NAJWA MIRZA MAYLANI', 'XI - 3', 'a1b63b36ba67b15d2f47da55cdb8018d', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(379, '6272', 'SITI NUR ANDINI', 'XI - 3', '146389f11f0e76cbc28ca267a34353a7', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(380, '6280', 'TIARA DEVI LESTARI', 'XI - 3', '9b10a919ddeb07e103dc05ff523afe38', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(381, '6287', 'VINNA MAWADDAH', 'XI - 3', '57827ddd068a17ad6dfc6690962241e5', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(382, '5971', 'ABIM ALAIKA AL FATIH', 'XI - 4', '73983c01982794632e0270cd0006d407', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(383, '5974', 'ADAM RIZKI PRATAMA', 'XI - 4', '7e1cacfb27da22fb243ff2debf4443a0', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(384, '5980', 'ADRIAN TEGAR LIL FIRDAUS', 'XI - 4', '63dfdeb1ff9ff09ecc3f05d2d7221ffa', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(385, '5993', 'AISYAH ILVANIA ARTALITA', 'XI - 4', '32e0bd1497aa43e02a42f47d9d6515ad', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(386, '6005', 'AMEL ANJELINA', 'XI - 4', '50c1f44e426560f3f2cdcb3e19e39903', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(387, '6018', 'ARIFATUL ULFA', 'XI - 4', '8d2a5f7d4afa5d0530789d3066945330', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(388, '6304', 'ATHA REIGA DANARTA KHOSYI', 'XI - 4', 'ccf0304d099baecfbe7ff6844e1f6d91', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(389, '6048', 'CINDY APRILIA', 'XI - 4', '6646b06b90bd13dabc11ddba01270d23', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(390, '6061', 'DHEA ROHMITUL ZAHRA', 'XI - 4', 'a775361d1fd47a9823a91aabf2a28a35', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(391, '6063', 'DIANDRA JULIA GACHELA', 'XI - 4', 'ae2a2db40a12ec0131d48acc1218d2ef', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(392, '6066', 'DIMAS MA\'ROEF HIDAYATULLOH', 'XI - 4', '2be5f9c2e3620eb73c2972d7552b6cb5', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(393, '6075', 'EREN RIFA RISTA', 'XI - 4', '4a3fd911279cd8bc597fa13222ef83be', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(394, '6083', 'FAHRIZ RAGIL SETYAWAN', 'XI - 4', 'add5efc3f8de35d6208dc6fc154b59d3', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(395, '6103', 'GESANG TAN KINAYA', 'XI - 4', '56880339cfb8fe04c2d17c6160d0512f', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(396, '6107', 'HADI ILZAM MUBARAK', 'XI - 4', '29586cb449c90e249f1f09a0a4ee245a', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(397, '6119', 'IMANUL HAKIM', 'XI - 4', '7bb7a62681a8a0f94ab424b06d172ca3', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(398, '6126', 'ISKANDAR PAHLEVI', 'XI - 4', '421740375847b6249d9383615831c23b', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(399, '6130', 'JULFIKAR', 'XI - 4', '7b99efbc101a6013d2c710028bca5cbf', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(400, '6133', 'KARINA SATYA MAHADEWI', 'XI - 4', 'c5df4f4eabf1cbcfeb50fbbf97c5289f', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(401, '6137', 'KEYLA FARA AULIA', 'XI - 4', 'b8c8c63d4b8856c7872b225e53a6656c', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(402, '6142', 'KHUMAIROH MAULIDAH', 'XI - 4', '7d4ba7006351436c35e283b0be8ff56c', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(403, '6144', 'LANY ORDYANA CHINTIA SAPUTRI', 'XI - 4', '197f76fe309657064dbec74d9eea4be4', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(404, '6147', 'LIRIS PUTRI JELITA', 'XI - 4', '310614fca8fb8e5491295336298c340f', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(405, '6160', 'MEI RIZKY ADITYA', 'XI - 4', 'fa3060edb66e6ff4507886f9912e1ab9', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(406, '6201', 'NILA MAGFIROH', 'XI - 4', 'e0cd3f16f9e883ca91c2a4c24f47b3d9', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(407, '6206', 'NOVITA SYAFIRA', 'XI - 4', '1b84c4cee2b8b3d823b30e2d604b1878', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(408, '6215', 'PATRA PUNDI WINDANU', 'XI - 4', '913eb3f7a1d5e28b3f30b2dda4f5569e', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(409, '6236', 'RAMADHANA WAHYU EKA MAULANA', 'XI - 4', '1fdc0ee9d95c71d73df82ac8f0721459', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(410, '6239', 'REGAN IRSYAD AL-AQLI', 'XI - 4', '4a5cfa9281924139db466a8a19291aff', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(411, '6251', 'RIZKYNA NAOMYRA HANUM', 'XI - 4', '9ac1382fd8fc4b631594aa135d16ad75', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(412, '6254', 'SALSA OKTAVYANI', 'XI - 4', '8617f303dd11780c5d48aedf0bd90823', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(413, '6259', 'SELLY PUTRI AGUSTIN', 'XI - 4', '99503bdd3c5a4c4671ada72d6fd81433', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(414, '6285', 'ULFA MARIA AZZAHRA', 'XI - 4', 'b7ae8fecf15b8b6c3c69eceae636d203', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(415, '6307', 'CHENITA VIDELLA AULYA WULANDARHY', 'XI - 4', 'e3bc4e7f243ebc05d66a0568a3331966', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(416, '5977', 'ADHIETYA PUTRA PRATAMA', 'XI - 5', '7eb532aef980c36170c0b4426f082b87', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(417, '5984', 'AHMAD DANY', 'XI - 5', '7f2cba89a7116c7c6b0a769572d5fad9', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(418, '6004', 'ALVIN SETIAWAN', 'XI - 5', '636efd4f9aeb5781e9ea815cdd633e52', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(419, '6011', 'ANGGUN PUTRI ALVIRA HASYIM', 'XI - 5', 'e3b80d30a727c738f3cff0941f6bc55a', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(420, '6024', 'AULIA DWI MAHARANI', 'XI - 5', '3bd8fdb090f1f5eb66a00c84dbc5ad51', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(421, '6037', 'BINTANG PRATAMA', 'XI - 5', '8b2a9c176d358811a479f771a5874c1b', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(422, '6042', 'CHAERAL AFDAN SYAKURO', 'XI - 5', '838aac83e00e8c5ca0f839c96d6cb3be', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(423, '6047', 'CHINDY NABILA APRILIANI', 'XI - 5', '98baeb82b676b662e12a7af8ad9212f6', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(424, '6050', 'CITRA ANGGUN NOVIANTI', 'XI - 5', '6687cb56cc090abcaedefca26a8e6606', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(425, '6074', 'ELVITA DWI MAHARANI', 'XI - 5', '2281f5c898351dbc6dace2ba201e7948', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(426, '6078', 'ERLANGGA RIZKI DIKA PRATAMA', 'XI - 5', '5f8a7deb15235a128fcd99ad6bfde11e', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(427, '6095', 'FINGKI TANIASARI', 'XI - 5', '000c076c390a4c357313fca29e390ece', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(428, '6098', 'FITRI OCTHA RAMADHANI', 'XI - 5', '34e420f6e47d96669897a45586997a57', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(429, '6100', 'GABRIELINO HARDIYANSYAH', 'XI - 5', '802a5fd4efb36391dfa8f1991fd0f849', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(430, '6108', 'HAFIZH WILDAN HARIYANTO', 'XI - 5', 'c09b1eadea0efc7914f73ac698494b5e', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(431, '6136', 'KERN ERESYA PUTRI', 'XI - 5', 'c1285fcadc52c0d3dc8813fc2c2e2b2a', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(432, '6138', 'KEYNA GRESIA PUTRI', 'XI - 5', 'b2ead76dfdc4ae56a2abd1896ec46291', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(433, '6156', 'MASRUROH', 'XI - 5', '2eacc82231f2e62f9acb38bece54635e', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(434, '6167', 'MOH. YONATHAN ZULKARNAIN', 'XI - 5', '63d5fb54a858dd033fe90e6e4a74b0f0', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(435, '6183', 'MUHAMMAD RAIHAN KADAVI', 'XI - 5', 'c14a2a57ead18f3532a5a8949382c536', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(436, '6207', 'NURHAMID', 'XI - 5', '62db9e3397c76207a687c360e0243317', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(437, '6209', 'NURMA SAQINA PURNAMI PUTRI', 'XI - 5', '5446f217e9504bc593ad9dcf2ec88dda', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(438, '6211', 'OCTA FELISHA', 'XI - 5', '0f34132b15dd02f282a11ea1e322a96d', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(439, '6217', 'PRADITA ENGGAR NILAM CAHAYA', 'XI - 5', '9d1827dc5f75b9d65d80e25eb862e676', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(440, '6232', 'RAFA GALANG ADMAJA HAMINTO', 'XI - 5', '575425a3f433138553be468c9d1ecba7', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(441, '6237', 'RAMADHANI WAHYU DWI MAULANA', 'XI - 5', '885cb47f87718a2cd8641ae79113eeea', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(442, '6249', 'RIZKY ARIANI PUTRI', 'XI - 5', 'bcb7c13ff9746a60fa8c3e748acd054d', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(443, '6258', 'SEKAR PELANGI KARUNIA MEGA', 'XI - 5', '97ffcbd95363387c7e371563057eb02f', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(444, '6263', 'SETIO BUDI SANTOSO', 'XI - 5', '30ee748d38e21392de740e2f9dc686b6', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(445, '6278', 'SYIFAUL ASROR', 'XI - 5', '30de24287a6d8f07b37c716ad51623a7', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(446, '6282', 'TIRTHAYAZA NILLA ZAENIRA', 'XI - 5', 'c2073ffa77b5357a498057413bb09d3a', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(447, '6284', 'TUSILA DWI ANGGRAINI', 'XI - 5', '7a7c6a5b2f18e21e23049634cec06c68', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(448, '6288', 'VIRA NUR INDAH SARI', 'XI - 5', '20ba7f85c05c5e5b75abced9ece67ac9', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(449, '6296', 'YULIA RAHMA', 'XI - 5', 'e1fe6165cad3f7f3f57d409f78e4415f', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(450, '5972', 'ACHMAD AZZAM MUZAQI', 'XI - 6', 'd8a3a3c3234392b0add43c5f9c05a246', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(451, '5987', 'AHMAD FARHAN', 'XI - 6', '7f9d88fe83d3e7fce3136e510b0a9a38', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(452, '5990', 'AHMAD SYUKRI AUNILLAH', 'XI - 6', '3cba81c5c6cac4ce77157631fc2dc277', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(453, '5991', 'AINI NUR KAMILA', 'XI - 6', 'c0356641f421b381e475776b602a5da8', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(454, '5992', 'AIRA GRIMONIA INDU RAYA', 'XI - 6', '675f9820626f5bc0afb47b57890b466e', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(455, '6000', 'ALKA GADING SANDIKA', 'XI - 6', 'a8c6dd982010fce8701ce1aef8a2d40a', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(456, '6013', 'ANGGUN RUGAIYAH', 'XI - 6', '8fd7f981e10b41330b618129afcaab2d', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(457, '6016', 'AQNA DIVANIL AFTONI', 'XI - 6', '593906af0d138e69f49d251d3e7cbed0', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(458, '6019', 'ARISTA WIDYA DAMAYANTI', 'XI - 6', '5218f316b3f85b751c613a06aa18010d', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(459, '6021', 'ARKAN JAVIER FIKRI', 'XI - 6', 'b075703bbe07a50ddcccfaac424bb6d9', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(460, '6022', 'ARTHA SETIAWAN', 'XI - 6', 'da54dd5a0398011cdfa50d559c2c0ef8', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(461, '6026', 'AULIA NABILA PUTRI', 'XI - 6', 'a70dab11c90d06b809d0be230731762a', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(462, '6034', 'AZWALIZA MONA SELABUNG PUTRI', 'XI - 6', '78421a2e0e1168e5cd1b7a8d23773ce6', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(463, '6035', 'AZZAHRAH NISMA GHAZIYAH', 'XI - 6', '4639475d6782a08c1e964f9a4329a254', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(464, '6049', 'CINTA TUNGGA DEWI LENTERA HARI PUTRI', 'XI - 6', 'fe45e3227f3805b1314414203c4e5206', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(465, '6076', 'ERIKA MAWANDA VANESA', 'XI - 6', 'beb22abb9ec56c0cf7ec7d811dd91a56', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(466, '6086', 'FAREL EMERALDI', 'XI - 6', '95e1533eb1b20a97777749fb94fdb944', '2026-07-28 01:34:03', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(467, '6104', 'GIOFANI OKTAVIAZIZA', 'XI - 6', '46384036044a604b6b3316fc167fc15f', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(468, '6118', 'ILMIRA SYAFHA MAULIDIYAH', 'XI - 6', '1755c118e8859eb000eb6eca25369407', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(469, '6127', 'JESSICA SALSABILA', 'XI - 6', '9570efef719d705326f0ff817ef084e6', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(470, '6128', 'JESSLYN CHRYSILLA SYBIL', 'XI - 6', 'b72a5a099433a2099fc3d92f6ad3accf', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(471, '6148', 'LIVIENA ANINDIYA DELISHA', 'XI - 6', '30c0a496a57bcc2c7c6c481342526729', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(472, '6149', 'LOVECHA SAFA BRILIAN ARIZONA', 'XI - 6', 'b04c387c8384ca083a71b8da516f65f6', '2026-07-28 01:34:03', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:03'),
(473, '6157', 'MAYLANG KORI', 'XI - 6', '26d4b4313a7e5828856bc0791fca39a2', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(474, '6176', 'MUHAMAD RIVALIAN FADILLAH', 'XI - 6', 'fc1f073fe91403f00d2219185fdea79b', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(475, '6178', 'MUHAMMAD FARDHAN AZIZI', 'XI - 6', '654516d1b4df6917094de807156adc14', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(476, '6182', 'MUHAMMAD RAFI HAMMADI', 'XI - 6', '4c5a99856a3c634a5a3beae02520cdc2', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(477, '6189', 'NADIA AYU FRANSISKA', 'XI - 6', '67ba02d73c54f0b83c05507b7fb7267f', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(478, '6191', 'NADYA NURUL AFIYAH', 'XI - 6', '9d4c03631b8b0c85ae08bf05eda37d0f', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(479, '6192', 'NAIMA FITRI RAMADANI', 'XI - 6', 'f91ceb5afe88b7ab6023892165de4033', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(480, '6202', 'NIMAS AYU SETIAWATI', 'XI - 6', '38ccdf8d538de2d6a6deb2ed17d1f873', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(481, '6203', 'NIMAS CANDRA KIRANA CAHYANINGRUM', 'XI - 6', 'd4b0a4ece86c42fe7c34d6eaa9aef588', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(482, '6228', 'RACHEL ADELIA MAHARANI', 'XI - 6', 'f4e3ce3e7b581ff32e40968298ba013d', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(483, '6245', 'RIFNU MAHENDRA DESTA', 'XI - 6', 'c783eed3cfc1c978fe76e15af007e0d0', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(484, '6265', 'SHIFA AULIA SUPIYANTO', 'XI - 6', 'b3b25a26a0828ea5d48d8f8aa0d6f9af', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(485, '6274', 'SUNAN AJI CANDRA WIRATAMA', 'XI - 6', 'd0353558f3ae8b91febe82f5a735bb06', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(486, '5989', 'AHMAD NUR RANGGA', 'XI - 7', '1ae6464c6b5d51b363d7d96f97132c75', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(487, '5997', 'ALFATH ADAM KADAFI', 'XI - 7', '077fd57e57aab32087b0466fe6ebcca8', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(488, '6006', 'AMELINDA', 'XI - 7', '91ba4a4478a66bee9812b0804b6f9d1b', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(489, '6008', 'ANDIKA', 'XI - 7', '569ff987c643b4bedf504efda8f786c2', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(490, '6036', 'BILQISTH REGITA CAHYANI', 'XI - 7', '567b8f5f423af15818a068235807edc0', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(491, '6041', 'CARIN TRISIA', 'XI - 7', '58ee2794cc87707943624dc8db2ff5a0', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(492, '6043', 'CHAIRIL DAMAR YUSUF PUTRA', 'XI - 7', '2e9777b99786a3ef6e5d786e2bc2e16f', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(493, '6065', 'DIEGO ILHAM FANDEV', 'XI - 7', 'dfd786998e082758be12670d856df755', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(494, '6068', 'DISTA APRILIA EFENDI', 'XI - 7', 'b5ecbbf5782cc7fe9e453f3a2f26f24b', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(495, '6070', 'DITA PUTRI WAHYUNI', 'XI - 7', 'a4df48d0b71376788fee0b92746fd7d5', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(496, '6071', 'DIVANY PUTRI', 'XI - 7', '7fa1575cbd7027c9a799983a485c3c2f', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(497, '6072', 'DWI CAHYA SURYA BUANA', 'XI - 7', '3ffebb08d23c609875d7177ee769a3e9', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(498, '6081', 'EXSA MONICA', 'XI - 7', 'adf854f418fc96fb01ad92a2ed2fc35c', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(499, '6084', 'FARAH NATASHA BEGUM', 'XI - 7', '0d770c496aa3da6d2c3f2bd19e7b9d6b', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(500, '6105', 'GITA RAMADHANI', 'XI - 7', 'c1d53b7a97707b5cd1815c8d228d8ef1', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(501, '6111', 'HARLANG ULAMAK ALI FARHAD', 'XI - 7', '721e049e9903c3a740c4902878c99923', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(502, '6113', 'HELDYNO SYAPUTRA', 'XI - 7', '0af854284f4ab0cfea8fcfd889cbb41a', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(503, '6132', 'JUWITA MEI ZIVANNA', 'XI - 7', '36d5ef2a011f0b3e0e0fa139228bbe18', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(504, '6146', 'LENY SRI ANGGRIANI', 'XI - 7', 'ba053350fe56ed93e64b3e769062b680', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(505, '6153', 'M.HAFIDS ANDIKA DARYANTA', 'XI - 7', 'a4d5fad84ee90c1308cc37b52135d5db', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(506, '6173', 'MOHAMAD FARHAN ARDIANSYAH', 'XI - 7', '4ccb2d64b8159636a44b29fe2e62a841', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(507, '6171', 'MOHAMAD WAFI RAHARDIAN', 'XI - 7', 'b5d3ad899f70013367f24e0b1fa75944', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(508, '6179', 'MUHAMMAD HAMDAN SYAUQI', 'XI - 7', '3d36c07721a0a5a96436d6c536a132ec', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(509, '6195', 'NAVELION RAVA AMARTA', 'XI - 7', '03c874ab55baa3c1f835d108415fac44', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(510, '6204', 'NINDIYA AYU RIZKINAH', 'XI - 7', '07b2ee9f02d5e6e8894377afb4feed32', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(511, '6212', 'OCTARIO IBRAHIM MASRUR ZAMROZI', 'XI - 7', '9a83eabfb7fa303a2d85dbc6f37483e5', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(512, '6223', 'PUTRI NUR RAMADHANI', 'XI - 7', '0e1418311a013ebb344e7fcf8d199cc3', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(513, '6233', 'RAHMAT NUR HIDAYAT', 'XI - 7', '196894366d827c56344bfe5186dbcf64', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(514, '6250', 'RIZKY NURWAHYUDI', 'XI - 7', '947018640bf36a2bb609d3557a285329', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(515, '6264', 'SHAFA NURIA SADIRA', 'XI - 7', '8ab7f718012c87aad3887a7d136cdf53', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(516, '6283', 'TRYA MULYA SUGIARTATI', 'XI - 7', '8a9c8ac001d3ef9e4ce39b1177295e03', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(517, '6289', 'WILDAN RADITYA PRATAMA', 'XI - 7', 'f7fbc4bafcc80cbf690acbef25f2ce1c', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(518, '6290', 'WILUJENG DEVINA IMLIYANTI', 'XI - 7', '5d8c6ee0d8964e66a3225458f981522d', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(519, '6292', 'YARDAN AKBAR', 'XI - 7', '89d3d7800304002cd469f0c402bd3ea0', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(520, '6301', 'ZIDAN AULIYA NUR BASMALAH', 'XI - 7', '1dffefa65e27e7187c6c052be0ae02b0', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(521, '6308', 'EKA PUTRI INDAH AYU LESTARI', 'XI - 7', 'eb21cc0143d96dbc8e3a58f1a81e4dd2', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(522, '5979', 'ADINDA FITRIYANI', 'XI - 8', '6d7d394c9d0c886e9247542e06ebb705', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(523, '5994', 'AIZAR IBNU ZAKI', 'XI - 8', 'edb446b67d69adbfe9a21068982000c2', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(524, '6003', 'ALMIRA FIKRIATUS SYIFA', 'XI - 8', '7acba01022004f2ce03bf56ca56ec6f4', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(525, '6032', 'AYUNDA HANUN HARIYANTO', 'XI - 8', 'fb3a30a2e3e8abdcbf63f0aaaadb06e4', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(526, '6038', 'BIYAN RAFAEL', 'XI - 8', '6bb56208f672af0dd65451f869fedfd9', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(527, '6054', 'DEA NATALIYA', 'XI - 8', '417fbbf2e9d5a28a855a11894b2e795a', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(528, '6058', 'DEVI SILVIA NINGRUM', 'XI - 8', '5b8e9841e87fb8fc590434f5d933c92c', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(529, '6077', 'ERLANGGA DWI NUGROHO', 'XI - 8', '58182b82110146887c02dbd78719e3d5', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(530, '6087', 'FATEHATUL KARIMAH', 'XI - 8', '5a2a330b175fe588c2551b78d18d3207', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(531, '6093', 'FIDHOTUL AINI', 'XI - 8', '1438ecb8cb1f6fadfee2190700789d7b', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(532, '6101', 'GALIH OKTAKUMALA', 'XI - 8', '2cfa47a65809ea0496bbf9aa363dc5da', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(533, '6109', 'HANUM NAJUANG PRABAN', 'XI - 8', '27b09e189a405b6cca6ddd7ec869c143', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(534, '6112', 'HASBY ZULFANI RIDHO', 'XI - 8', '0b6a27e2bfcb010e762109f0d2e042dc', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(535, '6125', 'IRAWAN PRABOWO', 'XI - 8', '6e3b0bf8b7d5956ae572b15cd7ddb0e1', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(536, '6131', 'JUWITA DWI HARANTI', 'XI - 8', '392526094bcba21af9fd4102ce5ed092', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(537, '6135', 'KEN MOHAMMAD ERNANDO', 'XI - 8', '4cc5400e63624c44fadeda99f57588a6', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(538, '6139', 'KHAULA AZIZA', 'XI - 8', '618faa1728eb2ef6e3733645273ab145', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(539, '6140', 'KHOIRUNNISA ANDRIANI', 'XI - 8', '3d7d9461075eb7c37fbbfcad1d7042c1', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(540, '6150', 'LUKMAN ALFIANSYAH', 'XI - 8', '598a90004bace6540f0e2230bdc47c09', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(541, '6155', 'MARVIN CRISTIAN ARDINO', 'XI - 8', 'a47072176bca825aadacf648034e124b', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(542, '6165', 'MOH. FARDAN ELDIANO', 'XI - 8', '36452e720502e4da486d2f9f6b48a7bb', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(543, '6166', 'MOH. GELDIN RENOZA OBAMA', 'XI - 8', '4249a84bdaf63c34332d1988244fb089', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(544, '6187', 'MYZEL JUNY ALSA', 'XI - 8', '0e1bacf07b14673fcdb553da51b999a5', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(545, '6200', 'NIKO', 'XI - 8', 'dd409260aea46a90e61b9a69fb9726ef', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(546, '6205', 'NIRMALA KAUTSAR PUTRIE', 'XI - 8', '03924fb32bcc6248036e209a716e3339', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(547, '6222', 'PUTRI IVANA', 'XI - 8', '1a260649dac0ddb2290f609a13f4b814', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(548, '6227', 'QURROTU NISA\'UR ROHMAH', 'XI - 8', '56f0b515214a7ec9f08a4bbf9a56f7ba', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(549, '6230', 'RADITYA NESTA SAPUTRA', 'XI - 8', 'a7c9585703d275249f30a088cebba0ad', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(550, '6244', 'RIFKI IHZA PRATAMA PUTRA', 'XI - 8', '21f4c3b5591da245af90a2fd52fa1a55', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(551, '6243', 'RIFKY ALFAREZA', 'XI - 8', 'b4edda67f0f57e218a8e766927e3e5c5', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(552, '6248', 'RISTA OKTAVIA PUTRI', 'XI - 8', 'e6a4f65e7355bb8b7671c3a18003b146', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(553, '6267', 'SIFA OKTA NURSAHDINI', 'XI - 8', '193510e35bf81956996aa49093954075', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(554, '6270', 'SITI AIRA NATASYA', 'XI - 8', '75a7e9d83024b7ce00fe9cd2aa0bd0c5', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(555, '6276', 'SYAIF ALI MAULANA', 'XI - 8', '08aee6276db142f4b8ac98fb8ee0ed1b', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(556, '6279', 'TEGAR WAHYU SYAPUTRA', 'XI - 8', 'dc0e1946e45197021f072193c520505a', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(557, '6291', 'WINA CINDY AULIA', 'XI - 8', 'c9f029a6a1b20a8408f372351b321dd8', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(558, '5973', 'ACHMAD NAWAF DANIEL HUDA', 'XI - 9', '6de59d960d3bb8a6346c058930f3cd28', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(559, '5986', 'AHMAD FAIRUZ RAFIF WAKAYSI', 'XI - 9', 'fd45c64e026040dbcb83395829d2aea5', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(560, '5988', 'AHMAD GALANG TSALASA MIHDANIL ABI', 'XI - 9', 'dfbfa7ddcfffeb581f50edcf9a0204bb', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(561, '6001', 'ALLEN ADI PRATAMA', 'XI - 9', 'ea1818cbe59c23b20f1a10a8aa083a82', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(562, '6007', 'ANDHIKA PRATAMA', 'XI - 9', 'bacadc62d6e67d7897cef027fa2d416c', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(563, '6028', 'AURA NISA CAHAYA GUMILANG', 'XI - 9', '2c60e40b399dc55d8b755ec6b5d09f8a', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(564, '6044', 'CHANTIKA LAURA DEWI', 'XI - 9', '6b39183e7053a0106e4376f4e9c5c74d', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(565, '6059', 'DEWI ANATASYA LESTARI', 'XI - 9', '18b91b19f6a289e7708da7f778b2c609', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(566, '6085', 'FARDILA KHUMAIRA RAHMA', 'XI - 9', '3413ce14d52b87557e87e2c1518c2cbe', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(567, '6088', 'FAZA FAUDZAN ADIMA', 'XI - 9', 'c4bca428211c2b48b81fd3b12afd2aa1', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(568, '6090', 'FEBIYANTI', 'XI - 9', '0fcee95cc7b4f2067da8ba1e330de18e', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(569, '6097', 'FITRI AYU WULANDARI', 'XI - 9', 'afb79a9be5cd9762572a008088d3153e', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(570, '6115', 'HERLAMBANG SURYA RAMADHANI', 'XI - 9', 'c77cfd5563c8ec4bfcde94c09098ba84', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(571, '6121', 'IMIRA SKARTIKA', 'XI - 9', '03fcd68e5673f08be96d2b6bb5be8261', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(572, '6122', 'INAS MAULAYAL HUSNA', 'XI - 9', '8aa2c95dc0a6833d2d0cb944555739cc', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(573, '6129', 'JOCKY DWI SANJAYA', 'XI - 9', 'acc21473c4525b922286130ffbfe00b5', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(574, '6168', 'MOH.FAHRI HIDAYATULLAH', 'XI - 9', 'f5a14d4963acf488e3a24780a84ac96c', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(575, '6170', 'MOHAMAD REVI SOPYAN', 'XI - 9', '2ccc2826b445aebac6f6b3f8013e7931', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(576, '6175', 'MUHAMAD NURIL AKBAR', 'XI - 9', 'c80d9ba4852b67046bee487bcd9802c0', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(577, '6177', 'MUHAMAD ZAINU ALBAR', 'XI - 9', 'd98c1545b7619bd99b817cb3169cdfde', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(578, '6181', 'MUHAMMAD MIFTAHUL UMMAM', 'XI - 9', '7873b66ca1d39eb8603c467fa05cfe86', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(579, '6184', 'MUHAMMAD UMARUL FARUQ', 'XI - 9', '08425b881bcde94a383cd258cea331be', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(580, '6190', 'NADIN OKTAVIA AL KALIFI', 'XI - 9', '16837163fee34175358a47e0b51485ff', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(581, '6196', 'NAWAL ANGGRAINI', 'XI - 9', 'f169b1a771215329737c91f70b5bf05c', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(582, '6198', 'NEZA INDIRA PUTRI', 'XI - 9', 'b77375f945f272a2084c0119c871c13c', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(583, '6213', 'PANDU SANDI KUSUMA', 'XI - 9', 'e275193bc089e9b3ca1aeef3c44be496', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(584, '6216', 'PRADIFTA ADITYA WIJAYA', 'XI - 9', '619427579e7b067421f6aa89d4a8990c', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(585, '6234', 'RAIHAN ALI SYAH BANA', 'XI - 9', '91576cbf171986154e523305a69c79d3', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(586, '6262', 'SESILIA ANGGRAINI', 'XI - 9', '481fbfa59da2581098e841b7afc122f1', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(587, '6269', 'SINDI RAHAYU LESTARI', 'XI - 9', 'cc9b3c69b56df284846bf2432f1cba90', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(588, '6273', 'SITI RAHMA NURHIDAYATI', 'XI - 9', '619953730129049907919279f29bd9d7', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(589, '6281', 'TIRTA BENING AULIA', 'XI - 9', 'f86890095c957e9b949d11d15f0d0cd5', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(590, '6286', 'UMMUL KHOIROH NUR AINI', 'XI - 9', 'caa145542f7333f6ebf99a72b87bdeba', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(591, '6295', 'YOSI ARDI PRAYOGA', 'XI - 9', '9df81829c4ebc9c427b9afe0438dce5a', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(592, '6297', 'YUSUF ACHMAD ABDILLAH', 'XI - 9', '32c47400d002aa2e9608f262414b4aba', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(593, '6310', 'HASYIELLA ZAHRA SABRINA', 'XI - 9', '9381fc93ad66f9ec4b2eef71147a6665', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(594, '5613', 'ADIKE CAHAYA VALENTINA', 'XII - 1', '45624a44b89793087e9ef4d076018adb', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(595, '5614', 'ADINDA AJENG VHERONICA', 'XII - 1', '3a09a524440d44d7f19870070a5ad42f', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(596, '5627', 'AHMAD RIKZA ALFACHRI', 'XII - 1', '5898d8095428ee310bf7fa3da1864ff7', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(597, '5631', 'AHMAD ZAKKY AINUN NIZAR', 'XII - 1', 'cacbf64b8a464fa1974da1eb0aa92851', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(598, '5656', 'ANANDA MARSYA NUR MADINA', 'XII - 1', 'ae5eb824ef87499f644c3f11a7176157', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(599, '5657', 'ANANDA RAFIQ ADITAMA', 'XII - 1', 'ba2030d9a88b7db99edb3da67200167c', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(600, '5659', 'ANANDA UNDATUS S', 'XII - 1', '94b087da83ceb5fe6f1a13150f8c0471', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(601, '5663', 'ANGGITA YASMIN AL-MAGHFIROH', 'XII - 1', 'ac71e0079799a57cc6616312cbbbaf84', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(602, '5670', 'ANNISHA SHARIENA NATHALIA', 'XII - 1', '8909a6e385b0fbc1f3885c00ae838de7', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(603, '5671', 'APRILIA CITRA ANANDA', 'XII - 1', '63a8f9e307f0bf4473c24dd4db17cebd', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(604, '5673', 'ARDHAN ADITYA YUSUF', 'XII - 1', 'c66dd00e5fc44ba8de89d7713fedcd50', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04');
INSERT INTO `siswa` (`id`, `nis`, `nama`, `kelas`, `password`, `created_at`, `jenis_kelamin`, `tanggal_lahir`, `alamat`, `no_telepon`, `foto_profile`, `updated_at`) VALUES
(605, '5676', 'ARKHA RIZKY PERDANA', 'XII - 1', '3a01fc0853ebeba94fde4d1cc6fb842a', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(606, '5692', 'BELQIZT INDIRA KUSNO', 'XII - 1', 'b597460c506e8e35fb0cc1c1905dd3bc', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(607, '5710', 'DEVI ADELINA SAVITRI', 'XII - 1', '810462d01f318bd13e628a77fc3f92c0', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(608, '5714', 'DHEA ANDELLA', 'XII - 1', '0fe6a94848e5c68a54010b61b3e94b0e', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(609, '5716', 'DIAH WARDANI', 'XII - 1', 'fd4771e85e1f916f239624486bff502d', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(610, '5731', 'DIVA SITI FATIMAH', 'XII - 1', '164bf317ea19ccfd9e97853edc2389f4', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(611, '5733', 'DWI RANGGA RAHARJOYO', 'XII - 1', '0a988fc2992add2d3233e19c7aadfdea', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(612, '5747', 'FAHRI ADI VIRDHASYA', 'XII - 1', '56d326d8139f904b679084778f1b3285', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(613, '5771', 'HIROKY AGIECO', 'XII - 1', 'd156d4836ea87dd732cfda175b7911cb', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(614, '5793', 'KHOIRUN NUR FI\'LIK JAMIL', 'XII - 1', 'fe256faf97c200de0f7486ddf56c02f6', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(615, '5797', 'KRISNA DHARMA CHARTA POLITIKA', 'XII - 1', '034260c0426cf36118803ce0df4457fd', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(616, '5799', 'LEO ARI SAPUTRA', 'XII - 1', 'de01d76e793fec3fba32f4401a45fb20', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(617, '5805', 'LUTVI ARDIAN', 'XII - 1', 'd81f29a9985d0eb4adc0279e79a9ec75', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(618, '5820', 'MOH. FARHAN SATRIO HADI', 'XII - 1', 'a9e18cb5dd9d3ab420946fa19ebbbf52', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(619, '5824', 'MOH. THORIQ RIDHO SETYO EKO SASMITO', 'XII - 1', 'b7f520a55897b35e6eb462bbf80915c6', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(620, '5826', 'MOHAMAD ALVIN DIKRUNAFAQI', 'XII - 1', '99f42c473afe0eb4bd047ae133b851fc', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(621, '5833', 'MUHAMAD ADI SUYONO', 'XII - 1', 'f5f3b8d720f34ebebceb7765e447268b', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(622, '5838', 'MUHAMMAD FAIZ ADHIBI', 'XII - 1', 'a91bc76c2a6302e573badedcbf57bf7a', '2026-07-28 01:34:04', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(623, '5859', 'NAWANG AYU WULANDARI', 'XII - 1', '60106888f8977b71e1f15db7bc9a88d1', '2026-07-28 01:34:04', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:04'),
(624, '5879', 'PUTRI WULANDARI', 'XII - 1', '927e838a450e2fe6225edfc3d12e2463', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(625, '5905', 'RIF\'A FATAR', 'XII - 1', '148148d62be67e0916a833931bd32b26', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(626, '5939', 'SINTA AYUDIANA', 'XII - 1', '8a88d5f412f2ad376f8597d28cbd3720', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(627, '6305', 'RISKI AGUSTIN', 'XII - 1', '90e69a6d2ad189b222ac1998abe63aea', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(628, '5611', 'ADAM MAULANA FIRMANSYAH', 'XII - 2', '01846ae470651e97d2f73fce979406a9', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(629, '5612', 'ADELIA DESTY PRAMITHA', 'XII - 2', '6e8404c3b93a9527c8db241a1846599a', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(630, '5619', 'AGUS TRI CAHYONO', 'XII - 2', '1a4ab15f37a1d2341d947a9996ddfbf7', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(631, '5639', 'ALDO PUTRA TIMURIYANTO', 'XII - 2', 'f4f0edb08c97567ce6b0475a63bf7000', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(632, '5649', 'ALVIN DIKI SAPUTRA', 'XII - 2', '337cd73a31464dd4adfc3c5dbc356cd0', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(633, '5660', 'ANDIKA DWI RAMADHANI', 'XII - 2', 'fa1839c55070bf5cb53fd4a2e523641c', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(634, '5662', 'ANDIKA FEBRIANTO', 'XII - 2', '887caadc3642e304ede659b734f79b00', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(635, '5668', 'ANNISA QURATUL AIN', 'XII - 2', '048e9aee4ffe42efbf7865f0bd5a2fa4', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(636, '5690', 'BALQIS SYAHKIRA RIZQI HIDAYAT', 'XII - 2', '9cea10c7ff109c6e61727a0d45492ead', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(637, '5695', 'BRILIAN ZADA PUTRA HARIYANTO', 'XII - 2', 'dfea0768cc6ba51dd20c7224016b0bd7', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(638, '5705', 'DAVA NAREL AGUSTIAN', 'XII - 2', 'af87f7cdcda223c41c3f3ef05a3aaeea', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(639, '5738', 'ELANG DZIKRA AWWALIN', 'XII - 2', 'd0f4dae80c3d0277922f8371d5827292', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(640, '5741', 'ELZHA MAULIDYA PUTRI', 'XII - 2', 'edea298442a67de045e88dfb6e5ea4a2', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(641, '5756', 'FHAREL HADI SAPUTRA', 'XII - 2', '7ecd070e606afbf07a07c32e7267051f', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(642, '5770', 'HESTITA AINURA RAYA', 'XII - 2', '4b7a55505729b7f664e7222960e9c2d5', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(643, '5782', 'JELITA AFRIDA', 'XII - 2', 'cf9dc5e4e194fc21f397b4cac9cc3ae9', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(644, '5787', 'KANAYA TABITA', 'XII - 2', 'a32d7eeaae19821fd9ce317f3ce952a7', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(645, '5790', 'KEISYA PUTRI ARIANTI', 'XII - 2', '8763d72bba4a7ade23f9ae1f09f4efc7', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(646, '5804', 'LUTFI NUR AZIZAH', 'XII - 2', '5e5dd00d770ef3e9154a4257edcb80b8', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(647, '5806', 'LUTVILATUL RIMEYZA ALYA', 'XII - 2', '9873eaad153c6c960616c89e54fe155a', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(648, '5810', 'MASDAR MAHFURI', 'XII - 2', '4c7a167bb329bd92580a99ce422d6fa6', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(649, '5814', 'MEGA AGUSTIN NUR AZIZAH', 'XII - 2', 'f93486bfff38ca69d76d85c089569a09', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(650, '5825', 'MOH. RAFI OKTAVIYANDI', 'XII - 2', 'c5a0ac0e2f48af1a4e619e7036fe5977', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(651, '5831', 'MOHAMMAD FICO MAHARDIKA', 'XII - 2', '228669109aa3ab1b4ec06b7722efb105', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(652, '5846', 'NAGITA AFNI ANNAFI\'U', 'XII - 2', '63eb58bd4d3486f001438f911a11d323', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(653, '5850', 'NANDA RIZKI PRATAMA', 'XII - 2', '234a1273487bf7b2e2061b9b56373a29', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(654, '5898', 'REVA RIZALUL KAMIL', 'XII - 2', 'eecccd8ff4107946c78d42265cd474b5', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(655, '5901', 'REZA ARDIANSYAH', 'XII - 2', 'f4661398cb1a3abd3ffe58600bf11322', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(656, '5930', 'Safira Zahra Ramadhani', 'XII - 2', '3b199f42a9909061516b6ce6d334af6d', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(657, '5936', 'SILVIA ROYTHUL VIZZANAH', 'XII - 2', '60131a2a3f223dc8f4753bcc5771660c', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(658, '5940', 'SISKA MEIDINA', 'XII - 2', 'c17028c9b6e0c5deaad29665d582284a', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(659, '5951', 'UMAR AL FARUQ', 'XII - 2', '800b03685c22049f049801f6841861a2', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(660, '5959', 'YUDHA PRATAMA', 'XII - 2', '010e406df2463597c58286a93f8b3160', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(661, '5967', 'CAHYO PUTRA ADI SULUNG', 'XII - 2', '8682cc30db9c025ecd3fee433f8ab54c', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(662, '6309', 'AVRILIANA ZWEI ZAHRA', 'XII - 2', '6a13382a520e0420014027350a0b3eb4', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(663, '5652', 'AMELIA RISKA', 'XII - 3', 'b4f1ec9f4b5c8207f8fc29522efe783d', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(664, '5675', 'ARINI ALFANAL YAUMI', 'XII - 3', '045752bc5c7f705cea3cc14c036c261c', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(665, '5678', 'ARYA INDRA KUSUMA', 'XII - 3', '674f3c2c1a8a6f90461e8a66fb5550ba', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(666, '5683', 'ASMARA RIFKI ARDANI', 'XII - 3', '14db62200d8bf46551aa214accafe1df', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(667, '5685', 'AULIA DEWI SINTIYA SARI', 'XII - 3', 'a1b07b8980c5acf5ef69cff16ebb1f42', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(668, '5687', 'AXEL CHANDRA PRASTIYO', 'XII - 3', '218ac3fe3df6ff2c8fe8f9353f1084f6', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(669, '5700', 'CHARILLA', 'XII - 3', '84f5ddd735176becc72c3b1ff424149e', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(670, '5722', 'DINA LUTFIANA', 'XII - 3', 'c94a589bdd47870b1d74b258d1ce3b33', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(671, '5724', 'DINDA KANYA MAHANI SETIAWAN', 'XII - 3', 'e49eb6523da9e1c347bc148ea8ac55d3', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(672, '5725', 'DINDA MAULINA DEWI', 'XII - 3', '2109737282d2c2de4fc5534be26c9bb6', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(673, '5735', 'EGA PUTRA PRATAMA', 'XII - 3', '6d34d468ac8876333c4d7173b85efed9', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(674, '5740', 'ELSHA MAIFIRA ROSADI', 'XII - 3', '9be681ea06f52111e4c1ef99d3763770', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(675, '5751', 'FANTRI ZUPI ZULKARNAIN', 'XII - 3', 'a4c42bfd5f5130ddf96e34a036c75e0a', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(676, '5765', 'FITRI WIDIA AGUSTIN', 'XII - 3', '8b10a9280bd46b8874af9b5cadec91d5', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(677, '5779', 'INDY ZAHRATUN NAJWA', 'XII - 3', '7d3d5bcad324d3edc08e40738e663554', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(678, '5795', 'KIRANA SATYA MAHARANI', 'XII - 3', '5f11b27f131494a1c014fcced2f13165', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(679, '5800', 'LIONAL AKHADI WIRA SAID', 'XII - 3', '1dacb10f0623c67cb7dbb37587d8b38a', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(680, '5818', 'MIALIS SYAFA', 'XII - 3', 'ed23fbf18c2cd35f8c7f8de44f85c08d', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(681, '5829', 'MOHAMAD ROBEN FEBRIANTO', 'XII - 3', 'd9909824688daaad46d441eefd81eb38', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(682, '5834', 'MUHAMAD FIRMANSYAH', 'XII - 3', '15b3342aa0abd5176b93d68ddf95e3ce', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(683, '5844', 'NADIA MUSTIKA', 'XII - 3', 'f9322b146574d9da9ad32ad879ad373b', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(684, '5849', 'NAJWA SALSABILA ABRIAN', 'XII - 3', '1b388c8b7c863fde3f559142fdc123b0', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(685, '5851', 'NASYA AUREL SALSABILLA', 'XII - 3', '2aec405d4b5959235c49ec1d78edb0c2', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(686, '5854', 'NAURA JUWITA CRENATA', 'XII - 3', '624ec1c881656ee6418604df2928494b', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(687, '5877', 'PUTRI AURALIA NUR AINI', 'XII - 3', 'c344336196d5ec19bd54fd14befdde87', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(688, '5878', 'PUTRI MARISKA AJENG ANDAYANI', 'XII - 3', 'e0ae4561193dbf6e4cf7e8f4006948e3', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(689, '5892', 'REGENT PUTRA ANDIANA', 'XII - 3', 'f1daf122cde863010844459363cd31db', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(690, '5902', 'RIA DWI NUR FADILAH', 'XII - 3', '70a32110fff0f26d301e58ebbca9cb9f', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(691, '5903', 'RIA MANGGARANI', 'XII - 3', '367147f1755502d9bc6189f8e2c3005d', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(692, '5904', 'RIDHO ALVIANO SETIAWAN', 'XII - 3', '05ae14d7ae387b93370d142d82220f1b', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(693, '5942', 'SITI NURKUMALA RAMADANI', 'XII - 3', 'b0dd033cbe58aa5ea27747271bfd84e3', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(694, '5950', 'TIARA ANGGUN KHARISMA', 'XII - 3', 'e148bbf8d64abf4aac7ea4a3c5560aee', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(695, '5952', 'VIKA AULIA ANWAR', 'XII - 3', '761efc843ff05ab74ed358713dd51c1b', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(696, '5953', 'VIRENCY SEPTIA RAHMADANI', 'XII - 3', 'e769e03a9d329b2e864b4bf4ff54ff39', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(697, '5616', 'ADITIYO RIZKY WIJAYA KUSUMA', 'XII - 4', '55a0ce8200cf39c3028ebc66f356bf7e', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(698, '5618', 'AFIFAH ULFAH', 'XII - 4', '98fb202278940504d75b5a97b1476be4', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(699, '5624', 'AHMAD NABIL QOTRIN NADA', 'XII - 4', 'c460dc0f18fc309ac07306a4a55d2fd6', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(700, '5643', 'ALFIN RAHMAT SYAUQI ROBBY', 'XII - 4', 'bee3d07327a21d8e7f02e10ba4b35c15', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(701, '5646', 'ALISA MAULI DINDA', 'XII - 4', '9219adc5c42107c4911e249155320648', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(702, '5647', 'ALMIRA SALSABILA DARMAWAN', 'XII - 4', '06563f3b418fe57f8fc331872343ce44', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(703, '5650', 'ALZHENA TRISKA SAFIRA', 'XII - 4', '675be3930765f553975c0b140bbf0863', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(704, '5664', 'ANGGUN JILAN RONA SAUSAN', 'XII - 4', 'b24d21019de5e59da180f1661904f49a', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(705, '5682', 'ASKA ADITYA PUTRA', 'XII - 4', '2f891485332423c8715842537cf742a0', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(706, '5684', 'AUFA ABDULLAH', 'XII - 4', '1959eb9d5a0f7ebc58ebde81d5df400d', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(707, '5715', 'DIAH AYU LESTARI', 'XII - 4', '6e4243f5511fd6ef0f03e9f386d54403', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(708, '5720', 'DIMAS ADITYA WARMAN', 'XII - 4', 'e34376937c784505d9b4fcd980c2f1ce', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(709, '5721', 'DIMAS BINTANG PRAYOGA', 'XII - 4', '5a66b9200f29ac3fa0ae244cc2a51b39', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(710, '5728', 'DIRGA JAYA EKO PURWANTO', 'XII - 4', '80b618ebcac7aa97a6dac2ba65cb7e36', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(711, '5744', 'EXCELLENT ATHAYA RIZQULLOH', 'XII - 4', '78631a4bb5303be54fa1cfdcb958c00a', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(712, '5746', 'FAHMI IHZA MAHENDRA', 'XII - 4', '63a99723ebb3af94d52b474c3b21dbe1', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(713, '5748', 'FAJAR NUZULUL ANAS', 'XII - 4', '1db3fa8e5bbd04882892f478a301a311', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(714, '5758', 'FINATUL ZANNAH', 'XII - 4', '588e343066cf54ec3db5132231df7d68', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(715, '5774', 'ICHA NOVITASARI', 'XII - 4', 'cff34ad343b069ea6920464ad17d4bcf', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(716, '5777', 'ILZAM NUZULI', 'XII - 4', '89abe98de6071178edb1b28901a8f459', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(717, '5788', 'KANZA VAIRUZA AQILLA', 'XII - 4', '967edfdcdfbcc3b2d253fac24326e5b5', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(718, '5796', 'KIRANIA ALZAHWA', 'XII - 4', '49856ed476ad01fcff881d57e161d73f', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(719, '5808', 'M. RASYA PRATAMA PUTRA', 'XII - 4', 'b448d8292fd27ae25bbc2e09ad43ff88', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(720, '5841', 'MUHAMMAD ROFI', 'XII - 4', '5fc34ed307aac159a30d81181c99847e', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(721, '5848', 'NAISILA SAFITRI', 'XII - 4', 'f19c44d068fecac1d6d13a80df4f8e96', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(722, '5852', 'NATALIA DEWI SAFIRA', 'XII - 4', '805163a0f0f128e473726ccda5f91bac', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(723, '5886', 'RAMA GRAYSILION NOVALA', 'XII - 4', '5300ef422e613b74fbf759d293aaab6a', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(724, '5890', 'RAYHAN ULIN NUHA', 'XII - 4', 'fc95fa5740ba01a870cfa52f671fe1e4', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(725, '5897', 'RESTU MAULANA NUR AZIZI', 'XII - 4', 'f9fd5ec4c141a95257aa99ef1b590672', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(726, '5899', 'REVAN MUAMMAR ZAIN', 'XII - 4', '362c99307cdc3f2d8b410652386a9dd1', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(727, '5900', 'REYHAN BINTANG ZULKARNAEN', 'XII - 4', 'fd0efcca272f704a760c3b61dcc70fd0', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(728, '5906', 'RIMBI HERDIANTIKASARI', 'XII - 4', '6d96718a701f5bfba283bbdc71dfa5c4', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(729, '5915', 'SAFINA AL MAKUIRA', 'XII - 4', '9ba196c7a6e89eafd0954de80fc1b224', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(730, '5934', 'SIDDAH DWI PUTRI', 'XII - 4', '7b852316cf9d2d41bec07321928afe96', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(731, '5962', 'ZASKIA MUTIARA RAMADHANI', 'XII - 4', 'baeabb8ff01160eec0b5db7da2805f57', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(732, '5608', 'ACH. REZA RIZQI MUBAROK', 'XII - 5', '487129304eca93e3646dd0c7dd441bf5', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(733, '5653', 'AMEZA LAILA FARHANA', 'XII - 5', 'd7e4cdde82a894b8f633e6d61a01ef15', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(734, '5654', 'AMIN WIBOWO', 'XII - 5', '297018ebde10e3024ac70a8120a2c82c', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(735, '5666', 'ANINDRA BINTANG ARDIANSAH', 'XII - 5', '4d386d01419c083e8df5de53eb5a0254', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(736, '5672', 'ARDA RIO MARFHEL', 'XII - 5', 'e7c573c14a09b84f6b7782ce3965f335', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(737, '5680', 'ASFA DAVYBYA ANHAR', 'XII - 5', '0f9a0878fcaf0dde29b4e487aa8bbb44', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(738, '5696', 'BUNGA SUCI KURYANINGTIAS', 'XII - 5', 'b8cfbf77a3d250a4523ba67a65a7d031', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(739, '5701', 'CHESIL HELSIVA', 'XII - 5', 'bac49b876d5dfc9cd169c22ef5178ca7', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(740, '5707', 'DEBHI ANGELINA PUTRI', 'XII - 5', '18903e4430783a191b0cfab439daaef8', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(741, '5712', 'DEWI NAWANGSARI', 'XII - 5', 'a6b8deb7798e7532ade2a8934477d3ce', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(742, '5745', 'FABRIO REVALDY', 'XII - 5', '46936add066bd6422b3ac74a0ccb7174', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(743, '5754', 'FERDINAND ABI NIZZAR DAVINZA', 'XII - 5', '0dbcf39d413231953d442f2f17f80cd5', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(744, '5755', 'FERY HARDIAN SYAH', 'XII - 5', '840d68cbbbfa627cd4635408a6c82009', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(745, '5762', 'FIRMANSYAH REVANLIANDRA PUTRA', 'XII - 5', 'd384dec9f5f7a64a36b5c8f03b8a6d92', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(746, '5781', 'IQHWAN MUAZIZ ZAINUR ROHMAN', 'XII - 5', '8e2c381d4dd04f1c55093f22c59c3a08', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(747, '5792', 'KHOFSOH LAELA', 'XII - 5', '89b9c689a57b82e59074c6ba09aa394d', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(748, '5813', 'MAZIYA HULI AZ-ZAHRA', 'XII - 5', '069090145d54bf4aa3894133f7e89873', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(749, '5817', 'MEYSILLA CINTA HIDAYAT', 'XII - 5', 'd1588e685562af341ff2448de4b674d1', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(750, '5823', 'MOH. SUGIYONO', 'XII - 5', '658bbbdef9415ba5e2ff857f1146ba6e', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(751, '5842', 'NADA KHALIZAH ZAHROTUSSITA', 'XII - 5', 'fb3ea77a2b3f8e7cb0e4e6699568d43d', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(752, '5856', 'NAURA SYAQINA AZAHRA FIRDAUSY', 'XII - 5', '10112bde2ba78e674b21aaa84613bc8e', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(753, '5857', 'NAVIA WARDATUS SHOLIHA', 'XII - 5', '2fb544a21e8cb8768b80cc231ca2f691', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(754, '5861', 'NAZMA KIRANI', 'XII - 5', 'ccdf3864e2fa9089f9eca4fc7a48ea0a', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(755, '5862', 'NAZWA KHARISMA BHIGUM', 'XII - 5', 'ecb287ff763c169694f682af52c1f309', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(756, '5865', 'NIKKI RUSDIANSYAH', 'XII - 5', '4669d6db6d5b6739b9194e999d907924', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(757, '5874', 'PUSPITA ELVINA AMBARSARI', 'XII - 5', '85d6e9c8255c0364fb67b5ac8a25eea3', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(758, '5881', 'QURROTUL A\'YUNIIN', 'XII - 5', '6d378765f17a856b7ba8bf1541cafb69', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(759, '5882', 'RADITYA FATUR RACHMAN', 'XII - 5', 'dffac38df13c3a801f1b8994f9303bcc', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(760, '5884', 'RAGIEL PUTRA PANGESTU', 'XII - 5', '7ed2d3454c5eea71148b11d0c25104ff', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(761, '5907', 'RIO FERDINAN', 'XII - 5', '5bcf8dd060e5ea0bff484b4a4127cb47', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(762, '5920', 'SAMUEL MARCEL FREDERICO MAY', 'XII - 5', '4c4ea5258ef3fb3fb1fc48fee9b4408c', '2026-07-28 01:34:05', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(763, '5923', 'SASKIA AMILATUSSOLIHA', 'XII - 5', '418db2ea5d227a9ea8db8e5357ca2084', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(764, '5938', 'SINDY AGUSTINA', 'XII - 5', '62e0973455fd26eb03e91d5741a4a3bb', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(765, '5948', 'TATA KALISTA PUTRI', 'XII - 5', 'cd0b43eac0392accf3624b7372dec36e', '2026-07-28 01:34:05', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:05'),
(766, '5961', 'ZAHRA RANA AMIRA', 'XII - 5', '094366eaa7a4b5d7f9ed227f212b3649', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(767, '5609', 'ACHMAD JIBRIL', 'XII - 6', '828c3938b662961ed8f775ed638b97f2', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(768, '5667', 'ANNISA ALMIRA LARASATI', 'XII - 6', 'c34a7191f6e9948068b83e7179ea3da8', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(769, '5679', 'ASAYVA VAZIO HALIL', 'XII - 6', '166cee72e93a992007a89b39eb29628b', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(770, '5689', 'BAGAS PRATAMA PUTRA', 'XII - 6', '8ba6c657b03fc7c8dd4dff8e45defcd2', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(771, '5691', 'BAYU HANAFI', 'XII - 6', '87784eca6b0dea1dff92478fb786b401', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(772, '5694', 'BINTANG ALIP UTAMA', 'XII - 6', 'b0d6951563a26ffeb2405a9653b3b422', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(773, '5698', 'CESARIO ARFATH', 'XII - 6', '7f848746fe2599dc199a75f0d02fc3d6', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(774, '5709', 'DESTA TRI PRATAMA', 'XII - 6', '63c3ddcc7b23daa1e42dc41f9a44a873', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(775, '5732', 'DWI FATIKA LESTARI', 'XII - 6', 'c19af480c40e343bbac3e2c01967b09f', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(776, '5752', 'FARID HIDAYAT', 'XII - 6', 'c7b3f097f4810cbb3c4b18c09ab893bc', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(777, '5759', 'FIRDA AFLATUL YAUMI', 'XII - 6', 'bff624c3a469dce7c45ce151902222ba', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(778, '5773', 'IBRAHIM UMAR HABIBURRAHMAN', 'XII - 6', '7e448ed9dd44e6e22442dac8e21856ae', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(779, '5776', 'IKRIMA SHABILA', 'XII - 6', 'cfd2b32e4caf5678c34b631f56c03686', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(780, '5784', 'JOHAN PRASETIO', 'XII - 6', '6157966f9b9e2f35d2266675bad8b7f8', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(781, '5791', 'KHAYLA APRILYA', 'XII - 6', '05b0afd266cc205432b8dad3f3413c28', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(782, '5827', 'MOHAMAD AYATULOH LIYAN MAULANA', 'XII - 6', '1c208ee88299e7d6d6eff86e6879384e', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(783, '5832', 'MOHAMMAD YOGA MAULANA', 'XII - 6', '677fa4059ee76333f9bb9a7920aef719', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(784, '5843', 'NADIA DESI RAHAYU', 'XII - 6', 'b4a0e0fbaa9f16d8947c49f4e610b549', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(785, '5853', 'NAUMYRA PUTRI ALLEA', 'XII - 6', '367692068f069c135b7d5a3a59e470d3', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(786, '5870', 'NURDIAN AYU WULANDARI', 'XII - 6', '1f74a54f39b3123ad272ca0a06e7463f', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(787, '5875', 'PUTRA LAKSANA WIJAYA', 'XII - 6', '767d01b4bac1a1e8824c9b9f7cc79a04', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(788, '5887', 'RANGGA HAFIZH ARKAN PURWANTO', 'XII - 6', '7cfd5df443b4eb0d69886a583b33de4c', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(789, '5894', 'REGITA CHELSEA PUTRI WIBISONO', 'XII - 6', '8973ba741e7bd6450d8023552f43728e', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(790, '5909', 'RIZKI RAMADANI', 'XII - 6', '9b16759a62899465ab21e2e79d2ef75c', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(791, '5913', 'RYNA RAHMA', 'XII - 6', '941c377c73c0efed759c993f1b859526', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(792, '5917', 'SAI`FIN NUHA', 'XII - 6', '78e092e6f3d8a7b10a82c6abd756d748', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(793, '5921', 'SANI NAILAH PUTRI', 'XII - 6', 'b59442085644532ef03417a3e5a76437', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(794, '5924', 'SAVIRA MEYLLAVAZA', 'XII - 6', 'd5fcc35c94879a4afad61cacca56192c', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(795, '5931', 'SHELVINIA FINI VEFI ALEA', 'XII - 6', 'aa1b6b26d690368d6f74a35a7daa0916', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(796, '5937', 'SILVIRA ANANTA PRAMASARI', 'XII - 6', '15a50c8ba6a0002a2fa7e5d8c0a40bd9', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(797, '5945', 'SUKMA DHANA ARIANTI', 'XII - 6', '2e907f44e0a9616314cf3d964d4e3c93', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(798, '5949', 'TAZQIYA ULIN NUHA', 'XII - 6', '0c2a1b8eada4803abd90386df241cbf3', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(799, '5954', 'WAHYU SELAMET RAHARJO', 'XII - 6', '2f0928c25ff3f884e8d2fa38835bd328', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(800, '5960', 'ZAHRA AZWA AZA MEILISA HERMAN', 'XII - 6', '233f1dd0f3f537bcb7a338ea74d63483', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(801, '5607', 'ABIL FIRDA HUSNUR RIYADI', 'XII - 7', '96bf57c6ff19504ff145e2a32991ea96', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(802, '5615', 'ADINDA SYIFAUL ISLAH', 'XII - 7', 'da647c549dde572c2c5edc4f5bef039c', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(803, '5622', 'AHMAD FAJAR ASSHIDQI', 'XII - 7', 'b4681a619cf018eed690452faeb0e94f', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(804, '5629', 'AHMAD WILDANUS SHIBA', 'XII - 7', '5c6287be4de9ff5afeaec72d54436fcf', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(805, '5630', 'AHMAD ZAINUL ROSID', 'XII - 7', 'f84d465177e84bb4e756a8319443cdcb', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(806, '5634', 'AISYA AUFA AQILA', 'XII - 7', '72bcba983cd3b0bf1d4251311d8b3772', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(807, '5636', 'AJENG SHALWA MARETA DIANIAKO', 'XII - 7', '203cb085a5c2c3faf8e4f60131817256', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(808, '5642', 'ALFARISKY PRAYUDHA', 'XII - 7', '754c32eb39c6dfd8b7c97531a459937c', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(809, '5661', 'ANDIKA FAJAR A.M', 'XII - 7', '0c4b1eeb45c90b52bfb9d07943d855ab', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(810, '5674', 'ARI SETIYOAJI', 'XII - 7', 'f1ee083baf7bb88affb4bbe77dd229f0', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(811, '5706', 'DAVINA AURELIA AGUSTINA', 'XII - 7', '99607461cdb9c26e2bd5f31b12dcf27a', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(812, '5708', 'DESI NUR\'AINI', 'XII - 7', '36165c62f7b7df72863d470d73302627', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(813, '5717', 'DIAN PUSPITA DEWI', 'XII - 7', 'dae3312c4c6c7000a37ecfb7b0aeb0e4', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(814, '5719', 'DILA AULIA ZAFIRAH', 'XII - 7', '0b33f2e8843e8b440dd8caf7086995b0', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(815, '5723', 'DINDA AGASTA SALSABILA', 'XII - 7', 'd94fd74dcde1aa553be72c1006578b23', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(816, '5727', 'DIPA SELPIANA MA\'RIFA', 'XII - 7', 'dc363817786ff182b7bc59565d864523', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(817, '5734', 'EDWARD SOO ZEI EN', 'XII - 7', '860052df4915de4d6c3deac9f7ebf5cc', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(818, '5739', 'ELSA ELVIAS', 'XII - 7', '167ccbe15cc1664c9a63c20ac4c6a55a', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(819, '5749', 'FAJAR YUNZI SYAFAAT', 'XII - 7', '0e98aeeb54acf612b9eb4e48a269814c', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(820, '5763', 'FITRA PERKASA ROHMAN', 'XII - 7', '1819020b02e926785cf3be594d957696', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(821, '5764', 'FITRI OKTAVIANA', 'XII - 7', '9715d04413f296eaf3c30c47cec3daa6', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(822, '5767', 'GENDIS RISTIANTI', 'XII - 7', 'b8b12f949378552c21f28deff8ba8eb6', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(823, '5794', 'KHOLIDATUL ZAZKIA', 'XII - 7', '5d55e7c13b0f4d7cf9d5d55d3af329c8', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(824, '5803', 'LUCKYSA RAHMADANI', 'XII - 7', '5a29503a4909fcade36b1823e7cebcf5', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(825, '5836', 'MUHAMMAD ANDIKA PRATAMA', 'XII - 7', '6fd9a99a5abed788d9afc9d52d54e91b', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(826, '5837', 'MUHAMMAD FAHRI ALFARIZI', 'XII - 7', 'd1e39c9bda5c80ac3d8ea9d658163967', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(827, '5895', 'REGITA DWI LESTARI', 'XII - 7', '33853141e0873909be88f5c3e6144cc6', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(828, '5908', 'RISKI MAULANA', 'XII - 7', '8804f94e16ba5b680e239a554a08f7d2', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(829, '5914', 'SABRINA OKTAVIANA PUTRI', 'XII - 7', 'dd5bfdeb57f7c75d400de61e99d78e2e', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(830, '5918', 'SAIFULLOH YUSUF', 'XII - 7', '15ae3b9d6286f1b2a489ea4f3f4abaed', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(831, '5919', 'SALSABILA DEVY AGUSTINE', 'XII - 7', 'cd755a6c6b699f3262bcc2aa46ab507e', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(832, '5927', 'SEPTIAN ARMADANI', 'XII - 7', 'c8afe805c097dab1f1e5bdd57f8d2931', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(833, '5606', 'A.ROISYA SYARIF', 'XII - 8', 'e6385d39ec9394f2f3a354d9d2b88eec', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(834, '5625', 'AHMAD NAUL LUZUMY', 'XII - 8', 'da94be6d2b80d736e2d13d1e3c47d035', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(835, '5635', 'AJENG OKTAVIANI', 'XII - 8', '6b493230205f780e1bc26945df7481e5', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(836, '5640', 'ALDO RIZKI  PUTRA', 'XII - 8', 'd0f5722f11a0cc839fa2ca6ea49d8585', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(837, '5644', 'ALIF FATUS SHOLEHA', 'XII - 8', '8db1d4a631a6e9a24e2c0e842e1f1772', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(838, '5648', 'ALTANTUYA ZHALIASTA IRAWAN', 'XII - 8', '84f2798f05d595273de40e3046329309', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(839, '5651', 'AMANDA DEWI LESTARI', 'XII - 8', '9b2e035e5362c96aea4c28083f02d6ff', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(840, '5688', 'AZIZA AZAHRA', 'XII - 8', '1f029c1e1abaaf0605807b7f91552d36', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(841, '5693', 'BIAN YOGA SAPUTRA', 'XII - 8', '5ba47c07b9b6a8f2718d94fa3f48fe9f', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(842, '5711', 'DEVISTA ADITYA PRATAMA', 'XII - 8', 'c10f48884c9c7fdbd9a7959c59eebea8', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(843, '5718', 'DIKA ARDIANSA', 'XII - 8', '25daeb9b3072e9c53f66a2196a92a011', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(844, '5736', 'EKA SUSANTI', 'XII - 8', '105e822401e5551873cc80584f19c649', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(845, '5742', 'ENDIN MEILANI PUTRI', 'XII - 8', 'c7be03f5d811ed29c328526ca8ab0d61', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(846, '5757', 'FIMA FATLUNA AULIA ROHMAN', 'XII - 8', 'a13e00b0854808128933f99f4955f338', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(847, '5761', 'FIRDANIA TSBITA ZAHIRAH', 'XII - 8', '81cacbb44ce8bf874ef92e1a73432c7f', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(848, '5766', 'GABRIELLA SABATINI', 'XII - 8', '3465ab6e0c21086020e382f09a482ced', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(849, '5768', 'GISTIA MEDIA ARTA RENSA', 'XII - 8', '4feb2371a1843d099b28dd419dbab1ef', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(850, '5783', 'JENYFA MAYGA PUTRI', 'XII - 8', '634841a6831464b64c072c8510c7f35c', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(851, '5801', 'LIRA AMEL RAGILLIA', 'XII - 8', '1ce4fe042832e6bd7d06697a43055373', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(852, '5812', 'MAYA TRY ARTA LITA', 'XII - 8', 'b1bc40d056bad6ec6949d9bb6fee5e84', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(853, '5822', 'MOH. ILYAS KHOIRUL KHOIR', 'XII - 8', 'fd2ae8ec902471d8956fca3486031013', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(854, '5855', 'NAURA MAYA NAZARA AZWA', 'XII - 8', 'cdfa4c42f465a5a66871587c69fcfa34', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(855, '5860', 'NAWWAL IZA', 'XII - 8', '32508f53f24c46f685870a075eaaa29c', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(856, '5868', 'NUR ALIFIA RAHMADANI', 'XII - 8', 'c41dd99a69df04044aa4e33ece9c9249', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(857, '5871', 'PALAGAN AUFA YUDHISTIRA', 'XII - 8', '07bba581a2dd8d098a3be0f683560643', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(858, '5885', 'RAIHAN ZULFAN HAFIZ', 'XII - 8', '75877cb75154206c4e65e76b88a12712', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(859, '5889', 'RAVELINO NABIL FEBIYANSYAH', 'XII - 8', 'a3bf6e4db673b6449c2f7d13ee6ec9c0', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(860, '5912', 'ROJIKIN', 'XII - 8', 'eddeb82df22554fa67c641e3f8a25566', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(861, '5916', 'SAFIRA ANAZA DWI CAHYANI', 'XII - 8', 'c5f441cd5f43eb2f2c024e1f8b5d00cd', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(862, '5928', 'SEPTIANA RAMADANI', 'XII - 8', '8ae1da0fe37c98412768453f82490da2', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(863, '5929', 'SEYNA GUSTAVIA YANSYTHASARI', 'XII - 8', '05f17e3cfa5de42020eaa6df34fb4805', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(864, '5932', 'SHERIN ZAHRA AGUSTIN', 'XII - 8', '3d191ef6e236bd1b9bdb9ff4743c47fe', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(865, '5941', 'SITI NUR HOLISAH', 'XII - 8', 'e0b60d939b4a80628dfd66b1e0bb65fa', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(866, '5957', 'WINDA AYU LESTARI', 'XII - 8', 'd5eca8dc3820cad9fe56a3bafda65ca1', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(867, '5610', 'ADAM BAGAS SATRIYA WIBOWO', 'XII - 9', '049671e28a386427e432b3370a22aae4', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(868, '5617', 'ADZAN ALSHIRAZY HAKIM', 'XII - 9', 'b56b7c12f20e05664ec7674d075c5fc0', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(869, '5632', 'AINA ULFIYA', 'XII - 9', 'a2232b5b6b17429cdff8ddc2f14ea8c9', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(870, '5638', 'ALDI FIRMAN SAPUTRA', 'XII - 9', '78b91366b15c399bd05530e96d28a530', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(871, '5658', 'ANANDA SATHYA DEWI', 'XII - 9', '8c96a3d5e1a41ee7925daa5a4dc0c25a', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(872, '5669', 'ANNISA SILVIA AGUSTIN', 'XII - 9', '8a7129b8f3edd95b7d969dfc2c8e9d9d', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(873, '5686', 'AULIA SEPTA RAHMA', 'XII - 9', '07bb5fdef1ee99d35eaccce14f8b5540', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(874, '5697', 'CAESAR FEBRY ANGKASA', 'XII - 9', 'cd3109c63bf4323e6b987a5923becb96', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(875, '5702', 'CINARA KALILA RIZKY', 'XII - 9', 'ba500f04049a8eece1e23e36ea7bbab0', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(876, '5703', 'DANANG ROSIHAN ANWAR', 'XII - 9', 'f7dd39d47c6f28f7877155ccffad0192', '2026-07-28 01:34:06', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(877, '5713', 'DEYCHA NURCAHYASARI PUTRI', 'XII - 9', '5e7d00134ba3a8b3e37edf5038bc51fc', '2026-07-28 01:34:06', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:06'),
(878, '5730', 'DIVA PUTRI LESTARI', 'XII - 9', '3ce257b311e5acf849992f5a675188e8', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(879, '5750', 'FALDAN DWIKA ALMEIZA', 'XII - 9', 'e347c51419ffb23ca3fd5050202f9c3d', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(880, '5760', 'FIRDA SUKMA AYU', 'XII - 9', '9ec51f6eb240fb631a35864e13737bca', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(881, '5780', 'INTAN SOFIANA', 'XII - 9', '294a8ed24b1ad22ec2e7efea049b8737', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(882, '5786', 'JUMA MIRANDA BERLYANTI', 'XII - 9', '77431ca7981f1f1483ae8a58bcbb6e0e', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(883, '5815', 'MELISA FITRI WULANDARI', 'XII - 9', '2835acf1b5aaa6ade0d10b4c977e912a', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(884, '5816', 'MEY KEYLA DEVI', 'XII - 9', 'ff1ced3097ccf17c1e67506cdad9ac95', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(885, '5830', 'MOHAMMAD AZRIL ILHAM', 'XII - 9', 'e520f70ac3930490458892665cda6620', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(886, '5809', 'MOHAMMAD TRISTAN PRATAMA PUTRA', 'XII - 9', 'e68a83370faacfab07ae1f8aaf5352bb', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(887, '5869', 'NUR HABIBA UTOMO', 'XII - 9', '4c26774d852f62440fc746ea4cdd57f6', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(888, '5872', 'PANJI RIZKYI DARMAWAN', 'XII - 9', '94f192dee566b018e0acf31e1f99a2d9', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(889, '5888', 'RASYIKA ELVARETTA RAMADHANI', 'XII - 9', '0a54b19a13b6712dc04d1b49215423d8', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(890, '5891', 'RAYHAN ZAHID RAMDHAN GUNAWAN', 'XII - 9', '3d9dabe52805a1ea21864b09f3397593', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(891, '5896', 'RENITA AURA ANGGRAINI', 'XII - 9', 'a914ecef9c12ffdb9bede64bb703d877', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(892, '5910', 'RIZKIYAH FITRI', 'XII - 9', '79385312dbee4c9e7270b26e4b3e1459', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(893, '5911', 'RIZQY MEDIN ADITYA', 'XII - 9', '84a955d5ff75f508ec01007bc2b9b301', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(894, '5922', 'SAPIYUL ROHIM', 'XII - 9', 'd76d8deea9c19cc9aaf2237d2bf2f785', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(895, '5925', 'SEKAR AYU WULANDARI', 'XII - 9', '979a3f14bae523dc5101c52120c535e9', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(896, '5926', 'SEPBRINA MAYCA RAHMADANI', 'XII - 9', 'a8a427afafda854020c951467cc2b4b7', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(897, '5943', 'SOFI NIZAR AKHDANI YAHYA', 'XII - 9', '9a3f54913bf27e648d1759c18d007165', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(898, '5621', 'AHMAD AUFI', 'XII - 10', '249338e601902b14d0f529fe5e6ae417', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(899, '5623', 'AHMAD FERDINAND', 'XII - 10', '44bf89b63173d40fb39f9842e308b3f9', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(900, '5628', 'AHMAD ROFIQ', 'XII - 10', '2548a4ac7ad6eddd035bced24ec6d964', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(901, '5641', 'ALFARADO BAGAS ARDIANSYAH', 'XII - 10', '48fbab00052197bc8bd943498b89dd71', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(902, '5677', 'ARMELIA DWI ANNISA', 'XII - 10', 'cca8f108b55ec9e39d7885e24f7da0af', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(903, '5681', 'ASHABUL ARHAM', 'XII - 10', 'b476828992f393a09339cf6270d30aa8', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(904, '5699', 'CHAILA RAMADHANI', 'XII - 10', '5c971edc0c2cc92fc99b5a3609450cb7', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07');
INSERT INTO `siswa` (`id`, `nis`, `nama`, `kelas`, `password`, `created_at`, `jenis_kelamin`, `tanggal_lahir`, `alamat`, `no_telepon`, `foto_profile`, `updated_at`) VALUES
(905, '5704', 'DANI FAHREZA FIRMANDIKA', 'XII - 10', 'ce11641e056f7b59aef8e9a42eaeb65b', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(906, '5726', 'DINDA SAQILA KURNIASIH', 'XII - 10', '2c8ed8587468aec2462a3914f154e570', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(907, '5729', 'DIVA MAULINDA', 'XII - 10', '024677efb8e4aee2eaeef17b54695bbe', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(908, '5743', 'ERLANGGA TIRTA AJI PRADIPTA', 'XII - 10', '31f81674a348511b990af268ca3a8391', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(909, '5775', 'IGA MELIYANTA PUTRI', 'XII - 10', '7a5200e5e9b3a893e1c2b0ccba7dd72f', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(910, '5778', 'INDRIYANI', 'XII - 10', 'ca7be8306ecc3f5fa30ff2c41e64fa7b', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(911, '5785', 'JULIA TRIKUMALA', 'XII - 10', '51425b752a0b402ed3effc83fc4bbb74', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(912, '5789', 'KASIH DWI PRATIWI', 'XII - 10', 'f0efb5f6cb4ce54821a9c5c6e1dff052', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(913, '5798', 'LELY NURMALASARI', 'XII - 10', 'ba4002d88b8860b6a684ade8357aba56', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(914, '5819', 'MOH. ARIEF ARDANU', 'XII - 10', '8e036cc193d0af59aa9b22821248292b', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(915, '5839', 'MUHAMMAD FATHUR RIZKY', 'XII - 10', 'f610a13de080fb8df6cf972fc01ad93f', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(916, '5840', 'MUHAMMAD RIFAT IBAM PRATAMA', 'XII - 10', '61d009da208a34ae155420e55f97abc7', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(917, '5847', 'NAELA FARIDOTUL AZIZA', 'XII - 10', 'd6ae00d77468471c0fba3a53a0273891', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(918, '5845', 'NAFIS RIZQIA MAZIDA', 'XII - 10', 'f41ff84e7cbd129397c11f8c5d20c0f4', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(919, '5858', 'NAWAL RIZKA HARBININGSIH', 'XII - 10', '8336041a6899d0bce657dcd29409cf7e', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(920, '5863', 'NEISYA SABILLIA ANISA PUTRI', 'XII - 10', '4722176876d0b766e2ce8328108416b9', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(921, '5864', 'NIA ROMADHONI', 'XII - 10', '7cdace91c487558e27ce54df7cdb299c', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(922, '5866', 'NIKKO RUSDIANSYAH', 'XII - 10', 'a7471fdc77b3435276507cc8f2dc2569', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(923, '5873', 'PARA HAMSA ADHA NANDA', 'XII - 10', '7ee6f2b3b68a212d3b7a4f6557eb8cc7', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(924, '5876', 'PUTRI APRILIANI DEWI', 'XII - 10', 'fdc0eb412a84fa549afe68373d9087e9', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(925, '5880', 'PUTRI WULANDARI', 'XII - 10', '055e31fa43e652cb4ab6c0ee845c8d36', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(926, '5883', 'RAGA CAPRIANZA LAZUARDI NUGROHO', 'XII - 10', 'c1cdd433a18e3949d6e64b68564a7c0d', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(927, '5933', 'SHEVA PUTRA PRADANA', 'XII - 10', 'a5d42e4024cc540befb48f466820e25f', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(928, '5944', 'SUCI HANDAYANI', 'XII - 10', '90f4760fcc9b69c13da7368c5c2917f3', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(929, '5946', 'SYDNEY ANDROMEDA RHAMADAN', 'XII - 10', '926ffc0ca56636b9e73c565cf994ea5a', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(930, '5947', 'TALITHA CANDRANINGTYAS', 'XII - 10', '9e05fb01c4c2aa78872ff38b73e69197', '2026-07-28 01:34:07', 'Perempuan', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07'),
(931, '5956', 'WILDAN NAZLI RAMADHANI', 'XII - 10', '0a4bbceda17a6253386bc9eb45240e25', '2026-07-28 01:34:07', 'Laki-laki', NULL, NULL, NULL, NULL, '2026-07-28 01:34:07');

-- --------------------------------------------------------

--
-- Struktur untuk view `rekap_pelanggaran`
--
DROP TABLE IF EXISTS `rekap_pelanggaran`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `rekap_pelanggaran`  AS SELECT `s`.`id` AS `id`, `s`.`nis` AS `nis`, `s`.`nama` AS `nama`, `s`.`kelas` AS `kelas`, count(`p`.`id`) AS `total_pelanggaran`, sum(`p`.`poin`) AS `total_poin`, max(`p`.`tanggal`) AS `terakhir_pelanggaran` FROM (`siswa` `s` left join `pelanggaran` `p` on(`s`.`id` = `p`.`siswa_id`)) GROUP BY `s`.`id` ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `catatan_pelanggaran`
--
ALTER TABLE `catatan_pelanggaran`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pelanggaran_id` (`pelanggaran_id`),
  ADD KEY `siswa_nis` (`siswa_nis`);

--
-- Indeks untuk tabel `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `session_id` (`session_id`);

--
-- Indeks untuk tabel `informasi_bk`
--
ALTER TABLE `informasi_bk`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `konseling`
--
ALTER TABLE `konseling`
  ADD PRIMARY KEY (`id`),
  ADD KEY `siswa_id` (`siswa_id`);

--
-- Indeks untuk tabel `master_pelanggaran`
--
ALTER TABLE `master_pelanggaran`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `jenis_pelanggaran` (`jenis_pelanggaran`);

--
-- Indeks untuk tabel `pelanggaran`
--
ALTER TABLE `pelanggaran`
  ADD PRIMARY KEY (`id`),
  ADD KEY `siswa_id` (`siswa_id`);

--
-- Indeks untuk tabel `rekap_pelanggaran_siswa`
--
ALTER TABLE `rekap_pelanggaran_siswa`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `siswa_nis` (`siswa_nis`);

--
-- Indeks untuk tabel `riwayat_kelas`
--
ALTER TABLE `riwayat_kelas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_nis_tahun` (`nis`,`tahun_ajaran`);

--
-- Indeks untuk tabel `siswa`
--
ALTER TABLE `siswa`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nis` (`nis`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `catatan_pelanggaran`
--
ALTER TABLE `catatan_pelanggaran`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `chat_messages`
--
ALTER TABLE `chat_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=106;

--
-- AUTO_INCREMENT untuk tabel `informasi_bk`
--
ALTER TABLE `informasi_bk`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `konseling`
--
ALTER TABLE `konseling`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT untuk tabel `master_pelanggaran`
--
ALTER TABLE `master_pelanggaran`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT untuk tabel `pelanggaran`
--
ALTER TABLE `pelanggaran`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `rekap_pelanggaran_siswa`
--
ALTER TABLE `rekap_pelanggaran_siswa`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `riwayat_kelas`
--
ALTER TABLE `riwayat_kelas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `siswa`
--
ALTER TABLE `siswa`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=932;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `catatan_pelanggaran`
--
ALTER TABLE `catatan_pelanggaran`
  ADD CONSTRAINT `catatan_pelanggaran_ibfk_1` FOREIGN KEY (`pelanggaran_id`) REFERENCES `master_pelanggaran` (`id`),
  ADD CONSTRAINT `catatan_pelanggaran_ibfk_2` FOREIGN KEY (`siswa_nis`) REFERENCES `siswa` (`nis`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `konseling`
--
ALTER TABLE `konseling`
  ADD CONSTRAINT `konseling_ibfk_1` FOREIGN KEY (`siswa_id`) REFERENCES `siswa` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `pelanggaran`
--
ALTER TABLE `pelanggaran`
  ADD CONSTRAINT `pelanggaran_ibfk_1` FOREIGN KEY (`siswa_id`) REFERENCES `siswa` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `rekap_pelanggaran_siswa`
--
ALTER TABLE `rekap_pelanggaran_siswa`
  ADD CONSTRAINT `rekap_pelanggaran_siswa_ibfk_1` FOREIGN KEY (`siswa_nis`) REFERENCES `siswa` (`nis`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
