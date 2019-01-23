/*********************************************************************************
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
import java.io.PrintWriter;
import java.util.Scanner;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

/**
 *
 * @author John McCrae
 */
public class Main {

    public static void main(String[] args) throws Exception {
        if(args.length != 2) {
            System.err.println("Need two arguments");
            return;
        }
        final String outPrefix = args[1].endsWith(".rdf") ? args[1].substring(0,args[1].length()-4) : args[1];
        final File splitFile = new File(outPrefix+"-split.xml");
        final Uby2LemonHandler handler = new Uby2LemonHandler(splitFile.getPath());
        final SAXParserFactory parserFactory = SAXParserFactory.newInstance();
        System.out.println("SAX parse");
        final SAXParser saxParser = parserFactory.newSAXParser();
        saxParser.parse(new File(args[0]), handler);
        final MergeData mergeData = new MergeData(handler);
        final File mergeFile = new File(outPrefix+"-merge.xml");
        System.out.println("Merge");
        mergeData.process(new Scanner(splitFile), new PrintWriter(mergeFile));
        final ApplyXSLT applyXSLT = new ApplyXSLT();
        final File tmpRDFFile = new File(outPrefix+".temp.rdf");
        System.out.println("Apply XSLT");
        applyXSLT.process(new Scanner(mergeFile), tmpRDFFile);
        System.out.println("Post-process");
        final File rdfFile = new File(outPrefix+".rdf");
        PostProcess.process(new Scanner(tmpRDFFile), new PrintWriter(rdfFile));
        splitFile.delete();
        mergeFile.delete();
        tmpRDFFile.delete();
    }
}
