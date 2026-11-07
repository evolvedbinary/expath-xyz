<?xml version="1.0" encoding="UTF-8"?>
<!--

    Copyright © 2026 EXPath Community Group (public-expath@w3.org)

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fos="http://www.w3.org/xpath-functions/spec/namespace" 
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:f="http://function.expath.xyz"
  exclude-result-prefixes="#all">

  <xsl:output method="xhtml" html-version="5" media-type="text/html" include-content-type="no" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>
  
  <xsl:param name="spec-directory" as="xs:string"></xsl:param>


  <xsl:variable name="spec-docs" as="document-node(element(xhtml:html))*"
    select="collection('file://' || $spec-directory || '?recurse=yes;stable=yes;select=*.xhtml')" />

  <xsl:template match="xhtml:nav[@id eq 'specification-index']">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <xhtml:ul>
        <xsl:for-each-group select="$spec-docs"  group-by="//xhtml:meta[@name eq 'spec-family']/@content">
          <xsl:sort select="current-grouping-key()"/>
          <xsl:variable name="spec-family" select="current-group()"/>
          <xhtml:li><xhtml:a href="#{current-grouping-key()}"><xsl:value-of select="$spec-family[1]//xhtml:title"/></xhtml:a></xhtml:li>
        </xsl:for-each-group>
      </xhtml:ul>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="xhtml:main">
    <xsl:copy>
      <xhtml:h2>Specifications</xhtml:h2>
      <xsl:for-each-group select="$spec-docs"  group-by="//xhtml:meta[@name eq 'spec-family']/@content">
       <xsl:sort select="current-grouping-key()"/>
       <xsl:variable name="spec-family" select="current-group()"/>
        <xsl:variable name="latest-version" select="f:latest-spec($spec-family)"/>
        <xhtml:article id="{current-grouping-key()}">
        <xhtml:div class="spec-main">
          <xsl:choose>
            <xsl:when test="exists($latest-version)">
              <xhtml:h3><xhtml:a href="{f:format-spec-path($latest-version)}"><xsl:value-of select="$latest-version//xhtml:title"/></xhtml:a></xhtml:h3>
              <xhtml:blockquote>
                <!-- get the abstract from the  main module file-->
                <xsl:sequence select="f:abstract($latest-version)"/>
              </xhtml:blockquote>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="latest-draft" select="f:latest-editors-draft($spec-family)"/>
              <xhtml:h3><xhtml:a href="{f:format-spec-path($latest-draft)}"><xsl:value-of select="$latest-draft//xhtml:title"/></xhtml:a></xhtml:h3>
              <xhtml:blockquote>
                <xsl:sequence select="f:abstract($latest-draft)"/>
              </xhtml:blockquote>
              
            </xsl:otherwise>
          </xsl:choose>
          
        </xhtml:div>
        <xhtml:div class="spec-meta">
          <xsl:choose>
            <xsl:when test="exists($latest-version)">
              <xhtml:p class="latest"><xhtml:a href="{f:format-spec-path($latest-version)}"><xhtml:b>Latest version</xhtml:b></xhtml:a></xhtml:p>
            </xsl:when>
          </xsl:choose>
          <xsl:variable name="latest-draft" select="f:latest-editors-draft($spec-family)"/>
          <xsl:choose>
            <xsl:when test="exists($latest-draft)">
              <xhtml:p class="draft"><xhtml:a href="{f:format-spec-path($latest-draft)}">Editor's draft</xhtml:a></xhtml:p>
            </xsl:when>
          </xsl:choose>
          <xhtml:ul>
            <xsl:for-each select="f:previous-spec-list($spec-family)">
              <xhtml:li><xhtml:a href="{f:format-spec-path(.)}"><xsl:copy-of select="f:doc-status(.)"/></xhtml:a> — <xsl:value-of select="f:parse-pubdate(.)"/></xhtml:li>
            </xsl:for-each>
          </xhtml:ul>
        </xhtml:div>
      </xhtml:article>
      <xhtml:hr/>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>


  <!--
    Get the latest Editors Draft.
    
    @param specs - the specs to consider for the list.
    
    @return the latest Editor's Draft, or an empty sequence if there are no non-editor's drafts.
  -->
  <xsl:function name="f:latest-editors-draft" as="document-node(element(xhtml:html))?">
    <xsl:param name="specs" as="document-node(element(xhtml:html))+"/>
    <xsl:sequence select="head(f:spec-list($specs, 'wd'))"/>
  </xsl:function>
  
  <!--
    Get the latest spec (that is not an Editors Draft).
    
    @param specs - the specs to consider for the list.
    
    @return the latest spec, or an empty sequence if there are no non-editor's drafts.
  -->
  <xsl:function name="f:latest-spec" as="document-node(element(xhtml:html))?">
    <xsl:param name="specs" as="document-node(element(xhtml:html))+"/>
    <xsl:sequence select="head(f:spec-list($specs, ('cr','pr','rec')))"/>
  </xsl:function>
  
  <!--
    Get a list of all but the latest specs (that are not Editors Drafts) in descending date order.
    
    @param specs - the specs to consider for the list.
    
    @return a list of matching specs.
  -->
  <xsl:function name="f:previous-spec-list"> 
    <xsl:param name="specs" as="document-node(element(xhtml:html))+"/>
    <xsl:sequence select="tail(f:spec-list($specs, ('cr','pr','rec')))"/>
  </xsl:function>
  
  <!--
    Get a list of matching specs in descending date order.
    
    @param specs - the specs to consider for the list.
    @param spec-w3c-doctypes - the w3c-doctypes to consider for the list (e.g. cr, pr, etc...).
    
    @return a list of matching specs.
  -->
  <xsl:function name="f:spec-list">
    <xsl:param name="specs" as="document-node(element(xhtml:html))+"/>
    <xsl:param name="spec-w3c-doctypes" as="xs:string+"/>
    <xsl:variable name="matching-specs" select="$specs[.//xhtml:meta[@name eq 'spec-w3c-doctype']/@content = $spec-w3c-doctypes]"/>
    <xsl:variable name="sorted-matching-specs" select="sort($matching-specs, (),  function($matching-spec) { f:parse-pubdate($matching-spec) })"/>
    <xsl:sequence select="reverse($sorted-matching-specs)"/>
  </xsl:function>

  <!--
    Parses the publictaion date from the ReSpec input.
    
    @param doc - The ReSpec document.
    
    @return an xs:date of the publication date.
  -->
  <xsl:function name="f:parse-pubdate" as="xs:date">
    <xsl:param name="doc" as="document-node(element(xhtml:html))"/>
    <xsl:variable name="script" as="xs:string" select="$doc//xhtml:script[@class eq 'remove'][contains(., 'respecConfig')]"/>
    <xsl:variable name="publish-date" as="xs:date" select="xs:date(analyze-string($script, 'publishDate:\s*&quot;(.+)&quot;')//fn:group[@nr eq '1'])"/>
    <xsl:sequence select="$publish-date"/>
  </xsl:function>
  
  <!--
    Gets the abstract text of a spec, turning any ReSpec citations
    (e.g. [[xpath-30]] or [[!XPATH20]]) into links.

    @param spec - The ReSpec document.

    @return the abstract text, with citations replaced by links.
  -->
  <xsl:function name="f:abstract">
    <xsl:param name="spec" as="document-node(element(xhtml:html))"/>
    <xsl:variable name="spec-path" select="f:format-spec-path($spec)"/>
    <xsl:variable name="abstract" select="$spec//xhtml:section[@id eq 'abstract']/xhtml:p"/>
    <!-- replace the bibref with a link -->
    <xsl:variable name="abstract-with-links">
      <xsl:for-each select="$abstract">
          <!-- Match `[[FOOBAR]]` `[[!FOOBAR]]` or `[=FOOBAR=]` -->
          <xsl:analyze-string select="." regex="\[\[!?([^\]]+)\]\]|\[=([^=]+)=\]">
            <xsl:matching-substring>
              <xsl:choose>
                <xsl:when test="regex-group(1)">
                  <xhtml:a href="{$spec-path}#bib-{regex-group(1)}">
                    <xsl:value-of select="regex-group(1)"/>
                  </xhtml:a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="specid" select="lower-case(replace(regex-group(2), ' ', '-'))"/>
                  <xhtml:a href="{$spec-path}#dfn-{$specid}">
                    <xsl:value-of select="$specid"/>
                  </xhtml:a>   
                </xsl:otherwise>
              </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:copy-of select="."/>
            </xsl:non-matching-substring>   
          </xsl:analyze-string>
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="$abstract-with-links"/>
  </xsl:function>

  <!--
    Gets the relative path of a spec, for use in links.

    @param node - The ReSpec document.

    @return the path of the spec, relative to the site root.
  -->
  <xsl:function name="f:format-spec-path">
    <xsl:param name="node" as="document-node(element(xhtml:html))"></xsl:param>
    <xsl:variable name="document-uri" select="document-uri($node)"/>
    <xsl:variable name="formatted-path" select="substring-after($document-uri, $spec-directory)"/>
    <xsl:sequence select="'specs' || $formatted-path"/>
  </xsl:function>

  <!--
    Get a human readable description of the status of a ReSpec spec.
    Cnomputed from the spec-w3c-doctype metadata.
    
    @param spec - The ReSpec document.
    
    @return The human readable document status.
  -->
  <xsl:function name="f:doc-status" as="text()">
    <xsl:param name="spec" as="document-node(element(xhtml:html))"/>
    <xsl:variable name="doctype" as="xs:string" select="$spec//xhtml:meta[@name eq 'spec-w3c-doctype']/@content"/>
    <xsl:choose>
      <xsl:when test="$doctype eq 'cr'">
        <xsl:text>Candidate Recommendation</xsl:text>
      </xsl:when>
      <xsl:when test="$doctype eq 'pr'">
        <xsl:text>Proposed Recommendation</xsl:text>
      </xsl:when>
      <xsl:when test="$doctype eq 'rec'">
        <xsl:text>Recommendation</xsl:text>
      </xsl:when>
      <xsl:when test="$doctype eq 'wd'">
        <xsl:text>Working Draft</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">Unknown doctype: <xsl:value-of select="$doctype"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
