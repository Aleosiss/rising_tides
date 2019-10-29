class AnalyticsSender extends TcpLinkClient;

function start() {
	`RTLOG("[TcpLinkClient] Resolving: "$TargetHost);
	resolve(TargetHost);
}

function BuildRequest() {
	// The HTTP request
	SendText("GET / HTTP/1.0");
	SendText("Host: " $ TargetHost);
	SendText("Connection: Close");

	// end it
	SendText("");
}


function int SendText( coerce string Str ) {
	super.SendText(Str$chr(13)$chr(10));
}