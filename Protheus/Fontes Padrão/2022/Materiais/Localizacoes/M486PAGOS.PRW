#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "M486PAGOS.CH"
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} M486PAGOS
Permite el registro de los pagos realizados a una factura cuando la condición de Pago es Contado.
@type function
@author Autor 
@version versao
@since 09/08/2019
@return Nil
@obs 
@sample
/*/
//--------------------------------------------------------------------------------------------------------
Function M486PAGOS(cEsp,cCodDoc, cSerDoc, cClidoc, cLojDoc,cCondPag,nTotal,nOperation)

	Local aArea 	:= GetArea()
	Local oExecView	:= Nil 
	Local oModel	:= Nil
	Local cTipo   	:= "" 
	Local lContado 	:= .f.
	
	Default cEsp 	:= SF2->F2_ESPECIE
	Default cCodDoc:= SF2->F2_DOC
	Default cSerDoc:= SF2->F2_SERIE
	Default cClidoc:= SF2->F2_CLIENTE
	Default cLojDoc:= SF2->F2_LOJA
	Default nOperation := 4
  	 
  	lcontado := POSICIONE("SE4",1,XFILIAL("SE4") + cCondPag, "E4_BXTITAV") == "1"
	If !lContado
		Return Nil
	EndIF
	
	Aviso(STR0020,STR0012 + CHR(13) + CHR(10) + ; 	// "La siguiente pantalla permite capturar los Pagos realizados a una Factura con " 
					 STR0013 + CHR(13) + CHR(10) + ;	// "Condición de Pago de Contado. Si omite este paso, el documento digital (XML)  "
					 STR0014,{STR0023}) 				 	// "contendrá errores y  no será autorizado."
					 
	
	oModel := FWLoadModel("M486PAGOS")
	oModel:SetOperation(nOperation)
	oModel:GetModel("F7LMASTER"):bLoad := {|| {xFilial("F7L"),cCoddoc,cSerDoc,cCliDoc,cLojDoc,cCondPag,nTotal}}
	oModel:Activate() 
	
	oView := FWLoadView("M486PAGOS")
	oView:SetModel(oModel)
	oView:SetOperation(nOperation) 
			  	
	oExecView:= FWViewExec():New()
	oExecView:SetTitle(STR0024) 
	oExecView:SetView(oView)
	oExecView:SetModal(.F.)
	oExecView:SetCloseOnOK({|| .T. })
	oExecView:SetOperation(nOperation)
	oExecView:OpenView(.T.)
	
	oModel:DeActivate()
	
	RestArea(aArea)
Return Nil
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Exemplo da criaçao do Menu usando MVC.
@type function
@author Autor 
@version versao
@since 09/08/2019
@return Nil
@obs 
@sample
/*/
//--------------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0001 	Action 'VIEWDEF.M486PAGOS' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.M486PAGOS' OPERATION 3 ACCESS 0 // 'Incluir' 
	ADD OPTION aRotina Title STR0003 	Action 'VIEWDEF.M486PAGOS' OPERATION 4 ACCESS 0 // 'Modificar'
	ADD OPTION aRotina Title STR0004 	Action 'VIEWDEF.M486PAGOS' OPERATION 5 ACCESS 0 // 'Excluir'
	ADD OPTION aRotina Title STR0005 	Action 'VIEWDEF.M486PAGOS' OPERATION 8 ACCESS 0 // 'Imprimir'
	ADD OPTION aRotina Title STR0006	Action 'VIEWDEF.M486PAGOS' OPERATION 9 ACCESS 0 // 'Copiar'
Return aRotina
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Exemplo da criação do Model usando MVC
@type function
@author Autor 
@version versao
@since 09/08/2019
@return oModel
@obs 
@sample
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ModelDef()
	// Cria as estruturas a serem usadas no Modelo de Dados
	Local oStruF7LMASTER 	:= FWFormStruct( 1, 'F7L' ,{ | cCampo |  (AllTrim(cCampo)	$ "F7L_FILIAL|F7L_DOC|F7L_SERIE|F7L_CLIENT|F7L_LOJA|F7L_COND|F7L_DESC1") })
	Local oStruF7LFil 		:= FWFormStruct( 1, 'F7L' ,{ | cCampo | !(AllTrim(cCampo) 	$ "F7L_FILIAL|F7L_DOC|F7L_SERIE|F7L_CLIENT|F7L_LOJA|F7L_COND|F7L_DESC1") })
	Local oModel // Modelo de dados construído
	
	// Campos virutales en el encabezado
	oStruF7LMASTER:AddField(  ;      	// Ord. Tipo Desc.
	STR0018			, ;	// [01]  C   Titulo do campo //"Descripción"
	STR0018			, ;	// [02]  C   ToolTip do campo //"Descripción de resp/tributo"
	'F7L_DESC1'		, ;	// [03]  C   Id do Field
	'N'				, ;	// [04]  C   Tipo do campo
	15				, ;	// [05]  N   Tamanho do campo
	2				, ;	// [06]  N   Decimal do campo
	NIL				, ;	// [07]  B   Code-block de validação do campo
	NIL				, ;	// [08]  B   Code-block de validação When do campo
	NIL           	, ;	// [09]  A   Lista de valores permitido do campo
	.F.           	, ;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	NIL				, ;	// [11]  B   Code-block de inicializacao do campo
	NIL				, ;	// [12]  L   Indica se trata-se de um campo chave
	NIL				, ;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.				) 	// [14]  L   Indica se o campo é virtual
	
	// Campos virutales en el detalle
	oStruF7LFil:AddField(  ;      	// Ord. Tipo Desc.
	STR0019			, ;	// [01]  C   Titulo do campo //"Descripción"
	STR0019			, ;	// [02]  C   ToolTip do campo //"Descripción de resp/tributo"
	'F7L_DESC2'		, ;	// [03]  C   Id do Field
	'C'				, ;	// [04]  C   Tipo do campo
	80				, ;	// [05]  N   Tamanho do campo
	0				, ;	// [06]  N   Decimal do campo
	NIL				, ;	// [07]  B   Code-block de validação do campo
	NIL				, ;	// [08]  B   Code-block de validação When do campo
	NIL           	, ;	// [09]  A   Lista de valores permitido do campo
	.F.           	, ;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	NIL				, ;	// [11]  B   Code-block de inicializacao do campo
	NIL				, ;	// [12]  L   Indica se trata-se de um campo chave
	NIL				, ;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.				) 	// [14]  L   Indica se o campo é virtual
	
	oStruF7LFil:AddField(  ;      	// Ord. Tipo Desc.
	STR0017			, ;	// [01]  C   Titulo do campo //"Desc. Tipo Tarjeta"
	STR0017			, ;	// [02]  C   ToolTip do campo //"Desc. Tipo Tarjeta"
	'F7L_DESC3'		, ;	// [03]  C   Id do Field
	'C'				, ;	// [04]  C   Tipo do campo
	80				, ;	// [05]  N   Tamanho do campo
	0				, ;	// [06]  N   Decimal do campo
	NIL				, ;	// [07]  B   Code-block de validação do campo
	NIL				, ;	// [08]  B   Code-block de validação When do campo
	NIL           	, ;	// [09]  A   Lista de valores permitido do campo
	.F.           	, ;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	NIL				, ;	// [11]  B   Code-block de inicializacao do campo
	NIL				, ;	// [12]  L   Indica se trata-se de um campo chave
	NIL				, ;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.				) 	// [14]  L   Indica se o campo é virtual
	
	oStruF7LFil:AddField(  ;      	// Ord. Tipo Desc.
	STR0015			, ;	// [01]  C   Titulo do campo //"Desc. Form. Proc. Pago"
	STR0015			, ;	// [02]  C   ToolTip do campo //"Desc. Form. Proc. Pago"
	'F7L_DESC4'		, ;	// [03]  C   Id do Field
	'C'				, ;	// [04]  C   Tipo do campo
	80				, ;	// [05]  N   Tamanho do campo
	0				, ;	// [06]  N   Decimal do campo
	NIL				, ;	// [07]  B   Code-block de validação do campo
	NIL				, ;	// [08]  B   Code-block de validação When do campo
	NIL           	, ;	// [09]  A   Lista de valores permitido do campo
	.F.           	, ;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	NIL				, ;	// [11]  B   Code-block de inicializacao do campo
	NIL				, ;	// [12]  L   Indica se trata-se de um campo chave
	NIL				, ;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.				) 	// [14]  L   Indica se o campo é virtual
	
	oStruF7LFil:AddField(  ;      	// Ord. Tipo Desc.
	STR0016			, ;	// [01]  C   Titulo do campo //"Desc. Banco"
	STR0016			, ;	// [02]  C   ToolTip do campo //"Desc. Banco"
	'F7L_DESC5'		, ;	// [03]  C   Id do Field
	'C'				, ;	// [04]  C   Tipo do campo
	80				, ;	// [05]  N   Tamanho do campo
	0				, ;	// [06]  N   Decimal do campo
	NIL				, ;	// [07]  B   Code-block de validação do campo
	NIL				, ;	// [08]  B   Code-block de validação When do campo
	NIL           	, ;	// [09]  A   Lista de valores permitido do campo
	.F.           	, ;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	NIL				, ;	// [11]  B   Code-block de inicializacao do campo
	NIL				, ;	// [12]  L   Indica se trata-se de um campo chave
	NIL				, ;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.				) 	// [14]  L   Indica se o campo é virtual
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('M486PAGOS',,,,{ | oMdl | M486CAN(oMdl)} )
	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'F7LMASTER', /*cOwner*/, oStruF7LMASTER ,,{ | oMdl | M486POS(oMdl) })
	// Adiciona ao modelo uma componente de grid
	oModel:AddGrid( 'F7LDETAIL', 'F7LMASTER', oStruF7LFil,, )
	// Faz relacionamento entre os componentes do model
	oModel:SetRelation('F7LDETAIL', { { 'F7L_FILIAL', 'xFilial( "F7L" )' }, {'F7L_DOC','F7L_DOC'},{ 'F7L_SERIE','F7L_SERIE'}, {'F7L_CLIENT','F7L_CLIENT'},{'F7L_LOJA','F7L_LOJA'} }, F7L->( IndexKey(2) ) )
	oModel:GetModel('F7LMASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('F7LDETAIL'):SetOptional(.T.)
	oModel:GetModel('F7LDETAIL'):SetUniqueLine({'F7L_SEQ' })	
	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription(STR0007) // 'Factura de Venta '
	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel('F7LMASTER'):SetDescription(STR0008) // 'Datos Factura de Venta'
	oModel:GetModel('F7LDETAIL'):SetDescription(STR0009) // 'Registro de Pagos'
	oModel:SetPrimaryKey( {} )
	// Retorna o Modelo de dados
Return oModel
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Exemplo da criaçao da View usando MVC.
@type function
@author Autor 
@version versao
@since 09/08/2019
@return oView
@obs 
@sample
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de dados baseado no ModelDef do fonteinformado
	Local oModel := FWLoadModel('M486PAGOS')
	// Cria as estruturas a serem usadas na View
	Local oStruF7LMASTER 	:= FWFormStruct( 2, 'F7L', { | cCampo |   (AllTrim(cCampo)  $ "F7L_FILIAL|F7L_DOC|F7L_SERIE|F7L_CLIENT|F7L_LOJA|F7L_COND|F7L_DESC1")} )
	Local oStruF7LFil 		:= FWFormStruct( 2, 'F7L', { | cCampo |  !(AllTrim(cCampo)  $ "F7L_FILIAL|F7L_DOC|F7L_SERIE|F7L_CLIENT|F7L_LOJA|F7L_COND|F7L_DESC1")} )
	// Interface de visualização construída
	Local oView
	//Campos no ediatbles
	oStruF7LMASTER:SetProperty("F7L_DOC"	, MVC_VIEW_CANCHANGE, .F.)
	oStruF7LMASTER:SetProperty("F7L_SERIE" 	, MVC_VIEW_CANCHANGE, .F.)
	oStruF7LMASTER:SetProperty("F7L_CLIENT" , MVC_VIEW_CANCHANGE, .F.)
	oStruF7LMASTER:SetProperty("F7L_LOJA" 	, MVC_VIEW_CANCHANGE, .F.)
	oStruF7LMASTER:SetProperty("F7L_COND" 	, MVC_VIEW_CANCHANGE, .F.)
	
	// Cria o objeto de View
	oView := FWFormView():New()
	// Define qual Modelo de dados será utilizado
	oView:SetModel( oModel )
	
	// Campos Virtuales Encabezado
	oStruF7LMASTER:AddField(; 	      // Ord. Tipo Desc.
	'F7L_DESC1'		, ;      // [01]  C   Nome do Campo
	'ZZ'			, ;      // [02]  C   Ordem
	STR0018			, ;      // [03]  C   Titulo do campo //"Total Factura"
	STR0018			, ;      // [04]  C   Descricao do campo //"Total Factura"
	{ "" }			, ;      // [05]  A   Array com Help //"Descripción"
	'N' 			, ;      // [06]  C   Tipo do campo
	'999999999999.99', ;      // [07]  C   Picture
	NIL    			, ;      // [08]  B   Bloco de Picture Var
	''           	, ;      // [09]  C   Consulta F3
	.F.				, ;      // [10]  L   Indica se o campo é alteravel
	NIL           	, ;      // [11]  C   Pasta do campo
	NIL           	, ;      // [12]  C   Agrupamento do campo
	NIL           	, ;      // [13]  A   Lista de valores permitido do campo (Combo)
	NIL           	, ;      // [14]  N   Tamanho maximo da maior opção do combo
	NIL           	, ;      // [15]  C   Inicializador de Browse
	.T.				, ;      // [16]  L   Indica se o campo é virtual
	NIL				, ;      // [17]  C   Picture Variavel
	NIL				)        // [18]  L   Indica pulo de linha após o campo
	
	// Campos Virtuales Detalle
	oStruF7LFil:AddField(; 	      // Ord. Tipo Desc.
	'F7L_DESC2'		, ;      // [01]  C   Nome do Campo
	'09'			, ;      // [02]  C   Ordem
	STR0019			, ;      // [03]  C   Titulo do campo //"Desc. Tipo Pago"
	STR0019			, ;      // [04]  C   Descricao do campo //"Desc. Tipo Pago"
	{ "" }			, ;      // [05]  A   Array com Help //"Descripción"
	'C' 			, ;      // [06]  C   Tipo do campo
	'@!'			, ;      // [07]  C   Picture
	NIL    			, ;      // [08]  B   Bloco de Picture Var
	''           	, ;      // [09]  C   Consulta F3
	.F.				, ;      // [10]  L   Indica se o campo é alteravel
	NIL           	, ;      // [11]  C   Pasta do campo
	NIL           	, ;      // [12]  C   Agrupamento do campo
	NIL           	, ;      // [13]  A   Lista de valores permitido do campo (Combo)
	NIL           	, ;      // [14]  N   Tamanho maximo da maior opção do combo
	NIL           	, ;      // [15]  C   Inicializador de Browse
	.T.				, ;      // [16]  L   Indica se o campo é virtual
	NIL				, ;      // [17]  C   Picture Variavel
	NIL				)        // [18]  L   Indica pulo de linha após o campo
	
	oStruF7LFil:AddField(;    // Ord. Tipo Desc.
	'F7L_DESC3'		, ;      // [01]  C   Nome do Campo
	'11'			, ;      // [02]  C   Ordem
	STR0017			, ;      // [03]  C   Titulo do campo //"Desc. Tipo Tarjeta"
	STR0017			, ;      // [04]  C   Descricao do campo //"Desc. Tipo Tarjeta"
	{ "" }			, ;      // [05]  A   Array com Help //"Descripción"
	'C' 			, ;      // [06]  C   Tipo do campo
	'@!'			, ;      // [07]  C   Picture
	NIL    			, ;      // [08]  B   Bloco de Picture Var
	''           	, ;      // [09]  C   Consulta F3
	.F.				, ;      // [10]  L   Indica se o campo é alteravel
	NIL           	, ;      // [11]  C   Pasta do campo
	NIL           	, ;      // [12]  C   Agrupamento do campo
	NIL           	, ;      // [13]  A   Lista de valores permitido do campo (Combo)
	NIL           	, ;      // [14]  N   Tamanho maximo da maior opção do combo
	NIL           	, ;      // [15]  C   Inicializador de Browse
	.T.				, ;      // [16]  L   Indica se o campo é virtual
	NIL				, ;      // [17]  C   Picture Variavel
	NIL				)        // [18]  L   Indica pulo de linha após o campo
	
	oStruF7LFil:AddField(; 	      // Ord. Tipo Desc.
	'F7L_DESC4'		, ;      // [01]  C   Nome do Campo
	'12'			, ;      // [02]  C   Ordem
	STR0015			, ;      // [03]  C   Titulo do campo //"Desc. Forma Proc. Pago"
	STR0015			, ;      // [04]  C   Descricao do campo //"Desc. Forma Proc. Pago"
	{ "" }			, ;      // [05]  A   Array com Help //"Descripción"
	'C' 			, ;      // [06]  C   Tipo do campo
	'@!'			, ;      // [07]  C   Picture
	NIL    			, ;      // [08]  B   Bloco de Picture Var
	''           	, ;      // [09]  C   Consulta F3
	.F.				, ;      // [10]  L   Indica se o campo é alteravel
	NIL           	, ;      // [11]  C   Pasta do campo
	NIL           	, ;      // [12]  C   Agrupamento do campo
	NIL           	, ;      // [13]  A   Lista de valores permitido do campo (Combo)
	NIL           	, ;      // [14]  N   Tamanho maximo da maior opção do combo
	NIL           	, ;      // [15]  C   Inicializador de Browse
	.T.				, ;      // [16]  L   Indica se o campo é virtual
	NIL				, ;      // [17]  C   Picture Variavel
	NIL				)        // [18]  L   Indica pulo de linha após o campo
	
	oStruF7LFil:AddField(; 	      // Ord. Tipo Desc.
	'F7L_DESC5'		, ;      // [01]  C   Nome do Campo
	'15'			, ;      // [02]  C   Ordem
	STR0016			, ;      // [03]  C   Titulo do campo //"Desc. Banco"
	STR0016			, ;      // [04]  C   Descricao do campo //"Desc. Banco"
	{ "" }			, ;      // [05]  A   Array com Help //"Descripción"
	'C' 			, ;      // [06]  C   Tipo do campo
	'@!'			, ;      // [07]  C   Picture
	NIL    			, ;      // [08]  B   Bloco de Picture Var
	''           	, ;      // [09]  C   Consulta F3
	.F.				, ;      // [10]  L   Indica se o campo é alteravel
	NIL           	, ;      // [11]  C   Pasta do campo
	NIL           	, ;      // [12]  C   Agrupamento do campo
	NIL           	, ;      // [13]  A   Lista de valores permitido do campo (Combo)
	NIL           	, ;      // [14]  N   Tamanho maximo da maior opção do combo
	NIL           	, ;      // [15]  C   Inicializador de Browse
	.T.				, ;      // [16]  L   Indica se o campo é virtual
	NIL				, ;      // [17]  C   Picture Variavel
	NIL				)        // [18]  L   Indica pulo de linha após o campo
	// Adiciona no nosso View um controle do tipo formulário (antigaEnchoice)
	oView:AddField('VIEW_F7LMASTER', oStruF7LMASTER, 'F7LMASTER' )
	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid('VIEW_F7LDETAIL', oStruF7LFil, 'F7LDETAIL' )
	oView:AddIncrementField('VIEW_F7LDETAIL', 'F7L_SEQ')
	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox('SUPERIOR', 25)
	oView:CreateHorizontalBox('INFERIOR', 75)
	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_F7LMASTER', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_F7LDETAIL', 'INFERIOR' )
	// Retorna o objeto de View criado
	oView:SetFieldAction( 'F7L_TPPAGO'	, { |oView| M486SHOWDES(oView,'1')	} )
	oView:SetFieldAction( 'F7L_TPTAR '	, { |oView| M486SHOWDES(oView,'2')	} )
	oView:SetFieldAction( 'F7L_FRMPRO '	, { |oView| M486SHOWDES(oView,'3')	} )
	oView:SetFieldAction( 'F7L_CODBCO '	, { |oView| M486SHOWDES(oView,'4')	} )  
	oView:SetAfterViewActivate({|oView| M486VISTA(oView)}) 
Return oView

/*/{Protheus.doc} M486ACTFLDS
Activa o desactiva edición de campos dependiendo del tipo de pago F7L_TPPAGO
@type
@author mayra.camargo
@since 14/08/2019
@version 1.0
@return lActivo}, Indica si será o no editable el campo
@example
(examples)
@see (links_or_references)a
/*/
Function M486ACTFLDS()
	Local lActivo	:= .F.
	Local oMdl := FWModelActive() // obtiene el Modelo activo
	Local oMdl1:= oMdl:getmodel('F7LDETAIL') 
	Local cTpPago := ""
	Local cCampo := ReadVar()
	cCampo := STRTRAN(cCampo,"M->","")
	cTpPago := oMdl1:getvalue("F7L_TPPAGO")
	If (cTpPago $ "3 |4 |"  .AND. cCampo $ "F7L_TPTAR|F7L_FRMPRO|F7L_CODOPE|F7L_NUMTRJ") .or.  (cTpPago $ "2 |" .AND. cCampo $ "F7L_CODBCO|F7L_NUMCQH")
		lActivo := .T.	
	EndIf
Return lActivo

/*
Static function  M486CHGLINE(oview,cViewid) //M486LPRE(oModelGrid, nLine, cAction, cField)
	Local lRet := .t.
	Local aLnGrid := {}
	Local oMdl := FWModelActive()
	Local oMdlDet	:= oMdl:GetModel('AIUDETAIL')
	Local nPos := 0
	Local nTGrid := 0
	Local nI := 0
	
	aLnGrid := aClone(oMdlDet:ACols)
	nPos 	:= aScan(oMdlDet:aHeader, { |x,y| x[2] == "AIU_MONTO"} )
	nRet	:= 0
	
	For nI := 1 To len(aLnGrid)	
		If !oMdlDet:IsDeleted(nI)
			nTGrid += aLnGrid[nI,nPos]	
		EndIf		
	Next nI
	If nTGrid <> SF2->F2_VALBRUT
		lRet := .F.
		Help( ,, STR0010,, STR0011 ,1, 0 )   // "Aviso" // "La sumatoria de los Pagos difiere del total de la Factura"			
	EndIf
Return lRet*/
/*/{Protheus.doc} M486POS
Validación de grid, para que sume el total del monto hasta alcanzar el total de la factura.
@type
@author mayra.camargo
@since 14/08/2019
@version 1.0
@return lActivo, 
@example
(examples)
@see (links_or_references)
/*/
Function  M486POS(oMdl1) 
	Local lRet := .t.
	Local aLnGrid := {}
	Local oMdl := FWModelActive()
	Local oMdlDet	:= oMdl:GetModel('F7LDETAIL')
	Local nPos := 0
	Local nTGrid := 0
	Local nI := 0
	
	aLnGrid := aClone(oMdlDet:ACols)
	nPos 	:= aScan(oMdlDet:aHeader, { |x,y| x[2] == "F7L_MONTO"} )
	nRet	:= 0
	
	/*For nI := 1 To len(aLnGrid)	
		If !oMdlDet:IsDeleted(nI)
			nTGrid += aLnGrid[nI,nPos]	
		EndIf		
	Next nI*/
	For nI := 1 To oMdlDet:Length()
		oMdlDet:GoLine( nI )
		If !oMdlDet:IsDeleted()
			nTGrid += oMdlDet:getValue("F7L_MONTO")
		EndIf
	Next nI
	
	
	If nTGrid <> SF2->F2_VALBRUT
		lRet := .F.
		Help( ,, STR0010,, STR0011 ,1, 0 )   // "Aviso" // "La sumatoria de los Pagos difiere del total de la Factura"			
	EndIf	

Return lRet
/*/{Protheus.doc} M486VISTA(oView)
actualiza descripciones al cargar la vista
@type
@author mayra.camargo
@since 14/08/2019
@version 1.0
@return lActivo, 
@example
(examples)
@see (links_or_references)a
/*/
Function M486VISTA(oView)
	Local oModel 	 	:= FWModelActivate()
	Local oModelF7L		:= oModel:GetModel('F7LDETAIL')
	Local nOperation 	:= oModel:GetOperation()
	Local nX         	:= 0
	Local cDesc      	:= ""
	
	If nOperation == 4 
		For nX:= 1 to oModelF7L:Length()
			oModelF7L:GoLine(nX)
			cValor 	:= oModelF7L:GetValue("F7L_TPPAGO") 
			cDesc  	:= alltrim(ObtColSAT("S013", cValor , 1, 2, 3,80))			
			If !Empty(cDesc)
				oModelF7L:LoadValue( 'F7L_DESC2' , cDesc)
			EndIf	
			cValor	:= 	oModelF7L:GetValue("F7L_TPTAR")
			cDesc 	:= alltrim(ObtColSAT("S014", cValor , 1, 1, 2,20))			
			If !Empty(cDesc)
				oModelF7L:LoadValue( 'F7L_DESC3' , cDesc)
			EndIf	
			cValor	:= 	oModelF7L:GetValue("F7L_FRMPRO")
			cDesc 	:= alltrim(ObtColSAT("S032", cValor , 1,1, 2,80))
			If !Empty(cDesc)
				oModelF7L:LoadValue( 'F7L_DESC4' , cDesc)
			EndIf
			cValor	:= 	oModelF7L:GetValue("F7L_CODBCO")
			cDesc 	:= POSICIONE("SA6",1, XFILIAL("SA6") + PADR(cValor,TAMSX3("A6_COD")[1]), "A6_NOME")
			If !Empty(cDesc)
				oModelF7L:LoadValue( 'F7L_DESC5' , cDesc)
			EndIf	
		Next nX
	EndIf	
	
	oModelF7L:GoLine(1)
	oView:Refresh()		
Return
/*/{Protheus.doc} M486SHOWDESC(oView,cOp)
actualiza descripciones dependiendo de cOp
@type
@author mayra.camargo
@since 14/08/2019
@version 1.0
@return lActivo, 
@example
(examples)
@see (links_or_references)a
/*/
Function M486SHOWDESC(oView,cOp)

	Local cValor		:= ""
	Local aValores 		:= {}
	Local cDesc			:= ""
	Local nI			:= 0
	Local nPos1			:= 0
	local oModel 		:= FWModelActivate()
	Local omodelGrid	:= omodel:getmodel('F7LDETAIL')	
	Local cTabla		:= ""
	
	If cOp == "1"
		cValor	:= 	omodelGrid:GetValue("F7L_TPPAGO")
		cDesc  	:= 	alltrim(ObtColSAT("S013", cValor , 1, 2, 3,80))
		cCampo 	:=	"F7L_DESC2"
		
		// Limpiar campos que no se usan
		If cValor == "2 " // cheque
			oModel:LoadValue('F7LDETAIL', "F7L_TPTAR" 	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_FRMPRO"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_CODOPE"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_NUMTRJ"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_DESC2"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_DESC3"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_DESC4"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_DESC5"	, "")
		ElseIf cValor $ "3 |4 " // tarjeta debito ocrédito
			oModel:LoadValue('F7LDETAIL', "F7L_CODBCO" 	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_NUMCQH"	, "")
		Else
			oModel:LoadValue('F7LDETAIL', "F7L_TPTAR" 	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_FRMPRO"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_CODOPE"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_NUMTRJ"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_DESC2"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_DESC3"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_DESC4"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_DESC5"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_CODBCO"	, "")
			oModel:LoadValue('F7LDETAIL', "F7L_NUMCQH"	, "")
		EndIf
	ElseIf cOp == "2"
		cValor	:= 	omodelGrid:GetValue("F7L_TPTAR")
		cDesc := alltrim(ObtColSAT("S014", cValor , 1, 1, 2,20))
		cCampo := "F7L_DESC3"	
	ElseIf cOp == "3"
		cValor	:= 	omodelGrid:GetValue("F7L_FRMPRO")
		cDesc := alltrim(ObtColSAT("S032", cValor , 1,1, 2,80))
		cCampo := "F7L_DESC4"
	ElseIf cOp == "4"
		cValor	:= 	omodelGrid:GetValue("F7L_CODBCO")
		cDesc := POSICIONE("SA6",1, XFILIAL("SA6") + PADR(cValor,TAMSX3("A6_COD")[1]), "A6_NOME")
		cCampo := "F7L_DESC5"	
	EndIf
	If !Empty(cDesc)		
		oModel:LoadValue( 'F7LDETAIL', cCampo	, cDesc)
	EndIf
	oView:Refresh()	
Return .T.
/*/{Protheus.doc} M486CAN(oMdl)
Ejecuta validación al cancelar la grabación del formulario.
@type
@author mayra.camargo
@since 14/08/2019a
@version 1.0
@return lActivo, 
@example
(examples)
@see (links_or_references)a
/*/
Function M486CAN(oMdl)
	Local lRet := .T.	
	lRet := M486POS(oMdl) 
	If !lRet 
		Help( ,, STR0010,,STR0021,1, 0,,,,,,{STR0022} )   // "Aviso" // "Debe registrar al menos un Pago que cubra el Total de la Factura. "
	EndIf
Return lRet
