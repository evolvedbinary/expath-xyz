<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:ex="http://expath.org/ns/xmlspec"
  xmlns:fos="http://www.w3.org/xpath-functions/spec/namespace"
  xmlns:f="http://function.expath.xyz"
  exclude-result-prefixes="#all">

    <xsl:param name="specref-map" as="xs:string" select="'specref-map.xml'"/>
    <xsl:param name="function-catalog" as="xs:string" select="'function-catalog.xml'"/>
    <xsl:param name="original-site" as="xs:string" select="'http://expath.org'"/>
    <xsl:param name="updated-site" as="xs:string" select="'https://www.expath.xyz'"/>

    <xsl:output method="xhtml" html-version="5" media-type="text/html" include-content-type="no" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>



    <!-- NOTE: used in calls to 'f:bibl-id-to-key' to resolve bibl/@key from bibl/@id for non-bibliograpgic references; useful when encountering bibref/@ref -->
    <xsl:variable name="non-ref-bibl-id-key-mappings" as="element(bibl-mapping)*">
      <xsl:for-each select="/spec/back/div1[@id ne 'references']//bibl">
        <xsl:element name="bibl-mapping">
          <xsl:copy-of select="@id|@key"/>
        </xsl:element>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="specref-mappings" as="document-node(element(mappings))" select="doc($specref-map)"/>
    <xsl:variable name="localbibl-entries" as="element(mapping)*" select="$specref-mappings/mappings/mapping[title]"/>
    <xsl:variable name="isFO" select="contains(/spec/header/title, 'Functions and Operators')" as="xs:boolean"/>
    <xsl:variable name="func-catalog-uri" as="xs:anyURI" select="resolve-uri($function-catalog, base-uri())"/>
    <xsl:variable name="fos-functions" as="element(fos:function)*">
      <xsl:if test="doc-available($func-catalog-uri)">
        <xsl:sequence select="doc($func-catalog-uri)/fos:functions/fos:function"/>
      </xsl:if>
    </xsl:variable>
  
  <xsl:template match="processing-instruction(oxygen)"/>

	<xsl:template name="make-property-termref">
		<xsl:choose>
			<xsl:when test="$isFO">
				<!-- Functions and Operators spec -->
				<termref def="dt-{.}"><xsl:value-of select="."/></termref>
			</xsl:when>
			<xsl:otherwise>
				<!-- Typically the XSLT spec -->
				<xtermref spec="FO30" ref="dt-{.}"><xsl:value-of select="."/></xtermref>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
  
  <xsl:template match="@xml:space"/>
  
  <!-- 
  <xsl:template match="loc/@href">
    <xsl:attribute name="href" select="f:replace-url(., $original-site, $updated-site)"/>
  </xsl:template>
  -->
  
  <xsl:template match="spec">
    <xhtml:html lang="en">
      <xhtml:head>
        <xhtml:meta charset="utf-8" />

        <xhtml:meta name="spec-w3c-doctype" content="{@w3c-doctype}"/>
        <xhtml:meta name="spec-family" content="{header/title/@role}"/>
        <xhtml:title><xsl:value-of select="header/title"/></xhtml:title>
          
        
        <xhtml:script src="https://www.w3.org/Tools/respec/respec-w3c" class="remove" defer="defer"></xhtml:script>
        
        <xhtml:script class="remove">
          var respecConfig = {
            specStatus: "<xsl:choose>
              <xsl:when test="@w3c-doctype eq 'rec'">CG-FINAL</xsl:when>
              <xsl:otherwise>CG-DRAFT</xsl:otherwise>
            </xsl:choose>",
            shortName: "expath-<xsl:value-of select="header/title/@role"/>",
            group: "cg/expath",
            wgPublicList: "public-expath",
            
            editors: <xsl:copy-of select="f:authors-to-json(header/authlist/author[@role eq 'editor'])"/>,
            <xsl:if test="header/authlist/author[@role ne 'editor']">
              authors: <xsl:copy-of select="f:authors-to-json(header/authlist/author[@role ne 'editor'])"/>,
            </xsl:if>

            <xsl:if test="header/pubdate">
            publishDate: "<xsl:value-of select="f:parse-xmlspec-pubdate(header/pubdate)" />",
            </xsl:if>

            <xsl:if test="header/latestloc/loc">
            edDraftURI: "<xsl:value-of select="f:replace-url(normalize-space(header/latestloc/loc[1]/@href), $original-site, $updated-site)"/>",
            </xsl:if>

            <xsl:if test="header/prevlocs/loc">
            prevED: "<xsl:value-of select="f:replace-url(normalize-space(header/prevlocs/loc[1]/@href), $original-site, $updated-site)"/>",
            </xsl:if>

            <xsl:if test="header/altlocs/loc">
            alternateFormats: [
              <xsl:for-each select="header/altlocs/loc">
              {
                uri: "<xsl:value-of select="f:replace-url(@href, $original-site, $updated-site)"/>",
                label: "<xsl:value-of select="normalize-space(.)"/>"
              }<xsl:if test="position() ne last()">,</xsl:if>
              </xsl:for-each>
            ],
            </xsl:if>

            xref: "web-platform",
            
            <xsl:variable name="used-bibrefs" as="xs:string*" select="distinct-values(//bibref/@ref)"/>
            <xsl:variable name="used-localbibl-entries" as="element(mapping)*" select="$localbibl-entries[@xmlspec = $used-bibrefs]"/>
            <xsl:if test="exists($used-localbibl-entries)">
            localBiblio: <xsl:sequence select="f:localbibls-to-json($used-localbibl-entries)"/>
            </xsl:if>
          };
        </xhtml:script>

      </xhtml:head>
      <xhtml:body>
        <xsl:apply-templates select="header"/>
        <xsl:apply-templates select="body"/>
        <xhtml:section id="conformance"/>
        <xsl:apply-templates select="back"/>
      </xhtml:body>
    </xhtml:html>
  </xsl:template>
  
  <xsl:template match="header">
    <xsl:apply-templates select="abstract"/>
    <xhtml:section id="sotd">
      <xsl:apply-templates select="node()[not(self::abstract)]|@*"/>
    </xhtml:section>
  </xsl:template>

  <xsl:template match="abstract">
    <xhtml:section id="abstract">
      <xsl:apply-templates select="@*|node()"/>
    </xhtml:section>
  </xsl:template>
  
  <!-- Config from the xmlspec that should be inthe respecConfig object -->
  <xsl:template match="title|w3c-designation|w3c-doctype|pubdate|publoc|altlocs|latestloc|prevlocs|authlist|copyright|status|langusage|revisiondesc|version|subtitle"/>
  
  <xsl:template match="body">
    <xsl:apply-templates mode="body"/>
  </xsl:template>

  <xsl:template match="back">
    <xsl:apply-templates mode="back"/>
  </xsl:template>

  <!-- Ignore the status of this doc as ReSpec will add its own -->
  <xsl:template match="div1[@id eq 'status']" mode="body"/>

  <xsl:template match="div1" mode="body">
    <xhtml:section>
      <xsl:call-template name="div-children"/>
    </xhtml:section>
  </xsl:template>

  <!-- Don't transform the references backmatter section from xmlspec, as ReSpec will build its own -->
  <xsl:template match="div1[@id eq 'references']" mode="back"/>

  <xsl:template match="div1" mode="back">
    <xhtml:section class="appendix">
      <xsl:call-template name="div-children"/>
    </xhtml:section>
  </xsl:template>

  <xsl:template match="div2|div3">
    <xhtml:section>
      <xsl:call-template name="div-children"/>
    </xhtml:section>
  </xsl:template>

  <xsl:template name="div-children">
    <xsl:choose>
      <xsl:when test="@id">
        <xsl:attribute name="id" select="@id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="id" select="generate-id()"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="node()|@*[local-name() ne 'class']"/>
  </xsl:template>

  <xsl:template match="head[processing-instruction('function')]" priority="2">
    <xsl:variable name="lexname" select="normalize-space(processing-instruction('function'))"/>
		<xsl:variable name="fspec" select="fos:get-function($fos-functions, $lexname)"/>

    <!-- TODO replace h3 with a conditional or get it to use the other template		-->
    <xhtml:h3>
			<xsl:value-of select="$lexname"/>
		</xhtml:h3>
		<xhtml:dl>
			<xhtml:div>
        <xhtml:dt>Summary</xhtml:dt>
        <xhtml:dd>
          <xsl:apply-templates select="$fspec/fos:summary/node()"/>
        </xhtml:dd>
      </xhtml:div>
			<xsl:if test="$fspec/fos:opermap">
				<xhtml:div>
					<xhtml:dt>Operator Mapping</xhtml:dt>
					<xhtml:dd>
						<xhtml:p>
							<xsl:copy-of select="$fspec/fos:opermap/node()" copy-namespaces="no"/>
						</xhtml:p>
					</xhtml:dd>
				</xhtml:div>
			</xsl:if>
			<xhtml:div>
        <xhtml:dt>Signature<xsl:value-of select="'s'[$fspec/fos:signatures/fos:proto[2]]" /></xhtml:dt>
        <xhtml:dd>
          <xsl:apply-templates select="$fspec/fos:signatures/fos:proto"/>
        </xhtml:dd>
      </xhtml:div>
			<xsl:if test="$fspec/fos:properties">
				<xhtml:div>
					<xhtml:dt>Properties</xhtml:dt>
					<xhtml:dd>
						<xsl:for-each select="$fspec/fos:properties">
							<xhtml:p>
								<xsl:choose>
									<xsl:when test="last() eq 1">
										<xsl:text>This function is </xsl:text>
									</xsl:when>
									<xsl:otherwise> <xsl:text>The </xsl:text>
										<xsl:number value="@arity" format="w"/>
										<xsl:text>-argument form of this function is </xsl:text>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:for-each select="fos:property">
									<xsl:call-template name="make-property-termref"/>
									
									
									<xsl:if test="position() ne last()">, </xsl:if>
									<xsl:if test="position() eq last() - 1"> and </xsl:if>
								</xsl:for-each>
								<xsl:text>. </xsl:text>
								<xsl:apply-templates select="fos:property/@dependency"/>
							</xhtml:p>
						</xsl:for-each>
					</xhtml:dd>
				</xhtml:div>
			</xsl:if>
			<xhtml:div>
        <xhtml:dt>Rules</xhtml:dt>
        <xhtml:dd>
          <xsl:apply-templates select="$fspec/fos:rules/node()"/>
        </xhtml:dd>
      </xhtml:div>
      <xsl:if test="$fspec/fos:errors">
        <xhtml:div>
          <xhtml:dt>Error Conditions</xhtml:dt>
          <xhtml:dd>
            <xsl:apply-templates select="$fspec/fos:errors/node()"/>
          </xhtml:dd>
        </xhtml:div>
      </xsl:if>
      <xsl:if test="$fspec/fos:notes">
        <xhtml:div>
          <xhtml:dt>Notes</xhtml:dt>
          <xhtml:dd>
            <xsl:apply-templates select="$fspec/fos:notes/node()"/>
          </xhtml:dd>
        </xhtml:div>
      </xsl:if>
			<xsl:if test="$fspec/fos:examples">
				<xhtml:div>
					<xhtml:dt>Examples</xhtml:dt>
					<xhtml:dd>
						<xsl:apply-templates select="$fspec/fos:examples/node()"/>
					</xhtml:dd>
				</xhtml:div>
			</xsl:if>
		</xhtml:dl>
	</xsl:template>

  <xsl:template match="head[parent::div1]">
    <xhtml:h2>
      <xsl:apply-templates select="node()"/>
    </xhtml:h2>
  </xsl:template>
  
  <xsl:template match="head[parent::div2]">
    <xhtml:h3>
      <xsl:apply-templates select="node()"/>
    </xhtml:h3>
  </xsl:template>

  <xsl:template match="head[parent::div3]">
    <xhtml:h4>
      <xsl:apply-templates select="node()"/>
    </xhtml:h4>
  </xsl:template>

  <xsl:template match="loc|xtermref">
    <xhtml:a href="{@href}">
      <xsl:apply-templates select="text()"/>
    </xhtml:a>
  </xsl:template>

  <xsl:template match="ex:type">
    <xhtml:code>
      <xsl:apply-templates select="text()"/>
    </xhtml:code>
  </xsl:template>

  <xsl:template match="ex:function">
    <xhtml:code class="function">
      <xsl:apply-templates select="node()"/>
    </xhtml:code>
  </xsl:template>

  <xsl:template match="eg">
    <xhtml:aside class="example">
      <xhtml:pre>
        <xsl:apply-templates select="@*|node()"/>
      </xhtml:pre>
    </xhtml:aside>
  </xsl:template>

  <xsl:template match="ulist">
    <xhtml:ul>
      <xsl:apply-templates select="node()|@*"/>
    </xhtml:ul>
  </xsl:template>

  <xsl:template match="item">
    <xhtml:li>
      <xsl:apply-templates select="node()|@*"/>
    </xhtml:li>
  </xsl:template>

  <xsl:template match="bibref">
    <xsl:variable name="non-ref-bibl-key" as="xs:string?" select="f:bibl-id-to-key($non-ref-bibl-id-key-mappings, @ref)"/>
    <xsl:choose>
      <xsl:when test="exists($non-ref-bibl-key)">
        <xsl:text>[=</xsl:text>
        <xsl:value-of select="$non-ref-bibl-key"/>
        <xsl:text>=]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[[</xsl:text>
        <xsl:value-of select="f:to-specref-key(@ref)"/>
        <xsl:text>]]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="specref">
    <xhtml:a href="#{@ref}"></xhtml:a>
  </xsl:template>

<xsl:template match="blist">
    <xhtml:dl class="bibliography">
      <xsl:if test="@id">
        <xsl:attribute name="id" select="@id"/>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xhtml:dl>
  </xsl:template>

  <xsl:template match="bibl">
    <xhtml:dt>
      <xhtml:dfn><xsl:value-of select="@key"/></xhtml:dfn>
    </xhtml:dt>
    <xhtml:dd>
      <xsl:apply-templates select="node()"/>
    </xhtml:dd>
  </xsl:template>

  <xsl:template match="fos:proto">
    <xsl:variable name="prefix" select="f:get-prefix(.)"/>
  <xhtml:pre>
    <xhtml:code>
        <xsl:copy-of select="$prefix"/>
        <xsl:value-of select="@name"/>

        <xsl:text>(</xsl:text>
        
        <xsl:for-each select="fos:arg">
            <xsl:text>$</xsl:text>
            <xsl:value-of select="@name"/>

            <xsl:text> as </xsl:text>
            <xsl:value-of select="@type"/>

            <xsl:if test="position() ne last()">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:for-each>
        
        <xsl:text>) as </xsl:text>
        <xsl:value-of select="@return-type"/>

    </xhtml:code>
    </xhtml:pre>
</xsl:template>

  <xsl:template match="fos:example">
      <xsl:apply-templates select="node()|@*"/>
  </xsl:template>
  
  <xsl:template match="note">
    <xhtml:div class="note">
      <xsl:apply-templates select="node()|@*"/>
    </xhtml:div>
  </xsl:template>

  <xsl:template match="emph">
    <xhtml:em>
      <xsl:apply-templates select="node()|@*"/>
    </xhtml:em>
  </xsl:template>

  <xsl:template match="kw">
    <xhtml:code>
      <xsl:apply-templates select="node()|@*"/>
    </xhtml:code>
  </xsl:template>

  <xsl:template match="rfc2119">
      <xsl:value-of select="upper-case(.)"/>
  </xsl:template>
  
  <xsl:template match="olist">
    <xhtml:ol>
      <xsl:choose>
          <xsl:when test="@role">
              <xsl:attribute name="class" select="@role"/>
          </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="node()|@*[name() ne 'role']"/>
    </xhtml:ol>
  </xsl:template>

  <xsl:template match="glist">
      <xhtml:dl>
          <xsl:apply-templates select="node()|@*"/>
      </xhtml:dl>
  </xsl:template>

  <xsl:template match="gitem">
      <xsl:apply-templates select="node()|@*" mode="gitem"/>
  </xsl:template>

  <xsl:template match="label" mode="gitem">
    <xhtml:dt>
      <xsl:apply-templates select="node()|@*" mode="#default"/>
    </xhtml:dt>
  </xsl:template>

  <xsl:template match="def" mode="gitem">
    <xhtml:dd>
      <xsl:apply-templates select="node()|@*" mode="#default"/>
    </xhtml:dd>
  </xsl:template>

    <xsl:template match="table">
        <xhtml:table>
            <xsl:apply-templates select="node()|@*[not(local-name(.) = ('cellpadding', 'cellspacing', 'border', 'frame'))]"/>
        </xhtml:table>
    </xsl:template>

  <xsl:template match="phrase">
      <xhtml:span class="phrase">
          <xsl:apply-templates select="node()|@*"/>
      </xhtml:span>
  </xsl:template>

  <!-- transform <p>...<ulist>...</ulist>...</p> to <p>...</p><ul>...</ul><p>...</p> -->
  <xsl:template match="p[ulist]">
    <xsl:variable name="p-attrs" select="@*"/>

      <xsl:for-each select="node()">
        <xsl:choose>
          <xsl:when test=". instance of text()">
            <xsl:choose>
              <xsl:when test="string-length(normalize-space(.)) gt 0">
                <xhtml:p><xsl:copy-of select="$p-attrs"/><xsl:copy-of select="."/></xhtml:p>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
  </xsl:template>

  <!-- unwrap <p><eg> to just <eg> -->
  <xsl:template match="p[eg]">
      <xsl:apply-templates select="eg"/>
  </xsl:template>

  <!-- transform <p><termdef id="term-id" term="term">...</termdef></p> to <dl><dt id="term-id>term</dt><dd>...</dd> -->
  <xsl:template match="p[termdef]">
    <xhtml:dl>
      <xsl:apply-templates select="node()|@*"/>
    </xhtml:dl>
  </xsl:template>
  <xsl:template match="termdef">
    <xsl:variable name="term" select="(@term, term)[1]"/>
    <xhtml:dt><xsl:apply-templates select="@*[local-name(.) ne 'term']"/><xsl:value-of select="$term"/></xhtml:dt>
    <xhtml:dd><xsl:apply-templates select="node()"/></xhtml:dd>
  </xsl:template>
  <xsl:template match="term[parent::termdef]">
    <xhtml:i>
      <xsl:apply-templates select="node()|@*"/>
    </xhtml:i>
  </xsl:template>

  <!-- transform <termref def="term-id">...</termref> to <a href="#term-id">...</a> -->
  <xsl:template match="termref">
    <xhtml:a href="{@def}">
      <xsl:apply-templates select="node()|@*[local-name() ne 'def']"/>
    </xhtml:a>
  </xsl:template>

  <!-- identity transform - but moving namespaces -->
  <xsl:template match="@* | comment() | processing-instruction() | text()">
    <xsl:copy/>
  </xsl:template>
  <xsl:template match="element()">
    <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>

  <!--
    Get the prefix of a function prototype.

    @param fp - the function prototype.

    @return The prefix.
  -->
  <xsl:function name="f:get-prefix" as="text()">
    <xsl:param name="fp" as="element(fos:proto)"/>
    <xsl:variable name="prefix" as="attribute(prefix)" select="$fp/ancestor-or-self::*[@prefix][1]/@prefix"/>
    <xsl:choose>
      <xsl:when test="exists($prefix)"><xsl:value-of select="concat($prefix, ':')"/></xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">Unknown prefix for function: <xsl:copy-of select="$fp"/> at: <xsl:sequence select="document-uri(root($fp))"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Get a bibl key from a bibl id.

    @param bibl-id-key-mappings - the bibl id to key mappings.

    @return the bibl key if it exists, otherwise the empty sequence.
  -->
  <xsl:function name="f:bibl-id-to-key" as="xs:string?">
    <xsl:param name="bibl-id-key-mappings" as="element(bibl-mapping)*"/>
    <xsl:param name="bibl-id" as="xs:string"/>
    <xsl:sequence select="$bibl-id-key-mappings[@id eq $bibl-id]/@key/string()"/>
  </xsl:function>

  <!--
    Get a function by its prefix and local name.
    
    @param prefix - the namespace prefix for the function.
    @param local-name - the local-name of the function.
    
    @return The function definition, or terminates with an error.
  -->
  <xsl:function name="fos:get-function" as="element(fos:function)">
    <xsl:param name="fos-functions" as="element(fos:function)*"/>
    <xsl:param name="lexname" as="xs:string"/>
		<xsl:variable name="prefix" select="tokenize($lexname, ':')[1]"/>
		<xsl:variable name="local-name" select="tokenize($lexname, ':')[2]"/>
      <xsl:variable name="fspec" select="$fos-functions[@name eq $local-name][@prefix eq $prefix]"/>
      <xsl:if test="empty($fspec)">
        <xsl:message terminate="yes">Function not found in catalog: <xsl:value-of select="$prefix, $local-name" separator=":"/></xsl:message>
      </xsl:if>
      <xsl:if test="count($fspec) gt 1">
        <xsl:message terminate="yes">Duplicate function found in catalog: <xsl:value-of select="$prefix, $local-name" separator=":"/></xsl:message>
      </xsl:if>
      <xsl:sequence select="$fspec"/>
	</xsl:function>

  <!--
    Replace the old expath site prefix.

    @param url - the URL.
    @param old-site - the old site.
    @param new-site - the new site.

    @return The URL with the new site prefix.
  -->
  <xsl:function name="f:replace-url" as="xs:string">
    <xsl:param name="url" as="xs:string"/>
    <xsl:param name="old-site" as="xs:string"/>
    <xsl:param name="new-site" as="xs:string"/>
    <xsl:sequence select="replace($url, $old-site, $new-site)"/>
  </xsl:function>

  <!--
    Parse an xmlspec publication date into an valid ReSpec pubDate value.

    @param pubdate - the pubdate.

    @return The publication date.
  -->
  <xsl:function name="f:parse-xmlspec-pubdate" as="xs:date">
    <xsl:param name="pubdate" as="element(pubdate)"/>
    <xsl:variable name="months" select="('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')"/>
    <xsl:variable name="day" as="xs:string" select="format-number($pubdate/day, '00')"/>
    <xsl:variable name="month" as="xs:string" select="format-number(index-of($months, $pubdate/month), '00')"/>
    <xsl:variable name="year" as="xs:string" select="$pubdate/year"/>
    <xsl:sequence select="xs:date($year || '-' || $month || '-' || $day)"/>
  </xsl:function>

  <!--
    Get the SpecRef key for an xmlspec bibref.

    @param bibref - the xmlspec bibref.

    @return The SpecRef key if there is a none local mapping, otherwise the bibref unchanged.
  -->
  <xsl:function name="f:to-specref-key" as="xs:string">
    <xsl:param name="bibref" as="xs:string"/>
    <xsl:choose>
     <xsl:when test="$specref-mappings//mapping[@xmlspec eq $bibref][empty(title)]">
        <xsl:sequence select="$specref-mappings//mapping[@xmlspec eq $bibref]/@specref"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$bibref"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  
  <!--
    Create JSON object entries of the local bibiographic entries.
    
    @param localbibl-entries - the local bibiographic entries.
    
    @return The localbiblio JSON entries (as text nodes).
  -->
  <xsl:function name="f:localbibls-to-json" as="text()+">
    <xsl:param name="localbibl-entries" as="element(mapping)+"/>
    {
      <xsl:variable name="entries" as="xs:string+">
        <xsl:for-each select="$localbibl-entries">
          <xsl:value-of select="concat('&quot;', current()/@xmlspec, '&quot;', ': ', '&#xa;', string-join(f:localbibl-to-json(current()), ''))"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="string-join($entries, ',&#xa;      ')"/>
    }
  </xsl:function>
  
  <!--
    Create a JSON object of the local bibiographic entry.
    
    @param localbibl-entry - the local bibiographic entry.
    
    @return The localbiblio JSON (as text nodes).
  -->
  <xsl:function name="f:localbibl-to-json" as="text()+">
    <xsl:param name="localbibl-entry" as="element(mapping)"/>
    {
      <xsl:variable name="fields" as="xs:string+">
        <xsl:for-each select="$localbibl-entry/child::element()">
          <xsl:sequence select="concat(local-name(current()), ': ', '&quot;', current(), '&quot;')"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="string-join($fields, ',&#xa;      ')"/>
    }
  </xsl:function>

  <!--
    Create JSON objects of the authors details.
    
    @param authors - the authors.
    
    @return The authors JSON (as text nodes).
  -->
  <xsl:function name="f:authors-to-json" as="text()+">
    <xsl:param name="authors" as="element(author)+"/>
    [
      <xsl:for-each select="$authors">
        <xsl:copy-of select="f:author-to-json(.)"/>
        <xsl:if test="position() ne last()">,</xsl:if>
      </xsl:for-each>
    ]
  </xsl:function>

  <!--
    Create a JSON object of the authors details.
    
    @param author - the author.
    
    @return The author JSON (as text nodes).
  -->
  <xsl:function name="f:author-to-json" as="text()+">
    <xsl:param name="author" as="element(author)"/>
    {
      name: "<xsl:value-of select="normalize-space($author/name)"/>"<xsl:if test="exists($author/(affiliation|email))">,</xsl:if>
      <xsl:if test="$author/affiliation">
        company: "<xsl:value-of select="normalize-space($author/affiliation)"/>",
      </xsl:if>
      <xsl:if test="$author/email">
        mailto: "<xsl:value-of select="normalize-space($author/email)"/>"
      </xsl:if>
    }
  </xsl:function>

</xsl:stylesheet>
