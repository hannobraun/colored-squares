module "Playtomic", [], ->
	gameId = 428191
	guid   = "5519409305d24c43"
	apiKey = "d0e76e8b41b74561ba6d2aeaff51ec"

	module =
		view: ->
			Playtomic.Log.View( gameId, guid, apiKey, document.location )

		play: ->
			Playtomic.Log.Play()

		average: ( metric, value ) ->
			console.log( "average", metric, value )
			Playtomic.Log.LevelAverageMetric( metric, "level1", value )

		ranged: ( metric, value ) ->
			console.log( "ranged", metric, value )
			Playtomic.Log.LevelRangedMetric( metric, "level1", value )
