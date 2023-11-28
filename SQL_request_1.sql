WITH t1 as     
    (SELECT manager_name,
        sal,
        manager_id,
        vsp_name,
        DENSE_RANK () OVER (PARTITION BY data_vsp.vsp_name ORDER BY sal DESC) as rank
    FROM data_manager
    LEFT JOIN map_vsp2manager
    ON data_manager.id = map_vsp2manager.manager_id
    LEFT JOIN data_vsp
    ON map_vsp2manager.vsp_id = data_vsp.id)
    
SELECT manager_name,
        sal,
        vsp_name,
        CASE 
        WHEN sal = MAX(sal) OVER (PARTITION BY vsp_name) THEN '-1'
        ELSE (SELECT manager_name 
            FROM t1 as a 
            WHERE a.vsp_name = b.vsp_name and a.rank = b.rank-1 
            ORDER BY a.manager_id DESC 
            LIMIT 1)
        END as bigger_sal_name,
        CASE 
        WHEN sal = MAX(sal) OVER (PARTITION BY vsp_name) THEN -1
        ELSE (SELECT sal 
            FROM t1 as a 
            WHERE a.vsp_name = b.vsp_name and a.rank = b.rank-1 
            ORDER BY a.manager_id DESC 
            LIMIT 1)
        END as bigger_sal
FROM t1 as b
ORDER BY vsp_name, sal DESC, manager_id DESC
