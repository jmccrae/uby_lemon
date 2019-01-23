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
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Scanner;
import java.util.Set;

/**
 *
 * @author John McCrae
 */
public class MergeData {

    private final HashMap<String, Set<String>> entry2ssam;
    private final HashMap<String, Set<String>> sa2elem;
    private final HashMap<String, File> tmpFiles;
    private int lastLength = 0;
    private int processed = 0;

    public MergeData(Uby2LemonHandler handler) {
        this.entry2ssam = handler.entry2ssam;
        this.sa2elem = handler.sa2elem;
        this.tmpFiles = handler.tmpFiles;
    }

    public void process(Scanner scanner, PrintWriter out) throws IOException {
        String id = null;
        while (scanner.hasNextLine()) {
            final String line = scanner.nextLine();
            if (line.startsWith("<!--") && line.contains(".xml-->")) {
                id = line.substring(4, line.indexOf(".xml-->"));
                if (++processed % 50 == 0) {
                    for (int i = 0; i < lastLength; i++) {
                        System.out.print("\b");
                    }
                    System.out.print(id);
                    lastLength = id.length();
                }
            } else if (line.contains("</Lexicon>")) {
                if (entry2ssam.containsKey(id)) {
                    for (String ssam : entry2ssam.get(id)) {
                        final Scanner in = new Scanner(tmpFiles.get(ssam));
                        copyIn(in, out);
                        in.close();
                    }
                }
            } else if (line.contains("</LexicalResource>")) {
                if (sa2elem.containsKey(id)) {
                    for (String sa : sa2elem.get(id)) {
                        final Scanner in = new Scanner(tmpFiles.get(sa));
                        copyIn(in, out);
                        in.close();
                    }
                }
            }
            out.println(line);
        }
        System.out.println();
        out.flush();
        out.close();
    }

    private void copyIn(final Scanner in, PrintWriter out) {
        while (in.hasNextLine()) {
            final String line = in.nextLine();
            if (!line.startsWith("<?xml") && !line.startsWith("<LexicalResource")
                    && !line.startsWith("  <Lexicon") && !line.startsWith("  </Lexicon")
                    && !line.startsWith("</LexicalResource")) {
                out.println(line);
            }
        }
    }
}
