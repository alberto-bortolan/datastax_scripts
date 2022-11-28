DROP PROCEDURE IF EXISTS gen_d_<CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_messages;
DELIMITER //

CREATE PROCEDURE gen_d_<CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_messages()
BEGIN
  DECLARE done BOOL DEFAULT FALSE;
  DECLARE nloop INT;
 
  -- current row
  DECLARE c_runid    VARCHAR(32);
  DECLARE c_ip      VARCHAR(18);
  DECLARE c_messages     VARCHAR(64); 
  DECLARE c_ts           DATETIME;
  DECLARE c_dropped      DECIMAL(16,0); 
  
  -- previous row (only relevant values)
  DECLARE p_ts           DATETIME;  
  DECLARE p_messages     VARCHAR(64)  DEFAULT 'NONSENSE';  
  DECLARE p_dropped      DECIMAL(16,0) DEFAULT 0; 
  
  -- delta values (per second)
  DECLARE delta_ts        INT DEFAULT 1;
  DECLARE vd_dropped      DECIMAL(16,0) DEFAULT 0;  
  
  -- this stores the very first key, for each messages change
  -- we go back and set the 1st row to the same values of the second to
  -- avoid the ugly ramps in the graph (anyway the 1st value is meaningless as it's a delta)
  DECLARE first_runid        VARCHAR(32);
  DECLARE first_ip           VARCHAR(18);
  DECLARE first_messages     VARCHAR(64); 
  DECLARE first_ts           DATETIME;
  
  DECLARE updsql             VARCHAR(500);
  
  DECLARE curs1 CURSOR FOR SELECT runid, ip, messages, ts, dropped FROM for_grafana.<CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_messages ORDER BY runid, ip, messages, ts;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;  
  
  SET @updsql = 'UPDATE for_grafana.<CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_messages SET d_dropped = ? WHERE runid = ? AND ip = ? AND messages = ? AND ts = ?'; 
  PREPARE updstm FROM @updsql;  
  SET nloop =0;  -- count the loops within a messages 

  SET p_messages = 'NONSENSE';
  
  OPEN curs1;
  read_loop: LOOP
    FETCH curs1 INTO c_runid,c_ip,c_messages,c_ts, c_dropped;
    IF done THEN
      LEAVE read_loop;
    END IF;
	SET nloop = nloop+1;
	IF ( c_messages != p_messages) THEN
	   SET nloop = 1;
	   SET vd_dropped = 0;
	   
	   SET first_runid = c_runid;
	   SET first_ip =  c_ip;
	   SET first_messages = c_messages;
	   SET first_ts   = c_ts;
    ELSE
       SET delta_ts = TIMESTAMPDIFF(SECOND,p_ts,c_ts);
	   SET vd_dropped = (c_dropped - p_dropped )/delta_ts;	
    END IF; 	
    EXECUTE updstm USING vd_dropped,c_runid,c_ip, c_messages, c_ts;
	-- set 1st row like the 2nd to avoid the starup ramp in the graphs
	IF nloop = 2 THEN
	   EXECUTE updstm USING vd_dropped,first_runid,first_ip, first_messages, first_ts;
	END IF;
	SET p_ts = c_ts;
    SET p_messages = c_messages;
    SET p_dropped = c_dropped;

  END LOOP;

  CLOSE curs1;
  DEALLOCATE PREPARE updstm;

END; //

DELIMITER ;
