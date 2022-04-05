/*
T_CUST33 ���̺� ����
   CUST_NO       VARCHAR2(7),
   CUST_NM       VARCHAR2(50),
   CUST_CD       VARCHAR2(3),
   DIV           VARCHAR2(3),
   FLAG          VARCHAR2(2),
   C1            VARCHAR2(30),
   C2            VARCHAR2(30),
   C3            VARCHAR2(30),
   C4            VARCHAR2(30),
   C5            VARCHAR2(30)
   
PRIMARY KEY : CUST_NO
�ε���      : CUST_CD + FLAG + DIV


T_CUST33  200����
  - CUST_CD   200�� ����(001 ~ 200),  �ڵ�� �Ǽ��� ��  1���� 
  - DIV       100�� ����(001 ~ 100),  �ڵ�� �Ǽ��� ��  2����
  - FLAG      10��  ����(01 ~ 10),    �ڵ�� �Ǽ��� �� 20����

����) ȭ�鿡 CUST_CD, FLAG,  DIV 3���� ��ȸ ������ �����Ѵ�.  
      CUST_CD,  DIV�� �ʼ�������,  FLAG�� ���� �����̴�.
      3������ ��� �ԷµǾ��� ��� ��� ��� �Ǽ��� 11���̸�,
      FLAG�� �Էµ��� �ʾ��� ��� ��� ��� �Ǽ��� 100�� ���̴�.
      �Ʒ��� SQL�� Ʃ�� �ϼ���.   
      FLAG ������ ������ ���� �����ڸ� LIKE ��� "="��
      �����ص� ������� �����ϴ�.
      
      FLAG�� NULLABLE �� ���� NOT NULL �Ӽ��� ��� 2������ 
      Ǯ�� ������.
*/
 ALTER SESSION SET STATISTICS_LEVEL = ALL;
 /*+ GATHER_PLAN_STATISTICS */
 SELECT * FROM TABLE(DBMS_XPLAN.display_cursor(NULL,NULL, 'ADVANCED ALLSTATS LAST'));
CUST_CD  FLAG  DIV 
124     	460	 50 	12
181     	030	 20	  14
110	      890  40	  24
SELECT /*+ GATHER_PLAN_STATISTICS */ * FROM T_CUST33 
WHERE CUST_CD =    :CUST_CD
  AND FLAG    LIKE :FLAG|| '%'
  AND DIV     =    :DIV 
;
/* Ʃ�� �� ���� ��ȹ
1) FLAG NULLABLE �϶�
- FLAG ���� ������ ��
-------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name        | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |             |      1 |        |       |    13 (100)|          |     24 |00:00:00.01 |      27 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_CUST33    |      1 |     81 | 10206 |    13   (0)| 00:00:01 |     24 |00:00:00.01 |      27 |
|*  2 |   INDEX RANGE SCAN          | IX_T_CUST33 |      1 |      6 |       |     7   (0)| 00:00:01 |     24 |00:00:00.01 |       3 |
-------------------------------------------------------------------------------------------------------------------------------------
- FLAG ���� �� ������ ��
----------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name        | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | A-Rows |   A-Time   | Buffers | Reads  |
----------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |             |      1 |        |       |    13 (100)|          |    191 |00:00:00.02 |     259 |    116 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_CUST33    |      1 |     81 | 10206 |    13   (0)| 00:00:01 |    191 |00:00:00.02 |     259 |    116 |
|*  2 |   INDEX RANGE SCAN          | IX_T_CUST33 |      1 |      6 |       |     7   (0)| 00:00:01 |    191 |00:00:00.01 |      68 |      0 |
----------------------------------------------------------------------------------------------------------------------------------------------
   2 - access("CUST_CD"=:CUST_CD AND "FLAG" LIKE :FLAG||'%' AND "DIV"=:DIV)
       filter(("DIV"=:DIV AND "FLAG" LIKE :FLAG||'%'))
*/
/* Ʃ��  - NULLABLE �϶� */
CREATE INDEX IX02_T_CUST33 ON T_CUST33(CUST_CD, DIV, FLAG);
 SELECT * FROM TABLE(DBMS_XPLAN.display_cursor(NULL,NULL, 'ADVANCED ALLSTATS LAST'));
SELECT /*+ GATHER_PLAN_STATISTICS NO_QUERY_TRANSFORMATION INDEX(T1 IX02_T_CUST33) */ 
* FROM t_cust33
WHERE :FLAG IS NULL
AND CUST_CD = :CUST_CD
AND DIV = :DIV
UNION ALL
SELECT /*+ GATHER_PLAN_STATISTICS NO_QUERY_TRANSFORMATION INDEX(T1 IX02_T_CUST33) */ 
* FROM T_CUST33 T1
WHERE CUST_CD =    :CUST_CD
  AND :FLAG IS NOT NULL
  AND FLAG    = :FLAG
  AND DIV     =    :DIV 
;
/* Ʃ�� �� �����ȹ
- FLAG ������ ������ ��
-----------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name          | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | A-Rows |   A-Time   | Buffers |
-----------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |               |      1 |        |       |    39 (100)|          |     24 |00:00:00.01 |      27 |
|   1 |  UNION-ALL                    |               |      1 |        |       |            |          |     24 |00:00:00.01 |      27 |
|*  2 |   FILTER                      |               |      1 |        |       |            |          |      0 |00:00:00.01 |       0 |
|   3 |    TABLE ACCESS BY INDEX ROWID| T_CUST33      |      0 |    208 | 26208 |    35   (0)| 00:00:01 |      0 |00:00:00.01 |       0 |
|*  4 |     INDEX RANGE SCAN          | IX02_T_CUST33 |      0 |     33 |       |     3   (0)| 00:00:01 |      0 |00:00:00.01 |       0 |
|*  5 |   FILTER                      |               |      1 |        |       |            |          |     24 |00:00:00.01 |      27 |
|   6 |    TABLE ACCESS BY INDEX ROWID| T_CUST33      |      1 |      2 |   252 |     4   (0)| 00:00:01 |     24 |00:00:00.01 |      27 |
|*  7 |     INDEX RANGE SCAN          | IX02_T_CUST33 |      1 |      1 |       |     3   (0)| 00:00:01 |     24 |00:00:00.01 |       3 |
-----------------------------------------------------------------------------------------------------------------------------------------
- FLAG ������ �� ������ ��
-----------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name          | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | A-Rows |   A-Time   | Buffers |
-----------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |               |      1 |        |       |    39 (100)|          |    191 |00:00:00.01 |     197 |
|   1 |  UNION-ALL                    |               |      1 |        |       |            |          |    191 |00:00:00.01 |     197 |
|*  2 |   FILTER                      |               |      1 |        |       |            |          |    191 |00:00:00.01 |     197 |
|   3 |    TABLE ACCESS BY INDEX ROWID| T_CUST33      |      1 |    208 | 26208 |    35   (0)| 00:00:01 |    191 |00:00:00.01 |     197 |
|*  4 |     INDEX RANGE SCAN          | IX02_T_CUST33 |      1 |     33 |       |     3   (0)| 00:00:01 |    191 |00:00:00.01 |       6 |
|*  5 |   FILTER                      |               |      1 |        |       |            |          |      0 |00:00:00.01 |       0 |
|   6 |    TABLE ACCESS BY INDEX ROWID| T_CUST33      |      0 |      2 |   252 |     4   (0)| 00:00:01 |      0 |00:00:00.01 |       0 |
|*  7 |     INDEX RANGE SCAN          | IX02_T_CUST33 |      0 |      1 |       |     3   (0)| 00:00:01 |      0 |00:00:00.01 |       0 |
-----------------------------------------------------------------------------------------------------------------------------------------

*/

/* Ʃ��  - NOT NULL �϶� */
CREATE INDEX IX02_T_CUST33 ON T_CUST33(CUST_CD, DIV, FLAG);
 SELECT * FROM TABLE(DBMS_XPLAN.display_cursor(NULL,NULL, 'ADVANCED ALLSTATS LAST'));
SELECT /*+ GATHER_PLAN_STATISTICS NO_QUERY_TRANSFORMATION INDEX(T1 IX02_T_CUST33) */ 
* FROM t_cust33 T1
WHERE FLAG = NVL(:FLAG, FLAG) 
AND CUST_CD = :CUST_CD
AND DIV = :DIV 
;
/* Ʃ�� �� �����ȹ
- FLAG ������ �� ������ ��
---------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Starts | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | A-Rows |   A-Time   | Buffers |
---------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |      1 |        |       |     4 (100)|          |    191 |00:00:00.01 |     197 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_CUST33      |      1 |      2 |   252 |     4   (0)| 00:00:01 |    191 |00:00:00.01 |     197 |
|*  2 |   INDEX RANGE SCAN          | IX02_T_CUST33 |      1 |      1 |       |     3   (0)| 00:00:01 |    191 |00:00:00.01 |       6 |
---------------------------------------------------------------------------------------------------------------------------------------
*/
/*
Ʃ������Ʈ!!!
1. Ȯ���� ���ͼ� = �� ��ȸ���� �� �ִ� ���ǵ��� INDEX ���� �÷�����
2. ������ �� ������ �𸣴� �÷��� ������ INDEX�� �������ְ� UNION ALL �� �����ų� OR_EXPANSION ���� �����.
3. NOT NULL �÷��� ��쿡�� NVL�� �Ἥ ������ ����ϰ� ������� �� �ִ�.
*/