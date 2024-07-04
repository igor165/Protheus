#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "GTPA042.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA042()
Cadastro de Eventos
 
@sample	GTPA042()
 
@return	oBrowse  Retorna o Cadastro de Eventos
 
@author	Renan Ribeiro Brando -  Inovação
@since		19/05/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA042()
Local oBrowse	:= nil
Local lMV_Email := GxVldMvEmail()
Local cMsgEmail	:=	STR0035+CHR(13)+CHR(10)+;//"Não foi feita a parametrização de envio de email"
					STR0036+CHR(13)+CHR(10)+;//"Favor verificar os parametros:"
					"MV_PORSMTP"+CHR(13)+CHR(10)+;
					"MV_RELSERV"+CHR(13)+CHR(10)+;
					"MV_RELACNT"+CHR(13)+CHR(10)+;
					"MV_RELPSW" +CHR(13)+CHR(10)+;
					"MV_RELAUSR"+CHR(13)+CHR(10)+;
					"MV_RELAUTH"+CHR(13)+CHR(10)+;
					"MV_RELTIME"+CHR(13)+CHR(10)+;
					"MV_RELSSL" +CHR(13)+CHR(10)+;
					"MV_RELTLS" 

If lMV_Email .or. (!lMV_Email .and. FwAlertYesNo(cMsgEmail,STR0014))//"Atenção!!!"
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GZ8")
	oBrowse:SetDescription(STR0001)  // "Cadastro de Eventos"
	oBrowse:DisableDetails()
	oBrowse:Activate()
Endif

Return oBrowse

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com opções do menu
 
@author	Renan Ribeiro Brando -  Inovação
@since		19/05/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002	ACTION "VIEWDEF.GTPA042" OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0003    ACTION "VIEWDEF.GTPA042" OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.GTPA042" OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.GTPA042" OPERATION 5 ACCESS 0 // Excluir

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author	Renan Ribeiro Brando -  Inovação
@since		19/05/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruGZ8  := FWFormStruct(1,"GZ8") // Eventos
Local oStruGZ7  := FWFormStruct(1,"GZ7") // Destinatários - Grupos
Local oStruGZ6  := FWFormStruct(1,"GZ6") // Grupos 
Local oStruGZ4  := FWFormStruct(1,"GZ4") // Eventos - Destinatários
Local oStruGY5	:= FWFormStruct(1,"GY5") // Regra Pai
Local oStruGY6	:= FWFormStruct(1,"GY6") // Regra Filho
Local oStruGY7	:= FWFormStruct(1,"GY7") // Campos Regra
Local bPosValid	:= {|oModel| GTPA042Pos(oModel)}
Local oModel	:= MPFormModel():New("GTPA042",/*bPreValidMdl*/, bPosValid,/*bCommit*/, /*bCancel*/ )
Local bPreLine  	:= { |oModel,nLine,cAction,cField,uValue| GA282LinePre(oModel,nLine,cAction,cField,uValue)}
Local xAux    

// Gatilho do Destinatário               
oStruGZ4:AddTrigger('GZ4_CODDES'  , ;     // [01] Id do campo de origem
					'GZ4_CODDES'  , ;     // [02] Id do campo de destino
		 			{ || .T. }    , ; 	  // [03] Bloco de codigo de validação da execução do gatilho
		 			{ |oGridGZ4| GA042TrigDest(oGridGZ4) } ) // [04] Bloco de codigo de execução do gatilho

// Gatilho do Grupo               
oStruGZ6:AddTrigger('GZ6_CODIGO'  , ;     // [01] Id do campo de origem
					'GZ6_CODIGO'  , ;     // [02] Id do campo de destino
		 			{ || .T. }    , ; 	  // [03] Bloco de codigo de validação da execução do gatilho
		 			{ |oFieldGZ6| GA042TrigGru(oFieldGZ6) } ) // [04] Bloco de codigo de execução do gatilho

// Gatilho dos campos
xAux := FwStruTrigger( 'GY7_CAMPO', 'GY7_DESCRI', ' GTPX3TIT(M->GY7_CAMPO)', .F. )
oStruGY7:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

oStruGZ4:SetProperty('GZ4_CODDES', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "GA042VldCodDest()"))
oStruGZ6:SetProperty('GZ6_CODIGO', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "EXISTCPO('GZ6')"))
oStruGZ6:SetProperty('GZ6_CODIGO', MODEL_FIELD_OBRIGAT, .F.)
oStruGZ6:SetProperty('GZ6_GRDESC', MODEL_FIELD_OBRIGAT, .F.)
oStruGZ6:SetProperty('GZ6_CODIGO', MODEL_FIELD_INIT,  {|| "" } )
oStruGZ6:SetProperty('GZ6_CODIGO', MODEL_FIELD_WHEN,  {|| .T. } )

oStruGY7:SetProperty('GY7_ENTIDA', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "GA042Entida()"))
oStruGY7:SetProperty("GY7_DESCRI"	, MODEL_FIELD_WHEN, { || EMPTY(oModel:GetModel("GRIDGY7"):GetValue('GY7_CAMPO')) .or. FwIsInCall('RUNTRIGGER')  })
oStruGY7:SetProperty("GY7_VALOR"	, MODEL_FIELD_WHEN, { || EMPTY(oModel:GetModel("GRIDGY7"):GetValue('GY7_CAMPO'))})
oStruGY7:SetProperty("GY7_CAMPO"	, MODEL_FIELD_WHEN, { || EMPTY(oModel:GetModel("GRIDGY7"):GetValue('GY7_VALOR'))})
oStruGY7:SetProperty("GY7_ENTIDA"	, MODEL_FIELD_WHEN, { || EMPTY(oModel:GetModel("GRIDGY7"):GetValue('GY7_VALOR'))})

oStruGZ4:SetProperty("GZ4_EMAIL"	, MODEL_FIELD_WHEN, { || EMPTY(oModel:GetModel("GRIDGZ4"):GetValue('GZ4_CODDES')) .or. FwIsInCall('RUNTRIGGER') })
 
oStruGZ8:SetProperty("GZ8_CODIGO"	, MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "EXISTCHAV('GZ8')"))
oStruGZ8:SetProperty('GZ8_CODIGO'   , MODEL_FIELD_INIT,  {|| GETSXENUM('GZ8', 'GZ8_CODIGO') })

oModel:AddFields('FIELDGZ8'	,			,oStruGZ8)
oModel:AddFields('FIELDGZ6'	,'FIELDGZ8'	,oStruGZ6)
oModel:AddGrid("GRIDGZ4"	,"FIELDGZ8"	,oStruGZ4)
oModel:AddGrid('TREE1'		,'FIELDGZ8'	,oStruGY5,bPreLine)
oModel:AddGrid('TREE2'		,'TREE1'	,oStruGY6)
oModel:AddGrid('GRIDGY7'	,'FIELDGZ8' ,oStruGY7)

oModel:SetRelation( 'FIELDGZ6', { { 'GZ6_FILIAL', 'xFilial( "GZ6" ) ' } , { 'GZ6_CODEVE', 'GZ8_CODIGO' } } , GZ6->(IndexKey(1)) )
oModel:SetRelation( 'GRIDGZ4' , { { 'GZ4_FILIAL', 'xFilial( "GZ4" ) ' } , { 'GZ4_CODEVE', 'GZ8_CODIGO' } } , GZ4->(IndexKey(2)) )
oModel:SetRelation( 'GRIDGY7' , { { 'GY7_FILIAL', 'xFilial( "GY7" ) ' } , { 'GY7_CODIGO', 'GZ8_CODIGO' } } , GY7->(IndexKey(1)) )
oModel:SetRelation( 'TREE1'	  , { { 'GY5_FILIAL', 'xFilial( "GY5" ) ' } , { 'GY5_CODEVE', 'GZ8_CODIGO' } } , GY5->(IndexKey(1)) )
oModel:SetRelation( 'TREE2'	  , { { 'GY6_FILIAL', 'xFilial( "GY6" ) ' } , { 'GY6_CODEVE', 'GZ8_CODIGO' },{ 'GY6_IDTREE','GY5_IDTREE' }}, GY6->(IndexKey(1)) )


oModel:GetModel('FIELDGZ6'):SetOnlyQuery(.T.)

oModel:GetModel('FIELDGZ6'):SetOptional(.T.)
oModel:GetModel('TREE1'):SetOptional(.T.)
oModel:GetModel('TREE2'):SetOptional(.T.)


oModel:GetModel('GRIDGZ4'):SetUniqueLine({"GZ4_CODDES"})  //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
oModel:GetModel('GRIDGY7'):SetUniqueLine({"GY7_ENTIDA","GY7_CAMPO","GY7_DESCRI"})

oModel:SetDescription(STR0001) // "Cadastro de Eventos"
oModel:GetModel('FIELDGZ8'):SetDescription(STR0006) //"Eventos"
oModel:GetModel('GRIDGZ4'):SetDescription(STR0007) // Destinatários
oModel:GetModel('FIELDGZ6'):SetDescription(STR0008)//"Grupos"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author	Renan Ribeiro Brando -  Inovação
@since		19/05/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView    := FWFormView():New()
Local oModel   := FwLoadModel('GTPA042')
Local oStruGZ4 := FWFormStruct(2, 'GZ4') // Eventos - Destinatários
Local oStruGZ6 := FWFormStruct(2, 'GZ6') // Grupos
Local oStruGZ7 := FWFormStruct(2, 'GZ7') // Grupos - Destinatários
Local oStruGZ8 := FWFormStruct(2, 'GZ8') // Eventos
Local oStruGY7 := FWFormStruct(2, 'GY7') // Eventos

oStruGZ6:SetProperty("GZ6_CODIGO", MVC_VIEW_LOOKUP , "GZ6")
oStruGZ4:SetProperty("GZ4_CODDES", MVC_VIEW_LOOKUP , "GZ5")

oStruGZ6:SetProperty("GZ6_CODIGO", MVC_VIEW_CANCHANGE , .T.)
oStruGZ6:SetProperty("GZ6_GRDESC", MVC_VIEW_CANCHANGE , .F.)


oStruGZ4:RemoveField("GZ4_CODEVE")
oStruGZ6:RemoveField("GZ6_CODEVE")
oStruGZ8:RemoveField("GZ8_SQL")

oView:SetModel(oModel)
oView:AddField('VIEWGZ8', oStruGZ8, 'FIELDGZ8') 
oView:AddField('VIEWGZ6', oStruGZ6, 'FIELDGZ6')
oView:AddGrid('VIEWGRIDGZ4', oStruGZ4, 'GRIDGZ4') 
oView:AddGrid('CAMPOS_REGRA', oStruGY7, 'GRIDGY7')  

oView:addUserButton(STR0009, "", {|oView| GA042ClearDest(oView)}, , , {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE})//"Limpar Dest."
oView:AddUserButton(STR0010, '', {|oModel| GA042TestMail()}, , , {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE})//"Teste Email"

oView:CreateVerticalBox( 'DIREITA' , 65)
oView:CreateVerticalBox( 'ESQUERDA', 35)
oView:CreateHorizontalBox("DIREITOSUP" , 35, "DIREITA")
oView:CreateHorizontalBox("DIREITOINF" , 65, "DIREITA")
oView:CreateHorizontalBox("ESQUERDASUP", 15, "ESQUERDA")
oView:CreateHorizontalBox("ESQUERDAINF", 85, "ESQUERDA")
oView:CreateFolder('PASTAS','DIREITOINF')
oView:AddSheet('PASTAS','PASTA1',STR0011)  //'Regras de Aplicação'
oView:CreateHorizontalBox('ID_PASTA1',100,,,'PASTAS', 'PASTA1' )
oView:AddSheet('PASTAS','PASTA2',STR0026) //"Campos"
oView:CreateHorizontalBox('ID_PASTA2',100,,,'PASTAS', 'PASTA2' )

oView:AddOtherObject("TREE_REGRA", {|oPanel| GTPA42TREE(oPanel)})

oView:AddIncrementField( 'CAMPOS_REGRA', 'GY7_SEQ' )

oView:SetOwnerView('VIEWGZ8','DIREITOSUP')
oView:SetOwnerView("TREE_REGRA"	,"ID_PASTA1")
oView:SetOwnerView('VIEWGZ6','ESQUERDASUP')
oView:SetOwnerView('VIEWGRIDGZ4','ESQUERDAINF')
oView:SetOwnerView("CAMPOS_REGRA" ,"ID_PASTA2")

oView:EnableTitleView("VIEWGZ8")
oView:EnableTitleView("VIEWGZ6")
oView:EnableTitleView("VIEWGRIDGZ4")
oView:EnableTitleView('TREE_REGRA',STR0012) //"Regra do Evento"
oView:EnableTitleView('CAMPOS_REGRA', STR0012) //"Campos"

If __cUserId == '000000' .And. dDataBase == StoD('20200814')
	oView:AddUserButton( "Automação", "Automação", {|oView| GTPA042AUT(oview)} ) 
Endif

Return oView

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA041TrigDest
Função que preenche os dados do destinatário

@sample	GA041TrigDest()

@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA042TrigDest(oGridGZ4)

oGridGZ4:SetValue("GZ4_EMAIL" , Posicione("GZ5",1,xFilial("GZ5")+oGridGZ4:GetValue("GZ4_CODDES"),"GZ5_EMAIL")) 
oGridGZ4:SetValue("GZ4_STATUS", Posicione("GZ5",1,xFilial("GZ5")+oGridGZ4:GetValue("GZ4_CODDES"),"GZ5_STATUS"))

Return


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA042TrigGru
Função que preenche os dados do grupo

@sample	GA042TrigGru()

@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA042TrigGru(oFieldGZ6)

Local oModel    := oFieldGZ6:GetModel()
Local oGridGZ4  := oModel:GetModel('GRIDGZ4')
Local cAliasGZ6 := GetNextAlias()  // Cria tabela temporária

oFieldGZ6:SetValue("GZ6_GRDESC" , Posicione("GZ6", 1, xFilial("GZ6")+FWFldGet("GZ6_CODIGO"), "GZ6_GRDESC")) 

// Começa consulta SQL na tabela temporária criada
BeginSQL Alias cAliasGZ6
	SELECT GZ7.GZ7_CODDES
		FROM %table:GZ7% GZ7
	WHERE 
		GZ7.GZ7_FILIAL = %xFilial:GZ7% AND
		GZ7.GZ7_CODGRU = %Exp: GZ6->GZ6_CODIGO %  AND 
		GZ7.%NotDel%
EndSQL

WHILE ( (cAliasGZ6)->(!Eof()) )
	// Se não houver o registro no GRID
	IF (!oGridGZ4:SeekLine({{"GZ4_CODDES", (cAliasGZ6)->GZ7_CODDES}}))
		// Se a linha ja estiver preenchida, criar uma nova lina 
		IF ( !Empty(oGridGZ4:GetValue("GZ4_CODDES")) .OR. oGridGZ4:IsDeleted() )
			oGridGZ4:AddLine()
		ENDIF
		// Preenche os campos do GRID
		oGridGZ4:SetValue("GZ4_CODDES", (cAliasGZ6)->GZ7_CODDES)
	ENDIF
 	// Pula para próxima linha do resultset
	(cAliasGZ6)->(DbSkip())
END
// Volta para primeira linha do GRID
oGridGZ4:GoLine(1)
// Fecha o alias na tabela
(cAliasGZ6)->(DbCloseArea())

Return NIL

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA042ClearDest
Limpa o GRID de destinatários

@sample GA042ClearDest()

@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Static Function GA042ClearDest(oView)
Local oModel :=  FWModelActive()
Local oGridGZ4 := oModel:GetModel("GRIDGZ4")

oGridGZ4:DelAllLine()

Return NIL

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA041VldCodDest
Valida se o destinatário existe

@sample GA041VldCodDest()
@return  lRet

@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA042VldCodDest()
Local oModel	  := FWModelActive()
Local cAliasGZ5	  := GetNextAlias()
Local oModelGZ4	  := oModel:GetModel('GRIDGZ4')
Local cCodDest	  := oModelGZ4:GetValue("GZ4_CODDES")
Local lRet		  := .T.

If (oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
	BeginSQL Alias cAliasGZ5
		SELECT 
			COUNT(*) GZ5_CODIGO
		FROM 
			%table:GZ5% GZ5 
		WHERE
			GZ5.GZ5_FILIAL = %xFilial:GZ5%
			AND GZ5.GZ5_CODIGO = %Exp:cCodDest%  
			AND GZ5.%NotDel%
	EndSQL
	// Verifica se já existe um vale aberto daquele tipo para aquele funcionário
	If (!((cAliasGZ5)->GZ5_CODIGO > 0))
		Help(,, STR0014,, STR0015, 1,0 ) // Atenção## Destinatário não existente
		lRet := .F.
	EndIf
	(cAliasGZ5)->(DbCloseArea())
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GA042TestMail
	
Envia um email de teste das regras de eventos cadastradas
@author Flavio
@since 12/07/2017
@version P12
/*/
//------------------------------------------------------------------------------
Static Function GA042TestMail()

Local oDlg		:= Nil
Local cDestinatario := Space(255)
Local lRet := .T.
Local oModel    := FwModelActive()
Local oModelGZ8 := oModel:GetModel('FIELDGZ8')
Local aEvent	:= {}
Local cQuery 	:= ""
Local cErro		:= ""
	If oModel:VldData()
		If !EMPTY(oModelGZ8:GetValue('GZ8_SQL'))
			
			DEFINE DIALOG oDlg TITLE STR0016 FROM 00,00 TO 200,250 PIXEL //"Teste de Email"
			
				oDlg:lEscClose := .F.
				
				@ 032,005 Say STR0017 of oDlg PIXEL //"Destinatário"
				@ 040,005 MsGet cDestinatario SIZE 120,11 OF oDlg PIXEL 	
							
				TButton():New(75,15,STR0018 ,oDlg,{||nOpcao:=0,oDlg:End()},50,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Enviar"
				TButton():New(75,75,STR0019 ,oDlg,{||nOpcao:=1,oDlg:End()},50,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"

			ACTIVATE MSDIALOG oDlg CENTERED

			If (nOpcao == 0)
				cQuery 	:= GTPXChgKey(oModelGZ8:GetValue('GZ8_SQL'),@cErro)
				If (at( "@", cDestinatario ) == 0)
			
					Help( ,, 'Help',"GA042TestMail", STR0020, 1, 0 )//"Email inválido"
					lRet := .F.
				ElseIf !Empty(cErro)
					lRet := .F.
					FwAlertHelp(cErro,,'GA042TestMail')
				ElseIf TCSqlExec(cQuery) < 0
					lRet := .F.
					FwAlertHelp(TCSQLError(),STR0025,'GA042TestMail')//"Preencha a tree de regra de aplicação corretamente"
				Endif	
					
					
				If lRet
					aAdd(aEvent,oModelGZ8:GetValue('GZ8_CODIGO'))
					aAdd(aEvent,oModelGZ8:GetValue('GZ8_DESEVE'))
					aAdd(aEvent,oModelGZ8:GetValue('GZ8_STATUS'))
					aAdd(aEvent,oModelGZ8:GetValue('GZ8_TITULO'))
					aAdd(aEvent,oModelGZ8:GetValue('GZ8_TEXTO'))
					aAdd(aEvent,oModelGZ8:GetValue('GZ8_RECOR'))
					
					If !(GA044SendMail(aEvent, {cDestinatario}, cQuery, /*cStyle*/, .F. )[1])
					
						Help( ,, 'Help',"GA042TestMail", STR0023, 1, 0 ) //"Falha no envio do email"
						lRet := .F.
				
					Else
						FwAlertSuccess(STR0021,STR0022 ) //"Email enviado com sucesso"##"Aviso" 
						
					Endif
				Endif	
				
			Endif
		Else
			FwAlertHelp(STR0024,STR0025) //"Query vazia!"##"Preencha a tree de regra de aplicação corretamente"
		Endif
	Else
		JurShowErro( oModel:GetErrorMessage() )
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA042Pos(oModel)

@author  jacomo.fernandes
@since   01/08/17
@version P12
/*/
//-------------------------------------------------------------------
Function GTPA042Pos(oModel)
Local lRet		:= .T.
Local oMdlTree1	:= oModel:GetModel('TREE1')
Local oMdlTree2	:= oModel:GetModel('TREE2')
Local oMdlGY7	:= oModel:GetModel('GRIDGY7')
Local oMdlGZ8   := oModel:GetModel('FIELDGZ8')
Local cQuery 	:= ""
Local cCampos	:= ""//"Select "
Local cFrom		:= ""//" From "
Local cWhere	:= ""//" Where "
Local cEnt 		:= ""
Local nX		:= 0
Local nY		:= 0
Local nZ		:= 0

If (oModel:GetOperation() == MODEL_OPERATION_INSERT  .and. !EXISTCHAV("GZ8", oMdlGZ8:GetValue("GZ8_CODIGO")))
	oModel:SetErrorMessage(oModel:GetId(),"GZ8_CODIGO",oModel:GetId(),"GZ8_CODIGO","GTPA042Pos",STR0027,STR0028+Chr(13)+Chr(10)+STR0029+Chr(13)+Chr(10)+STR0030) //"Não existe registro relacionado a este código."##"1) Informe um código que exista no cadastro"##"2)Efetue o cadastro no programa de manutenção do respectivo cadastro"##"3) Escolha um registro válido"
	lRet := .F.
EndIf

If lRet .and. ( oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE )
	For nX := 1 To oMdlTree1:Length()
		If !oMdlTree1:IsDeleted(nX)
			oMdlTree1:GoLine(nX)
			cEnt := oMdlTree1:GetValue('GY5_ENTIDA')
			If !Empty(cEnt)
				cFrom+= RetSqlName(cEnt) +' '+cEnt+','
			Endif
			For nY := 1 To oMdlTree2:Length()
				If !oMdlTree2:IsDeleted(nY) .and. !Empty(oMdlTree2:GetValue('GY6_CONDIC',nY))
					cWhere += AllTrim(oMdlTree2:GetValue('GY6_CONDIC',nY))+=" and "
				EndIf
			Next
			If !Empty(cEnt)
				cWhere+= cEnt+".D_E_L_E_T_ = ' ' and "
			Endif	
			
		Endif
	Next
	For nZ := 1 To oMdlGY7:Length()
		If !oMdlGY7:IsDeleted(nZ)
			oMdlGY7:GoLine(nZ)
			If !Empty(oMdlGY7:GetValue('GY7_CAMPO'))
				cCampos+=oMdlGY7:GetValue('GY7_ENTIDA')+'.'+oMdlGY7:GetValue('GY7_CAMPO')+','
			Else
				cCampos+= "'"+Alltrim(oMdlGY7:GetValue('GY7_VALOR'))+"' AS '" +Alltrim(oMdlGY7:GetValue('GY7_DESCRI'))+"',"
			Endif
		Endif

	Next
	IF !Empty(cFrom) .or. !Empty(cWhere)
		cQuery 	:= "Select "+ SubStr(cCampos,1,Len(cCampos)-1) 
		cQuery 	+= " From " + SubStr(cFrom,1,Len(cFrom)-1) 
		cQuery 	+= " Where "+ SubStr(cWhere,1,Len(cWhere)-4) 
	Endif
	lRet	:= oModel:GetModel('FIELDGZ8'):SetValue('GZ8_SQL',cQuery)
Endif
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GA042Entida()
Valida en entidade com a tree
@author  Renan Ribeiro Brando	
@since   04/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GA042Entida()

Local oModel := FWModelActive()
Local oModelTree := oModel:GetModel('TREE1')
Local oModelGY7 := oModel:GetModel('GRIDGY7')
Local lRet := .T.

If (!oModelTree:SeekLine({{"GY5_ENTIDA", oModelGY7:GetValue("GY7_ENTIDA")}}))
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GA282LinePre(oModel,nLine,cAction,cField,uValue)
description
@author  jacomo.fernandes
@since   07/08/17
@version 12
/*/
//-------------------------------------------------------------------
Static Function GA282LinePre(oMdl,nLine,cAction,cField,uValue)
Local oModel:= oMdl:GetModel()
Local lRet	:= .T.
Local cId	:= oMdl:GetId()
Local xValue:= ""
If cId == 'TREE1' .and. cAction == "DELETE" .and. oMdl:GetValue('GY5_IDTREE') <> 'REL'
	xValue := oMdl:GetValue('GY5_ENTIDA')
	If oMdl:SeekLine({{'GY5_IDTREE','REL'}})
		If oModel:GetModel('TREE2'):SeekLine({ {'GY6_ENTID1',xValue} })
			lRet := .F.
		ElseIf oModel:GetModel('TREE2'):SeekLine({ {'GY6_ENTID2',xValue} })
			lRet := .F.
		Endif
		If !lRet
			FwAlertHelp(STR0031,STR0032,"GA282LinePre")//"Existe relacionamento para essa Entidade"##'Exclua primeiramente o relacionamento antes de excluir a entidade'
		Endif
	Endif
	If lRet .and. oModel:GetModel('GRIDGY7'):SeekLine({ {'GY7_ENTIDA',xValue} })
		lRet := .F.
		FwAlertHelp(STR0033,STR0034,"GA282LinePre")//"Existem campos informados para essa Entidade"##'Exclua primeiramente os campos dessa entidade para excluí-las'
	Endif
Endif
oMdl:GoLine(nLine)
Return lRet

/*/{Protheus.doc} GTPX2Name
Função que retorna a descrição da tabela
@author elton.alves
@since 16/09/2015
@version 1.0
@param cAlias, Caracter, Alias da tabela
@return Caracter, Nome da tabela
/*/
Function GTPX2Name( cAlias )
	//Função puxada dos fontes do SIGATUR
	Local cRet := ''
	
	If SX2->( DbSeek( cAlias ) )
		
		cRet := Capital( X2Nome() )
		
	End If
	
Return cRet
