create database employees_info;
use employees_info;
create table employees(employee_id int primary key,
                       first_name varchar(20),
					   last_name varchar(20),
                       date_of_birth date,
                       gender varchar(5),
                       hire_date date,
                       department_id int, 
                       foreign key(department_id)  references department(department_id));

create table department(department_id int primary key,department_name varchar(20));
create table salary(employee_id int, salary int, bonus int, pay_date date,foreign key(employee_id)references employees(employee_id));

select * from employees;
select * from department;
select * from salary;

-- How many employees are there in each department?
select department_name,count(*) as no_of_employees
from department d
inner join employees e
on d.department_id=e.department_id
group by department_name;

--  What is the average salary for employees in each department?
select d.department_name,round(avg(s.salary),2) as avg_salary
from employees e
inner join salary s
on e.employee_id=s.employee_id
join department d
on e.department_id=d.department_id
group by d.department_name;

--  Which employee has the highest salary and which has the lowest?
with combined_table as(
(select e.first_name,e.last_name,s.salary,dense_rank() over(order by salary desc) ,'highest salary' as salary_type
                      from employees e
                      inner join salary s
                      on e.employee_id=s.employee_id
                      limit 1)

union
(select e.first_name,e.last_name,s.salary,dense_rank() over(order by salary) ,'lowest salary' as salary_type
                      from employees e
                      inner join salary s
                      on e.employee_id=s.employee_id
                      limit 1))
select first_name,last_name,salary,salary_type
from combined_table;

-- What is the gender distribution of employees in each department?
select d.department_name,e.gender,count(e.gender) as gender_count
from employees e
inner join department d
on e.department_id=d.department_id
group by d.department_name,e.gender;

-- How many employees were hired each year?
select year(hire_date) as years,count(employee_id) as no_of_employees
from employees
group by years
order by years;

-- What is the distribution of employees in different age groups (e.g., 20-30, 30-40, etc.)?
select case
       when timestampdiff(year,date_of_birth,curdate()) between 20 and 30 then '20-30'
       when timestampdiff(year,date_of_birth,curdate()) between 31 and 40 then '31-40'
       when timestampdiff(year,date_of_birth,curdate()) between 41 and 50 then '41-50'
       else '50+'
       end as age_group,
       count(employee_id) as employee_count
from employees
group by age_group;

-- What is the distribution of bonuses among employees?
select bonus,count(employee_id) as employee_count
from salary
group by bonus
order by employee_count desc;

-- Who are the top 10 highest-paid employees?
select e.first_name,e.last_name,s.salary
from employees e
join salary s
on e.employee_id=s.employee_id
order by s.salary desc
limit 10;

--  Which department has hired the most employees recently?
 
          -- firstly,we will find recent year for the hiring_date of employees--
with recent_hire_year as
(select year(hire_date) as years
from employees
order by years desc
limit 1)

             -- Now,we will find department that has hired the most employees in the year 2024 --
select d.department_name,count(e.employee_id) as employee_count
from department d
join employees e
on d.department_id=e.department_id
where year(e.hire_date)=(select years from recent_hire_year) 
group by d.department_name
order by employee_count desc
limit 1;

-- Are there any employees who have the exact same salary? If so, who are they?
select group_concat(e.first_name," ",e.last_name separator ",") as employees_name,s.salary
from employees e
inner join salary s
on e.employee_id=s.employee_id
group by s.salary
having count(e.employee_id)>1;

-- What is the average tenure (in years) of employees in each department?
select d.department_name,round(avg(timestampdiff(year,e.hire_date,curdate())),1) as avg_tenure_years
from department d
inner join employees e
on d.department_id=e.department_id
group by d.department_name
order by avg_tenure_years desc;

-- List all employees working in a specific department.
select d.department_name,e.first_name,e.last_name,row_number() over(partition by d.department_name order by e.first_name ) as employee_row_number
from department d
inner join employees e
on d.department_id=e.department_id;

-- What is the average salary of male vs female employees?
select e.gender,round(avg(s.salary),2) as avg_salary
from employees e
inner join salary s
on e.employee_id=s.employee_id
group by e.gender
order by avg_salary desc;

-- What is the total compensation (salary + bonus) for each employee?
select e.first_name,e.last_name,(s.salary+s.bonus) as total_compensation
from employees e
inner join salary s
on e.employee_id=s.employee_id
order by total_compensation desc;

-- Who are the longest-tenured employees in the company?
select first_name,last_name,timestampdiff(year,hire_date,curdate()) as tenure_years
from employees 
order by  tenure_years desc
limit 10;











       



