module "Stats", [], ->
	callbackName = "noopStatsHelloGlobalJSONPCallback"

	appId     = encodeURIComponent( "Colored Squares" )
	userAgent = encodeURIComponent( navigator.userAgent )

	sessionId      = null
	localSessionId = "local#{ Math.random() * Number.MAX_VALUE }"

	module =
		sayHello: ->
			window[ callbackName ] = ( data ) ->
				sessionId = data.sessionId

			url = "http://stats.hannobraun.com/hello/#{ appId },#{ userAgent },#{ callbackName }"

			script = document.createElement( "script" )
			script.type = "text/javascript"
			script.src  = url
			
			head = document.getElementsByTagName( "head" )[ 0 ]
			head.appendChild( script )

		submit: ( unencodedTopic, data ) ->
			topic = encodeURIComponent( unencodedTopic )

			url = "http://stats.hannobraun.com/submit/#{ appId }/#{ topic }"

			stats =
				sessionId     : sessionId
				localSessionId: localSessionId
				data          : data

			request = new XMLHttpRequest()
			request.open( "POST", url, true )
			request.setRequestHeader( "Content-Type", "application/json" )
			request.send( JSON.stringify( stats ) )
