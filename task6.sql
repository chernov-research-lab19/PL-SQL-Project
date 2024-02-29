/*6. Створення механізму синхронізації даних з API у базу даних

Опис задачі: в пакеті util створити процедуру api_nbu_sync яка оновлювала дані по заданим валютам які записані в таблицю sys_params.

Сворити таблицю sys_params з такою структурою:

param_name    VARCHAR2(150),
value_date        DATE,
value_text         VARCHAR2(2000),
value_number NUMBER,
param_descr   VARCHAR2(200) 

Розробити процедуру з назвою api_nbu_sync, яка б оновлювала дані в таблиці cur_exchange кожен день в 6 ранку.

Вимоги до реалізації:

    Завести параметр list_currencies з значенням 'USD,EUR,KZT,AMD,GBP,ILS' в полі sys_params.value_text. 
    В поле sys_params.param_descr записати “Список валют для синхронізації в процедурі util.api_nbu_sync“.
    Завести змінну v_list_currencies, далі в PL-SQL боці в цю змінну записати значення з параметру list_currencies. 
    Запис обверунути в PL-SQL і якщо буде на цьому кроці помилка, видати помилку через RAISE_APPLICATION_ERROR та записати лог через процедуру log_util.log_error.
  
    В циклі прокрутити всі валюти через цей селект SELECT value_list AS curr FROM TABLE(util.table_from_list(p_list_val => v_list_currencies))
    При кожній ітерації цикла робити інсерт в таблицю cur_exchange з API SELECT * FROM TABLE(util.get_currency(p_currency => cc.curr));

    Викликати процедуру log_util.log_finish
*/


CREATE TABLE sys_params 
   (	
    param_name VARCHAR2(150), 
	value_date DATE,
    value_text VARCHAR2(2000),
    value_number NUMBER,
    param_descr VARCHAR2(200)
   );


create or replace PACKAGE util AS
    PROCEDURE api_nbu_sync(list_currencies IN VARCHAR2);
    TYPE rec_value_list IS RECORD (value_list VARCHAR2(100));
    TYPE tab_value_list IS TABLE OF rec_value_list;
    FUNCTION table_from_list(p_list_val IN VARCHAR2, p_separator IN VARCHAR2 DEFAULT ',') RETURN tab_value_list PIPELINED;
END util;

create or replace PACKAGE BODY util AS PROCEDURE api_nbu_sync(list_currencies IN VARCHAR2) IS
        
     v_list_currencies VARCHAR2(100);
     v_currency VARCHAR2(3);
 
    BEGIN
     -- Получение списка валют из параметра list_currencies
        begin
            INSERT INTO sys_params(value_text) VALUES (list_currencies);
            INSERT INTO sys_params(value_text) VALUES ('Список валют для синхронізації в процедурі util.api_nbu_sync');
            v_list_currencies := list_currencies;
           
            IF v_list_currencies IS NULL THEN
                log_util.log_error(p_proc_name => 'api_nbu_sync', p_sqlerrm  => 'Hz??', p_text => 'Параметр list_currencies не содержит значений.');
                raise_application_error(-20001, 'Параметр list_currencies не содержит значений.');
            END IF;
           
            EXCEPTION  WHEN OTHERS THEN
                 raise_application_error(-20003, 'Виникла помилка .... '|| SQLERRM);
                 log_util.log_error(p_proc_name => 'api_nbu_sync', p_sqlerrm  => 'Hz??', p_text => 'Eroor, error...');
        end;
    
    -- Обработка списка валют
    --  В циклі прокрутити всі валюти через цей селект SELECT value_list AS curr FROM TABLE(util.table_from_list(p_list_val => v_list_currencies))
    --  При кожній ітерації цикла робити інсерт в таблицю cur_exchange з API SELECT * FROM TABLE(util.get_currency(p_currency => cc.curr));

    
        FOR cc IN (SELECT value_list AS curr FROM TABLE(util.table_from_list(p_list_val => v_list_currencies))) LOOP
            v_currency := cc.curr;
    
            -- Вызов API для получения данных по валюте и вставка в таблицу cur_exchange
            INSERT INTO cur_exchange (currency_code, exchange_rate, exchange_date)
            SELECT * FROM TABLE(util.get_currency(p_currency => cc.curr));
        END LOOP;

        COMMIT; -- Фиксация изменений
        EXCEPTION
            WHEN OTHERS THEN
                log_util.log_error('Ошибка при выполнении процедуры api_nbu_sync: ' || SQLERRM);
                RAISE;
    
    log_util.log_finish(p_proc_name => 'api_nbu_sync',  p_text => 'api_nbu_sync - finish');
    

END api_nbu_sync;


FUNCTION table_from_list(p_list_val IN VARCHAR2, p_separator IN VARCHAR2 DEFAULT ',') RETURN tab_value_list PIPELINED IS
out_rec tab_value_list := tab_value_list();
l_cur SYS_REFCURSOR;
BEGIN
    OPEN l_cur FOR
    SELECT TRIM(REGEXP_SUBSTR(p_list_val, '[^'||p_separator||']+', 1, LEVEL)) AS cur_value
    FROM dual
    CONNECT BY LEVEL <= REGEXP_COUNT(p_list_val, p_separator) + 1;
    BEGIN
    LOOP
    EXIT WHEN l_cur%NOTFOUND;
    FETCH l_cur BULK COLLECT
    INTO out_rec;
    FOR i IN 1 .. out_rec.count LOOP
    PIPE ROW(
    out_rec(i));
    END LOOP;
    END LOOP;
    CLOSE l_cur;
    EXCEPTION
    WHEN OTHERS THEN
    IF (l_cur%ISOPEN) THEN
    CLOSE l_cur;
    RAISE;
    ELSE
    RAISE;
    END IF;
    END;
END table_from_list;
    
END util;



DECLARE
    p_text VARCHAR2(300):= 'some text';
BEGIN

     SELECT * FROM TABLE(util.api_nbu_sync(list_currencies => 'USD,EUR,KZT,AMD,GBP,ILS'));

END;
/



BEGIN
sys.dbms_scheduler.create_job(job_name
=> 'UPDATE_CURR_PRG',
job_type => 'PLSQL_BLOCK',
job_action => 'begin add_test_curr(); end;',
start_date => SYSDATE,
repeat_interval => 'FREQ=DAILY;BYHOUR=6;BYMINUTE=00', -- кожень день в 18:00
end_date => TO_DATE(NULL),
job_class => 'DEFAULT_JOB_CLASS',
enabled => TRUE,
auto_drop => FALSE,
comments => 'Оновлення курс валют тестовими даними');
END;
/

BEGIN
DBMS_SCHEDULER.RUN_JOB(job_name => 'UPDATE_CURR_PRG');
END;
/
SELECT *
FROM all_scheduler_jobs sj;


ROLLBACK;     
--tests
SELECT * FROM sys_params;



--
