/* 아래의 SQL에 대한 인덱스를 설계하시오
T1 
  - 전체 1천만건
  - T1.C5 = 'A'   100건
  
T2
  - 전체 1억건
  - T2.C2 = '10'  AND  T2.C3 = '123'  2,000건
*/

--1)
SELECT  /*+ ORDERED  USE_NL(T2) */  *
FROM  T1_34 T1,  T2_34 T2
WHERE  T1.C5 = 'A'
 AND   T2.C1 = T1.C1
 AND   T2.C2 = '10'
 AND   T2.C3 = '123';

--2)
SELECT  /*+ ORDERED  USE_HASH(T2) */   *
FROM  T1_34 T1,  T2_34 T2
WHERE  T1.C5 = 'A'
 AND   T2.C1 = T1.C1
 AND   T2.C2 = '10'
 AND   T2.C3 = '123';

--3) HASH JOIN으로 최적화 시키세요.
     -- 인덱스 변경가능
     -- SQL 변경 가능


인덱스 - 
T1 : C5
T2 : C2, C3

NL 조인으로 하는 게 젤 나을 거 같지만, 알고보면 뒤에 1억건중 9억 8천건을 버려야하는 비효율이 발생한다...?
HASH 조인으로 푸는게 낫겠음
테이블이 너무 클 때는! INNER 테이블의 인덱스로만 먼저 조인해주는 것이 낫다.
SELECT  /*+ LEADING(T1 BRG_T2)  USE_HASH(BRG_T2) */  T1. *, T2.*
FROM  T1_34 T1,  T2_34 T2, T2_34 BRG_T2
WHERE  T1.C5 = 'A'
 AND   BRG_T2.C1 = T1.C1
 AND   BRG_T2.C2 = '10'
 AND   BRG_T2.C3 = '123'
AND    BRG_T2.ROWID = T2.ROWID;