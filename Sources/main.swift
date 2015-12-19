#if os(Linux)
  import Glibc
#endif
import Inquiline
import Curassow
import Foundation
import Mustache

func genResponse(body: String) -> Response {
  // バイト数 - 文字数 を足す？
  return Response(.Ok, contentType: "text/html; charset=UTF-8", body: body)
}

serve { request in
  if request.method == "GET" && request.path == "/" {
  
    let path = NSFileManager.defaultManager().currentDirectoryPath
    let template = try! Template(path: "\(path)/Sources/index.mustache")

    let data = [
      "goodWord": "鳥取県",
      "badWord": "島根県"
    ]
    
    let rendering = try! template.render(Box(data))
    print(rendering)
    return genResponse(rendering)
  }
  
  if request.method == "POST" && request.path == "/search" {
  
    let path = NSFileManager.defaultManager().currentDirectoryPath
    let template = try! Template(path: "\(path)/Sources/result.mustache")

    let data = [
      "keywords": ["aaa", "vvv", "ccc"],
      "items": ["aaaaaa", "鳥取県", "eeeee", "sssss"],
      "status": "even",
      "goodWord": "鳥取県",
      "badWord": "島根県"
    ]
    
    let rendering = try! template.render(Box(data))
    print(rendering)
    return genResponse(rendering)
  }
  
  return genResponse("なんじゃいこりゃ！長芋まんじゅうだがな")
}
