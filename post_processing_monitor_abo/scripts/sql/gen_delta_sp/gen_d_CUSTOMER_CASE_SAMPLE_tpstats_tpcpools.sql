DROP PROCEDURE IF EXISTS gen_d_<CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_tpcpools;
DELIMITER //

CREATE PROCEDURE gen_d_<CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_tpcpools()
BEGIN
  -- DECLARE first_row BOOL DEFAULT TRUE;
  DECLARE done BOOL DEFAULT FALSE;
  DECLARE nloop INT;
 
  -- current row
  DECLARE c_runid        VARCHAR(32);
  DECLARE c_ip           VARCHAR(18);
  DECLARE c_group_name   VARCHAR(10);
  DECLARE c_pool         VARCHAR(64); 
  DECLARE c_ts           DATETIME;
  DECLARE c_completed    DECIMAL(16,0); 
  
  -- previous row (only relevant values)
  DECLARE p_ts           DATETIME;  
  DECLARE p_pool         VARCHAR(64)   DEFAULT 'NONSENSE';  
  DECLARE p_completed    DECIMAL(16,0) DEFAULT 0; 
  
  -- delta values (per second)
  DECLARE delta_ts        INT DEFAULT 1;
  DECLARE vd_completed    DECIMAL(16,0) DEFAULT 0;  
  
  -- this stores the very first key, for each pool change
  -- we go back and set the 1st row to the same values of the second to
  -- avoid the ugly ramps in the graph (anyway the 1st value is meaningless as it's a delta)
  DECLARE first_runid    VARCHAR(32);
  DECLARE first_ip      VARCHAR(18);
  DECLARE first_group_name   VARCHAR(10);
  DECLARE first_pool         VARCHAR(64); 
  DECLARE first_ts           DATETIME;
  
  DECLARE updsql          VARCHAR(500);
  
  DECLARE curs1 CURSOR FOR SELECT runid, ip, group_name, pool, ts, completed 
                              FROM for_grafana.<CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_tpcpools 
                          ORDER BY runid,ip,group_name,pool,ts;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;  
  
  SET @updsql = 'UPDATE for_grafana.<CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_tpcpools SET d_completed = ? WHERE runid = ? AND ip = ? AND group_name = ? AND pool = ? AND ts = ?'; 
  PREPARE updstm FROM @updsql;  
  SET nloop =0;  -- count the loops within a pool 
  -- SET first_row = FALSE;
  SET p_pool = 'NONSENSE';
  
  OPEN curs1;
  read_loop: LOOP
    FETCH curs1 INTO c_runid,c_ip,c_group_name,c_pool,c_ts, c_completed;
    IF done THEN
      LEAVE read_loop;
    END IF;
	SET nloop = nloop+1;
	IF ( c_pool != p_pool) THEN
	   SET nloop = 1;
	   SET vd_completed = 0;
	   
	   SET first_runid = c_runid;
	   SET first_ip =  c_ip;
	   SET first_group_name = c_group_name;
	   SET first_pool = c_pool;
	   SET first_ts   = c_ts;
    ELSE
       SET delta_ts = TIMESTAMPDIFF(SECOND,p_ts,c_ts);
	   SET vd_completed = (c_completed - p_completed )/delta_ts;	
    END IF; 	

    EXECUTE updstm USING vd_completed,c_runid,c_ip, c_group_name, c_pool, c_ts;
	-- set 1st row like the 2nd to avoid the starup ramp in the graphs
	IF nloop = 2 THEN
	   EXECUTE updstm USING vd_completed,first_runid,first_ip, first_group_name, first_pool, first_ts;
	END IF;
	SET p_ts = c_ts;
    SET p_pool = c_pool;
    SET p_completed = c_completed;

  END LOOP;

  CLOSE curs1;
  DEALLOCATE PREPARE updstm;

END; //

DELIMITER ;
