#if os(Linux)
  import Glibc
#endif
import Inquiline
import Curassow
import Foundation
import Mustache

serve { request in
  print("--------")
  print(request.method)
  print(request.path)
  print(request.headers)
  print(request.body)
  
  
  if request.method == "GET" && request.path == "/" {
  
    let path = NSFileManager.defaultManager().currentDirectoryPath
    let template = try! Template(path: "\(path)/Sources/index.mustache")

    let data = [
      "goodWord": "鳥取",
      "badWord": "島根"
    ]
    
    do {
      let rendering = try template.render(Box(data))
      print(rendering)
      return Response(.Ok, contentType: "text/html; charset=UTF-8", body: rendering)
    } catch let error as NSError {
      print("something was wrong: \(error)")
    }
  }
  
  if request.method == "POST" && request.path == "/search" {
    return Response(.Ok, contentType: "text/html; charset=UTF-8", body: "Hello World")
  }
  
  return Response(.Ok, contentType: "text/html; charset=UTF-8", body: "なんじゃいこりゃ！長芋まんじゅうだがな              ")
}
