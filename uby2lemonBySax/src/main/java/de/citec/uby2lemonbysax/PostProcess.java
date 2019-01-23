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
import java.io.PrintWriter;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;
import java.util.HashSet;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Remove duplicate Lexicon tags
 * 
 * @author John McCrae
 */
public class PostProcess {

    public static void process(Scanner in, PrintWriter out) {
        final HashSet<String> seenLexiconIds = new HashSet<String>();
        String lexiconId = "";
        int lineNo = 0;
        final Pattern lexiconPattern = Pattern.compile(".*<lemon:Lexicon.*rdf:ID=\"([^\"]+)\".*");
        while (in.hasNextLine()) {
            final String line = in.nextLine();
            lineNo++;
            if(line.startsWith("<?xml") && lineNo != 1) {
            	continue;
            }
            if (line.contains("</lemon:Lexicon>")) {
                final String line2 = in.nextLine();
                final Matcher m = lexiconPattern.matcher(line2);
                if (m.matches()) {
                    if (m.group(1).equals(lexiconId)) {
                        while (in.hasNextLine()) {
                            final String line3 = in.nextLine();
                            if (line3.contains("lemon:entry")) {
                                out.println(line3);
                                break;
                            } else if(line3.contains("</lemon:Lexicon>")) {
                                out.println(line3);
                                break;
                            }
                        }
                    } else {
                    	if(!line.startsWith("<?xml") || lineNo == 1) {
                    		out.println(line);
                    	}
                    	if(!line2.startsWith("<?xml") || lineNo == 1) {
                    		out.println(line2);
                    	}
                        lexiconId = m.group(1);
                    }
                } else {
                	if(!line.startsWith("<?xml") || lineNo == 1) {
                    	out.println(line);
                    }
                    if(!line2.startsWith("<?xml") || lineNo == 1) {
                    	out.println(line2);
                    }
                }
            } else {
                final Matcher m = lexiconPattern.matcher(line);
                if (m.matches()) {
                    lexiconId = m.group(1);
                    if(seenLexiconIds.contains(lexiconId)) {
                        while(in.hasNextLine()) {
                            final String line2 = in.nextLine();
                            if(line2.contains("lemon:entry")) {
                                out.println(line2);
                                break;
                            } else if(line2.contains("</lemon:Lexicon>")) {
                                break;
                            }
                        }
                    } else {
                        if(!line.startsWith("<?xml") || lineNo == 1) {
                        	out.println(line);
                        }
                        seenLexiconIds.add(lexiconId);
                    }
                } else {
                    if(!line.startsWith("<?xml") || lineNo == 1) {
                    	out.println(substituteSymbols(line));
                    }
                }
            }
        }
        out.flush();
        out.close();
    }
 
    private static final String user = determineUser();
    private static final String dateTime = currentDateTime();

    private static String determineUser() {
        if(System.getProperty("user.name").equals("jmccrae") || System.getProperty("user.name").equals("johmcc")) {
            return "http://john.mccr.ae/";
        } else {
            System.err.println("I don't know your FOAF page, " + System.getProperty("user.name") + " perhaps you can add it to PostProcess.java?");
            return "";
        }
    }

    private static String currentDateTime() {
        TimeZone tz = TimeZone.getTimeZone("UTC");
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'");
        df.setTimeZone(tz);
        return df.format(new Date());
    }

    private static String substituteSymbols(String s) {
        return s.replaceAll("####EXPORTER####", user).replaceAll("####DATETIME####", dateTime);
    }
    
    public static void main(String[] args) throws Exception {
        PostProcess.process(new Scanner(new File(args[0])), new PrintWriter(args[1]));
    }
}
