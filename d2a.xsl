<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:util="http://github.com/oreillymedia/docbook2asciidoc/" exclude-result-prefixes="util">

  <!-- Mapping to allow use of XML reserved chars in AsciiDoc markup elements, e.g., angle brackets for cross-references -->
  <xsl:character-map name="xml-reserved-chars">
    <xsl:output-character character="&#xE801;" string="&lt;"/>
    <xsl:output-character character="&#xE802;" string="&gt;"/>
    <xsl:output-character character="&#xE803;" string="&amp;"/>
    <xsl:output-character character="“" string="&amp;ldquo;"/>
    <xsl:output-character character="”" string="&amp;rdquo;"/>
    <xsl:output-character character="’" string="&amp;rsquo;"/>
  </xsl:character-map>

  <xsl:output method="text" omit-xml-declaration="yes" use-character-maps="xml-reserved-chars" indent="no"/>
  <xsl:param name="chunk-output">false</xsl:param>
  <xsl:param name="bookinfo-doc-name">book-docinfo.xml</xsl:param>

  <xsl:variable name="punctuation">
    <xsl:text>.,:;!?&amp;'"()[]{}</xsl:text>
  </xsl:variable>

  <xsl:strip-space elements="*"/>

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
    <xsl:text>++++++++++++++++++++++++++++++++++++++</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:copy/>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>++++++++++++++++++++++++++++++++++++++</xsl:text>
    <xsl:value-of select="util:carriage-returns(2)"/>
  </xsl:template>

  <xsl:template match="processing-instruction()">
    <xsl:text>+++</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:copy-of select="."/>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>+++</xsl:text>
    <xsl:value-of select="util:carriage-returns(2)"/>
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
  <xsl:template match="indexterm"/>

  <xsl:template match="para/text()">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="following-sibling::text()[1] != following-sibling::node()[1]">
      <!-- Add a space if the next node is not a text node -->
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="phrase/text()">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="following-sibling::text()[1] != following-sibling::node()[1]">
      <!-- Add a space if the next node is not a text node -->
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ulink/text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <xsl:template match="title/text()">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="following-sibling::text()[1] != following-sibling::node()[1]">
      <!-- Add a space if the next node is not a text node -->
      <xsl:text> </xsl:text>
    </xsl:if>
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
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <xsl:template match="member/text()">
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
    <xsl:text>= </xsl:text>
    <xsl:apply-templates select="title"/>
    <xsl:value-of select="util:carriage-returns(2)"/>
    <xsl:apply-templates select="*[not(self::title)]"/>
  </xsl:template>

  <xsl:template match="partintro">
    <xsl:call-template name="process-id"/>
    <xsl:text>[partintro]</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:apply-templates select="." mode="title"/>
    <xsl:text>--</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:apply-templates select="*[not(self::title)]"/>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>--</xsl:text>
    <xsl:value-of select="util:carriage-returns(2)"/>
  </xsl:template>

  <xsl:template match="chapter">
    <xsl:call-template name="process-id"/>
    <xsl:text>== </xsl:text>
    <xsl:apply-templates select="title"/>
    <xsl:value-of select="util:carriage-returns(2)"/>
    <xsl:apply-templates select="*[not(self::title)]"/>
  </xsl:template>

  <xsl:template match="appendix">
    <xsl:call-template name="process-id"/>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>[appendix]</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>== </xsl:text>
    <xsl:apply-templates select="title"/>
    <xsl:value-of select="util:carriage-returns(2)"/>
    <xsl:apply-templates select="*[not(self::title)]"/>
  </xsl:template>

  <xsl:template match="preface">
    <xsl:call-template name="process-id"/>
    <xsl:text>[preface]</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>== </xsl:text>
    <xsl:value-of select="title"/>
    <xsl:value-of select="util:carriage-returns(2)"/>
    <xsl:apply-templates select="*[not(self::title)]"/>
  </xsl:template>

  <xsl:template match="sect1">
    <xsl:call-template name="process-id"/>
    <xsl:text>=== </xsl:text>
    <xsl:apply-templates select="title"/>
    <!--<xsl:value-of select="util:carriage-returns(2)"/>-->
    <xsl:apply-templates select="*[not(self::title)]"/>
  </xsl:template>

  <xsl:template match="sect2">
    <xsl:call-template name="process-id"/>
    <xsl:text>==== </xsl:text>
    <xsl:apply-templates select="title"/>
    <!--<xsl:value-of select="util:carriage-returns(2)"/>-->
    <xsl:apply-templates select="*[not(self::title)]"/>
  </xsl:template>

  <xsl:template match="sect3">
    <xsl:call-template name="process-id"/>
    <xsl:text>===== </xsl:text>
    <xsl:apply-templates select="title"/>
    <!--<xsl:value-of select="util:carriage-returns(2)"/>-->
    <xsl:apply-templates select="*[not(self::title)]"/>
  </xsl:template>

  <!-- Use passthrough for sect4 and sect5, as there is no AsciiDoc markup/formatting for these -->
  <xsl:template match="sect4|sect5">
    <xsl:text>++++++++++++++++++++++++++++++++++++++</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:copy-of select="."/>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>++++++++++++++++++++++++++++++++++++++</xsl:text>
    <xsl:value-of select="util:carriage-returns(2)"/>
  </xsl:template>

  <xsl:template match="para|simpara">
    <xsl:call-template name="process-id"/>
    <xsl:apply-templates select="node()"/>
    <xsl:choose>
      <xsl:when test="parent::listitem">
        <xsl:value-of select="util:carriage-returns(1)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="util:carriage-returns(2)"/>
      </xsl:otherwise>
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
           and skipping <citetitle>, which is handled separately below 
      -->
      <xsl:for-each select="attribution/text()|attribution//*[not(*)][not(self::citetitle)]">
        <!-- Output text as is, except escape commas as &#44; entities for
	           proper AsciiDoc attribute processing 
        -->
        <xsl:value-of select="normalize-space(replace(., ',', '&#xE803;#44;'))"/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test="attribution/citetitle">
      <xsl:text>, </xsl:text>
      <xsl:value-of select="attribution/citetitle"/>
    </xsl:if>
    <xsl:text>]</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>____</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:apply-templates select="node()[not(self::title or self::attribution)]"/>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>____</xsl:text>
    <xsl:value-of select="util:carriage-returns(2)"/>
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
    <xsl:text>[</xsl:text>
    <xsl:value-of select="upper-case(name())"/>
    <xsl:text>]</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:apply-templates select="." mode="title"/>
    <xsl:text>====</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:apply-templates select="node()[not(self::title)]"/>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>====</xsl:text>
    <xsl:value-of select="util:carriage-returns(2)"/>
  </xsl:template>

  <xsl:template match="tip/para|warning/para|note/para|caution/para|important/para">
    <!--Special handling for admonition paras to contract whitespace-->
    <xsl:apply-templates select="node()"/>
    <xsl:if test="position() != last()">
      <xsl:value-of select="util:carriage-returns(2)"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="term">
    <xsl:apply-templates select="node()"/>
    <xsl:text>:: </xsl:text>
  </xsl:template>

  <xsl:template match="listitem">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="phrase">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="emphasis [@role='bold']">
    <xsl:text>*</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>*</xsl:text>
    <xsl:if test="(following-sibling::text()[1] = following-sibling::node()[1]) and not(contains($punctuation, substring(following-sibling::text()[1], 1, 1)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="filename">
    <xsl:text>_</xsl:text>
    <xsl:if test="contains(., '~') or contains(., '_')">
      <xsl:text>$$</xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(replace(., '([\+])', '\\$1', 'm'))"/>
    <xsl:if test="contains(., '~') or contains(., '_')">
      <xsl:text>$$</xsl:text>
    </xsl:if>
    <xsl:text>_</xsl:text>
    <xsl:if test="not(following-sibling::node()[1][self::userinput]) and matches(following-sibling::node()[1], '^[a-zA-Z]')">
      <xsl:if test="(following-sibling::text()[1] = following-sibling::node()[1]) and not(contains($punctuation, substring(following-sibling::text()[1], 1, 1)))">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="emphasis">
    <xsl:text>_</xsl:text>
    <xsl:if test="contains(., '~') or contains(., '_')">
      <xsl:text>$$</xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="contains(., '~') or contains(., '_')">
      <xsl:text>$$</xsl:text>
    </xsl:if>
    <xsl:text>_</xsl:text>
    <xsl:if test="not(following-sibling::node()[1][self::userinput]) and matches(following-sibling::node()[1], '^[a-zA-Z]')">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:if test="(following-sibling::text()[1] = following-sibling::node()[1]) and not(contains($punctuation, substring(following-sibling::text()[1], 1, 1)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="command">
    <xsl:text>_</xsl:text>
    <xsl:if test="contains(., '~') or contains(., '_')">
      <xsl:text>$$</xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(replace(., '([\+])', '\\$1', 'm'))"/>
    <xsl:if test="contains(., '~') or contains(., '_')">
      <xsl:text>$$</xsl:text>
    </xsl:if>
    <xsl:text>_</xsl:text>
    <xsl:if test="not(following-sibling::node()[1][self::userinput]) and matches(following-sibling::node()[1], '^[a-zA-Z]')">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:if test="(following-sibling::text()[1] = following-sibling::node()[1]) and not(contains($punctuation, substring(following-sibling::text()[1], 1, 1)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="literal|code">
    <xsl:if test="preceding-sibling::node()[1][self::replaceable] or following-sibling::node()[1][self::replaceable] or following-sibling::node()[1][self::emphasis] or substring(following-sibling::node()[1],1,1) = 's' or substring(following-sibling::node()[1],1,1) = '’'">
      <xsl:text>+</xsl:text>
    </xsl:if>
    <xsl:text>+</xsl:text>
    <xsl:if test="contains(., '+')">
      <xsl:text>$$</xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(replace(., '([\[\]\*\^~])', '\\$1', 'm'))"/>
    <xsl:if test="contains(., '+')">
      <xsl:text>$$</xsl:text>
    </xsl:if>
    <xsl:text>+</xsl:text>
    <xsl:if test="preceding-sibling::node()[1][self::replaceable] or following-sibling::node()[1][self::replaceable] or following-sibling::node()[1][self::emphasis] or substring(following-sibling::node()[1],1,1) = 's' or substring(following-sibling::node()[1],1,1) = '’'">
      <xsl:text>+</xsl:text>
    </xsl:if>
    <xsl:if test="(following-sibling::text()[1] = following-sibling::node()[1]) and not(contains($punctuation, substring(following-sibling::text()[1], 1, 1)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="userinput">
    <xsl:text>**`</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>`**</xsl:text>
    <xsl:if test="(following-sibling::text()[1] = following-sibling::node()[1]) and not(contains($punctuation, substring(following-sibling::text()[1], 1, 1)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="replaceable">
    <xsl:text>_++</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>++_</xsl:text>
    <xsl:if test="(following-sibling::text()[1] = following-sibling::node()[1]) and not(contains($punctuation, substring(following-sibling::text()[1], 1, 1)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="superscript">
    <xsl:text>^</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>^</xsl:text>
    <xsl:if test="(following-sibling::text()[1] = following-sibling::node()[1]) and not(contains($punctuation, substring(following-sibling::text()[1], 1, 1)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="subscript">
    <xsl:text>~</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>~</xsl:text>
    <xsl:if test="(following-sibling::text()[1] = following-sibling::node()[1]) and not(contains($punctuation, substring(following-sibling::text()[1], 1, 1)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ulink">
    <xsl:text>link:$$</xsl:text>
    <xsl:value-of select="@url"/>
    <xsl:text>$$[</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>]</xsl:text>
    <xsl:if test="(following-sibling::text()[1] = following-sibling::node()[1]) and not(contains($punctuation, substring(following-sibling::text()[1], 1, 1)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="email">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="(following-sibling::text()[1] = following-sibling::node()[1]) and not(contains($punctuation, substring(following-sibling::text()[1], 1, 1)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xref">
    <xsl:text>&#xE801;&#xE801;</xsl:text>
    <xsl:value-of select="@linkend"/>
    <xsl:text>&#xE802;&#xE802;</xsl:text>
    <xsl:if test="(following-sibling::text()[1] = following-sibling::node()[1]) and not(contains($punctuation, substring(following-sibling::text()[1], 1, 1)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="link">
    <xsl:text>&#xE801;&#xE801;</xsl:text>
    <xsl:value-of select="@linkend"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&#xE802;&#xE802;</xsl:text>
    <xsl:if test="(following-sibling::text()[1] = following-sibling::node()[1]) and not(contains($punctuation, substring(following-sibling::text()[1], 1, 1)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="variablelist">
    <xsl:call-template name="process-id"/>
    <xsl:for-each select="varlistentry">
      <xsl:apply-templates select="term,listitem"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="itemizedlist">
    <xsl:call-template name="process-id"/>
    <xsl:if test="@spacing">
      <xsl:text>[options="</xsl:text>
      <xsl:value-of select="@spacing"/>
      <xsl:text>"]</xsl:text>
      <xsl:value-of select="util:carriage-returns(1)"/>
    </xsl:if>
    <xsl:for-each select="listitem">
      <xsl:text>* </xsl:text>
      <xsl:apply-templates/>
      <xsl:choose>
        <xsl:when test="position() = last()">
          <xsl:value-of select="util:carriage-returns(1)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="orderedlist">
    <xsl:call-template name="process-id"/>
    <xsl:if test="@spacing">
      <xsl:text>[options="</xsl:text>
      <xsl:value-of select="@spacing"/>
      <xsl:text>"]</xsl:text>
      <xsl:value-of select="util:carriage-returns(1)"/>
    </xsl:if>
    <xsl:for-each select="listitem">
      <xsl:text>. </xsl:text>
      <xsl:apply-templates/>
      <xsl:value-of select="util:carriage-returns(2)"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="simplelist">
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:call-template name="process-id"/>
    <xsl:for-each select="member">
      <xsl:apply-templates/>
      <xsl:if test="position() &lt; last()">
        <xsl:text> + </xsl:text>
      </xsl:if>
      <xsl:value-of select="util:carriage-returns(1)"/>
    </xsl:for-each>
    <!--<xsl:value-of select="util:carriage-returns(2)"/>-->
  </xsl:template>

  <xsl:template match="figure">
    <xsl:call-template name="process-id"/>
    <xsl:text>.</xsl:text>
    <xsl:apply-templates select="title"/>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>image::</xsl:text>
    <xsl:if test="imageobject[@role = 'web']">
      <xsl:apply-templates select="imageobject" />
    </xsl:if>
    <xsl:value-of select="util:carriage-returns(1)"/>
  </xsl:template>

  <xsl:template match="informalfigure">
    <xsl:call-template name="process-id"/>
    <xsl:text>image::</xsl:text>
    <xsl:if test="imageobject[@role = 'web']">
      <xsl:apply-templates select="imageobject" />
    </xsl:if>
    <xsl:value-of select="util:carriage-returns(1)"/>
  </xsl:template>

  <xsl:template match="inlinemediaobject">
    <xsl:text>image:</xsl:text>
    <xsl:if test="imageobject[@role = 'web']">
      <xsl:apply-templates select="imageobject" />
    </xsl:if>
  </xsl:template>

  <!-- Could be a JBoss-only tweak for a mediaobject outside of a figure -->
  <xsl:template match="mediaobject/imageobject">
    <xsl:text>image::</xsl:text>
    <xsl:apply-templates select="imagedata" />
    <xsl:value-of select="util:carriage-returns(2)"/>
  </xsl:template>
  
  <xsl:template match="imagedata">
    <xsl:value-of select="@fileref"/>
    <xsl:text>[</xsl:text>
    <xsl:for-each select="@*[name() != 'fileref' and name() != 'format']">
      <xsl:copy-of select="name()"/>
      <xsl:text>="</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>"</xsl:text>
      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="example">
    <xsl:call-template name="process-id"/>
    <xsl:apply-templates select="." mode="title"/>
    <xsl:text>====</xsl:text>
    <xsl:apply-templates select="programlisting|screen"/>
    <xsl:text>====</xsl:text>
    <xsl:value-of select="util:carriage-returns(2)"/>
  </xsl:template>
  
  <!-- Possible JBoss-only tweak for adding the areaspec and callout list within comments for the author to go back and fix -->
  <xsl:template match="programlistingco|screenco">
    <xsl:text>++++++++++++++++++++++++++++++++++++++</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:for-each select="calloutlist/callout">
      <xsl:variable name="arearefs" select="@arearefs" />
      <xsl:text>callout (coords </xsl:text>
      <xsl:value-of select="../../areaspec/area[@id = $arearefs]/@coords" />
      <xsl:text>) </xsl:text>
      <xsl:apply-templates />
    </xsl:for-each>
    <xsl:text>++++++++++++++++++++++++++++++++++++++</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:apply-templates select="programlisting|screenlisting" />
  </xsl:template>

  <!-- Asciidoc-formatted programlisting|screen (don't contain child elements) -->
  <xsl:template match="programlisting|screen">
    <!-- Preserve non-empty "language" attribute if present -->
    <xsl:if test="@language != ''">
      <xsl:text>[source, </xsl:text>
      <xsl:value-of select="@language"/>
      <xsl:text>]</xsl:text>
      <xsl:value-of select="util:carriage-returns(1)"/>
    </xsl:if>
    <!-- possible JBoss-only tweak, we use role the same as language -->
    <xsl:if test="@role != ''">
      <xsl:text>[source, </xsl:text>
      <xsl:value-of select="@role"/>
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
        <!-- Disable output escaping on code listing text to avoid any problems with roundtripping lt, gt, and amp chars -->
        <xsl:value-of select="." disable-output-escaping="yes"/>
        <xsl:value-of select="util:carriage-returns(1)"/>
        <xsl:text>....</xsl:text>
        <xsl:value-of select="util:carriage-returns(2)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>----</xsl:text>
        <xsl:value-of select="util:carriage-returns(1)"/>
        <!-- Disable output escaping on code listing text to avoid any problems with roundtripping lt, gt, and amp chars -->
        <xsl:value-of select="." disable-output-escaping="yes"/>
        <xsl:value-of select="util:carriage-returns(1)"/>
        <xsl:text>----</xsl:text>
        <xsl:value-of select="util:carriage-returns(2)"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="following-sibling::*[1][self::calloutlist]">
      <xsl:call-template name="calloutlist_ad"/>
    </xsl:if>
  </xsl:template>

  <!-- This template is called for an asciidoc-formatted calloutlist (not docbook passthrough) -->
  <xsl:template name="calloutlist_ad">
    <xsl:call-template name="process-id"/>
    <xsl:for-each select="callout">
      <xsl:text>&#xE801;</xsl:text>
      <xsl:value-of select="position()"/>
      <xsl:text>&#xE802; </xsl:text>
      <xsl:apply-templates/>
      <xsl:value-of select="util:carriage-returns(1)"/>
    </xsl:for-each>
    <xsl:if test="calloutlist">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <!-- Passthrough for code listings that have child elements (inlines) -->
  <xsl:template match="programlisting[*]|screen[*]">
    <xsl:text>++++++++++++++++++++++++++++++++++++++</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:copy-of select="."/>

    <!-- Passthrough for related calloutlist -->
    <xsl:if test="following-sibling::*[1][self::calloutlist]">
      <xsl:copy-of select="following-sibling::*[1][self::calloutlist]"/>
    </xsl:if>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>++++++++++++++++++++++++++++++++++++++</xsl:text>
    <xsl:value-of select="util:carriage-returns(2)"/>
  </xsl:template>

  <!-- Repress callout text from appearing as duplicate text outside of the programlisting passthrough -->
  <xsl:template match="calloutlist/callout"/>

  <!-- Also use passthrough for examples that have code listings with child elements (inlines) -->
  <xsl:template match="example[descendant::programlisting[*]]|example[descendant::screen[*]]">
    <xsl:text>++++++++++++++++++++++++++++++++++++++</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:copy-of select="."/>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>++++++++++++++++++++++++++++++++++++++</xsl:text>
    <xsl:value-of select="util:carriage-returns(2)"/>
  </xsl:template>

  <xsl:template match="co">
    <xsl:variable name="curr" select="@id"/>
    <xsl:text>&#xE801;</xsl:text>
    <xsl:value-of select="count(//calloutlist/callout[@arearefs=$curr]/preceding-sibling::callout)+1"/>
    <xsl:text>&#xE802;</xsl:text>
  </xsl:template>

  <xsl:template match="table|informaltable">
    <xsl:call-template name="process-id"/>
    <xsl:apply-templates select="." mode="title"/>
    <xsl:if test="descendant::thead">
      <xsl:text>[options="header"]</xsl:text>
      <xsl:value-of select="util:carriage-returns(1)"/>
    </xsl:if>
    <xsl:text>|===============</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:apply-templates select="descendant::row"/>
    <xsl:text>|===============</xsl:text>
    <xsl:value-of select="util:carriage-returns(2)"/>
  </xsl:template>

  <xsl:template match="sidebar">
    <xsl:call-template name="process-id"/>
    <xsl:text>.</xsl:text>
    <xsl:apply-templates select="title"/>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>****</xsl:text>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:apply-templates select="*[not(self::title)]"/>
    <xsl:value-of select="util:carriage-returns(1)"/>
    <xsl:text>****</xsl:text>
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
    <xsl:text>footnote:[</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="section">
    <xsl:call-template name="process-id"/>
    <xsl:sequence select="string-join (('', for $i in (1 to count (ancestor::section) + 3) return '='),'')"/>
    <!-- Make sure we have a space after the heading = -->
    <xsl:text> </xsl:text>
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
      <xsl:text>[[</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>]]&#10;</xsl:text>
      <xsl:value-of select="util:carriage-returns(1)"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="title">
    <xsl:if test="title">
      <xsl:text>.</xsl:text>
      <xsl:apply-templates select="title"/>
      <xsl:value-of select="util:carriage-returns(1)"/>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>

