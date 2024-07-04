#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA840.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA840()
Cadastro de Eventos 

@Return 	nil
@author 	Serviços
@since 		10/09/2013
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA840()

Local oBrowse

oBrowse := FwMBrowse():New()

oBrowse:SetAlias("TEQ")

oBrowse:SetDescription(STR0001) // Cadastro de Eventos
oBrowse:DisableDetails()

//Legendas para o browse
oBrowse:Addlegend("TEQ_STATUS=='1'", "GREEN"	, STR0002) // Evento Ativo
oBrowse:Addlegend("TEQ_STATUS=='2'", "RED"	, STR0003) // Evento Inativo

oBrowse:Activate()

Return(Nil)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Cadastro de Eventos

@Return 	MenuDef
@author 	Serviços
@since 		10/09/2013
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0004 	ACTION "PesqBrw" 				OPERATION 1	ACCESS 0	// "Pesquisar"
	ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TECA840"		OPERATION 2 	ACCESS 0	// "Visualizar"
	ADD OPTION aRotina TITLE STR0006	ACTION "VIEWDEF.TECA840" 	OPERATION 3	ACCESS 0	// "Incluir"
	ADD OPTION aRotina TITLE STR0007	ACTION "VIEWDEF.TECA840"		OPERATION 4	ACCESS 0	// "Alterar"
	ADD OPTION aRotina TITLE STR0013	ACTION "At840GetLegend"		OPERATION 2 	ACCESS 0	// "Legenda"
	
Return(aRotina)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Cadastro de Eventos

@Return 	model
@author 	Serviços
@since 		10/09/2013
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel	
Local oStruTEQ 		:= FWFormStruct(1,"TEQ")
Local oStruTEY 	   	:= FWFormStruct(1,"TEY")
Local bPosValidacao	:= {|oMdl| At840Vld(oMdl) }

// Tira a obrigatoriedade do campo para prosseguir com o processo de gravação, 
// a prioridade de consistencia o VALID do campo vem antes da gravação.
oStruTEY:SetProperty("TEY_CODEVE", MODEL_FIELD_OBRIGAT, .F.)

oModel := MPFormModel():New("TECA840",/* bPreValidacao */, /*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

oModel:AddFields("TEQMASTER",/*cOwner*/,oStruTEQ, /*bPreValidacao*/, bPosValidacao, /*bCarga*/ )
oModel:AddGrid( "TEYDETAIL","TEQMASTER",oStruTEY,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/)
oModel:SetRelation( "TEYDETAIL",{{"TEY_FILIAL","xFilial('TEY')"},{"TEY_CODEVE","TEQ_CODEVE"}} ,"TEY_FILIAL+TEY_CODEVE")
oModel:SetDescription(STR0008) // Eventos

// Verificação para linhas duplicadas
oModel:GetModel( "TEYDETAIL" ):SetUniqueLine( { "TEY_CODDES" } )								  

Return(oModel)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Cadastro de Eventos

@Return 	view
@author 	Serviços
@since 		10/09/2013
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel("TECA840")  
Local oStruTEP := FWFormStruct(2,"TEQ")
Local oStruTEY := FWFormStruct(2,"TEY")

// remove o campo codigo do evento da exibição 
oStruTEY:RemoveField("TEY_CODEVE")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_TEQ",oStruTEP,"TEQMASTER")
oView:AddGrid( "VIEW_TEY",oStruTEY,"TEYDETAIL")
oView:CreateHorizontalBox("SUPERIOR", 50 )// 50 = % utilizado da tela
oView:CreateHorizontalBox("INFERIOR", 50 )
oView:SetOwnerView( "VIEW_TEQ", "SUPERIOR" )
oView:SetOwnerView( "VIEW_TEY", "INFERIOR" )

// Incrementa automaticamente o campo ao incluir uma nova linha
oView:AddIncrementField( "VIEW_TEY", "TEY_ITEM" ) 

Return(oView)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT840X3Nome(cCmpTab)

Retorna o nome do campo.  

@sample 	AT840X3Nome("TEQ_CAMPO") 
@since		11/09/2013       
@param    	cCmpTab, Campo da tabela para retorno do nome
@return 	cDesCmp, CHARACTER, nome do campo da tabela 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT840X3Nome(cCmpTab)

Local cDesCmp	:= ""
Local oModel	:= FWModelActive()
Local oMdlTEQ	:= oModel:GetModel("TEQMASTER")
Local cCampo	:= oMdlTEQ:GetValue(cCmpTab)

cDesCmp := TecTituDes( cCampo , .F. )

Return(cDesCmp)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT840CmpCons()

Cria uma janela com os campos da tabela selecionada no campo TEQ_TABELA, onde 
é possivel selecionar um campo dessa tabela.

@sample 	AT840CmpCons() 
@since		11/09/2013
@param    	cCmpTab, Campo da tabela para retorno do valor       
@return 	lOk, BOOLEAN, retorna .T. ou .F. conforme a rotina de seleção do campo

/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT840CmpCons(cCmpTab)

Local aCmpBco		:= {}
Local cQuery		:= ""
Local cConteudo	:= ""
Local cCampo		:= ""
Local lOk			:= .F.

Local oModel				//Modelo atual
Local oDlgCmp				//Dialog
Local oPanel 				//Objeto Panel
Local oFooter				//Rodapé
Local oListBox			//Grid campos
Local oOk					//Objeto Confirma 
Local oCancel				//Objeto Cancel

If !Empty(FwFldGet("TEQ_TABELA"))

	cConteudo := &(ReadVar())
	
	dbSelectArea( "SX3" )
	SX3->( dbSetOrder( 1 ) )
	SX3->( DbSeek( FwFldGet("TEQ_TABELA") ) )
	
	While SX3->( !Eof() ) .AND. AllTrim(SX3->X3_ARQUIVO) == FwFldGet("TEQ_TABELA")	
		AAdd(aCmpBco, { SX3->X3_CAMPO, TecTituDes( SX3->X3_CAMPO, .F. ) })			
		SX3->( DbSkip() )	
	End
	
	SX3->(DbCloseArea())	
	
	//	Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela 
	Define MsDialog oDlgCmp FROM 000, 000 To 200, 350 Pixel
		
	// Cria o panel principal
	@ 000, 000 MsPanel oPanel Of oDlgCmp Size 250, 340 // Coordenada para o panel
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
	
	// Criação do grid para o panel	
	oListBox := TWBrowse():New( 40,05,204,100,,{STR0009,STR0010},,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,) // Campo#Descricao	  
	oListBox:SetArray(aCmpBco) // Atrela os dados do grid com a matriz
	oListBox:bLine := { ||{aCmpBco[oListBox:nAT][1],aCmpBco[oListBox:nAT][2]}} // Indica as linhas do grid
	oListBox:bLDblClick := { ||Eval(oOk:bAction), oDlgCmp:End()} // Duplo clique executa a ação do objeto indicado
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse
	
	// Cria o panel para os botoes	
	@ 000, 000 MsPanel oFooter Of oDlgCmp Size 000, 010 // Corrdenada para o panel dos botoes (size)
	oFooter:Align   := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
		
	// Botoes para o grid auxiliar	
	@ 000, 000 Button oCancel Prompt STR0011  Of oFooter Size 030, 000 Pixel //Cancelar
	oCancel:bAction := { || lOk := .F., oDlgCmp:End() }
	oCancel:Align   := CONTROL_ALIGN_RIGHT
	
	@ 000, 000 Button oOk     Prompt STR0012 Of oFooter Size 030, 000 Pixel //Confirmar
	oOk:bAction     := { || lOk := .T.,cCampo:=aCmpBco[oListBox:nAT][1], oDlgCmp:End() } // Acao ao clicar no botao
	oOk:Align       := CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel
	
	// Ativa a tela exibindo conforme a coordenada
	Activate MsDialog oDlgCmp Centered		
		
	//Utilizar o modelo ativo para substituir os valores das variaves de memoria		
	oModel	:= FWModelActive()
	
	If INCLUI .Or. ALTERA  // Consiste para nao abrir a consulta na visualização	
		If lOk
			oModel:SetValue("TEQMASTER",cCmpTab, cCampo)		
		Else
			oModel:SetValue("TEQMASTER",cCmpTab, cConteudo)		
		EndIf	
	Else 
		lOk := .F.	
	EndIf
	
Else
	Help( "", 1, "AT840CMPCONS" ) 
EndIf
	
Return(lOk)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT840RetCons()

Retorna a variavel da memoria do model, para a consulta especifica

@sample 	AT840RetCons() 
@since		11/09/2013
@param    	cCmpTab, Campo da tabela para retorno do valor       
@return 	FwFldGet("TEQ_CAMPO"), CHARACTER, conteudo da variavel de memoria.

/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT840RetCons(cCmpTab)
Return (FwFldGet(cCmpTab))


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At840VldTab
Verifica se um campo existe no dicionario de campos SX3, e o mesmo pertence a tabela desejada.

@return	lRet		.T./.F. Se o campo existir ou nao no Dicionario SX3, conforme a tabela
@param    	cCmpTab, Campo da tabela para verificação da existencia
@sample	At840VldTab()
@since 		11/09/2013
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At840VldTab(cCmpTab)
Local lRet			:= .T.
Local oModel		:= FwModelActive()
Local nOperation	:= oModel:GetOperation()
Local aArea   	:= GetArea()
Local aAreaSX3	:= SX3->( GetArea() )
Local cCampo		:= FwFldGet(cCmpTab)

If !Empty(cCampo) .And. (nOperation == 3 .OR. nOperation == 4)
	
	SX3->(DbSelectArea("SX3"))
	SX3->( dbSetOrder( 2 ) )

	If !(SX3->(dbSeek(cCampo)) .And. SX3->X3_ARQUIVO == FwFldGet("TEQ_TABELA"))
		Help( "", 1, "AT840VLDTAB" )
		lRet := .F.		
	EndIf
	
	RestArea( aAreaSX3 )
	RestArea( aArea    )
EndIf

Return(lRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At840InitDes()

Inicializa a descrição dos campos virtuais da tabela TEY

@sample 	At840IniItDes("TEP_NOME") 
@since		13/09/2013      
@param		cNomCmp - Nome do campo que deseja a descrição da tabela TEP	 
@return 	cDescricao, CHARACTER, conteúdo da descrição 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At840InitDes(cNomCmp)

Local cDescricao	:= ""
Local oMdl 	 	:= FwModelActive()
Local oMdlGrid 	:= Nil

If oMdl:GetId()=="TECA840"
	
	oMdlGrid := oMdl:GetModel( "TEYDETAIL" )	
	
	If oMdlGrid:GetOperation()!=MODEL_OPERATION_INSERT .And. oMdlGrid:GetLine()==0
		cDescricao := Posicione("TEP",1,xFilial("TEP")+TEY->TEY_CODDES,cNomCmp)			     		
	EndIf

EndIf

Return(cDescricao)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At840Vld()

Valida a gravação dos dados dos eventos

@sample 	At840Vld(oMdl) 
@since		14/11/2013     
@param		oMdl - Model utilizado para a manipulação dos dados	 
@return 	lRet, BOOLEAN, .T. ou .F. para validar as informações 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At840Vld(oMdl)

Local lRet := (FwFldGet("TEQ_CONDIC") <> "1")

If ! lRet  
	If FwFldGet("TEQ_OPEMAT") == "3" .Or. FwFldGet("TEQ_OPEMAT") == "4"
		Help( "", 1, "AT840VLD" )	
	Else 
		lRet := .T.	
	EndIf 
EndIf 

Return(lRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At840GetLegend()

Valida a gravação dos dados dos eventos

@sample 	At840GetLegend() 
@since		14/11/2013     
@return 	Nil 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At840GetLegend()

Local oLegenda := FwLegend():New()

oLegenda:Add( "", "BR_VERDE"   , STR0002 )	// Evento Ativo
oLegenda:Add( "", "BR_VERMELHO", STR0003 )	// Evento Inativo	

oLegenda:View()		
		
oLegenda := Nil
DelClassIntf()

Return(Nil) 
