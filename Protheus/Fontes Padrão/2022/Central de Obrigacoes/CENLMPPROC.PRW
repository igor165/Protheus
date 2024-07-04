#include 'totvs.ch'
#include 'protheus.ch'
#INCLUDE "Fwlibversion.ch"
#DEFINE ARQ_LOG_CARGA	"log_limpa_despesa.log"
#DEFINE CHECKED		1
#DEFINE STATUS		2
#DEFINE TABELA		3
#DEFINE DESCTABELA	4
#DEFINE FUNCLIMP	5
#DEFINE OBSERVACAO	6

#DEFINE AGUARDANDO	'0'
#DEFINE SUCESSO		'1'
#DEFINE FALHA		'2'
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENLMPPROC

Rotina criada para limpar as tabelas do SIP da Central de Obrigações

@author everton.mateus
@since 15/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Function CENLMPPROC()
	Local oBrw		:= ""
	Local aTabelas	:= RetornaTabelas()
	Local oDlg

	oOk 	:= LoadBitmap(GetResources(), "LBOK")
	oCancel := LoadBitmap(GetResources(), "LBNO")
	oSim  	:= LoadBitmap(GetResources(), "BR_VERDE")
	oNao  	:= LoadBitmap(GetResources(), "BR_VERMELHO")
	oTalvez	:= LoadBitmap(GetResources(), "BR_AMARELO")

	DEFINE MSDIALOG oDlg FROM 0,0 TO 340,640 PIXEL TITLE "Selecionar tabelas para limpar"

	oBrw := TCBrowse():New( 01,01,320,147 ,,{"","","Descrição","Observação"},{2,2,50,70},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrw:SetArray(aTabelas)
	oBrw:bLine := {|| {;
		iIf(aTabelas[oBrw:nAt,CHECKED],oOk,oCancel),;
		IIf(aTabelas[oBrw:nAt,STATUS]==AGUARDANDO,oTalvez, IIf(aTabelas[oBrw:nAt,STATUS]==SUCESSO,oSim,oNao)),;
		aTabelas[oBrw:nAt,DESCTABELA],;
		aTabelas[oBrw:nAt,OBSERVACAO];
		}}
	oBrw:bLDblClick := {|| aTabelas[oBrw:nAt,CHECKED] := !aTabelas[oBrw:nAt,CHECKED] }

	TButton():New(151,220, "Sair"		,,{|| oDlg:End() } , 040, 010 ,,,,.T.)
	TButton():New(151,270, "Limpar"		,,{|| plsProcSIP( aTabelas, oDlg ),	oDlg:Refresh() } , 040, 010 ,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} plsProcSIP

Função criada para executar a limpeza de todos os Tabelas marcadas no browse

@author everton.mateus
@since 15/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function plsProcSIP( aTabLmp, oBrwProc, lAuto )

	Local nTabela		:= 0
	Local cMsg		:= ''
	Local aRotProc	:= {}
	Local lOk		:= .F.

	Default aTabLmp := RetornaTabelas()
	Default lAuto := .F.

	If lAuto .OR. MsgYesNo("Esta ação irá limpar os dados das tabelas selecionadas. Confirma a execução desta ação ?")
		if lHabMetric .and. lLibSupFw .and. lVrsAppSw
			FWMetrics():addMetrics("Limpa Processamento", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
		endif

		PlsLogFil(CENDTHRL("I") + " Início da Limpeza.", ARQ_LOG_CARGA)
		For nTabela := 1 to len(aTabLmp)

			If aTabLmp[nTabela][CHECKED]
				If aTabLmp[nTabela][STATUS] == SUCESSO
					aAdd( aRotProc, aTabLmp[nTabela][DESCTABELA] )
					Loop
				EndIf

				MsgRun( "Processando " + aTabLmp[nTabela][DESCTABELA], "SIP", {|| lOk := controlProc( aTabLmp[nTabela][FUNCLIMP] ) } )

				If lOk
					aTabLmp[nTabela][STATUS] := SUCESSO
					aTabLmp[nTabela][OBSERVACAO] := 'Rotina executada com sucesso.'
				Else
					aTabLmp[nTabela][STATUS] := FALHA
					aTabLmp[nTabela][OBSERVACAO] := 'Erros encontrados na execução da rotina.'
				EndIf
				If !lAuto
					oBrwProc:Refresh()
				EndIf
			EndIf

		Next nTabela
		PlsLogFil(CENDTHRL("I") + " Fim da Limpeza.", ARQ_LOG_CARGA)
		// Se rotinas já foram processadas e continuam solicitando execução, avisa na tela.
		If Len(aRotProc) > 0
			cMsg := "Rotina(s) : "  + CHR(13)
			For nTabela := 1 to Len(aRotProc)
				cMsg += aTabLmp[nTabela][DESCTABELA] + CHR(13)
			Next
			cMsg += " já processada(s). "
			MsgAlert( cMsg, "SIP" )
		EndIf
		If !lAuto
			oBrwProc:Refresh()
		EndIf
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaTabelas

Rotina criada para retornar a lista de Tabelas para o browse

@author everton.mateus
@since 15/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaTabelas()
	Local aTabelas	:= {}

	aAdd(aTabelas,{.T.,"0","B3Q","Tabela B3Q - Temporaria de Eventos X Despesas","LimpaTabela('B3Q')","Aguardando processamento..."})
	aAdd(aTabelas,{.T.,"0","B3M","Tabela B3M - SIP XML","LimpaTabela('B3M')","Aguardando processamento..."})
	aAdd(aTabelas,{.T.,"0","B3F","Tabela B3F - Criticas da Central de Obrigacoes","LimpaTabela('B3F')","Aguardando processamento..."})
	aAdd(aTabelas,{.T.,"0","B3L","Tabela B3L - Eventos X Despesas","LimpaTabela('B3L')","Aguardando processamento..."})
	aAdd(aTabelas,{.T.,"0","BD7","Tabela BD7 - Part Honorarios Prestadores Itens","LimpaTabela('BD7')","Aguardando processamento..."})
	aAdd(aTabelas,{.T.,"0","B3O","Tabela B3O - Beneficiários Expostos","LimpaTabela('B3O')","Aguardando processamento..."})

Return aTabelas

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LimpaTabela
Funcao criada para limpar os dados processados pela central para a obrigacao

@param cTab		Tabela onde serao excluidos os registros
@param cMsg		Mensagem com o nome da tabela para a regua
@param cOpe		Codigo da operadora
@param cObri	Codigo da obrigacao
@param cComp	Codigo do compromisso

@author timoteo.bega
@since 17/07/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function LimpaTabela(cTab)
	Local cSql			:= ""
	Local cIntPad		:= PlsIntPad()
	Local  cTriRec		:= TriRec()
	Default cTab		:= ""

	Do Case
		Case cTab == "B3L"
			cSql := "DELETE FROM " + RetSqlName(cTab) + " WHERE "
			cSql += " B3L_FILIAL='" + xFilial(cTab) + "' "
			cSql += " AND B3L_CODOPE='" + B3D->B3D_CODOPE + "' "
			cSql += " AND B3L_CODOBR='" + B3D->B3D_CDOBRI + "' "
			cSql += " AND B3L_ANOCMP='" + B3D->B3D_ANO + "' "
			cSql += " AND B3L_CDCOMP='" + B3D->B3D_CODIGO + "' "
			cSql += " AND D_E_L_E_T_=' ' "
		Case cTab == "B3F"
			cSql := "DELETE FROM " + RetSqlName(cTab) + " WHERE "
			cSql += " B3F_FILIAL='" + xFilial(cTab) + "' "
			cSql += " AND B3F_CODOPE='" + B3D->B3D_CODOPE + "' "
			cSql += " AND B3F_CDOBRI='" + B3D->B3D_CDOBRI + "' "
			cSql += " AND B3F_ANO='" + B3D->B3D_ANO + "' "
			cSql += " AND B3F_CDCOMP='" + B3D->B3D_CODIGO + "' "
			cSql += " AND B3F_ORICRI='B3L' "
			cSql += " AND D_E_L_E_T_=' ' "
		Case cTab == "B3Q"
			cSql := " DELETE FROM " + RetSqlName(cTab) + " WHERE "
			cSql += " B3Q_FILIAL='" + xFilial(cTab) + "' "
			cSql += " AND B3Q_CODOPE='" + B3D->B3D_CODOPE + "' "
			cSql += " AND B3Q_CODOBR='" + B3D->B3D_CDOBRI + "' "
			cSql += " AND B3Q_ANOCMP='" + B3D->B3D_ANO + "' "
			cSql += " AND B3Q_CDCOMP='" + B3D->B3D_CODIGO + "' "
			//cSql += " AND B3Q_EVEDES IN ('0001000200442580000000341','0001000200442580000000351') "
			cSql += " AND D_E_L_E_T_=' ' "
		Case cTab == "B3O"
			cSql := "DELETE FROM " + RetSqlName(cTab) + " WHERE B3O_FILIAL='" + xFilial(cTab) + "' "
			cSql += " AND B3O_CODOPE='" + B3D->B3D_CODOPE + "' "
			cSql += " AND B3O_CDOBRI='" + B3D->B3D_CDOBRI + "' "
			cSql += " AND B3O_ANO='" + B3D->B3D_ANO + "' "
			cSql += " AND B3O_CDCOMP='" + B3D->B3D_CODIGO + "' "
			cSql += " AND D_E_L_E_T_=' ' "
		Case cTab == "B3M" .And. !Empty(cTriRec)
			cSql := "DELETE FROM " + RetSqlName(cTab) + " WHERE B3M_FILIAL='" + xFilial(cTab) + "' "
			cSql += " AND B3M_CODOPE='" + B3D->B3D_CODOPE + "' "
			cSql += " AND B3M_TRIREC='" + cTriRec + "' "
			cSql += " AND D_E_L_E_T_=' ' "
		Case cTab == "BD7" .And. !Empty(cTriRec)
			cSql := "UPDATE "+ RetSqlName(cTab) +" SET BD7_RECSIP=' ' "
			cSql += " WHERE "
			cSql += " BD7_FILIAL='" + xFilial(cTab) + "' "
			cSql += " AND BD7_CODOPE='" + cIntPad + "' "
			cSql += " AND BD7_RECSIP='" + cTriRec + "' "
			//cSql += " AND BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV IN('0001000200442580000000341','0001000200442580000000351') "
			cSql += " AND D_E_L_E_T_=' ' "
	EndCase

	PlsLogFil(CENDTHRL("I") + " Limpando Tabela [" + cTab + "] " + Iif( Empty(cTriRec), "", "Trimestre [" + cTriRec + "]: " ) + cSql, ARQ_LOG_CARGA)
	nRet := TCSQLEXEC(cSql)
	If nRet >= 0
		TcSQLExec("COMMIT")
	Else
		PlsLogFil(CENDTHRL("E") + "Nao conseguiu efetuar a limpeza. Codigo de retorno " + AllTrim(Str(nRet)) + ": " + TCSQLError() , ARQ_LOG_CARGA)
	EndIf
	PlsLogFil(CENDTHRL("I") + " Fim da limpeza da tabela [" + cTab + "] " + Iif( Empty(cTriRec), "", "Trimestre [" + cTriRec + "]: " ), ARQ_LOG_CARGA)

Return nRet >= 0

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TriRec

Funcao criada para retornar o trimestre de reconhecimento da despesa no formato 99

@author timoteo.bega
@since 05/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function TriRec()
	Local cTriRec := ""

	cTriRec := Subs(B3D->B3D_REFERE,1,1)
	cTriRec := AllTrim(cTriRec)
	cTriRec := StrZero(Val(cTriRec),2)
	cTriRec := B3D->B3D_ANO + cTriRec

Return cTriRec


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} controlProc

Função faz o controle de execução por semaforo para os Tabelas em execução

@author Henrique Brugugnoli
@since 15/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function controlProc( cProc )
	Local lLocked	:= .F.
	Local lRet	:= .F.
	Local cLock	:= cProc + ".lck"

	lLocked := LockByName(cLock, .T., .T.)

	cProc := allTrim(cProc)

	lRet	:= &cProc

	UnlockByName(cLock, .T., .T.)

Return lRet