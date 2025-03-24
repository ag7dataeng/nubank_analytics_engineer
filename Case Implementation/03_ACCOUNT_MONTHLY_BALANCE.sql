WITH monthly_transactions AS (
    -- Incoming non-PIX transfers
    SELECT 
        a.account_id,
        t.year_id,
        t.month_id,
        SUM(ti.amount) AS total_transfer_in,
        0 AS total_transfer_out
    FROM transfer_ins ti
    JOIN d_time t ON ti.transaction_completed_at = t.time_id
    JOIN d_month dm ON t.month_id = dm.month_id
    JOIN d_year dy ON t.year_id = dy.year_id
    JOIN accounts a ON ti.account_id = a.account_id
    WHERE ti.status = 'completed'
      AND dy.action_year = 2020
    GROUP BY a.account_id, t.year_id, t.month_id

    UNION ALL

    -- Outgoing non-PIX transfers
    SELECT 
        a.account_id,
        t.year_id,
        t.month_id,
        0 AS total_transfer_in,
        SUM(t_out.amount) AS total_transfer_out
    FROM transfer_outs t_out
    JOIN d_time t ON t_out.transaction_completed_at = t.time_id
    JOIN d_month dm ON t.month_id = dm.month_id
    JOIN d_year dy ON t.year_id = dy.year_id
    JOIN accounts a ON t_out.account_id = a.account_id
    WHERE t_out.status = 'completed'
      AND dy.action_year = 2020
    GROUP BY a.account_id, t.year_id, t.month_id

    UNION ALL

    -- PIX Transfers (Incoming & Outgoing)
    SELECT 
        a.account_id,
        t.year_id,
        t.month_id,
        SUM(CASE WHEN pm.in_or_out = 'in' THEN pm.pix_amount ELSE 0 END) AS total_transfer_in,
        SUM(CASE WHEN pm.in_or_out = 'out' THEN pm.pix_amount ELSE 0 END) AS total_transfer_out
    FROM pix_movements pm
    JOIN d_time t ON pm.pix_completed_at = t.time_id
    JOIN d_month dm ON t.month_id = dm.month_id
    JOIN d_year dy ON t.year_id = dy.year_id
    JOIN accounts a ON pm.account_id = a.account_id
    WHERE pm.status = 'completed'
      AND dy.action_year = 2020
    GROUP BY a.account_id, t.year_id, t.month_id
)

, aggregated_balances AS (
    -- Compute net balance per account-month
    SELECT 
        mt.account_id,
        dy.action_year AS year,
        dm.action_month AS month,
        SUM(mt.total_transfer_in) AS total_transfer_in,
        SUM(mt.total_transfer_out) AS total_transfer_out,
        SUM(mt.total_transfer_in) - SUM(mt.total_transfer_out) AS net_change
    FROM monthly_transactions mt
    JOIN d_month dm ON mt.month_id = dm.month_id
    JOIN d_year dy ON mt.year_id = dy.year_id
    GROUP BY mt.account_id, dy.action_year, dm.action_month
)

-- Compute Cumulative Account Balance Over Time
SELECT 
    ab.month AS month,
    ab.account_id AS account,
    ab.total_transfer_in,
    ab.total_transfer_out,
    SUM(ab.net_change) OVER (
        PARTITION BY ab.account_id ORDER BY ab.year, ab.month
    ) AS account_monthly_balance
FROM aggregated_balances ab
ORDER BY ab.account_id, ab.year, ab.month;
