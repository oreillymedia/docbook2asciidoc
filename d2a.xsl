<xsl:stylesheet version="2.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:util="http://github.com/oreillymedia/docbook2asciidoc/"
 exclude-result-prefixes="util"
 >
  
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
<xsl:param name="chunk-output">false</xsl:param>
<xsl:param name="bookinfo-doc-name">book-docinfo.xml</xsl:param>
<xsl:param name="strip-indexterms">false</xsl:param>
<xsl:param name="glossary-passthrough">false</xsl:param>
<xsl:param name="add-equation-titles">false</xsl:param>

<xsl:preserve-space elements="*"/>
<xsl:strip-space elements="table row entry tgroup thead"/>

<xsl:template match="/book">
  <xsl:choose>
    <xsl:when test="title">
      <xsl:apply-templates select="title"/>
    </xsl:when>
    <xsl:when test="bookinfo/title">
      <xsl:apply-templates select="bookinfo/title"/>
    </xsl:when>
  </xsl:choose>
  <xsl:choose>
    <xsl:when test="$chunk-output != 'false'">
      <xsl:apply-templates select="*[not(self::title)]" mode="chunk"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="*[not(self::title)]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<xsl:template match="//comment()">

++++++++++++++++++++++++++++++++++++++
<xsl:copy/>
++++++++++++++++++++++++++++++++++++++
    
</xsl:template>
  
<xsl:template match="remark">
++++++++++++++++++++++++++++++++++++++
<xsl:copy-of select="."/>
++++++++++++++++++++++++++++++++++++++
    
</xsl:template>

<xsl:template match="processing-instruction()">
<xsl:text>+++</xsl:text>
<xsl:copy-of select="."/>
<xsl:text>+++</xsl:text>
</xsl:template>

<xsl:template match="book/title|bookinfo/title">
  <xsl:text>= </xsl:text>
  <xsl:value-of select="."/>
  <xsl:value-of select="util:carriage-returns(2)"/>
</xsl:template>

<xsl:template match="part" mode="chunk">
  <!-- Only bother chunking parts into a separate file if there's actually partintro content -->
  <xsl:variable name="part_content">
    <!-- Title and partintro (if present) -->
    <xsl:call-template name="process-id"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:text xml:space="preserve">= </xsl:text>
    <xsl:apply-templates select="title"/>
    <xsl:value-of select="util:carriage-returns(2)"/>
    <xsl:apply-templates select="partintro" mode="#default"/>
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
    <xsl:apply-templates select="." mode="#default"/>
  </xsl:result-document>
</xsl:template>

<!-- BEGIN INDEX HANDLING --> 
  <!-- If keeping index, create index.asciidoc file, add include to book.asciidoc file -->
  <xsl:template match="index" mode="chunk">
    <xsl:choose>
      <xsl:when test="$strip-indexterms = 'true'"/>
      <xsl:otherwise>
        <xsl:value-of select="util:carriage-returns(2)"/>
        <xsl:text>include::index.asciidoc[]</xsl:text>
        <xsl:result-document href="index.asciidoc">
          <xsl:apply-templates select="." mode="#default"/>
        </xsl:result-document>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- If keeping index, output heading markup in index file -->
  <xsl:template match="index">
    <xsl:choose>
      <xsl:when test="$strip-indexterms = 'true'"/>
      <!-- Index should be at main level when book has parts. -->
      <xsl:when test="$strip-indexterms= 'false' and preceding::part">
        <xsl:text>= Index</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>== Index</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Handling for in-text index markup -->
  <!-- Specific handling for indexterms in emphasis elements, to override emphasis template that was ignoring indexterms -->
  <xsl:template match="indexterm | indexterm[parent::emphasis]">
    <xsl:choose>
      <xsl:when test="$strip-indexterms = 'true'"/>
      <xsl:otherwise><xsl:text>(((</xsl:text><xsl:apply-templates/><xsl:text>)))</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="indexterm[@class='startofrange'][not(*/@sortas)] | indexterm[@class='startofrange'][parent::emphasis][not(*/@sortas)]">
    <xsl:choose>
      <xsl:when test="$strip-indexterms = 'true'"/>
      <xsl:otherwise><xsl:text>(((</xsl:text><xsl:apply-templates/><xsl:text>, id="</xsl:text><xsl:value-of select="@id"/><xsl:text>", range="startofrange")))</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="indexterm[*/@sortas][not(@class='startofrange')] | indexterm[*/@sortas][parent::emphasis][not(@class='startofrange')]">
    <xsl:choose>
      <xsl:when test="$strip-indexterms = 'true'"/>
      <!-- Output indexterms with @sortas and both primary and secondary indexterms as docbook passthroughs. Not supported in Asciidoc markup. -->
      <xsl:when test="$strip-indexterms = 'false' and secondary"><xsl:text>pass:[</xsl:text><xsl:copy-of select="."/><xsl:text>]</xsl:text></xsl:when>
      <!-- When only primary term exists, output as asciidoc -->
      <xsl:otherwise><xsl:text>(((</xsl:text><xsl:apply-templates/><xsl:text>, sortas="</xsl:text><xsl:value-of select="primary/@sortas"/><xsl:text>")))</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Output indexterms with both @sortas and @startofrange as docbook passthroughs. Not supported in Asciidoc markup. -->
  <xsl:template match="indexterm[@class='startofrange' and */@sortas]">
    <xsl:choose>
      <xsl:when test="$strip-indexterms = 'true'"/>
      <xsl:otherwise><xsl:text>pass:[</xsl:text><xsl:copy-of select="."/><xsl:text>]</xsl:text></xsl:otherwise>
    </xsl:choose>  
  </xsl:template>
  
  <xsl:template match="indexterm[@class='endofrange'] | indexterm[@class='endofrange'][parent::emphasis]">
    <xsl:choose>
      <xsl:when test="$strip-indexterms = 'true'"/>
      <xsl:otherwise><xsl:text>(((range="endofrange", startref="</xsl:text><xsl:value-of select="@startref"/><xsl:text>")))</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="indexterm/primary | indexterm/primary[parent::emphasis]">
    <xsl:choose>
      <xsl:when test="$strip-indexterms = 'true'"/>
      <xsl:otherwise><xsl:text>"</xsl:text><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:apply-templates/><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:text>"</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="indexterm/secondary | indexterm/secondary[parent::emphasis]">
    <xsl:choose>
      <xsl:when test="$strip-indexterms = 'true'"/>
      <xsl:otherwise><xsl:text>, "</xsl:text><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:apply-templates/><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:text>"</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="indexterm/tertiary | indexterm/tertiary[parent::emphasis]">
    <xsl:choose>
      <xsl:when test="$strip-indexterms = 'true'"/>
      <xsl:otherwise><xsl:text>, "</xsl:text><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:apply-templates/><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:text>"</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="indexterm/see | indexterm/see[parent::emphasis]">
    <xsl:choose>
      <xsl:when test="$strip-indexterms = 'true'"/>
      <xsl:otherwise><xsl:text>, see="</xsl:text><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:apply-templates/><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:text>"</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="indexterm/seealso | indexterm/seealso[parent::emphasis]">
    <xsl:choose>
      <xsl:when test="$strip-indexterms = 'true'"/>
      <xsl:otherwise><xsl:text>, seealso="</xsl:text><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:apply-templates/><xsl:if test="contains(., '+') or contains(., '_') or contains(., '#')">$$</xsl:if><xsl:text>"</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
<!-- END INDEX HANDLING -->

<!-- Special handling for text inside code block that will be converted as Asciidoc, 
      to make sure special characters are not escaped.-->
<xsl:template match="text()" mode="code">
  <xsl:value-of select=".[not(parent::title)]" disable-output-escaping="yes"></xsl:value-of>
</xsl:template>

<xsl:template match="phrase/text()"><xsl:text/><xsl:value-of select="replace(., '\n\s+', ' ', 'm')"/><xsl:text/></xsl:template>

<xsl:template match="ulink/text()">
<xsl:value-of select="replace(., '\n\s+', ' ', 'm')"/>
</xsl:template>

<xsl:template match="title/text()">
<xsl:value-of select="replace(., '\n\s+', ' ', 'm')"/>
</xsl:template>

<!-- Strip leading whitespace from first text node in <term>, if it does not have preceding element siblings --> 
<xsl:template match="term[count(element()) != 0]/text()[1][not(preceding-sibling::element())]">
  <xsl:call-template name="strip-whitespace">
    <xsl:with-param name="text-to-strip" select="."/>
    <xsl:with-param name="leading-whitespace" select="'strip'"/>
  </xsl:call-template>
</xsl:template>

<!-- Strip trailing whitespace from last text node in <term>, if it does not have following element siblings --> 
<xsl:template match="term[count(element()) != 0]/text()[not(position() = 1)][last()][not(following-sibling::element())]">
  <xsl:call-template name="strip-whitespace">
    <xsl:with-param name="text-to-strip" select="."/>
    <xsl:with-param name="trailing-whitespace" select="'strip'"/>
  </xsl:call-template>
</xsl:template>

<!-- If term has just one text node (no element children), just normalize space in it -->
<xsl:template match="term[count(element()) = 0]/text()">
  <xsl:value-of select="normalize-space(.)"/>
</xsl:template>

<!-- Text nodes in <term> that are between elements that contain only whitespace should be normalized to one space -->
<xsl:template match="term/text()[not(position() = 1)][not(position() = last())][matches(., '^[\s\n]+$', 'm')]">
  <xsl:value-of select="replace(., '^[\s\n]+$', ' ', 'm')"/>
</xsl:template>

<xsl:template match="member/text()">
<xsl:value-of select="replace(., '^\s+', '', 'm')"/>
</xsl:template>

<!-- Normalize space in indexterms -->
<xsl:template match="indexterm//text()">
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

<xsl:template match="part">
<xsl:call-template name="process-id"/>
= <xsl:apply-templates select="title"/>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="partintro">
<xsl:call-template name="process-id"/>
[partintro]
<xsl:apply-templates select="." mode="title"/>
--
<xsl:apply-templates select="*[not(self::title)]"/>
--
</xsl:template>
  
<xsl:template match="chapter">
<xsl:call-template name="process-id"/>
== <xsl:apply-templates select="title"/>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template> 

<xsl:template match="appendix">
<xsl:call-template name="process-id"/>
[appendix]
== <xsl:apply-templates select="title"/>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="prefaceinfo"/>

<xsl:template match="preface">
<xsl:call-template name="process-id"/>
<xsl:text>[preface]
</xsl:text>

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

<xsl:text>
== </xsl:text><xsl:value-of select="title"/>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="sect1">
  <!-- If sect1 title is "References," override special Asciidoc section macro -->
<xsl:if test="title = 'References'">
  <xsl:text>[sect2]</xsl:text>
  <xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
<xsl:call-template name="process-id"/>
=== <xsl:apply-templates select="title"/>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="sect2">
<xsl:call-template name="process-id"/>
==== <xsl:apply-templates select="title"/>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="sect3">
<xsl:call-template name="process-id"/>
===== <xsl:apply-templates select="title"/>
<xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<!-- Use passthrough for sect4 and sect5, as there is no AsciiDoc markup/formatting for these -->
<xsl:template match="sect4|sect5">
++++++++++++++++++++++++++++++++++++++
<xsl:choose>
  <xsl:when test="$strip-indexterms='false'">
    <xsl:copy-of select="."/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="copy-and-drop-indexterms"/>
    </xsl:copy>
  </xsl:otherwise>
</xsl:choose>
++++++++++++++++++++++++++++++++++++++
</xsl:template>

<!-- Use passthrough for bibliography -->
<xsl:template match="bibliography">
++++++++++++++++++++++++++++++++++++++
<xsl:choose>
  <xsl:when test="$strip-indexterms='false'">
    <xsl:copy-of select="."/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="copy-and-drop-indexterms"/>
    </xsl:copy>
  </xsl:otherwise>
</xsl:choose>
++++++++++++++++++++++++++++++++++++++
</xsl:template>

<!-- Use passthrough for reference sections -->
<xsl:template match="refentry">
++++++++++++++++++++++++++++++++++++++
<xsl:choose>
  <xsl:when test="$strip-indexterms='false'">
    <xsl:copy-of select="."/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="copy-and-drop-indexterms"/>
    </xsl:copy>
  </xsl:otherwise>
</xsl:choose>
++++++++++++++++++++++++++++++++++++++
</xsl:template>

<!-- Begin handling for glossary -->
<xsl:template match="glossary">
  <xsl:choose>
    <xsl:when test="$glossary-passthrough != 'false'">
<xsl:call-template name="process-id"/>
<xsl:text>[glossary]
== Glossary

</xsl:text>
++++++++++++++++++++++++++++++++++++++
<xsl:choose>
  <xsl:when test="$strip-indexterms='false'">
    <xsl:copy-of select="*[not(local-name() = 'title')]"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="*[not(self::title)]" mode="copy-and-drop-indexterms"/>
  </xsl:otherwise>
</xsl:choose>
++++++++++++++++++++++++++++++++++++++
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="process-id"/>== <xsl:value-of select="title"/><xsl:value-of select="util:carriage-returns(2)"/>[glossary]<xsl:value-of select="util:carriage-returns(1)"/><xsl:apply-templates select="*[not(self::title)]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<xsl:template match="glossentry">
  <xsl:call-template name="process-id"/>
  <xsl:apply-templates select="glossterm"/><xsl:text>::&#10;</xsl:text><xsl:text>   </xsl:text><xsl:apply-templates select="glossdef"/>
</xsl:template>

<!-- Output glossary "See Also"s as hardcoded text. Asc to DB toolchain does not 
    currently retain any @id attrbutes for glossentry elements. -->
<xsl:template match="glossseealso">
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
  
<xsl:template match="colophon">
<xsl:call-template name="process-id"/>
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
    <xsl:when test="para/text()"><xsl:apply-templates select="*[not(self::title)]"/></xsl:when>
    <xsl:otherwise><xsl:text>(FILL IN)</xsl:text></xsl:otherwise>
  </xsl:choose>
  
</xsl:template>
  
  <xsl:template match="dedication">
    <xsl:call-template name="process-id"/>
    <xsl:text>[dedication]</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>== Dedication</xsl:text>
    <xsl:value-of select="util:carriage-returns(2)"/>
    <xsl:apply-templates select="node()[not(self::title)]"/>
  </xsl:template>
  
<xsl:template match="para|simpara">
  <xsl:choose>
    <xsl:when test="ancestor::callout"/>
    <xsl:otherwise>
      <xsl:call-template name="process-id"/>
    </xsl:otherwise>
  </xsl:choose>
  <!-- If it's the 2nd+ para inside a listitem, glossdef, or callout (but not a nested admonition or sidebar), precede it with a plus symbol -->
<xsl:if test="ancestor::listitem and preceding-sibling::element()">
  <xsl:choose>
  <xsl:when test="not(ancestor::warning|ancestor::note|ancestor::caution|ancestor::tip|ancestor::important) and not(ancestor::sidebar)">
    <xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="util:carriage-returns(1)"/>
  </xsl:otherwise>
</xsl:choose>
</xsl:if>
<xsl:if test="ancestor::glossdef and preceding-sibling::element()">
  <xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
<xsl:if test="ancestor::callout and preceding-sibling::element()">
  <xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
<xsl:apply-templates select="node()"/>
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

<xsl:template match="formalpara">
<xsl:call-template name="process-id"/>
<!-- Put formalpara <title> in bold (drop any inline formatting) -->
<xsl:text>*</xsl:text>
<xsl:value-of select="title"/>
<xsl:text>* </xsl:text>
<xsl:apply-templates select="node()[not(self::title)]"/>
<xsl:value-of select="util:carriage-returns(2)"/>
</xsl:template>

<!-- Same handling for blockquote and epigraph; convert to AsciiDoc quote block -->
<xsl:template match="blockquote|epigraph">
<xsl:call-template name="process-id"/>
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
<xsl:apply-templates select="node()[not(self::title or self::attribution)]"/>
____
<xsl:value-of select="util:carriage-returns(2)"/>
</xsl:template>

<!-- Handling for inline quote elements -->
<xsl:template match="quote">
  <xsl:text>"</xsl:text><xsl:apply-templates/><xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="entry/para|entry/simpara">
<xsl:call-template name="process-id"/>
<xsl:apply-templates select="node()"/>
<xsl:choose>
<xsl:when test="following-sibling::para|following-sibling::simpara">
  <!-- Two carriage returns if para has following para siblings in the same entry -->
  <xsl:value-of select="util:carriage-returns(2)"/>
</xsl:when>
<xsl:when test="parent::entry[not(following-sibling::entry)]">
  <!-- One carriage return if last para in last entry in row -->
  <xsl:value-of select="util:carriage-returns(1)"/>
</xsl:when>
</xsl:choose>
</xsl:template>

<xsl:template match="footnote/para">
<!--Special handling for footnote paras to contract whitespace-->
<xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="tip|warning|note|caution|important">
<xsl:call-template name="process-id"/>
[<xsl:value-of select="upper-case(name())"/>]
<xsl:apply-templates select="." mode="title"/>====
<xsl:apply-templates select="node()[not(self::title)]"/>====
<xsl:value-of select="util:carriage-returns(2)"/>
</xsl:template>

<xsl:template match="term"><xsl:apply-templates select="node()"/>:: </xsl:template>

<xsl:template match="listitem">
<xsl:apply-templates select="node()"/>
</xsl:template>

<!-- BEGIN INLINE MARKUP HANDLING -->
<xsl:template match="phrase"><xsl:apply-templates /></xsl:template>

<xsl:template match="emphasis[@role='bold']|emphasis[@role='strong']">**<xsl:apply-templates />**</xsl:template>

  <xsl:template match="filename">__<xsl:if test="contains(., '~') or contains(., '_')">$$</xsl:if><xsl:apply-templates/><xsl:if test="contains(., '~') or contains(., '_')">$$</xsl:if>__</xsl:template>
  <!-- Normalize-space() on text node below includes extra handling for child elements of filename, to add needed spaces back in. (They're removed by normalize-space(), which normalizes the two text nodes separately.) -->
  <xsl:template match="filename/text()">
    <xsl:if test="preceding-sibling::* and (starts-with(.,' ') or starts-with(.,'&#10;'))">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(replace(., '([\+])', '\\$1', 'm'))"/>
    <xsl:if test="following-sibling::* and (substring(.,string-length(.))=' ' or substring(.,string-length(.))='&#10;')">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="emphasis">__<xsl:if test="contains(., '~') or contains(., '_')">$$</xsl:if><xsl:apply-templates/><xsl:if test="contains(., '~') or contains(., '_')">$$</xsl:if>__</xsl:template>
  <!-- Normalize-space() on text node below includes extra handling for child elements of emphasis, to add needed spaces back in. (They're removed by normalize-space(), which normalizes the two text nodes separately.) -->
  <xsl:template match="emphasis/text()">
    <xsl:if test="preceding-sibling::* and (starts-with(.,' ') or starts-with(.,'&#10;'))">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="following-sibling::* and (substring(.,string-length(.))=' ' or substring(.,string-length(.))='&#10;')">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="command">__<xsl:if test="contains(., '~') or contains(., '_')">$$</xsl:if><xsl:apply-templates/><xsl:if test="contains(., '~') or contains(., '_')">$$</xsl:if>__</xsl:template>
  <!-- Normalize-space() on text node below includes extra handling for child elements of command, to add needed spaces back in. (They're removed by normalize-space(), which normalizes the two text nodes separately.) -->
  <xsl:template match="command/text()">
    <xsl:if test="preceding-sibling::* and (starts-with(.,' ') or starts-with(.,'&#10;'))">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(replace(., '([\+])', '\\$1', 'm'))"/>
    <xsl:if test="following-sibling::* and (substring(.,string-length(.))=' ' or substring(.,string-length(.))='&#10;')">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="literal | code">++<xsl:if test='contains(., "+") or contains(., "&apos;") or contains(., "_")'>$$</xsl:if><xsl:apply-templates/><xsl:if test='contains(., "+") or contains(., "&apos;") or contains(., "_")'>$$</xsl:if>++</xsl:template>

  <xsl:template match="literal/text()"><xsl:value-of select="replace(replace(replace(., '\n\s+', ' ', 'm'), 'C\+\+', '\$\$C++\$\$', 'm'), '([\[\]\*\^~])', '\\$1', 'm')"></xsl:value-of></xsl:template>
  
<xsl:template match="userinput">**`<xsl:apply-templates />`**</xsl:template>
  <!-- Normalize-space() on text node below includes extra handling for child elements of userinput, to add needed spaces back in. (They're removed by normalize-space(), which normalizes the two text nodes separately.) -->
  <xsl:template match="userinput/text()">
    <xsl:if test="preceding-sibling::* and (starts-with(.,' ') or starts-with(.,'&#10;'))">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="following-sibling::* and (substring(.,string-length(.))=' ' or substring(.,string-length(.))='&#10;')">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

<xsl:template match="replaceable"><xsl:choose>
  <xsl:when test="parent::literal">__<xsl:apply-templates />__</xsl:when>
  <xsl:otherwise>__++<xsl:apply-templates />++__</xsl:otherwise>
</xsl:choose></xsl:template>
  <!-- Normalize-space() on text node below includes extra handling for child elements of replaceable, to add needed spaces back in. (They're removed by normalize-space(), which normalizes the two text nodes separately.) -->
  <xsl:template match="replaceable/text()">
    <xsl:if test="preceding-sibling::* and (starts-with(.,' ') or starts-with(.,'&#10;'))">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="following-sibling::* and (substring(.,string-length(.))=' ' or substring(.,string-length(.))='&#10;')">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
<xsl:template match="superscript">^<xsl:apply-templates />^</xsl:template>
  <!-- Normalize-space() on text node below includes extra handling for child elements of superscript, to add needed spaces back in. (They're removed by normalize-space(), which normalizes the two text nodes separately.) -->
  <xsl:template match="superscript/text()">
    <xsl:if test="preceding-sibling::* and (starts-with(.,' ') or starts-with(.,'&#10;'))">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="following-sibling::* and (substring(.,string-length(.))=' ' or substring(.,string-length(.))='&#10;')">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

<xsl:template match="subscript">~<xsl:apply-templates />~</xsl:template>
  <!-- Normalize-space() on text node below includes extra handling for child elements of subscript, to add needed spaces back in. (They're removed by normalize-space(), which normalizes the two text nodes separately.) -->
  <xsl:template match="subscript/text()">
    <xsl:if test="preceding-sibling::* and (starts-with(.,' ') or starts-with(.,'&#10;'))">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="following-sibling::* and (substring(.,string-length(.))=' ' or substring(.,string-length(.))='&#10;')">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

<xsl:template match="ulink">link:$$<xsl:value-of select="@url" />$$[<xsl:apply-templates/>]</xsl:template>

  <xsl:template match="email"><xsl:text>pass:[</xsl:text><xsl:element name="email"><xsl:value-of select="normalize-space(.)"/></xsl:element><xsl:text>]</xsl:text></xsl:template>

<xsl:template match="xref">&#xE801;&#xE801;<xsl:value-of select="@linkend" />&#xE802;&#xE802;</xsl:template>

<xsl:template match="link">&#xE801;&#xE801;<xsl:value-of select="@linkend" />,<xsl:value-of select="."/>&#xE802;&#xE802;</xsl:template>
<!-- END INLINE MARKUP HANDLING -->

<xsl:template match="variablelist">
  <xsl:choose>
    <!-- When variablelist has a varlistentry with more than one term, or a nested variablelist, output as passthrough -->
    <xsl:when test="./varlistentry/term[2] | .//variablelist">
      <xsl:text>
++++
</xsl:text>
  <xsl:choose>
    <xsl:when test="$strip-indexterms='false'">
      <xsl:copy-of select="."/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="copy-and-drop-indexterms"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>
++++</xsl:text>
      <xsl:value-of select="util:carriage-returns(2)"/>
    </xsl:when>
   <xsl:otherwise>
     <xsl:call-template name="process-id"/>
     <xsl:for-each select="varlistentry">
       <xsl:apply-templates select="term,listitem"/>
     </xsl:for-each>
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="itemizedlist">
<xsl:call-template name="process-id"/>
<xsl:if test="@spacing">
[options="<xsl:value-of select="@spacing"/>"]
</xsl:if>
<xsl:for-each select="listitem">
* <xsl:apply-templates/>
</xsl:for-each>
</xsl:template>

<xsl:template match="orderedlist">
<xsl:call-template name="process-id"/>
<xsl:if test="@spacing">
[options="<xsl:value-of select="@spacing"/>"]
</xsl:if>
<xsl:for-each select="listitem">
. <xsl:apply-templates/>
</xsl:for-each>
</xsl:template>

<xsl:template match="simplelist">
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:call-template name="process-id"/>
<xsl:for-each select="member">
<xsl:apply-templates/><xsl:if test="position() &lt; last()"> +
</xsl:if>
</xsl:for-each>
<xsl:value-of select="util:carriage-returns(2)"/>
</xsl:template>

<xsl:template match="figure">
<xsl:if test="ancestor::listitem and preceding-sibling::element()">
  <xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/>
</xsl:if>
<xsl:call-template name="process-id"/>
<xsl:text>.</xsl:text><xsl:apply-templates select="title"/>
image::<xsl:value-of select="mediaobject/imageobject[@role='web']/imagedata/@fileref"/>[]
<xsl:choose>
  <xsl:when test="ancestor::listitem and following-sibling::element()"/>
  <xsl:otherwise><xsl:value-of select="util:carriage-returns(1)"/></xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="informalfigure">
<xsl:value-of select="util:carriage-returns(1)"/>
<xsl:call-template name="process-id"/>
image::<xsl:value-of select="mediaobject/imageobject[@role='web']/imagedata/@fileref"/>[]
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:template>

<xsl:template match="inlinemediaobject">image:<xsl:value-of select="imageobject[@role='web']/imagedata/@fileref"/>[]</xsl:template>
  
<xsl:template match="literallayout">
....
<xsl:apply-templates/>
....
</xsl:template>

<!-- BEGIN EQUATION HANDLING -->
<xsl:template match="equation">
<xsl:call-template name="process-id"/>
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
<xsl:copy-of select="."/>
++++++++++++++++++++++++++++++++++++++
  </xsl:otherwise>
</xsl:choose>
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:template>

<xsl:template match="informalequation">
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
<xsl:copy-of select="."/>
++++++++++++++++++++++++++++++++++++++
  </xsl:otherwise>
</xsl:choose>
<xsl:value-of select="util:carriage-returns(1)"/>
</xsl:template>

<xsl:template match="inlineequation">
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

  <xsl:template match="example">
    <xsl:choose>
      <!-- When example code contains callouts -->
      <xsl:when test="//co">
        <xsl:choose>
          <!-- When example code contains other inlines besides callouts, output as Docbook passthrough -->
          <xsl:when test="descendant::*[*[not(self::co)]]">
++++++++++++++++++++++++++++++++++++++
<xsl:choose>
  <xsl:when test="$strip-indexterms='false'">
    <xsl:copy-of select="."/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="copy-and-drop-indexterms"/>
    </xsl:copy>
  </xsl:otherwise>
</xsl:choose>
++++++++++++++++++++++++++++++++++++++
            
</xsl:when>
          <!-- When example code is in a different section than corresponding calloutlist,
                          output as Docbook passthrough-->
          <xsl:when test="parent::node() != */co/id(@linkends)/parent::calloutlist/parent::node()">
++++++++++++++++++++++++++++++++++++++
<xsl:choose>
  <xsl:when test="$strip-indexterms='false'">
    <xsl:copy-of select="."/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="copy-and-drop-indexterms"/>
    </xsl:copy>
  </xsl:otherwise>
</xsl:choose>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
          <!-- When example code contains only callout inlines, output as Asciidoc -->
          <xsl:otherwise>
            <xsl:call-template name="process-id"/>
            <xsl:apply-templates select="." mode="title"/>====
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
                <!-- This apply-templates calls on special "code" mode templates for text() and <co> elements.
          Allows disable-output-escaping to be used on text(), while still using apply-templates to
          process child <co> elements. -->
                <xsl:apply-templates mode="code"/>
                <xsl:value-of select="util:carriage-returns(1)"/>
                <xsl:text>....</xsl:text>
                <xsl:choose>
                  <xsl:when test="ancestor::listitem and preceding-sibling::element()"><xsl:value-of select="util:carriage-returns(1)"/></xsl:when>
                  <xsl:otherwise><xsl:value-of select="util:carriage-returns(2)"/></xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise><xsl:text>----</xsl:text>
                <xsl:value-of select="util:carriage-returns(1)"/>
                <!-- This apply-templates calls on special "code" mode templates for text() and <co> elements.
          Allows disable-output-escaping to be used on text(), while still using apply-templates to
          process child <co> elements. -->
                <xsl:apply-templates mode="code"/>
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
          <!-- When example code contains inline elements, output as Docbook passthrough -->
          <xsl:when test="example[descendant::*[*]]">
++++++++++++++++++++++++++++++++++++++
<xsl:choose>
  <xsl:when test="$strip-indexterms='false'">
    <xsl:copy-of select="."/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="copy-and-drop-indexterms"/>
    </xsl:copy>
  </xsl:otherwise>
</xsl:choose>
++++++++++++++++++++++++++++++++++++++
            
</xsl:when>
          <!-- Otherwise output as Asciidoc -->
          <xsl:otherwise>
            <xsl:call-template name="process-id"/>
            <xsl:apply-templates select="." mode="title"/>====
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
                <!-- This apply-templates calls on special "code" mode templates for text() and <co> elements.
          Allows disable-output-escaping to be used on text(), while still using apply-templates to
          process child <co> elements. -->
                <xsl:apply-templates mode="code"/>
                <xsl:value-of select="util:carriage-returns(1)"/>
                <xsl:text>....</xsl:text>
                <xsl:choose>
                  <xsl:when test="ancestor::listitem and preceding-sibling::element()"><xsl:value-of select="util:carriage-returns(1)"/></xsl:when>
                  <xsl:otherwise><xsl:value-of select="util:carriage-returns(2)"/></xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise><xsl:text>----</xsl:text>
                <xsl:value-of select="util:carriage-returns(1)"/>
                <!-- This apply-templates calls on special "code" mode templates for text() and <co> elements.
          Allows disable-output-escaping to be used on text(), while still using apply-templates to
          process child <co> elements. -->
                <xsl:apply-templates mode="code"/>
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

  <xsl:template match="programlisting | screen">
    <xsl:choose>
      <!-- Contains child <co> elements -->
      <xsl:when test="co">
        <xsl:choose>
          <!-- Use Docbook passthrough when code block contains other child elements besides <co>-->
          <xsl:when test="*[not(self::co) and not(indexterm)]">
            <xsl:if test="ancestor::listitem and preceding-sibling::element()"><xsl:text>+</xsl:text>
              <xsl:value-of select="util:carriage-returns(1)"/>
            </xsl:if>
++++++++++++++++++++++++++++++++++++++
<xsl:copy-of select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
          <!-- Use Docbook passthrough when corresponding calloutlist isn't in same section -->
          <xsl:when test="not(self::*/parent::node() = co/id(@linkends)/parent::calloutlist/parent::node())">
            <xsl:if test="ancestor::listitem and preceding-sibling::element()"><xsl:text>+</xsl:text>
              <xsl:value-of select="util:carriage-returns(1)"/>
            </xsl:if>
++++++++++++++++++++++++++++++++++++++
<xsl:copy-of select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
          <!-- Use Docbook passthrough when code block contains indexterms and you want to keep them -->
          <xsl:when test="indexterm and $strip-indexterms='false'">
            <xsl:if test="ancestor::listitem and preceding-sibling::element()"><xsl:text>+</xsl:text>
              <xsl:value-of select="util:carriage-returns(1)"/>
            </xsl:if>
++++++++++++++++++++++++++++++++++++++
<xsl:copy-of select="."/>
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
                <!-- This apply-templates calls on special "code" mode templates for text() and <co> elements.
          Allows disable-output-escaping to be used on text(), while still using apply-templates to
          process child <co> elements. -->
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
                <!-- This apply-templates calls on special "code" mode templates for text() and <co> elements.
          Allows disable-output-escaping to be used on text(), while still using apply-templates to
          process child <co> elements. -->
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
          <!-- Use Docbook passthrough when code block has inlines -->
          <xsl:when test="*[not(self::indexterm)]">
            <xsl:if test="ancestor::listitem and preceding-sibling::element()">
              <xsl:text>+</xsl:text><xsl:value-of select="util:carriage-returns(1)"/>
            </xsl:if>
++++++++++++++++++++++++++++++++++++++
<xsl:copy-of select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
          <!-- Use Docbook passthrough when code block contains indexterms and you want to keep them -->
          <xsl:when test="indexterm and $strip-indexterms='false'">
            <xsl:if test="ancestor::listitem and preceding-sibling::element()"><xsl:text>+</xsl:text>
              <xsl:value-of select="util:carriage-returns(1)"/>
            </xsl:if>
++++++++++++++++++++++++++++++++++++++
<xsl:copy-of select="."/>
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
                <!-- This apply-templates calls on special "code" mode templates for text() and <co> elements.
          Allows disable-output-escaping to be used on text(), while still using apply-templates to
          process child <co> elements. -->
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
                <!-- This apply-templates calls on special "code" mode templates for text() and <co> elements.
          Allows disable-output-escaping to be used on text(), while still using apply-templates to
          process child <co> elements. -->
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
  <xsl:template match="calloutlist">
    <xsl:choose>
      <!-- Calloutlist points to an example -->
      <xsl:when test="callout/id(@arearefs)/ancestor::example">
        <xsl:choose>
          <!-- When corresponding code block has inlines (besides co) and will be output as Docbook passthrough,
          also output calloutlist as Docbook passthrough-->
          <xsl:when test="callout/id(@arearefs)/parent::*[*[not(self::co)]]">
++++++++++++++++++++++++++++++++++++++
<xsl:copy-of select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
          <!-- When corresponding code block isn't in same section as calloutlist and will be output as Docbook passthrough,
          also output calloutlist as Docbook passthrough.-->
          <xsl:when test="callout/id(@arearefs)/parent::*/parent::example/parent::node() != self::calloutlist/parent::node()">
++++++++++++++++++++++++++++++++++++++
<xsl:copy-of select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
          <!-- Otherwise output as Asciidoc -->
          <xsl:otherwise>
            <xsl:for-each select="callout">
&#xE801;<xsl:value-of select="position()"/>&#xE802; <xsl:apply-templates/></xsl:for-each>
<xsl:if test="calloutlist">
<xsl:copy-of select="."/>
</xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- Calloutlist points to a regular code block (not example) -->
      <xsl:otherwise>
        <xsl:choose>
          <!-- When corresponding code block has inlines (besides co) and will be output as Docbook passthrough,
          also output calloutlist as Docbook passthrough-->
          <xsl:when test="callout/id(@arearefs)/parent::*[*[not(self::co)]]">
++++++++++++++++++++++++++++++++++++++
<xsl:copy-of select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
          <!-- When corresponding code block isn't in same section as calloutlist and will be output as Docbook passthrough,
          also output calloutlist as Docbook passthrough.-->
          <xsl:when test="callout/id(@arearefs)/parent::*/parent::node() != self::calloutlist/parent::node()">
++++++++++++++++++++++++++++++++++++++
<xsl:copy-of select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:when>
          <!-- Otherwise output as Asciidoc -->
          <xsl:otherwise>
            <xsl:for-each select="callout">
&#xE801;<xsl:value-of select="position()"/>&#xE802; <xsl:apply-templates/></xsl:for-each>
<xsl:if test="calloutlist">
<xsl:copy-of select="."/>
</xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
<!-- END CODE BLOCK HANDLING -->
  

<xsl:template match="table|informaltable">
<xsl:call-template name="process-id"/>
<xsl:apply-templates select="." mode="title"/>
<xsl:if test="descendant::thead">
<xsl:text>[options="header"]</xsl:text>
</xsl:if>
|===============
<xsl:apply-templates select="descendant::row"/>
|===============
<xsl:value-of select="util:carriage-returns(2)"/>
</xsl:template>

<xsl:template match="sidebar">
<xsl:call-template name="process-id"/>
.<xsl:apply-templates select="title"/>
****
<xsl:apply-templates select="*[not(self::title)]"/>
****
<xsl:value-of select="util:carriage-returns(2)"/>
</xsl:template>

<xsl:template match="row">
  <xsl:for-each select="entry">
    <xsl:text>|</xsl:text>
    <xsl:apply-templates/>
  </xsl:for-each>
    <xsl:if test="not (entry/para)">
      <xsl:value-of select="util:carriage-returns(1)"/>
    </xsl:if>
</xsl:template>

<xsl:template match="footnote">
  <!-- When footnote has @id, output as footnoteref with @id value, 
       in case there are any corresponding footnoteref elements -->
  <xsl:choose>
    <xsl:when test="@id">
      <xsl:text>footnoteref:[</xsl:text>
      <xsl:value-of select="@id"/><xsl:text>,</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>footnote:[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<xsl:template match="footnoteref">
  <xsl:text>footnoteref:[</xsl:text><xsl:value-of select="@linkend"/><xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="section">
  <xsl:call-template name="process-id"/>
  <xsl:sequence select="string-join (('&#10;&#10;', for $i in (1 to count (ancestor::section) + 3) return '='),'')"/>
  <xsl:apply-templates select="title"/>
  <xsl:value-of select="util:carriage-returns(2)"/>
  <xsl:apply-templates select="*[not(self::title)]"/>
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

<xsl:template name="process-id">
  <xsl:if test="@id">
    <xsl:text xml:space="preserve">[[</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text xml:space="preserve">]]&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="title">
  <xsl:if test="title">
    <xsl:text>.</xsl:text>
    <xsl:apply-templates select="title"/>
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