<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns:uby="http://purl.org/olia/ubyPos.owl#">

  <xsl:strip-space elements="*" />
  <xsl:output method="xml" indent="yes" />

  <xsl:template match="/">
    <rdf:RDF>
      <xsl:apply-templates match="//SenseAxis"/>
    </rdf:RDF>
  </xsl:template>
  
  <xsl:template match="SenseAxis">
  	<xsl:if test="@senseOne and @senseTwo">
  	  <rdf:Description>
  	    <xsl:attribute name="rdf:about">
  	      <xsl:value-of select="@senseOne"/>
  	    </xsl:attribute>
  	    <xsl:element name="{concat('uby:',@senseAxisType)}">
  	      <rdf:Description>
  	        <xsl:attribute name="rdf:about">
  	      	  <xsl:value-of select="@senseTwo"/>
  	        </xsl:attribute>
  	      </rdf:Description>
  	    </xsl:element>
     </rdf:Description>
   </xsl:if>
   <xsl:if test="@synsetOne and @synsetTwo">
  	  <rdf:Description>
  	    <xsl:attribute name="rdf:about">
  	      <xsl:value-of select="@synsetOne"/>
  	    </xsl:attribute>
  	    <xsl:element name="{concat('uby:',@senseAxisType)}">
  	      <rdf:Description>
  	        <xsl:attribute name="rdf:about">
  	      	  <xsl:value-of select="@synsetTwo"/>
  	        </xsl:attribute>
  	      </rdf:Description>
  	    </xsl:element>
     </rdf:Description>
   </xsl:if>
  </xsl:template>
</xsl:stylesheet>
