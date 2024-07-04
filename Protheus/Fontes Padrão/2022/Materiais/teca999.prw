#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "TECA999.ch"

Static oFWSheet
Static cMemo
Static lCopyPl		:= .F.
Static lMdExemplo		:= .F.	
Static cTpPlan		:= ""
Static aCelulasBlock	:= {}
Static oCharge		:= Nil
Static cRetCod	:= "" 
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA999
Planilha de Preços de Serviços
@sample 	TECA999() 
@param		Nenhum
@return	ExpL	Verdadeiro / Falso
@since		16/09/2013       
@version	P119
/*/
//------------------------------------------------------------------------------
Function TECA999()

Local oMBrowse
	
At999CadEx()
	
oMBrowse:= FWmBrowse():New() 
oMBrowse:SetAlias("ABW")
oMBrowse:SetDescription(STR0001) //"Modelo de Planilha de Preços de Serviços"
oMBrowse:AddFilter(STR0002,"ABW_ULTIMA == '1'", .F.,.T., , , , ) //"Somente última revisão"
oMBrowse:SetDBFFilter()  							
oMBrowse:Activate()
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define o menu funcional. 
@sample 	MenuDef() 
@param		Nenhum  
@return	ExpA Opções da Rotina. 
@since		16/09/2013       
@version	P11   
/*/
//------------------------------------------------------------------------------

Static Function MenuDef()  

Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TECA999" OPERATION 2 ACCESS 0  // "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TECA999" OPERATION 3 ACCESS 0  // "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TECA999" OPERATION 4 ACCESS 0  // "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TECA999" OPERATION 5 ACCESS 0  // "Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION "At999CpPl()"     OPERATION 7 ACCESS 0  // "Copiar"
Return( aRotina )


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Model
@sample 	ModelDef() 
@param		Nenhum
@return	ExpO Objeto FwFormModel 
@since		16/09/2013       
@version	P11   
/*/
//------------------------------------------------------------------------------

Static Function ModelDef()

Local oStruABW		:= FWFormStruct( 1, "ABW" )				// Estrutura ABW.
Local bCommit 		:= {|oModel| At999Cmt(oModel,aCelulasBlock)}
Local bPosValid		:= {|oModel| IIF(!lMdExemplo,At999Vld(oModel),.T.) }
Local xAux

If At999CpCCT()
	xAux := FwStruTrigger( 'ABW_FUNCAO', 'ABW_SALARI', 'Posicione("SRJ",1,xFilial("SRJ")+FwFldGet("ABW_FUNCAO"),"RJ_SALARIO")', .F. )
		oStruABW:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif

oStruABW:AddField(STR0052,STR0052,'ABW_ALTERA','L',1) // 'Alterado' ### 'Alterado'

oStruABW:AddField(STR0052,STR0052,'ABW_FAKE','N',3) // 'Alterado' ### 'Alterado'

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("TECA999",/*bPreValid*/,bPosValid,bCommit )
oModel:AddFields("ABWMASTER",/*cOwner*/,oStruABW)
oModel:SetPrimaryKey({"ABW_FILIAL","ABW_CODIGO"})
oModel:SetDescription(STR0001) //"Modelo de Planilha de Preços de Serviços" 
oModel:SetActivate( {|oModel| At999InDds( oModel ) } )
Return( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View
@sample 	ViewDef()
@param		Nenhum
@return	ExpO Objeto FwFormView 
@since		16/09/2013       
@version	P11   
/*/
//------------------------------------------------------------------------------

Static Function ViewDef() 

Local oView		:= Nil									// Interface de visualização construída	
Local oModel		:= If( At999GLoad() <> NIl, At999GLoad(), FwLoadModel("TECA999") )					// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStruABW	:= FWFormStruct(2,"ABW")				// Cria as estruturas a serem usadas na View

oView := FWFormView():New()								// Cria o objeto de View
oView:SetModel(oModel)									// Define qual Modelo de dados será utilizado
				
oView:AddField("VIEW_ABW",oStruABW,"ABWMASTER")		// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

oView:AddOtherObject("VIEW_PLAN", {|oPanel| At999Plan(oPanel,cMemo)})

oStruABW:RemoveField("ABW_INSTRU")
oStruABW:RemoveField("ABW_ALTERA")
oStruABW:RemoveField("ABW_ULTIMA")
oStruABW:RemoveField("ABW_LISTA")
oStruABW:RemoveField("ABW_FAKE")

If !At999CpCCT()
	oStruABW:RemoveField("ABW_CODAA0")
	oStruABW:RemoveField("ABW_FUNCAO")
	oStruABW:RemoveField("ABW_SALARI")
Else
	oView:AddUserButton(STR0076,"",{|oModel| At999CarPl(oModel)},,,) // "Carregar Planilha"
Endif


// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox("SUPERIOR" 	,10)		
oView:CreateHorizontalBox("INFERIOR"	,90)

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView("VIEW_ABW","SUPERIOR")
oView:SetOwnerView("VIEW_PLAN","INFERIOR")

oView:SetDescription( STR0001 ) //"Modelo de Planilha de Preços de Serviços"

oView:SetViewAction( "BUTTONCANCEL", {|| aCelulasBlock := {}  } )

oView:SetCloseOnOk({||.T.}) //fecha a tela após clicar no botao confirmar (o padrao era manter a tela aberta mesmo após a edicao)

Return( oView )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999Plan
	Monta a Planilha de cálculo para manipulação. 
@sample 	At999Plan() 
@since		10/10/2013       
@version	P11.90
@param 		oPanel, Object, Painel do Objeto oView
@param		cMemo, Caracter, Conteúdo do xml
/*/
//------------------------------------------------------------------------------
Static Function At999Plan( oPanel,cMemo  )

Local oFWLayer 
Local oList
Local oSay                                
Local oWinCampos
Local oWinPlanilha
Local oWinBloquead
Local nList	:= 1
Local aCellList	:= Array(1)
Local cXml	:= ABW->ABW_INSTRU
Local cLst := ABW->ABW_LISTA
Local bSalvar := {|| oFWSheet:Save(cGetFile(STR0009,STR0008)+'.xml') } //"Salvar Como..."
Local bAbrir := {|| cFile := cGetFile(STR0009,STR0010,,,.T.,) , IF(!empty(cFile), oFWSheet:Load(cFile),nil )  } //"Arquivo XML|*.xml","Escolha o arquivo"
Local bNovo := {||oFWSheet:Close(), oFWSheet:ReInit()}
Local bBloq	:= {|| At999BloCe(aCelulasBlock,oList)}
Local bLibera	:= {|| At999LibCe(aCelulasBlock,oList)}
Local cLista	:= ""
Local oMemo
Local cTexto := STR0011 + CHR(10) + CHR(10) +;	//A Planilha de formação de preços é utilizada para calcular o valor da prestação de serviços usando fórmulas matemáticas e rotinas em ADVPL.					
				  STR0012 + CHR(10) + CHR(10) +;	//É possível atribuir os seguinte apelidos nas células da planilha para que no orçamento de serviços sejam recuperados os valores de recursos humanos, materiais de implantação e materiais de consumo: 
				  STR0013 + CHR(10) +;	 			//TOTAL_RH - Este apelido é obrigatório e deve corresponder ao preço de venda unitário da formação do preço do recurso humano que se estiver calculando no momento.
				  STR0014 + CHR(10) +;	 			//TOTAL_MAT_IMP - Esta célula, quando presente, receberá o valor total do material de implantação estimado no orçamento de serviços para o recurso humano manipulado.
				  STR0015 + CHR(10) +;				//TOTAL_MAT_CONS - Esta célula, quando presente, receberá o valor total do material de consumo estimado no orçamento de serviços para o recurso humano manipulado.
				  STR0053 + CHR(10) +;				//TOTAL_LE_COB - Esta célula, quando presente, receberá a configuração do tipo de cobrança para o item da locação de equipamento.
				  STR0054 + CHR(10) +;				//TOTAL_LE_QUANT - Esta célula, quando presente, receberá a quantidade para o item da locação de equipamento.
				  STR0055 + CHR(10) + CHR(10) +;	//TOTAL_LE_VUNIT - Esta célula, quando presente, receberá o valor unitário para o item da locação de equipamento.
				  STR0016 + ; 						//A Planilha também permite configurar a quantidade de linhas, colunas, o tipo de célula que pode ser texto ou númerico. Através do botão ações é possível criar uma nova planilha, abrir uma planilha a partir de um arquivo xml, salvar a planilha em arquivo xml
				  STR0017 + CHR(10) + CHR(10) +;	//(guardando a quantidade de linhas, colunas, nome, alias, valores, fórmulas das células, células bloqueadas) e adicionar ou remover uma célula da lista de células liberadas ou bloqueadas para edição no orçamento de serviços conforme tipo de planilha escolhido na criação do modelo.
				  STR0018 + ;							//As células da lista liberada ou bloqueada para edição serão gravadas para que no orçamento de serviços seja possível manipular apenas as celulas liberadas para edição. Se a lista for de células bloqueadas, apenas as células da lista serão bloqueadas pra edição e todas as demais serão liberadas.
				  STR0019 + CHR(10) + CHR(10) +;	//Se a lista de células for de células liberadas, apenas as células da lista serão liberadas para edição, todas as demais serão bloqueadas.
				  STR0050 								//"Para utilizar fórmulas matemáticas ou ADVPL é necessário utilizar o sinal de igual, =, exemplo: =VAL(SOMA1("10"))+1 ou =A1+A2 ou =A1+10 ou =U_USFUNC()"

If cTpPlan == "1"
	cLista := STR0020 //"Lista Liberada"
Else
	cLista := STR0021 //"Lista bloqueada"
EndIf
//---------------------------------------
// AUXILIARES , containers, botoes, etc
//---------------------------------------
oFWLayer	:= FWLayer():New()
oFWLayer:init( oPanel, .T. )
oFWLayer:addLine( "Lin01", 22, .T. )
oFWLayer:addCollumn("Col01", 90, .T., "Lin01" )
oFWLayer:addCollumn("Col02", 10, .T., "Lin01" )
oFWLayer:addWindow("Col01", "Win01", STR0022, 100, .f., .f., {||  },"Lin01" ) //"Instrução"
oFWLayer:addWindow("Col02", "Win03", cLista, 100, .F., .f., {|| Nil } ,"Lin01")
oFWLayer:addLine( "Lin02", 78, .T. )
oFWLayer:addCollumn("Col01", 100, .T., "Lin02" )
oFWLayer:addWindow("Col01", "Win02", STR0023, 100,.F., .f., {|| Nil },"Lin02" ) //"Planilha"

oWinPlanilha	:= oFWLayer:getWinPanel("Col01"	, "Win02" ,"Lin02")
oWinCampos		:= oFWLayer:getWinPanel("Col01"		, "Win01","Lin01" )
oWinBloquead	:= oFWLayer:getWinPanel("Col02"	, "Win03","Lin01" )

oList			:= tListBox():New(0,0,{|u|if(Pcount()>0,nList:=u,nList)},aCellList,80,45,,oWinBloquead,,,,.T.)

@0.01,0.01 GET oMemo VAR cTexto OF oWinCampos MEMO size 540,52 FONT oWinCampos:oFont COLOR CLR_BLACK,CLR_HGRAY

//---------------------------------------
// PLANILHA
//---------------------------------------
oFWSheet := FWUIWorkSheet():New(oWinPlanilha,,75,15)

//adiciona menus
oFWSheet:AddItemMenu(STR0024,bNovo) //"Novo"
oFWSheet:AddItemMenu(STR0025,bAbrir) //"Abrir"
oFWSheet:AddItemMenu(STR0026,bSalvar) //"Salvar"
oFWSheet:AddItemMenu('-------------------') //"-------------------"
oFWSheet:AddItemMenu(STR0027,bBloq) //"Adicionar na Lista"
oFWSheet:AddItemMenu(STR0028,bLibera) //"Remover da Lista"
oFwSheet:SetMenuVisible(.T.,STR0029,50) //"Ações"

If MethIsMemberOf(oFWSheet,"ShowAllErr")
	oFWSheet:ShowAllErr(.F.)
EndIf

If !Empty(cMemo)
	At999CList(oList)
	If isBlind()
		oFWSheet:LoadXmlModel(cMemo)
	Else
		FwMsgRun(Nil,{|| oFWSheet:LoadXmlModel(cMemo)}, Nil, STR0056)//"Carregando..."
	EndIf
	oFWSheet:Refresh(.T.)
	lCopyPl := .F.
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999Cmt
	Realizar a gravação dos dados
@sample 	At999Cmt() 
@since		10/10/2013       
@version	P11.90
@param	 	oModel, Object, Classe do modelo de dados MpFormModel
@param		aCelulasBlock, Array, lista com as células adicionadas na lista.
@return	.T.
/*/
//------------------------------------------------------------------------------
Function At999Cmt(oModel,aCelulasBlock)

Local oMdlAbw := oModel:GetModel("ABWMASTER")
Local cCodP	:= oMdlAbw:GetValue("ABW_CODIGO")
Local bAfter	:= {|oModel,cID,cAlia| IIF(!lMdExemplo,At999GrvD(oModel,cID,cAlia),.T.)}
Local cRecno	:= ABW->(Recno())
Local cRevisa	:= ""
Local lRet		:= .T.

oModel:lModify := .T.

If lCopyPl
	oMdlAbw:SetValue("ABW_REVISA","001")
EndIf

If lRet .And. oMdlAbw:GetOperation() == MODEL_OPERATION_UPDATE

	oModel:SetValue("ABWMASTER","ABW_ULTIMA","2")
			
	lNewRevis := Aviso( STR0030, STR0031, { STR0032, STR0033 }, 2 ) == 1 //"Atencao !"###"Deseja gerar uma nova revisao deste modelo de planilha ?"###"Sim"###"Nao"
		
	At999VldPl(oModel)
		
	If lNewRevis
		cRevisa := Soma1( At999VfRev())
		At999NewRe(oModel,"ABWMASTER",cRevisa, aCelulasBlock)
		At999AlMem(oModel,aCelulasBlock)
		At999DesFl(cRecno)
	Else
		oModel:SetValue("ABWMASTER","ABW_ULTIMA","1")
		At999AlMem(oModel,aCelulasBlock, .f.)
		FWFormCommit(oModel,/*bBefore*/,bAfter,NIL)
		oMdlAbw:SetValue("ABW_ALTERA",.F.)
	EndIf
	
ElseIf lRet .And. oMdlAbw:GetOperation() == MODEL_OPERATION_INSERT
	
	oModel:SetValue("ABWMASTER","ABW_ULTIMA","1")
	At999AlMem(oModel,aCelulasBlock, .F.)
	FWFormCommit(oModel,/*bBefore*/,bAfter,NIL)
	oMdlAbw:SetValue("ABW_ALTERA",.F.)
	lMdExemplo := .F.

	oModel:SetValue("ABWMASTER","ABW_ULTIMA","1")
	At999AlMem(oModel,aCelulasBlock, .F.)
	FWFormCommit(oModel,/*bBefore*/,bAfter,NIL)
	oMdlAbw:SetValue("ABW_ALTERA",.F.)
	lMdExemplo := .F.
	
ElseIf oMdlAbw:GetOperation() == MODEL_OPERATION_DELETE
	
	nOpcDel	:=	Aviso(STR0034 ,STR0035 +CRLF+ STR0036,{STR0037,STR0038},3)  //"Selecione a opção desejada" ,"Deseja excluir todas as revisões desta planilha "#" ou somente a revisão atual?",##"Todas"##"Atual"
							
	Do Case
		Case (nOpcDel == 1) // exclui todas as revisões do modelo de planilha
			At999DelTd(cCodP)
		Case (nOpcDel == 2) // exclui somente esta revisão
			FWFormCommit( oModel )
			At999RetRv(cCodP)
	EndCase
						
EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999GrvD
	Realizar a gravação do xml da planilha para o campo memo
@sample 	At999GrvD() 
@since		10/10/2013       
@version	P11.90
@param  	oModel, Objeto, 
@param  	cId, Caracter, 
@param  	cAlia, Caracter, 
/*/
//------------------------------------------------------------------------------
Function At999GrvD(oModel,cId,cAlia)

Local cPlan := ""

cPlan := oFWSheet:GetModel():GetXmlData()

RecLock(cAlia,.F.)
ABW->ABW_INSTRU := cPlan
ABW->(MsUnlock())
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999InDds
	Validação para excecutar o oModel	
@sample 	At999InDds() 
@since		10/10/2013       
@version	P11.90
@param	 	oModel, Object, Classe do modelo de dados MpFormModel
/*/
//------------------------------------------------------------------------------
Function At999InDds(oModel)

Local aArea	:= GetArea()
Local oMdlAbw := oModel:GetModel("ABWMASTER")
Local cPerg	:= "TECA999"
Local nFator	:= Randomize(0, 100)

If oMdlAbw:GetOperation() == MODEL_OPERATION_UPDATE
	oMdlAbw:SetValue("ABW_FAKE",nFator)
Endif

If oMdlAbw:GetOperation() != MODEL_OPERATION_INSERT .OR. lCopyPl
	DbSelectArea("ABW")
	DbSetOrder(1)
	If DbSeek(xFilial("ABW")+ABW->ABW_CODIGO+ABW->ABW_REVISA)
		cMemo := oMdlAbw:GetValue("ABW_INSTRU")
		cTpPlan := oMdlAbw:GetValue("ABW_TPMODP")
	EndIf
Else
	Pergunte(cPerg)
	cTpPlan := Alltrim(STR(MV_PAR01))
	oModel:SetValue("ABWMASTER","ABW_TPMODP",cTpPlan)
	cMemo	:= ""
EndIf
If (oMdlAbw:GetOperation() != MODEL_OPERATION_VIEW) .AND. (oMdlAbw:GetOperation() != MODEL_OPERATION_DELETE)
	oModel:lModify := .T.
EndIf
RestArea(aArea)
Return (cMemo)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999VldPl
	Validação de alteração da planilha	
@sample 	At999VldPl() 
@since		10/10/2013       
@version	P11.90
@param	 	oModel, Object, Classe do modelo de dados MpFormModel
/*/
//------------------------------------------------------------------------------
Function At999VldPl(oModel)

Local oMdlAbw := oModel:GetModel("ABWMASTER")

If cMemo <> oFWSheet:GetXmlModel(,,,,.F.,.T.,.F.)
	oMdlAbw:SetValue("ABW_ALTERA",.T.)
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999BloCe
	Adiciona as células no objeto oList
@sample 	At999BloCe() 
@since		14/10/2013       
@version	P11.90
@param		aCelulasBlock, Array, lista com as células adicionadas na lista
@param	 	oModel, Object, Classe do modelo de dados MpFormModel
/*/
//------------------------------------------------------------------------------
Static Function At999BloCe(aCelulasBlock,oList)

Local nPosCel := 0

nPosCel := Ascan(aCelulasBlock,{|x| alltrim(x) == alltrim(oFwSheet:cCellSelec) })

If nPosCel == 0
	aAdd(aCelulasBlock, oFwSheet:cCellSelec)
	oList:Insert(oFwSheet:cCellSelec,Len(aCelulasBlock))
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999LibCe
	Remove as células do objeto oList
@sample 	At999LibCe() 
@since		10/10/2013       
@version	P11.90
@param		aCelulasBlock, Array, lista com as células adicionadas na lista
@param		oList, Object, Classe do TListBox
/*/
//------------------------------------------------------------------------------
Static Function At999LibCe(aCelulasBlock,oList)

Local nPosCel := 0

nPosCel := Ascan(aCelulasBlock,{|x| alltrim(x) == alltrim(oFwSheet:cCellSelec) })
If nPosCel > 0
	aDel(aCelulasBlock,nPosCel)
	aSize(aCelulasBlock,Len(aCelulasBlock)-1)
	oList:Del(nPosCel)
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999CpPl
	Cópia do registro escolhido 
@sample 	At999CpPl() 
@since		10/10/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function At999CpPl()

Local aArea 		:= GetArea()
Local aAreaABW 	:= ABW->(GetArea())
Local lConfirma	:= .F.
Local lCancela		:= .F.
Local cCodPlan		:= ABW->ABW_CODIGO
Local cRevisa		:= ABW->ABW_REVISA
Local lRetorno		:= .T.

If lRetorno .and. ABW->(DbSeek(xFilial("ABW") + cCodPlan + cRevisa))

	nOperation	:= MODEL_OPERATION_INSERT

	oModel		:= FWLoadModel( 'TECA999' )
	lCopyPl	:= .T.
	oModel:SetOperation( nOperation ) // Inclusão
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados
	oModel:SetValue("ABWMASTER","ABW_REVISA","001")
	At999SLoad(oModel)//controle para indicar model a ser considerado
	nRet		:= FWExecView( STR0007 , 'TECA999', nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnable'Butt'ons*/, /*bCancel*/ , "At999CpPl" /*cOperatId*/, /*cToolBar*/, oModel ) //"Copiar"
	At999SLoad(Nil)
	oModel:DeActivate()
EndIf
RestArea(aAreaABW)
RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999VfRev
	Verifica ultima revisão da planilha	
@sample 	At999VfRev() 
@since		10/10/2013       
@version	P11.90
@return	cRev, Caracter, Revisão do registro
/*/
//------------------------------------------------------------------------------
Function At999VfRev()

Local aArea		:= GetArea()
Local aAreaABW	:= ABW->(GetArea())
Local cCodP		:= ABW->ABW_CODIGO
Local cRev			:= ""

DbSelectArea("ABW")
DbSetOrder(1) //ABW_FILIAL+ABW_CODIGO
If DbSeek(xFilial("ABW")+cCodP)
	While !EOF() .AND. xFilial("ABW")+cCodP == ABW->(ABW_FILIAL+ABW_CODIGO)
		cRev	:= ABW->ABW_REVISA
		ABW->(DbSkip())
	EndDo
EndIf
RestArea(aAreaABW)
RestArea(aArea)
Return cRev

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999Vld
	Validação do apelido obrigatório da planilha 	
@sample 	At999Vld(oModel) 
@since		15/10/2013       
@version	P11.90
@param		oModel, Object, Classe do modelo de dados MpFormModel
/*/
//------------------------------------------------------------------------------
Function At999Vld(oModel)
Local oMdlAbw 	:= oModel:GetModel("ABWMASTER")
Local aArea		:= GetArea()
Local lRet		:= .T.
Local nFator	:= Randomize(0, 100)
Local cMsg		:= ""

If oMdlAbw:GetOperation() == MODEL_OPERATION_UPDATE .Or. oMdlAbw:GetOperation() == MODEL_OPERATION_INSERT
	If !At999VldCel(@cMsg)
		If !Empty(cMsg)
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"",oModel:GetModel():GetId(), "",STR0030,	STR0057,'' ) //Atenção##"Encontrado problemas nas formulas"
			AtShowLog(cMsg,STR0030,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.)
			lRet := .F.
			oMdlAbw:SetValue("ABW_FAKE",nFator)
		EndIf
	EndIf
EndIf

If lRet
	If (oFWSheet:CellExists("TOTAL_RH"))
		If Empty(oFWSheet:GetCELLVALUE("TOTAL_RH"))
			Help(,, "At999Vld",,STR0051,1,0,,,,,,{STR0073}) //"A célula com o apelido TOTAL_RH não foi preenchida."##"Informe um conteúdo para dar andamento à gravação"
			lRet	:= .F.
		EndIf
	Else
		Help(,, "At999Vld",,STR0039,1,0,,,,,,{STR0073}) //"Não foi definido o apelido TOTAL_RH obrigatório do modelo de planilha"##"Informe um conteúdo para dar andamento à gravação"
		lRet	:= .F.
	EndIf
EndIf	

RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999NewRe
	Geração da nova revisão para planilha	
@sample 	At999NewRe(oModel,cModel,cRevisa) 
@since		16/10/2013       
@version	P11.90
@param		oModel, Object, Classe do modelo de dados MpFormModel
@param		cModel, Caracter, 
@param		cRevisa, Caracter, Código da revisão
/*/
//------------------------------------------------------------------------------
Function At999NewRe(oModel,cModel,cRevisa, aCellBlck)

Local aArea	:= GetArea()
Local aAreaABW	:= ABW->(GetArea())
Local cCodP	:= oModel:GetValue(cModel,"ABW_CODIGO")
Local cDesc	:= oModel:GetValue(cModel,"ABW_DESC")
Local aStruct	:= oModel:GetModel(cModel):GetStruct():aFields
Local aDados	:= oModel:GetModel(cModel):GetData()
Local aAux		:= {}
Local aCopy	:= {}
Local nX		:= 0
Local nY		:= 0
Local nCont	:= 0
Local nPosField	:= 0
Local cList := ""

Default aCellBlck := {}


cList := At999AlMem(oModel,aCellBlck, .T.)

For nX := 1 to Len(aStruct)
	aAdd(aAux,{aStruct[nX][3], aDados[nX][2] })
Next nX

aAdd(aCopy,aAux)
aAux := {}

For nY:= 1 to Len(aCopy)
	RecLock("ABW",.T.)
	For nCont := 1 To ABW->(FCount())
		Do Case
		Case ( FieldName(nCont) == "ABW_CODIGO" )
			FieldPut(nCont,cCodP) //Código da planilha
		Case ( FieldName(nCont) == "ABW_DESC" )
			FieldPut(nCont, cDesc ) //Descrição
		Case ( FieldName(nCont) == "ABW_REVISA" )
			FieldPut(nCont, cRevisa) //Revisão da planilha
		Case ( FieldName(nCont) == "ABW_INSTRU" )
			FieldPut(nCont, oFWSheet:GetModel():GetXmlData() ) //Xml da planilha
		Case ( FieldName(nCont) == "ABW_ULTIMA" )
			FieldPut(nCont, "1")
		Case (  FieldName(nCont) ==  "ABW_LISTA")
			FieldPut(nCont, cList)
		OtherWise
			nPosField := AScan(aCopy[nY], {|x| x[1] == FieldName(nCont)} )
			FieldPut(nCont,aCopy[nY][nPosField][2])
		EndCase
	Next nCont
	ABW->( MsUnLock() )
Next nY
RestArea(aAreaABW)
RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999DelTd
	Deleta todas as revisões do modelo da planilha	
@sample 	At999DelTd(cCodP) 
@since		16/10/2013       
@version	P11.90
@param		cCodP, Caracter, Código da planilha
/*/
//------------------------------------------------------------------------------
Function At999DelTd(cCodP)

DbSelectArea("ABW")
DbSetOrder(1)
If ABW->(DbSeek(xFilial("ABW")+cCodP))
	While ABW->(!EOF()) .AND. ABW->ABW_FILIAL == xFilial("ABW") .AND. ABW->ABW_CODIGO == cCodP
		RecLock( "ABW", .F. )
		ABW->( DbDelete() )
		ABW->( MsUnLock() )
		ABW->(DbSkip())
	EndDo
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999RetRv
	Marca a ultima revisão com a flag de ultima revisão			
@sample 	At999RetRv(cCodP) 
@since		16/10/2013       
@version	P11.90
@param		cCodP, Caracter, Código da planilha
/*/
//------------------------------------------------------------------------------
Function At999RetRv(cCodP)

Local aArea		:= GetArea()
Local aAreaABW 	:= ABW->(GetArea())
Local cRev 		:= At999VfRev()

DbSelectArea("ABW")
DbSetOrder(1)
If !Empty(cRev)
	If ABW->(DbSeek(xFilial("ABW") + cCodP + cRev))
		If Reclock("ABW", .F.)
			ABW->ABW_ULTIMA := "1"
			ABW->( MsUnLock() )
		EndIf
	EndIf
EndIf
RestArea(aAreaABW)
RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999DesFl
	Desabilita a flag de ultima revisão		
@sample 	At999DesFl(cRecno) 
@since		10/10/2013       
@version	P11.90
@param		cRecno, Caracter, registro posicionado
/*/
//------------------------------------------------------------------------------
Function At999DesFl(cRecno)

Local aArea		:= GetArea()
Local aAreaABW 	:= ABW->(GetArea())

ABW->(DbGoto(cRecno))
If Reclock("ABW", .F.)
	ABW->ABW_ULTIMA := "2"
	ABW->( MsUnLock() )
EndIf
ABW->(RestArea(aAreaABW))
RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999AlMem
	Atribui as células adicionadas na lista para o campo memo (ABW_LISTA)	
@sample 	At999AlMem() 
@since		18/10/2013       
@version	P11.90
@param		aCelulasBlock, Array, lista com as células adicionadas na lista
/*/
//------------------------------------------------------------------------------
Function At999AlMem(oModel,aCelulasBlock, lField)

Local aArea := GetArea()
Local nX	:= 0
Local cList	:= ""
Local oMdlABW	:= oModel:GetModel("ABWMASTER")

DEFAULT lField := .F.

For nX := 1 To Len(aCelulasBlock)
	cList	+= Alltrim(aCelulasBlock[nX])+";"
Next
If !lField 
	oMdlABW:SetValue("ABW_LISTA",cList)
EndIf
RestArea(aArea)
Return cList

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999CList
	Atualiza a lista com as células gravadas anteriormente.	
@sample 	At999CList() 
@since		18/10/2013       
@version	P11.90
@param		oList, Objeto, Classe do TLisBox
/*/
//------------------------------------------------------------------------------
Function At999CList(oList)

Local aArea := GetArea()
Local cList := ABW->ABW_LISTA
Local nX		:= 0

If !Empty(cList)
	aCelulasBlock := StrTokArr(cList,";")
	oList:Reset()
	For nX := 1 To Len(aCelulasBlock)
		oList:Insert(aCelulasBlock[nX],nX)
	Next
EndIf
RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999CadEx
	Cadastro do Modelo exemplo.	
@sample 	At999CadEx() 
@since		28/10/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function At999CadEx

Local aArea 		:= GetArea()
Local aAreaABW		:= ABW->(GetArea())
Local oModel
Local lRet 		:= .F.

DbSelectArea("ABW")
ABW->(DbSetOrder(1))

If ABW->(!DbSeek(xFilial("ABW")+'000001'))

	oModel:=FwloadModel('TECA999')
	oModel:SetOperation(3)
	oModel:Activate()

	oModel:SetValue("ABWMASTER","ABW_FILIAL",xFilial("ABW"))
	oModel:SetValue("ABWMASTER","ABW_CODIGO",'000001')
	oModel:SetValue("ABWMASTER","ABW_DESC",STR0040)  //"Modelo Exemplo"
	oModel:SetValue("ABWMASTER","ABW_REVISA","001")
	oModel:SetValue("ABWMASTER","ABW_INSTRU",At999MdExe())
	oModel:SetValue("ABWMASTER","ABW_TPMODP",cTpPlan)
	oModel:SetValue("ABWMASTER","ABW_LISTA","")

	lMdExemplo := .T.

	If lRet := oModel:VldData()
		oModel:CommitData()
	EndIf

	If !lRet

		aErro := oModel:GetErrorMessage()

		AutoGrLog( STR0041 + ' [' + AllToChar( aErro[1] ) + ']' ) //"Id do formulário de origem:"
		AutoGrLog( STR0042 + ' [' + AllToChar( aErro[2] ) + ']' ) //"Id do campo de origem: "
		AutoGrLog( STR0043 + ' [' + AllToChar( aErro[3] ) + ']' ) //"Id do formulário de erro: "
		AutoGrLog( STR0044 + ' [' + AllToChar( aErro[4] ) + ']' ) //"Id do campo de erro: "
		AutoGrLog( STR0045 + ' [' + AllToChar( aErro[5] ) + ']' ) //"Id do erro: "
		AutoGrLog( STR0046 + ' [' + AllToChar( aErro[6] ) + ']' ) //"Mensagem do erro: "
		AutoGrLog( STR0047 + ' [' + AllToChar( aErro[7] ) + ']' ) //"Mensagem da solução: "
		AutoGrLog( STR0048 + ' [' + AllToChar( aErro[8] ) + ']' ) //"Valor atribuído: "
		AutoGrLog( STR0049 + ' [' + AllToChar( aErro[9] ) + ']' ) //"Valor anterior: "

		MostraErro()

		// Desativamos o Model 
		oModel:DeActivate()
	EndIf

EndIf
RestArea(aArea)
RestArea(aAreaABW)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999MdExe
	Carrega XML do Modelo exemplo.	
@sample 	At999MdExe() 
@since		28/10/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function At999MdExe()

Local cXml := ''

cXml += '<?xml version="1.0" encoding="UTF-8"?>'
cXml += '<FWMODELSHEET Operation="4" version="1.01">'
cXml += '	<MODEL_SHEET modeltype="FIELDS" >'
cXml += '		<TOTLINES order="1">'
cXml += '			<value>75</value>'
cXml += '		</TOTLINES>'
cXml += '		<TOTCOLUMNS order="2">'
cXml += '			<value>15</value>'
cXml += '		</TOTCOLUMNS>'
cXml += '		<MODEL_CELLS modeltype="GRID" optional="1">'
cXml += '		<struct>'
cXml += '			<NAME order="1"></NAME>'
cXml += '			<NICKNAME order="2"></NICKNAME>'
cXml += '			<FORMULA order="3"></FORMULA>'
cXml += '			<VALUE order="4"></VALUE>'
cXml += '			<PICTURE order="5"></PICTURE>'
cXml += '			<BLOCKCELL order="6"></BLOCKCELL>'
cXml += '			<BLOCKNAME order="7"></BLOCKNAME>'
cXml += '		</struct>'
cXml += '		<items>'
cXml += '			<item id="1" deleted="0" ><NAME>A1</NAME><VALUE>|| - MAO - DE - OBRA</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="2" deleted="0" ><NAME>G1</NAME><VALUE>PORCENT(%)</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="3" deleted="0" ><NAME>I1</NAME><VALUE>R$</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="4" deleted="0" ><NAME>A2</NAME><VALUE>01 - SALARIO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="5" deleted="0" ><NAME>I2</NAME><VALUE>1496.43</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="6" deleted="0" ><NAME>A3</NAME><VALUE>02 - ADICIONAL DE INSALUBRIDADE MEDIA</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="7" deleted="0" ><NAME>I3</NAME><VALUE>299.29</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="8" deleted="0" ><NAME>A4</NAME><VALUE>TOTAL DAS REMUNERACOES</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="9" deleted="0" ><NAME>I4</NAME><FORMULA>=(I2+I3)</FORMULA><VALUE>1795.72</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="10" deleted="0" ><NAME>A6</NAME><VALUE>RESERVA TECNICA</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="11" deleted="0" ><NAME>G6</NAME><VALUE>0.02</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="12" deleted="0" ><NAME>I6</NAME><FORMULA>=(I4*G6)/100</FORMULA><VALUE>0.359144</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="13" deleted="0" ><NAME>D7</NAME><VALUE>TOTAL</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="14" deleted="0" ><NAME>I7</NAME><FORMULA>=I4+I6</FORMULA><VALUE>1796.079144</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="15" deleted="0" ><NAME>A8</NAME><VALUE>II - ENCARGOS SOCIAIS: INC. S/O VALOR DA REMUNERACAO + RESERVA TECNICA.</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="16" deleted="0" ><NAME>A9</NAME><VALUE>GRUPO &quot;A&quot; - OBRIGACOES SOCIAIS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="17" deleted="0" ><NAME>G9</NAME></item>'
cXml += '			<item id="18" deleted="0" ><NAME>A10</NAME><VALUE>A1 - PREVIDENCIA SOCIALINSS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="19" deleted="0" ><NAME>G10</NAME><VALUE>20</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="20" deleted="0" ><NAME>I10</NAME><FORMULA>=(I7*G10)/100</FORMULA><VALUE>359.2158288</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="21" deleted="0" ><NAME>A11</NAME><VALUE>A2 - FGTS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="22" deleted="0" ><NAME>G11</NAME><VALUE>8</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="23" deleted="0" ><NAME>I11</NAME><FORMULA>=(I7*G11)/100</FORMULA><VALUE>143.68633152</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="24" deleted="0" ><NAME>A12</NAME><VALUE>A3 - SALARIO EDUCACAO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="25" deleted="0" ><NAME>G12</NAME><VALUE>2.5</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="26" deleted="0" ><NAME>I12</NAME><FORMULA>=(I7*G12)/100</FORMULA><VALUE>44.9019786</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="27" deleted="0" ><NAME>A13</NAME><VALUE>A4 - SESC</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="28" deleted="0" ><NAME>G13</NAME><VALUE>1.5</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="29" deleted="0" ><NAME>I13</NAME><FORMULA>=(I7*G13)/100</FORMULA><VALUE>26.94118716</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="30" deleted="0" ><NAME>A14</NAME><VALUE>A5 - SENAC</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="31" deleted="0" ><NAME>G14</NAME><VALUE>1</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="32" deleted="0" ><NAME>I14</NAME><FORMULA>=(I7*G14)/100</FORMULA><VALUE>17.96079144</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="33" deleted="0" ><NAME>A15</NAME><VALUE>A6 - INCRA</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="34" deleted="0" ><NAME>G15</NAME><VALUE>0.2</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="35" deleted="0" ><NAME>I15</NAME><FORMULA>=(I7*G15)/100</FORMULA><VALUE>3.59215829</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="36" deleted="0" ><NAME>A16</NAME><VALUE>A7 - SEGURO ACIDENTE DE TRABALHO (SAT/INSS)</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="37" deleted="0" ><NAME>G16</NAME><VALUE>3</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="38" deleted="0" ><NAME>I16</NAME><FORMULA>=(I7*G16)/100</FORMULA><VALUE>53.88237432</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="39" deleted="0" ><NAME>A17</NAME><VALUE>A8 - SEBRAE</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="40" deleted="0" ><NAME>G17</NAME><VALUE>0.6</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="41" deleted="0" ><NAME>I17</NAME><FORMULA>=(I7*G17)/100</FORMULA><VALUE>10.77647486</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="42" deleted="0" ><NAME>A18</NAME><VALUE>TOTAL DO GRUPO &quot;A&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="43" deleted="0" ><NAME>G18</NAME><FORMULA>=G10+G11+G12+G13+G14+G15+G16+G17</FORMULA><VALUE>36.8</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="44" deleted="0" ><NAME>I18</NAME><FORMULA>=I10+I11+I12+I13+I14+I15+I16+I17</FORMULA><VALUE>660.95712499</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="45" deleted="0" ><NAME>A20</NAME><VALUE>GRUPO &quot;B&quot; - TEMPO DE TRABALHO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="46" deleted="0" ><NAME>A21</NAME><VALUE>B1 - FERIAS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="47" deleted="0" ><NAME>G21</NAME><VALUE>9.04</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="48" deleted="0" ><NAME>I21</NAME><FORMULA>=(I7*G21)/100</FORMULA><VALUE>162.36555462</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="49" deleted="0" ><NAME>A22</NAME><VALUE>B2 - FALTAS LEGAIS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="50" deleted="0" ><NAME>G22</NAME><VALUE>0.1</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="51" deleted="0" ><NAME>I22</NAME><FORMULA>=(I7*G22)/100</FORMULA><VALUE>1.79607914</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="52" deleted="0" ><NAME>A23</NAME><VALUE>B3 - AUSENCIA POR DOENCA</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="53" deleted="0" ><NAME>G23</NAME><VALUE>1.61</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="54" deleted="0" ><NAME>I23</NAME><FORMULA>=(I7*G23)/100</FORMULA><VALUE>28.91687422</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="55" deleted="0" ><NAME>A24</NAME><VALUE>B4 - LICENCA PARTENIDADE</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="56" deleted="0" ><NAME>G24</NAME><VALUE>0.03</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="57" deleted="0" ><NAME>I24</NAME><FORMULA>=(I7*G24)/100</FORMULA><VALUE>0.53882374</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="58" deleted="0" ><NAME>A25</NAME><VALUE>B5 - ACIDENTE DE TRABALHO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="59" deleted="0" ><NAME>G25</NAME><VALUE>0.05</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="60" deleted="0" ><NAME>I25</NAME><FORMULA>=(I7*G25)/100</FORMULA><VALUE>0.89803957</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="61" deleted="0" ><NAME>A26</NAME><VALUE>B6 - AVISO PREVIO TRABALHADO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="62" deleted="0" ><NAME>G26</NAME><VALUE>0.08</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="63" deleted="0" ><NAME>I26</NAME><FORMULA>=(I7*G26)/100</FORMULA><VALUE>1.43686332</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="64" deleted="0" ><NAME>A27</NAME><VALUE>TOTAL DO GRUPO &quot;B&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="65" deleted="0" ><NAME>G27</NAME><FORMULA>=G21+G22+G23+G24+G25+G26</FORMULA><VALUE>10.91</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="66" deleted="0" ><NAME>I27</NAME><FORMULA>=I21+I22+I23+I24+I25+I26</FORMULA><VALUE>195.95223461</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="67" deleted="0" ><NAME>A29</NAME><VALUE>GRUPO &quot;C&quot; - GRATIFICACOES</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="68" deleted="0" ><NAME>A30</NAME><VALUE>C1 - ADICIONAL DE 1/3 DE FERIAS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="69" deleted="0" ><NAME>G30</NAME><VALUE>3.01</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="70" deleted="0" ><NAME>I30</NAME><FORMULA>=(I7*G30)/100</FORMULA><VALUE>54.06198223</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="71" deleted="0" ><NAME>A31</NAME><VALUE>C2 - 13Âº SALARIO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="72" deleted="0" ><NAME>G31</NAME><VALUE>9.17</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="73" deleted="0" ><NAME>H31</NAME></item>'
cXml += '			<item id="74" deleted="0" ><NAME>I31</NAME><FORMULA>=(I7*G31)/100</FORMULA><VALUE>164.7004575</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="75" deleted="0" ><NAME>A32</NAME><VALUE>TOTAL DO GRUPO &quot;C&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="76" deleted="0" ><NAME>G32</NAME><FORMULA>=G30+G31</FORMULA><VALUE>12.18</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="77" deleted="0" ><NAME>I32</NAME><FORMULA>=I30+I31</FORMULA><VALUE>218.76243973</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="78" deleted="0" ><NAME>A34</NAME><VALUE>GRUPO &quot;D&quot; - INDENIZACOES</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="79" deleted="0" ><NAME>A35</NAME><VALUE>D1 - AVISO PREVIO INDENIZADO + FERIAS E 1/3 CONST. + 13Âº + CONTRIB. SOCIAL</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="80" deleted="0" ><NAME>G35</NAME><VALUE>1.63</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="81" deleted="0" ><NAME>I35</NAME><FORMULA>=(I7*G35)/100</FORMULA><VALUE>29.27609005</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="82" deleted="0" ><NAME>A36</NAME><VALUE>D2 - FGTS SOBRE AVISO PREVIO + 13Âº INDENIZADO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="83" deleted="0" ><NAME>G36</NAME><VALUE>0.12</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="84" deleted="0" ><NAME>I36</NAME><FORMULA>=(I7*G36)/100</FORMULA><VALUE>2.15529497</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="85" deleted="0" ><NAME>A37</NAME><VALUE>D3 - INCIDENCIA COMPENSATORIA POR DEMISSAO S/ JUSTA CAUSA</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="86" deleted="0" ><NAME>G37</NAME><VALUE>2.4</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="87" deleted="0" ><NAME>I37</NAME><FORMULA>=(I7*G37)/100</FORMULA><VALUE>43.10589946</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="88" deleted="0" ><NAME>A38</NAME><VALUE>TOTAL DO GRUPO &quot;D&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="89" deleted="0" ><NAME>G38</NAME><FORMULA>=G35+G36+G37</FORMULA><VALUE>4.15</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="90" deleted="0" ><NAME>I38</NAME><FORMULA>=I35+I36+I37</FORMULA><VALUE>74.53728448</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="91" deleted="0" ><NAME>A40</NAME><VALUE>GRUPO &quot;E&quot; - LICENCA MATERNIDADE</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="92" deleted="0" ><NAME>A41</NAME><VALUE>E1 - APROVISIONAMENTO DE FERIAS SOBRE LICENCA MATERNIDADE</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="93" deleted="0" ><NAME>G41</NAME><VALUE>0.02</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="94" deleted="0" ><NAME>I41</NAME><FORMULA>=(I7*G41)/100</FORMULA><VALUE>0.35921583</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="95" deleted="0" ><NAME>A42</NAME><VALUE>E2 - APROVISIONAMENTO 1/3 CONSTITUCIONAL FERIAS SOBRE LICENCA MATERNIDADE</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="96" deleted="0" ><NAME>G42</NAME><VALUE>0.01</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="97" deleted="0" ><NAME>I42</NAME><FORMULA>=(I7*G42)/100</FORMULA><VALUE>0.17960791</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="98" deleted="0" ><NAME>A43</NAME><VALUE>E3 - INCIDENCIA DO GRUPO &quot;A&quot; SOBRE GRUPO LICENCA MATERNIDADE</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="99" deleted="0" ><NAME>G43</NAME><VALUE>0.1</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="100" deleted="0" ><NAME>I43</NAME><FORMULA>=(I7*G43)/100</FORMULA><VALUE>1.79607914</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="101" deleted="0" ><NAME>A44</NAME><VALUE>TOTAL DO GRUPO &quot;E&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="102" deleted="0" ><NAME>G44</NAME><FORMULA>=G41+G42+G43</FORMULA><VALUE>0.13</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="103" deleted="0" ><NAME>I44</NAME><FORMULA>=I41+I42+I43</FORMULA><VALUE>2.33490288</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="104" deleted="0" ><NAME>A46</NAME><VALUE>GRUPO &quot;F&quot; - INCIDENCIA DO GRUPO &quot;A&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="105" deleted="0" ><NAME>A47</NAME><VALUE>F1 - INCIDENCIA GRUPO A X (GRUPO B + C)</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="106" deleted="0" ><NAME>G47</NAME><VALUE>8.5</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="107" deleted="0" ><NAME>I47</NAME><FORMULA>=(I7*G47)/100</FORMULA><VALUE>152.66672724</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="108" deleted="0" ><NAME>A48</NAME><VALUE>TOTAL DO GRUPO &quot;F&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="109" deleted="0" ><NAME>G48</NAME><FORMULA>=G47</FORMULA><VALUE>8.5</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="110" deleted="0" ><NAME>I48</NAME><FORMULA>=I47</FORMULA><VALUE>152.66672724</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="111" deleted="0" ><NAME>A50</NAME><VALUE>VALOR DOS ENCARGOS SOCIAIS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="112" deleted="0" ><NAME>G50</NAME><FORMULA>=G18+G27+G32+G38+G44+G48</FORMULA><VALUE>72.67</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="113" deleted="0" ><NAME>I50</NAME><FORMULA>=(I7*G50)/100</FORMULA><VALUE>1305.21071394</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="114" deleted="0" ><NAME>A52</NAME><VALUE>VALOR TOTAL DO MONTANTE &quot;A&quot;  (REMUNERACAO + RESERVA TECNICO + VALOR DOS ENCARGOS SOCIAIS)</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="115" deleted="0" ><NAME>I52</NAME><NICKNAME>TOTAL_RH</NICKNAME><FORMULA>=I7+I50</FORMULA><VALUE>3101.28985794</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '		</items>'
cXml += '		</MODEL_CELLS>'
cXml += '	</MODEL_SHEET>'
cXml += '</FWMODELSHEET>'
Return cXml

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT999GLoad
Getter do modelo 

@since 17/10/2014
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function AT999GLoad()	
Return oCharge

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999SLoad
Setter do model
@since 17/10/2014
@version 1.0
@param oModel, FormModel, Model
/*/
//------------------------------------------------------------------------------
Static Function At999SLoad(oModel)
oCharge := oModel
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999VldCel
Validação de formulas
@since 04/03/2022
@version 1.0
@param cMsgErro, String com a mensagem de erro, enviado por referencia
/*/
//------------------------------------------------------------------------------
Static Function At999VldCel(cMsgErro)
Local lRet		:= .T.
Local aCelsErro	:= {}
Local cMsgCel	:= ""
Local cMsgCel1	:= ""
Local cMsgForm	:= ""
Local cMsgForm1	:= ""
Local nX 		:= 0

If MethIsMemberOf(oFWSheet,"VldFormulas") .And. !oFWSheet:VldFormulas(aCelsErro)
	If Len(aCelsErro) > 0
		cMsgCel	:= STR0058 //"Houve Erro na seguinte celula: "
		cMsgForm := STR0059 //"e na seguinte formula "
		For nX := 1 To Len(aCelsErro)
			cMsgCel1 := CRLF + aCelsErro[nX][2] + CRLF
			cMsgForm1 := CRLF + aCelsErro[nX][1] + CRLF
			cMsgForm1 += "----------------------------------------------" + CRLF	
			cMsgErro += cMsgCel + cMsgCel1 + cMsgForm + cMsgForm1
		Next nX
	EndIf 	
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} At999ConAA0()
Construção da consulta especifica do campo ABW_CODAA0 Base Operacional

@author Kaique Schiller
@since  08/07/2022
/*/
//------------------------------------------------------------------
Function At999ConAA0()
Local lRet			:= .F.
Local oBrowse		:= Nil
Local cAls			:= "AA0REI"
Local nSuperior		:= 0
Local nEsquerda		:= 0
Local nInferior		:= 0
Local nDireita		:= 0
Local oDlgEscTela	:= Nil
Local cQry			:= At999Qry("AA0")
Local aIndex		:= {}
Local aSeek 		:= {}
Local cProfID		:= "AA0REI"  //Indica o ID do browse para recuperar as informações do usuario	

Aadd( aSeek, { STR0060, {{"","C",TamSX3("AA0_CODIGO")[1],0,STR0060,,}} } )	 // "Código" ### "Código"
Aadd( aSeek, { STR0061, {{"","C",TamSX3("AA0_DESCRI")[1],0,STR0061,,}}}) // "Descrição" ### "Descrição"

Aadd( aIndex, "AA0_CODIGO" )
Aadd( aIndex, "AA0_DESCRI")
Aadd( aIndex, "AA0_FILIAL")  // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último

IF !isBlind()
	nSuperior := 0
	nEsquerda := 0	
	nInferior := GetScreenRes()[2] * 0.6
	nDireita  := GetScreenRes()[1] * 0.65
	
	DEFINE MSDIALOG oDlgEscTela TITLE STR0062 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL // "Base Operacional x CCT"

	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oDlgEscTela)
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetAlias(cAls)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetQuery(cQry)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDescription(STR0062)  // "Base Operacional x CCT"
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetProfileID(cProfID)

	oBrowse:SetDoubleClick({ || cRetCod := (oBrowse:Alias())->AA0_CODIGO, lRet := .T. ,oDlgEscTela:End()})
	oBrowse:AddButton( OemTOAnsi(STR0063), {|| cRetCod   := (oBrowse:Alias())->AA0_CODIGO, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
	oBrowse:AddButton( OemTOAnsi(STR0064),  {||  cRetCod  := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()

	ADD COLUMN oColumn DATA { ||  AA0_CODIGO  } TITLE STR0065 SIZE TamSX3("AA0_CODIGO")[1] 	OF oBrowse //"Código"
	ADD COLUMN oColumn DATA { ||  AA0_DESCRI } 	TITLE STR0061 SIZE TamSX3("AA0_DESCRI")[1] 	OF oBrowse //"Descrição"

	oBrowse:Activate()
	ACTIVATE MSDIALOG oDlgEscTela CENTERED
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} At999ConSRJ()
Construção da consulta especifica do campo ABW_FUNCAO Função

@author Kaique Schiller
@since  08/07/2022
/*/
//------------------------------------------------------------------
Function At999ConSRJ(cCodBase)
Local lRet			:= .F.
Local oBrowse		:= Nil
Local cAls			:= "SRJRI4"
Local nSuperior		:= 0
Local nEsquerda		:= 0
Local nInferior		:= 0
Local nDireita		:= 0
Local oDlgEscTela	:= Nil
Local cQry			:= At999Qry("SRJ",cCodBase)
Local aIndex		:= {}
Local aSeek 		:= {}
Local cProfID		:= "SRJRI4"  //Indica o ID do browse para recuperar as informações do usuario	
Default cCodBase := ""

Aadd( aSeek, { STR0060, {{"","C",TamSX3("RJ_FUNCAO")[1],0,STR0060,,}} } )	// "Código" ### "Código"
Aadd( aSeek, { STR0061, {{"","C",TamSX3("RJ_DESC")[1],0,STR0061,,}}}) // "Descrição" ### "Descrição"

Aadd( aIndex, "RJ_FUNCAO" )
Aadd( aIndex, "RJ_DESC")
Aadd( aIndex, "RJ_FILIAL")  // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último

IF !isBlind()
	nSuperior := 0
	nEsquerda := 0	
	nInferior := GetScreenRes()[2] * 0.6
	nDireita  := GetScreenRes()[1] * 0.65
	
	DEFINE MSDIALOG oDlgEscTela TITLE STR0067 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL // "Função x CCT"

	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oDlgEscTela)
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetAlias(cAls)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetQuery(cQry)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDescription(STR0067)  // "Função x CCT"
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetProfileID(cProfID)

	oBrowse:SetDoubleClick({ || cRetCod := (oBrowse:Alias())->RJ_FUNCAO, lRet := .T. ,oDlgEscTela:End()})
	oBrowse:AddButton( OemTOAnsi(STR0063), {|| cRetCod   := (oBrowse:Alias())->RJ_FUNCAO, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
	oBrowse:AddButton( OemTOAnsi(STR0064),  {||  cRetCod  := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()

	ADD COLUMN oColumn DATA { ||  RJ_FUNCAO  } 	TITLE STR0068 SIZE TamSX3("RJ_FUNCAO")[1] 	OF oBrowse //"Cod. Função"
	ADD COLUMN oColumn DATA { ||  RJ_DESC } 	TITLE STR0061 SIZE TamSX3("RJ_DESC")[1] 	OF oBrowse //"Descrição"
	ADD COLUMN oColumn DATA { ||  WY_CODIGO  } 	TITLE STR0066 SIZE TamSX3("WY_CODIGO")[1] 	OF oBrowse //"Código CCT"
	ADD COLUMN oColumn DATA { ||  WY_DESC } 	TITLE STR0061 SIZE TamSX3("WY_DESC")[1] 	OF oBrowse //"Descrição"

	oBrowse:Activate()
	ACTIVATE MSDIALOG oDlgEscTela CENTERED
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} At999RetCd()
Retorno da consulta especifica

@author Kaique Schiller
@since  08/07/2022
/*/
//------------------------------------------------------------------
Function At999RetCd()
Return cRetCod

//-------------------------------------------------------------------
/*/{Protheus.doc} At999VldBs()
Validação da Base Operacional x CCT
@author Kaique Schiller
@since  11/07/2022
/*/
//------------------------------------------------------------------
Function At999VldBs(cCodBase)
Local lRet := .T. 
Local cQuery := ""
Local cAliasAA0 := ""
Default cCodBase := ""

If !Empty(cCodBase)
	cQuery := At999Qry("AA0",cCodBase)
	cAliasAA0 := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAA0,.T.,.T.)
	If (cAliasAA0)->(Eof())
		Help(,, "At999VldBs",,STR0069,1,0,,,,,,{STR0070}) //"Não existe essa base operacional atrelada na CCT."##"Realize a amarração da base operacional com a CCT."
		lRet := .F.
	Endif
	(cAliasAA0)->(DbCloseArea())
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At999VldFn()
Validação da Função x CCT
@author Kaique Schiller
@since  11/07/2022
/*/
//------------------------------------------------------------------
Function At999VldFn(cCodBase,cCodFun)
Local lRet := .T.
Local cQuery := ""
Local cAliasSRJ := ""
Default cCodBase := ""
Default cCodFun := ""

If !Empty(cCodFun)
	cQuery := At999Qry("SRJ",cCodBase,cCodFun)
	cAliasSRJ := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRJ,.T.,.T.)
	If (cAliasSRJ)->(Eof())
		Help(,, "At999VldFn",,STR0071,1,0,,,,,,{STR0072}) //"Não existe essa função atrelada na CCT."##"Realize a amarração da função com a CCT."
		lRet := .F.
	Endif
	(cAliasSRJ)->(DbCloseArea())
Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At999Qry()
Validação da Função x CCT
@author Kaique Schiller
@since  11/07/2022
/*/
//------------------------------------------------------------------
Static Function At999Qry(cTbl,cCodBase,cCodFun)
Local cQry := ""
Default cTbl := ""
Default cCodBase := ""
Default cCodFun := ""

If cTbl == "AA0"
	cQry := " SELECT AA0_FILIAL, AA0_CODIGO, AA0_DESCRI "
	cQry += " FROM " + RetSqlName("AA0") + " AA0 "
	cQry += " INNER JOIN "+ RetSQLName('REI')  + " REI ON REI_FILIAL = '" + xFilial("REI") + "' AND REI.REI_CODAA0 = AA0.AA0_CODIGO"
	cQry += " AND REI.D_E_L_E_T_ =  ' ' "
	cQry += " INNER JOIN "+ RetSQLName('SWY')  + " SWY ON SWY.WY_FILIAL = '" + xFilial("SWY") + "' AND SWY.WY_CODIGO = REI.REI_CODCCT"
	cQry += " AND SWY.D_E_L_E_T_ =  ' ' "
	cQry += " WHERE AA0.AA0_FILIAL = '" +  xFilial('AA0') + "'"
	If !Empty(cCodBase)
		cQry += " AND AA0.AA0_CODIGO = '" + cCodBase + "' "
	Endif
	cQry += " AND AA0.D_E_L_E_T_ =  ' ' "
	cQry += " GROUP BY AA0_FILIAL, AA0_CODIGO, AA0_DESCRI "
ElseIf cTbl == "SRJ"
	cQry := " SELECT RJ_FILIAL, RJ_FUNCAO, RJ_DESC, WY_CODIGO, WY_DESC "
	cQry += " FROM " + RetSqlName("SRJ") + " SRJ "
	cQry += " INNER JOIN "+ RetSQLName('RI4')  + " RI4 ON RI4_FILIAL = '" + xFilial("RI4") + "' AND RI4.RI4_CODSRJ = SRJ.RJ_FUNCAO"
	cQry += " AND RI4.D_E_L_E_T_ =  ' ' "
	cQry += " INNER JOIN "+ RetSQLName('SWY')  + " SWY ON SWY.WY_FILIAL = '" + xFilial("SWY") + "' AND SWY.WY_CODIGO = RI4.RI4_CODCCT"
	cQry += " AND SWY.D_E_L_E_T_ =  ' ' "
	If !Empty(cCodBase)
		cQry += " INNER JOIN "+ RetSQLName('REI')  + " REI ON REI_FILIAL = '" + xFilial("REI") + "' AND REI.REI_CODCCT = RI4.RI4_CODCCT"
		cQry += " AND REI.REI_CODAA0 = '" + cCodBase + "' "
		cQry += " AND REI.D_E_L_E_T_ =  ' ' "
	Endif
	cQry += " WHERE SRJ.RJ_FILIAL = '" +  xFilial('SRJ') + "'"
	If !Empty(cCodFun)
		cQry += " AND SRJ.RJ_FUNCAO = '" + cCodFun + "' "
	Endif
	cQry += " AND SRJ.D_E_L_E_T_ =  ' ' "
Endif

cQry := ChangeQuery(cQry)

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} At999CpCCT()
Verificar se existe os campos e o parametro MV_TECXRH está ativo.
@author Kaique Schiller
@since  11/07/2022
/*/
//------------------------------------------------------------------
Function At999CpCCT()
Local lRet := .F.

If SuperGetMv("MV_TECXRH",,.F.) .And. ABW->( ColumnPos('ABW_CODAA0') ) > 0 ;
								.And. ABW->( ColumnPos('ABW_FUNCAO') ) > 0 ;
								.And. ABW->( ColumnPos('ABW_SALARI') ) > 0 ;
								.And. ABW->( ColumnPos('ABW_CODTCW') ) > 0 ;
								.And. TableInDic("REI") .And. TableInDic("RI4")
	lRet := .T.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At999CarPl()
Realiza o carregamento da Planilha x CCT
@author Kaique Schiller
@since  12/07/2022
/*/
//------------------------------------------------------------------
Static Function At999CarPl(oMdl)
Local lRet := .T.
Local cXml := ""
Default oMdl := Nil

If MsgYesNo(STR0074, STR0075 )//"Ao realizar o carregamento da planilha o sistema sobrescreverá as linhas e colunas abaixo, gostaria de continuar?"##"Aviso importante"	
	cXml := At999ExePl(oMdl:GetValue("ABWMASTER","ABW_SALARI"),;
					   oMdl:GetValue("ABWMASTER","ABW_FUNCAO"),;
					   oMdl:GetValue("ABWMASTER","ABW_CODTCW"))
	oFWSheet:Close()
	oFWSheet:ReInit()
	FwMsgRun(Nil,{|| oFWSheet:LoadXmlModel(cXml)}, Nil, STR0056)//"Carregando..."
	cMemo := cXml
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999ExePl
	Carrega XML do Modelo com a CCT.	
@sample At999ExePl() 
@author Kaique Schiller
@since  12/07/2022
/*/
//------------------------------------------------------------------------------
Function At999ExePl(nSalario,cCodFun,cCodCfg)
Local cXml := ''
Local aTblConfig := {} 		  
Local nX	:= 0
Local nY	:= 0
Local nLinha := 4
Local nId	:= 8
Local cFormTotMao := ""
Local cFormTotEnc := ""
Local cFormTotIns := ""
Local cFormTotBnf := ""
Local cFormTotTaxa := ""
Local cFormTotImpos := ""
Local cFormTotCusto := ""
Local lPeri	:= .F.
Local nAba	:= 1
Local cDedBaseIr := ""
Local cFGTS		 := ""
Local cFormTotBrt := ""
Local lDedBaseIr := .F.
Local lFGTS		 := .F.
Local lFerias 	 := .F.
Local nLinTotEnc := 0
Local nPercFer	:= 0
Local nLinTotIns := 0
Local nLinTotBnf := 0
Local nLinTotTaxa := 0
Local nLinTotImpos := 0
Local nLinTotCusto := 0
Local nLinTotBrt := 0
Local nPercentual := 0
Local cFormPrcTx := ""
Local cFormPrcImp:= ""
local lTotMI := .F.
Local lTotMC := .F.
Local lTotUni := .F.
Local lTotArm := .F.
Local aInsumos := At999Insum()
Local cFormTotAux := ""
Default nSalario := 0
Default cCodFun := ""
Default cCodCfg := ""

aTblConfig := At999Array(cCodCfg)		

cXml += '<?xml version="1.0" encoding="UTF-8"?>'
cXml += '<FWMODELSHEET Operation="4" version="1.01">'
cXml += '    <MODEL_SHEET modeltype="FIELDS">'
cXml += '        <TOTLINES order="1">'
cXml += '            <value>75</value>'
cXml += '        </TOTLINES>'
cXml += '        <TOTCOLUMNS order="2">'
cXml += '            <value>15</value>'
cXml += '        </TOTCOLUMNS>'
cXml += '        <MODEL_CELLS modeltype="GRID" optional="1">'
cXml += '            <struct>'
cXml += '                <NAME order="1"></NAME>'
cXml += '                <NICKNAME order="2"></NICKNAME>'
cXml += '                <FORMULA order="3"></FORMULA>'
cXml += '                <VALUE order="4"></VALUE>'
cXml += '                <PICTURE order="5"></PICTURE>'
cXml += '                <BLOCKCELL order="6"></BLOCKCELL>'
cXml += '                <BLOCKNAME order="7"></BLOCKNAME>'
cXml += '            </struct>'
cXml += '            <items>'
cXml += '                <item id="1" deleted="0" >'
cXml += '                    <NAME>B1</NAME>'
cXml += '                    <VALUE>'+STR0077+'</VALUE>' //%Porcentagem
cXml += '                    <PICTURE>@!</PICTURE>'
cXml += '                </item>'
cXml += '                <item id="2" deleted="0" >'
cXml += '                    <NAME>C1</NAME>'
cXml += '                    <VALUE>'+STR0078+'</VALUE>' //'VALOR'
cXml += '                    <PICTURE>@!</PICTURE>'
cXml += '                </item>'
cXml += '                <item id="3" deleted="0" >'
cXml += '                    <NAME>D1</NAME>'
cXml += '                    <VALUE>'+STR0079+'</VALUE>' //'TOTAL'
cXml += '                    <PICTURE>@!</PICTURE>'
cXml += '                </item>'
cXml += '                <item id="4" deleted="0" >'
cXml += '                    <NAME>A2</NAME>'
cXml += '                    <VALUE>'+STR0080+'</VALUE>' //'MAO DE OBRA'
cXml += '                    <PICTURE>@!</PICTURE>'
cXml += '                </item>'
cXml += '                <item id="6" deleted="0" >'
cXml += '                    <NAME>A3</NAME>'
cXml += '                    <VALUE>'+STR0081+'</VALUE>' //'SALARIO'
cXml += '                    <PICTURE>@!</PICTURE>'
cXml += '                </item>'
cXml += '                <item id="7" deleted="0" >'
cXml += '                    <NAME>C3</NAME>'
cXml += '           		 <VALUE>'+cValToChar(nSalario)+'</VALUE>'
cXml += '                    <PICTURE>'+Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE"))+'</PICTURE>'
cXml += '                </item>'

For nX := 1 to Len(aTblConfig)
	For nY := 1 to Len(aTblConfig[nX])
		If aTblConfig[nX,nY,1] == "CFG_TIPOPE"
			If Val(aTblConfig[nX,nY,2]) > nAba
				cXml += '	<item id="'+cValToChar(nId)+'" deleted="0" >'
				cXml += '		<NAME>'+"A"+cValToChar(nLinha)+'</NAME>'
				cXml += '		<VALUE></VALUE>'
				cXml += '		<PICTURE>@!</PICTURE>'
				cXml += '	</item>'
				nLinha++
				nId++
				cXml += '	<item id="'+cValToChar(nId)+'" deleted="0" >'		
				cXml += '		<NAME>'+"A"+cValToChar(nLinha)+'</NAME>'
				cXml += '		<VALUE>'+At999Aba(Val(aTblConfig[nX,nY,2]))+'</VALUE>'
				cXml += '		<PICTURE>@!</PICTURE>'
				cXml += '	</item>'
				If Val(aTblConfig[nX,nY,2]) == 2
					nLinTotEnc := nLinha
				Elseif Val(aTblConfig[nX,nY,2]) == 3
					nLinTotIns := nLinha
				Elseif Val(aTblConfig[nX,nY,2]) == 4
					nLinTotBnf := nLinha
				Elseif Val(aTblConfig[nX,nY,2]) == 5
					nLinTotCusto := nLinha
				Elseif Val(aTblConfig[nX,nY,2]) == 6
					nLinTotTaxa := nLinha
				Elseif Val(aTblConfig[nX,nY,2]) == 7
					nLinTotImpos := nLinha
				Elseif Val(aTblConfig[nX,nY,2]) == 8
					nLinTotBrt := nLinha
				Endif
				If Val(aTblConfig[nX,nY,2]) <> 5
					nLinha++
				Endif
			Endif
			nAba := Val(aTblConfig[nX,nY,2])
		Elseif aTblConfig[nX,nY,1] == "CFG_NOME" .And. nAba <> 5
			cXml += '	<item id="'+cValToChar(nId)+'" deleted="0" >'		
			cXml += '		<NAME>'+"A"+cValToChar(nLinha)+'</NAME>'
			cXml += '		<VALUE>'+aTblConfig[nX,nY,2]+'</VALUE>'
			cXml += '		<PICTURE>@!</PICTURE>'
			If aTblConfig[nX,1,2] == "1" .And. Alltrim(aTblConfig[nX,5,2]) == "008" //"PERICULOSIDADE"
				lPeri := .T.
			ElseIf aTblConfig[nX,1,2] == "2" .And. Alltrim(aTblConfig[nX,5,2]) == "002" //"DED. BASE IR"
				lDedBaseIr := .T.
			ElseIf aTblConfig[nX,1,2] == "2" .And. Alltrim(aTblConfig[nX,5,2]) == "003" //"F.G.T.S"
				lFGTS := .T.
			ElseIf aTblConfig[nX,1,2] == "2" .And. Alltrim(aTblConfig[nX,5,2]) == "012" //"FERIAS"
				lFerias := .T.
			ElseIf aTblConfig[nX,1,2] == "3" .And. Alltrim(aTblConfig[nX,nY,2]) == aInsumos[1]
				lTotMI := .T.
			ElseIf aTblConfig[nX,1,2] == "3" .And. Alltrim(aTblConfig[nX,nY,2]) == aInsumos[2] 
				lTotMC := .T.
			ElseIf aTblConfig[nX,1,2] == "3" .And. Alltrim(aTblConfig[nX,nY,2]) == aInsumos[3] 
				lTotUni := .T.
			ElseIf aTblConfig[nX,1,2] == "3" .And. Alltrim(aTblConfig[nX,nY,2]) == aInsumos[4] 
				lTotArm := .T.
			Endif
			cXml += '	</item>'
		Elseif aTblConfig[nX,nY,1] == "CFG_PORCENT" .And. (nAba <> 3 .And. nAba <> 5 .And. nAba <> 8)
			cXml += '	<item id="'+cValToChar(nId)+'" deleted="0" >'		
			cXml += '		<NAME>'+"B"+cValToChar(nLinha)+'</NAME>'
			cXml += '		<VALUE>'+cValtoChar(aTblConfig[nX,nY,2])+'</VALUE>'
			cXml += '		<PICTURE>'+Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE"))+'</PICTURE>'
			cXml += '	</item>'
			If lFerias
				nPercFer := aTblConfig[nX,nY,2]
			Endif
			nPercentual := 0
			If nAba == 6
				If Empty(cFormPrcTx)
					cFormPrcTx += "B"+cValToChar(nLinha)
				Else
					cFormPrcTx += "+B"+cValToChar(nLinha)
				Endif
				If aTblConfig[nX,nY,2] > 0
					nPercentual := aTblConfig[nX,nY,2]
				Endif
			Elseif nAba == 7
				If Empty(cFormPrcImp)
					cFormPrcImp += "B"+cValToChar(nLinha)
				Else
					cFormPrcImp += "+B"+cValToChar(nLinha)
				Endif
				If aTblConfig[nX,nY,2] > 0
					nPercentual := aTblConfig[nX,nY,2]
				Endif
			Endif
		Elseif aTblConfig[nX,nY,1] == "CFG_VALOR" .And. nAba <> 5 .And. nAba <> 8
			cXml += '	<item id="'+cValToChar(nId)+'" deleted="0" >'		
			cXml += '<NAME>'+"C"+cValToChar(nLinha)+'</NAME>'
			If !Empty(aTblConfig[nX,6,2])
				cXml += '<NICKNAME>'+aTblConfig[nX,6,2]+'</NICKNAME>'
			Endif
			If nAba == 1
				If lPeri
					cXml += '<VALUE>'+"=(B"+cValToChar(nLinha)+"*(C3"+cFormTotMao+"))/100"+'</VALUE>'
					lPeri := .F.
				Else
					cXml += '<VALUE>'+"=(B"+cValToChar(nLinha)+"*C3)/100"+'</VALUE>'
				Endif
			Elseif nAba == 2
				If lDedBaseIr
					cDedBaseIr := "C"+cValToChar(nLinha)
					lDedBaseIr := .F.
				Elseif lFGTS
					cFGTS := "C"+cValToChar(nLinha)
					lFGTS := .F.
				Endif
				If lFerias .And. nPercFer == 0
					cXml += '<VALUE>'+"=("+cFGTS+"+"+cDedBaseIr+")"+'</VALUE>'
					lFerias := .F.
					nPercFer := 0
				Else
					cXml += '<VALUE>'+"=(B"+cValToChar(nLinha)+"*D2)/100"+'</VALUE>'
				Endif
			Elseif nAba == 3
				cXml += '<VALUE>'+cValtoChar(aTblConfig[nX,nY,2])+'</VALUE>'
				If lTotMI
					cXml += '<NICKNAME>TOTAL_MI</NICKNAME>'
					lTotMI := .F.
				Elseif lTotMC
					cXml += '<NICKNAME>TOTAL_MC</NICKNAME>'
					lTotMC := .F.
				Elseif lTotUni
					cXml += '<NICKNAME>TOTAL_UNIF</NICKNAME>'
					lTotUni := .F.
				Elseif lTotArm
					cXml += '<NICKNAME>TOTAL_ARMA</NICKNAME>'
					lTotArm := .F.
				Endif
			Elseif nAba == 4
				cXml += '<VALUE>'+cValtoChar(aTblConfig[nX,nY,2])+'</VALUE>'
			Elseif nAba == 6 .Or. nAba == 7
				If nPercentual == 0
					cXml += '<VALUE>'+cValtoChar(aTblConfig[nX,nY,2])+'</VALUE>'
				Else
					cXml += '<VALUE>'+'=(B'+cValToChar(nLinha)+'*D'+cValtoChar(nLinTotCusto)+')/100'+'</VALUE>'
				Endif
			Endif
			cXml += '<PICTURE>'+Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE"))+'</PICTURE>'
			If nAba == 1
				cFormTotMao += "+C"+cValToChar(nLinha)
			ElseIf nAba == 2
				If !Empty(cFormTotEnc)
					cFormTotEnc += "+C"+cValToChar(nLinha)
				Else
					cFormTotEnc += "C"+cValToChar(nLinha)
				Endif
			Elseif nAba == 3
				If !Empty(cFormTotIns)
					cFormTotIns += "+C"+cValToChar(nLinha)
				Else
					cFormTotIns += "C"+cValToChar(nLinha)
				Endif
			Elseif nAba == 4
				If !Empty(cFormTotBnf)
					cFormTotBnf += "+C"+cValToChar(nLinha)
				Else
					cFormTotBnf += "C"+cValToChar(nLinha)
				Endif
			Elseif nAba == 6
				If !Empty(cFormTotTaxa)
					cFormTotTaxa += "+C"+cValToChar(nLinha)
				Else
					cFormTotTaxa += "C"+cValToChar(nLinha)
				Endif
			Elseif nAba == 7
				If !Empty(cFormTotImpos)
					cFormTotImpos += "+C"+cValToChar(nLinha)
				Else
					cFormTotImpos += "C"+cValToChar(nLinha)
				Endif
			Endif
			cXml += '	</item>'
		Endif
		nId++
	Next nY
	nLinha++
Next nX

cXml += '                <item id="5" deleted="0" >'
cXml += '					 <NICKNAME>TOTAL_RH</NICKNAME>'
cXml += '                    <NAME>D2</NAME>'
cXml += '                    <FORMULA>=C3'+cFormTotMao+'</FORMULA>'
cXml += '                    <PICTURE>'+Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE"))+'</PICTURE>'
cXml += '                </item>'
cFormTotCusto += 'D2'

If !Empty(cFormTotEnc) .And. nLinTotEnc <> 0
	cXml += '	<item id="'+cValToChar(nId++)+'" deleted="0" >'		
	cXml += '					 <NICKNAME>TOTAL_ENCARGOS</NICKNAME>'
	cXml += '                    <NAME>D'+cValtoChar(nLinTotEnc)+'</NAME>'
	cXml += '                    <FORMULA>='+cFormTotEnc+'</FORMULA>'
	cXml += '                    <PICTURE>'+Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE"))+'</PICTURE>'
	cXml += '                </item>'
	cFormTotCusto += '+D'+cValtoChar(nLinTotEnc)
Endif

If !Empty(cFormTotIns) .And. nLinTotIns <> 0
	cXml += '	<item id="'+cValToChar(nId++)+'" deleted="0" >'		
	cXml += '					 <NICKNAME>TOTAL_INSUMOS</NICKNAME>'
	cXml += '                    <NAME>D'+cValtoChar(nLinTotIns)+'</NAME>'
	cXml += '                    <FORMULA>='+cFormTotIns+'</FORMULA>'
	cXml += '                    <PICTURE>'+Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE"))+'</PICTURE>'
	cXml += '                </item>'
	cFormTotCusto += '+D'+cValtoChar(nLinTotIns)	
Endif

If !Empty(cFormTotBnf) .And. nLinTotBnf <> 0
	cXml += '	<item id="'+cValToChar(nId++)+'" deleted="0" >'		
	cXml += '					 <NICKNAME>TOTAL_BENEF</NICKNAME>'
	cXml += '                    <NAME>D'+cValtoChar(nLinTotBnf)+'</NAME>'
	cXml += '                    <FORMULA>='+cFormTotBnf+'</FORMULA>'
	cXml += '                    <PICTURE>'+Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE"))+'</PICTURE>'
	cXml += '                </item>'
	cFormTotCusto += '+D'+cValtoChar(nLinTotBnf)
Endif

If !Empty(cFormTotCusto) .And. nLinTotCusto <> 0
	cXml += '	<item id="'+cValToChar(nId++)+'" deleted="0" >'
	cXml += '					 <NICKNAME>TOTAL_CUSTOS</NICKNAME>'
	cXml += '                    <NAME>D'+cValtoChar(nLinTotCusto)+'</NAME>'
	cXml += '                    <FORMULA>='+cFormTotCusto+'</FORMULA>'
	cXml += '                    <PICTURE>'+Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE"))+'</PICTURE>'
	cXml += '                </item>'
Endif

If !Empty(cFormTotTaxa) .And. nLinTotTaxa <> 0
	cXml += '	<item id="'+cValToChar(nId++)+'" deleted="0" >'		
	cXml += '					 <NICKNAME>TOTAL_TAXA</NICKNAME>'
	cXml += '                    <NAME>D'+cValtoChar(nLinTotTaxa)+'</NAME>'
	cXml += '                    <FORMULA>='+cFormTotTaxa+'</FORMULA>'
	cXml += '                    <PICTURE>'+Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE"))+'</PICTURE>'
	cXml += '                </item>'
Endif

If !Empty(cFormTotImpos) .And. nLinTotImpos <> 0
	cXml += '	<item id="'+cValToChar(nId++)+'" deleted="0" >'
	cXml += '					 <NICKNAME>TOTAL_IMPOSTO</NICKNAME>'
	cXml += '                    <NAME>D'+cValtoChar(nLinTotImpos)+'</NAME>'
	cXml += '                    <FORMULA>='+cFormTotImpos+'</FORMULA>'
	cXml += '                    <PICTURE>'+Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE"))+'</PICTURE>'
	cXml += '                </item>'
Endif

If nLinTotBrt <> 0
	If !Empty(cFormPrcTx)
		cFormTotAux := cFormPrcTx
	Endif	
	If !Empty(cFormPrcImp)
		cFormTotAux += +'+'+cFormPrcImp
	Endif
	If !Empty(cFormTotAux)
		cFormTotBrt := 'D'+cValtoChar(nLinTotCusto)+'/((100-('+cFormTotAux+'))/100)'
	Else
		cFormTotBrt := 'D'+cValtoChar(nLinTotCusto)
	Endif
	cXml += '	<item id="'+cValToChar(nId++)+'" deleted="0" >'
	cXml += '					 <NICKNAME>TOTAL_BRUTO</NICKNAME>'
	cXml += '                    <NAME>D'+cValtoChar(nLinTotBrt)+'</NAME>'
	cXml += '                    <FORMULA>='+cFormTotBrt+'</FORMULA>'
	cXml += '                    <PICTURE>'+Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE"))+'</PICTURE>'
	cXml += '                </item>'
Endif

cXml += '            </items>'
cXml += '        </MODEL_CELLS>'
cXml += '    </MODEL_SHEET>'
cXml += '</FWMODELSHEET>'

Return cXml

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999Array
	Realiza o preenchimento do array com as tabelas da Configuração de Planilha
@sample At999Array() 
@author Kaique Schiller
@since	13/07/2022       
/*/
//------------------------------------------------------------------------------
Static Function At999Array(cCodCfg)
Local aRet := {}
Local cTabTemp := GetNextAlias()
Local aInsumos	:= {}
Local nX := 0
Local aTblVerb := {}
Local nPorcent := 0
Local nValor   := 0
Local nTam1    := 0
Local nTam2    := 0

Default cCodCfg := ""

BeginSql Alias cTabTemp
	SELECT TCX.TCX_DESCRI, 
		   TCX.TCX_PORCEN, 
		   TCX.TCX_TIPOPE, 
		   TCX.TCX_CODTBL, 
		   TCX.TCX_TABELA,
		   TCX.TCX_ITEM
	FROM %Table:TCX% TCX
	INNER JOIN %Table:TCW% TCW ON TCW_FILIAL = %xFilial:TCW%
							AND TCW.TCW_CODIGO = TCX.TCX_CODTCW
							AND TCW.%NotDel%
	WHERE TCX.TCX_FILIAL = %xFilial:TCX%
		AND TCX.TCX_CODTCW = %Exp:cCodCfg% 
		AND TCX.%notDel%
	ORDER BY TCX.TCX_TIPOPE,TCX.TCX_ITEM
EndSql

While !(cTabTemp)->(EOF())
	nPorcent := 0
	If (cTabTemp)->TCX_TIPOPE == "2" .And. (cTabTemp)->TCX_TABELA == "2" .And. !Empty((cTabTemp)->TCX_CODTBL) .And. (cTabTemp)->TCX_PORCEN == 0
		aTblVerb := {}
		fCarrTab(@aTblVerb,AllTrim((cTabTemp)->TCX_CODTBL),dDataBase,.T.)
		nTam1 := Len(aTblVerb) // Verifica se retornou vazio
		If nTam1 > 0
			nTam2 := Len(aTblVerb[nTam1]) // Verifica total de itens retornados
			If Alltrim((cTabTemp)->TCX_CODTBL) == "S001"
				If (cTabTemp)->TCX_ITEM == "001" .And. nTam2 >= 8 //Desc INSS
					nPorcent := aTblVerb[nTam1,8]
				Elseif (cTabTemp)->TCX_ITEM == "002" .And. nTam2 >= 9 //Ded. Base IR
					nPorcent := aTblVerb[nTam1,9]
				Endif
			Elseif Alltrim((cTabTemp)->TCX_CODTBL) == "S037" .And. nTam2 >= 9 //F.G.T.S
				nPorcent := aTblVerb[nTam1,9]
			Elseif  Alltrim((cTabTemp)->TCX_CODTBL) == "S038"
				If (cTabTemp)->TCX_ITEM == "004" .And. nTam2 >=  7 //Salario Educação
					nPorcent := aTblVerb[nTam1,7]
				Elseif (cTabTemp)->TCX_ITEM == "005" .And. nTam2 >= 10 //SESI
					nPorcent := aTblVerb[nTam1,10]
				Elseif (cTabTemp)->TCX_ITEM == "006" .And. nTam2 >= 12 //SESC
					nPorcent := aTblVerb[nTam1,12]
				Elseif (cTabTemp)->TCX_ITEM == "007" .And. nTam2 >=  9 //SENAI
					nPorcent := aTblVerb[nTam1,9]
				Elseif (cTabTemp)->TCX_ITEM == "008" .And. nTam2 >= 11 //SENAC
					nPorcent := aTblVerb[nTam1,11]
				Elseif (cTabTemp)->TCX_ITEM == "009" .And. nTam2 >=  8 //INCRA
					nPorcent := aTblVerb[nTam1,8]
				Elseif (cTabTemp)->TCX_ITEM == "011" .And. nTam2 >= 13 //SEBRAE
					nPorcent := aTblVerb[nTam1,13]
				Endif
			Endif
		Endif
	Endif
	If nPorcent == 0
		nPorcent := (cTabTemp)->TCX_PORCEN
	Endif
	If !((cTabTemp)->TCX_TIPOPE == "1" .And. nPorcent == 0)
		Aadd(aRet,{ {"CFG_TIPOPE" , (cTabTemp)->TCX_TIPOPE},;
					{"CFG_NOME"   , (cTabTemp)->TCX_DESCRI},;
					{"CFG_PORCENT", nPorcent},;
					{"CFG_VALOR"  , 0 },;
					{"CFG_ITEM"   , (cTabTemp)->TCX_ITEM},;
					{"CFG_NICK"   , "" }})
	Endif
	(cTabTemp)->(DbSkip())
EndDo

(cTabTemp)->(DbCloseArea())

aInsumos := At999Insum()
For nX := 1 To Len(aInsumos)
	Aadd(aRet,{{"CFG_TIPOPE" ,"3"},;
			   {"CFG_NOME" 	 ,aInsumos[nX]},;
	  		   {"CFG_PORCENT",0},;
			   {"CFG_VALOR"	 ,0 },;
			   {"CFG_ITEM"	 ,"" },;
			   {"CFG_NICK"   ,"" }})
Next nX

cTabTemp := GetNextAlias()
BeginSql Alias cTabTemp
	SELECT TDZ_ITEM,
		   TDZ_CODSLY,
		   TDZ_TIPBEN,
		   TDZ_VLRDIF
	FROM %Table:TDZ% TDZ
	INNER JOIN %Table:TCW% TCW ON TCW_FILIAL = %xFilial:TCW%
							AND TCW.TCW_CODIGO = TDZ.TDZ_CODTCW
							AND TCW.%NotDel%
	WHERE TDZ.TDZ_FILIAL = %xFilial:TDZ%
		AND TDZ.TDZ_CODTCW = %Exp:cCodCfg% 
		AND TDZ.%notDel%
EndSql

While !(cTabTemp)->(EOF())

	Aadd(aRet,{ {"CFG_TIPOPE" , "4"},;
				{"CFG_NOME"   , Alltrim(At996aDsc((cTabTemp)->TDZ_CODSLY,(cTabTemp)->TDZ_TIPBEN,.T.))},;
				{"CFG_PORCENT", 0},;
				{"CFG_VALOR"  , Iif( Alltrim((cTabTemp)->TDZ_TIPBEN) == "VR" .Or. Alltrim((cTabTemp)->TDZ_TIPBEN) == "VA", 0 ,(cTabTemp)->TDZ_VLRDIF ) },;
				{"CFG_ITEM"   , (cTabTemp)->TDZ_ITEM},;
				{"CFG_NICK"   , (cTabTemp)->TDZ_ITEM+'_'+TDZ_TIPBEN}})
	(cTabTemp)->(DbSkip())
EndDo

(cTabTemp)->(DbCloseArea())

//Custos
Aadd(aRet,{{"CFG_TIPOPE" 	,"5"},;
			{"CFG_NOME"  	,""},;
			{"CFG_PORCENT"	,0},;
			{"CFG_VALOR"	,0 },;
			{"CFG_ITEM"	 	,"" },;
			{"CFG_NICK"  	,"" }})

cTabTemp := GetNextAlias()
BeginSql Alias cTabTemp
	SELECT TEX_VALOR, 
		   TEX_TIPOTX, 
		   TEX_TIPOPE, 
		   TEX_DESCRI
	FROM %Table:TEX% TEX
	INNER JOIN %Table:TCW% TCW ON TCW_FILIAL = %xFilial:TCW%
							AND TCW.TCW_CODIGO = TEX.TEX_CODTCW
							AND TCW.%NotDel%
	WHERE TEX.TEX_FILIAL = %xFilial:TEX%
		AND TEX.TEX_CODTCW = %Exp:cCodCfg% 
		AND TEX.%notDel%
	ORDER BY TEX.TEX_TIPOPE
EndSql

While !(cTabTemp)->(EOF())
	nPorcent := 0
	nValor := 0
	If (cTabTemp)->TEX_TIPOTX == "1"
		nValor := (cTabTemp)->TEX_VALOR
	Elseif (cTabTemp)->TEX_TIPOTX == "2"
		nPorcent := (cTabTemp)->TEX_VALOR
	Endif
	Aadd(aRet,{ {"CFG_TIPOPE" , Iif((cTabTemp)->TEX_TIPOPE == "1","6","7")},;
				{"CFG_NOME"   , (cTabTemp)->TEX_DESCRI},;
				{"CFG_PORCENT", nPorcent},;
				{"CFG_VALOR"  , nValor },;
				{"CFG_ITEM"   , ""},;
				{"CFG_NICK"   , "" }})
	(cTabTemp)->(DbSkip())
EndDo

//Total da Planilha
Aadd(aRet,{ {"CFG_TIPOPE" 	,"8"},;
			{"CFG_NOME"  	,""},;
			{"CFG_PORCENT"	,0},;
			{"CFG_VALOR"	,0 },;
			{"CFG_ITEM"	 	,"" },;
			{"CFG_NICK" 	,"" }})


(cTabTemp)->(DbCloseArea())

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999Aba
	Seleciona a Aba da tabela de Configuração de Planilha
@sample At999Aba() 
@author Kaique Schiller
@since	13/07/2022       
/*/
//------------------------------------------------------------------------------
Static Function At999Aba(nAba)
Local cRet := STR0080 //"MÃO DE OBRA"
Default nAba := 1

If nAba == 2
	cRet := STR0082 //"ENCARGOS SOCIAIS"	
Elseif nAba == 3
	cRet := STR0083 //"INSUMOS"	
Elseif nAba == 4
	cRet := STR0088 //"BENEFÍCIOS"	
Elseif nAba == 5
	cRet := STR0089 //"TOTAL DE CUSTO"
Elseif nAba == 6
	cRet := STR0090 //"TAXAS"	
Elseif nAba == 7
	cRet := STR0091 //"IMPOSTOS"	
Elseif nAba == 8	
	cRet := STR0092 //"TOTAL BRUTO"
Endif

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999Insum
	Inclusão do array de Insumos
@sample At999Insum()
@author Kaique Schiller
@since	13/07/2022       
/*/
//------------------------------------------------------------------------------
Static Function At999Insum()
Local aRet := {STR0084 ,;//"Material de Consumo"
			   STR0085 ,; //"Material de Implantação"
			   STR0086 ,; //"Uniforme"
			   STR0087 } //"Armamento"
Return aRet
