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

    На останньому етапі, якщо всі перевірки пройшли успішно, додати нового співробітника (інсерт обвернути в PL-SQL блок) до таблиці EMPLOYEES, та видати повідомлення - "Співробітник ІМ'Я, Прізвище, КОД ПОСАДИ, ІД ДЕПАРТАМЕНТУ успішно додано до системи". Якщо на єтапі інсерту буде помилка, викликати процедуру log_util.log_error.

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
                            p_commission_pct IN VARCHAR2 DEFAULT NULL,
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
                            p_commission_pct IN VARCHAR2 DEFAULT NULL,
                            p_manager_id IN NUMBER DEFAULT 100,
                            p_department_id IN NUMBER) IS
        v_text VARCHAR2(300);
    BEGIN
        log_util.log_start(p_proc_name => 'add_employee',  p_text => 'add new employee - start');
        
        
        log_util.log_finish(p_proc_name => 'add_employee',  p_text => 'add new employee - finish');
    END add_employee;
END util;

--tests
SELECT * FROM logs;
SELECT * FROM jobs;
SELECT * FROM departments;
SELECT MIN_SALARY, MAX_SALARY FROM jobs
WHERE job_id = 'IT_QA';

SELECT CURRENT_TIMESTAMP FROM DUAL;
SELECT TO_CHAR(SYSTIMESTAMP, 'HH24:MI') AS "Current Time" FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'DY') AS "Day of the Week" FROM DUAL;
SELECT trunc(sysdate,'dd') as "поточний день без секунд" FROM DUAL;
--

DECLARE
    p_text VARCHAR2(300):= 'some text';
BEGIN
   util.add_employee( p_first_name => 'Ivan',
                      p_last_name => 'Ivanov',
                      p_email => 'eee@mail.com',
                      p_phone_number => '233467787',
                      -- p_hire_date,
                      p_job_id => 'IT_QA',
                      p_salary => 4000,
                      p_commission_pct => 12,
                      -- p_manager_id,
                      p_department_id => 110);
     
                    
END;
/