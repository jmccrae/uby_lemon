<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : lmf2lemon.xsl
    Created on : 09 August 2012, 16:40
    Author     : John McCrae
    Description: Uby-LMF to Lemon Transforms

    Please replace the #### values with their correct values, e.g.,
    ####EXPORTER#### = FOAF profile of exporter
    ####DATETIME#### = Current date-time
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:lemon="http://www.monnet-project.eu/lemon#"
                xmlns:uby="http://purl.org/olia/ubyCat.owl#"
                xmlns:dcr="http://www.isocat.org/ns/dcr.rdf#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:prov="http://www.w3.org/ns/prov#"
                xmlns:dct="http://purl.org/dc/terms/"
                version="1.0">                                                          
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <rdf:RDF>
            <xsl:apply-templates select="LexicalResource"/>
        </rdf:RDF>
    </xsl:template>
    
    <xsl:template match="LexicalResource">
        <xsl:apply-templates select="GlobalInformation"/>
        <xsl:apply-templates select="Lexicon"/>
        <!--<xsl:apply-templates select="SenseAxis"/>-->
    </xsl:template>
    
    <xsl:template match="GlobalInformation">
        <rdf:Description rdf:about="#GlobalInformation">
            <xsl:if test="@label">
                <rdfs:label>
                    <xsl:if test="FormRepresentation/@xml:lang">
                        <xsl:attribute name="xml:lang">
                            <xsl:value-of select="FormRepresentation/@xml:lang"/>
                        </xsl:attribute>
                    </xsl:if>    
                    <xsl:value-of select="@label"/>
                </rdfs:label>
            </xsl:if>
        </rdf:Description>
    </xsl:template>
    
    <xsl:template match="Lexicon">
        <lemon:Lexicon>
            <xsl:if test="@id">
                <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@languageIdentifier">
                <lemon:language>
                    <xsl:value-of select="@languageIdentifier"/>
                </lemon:language>
            </xsl:if>
            <xsl:if test="@name">
                <rdfs:label>
                    <xsl:value-of select="@name"/>
                </rdfs:label>
            </xsl:if>
            <xsl:apply-templates select="LexicalEntry"/>
            <prov:wasGeneratedBy>
                <prov:Activity>
                    <xsl:attribute name="rdf:about">
                        <xsl:value-of select="concat(@id,'#Provenance')"/>
                    </xsl:attribute>
                    <prov:wasAssociatedWith rdf:resource="####EXPORTER####"/>
                    <prov:atTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">####DATETIME####</prov:atTime>
                </prov:Activity>
            </prov:wasGeneratedBy>
            <dct:version>0.2</dct:version>
        </lemon:Lexicon>
        <xsl:apply-templates select="SubcategorizationFrame"/>
        <xsl:apply-templates select="Synset"/>
        <!--<xsl:apply-templates select="SynSemCorrespondence"/>-->
        <xsl:apply-templates select="ConstraintSet"/>
        <xsl:apply-templates select="SemanticPredicate"/>
    </xsl:template>
    
    <xsl:template match="LexicalEntry">
        <lemon:entry>
            <lemon:LexicalEntry>
                <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:if test="@partOfSpeech">
                    <uby:partOfSpeech>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@partOfSpeech)"/>
                        </xsl:attribute>
                    </uby:partOfSpeech>
                </xsl:if>
                <xsl:if test="@separableParticle">
                    <uby:separableParticle>
                        <xsl:value-of select="@separableParticle"/>
                    </uby:separableParticle>
                </xsl:if>
                <xsl:apply-templates select="Lemma"/>
                <xsl:for-each select="WordForm[position() > 1]">
                  <lemon:otherForm>
                     <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                       <xsl:value-of select="concat(../@id,'#Form',position())"/>
                     </xsl:attribute>
                     <lemon:Form>
                        <xsl:call-template name="wordForm"/>
                     </lemon:Form>
                  </lemon:otherForm>
                </xsl:for-each>
                <xsl:apply-templates select="RelatedForm"/>
                <xsl:apply-templates select="Sense"/>
                <xsl:apply-templates select="SyntacticBehaviour"/>
                <xsl:apply-templates select="ListOfComponents"/>
                <xsl:apply-templates select="Frequency"/>
            </lemon:LexicalEntry>
        </lemon:entry>
    </xsl:template>
    
    <xsl:template match="Sense">
        <lemon:sense>
            <lemon:LexicalSense>
                <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:if test="@index">
                    <uby:index>
                        <xsl:value-of select="@index"/>
                    </uby:index>
                </xsl:if>
                <xsl:if test="@synset">
                    <lemon:reference>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="@synset"/>
                        </xsl:attribute>
                    </lemon:reference>
                </xsl:if>
                <xsl:if test="@incorporatedSemArg">
                    <uby:incorporatedSemArg>
                        <xsl:value-of select="@incorporatedSemArg"/>
                    </uby:incorporatedSemArg>
                </xsl:if>
                <xsl:if test="@transparentMeaning">
                    <uby:transparentMeaning>
                        <xsl:value-of select="@transparentMeaning"/>
                    </uby:transparentMeaning>
                </xsl:if>
                <xsl:for-each select="Sense">
                    <lemon:narrower>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="@id"/>
                        </xsl:attribute>
                    </lemon:narrower>
                </xsl:for-each>
                <xsl:variable name="senseId" select="@id"/>
                <xsl:apply-templates select="Context"/>
                <xsl:apply-templates select="PredicativeRepresentation"/>
                <xsl:apply-templates select="SenseExample"/>
                <xsl:apply-templates select="Definition"/>
                <xsl:apply-templates select="SenseRelation"/>
                <xsl:apply-templates select="MonolingualExternalRef"/>
                <xsl:apply-templates select="Frequency"/>
                <xsl:apply-templates select="SemanticLabel"/>
                <xsl:apply-templates select="Equivalent"/>
                <xsl:for-each select="//SenseAxis[@senseOne=$senseId]">
                    <xsl:call-template name="senseAxis1"/>
                </xsl:for-each>
                <xsl:for-each select="//SenseAxis[@senseTwo=$senseId]">
                    <xsl:call-template name="senseAxis2"/>
                </xsl:for-each>
            </lemon:LexicalSense>
        </lemon:sense>
        <xsl:apply-templates select="Sense"/>
    </xsl:template>
    
    <xsl:template match="Definition">
        <xsl:if test="Statement">
            <xsl:for-each select="Statement">
                <lemon:definition>
                    <lemon:SenseDefinition>
                    <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                      <xsl:value-of select="concat(../../@id,'#Statement',position())"/>
                    </xsl:attribute>
                        <xsl:if test="../@definitionType">
                            <uby:definitionType>
                                <xsl:value-of select="../@definitionType"/>
                            </uby:definitionType>
                        </xsl:if>         
                        <xsl:if test="@statementType">
                            <uby:statementType>
                                <xsl:value-of select="@statementType"/>
                            </uby:statementType>
                        </xsl:if>
                        <xsl:apply-templates select="../TextRepresentation"/>
                        <xsl:apply-templates select="TextRepresentation"/>
                    </lemon:SenseDefinition>
                </lemon:definition>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="not(Statement)">
            <lemon:definition>
                <lemon:SenseDefinition>
                    <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                      <xsl:value-of select="concat(../@id,'#Definition',position())"/>
                    </xsl:attribute>
                    <xsl:if test="@definitionType">
                        <uby:definitionType>
                            <xsl:value-of select="@definitionType"/>
                        </uby:definitionType>
                    </xsl:if>
                    <xsl:apply-templates select="TextRepresentation"/>
                </lemon:SenseDefinition>
            </lemon:definition>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="TextRepresentation">
        <lemon:value>
            <xsl:if test="@languageIdentifier">
                <xsl:attribute name="xml:lang">
                    <xsl:choose>
                        <xsl:when test="@geographicalVariant='English_United_Kingdom'">en-GB</xsl:when>
                        <xsl:when test="@geographicalVariant='English_United_States'">en-US</xsl:when>
                        <xsl:otherwise><xsl:value-of select="@languageIdentifier"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@xml:lang">
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="@xml:lang"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="@writtenText"/>
        </lemon:value>
    </xsl:template>
    
    
    <xsl:template match="Lemma">
        <lemon:canonicalForm>
            <lemon:Form>
                <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                  <xsl:value-of select="concat(../@id,'#CanonicalForm')"/>
                </xsl:attribute>
                <xsl:apply-templates select="FormRepresentation"/>
                <xsl:for-each select="../WordForm[1]">
                	<xsl:call-template name="wordForm"/>
                </xsl:for-each>
            </lemon:Form>
        </lemon:canonicalForm>
    </xsl:template>
    
    <xsl:template name="wordForm">
        <xsl:if test="@grammaticalNumber">
            <uby:grammaticalNumber>
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@grammaticalNumber)"/>
                </xsl:attribute>
            </uby:grammaticalNumber>
        </xsl:if>
        <xsl:if test="@grammaticalGender">
            <uby:grammaticalGender>
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@grammaticalGender)"/>
                </xsl:attribute>
            </uby:grammaticalGender>
        </xsl:if>
        <xsl:if test="@case">
            <uby:case>
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@case)"/>
                </xsl:attribute>
            </uby:case>
        </xsl:if>
        <xsl:if test="@person">
            <uby:person>
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@person)"/>
                </xsl:attribute>
            </uby:person>
        </xsl:if>
        <xsl:if test="@tense">
            <uby:tense>
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@tense)"/>
                </xsl:attribute>
            </uby:tense>
        </xsl:if>
        <xsl:if test="@verbFormMood">
            <uby:verbFormMood>
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@verbFormMood)"/>
                </xsl:attribute>
            </uby:verbFormMood>
        </xsl:if>
        <xsl:if test="@degree">
            <uby:degree>
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@degree)"/>
                </xsl:attribute>
            </uby:degree>
        </xsl:if>
        <xsl:apply-templates select="FormRepresentation"/>
        <xsl:apply-templates select="Frequency"/>
    </xsl:template>
    
    
    <xsl:template match="FormRepresentation">
        <lemon:writtenRep>
            <xsl:if test="@languageIdentifier">
                <xsl:attribute name="xml:lang">
                    <xsl:choose>
                        <xsl:when test="@geographicalVariant='English_United_Kingdom'">en-GB</xsl:when>
                        <xsl:when test="@geographicalVariant='English_United_States'">en-US</xsl:when>
                        <xsl:otherwise><xsl:value-of select="@languageIdentifier"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@xml:lang">
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="@xml:lang"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="@writtenForm"/>
        </lemon:writtenRep>
        <xsl:if test="@phoneticForm">
            <uby:phoneticForm>
                <xsl:value-of select="@phoneticForm"/>
            </uby:phoneticForm>
        </xsl:if>
        <xsl:if test="@sound">
            <uby:sound>
                <xsl:value-of select="@sound"/>
            </uby:sound>
        </xsl:if>
        <xsl:if test="@hyphenation">
            <uby:hyphenation>
                <xsl:value-of select="@hyphenation"/>
            </uby:hyphenation>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="RelatedForm">
        <xsl:if test="@relType">
            <xsl:element name="{concat('uby:',@relType)}">
                <xsl:choose>
                    <xsl:when test="@targetLexicalEntry">
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="@targetLexicalEntry"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="FormRepresentation">
                        <lemon:Form>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of select="concat(../@id,'#RelatedForm',position())"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="FormRepresentation"/>
                        </lemon:Form>
                    </xsl:when>
                </xsl:choose>
            </xsl:element>
            <xsl:if test="@targetSense">
                <xsl:comment>Linked to sense 
                    <xsl:value-of select="@targetSense"/>
                </xsl:comment>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="ListOfComponents">
        <lemon:decomposition rdf:parseType="Collection">
            <xsl:for-each select="Component">
                <lemon:Component>
                <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                  <xsl:value-of select="concat(../../@id,'#Component',position())"/>
                </xsl:attribute>
                    <lemon:element>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="@targetLexicalEntry"/>
                        </xsl:attribute>
                    </lemon:element>
                    <xsl:if test="@isHead">
                        <uby:isHead>
                            <xsl:value-of select="@isHead"/>
                        </uby:isHead>
                    </xsl:if>
                    <xsl:if test="@position">
                        <uby:position>
                            <xsl:value-of select="@position"/>
                        </uby:position>
                    </xsl:if>
                    <xsl:if test="@isBreakBefore">
                        <uby:isBreakBefore>
                            <xsl:value-of select="@isBreakBefore"/>
                        </uby:isBreakBefore>
                    </xsl:if>
                </lemon:Component>
            </xsl:for-each>
        </lemon:decomposition>
    </xsl:template>
    
    <xsl:template match="Context">
        <lemon:context>
            <lemon:LexicalContext>
                <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                  <xsl:value-of select="concat(../@id,'#Context',position())"/>
                </xsl:attribute>
                <xsl:if test="@source">
                    <uby:source>
                        <xsl:value-of select="@source"/>
                    </uby:source>
                </xsl:if>
                <xsl:if test="@contextType">
                    <uby:contextType>
                        <xsl:value-of select="@contextType"/>
                    </uby:contextType>
                </xsl:if>
                <xsl:apply-templates select="TextRepresentation"/>
                <xsl:apply-templates select="MonolingualExternalRef"/>
            </lemon:LexicalContext>
        </lemon:context>
    </xsl:template>
    
    <xsl:template match="SyntacticBehaviour">
        <xsl:choose>
            <xsl:when test="@subcategorizationFrame">
                <lemon:synBehavior>
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="@subcategorizationFrame"/>
                    </xsl:attribute>
                </lemon:synBehavior>
            </xsl:when>
            <xsl:when test="@subcategorizationFrameSet">
                <xsl:variable name="sfs" select="@subcategorizationFrameSet"/>
                <xsl:apply-templates select="//SubcategorizationFrameSet[@id=$sfs]"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="@sense">
            <xsl:comment>Different senses do not have different subcategorizations in lemon.</xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="SubcategorizationFrame">
        <lemon:Frame>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <xsl:if test="@parentSubcatFrame">
                <uby:parentSubcatFrame>
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="@parentSubcatFrame"/>
                    </xsl:attribute>
                </uby:parentSubcatFrame>
            </xsl:if>
            <xsl:if test="@subcatLabel">
                <rdfs:label>
                    <xsl:value-of select="@subcatLabel"/>
                </rdfs:label>
            </xsl:if>
            <xsl:apply-templates select="LexemeProperty"/>
            <xsl:apply-templates select="SyntacticArgument"/>
            <xsl:apply-templates select="Frequency"/>
        </lemon:Frame>
    </xsl:template>
    
    <xsl:template match="LexemeProperty">
        <xsl:if test="@auxiliary">
            <uby:auxiliary>
                <xsl:value-of select="@parentSubcatFrame"/>
            </uby:auxiliary>
        </xsl:if>
        <xsl:if test="@syntacticProperty">
            <uby:syntacticProperty>
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@syntacticProperty)"/>
                </xsl:attribute>
            </uby:syntacticProperty>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="SyntacticArgument">
    	<xsl:choose>
    		<xsl:when test="@grammaticalFunction">
    			<xsl:element name="{concat('uby:',@grammaticalFunction)}">
    				<xsl:call-template name="synArg"/>
    			</xsl:element>
            </xsl:when>
            <xsl:otherwise>
            	<lemon:synArg>
            		<xsl:call-template name="synArg"/>
            	</lemon:synArg>
            </xsl:otherwise>
       </xsl:choose>
   </xsl:template>
            
   <xsl:template name="synArg">
            <lemon:Argument>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:if test="@optional">
                    <lemon:optional>
                        <xsl:value-of select="@optional"/>
                    </lemon:optional>
                </xsl:if>
                <xsl:if test="@syntacticCategory">
                    <uby:syntacticCategory>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@syntacticCategory)"/>
                        </xsl:attribute>
                    </uby:syntacticCategory>
                </xsl:if>
                <xsl:if test="@case">
                    <uby:case>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@case)"/>
                        </xsl:attribute>
                    </uby:case>
                </xsl:if>
                <xsl:if test="@determiner">
                    <uby:determiner>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@determiner)"/>
                        </xsl:attribute>
                    </uby:determiner>
                </xsl:if>
                <xsl:if test="@number">
                    <uby:grammaticalNumber>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@number)"/>
                        </xsl:attribute>
                    </uby:grammaticalNumber>
                </xsl:if>
                <xsl:if test="@verbForm">
                    <uby:verbForm>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@verbForm)"/>
                        </xsl:attribute>
                    </uby:verbForm>
                </xsl:if>
                <xsl:if test="@tense">
                    <uby:tense>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@tense)"/>
                        </xsl:attribute>
                    </uby:tense>
                </xsl:if>
                <xsl:if test="@complementizer">
                    <uby:complementizer>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@complementizer)"/>
                        </xsl:attribute>
                    </uby:complementizer>
                </xsl:if>
                <xsl:if test="@preposition">
                    <uby:preposition>
                        <xsl:value-of select="@preposition"/>
                    </uby:preposition>
                </xsl:if>
                <xsl:if test="@prepositionType">
                    <uby:prepositionType>
                        <xsl:value-of select="@prepositionType"/>
                    </uby:prepositionType>
                </xsl:if>
                <xsl:if test="@lexeme">
                    <uby:lexeme>
                        <xsl:value-of select="@lexeme"/>
                    </uby:lexeme>
                </xsl:if>
            </lemon:Argument>
    </xsl:template>
    
    <xsl:template match="SubcategorizationFrameSet">
        <xsl:for-each select="SubcatFrameSetElement">
            <lemon:synBehavior>
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of select="@element"/>
                </xsl:attribute> 
            </lemon:synBehavior>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- synargmap -->
        
    <xsl:template match="PredicativeRepresentation">
        <lemon:broader>
            <xsl:attribute name="rdf:resource">
                <xsl:value-of select="@predicate"/>
            </xsl:attribute>
        </lemon:broader>
    </xsl:template>
            
    <xsl:template match="SemanticPredicate">
        <lemon:LexicalSense>
            <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <xsl:if test="@label">
                <uby:label>
                    <xsl:value-of select="@label"/>
                </uby:label>
            </xsl:if>
            <xsl:if test="@lexicalized">
                <uby:lexicalized>
                    <xsl:value-of select="@lexicalized"/>
                </uby:lexicalized>
            </xsl:if>
            <xsl:if test="@perspectivalized">
                <uby:perspectivalized>
                    <xsl:value-of select="@perspectivalized"/>
                </uby:perspectivalized>
            </xsl:if>
            <xsl:apply-templates select="Definition"/>
            <xsl:apply-templates select="SemanticArgument"/>
            <xsl:apply-templates select="PredicateRelation"/>
            <xsl:apply-templates select="Frequency"/>
            <xsl:apply-templates select="SemanticLabel"/>
        </lemon:LexicalSense>
    </xsl:template>
    
    <xsl:template match="SemanticArgument">
        <lemon:semArg>
            <lemon:Argument>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:if test="@semanticRole">
                    <uby:semanticRole>
                        <xsl:value-of select="@semanticRole"/>
                    </uby:semanticRole>
                </xsl:if>
                <xsl:if test="@isIncorporated">
                    <uby:isIncorporated>
                        <xsl:value-of select="@semanticRole"/>
                    </uby:isIncorporated>
                </xsl:if>
                <xsl:if test="@coreType">
                    <uby:coreType>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@coreType)"/>
                        </xsl:attribute>
                    </uby:coreType>
                </xsl:if>
                <xsl:variable name="argId" select="@id"/>
                <xsl:apply-templates select="//SynSemArgMap[@semanticArgument=$argId]"/>
                <xsl:apply-templates select="ArgumentRelation"/>
                <xsl:apply-templates select="Frequency"/>
                <xsl:apply-templates select="SemanticLabel"/>
                <xsl:apply-templates select="Definition"/>
            </lemon:Argument>
        </lemon:semArg>
    </xsl:template>
    
    <xsl:template match="ArgumentRelation">
        <xsl:comment>Argument relations not supported in lemon.</xsl:comment>
    </xsl:template>
    
    <!--<xsl:template match="SynSemCorrespondence">
        <xsl:for-each select="SynSemArgMap">
            <rdf:Description>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="@syntacticArgument"/>
                </xsl:attribute>
                <owl:sameAs>
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="concat('#',@semanticArgument)"/>
                    </xsl:attribute>
                </owl:sameAs>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>-->
    <xsl:template match="SynSemArgMap">
        <owl:sameAs>
            <xsl:attribute name="rdf:resource">
                <xsl:value-of select="@syntacticArgument"/>
            </xsl:attribute>
        </owl:sameAs>
    </xsl:template>
    
    <xsl:template match="PredicateRelation">
        <xsl:comment>Predicate Relation's are not mapped as no URI for the relation could be defined.</xsl:comment>
    </xsl:template>
    
    <xsl:template match="SenseExample">
        <lemon:example>
            <lemon:UsageExample>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:if test="@exampleType">
                    <uby:exampleType>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="concat('http://purl.org/olia/ubyCat.owl#',@exampleType)"/>
                        </xsl:attribute>
                    </uby:exampleType>
                </xsl:if>
                <xsl:apply-templates select="TextRepresentation"/>
            </lemon:UsageExample>
        </lemon:example>
    </xsl:template>
    
    <xsl:template match="Synset">
        <skos:Concept>
            <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <!--<xsl:apply-templates select="Definition"/>-->
            <xsl:for-each select="Definition">
            	<xsl:for-each select="TextRepresentation">
            		<rdfs:comment>
            		<xsl:if test="@languageIdentifier">
            			<xsl:attribute name="xml:lang">
                                    <xsl:choose>
                                        <xsl:when test="@geographicalVariant='English_United_Kingdom'">en-GB</xsl:when>
                                        <xsl:when test="@geographicalVariant='English_United_States'">en-US</xsl:when>
                                        <xsl:otherwise><xsl:value-of select="@languageIdentifier"/></xsl:otherwise>
                                    </xsl:choose>
            			</xsl:attribute>
            		</xsl:if>
            		<xsl:if test="@xml:lang">
            			<xsl:attribute name="xml:lang">
            				<xsl:value-of select="@xml:lang"/>
            			</xsl:attribute>
            		</xsl:if>
            	  <xsl:value-of select="@writtenText"/>
            		</rdfs:comment>
            	</xsl:for-each>
            </xsl:for-each>
            <xsl:apply-templates select="SynsetRelation"/>
            <xsl:apply-templates select="MonolingualExternalRef"/>
            <xsl:variable name="synsetId" select="@id"/>
            <xsl:for-each select="//SenseAxis[@synsetOne=$synsetId]">
                <xsl:call-template name="senseAxis1"/>
            </xsl:for-each>
            <xsl:for-each select="//SenseAxis[@synsetTwo=$synsetId]">
                <xsl:call-template name="senseAxis2"/>
            </xsl:for-each>
        </skos:Concept>
    </xsl:template>
    
    <xsl:template match="SynSetRelation">
        <xsl:choose>
        	<xsl:when test="@relType='hypernym'">
        		<skos:broader>
        			<xsl:attribute name="rdf:resource">
                        <xsl:value-of select="@target"/>
                    </xsl:attribute>
                </skos:broader>
            </xsl:when>
        	<xsl:when test="@relType='seeAlso'">
        		<rdfs:seeAlso>
        			<xsl:attribute name="rdf:resource">
                        <xsl:value-of select="@target"/>
                    </xsl:attribute>
                </rdfs:seeAlso>
            </xsl:when>
            <xsl:when test="@relType">
                <xsl:element name="{concat('uby:',@relType)}">
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="@target"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <lemon:senseRelation>
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="@target"/>
                    </xsl:attribute>
                </lemon:senseRelation>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="MonolingualExternalRef">
        <uby:monolingualExternalRef>
            <uby:MonolingualExternalRef>
                <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                  <xsl:choose>
                    <xsl:when test="../@id">
                      <xsl:value-of select="concat(../@id,'#MonolingualExternalRef',position())"/>
                    </xsl:when>
                    <xsl:when test="../../@id">
                      <xsl:value-of select="concat(../../@id,'#MonolingualExternalRef',position())"/>
                    </xsl:when>
                  </xsl:choose>
                </xsl:attribute>
                <uby:externalSystem>
                    <xsl:value-of select="@externalSystem"/>
                </uby:externalSystem>
                <uby:externalReference>
                    <xsl:value-of select="@externalReference"/>
                </uby:externalReference>
            </uby:MonolingualExternalRef>
        </uby:monolingualExternalRef>
    </xsl:template>
    
    <xsl:template match="SenseRelation">
        <xsl:choose>
            <xsl:when test="@relType">
                <xsl:element name="{concat('uby:',@relType)}">
                    <xsl:choose>
                        <xsl:when test="@target">
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of select="@target"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="FormRepresentation">
                            <lemon:LexicalSense>
                                <lemon:isSenseOf>
                                    <lemon:LexicalEntry>
                                        <lemon:canonicalForm>
                                            <lemon:Form>
                                                <lemon:writtenRep>
                                                    <xsl:if test="FormRepresentation/@languageIdentifier">
                                                        <xsl:attribute name="xml:lang">
                                                            <xsl:if test="FormRepresentation/@languageIdentifier">
                                                                <xsl:value-of select="FormRepresentation/@languageIdentifier"/>
                                                            </xsl:if>
                                                        </xsl:attribute>
                                                    </xsl:if>
                                                    <xsl:if test="@xml:lang">
                                                        <xsl:attribute name="xml:lang">
                                                            <xsl:value-of select="@xml:lang"/>
                                                        </xsl:attribute>
                                                    </xsl:if>
                                                    <xsl:value-of select="FormRepresentation/@writtenForm"/>
                                                </lemon:writtenRep>
                                            </lemon:Form>
                                        </lemon:canonicalForm>
                                    </lemon:LexicalEntry>
                                </lemon:isSenseOf>
                            </lemon:LexicalSense>
                        </xsl:when>
                        <xsl:when test="@source">
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of select="@source"/>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <lemon:senseRelation>
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="@target"/>
                    </xsl:attribute>
                </lemon:senseRelation>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="senseAxis1">
        <xsl:choose>
            <xsl:when test="@senseAxisType">
                <xsl:element name="{concat('uby:',@senseAxisType)}">
                    <xsl:attribute name="rdf:resource">
                        <xsl:choose>
                            <xsl:when test="@senseTwo">
                                <xsl:value-of select="@senseTwo"/>
                            </xsl:when>
                            <xsl:when test="@synsetTwo">
                                <xsl:value-of select="@synsetTwo"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <lemon:senseRelation>
                    <xsl:attribute name="rdf:resource">
                        <xsl:choose>
                            <xsl:when test="@senseTwo">
                                <xsl:value-of select="@senseTwo"/>
                            </xsl:when>
                            <xsl:when test="@synsetTwo">
                                <xsl:value-of select="@synsetTwo"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </lemon:senseRelation>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="senseAxis2">
        <xsl:choose>
            <xsl:when test="@senseAxisType">
                <xsl:element name="{concat('uby:',@senseAxisType)}">
                    <xsl:attribute name="rdf:resource">
                        <xsl:choose>
                            <xsl:when test="@senseOne">
                                <xsl:value-of select="@senseTwo"/>
                            </xsl:when>
                            <xsl:when test="@synsetOne">
                                <xsl:value-of select="@synsetTwo"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <lemon:senseRelation>
                    <xsl:attribute name="rdf:resource">
                        <xsl:choose>
                            <xsl:when test="@senseOne">
                                <xsl:value-of select="@senseTwo"/>
                            </xsl:when>
                            <xsl:when test="@synsetOne">
                                <xsl:value-of select="@synsetTwo"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </lemon:senseRelation>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="SenseAxisRelation">
        <xsl:comment>Sense Axis Relations are not supported by lemon.</xsl:comment>
    </xsl:template>
    
    <xsl:template match="ConstraintSet">
        <!-- Yep, nothing to do here -->
    </xsl:template>
    
    <xsl:template match="Frequency">
        <uby:frequency>
            <uby:Frequency>
                <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                  <xsl:choose>
                    <xsl:when test="../@id">
                      <xsl:value-of select="concat(../@id,'#Frequency',position())"/>
                    </xsl:when>
                    <xsl:when test="../../@id">
                      <xsl:value-of select="concat(../../@id,'#Frequency',position())"/>
                    </xsl:when>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:if test="@corpus">
                    <uby:corpus>
                        <xsl:value-of select="@corpus"/>
                    </uby:corpus>
                </xsl:if>
                <xsl:if test="@frequency">
                    <uby:frequencyValue>
                        <xsl:value-of select="@frequency"/>
                    </uby:frequencyValue>
                </xsl:if>
                <xsl:if test="@generator">
                    <uby:generator>
                        <xsl:value-of select="@generator"/>
                    </uby:generator>
                </xsl:if>
            </uby:Frequency>
        </uby:frequency>
    </xsl:template>
    
    <xsl:template match="SemanticLabel">
        <uby:semanticLabel>
            <uby:SemanticLabel>
                <xsl:attribute name="rdf:about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                  <xsl:choose>
                    <xsl:when test="../@id">
                      <xsl:value-of select="concat(../@id,'#SemanticLabel',position())"/>
                    </xsl:when>
                    <xsl:when test="../../@id">
                      <xsl:value-of select="concat(../../@id,'#SemanticLabel',position())"/>
                    </xsl:when>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:if test="@label">
                    <uby:label>
                        <xsl:value-of select="@label"/>
                    </uby:label>
                </xsl:if>
                <xsl:if test="@type">
                    <uby:type>
                        <xsl:value-of select="@type"/>
                    </uby:type>
                </xsl:if>
                <xsl:if test="@quantification">
                    <uby:quantification>
                        <xsl:value-of select="@quantification"/>
                    </uby:quantification>
                </xsl:if>
                <xsl:apply-templates select="MonolingualExternalRef"/>
            </uby:SemanticLabel>
        </uby:semanticLabel>
    </xsl:template>

    <!--<xsl:template match="Equivalent">
    	<xsl:variable name="senseId" select="../@id"/>
    	<xsl:variable name="eqLoc" select="position()"/>
        <lemon:equivalent>
            <lemon:LexicalSense>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="concat($senseId,'_AnonEntrySense_',$eqLoc)"/>
                </xsl:attribute>
                <xsl:if test="@usage">
                    <uby:usage>
                        <xsl:value-of select="@usage"/>
                    </uby:usage>
                </xsl:if>
                <xsl:if test="@writtenForm or @transliteration">
                    <lemon:isSenseOf>
                        <lemon:LexicalEntry>
                            <xsl:attribute name="rdf:about">
                              <xsl:value-of select="concat($senseId,'_AnonEntry_',$eqLoc)"/>
                            </xsl:attribute>
                            <lemon:canonicalForm>
                                <lemon:Form>
                                   <xsl:attribute name="rdf:about">
                                     <xsl:value-of select="concat($senseId,'_AnonEntryForm_',$eqLoc)"/>
                                   </xsl:attribute>
                                   <xsl:if test="@writtenForm">
                                   <lemon:writtenRep>
                                      <xsl:if test="@languageIdentifier">
                                         <xsl:attribute name="xml:lang">
                                            <xsl:value-of select="@languageIdentifier"/>
                                         </xsl:attribute>
                                       </xsl:if>
                                       <xsl:value-of select="@writtenForm"/>
                                    </lemon:writtenRep>
                                    </xsl:if>
                                    <xsl:if test="@transliteration">                                    
                                    <uby:transliteration>
                                      <xsl:if test="@languageIdentifier">
                                        <xsl:attribute name="xml:lang">
                                          <xsl:value-of select="@languageIdentifier"/>
                                        </xsl:attribute>
                                      </xsl:if>
                                      <xsl:value-of select="@transliteration"/>
                                    </uby:transliteration>
                                    </xsl:if>
                                  </lemon:Form>
                              </lemon:canonicalForm>
                          </lemon:LexicalEntry>
                    </lemon:isSenseOf>
                </xsl:if>
            </lemon:LexicalSense>
        </lemon:equivalent>
    </xsl:template>-->
    <xsl:template match="Equivalent">
        <xsl:if test="@writtenForm">
            <uby:equivalent>
                <xsl:if test="@languageIdentifier">
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="@languageIdentifier"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="@writtenForm"/>
            </uby:equivalent>
        </xsl:if>
        <xsl:if test="@transliteration">
            <uby:equivalent>
                <xsl:if test="@transliteration">
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="concat(@languageIdentifier,'-Latn')"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="@transliteration"/>
            </uby:equivalent>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
