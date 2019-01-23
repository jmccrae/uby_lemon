import scala.io._
import java.io._

val lexEntryLine = ".*<LexicalEntry id=\"([\\w\\d_]+)\" partOfSpeech=\"(\\w+)\">.*".r
val formLine = ".*<FormRepresentation.*writtenForm=\"(.*)\"/>.*".r

val uris = Source.fromFile("../linking/wn20uris").getLines().toSet

val in = Source.fromFile("../data/ubyLexicons/wnInLMF.xml")

val out = new PrintWriter("../linking/uby2wn20.ttl")

out.println("@prefix wn20instances: <http://www.w3.org/2006/03/wn/wn20/instances/> .")
out.println("@prefix ubywn: <http://lemon-model.net/lexica/uby/wn/> .")
out.println("@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .")
out.println()

var currentEntryId = ""

def normalize(form : String) = form.replaceAll("[ \\.'/]","_")

for(line <- in.getLines()) {
	line match {
		case lexEntryLine(entryId,pos) => {
			currentEntryId = entryId
		}
		case formLine(form) => {
			val uri1 = "wn20instances:word-" + normalize(form)  
			if(uris contains uri1) {
			 	out.println("ubywn:"+currentEntryId + " rdfs:seeAlso "+uri1 +" .");
			} else {
				System.err.println("not found " + uri1);
			}
		}
		case _ =>
	}
}

out.flush
out.close
