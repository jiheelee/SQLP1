/* �Ʒ��� SQL�� ���� �ε����� �����Ͻÿ�
T1 
  - ��ü 1õ����
  - T1.C5 = 'A'   100��
  
T2
  - ��ü 1���
  - T2.C2 = '10'  AND  T2.C3 = '123'  2,000��
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

--3) HASH JOIN���� ����ȭ ��Ű����.
     -- �ε��� ���氡��
     -- SQL ���� ����


�ε��� - 
T1 : C5
T2 : C2, C3

NL �������� �ϴ� �� �� ���� �� ������, �˰��� �ڿ� 1����� 9�� 8õ���� �������ϴ� ��ȿ���� �߻��Ѵ�...?
HASH �������� Ǫ�°� ������
���̺��� �ʹ� Ŭ ����! INNER ���̺��� �ε����θ� ���� �������ִ� ���� ����.
SELECT  /*+ LEADING(T1 BRG_T2)  USE_HASH(BRG_T2) */  T1. *, T2.*
FROM  T1_34 T1,  T2_34 T2, T2_34 BRG_T2
WHERE  T1.C5 = 'A'
 AND   BRG_T2.C1 = T1.C1
 AND   BRG_T2.C2 = '10'
 AND   BRG_T2.C3 = '123'
AND    BRG_T2.ROWID = T2.ROWID;