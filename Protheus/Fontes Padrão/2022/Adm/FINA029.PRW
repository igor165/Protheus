#Include "Protheus.ch"
#Include "FWMVCDEF.ch"
#Include "FINA029.ch"

Static __nTotPerc	:= 0
Static __lConfirmou	:= .F.
Static __lCopy		:= .F.
Static __nOper		:= 0
Static __lVersao	:= .F.
Static __cVerImov	:= ""

#DEFINE OPER_ALTEXP		10

#DEFINE	ENTER		Chr(13) + Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA029
Cadastro da Imóvel

@author  rafael rondon
@since 01/11/2019
@version 12
/*/
//-------------------------------------------------------------------
Function FINA029()

	Local oBrowse As Object

    If FindFunction("TemLCDPR") 

        If TemLCDPR()

            oBrowse := FWMBrowse():New()

            oBrowse:SetAlias( 'FVV' )
			
			AjustBS()
			
            oBrowse:SetDescription(STR0001) // 'Imóveis'
            oBrowse:Activate()
        
        EndIf

    Else

        Help(' ',1,STR0025 ,,STR0026,2,0,,,,,,)   // 'Função não compilada' ## 'Fonte FINA820 não está compilado no repositório'

    EndIf
    
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Define o MenuDef padrão.

@type Function

@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MenuDef() As Array

	Local aRotina As Array
	
	aRotina := {}

	ADD OPTION aRotina Title STR0005     	Action 'VIEWDEF.FINA029' OPERATION 2 ACCESS 0   //  Visualizar
	ADD OPTION aRotina Title STR0006		Action 'FIN029INC()' 	 OPERATION 3 ACCESS 0   // Incluir
	ADD OPTION aRotina Title STR0007 		Action 'VIEWDEF.FINA029' OPERATION 4 ACCESS 0   // Alterar
	ADD OPTION aRotina Title STR0008 		Action 'VIEWDEF.FINA029' OPERATION 5 ACCESS 0   // Excluir
	ADD OPTION aRotina Title STR0009 	    Action 'VIEWDEF.FINA029' OPERATION 8 ACCESS 0   // Imprimir
	ADD OPTION aRotina Title STR0054 	    Action 'FIN029Exp()' 	OPERATION OP_COPIA ACCESS 0   // Alt. Exploração
	
Return aRotina

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Define o ModelDef padrão

@type Function

@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef() As Object

	Local oStruFVV	As Object
    Local oStruFVG  As Object
    Local oModel	As Object
    
    oStruFVV      := FWFormStruct( 1, 'FVV' )
    oStruFVG      := FWFormStruct( 1, 'FVG' )
    
    oStruFVV:AddField( 		  ; // Ord. Tipo Desc.
		STR0041				, ;	// [01] Titulo do campo	//'Nome do País'
		STR0041				, ;	// [02] ToolTip do campo 	//'Nome do País'
		"FVV_NPAIS"			, ;	// [03] Id do Field
		"C"					, ;	// [04] Tipo do campo
		50					, ;	// [05] Tamanho do campo
		0					, ;	// [06] Decimal do campo
		{ || .T. }			, ;	// [07] Code-block de validação do campo
		{ || .T. }			, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
		.F.					, ;	// [10] Indica se o campo tem preenchimento obrigatório
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "F029INI('FVV_NPAIS')") ,,,;// [11] Inicializador Padrão do campo
		.T.)					//[14] Virtual
	
	oStruFVV:AddField( 		  ; // Ord. Tipo Desc.
		STR0042				, ;	// [01] Titulo do campo	//'Descrição'
		STR0042				, ;	// [02] ToolTip do campo 	//'Descrição'
		"FVV_DMOEDA"		, ;	// [03] Id do Field
		"C"					, ;	// [04] Tipo do campo
		30					, ;	// [05] Tamanho do campo
		0					, ;	// [06] Decimal do campo
		{ || .T. }			, ;	// [07] Code-block de validação do campo
		{ || .T. }			, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
		.F.					, ;	// [10] Indica se o campo tem preenchimento obrigatório
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "F029INI('FVV_DMOEDA')") ,,,;// [11] Inicializador Padrão do campo
		.T.)					//[14] Virtual
    
	oModel        := MPFormModel():New('FINA029', /* bPreVld */ , { |oModel| PosVld029(oModel) } , {|oModel| Gravacao(oModel)} , { |oModel| Cancel() } )
    
	oStruFVG:SetProperty('FVG_PERC'		, MODEL_FIELD_OBRIGAT, .F. )
    oStruFVG:SetProperty('FVG_PERC'		, MODEL_FIELD_VALID, {|| SumPartic('FVG_PERC')})

	oStruFVG:SetProperty('FVG_NUMIMO'	, MODEL_FIELD_INIT, {|| "000" })
	oStruFVG:SetProperty('FVG_ORIG'		, MODEL_FIELD_INIT, {|| "1" })

	oStruFVG:SetProperty('FVG_VERSAO'	, MODEL_FIELD_INIT, {|| FVV->FVV_VERSAO })

	oStruFVV:SetProperty('FVV_VIGFIM'	, MODEL_FIELD_VALID, {|| VldDtVig(oModel)})
    oStruFVV:SetProperty('FVV_PARTIC'	, MODEL_FIELD_VALID, {|| SumPartic('FVV_PARTIC')})
    oStruFVV:SetProperty('FVV_PAIS'		, MODEL_FIELD_VALID, {|| FIN029FVV('FVV_PAIS')})
    oStruFVV:SetProperty('FVV_MOEDA'	, MODEL_FIELD_VALID, {|| FIN029FVV('FVV_MOEDA')})

	oStruFVV:SetProperty('FVV_VERSAO'	, MODEL_FIELD_INIT, {|| F029FVVVER(oModel) })
    
	oModel:AddFields(   'MODEL_FVV_IMOVEL'              , /*cOwner*/                , oStruFVV      )
	oModel:AddGrid(	    'MODEL_FVG_IMOVEL_PESSOA'		, 'MODEL_FVV_IMOVEL'		, oStruFVG     , {|| M->FVV_TIPOEX != '1'} )
    
	oModel:SetDescription(STR0010)  // 'Cadastro de Imóveis'
	oModel:GetModel( 'MODEL_FVV_IMOVEL' ):SetDescription( STR0011 ) // 'Dados do Imovel'
    oModel:GetModel( 'MODEL_FVG_IMOVEL_PESSOA' ):SetDescription( STR0012 ) //   'Dados dos Terceiros'

    oModel:SetRelation( 'MODEL_FVG_IMOVEL_PESSOA', { { 'FVG_FILIAL', 'xFilial( "FVG" )' }, {'FVG_CODIMO', 'FVV_CODIGO' }, {'FVG_VERSAO', 'FVV_VERSAO'} }, FVG->( IndexKey( 3 ) ) )

    oModel:GetModel( 'MODEL_FVG_IMOVEL_PESSOA' ):SetUniqueLine( { 'FVG_FILIAL', 'FVG_CODPES'} )
    oModel:GetModel( "MODEL_FVG_IMOVEL_PESSOA" ):SetOptional( .T. )
 
    oModel:AddRules( 'MODEL_FVG_IMOVEL_PESSOA', 'FVG_CODPES', 'MODEL_FVV_IMOVEL', 'FVV_CODPES', 1 )
    
	If __nOper == OPER_ALTEXP
		oStruFVV:SetProperty( '*'  			, MODEL_FIELD_WHEN , {|| .F. } )
		oStruFVV:SetProperty('FVV_CODPES'  	, MODEL_FIELD_WHEN , {|| .T. } )
		oStruFVV:SetProperty('FVV_TIPOEX'  	, MODEL_FIELD_WHEN , {|| .T. } )
		oStruFVV:SetProperty('FVV_PARTIC'	, MODEL_FIELD_WHEN , {|| .T. } )
		oStruFVV:SetProperty('FVV_VIGINI'  	, MODEL_FIELD_WHEN , {|| .T. } )
		oStruFVV:SetProperty('FVV_VIGFIM'  	, MODEL_FIELD_WHEN , {|| .T. } )

	ElseIf __nOper == MODEL_OPERATION_INSERT
		oStruFVV:SetProperty( '*'  			, MODEL_FIELD_WHEN , {|| .T. } )
		oStruFVV:SetProperty('FVV_VERSAO'  	, MODEL_FIELD_WHEN , {|| .F. } )
		oStruFVV:SetProperty("FVV_PARTIC", MODEL_FIELD_WHEN, { || M->FVV_TIPOEX != '1' } )
	Else
		oStruFVV:SetProperty( '*'  			, MODEL_FIELD_WHEN , {|| .T. } )
		oStruFVV:SetProperty('FVV_VERSAO'  	, MODEL_FIELD_WHEN , {|| .F. } )
		oStruFVV:SetProperty('FVV_CODIGO'  	, MODEL_FIELD_WHEN , {|| .F. } )
		oStruFVV:SetProperty("FVV_PARTIC", MODEL_FIELD_WHEN, { || M->FVV_TIPOEX != '1' } )
	EndIf

	oModel:GetModel( "MODEL_FVG_IMOVEL_PESSOA" ):SetLoadFilter( Nil, " FVG_NUMIMO = '000' " )
	oModel:SetVldActivate( { |oModel| VldActivate( oModel ) } )
	
Return oModel

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Define a ViewDef padrão para o cadastro de Pessoa

@type Function

@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ViewDef() As Object

	Local oModel        := FWLoadModel( 'FINA029' )
	Local oStruFVV      := FWFormStruct( 2, 'FVV' )
    Local oStruFVG      := FWFormStruct( 2, 'FVG' )
	Local oView         := FWFormView():New()
	Local nOpc			:= oModel:GetOperation()
	
	oView:SetModel( oModel )

	oStruFVV:AddField("FVV_NPAIS" , "17", STR0041, STR0041, {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)	//"Nome do País"
	oStruFVV:AddField("FVV_DMOEDA" , "18", STR0042, STR0042, {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)	//"Descrição"

	oStruFVV:SetProperty( 'FVV_VIGINI'  , MVC_VIEW_ORDEM , '50' )
    oStruFVV:SetProperty( 'FVV_VIGFIM'  , MVC_VIEW_ORDEM , '51' )

	oStruFVG:RemoveField("FVG_NUMIMO")
	oStruFVG:RemoveField("FVG_VERSAO")
	oStruFVG:RemoveField("FVG_ORIG")

	oStruFVV:SetProperty( 'FVV_VERSAO'	, MVC_VIEW_CANCHANGE , .F. )
			
	oView:AddField( 'VIEW_FVV_IMOVEL'           , oStruFVV  ,   'MODEL_FVV_IMOVEL'          )
    oView:AddGrid(  'VIEW_FVG_IMOVEL_PESSOA' 	, oStruFVG  ,   'MODEL_FVG_IMOVEL_PESSOA'   )

	If __nOper <> OPER_ALTEXP
		oView:AddUserButton( 'Compl. Imóvel', '', {|oView| FINA032( nOpc, FVV->(Recno()), __cVerImov, .T., __nOper)})
    EndIf

    oView:EnableTitleView("VIEW_FVV_IMOVEL",STR0011) // "Dados do Imóvel"
    oView:EnableTitleView("VIEW_FVG_IMOVEL_PESSOA",STR0012) // "Dados dos Terceiros"

	oView:CreateHorizontalBox( 'SUPERIOR' , 65 )
    oView:CreateHorizontalBox( 'INFERIOR' , 35 )

	oView:SetOwnerView( 'VIEW_FVV_IMOVEL'           , 'SUPERIOR'    )
    oView:SetOwnerView( 'VIEW_FVG_IMOVEL_PESSOA'    , 'INFERIOR'    )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} updGrid()
Atualiza o mesmo campo em todas as linhas do FWFormGridModel

@author guilherme.sordi
@since	30/08/2021
@version 12
/*/
//-------------------------------------------------------------------

static Function updGrid(oGrid as object, cField as Character, cValue as Character)
	local nX as numeric
	for nX := 1 to oGrid:getQTDLine()
		oGrid:goLine(nX)
		oGrid:setValue(cField, cValue)
	next nX
return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN029Exp()
Define operacao PARA Ajustar a vigência de um cadastro de imóvel

@author Rodrigo Oliveira
@since	09/03/2020
@version 12
/*/
//-------------------------------------------------------------------
Function FIN029Exp()

	Local nOpc 				As Numeric
	Local nAct				As Numeric
	Local aBtnCopy 			As Array
	Local aBtnUpdate		As Array
	Local oModel			As Object
	local oGrid				as Object
	local oNewModel			as Object
	local oNewGrid			as Object
	local lCopyCompl		as logical
	Local cPerg				As Character

	aBtnCopy	 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //Confirmar e Cancelar
	aBtnUpdate	 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //Confirmar e Fechar
	nOpc 			:= OP_COPIA
	lCopyCompl		:= .F.

	__nOper 		:= OPER_ALTEXP
	__lConfirmou 	:= .F.
	__cVerImov		:= ""

	oModel := FwLoadModel("FINA032")
	oModel:Activate(.T.)

	//F029FVVVER(oModel, .F.)
	nAct = FWExecView( STR0054, "FINA029", /*MODEL_OPERATION_INSERT*/ nOpc,/*oDlg*/, /*bCloseOnOk*/, /*bOk*/,,aBtnCopy,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ ) //'Alt. Exploração' ## 'Ativar/Desativar'

	If nAct = 0
		If !Empty(oModel:GetValue("FXVDETAIL", "FXV_CODPES"))	
			cPerg	:= STR0068 // "Deseja copiar o complemento de imóvel?"
		Else
			cPerg	:= STR0069 // "Deseja incluir complemento para o imóvel agora?"
		EndIf
		lCopyCompl := MsgYesNo(cPerg, "COMPLIMOV")
	EndIf

	If lCopyCompl
		oNewModel := FwLoadModel("FINA032")
		oNewModel:setOperation(MODEL_OPERATION_UPDATE)
		oNewModel:Activate()
		cNewVersion := oNewModel:getValue("MODEL_FVV_IMOVEL", "FVV_VERSAO")	

		oGrid := oModel:getModel("FXVDETAIL")
		oNewGrid := oNewModel:getModel("FXVDETAIL")
		oNewGrid:copyDataFromGrid(oGrid)
		updGrid(oNewGrid, "FXV_VERSAO", cNewVersion)
		
		oGrid := oModel:getModel("MODEL_FVG_IMOVEL_PESSOA")
		oNewGrid := oNewModel:getModel("MODEL_FVG_IMOVEL_PESSOA")
		oNewGrid:copyDataFromGrid(oGrid)
		updGrid(oNewGrid, "FVG_VERSAO", cNewVersion)

		oNewModel:vldData()
		oNewModel:CommitData()	
		oNewModel:Deactivate()
		oNewModel:Destroy()
		oNewModel:= Nil
		oNewGrid:= Nil
		oGrid := nil

		nAct = FWExecView( STR0054, "FINA032", /*MODEL_OPERATION_INSERT*/ MODEL_OPERATION_UPDATE,/*oDlg*/, /*bCloseOnOk*/, /*bOk*/,,aBtnUpdate,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ ) //'Alt. Exploração' ## 'Ativar/Desativar'
	endif
		
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil	

	__lConfirmou 	:= .F.
	__lVersao		:= .F.
	__nOper 		:= 0

Return

//---------------------------------
/*/{Protheus.doc} FIN029INC
Define a operação de inclusão
@author  Rodrigo Oliveira
@since 09/03//2020
@version 12
/*/
//---------------------------------
Function FIN029INC()
	Local oModel   As Object
	Local nOpc	   As Numeric
	Local aButtons As Array

	//Inicializa variáveis
	oModel   := Nil
	nOpc     := MODEL_OPERATION_INSERT
	__nOper  := nOpc
	aButtons := {}

	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel := FwLoadModel("FINA029")
	oModel:SetOperation(nOpc)
	oModel:Activate()

	FWExecView( OemToAnsi(STR0004), "FINA029", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )		//"Incluir"

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil

	__nOper := 0

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosVld029()
Validação TudoOK do Modelo (Confirmar)

@type Function
@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Function PosVld029(oModel As Object, cAlias As Character) As Logical

Local lRet          As Logical
Local oModelFVG     As Object
Local oModelFXV     As Object
Local nI            As Numeric
Local nSumPerc      As Numeric
Local lExistTerc    As Logical
Local lHelp			As Logical
Local cCodigo		As Character
Local cVerImo		As Character
Local cDes			As Character
Local cVerFVV		As Character
Local cSol			As Character
Local cChaveFVV 	As Character
Local aArea			As Array
Local dVigIni 		As Date
Local dVigFim 		As Date
	
Default cAlias := "FVV"

lRet        := .T.
lExistTerc  := .F.      // Define se informou algum terceiro
lHelp		:= .F.
nI          := 0
oModelFXV	:= oModel:GetModel('FXVDETAIL')
oModelFVG   := oModel:GetModel('MODEL_FVG_IMOVEL_PESSOA')
nOper		:= oModel:GetOperation()

cDes 		:= ''
cSol 		:= ''
cVerFVV		:= ''
nSumPerc    := FWFldGet( cAlias + "_PARTIC",,oModel)
aArea		:= {}
dVigIni 	:= CTOD("//")
dVigFim 	:= CTOD("//")

If cAlias == 'FVV'
	cCodigo		:= FWFldGet("FVV_CODIGO",,oModel)
	cVerImo		:= FWFldGet("FVV_VERSAO",,oModel)
	dVigIni		:= FWFldGet("FVV_VIGINI",,oModel)
	dVigFim		:= FWFldGet("FVV_VIGFIM",,oModel)
	cChaveFVV	:= FWFldGet("FVV_FILIAL",,oModel) + cCodigo
EndIf

If ( FWFldGet( cAlias + "_TIPOEX",,oModel) != '1' .OR. FWFldGet( cAlias + "_PARTIC",,oModel) < 100 ) .And. oModelFVG:IsEmpty()
    Help(' ',1, "TERCVAZIO" ,, STR0038 + ENTER + STR0039,2,0)  // 'TERCVAZIO' ## "Para participação em conjunto (não individual), é necessária a indicação "##" de ao menos um parceiro"
    lRet := .F.        
EndIf

If lRet .And. FWFldGet("FVV_PAIS",,oModel) == "BR"
    If Empty(FWFldGet( If(cAlias == 'FVV', "FVV_UF", "FXV_UF"),,oModel)) .OR. Empty(FWFldGet( If( cAlias == 'FVV', "FVV_CODMUN", "FXV_CODMUN"),,oModel)) .OR. Empty(FWFldGet( cAlias + "_CEP",,oModel)) .OR. Empty(FWFldGet( cAlias + "_CAFIR",,oModel))
        Help(' ',1,STR0013 ,,STR0014 + ENTER + ENTER + STR0033 + ENTER + STR0034 + ENTER + STR0035 + ENTER + STR0036 + ENTER + STR0037 ,2,0)  // 'Campo Obrigatório' ## "Para país Brasil, é obrigatório informar os campos: ##Estado##Cod. Municipio##CEP##CAFIR##CAEPF "
        lRet := .F.
	ElseIf FWFldGet( cAlias + "_TIPOEX",,oModel) == '1' .And. Empty(FWFldGet(cAlias + "_CAEPF",,oModel))
		Help(' ',1, STR0013 ,, STR0050 ,2,0,,,,,, {STR0051})  // 'Campo Obrigatório' ## "Para tipo de exploração individual, o CAEPF é obrigatório" ## "Informe o CAEPF do declarante"
        lRet := .F.
    ElseIf Len(AllTrim(FWFldGet( cAlias + "_CEP",,oModel)) ) < 8
    	Help(' ',1, STR0048 ,, STR0049 ,2,0)  // "Cep Inválido" ## "Verificar o Código e informar um Cep Válido"
        lRet := .F.
    EndIf
    If lRet
		If Empty(FWFldGet( cAlias + "_CAEPF",,oModel))
			For nI := 1 To oModelFVG:Length()
				oModelFVG:GoLine(nI)
				If !oModelFVG:IsDeleted() .And. oModelFVG:GetValue('FVG_TPPES') == '1'
					If Empty(oModelFVG:GetValue('FVG_CAEPF'))
						lHelp := .T.
					Else
						lHelp := .F.
						Exit
					EndIf
				EndIf
			Next nI
			If lHelp
				If !IsBlind()
					If ! (lRet	:= MsgYESNO( STR0040 + ENTER + ENTER + STR0052, STR0053 ) ) // "Para país Brasil, é obrigatório informar o CAEPF (representante) de ao menos um dos sócios declarantes." ## "Deseja prosseguir com a gravação do imóvel sem informar um CAEPF?" ## "Atenção!"
						Help(' ',1,STR0013 ,, STR0047,2,0) // 'Campo Obrigatório' ## "Informe um CAEPF para um dos declarantes cadastrados. "
					EndIf
				EndIf
			EndIf
		EndIf
    EndIf
EndIf

If lRet
	For nI := 1 To oModelFVG:Length()
        oModelFVG:GoLine(nI)
        If !oModelFVG:IsDeleted() .AND. !Empty(oModelFVG:GetValue('FVG_CODPES'))
			lExistTerc := .T.   
            nSumPerc += oModelFVG:GetValue('FVG_PERC')
            If FWFldGet( cAlias + "_CODPES",,oModel) == oModelFVG:GetValue('FVG_CODPES')
                Help(' ',1,STR0027 ,,STR0028,2,0)  // 'Proprietário terceiro' ## 'O Proprietário/Contribuinte não pode ser um terceiro!'
                lRet := .F.                            
                Exit
            EndIf
        EndIf
    Next nI
EndIf

If lRet .AND. lExistTerc .AND. FWFldGet( cAlias + "_TIPOEX",,oModel) == '1' // Exploração Individual
    Help(' ',1,STR0029 ,,STR0030,2,0)  // 'Exploração Individual' ## 'Quando tipo Exploração Individual não informar terceiros!'
    lRet := .F.                                
EndIf

	If lRet .And. cAlias == 'FVV' .And. !Empty(cChaveFVV) .and.; // !Empty(dVigIni) ; //.and. !Empty(dVigFim) .and.
		!Empty(cCodigo) .and. !Empty(cVerImo)
		aArea := FVV->(GetArea())
		FVV->(DbSetOrder(2))
		FVV->(DbGoTop())
		If FVV->(DbSeek(cChaveFVV))
			While FVV->(!EOF()) .and. cChaveFVV == FVV->(FVV_FILIAL+FVV_CODIGO)

				DO CASE
					//Interseção Filial sem data informada
					Case Empty(dVigIni) .and. FVV->FVV_VERSAO != cVerImo
						cDes 	:= STR0070 // 'Existe mais de uma versão para o mesmo imóvel (conflito). ' 
						cSol 	:= STR0071 // "por favor, informe uma data de ínicio de vigência."
						cVerFVV := STR0057 + FVV->FVV_VERSAO	//"Versão: "
						lRet := .F.
					//Interseção Filial sem data informada
					Case ( Empty(FVV->FVV_VIGINI) .Or. Empty(FVV->FVV_VIGFIM)) .and. FVV->FVV_VERSAO != cVerImo
						cDes 	:= STR0072 // 'Existe uma versão com data de início ou fim não informada (conflito). ' 
						cSol 	:= STR0056 // "por favor, verifique as datas de vigência inicial e final."
						cVerFVV := STR0057 + FVV->FVV_VERSAO	//"Versão: "
						lRet := .F.
					//Intersecção Total (inicio e fim)
					Case (!Empty(dVigFim) .And. dVigIni >= FVV->FVV_VIGINI .and. dVigFim <= FVV->FVV_VIGFIM .and. FVV->FVV_VERSAO != cVerImo ) .Or. ;
						( Empty(dVigFim) .And. dVigIni <= FVV->FVV_VIGFIM .and. FVV->FVV_VERSAO != cVerImo )
						cDes 	:= STR0055 // 'Existe uma versão com vigência conflitante com a informada (vigência inicial e final internas).' 
						cSol 	:= STR0056 // "por favor, verifique as datas de vigência inicial e final."
						cVerFVV := STR0057 + FVV->FVV_VERSAO	//"Versão: "
						lRet := .F.
					//Intersecção de data inicial
					Case dVigIni >= FVV->FVV_VIGINI .and. dVigIni <= FVV->FVV_VIGFIM .and. FVV->FVV_VERSAO != cVerImo
						cDes	:= STR0058 // "Existe uma versão com vigência inicial conflitante com a informada."
						cSol	:= STR0059 // "Por favor, verifique as datas de vigência inicial."
						cVerFVV := STR0057 + FVV->FVV_VERSAO	//"Versão: "
						lRet := .F.

					//Intersecção de data final
					Case dVigFim >= FVV->FVV_VIGINI .and. dVigFim <= FVV->FVV_VIGFIM .and. FVV->FVV_VERSAO != cVerImo
						cDes 	:= STR0061 // "Existe uma versão com vigência final conflitante com a informada."
						cSol 	:= STR0062 // "Por favor, verifique as datas de vigência final."
						cVerFVV := STR0057 + FVV->FVV_VERSAO	//"Versão: "
						lRet := .F.

					//Intersecção de externa
					Case dVigIni <= FVV->FVV_VIGINI .and. dVigFim >= FVV->FVV_VIGFIM .and. FVV->FVV_VERSAO != cVerImo
						cDes	:= STR0060 // "Existe uma versão com vigência conflitante com a informada (vigência inicial e final externas)."
						cSol	:= STR0056 // "Por favor, verifique as datas de vigência inicial e final."
						cVerFVV := STR0057 + FVV->FVV_VERSAO	//"Versão: "
						lRet := .F.

					Case FVV->FVV_VERSAO == cVerImo
						dIniVigOri := FVV->FVV_VIGINI
						dFimVigOri := FVV->FVV_VIGFIM

				ENDCASE

				If !lRet
					HELP(' ',1,  STR0063 ,, ENTER + cDes+' '+cVerFVV ,2,0,,,,,, {cSol} )		//"INTERVALO DE VIGÊNCIA"
					If __nOper == OPER_ALTEXP
						//Volto os valores originais a
						oModel:SetValue("MODEL_FVV_IMOVEL","FVV_VIGINI", FVV->FVV_VIGINI )
						oModel:SetValue("MODEL_FVV_IMOVEL","FVV_VIGFIM", FVV->FVV_VIGFIM )
					EndIf
					Exit
				Else
					FVV->(DbSkip())
				EndIf
			EndDo
		EndIf

		RestArea(aArea)
		//Se for Ajuste de Vigência
		
	EndIf

If lRet
    lRet := Vld1ImoFil(oModel)
EndIf
	
__lConfirmou	:= lRet

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldActivate()
Validação de ativação do modelo

@type Function
@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function VldActivate( oModel As Object) As Logical

Local lRet          As Logical

lRet := Vld1ImoFil(oModel)

If lRet
    lRet := MayIUseCode( "FVV_" + cFilAnt ) // semáforo por filial
    If !lRet
        Help(' ',1,STR0023 ,,STR0024,2,0,,,,,,) // 'Filial' ## 'Está filial já está sendo cadastrada em uma outra estação!'
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Vld1ImoFil()
Validação de 1 Imóvel por filial

@type Function
@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function Vld1ImoFil( oModel As Object) As Logical

Local lRet          As Logical
Local aArea         As Array
Local aAreaFVV      As Array

lRet        := .T.
aArea       := GetArea()
aAreaFVV    := FVV->(GetArea())

If oModel:GetOperation() == 3 .And. __nOper != OPER_ALTEXP // Incluir

    DbSelectArea("FVV")
    FVV->(DbSetOrder(1))
    If FVV->(DbSeek(xFilial('FVV')) )
        lRet := .F.
        Help(' ',1,STR0017 ,,STR0018,2,0,,,,,,) // 'Imóvel por filial' ## 'Só é permitido cadastrar 1 imóvel por filial'
    EndIf
EndIf

RestArea(aAreaFVV)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F029EndSM0()
Pega a parte do endereço da SM0, retirando o número

@type Function
@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Function F029EndSM0() As Character

Local cEnd      As Character

cEnd := SM0->M0_ENDENT

If At(',',SM0->M0_ENDENT) > 0   // Tem ','
    cEnd := SubStr(SM0->M0_ENDENT,1,At(',',SM0->M0_ENDENT)-1)
EndIf

Return cEnd

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F029NumSM0()
Pega a parte do numero do endereço da SM0

@type Function
@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Function F029NumSM0() As Numeric

Local nNum      As Numeric

nNum := 0

If At(',',SM0->M0_ENDENT) > 0
    nNum := Val(SubStr(SM0->M0_ENDENT,At(',',SM0->M0_ENDENT)+1,Len(SM0->M0_ENDENT)))
EndIf

Return nNum

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F029IniCoM()
Inicializador padrão do Código do Municipio

@type Function
@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Function F029IniCoM() As Character

Local cCodMun       As Character
Local aArea         As Array
Local cAux          As Character

cCodMun     := ""
cAux        := ""
aArea       := GetArea()

If !Empty(SM0->M0_ESTENT) .AND. !Empty(SM0->M0_CODMUN) 

    If Len(AllTrim(SM0->M0_CODMUN)) == 7 // Estado + Municipio, Ex: 3550308
        cAux := SubStr(SM0->M0_CODMUN,3,Len(SM0->M0_CODMUN))
    ElseIf Len(AllTrim(SM0->M0_CODMUN)) == 5 // Municipio, Ex: 50308
        cAux := SubStr(AllTrim(SM0->M0_CODMUN),1,5)
    EndIf

    If !Empty(cAux)

        DBSelectArea('CC2')
        CC2->(DbSetOrder(1))
        If CC2->(MSSeek(xFilial('CC2') + SM0->M0_ESTENT + cAux))
            cCodMun := cAux
        EndIf
    EndIf

EndIf

RestArea(aArea)

Return cCodMun

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F029VPess()
Validação do campo Pessoa FVV_CODPES

@type Function
@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Function F029VPess( cCodPes As Character ) As Logical

Local lRet          As Logical
Local aArea         As Array

lRet        := .T.
aArea       := GetArea()

If !Empty(cCodPes)

    DbSelectArea("FVU")
    FVU->(DbSetOrder(1))    // FVU_FILIAL+FVU_CODIGO                                                                                                                                           
    If FVU->(DbSeek(xFilial('FVU') + cCodPes))
        If FVU->FVU_TIPCAD <> '1'
            lRet := .F.
            Help(' ',1,STR0019 ,,STR0020,2,0,,,,,,) // 'Tipo de Pessoa' ## 'O Contribuinte deve estar marcado como Contribuinte no Cadastro de Pessoas'
        EndIf
    Else
        lRet := .F.
        Help(' ',1,STR0021 ,,STR0022,2,0,,,,,,) // 'Proprietário' ## 'Registro não encontrado no Cadastro de Pessoas'
    EndIf

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F029IniCod()
Inicializador padrão do Código do Imovel

@type Function
@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Function F029IniCod() As Character

Local cCodigo       As Character
Local aArea         As Array
Local cAux          As Character
Local cQuery        As Character
Local cAliasQry     As Character

cCodigo     := ""
cAux        := ""
cQuery      := ""
aArea       := GetArea()

If __nOper != OPER_ALTEXP
	cAliasQry   := GetNextAlias()

	// MAX sem filial (Imóvel por Pessoa)
	BeginSql Alias cAliasQry
		SELECT MAX(FVV_CODIGO) MAX_CODIGO 
		FROM %Table:FVV% FVV
		WHERE FVV.%notDel%
	EndSql

	If (cAliasQry)->(!Eof())
		cCodigo := Soma1((cAliasQry)->MAX_CODIGO)
	EndIf

	(cAliasQry)->(DbCloseArea())
Else
	cCodigo	:= FVV->FVV_CODIGO	
EndIf

RestArea(aArea)

Return cCodigo

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Gravacao()
Gravação do Modelo

@type Function

@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function Gravacao(oModel As Object) AS Logical
	Local lRet As Logical

	lRet	:= .T.

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		If FwFldGet("FVV_VERSAO",, oModel) == '0001' .And. FilCompl(FVV->FVV_CODIGO) > 0
			oModel:SetErrorMessage("MODEL_FVV_IMOVEL", , "MODEL_FVV_IMOVEL", , , STR0066, STR0067, , ) // 'IMÓVEL VERSIONADO' ## 'Filial (versão 0001) que contém outras versões não pode ser excluída.'
			lRet	:= .F.
		Else
			FWFormCommit( oModel )

			DelCompl(oModel)
		EndIf
	Else
		FWFormCommit( oModel )
	EndIf
	
	FreeUsedCode()
	__nTotPerc	:= 0

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Cancel()
Cancelamento do Modelo

@type Function

@author rafael rondon
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function Cancel(oModel As Object) AS Logical

	FreeUsedCode()
    __nTotPerc	:= 0

Return .T.

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SumPartic()
Soma o total de participaão no imóvel

@type Function

@author Rodrigo Oliveira
@since 01/11/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Function SumPartic(cCampo As Character) As Logical
	Local oModel 		As Object
	Local oGrid			As Object
	Local nPerc			As Numeric
	Local nTotPerOld 	As Numeric
	Local nI			As Numeric
	Local lRet			As Logical
	
	oModel	:= FwModelActive()
	oGrid	:= oModel:GetModel("MODEL_FVG_IMOVEL_PESSOA")
	nPerc	:= 0
	nI		:= 0
	lRet	:= .T.
	
	If cCampo == "FVG_PERC"
		nTotPerOld := __nTotPerc
		If oModel:lModify
			__nTotPerc := 0
			For nI := 1 To oGrid:Length()
				__nTotPerc	+= oGrid:GetValue("FVG_PERC", nI)
			Next
		Else
			__nTotPerc += oGrid:GetValue("FVG_PERC")
		EndIf
	EndIf
	
	If cCampo == "FVG_PERC"
	 	If ( oGrid:GetValue("FVG_PERC") ) < 0
			oModel:SetErrorMessage("MODEL_FVV_IMOVEL", , "MODEL_FVV_IMOVEL", , , STR0043, STR0044, , ) // 'NEGATIVO' ## 'Porcentagem de participação não pode ser negativa.'
			lRet	:= .F.
		Else
			If ( oModel:GetValue("MODEL_FVV_IMOVEL", "FVV_PARTIC") + __nTotPerc ) <= 100
				nPerc	:= oGrid:GetValue("FVG_PERC")
			Else
				__nTotPerc	:= nTotPerOld
				oModel:SetErrorMessage("MODEL_FVV_IMOVEL", , "MODEL_FVV_IMOVEL", , , STR0031, STR0032, , ) // 'Percentagem total superior a 100%' ## "Total das porcentagens de participação (proprietário + terceiros) não deve ser maior que 100%"
				nPerc	:= 0
				lRet	:= .F.
			EndIf
		EndIf
	Else
		If ( oModel:GetValue("MODEL_FVV_IMOVEL", "FVV_PARTIC") ) < 0
			oModel:SetErrorMessage("MODEL_FVV_IMOVEL", , "MODEL_FVV_IMOVEL", , , STR0043, STR0044, , ) // 'NEGATIVO' ## 'Porcentagem de participação não pode ser negativa.'
			lRet	:= .F.
		Else
			If (oModel:GetValue("MODEL_FVV_IMOVEL", "FVV_PARTIC") + __nTotPerc) <= 100
				nPerc	:= oModel:GetValue("MODEL_FVV_IMOVEL", "FVV_PARTIC")
			Else
				oModel:SetErrorMessage("MODEL_FVV_IMOVEL", , "MODEL_FVV_IMOVEL", , , STR0031, STR0032, , ) // 'Percentagem total superior a 100%' ## "Total das porcentagens de participação (proprietário + terceiros) não deve ser maior que 100%"
				nPerc	:= 0
				lRet	:= .F.
			EndIf
		EndIf
	EndIf
	
	If nPerc == 100 .And. M->FVV_TIPOEX $ '2|4'
		oModel:SetErrorMessage("MODEL_FVV_IMOVEL", , "MODEL_FVV_IMOVEL", , , STR0045, STR0046, , ) // 'PARCEIR' ## 'Tipo de exploração não permite exploração individual de 100%.'
		lRet	:= .F.
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FPesTerc()
Valid do campo do código de Terceiro / Proprietário

@author  Rodrigo Oliveira
@since 05/11/2019
@version 12
/*/
//-------------------------------------------------------------------
Function FPesTerc() As Logical
	Local lRet		As Logical
	Local oModel	As Object
	Local cCodPes	As Character
	Local cProcName	As Character

	oModel		:= FWModelActive()
	cCodPes		:= (oModel:GetValue("MODEL_FVG_IMOVEL_PESSOA", "FVG_CODPES") )
	lRet		:= .F.
	cProcName	:= AllTrim(oModel:cID)
	
	If cProcName == "FINA032"
		If (oModel:GetValue("FXVDETAIL", "FXV_CODPES") ) == cCodPes
			lRet	:= .T.
		EndIf
	Else
		If (oModel:GetValue("MODEL_FVV_IMOVEL", "FVV_CODPES") ) == cCodPes
			lRet	:= .T.
		EndIf
	EndIf

	If lRet
		Help(' ',1,STR0027 ,,STR0028,2,0)  // 'Proprietário terceiro' ## 'O Proprietário/Contribuinte não pode ser um terceiro!'
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F029INI()
Inicializador padrão do Nome do País / Descrição da moeda

@author Rodrigo Oliveira
@since	13/12/2019
@version 12
/*/
//-------------------------------------------------------------------
Function F029INI(cCampo As Character) As Character

	Local cRet 		As Character
	Local cCodigo 	As Character
	Local nOper		As Numeric
	Local oModel 	As Object
	Local oFVV 		As Object
	
	DEFAULT cCampo := ""

	oModel		:= FWModelActive()
	nOper		:= oModel:GetOperation()
	oFVV 		:= oModel:GetModel("MODEL_FVV_IMOVEL")
	cRet		:= ""
	cCodigo		:= ""

	If !Empty(cCampo)
		If cCampo = "FVV_NPAIS"
			cCodigo	:= oModel:GetValue("MODEL_FVV_IMOVEL","FVV_PAIS")
			If !Empty(cCodigo)
				SX5->(MsSeek(xFilial("SX5") + 'SW'+ cCodigo ))
				cRet := SX5->X5_DESCRI
			EndIf
		Else
			cCodigo		:= oModel:GetValue("MODEL_FVV_IMOVEL","FVV_MOEDA")
			If !Empty(cCodigo)
				SX5->(MsSeek(xFilial("SX5") + 'SY'+ cCodigo ))
				cRet := SX5->X5_DESCRI
			EndIf
		EndIf
	EndIf

	If __nOper == OPER_ALTEXP .And. !__lVersao
		__lVersao	:= .T.
		If __cVerImov == ''
			F029FVVVER(oModel, .F.)
		EndIf
	EndIf
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN029FVV()
Pos Validacao de preenchimento dos códigos de País e Moeda

@author Rodrigo Oliveira
@since	14/10/2019
@version 12
/*/
//-------------------------------------------------------------------
Function FIN029FVV(cCampo As Character) As Logical
	
	Local lRet 		As Logical
	Local oModel 	As Object
	Local oFVV	 	As Object	
	Local cCodigo	As Character
	Local aArea 	As Array
	
	DEFAULT cCampo	:= ""

	lRet 	:= .T.
	aArea 	:= GetArea()
	oModel 	:= FWModelActive()
	oFVV	:= oModel:GetModel( 'MODEL_FVV_IMOVEL' )

	If !Empty(cCampo)
		If cCampo = "FVV_PAIS"
			cCodigo	:= oModel:GetValue( 'MODEL_FVV_IMOVEL', cCampo)
			If !Empty(cCodigo)
				SX5->(MsSeek(xFilial("SX5") + 'SW'+ cCodigo ))
				oModel:SetValue('MODEL_FVV_IMOVEL','FVV_NPAIS', AllTrim(SX5->X5_DESCRI) )
			EndIf
		ElseIf cCampo = "FVV_MOEDA"
			cCodigo	:= oModel:GetValue( 'MODEL_FVV_IMOVEL', cCampo)
			If !Empty(cCodigo)
				SX5->(MsSeek(xFilial("SX5") + 'SY'+ cCodigo ))
				oModel:SetValue('MODEL_FVV_IMOVEL','FVV_DMOEDA', AllTrim(SX5->X5_DESCRI) )
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} VldDtVig

Validar Período

@sample     
@return		
@author		Rodrigo Oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function VldDtVig( oModel As Object ) As Logical

Local lRet      As Logical
Local dDtIni	As Date
Local dDtFim	As Date

lRet 	:= .T.

dDtIni	:= oModel:GetValue( "MODEL_FVV_IMOVEL", "FVV_VIGINI")
dDtFim	:= oModel:GetValue( "MODEL_FVV_IMOVEL", "FVV_VIGFIM")

If Empty(dDtIni)
	oModel:SetErrorMessage("MODEL_FVV_IMOVEL", , "MODEL_FVV_IMOVEL", , , 'DTINIVIG', 'Data inicial de vigência não informada.' /*STR0044*/, , ) // 'DTINIVIG ## 'Data inicial de vigência não informada.' STR To Do
	lRet	:= .F.
Else
	If !Empty(dDtFim) .And. dDtIni > dDtFim
		lRet := .F.
		Help(' ',1, STR0064,, STR0065,2,0,) // 'Vigência' ## 'Data Inicial não pode ser maior que a data final!' // STR To do Rod
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F029FVVVER()
Inicializador padrão do campo FVV_VERSAO

@author Rodrigo Oliveira
@since	09/03/2020
@version 12
/*/
//-------------------------------------------------------------------
Function F029FVVVER(oModel As Object, lLdVer As Logical) As Character

	Local cCod 	As Character
	Local cRet 	As Character
	Local aArea As Array

	DEFAULT oModel 	:= NIL
	DEFAULT lLdVer	:= .T.

	cCod		:= ""
	cRet		:= ""
	__cVerImov	:= ""
	aArea		:= {}

	aArea	:= FVV->(GetArea())

	If __nOper == OPER_ALTEXP .Or. ( oModel <> Nil .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. Empty(AllTrim(FwFldGet( 'FVV_VERSAO',, oModel ))) )
		cCod := FVV->FVV_CODIGO
		cRet := FVV->FVV_VERSAO
		While .T.
			cRet := Soma1(cRet,4)
			FVV->(DbSetOrder(2))
			If !(FVV->(MsSeek(xFilial("FVV")+cCod+cRet)))
				If oModel != NIL .And. lLdVer
					oModel:LoadValue("MODEL_FVV_IMOVEL","FVV_VERSAO",cRet)
				EndIf
				Exit
			EndIf
		EndDo
	Else
		cRet := '0001'
	EndIf

	__cVerImov := cRet
	RestArea(aArea)
Return cRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} F029Whe
Permissão de edição de campos (When)

@param oGridModel - Model que chamou a validação
@param cCampo - Campo a ser validada permissão de edição

@author Rodrigo Oliveira
@since 09/03/2020

@return Logico com permissão ou não de edição do campo
/*/
//-------------------------------------------------------------------
Function F029Whe(oModel As Object, cCampo As Character)

Local lRet As Logical

DEFAULT oModel := NIL
DEFAULT cCampo := ""

lRet := .T.

If __nOper != OPER_ALTEXP .Or. cCampo == 'FVV_VERSAO'
	lRet	:= .F.
EndIf

If cCampo == 'FVV_VERSAO' .And. (__nOper == OPER_ALTEXP .OR. ( oModel:Getoperation() == MODEL_OPERATION_UPDATE .And. Empty(AllTrim(FwFldGet( "FVV_VERSAO",, oModel ))) ) ) /*__nOper == OPER_COPIAR)*/ .AND. __lVersao == .F.
	__lVersao := .T.
	F029FVVVER(oModel)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} AjustBS
Ajuste inicial na base dos clientes piloto

@author Rodrigo Oliveira
@since 11/03/2020

@return Nil
/*/
//-------------------------------------------------------------------
Static Function AjustBS()
	Local aArea 	As Array
	Local cAliasQry	As Character

	aArea		:= GetArea()
	cAliasQry	:= ""

	cAliasQry	:= GetNextAlias()

	BeginSql Alias cAliasQry
		Select R_E_C_N_O_ AS REC
		  From %Table:FVU% FVU
		  	Where FVU_FILORI = ' '
			  And FVU.%notdel%
	EndSql

	If !(cAliasQry)->(Eof())
		DbSelectArea("FVU")
		DbSetOrder(1)
		While !(cAliasQry)->(Eof())
			DbGoTo((cAliasQry)->REC)
			RecLock("FVU", .F.)
			Replace FVU_FILORI With cFilAnt
			FVU->(MsUnLock())
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf

	(cAliasQry)->(DbCloseArea())

	cAliasQry	:= GetNextAlias()

	BeginSql Alias cAliasQry
		Select R_E_C_N_O_ AS REC
		  From %Table:FVV% FVV
		  	Where FVV_VERSAO = ' '
			  And FVV.%notdel%
	EndSql

	If !(cAliasQry)->(Eof())
		DbSelectArea("FVV")
		DbSetOrder(1)
		While !(cAliasQry)->(Eof())
			DbGoTo((cAliasQry)->REC)
			RecLock("FVV", .F.)
			Replace FVV_VERSAO With "0001"
			FVV->(MsUnLock())
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf

	(cAliasQry)->(DbCloseArea())

	cAliasQry	:= GetNextAlias()

	BeginSql Alias cAliasQry
		Select R_E_C_N_O_ AS REC
		  From %Table:FVG% FVG
		  	Where FVG_VERSAO = ' '
			  Or FVG_NUMIMO = ' '
			  Or FVG_ORIG = ' '
			  And FVG.%notdel%
	EndSql

	If !(cAliasQry)->(Eof())
		DbSelectArea("FVG")
		DbSetOrder(1)
		While !(cAliasQry)->(Eof())
			DbGoTo((cAliasQry)->REC)
			If Empty(AllTrim(FVG_VERSAO))
				RecLock("FVG", .F.)
				Replace FVG_VERSAO With "0001"
				FVG->(MsUnLock())
			EndIf
			If Empty(AllTrim(FVG_NUMIMO))
				RecLock("FVG", .F.)
				Replace FVG_NUMIMO With "000"
				FVG->(MsUnLock())
			EndIf
			If Empty(AllTrim(FVG_ORIG))
				RecLock("FVG", .F.)
				Replace FVG_ORIG With "1"
				FVG->(MsUnLock())
			EndIf
			
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf

	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/ {Protheus.doc} DelCompl
Eliminação do complemento do imóvel

@author Rodrigo Oliveira
@since 13/03/2020

@return Nil
/*/
//-------------------------------------------------------------------
Function DelCompl(oModel As Object)
	Local cCodigo	As Character
	Local cFil		As Character
	Local cVerFX	As Character

	cFil	:= FwFldGet("FVV_FILIAL",, oModel)
	cCodigo := FwFldGet("FVV_CODIGO",, oModel)
	cVerFX	:= FwFldGet("FVV_VERSAO",, oModel)

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		DbSelectArea("FXV")
		DbSetOrder(2)
		DbGoTop()
		FXV->(DbSeek(cFil + cCodigo))
		While !FXV->(Eof())
			If	cFil == FXV->FXV_FILIAL .And. cCodigo == FXV->FXV_CODIGO .And. cVerFX == FXV->FXV_VERSAO
				RecLock("FXV", .F.)
				FXV->(DbDelete())
				MsUnlock("FXV")
				FXV->(DbSkip())
			Else
				FXV->(DbSkip())
			EndIf
		EndDo
		DbSelectArea("FVG")
		DbSetOrder(2)
		DbGoTop()
		FVG->(DbSeek(cFil + cCodigo))
		While !FVG->(Eof())
			If	cFil == FVG->FVG_FILIAL .And. cCodigo == FVG->FVG_CODIMO .And. FVG->FVG_NUMIMO != '000' .And. cVerFX == FVG->FVG_VERSAO
				RecLock("FVG", .F.)
				FVG->(DbDelete())
				MsUnlock("FVG")
				FVG->(DbSkip())
			Else
				FVG->(DbSkip())
			EndIf
		EndDo
	EndIf

Return Nil

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FilCompl()
Verifica se a filial tem complemento

@param cCodigo - código da filial

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function FilCompl(cCodigo As Character) As Numeric
	Local cQuery	As Character
	Local nRet		As Numeric

	Default cCodigo := " "

	cQuery 	:= " Select Count(FVV_FILIAL) AS QTDE From " + RetSqlName("FVV") + " FVV "
	cQuery	+= " Where FVV_CODIGO = '" + cCodigo + "' And FVV_VERSAO != '0001' AND FVV.D_E_L_E_T_ = ' ' " 
     
    nRet	:= MpSysExecScalar(cQuery,"QTDE")

Return nRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FINA029SetOp()
Sea a operação (usado para TestCase já que chama direto sema  tela)

@param nOperation - operação do model
@author	rafael.rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Function FINA029SetOp( nOperation As Numeric )

__nOper  := nOperation

Return
