SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

CREATE DATABASE IF NOT EXISTS `Luna` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;

USE `Luna`;

DROP TABLE IF EXISTS `servers`;
DROP TABLE IF EXISTS `igloos`;
DROP TABLE IF EXISTS `postcards`;
DROP TABLE IF EXISTS `puffles`;
DROP TABLE IF EXISTS `stamps`;
DROP TABLE IF EXISTS `redemption`;
DROP TABLE IF EXISTS `users`;

CREATE TABLE IF NOT EXISTS `servers` (
  `servPort` int(11) NOT NULL,
  `servName` varchar(20) NOT NULL,
  `servIP` mediumtext NOT NULL,
  `curPop` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`servName`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `igloos` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(20) NOT NULL,
  `igloo` int(10) NOT NULL DEFAULT '1',
  `floor` int(10) NOT NULL DEFAULT '0',
  `music` int(10) NOT NULL DEFAULT '0',
  `furniture` longtext NOT NULL,
  `ownedFurns` longtext NOT NULL,
  `ownedIgloos` longtext NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `puffles` (
  `ID` int(11) NOT NULL,
  `puffleID` mediumint(2) NOT NULL,
  `puffleName` varchar(10) NOT NULL,
  `puffleType` mediumint(2) NOT NULL,
  `puffleEnergy` mediumint(3) NOT NULL DEFAULT '100',
  `puffleHealth` mediumint(3) NOT NULL DEFAULT '100',
  `puffleRest` mediumint(3) NOT NULL DEFAULT '100',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `postcards` (
  `toUser` int(11) NOT NULL,
  `fromID` int(11) NOT NULL,
  `fromName` varchar(20) NOT NULL,
  `cardType` int(11) NOT NULL,
  `details` longtext NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `isRead` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`toUser`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1; 

CREATE TABLE IF NOT EXISTS `stamps` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(20) NOT NULL,
  `stamps` longtext NOT NULL,
  `cover` longtext NOT NULL,
  `restamps` longtext NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `users` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(20) NOT NULL,
  `nickname` varchar(20) NOT NULL,
  `password` varchar(250) NOT NULL,
  `loginKey` varchar(30) NOT NULL,
  `ipAddr` longtext NOT NULL,
  `age` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `bitMask` tinyint(1) NOT NULL DEFAULT '1',
  `isBanned` varchar(10) NOT NULL,
  `banCount` tinyint(1) NOT NULL DEFAULT '0',
  `items` longtext NOT NULL,
  `head` int(10) NOT NULL DEFAULT '0',
  `face` int(10) NOT NULL DEFAULT '0',
  `neck` int(10) NOT NULL DEFAULT '0',
  `body` int(10) NOT NULL DEFAULT '0',
  `hand` int(10) NOT NULL DEFAULT '0',
  `feet` int(10) NOT NULL DEFAULT '0',
  `photo` varchar(10) NOT NULL DEFAULT '0',
  `flag` varchar(10) NOT NULL DEFAULT '0',
  `colour` varchar(10) NOT NULL DEFAULT '1',
  `coins` int(11) NOT NULL,
  `isMuted` tinyint(1) NOT NULL DEFAULT '0',
  `isStaff` tinyint(11) NOT NULL DEFAULT '0',
  `isAdmin` tinyint(1) NOT NULL DEFAULT '0',
  `rank` tinyint(1) NOT NULL DEFAULT '1',  
  `buddies` longtext NOT NULL,
  `ignored` longtext NOT NULL,
  `isEPF` tinyint(1) NOT NULL DEFAULT '0',
  `fieldOPStatus` tinyint(1) NOT NULL DEFAULT '0',
  `medalsUsed` int(10) NOT NULL DEFAULT '50',
  `medalsUnused` int(10) NOT NULL DEFAULT '100',
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;