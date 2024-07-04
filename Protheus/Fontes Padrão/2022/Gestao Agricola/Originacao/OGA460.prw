#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OGA460.CH"

#DEFINE ITEMFIX "SIM"			//SIM - simula��o

Static _aCompPrc	:= {}		//Array Grava NKA
Static _lLerComp	:= .F.		//Controla Edi��o de Campos Da Composi��o de Pre�o - Modelo OGA460_NKN

/** {Protheus.doc} OGA460
Rotina Para Simula��es de Composi��o de Pre�o

@param.:    Nil
@author:    Ana Laura Olegini
@since.:    12/04/2016
@Uso...:    SIGAARM - Origina��o de Gr�os
*/
Function OGA460()
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NKN" )
	oMBrowse:SetDescription( STR0001 ) //"Simula��o de Composi��o de Pre�o"
	oMBrowse:DisableDetails()
	oMBrowse:SetMenuDef('OGA460')
	oMBrowse:Activate()
Return()

/** {Protheus.doc} MenuDef
Fun��o que retorna os itens para constru��o do menu da rotina

@param.:    Nil
@return:    aRotina - Array com os itens do menu
@author:    Equipe Agroind�stria
@since.:    12/04/2016
@Uso...:    
- Simula��o Composi��o de Pre�o
*/
Static Function MenuDef()
	Local aRotina 	:= {}

	aAdd( aRotina, { STR0002 , "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003 , "ViewDef.OGA460"	, 0, 2, 0, .T. } ) //"Visualizar"
	aAdd( aRotina, { STR0004 , "ViewDef.OGA460"	, 0, 3, 0, .T. } ) //"Incluir"
	aAdd( aRotina, { STR0005 , "ViewDef.OGA460"	, 0, 4, 0, .T. } ) //"Alterar"
	aAdd( aRotina, { STR0006 , "ViewDef.OGA460"	, 0, 5, 0, .T. } ) //"Excluir"
Return( aRotina )

/** {Protheus.doc} ModelDef
Fun��o que retorna o modelo padrao para a rotina

@param.: 	Nil
@return:	oModel - Modelo de dados
@author:    Equipe Agroind�stria
@since.:    12/04/2016
@Uso...:    OGA460 - Simula��o Composi��o de Pre�o
*/
Static Function ModelDef()
	Local oStruNKN 		:= FWFormStruct( 1, "NKN" )
	Local oModel 		:= MPFormModel():New( "OGA460", /*<bPre >*/, {| oModel | PosModelo( oModel ) }, {| oModel | GrvModelo( oModel ) }, /*<bCancel >*/ )

	oModel:AddFields( 'OGA460_NKN', Nil, oStruNKN,{|oModel,cAcao,cCampo,cVrNovo|OGA460EDIT(oModel,cAcao,cCampo,cVrNovo)} /*<bPre >*/,/*< bPost >*/,/*< bLoad >*/)

	oModel:SetDescription( STR0001 ) 									//"Simula��o de Composi��o de Pre�o"
	oModel:GetModel( 'OGA460_NKN' ):SetDescription( STR0007 ) 			//"Dados da Simula��o de Composi��o de Pre�o"

	oModel:SetActivate( { | oModel | ActvModelo() } )					//-- Inicializando o Modelo --//
	oModel:SetDeActivate( { | oModel | fDeactivMD( oModel ) } ) 		//-- Encerrando o Modelo 	--//
Return oModel

/** {Protheus.doc} ActvModelo
Fun��o que Inicializa a variavel _aCompPrc

@param.: 	oModel 		- Modelo de dados
@param.: 	nOperation 	- Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno 	- verdadeiro ou falso
@author:    Equipe Agroind�stria
@since.:    12/04/2016
@Uso...:    OGA460 - Simula��o Composi��o de Pre�o
*/
Static Function ActvModelo()
	Local lRetorno		:= .T.

	_aCompPrc := {}		//Limpa v�riavel static
	_lLerComp := .F.	//Seta v�riavel static para o valor inicial
Return(lRetorno)

/** {Protheus.doc} PosModelo
Fun��o que valida o modelo de dados ap�s a confirma��o

@param.: 	oModel - Modelo de dados
@return:	lRetorno 	- verdadeiro ou falso
@author:    Equipe Agroind�stria
@since.:    12/04/2016
@Uso...:    OGA460 - Simula��o Composi��o de Pre�o
*/
Static Function PosModelo( oModel )
	Local lRetorno		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local cSimula		:= oModel:GetValue("OGA460_NKN", "NKN_CODSIM" )
	Local cUm1Pro   	:= oModel:GetValue("OGA460_NKN", "NKN_UM1PRO" ) 
	Local cUmPreco   	:= oModel:GetValue("OGA460_NKN", "NKN_UM1PRE" )    	
	Local dDatIni		:= oModel:GetValue("OGA460_NKN", "NKN_DATINI" )
	Local dDatFim		:= oModel:GetValue("OGA460_NKN", "NKN_DATFIM" )
	Local nMoeda 		:= oModel:GetValue("OGA460_NKN", "NKN_MOEDA"  )
	Local nTopUM1		:= oModel:GetValue("OGA460_NKN", "NKN_TOPUM1" )   

	// -- Alimentando a Variavel  Statica _aCompPRC com os Dados da Composi��o de Pre�os;
	StaticCall(OGA420, fArrayNKA, cSimula, nMoeda ,cUmPreco, cUm1Pro,aCompPrc,@_aCompPRC)

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		If Empty(_aCompPRC)
			lRetorno := .F.
			oModel:GetModel():SetErrorMessage( , , oModel:GetId(), "", "", STR0008, STR0009, "", "")	//"N�o foi poss�vel confirmar a simula��o."#"Por favor, informe a composi��o de pre�o."
		EndIf

		// Data de in�cio de entrega n�o pode ser maior que a data de final de entrega
		If dDatIni > dDatFim
			lRetorno := .F.
			oModel:GetModel():SetErrorMessage( , , oModel:GetId(), "", "", STR0010, STR0011, "", "")	//"Data de In�cio de Entrega n�o pode ser maior que a Data Final de Entrega"#"Por favor, verifique as Datas de In�cio e Final de Entrega."
		EndIf

		If nTopUM1 = 0
			lRetorno := .F.
			oModel:GetModel():SetErrorMessage( , , oModel:GetId(), "", "", STR0012, STR0013, "", "")	//"Pre�o Proposto n�o pode estar zerado."#"Por favor, informar um valor v�lido."			
		EndIf
	EndIf

	If nOperation == MODEL_OPERATION_UPDATE		

		If _lLerComp //Indica que campos necessario para a composicao de pre�o que foram alterados porem os componentes nao foram recalculados
			lRetorno := .F.
			oModel:GetModel():SetErrorMessage( , , oModel:GetId(), "", "", STR0014, STR0015, "", "")	//"Os campos - C�d.Produto, Quantidade, Entrega Ini., Entrega Fim, Moeda  e Tipo Sim. - foram alterados e n�o foi realizado o recalculo dos componentes."#"Por favor, realize o rec�lculo dos componentes."
		EndIf		
	EndIf	 
Return( lRetorno )

/** {Protheus.doc} GrvModelo
Fun��o que grava o modelo de dados ap�s a confirma��o

@param.:    oModel - Modelo de dados
@return:    lRetorno [Retorno do Commit - podendo ser .T. ou .F.]
@author:    Equipe Agroind�stria
@since.:    12/04/2016
@Uso...:    OGA460 - Simula��o Composi��o de Pre�o
*/
Static Function GrvModelo( oModel )
	Local lRetorno		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local cSimula		:= oModel:GetValue( "OGA460_NKN", "NKN_CODSIM" )

	//--<< Inicio Tratamento Composi��o de Pre�o >>--
	IF ( nOperation == MODEL_OPERATION_INSERT .OR.  nOperation == MODEL_OPERATION_UPDATE )
		lRetorno := FWFormCommit(oModel, /*[bBefore]*/, /*[bAfter]*/, /*[bAfterSTTS]*/, {|oModel| OGA420NKAW( _aCompPRC, ITEMFIX ) }, /*[bABeforeTTS]*/, /*<bIntegEAI >*/)
	ElseIF ( nOperation == MODEL_OPERATION_DELETE )
		lRetorno := FWFormCommit(oModel, /*[bBefore]*/, /*[bAfter]*/, /*[bAfterSTTS]*/, {|oModel| OGA420NKAD( cSimula, ITEMFIX  ) }, /*[bABeforeTTS]*/, /*<bIntegEAI >*/)
	EndIF
	//--<< Fim    Tratamento Composi��o de Pre�o >>--       

	If !lRetorno
		oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0016, STR0017, "", "")	//"N�o foi poss�vel Confirmar a Simula��o."#"Por Favor, verifique o cadastro!"
	EndiF 

Return( lRetorno )

/** {Protheus.doc} ViewDef
Fun��o que retorna a view para o modelo padrao da rotina

@param.: 	Nil
@return:	oView - View do modelo de dados
@author:    Equipe Agroind�stria
@since.:    12/04/2016
@Uso...:    OGA460 - Simula��o Composi��o de Pre�o
*/
Static Function ViewDef()
	Local oStruNKN	:= FWFormStruct( 2, 'NKN' )
	Local oModel  	:= FWLoadModel( 'OGA460' )
	Local oView   	:= FWFormView():New()

	// Define qual Modelo de dados ser� utilizado
	oView:SetModel( oModel )

	// Declarando Objetos da Parte Superior
	oView:AddField( 'OGA460_NKN', oStruNKN, 'OGA460_NKN' )	//Controle Tipo formulario

	// Declarando Objetos da Parte Inferior
	oView:AddOtherObject("OGA460_CMP", {|oPanel, oObj | OGA460CMP(oPanel, oObj) },,) 	//Objeto n�o MVC
	oView:AddOtherObject("OTHER_BTN" , {|oPanel,oModel| OGA460BTN(oPanel,oModel)}  )	//Objeto n�o MVC

	//Cria um "box" vertical para receber cada elemento da view
	oView:CreateVerticallBox( "OGA460_V" , 100 )
	oView:CreateHorizontalBox( 'SUPERIOR', 40 ,"OGA460_V" )	
	oView:CreateHorizontalBox( 'INFERIOR', 60 ,"OGA460_V" )	

	//-- Tratando Parte Inferiror Criando Grids na Pasta Inferior
	oView:CreateFolder( "Grids", "INFERIOR")
	oView:CreateHorizontalBox( "INFERIOR" , 100, , , "Grids" )

	//-- Criando Pastas na Parte Inferior
	oView:CreateFolder( "FOLDER_INF", "INFERIOR")
	oView:AddSheet( 	"FOLDER_INF", "SHEET001_INF", OemToAnsi(STR0018) )	//"Composi��o de Pre�os"

	// Cria 2 box verticais na Pasta Inferior FOLDER_INF 
	oView:CreateVerticalBox( "EMBAIXOESQ", 10,,,"FOLDER_INF","SHEET001_INF"   )
	oView:CreateVerticalBox( "EMBAIXOMEI", 80,,,"FOLDER_INF","SHEET001_INF"   )
	oView:CreateVerticalBox( "EMBAIXODIR", 10,,,"FOLDER_INF","SHEET001_INF"  )

	// Relacionando os Objetos Da Parte Superior da View com seux Boxs Esquerdo e direito
	oView:SetOwnerView( 'OGA460_NKN', 'SUPERIOR'	)

	//Relacionando Objetos da Parte Inferior
	oView:SetOwnerView( 'OGA460_CMP', 'EMBAIXOMEI'	)
	oView:SetOwnerView( 'OTHER_BTN' , 'EMBAIXODIR' 	)

	oView:SetAfterViewActivate({|oV| SetConMan(oV) })

	oView:SetCloseOnOk( {||.T.} )
Return oView

/** {Protheus.doc} OGA460CMP
Fun��o tela composi��o de pre�o

@author:    Equipe Agroind�stria
@since.:    12/04/2016
@Uso...:    OGA460 - Simula��o Composi��o de Pre�o
*/
Static Function OGA460CMP(oPanel, oObj)
	Local oModel    	:= FWModelActive()
	Local nOperation    := oModel:GetOperation()
	// -- Variaveis Da OGA420
	Local cProduto 		:= oModel:GetValue("OGA460_NKN", "NKN_CODPRO")
	Local cSimula		:= oModel:GetValue("OGA460_NKN", "NKN_CODSIM")
	Local cTipoSim		:= If(oModel:GetValue("OGA460_NKN", "NKN_TIPSIM") == '1',"C","V") //1=Compra#2=Venda
	Local cUm1Pro   	:= oModel:GetValue("OGA460_NKN", "NKN_UM1PRO") 
	Local cUm1Pre   	:= oModel:GetValue("OGA460_NKN", "NKN_UM1PRE")    
	Local dDtBase  		:= dDatabase
	Local dDEntrIni 	:= oModel:GetValue("OGA460_NKN", "NKN_DATINI")
	Local dDEntrFim 	:= oModel:GetValue("OGA460_NKN", "NKN_DATFIM")
	Local nMoeda 		:= oModel:GetValue("OGA460_NKN", "NKN_MOEDA")
	Local nQtSimula  	:= oModel:GetValue("OGA460_NKN", "NKN_QTDSIM")
	Local lEditar   	:= IF(nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE,.T., .F. )
	// --
	Private L460CriaTl 	:= .f.
	Private l460Insert	:= .f.
	Private OG460PANEL	:= oPanel

	//--<< Variaveis dos Gets (Rodape)>>--
	/*
	Private nPrcCalc1 := 0
	Private nPrcCalc2 	:= 0
	Private nVrMarg1	:= 0
	Private nVrMarg2	:= 0
	Private nPrcProp1	:= 0
	Private nPrcProp2	:= 0
	Private nSalMarg1	:= 0
	Private nSalMarg2	:= 0
	Private nQtidade  	:= 0
	Private nTotCalc	:= 0
	Private nTotProp	:= 0()
	Private cUmCtrato 	:= 0
	Private c1aUmProd 	:= ""
	Private nTratoMoed 	:= 0
	Private dDt_aFixar	:= ctod('//')
	Private cUmPreco	:= ""
	Private lEdit       := .f.
	Private aGrvNKA     := {}
	Private nVrPMarg 	:= 0  			//--<< Percentual de Margem em % >>-
	Private aUMNaoConv 	:= {} 			// Array Utilizado na verifica��o de Convers�o de Unidades de Medidas.
	*/
	IF ! nOperation = MODEL_OPERATION_INSERT
		dbSelectArea("NKA")
		dbSetOrder(1)
		If dbSeek(xFilial("NKA") + cSimula + ITEMFIX )
			IF Len ( _aCompPrc )== 0
				_aCompPrc := OGA420NKAR( cSimula , ITEMFIX ) //--<< Le a NKA e Recebe Retorno do Array com os Dados >>--
			EndIF
		EndIf
		L460CriaTl 	:= .T.
		l460Insert	:= .F.
		OGA420( cSimula , cProduto , dDtBase , dDEntrIni , dDEntrFim , nQtSimula , cTipoSim, cUm1Pro,cUm1Pre, nMoeda, _aCompPrc, lEditar )
	Else
		L460CriaTl 	:= .T. 
		l460Insert	:= .T.
		OGA420()
	EndIF 	
Return()

/** {Protheus.doc} SetConMan
Atribui a propriedade doubleclick da grid.
Tempor�rio at� sair a propriedade oficial do framework

@author:    Equipe Agroind�stria
@since.:    12/04/2016
@Uso...:    OGA460 - Simula��o Composi��o de Pre�o
*/
Static Function SetConMan(oView)
	Local oModel    	:= FWModelActive()
	Local nOperation	:= oModel:GetOperation()
	Local oCompPreco    := oView:GetViewObj("OGA460_CMP")[3]		//Objetos da Composi��o de Pre�o

	IF nOperation = MODEL_OPERATION_INSERT	// Inserindo 
		IF oCompPreco:IsActivate()
			oCompPreco:oOwner:lReadOnly := .T.
		EndIF
	EndIf
Return

/** {Protheus.doc} OGA460BTN
Bot�o da tela inferior

@author:    Equipe Agroind�stria
@since.:    12/04/2016
@Uso...:    OGA460 - Simula��o Composi��o de Pre�o
*/
Static Function OGA460BTN(oPanel,oView)
	Local lContinua		:= .T.
	Local oModel    	:= FWModelActive()
	Local nOperation    := oModel:GetOperation()
	Local lWhen			:= IIF(nOperation == MODEL_OPERATION_VIEW,.f.,.t. )	

	//@ nLinha,nColuna BUTTON cTexto SIZE nLargura,nAltura UNIDADE OF oObjetoRef ACTION A��O
	@ 010, 001 Button STR0019 Size 50, 15 Message STR0020 Pixel Action OGA460CMP01() of oPanel  When lWhen //"Ler Componentes"#"Ler Componentes de Pre�o"
		
	if TableInDic('NJ7')
		@ 030, 001 Button "Atualizar Taxas" Size 50, 15 Message "Atualiza as Taxas de Moeda e Indices de Mercado" Pixel Action OGA460AMI01() of oPanel  When lWhen //"Ler Componentes"#"Ler Componentes de Pre�o"
	endIf
		
Return lContinua

/** {Protheus.doc} OGA460AMI01
A��o do bot�o da tela inferior - Atualizar Taxas de Moeda e Indice de emercado

@author:    Claudineia Heerdt Reinert
@since.:    16/06/2017
@Uso...:    OGA460 - Simula��o Composi��o de Pre�o
*/
Static Function OGA460AMI01()
	Local oModel    	:= FWModelActive()
	Local oVldNKN		:= oModel:GetModel( "OGA460_NKN" )
	Local nOperation	:= oModel:GetOperation()
	Local oView			:= FwViewActive()
	Local cSimula		:= oModel:GetValue("OGA460_NKN", "NKN_CODSIM")
	Local cProduto 		:= oModel:GetValue("OGA460_NKN", "NKN_CODPRO")
	Local cUm1Pro   	:= oModel:GetValue("OGA460_NKN", "NKN_UM1PRO") 
	Local cUm1Pre   	:= oModel:GetValue("OGA460_NKN", "NKN_UM1PRE")  	
	Local nQtSimula  	:= oModel:GetValue("OGA460_NKN", "NKN_QTDSIM")
	Local dDEntrIni 	:= oModel:GetValue("OGA460_NKN", "NKN_DATINI")
	Local dDEntrFim 	:= oModel:GetValue("OGA460_NKN", "NKN_DATFIM")
	Local nMoeda 		:= oModel:GetValue("OGA460_NKN", "NKN_MOEDA")
	Local cTipoSim		:= If (oModel:GetValue("OGA460_NKN", "NKN_TIPSIM") == '1', "C", "V") //1=Compra#2=Venda
	Local dDtBase  		:= dDatabase	
	Local lEditar   	:= IF(nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE,.T., .F. )
	Local oCompPreco    := oView:GetViewObj("OGA460_CMP")[3] //Objetos da Composi��o de Pre�o
	Local nOpcAviso		:= ''
	Local lRetorno		:= .T.
	Private L460CriaTl  := .F. 
	Private lAtuTaxas	:= .F.

	If !oVldNKN:VldData()
		lRetorno := .F.
		oModel:GetModel():SetErrorMessage( oVldNKN:GetId(), , oVldNKN:GetId(), "", "", STR0021, STR0022, "", "")	//"Os campos - C�d.Produto, Quantidade, Entrega Ini., Entrega Fim, Moeda  e Tipo Sim. - est�o vazios."#"Por favor, informar todos os campos para Ler Componentes."
		oView:ShowLastError()
	Else 
		If dDEntrIni > dDEntrFim 
			lRetorno := .F.
			oModel:GetModel():SetErrorMessage(oVldNKN:GetId(), , oVldNKN:GetId(), "", "", STR0010, STR0011, "", "")	//"Data de In�cio de Entrega n�o pode ser maior que a Data Final de Entrega"#"Por favor, verifique as Datas de In�cio e Final de Entrega."
			oView:ShowLastError()
		Else 		
			oCompPreco:oOwner:lReadOnly := .F.	
			If !empty(aCompPrc)

				_aCompPRC := {} //limpa variavel
				// -- Alimentando a Variavel  Statica _aCompPRC com os Dados da Composi��o de Pre�os da tela
				StaticCall(OGA420, fArrayNKA, cSimula, nMoeda ,cUmPreco, cUm1Pro,aCompPrc,@_aCompPRC)

				nOpcAviso := AVISO( STR0023, STR0027, { STR0025, STR0026 }, 1)	//"Deseja Realmente Atualizar as Taxas de Moeda e Indices de Mercado?""Aten��o"#"Deseja realmente Reler os Componentes de Pre�o?"#"Sim"#"N�o" 

				If nOpcAviso == 1  	// Sim
					lAtuTaxas := .T. //seta para atualizar as taxas, ser� tratado no OGA420
					OGA420( cSimula , cProduto , dDtBase , dDEntrIni , dDEntrFim , nQtSimula , cTipoSim, cUm1Pro,cUm1Pre, nMoeda, _aCompPrc, lEditar)
				Else
					Return .F.
				EndIf
			Else
				Help( , , STR0002, , STR0028, 1, 0 ) //"N�o foi possivel ler os componentes da composi��o de pre�o" 	
				Return .F.
			EndIF

			//Seta para .F. quando realiza o recalculo da composi��o de pre�o
			_lLerComp := .F.
		EndIf 
	EndIf 

Return(lRetorno)

/** {Protheus.doc} OGA460CMP01
A��o do bot�o da tela inferior

@author:    Equipe Agroind�stria
@since.:    12/04/2016
@Uso...:    OGA460 - Simula��o Composi��o de Pre�o
*/
Static Function OGA460CMP01()
	Local oModel    	:= FWModelActive()
	Local oVldNKN		:= oModel:GetModel( "OGA460_NKN" )
	Local nOperation	:= oModel:GetOperation()
	Local oView			:= FwViewActive()
	Local cSimula		:= oModel:GetValue("OGA460_NKN", "NKN_CODSIM")
	Local cProduto 		:= oModel:GetValue("OGA460_NKN", "NKN_CODPRO")
	Local cUm1Pro   	:= oModel:GetValue("OGA460_NKN", "NKN_UM1PRO") 
	Local cUm1Pre   	:= oModel:GetValue("OGA460_NKN", "NKN_UM1PRE")  	
	Local nQtSimula  	:= oModel:GetValue("OGA460_NKN", "NKN_QTDSIM")
	Local dDEntrIni 	:= oModel:GetValue("OGA460_NKN", "NKN_DATINI")
	Local dDEntrFim 	:= oModel:GetValue("OGA460_NKN", "NKN_DATFIM")
	Local nMoeda 		:= oModel:GetValue("OGA460_NKN", "NKN_MOEDA")
	Local cTipoSim		:= If (oModel:GetValue("OGA460_NKN", "NKN_TIPSIM") == '1', "C", "V") //1=Compra#2=Venda
	Local dDtBase  		:= dDatabase	
	Local lEditar   	:= IF(nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE,.T., .F. )
	Local oCompPreco    := oView:GetViewObj("OGA460_CMP")[3]								//Objetos da Composi��o de Pre�o
	Local nOpcAviso		:= ''
	Local lRetorno		:= .T.

	Private L460CriaTl  := .F. 

	If !oVldNKN:VldData()
		lRetorno := .F.
		oModel:GetModel():SetErrorMessage( oVldNKN:GetId(), , oVldNKN:GetId(), "", "", STR0021, STR0022, "", "")	//"Os campos - C�d.Produto, Quantidade, Entrega Ini., Entrega Fim, Moeda  e Tipo Sim. - est�o vazios."#"Por favor, informar todos os campos para Ler Componentes."
		oView:ShowLastError()
	Else 
		//O array preenche com o Total sendo qe para ler os componentes na inclusao precisa do array VAZIO.
		If LEN(_aCompPrc) = 1
			_aCompPrc := {}
		EndIf

		If dDEntrIni > dDEntrFim 
			lRetorno := .F.
			oModel:GetModel():SetErrorMessage(oVldNKN:GetId(), , oVldNKN:GetId(), "", "", STR0010, STR0011, "", "")	//"Data de In�cio de Entrega n�o pode ser maior que a Data Final de Entrega"#"Por favor, verifique as Datas de In�cio e Final de Entrega."
			oView:ShowLastError()
		Else 		
			oCompPreco:oOwner:lReadOnly := .F.	
			IF !L460CriaTl .AND. !Empty( _aCompPrc ) 
				nOpcAviso := AVISO( STR0023, STR0024, { STR0025, STR0026 }, 1)	//"Aten��o"#"Deseja realmente Reler os Componentes de Pre�o?"#"Sim"#"N�o" 
				
				IF nOpcAviso == 1  	// Sim
					_aCompPrc := {} //Limpo o Array dos Componentes para for�ar re-ler os componentes no OGA420
				Else
					Return .F.
				EndIF
			EndIF
				
			OGA420( cSimula , cProduto , dDtBase , dDEntrIni , dDEntrFim , nQtSimula , cTipoSim, cUm1Pro,cUm1Pre, nMoeda, _aCompPrc, lEditar )
			lRetorno := .T. 
			
			//Seta para .F. quando realiza o recalculo da composi��o de pre�o
			_lLerComp := .F.
		EndIf 
		
	EndIf 
	
Return(lRetorno)

/** {Protheus.doc} fDeactivMD
Fun��o executada no Deactivate do modelo de dados

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	E Coelho
@since: 	12/04/2016
@Uso: 		AgroIndustria
*/
Static Function fDeactivMD( oModel )
	IF Type("oBrwComp") == "O"
		oBrwComp:Deactivate()
		oBrwComp := nil
	EndIF	
Return(.T.)

/** {Protheus.doc} OGA460EDIT
Fun��o para informar a edi��o dos campos necessarios da composi��o de pre�o

@param: 	oModel - Modelo de dados
@return:	.T.
@author: 	Equipe Agroindustria
@since: 	08/06/2016
@Uso: 		AgroIndustria
*/
Static Function OGA460EDIT(oModel,cAcao,cCampo,cVrNovo)
	IF cCampo $ 'NKN_CODPRO|NKN_QTDSIM|NKN_DATINI|NKN_DATFIM|NKN_MOEDA|NKN_TIPSIM' .AND. cAcao == 'SETVALUE'
		_lLerComp := .T.
	EndIF
Return(.T.)