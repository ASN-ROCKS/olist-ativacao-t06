WITH tb_ativacao AS (

    SELECT DISTINCT
        date(t1.order_purchase_timestamp) as dtVenda,
        t2.seller_id

    FROM workspace.olist.orders AS t1

    INNER JOIN workspace.olist.order_items AS t2
    ON t1.order_id = t2.order_id

    ORDER BY t2.seller_id, dtVenda

),

tb_fl_ativacao AS (

SELECT DISTINCT
       dtRef,
       idSeller,
       CASE WHEN t2.seller_id IS NULL THEN 1 ELSE 0 END AS flNotActivate

FROM workspace.feature_store.fs_rfv as t1

LEFT JOIN tb_ativacao AS t2
ON t1.idSeller = t2.seller_id
AND t1.dtRef <= t2.dtVenda
AND add_months(t1.dtRef,1) > t2.dtVenda

ORDER BY t1.idSeller, t1.dtRef

),

tb_abt_all AS (

    SELECT t1.*,
           t2.* EXCEPT (idSeller, dtRef),
           t3.* EXCEPT (idSeller, dtRef),
           t4.* EXCEPT (idSeller, dtRef),
           t5.* EXCEPT (idSeller, dtRef),
           t6.* EXCEPT (idSeller, dtRef),
           t7.* EXCEPT (idSeller, dtRef),
           t8.* EXCEPT (idSeller, dtRef)

    FROM tb_fl_ativacao AS t1

    LEFT JOIN workspace.feature_store.fs_customer AS t2
    ON t1.idseller = t2.idSeller
    AND t1.dtRef = t2.dtRef

    LEFT JOIN workspace.feature_store.fs_delivery AS t3
    ON t1.idseller = t3.idSeller
    AND t1.dtRef = t3.dtRef

    LEFT JOIN workspace.feature_store.fs_geoloc AS t4
    ON t1.idseller = t4.idSeller
    AND t1.dtRef = t4.dtRef

    LEFT JOIN workspace.feature_store.fs_payment AS t5
    ON t1.idseller = t5.idSeller
    AND t1.dtRef = t5.dtRef

    LEFT JOIN workspace.feature_store.fs_products AS t6
    ON t1.idseller = t6.idSeller
    AND t1.dtRef = t6.dtRef

    LEFT JOIN workspace.feature_store.fs_reputation AS t7
    ON t1.idseller = t7.idSeller
    AND t1.dtRef = t7.dtRef

    LEFT JOIN workspace.feature_store.fs_rfv AS t8
    ON t1.idseller = t8.idSeller
    AND t1.dtRef = t8.dtRef

    ORDER BY t1.idSeller, t1.dtRef

),

tb_train AS (

    SELECT *
    FROM tb_abt_all
    WHERE dtRef < '2018-07-01'
    QUALIFY row_number() OVER (PARTITION BY idSeller ORDER BY RAND()) = 1
    ORDER BY idSeller
)

SELECT *
FROM tb_train

UNION ALL

SELECT *
FROM tb_abt_all
WHERE dtRef = '2018-07-01'