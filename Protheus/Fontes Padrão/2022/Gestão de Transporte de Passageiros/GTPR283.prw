#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'GTPR283.CH'

 //-------------------------------------------------------------------
/*/{Protheus.doc} GTPR283()
Relatório de requisições 

@sample GTPR283()

@author	Renan Ribeiro Brando -  Inovação
@since	08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Function GTPR283()
       Local oReport     := Nil
       If Pergunte("GTPR283", .T.)
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
      Local cAliasGQW := GetNextAlias()
      //---------------------------------------
      // Criação do componente de impressão
      //---------------------------------------
      oReport := TReport():New("GTPR283", STR0001, "GTPR283", {|oReport| ReportPrint(oReport, cAliasGQW)}, "" ) // "Requisições"
      oReport:SetTotalInLine(.F.)
      
      oSection := TRSection():New(oReport, STR0001, "GQW", /*{Array com as ordens do relatório}*/, /*Campos do SX3*/, /*Campos do SIX*/) // "Requisições"
      oSection:SetTotalInLine(.F.)
      oSection:SetAutoSize(.F.)

      TRCell():New(oSection, "GQW_CODIGO", "GQW", STR0003, X3Picture("GQW_CODIGO"), /*lTamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // Código da Requisição
      TRCell():New(oSection, "GQW_REQDES", "GQW", STR0004, X3Picture("GQW_REQDES"), /*lTamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // Código do Requisição
      TRCell():New(oSection, "GQW_CODCLI", "GQW", STR0005, X3Picture("GQW_CODCLI"), /*lTamanho*/, /*lPixel*/,  /*{|| code-block de impressao }*/ ) // Código Cliente
      TRCell():New(oSection, "GQW_CODLOJ", "GQW", STR0006, X3Picture("GQW_CODLOJ"), /*lTamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // Código Loja
      TRCell():New(oSection, "GQW_NOMCLI", "GQW", STR0007, X3Picture("GQW_NOMCLI"), /*lTamanho*/, /*lPixel*/, {||POSICIONE('SA1',1,xFilial('SA1') + (cAliasGQW)->GQW_CODCLI+ (cAliasGQW)->GQW_CODLOJ,'A1_NOME')}) // Nome Cliente
      TRCell():New(oSection, "GQW_CODAGE", "GQW", STR0008, X3Picture("GQW_CODAGE"), /*lTamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // Agência
      TRCell():New(oSection, "GQW_DATEMI", "GQW", STR0009, X3Picture("GQW_DATEMI"), /*lTamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // Data Emissão
      TRCell():New(oSection, "GQW_STATUS", "GQW", STR0010, X3Picture("GQW_STATUS"), /*lTamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // Status
      TRCell():New(oSection, "GQW_TOTAL" , "GQW", STR0011, X3Picture("GQW_TOTAL") , /*lTamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // Total   
             
      TRFunction():New(oSection:Cell("GQW_TOTAL") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

      oSection:SetLeftMargin(5) 
      oSection:SetTotalInLine(.F.) 
       
      oSection:Cell("GQW_CODIGO"):lHeaderSize := .F.
      oSection:Cell("GQW_REQDES"):lHeaderSize := .F.
      oSection:Cell("GQW_CODCLI"):lHeaderSize := .F.
      oSection:Cell("GQW_CODLOJ"):lHeaderSize := .F.
      oSection:Cell("GQW_NOMCLI"):lHeaderSize := .F.
      oSection:Cell("GQW_CODAGE"):lHeaderSize := .F.
      oSection:Cell("GQW_DATEMI"):lHeaderSize := .F.
      oSection:Cell("GQW_STATUS"):lHeaderSize := .F.
      oSection:Cell("GQW_TOTAL"):lHeaderSize := .F.

Return oReport
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()
@sample ReportPrint()

@author	Renan Ribeiro Brando -  Inovação
@since	08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport, cAliasGQW)
      
      Local oSection := oReport:Section(1)
      Local cParam1  := cValToChar(MV_PAR01) // Código de?
      Local cParam2  := cValToChar(MV_PAR02) // Código até?
      Local cParam3  := DTOS(MV_PAR03) // Data de emissão de?
      Local cParam4  := DTOS(MV_PAR04) // Data de emissão até?
      Local cParam5  := cValToChar(MV_PAR05) // Cliente de?
      Local cParam6  := cValToChar(MV_PAR06) // Cliente até?
      Local cParam7  := cValToChar(MV_PAR07) // Agência de?
      Local cParam8  := cValToChar(MV_PAR08) // Agência até?
      Local cParam9  := cValToChar(MV_PAR09) // Status igual?
      //---------------------------------------
      // Query do relatório da secao 1
      //---------------------------------------
      oSection:BeginQuery()
          BeginSQL Alias cAliasGQW
            SELECT 
                  GQW.GQW_CODIGO, GQW.GQW_REQDES, GQW.GQW_CODCLI, 
                  GQW.GQW_CODLOJ, GQW.GQW_CODAGE, GQW.GQW_DATEMI, 
                  GQW.GQW_STATUS, GQW.GQW_TOTAL 
            FROM 
                  %table:GQW% GQW
            WHERE 
                  GQW.GQW_FILIAL = %xFilial:GQW%
              	AND GQW.%NotDel%  
                  AND GQW.GQW_CODIGO BETWEEN %Exp:cParam1% AND %Exp:cParam2% 
                  AND GQW.GQW_DATEMI BETWEEN %Exp:cParam3% AND %Exp:cParam4% 
                  AND GQW.GQW_CODCLI BETWEEN %Exp:cParam5% AND %Exp:cParam6% 
                  AND GQW.GQW_CODAGE BETWEEN %Exp:cParam7% AND %Exp:cParam8% 
                  AND GQW.GQW_STATUS = %Exp:cParam9% 
          EndSQL
      oSection:EndQuery()

      If (cAliasGQW)->(!EOF())
            oSection:Print()
      Else
            FwAlertHelp(STR0012, STR0013, STR0014) // "Não foram encontrados registros para esse relatório", "Verifique os dados de filtros", "Atenção!"
      Endif
Return