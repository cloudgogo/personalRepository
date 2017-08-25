create tablespace TEST_STUDY datafile 'D:\oracle\TEST_STUDY.dbf' size 128M autoextend on next 64M permanent online;

-- Create table
create table TEST_STUDY_0001
(
  ID    NUMBER not null,
  NAME         VARCHAR2(150),
  INFO        VARCHAR2(320)
)
tablespace TEST_STUDY
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 104
    next 104
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate indexes 
create unique index TEST_STUDY_0001_U1 on TEST_STUDY_0001 (ID)
  tablespace TEST_STUDY
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 104K
    next 104K
    minextents 1
    maxextents unlimited
  );
create unique index HRS_DEF_PARAMTER_U2 on TEST_STUDY_0001 (NAME,INFO)
  tablespace TEST_STUDY
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 104K
    next 104K
    minextents 1
    maxextents unlimited
  );
