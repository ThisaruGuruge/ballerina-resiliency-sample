import ballerina/http;
import ballerina/log;
import ballerina/runtime;

listener http:Listener weatherService = new(10300);

int count = 0;
string http1ServicePrefix = "[WeatherService]";

@http:ServiceConfig {
    basePath: "/"
}
service WeatherService on weatherService {
    @http:ResourceConfig {
        methods: ["GET"]
	}
    resource function getWeather(http:Caller caller, http:Request req) {
        http:Response response = new;
        count += 1;
        log:printInfo("[BackendService] Request received. Request Count: " + count.toString());
        if (count < 3) {
            runtime:sleep(5000);
            sendErrorResponse(caller, response, http1ServicePrefix);
        } else if (count < 5) {
            sendErrorResponse(caller, response, http1ServicePrefix);
        } else {
            sendTemperatureResponse(caller, response, http1ServicePrefix);
        }
    }
}
