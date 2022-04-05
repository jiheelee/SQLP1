drop table source;
drop table target;
--1000���� ������ ����
CREATE TABLE source
as 
select b.no, a.*
from (select * from employees where rownum <= 10) a,
     (select rownum as no from dual connect by level <= 3000000) b;

create table target
as
select * from source where 1=2;
--PK ����
alter table target add
constraint target_pk primary key(no, employee_id);
select * from source;

--INEX ����
create index target_x1 on target(FIRST_NAME);

--�Ϲ����� ���
SET TIMING ON;
INSERT /*+ APPEND */ INTO target
select * from source;

--133�� �ɸ�

--=========================================
1. pk �������� ����, index unusable
--=========================================
truncate table target;
alter table target modify constraint target_pk disable drop index;
alter table target drop primary key;
alter table target add
constraint target_pk primary key(no, employee_id);
alter index target_x1 unusable;

INSERT /*+ APPEND */ INTO target
select * from source;
--27.8�� �ɸ�

--�ε��� �����
alter table target modify constraint target_pk enable novalidate;
--39�� �ɸ�
alter index target_x1 rebuild;
--37�� �ɸ�
--
133�� => 30���� ȿ��
--
--=====================================================
2. pk �������� ����, index unusable -> non-unique index
--=====================================================

truncate table target;
alter table target drop primary key drop index;
create index target_pk on target(no, employee_id);
alter table target add
constraint target_pk primary key(no, employee_id)
using index target_pk;

alter table target modify constraint target_pk disable keep index;
alter index target_x1 unusable;
alter index target_pk unusable;


INSERT /*+ APPEND */ INTO target
select * from source;
--23�� �ɸ�
alter index target_pk rebuild;
--35��
alter index target_x1 rebuild;
--38��
alter table target modify constraint target_pk enable novalidate;

--
133�� => 28���� ȿ��
--











