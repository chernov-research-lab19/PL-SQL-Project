create or replace PACKAGE BODY UTIL AS  
/*function get_sum_price_sales (p_table IN VARCHAR2) RETURN number IS 
    v_sum_price number;
    input_err EXCEPTION;
    v_dynamic_sql VARCHAR2(500);
    BEGIN
        BEGIN
            dbms_output.put_line(p_table);
            IF p_table <> 'products'  THEN
                RAISE input_err;
            END IF;
            ----
            v_dynamic_sql := 'SELECT SUM(pr.PRICE_SALES) FROM hr.' || p_table || ' pr';
            dbms_output.put_line(v_dynamic_sql);
            EXECUTE IMMEDIATE v_dynamic_sql INTO v_sum_price;
            RETURN v_sum_price;
        EXCEPTION
            WHEN input_err THEN
                    to_log(p_appl_proc => 'util.get_sum_price_sales', p_message => 'Неприпустиме значення! Очікується produ﻿cts або produ﻿cts_old');
                    raise_application_error(-20001, 'Неприпустиме значення! Очікується produ﻿cts або produ﻿cts_old');
        END;
END get_sum_price_sales;
  */
    
    
FUNCTION table_from_list(p_list_val IN VARCHAR2,
                            p_separator IN VARCHAR2 DEFAULT ',') RETURN tab_value_list PIPELINED IS
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
        FOR i IN 1..out_rec.count LOOP
            PIPE ROW(out_rec(i));
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

FUNCTION get_currency(p_currency IN VARCHAR2 DEFAULT 'USD',
                        p_exchangedate IN DATE DEFAULT SYSDATE) RETURN tab_exchange PIPELINED IS
out_rec tab_exchange := tab_exchange();
l_cur SYS_REFCURSOR;
BEGIN
    OPEN l_cur FOR
    SELECT tt.r030, tt.txt, tt.rate, tt.cur, TO_DATE(tt.exchangedate, 'dd.mm.yyyy') AS exchangedate
    FROM (SELECT get_needed_curr(p_valcode => p_currency,p_date => p_exchangedate) AS json_value FROM dual)
    CROSS JOIN json_table
    (
    json_value, '$[*]'
    COLUMNS
    (
        r030 NUMBER PATH '$.r030',
        txt VARCHAR2(100) PATH '$.txt',
        rate NUMBER PATH '$.rate',
        cur VARCHAR2(100) PATH '$.cc',
        exchangedate VARCHAR2(100) PATH '$.exchangedate'
    )
    ) TT;
    BEGIN
        LOOP
            EXIT WHEN l_cur%NOTFOUND;
            FETCH l_cur BULK COLLECT
            INTO out_rec;
            FOR i IN 1 .. out_rec.count LOOP
                PIPE ROW(out_rec(i));
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
END get_currency;


--Home Work 7-01


FUNCTION get_region_cnt_emp(p_department_id in number default null) RETURN tab_region_list PIPELINED IS 
out_rec tab_region_list := tab_region_list();
l_cur SYS_REFCURSOR;
BEGIN
    OPEN l_cur FOR
    SELECT ttt.region_name, ttt.cnt_employees
    FROM (select 
                --rg.region_id,
                nvl(rg.region_name,'Not defined') as region_name,
                count(em.employee_id) as cnt_employees
                from hr.regions rg
                
                right outer join hr.countries cn
                on rg.region_id = cn.region_id
                
                right outer join hr.locations lc
                on lc.country_id = cn.country_id
                
                right outer join hr.departments dp
                on lc.location_id = dp.location_id
                
                right outer join hr.employees em
                on em.department_id = dp.department_id
                where (em.department_id = p_department_id or p_department_id is null)
                group by rg.region_name
            ) ttt;
   
    BEGIN
    LOOP
        EXIT WHEN l_cur%NOTFOUND;
        FETCH l_cur BULK COLLECT
        INTO out_rec;
        FOR i IN 1..out_rec.count LOOP
            PIPE ROW(out_rec(i));
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
END get_region_cnt_emp;
--
    
END UTIL;