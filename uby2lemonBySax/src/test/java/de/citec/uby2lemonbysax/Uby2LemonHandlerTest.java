package de.citec.uby2lemonbysax;

import java.io.File;
import java.util.Scanner;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author john
 */
public class Uby2LemonHandlerTest {
    
    @Test
    public void test() throws Exception {
        final File file = File.createTempFile("lexicon", ".lmf"); 
        file.deleteOnExit();
        final Uby2LemonHandler handler = new Uby2LemonHandler(file.getPath());
        
        final SAXParserFactory parserFactory = SAXParserFactory.newInstance();
        final SAXParser saxParser = parserFactory.newSAXParser();
        saxParser.parse(new File("src/test/resources/testfile.xml"), handler);
        final Scanner expScanner = new Scanner(new File("src/test/resources/testfile-split.xml"));
        final Scanner resScanner = new Scanner(file);
        while(expScanner.hasNextLine()) {
            assertTrue(resScanner.hasNextLine());
            final String expLine = expScanner.nextLine().replaceAll("\\s+"," ");
            final String resLine = resScanner.nextLine().replaceAll("\\s+"," ");
            //System.err.println(expLine);
            //System.err.println(resLine);
            assertEquals(expLine, resLine);
        }
        assertFalse(resScanner.hasNextLine());
    }
}
