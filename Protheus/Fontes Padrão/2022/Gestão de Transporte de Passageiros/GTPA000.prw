#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA000.CH"
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA000()
Cadastro de Orgãos Poder Concedente - Órgão -  GI0
@sample		GTPA000()
@return		oBrowse  Retorna o Cadastro de Órgãos
@author		Serviços - Inovação
@since			05/03/2014
@version		P12
/*///------------------------------------------------------------------------------------------
Function GTPA000()
	
	Local oBrowse		:= Nil	
	Private aRotina	:= MenuDef()
		
		oBrowse:=FWMBrowse():New()
		oBrowse:SetAlias("GI0")
		oBrowse:SetDescription(STR0008)// "Órgão Concedente"
		
		if FieldPos('GI0_MSBLQL') > 0
			
			oBrowse:AddLegend("GI0_MSBLQL == '1'"	, "RED"		, STR0017)//"Inativo" 
			oBrowse:AddLegend("GI0_MSBLQL <> '1'"	, "GREEN"	, STR0018)//"Ativo"
	
		EndIf
		
		oBrowse:Activate()
	
Return oBrowse
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
@sample		ModelDef()
@return		oModel - Retorna o Modelo de dados
@author		Serviços - Inovação
@since			05/03/2014
@version		P12
/*///------------------------------------------------------------------------------------------
Static Function ModelDef()
	
	Local oStruGI0	:= FWFormStruct( 1,"GI0")	//Tabela de Poder Concedente
	Local oStruGQD	:= FWFormStruct( 1,"GQD")	//Tipo de Linhas x OrgÆo
	Local oStruG5F	:= FWFormStruct( 1,"G5F")   // Categorias x Orgão
	Local oStruG5H	:= FWFormStruct( 1,"G5H")   //Reajuste de preço
	Local lExistH68 := AliasInDic('H68')
	Local oStruH68	:= Nil 					   // Tipos de Documentos X Orgao

	Local bPosValid	:= { |oModel| TP000TdOK(oModel)}
	Local bPreLnGQD	:= { |oMdlGQD,nLine,cAcao,cCampo| P000PLGQD(oMdlGQD,nLine,cAcao,cCampo)}
	Local oModel	:= MPFormModel():New('GTPA000', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )
		
	If lExistH68
	
		oStruH68 := FWFormStruct( 1,"H68")
		
	Endif
	
	SetModelProperty(oStruGI0,oStruH68)

	oModel:AddFields('GI0MASTER',/*cPai*/,oStruGI0)
	oModel:SetPrimaryKey({"GI0_FILIAL","GI0_COD"})

	// Adiciona Relacionamento
	oModel:addGrid('GQDDETAIL','GI0MASTER',oStruGQD, bPreLnGQD,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
	oModel:AddGrid('G5FDETAIL','GQDDETAIL',oStruG5F,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
	oModel:AddGrid('G5HDETAIL','G5FDETAIL',oStruG5H,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)

	oModel:SetRelation('GQDDETAIL',{{ 'GQD_FILIAL','xFilial( "GQD" )'},{'GQD_CODGI0','GI0_COD' }},GQD->(IndexKey(2)))
	oModel:SetRelation('G5FDETAIL',{{ 'G5F_FILIAL','xFilial( "G5F" )'},{'G5F_CODGI0','GI0_COD' }, {'G5F_CODGQC','GQD_CODGQC' } },G5F->(IndexKey(1)))
	oModel:SetRelation('G5HDETAIL',{{ 'G5H_FILIAL','xFilial( "G5F" )'},{'G5H_CODORG','GI0_COD' },{'G5H_TPLIN','GQD_CODGQC' } },G5H->(IndexKey(1)))

	oModel:GetModel('GQDDETAIL'):SetOptional(.T.)
	oModel:GetModel('G5FDETAIL'):SetOptional(.T.)
	oModel:GetModel('G5HDETAIL'):SetOptional(.T.)

	// Para nao ter duplicidade de Tipo de Linha
	oModel:GetModel( 'GQDDETAIL' ):SetUniqueLine( { 'GQD_CODGQC' } )
	oModel:GetModel( 'G5FDETAIL' ):SetUniqueLine( { 'G5F_CODGYR' } )
	oModel:GetModel( 'G5HDETAIL' ):SetUniqueLine( { 'G5H_CODIGO' } )

	// Adiciona Descrição
	oModel:SetDescription(STR0008) // "Órgão Concedente"
	
	If ( lExistH68 )
	
		oModel:AddGrid('H68DETAIL','GI0MASTER',oStruH68,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
		oModel:SetRelation('H68DETAIL',{{ 'H68_FILIAL','xFilial( "H68" )'},{'H68_CODGI0','GI0_COD' }}, H68->(IndexKey(1)))
		oModel:GetModel('H68DETAIL'):SetOptional(.T.)
		oModel:GetModel( 'H68DETAIL' ):SetUniqueLine( { 'H68_CODG6U' } )
	
	EndIf

Return oModel

 /*/{Protheus.doc} SetModelProperty
	(long_description)
	@type  Function
	@author user
	@since 18/08/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function SetModelProperty(oStruGI0,oStruH68)

	Local aCombo	:= {}
	
	Local lExistH68 := AliasInDic('H68')
	
	oStruGI0:SetProperty('GI0_SIGLA',MODEL_FIELD_OBRIGAT, .F. )

	If ( lExistH68 )

		aCombo := {"1=Colaborador","2=Veículo","3=Órgão"}

		oStruH68:AddField(;
			FWX3Titulo("G6U_TRECUR"),;  	//  [01]  C   Titulo do campo   //"Arquivo"
			FWX3Titulo("G6U_TRECUR"),;  	//  [02]  C   ToolTip do campo  //"Caminho e Nome do Arquivo"
			"H68_TRECUR",;     				//  [03]  C   Id do Field
			"C",;							//  [04]  C   Tipo do campo
			1,;	  							//  [05]  N   Tamanho do campo
			0,;              				//  [06]  N   Decimal do campo
			Nil,;       					//  [07]  B   Code-block de validação do campo
			Nil,;       					//  [08]  B   Code-block de validação When do campo
			aCombo,;       					// 	[09]  A   Lista de valores permitido do campo
			.F.,;       					// 	[10]  L   Indica se o campo tem preenchimento obrigatório
			{|oSub| RetTpRecurso(oSub) },;  // 	[11]  B   Code-block de inicializacao do campo
			.F.,;       					// 	[12]  L   Indica se trata-se de um campo chave
			.T.,;       					// 	[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T. )       					//  [14]  L   Indica se o campo é virtual

		oStruH68:SetProperty('H68_DTMAX',MODEL_FIELD_WHEN, {|oSubMdl| oSubMdl:GetValue("H68_TRECUR") == "3" } )
		
		oStruH68:AddTrigger("H68_CODG6U", "H68_CODG6U", {|| .T.}, {|oMdl| oMdl:LoadValue('H68_DSCG6U',Posicione("G6U",1,xFilial("G6U")+oMdl:GetValue("H68_CODG6U"),"G6U_DESCRI"))})
		oStruH68:AddTrigger("H68_CODG6U", "H68_TRECUR", {|| .T.}, {|oMdl| Posicione("G6U",1,xFilial("G6U")+oMdl:GetValue("H68_CODG6U"),"G6U_TRECUR") })
	
	Endif

Return()

Static Function RetTpRecurso()

	Local cRet := ""
	
	cRet := Posicione("G6U",1,xFilial("G6U")+H68->H68_CODG6U,"G6U_TRECUR")
	

Return(cRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição do interface
@sample		ViewDef()
@return		oView - Retorna a View
@author		Serviços - Inovação
@since			05/03/2014
@version		P12
/*///------------------------------------------------------------------------------------------
Static Function ViewDef()
	
	Local oModel	:= FWLoadModel('GTPA000')
	Local oStruGI0	:= FWFormStruct(2,'GI0')
	Local oStruGQD 	:= FWFormStruct(2,'GQD', {|cCampo| AllTrim(cCampo)+ "|" $ "GQD_CODGQC|GQD_DESGQC|GQD_RJTTAR|GQD_RJTPED|GQD_RJTTAX|"})
	Local oStruG5F 	:= FWFormStruct(2,'G5F', {|cCampo| AllTrim(cCampo)+ "|" $ "G5F_CODGYR|G5F_DSCGYR|"})
	Local oStruG5H 	:= FWFormStruct(2,'G5H')	//Radu diz: Nãp possui definição dentro da View - 19/08/2022
	Local lExistH68 := AliasInDic('H68')
	Local oStruH68 	:= Nil 
	Local oView		:= Nil

		oView := FWFormView():New()
		oView:SetModel(oModel)
		oView:SetDescription(STR0008)
	
		oView:AddField('VIEW_GI0',oStruGI0,'GI0MASTER')
		oView:AddGrid('VIEW_GQD' , oStruGQD,'GQDDETAIL')
		oView:AddGrid('VIEW_G5F' , oStruG5F,'G5FDETAIL')

		If lExistH68
		
			oStruH68 := FWFormStruct(2, 'H68')
			
			SetViewProperty(oStruH68)
			
			oView:AddGrid('VIEW_H68' , oStruH68, 'H68DETAIL')
			
			oView:CreateHorizontalBox('SUPERIOR', 20)
			oView:CreateHorizontalBox('INFERIOR', 80)

			oView:CreateFolder("FOLDER", "INFERIOR")
			oView:AddSheet("FOLDER", "ABA01", "Tipos de Linhas e Categorias")
			oView:AddSheet("FOLDER", "ABA02", "Tipos de Documentos") 
			oView:CreateVerticalBox("LINCATEG", 100,,, 'FOLDER', 'ABA01')
			oView:CreateVerticalBox("TIPODOC",  100,,, 'FOLDER', 'ABA02')
					
			oView:CreateHorizontalBox('LINHA', 50, 'LINCATEG',, 'FOLDER', 'ABA01')
			oView:CreateHorizontalBox('CATEG', 50, 'LINCATEG',, 'FOLDER', 'ABA01')

			oView:SetOwnerView('VIEW_GI0','SUPERIOR')
			oView:SetOwnerView('VIEW_GQD','LINHA')
			oView:SetOwnerView('VIEW_G5F','CATEG')
			oView:SetOwnerView('VIEW_H68','TIPODOC')
		Else
			oView:CreateHorizontalBox('SUPERIOR',20)
			oView:CreateHorizontalBox('TIPOLINHA',40)
			oView:CreateHorizontalBox('CATEGORIA',40)

			oView:SetOwnerView('VIEW_GI0','SUPERIOR')
			oView:SetOwnerView('VIEW_GQD','TIPOLINHA')
			oView:SetOwnerView('VIEW_G5F','CATEGORIA')
		Endif

		oView:AddUserButton( STR0014, "", {|oModel| GTPA701(oModel, oModel:GetModel("GQDDETAIL"):GetValue("GQD_RJTTAR"), "1")},,,{MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE} )//"Tarifa"
		oView:AddUserButton( STR0015, "", {|oModel| GTPA701(oModel, oModel:GetModel("GQDDETAIL"):GetValue("GQD_RJTPED"), "2")},,,{MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE} )//"Pedágio"
		oView:AddUserButton( STR0016, "", {|oModel| GTPA701(oModel, oModel:GetModel("GQDDETAIL"):GetValue("GQD_RJTTAX"), "3")},,,{MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE} )//"Tx. Embarque"
	
		//Categorias e Coeficientes
		oView:EnableTitleView("VIEW_GQD",STR0009)//Tipos de Linhas"	
		oView:EnableTitleView("VIEW_G5F",STR0012) //Categorias
		
Return oView

/*/{Protheus.doc} SetModelProperty
	(long_description)
	@type  Function
	@author user
	@since 18/08/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function SetViewProperty(oStruH68)

	Local aCombo	:= {}
	
	Local lExistH68 := AliasInDic('H68')

	If ( lExistH68 )

		aCombo := {"1=Colaborador","2=Veículo","3=Órgão"}

		//Composição da Estrutura do Cabeçalho
    	oStruH68:AddField(;	
			"H68_TRECUR",;					// [01]  C   Nome do Campo
			"02",;							// [02]  C   Ordem
			FWX3Titulo("G6U_TRECUR"),;		// [03]  C   Titulo do campo // "Data de"
			FWX3Titulo("G6U_TRECUR"),;		// [04]  C   Descricao do campo // "Data de"
			{FWX3Titulo("G6U_TRECUR")},;	// [05]  A   Array com Help // "Data de"
			"COMBO",;				    	// [06]  C   Tipo do campo
			"",;							// [07]  C   Picture
			NIL,;							// [08]  B   Bloco de Picture Var
			"",;							// [09]  C   Consulta F3
			.F.,;							// [10]  L   Indica se o campo é alteravel
			NIL,;							// [11]  C   Pasta do campo
			"",;							// [12]  C   Agrupamento do campo
			aCombo,;						// [13]  A   Lista de valores permitido do campo (Combo)
			NIL,;							// [14]  N   Tamanho maximo da maior opção do combo
			NIL,;							// [15]  C   Inicializador de Browse
			.T.,;							// [16]  L   Indica se o campo é virtual
			NIL,;							// [17]  C   Picture Variavel
			.F.)							// [18]  L   Indica pulo de linha após o campo

		oStruH68:RemoveField('H68_CODGI0')
		GTPOrdStruct(oStruH68,"01","H68_CODG6U")
	EndIf

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
@sample		MenuDef()
@return		aRotina - Array de opções do menu
@author		Serviços - Inovação
@since			05/03/2014
@version		P12
/*///------------------------------------------------------------------------------------------
Static Function MenuDef()
	
	Local aRotina := {}
	
		ADD OPTION aRotina TITLE STR0006 ACTION "PesqBrw"			OPERATION 1 ACCESS 0 //"Pesquisar"
		ADD OPTION aRotina TITLE STR0001 ACTION 'VIEWDEF.GTPA000'	OPERATION 2 ACCESS 0 // #Visualizar
		ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.GTPA000'	OPERATION 3 ACCESS 0 // #Incluir
		ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.GTPA000'	OPERATION 4 ACCESS 0 // #Alterar
		ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA000'	OPERATION 5 ACCESS 0 // #Excluir
		
Return aRotina
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Funcao para chamar o Adapter para integracao via Mensagem Unica 

@sample 	IntegDef( cXML, nTypeTrans, cTypeMessage )
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				'0'- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				'1'- para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				'20' - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return  	aRet[1] - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.)
			aRet[2] - String contendo informacoes sobre o processamento
			aRet[3] - String com o nome da mensagem Unica deste cadastro                        
@author  	Jacomo Lisa
@since   	15/02/2017
@version  	P12.1.8
/*///-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
	
	Local aRet := {}
	
	aRet:= GTPI000( cXml, nTypeTrans, cTypeMessage )
	
Return aRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP000TdOK(oModel)
Pós validação do commit MVC, verificação da chave antes do commit
 @sample	TP000TdOK(oModel)
 @return	lRet 
 @author	Inovação
@since		08/03/2017
@version	P12
/*///------------------------------------------------------------------------------------------
Static Function TP000TdOK(oModel)

	Local oMdlGI0	:= oModel:GetModel('GI0MASTER')
	Local lRet	:= .T.
	
		// Se já existir a chave no banco de dados no momento do commit, a rotina 
		If (oMdlGI0:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGI0:GetOperation() == MODEL_OPERATION_UPDATE)
		
			If (!ExistChav("GI0", oMdlGI0:GetValue("GI0_COD")))
		
				lRet := .F.
				Help( ,, 'Help',"TP000TdOK", STR0011, 1, 0 )//"Órgão já cadastrado!"
		
			EndIf
		
		EndIf

Return (lRet)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} P000PLGQD(oMdlGQD,nLine,cAcao,cCampo)
Verifica se possui algum reajuste cadastrado
@sample	P000PLGQD(oModel)
@return	lRet 
@author	Inovação
@since		08/03/2017
@version	P12
/*///------------------------------------------------------------------------------------------
Static Function P000PLGQD(oMdlGQD,nLine,cAcao,cCampo)
	
	Local lRet		:= .T.
	Local nI		:= 1
	Local oModel	:= FwModelActive()
	Local oMdlG5H	:= oModel:GetModel("G5HDETAIL")
	Local lReg		:= .F.
	Local cTpReaj
		
		If	(cAcao == "SETVALUE" .And. cCampo == "GQD_RJTTAR") .Or. (cAcao == "SETVALUE" .And. cCampo == "GQD_RJTPED");
				.Or. (cAcao == "SETVALUE" .And. cCampo == "GQD_RJTTAX")
		
			oMdlGQD:GoLine(nLine)
			
			If cCampo == "GQD_RJTTAR"
			
				cTpReaj	:= '1'
			
			ElseIf cCampo == "GQD_RJTPED"
			
				cTpReaj	:= '2'
			
			ElseIf cCampo == "GQD_RJTTAX"
			
				cTpReaj	:= '3'
			
			EndIf
		
			While oMdlG5H:SeekLine({{'G5H_TPREAJ',cTpReaj}})
			
				lReg	:= .T.
				Exit
			
			End
			
			If nI == 1 .And. !Empty(oMdlG5H:GetValue("G5H_CODIGO")) .And. !oMdlG5H:IsDeleted() .And. lReg
				
				If MsgYesNo(STR0013)//"Possui valores no reajuste de preço deseja apagar?"
				
					While oMdlG5H:SeekLine({{'G5H_TPREAJ',cTpReaj}})
						oMdlG5H:DeleteLine()
					End
					lRet := .F.
				
				EndIf
			
			EndIf
	
		EndIf

Return lRet

