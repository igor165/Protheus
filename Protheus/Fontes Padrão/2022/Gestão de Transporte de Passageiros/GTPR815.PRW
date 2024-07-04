#INCLUDE "TOTVS.ch"
#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "GTPR815.CH"
#INCLUDE "FWPrintSetup.ch"


/*/
 * {Protheus.doc} GTPR815()
 * Relatório de Pendências de Entrega
 * type    Function
 * author  Eduardo Ferreira
 * since   10/12/2019
 * version 12.25
 * param   Não há
 * return  Não há
/*/
Function GTPR815()
Local oReport := Nil
Local cPerg   := 'GTPR815'

If Pergunte(cPerg, .T.)
    oReport := ReportDef(cPerg)
    oReport:PrintDialog()
EndIf

Return

/*/
 * {Protheus.doc} ReportDef()
 * Montagem do Relatorio 
 * type    Static Function
 * author  Eduardo Ferreira
 * since   10/12/2019
 * version 12.25
 * param   Não há
 * return  oReport
/*/
Static Function ReportDef(cPerg)
Local oReport    := Nil
Local oSection1  := Nil	
Local oSection2  := Nil	
Local oBreak     := Nil
Local cTitle     := STR0001 //'Relatório de Pendências de Entrega'
Local cHelp      := STR0001 //'Relatório de Pendências de Entrega'

oReport := TReport():New('GTPR815', cTitle, cPerg, {|oReport|ReportPrint(oReport)}, cHelp, .T.,, .F.,, .F., .F.,)

oSection1 := TRSection():New(oReport, "Agencia", {"G99", "GI6"},, .F., .F.,, .F.,,,,,,,,,,,,,,)

TRCell():New(oSection1, "GI6_FILRES", "G99", STR0002,, TamSx3('GI6_FILRES')[1],,,,,,,5,,,,) //'FILIAL'
TRCell():New(oSection1, "G99_CODREC", "G99", STR0003,, TamSx3('G99_CODEMI')[1],,,,,,,5,,,,) //'AG. RECEBEDORA'
TRCell():New(oSection1, "GI6_DESCRI", "GI6", STR0004,, TamSx3('GI6_DESCRI')[1],,,,,,,5,,,,) //'DESCRIÇÃO'

oSection2 := TRSection():New(oSection1, "Cliente", {"G99", "SA1", "SB1"},, .F., .F.,, .F.,,,,,,,,,,4,,,,) 

TRCell():New(oSection2, "G99_CODIGO", "G99", STR0005,, TamSx3('G99_CODIGO')[1],,,,,,,,.T.,,,) //'ENCOMENDAS'
TRCell():New(oSection2, "G99_DTEMIS", "G99", STR0006,, TamSx3('G99_DTEMIS')[1],,,,,,,,.T.,,,) //'DT. ENTRADA'
TRCell():New(oSection2, "G99_DTRECB", "G99", STR0007,, TamSx3('G99_DTRECB')[1],,,,,,,,.T.,,,) //'DT. RECEBIMENTO'
TRCell():New(oSection2, "TOTDIAS"   , "G99", STR0008,, TamSx3('G99_DTRECB')[1],,,,,,,,.T.,,,) //'DIAS PARADO'
TRCell():New(oSection2, "PRODUTO"   , "G99", STR0009,, TamSx3('B1_DESC'   )[1],,,,,,,,.T.,,,) //'PRODUTOS'
TRCell():New(oSection2, "AGENCIA"   , "G99", STR0016,, TamSx3('GI6_DESCRI')[1],,,,,,,,.T.,,,) //'AG. EMITENTE'
TRCell():New(oSection2, "G99_CLIREM", "G99", STR0011,, TamSx3('G99_CLIREM')[1],,,,,,,,.T.,,,) //'CLIENTE'
TRCell():New(oSection2, "G99_LOJREM", "G99", STR0012,, TamSx3('G99_LOJREM')[1],,,,,,,,.T.,,,) //'LOJA'
TRCell():New(oSection2, "A1_NOME"   , "SA1", STR0013,, TamSx3('A1_NOME'   )[1],,,,,,,,.T.,,,) //'NOME'
TRCell():New(oSection2, "A1_TEL"    , "SA1", STR0014,, TamSx3('A1_TEL'    )[1],,,,,,,,.T.,,,) //'TEL.'
TRCell():New(oSection2, "A1_EMAIL"  , "SA1", STR0015,, TamSx3('A1_EMAIL'  )[1],,,,,,,,.T.,,,) //'E-MAIL'

oSection2:Cell('TOTDIAS'):SetBlock({|| dDatabase - cTod(oSection2:Cell('G99_DTRECB'):GetText())})

oBreak := TRBreak():New(oSection1, {|| }, "", .F.,, .T.) 
oBreak:SetPageBreak(.T.)  

Return oReport
 

/*/
 * {Protheus.doc} PrintDialog()
 * Chamada da query
 * type    Static Function
 * author  Eduardo Ferreira
 * since   10/12/2019
 * version 12.25
 * param   oReport
 * return  Não há
/*/
Static Function ReportPrint(oReport)
Local oSection1 := oReport:Section("Agencia")

SetQrySection(oReport)
oSection1:Print()

Return


/*/
 * {Protheus.doc} SetQrySection()
 * Montagem da query
 * type    Static Function
 * author  Eduardo Ferreira
 * since   10/12/2019
 * version 12.25
 * param   oReport
 * return  Não há
/*/
Static Function SetQrySection(oReport)
Local oSection1  := oReport:Section("Agencia")
Local oSection2  := oSection1:Section("Cliente")
Local cAliasSec1 := GetNextAlias()
Local cAliasSec2 := GetNextAlias()
Local dDTRec     := ddatabase - MV_PAR03
Local cAgeDe     := MV_PAR01
Local cAgeAte    := MV_PAR02

oSection1:BeginQuery()
	BeginSql Alias cAliasSec1
		SELECT 
            Distinct(G99_CODREC),
            GI6.GI6_DESCRI,
            GI6.GI6_FILRES
        FROM 
            %Table:G99% G99
            JOIN %Table:GI6% GI6
                ON GI6.GI6_FILIAL = %xFilial:GI6%
                AND GI6.GI6_CODIGO = G99.G99_CODREC
                AND GI6.%NotDel%
		WHERE
            G99.G99_FILIAL = %xFilial:G99%
            AND G99.G99_CODREC BETWEEN %Exp:cAgeDe% AND %Exp:cAgeAte%
            AND G99.G99_STAENC  = '4'
            AND G99.G99_DTRECB <> ''
            AND G99.G99_DTRECB <= %eXP:dDTRec%
			AND G99.%NotDel%
	EndSql

oSection1:EndQuery()    

oSection2:BeginQuery()
	BeginSql Alias cAliasSec2
        SELECT
            G99.G99_CODREC,
            G99.G99_DTEMIS,
            G99.G99_NUMDOC,
            G99.G99_DTRECB,
            G99.G99_CLIREM,
            G99.G99_LOJREM,
            G99.G99_CODIGO,
            GI6.GI6_DESCRI AS AGENCIA,
            SB1.B1_DESC AS PRODUTO,
            SB1.B1_DESC,
            SA1.A1_EMAIL,
	        SA1.A1_TEL,
            SA1.A1_NOME   
        FROM 
        %Table:G99% G99
            JOIN %Table:GI6% GI6
                ON GI6.GI6_FILIAL = %xFilial:GI6%
                AND GI6.GI6_CODIGO = G99.G99_CODEMI
                AND GI6.%NotDel%
            JOIN %Table:SA1% SA1 
                ON SA1.A1_FILIAL = %xFilial:SA1%
                AND SA1.A1_COD = G99.G99_CLIDES
                AND SA1.%NotDel%
            JOIN %Table:SB1% SB1 
                ON SB1.B1_FILIAL = %xFilial:SB1%
                AND SB1.B1_COD = G99.G99_CODPRO
                AND SB1.%NotDel%
		WHERE
            G99.G99_FILIAL = %xFilial:G99%
            AND G99.G99_CODREC BETWEEN %Exp:cAgeDe% AND %Exp:cAgeAte%
            AND G99.G99_STAENC  = '4'
            AND G99.G99_DTRECB <> ''
            AND G99.G99_DTRECB <= %eXP:dDTRec%
            AND G99.%NotDel%
        ORDER BY G99_DTRECB 
	EndSql

oSection2:EndQuery()   

oSection2:SetParentFilter({|cParam| Rtrim((cAliasSec2)->(G99_CODREC))== cParam},{|| Rtrim((cAliasSec1)->(G99_CODREC))})

Return nil
