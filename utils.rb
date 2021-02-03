
# general purpose class
class Utils

	# separating this big sql statement from the main api code
	def self.sql_query_text(a, b)
		"-- recursive CTE
		WITH RECURSIVE 
		   results_1( id, parent_id, depth, obj_no ) AS
		(

		    SELECT
		        id, 
		        parent_id,
		        0 depth,
		        1 obj_no  /* placeholder IN order TO identify the dataset */
		    FROM csv
		    WHERE id = #{ a }

		    UNION ALL

		    SELECT  
		        t.id, 
		        t.parent_id,
		        r.depth + 1,
		        1 obj_no  /* placeholder IN order TO identify the dataset */
		    FROM csv t
		        INNER JOIN results_1 r ON r.parent_id = t.id

		),
		results_2( id, parent_id, depth, obj_no ) AS
		(

		    SELECT
		        id, 
		        parent_id,
		        0 depth,
		        2 obj_no  /* placeholder IN order TO identify the dataset */
		    FROM csv
		    WHERE id = #{ b }

		    UNION ALL

		    SELECT  
		        t.id, 
		        t.parent_id,
		        r.depth + 1,
		        2 obj_no   /* placeholder IN order TO identify the dataset */
		    FROM csv t
		        INNER JOIN results_2 r ON r.parent_id = t.id

		)
		-- GETTING THE RESULTS OF THE CTE
		SELECT * 
		FROM (
		    SELECT a.*,
		        row_number() over( ORDER BY a.depth DESC ) rn,
		        count(1) over() total_records
		    FROM results_1 a
		        INNER JOIN results_2 b ON a.id = b.id
		) results
		WHERE rn = 1  /* GETTING THE FIRST AND THE LAST RECORDS */
		    OR rn = total_records;"
	end

end
