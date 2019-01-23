import scala.io._
import java.io._

val lexEntryLine = ".*<LexicalEntry id=\"([\\w\\d_]+)\" partOfSpeech=\"(\\w+)\">.*".r
val formLine = ".*<FormRepresentation.*writtenForm=\"(.*)\"/>.*".r

val uris = Source.fromFile("../linking/wikturis").getLines().toSet

val in = Source.fromFile("../data/ubyLexicons/wnInLMF.xml")

val out = new PrintWriter("../linking/uby2wikt.ttl")

out.println("@prefix ubywn: <http://lemon-model.net/lexica/uby/wn/> .")
out.println("@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .")
out.println()

var currentEntryId = ""
var currentPOS = ""

def normalize(form : String) = form.replaceAll(" ","_").replaceAll("[\\.'/]","")

def ucFirst(form : String) = form(0).toUpper + form.substring(1) 

for(line <- in.getLines()) {
	line match {
		case lexEntryLine(entryId,pos) => {
			currentEntryId = entryId
			currentPOS = pos
		}
		case formLine(form) => {
			val uri1 = "http://wiktionary.dbpedia.org/resource/" + ucFirst(normalize(form)) + "-English-" + ucFirst(currentPOS)
			val uri2 = "http://wiktionary.dbpedia.org/resource/" + normalize(form) + "-English-" + ucFirst(currentPOS)    
			val uri3 = "http://wiktionary.dbpedia.org/resource/" + normalize(form).toLowerCase() + "-English-" + ucFirst(currentPOS)    	
			
			if(uris contains uri1) {
			 	out.println("ubywn:"+currentEntryId + " rdfs:seeAlso <"+uri1 +"> .");
			} else if(uris contains uri2) {
			 	out.println("ubywn:"+currentEntryId + " rdfs:seeAlso <"+uri2 +"> .");
			} else if(uris contains uri3) {
			 	out.println("ubywn:"+currentEntryId + " rdfs:seeAlso <"+uri3 +"> .");
			} else {
				var found = false
				for(i <- 1 to 8) {
					
				  val uri4 = "http://wiktionary.dbpedia.org/resource/" + ucFirst(normalize(form)) + "-English-" + i + "-" + ucFirst(currentPOS)
				  val uri5 = "http://wiktionary.dbpedia.org/resource/" + normalize(form) + "-English-" + i + "-"  + ucFirst(currentPOS)    
				  val uri6 = "http://wiktionary.dbpedia.org/resource/" + normalize(form).toLowerCase() + "-English-" + i + "-"  + ucFirst(currentPOS)    	
				  
				  if(uris contains uri4) {
				    out.println("ubywn:"+currentEntryId + " rdfs:seeAlso <"+uri4 +"> .");
				    found = true;
				  } else if(uris contains uri5) {
				    out.println("ubywn:"+currentEntryId + " rdfs:seeAlso <"+uri5 +"> .");
				    found = true;
				  } else if(uris contains uri6) {
				    out.println("ubywn:"+currentEntryId + " rdfs:seeAlso <"+uri6 +"> .");
				    found = true;
				  } 
				}
				if(!found) {
				  System.err.println("not found " + uri1);
				}
			}
		}
		case _ =>
	}
}

out.flush
out.close
