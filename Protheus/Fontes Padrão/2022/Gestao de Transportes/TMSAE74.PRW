#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TMSAE74.CH"

Static lMarkAll  	:= .T.
Static lMarkTodos	:= .T.
Static cTodos		:= MV_PAR01 //usado para quando houver todos no parâmetro, e permitir que possa ser selecionado nenhum e depois todos novamente.

/*/{Protheus.doc} TMSAE74
//Monitor de averbação: tem como objetivo monitorar os MDFe´s averbados ou não.
@author Rodolfo K Rosseto
@since 03/09/2018
@version 12.1.17
/*/
Function TMSAE74()
	
	Local lCallVge 		:= (FunName() $ "TMSA140A/TMSA144B/TMSA141C/TMSA144D")
	
	Private oBrowse		:= FWMarkBrowse():New()
	Private c74eRetFil	:= ''
	Private c74eRetSta	:= ''
	Private lTela		:= .T.	

	If !(TableIndic("DL6") .And. TableIndic("DLI"))
		MsgNextRel(STR0023) //"Averbacao de Seguro - Tabelas DLI e DL6"
		Return
	EndIf
	
	//Abre o pergunte, aplica o filtro no browse, limpa o campo DLI_MARK, e ativa o timer se informado no pergunte.
	If !TME74Par(.F.)
		Return
	EndIf
	
	//--Se for chamado da viagem, precisa limpar o aRotina que vem da viagem
	If lCallVge
		aRotina := {}
	EndIf

	oBrowse:SetAlias("DLI")
	oBrowse:SetMenuDef("TMSAE74")
	oBrowse:SetDescription(STR0024) //"Tracking Eventos MDFe"
	oBrowse:AddStatusColumns({||TME74Stat(DLI->DLI_STATUS)}, {||TME74Leg()})
	oBrowse:SetFieldMark("DLI_MARK")
	oBrowse:SetCustomMarkRec({||TME74MkUn()}) //marcar o regisro selecionado
	oBrowse:SetAllMark({||TME74MsgR(1)}) //marcar todos os registros pendentes para transmissão

	SetKey(VK_F12,{ ||TME74Par(.T.)} )
	
	oBrowse:Activate()

Return(Nil)

Static Function Menudef(lTela)
	Local aRotina 	:= {}	
	Local lCallVge	:= (FunName() $ "TMSA140A/TMSA144B/TMSA141C/TMSA144D")
	
	Default lTela := .T.

	If IsInCallStack("TM74F3Fil") .OR. IsInCallStack("TM74F3Sta")
		lTela := .F.
	Endif

	If lTela
		ADD OPTION aRotina TITLE STR0007 ACTION "TME74MsgR(1)"      				OPERATION 4 ACCESS 0 // "Marcar/Desmarcar Pendentes"
		ADD OPTION aRotina TITLE STR0006 ACTION "TME74MsgR(3)"      				OPERATION 3 ACCESS 0 // "Transmitir"
		ADD OPTION aRotina TITLE STR0017 ACTION "TME74MsgR(2, .T.)" 				OPERATION 4 ACCESS 0 // "Refresh"
		ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAE74"    				OPERATION 2 ACCESS 0 // "Visualizar"
		ADD OPTION aRotina TITLE STR0019 ACTION "StaticCall(TMSAE74,TME74Leg)"		OPERATION 2 ACCESS 0 // "Legenda"
		If !lCallVge
			ADD OPTION aRotina TITLE STR0018 ACTION "TME74Par(.T.)"     				OPERATION 3 ACCESS 0 // "Parâmetro"
		Else
			ADD OPTION aRotina TITLE STR0018 ACTION "TME74But()"     				OPERATION 3 ACCESS 0 // "Parâmetro"
		EndIf
	Else
		ADD OPTION aRotina TITLE STR0001 ACTION "StaticCall(TMSAE74,TME74AMARK)" 	OPERATION 4 ACCESS 0 // "Marcar/Desmarcar todos"
	EndIf

	lTela := .T.
	
Return aRotina

Static Function ModelDef()
	Local oModel
	Local oStDLI  := FWFormStruct(1, 'DLI')
	
	oModel := MPFormModel():New("TMSAE74", /*bPre*/, /* bPost*/, /*bACommit*/, /*bCancel*/)
	oModel:AddFields("FIELDS_DLI", Nil, oStDLI,/*bPre*/,/*bPost*/,/*bLoad*/)
	
	oModel:SetPrimaryKey({"DLI_FILIAL","DLI_FILMAN", "DLI_MANIFE", "DLI_SERMAN", "DLI_CODEVE", "DLI_SEQEVE"})                                                                                               
	 						
Return oModel

Static Function ViewDef()
	Local oModel    := FWLoadModel("TMSAE74")
	Local oStDLI    := FWFormStruct(2, 'DLI')
	Local oView     := FWFormView():New()
	
	oStDLI:RemoveField("DLI_MARK")
	oView:SetModel(oModel)
	
	oView:AddField('VIEW_DLI',oStDLI,'FIELDS_DLI')
	
	oView:EnableTitleView( "VIEW_DLI", STR0009 ) //"Averbação"

Return oView

/*/{Protheus.doc} TME74Env
//Esta função tem como objetivo averbar todos os documentos com averbação pendente
@author Rodolfo K Rosseto
@since 04/09/2018
@version 12.1.17
/*/
Function TME74Env()
	Local nX        := 0
	Local cAliasDLI := GetNextAlias()
	Local cQuery    := ''
	
	cQuery := " SELECT DLI_FILIAL, DLI_FILMAN, DLI_MANIFE, DLI_SERMAN, DLI_CODEVE, DLI_SEQEVE "
	cQuery += " FROM " + RetSqlName("DLI") 
	cQuery += " WHERE DLI_FILIAL = '" + xFilial("DLI")  + "' "
	If ValType(oBrowse:Mark()) = "C" .AND. !Empty(oBrowse:Mark())
		cQuery += " AND DLI_MARK = '" + oBrowse:Mark() + "'"
	Else
		cQuery += " AND DLI_MARK <> ' ' "
	EndIf
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDLI, .F., .T.)
	
	While !(cAliasDLI)->(Eof())	
		TMSAVBeM((cAliasDLI)->DLI_FILMAN, (cAliasDLI)->DLI_MANIFE, (cAliasDLI)->DLI_SERMAN,,(cAliasDLI)->DLI_CODEVE,(cAliasDLI)->DLI_SEQEVE)
		nX++
	(cAliasDLI)->(DbSkip())
	EndDo							
	
	If nX == 0
		MsgAlert(STR0016) //--Nao existem documentos para transmitir
	Else
		TME74MsgR(2,.F.)
	EndIf
	
	Sleep(500)
	
	(cAliasDLI)->( DbCloseArea() )
	
Return

/*/{Protheus.doc} TME74MkUn()
//Função para marcar/desmarcar um único documento
@author Gustavo Krug
@since 27/11/2017
@version 12.1.17
/*/
Function TME74MkUn()
	Local aArea := GetArea()                                                                                          

	DLI->(DbSetOrder(1))
	If DLI->(MsSeek(xFilial("DLI") + DLI->DLI_FILMAN + DLI->DLI_MANIFE + DLI->DLI_SERMAN + DLI->DLI_CODEVE + DLI->DLI_SEQEVE ))
		//Marca se o status permitir e se não estiver marcado. Senão desmarca
		RecLock("DLI",.F.)
		DLI->DLI_MARK := IIf(DLI->DLI_STATUS $ "02" .And. Vazio(DLI->DLI_MARK), oBrowse:Mark(), '')
		MsUnlock()
	EndIf
	RestArea(aArea)
		
Return

/*/{Protheus.doc} TME74MsgR
/Executa um processo de forma que seja exibida uma mensagem para bloquear a tela e executar um processamento. 
O processamento faz o refresh da tela e atualiza DL5_MARK para vazio, caso seja passado por parâmetro para isso.
Parâmetros:
nProc: indica o processo que será executado.
lMarkVazio: usado apenas no processo de atualização de tela para indicar se haverá update para vazio do campo DL5_MARK
@author Gustavo Krug
@since 01/12/2017
@version 12.1.17
/*/
Function TME74MsgR(nProc, lMarkVazio)
	Do Case
	Case nProc == 1; MsgRun(STR0014,STR0015,{||TME74MkAll()})          //"Processando marcação dos documentos...", "Aguarde"
	Case nProc == 2; MsgRun(STR0013,STR0015,{||TME74Refr(lMarkVazio)}) //"Atualizando exibição das informações...", "Aguarde"
	Case nProc == 3; MsgRun(STR0012,STR0015,{||TME74Env()})            //"Transmitindo documentos...", "Aguarde"
	Case nProc == 4; MsgRun(STR0013,STR0015,{||oBrowse:Refresh()})   	 //"Atualizando exibição das informações...", "Aguarde"
	EndCase
Return

/*/{Protheus.doc} TME74MkAll
//Função para marcar/desmarcar todos os documentos pendentes.
@author Gustavo Krug
@since 27/11/2017
@version 12.1.17
/*/
Function TME74MkAll()
	Local cFiltro

	cFiltro := TME74Filt(.F.)
	cFiltro += " AND DLI_STATUS <> '1' " //Adiciona no filtro somente aqueles que podem ser marcados
	TME74MkUp(IIf(lMarkAll,oBrowse:Mark(),''), cFiltro)
	lMarkAll := !lMarkAll
	TME74Refr(.F.)
	
	oBrowse:GoTop()
		
Return ( Nil )

/*/{Protheus.doc} TME74Refr
/Faz o refresh da tela e atualiza DLI_MARK para vazio, caso seja passado por parâmetro para isso.
Parâmetros:
1-lMarkVazio: se verdadeiro, executa o update que atualiza o campo DLI_MARK de todos os registros para vazio.
@author Rodolfo K Rosseto
@since 04/09/2018
@version 12.1.17
/*/
Function TME74Refr(lMarkVazio)
	Local aArea  := GetArea()
    Local nPos := oBrowse:at()
	If lMarkVazio
		lMarkAll := .T. //para retornar ao status default de marcar todos, já que todos serão desmarcados no comando a seguir
		TME74MkUp('')  //altera DL5_MARK para '' em todos os registros
	EndIf
	
	oBrowse:SetFilterDefault(TME74Filt()) //Efetua o setfilter pois no refresh os registros eram todos exibidos e depois exibidos conforme filtro
	oBrowse:Refresh(.T.)
	RestArea(aArea)

	If ValType(npos) <> 'U' 
		oBrowse:GoTop()
	EndIf			
	
Return

/*/{Protheus.doc} TME74MkUp
//Atualiza o campo DLI_MARK dos registros a partir do filtro passado por parâmetro
Parâmetros:
1-cValor: valor que será gravado no campo DLI_MARK
2-cFiltro: condição WHERE que indica quais registros serão atualizados.
@author Rodolfo K Rosseto
@since 04/09/2018
@version 12.1.17
/*/
Function TME74MkUp(cValor, cFiltro)
	Local cQuery  := ""
	Local nStatus := 0

	Default cFiltro := ''
    
	cQuery := "UPDATE " + RetSqlName("DLI")+ " SET DLI_MARK = '" + cValor + "'"
	
	If !Empty(cFiltro)
		cQuery += " WHERE " + cFiltro
	EndIf
	
	nStatus := TcSqlExec(cQuery)
	
	If (nStatus < 0)
		TmsLogMsg("ERROR", "TCSQLError() : " + TCSQLError())
	EndIf
		
Return


/*/{Protheus.doc} TME74Leg
Esta função tem como objetivo, exibir a legenda conforme status do documento de averbação.
@author Rodolfo K Rosseto
@since 03/09/2018
@version 12.1.17
/*/
Static Function TME74Leg()

	Local   oLegend  :=  FWLegend():New()
    
	oLegend:Add("","BR_VERDE",        STR0022) // "Aguardando Averbação"
	oLegend:Add("","BR_LARANJA",      STR0021) // "Falha"
	oLegend:Add("","BR_AZUL",         STR0020) // "Averbado"
   	
	oLegend:Activate()
	oLegend:View()
	oLegend:DeActivate()
   	
Return

/*/{Protheus.doc} TME74Stat
Função retorna as cores conforme o status de documento de averbação eletronica
@author Rodolfo K Rosseto
@since 04/09/2018
@version 12.1.17
@param cStatus
@return cStatus
/*/
Static Function TME74Stat(cStatus)
	Do Case
	Case cStatus=="0"; cStatus := 'BR_VERDE'	
	Case cStatus=="1"; cStatus := 'BR_AZUL'
	Case cStatus=="2"; cStatus := 'BR_LARANJA'
	EndCase
Return cStatus

/*/{Protheus.doc} TME74Filt
//Objetivo desta função é montar o filtro para consultar os documentos de averbação eletronica
@author Rodolfo K Rosseto
@since 04/09/2018
@version 12.1.17
/*/
Function TME74Filt(lFormAdvPL)
	Local cRet
	Local nX
	Local aStatus
	Local nY            := 1
	Local aFiliais      := {}
	Local cQuery 		:= ""
	Local cAliasMDF 	:= ""
	Local aManif 		:= {}
	Local lCallVge 		:= (FunName() $ "TMSA140A/TMSA144B/TMSA141C/TMSA144D") 
	
	Default lFormAdvPL	:= .T. //.T. = cria filtro no formato advpl; .F. = cria filtro no formato SQL

	If !lCallVge .Or. (lCallVge .And. IsInCallStack("TME74BUT")) 	
		cRet := IIf (lFormAdvPL,"DLI_FILIAL == '", "DLI_FILIAL = '") + xFilial("DLI") + "' "
		If !Empty(TME74Limp(MV_PAR01)) .And. Upper(Trim(TME74Limp(MV_PAR01))) != Upper('Todos')
			aFiliais := StrTokArr(AllTrim(MV_PAR01),";")
			For nY := 1 to Len(aFiliais)
				If !Empty(aFiliais[nY])
					If nY == 1
						cRet += IIf (lFormAdvPL," .AND. (DLI_FILMAN == '"," AND DLI_FILMAN IN ('") + PadR(aFiliais[nY],Len(DLI->DLI_FILMAN)) + "'"
					Else
						cRet += IIf (lFormAdvPL," .Or. DLI_FILMAN == '", ", '") + PadR(aFiliais[nY],Len(DLI->DLI_FILMAN)) + "'"
					EndIf
				EndIf
			Next
			If !Empty(aFiliais[1])
				cRet += ")"
			EndIf
		EndIf
	   
		cRet += IIf (lFormAdvPL," .AND. DToS(DLI_DATEMI) >= '"," AND DLI_DATEMI >= '") + DtoS(MV_PAR02) + "' "
		cRet += IIf (lFormAdvPL," .AND. DToS(DLI_DATEMI) <= '"," AND DLI_DATEMI <= '") + DtoS(MV_PAR03) + "' "
		cRet += IIf (lFormAdvPL," .AND."," AND") + " DLI_MANIFE   >= '" + TME74Limp(MV_PAR04) + "' "
		cRet += IIf (lFormAdvPL," .AND."," AND") + " DLI_MANIFE   <= '" + TME74Limp(MV_PAR05) + "' "
		cRet += IIf (lFormAdvPL," .AND."," AND") + " DLI_SERMAN   >= '" + TME74Limp(MV_PAR06) + "' "
		cRet += IIf (lFormAdvPL," .AND."," AND") + " DLI_SERMAN   <= '" + TME74Limp(MV_PAR07) + "' "
	    
		If !Empty(TME74Limp(MV_PAR08))
			aStatus := StrTokArr(AllTrim(Transform(TME74Limp(MV_PAR08),"@R 9;9;9;9;9;9;9;9;9")), ';')
	        
			For nX := 1 to Len(aStatus)
				If FwIsNumeric(aStatus[nx]) .AND. !Empty(aStatus[nx])
					If Len(aStatus[nx]) == 1 //campo é char(1), então ignora informações com tamanho maior (inválidas)
						If nX == 1
							cRet += IIf (lFormAdvPL," .AND. (DLI_STATUS == '"," AND DLI_STATUS IN ('") + trim(aStatus[nx]) + "'"
						Else
							cRet += IIf (lFormAdvPL," .Or. DLI_STATUS == '", ", '") + trim(aStatus[nx]) + "'"
						EndIf
					EndIf
				EndIf
			Next nX
			If !Empty(aStatus[1])
				cRet += ")"
			EndIf
		EndIf	
	EndIf
	
	//--Adicionar os filtros quando for chamado pelos menus de viagem
	//--Quando for chamado pela funcao TME74BUT nao ira filtrar pois o usuario clicou em parametros e quer fazer nova filtragem
	If lCallVge .And. !IsInCallStack("TME74BUT")
		//--Verifica os manifestos da viagem
		cAliasMDF := GetNextAlias()		
		cQuery := " SELECT DTX_MANIFE FROM "
		cQuery += RetSqlName("DTX")+ " DTX "
		cQuery += " WHERE DTX_FILIAL    = '"+xFilial("DTX")+"'"
		cQuery += "   AND DTX_FILORI    = '"+DTQ->DTQ_FILORI+"'"
		cQuery += "   AND DTX_VIAGEM    = '"+DTQ->DTQ_VIAGEM+"'"
		cQuery += "   AND DTX.D_E_L_E_T_    = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasMDF,.T.,.T.)
		
		While (cAliasMDF)->(!Eof())
			Aadd(aManif, { (cAliasMDF)->DTX_MANIFE })
			(cAliasMDF)->(dbSkip())
		EndDo
		(cAliasMDF)->(DbCloseArea())

		//--Verifica manifestos cancelados da viagem
		cAliasMDF := GetNextAlias()		
		cQuery := " SELECT DYN_MANIFE FROM "
		cQuery += RetSqlName("DYN")+ " DYN "
		cQuery += " WHERE DYN_FILIAL    = '"+xFilial("DYN")+"'"
		cQuery += "   AND DYN_FILORI    = '"+DTQ->DTQ_FILORI+"'"
		cQuery += "   AND DYN_VIAGEM    = '"+DTQ->DTQ_VIAGEM+"'"
		cQuery += "   AND DYN.D_E_L_E_T_    = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasMDF,.T.,.T.)
		
		While (cAliasMDF)->(!Eof())
			Aadd(aManif, { (cAliasMDF)->DYN_MANIFE })
			(cAliasMDF)->(dbSkip())
		EndDo
		(cAliasMDF)->(DbCloseArea())		
		
		For nX := 1 To Len(aManif)
			If nx == 1
				cRet := " ( DLI_MANIFE = '" + aManif[nX][01] + "'"
			Else
				cRet += IIf (lFormAdvPL," .OR."," OR") + " DLI_MANIFE = '" + aManif[nX][01] + "'"
			EndIf			
		Next nX
		If Len(aManif) > 0
			cRet += ")"
		EndIf
	EndIf	
    
Return cRet

/*/{Protheus.doc} TME74Par
//Executa o pergunte, faz o filtro, atualiza DLI_MARK para vazio e carrega os dados na tela conforme o filtro
@author Rodolfo K Rosseto
@since 04/09/2018
@version 12.1.17
/*/
Function TME74Par(lF12)
	Local lRet
	Local nTempo := 0
	Local lCallVge 		:= (FunName() $ "TMSA140A/TMSA144B/TMSA141C/TMSA144D")
	
	If !lCallVge .Or. (lCallVge .And. IsInCallStack("TME74BUT"))   	
		lRet := Pergunte('TMSAE74', .T.)
		nTempo := MV_PAR09
	Else
		lRet := .T. //--Nao chama o pergunte mais prossegue a rotina com os filtros necessarios
	EndIf	
	
	If lRet
		TME74MsgR(2, .T.) //Executa o refresh e atualiza DLI_MARK para vazio
	
		If nTempo > 0
			oBrowse:SetTimer({|| TME74MsgR(4) }, nTempo*60*1000)  //Atualização do monitor será feita a cada X minutos
		EndIf
		If lF12
			oBrowse:GoTop()
		EndIf
	Else
		Pergunte('TMSAE74', .F.) //Efetua o pergunte para retornar os parâmetros com os valores antes da abertura do pergunte anterior.
		If lF12
			oBrowse:GoTop()
		Endif	
	EndIf
   	
Return lRet

/*/{Protheus.doc} TM74F3Fil
//Cria uma tela MVC para selecionar as filiais.
@author Rodolfo K Rosseto
@since 04/09/2018
@version 12.1.17
@return return, return_description
/*/
Function TM74F3Fil()
	Local aBotoes     := {} //Botoes da tela
	Local aStructBrw  := {} //Estrutura da tela
	Local aCamposBrw  := {} //Campos que compoem a tela
	Local aColsBrw    := {} //Colunas que compoem a tela
	Local nX          := 1
	Local aTodos      := {}
	
	c74eRetFil	:= ''
	lTela 		:= .F.
	
	Aadd(aCamposBrw,"AVB_FILIAL")
	Aadd(aCamposBrw,"AVB_DESC")
	Aadd(aCamposBrw,"AVB_CNPJ")
	
	Aadd(aStructBrw, {"MARK",       "C",   1, 0})
	Aadd(aStructBrw, {"AVB_FILIAL", "C",  TAMSX3("DLI_FILMAN")[1], 0})
	Aadd(aStructBrw, {"AVB_DESC",   "C",  50, 0})
	Aadd(aStructBrw, {"AVB_CNPJ",   "C",  18, 0})
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| AVB_FILIAL }"))
	oBrwCol:SetTitle('Código')
	oBrwCol:SetSize(TAMSX3("DLI_FILMAN")[1])
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("AVB_FILIAL")
	AAdd(aColsBrw, oBrwCol)
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| AVB_DESC }"))
	oBrwCol:SetTitle(STR0025) //'Descrição'
	oBrwCol:SetSize(50)
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("AVB_DESC")
	AAdd(aColsBrw, oBrwCol)
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('N')
	oBrwCol:SetData(&("{|| AVB_CNPJ }"))
	oBrwCol:SetTitle(STR0026) //'CNPJ'
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
	oDlgMan:SetTitle(STR0027) //"Filiais"
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
	oMarkBrw:SetMenuDef("TMSAE74")
	oMarkBrw:SetTemporary(.T.)
	oMarkBrw:SetColumns(aColsBrw)
	oMarkBrw:SetAlias("AVB")
	oMarkBrw:SetFieldMark("MARK")
	oMarkBrw:SetDescription(STR0002) //"Seleciona as filiais"
	oMarkBrw:SetOwner(oPnlObj)
	oMarkBrw:SetAllMark({||.F.})
	
	bConfir := {|| TM74SelFil(), oDlgMan:DeActivate()}

	bCancel := {|| c74eRetFil := MV_PAR01, oDlgMan:DeActivate()}
	    
	//-- Cria botoes de operacao
	Aadd(aBotoes, {"", STR0004, bConfir, , , .T., .F.}) // 'Confirmar'
	Aadd(aBotoes, {"", STR0003, bCancel, , , .T., .F.}) // 'Cancelar'
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

/*/{Protheus.doc} TM74SelFil
//Alimenta a variavel c74eRetFil com as filiais selecionadas pelo usuario.
@author Rodolfo K Rosseto
@since 04/09/2018
@version 12.1.17
@return return, 
/*/
Function TM74SelFil()
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
				c74eRetFil += AVB_FILIAL + ';'
				nTotal++
			EndIf
		Else
			lTodos := .F.
		EndIf
		DbSkip()
	EndDo
	
	//Quando for selecionado todas as filiais o campo Filial de documento é preenchido com a palavra Todos.
	If lTodos
		c74eRetFil := 'Todos'
	Else
		aMarcados := Separa(c74eRetFil,';')
		c74eRetFil := ""
		If Len(aMarcados) > 0
			For nX := 1 To Len(aMarcados)
				If !Empty(aMarcados[nX])
					c74eRetFil += aMarcados[nX]
					If nX < (Len(aMarcados) - 1)
						c74eRetFil += ';'
					EndIf
				EndIf
			Next
		EndIf
		
		If !(lTodos)
		     //Se a quantidade de filial selecionado for maior que o permitido o sistema avisa e limpa o campo.
			If (nTotal > nFil)
		         //"Limite de filiais exedido"  //"Utiliza opção Marcar / Desmacar para selecionar todos os filiais."
				MsgAlert(STR0011 +' (' + cValToChar(nFil) + '). ' + CHR(13) + STR0010)
				c74eRetFil := ""
		         //Retorna somente as filias que cabe no campo para que seja efetuado a consulta
				If Len(aMarcados) > 0
					For nX := 1 To (nTotal - 1)
						c74eRetFil += aMarcados[nX]
						If nX < (nTotal - 1)
							c74eRetFil += ';'
						EndIf
					Next
				EndIf
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)

Return ( .T. )

/*/{Protheus.doc} TM74F3Sta
//Cria uma tela MVC para selecionar tipos de documentos e retorna para a variavel c74eRetSta.
@author Rodolfo K Rosseto
@since 04/09/2018
@version 12.1.17
@return return, return_description
/*/
Function TM74F3Sta()
	Local aBotoes     := {} //Botoes da tela
	Local aStructBrw  := {} //Estrutura da tela
	Local aCamposBrw  := {} //Campos que compoem a tela
	Local aColsBrw    := {} //Colunas que compoem a tela
	Local cAliComp    := "" //GetNextAlias()
	Local nX          := 1
	Local aTodos      := {}
	Local aItem       := {}
	
	c74eRetSta := ''
	
	aadd(aItem,{"0",STR0022}) //"Aguardando Averbação"
	aadd(aItem,{"1",STR0020}) //"Averbado"
	aadd(aItem,{"2",STR0021}) //"Falha"	
	
	aadd(aCamposBrw,"AVB_STATUS")
	
	aadd(aStructBrw, {"MARK",       "C",    1, 0})
	aadd(aStructBrw, {"AVB_CODIGO", "C",    1, 0})
	aadd(aStructBrw, {"AVB_STATUS", "C",  100, 0})
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| AVB_STATUS }"))
	oBrwCol:SetTitle(STR0025) //'Descrição'
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
	oDlgMan:SetTitle(STR0028) //"Status"
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
	oMarkBrw:SetMenuDef("TMSAE74")
	oMarkBrw:SetTemporary(.T.)
	oMarkBrw:AddStatusColumns({||TME74Stat(("AVB")->AVB_CODIGO)})
	oMarkBrw:SetColumns(aColsBrw)
	oMarkBrw:SetAlias("AVB")
	oMarkBrw:SetFieldMark("MARK")
	oMarkBrw:SetDescription(STR0008) //"Seleciona o tipo de documento"
	oMarkBrw:SetOwner(oPnlObj)
	oMarkBrw:SetAllMark({||.F.})
	
	bConfir := {|| TM74SELSTA(.F.), oDlgMan:DeActivate()}

	bCancel := {|| c74eRetSta := MV_PAR08, oDlgMan:DeActivate()}
	    
	//-- Cria botoes de operacao
	Aadd(aBotoes, {"", STR0004, bConfir, , , .T., .F.}) // 'Confirmar'
	Aadd(aBotoes, {"", STR0003, bCancel, , , .T., .F.}) // 'Cancelar'
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


/*/{Protheus.doc} TM74SelSta
//Alimenta a variavel c74eRetSta com as filiais selecionadas pelo usuario.
@author Rodolfo K Rosseto
@since 04/09/2018
@version 12.1.17
@return return, 
/*/
Function TM74SelSta(lTodos)
	Local aArea     := GetArea()
	Local aMarcados := {}
	Local nX        := 1
	Default lTodos 	:= .T.
	
	DbSelectArea('AVB')
	dbGoTop()
	While !(EoF())
		If !Empty(MARK)
			c74eRetSta += Trim(AVB_CODIGO) + ';'
		Else
			lTodos := .F.
		EndIf
		DbSkip()
	EndDo
	If lTodos
		c74eRetSta := 'Todos'
	Else
		aMarcados := Separa(c74eRetSta,';')
		c74eRetSta := ""
		If Len(aMarcados) > 0
			For nX := 1 To Len(aMarcados)
				If !Empty(aMarcados[nX])
					c74eRetSta += Trim(aMarcados[nX])
					If nX < (Len(aMarcados) - 1)
						c74eRetSta += ';'
					EndIf
				EndIf
			Next
		EndIf
	Endif
	RestArea(aArea)
	
Return ( .T. )

Static Function TME74AMARK()
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

/*/{Protheus.doc} TME74Limp
Remove caracteres especiais 
@author Rodolfo K Rosseto
@since 04/09/2018
@version 12.1.17
@param  cValor
@return cValor
/*/
Function TME74Limp(cValor)

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

/*/{Protheus.doc} TME74But
//Faz uma nova chamada na funcao de exibicao dos parametros,
//para que o usuario possa fazer novo filtro quando estiver na viagem
@author Rodolfo K Rosseto
@since 03/10/2018
@version 12.1.17
@return return, 
/*/
Function TME74But()

TME74Par(.T.)

Return Nil

/*/{Protheus.doc} TME74Cbx
//Descricao do campo virtual DLI_DSCDEV
@author Rodolfo K Rosseto
@since 03/10/2018
@version 12.1.17
@return return, 
/*/
Function TME74Cbx()

Local cRet 		:= ""
Local cCampo	:= DLI->DLI_CODEVE

If cCampo == "001"
	cRet := STR0029 //"Envio MDFe"
ElseIf cCampo == "003"
	cRet := STR0030 //"Inclusao de Condutor MDFe"
ElseIf cCampo == "015"
	cRet := STR0031 //"Cancelamento MDFe"
ElseIf cCampo == "035"
	cRet := STR0032 //"Encerramento MDFe"
EndIf

Return cRet