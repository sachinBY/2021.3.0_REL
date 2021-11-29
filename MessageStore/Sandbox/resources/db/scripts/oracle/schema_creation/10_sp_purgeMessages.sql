DEFINE SCHEMAOWNER = 'CONNECT_MS.';

CREATE OR REPLACE PROCEDURE &SCHEMAOWNER.purgeMessages
(
	p_retentionDays    NUMBER,
	p_batchSize    NUMBER
)
AS
     v_BatchSize   NUMBER(10);
     v_rowsDeleted NUMBER(10);
	 v_StartTime   TIMESTAMP;
     v_EndTime     TIMESTAMP;
	 v_totalHeaderRows  NUMBER(10) := 0;
	 v_totalBodyRows    NUMBER(10) := 0;
	 v_rowCount    NUMBER(10);
	 v_eventRows   NUMBER(10) := 0;
	 v_headerRows  NUMBER(10) := 0;
	 v_bodyRows    NUMBER(10) := 0;
     v_tagRows     NUMBER(10) := 0;
	 v_bodyIteration   NUMBER(10) := 0;
	 v_headerIteration   NUMBER(10) := 0;
     v_replayRows  NUMBER(10) := 0;
	 v_Processed      RAW(1);
	 Invalid_Retention_Days_specified EXCEPTION;
   PRAGMA AUTONOMOUS_TRANSACTION; 
   
BEGIN

  IF (p_retentionDays <= 0 OR p_retentionDays IS NULL)
	THEN
	    RAISE Invalid_Retention_Days_specified;
		RETURN;
	END IF;

	IF (p_batchSize <= 0 OR p_batchSize IS NULL)
	THEN
	    v_BatchSize := 1000;
	ELSE
	    v_BatchSize := p_batchSize;
	END IF;
	
	v_StartTime := SYSTIMESTAMP;
	DBMS_OUTPUT.PUT_LINE( '---------------------');
	DBMS_OUTPUT.PUT_LINE( '----START SUMMARY----');
	DBMS_OUTPUT.PUT_LINE( 'Start Time ' || TO_CHAR(v_StartTime));
	
 DELETE FROM messageHeaderToDelete;
 INSERT INTO messageHeaderToDelete SELECT MSG_HDR_ID FROM MS_MSG_HDR WHERE ACTIVE = 0;


BEGIN 
	WHILE 1 = 1
	LOOP
			v_headerIteration := v_headerIteration + 1;
			DBMS_OUTPUT.PUT_LINE ( 'Iteration: ' || TO_CHAR(v_headerIteration) || ' Time Taken till now : ' || TO_CHAR((SYSTIMESTAMP - v_StartTime)));	
      
    	INSERT INTO headerToProcess SELECT MSG_HDR_ID FROM messageHeaderToDelete WHERE rownum <= v_BatchSize;
	
			v_rowCount := SQL%ROWCOUNT;
	
			DBMS_OUTPUT.PUT_LINE ( 'Loaded...' || TO_CHAR(v_rowCount) || ' header keys to delete, Time Taken till now : ' || TO_CHAR((SYSTIMESTAMP - v_StartTime)));

-- Replayable Table 

			DELETE FROM MS_RPLYBL_MSGS WHERE MSG_STORE_ID IN (SELECT msg_hdr_id FROM headerToProcess);
			v_rowCount := SQL%ROWCOUNT;
			v_replayRows := v_replayRows + v_rowCount;
			DBMS_OUTPUT.PUT_LINE ( 'Rows deleted from Replable Table ...' || TO_CHAR(v_rowCount) || ' ' || TO_CHAR((SYSTIMESTAMP - v_StartTime)));

-- Delete From EVENTS

			DELETE FROM MS_MSG_EVNT
			WHERE msg_hdr_id IN (SELECT msg_hdr_id
							FROM headerToProcess);
				
			v_rowCount := SQL%ROWCOUNT;
			v_eventRows := v_eventRows + v_rowCount;
			DBMS_OUTPUT.PUT_LINE ( 'Rows deleted from Event Table ...' || TO_CHAR(v_rowCount) || ' ' || TO_CHAR((SYSTIMESTAMP - v_StartTime)));

-- Deelte from Tag  

			DELETE FROM MS_MSG_TAG
			WHERE MSG_HDR_ID IN (SELECT msg_hdr_id
		                           FROM headerToProcess);

			v_rowCount := SQL%ROWCOUNT;
            v_tagRows := v_tagRows + v_rowCount;
			DBMS_OUTPUT.PUT_LINE ( 'Rows deleted from Tag Table ...' || TO_CHAR(v_rowCount) || ' ' || TO_CHAR((SYSTIMESTAMP - v_StartTime)));
			
-- Delete From Header 
			DELETE FROM MS_MSG_HDR
			WHERE msg_hdr_id IN (SELECT msg_hdr_id
			                        FROM headerToProcess);
			v_rowCount := SQL%ROWCOUNT;
			v_headerRows := v_headerRows + v_rowCount;
			DBMS_OUTPUT.PUT_LINE ( 'Rows deleted from Header Table ...' || TO_CHAR(v_rowCount) || ' ' || TO_CHAR((SYSTIMESTAMP - v_StartTime)));
      
-- Temprary table.
			DELETE FROM messageHeaderToDelete
			 WHERE msg_hdr_id IN (SELECT msg_hdr_id
			                        FROM headerToProcess);

			v_rowsDeleted := SQL%ROWCOUNT;
      
      DELETE FROM headerToProcess;
			
		COMMIT;

-- Successed the complete dataset
		IF v_rowsDeleted < v_BatchSize 
    THEN 
      EXIT;
		END IF;
	END LOOP;
END;

BEGIN
    WHILE 1 = 1
		LOOP 
			
			v_bodyIteration := v_bodyIteration + 1;
			DBMS_OUTPUT.PUT_LINE (  'Iteration: ' || TO_CHAR(v_bodyIteration) || ', Time Taken till now : ' || TO_CHAR((SYSTIMESTAMP - v_StartTime)));

			DELETE  FROM MS_MSG_BDY WHERE ACTIVE = 0 AND ROWNUM <= p_batchSize;
			v_rowCount := SQL%ROWCOUNT;
			
			v_bodyRows := v_bodyRows + v_rowCount;
			DBMS_OUTPUT.PUT_LINE ( 'Deleted...' || TO_CHAR(v_rowCount) || ' body keys, Time Taken till now: ' || TO_CHAR((SYSTIMESTAMP - v_StartTime)));

			IF (v_rowCount < p_batchSize OR v_rowCount = 0 )
			THEN
				COMMIT;
				EXIT;
			END IF;
			
		COMMIT;
		END LOOP;
END;

    v_EndTime := SYSTIMESTAMP;
   DBMS_OUTPUT.PUT_LINE ( '----SUMMARY----');
   DBMS_OUTPUT.PUT_LINE ( 'Start Time: ' || TO_CHAR(v_StartTime));
   DBMS_OUTPUT.PUT_LINE ( 'Total Body Iterations: ' || TO_CHAR(v_bodyIteration));
   DBMS_OUTPUT.PUT_LINE ( 'Total Header Iterations: ' || TO_CHAR(v_headerIteration));
   DBMS_OUTPUT.PUT_LINE ( 'Header Rows Deleted: ' || TO_CHAR(v_headerRows));
   DBMS_OUTPUT.PUT_LINE ( 'Body Rows Deleted: ' || TO_CHAR(v_bodyRows));
   DBMS_OUTPUT.PUT_LINE ( 'Event Rows Deleted: ' || TO_CHAR(v_eventRows));
   DBMS_OUTPUT.PUT_LINE ( 'Replay Rows Deleted: ' || TO_CHAR(v_replayRows));
   DBMS_OUTPUT.PUT_LINE ( 'Tag Rows Deleted: ' || TO_CHAR(v_tagRows));
   DBMS_OUTPUT.PUT_LINE ( 'End Time : ' || TO_CHAR(v_EndTime));
	 DBMS_OUTPUT.PUT_LINE ( 'Total Time Taken : ' || TO_CHAR((v_EndTime - v_StartTime)));
END;