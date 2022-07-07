-- ---------------------------------------------------------------------------
-- SQL script for the quiz module in DbPersist.
-- 
-- Version: 1
-- Date:    07.07.2022
--
-- GitHub:  https://github.com/bkristoff/dbpersist/
-- ---------------------------------------------------------------------------



-- ***************************************************************************
-- DROPPING TABLES
--
-- Drop tables if they exists.
-- ***************************************************************************
DROP TABLE IF EXISTS AlternativeTrans;
DROP TABLE IF EXISTS QuestionTrans;
DROP TABLE IF EXISTS QuizTrans;
DROP TABLE IF EXISTS ContextTrans;

DROP TABLE IF EXISTS QuestionAnswer;
DROP TABLE IF EXISTS QuizAnswer;
DROP TABLE IF EXISTS Alternative;
DROP TABLE IF EXISTS AlternativeTemplate;
DROP TABLE IF EXISTS QuestionInQuiz;
DROP TABLE IF EXISTS Question;
DROP TABLE IF EXISTS QuestionTemplate;
DROP TABLE IF EXISTS Quiz;
DROP TABLE IF EXISTS Context;


-- ***************************************************************************
-- CREATING TABLES
--
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
  Id           INTEGER AUTO_INCREMENT,
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
  Id           INTEGER AUTO_INCREMENT,
  DiffLevelNum SMALLINT NOT NULL,  
  CONSTRAINT QuizPK PRIMARY KEY (Id),
  CONSTRAINT QuizDiffLevelFK FOREIGN KEY (DiffLevelNum)
    REFERENCES DiffLevel (LevelNum)
);


-- ---------------------------------------------------------------------------
-- Table QuestionTemplate
--
-- A question template can be combined with an exercise and then used to
-- generate a (concrete) question.
--
-- ---------------------------------------------------------------------------
CREATE TABLE QuestionTemplate
(
  Id       INTEGER AUTO_INCREMENT,
  QText    TEXT,
  LangCode CHAR(2),
  CONSTRAINT QuestionTemplatePK PRIMARY KEY (Id),
  CONSTRAINT QuestionTemplateLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code)
);


-- ---------------------------------------------------------------------------
-- Table Question
--
-- ---------------------------------------------------------------------------
CREATE TABLE Question
(
  Id INTEGER AUTO_INCREMENT,
  CONSTRAINT QuestionPK PRIMARY KEY (Id)
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
-- Table AlternativeTemplate
--
-- ---------------------------------------------------------------------------
CREATE TABLE AlternativeTemplate
(
  QTId     INTEGER,
  AId      CHAR(1),
  AText    TEXT,
  Correct  TINYINT NOT NULL,
  LangCode CHAR(2),
  CONSTRAINT AlternativeTemplatePK PRIMARY KEY (QTId, AId),
  CONSTRAINT AlternativeTemplateQuestionTemplateFK FOREIGN KEY (QTId)
    REFERENCES QuestionTemplate (Id),
  CONSTRAINT AlternativeTemplateLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code)
);


-- ---------------------------------------------------------------------------
-- Table Alternative
--
-- ---------------------------------------------------------------------------
CREATE TABLE Alternative
(
  QId     INTEGER,
  AId     CHAR(1),
  Correct TINYINT NOT NULL,
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
  Id         INTEGER AUTO_INCREMENT,
  QId        INTEGER,
  UserId     INTEGER,
  AnsweredAt DATETIME,
  Points     INTEGER,
  CONSTRAINT QuizAnswerPK PRIMARY KEY (Id),
  CONSTRAINT QuizAnswerQuizFK FOREIGN KEY (QId) 
    REFERENCES Quiz (Id),
  CONSTRAINT QuizAnswerUserFK FOREIGN KEY (UserId) 
    REFERENCES AppUser (Id)
);


-- ---------------------------------------------------------------------------
-- Table QuestionAnswer
--
-- ---------------------------------------------------------------------------
CREATE TABLE QuestionAnswer
(
  Id          INTEGER AUTO_INCREMENT,
  QuizId      INTEGER,
  QuestionId  INTEGER,
  AId         CHAR(1),
  CONSTRAINT QuestionAnswerPK PRIMARY KEY (Id),
  CONSTRAINT QuestionAnswerQuestionInQuizFK FOREIGN KEY (QuizId, QuestionId) 
    REFERENCES QuestionInQuiz (QuizId, QuestionId),
  CONSTRAINT QuizAnswerAlternativeFK FOREIGN KEY (QuestionId, AId) 
    REFERENCES Alternative (QId, AId)
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
  CONSTRAINT QuizTransPK PRIMARY KEY (LangCode, Id),
  CONSTRAINT QuizTransLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code),
  CONSTRAINT QuizTransQuizFK FOREIGN KEY (Id) 
    REFERENCES Quiz (Id)
);


-- ---------------------------------------------------------------------------
-- Table QuestionTrans
-- ---------------------------------------------------------------------------
CREATE TABLE QuestionTrans
(
  LangCode CHAR(2),
  Id       INTEGER,
  QText    TEXT NOT NULL,
  CId      INTEGER NOT NULL,
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
-- ---------------------------------------------------------------------------
CREATE TABLE AlternativeTrans
(
  LangCode CHAR(2),
  QId      INTEGER,
  AId      CHAR(1),
  AText    TEXT NOT NULL,
  CONSTRAINT AlternativeTransPK PRIMARY KEY (LangCode, QId, AId),
  CONSTRAINT AlternativeTransLangFK FOREIGN KEY (LangCode) 
    REFERENCES Lang (Code),
  CONSTRAINT AlternativetTransAlternativeFK FOREIGN KEY (QId, AId) 
    REFERENCES Alternative (QId, AId)
);
