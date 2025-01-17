CREATE TABLE segment_users
(
    `tenant_id` UInt16,
    `segment_id` String,
    `users` Array(String),
    `at` DateTime64
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(at)
ORDER BY (tenant_id, segment_id, at)
;


CREATE TABLE segment_users_final
(
    `tenant_id` UInt16,
    `segment_id` String,
    `users` AggregateFunction(argMax, Array(String), DateTime64),
    `at_final` SimpleAggregateFunction(max, DateTime64)
)
ENGINE = AggregatingMergeTree()
ORDER BY (tenant_id, segment_id)
;


CREATE MATERIALIZED VIEW segment_users_final_mv TO segment_users_final AS
SELECT
    tenant_id,
    segment_id,
    argMaxState(users, at) AS users,
    max(at) AS at_final
FROM segment_users
GROUP BY
    tenant_id,
    segment_id
;



