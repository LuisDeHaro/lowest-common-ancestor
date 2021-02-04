# Lowest Common Ancestor

Sinatra API with one endpoint: 

`/common_ancestor`

It takes two params, a and b and returns the root_id, lowest_common_ancestor_id, and depth of tree of the lowest common ancestor that those two node ids share.

#### Issues encountered during the initial problem evaluation

1. The data resides in a SQL table inside PGSQL: in order to consider a db side solution simple SQL queries won't do. Something more advanced needs to be implemented.
2. The tree can have *N* nodes so:
    1. For a database-side solution: performance is a concern because of whole table scans and intensive cpu loads
    2. For an app-side solution: retreving a large dataset to analyze it later, could be a performance issue in the future
3. As mentioned in the problem statement: there may not be a chance to pre-process the data in order to have it a more efficient schema for this scenario. So, we'll need to take the data as it is.

Taking into consideration that the SQL table only has two columns, a db-side solution could be more performant and simple as long as the right tools are used. This gives us also the chance to work with the data as it is.

Having decided to go for a db-side solution, now is time to evaluate options.

#### Options considered for the db-side solution

##### 1. LTREE

https://www.postgresql.org/docs/9.5/ltree.html



##### 2. Recursive CTE (Common table expression) and window functions

https://www.postgresql.org/docs/9.1/queries-with.html
https://www.postgresql.org/docs/9.1/tutorial-window.html

1.4 ms - 12 M records


#### How to install the project

1. Clone this repo
2. Make sure you have a PGSQL server running
3. Connect to the PG server and create the needed table and data (database-structure.sql)
4. Open a terminal and inside the project's folder run: `ruby app.rb -s Puma`
5. Make a GET request to the server. For example:
`http://localhost:3000/common_ancestor?a=4430546&b=4430546`
