class AnalyticsSender extends TcpLinkClient;

private JsonObject Content;
private String ContentAsString;

function start() {
	`RTLOG("[TcpLinkClient] Resolving: "$TargetHost);
	resolve(TargetHost);
}

function BuildRequest() {
	ContentAsString = JsonObject.static.EncodeJson(Content);

	// The HTTP request
	SendText(GetRequestType() @ GetEndpoint() @ GetProtocolVersion());
	AddHeader("Host", TargetHost);
	AddHeader("Content-Type", CONTENT_TYPE_JSON);
	AddHeader("Content-Length", Len(ContentAsString));
	// end it
	AddHeader("Connection", "Close");

	AddBody();
}

function BuildRequestBody() {
	// space
	SendText("");

	// content
	SendText(ContentAsString)
}

function AddBody() {
	BuildRequestBody();
}

function int SendText( coerce string Str ) {
	super.SendText(Str$chr(13)$chr(10));
}

function int AddHeader( coerce string Header, coerce string Value ) {
	super.SendText(Header $ ": " $ Value $ chr(13) $chr(10));
}