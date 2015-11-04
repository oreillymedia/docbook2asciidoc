<xsl:stylesheet version="2.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:util="http://github.com/oreillymedia/docbook2asciidoc/"
 exclude-result-prefixes="util"
 >

<!-- Import docbook2htmlbook XSL for passthroughs -->
<xsl:include href="docbook2htmlbook/db2htmlbook.xsl"/>

<!-- Mapping to allow use of XML reserved chars in AsciiDoc markup elements, e.g., angle brackets for cross-references --> 
<xsl:character-map name="xml-reserved-chars">
  <xsl:output-character character="&#xE801;" string="&lt;"/>
  <xsl:output-character character="&#xE802;" string="&gt;"/>
  <xsl:output-character character="&#xE803;" string="&amp;"/>
  <xsl:output-character character='“' string="&amp;ldquo;"/>
  <xsl:output-character character='”' string="&amp;rdquo;"/>
  <xsl:output-character character="’" string="&amp;rsquo;"/>
</xsl:character-map>

<xsl:output method="xml" omit-xml-declaration="yes" use-character-maps="xml-reserved-chars"/>
<xsl:param name="chunk-output-d2a">false</xsl:param>
<xsl:param name="bookinfo-doc-name">book-docinfo.xml</xsl:param>
<xsl:param name="glossary-passthrough">false</xsl:param>
<xsl:param name="add-equation-titles">false</xsl:param>

<xsl:preserve-space elements="*"/>
<xsl:strip-space elements="table row entry tgroup thead"/>

<xsl:template match="/book" priority="2">
  <xsl:choose>
    <xsl:when test="title">
      <xsl:apply-templates select="title" mode="d2a"/>
    </xsl:when>
    <xsl:when test="bookinfo/title">
      <xsl:apply-templates select="bookinfo/title" mode="d2a"/>
    </xsl:when>
  </xsl:choose>
  <xsl:choose>
    <xsl:when test="$chunk-output-d2a != 'false'">
      <xsl:apply-templates select="*[not(self::title)]" mode="chunk"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="*[not(self::title)]" mode="d2a"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<xsl:template match="//comment()" mode="d2a">

++++++++++++++++++++++++++++++++++++++
<xsl:copy/>
++++++++++++++++++++++++++++++++++++++
    
</xsl:template>

<!-- Complex inline formatting in remark elements will not be preserved -->
<xsl:template match="remark" mode="d2a">
<xsl:choose>
<xsl:when test="para or not(ancestor::para)">
++++++++++++++++++++++++++++++++++++++
<xsl:comment>
<xsl:choose>
<xsl:when test="para">
<xsl:for-each select="para"><xsl:copy-of select="*|node()"/><xsl:text>
</xsl:text></xsl:for-each>
</xsl:when>
<xsl:otherwise><xsl:copy-of select="*|node()"/></xsl:otherwise>
</xsl:choose>
</xsl:comment>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
<xsl:otherwise>pass:[<xsl:comment><xsl:copy-of select="*|node()"/></xsl:comment>]</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- <xsl:template match="processing-instruction()" mode="d2a">
<xsl:text>+++</xsl:text>
<xsl:copy-of select="."/>
<xsl:text>+++</xsl:text>
</xsl:template> -->

<xsl:template match="processing-instruction()" mode="d2a"/>

<xsl:template match="book/title|bookinfo/title" mode="d2a">
  <xsl:text>= </xsl:text>
  <xsl:value-of select="."/>
  <xsl:value-of select="util:carriage-returns(2)"/>
</xsl:template>

<xsl:template match="part" mode="chunk">
  <!-- Only bother chunking parts into a separate file if there's actually partintro content -->
  <xsl:variable name="part_content">
    <!-- Title and partintro (if present) -->
    <xsl:call-template name="process-id-d2a"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:text xml:space="preserve">= </xsl:text>
    <xsl:apply-templates select="title" mode="d2a"/>
    <xsl:value-of select="util:carriage-returns(2)"/>
    <xsl:apply-templates select="partintro" mode="d2a"/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="partintro">
      <xsl:variable name="doc-name">
	<xsl:text>part</xsl:text>
	<xsl:number count="part" level="any" format="i"/>
	<xsl:text>.asciidoc</xsl:text>
      </xsl:variable>
      <xsl:value-of select="util:carriage-returns(2)"/>
      <xsl:text>include::</xsl:text>
      <xsl:value-of select="$doc-name"/>
      <xsl:text>[]</xsl:text>
      <xsl:result-document href="{$doc-name}">
	<xsl:value-of select="$part_content"/>
      </xsl:result-document>
      <xsl:apply-templates select="*[not(self::title)][not(self::partintro)]" mode="chunk"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="util:carriage-returns(2)"/>
      <xsl:value-of select="$part_content"/>
      <xsl:apply-templates select="*[not(self::title)][not(self::partintro)]" mode="chunk"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="chapter|appendix|preface|colophon|dedication|glossary|bibliography" mode="chunk">
  <xsl:variable name="doc-name">
    <xsl:choose>
      <xsl:when test="self::chapter">
        <xsl:text>ch</xsl:text>
	<xsl:number count="chapter" level="any" format="01"/>
      </xsl:when>
      <xsl:when test="self::appendix">
        <xsl:text>app</xsl:text>
	<xsl:number count="appendix" level="any" format="a"/>
      </xsl:when>
      <xsl:when test="self::preface">
	<xsl:text>pr</xsl:text>
	<xsl:number count="preface" level="any" format="01"/>
      </xsl:when>
      <xsl:when test="self::colophon">
        <xsl:text>colo</xsl:text>
        <xsl:if test="count(//colophon) &gt; 1">
	  <xsl:number count="colo" level="any" format="01"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="self::dedication">
        <xsl:text>dedication</xsl:text>
        <xsl:if test="count(//dedication) &gt; 1">
	  <xsl:number count="dedication" level="any" format="01"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="self::glossary">
        <xsl:text>glossary</xsl:text>
        <xsl:if test="count(//glossary) &gt; 1">
	  <xsl:number count="glossary" level="any" format="01"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="self::bibliography">
        <xsl:text>bibliography</xsl:text>
        <xsl:if test="count(//bibliography) &gt; 1">
	  <xsl:number count="bibliography" level="any" format="01"/>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
    <xsl:text>.asciidoc</xsl:text>
  </xsl:variable>
  <xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:text>include::</xsl:text>
  <xsl:value-of select="$doc-name"/>
  <xsl:text>[]</xsl:text>
  <xsl:result-document href="{$doc-name}">
    <xsl:apply-templates select="." mode="d2a"/>
  </xsl:result-document>
</xsl:template>

<!-- BEGIN INDEX HANDLING --> 
  <!-- Create index.asciidoc file, add include to book.asciidoc file -->
  <xsl:template match="index" mode="chunk">
        <xsl:value-of select="util:carriage-returns(2)"/>
        <xsl:text>include::index.asciidoc[]</xsl:text>
        <xsl:result-document href="index.asciidoc">
          <xsl:apply-templates select="." mode="d2a"/>
        </xsl:result-document>
  </xsl:template>

  <!-- Output heading markup in index file -->
  <xsl:template match="index" mode="d2a">
    <xsl:choose>
        <xsl:when test="preceding::part">
        <xsl:text>= Index</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>== Index</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Handling for in-text index markup -->
  <!-- Specific handling for indexterms in emphasis elements, to override emphasis template that was ignoring indexterms -->
  <xsl:template match="indexterm | indexterm[parent::emphasis]" mode="d2a">
    <xsl:text>(((</xsl:text><xsl:apply-templates mode="d2a"/><xsl:text>)))</xsl:text>
  </xsl:template>

  <xsl:template match="indexterm[@class='startofrange'][not(*/@sortas)] | indexterm[@class='startofrange'][parent::emphasis][not(*/@sortas)]" mode="d2a">
    <xsl:text>(((</xsl:text><xsl:apply-templates mode="d2a"/><xsl:text>, id="</xsl:text><xsl:value-of select="@id"/><xsl:text>", range="startofrange")))</xsl:text>
  </xsl:template>
  
  <xsl:template match="indexterm[*/@sortas][not(@class='startofrange')] | indexterm[*/@sortas][parent::emphasis][not(@class='startofrange')]">
    <xsl:choose>
      <!-- Output indexterms with @sortas and both primary and secondary indexterms as passthroughs. Not supported in Asciidoc markup. -->
      <xsl:when test="secondary"><xsl:text>pass:[</xsl:text><xsl:copy-of select="."/><xsl:text>]</xsl:text></xsl:when>
      <!-- When only primary term exists, output as asciidoc -->
      <xsl:otherwise><xsl:text>(((</xsl:text><xsl:apply-templates/><xsl:text>, sortas="</xsl:text><xsl:value-of select="primary/@sortas"/><xsl:text>")))</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Output indexterms with both @sortas and @startofrange as passthroughs. Not supported in Asciidoc markup. -->
  <xsl:template match="indexterm[@class='startofrange' and */@sortas]" mode="d2a">
    <xsl:text>pass:[</xsl:text><xsl:apply-templates select="."/><xsl:text>]</xsl:text>
  </xsl:template>
  
  <xsl:template match="indexterm[@class='endofrange'] | indexterm[@class='endofrange'][parent::emphasis]" mode="d2a">
      <xsl:text>(((range="endofrange", startref="</xsl:text><xsl:value-of select="@startref"/><xsl:text>")))</xsl:text>
  </xsl:template>

  <xsl:template match="indexterm/primary | indexterm/primary[parent::emphasis]" mode="d2a">
      <xsl:text>"</xsl:text><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:apply-templates mode="d2a"/><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="indexterm/secondary | indexterm/secondary[parent::emphasis]" mode="d2a">
      <xsl:text>, "</xsl:text><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:apply-templates mode="d2a"/><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="indexterm/tertiary | indexterm/tertiary[parent::emphasis]" mode="d2a">
    <xsl:text>, "</xsl:text><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:apply-templates mode="d2a"/><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="indexterm/see | indexterm/see[parent::emphasis]" mode="d2a">
    <xsl:text>, see="</xsl:text><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:apply-templates mode="d2a"/><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="indexterm/seealso | indexterm/seealso[parent::emphasis]" mode="d2a">
    <xsl:text>, seealso="</xsl:text><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:apply-templates mode="d2a"/><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:text>"</xsl:text>
  </xsl:template>
<!-- END INDEX HANDLING -->

<!-- Special handling for text inside code block that will be converted as Asciidoc, to make sure special characters are not escaped.-->
<xsl:template match="text()" mode="code">
  <xsl:value-of select=".[not(parent::title)]" disable-output-escaping="yes"></xsl:value-of>
</xsl:template>

<xsl:template match="phrase/text()" mode="d2a"><xsl:text/><xsl:value-of select="replace(., '\n\s+', ' ', 'm')"/><xsl:text/></xsl:template>

<xsl:template match="ulink/text()" mode="d2a">
<xsl:value-of select="replace(., '\n\s+', ' ', 'm')"/>
</xsl:template>

<xsl:template match="title/text()" mode="d2a">
<xsl:value-of select="replace(., '\n\s+', ' ', 'm')"/>
</xsl:template>

<xsl:template match="text()[contains(.,'$$')]" mode="d2a">
<xsl:value-of select='replace(.,"([\$]{2})","+++$1+++","m")'/>
</xsl:template>

<!-- Handling whitespace -->
<xsl:template match="text()" mode="d2a">
<xsl:choose>
<xsl:when test="ancestor::*[@xml:space][1]/@xml:space='preserve'">
<xsl:value-of select="normalize-space(replace(., '([\\])', '\$\$$1\$\$', 'm'))"/>
</xsl:when>
<xsl:otherwise>
<!-- Retain one leading space if node isn't first, has non-space content, and has leading space.-->
<xsl:if test="position()!=1 and matches(.,'^\s') and normalize-space()!=''">
<xsl:text> </xsl:text>
</xsl:if>
<xsl:choose>
<!-- If in a table, add double dollars around special characters and escape pipes,double-dollars, and backslashes -->
<xsl:when test='(ancestor::table or ancestor::informaltable)'>
<xsl:choose>
<xsl:when test='(contains(., "~") or contains(., "_") or contains(., "^") or contains(., "*") or contains(., "/") or contains(., "+") or contains(., "&apos;") or contains(.,"|"))'>
<xsl:value-of select='normalize-space(replace(replace(replace(., "([~_\^\*/\+&apos;]{1,2})", "\$\$$1\$\$", "m"), "([\\])", "\$\$$1\$\$", "m"), "([\|])", "\\$1", "m"))'/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="normalize-space(replace(., '([\\])', '\$\$$1\$\$', 'm'))"/>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- If NOT in a table but in an inline, add double dollars around special characters and escape backslashes, double-dollars, but NOT pipes -->
<xsl:when test='(ancestor::emphasis or ancestor::literal or ancestor::code or ancestor::filename or ancestor::command or ancestor::replaceable or ancestor::emphasis or ancestor::literal or ancestor::code or ancestor::filename or ancestor::command or ancestor::option or ancestor::computeroutput or ancestor::varname or ancestor::classname or ancestor::code or ancestor::envar or ancestor::constant or ancestor::function or ancestor::methodname or ancestor::package or ancestor::property or ancestor::uri) and not(ancestor::table or ancestor::informaltable)'>
<xsl:choose>
<xsl:when test='(contains(., "~") or contains(., "_") or contains(., "^") or contains(., "*") or contains(., "/") or contains(., "+") or contains(., "&apos;"))'>
<xsl:value-of select='normalize-space(replace(replace(., "([~_\^\*/\+&apos;]{1,2})", "\$\$$1\$\$", "m"), "([\\])", "\$\$$1\$\$", "m"))'/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="normalize-space(replace(., '([\\])', '\$\$$1\$\$', 'm'))"/>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- If in neither in a table or an inline, only escape backslashes and double-dollars -->
<xsl:otherwise>
<xsl:value-of select="normalize-space(replace(., '([\\])', '\$\$$1\$\$', 'm'))"/>
</xsl:otherwise>
</xsl:choose>
<xsl:choose>
<!-- Retain trailing space if... -->
<!-- node is an only child, and has content but it's all space -->
<xsl:when test="last()=1 and string-length()!=0 and normalize-space()=''">
<xsl:text> </xsl:text>
</xsl:when>
<!-- node isn't last, isn't first, and has trailing space -->
<xsl:when test="position()!=1 and position()!=last() and matches(.,' $')">
<xsl:text> </xsl:text>
</xsl:when>
<!-- node is first, has trailing space, and has non-space content   -->
<xsl:when test="position()=1 and matches(.,' $') and normalize-space()!=''">
<xsl:text> </xsl:text>
</xsl:when>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- Strip leading whitespace from first text node in <term>, if it does not have preceding element siblings --> 
<xsl:template match="term[count(element()) != 0]/text()[1][not(preceding-sibling::element())]" mode="d2a">
  <xsl:call-template name="strip-whitespace">
    <xsl:with-param name="text-to-strip" select="."/>
    <xsl:with-param name="leading-whitespace" select="'strip'"/>
  </xsl:call-template>
</xsl:template>

<!-- Strip trailing whitespace from last text node in <term>, if it does not have following element siblings --> 
<xsl:template match="term[count(element()) != 0]/text()[not(position() = 1)][last()][not(following-sibling::element())]" mode="d2a">
  <xsl:call-template name="strip-whitespace">
    <xsl:with-param name="text-to-strip" select="."/>
    <xsl:with-param name="trailing-whitespace" select="'strip'"/>
  </xsl:call-template>
</xsl:template>

<!-- If term has just one text node (no element children), just normalize space in it -->
<xsl:template match="term[count(element()) = 0]/text()" mode="d2a">
  <xsl:value-of select="normalize-space(.)"/>
</xsl:template>

<!-- Text nodes in <term> that are between elements that contain only whitespace should be normalized to one space -->
<xsl:template match="term/text()[not(position() = 1)][not(position() = last())][matches(., '^[\s\n]+$', 'm')]" mode="d2a">
  <xsl:value-of select="replace(., '^[\s\n]+$', ' ', 'm')"/>
</xsl:template>

<xsl:template match="member/text()" mode="d2a">
<xsl:value-of select="replace(., '^\s+', '', 'm')"/>
</xsl:template>

<!-- Normalize space in indexterms -->
<xsl:template match="indexterm//text()" mode="d2a">
  <xsl:value-of select="normalize-space(.)"/>
</xsl:template>

<!-- Output bookinfo children into book-docinfo.xml -->
<xsl:template match="bookinfo" mode="#all">
<xsl:result-document href="{$bookinfo-doc-name}">
  <xsl:apply-templates mode="bookinfo-children"/>
</xsl:result-document>
</xsl:template>

<xsl:template match="bookinfo/*" mode="bookinfo-children">
  <xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="part" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
= <xsl:apply-templates select="title" mode="d2a"/>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]" mode="d2a"/>
</xsl:template>

<xsl:template match="partintro" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
[partintro]
<xsl:apply-templates select="." mode="title"/>
--
<xsl:apply-templates select="*[not(self::title)]" mode="d2a"/>
--
</xsl:template>
  
<xsl:template match="chapter" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
== <xsl:apply-templates select="title" mode="d2a"/>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]" mode="d2a"/>
</xsl:template> 

<xsl:template match="appendix" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
[appendix]
== <xsl:apply-templates select="title" mode="d2a"/>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]" mode="d2a"/>
</xsl:template>

<xsl:template match="prefaceinfo" mode="d2a"/>

<xsl:template match="preface" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
<xsl:text>&#10;</xsl:text>
<xsl:text>[preface]
</xsl:text>

<xsl:if test="prefaceinfo">
<!--Gather Author name(s): -->
<xsl:text>[</xsl:text>
   <!-- For each author: -->
   <xsl:for-each select="prefaceinfo/author">
       <!--Dynamic retrieval of author number-->
       <xsl:variable name="prefauth" select="position()" />
       <!--Add a comma if 2nd+ author -->
       <xsl:if test="$prefauth &gt; 1">
          <xsl:text>, </xsl:text>
       </xsl:if>
       <xsl:choose>
         <!-- if first author, don't append a number -->
         <xsl:when test="$prefauth = 1">
            <xsl:text>au=</xsl:text>
         </xsl:when>
         <!-- if 2nd or later author, append a number -->
         <xsl:when test="$prefauth &gt; 1">
            <xsl:value-of select="concat('au',$prefauth, '=')"/>
         </xsl:when>
       </xsl:choose> 
       <xsl:text>"</xsl:text>
       <!--Grabbing only specific children nodes, as affiliation nodes can also show up within author nods -->
       <!--If firstname/surname:-->     
       <xsl:if test="firstname">
           <xsl:value-of select="firstname"/>
       </xsl:if>
       <xsl:if test="surname">
           <xsl:text> </xsl:text><xsl:value-of select="surname"/>
       </xsl:if>
       <!--If othername:-->
       <xsl:if test="othername">
           <xsl:value-of select="othername"/>
       </xsl:if>
       <xsl:text>"</xsl:text>
  </xsl:for-each>

<!--Gather Author Affiliation(s):-->
   <!--Test to see if there's not a date, not an affiliation OUTSIDE author, not an affiliation INSIDE author -->
   <xsl:choose>
     <!--If there's nothing, just close the tag and you're good-->
     <xsl:when test="not(prefaceinfo//affiliation) and not(prefaceinfo/date)">
        <xsl:text>]</xsl:text>
     </xsl:when>
     <xsl:otherwise>
      <!--There can be multiple affiliations and multiple jobtitles or orgnames within each other. We need for-each's to select potentially multiple of all of these -->
        <xsl:text>, auaffil="</xsl:text>         
         <!--For each child affilation tag in prefaceinfo-->
         <xsl:for-each select="prefaceinfo//affiliation">
           <!--Commas for multiple jobtitle/orgname nodes within a single affiliation node-->
           <xsl:value-of select="*" separator=", "/>
           <!-- Comma Formatting For things separator doesn't get-->
           <xsl:if test="not( position() = last() )">
              <xsl:text>, </xsl:text>
           </xsl:if>
         </xsl:for-each>
         <!--If Date, put it in:-->
         <xsl:if test="prefaceinfo//date">
            <!--only use a comma if there were preceding affiliation things-->
            <xsl:if test="prefaceinfo//affiliation">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="prefaceinfo//date"/>
           </xsl:if>
        <!-- close off the asciidioc tag -->
        <xsl:text>"]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
</xsl:if>
<xsl:text>== </xsl:text><xsl:value-of select="title"/>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]" mode="d2a"/>
</xsl:template>

<xsl:template match="sect1" mode="d2a">
  <!-- If sect1 title is "References," override special Asciidoc section macro -->
<xsl:if test="title = 'References'">
  <xsl:text>[sect2]</xsl:text>
  <xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
<xsl:call-template name="process-id-d2a"/>
=== <xsl:apply-templates select="title" mode="d2a"/>
<xsl:value-of select="util:carriage-returns(2)"/>
<xsl:if test="sect1info and not(sect1info//author[2])">__By <xsl:value-of select="normalize-space(sect1info//firstname)"/><xsl:text> </xsl:text><xsl:value-of select="normalize-space(sect1info//surname)"/>__<xsl:value-of select="util:carriage-returns(2)"/></xsl:if>
  <xsl:apply-templates select="*[not(self::title or self::sect1info)]" mode="d2a"/>
</xsl:template>

<xsl:template match="sect1info"/>

<xsl:template match="sect2" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
==== <xsl:apply-templates select="title" mode="d2a"/>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]" mode="d2a"/>
</xsl:template>

<xsl:template match="sect3" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
===== <xsl:apply-templates select="title" mode="d2a"/>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]" mode="d2a"/>
</xsl:template>

<!-- Use passthrough for sect4 as there is no AsciiDoc markup/formatting for these -->
<xsl:template match="sect4" mode="d2a">
++++++++++++++++++++++++++++++++++++++
<xsl:element name="section">
<xsl:attribute name="data-type">sect4</xsl:attribute>
<xsl:copy-of select="@*"/><xsl:text>
</xsl:text>
<xsl:element name="h4"><xsl:apply-templates select="title" mode="d2a"/></xsl:element>
++++++++++++++++++++++++++++++++++++++

<xsl:apply-templates select="*[not(self::title)]" mode="d2a"/>
++++++++++++++++++++++++++++++++++++++
</xsl:element>
++++++++++++++++++++++++++++++++++++++

</xsl:template>

<xsl:template match="para/@id" mode="d2a"/>

<!-- Use passthrough for bibliography -->
<xsl:template match="bibliography" mode="d2a">
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++
</xsl:template>

<!-- Use passthrough for reference sections -->
<xsl:template match="refentry" mode="d2a">
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++
</xsl:template>

<!-- Begin handling for glossary -->
<xsl:template match="glossary" mode="d2a">
  <xsl:choose>
    <xsl:when test="$glossary-passthrough != 'false'">
<xsl:call-template name="process-id-d2a"/>
<xsl:text>[glossary]
== Glossary

</xsl:text>
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="*[not(local-name() = 'title')]"/>
++++++++++++++++++++++++++++++++++++++
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="process-id-d2a"/>== <xsl:value-of select="title"/><xsl:value-of select="util:carriage-returns(2)"/>[glossary]<xsl:value-of select="util:carriage-returns(1)"/><xsl:apply-templates select="*[not(self::title)]" mode="d2a"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<xsl:template match="glossentry" mode="d2a">
  <xsl:call-template name="process-id-d2a"/>
  <xsl:apply-templates select="glossterm" mode="d2a"/><xsl:text>::&#10;</xsl:text><xsl:text>   </xsl:text><xsl:apply-templates select="glossdef" mode="d2a"/>
</xsl:template>

<!-- Output glossary "See Also"s as hardcoded text. Asc to DB toolchain does not 
    currently retain any @id attrbutes for glossentry elements. -->
<xsl:template match="glossseealso" mode="d2a">
  <xsl:choose>
    <xsl:when test="preceding-sibling::para">
      <xsl:text>+&#10;See Also </xsl:text><xsl:value-of select="id(@otherterm)/glossterm" /><xsl:choose>
        <xsl:when test="following-sibling::glossseealso"><xsl:value-of select="util:carriage-returns(1)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="util:carriage-returns(2)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>See Also </xsl:text><xsl:value-of select="id(@otherterm)/glossterm" /><xsl:value-of select="util:carriage-returns(2)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
<!-- End handling for glossary -->
  
<xsl:template match="colophon" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
  <xsl:choose>
    <xsl:when test="preceding::part">
      <xsl:text>= Colophon</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>== Colophon</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:choose>
    <xsl:when test="para/text()"><xsl:apply-templates select="*[not(self::title)]" mode="d2a"/></xsl:when>
    <xsl:otherwise><xsl:text>(FILL IN)</xsl:text></xsl:otherwise>
  </xsl:choose>
  
</xsl:template>
  
  <xsl:template match="dedication" mode="d2a">
    <xsl:call-template name="process-id-d2a"/>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>[dedication]</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>== Dedication</xsl:text>
    <xsl:value-of select="util:carriage-returns(2)"/>
    <xsl:apply-templates select="node()[not(self::title)]" mode="d2a"/>
  </xsl:template>
  
<xsl:template match="para|simpara" mode="d2a">
  <xsl:choose>
    <xsl:when test="ancestor::callout"/>
    <xsl:otherwise>
      <xsl:call-template name="process-id-d2a"/>
    </xsl:otherwise>
  </xsl:choose>
  <!-- If it's the 2nd+ para inside a listitem, glossdef, or callout (but not a nested admonition or sidebar), precede it with a plus symbol -->
<xsl:if test="ancestor::listitem and preceding-sibling::element()">
<xsl:choose>
<xsl:when test="not(ancestor::warning|ancestor::note|ancestor::caution|ancestor::tip|ancestor::important) and not(ancestor::sidebar)">
  <xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/></xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="util:carriage-returns(1)"/>
  </xsl:otherwise>
</xsl:choose>
</xsl:if>
<xsl:if test="ancestor::glossdef and preceding-sibling::element()"><xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/></xsl:if>
<xsl:if test="ancestor::callout and preceding-sibling::element()"><xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/></xsl:if>
<xsl:apply-templates select="node()" mode="d2a"/>
  <!-- Control number of blank lines following para, if it's inside a listitem or glossary -->
<xsl:choose>
  <xsl:when test="following-sibling::glossseealso">
    <xsl:value-of select="util:carriage-returns(1)"/>
  </xsl:when>
  <xsl:when test="ancestor::listitem and following-sibling::element()">
    <xsl:value-of select="util:carriage-returns(1)"/>
  </xsl:when>
  <xsl:otherwise><xsl:value-of select="util:carriage-returns(2)"/></xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="formalpara" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
<!-- Put formalpara <title> in bold (drop any inline formatting) -->
<xsl:text>**</xsl:text>
<xsl:value-of select="title"/>
<xsl:text>** </xsl:text>
<xsl:apply-templates select="node()[not(self::title)]" mode="d2a"/>
<xsl:value-of select="util:carriage-returns(2)"/>
</xsl:template>

<!-- Same handling for blockquote and epigraph; convert to AsciiDoc quote block -->
<xsl:template match="blockquote|epigraph" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
<xsl:apply-templates select="." mode="title"/>
<xsl:text>[quote</xsl:text>
<xsl:if test="attribution">
  <xsl:text>, </xsl:text>
  <!-- Simple processing of attribution elements, placing a space between each
       and skipping <citetitle>, which is handled separately below -->
  <xsl:for-each select="attribution/text()|attribution//*[not(*)][not(self::citetitle)]">
    <!--Output text as is, except escape commas as &#44; entities for 
	proper AsciiDoc attribute processing -->
    <xsl:value-of select="normalize-space(replace(., ',', '&#xE803;#44;'))"/>
    <xsl:text> </xsl:text>
  </xsl:for-each>
</xsl:if>
<xsl:if test="attribution/citetitle">
  <xsl:text>, </xsl:text>
  <xsl:value-of select="attribution/citetitle"/>
</xsl:if>
<xsl:text>]</xsl:text>
____
<xsl:apply-templates select="node()[not(self::title or self::attribution)]" mode="d2a"/>
____
<xsl:value-of select="util:carriage-returns(2)"/>
</xsl:template>

<!-- Handling for inline quote elements -->
<xsl:template match="quote" mode="d2a">
  <xsl:text>"</xsl:text><xsl:apply-templates mode="d2a"/><xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="footnote/para" mode="d2a">
<!--Special handling for footnote paras to contract whitespace-->
<xsl:apply-templates select="node()" mode="d2a"/>
</xsl:template>

<xsl:template match="tip|warning|note|caution|important" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
[<xsl:value-of select="upper-case(name())"/>]
<xsl:apply-templates select="." mode="title"/>====
<xsl:apply-templates select="node()[not(self::title)]" mode="d2a"/>====
<!-- <xsl:value-of select="util:carriage-returns(2)"/> -->
</xsl:template>

<!-- BEGIN INLINE MARKUP HANDLING -->
<xsl:template match="emphasis|literal|code|filename|command|superscript|subscript|option|computeroutput|varname|classname|code|envar|constant|function|methodname|package|property|uri" mode="d2a">
  <xsl:variable name="inline_markup">
    <xsl:choose>
      <!-- <xsl:when test="self::emphasis[not(@role)] or self::filename or self::command">__</xsl:when> -->
      <xsl:when test="self::emphasis[not(@role)] or self::filename or self::uri">__</xsl:when>
      <xsl:when test="self::emphasis[@role='bold' or @role='strong']">**</xsl:when>
      <!-- <xsl:when test="self::literal or self::code">++</xsl:when> -->
      <xsl:when test="self::literal or self::code or self::command or self::option or self::computeroutput or self::varname or self::classname or self::code or self::envar or self::constant or self::function or self::methodname or self::package or self::paramater or self::property">++</xsl:when>
      <xsl:when test="self::superscript">^</xsl:when>
      <xsl:when test="self::subscript">~</xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="$inline_markup"/>
    <xsl:apply-templates mode="d2a"/>
  <xsl:value-of select="$inline_markup"/>
</xsl:template>

<xsl:template match="replaceable" mode="d2a">
<xsl:choose>
  <xsl:when test="parent::literal or parent::code or parent::command or parent::option or parent::computeroutput or parent::varname or parent::classname or parent::code or parent::envar or parent::constant or parent::function or parent::methodname or parent::package or parent::paramater or parent::property">__<xsl:apply-templates mode="d2a"/>__</xsl:when>
  <xsl:otherwise>__++<xsl:apply-templates mode="d2a"/>++__</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="phrase" mode="d2a"><xsl:apply-templates mode="d2a"/></xsl:template>

<xsl:template match="userinput" mode="d2a">**`<xsl:apply-templates mode="d2a" />`**</xsl:template>

<xsl:template match="ulink" mode="d2a">link:$$<xsl:value-of select="@url" />$$[<xsl:apply-templates mode="d2a"/>]</xsl:template>

<xsl:template match="email" mode="d2a"><xsl:text>pass:[</xsl:text><xsl:element name="a"><xsl:attribute name="href">mailto:<xsl:value-of select="normalize-space(.)"/></xsl:attribute><xsl:element name="em"><xsl:value-of select="normalize-space(.)"/></xsl:element></xsl:element><xsl:text>]</xsl:text></xsl:template>

<xsl:template match="xref" mode="d2a">&#xE801;&#xE801;<xsl:value-of select="@linkend" />&#xE802;&#xE802;</xsl:template>

<xsl:template match="link" mode="d2a">&#xE801;&#xE801;<xsl:value-of select="@linkend" />,<xsl:value-of select="."/>&#xE802;&#xE802;</xsl:template>
<!-- END INLINE MARKUP HANDLING -->

<xsl:template match="variablelist" mode="d2a">
     <xsl:call-template name="process-id-d2a"/>
     <xsl:for-each select="varlistentry">
       <xsl:apply-templates select="term,listitem" mode="d2a"/><xsl:text>
</xsl:text>
     </xsl:for-each>
</xsl:template>

<xsl:template match="term[position() &lt; last()]" mode="d2a"><xsl:apply-templates select="@*|node()" mode="d2a"/>, </xsl:template>

<xsl:template match="term[position() = last()]" mode="d2a">
  <!-- Handling for nested variablelists -->
  <xsl:choose>
    <xsl:when test=".[count(ancestor::*[name()='variablelist'])=1]">
      <xsl:apply-templates select="@*|node()" mode="d2a"/>:: 
    </xsl:when>
    <xsl:when test=".[count(ancestor::*[name()='variablelist'])=2]">
  <xsl:apply-templates select="@*|node()" mode="d2a"/>;; 
    </xsl:when>
    <xsl:when test=".[count(ancestor::*[name()='variablelist'])=3]">
  <xsl:apply-templates select="@*|node()" mode="d2a"/>::: 
    </xsl:when>
    <xsl:otherwise>
      <!-- No support for more than three levels of variablelists -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="listitem" mode="d2a">
<xsl:apply-templates select="@*|node()" mode="d2a"/>
</xsl:template>

<xsl:template match="itemizedlist" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
<xsl:if test="@spacing">
[options="<xsl:value-of select="@spacing"/>"]
</xsl:if>
<xsl:for-each select="listitem">
* <xsl:apply-templates mode="d2a"/>
</xsl:for-each>
</xsl:template>

<xsl:template match="orderedlist" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
<xsl:if test="@spacing">
[options="<xsl:value-of select="@spacing"/>"]
</xsl:if>
<xsl:for-each select="listitem">
. <xsl:apply-templates mode="d2a"/>
</xsl:for-each>
</xsl:template>

<xsl:template match="simplelist" mode="d2a">
<xsl:if test="@id">
  <xsl:call-template name="process-id-d2a"/>
</xsl:if>
[role="simplelist"]<xsl:for-each select="member">
* <xsl:apply-templates mode="d2a"/>
</xsl:for-each>
<xsl:value-of select="util:carriage-returns(2)"/>
</xsl:template>

<xsl:template match="figure" mode="d2a">
<xsl:if test="ancestor::listitem and preceding-sibling::element()">
<xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
<xsl:call-template name="process-id-d2a"/>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text>.</xsl:text><xsl:apply-templates select="title" mode="d2a"/>
image::<xsl:value-of select="mediaobject/imageobject[@role='web']/imagedata/@fileref"/>[]
<xsl:choose>
  <xsl:when test="ancestor::listitem and following-sibling::element()">
  <xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/>
  </xsl:when>
  <xsl:otherwise><xsl:value-of select="util:carriage-returns(1)"/></xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="informalfigure" mode="d2a">
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:call-template name="process-id-d2a"/>
image::<xsl:value-of select="mediaobject/imageobject[@role='web']/imagedata/@fileref"/>[]
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:template>

<xsl:template match="inlinemediaobject" mode="d2a">image:<xsl:value-of select="imageobject[@role='web']/imagedata/@fileref"/>[]</xsl:template>
  
<xsl:template match="literallayout" mode="d2a">
....
<xsl:apply-templates mode="d2a"/>
....
</xsl:template>

<!-- BEGIN EQUATION HANDLING -->
<xsl:template match="equation" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
<xsl:choose>
  <!-- If nested latex, use the macro -->
  <xsl:when test="mathphrase[@role='tex']">
<xsl:text xml:space="preserve">[latexmath]</xsl:text>
<xsl:choose>
<!-- Set the below parameter to "true" only for DocBook books that have numbered equations but no titles -->
<!-- This will pass through a placeholder title -->
<xsl:when test="$add-equation-titles = 'true'">
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text xml:space="preserve">.FILL IN TITLE</xsl:text>
</xsl:when>
<xsl:otherwise>
.<xsl:apply-templates mode="title"/>
</xsl:otherwise>
</xsl:choose>
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates/>
++++++++++++++++++++++++++++++++++++++
  </xsl:when>
  <!-- If nested docbook or mediaobject, just pass through-->  
  <xsl:otherwise>
<xsl:choose>
<xsl:when test="$add-equation-titles = 'true'">
<xsl:text xml:space="preserve">.FILL IN TITLE</xsl:text>
</xsl:when>
<xsl:otherwise>
.<xsl:apply-templates mode="title"/>
</xsl:otherwise>
</xsl:choose>
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++
  </xsl:otherwise>
</xsl:choose>
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:template>

<xsl:template match="informalequation" mode="d2a">
<xsl:choose>
  <!-- If nested latex, use the macro -->
  <xsl:when test="mathphrase[@role='tex']">
<xsl:text xml:space="preserve">[latexmath]</xsl:text>
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates/>
++++++++++++++++++++++++++++++++++++++
  </xsl:when>
  <!-- If nested docbook or mediaobject, just pass through-->  
  <xsl:otherwise>
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++
  </xsl:otherwise>
</xsl:choose>
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:template>

<xsl:template match="inlineequation" mode="d2a">
  <xsl:choose>
  <xsl:when test="mathphrase[@role='tex']">
latexmath:[<xsl:copy-of select="."/>]
  </xsl:when>
  <xsl:otherwise>
pass:[<xsl:copy-of select="."/>]    
  </xsl:otherwise>
</xsl:choose>
</xsl:template>


<!-- BEGIN CODE BLOCK HANDLING -->
<!-- EXAMPLES -->
<xsl:template match="example" mode="d2a">
<xsl:choose>
<!-- When example code contains callouts -->
<xsl:when test="descendant::co">
<xsl:choose>
<!-- When example code contains other inlines besides callouts, output as passthrough -->
<xsl:when test="descendant::*[*[not(self::co)]]">
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
<!-- When example code is in a different section than corresponding calloutlist, output as passthrough-->
<xsl:when test="parent::node() != */co/id(@linkends)/parent::calloutlist/parent::node()">
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
<!-- When example code contains only callout inlines, output as Asciidoc -->
<xsl:otherwise>
<xsl:call-template name="process-id-d2a"/>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:apply-templates select="." mode="title"/>====
<!-- Preserve non-empty "language" attribute if present -->
<xsl:if test="descendant::programlisting[@language] != '' or descendant::screen[@language] != ''">
<xsl:text>[source, </xsl:text>
<xsl:value-of select="descendant::*/@language"/>
<xsl:text>]</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
<xsl:choose>
<!-- Must format as a [listing block] for proper AsciiDoc processing, if programlisting text contains 4 hyphens in a row -->
<xsl:when test="matches(., '----')">
<xsl:text>[listing]</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text>....</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:apply-templates select="programlisting" mode="code"/>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text>....</xsl:text>
<xsl:choose>
<xsl:when test="ancestor::listitem and preceding-sibling::element()"><xsl:value-of select="util:carriage-returns(1)"/></xsl:when>
<xsl:otherwise><xsl:value-of select="util:carriage-returns(2)"/></xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise><xsl:text>----</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:apply-templates select="programlisting" mode="code"/>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text>----</xsl:text>
<xsl:choose>
<xsl:when test="ancestor::listitem and preceding-sibling::element()"><xsl:value-of select="util:carriage-returns(1)"/></xsl:when>
<xsl:otherwise><xsl:value-of select="util:carriage-returns(2)"/></xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
====

</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- When example code doesn't contain callouts -->
<xsl:otherwise>
<xsl:choose>
<!-- When example code contains inline elements, output as passthrough -->
<xsl:when test="example[descendant::*[*]]">
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
<!-- Otherwise output as Asciidoc -->
<xsl:otherwise>
<xsl:call-template name="process-id-d2a"/>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:apply-templates select="." mode="title"/>====
<!-- Preserve non-empty "language" attribute if present -->
<xsl:if test="descendant::programlisting[@language] != '' or descendant::screen[@language] != ''">
<xsl:text>[source, </xsl:text>
<xsl:value-of select="@language"/>
<xsl:text>]</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
<xsl:choose>
<!-- Must format as a [listing block] for proper AsciiDoc processing, if programlisting text contains 4 hyphens in a row -->
<xsl:when test="matches(., '----')">
<xsl:text>[listing]</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text>....</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:apply-templates select="programlisting" mode="code"/>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text>....</xsl:text>
<xsl:choose>
<xsl:when test="ancestor::listitem and preceding-sibling::element()"><xsl:value-of select="util:carriage-returns(1)"/></xsl:when>
<xsl:otherwise><xsl:value-of select="util:carriage-returns(2)"/></xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<xsl:text>----</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:apply-templates select="programlisting" mode="code"/>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text>----</xsl:text>
<xsl:choose>
<xsl:when test="ancestor::listitem and preceding-sibling::element()"><xsl:value-of select="util:carriage-returns(1)"/></xsl:when>
<xsl:otherwise><xsl:value-of select="util:carriage-returns(2)"/></xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
====

</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- PROGRAMLISTING/SCREEN -->
<xsl:template match="programlisting | screen" mode="d2a">
<xsl:choose>
<!-- Contains child <co> elements -->
<xsl:when test="co">
<xsl:choose>
<!-- Use passthrough when code block contains other child elements besides <co>-->
<xsl:when test="*[not(self::co) and not(indexterm)]">
<xsl:if test="ancestor::listitem and preceding-sibling::element()"><xsl:text>+</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
<!-- Use passthrough when corresponding calloutlist isn't in same section -->
<xsl:when test="self::*/parent::node() != self::*/co/id(@linkends)/parent::calloutlist/parent::node()">
<xsl:if test="ancestor::listitem and preceding-sibling::element()"><xsl:text>+</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
<!-- Use passthrough when code block contains indextermx -->
<xsl:when test="indexterm">
<xsl:if test="ancestor::listitem and preceding-sibling::element()"><xsl:text>+</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
<!-- Otherwise output as Asciidoc -->
<xsl:otherwise>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:if test="ancestor::listitem and preceding-sibling::element()"><xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/></xsl:if>
<!-- Preserve non-empty "language" attribute if present -->
<xsl:if test="@language != ''">
<xsl:text>[source, </xsl:text>
<xsl:value-of select="@language"/>
<xsl:text>]</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
<xsl:choose>
<!-- Must format as a [listing block] for proper AsciiDoc processing, if programlisting text contains 4 hyphens in a row -->
<xsl:when test="matches(., '----')">
<xsl:text>[listing]</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text>....</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:apply-templates mode="code"/>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text>....</xsl:text>
<xsl:choose>
<xsl:when test="ancestor::listitem and preceding-sibling::element()"><xsl:value-of select="util:carriage-returns(1)"/></xsl:when>
<xsl:otherwise><xsl:value-of select="util:carriage-returns(2)"/></xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<xsl:text>----</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:apply-templates mode="code"/>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text>----</xsl:text>
<xsl:choose>
<xsl:when test="ancestor::listitem and preceding-sibling::element()"><xsl:value-of select="util:carriage-returns(1)"/></xsl:when>
<xsl:otherwise><xsl:value-of select="util:carriage-returns(2)"/></xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- No child co elements -->
<xsl:otherwise>
<xsl:choose>
<!-- Use passthrough when code block has inlines -->
<xsl:when test="*[not(self::indexterm)]">
<xsl:if test="ancestor::listitem and preceding-sibling::element()">
<xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
<!-- Use passthrough when code block contains indexterms -->
<xsl:when test="indexterm">
<xsl:if test="ancestor::listitem and preceding-sibling::element()"><xsl:text>+</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
<!-- Output Asciidoc -->
<xsl:otherwise>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:if test="ancestor::listitem and preceding-sibling::element()"><xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/></xsl:if>
<!-- Preserve non-empty "language" attribute if present -->
<xsl:if test="@language != ''">
<xsl:text>[source, </xsl:text>
<xsl:value-of select="@language"/>
<xsl:text>]</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
<xsl:choose>
<!-- Must format as a [listing block] for proper AsciiDoc processing, if programlisting text contains 4 hyphens in a row -->
<xsl:when test="matches(., '----')">
<xsl:text>[listing]</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text>....</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:apply-templates mode="code"/>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text>....</xsl:text>
<xsl:choose>
<xsl:when test="ancestor::listitem and preceding-sibling::element()"><xsl:value-of select="util:carriage-returns(1)"/></xsl:when>
<xsl:otherwise><xsl:value-of select="util:carriage-returns(2)"/></xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<xsl:text>----</xsl:text>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:apply-templates mode="code"/>
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:text>----</xsl:text>
<xsl:choose>
<xsl:when test="ancestor::listitem and preceding-sibling::element()"><xsl:value-of select="util:carriage-returns(1)"/></xsl:when>
<xsl:otherwise><xsl:value-of select="util:carriage-returns(2)"/></xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- <co> element -->
<xsl:template match="co" mode="code"><xsl:variable name="curr" select="@id"/>&#xE801;<xsl:value-of select="count(//calloutlist/callout[@arearefs=$curr]/preceding-sibling::callout)+1"/>&#xE802;</xsl:template>

<!-- Calloutlist -->
<xsl:template match="calloutlist" mode="d2a">
<xsl:choose>
<!-- Calloutlist points to an example -->
<xsl:when test="callout/id(@arearefs)/ancestor::example">
<xsl:choose>
<!-- When corresponding code block has inlines (besides co) and will be output as passthrough,
also output calloutlist as passthrough-->
<xsl:when test="callout/id(@arearefs)/parent::*[*[not(self::co)]]">
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
<!-- When corresponding code block isn't in same section as calloutlist and will be output as passthrough,
also output calloutlist as passthrough.-->
<xsl:when test="callout/id(@arearefs)/parent::*/parent::example/parent::node() != self::calloutlist/parent::node()">
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
<!-- Otherwise output as Asciidoc -->
<xsl:otherwise>
<xsl:for-each select="callout">
&#xE801;<xsl:value-of select="position()"/>&#xE802; <xsl:apply-templates mode="d2a"/></xsl:for-each>
<xsl:if test="calloutlist">
<xsl:copy-of select="."/>
</xsl:if>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- Calloutlist points to a regular code block (not example) -->
<xsl:otherwise>
<xsl:choose>
<!-- When corresponding code block has inlines (besides co) and will be output as passthrough,
also output calloutlist as passthrough-->
<xsl:when test="callout/id(@arearefs)/parent::*[*[not(self::co)]]">
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
<!-- When corresponding code block isn't in same section as calloutlist and will be output as passthrough,
also output calloutlist as passthrough.-->
<xsl:when test="callout/id(@arearefs)/parent::*/parent::node() != self::calloutlist/parent::node()">
++++++++++++++++++++++++++++++++++++++
<xsl:apply-templates select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
<!-- Otherwise output as Asciidoc -->
<xsl:otherwise>
<xsl:for-each select="callout">
&#xE801;<xsl:value-of select="position()"/>&#xE802; <xsl:apply-templates mode="d2a"/></xsl:for-each>
<xsl:if test="calloutlist">
<xsl:copy-of select="."/>
</xsl:if>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- END CODE BLOCK HANDLING -->

<xsl:template match="table|informaltable" mode="d2a">
<xsl:if test="ancestor::listitem and preceding-sibling::element()"><xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/></xsl:if>
<xsl:call-template name="process-id-d2a"/>
<xsl:if test="descendant::title"><xsl:value-of select="util:carriage-returns(1)"/><xsl:apply-templates select="." mode="title"/></xsl:if>
<xsl:if test="descendant::thead"><xsl:text>[options="header"]</xsl:text></xsl:if>
|===============
<xsl:apply-templates select="descendant::row" mode="d2a"/>
|===============
<xsl:choose>
<xsl:when test="ancestor::listitem and following-sibling::element()"/>
<xsl:otherwise><xsl:value-of select="util:carriage-returns(1)"/></xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="row" mode="d2a">
  <xsl:for-each select="entry">
    <xsl:text>|</xsl:text>
    <xsl:apply-templates select="." mode="d2a"/>
  </xsl:for-each>
    <xsl:if test="not(entry/para)">
      <xsl:value-of select="util:carriage-returns(1)"/>
    </xsl:if>
</xsl:template>

<xsl:template match="entry[not(node()) and not(following-sibling::entry)]" mode="d2a">
<xsl:if test="ancestor::row[following-sibling::row]">
  <xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
</xsl:template>

<xsl:template match="entry/para|entry/simpara" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
<xsl:apply-templates select="node()" mode="d2a"/>
<xsl:choose>
<xsl:when test="following-sibling::para|following-sibling::simpara">
  <!-- Two carriage returns if para has following para siblings in the same entry -->
  <xsl:value-of select="util:carriage-returns(2)"/>
</xsl:when>
<xsl:when test="parent::entry[not(following-sibling::entry)] and (ancestor::row[following-sibling::row] or ancestor::thead)">
  <!-- One carriage return if last para in last entry in row -->
  <xsl:value-of select="util:carriage-returns(1)"/>
</xsl:when>
</xsl:choose>
</xsl:template>

<xsl:template match="sidebar" mode="d2a">
<xsl:call-template name="process-id-d2a"/>
.<xsl:apply-templates select="title" mode="d2a"/>
****
<xsl:apply-templates select="*[not(self::title)]" mode="d2a"/>
****
<xsl:value-of select="util:carriage-returns(2)"/>
</xsl:template>

<xsl:template match="footnote" mode="d2a">
  <!-- When footnote has @id, output as footnoteref with @id value, 
       in case there are any corresponding footnoteref elements -->
  <xsl:choose>
    <xsl:when test="@id">
      <xsl:text>footnoteref:[</xsl:text>
      <xsl:value-of select="@id"/><xsl:text>,</xsl:text>
      <xsl:apply-templates mode="d2a"/>
      <xsl:text>]</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>footnote:[</xsl:text>
      <xsl:apply-templates mode="d2a"/>
      <xsl:text>]</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<xsl:template match="footnoteref" mode="d2a">
  <xsl:text>footnoteref:[</xsl:text><xsl:value-of select="@linkend"/><xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="section" mode="d2a">
  <xsl:call-template name="process-id-d2a"/>
  <xsl:sequence select="string-join (('&#10;&#10;', for $i in (1 to count (ancestor::section) + 3) return '='),'')"/>
  <xsl:apply-templates select="title" mode="d2a"/>
  <xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]" mode="d2a"/>
</xsl:template>

<!-- Utility functions/templates -->
<xsl:function name="util:carriage-returns">
  <xsl:param name="n"/>
  <xsl:value-of select="string-join(for $i in (1 to $n) return '&#10;', '')"/>
</xsl:function>

<xsl:template name="strip-whitespace">
  <!-- Assumption is that $text-to-strip will be a text() node --> 
  <xsl:param name="text-to-strip" select="."/>
  <!-- By default, don't strip any whitespace -->
  <xsl:param name="leading-whitespace"/>
  <xsl:param name="trailing-whitespace"/>
  <xsl:choose>
    <xsl:when test="($leading-whitespace = 'strip') and ($trailing-whitespace = 'strip')">
      <xsl:value-of select="replace(replace(., '^\s+', '', 'm'), '\s+$', '', 'm')"/>
    </xsl:when>
    <xsl:when test="$leading-whitespace = 'strip'">
      <xsl:value-of select="replace(., '^\s+', '', 'm')"/>
    </xsl:when>
    <xsl:when test="$trailing-whitespace = 'strip'">
      <xsl:value-of select="replace(., '\s+$', '', 'm')"/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template name="process-id-d2a">
  <xsl:if test="@id">
    <xsl:text xml:space="preserve">[[</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text xml:space="preserve">]]</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="title">
  <xsl:if test="title">
    <xsl:text>.</xsl:text>
    <xsl:apply-templates select="title" mode="d2a"/>
    <xsl:value-of select="util:carriage-returns(1)"/>
  </xsl:if>
</xsl:template>

<xsl:template match="@*|node()" mode="copy-and-drop-indexterms">
   <xsl:copy>
     <xsl:apply-templates select="@*|node()" mode="copy-and-drop-indexterms"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="indexterm" mode="copy-and-drop-indexterms"/>

</xsl:stylesheet>