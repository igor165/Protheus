#INCLUDE "PROTHEUS.CH"
#INCLUDE "QNCA040.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} QNCA340()
Cadastro de FNC
@author Gustavo Della Giustina
@since 29/05/2018
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function QNCA340()
	Local cFilPend   := GETMV("MV_QNCPFNC")
	
	Private aUsrMat    := QNCUSUARIO()
	Private oBrowse	
	Private lApelido := aUsrMat[1]
	Private cMatFil  := aUsrMat[2]
	Private cMatCod  := aUsrMat[3]
	Private cMatDep  := aUsrMat[4]
	Private aQNQI2   := {}
	Private __lQNSX8 := .F.
	Private cFilOrig := aUsrMat[2]
	Private cFilDest := cFilAnt
	Private nMudaSel := If(cFilPend=="S",5,1)
	Private lRevisao := .F.
	Private cMemo4   := ""
	Private cMotivo  := ""
	Private lModFNC  := .F.
		
	DbSelectArea("QI2")
	DbSetOrder(1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada - Exibir MSGs ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ExistBlock( "QNCABFNC" )
		ExecBlock( "QNCABFNC", .f., .f.)
	Endif

	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias("QI2")
	oBrowse:SetDescription(STR0006) //"Cadastro de Ocorrencias/Nao-conformidades"
	A340Filtro()

	oBrowse:AddLegend('!Empty(QI2->QI2_CONREA)', 'ENABLE'  , STR0033) // "Ficha Baixada"
	oBrowse:AddLegend('Empty(QI2->QI2_CONREA) .And. !Empty(QI2->QI2_CODACA) .And. !Empty(QI2->QI2_REVACA)', 'BR_AMARELO', STR0034) // "Ficha pendente com Plano Acao"
	oBrowse:AddLegend('Empty(QI2->QI2_CONREA)' , 'DISABLE' , STR0035) // "Ficha pendente sem Plano Acao"
	oBrowse:AddLegend('QI2->QI2_OBSOL=="S"'    , 'BR_PRETO', STR0079) // "Ficha com Revisao Obsoleta"

	If Existblock("QNC340LEG")
			ExecBlock("QNC340LEG", .F., .F., {@oBrowse})
	Endif

	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Gustavo Della Giustina
@since 29/05/2018
@version 1.0
@return aRotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local cFilPend := GETMV("MV_QNCPFNC")
	Local aRotina  := {}
	Local aRotAdic := {}
	
	ADD OPTION aRotina TITLE STR0001 ACTION 'AxPesqui'        OPERATION 1                      ACCESS 0 //Pesquisar
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.QNCA340' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'QNC340Alt' 		  OPERATION MODEL_OPERATION_INSERT ACCESS 0 //Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'QNC340Alt' 	  	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'QNC340Alt'       OPERATION MODEL_OPERATION_DELETE ACCESS 0 //Excluir
	ADD OPTION aRotina TITLE STR0045 ACTION 'QNC340Rev'       OPERATION 6                      ACCESS 0 //Gera Revisao
	If cFilPend == "N"
		ADD OPTION aRotina TITLE  STR0036  ACTION 'QNC340Sel' OPERATION 3 ACCESS 0 //Muda Selecao
	Endif
	ADD OPTION aRotina TITLE STR0039 ACTION 'QNC040Foll' OPERATION 6 ACCESS 0 //Follow-UP
	ADD OPTION aRotina TITLE STR0041 ACTION 'QNCA040IMP' OPERATION 6 ACCESS 0 //Imprime
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QNC040BUT")
		aRotAdic := ExecBlock("QNC040BUT", .F., .F.)
		If ValType(aRotAdic) == "A" .And. Len(aRotAdic)==1
			AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Gustavo Della Giustina
@since 29/05/2018
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel    := Nil
	Local oStruQI2  := FWFormStruct(1,"QI2")
	Local oStruQIF  := FWFormStruct(1,"QIF")
	Local oEvent    := QNCA340EVDEF():New()

	If Type("lRevisao") != "L"
		Private lRevisao := .F.
	EndIf
	
	If lRevisao
		oStruQI2:SetProperty("QI2_FNC"   , MODEL_FIELD_INIT, {||QI2->QI2_FNC})
		oStruQI2:SetProperty("QI2_REV"   , MODEL_FIELD_INIT, {||StrZero(Val(QI2->QI2_REV)+1, 2)})
	EndIf 
	
	oStruQIF:SetProperty("QIF_SEQ"   , MODEL_FIELD_INIT, {||""})
	oStruQIF:SetProperty("QIF_ETAPA" , MODEL_FIELD_INIT, {||QncInEtapa("QIF", "QI2MASTER")})
	oStruQIF:SetProperty("QIF_NUSR"  , MODEL_FIELD_INIT, {||QncAnexMVC("QIF")})
	oStruQIF:SetProperty("QIF_FILMAT", MODEL_FIELD_INIT, {||IIF(!IsBlind(),aUsrMat[2],)})
	oStruQIF:SetProperty("QIF_MAT"   , MODEL_FIELD_INIT, {||IIF(!IsBlind(),aUsrMat[3],)})
		
	oStruQIF:SetProperty("QIF_TIPO" , MODEL_FIELD_WHEN, {||QNCAltAnex("QIF", "QI2MASTER")})
	oStruQIF:SetProperty("QIF_ETAPA", MODEL_FIELD_WHEN, {||.T.})
	
	oStruQIF:SetProperty("QIF_FILMAT", MODEL_FIELD_VALID, MTBlcVld("QIF", "QIF_FILMAT", "NaoVazio() .And. QAChkFil('QIF_FILMAT', 'QIFDETAIL')",.F.,.F. ))
	oStruQIF:SetProperty("QIF_MAT"   , MODEL_FIELD_VALID, MTBlcVld("QIF", "QIF_MAT", "NaoVazio() .And. VldChkMat('QIF', 'QIFDETAIL', 'QIF_FILMAT', 'QIF_MAT')",.F.,.F. ))
	oStruQIF:SetProperty("QIF_NUSR"  , MODEL_FIELD_VALID, MTBlcVld("QIF", "QIF_NUSR", "NaoVazio()",.F.,.F. ))
	
	oStruQIF:SetProperty("QIF_FNC", MODEL_FIELD_OBRIGAT, .F.)
	oStruQIF:SetProperty("QIF_REV", MODEL_FIELD_OBRIGAT, .F.)
	
	oStruQI2:SetProperty("QI2_FNC"   , MODEL_FIELD_WHEN, {||.T.})
	oStruQI2:SetProperty("QI2_REV"   , MODEL_FIELD_WHEN, {||IsBlind()})
	oStruQI2:SetProperty("QI2_ANO"   , MODEL_FIELD_WHEN, {||IsBlind()})
	oStruQI2:SetProperty("QI2_ORIGEM", MODEL_FIELD_WHEN, {||IsBlind()})
	oStruQI2:SetProperty("QI2_OBSOL" , MODEL_FIELD_WHEN, {||IsBlind()})
	oStruQI2:SetProperty("QI2_DOCUME", MODEL_FIELD_WHEN, {||IsBlind()})

	oStruQI2:SetProperty("QI2_ORIGEM", MODEL_FIELD_INIT, {||"QNC"})
	oStruQI2:SetProperty("QI2_DOCUME", MODEL_FIELD_INIT, {||"S"})
	oStruQI2:SetProperty("QI2_SIGILO", MODEL_FIELD_INIT, {||"2"})
	oStruQI2:SetProperty("QI2_OBSOL" , MODEL_FIELD_INIT, {||"N"})
	oStruQI2:SetProperty("QI2_ANO"   , MODEL_FIELD_INIT, {||QncInitAno("QI2", "QI2MASTER")})
	oStruQI2:SetProperty("QI2_FNC"   , MODEL_FIELD_INIT, {||IIF(!IsBlind(),GETNEXTNUM(StrZero(Year(dDataBase),4)),)})
	oStruQI2:SetProperty("QI2_FILRES", MODEL_FIELD_INIT, {||IIF(!IsBlind(),aUsrMat[2],)})
	oStruQI2:SetProperty("QI2_MATRES", MODEL_FIELD_INIT, {||IIF(!IsBlind(),aUsrMat[3],)})
	oStruQI2:SetProperty("QI2_NUSRRS", MODEL_FIELD_INIT, {||IIF(!IsBlind(),IF(Empty(QI2->QI2_FILRES), QA_NUSR(aUsrMat[2],aUsrMat[3],.T.),QA_NUSR(QI2->QI2_FILRES,QI2->QI2_MATRES)),)})
	oStruQI2:SetProperty("QI2_FILMAT", MODEL_FIELD_INIT, {||IIF(!IsBlind(),aUsrMat[2],)})
	oStruQI2:SetProperty("QI2_MATDEP", MODEL_FIELD_INIT, {||IIF(!IsBlind(),aUsrMat[4],)})
	oStruQI2:SetProperty("QI2_MAT"   , MODEL_FIELD_INIT, {||IIF(!IsBlind(),aUsrMat[3],)})
	oStruQI2:SetProperty("QI2_NUSR"  , MODEL_FIELD_INIT, {||IIF(!IsBlind(),IF(Empty(QI2->QI2_FILMAT), QA_NUSR(aUsrMat[2],aUsrMat[3],.T.),QA_NUSR(QI2->QI2_FILMAT,QI2->QI2_MAT)),)}) 

	oStruQI2:SetProperty("QI2_MEMO1", MODEL_FIELD_OBRIGAT, !IsBlind())

	oStruQI2:SetProperty("QI2_FILORI", MODEL_FIELD_VALID, MTBlcVld("QI2", "QI2_FILORI", "QAChkFil('QI2_FILORI', 'QI2MASTER')",.F.,.F. ))
	oStruQI2:SetProperty("QI2_ORIDEP", MODEL_FIELD_VALID, MTBlcVld("QI2", "QI2_ORIDEP", "QAChkDepto('QI2', 'QI2MASTER', 'QI2_FILORI', 'QI2_ORIDEP')",.F.,.F. ))
	oStruQI2:SetProperty("QI2_FILDEP", MODEL_FIELD_VALID, MTBlcVld("QI2", "QI2_FILDEP", "QAChkFil('QI2_FILDEP', 'QI2MASTER')",.F.,.F. ))
	oStruQI2:SetProperty("QI2_DESDEP", MODEL_FIELD_VALID, MTBlcVld("QI2", "QI2_DESDEP", "QAChkDepto('QI2', 'QI2MASTER', 'QI2_FILDEP', 'QI2_DESDEP')",.F.,.F. ))
	oStruQI2:SetProperty("QI2_FILRES", MODEL_FIELD_VALID, MTBlcVld("QI2", "QI2_FILRES", "QAChkFil('QI2_FILRES', 'QI2MASTER')",.F.,.F. ))
	oStruQI2:SetProperty("QI2_MATRES", MODEL_FIELD_VALID, MTBlcVld("QI2", "QI2_MATRES", "VldChkMat('QI2', 'QI2MASTER', 'QI2_FILRES', 'QI2_MATRES')",.F.,.F. ))

	oStruQI2:AddTrigger( "QI2_STATUS", "QI2_STATUS", { || .t. }, { | x | fTrgJusHelp( x ) } )  
	oStruQIF:AddTrigger("QIF_MAT", "QIF_NUSR", {||.T.}, {|oModel|Posicione("QAA",1,oModel:GetValue("QIF_FILMAT")+oModel:GetValue("QIF_MAT"),"PadR(QAA->QAA_NOME,TamSX3('QIF_NUSR')[1])")})
	
	oModel := MPFormModel():New('QNCA340')
	
	oModel:AddFields("QI2MASTER", /*cOwner*/, oStruQI2 , , )
	oModel:addGrid("QIFDETAIL", 'QI2MASTER', oStruQIF , , ,)
	
	oModel:SetPrimaryKey( {"QI2_FNC", "QI2_REV"} )
	
	oModel:SetRelation("QIFDETAIL", {{"QIF_FILIAL",'xFilial("QIF")'},{"QIF_FNC", "QI2_FNC"},{"QIF_REV","QI2_REV"}},QIF->(IndexKey(1)))
	
	oModel:GetModel("QIFDETAIL"):SetOptional(.T.)
	
	oModel:SetDescription(STR0006) 
	oModel:GetModel("QI2MASTER"):SetDescription(STR0006)
	oModel:GetModel("QIFDETAIL"):SetDescription(STR0016)
	
	oModel:InstallEvent("QNCA340EVDEF", /*cOwner*/, oEvent)
	
	FWMemoVirtual(oStruQI2, {{"QI2_DDETA"  ,"QI2_MEMO1"},;	// Descricao Detalhada
							 {"QI2_COMEN"  ,"QI2_MEMO2"},;	// Comentarios
							 {"QI2_DISPOS" ,"QI2_MEMO3"},;	// Acao Imediata/Disposicao
						 	 {"QI2_MOTREV" ,"QI2_MEMO4"},;  // Motivo da Revisao
							 {"QI2_JUSTIF" ,"QI2_MEMO5"}})	// Justificativa Status Não Procede 

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Gustavo Della Giustina
@since 29/05/2018
@version 1.0
@return oView
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel("QNCA340")
	Local oStruQI2 := FWFormStruct(2,"QI2")
	Local oView
	
	oStruQI2:RemoveField("QI2_ANO")
	oStruQI2:RemoveField("QI2_DISPOS")
	oStruQI2:RemoveField("QI2_DDETA")
	oStruQI2:RemoveField("QI2_COMEN")
	oStruQI2:RemoveField("QI2_ORIGEM")
	oStruQI2:RemoveField("QI2_ANEXO")
	oStruQI2:RemoveField("QI2_OBSOL")
	oStruQI2:RemoveField("QI2_JUSTIF")
	oStruQI2:RemoveField("QI2_MEMO4")
	oStruQI2:RemoveField("QI2_MEMO5")

	oStruQI2:SetProperty("QI2_MEMO1", MVC_VIEW_ORDEM, "12")

	If Type("lRevisao") != "L"
		Private lRevisao := .F.
	EndIf
	
	oStruQI2:RemoveField("QI2_MOTREV")

	oView := FWFormView():New()
	oView:SetViewAction('BUTTONCANCEL', { |oView| A340Rolbak(oView) })
	oView:SetModel( oModel )
	
	oView:AddUserButton(OemToAnsi(STR0015),"FILTRO",{||QNC340ACAO()})  // Plano de Acao
	oView:AddUserButton(OemToAnsi(STR0095),"FILTRO",{|oView| Q340Docs(oView)})   // "Documentos"  //"Docs"
	If oModel:GetOperation() <> MODEL_OPERATION_INSERT
		oView:AddUserButton(OemToAnsi(STR0099),"FILTRO",{|| QNCR030(QI2->(Recno()))})   //"Imprime Follow-Up" //"Follow-Up"
	EndIf
	If (GetMv("MV_QTMKPMS",.F.,1) == 4)
		oView:AddUserButton(OemToAnsi(STR0116),"DISCAGEM",{|| QNC040TMK() })
	EndIf	
	
	If !Empty(cMemo4)
		oView:AddUserButton(OemToAnsi(STR0057),"FILTRO",{|| fTrgMotvRev() }) // "Motivo da Revisao" //"Mot.Rev"
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Visualizacao da Ordem de Servico caso esteja integrado com o MNT ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetMV("MV_NGMNTQN",.F.,"N") == "S"
		oView:AddUserButton(OemToAnsi(STR0031),"FILTRO",{||MNTC040(M->QI2_NUMOS)})
	Endif
	If !IsBlind()
		oView:AddUserButton(STR0124,"DISCAGEM",{||fTrgJustif()})  // Justificativa
	Endif
	oView:AddField( "VIEW_QI2", oStruQI2,  "QI2MASTER")
	oView:CreateHorizontalBox( 'TELA', 100 )
	oView:SetOwnerView( "VIEW_QI2", 'TELA' )
		
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A340Rolbak(oView)
Funcao para cancelar a sequencia não utilizada
@author Gustavo Della Giustina
@since 07/06/2018
@version 1.0
@return 
/*/
//-------------------------------------------------------------------
Static Function A340Rolbak(oView)
	If Type("aQNQI2") != "A"
		Private aQNQI2 := {}
		lA := .F.
	EndIf
	
	If Type("__lQNSX8") != "L"
		Private __lQNSX8 := .F.
	EndIf
	
	If __lQNSX8 .And. Type("aQNQI2[1][1]") <> "U"
		RollBackQE(aQNQI2)
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} QNC340Sel()()
Tela para informar o filtro a ser utilizado
@author Gustavo Della Giustina
@since 07/06/2018
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function QNC340Sel()

	Local oDlg
	Local oMudaSel
	Local nMudaAux:= nMudaSel
	Local nOpc1   := 0
	Local lFecha  := .F.
	
	DEFINE MSDIALOG oDlg FROM 201,101 TO 380,360 TITLE OemToAnsi(STR0036) PIXEL // "Muda Selecao"
	
	@ 003,003 TO 070,126 LABEL OemToAnsi(STR0087) OF oDlg PIXEL // "Situacao"
	
	@ 011,008 RADIO oMudaSel VAR nMudaSel ITEMS;
						OemToAnsi(STR0085),; //"Todas"
						OemToAnsi(STR0033),; //"Ficha Baixada"
						OemToAnsi(STR0034),; //"Ficha pendente com Plano Acao"
						OemToAnsi(STR0035),; //"Ficha pendente sem Plano Acao"
						OemToAnsi(STR0086),; //"Ambas Pendencias"
						OemToAnsi(STR0079) ; //"Ficha com Revisao Obsoleta"
				  3D SIZE 110,008 OF oDlg PIXEL
	
	DEFINE SBUTTON FROM 074,070 TYPE 1 ENABLE OF oDlg ;
				ACTION (nOpc1 := 1,lFecha:= .T.,oDlg:End())
	
	DEFINE SBUTTON FROM 074,100 TYPE 2 ENABLE OF oDlg ;
				ACTION oDlg:End()
	
	ACTIVATE MSDIALOG oDlg CENTERED VALID lFecha
	
	If nOpc1 == 1
		MsgRun( OemToAnsi( STR0037 ), OemToAnsi( STR0038 ), { || A340Filtro() } ) //"Selecionando Ficha de Ocorrencias/Nao-Conformidades" ### "Aguarde..."
	Else
		nMudaSel:= nMudaAux
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A340Filtro()
Monta o filtro que sera utilizado no Brownse
@author Gustavo Della Giustina
@since 07/06/2018
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A340Filtro()
	
	Local cFiltro  := ""
	Local cExpFilt := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada criado para mudar o Filtro ou realizar alguma tarefa especifica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QNCAP01")
		cExpFilt:= ExecBlock("QNCAP01", .F., .F.)
		If !Empty(cExpFilt)
			cExpFilt := " .And. " + cExpFilt
		EndIf
	EndIf
	
	If Type("nMudaSel") = "U"
		Return ".T."
	Endif
	
	If nMudaSel == 1
		cFiltro := ".T." + cExpFilt
	ElseIf nMudaSel == 2 // Baixada
		cFiltro:= '!Empty(QI2->QI2_CONREA)' + cExpFilt
	ElseIf nMudaSel == 3 // Pendente com Plano
		cFiltro:= 'Empty(QI2->QI2_CONREA) .And. !Empty(QI2->QI2_CODACA) .And. !Empty(QI2->QI2_REVACA)' + cExpFilt
	ElseIf nMudaSel == 4 // Pendente sem Plano
		cFiltro:= 'Empty(QI2->QI2_CONREA) .And. Empty(QI2->QI2_CODACA) .And. Empty(QI2->QI2_REVACA)' + cExpFilt
	ElseIf nMudaSel == 5 // Ambas Pendencias
		cFiltro:= 'Empty(QI2->QI2_CONREA)' + cExpFilt
	ElseIf nMudaSel == 6 // Obsoleto
		cFiltro:= 'QI2->QI2_OBSOL == "S"' + cExpFilt
	EndIf
	
	oBrowse:SetFilterDefault(cFiltro)
	
Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} QNC340Rev()
Função de chamada antes do Insert.
@author Luiz Henrique Bourscheid
@since 16/05/2018
@version 1.0
@return oView
/*/
//-------------------------------------------------------------------
Function QNC340Rev()
	Local nRegObs   := QI2->(Recno())
	Local nOrdObs   := QI2->(IndexOrd())
	Local cChaveQI2 := QI2->QI2_FILIAL+QI2->QI2_FNC
	Local lRet		:= .T.

	lRevisao := .T.
	
	If ( cMatFil+cMatCod <> QI2->QI2_FILRES+QI2->QI2_MATRES ) .And. ( cMatFil+cMatCod <> QI2->QI2_FILMAT+QI2->QI2_MAT )
		DbSelectArea("QAA")
		DbSetOrder(1)
		DbSelectArea ("QAD")
		DbSetOrder(1)
	
		If QAA->(DbSeek(xFilial("QAA")+QI2->QI2_MATRES)) .And. !QA_SitFolh() // Usuario inativo
			If QAD->(DbSeek(xFilial("QAD")+QAA->QAA_CC)) .And. !Empty(QAD->QAD_MAT) .And. QAD->QAD_MAT <> cMatCod
				MsgAlert(OemToAnsi(STR0115)) //"O usuário responsável pela Ficha de Ocorrência / Não Conformidade está inativo, somente o responsável pelo Departamento poderá efetuar a revisão."
				lRet := .F.
			EndIf
		Else
			MsgAlert(OemToAnsi(STR0046)) // "Usuario nao autorizado a gerar Revisao."
			lRet := .F.
		EndIf
		RestArea(aArea)
	EndIf
	
	If lRet
		dbSetOrder(2)
	    If dbSeek(cChaveQI2+QI2->QI2_REV)
	    	dbSkip()
				If QI2->QI2_FILIAL+QI2->QI2_FNC == cChaveQI2
					MsgAlert(OemToAnsi(STR0047)) // "Ja existe uma Revisao em andamento ou superior."
					dbSetOrder(nOrdObs)
					dbGoTo(nRegObs)
					Return Nil
				Endif
	    Endif
	
		dbSetOrder(nOrdObs)
		dbGoTo(nRegObs)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Permite apenas a Geracao de Revisao se o Plano de Acao estiver BAIXADO e ³
		//³ se o numero da revisao for menor que "99"(limite de revisoes)            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(QI2->QI2_CONREA)
			If Val(QI2->QI2_REV) < 99
				cMemo4 := fTrgMotvRev()
				If !Empty(cMemo4)
				  If FWExecView(STR0045, "QNCA340", 9) == 0    //  Terceiro parametro "8" = Gera Revisao
						dbSelectArea("QI2")
						dbGoTo(nRegObs)
						RecLock("QI2",.F.)
					    QI2->QI2_OBSOL := "S"
						MsUnLock()				
						dbSkip()
					Endif
				Endif
			Endif
		Else
			MsgAlert(OemToAnsi(STR0048)) // "Nao sera permitida a Geracao de Revisao para Lancamentos pendentes."
		Endif
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QNC340Alt()
Programa generico para alteracao.
@author Luiz Henrique Bourscheid
@since 16/05/2018
@version 1.0
@return oView
/*/
//-------------------------------------------------------------------
Function QNC340Alt(cAlias,nReg,nOpcAcao)
	Local lSigilo    := .T.
	Local lRet 	     := .T.
	Local nHandle
	Local cChaveQI2  := QI2->QI2_FILIAL+QI2->QI2_FNC
	Local lMvQncAEta := If(GetMv("MV_QNCAETA",.F.,"2") == "1",.T.,.F.) // Define se usuario pode alterar a etapa
	Local lAutorizado:= .T.
	Local lUsrAlter  := If(GetMv("MV_QALTFNC",.F.,"2")=="1",.T.,.F.)	// 1=SIM 2=NAO
	
	Private nOpc      := nOpcAcao
	Private cQPathFNC := Alltrim(GetMv("MV_QNCPDOC"))
	Private aQPath    := QDOPATH()
	Private cQPathTrm := aQPath[3]
	Private lAltEta   := .F.
	Private cFilQIF   := xFilial("QAA") 

	If nOpcAcao == 3
		If GetMv("MV_QTMKPMS",.F.,1) == 2 .Or. GetMv("MV_QTMKPMS",.F.,1) == 4
			Alert(STR0117) // "Integracao MV_QTMKPMS ativada, deve ser utilizado o modulo Call Center para inclusão de Chamado/Atendimento"
			Return .F.
		Endif 
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Usuario Logado esta cadastrado no Cad.Usuarios/Responsaveis atraves   ³
	//³ do Apelido cadastro no Configurador                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lApelido
		Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual do configurador."
	Endif
	
	If !Right( cQPathFNC,1 ) == "\"
		cQPathFNC := cQPathFNC + "\"
	Endif
	
	If !Right( cQPathTrm,1 ) == "\"
		cQPathTrm := cQPathTrm + "\"
	Endif
	
	If ExistBlock ("QN040ALT")
		Execblock("QN040ALT",.F.,.F.,{nOpc})
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o diretorio para gravacao do Docto Anexo Existe. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6
		nHandle := fCreate(cQPathFNC+"SIGATST.CEL")
		If nHandle <> -1  // Consegui criar e vou fechar e apagar novamente...
			fClose(nHandle)
			fErase(cQPathFNC+"SIGATST.CEL")
		Else
		  Help("",1,"QNCDIRDCNE") // "O Diretorio definido no parametro MV_QNCPDOC" ### "para o Documento Anexo nao existe."
		  Return .F.
		EndIf
	EndIf
	
	If nOpcAcao <> MODEL_OPERATION_INSERT
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se FNC eh Sigilosa. Somente Responsavel e Digitador podem Manipular  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If QI2->QI2_SIGILO == "1"
			If Existblock("QNC40SIG") //Ponto de Entrada para deixar que uma FNC sigilosa seja visualizada por alguns usuarios
				lSigilo := Execblock("QNC40SIG",.F.,.F.,{cMatFil,cMatCod})
			Endif	
			If !(cMatFil+cMatCod == QI2->QI2_FILMAT+QI2->QI2_MAT .Or. ;
			   	 cMatFil+cMatCod == QI2->QI2_FILRES+QI2->QI2_MATRES) .And. lSigilo
				MsgAlert(OemToAnsi(STR0107)+Chr(13)+;		// "Ficha de Ocorrencias / Nao-conformidades sigilosa"
				OemToAnsi(STR0108 + ;		//"Somente o usuario digitador ("
				AllTrim(Posicione("QAA",1, QI2->QI2_FILMAT+QI2->QI2_MAT,"QAA_NOME")) + ;
				STR0109 + ; // ") e/ou responsavel ("
				AllTrim(Posicione("QAA",1, QI2->QI2_FILRES+QI2->QI2_MATRES,"QAA_NOME"))+ STR0110 ))	// ") terão acesso aos dados."
	
				Return .F.
			Endif
		Endif
		
		nOrdQI2 := QI2->(IndexOrd())
		nRegQI2 := QI2->(Recno())
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe revisoes novas entao forca virar Visualizacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		QI2->(dbSetOrder(2))
	    If dbSeek(cChaveQI2+QI2->QI2_REV)
	    	QI2->(dbSkip())
			While !Eof() .And. QI2->QI2_FILIAL+QI2->QI2_FNC == cChaveQI2
				lAutorizado := .F.
				nOpc := 1
				QI2->(dbSkip())
			Enddo		
	    Endif    
	
		dbGoTo(nRegQI2)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso seja Exclusao verifica se existe revisoes anteriores ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 5 .And. QI2->QI2_OBSOL <> "S"
	        M->QI2_REV := QI2->QI2_REV
		    If dbSeek(cChaveQI2)
				While !Eof() .And. QI2->QI2_FILIAL+QI2->QI2_FNC == cChaveQI2
	                If QI2->QI2_REV <> M->QI2_REV
	                	lRevisao := .T.
	                	Exit
					Endif
					dbSkip()
				Enddo
			Endif
		Endif
		
		dbSetOrder(nOrdQI2)
		dbGoTo(nRegQI2)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o usuario corrente podera fazer manutencoes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc <> 1 .And. nOpc <> 5		// Visualizar ou Excluir
			// Ponto de entrada para liberar alteracao e inclusao de Plano de Acao na FNC por usuarios que nao sejam o Responsavel pela FNC
			If ExistBlock('QN040AUT')
				lAutorizado := ExecBlock('QN040AUT',.F., .F.,{cMatFil,cMatCod})
			Else
				If (( QI2->QI2_STATUS == "1" .And. cMatFil+cMatCod <> QI2->QI2_FILMAT+QI2->QI2_MAT .And. cMatFil+cMatCod <> QI2->QI2_FILRES+QI2->QI2_MATRES) .Or. ;
					( QI2->QI2_STATUS <> "1" .And. cMatFil+cMatCod <> QI2->QI2_FILRES+QI2->QI2_MATRES )) .AND. !lUsrAlter
					lAutorizado := .F.
					nOpc := 1
				Endif
				If nOpc == 4 .And. !Empty(QI2->QI2_CONREA)  //
					lAutorizado := .F.
					nOpc := 1
				Endif
			Endif		
		ElseIf nOpc == 5		// Excluir
			If ExistBlock("QNCDELFNC")
				lAutorizado := ExecBlock("QNCDELFNC", .F., .F.)
				If ValType(lAutorizado) <> "L"
					lAutorizado := cMatFil+cMatCod = QI2->QI2_FILMAT+QI2->QI2_MAT .OR. cMatFil+cMatCod = QI2->QI2_FILRES+QI2->QI2_MATRES
				Endif
			Else
				lAutorizado := cMatFil+cMatCod = QI2->QI2_FILMAT+QI2->QI2_MAT .OR. cMatFil+cMatCod = QI2->QI2_FILRES+QI2->QI2_MATRES
			Endif
			If ! lAutorizado .Or. QI2->QI2_STATUS <> "1"
				lAutorizado := .F.
				nOpc := 1
			Endif
	    Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o usuario corrente podera alterar descricoes das etapas do Plano de Acao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpcAcao == 4 .And. QI2->QI2_OBSOL <> "S" .And. lMvQncAEta
			If !lAutorizado
				If QN030VdAlt(QI2->QI2_FILIAL,QI2->QI2_CODACA,QI2->QI2_REVACA)
					lAltEta:= .T.
				EndIf
			EndIf
	    EndIf
	
		If !lAutorizado
			If nOpcAcao == 4 .And. !Empty(QI2->QI2_CONREA)
				MsgAlert(OemToAnsi(STR0030)+Chr(13)+;	// "Ficha de Nao-Conformidade ja baixada, impossivel alterar os Dados,"
							OemToAnsi(STR0022))				// "a Ficha de Nao-Conformidades sera apenas visualizada."
				nOpc := 1
			Else
				MsgAlert(OemToAnsi(STR0021)+Chr(13)+;	// "Usuario nao autorizado a fazer Manutencao nesta Ficha de Ocorrencias/Nao-conformidades,"
				OemToAnsi(STR0022))				// "a Ficha de Ocorrencias/Nao-conformidades sera apenas visualizada."
			   nOpc := 1
			Endif
		Endif
	EndIf

	FWExecView(STR0032, "QNCA340", nOpc,,,,,,{||Q340VTPMS()})

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QNC340ACAO()
nclusao de Acao Corretiva atraves da Ficha Nao-Conformidade.
@author Luiz Henrique Bourscheid
@since 29/06/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function QNC340ACAO()
	Local nOpcAcao := 7
	Local nRegAcao := 0
	Local nOpcQI3  := 0
	Local nRegQI2  := QI2->(Recno())
	Local nOrdQI2  := QI2->(IndexOrd())
	Local cStatusPlano := AllTrim(GetMv("MV_QNCSFNC",.F.,"3")) 
	Local lRet     := .T.
	Local lAut	   := .F.
	Local oModel   := FWModelActive() 
		
	Private aRotina := { {"","",0,1}, {"","",0,2}, {"","",0,3},{"","",0,4} }
	
	If Empty(M->QI2_CODACA+M->QI2_REVACA) .and. oModel:GetOperation() <> MODEL_OPERATION_VIEW
		
		// Ponto de entrada para liberar alteracao e inclusao de Plano de Acao na FNC por usuarios que nao sejam o Responsavel pela FNC
		If ExistBlock('QN040AUT')
			lAut := ExecBlock('QN040AUT',.F., .F.,{cMatFil,cMatCod})
		Endif	
	
		// Caso seja diferente de 3-Procede e diferente de responsavel nao deixa cadastrar Acao Corretiva
		If !(M->QI2_STATUS $ cStatusPlano .And. cMatFil+cMatCod == M->QI2_FILRES+M->QI2_MATRES) .And. !lAut
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ So podera gerar a Acao Corretiva se a Ficha Proceder ³
			//³ ou se o Usuario logado for diferente do responsavel  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Help(" ",1,"QNC040NCAC")
			Return 
		Endif
	Else
		nOpcAcao := 1
		dbSelectArea("QI3")
		dbSetOrder(2)
		If !dbSeek(xFilial("QI3")+M->QI2_CODACA+M->QI2_REVACA)
			Return
		Endif
		nRegAcao := QI3->(Recno())
		dbSetOrder(1)
	Endif

	If GetMv("MV_QTMKPMS",.F.,1) == 2
		nOpcAcao := 4
		lAltEta  :=.T.
	Endif

	If Existblock ("QNC040PL")
		Execblock ("QNC040PL",.F.,.F.)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada "QNC040VPL" criado para permitir ou não o uso do botão    ³
	//³ Plano de ação.  QNC040VPL Ret = .T. abre plano de ação, .F. não abre       ³
	// Default = .T.															   ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If Existblock ("QNC040VPL")
		Lret := Execblock ("QNC040VPL",.F.,.F.)
	Endif
	
	if Lret	 
		nOpcQI3 := QNC330Alt("QI3",nRegAcao,nOpcAcao,lAltEta) //QNC330Alt("QI3", , 7)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se houve Inclusao de Acao Corretiva e atualiza flag ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcQI3 == 0 .And. nOpcAcao == 7
		lAcaoNova := .T.
		cQI3_Cod := QI3->QI3_CODIGO
		cQI3_Rev := QI3->QI3_REV
	Endif
	
	dbSelectArea("QI2")
	dbSetOrder(nOrdQI2)
	dbGoto(nRegQI2)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Q340Docs()
Abre a tela de "Documentos Anexos"
@author Luiz Henrique Bourscheid
@since 21/05/2018
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function Q340Docs(oViewPai)
	Local oStruQIF  := FWFormStruct(2, "QIF", {|cCampo| !ALLTRIM(cCampo) $ "QIF_FNC|QIF_REV" })
	Local oView 	:= Nil
	Local oExecView := FWViewExec():New()
	Local oModel	:= oViewPai:GetModel()
	Local lRet 		:= .T.
	Local oModelQIF := oModel:GetModel("QIFDETAIL")
	Local oModelQI2 := oModel:GetModel("QI2MASTER")

	If Empty(oModelQIF:GetValue("QIF_ANEXO", 1)) .And. oModel:GetOperation() <> MODEL_OPERATION_VIEW
		oModelQIF:SetValue("QIF_ETAPA", oModelQI2:GetValue("QI2_STATUS")) 
	EndIF

	oStruQIF:SetProperty("QIF_ETAPA", MVC_VIEW_CANCHANGE, .F.)

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oView:AddGrid("FORM_QIF" , oStruQIF, "QIFDETAIL")
	
	oView:CreateHorizontalBox("BOXFORM_QIF", 100)
	
	oView:SetOwnerView('FORM_QIF','BOXFORM_QIF')
	
	oView:EnableTitleView('FORM_QIF' , OemToAnsi(STR0016) )
	
	oView:addIncrementField("FORM_QIF", "QIF_SEQ")

	oView:AddUserButton(OemToAnsi(STR0095),"ANEXO",{|oView| QncAnexoMv("QIF", "QI2MASTER", "QIFDETAIL")})   // "Documentos"  //"Docs"
	
	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
	  oExecView:setModel(oModel)
	  oExecView:setView(oView)
	  oExecView:setTitle(OemToAnsi(STR0016))
	  oExecView:setOperation(oViewPai:GetOperation())
	  oExecView:setReduction(50)
	  oExecView:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})
	  oExecView:SetCloseOnOk({|| .t.})
	  oExecView:openView(.F.)
	  
	  If oExecView:getButtonPress() == VIEW_BUTTON_OK
	    lRet := .T.
	  Endif
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fTrgJusHelp()
Função que valida status 4 e apresenta help para preencher justificativa
@author Thiago Henrique Rover
@since 14/03/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function fTrgJusHelp()

	Local oModel    := FWModelActive()
	Local oModelQI2 := oModel:GetModel("QI2MASTER")
	Local lRet      := .T.

	If oModelQI2:GetValue("QI2_STATUS") == "4" .And. !IsBlind()
		Help( " ", 1, "QNCJUSTHELP")
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fTrgJustif()
Função que abre a tela de Justificativa após alterar o status para 4
@author Thiago Henrique Rover
@since 14/03/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function fTrgJustif()
		
	Local oModel  := FWModelActive() 
	Local oModelQI2 := oModel:GetModel("QI2MASTER")
	Local lVquaEma	:= iif(SuperGetMv( "MV_QQUAEMA" , .F. ,'') <> '',.T.,.F.)
	Local lRet      := .T.
	Local oTexto	:= NIL
	Local oFontMet	:= TFont():New("Courier New",6,0)
	Local cCodFNC1	:= ""
	Local cTexto	:= Iif(!Empty(oModelQI2:GetValue("QI2_MEMO5")), oModelQI2:GetValue("QI2_MEMO5"), "")
	Local nOpca    
	Local cAnt		:= cMotivo

	If oModelQI2:GetValue("QI2_STATUS") == "4" .And. (lVquaEma .or. cMatFil+cMatCod <> M->QI2_FILMAT+M->QI2_MAT)

		//Tela do Motivo de Nao Procede
		cCodFNC1 := M->QI2_FNC+"  "+STR0020+M->QI2_REV //"Revisao: "
	
		DEFINE MSDIALOG oDlg FROM 62,100 TO 320,610 TITLE STR0122 PIXEL //"Justificativa da classificação Não-Procede"

		@ 003, 004 TO 027, 250 LABEL STR0019 OF oDlg PIXEL //"Ficha N.C.: "
		@ 040, 004 TO 110, 250 OF oDlg PIXEL

		@ 013, 010 MSGET cCodFNC1 WHEN .F. SIZE 185, 010 OF oDlg PIXEL
	
		@ 050, 010 GET oTexto VAR cMotivo MEMO NO VSCROLL SIZE 238, 051 OF oDlg PIXEL
			
		oTexto:SetFont(oFontMet)
	
		DEFINE SBUTTON FROM 115,190 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 115,220 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg CENTERED
		
		If Empty(cMotivo) .and. nOpca == 1 // Verifica se a justificativa foi preenchida
			Alert(STR0123) //"É necessário informar a justificativa para a classificação Não-Procede."
			fTrgJustif()
		Endif
		
		If nOpca == 2
		   cMotivo := cAnt
		   lRet := .F.
		Endif
		
		If oModel:GetOperation() <> MODEL_OPERATION_DELETE .And. !Empty(cMotivo)
			oModelQI2:SetValue("QI2_MEMO5", cMotivo)
		EndIf

	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fTrgMotvRev()
Função que abre a tela de Justificativa após alterar o status para 4
@author Thiago Henrique Rover
@since 14/03/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function fTrgMotvRev()
	
	Local oModel    := FWModelActive() 
	Local oTexto	:= NIL
	Local oFontMet	:= TFont():New("Courier New",6,0)
	Local cCodFNC	:= ""
	Local lValModel := Type("oModel") == "O"
	Local nOpca
	Local cAnt      := cMemo4

		//Tela do Motivo de Revisão
		cCodFNC := QI2->QI2_FNC+"  "+STR0020+QI2->QI2_REV //"Revisao: "
		
		DEFINE MSDIALOG oDlg FROM 62,100 TO 320,610 TITLE STR0057 PIXEL //"Motivo da revisão"
		
		@ 003, 004 TO 027, 250 LABEL STR0019 OF oDlg PIXEL //"Ficha N.C.: "
		@ 040, 004 TO 110, 250 OF oDlg PIXEL

		@ 013, 010 MSGET cCodFNC WHEN .F. SIZE 185, 010 OF oDlg PIXEL
	
		@ 050, 010 GET oTexto VAR cMemo4 MEMO NO VSCROLL SIZE 238, 051 OF oDlg PIXEL
			
		oTexto:SetFont(oFontMet)
	
		DEFINE SBUTTON FROM 115,190 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 115,220 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg CENTERED
		
		If Empty(cMemo4) .and. nOpca == 1 // Verifica se o motivo da revisão foi preenchido
			Alert(STR0125) 
			fTrgMotvRev()
		Endif
		
		If nOpca == 2
		   cMemo4 := cAnt
		Endif
		
Return cMemo4