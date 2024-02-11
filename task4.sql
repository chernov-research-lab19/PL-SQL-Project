/*4. Створення механізму зміни атрибутів співробітника

Опис задачі: в пакеті util створити процедуру change_attribute_employee яка б дозволяла змінювати будь-який атрибут співробітника в таблиці employees.

Розробити процедуру з назвою change_attribute_employee, з такими параметрами:

  1  Викликати процедуру log_util.log_start

  2  Перевірити, що мінімум в одному параметрі (окрім p_employee_id) є значення НЕ NULL через OR, інакше помилка і виклик процедури log_util.log_finish.

  3  Перевіряти який з вхідних параметрів не пустий і для такого параметра зробити UPDATE в таблиці employees.
   Механізм продумати самостійно. Бажано зробити через дінамічний SQL. Але для першого варіанта цієї процедуру підійде варіант через IF..ELSIF..END IF на кожний вхідний параметр.

  4  На етапі, коли робите оновлення атрибута (update обвернути в PL-SQL блок) співробітника, при успіху видати повідомлення - 
    'У співробітника p_employee_id успішно оновлені атрибути'. Якщо на єтапі оновлення буде помилка, викликати процедуру log_util.log_error.

*/




create or replace PACKAGE util AS
    PROCEDURE change_attribute_employee(
                            p_employee_id IN NUMBER,
                            p_first_name IN VARCHAR2 DEFAULT NULL,
                            p_last_name IN VARCHAR2 DEFAULT NULL,
                            p_email IN VARCHAR2 DEFAULT NULL,
                            p_phone_number IN VARCHAR2 DEFAULT NULL,
                            p_job_id IN VARCHAR2 DEFAULT NULL,
                            p_salary IN NUMBER DEFAULT NULL,
                            p_commission_pct IN NUMBER DEFAULT NULL,
                            p_manager_id IN NUMBER DEFAULT NULL,
                            p_department_id IN NUMBER DEFAULT NULL);
END util;

create or replace PACKAGE BODY util AS PROCEDURE change_attribute_employee(
                            p_employee_id IN NUMBER,
                            p_first_name IN VARCHAR2 DEFAULT NULL,
                            p_last_name IN VARCHAR2 DEFAULT NULL,
                            p_email IN VARCHAR2 DEFAULT NULL,
                            p_phone_number IN VARCHAR2 DEFAULT NULL,
                            p_job_id IN VARCHAR2 DEFAULT NULL,
                            p_salary IN NUMBER DEFAULT NULL,
                            p_commission_pct IN NUMBER DEFAULT NULL,
                            p_manager_id IN NUMBER DEFAULT NULL,
                            p_department_id IN NUMBER DEFAULT NULL) IS
        
        v_text VARCHAR2(300);
        v_employee_id NUMBER;
        v_first_name VARCHAR2(50);
        v_last_name VARCHAR2(50);
        v_email VARCHAR2(50);
        v_phone_number VARCHAR2(50);
        v_job_id NUMBER; 
        v_salary NUMBER;
        v_commission_pct NUMBER;
        v_manager_id NUMBER;
        v_department_id NUMBER;
      
 
    BEGIN

        log_util.log_start(p_proc_name => 'change_attribute_employee',  p_text => 'change_attribute_employee - start');
        
          /* Перевіряти чи існує p_employee_id, що передається в таблиці EMPLOYEES. 
   Якщо передали не існуючий ід співробітника, тоді помилка - RAISE_APPLICATION_ERROR(-20001,'Переданий співробітник не існує ')
   */
            <<check_input_data>>
            BEGIN
            IF (v_first_name is NULL) OR (v_last_name = is NULL) OR (v_email is NULL) OR (v_phone_number is NULL) OR (v_job_id is NULL) OR 
            (v_salary = is NULL) OR (v_commission_pct is NULL) OR (v_manager_id is NULL) OR (v_department_id is NULL)  THEN
                     RAISE_APPLICATION_ERROR(-20001,'NUL in Input parameters');
                     log_util.log_finish(p_proc_name => 'change_attribute_employee',  p_text => 'change_attribute_employee - finish');
            END IF;
            
            END check_input_data;
            
            
   
p_first_name


          /* UPDATE balance b
            SET b.balance = v_balance_old - p_balance*/
            WHERE employee_id = p_employee_id
            dbms_output.put_line('У співробітника ' || p_employee_id || ' успішно оновлені атрибути');
            

           
                EXCEPTION
                WHEN OTHERS THEN
                    raise_application_error(-20003, 'Виникла помилка при updade spivrobitn. '|| SQLERRM);
                    log_util.log_error(p_proc_name => 'change_attribute_employee', p_sqlerrm  => 'Hz??', p_text => 'Eroor, error...');
        
                  
         --log_util.log_finish(p_proc_name => 'change_attribute_employee',  p_text => 'change_attribute_employee - finish');
    END change_attribute_employee;
END util;



DECLARE
    p_text VARCHAR2(300):= 'some text';
BEGIN
   util.change_attribute_employee( 
                      p_first_name => 'Nic',
                      p_last_name => 'Nic',
                      p_email => 'nnn@mail.com',
                      p_phone_number => '233467787',
                      p_job_id => 'IT_QA',
                      p_salary => 6000,
                      p_commission_pct => 0.3,
                      p_manager_id => 20,
                      p_department_id => 130
                      ); 
     
                    
END;
/

         
--tests
SELECT * FROM logs
ORDER BY  log_date;
SELECT * FROM employees_history;
SELECT * FROM employees;




                      