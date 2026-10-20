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
  version="3.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:spec="http://expath.org/ns/xmlspec"
  xmlns:fos="http://www.w3.org/xpath-functions/spec/namespace" 
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">

  <xsl:output method="xhtml" html-version="5" media-type="text/html" include-content-type="no" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>
  
  <xsl:param name="spec-directory" as="xs:string"></xsl:param>


  <xsl:variable name="spec-collections" as="xs:string*"
    select="uri-collection('file://' || $spec-directory || '?recurse=yes;select=*.xhtml')" />


  <!-- get the unique spec names eg: archive, binary, crypto, facet, file, http, http-client, http-client-2, http-model, mongo, pkg, webapp, zip -->
  <xsl:variable name="spec-modules" as="xs:string*"
    select="sort(distinct-values($spec-collections ! substring-before(substring-after(., '/specs/'), '/')))"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="nav/ul">
    <xsl:for-each select="$spec-modules">
      <xsl:variable name="spec-doc" select="document('file://' || $spec-directory || '/' || current() || '/' || current() || '.xhtml')"/>

      <li><a href="#{.}"><xsl:value-of select="$spec-doc//xhtml:title"/></a></li>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="main">
    <h2>Specifications</h2>
    <xsl:for-each select="$spec-modules">
      <xsl:variable name="spec-doc" select="document('file://' || $spec-directory || '/' || current() || '/' || current() || '.xhtml')"/>
      <article id="{.}">
        <div class="spec-main">
          <!-- we need to pull the main module file -->
          <h3><a href="specs/{.}/{.}.xhtml"><xsl:value-of select="$spec-doc//xhtml:title"/></a></h3>
          <blockquote>
            <!-- get the abstract from the  main module file-->
            <xsl:value-of select="$spec-doc//xhtml:section[@id='abstract']/xhtml:p"/>
          </blockquote>
        </div>
        <div class="spec-meta">
          <!-- Get all the versions of the doc -->
          <xsl:variable name="current-spec" select="current()"/>
          <xsl:variable name="spec-versions" as="xs:string*">
            <xsl:perform-sort select="distinct-values($spec-collections ! substring-before(substring-after(., '/' || $current-spec || '/'), '/'))[. ne '']">
              <!-- Folder names can be dates or labels such as 1.0. -->
              <xsl:sort select="document('file://' || $spec-directory || '/' || $current-spec || '/' || . || '/' || $current-spec || '.xhtml')/xhtml:html/xhtml:head/xhtml:meta[@name='date']/@content" order="descending"/>
            </xsl:perform-sort>
          </xsl:variable>
          
          <!-- Use the newest version, or the main document when no versions exist. -->
          <p class="latest"><a href="specs/{string-join(($current-spec, $spec-versions[1], $current-spec || '.xhtml'), '/')}"><b>Latest version</b></a></p>
          <!-- get the editor's draft version of the spec and put it in the link-->
          <!--  this is an issue for me -->
          <p class="draft"><a href="specs/{.}/{.}.xhtml">Editor's draft</a></p>

          <ul>
            <xsl:for-each select="$spec-versions">
              <xsl:if test="string-length(.) gt 0">
                <xsl:variable name="candidate-doc" select="document('file://' || $spec-directory || '/' || $current-spec || '/' || . || '/' || $current-spec || '.xhtml')"/>
                <li><a href="specs/{$current-spec}/{.}/{$current-spec}.xhtml">Candidate Module</a> — <xsl:value-of select="$candidate-doc//xhtml:head/xhtml:meta[@name='date']/@content"/></li>
              </xsl:if>
            </xsl:for-each>
          </ul>
          
        </div>
      </article>
      <hr/>
    </xsl:for-each>

   
  </xsl:template>

</xsl:stylesheet>
