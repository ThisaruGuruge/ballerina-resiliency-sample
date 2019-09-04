import ballerina/http;

http:Client backendClientEP = new("http://localhost:10200", {
    retryConfig: {
        intervalInMillis: 3000,
        count: 3,
        backOffFactor: 2.0,
        maxWaitIntervalInMillis: 20000,
        statusCodes: [400, 401, 402, 403, 404, 500, 501, 502, 503]
    },
    timeoutInMillis: 2000
});

listener http:Listener retryListener = new(10100);

@http:ServiceConfig {
    basePath: "/"
}
service RetryService on retryListener {
    resource function getWeather(http:Caller caller, http:Request request) {
        var result = backendClientEP->get("/getWeather");
        http:Response response = new;
        if (result is http:ClientError) {
            response.statusCode = 501;
        }
	}
}
