SELECT b.*,
       CASE WHEN b.height NOT BETWEEN b.lcl AND b.ucl THEN TRUE
	    ELSE FALSE END AS alert
FROM (
	SELECT a.*,
	       a.avg_height + 3 * (a.stddev_height/SQRT(5)) AS UCL,
	       a.avg_height - 3 * (a.stddev_height/SQRT(5)) AS LCL
    	FROM (
		SELECT operator,
	   	       ROW_NUMBER() OVER moving_totals AS row_number,
	   	       height,
	               AVG(height) OVER moving_totals AS avg_height,
	               STDDEV(height) OVER moving_totals AS stddev_height
	    	FROM manufacturing_parts
		WINDOW moving_totals AS (PARTITION BY operatorORDER BY item_no
			ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
		)
	) AS a
	WHERE a.row_number >= 5
) AS b;
