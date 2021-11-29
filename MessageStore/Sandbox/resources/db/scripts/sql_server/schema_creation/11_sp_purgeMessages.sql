:setvar SCHEMANAME CONNECT_MS

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE $(SCHEMANAME).[purgeMessages]
(
	@p_retentionDays    INT,
	@p_batchSize    INT
)
AS
BEGIN
    DECLARE @lv_BatchSize   INT,
	        @lv_rowsDeleted INT,
			@lv_StartTime   TIME,
            @lv_EndTime     TIME,
			@lv_totalHeaderRows  INT = 0,
			@lv_totalBodyRows    INT = 0,
			@lv_rowCount    INT,
			@lv_eventRows   INT = 0,
			@lv_headerRows  INT = 0,
			@lv_bodyRows    INT = 0,
            @lv_tagRows     INT = 0,
			@lv_bodyIteration   INT = 0,
			@lv_headerIteration   INT = 0,
            @lv_replayRows  INT = 0,
			@Processed      BINARY


-- Retention Days are mandatory

    IF (@p_retentionDays <= 0 OR @p_retentionDays IS NULL)
	BEGIN
	    RAISERROR('Invalid Retention Days specified',
		           16,
				   1);
		RETURN
	END

-- Default batch size to 1000 if not provided

	IF (@p_batchSize <= 0 OR @p_batchSize IS NULL)
	BEGIN
	    SET @lv_BatchSize = 1000
    END
	ELSE
	BEGIN
	    SET @lv_BatchSize = @p_batchSize
	END
	
	SET @lv_StartTime = GETDATE()
	PRINT '---------------------'
	PRINT '----START SUMMARY----'
	PRINT 'Start Time ' + CAST(@lv_StartTime as VARCHAR)
	

	SET NOCOUNT ON

-- Drop Temporary table if exists
	
	IF OBJECT_ID('tempdb.dbo.#messageHeaderToDelete') IS NOT NULL
    BEGIN
		DROP TABLE [#messageHeaderToDelete]
    END
	
	SELECT MSG_HDR_ID
	INTO #messageHeaderToDelete
	FROM MS_MSG_HDR WITH (NOLOCK) 
	WHERE ACTIVE = 0

BEGIN  -- (@lv_BatchSize > 0)
	WHILE (1 = 1)
	BEGIN
		
        IF OBJECT_ID('tempdb.dbo.#headerToProcess') IS NOT NULL
		BEGIN
			DROP TABLE #headerToProcess
		END
		
		BEGIN TRANSACTION

			SET @lv_HeaderIteration = @lv_HeaderIteration + 1
			PRINT 'Iteration: ' + CAST(@lv_HeaderIteration AS VARCHAR) + ', Time Taken(in seconds) till now : ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)
			
			SELECT TOP (@lv_BatchSize) MSG_HDR_ID 
			INTO #headerToProcess
			FROM #messageHeaderToDelete
			ORDER BY MSG_HDR_ID;
	
			SET @lv_rowCount = @@ROWCOUNT
	
			PRINT 'Loaded...' + CAST(@lv_rowCount AS VARCHAR) + ' header keys to delete, Time Taken(in seconds) till now : ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)

-- Delete From Replayable Table 
			DELETE FROM MS_RPLYBL_MSGS WHERE MSG_STORE_ID IN (SELECT msg_hdr_id FROM #headerToProcess) OPTION (RECOMPILE)
			
			SET @lv_rowCount = @@ROWCOUNT
			SET @lv_replayRows = @lv_replayRows + @lv_rowCount
			PRINT 'Rows deleted from Replable Table ...' + CAST(@lv_rowCount AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)

-- Delete From EVENTS

			DELETE FROM MS_MSG_EVNT
			WHERE msg_hdr_id IN (SELECT msg_hdr_id
							FROM #headerToProcess) OPTION (RECOMPILE);
				
			SET @lv_rowCount = @@ROWCOUNT
			SET @lv_eventRows = @lv_eventRows + @lv_rowCount
			PRINT 'Rows deleted from Event Table ...' + CAST(@lv_rowCount AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)


-- Deelte from Tag  

			DELETE FROM MS_MSG_TAG
			WHERE MSG_HDR_ID IN (SELECT msg_hdr_id
		                           FROM #headerToProcess) OPTION (RECOMPILE)

			SET @lv_rowCount = @@ROWCOUNT
            SET @lv_tagRows = @lv_tagRows + @lv_rowCount
			PRINT 'Rows deleted from Tag Table ...' + CAST(@lv_rowCount AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)
			
-- Delete From Header 
			DELETE FROM MS_MSG_HDR
			WHERE msg_hdr_id IN (SELECT msg_hdr_id
			                        FROM #headerToProcess) OPTION (RECOMPILE);
			SET @lv_rowCount = @@ROWCOUNT
			SET @lv_headerRows = @lv_headerRows + @lv_rowCount
			PRINT 'Rows deleted from Header Table ...' + CAST(@lv_rowCount AS VARCHAR) + ' ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)

-- Delete from temporary table.
			DELETE FROM #messageHeaderToDelete
			 WHERE msg_hdr_id IN (SELECT msg_hdr_id
			                        FROM #headerToProcess);

			SET @lv_rowsDeleted = @@ROWCOUNT
			
		COMMIT TRANSACTION

-- Check if we processed the complete dataset
		IF @lv_rowsDeleted < @lv_BatchSize BREAK
	END -- WHILE (1 = 1)
END 

BEGIN  -- (@lv_BatchSize > 0)
	    WHILE (1 = 1)
		BEGIN 
			BEGIN TRANSACTION
			
			SET @lv_bodyIteration = @lv_bodyIteration + 1
			PRINT 'Iteration: ' + CAST(@lv_bodyIteration AS VARCHAR) + ', Time Taken(in seconds) till now : ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)

			DELETE TOP(@p_batchSize) FROM MS_MSG_BDY WHERE ACTIVE = 0 
			SET @lv_rowCount = @@ROWCOUNT
			
			SET @lv_bodyRows = @lv_bodyRows + @lv_rowCount
			PRINT 'Deleted...' + CAST(@lv_rowCount AS VARCHAR) + ' body keys, Time Taken(in seconds) till now: ' + CAST(DATEDIFF(ss, @lv_StartTime, CAST(GETDATE() AS TIME)) AS VARCHAR)

			IF (@lv_rowCount < @p_batchSize OR @lv_rowCount = 0 )
			BEGIN
				-- No more rows for this iteration
				-- SET @lv_iteration = @lv_iteration - 1
				COMMIT TRANSACTION
				BREAK
			END
			
		COMMIT TRANSACTION
		END
END

    SET @lv_EndTime = GETDATE()

    PRINT '----SUMMARY----'
    PRINT 'Start Time: ' + CAST(@lv_StartTime as VARCHAR)
	PRINT 'Total Body Iterations: ' + CAST(@lv_BodyIteration as VARCHAR)
	PRINT 'Total Header Iterations: ' + CAST(@lv_HeaderIteration AS VARCHAR)
	PRINT 'Header Rows Deleted: ' + CAST(@lv_headerRows AS VARCHAR)
	PRINT 'Body Rows Deleted: ' + CAST(@lv_bodyRows AS VARCHAR)
	PRINT 'Event Rows Deleted: ' + CAST(@lv_eventRows AS VARCHAR)
    PRINT 'Replay Rows Deleted: ' + CAST(@lv_replayRows AS VARCHAR)
    PRINT 'Tag Rows Deleted: ' + CAST(@lv_tagRows AS VARCHAR)
    PRINT 'End Time : ' + CAST(@lv_EndTime as VARCHAR)
	PRINT 'Total Time Taken : ' + CAST(DATEDIFF(ss, @lv_StartTime, @lv_EndTime) AS VARCHAR)
	SET NOCOUNT OFF
END
GO
