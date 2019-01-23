import scala.collection.mutable.HashSet
import scala.io._

var uris = HashSet[String]()

val CAT_URI = "http://purl.org/olia/ubyPos.owl#"

for(arg <- args) {
  val src = Source.fromFile(arg)
  for(line <- src.getLines) {
    var idx = line.indexOf(CAT_URI)
    while(idx >= 0) {
      val end = line.indexOf(">",idx)
      val uri = line.substring(idx,end)
      uris += uri
      idx = line.indexOf(CAT_URI,end)
    }
  }
}

for(uri <- uris.toList.sorted) {
  println(uri)
}
