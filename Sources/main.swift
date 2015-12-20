#if os(Linux)
  import Glibc
#endif
import Inquiline
import Curassow
import Foundation
import Mustache

let GOOD_WORD = "鳥取県"
let BAD_WORD  = "島根県"

func genResponse(body: String) -> Response {
  var response = body
  let num = body.utf8.count - body.characters.count
  for _ in 1...num {
    response = response + " "
  }
  return Response(.Ok, contentType: "text/html; charset=UTF-8", body: response)
}

func templatePath(name: String) -> String {
  let current = NSFileManager.defaultManager().currentDirectoryPath
  return "\(current)/Sources/\(name).mustache"
}

func dbpedia(keyword: String) -> [String] {
  let urlString = "http://ja.dbpedia.org/data/\(keyword).json"
  let encoded: String = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
  let url: NSURL = NSURL(string: encoded)!
  let response: NSData? = try! NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: url), returningResponse: nil)
  
  let result: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(response!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
  let rItems = result["http://ja.dbpedia.org/resource/\(keyword)"]!
  let items: NSArray = rItems["http://dbpedia.org/ontology/wikiPageWikiLink"]! as! [NSDictionary]
  
  var links: [String] = []
  for (_, item) in items.enumerate() {
    let text = item["value"] as! String
    links.append(text.stringByReplacingOccurrencesOfString("http://ja.dbpedia.org/resource/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil))
  }
  return links
}

func status(items: [String]) -> String {
  if items.contains(GOOD_WORD) && items.contains(BAD_WORD) {
    return "even"
  } else if items.contains(GOOD_WORD) {
    return "good"
  } else if items.contains(BAD_WORD) {
    return "bad"
  } else {
    return "none"
  }
}

serve { request in
  if request.method == "GET" && request.path == "/" {
  
    let data = [
      "goodWord": GOOD_WORD,
      "badWord": BAD_WORD
    ]

    let template = try! Template(path: templatePath("index"))
    return genResponse(try! template.render(Box(data)))
  }
  
  if request.method == "POST" && request.path == "/search" {
  
    let param: String? = request.body?.stringByRemovingPercentEncoding
    let keywords: [String] = param!.componentsSeparatedByString("&").map({(x: String) -> String in
      return x.componentsSeparatedByString("=")[1]
    })
  
    let items = dbpedia(keywords[keywords.endIndex - 1])
    let data = [
      "keywords": keywords,
      "items": items,
      "status": status(items),
      "goodWord": GOOD_WORD,
      "badWord": BAD_WORD
    ]
    
    let template = try! Template(path: templatePath("result"))
    return genResponse(try! template.render(Box(data)))
  }
  
  return genResponse("なんじゃいこりゃ！長芋まんじゅうだがな")
}
