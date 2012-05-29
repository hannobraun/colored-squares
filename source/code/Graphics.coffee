module "Graphics", [ "Rendering", "Camera", "Vec2" ], ( Rendering, Camera, Vec2 ) ->
	cellSize = 32
	gridSize = 10

	max = gridSize / 2 * cellSize
	min = -max


	module =
		createRenderState: ->
			renderState =
				renderables: []

		updateRenderState: ( renderState, gameState ) ->
			renderState.renderables.length = 0

			appendGrid(
				renderState.renderables )
			appendSquares(
				gameState.grid,
				renderState.renderables )
			appendNext(
				gameState.next,
				renderState.renderables )
			appendScore(
				gameState.score,
				renderState.renderables )
			appendEndScore(
				gameState.lost,
				gameState.score,
				renderState.renderables )


	appendGrid = ( renderables ) ->
		i = min

		while i <= max
			horizontal = Rendering.createRenderable( "line" )
			horizontal.resource =
				color: "rgb(255,255,255)"
				start: [ min, i ]
				end  : [ max, i ]

			vertical = Rendering.createRenderable( "line" )
			vertical.resource =
				color: "rgb(255,255,255)"
				start: [ i, min ]
				end  : [ i, max ]

			renderables.push( horizontal )
			renderables.push( vertical )

			i += cellSize

	appendSquares = ( grid, renderables ) ->
		for x in [ 0...grid.length ]
			for y in [ 0...grid[ x ].length ]
				cell = grid[ x ][ y ]
				appendCell(
					x,
					y,
					cell,
					renderables )

	appendNext = ( next, renderables ) ->
		for square, i  in next.squares
			appendCell(
				i + next.offset,
				-1,
				square,
				renderables )

	appendCell = ( x, y, cell, renderables ) ->
		margin = 2

		unless cell == "empty"
			renderable = Rendering.createRenderable( "rectangle" )
			renderable.position = [
				min + x*cellSize + margin
				min + y*cellSize + margin ]
			renderable.resource =
				size: [
					cellSize - margin*2
					cellSize - margin*2 ]

			renderable.resource.color = switch cell
				when "red"     then "rgb(255,0,0)"
				when "green"   then "rgb(0,255,0)"
				when "blocked" then "rgb(127,127,127)"

			renderables.push( renderable )

	appendScore = ( score, renderables ) ->
		renderable = Rendering.createRenderable( "text" )
		renderable.position = [ 0, max + 40 ]
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
				font: "40px Monospace"

			scoreMessage = Rendering.createRenderable( "text" )
			scoreMessage.position = [ 0, 30 ]
			scoreMessage.resource =
				string: "You got #{ score } points!"
				textColor: "rgb(0,0,0)"
				centered: [ true, false ]
				font: "40px Monospace"

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

	module
