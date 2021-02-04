
CREATE DATABASE dataplor;


/* First table w.o. ltree */

CREATE TABLE csv(
	id INT NOT NULL,
	parent_id INT NULL
);


-- indexing the table
CREATE INDEX ON csv (id, parent_id);



/* Second  table with ltree */


CREATE TABLE csv_ltree(
	id INT NOT NULL,
	parent_id INT NULL,
	path ltree
);


-- indexing the table
CREATE INDEX ON csv_ltree (id, parent_id);

CREATE INDEX ON csv_ltree (id);

CREATE INDEX ON csv_ltree USING GIST (path);


/*
 
--TESTING DATA wo ltree

INSERT INTO csv VALUES(  '125', '130' );

INSERT INTO csv VALUES(  '130', NULL );

INSERT INTO csv VALUES(  '2820230', '125' );

INSERT INTO csv VALUES(  '4430546', '125' );

INSERT INTO csv VALUES(  '5497637', '4430546' );



--- 12 M rows

WITH RECURSIVE tree ( id, parent, lvl ) AS
         (
            SELECT generate_series(1, 5) AS id, 
                   NULL :: int4 AS parent,
                   1 lvl
            UNION ALL
            SELECT n, 
                   id, 
                   lvl + 1 lvl
            FROM tree, 
                 generate_series(power(5, lvl) :: int4 + (id - 1)*5 + 1,
                 power(5, lvl) :: int4 + (id -1)*5 + 5 ) g(n)
            WHERE lvl < 10
         ) 
INSERT INTO csv(id, parent_id)
SELECT id, parent
FROM tree



--TESTING w LTREE

WITH RECURSIVE x AS
(
   SELECT 
     id::text, 
     parent_id::text, 
     id::text::ltree AS mypath                                                                                                      
   FROM csv
   WHERE parent_id IS NULL

   UNION ALL

   SELECT 
     y.id::text, 
     y.parent_id::text, 
     ltree_addtext(x.mypath, y.id::text) AS mypath
   FROM x, csv AS y                                                                                                                                           
   WHERE x.id::text = y.parent_id::text
 )
 INSERT INTO csv_ltree(id, parent_id, path)
 SELECT
    id::INT,
    parent_id::INT,
    mypath
 FROM x;


*/


