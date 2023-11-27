WITH t1 as     
    (SELECT manager_name,
        sal,
        manager_id,
        vsp_name,
        DENSE_RANK () OVER (PARTITION BY data_vsp.vsp_name ORDER BY sal DESC) as rank,
        DENSE_RANK () OVER (PARTITION BY data_vsp.vsp_name ORDER BY sal DESC) + 1 as coef
    FROM data_manager
    LEFT JOIN map_vsp2manager
    ON data_manager.id = map_vsp2manager.manager_id
    LEFT JOIN data_vsp
    ON map_vsp2manager.vsp_id = data_vsp.id),
    
 t2 as (SELECT *
 FROM
 (SELECT DISTINCT manager_name, sal, vsp_name, 
     MAX(manager_id) OVER (PARTITION BY manager_name, sal, vsp_name ORDER BY sal DESC) as id 
 FROM
(SELECT a.manager_name,
        a.sal,
        a.vsp_name,
        b.manager_id,
        COALESCE(b.vsp_name, a.vsp_name) as bigger_vsp
    FROM t1 as a
    LEFT JOIN t1 as b
    ON a.rank = b.coef) as c
WHERE vsp_name = bigger_vsp) as d
ORDER BY vsp_name, sal DESC)

SELECT t2.manager_name,
    t2.sal,
    t2.vsp_name,
    COALESCE(t3.manager_name, '-1') as bigger_sal_name,
    COALESCE(t3.sal, '-1') as bigger_sal
FROM t2
LEFT JOIN data_manager as t3
USING (id)