WITH tb_pedidos AS (
    SELECT *
    FROM workspace.olist.orders
    WHERE order_purchase_timestamp < '{date}'
),

tb_reputation AS (

    SELECT
        toi.seller_id,
    -- ===========================================
    -- Quantidade de avaliações por seller 28,56,365 dias e lifetime
    -- ===========================================
        COUNT(DISTINCT CASE 
            WHEN DATE(tor.review_creation_date) BETWEEN DATE_SUB('{date}', 28) AND '{date}'
            THEN tp.order_id 
        END) AS reviews_28d,

        COUNT(DISTINCT CASE 
            WHEN DATE(tor.review_creation_date) BETWEEN DATE_SUB('{date}', 56) AND '{date}'
            THEN tp.order_id 
        END) AS reviews_56d,

        COUNT(DISTINCT CASE 
            WHEN DATE(tor.review_creation_date) BETWEEN DATE_SUB('{date}', 365) AND '{date}'
            THEN tp.order_id 
        END) AS reviews_365d,

        COUNT(DISTINCT tp.order_id) AS reviews_lifetime,
    -- ===========================================
    -- Percentual de avaliações por seller 28,56,365 dias e lifetime
    -- ===========================================   
        ROUND(
            COUNT(DISTINCT CASE
                WHEN CAST(tp.order_purchase_timestamp AS DATE) >= date_sub('{date}', 28)
                    AND tor.order_id IS NOT NULL
                THEN tp.order_id
            END) * 100.0
            /
            NULLIF(COUNT(DISTINCT CASE
                WHEN CAST(tp.order_purchase_timestamp AS DATE) >= date_sub('{date}', 28)
                THEN tp.order_id
            END), 0)
        , 2) AS percentual_28d,

        ROUND(
            COUNT(DISTINCT CASE
                WHEN CAST(tp.order_purchase_timestamp AS DATE) >= date_sub('{date}', 56)
                    AND tor.order_id IS NOT NULL
                THEN tp.order_id
            END) * 100.0
            /
            NULLIF(COUNT(DISTINCT CASE
                WHEN CAST(tp.order_purchase_timestamp AS DATE) >= date_sub('{date}', 56)
                THEN tp.order_id
            END), 0)
        , 2) AS percentual_56d,

        ROUND(
            COUNT(DISTINCT CASE
                WHEN CAST(tp.order_purchase_timestamp AS DATE) >= date_sub('{date}', 365)
                    AND tor.order_id IS NOT NULL
                THEN tp.order_id
            END) * 100.0
            /
            NULLIF(COUNT(DISTINCT CASE
                WHEN CAST(tp.order_purchase_timestamp AS DATE) >= date_sub('{date}', 365)
                THEN tp.order_id
            END), 0)
        , 2) AS percentual_365d,

        ROUND(
            COUNT(DISTINCT CASE
                WHEN tor.order_id IS NOT NULL
                THEN tp.order_id
            END) * 100.0
            /
            NULLIF(COUNT(DISTINCT tp.order_id), 0)
        , 2) AS percentual_lifetime,
    -- ===========================================
    -- Média das avaliações por seller 28,56,365 dias e lifetime
    -- ===========================================  
        ROUND(AVG(tor.review_score), 2) AS media_avaliacoes_lifetime,

        ROUND(AVG(CASE
            WHEN DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28
            THEN tor.review_score
        END), 2) AS media_avaliacoes_d28,

        ROUND(AVG(CASE
            WHEN DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56
            THEN tor.review_score
        END), 2) AS media_avaliacoes_d56,

        ROUND(AVG(CASE
            WHEN DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365
            THEN tor.review_score
        END), 2) AS media_avaliacoes_d365,
    -- ===========================================
    -- Desvio Padrão das avaliações por seller 28,56,365 dias e lifetime
    -- ===========================================  
        ROUND(STDDEV(tor.review_score), 2) AS desvpad_avaliacoes_lifetime,

        ROUND(STDDEV(CASE 
            WHEN DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28
            THEN tor.review_score
        END), 2) AS desvpad_avaliacoes_d28,

        ROUND(STDDEV(CASE
            WHEN DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56
            THEN tor.review_score
        END), 2) AS desvpad_avaliacoes_d56,

        ROUND(STDDEV(CASE
            WHEN DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365
            THEN tor.review_score
        END), 2) AS desvpad_avaliacoes_d365,
    -- ===========================================
    -- Percentual de avaliações recebidas pelo vendedor com nota 1 por 28,56,365 dias e lifetime
    -- ===========================================  
        ROUND(AVG(CASE WHEN tor.review_score = 1 THEN 1 ELSE 0 END),2) as pct_nota1,

        ROUND(AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28) AND (tor.review_score = 1) THEN 1 ELSE 0 END),2) AS pct_nota1_d28,

        ROUND(AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56) AND  (tor.review_score = 1) THEN 1 ELSE 0 END),2) AS pct_nota1_d56,

        ROUND(AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365) AND (tor.review_score = 1) THEN 1 ELSE 0 END),2) AS pct_nota1_d365,
    -- ===========================================
    -- Percentual de avaliações recebidas pelo vendedor com nota 2 por 28,56,365 dias e lifetime
    -- =========================================== 
        ROUND(AVG(CASE WHEN tor.review_score = 2 THEN 1 ELSE 0 END),2) AS pct_nota2,

        ROUND(AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28) AND (tor.review_score = 2) THEN 1 ELSE 0 END),2) AS pct_nota2_d28,

        ROUND(AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56) AND  (tor.review_score = 2) THEN 1 ELSE 0 END),2) AS pct_nota2_d56,

        ROUND(AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365) AND (tor.review_score = 2) THEN 1 ELSE 0 END),2) AS pct_nota2_d365,
    -- ===========================================
    -- Percentual de avaliações recebidas pelo vendedor com nota 3 por 28,56,365 dias e lifetime
    -- =========================================== 
        AVG(CASE 
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28) AND tor.review_score = 3
                THEN 1
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28) THEN 0 END) AS perc_nota_3_d28,

        AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56) AND tor.review_score = 3 THEN 1
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56) THEN 0 END) AS perc_nota_3_d56,

        AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365) AND tor.review_score = 3 THEN 1
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365) THEN 0 END) AS perc_nota_3_d365,

        AVG(CASE WHEN tor.review_score = 3 THEN 1 ELSE 0 END) AS perc_nota_3_lifetime,
    -- ===========================================
    -- Percentual de avaliações recebidas pelo vendedor com nota 4 por 28,56,365 dias e lifetime
    -- =========================================== 
        AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28) AND tor.review_score = 4 THEN 1
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28) THEN 0 END) AS perc_nota_4_d28,

        AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56) AND tor.review_score = 4 THEN 1
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56) THEN 0 END) AS perc_nota_4_d56,

        AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365) AND tor.review_score = 4 THEN 1
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365) THEN 0 END) AS perc_nota_4_d365,

        AVG(CASE WHEN tor.review_score = 4 THEN 1 ELSE 0 END) AS perc_nota_4_lifetime,
    -- ===========================================
    -- Percentual de avaliações recebidas pelo vendedor com nota 5 por 28,56,365 dias e lifetime
    -- =========================================== 
        AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28) AND tor.review_score = 5 THEN 1
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28) THEN 0 END) AS perc_nota_5_d28,

        AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56) AND tor.review_score = 5 THEN 1
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56) THEN 0 END) AS perc_nota_5_d56,

        AVG(CASE WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365) AND tor.review_score = 5 THEN 1
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365) THEN 0 END) AS perc_nota_5_d365,

        AVG(CASE WHEN tor.review_score = 5 THEN 1 ELSE 0 END) AS perc_nota_5_lifetime,
    -- ===========================================
    -- Percentual de Notas Boas:
    -- avaliações nota 4 ou 5 / quantidade de pedidos recebidos pelo seller por 28,56,365 dias e lifetime
    -- =========================================== 
        SUM(CASE 
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28)
                AND tor.review_score IN (4, 5)
                THEN 1 ELSE 0 
            END) * 1.0
        / NULLIF(SUM(CASE 
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28)
                THEN 1 ELSE 0 
            END), 0) AS pct_notas_boas_d28,

        SUM(CASE 
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56)
                AND tor.review_score IN (4, 5)
                THEN 1 ELSE 0 
            END) * 1.0
        / NULLIF(SUM(CASE 
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56)
                THEN 1 ELSE 0 
            END), 0) AS pct_notas_boas_d56,

        SUM(CASE 
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365)
                AND tor.review_score IN (4, 5)
                THEN 1 ELSE 0 
            END) * 1.0
        / NULLIF(SUM(CASE 
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365)
                THEN 1 ELSE 0 
            END), 0) AS pct_notas_boas_d365,

        SUM(CASE 
                WHEN tor.review_score IN (4, 5)
                THEN 1 ELSE 0 
            END) * 1.0
        / NULLIF(COUNT(toi.order_id), 0) AS pct_notas_boas_lifetime,
    -- ===========================================
    --  Percentual de Notas Ruins:
    -- avaliações nota 1 ou 2 / quantidade de pedidos recebidos pelo seller por 28,56,365 dias e lifetime
    -- =========================================== 
        SUM(CASE 
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28)
                AND tor.review_score IN (1, 2)
                THEN 1 ELSE 0 
            END) * 1.0
        / NULLIF(SUM(CASE 
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 28)
                THEN 1 ELSE 0 
            END), 0) AS pct_notas_ruins_d28,

        SUM(CASE 
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56)
                AND tor.review_score IN (1, 2)
                THEN 1 ELSE 0 
            END) * 1.0
        / NULLIF(SUM(CASE 
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 56)
                THEN 1 ELSE 0 
            END), 0) AS pct_notas_ruins_d56,

        SUM(CASE 
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365)
                AND tor.review_score IN (1, 2)
                THEN 1 ELSE 0 
            END) * 1.0
        / NULLIF(SUM(CASE 
                WHEN (DATE_DIFF('{date}', tp.order_purchase_timestamp) <= 365)
                THEN 1 ELSE 0 
            END), 0) AS pct_notas_ruins_d365,

        SUM(CASE 
                WHEN tor.review_score IN (1, 2)
                THEN 1 ELSE 0 
            END) * 1.0
        / NULLIF(COUNT(toi.order_id), 0) AS pct_notas_ruins_lifetime



    FROM tb_pedidos AS tp LEFT JOIN olist.order_reviews AS tor ON tp.order_id = tor.order_id
                        LEFT JOIN olist.order_items AS toi ON tp.order_id = toi.order_id

    GROUP BY toi.seller_id 

)

SELECT '{date}' AS dtRef,
        *
FROM tb_reputation