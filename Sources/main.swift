import swiftra

#if os(Linux)
    import Glibc
#endif

get("/abc") { req in
    return Response("/abc was requested with GET")
}

post("/abc") { req in
    return "/abc was requested with POST, body = \(String(req.bodyString))"
}

get("/def") { req in
    return "/def was was requested with GET"
}

serve(8080)
