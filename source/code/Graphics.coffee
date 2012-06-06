module "Graphics", [ "Rendering", "Camera", "Vec2" ], ( Rendering, Camera, Vec2 ) ->
	cellSize = 32
	gridSize = 9
	margin   = 2


	module =
		createRenderState: ->
			renderState =
				renderables: []

				squareAnimations       : []
				scoreAnimations        : []
				columnRemovalAnimations: []

		updateRenderState: ( renderState, gameState, passedTimeInS ) ->
			renderState.renderables.length = 0

			for change in gameState.changesInGrid
				duration = switch change.type
					when "next"   then 0.2
					when "block"  then 0.5
					when "remove" then 0.5

				renderState.squareAnimations.push( {
					t       : 0
					position: change.position
					from    : change.from
					to      : change.to
					duration: duration } )

			for scoreEvent in gameState.scoreEvents
				renderState.scoreAnimations.push( {
					t     : 0
					score : scoreEvent.score
					column: scoreEvent.column } )


			if gameState.columnRemoval and not gameState.columnRemovalAnimationStarted
				gameState.columnRemovalAnimationStarted = true
				for column in gameState.columnsToRemove
					renderState.columnRemovalAnimations.push( {
						t     : 0
						column: column } )



			renderState.squareAnimations = for animation, i in renderState.squareAnimations when animation.t <= 1.0
				animation.t += passedTimeInS / animation.duration
				animation

			renderState.scoreAnimations = for animation, i in renderState.scoreAnimations when animation.t <= 1.0
				animation.t += passedTimeInS / 1.0
				animation

			renderState.columnRemovalAnimations = for animation, i in renderState.columnRemovalAnimations when animation.t <= 1.0
				animation.t += passedTimeInS / 1.0
				animation


			if renderState.columnRemovalAnimations.length == 0
				if gameState.columnRemovalAnimationStarted
					gameState.columnRemovalAnimationFinished = true

				gameState.columnRemovalAnimationStarted  = false
				gameState.columnRemoval                  = false
				

			appendGrid(
				gameState.grid,
				renderState.renderables )
			appendSquares(
				gameState.grid,
				renderState.renderables,
				renderState.squareAnimations )
			appendNext(
				gameState.next,
				gameState.grid,
				renderState.renderables,
				renderState.squareAnimations )
			appendColumnRemovalAnimation(
				gameState.grid,
				renderState.renderables,
				renderState.columnRemovalAnimations )
			appendScoreAnimations(
				gameState.grid,
				renderState.scoreAnimations,
				renderState.renderables )
			appendScore(
				gameState.score,
				gameState.grid,
				renderState.renderables )
			appendEndScore(
				gameState.lost,
				gameState.score,
				renderState.renderables )


	appendGrid = ( grid, renderables ) ->
		x = xMin( grid )
		while x <= xMax( grid )
			vertical = Rendering.createRenderable( "line" )
			vertical.resource =
				color: "rgb(255,255,255)"
				start: [ x, yMin( grid ) ]
				end  : [ x, yMax( grid ) ]

			renderables.push( vertical )

			x += cellSize

		y = yMin( grid )
		while y <= yMax( grid )
			horizontal = Rendering.createRenderable( "line" )
			horizontal.resource =
				color: "rgb(255,255,255)"
				start: [ xMin( grid ), y ]
				end  : [ xMax( grid ), y ]

			renderables.push( horizontal )

			y += cellSize

	appendSquares = ( grid, renderables, squareAnimations ) ->
		for x in [ 0...grid.length ]
			for y in [ 0...grid[ x ].length ]
				square = grid[ x ][ y ]
				appendSquare(
					x,
					y,
					grid,
					square,
					renderables,
					squareAnimations )

	appendNext = ( next, grid, renderables, squareAnimations ) ->
		for square, i  in next.squares
			appendSquare(
				i + next.offset,
				-1,
				grid,
				square,
				renderables,
				squareAnimations )

	appendSquare = ( x, y, grid, square, renderables, squareAnimations ) ->
		animation = null
		for theAnimation in squareAnimations
			if theAnimation.position[ 0 ] == x and theAnimation.position[ 1 ] == y
				animation = theAnimation

		if animation == null
			unless square == "empty"
				renderable = Rendering.createRenderable( "rectangle" )
				renderable.position = [
					xMin( grid ) + x*cellSize + margin
					yMin( grid ) + y*cellSize + margin ]
				renderable.resource =
					size: [
						cellSize - margin*2
						cellSize - margin*2 ]
					color: convertColor( squareColor( square ) )

				renderables.push( renderable )
		else
			fromColor = squareColor( animation.from )
			toColor   = squareColor( animation.to   )

			animatedColor = [
				interpolate( fromColor[ 0 ], toColor[ 0 ], animation.t )
				interpolate( fromColor[ 1 ], toColor[ 1 ], animation.t )
				interpolate( fromColor[ 2 ], toColor[ 2 ], animation.t ) ]

			renderable = Rendering.createRenderable( "rectangle" )
			renderable.position = [
				xMin( grid ) + x*cellSize + margin
				yMin( grid ) + y*cellSize + margin ]
			renderable.resource =
				size: [
					cellSize - margin*2
					cellSize - margin*2 ]
				color: convertColor( animatedColor )

			renderables.push( renderable )

	squareColor = ( square ) ->
		switch square
			when "red"     then [ 255,   0,   0 ]
			when "green"   then [   0, 255,   0 ]
			when "blocked" then [ 127, 127, 127 ]
			when "empty"   then [   0,   0,   0 ]

	convertColor = ( colorArray ) ->
		"rgb(#{ colorArray[ 0 ] },#{ colorArray[ 1 ] },#{ colorArray[ 2 ] })"

	interpolate = ( a, b, t ) ->
		Math.floor( a + ( b - a ) * t )

	appendColumnRemovalAnimation = ( grid, renderables, columnRemovalAnimations ) ->
		for animation in columnRemovalAnimations
			alpha = animation.t
			color = "rgba(0,0,0,#{ alpha })"

			renderable = Rendering.createRenderable( "rectangle" )
			renderable.position = [
				xMin( grid ) + animation.column*cellSize
				yMin( grid ) +                0*cellSize ]
			renderable.resource =
				color: color
				size : [
					cellSize * 1
					cellSize * grid[ animation.column ].length ]

			renderables.push( renderable )

	appendScoreAnimations = ( grid, scoreAnimations, renderables ) ->
		for animation in scoreAnimations
			renderable = Rendering.createRenderable( "text" )
			renderable.position = [
					xMin( grid ) + animation.column*cellSize + cellSize / 2
					yMin( grid ) +                0*cellSize + cellSize / 2 + 12 ]
			renderable.resource =
				string: "#{ animation.score }"
				textColor: "rgb(255,255,0)"
				centered: [ true, false ]
				font: "bold 24px Monospace"

			renderables.push( renderable )

	appendScore = ( score, grid, renderables ) ->
		renderable = Rendering.createRenderable( "text" )
		renderable.position = [ 0, yMax( grid ) + 40 ]
		renderable.resource =
			string: "#{ score }"
			textColor: "rgb(255,255,255)"
			centered: [ true, false ]
			font: "32px Monospace"

		renderables.push( renderable )

	appendEndScore = ( lost, score, renderables ) ->
		if lost
			size = [ 440, 150 ]

			position = Vec2.copy( size )
			Vec2.scale( position, -0.5)

			box = Rendering.createRenderable( "rectangle" )
			box.position = position
			box.resource =
				color: "rgb(255,255,255)"
				size : size

			congratulations = Rendering.createRenderable( "text" )
			congratulations.position = [ 0, -30 ]
			congratulations.resource =
				string: "Congratulations!"
				textColor: "rgb(0,0,0)"
				centered: [ true, false ]
				font: "35px Monospace"

			scoreMessage = Rendering.createRenderable( "text" )
			scoreMessage.position = [ 0, 30 ]
			scoreMessage.resource =
				string: "You got #{ score } points!"
				textColor: "rgb(0,0,0)"
				centered: [ true, false ]
				font: "35px Monospace"

			resetMessage = Rendering.createRenderable( "text" )
			resetMessage.position = [ 0, 60 ]
			resetMessage.resource =
				string: "(press enter to reset)"
				textColor: "rgb(0,0,0)"
				centered: [ true, false ]
				font: "20px Monospace"
			 

			renderables.push( box )
			renderables.push( congratulations )
			renderables.push( scoreMessage )
			renderables.push( resetMessage )

	xMin = ( grid ) ->
		-grid.length / 2 * cellSize

	xMax = ( grid ) ->
		grid.length / 2 * cellSize

	yMin = ( grid ) ->
		-grid[ 0 ].length / 2 * cellSize

	yMax = ( grid ) ->
		grid[ 0 ].length / 2 * cellSize


	module
