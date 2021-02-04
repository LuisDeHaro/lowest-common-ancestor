

# Lowest Common Ancestor

Sinatra API with one endpoint: 

`/common_ancestor`

It takes two params, `a` and `b` and returns the root_id, lowest_common_ancestor_id, and depth of tree of the lowest common ancestor that those two node ids share. 

Optional parameter `query_type` with values ENUM ( 'ltree', 'recursive' ) in order to choose one method or the other for the data retrieval.

Example output:

`{root_id: 130, lowest_common_ancestor: 4430546, depth: 3}`

#### Issues encountered during the initial problem evaluation

1. The data resides in a SQL table inside PGSQL: in order to consider a db side solution simple SQL queries won't do. Something more advanced needs to be implemented.
2. The tree can have *N* nodes so:
    1. For a database-side solution: performance is a concern because of whole table scans and intensive cpu loads
    2. For an app-side solution: retreving a large dataset to analyze it later, could be a performance issue in the future
3. As mentioned in the problem statement: there may not be a chance to pre-process the data in order to have it a more efficient schema for this scenario. 

Taking into consideration that the SQL queries only involve two columns, a db-side solution could be more performant and simple as long as the right tools are used. This gives us also the chance to work with the data as it is.

Having decided to go for a db-side solution, now is time to evaluate options.

#### Database schema

For non-LREE queries:

`CREATE TABLE csv(
	id INT NOT NULL,
	parent_id INT NULL
);
`

For LTREE queries:

`CREATE TABLE csv_ltree(
	id INT NOT NULL,
	parent_id INT NULL,
	path ltree
);`

At the end of the day only one schema could be used.

#### Options considered for the db-side solution

The exact SQL queries used for both cases can be found in: `utils.rb`

##### 1. LTREE

https://www.postgresql.org/docs/9.5/ltree.html

Results: 27.2 - 34.1 ms with +12 M records

Table indexes:

`CREATE INDEX ON csv_ltree (id, parent_id);`
`CREATE INDEX ON csv_ltree (id);`
`CREATE INDEX ON csv_ltree USING GIST (path);`

##### 2. Recursive CTE (Common table expression) and window functions

https://www.postgresql.org/docs/9.1/queries-with.html
https://www.postgresql.org/docs/9.1/tutorial-window.html

Results: 1.4 - 2.1 ms with +12 M records

Table indexes:

`CREATE INDEX ON csv (id, parent_id);`

#### Based on the performance and simplicity (no extra modules), we have a winner

*CTE* is showing a better performance than *LTREE* for this +12M records

#### How to install the project

1. Clone this repo
2. Make sure you have a PGSQL server running
3. Connect to the PG server and create the needed databases, tables, indexes and test data (database-structure.sql)
4. Open a terminal and inside the project's folder run: `ruby app.rb -s Puma`
5. Make a GET request to the server. For example:
`http://localhost:3000/common_ancestor?a=4430546&b=4430546`
`http://localhost:3000/common_ancestor?a=4430546&b=4430546&query_type=recursive`

