import scala.io._
import java.io._

val lexEntryLine = ".*<LexicalEntry id=\"([\\w\\d_]+)\" partOfSpeech=\"(\\w+)\">.*".r
val formLine = ".*<FormRepresentation.*writtenForm=\"(.*)\"/>.*".r
val senseLine = ".*<Sense id=\"([\\w\\d_]+)\" index=\"(\\d+)\".*".r

val uris = Source.fromFile("../linking/wn30uris").getLines().toSet

val in = Source.fromFile("../data/ubyLexicons/wnInLMF.xml")

val out = new PrintWriter("../linking/uby2wn30.ttl")

out.println("@prefix wn30: <http://purl.org/vocabularies/princeton/wn30/> .")
out.println("@prefix ubywn: <http://lemon-model.net/lexica/uby/wn/> .")
out.println("@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .")
out.println()

var currentEntryId = ""
var currentPOS = ""
var currentForm = ""

def normalize(form : String) = form.replaceAll("[ \\.'/]","_")

for(line <- in.getLines()) {
	line match {
		case lexEntryLine(entryId,pos) => {
			currentEntryId = entryId
			currentPOS = pos
		}
		case formLine(form) => {
			currentForm = form
		}
		case senseLine(senseId,idx) => {
			val uri1 = "wn30:wordsense-" + normalize(currentForm) + "-" + currentPOS + "-" + idx
			val uri2 = "wn30:wordsense-" + normalize(currentForm) + "-" + currentPOS + "satellite-" + idx  
			if(uris contains uri1) {
			 	out.println("ubywn:"+senseId + " rdfs:seeAlso "+uri1 +" .");
			} else if(uris contains uri2) {
				out.println("ubywn:"+senseId + " rdfs:seeAlso "+uri1 + " .");
			} else {
				System.err.println("not found " + uri1);
			}
		}
		case _ =>
	}
}

out.flush
out.close
