<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:ddi-cv="urn:ddi-cv"
    xmlns:ddi="ddi:instance:3_2" 
    xmlns:l="ddi:logicalproduct:3_2" 
    xmlns:r="ddi:reusable:3_2" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xsi:schemaLocation="ddi:instance:3_2 http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/instance.xsd"
    exclude-result-prefixes="xs rdf rdfs skos owl gc dcterms xsi"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"></xsl:output>
    
    <xsl:variable name="agency">int.ddi.cv</xsl:variable>
    <xsl:variable name="cvID" select="//rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme']/skos:notation"/>
    <xsl:variable name="cvVersion" select="//rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme']/owl:versionInfo"/>
    
    <xsl:template match="rdf:RDF">
        <ddi:FragmentInstance>
            <ddi:Fragment>
                <l:CodeList>
                    <r:Agency><xsl:value-of select="$agency"/></r:Agency>
                    <r:ID><xsl:value-of select="$cvID"/></r:ID>
                    <r:Version><xsl:value-of select="$cvVersion"/></r:Version>
                    <r:UserID typeOfUserID="URI"><xsl:value-of select="//rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme']/@rdf:about"/></r:UserID>
                    <r:Label>
                        <xsl:for-each select="//rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme']/dcterms:title">
                            <r:Content>
                                <xsl:attribute name="xml:lang">
                                    <xsl:value-of select="@xml:lang"/>
                                </xsl:attribute>
                                <xsl:value-of select="."/>
                            </r:Content>
                        </xsl:for-each>
                    </r:Label>
                    <r:Description>
                        <xsl:for-each select="//rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme']/dcterms:description">
                            <r:Content>
                                <xsl:attribute name="xml:lang">
                                    <xsl:value-of select="@xml:lang"/>
                                </xsl:attribute>
                                <xsl:value-of select="."/>
                            </r:Content>
                        </xsl:for-each>
                    </r:Description>
                    <xsl:apply-templates select="rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme']/skos:hasTopConcept" mode="Code"/>
                </l:CodeList>
            </ddi:Fragment>
            <xsl:apply-templates select="rdf:Description[not(rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme')]" mode="Category"/>
        </ddi:FragmentInstance>
    </xsl:template>
    
    <xsl:template match="skos:hasTopConcept" mode="Code">
        <xsl:variable name="descriptionID" select="@rdf:resource"/>
        <xsl:apply-templates select="//rdf:Description[@rdf:about=$descriptionID]" mode="Code"/>
    </xsl:template>
    
    <xsl:template match="rdf:Description" mode="Code">
        <l:Code>
            <r:Agency><xsl:value-of select="$agency"/></r:Agency>
            <r:ID>
                <xsl:value-of select="$cvID"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="substring-after(substring-after(substring-after(@rdf:about, $cvID),'/'),'/')"/>
                <xsl:text>-Code</xsl:text>
            </r:ID>
            <r:Version><xsl:value-of select="$cvVersion"/></r:Version>
            <r:UserID typeOfUserID="URI"><xsl:value-of select="@rdf:about"/></r:UserID>
            <r:CategoryReference>
                <r:Agency><xsl:value-of select="$agency"/></r:Agency>
                <r:ID>
                    <xsl:value-of select="$cvID"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="substring-after(substring-after(substring-after(@rdf:about, $cvID),'/'),'/')"/>
                    <xsl:text>-Category</xsl:text>
                </r:ID>
                <r:Version><xsl:value-of select="$cvVersion"/></r:Version>
                <r:TypeOfObject>Category</r:TypeOfObject>
            </r:CategoryReference>
            <r:Value>
                <xsl:value-of select="skos:notation"/>
            </r:Value>
        </l:Code>
        <xsl:for-each select="skos:narrower">
            <xsl:variable name="descriptionID" select="@rdf:resource"/>
            <xsl:apply-templates select="//rdf:Description[@rdf:about=$descriptionID]" mode="Code"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="rdf:Description" mode="Category">
        <ddi:Fragment>
           <l:Category>
               <r:Agency><xsl:value-of select="$agency"/></r:Agency>
               <r:ID>
                   <xsl:value-of select="$cvID"/>
                   <xsl:text>-</xsl:text>
                   <xsl:value-of select="substring-after(substring-after(substring-after(@rdf:about, $cvID),'/'),'/')"/>
                   <xsl:text>-Category</xsl:text>
               </r:ID>
               <r:Version><xsl:value-of select="$cvVersion"/></r:Version>
               <r:UserID typeOfUserID="URI"><xsl:value-of select="@rdf:about"/></r:UserID>
               <l:CategoryName>
                   <xsl:value-of select="skos:notation"/>
               </l:CategoryName>
               <r:Label>
                   <xsl:for-each select="skos:prefLabel">
                       <r:Content>
                           <xsl:attribute name="xml:lang">
                               <xsl:value-of select="@xml:lang"/>
                           </xsl:attribute>
                           <xsl:value-of select="."/>
                       </r:Content>
                   </xsl:for-each>
               </r:Label>
               <r:Description>
                   <xsl:for-each select="skos:definition">
                       <r:Content>
                           <xsl:attribute name="xml:lang">
                               <xsl:value-of select="@xml:lang"/>
                           </xsl:attribute>
                           <xsl:value-of select="."/>
                       </r:Content>
                   </xsl:for-each>
               </r:Description>
           </l:Category>
        </ddi:Fragment>
    </xsl:template>
    
</xsl:stylesheet>