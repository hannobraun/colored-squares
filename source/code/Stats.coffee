module "Stats", [], ->
	callbackName = "noopStatsHelloGlobalJSONPCallback"

	localSessionId = "local#{ Math.random() * Number.MAX_VALUE }"
	sessionId      = null

	module =
		sayHello: ( unencodedAppId ) ->
			window[ callbackName ] = ( data ) ->
				console.log( data )
				sessionId = data.sessionId

			appId     = encodeURIComponent( unencodedAppId )
			userAgent = encodeURIComponent( navigator.userAgent )

			url = "http://stats.hannobraun.com/hello/#{ appId },#{ userAgent },#{ callbackName }"

			script = document.createElement( "script" )
			script.type = "text/javascript"
			script.src  = url
			
			head = document.getElementsByTagName( "head" )[ 0 ]
			head.appendChild( script )
