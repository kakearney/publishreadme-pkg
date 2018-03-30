<?xml version="1.0" encoding="utf-8"?>

<!--
This is an XSL stylesheet which converts mscript XML files into Markdown, 
with code formatted for syntax highlighting via Liquid. Use the XSLT 
command to perform the conversion.

Modified by Kelly Kearney 2017
Copyright 1984-2012 The MathWorks, Inc.
-->

<!--Setup stuff -->

<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#160;"> <!ENTITY reg "&#174;"> ]>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mwsh="http://www.mathworks.com/namespace/mcode/v1/syntaxhighlight.dtd"
  exclude-result-prefixes="mwsh">
  <xsl:output method="html"
    indent="no"/>
  <xsl:strip-space elements="mwsh:code"/>

<xsl:variable name="title">
  <xsl:variable name="dTitle" select="//steptitle[@style='document']"/>
  <xsl:choose>
    <xsl:when test="$dTitle"><xsl:value-of select="$dTitle"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="mscript/m-file"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>


<xsl:template match="mscript">
---
title: "<xsl:value-of select="$title"/>"
layout: post
permalink:
---

<xsl:text>&#xa;</xsl:text>
<xsl:text>&#xa;</xsl:text>
    <xsl:call-template name="header"/>

    <!-- Determine if the there should be an introduction section. -->
    <xsl:variable name="hasIntro" select="count(cell[@style = 'overview'])"/>

    <!-- If there is an introduction, display it. -->
    <xsl:if test = "$hasIntro">
      <xsl:apply-templates select="cell[1]/text"/>
    </xsl:if>
    
    <xsl:variable name="body-cells" select="cell[not(@style = 'overview')]"/>

    <!-- Include contents if there are titles for any subsections. -->
    <xsl:if test="count(cell/steptitle[not(@style = 'document')])">
      <xsl:call-template name="contents">
        <xsl:with-param name="body-cells" select="$body-cells"/>
      </xsl:call-template>
    </xsl:if>
    
    <!-- Loop over each cell -->
    <xsl:for-each select="$body-cells">
<!-- Title of cell -->
<xsl:if test="steptitle">

<xsl:choose>
<xsl:when test="steptitle[@style = 'document']">
<xsl:text>&#xa;</xsl:text>
# <xsl:apply-templates select="steptitle"/>
<xsl:text>&#xa;</xsl:text>
<xsl:text>&#xa;</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text>&#xa;</xsl:text>
## <xsl:apply-templates select="steptitle"/>
<xsl:text>&#xa;</xsl:text>
<xsl:text>&#xa;</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:if>

<!-- Contents of each cell -->
<xsl:apply-templates select="text"/>
<xsl:apply-templates select="mcode-xmlized"/>
<!-- <xsl:apply-templates select="mcode"/> -->
<xsl:apply-templates select="mcodeoutput|img"/>

    </xsl:for-each>

    <xsl:call-template name="footer"/>


</xsl:template>

<!-- Header -->
<xsl:template name="header">


</xsl:template>

<!-- Footer -->
<xsl:template name="footer">
	<xsl:value-of select="copyright"/>
<xsl:text>&#xa;</xsl:text>
<xsl:text>&#xa;</xsl:text>
<sub>[Published with MATLAB R<xsl:value-of select="release"/>]("http://www.mathworks.com/products/matlab/")</sub>

</xsl:template>

<!-- Contents -->
<xsl:template name="contents">
  <xsl:param name="body-cells"/>

## Contents

    <xsl:for-each select="$body-cells">
      <xsl:if test="./steptitle">        
- <xsl:apply-templates select="steptitle"/>
      </xsl:if>
    </xsl:for-each>

</xsl:template>


<!-- HTML Tags in text sections -->
<xsl:template match="p">
<xsl:text>&#xa;</xsl:text>
<xsl:apply-templates/>
<xsl:text>&#xa;</xsl:text>
<xsl:text>&#xa;</xsl:text>
</xsl:template>
<xsl:template match="ul">
<xsl:text>&#xa;</xsl:text>
<xsl:apply-templates/>
<xsl:text>&#xa;</xsl:text>
</xsl:template>
<xsl:template match="ol">
<xsl:text>&#xa;</xsl:text>
<xsl:apply-templates/>
<xsl:text>&#xa;</xsl:text>
</xsl:template>
<xsl:template match="li">
  - <xsl:apply-templates/>
</xsl:template>
<xsl:template match="pre">
<xsl:text>&#xa;</xsl:text>
{% highlight none %}
<xsl:apply-templates/>
{% endhighlight %}
<xsl:text>&#xa;</xsl:text>
</xsl:template>
<xsl:template match="b">**<xsl:apply-templates/>**</xsl:template>
<xsl:template match="i">*<xsl:apply-templates/>*</xsl:template>
<xsl:template match="tt">`<xsl:apply-templates/>`</xsl:template>
<xsl:template match="a">[<xsl:value-of select="text()"/>](<xsl:value-of select="@href"/>)</xsl:template>
<xsl:template match="html"><xsl:apply-templates select="@text"/></xsl:template>
<xsl:template match="h3">

### <xsl:apply-templates select="@text"/>

</xsl:template>
<xsl:template match="latex"/>

<!-- Detecting M-Code in Comments-->
<xsl:template match="text/mcode-xmlized">
<xsl:text>&#xa;</xsl:text>
{% highlight matlab linenos %}
<xsl:apply-templates/>
{% endhighlight %}
<xsl:text>&#xa;</xsl:text>
</xsl:template>

<!-- Code input and output -->

<xsl:template match="mcode-xmlized">
<xsl:text>&#xa;</xsl:text>
{% highlight matlab linenos %}
<xsl:apply-templates/>
{% endhighlight %}
<xsl:text>&#xa;</xsl:text>
</xsl:template>

<xsl:template match="mcodeoutput">
<xsl:choose>
<xsl:when test="concat(substring(.,0,7),substring(.,string-length(.)-7,7))='&lt;html&gt;&lt;/html&gt;'">
<xsl:value-of select="substring(.,7,string-length(.)-14)" disable-output-escaping="yes"/>
</xsl:when>
<xsl:otherwise><xsl:text>&#xa;</xsl:text>
<xsl:text>&#xa;</xsl:text>
{% highlight none %}
<xsl:apply-templates/>
{% endhighlight %}<xsl:text>&#xa;</xsl:text>
<xsl:text>&#xa;</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<!-- Figure and model snapshots and equations -->
<xsl:template match="img[@class='equation']">
{% include scaledimage.html src="<xsl:value-of select="@src"/>" scale="1" %}
</xsl:template>

<xsl:template match="img">
{% include scaledimage.html src="<xsl:value-of select="@src"/>" scale="1" %}
</xsl:template>

<!-- Stash original code in HTML for easy slurping later. -->

<xsl:template match="originalCode">
  <xsl:variable name="xcomment">
    <xsl:call-template name="globalReplace">
      <xsl:with-param name="outputString" select="."/>
      <xsl:with-param name="target" select="'--'"/>
      <xsl:with-param name="replacement" select="'REPLACE_WITH_DASH_DASH'"/>
    </xsl:call-template>
  </xsl:variable>
<xsl:comment>
##### SOURCE BEGIN #####
<xsl:value-of select="$xcomment"/>
##### SOURCE END #####
</xsl:comment>
</xsl:template>

<!-- Colors for syntax-highlighted input code -->

<xsl:template match="mwsh:code">
<xsl:apply-templates/>
</xsl:template>
<xsl:template match="mwsh:keywords">
<xsl:apply-templates/>
</xsl:template>
<xsl:template match="mwsh:strings">
<xsl:apply-templates/>
</xsl:template>
<xsl:template match="mwsh:comments">
<xsl:apply-templates/>
</xsl:template>
<xsl:template match="mwsh:unterminated_strings">
<xsl:apply-templates/>
</xsl:template>
<xsl:template match="mwsh:system_commands">
<xsl:apply-templates/>
</xsl:template>


<!-- Footer information -->

<xsl:template match="copyright">
  <xsl:value-of select="."/>
</xsl:template>
<xsl:template match="revision">
  <xsl:value-of select="."/>
</xsl:template>

<!-- Search and replace  -->
<!-- From http://www.xml.com/lpt/a/2002/06/05/transforming.html -->

<xsl:template name="globalReplace">
  <xsl:param name="outputString"/>
  <xsl:param name="target"/>
  <xsl:param name="replacement"/>
  <xsl:choose>
    <xsl:when test="contains($outputString,$target)">
      <xsl:value-of select=
        "concat(substring-before($outputString,$target),$replacement)"/>
      <xsl:call-template name="globalReplace">
        <xsl:with-param name="outputString" 
          select="substring-after($outputString,$target)"/>
        <xsl:with-param name="target" select="$target"/>
        <xsl:with-param name="replacement" 
          select="$replacement"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$outputString"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
