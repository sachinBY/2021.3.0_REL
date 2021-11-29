:setvar SCHEMANAME CONNECT_MS

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE $(SCHEMANAME).[prepareToPurge]
(
	@p_retentionDays    INT,
	@p_batchSize    INT
)
AS
BEGIN
    DECLARE @lv_BatchSize   	INT,
			@lv_rowCount    	INT,
			@lv_StartTime   	TIME,
            @lv_EndTime     	TIME,			
	        @lv_headerRows  	INT = 0,
			@lv_HeaderEndTime 	TIME,
			@lv_HeaderIteration INT = 0,
			@lv_bodyRows    	INT = 0,
			@lv_BodyEndTime 	TIME,
			@lv_BodyIteration   INT = 0,
			@Processed      	BINARY



-- Retention Days are mandatory

    IF (@p_retentionDays <= 0 OR @p_retentionDays IS NULL)
	BEGIN
	    RAISERROR('Invalid Retention Days specified',
		           16,
				   1);
		RETURN
	END

-- Default batch size to 1000 if not provided

	IF (@p_batchSize < 0 OR @p_batchSize IS NULL)
	BEGIN
	    SET @lv_BatchSize = 1000
    END
	ELSE
	BEGIN
	    SET @lv_BatchSize = @p_batchSize
	END

	SET NOCOUNT ON
	SET @lv_StartTime = CAST(GETDATE() AS TIME)

	BEGIN  -- (@lv_BatchSize > 0)
		WHILE (1 = 1)
		BEGIN
	
			BEGIN TRANSACTION
				UPDATE TOP (@lv_BatchSize) MS_MSG_HDR
				SET ACTIVE = 0
				WHERE 
				CAST(LST_UPDT_AT AS DATE) < CAST(dateadd(DAY, -@p_retentionDays, sysdatetime()) AS DATE)
				AND ACTIVE = 1
			
				SET @lv_rowCount = @@ROWCOUNT
				SET @lv_headerRows = @lv_headerRows + @lv_rowCount
				SET @lv_HeaderIteration = @lv_HeaderIteration + 1
			
				PRINT 'Rows Updated in Header Table ...' + CAST(@lv_rowCount AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)
			
				IF (@lv_rowCount = 0 OR @lv_rowCount < @lv_BatchSize)
				BEGIN
					-- No more rows for this iteration
					-- SET @lv_iteration = @lv_iteration - 1
					COMMIT TRANSACTION
					BREAK
				END
			COMMIT TRANSACTION
		END
	
		SET @lv_HeaderEndTime = CAST(GETDATE() AS TIME)
		PRINT 'Updated Header table' + CAST(@lv_HeaderEndTime as VARCHAR)
	PRINT 'Rows Updated in Body Table ...' + CAST(@lv_bodyRows AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)

	-- Updating Body Table

		-- Set Processed For Body Updates
		SELECT @Processed=COMPRESS ('PROCESSED') ;
	END
	
-- Drop Temporary table if exists
	
	IF OBJECT_ID('tempdb.dbo.#messageBodyToBeInactivated') IS NOT NULL
    BEGIN
		DROP TABLE [#messageBodyToBeInactivated]
    END

	SELECT DISTINCT (MSG_BDY_ID)
	INTO #messageBodyToBeInactivated
	FROM MS_MSG_HDR MH WITH (NOLOCK) 
	WHERE ACTIVE = 0
	AND NOT EXISTS (SELECT 1 FROM MS_MSG_HDR MHI where ACTIVE = 1 AND MHI.MSG_BDY_ID = MH.MSG_BDY_ID )
	
	BEGIN
		WHILE (1 = 1)
		BEGIN
			
			IF OBJECT_ID('tempdb.dbo.#bodyToProcess') IS NOT NULL
			BEGIN
				DROP TABLE #bodyToProcess
			END
		

			BEGIN TRANSACTION

				SELECT TOP (@lv_BatchSize) MSG_BDY_ID 
				INTO #bodyToProcess
				FROM #messageBodyToBeInactivated
				ORDER BY MSG_BDY_ID;
				
				SET @lv_rowCount = @@ROWCOUNT
		
				PRINT 'Loaded...' + CAST(@lv_rowCount AS VARCHAR) + ' body keys to be inactivated, Time Taken(in seconds) till now : ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)

				UPDATE MS_MSG_BDY
				SET ACTIVE = 0
				WHERE 
				MSG_BDY_ID IN (SELECT MSG_BDY_ID
								FROM #bodyToProcess) OPTION (RECOMPILE);
				
				SET @lv_rowCount = @@ROWCOUNT
				SET @lv_bodyRows = @lv_bodyRows + @lv_rowCount
				SET @lv_BodyIteration = @lv_BodyIteration + 1
				PRINT 'Rows Updated in Body Table ...' + CAST(@lv_rowCount AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)

				IF (@lv_rowCount = 0 OR @lv_rowCount < @lv_BatchSize)
				BEGIN
					-- No more rows for this iteration
					-- SET @lv_iteration = @lv_iteration - 1
					COMMIT TRANSACTION
					BREAK
				END
-- Delete from temporary table.
				DELETE FROM #messageBodyToBeInactivated
				WHERE msg_bdy_id IN (SELECT msg_bdy_id
										FROM #bodyToProcess);
			COMMIT TRANSACTION
		END
		SET @lv_BodyEndTime = CAST(GETDATE() AS TIME)
	END
	PRINT 'Rows Updated in Body Table ...' + CAST(@lv_bodyRows AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)


    SET @lv_EndTime = GETDATE()

    PRINT '----SUMMARY----'
    PRINT 'Start Time' + CAST(@lv_StartTime as VARCHAR)
	PRINT 'End Time' + CAST(@lv_BodyEndTime as VARCHAR)
	PRINT 'Total time taken' + CAST(DATEDIFF(ss, @lv_StartTime, @lv_BodyEndTime) AS VARCHAR)
	PRINT 'Rows Updated in Header Table : ' + CAST(@lv_headerRows AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, @lv_HeaderEndTime) AS VARCHAR)
	PRINT 'Total Header Iterations:' + CAST(@lv_HeaderIteration AS VARCHAR)
	PRINT 'Rows Updated in Body Table : ' + CAST(@lv_bodyRows AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_HeaderEndTime, @lv_BodyEndTime) AS VARCHAR)
	PRINT 'Total Body Iterations:' + CAST(@lv_BodyIteration AS VARCHAR)
	
	
	--PRINT 'Total Time Taken : ' + CAST(DATEDIFF(ss, @lv_StartTime, lv_BodyEndTime) AS VARCHAR)

    --PRINT 'End Time' + CAST(@lv_EndTime as VARCHAR)
  --  PRINT 'Total Time Taken' + CAST(DATEDIFF(ss, @lv_StartTime, lv_EndTime)) AS VARCHAR)
	SET NOCOUNT OFF
END
GO