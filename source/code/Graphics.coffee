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
		margin = 2

		for x in [ 0...grid.length ]
			for y in [ 0...grid[ x ].length ]
				cell = grid[ x ][ y ]
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
						when "red"   then "rgb(255,0,0)"
						when "green" then "rgb(0,255,0)"

					renderables.push( renderable )


	module
