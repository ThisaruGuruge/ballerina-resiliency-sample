import ballerina/http;
import ballerina/log;

http:Client backendClientEP = new("http://localhost:10200", {
    retryConfig: {
        intervalInMillis: 3000,
        count: 10,
        backOffFactor: 2.0,
        maxWaitIntervalInMillis: 20000,
        statusCodes: [400, 401, 402, 403, 404, 500, 501, 502, 503]
    },
    timeoutInMillis: 2000
});

listener http:Listener retryListener = new(10100);

int count = 0;

@http:ServiceConfig {
    basePath: "/"
}
service RetryService on retryListener {
    @http:ResourceConfig {
        methods: ["GET"]
	}
    resource function getWeather(http:Caller caller, http:Request request) {
        count += 1;
        log:printInfo("[RetryService] Request Received. Request Count: " + count.toString());
        var result = backendClientEP->get("/getWeather");
        http:Response response = new;
        if (result is http:ClientError) {
            response.statusCode = 501;
        } else {
            var sendResult = caller->respond(result);
        }
	}
}
