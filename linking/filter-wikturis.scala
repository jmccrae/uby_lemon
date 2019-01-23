import java.util.Scanner

val in = new Scanner(System.in)

while(in.hasNextLine()) {
  val s = in.nextLine()
  if((s contains "hasPoS>") && (s contains "English")) {
    val ss = s.split("[<>]")
    if(ss.length > 1 && !(ss(1) matches ".*\\d+en")) {
      println(ss(1));
    }
  }
}

