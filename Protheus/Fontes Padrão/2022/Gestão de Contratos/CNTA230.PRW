#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "CNTA230.CH"

Static __lC230ROT := ExistBlock("CN230ROT")

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTA230()
Cadastro de tipos de planilha
@author Leonardo Quintania
@since 26/05/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------	
Function CNTA230() 
	Local oBrowse  

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("CNL")                                          
	oBrowse:SetDescription(STR0001)  //"Tipos de Planilha"
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Quintania
@since 26/05/2015
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {} //Array utilizado para controlar opcao selecionada
	Local aRotPE := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"			OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.CNTA230" 	OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CNTA230"	OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.CNTA230"	OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.CNTA230"	OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.CNTA230"	OPERATION 8 ACCESS 0 //'Imprimir'
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.CNTA230"	OPERATION 9 ACCESS 0 //'Copia'

	If __lC230ROT
		aRotPE := ExecBlock( "CN230ROT", .F., .F. )
		If ValType( aRotPE ) == "A"
			AEval( aRotPE, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Quintania
@since 26/05/2015
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruCab	:= FWFormStruct(1,"CNL") //Tipos de Planilha
	Local oModel	:= Nil //Modelo de Dados MVC
	Local bVldTpSFix:= MTBlcVld("CNL","CNL_TPSFIX"	,"Cn230GtPlan('CNL_TPSFIX',FwFldGet('CNL_TPSFIX'))",.F.,.F., .T.)
	Local bWhen		:= {|| !Empty(FwFldGet('CNL_MEDEVE')) }	

	oStruCab:SetProperty('CNL_TPSFIX',MODEL_FIELD_VALID, bVldTpSFix)
	oStruCab:SetProperty('CNL_MEDEVE',MODEL_FIELD_OBRIGAT,.T.)//Medição Eventual Obrigatório
	
	//Inicializa campos bloqueados
	oStruCab:SetProperty('CNL_CROFIS',MODEL_FIELD_WHEN,bWhen)
	oStruCab:SetProperty('CNL_CROCTB',MODEL_FIELD_WHEN,bWhen)
	oStruCab:SetProperty('CNL_TPLMT' ,MODEL_FIELD_WHEN,bWhen)	
	oStruCab:SetProperty('CNL_TPSFIX',MODEL_FIELD_WHEN,{||Cn230SFix("CNL_TPSFIX")})
	oStruCab:SetProperty('CNL_ALCMED',MODEL_FIELD_WHEN,{||Cn230AlcMd("CNL_ALCMED")})

	//------------------------------------------------------
	//		Cria a estrutura basica
	//------------------------------------------------------
	oModel:= MPFormModel():New("CNTA230", /*Pre-Validacao*/,/*Pós-Validação*/,/*bCommit*/,/*bCancel*/)

	//------------------------------------------------------
	//		Adiciona o componente de formulario no model
	//     Nao sera usado, mas eh obrigatorio ter
	//------------------------------------------------------
	oModel:AddFields("CNLMASTER",/*cOwner*/,oStruCab)

	//--------------------------------------
	//		Configura o model
	//--------------------------------------
	oModel:SetPrimaryKey( {"CNL_FILIAL","CNL_CODIGO"} ) //Obrigatorio setar a chave primaria (mesmo que vazia)
	oModel:SetVldActivate({|oModel| CN230VlAct(oModel)})

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Leonardo Quintania
@since 26/05/2015
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()  

	Local oModel   	:= FWLoadModel( "CNTA230" )	 //Carrega model definido
	Local oStruCab 	:= FWFormStruct(2,"CNL") //Estrutura Tipos de Planilha
	Local oView	  	:= FWFormView():New()

	If oStruCab:HasField('CNL_CODAGR')
		oStruCab:RemoveField('CNL_CODAGR')
	EndIf
	If oStruCab:HasField('CNL_NIVAGR')
		oStruCab:RemoveField('CNL_NIVAGR')
	EndIf

	//--------------------------------------
	//		Associa o View ao Model
	//--------------------------------------
	oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado
	oView:SetUseCursor(.F.) //-- Remove cursor de registros'

	//--------------------------------------
	//		Insere os componentes na view
	//--------------------------------------
	oView:AddField("VIEW_CNL",oStruCab,"CNLMASTER")   //Cabecalho da matriz de abastecimento

	//--------------------------------------
	//		Cria os Box's
	//--------------------------------------
	oView:CreateHorizontalBox("CABEC",100)

	//--------------------------------------
	//		Associa os componentes
	//--------------------------------------
	oView:SetOwnerView("VIEW_CNL","CABEC")

Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} Cn2030GtPlan(cField,cValue)
Função para gatilho dos campos do modelo
@author José Eulálio
@since 04/07/2015
@version 12
@return .T.
/*/
//--------------------------------------------------------------------
Function Cn230GtPlan(cField,cValue)
	Local lRet			:= .T.
	Local oModel		:= FwModelActive()
	Local oView			:= FwViewActive()
	Local oModelCNL
	Local oStructCNL

	If oModel:GetId() <> "CNTA230"
		oModel:= FWLoadModel( "CNTA230" )
	EndIf

	oModelCNL  	:= oModel:GetModel('CNLMASTER')
	oStructCNL 	:= oModelCNL:GetStruct()

	Do Case		
		
		Case cField == "CNL_MEDEVE"//Medição Eventual
			If cValue == "0"//0=Conforme Contrato

				//Medição Automática
				oStructCNL:SetProperty("CNL_MEDAUT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_MEDAUT","0")
				oStructCNL:SetProperty("CNL_MEDAUT",MODEL_FIELD_WHEN,{||.F.})

				//Fixo
				oStructCNL:SetProperty("CNL_CTRFIX",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_CTRFIX","0")
				oStructCNL:SetProperty("CNL_CTRFIX",MODEL_FIELD_WHEN,{||.F.})

				//SemiFixo
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPSFIX","0")
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.F.})

				//Físico
				oStructCNL:SetProperty("CNL_CROFIS",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_CROFIS","0")
				oStructCNL:SetProperty("CNL_CROFIS",MODEL_FIELD_WHEN,{||.F.})

				//Contábil
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_CROCTB","0")
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.F.})

				//Previsão Financeira
				oStructCNL:SetProperty("CNL_VLRPRV",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_VLRPRV","0")
				oStructCNL:SetProperty("CNL_VLRPRV",MODEL_FIELD_WHEN,{||.F.})

				//Limite da Medição
				oStructCNL:SetProperty("CNL_LMTMED",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_LMTMED",0)
				oStructCNL:SetProperty("CNL_LMTMED",MODEL_FIELD_WHEN,{||.F.})

				//Tipo de Limite
				oStructCNL:SetProperty("CNL_TPLMT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPLMT","0")
				oStructCNL:SetProperty("CNL_TPLMT",MODEL_FIELD_WHEN,{||.F.})

				//Tipo de Multa
				oStructCNL:SetProperty("CNL_TPMULT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPMULT","0")
				oStructCNL:SetProperty("CNL_TPMULT",MODEL_FIELD_WHEN,{||.F.})

			ElseIf cValue == "1"//1=Sim
				//Medição Automática
				oStructCNL:SetProperty("CNL_MEDAUT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_MEDAUT","2")
				oStructCNL:SetProperty("CNL_MEDAUT",MODEL_FIELD_WHEN,{||.F.})

				//Fixo
				oStructCNL:SetProperty("CNL_CTRFIX",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_CTRFIX","0")

				//Semi Fixo
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPSFIX","0")
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.F.})

				//Físico
				oStructCNL:SetProperty("CNL_CROFIS",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_CROFIS","2")
				oStructCNL:SetProperty("CNL_CROFIS",MODEL_FIELD_WHEN,{||.F.})

				//Contábil
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_CROCTB","0")
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.F.})

				//Limite da Medição
				oStructCNL:SetProperty("CNL_LMTMED",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_LMTMED",0)

				//Tipo de Limite
				oStructCNL:SetProperty("CNL_TPLMT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPLMT","1")  // Financeiro
				oStructCNL:SetProperty("CNL_TPLMT",MODEL_FIELD_WHEN,{||.F.})

				//Tipo de Multa
				oStructCNL:SetProperty("CNL_TPMULT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPMULT","0")

			ElseIf cValue == "2"//2=Não
				//Medição Automática
				oStructCNL:SetProperty("CNL_MEDAUT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_MEDAUT","0")

				//Fixo
				oStructCNL:SetProperty("CNL_CTRFIX",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_CTRFIX","1")
				oStructCNL:SetProperty("CNL_CTRFIX",MODEL_FIELD_WHEN,{||.F.})

				//Semi Fixo
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPSFIX","0")
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.F.})

				//Físico
				oStructCNL:SetProperty("CNL_CROFIS",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_CROFIS",'0')

				//Contábil
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_CROCTB",'0')

				//Previsão financeira
				oStructCNL:SetProperty("CNL_VLRPRV",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_VLRPRV","1")
				oStructCNL:SetProperty("CNL_VLRPRV",MODEL_FIELD_WHEN,{||.F.})

				//Limite da Medição
				oStructCNL:SetProperty("CNL_LMTMED",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_LMTMED",0)

				//Tipo de Limite
				oStructCNL:SetProperty("CNL_TPLMT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPLMT","0")
				oStructCNL:SetProperty("CNL_TPLMT",MODEL_FIELD_WHEN,{||.F.})

				//Tipo de Multa
				oStructCNL:SetProperty("CNL_TPMULT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPMULT","0")

			ElseIf cValue == "3"//3=Recorrente
				//Medição Automática
				oStructCNL:SetProperty("CNL_MEDAUT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_MEDAUT","1")
				oStructCNL:SetProperty("CNL_MEDAUT",MODEL_FIELD_WHEN,{||.F.})

				//Fixo
				oStructCNL:SetProperty("CNL_CTRFIX",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_CTRFIX","1")
				oStructCNL:SetProperty("CNL_CTRFIX",MODEL_FIELD_WHEN,{||.F.})

				//Semi Fixo
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPSFIX","0")
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.F.})

				//Físico
				oStructCNL:SetProperty("CNL_CROFIS",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_CROFIS","2")
				oStructCNL:SetProperty("CNL_CROFIS",MODEL_FIELD_WHEN,{||.F.})

				//Contábil
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_CROCTB","2")
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.F.})

				//Previsão financeira
				oStructCNL:SetProperty("CNL_VLRPRV",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_VLRPRV","1")
				oStructCNL:SetProperty("CNL_VLRPRV",MODEL_FIELD_WHEN,{||.F.})

				//Limite da Medição
				oStructCNL:SetProperty("CNL_LMTMED",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_LMTMED",0)

				//Tipo de Limite
				oStructCNL:SetProperty("CNL_TPLMT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_TPLMT",'1')
				oStructCNL:SetProperty("CNL_TPLMT",MODEL_FIELD_WHEN,{||.F.})

				//Tipo de Multa
				oStructCNL:SetProperty("CNL_TPMULT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPMULT","0")
			EndIf
		Case cField == "CNL_CTRFIX"// "Planilha" Fixa
			If cValue == "0" // Conforme o Contrato
				// Previsão Financeira
				oStructCNL:SetProperty("CNL_VLRPRV",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_VLRPRV","0")
				oStructCNL:SetProperty("CNL_VLRPRV",MODEL_FIELD_WHEN,{||.F.})
				
				//Contábil
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_CROCTB","0")
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.F.})
				
				//Semi Fixo
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPSFIX","0")
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.F.})

			ElseIf cValue == "1" // Sim
				// Previsão Financeira
				oStructCNL:SetProperty("CNL_VLRPRV",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_VLRPRV","1")
				oStructCNL:SetProperty("CNL_VLRPRV",MODEL_FIELD_WHEN,{||.F.})

				//Contábil
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.T.})

				//Semi Fixo
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPSFIX","0")
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.F.})

			ElseIf cValue == "2" // Não				
				// Previsão Financeira
				oStructCNL:SetProperty("CNL_VLRPRV",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_VLRPRV","0")
				
				//Contábil
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_CROCTB","2")
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.F.})

				//Semi Fixo
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPSFIX","0")
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.F.})

			ElseIf cValue == "3" // Semi Fixo

				//Semi Fixo
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.T.})
				
				// Previsão Financeira
				oStructCNL:SetProperty("CNL_VLRPRV",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_VLRPRV","1")
				oStructCNL:SetProperty("CNL_VLRPRV",MODEL_FIELD_WHEN,{||.F.})
				
				// Previsão Financeira
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_CROCTB","2")
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.F.})
				
				// Previsão Financeira
				oStructCNL:SetProperty("CNL_TPSFIX",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPSFIX","1")
				
			EndIf

		Case cField == "CNL_TPLMT"
			If !cValue $ "1|2"
				//Limite da Medição
				oStructCNL:SetProperty("CNL_LMTMED",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_LMTMED",0)
				oStructCNL:SetProperty("CNL_LMTMED",MODEL_FIELD_WHEN,{||.F.})
			Else
				//Limite da Medição
				oStructCNL:SetProperty("CNL_LMTMED",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:LoadValue("CNL_LMTMED",0)
			EndIf
			
		Case cField == "CNL_PLSERV"
			If cValue == "1"
				oStructCNL:SetProperty("CNL_CROCTB",MODEL_FIELD_WHEN,{||.T.})
			EndIf
		Case cField == "CNL_CROFIS"
			If cValue == "0"
				oStructCNL:SetProperty("CNL_TPLMT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPLMT","0")
				oStructCNL:SetProperty("CNL_TPLMT",MODEL_FIELD_WHEN,{||.F.})
			ElseIf cValue == "1"
				oStructCNL:SetProperty("CNL_TPLMT",MODEL_FIELD_WHEN,{||.T.})
			ElseIf cValue == "2"
				oStructCNL:SetProperty("CNL_TPLMT",MODEL_FIELD_WHEN,{||.T.})
				oModelCNL:SetValue("CNL_TPLMT","1")
				oStructCNL:SetProperty("CNL_TPLMT",MODEL_FIELD_WHEN,{||.F.})
			EndIf
	EndCase
	
	lRet := CN230VlCpo(cField,cValue)		

	If ValType(oView) == "O" .And. oView:IsActive().And. oView:GetModel():GetId() == "CNTA230"
		oView:Refresh()
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN230VlCpo()
Valid dos campos

@author jose.eulalio
@since 10/08/2015
@version P12
@return lRet
/*/
//--------------------------------------------------------------------
Function CN230VlCpo(cCampo,cValor)
	Local lRet		:= .T.
	Local oModel	:= FwModelActive()
	Local oModCNL  	:= oModel:GetModel('CNLMASTER')
	
	If lRet .And. cCampo == "CNL_CROFIS"//Validação do Cronograma Físico
		If cValor == "1" .And. oModCNL:GetValue("CNL_MEDEVE") <> "2"
			lRet := .F.
			Help( " ", 1, "CNTA020_03" )
		EndIf
	EndIf
	
	If lRet .And. cCampo == "CNL_TPLMT"//Validação do Tipo de Limite
		If cValor == "2" .And. oModCNL:GetValue("CNL_CROFIS") == "2"
			lRet := .F.
			Help( " ", 1, "CNTA020_04" )
		EndIf
	EndIf
	
	If lRet .And. cCampo == "CNL_CTRFIX"//Validação da Planilha Fixa
		If cValor == "2" .And. oModCNL:GetValue("CNL_MEDEVE") == "2"
			lRet := .F.
			Help( " ", 1, "CNTA020_06" )
		EndIf
	EndIf
	
	If lRet .And. cCampo == "CNL_CROCTB"//Validação do Cronograma Contábil
		If cValor == "1" .And. oModCNL:GetValue("CNL_CTRFIX") == "2"
			lRet := .F.
			Help( " ", 1, "CNTA020_07" )
		EndIf
		If lRet .And. cValor $ "01" .And. oModCNL:GetValue("CNL_MEDEVE") == "1"
			lRet := .F.
			Help("",1,"CNTA020_EVE",,STR0009,4,1) //"Contratos com Medição Eventual não possuem cronogramas."
		EndIf
	EndIf

Return lRet

//=============================================================================
/*/{Protheus.doc} Cn230VlServ(oModelCNL)
Função responsável pelo WHEN do campo CNL_PLSERV
@author israel.escorizza
@since 10/05/2016
@return
/*/
//=============================================================================
Function Cn230VlServ(oModelCNL)
Local lRet			:= .F.
Local oView	:= FwViewActive()
Local oModel:= Nil

Default oModelCNL	:= Nil

If oModelCNL == Nil
	oModel	:= FwModelActive()
	oModelCNL := oModel:GetModel('CNLMASTER')
Endif

If 	oModelCNL:GetValue('CNL_CTRFIX') == '1' .And. oModelCNL:GetValue('CNL_VLRPRV') == '1' .And. oModelCNL:GetValue('CNL_TPLMT') == '1' .And.;
	oModelCNL:GetValue('CNL_MEDEVE') == '2' .And. oModelCNL:GetValue('CNL_CROFIS') == '2' 

	lRet := .T.
ElseIf oModelCNL:GetValue('CNL_PLSERV') == '1'
	oModelCNL:LoadValue('CNL_PLSERV','2')
	If ValType(oView) == "O" .And. oView:isActive() .And. oView:GetModel():GetId()=="CNTA230"
		oView:Refresh()
	EndIf
EndIf

If ALTERA
	dbSelectArea("CNA") 
	dbSetOrder(4)//Tipo de planilha

	 If MsSeek(xFilial('CNA')+CNL->CNL_CODIGO, .F.)
	 	lRet := .F. 
	 Endif
Endif	

Return lRet

//=============================================================================
/*/{Protheus.doc} Cn230SFix(cCampo)
Função responsável pelo WHEN do campo CNL_TPSFIX
@author israel.escorizza
@since 10/05/2016
@return
/*/
//=============================================================================
Function Cn230SFix(cCampo)
Local oModel		:= FWModelActive()
Local lRet			:= .F.

If cCampo == "CNL_TPSFIX" .And. oModel:GetValue('CNLMASTER','CNL_CTRFIX') == '3'
	lRet := .T.
EndIf

Return lRet

//=============================================================================
/*/{Protheus.doc} Cn230AlcMd(cCampo)
Função responsável pelo WHEN do campo CNL_ALCMED
@author fabiano.dantas
@since 21/11/2019
@return
/*/
//=============================================================================

Function Cn230AlcMd(cCampo)
Local lRet	:= .T.
Default ALTERA := .F.
CNA->(dbSetOrder(4))

If CNA->(dbSeek(xFilial('CNA')+CNL->CNL_CODIGO)) .and. ALTERA
	lRet := .F.
Endif  

Return lRet 

/*/{Protheus.doc} CN230VlAct
	Realiza validações antes da ativação do modelo
@author philipe.pompeu
@since 21/03/2022
@param oModel, Objeto, Instância de MPFormModel
@return lActivate, lógico, se pode ativar o modelo
/*/
Function CN230VlAct(oModel)
	Local lActivate := .T.

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		CNA->(dbSetOrder(4))//Planilha de Contrato
		If CNA->(MsSeek(xFilial('CNA')+CNL->CNL_CODIGO, .F.))
			lActivate := .F.
			Help(" ", 1, "CNTA230NOTEXC" )
		EndIf
	EndIf
Return lActivate

/*/{Protheus.doc} CN230INC()
	ExecView para Inclusão - usada na consulta padrão da CNL
@author José Eulálio
@since 01/08/2015
@return
/*/
Function CN230INC()
	FWExecView(STR0004, "CNTA230", MODEL_OPERATION_INSERT,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,{||.T.} /*bCancel*/ )
Return

/*/{Protheus.doc} CN230VISU()
	ExecView para Visualização - usada na consulta padrão da CNL
@author José Eulálio
@since 01/08/2015
@return
/*/
Function CN230VIS()
	FWExecView(STR0003, "CNTA230", MODEL_OPERATION_VIEW,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,{||.T.} /*bCancel*/ )
Return 
