create or replace PACKAGE  UTIL AS

TYPE rec_value_list IS RECORD (value_list VARCHAR2(100));
TYPE tab_value_list IS TABLE OF rec_value_list;

TYPE rec_exchange IS RECORD (   r030 NUMBER,
                                txt VARCHAR2(100),
                                rate NUMBER,
                                cur VARCHAR2(100),
                                exchangedate DATE );
TYPE tab_exchange IS TABLE OF rec_exchange;



--Home Work 7-01
TYPE rec_region_list IS RECORD (    region_name VARCHAR2(20),
                                    cnt_employees NUMBER
                                );
TYPE tab_region_list IS TABLE OF rec_region_list;

FUNCTION get_region_cnt_emp(p_department_id in number default null) RETURN tab_region_list PIPELINED;
--




--function get_sum_price_sales (p_table IN VARCHAR2) RETURN number;
FUNCTION table_from_list(p_list_val IN VARCHAR2, p_separator IN VARCHAR2 DEFAULT ',') RETURN tab_value_list  PIPELINED;
FUNCTION get_currency(p_currency IN VARCHAR2 DEFAULT 'USD', p_exchangedate IN DATE DEFAULT SYSDATE) RETURN tab_exchange PIPELINED;





END UTIL;