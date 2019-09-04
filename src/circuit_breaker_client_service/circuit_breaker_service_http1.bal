import ballerina/http;
import ballerina/log;

http:RollingWindow rollingWindowConfig = {
    requestVolumeThreshold: 3,
	timeWindowInMillis: 10000,
	bucketSizeInMillis: 2000 // 5 Buckets
};

http:CircuitBreakerConfig circuitBreakerConfig = {
    rollingWindow: rollingWindowConfig,
    resetTimeInMillis: 10000,
    failureThreshold: 0.3, // If more than 3 requests failed among 10 requests, circuit trips.
    statusCodes: [400, 401, 402, 403, 404, 500, 501, 502, 503]
};

http:ClientEndpointConfig clientConfig = {
    circuitBreaker: circuitBreakerConfig,
    timeoutInMillis: 2000
};

http:Client weatherClient = new("http://localhost:10300", clientConfig);

listener http:Listener circuitBreakerListener = new(10200);

@http:ServiceConfig {
    basePath: "/"
}
service CallBackendService on circuitBreakerListener {
    @http:ResourceConfig {
        methods: ["GET"]
	}
    resource function getWeather(http:Caller caller, http:Request request) {
        log:printInfo("[CircuitBreakerService] Request received from the client");
        http:Response response = new;
        var backendResponse = weatherClient->get("/getWeather");
        if (backendResponse is http:ClientError) {
            response.statusCode = 503;
            response.setPayload(backendResponse.toString());
        } else {
            response = backendResponse;
        }
        var result = caller->respond(backendResponse.toString());
        handleResult(result);
	}
}
