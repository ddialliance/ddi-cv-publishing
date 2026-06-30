<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"></xsl:output>

	<xsl:param name="name"/>
	<xsl:param name="version"/>

	<xsl:variable name="base">
		<xsl:text>http://rdf-vocabulary.ddialliance.org/cv/</xsl:text>
		<xsl:value-of select="$name"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="$version"/>
		<xsl:text>/</xsl:text>
	</xsl:variable>

    <xsl:template match="rdf:RDF">
    	<rdf:RDF>
    		<xsl:apply-templates select="rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme']" mode="CV"/>
    		<xsl:apply-templates select="rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#Concept']" mode="Entry"/>
    	</rdf:RDF>
    </xsl:template>
    
    <xsl:template match="rdf:Description" mode="CV">
    	<rdf:Description>
			<xsl:attribute name="rdf:about"><xsl:value-of select="$base"/></xsl:attribute>
    		<xsl:copy-of select="dcterms:identifier"/>
    		<xsl:copy-of select="rdf:type"/>
			<dcterms:isVersionOf>
				<xsl:attribute name="rdf:resource">
					<xsl:text>http://rdf-vocabulary.ddialliance.org/cv/</xsl:text>
					<xsl:value-of select="$name"/>
					<xsl:text>/</xsl:text>
				</xsl:attribute>
			</dcterms:isVersionOf>
    		<xsl:copy-of select="owl:priorVersion"/>
    		<xsl:copy-of select="skos:notation"/>
    		<xsl:copy-of select="skos:prefLabel[not(text()='')]|skos:definition[not(text()='')]|dcterms:title[not(text()='')]|dcterms:description[not(text()='')]"/>
    		<xsl:copy-of select="owl:versionInfo"/>
    		<xsl:copy-of select="dcterms:license"/>
    		<xsl:copy-of select="dcterms:rights"/>
    		<xsl:copy-of select="dcterms:created"/>
    		<xsl:copy-of select="dcterms:issued"/>
    		<xsl:copy-of select="skos:historyNote"/>
    	    <xsl:copy-of select="skos:changeNote"/>
			<xsl:for-each select="skos:hasTopConcept">
				<xsl:variable name="idplus" select="substring-after(@rdf:resource, concat($name, '/'))"/>
				<xsl:variable name="id" select="substring-after($idplus, '/')"/>
				<skos:hasTopConcept>
					<xsl:attribute name="rdf:resource"><xsl:value-of select="$base"/><xsl:value-of select="$id"/></xsl:attribute>
				</skos:hasTopConcept>
			</xsl:for-each>
    	</rdf:Description>
    </xsl:template>
    
    <xsl:template match="rdf:Description" mode="Entry">
		<xsl:variable name="idplus" select="substring-after(@rdf:about, concat($name, '/'))"/>
		<xsl:variable name="id" select="substring-after($idplus, '/')"/>
		<rdf:Description>
			<xsl:attribute name="rdf:about"><xsl:value-of select="$base"/><xsl:value-of select="$id"/></xsl:attribute>
    	    <xsl:copy-of select="rdf:type"/>
			<xsl:for-each select="skos:inScheme">
				<skos:inScheme>
					<xsl:attribute name="rdf:resource"><xsl:value-of select="$base"/></xsl:attribute>
				</skos:inScheme>
			</xsl:for-each>
    		<xsl:copy-of select="dcterms:created"/>
    		<xsl:copy-of select="skos:changeNote"/>
    		<xsl:copy-of select="skos:notation"/>
			<xsl:copy-of select="skos:prefLabel[not(text()='')]|skos:definition[not(text()='')]|dcterms:title[not(text()='')]|dcterms:description[not(text()='')]"/>
			<xsl:for-each select="skos:narrower">
				<xsl:variable name="ridplus" select="substring-after(@rdf:resource, concat($name, '/'))"/>
				<xsl:variable name="rid" select="substring-after($ridplus, '/')"/>
				<skos:narrower>
					<xsl:attribute name="rdf:resource"><xsl:value-of select="$base"/><xsl:value-of select="$rid"/></xsl:attribute>
				</skos:narrower>
			</xsl:for-each>
   		    <xsl:variable name="myConceptId" select="@rdf:about"/>
    		<xsl:for-each select="//rdf:Description[skos:narrower/@rdf:resource=$myConceptId]">
				<xsl:variable name="ridplus" select="substring-after(@rdf:about, concat($name, '/'))"/>
				<xsl:variable name="rid" select="substring-after($ridplus, '/')"/>
	    		<skos:broader>
					<xsl:attribute name="rdf:resource"><xsl:value-of select="$base"/><xsl:value-of select="$rid"/></xsl:attribute>
	    		</skos:broader>
    		</xsl:for-each>
    	</rdf:Description>
    </xsl:template>
</xsl:stylesheet>