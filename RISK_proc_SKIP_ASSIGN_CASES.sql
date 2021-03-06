USE [RetCRM_Applications]
GO
/****** Object:  StoredProcedure [dbo].[proc_SKIP_ASSIGN_CASES]    Script Date: 30.1.2017 9:03:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[proc_SKIP_ASSIGN_CASES] (
	@p_person_id varchar(5) = NULL,
	@p_limit int = NULL,
	@p_search_type_short varchar(10) = NULL
)AS 

BEGIN 
	SET NOCOUNT ON;
	DECLARE @person_id varchar(5) = NULL, @N_cases int, @update tinyint = 0;

	DECLARE @id int, @load_date date, @search_type varchar(50), @cluid varchar(50), @br_ic varchar(10), @client_name varchar(MAX), @legal_form varchar(3), @last_rpc_date datetime,
		@max_dpd int, @max_balance float, @max_outstanding float, @sum_balance float, @sum_outstanding float, @cnt_all int, @client_order int, @short varchar(10), @assigned tinyint;
	
	DECLARE @limit int = NULL;
		IF @p_limit is NULL
			SET @limit = (SELECT value_order FROM [RetCRM_Applications].[dbo].[APL_LOV] WHERE value = 'SKIP LIMIT' and valid_from <= CAST(GETDATE() AS DATE) and valid_to > CAST(GETDATE() AS DATE));
		ELSE
			SET @limit = @p_limit;

	DECLARE @last_workday_of_month date;
		SET @last_workday_of_month = (SELECT [LAST_WORK_DAY_IN_MONTH] FROM [dbo].[view_LAST_WORK_DAY_IN_CUR_MONTH]);


	IF @p_search_type_short IN ('SKIP','DCA','ZAHR','MSE')
		BEGIN
			DECLARE C_CLIENTS_TO_ASSIGN CURSOR FOR
				SELECT id, load_date, search_type, cluid, br_ic, client_name, legal_form, last_rpc_date, max_dpd, max_balance, max_outstanding
					, sum_balance, sum_outstanding, cnt_all, client_order, short, assigned
				FROM [RetCRM_Applications].[dbo].[view_SKIP_TODAY_DATA] WHERE assigned IS NULL and short = @p_search_type_short
				ORDER BY client_order, max_dpd, sum_balance DESC, sum_outstanding DESC;
				
			SET @update = 1;
		END
	IF @p_search_type_short is NULL
		BEGIN
			DECLARE C_CLIENTS_TO_ASSIGN CURSOR FOR
				SELECT id, load_date, search_type, cluid, br_ic, client_name, legal_form, last_rpc_date, max_dpd, max_balance, max_outstanding
					, sum_balance, sum_outstanding, cnt_all, client_order, short, assigned
				FROM [RetCRM_Applications].[dbo].[view_SKIP_TODAY_DATA] WHERE assigned IS NULL
				ORDER BY client_order, max_dpd, sum_balance DESC, sum_outstanding DESC;
				
			SET @update = 1;
		END
	ELSE
		BEGIN
			DECLARE C_CLIENTS_TO_ASSIGN CURSOR FOR
				SELECT id, load_date, search_type, cluid, br_ic, client_name, legal_form, last_rpc_date, max_dpd, max_balance, max_outstanding
					, sum_balance, sum_outstanding, cnt_all, client_order, short, assigned
				FROM [RetCRM_Applications].[dbo].[view_SKIP_TODAY_DATA] WHERE assigned IS NULL
				ORDER BY client_order, max_dpd, sum_balance DESC, sum_outstanding DESC;
				
			SET @update = 1;
		END

	OPEN C_CLIENTS_TO_ASSIGN;
	FETCH NEXT FROM C_CLIENTS_TO_ASSIGN INTO @id, @load_date, @search_type, @cluid, @br_ic, @client_name, @legal_form, @last_rpc_date, @max_dpd, @max_balance, @max_outstanding
		, @sum_balance, @sum_outstanding, @cnt_all, @client_order, @short, @assigned;

	DECLARE @id_search_type int = NULL;
	DECLARE @id_client int = NULL;
	DECLARE @table table(id int);

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @p_search_type_short is null
			SET @id_search_type = (SELECT ID FROM [RetCRM_Applications].[dbo].[view_SKIP_search_type_ACTUAL] WHERE SHORT = @short);
		ELSE
			SET @id_search_type = (SELECT ID FROM [RetCRM_Applications].[dbo].[view_SKIP_search_type_ACTUAL] WHERE SHORT = @p_search_type_short);
		
		IF @id_search_type IS NULL -- přiřazení do klasického dohl (asi jen pro jistotu)
			SET @id_search_type = 653;

		SET @person_id = @p_person_id;

		IF @person_id IS NULL -- automatické přidělení klientů
			BEGIN
				IF @limit > 0
					BEGIN
						DECLARE C_CASES_COUNT CURSOR FOR
							SELECT TOP 1 ur.id_person
							  , count(c.id) as cases_count
							FROM [RetCRM_Applications].[dbo].[APL_USER_RIGHTS] as ur
							LEFT JOIN [RetCRM_Applications].[dbo].SKIP_CLIENT c
							  on c.owner = ur.id_person
								and c.date_of_create=CAST(GETDATE() AS DATE)
							WHERE ur.id_rights=646
							  and ur.valid_from<=CAST(GETDATE() AS DATE)
							  and ur.valid_to > CAST(GETDATE() AS DATE)
							GROUP BY ur.id_person
							ORDER BY cases_count ASC, id_person;

						OPEN C_CASES_COUNT;
							FETCH NEXT FROM C_CASES_COUNT INTO @person_id, @N_cases;
				
							INSERT INTO dbo.SKIP_CLIENT
							  (date_of_create, cluid, id_search_type, bn_ic, clients_name, legal_form, number_of_accounts, max_dpd, max_bal, max_out, sum_bal, sum_out, owner, own_worker, comment_own_worker) 
							OUTPUT inserted.id into @table
							VALUES 
							  (@load_date, @cluid, @id_search_type, @br_ic, @client_name, @legal_form, @cnt_all, @max_dpd, @max_balance, @max_outstanding, @sum_balance, @sum_outstanding, @person_id, NULL, NULL);
						
							SELECT @id_client = id FROM @table;

							INSERT INTO dbo.SKIP_CLIENT_STATE (id_client, id_state, id_client_search_type, id_noncontact_reason, valid_from, valid_to, comment)
							VALUES (@id_client, 682, NULL, NULL, CAST(GETDATE() AS DATE), '01.01.3000', NULL);

							IF @update = 1
								UPDATE dbo.SKIP_LOAD SET assigned = 1 WHERE id = @id;	
							
						CLOSE C_CASES_COUNT;
						DEALLOCATE C_CASES_COUNT;

						SET @id_client = NULL;
						SET @limit = @limit - 1;
					END
				ELSE 
					BREAK;
			END			
		ELSE -- ruční přidělení klientů
			BEGIN
				IF @limit > 0
					BEGIN
						INSERT INTO dbo.SKIP_CLIENT
						  (date_of_create, cluid, id_search_type, bn_ic, clients_name, legal_form, number_of_accounts, max_dpd, max_bal, max_out, sum_bal, sum_out, owner, own_worker, comment_own_worker) 
						OUTPUT inserted.id into @table
						VALUES 
						  (@load_date, @cluid, @id_search_type, @br_ic, @client_name, @legal_form, @cnt_all, @max_dpd, @max_balance, @max_outstanding, @sum_balance, @sum_outstanding, @person_id, NULL, NULL);
						
						SELECT @id_client = id FROM @table;

						INSERT INTO dbo.SKIP_CLIENT_STATE (id_client, id_state, id_client_search_type, id_noncontact_reason, valid_from, valid_to, comment)
						VALUES (@id_client, 682, NULL, NULL, CAST(GETDATE() AS DATE), '01.01.3000', NULL);
						
						IF @update = 1
							UPDATE dbo.SKIP_LOAD SET assigned = 1 WHERE id = @id;	
						
						SET @id_client = NULL;
						SET @limit = @limit - 1;
					END
				ELSE
					BREAK;
			END
		
		FETCH NEXT FROM C_CLIENTS_TO_ASSIGN INTO @id, @load_date, @search_type, @cluid, @br_ic, @client_name, @legal_form, @last_rpc_date, @max_dpd, @max_balance, @max_outstanding
			, @sum_balance, @sum_outstanding, @cnt_all, @client_order, @short, @assigned;
	END
	CLOSE C_CLIENTS_TO_ASSIGN;
	DEALLOCATE C_CLIENTS_TO_ASSIGN;
END 