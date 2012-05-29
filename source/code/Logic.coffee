module "Logic", [ "Input", "Entities", "Vec2" ], ( Input, Entities, Vec2 ) ->
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
					offset : 4
					squares: []

				launchNext: false

				grid: []

				# Game entities are made up of components. The components will
				# be stored in this map.
				components: {}

		initGameState: ( gameState ) ->
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


			for x in [0..9]
				grid[ x ] = []
				for y in [0..9]
					grid[ x ][ y ] = "empty"


			Input.onKeys [ "left arrow" ], ->
				next.offset -= 1
				next.offset = Math.max( 0, next.offset )
			Input.onKeys [ "right arrow" ], ->
				next.offset += 1
				next.offset = Math.min(
					grid.length - next.squares.length,
					next.offset )

			Input.onKeys [ "space" ], ( keyName, event ) ->
				gameState.launchNext = true

		updateGameState: ( gameState, currentInput, timeInS, passedTimeInS ) ->
			refillNext(
				gameState.next )
			launchNext(
				gameState,
				gameState.next,
				gameState.grid )


	refillNext = ( next ) ->
		if next.squares.length == 0
			for i in [0..2]
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

			next.squares.length = 0


	module
