-- 1 Даты регистрации
-- Вывести количество контрактов, зарегистрированных в системе за каждый день за последние 5 дней 


select  DT_REG, count(*) as contract_count from contracts 
group by (DT_REG) having DT_REG between current_date() - 4 and current_date();


-- 2 Отчёт по статусам
-- Вывести количество контрактов для каждого значения статуса контракта из списка: A - активен, B - заблокирован, C - расторгнут. 
-- Результат: статус, «словесное» наименование статуса, количество контрактов.


select v_status,
case 
	when v_status = 'A'
		then 'активен'
	when v_status = 'B'
		then 'заблокирован'
	when v_status = 'C'
		then 'расторгнут'
end as status_name,
count(*) as status_count from contracts
group by v_status;


-- 3 «Пустые» филиалы
-- Вывести наименования филиалов, в которых нет ни одного активного контракта.


select distinct id_department from departments
where id_department not in 
(select distinct ID_department from contracts
where v_status = 'A');


-- 4 Счет
-- По контракту (v_ext_ident = ‘XXX’) после каждого события (оказанная услуга, платеж) выставляют счет, в котором в поле f_sum отображается сумма всех неоплаченных услуг на тот момент. 
-- Требуется вывести задолженность абонента на произвольную дату

-- Выведем задолжность абонента с контрактом v_ext_ident = 130 на 15.06.2021

select f_sum as debt from bills
where id_contract_inst in (select id_contract_inst from contracts where v_ext_ident = 130)
and dt_event in (select max(dt_event) from bills where dt_event <= '2021-06-15');


-- 7 Уникальные услуги
-- Вывести наименования услуг, которые являются уникальными в рамках филиалов, т.е. таких услуг, которые есть только в конкретном филиале и ни в каком другом.


-- Выводим наименование уникальной услуги и id департамента, который его выполняет
select t3.v_name, t3.id_department from (
select t2.id_department, t2.v_name, t2.id_service, count(*) as counter from 
(select d.id_department, s1.v_name, s1.id_service from service s1
join services s2 on s1.id_service = s2.id_service
join contracts c on c.id_contract_inst = s2.id_contract_inst
join departments d on c.id_department = d.id_department
group by d.id_department, s1.v_name) t2 group by t2.id_service
having counter = 1) as t3;


-- 8 Популярные услуги
-- Вывести наименования тарифных планов для 5 самых популярных услуг


select t4.v_name from
(select id_tariff_plan from services where id_service in 
(select t2.id_service from
(select id_service, count(*) as max_count from services group by id_service order by max_count desc limit 5) t2)) t3
join tariff_plan t4
on t3.id_tariff_plan = t4.id_tariff_plan



