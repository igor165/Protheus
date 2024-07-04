#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'GTPR284.CH'

 //-------------------------------------------------------------------
/*/{Protheus.doc} GTPR284()
Relatório de lotes de requisições 

@sample GTPR284()

@author	Renan Ribeiro Brando -  Inovação
@since	09/08/2017
@version	P12
/*/
//-------------------------------------------------------------------
Function GTPR284()
       Local oReport     := Nil
       If Pergunte("GTPR284", .T.)
            // Interface de impressao
            oReport := ReportDef()
            oReport:PrintDialog()
      EndIf
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()

@sample ReportDef()
@return oReport - Objeto - Objeto TREPORT

@author	Renan Ribeiro Brando -  Inovação
@since	08/08/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
      Local oReport
      Local cAliasGQY := GetNextAlias()
      //---------------------------------------
      // Criação do componente de impressão
      //---------------------------------------
      oReport := TReport():New("GTPR284", STR0001, "GTPR284", {|oReport| ReportPrint(oReport, cAliasGQY)}, "" ) // "Lotes de Requisições"
      oReport:SetTotalInLine(.F.)
      
      oSection := TRSection():New(oReport, STR0001, "GQY", /*{Array com as ordens do relatório}*/, /*Campos do SX3*/, /*Campos do SIX*/)  //"Lotes de Requisições"
      oSection:SetTotalInLine(.F.)
      oSection:SetAutoSize(.F.)

      TRCell():New(oSection, "GQY_CODIGO", "GQY", STR0003, X3Picture("GQY_CODIGO"), /*lTamanho*/ , /*lPixel*/, /*{|| code-block de impressao }*/) // Código do Lote
      TRCell():New(oSection, "GQY_DESCRI", "GQY", STR0004, X3Picture("GQY_DESCRI"), /*lTamanho*/ , /*lPixel*/, /*{|| code-block de impressao }*/) // Código do Lote
      TRCell():New(oSection, "GQY_CODCLI", "GQY", STR0005, X3Picture("GQY_CODCLI"), /*lTamanho*/ , /*lPixel*/,  /*{|| code-block de impressao }*/ ) // Código Cliente
      TRCell():New(oSection, "GQY_NOMCLI", "GQY", STR0006, X3Picture("GQY_NOMCLI"), /*lTamanho*/ , /*lPixel*/, {||POSICIONE('SA1',1,xFilial('SA1') + (cAliasGQY)->GQY_CODCLI,'A1_NOME')}) // Nome Cliente
      TRCell():New(oSection, "GQY_DTEMIS", "GQY", STR0007, X3Picture("GQY_DTEMIS"), /*lTamanho*/ , /*lPixel*/, /*{|| code-block de impressao }*/) // Data Emissão
      TRCell():New(oSection, "GQY_DTFECH", "GQY", STR0008, X3Picture("GQY_DTFECH"), /*lTamanho*/ , /*lPixel*/, /*{|| code-block de impressao }*/) // Data Emissão
      TRCell():New(oSection, "GQY_STATUS", "GQY", STR0009, X3Picture("GQY_STATUS"), /*lTamanho*/ , /*lPixel*/, /*{|| code-block de impressao }*/) // Status
      TRCell():New(oSection, "GQY_TOTAL" , "GQY", STR0010, X3Picture("GQY_TOTAL") , /*lTamanho*/  ,/*lPixel*/, /*{|| code-block de impressao }*/) // Total    

      TRFunction():New(oSection:Cell("GQY_TOTAL") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

      oSection:SetLeftMargin(5) 
      oSection:SetTotalInLine(.F.) 

      oSection:Cell("GQY_CODIGO"):lHeaderSize := .F.
      oSection:Cell("GQY_DESCRI"):lHeaderSize := .F.
      oSection:Cell("GQY_CODCLI"):lHeaderSize := .F.
      oSection:Cell("GQY_NOMCLI"):lHeaderSize := .F.
      oSection:Cell("GQY_DTEMIS"):lHeaderSize := .F.
      oSection:Cell("GQY_DTFECH"):lHeaderSize := .F.
      oSection:Cell("GQY_STATUS"):lHeaderSize := .F.
      oSection:Cell("GQY_TOTAL"):lHeaderSize := .F.

Return oReport
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()
@sample ReportPrint()

@author	Renan Ribeiro Brando -  Inovação
@since	08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport, cAliasGQY)
      
      Local oSection := oReport:Section(1)
      Local cParam1  := cValToChar(MV_PAR01) // Código de?
      Local cParam2  := cValToChar(MV_PAR02) // Código até?
      Local cParam3  := cValToChar(MV_PAR03) // Cliente de?
      Local cParam4  := cValToChar(MV_PAR04) // Cliente até?
      Local cParam5  := DTOS(MV_PAR05) // Emissão de?
      Local cParam6  := DTOS(MV_PAR06) // Emissão até?
      Local cParam7  := DTOS(MV_PAR07) // Fechamento de?
      Local cParam8  := DTOS(MV_PAR08) // Fechamento até?
      Local cParam9  := cValToChar(MV_PAR09) // Status igual?
      //---------------------------------------
      // Query do relatório da secao 1
      //---------------------------------------
      oSection:BeginQuery()
          BeginSQL Alias cAliasGQY
            SELECT 
                GQY.GQY_CODIGO, GQY.GQY_DESCRI, GQY.GQY_CODCLI, 
                GQY.GQY_DTEMIS, GQY.GQY_DTFECH, GQY.GQY_STATUS, 
                GQY.GQY_TOTAL 
            FROM 
                  %table:GQY% GQY
            WHERE 
                  GQY.GQY_FILIAL = %xFilial:GQY%
              	  AND GQY.%NotDel%  
                  AND GQY.GQY_CODIGO BETWEEN %Exp:cParam1% AND %Exp:cParam2% 
                  AND GQY.GQY_CODCLI BETWEEN %Exp:cParam3% AND %Exp:cParam4% 
                  AND GQY.GQY_DTEMIS BETWEEN %Exp:cParam5% AND %Exp:cParam6% 
                  AND GQY.GQY_DTFECH BETWEEN %Exp:cParam7% AND %Exp:cParam8% 
                  AND GQY.GQY_STATUS = %Exp:cParam9% 
          EndSQL
      oSection:EndQuery()
      If (cAliasGQY)->(!EOF())
            oSection:Print()
      Else
             FwAlertHelp(STR0011, STR0012, STR0013) // "Não foram encontrados registros para esse relatório", "Verifique os dados de filtros", "Atenção!"
      Endif
Return