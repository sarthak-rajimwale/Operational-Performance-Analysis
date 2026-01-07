CREATE VIEW vw_ops_logs AS
SELECT
    CAST(id AS INT) AS id,

    TRY_CONVERT(DATETIME2, time) AS timestamp,

    webPart AS service_name,
    category,

    TRY_CONVERT(INT, length) AS response_time_proxy,

    -- Error definition: failed / aborted requests
    CASE
        WHEN TRY_CONVERT(INT, length) < 0 THEN 1
        ELSE 0
    END AS error_flag,

    -- SLA definition: slow or failed requests
    CASE
        WHEN TRY_CONVERT(INT, length) < 0
          OR TRY_CONVERT(INT, length) > 50 THEN 1
        ELSE 0
    END AS sla_breach

FROM logs
WHERE TRY_CONVERT(DATETIME2, time) IS NOT NULL;


select * from vw_ops_logs;

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN timestamp IS NULL THEN 1 ELSE 0 END) AS null_timestamp,
    SUM(CASE WHEN service_name IS NULL THEN 1 ELSE 0 END) AS null_service,
    SUM(CASE WHEN response_time_proxy IS NULL THEN 1 ELSE 0 END) AS null_latency
FROM vw_ops_logs;
SELECT
    MIN(response_time_proxy) AS min_latency,
    MAX(response_time_proxy) AS max_latency,
    AVG(response_time_proxy) AS avg_latency
FROM vw_ops_logs;
SELECT
    response_time_proxy,
    COUNT(*) AS cnt
FROM vw_ops_logs
GROUP BY response_time_proxy
ORDER BY response_time_proxy;
SELECT
    error_flag,
    sla_breach,
    COUNT(*) AS cnt
FROM vw_ops_logs
GROUP BY error_flag, sla_breach
ORDER BY error_flag, sla_breach;
SELECT
    service_name,
    COUNT(*) AS requests,
    AVG(response_time_proxy) AS avg_latency,
    SUM(error_flag) * 1.0 / COUNT(*) AS error_rate
FROM vw_ops_logs
GROUP BY service_name
ORDER BY requests DESC;

CREATE OR ALTER VIEW vw_ops_logs AS
SELECT
    CAST(id AS INT) AS id,
    TRY_CONVERT(DATETIME2, time) AS timestamp,

    ISNULL(webPart, 'Unknown') AS service_name,
    category,

    TRY_CONVERT(INT, length) AS response_time_proxy,

    CASE
        WHEN TRY_CONVERT(INT, length) < 0 THEN 1
        ELSE 0
    END AS error_flag,

    CASE
        WHEN TRY_CONVERT(INT, length) < 0
          OR TRY_CONVERT(INT, length) > 50 THEN 1
        ELSE 0
    END AS sla_breach
FROM logs
WHERE TRY_CONVERT(DATETIME2, time) IS NOT NULL;

select * from vw_ops_logs;

CREATE OR ALTER VIEW vw_ops_logs_final AS
SELECT
    CAST(id AS INT) AS id,

    TRY_CONVERT(DATETIME2, time) AS timestamp,

    ISNULL(NULLIF(webPart, ''), 'Unknown') AS service_name,
    ISNULL(NULLIF(category, ''), 'Unknown') AS category,

    CASE
        WHEN TRY_CONVERT(INT, length) >= 0
        THEN TRY_CONVERT(INT, length)
        ELSE NULL
    END AS latency_ms,

    CASE
        WHEN TRY_CONVERT(INT, length) < 0 THEN 1
        ELSE 0
    END AS error_flag,

    CASE
        WHEN TRY_CONVERT(INT, length) < 0
          OR TRY_CONVERT(INT, length) > 50 THEN 1
        ELSE 0
    END AS sla_breach

FROM logs
WHERE
    TRY_CONVERT(DATETIME2, time) IS NOT NULL
    AND TRY_CONVERT(INT, length) IS NOT NULL;

SELECT
    SUM(CASE WHEN timestamp IS NULL THEN 1 ELSE 0 END) AS null_time,
    SUM(CASE WHEN service_name IS NULL THEN 1 ELSE 0 END) AS null_service,
    SUM(CASE WHEN latency_ms IS NULL AND error_flag = 0 THEN 1 ELSE 0 END) AS bad_latency
FROM vw_ops_logs_final;

SELECT
    MIN(latency_ms) AS min_latency,
    MAX(latency_ms) AS max_latency,
    AVG(latency_ms) AS avg_latency
FROM vw_ops_logs_final
WHERE latency_ms IS NOT NULL;

SELECT
    error_flag,
    sla_breach,
    COUNT(*) AS cnt
FROM vw_ops_logs_final
GROUP BY error_flag, sla_breach;




