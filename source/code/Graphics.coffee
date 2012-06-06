module "Graphics", [ "Rendering", "Camera", "Vec2" ], ( Rendering, Camera, Vec2 ) ->
	cellSize = 32
	gridSize = 9


	module =
		createRenderState: ->
			renderState =
				renderables: []
				animations : []

		updateRenderState: ( renderState, gameState, passedTimeInS ) ->
			renderState.renderables.length = 0

			for change in gameState.changesInGrid
				renderState.animations.push( {
					t       : 0
					position: change.position
					from    : change.from
					to      : change.to } )

			animationsToRemove = []
			renderState.animations = for animation, i in renderState.animations when animation.t <= 1.0
				animation.t += passedTimeInS / 0.2
				animation
				

			appendGrid(
				gameState.grid,
				renderState.renderables )
			appendSquares(
				gameState.grid,
				renderState.renderables,
				renderState.animations )
			appendNext(
				gameState.next,
				gameState.grid,
				renderState.renderables,
				renderState.animations )
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

	appendSquares = ( grid, renderables, animations ) ->
		for x in [ 0...grid.length ]
			for y in [ 0...grid[ x ].length ]
				square = grid[ x ][ y ]
				appendSquare(
					x,
					y,
					grid,
					square,
					renderables,
					animations )

	appendNext = ( next, grid, renderables, animations ) ->
		for square, i  in next.squares
			appendSquare(
				i + next.offset,
				-1,
				grid,
				square,
				renderables,
				animations )

	appendSquare = ( x, y, grid, square, renderables, animations ) ->
		margin = 2

		animation = null
		for theAnimation in animations
			if theAnimation.position[ 0 ] == x and theAnimation.position[ 1 ] == y
				animation = theAnimation

		console.log( animation ) unless animation == null

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

			console.log( renderable.resource.color )

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
