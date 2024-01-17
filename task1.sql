/*
1. Створення механізму логування будь-якого процесу

Опис задачі: розробити пакет log_util та оголосити там три процедури log_start, log_finish, log_error.
Вимоги до реалізації:
Існуючу процедуру to_log оголосити тільки в body пакета log_util
1. Розробити процедуру з назвою log_start, з такими параметрами:
2. Перевірити, чи вхідний параметр p_text має значення NULL. Якщо p_text має значення NULL, то присвоїти змінній v_text значення 'Старт логування, назва процесу = ' додане до значення параметру p_proc_name. 
В іншому випадку, присвоїти змінній v_text значення параметру p_text.
3. Викликати процедуру to_log з наступними параметрами: to_log(p_appl_proc => p_proc_name, p_message => p_text);
 

1. Розробити процедуру з назвою log_finish, з такими параметрами:
2. Перевірити, чи вхідний параметр p_text має значення NULL. Якщо p_text має значення NULL, то присвоїти змінній v_text значення 'Завершення логування, назва процесу = ' додане до значення параметру p_proc_name. 
В іншому випадку, присвоїти змінній v_text значення параметру p_text.
3. Викликати процедуру to_log з наступними параметрами: to_log(p_appl_proc => p_proc_name, p_message => p_text);

1. Розробити процедуру з назвою log_error, з такими параметрами:
2. Перевірити, чи вхідний параметр  p_text має значення NULL. Якщо p_text має значення NULL, то присвоїти змінній v_text значення 'В процедурі ' || p_proc_name || ' сталася помилка. ' || p_sqlerrm. 
В іншому випадку, присвоїти змінній v_text значення параметру p_text.
3. Викликати процедуру to_log з наступними параметрами: to_log(p_appl_proc => p_proc_name, p_message => p_text);*/


create or replace PACKAGE log_util AS

    PROCEDURE log_start(p_proc_name IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL);
    PROCEDURE log_finish(p_proc_name IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL);
    PROCEDURE log_error(p_proc_name IN VARCHAR2, p_sqlerrm IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL);
   
END log_util;


create or replace PACKAGE BODY log_util AS 
    PROCEDURE log_start(p_proc_name IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL) IS
        v_text VARCHAR2(50);
    BEGIN
        IF p_text IS NULL THEN
            v_text := 'Старт логування, назва процесу = ' || p_proc_name;
        ELSE
            v_text := p_text;
        END IF;
        dbms_output.put_line (v_text);

    END log_start;
    ----------
    PROCEDURE log_finish(p_proc_name IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL) IS 
        v_text VARCHAR2(50);
    BEGIN
        IF p_text IS NULL THEN
            v_text := 'Завершення логування, назва процесу =  ' || p_proc_name;
        ELSE
            v_text := p_text;
        END IF;
        dbms_output.put_line (v_text);

    END log_finish;
    ----------
    PROCEDURE log_error(p_proc_name IN VARCHAR2, p_sqlerrm IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL) IS 
        v_text VARCHAR2(50);
    BEGIN
        IF p_text IS NULL THEN
            v_text :=  'В процедурі ' || p_proc_name || ' сталася помилка. ' || p_sqlerrm;
        ELSE
            v_text := p_text;
        END IF;
        dbms_output.put_line (v_text);


    END log_error;
    -----------
    PROCEDURE to_log(p_appl_proc IN VARCHAR2, p_message IN VARCHAR2) IS PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO logs(id, appl_proc, message)
        VALUES(log_seq.NEXTVAL, p_appl_proc, p_message);
        COMMIT;
    END to_log;
    
    
    
END log_util;




DECLARE
    p_text VARCHAR2(50):= 'some text';
 
BEGIN
    to_log(p_appl_proc => 'log_start', p_message => NULL);
    to_log(p_appl_proc => 'log_finish', p_message => NULL);
    to_log(p_appl_proc => 'log_finish', p_message => p_text);
    to_log(p_appl_proc => 'log_error', p_message => NULL);
    to_log(p_appl_proc => 'log_error',  p_message => p_text);
END;
/



SELECT * FROM logs;


DECLARE
    --p_text VARCHAR2(50):= 'some text';
BEGIN
    log_util.log_start(p_proc_name => 'log_start',  p_text => NULL); -- Ne rabotaet!!!!!!
    log_util.log_finish(p_proc_name => 'log_finish', p_text => 'some text');
    log_util.log_error(p_proc_name => 'log_error', p_sqlerrm => 'some text', p_text => 'some text');
    
END;
/

