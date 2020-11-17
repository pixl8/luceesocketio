component {

	this.name = "socket.io-lucee test harness application";
	this.mappings[ "/socketiolucee" ] = ExpandPath( "../../" );

	processingdirective preserveCase="true";

	public void function onRequest( required string requestedTemplate ) output=true {
		// each request, check to see if we need to setup our Server and listeners
		reloadCheck();

		include template=arguments.requestedTemplate;
	}

// private helpers
	private void function setupListeners() {
		var io = application.io;

		// log connections and disconnections
		io.on( "connect", function( socket ){
			SystemOutput( "A user connected...#arguments.socket.getId()#" );

			socket.on( "disconnect", function() {
				SystemOutput( "A user disconnected" );
			});

			thread socket=socket name="bg-thrd-#socket.getId()#" {
				sleep( 4000 );
				socket.send('Sent a message 4 seconds after connection!');
			}
		} );
	}

	private void function reloadCheck() {
		// Setup our server and listeners if either`?fwreinit=true` is
		// present in the URL, or if it has not yet been setup
		if ( !StructKeyExists( application, "io" ) || ( url.fwreinit ?: "" ) == "true" ) {
			shutdownServer();
			initServer();
			setupListeners();
		}
	}

	private void function initServer() {
		// create and start the server on default port, 3000
		application.io = new socketiolucee.models.SocketIoServer();
	}

	private void function shutdownServer() {
		if ( StructKeyExists( application, "io" ) ) {
			application.io.close();
			StructDelete( application, "io" );
		}

	}

}
