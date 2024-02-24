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
        v_parameter_exists BOOLEAN := FALSE;
        v_sql VARCHAR2(1000);
        v_employee_id NUMBER;
    
 
    BEGIN

        log_util.log_start(p_proc_name => 'change_attribute_employee',  p_text => 'change_attribute_employee - start');
        
          /* Перевіряти чи існує p_employee_id, що передається в таблиці EMPLOYEES. 
   Якщо передали не існуючий ід співробітника, тоді помилка - RAISE_APPLICATION_ERROR(-20001,'Переданий співробітник не існує ')
   */
         
           
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
       
     -- Перевірка наявності хоча б одного параметра, крім p_employee_id      
     <<check_any_param>>
     BEGIN  
            IF (p_first_name IS NOT NULL OR
                p_last_name IS NOT NULL OR 
                p_email IS NOT NULL OR 
                p_phone_number IS NOT NULL OR 
                p_job_id IS NOT NULL OR 
                p_salary IS NOT NULL  OR 
                p_commission_pct IS NOT NULL OR
                p_manager_id IS NOT NULL OR 
                p_department_id IS NOT NULL) THEN
                    v_parameter_exists := TRUE;
            END IF;
            
            -- Якщо немає жодного непустого параметра, логуємо помилку та виходимо
            IF NOT v_parameter_exists THEN
                log_util.log_finish(p_proc_name => 'fire_an_employee', p_text =>'Не вказано жодного параметра для оновлення.');
                RETURN;
            END IF;

      END check_any_param;
           
            
          -- this code is good
          /* UPDATE employees 
                SET 
                    employee_id = p_employee_id, 
                    first_name = p_first_name, 
                    last_name = p_last_name, 
                    email = p_email, 
                    phone_number = p_phone_number,
                    job_id = p_job_id, 
                    salary = p_salary, 
                    commission_pct = p_commission_pct,
                    manager_id = p_manager_id,
                    department_id = p_department_id

                WHERE 
                    employee_id = p_employee_id;*/
                    
        v_sql := 'UPDATE employees SET ';
        
        IF p_first_name IS NOT NULL THEN
            v_sql := v_sql || 'first_name = :p_first_name, ';
        END IF;
        
        IF p_last_name IS NOT NULL THEN
            v_sql := v_sql || 'last_name = :p_last_name, ';
        END IF;
        
        IF p_email IS NOT NULL THEN
            v_sql := v_sql || 'email = :p_email, ';
        END IF;
        
        IF p_phone_number IS NOT NULL THEN
            v_sql := v_sql || 'phone_number = :p_phone_number, ';
        END IF;
        
        IF p_job_id IS NOT NULL THEN
            v_sql := v_sql || 'job_id = :p_job_id, ';
        END IF;
        
        IF p_salary IS NOT NULL THEN
            v_sql := v_sql || 'salary = :p_salary, ';
        END IF;
        
        IF p_commission_pct IS NOT NULL THEN
            v_sql := v_sql || 'commission_pct = :p_commission_pct, ';
        END IF;
        
        IF p_manager_id IS NOT NULL THEN
            v_sql := v_sql || 'manager_id = :p_manager_id, ';
        END IF;
        
        IF p_department_id IS NOT NULL THEN
            v_sql := v_sql || 'department_id = :p_department_id';
        END IF;

        -- Додавання умови WHERE
        v_sql := v_sql || ' WHERE employee_id = :p_employee_id';

        -- Виконання динамічного SQL
        EXECUTE IMMEDIATE v_sql
        USING 
            p_first_name, 
            p_last_name, 
            p_email, 
            p_phone_number,
            p_job_id, 
            p_salary, 
            p_commission_pct,
            p_manager_id,
            p_department_id,
            p_employee_id;

            
            dbms_output.put_line('У співробітника ' || p_employee_id || ' успішно оновлені атрибути');
            
   
                EXCEPTION
                WHEN OTHERS THEN
                    raise_application_error(-20003, 'Виникла помилка при updade spivrobitn. '|| SQLERRM);
                    log_util.log_error(p_proc_name => 'change_attribute_employee', p_sqlerrm  => 'Hz??', p_text => 'Eroor, error...');
        
                  
         log_util.log_finish(p_proc_name => 'change_attribute_employee',  p_text => 'change_attribute_employee - finish');
    END change_attribute_employee;
END util;



DECLARE
    p_text VARCHAR2(300):= 'some text';
BEGIN
   util.change_attribute_employee(
                      p_employee_id => 1 ,
                      p_first_name => 'Nic3',
                      p_last_name => 'Nic3',
                      p_email => 'nnn@mail.com',
                      p_phone_number => '233467787',
                      p_job_id => 'IT_QA'
                     /* po umolchaniu NULL
                      p_salary => 6000,
                      p_commission_pct => 0.3,
                      p_manager_id => 20,
                      p_department_id => 130*/
                      ); 
     
                    
END;
/

    ROLLBACK;     
--tests
SELECT * FROM logs
ORDER BY  log_date;
SELECT * FROM employees_history2;
SELECT * FROM employees;

