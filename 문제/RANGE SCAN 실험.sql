
CREATE INDEX IX_T_EMP2_02 ON T_EMP2(DEPT_CODE, EMP_NAME);
CREATE INDEX IX_T_EMP2_03 ON T_EMP2(EMP_NAME, DEPT_CODE);
CREATE INDEX IX_T_DEPT2_01 ON T_DEPT2(LOC);

SELECT COUNT(DISTINCT DEPT_CODE) FROM T_EMP2; --99개
SELECT COUNT(DISTINCT EMP_NAME) FROM T_EMP2;  --1 개
--1번 =,=인 경우 차이
SELECT  /*+ GATHER_PLAN_STATISTICS NO_QUERY_TRANSFORMATION INDEX(E IX_T_EMP2_03) */
        E.EMP_NO,  E.EMP_NAME,  E.DIV_CODE, E.DEPT_CODE
FROM  T_EMP2  E
WHERE E.DEPT_CODE    = '25'
 AND  E.EMP_NAME = '12345678901234567890123456789012345678901234567890';
SELECT * FROM TABLE(DBMS_XPLAN.display_cursor('','','ALLSTATS'));
/* --------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              |      1 |        |   1026 |00:00:00.01 |     677 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_EMP2       |      1 |    843 |   1026 |00:00:00.01 |     677 |
|*  2 |   INDEX RANGE SCAN          | IX_T_EMP2_02 |      1 |    843 |   1026 |00:00:00.01 |      32 |
------------------------------------------------------------------------------------------------------*/
/*
---------------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              |      1 |        |   1026 |00:00:00.01 |     677 |     11 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_EMP2       |      1 |    843 |   1026 |00:00:00.01 |     677 |     11 |
|*  2 |   INDEX RANGE SCAN          | IX_T_EMP2_03 |      1 |    843 |   1026 |00:00:00.01 |      32 |     11 |
--------------------------------------------------------------------------------------------------------------- 
*/
=> 결론 : 똑같음

두번째 케이스 : >, =
;
SELECT COUNT(DISTINCT DEPT_CODE) FROM T_EMP2; --99개
SELECT COUNT(DISTINCT EMP_NAME) FROM T_EMP2;  --1 개
SELECT  /*+ GATHER_PLAN_STATISTICS NO_QUERY_TRANSFORMATION INDEX(E IX_T_EMP2_03) */
        E.EMP_NO,  E.EMP_NAME,  E.DIV_CODE, E.DEPT_CODE
FROM  T_EMP2  E
WHERE E.DEPT_CODE    > '25'
 AND  E.EMP_NAME = '12345678901234567890123456789012345678901234567890';
SELECT * FROM TABLE(DBMS_XPLAN.display_cursor('','','ALLSTATS'));
IX_T_EMP2_02
------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              |      1 |        |  74880 |00:00:00.14 |   49336 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_EMP2       |      1 |  74631 |  74880 |00:00:00.14 |   49336 |
|*  2 |   INDEX RANGE SCAN          | IX_T_EMP2_02 |      1 |  74631 |  74880 |00:00:00.05 |    2861 |
------------------------------------------------------------------------------------------------------
2 - access("E"."DEPT_CODE">'25' AND "E"."EMP_NAME"='123456789012345678901234567890123456789
          01234567890' AND "E"."DEPT_CODE" IS NOT NULL)
    filter("E"."EMP_NAME"='12345678901234567890123456789012345678901234567890')
IX_T_EMP2_03
---------------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              |      3 |        |    224K|00:00:00.38 |     145K|    681 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_EMP2       |      3 |  74631 |    224K|00:00:00.38 |     145K|    681 |
|*  2 |   INDEX RANGE SCAN          | IX_T_EMP2_03 |      3 |  74631 |    224K|00:00:00.12 |    6543 |    681 |
---------------------------------------------------------------------------------------------------------------
   2 - access("E"."EMP_NAME"='12345678901234567890123456789012345678901234567890' AND 
              "E"."DEPT_CODE">'25' AND "E"."DEPT_CODE" IS NOT NULL)
=> 결론 : 물론 변별력 차이가 별로 없으면 = 가 선행으로 오는 것이 당연히 좋겠지만, 만약 차이가 크다면, 그냥 변별력 좋은 걸 선행으로 잡는 게 나음

세번째 케이스 : =, >
;
SELECT  /*+ GATHER_PLAN_STATISTICS NO_QUERY_TRANSFORMATION INDEX(E IX_T_EMP2_03) */
        E.EMP_NO,  E.EMP_NAME,  E.DIV_CODE, E.DEPT_CODE
FROM  T_EMP2  E
WHERE E.DEPT_CODE  =   '26'
 AND  E.EMP_NAME >= '12345678901234567890123456789012345678901234567890';
SELECT * FROM TABLE(DBMS_XPLAN.display_cursor('','','ALLSTATS'));

------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              |      1 |        |   1021 |00:00:00.01 |     653 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_EMP2       |      1 |    915 |   1021 |00:00:00.01 |     653 |
|*  2 |   INDEX RANGE SCAN          | IX_T_EMP2_02 |      1 |    915 |   1021 |00:00:00.01 |      32 |
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              |      2 |        |   2042 |00:00:00.01 |    1390 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_EMP2       |      2 |    915 |   2042 |00:00:00.01 |    1390 |
|*  2 |   INDEX SKIP SCAN           | IX_T_EMP2_03 |      2 |    915 |   2042 |00:00:00.01 |     148 |
------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("E"."EMP_NAME">='12345678901234567890123456789012345678901234567890' AND 
              "E"."DEPT_CODE"='26' AND "E"."EMP_NAME" IS NOT NULL)
       filter("E"."DEPT_CODE"='26')

네번째 케이스 : >,>;
SELECT  /*+ GATHER_PLAN_STATISTICS NO_QUERY_TRANSFORMATION INDEX(E IX_T_EMP2_03) */
        E.EMP_NO,  E.EMP_NAME,  E.DIV_CODE, E.DEPT_CODE
FROM  T_EMP2  E
WHERE E.DEPT_CODE >=   '26'
 AND  E.EMP_NAME >= '12345678901234567890123456789012345678901234567890';
SELECT * FROM TABLE(DBMS_XPLAN.display_cursor('','','ALLSTATS'));

------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              |      1 |        |  74880 |00:00:00.15 |   49336 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_EMP2       |      1 |  74631 |  74880 |00:00:00.15 |   49336 |
|*  2 |   INDEX RANGE SCAN          | IX_T_EMP2_02 |      1 |  74631 |  74880 |00:00:00.05 |    2861 |
------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("E"."DEPT_CODE">='26' AND "E"."EMP_NAME">='1234567890123456789012345678901234567
              8901234567890' AND "E"."DEPT_CODE" IS NOT NULL)
       filter("E"."EMP_NAME">='12345678901234567890123456789012345678901234567890')
---------------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              |      1 |        |  74880 |00:00:00.16 |   51537 |      5 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_EMP2       |      1 |  74631 |  74880 |00:00:00.16 |   51537 |      5 |
|*  2 |   INDEX SKIP SCAN           | IX_T_EMP2_03 |      1 |  74631 |  74880 |00:00:00.07 |    5062 |      5 |
---------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("E"."EMP_NAME">='12345678901234567890123456789012345678901234567890' AND 
              "E"."DEPT_CODE">='26' AND "E"."EMP_NAME" IS NOT NULL)
       filter("E"."DEPT_CODE">='26')