/*2. Створення механізму додавання нового співробітника
Опис задачі: в пакеті util створити процедуру add_employee яка б додавала нового співробітника в таблицю employees
Розробити процедуру з назвою add_employee, з такими параметрами:

Вимоги до реалізації:

    Викликати процедуру log_util.log_start

    Перевірити, чи існує переданий код посади (P_JOB_ID) в таблиці JOBS. 
    Якщо передано неіснуючий код, викликати помилку - RAISE_APPLICATION_ERROR(-20001,'Введено неіснуючий код посади').

    Перевірити, чи існує переданий ідентифікатор відділу (P_DEPARTMENT_ID) в таблиці DEPARTMENTS. 
    Якщо передано неіснуючий ідентифікатор, викликати помилку - RAISE_APPLICATION_ERROR(-20001,'Введено неіснуючий ідентифікатор відділу').

    Перевірити передану заробітну плату на коректність за кодом посади (P_JOB_ID) в таблиці JOBS. 
    Якщо передана заробітна плата не входить у діапазон заробітних плат для даного коду посади (P_JOB_ID), викликати помилку - RAISE_APPLICATION_ERROR(-20001,'Введено неприпустиму заробітну плату для даного коду посади').

    Перевірити день і час при вставці. Неможливо додавати нового співробітника у суботу і неділю, а також з 18:01 до 07:59. 
    Якщо нового співробітника додають у недозволений час, викликати помилку - RAISE_APPLICATION_ERROR(-20001,'Ви можете додавати нового співробітника лише в робочий час').

    При додаванні нового співробітника вставити ідентифікатор EMPLOYEE_ID, який дорівнює максимальному EMPLOYEE_ID + 1 (за рахунок сіквенса або стоворити власну вкладену функцію), а решта значень взяти з вхідних параметрів.

    На останньому етапі, якщо всі перевірки пройшли успішно, додати нового співробітника (інсерт обвернути в PL-SQL блок) до таблиці EMPLOYEES, та видати повідомлення 
    - "Співробітник ІМ'Я, Прізвище, КОД ПОСАДИ, ІД ДЕПАРТАМЕНТУ успішно додано до системи". Якщо на єтапі інсерту буде помилка, викликати процедуру log_util.log_error.

    Викликати процедуру log_util.log_finish


*/

create or replace PACKAGE util AS
    PROCEDURE add_employee( p_first_name IN VARCHAR2,
                            p_last_name IN VARCHAR2,
                            p_email IN VARCHAR2,
                            p_phone_number IN VARCHAR2 ,
                            p_hire_date IN DATE DEFAULT trunc(sysdate, 'dd'),
                            p_job_id IN VARCHAR2,
                            p_salary IN NUMBER,
                            p_commission_pct IN NUMBER DEFAULT NULL,
                            p_manager_id IN NUMBER DEFAULT 100,
                            p_department_id IN NUMBER);
END util;


create or replace PACKAGE BODY util AS PROCEDURE add_employee(
                            p_first_name IN VARCHAR2,
                            p_last_name IN VARCHAR2,
                            p_email IN VARCHAR2,
                            p_phone_number IN VARCHAR2 ,
                            p_hire_date IN DATE DEFAULT trunc(sysdate, 'dd'),
                            p_job_id IN VARCHAR2,
                            p_salary IN NUMBER,
                            p_commission_pct IN NUMBER DEFAULT NULL,
                            p_manager_id IN NUMBER DEFAULT 100,
                            p_department_id IN NUMBER) IS
        v_text VARCHAR2(300);
        job_err EXCEPTION;
        dep_err EXCEPTION;
        v_is_exist_job NUMBER;
        v_is_exist_dep NUMBER;
        v_min_sal  NUMBER;
        v_max_sal  NUMBER;
        v_cur_date VARCHAR2(10);
        v_cur_time VARCHAR2(10);
        v_employeeid NUMBER;
        
       FUNCTION get_max_employeeid RETURN NUMBER IS
            v_employeeid NUMBER;
            BEGIN
            SELECT NVL(MAX(employee_id),0)+1
                INTO v_employeeid
                FROM employees;
            RETURN v_employeeid;
        END get_max_employeeid;
            
        
        
    BEGIN
    
     
        log_util.log_start(p_proc_name => 'add_employee',  p_text => 'add new employee - start');
        
          -- Перевірити, чи існує переданий код посади (P_JOB_ID) в таблиці JOBS. 
             -- Якщо передано неіснуючий код, викликати помилку - RAISE_APPLICATION_ERROR(-20001,'Введено неіснуючий код посади').
            /*  IF (p_job_id NOT IN (SELECT j.job_id FROM JOBS j)) THEN
                    RAISE job_err;
              END IF;        */
            <<check_P_JOB_ID>>
            BEGIN
                SELECT COUNT(*)
                INTO v_is_exist_job
                FROM JOBS j
                WHERE j.job_id = p_job_id;
                IF v_is_exist_job=0 THEN
                     RAISE_APPLICATION_ERROR(-20001,'Введено неіснуючий код посади');
                   -- RAISE job_err;
                END IF;
            END check_P_JOB_ID;
            
            -- Перевірити, чи існує переданий ідентифікатор відділу (P_DEPARTMENT_ID) в таблиці DEPARTMENTS. 
            -- Якщо передано неіснуючий ідентифікатор, викликати помилку - RAISE_APPLICATION_ERROR(-20001,'Введено неіснуючий ідентифікатор відділу').
            <<check_P_DEPARTMENT_ID>>
            BEGIN
                SELECT COUNT(*)
                INTO v_is_exist_dep
                FROM DEPARTMENTS dp
                WHERE dp.department_id = p_department_id;
                IF v_is_exist_dep=0 THEN
                     RAISE_APPLICATION_ERROR(-20001,'Введено неіснуючий ідентифікатор відділу');
                    -- RAISE dep_err;
                END IF;
                
   
            END check_P_DEPARTMENT_ID;

            -- Перевірити передану заробітну плату на коректність за кодом посади (P_JOB_ID) в таблиці JOBS. 
            -- Якщо передана заробітна плата не входить у діапазон заробітних плат для даного коду посади (P_JOB_ID), 
            -- викликати помилку - RAISE_APPLICATION_ERROR(-20001,'Введено неприпустиму заробітну плату для даного коду посади').
            <<check_SALARY>>
            BEGIN
                SELECT j.MIN_SALARY, j.MAX_SALARY 
                INTO v_min_sal, v_max_sal 
                FROM JOBS j
                WHERE j.job_id = p_job_id;
                IF (p_salary <= v_min_sal) OR (p_salary >= v_max_sal)  THEN
                     RAISE_APPLICATION_ERROR(-20001,'Введено неприпустиму заробітну плату для даного коду посади');
                    -- RAISE dep_err;
                END IF;
            END check_SALARY;
            
            -- Перевірити день і час при вставці. Неможливо додавати нового співробітника у суботу і неділю, а також з 18:01 до 07:59. 
            -- Якщо нового співробітника додають у недозволений час, викликати 
            -- помилку - RAISE_APPLICATION_ERROR(-20001,'Ви можете додавати нового співробітника лише в робочий час').
           
           -- Ne prazue!
            <<check_DATE_TIME>>
            BEGIN
               
                SELECT TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=UKRAINIAN') INTO v_cur_date FROM DUAL;
                SELECT TO_CHAR(SYSTIMESTAMP, 'HH24') INTO v_cur_time FROM DUAL;
                IF ((v_cur_date = 'НД.') OR (v_cur_date = 'СБ.')) OR ((v_cur_time < '08') OR (v_cur_time > '18'))  THEN
                     RAISE_APPLICATION_ERROR(-20001,'Ви можете додавати нового співробітника лише в робочий час');
                END IF;
          END check_DATE_TIME;



            v_employeeid := get_max_employeeid();
            INSERT INTO employees(employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
                VALUES (v_employeeid, p_first_name, p_last_name, p_email, p_phone_number, p_hire_date, p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id);
                --po_err := 'Spivrobitnik '||p_first_name||' успішно додан';
                dbms_output.put_line('Співробітник '||p_first_name|| ' ' || p_last_name || ' КОД ПОСАДИ ' || 'p_job_id'  || 'ІД ДЕПАРТАМЕНТУ ' || p_department_id || ' успішно доданий до  .');
           
                EXCEPTION
                WHEN OTHERS THEN
                    raise_application_error(-20003, 'Виникла помилка при додаванні нов spivrobitn. '|| SQLERRM);
                    log_util.log_error(p_proc_name => 'add_employee', p_sqlerrm  => 'Hz??', p_text => 'Eroor, error...');
        
        
        log_util.log_finish(p_proc_name => 'add_employee',  p_text => 'add new employee - finish');
    END add_employee;
END util;



DECLARE
    p_text VARCHAR2(300):= 'some text';
BEGIN
   util.add_employee( p_first_name => 'Sidor',
                      p_last_name => 'Sidorov',
                      p_email => 'hhh@mail.com',
                      p_phone_number => '233467787',
                      p_hire_date =>  trunc(sysdate, 'dd'),
                      p_job_id => 'IT_QA',
                      p_salary => 6000,
                      p_commission_pct => 0.5,
                      p_manager_id => 10,
                      p_department_id => 110);
     
                    
END;
/

              /*      p_first_name IN VARCHAR2,
                            p_last_name IN VARCHAR2,
                            p_email IN VARCHAR2,
                            p_phone_number IN VARCHAR2 ,
                            p_hire_date IN DATE DEFAULT trunc(sysdate, 'dd'),
                            p_job_id IN VARCHAR2,
                            p_salary IN NUMBER,
                            p_commission_pct IN VARCHAR2 DEFAULT NULL,
                            p_manager_id IN NUMBER DEFAULT 100,
                            p_department_id IN NUMBER*/
       
--tests
SELECT * FROM logs
ORDER BY  log_date;

SELECT * FROM jobs;
SELECT * FROM departments;
SELECT * FROM employees;

SELECT MIN_SALARY, MAX_SALARY FROM jobs
WHERE job_id = 'IT_QA';

SELECT CURRENT_TIMESTAMP FROM DUAL;

SELECT TO_CHAR(SYSTIMESTAMP, 'HH24') AS "Current Time" FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'DY') AS "Day of the Week" FROM DUAL;

SELECT trunc(sysdate,'dd') as "поточний день без секунд" FROM DUAL;
--
                      