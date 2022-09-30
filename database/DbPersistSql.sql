-- ---------------------------------------------------------------------------
-- SQL script for the SQL module in DbPersist.
-- 
-- Version: 1
-- Date:    30.09.2022
--
-- GitHub:  https://github.com/bkristoff/dbpersist/
-- ---------------------------------------------------------------------------



-- ***************************************************************************
-- DROPPING TABLES
--
-- ***************************************************************************
DROP TABLE IF EXISTS SqlQuestionTrans;

DROP TABLE IF EXISTS SqlAnswer;
DROP TABLE IF EXISTS SqlQuestion;



-- ***************************************************************************
-- CREATING TABLES
--
-- ***************************************************************************


-- ---------------------------------------------------------------------------
-- Table SqlQuestion
--
-- ---------------------------------------------------------------------------
CREATE TABLE SqlQuestion
(
  Id           INTEGER AUTO_INCREMENT,
  IsPublic     BOOLEAN NOT NULL,
  ExerciseId   INTEGER,
  DiffLevelNum SMALLINT NOT NULL,
  CONSTRAINT SqlQuestionPK PRIMARY KEY (Id),
  CONSTRAINT SqlQuestionExerciseFK FOREIGN KEY (ExerciseId) 
    REFERENCES Exercise (Id) ON DELETE SET NULL,
  CONSTRAINT SqlQuestionDiffLevelFK FOREIGN KEY (DiffLevelNum)
    REFERENCES DiffLevel (LevelNum)
);


-- ---------------------------------------------------------------------------
-- Table SqlAnswer
--
-- ---------------------------------------------------------------------------
CREATE TABLE SqlAnswer
(
  Id       INTEGER AUTO_INCREMENT,
  Answer   TEXT,
  StoredAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  Points   INTEGER,
  UserId   INTEGER,
  QId      INTEGER,
  CONSTRAINT SqlAnswerPK PRIMARY KEY (Id),
  CONSTRAINT SqlAnswerSqlQuestionFK FOREIGN KEY (QId) 
    REFERENCES SqlQuestion (Id),
  CONSTRAINT SqlAnswerUserFK FOREIGN KEY (UserId) 
    REFERENCES AppUser (Id)
);




-- ***************************************************************************
-- TRANSLATION TABLES
--
-- The database has an extra translation table for every table that contains
-- multilingual (textual) data. Such a table T has a translation table TTrans.
-- If T has primary key K, TTrans has primary key LangCode+K, where LangCode
-- is a foreign key referencing Lang. TTrans contains every multilingual
-- column from T.
-- ***************************************************************************


-- ---------------------------------------------------------------------------
-- Table SqlQuestionTrans
-- ---------------------------------------------------------------------------
CREATE TABLE SqlQuestionTrans
(
  LangCode CHAR(2),
  Id       INTEGER,
  QText    TEXT NOT NULL,
  Solution TEXT,
  CONSTRAINT SqlQuestionTransPK PRIMARY KEY (LangCode, Id),
  CONSTRAINT SqlQuestionTransLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code),
  CONSTRAINT SqlQuestionTransQuestionFK FOREIGN KEY (Id) 
    REFERENCES Question (Id)
);
