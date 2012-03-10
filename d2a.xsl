<xsl:stylesheet version="2.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 >

<xsl:output method="xml" omit-xml-declaration="yes"/>
<xsl:param name="chunk-output">false</xsl:param>
<xsl:preserve-space elements="*"/>
<xsl:strip-space elements="table row entry tgroup thead"/>

<xsl:template match="/">
  <xsl:choose>
    <xsl:when test="$chunk-output != 'false'">
      <xsl:apply-templates select="*" mode="chunk"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
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

<xsl:template match="bookinfo" mode="#all"/>

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
    <xsl:text>.asc</xsl:text>
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

<xsl:template match="term/text()">
<xsl:sequence select="replace(replace(., '^\s+', '', 'm'), '\s+$', '', 'm')"/>
</xsl:template>

<xsl:template match="member/text()">
<xsl:sequence select="replace(., '^\s+', '', 'm')"/>
</xsl:template>

<xsl:template match="chapter">
[[<xsl:value-of select="@id"/>]]
== <xsl:apply-templates select="title"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="preface">
[[<xsl:value-of select="@id"/>]]
== <xsl:apply-templates select="title"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="sect1">
[[<xsl:value-of select="@id"/>]]
=== <xsl:apply-templates select="title"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="sect2">
[[<xsl:value-of select="@id"/>]]
==== <xsl:apply-templates select="title"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="sect3">
[[<xsl:value-of select="@id"/>]]
===== <xsl:apply-templates select="title"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:apply-templates select="*[not(self::title)]"/>
</xsl:template>

<xsl:template match="para">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
<xsl:apply-templates select="node()"/>
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<xsl:template match="entry/para">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
<xsl:apply-templates select="node()"/>
<xsl:choose>
<xsl:when test="following-sibling::para">
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


<xsl:template match="tip">
<xsl:if test="@id">[[<xsl:value-of select="@id"/>]]</xsl:if>
[TIP]
====
<xsl:apply-templates select="node()"/>
====
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<xsl:template match="note">
<xsl:if test="@id">[[<xsl:value-of select="@id"/>]]</xsl:if>
[NOTE]
====
<xsl:apply-templates select="node()"/>
====
<xsl:text xml:space="preserve">&#10;</xsl:text>
<xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<xsl:template match="warning">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
[WARNING]
====
<xsl:apply-templates select="node()"/>
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

<xsl:template match="userinput">**+<xsl:value-of select="normalize-space(.)" />+**</xsl:template>

<xsl:template match="replaceable">_++<xsl:value-of select="normalize-space(.)" />++_</xsl:template>

<xsl:template match="ulink">link:$$<xsl:value-of select="@url" />$$[<xsl:apply-templates/>]</xsl:template>

<xsl:template match="email"><xsl:value-of select="normalize-space(.)" /></xsl:template>

<xsl:template match="xref">&lt;&lt;<xsl:value-of select="@linkend" />&gt;&gt;</xsl:template>

<xsl:template match="link">&lt;&lt;<xsl:value-of select="@linkend" />,<xsl:value-of select="."/>&gt;&gt;</xsl:template>

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
<xsl:for-each select="listitem">
* <xsl:apply-templates/>
</xsl:for-each>
</xsl:template>

<xsl:template match="orderedlist">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
<xsl:for-each select="listitem">
. <xsl:apply-templates/>
</xsl:for-each>
</xsl:template>

<xsl:template match="calloutlist">
<xsl:if test="@id">
[[<xsl:value-of select="@id"/>]]
</xsl:if>
<xsl:for-each select="callout">
&lt;<xsl:value-of select="position()"/>&gt; <xsl:apply-templates/>
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
<xsl:apply-templates select="programlisting|screen"/>
</xsl:template>

<xsl:template match="programlisting|screen">
----
<xsl:apply-templates/>
----
<xsl:text xml:space="preserve">&#10;</xsl:text>
</xsl:template>

<xsl:template match="programlisting[*]|screen[*]">
++++++++++++++++++++++++++++++++++++++
<xsl:copy-of select="."/>
++++++++++++++++++++++++++++++++++++++
</xsl:template>

<xsl:template match="co"><xsl:variable name="curr" select="@id"/>&lt;<xsl:value-of select="count(//calloutlist/callout[@arearefs=$curr]/preceding-sibling::callout)+1"/>&gt;</xsl:template>

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
</xsl:template>



</xsl:stylesheet>

