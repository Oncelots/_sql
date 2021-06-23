﻿--
--
--  ██████╗  ██████╗     ███████╗██╗   ██╗ █████╗ ██╗         ████████╗ █████╗ ██████╗ ██╗     ███████╗███████╗
--  ██╔══██╗██╔═══██╗    ██╔════╝██║   ██║██╔══██╗██║         ╚══██╔══╝██╔══██╗██╔══██╗██║     ██╔════╝██╔════╝
--  ██████╔╝██║   ██║    █████╗  ██║   ██║███████║██║            ██║   ███████║██████╔╝██║     █████╗  ███████╗
--  ██╔══██╗██║   ██║    ██╔══╝  ╚██╗ ██╔╝██╔══██║██║            ██║   ██╔══██║██╔══██╗██║     ██╔══╝  ╚════██║
--  ██████╔╝╚██████╔╝    ███████╗ ╚████╔╝ ██║  ██║███████╗       ██║   ██║  ██║██████╔╝███████╗███████╗███████║
--  ╚═════╝  ╚═════╝     ╚══════╝  ╚═══╝  ╚═╝  ╚═╝╚══════╝       ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚══════╝
--   
USE [RETCRM_APPLICATIONS]
GO

--############# 01 HLAVNI TABULKA #############			OK
--DROP TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM 	
CREATE TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM (
		ID INT IDENTITY(100,1) PRIMARY KEY	NOT NULL
		, PERIOD DATE						NOT NULL
		, ID_PERSON VARCHAR(5)				NOT NULL
		, APPROVED_RESTRUCTURING NUMERIC(5, 2)	NULL
		, DECLINED_RESTRUCTURING NUMERIC(5, 2)	NULL
		, OBLIGATION_LOAN NUMERIC(5, 2)			NULL
		, PHONE_COMMUNICATION_1 NUMERIC(5, 2)	NULL
		, PHONE_COMMUNICATION_2 NUMERIC(5, 2)	NULL
		, WRITTEN_COMMUNICATION_1 NUMERIC(5, 2)	NULL
		, WRITTEN_COMMUNICATION_2 NUMERIC(5, 2)	NULL
		, PHD_CALL_1 NUMERIC(5, 2)				NULL
		, PHD_CALL_2 NUMERIC(5, 2)				NULL
		, DOCUMENTATION_CHECK NUMERIC(5, 2)		NULL
		, INSOLVENCY NUMERIC(5, 2)				NULL
		, COURT_FEE NUMERIC(5, 2)				NULL
		, MAILBOX_1 NUMERIC(5, 2)				NULL
		, MAILBOX_2 NUMERIC(5, 2)				NULL
		, WATCHLISTS NUMERIC(5, 2)				NULL
		, EVAL_TOTAL NUMERIC(5, 2)				NULL
		, EVAL_TOTAL_AFTER_KO NUMERIC(5, 2)		NULL
		, KO_IDENTITY_CHECK_CALL_1 BIT			NULL	-- KO 100% NA KVALITU
		, KO_IDENTITY_CHECK_CALL_2 BIT			NULL	-- KO 100% NA KVALITU
		, KO_IDENTITY_CHECK_MAIL_1 BIT			NULL	-- KO 100% NA KVALITU
		, KO_IDENTITY_CHECK_MAIL_2 BIT			NULL	-- KO 100% NA KVALITU
		, KO_INCENTIVES NUMERIC(5, 2)			NULL	-- KO DLE 
		, PUBLIC_EVALUATION TINYINT			NOT NULL
		, IN_INCENTIVES BIT					NOT NULL	-- JDE DO INCNETIV
		, LAST_UPDATE DATETIME2(0)			NOT NULL
);
GO
-- TRIGGERS
CREATE OR ALTER TRIGGER TR_UPDATE_EVAL_BO_FORM
ON RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_FORM INT, @EVAL_TOTAL NUMERIC(5, 2), @KO BIT, @DELENEC NUMERIC(5, 2), @DELITEL NUMERIC(5, 2)

	SELECT @ID_FORM = INSERTED.ID
			, @DELENEC = (ISNULL(APPROVED_RESTRUCTURING, 0)
							+ ISNULL(DECLINED_RESTRUCTURING, 0)
							+ ISNULL(OBLIGATION_LOAN, 0)
							+ ISNULL(PHONE_COMMUNICATION_1, 0)
							+ ISNULL(PHONE_COMMUNICATION_2, 0)
							+ ISNULL(WRITTEN_COMMUNICATION_1, 0)
							+ ISNULL(WRITTEN_COMMUNICATION_2, 0)
							+ ISNULL(PHD_CALL_1, 0)
							+ ISNULL(PHD_CALL_2, 0)
							+ ISNULL(DOCUMENTATION_CHECK, 0)
							+ ISNULL(INSOLVENCY, 0)
							+ ISNULL(COURT_FEE, 0)
							+ ISNULL(MAILBOX_1, 0)
							+ ISNULL(MAILBOX_2, 0) 
							+ ISNULL(WATCHLISTS, 0))											-- DELENEC
			, @DELITEL= (CASE WHEN APPROVED_RESTRUCTURING IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN DECLINED_RESTRUCTURING IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN OBLIGATION_LOAN IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN PHONE_COMMUNICATION_1 IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN PHONE_COMMUNICATION_2 IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN WRITTEN_COMMUNICATION_1 IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN WRITTEN_COMMUNICATION_2 IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN PHD_CALL_1 IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN PHD_CALL_2 IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN DOCUMENTATION_CHECK IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN INSOLVENCY IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN COURT_FEE IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN MAILBOX_1 IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN MAILBOX_2 IS NULL THEN 0 ELSE 1 END
							+ CASE WHEN WATCHLISTS IS NULL THEN 0 ELSE 1 END)
			, @KO = CASE WHEN KO_IDENTITY_CHECK_CALL_1 IS NULL THEN 1 ELSE 0 END
					* CASE WHEN KO_IDENTITY_CHECK_CALL_2 IS NULL THEN 1 ELSE 0 END
					* CASE WHEN KO_IDENTITY_CHECK_MAIL_1 IS NULL THEN 1 ELSE 0 END
					* CASE WHEN KO_IDENTITY_CHECK_MAIL_2 IS NULL THEN 1 ELSE 0 END
	FROM INSERTED

	IF @DELITEL > 0
	BEGIN
	UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET EVAL_TOTAL = @DELENEC / @DELITEL, EVAL_TOTAL_AFTER_KO = @DELENEC / @DELITEL * @KO
	WHERE ID = @ID_FORM
	END
END
GO
		 
--############# 02 SCHVÁLENÉ RESTRU #############		OK
--DROP TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_APPROVED_RESTRUCTURING
CREATE TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_APPROVED_RESTRUCTURING (
		ID INT IDENTITY(100,1) PRIMARY KEY	NOT NULL
		, ID_FORM INT						NOT NULL
		, ID_EVALUATOR VARCHAR(5)			NOT NULL
		, IN_EVAL BIT							NULL
		, LOAN_NUMBER VARCHAR(15)				NULL
		, LOAN_TYPE VARCHAR(10)					NULL
		, VALUE_01 NUMERIC(5, 2)				NULL	-- ÚVĚR SPLACEN ŘÁDNĚ MIN. 6 MĚSÍCŮ OD POSKYTNUTÍ
		, VALUE_02 NUMERIC(5, 2)				NULL	-- V PŘEDHOZÍCH 2 LETECH NEBYLA POSKYTNUTA RESTRUKTURALIZACE ÚVĚRU
		, VALUE_03 NUMERIC(5, 2)				NULL	-- H, SD NEBO R NEJSOU V INSOLVENČNÍM ŘÍZENÍ: H, SD NEBO R NEMAJÍ AKTIVNÍ UPOZORNNĚNÍ V CRM
		, VALUE_04 NUMERIC(5, 2)				NULL	-- RESTRU KALKULÁTOR VYPLNĚN DLE PRAVIDEL
		, VALUE_05 NUMERIC(5, 2)				NULL	-- DOLOŽEN DOKLAD (OPODSTATNĚNÁ ŽÁDOST O RESTRU)
		, VALUE_06 NUMERIC(5, 2)				NULL	-- SPRÁVNA A ÚPLNÁ ŽÁDOST O RESTRU
		, VALUE_07 NUMERIC(5, 2)				NULL	-- DODATEK ŘÁDNĚ PODEPSÁN KLIENTEM I BANKOU
		, VALUE_08 NUMERIC(5, 2)				NULL	-- PROVEDENY ÚPRAVY SPLÁTEK VE SB V SOULADU S DODATKEM
		, VALUE_09 NUMERIC(5, 2)				NULL	-- DODATEK ZADÁN DO SMLUV VE SB
		, VALUE_10 NUMERIC(5, 2)				NULL	-- ZADÁNO AKTIVNÍ VAROVÁNÍ DO APLIKACE CRM (SCHVÁLENÁ RESTRU S PLATNOSTÍ 60M)
		, VALUE_11 NUMERIC(5, 2)				NULL	-- DO STARBANKU ZADÁNA FORBEARANCE
		, VALUE_12 NUMERIC(5, 2)				NULL	-- DOKUMENTACE NAHRANÁ DO BRASILU
		, EVAL_TOTAL NUMERIC(5, 2)				NULL
		, COMMENT VARCHAR(MAX)					NULL
		, LAST_UPDATE DATETIME2(0)				NULL
);
GO
-- TRIGGERS
CREATE OR ALTER TRIGGER TR_INSERT_UPDATE_APPROVED_RESTRUCTURING
ON RETCRM_APPLICATIONS.DBO.EVAL_BO_APPROVED_RESTRUCTURING
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_FORM INT, @EVAL_TOTAL NUMERIC(5, 2), @IN_EVAL BIT

	SELECT @ID_FORM = INSERTED.ID_FORM, @EVAL_TOTAL = INSERTED.EVAL_TOTAL, @IN_EVAL = INSERTED.IN_EVAL
	FROM INSERTED


	IF @IN_EVAL = 1
		BEGIN
		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET APPROVED_RESTRUCTURING = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		WHERE ID = @ID_FORM
		END
	ELSE
		BEGIN
		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET APPROVED_RESTRUCTURING = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		WHERE ID = @ID_FORM
		END

END
GO

-- /TRIGGERS

--############# 03 ZAMÍTNUTÉ RESTRU #############		OK
--DROP TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_DECLINED_RESTRUCTURING
CREATE TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_DECLINED_RESTRUCTURING (
		ID INT IDENTITY(100,1) PRIMARY KEY	NOT NULL
		, ID_FORM INT						NOT NULL
		, ID_EVALUATOR VARCHAR(5)			NOT NULL
		, IN_EVAL BIT							NULL
		, LOAN_NUMBER VARCHAR(15)				NULL
		, LOAN_TYPE VARCHAR(10)					NULL
		, VALUE_01 NUMERIC(5, 2)				NULL	/*	ZKONTROLOVÁNA KO KRITERIA (
															ÚVĚR SPLACEN ŘÁDNĚ MIN. 6 MĚSÍCŮ OD POSKYTNUTÍ
															V PŘEDCHOZÍCH 2 LETECH NEBYLA POSKYTNUTA RESTRU
															H, SD NEBO R NEJSOU V INSOLVENČNÍM ŘÍZENÍ ANI NEMAJÍ AKTIVNÍ UPOZORNĚNÍ V CRM
														*/
		, VALUE_02 NUMERIC(5, 2)				NULL	-- RESTRU KALKULÁTOR VYPLNĚN DLE PRAVIDEL
		, VALUE_03 NUMERIC(5, 2)				NULL	/* ROZHODNUTÍ O ZAMÍTNUTÍ VYDÁNO V SOULADU S PRAVIDLY PRO ZAMÍTNUTÍ ŽÁDOSTI (
														   KLIENT SPLNIL MIN. JEDNO KO KRITÉRIEUM
														   VÝSLEDEK SCORINGU => ZAMÍTNUTO
														   POSKYTNUTÍ RESTRU NEVYŘEŠÍ AKTUÁLNÍ SITUACI KLIENTA
														   KLIENT SE ZADLUŽUJE VE FINANČNÍ TÍSTNI
														   PŘÍPADNĚ DALŠÍ NASTAVENÁ PRAVIDLA		
														*/
		, VALUE_04 NUMERIC(5, 2)				NULL	-- SPRÁVNÁ A ÚPLNÁ ŽÁDOST O RESTRU
		, VALUE_05 NUMERIC(5, 2)				NULL	-- ZADÁNO AKTIVNÍ VAROVÁNÍ DO APLIKACE CRM (ZAMÍTNUTÁ RESTRUKTURALIZACE
		, VALUE_06 NUMERIC(5, 2)				NULL	-- KLIENT O ZAMÍTNUTÍ INFORMOVÁN PÍSEMNĚ
		, VALUE_07 NUMERIC(5, 2)				NULL	-- DOKUMENTACE VLOŽENA DO BRASIL - ZAMÍTNUTÍ
		, VALUE_08 NUMERIC(5, 2)				NULL	-- DOKUMENTACE VLOŽENA DO BRASIL - SCOREKARTA
		, EVAL_TOTAL NUMERIC(5, 2)				NULL
		, COMMENT VARCHAR(MAX)					NULL
		, LAST_UPDATE DATETIME2(0)				NULL
);
GO
-- TRIGGERS
CREATE OR ALTER TRIGGER TR_INSERT_UPDATE_DECLINED_RESTRUCTURING
ON RETCRM_APPLICATIONS.DBO.EVAL_BO_DECLINED_RESTRUCTURING
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_FORM INT, @EVAL_TOTAL NUMERIC(5, 2), @IN_EVAL BIT

	SELECT @ID_FORM = INSERTED.ID_FORM, @EVAL_TOTAL = INSERTED.EVAL_TOTAL, @IN_EVAL = INSERTED.IN_EVAL
	FROM INSERTED

	IF @IN_EVAL = 1
		BEGIN
		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET DECLINED_RESTRUSTURING = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		WHERE ID = @ID_FORM
		END
	ELSE
		BEGIN
		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET DECLINED_RESTRUSTURING = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		WHERE ID = @ID_FORM
	END
END
GO
-- /TRIGGERS

--############# 04 ZÁVAZKOVÝ ÚVĚR #############
--DROP TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_OBLIGATION_LOAN
CREATE TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_OBLIGATION_LOAN (
		ID INT IDENTITY(100,1) PRIMARY KEY	NOT NULL
		, ID_FORM INT						NOT NULL
		, ID_EVALUATOR VARCHAR(5)			NOT NULL
		, IN_EVAL BIT							NULL
		, LOAN_NUMBER VARCHAR(15)				NULL
		, LOAN_TYPE VARCHAR(10)					NULL
		, VALUE_01 NUMERIC(5, 2)				NULL	-- KONTROLA INSOLVENCE PROVEDENA
		, VALUE_02 NUMERIC(5, 2)				NULL	-- KONTROLA KATIVNÍCH VAROVÁNÍ V CRM PROVEDENA
		, VALUE_03 NUMERIC(5, 2)				NULL	-- DOLOŽENA SPRÁVNÁ A ÚPPLNÁ ŽÁDOST O ZU (JE LI NEZBYTNÉ I S NOVÝM SOUHLASEM ZPRACOVÁNÍ OS. ÚDAJŮ)
		, VALUE_04 NUMERIC(5, 2)				NULL	-- MODELACE ZU V CPS+ PROVEDENA V SOULADU S PLATNÝMI POSTUPY (ÚVĚR DO 70 000KČ MAX 60 SPLÁTEK)
		, VALUE_05 NUMERIC(5, 2)				NULL	/* SMLUVNÍ DOKUMENTACE PODEPSÁNA ŽÁDNĚ KLIENTEM I BANKOU 
														   (PŘEDSMLUVNÍ INFORMACE, PŘÍKAZ K ČERPÁNÍ, VÝPOVĚĎ KTK NEBO KK, SMLOUVA O ZÁVAZKOVÉM ÚVĚRU)
														*/
		, VALUE_06 NUMERIC(5, 2)				NULL	-- PROVEDENO SPRÁVNÉ ČERPÁNÍ ZU
		, VALUE_07 NUMERIC(5, 2)				NULL	-- ZADÁNO VAROVÁNÍ DO APLIKACE CRM
		, EVAL_TOTAL NUMERIC(5, 2)				NULL
		, COMMENT VARCHAR(MAX)					NULL
		, LAST_UPDATE DATETIME2(0)				NULL
);
GO

-- TRIGGERS
CREATE OR ALTER TRIGGER TR_INSERT_UPDATE_OBLIGATION_LOAN
ON RETCRM_APPLICATIONS.DBO.EVAL_BO_OBLIGATION_LOAN
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_FORM INT, @EVAL_TOTAL NUMERIC(5, 2), @IN_EVAL BIT

	SELECT @ID_FORM = INSERTED.ID_FORM, @EVAL_TOTAL = INSERTED.EVAL_TOTAL, @IN_EVAL = INSERTED.IN_EVAL
	FROM INSERTED

	IF @IN_EVAL = 1
		BEGIN
		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET OBLIGATION_LOAN = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		WHERE ID = @ID_FORM
		END
	ELSE
		BEGIN
		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET OBLIGATION_LOAN = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		WHERE ID = @ID_FORM
	END
END
GO
-- /TRIGGERS

--############# 05 HOVOR S KLIENTEM #############
--DROP TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_PHONE_COMMUNICATION
CREATE TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_PHONE_COMMUNICATION (
		ID INT IDENTITY(100,1) PRIMARY KEY	NOT NULL
		, ID_FORM INT						NOT NULL
		, ID_EVALUATOR VARCHAR(5)			NOT NULL
		, IN_EVAL BIT							NULL
		, EVAL_ORDER TINYINT				NOT NULL
		, PHONE_NUMBER VARCHAR(15)				NULL
		, CALL_DATE DATETIME2(0)				NULL
		, KO_VALIDATION BIT						NULL	-- KO OVĚŘENÍ (-100% KVALITY) - JMÉNO + PŘÍJMENÍ KLIENTA + DATUM NAROZENÍ + 2 ČÍSLA ZA LOMÍTKEM RČ 
		, VALUE_01 NUMERIC(5, 2)				NULL	-- SDĚLENÍ DŮVODŮ VOLÁNÍ
		, VALUE_02 NUMERIC(5, 2)				NULL	-- SDĚLENÍ PODMÍNEK SCHVÁLENÍ
		, VALUE_03 NUMERIC(5, 2)				NULL	-- DOPADY NA KLIENTA - UPOZORNĚNÍ NA CCB * DOPAD V ČS V JINÉ BANCE
		, VALUE_04 NUMERIC(5, 2)				NULL	-- DOPORČENÍ NÁSLEDNÉHO POSTUPU + REKAPITULACE
		, KO_ARROGANCE BIT						NULL	-- KO AROGANCE (-100% NA HOVOR) - IRONIE, AROGANCE, SARKASMUS, JÍZLIVOST 
		, VALUE_05 NUMERIC(5, 2)				NULL	-- PŘEDSTAVENÍ / ROZLOUČENÍ - ZAČÁTEK HOVORU
		, VALUE_06 NUMERIC(5, 2)				NULL	-- PŘEKONÁNÍ NÁMITEK - VHODNÁ ARGUMENTACE, REAKCE NA DOTAZY
		, VALUE_07 NUMERIC(5, 2)				NULL	-- VEDENÍ HOVORU - TEMPO, HOVOROVÉ VÝRAZY, DIALOG S KLIENTEM, SCHOPNOST VÉST HOVOR, ZAMĚŘENÍ NA CÍL
		, VALUE_08 NUMERIC(5, 2)				NULL	-- LOAJALITA - VŮČI KLIENTOVI A ČESKÉ SPOŘITELNĚ
		, VALUE_09 NUMERIC(5, 2)				NULL	-- SPRÁVNÉ A PRAVIDVÉ INFORMACE - REAKCE NA DOTAZY KLIENTA
		, EVAL_TOTAL NUMERIC(5, 2)				NULL	
		, COMMENT VARCHAR(MAX)					NULL
		, LAST_UPDATE DATETIME2(0)			NOT NULL
);
GO
-- TRIGGERS
CREATE OR ALTER TRIGGER TR_INSERT_UPDATE_PHONE_COMMUNICATION
ON RETCRM_APPLICATIONS.DBO.EVAL_BO_PHONE_COMMUNICATION
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_FORM INT, @EVAL_TOTAL NUMERIC(5, 2), @IN_EVAL BIT, @EVAL_ORDER TINYINT

	SELECT @ID_FORM = INSERTED.ID_FORM, @EVAL_TOTAL = INSERTED.EVAL_TOTAL, @IN_EVAL = INSERTED.IN_EVAL, @EVAL_ORDER = INSERTED.EVAL_ORDER
	FROM INSERTED

	IF @IN_EVAL = 1
		BEGIN
		IF @EVAL_ORDER = 1
			BEGIN
			UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET PHONE_COMMUNICATION_1 = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
			WHERE ID = @ID_FORM
			END
		ELSE
			BEGIN
			UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET PHONE_COMMUNICATION_2 = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
			WHERE ID = @ID_FORM
			END
		END
	ELSE
		BEGIN
		IF @EVAL_ORDER = 1
			BEGIN
			UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET PHONE_COMMUNICATION_1 = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
			WHERE ID = @ID_FORM
			END
		ELSE
			BEGIN
			UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET PHONE_COMMUNICATION_2 = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
			WHERE ID = @ID_FORM
			END
		END
END
GO
-- /TRIGGERS

--############# 06 EMAIL/DOPIS #############
--DROP TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_WRITTEN_COMMUNICATION
CREATE TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_WRITTEN_COMMUNICATION (
		ID INT IDENTITY(100,1) PRIMARY KEY	NOT NULL
		, ID_FORM INT						NOT NULL
		, ID_EVALUATOR VARCHAR(5)			NOT NULL
		, IN_EVAL BIT							NULL
		, EVAL_ORDER TINYINT				NOT NULL
		, CLIENT_IDENTIFIER VARCHAR(100)	NOT NULL
		, COMMUNICATION_TYPE VARCHAR(10)	NOT NULL
		, KO_VALIDATION BIT						NULL	-- KO OVĚŘENÍ (-100% KVALITY) - KLIENTOVI SDĚLENY KONKRÉTNÍ INFORMACE I PŘESTO, ŽE NEMÁ OVĚŘENÝ EMAIL 
		, KO_FAULT BIT							NULL	-- KO CHYBA (-50% NA MAIL) - KLIENTOVI SDĚLENO, ŽE MU NEMŮŽEME POSKYTNOUT INFORMACE I PŘESTO, ŽE MÁ OVĚŘENÝ MAIL
		, VALUE_01 NUMERIC(5, 2)				NULL	-- OSLOVENÍ / ROZLOUČENÍ
		, VALUE_02 NUMERIC(5, 2)				NULL	-- SPRÁVNÉ A ÚPLNÉ ÚDAJE
		, VALUE_03 NUMERIC(5, 2)				NULL	-- DOPORUČENÍ (ŘEŠENÍ)
		, VALUE_04 NUMERIC(5, 2)				NULL	-- ZÁVĚR - KONTAKTY PRO KLIENTA
		, VALUE_05 NUMERIC(5, 2)				NULL	-- SPISOVNÁ ČEŠTINA A VOLBA SLOV
		, VALUE_06 NUMERIC(5, 2)				NULL	-- MAZÁNÍ OS. ÚDAJŮ
		, VALUE_07 NUMERIC(5, 2)				NULL	-- LAJALITA K BANCE
		, VALUE_08 NUMERIC(5, 2)				NULL	-- VYSVĚTLOVÁNÍ BANKOVNÍCH POJMŮ
		, VALUE_09 NUMERIC(5, 2)				NULL	-- KVALITNÍ ODPOVĚĎ - NEJDE O STROHOU ODPOVĚĎ
		, EVAL_TOTAL NUMERIC(5, 2)				NULL
		, COMMENT VARCHAR(MAX)					NULL
		, LAST_UPDATE DATETIME2(0)			NOT NULL
);
GO
-- TRIGGERS
CREATE OR ALTER TRIGGER TR_INSERT_UPDATE_WRITTEN_COMMUNICATION
ON RETCRM_APPLICATIONS.DBO.EVAL_BO_WRITTEN_COMMUNICATION
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_FORM INT, @EVAL_TOTAL NUMERIC(5, 2), @IN_EVAL BIT, @EVAL_ORDER TINYINT

	SELECT @ID_FORM = INSERTED.ID_FORM, @EVAL_TOTAL = INSERTED.EVAL_TOTAL, @IN_EVAL = INSERTED.IN_EVAL, @EVAL_ORDER = INSERTED.EVAL_ORDER
	FROM INSERTED


	IF @IN_EVAL = 1
	BEGIN
		IF @EVAL_ORDER = 1
			BEGIN
			UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET WRITTEN_COMMUNICATION_1 = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
			WHERE ID = @ID_FORM
			END
		ELSE
			BEGIN
			UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET WRITTEN_COMMUNICATION_2 = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
			WHERE ID = @ID_FORM
			END
		END
	ELSE
		BEGIN
		IF @EVAL_ORDER = 1
			BEGIN
			UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET WRITTEN_COMMUNICATION_1 = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
			WHERE ID = @ID_FORM
			END
		ELSE
			BEGIN
			UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET WRITTEN_COMMUNICATION_2 = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
			WHERE ID = @ID_FORM
			END
		END
	END
GO
-- /TRIGGERS

--############# 07 PRODUKTOVÝ HELPDESK #############
--DROP TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_PHD
CREATE TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_PHD (
		ID INT IDENTITY(100,1) PRIMARY KEY	NOT NULL
		, ID_FORM INT						NOT NULL
		, ID_EVALUATOR VARCHAR(5)			NOT NULL
		, IN_EVAL BIT							NULL
		, EVAL_ORDER TINYINT				NOT NULL
		, CALL_DATE DATETIME2(0)			NOT NULL
		, CALL_COMMENT VARCHAR(MAX)			NOT NULL
		, VALUE_01 NUMERIC(5, 2)				NULL	-- EFEKTIVITA HOVORU - ANALÝZA HOVORU A AKTIVNÍ NASLOUCHÁNÍ
		, VALUE_02 NUMERIC(5, 2)				NULL	-- NABÍDKA ŘEŠENÍ - SPRÁVNÉ A SROZUMITELNÉ ŘEŠENÍ
		, VALUE_03 NUMERIC(5, 2)				NULL	-- ETIKA HOVORU - KOMUNIKAČNÍ DOVEDNOSTI, LIDSKÝ PŘÍSTUP, EMPATIE
		, VALUE_04 NUMERIC(5, 2)				NULL	-- KVALITA HOVORU - KVALITA VEDENÉHO HOVORU
		, EVAL_TOTAL NUMERIC(5, 2)				NULL
		, COMMENT VARCHAR(MAX)					NULL
		, LAST_UPDATE DATETIME2(0)			NOT NULL
);
GO
-- TRIGGERS
CREATE OR ALTER TRIGGER TR_INSERT_UPDATE_PHD
ON RETCRM_APPLICATIONS.DBO.EVAL_BO_PHD
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_FORM INT, @EVAL_TOTAL NUMERIC(5, 2), @IN_EVAL BIT, @EVAL_ORDER TINYINT

	SELECT @ID_FORM = INSERTED.ID_FORM, @EVAL_TOTAL = INSERTED.EVAL_TOTAL, @IN_EVAL = INSERTED.IN_EVAL, @EVAL_ORDER = INSERTED.EVAL_ORDER
	FROM INSERTED

	IF @IN_EVAL = 1
	BEGIN
		IF @EVAL_ORDER = 1
			BEGIN
			UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET PHD_CALL_1 = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
			WHERE ID = @ID_FORM
			END
		ELSE
			BEGIN
			UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET PHD_CALL_2 = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
			WHERE ID = @ID_FORM
			END
		END
	ELSE
	BEGIN
		IF @EVAL_ORDER = 1
			BEGIN
			UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET PHD_CALL_1 = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
			WHERE ID = @ID_FORM
			END
		ELSE
			BEGIN
			UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET PHD_CALL_2 = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
			WHERE ID = @ID_FORM
			END
		END
	END
GO
-- /TRIGGERS

--############# 08 KONTROLA DOKUMENTACE #############
--DROP TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_DOCUMENTATION_CHECK
CREATE TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_DOCUMENTATION_CHECK (
		ID INT IDENTITY(100,1) PRIMARY KEY	NOT NULL
		, ID_FORM INT						NOT NULL
		, ID_EVALUATOR VARCHAR(5)			NOT NULL
		, IN_EVAL BIT							NULL
		, ACC_NUMBER VARCHAR(15)				NULL
		, RESULT VARCHAR(5)						NULL	-- OK / CHYBA
		, POINT_LOSS NUMERIC(5, 2)				NULL	-- 0  / 5
		, COMMENT VARCHAR(MAX)					NULL
		, LAST_UPDATE DATETIME2(0)			NOT NULL
);
GO
--TRIGGERS
CREATE OR ALTER TRIGGER TR_INSERT_UPDATE_DOCUMENTATION_CHECK
ON RETCRM_APPLICATIONS.DBO.EVAL_BO_DOCUMENTATION_CHECK
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_FORM INT, @EVAL_TOTAL NUMERIC(5, 2), @IN_EVAL BIT, @POCET INT

	SELECT @ID_FORM = INSERTED.ID_FORM, @IN_EVAL = INSERTED.IN_EVAL
	FROM INSERTED

	SELECT @POCET = COUNT(ID)
	FROM RETCRM_APPLICATIONS.DBO.EVAL_BO_DOCUMENTATION_CHECK
	WHERE ID_FORM = @ID_FORM
	AND IN_EVAL = 1

	IF @POCET > 0
		BEGIN
		SELECT @EVAL_TOTAL = 100 - SUM(POINT_LOSS)
		FROM RETCRM_APPLICATIONS.DBO.EVAL_BO_DOCUMENTATION_CHECK
		WHERE ID_FORM = @ID_FORM
		AND IN_EVAL = 1

		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET DOCUMENTATION_CHECK = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		WHERE ID = @ID_FORM
		END
	ELSE
		BEGIN
		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET DOCUMENTATION_CHECK = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		WHERE ID = @ID_FORM
		END
	END
GO
-- /TRIGGERS

--############# 09 INSOLVENCE #############
--DROP TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_INSOLVENCY
CREATE TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_INSOLVENCY (
		ID INT IDENTITY(100,1) PRIMARY KEY	NOT NULL
		, ID_FORM INT						NOT NULL
		, ID_EVALUATOR VARCHAR(5)			NOT NULL
		, IN_EVAL BIT							NULL
		, EVAL_TYPE VARCHAR(150)				NULL
		, INSOLVENCY_NUMBER VARCHAR(20)			NULL
		, RESULT VARCHAR(5)						NULL	-- OK / CHYBA
		, POINT_LOSS NUMERIC(5, 2)				NULL	-- 0  / 5
		, COMMENT VARCHAR(MAX)					NULL
		, KO_EVAL NUMERIC(5, 2)					NULL
		, LAST_UPDATE DATETIME2(0)			NOT NULL
);
GO
--TRIGGERS
CREATE OR ALTER TRIGGER TR_INSERT_UPDATE_INSOLVENCY
ON RETCRM_APPLICATIONS.DBO.EVAL_BO_INSOLVENCY
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_FORM INT, @EVAL_TOTAL NUMERIC(5, 2), @POCET INT

	SELECT @ID_FORM = INSERTED.ID_FORM
	FROM INSERTED

	SELECT @POCET = COUNT(ID)
	FROM RETCRM_APPLICATIONS.DBO.EVAL_BO_INSOLVENCY
	WHERE ID_FORM = @ID_FORM

	IF @POCET > 0
		BEGIN
		SELECT @EVAL_TOTAL = 100 - SUM(POINT_LOSS)
		FROM RETCRM_APPLICATIONS.DBO.EVAL_BO_INSOLVENCY
		WHERE ID_FORM = @ID_FORM
		AND IN_EVAL = 1

		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET INSOLVENCY = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		WHERE ID = @ID_FORM
		END
	ELSE
		BEGIN
		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET INSOLVENCY = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		END
	END
GO
-- /TRIGGERS

--############# 10 KONTROLA SOUDNIHO POPLATKU #############
--DROP TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_COURT_FEE
CREATE TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_COURT_FEE (
		ID INT IDENTITY(100,1) PRIMARY KEY	NOT NULL
		, ID_FORM INT						NOT NULL
		, ID_EVALUATOR VARCHAR(5)			NOT NULL
		, IN_EVAL BIT							NULL
		, ACC_NUMBER VARCHAR(15)				NULL
		, CORRECT_ASSIGN_TEXT VARCHAR(5)		NULL
		, CORRECT_ASSIGN NUMERIC(5, 2)			NULL	-- SPRÁVNĚ VYPLNĚNÝ A ODESLANÝ PŘIKAZ
		, COURT_FEE_AT_COLMAN_TEXT VARCHAR(5)	NULL
		, COURT_FEE_AT_COLMAN NUMERIC(5, 2)		NULL	-- SOP ZADANÁ DO COLMANU
		, LAST_UPDATE DATETIME2(0)				NULL
); 
GO
--TRIGGERS
CREATE OR ALTER TRIGGER TR_INSERT_UPDATE_COURT_FEE
ON RETCRM_APPLICATIONS.DBO.EVAL_BO_COURT_FEE
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_FORM INT, @EVAL_TOTAL NUMERIC(5, 2), @POCET INT

	SELECT @ID_FORM = INSERTED.ID_FORM
	FROM INSERTED

	SELECT @POCET = COUNT(ID)
	FROM RETCRM_APPLICATIONS.DBO.EVAL_BO_COURT_FEE
	WHERE ID_FORM = @ID_FORM

	IF @POCET > 0
		BEGIN
		SELECT @EVAL_TOTAL = SUM(CORRECT_ASSIGN) + SUM(COURT_FEE_AT_COLMAN)
		FROM RETCRM_APPLICATIONS.DBO.EVAL_BO_COURT_FEE
		WHERE ID_FORM = @ID_FORM
		AND IN_EVAL = 1

		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET COURT_FEE = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		WHERE ID = @ID_FORM
		END
	ELSE
		BEGIN
		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET COURT_FEE = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		END
	END
GO
-- /TRIGGERS

--############# 11 MAILY - SCHRÁNKA DLUH #############
--DROP TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_MAILBOX
CREATE TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_MAILBOX (
		ID INT IDENTITY(100,1) PRIMARY KEY	NOT NULL
		, ID_FORM INT						NOT NULL
		, ID_EVALUATOR VARCHAR(5)			NOT NULL
		, IN_EVAL BIT							NULL
		, EVAL_ORDER TINYINT					NULL
		, BIRTH_NUMBER VARCHAR(15)				NULL
		, MAIL_DATE DATETIME2(0)				NULL
		, VALUE_01 NUMERIC(5, 2)				NULL	-- EFEKTIVITA - ANALÝZA POŽADAVKU A SPRÁVNÉ POCHOPENÍ
		, VALUE_02 NUMERIC(5, 2)				NULL	-- NABÍDNUTÍ ŘEŠENÍ - SPRÁVNÉ A SROZUMITELNÉ ŘEŠENÍ
		, VALUE_03 NUMERIC(5, 2)				NULL	-- ETIKA - KOMUNIKAČNÍ DOVEDNOSTI, LIDSKÝ PŘÍSTUP, EMPATIE
		, VALUE_04 NUMERIC(5, 2)				NULL	-- KVALITA - KVALITA EMAILOVÉ ODPOVĚDI
		, EVAL_TOTAL NUMERIC(5, 2)				NULL
		, LAST_UPDATE DATETIME2(0)				NULL
);
GO
--TRIGGERS
CREATE OR ALTER TRIGGER TR_INSERT_UPDATE_MAILBOX
ON RETCRM_APPLICATIONS.DBO.EVAL_BO_MAILBOX
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_FORM INT, @EVAL_TOTAL NUMERIC(5,2), @EVAL_ORDER TINYINT, @IN_EVAL BIT

	SELECT @ID_FORM = INSERTED.ID_FORM, @EVAL_ORDER = INSERTED.EVAL_ORDER, @EVAL_TOTAL = INSERTED.EVAL_TOTAL, @IN_EVAL = INSERTED.IN_EVAL
	FROM INSERTED

	IF @IN_EVAL = 1
		BEGIN
			IF @EVAL_ORDER = 1
				BEGIN
				UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET MAILBOX_1 = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
				WHERE ID = @ID_FORM
				END
			ELSE
				BEGIN
				UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET MAILBOX_2 = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
				WHERE ID = @ID_FORM
				END
		END
	ELSE
		BEGIN
			IF @EVAL_ORDER = 1
				BEGIN
				UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET MAILBOX_1 = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
				WHERE ID = @ID_FORM
				END
			ELSE
				BEGIN
				UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET MAILBOX_2 = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
				WHERE ID = @ID_FORM
				END
		END
END
GO
-- /TRIGGERS

--############# 12 WATCHLISTY #############
--DROP TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_WATCHLIST
CREATE TABLE RETCRM_APPLICATIONS.DBO.EVAL_BO_WATCHLIST (
		ID INT IDENTITY(100,1) PRIMARY KEY	NOT NULL
		, ID_FORM INT						NOT NULL
		, ID_EVALUATOR VARCHAR(5)			NOT NULL
		, IN_EVAL BIT							NULL
		, WATCHLIST_TYPE VARCHAR(150)			NULL
		, ACC_COUNT INT							NULL
		, ERROR_COUNT INT						NULL
		, ERROR_RATE NUMERIC(5, 2)				NULL
		, LAST_UPDATE DATETIME2(0)				NULL
);
GO
--TRIGGERS
CREATE OR ALTER TRIGGER TR_INSERT_UPDATE_WATCHLIST
ON RETCRM_APPLICATIONS.DBO.EVAL_BO_WATCHLIST
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID_FORM INT, @EVAL_TOTAL DECIMAL(5, 2), @POCET INT

	SELECT @ID_FORM = INSERTED.ID_FORM
	FROM INSERTED

	SELECT @POCET = COUNT(ID)
	FROM RETCRM_APPLICATIONS.DBO.EVAL_BO_WATCHLIST
	WHERE ID_FORM = @ID_FORM
	AND IN_EVAL = 1

	IF @POCET > 0
		BEGIN
		SELECT @EVAL_TOTAL = SUM(CAST(ERROR_COUNT AS DECIMAL(5, 2))) / SUM(CAST(ACC_COUNT AS DECIMAL(5, 2)))
		FROM RETCRM_APPLICATIONS.DBO.EVAL_BO_WATCHLIST
		WHERE ID_FORM = @ID_FORM
		AND IN_EVAL = 1

		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET WATCHLISTS = @EVAL_TOTAL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		WHERE ID = @ID_FORM
		END
	ELSE
		BEGIN
		UPDATE RETCRM_APPLICATIONS.DBO.EVAL_BO_FORM SET WATCHLISTS = NULL, LAST_UPDATE = CAST(GETDATE() AS DATETIME2(0))
		END
	END
GO
-- /TRIGGERS