<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"></xsl:output>
    
    <xsl:template match="rdf:RDF">
    	<rdf:RDF>
    		<xsl:apply-templates select="rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme']" mode="CV"/>
    		<xsl:apply-templates select="rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#Concept']" mode="Entry"/>
    	</rdf:RDF>
    </xsl:template>
    
    <xsl:template match="rdf:Description" mode="CV">
    	<rdf:Description>
    		<xsl:copy-of select="@rdf:about"/>
    		<xsl:copy-of select="dcterms:identifier"/>
    		<xsl:copy-of select="rdf:type"/>
    		<xsl:copy-of select="dcterms:identifier"/>
    		<xsl:copy-of select="dcterms:isVersionOf"/>
    		<xsl:copy-of select="owl:priorVersion"/>
    		<xsl:copy-of select="skos:notation"/>
    		<xsl:copy-of select="skos:prefLabel[not(text()='')]|skos:definition[not(text()='')]"/>
    		<xsl:for-each select="dcterms:title">
    			<skos:prefLabel>
    				<xsl:copy-of select="@xml:lang"/>
    				<xsl:value-of select="text()"/>
    			</skos:prefLabel>
    		</xsl:for-each>
    		<xsl:for-each select="dcterms:description">
    			<skos:definition>
    				<xsl:copy-of select="@xml:lang"/>
    				<xsl:value-of select="text()"/>
    			</skos:definition>
    		</xsl:for-each>
    		<xsl:copy-of select="owl:versionInfo"/>
    		<xsl:copy-of select="dcterms:license"/>
    		<xsl:copy-of select="dcterms:rights"/>
    		<xsl:copy-of select="dcterms:created"/>
    		<xsl:copy-of select="dcterms:issued"/>
    		<xsl:copy-of select="skos:historyNote"/>
    	    <xsl:copy-of select="skos:changeNote"/>
    	    <xsl:copy-of select="skos:hasTopConcept"/>
    	</rdf:Description>
    </xsl:template>
    
    <xsl:template match="rdf:Description" mode="Entry">
		<xsl:variable name="code" select="skos:notation"/>
    	<rdf:Description>
    	    <xsl:copy-of select="@rdf:about"/>
    	    <xsl:copy-of select="rdf:type"/>
    	    <xsl:copy-of select="dcterms:isVersionOf"/>
    		<xsl:copy-of select="owl:priorVersion"/>
    		<xsl:copy-of select="owl:priorVersion"/>
    		<xsl:copy-of select="skos:inScheme"/>
    		<xsl:copy-of select="skos:topConceptOf"/>
    		<xsl:copy-of select="dcterms:created"/>
    		<xsl:copy-of select="skos:changeNote"/>
    		<xsl:copy-of select="skos:notation"/>
    		<xsl:copy-of select="skos:prefLabel[not(text()='')]|skos:definition[not(text()='')]"/>
    	    <xsl:copy-of select="skos:narrower"/>
   		 <xsl:variable name="myConceptId" select="@rdf:about"/>
    		<xsl:for-each select="//rdf:Description[skos:narrower/@rdf:resource=$myConceptId]">
	    		<skos:broader>
		    		<xsl:attribute name="rdf:resource">
		    			<xsl:value-of select="@rdf:about"/>
		    		</xsl:attribute>
	    		</skos:broader>
    		</xsl:for-each>
    	</rdf:Description>
    </xsl:template>
</xsl:stylesheet>