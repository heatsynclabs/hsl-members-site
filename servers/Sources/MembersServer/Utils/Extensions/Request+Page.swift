import struct Fluent.PageRequest
import class Vapor.Request

extension Request {
    var pagination: PageRequest {
        let page = self.query[Int.self, at: "page"]
        let per = self.query[Int.self, at: "per"]
        return PageRequest(page: page ?? 1, per: per ?? 20)
    }
}
