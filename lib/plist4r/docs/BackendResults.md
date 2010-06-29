# The benchmark above will output the following:
                                                                 
		 Squeezing                        |      #1 |      #2 |   #1/#2
		--------------------------------- | ------- | ------- | -------
		with #squeeze             x100000 |   0.122 |   0.117 |   1.04x
		with #gsub                x100000 |   0.267 |   0.279 |   0.96x
		all methods (totals)              |   0.390 |   0.396 |   0.98x
                                                               
		 Splitting                        |      #1 |      #2 |   #1/#2
		--------------------------------- | ------- | ------- | -------
		with #split               x100000 |   0.341 |   0.394 |   0.87x
		with #match                 x1000 |   0.002 |   0.003 |   0.82x

