DEFINE SCHEMAOWNER = 'CONNECT_MS.';

CREATE OR REPLACE PROCEDURE &SCHEMAOWNER.prepareToPurge
(
	p_retentionDays    NUMBER,
	p_batchSize        NUMBER
)
AS
            v_BatchSize   	    NUMBER(10);
			v_rowCount    	    NUMBER(10) := 0;
			v_StartTime   	    TIMESTAMP;
            v_EndTime     	    TIMESTAMP;			
	        v_headerRows  	    NUMBER(10) := 0;
			v_HeaderEndTime     TIMESTAMP;
			v_HeaderIteration   NUMBER(10) := 0;
			v_bodyRows    	    NUMBER(10) := 0;
			v_BodyEndTime 	    TIMESTAMP;
			v_BodyIteration     NUMBER(10) := 0;
			v_Processed      	RAW(1);
            Invalid_Retention_Days_specified EXCEPTION;
            PRAGMA AUTONOMOUS_TRANSACTION; 
       
BEGIN
    IF (p_retentionDays <= 0 OR p_retentionDays IS NULL)
	THEN
	   RAISE Invalid_Retention_Days_specified;
		RETURN;
	END IF;

	IF (p_batchSize < 0 OR p_batchSize IS NULL)
	THEN
	    v_BatchSize := 1000;
	ELSE
	    v_BatchSize := p_batchSize;
	END IF;

	v_StartTime := CAST(SYSTIMESTAMP AS TIMESTAMP);

	BEGIN  -- (@lv_BatchSize > 0)
		WHILE 1 = 1
		LOOP
				
        UPDATE  MS_MSG_HDR SET ACTIVE = 0 WHERE	LST_UPDT_AT  < (SYSDATE - p_retentionDays)	AND ACTIVE = 1 and rownum <= v_BatchSize;
				
        v_rowCount := SQL%ROWCOUNT;
				v_headerRows := v_headerRows + v_rowCount;
				v_HeaderIteration := v_HeaderIteration + 1;
			
				DBMS_OUTPUT.PUT_LINE ('Rows Updated in Header Table ...' || TO_CHAR(v_rowCount) || ' time taken: ' || TO_CHAR(SYSTIMESTAMP - v_StartTime));
				IF (v_rowCount = 0 OR v_rowCount < v_BatchSize)
				THEN
					COMMIT ;
					EXIT;
				END IF;
			COMMIT;
		END LOOP;
	
		v_HeaderEndTime := CAST(SYSTIMESTAMP AS TIMESTAMP);
		DBMS_OUTPUT.PUT_LINE ('Updated Header table' || TO_CHAR(v_HeaderEndTime));
	  DBMS_OUTPUT.PUT_LINE ( 'Rows Updated in Body Table ...' || TO_CHAR(v_bodyRows) || ' time taken: ' || TO_CHAR(SYSTIMESTAMP - v_StartTime));

	-- Updating Body Table

	-- v_Processed:=COMPRESS ('PROCESSED') FROM dual ;
	END;
	
	DELETE FROM messageBodyToBeInactivated;
	
	INSERT INTO messageBodyToBeInactivated SELECT DISTINCT MSG_BDY_ID FROM MS_MSG_HDR MH  WHERE ACTIVE = 0 AND NOT EXISTS (SELECT 1 FROM MS_MSG_HDR MHI where ACTIVE = 1 AND MHI.MSG_BDY_ID = MH.MSG_BDY_ID );
	
	BEGIN
		WHILE 1 = 1
		LOOP
    
		DELETE FROM bodyToProcess;
		
		INSERT INTO bodyToProcess SELECT MSG_BDY_ID FROM messageBodyToBeInactivated where rownum <= v_BatchSize;
				
		v_rowCount := SQL%ROWCOUNT;
		
		DBMS_OUTPUT.PUT_LINE ('Loaded...' || TO_CHAR(v_rowCount) || ' body keys to be inactivated, Time Taken: ' || TO_CHAR(SYSTIMESTAMP - v_StartTime));
		
		UPDATE MS_MSG_BDY SET ACTIVE = 0 WHERE MSG_BDY_ID IN (SELECT MSG_BDY_ID FROM bodyToProcess) ;
		
			v_rowCount := SQL%ROWCOUNT;
			v_bodyRows := v_bodyRows + v_rowCount;
			v_BodyIteration := v_BodyIteration + 1;
		
        DBMS_OUTPUT.PUT_LINE ('Rows Updated in Body Table ...' || TO_CHAR(v_rowCount) || ' time taken: ' || TO_CHAR(SYSTIMESTAMP - v_StartTime));

			IF (v_rowCount = 0 OR v_rowCount < v_BatchSize)
			THEN
				COMMIT;
				EXIT;
			END IF;
			
			DELETE FROM messageBodyToBeInactivated WHERE msg_bdy_id IN (SELECT msg_bdy_id FROM bodyToProcess);
		
		COMMIT;
		END LOOP;
		
		v_BodyEndTime := CAST(SYSTIMESTAMP AS TIMESTAMP);
	END;
	DBMS_OUTPUT.PUT_LINE ('Rows Updated in Body Table ...' || TO_CHAR(v_bodyRows) || ' time taken: ' || TO_CHAR(SYSTIMESTAMP - v_StartTime));
	v_EndTime := SYSTIMESTAMP;

    DBMS_OUTPUT.PUT_LINE ('----SUMMARY----');
    DBMS_OUTPUT.PUT_LINE ('Start Time' || TO_CHAR(v_StartTime));
	DBMS_OUTPUT.PUT_LINE ( 'End Time' || TO_CHAR(v_BodyEndTime));
	DBMS_OUTPUT.PUT_LINE ( 'Total time taken' || TO_CHAR(v_BodyEndTime - v_StartTime));
	DBMS_OUTPUT.PUT_LINE ( 'Rows Updated in Header Table  ' || TO_CHAR(v_headerRows) || ' time taken: ' || TO_CHAR(v_HeaderEndTime - v_StartTime));
	DBMS_OUTPUT.PUT_LINE ( 'Total Header Iterations ' || TO_CHAR(v_HeaderIteration));
	DBMS_OUTPUT.PUT_LINE ( 'Rows Updated in Body Table ' || TO_CHAR(v_bodyRows) || ' time taken: ' || TO_CHAR(v_BodyEndTime - v_HeaderEndTime));
	DBMS_OUTPUT.PUT_LINE ( 'Total Body Iterations:' || TO_CHAR(v_BodyIteration));	
END;