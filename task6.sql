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




BEGIN
sys.dbms_scheduler.create_job(job_name => 'UPDATE_CURR_PRG',
job_type => 'PLSQL_BLOCK',
job_action => 'begin util.api_nbu_sync; end;',
start_date => SYSDATE,
repeat_interval => 'FREQ=DAILY;BYHOUR=6;BYMINUTE=00', -- кожень день в 6:00
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

BEGIN
     util.api_nbu_sync;
END;
/

SELECT * FROM all_scheduler_jobs sj;


ROLLBACK;     

--tests
SELECT * FROM sys_params;
SELECT * FROM cur_exchange;
DELETE FROM cur_exchange;


--
