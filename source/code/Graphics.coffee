module "Graphics", [ "Rendering", "Camera", "Vec2" ], ( Rendering, Camera, Vec2 ) ->
	gridWidth = 32
	gridSize  = 10


	module =
		createRenderState: ->
			renderState =
				renderables: []

		updateRenderState: ( renderState, gameState ) ->
			renderState.renderables.length = 0

			appendGrid(
				renderState.renderables )


	appendGrid = ( renderables ) ->
		max = gridSize / 2 * gridWidth
		min = -max

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

			i += gridWidth


	module
