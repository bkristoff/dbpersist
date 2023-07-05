-- ---------------------------------------------------------------------------
-- SQL script for DbPersist.
-- 
-- Version: 2.0
-- Date:    04.07.2023
-- Author:  Bjørn Kristoffersen
--
-- GitHub:  https://github.com/bkristoff/dbpersist/
--
-- This SQL script creates the database tables for DbPersist.
-- It is divided into three parts:
--   1. Core tables
--   2. ER module tables
--   3. Quiz + SQL + Concept module tables

-- Translation tables:
-- The database has an extra translation table for some tables that contains
-- multilingual data. Such a table T has a translation table TTrans.
-- If T has primary key K, TTrans has primary key LangCode+K, where LangCode
-- is a foreign key referencing Lang. TTrans contains every multilingual
-- column from T.
-- ---------------------------------------------------------------------------


-- ***************************************************************************
-- CREATE DATABASE
-- ***************************************************************************

-- DROP DATABASE IF EXISTS dbpersist;
-- 
-- CREATE DATABASE IF NOT EXISTS dbpersist
--   DEFAULT CHARACTER SET = 'utf8mb4';
-- USE dbpersist;



-- ***************************************************************************
-- DELETE TABLES
--
-- Delete tables if they exists.
-- Useful when running the script repeatedly (after changes).
-- ***************************************************************************

-- Old SQL module (TO BE REMOVED)
DROP TABLE IF EXISTS SqlQuestionTrans;
DROP TABLE IF EXISTS SqlAnswer;
DROP TABLE IF EXISTS SqlQuestion;

-- QUIZ + SQL + CONCEPT module
DROP TABLE IF EXISTS AlternativeTrans;
DROP TABLE IF EXISTS QuestionTrans;
DROP TABLE IF EXISTS QuizTrans;
DROP TABLE IF EXISTS ContextTrans;
DROP TABLE IF EXISTS QuestionAnswer;
DROP TABLE IF EXISTS QuizAnswer;
DROP TABLE IF EXISTS Alternative;
DROP TABLE IF EXISTS QuestionInQuiz;
DROP TABLE IF EXISTS Question;
DROP TABLE IF EXISTS Quiz;
DROP TABLE IF EXISTS Context;

-- ER module
DROP TABLE IF EXISTS ExerciseTrans;
DROP TABLE IF EXISTS CheckLog;
DROP TABLE IF EXISTS Answer;
DROP TABLE IF EXISTS Exercise;

-- CORE tables
DROP TABLE IF EXISTS AchievementTrans;
DROP TABLE IF EXISTS MessageTrans;
DROP TABLE IF EXISTS UserLevelTrans;
DROP TABLE IF EXISTS UserGotAchievement;
DROP TABLE IF EXISTS Login;
DROP TABLE IF EXISTS AppUser;
DROP TABLE IF EXISTS Notation;
DROP TABLE IF EXISTS Achievement;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS Avatar;
DROP TABLE IF EXISTS UserLevel;
DROP TABLE IF EXISTS DiffLevel;
DROP TABLE IF EXISTS UserType;
DROP TABLE IF EXISTS Lang;



-- ***************************************************************************
-- CREATE CORE TABLES
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
  Name VARCHAR(50),
  CONSTRAINT UserTypePK PRIMARY KEY (Name)
);


-- ---------------------------------------------------------------------------
-- Table DiffLevel
--
-- The difficulty levels in the app; go from 1 to 10.
--
-- TODO Remove columns Name + Points?
-- ---------------------------------------------------------------------------
CREATE TABLE DiffLevel
(
  LevelNum SMALLINT,
  -- Name   VARCHAR(50) NOT NULL,
  Points INTEGER NOT NULL,
  CONSTRAINT DiffLevelPK PRIMARY KEY (LevelNum)
);


-- ---------------------------------------------------------------------------
-- Table UserLevel
--
-- The user levels in the app; go from 1 to 5.
-- Descriptions can be Newbie, Beginner, Experienced, Expert, Guru.
-- UserLevel=n can solve exercises at DiffLevel=n*2 without too much help.
--
-- TODO Remove columns Description + PointsRequired?
-- ---------------------------------------------------------------------------
CREATE TABLE UserLevel
(
  LevelNum    SMALLINT,
  -- Description    VARCHAR(255),
  PointsRequired INTEGER,
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
  Id       SMALLSERIAL,
  FileName VARCHAR(255) NOT NULL,
  LevelNum SMALLINT     NOT NULL,
  CONSTRAINT AvatarPK PRIMARY KEY (Id),
  CONSTRAINT AvatarDiffLevelFK FOREIGN KEY (LevelNum)
    REFERENCES DiffLevel (LevelNum)
);


-- ---------------------------------------------------------------------------
-- Table Message
--
-- Contains formative feedback message templates.
-- ---------------------------------------------------------------------------
CREATE TABLE Message
(
  MsgKey     VARCHAR(30),
  Definition VARCHAR(255),
  CONSTRAINT MessagePK PRIMARY KEY (MsgKey)
);


-- ---------------------------------------------------------------------------
-- Table Achievement
--
-- Achievements are given to appreciate volume training.
-- The achievement image is displayed on the user's profile page.
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
  Id          SMALLSERIAL,
  ImgFileName VARCHAR(255) NOT NULL,
  LevelCond   SMALLINT     NOT NULL,
  VolumeCond  SMALLINT     NOT NULL,
  SuccessCond SMALLINT     NOT NULL,
  HelpCond    SMALLINT     NOT NULL,
  CONSTRAINT AchievementPK PRIMARY KEY (Id)
);


-- ---------------------------------------------------------------------------
-- Table Notation
--
-- ---------------------------------------------------------------------------
CREATE TABLE Notation
(
  Name VARCHAR(50),
  CONSTRAINT NotationPK PRIMARY KEY (Name)
);


-- ---------------------------------------------------------------------------
-- Table AppUser
--
-- ---------------------------------------------------------------------------
CREATE TABLE AppUser
(
  Id         SERIAL,
  UserName   VARCHAR(255) NOT NULL UNIQUE,
  Email      VARCHAR(255) NOT NULL UNIQUE,
  CreatedAt  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Password   VARCHAR(255) NOT NULL,
  UserType   VARCHAR(50)  NOT NULL,
  LangCode   CHAR(2)      NOT NULL,
  Verified   BOOLEAN      NOT NULL,
  Notation   VARCHAR(50),
  LevelNum   SMALLINT     NOT NULL,
  AvatarId   SMALLINT,
  CONSTRAINT AppUserPK PRIMARY KEY (Id),
  CONSTRAINT AppUserUserTypeFK FOREIGN KEY (UserType) 
    REFERENCES UserType (Name),
  CONSTRAINT AppUserLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code),
  CONSTRAINT AppUserNotationFK FOREIGN KEY (Notation) 
      REFERENCES Notation (Name) ON DELETE SET NULL,
  CONSTRAINT AppUserUserLevelFK FOREIGN KEY (LevelNum) 
      REFERENCES UserLevel (LevelNum),
  CONSTRAINT AppUserAvatarFK FOREIGN KEY (AvatarId) 
    REFERENCES Avatar (Id) ON DELETE SET NULL
);


-- ---------------------------------------------------------------------------
-- Table Login
--
-- ---------------------------------------------------------------------------
CREATE TABLE Login
(
  Id         SERIAL,
  SignedInAt TIMESTAMP NOT NULL,
  UserId     INTEGER   NOT NULL,
  CONSTRAINT LoginPK PRIMARY KEY (Id),
  CONSTRAINT LoginAppUser FOREIGN KEY (UserId) 
    REFERENCES AppUser (Id) ON DELETE CASCADE
);


-- ---------------------------------------------------------------------------
-- Table UserGotAchievement
--
-- ---------------------------------------------------------------------------
CREATE TABLE UserGotAchievement
(
  Id         SERIAL,
  UserId     INTEGER   NOT NULL,
  AchievId   SMALLINT  NOT NULL,
  ReceivedAt TIMESTAMP NOT NULL,
  CONSTRAINT UserGotAchievementPK PRIMARY KEY (Id),
  CONSTRAINT UserGotAchievementAppUser FOREIGN KEY (UserId) 
    REFERENCES AppUser (Id) ON DELETE CASCADE,
  CONSTRAINT UserGotAchievementAchievementFK FOREIGN KEY (AchievId) 
    REFERENCES Achievement (Id)
);


-- ---------------------------------------------------------------------------
-- Table UserLevelTrans
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
--
-- ---------------------------------------------------------------------------
CREATE TABLE MessageTrans
(
  LangCode      CHAR(2),
  MsgKey        VARCHAR(30),
  Stats         VARCHAR(255),
  ShortFeedback TEXT,
  LongFeedback  TEXT,
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



-- ***************************************************************************
-- CREATE TABLES FOR ER MODULE
-- ***************************************************************************

-- ---------------------------------------------------------------------------
-- Table Exercise
--
-- ---------------------------------------------------------------------------
CREATE TABLE Exercise (
  Id           SERIAL,
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
-- Table Answer
--
-- ---------------------------------------------------------------------------
CREATE TABLE Answer
(
  Id             SERIAL,
  Answer         JSON         NOT NULL,
  Notation       VARCHAR(50),
  Submitted      BOOLEAN      NOT NULL,
  StoredAt       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ModelPoints    INTEGER      NOT NULL,
  NumberOfChecks SMALLINT     NOT NULL,
  HintPenalty    INTEGER      NOT NULL,
  UserId         INTEGER      NOT NULL,
  ExId           INTEGER      NOT NULL,
  LangCode       CHAR(2),
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
  Id             SERIAL,
  Answer         JSON         NOT NULL,
  Notation       VARCHAR(50),
  CheckedAt      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ModelPoints    INTEGER      NOT NULL,
  NumberOfChecks SMALLINT     NOT NULL,
  HintPenalty    INTEGER      NOT NULL,
  AnswerId       INTEGER      NOT NULL,
  CONSTRAINT CheckLogPK PRIMARY KEY (Id),
  CONSTRAINT CheckLogNotationFK FOREIGN KEY (Notation) 
    REFERENCES Notation (Name),
  CONSTRAINT CheckLogAnswerFK FOREIGN KEY (AnswerId) 
    REFERENCES Answer (Id) ON DELETE CASCADE
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
-- CREATE TABLES FOR QUIZ + SQL + CONCEPT MODULES
-- ***************************************************************************

-- ---------------------------------------------------------------------------
-- Table Context
--
-- A context has a (HTML) text describing a case or giving some background
-- to a given question, together with an image. Often the text will describe
-- an example database and the image will display the content of some of
-- the tables. ImgFile is a simple file name (not including the full path).
-- ---------------------------------------------------------------------------
CREATE TABLE Context
(
  Id SERIAL ,
  CONSTRAINT ContextPK PRIMARY KEY (Id)
);


-- ---------------------------------------------------------------------------
-- Table Quiz
--
-- A quiz contains a set of questions. It has a title and is assigned a
-- difficulty level.
-- ---------------------------------------------------------------------------
CREATE TABLE Quiz
(
  Id           SERIAL,
  DiffLevelNum SMALLINT,
  ExerciseId   INTEGER, 
  CONSTRAINT QuizPK PRIMARY KEY (Id),
  CONSTRAINT QuizDiffLevelFK FOREIGN KEY (DiffLevelNum)
    REFERENCES DiffLevel (LevelNum),
  CONSTRAINT QuizExerciseFK FOREIGN KEY (ExerciseId) 
    REFERENCES Exercise (Id) ON DELETE SET NULL
);


-- ---------------------------------------------------------------------------
-- Table Question
--
-- ---------------------------------------------------------------------------
CREATE TABLE Question
(
  Id SERIAL,
  DiffLevelNum SMALLINT NOT NULL,
  CONSTRAINT QuestionPK PRIMARY KEY (Id),
  CONSTRAINT QuestionDiffLevelFK FOREIGN KEY (DiffLevelNum)
    REFERENCES DiffLevel (LevelNum)
);


-- ---------------------------------------------------------------------------
-- Table QuestionInQuiz
--
-- ---------------------------------------------------------------------------
CREATE TABLE QuestionInQuiz
(
  QuizId      INTEGER,
  QuestionId  INTEGER,
  Pos         INTEGER,
  CONSTRAINT QuestionInTest PRIMARY KEY (QuizId, QuestionId),
  CONSTRAINT QuestionInQuizQuestionFK FOREIGN KEY (QuestionId)
    REFERENCES Question (Id),
  CONSTRAINT QuestionInQuizQuizFK FOREIGN KEY (QuizId)
    REFERENCES Quiz (Id)
);


-- ---------------------------------------------------------------------------
-- Table Alternative
--
-- Used to represent alternatives for multiple choice questions.
-- For concept questions, the table is not used.
-- ---------------------------------------------------------------------------
CREATE TABLE Alternative
(
  QId     INTEGER,
  AId     CHAR(1),
  Correct SMALLINT NOT NULL,
  CONSTRAINT AlternativePK PRIMARY KEY (QId, AId),
  CONSTRAINT AlternativeQuestionFK FOREIGN KEY (QId)
    REFERENCES Question (Id)
);


-- ---------------------------------------------------------------------------
-- Table QuizAnswer
--
-- ---------------------------------------------------------------------------
CREATE TABLE QuizAnswer
(
  Id         SERIAL,
  QId        INTEGER,
  UserId     INTEGER,
  AnsweredAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  Points     INTEGER,
  Submitted  BOOLEAN NOT NULL,
  CONSTRAINT QuizAnswerPK PRIMARY KEY (Id),
  CONSTRAINT QuizAnswerQuizFK FOREIGN KEY (QId) 
    REFERENCES Quiz (Id),
  CONSTRAINT QuizAnswerUserFK FOREIGN KEY (UserId) 
    REFERENCES AppUser (Id)
);


-- ---------------------------------------------------------------------------
-- Table QuestionAnswer
--
-- For multiple choice questions, the user's answer is stored in column AId.
-- For SQL questions, the user's answer is stored in column Answer.
-- For concept questions, the table is not used.
-- ---------------------------------------------------------------------------
CREATE TABLE QuestionAnswer
(
  Id           SERIAL,
  QuizAnswerId INTEGER,
  QuizId       INTEGER,
  QuestionId   INTEGER,
  AId          CHAR(1),
  Answer       TEXT,
  CONSTRAINT QuestionAnswerPK PRIMARY KEY (Id),
  CONSTRAINT QuestionAnswerQuizAnswerFK FOREIGN KEY (QuizAnswerId) 
    REFERENCES QuizAnswer (Id),
  CONSTRAINT QuestionAnswerQuestionInQuizFK FOREIGN KEY (QuizId, QuestionId) 
    REFERENCES QuestionInQuiz (QuizId, QuestionId),
  CONSTRAINT QuizAnswerAlternativeFK FOREIGN KEY (QuestionId, AId) 
    REFERENCES Alternative (QId, AId)
);


-- ---------------------------------------------------------------------------
-- Table ContextTrans
-- ---------------------------------------------------------------------------
CREATE TABLE ContextTrans
(
  LangCode CHAR(2),
  Id       INTEGER,
  CText    TEXT NOT NULL,
  ImgFile  VARCHAR(255),
  CONSTRAINT ContextTransPK PRIMARY KEY (LangCode, Id),
  CONSTRAINT ContextTransLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code),
  CONSTRAINT ContextTransContextFK FOREIGN KEY (Id) 
    REFERENCES Context (id)
);


-- ---------------------------------------------------------------------------
-- Table QuizTrans
-- ---------------------------------------------------------------------------
CREATE TABLE QuizTrans
(
  LangCode CHAR(2),
  Id       INTEGER,
  Title    VARCHAR(100) NOT NULL,
  QuizType VARCHAR(50),
  CONSTRAINT QuizTransPK PRIMARY KEY (LangCode, Id),
  CONSTRAINT QuizTransLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code),
  CONSTRAINT QuizTransQuizFK FOREIGN KEY (Id) 
    REFERENCES Quiz (Id)
);


-- ---------------------------------------------------------------------------
-- Table QuestionTrans
--
-- For multiple choice questions, QSolution is NULL.
-- For SQL/concept questions, QSolution holds the correct answer/definition.
-- ---------------------------------------------------------------------------
CREATE TABLE QuestionTrans
(
  LangCode  CHAR(2),
  Id        INTEGER,
  QText     TEXT     NOT NULL,
  QSolution TEXT     NOT NULL,
  CId       INTEGER  NOT NULL,
  CONSTRAINT QuestionTransPK PRIMARY KEY (LangCode, Id),
  CONSTRAINT QuestionTransLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code),
  CONSTRAINT QuestionTransQuestionFK FOREIGN KEY (Id) 
    REFERENCES Question (Id),
  CONSTRAINT QuestionTransContextTransFK FOREIGN KEY (LangCode, CId) 
    REFERENCES ContextTrans (LangCode, Id)
);


-- ---------------------------------------------------------------------------
-- Table AlternativeTrans
--
-- Used to represent alternatives for multiple choice questions.
-- For SQL/concept questions, the table is not used.
-- ---------------------------------------------------------------------------
CREATE TABLE AlternativeTrans
(
  LangCode CHAR(2),
  QId      INTEGER,
  AId      CHAR(1),
  AText    TEXT     NOT NULL,
  CONSTRAINT AlternativeTransPK PRIMARY KEY (LangCode, QId, AId),
  CONSTRAINT AlternativeTransLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code),
  CONSTRAINT AlternativetTransAlternativeFK FOREIGN KEY (QId, AId) 
    REFERENCES Alternative (QId, AId)
);
