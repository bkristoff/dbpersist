-- ---------------------------------------------------------------------------
-- SQL script for the core tables in DbPersist.
-- 
-- Version: 1
-- Date:    07.07.2022
--
-- ---------------------------------------------------------------------------



-- ***************************************************************************
-- CREATE DATABASE
-- 
-- ***************************************************************************

-- DROP DATABASE IF EXISTS dbpersist1;
-- 
-- CREATE DATABASE IF NOT EXISTS dbpersist1
--   DEFAULT CHARACTER SET = 'utf8mb4';
-- 
-- USE dbpersist1;



-- ***************************************************************************
-- DELETE TABLES
--
-- Delete tables if they exists.
-- ***************************************************************************

DROP TABLE IF EXISTS ExerciseTrans;
DROP TABLE IF EXISTS AchievementTrans;
DROP TABLE IF EXISTS MessageTrans;
DROP TABLE IF EXISTS UserLevelTrans;

DROP TABLE IF EXISTS UserGotAchievement;
DROP TABLE IF EXISTS CheckLog;
DROP TABLE IF EXISTS Answer;
DROP TABLE IF EXISTS Login;
DROP TABLE IF EXISTS SynonymPair;
DROP TABLE IF EXISTS Exercise;
DROP TABLE IF EXISTS AppUser;
DROP TABLE IF EXISTS Achievement;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS Avatar;
DROP TABLE IF EXISTS UserLevel;
DROP TABLE IF EXISTS DiffLevel;
DROP TABLE IF EXISTS WordType;
DROP TABLE IF EXISTS Notation;
DROP TABLE IF EXISTS UserType;
DROP TABLE IF EXISTS Lang;



-- ***************************************************************************
-- CREATE TABLES
--
-- ***************************************************************************

-- ---------------------------------------------------------------------------
-- Table Lang
--
-- List of supported languages.
-- Language codes as defined in ISO 639-1.
-- ---------------------------------------------------------------------------
CREATE TABLE Lang
(
  Code CHAR(2),
  Name VARCHAR(255) NOT NULL,
  CONSTRAINT LangPK PRIMARY KEY (Code)
);


-- ---------------------------------------------------------------------------
-- Table UserType
--
-- ---------------------------------------------------------------------------
CREATE TABLE UserType
(
  Name     VARCHAR(50),
  CONSTRAINT UserTypePK PRIMARY KEY (Name)
);


-- ---------------------------------------------------------------------------
-- Table Notation
--
-- ---------------------------------------------------------------------------
CREATE TABLE Notation
(
  Name     VARCHAR(50),
  CONSTRAINT NotationPK PRIMARY KEY (Name)
);


-- ---------------------------------------------------------------------------
-- Table WordType
--
-- ---------------------------------------------------------------------------
CREATE TABLE WordType
(
  Name     VARCHAR(50),
  CONSTRAINT WordTypePK PRIMARY KEY (Name)
);


-- ---------------------------------------------------------------------------
-- Table DiffLevel
--
-- The difficulty levels in the app; will probably go from 1 to 10.
-- ---------------------------------------------------------------------------
CREATE TABLE DiffLevel
(
  LevelNum SMALLINT,
  CONSTRAINT DiffLevelPK PRIMARY KEY (LevelNum)
);


-- ---------------------------------------------------------------------------
-- Table UserLevel
--
-- The user levels in the app; will probably go from 1 to 5.
-- UserLevel=n can solve exercises at DiffLevel=n*2 without too much help?
-- ---------------------------------------------------------------------------
CREATE TABLE UserLevel
(
  LevelNum    SMALLINT,
  CONSTRAINT UserLevelPK PRIMARY KEY (LevelNum)
);


-- ---------------------------------------------------------------------------
-- Table Avatar
--
-- Contains filenames for avatar images.
-- All image files are stored in the same folder.
-- Filenames do not include the path.
-- A number of avatars belongs to a given user level.
-- ---------------------------------------------------------------------------
CREATE TABLE Avatar
(
  Id       SMALLINT     AUTO_INCREMENT,
  FileName VARCHAR(255) NOT NULL,
  LevelNum SMALLINT     NOT NULL,
  CONSTRAINT AvatarPK PRIMARY KEY (Id),
  CONSTRAINT AvatarDiffLevelFK FOREIGN KEY (LevelNum)
    REFERENCES DiffLevel (LevelNum)
);


-- ---------------------------------------------------------------------------
-- Table Message
--
-- Contains formative feedback message keys.
-- Feedback (template) texts are stored in MessageTrans.
-- ---------------------------------------------------------------------------
CREATE TABLE Message
(
  MsgKey        VARCHAR(30),
  CONSTRAINT MessagePK PRIMARY KEY (MsgKey)
);


-- ---------------------------------------------------------------------------
-- Table Achievement
--
-- Achievements are given to appreciate volume training.
-- They are symbolized with images shown on user's profile pages.
--
-- A given achievement has a compound condition. The user must have:
--   solved a minimum of VolumeCond exercises
--   at difficulty level LevelCond or above,
--   with average success percent above SuccessCond,
--   using the help button less than HelpCond times on average
--   (for these exercises).
-- ---------------------------------------------------------------------------
CREATE TABLE Achievement
(
  Id          SMALLINT     AUTO_INCREMENT,
  ImgFileName VARCHAR(255) NOT NULL,
  LevelCond   SMALLINT     NOT NULL,
  VolumeCond  SMALLINT     NOT NULL,
  SuccessCond SMALLINT     NOT NULL,
  HelpCond    SMALLINT     NOT NULL,
  CONSTRAINT AchievementPK PRIMARY KEY (Id)
);


-- ---------------------------------------------------------------------------
-- Table AppUser
--
-- ---------------------------------------------------------------------------
CREATE TABLE AppUser
(
  Id        INTEGER      AUTO_INCREMENT,
  UserName  VARCHAR(255) NOT NULL,
  Email     VARCHAR(255) NOT NULL,
  CreatedAt TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Password  VARCHAR(255) NOT NULL,
  UserType  VARCHAR(50),
  LangCode  CHAR(2),
  Verified  BOOLEAN      NOT NULL,
  Notation  VARCHAR(50),
  LevelNum  SMALLINT     NOT NULL,
  AvatarId  SMALLINT,
  CONSTRAINT AppUserPK PRIMARY KEY (Id),
  CONSTRAINT AppUserUserTypeFK FOREIGN KEY (UserType) 
    REFERENCES UserType (Name) ON DELETE SET NULL,
  CONSTRAINT AppUserNotationFK FOREIGN KEY (Notation) 
    REFERENCES Notation (Name) ON DELETE SET NULL,
  CONSTRAINT AppUserUserLevelFK FOREIGN KEY (LevelNum) 
    REFERENCES UserLevel (LevelNum),
  CONSTRAINT AppUserAvatarFK FOREIGN KEY (AvatarId) 
    REFERENCES Avatar (Id) ON DELETE SET NULL
);


-- ---------------------------------------------------------------------------
-- Table Exercise
--
-- ---------------------------------------------------------------------------
CREATE TABLE Exercise (
  Id           INTEGER      AUTO_INCREMENT,
  IsPublic     BOOLEAN      NOT NULL,
  AuthorId     INTEGER,
  DiffLevelNum SMALLINT     NOT NULL,
  CONSTRAINT ExercisePK PRIMARY KEY (Id),
  CONSTRAINT ExerciseAppUserFK FOREIGN KEY (AuthorId) 
    REFERENCES AppUser (Id) ON DELETE SET NULL,
  CONSTRAINT ExerciseDiffLevelFK FOREIGN KEY (DiffLevelNum)
    REFERENCES DiffLevel (LevelNum)
);


-- ---------------------------------------------------------------------------
-- Table SynonymPair
--
-- A pair of words can be synonyms:
--   in all contexts (ExId and NameType is null)
--   in a given exercise (ExId is not null)
--   when used as entities, attributes or relationships (NameType is not null)
-- The table is symmetric; if (w1, w2) is a row, so is (w2, w1).
-- ---------------------------------------------------------------------------
CREATE TABLE SynonymPair
(
  Id         INTEGER AUTO_INCREMENT,
  Word1      VARCHAR(255) NOT NULL,
  Word2      VARCHAR(255) NOT NULL,
  ExId       INTEGER,
  NameType   VARCHAR(50),
  LangCode   CHAR(2),
  CONSTRAINT SynonymPairPK PRIMARY KEY (Id),
  CONSTRAINT SynonymPairExerciseFK FOREIGN KEY (ExId) 
    REFERENCES Exercise (Id) ON DELETE SET NULL,
  CONSTRAINT SynonymPairWordTypeFK FOREIGN KEY (NameType) 
    REFERENCES WordType (Name) ON DELETE SET NULL,
  CONSTRAINT SynonymPairLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code)
);


-- ---------------------------------------------------------------------------
-- Table Login
--
-- ---------------------------------------------------------------------------
CREATE TABLE Login
(
  Id         INTEGER   AUTO_INCREMENT,
  SignedInAt TIMESTAMP NOT NULL,
  UserId     INTEGER   NOT NULL,
  CONSTRAINT LoginPK PRIMARY KEY (Id),
  CONSTRAINT LoginAppUser FOREIGN KEY (UserId) 
    REFERENCES AppUser (Id) ON DELETE CASCADE
);


-- ---------------------------------------------------------------------------
-- Table Answer
--
-- ---------------------------------------------------------------------------
CREATE TABLE Answer
(
  Id             INTEGER     AUTO_INCREMENT,
  Answer         JSON        NOT NULL,
  Notation       VARCHAR(50) NOT NULL,
  Submitted      BOOLEAN     NOT NULL,
  StoredAt       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ModelPoints    INTEGER     NOT NULL,
  NumberOfChecks SMALLINT    NOT NULL,
  HintPenalty    INTEGER     NOT NULL,
  UserId         INTEGER     NOT NULL,
  ExId           INTEGER     NOT NULL,
  LangCode       CHAR(2)     NOT NULL,
  CONSTRAINT AnswerPK PRIMARY KEY (Id),
  CONSTRAINT AnswerNotationFK FOREIGN KEY (Notation) 
    REFERENCES Notation (Name),
  CONSTRAINT AnswerUserFK FOREIGN KEY (UserId) 
    REFERENCES AppUser (Id) ON DELETE CASCADE,
  CONSTRAINT AnswerExerciseFK FOREIGN KEY (ExId) 
    REFERENCES Exercise (Id) ON DELETE CASCADE,
  CONSTRAINT AnswerLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code)
);


-- ---------------------------------------------------------------------------
-- Table CheckLog
--
-- ---------------------------------------------------------------------------
CREATE TABLE CheckLog
(
  Id             INTEGER     AUTO_INCREMENT,
  Answer         JSON        NOT NULL,
  Notation       VARCHAR(50) NOT NULL,
  CheckedAt      DATETIME    NOT NULL,
  ModelPoints    INTEGER     NOT NULL,
  NumberOfChecks SMALLINT    NOT NULL,
  HintPenalty    INTEGER     NOT NULL,
  AnswerId       INTEGER     NOT NULL,
  CONSTRAINT AnswerPK PRIMARY KEY (Id),
  CONSTRAINT CheckLogAnswerFK FOREIGN KEY (AnswerId) 
    REFERENCES Answer (Id) ON DELETE CASCADE
);


-- ---------------------------------------------------------------------------
-- Table UserGotAchievement
--
-- ---------------------------------------------------------------------------
CREATE TABLE UserGotAchievement
(
  Id         INTEGER   AUTO_INCREMENT,
  UserId     INTEGER   NOT NULL,
  AchievId   SMALLINT  NOT NULL,
  ReceivedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT UserGotAchievementPK PRIMARY KEY (Id),
  CONSTRAINT UserGotAchievementAppUser FOREIGN KEY (UserId) 
    REFERENCES AppUser (Id) ON DELETE CASCADE,
  CONSTRAINT UserGotAchievementAchievementFK FOREIGN KEY (AchievId) 
    REFERENCES Achievement (Id)
);



-- ***************************************************************************
-- TRANSLATION TABLES
--
-- The database has an extra translation table for some tables that contains
-- multilingual (textual) data. Such a table T has a translation table TTrans.
-- If T has primary key K, TTrans has primary key LangCode+K, where LangCode
-- is a foreign key referencing Lang. TTrans contains every multilingual
-- column from T.
-- ***************************************************************************


-- ---------------------------------------------------------------------------
-- Table UserLevelTrans
-- 
-- Descriptions can be Newbie, Beginner, Experienced, Expert, Guru.
-- ---------------------------------------------------------------------------
CREATE TABLE UserLevelTrans
(
  LangCode CHAR(2),
  LevelNum SMALLINT,
  Name     VARCHAR(255) NOT NULL,
  CONSTRAINT UserLevelTransPK PRIMARY KEY (LangCode, LevelNum),
  CONSTRAINT UserLevelTransLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code),
  CONSTRAINT UserLevelTransUserLevelFK FOREIGN KEY (LevelNum) 
    REFERENCES UserLevel (LevelNum)
);


-- ---------------------------------------------------------------------------
-- Table MessageTrans
-- ---------------------------------------------------------------------------
CREATE TABLE MessageTrans
(
  LangCode      CHAR(2),
  MsgKey        VARCHAR(30),
  Definition    LONGTEXT,
  Stats         LONGTEXT,
  ShortFeedback LONGTEXT,
  LongFeedback  LONGTEXT,
  CONSTRAINT MessageTransPK PRIMARY KEY (LangCode, MsgKey),
  CONSTRAINT MessageTransLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code),
  CONSTRAINT MessageTransMessageFK FOREIGN KEY (MsgKey) 
    REFERENCES Message (MsgKey)
);


-- ---------------------------------------------------------------------------
-- Table AchievementTrans
-- ---------------------------------------------------------------------------
CREATE TABLE AchievementTrans
(
  LangCode    CHAR(2),
  Id          SMALLINT,
  Title       VARCHAR(255) NOT NULL,
  Description VARCHAR(255) NOT NULL,
  CONSTRAINT AchievementTransPK PRIMARY KEY (LangCode, Id),
  CONSTRAINT AchievementTransLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code),
  CONSTRAINT AchievementTransAchievementFK FOREIGN KEY (Id) 
    REFERENCES Achievement (Id)
);


-- ---------------------------------------------------------------------------
-- Table ExerciseTrans
--
-- Description is the scenario text (HTML).
-- Solution contains the solution data model (JSON).
-- FalseNames contains lists of inadequate entity, attribute and 
--   relationship names (JSON).
-- Hint contains an exercise specific help text (HTML).
-- ---------------------------------------------------------------------------
CREATE TABLE ExerciseTrans
(
  LangCode    CHAR(2),
  Id          INTEGER,
  Title       VARCHAR(255),
  Description TEXT,
  Solution    JSON,
  FalseNames  JSON,
  Hint        TEXT,
  CONSTRAINT ExerciseTransPK PRIMARY KEY (LangCode, Id),
  CONSTRAINT ExerciseTransLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code),
  CONSTRAINT ExerciseTransExerciseFK FOREIGN KEY (Id) 
    REFERENCES Exercise (Id)
);

  
-- ***************************************************************************
-- END OF SCRIPT
-- ***************************************************************************
