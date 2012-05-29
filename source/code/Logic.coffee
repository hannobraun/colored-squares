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

			for x in [0..9]
				grid[ x ] = []
				for y in [0..9]
					grid[ x ][ y ] = "empty"

			grid[ 3 ][ 4 ] = "green"
			grid[ 4 ][ 3 ] = "red"

		updateGameState: ( gameState, currentInput, timeInS, passedTimeInS ) ->
			for entityId, position of gameState.components.positions
				movement = gameState.components.movements[ entityId ]

				angle = timeInS * movement.speed
				position[ 0 ] = movement.radius * Math.cos( angle )
				position[ 1 ] = movement.radius * Math.sin( angle )

				Vec2.add( position, currentInput.pointerPosition )
