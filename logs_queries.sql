create view vw_ops_logs as
select
    cast(id as int) as id,
    try_convert(datetime2, time) as timestamp,
    webpart as service_name,
    category,
    try_convert(int, length) as response_time_proxy,
    case
        when try_convert(int, length) < 0 then 1
        else 0
    end as error_flag,
    case
        when try_convert(int, length) < 0
          or try_convert(int, length) > 50 then 1
        else 0
    end as sla_breach
from logs
where try_convert(datetime2, time) is not null;


select * from vw_ops_logs;



create or alter view vw_ops_logs as
select
    cast(id as int) as id,
    try_convert(datetime2, time) as timestamp,

    isnull(webpart, 'unknown') as service_name,
    category,

    try_convert(int, length) as response_time_proxy,

    case
        when try_convert(int, length) < 0 then 1
        else 0
    end as error_flag,

    case
        when try_convert(int, length) < 0
          or try_convert(int, length) > 50 then 1
        else 0
    end as sla_breach
from logs
where try_convert(datetime2, time) is not null;

select * from vw_ops_logs;


create or alter view vw_ops_logs_final as
select
    cast(id as int) as id,

    try_convert(datetime2, time) as timestamp,

    isnull(nullif(webpart, ''), 'unknown') as service_name,
    isnull(nullif(category, ''), 'unknown') as category,

    case
        when try_convert(int, length) >= 0
        then try_convert(int, length)
        else null
    end as latency_ms,

    case
        when try_convert(int, length) < 0 then 1
        else 0
    end as error_flag,

    case
        when try_convert(int, length) < 0
          or try_convert(int, length) > 50 then 1
        else 0
    end as sla_breach

from logs
where
    try_convert(datetime2, time) is not null
    and try_convert(int, length) is not null;

select
    sum(case when timestamp is null then 1 else 0 end) as null_time,
    sum(case when service_name is null then 1 else 0 end) as null_service,
    sum(case when latency_ms is null and error_flag = 0 then 1 else 0 end) as bad_latency
from vw_ops_logs_final;

select
    min(latency_ms) as min_latency,
    max(latency_ms) as max_latency,
    avg(latency_ms) as avg_latency
from vw_ops_logs_final
where latency_ms is not null;

select
    error_flag,
    sla_breach,
    count(*) as cnt
from vw_ops_logs_final
group by error_flag, sla_breach;
