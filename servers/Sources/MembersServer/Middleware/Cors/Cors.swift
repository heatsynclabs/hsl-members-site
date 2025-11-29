import Vapor

private let corsConfiguration = CORSMiddleware.Configuration(
	allowedOrigin: .any([
		"http://localhost:5173", "http://localhost:3000", "https://tiger.atnnn.com"
	]),
	allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS, .PATCH],
	allowedHeaders: [
		.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent,
		.accessControlAllowOrigin
	]
)

let cors = CORSMiddleware(configuration: corsConfiguration)
