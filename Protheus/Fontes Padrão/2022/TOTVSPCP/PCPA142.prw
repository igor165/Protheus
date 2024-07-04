#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA142.CH"

#DEFINE ARRAY_POS_MARK_IMG   1
#DEFINE ARRAY_POS_API_TXT    2
#DEFINE ARRAY_POS_STATUS_TXT 3
#DEFINE ARRAY_POS_IDREG      4
#DEFINE ARRAY_POS_DTENV      5
#DEFINE ARRAY_POS_HRENV      6
#DEFINE ARRAY_POS_PROG       7
#DEFINE ARRAY_POS_DTREP      8
#DEFINE ARRAY_POS_HRREP      9
#DEFINE ARRAY_POS_MSGRET     10
#DEFINE ARRAY_POS_STATUS_ID  11
#DEFINE ARRAY_POS_API_ID     12
#DEFINE ARRAY_POS_MARK_ID    13
#DEFINE ARRAY_POS_RECNO      14
#DEFINE ARRAY_POS_MSGENV     15
#DEFINE ARRAY_POS_TIPO       16
#DEFINE ARRAY_SIZE           16

#DEFINE IN_STATUS_PENDENTE   "'1','2','4'"
#DEFINE IN_STATUS_SCHEDULE   "'3'"

#DEFINE TAMANHO_ITEM_TREE   150

/*/{Protheus.doc} PCPA142
Programa para consultar as pendências de integração do MRP.

@type  Function
@author lucas.franca
@since 27/06/2019
@version P12.1.27
/*/
Function PCPA142()
	Local aTabsFil   := {}
	Local aTamanhos  := {}
	Local aCoors     := FWGetDialogSize( oMainWnd )
	Local nAltura    := 0
	Local nLargura   := aCoors[4]
	Local nHeight    := aCoors[3]-15
	Local nX         := 0
	Local oDialog    := Nil
	Local oCheckAll  := Nil
	Local oPanelSup  := Nil
	Local oPanelInf  := Nil
	Local oPanelEsq  := Nil
	Local oPanelDir  := Nil
	Local oPnlGrid   := Nil
	Local oPnlMemos  := Nil

	Local oFont      := TFont():New("Arial", , -12, , .F.)

	Private aFiltEsp   := {}
	Private aDados     := {}
	Private aColunas   := {}
	Private aAllReg	   := {}
	Private aChecks	   := {}
	Private cMsgRet    := ""
	Private lChange    := .F.
	Private lCBAllGrid := .T.
	Private nRecnoMemo := 0
	Private oMsgRet    := Nil
	Private oMsgEnv    := Nil
	Private oList      := Nil
	Private oTabsFil   := JsonObject():New()
	Private oJsonDesc  := JsonObject():New()
	Default lAutoMacao := .F.

	If GetRpoRelease() < "12.1.025"
		HELP(' ',1,"Release" ,,STR0069,2,0,,,,,,) //"Rotina disponível a partir do release 12.1.25."
		Return
	EndIf

	//Se a tabela T4R não estiver em modo compartilhado, não permite abertura da tela
	If !FWModeAccess("T4R",1) == "C" .Or. !FWModeAccess("T4R",2) == "C" .Or. !FWModeAccess("T4R",3) == "C"
		HELP(' ', 1, "Help",, STR0055,; //"A rotina não pode ser inciada pois tabela T4R (pendências do MRP) está com modo de compartilhamento incorreto)."
		     2, 0, , , , , , {STR0056}) //"Altere o modo de compartilhamento da tabela T4R para 'Compartilhado'."
		Return
	Else
		//Se a integração não estiver habilitada, não permite utilizar a tela de sincronização.
		If !IntNewMRP("MRPDEMANDS")
			HELP(' ', 1, "Help",, STR0041,; //"Integração com o MRP não está habilitada."
				2, 0, , , , , , {STR0042}) //"Ative a integração com o MRP para utilizar o programa de Sincronização."
			Return
		EndIf
	EndIf

	/*
		Lista de opções que aparecerão para consulta.
		Estrutura:
		oTabsFil(JsonObject)
		oTabsFil["CODIGO_API"] == ARRAY
		oTabsFil["CODIGO_API"][1] == Descrição para apresentar em tela.
		oTabsFil["CODIGO_API"][2] == Função utilizada no reprocessamento, para operação de inclusão/alteração
		oTabsFil["CODIGO_API"][3] == Função utilizada no reprocessamento, para operação de exclusão
		oTabsFil["CODIGO_API"][4] == Função utilizada no reprocessamento, para operação de atualização
		oTabsFil["CODIGO_API"][5] == Ordem de criação do checkbox de filtros
		oTabsFil["CODIGO_API"][6] == Função da API que retorna os MapFields
	*/

	oTabsFil["MRPBILLOFMATERIAL"   ] := {P139GetAPI("MRPBILLOFMATERIAL"   ), "P200Reproc", "P200Reproc", Nil         ,  1, "MrpBOMMap()"} //"Estruturas"
	oTabsFil["MRPPRODUCTIONVERSION"] := {P139GetAPI("MRPPRODUCTIONVERSION"), "MrpVPPost" , "MrpVPDel"  , Nil         ,  2, "MrpVPMap()" } //"Versão da Produção"

	If FWAliasInDic( "HW9", .F. )
		oTabsFil["MRPBOMROUTING"       ] := {P139GetAPI("MRPBOMROUTING"       ), "MrpBROPost", "MrpBRODel" , Nil         ,  3, "MrpBROMap()"} //"Operações por Componente"
	EndIf

	oTabsFil["MRPCALENDAR"         ] := {P139GetAPI("MRPCALENDAR"         ), "MrpCAPost" , "MrpCADel"  , Nil         ,  4, "MrpCAMap()" } //"Calendário MRP"
	oTabsFil["MRPDEMANDS"          ] := {P139GetAPI("MRPDEMANDS"          ), "MrpDemPost", "MrpDemDel" , Nil         ,  5, "MrpDemMap()"} //"Demandas"
	oTabsFil["MRPPRODUCTIONORDERS" ] := {P139GetAPI("MRPPRODUCTIONORDERS" ), "MrpOrdPost", "MrpOrdDel" , "PCPA141OP" ,  6, "MrpOrdMap()"} //"Ordem de Produção"
	oTabsFil["MRPALLOCATIONS"      ] := {P139GetAPI("MRPALLOCATIONS"      ), "MrpEmpPost", "MrpEmpDel" , "PCPA141EMP",  7, "MrpEmpMap()"} //"Empenho MRP"
	oTabsFil["MRPPURCHASEORDER"    ] := {P139GetAPI("MRPPURCHASEORDER"    ), "MrpSCPost" , "MrpSCDel"  , "PCPA141SCO",  8, "MrpSCMap()" } //"Solicitação de Compra"
	oTabsFil["MRPPURCHASEREQUEST"  ] := {P139GetAPI("MRPPURCHASEREQUEST"  ), "MrpPCPost" , "MrpPCDel"  , "PCPA141OCO",  9, "MrpPCMap()" } //"Pedido de Compra"
	oTabsFil["MRPSTOCKBALANCE"     ] := {P139GetAPI("MRPSTOCKBALANCE"     ), "MrpSBPost" , "MrpSBDel"  , "PCPA141EST", 10, "MrpSBMap()" } //"Saldo em estoque"
	oTabsFil["MRPPRODUCT"          ] := {P139GetAPI("MRPPRODUCT"          ), "MrpPrdPost", "MrpPrdDel" , Nil         , 13, "MrpPrdMap()"} //"Produtos"
	oTabsFil["MRPPRODUCTINDICATOR" ] := {P139GetAPI("MRPPRODUCTINDICATOR" ), "MrpIprPost", "MrpIPrDel" , Nil         , 14, "MrpIPrMap()"} //"Indicadores de Produtos"

	If FWAliasInDic( "HWX", .F. )
		oTabsFil["MRPREJECTEDINVENTORY"] := {P139GetAPI("MRPREJECTEDINVENTORY"), "MrpRIPost" , "MrpRIDel"  , "PCPA141CQ" , 15, "MrpRIMap()" } //"CQ"
	EndIf

	If FWAliasInDic( "HWY", .F. )
		oTabsFil["MRPWAREHOUSE"] := {P139GetAPI("MRPWAREHOUSE"), "MrpWPost" , "MrpWDel"  , "PCPA141AMZ" , 16, "MrpWMap()" } //"Armazéns"
	EndIf

	IF !lAutoMacao
		//Define a janela da tela
		oDialog := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],STR0002,,,,nOr(WS_VISIBLE,WS_POPUP),,CLR_WHITE,,,.T.,,,,,,.T.) //"Pendências de integração do MRP"
		//Não fecha com ESC
		oDialog:lEscClose := .F.

		//Definição dos paineis utilizados na estruturação dos componentes em tela.
		//Painel superior, com filtros e dados.
		oPanelSup := TPanel():New(0,0,,oDialog,,,,,, nLargura/2, (nHeight/2), .F., .T.)
		oPanelSup:Align := CONTROL_ALIGN_TOP
		//Painel Lateral esquerdo
		oPanelEsq  := TPanel():New(0,0,,oPanelSup,,,,,, 110, oPanelSup:nHeight, .F.,.T.)
		//Painel da direita, com os dados.
		oPanelDir  := TPanel():New(0,110,,oPanelSup,,,,,,(oPanelSup:nWidth/2)-110, (oPanelSup:nHeight/2), .F.,.T.)
		//Painel para a GRID
		oPnlGrid   := TPanel():New(0,0,,oPanelDir,,,,,,(oPanelDir:nWidth/2), (oPanelDir:nHeight/2)*0.7, .F.,.F. )
		//Painel para a mensagem do erro
		oPnlMemos  := TPanel():New((oPanelDir:nHeight/2)*0.7,0,,oPanelDir,,,,,,(oPanelDir:nWidth/2), (oPanelDir:nHeight/2)*0.3, .F.,.F. )
		//Painel Inferior
		oPanelInf  := TPanel():New((nHeight/2),0,,oDialog,,,,,, (nLargura/2), 20, .T.,.F.)
		oPanelInf:Align := CONTROL_ALIGN_BOTTOM

		//Define os CHECKBOX de filtro, no lado esquerdo da tela

		//Checkbox para marcar/desmarcar todos os filtros
		@ 05, 05 CHECKBOX oCheckAll VAR lChange PROMPT STR0003 WHEN PIXEL OF oPanelEsq SIZE 100,015 MESSAGE "" //"Marca/Desmarca todos"
		oCheckAll:bChange := {|| ChangCheck(lChange)}
	ENDIF

	//Adiciona os CHECKBOX, de acordo com o que foi definido no oTabsFil
	aTabsFil := oTabsFil:GetNames()
	aTabsFil := aSort(aTabsFil,,,{|x,y| oTabsFil[x][5] < oTabsFil[y][5]})
	nAltura  := 20
	For nX := 1 To Len(aTabsFil)
		IF !lAutoMacao
			aAdd(aChecks , PCPA110C():New(oPanelEsq, aTabsFil[nX], oTabsFil[aTabsFil[nX]][1], nAltura, 05, {||FiltraInfo()}))
			aAdd(aFiltEsp, PCPA142Fil():New(oPanelEsq, aTabsFil[nX], oTabsFil[aTabsFil[nX]][1], nAltura, 92, {||FiltraInfo()}))
		ENDIF
		nAltura += 15
	Next nX

	//Monta o componente da GRID
	aAdd(aColunas ," ")
	aAdd(aTamanhos, 10)
	aAdd(aColunas ,STR0004)//"Transação"
	aAdd(aTamanhos, 70)
	aAdd(aColunas ,STR0005)//"Status"
	aAdd(aTamanhos, 60)
	aAdd(aColunas ,STR0006)//"Identificador"
	aAdd(aTamanhos, 150)
	aAdd(aColunas ,STR0007)//"Data Envio"
	aAdd(aTamanhos, 40)
	aAdd(aColunas ,STR0008)//"Hora Envio"
	aAdd(aTamanhos, 40)
	aAdd(aColunas ,STR0009)//"Programa"
	aAdd(aTamanhos, 40)
	aAdd(aColunas ,STR0010)//"Data Reprocessamento"
	aAdd(aTamanhos, 70)
	aAdd(aColunas ,STR0011)//"Hora Reprocessamento"
	aAdd(aTamanhos, 70)
	aAdd(aColunas ,STR0043)//"Tipo"
	aAdd(aTamanhos, 70)

	IF !lAutoMacao
		oList := TWBrowse():New(0, 0, 500, 500,,aColunas,aTamanhos,oPnlGrid,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oList:Align := CONTROL_ALIGN_ALLCLIENT

		//Inicializa o array de dados.
		initDados()

		oList:SetArray(aDados)
		oList:bLine        := {|| bLineData(oList:nAt,Len(aColunas)) }
		oList:bChange      := {|| AlteraMemo(oList:nAt)}
		oList:bLDblClick   := {|| TrocaCheck(oList:nAt)}
		oList:bHeaderClick := {|oBrw,nCol| IIf(nCol == 1, MarcaTodos(oBrw), Nil)}

		//Monta o componente para exibição dos dados trafegados
		oMsgEnv := DbTree():New(13, 0, oPnlMemos:nHeight/2, (oPnlMemos:nWidth/4)-2, oPnlMemos, {|| }, , .F., , oFont, PadR(STR0067,60) + ";" + PadR(STR0068,80)) //"Campo";"Valor"
		oMsgEnv:SetScroll(1,.T.) // Habilita a barra de rolagem horizontal
		oMsgEnv:SetScroll(2,.T.) // Habilita a barra de rolagem vertical
		TSay():New(5, 1, {|| STR0059 }, oPnlMemos, , , , , , .T., , , 100, 20) //"Dados Enviados:"

		//Monta o componente para exibição da mensagem de retorno
		oMsgRet := tMultiget():new(13, (oPnlMemos:nWidth/4)+2, {|u| If(PCount()==0,cMsgRet,cMsgRet:=u)}, oPnlMemos, (oPnlMemos:nWidth/4)-2, (oPnlMemos:nHeight/2)-13,,,,,,.T.,,,{||.T.},,,.T.)
		TSay():New(5, (oPnlMemos:nWidth/4)+3, {|| STR0060 }, oPnlMemos, , , , , , .T., , , 100, 20) //"Mensagem:"

		//Monta os botões de ação, na parte inferior da tela
		@ 05,(nLargura/2)-195 BUTTON oBtn PROMPT STR0012 SIZE 60,12 WHEN (.T.) ACTION (buscaDados(),FiltraInfo(),AlteraMemo(oList:nAt,.T.)) OF oPanelInf PIXEL //"Atualizar"
		@ 05,(nLargura/2)-130 BUTTON oBtn PROMPT STR0013 SIZE 60,12 WHEN (.T.) ACTION (Reprocessa(),AlteraMemo(oList:nAt,.T.)) OF oPanelInf PIXEL //"Reprocessar"
		@ 05,(nLargura/2)-65  BUTTON oBtn PROMPT STR0014 SIZE 60,12 WHEN (.T.) ACTION (oDialog:End()) OF oPanelInf PIXEL //"Sair"

		//Abre a tela
		oDialog:Activate(,,,.T.,,,{|| oList:Refresh(),AlteraMemo(oList:nAt)} )
	ENDIF
Return Nil

/*/{Protheus.doc} initDados
Verifica se é necessário adicionar um registro em branco no array aDados

@type  Static Function
@author lucas.franca
@since 27/06/2019
@version P12.1.27
/*/
Static Function initDados()
	Local nIndex := 0

	If Len(aDados) == 0
		aAdd(aDados,Array(ARRAY_SIZE))

		For nIndex := 1 To ARRAY_SIZE
			If nIndex == ARRAY_POS_MARK_IMG
				aDados[1][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), "LBOK" )
			ElseIf nIndex == ARRAY_POS_DTENV .Or. nIndex == ARRAY_POS_DTREP
				aDados[1][nIndex] := SToD(" ")
			ElseIf nIndex == ARRAY_POS_RECNO
				aDados[1][nIndex] := 0
			Else
				aDados[1][nIndex] := ""
			EndIf
		Next nIndex
		aDados[1][ARRAY_POS_MARK_ID] := .T.
	EndIf
Return

/*/{Protheus.doc} bLineData
Monta linha de dados para o objeto TWBrowse

@type  Static Function
@author lucas.franca
@since 27/06/2019
@version P12.1.27
@param nAt     , Numeric, Linha posicionada na grid
@param nColunas, Numeric, Total de colunas da grid
@return aRet   , Array  , Array com os dados para exibição.
/*/
Static Function bLineData(nAt,nColunas)
	Local aRet   := {}
	Local nIndex := 0

	For nIndex := 1 To nColunas
		If nIndex != 10
			aAdd(aRet,aDados[nAt][nIndex])
		Else
			If aDados[nAt][ARRAY_POS_TIPO] == '1'
				aAdd(aRet,STR0044) //"Inclusão"
			ElseIf aDados[nAt][ARRAY_POS_TIPO] == '2'
				aAdd(aRet,STR0045) //"Exclusão"
			ElseIf aDados[nAt][ARRAY_POS_TIPO] == '3'
				aAdd(aRet,STR0054) //"Atualização"
			Else
				aAdd(aRet," ")
			EndIf
		EndIf
	Next nIndex
Return aRet

/*/{Protheus.doc} MarcaTodos
Marca/Desmarca todos os registros da grid.

@type  Static Function
@author lucas.franca
@since 28/06/2019
@version P12.1.27
@param oBrw, Object, Objeto da GRID exibida em tela
/*/
Static Function MarcaTodos(oBrw)
	Local cImg   := Iif(lCBAllGrid,"LBOK","LBNO")
	Local nIndex := 0
	Local nTotal := 0
	Default lAutoMacao := .F.

	nTotal := Len(aDados)
	For nIndex := 1 To nTotal
		If aDados[nIndex][ARRAY_POS_STATUS_ID] != "3" //Registros aguardando schedule não podem ser marcados.
			aDados[nIndex][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), cImg )
			aDados[nIndex][ARRAY_POS_MARK_ID ] := lCBAllGrid
		EndIf
	Next nIndex

	nTotal := Len(aAllReg)
	For nIndex := 1 To nTotal
		If aAllReg[nIndex][ARRAY_POS_STATUS_ID] != "3" //Registros aguardando schedule não podem ser marcados.
			aAllReg[nIndex][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), cImg )
			aAllReg[nIndex][ARRAY_POS_MARK_ID ] := lCBAllGrid
		EndIf
	Next

	lCBAllGrid := !lCBAllGrid

	IF !lAutoMacao
		oBrw:Refresh()
	ENDIF
Return Nil

/*/{Protheus.doc} AlteraMemo
Atualiza o conteúdo do campo memo em tela

@type  Static Function
@author lucas.franca
@since 28/06/2019
@version P12.1.27
@param 01 nAt    , Numeric, Linha posicionada da grid
@param 02 lReload, Logical, Indica se deve forçar o recarregamento do Memo
/*/
Static Function AlteraMemo(nAt, lReload)

	Default lReload    := .F.
	Default lAutoMacao := .F.

	//Se não tem registro selecionado, limpa os campos
	If Empty(aDados[nAt][ARRAY_POS_API_ID])
		nRecnoMemo := 0
		cMsgRet    := ""
		IF !lAutoMacao
			SetFocus(oMsgRet:HWND)
			oMsgEnv:Reset()
		ENDIF
	Else
		//Só atualiza se mudar o registro selecionado
		If nRecnoMemo <> aDados[nAt][ARRAY_POS_RECNO] .Or. lReload
			nRecnoMemo := aDados[nAt][ARRAY_POS_RECNO]
			cMsgRet    := aDados[nAt][ARRAY_POS_MSGRET]
			SetFocus(oMsgRet:HWND)
			TrataJson(nAt)
		EndIf
	EndIf

	IF !lAutoMacao
		SetFocus(oMsgEnv:HWND)
		SetFocus(oList:HWND)
	ENDIF
Return Nil

/*/{Protheus.doc} TrocaCheck
Inverte a seleção do checkbox em um registro da grid

@type  Static Function
@author lucas.franca
@since 28/06/2019
@version P12.1.27
@param nAt, Numeric, Linha posicionada da grid
/*/
Static Function TrocaCheck(nAt)
	Local nIndex := 0
	Local nTotal := 0

	//Inverte o valor do check
	If aDados[nAt][ARRAY_POS_STATUS_ID] == "3"
		HELP(' ', 1, "Help",, STR0046,; //"Registros que estão com o status 'Aguardando schedule' não podem ser marcados para reprocessar."
		     2, 0, , , , , , {STR0047}) //"Aguarde o processamento da rotina de Schedule para o envio deste registro."
	Else
		aDados[nAt][ARRAY_POS_MARK_ID] := !aDados[nAt][ARRAY_POS_MARK_ID]

		If aDados[nAt][ARRAY_POS_MARK_ID]
			aDados[nAt][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), "LBOK" )
		Else
			aDados[nAt][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), "LBNO" )
		EndIf

		nTotal := Len(aAllReg)
		For nIndex := 1 To nTotal
			If aAllReg[nIndex][ARRAY_POS_RECNO] == aDados[nAt][ARRAY_POS_RECNO]

				//Inverte o valor do check
				aAllReg[nIndex][ARRAY_POS_MARK_ID] := aDados[nAt][ARRAY_POS_MARK_ID]

				If aDados[nAt][ARRAY_POS_MARK_ID]
					aAllReg[nIndex][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), "LBOK" )
				Else
					aAllReg[nIndex][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), "LBNO" )
				EndIf
				Exit
			EndIf
		Next
	EndIf
Return Nil

/*/{Protheus.doc} ChangCheck
Inverte a seleção do checkbox para filtro dos dados

@type  Static Function
@author lucas.franca
@since 28/06/2019
@version P12.1.27
@param lTipo, Logic, Identifica se os checkbox de filtro devem ser marcados ou desmarcados.
/*/
Static Function ChangCheck(lTipo)
	Local nIndex := 0

	For nIndex := 1 To Len(aChecks)
		aChecks[nIndex]:lValue := lTipo
	Next nIndex

	FiltraInfo()
Return .T.

/*/{Protheus.doc} buscaDados
Dispara a consulta dos dados no banco.

@type  Static Function
@author lucas.franca
@since 28/06/2019
@version P12.1.27
/*/
Static Function buscaDados()
	Processa( {|| consultar() }, STR0015, STR0016,.F.) //"Aguarde..." # "Executando consulta..."
Return .T.

/*/{Protheus.doc} consultar
Consulta dos dados no banco.

@type  Static Function
@author lucas.franca
@since 28/06/2019
@version P12.1.27
/*/
Static Function consultar()
	Local cAliasTop := GetNextAlias()
	Local cAliasCnt := GetNextAlias()
	Local cQueryCnt := ""
	Local lPrimeiro := .T.
	Local nIndex    := 0
	Local nTotal    := 0
	Local cFiltro   := ""
	Default lAutoMacao := .F.

	aSize(aAllReg,0)
	aSize(aDados ,0)

	For nIndex := 1 To Len(aChecks)
		If aChecks[nIndex]:lValue
			If lPrimeiro
				cFiltro := "(("
				lPrimeiro := .F.
			Else
				cFiltro += " OR ("
			EndIf

			cFiltro += " T4R.T4R_API = '" + aChecks[nIndex]:cId + "'"
			If !Empty(aFiltEsp[nIndex]:dDtAte)
				cFiltro += " AND T4R.T4R_DTENV <= '" + DtoS(aFiltEsp[nIndex]:dDtAte) + "' "
			EndIf
			If !Empty(aFiltEsp[nIndex]:dDtDe)
				cFiltro += " AND T4R.T4R_DTENV >= '" + DtoS(aFiltEsp[nIndex]:dDtDe) + "' "
			EndIf
			If !Empty(aFiltEsp[nIndex]:cProg)
				cFiltro += " AND T4R.T4R_PROG = '" + aFiltEsp[nIndex]:cProg + "' "
			EndIf

			cFiltro += " AND T4R.T4R_STATUS IN(''"

			If aFiltEsp[nIndex]:lPendente
				cFiltro += "," + IN_STATUS_PENDENTE
			EndIf
			If aFiltEsp[nIndex]:lSchedule
				cFiltro += "," + IN_STATUS_SCHEDULE
			EndIf
			cFiltro += ")" //Fecha o comando IN de filtro do T4R_STATUS

			cFiltro += ")"
		EndIf
	Next nI
	If !Empty(cFiltro)
		cFiltro := cFiltro + ") "
	Else
		cFiltro := " 1 = 1 "
	EndIf

	cQueryCnt := "SELECT COUNT(*) TOTAL "
	cQueryCnt +=  " FROM (SELECT 1 TOTAL "
	cQueryCnt +=          " FROM " + RetSqlName("T4R") + " T4R "
	cQueryCnt +=         " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
	cQueryCnt +=           " AND T4R.D_E_L_E_T_ = ' ' "
	cQueryCnt +=           " AND " + cFiltro + " ) T"


	cFiltro +=  " ORDER BY T4R.T4R_FILIAL ASC, "
	cFiltro +=     " (CASE T4R.T4R_DTREP WHEN '' THEN T4R.T4R_DTENV ELSE T4R.T4R_DTREP END) DESC, "
	cFiltro +=     " (CASE T4R.T4R_HRREP WHEN '' THEN T4R.T4R_HRENV ELSE T4R.T4R_HRREP END) DESC, "
	cFiltro +=     " T4R.T4R_API ASC "

	cFiltro := "% " + cFiltro + " %"

	BeginSql Alias cAliasTop
		%noparser%
		column T4R_DTENV as Date
		column T4R_DTREP as Date
		SELECT T4R.T4R_API,
		       T4R.T4R_STATUS,
		       T4R.T4R_IDREG,
		       T4R.T4R_DTENV,
		       T4R.T4R_HRENV,
		       T4R.T4R_PROG,
		       T4R.T4R_MSGRET,
		       T4R.T4R_DTREP,
		       T4R.T4R_HRREP,
		       T4R.R_E_C_N_O_,
			   T4R.T4R_TIPO,
		       T4R.T4R_MSGENV //Campo MEMO sempre deve ser o último da query.
		  FROM %table:T4R% T4R
		 WHERE T4R.T4R_FILIAL = %xfilial:T4R%
		   AND T4R.%notDel%
		   AND %Exp:cFiltro%
	EndSql

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCnt),cAliasCnt,.T.,.T.)
	nTotal := (cAliasCnt)->(TOTAL)
	(cAliasCnt)->(dbCloseArea())

	ProcRegua(nTotal)

	While !(cAliasTop)->(Eof())
		IncProc()

		aAdd(aDados,Array(ARRAY_SIZE))

		nTotal := Len(aDados)

		aDados[nTotal][ARRAY_POS_IDREG    ] := AllTrim((cAliasTop)->T4R_IDREG)
		aDados[nTotal][ARRAY_POS_DTENV    ] := (cAliasTop)->T4R_DTENV
		aDados[nTotal][ARRAY_POS_HRENV    ] := (cAliasTop)->T4R_HRENV
		aDados[nTotal][ARRAY_POS_PROG     ] := AllTrim((cAliasTop)->T4R_PROG)
		aDados[nTotal][ARRAY_POS_DTREP    ] := (cAliasTop)->T4R_DTREP
		aDados[nTotal][ARRAY_POS_HRREP    ] := (cAliasTop)->T4R_HRREP
		aDados[nTotal][ARRAY_POS_MSGRET   ] := AllTrim((cAliasTop)->T4R_MSGRET)
		aDados[nTotal][ARRAY_POS_STATUS_ID] := (cAliasTop)->T4R_STATUS
		aDados[nTotal][ARRAY_POS_API_ID   ] := AllTrim((cAliasTop)->T4R_API)
		aDados[nTotal][ARRAY_POS_RECNO    ] := (cAliasTop)->R_E_C_N_O_
		aDados[nTotal][ARRAY_POS_MSGENV   ] := (cAliasTop)->T4R_MSGENV
		aDados[nTotal][ARRAY_POS_TIPO     ] := (cAliasTop)->T4R_TIPO

		If aDados[nTotal][ARRAY_POS_STATUS_ID] == "3"
			aDados[nTotal][ARRAY_POS_MARK_IMG ] := LoadBitmap( GetResources(), "LBNO" )
			aDados[nTotal][ARRAY_POS_MARK_ID  ] := .F.
		Else
			aDados[nTotal][ARRAY_POS_MARK_IMG ] := LoadBitmap( GetResources(), "LBOK" )
			aDados[nTotal][ARRAY_POS_MARK_ID  ] := .T.
		EndIf

		If aDados[nTotal][ARRAY_POS_STATUS_ID] == "1"
			aDados[nTotal][ARRAY_POS_STATUS_TXT] := STR0017 //"Pendente"
		ElseIf aDados[nTotal][ARRAY_POS_STATUS_ID] == "2"
			aDados[nTotal][ARRAY_POS_STATUS_TXT] := STR0018 //"Reprocessado com erro"
		ElseIf aDados[nTotal][ARRAY_POS_STATUS_ID] == "3"
			aDados[nTotal][ARRAY_POS_STATUS_TXT] := STR0048 //"Aguardando schedule"
		ElseIf aDados[nTotal][ARRAY_POS_STATUS_ID] == "4"
			aDados[nTotal][ARRAY_POS_STATUS_TXT] := STR0070 //"Pendente schedule"
		Else
			aDados[nTotal][ARRAY_POS_STATUS_TXT] := ""
		EndIf

		IF !lAutoMacao
			If oTabsFil[aDados[nTotal][ARRAY_POS_API_ID]] != Nil
				aDados[nTotal][ARRAY_POS_API_TXT] := oTabsFil[aDados[nTotal][ARRAY_POS_API_ID]][1]
			Else
				aDados[nTotal][ARRAY_POS_API_TXT] := (cAliasTop)->T4R_API
			EndIf
		ENDIF
		(cAliasTop)->(dbSkip())
	End

	aAllReg := aClone(aDados)

	(cAliasTop)->(dbCloseArea())

	initDados()

	lCBAllGrid := .T.
	IF !lAutoMacao
		oList:nAt  := 1
		oList:Refresh()
		AlteraMemo(oList:nAt)
	ENDIF
Return

/*/{Protheus.doc} FiltraInfo
Filtra os dados nos arrays

@type  Static Function
@author lucas.franca
@since 28/06/2019
@version P12.1.27
/*/
Static Function FiltraInfo()
	Local aFiltros   := {}
	Local aFilEsp    := {}
	Local nIndRegs   := 0
	Local nIndFilt   := 0
	Local nCount     := 0
	Local oIndexFilt := JsonObject():New()
	Default lAutoMacao := .F.

	For nIndRegs := 1 To Len(aChecks)
		If aChecks[nIndRegs]:lValue
			aAdd(aFiltros,aChecks[nIndRegs]:cId)
			aAdd(aFilEsp,aFiltEsp[nIndRegs])
			nCount++
			oIndexFilt[AllTrim(aChecks[nIndRegs]:cId)] := nCount
		EndIf
	Next nIndRegs

	aSize(aDados,0)

	For nIndRegs := 1 To Len(aAllReg)

		nIndFilt := oIndexFilt[AllTrim(aAllReg[nIndRegs][ARRAY_POS_API_ID])]

		//Se a API não estiver no índice de filtros é pq não foi selecionada na consulta.
		If nIndFilt == Nil
			Loop
		EndIf

		//Verifica o filtro de PROGRAMA.
		If !Empty(aFilEsp[nIndFilt]:cProg) .And. !(AllTrim(aFilEsp[nIndFilt]:cProg) == aAllReg[nIndRegs][ARRAY_POS_PROG])
			Loop
		EndIf

		//Verifica o filtro de registros PENDENTES
		If !aFilEsp[nIndFilt]:lPendente .And. aAllReg[nIndRegs][ARRAY_POS_STATUS_ID] $ "|1|2|4"
			Loop
		EndIf

		//Verifica o filtro de registros AGUARDANDO SCHEDULE
		If !aFilEsp[nIndFilt]:lSchedule .And. aAllReg[nIndRegs][ARRAY_POS_STATUS_ID] == "3"
			Loop
		EndIf

		//Verifica filtro de DATAS. Se estiver dentro do filtro, adiciona o registro no array de tela.
		IF aFilEsp[nIndFilt]:dDtDe <= aAllReg[nIndRegs][ARRAY_POS_DTENV] .And. aFilEsp[nIndFilt]:dDtAte >= aAllReg[nIndRegs][ARRAY_POS_DTENV]
			aAdd(aDados,aClone(aAllReg[nIndRegs]))
		EndIf
	Next nIndRegs

	initDados()

	IF !lAutoMacao
		oList:Refresh()
		AlteraMemo(oList:nAt)
	ENDIF

	FreeObj(oIndexFilt)
	oIndexFilt := Nil

Return Nil

/*/{Protheus.doc} PCPA142Fil
Classe para montar tela de filtros

@type  Class
@author lucas.franca
@since 01/07/2019
@version P12.1.27
/*/
Class PCPA142Fil
	//Método construtor da classe
	Method New(oDlg,cId,cTitle,nPosAlt,nPosLar,bOk) Constructor

	//Propriedades
	Data bOk
	Data cId
	Data cTitle
	Data cProg
	Data cProgOld
	Data dDtDe
	Data dDtAte
	Data dDtDeOld
	Data dDtAteOld
	Data lSchedule
	Data lScheduleOld
	Data lPendente
	Data lPendenteOld
	Data oDlgFil

	//Métodos
	Method Dialog()
	Method Restaura()
EndClass

/*/{Protheus.doc} New
Método construtor da classe PCPA142Fil

@type  Method
@author lucas.franca
@since 01/07/2019
@version P12.1.27
@param oDlg   , Object   , Local onde o botão de filtro será criado.
@param cId    , Caracter , Código identificador do filtro.
@param cTitle , Caracter , Título da janela de filtro.
@param nPosAlt, Numeric  , Posição (Vertical) onde o botão de filtro será criado.
@param nPosLar, Numeric  , Posição (Horizontal) onde o botão de filtro será criado.
@param bOk    , CodeBlock, Bloco de código que será excecutado na confirmação do filtro.
/*/
Method New(oDlg,cId,cTitle,nPosAlt,nPosLar,bOk) Class PCPA142Fil
	Local oBtn
	Default lAutoMacao := .F.

	Self:bOk       := bOk
	Self:cId       := cId
	Self:cTitle    := cTitle
	Self:cProg     := Space(255)
	Self:dDtDe     := SToD("20000101")
	Self:dDtAte    := SToD("29990101")
	Self:lSchedule := .T.
	Self:lPendente := .T.

	IF !lAutoMacao
		@ nPosAlt-2,nPosLar BUTTON oBtn PROMPT "..."  SIZE 12,10 WHEN (.T.) ACTION (Self:Dialog()) OF oDlg PIXEL
	ENDIF

Return Self

/*/{Protheus.doc} Dialog
Construção da tela de filtros

@type  Method
@author lucas.franca
@since 01/07/2019
@version P12.1.27
/*/
Method Dialog() Class PCPA142Fil
	Local oBtn   := Nil
	Local oGroup := Nil
	Default lAutoMacao := .F.

	//Armazena os valores atuais para restaurar caso o usuário clique em cancelar
	Self:cProgOld     := Self:cProg
	Self:dDtDeOld     := Self:dDtDe
	Self:dDtAteOld    := Self:dDtAte
	Self:lScheduleOld := Self:lSchedule
	Self:lPendenteOld := Self:lPendente

	IF !lAutoMacao
		DEFINE DIALOG Self:oDlgFil TITLE Self:cTitle FROM 0,0 TO 190,429 PIXEL

		//Faixa data
		oGroup := TGroup():New(05, 09, 30, 204, STR0049, Self:oDlgFil,,, .T.) //"Datas"
		TGet():New(13, 13 , {|u| If(PCount()==0,Self:dDtDe,Self:dDtDe:=u  )}, oGroup, 60, 10, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,, "Self:dDtDe",,,,.T.,,, STR0019, 2) //"Envio de:"
		TGet():New(13, 110, {|u| If(PCount()==0,Self:dDtAte,Self:dDtAte:=u)}, oGroup, 60, 10, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"Self:dDtAte",,,,.T.,,, STR0020, 2) //"Envio até:"

		//Filtro de status
		oGroup := TGroup():New(32, 09, 53, 204, STR0005, Self:oDlgFil,,, .T.) //"Status"

		//Checkbox "Aguardando schedule"
		TCheckBox():New(42, 13, STR0048, {|| Self:lSchedule }, oGroup, 80,,, ; //"Aguardando schedule"
						{|| Self:lSchedule:=!Self:lSchedule},,,,,,, STR0050) //"Quando marcado, irá exibir os registros com status igual à 'Aguardando Schedule'."

		//Checkbox "Pendentes"
		TCheckBox():New(42, 100, STR0051, {|| Self:lPendente }, oGroup, 80,,, ; //"Pendentes"
						{|| Self:lPendente:=!Self:lPendente},,,,,,, STR0052) //"Quando marcado, irá exibir os registros com status igual à 'Pendente' e 'Reprocessado com erro'."

		//Programa
		TGet():New(58, 09, {|u| If(PCount()==0,Self:cProg,Self:cProg:=u)}, Self:oDlgFil, 171, 10,,, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"Self:cProg",,,,.T.,,, STR0021, 2) //"Programa:"

		//Botão Replicar
		@ 77, 009 BUTTON oBtn PROMPT STR0022 SIZE 61,15 WHEN (.T.) ACTION {||Replicar(Self),Eval(Self:bOk),Self:oDlgFil:End()} OF Self:oDlgFil PIXEL //"Replicar"
		//Botão Confirmar
		@ 77, 075 BUTTON oBtn PROMPT STR0023 SIZE 63,15 WHEN (.T.) ACTION {||Eval(Self:bOk),Self:oDlgFil:End()} OF Self:oDlgFil PIXEL //"Confirmar"
		//Botão Cancelar
		@ 77, 143 BUTTON oBtn PROMPT STR0024 SIZE 61,15 WHEN (.T.) ACTION {||Self:Restaura(),Self:oDlgFil:End()} OF Self:oDlgFil PIXEL //"Cancelar"

		ACTIVATE MSDIALOG Self:oDlgFil CENTERED
	ENDIF

Return Nil

/*/{Protheus.doc} Restaura
Restaura os valores da tela.

@type  Method
@author lucas.franca
@since 01/07/2019
@version P12.1.27
/*/
Method Restaura() Class PCPA142Fil
	Self:cProg     := Self:cProgOld
	Self:dDtDe     := Self:dDtDeOld
	Self:dDtAte    := Self:dDtAteOld
	Self:lSchedule := Self:lScheduleOld
	Self:lPendente := Self:lPendenteOld
Return

/*/{Protheus.doc} Replicar
Replica as informações para os demais filtros

@type  Static Function
@author lucas.franca
@since 01/07/2019
@version P12.1.27
@param oFiltro, Object, Objeto da tela de filtros
/*/
Static Function Replicar(oFiltro)
	Local nIndex := 0

	For nIndex := 1 To Len(aFiltEsp)
		aFiltEsp[nIndex]:dDtDe     := oFiltro:dDtDe
		aFiltEsp[nIndex]:dDtAte    := oFiltro:dDtAte
		aFiltEsp[nIndex]:lSchedule := oFiltro:lSchedule
		aFiltEsp[nIndex]:lPendente := oFiltro:lPendente
	Next
Return Nil

/*/{Protheus.doc} Reprocessa
Executa o reprocessamento das mensagens.

@type  Static Function
@author lucas.franca
@since 01/07/2019
@version P12.1.27
/*/
Static Function Reprocessa()
	Local nIndex  := 0
	Local nTotal  := 0
	Local nQtdReg := 0
	Default lAutoMacao := .F.

	nTotal := Len(aDados)
	If nTotal == 1 .And. aDados[1][ARRAY_POS_API_ID] == ""
		//Tratativa para quando não existem dados na tela.
		HELP(' ',1,"HELP",,STR0031,2,0,,,,,, {STR0032}) //"Não existem dados consultados." ### "Execute a pesquisa antes de realizar o processamento."
		Return Nil
	EndIf

	For nIndex := 1 To nTotal
		If aDados[nIndex][ARRAY_POS_MARK_ID] .And. aDados[nIndex][ARRAY_POS_STATUS_ID] != "3"
			nQtdReg++
		EndIf
	Next nIndex

	If nQtdReg == 0
		HELP(' ',1,"NAOMARCADO",,STR0025,2,0,,,,,, {STR0026}) //"Nenhum registro selecionado para reprocessar" //"Selecione os registros para executar o reprocessamento."
		Return
	ElseIf nQtdReg > 0
		IF !lAutoMacao
			If !MsgYesNo(STR0027 + cValToChar(nQtdReg) + STR0028, STR0029) //"Deseja reprocessar o(s) " //" registro(s) selecionado(s)?" //"Atenção"
				Return Nil
			EndIf
		ENDIF
	EndIf

	Processa( {|| ExecReproc() }, STR0015, STR0030,.F.) //"Aguarde..." //"Reprocessando registros..."
Return Nil

/*/{Protheus.doc} ExecReproc
Executa o reprocessamento das mensagens.

@type  Static Function
@author lucas.franca
@since 01/07/2019
@version P12.1.27
/*/
Static Function ExecReproc()
	Local aAPI       := {}
	Local aRetorno   := {}
	Local aSuccess   := {}
	Local aError     := {}
	Local aOper      := {"INSERT","DELETE","CLEARINSERT"}
	Local cFuncApi   := ""
	Local cOperac    := ""
	Local cTipo      := ""
	Local cUUID      := UUIDRandomSeq()
	Local lAllError  := .F.
	Local lTTDemands := .F.
	Local nIndex     := 0
	Local nIndOper   := 0
	Local nUltimo    := 0
	Local nTotal     := 0
	Local oJsonDados := JsonObject():New()
	Local oTTDemands := Nil
	Default lAutoMacao := .F.

	//Monta JSON com os dados que serão reprocessados
	nTotal := Len(aDados)
	For nIndex := 1 To nTotal
		If aDados[nIndex][ARRAY_POS_MARK_ID]
			IF !lAutoMacao
				If oTabsFil[aDados[nIndex][ARRAY_POS_API_ID]] != Nil .And. aDados[nIndex][ARRAY_POS_STATUS_ID] != "3"
					If !lTTDemands .And. aDados[nIndex][ARRAY_POS_API_ID] == "MRPDEMANDS"
						lTTDemands := .T.
					EndIf

					If oJsonDados[aDados[nIndex][ARRAY_POS_API_ID]] == Nil
						oJsonDados[aDados[nIndex][ARRAY_POS_API_ID]] := JsonObject():New()
					EndIf

					If aDados[nIndex][ARRAY_POS_TIPO] == '1'
						cOperac := aOper[1] //"INSERT"
					ElseIf aDados[nIndex][ARRAY_POS_TIPO] == '2'
						cOperac := aOper[2] //"DELETE"
					ElseIf aDados[nIndex][ARRAY_POS_TIPO] == '3'
						//Se for Atualização, não precissa preencher o Json (será chamado o PCPA141)
						cOperac := aOper[3] //"CLEARINSERT"
						MarcaT4R(aDados[nIndex][ARRAY_POS_RECNO], cUUID) //Função de atualização
						oJsonDados[aDados[nIndex][ARRAY_POS_API_ID]][cOperac] := .T.
						Loop
					EndIf

					If oJsonDados[aDados[nIndex][ARRAY_POS_API_ID]][cOperac] == Nil
						oJsonDados[aDados[nIndex][ARRAY_POS_API_ID]][cOperac] := JsonObject():New()
						oJsonDados[aDados[nIndex][ARRAY_POS_API_ID]][cOperac]["items"] := {}
					EndIf

					aAdd(oJsonDados[aDados[nIndex][ARRAY_POS_API_ID]][cOperac]["items"], JsonObject():New())
					nUltimo := Len(oJsonDados[aDados[nIndex][ARRAY_POS_API_ID]][cOperac]["items"])
					oJsonDados[aDados[nIndex][ARRAY_POS_API_ID]][cOperac]["items"][nUltimo]:FromJson(aDados[nIndex][ARRAY_POS_MSGENV])
				EndIf
			ENDIF
		EndIf
	Next nIndex

	//Cria temp table para processamento de demandas.
	If lTTDemands
		oTTDemands := P136APITMP()
	EndIf

	BEGIN TRANSACTION

	//Executa as funções da api
	aAPI := oJsonDados:GetNames()
	nTotal := Len(aAPI)
	ProcRegua((nTotal*3)+2)
	For nIndOper := 1 To 3
		cOperac := aOper[nIndOper]
		For nIndex := 1 To nTotal
			IncProc()
			aRetorno  := {}
			aSuccess  := {}
			aError    := {}
			lAllError := .F.
			If oTabsFil[aApi[nIndex]] != Nil
				If oJsonDados[aAPI[nIndex]][cOperac] != Nil
					//Executa a função da API
					If cOperac == "CLEARINSERT"
						cFuncApi := oTabsFil[aApi[nIndex]][4]
						If !Empty(cFuncApi)
							If "|" + aApi[nIndex] + "|" $ "|MRPALLOCATIONS|MRPPRODUCTIONORDERS|MRPPURCHASEORDER|MRPPURCHASEREQUEST|"
								cFuncApi += '(cUUID)'
							Else
								cFuncApi += '(cUUID, "1")'
							EndIf	
							cTipo    := '3'
							&(cFuncApi)
						EndIf
						Loop
					Else
						If cOperac == "INSERT"
							cFuncApi := oTabsFil[aApi[nIndex]][2] //Função de inclusão
							cTipo    := '1'

						ElseIf cOperac == "DELETE"
							cFuncApi := oTabsFil[aApi[nIndex]][3] //Função de exclusão
							cTipo    := '2'
						EndIf

						If aApi[nIndex] == "MRPBILLOFMATERIAL"
							cFuncApi += '(oJsonDados["' + aAPI[nIndex] + '"]["' + cOperac + '"], cTipo)'
						Else
							cFuncApi += '(oJsonDados["' + aAPI[nIndex] + '"]["' + cOperac + '"])'
						EndIf
						aRetorno := &(cFuncApi)

						// Não atualiza as pendências quando for estrutura, pois a propria função de reprocessamento já faz.
						If aApi[nIndex] != "MRPBILLOFMATERIAL"
							//Executa a função para atualizar as pendências.
							PrcPendMRP(aRetorno, aAPI[nIndex], oJsonDados[aAPI[nIndex]][cOperac], .T., @aSuccess, @aError, @lAllError, cTipo)
						EndIf

						//Tratativas específicas de cada API
						If cTipo == '1' .And. aApi[nIndex] == "MRPDEMANDS"
							AtuDemands(lAllError, aSuccess, aError, oJsonDados[aAPI[nIndex]][cOperac], oTTDemands)
						EndIf
					EndIf
				EndIf
			EndIf
		Next nIndex
	Next nIndOper

	END TRANSACTION

	//Deleta as temp tables criadas.
	If lTTDemands
		oTTDemands:Delete()
		oTTDemands := Nil
	EndIf
	
	//Refaz a consulta para exibir os dados atualizados em tela
	IncProc()
	buscaDados()
	IncProc()
	FiltraInfo()
Return Nil

/*/{Protheus.doc} AtuDemands
Executa a atualização da flag de integração da tabela de demandas (SVR)

@type  Static Function
@author lucas.franca
@since 01/07/2019
@version P12.1.27
@param lAllError , Logic , Indica se ocorreu erro em todo o processo
@param aSuccess  , Array , Dados processados com sucesso
@param aError    , Array , Dados processados com erro
@param oDados    , Object, JSON com os dados enviados para processamento
@param oTTDemands, Object, TEMP Table para utilizar no processamento de atualização.
/*/
Static Function AtuDemands(lAllError, aSuccess, aError, oDados, oTTDemands)
Default lAutoMacao := .F.

	If lAllError
		//Se ocorreu erro em todos os dados, adiciona todos os registros enviados no array aError.
		aSuccess  := {}
		aError    := aClone(oDados["items"])
		lAllError := .F.
	EndIf
	IF !lAutoMacao
		A136UpdFlg(lAllError, aSuccess, aError, {}, oTTDemands)
	ENDIF
Return

/*/{Protheus.doc} MarcaT4R
Marca o registro a ser processado

@type  Static Function
@author marcelo.neumann
@since 04/09/2019
@version P12.1.27
@param 01 nRecno, Numeric  , R_E_C_N_O_ do registro a ser marcado
@param 02 cUUID , Character, identificador para o processo
/*/
Static Function MarcaT4R(nRecno, cUUID)

	Local cSql := "UPDATE " + RetSqlName("T4R")                       + ;
	                " SET T4R_IDPRC  = '"  + cUUID              + "'" + ;
	              " WHERE R_E_C_N_O_ = '"  + cValToChar(nRecno) + "'" + ;
	                " AND T4R_STATUS IN (" + IN_STATUS_PENDENTE + ")"

	If TcSqlExec(cSql) < 0
		LogMsg('PCPA142', 0, 0, 1, '', '', STR0053 + TcSqlError()) //"Erro ao marcar os registros para processamento. "
	EndIf

Return

/*/{Protheus.doc} TrataJson
Trata a mensagem Json para ser exibida

@type  Static Function
@author marcelo.neumann
@since 16/10/2019
@version P12.1.27
@param nAt, Numeric, Linha posicionada da grid
/*/
Static Function TrataJson(nAt)

	Local aMaps    := {}
	Local nIndex1  := 0
	Local nIndex2  := 0
	Local nLenMaps := 0
	Local nLen     := 0
	Local cError   := ""
	Local oJsonMsg := JsonObject():New()
	Default lAutoMacao := .F.

	IF !lAutoMacao
		oMsgEnv:BeginUpdate()
		oMsgEnv:Reset()
	ENDIF

	If !Empty(aDados[nAt][ARRAY_POS_MSGENV])
		cError := oJsonMsg:FromJson(aDados[nAt][ARRAY_POS_MSGENV])

		If cError == Nil
			//Tratamento caso não tenha função de retorno do maps da API
			If !Empty(oTabsFil[aDados[nAt][ARRAY_POS_API_ID]][6])
				aMaps := &(oTabsFil[aDados[nAt][ARRAY_POS_API_ID]][6])

				//Percorre todos os Maps, alimentando um Json com a descrição
				nLenMaps := Len(aMaps)
				For nIndex1 := 1 To nLenMaps
					//Percorre todos os campos do Map
					nLen := Len(aMaps[nIndex1])
					For nIndex2 := 1 To nLen
						//Busca a descrição caso ainda não tenha sido buscada
						If oJsonDesc[aMaps[nIndex1][nIndex2][1]] == Nil .Or. oJsonDesc[aMaps[nIndex1][nIndex2][1]] <> aMaps[nIndex1][nIndex2][2]
							oJsonDesc[aMaps[nIndex1][nIndex2][1]] := RetTitle(aMaps[nIndex1][nIndex2][2])
						EndIf
					Next nIndex2
				Next nIndex1
			EndIf

			//Informa a descrição dos atributos que agrupam as listas (inexistentes no mapfields da API)
			Do Case
				Case aDados[nAt][ARRAY_POS_API_ID] == "MRPBILLOFMATERIAL"
					oJsonDesc["listOfMRPComponents"   ] := STR0061 //"Componentes"
					oJsonDesc["listOfMRPAlternatives" ] := STR0062 //"Alternativos"
			EndCase

			MontaTree(oJsonMsg, 1)
		Else
			oMsgEnv:AddItem(PadR(cError, TAMANHO_ITEM_TREE), , , , , , 1)
		EndIf
	EndIf

	IF !lAutoMacao
		oMsgEnv:EndUpdate()
	ENDIF

	FreeObj(oJsonMsg)
	oJsonMsg := Nil

Return cError

/*/{Protheus.doc} MontaTree
Monta uma tree de acordo com o objeto oJson
@author Marcelo Neumann
@since 18/10/2019
@version 1.0
@param 01 oJson , Object , objeto JSON a ser convertido para tree
@param 02 nNivel, Numeric, indica onde os filhos devem ser incluídos em relação ao posicionado: 1 - Mesmo nível
                                                                                                2 - Nível abaixo
/*/
Static Function MontaTree(oJson, nNivel)

	Local aNames    := oJson:GetNames()
	Local nIndNames := 0
	Local nIndArray := 0
	Local nLenNames := 0
	Local cNode     := ""
	Local cNodeAgr  := ""
	Local cNodePri  := ""
	Default lAutoMacao := .F.

	//Ordena as chaves pois o GetNames
	aSort(aNames)

	//Percorre as chaves do JSON
	nLenNames := Len(aNames)
	For nIndNames := 1 To nLenNames
		//Se não existe descrição, usa a chave como descrição (tratamento de erro)
		If oJsonDesc[aNames[nIndNames]] == NIL
			oJsonDesc[aNames[nIndNames]] := aNames[nIndNames]
		EndIf

		//Se for uma lista, cria os nós de agrupamento e chama a função MontaTree (recursiva)
		If ValType(oJson[aNames[nIndNames]]) == "A"
			oMsgEnv:AddItem(PadR(oJsonDesc[aNames[nIndNames]],TAMANHO_ITEM_TREE), , , , , , nNivel)
			cNode := LastNode()
			oMsgEnv:PTGotoToNode(cNode)

			//Percorre o array com a lista
			nLenArray := Len(oJson[aNames[nIndNames]])
			For nIndArray := 1 To nLenArray
				//Adiciona um agrupador para os campos das listas
				oMsgEnv:AddItem("[" + cValToChar(nIndArray) + "]", , , , , , 2)
				cNodeAgr := LastNode()
				oMsgEnv:PTGotoToNode(cNodeAgr)

				//Chama recursivamente, pois é um novo Json
				MontaTree(oJson[aNames[nIndNames]][nIndArray], 2)

				//Posiciona no pai e Recolhe a tree
				oMsgEnv:PTGotoToNode(cNodeAgr)
				oMsgEnv:PTCollapse()
				oMsgEnv:PTGotoToNode(cNode)
			Next nIndArray
			oMsgEnv:PTCollapse()

			//O registro passa a ficar posicionado na lista, logo, deve-se inserir no mesmo nível os próximos atributos
			nNivel := 1
		Else
			If ValType(oJson[aNames[nIndNames]]) == "N"
				oJson[aNames[nIndNames]] := cValToChar(oJson[aNames[nIndNames]])
			ElseIf ValType(oJson[aNames[nIndNames]]) == "L"
				oJson[aNames[nIndNames]] := IIf(oJson[aNames[nIndNames]], STR0065, STR0066) //"Verdadeiro", "Falso"
			ElseIf ValType(oJson[aNames[nIndNames]]) == "U"
				oJson[aNames[nIndNames]] := ""
			EndIf

			oMsgEnv:AddItem(PadR(oJsonDesc[aNames[nIndNames]] + ";" + oJson[aNames[nIndNames]],TAMANHO_ITEM_TREE), , , , , , nNivel)
		EndIf

		//Armazena o primeiro item inserido
		If nIndNames == 1 .And. nNivel == 1
			cNodePri := LastNode()
			oMsgEnv:PTGotoToNode(cNodePri)
		EndIf
	Next nIndNames

	//Pocisiona no primeiro item incluído
	IF !lAutoMacao
		oMsgEnv:PTGotoToNode(cNodePri)
	ENDIF

Return

/*/{Protheus.doc} LastNode
Retorna o ID do último nó da Tree
@author Marcelo Neumann
@since 18/10/2019
@version 1.0
@return Character, Quantidade de nós da tree formatado com "0" à esquerda
/*/
Static Function LastNode()

Return PadL(oMsgEnv:PTGetNodeCount(), Len(oMsgEnv:CurrentNodeId), "0")
