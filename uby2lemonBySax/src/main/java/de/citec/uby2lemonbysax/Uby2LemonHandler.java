/**
 * *******************************************************************************
 * Copyright (c) 2011, Monnet Project All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met: *
 * Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer. * Redistributions in binary
 * form must reproduce the above copyright notice, this list of conditions and
 * the following disclaimer in the documentation and/or other materials provided
 * with the distribution. * Neither the name of the Monnet Project nor the names
 * of its contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE MONNET PROJECT BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * *******************************************************************************
 */
package de.citec.uby2lemonbysax;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Set;
import java.util.TreeSet;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 *
 * @author John McCrae
 */
public class Uby2LemonHandler extends DefaultHandler {

    private PrintWriter out;
    private File current;
    private String currentId;
    private StringBuilder header;
    private StringBuilder footer;
    public final HashMap<String, Set<String>> entry2ssam = new HashMap<String, Set<String>>();
    public final HashMap<String, Set<String>> sa2elem = new HashMap<String, Set<String>>();
    public final HashMap<String, String> sense2entry = new HashMap<String, String>();
    public final HashMap<String, String> semarg2sempred = new HashMap<String, String>();
    public final HashMap<String, File> tmpFiles = new HashMap<String, File>();
    private FileOutputStream fos;
    private final String outFile;
    private int depth = 0;
    private boolean retainFile = false;
    private int lastLength = 0;
    private int processed = 0;

    public Uby2LemonHandler(String outFile) {
        this.outFile = outFile;
    }

    @Override
    public InputSource resolveEntity(String publicId, String systemId) throws IOException, SAXException {
        //System.err.println(publicId + "//" + systemId);
        return new InputSource(new FileInputStream("src/main/resources/ubyDTD_1_0.dtd"));
    }

    @Override
    public void characters(char[] ch, int start, int length) throws SAXException {
        final String str = new String(ch, start, length);
        if (out != null) {
            if (!str.matches("\\s*")) {
                out.print(escapeXML(str));
            }
        } /*else {
            System.err.print(str);
        }*/
    }

    private static String escapeXML(String in) {

        StringBuilder out = new StringBuilder();
        for (int i = 0; i < in.length(); i++) {
            char c = in.charAt(i);
            if (c < 31 || c > 126 || "<>\"'\\&".indexOf(c) >= 0) {
                out.append("&#").append((int) c).append(";");
            } else {
                out.append(c);
            }
        }
        return out.toString();
    }

    public void printStartElem(Appendable out, String qName, Attributes attributes) throws IOException {
        for (int i = 0; i < depth; i++) {
            out.append("  ");
        }
        out.append("<").append(qName);
        for (int i = 0; i < attributes.getLength(); i++) {
            out.append(" ").append(attributes.getQName(i)).append("=\"").append(escapeXML(attributes.getValue(i))).append("\"");
        }
        out.append(">\n");
    }

    public void printEndElem(Appendable out, String qName) throws IOException {
        for (int i = 0; i < depth; i++) {
            out.append("  ");
        }
        out.append("</").append(qName).append(">\n");
    }

    public static boolean isLexiconElem(String qName) {
        return qName.equals("LexicalEntry")
                || qName.equals("SubcategorizationFrame")
                || qName.equals("SubcategorizationFrameSet")
                || qName.equals("SemanticPredicate")
                || qName.equals("Synset")
                || qName.equals("SynSemCorrespondence")
                || qName.equals("ConstraintSet*");
    }

    @Override
    public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException {
        try {
            if (qName.equals("LexicalResource") || qName.equals("Lexicon")) {
                if (qName.equals("LexicalResource")) {
                    header.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
                }
                printStartElem(header, qName, attributes);
                for (int i = 0; i < depth; i++) {
                    footer.insert(0, "  ");
                }
                footer.insert(depth * 2, "</" + qName + ">\n");
            } else if (isLexiconElem(qName)) {
                if (qName.equals("SynSemCorrespondence")) {
                    retainFile = true;
                } else {
                    retainFile = false;
                }
                final String id = attributes.getValue("id");
                if (id == null) {
                    throw new RuntimeException("No id on LexicalEntry!");
                }
                if(id.length() >= 3) {
                    current = File.createTempFile(id, ".lmf");
                } else {
                    current = File.createTempFile(id + "xxx", ".lmf");
                }
                currentId = id;

                if (++processed % 50 == 0) {
                    for (int i = 0; i < lastLength; i++) {
                        System.out.print("\b");
                    }
                    System.out.print(id);
                    lastLength = id.length();
                }
                tmpFiles.put(id, current);
                out = new PrintWriter(current);
                out.print(header);
                printStartElem(out, qName, attributes);
            } else if (out != null) {
                if (qName.equals("SynSemArgMap")) {
                    final String predId = semarg2sempred.get(attributes.getValue("semanticArgument"));
                    if (predId != null) {
                        if (!entry2ssam.containsKey(predId)) {
                            entry2ssam.put(predId, new TreeSet<String>());
                        }
                        entry2ssam.get(predId).add(currentId);
                    }
                } else if (qName.equals("Sense")) {
                    sense2entry.put(attributes.getValue("id"), currentId);
                } else if (qName.equals("SemanticArgument")) {
                    semarg2sempred.put(attributes.getValue("id"), currentId);
                }
                printStartElem(out, qName, attributes);
            } else if (qName.equals("SenseAxis")) {
                final String id = attributes.getValue("id");
                final String synsetOne = attributes.getValue("synsetOne");
                final String senseOne = attributes.getValue("senseOne");
                if (synsetOne != null) {
                    if (!sa2elem.containsKey(synsetOne)) {
                        sa2elem.put(synsetOne, new TreeSet<String>());
                    }
                    sa2elem.get(synsetOne).add(id);
                }
                if (senseOne != null) {
                    final String entryId = sense2entry.get(senseOne);
                    if (!sa2elem.containsKey(entryId)) {
                        sa2elem.put(entryId, new TreeSet<String>());
                    }
                    sa2elem.get(entryId).add(id);
                }
                retainFile = true;
                if(id.length() >= 3) {
                    current = File.createTempFile(id, ".lmf");
                } else {
                    current = File.createTempFile(id + "xxx", ".lmf");
                }
                currentId = id;
                tmpFiles.put(id, current);
                out = new PrintWriter(current);
                printStartElem(out, qName, attributes);
            } else {
                printStartElem(System.err, qName, attributes);
            }
        } catch (IOException x) {
            throw new RuntimeException(x);
        } finally {
            depth++;
        }
    }

    @Override
    public void endElement(String uri, String localName, String qName) throws SAXException {
        try {
            if (qName.equals("Lexicon") || qName.equals("LexicalResource")) {
                // Do Nothing
            } else if (isLexiconElem(qName)) {
                printEndElem(out, qName);
                out.print(footer);
                out.flush();
                out.close();
                out = null;
                if (!retainFile) {
                    writeToArchive();
                    current.delete();
                } else {
                    current.deleteOnExit();
                }
                current = null;

            } else if (qName.equals("SenseAxis")) {
                printEndElem(out, qName);
                out.flush();
                out.close();
                out = null;
                current.deleteOnExit();
                current = null;
            } else if (out != null) {
                printEndElem(out, qName);
            }
        } catch (IOException x) {
            throw new RuntimeException(x);
        } finally {
            depth--;
        }
    }

    @Override
    public void startDocument() throws SAXException {
        header = new StringBuilder();
        footer = new StringBuilder();
        try {
            fos = new FileOutputStream(outFile);
        } catch (IOException x) {
            throw new RuntimeException(x);
        }
    }

    @Override
    public void endDocument() throws SAXException {
        try {
            fos.close();
            System.out.println();
        } catch (IOException x) {
            x.printStackTrace();
        }
    }

    private void writeToArchive() throws IOException {
        fos.write(("<!--" + currentId + ".xml-->\n").getBytes());
        final byte[] buf = new byte[1024];
        int read;
        final FileInputStream fis = new FileInputStream(current);
        while ((read = fis.read(buf)) >= 0) {
            fos.write(buf, 0, read);
        }
        fis.close();
    }
}
