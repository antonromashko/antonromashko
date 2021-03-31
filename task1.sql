drop table if exists public.customer_info;
drop table if exists public.transaction_info;
create table public.customer_info (
    id serial,
    client_id int not null primary key ,
    total_amount money not null,
    gender text,
    age int,
    count_city int not null,
    response_communication bool not null,
    communication_3month bool not null,
    tenure int not null
);

create table public.transaction_info (
    id serial,
    date_new timestamp not null,
    check_id int not null,
    client_id int not null,
    count_products text not null ,
    sum_payment money not null
);

copy customer_info (
        client_id, total_amount, gender, age, count_city, response_communication, communication_3month, tenure
    ) from '/Users/anton.romashko/Downloads/Data files/Customer_info.csv' with (format csv);
copy transaction_info (
       date_new, check_id, client_id, count_products, sum_payment
    ) from '/Users/anton.romashko/Downloads/Data files/Transactions_info.csv' with (format csv);

-- update public.transaction_info
-- set date_new = to_timestamp(date_new::date::text, 'yyyy-dd-mm')
-- where true;

-- вывести список клиентов с непрерывной историей за год,
-- средний чек за период, средняя сумма покупок за месяц,
-- количество всех операций по клиенту за период
select client_id,
       sum(sum_payment)/count(distinct check_id) as avg_check,
       sum(sum_payment)/count(distinct to_char(date_new, 'YYYY-MM')) avg_per_month,
       count(*)
from public.transaction_info
group by 1
having count(distinct to_char(date_new, 'YYYY-MM')) >= 12;

-- средняя сумма чека в месяц
-- долю от общего количества операций за год и долю в месяц от общей суммы операций
with t as (
    select count(*) qty_transactions, sum(sum_payment) amount_payment
    from public.transaction_info
)
select to_char(date_new, 'YYYY-MM'),
       sum(sum_payment) / count(distinct check_id) as avg_check,
       round(sum(sum_payment)::numeric / (select t.amount_payment from t)::numeric, 3) amount_share,
       round(count(*)::numeric /  (select t.qty_transactions from t)::numeric, 3) qty_share
from public.transaction_info
group by 1;

-- среднее количество операций в месяц
-- среднее количество клиентов
select
       count(distinct client_id) / count(distinct to_char(date_new, 'YYYY-MM')) avg_clients,
       count(*) / count(distinct to_char(date_new, 'YYYY-MM')) avg_per_month
from public.transaction_info;

-- вывести % соотношение M/F/NA в каждом месяце с их долей затрат
select to_char(date_new, 'YYYY-MM'),
       round(count(distinct c.client_id) filter ( where c.gender = 'M')::numeric / count(distinct c.client_id), 3) male,
       round(count(distinct c.client_id) filter ( where c.gender = 'F')::numeric / count(distinct c.client_id), 3) female,
       round(count(distinct c.client_id) filter ( where c.gender is null)::numeric / count(distinct c.client_id), 3) "none",
       round(sum(t.sum_payment) filter ( where c.gender = 'M')::numeric /   sum(t.sum_payment)::numeric, 3) amount_male_share,
       round(sum(t.sum_payment) filter ( where c.gender = 'F')::numeric /   sum(t.sum_payment)::numeric, 3) amount_female_share,
       round(sum(t.sum_payment) filter ( where c.gender is null)::numeric / sum(t.sum_payment)::numeric, 3) "amount_none_share"
from public.transaction_info t
left join public.customer_info c on t.client_id = c.client_id
group by 1;

-- Вывести возрастные группы клиентов с шагом 10 лет
-- и отдельно клиентов у которых нет данной информации
-- с параметрами сумма и количество операций за весь период,
-- и поквартально, средние показатели и %.
select
       -- конструкция для генерации строки типа 20-29 для возрастных групп, вместо case when
       coalesce((age - right(age::text, 1)::int)::text || '-' || (age - right(age::text, 1)::int + 9)::text, 'None') age_range,
       -- total
       count(*) total_qty,
       sum(sum_payment) total_amount,
       -- q2 2015
       sum(sum_payment) filter ( where date_trunc('quarter', date_new) = '2015-04-01'::timestamp )
        / count(distinct check_id) filter ( where date_trunc('quarter', date_new) = '2015-04-01'::timestamp ) as q2_2015_avg_check,
       round(sum(sum_payment) filter ( where date_trunc('quarter', date_new) = '2015-04-01'::timestamp )::numeric
        / sum(sum_payment)::numeric, 3) q2_2015_amount_share,
       round(count(*) filter ( where date_trunc('quarter', date_new) = '2015-04-01'::timestamp )::numeric
        / count(*)::numeric, 3) q2_2015_qty_share,
       -- q3 2015
       sum(sum_payment) filter ( where date_trunc('quarter', date_new) = '2015-07-01'::timestamp )
        / count(distinct check_id) filter ( where date_trunc('quarter', date_new) = '2015-07-01'::timestamp ) as q3_2015_avg_check,
       round(sum(sum_payment) filter ( where date_trunc('quarter', date_new) = '2015-07-01'::timestamp )::numeric
        / sum(sum_payment)::numeric, 3) q3_2015_amount_share,
       round(count(*) filter ( where date_trunc('quarter', date_new) = '2015-07-01'::timestamp )::numeric
        / count(*)::numeric, 3) q3_2015_qty_share,
       -- q4 2015
       sum(sum_payment) filter ( where date_trunc('quarter', date_new) = '2015-10-01'::timestamp )
        / count(distinct check_id) filter ( where date_trunc('quarter', date_new) = '2015-10-01'::timestamp ) as q4_2015_avg_check,
       round(sum(sum_payment) filter ( where date_trunc('quarter', date_new) = '2015-10-01'::timestamp )::numeric
        / sum(sum_payment)::numeric, 3) q4_2015_amount_share,
       round(count(*) filter ( where date_trunc('quarter', date_new) = '2015-10-01'::timestamp )::numeric
        / count(*)::numeric, 3) q4_2015_qty_share,
       -- q1 2016
       sum(sum_payment) filter ( where date_trunc('quarter', date_new) = '2016-01-01'::timestamp )
        / count(distinct check_id) filter ( where date_trunc('quarter', date_new) = '2016-01-01'::timestamp ) as q1_2016_avg_check,
       round(sum(sum_payment) filter ( where date_trunc('quarter', date_new) = '2016-01-01'::timestamp )::numeric
        / sum(sum_payment)::numeric, 3) q1_2016_amount_share,
       round(count(*) filter ( where date_trunc('quarter', date_new) = '2016-01-01'::timestamp )::numeric
        / count(*)::numeric, 3) q1_2016_qty_share,
       -- q2 2016
       sum(sum_payment) filter ( where date_trunc('quarter', date_new) = '2016-04-01'::timestamp ) /
       count(distinct check_id) filter ( where date_trunc('quarter', date_new) = '2016-04-01'::timestamp ) as q2_2016_avg_check,
       round(sum(sum_payment) filter ( where date_trunc('quarter', date_new) = '2016-04-01'::timestamp )::numeric
                 / sum(sum_payment)::numeric, 3) q2_2016_amount_share,
       round(count(*) filter ( where date_trunc('quarter', date_new) = '2016-04-01'::timestamp )::numeric
        / count(*)::numeric, 3) q2_2016_qty_share
from
     public.customer_info c
         join transaction_info ti on c.client_id = ti.client_id
group by 1;

-- Вывести возрастные группы клиентов с шагом 10 лет
-- и отдельно клиентов у которых нет данной информации
-- с параметрами сумма и количество операций за весь период,
select coalesce((age - right(age::text, 1)::int)::text || '-' || (age - right(age::text, 1)::int + 9)::text, 'None') age_range,
count(*) qty,
sum(sum_payment) amount
from public.customer_info c join transaction_info ti on c.client_id = ti.client_id
group by 1;

-- и поквартально, средние показатели и %.
with t as (
select coalesce((age - right(age::text, 1)::int)::text || '-' || (age - right(age::text, 1)::int + 9)::text, 'None') age_range,
count(*) qty,
sum(sum_payment) amount
from public.customer_info c join transaction_info ti on c.client_id = ti.client_id
group by 1
order by 1)

select to_char(date_trunc('quarter', date_new), 'YYYY-MM'),
       coalesce((age - right(age::text, 1)::int)::text || '-' || (age - right(age::text, 1)::int + 9)::text, 'None') age_range,
       sum(sum_payment) / count(distinct check_id) as avg_check,
       round(sum(sum_payment)::numeric / max(amount)::numeric, 3) amount_share,
       round(count(*)::numeric / max(qty)::numeric, 3) qty_share
from
     public.customer_info c
         join transaction_info ti on c.client_id = ti.client_id
         join t on t.age_range = coalesce((age - right(age::text, 1)::int)::text || '-' || (age - right(age::text, 1)::int + 9)::text, 'None')
group by 1, 2;