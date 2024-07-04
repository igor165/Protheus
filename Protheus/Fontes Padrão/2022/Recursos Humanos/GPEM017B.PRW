#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM017.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEM017B
Importação dos dados das tabelas do TAF/TSS para o Middleware
@author  Allyson L Mesashi
@since   30/09/2019
@version  1
/*/
//-------------------------------------------------------------------
Function GPEM017B()

Local aStru				:= {}
Local aLstIndices		:= {}
Local nCont				:= 0
Local oNewPag   		:= Nil
Local oStepWiz  		:= Nil

Private aArrayFil		:= {}
Private aSM0     		:= FWLoadSM0(.T.,,.T.)
Private cAliasTRB		:= GetNextAlias()
Private cIdEntidade		:= ""
Private cNumThrd		:= "01"
Private cPerDe			:= Space(6)
Private cPerAte			:= Space(6)
Private lInExec			:= .F.
Private lConcl			:= .F.
Private nRemoteType		:= GetRemoteType()
Private oArq1Tmp		:= Nil

Private aLogErr        	:= {}
Private aLogImp       	:= {}
Private aLogProc       	:= {}
Private aLogTab       	:= {}
Private aTitle         	:= { OemToAnsi(STR0364), OemToAnsi(STR0373), OemToAnsi(STR0359), OemToAnsi(STR0365) }//""Processamento"##"Erro na Importação"##"Falha na Importação do XML"##"Registros Importados"
Private cTimeIni		:= Time()

Private aXmls         	:= {}
Private aXmlsRetorno  	:= {}
Private aXmlsLote     	:= {}
Private cIdXML			:= ""
Private cTSSKey			:= ""
Private cUrlTSS			:= fGetUrlTSS()
Private nTamLote      	:= 50
Private nContLote     	:= 0

Private lOpc01 			:= .F.
Private lOpc02 			:= .F.
Private lOpc03 			:= .F.
Private lOpc04 			:= .F.
Private lOpc05 			:= .F.
Private lOpc06 			:= .F.
Private lOpc07 			:= .F.
Private lOpc08 			:= .F.
Private lOpc09 			:= .F.
Private lOpc10 			:= .F.
Private lOpc11 			:= .F.
Private lOpc12 			:= .F.
Private lOpc13 			:= .F.
Private lOpc14 			:= .F.
Private lOpc15 			:= .F.
Private lOpc16 			:= .F.
Private lOpc17 			:= .F.
Private lOpc18 			:= .F.
Private lOpc19 			:= .F.
Private lOpc20 			:= .F.
Private lOpc21 			:= .F.
Private lOpc22 			:= .F.
Private lOpc23 			:= .F.
Private lOpc24 			:= .F.
Private lOpc25 			:= .F.
Private lOpc26 			:= .F.
Private lOpc27 			:= .F.
Private lOpc28 			:= .F.
Private lOpc29 			:= .F.
Private lOpc30 			:= .F.
Private lOpc31 			:= .F.
Private lOpc32 			:= .F.
Private lOpc33 			:= .F.
Private lOpc34 			:= .F.
Private lOpc35 			:= .F.
Private lOpc36 			:= .F.
Private nQtdSel 		:= 0
Private nTotProc 		:= 0

If !ChkFile("RJE")
	//ATENCAO"###"Tabela RJ9 e RJE não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
	Help( " ", 1, OemToAnsi(STR0228),, OemToAnsi(STR0258), 1, 0 )
	Return
EndIf

If !fGetIdEntidade(cUrlTSS, @cIdEntidade)
	Return
EndIf

aAdd( aLogProc, STR0366 + dToC( Date() ) )//"Data de início: "
aAdd( aLogProc, STR0367 + Time() )//"Hora de início: "

Aadd(aStru, {"OK"		, "C", 2						, 0})
Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
Aadd(aStru, {"NOME"  	, "C", 100						, 0})
Aadd(aStru, {"CNPJ"  	, "C", TamSx3("CTT_CEI")[1]  	, 0})
AAdd(aLstIndices, {"FILIAL"})

oArq1Tmp := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

For nCont := 1 To Len(aSM0)
	If aSM0[nCont, 1] == cEmpAnt
		RecLock(cAliasTRB, .T.)
			(cAliasTRB)->FILIAL	:= aSM0[nCont, 2]
			(cAliasTRB)->NOME  	:= aSM0[nCont, 7]
			(cAliasTRB)->CNPJ 	:= aSM0[nCont, 18]
		(cAliasTRB)->(MsUnlock())
	EndIf
Next nCont

oStepWiz := FWWizardControl():New()
oStepWiz:ActiveUISteps()

oNewPag := oStepWiz:AddStep("1")
oNewPag:SetStepDescription(STR0274)//"Observações"
oNewPag:SetConstruction( { |Panel1| fPag1(Panel1) } )
oNewPag:SetNextAction( {|| .T. } )
oNewPag:SetCancelAction( {|| .T.} )

oNewPag := oStepWiz:AddStep("2")
oNewPag:SetStepDescription(STR0304)//"Eventos"
oNewPag:SetConstruction( { |Panel2| fPag2(Panel2) } )
oNewPag:SetNextAction( {|| fVldOpc() .And. !MigrInExec() } )
oNewPag:SetCancelAction( {|| .T. })

oNewPag := oStepWiz:AddStep("3")
oNewPag:SetStepDescription(STR0275)//"Processamento"
oNewPag:SetConstruction( { |Panel3| fPag3(Panel3) } )
oNewPag:SetPrevAction( {|| !MigrConcl() } )
oNewPag:SetNextAction( {|| !MigrInExec() } )
oNewPag:SetCancelAction( {|| .T. })

oNewPag:SetPrevWhen({|| !MigrInExec() })
oNewPag:SetCancelWhen({|| !MigrInExec() })

oStepWiz:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag1
Painel com os descritivos do assistente
@author  Allyson L Mesashi
@since   30/09/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fPag1(oPanel)

Local oButtonProc	:= Nil

TSay():New(25, 20, {||  fText("BEMVINDO")      }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)
TSay():New(45, 20, {||  fText("ASSIST")        }, oPanel,,,,,,.T.,,,300,300,,,,,,.T.)

oButtonProc  := TButton():New( 120, 25, OemToAnsi(STR0305), oPanel, {|| ShellExecute("open","http://tdn.totvs.com/x/GiUAHw","","",1)},; //"Clique para abrir a documentação no TDN"
																							250, 15,,, .F., .T., .F.,, .F.,,, .F.)

If nRemoteType <> 5
	oButtonProc:setCSS( fCSS("BTPROC") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag2
Painel com os descritivos do assistente
@author  Allyson L Mesashi
@since   30/09/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fPag2(oPanel)

Local oSayExec		:= Nil
Local nLin			:= 15

oScroll := TScrollArea():New(oPanel,01,01,100,100)
oScroll:Align := CONTROL_ALIGN_ALLCLIENT

@ 000,000 MSPANEL oPanel2 OF oScroll SIZE 300,350 COLOR CLR_HRED

oScroll:SetFrame( oPanel2 )

oSayExec := TSay():New(5, 10, { || STR0277 }, oPanel2,,,,,, .T.,,, 200,20)//"Tipo de Execução"

TcheckBox():New(nLin, 10, STR0276, {|| lOpc01 }, oPanel2, 300, 10, Nil, {|| lOpc01:=!lOpc01 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação da tabela T3M"
nLin += 10
TcheckBox():New(nLin, 10, STR0363, {|| lOpc36 }, oPanel2, 300, 10, Nil, {|| lOpc36:=!lOpc36 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação da tabela V3N"
nLin += 10
TcheckBox():New(nLin, 10, STR0302, {|| lOpc02 }, oPanel2, 300, 10, Nil, {|| lOpc02:=!lOpc02 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1000"
nLin += 10
TcheckBox():New(nLin, 10, STR0303, {|| lOpc03 }, oPanel2, 300, 10, Nil, {|| lOpc03:=!lOpc03 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1005"
nLin += 10
TcheckBox():New(nLin, 10, STR0306, {|| lOpc04 }, oPanel2, 300, 10, Nil, {|| lOpc04:=!lOpc04 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1010"
nLin += 10
TcheckBox():New(nLin, 10, STR0321, {|| lOpc05 }, oPanel2, 300, 10, Nil, {|| lOpc05:=!lOpc05 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1020"
nLin += 10
TcheckBox():New(nLin, 10, STR0322, {|| lOpc06 }, oPanel2, 300, 10, Nil, {|| lOpc06:=!lOpc06 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1030"
nLin += 10
TcheckBox():New(nLin, 10, STR0323, {|| lOpc07 }, oPanel2, 300, 10, Nil, {|| lOpc07:=!lOpc07 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1035"
nLin += 10
TcheckBox():New(nLin, 10, STR0324, {|| lOpc08 }, oPanel2, 300, 10, Nil, {|| lOpc08:=!lOpc08 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1040"
nLin += 10
TcheckBox():New(nLin, 10, STR0325, {|| lOpc09 }, oPanel2, 300, 10, Nil, {|| lOpc09:=!lOpc09 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1050"
nLin += 10
TcheckBox():New(nLin, 10, STR0326+" [EM CONSTRUÇÃO]", {|| lOpc10 }, oPanel2, 300, 10, Nil, {|| lOpc10:=!lOpc10 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .F.})//"Importação Evento S-1060"
nLin += 10
TcheckBox():New(nLin, 10, STR0327, {|| lOpc11 }, oPanel2, 300, 10, Nil, {|| lOpc11:=!lOpc11 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1070"
nLin += 10
TcheckBox():New(nLin, 10, STR0345, {|| lOpc12 }, oPanel2, 300, 10, Nil, {|| lOpc12:=!lOpc12 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1200"
nLin += 10
TcheckBox():New(nLin, 10, STR0346, {|| lOpc13 }, oPanel2, 300, 10, Nil, {|| lOpc13:=!lOpc13 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1210"
nLin += 10
TcheckBox():New(nLin, 10, STR0347, {|| lOpc14 }, oPanel2, 300, 10, Nil, {|| lOpc14:=!lOpc14 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1280"
nLin += 10
TcheckBox():New(nLin, 10, STR0348, {|| lOpc15 }, oPanel2, 300, 10, Nil, {|| lOpc15:=!lOpc15 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1295"
nLin += 10
TcheckBox():New(nLin, 10, STR0349, {|| lOpc16 }, oPanel2, 300, 10, Nil, {|| lOpc16:=!lOpc16 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1298"
nLin += 10
TcheckBox():New(nLin, 10, STR0350, {|| lOpc17 }, oPanel2, 300, 10, Nil, {|| lOpc17:=!lOpc17 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1299"
nLin += 10
TcheckBox():New(nLin, 10, STR0351, {|| lOpc18 }, oPanel2, 300, 10, Nil, {|| lOpc18:=!lOpc18 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-1300"
nLin += 10
TcheckBox():New(nLin, 10, STR0328, {|| lOpc19 }, oPanel2, 300, 10, Nil, {|| lOpc19:=!lOpc19 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-2190"
nLin += 10
TcheckBox():New(nLin, 10, STR0329, {|| lOpc20 }, oPanel2, 300, 10, Nil, {|| lOpc20:=!lOpc20 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-2200"
nLin += 10
TcheckBox():New(nLin, 10, STR0330, {|| lOpc21 }, oPanel2, 300, 10, Nil, {|| lOpc21:=!lOpc21 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-2205"
nLin += 10
TcheckBox():New(nLin, 10, STR0331, {|| lOpc22 }, oPanel2, 300, 10, Nil, {|| lOpc22:=!lOpc22 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-2206"
nLin += 10
//TcheckBox():New(nLin, 10, STR0333+" [NÃO ESTÁ LIBERADO]", {|| lOpc23 }, oPanel2, 300, 10, Nil, {|| lOpc23:=!lOpc23 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .F.})//"Importação Evento S-2210"
//TcheckBox():New(nLin, 10, STR0334+" [NÃO ESTÁ LIBERADO]", {|| lOpc24 }, oPanel2, 300, 10, Nil, {|| lOpc24:=!lOpc24 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .F.})//"Importação Evento S-2220"
//TcheckBox():New(nLin, 10, STR0335+" [NÃO ESTÁ LIBERADO]", {|| lOpc25 }, oPanel2, 300, 10, Nil, {|| lOpc25:=!lOpc25 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .F.})//"Importação Evento S-2221"
TcheckBox():New(nLin, 10, STR0336, {|| lOpc26 }, oPanel2, 300, 10, Nil, {|| lOpc26:=!lOpc26 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-2230"
//TcheckBox():New(nLin, 10, STR0337+" [NÃO ESTÁ LIBERADO]", {|| lOpc27 }, oPanel2, 300, 10, Nil, {|| lOpc27:=!lOpc27 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .F.})//"Importação Evento S-2240"
//TcheckBox():New(nLin, 10, STR0338+" [NÃO ESTÁ LIBERADO]", {|| lOpc28 }, oPanel2, 300, 10, Nil, {|| lOpc28:=!lOpc28 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .F.})//"Importação Evento S-2245"
//TcheckBox():New(nLin, 10, STR0339+" [NÃO ESTÁ LIBERADO]", {|| lOpc29 }, oPanel2, 300, 10, Nil, {|| lOpc29:=!lOpc29 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .F.})//"Importação Evento S-2250"
//TcheckBox():New(nLin, 10, STR0340+" [NÃO ESTÁ LIBERADO]", {|| lOpc30 }, oPanel2, 300, 10, Nil, {|| lOpc30:=!lOpc30 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-2260"
nLin += 10
TcheckBox():New(nLin, 10, STR0341, {|| lOpc31 }, oPanel2, 300, 10, Nil, {|| lOpc31:=!lOpc31 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-2298"
nLin += 10
TcheckBox():New(nLin, 10, STR0342, {|| lOpc32 }, oPanel2, 300, 10, Nil, {|| lOpc32:=!lOpc32 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-2299"
nLin += 10
TcheckBox():New(nLin, 10, STR0332, {|| lOpc33 }, oPanel2, 300, 10, Nil, {|| lOpc33:=!lOpc33 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-2300"
nLin += 10
TcheckBox():New(nLin, 10, STR0343, {|| lOpc34 }, oPanel2, 300, 10, Nil, {|| lOpc34:=!lOpc34 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-2306"
nLin += 10
TcheckBox():New(nLin, 10, STR0344, {|| lOpc35 }, oPanel2, 300, 10, Nil, {|| lOpc35:=!lOpc35 }, Nil, Nil, Nil, ,.T., Nil, Nil, Nil, { || .T.})//"Importação Evento S-2399"
nLin += 10

If nRemoteType <> 5
	oSayExec:setCSS( fCSS("TEXTTITLE") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPag3
Painel com os descritivos do assistente
@author  Allyson L Mesashi
@since   04/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fPag3(oPanel)

Local oBtnFil		:= Nil
Local oButtonProc	:= Nil
Local oGetPerD		:= Nil
Local oGetPerA		:= Nil
Local oGetThrd		:= Nil
Local oSayExec		:= Nil
Local oSayForm		:= Nil
Local oSayPerD		:= Nil
Local oSayPerA		:= Nil
Local oSayThrd		:= Nil
Local oSayFil		:= Nil

oSayExec := TSay():New(20, 10, { || STR0307 }, oPanel,,,,,, .T.,,, 200,20)//"Parâmetros"

oSayThrd := TSay():New(35, 10, { || STR0308 }, oPanel,,,,,, .T.,,, 60,60)//"Nº de Threads: "
oGetThrd := TGet():New(35, 55, { | u | If( PCount() == 0, cNumThrd, cNumThrd := u ) }, oPanel, 10, 10, "", { || VldNumThrd( @cNumThrd ) } , 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cNumThrd,,,,)

oSayPerD := TSay():New(55, 10, { || STR0309 }, oPanel,,,,,, .T.,,, 60,60)//"Período de: "
oGetPerD := TGet():New(55, 55, { | u | If( PCount() == 0, cPerDe, cPerDe := u ) }, oPanel, 10, 10, "", { || VldPer( @cPerDe ) } , 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cPerDe,,,,)
oSayPerA := TSay():New(55, 100, { || STR0310 }, oPanel,,,,,, .T.,,, 60,60)//"Período até: "
oGetPerA := TGet():New(55, 145, { | u | If( PCount() == 0, cPerAte, cPerAte := u ) }, oPanel, 10, 10, "", { || VldPer( @cPerAte ) } , 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cPerDe,,,,)
oSayForm := TSay():New(55, 185, { || STR0320 }, oPanel,,,,,, .T.,,, 60,60)//"(Formato AAAAMM)"

oSayFil  := TSay():New(75, 10, { || STR0311 }, oPanel,,,,,, .T.,,, 60,60)//"Filiais: "
oBtnFil  := TButton():New( 75, 55, OemToAnsi(STR0312), oPanel, {|| fSelFil() },; //"Selecionar"
																							50, 15,,, .F., .T., .F.,, .F.,,, .F.)

oButtonProc  := TButton():New( 100, 25, OemToAnsi(STR0278), oPanel, {|| fVldProc() .And. fBarra(oPanel, oButtonProc, oBtnFil, oGetThrd, oGetPerD, oGetPerA )},; //"Clique para efetuar a importação"
																							250, 15,,, .F., .T., .F.,, .F.,,, .F.)
If nRemoteType <> 5
	oSayExec:setCSS( fCSS("TEXTTITLE") )
	oButtonProc:setCSS( fCSS("BTPROC") )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrInExec
Retorna se o migrador está em execução de acordo com o semáforo
@author  Allyson L Mesashi
@since   30/09/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrInExec()
Return( lInExec )

//-------------------------------------------------------------------
/*/{Protheus.doc} MigrConcl
Retorna se o migrador já foi concluído
@author  Allyson L Mesashi
@since   04/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function MigrConcl()
Return( lConcl )

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldOpc
Retorna se foi selecionado uma opção para importação
@author  Allyson L Mesashi
@since   04/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fVldOpc()

Local lRet := .T.

fContSel()

If Empty(nQtdSel)
	lRet := .F.
	MsgInfo(STR0313, STR0314)//Não foi selecionado a opção para importação"##"Aviso"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldNumThrd
Retorna se foi preenchido o número de threads dentro do limite permitido
@author  Allyson L Mesashi
@since   04/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function VldNumThrd( cNumThrd )

Local lRet := .T.

If !Empty(cNumThrd)
	If Val(cNumThrd) < 1 .Or. Val(cNumThrd) > 10
		lRet := .F.
		MsgInfo(STR0315, STR0314)//"O número de threads para este processo de ser um valor entre 1 e 10."##"Aviso"
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPer
Retorna se o período de possui formato válido
@author  Allyson L Mesashi
@since   04/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function VldPer( cPer )

Local lRet 	:= .T.
Local nAno	:= 0
Local nMes	:= 0

If !Empty(cPer)
	// Forca o periodo no formato AAAA/MM
		nAno := Val(SubStr(cPer, 0, 4))
		nMes := Val(SubStr(cPer, 5, 2))
		If (nAno < 1900 .Or. nAno > 3000 ) .Or. (nMes < 1 .Or. nMes > 12 )
			lRet := .F.
		EndIf

	If !lRet
		MsgInfo(STR0316, STR0314)//"Período Inválido! Verifique formato (AAAAMM)".##"Aviso"
	Endif
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fSelFil
Retorna as filiais que serão processadas
@author  Allyson L Mesashi
@since   04/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fSelFil()

Local aButtons 		:= {}
Local aColumns 		:= {}
Local bOK2			:= {||(oDlgGrid:End(), nOpcB := 1)}
Local bFecha 		:= {||oDlgGrid:End()}
Local lMArcar 		:= .F.
Local nOpcB 		:= 0
Local oFont 		:= Nil

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
aColumns[Len(aColumns)]:SetTitle("Filial" )
aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
aColumns[Len(aColumns)]:SetTitle("Nome")
aColumns[Len(aColumns)]:SetSize(Len(SM0->M0_NOME))
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CNPJ}") )
aColumns[Len(aColumns)]:SetTitle("CNPJ")
aColumns[Len(aColumns)]:SetSize(14)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture(  "@R 99.999.999/9999-99"   )

//Tela
oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0317) From 0,0 TO 380,930 OF oMainWnd PIXEL //"Filiais"


// Cria o conteiner onde serão colocados os paineis
oTela2		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela2:CreateHorizontalBox( 80 )

oTela2:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel4	:= oTela2:GeTPanel( cIdGrid )

@ oSize:GetDimension("CABECALHO","LININI")+1, oSize:GetDimension("CABECALHO","COLINI")+4 GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090, oSize:GetDimension("CABECALHO","COLEND") * 0.431 LABEL OemToAnsi(STR0001) OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9, oSize:GetDimension("CABECALHO","COLINI")+6 SAY OemToAnsi(STR0004) Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()
oMark:SetAlias(cAliasTrb)
oMark:SetTemporary(.T.)

oMark:SetColumns(aColumns)

//Indica o container onde sera criado o browse
oMark:SetOwner(oPanel4)
oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTRB ), oMark:Refresh(.T.)  }

oMark:SetFieldMark('OK')

oMark:SetMenuDef("GPEM034")
oMark:Activate()

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, bOK2 ,bFecha, NIL, aButtons)

If nOpcB == 1
	aArrayFil		:= {}
	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK)
			aAdd(aArrayFil, (cAliasTRB)->FILIAL)
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo
EndIf

Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SetMarkAll  ³ Autor ³ Leandro Drumond       ³ Data ³ 17/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca/desmarca todos os itens 			                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SetMarkAll(cMarca,lMarcar )                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SetMarkAll(cMarca,lMarcar,cAliasTRB)

Local cAliasMark := cAliasTRB
Local aAreaMark  := (cAliasMark)->( GetArea() )

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	RecLock( (cAliasMark), .F. )
	(cAliasMark)->OK := IIf( lMarcar , cMarca, '  ' )
	MsUnLock()
	(cAliasMark)->( dbSkip() )
EndDo

RestArea(aAreaMark)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldProc
Valida o processamento
@author  Allyson L Mesashi
@since   04/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fVldProc()

Local lRet := .T.

If (!Empty(cPerDe) .And. Empty(cPerAte)) .Or.;
	(Empty(cPerDe) .And. !Empty(cPerAte)) .Or.;
	(!Empty(cPerDe) .And. !Empty(cPerAte) .And. cPerAte < cPerDe)
	lRet := .F.
	MsgInfo(STR0318, STR0314)//"Período de/até inválido!".##"Aviso"
EndIf

If Empty(aArrayFil)
	lRet := .F.
	MsgInfo(STR0319, STR0314)//"Selecione a(s) filial(is) para processamento!".##"Aviso"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fBarra
Monta a barra de progresso na parte de baixo do painel 3 do wizard
@author  Allyson L Mesashi
@since   30/09/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fBarra(oPanel, oButtonProc, oBtnFil, oGetThrd, oGetPerD, oGetPerA)

Local nMeter	:= 0
Local nMeter2	:= 0
Local oMeter	:= Nil
Local oMeter2	:= Nil
Local oSaySep	:= Nil
Local oSayProc	:= Nil
Local oSayProc2	:= Nil
Local oSayProc3	:= Nil

lInExec := .T.

// Desabilita os botões
oButtonProc:Disable()
oBtnFil:Disable()
oGetThrd:Disable()
oGetPerD:Disable()
oGetPerA:Disable()

oSaySep := TSay():New(115, 02, { || Replicate("_", 150) }, oPanel,,,,,, .T.,,, 300,20)
oSaySep:setCSS( fCSS("LINESEPARADOR") )

oSayProc := TSay():New(130, 80, { || STR0279 }, oPanel,,,,,, .T.,,, 300,20)//"Efetuando Processamento -> "
oSayProc:setCSS( fCSS("TEXTTITLE") )

oSayProc2 := TSay():New(145, 115, { || STR0361 }, oPanel,,,,,, .T.,,, 300,20)//"Eventos importados: "
oSayProc2:setCSS( fCSS("TEXTTITLE") )
oMeter2 := TMeter():New( 155, 25, { |u| Iif( Pcount() > 0, nMeter2 := u, nMeter2) }, 100, oPanel, 250, 16,, .T.)
oMeter2:setCSS("METER")
oMeter2:SetTotal(0)
oMeter2:Set(0)

oSayProc3 := TSay():New(175, 115, { || STR0362 }, oPanel,,,,,, .T.,,, 300,20)//"Registros importados: "
oSayProc3:setCSS( fCSS("TEXTTITLE") )
oMeter := TMeter():New( 185, 25, { |u| Iif( Pcount() > 0, nMeter := u, nMeter) }, 100, oPanel, 250, 16,, .T.)
oMeter:setCSS("METER")
oMeter:SetTotal(0)
oMeter:Set(0)

// Chama as funções de processamento
fProc(oSayProc, oMeter, oMeter2, oSayProc2, oSayProc3)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fProc
Encapsula as funções de processamento
@author  Allyson L Mesashi
@since   30/09/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fProc(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

oMeter2:SetTotal( nQtdSel )

If lOpc01//T3M
	fMigrT3M(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc02//S-1000
	fMigr1000(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc03//S-1005
	fMigr1005(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc04//S-1010
	fMigr1010(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc05//S-1020
	fMigr1020(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc06//S-1030
	fMigr1030(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc07//S-1035
	fMigr1035(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc08//S-1040
	fMigr1040(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc09//S-1050
	fMigr1050(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc11//S-1070
	fMigr1070(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc12//S-1200
	fMigr1200(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc13//S-1210
	fMigr1210(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc14//S-1280
	fMigr1280(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc15//S-1295
	fMigr1295(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc16//S-1298
	fMigr1298(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc17//S-1299
	fMigr1299(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc18//S-1300
	fMigr1300(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc19//S-2190
	fMigr2190(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc20//S-2200
	fMigr2200(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc21//S-2205
	fMigr2205(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc22//S-2206
	fMigr2206(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc26//S-2230
	fMigr2230(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc31//S-2298
	fMigr2298(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc32//S-2299
	fMigr2299(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc33//S-2300
	fMigr2300(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc34//S-2306
	fMigr2306(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc35//S-2399
	fMigr2399(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf
If lOpc36//V3N
	fMigrV3N(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
EndIf

If Len(aLogErr) > 0 .Or. Len(aLogImp) > 0 .Or. Len(aLogTab) > 0
	aAdd( aLogProc, STR0368 + dToC( Date() ) )//"Data de término: "
	aAdd( aLogProc, STR0369 + Time() )//"Hora de término: "
	aAdd( aLogProc, STR0370 + ElapTime( cTimeIni, Time() ) )//"Tempo de processamento: "
	aAdd( aLogProc, "")
	aAdd( aLogProc, STR0371 + cValToChar(Len(aLogImp)) )//"Total de registros importados: "
	aAdd( aLogProc, STR0372 + cValToChar(Len(aLogErr)) )//"Total de registros importados sem XML: "
	fMakeLog({aLogProc, aLogTab, aLogErr, aLogImp}, aTitle, Nil, Nil, , OemToAnsi(STR0360), "M", "L",, .F.) //#"Log de Ocorrências"
EndIf

MsgAlert(STR0280, STR0045)//"Processamento Finalizado."##"Atenção"
lInExec := .F.
lConcl  := .T.

If ValType(oMeter) <> "U"
	oSay:setText(Space(20)+STR0280)//"Processamento Finalizado."
	oMeter:Free()
	oMeter2:Free()
	oSayProc2:setText("")
	oSayProc3:setText("")
EndIf

If Select(cAliasTRB) > 0
	(cAliasTRB)->(DbCloseArea())
EndIf

If oArq1Tmp <> Nil
	oArq1Tmp:Delete()
	Freeobj(oArq1Tmp)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fText
Descritivos do assistente
@author  Allyson L Mesashi
@since   30/09/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fText(cInfo)

Local cRet 		:= ""

If cInfo == "BEMVINDO"
	cRet := '<font size="6" color="#0c9abe"><b>'+STR0283+'</b></font>'//"Bem-vindo..."
	cRet += '<br/>'
ElseIf cInfo == "ASSIST"
	cRet += '<font size="5" color="#888">'+STR0284//"Este é um processo que deve ser efetuado para a migração do TAF"
	cRet += '<br/>'
	cRet += STR0285//"para o Middleware."
	cRet += '<br/>'
	cRet += STR0286//'Serão importadas informações de tabelas do TAF/TSS que são'
	cRet += '<br/>'
	cRet += STR0287//'necessárias para a integração correta de dados.'
	cRet += '<br/>'
	cRet += STR0288+'</font>'//'Certifique-se que o ambiente está com acesso exclusivo.'
EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} fCSS
Fonte genérico contendo os Cascade Style (CSS) utilizados nas interfaces
@author  Allyson L Mesashi
@since   30/09/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fCSS(cIDCSS)

Local cCSS := ""

Do Case
	Case cIDCSS == "TEXTTITLE"
		cCSS +=	"QLabel{"
		cCSS += "  font-size: 20;"
		cCSS += "  font-weight: bold;"
		cCSS += "  color: #000000;"
		cCSS += "}"
	Case cIDCSS == "BTPROC"
		cCSS += "QPushButton{ background-color: #3C7799; "
		cCSS += "border: none; "
		cCSS += "color: #FFFFFF;"
		cCSS += "padding: 2px 5px;"
		cCSS += "text-align: center; "
		cCSS += "text-decoration: none; "
		cCSS += "display: inline-block; "
		cCSS += "font-size: 16px; "
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
		cCSS += "}"
		cCSS += "QPushButton:hover { "
		cCSS += "background-color: #FFFFFF;"
		cCSS += "color: #3C7799;"
		cCSS += "background-repeat: no-repeat;"
		cCSS += "border: 2px solid #3C7799; "
		cCSS += "border-radius: 2px "
		cCSS += "}"
		cCSS +=	"QPushButton:pressed {"
		cCSS +=	"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,"
		cCSS +=	"                                    stop: 0 #FFFFFF, stop: 1 #3C7799);"
		cCSS += "color: #000000;"
		cCSS +=	"}"
	Case cIDCSS == "LINESEPARADOR"
		cCSS +=	"QLabel{"
		cCSS += "  font-size: 20;"
		cCSS += "  font-weight: bold;"
		cCSS += "  color: #BBBBBB;"
		cCSS += "}"
EndCase

Return(cCSS)

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigrT3M
Realiza a migração da tabela T3M para RJF
@author  Allyson L Mesashi
@since   30/09/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigrT3M(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 		:= GetArea()
Local cTbGpe		:= FWModeAccess( "RJF", 1) + FWModeAccess( "RJF", 2) + FWModeAccess( "RJF", 3)
Local cTbTaf		:= FWModeAccess( "T3M", 1) + FWModeAccess( "T3M", 2) + FWModeAccess( "T3M", 3)
Local lNovo			:= .F.
Local nInc			:= 0

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0276 )//"Iniciando Processamento..."##"Importação da tabela T3M"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

If cTbGpe != cTbTaf
	aAdd( aLogTab, STR0281 + CRLF + STR0282 )//"O modo de acesso das tabelas T3M e RJF está divergente!"##"Não será possível efetuar a migração dos registros"
	Return .F.
EndIf

RJF->( dbSetOrder(1) )
T3M->( dbGoTop() )
oMeter:SetTotal( T3M->(RecCount()) )

While T3M->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(T3M->(RecCount())) )//"Registros importados: "
	lNovo := !RJF->( dbSeek( T3M->T3M_FILIAL + T3M->T3M_ID ) )
	If Reclock("RJF", lNovo)
		RJF->RJF_FILIAL 	:= T3M->T3M_FILIAL
		RJF->RJF_ID 		:= T3M->T3M_ID
		RJF->RJF_CODERP 	:= T3M->T3M_CODERP
		RJF->( MsUnlock() )
	EndIf
	aAdd(aLogImp, OemToAnsi(STR0376) + "T3M" + OemToAnsi(STR0357) + "ID: " + T3M->T3M_ID + OemToAnsi(STR0375) ) //"O registro da tabela XXX com ID: XXXXXX foi importado."
	T3M->( dbSkip() )
EndDo

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1000
Realiza a migração da tabela C1E para RJE (S-1000)
@author  Allyson L Mesashi
@since   30/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1000(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aRJE		:= {}
Local cAliasQRY := "IMPC1E"
Local cDtIni	:= ""
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cNatJ		:= ""
Local cQuery	:= ""
Local dDataImp	:= Date()
Local lAdmPubl	:= .F.
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0302 )//"Iniciando Processamento..."##"Importação Evento S-1000"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
RJ9->(dbSetOrder(1))//RJ9_FILIAL+RJ9_INI+RJ9_TPINSC+RJ9_NRINSC
RJA->(dbSetOrder(1))//RJA_FILIAL+RJA_INI+RJA_TPINSC+RJA_NRINSC+RJA_CNPJ
CRM->( dbSetOrder(1))//CRM_FILIAL+CRM_ID+CRM_VERSAO+CRM_CNPJ
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('C1E') + " C1E "
cQuery 	+= "WHERE C1E.C1E_MATRIZ = 'T' AND C1E.C1E_STATUS = '4' AND "
cQuery 	+= "C1E.C1E_FILTAF IN (" + cFilIn + ") AND "
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C1E.C1E_DTINI, 3, 4) || SUBSTRING(C1E.C1E_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C1E.C1E_DTINI, 3, 4) || SUBSTRING(C1E.C1E_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C1E.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr1000" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('C1E') + " C1E "
cQuery 	+= "WHERE C1E.C1E_MATRIZ = 'T' AND C1E.C1E_STATUS = '4' AND "
cQuery 	+= "C1E.C1E_FILTAF IN (" + cFilIn + ") AND "
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C1E.C1E_DTINI, 3, 4) || SUBSTRING(C1E.C1E_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C1E.C1E_DTINI, 3, 4) || SUBSTRING(C1E.C1E_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C1E.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY C1E.C1E_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	cFilAnt 	:= (cAliasQRY)->C1E_FILTAF
	fPosFil( cEmpAnt, AllTrim(cFilAnt) )
	cNatJ 		:= Posicione("C8P", 1, xFilial("C8P", C1E_FILIAL)+(cAliasQRY)->C1E_NATJUR, "C8P_CODIGO")
	lAdmPubl	:= (cNatJ $ ("1015/1040/1074/1163"))
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	cDtIni		:= SubStr((cAliasQRY)->C1E_DTINI, 3, 4) + SubStr((cAliasQRY)->C1E_DTINI, 1, 2)

	lNovo := !RJE->( dbSeek( "S1000" + AllTrim((cAliasQRY)->C1E_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", (cAliasQRY)->C1E_FILTAF)), (cAliasQRY)->C1E_FILTAF, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1000", cDtIni, (cAliasQRY)->C1E_FILTAF, ("S1000"+AllTrim((cAliasQRY)->C1E_ID) + AllTrim((cAliasQRY)->C1E_VERSAO)), (Iif((cAliasQRY)->C1E_EVENTO == "A", "2", "1")), "Importado TAF", "4", dDataImp, Time(), (cAliasQRY)->C1E_EVENTO, (cAliasQRY)->C1E_PROTUL, (cAliasQRY)->C1E_PROTPN }

	fCriaLote( "S1000", cAliasQRY, "C1E" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	lNovo := !RJ9->( dbSeek( xFilial("RJ9", (cAliasQRY)->C1E_FILTAF) + cDtIni + cTpInsc + PadR(cNrInsc, 14, " ") ) )

	oModel 	:= FWLoadModel("GPEA935")
	oGrid 	:= oModel:GetModel('GPEA935_RJA')
	If lNovo
		oModel:SetOperation(3)
	Else
		oModel:SetOperation(4)
	EndIf
	oModel:Activate()

	oModel:LoadValue( "GPEA935_RJ9", "RJ9_FILIAL", xFilial( "RJ9", (cAliasQRY)->C1E_FILTAF ) )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_TPINSC", cTpInsc )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_NRINSC", cNrInsc )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_INI", cDtIni )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_NOME", SubStr((cAliasQRY)->C1E_NOME, 1, 100) )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_CLASS", Posicione("C8D",1,xFilial("C8D", (cAliasQRY)->C1E_FILTAF)+(cAliasQRY)->C1E_CLAFIS, "C8D_CODIGO") )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_NATJ", SubStr(cNatJ, 1, 3) + "-" + SubStr(cNatJ, 4, 1) )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_COOP", (cAliasQRY)->C1E_INCOOP )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_CONS", (cAliasQRY)->C1E_INCONS )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_DESON", (cAliasQRY)->C1E_DESFOL )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_PONTO", (cAliasQRY)->C1E_REGELT )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_EDUC", Iif((cAliasQRY)->C1E_ENTEDU == "0", "1", "2") )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_TEMP", Iif((cAliasQRY)->C1E_INDETT == "1", "2", "1") )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_RTEM", SubStr((cAliasQRY)->C1E_NRETT, 1, 30) )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_ISLEI", (cAliasQRY)->C1E_SIGMIN )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_ISNUM", (cAliasQRY)->C1E_NRCERT )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_ISDTE", sToD((cAliasQRY)->C1E_DTEMCE) )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_ISVCT", sToD((cAliasQRY)->C1E_DTVCCE) )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_ISPTC", (cAliasQRY)->C1E_NRPRRE )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_ISTDPT", sToD((cAliasQRY)->C1E_DTPRRE) )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_DTDOU", sToD((cAliasQRY)->C1E_DTDOU) )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_PAGDOU", (cAliasQRY)->C1E_PAGDOU )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_CNM", (cAliasQRY)->C1E_NOMCNT )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_CCPF", (cAliasQRY)->C1E_CPFCNT )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_CFIXO", (cAliasQRY)->C1E_DDDFON+(cAliasQRY)->C1E_FONCNT )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_CCEL", (cAliasQRY)->C1E_DDDCEL+(cAliasQRY)->C1E_CELCNT )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_CEMAIL", SubStr((cAliasQRY)->C1E_EMAIL, 1, 60) )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_SIAFI", (cAliasQRY)->C1E_SIAFI )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_IDEEFR", (cAliasQRY)->C1E_EFR )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_NRFER", (cAliasQRY)->C1E_CPNJER )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_EFNM", SubStr((cAliasQRY)->C1E_NMENTE, 1, 100) )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_EFUF", Posicione("C09",3,xFilial("C09", (cAliasQRY)->C1E_FILTAF)+(cAliasQRY)->C1E_UF, "C09_UF") )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_EFCMN", Posicione("C07",3,xFilial("C07", (cAliasQRY)->C1E_FILTAF)+(cAliasQRY)->C1E_CODMUN, "C07_CODIGO") )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_EFRPPS", (cAliasQRY)->C1E_RPPS )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_EFST", (cAliasQRY)->C1E_SUBTET )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_EFVST", (cAliasQRY)->C1E_VLRSUB )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_OIMUL", (cAliasQRY)->C1E_ISEMUL )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_SITPJ", (cAliasQRY)->C1E_SITESP )
	oModel:LoadValue( "GPEA935_RJ9", "RJ9_SITPF", (cAliasQRY)->C1E_SITPF )

	oGrid:DelAllLine()
	If CRM->( dbSeek( xFilial("CRM", (cAliasQRY)->C1E_FILTAF)+(cAliasQRY)->C1E_ID+(cAliasQRY)->C1E_VERSAO ) )
		While CRM->( !EoF() .And. CRM->CRM_ID+CRM->CRM_VERSAO == (cAliasQRY)->C1E_ID+(cAliasQRY)->C1E_VERSAO )
			oGrid:SetValue("RJA_FILIAL", xFilial( "RJ9", (cAliasQRY)->C1E_FILTAF ))
			oGrid:SetValue("RJA_TPINSC", cTpInsc)
			oGrid:SetValue("RJA_NRINSC", cNrInsc)
			oGrid:SetValue("RJA_INI", cDtIni)
			oGrid:SetValue("RJA_CNPJ", CRM->CRM_CNPJ)
			oGrid:SetValue("RJA_NOME", SubStr(CRM->CRM_NOME, 1, 100))
			oGrid:SetValue("RJA_CONTA", CRM->CRM_CONTAT)
			oGrid:SetValue("RJA_TELEF", CRM->CRM_DDD+CRM->CRM_FONE)
			oGrid:SetValue("RJA_EMAIL", CRM->CRM_MAIL)
			CRM->( dbSkip() )
			If CRM->( !EoF() )
				oGrid:AddLine()
			EndIf
		EndDo
	EndIf

	lRet := FWFormCommit( oModel )

	oModel:DeActivate()
	oModel     := Nil
	oGrid      := Nil

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S1000" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1005
Realiza a migração da tabela C92 para RJE (S-1005)
@author  Allyson L Mesashi
@since   01/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1005(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aFilProc	:= {}
Local aRJE		:= {}
Local cAliasQRY := "IMPC92"
Local cDtIni	:= ""
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cRJEFil	:= ""
Local cKey		:= ""
Local cQuery	:= ""
Local dDataImp	:= Date()
Local lAdmPubl	:= .F.
Local lCompart	:= Empty(xFilial("C92"))
Local lExclusiv	:= (Len(AllTrim(xFilial("C92"))) == FwGetTamFilial)
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nFilEmp	:= 0
Local nInc		:= 0
Local nTamFil	:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0303 )//"Iniciando Processamento..."##"Importação Evento S-1005"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

If !lCompart .And. !lExclusiv
	nTamFil	:= Len(AllTrim(xFilial("C92")))
	For nContFil := 1 To Len(aArrayFil)
		If aScan(aFilProc, {|x| x == xFilial("C92", aArrayFil[nContFil]) }) == 0
			aAdd(aFilProc, xFilial("C92", aArrayFil[nContFil]) )
			cFilQry += AllTrim(xFilial("C92", aArrayFil[nContFil]))
		EndIf
	Next nContFil
	cFilIn := fSqlIn(cFilQry, nTamFil)
ElseIf lExclusiv
	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)
EndIf

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('C92') + " C92 "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C92.C92_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C92.C92_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C92.C92_FILIAL IN (" + cFilIn + ") AND C92.C92_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C92.C92_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C92.C92_DTINI, 3, 4) || SUBSTRING(C92.C92_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C92.C92_DTINI, 3, 4) || SUBSTRING(C92.C92_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C92.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr1005" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('C92') + " C92 "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C92.C92_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C92.C92_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C92.C92_FILIAL IN (" + cFilIn + ") AND C92.C92_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C92.C92_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C92.C92_DTINI, 3, 4) || SUBSTRING(C92.C92_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C92.C92_DTINI, 3, 4) || SUBSTRING(C92.C92_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C92.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY C92.C92_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->C92_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	cDtIni		:= SubStr((cAliasQRY)->C92_DTINI, 3, 4) + SubStr((cAliasQRY)->C92_DTINI, 1, 2)

	If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. x[18] == AllTrim((cAliasQRY)->C92_NRINSC) }) ) > 0
		cKey 	:= aSM0[nFilEmp, 2] + (cAliasQRY)->C92_NRINSC
		cRJEFil	:= aSM0[nFilEmp, 2]
	Else
		cKey 	:= (cAliasQRY)->C92_FILIAL + (cAliasQRY)->C92_NRINSC
		cRJEFil	:= (cAliasQRY)->C92_FILIAL
	EndIf

	lNovo := !RJE->( dbSeek( "S1005" + AllTrim((cAliasQRY)->C92_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), cRJEFil, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1005", cDtIni, cKey, ("S1005"+AllTrim((cAliasQRY)->C92_ID) + AllTrim((cAliasQRY)->C92_VERSAO)), (Iif((cAliasQRY)->C92_EVENTO == "A", "2", "1")), "Importado TAF", "4", dDataImp, Time(), (cAliasQRY)->C92_EVENTO, (cAliasQRY)->C92_PROTUL, (cAliasQRY)->C92_PROTPN }

	fCriaLote( "S1005", cAliasQRY, "C92" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S1005" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1010
Realiza a migração da tabela C8R para RJE (S-1010)
@author  Allyson L Mesashi
@since   04/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1010(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aFilProc	:= {}
Local aRJE		:= {}
Local cAliasQRY := "IMPC8R"
Local cDtIni	:= ""
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cQuery	:= ""
Local dDataImp	:= Date()
Local lAdmPubl	:= .F.
Local lCompart	:= Empty(xFilial("C8R"))
Local lExclusiv	:= (Len(AllTrim(xFilial("C8R"))) == FwGetTamFilial)
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nTamFil	:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0306 )//"Iniciando Processamento..."##"Importação Evento S-1010"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

If !lCompart .And. !lExclusiv
	nTamFil	:= Len(AllTrim(xFilial("C8R")))
	For nContFil := 1 To Len(aArrayFil)
		If aScan(aFilProc, {|x| x == xFilial("C8R", aArrayFil[nContFil]) }) == 0
			aAdd(aFilProc, xFilial("C8R", aArrayFil[nContFil]) )
			cFilQry += AllTrim(xFilial("C8R", aArrayFil[nContFil]))
		EndIf
	Next nContFil
	cFilIn := fSqlIn(cFilQry, nTamFil)
ElseIf lExclusiv
	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)
EndIf

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('C8R') + " C8R "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C8R.C8R_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C8R.C8R_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C8R.C8R_FILIAL IN (" + cFilIn + ") AND C8R.C8R_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C8R.C8R_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C8R.C8R_DTINI, 3, 4) || SUBSTRING(C8R.C8R_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C8R.C8R_DTINI, 3, 4) || SUBSTRING(C8R.C8R_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C8R.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr1010" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('C8R') + " C8R "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C8R.C8R_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C8R.C8R_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C8R.C8R_FILIAL IN (" + cFilIn + ") AND C8R.C8R_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C8R.C8R_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C8R.C8R_DTINI, 3, 4) || SUBSTRING(C8R.C8R_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C8R.C8R_DTINI, 3, 4) || SUBSTRING(C8R.C8R_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C8R.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY C8R.C8R_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->C8R_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	cDtIni		:= SubStr((cAliasQRY)->C8R_DTINI, 3, 4) + SubStr((cAliasQRY)->C8R_DTINI, 1, 2)

	lNovo := !RJE->( dbSeek( "S1010" + AllTrim((cAliasQRY)->C8R_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->C8R_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1010", cDtIni, ((cAliasQRY)->C8R_FILIAL+(cAliasQRY)->C8R_CODRUB), ("S1010"+AllTrim((cAliasQRY)->C8R_ID) + AllTrim((cAliasQRY)->C8R_VERSAO)), (Iif((cAliasQRY)->C8R_EVENTO == "A", "2", "1")), "Importado TAF", "4", dDataImp, Time(), (cAliasQRY)->C8R_EVENTO, (cAliasQRY)->C8R_PROTUL, (cAliasQRY)->C8R_PROTPN }

	fCriaLote( "S1010", cAliasQRY, "C8R" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S1010" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1020
Realiza a migração da tabela C99 para RJE (S-1020)
@author  Allyson L Mesashi
@since   05/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1020(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aFilProc	:= {}
Local aRJE		:= {}
Local cAliasQRY := "IMPC99"
Local cDtIni	:= ""
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cKey		:= ""
Local cQuery	:= ""
Local cRJEFil	:= ""
Local dDataImp	:= Date()
Local lAdmPubl	:= .F.
Local lCompart	:= Empty(xFilial("C99"))
Local lExclusiv	:= (Len(AllTrim(xFilial("C99"))) == FwGetTamFilial)
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nTamFil	:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0321 )//"Efetuando Processamento -> "##"Importação Evento S-1020"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

If !lCompart .And. !lExclusiv
	nTamFil	:= Len(AllTrim(xFilial("C99")))
	For nContFil := 1 To Len(aArrayFil)
		If aScan(aFilProc, {|x| x == xFilial("C99", aArrayFil[nContFil]) }) == 0
			aAdd(aFilProc, xFilial("C99", aArrayFil[nContFil]) )
			cFilQry += AllTrim(xFilial("C99", aArrayFil[nContFil]))
		EndIf
	Next nContFil
	cFilIn := fSqlIn(cFilQry, nTamFil)
ElseIf lExclusiv
	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)
EndIf

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('C99') + " C99 "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C99.C99_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C99.C99_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C99.C99_FILIAL IN (" + cFilIn + ") AND C99.C99_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C99.C99_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C99.C99_DTINI, 3, 4) || SUBSTRING(C99.C99_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C99.C99_DTINI, 3, 4) || SUBSTRING(C99.C99_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C99.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr1020" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('C99') + " C99 "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C99.C99_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C99.C99_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C99.C99_FILIAL IN (" + cFilIn + ") AND C99.C99_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C99.C99_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C99.C99_DTINI, 3, 4) || SUBSTRING(C99.C99_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C99.C99_DTINI, 3, 4) || SUBSTRING(C99.C99_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C99.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY C99.C99_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->C99_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	cDtIni		:= SubStr((cAliasQRY)->C99_DTINI, 3, 4) + SubStr((cAliasQRY)->C99_DTINI, 1, 2)
	If !lCompart
		cKey	:= (cAliasQRY)->C99_CODIGO
		cRJEFil	:= SubStr((cAliasQRY)->C99_CODIGO, 1, FwGetTamFilial)
	Else
		cKey	:= (cAliasQRY)->C99_FILIAL + (cAliasQRY)->C99_CODIGO
		cRJEFil	:= (cAliasQRY)->C99_FILIAL
	EndIf

	lNovo := !RJE->( dbSeek( "S1020" + AllTrim((cAliasQRY)->C99_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), cRJEFil, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1020", cDtIni, cKey, ("S1020"+AllTrim((cAliasQRY)->C99_ID) + AllTrim((cAliasQRY)->C99_VERSAO)), (Iif((cAliasQRY)->C99_EVENTO == "A", "2", "1")), "Importado TAF", "4", dDataImp, Time(), (cAliasQRY)->C99_EVENTO, (cAliasQRY)->C99_PROTUL, (cAliasQRY)->C99_PROTPN }

	fCriaLote( "S1020", cAliasQRY, "C99" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S1020" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1030
Realiza a migração da tabela C8V para RJE (S-1030)
@author  Allyson L Mesashi
@since   07/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1030(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aFilProc	:= {}
Local aRJE		:= {}
Local cAliasQRY := "IMPC8V"
Local cDtIni	:= ""
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cKey		:= ""
Local cQuery	:= ""
Local cRJEFil	:= ""
Local dDataImp	:= Date()
Local lAdmPubl	:= .F.
Local lCompart	:= Empty(xFilial("C8V"))
Local lExclusiv	:= (Len(AllTrim(xFilial("C8V"))) == FwGetTamFilial)
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nTamFil	:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0322 )//"Iniciando Processamento..."##"Importação Evento S-1030"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

If !lCompart .And. !lExclusiv
	nTamFil	:= Len(AllTrim(xFilial("C8V")))
	For nContFil := 1 To Len(aArrayFil)
		If aScan(aFilProc, {|x| x == xFilial("C8V", aArrayFil[nContFil]) }) == 0
			aAdd(aFilProc, xFilial("C8V", aArrayFil[nContFil]) )
			cFilQry += AllTrim(xFilial("C8V", aArrayFil[nContFil]))
		EndIf
	Next nContFil
	cFilIn := fSqlIn(cFilQry, nTamFil)
ElseIf lExclusiv
	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)
EndIf

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('C8V') + " C8V "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C8V.C8V_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C8V.C8V_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C8V.C8V_FILIAL IN (" + cFilIn + ") AND C8V.C8V_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C8V.C8V_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C8V.C8V_DTINI, 3, 4) || SUBSTRING(C8V.C8V_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C8V.C8V_DTINI, 3, 4) || SUBSTRING(C8V.C8V_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C8V.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr1030" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('C8V') + " C8V "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C8V.C8V_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C8V.C8V_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C8V.C8V_FILIAL IN (" + cFilIn + ") AND C8V.C8V_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C8V.C8V_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C8V.C8V_DTINI, 3, 4) || SUBSTRING(C8V.C8V_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C8V.C8V_DTINI, 3, 4) || SUBSTRING(C8V.C8V_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C8V.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY C8V.C8V_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->C8V_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	cDtIni		:= SubStr((cAliasQRY)->C8V_DTINI, 3, 4) + SubStr((cAliasQRY)->C8V_DTINI, 1, 2)
	If !lCompart
		cKey	:= (cAliasQRY)->C8V_CODIGO
		cRJEFil	:= SubStr((cAliasQRY)->C8V_CODIGO, 1, FwGetTamFilial)
	Else
		cKey	:= (cAliasQRY)->C8V_FILIAL + (cAliasQRY)->C8V_CODIGO
		cRJEFil	:= (cAliasQRY)->C8V_FILIAL
	EndIf

	lNovo := !RJE->( dbSeek( "S1030" + AllTrim((cAliasQRY)->C8V_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), cRJEFil, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1030", cDtIni, cKey, ("S1030"+AllTrim((cAliasQRY)->C8V_ID) + AllTrim((cAliasQRY)->C8V_VERSAO)), (Iif((cAliasQRY)->C8V_EVENTO == "A", "2", "1")), "Importado TAF", "4", dDataImp, Time(), (cAliasQRY)->C8V_EVENTO, (cAliasQRY)->C8V_PROTUL, (cAliasQRY)->C8V_PROTPN }

	fCriaLote( "S1030", cAliasQRY, "C8V" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S1030" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1035
Realiza a migração da tabela T5K para RJE (S-1035)
@author  Allyson L Mesashi
@since   08/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1035(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aFilProc	:= {}
Local aRJE		:= {}
Local cAliasQRY := "IMPT5K"
Local cDtIni	:= ""
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cKey		:= ""
Local cQuery	:= ""
Local cRJEFil	:= ""
Local dDataImp	:= Date()
Local lAdmPubl	:= .F.
Local lCompart	:= Empty(xFilial("T5K"))
Local lExclusiv	:= (Len(AllTrim(xFilial("T5K"))) == FwGetTamFilial)
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nTamFil	:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0323 )//"Iniciando Processamento..."##"Importação Evento S-1035"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

If !lCompart .And. !lExclusiv
	nTamFil	:= Len(AllTrim(xFilial("T5K")))
	For nContFil := 1 To Len(aArrayFil)
		If aScan(aFilProc, {|x| x == xFilial("T5K", aArrayFil[nContFil]) }) == 0
			aAdd(aFilProc, xFilial("T5K", aArrayFil[nContFil]) )
			cFilQry += AllTrim(xFilial("T5K", aArrayFil[nContFil]))
		EndIf
	Next nContFil
	cFilIn := fSqlIn(cFilQry, nTamFil)
ElseIf lExclusiv
	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)
EndIf

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('T5K') + " T5K "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(T5K.T5K_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND T5K.T5K_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE T5K.T5K_FILIAL IN (" + cFilIn + ") AND T5K.T5K_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE T5K.T5K_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(T5K.T5K_DTINI, 3, 4) || SUBSTRING(T5K.T5K_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(T5K.T5K_DTINI, 3, 4) || SUBSTRING(T5K.T5K_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "T5K.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr1035" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('T5K') + " T5K "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(T5K.T5K_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND T5K.T5K_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE T5K.T5K_FILIAL IN (" + cFilIn + ") AND T5K.T5K_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE T5K.T5K_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(T5K.T5K_DTINI, 3, 4) || SUBSTRING(T5K.T5K_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(T5K.T5K_DTINI, 3, 4) || SUBSTRING(T5K.T5K_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "T5K.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY T5K.T5K_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->T5K_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	cDtIni		:= SubStr((cAliasQRY)->T5K_DTINI, 3, 4) + SubStr((cAliasQRY)->T5K_DTINI, 1, 2)
	If !lCompart
		cKey	:= (cAliasQRY)->T5K_CODIGO
		cRJEFil	:= SubStr((cAliasQRY)->T5K_CODIGO, 1, FwGetTamFilial)
	Else
		cKey	:= (cAliasQRY)->T5K_FILIAL + (cAliasQRY)->T5K_CODIGO
		cRJEFil	:= (cAliasQRY)->T5K_FILIAL
	EndIf

	lNovo := !RJE->( dbSeek( "S1035" + AllTrim((cAliasQRY)->T5K_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), cRJEFil, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1035", cDtIni, cKey, ("S1035"+AllTrim((cAliasQRY)->T5K_ID) + AllTrim((cAliasQRY)->T5K_VERSAO)), (Iif((cAliasQRY)->T5K_EVENTO == "A", "2", "1")), "Importado TAF", "4", dDataImp, Time(), (cAliasQRY)->T5K_EVENTO, (cAliasQRY)->T5K_PROTUL, (cAliasQRY)->T5K_PROTPN }

	fCriaLote( "S1035", cAliasQRY, "T5K" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S1035" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1040
Realiza a migração da tabela C8X para RJE (S-1040)
@author  Allyson L Mesashi
@since   08/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1040(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aFilProc	:= {}
Local aRJE		:= {}
Local cAliasQRY := "IMPC8X"
Local cDtIni	:= ""
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cKey		:= ""
Local cQuery	:= ""
Local cRJEFil	:= ""
Local dDataImp	:= Date()
Local lAdmPubl	:= .F.
Local lCompart	:= Empty(xFilial("C8X"))
Local lExclusiv	:= (Len(AllTrim(xFilial("C8X"))) == FwGetTamFilial)
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nTamFil	:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0324 )//"Iniciando Processamento..."##"Importação Evento S-1040"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

If !lCompart .And. !lExclusiv
	nTamFil	:= Len(AllTrim(xFilial("C8X")))
	For nContFil := 1 To Len(aArrayFil)
		If aScan(aFilProc, {|x| x == xFilial("C8X", aArrayFil[nContFil]) }) == 0
			aAdd(aFilProc, xFilial("C8X", aArrayFil[nContFil]) )
			cFilQry += AllTrim(xFilial("C8X", aArrayFil[nContFil]))
		EndIf
	Next nContFil
	cFilIn := fSqlIn(cFilQry, nTamFil)
ElseIf lExclusiv
	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)
EndIf

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('C8X') + " C8X "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C8X.C8X_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C8X.C8X_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C8X.C8X_FILIAL IN (" + cFilIn + ") AND C8X.C8X_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C8X.C8X_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C8X.C8X_DTINI, 3, 4) || SUBSTRING(C8X.C8X_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C8X.C8X_DTINI, 3, 4) || SUBSTRING(C8X.C8X_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C8X.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr1040" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('C8X') + " C8X "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C8X.C8X_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C8X.C8X_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C8X.C8X_FILIAL IN (" + cFilIn + ") AND C8X.C8X_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C8X.C8X_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C8X.C8X_DTINI, 3, 4) || SUBSTRING(C8X.C8X_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C8X.C8X_DTINI, 3, 4) || SUBSTRING(C8X.C8X_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C8X.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY C8X.C8X_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->C8X_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	cDtIni		:= SubStr((cAliasQRY)->C8X_DTINI, 3, 4) + SubStr((cAliasQRY)->C8X_DTINI, 1, 2)
	If !lCompart
		cKey	:= (cAliasQRY)->C8X_CODIGO
		cRJEFil	:= SubStr((cAliasQRY)->C8X_CODIGO, 1, FwGetTamFilial)
	Else
		cKey	:= (cAliasQRY)->C8X_FILIAL + (cAliasQRY)->C8X_CODIGO
		cRJEFil	:= (cAliasQRY)->C8X_FILIAL
	EndIf

	lNovo := !RJE->( dbSeek( "S1040" + AllTrim((cAliasQRY)->C8X_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), cRJEFil, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1040", cDtIni, cKey, ("S1040"+AllTrim((cAliasQRY)->C8X_ID) + AllTrim((cAliasQRY)->C8X_VERSAO)), (Iif((cAliasQRY)->C8X_EVENTO == "A", "2", "1")), "Importado TAF", "4", dDataImp, Time(), (cAliasQRY)->C8X_EVENTO, (cAliasQRY)->C8X_PROTUL, (cAliasQRY)->C8X_PROTPN }

	fCriaLote( "S1040", cAliasQRY, "C8X" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S1040" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1050
Realiza a migração da tabela C90 para RJE (S-1050)
@author  Allyson L Mesashi
@since   08/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1050(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aFilProc	:= {}
Local aRJE		:= {}
Local cAliasQRY := "IMPC90"
Local cDtIni	:= ""
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cKey		:= ""
Local cQuery	:= ""
Local cRJEFil	:= ""
Local dDataImp	:= Date()
Local lAdmPubl	:= .F.
Local lCompart	:= Empty(xFilial("C90"))
Local lExclusiv	:= (Len(AllTrim(xFilial("C90"))) == FwGetTamFilial)
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nTamFil	:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0325 )//"Iniciando Processamento..."##"Importação Evento S-1050"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

If !lCompart .And. !lExclusiv
	nTamFil	:= Len(AllTrim(xFilial("C90")))
	For nContFil := 1 To Len(aArrayFil)
		If aScan(aFilProc, {|x| x == xFilial("C90", aArrayFil[nContFil]) }) == 0
			aAdd(aFilProc, xFilial("C90", aArrayFil[nContFil]) )
			cFilQry += AllTrim(xFilial("C90", aArrayFil[nContFil]))
		EndIf
	Next nContFil
	cFilIn := fSqlIn(cFilQry, nTamFil)
ElseIf lExclusiv
	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)
EndIf

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('C90') + " C90 "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C90.C90_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C90.C90_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C90.C90_FILIAL IN (" + cFilIn + ") AND C90.C90_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C90.C90_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C90.C90_DTINI, 3, 4) || SUBSTRING(C90.C90_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C90.C90_DTINI, 3, 4) || SUBSTRING(C90.C90_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C90.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr1050" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('C90') + " C90 "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C90.C90_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C90.C90_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C90.C90_FILIAL IN (" + cFilIn + ") AND C90.C90_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C90.C90_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C90.C90_DTINI, 3, 4) || SUBSTRING(C90.C90_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C90.C90_DTINI, 3, 4) || SUBSTRING(C90.C90_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C90.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY C90.C90_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->C90_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	cDtIni		:= SubStr((cAliasQRY)->C90_DTINI, 3, 4) + SubStr((cAliasQRY)->C90_DTINI, 1, 2)
	If !lCompart
		cKey	:= (cAliasQRY)->C90_CODIGO
		cRJEFil	:= SubStr((cAliasQRY)->C90_CODIGO, 1, FwGetTamFilial)
	Else
		cKey	:= (cAliasQRY)->C90_FILIAL + (cAliasQRY)->C90_CODIGO
		cRJEFil	:= (cAliasQRY)->C90_FILIAL
	EndIf

	lNovo := !RJE->( dbSeek( "S1050" + AllTrim((cAliasQRY)->C90_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), cRJEFil, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1050", cDtIni, cKey, ("S1050"+AllTrim((cAliasQRY)->C90_ID) + AllTrim((cAliasQRY)->C90_VERSAO)), (Iif((cAliasQRY)->C90_EVENTO == "A", "2", "1")), "Importado TAF", "4", dDataImp, Time(), (cAliasQRY)->C90_EVENTO, (cAliasQRY)->C90_PROTUL, (cAliasQRY)->C90_PROTPN }

	fCriaLote( "S1050", cAliasQRY, "C90" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S1050" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1070
Realiza a migração da tabela C1G para RJE (S-1070)
@author  Allyson L Mesashi
@since   14/01/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1070(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aFilProc	:= {}
Local aRJE		:= {}
Local cAliasQRY := "IMPC1G"
Local cDtIni	:= ""
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cKey		:= ""
Local cQuery	:= ""
Local cRJEFil	:= ""
Local dDataImp	:= Date()
Local lAdmPubl	:= .F.
Local lCompart	:= Empty(xFilial("C1G"))
Local lExclusiv	:= (Len(AllTrim(xFilial("C1G"))) == FwGetTamFilial)
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nTamFil	:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0327 )//"Iniciando Processamento..."##"Importação Evento S-1070"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

If !lCompart .And. !lExclusiv
	nTamFil	:= Len(AllTrim(xFilial("C1G")))
	For nContFil := 1 To Len(aArrayFil)
		If aScan(aFilProc, {|x| x == xFilial("C1G", aArrayFil[nContFil]) }) == 0
			aAdd(aFilProc, xFilial("C1G", aArrayFil[nContFil]) )
			cFilQry += AllTrim(xFilial("C1G", aArrayFil[nContFil]))
		EndIf
	Next nContFil
	cFilIn := fSqlIn(cFilQry, nTamFil)
ElseIf lExclusiv
	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)
EndIf

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('C1G') + " C1G "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C1G.C1G_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C1G.C1G_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C1G.C1G_FILIAL IN (" + cFilIn + ") AND C1G.C1G_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C1G.C1G_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C1G.C1G_DTINI, 3, 4) || SUBSTRING(C1G.C1G_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C1G.C1G_DTINI, 3, 4) || SUBSTRING(C1G.C1G_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C1G.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr1070" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('C1G') + " C1G "
If !lCompart .And. !lExclusiv
	cQuery 	+= "WHERE SUBSTRING(C1G.C1G_FILIAL, 1, " + cValToChar(nTamFil) + ") IN (" + cFilIn + ") AND C1G.C1G_STATUS = '4' AND "
ElseIf lExclusiv
	cQuery 	+= "WHERE C1G.C1G_FILIAL IN (" + cFilIn + ") AND C1G.C1G_STATUS = '4' AND "
Else
	cQuery 	+= "WHERE C1G.C1G_STATUS = '4' AND "
EndIf
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " SUBSTRING(C1G.C1G_DTINI, 3, 4) || SUBSTRING(C1G.C1G_DTINI, 1, 2) >= '" + cPerDe + "' AND SUBSTRING(C1G.C1G_DTINI, 3, 4) || SUBSTRING(C1G.C1G_DTINI, 1, 2) <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C1G.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY C1G.C1G_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->C1G_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	cDtIni		:= SubStr((cAliasQRY)->C1G_DTINI, 3, 4) + SubStr((cAliasQRY)->C1G_DTINI, 1, 2)
	cKey		:= xFilial("O08", (cAliasQRY)->C1G_FILIAL ) + Posicione("O08", 2, xFilial("O08", (cAliasQRY)->C1G_FILIAL)+(cAliasQRY)->C1G_TPPROC+(cAliasQRY)->C1G_NUMPRO, "O08_CAJURI")
	cRJEFil		:= xFilial("O08", (cAliasQRY)->C1G_FILIAL )

	lNovo := !RJE->( dbSeek( "S1070" + AllTrim((cAliasQRY)->C1G_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), cRJEFil, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1070", cDtIni, cKey, ("S1070"+AllTrim((cAliasQRY)->C1G_ID) + AllTrim((cAliasQRY)->C1G_VERSAO)), (Iif((cAliasQRY)->C1G_EVENTO == "A", "2", "1")), "Importado TAF", "4", dDataImp, Time(), (cAliasQRY)->C1G_EVENTO, (cAliasQRY)->C1G_PROTUL, (cAliasQRY)->C1G_PROTPN }

	fCriaLote( "S1070", cAliasQRY, "C1G" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S1070" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1200
Realiza a migração da tabela C91 para RJE (S-1200)
@author  Allyson L Mesashi
@since   18/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1200(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aRJE		:= {}
Local cAliasQRY := "IMPC91"
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cKey		:= ""
Local cQuery	:= ""
Local lAdmPubl	:= .F.
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0345 )//"Iniciando Processamento..."##"Importação Evento S-1200"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('C91') + " C91 "
cQuery 	+= "WHERE C91.C91_FILIAL IN (" + cFilIn + ") AND C91.C91_STATUS = '4' AND "
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " C91.C91_PERAPU >= '" + cPerDe + "' AND C91.C91_PERAPU <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C91.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr1200" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('C91') + " C91 "
cQuery 	+= "WHERE C91.C91_FILIAL IN (" + cFilIn + ") AND C91.C91_STATUS = '4' AND "
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " C91.C91_PERAPU >= '" + cPerDe + "' AND C91.C91_PERAPU <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "C91.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY C91.C91_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->C91_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	If !Empty((cAliasQRY)->C91_TRABAL)
		cKey := AllTrim((cAliasQRY)->C91_PERAPU) + (cAliasQRY)->C91_INDAPU + Posicione("C9V",2,xFilial("C9V", (cAliasQRY)->C91_FILIAL)+(cAliasQRY)->C91_TRABAL+"1","C9V_CPF")
	Else
		cKey := AllTrim((cAliasQRY)->C91_PERAPU) + (cAliasQRY)->C91_INDAPU + (cAliasQRY)->C91_CPF
	EndIf

	lNovo := !RJE->( dbSeek( "S1200" + AllTrim((cAliasQRY)->C91_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->C91_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1200", AllTrim((cAliasQRY)->C91_PERAPU), cKey, (cAliasQRY)->C91_ID, (Iif((cAliasQRY)->C91_EVENTO == "A", "2", "1")), "Importado TAF", "4", sToD((cAliasQRY)->C91_DINSIS), "", (cAliasQRY)->C91_EVENTO, (cAliasQRY)->C91_PROTUL, (cAliasQRY)->C91_PROTPN }

	fCriaLote( "S1200", cAliasQRY, "C91" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S1200" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1210
Realiza a migração da tabela T3P para RJE (S-1210)
@author  Allyson L Mesashi
@since   18/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1210(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aRJE		:= {}
Local cAliasQRY := "IMPT3P"
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cKey		:= ""
Local cQuery	:= ""
Local lAdmPubl	:= .F.
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0346 )//"Iniciando Processamento..."##"Importação Evento S-1210"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('T3P') + " T3P "
cQuery 	+= "WHERE T3P.T3P_FILIAL IN (" + cFilIn + ") AND T3P.T3P_STATUS = '4' AND "
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " T3P.T3P_PERAPU >= '" + cPerDe + "' AND T3P.T3P_PERAPU <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "T3P.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr1210" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('T3P') + " T3P "
cQuery 	+= "WHERE T3P.T3P_FILIAL IN (" + cFilIn + ") AND T3P.T3P_STATUS = '4' AND "
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " T3P.T3P_PERAPU >= '" + cPerDe + "' AND T3P.T3P_PERAPU <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "T3P.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY T3P.T3P_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->T3P_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	If !Empty((cAliasQRY)->T3P_BENEFI)
		cKey := AllTrim((cAliasQRY)->T3P_PERAPU) + (cAliasQRY)->T3P_INDAPU + Posicione("C9V",2,xFilial("C9V", (cAliasQRY)->T3P_FILIAL)+(cAliasQRY)->T3P_BENEFI+"1","C9V_CPF")
	Else
		cKey := AllTrim((cAliasQRY)->T3P_PERAPU) + (cAliasQRY)->T3P_INDAPU + (cAliasQRY)->T3P_CPF
	EndIf

	lNovo := !RJE->( dbSeek( "S1210" + AllTrim((cAliasQRY)->T3P_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->T3P_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1210", AllTrim((cAliasQRY)->T3P_PERAPU), cKey, (cAliasQRY)->T3P_ID, (Iif((cAliasQRY)->T3P_EVENTO == "A", "2", "1")), "Importado TAF", "4", sToD((cAliasQRY)->T3P_DINSIS), "", (cAliasQRY)->T3P_EVENTO, (cAliasQRY)->T3P_PROTUL, (cAliasQRY)->T3P_PROTPN }

	fCriaLote( "S1210", cAliasQRY, "T3P" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S1210" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1280

Realiza a migração da tabela T3V para RJE (S-1280)
@author  Silvio C. Stecca
@since   13/01/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1280(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

	Local aArea 	:= GetArea()
	Local aAreaSM0 	:= SM0->(GetArea())
	Local aRJE		:= {}
	Local cAliasQRY := "IMPT3V"
	Local cFilBkp	:= cFilAnt
	Local cFilIn	:= ""
	Local cFilQry	:= ""
	Local cQuery	:= ""
	Local lAdmPubl	:= .F.
	Local lMultThr	:= .F.
	Local lNovo		:= .F.
	Local nCont		:= 0
	Local nContFil	:= 0
	Local nInc		:= 0
	Local nThreads	:= Val(cNumThrd)

	nTotProc++
	oMeter2:Set(nTotProc)
	oSay:SetText( STR0279 + STR0347 )//"Iniciando Processamento..."##"Importação Evento S-1280"
	oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
	fRstLote()

	// RJE_EVENTO + RJE_RECIB
	RJE->( dbSetOrder(5) )
	If Select(cAliasQRY) > 0
		(cAliasQRY)->( dbCloseArea() )
	EndIf

	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil]
	Next nContFil

	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

	cQuery	:= "SELECT COUNT(*) AS CONT "
	cQuery 	+= "FROM " + RetSqlName('T3V') + " T3V "
	cQuery 	+= "WHERE T3V.T3V_FILIAL IN (" + cFilIn + ") AND T3V.T3V_STATUS = '4' AND "

	If !Empty(cPerDe) .And. !Empty(cPerAte)
		cQuery 	+= " T3V.T3V_PERAPU >= '" + cPerDe + "' AND T3V.T3V_PERAPU <= '" + cPerAte + "' AND "
	EndIf

	cQuery 	+= "T3V.D_E_L_E_T_ = ' ' "
	cQuery 	:= ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQRY, .T., .T.)

	nCont := (cAliasQRY)->CONT

	oMeter:SetTotal(nCont)
	(cAliasQRY)->(dbCloseArea())

	lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
	If lMultThr
		oMultiThr := FWIPCWait():New("fMigr1280" , 10000)
		oMultiThr:SetThreads(nThreads)
		oMultiThr:SetEnvironment(cEmpAnt, cFilAnt)
		oMultiThr:Start("fImpRJE")
		Sleep(1000 * nThreads)
	EndIf

	cQuery	:= "SELECT * "
	cQuery 	+= "FROM " + RetSqlName('T3V') + " T3V "
	cQuery 	+= "WHERE T3V.T3V_FILIAL IN (" + cFilIn + ") AND T3V.T3V_STATUS = '4' AND "

	If !Empty(cPerDe) .And. !Empty(cPerAte)
		cQuery 	+= " T3V.T3V_PERAPU >= '" + cPerDe + "' AND T3V.T3V_PERAPU <= '" + cPerAte + "' AND "
	EndIf

	cQuery 	+= "T3V.D_E_L_E_T_ = ' ' "
	cQuery 	+= "ORDER BY T3V.T3V_PROTUL"
	cQuery 	:= ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQRY, .T., .T.)

	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
		fPosFil( cEmpAnt, AllTrim((cAliasQRY)->T3V_FILIAL) )
		cFilAnt 	:= SM0->M0_CODFIL
		cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
		cNrInsc 	:= SM0->M0_CGC

		lNovo := !RJE->(dbSeek("S1280" + AllTrim((cAliasQRY)->T3V_PROTUL)))

		aRJE := {	lNovo, ;
					(xFilial("RJE", cFilAnt))															, ;// RJE_FILIAL
					(cAliasQRY)->T3V_FILIAL																, ;// RJE_FIL
					cTpInsc																				, ;// RJE_TPINSC
					Iif(cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc)					, ;// RJE_INSCR
					"S1280"																				, ;// RJE_EVENTO
					AllTrim((cAliasQRY)->T3V_PERAPU)													, ;// RJE_INI
					(cAliasQRY)->T3V_FILIAL + AllTrim((cAliasQRY)->T3V_PERAPU) + (cAliasQRY)->T3V_INDAPU, ;// RJE_KEY
					("S1280"+AllTrim((cAliasQRY)->T3V_ID) + AllTrim((cAliasQRY)->T3V_VERSAO))			, ;// RJE_RETKEY
					Iif((cAliasQRY)->T3V_EVENTO == "A", "2", "1")										, ;// RJE_RETF
					"Importado TAF"																		, ;// RJE_VERS
					"4"																					, ;// RJE_STATUS
					Date()																				, ;// RJE_DTG
					Time()																				, ;// RJE_HORAG
					(cAliasQRY)->T3V_EVENTO																, ;// RJE_OPER
					(cAliasQRY)->T3V_PROTUL																, ;// RJE_RECIB
					(cAliasQRY)->T3V_PROTPN																, ;// RJE_RECANT
				}

		fCriaLote( "S1280", cAliasQRY, "T3V" )

		If lMultThr
			oMultiThr:Go( aRJE )
		Else
			fImpRJE( aRJE )
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo

	(cAliasQRY)->( dbCloseArea() )

	If lMultThr
		oMultiThr:Stop()
		FreeObj(oMultiThr)
	EndIf

	fPesqTSS( "S1280" )

	cFilAnt := cFilBkp
	RestArea(aArea)
	RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1295
Realiza a migração da tabela T72 para RJE (S-1295)
@author  isabel.noguti
@since   07/01/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1295(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
	Local aArea 	:= GetArea()
	Local aAreaSM0 	:= SM0->(GetArea())
	Local aRJE		:= {}
	Local cAliasQRY := "IMPT72"
	Local cFilBkp	:= cFilAnt
	Local cFilIn	:= ""
	Local cFilQry	:= ""
	Local cQuery	:= ""
	Local lAdmPubl	:= .F.
	Local lMultThr	:= .F.
	Local lNovo		:= .F.
	Local nCont		:= 0
	Local nContFil	:= 0
	Local nInc		:= 0
	Local nThreads	:= Val(cNumThrd)

	nTotProc++
	oMeter2:Set(nTotProc)
	oSay:SetText( STR0279 + STR0348 )//"Iniciando Processamento..."##"Importação Evento S-1295"
	oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
	fRstLote()

	RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
	If Select(cAliasQRY) > 0
		(cAliasQRY)->( dbCloseArea() )
	EndIf

	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

	cQuery	:= "SELECT COUNT(*) AS CONT "
	cQuery 	+= "FROM " + RetSqlName('T72') + " T72 "
	cQuery 	+= "WHERE T72.T72_FILIAL IN (" + cFilIn + ") AND T72.T72_STATUS = '4' AND "
	If !Empty(cPerDe) .And. !Empty(cPerAte)
		cQuery 	+= " T72.T72_PERAPU >= '" + cPerDe + "' AND T72.T72_PERAPU <= '" + cPerAte + "' AND "
	EndIf
	cQuery 	+= "T72.D_E_L_E_T_ = ' ' "
	cQuery 	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
	nCont := (cAliasQRY)->CONT
	oMeter:SetTotal( nCont )
	(cAliasQRY)->( dbCloseArea() )

	lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
	If lMultThr
		oMultiThr := FWIPCWait():New( "fMigr1295" , 10000 )
		oMultiThr:SetThreads(nThreads)
		oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
		oMultiThr:Start("fImpRJE")
		Sleep( 1000 * nThreads )
	EndIf

	cQuery	:= "SELECT * "
	cQuery 	+= "FROM " + RetSqlName('T72') + " T72 "
	cQuery 	+= "WHERE T72.T72_FILIAL IN (" + cFilIn + ") AND T72.T72_STATUS = '4' AND "
	If !Empty(cPerDe) .And. !Empty(cPerAte)
		cQuery 	+= " T72.T72_PERAPU >= '" + cPerDe + "' AND T72.T72_PERAPU <= '" + cPerAte + "' AND "
	EndIf
	cQuery 	+= "T72.D_E_L_E_T_ = ' ' "
	cQuery 	+= "ORDER BY T72.T72_PROTUL"
	cQuery 	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
		fPosFil( cEmpAnt, AllTrim((cAliasQRY)->T72_FILIAL) )
		cFilAnt 	:= SM0->M0_CODFIL
		cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
		cNrInsc 	:= SM0->M0_CGC

		lNovo := !RJE->( dbSeek( "S1295" + AllTrim((cAliasQRY)->T72_PROTUL) ) )

		aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->T72_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1295", AllTrim((cAliasQRY)->T72_PERAPU), (cAliasQRY)->T72_FILIAL + AllTrim((cAliasQRY)->T72_PERAPU) + (cAliasQRY)->T72_INDAPU, (cAliasQRY)->T72_ID, "1", "Importado TAF", "4", Date(), Time(), (cAliasQRY)->T72_EVENTO, (cAliasQRY)->T72_PROTUL, (cAliasQRY)->T72_PROTPN }

		fCriaLote( "S1295", cAliasQRY, "T72" )

		If lMultThr
			oMultiThr:Go( aRJE )
		Else
			fImpRJE( aRJE )
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo

	(cAliasQRY)->( dbCloseArea() )

	If lMultThr
		oMultiThr:Stop()
		FreeObj(oMultiThr)
	EndIf

	fPesqTSS( "S1295" )

	cFilAnt := cFilBkp
	RestArea(aArea)
	RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1298
Realiza a migração da tabela T1S para RJE (S-1298)
@author  isabel.noguti
@since   09/01/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1298(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
	Local aArea 	:= GetArea()
	Local aAreaSM0 	:= SM0->(GetArea())
	Local aRJE		:= {}
	Local cAliasQRY := "IMPT1S"
	Local cFilBkp	:= cFilAnt
	Local cFilIn	:= ""
	Local cFilQry	:= ""
	Local cQuery	:= ""
	Local lAdmPubl	:= .F.
	Local lMultThr	:= .F.
	Local lNovo		:= .F.
	Local nCont		:= 0
	Local nContFil	:= 0
	Local nInc		:= 0
	Local nThreads	:= Val(cNumThrd)

	nTotProc++
	oMeter2:Set(nTotProc)
	oSay:SetText( STR0279 + STR0349 )//"Iniciando Processamento..."##"Importação Evento S-1298"
	oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
	fRstLote()

	RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
	If Select(cAliasQRY) > 0
		(cAliasQRY)->( dbCloseArea() )
	EndIf

	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

	cQuery	:= "SELECT COUNT(*) AS CONT "
	cQuery 	+= "FROM " + RetSqlName('T1S') + " T1S "
	cQuery 	+= "WHERE T1S.T1S_FILIAL IN (" + cFilIn + ") AND T1S.T1S_STATUS = '4' AND "
	If !Empty(cPerDe) .And. !Empty(cPerAte)
		cQuery 	+= " T1S.T1S_PERAPU >= '" + cPerDe + "' AND T1S.T1S_PERAPU <= '" + cPerAte + "' AND "
	EndIf
	cQuery 	+= "T1S.D_E_L_E_T_ = ' ' "
	cQuery 	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
	nCont := (cAliasQRY)->CONT
	oMeter:SetTotal( nCont )
	(cAliasQRY)->( dbCloseArea() )

	lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
	If lMultThr
		oMultiThr := FWIPCWait():New( "fMigr1298" , 10000 )
		oMultiThr:SetThreads(nThreads)
		oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
		oMultiThr:Start("fImpRJE")
		Sleep( 1000 * nThreads )
	EndIf

	cQuery	:= "SELECT * "
	cQuery 	+= "FROM " + RetSqlName('T1S') + " T1S "
	cQuery 	+= "WHERE T1S.T1S_FILIAL IN (" + cFilIn + ") AND T1S.T1S_STATUS = '4' AND "
	If !Empty(cPerDe) .And. !Empty(cPerAte)
		cQuery 	+= " T1S.T1S_PERAPU >= '" + cPerDe + "' AND T1S.T1S_PERAPU <= '" + cPerAte + "' AND "
	EndIf
	cQuery 	+= "T1S.D_E_L_E_T_ = ' ' "
	cQuery 	+= "ORDER BY T1S.T1S_PROTUL"
	cQuery 	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
		fPosFil( cEmpAnt, AllTrim((cAliasQRY)->T1S_FILIAL) )
		cFilAnt 	:= SM0->M0_CODFIL
		cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
		cNrInsc 	:= SM0->M0_CGC

		lNovo := !RJE->( dbSeek( "S1298" + AllTrim((cAliasQRY)->T1S_PROTUL) ) )

		aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->T1S_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1298", AllTrim((cAliasQRY)->T1S_PERAPU), (cAliasQRY)->T1S_FILIAL + AllTrim((cAliasQRY)->T1S_PERAPU) + (cAliasQRY)->T1S_INDAPU, ("S1298"+AllTrim((cAliasQRY)->T1S_ID) + AllTrim((cAliasQRY)->T1S_VERSAO)), (Iif((cAliasQRY)->T1S_EVENTO == "A", "2", "1")), "Importado TAF", "4", Date(), Time(), (cAliasQRY)->T1S_EVENTO, (cAliasQRY)->T1S_PROTUL, (cAliasQRY)->T1S_PROTPN }

		fCriaLote( "S1298", cAliasQRY, "T1S" )

		If lMultThr
			oMultiThr:Go( aRJE )
		Else
			fImpRJE( aRJE )
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo

	(cAliasQRY)->( dbCloseArea() )

	If lMultThr
		oMultiThr:Stop()
		FreeObj(oMultiThr)
	EndIf

	fPesqTSS( "S1298" )

	cFilAnt := cFilBkp
	RestArea(aArea)
	RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1299
Realiza a migração da tabela CUO para RJE (S-1299)
@author  isabel.noguti
@since   10/01/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1299(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)
	Local aArea 	:= GetArea()
	Local aAreaSM0 	:= SM0->(GetArea())
	Local aRJE		:= {}
	Local cAliasQRY := "IMPCUO"
	Local cFilBkp	:= cFilAnt
	Local cFilIn	:= ""
	Local cFilQry	:= ""
	Local cQuery	:= ""
	Local lAdmPubl	:= .F.
	Local lMultThr	:= .F.
	Local lNovo		:= .F.
	Local nCont		:= 0
	Local nContFil	:= 0
	Local nInc		:= 0
	Local nThreads	:= Val(cNumThrd)

	nTotProc++
	oMeter2:Set(nTotProc)
	oSay:SetText( STR0279 + STR0350 )//"Iniciando Processamento..."##"Importação Evento S-1299"
	oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
	fRstLote()

	RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
	If Select(cAliasQRY) > 0
		(cAliasQRY)->( dbCloseArea() )
	EndIf

	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil]
	Next nContFil
	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

	cQuery	:= "SELECT COUNT(*) AS CONT "
	cQuery 	+= "FROM " + RetSqlName('CUO') + " CUO "
	cQuery 	+= "WHERE CUO.CUO_FILIAL IN (" + cFilIn + ") AND CUO.CUO_STATUS = '4' AND "
	If !Empty(cPerDe) .And. !Empty(cPerAte)
		cQuery 	+= " CUO.CUO_PERAPU >= '" + cPerDe + "' AND CUO.CUO_PERAPU <= '" + cPerAte + "' AND "
	EndIf
	cQuery 	+= "CUO.D_E_L_E_T_ = ' ' "
	cQuery 	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
	nCont := (cAliasQRY)->CONT
	oMeter:SetTotal( nCont )
	(cAliasQRY)->( dbCloseArea() )

	lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
	If lMultThr
		oMultiThr := FWIPCWait():New( "fMigr1299" , 10000 )
		oMultiThr:SetThreads(nThreads)
		oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
		oMultiThr:Start("fImpRJE")
		Sleep( 1000 * nThreads )
	EndIf

	cQuery	:= "SELECT * "
	cQuery 	+= "FROM " + RetSqlName('CUO') + " CUO "
	cQuery 	+= "WHERE CUO.CUO_FILIAL IN (" + cFilIn + ") AND CUO.CUO_STATUS = '4' AND "
	If !Empty(cPerDe) .And. !Empty(cPerAte)
		cQuery 	+= " CUO.CUO_PERAPU >= '" + cPerDe + "' AND CUO.CUO_PERAPU <= '" + cPerAte + "' AND "
	EndIf
	cQuery 	+= "CUO.D_E_L_E_T_ = ' ' "
	cQuery 	+= "ORDER BY CUO.CUO_PROTUL"
	cQuery 	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

	While (cAliasQRY)->( !EoF() )
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
		fPosFil( cEmpAnt, AllTrim((cAliasQRY)->CUO_FILIAL) )
		cFilAnt 	:= SM0->M0_CODFIL
		cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
		cNrInsc 	:= SM0->M0_CGC

		lNovo := !RJE->( dbSeek( "S1299" + AllTrim((cAliasQRY)->CUO_PROTUL) ) )

		aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->CUO_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S1299", AllTrim((cAliasQRY)->CUO_PERAPU), (cAliasQRY)->CUO_FILIAL + AllTrim((cAliasQRY)->CUO_PERAPU) + (cAliasQRY)->CUO_INDAPU, ("S1299"+AllTrim((cAliasQRY)->CUO_ID) + AllTrim((cAliasQRY)->CUO_VERSAO)), "1", "Importado TAF", "4", Date(), Time(), (cAliasQRY)->CUO_EVENTO, (cAliasQRY)->CUO_PROTUL, (cAliasQRY)->CUO_PROTPN }

		fCriaLote( "S1299", cAliasQRY, "CUO" )

		If lMultThr
			oMultiThr:Go( aRJE )
		Else
			fImpRJE( aRJE )
		EndIf

		(cAliasQRY)->( dbSkip() )
	EndDo

	(cAliasQRY)->( dbCloseArea() )

	If lMultThr
		oMultiThr:Stop()
		FreeObj(oMultiThr)
	EndIf

	fPesqTSS( "S1299" )

	cFilAnt := cFilBkp
	RestArea(aArea)
	RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr1300
Realiza a migração da tabela T3Z para RJE (S-1300)

@author  Silvio C. Stecca
@since   14/01/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr1300(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

	Local aArea 	:= GetArea()
	Local aAreaSM0 	:= SM0->(GetArea())
	Local aRJE		:= {}
	Local cAliasQRY := "IMPT3Z"
	Local cFilBkp	:= cFilAnt
	Local cFilIn	:= ""
	Local cFilQry	:= ""
	Local cQuery	:= ""
	Local lAdmPubl	:= .F.
	Local lMultThr	:= .F.
	Local lNovo		:= .F.
	Local nCont		:= 0
	Local nContFil	:= 0
	Local nInc		:= 0
	Local nThreads	:= Val(cNumThrd)

	nTotProc++
	oMeter2:Set(nTotProc)
	oSay:SetText( STR0279 + STR0351 )//"Iniciando Processamento..."##"Importação Evento S-1300"
	oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
	fRstLote()

	// RJE_EVENTO + RJE_RECIB
	RJE->(dbSetOrder(5))
	If Select(cAliasQRY) > 0
		(cAliasQRY)->(dbCloseArea())
	EndIf

	For nContFil := 1 To Len(aArrayFil)
		cFilQry += aArrayFil[nContFil]
	Next nContFil

	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

	cQuery	:= "SELECT COUNT(*) AS CONT "
	cQuery 	+= "FROM " + RetSqlName('T3Z') + " T3Z "
	cQuery 	+= "WHERE T3Z.T3Z_FILIAL IN (" + cFilIn + ") AND T3Z.T3Z_STATUS = '4' AND "

	If !Empty(cPerDe) .And. !Empty(cPerAte)
		cQuery 	+= " T3Z.T3Z_PERAPU >= '" + cPerDe + "' AND T3Z.T3Z_PERAPU <= '" + cPerAte + "' AND "
	EndIf

	cQuery 	+= "T3Z.D_E_L_E_T_ = ' ' "
	cQuery 	:= ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQRY, .T., .T.)

	nCont := (cAliasQRY)->CONT
	oMeter:SetTotal(nCont)
	(cAliasQRY)->(dbCloseArea())

	lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)

	If lMultThr
		oMultiThr := FWIPCWait():New("fMigr1300" , 10000)
		oMultiThr:SetThreads(nThreads)
		oMultiThr:SetEnvironment(cEmpAnt, cFilAnt)
		oMultiThr:Start("fImpRJE")
		Sleep(1000 * nThreads)
	EndIf

	cQuery	:= "SELECT * "
	cQuery 	+= "FROM " + RetSqlName('T3Z') + " T3Z "
	cQuery 	+= "WHERE T3Z.T3Z_FILIAL IN (" + cFilIn + ") AND T3Z.T3Z_STATUS = '4' AND "

	If !Empty(cPerDe) .And. !Empty(cPerAte)
		cQuery 	+= " T3Z.T3Z_PERAPU >= '" + cPerDe + "' AND T3Z.T3Z_PERAPU <= '" + cPerAte + "' AND "
	EndIf

	cQuery 	+= "T3Z.D_E_L_E_T_ = ' ' "
	cQuery 	+= "ORDER BY T3Z.T3Z_PROTUL"
	cQuery 	:= ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQRY, .T., .T.)

	While (cAliasQRY)->(!EoF())
		nInc++
		oMeter:Set(nInc)
		oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
		fPosFil(cEmpAnt, AllTrim((cAliasQRY)->T3Z_FILIAL))

		cFilAnt	:= SM0->M0_CODFIL
		cTpInsc	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
		cNrInsc	:= SM0->M0_CGC

		lNovo := !RJE->(dbSeek("S1300" + AllTrim((cAliasQRY)->T3Z_PROTUL)))

		aRJE := {	lNovo, ;
					(xFilial("RJE", cFilAnt))															, ;// RJE_FILIAL
					(cAliasQRY)->T3Z_FILIAL																, ;// RJE_FIL
					cTpInsc																				, ;// RJE_TPINSC
					Iif(cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc)					, ;// RJE_INSCR
					"S1300"																				, ;// RJE_EVENTO
					AllTrim((cAliasQRY)->T3Z_PERAPU)													, ;// RJE_INI
					(cAliasQRY)->T3Z_FILIAL + AllTrim((cAliasQRY)->T3Z_PERAPU) + (cAliasQRY)->T3Z_INDAPU, ;// RJE_KEY
					("S1300"+AllTrim((cAliasQRY)->T3Z_ID) + AllTrim((cAliasQRY)->T3Z_VERSAO))			, ;// RJE_RETKEY
					Iif((cAliasQRY)->T3Z_EVENTO == "A", "2", "1")										, ;// RJE_RETF
					"Importado TAF"																		, ;// RJE_VERS
					"4"																					, ;// RJE_STATUS
					Date()																				, ;// RJE_DTG
					Time()																				, ;// RJE_HORAG
					(cAliasQRY)->T3Z_EVENTO																, ;// RJE_OPER
					(cAliasQRY)->T3Z_PROTUL																, ;// RJE_RECIB
					(cAliasQRY)->T3Z_PROTPN																, ;// RJE_RECANT
				}

		fCriaLote( "S1300", cAliasQRY, "T3Z" )

		If lMultThr
			oMultiThr:Go(aRJE)
		Else
			fImpRJE(aRJE)
		EndIf

		(cAliasQRY)->(dbSkip())
	EndDo

	(cAliasQRY)->(dbCloseArea())

	If lMultThr
		oMultiThr:Stop()
		FreeObj(oMultiThr)
	EndIf

	fPesqTSS( "S1300" )

	cFilAnt := cFilBkp
	RestArea(aArea)
	RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr2190
Realiza a migração da tabela T3A para RJE (S-2190)
@author  Allyson L Mesashi
@since   12/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr2190(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aRJE		:= {}
Local cAliasQRY := "IMPT3A"
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cQuery	:= ""
Local lAdmPubl	:= .F.
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0328 )//"Iniciando Processamento..."##"Importação Evento S-2190"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('T3A') + " T3A "
cQuery 	+= "WHERE T3A.T3A_FILIAL IN (" + cFilIn + ") AND T3A.T3A_STATUS = '4' AND "
cQuery 	+= "T3A.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr2190" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('T3A') + " T3A "
cQuery 	+= "WHERE T3A.T3A_FILIAL IN (" + cFilIn + ") AND T3A.T3A_STATUS = '4' AND "
cQuery 	+= "T3A.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY T3A.T3A_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->T3A_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC

	lNovo := !RJE->( dbSeek( "S2190" + AllTrim((cAliasQRY)->T3A_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->T3A_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S2190", "", ((cAliasQRY)->T3A_CPF+(cAliasQRY)->T3A_DTADMI), ("S2190"+AllTrim((cAliasQRY)->T3A_ID) + AllTrim((cAliasQRY)->T3A_VERSAO)), (Iif((cAliasQRY)->T3A_EVENTO == "A", "2", "1")), "Importado TAF", "4", sToD((cAliasQRY)->T3A_DINSIS), "", (cAliasQRY)->T3A_EVENTO, (cAliasQRY)->T3A_PROTUL, (cAliasQRY)->T3A_PROTPN }

	fCriaLote( "S2190", cAliasQRY, "T3A" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S2190" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr2200
Realiza a migração da tabela C9V para RJE (S-2200)
@author  Allyson L Mesashi
@since   11/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr2200(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aRJE		:= {}
Local cAliasQRY := "IMPC9V"
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cQuery	:= ""
Local lAdmPubl	:= .F.
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0329 )//"Iniciando Processamento..."##"Importação Evento S-2200"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('C9V') + " C9V "
cQuery 	+= "WHERE C9V.C9V_FILIAL IN (" + cFilIn + ") AND C9V.C9V_NOMEVE = 'S2200' AND C9V.C9V_STATUS = '4' AND "
cQuery 	+= "C9V.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr2200" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('C9V') + " C9V "
cQuery 	+= "WHERE C9V.C9V_FILIAL IN (" + cFilIn + ") AND C9V.C9V_NOMEVE = 'S2200' AND C9V.C9V_STATUS = '4' AND "
cQuery 	+= "C9V.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY C9V.C9V_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->C9V_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC

	lNovo := !RJE->( dbSeek( "S2200" + AllTrim((cAliasQRY)->C9V_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->C9V_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S2200", "", (cAliasQRY)->C9V_MATRIC, ("S2200"+AllTrim((cAliasQRY)->C9V_ID) + AllTrim((cAliasQRY)->C9V_VERSAO)), (Iif((cAliasQRY)->C9V_EVENTO == "A", "2", "1")), "Importado TAF", "4", sToD((cAliasQRY)->C9V_DINSIS), "", (cAliasQRY)->C9V_EVENTO, (cAliasQRY)->C9V_PROTUL, (cAliasQRY)->C9V_PROTPN }

	fCriaLote( "S2200", cAliasQRY, "C9V" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S2200" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr2205
Realiza a migração da tabela T1U para RJE (S-2205)
@author  Allyson L Mesashi
@since   13/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr2205(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aRJE		:= {}
Local cAliasQRY := "IMPT1U"
Local cCatC9V	:= ""
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cKey		:= ""
Local cQuery	:= ""
Local cTCVIN    := fCatTrabEFD("TCV")
Local lAdmPubl	:= .F.
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0330 )//"Iniciando Processamento..."##"Importação Evento S-2205"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('T1U') + " T1U "
cQuery 	+= "WHERE T1U.T1U_FILIAL IN (" + cFilIn + ") AND T1U.T1U_STATUS = '4' AND "
cQuery 	+= "T1U.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr2205" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('T1U') + " T1U "
cQuery 	+= "WHERE T1U.T1U_FILIAL IN (" + cFilIn + ") AND T1U.T1U_STATUS = '4' AND "
cQuery 	+= "T1U.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY T1U.T1U_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->T1U_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	cCatC9V		:= Posicione("CUP",1,xFilial("CUP", (cAliasQRY)->T1U_FILIAL)+(cAliasQRY)->T1U_ID+"1","CUP_CODCAT")
	If Empty(cCatC9V)
		cCatC9V	:= Posicione("C9V",2,xFilial("C9V", (cAliasQRY)->T1U_FILIAL)+(cAliasQRY)->T1U_ID+"1","C9V_CATCI")
	Else
		Posicione("C9V",2,xFilial("C9V", (cAliasQRY)->T1U_FILIAL)+(cAliasQRY)->T1U_ID+"1","C9V_CATCI")
	EndIf
	cCatC9V		:= Posicione("C87",1,xFilial("C87", (cAliasQRY)->T1U_FILIAL)+cCatC9V,"C87_CODIGO")

	lNovo := !RJE->( dbSeek( "S2205" + AllTrim((cAliasQRY)->T1U_PROTUL) ) )

	If cCatC9V $ cTCVIN
		cKey := C9V->C9V_MATRIC
	Else
		cKey := (C9V->C9V_CPF+cCatC9V+dToS(C9V->C9V_DTINIV))
	EndIf

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->T1U_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S2205", "", cKey, ("S2205"+AllTrim((cAliasQRY)->T1U_ID) + AllTrim((cAliasQRY)->T1U_VERSAO)), (Iif((cAliasQRY)->T1U_EVENTO == "A", "2", "1")), "Importado TAF", "4", sToD((cAliasQRY)->T1U_DTALT), "", (cAliasQRY)->T1U_EVENTO, (cAliasQRY)->T1U_PROTUL, (cAliasQRY)->T1U_PROTPN }

	fCriaLote( "S2205", cAliasQRY, "T1U" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S2205" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr2206
Realiza a migração da tabela T1V para RJE (S-2206)
@author  Allyson L Mesashi
@since   13/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr2206(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aRJE		:= {}
Local cAliasQRY := "IMPT1V"
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cQuery	:= ""
Local lAdmPubl	:= .F.
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0331 )//"Iniciando Processamento..."##"Importação Evento S-2206"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('T1V') + " T1V "
cQuery 	+= "WHERE T1V.T1V_FILIAL IN (" + cFilIn + ") AND T1V.T1V_STATUS = '4' AND "
cQuery 	+= "T1V.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr2206" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('T1V') + " T1V "
cQuery 	+= "WHERE T1V.T1V_FILIAL IN (" + cFilIn + ") AND T1V.T1V_STATUS = '4' AND "
cQuery 	+= "T1V.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY T1V.T1V_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->T1V_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC

	lNovo := !RJE->( dbSeek( "S2206" + AllTrim((cAliasQRY)->T1V_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->T1V_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S2206", "", Posicione("C9V",2,xFilial("C9V", (cAliasQRY)->T1V_FILIAL)+(cAliasQRY)->T1V_ID+"1","C9V_MATRIC"), ("S2206"+AllTrim((cAliasQRY)->T1V_ID) + AllTrim((cAliasQRY)->T1V_VERSAO)), (Iif((cAliasQRY)->T1V_EVENTO == "A", "2", "1")), "Importado TAF", "4", sToD((cAliasQRY)->T1V_DTALT), "", (cAliasQRY)->T1V_EVENTO, (cAliasQRY)->T1V_PROTUL, (cAliasQRY)->T1V_PROTPN }

	fCriaLote( "S2206", cAliasQRY, "T1V" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S2206" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr2230
Realiza a migração da tabela CM6 para RJE (S-2230)
@author  Allyson L Mesashi
@since   18/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr2230(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aRJE		:= {}
Local cAliasQRY := "IMPCM6"
Local cCatC9V	:= ""
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cKey		:= ""
Local cMatric	:= ""
Local cQuery	:= ""
Local lAdmPubl	:= .F.
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0336 )//"Iniciando Processamento..."##"Importação Evento S-2230"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

CM6->( dbSetOrder(1) )//CM6_FILIAL+CM6_ID+CM6_VERSAO
RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('CM6') + " CM6 "
cQuery 	+= "WHERE CM6.CM6_FILIAL IN (" + cFilIn + ") AND CM6.CM6_STATUS = '4' AND "
cQuery 	+= "CM6.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr2230" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('CM6') + " CM6 "
cQuery 	+= "WHERE CM6.CM6_FILIAL IN (" + cFilIn + ") AND CM6.CM6_STATUS = '4' AND "
cQuery 	+= "CM6.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY CM6.CM6_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->CM6_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	cMatric		:= Posicione("C9V",2,xFilial("C9V", (cAliasQRY)->CM6_FILIAL)+(cAliasQRY)->CM6_FUNC+"1","C9V_MATRIC")
	If Empty(cMatric)
		cCatC9V	:= Posicione("C87",1,xFilial("C87", (cAliasQRY)->CM6_FILIAL)+C9V->C9V_CATCI,"C87_CODIGO")
		cMatric	:= (C9V->C9V_CPF + cCatC9V + dToS(C9V->C9V_DTINIV))
	EndIf
	If (cAliasQRY)->CM6_XMLREC == "INIC"
		cKey	:= cMatric + (cAliasQRY)->CM6_DTAFAS + "I"
	ElseIf (cAliasQRY)->CM6_XMLREC == "COMP"
		cKey	:= cMatric + (cAliasQRY)->CM6_DTAFAS + "C"
	ElseIf (cAliasQRY)->CM6_XMLREC == "TERM"
		CM6->( dbSeek( (cAliasQRY)->CM6_FILIAL + (cAliasQRY)->CM6_ID + (cAliasQRY)->CM6_VERANT ) )
		cKey	:= cMatric + dToS(CM6->CM6_DTAFAS) + "F"
	EndIf

	lNovo := !RJE->( dbSeek( "S2230" + AllTrim((cAliasQRY)->CM6_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->CM6_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S2230", "", cKey, ("S2230"+AllTrim((cAliasQRY)->CM6_ID) + AllTrim((cAliasQRY)->CM6_VERSAO)), (Iif((cAliasQRY)->CM6_EVENTO $ "A/R", "2", "1")), "Importado TAF", "4", sToD((cAliasQRY)->CM6_DINSIS), "", (Iif((cAliasQRY)->CM6_EVENTO $ "I/F", "I", (cAliasQRY)->CM6_EVENTO)), (cAliasQRY)->CM6_PROTUL, (cAliasQRY)->CM6_PROTPN }

	fCriaLote( "S2230", cAliasQRY, "CM6" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S2230" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr2298
Realiza a migração da tabela CMF para RJE (S-2298)
@author  Allyson L Mesashi
@since   19/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr2298(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aRJE		:= {}
Local cAliasQRY := "IMPCMF"
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cQuery	:= ""
Local lAdmPubl	:= .F.
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0341 )//"Iniciando Processamento..."##"Importação Evento S-2298"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('CMF') + " CMF "
cQuery 	+= "WHERE CMF.CMF_FILIAL IN (" + cFilIn + ") AND CMF.CMF_STATUS = '4' AND "
cQuery 	+= "CMF.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr2298" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('CMF') + " CMF "
cQuery 	+= "WHERE CMF.CMF_FILIAL IN (" + cFilIn + ") AND CMF.CMF_STATUS = '4' AND "
cQuery 	+= "CMF.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY CMF.CMF_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->CMF_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC

	lNovo := !RJE->( dbSeek( "S2298" + AllTrim((cAliasQRY)->CMF_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->CMF_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S2298", "", Posicione("C9V",2,xFilial("C9V", (cAliasQRY)->CMF_FILIAL)+(cAliasQRY)->CMF_FUNC+"1","C9V_MATRIC"), ("S2298"+AllTrim((cAliasQRY)->CMF_ID) + AllTrim((cAliasQRY)->CMF_VERSAO)), (Iif((cAliasQRY)->CMF_EVENTO == "A", "2", "1")), "Importado TAF", "4", sToD((cAliasQRY)->CMF_DINSIS), "", (cAliasQRY)->CMF_EVENTO, (cAliasQRY)->CMF_PROTUL, (cAliasQRY)->CMF_PROTPN }

	fCriaLote( "S2298", cAliasQRY, "CMF" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S2298" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr2299
Realiza a migração da tabela CMD para RJE (S-2299)
@author  Allyson L Mesashi
@since   14/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr2299(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aRJE		:= {}
Local cAliasQRY := "IMPCMD"
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cQuery	:= ""
Local lAdmPubl	:= .F.
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0342 )//"Iniciando Processamento..."##"Importação Evento S-2299"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('CMD') + " CMD "
cQuery 	+= "WHERE CMD.CMD_FILIAL IN (" + cFilIn + ") AND CMD.CMD_STATUS = '4' AND "
cQuery 	+= "CMD.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr2299" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('CMD') + " CMD "
cQuery 	+= "WHERE CMD.CMD_FILIAL IN (" + cFilIn + ") AND CMD.CMD_STATUS = '4' AND "
cQuery 	+= "CMD.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY CMD.CMD_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->CMD_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC

	lNovo := !RJE->( dbSeek( "S2299" + AllTrim((cAliasQRY)->CMD_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->CMD_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S2299", "", Posicione("C9V",2,xFilial("C9V", (cAliasQRY)->CMD_FILIAL)+(cAliasQRY)->CMD_FUNC+"1","C9V_MATRIC"), ("S2299"+AllTrim((cAliasQRY)->CMD_ID) + AllTrim((cAliasQRY)->CMD_VERSAO)), (Iif((cAliasQRY)->CMD_EVENTO == "A", "2", "1")), "Importado TAF", "4", sToD((cAliasQRY)->CMD_DINSIS), "", (cAliasQRY)->CMD_EVENTO, (cAliasQRY)->CMD_PROTUL, (cAliasQRY)->CMD_PROTPN }

	fCriaLote( "S2299", cAliasQRY, "CMD" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S2299" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr2300
Realiza a migração da tabela C9V para RJE (S-2300)
@author  Allyson L Mesashi
@since   11/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr2300(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aRJE		:= {}
Local cAliasQRY := "IMPC9V"
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cQuery	:= ""
Local lAdmPubl	:= .F.
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nThreads	:= Val(cNumThrd)
Local lGeraMat	:= SRA->(ColumnPos("RA_DESCEP")) > 0
Local cVersaoEnv	:= ""

If FindFunction("fVersEsoc")
	fVersEsoc( "S2300", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersaoEnv )
EndIf

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0332 )//"Iniciando Processamento..."##"Importação Evento S-2300"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('C9V') + " C9V "
cQuery 	+= "WHERE C9V.C9V_FILIAL IN (" + cFilIn + ") AND C9V.C9V_NOMEVE = 'S2300' AND C9V.C9V_STATUS = '4' AND "
cQuery 	+= "C9V.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr2300" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('C9V') + " C9V "
cQuery 	+= "WHERE C9V.C9V_FILIAL IN (" + cFilIn + ") AND C9V.C9V_NOMEVE = 'S2300' AND C9V.C9V_STATUS = '4' AND "
cQuery 	+= "C9V.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY C9V.C9V_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->C9V_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC

	If  cVersaoEnv >= "9.0" .And. !Empty((cAliasQRY)->C9V_MATTSV) .And. lGeraMat .And. Posicione("SRA",24,(cAliasQRY)->C9V_MATTSV + (cAliasQRY)->C9V_FILIAL,"RA_DESCEP") == "1"
		cChaveMid := (cAliasQRY)->C9V_MATTSV
	Else
		cChaveMid := ((cAliasQRY)->C9V_CPF+Posicione("C87",1,xFilial("C87", (cAliasQRY)->C9V_FILIAL)+(cAliasQRY)->C9V_CATCI,"C87_CODIGO")+(cAliasQRY)->C9V_DTINIV)
	EndIf
	
	lNovo := !RJE->( dbSeek( "S2300" + AllTrim((cAliasQRY)->C9V_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->C9V_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S2300", "", cChaveMid, ("S2300"+AllTrim((cAliasQRY)->C9V_ID) + AllTrim((cAliasQRY)->C9V_VERSAO)), (Iif((cAliasQRY)->C9V_EVENTO == "A", "2", "1")), "Importado TAF", "4", sToD((cAliasQRY)->C9V_DINSIS), "", (cAliasQRY)->C9V_EVENTO, (cAliasQRY)->C9V_PROTUL, (cAliasQRY)->C9V_PROTPN }

	fCriaLote( "S2300", cAliasQRY, "C9V" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S2300" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr2306
Realiza a migração da tabela T0F para RJE (S-2306)
@author  Allyson L Mesashi
@since   13/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr2306(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aRJE		:= {}
Local cAliasQRY := "IMPT0F"
Local cCatC9V	:= ""
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cQuery	:= ""
Local lAdmPubl	:= .F.
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0343 )//"Iniciando Processamento..."##"Importação Evento S-2306"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('T0F') + " T0F "
cQuery 	+= "WHERE T0F.T0F_FILIAL IN (" + cFilIn + ") AND T0F.T0F_STATUS = '4' AND "
cQuery 	+= "T0F.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr2306" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('T0F') + " T0F "
cQuery 	+= "WHERE T0F.T0F_FILIAL IN (" + cFilIn + ") AND T0F.T0F_STATUS = '4' AND "
cQuery 	+= "T0F.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY T0F.T0F_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->T0F_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	cCatC9V		:= Posicione("C9V",2,xFilial("C9V", (cAliasQRY)->T0F_FILIAL)+(cAliasQRY)->T0F_ID+"1","C9V_CATCI")
	cCatC9V		:= Posicione("C87",1,xFilial("C87", C9V->C9V_FILIAL)+cCatC9V,"C87_CODIGO")

	lNovo := !RJE->( dbSeek( "S2306" + AllTrim((cAliasQRY)->T0F_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->T0F_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S2306", "", (C9V->C9V_CPF+cCatC9V+dToS(C9V->C9V_DTINIV)), ("S2306"+AllTrim((cAliasQRY)->T0F_ID) + AllTrim((cAliasQRY)->T0F_VERSAO)), (Iif((cAliasQRY)->T0F_EVENTO == "A", "2", "1")), "Importado TAF", "4", sToD((cAliasQRY)->T0F_DTALT), "", (cAliasQRY)->T0F_EVENTO, (cAliasQRY)->T0F_PROTUL, (cAliasQRY)->T0F_PROTPN }

	fCriaLote( "S2306", cAliasQRY, "T0F" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S2306" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigr2399
Realiza a migração da tabela T92 para RJE (S-2399)
@author  Allyson L Mesashi
@since   14/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigr2399(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local aAreaSM0 	:= SM0->(GetArea())
Local aRJE		:= {}
Local cAliasQRY := "IMPT92"
Local cCatC9V	:= ""
Local cFilBkp	:= cFilAnt
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cQuery	:= ""
Local lAdmPubl	:= .F.
Local lMultThr	:= .F.
Local lNovo		:= .F.
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0
Local nThreads	:= Val(cNumThrd)

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0344 )//"Iniciando Processamento..."##"Importação Evento S-2399"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "
fRstLote()

RJE->( dbSetOrder(5) )//RJE_EVENTO+RJE_RECIB
If Select(cAliasQRY) > 0
	(cAliasQRY)->( dbCloseArea() )
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('T92') + " T92 "
cQuery 	+= "WHERE T92.T92_FILIAL IN (" + cFilIn + ") AND T92.T92_STATUS = '4' AND "
cQuery 	+= "T92.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

lMultThr := (nCont > 2500 .And. !Empty(nThreads) .And. nThreads > 1)
If lMultThr
	oMultiThr := FWIPCWait():New( "fMigr2399" , 10000 )
	oMultiThr:SetThreads(nThreads)
	oMultiThr:SetEnvironment( cEmpAnt, cFilAnt )
	oMultiThr:Start("fImpRJE")
	Sleep( 1000 * nThreads )
EndIf

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('T92') + " T92 "
cQuery 	+= "WHERE T92.T92_FILIAL IN (" + cFilIn + ") AND T92.T92_STATUS = '4' AND "
cQuery 	+= "T92.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY T92.T92_PROTUL"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "
	fPosFil( cEmpAnt, AllTrim((cAliasQRY)->T92_FILIAL) )
	cFilAnt 	:= SM0->M0_CODFIL
	cTpInsc 	:= Iif(SM0->M0_TPINSC == 2, "1", "2")
	cNrInsc 	:= SM0->M0_CGC
	cCatC9V		:= Posicione("C9V",2,xFilial("C9V", (cAliasQRY)->T92_FILIAL)+(cAliasQRY)->T92_TRABAL+"1","C9V_CATCI")
	cCatC9V		:= Posicione("C87",1,xFilial("C87", C9V->C9V_FILIAL)+cCatC9V,"C87_CODIGO")

	lNovo := !RJE->( dbSeek( "S2399" + AllTrim((cAliasQRY)->T92_PROTUL) ) )

	aRJE := { lNovo, (xFilial("RJE", cFilAnt)), (cAliasQRY)->T92_FILIAL, cTpInsc, (Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc )), "S2399", "", (C9V->C9V_CPF+cCatC9V+dToS(C9V->C9V_DTINIV)), ("S2399"+AllTrim((cAliasQRY)->T92_ID) + AllTrim((cAliasQRY)->T92_VERSAO)), (Iif((cAliasQRY)->T92_EVENTO == "A", "2", "1")), "Importado TAF", "4", sToD((cAliasQRY)->T92_DINSIS), "", (cAliasQRY)->T92_EVENTO, (cAliasQRY)->T92_PROTUL, (cAliasQRY)->T92_PROTPN }

	fCriaLote( "S2399", cAliasQRY, "T92" )

	If lMultThr
		oMultiThr:Go( aRJE )
	Else
		fImpRJE( aRJE )
	EndIf

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

If lMultThr
	oMultiThr:Stop()
	FreeObj(oMultiThr)
EndIf

fPesqTSS( "S2399" )

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMigrV3N
Realiza a migração da tabela V3N para RJO
@author  Allyson L Mesashi
@since   07/04/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fMigrV3N(oSay, oMeter, oMeter2, oSayProc2, oSayProc3)

Local aArea 	:= GetArea()
Local cAliasQRY := "IMPV3N"
Local cFilIn	:= ""
Local cFilQry	:= ""
Local cQuery	:= ""
Local cTbGpe	:= FWModeAccess( "RJO", 1) + FWModeAccess( "RJO", 2) + FWModeAccess( "RJO", 3)
Local cTbTaf	:= FWModeAccess( "V3N", 1) + FWModeAccess( "V3N", 2) + FWModeAccess( "V3N", 3)
Local nCont		:= 0
Local nContFil	:= 0
Local nInc		:= 0

nTotProc++
oMeter2:Set(nTotProc)
oSay:SetText( STR0279 + STR0363 )//"Iniciando Processamento..."##"Importação da tabela V3N"
oSayProc2:SetText( STR0361 + cValToChar(nTotProc) + "/" + cValToChar(nQtdSel) )//"Eventos importados: "

If cTbGpe != cTbTaf
	aAdd( aLogTab, STR0374 + CRLF + STR0282 )//"O modo de acesso das tabelas V3N e RJO está divergente!"##"Não será possível efetuar a migração dos registros"
	Return .F.
EndIf

For nContFil := 1 To Len(aArrayFil)
	cFilQry += aArrayFil[nContFil]
Next nContFil
cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + RetSqlName('V3N') + " V3N "
cQuery 	+= "WHERE V3N.V3N_FILIAL IN (" + cFilIn + ") AND "
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " V3N.V3N_PERAPU >= '" + cPerDe + "' AND V3N.V3N_PERAPU <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "("
cQuery 	+= "(V3N.V3N_ORIGEM = '3' OR V3N.V3N_ORIGEM = '5') OR "
cQuery 	+= "(V3N.V3N_ORIGEM = '1' AND"
cQuery 	+= "((V3N.V3N_NATRUB = '9901' AND V3N.V3N_TPRUBR = '3') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '9201' AND V3N.V3N_ITCP IN ('31','32')) OR "
cQuery 	+= "(V3N.V3N_NATRUB = '1409' AND V3N.V3N_ITCP = '51') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '4050' AND V3N.V3N_ITCP = '21') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '4051' AND V3N.V3N_ITCP = '22') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '9902' AND V3N.V3N_TPRUBR = '3') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '9904' AND V3N.V3N_TPRUBR = '3') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '9908' AND V3N.V3N_TPRUBR = '3')))"
cQuery 	+= ") AND "
cQuery 	+= "V3N.D_E_L_E_T_ = ' ' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
nCont := (cAliasQRY)->CONT
oMeter:SetTotal( nCont )
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT V3N_FILIAL,V3N_INDAPU,V3N_PERAPU,V3N_CPF "
cQuery 	+= "FROM " + RetSqlName('V3N') + " V3N "
cQuery 	+= "WHERE V3N.V3N_FILIAL IN (" + cFilIn + ") AND "
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " V3N.V3N_PERAPU >= '" + cPerDe + "' AND V3N.V3N_PERAPU <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "("
cQuery 	+= "(V3N.V3N_ORIGEM = '3' OR V3N.V3N_ORIGEM = '5') OR "
cQuery 	+= "(V3N.V3N_ORIGEM = '1' AND"
cQuery 	+= "((V3N.V3N_NATRUB = '9901' AND V3N.V3N_TPRUBR = '3') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '9201' AND V3N.V3N_ITCP IN ('31','32')) OR "
cQuery 	+= "(V3N.V3N_NATRUB = '1409' AND V3N.V3N_ITCP = '51') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '4050' AND V3N.V3N_ITCP = '21') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '4051' AND V3N.V3N_ITCP = '22') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '9902' AND V3N.V3N_TPRUBR = '3') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '9904' AND V3N.V3N_TPRUBR = '3') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '9908' AND V3N.V3N_TPRUBR = '3')))"
cQuery 	+= ") AND "
cQuery 	+= "V3N.D_E_L_E_T_ = ' ' "
cQuery 	+= "GROUP BY V3N_FILIAL,V3N_INDAPU,V3N_PERAPU,V3N_CPF"
cQuery 	+= "ORDER BY V3N_FILIAL,V3N_INDAPU,V3N_PERAPU,V3N_CPF"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

RJO->( dbSetOrder(1) )//RJO_FILIAL+RJO_INDAPU+RJO_PERAPU+RJO_CPF+RJO_EVENTO
While (cAliasQRY)->( !EoF() )
	If RJO->( dbSeek( (cAliasQRY)->V3N_FILIAL+(cAliasQRY)->V3N_INDAPU+(cAliasQRY)->V3N_PERAPU+(cAliasQRY)->V3N_CPF ) )
		While RJO->( !EoF() ) .And. RJO->RJO_FILIAL+RJO->RJO_INDAPU+RJO->RJO_PERAPU+RJO->RJO_CPF == (cAliasQRY)->V3N_FILIAL+(cAliasQRY)->V3N_INDAPU+(cAliasQRY)->V3N_PERAPU+(cAliasQRY)->V3N_CPF
			If RJO->( RecLock( "RJO", .F. ) )
				RJO->( dbDelete() )
				RJO->( MsUnlock() )
			EndIf
			RJO->( dbSkip() )
		EndDo
	EndIf
	(cAliasQRY)->( dbSkip() )
EndDo
(cAliasQRY)->( dbCloseArea() )

cQuery	:= "SELECT * "
cQuery 	+= "FROM " + RetSqlName('V3N') + " V3N "
cQuery 	+= "WHERE V3N.V3N_FILIAL IN (" + cFilIn + ") AND "
If !Empty(cPerDe) .And. !Empty(cPerAte)
	cQuery 	+= " V3N.V3N_PERAPU >= '" + cPerDe + "' AND V3N.V3N_PERAPU <= '" + cPerAte + "' AND "
EndIf
cQuery 	+= "("
cQuery 	+= "(V3N.V3N_ORIGEM = '3' OR V3N.V3N_ORIGEM = '5') OR "
cQuery 	+= "(V3N.V3N_ORIGEM = '1' AND"
cQuery 	+= "((V3N.V3N_NATRUB = '9901' AND V3N.V3N_TPRUBR = '3') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '9201' AND V3N.V3N_ITCP IN ('31','32')) OR "
cQuery 	+= "(V3N.V3N_NATRUB = '1409' AND V3N.V3N_ITCP = '51') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '4050' AND V3N.V3N_ITCP = '21') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '4051' AND V3N.V3N_ITCP = '22') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '9902' AND V3N.V3N_TPRUBR = '3') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '9904' AND V3N.V3N_TPRUBR = '3') OR "
cQuery 	+= "(V3N.V3N_NATRUB = '9908' AND V3N.V3N_TPRUBR = '3')))"
cQuery 	+= ") AND "
cQuery 	+= "V3N.D_E_L_E_T_ = ' ' "
cQuery 	+= "ORDER BY V3N_FILIAL,V3N_INDAPU,V3N_PERAPU,V3N_CPF,V3N_EVENTO,V3N_ORIGEM"
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
	nInc++
	oMeter:Set(nInc)
	oSayProc3:SetText( STR0362 + cValToChar(nInc) + "/" + cValToChar(nCont) )//"Registros importados: "

	If Reclock("RJO", .T.)
		RJO->RJO_FILIAL 	:= (cAliasQRY)->V3N_FILIAL
		RJO->RJO_INDAPU 	:= (cAliasQRY)->V3N_INDAPU
		RJO->RJO_PERAPU 	:= (cAliasQRY)->V3N_PERAPU
		RJO->RJO_CPF 		:= (cAliasQRY)->V3N_CPF
		RJO->RJO_NOME 		:= (cAliasQRY)->V3N_NOME
		RJO->RJO_MATRIC 	:= (cAliasQRY)->V3N_MATRIC
		RJO->RJO_CATEG 		:= (cAliasQRY)->V3N_CATEG
		RJO->RJO_TPINSC 	:= (cAliasQRY)->V3N_TPINSC
		RJO->RJO_NRINSC 	:= (cAliasQRY)->V3N_NRINSC
		RJO->RJO_CODLOT 	:= (cAliasQRY)->V3N_CODLOT
		RJO->RJO_EVENTO 	:= Iif( (cAliasQRY)->V3N_ORIGEM == "3", "S-5001", Iif( (cAliasQRY)->V3N_ORIGEM == "5", "S-5003", (cAliasQRY)->V3N_EVENTO ) )
		RJO->RJO_NATRUB 	:= (cAliasQRY)->V3N_NATRUB
		RJO->RJO_TPRUBR 	:= (cAliasQRY)->V3N_TPRUBR
		RJO->RJO_INCCP 		:= (cAliasQRY)->V3N_ITCP
		RJO->RJO_INCFGT 	:= (cAliasQRY)->V3N_ITFGTS
		RJO->RJO_INCIRF 	:= (cAliasQRY)->V3N_ITIRRF
		RJO->RJO_INDDEC 	:= (cAliasQRY)->V3N_INDDEC
		RJO->RJO_TPVLR 		:= (cAliasQRY)->V3N_TPVLR
		RJO->RJO_VALOR 		:= (cAliasQRY)->V3N_VALOR
		RJO->( MsUnlock() )
	EndIf
	aAdd(aLogImp, OemToAnsi(STR0376) + "V3N" + OemToAnsi(STR0357) + "ID: " + (cAliasQRY)->V3N_ID + OemToAnsi(STR0375) ) //"O registro da tabela XXX com ID: XXXXXX foi importado."
	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fImpRJE()
Função que efetua a gravação na RJE
@author  Allyson L Mesashi
@since   04/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Function fImpRJE( aRJE )

If Reclock("RJE", aRJE[01])
	RJE->RJE_FILIAL 	:= aRJE[02]
	RJE->RJE_FIL 		:= aRJE[03]
	RJE->RJE_TPINSC		:= aRJE[04]
	RJE->RJE_INSCR		:= aRJE[05]
	RJE->RJE_EVENTO		:= aRJE[06]
	RJE->RJE_INI 		:= aRJE[07]
	RJE->RJE_KEY 		:= aRJE[08]
	RJE->RJE_RETKEY 	:= aRJE[09]
	RJE->RJE_RETF 		:= aRJE[10]
	RJE->RJE_VERS 		:= aRJE[11]
	RJE->RJE_STATUS		:= aRJE[12]
	RJE->RJE_DTG		:= aRJE[13]
	RJE->RJE_HORAG		:= aRJE[14]
	RJE->RJE_OPER 		:= aRJE[15]
	RJE->RJE_RECIB 		:= aRJE[16]
	RJE->RJE_RECANT		:= aRJE[17]
	RJE->( MsUnlock() )
EndIf

Return()

/*/
{Protheus.doc} fGetUrlTSS
Rotina para retornar a URL do TSS (Copia de getUrlTSS)
@type  Static Function
@author  Allyson L Mesashi
@since   09/03/2020
@version 1.0
@return return, return_type, return_description
/*/
Static Function fGetUrlTSS()

Local cUrl := ""

If FindFunction("TafGetUrlTSS")
    cUrl := AllTrim((TafGetUrlTSS()))
Else
    cUrl := AllTrim(GetNewPar("MV_TAFSURL","http://"))
EndIf

If !("TSSWSSOCIAL.APW" $ Upper(cUrl))
    cUrl += "/TSSWSSOCIAL.apw"
EndIf

Return cUrl

/*/
{Protheus.doc} fGetIdEntidade
Rotina para retornar a Entidade do TSS (Copia de getIdEntidade)
@type  Static Function
@author  Allyson L Mesashi
@since   09/03/2020
@version 1.0
@return return, return_type, return_description
/*/
Static Function fGetIdEntidade(cUrl, cIdEntidade)

Local lTransFil := .F.
Local cCheckURL := ""
Local lRet 		:= .T.

If FindFunction("TAFTransFil")
    lTransFil := TAFTransFil(.F.)
EndIf

If !("TSSWSSOCIAL.APW" $ Upper(cUrl))
    cCheckURL := cUrl
Else
    cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
EndIf

If TAFCTSpd(cCheckURL,,.T.)
    cIdEntidade := TAFRIdEnt(lTransFil)
	If Empty(cIdEntidade)
		lRet := .F.
	EndIf
Else
    lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaLote()
Função que cria o lote para pesquisa no TSS
@author  Allyson L Mesashi
@since   09/03/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fCriaLote(cEvento, cAliasQRY, cPrefTab)

If !Empty((cAliasQRY)->&(cPrefTab+"_ID")) .And. !Empty((cAliasQRY)->&(cPrefTab+"_VERSAO"))
	nContLote++
	cTSSKey := cEvento + AllTrim((cAliasQRY)->&(cPrefTab+"_ID")) + AllTrim((cAliasQRY)->&(cPrefTab+"_VERSAO"))
	aAdd( aXmls, cTSSKey )
	If nContLote == nTamLote
		aAdd(aXmlsLote, aClone(aXmls))
		aSize(aXmls, 0)
		aXmls     := {}
		nContLote := 0
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fPesqTSS()
Função que efetua a pesquisa do XML no TSS
@author  Allyson L Mesashi
@since   09/03/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fPesqTSS( cEvento )

Local cChave	:= ""
Local cId		:= ""
Local cVersao	:= ""
Local cXMLId	:= ""
Local nItem		:= 0
Local nX		:= 0

If Len(aXmls) > 0
	aAdd(aXmlsLote,aClone(aXmls))
	aSize(aXmls,0)
	aXmls := {}
EndIf

RJE->(dbSetOrder(3))//RJE_EVENTO+RJE_RETKEY+RJE_INI
For nX := 1 To Len(aXmlsLote)
	aXmlsRetorno := fGetXMLTSS(aXmlsLote[nX])
	For nItem := 1 To Len(aXmlsRetorno)
		If cEvento $ "S1200/S1210/S1295/S2260"
			cId 	:= SubStr(aXmlsRetorno[nItem][2], 6, 36)
			cChave 	:= cEvento+cId
		Else
			cId 	:= SubStr(aXmlsRetorno[nItem][2], 6, 6)
			cVersao	:= AllTrim(SubStr(aXmlsRetorno[nItem][2], 12))
			cChave 	:= cEvento+aXmlsRetorno[nItem][2]
		EndIf
		If cEvento $ "S1200/S1210/S1295/S2260"
			cErro := "ID: " + cId
		Else
			cErro := "ID: " + cId + OemToAnsi(STR0355) + cVersao//" | Versão: "
		EndIf
		If aXmlsRetorno[nItem][1]
			aXmlsRetorno[nItem][3] := StrTran(aXmlsRetorno[nItem][3], '<?xml version="1.0" encoding="UTF-8"?>', '' ) // UTF Upper
			aXmlsRetorno[nItem][3] := StrTran(aXmlsRetorno[nItem][3], '<?xml version="1.0" encoding="utf-8"?>', '' ) // UTF Lower
			cXMLId := fGetRetTag( aXmlsRetorno[nItem][3], "XMLID" )
			If RJE->( dbSeek( cChave ) )
				If RJE->( Reclock("RJE", .F.) )
					RJE->RJE_RETKEY := cXMLId
					RJE->RJE_XML	:= aXmlsRetorno[nItem][3]
					RJE->( MsUnlock() )
				EndIf
			EndIf
			aAdd(aLogImp, OemToAnsi(STR0356) + SubStr(cEvento, 2, 4) + OemToAnsi(STR0357) + cErro + OemToAnsi(STR0375) ) //"O registro do evento S-XXXX com ID: XXXXXX | Versão: XXXXXXX foi importado."
		Else
			cXMLId	:= ""
			aAdd(aLogErr, OemToAnsi(STR0356) + SubStr(cEvento, 2, 4) + OemToAnsi(STR0357) + cErro + OemToAnsi(STR0358) ) //"O registro do evento S-XXXX com ID: XXXXXX | Versão: XXXXXXX não foi encontrado no TSS. Obs.: O XML não foi importado."
		EndIf
	Next nItem
	aSize(aXmlsRetorno, 0)
	aXmlsRetorno := Nil
Next nX

aSize(aXmlsLote, 0)
aXmlsLote := Nil

Return

/*/
{Protheus.doc} fGetXMLTSS
Rotina que irá realizar a consulta dos eventos no TSS. (Copia de TafGetXMLTSS)
Para retorno do recibo e do XML de envio
@type  Static Function
@author Diego Santos
@since 15-10-2018
@version 1.0
@return return, return_type, return_description
/*/
Static Function fGetXMLTSS(aLoteXML)

Local nX                := 0
Local nItemLote         := 0
Local oSocialRetorno    := Nil
Local oSocial           := Nil
Local aXmlsRetorno      := {}
Local cAmbiente         := SuperGetMv('MV_TAFAMBE',.F.,"2")

oSocial 	   						:= WSTSSWSSOCIAL():New()
oSocial:_Url 						:= cUrlTSS
oSocial:oWSENTEXPDADOS:cUSERTOKEN 	:= "TOTVS"
oSocial:oWSENTEXPDADOS:cID_ENT    	:= cIdEntidade
oSocial:oWSENTEXPDADOS:cAMBIENTE   	:= cAmbiente

oSocial:oWSENTEXPDADOS:oWSENTEXPDOCS := WsClassNew("TSSWSSOCIAL_ARRAYOFENTEXPDOC")
oSocial:oWSENTEXPDADOS:oWSENTEXPDOCS:OWSENTEXPDOC := {}

For nItemLote := 1 To Len(aLoteXML)
	aAdd(oSocial:oWSENTEXPDADOS:oWSENTEXPDOCS:OWSENTEXPDOC, WsClassNew("TSSWSSOCIAL_ENTEXPDOC"))
	ATAIL(oSocial:oWSENTEXPDADOS:oWSENTEXPDOCS:OWSENTEXPDOC):CID := aLoteXML[nItemLote]
Next nItemLote

oSocial:ExportarDocumentos()

If ValType(oSocial:oWSEXPORTARDOCUMENTOSRESULT:oWSSAIDAEXPDOCS) <> "U"
	oSocialRetorno := oSocial:oWSEXPORTARDOCUMENTOSRESULT:oWSSAIDAEXPDOCS:oWSSAIDAEXPDOC
	For nX := 1 To Len(oSocialRetorno)
		aAdd(aXmlsRetorno, {oSocialRetorno[nX]:lSucesso, AllTrim(oSocialRetorno[nX]:cID), oSocialRetorno[nX]:cXMLERP})
	Next nX
EndIf
FreeObj(oSocialRetorno)
FreeObj(oSocial)
oSocialRetorno  := Nil
oSocial         := Nil
DelClassIntF()

Return aXmlsRetorno

/*/
{Protheus.doc} fGetRetTag
Rotina que irá realizar o parse do XML retornado
pelo TSS para capturar apenas o recibo do RET. (Copia de GetRetTag)
@type  Static Function
@author  Allyson L Mesashi
@since   09/03/2020
@version 1.0
@return return, return_type, return_description
/*/
Static Function fGetRetTag( cXML, cCodTag )

Local oXML          := tXMLManager():New()
Local cRetTag       := ""

If oXml:Parse(EncodeUTF8(cXML)) // Faz o parser para garantir que é um arquivo XML válido
    cRetTag := fRetTag(oXML, cCodTag)
EndIf
// Limpa da memória as classes de interfaces criadas por tXMLManager
FreeObj(oXml)
oXml := Nil

DelClassIntF()

Return cRetTag

//-------------------------------------------------------------------
/*/{Protheus.doc} fRetTag
Retorna o conteúdo da tag do arquivo xml (Copia de Migr01RetTag)
@author  Allyson L Mesashi
@since   09/03/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fRetTag(oXML, cCodTag )

Local cRet   := ""

If cCodTag == "XMLID"
    oXML:DOMChildNode()
    cRet := oXML:DOMGetAtt( "Id" )
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fContSel
Verifica quantas opções foram selecionadas
@author  Allyson L Mesashi
@since   03/04/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fContSel()

nQtdSel := 0

If lOpc01
	nQtdSel++
EndIf
If lOpc02
	nQtdSel++
EndIf
If lOpc03
	nQtdSel++
EndIf
If lOpc04
	nQtdSel++
EndIf
If lOpc05
	nQtdSel++
EndIf
If lOpc06
	nQtdSel++
EndIf
If lOpc07
	nQtdSel++
EndIf
If lOpc08
	nQtdSel++
EndIf
If lOpc09
	nQtdSel++
EndIf
If lOpc10
	nQtdSel++
EndIf
If lOpc11
	nQtdSel++
EndIf
If lOpc12
	nQtdSel++
EndIf
If lOpc13
	nQtdSel++
EndIf
If lOpc14
	nQtdSel++
EndIf
If lOpc15
	nQtdSel++
EndIf
If lOpc16
	nQtdSel++
EndIf
If lOpc17
	nQtdSel++
EndIf
If lOpc18
	nQtdSel++
EndIf
If lOpc19
	nQtdSel++
EndIf
If lOpc20
	nQtdSel++
EndIf
If lOpc21
	nQtdSel++
EndIf
If lOpc22
	nQtdSel++
EndIf
If lOpc23
	nQtdSel++
EndIf
If lOpc24
	nQtdSel++
EndIf
If lOpc25
	nQtdSel++
EndIf
If lOpc26
	nQtdSel++
EndIf
If lOpc27
	nQtdSel++
EndIf
If lOpc28
	nQtdSel++
EndIf
If lOpc29
	nQtdSel++
EndIf
If lOpc30
	nQtdSel++
EndIf
If lOpc31
	nQtdSel++
EndIf
If lOpc32
	nQtdSel++
EndIf
If lOpc33
	nQtdSel++
EndIf
If lOpc34
	nQtdSel++
EndIf
If lOpc35
	nQtdSel++
EndIf
If lOpc36
	nQtdSel++
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fRstLote
Reinicializa variáveis de pesquisa no TSS
@author  Allyson L Mesashi
@since   03/04/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fRstLote()

aXmls         	:= {}
aXmlsRetorno  	:= {}
aXmlsLote     	:= {}

Return
