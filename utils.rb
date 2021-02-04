
# general purpose class
class Utils

	# separating this big sql statement from the main api code
	def self.sql_query_text_recursive(a, b)
		"-- recursive CTE
		WITH RECURSIVE 
		   results_1( id, parent_id, depth, obj_no ) AS
		(

		    SELECT
		        id, 
		        parent_id,
		        0 depth,
		        1 obj_no  /* placeholder IN order TO identify the dataset */
		    FROM csv_ltree
		    WHERE id = #{ a }

		    UNION ALL

		    SELECT  
		        t.id, 
		        t.parent_id,
		        r.depth + 1,
		        1 obj_no  /* placeholder IN order TO identify the dataset */
		    FROM csv_ltree t
		        INNER JOIN results_1 r ON r.parent_id = t.id

		),
		results_2( id, parent_id, depth, obj_no ) AS
		(

		    SELECT
		        id, 
		        parent_id,
		        0 depth,
		        2 obj_no  /* placeholder IN order TO identify the dataset */
		    FROM csv_ltree
		    WHERE id = #{ b }

		    UNION ALL

		    SELECT  
		        t.id, 
		        t.parent_id,
		        r.depth + 1,
		        2 obj_no   /* placeholder IN order TO identify the dataset */
		    FROM csv_ltree t
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

	# separating this big sql statement from the main api code
	def self.sql_query_text_ltree(a, b)
		"-- CTE
		WITH  
		   results_1( id, parent_id, obj_no ) AS
		(
		    SELECT
		      id, 
		      parent_id,
		      1 obj_no  /* placeholder IN order TO identify the dataset */
		    FROM
		      csv_ltree
		    WHERE
		      path @> (
		        SELECT
		          path
		        FROM
		          csv_ltree
		        WHERE
		          id = #{ a }
		      )
		    
		),
		results_2( id, parent_id, obj_no ) AS
		(

		   SELECT
		      id, 
		      parent_id,
		      1 obj_no  /* placeholder IN order TO identify the dataset */
		    FROM
		      csv_ltree
		    WHERE
		      path @> (
		        SELECT
		          path
		        FROM
		          csv_ltree
		        WHERE
		          id = #{ b }
		      )

		)
		-- GETTING THE RESULTS OF THE CTE
		SELECT * 
		FROM (
		    SELECT a.*,
		        row_number() over() rn,
		        count(1) over() total_records
		    FROM results_1 a
		        INNER JOIN results_2 b ON a.id = b.id
		) results
		WHERE rn = 1  /* GETTING THE FIRST AND THE LAST RECORDS */
		    OR rn = total_records;
		"

	end

end
