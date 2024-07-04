#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "report.ch"
#Include 'TOTVS.ch'
#include 'plsa977ab.ch'
#Include 'TBICONN.CH'
#Include 'TBICODE.CH'
#Include 'TopConn.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA977AB
Funcao para abrir a tela de análise de beneficiários
@author Karine Riquena Limp
@since 23/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA977AB()

	Local cFilter := ""

	//executa o filtro novamente
	SetKey(VK_F12,{|| PlLoadAnz() })

	If Pergunte("PLANBEN",.T., "Análise de Beneficiário")

		//Instancia objeto
		oBrowse := FWMBrowse():New()

		//Define tabela de origem do Browse
		oBrowse:SetAlias('BBA')

		//Define nome da tela
		oBrowse:SetDescription(FunDesc())

		cFilter := "BBA_TIPSOL == '2' .AND. BBA_TIPMAN == '" + ALLTRIM( STR( MV_PAR01)) + "' "

		//Ponto de entrada que permite incluir mais condições no filtro
		If ExistBlock("PLINCBEN")
			cFilter += " .AND. " + ExecBlock("PLINCBEN",.F.,.F.)
		Endif

		// Ponto de Entrada para alterar todo o Filtro
		If ExistBlock("PL977FIL")
			cFilter := ExecBlock("PL977FIL", .F., .F., {cFilter})
		Endif

		oBrowse:SetFilterDefault(cFilter)

		//Adiciona Legenda
		//1=Pendente de documentação;2=Em análise;3=Processado;4=Aprovado;5=Rejeitado;6=Aprovado parcialmente;7=Aprovado Automaticamente
		oBrowse:AddLegend( "PL977ABLEG()=='1'"	, "YELLOW"	, STR0001)
		oBrowse:AddLegend( "PL977ABLEG()=='2'"	, "ORANGE"	, STR0002)
		oBrowse:AddLegend( "PL977ABLEG()=='3'"	, "GREEN"	, STR0003)
		oBrowse:AddLegend( "PL977ABLEG()=='4'"	, "BLUE"	, STR0004)
		oBrowse:AddLegend( "PL977ABLEG()=='5'"	, "RED"	, STR0005)
		oBrowse:AddLegend( "PL977ABLEG()=='6'"	, "BROWN"	, STR0006)
		oBrowse:addLegend( "PL977ABLEG()=='7'"	, "PINK"	, STR0044) //Esse Status é para quado o que foi alterado não gera nenhum registro de análise, tudo já foi alterado na tabela final

		// Ponto de Entrada para adicionar mais legendas 
		If ExistBlock("PL977LEG")
			oBrowse := ExecBlock("PL977LEG", .F., .F., {oBrowse})
		EndIf

		oBrowse:Activate()
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Karine Riquena Limp
@since 23/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	Local aBotAdd := {}

	Add Option aRotina Title  STR0007 /*'Visualizar'*/	Action 'VIEWDEF.PLSA977AB' Operation 2 Access 0
	Add Option aRotina Title  STR0008 /*'Analisar'*/  	Action 'VIEWDEF.PLSA977AB' Operation 4 Access 0
	Add Option aRotina Title  STR0009 /*'Imprimir'*/  	Action 'VIEWDEF.PLSA977AB' Operation 8 Access 0
	ADD OPTION aRotina TITLE  STR0056 ACTION "FwMsgRun(,{|| PL977MobAtualiza()},,'"+STR0057+"')" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Atualizar Status" ; "Atualizando status do protocolo ..."

	//Adiciona opções extras no menu 'Outras Ações'
	AAdd(aRotina, { STR0010/*'Gerar Grupo Familiar'*/	, "PLGERGRPFA()"	, 0, 0} )

	If ExistBlock("PL977MEN")
		aBotAdd := ExecBlock("PL977MEN",.F.,.F.,{aRotina})

		If ValType(aBotAdd) == "A"
			AEval(aBotAdd, {|x| aAdd(aRotina, x)})
		EndIf
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Karine Riquena Limp
@since 23/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStrBBA := FWFormStruct(1,'BBA')
	Local oStrB2N	:= NIL
	Local oStrBA1	:= NIL
	Local oStrB5G := FWFormStruct(1,'B5G',  { |cCampo| PL977AB5GM(cCampo)})
	Local oStrB4H := FWFormStruct(1,'B4H')
	Local aAux := nil
	Local cCodInt	:= PLSINTPAD()

	oModel := MPFormModel():New( 'PLSA977AB',, { |oModel| PLS977ABOK(oModel) }  )
	aAux := {}
	aAux := FwStruTrigger(;
		'BBA_CODEMP' ,;
		'BBA_DESGRP' ,;
		'BG9->BG9_DESCRI',;
		.T.            ,;
		'BG9'          ,;
		1              ,;
		'xFilial("BG9")+PLSINTPAD()+M->BBA_CODEMP',; //OmODEL:GETmODEL("MasterBBA"):getValue("BBA_CODEMP")
		'BG9->BG9_TIPO == "1" ' )

	oStrBBA:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

	aAux := FwStruTrigger(;
		'BBA_CODPRO' ,;
		'BBA_DESPRO' ,;
		'BI3->BI3_DESCRI',;
		.T.            ,;
		'BI3'          ,;
		1              ,;
		'xFilial("BI3")+PLSINTPAD()+M->BBA_CODPRO',;
		'(BI3->BI3_TIPO == "1" .Or. BI3->BI3_TIPO == "3") .and. BI3->BI3_STATUS <> "2" .and. BI3->BI3_GRUPO == "001" ' ) //condicao

	oStrBBA:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

	aAux := FwStruTrigger(;
		'BBA_CODPRO' ,;
		'BBA_VERSAO' ,;
		'BI3->BI3_VERSAO',;
		.T.            ,;
		'BI3'          ,;
		1              ,;
		'xFilial("BI3")+PLSINTPAD()+M->BBA_CODPRO',;
		'(BI3->BI3_TIPO == "1" .Or. BI3->BI3_TIPO == "3") .and. BI3->BI3_STATUS <> "2" .and. BI3->BI3_GRUPO == "001" ' ) //condicao

	oStrBBA:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )


	oModel:addFields('MasterBBA', ,oStrBBA)  // Adiciona ao modelo um componente de formulário

	oModel:AddGrid('B5GDetail', 'MasterBBA', oStrB5G, { |oMdlG,nLine,cAcao,cCampo| Vld813Del( oMdlG, nLine, cAcao, cCampo ) }, { |oB5G,nLine| PLS977VLDI(oB5G,nLine)})
	oModel:AddGrid('B4HDetail', 'B5GDetail', oStrB4H)

	oModel:SetRelation( 'B5GDetail', { { 'B5G_FILIAL' 	, 'xFilial( "B5G" )' },;
		{ 'B5G_CODINT'	, 'BBA_CODINT'       },;
		{ 'B5G_CODBEN'	, 'BBA_CODSEQ'		} },;//Passos da Análise
		B5G->( IndexKey(  ) ) )

	oModel:SetRelation( 'B4HDetail', { { 'B4H_FILIAL' 	, 'xFilial( "B4H" )' },;
		{ 'B4H_CODSEQ'	, 'B5G_CODSEQ'		} },; //Histórico
		B4H->( IndexKey(  ) ) )

	oModel:GetModel('MasterBBA'):SetDescription("Análise de Beneficiários")
	oModel:GetModel('B5GDetail'):SetDescription("Passos da Análise")
	oModel:GetModel('B4HDetail'):SetDescription("Histórico")

	oModel:getModel( 'B5GDetail' ):SetOptional( .T. )
	oModel:GetModel( 'B4HDetail' ):SetOptional( .T. )

	oModel:SetPrimaryKey( {"BBA_FILIAL", "BBA_CODSEQ"} )

	oStrB5G:setProperty( '*',          MODEL_FIELD_WHEN , { || PLS977ABWH(oModel)} )
	oStrB5G:SetProperty( 'B5G_STATUS', MODEL_FIELD_WHEN , { || PL977ABCan(oModel)} )
	oStrB5G:setProperty( 'B5G_CODPBE', MODEL_FIELD_VALID, { || PL977AB5G(oModel) } )

	oStrBBA:setProperty( '*',          MODEL_FIELD_WHEN,   { || PLS977ABWH(oModel)})
	oStrBBA:SetProperty( 'BBA_CODEMP' , MODEL_FIELD_VALID, { || EmpTy(oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_CODEMP' )) .OR. ExistCpo("BG9", cCodInt+oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_CODEMP' ) ,1 ) } )
	oStrBBA:SetProperty( 'BBA_CODPRO' , MODEL_FIELD_VALID, { || EmpTy(oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_CODPRO' )) .OR. ExistCpo("BI3", cCodInt+oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_CODPRO' ) ,1) } )
	oStrBBA:setProperty( 'BBA_CODEMP' , MODEL_FIELD_WHEN, { || PLS977WHNX(oModel, 'BBA_CODINT') } )

	oStrBBA:setProperty( 'BBA_CONEMP' , MODEL_FIELD_WHEN, { || PLS977WHNX(oModel, 'BBA_CODEMP') } )
	oStrBBA:setProperty( 'BBA_CONEMP' , MODEL_FIELD_VALID, { || EmpTy(oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_CONEMP' )) .OR. ExistCpo("BT5", cCodInt + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_CODEMP' ) + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_CONEMP' ), 1)})

	oStrBBA:setProperty( 'BBA_VERCON' , MODEL_FIELD_WHEN, { || PLS977WHNX(oModel, 'BBA_CONEMP') } )
	oStrBBA:setProperty( 'BBA_VERCON' , MODEL_FIELD_VALID, { || EmpTy(oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_VERCON' )) .OR. ExistCpo("BT5", cCodInt + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_CODEMP' ) + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_CONEMP' ) + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_VERCON' ), 1)})
	oStrBBA:setProperty( 'BBA_SUBCON' , MODEL_FIELD_WHEN, { || PLS977WHNX(oModel, 'BBA_VERCON') } )
	oStrBBA:setProperty( 'BBA_SUBCON' , MODEL_FIELD_VALID, { || EmpTy(oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_SUBCON' )) .OR. Existcpo("BQC", cCodInt + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_CODEMP' ) + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_CONEMP' ) + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_VERCON' ) + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_SUBCON' ), 1)})
	oStrBBA:setProperty( 'BBA_VERSUB' , MODEL_FIELD_WHEN, { || PLS977WHNX(oModel, 'BBA_SUBCON') } )
	oStrBBA:setProperty( 'BBA_VERSUB' , MODEL_FIELD_VALID, {| | EmpTy(oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_VERSUB' )) .OR. Existcpo("BQC", cCodInt + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_CODEMP' ) + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_CONEMP' ) + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_VERCON' ) + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_SUBCON' ) + oModel:GetModel( 'MasterBBA' ):GetValue( 'BBA_VERSUB' ), 1)})

	//verifico se vou usar a estrutura da B2N ou da BA1
	if  (BBA->BBA_TIPMAN == '1' .OR. BBA->BBA_TIPMAN == '3')
		oStrB2N	:= FWFormStruct(1,'B2N')
		oModel:AddGrid('B2NDetail', 'MasterBBA', oStrB2N)

		oModel:SetRelation( 'B2NDetail', { { 'B2N_FILIAL'	, 'xFilial( "B2N" )' },;
			{ 'B2N_PROTOC'	,'BBA_CODSEQ'        }  },;
			B2N->( IndexKey(  ) ) )

		oModel:GetModel( 'B2NDetail' ):SetDescription("Beneficiários")
		oModel:GetModel( 'B2NDetail' ):SetOptional( .T. )
		oModel:getModel( 'B2NDetail' ):setNoInsertLine( .T. )
		oStrB2N:setProperty( 'B2N_DESGRA', MODEL_FIELD_INIT, { || Posicione("BRP",1,xFilial("BRP")+B2N->B2N_GRAUPA,"BRP_DESCRI")})
		oStrB2N:setProperty( '*',          MODEL_FIELD_WHEN, { || PLS977ABWH(oModel)})
	else
		oStrBA1 := FWFormStruct(1,'B7L')

		B7L->(DbSetOrder(1))

		oStrBA1:AddField( ; 													// Ord. Tipo Desc.
			AllTrim( STR0011/*'Campo'*/ ) , ; 							// [01] C Titulo do campo
			AllTrim( STR0012/*'Nome do campo Alterado'*/ ) , ; 		// [02] C ToolTip do campo
			'B7L_CPOAMG' , ; 									// [03] C identificador (ID) do Field
			'C' , ; 											// [04] C Tipo do campo
			12 , ; 											// [05] N Tamanho do campo
			0 , ; 												// [06] N Decimal do campo
			NIL, ; 											// [07] B Code-block de validação do campo
			NIL , ; 											// [08] B Code-block de validação When do campo
			NIL , ; 											// [09] A Lista de valores permitido do campo
			NIL , ; 											// [10] L Indica se o campo tem preenchimento obrigatório
			FwBuildFeature( STRUCT_FEATURE_INIPAD, "PL977ABSX3(B7L->(B7L_CAMPO), 'X3_TITULO')" )/* NIL*/ , ; // [11] B Code-block de inicializacao do campo
			NIL , ; 											// [12] L Indica se trata de um campo chave
			NIL , ; 											// [13] L Indica se o campo pode receber valor em uma operação de update.
			.T. )

		oStrBA1:AddField( ; 													// Ord. Tipo Desc.
			AllTrim( STR0013/*'Tabela'*/ ) , ; 							// [01] C Titulo do campo
			AllTrim( STR0014/*'Nome da tabela Alterada'*/ ) , ; 		// [02] C ToolTip do campo
			'B7L_ALIAMG' , ; 									// [03] C identificador (ID) do Field
			'C' , ; 											// [04] C Tipo do campo
			30 , ; 											// [05] N Tamanho do campo
			0 , ; 												// [06] N Decimal do campo
			NIL, ; 											// [07] B Code-block de validação do campo
			NIL , ; 											// [08] B Code-block de validação When do campo
			NIL , ; 											// [09] A Lista de valores permitido do campo
			NIL , ; 											// [10] L Indica se o campo tem preenchimento obrigatório
			FwBuildFeature( STRUCT_FEATURE_INIPAD, "PL977ABSX2(B7L->(B7L_ALIAS))" )/* NIL*/ , ; // [11] B Code-block de inicializacao do campo
			NIL , ; 											// [12] L Indica se trata de um campo chave
			NIL , ; 											// [13] L Indica se o campo pode receber valor em uma operação de update.
			.T. )

		oModel:AddGrid('BA1Detail', 'MasterBBA', oStrBA1)

		oModel:SetRelation( 'BA1Detail', { { 'B7L_FILIAL'	, 'xFilial( "B7L" )' },;
			{ 'B7L_CHAVE'		, 'BBA_CODSEQ'		},;
			{ 'B7L_ALIAS'		, '"BA1"'				},;
			{ 'B7L_ALIACH'	, '"BBA"'				} },;
			B7L->( IndexKey( ) ) )

		oModel:GetModel( 'BA1Detail' ):SetDescription("Beneficiários")
		oModel:getModel( 'BA1Detail' ):setOptional( .T. )
		oModel:getModel( 'BA1Detail' ):setNoInsertLine( .T. )
	endif

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Karine Riquena Limp
@since 25/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado

	Local oView  // Interface de visualização construída
	Local oModel := FWLoadModel( 'PLSA977AB' ) // Cria as estruturas a serem usadas na View

	Local oStrBBA := FWFormStruct(2,'BBA', { |cCampo| PL977ABBAV(cCampo)} )
	Local oStrB5G := FWFormStruct(2,'B5G', { |cCampo| PL977AB5GV(cCampo)} )
	Local oStrB4H := FWFormStruct(2,'B4H', { |cCampo| PL977AB4HV(cCampo)} )
	Local oStrB2N	:=  NIL
	Local oStrBA1	:=  NIL

	oView := FWFormView():New() // Cria o objeto de View

	oStrB5G:SetProperty( 'B5G_CODPBE', MVC_VIEW_ORDEM, '00'	 )
	oStrBBA:setProperty( '*', MVC_VIEW_CANCHANGE, .F.)
	oStrBBA:setProperty( 'BBA_OBSERV', MVC_VIEW_CANCHANGE, .T.)

	oStrBBA:setProperty( 'BBA_CODEMP', MVC_VIEW_LOOKUP, 'BBABG9')
	oStrBBA:setProperty( 'BBA_CONEMP', MVC_VIEW_LOOKUP, 'BBABT5')
	oStrBBA:setProperty( 'BBA_CODPRO', MVC_VIEW_LOOKUP, 'BBABI3')
	oStrBBA:setProperty( 'BBA_SUBCON', MVC_VIEW_LOOKUP, 'BBABQC')

	If EmpTy(AllTrim(BBA->BBA_CODEMP))
		oStrBBA:setProperty( 'BBA_CODEMP' , MVC_VIEW_CANCHANGE, .T. )
	EndIf
	If EmpTy(AllTrim(BBA->BBA_CONEMP))
		oStrBBA:setProperty( 'BBA_CONEMP' , MVC_VIEW_CANCHANGE, .T. )
	EndIF
	If empTy(Alltrim(BBA->BBA_VERCON))
		oStrBBA:setProperty( 'BBA_VERCON' , MVC_VIEW_CANCHANGE, .T. )
	EndIF
	IF EmpTy(AllTrim(BBA->BBA_SUBCON))
		oStrBBA:setProperty( 'BBA_SUBCON' , MVC_VIEW_CANCHANGE, .T. )
	EndIf
	If EmpTy(Alltrim(BBA->BBA_VERSUB))
		oStrBBA:setProperty( 'BBA_VERSUB' , MVC_VIEW_CANCHANGE, .T. )
	EndIf

	//não exibe o campo de cpf na tela
	oStrBBA:RemoveField('BBA_CPFTIT')

	//verifico se vou usar a view da B2N ou da BA1
	if  (BBA->BBA_TIPMAN == '1' .OR. BBA->BBA_TIPMAN == '3')
		oStrB2N	:=  FWFormStruct(2,'B2N', { |cCampo| PL977AB2NV(cCampo)} )
		oStrB2N:setProperty( '*', MVC_VIEW_CANCHANGE, .F.)
		oStrB2N:setProperty( 'B2N_STATUS', MVC_VIEW_CANCHANGE, .T.)
		oStrB2N:SetProperty( 'B2N_STATUS', MVC_VIEW_ORDEM, '00'	 )
		if BBA->BBA_TIPMAN == '1' .AND. empty(BBA->BBA_MATRIC)
			BG9->(DbSetOrder(1))
			if (empty(BBA->BBA_CODEMP)) .OR. ((BG9->(MsSeek(xFilial("BG9")+PLSINTPAD()+BBA->BBA_CODEMP))) .AND. BG9->BG9_TIPO == "1") .AND. (empty(BBA->BBA_SUBCON))
				oStrBBA:setProperty( 'BBA_CODEMP', MVC_VIEW_CANCHANGE, .T.)
				oStrBBA:setProperty( 'BBA_CODPRO', MVC_VIEW_CANCHANGE, .T.)
				BG9->(dbCloseArea())
			endIf
		elseif BBA->BBA_TIPMAN == '1' .AND. !(empty(BBA->BBA_SUBCON))
			oStrBBA:setProperty( 'BBA_CODPRO', MVC_VIEW_CANCHANGE, .T.)
			oStrBBA:setProperty( 'BBA_CODPRO', MVC_VIEW_LOOKUP, 'BT6BBA')
		endIf
	else
		oStrBA1	:= FWFormStruct(2,'B7L', { |cCampo| PL977AB7LV(cCampo)})

		oStrBA1:AddField( ; // Ord. Tipo Desc.
			'B7L_CPOAMG' , ; // [01] C Nome do Campo
			'03' , ; 			// [02] C Ordem
			AllTrim( STR0011/*'Campo'*/ ) , ; 			// [03] C Titulo do campo
			AllTrim( STR0015/*'Campo Alterado'*/ ) , ; // [04] C Descrição do campo
			{ STR0011/*'Nome do campo alterado'*/ } , ; // [05] A Array com Help
			'C' , ; // [06] C Tipo do campo
			'@!' , ;// [07] C Picture
			NIL , ; // [08] B Bloco de Picture Var
			'' , ;  // [09] C Consulta F3
			.F. , ; // [10] L Indica se o campo é evitável
			NIL , ; // [11] C Pasta do campo
			NIL , ; // [12] C Agrupamento do campo
			NIL , ; // [13] A Lista de valores permitido do campo (Combo)
			NIL , ; // [14] N Tamanho Maximo da maior opção do combo
			NIL , ; // [15] C Inicializador de Browse
			.T. , ; // [16] L Indica se o campo é virtual
			NIL )   // [17] C Picture Variável

		oStrBA1:AddField( ; // Ord. Tipo Desc.
			'B7L_ALIAMG' , ; // [01] C Nome do Campo
			'02' , ; 			// [02] C Ordem
			AllTrim( STR0013/*'Tabela'*/ ) , ; 			// [03] C Titulo do campo
			AllTrim( STR0014/*'Tabela alterada'*/ ) , ; // [04] C Descrição do campo
			{ STR0016/*'Nome da tabela alterada'*/ } , ; // [05] A Array com Help
			'C' , ; // [06] C Tipo do campo
			'@!' , ;// [07] C Picture
			NIL , ; // [08] B Bloco de Picture Var
			'' , ;  // [09] C Consulta F3
			.F. , ; // [10] L Indica se o campo é evitável
			NIL , ; // [11] C Pasta do campo
			NIL , ; // [12] C Agrupamento do campo
			NIL , ; // [13] A Lista de valores permitido do campo (Combo)
			NIL , ; // [14] N Tamanho Maximo da maior opção do combo
			NIL , ; // [15] C Inicializador de Browse
			.T. , ; // [16] L Indica se o campo é virtual
			NIL )   // [17] C Picture Variável

		oStrBA1:setProperty( '*', MVC_VIEW_CANCHANGE, .F.)
		oStrBA1:setProperty( 'B7L_GRAVAD', MVC_VIEW_CANCHANGE, .T.)
		oStrBA1:SetProperty( 'B7L_GRAVAD', MVC_VIEW_ORDEM, '00'	 )

	endIf

	oView:SetModel(oModel)

	oView:AddField('ViewBBA' , oStrBBA,'MasterBBA' )

	oView:AddGrid( 'ViewB5G' , oStrB5G,'B5GDetail' )
	oView:AddGrid( 'ViewB4H' , oStrB4H,'B4HDetail' )

	//faço o if mais de uma vez pq a ordem de criação dos componentes é dependente
	if  (BBA->BBA_TIPMAN == '1' .OR. BBA->BBA_TIPMAN == '3')
		oView:AddGrid( 'ViewB2N' , oStrB2N,'B2NDetail' )
	else
		oView:AddGrid( 'ViewBA1' , oStrBA1,'BA1Detail' )
	endif

	oView:CreateHorizontalBox( 'SUPERIOR' 	, 40)
	oView:CreateHorizontalBox( 'MEIO'		, 35)
	oView:CreateHorizontalBox( 'BAIXO'		, 25)

	oView:CreateFolder( 'ABA', 'MEIO' ) //Cria estrutura de abas

	oView:CreateHorizontalBox( 'A'		, 100,,, 'ABA', 'T1'  )
	oView:CreateHorizontalBox( 'B'		, 100,,, 'ABA', 'T2'  )

	oView:AddSheet( 'ABA', 'T1', STR0017 ) //"Passos da Análise"
	oView:AddSheet( 'ABA', 'T2', STR0018 ) //"Beneficiários"

	oView:SetOwnerView('ViewBBA', 'SUPERIOR'	)
	oView:SetOwnerView('ViewB5G', 'A'			)
	oView:SetOwnerView('ViewB4H', 'BAIXO'	  )

	if  (BBA->BBA_TIPMAN == '1' .OR. BBA->BBA_TIPMAN == '3')
		oView:SetOwnerView('ViewB2N', 'B'	)
	else
		oView:SetOwnerView('ViewBA1', 'B'	)
	endIf

	oView:SetFieldAction('B5G_CODPBE', { |oModel| PL977ABDTB(oModel, oView,"B5G_DATAIN" , "B5GDetail")})
	oView:SetFieldAction('B5G_STATUS', { |oModel| PL977ABMem(oModel, oView)})
	oView:setFieldAction('B4H_OBSERV', { |oModel| PLS813DBas(oModel, oView,"B4H_DATA"   , "B4HDetail")})

	oView:AddUserButton("Anexos", "", {|| PLBAN977AB(oModel)  } )
	If FindFunction("PLTermConsBenef")
		oView:AddUserButton("Termo de Consentimento do Beneficiário", "", {|oModel| BenefTermoConsentimento(oModel)  } )
	EndIf
	oView:EnableTitleView('ViewB4H',STR0019) //"Histórico"
	oView:SetViewProperty( "ViewB5G", "ENABLENEWGRID")
	oView:SetViewProperty( "ViewB5G", "GRIDNOORDER")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977ABLEG
Definição da Legenda a ser apresentada
@author Karine Riquena Limp
@since 23/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977ABLEG()

	Local cRet

	cRet := BBA_STATUS

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977AB5GM
Definição dos campos que pertencerão ao Model
@author Karine Riquena Limp
@since 25/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977AB5GM(cCampo)

	Local lRet := .T.

	if(cCampo == "B5G_CODIGO")
		lRet := .F.
	endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS977ABOK
Valida a inclusão do Registro
@author Karine Riquena Limp
@since 23/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS977ABOK(oModel)

	Local lRet		:= .T.
	Local nI := 0
	Local nTam := 0
	Local nReg := 0
	Local aDados := NIL
	Local cStPas := PLPOSB5GST(oModel)
	Local oBBA := oModel:GetModel("MasterBBA")
	Local oB2N := oModel:GetModel("B2NDetail")
	Local oBA1 := oModel:GetModel("BA1Detail")
	local cCodTit := getNewPar("MV_PLCDTIT", "T")
	Local cMatric := ""
	Local cMotivo := ""
	Local cCodInt	:= PLSINTPAD()
	Local cBloFat := ""
	Local lBloqFamilia := .F. 
	Local nIdOperadora := 0
	Local cMsHash := ""
	Local cMatricula := ""
	Local cProtocolo := ""
	Local cStatus := ""
	Local cObservacao := ""

	//1 = Pendente de documentação 5 = Rejeitado 6 = Aprovado parcialmente
	if( (cStPas == "1" .OR. cStPas == "5" .OR. cStPas == "6") .AND. empty(allTrim(oBBA:GetValue("BBA_OBSERV"))))
		MsgAlert( STR0020 /*"Informe uma observação para o beneficiário saber"*/ + " " + iif(cStPas=="1", STR0021, iif(cStPas == "5", STR0022 /*" o motivo da rejeição "*/, STR0023 /*" motivo da aprovação parcial "*/)), STR0024 /*"Atenção"*/)
	else
		PL977ABMAIL(oModel)

		If oModel:GetModel('MasterBBA'):GetValue('BBA_APROVA') .AND. oModel:GetModel('B5GDetail'):GetValue('B5G_STATUS')

			if(oB2N == NIL)

				nTam := oBA1:length()
				aDados := {}

				For nI := 1 To nTam

					oBA1:goLine(nI)

					oBA1:SetValue("B7L_GRAVAD", .T.)

					If ( (GetSx3Cache(oBA1:getValue("B7L_CAMPO"), "X3_CONTEXT") <> "V") )
						nReg := nReg + 1
						Aadd(aDados, { nReg, {oBA1:getValue("B7L_ALIAS"), oBA1:getValue("B7L_CAMPO"), oBA1:getValue("B7L_VLPOS"), oBA1:getValue("B7L_RECREG"), oBA1:getValue("B7L_TIPO"), oBA1:getValue("B7L_CHVREG")}} )
					EndIf

				Next nI

				If (Len(aDados) > 0 )
					PLS977ABTS(@aDados)
					lRet := PLS814GGRV(aDados)
					//*********alterar o fonte de 260 para PLSA977AB, verificar como cadastra****************
					PlsSinc("PLSA260","BA1","SA1", .F., .T., VAL( aDados[1][2][4]), NIL, NIL , NIL, 3, "BA1_CPFUSR")
					PLAFBNWRA('', '2', '', val(aDados[1][2][4]))
				EndIf

			elseif(oB2N != NIL .AND. BBA->BBA_TIPMAN == "3") // se é exclusão

				// quando é exclusão, vem apenas um registro na B2N por isso goline(1)

				oB2N:GoLine(1)
				cMotivo := POSICIONE("B9G", 1, xFilial("B9G")+cCodInt+oB2N:GetValue("B2N_CODMOT"),"B9G_MOTBG3")
				BA1->(DbGoTo(oB2N:GetValue("B2N_BA1REC")))

				BG3->(DBSetOrder(1))
				IF BG3->(MsSeek(xFilial("BG3") + cMotivo))
					cBloFat := BG3->BG3_BLOFAT	//	Status Atual do Usuário
				ENDIF

				If B2N->(FieldPos("B2N_TIPBLO")) > 0
					If oB2N:GetValue("B2N_TIPBLO") == "1"
						lBloqFamilia := .T.
					EndIf
				Else
					lBloqFamilia := oB2N:GetValue("B2N_TIPUSU") == cCodTit
				EndIf

				If lBloqFamilia
					//Bloqueia familia
					PL260BLOCO("BA1",oB2N:GetValue("B2N_BA1REC"),4,.T.,cMotivo,oB2N:GetValue("B2N_DTBLOQ"), cBloFat , 2,,,,.F.)
				Else
					//Bloqueia Usuário
					PL260BLOUS("BA1",oB2N:GetValue("B2N_BA1REC"),4,.T.,cMotivo,oB2N:GetValue("B2N_DTBLOQ"), cBloFat, .F.,,,,.F.)   //12-04
				Endif

				//Não permite mais alteração apos aprovação
				If oModel:GetModel('B5GDetail'):GetValue('B5G_STATUS') .AND. ;
						oModel:GetModel('B5GDetail'):GetValue('B5G_CODPBE') $ "0005,0006"

					oBBA:SetValue("BBA_APROVA", .T.)
				EndIf
			endIf
		endIf
	endIf

	// Realiza integração para atualização do protocolo
	If lRet .And. BBA->(FieldPos("BBA_IDOPER")) > 0 .And. BBA->(FieldPos("BBA_MSHASH")) > 0

		cMsHash := oBBA:GetValue("BBA_MSHASH")

		If !Empty(cMsHash)
			nIdOperadora := oBBA:GetValue("BBA_IDOPER")		
			cMatricula := oBBA:GetValue("BBA_MATRIC")
			cProtocolo := oBBA:GetValue("BBA_NROPRO")
			cStatus := oBBA:GetValue("BBA_STATUS")
			cObservacao := oBBA:GetValue("BBA_OBSERV")

			PL977MobComunica(nIdOperadora, cMsHash, cMatricula, cProtocolo, cStatus, cObservacao)
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS977VLDI
Validação de inclusão de linha
@author Karine Riquena Limp
@since 23/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS977VLDI(oB5G,nLine)

	Local lRet := .T.
	Local nTam := oB5G:Length()
	Local nNx

	If nLine == 1
		lRet := .T.
	Else
		// Verifica a linha anterior se está com o status finalizado.
		For nNx := nLine To 2 Step -1
		If !oB5G:IsDeleted(nNx-1) .and.  !Empty(oB5G:GetValue("B5G_CODPBE",nNx-1)) 
				lRet := oB5G:GetValue("B5G_STATUS",nNx-1)
				Exit
			EndIf
		Next
	EndIf

	// Verifica se as proximas linhas estao deletadas e se a linha atual for sem data final,
	// Nesse caso é usado para tentativas de deletar linhas e voltar linhas proximas
	If !oB5G:GetValue("B5G_STATUS",nLine)
		For nNx := nLine To nTam-1
		If !oB5G:IsDeleted(nNx+1) .and.  !Empty(oB5G:GetValue("B5G_CODPBE",nNx+1)) 
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf

	If !lRet
		Help(,,STR0024,, STR0025,1,0) //Atenção //"Foi inserido um passo sem a data fim do anterior, verifique o preenchimento"
		If oB5G:DeleteLine()	
			oB5G:GoLine(1 )
		Endif	
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977ABSX2
Busca o nome da tabela no arquivo SX2
@author Karine Riquena Limp
@since 23/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977ABSX2(cTabela)

	Local cNomeAlias	:= ""

	if (Select("SX2")==0)
		SX2->(DbSelectArea("SX2"))
	EndIf
	SX2->(DbSelectArea(1))
	SX2->(MsSeek(cTabela))
	cNomeAlias := SX2->(X2_NOME)

return (cNomeAlias)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977ABSX3
Busca o nome do campo no arquivo X3
@author Karine Riquena Limp
@since 23/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977ABSX3(cCampo, cCpoX3)

	Local xValor	:= ""

	If !(Vazio(cCampo))
		xValor := GetSx3Cache(cCampo, cCpoX3)
	EndIf

return (xValor)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS977ABWH
When do formulário, para travar a edição caso a solicitação seja aprovada
ou Indeferida.
@author Karine Riquena Limp
@since 23/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS977ABWH(oModel)
	Local oBBA 	:= oModel:getModel("MasterBBA")
	Local oB5G  := oModel:GetModel("B5GDetail")
	Local nTam  := oB5G:Length()
	Local nNx
	Local lRet  := .T.

	//Verifica se existe um passo rejeitado com o status concluido, se houver desabilita a edição
	B4G->(dbSetOrder(1))
	For nNx := 1 To nTam
		If (B4G->(MsSeek(xFilial("B4G") + oB5G:GetValue("B5G_CODPBE",nNx) )))
			If (B4G->B4G_LEGBEN == "5") // Rejeitado
				If oB5G:GetValue("B5G_STATUS",nNx) .AND. !Empty(oB5G:GetValue("B5G_DATAFM",nNx)) // Concluido
					lRet := .F.
					Exit
				EndIf
			EndIf
		endIf
	Next

return !oBBA:getValue("BBA_APROVA") .AND. !oBBA:getValue("BBA_STATUS") $ "1" .AND. lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977ABCan
Verifica se o passo foi iniciado para permitir sua finalização
@author Karine Riquena Limp
@since 23/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977ABCan(oModel)

	Local lRet		:= .F.
	Local oB5G		:= oModel:GetModel("B5GDetail")
	Local lStatus := oB5G:GetValue('B5G_STATUS')
	Local cCodPas	:= IIf(ValType(oB5G:GetValue("B5G_CODPBE")) == "U", "", oB5G:GetValue("B5G_CODPBE"))

	//1=Pendiente de documentación;2=En análisis;3=Procesado;4=Aprobado;5=Rechazado;6=Aprobado parcialmente
	If lStatus
		lRet := .F.
	else
		If ValType(cCodPas) == "C"
			B4G->(dbSetOrder(1))
			If ( B4G->(MsSeek(xFilial('B4G') + cCodPas)) .and. B4G->B4G_LEGBEN $"1,2,4,5") .OR. Vazio(cCodPas)
			lRet := .T.
		EndIf
	EndIf
	EndIF

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977AB5G
Valid da Grid da B5G
@author Karine Riquena Limp
@since 22/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977AB5G(oModel)

	Local lRet := .F.
	Local lB4G := .F.
	Local cCodPas	:= oModel:GetModel("B5GDetail"):getValue("B5G_CODPBE")

	B4G->(dbSetOrder(1))
	If ( B4G->(MsSeek(xFilial('B4G') + cCodPas)) .OR. Vazio(cCodPas) )
		lRet := .T.
	EndIf

return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLBAN977AB
Banco de conhecimento da rotina. Irá ser adequado para exibir os documentos cadastrados no Portal.
@author Karine Riquena Limp
@since 24/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLBAN977AB(oModel)

	Local aAreaBBA	:= BBA->(GetArea())
	Local oBBA 		:= oModel:GetModel("MasterBBA")
	Local cCodSeq 	:= ""
	Local cMsg		:= STR0026/*"Não foi encontrado o beneficiário, não é possível utilizar o Banco de Conhecimento"*/
	Local lIncDoc

	Private aRotina 		:= {}
	PRIVATE cCadastro   	:= FunDesc()

	If ValType(oModel) == "O"

		oBBA 	 := oModel:GetModel("MasterBBA")
		cCodSeq := oBBA:GetValue("BBA_CODSEQ")
	else

		cCodSeq := BBA->BBA_CODSEQ
	EndIf

	If AllTrim(cCodSeq) <> ""

		aRotina := {{STR0027 /*"Conhecimento"*/,'MsDocument',0,1},{STR0028/*"Inclusão Rápida"*/,'PLSDOcs',0,3}}

		BBA->(DbSetOrder(1))

		If BBA->(MsSeek(xFilial("BBA") + cCodSeq))
			lIncDoc := MsDocument( "BBA", BBA->( RecNo() ), 2 )

			If lIncDoc .AND. BBA->BBA_STATUS == "1" // Se foi incluido um anexo e o status esta em 1 - Pendente de Documentação
				oBBA:LoadValue("BBA_STATUS","2") // Altera o Status para 2 - Em Analise
			EndIf
		EndIf

	else
		MsgAlert(cMsg, STR0024 /*"Atenção"*/)
	EndIf

	RestArea(aAreaBBA)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977ABBAV
Definição dos campos que pertencerão à View
@author Karine Riquena Limp
@since 24/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977ABBAV(cCampo)

	Local lRet := .T.

	If (cCampo == "BBA_CODSEQ")
		lRet := .F.
	EndIf

	If (cCampo == "BBA_APROVA")
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977AB5GV
Definição dos campos que pertencerão à View
@author Karine Riquena Limp
@since 24/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977AB5GV(cCampo)

	Local lRet := .F.

	If (cCampo != "B5G_CODIGO" .AND. cCampo != "B5G_CODBEN" .AND. cCampo != "B5G_CODPAS")
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977AB4HV
Define os campos que irão compor a View
@author Karine Riquena Limp
@since 24/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977AB4HV(cCampo)

	Local lRet := .T.

	If (cCampo == "B4H_CODSEQ")
		lRet := .F.
	EndIf

	If (cCampo == "B4H_SEQB4H")
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977AB2NV
Definição dos campos que pertencerão à View
@author Karine Riquena Limp
@since 24/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977AB2NV(cCampo)

	Local lRet := .F.

	If (cCampo <> "B2N_FLGCTR")
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977AB7LV
Definição dos campos que pertencerão à View
@author Karine Riquena Limp
@since 24/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977AB7LV(cCampo)

	Local lRet := .F.

	If (cCampo == "B7L_GRAVAD") .OR.	(cCampo == "B7L_VLANT ");
			.OR.	(cCampo == "B7L_VLPOS ");
			.OR.	(cCampo == "B7L_DATA  ");
			.OR.	(cCampo == "B7L_HORA  ");
			.OR.	(cCampo == "B7L_USER  ")

		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977ABCHK
Alerta ou aprovação de todos os registros
@author Karine Riquena Limp
@since 25/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977ABCHK(oModel, nAction, lAsk)
	//nAction = 1 - ALERTA O USUARIO QUE TODOS OS CAMPOS SERÃO APROVADOS QUANDO FINALIZAR O PASSO
	//nAction = 2 - ATUALIZA OS CAMPOS TODOS PARA APROVADOS
	//lAsk = SE TRUE INDICA QUE VAI EXIBIR UMA MSG YESNO PARA MARCAR TODOS REGISTROS OU NAO
	Local oB2N := oModel:GetModel('B2NDetail')
	Local oBA1 := oModel:GetModel('BA1Detail')
	Local nTam   := 0
	Local lAchou := .F.
	Local lMarca := .F.
	Local nI := 0
	Default lAsk := .F.
	Default nAction := 1

	if oBA1 <> nil

		nTam := oBA1:length()

		While nI <= nTam .AND. !lAchou

			oBA1:goLine(nI)

			if !(oBA1:GetValue("B7L_GRAVAD"))
				if(nAction == 1 .AND. !lMarca)
					//se ja exibiu o alerta e o usuario clicou em sim na MsgNoYes para atualizar tudo para aprovado, o alerta não será exibido quando encontrarmos outro registro desmarcado
					if(!lMarca)
						MsgAlert(STR0029, STR0024/*'Atenção'*/)//'Nem todos os campos estão aprovados, ao finalizar o passo todos serão aprovados automaticamente!'
					endIf

					if(lAsk .AND. !lMarca)
						lMarca := MsgNoYes(STR0030, STR0024/*"Atenção"*/)//"Deseja marcar todos os registros para aprovado? "
					else
						//sai do while se só queremos exibir a mensagem de alerta
						lAchou := .T.
					endIf
				else
					oBA1:SetValue("B7L_GRAVAD", .T.)
				endif
			endIf

			nI++

		EndDo
	else

		nTam := oB2N:length()

		While nI <= nTam .AND. !lAchou

			oB2N:goLine(nI)

			if !(oB2N:GetValue("B2N_STATUS") == "2")
				if(nAction == 1 .AND. !lMarca)
					//se ja exibiu o alerta e o usuario clicou em sim na MsgNoYes para atualizar tudo para aprovado, o alerta não será exibido quando encontrarmos outro registro desmarcado
					if(!lMarca)
						MsgAlert(STR0029, STR0024 /*Atenção*/)//'Nem todos os campos estão aprovados, ao finalizar o passo todos serão aprovados automaticamente!'
					endIf

					if(lAsk .AND. !lMarca)
						lMarca := MsgNoYes(STR0030, STR0024/*"Atenção"*/)//"Deseja marcar todos os registros para aprovado? "
					else
						//sai do while se só queremos exibir a mensagem de alerta
						lAchou := .T.
					endIf
				else
					oB2N:LoadValue("B2N_STATUS", "2")
				endif
			endIf

			nI++

		EndDo

	endIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977ABDTB
Preenche o campo da data de inclusão da observação no histórico (função para Grids)
E executa preenchimento dos campos relacionados. Exibe confirmação da inserção de
passos de Conclusão ou Indeferimento, ou caso haja envio de e-mail vinculado.
@author Karine Riquena Limp
@since 24/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977ABDTB(oModel, oView, cCampo, cModel)

	Local oB5G 		:= oModel:GetModel(cModel)
	Local oBBA			:= oModel:getModel("MasterBBA")
	Local dDataI
	Local cCodPas		:= oB5G:GetValue("B5G_CODPBE")
	Local cCodMail	:= ""
	Local cCodInt		:= PLSINTPAD()
	Local cDescri		:= Posicione("B4G", 3, xFilial("B4G") + cCodInt + cCodPas, "B4G_DESCRI")
	Local cStatus		:= Posicione("B4G", 3, xFilial("B5G") + ccodInt + cCodPas, "B4G_LEGBEN")

	If (cStatus = '4')

		If (MsgNoYes(STR0031, STR0024/*Atenção*/))
			PL977ABCHK(oModel, 1, .T.)
		Else
			cCodPas := ""
		EndIf
	EndIf

	B4G->(DbSelectArea("B4G"))
	B4G->(DbSetOrder(3))

	If B4G->(MsSeek(xFilial("B4G") + cCodInt + cCodPas))

		cCodMail := AllTrim(B4G->B4G_CODEMA)
	EndIF

	B4G->(DbCloseArea())

	IF !(cCodMail == "")

		If !(MsgNoYes(STR0032, STR0024/*"Atenção!"*/))//"A inclusão deste passo está associada ao envio de informação para o Candidato, confirma a inclusão deste passo?"
			cCodPas := ""
		EndIf
	EndIf

	If AllTrim(cCodPas) == ""

		oB5G:ClearField("B5G_CODPBE", , .T.)
		oB5G:ClearField(cCampo)
		oB5G:ClearField("B5G_DESCRI")
		oB5G:ClearField("B5G_USUARI")
		oB5G:SetValue("B5G_STATUS", .F.)
		oB5G:ClearField("B5G_DATAFM")

		M->B5G_DATAIN := ""
		M->B5G_CODPBE	:= cCodPas

	Else

		oB5G:SetValue(cCampo, dDataBase)
		oB5G:Setvalue("B5G_DESCRI", cDescri)
		oBBA:setValue("BBA_STATUS", cStatus)

		dDataI := oB5G:GetValue("B5G_DATAIN")

		M->B5G_DATAIN := dDataI
		M->B5G_CODPBE	:= cCodPas

		PL977ABPaCr(oModel)

	EndIf

	oView:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977ABPaCr
Preenche o passo Atual ao preencher um novo passo e o Responsável pela inclusão do Passo.
@author Karine Riquena Limp
@since 24/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977ABPaCr(oModel)

	Local oB5G 	:= oModel:getModel("B5GDetail")
	Local cPasso 	:= oB5G:GetValue("B5G_CODPBE")

	oB5G:SetValue( "B5G_USUARI", UsrFullName( RetCodUsr() ) )

Return (cPasso)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977ABMem
Altera a variável de memória para que a Pós Validação da linha do Grid Funcione corretamente
@author Karine Riquena Limp
@since 24/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977ABMem(oModel, oView)
	Local oBBA      := oModel:GetModel("MasterBBA")
	Local oModelB5G := oModel:GetModel("B5GDetail")
	Local lStat		:= oModelB5G:GetValue("B5G_STATUS")
	Local nX		:= 0
	Local nPosCod	:= 0
	Local nPosPbe	:= 0
	Local nPosArr	:= 0
	Local nPosSta	:= 0

	M->B5G_STATUS := lStat

	if(Empty(oBBA:GetValue("BBA_CODEMP")) .OR. Empty(oBBA:GetValue("BBA_CODPRO")))
		msgAlert("Informe o grupo empresa e o plano!")
		oModelB5G:LoadValue("B5G_STATUS", .F.)
		oModelB5G:ClearField("B5G_DATAFM")
	else
		If lStat .AND. MsgNoYes(STR0033,STR0034 /*"Finalizar Passo"*/)//Confirma a finalização do passo?
			nPosCod := aScan(oModelB5G:aHeader,{|x| AllTrim(x[2]) == "B5G_CODSEQ" } )
			nPosPbe := aScan(oModelB5G:aHeader,{|x| AllTrim(x[2]) == "B5G_CODPBE" } )
			nPosArr := Len(oModelB5G:aDataModel)
			nPosSta	:= aScan(oModelB5G:aHeader,{|x| AllTrim(x[2]) == "B5G_STATUS" } )
			For nX := 1 to Len(oModelB5G:aDataModel) //O CodSeq quando você inclui mais de 1 passo dentro da mesma análise dá chave duplicada, efetuado o for de comparação à isso.
				B5G->(DBSetOrder(3))
				If Len(oModelB5G:aDataModel) != nX .And. !oModelB5G:aDataModel[nX][1][1][nPosSta] //Se não for a posição do último passo efetuado e estiver com o status falso, preenche ele.
					oModelB5G:GoLine(nX)
					oModelB5G:LoadValue("B5G_STATUS", .T.)
					oModelB5G:LoadValue("B5G_DATAFM", dDataBase)
					oModelB5G:LoadValue("B5G_USUARI",UsrFullName( RetCodUsr() ))
				EndIf

				If oModelB5G:GetValue("B5G_CODPBE") != oModelB5G:aDataModel[nX][1][1][nPosPbe] .And. oModelB5G:GetValue("B5G_CODSEQ") == oModelB5G:aDataModel[nX][1][1][nPosCod]
					oModelB5G:GoLine(nX)
					oModelB5G:aDataModel[nPosArr][1][1][nPosCod] := getSxEnum("B5G", "B5G_CODSEQ")
				EndIf
			Next nX
			oModelB5G:LoadValue("B5G_DATAFM", dDataBase)
			oModelB5G:LoadValue("B5G_USUARI",UsrFullName( RetCodUsr() ))
			If oBBA:GetValue("BBA_TIPMAN") $ "2,3"

				If oModelB5G:GetValue("B5G_STATUS") .AND. oBBA:GetValue("BBA_STATUS") $ "4,5,6"
					oBBA:setValue("BBA_STATUS", "3")
				EndIf
			EndIf

			PL977ABAPR(oModel, oView)

		Else

			oModelB5G:LoadValue("B5G_STATUS", .F.)
			oModelB5G:ClearField("B5G_DATAFM")

		EndIf
	endIf

	oView:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977ABAPR
Verifica se o passo finalizado foi de conclusão e indica como solicitação
aprovada.
@author Karine Riquena Limp
@since 24/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977ABAPR(oModel, oView)

	Local oBBA		:= oModel:GetModel("MasterBBA")
	Local oB5G		:= oModel:GetModel("B5GDetail")
	Local cPasso	:= oB5G:GetValue("B5G_CODPBE")
	Local cStPas	:= ""
	Local cCodInt	:= PLSINTPAD()


	B4G->(DbSetOrder(3))
	if(B4G->(MsSeek(xFilial("B4G") + cCodInt + cPasso)))
		cStPas := B4G->B4G_LEGBEN
	endIf

	If (cStPas == "4")
		MsgAlert(STR0035)//Solicitação aprovada, a edição da mesma está bloqueada. Opções de consulta de anexos e geração de documentos continuarão habilitadas.
		oBBA:setValue("BBA_APROVA", .T.)
		PL977ABCHK(oModel,2) // seta todos os registros para aprovado
	ElseIf (cStPas == "5")
		MsgAlert(STR0049) //Solicitação rejeitada, a edição da mesma está bloqueada. Opções de consulta de anexos e geração de documentos continuarão habilitadas.
	EndIf

	oView:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977GETMAI
Busca o e-mail no cadastro da vida e do beneficiário
@author Karine Riquena Limp
@since 25/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977GETMAI(cCpfBBA)

	Local cEmail 	:= ""

	BTS->(DbSetOrder(3))
	BA1->(dbSetOrder(7))
	B2N->(dbSetOrder(2))
	if(BTS->(MsSeek(xFilial("BTS") +  cCpfBBA)))
		cEmail := alltrim(BTS->BTS_EMAIL)
	endIf

	if(BA1->(MsSeek(xFilial("BA1") +  BTS->BTS_MATVID)))
		cEmail := alltrim(BA1->BA1_EMAIL)
	endIf

	if(B2N->(MsSeek(xFilial("B2N") +  cCpfBBA)))
		cEmail := alltrim(B2N->B2N_EMAIL)
	endIf

	BTS->(dbCloseArea())
	BA1->(dbCloseArea())

Return cEmail

//-------------------------------------------------------------------
/*/{Protheus.doc} PL977ABMAIL
Envio de e-mail conforme o passo
@author Karine Riquena Limp
@since 25/11/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PL977ABMAIL(oModel)

	Local oBBA 		:= oModel:GetModel("MasterBBA")
	Local oB5G			:= oModel:GetModel("B5GDetail")

	Local cCpfBBA		:= oBBA:Getvalue("BBA_CPFTIT")
	Local cCodPas		:= ""
	Local cMailCan	:= PL977GETMAI(cCpfBBA)
	Local cCodInt		:= PLSINTPAD()
	Local cCodMail	:= ""
	Local cCC			:= ""
	Local cCCo			:= ""
	Local cCodSin		:= ""
	Local cMsg			:= ""
	Local lEnvMail	:= ""

	Local nB5G			:= 0
	Local nTamB5G		:= oB5G:Length()

	B5G->(DbSelectArea("B5G"))
	B5G->(DbSetOrder(1))

	B4G->(DbSelectArea("B4G"))
	B4G->(DbSetOrder(3))

	For nB5G := 1 To nTamB5G

		If !(oB5G:GetValue('B5G_ENVIOU')) //Se não enviou e-mail ainda

			cCodPas	:= oB5G:GetValue("B5G_CODPBE") //Pegamos o Código do Passo para as verificações

			If B4G->(MsSeek(xFilial("B4G") + cCodInt + cCodPas))

				cCodMail := AllTrim(B4G->B4G_CODEMA) //Pegamos o Código de e-mail associado ao passo
				lEnvMail := IIF(B4G->B4G_ENVEMA == '1' .AND. !empty(cMailCan), .T., .F.)
				cMsg := STR0036 /*'E-mail referente ao passo '*/ + " " +  cCodPas + " " + STR0037 /*' enviado com sucesso!'*/

				if (lEnvMail)//chama envio de e-mail
					PLSinaliza(cCodMail, cMsg, 1, cMailCan, STR0038 /*"Manutenção de Beneficiários"*/, oB5G, "B5G_ENVIOU", .T.)
				EndIf
			EndIf
		EndIf
	Next

	B5G->(DbCloseArea())
	B4G->(DbCloseArea())

Return
//--------------------------------------------------------------------------------
/*/{Protheus.doc} PLPOSB5GPAS
Retorna se a descrição do passo vai ser pelo passo de beneficiario ou de prestador
@author Karine Riquena Limp
@since 26/11/2015
@version P12
/*/
//---------------------------------------------------------------------------------
function PLPOSB5GPAS()
	Local cDescri := ""

	if !INCLUI
		if !empty(alltrim(B5G->B5G_CODPAS))
			cDescri := POSICIONE("B4G", 1, XFILIAL("B4G") + B5G->B5G_CODPAS, "B4G_DESCRI")
		else
			cDescri := POSICIONE("B4G", 1, XFILIAL("B4G") + B5G->B5G_CODPBE, "B4G_DESCRI")
		endif
	endif

return cDescri

//--------------------------------------------------------------------------------
/*/{Protheus.doc} PLPOSB5GST
Retorna o status do passo de acordo com o codigo do ultimo passo informado pelo
analista da solicitação
@author Karine Riquena Limp
@since 26/11/2015
@version P12
/*/
//---------------------------------------------------------------------------------
function PLPOSB5GST(oModel)
	Local oB5G := oModel:getModel('B5GDetail')
	Local cStatus := ""

	//pula para a ultima linha
	oB5G:goLine(oB5G:Length())

	cStatus := POSICIONE("B4G", 1, XFILIAL("B4G") + oB5G:getValue("B5G_CODPBE") , "B4G_LEGBEN")

return cStatus
//--------------------------------------------------------------------------------
/*/{Protheus.doc} PLPOSB5GST
Retorna o status do passo de acordo com o codigo do ultimo passo informado pelo
analista da solicitação
@author Karine Riquena Limp
@since 26/11/2015
@version P12
/*/
//---------------------------------------------------------------------------------
function PLGERGRPFA()

	local cSql := ""
	local cB5G := B5G->(RetSQLName("B5G"))
	local cBBA := BBA->(RetSQLName("BBA"))
	local lRet := .T.
	local cCampo := ""
	local aDados := {}
	local aRetDoc := {}
	local aAux := {}
	local cFuncao := ""
	local lHasTit := .F.
	local nI := 1
	local aEstBA1 := BA1->(DBSTRUCT())
	local cCodTit := getNewPar("MV_PLCDTIT", "T")
	Local nRecnoBA1TitFam := 0
	Local cVersaoPlano := ""

	private cCodFam := "" //para utilizar no sinalizador
	private aMatrics := {} //para utilizar no sinalizador

	B2N->(dbSetOrder(1))
	B5G->(dbSetOrder(3))

	if BBA->BBA_TIPMAN <> "1"
		MsgAlert(STR0039)//"Opção disponível apenas para solicitações de inclusão dos novos beneficiários!"
		lRet := .F.
	elseif B2N->(msSeek(xFilial("B2N")+BBA->BBA_CODSEQ)) .AND. cValToChar(B2N->B2N_FLGCTR) == "1"
		MsgAlert(STR0040)//"Esse grupo familiar já foi gerado!"
		lRet := .F.
	elseif BBA->BBA_STATUS <> "4"
		MsgAlert(STR0041)//"Não é permitido gerar grupo familiar com o status da solicitação diferente de aprovado!"
		lRet := .F.
	elseif empty(BBA->BBA_CODEMP) .OR. empty(BBA->BBA_CODPRO)
		lRet := .F.
		msgAlert(STR0042)//"É necessário informar os seguintes campos para incluir uma solicitação: Grupo empresa, código do plano "
	elseif  BBA->BBA_STATUS == "4"  .AND. B5G->(msSeek(xFilial("B5G")+BBA->(BBA_CODINT+BBA_CODSEQ)))

		cSql = "SELECT B5G_STATUS"
		cSql += "FROM " + cB5G + " B5G INNER JOIN " + cBBA + " BBA on(B5G.B5G_CODBEN = BBA.BBA_CODSEQ)"
		cSql += "WHERE B5G.R_E_C_N_O_ IN ("
		cSql +=    "SELECT MAX(R_E_C_N_O_) FROM " + cB5G
		cSql +="  )"

		//-------------------------------------------------------------------------
		//  Execute
		//-------------------------------------------------------------------------
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB5G",.F.,.T.)
		//-------------------------------------------------------------------------
		//  Monta matriz de retorno
		//-------------------------------------------------------------------------

		if !TRB5G->( Eof() )
			if(!TRB5G->B5G_STATUS == "T")
				msgAlert(STR0043)//"Não é permitido gerar grupo familiar sem finalizar o passo de aprovação!"
				lRet := .F.
			endif
		endif

		TRB5G->(dbCloseArea())
	endif

	//geração do grupo familiar
	if lRet
		//B2N_FILIAL, B2N_PROTOC, B2N_FLGCTR
		B2N->(dbSetOrder(1))
		SX3->(DbSetOrder(1))
		if(B2N->(msSeek(xFilial("B2N")+BBA->BBA_CODSEQ)))
			while(B2N->(!EOF()) .AND. xFilial("B2N")+BBA->BBA_CODSEQ == B2N->(B2N_FILIAL+B2N_PROTOC))

				aAdd(aAux, {"BA1_CODINT", BBA->BBA_CODINT })
				aAdd(aAux, {"BA1_CODEMP", BBA->BBA_CODEMP })
				aAdd(aAux, {"BA1_CONEMP", BBA->BBA_CONEMP })
				aAdd(aAux, {"BA1_VERCON", BBA->BBA_VERCON })
				aAdd(aAux, {"BA1_SUBCON", BBA->BBA_SUBCON })
				aAdd(aAux, {"BA1_VERSUB", BBA->BBA_VERSUB })

				If cCodTit == B2N->B2N_TIPUSU
					aAdd(aAux, {"BA1_CODPLA", BBA->BBA_CODPRO })
					aAdd(aAux, {"BA1_VERSAO", BBA->BBA_VERSAO })
				Else
					cVersaoPlano := GetVersaoPlano(BBA->BBA_CODINT, B2N->B2N_CODPRO)

					aAdd(aAux, {"BA1_CODPLA", B2N->B2N_CODPRO})
					aAdd(aAux, {"BA1_VERSAO", cVersaoPlano})
				EndIf

				// Os valores abaixo foram retirados do inicializador padrão dos respectivos campos.
				// A alteração foi necessária devido a estes 4 campos serem obrigatórios

				aAdd(aAux, {"BA1_LOCATE", "1" })
				aAdd(aAux, {"BA1_LOCEMI", "1" })
				aAdd(aAux, {"BA1_LOCANS", "1" })
				aAdd(aAux, {"BA1_LOCSIB", "0" })
				aAdd(aAux, {"BA1_REEWEB", "0" })

				SX3->(DbSetOrder(1))
				if SX3->(MsSeek("B2N"))
					while !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "B2N"
						//VERIFICO SE O CAMPO DA B2N EXISTE NA BA1 PARA INSERIR NO ARRAY
						if SX3->X3_CONTEXT <> "V"
							cCampo := alltrim("BA1_" + substr(SX3->X3_CAMPO, 5))
							if (aScan(aEstBA1, { |x| x[1] == cCampo }) > 0)
								aAdd(aAux, {cCampo, &("B2N->"+SX3->X3_CAMPO)})
							endif

							if !lHasTit .and. SX3->X3_CAMPO == "B2N_TIPUSU" .AND.  &("B2N->"+SX3->X3_CAMPO) == cCodTit
								lHasTit := .T.
							endIf
						endIf
						SX3->(dbSkip())
					Enddo
				endif

				aAdd(aDados, aAux)
				aAux := {}
				B2N->(dbSkip())
			endDo
		endIf

		B2N->(dbCloseArea())

		if(!Empty(BBA->BBA_MATRIC))
			cCodFam := substr(BBA->BBA_MATRIC, 1, 14)
		endIf

		aDados := PLSINCGFAM(aDados,,cCodFam)

		if(aDados[1])
			//VERIFICAR SE RETORNOU TRUE, PROCURAR CADA BENEFICIARIO DA B2N NA BA1, SE ACHAR GRAVAR B2N_FLGCTR
			BA1->(dbSetOrder(2))
			If BA1->(MsSeek(xFilial("BA1")+aDados[2]))
				INCLUI := .F.
				ALTERA := .T.
				PLSA260MOV("BA1",BA1->(RECNO()),4)

				begin transaction

					BA1->(dbSetOrder(4)) //BA1_FILIAL+BA1_CPFUSR

					B2N->(dbGotop())
					B2N->(dbSetOrder(1))
					If B2N->(msSeek(xFilial("B2N")+BBA->BBA_CODSEQ+"0")) // Retirado o laço pois estava causando loop infinito travando a rotina.
						B2N->(RecLock("B2N", .F.))
						B2N->B2N_FLGCTR := "1"
						B2N->(msUnlock())
						B2N->(dbGotop())
					endIf

					//alteração do status da BBA para processado
					BBA->(recLock("BBA", .F.))
					BBA->BBA_STATUS := "3"
					BBA->(msUnlock())

					cCodFam := substr(aDados[2],1,14)
					BA3->(dbSetOrder(1))
					if(BA3->(msSeek(xFilial("BA3")+cCodFam)) .and. BA3->BA3_TIPOUS == "1")
						BSW->(dbSetOrder(1))
						//se tem o titular na Solicitacao entao devo alterar o login na BSW
						if lHasTit
							if(BSW->(msSeek(xFilial("BSW")+BBA->BBA_CPFTIT)))
								BSW->(recLock("BSW", .F.))
								BSW->BSW_PERACE := getNewPar("MV_TPPRAP", "")
								BSW->(msUnlock())
								B49->(dbSetOrder(1))
								if(B49->(msSeek(xFilial("B49")+BSW->BSW_CODUSR+BBA->BBA_CPFTIT)))
									B49->(recLock("B49", .F.))
									B49->B49_BENEFI := aDados[2]
									B49->(msUnlock())
								endIf
							endIf
						else
							B49->(dbSetOrder(2))
							if(B49->(msSeek(xFilial("B49")+aDados[2])))
								BSW->(dbSetOrder(5))
								BSW->(msSeek(xFilial("BSW")+B49->B49_CODUSR))
							endIf
						endIf

						//pego os dependentes da BA1, vejo se ja existe na B49, senão existir incluo
						if(BSW->BSW_TPPOR == "3")
							BA1->(dbSetOrder(1))
							B49->(dbSetOrder(1))
							if(BA1->(msSeek(xFilial("BA1")+cCodFam+"D")))
								while BA1->(!EOF()) .and. (xFilial("BA1")+cCodFam+"D") == BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU)
									if !(B49->(msSeek(xFilial("B49")+BSW->BSW_CODUSR+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))))
										B49->(recLock("B49", .T.))
										B49->B49_FILIAL := xFilial("B49")
										B49->B49_CODUSR := BSW->BSW_CODUSR
										B49->B49_BENEFI := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
										B49->(msUnlock())
									endIf
									BA1->(dbSkip())
								endDo
							endif
						endIf
					endIf

					//replico o banco de conhecimento para o usuário da familia

					If len(aDados[4]) == 1
						BA1->(DbSetOrder(2))
						If BA1->(msSeek(xFilial("BA1")+aDados[4][1]))
							PLSREPDOC("BBA", BBA->BBA_CODSEQ, "BA1", BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO),,.T.,.F.)
						EndIf
					Else

						aRetDoc := PLSRETDOCS("BBA", BBA->BBA_CODSEQ,.T.)
						PLS977Doc(aRetDoc, aDados[4])

					endIf

					BA1->(dbSetOrder(1))
					if(BA1->(msSeek(xFilial("BA1")+cCodFam+cCodTit))) .AND. !empty(BA1->BA1_EMAIL)
						aMatrics := aDados[4]
						BOJ->(DbSetOrder(2))
						cFuncao := Left( "PLSA977AB" + Space( TamSX3("BOJ_ROTINA")[1] ), TamSX3("BOJ_ROTINA")[1] )
						if BOJ->(MsSeek(xFilial("BOJ") + cFuncao + "4"))
							PLSinaliza(BOJ->BOJ_CODSIN,,,alltrim(BA1->BA1_EMAIL), "Solicitação de inclusão de beneficiários",,,,,,,,,"000002")
						endIf
					endIf


				end transaction


			endIf
		else
			if(!empty(aDados[3]))
				MsgAlert(aDados[3]) //retorna o erro
			endIf
		endIf

	endIf

	// Ponto de entrada apos a gerar o grupo familiar
	If ExistBlock("PL977FAM")
		ExecBlock("PL977FAM",.f.,.f.,{cCodFam})
	Endif

	BA3->(dbCloseArea())
	BA1->(dbCloseArea())
	B49->(dbCloseArea())
	BOJ->(dbCloseArea())
	BSW->(dbCloseArea())


return
//--------------------------------------------------------------------------------
/*/{Protheus.doc} PL97ABRETB
Retorna os beneficiarios da solicitação e as matriculas que foram geradas para o envio do email
@author Karine Riquena Limp
@since 07/12/2015
@version P12
/*/
//---------------------------------------------------------------------------------
function PL97ABRETB()
	local cMsg := ""
	local cMatric := ""
	local cCodTit := getNewPar("MV_PLCDTIT", "T")
	local cCodDep := getNewPar("MV_PLCDDEP", "D")
	BA1->(dbSetOrder(1))

	if(BA1->(msSeek(xFilial("BA1")+cCodFam+cCodTit))) //ccodfam private que vem da função que chama o sinalizador
		cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
		if(BA1->BA1_DATINC == ddatabase) .AND. aScan(aMatrics, {|x| x == cMatric} ) > 0
			cMsg += BA1->BA1_NOMUSR + " " + BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"."+BA1_TIPREG+"-"+BA1_DIGITO) + "<br/>"
		endIf
		BA1->(dbSkip())
	endIf

	if(BA1->(msSeek(xFilial("BA1")+cCodFam+cCodDep))) //ccodfam private que vem da função que chama o sinalizador
		while BA1->(!EOF()) .and. (xFilial("BA1")+cCodFam+cCodDep) == BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU)
			cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
			if(BA1->BA1_DATINC == ddatabase) .AND. aScan(aMatrics, {|x| x == cMatric} ) > 0
				cMsg += BA1->BA1_NOMUSR + " " + BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"."+BA1_TIPREG+"-"+BA1_DIGITO) + "<br/>"
			endIf
			BA1->(dbSkip())
		endDo
	endIf
return cMsg

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS977ABTS
Manipula os registros da BA1 para alimentar corretamente as tabelas:
- BTS (Cadastro de vidas)
@author Karine Riquena Limp
@since 08/12/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS977ABTS(aDados)

	Local i := 1
	Local lRet := .T.
	Local aArea := getArea()
	Local nSeq := 0
	Local nPosBA1 := aScan(aDados, { |x| x[2][1] == "BA1" })
	local cCampo := ""
	local aEstBTS := BTS->(DBSTRUCT())

	//Ordena o array aDados para garantir que o CGC esteja localizado antes dos outros campos.
	BTS->(dbSetOrder(1))
	if(nPosBA1 > 0)
		i := nPosBA1

		while i <= len(aDados) .and. aDados[i][2][1] == "BA1"
			if(nSeq <> aDados[i][1])
				BA1->(dbGoto(val(aDados[i][2][4])))
				BTS->(msSeek(xFilial("BTS")+BA1->BA1_MATVID))
			endIf
			cCampo := "BTS_"+substr(aDados[i][2][2], 5)
			if aScan(aEstBTS, { |x| x[1] == cCampo }) > 0
				aadd(aDados, { Len(aDados)+1 , { "BTS", cCampo,	aDados[i][2][3], str(BTS->(recno())) , "2", aDados[i][2][6] }})
			endIf
			i++
		endDo

	endIf

	RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} P977BDOC
Busca a lista de documentos
@author Oscar Zanin
@since 04/12/2015
@version P12
/*/
//-------------------------------------------------------------------
Function P977BDOC(cCodMot)

	Local cCodInt		:=	PLSINTPAD()
	Local aMotB9X	  	:=	{}
	Local aMotDoc		:=	{}
	Local nI        	:=	1
	Local cRet       	:=	""
	Local cCdMotivo     := If(cCodMot == '0', getNewPar("MV_MOTINCB",""), cCodMot)

	//Verificamos se existem documentos associados aos motivos do Array
	//e criamos uma matriz
	B9X->(dbSelectArea("B9X"))
	B9X->(DbSetorder(1))

	//For nI:=1 To Len(aMotDoc)
	If(B9X->(MsSeek(xFilial("B9X")+cCodInt+cCdMotivo)))
		While((B9X->B9X_FILIAL==xFilial("B9X")).AND.(B9X->B9X_CODMOT==cCdMotivo).AND. !(B9X->(EoF())))
			Aadd(aMotB9X, B9X->B9X_CODDOC)
			B9X->(DbSkip())
		End
	EndIf
	//Next+
	B9X->(DbCloseArea())

	//Como vamos precisar das descrições, verificamos os documentos relacionados
	// na tabela BD2 e trocamos o código pela descrição do documento.
	If len(aMotB9X) > 0

		BD2->(DbSelectArea("BD2"))
		BD2->(DbSetOrder(1))

		For nI:=1 To Len(aMotB9X)

			If BD2->(MsSeek(xFilial("BD2")+aMotB9X[nI]))
				Aadd(aMotDoc, BD2->BD2_DESCRI)
			EndIf
		Next
		BD2->(DbCloseArea())
	EndIf

	//Monta o cRet para o portal
	For nI:=1 To Len(aMotDoc)

		if nI == 1
			cRet+="@"
		else
			cRet+=","
		EndIf
		cRet+=aMotDoc[nI]

	Next

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSPXCLB2N
Grava B2N -> Pós-gravação
@author Oscar Zanin
@since 04/12/2015
@version P12
/*/
//-------------------------------------------------------------------
function PLSPXCLB2N(nRecno, cCodBBA, cCodMot, cStatus, lPos )

	Local aB2NSX3	:= {}
	Local aBA1SX3	:= {}
	Local nI		:= 1
	Local nPos		:= 0
	Local PontodeParada
	Default cStatus := "1"
	Default lPos	  := .F.

	SX3->(DbSetOrder(1))

	SX3->(MsSeek("BA1"))
	While( SX3->X3_ARQUIVO == "BA1" .AND. !(Sx3->(EoF())) )
		If ( SX3->X3_CONTEXT <> "V" )
			Aadd(aBA1SX3, SX3->X3_CAMPO)
		EndIf
		SX3->(DbSkip())
	EndDo

	SX3->(MsSeek("B2N"))
	While( SX3->X3_ARQUIVO == "B2N" .AND. !(SX3->(EoF())) )
		If ( SX3->X3_CONTEXT <> "V" )
			Aadd(aB2NSX3, SX3->X3_CAMPO)
		EndIf
		SX3->(DbSkip())
	EndDo

	BA1->(DbSelectArea("BA1"))
	BA1->(DbGoTo(nRecno))

	BEGIN TRANSACTION

		If !(lPos)

			B2N->(DbSelectArea("B2N"))
			B2N->(RecLock("B2N", .T.))
			B2N->B2N_CODSEQ := getSxEnum("B2N", "B2N_CODSEQ")
			B2N->B2N_BA1REC := nRecno
			B2N->B2N_PROTOC := cCodBBA //Receber o código sequencial da BBA
			B2N->B2N_CODMOT := cCodMot //Receber o motivo que está no combo
			For nI := 1 to Len(aB2NSX3)
				nPos := Ascan(aBA1SX3, "BA1_"+ Right(aB2NSX3[nI], Len(aB2NSX3[nI])-4))
				If nPos > 0
					B2N->(&(aB2NSX3[nI])) := BA1->(&(aBA1SX3[nPos]))
				EndIf
			Next
			B2N->(MsUnlock())
			B2N->(DbCloseArea())
		else

			BBA->(DbSetOrder(1))
			BBA->(MsSeek(xFilial("BBA") + cCodBBA))
			BBA->(RecLock("BBA", .F.))
			BBA->BBA_STATUS := "2"
			BBA->(MsUnLock())
		EndIf

		B2N->(confirmSx8())
	END TRANSACTION

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLXPR997AB
Grava o pré-registro na BBA
@author Oscar Zanin
@since 04/12/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLXPR997AB(cUserCod, nTpPortal, cRecno, cCodMot, cVersP, cCodeP)

	Local cSQL			:= ""
	Local cNumProt	:= ""
	Local cCodFam		:= ""
	Local cCodBBA		:= ""
	Local nRecno 		:= Val(cRecno)
	Local cRecRet		:= ""
	local cCodTit := getNewPar("MV_PLCDTIT", "T")


	If nTpPortal == 3 //Beneficiário

		cCodFam := SubStr(cUserCod, 1,14)
		cCodInt := SubStr(cUserCod, 1,4)
		cCodEmp := SubStr(cUserCod, 5,4)
		cMatric := SubStr(cUserCod, 9,6)

		cSQL := "SELECT BA1_CODINT, BA1_CODEMP, BA1_CONEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA1_NOMUSR, BA1_VERSAO, BA1_CODPLA "
		cSQL += " FROM " + RetSQLName("BA1")
		cSQL += " WHERE BA1_CODINT = '" + cCodInt + "' AND BA1_CODEMP = '" + cCodEmp + "' AND BA1_MATRIC = '" + cMatric + "' "
		cSQL += " AND D_E_L_E_T_ = ''"
		cSQL += " AND BA1_TIPUSU = '" + cCodTit + "'"

		If Select("TRBBA1") > 0
			TRBBA1->(DbCloseArea())
		EndIf

		TCQUERY cSQL New Alias "TRBBA1"

		TRBBA1->(DbGoTop())

	Else //Empresa
		If Empty(cUserCod)

			BSW->(DbSetOrder(5))
			If BSW->(MSSeek(xFilial("BSW")+cUserCod))
				cUserCod := BSW->BSW_LOGUSR
			EndIf
		EndIf
	EndIf

	BBA->(DbSetOrder(1))
	Begin Transaction
		RecLock("BBA",.T.)
		BBA->BBA_FILIAL := xFilial("BBA")
		cCodBBA		  := GetSxeNum("BBA","BBA_CODSEQ")
		BBA->(ConfirmSX8())
		BBA->BBA_CODSEQ := cCodBBA
		BBA->BBA_TIPSOL := "2"
		BBA->BBA_STATUS := "1"
		BBA->BBA_CODINT := PlsIntPad()

		If nTpPortal == 3

			//Pega as informações da query
			BBA->BBA_MATRIC := TRBBA1->BA1_CODINT+TRBBA1->BA1_CODEMP+TRBBA1->BA1_MATRIC+TRBBA1->BA1_TIPREG+TRBBA1->BA1_DIGITO
			BBA->BBA_EMPBEN := TRBBA1->BA1_NOMUSR
			BBA->BBA_CODEMP := TRBBA1->BA1_CODEMP
			BBA->BBA_CONEMP := TRBBA1->BA1_CONEMP
			BBA->BBA_VERCON := TRBBA1->BA1_VERCON
			BBA->BBA_SUBCON := TRBBA1->BA1_SUBCON
			BBA->BBA_VERSUB := TRBBA1->BA1_VERSUB
			BBA->BBA_CODPRO := TRBBA1->BA1_CODPLA
			BBA->BBA_VERSAO := TRBBA1->BA1_VERSAO

		ElseIf nTpPortal == 2

			If nRecno > 0

				//Pega as informações do arquivo
				BA1->(DbGoTo(nRecno))
				BBA->BBA_MATRIC := BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)
				BBA->BBA_EMPBEN := BA1->BA1_NOMUSR
				BBA->BBA_CODEMP := BA1->BA1_CODEMP
				BBA->BBA_CONEMP := BA1->BA1_CONEMP
				BBA->BBA_VERCON := BA1->BA1_VERCON
				BBA->BBA_SUBCON := BA1->BA1_SUBCON
				BBA->BBA_VERSUB := BA1->BA1_VERSUB
				BBA->BBA_EMPBEN := cUserCod
				BBA->BBA_CODPRO := IIF( Empty(cCodeP), Posicione('BA3', 1, xFilial('BA3')+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC, 'BA3_CODPLA'), cCodeP)
				BBA->BBA_VERSAO := IIf( Empty(cVersP), Posicione('BA3', 1, xFilial('BA3')+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC, 'BA3_VERSAO'), cVersP)
			EndIf
		EndIf

		BBA->BBA_DATSOL := dDataBase
		BBA->BBA_HORSOL := Time()
		BBA->BBA_OBSERV := ""
		BBA->BBA_TIPMAN := "3"

		//nro protocolo registro ans-ano-mes-dia-codigo
		cNroProt := Posicione("BA0",1,xFilial("BA0")+PLSINTPAD(),"BA0_SUSEP") + Dtos(dDataBase)+ BBA->BBA_CODSEQ
		BBA->BBA_NROPRO := cNroProt

		MsUnLock()

		cRecRet := AllTrim(Str(BBA->(Recno())))
	End Transaction

	If Select("TRBB40") > 0
		TRBB40->(DbCloseArea())
	EndIf

	PLSPXCLB2N(nRecno, cCodBBA, cCodMot)

return cCodBBA+"~"+cRecRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS977ABPS
Muda o status da solicitação para em análise
@author Oscar Zanin
@since 04/12/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS977ABPS(nRecno, cCodMot,DtExclu)

	Local cCodBBA 	:= ""
	Local cRecnoRet	:= Str(nRecno)
	Local cTipUsu := ""
	Local cMatricFam := ""
	Local cTipoBloqueio := ""
	Local lCheckBloqTitular := BG3->(FieldPos("BG3_BLQFAM")) > 0 .And. B2N->(FieldPos("B2N_TIPBLO")) > 0

	Default DtExclu	:= Date()

	BBA->(DbGoTo(nRecno))
	cCodBBA := BBA->BBA_CODSEQ
	cMatricFam := Substr(BBA->BBA_MATRIC, 1, 14)

	BBA->(RecLock("BBA", .F.))
	BBA->BBA_STATUS := "2"
	BBA->(MsUnLock())

	B2N->(DbSetOrder(1))
	If B2N->(MsSeek(xFilial("B2N") + cCodBBA))	
		B2N->(RecLock("B2N", .F.))
		B2N->B2N_CODMOT := cCodMot
		B2N->B2N_DTBLOQ := DtExclu
		If lCheckBloqTitular
			cTipUsu := B2N->B2N_TIPUSU
			cTipoBloqueio := PLCheckBloqTit(cCodMot, cTipUsu, cMatricFam)

			If cTipoBloqueio == "1"
				B2N->B2N_TIPBLO := "1" // Bloqueio Família
			Else
				B2N->B2N_TIPBLO := "2" // Bloqueio Beneficiário
			EndIf
		EndIf
		B2N->(MsUnLock())
	EndIF

Return cRecnoRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS977WHNX
When dos campos referentes ao beneficiário que podem não vir preenchids da Web
@author Oscar Zanin
@since 28/04/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLS977WHNX(oModel, cCampo)

	Local oBBA 	:= oModel:getModel("MasterBBA")
	Local lEdita	:= !(EmpTy(AllTrim(oBBA:getValue(cCampo)))) //Verifica se não está em branco

return lEdita .AND. PLS977ABWH(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRETDOCS
Retorna os documentos
@author Karine Riquena Limp
@since 05/10/2016
@version P12
@param cEntFrom -  Alias da tabela que grava na AC9
@param cCodEntFrom - Chave da tabela sem a filial
@param lFilFrom - Se considera filial para fazer a busca pois
quando a tabela tem X2_UNICO considera a filial, quando não tem, considera o indice 1 sem a filial
/*/
//-------------------------------------------------------------------
Function PLSRETDOCS(cEntFrom, cCodEntFrom, lFilFrom)
	Local aRetDoc := {}
	Local cFilEntFrom := xFilial(cEntFrom)
	Default cEntFrom 		:= ""
	Default cCodEntFrom 	:= ""
	Default lFilFrom		:= .T. //indica se considera a filial pra buscar no AC9_CODENT quando a tabela tem X2_UNICO considera a filial, quando não tem, considera o indice 1 sem a filial

	if lFilFrom
		cCodEntFrom := cFilEntFrom + cCodEntFrom
	endIf

	AC9->(dbSetOrder(2))//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ
	ACB->(dbSetOrder(1))//ACB_FILIAL, ACB_CODOBJ

	If AC9->( MsSeek( xFilial( "AC9" )+ cEntFrom + cFilEntFrom + cCodEntFrom) )

		While AC9->(!EOF()) .AND. ( AC9->AC9_FILIAL + AllTrim(AC9->(AC9_ENTIDA+AC9_FILENT+AC9_CODENT))) == ;
				(xFilial( "AC9" ) + AllTrim(cEntFrom+cFilEntFrom+cCodEntFrom))

			ACB->(dbgotop())

			If ACB->( MsSeek( xFilial( "ACB" ) + AC9->AC9_CODOBJ) )//cCodObj) )

				AaDd(aRetDoc,{ACB->ACB_OBJETO, ACB->ACB_DESCRI, ACB->(RECNO()) } )

			EndIf

			AC9->(dbSkip())

		EndDo

	EndIf

return aRetDoc

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSREPDOC
Replica os banco de conhecimento para o grupo familiar
@author Karine Riquena Limp
@since 04/10/2016
@version P12
@param cEntFrom -  Alias da tabela origem que grava na AC9
@param cCodEntFrom - Chave da tabela origem sem a filial
@param cEntTo -  Alias da tabela destino que grava na AC9
@param cCodEntTo - Chave da tabela destino sem a filial
@param aRetDoc -  Se ja tiver os documentos é só passar o array e os dados da tabela destino
		{ACB->ACB_OBJETO, ACB->ACB_DESCRI, ACB->(RECNO()) }
@param lFilFrom - Se considera filial na tabela origem para buscar na AC9_CODENT pois
quando a tabela tem X2_UNICO considera a filial, quando não tem, considera o indice 1 sem a filial
@param lFilTo - Se considera filial na tabela destino para gravar na AC9_CODENT pois
quando a tabela tem X2_UNICO considera a filial, quando não tem, considera o indice 1 sem a filial
/*/
//-------------------------------------------------------------------
Function PLSREPDOC(cEntFrom, cCodEntFrom, cEntTo, cCodEntTo, aRetDoc, lFilFrom, lFilTo)
	Local nI		:= 1
	Default cEntFrom 		:= ""
	Default cCodEntFrom 	:= ""
	Default cEntTo 		:= ""
	Default cCodEntTo 	:= ""
	Default aRetDoc 		:= {}
	Default lFilFrom		:= .T. //indica se considera a filial pra buscar no AC9_CODENT quando a tabela tem X2_UNICO considera a filial, quando não tem, considera o indice 1 sem a filial
	Default lFilTo 		:= .T. //indica se considera a filial pra gravar no AC9_CODENT quando a tabela tem X2_UNICO considera a filial, quando não tem, considera o indice 1 sem a filial

	if len(aRetDoc) == 0
		aRetDoc := PLSRETDOCS(cEntFrom, cCodEntFrom, lFilFrom)
	endIf

	Begin Transaction

		For nI := 1 to Len(aRetDoc)

			ACB->(Reclock("ACB", .T.))

			ACB->ACB_FILIAL := xFilial("ACB")
			ACB->ACB_CODOBJ := GetSxeNum("ACB","ACB_CODOBJ")
			ACB->ACB_OBJETO := aRetDoc[nI][1]
			ACB->ACB_DESCRI := aRetDoc[nI][2]

			ACB->(MsUnlock())

			AC9->(Reclock("AC9", .T.))

			AC9->AC9_FILIAL := xFilial("AC9")
			AC9->AC9_FILENT := xFilial(cEntTo)
			AC9->AC9_ENTIDA := cEntTo
			AC9->AC9_CODENT := iif(lFilTo, xFilial(cEntTo)+cCodentTo, cCodentTo)
			AC9->AC9_CODOBJ := ACB->ACB_CODOBJ

			AC9->(MsUnlock())

		Next nI

	End Transaction

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS977Doc
Cria dialog para associar os documentos com os beneficiários
@author Karine Riquena Limp
@since 05/10/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLS977Doc(aRetDoc, aMatrics)
	Local aCampos  	:= {"BENEF"} 	//Variável contendo o campo editável no Grid
	Local oLista     	:= nil       	//Declarando o objeto do browser
	Local oDlg			:= nil
	Local aCabecalho 	:= {}     		//Variavel que montará o aHeader do grid
	Local aColsEx 	:= {}         //Variável que receberá os dados
	Local aPosObj   	:= {}
	Local aObjects 	:= {}
	Local aSize     	:= {}
	Local aInfo     	:= {}
	Local aRet			:= {}
	Local aBenefs		:= {}
	Local nOpca		:= 0
	Local nDoc			:= 0
	Local nBenef		:= 0
	Local nI			:= 0
	Local nJ			:= 0
	Local cCboxBenef 	:= ""

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 1, 1, .T., .T., .F. } )
	AAdd( aObjects, { 1, aSize[4] * 0.25, .T., .F., .F. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	BA1->(DbSetOrder(2))
	For nI := 1 to len(aMatrics)
		If BA1->(msSeek(xFilial("BA1")+aMatrics[nI]))
			cCboxBenef += BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO)+"=" + Alltrim(BA1->BA1_NOMUSR) + iif(nI == len(aMatrics), "",";")
			aAdd(aBenefs, BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO))
		EndIf
	Next nI

	DEFINE MSDIALOG oDlg TITLE STR0045 /*"Associar Documentos"*/ From aSize[7],0 To aSize[6]*0.7,aSize[5]*0.4 OF GetWndDefault() PIXEL Style DS_MODALFRAME //retiro o "x"

	//chamar a função que cria a estrutura do aHeader
	CriaCabDoc(@aCabecalho, cCboxBenef, aRetDoc)

	nDoc 	:= aScan(aCabecalho, {|x|AllTrim(x[2]) == "DOCUMENTO"})
	nBenef := aScan(aCabecalho, {|x|AllTrim(x[2]) == "BENEF"})

	//Ajusta a posiçao e tamanho do Get
	nLarg 		:= aPosObj[2,4]*0.8
	nTop 		:= aPosObj[2,1]
	nLeft 		:= aPosObj[2,2]
	nBottom	:= aPosObj[2,3]

	//Monta o browser com inclusão, remoção e atualização
	oLista := MsNewGetDados():New( nTop, nLeft, nBottom, nLarg, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aCampos,,99, "AllwaysTrue", "", "AllwaysTrue", oDlg, aCabecalho, aColsEx)

	//Carregar os itens que irão compor o conteudo do grid
	LoadColDoc(@aColsEx, @oLista, aRetDoc)

	//Alinho o grid para ocupar todo o meu formulário
	oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//Ao abrir a janela o cursor está posicionado no meu objeto
	oLista:oBrowse:SetFocus()

	EnchoiceBar(oDlg, {|| nOpca := 1, oDlg:End() }, {|| msgInfo(STR0046) },,,,,,,.F.,.T.) /*"Não é possível cancelar, é necessário associar os documentos" */

	ACTIVATE MSDIALOG oDlg CENTERED

	For nI := 1 To Len(oLista:aCols)

		ACB->(dbGoto(val(oLista:aCols[nI, nDoc])))

		if oLista:aCols[nI, nBenef] == "0"
			For nJ := 1 to Len(aBenefs)
				PLSREPDOC("", "", "BA1", aBenefs[nJ], {{ACB->ACB_OBJETO, ACB->ACB_DESCRI}},.F.,.F. )
			Next nJ
		else
			PLSREPDOC("", "", "BA1", oLista:aCols[nI, nBenef], {{ACB->ACB_OBJETO, ACB->ACB_DESCRI}},.F.,.F. )
		endIf

	Next

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaCabDoc
Cria cabeçalho da dialog para associar os documentos
@author Karine Riquena Limp
@since 05/10/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function CriaCabDoc(aCabecalho, cCboxBen, aRetDoc)
	Local cCboxDoc := ""
	Local nI := 0

	For nI := 1 to len(aRetDoc)
		cCboxDoc += Alltrim(STR(aRetDoc[nI,3])) + "="+aRetDoc[nI,2] + iif(nI == len(aRetDoc), "",";")
	Next nI

	Aadd(aCabecalho, {;
		STR0047 /*"Documento"*/,;//X3Titulo()
		"DOCUMENTO",;  //X3_CAMPO
		"@!",;			//X3_PICTURE
		80,;			//X3_TAMANHO
		0,;			//X3_DECIMAL
		"",;			//X3_VALID
		"",;			//X3_USADO
		"C",;			//X3_TIPO
		"",; 			//X3_F3
		"V",;			//X3_CONTEXT
		cCboxDoc,;	//X3_CBOX
		"",;			//X3_RELACAO
		"",;			//X3_WHEN
		"V"})			//
	Aadd(aCabecalho, {;
		STR0048 /*"Beneficiário"*/,;//X3Titulo()
		"BENEF",;  //X3_CAMPO
		"@!",;		//X3_PICTURE
		50,;			//X3_TAMANHO
		0,;			//X3_DECIMAL
		"",;			//X3_VALID
		"",;			//X3_USADO
		"C",;			//X3_TIPO
		"",; 			//X3_F3
		"R",;			//X3_CONTEXT
		"0=Todos;"+cCboxBen,;   	//X3_CBOX
		"",;			//X3_RELACAO
		""})			//X3_WHEN
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadColDoc
Carrega itens para preencher o browse para associar os documentos
@author Karine Riquena Limp
@since 05/10/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function LoadColDoc(aColsEx, oLista, aRetDoc)

	Local aCols := {}
	Local i := 1

	For i := 1 to len(aRetDoc)

		aadd(aColsEx,{ALLTRIM(STR(aRetDoc[i,3])),"0", .F.})

	Next

	//Setar array do aCols do Objeto.
	oLista:SetArray(aColsEx,.T.)

	//Atualizo as informações no grid
	oLista:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PlLoadAnz
Executa o filtro do tipo de ação novamente
/*/
//-------------------------------------------------------------------
Static Function PlLoadAnz()

	//Fecha o browser atual
	CloseBrowse()

	//Executa a rotina novamente
	PLSA977AB()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLEXISSOLI
Verifica se existe uma solicitação de bloqueio em análise na rotina
de análise de beneficiários
/*/
//-------------------------------------------------------------------
Function PLEXISSOLI(nRecno) //12-04 funcao inteira

	LOCAL aAreaEXISO := GetArea()
	LOCAL aRetEXISSO := {.F./*Não possui solicitação em análise */,""} //por padrão, não possui solicitação em análise

	DEFAULT nRecno   := 0

	If nRecno != 0

		BA1->(DbGoto(nRecno))

		BBA->(DbSetOrder(3))
		If BBA->( MsSeek( xFilial("BBA") +  BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO) ) )

			While BBA->(BBA_FILIAL + BBA_MATRIC) == BA1->(BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)

				//Se o tipo for bloqueio e o status for diferente de processado, rejeitado ou aprovado automaticamente
				//significa que existe uma solicitação pendente de análise
				If BBA->BBA_TIPMAN == "3" .AND. !BBA->BBA_STATUS $ "3,5,7"

					aRetEXISSO := {.T., BBA->BBA_NROPRO}
					EXIT
				EndIf
				BBA->(DbSkip())

			EndDo
		EndIf
	EndIf

	RestArea(aAreaEXISO)

Return aRetEXISSO


//----------------------------------------------------------------------------------------
/*/{Protheus.doc} PLBENEFBLO
Verifica se o beneficiário esta bloqueado na data incluida para bloqueio do beneficiário
/*/
//----------------------------------------------------------------------------------------
Function PLBENEFBLO(nRecno, dDataBloq) //12-04 funcao inteira

	LOCAL aAreaBENEF  := GetArea()
	LOCAL lBloqueado  := .F.

	DEFAULT nRecno    := 0
	DEFAULT dDataBloq := CTOD("  /  /  ")

	If nRecno != 0

		BBA->(DbGoto(nRecno))
		BA1->(DbSetOrder(2))

		If BA1->( MsSeek( xFilial("BA1") + BBA->BBA_MATRIC))
			lBloqueado := PlChHiBlo("BCA",dDataBloq,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG)
		EndIf

	EndIf

	RestArea(aAreaBENEF)

Return lBloqueado

//---------------------------------------------------------------------------------------------------
/*/ {Protheus.doc} PLAFBNWRA
Atualiza de forma dinâmica BA1 e BTS, quando utilizado o layout de alteração de beneficiário,
além das validações do objeto MVC do cadastro de Vida.
cModWeb = Nome do layout genérico usado
cOrigem = Origem da solicitação: 1 - WEB / 2 - Remote (alfândega)
cMatVid = Matrícula da Vida
nRecnoBA1 = RECNO do BA1 posicionado.
@since 03/2020
@version P12
/*/
//---------------------------------------------------------------------------------------------------
function PLAFBNWRA(cModWeb, cOrigem, cMatVid, nRecnoBA1, lWeb)

	local aAreaBTS	:= BTS->(getArea())
	local aAreaBA1	:= BA1->(getArea())
	local oModelBTS	:= FWLoadModel("PLSA955")
	local nRecnoBTS	:= 0
	local cPrograma := ""

	default cModWeb	:= ""
	default cOrigem	:= "2"
	default lWeb := .F.

	if cOrigem == "2"
		BA1->( dbgoto(nRecnoBA1) )
		cMatVid := BA1->BA1_MATVID
	endif

	if BA1->(recno()) != nRecnoBA1
		BA1->( dbgoto(nRecnoBA1) )
	endif

	BTS->(DbSetOrder(1))
	if ( BTS->(MsSeek(xFilial("BTS") + cMatVid)) )
		nRecnoBTS := BTS->(RECNO())

		If lWeb
			cPrograma := PadR("LGALTBEN", TamSX3("BBL_PROGRA")[1])

			BBL->(DbSetOrder(2))	
			If BBL->(MsSeek(xFilial("BBL")+cPrograma+"BA1"+"BTS")) 
				PlsSinc("LGALTBEN","BA1","BTS",,.T., nRecnoBA1,,,nRecnoBTS)
			EndIf
		Else
			PlsSinc("LGALTBEN","BA1","BTS",,.T., nRecnoBA1,,,nRecnoBTS)
		EndIf

		//Vamos utilizar o MVC da tela de Vida, para realizar todas as validações. Por isso, o nome é "alterado", executar todas as validações.
		oModelBTS:SetOperation(4)
		oModelBTS:Activate()
		oModelBTS:GetModel('BTSMASTER'):setValue("BTS_NOMUSR", oModelBTS:GetModel('BTSMASTER'):GetValue('BTS_NOMUSR'))
		if (oModelBTS:VldData())
			oModelBTS:commitData()
		endif
		oModelBTS:deActivate()
		oModelBTS:destroy()
		freeObj( oModelBTS )
	endif

	RestArea(aAreaBTS)
	RestArea(aAreaBA1)
return

//--------------------------------------------------------------------
/*/ {Protheus.doc} PLCheckBloqTit
Verifica se será bloqueado somente o titular ou toda a familia quando
a solicitação for realizada pela Portal do Beneficiário

@author Vinicius Queiros Teixeira
@since 09/03/2021
@version Protheus 12
/*/
//--------------------------------------------------------------------
Function PLCheckBloqTit(cCodMotivo, cTipUsuario, cMatricFam, nRecno, lMensagem)

	Local cCodTitular := GetNewPar("MV_PLCDTIT", "T")
	Local cOperadora := PLSINTPAD()
	Local cMotivoBloq := ""
	Local cCodigoBBA := ""
	Local cRetorno := ""

	Default nRecno := 0
	Default lMensagem := .F.

	If nRecno > 0
		BBA->(DbGoTo(nRecno))
		cCodigoBBA := BBA->BBA_CODSEQ
		cMatricFam := Substr(BBA->BBA_MATRIC, 1, 14)

		B2N->(DbSetOrder(1))
		If B2N->(MsSeek(xFilial("B2N") + cCodigoBBA))
			cTipUsuario := B2N->B2N_TIPUSU
		EndIf
	EndIf 

	If cTipUsuario <> cCodTitular
		Return cRetorno // Bloqueio do Dependente (Beneficiário)
	EndIf

	B9G->(DbSetOrder(1))	
	If B9G->(MsSeek(xFilial("B9G") + cOperadora + cCodMotivo)) 
		cMotivoBloq := B9G->B9G_MOTBG3

		BG3->(DBSetOrder(1))
		If BG3->(MsSeek(xFilial("BG3") + cMotivoBloq))
			If BG3->BG3_BLQFAM == "0" .And. CheckBenefAtivos(cMatricFam) > 1
				cRetorno := "2" // Bloqueio somente do titular (Beneficiário)
			Else
				cRetorno := "1" // Bloqueio de toda a familia do titular (Família)
			EndIf
		EndIf
	EndIf

	If lMensagem
		Do Case
			Case cRetorno == "1"
				cRetorno := STR0050 //"O motivo escolhido ira bloquear toda a familia do titular."

			Case cRetorno == "2"
				cRetorno := STR0051 //"O motivo escolhido ira bloquear somente o titular, a familia permancera ativa."
		EndCase
	EndIf

Return cRetorno

//--------------------------------------------------------------------
/*/ {Protheus.doc} CheckBenefAtivos
Verifica quantos beneficiários estão ativos na familia

@author Vinicius Queiros Teixeira
@since 10/03/2021
@version Protheus 12
/*/
//--------------------------------------------------------------------
Static Function CheckBenefAtivos(cMatricFamilia)

	Local cOperadora := ""
	Local cEmpresa := ""
	Local cMatricula := ""
	Local cQuery := ""
	Local nQuantBenef := 0

	If Len(cMatricFamilia) == 14
		cOperadora := SubStr(cMatricFamilia, 1, 4)
	    cEmpresa := SubStr(cMatricFamilia, 5, 4)
		cMatricula := SubStr(cMatricFamilia, 9)

		cQuery := " SELECT COUNT(*) CONTADOR FROM " + RetSQLName("BA1") + " BA1 "
		cQuery += " WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"' "
		cQuery += "   AND BA1.BA1_CODINT = '"+cOperadora+"' "
		cQuery += "   AND BA1.BA1_CODEMP = '"+cEmpresa+"' "
		cQuery += "   AND BA1.BA1_MATRIC = '"+cMatricula+"' "
		cQuery += "   AND (BA1.BA1_DATBLO = ' ' OR BA1.BA1_DATBLO > '"+DtoS(dDataBase)+"') "
		cQuery += "   AND BA1.D_E_L_E_T_ = ' ' "

		nQuantBenef := MPSysExecScalar(cQuery, "CONTADOR")
	EndIf

Return nQuantBenef

//--------------------------------------------------------------------
/*/ {Protheus.doc} BenefTermoConsentimento
Visualiza o Termo de Consentimento do Beneficiário do protocolo (BBA)
Selecionado

@author Vinicius Queiros Teixeira
@since 07/05/2021
@version Protheus 12
/*/
//--------------------------------------------------------------------
Static Function BenefTermoConsentimento(oModel)
	
	Local cTipoManutencao := oModel:GetValue("MasterBBA", "BBA_TIPMAN")
	Local cMatricula := oModel:GetValue("MasterBBA", "BBA_MATRIC")
	Local cOperadora := Substr(cMatricula, 1, 4)
    Local cEmpresa := Substr(cMatricula, 5, 4)
    Local cMatFamilia := Substr(cMatricula, 9, 6)

	Do Case
		Case cTipoManutencao $ "1/2" // Inclusão e Alteração
			PLTermConsBenef(cOperadora, cEmpresa, cMatFamilia)

		Case cTipoManutencao == "3" // Exclusão
			Help(,, "Não Permitido",, "Não possui Termo de Consentimento para Protocolo de Exclusão.", 1, 0)

	EndCase

Return


//--------------------------------------------------------------------
/*/ {Protheus.doc} GetVersaoPlano
Retorna a Versão do Produto Saúde (Plano) Vigente

@author Vinicius Queiros Teixeira
@since 23/08/2021
@version Protheus 12
/*/
//--------------------------------------------------------------------
Static Function GetVersaoPlano(cOperadora, cPlano)

	Local cVersao := ""
	Local cQuery := ""
	Local cAliasTemp := ""

	Default cOperadora := PlsIntPad()
	Default cPlano := ""

	cAliasTemp := GetNextAlias()
	cQuery := " SELECT BIL.BIL_VERSAO FROM " + RetSQLName("BIL") + " BIL "
	cQuery += " WHERE BIL.BIL_FILIAL = '"+xFilial("BIL")+"' "
	cQuery += "   AND BIL.BIL_CODIGO = '"+cOperadora+cPlano+"' "
	cQuery += "   AND BIL.BIL_DATFIN = ' ' "
	cQuery += "   AND BIL.D_E_L_E_T_ = ' ' "

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTemp, .F., .T.) 

	While !(cAliasTemp)->(Eof())
		cVersao := (cAliasTemp)->BIL_VERSAO

		(cAliasTemp)->(DbSkip())
	EndDo

	(cAliasTemp)->(DbCloseArea())

Return cVersao


//--------------------------------------------------------------------
/*/ {Protheus.doc} PL977MobAtualiza
Função para preparar os dados para comunicar com a mobile saúde para
atualizar protocolo

@author Vinicius Queiros Teixeira
@since 18/03/2022
@version Protheus 12
/*/
//--------------------------------------------------------------------
Function PL977MobAtualiza()

	Local lComunica := .F.
	Local aComunica := {}
	Local lRetorno := .F.
	Local nIdOperadora := 0
	Local cMsHash := ""
	Local cMatricula := ""
	Local cProtocolo := ""
	Local cStatus := ""
	Local cObservacao := ""
	Local cMsgFinal := ""
	Local cTitFinal := ""

	If BBA->(FieldPos("BBA_IDOPER")) > 0 .And. BBA->(FieldPos("BBA_MSHASH")) > 0

		nIdOperadora := BBA->BBA_IDOPER	
		cMsHash := BBA->BBA_MSHASH
		cMatricula := BBA->BBA_MATRIC
		cProtocolo := BBA->BBA_NROPRO
		cStatus := BBA->BBA_STATUS
		cObservacao := BBA->BBA_OBSERV

		If !Empty(cMsHash)
			lComunica := .T.
		EndIf

	EndIf

	If lComunica

		aComunica := PL977MobComunica(nIdOperadora, cMsHash, cMatricula, cProtocolo, cStatus, cObservacao)

		cMsgFinal := IIf(aComunica[1], STR0052, IIf(!Empty(aComunica[2]), aComunica[2], STR0054)) // "Atualização realizada com sucesso!" ; "Não foi possivel atualizar o protocolo, verifique as configurações da integração." 
		cTitFinal := IIf(aComunica[1], STR0053, STR0024) //  "Protocolo" ; "Atenção"

		MsgInfo(cMsgFinal, cTitFinal) 
	Else
		MsgInfo(STR0055, STR0024) // "Integração não disponível para esse protocolo.";"Atenção"
	EndIf

Return lRetorno


//--------------------------------------------------------------------
/*/ {Protheus.doc} PL977MobComunica
Função que realiza a comunicação com o sistema extermo para atualizar o 
status do protocolo da atualização do beneficiário

@author Vinicius Queiros Teixeira
@since 18/03/2022
@version Protheus 12
/*/
//--------------------------------------------------------------------
Function PL977MobComunica(nIdOperadora, cMsHash, cMatricula, cProtocolo, cStatus, cObservacao, aAutomacao)

	Local lComunica := .F.
	Local cMsgError := ""
	Local cEndPoint := ""
	Local oComunica := Nil
	Local oConfig := PMobConfig():New()

	Default aAutomacao := {}

	oComunica := PMobAtuCadEnv():New(aAutomacao) 

    cEndPoint := Alltrim(Lower(oConfig:GetSettings()["atualizacaoCadastral"]["endpointStatus"]))
  
	If oComunica:MontaFormData(nIdOperadora, cMsHash, cMatricula, cProtocolo, cStatus, cObservacao)
		oComunica:SetEndPoint(cEndPoint)
		
		If oComunica:PostApi()
			lComunica := .T.
		EndIf
	EndIf

	If !lComunica
		cMsgError := oComunica:GetMessageError()
	EndIf

	FreeObj(oConfig)
    oConfig := Nil

Return {lComunica, cMsgError}