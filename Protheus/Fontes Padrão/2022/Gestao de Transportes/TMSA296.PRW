#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TMSA296.CH"

Static lMarkAll  	:= .T.
Static lMarkTodos	:= .T.
Static cTodos		:= MV_PAR01 //usado para quando houver todos no parâmetro, e permitir que possa ser selecionado nenhum e depois todos novamente.

Static lLoteNFc := TMA296Lot()

/*/{Protheus.doc} TMSA296
//Monitor de averbação: tem como objetivo monitorar todos os documentos averbados ou não.
@author Mohamed S B Djalo
@since 22/11/2017
@version 12.1.17
@see http://tdn.totvs.com/pages/viewpage.action?pageId=325855664
/*/
Function TMSA296()

	Private oBrowse		:= FWMarkBrowse():New()
	Private c296RetFil	:= ''
	Private c296RetSta	:= ''
	Private lTela			:= .T.
	//Abre o pergunte, aplica o filtro no browse, limpa o campo DL5_MARK, e ativa o timer se informado no pergunte.
	If !TMA296Par(.F.)
		Return
	EndIf

	oBrowse:SetAlias("DL5")
	oBrowse:SetMenuDef("TMSA296")
	oBrowse:SetDescription(STR0002) // "Monitor de averbação"
	oBrowse:AddStatusColumns({||TMA296Stat(DL5->DL5_STATUS)}, {||TMS296Lege()})
	oBrowse:SetFieldMark("DL5_MARK")
	oBrowse:SetCustomMarkRec({||TMA296MkUn()}) //marcar o regisro selecionado
	oBrowse:SetAllMark({||TMA296MsgR(1)}) //marcar todos os registros pendentes para transmissão

	SetKey(VK_F12,{ ||TMA296Par(.T.)} )
	
	oBrowse:Activate()

Return(Nil)

Static Function Menudef(lTela)
	Local aRotina := {}
	Default lTela := .T.

	If IsInCallStack("A296F3Fil") .OR. IsInCallStack("A296F3Sta") .OR. IsInCallStack("A296F3Tip")
		lTela := .F.
	Endif

	If lTela
		If lLoteNFc
			ADD OPTION aRotina TITLE STR0006 ACTION "TMA296MsgR(3)"      				OPERATION 3 ACCESS 0 // "Transmitir"
			ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSA296"    				OPERATION 2 ACCESS 0 // "Visualizar"
			ADD OPTION aRotina TITLE STR0031 ACTION "StaticCall(TMSA296,TMS296Lege)"	OPERATION 2 ACCESS 0 // "Legenda"
		Else
			ADD OPTION aRotina TITLE STR0007 ACTION "TMA296MsgR(1)"      				OPERATION 4 ACCESS 0 // "Marcar/Desmarcar Pendentes"
			ADD OPTION aRotina TITLE STR0006 ACTION "TMA296MsgR(3)"      				OPERATION 3 ACCESS 0 // "Transmitir"
			ADD OPTION aRotina TITLE STR0033 ACTION "TMA296MsgR(2, .T.)" 				OPERATION 4 ACCESS 0 // "Refresh"
			ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSA296"    				OPERATION 2 ACCESS 0 // "Visualizar"
			ADD OPTION aRotina TITLE STR0031 ACTION "StaticCall(TMSA296,TMS296Lege)"	OPERATION 2 ACCESS 0 // "Legenda"
			ADD OPTION aRotina TITLE STR0032 ACTION "TMA296Par(.T.)"     				OPERATION 3 ACCESS 0 // "Parâmetro"
		EndIf
	Else
		ADD OPTION aRotina TITLE STR0045 ACTION "StaticCall(TMSA296,TMA296AMARK)" OPERATION 4 ACCESS 0 // "Marcar/Desmarcar todos"
	EndIf

	lTela := .T.
	
Return aRotina

Static Function ModelDef()
	Local oModel
	Local oStDL5  := FWFormStruct(1, 'DL5')
	
	oModel := MPFormModel():New("TMSA296", /*bPre*/, /* bPost*/, /*bACommit*/, /*bCancel*/)
	oModel:AddFields("FIELDS_DL5", Nil, oStDL5,/*bPre*/,/*bPost*/,/*bLoad*/)
	
	oModel:SetPrimaryKey({"DL5_FILIAL","DL5_FILDOC", "DL5_DOC", "DL5_SERIE"})
	 						
Return oModel

Static Function ViewDef()
	Local oModel    := FWLoadModel("TMSA296")
	Local oStDL5    := FWFormStruct(2, 'DL5')
	Local oView     := FWFormView():New()
	
	oStDL5:RemoveField("DL5_MARK")
	oView:SetModel(oModel)
	
	oView:AddField('VIEW_DL5',oStDL5,'FIELDS_DL5')
	
	oView:EnableTitleView( "VIEW_DL5", STR0009 ) //"Averbação"

Return oView

/*/{Protheus.doc} TMA296Env
//Esta função tem como objetivo averbar todos os documentos com averbação pendente
@author Gustavo Krug
@since 27/11/2017
@version 12.1.17
/*/
Function TMA296Env()
	Local aAreaDL5  := DL5->(GetArea())
	Local aAreaDL51 := {}
	Local nX        := 0
	
	Local cCondicao := ""

	If lLoteNFc
		cCondicao := "       DL5->DL5_FILIAL == '" + xFilial("DL5") + "'"
		cCondicao += " .And. DL5->DL5_FILDOC ==  DT6->DT6_FILDOC "
		cCondicao += " .And. DL5->DL5_DOC    ==  DT6->DT6_DOC "
		cCondicao += " .And. DL5->DL5_SERIE  ==  DT6->DT6_SERIE "

		DL5->(DbSetFilter({|| &cCondicao },cCondicao))
	EndIf

	DL5->(DbSetOrder(1))
	While !DL5->(EoF())
		If !Empty(DL5->DL5_MARK) .Or. lLoteNFc
			aAreaDL51 := DL5->(GetArea())
			TMSAVBe('2', DL5->DL5_FILDOC, DL5->DL5_DOC, DL5->DL5_SERIE)
			nX++
			RestArea(aAreaDL51)
			If (DL5->DL5_STATUS $ '26') //Se estiver autorizado ou cancelado, desmarca o registro
				TMA296MkUn()
			EndIf
		EndIf
		DL5->(DbSkip())
	EndDo

	If lLoteNFc
		DL5->(DbClearFilter())
		DL5->(DbCloseArea())
	EndIf
		
	RestArea(aAreaDL5)

	If !lLoteNFc
		If nX == 0
			MsgAlert(STR0034)
		Else
			TMA296MsgR(2,.F.)
		EndIf
	EndIf
	
	Sleep(500)
	
Return

/*/{Protheus.doc} TMA296MkUn()
//Função para marcar/desmarcar um único documento
@author Gustavo Krug
@since 27/11/2017
@version 12.1.17
/*/
Function TMA296MkUn()
	Local aArea := GetArea()
    
	DL5->(DbSetOrder(1))
	If DL5->(MsSeek(xFilial("DL5") + DL5->DL5_FILDOC + DL5->DL5_DOC + DL5->DL5_SERIE ))
		//Marca se o status permitir e se não estiver marcado. Senão desmarca
		RecLock("DL5",.F.)
		DL5->DL5_MARK := IIf(DL5->DL5_STATUS $ "013457" .And. Vazio(DL5->DL5_MARK), oBrowse:Mark(), '')
		MsUnlock()
	EndIf
	RestArea(aArea)
		
Return

/*/{Protheus.doc} TMA296MsgR
/Executa um processo de forma que seja exibida uma mensagem para bloquear a tela e executar um processamento. 
O processamento faz o refresh da tela e atualiza DL5_MARK para vazio, caso seja passado por parâmetro para isso.
Parâmetros:
nProc: indica o processo que será executado.
lMarkVazio: usado apenas no processo de atualização de tela para indicar se haverá update para vazio do campo DL5_MARK
@author Gustavo Krug
@since 01/12/2017
@version 12.1.17
/*/
Function TMA296MsgR(nProc, lMarkVazio)
	Do Case
	Case nProc == 1; MsgRun(STR0036,STR0035,{||TMA296MkAll()})          //"Processando marcação dos documentos...", "Aguarde"
	Case nProc == 2; MsgRun(STR0037,STR0035,{||TMA296Refr(lMarkVazio)}) //"Atualizando exibição das informações...", "Aguarde"
	Case nProc == 3; MsgRun(STR0038,STR0035,{||TMA296Env()})            //"Transmitindo documentos...", "Aguarde"
	Case nProc == 4; MsgRun(STR0037,STR0035,{||oBrowse:Refresh()})   	 //"Atualizando exibição das informações...", "Aguarde"
	EndCase
Return

/*/{Protheus.doc} TMA296MkAll
//Função para marcar/desmarcar todos os documentos pendentes.
@author Gustavo Krug
@since 27/11/2017
@version 12.1.17
/*/
Function TMA296MkAll()
	Local cFiltro

	cFiltro := TMA296Filt(.F.)
	cFiltro += " AND DL5_STATUS IN ('0','1','3','4','5','7')" //Adiciona no filtro somente aqueles que podem ser marcados
	TMA296MkUp(IIf(lMarkAll,oBrowse:Mark(),''), cFiltro)
	lMarkAll := !lMarkAll
	TMA296Refr(.F.)
	
	oBrowse:GoTop()
		
Return ( Nil )

/*/{Protheus.doc} TMA296Refr
/Faz o refresh da tela e atualiza DL5_MARK para vazio, caso seja passado por parâmetro para isso.

Parâmetros:
1-lMarkVazio: se verdadeiro, executa o update que atualiza o campo DL5_MARK de todos os registros para vazio.
@author Gustavo Krug
@since 01/12/2017
@version 12.1.17
/*/

Function TMA296Refr(lMarkVazio)
	Local aArea  := GetArea()
    Local nPos := oBrowse:at()
	If lMarkVazio
		lMarkAll := .T. //para retornar ao status default de marcar todos, já que todos serão desmarcados no comando a seguir
		TMA296MkUp('')  //altera DL5_MARK para '' em todos os registros
	EndIf
	
	oBrowse:SetFilterDefault(TMA296Filt()) //Efetua o setfilter pois no refresh os registros eram todos exibidos e depois exibidos conforme filtro
	oBrowse:Refresh(.T.)
	RestArea(aArea)

	If ValType(npos) <> 'U' 
		oBrowse:GoTop()
	EndIf			
	
Return

/*/{Protheus.doc} TMA296MkUp
//Atualiza o campo DL5_MARK dos registros a partir do filtro passado por parâmetro
Parâmetros:
1-cValor: valor que será gravado no campo DL5_MARK
2-cFiltro: condição WHERE que indica quais registros serão atualizados.
@author Wander Horongoso
@since 07/12/2017
@version 12.1.17
/*/
Function TMA296MkUp(cValor, cFiltro)
	Local cQuery  := ""
	Local nStatus

	Default cFiltro := ''
    
	cQuery := "UPDATE " + RetSqlName("DL5")+ " SET DL5_MARK = '" + cValor + "'"
	
	If !Empty(cFiltro)
		cQuery += " WHERE " + cFiltro
	EndIf
	
	nStatus := TcSqlExec(cQuery)
	
	If (nStatus < 0)
		TmsLogMsg("ERROR", "TCSQLError() : " + TCSQLError())
	EndIf
		
Return

/*/{Protheus.doc} TMS296Lege
Esta função tem como objetivo, exibir a legenda conforme status do documento de averbação.
@author Mohamed S B Djalo
@since 27/11/2017
@version 12.1.17
@param  cTipo
/*/
Static Function TMS296Lege()

	Local   oLegend  :=  FWLegend():New()
    
	oLegend:Add("","BR_VERDE",        STR0022) // "Aguardando Averbação"
	oLegend:Add("","BR_LARANJA",      STR0023) // "Falha de Comunicação"
	oLegend:Add("","BR_AZUL",         STR0024) // "Averbado"
	oLegend:Add("","BR_VERMELHO",     STR0025) // Recusado"
	oLegend:Add("","BR_VERDE_ESCURO", STR0026) // "Aguardando Cancelamento"
	oLegend:Add("","BR_AMARELO",      STR0027) // "Falha de Comunicação para Cancelamento"
	oLegend:Add("","BR_CANCEL",       STR0028) // "Averbção cancelada"
	oLegend:Add("","BR_VIOLETA",      STR0029) // "Cancelamento Recusado"
	oLegend:Add("","BR_CANCEL",       STR0030) // "Documento cancelado antes da averbação"
   	
	oLegend:Activate()
	oLegend:View()
	oLegend:DeActivate()
   	
Return

/*/{Protheus.doc} TMA296Stat
Função retorna as cores conforme o status de documento de averbação eletronica
@author Mohamed S B Djalo
@since 27/11/2017
@version 12.1.17
@param cStatus
@return cStatus
/*/
Static Function TMA296Stat(cStatus)
	Do Case
	Case cStatus=="0"; cStatus := 'BR_VERDE'
	Case cStatus=="1"; cStatus := 'BR_LARANJA'
	Case cStatus=="2"; cStatus := 'BR_AZUL'
	Case cStatus=="3"; cStatus := 'BR_VERMELHO'
	Case cStatus=="4"; cStatus := 'BR_VERDE_ESCURO'
	Case cStatus=="5"; cStatus := 'BR_AMARELO'
	Case cStatus=="6"; cStatus := 'BR_CANCEL'
	Case cStatus=="7"; cStatus := 'BR_VIOLETA'
	Case cStatus=="8"; cStatus := 'BR_CANCEL'
	EndCase
Return cStatus

/*/{Protheus.doc} TMA296Filt
//Objetivo desta função é montar o filtro para consultar os documentos de averbação eletronica
@author Mohamed S B Djalo
@since 24/11/2017
@version 12.1.17
/*/
Function TMA296Filt(lFormAdvPL)
	Local cRet
	Local nX
	Local aStatus
	Local nY            := 1
	Local aFiliais      := {}
	Default lFormAdvPL	:= .T. //.T. = cria filtro no formato advpl; .F. = cria filtro no formato SQL
	
	cRet := IIf (lFormAdvPL,"DL5_FILIAL == '", "DL5_FILIAL = '") + xFilial("DL5") + "' "
	If !Empty(TMSA296Limp(MV_PAR01)) .And. Upper(Trim(TMSA296Limp(MV_PAR01))) != Upper('Todos')
		aFiliais := StrTokArr(AllTrim(MV_PAR01),";")
		For nY := 1 to Len(aFiliais)
			If !Empty(aFiliais[nY])
				If nY == 1
					cRet += IIf (lFormAdvPL," .AND. (DL5_FILDOC == '"," AND DL5_FILDOC IN ('") + PadR(aFiliais[nY],Len(DL5->DL5_FILDOC)) + "'"
				Else
					cRet += IIf (lFormAdvPL," .Or. DL5_FILDOC == '", ", '") + PadR(aFiliais[nY],Len(DL5->DL5_FILDOC)) + "'"
				EndIf
			EndIf
		Next
		If !Empty(aFiliais[1])
			cRet += ")"
		EndIf
	EndIf
   
	cRet += IIf (lFormAdvPL," .AND. DToS(DL5_DATEMI) >= '"," AND DL5_DATEMI >= '") + DtoS(MV_PAR02) + "' "
	cRet += IIf (lFormAdvPL," .AND. DToS(DL5_DATEMI) <= '"," AND DL5_DATEMI <= '") + DtoS(MV_PAR03) + "' "
	cRet += IIf (lFormAdvPL," .AND."," AND") + " DL5_DOC   >= '" + TMSA296Limp(MV_PAR04) + "' "
	cRet += IIf (lFormAdvPL," .AND."," AND") + " DL5_DOC   <= '" + TMSA296Limp(MV_PAR05) + "' "
	cRet += IIf (lFormAdvPL," .AND."," AND") + " DL5_SERIE >= '" + TMSA296Limp(MV_PAR06) + "' "
	cRet += IIf (lFormAdvPL," .AND."," AND") + " DL5_SERIE <= '" + TMSA296Limp(MV_PAR07) + "' "
	
	If ValType(MV_PAR11) == "C" .And. ValType(MV_PAR12) == "C" .And. ValType(MV_PAR13) == "C" .And. ValType(MV_PAR14) == "C" .And. DL5->(ColumnPos("DL5_CLIDEV")) > 0  
		cRet += IIf (lFormAdvPL," .AND."," AND") + " DL5_CLIDEV >= '" + TMSA296Limp(MV_PAR11) + "' "
		cRet += IIf (lFormAdvPL," .AND."," AND") + " DL5_LOJDEV >= '" + TMSA296Limp(MV_PAR12) + "' "
		cRet += IIf (lFormAdvPL," .AND."," AND") + " DL5_CLIDEV <= '" + TMSA296Limp(MV_PAR13) + "' "
		cRet += IIf (lFormAdvPL," .AND."," AND") + " DL5_LOJDEV <= '" + TMSA296Limp(MV_PAR14) + "' "
	EndIf
    
	If !Empty(TMSA296Limp(MV_PAR08))
		aStatus := StrTokArr(AllTrim(Transform(TMSA296Limp(MV_PAR08),"@R 9;9;9;9;9;9;9;9;9")), ';')
        
		For nX := 1 to Len(aStatus)
			If FwIsNumeric(aStatus[nx]) .AND. !Empty(aStatus[nx])
				If Len(aStatus[nx]) == 1 //campo é char(1), então ignora informações com tamanho maior (inválidas)
					If nX == 1
						cRet += IIf (lFormAdvPL," .AND. (DL5_STATUS == '"," AND DL5_STATUS IN ('") + trim(aStatus[nx]) + "'"
					Else
						cRet += IIf (lFormAdvPL," .Or. DL5_STATUS == '", ", '") + trim(aStatus[nx]) + "'"
					EndIf
				EndIf
			EndIf
		Next nX
		If !Empty(aStatus[1])
			cRet += ")"
		EndIf
	EndIf
	If ValType(MV_PAR09) == "C"  //Suavização 12.1.17 - 12.1.21 (parametro criado na Issue DLOGTMS01-1826 )
		If !Empty(TMSA296Limp(MV_PAR09))
			aStatus := StrTokArr(AllTrim(Transform(TMSA296Limp(MV_PAR09),"@R 9;9;9;9;9;9;9;9;9")), ';')
        
			For nX := 1 to Len(aStatus)
				If FwIsNumeric(aStatus[nx]) .AND. !Empty(aStatus[nx])
					If Len(aStatus[nx]) == 1 //campo é char(1), então ignora informações com tamanho maior (inválidas)
						If nX == 1
							cRet += IIf (lFormAdvPL," .AND. (DL5_DOCTMS == '"," AND DL5_DOCTMS IN ('") + trim(aStatus[nx]) + "'"
							Else
							cRet += IIf (lFormAdvPL," .Or. DL5_DOCTMS == '", ", '") + trim(aStatus[nx]) + "'"
						EndIf
					EndIf
				EndIf
			Next nX
			If !Empty(aStatus[1])
				cRet += ")"
			EndIf
		EndIf 
    EndIf //Suavização 12.1.17 - 12.1.21 (parametro criado na Issue DLOGTMS01-1826 )
    
Return cRet

/*/{Protheus.doc} TMS296Par
//Executa o pergunte, faz o filtro, atualiza DL5_MARK para vazio e carrega os dados na tela conforme o filtro
@author Mohamed S B Djalo
@since 28/11/2017
@version 12.1.17
/*/
Function TMA296Par(lF12)
	Local lRet
	Local nTempo  //Suavização 12.1.17 - 12.1.21 (parametro criado na Issue DLOGTMS01-1826 )
	
	lRet := Pergunte('TMSA296', .T.)
	
	Iif(ValType(MV_PAR09) == "C", nTempo := MV_PAR10 , nTempo := MV_PAR09 ) //Suavização 12.1.17 - 12.1.21 (parametro criado na Issue DLOGTMS01-1826 )
	
	If lRet
		TMA296MsgR(2, .T.) //Executa o refresh e atualiza DL5_MARK para vazio
	
		If nTempo > 0
			oBrowse:SetTimer({|| TMA296MsgR(4) }, nTempo*60*1000)  //Atualização do monitor será feita a cada X minutos
		EndIf
		If lF12
			oBrowse:GoTop()
		EndIf
	Else
		Pergunte('TMSA296', .F.) //Efetua o pergunte para retornar os parâmetros com os valores antes da abertura do pergunte anterior.
		If lF12
			oBrowse:GoTop()
		Endif	
	EndIf
   	
Return lRet

/*/{Protheus.doc} A296F3Fil
//Cria uma tela MVC para selecionar as filiais.
@author Mohamed S B Djalo
@since 11/12/2017
@version 12.1.17
@return return, return_description
/*/
Function A296F3Fil()
	Local aBotoes     := {} //Botoes da tela
	Local aStructBrw  := {} //Estrutura da tela
	Local aCamposBrw  := {} //Campos que compoem a tela
	Local aColsBrw    := {} //Colunas que compoem a tela
	Local nX          := 1
	Local aTodos      := {}
	
	c296RetFil	:= ''
	lTela 		:= .F.
	
	Aadd(aCamposBrw,"AVB_FILIAL")
	Aadd(aCamposBrw,"AVB_DESC")
	Aadd(aCamposBrw,"AVB_CNPJ")
	
	Aadd(aStructBrw, {"MARK",       "C",   1, 0})
	Aadd(aStructBrw, {"AVB_FILIAL", "C",  TAMSX3("DL5_FILDOC")[1], 0})
	Aadd(aStructBrw, {"AVB_DESC",   "C",  50, 0})
	Aadd(aStructBrw, {"AVB_CNPJ",   "C",  18, 0})
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| AVB_FILIAL }"))
	oBrwCol:SetTitle('Código')
	oBrwCol:SetSize(TAMSX3("DL5_FILDOC")[1])
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("AVB_FILIAL")
	AAdd(aColsBrw, oBrwCol)
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| AVB_DESC }"))
	oBrwCol:SetTitle('Descrição')
	oBrwCol:SetSize(50)
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("AVB_DESC")
	AAdd(aColsBrw, oBrwCol)
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('N')
	oBrwCol:SetData(&("{|| AVB_CNPJ }"))
	oBrwCol:SetTitle('CNPJ')
	oBrwCol:SetSize(18)
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("AVB_CNPJ")
	AAdd(aColsBrw, oBrwCol)

	If Len(GetSrcArray("FWTEMPORARYTABLE.PRW")) > 0 .And. !(InTransaction())
		cAliComp := GetNextAlias()
		oTempTable := FWTemporaryTable():New("AVB")
		oTempTable:SetFields(aStructBrw)
		oTempTable:AddIndex("01",{"AVB_FILIAL","AVB_CNPJ"})
		oTempTable:Create()
		cAliComp := oTempTable:GetAlias()
	EndIf
	
	DbSelectArea("AVB")
	
	aSM0   := FWLoadSM0()
	
	For nX := 1 To Len(aSM0)
		If aSM0[nX][1] == cEmpAnt
			("AVB")->(RecLock(("AVB"), .T.))
			("AVB")->AVB_FILIAL := aSM0[nX][2]
			("AVB")->AVB_DESC   := aSM0[nX][7]
			("AVB")->AVB_CNPJ   := aSM0[nX][18]
			("AVB")->(MsUnlock())
		EndIf
	Next
	
	oDlgMan := FWDialogModal():New()
	oDlgMan:SetBackground(.F.)
	oDlgMan:SetTitle("Filiais")
	oDlgMan:SetEscClose(.F.)
	oDlgMan:SetSize(300, 400)
	oDlgMan:CreateDialog()

	oPnlModal := oDlgMan:GetPanelMain()

	oFWLayer := FWLayer():New()                 //-- Container
	oFWLayer:Init(oPnlModal, .F., .F.)          //-- Inicializa container

	oFWLayer:AddLine('LIN', 100, .F.)           //-- Linha
	oFWLayer:AddCollumn('COL', 100, .F., 'LIN') //-- Coluna
	oPnlObj := oFWLayer:GetColPanel('COL', 'LIN')
	
	oMarkBrw := FWMarkBrowse():New()
	oMarkBrw:SetMenuDef("TMSA296")
	oMarkBrw:SetTemporary(.T.)
	oMarkBrw:SetColumns(aColsBrw)
	oMarkBrw:SetAlias("AVB")
	oMarkBrw:SetFieldMark("MARK")
	oMarkBrw:SetDescription(STR0044) //"Seleciona as filiais"
	oMarkBrw:SetOwner(oPnlObj)
	oMarkBrw:SetAllMark({||.F.})
	
	bConfir := {|| A296SelFil(), oDlgMan:DeActivate()}

	bCancel := {|| c296RetFil := MV_PAR01, oDlgMan:DeActivate()}
	    
	//-- Cria botoes de operacao
	Aadd(aBotoes, {"", STR0042, bConfir, , , .T., .F.}) // 'Confirmar'
	Aadd(aBotoes, {"", STR0043, bCancel, , , .T., .F.}) // 'Cancelar'
	oDlgMan:AddButtons(aBotoes)
	
	aTodos := Separa(AllTrim(MV_PAR01),';')
	If Len(aTodos) <= 0
		aadd(aTodos,"N")
	EndIf
	
	oMarkBrw:Activate()
	While AVB->(!Eof())
		If Upper(Trim(aTodos[1])) == Upper('Todos')
			oMarkBrw:MarkRec() 
		Else
			If aScan(aTodos,Trim(AVB->(AVB_FILIAL))) > 0
				oMarkBrw:MarkRec() 
			EndIf
		EndIf
		AVB->(dbSkip())
	EndDo
	oMarkBrw:Refresh(.T.)
	oMarkBrw:GoTop(.T.)
	
	oDlgMan:Activate()
	
	//-- Ao finalizar, elimina tabelas temporarias
	DbSelectArea('AVB')
	DbCloseArea()
	If File(cAliComp+GetDBExtension())
		FErase(cAliComp+GetDBExtension())
	EndIf
	
Return .T.

/*/{Protheus.doc} A296SELFil
//Alimenta a variavel c296RetFil com as filiais selecionadas pelo usuario.
@author Mohamed S B Djalo
@since 11/12/2017
@version 12.1.17
@return return, 
/*/
Function A296SelFil()
	Local aArea     := GetArea()
	Local lTodos    := .T.
	Local nX        := 1
	Local nTotal    := 0
	Local aSM0      := FWLoadSM0()
	Local nFil      := 0
	Local aMarcados := {}
	Local nTamanho  := 99
	lTela := .F.
	
	//determina quantos filiais é posssivel selecionar
	nFil := INT(nTamanho/(Len(aSM0[1][2])+1))
    
	DbSelectArea('AVB')
	dbGoTop()
	While !(EoF())
		If !Empty(MARK)
		    //Sistema preeche o campo Filial de documento com a quantidade maxima de filiais que o campo suporta.
			If (nTotal <= nFil)
				c296RetFil += AVB_FILIAL + ';'
				nTotal++
			EndIf
		Else
			lTodos := .F.
		EndIf
		DbSkip()
	EndDo
	
	//Quando for selecionado todas as filiais o campo Filial de documento é preenchido com a palavra Todos.
	If lTodos
		c296RetFil := 'Todos'
	Else
		aMarcados := Separa(c296RetFil,';')
		c296RetFil := ""
		If Len(aMarcados) > 0
			For nX := 1 To Len(aMarcados)
				If !Empty(aMarcados[nX])
					c296RetFil += aMarcados[nX]
					If nX < (Len(aMarcados) - 1)
						c296RetFil += ';'
					EndIf
				EndIf
			Next
		EndIf
		
		If !(lTodos)
		     //Se a quantidade de filial selecionado for maior que o permitido o sistema avisa e limpa o campo.
			If (nTotal > nFil)
		         //"Limite de filiais exedido"  //"Utiliza opção Marcar / Desmacar para selecionar todos os filiais."
				MsgAlert(STR0039 +' (' + cValToChar(nFil) + '). ' + CHR(13) + STR0040)
				c296RetFil := ""
		         //Retorna somente as filias que cabe no campo para que seja efetuado a consulta
				If Len(aMarcados) > 0
					For nX := 1 To (nTotal - 1)
						c296RetFil += aMarcados[nX]
						If nX < (nTotal - 1)
							c296RetFil += ';'
						EndIf
					Next
				EndIf
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)

Return ( .T. )

/*/{Protheus.doc} A296F3Sta
//Cria uma tela MVC para selecionar tipos de documentos e retorna para a variavel c296RetSta.
@author Mohamed S B Djalo
@since 11/12/2017
@version 12.1.17
@return return, return_description
/*/
Function A296F3Sta()
	Local aBotoes     := {} //Botoes da tela
	Local aStructBrw  := {} //Estrutura da tela
	Local aCamposBrw  := {} //Campos que compoem a tela
	Local aColsBrw    := {} //Colunas que compoem a tela
	Local cAliComp    := GetNextAlias()
	Local nX          := 1
	Local aTodos      := {}
	Local aItem       := {}
	
	c296RetSta := ''
	
	aadd(aItem,{"0",STR0022}) //"Aguardando Averbação"
	aadd(aItem,{"1",STR0023}) //"Falha de Comun. com o WebServ."
	aadd(aItem,{"2",STR0024}) //"Documento Averbado"
	aadd(aItem,{"3",STR0025}) //"Documento Recusado"
	aadd(aItem,{"4",STR0026}) //"Aguardando Canc. da averb."
	aadd(aItem,{"5",STR0027}) //"Falha de comun. do canc. da averb."
	aadd(aItem,{"6",STR0028}) //"Averbação cancelada"
	aadd(aItem,{"7",STR0029}) //"Canc. da averb. recusado"
	aadd(aItem,{"8",STR0030}) //"Doc. canc. antes da averbação"
	
	aadd(aCamposBrw,"AVB_STATUS")
	
	aadd(aStructBrw, {"MARK",       "C",    1, 0})
	aadd(aStructBrw, {"AVB_CODIGO", "C",    1, 0})
	aadd(aStructBrw, {"AVB_STATUS", "C",  100, 0})
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| AVB_STATUS }"))
	oBrwCol:SetTitle('Descrição')
	oBrwCol:SetSize(100)
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("AVB_STATUS")
	AAdd(aColsBrw, oBrwCol)

	If Len(GetSrcArray("FWTEMPORARYTABLE.PRW")) > 0 .And. !(InTransaction())
		cAliComp := GetNextAlias()
		oTempTable := FWTemporaryTable():New("AVB")
		oTempTable:SetFields(aStructBrw)
		oTempTable:AddIndex("01",{"AVB_CODIGO"})
		oTempTable:Create()
		cAliComp := oTempTable:GetAlias()
	EndIf
	
	DbSelectArea("AVB")
	
	For nX := 1 To Len(aItem)
		("AVB")->(RecLock(("AVB"), .T.))
		("AVB")->AVB_CODIGO := aItem[nX][1]
		("AVB")->AVB_STATUS := aItem[nX][2]
		("AVB")->(MsUnlock())
	Next
	
	oDlgMan := FWDialogModal():New()
	oDlgMan:SetBackground(.F.)
	oDlgMan:SetTitle("Status")
	oDlgMan:SetEscClose(.F.)
	oDlgMan:SetSize(200, 350)
	oDlgMan:CreateDialog()

	oPnlModal := oDlgMan:GetPanelMain()

	oFWLayer := FWLayer():New()                 //-- Container
	oFWLayer:Init(oPnlModal, .F., .F.)          //-- Inicializa container

	oFWLayer:AddLine('LIN', 100, .F.)           //-- Linha
	oFWLayer:AddCollumn('COL', 100, .F., 'LIN') //-- Coluna

	oPnlObj := oFWLayer:GetColPanel('COL', 'LIN')
	
	oMarkBrw := FWMarkBrowse():New()
	oMarkBrw:SetMenuDef("TMSA296")
	oMarkBrw:SetTemporary(.T.)
	oMarkBrw:AddStatusColumns({||TMA296Stat(("AVB")->AVB_CODIGO)})
	oMarkBrw:SetColumns(aColsBrw)
	oMarkBrw:SetAlias("AVB")
	oMarkBrw:SetFieldMark("MARK")
	oMarkBrw:SetDescription(STR0041) //"Seleciona o tipo de documento"
	oMarkBrw:SetOwner(oPnlObj)
	oMarkBrw:SetAllMark({||.F.})
	
	bConfir := {|| A296SELSTA(.F.), oDlgMan:DeActivate()}

	bCancel := {|| c296RetSta := MV_PAR08, oDlgMan:DeActivate()}
	    
	//-- Cria botoes de operacao
	Aadd(aBotoes, {"", STR0042, bConfir, , , .T., .F.}) // 'Confirmar'
	Aadd(aBotoes, {"", STR0043, bCancel, , , .T., .F.}) // 'Cancelar'
	oDlgMan:AddButtons(aBotoes)
	
	If !Empty(MV_PAR08)
		aTodos := Separa(MV_PAR08,';')
	EndIf
	
	oMarkBrw:Activate()
	While AVB->(!Eof())
		If aScan(aTodos,AVB->(AVB_CODIGO)) > 0
			oMarkBrw:MarkRec() 
		EndIf
		AVB->(dbSkip())
	EndDo
	oMarkBrw:Refresh(.T.)
	oMarkBrw:GoTop(.T.)
	
	oDlgMan:Activate()
	
	//-- Ao finalizar, elimina tabelas temporarias
	DbSelectArea('AVB')
	DbCloseArea()
	If File(cAliComp+GetDBExtension())
		FErase(cAliComp+GetDBExtension())
	EndIf
	
Return .T.


/*/{Protheus.doc} A296F3Tip
//Cria uma tela MVC para selecionar tipos de documentos e retorna para a variavel A296F3Tip.
@author Marlon Augusto Heiber
@since 29/03/2018
@version 12.1.21
@return return, return_description
/*/
Function A296F3Tip()
	Local aBotoes     := {} //Botoes da tela
	Local aStructBrw  := {} //Estrutura da tela
	Local aCamposBrw  := {} //Campos que compoem a tela
	Local aColsBrw    := {} //Colunas que compoem a tela
	Local cAliComp    := GetNextAlias()
	Local nX          := 1
	Local aTodos      := {}
	Local aItem       := {}
	
	c296RetSta := ''
	
	aItem := TMSValField("DL5_DOCTMS",.T.,,.T.,.F.,.F.,.F.)
	
	aadd(aCamposBrw,"AVB_CODIGO")
	aadd(aCamposBrw,"AVB_STATUS")
	
	aadd(aStructBrw, {"MARK",       "C",    1, 0})
	aadd(aStructBrw, {"AVB_CODIGO", "C",    1, 0})
	aadd(aStructBrw, {"AVB_STATUS", "C",  100, 0})
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| AVB_CODIGO }"))
	oBrwCol:SetTitle('Tipo Doc.')
	oBrwCol:SetSize(5)
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("AVB_CODIGO")
	AAdd(aColsBrw, oBrwCol)
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| AVB_STATUS }"))
	oBrwCol:SetTitle('Descrição Tipo Doc.')
	oBrwCol:SetSize(100)
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("AVB_STATUS")	
	AAdd(aColsBrw, oBrwCol)

	If Len(GetSrcArray("FWTEMPORARYTABLE.PRW")) > 0 .And. !(InTransaction())
		cAliComp := GetNextAlias()
		oTempTable := FWTemporaryTable():New("AVB")
		oTempTable:SetFields(aStructBrw)
		oTempTable:AddIndex("01",{"AVB_CODIGO"})
		oTempTable:Create()
		cAliComp := oTempTable:GetAlias()
	EndIf
	
	DbSelectArea("AVB")
	
	For nX := 1 To Len(aItem)
		("AVB")->(RecLock(("AVB"), .T.))
		("AVB")->AVB_CODIGO := aItem[nX][1]
		("AVB")->AVB_STATUS := aItem[nX][2]
		("AVB")->(MsUnlock())
	Next
	
	oDlgMan := FWDialogModal():New()
	oDlgMan:SetBackground(.F.)
	oDlgMan:SetTitle("Tipo de Documento")
	oDlgMan:SetEscClose(.T.)
	oDlgMan:SetSize(200, 350)
	oDlgMan:CreateDialog()

	oPnlModal := oDlgMan:GetPanelMain()

	oFWLayer := FWLayer():New()                 //-- Container
	oFWLayer:Init(oPnlModal, .F., .F.)          //-- Inicializa container

	oFWLayer:AddLine('LIN', 100, .F.)           //-- Linha
	oFWLayer:AddCollumn('COL', 100, .F., 'LIN') //-- Coluna

	oPnlObj := oFWLayer:GetColPanel('COL', 'LIN')
	
	oMarkBrw := FWMarkBrowse():New()
	oMarkBrw:SetMenuDef("TMSA296")
	oMarkBrw:SetTemporary(.T.)
	oMarkBrw:SetColumns(aColsBrw)
	oMarkBrw:SetAlias("AVB")
	oMarkBrw:SetFieldMark("MARK")
	oMarkBrw:SetDescription(STR0041) //"Seleciona o tipo de documento"
	oMarkBrw:SetOwner(oPnlObj)
	oMarkBrw:SetAllMark({||.F.})
	
	bConfir := {|| A296SELSTA(.T.), oDlgMan:DeActivate()}

	bCancel := {|| c296RetSta := MV_PAR09, oDlgMan:DeActivate()}
	    
	//-- Cria botoes de operacao
	Aadd(aBotoes, {"", STR0042, bConfir, , , .T., .F.}) // 'Confirmar'
	Aadd(aBotoes, {"", STR0043, bCancel, , , .T., .F.}) // 'Cancelar'
	oDlgMan:AddButtons(aBotoes)
	
	If !Empty(MV_PAR09)
		aTodos := Separa(MV_PAR09,';')
	EndIf
	
	oMarkBrw:Activate()
	While AVB->(!Eof())
		If !Empty(MV_PAR09) .AND. Upper(Trim(aTodos[1])) == Upper('Todos')
			oMarkBrw:MarkRec() 
		Else
			If aScan(aTodos,AVB->(AVB_CODIGO)) > 0
				oMarkBrw:MarkRec() 
			EndIf
		EndIf
		AVB->(dbSkip())
	EndDo
	oMarkBrw:Refresh(.T.)
	oMarkBrw:GoTop(.T.)
	
	oDlgMan:Activate()
	
	//-- Ao finalizar, elimina tabelas temporarias
	DbSelectArea('AVB')
	DbCloseArea()
	If File(cAliComp+GetDBExtension())
		FErase(cAliComp+GetDBExtension())
	EndIf
	
Return .T.

/*/{Protheus.doc} A296SELSTA
//Alimenta a variavel c296RetSta com as filiais selecionadas pelo usuario.
@author Mohamed S B Djalo
@since 11/12/2017
@version 12.1.17
@return return, 
/*/
Function A296SelSta(lTodos)
	Local aArea     := GetArea()
	Local aMarcados := {}
	Local nX        := 1
	Default lTodos 	:= .T.
	
	DbSelectArea('AVB')
	dbGoTop()
	While !(EoF())
		If !Empty(MARK)
			c296RetSta += Trim(AVB_CODIGO) + ';'
		Else
			lTodos := .F.
		EndIf
		DbSkip()
	EndDo
	If lTodos
		c296RetSta := 'Todos'
	Else
		aMarcados := Separa(c296RetSta,';')
		c296RetSta := ""
		If Len(aMarcados) > 0
			For nX := 1 To Len(aMarcados)
				If !Empty(aMarcados[nX])
					c296RetSta += Trim(aMarcados[nX])
					If nX < (Len(aMarcados) - 1)
						c296RetSta += ';'
					EndIf
				EndIf
			Next
		EndIf
	Endif
	RestArea(aArea)
	
Return ( .T. )

/*/{Protheus.doc} TMSA296RDSt
//Retorna a descrição do Status para exibição no monitor de averbação.
Usada no X3_BOX do campo DL5_STATUS.
@author Wander Horongoso
@since 14/12/2017
@version 12.1.17
@return cRet 
/*/
Function TMSA296RDSt()
	Local cRet

	cRet :=  '0=' + STR0022 +;
		';1=' + STR0023 +;
		';2=' + STR0024 +;
		';3=' + STR0025 +;
		';4=' + STR0026 +;
		';5=' + STR0027 +;
		';6=' + STR0028 +;
		';7=' + STR0029 +;
		';8=' + STR0030
Return cRet

Static Function TMA296AMARK()
	Local aArea := ('AVB')->(GetArea())
    
	DbSelectArea('AVB')
	dbGoTop()
   
	If Upper(Trim(cTodos)) == Upper('Todos')
		lMarkTodos := .F.
		cTodos := ''
	EndIf
    
	While !(EoF())
		If (Empty(MARK) .And. lMarkTodos) .Or. (!Empty(MARK) .And. !lMarkTodos)
			oMarkBrw:MarkRec()
		EndIf
		DbSkip()
	EndDo
	
	lMarkTodos := !lMarkTodos
	
	RestArea(aArea)
Return ( Nil )

/*/{Protheus.doc} TMSA296Limp
Remove caracteres especiais 
@author Marlon Augusto Heiber
@since 22/12/2017
@version 12.1.17
@param  cValor
@return cValor
/*/
Function TMSA296Limp(cValor)

	cValor := StrTran(cValor,".")
	cValor := StrTran(cValor,":")
	cValor := StrTran(cValor,"]")
	cValor := StrTran(cValor,"[")
	cValor := StrTran(cValor,"}")
	cValor := StrTran(cValor,"{")
	cValor := StrTran(cValor,",")
	cValor := StrTran(cValor,"|")
	cValor := StrTran(cValor,"/")
	cValor := StrTran(cValor,"\")
	cValor := StrTran(cValor,"-")
	cValor := StrTran(cValor,"*")
	cValor := StrTran(cValor,"+")
	cValor := StrTran(cValor,"ª")
	cValor := StrTran(cValor,"º")
	cValor := StrTran(cValor,"¹")
	cValor := StrTran(cValor,"²")
	cValor := StrTran(cValor,"³")
	cValor := StrTran(cValor,"£")
	cValor := StrTran(cValor,"¢")
	cValor := StrTran(cValor,"¬")
	cValor := StrTran(cValor,"'")
	cValor := StrTran(cValor,"?")
	cValor := StrTran(cValor,"!")
	cValor := StrTran(cValor,"@")
	cValor := StrTran(cValor,"#")
	cValor := StrTran(cValor,"$")
	cValor := StrTran(cValor,"%")
	cValor := StrTran(cValor,"¨")
	cValor := StrTran(cValor,"&")
	cValor := StrTran(cValor,"(")
	cValor := StrTran(cValor,")")
	cValor := StrTran(cValor,"§")
	cValor := StrTran(cValor,"=")
	cValor := StrTran(cValor,"<")
	cValor := StrTran(cValor,">")
	cValor := StrTran(cValor,"á","a")
	cValor := StrTran(cValor,"à","a")
	cValor := StrTran(cValor,"â","a")
	cValor := StrTran(cValor,"ã","a")
	cValor := StrTran(cValor,"é","e")
	cValor := StrTran(cValor,"è","e")
	cValor := StrTran(cValor,"ê","e")
	cValor := StrTran(cValor,"í","i")
	cValor := StrTran(cValor,"ì","i")
	cValor := StrTran(cValor,"ó","o")
	cValor := StrTran(cValor,"ò","o")
	cValor := StrTran(cValor,"ô","o")
	cValor := StrTran(cValor,"õ","o")
	cValor := StrTran(cValor,"ú","u")
	cValor := StrTran(cValor,"ù","u")
	cValor := StrTran(cValor,"ç","c")
	cValor := STrim(cValor)
	
Return  cValor


/*/{Protheus.doc} TMA296Vld()
//Validações gerais TMSA296
@author Felipe Barbiere
@since 19/03/2021
@version 12.1.32
@return cRet 
/*/
Function TMA296Vld()

Local lRet := .T.
Local xDestino := AllTrim(&(ReadVar()))

If ValType(xDestino) == "C" .And. !Empty(xDestino)
	If !IsEmail(xDestino) 
		If !ExistDir( xDestino )
			CheckHLP('PTMSA29601', {'E-Mail ou Pasta de Destino ','  inválida. Verifique! ',' '},{''},{''},.T.)
			Help( " " , 1 ,"TMSA29601") // E-Mail ou Pasta de Destino inválida!
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} TMA296Lot()
Verifica se a chamada foi do Lote de NFs Cliente
@author Valdemar Roberto Mognon
@since 03/05/2021
@return lRet 
/*/
Static Function TMA296Lot()
Local lRet := IsInCallStack("TMSA170")

Return lRet
