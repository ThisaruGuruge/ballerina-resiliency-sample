import ballerina/io;
import ballerina/http;

http:Client weatherClient = new("http://localhost:10100", {
    timeoutInMillis: 300000
});

# Prints `Hello World`.

public function main() {
    var result = weatherClient->get("/getWeather");
    if (result is http:ClientError) {
        io:println(result);
    } else {
        var temperature = result.getTextPayload();
        if (temperature is http:ClientError) {
            io:println(temperature);
        } else {
            io:print("Temperature is: ");
            io:println(result.getTextPayload());
        }
    }
}
