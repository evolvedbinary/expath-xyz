<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:spec="http://expath.org/ns/xmlspec"
  xmlns:fos="http://www.w3.org/xpath-functions/spec/namespace"
  xmlns:f="http://function.expath.xyz"
  exclude-result-prefixes="#all">


    <xsl:param name="specref-map" as="xs:string" select="'specref-map.xml'"/>
    <xsl:param name="function-catalog" as="xs:string" select="'function-catalog.xml'"/>
    <xsl:param name="original-site" as="xs:string" select="'http://expath.org'"/>
    <xsl:param name="updated-site" as="xs:string" select="'https://www.expath.xyz'"/>

    <xsl:output method="xhtml" html-version="5" media-type="text/html" include-content-type="no" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>
    
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
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en">
      <head>
        <meta charset="utf-8" />

        <meta name="spec-w3c-doctype" content="{@w3c-doctype}"/>
        <meta name="spec-family" content="{header/title/@role}"/>
        <title><xsl:value-of select="header/title"/></title>
          
        
        <script src="https://www.w3.org/Tools/respec/respec-w3c" class="remove" defer="defer"></script>
        
        <script class="remove">
          var respecConfig = {
            specStatus: "<xsl:choose>
              <xsl:when test="@w3c-doctype eq 'rec'">CG-FINAL</xsl:when>
              <xsl:otherwise>CG-DRAFT</xsl:otherwise>
            </xsl:choose>",
            shortName: "<xsl:value-of select="normalize-space(header/title)"/>",
            group: "expath",
            
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
        </script>

      </head>
      <body>
        <xsl:apply-templates select="header"/>
        <xsl:apply-templates select="body"/>
        <section id="conformance"/>
        <xsl:apply-templates select="back"/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="header">
    <xsl:apply-templates select="abstract"/>
    <section xmlns="http://www.w3.org/1999/xhtml" id="sotd">
      <xsl:apply-templates select="node()[not(self::abstract)]|@*"/>
    </section>
  </xsl:template>

  <xsl:template match="abstract">
    <section xmlns="http://www.w3.org/1999/xhtml" id="abstract">
      <xsl:apply-templates select="@*|node()"/>
    </section>
  </xsl:template>
  
  <!-- Config from the xmlspec that should be inthe respecConfig object -->
  <xsl:template match="title|w3c-designation|w3c-doctype|pubdate|publoc|altlocs|latestloc|prevlocs|authlist|copyright|status|langusage|revisiondesc|version|subtitle"/>
  
  <xsl:template match="body">
    <xsl:apply-templates mode="body"/>
  </xsl:template>

  <xsl:template match="back">
    <xsl:apply-templates mode="back"/>
  </xsl:template>

  <xsl:template match="div1" mode="body">
    <section xmlns="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="div-children"/>
    </section>
  </xsl:template>

  <!-- Don't transform the references backmatter section from xmlspec, as ReSpec will build its own -->
  <xsl:template match="div1[@id eq 'references']" mode="back"/>

  <xsl:template match="div1" mode="back">
    <section xmlns="http://www.w3.org/1999/xhtml" class="appendix">
      <xsl:call-template name="div-children"/>
    </section>
  </xsl:template>

  <xsl:template match="div2|div3">
    <section xmlns="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="div-children"/>
    </section>
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
    <xsl:variable name="lexname" select="tokenize(normalize-space(processing-instruction('function')), ':')"/>
		<xsl:variable name="fspec" select="fos:get-function($fos-functions, $lexname[1], $lexname[2])"/>

    <!-- TODO replace h3 with a conditional or get it to use the other template		-->
    <h3 xmlns="http://www.w3.org/1999/xhtml">
			<xsl:value-of select="$lexname"/>
		</h3>
		<dl xmlns="http://www.w3.org/1999/xhtml">
			<div>
        <dt>Summary</dt>
        <dd>
          <xsl:apply-templates select="$fspec/fos:summary/node()"/>
        </dd>
      </div>
			<xsl:if test="$fspec/fos:opermap">
				<div>
					<dt>Operator Mapping</dt>
					<dd>
						<p>
							<xsl:copy-of select="$fspec/fos:opermap/node()" copy-namespaces="no"/>
						</p>
					</dd>
				</div>
			</xsl:if>
			<div>
        <dt>Signature<xsl:value-of select="'s'[$fspec/fos:signatures/fos:proto[2]]" /></dt>
        <dd>
          <xsl:apply-templates select="$fspec/fos:signatures/fos:proto"/>
        </dd>
      </div>
			<xsl:if test="$fspec/fos:properties">
				<div>
					<dt>Properties</dt>
					<dd>
						<xsl:for-each select="$fspec/fos:properties">
							<p>
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
							</p>
						</xsl:for-each>
					</dd>
				</div>
			</xsl:if>
			<div>
        <dt>Rules</dt>
        <dd>
          <xsl:apply-templates select="$fspec/fos:rules/node()"/>
        </dd>
      </div>
      <xsl:if test="$fspec/fos:errors">
        <div>
          <dt>Error Conditions</dt>
          <dd>
            <xsl:apply-templates select="$fspec/fos:errors/node()"/>
          </dd>
        </div>
      </xsl:if>
      <xsl:if test="$fspec/fos:notes">
        <div>
          <dt>Notes</dt>
          <dd>
            <xsl:apply-templates select="$fspec/fos:notes/node()"/>
          </dd>
        </div>
      </xsl:if>
			<xsl:if test="$fspec/fos:examples">
				<div>
					<dt>Examples</dt>
					<dd>
						<xsl:apply-templates select="$fspec/fos:examples/node()"/>
					</dd>
				</div>
			</xsl:if>
		</dl>
	</xsl:template>

  <xsl:template match="head[parent::div1]">
    <h2 xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="node()"/>
    </h2>
  </xsl:template>
  
  <xsl:template match="head[parent::div2]">
    <h3 xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="node()"/>
    </h3>
  </xsl:template>

  <xsl:template match="head[parent::div3]">
    <h4 xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="node()"/>
    </h4>
  </xsl:template>

  <xsl:template match="loc|xtermref">
    <a xmlns="http://www.w3.org/1999/xhtml" href="{@href}">
      <xsl:apply-templates select="text()"/>
    </a>
  </xsl:template>

  <xsl:template match="spec:type">
    <code xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="text()"/>
    </code>
  </xsl:template>

  <xsl:template match="spec:function">
    <code xmlns="http://www.w3.org/1999/xhtml" class="function">
      <xsl:apply-templates select="node()"/>
    </code>
  </xsl:template>

  <xsl:template match="eg">
    <aside xmlns="http://www.w3.org/1999/xhtml" class="example">
      <pre>
        <xsl:apply-templates select="@*|node()"/>
      </pre>
    </aside>
  </xsl:template>

  <xsl:template match="ulist">
    <ul xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="node()|@*"/>
    </ul>
  </xsl:template>

  <xsl:template match="item">
    <li xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="node()|@*"/>
    </li>
  </xsl:template>

  <xsl:template match="bibref">
        <xsl:text>[[</xsl:text>
        <xsl:value-of select="spec:to-specref-key(@ref)"/>
        <xsl:text>]]</xsl:text>
  </xsl:template>

  <xsl:template match="specref">
    <a xmlns="http://www.w3.org/1999/xhtml" href="#{@ref}"></a>
  </xsl:template>

<xsl:template match="blist">
    <dl xmlns="http://www.w3.org/1999/xhtml" class="bibliography">
      <xsl:if test="@id">
        <xsl:attribute name="id" select="@id"/>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </dl>
  </xsl:template>

  <xsl:template match="bibl">
    <dt xmlns="http://www.w3.org/1999/xhtml" id="{@id}">
      <xsl:value-of select="@key"/>
    </dt>
    <dd xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="node()"/>
    </dd>
  </xsl:template>

  <xsl:template match="fos:proto">
    <xsl:variable name="prefix" select="f:get-prefix(.)"/>
  <pre xmlns="http://www.w3.org/1999/xhtml">
    <code>
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

    </code>
    </pre>
</xsl:template>

  <xsl:template match="fos:example">
      <xsl:apply-templates select="node()|@*"/>
  </xsl:template>
  
  <xsl:template match="note">
    <div xmlns="http://www.w3.org/1999/xhtml" class="note">
      <xsl:apply-templates select="node()|@*"/>
    </div>
  </xsl:template>

  <xsl:template match="emph">
    <em xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="node()|@*"/>
    </em>
  </xsl:template>

  <xsl:template match="kw">
    <code xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="node()|@*"/>
    </code>
  </xsl:template>

  <xsl:template match="rfc2119">
      <xsl:value-of select="upper-case(.)"/>
  </xsl:template>
  
  <xsl:template match="olist">
    <ol xmlns="http://www.w3.org/1999/xhtml">
      <xsl:choose>
          <xsl:when test="@role">
              <xsl:attribute name="class" select="@role"/>
          </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="node()|@*[name() ne 'role']"/>
    </ol>
  </xsl:template>

  <xsl:template match="glist">
      <dl xmlns="http://www.w3.org/1999/xhtml">
          <xsl:apply-templates select="node()|@*"/>
      </dl>
  </xsl:template>

  <xsl:template match="gitem">
      <xsl:apply-templates select="node()|@*" mode="gitem"/>
  </xsl:template>

  <xsl:template match="label" mode="gitem">
    <dt xmlns="http://www.w3.org/1999/xhtml"><dfn>
        <xsl:apply-templates select="node()|@*" mode="#default"/>
    </dfn></dt>
  </xsl:template>

  <xsl:template match="def" mode="gitem">
    <dd xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="node()|@*" mode="#default"/>
    </dd>
  </xsl:template>

    <xsl:template match="table">
        <table xmlns="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="node()|@*[not(local-name(.) = ('cellpadding', 'cellspacing', 'border', 'frame'))]"/>
        </table>
    </xsl:template>

  <xsl:template match="phrase">
      <span xmlns="http://www.w3.org/1999/xhtml" class="phrase">
          <xsl:apply-templates select="node()|@*"/>
      </span>
  </xsl:template>

  <!-- transform <p>...<ulist>...</ulist>...</p> to <p>...</p><ul>...</ul><p>...</p> -->
  <xsl:template match="p[ulist]">
    <xsl:variable name="p-attrs" select="@*"/>

      <xsl:for-each select="node()">
        <xsl:choose>
          <xsl:when test=". instance of text()">
            <xsl:choose>
              <xsl:when test="string-length(normalize-space(.)) gt 0">
                <p xmlns="http://www.w3.org/1999/xhtml"><xsl:copy-of select="$p-attrs"/><xsl:copy-of select="."/></p>
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
    <dl xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="node()|@*"/>
    </dl>
  </xsl:template>
  <xsl:template match="termdef">
    <xsl:variable name="term" select="(@term, term)[1]"/>
    <dt xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates select="@*[local-name(.) ne 'term']"/><xsl:value-of select="$term"/></dt>
    <dd xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates select="node()"/></dd>
  </xsl:template>
  <xsl:template match="term[parent::termdef]">
    <i xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="node()|@*"/>
    </i>
  </xsl:template>

  <!-- transform <termref def="term-id">...</termref> to <a href="#term-id">...</a> -->
  <xsl:template match="termref">
    <a xmlns="http://www.w3.org/1999/xhtml" href="{@def}">
      <xsl:apply-templates select="node()|@*[local-name() ne 'def']"/>
    </a>
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

  <xsl:function name="f:get-prefix" as="text()">
    <xsl:param name="node" as="element(fos:proto)"/>
    <xsl:variable name="prefix" as="attribute(prefix)" select="$node/ancestor-or-self::*[@prefix][1]/@prefix"/>
    <xsl:choose>
      <xsl:when test="exists($prefix)"><xsl:value-of select="concat($prefix, ':')"/></xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">Unknown prefix for function: <xsl:copy-of select="$node"/> at: <xsl:sequence select="document-uri(root($node))"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>                

  <!--
    Get a function by its prefix and local name.
    
    @param prefix - the namespace prefix for the function.
    @param local-name - the local-name of the function.
    
    @return The function definition, or terminates with an error.
  -->
  <xsl:function name="fos:get-function" as="element(fos:function)">
    <xsl:param name="fos-functions" as="element(fos:function)*"/>
		<xsl:param name="prefix" as="xs:string"/>
		<xsl:param name="local-name" as="xs:string"/>
      <xsl:variable name="fspec" select="$fos-functions[@name eq $local-name][@prefix eq $prefix]"/>
      <xsl:if test="empty($fspec)">
        <xsl:message terminate="yes">Function not found in catalog: <xsl:value-of select="$prefix, $local-name" separator=":"/></xsl:message>
      </xsl:if>
      <xsl:if test="count($fspec) gt 1">
        <xsl:message terminate="yes">Duplicate function found in catalog: <xsl:value-of select="$prefix, $local-name" separator=":"/></xsl:message>
      </xsl:if>
      <xsl:sequence select="$fspec"/>
	</xsl:function>

  <xsl:function name="f:replace-url" as="xs:string">
    <xsl:param name="url" as="xs:string"/>
    <xsl:param name="old-site" as="xs:string"/>
    <xsl:param name="new-site" as="xs:string"/>
    <xsl:sequence select="replace($url, $old-site, $new-site)"/>
  </xsl:function>

  <xsl:function name="f:parse-xmlspec-pubdate" as="xs:date">
    <xsl:param name="pubdate" as="element(pubdate)"/>
    <xsl:variable name="months" select="('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')"/>
    <xsl:variable name="day" as="xs:string" select="format-number($pubdate/day, '00')"/>
    <xsl:variable name="month" as="xs:string" select="format-number(index-of($months, $pubdate/month), '00')"/>
    <xsl:variable name="year" as="xs:string" select="$pubdate/year"/>
    <xsl:sequence select="xs:date($year || '-' || $month || '-' || $day)"/>
  </xsl:function>

  <xsl:function name="spec:to-specref-key" as="xs:string">
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
