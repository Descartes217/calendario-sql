DROP TABLE IF EXISTS time_dimension;
CREATE TABLE time_dimension (
        id                      INTEGER PRIMARY KEY,  -- year*10000+month*100+day
        db_date                 DATE NOT NULL,
        anio                    INTEGER NOT NULL,
        mes                   INTEGER NOT NULL, -- 1 to 12
        dia                     INTEGER NOT NULL,
        anio_mes                     INTEGER NOT NULL, -- 1 to 31
        trimestre                 INTEGER NOT NULL, -- 1 to 4
        semana                    INTEGER NOT NULL, -- 1 to 52/53
        dia_nombre                VARCHAR(20) NOT NULL, -- 'Monday', 'Tuesday'...
        mes_nombre              VARCHAR(20) NOT NULL, -- 'January', 'February'...
        feriado_flag            CHAR(1) DEFAULT 'f' CHECK (feriado_flag IN ('t', 'f')),
        fds_flag            CHAR(1) DEFAULT 'f' CHECK (fds_flag IN ('t', 'f')),
        EVENT                   VARCHAR(50),
        UNIQUE td_ymd_idx (anio,mes,dia),
        UNIQUE td_dbdate_idx (db_date)
) ENGINE=INNODB;


DROP PROCEDURE IF EXISTS fill_date_dimension;
DELIMITER //
CREATE PROCEDURE fill_date_dimension(IN startdate DATE,IN stopdate DATE)
BEGIN
    DECLARE currentdate DATE;
    SET currentdate = startdate;
    WHILE currentdate < stopdate DO
        INSERT INTO time_dimension VALUES (
                        YEAR(currentdate)*10000+MONTH(currentdate)*100 + DAY(currentdate),
                        currentdate,
                        YEAR(currentdate),
                        MONTH(currentdate),
                        DAY(currentdate),
                        YEAR(currentdate)*100+MONTH(currentdate),
                        QUARTER(currentdate),
                        WEEKOFYEAR(currentdate),
                        CASE WHEN  DAYOFWEEK(currentdate)=1 THEN 'Domingo'
                             WHEN  DAYOFWEEK(currentdate)=2 THEN 'Lunes'
                             WHEN  DAYOFWEEK(currentdate)=3 THEN 'Martes'
                             WHEN  DAYOFWEEK(currentdate)=4 THEN 'Miercoles'
                             WHEN  DAYOFWEEK(currentdate)=5 THEN 'Jueves'
                             WHEN  DAYOFWEEK(currentdate)=6 THEN 'Viernes'
                             WHEN  DAYOFWEEK(currentdate)=7 THEN 'Sabado'END,
                        CASE WHEN MONTH(currentdate)=1 THEN 'Enero'
			     WHEN MONTH(currentdate)=2 THEN 'Febrero'
			     WHEN MONTH(currentdate)=3 THEN 'Marzo'
			     WHEN MONTH(currentdate)=4 THEN 'Abril'
			     WHEN MONTH(currentdate)=5 THEN 'Mayo'
			     WHEN MONTH(currentdate)=6 THEN 'Junio'
			     WHEN MONTH(currentdate)=7 THEN 'Julio'
			     WHEN MONTH(currentdate)=8 THEN 'Agosto'
			     WHEN MONTH(currentdate)=9 THEN 'Septiembre'
			     WHEN MONTH(currentdate)=10 THEN 'Octubre'
			     WHEN MONTH(currentdate)=11 THEN 'Noviembre'
			     WHEN MONTH(currentdate)=12 THEN 'Diciembre' END,
                        -- DATE_FORMAT(currentdate,'%W'),
                        -- DATE_FORMAT(currentdate,'%M'),

                        'f',
                        CASE DAYOFWEEK(currentdate) WHEN 1 THEN 't' WHEN 7 THEN 't' ELSE 'f' END,
                        NULL);
        SET currentdate = ADDDATE(currentdate,INTERVAL 1 DAY);
    END WHILE;
END
//
DELIMITER ;


TRUNCATE TABLE time_dimension;

CALL fill_date_dimension('2019-10-10','2029-12-31');
OPTIMIZE TABLE time_dimension;
SELECT * FROM  time_dimension
