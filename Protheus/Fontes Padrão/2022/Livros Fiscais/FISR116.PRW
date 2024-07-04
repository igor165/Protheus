#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FWCOMMAND.CH"

Function FISR116()
  
local oReport
local cAlias := getNextAlias()
lOCAL cMsgX1	:= ''
Local lContinua	:= .T.


IF aliasindic("F0M")
	If Pergunte('FSR116', .T.)
		
		cMsgX1		:= VldSx1()		
		If len(Alltrim(cMsgX1)) > 0				
			MsgAlert(cMsgX1)
			lContinua	:= .F.		
		EndIF
		
		If lContinua
			oReport := reportDef(cAlias, 'FSR116')
			oReport:printDialog()
		EndIF
	EndIF
Else
	Alert('Dicionário desatualizado, favor verificar atualizações do compatibilizador u_updsigafis')
EndIF

return
        
//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relatório.                                  !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)
              
local oSecao1 := oReport:Section(1)
Local cAliasQry := GetNextAlias()
Local nX	:= 0
Local cFiltro	:= ''
Local cJoin		:= ''
Local aSelFil	:={}
local aFil	:= {}
Local nContFil	:= 0
Local aAreaSM0 := SM0->(GetArea())

aSelFil	:= MatFilCalc( .T. )		
aFil		:= GetFil(aSelFil)

If len(aFil) ==0
	MsgAlert('Nenhuma filial foi selecionada, o processamento não será realizado.')
Else
	For nContFil := 1 to Len(aFil)
		cUfIE	:= ''
		SM0->(DbGoTop ())
		SM0->(MsSeek (aFil[nContFil][1]+aFil[nContFil][2], .T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL

		cFiltro = "%"
		cFiltro += "F0M.F0M_FILIAL		= '"	+ xFilial('F0M')				+ "' AND "
		cFiltro += "F0M.F0M_DTFECH		= '" 	+ %Exp:DToS (mv_par01)% 		+ "' AND "
		cFiltro += "F0M.D_E_L_E_T_		= '' "
		cFiltro += "%"
		
		cJoin	+="%INNER JOIN "+RetSqlName("SB1")+" SB1 ON (SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD = F0M.F0M_CODIGO AND SB1.D_E_L_E_T_=' ') "
		cJoin 	+= '%'
		
		oSecao1:BeginQuery()
		
		BeginSql Alias cAliasQry
			
			SELECT
				F0M.F0M_FILIAL,F0M.F0M_REGRA,F0M.F0M_CODIGO,SB1.B1_DESC,F0M.F0M_QUANT,F0M.F0M_CST,F0M.F0M_SITUA,F0M.F0M_CLIFOR,F0M.F0M_LOJA,F0M.F0M_BASICM,F0M.F0M_ALIQ,F0M.F0M_VALICM,F0M_TOTICM
			FROM
				%TABLE:F0M% F0M
				%Exp:cJoin%				
			WHERE
				%Exp:cFiltro%	
			ORDER BY 
				F0M.F0M_REGRA,F0M.F0M_CODIGO,F0M.F0M_SITUA,F0M.F0M_CST
				EndSql
		
		oReport:SetTitle("Listagem produtos Iventario ")
		oSecao1:EndQuery()
		oReport:SetMeter((cAliasQry)->(RecCount()))
		oSecao1:Print() 
	
	Next nContFil
	
	RestArea (aAreaSM0)
	cFilAnt := FWGETCODFILIAL

EndIF

return

//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório.                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias,cPerg)

local cTitle  := "Listagem produtos Iventario "
local cHelp   := "Listagem produtos Iventario para compor SPED FISCAL bloco H, registro H020"
local oReport
local oSection1
Local aFields   := { }
Local nI	:= 0
Local oBreak 
Local oTotal   

oReport := TReport():New('H020',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)
oReport:SetLandscape()

//Primeira seção
oSection1 := TRSection():New(oReport,"Iventario",{"FM0"}) 
//F0M.F0M_FILIAL,F0M.F0M_REGRA,F0M.F0M_CODIGO,F0M.F0M_DESPRO,F0M.F0M_QUANT,F0M.F0M_CST,F0M.F0M_SITUA,F0M.F0M_CLIFOR,F0M.F0M_LOJA,F0M.F0M_BASICM,F0M.F0M_ALIQ,F0M.F0M_VALICM,F0M_TOTICM

TRCell():New(oSection1,"F0M_FILIAL"	,  "FM0", "Filial")
TRCell():New(oSection1,"F0M_REGRA"	,  "FM0", "Regra de Calculo")
TRCell():New(oSection1,"F0M_CODIGO"	,  "FM0", "Codigo")
TRCell():New(oSection1,"B1_DESC", 	   "SB1", "Descrição")
TRCell():New(oSection1,"F0M_QUANT"	,  "FM0", "Quantidade")
TRCell():New(oSection1,"F0M_CST"	,  "FM0", "Clas. Fiscal")
TRCell():New(oSection1,"F0M_SITUA"	,  "FM0", "Situação")
TRCell():New(oSection1,"F0M_CLIFOR"	,  "FM0", "Cliente/Fornecedor")
TRCell():New(oSection1,"F0M_LOJA"	,  "FM0", "Loja")
TRCell():New(oSection1,"F0M_BASICM"	,  "FM0", "Base Unit. ICM")
TRCell():New(oSection1,"F0M_ALIQ"	,  "FM0", "Aliq. ICMS")
TRCell():New(oSection1,"F0M_VALICM"	,  "FM0", "Val. Unit. ICM")
TRCell():New(oSection1,"F0M_TOTICM"	,  "FM0", "Total ICMS")

TRFunction():New(oSection1:Cell("F0M_TOTICM"),Nil,"SUM",/*oBreak2*/,"Valor Total ICMS","999,999,999.99",/*uFormula*/,.F.,.T.) // "Total de documentos importados sem erro: "
//oTotal := TRFunction():New(oSection1:Cell("F0M_TOTICM"),Nil,"SUM",/*oBreak2*/,"Valor Total ICMS","9999999999",/*uFormula*/,.F.,.T.) // "Total de documentos importados sem erro: "
//oTotal:SetCondition({ || NFE->IMPORT == "1" })


oBreak := TRBreak():New(oSection1,oSection1:Cell("F0M_REGRA"),"Regra",.t.,'Regra',.T.)
oSection1:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection1:SetPageBreak(.T.) //Pula de página após quebra
oSection1:SetHeaderSection(.T.)

Return(oReport)


Static Function GetFil(aSelFil)

Local aAreaSM0	:= {}
Local aSM0			:= {}
local nFil			:= 0

aAreaSM0 := SM0->(GetArea())
DbSelectArea("SM0")

//--------------------------------------------------------
//Irá preencher aSM0 somente com as filiais selecionadas
//pelo cliente  
//--------------------------------------------------------
If Len(aSelFil)> 0

	SM0->(DbGoTop())
	If SM0->(MsSeek(cEmpAnt))
		Do While !SM0->(Eof()) 
			nFil := Ascan(aSelFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
			If nFil > 0 .And. aSelFil[nFil][1] .AND. cEmpAnt == SM0->M0_CODIGO
				Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
			EndIf
			SM0->(dbSkip())
		Enddo
	EndIf
	
	SM0->(RestArea(aAreaSM0))
EndIF

Return aSM0

Static Function VldSx1()
Local cMensagem	:= ''

If Empty(mv_par01) 
	cMensagem	:= 'É necessário informar data de fechamento de estoque conforme relatrio (P7)"
EndIF

Return cMensagem