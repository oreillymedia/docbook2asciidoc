<xsl:stylesheet version="2.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 >


<!-- Mapping to allow use of XML reserved chars in AsciiDoc markup elements, e.g., angle brackets for cross-references --> 
<xsl:character-map name="xml-reserved-chars">
  <xsl:output-character character="&#xE801;" string="&lt;"/>
  <xsl:output-character character="&#xE802;" string="&gt;"/>
  <xsl:output-character character="&#xE803;" string="&amp;"/>
</xsl:character-map>

<xsl:output method="xml" omit-xml-declaration="yes" use-character-maps="xml-reserved-chars"/>
<xsl:param name="chunk-output">false</xsl:param>
<xsl:param name="bookinfo-doc-name">book-docinfo.xml</xsl:param>

<xsl:preserve-space elements="*"/>
<xsl:strip-space elements="table row entry tgroup thead"/>

<xsl:template match="/">
  <xsl:if test="not(/book/title)">
    <xsl:apply-templates select="//bookinfo/title"/>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="$chunk-output != 'false'">
      <xsl:apply-templates select="*" mode="chunk"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<xsl:template match="//comment()">
++++++++++++++++++++++++++++++++++++++
<xsl:copy/>
++++++++++++++++++++++++++++++++++++++
    
</xsl:template>

<xsl:template match="book/title" mode="#all">
  <xsl:variable name="title-text" select="normalize-space(.)"/>
  <xsl:value-of select="$title-text"/>
  <xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:call-template name="title-markup">
    <xsl:with-param name="title-length" select="string-length($title-text)"/>
  </xsl:call-template>
  <xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<xsl:template name="title-markup">
  <!-- Recursive loop to generate = markup under title -->
  <xsl:param name="title-length"/>
  <xsl:text>=</xsl:text>
  <xsl:variable name="length-minus-one" select="$title-length - 1"/>
  <xsl:if test="$length-minus-one &gt; 0">
    <xsl:call-template name="title-markup">
      <xsl:with-param name="title-length" select="$length-minus-one"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="bookinfo/title">
  <!-- Process bookinfo/title if it exists, and there is no book/title, which gets primacy -->
  <xsl:if test="not(/book/title)">
    <xsl:variable name="title-text" select="normalize-space(.)"/>
    <xsl:value-of select="$title-text"/>
    <xsl:text xml:space="preserve">&#10;</xsl:text>
    <xsl:call-template name="title-markup">
      <xsl:with-param name="title-length" select="string-length($title-text)"/>
    </xsl:call-template>
    <xsl:text xml:space="preserve">&#10;</xsl:text>
    <xsl:text xml:space="preserve">&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="part" mode="chunk">
  <!-- Only bother chunking parts into a separate file if there's actually partintro content -->
  <xsl:variable name="part_content">
    <!-- Title and partintro (if present) -->
    <xsl:if test="@id">
      <xsl:text>[[</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>]]</xsl:text>
    </xsl:if>
    <xsl:text xml:space="preserve">&#10;</xsl:text>
    <xsl:text xml:space="preserve">= </xsl:text>
    <xsl:apply-templates select="title"/>
    <xsl:text xml:space="preserve">&#10;</xsl:text>
    <xsl:text xml:space="preserve">&#10;</xsl:text>
    <xsl:apply-templates select="partintro" mode="#default"/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="partintro">
      <xsl:variable name="doc-name">
	<xsl:text>part</xsl:text>
	<xsl:number count="part" level="any" format="i"/>
	<xsl:text>.asciidoc</xsl:text>
      </xsl:variable>
      <xsl:text xml:space="preserve">&#10;</xsl:text>
      <xsl:text xml:space="preserve">&#10;</xsl:text>
      <xsl:text>include::</xsl:text>
      <xsl:value-of select="$doc-name"/>
      <xsl:text>[]</xsl:text>
      <xsl:result-document href="{$doc-name}">
	<xsl:value-of select="$part_content"/>
      </xsl:result-document>
      <xsl:apply-templates select="*[not(self::title)][not(self::partintro)]" mode="chunk"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text xml:space="preserve">&#10;</xsl:text>
      <xsl:text xml:space="preserve">&#10;</xsl:text>
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
  <xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:text>include::</xsl:text>
  <xsl:value-of select="$doc-name"/>
  <xsl:text>[]</xsl:text>
  <xsl:result-document href="{$doc-name}">
    <xsl:apply-templates select="." mode="#default"/>
  </xsl:result-document>
</xsl:template>
<xsl:template match="indexterm" />

<xsl:template match="para/text()">
<xsl:sequence select="replace(replace(., '\n\s+', ' ', 'm'), 'C\+\+', '\$\$C++\$\$', 'm')"/>
</xsl:template>

<xsl:template match="phrase/text()"><xsl:text/><xsl:sequence select="replace(., '\n\s+', ' ', 'm')"/><xsl:text/></xsl:template>

<xsl:template match="ulink/text()">
<xsl:sequence select="replace(., '\n\s+', ' ', 'm')"/>
</xsl:template>

<xsl:template match="title/text()">
<xsl:sequence select="replace(., '\n\s+', ' ', 'm')"/>
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
<xsl:sequence select="replace(., '^\s+', '', 'm')"/>
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
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
= <xsl:apply-templates select="title"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="partintro">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
[partintro]
<xsl:if test="title">
.<xsl:value-of select="title"/>
</xsl:if>
--
<xsl:apply-templates select="*[not(self::title)]"/>
--
</xsl:template>
  
<xsl:template match="chapter">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
== <xsl:apply-templates select="title"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template> 

<xsl:template match="appendix">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
[appendix]
== <xsl:apply-templates select="title"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="preface">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
[preface]
== <xsl:value-of select="title"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="sect1">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
=== <xsl:apply-templates select="title"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="sect2">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
==== <xsl:apply-templates select="title"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="sect3">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
===== <xsl:apply-templates select="title"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="para|simpara">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
<xsl:apply-templates select="node()"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<xsl:template match="formalpara">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
<!-- Put formalpara <title> in bold (drop any inline formatting) -->
<xsl:text>*</xsl:text>
<xsl:value-of select="title"/>
<xsl:text>* </xsl:text>
<xsl:apply-templates select="node()[not(self::title)]"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<!-- Same handling for blockquote and epigraph; convert to AsciiDoc quote block -->
<xsl:template match="blockquote|epigraph">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
<xsl:if test="title">.<xsl:apply-templates select="title"/></xsl:if>
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
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<xsl:template match="entry/para|entry/simpara">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
<xsl:apply-templates select="node()"/>
<xsl:choose>
<xsl:when test="following-sibling::para|following-sibling::simpara">
  <!-- Two carriage returns if para has following para siblings in the same entry -->
  <xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:when>
<xsl:when test="parent::entry[not(following-sibling::entry)]">
  <!-- One carriage return if last para in last entry in row -->
  <xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:when>
</xsl:choose>
</xsl:template>


<xsl:template match="footnote/para">
<!--Special handling for footnote paras to contract whitespace-->
<xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="tip|warning|note|caution|important">
<xsl:if test="@id">[[<xsl:value-of select="@id"/>]]</xsl:if>
[<xsl:value-of select="upper-case(name())"/>]
<xsl:if test="title">.<xsl:apply-templates select="title"/></xsl:if>
====
<xsl:apply-templates select="node()[not(self::title)]"/>
====
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<xsl:template match="term"><xsl:apply-templates select="node()"/>:: </xsl:template>

<xsl:template match="listitem">
<xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="phrase"><xsl:apply-templates /></xsl:template>

<xsl:template match="emphasis [@role='bold']">*<xsl:value-of select="." />*</xsl:template>

<xsl:template match="filename">_<xsl:if test="contains(., '~') or contains(., '_')">$$</xsl:if><xsl:value-of select="normalize-space(replace(., '([\+])', '\\$1', 'm'))" /><xsl:if test="contains(., '~') or contains(., '_')">$$</xsl:if>_<xsl:if test="not(following-sibling::node()[1][self::userinput]) and matches(following-sibling::node()[1], '^[a-zA-Z]')"><xsl:text> </xsl:text></xsl:if></xsl:template>

<xsl:template match="emphasis">_<xsl:if test="contains(., '~') or contains(., '_')">$$</xsl:if><xsl:value-of select="normalize-space(.)" /><xsl:if test="contains(., '~') or contains(., '_')">$$</xsl:if>_<xsl:if test="not(following-sibling::node()[1][self::userinput]) and matches(following-sibling::node()[1], '^[a-zA-Z]')"><xsl:text> </xsl:text></xsl:if></xsl:template>

<xsl:template match="literal"><xsl:if test="preceding-sibling::node()[1][self::replaceable] or following-sibling::node()[1][self::replaceable] or following-sibling::node()[1][self::emphasis] or substring(following-sibling::node()[1],1,1) = 's' or substring(following-sibling::node()[1],1,1) = '’'">+</xsl:if>+<xsl:if test="contains(., '+')">$$</xsl:if><xsl:value-of select="replace(., '([\[\]\*\^~])', '\\$1', 'm')" /><xsl:if test="contains(., '+')">$$</xsl:if>+<xsl:if test="preceding-sibling::node()[1][self::replaceable] or following-sibling::node()[1][self::replaceable] or following-sibling::node()[1][self::emphasis] or substring(following-sibling::node()[1],1,1) = 's' or substring(following-sibling::node()[1],1,1) = '’'">+</xsl:if></xsl:template>

  <xsl:template match="userinput">**`<xsl:value-of select="normalize-space(.)" />`**</xsl:template>

<xsl:template match="replaceable">_++<xsl:value-of select="normalize-space(.)" />++_</xsl:template>

<xsl:template match="ulink">link:$$<xsl:value-of select="@url" />$$[<xsl:apply-templates/>]</xsl:template>

<xsl:template match="email"><xsl:value-of select="normalize-space(.)" /></xsl:template>

<xsl:template match="xref">&#xE801;&#xE801;<xsl:value-of select="@linkend" />&#xE802;&#xE802;</xsl:template>

<xsl:template match="link">&#xE801;&#xE801;<xsl:value-of select="@linkend" />,<xsl:value-of select="."/>&#xE802;&#xE802;</xsl:template>

<xsl:template match="variablelist">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
<xsl:for-each select="varlistentry">
<xsl:apply-templates select="term,listitem"/>
</xsl:for-each>
</xsl:template>

<xsl:template match="itemizedlist">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
<xsl:if test="@spacing">
[options="<xsl:value-of select="@spacing"/>"]
</xsl:if>
<xsl:for-each select="listitem">
* <xsl:apply-templates/>
</xsl:for-each>
</xsl:template>

<xsl:template match="orderedlist">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
<xsl:if test="@spacing">
[options="<xsl:value-of select="@spacing"/>"]
</xsl:if>
<xsl:for-each select="listitem">
. <xsl:apply-templates/>
</xsl:for-each>
</xsl:template>

<xsl:template match="simplelist">
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
<xsl:for-each select="member">
<xsl:apply-templates/><xsl:if test="position() &lt; last()"> +
</xsl:if>
</xsl:for-each>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<xsl:template match="figure">
<xsl:if test="@id">[[<xsl:value-of select="@id"/>]]</xsl:if>
.<xsl:apply-templates select="title"/>
image::<xsl:value-of select="mediaobject/imageobject[@role='web']/imagedata/@fileref"/>[]
<xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<xsl:template match="informalfigure">
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:if test="@id">[[<xsl:value-of select="@id"/>]]</xsl:if>
image::<xsl:value-of select="mediaobject/imageobject[@role='web']/imagedata/@fileref"/>[]
<xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<xsl:template match="inlinemediaobject">image:<xsl:value-of select="imageobject[@role='web']/imagedata/@fileref"/>[]</xsl:template>

<xsl:template match="example">
<xsl:if test="@id">[[<xsl:value-of select="@id"/>]]</xsl:if>
<xsl:if test="title">
.<xsl:apply-templates select="title"/>
</xsl:if>
====<xsl:apply-templates select="programlisting|screen"/>====
</xsl:template>

<!-- Asciidoc-formatted programlisting|screen (don't contain child elements) -->
<xsl:template match="programlisting|screen">
----
<xsl:apply-templates/>
----
<xsl:text xml:space="preserve">&#10;</xsl:text>
    
<xsl:if test="following-sibling::*[1][self::calloutlist]">
    <xsl:call-template name="calloutlist_ad"/>
</xsl:if>
</xsl:template>
  
<!-- This template is called for an asciidoc-formatted calloutlist (not docbook passthrough) -->
<xsl:template name="calloutlist_ad">
  <xsl:if test="@id">
    [[<xsl:value-of select="@id"/>]]
  </xsl:if>
  <xsl:for-each select="callout">
    &#xE801;<xsl:value-of select="position()"/>&#xE802; <xsl:apply-templates/>
  </xsl:for-each>
  <xsl:if test="calloutlist">
    <xsl:copy-of select="."/>
  </xsl:if>
</xsl:template>

<!-- Passthrough for code listings that have child elements (inlines) -->
<xsl:template match="programlisting[*]|screen[*]">
++++++++++++++++++++++++++++++++++++++
<xsl:copy-of select="."/>

  <!-- Passthrough for related calloutlist -->
<xsl:if test="following-sibling::*[1][self::calloutlist]">
  <xsl:copy-of select="following-sibling::*[1][self::calloutlist]"/>
</xsl:if>
++++++++++++++++++++++++++++++++++++++
</xsl:template>
  
<!-- Repress callout text from appearing as duplicate text outside of the programlisting passthrough -->
<xsl:template match="calloutlist/callout"/>

<!-- Also use passthrough for examples that have code listings with child elements (inlines) -->
<xsl:template match="example[descendant::programlisting[*]]|example[descendant::screen[*]]">
++++++++++++++++++++++++++++++++++++++
<xsl:copy-of select="."/>
++++++++++++++++++++++++++++++++++++++

</xsl:template>

<xsl:template match="co"><xsl:variable name="curr" select="@id"/>&#xE801;<xsl:value-of select="count(//calloutlist/callout[@arearefs=$curr]/preceding-sibling::callout)+1"/>&#xE802;</xsl:template>

<xsl:template match="table|informaltable">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]</xsl:if>
<xsl:if test="title">
.<xsl:apply-templates select="title"/>
</xsl:if>
<xsl:if test="descendant::thead">
[options="header"]</xsl:if>
|===============
<xsl:apply-templates select="descendant::row"/>
|===============
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<xsl:template match="sidebar">
<xsl:if test="@id">[[<xsl:value-of select="@id"/>]]</xsl:if>
.<xsl:apply-templates select="title"/>
****
<xsl:apply-templates select="*[not(title)]"/>
****
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<xsl:template match="row">
  <xsl:for-each select="entry">
    <xsl:text>|</xsl:text>
    <xsl:apply-templates/>
  </xsl:for-each>
    <xsl:if test="not (entry/para)">
    <xsl:text xml:space="preserve">&#10;</xsl:text>
    </xsl:if>
</xsl:template>


<xsl:template match="footnote">
  <xsl:text>footnote:[</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="section">
  <xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
  </xsl:if>
  <xsl:sequence select="string-join (('&#10;&#10;', for $i in (1 to count (ancestor::section) + 3) return '='),'')"/>
  <xsl:apply-templates select="title"/>
  <xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:text xml:space="preserve">&#10;</xsl:text>
  <xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<!-- Utility templates -->

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

</xsl:stylesheet>

