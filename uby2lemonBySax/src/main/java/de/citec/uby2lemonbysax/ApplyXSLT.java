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

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Scanner;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

/**
 *
 * @author John McCrae
 */
public class ApplyXSLT {

    private final StringBuilder builder = new StringBuilder();
    private int lastLength = 0;
    private int processed = 0;
    private final Transformer transformer;
    
    public ApplyXSLT() throws TransformerException {
        TransformerFactory tFactory = TransformerFactory.newInstance();


        this.transformer =
                tFactory.newTransformer(new StreamSource("src/main/resources/ubylmf2lemon.xsl"));

        transformer.setParameter(OutputKeys.INDENT, "yes");
        transformer.setParameter(OutputKeys.OMIT_XML_DECLARATION, "yes");
        transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");
    }

    public void process(Scanner scanner, File zip) throws IOException, TransformerException {
        final PrintWriter out = new PrintWriter(zip);
        out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        out.println("<rdf:RDF xmlns:dcr=\"http://www.isocat.org/ns/dcr.rdf#\" xmlns:uby=\"http://purl.org/olia/ubyCat.owl#\" xmlns:owl=\"http://www.w3.org/2002/07/owl#\" xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\" xmlns:lemon=\"http://www.monnet-project.eu/lemon#\" xmlns:skos=\"http://www.w3.org/2004/02/skos/core#\" xmlns:prov=\"http://www.w3.org/ns/prov#\" xmlns:dct=\"http://purl.org/dc/terms/\" >");
        String id;
        while (scanner.hasNextLine()) {
            final String line = scanner.nextLine();
            if (line.startsWith("<!--") && line.contains(".xml-->")) {
                if (builder.length() > 0) {
                    final String rdf = applyXSLT(builder.toString());
                    writeRDF(rdf, out);
                }
                id = line.substring(4, line.indexOf(".xml-->"));
                if (++processed % 50 == 0) {
                    for (int i = 0; i < lastLength; i++) {
                        System.out.print("\b");
                    }
                    System.out.print(id);
                    lastLength = id.length();
                }
                builder.setLength(0);
            } else {
                builder.append(line).append("\n");
            }
        }
        out.println("</rdf:RDF>");
        out.flush();
        out.close();
        System.out.println();
    }

    private String applyXSLT(String xml) throws TransformerException {
        final StringWriter out = new StringWriter();
        transformer.transform(new StreamSource(new ByteArrayInputStream(xml.getBytes())),
                new StreamResult(out));
        return out.toString();
    }

    private void writeRDF(String rdf, PrintWriter out) {
        final Scanner rdfScan = new Scanner(rdf);
        while (rdfScan.hasNextLine()) {
            final String line = rdfScan.nextLine();
            if (!line.contains("rdf:RDF")) {
                out.println(line);
            }
        }
    }
}
