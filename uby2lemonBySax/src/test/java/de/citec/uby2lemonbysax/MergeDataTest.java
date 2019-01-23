package de.citec.uby2lemonbysax;

import java.io.File;
import java.io.PrintWriter;
import java.util.Scanner;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author john
 */
public class MergeDataTest {

    public MergeDataTest() {
    }

    @BeforeClass
    public static void setUpClass() {
    }

    @AfterClass
    public static void tearDownClass() {
    }

    @Before
    public void setUp() {
    }

    @After
    public void tearDown() {
    }

    /**
     * Test of process method, of class MergeData.
     */
    @Test
    public void testProcess() throws Exception {
        System.out.println("process");
        final File tempFile = File.createTempFile("lexicon", ".lmf");
        tempFile.deleteOnExit();
        final Uby2LemonHandler handler = new Uby2LemonHandler(tempFile.getPath());
        
        final SAXParserFactory parserFactory = SAXParserFactory.newInstance();
        final SAXParser saxParser = parserFactory.newSAXParser();
        saxParser.parse(new File("src/test/resources/testfile.xml"), handler);
        
        MergeData instance = new MergeData(handler);
        Scanner scanner = new Scanner(new File("src/test/resources/testfile-split.xml"));
        PrintWriter out = new PrintWriter(tempFile);
        
        instance.process(scanner, out);
        
        out.close();
        final Scanner expScanner = new Scanner(new File("src/test/resources/testfile-merge.xml"));
        final Scanner resScanner = new Scanner(tempFile);
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