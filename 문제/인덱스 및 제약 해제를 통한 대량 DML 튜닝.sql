drop table source;
drop table target;
--1000만건 데이터 생성
CREATE TABLE source
as 
select b.no, a.*
from (select * from employees where rownum <= 10) a,
     (select rownum as no from dual connect by level <= 3000000) b;

create table target
as
select * from source where 1=2;
--PK 생성
alter table target add
constraint target_pk primary key(no, employee_id);
select * from source;

--INEX 생성
create index target_x1 on target(FIRST_NAME);

--일반적인 경우
SET TIMING ON;
INSERT /*+ APPEND */ INTO target
select * from source;

--133초 걸림

--=========================================
1. pk 제약조건 해제, index unusable
--=========================================
truncate table target;
alter table target modify constraint target_pk disable drop index;
alter table target drop primary key;
alter table target add
constraint target_pk primary key(no, employee_id);
alter index target_x1 unusable;

INSERT /*+ APPEND */ INTO target
select * from source;
--27.8초 걸림

--인덱스 재생성
alter table target modify constraint target_pk enable novalidate;
--39초 걸림
alter index target_x1 rebuild;
--37초 걸림
--
133초 => 30초의 효과
--
--=====================================================
2. pk 제약조건 해제, index unusable -> non-unique index
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
--23초 걸림
alter index target_pk rebuild;
--35초
alter index target_x1 rebuild;
--38초
alter table target modify constraint target_pk enable novalidate;

--
133초 => 28초의 효과
--











