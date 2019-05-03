drop table p01enrolledcourses;
drop table my_tmp;

drop table p01gensection cascade constraints;	
drop table p01myclientsession cascade constraints;
drop table p01users cascade constraints;
drop table p01student cascade constraints;
drop table p01section cascade constraints;


create table p01users (
	clientid varchar2(8) primary key,
	password varchar2(12),
	aflag varchar2(1),
	sflag varchar2(1)
);

create table p01myclientsession (
  sessionid varchar2(32) primary key,
  clientid varchar2(8),
  sessiondate date,
  foreign key (clientid) references p01users
);

create table p01student (
stid varchar2(32) primary key,
fname varchar2(32) not null,
lname varchar2(32) not null,
clientid varchar2(8) not null,
age number(3), 
streetNumber number(8),
streetName varchar2(30),
city varchar2(30),
state varchar2(30),
zipCode varchar2(5),
typeflag varchar2(1),
status varchar2(1),
gpa number(2,1),
foreign key (clientid) references p01users ON DELETE CASCADE
);

create table p01section( /*Classes for each student if they need prereq*/
crn varchar2(32) primary key ,
ctitle varchar2(32),
credit number(1),
prereq1 varchar2(6),
prereq2 varchar2(6),
foreign key (prereq1) references p01section(crn),
foreign key (prereq2) references p01section(crn)
);


create table p01gensection( /*Sections Of Courses/Casses*/
crn varchar2(32) not null,
sectid number(4) not null,
sem number(4) not null,
stime varchar2(10),
max_size number(3), 
cur_size number(3),
deadline date,
primary key ( crn, sectid, sem),
foreign key (crn) references p01section
);

create table p01enrolledcourses (
	stid varchar2(8) not null,
	crn varchar2(6) not null,
	sem number(4) not null,
	sectid number(4) not null,
	enrollflag varchar2(1),
	grade number(3),
	primary key (stid, crn, sectid, sem),
	foreign key (stid) references p01student ON DELETE CASCADE,
	foreign key (crn,sectid, sem) references p01gensection(crn, sectid, sem)
);

create table my_tmp(
	my_grade number,
	my_credits number
);

--update_gpa procedure
create or replace procedure update_gpa(student_id in varchar2) as
	CURSOR c1 is select grade, credit from p01section natural join p01enrolledcourses
	where stid = student_id and enrollflag = 0;

	my_grade number;
	my_credits number;

	grade_total number;
	credits_total number;

	my_gpa number(3,1);
	begin

		delete from my_tmp;
		commit;
		
		open c1;
		LOOP
			fetch c1 into my_grade, my_credits;
			EXIT WHEN c1%NOTFOUND;
			my_grade := my_grade * my_credits;
			insert into my_tmp values(my_grade, my_credits);
			commit;
		END LOOP;
		close c1;
		select SUM(my_grade) into grade_total from my_tmp;
		select SUM(my_credits) into  credits_total from my_tmp;
		my_gpa := grade_total/credits_total;
		--dbms_output.put_line(my_gpa);
		update p01student set gpa = my_gpa where stid = student_id;
		commit;
	end;
	/
insert into p01users values ('a', 'a', '1', '0');
insert into p01users values ('b', 'b', '0', '1');
insert into p01users values ('c', 'c', '1', '1');

insert into p01student values ('stu001', 'John', 'Doe'  , 'b' , 20, 100, 'N University Dr' , 'Edmond' , 'OK' , '73034', 'U', 'N' , null);
insert into p01student values ('stu002', 'Joe', 'Dan' , 'c' , 22, 100 , 'N University Dr' , 'Edmond', 'OK' , '73034', 'U' , 'Y', null );

-- insert into p01section values ('CMSC', '10001' , 'Beginning Programming' ,'Spring 2019', 4, 90, 'b');
-- insert into p01section values ('CMSC', '10002' , 'Programming 1' ,'Fall 2019', 2, 79, 'b');
-- insert into p01section values ('CMSC', '10003' , 'Programming 2' , 'Spring 2020' ,3, 88, 'b');
-- insert into p01section values ('CMSC', '10001' , 'Beginning Programming' , 'Fall 2020' , 3, 89, 'c');
--courses/classes students enrolled
insert into p01section values ( 'cs1111', 'Intro to Computers', 3, null, null);
insert into p01section values ( 'ma1111', 'Math 1', 4, null, null);
insert into p01section values ( 'cs2111', 'Programming 1', 3, 'cs1111', null);
insert into p01section values ( 'cs2211', 'Programming 2', 3, 'cs2111', 'ma1111');
insert into p01section values ( 'ma2111', 'Math 2', 4, 'ma1111', null);
insert into p01section values ( 'ma2211', 'Math 3', 4, 'ma1111', 'ma2111');
--list of course/classes
insert into p01gensection values ('cs1111', 0001, 2020,    0,  3, 3, TO_DATE('20200101', 'yyyymmdd'));
insert into p01gensection values ('cs2111', 0001, 2020,    0,  2, 1, TO_DATE('20200101', 'yyyymmdd'));
insert into p01gensection values ('cs2211', 0001, 2020,    0,  2, 0, TO_DATE('20200101', 'yyyymmdd'));
insert into p01gensection values ('cs1111', 0001, 2021, 1300,  3, 0, TO_DATE('20211225', 'yyyymmdd'));
insert into p01gensection values ('cs2111', 0001, 2021, 1400,  2, 0, TO_DATE('20211101', 'yyyymmdd'));
insert into p01gensection values ('cs2211', 0001, 2021, 1500,  1, 0, TO_DATE('20211225', 'yyyymmdd'));
--ma sections
insert into p01gensection values ('ma1111', 0001, 2020,    0,  3, 3, TO_DATE('20190101', 'yyyymmdd'));
insert into p01gensection values ('ma2111', 0001, 2020,    0,  2, 1, TO_DATE('20190101', 'yyyymmdd'));
insert into p01gensection values ('ma2211', 0001, 2020,    0,  2, 0, TO_DATE('20190101', 'yyyymmdd'));
insert into p01gensection values ('ma1111', 0001, 2021, 1300,  3, 0, TO_DATE('20211225', 'yyyymmdd'));
insert into p01gensection values ('ma2111', 0001, 2021, 1400,  2, 0, TO_DATE('20211101', 'yyyymmdd')); 
insert into p01gensection values ('ma2211', 0001, 2021, 1500,  1, 0, TO_DATE('20211225', 'yyyymmdd'));
--student enrolled into a course
insert into p01enrolledcourses values ( 'stu001', 'cs1111', 2020, 0001, 0, 100);
insert into p01enrolledcourses values ( 'stu001', 'cs2111', 2020, 0001, 0, 70);
insert into p01enrolledcourses values ( 'stu001', 'cs2211', 2020, 0001, 0, 80);

-- insert into p01enrolledcourses values ( 'stu002', 'cs1111', 2020, 0001, 0, 1);
-- insert into p01enrolledcourses values ( 'stu002', 'cs2111', 2020, 0001, 0, 4);
i

-- insert into p01gensection values('CMSC', '10001', 'Beginning Programming' ,  4 , 'Fall 2019',30,0);
-- insert into p01gensection values('CMSC', '10002', 'Programming 1' , 4 , 'Fall 2019', 30,0);
-- insert into p01gensection values('CMSC', '10003', 'Programming 2' ,  4 , 'Fall 2019', 30,0);

create or replace procedure check_deadline
	(my_crn in varchar2, my_sectid in varchar2, my_sem in number, my_error out varchar2)
	AS
	my_date date := CURRENT_DATE;
	my_deadline date;
	begin
		select deadline into my_deadline from p01gensection
			where crn = my_crn and sectid = my_sectid and sem = my_sem;
		IF my_deadline < my_date THEN
			my_error := 'Enroll deadline passed for class ' 
				|| my_crn
				|| my_sectid;
		END IF;
	END;
	/

create or replace procedure check_passed_course
	(my_crn in varchar2, my_stid in varchar2, my_error out varchar2)
	is
	my_grade number;
	begin
		select max(grade) into my_grade from p01enrolledcourses 
			where crn = my_crn and stid = my_stid;
		IF my_grade IS NOT NULL THEN
			IF my_grade > 1 THEN
				my_error := 'Class '
					|| my_crn
					|| ' previously passed';
			END IF;
		END IF;
	END;
	/


create or replace procedure check_prereq
	(my_crn in varchar2, my_sectid in varchar2, my_stid in varchar2, my_error out varchar2)
	is
	my_prereq varchar2(30);
	my_tmp number;
	begin
		--check prereq1
		select prereq1 into my_prereq from p01section
			where crn = my_crn;
		IF my_prereq IS NOT NULL THEN
			select count(*) into my_tmp from p01enrolledcourses
				where crn = my_prereq and stid = my_stid and enrollflag = 0;
			IF my_tmp = 0 THEN
				my_error := 'Prereq1 not taken for class '
					|| my_crn
					|| ' section '
					|| my_sectid;
			END IF;
		END IF;

		--check prereq2
		select prereq2 into my_prereq from p01section 
			where crn = my_crn;
		IF my_prereq IS NOT NULL THEN
			select count(*) into my_tmp from p01enrolledcourses
				where crn = my_prereq and stid = my_stid and enrollflag = 0;
			IF my_tmp = 0 THEN
				my_error := my_error 
					|| 'Prereq2 not taken for class '
					|| my_crn
					|| ' section '
					|| my_sectid;
			END IF;
		END IF;
	END;
	/


create or replace procedure check_seat_available
	(my_crn in varchar2, my_sectid in varchar2, my_sem in number, my_stid in varchar2, my_error out varchar2)
	is
	my_students number;
	my_max_students number;
	my_tmp number;
	begin
		delete from my_tmp;
		select count(*) into my_tmp from p01enrolledcourses
			where crn = my_crn and sectid = my_sectid and sem=my_sem and enrollflag = 1;
		IF my_tmp = 0 THEN
			select cur_size, max_size into my_students, my_max_students from p01gensection
				where crn = my_crn and sectid = my_sectid and sem = my_sem FOR UPDATE;
			IF (my_max_students - my_students) > 0 THEN
				insert into p01enrolledcourses values (my_stid, my_crn, my_sem, my_sectid, 1, NULL);
				my_students := my_students + 1; 
				update p01gensection set cur_size = my_students
					where crn = my_crn and sectid = my_sectid and sem = my_sem;
				COMMIT;
			ELSE
				ROLLBACK;
				my_error := 'No seats available for '
					|| my_crn
					|| ' section '
					|| my_sectid;
			END IF;
		ELSE
			my_error := 'Currently enrolled in '
				|| my_crn
				|| ' section '
				|| my_sectid;
		END IF;
	END;
	/




commit;
