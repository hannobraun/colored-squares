module "Logic", [ "Input", "Entities", "Vec2", "Playtomic" ], ( Input, Entities, Vec2, Playtomic ) ->
	nextEntityId = 0

	entityFactories =
		"myEntity": ( args ) ->
			movement =
				center: args.center
				radius: args.radius
				speed : args.speed

			id = nextEntityId
			nextEntityId += 1

			entity =
				id: id
				components:
					"positions": [ 0, 0 ]
					"movements": movement
					"imageIds" : "images/star.png"

	# There are functions for creating and destroying entities in the Entities
	# module. We will mostly use shortcuts however. They are declared here and
	# defined further down in initGameState.
	createEntity  = null
	destroyEntity = null

	module =
		createGameState: ->
			gameState =
				next:
					numberOfSquares: 3

					offset : 3
					squares: []

				launchNext: false

				grid         : []
				changesInGrid: []

				scoreEvents: []

				lost : false
				reset: false

				score: 0

				# Game entities are made up of components. The components will
				# be stored in this map.
				components: {}

		initGameState: ( gameState ) ->
			Playtomic.play()

			# These are the shortcuts we will use for creating and destroying
			# entities.
			createEntity = ( type, args ) ->
				Entities.createEntity(
					entityFactories,
					gameState.components,
					type,
					args )
			destroyEntity = ( entityId ) ->
				Entities.destroyEntity(
					gameState.components,
					entityId )


			grid = gameState.grid
			next = gameState.next


			for x in [ 0...9 ]
				grid[ x ] = []
				for y in [ 0...9 ]
					grid[ x ][ y ] = "empty"


			Input.onKeys [ "left arrow" ], ->
				if gameState.columnRemoval
					return

				next.offset -= 1
				next.offset = Math.max( 0, next.offset )
			Input.onKeys [ "right arrow" ], ->
				if gameState.columnRemoval
					return

				next.offset += 1
				next.offset = Math.min(
					grid.length - next.squares.length,
					next.offset )

			Input.onKeys [ "space", "down arrow" ], ->
				if gameState.columnRemoval
					return

				unless gameState.lost
					gameState.launchNext = true

			Input.onKeys [ "enter" ], ->
				gameState.reset = gameState.lost


		updateGameState: ( gameState, currentInput, timeInS, passedTimeInS ) ->
			unless gameState.startTimeInS?
				gameState.startTimeInS = timeInS

			gameState.changesInGrid.length = 0
			gameState.scoreEvents.length = 0

			unless gameState.columnRemoval
				refillNext(
					gameState.next )
				launchNext(
					gameState,
					gameState.next,
					gameState.grid )
				blockSquares(
					gameState.grid,
					gameState )
				removeSquares(
					gameState,
					gameState.grid )
				checkIfColumnsHaveToBeRemoved(
					gameState.grid,
					gameState.next,
					gameState )
				removeFullColumns(
					gameState.grid,
					gameState.next,
					gameState )
				checkLoseCondition(
					gameState,
					gameState.grid,
					timeInS )


	refillNext = ( next ) ->
		if next.squares.length == 0
			for i in [ 0...next.numberOfSquares ]
				possibleSquares = [ "red", "green" ]
				randomIndex  = Math.floor( Math.random() * possibleSquares.length )
				randomSquare = possibleSquares[ randomIndex ]

				next.squares[ i ] = randomSquare

	launchNext = ( gameState, next, grid ) ->
		if gameState.launchNext
			gameState.launchNext  = false

			for square, i in next.squares
				x = i + next.offset

				y = -1
				for cell in grid[ x ]
					if cell == "empty"
						y += 1

				grid[ x ][ y ] = square

				gameState.changesInGrid.push( {
					type    : "next"
					position: [ x, y ]
					from    : "empty"
					to      : square } )

				if y > 0
					gameState.score += 1

			next.squares.length = 0

	blockSquares = ( grid, gameState ) ->
		for x in [ 0...grid.length ]
			topSquare = null

			for y in [ 0...grid[ 0 ].length ]
				square = grid[ x ][ y ]
				if topSquare == null and square != "empty"
					topSquare = square

				if topSquare != null and square != topSquare and square != "blocked"
					grid[ x ][ y ] = "blocked"

					gameState.changesInGrid.push( {
						type    : "block"
						position: [ x, y ]
						from    : square
						to      : "blocked" } )

	removeSquares = ( gameState, grid ) ->
		for x in [ 0...grid.length ]
			topSquare = grid[ x ][ 0 ]
			unless topSquare == "empty"
				secondSquare = grid[ x ][ 1 ]
				remove = topSquare == secondSquare

				removedSquares = 0

				for y in [ 0...grid[ x ].length ]
					square = grid[ x ][ y ]
					remove = remove and square == topSquare

					if remove
						square = grid[ x ][ y ]

						grid[ x ][ y ] = "empty"
						removedSquares += 1

						gameState.changesInGrid.push( {
							type    : "remove"
							position: [ x, y ]
							from    : square
							to      : "empty" } )

				score = removedSquares*removedSquares

				gameState.score += score

				if score > 0
					gameState.scoreEvents.push( {
						score : score
						column: x } )

	checkIfColumnsHaveToBeRemoved = ( grid, next, gameState ) ->
		if gameState.columnRemovalAnimationStarted
			return

		if gameState.columnRemovalAnimationFinished
			gameState.columnRemovalAnimationFinished = false
			return

		columnsToRemove = []

		if grid.length > next.numberOfSquares
			for column, x in grid
				topSquare = column[ 0 ]

				if topSquare != "empty"
					columnsToRemove.push( x )

		if columnsToRemove.length > 0
			gameState.columnRemoval   = true
			gameState.columnsToRemove = columnsToRemove

	removeFullColumns = ( grid, next, gameState ) ->
		if gameState.columnRemoval
			return

		columnsWereRemoved = false

		if grid.length > next.numberOfSquares

			noMoreColumnsToRemove = false

			until noMoreColumnsToRemove
				columnsToRemove = []

				for column, x in grid
					topSquare = column[ 0 ]

					if topSquare != "empty"
						columnsToRemove.push( x )

				if columnsToRemove.length > 0
					xToRemove = columnsToRemove.shift()
					grid.splice( xToRemove, 1 )

					columnsWereRemoved = true

					noMoreColumnsToRemove =
						columnsToRemove.length == 0 or grid.length == 3
				else
					noMoreColumnsToRemove = true

		if next.offset + next.numberOfSquares > grid.length
			next.offset = grid.length - next.numberOfSquares

		if columnsWereRemoved
			for column in grid
				currentY  = column.length - 1
				nextFreeY = column.length - 1

				until column[ currentY ] == "empty" || currentY < 0
					if column[ currentY ] == "blocked"
						column[ currentY ] = "empty"
					else
						square = column[ currentY ]
						column[ currentY ] = "empty"
						column[ nextFreeY ] = square

						nextFreeY -= 1

					currentY -= 1

	checkLoseCondition = ( gameState, grid, timeInS ) ->
		if gameState.columnRemoval
			return

		unless gameState.lost
			for column in grid
				topSquare = column[ 0 ]

				gameState.lost = gameState.lost or topSquare != "empty"

				if gameState.lost and not gameState.reportedStats
					timeTaken = timeInS - gameState.startTimeInS

					Playtomic.ranged( "score", gameState.score )
					Playtomic.average( "time", timeTaken )

					gameState.reportedStats = true


	module
