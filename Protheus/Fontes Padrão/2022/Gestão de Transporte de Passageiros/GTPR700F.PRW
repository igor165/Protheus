#INCLUDE "TOTVS.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "GTPR700F.ch"


/*/{Protheus.doc} GTPR700F()
 * chamada da view
 * type  Function
 * author Eduardo Ferreira
 * since 03/07/2020
 * version 12.1.30
 * param oView
 * return não há
/*/
Function GTPR700F(oView)
Local oReport := Nil
Local cPerg   := 'GTPR700F'

If CHKFILE("GQN")
    If !FwIsInCall('GTPA700F')
        If Pergunte(cPerg, .T.)
            oReport := ReportDef(cPerg)
            oReport:PrintDialog()
        EndIf 
    Else 
        if oView:GetModel('GQNDETAIL'):Length() >=1 .AND. !oView:GetModel('GQNDETAIL'):IsEmpty()
            MV_PAR01 := oView:GetModel('CABMASTER'):GetValue('AGINI')
            MV_PAR02 := oView:GetModel('CABMASTER'):GetValue('AGFIN')
            MV_PAR03 := oView:GetModel('CABMASTER'):GetValue('DTDE')
            MV_PAR04 := oView:GetModel('CABMASTER'):GetValue('DTATE')

            oReport := ReportDef(cPerg)
            oReport:PrintDialog()
        else 
            MsgAlert(STR0002, STR0001) //"Atenção! " //"Não existe consulta para impressão do relatorio. "
        endif 
    EndIf
Else 
    MsgAlert(STR0003, STR0001) //"Não é possivel gerar o relatorio, tabela GQN não existe. "
EndIf

Return


/*/
 * {Protheus.doc} ReportDef()
 * Montagem do Relatorio 
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/07/2020
 * version 12.30
 * param   Não há
 * return  oReport
/*/
Static Function ReportDef(cPerg)
Local oReport    := Nil
Local oSection   := Nil	
Local oSection1  := Nil	
Local oBreak     := Nil
Local cTitle     := STR0004 //'Relatório Saldos da conta corrente'
Local cHelp      := STR0004 //'Relatório Saldos da conta corrente'

oReport := TReport():New('GTPR700F', cTitle, cPerg, {|oReport|ReportPrint(oReport)}, cHelp, .T.,, .F.,, .F., .F.,)

oSection := TRSection():New(oReport, STR0005, {"GQN"}) //"Agência"

TRCell():New(oSection, "GQN_AGENCI", "GQN", STR0006,, TamSx3('GQN_AGENCI')[1],,,,,,,5,,,,)  //"Agencia"
TRCell():New(oSection, "GI6_DESCRI", "GQN", STR0007,, TamSx3('GQN_DESCAG')[1],,,,,,,5,,,,)  //"Descrição"

oSection1 := TRSection():New(oReport, STR0008, {"GQN"}) //"Saldos da conta corrente"
TRCell():New(oSection1, "GQN_DATA"  , "GQN", STR0009,, TamSx3('GQN_DATA'  )[1],,,,,,,5,,,,)  //"Data"
TRCell():New(oSection1, "GQN_NUMFCH", "GQN", STR0010,, TamSx3('GQN_NUMFCH')[1],,,,,,,5,,,,)  //"Número Ficha"
TRCell():New(oSection1, "GQN_FCHDES", "GQN", STR0011,, TamSx3('GQN_FCHDES')[1],,,,,,,5,,,,)  //"Fch Destino "
TRCell():New(oSection1, "GQN_TPDIFE", "GQN", STR0012,, TamSx3('GQN_TPDIFE')[1],,,,,,,5,,,,)  //"TP Diferença"
TRCell():New(oSection1, "GQN_VLDIFE", "GQN", STR0013,, TamSx3('GQN_VLDIFE')[1],,,,,,,5,,,,)  //"Vl diferença"
TRCell():New(oSection1, "GQN_CDCAIX", "GQN", STR0014,, TamSx3('GQN_CDCAIX')[1],,,,,,,5,,,,) //"Caixa"
TRCell():New(oSection1, "GQN_CODIGO", "GQN", STR0015,, TamSx3('GQN_CODIGO')[1],,,,,,,5,,,,) //"Codigo"

oSection1:SetLeftMargi(5)
oSection1:SetTotalInLine(.F.)

oBreak := TRBreak():New(oSection, oSection:Cell("GQN_AGENCI"), STR0006, .F., "GQN_AGENCI", .F.)  //"Agencia"

oBreak1 := TRBreak():New(oSection1, oSection1:Cell("GQN_NUMFCH"), STR0006, .F., "GQN_AGENCI", .F.)  //"Agencia"

Return oReport
 

/*/
 * {Protheus.doc} PrintDialog()
 * Chamada da query
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/07/2020
 * version 12.30
 * param   oReport
 * return  Não há
/*/
Static Function ReportPrint(oReport)
Local oSecCbEx	:= oReport:Section(1)
Local oSection1 := oReport:Section(2)
Local cAliasTmp := ""
Local cAgencia  := ""

cAliasTmp := SetQrySection()

DbSelectArea(cAliasTmp)
(cAliasTmp)->(dbGoTop())
oReport:SetMeter((cAliasTmp)->(RecCount()))

While (cAliasTmp)->(!Eof())
    If oReport:Cancel()
        Exit
    EndIf

    oReport:IncMeter()

    If EMPTY(cAgencia) .OR. cAgencia != (cAliasTmp)->GQN_AGENCI
        cAgencia := (cAliasTmp)->GQN_AGENCI
        If !(EMPTY(cAgencia))
            oReport:SkipLine()
            oSection1:Finish()
            oSecCbEx:Finish()
        EndIf
        oSecCbEx:Init()		
	
        oSecCbEx:Cell("GQN_AGENCI"):SetValue((cAliasTmp)->GQN_AGENCI)
        oSecCbEx:Cell("GQN_AGENCI"):SetBorder("BOTTOM",0,0,.T.)
        
        oSecCbEx:Cell("GI6_DESCRI"):SetValue((cAliasTmp)->GI6_DESCRI)
        oSecCbEx:Cell("GI6_DESCRI"):SetBorder("BOTTOM",0,0,.T.)

        oSecCbEx:PrintLine()
    EndIf 

    oSection1:init()
    oSection1:Cell("GQN_DATA"  ):SetValue((cAliasTmp)->GQN_DATA  )
    oSection1:Cell("GQN_NUMFCH"):SetValue((cAliasTmp)->GQN_NUMFCH)
    oSection1:Cell("GQN_FCHDES"):SetValue((cAliasTmp)->GQN_FCHDES)
    oSection1:Cell("GQN_TPDIFE"):SetValue((cAliasTmp)->GQN_TPDIFE)
    oSection1:Cell("GQN_VLDIFE"):SetValue((cAliasTmp)->GQN_VLDIFE)
    oSection1:Cell("GQN_CDCAIX"):SetValue((cAliasTmp)->GQN_CDCAIX)
    oSection1:Cell("GQN_CODIGO"):SetValue((cAliasTmp)->GQN_CODIGO)
    oSection1:PrintLine()

    (cAliasTmp)->(dbSkip())
End

(cAliasTmp)->(DbCloseArea())
oSection1:Finish()
oSecCbEx:Finish()
Return


/*/
 * {Protheus.doc} SetQrySection()
 * Montagem da query
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/07/2020
 * version 12.30
 * param   oReport
 * return  Não há
/*/
Static Function SetQrySection()
Local cAliasSec1 := GetNextAlias()
Local cAgIni     := MV_PAR01
Local cAgFin     := MV_PAR02
Local dDtDe      := MV_PAR03
Local dDtAte     := MV_PAR04

	BeginSql Alias cAliasSec1
	    SELECT 
	    	GQN.GQN_AGENCI, 
		    GQN.GQN_CODIGO,
		    GQN.GQN_DATA ,
		    GQN.GQN_NUMFCH,
		    GQN.GQN_FCHDES,
		    GQN.GQN_TPDIFE,
		    GQN.GQN_VLDIFE,
		    GQN.GQN_ORIGEM,
		    GQN.GQN_CDCAIX,
            GI6.GI6_DESCRI
        FROM 
            %Table:GQN% GQN JOIN %Table:GI6% GI6 
	        ON  GI6.GI6_FILIAL = %xFilial:GI6%
	        AND GI6.GI6_CODIGO = GQN.GQN_AGENCI 
	        AND GI6.%NotDel%
	    WHERE
            GQN.GQN_FILIAL = %xFilial:GQN%
	    	AND GQN.GQN_AGENCI BETWEEN %Exp:cAgIni% AND %Exp:cAgFin%
	    	AND GQN.GQN_DATA BETWEEN %Exp:dDtDe% AND %Exp:dDtAte%
	    	AND GQN.%NotDel%
    EndSql
 
Return cAliasSec1
