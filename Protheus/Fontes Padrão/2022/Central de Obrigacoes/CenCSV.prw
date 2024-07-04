#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe que gera arquivo .csv
    @type  Class
    @author p.drivas
    @since 14/09/2020
    @version version
/*/

Class CenCSV

  Data aHeader
  Data cContent 
  Data cDelimiter

	Method new(aHeader,cdelimiter) Constructor

  Method getHeader()
  Method setHeader(aHeader)
  Method getContent()
  Method setContent(cContent)
  Method getDelimiter()
  Method setDelimiter(aDelimiter)
  Method createFile()

  Method addLine(aLine)

	Method destroy()

EndClass

Method New(aHeader,cdelimiter) Class CenCSV
  Default cdelimiter := ';'
	self:setHeader(aHeader)
	self:setDelimiter(cDelimiter)
  self:setContent('')
  self:addLine(aHeader)
Return self

Method getHeader() Class CenCSV
return self:aHeader

Method setHeader(aHeader) Class CenCSV
  self:aHeader := aHeader
return

Method getContent() Class CenCSV
return self:cContent

Method setContent(cContent) Class CenCSV
  self:cContent := cContent
return

Method getDelimiter() Class CenCSV
return self:cDelimiter

Method setDelimiter(cDelimiter) Class CenCSV
  self:cDelimiter := cDelimiter
return

Method addLine(aLine) Class CenCSV
  local nFields 
  local cContent

  For nFields := 1 to len(aLine)
    if nFields != len(aline)
      self:cContent += aLine[nFields] + self:cDelimiter
    else
      self:cContent += aLine[nFields] + CRLF
    EndIf
  Next nFields
Return

Method createFile(cPath, cNamArq, lAuto) Class CenCSV
  local   lGerou   := .T.
  Local   nArquivo
  Default lAuto    := .F.

  if !ExistDir(cPath)
    if MakeDir(cPath) <> 0
      If !lAuto
        MsgStop("Não foi possível criar o diretório: " + cPath + ".","ATENÇÃO")
      EndIf
      lGerou := .F.
    EndIf
  endif

  nArquivo := fCreate(cPath + cNamarq + ".csv")
  If fError() # 0
    If !lAuto
      MsgAlert ("Não conseguiu criar o arquivo ")
    EndIf
    lGerou := .F.
  else
    fWrite (nArquivo, self:cContent)
    if fError() # 0
      If !lAuto
        MsgAlert ("Não conseguiu gravar conteúdo no arquivo ")
      EndIf
      lGerou := .F.
    EndIf	
  EndIf
  fClose(nArquivo)	
Return lGerou

Method Destroy() Class CenCSV
Return
