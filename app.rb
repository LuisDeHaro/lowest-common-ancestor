
require 'sinatra'
require 'pg'
require './utils.rb'

set :bind, '0.0.0.0'
set :port, 3000

# content type JSON
before do
  content_type :json
end

# api endpoint
get "/common_ancestor" do
  
  a = params[:a]
  b = params[:b]
  query_type = params[:query_type] # -> ltree or recursive

  # throwing 400 if we don't have the proper inputs
  halt 400 if !a || !b
  
  begin

    # connecting to the database
    conection = PG.connect host: 'localhost', 
    					 	dbname: 'dataplor',
    					  user: 'postgres', 
    					  password: 'mandarina'

    # reading data from the database
    # deciding which query to use for the results

    if query_type and query_type == 'ltree'

    	query_result = conection.exec Utils.sql_query_text_ltree( 
				conection.escape(a), 
				conection.escape(b) 
			)

    else

    	# recursive is used by default
    	query_result = conection.exec Utils.sql_query_text_recursive( 
				conection.escape(a), 
				conection.escape(b) 
			)

   	end
    
		# if we have data, we proceed 
    if query_result.cmd_tuples > 0
    	
    	# the first row is the root_id we are looking for
    	root_id = query_result.find { |r| r['rn'].to_i == 1 }

    	# the second row is the lowest_common_ancestor, that may be the same so in that case
    	# only one row is returned
    	if query_result.cmd_tuples > 1
    		lowest_common_ancestor = query_result.find { |r| r['rn'].to_i > 1 }
    	else
    		lowest_common_ancestor = root_id
    	end

    	# the depth is equal to the total records of the first query
    	depth = query_result[0]['total_records']

    	# finally we return the final data
    	{ 
    		root_id: root_id['id'], 
    		lowest_common_ancestor: lowest_common_ancestor['id'], 
    		depth: depth 

    	}.to_json

    # or else, we return an empty result
    else
    
  		{ 
  			root_id: nil, 
  			lowest_common_ancestor: nil, 
  			depth: nil 
  		}.to_json

   	end

  rescue PG::Error => e

    halt 500

  ensure

    conection.close if conection
  end

end
