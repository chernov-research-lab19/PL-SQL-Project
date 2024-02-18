/*3. Створення механізму звільнення існуючого співробітника

Опис задачі: в пакеті util створити процедуру fire_an_employee яка б звільняла інснуючого співробітника з таблиці employees
Розробити процедуру з назвою fire_an_employee, з такими параметрами:
   
   1  Викликати процедуру log_util.log_start

   2 Перевіряти чи існує p_employee_id, що передається в таблиці EMPLOYEES. 
   Якщо передали не існуючий ід співробітника, тоді помилка - RAISE_APPLICATION_ERROR(-20001,'Переданий співробітник не існує ')

   3 Перевіряти день та час при видаленні працівника. Не можна видаляти співробітника у суботу та неділю, а також з 18:01 до 07:59. 
    Якщо співробітника видаляють у невирішений час, тоді помилка - RAISE_APPLICATION_ERROR (-20001, 'Ви можете видаляти співробітника лише в робочий час');
    По можливості цей пункт можна завернути в окрему процедуру і пере викорастити її в процедурі util.add_employee в пункті 5 і тут.

   4 На останньому етапі, якщо всі перевірки пройшли успішно, то видалити (delete обвернути в PL-SQL блок) співробітника за переданим значенням у параметрі p_employee_id 
    з таблиці EMPLOYEES і видати повідомлення - "Співробітник ІМ'Я, ПРІЗВИЩЕ, КОД ПОСАДИ УСПІЛЬНОСТІ, ІД ДЕПАРТАМЕНТУ. 
    Якщо на єтапі деліту буде помилка, викликати процедуру log_util.log_error.

   5 Записати дані в таблицю і історичну employees_history. Архитектуру таблиці продумати самостійно. 

   6 Викликати процедуру log_util.log_finish */

CREATE TABLE employees_history2 
   (	
    employee_id NUMBER, 
	first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(50),
    phone_number VARCHAR2(50),
    hire_date DATE , 
    job_id VARCHAR2(10), 
    salary NUMBER,
    department_id NUMBER,
	LOG_DATE VARCHAR2(40)
   );

create or replace PACKAGE BODY util AS 
    
 PROCEDURE fire_an_employee(
                           p_employee_id IN NUMBER) IS
        v_text VARCHAR2(300);
        v_employee_id NUMBER;
        v_first_name VARCHAR2(50);
        v_last_name VARCHAR2(50);
        v_email VARCHAR2(50);
        v_phone_number VARCHAR2(50);
        v_hire_date DATE; 
        v_job_id VARCHAR2(10); 
        v_salary NUMBER;
        v_department_id NUMBER;
        v_LOG_DATE VARCHAR2(40);
        v_cur_date VARCHAR2(10);
        v_cur_time VARCHAR2(10);
     BEGIN

        log_util.log_start(p_proc_name => 'fire_an_employee',  p_text => 'fire_an_employee - start');
        
/* Перевіряти чи існує p_employee_id, що передається в таблиці EMPLOYEES. 
   Якщо передали не існуючий ід співробітника, тоді помилка - RAISE_APPLICATION_ERROR(-20001,'Переданий співробітник не існує ')   */
            <<check_p_employee_id>>
            BEGIN
                SELECT COUNT(*)
                INTO v_employee_id
                FROM employees em
                WHERE em.employee_id = p_employee_id;
                IF v_employee_id = 0 THEN
                     RAISE_APPLICATION_ERROR(-20001,'Переданий співробітник не існує');
                END IF;
            END check_p_employee_id;
            
           /*3 Перевіряти день та час при видаленні працівника. Не можна видаляти співробітника у суботу та неділю, а також з 18:01 до 07:59. 
    Якщо співробітника видаляють у невирішений час, тоді помилка - RAISE_APPLICATION_ERROR (-20001, 'Ви можете видаляти співробітника лише в робочий час');*/
            
            <<check_DATE_TIME>>
            BEGIN
               
                SELECT TO_CHAR(SYSDATE-3, 'DY', 'NLS_DATE_LANGUAGE=UKRAINIAN') INTO v_cur_date FROM DUAL;
                SELECT TO_CHAR(SYSTIMESTAMP, 'HH24') INTO v_cur_time FROM DUAL;
                IF ((v_cur_date = 'НД.') OR (v_cur_date = 'СБ.')) OR ((v_cur_time < '08') OR (v_cur_time > '18'))  THEN
                     RAISE_APPLICATION_ERROR(-20001,'Ви можете видаляти співробітника лише в робочий час');
                END IF;
           END check_DATE_TIME;

           SELECT 
           em.employee_id, em.first_name, em.last_name, em.email, em.phone_number, em.hire_date, em.job_id, em.salary, em.department_id
           INTO v_employee_id, v_first_name, v_last_name, v_email, v_phone_number, v_hire_date, v_job_id, v_salary, v_department_id
           FROM employees em
           WHERE em.employee_id =  p_employee_id;

           DELETE FROM employees em
           WHERE em.employee_id =  p_employee_id; 
              --COMMIT;
           dbms_output.put_line('Співробітник ' || v_first_name || ' ' || v_last_name || ' '  || v_job_id || ' '|| v_department_id || ' Deleted.');

        /* Записати дані в таблицю і історичну employees_history.*/
        
         INSERT INTO employees_history2(employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, department_id, LOG_DATE)
         VALUES (v_employee_id, v_first_name, v_last_name, v_email, v_phone_number, v_hire_date, v_job_id, v_salary, v_department_id, TO_CHAR(SYSDATE));
         dbms_output.put_line('Співробітник '||v_first_name|| ' ' || v_last_name || ' КОД ПОСАДИ ' || v_job_id  || ' added to employees_history2');
         log_util.log_finish(p_proc_name => 'fire_an_employee',  p_text => 'fire_an_employee - finish');

         EXCEPTION
         WHEN OTHERS THEN
             raise_application_error(-20003, 'Виникла помилка при delete spivrobitn. '|| SQLERRM);
             log_util.log_error(p_proc_name => 'fire_an_employee', p_sqlerrm  => 'Hz??', p_text => 'Eroor, error...');
   END fire_an_employee;
END util;


DECLARE
    p_text VARCHAR2(300):= 'some text';
BEGIN
   util.fire_an_employee(p_employee_id => 208);
  -- rollback;  
END;
/

         
--tests
SELECT * FROM logs
ORDER BY  log_date;
SELECT * FROM employees_history2;
SELECT * FROM employees;

/*

DECLARE
        
        v_employee_id NUMBER;
        v_first_name VARCHAR2(50);
        v_last_name VARCHAR2(50);
        v_email VARCHAR2(50);
        v_phone_number VARCHAR2(50);
        v_hire_date DATE; 
        v_job_id VARCHAR2(10) ; 
        v_salary NUMBER;
        v_department_id NUMBER;
BEGIN     
        SELECT  em.employee_id, em.first_name, em.last_name, em.email, em.phone_number, em.hire_date, em.job_id, em.salary, em.department_id
        INTO v_employee_id, v_first_name, v_last_name, v_email, v_phone_number, v_hire_date, v_job_id, v_salary, v_department_id
        FROM employees em
        WHERE em.employee_id =  108;
       
        
        INSERT INTO employees_history2(employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, department_id, LOG_DATE)
        VALUES (v_employee_id, v_first_name, v_last_name, v_email, v_phone_number, v_hire_date, v_job_id, v_salary, v_department_id, TO_CHAR(SYSDATE));
        dbms_output.put_line('Співробітник '||v_first_name|| ' ' || v_last_name || ' КОД ПОСАДИ ' || v_job_id  || ' added to employees_history');
        
END;
/*/

                      