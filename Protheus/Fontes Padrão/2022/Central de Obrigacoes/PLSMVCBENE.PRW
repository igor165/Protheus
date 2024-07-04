#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'PLSMVCBENE.CH'

#DEFINE SIB_INCLUIR    "1" // Incluir
#DEFINE SIB_RETIFIC    "2" // Retificar
#DEFINE SIB_MUDCONT    "3" // Mud.Contrat
#DEFINE SIB_CANCELA    "4" // Cancelar
#DEFINE SIB_REATIVA    "5" // Reativar

#DEFINE MVCERRCOD 5
#DEFINE MVCERRDES 6
#DEFINE MVCERRSOL 7
#DEFINE PDTE_VALID		"1" // Pendente Validacao
#DEFINE VALIDO         "2" // Valido
#DEFINE INVALIDO			"3" // Invalido
#DEFINE ENV_ANS        "4" // Enviado ANS
#DEFINE CRIT_ANS       "5" // Criticado ANS
#DEFINE ACAT_ANS       "6" // Acatado ANS
#DEFINE CANCELADO      "7" // Cancelado
#DEFINE JOB_VALID		"1" // Job Validacao
#DEFINE ESPELHO_COMP	"2" // Comparacao de Espelhos
#DEFINE ARQ_RETORNO    "3" // Arquivo Retorno

#DEFINE CAMPO    		1
#DEFINE VALOR_NOVO    	2
#DEFINE VALOR_ANTIGO    3


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCBENE

Manutencao de beneficiarios no nucleo de informacoes e obrigacoes

@author timoteo.bega
@since 26/01/2016.
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCBENE(lAuto,cFiltro,cDescript)
	Local   oMark	    := Nil
	Local   aCoors    := FWGetDialogSize( oMainWnd )
	Local   oFWLayer  := FWLayer():New()
	Local   oPnl
	Local   cAlias	  := "B3K"
	Local  cSql       := ""
	Local cMarca      := ""
	Private lMark	  := .F.
	Private cFilBrw	  := ''
	Private oDlgB3K
	Private aRotina	  :=	{}
	Default cFiltro   := ''
	Default cDescript := STR0001
	Default lAuto		  := .F.

	DbSelectArea("B3K")
	lMark := B3K->(FieldPos("B3K_MARK")) > 0

	(cAlias)->(dbSetOrder(1))
	// Criação dos Componentes Visuais
	If !lAuto
		Define MsDialog oDlgB3K Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer:Init( oDlgB3K, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	EndIf

	// Cria a Tela do Browse
	oMark:= FWMarkBrowse():New()
	oMark:SetOwner( oPnl )
	oMark:SetFilterDefault( cFiltro )
	oMark:SetDescription( cDescript )
	If lMark
		oMark:SetFieldMark("B3K_MARK")
	EndIf
	oMark:SetAllMark({|| MsgRun("Selecionando Beneficiários","Movimentações Beneficiários",{||SetMrkAll(oMark,'B3K',"B3K_MARK")})})
	oMark:SetMenuDef( 'PLSMVCBENE' )
	oMark:SetAlias( cAlias )
	oMark:SetProfileID( '1' )
	oMark:ForceQuitButton()
	oMark:DisableDetails(.T.)
	oMark:SetWalkthru(.F.)
	oMark:SetAmbiente(.F.)

	If !lAuto
		oMark:Activate()
		Activate MsDialog oDlgB3K Center
	EndIf

	cMarca := oMark:Mark()

	If cMarca == nil .and. oMark:cMark <> nil
		cMarca := oMark:cMark
	Endif

	If cMarca <> nil
		// Desmarca tudo que foi marcado. Devido ao controle de semaforo do FWMarkBrowse não podemos usar
		// O update direto no banco.
		cSql := "Select R_E_C_N_O_ RECNO FROM "+RetSqlName("B3K")+" WHERE B3K_FILIAL = '"+xFilial("B3K")+"' "
		cSql += "AND B3K_MARK = '"+cMarca+"' "
		cSql += "AND D_E_L_E_T_ = ' '"
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBB3K1",.F.,.T.)
		While !TRBB3K1->( Eof() )
			B3K->( dbGoto(TRBB3K1->RECNO) )

			// Desmarca
			oMark:MarkRec()

			TRBB3K1->( dbSkip() )
		Enddo
		TRBB3K1->( dbCloseArea() )
	Endif

Return oMark
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotEnv	 := {}
	Local aRotVld	 := {}
	Private aRotina	 := {}

	aAdd( aRotEnv, { "Inclusão"     , 'SIBAddMov("' + SIB_INCLUIR + '", B3K->(FieldPos("B3K_MARK")) > 0)' , 0 , 4 , 0 , NIL } )
	aAdd( aRotEnv, { "Cancelamento"	, 'SIBAddMov("' + SIB_CANCELA + '", B3K->(FieldPos("B3K_MARK")) > 0)' , 0 , 4 , 0 , NIL } )
	aAdd( aRotEnv, { "Reativação"	, 'SIBAddMov("' + SIB_REATIVA + '", B3K->(FieldPos("B3K_MARK")) > 0)' , 0 , 4 , 0 , NIL } )

	aAdd( aRotVld, { "Regras gerais SIB"	, 'TypeVldBen("SIB", B3K->(FieldPos("B3K_MARK")) > 0)' , 0 , 9 , 0 , NIL } )
	aAdd( aRotVld, { "Regras SIP"			, 'TypeVldBen("SIP", B3K->(FieldPos("B3K_MARK")) > 0)' 	, 0 , 9 , 0 , NIL } )
	aAdd( aRotVld, { "Benef x CNX"			, 'PLSSIBESP(B3K->(RECNO()), B3K->(FieldPos("B3K_MARK")) > 0)' 		, 0 , 9 , 0 , NIL } )

	aAdd( aRotina, { STR0002	, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { STR0003	, 'VIEWDEF.PLSMVCBENE(.F.)'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { STR0006	, 'VIEWDEF.PLSMVCBENE(.F.)'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { STR0007	, 'VIEWDEF.PLSMVCBENE(.F.)'	, 0 , 8 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Inc. Movto SIB"	, aRotEnv		, 0 , 3 , 0 , NIL } )
	aAdd( aRotina, { "Valid. Selec."	, aRotVld		, 0 , 3 , 0 , NIL } )
	aAdd( aRotina, { "Exibir dif. CNX"	, 'PLSB3KB3W(B3K->(Recno()), .F.)'			, 0 , 3 , 0 , NIL } )
	aAdd( aRotina, { STR0008	, 'PLSCARBEN'			, 0 , 3 , 0 , NIL } ) //Imp. Beneficiarios
	aAdd( aRotina, { "Críticas"	, 'PlCenCriBen()'		, 0 , 9 , 0 , NIL } )

Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B3K

@return oModel	objeto model criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB3K := FWFormStruct( 1, 'B3K')
	Local oStruB3X := FWFormStruct( 1, 'B3X')
	Local oStruB4W := FWFormStruct( 1, 'B4W')
	Local oStruB3F := FWFormStruct( 1, 'B3F')
	Local cExp     := "GetAdvFVal('B3D','B3D_REFERE',xFilial('B3D')+B3F->B3F_CODOPE+B3F->B3F_CDOBRI+B3F->B3F_ANO+B3F->B3F_CDCOMP+'2',1,'',.T.)"
	oStruB3F:AddField(;
		'REF. OBRIG',;
		'REF. OBRIG',;
		'B3F_REFERE',;
		'C',;
		10,;
		0,;
		/*[ bValid ]*/,;
		/*[ bWhen ]*/,;
		/*[ aValues ]*/,;
		/*[ lObrigat ]*/,;
		FwBuildFeature( STRUCT_FEATURE_INIPAD, cExp ),;
		Nil,;
		/*[ lNoUpd ]*/,;
		/*[ lVirtual ]*/,;
		/*[ cValid ]*/;
		)

	oStruB3K:AddField("Hora Mov.",;	// [01] C Titulo do campo
		"Hora Mov.",; // [02] C ToolTip do campo
		"B3K_HORMOV",;// [03] C identificador (ID) do Field
		"C",;			// [04] C Tipo do campo
		8,; 			// [05] N Tamanho do campo
		0,; 			// [06] N Decimal do campo
		Nil,;			// [07] B Code-block de validação do campo
		Nil,; 		// [08] B Code-block de validação When do campo
		Nil,; 		// [09] A Lista de valores permitido do campo
		Nil,; 		// [10] L Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "''" ),; // [11] B Code-block de inicializacao do campo
		Nil,; 		// [12] L Indica se trata de um campo chave
		Nil,; 		// [13] L Indica se o campo pode receber valor em uma operação de update.
		Nil,; 		// [14] L Indica se o campo é virtual
		)

	oModel := MPFormModel():New( STR0001,,,{ |oModel| PLCenGrvBen( oModel ) } )
	oModel:AddFields( 'B3KMASTER', NIL, oStruB3K )
	oModel:AddGrid( 'B3XDETAIL', 'B3KMASTER', oStruB3X )

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'B3XDETAIL',  { 	{ 'B3X_FILIAL', 'xFilial( "B3K" )' },;
		{ 'B3X_BENEF' , 'B3K->(Recno())' };
		}, B3X->( IndexKey( 1 ) ) )

	oModel:GetModel( 'B3KMASTER' ):SetDescription( STR0001 )
	oModel:GetModel( 'B3XDETAIL' ):SetDescription( "Movimentações" )
	oModel:SetDescription( STR0001 )

	oModel:GetModel( 'B3XDETAIL' ):SetOnlyView(.T.)
	oModel:GetModel( 'B3XDETAIL' ):SetOptional(.T.)


	oModel:addGrid('B4WDETAIL','B3KMASTER',oStruB4W)
	oModel:getModel("B4WDETAIL"):SetOptional(.T.)
	oModel:getModel('B4WDETAIL'):SetDescription('Dados das Notas do Aluno')
	oModel:setRelation("B4WDETAIL", ;
		{{"B4W_FILIAL",'xFilial("B4W")'},;
		{"B4W_MATRIC","B3K_MATRIC"  }},;
		B4W->(IndexKey(1)))

	oModel:addGrid('B3FDETAIL','B3XDETAIL',oStruB3F)
	oModel:getModel("B3FDETAIL"):SetOptional(.T.)
	oModel:getModel('B3FDETAIL'):SetDescription('Críticas Movimento')
	oModel:setRelation("B3FDETAIL", ;
		{{"B3F_FILIAL",'xFilial("B3F")'},;
		{"B3F_ORICRI",'"B3X"'},;
		{AllTrim("B3F_IDEORI"),AllTrim("B3K->B3K_MATRIC")}},;
		B3F->(IndexKey(1)))

Return oModel

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B3K

@return oView	objeto view criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCBENE' )
	Local oStruB3K := FWFormStruct( 2, 'B3K' )
	Local oStruB3X := FWFormStruct( 2, 'B3X' )
	Local oStruB4W := FWFormStruct( 2, 'B4W' )
	Local oStruB3F := FWFormStruct( 2, 'B3F' )

	Local oView    := FWFormView():New()

	oStruB3F:AddField( ; // Ord. Tipo Desc.
		'B3F_REFERE' , ; // [01] C Nome do Campo
		'00' , ; // [02] C Ordem
		'Ref. Obrig', ; // [03] C Titulo do campo
		'REFERENCIA OBRIGAÇÃO', ; // [04] C Descrição do campo
		{ 'Referência obrigação movimento crítica' } , ; // [05] A Array com Help
		'C' , ; // [06] C Tipo do campo
		'@!' , ; // [07] C Picture
		NIL , ; // [08] B Bloco de Picture Var
		'' , ; // [09] C Consulta F3
		.T. , ; // [10] L Indica se o campo é evitável
		NIL , ; // [11] C Pasta do campo
		NIL , ; // [12] C Agrupamento do campo
		NIL, ; // [13] A Lista de valores permitido do campo (Combo)
		NIL , ; // [14] N Tamanho Máximo da maior opção do combo
		NIL , ; // [15] C Inicializador de Browse
		.T. , ; // [16] L Indica se o campo é virtual
		NIL ) // [17] C Picture Variável

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B3K' , oStruB3K, 'B3KMASTER' )
	oView:AddGrid( 'VIEW_B3X'  , oStruB3X, 'B3XDETAIL' )
	oView:AddGrid( 'VIEW_B4W'  , oStruB4W, 'B4WDETAIL' )
	oView:AddGrid( 'VIEW_B3F'  , oStruB3F, 'B3FDETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR', 50 )

	oView:CreateHorizontalBox( 'BOXFOLDER', 50)
	oView:CreateFolder( 'FOLDER', 'BOXFOLDER')
	oView:addSheet("FOLDER","ABA1","Movimento SIB")
	oView:addSheet("FOLDER","ABA2","Historico")
	oView:addSheet("FOLDER","ABA3","Criticas Movi.")

	oView:createHorizontalBox("BOX_SUPERIOR",100,,,"FOLDER","ABA1")
	oView:createHorizontalBox("BOX_INFERIOR",100,,,"FOLDER","ABA2")
	oView:createHorizontalBox("BOX_CRITICAS",100,,,"FOLDER","ABA3")

	oView:CreateVerticalBox( 'BOX_MOVI', 100, 'BOX_SUPERIOR',,"FOLDER","ABA1")
	oView:CreateVerticalBox( 'BOX_HIST', 100, 'BOX_INFERIOR',,"FOLDER","ABA2")
	oView:CreateVerticalBox( 'BOX_CRIT', 100, 'BOX_CRITICAS',,"FOLDER","ABA3")

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_B3K', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_B3X', 'BOX_MOVI' )
	oView:SetOwnerView( 'VIEW_B4W', 'BOX_HIST' )
	oView:SetOwnerView( 'VIEW_B3F', 'BOX_CRIT' )

	//Insiro descrições nas views
	oView:EnableTitleView( 'VIEW_B3K', "Beneficiário" )
	oView:EnableTitleView( 'VIEW_B3X', "Movimento SIB" )
	oView:EnableTitleView( 'VIEW_B4W', "Historico do Bloqueio" )
	oView:EnableTitleView( 'VIEW_B3F', "Críticas do Movimento" )

Return oView
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLCGrvBen

Funcao criada para encapsular a gravação e limpar o model depois

@author everton.mateus
@since 21/07/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLCGrvBen( oModel,lSoVld,aCrit,lEnvOpe,dDatAlt, lAuto)

	Local lGravou   := .F.
	Default oModel	:= Nil
	Default lSoVld	:= .F.
	Default aCrit	:= {}
	Default lEnvOpe	:= .T.
	Default dDatAlt	:= dDataBase
	Default lAuto   := .F.

	lGravou := PLCenGrvBen( oModel,lSoVld,aCrit,lEnvOpe,,,,,,, dDatAlt,lAuto)

	oModel:DeActivate()
	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil

Return lGravou
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLGrvBen

Funcao criada para validar e persistir os dados

@author everton.mateus
@since 21/07/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLCenGrvBen( oModel,lSoVld,aCrit,lEnvOpe,lUsaSIB,lUsaSIP,lSIBSincrono,lVldSibSin,lGrvCritic,lAltCancel, dDatAlt, lAuto, aDadosAlt,lDatAlt, aDadEnv,lChange)

	Local lGravou    := .F.
	Local nOpc       := oModel:GetOperation()
	Local nI         := 0
	Local nRecno     := B3K->(Recno())
	Local cCampos    := ""
	Local cRegAns    := oModel:GetValue( "B3KMASTER", 'B3K_CODOPE' )
	Local cMatric    := oModel:GetValue( "B3KMASTER", 'B3K_MATRIC' )
	Local cSitAns    := ""
	Local cSitAnsAnt := ""
	Local cNome      := ""
	Local cMotBlo    := ""
	Local cOpera     := ""
	Local cHoraMov   := ""
	Local cCodCco    := ""
	Local dDatInc    := STOD("")
	Local dDatBlo    := STOD("")
	Local dDatRea    := STOD("")
	Local lBenVld    := .T.
	Local lModelFake := GetClassName(oModel) == 'CENLOADMODEL'
	Local lValid     := .T.
	Local cTimeMov   := ""

	Default aCrit 	     := {}
	Default lSoVld 	     := .F.
	Default lEnvOpe      := .T.
	Default lUsaSIB		 := "2" $ GetNewPar("MV_PLSTIPO","")
	Default lUsaSIP		 := "1" $ GetNewPar("MV_PLSTIPO","")
	Default lSIBSincrono := "2" $ GetNewPar("MV_PLOBRSI","1,2")
	Default lVldSibSin 	 := "2" $ GetNewPar("MV_PLVLDSI","2") .AND. lSIBSincrono
	Default lGrvCritic	 := GetNewPar("MV_PLGRCRI",.T.) //Indica se pode gravar o registro mesmo com críticas.
	Default lAltCancel	 := GetNewPar("MV_PLATCAN",.F.) //Indica se beneficiarios inativos enviarao retificacoes para a ANS
	Default	dDatAlt		 := dDataBase
	Default	lAuto        := .F.
	Default aDadosAlt    := IIf(aDadosAlt == Nil,{},aDadosAlt)
	Default lDatAlt      := lDatAlt
	Default aDadEnv      := {}
	Default lAuto        := .T.
	Default lChange      := .F.

	lGrava := !lSoVld

	//Preencho o model com os dados que vieram da rotina
	If lUsaSib .AND. lEnvOpe

		cSitAns    := oModel:GetValue( "B3KMASTER", "B3K_SITANS" )
		cSitAnsAnt := IIf(cSitAns == 'A','I','A')
		cMatric    := oModel:GetValue( "B3KMASTER", 'B3K_MATRIC' )
		cNome      := oModel:GetValue( "B3KMASTER", 'B3K_NOMBEN' )
		cMotBlo    := oModel:GetValue( "B3KMASTER", 'B3K_MOTBLO' )
		cOpera     := oModel:GetValue( "B3KMASTER", 'B3K_OPESIB' )
		cHoraMov   := Time()
		lBenNaAns  := PlBenNaANS(oModel)
		cDesOpe    := RetOpeSIB(cOpera,lBenNaAns)
		dDatInc    := oModel:GetValue( "B3KMASTER", 'B3K_DATINC' )
		dDatInc    := IIf(Empty(dDatInc),dDataBase,dDatInc)
		dDatBlo    := oModel:GetValue( "B3KMASTER", 'B3K_DATBLO' )
		dDatRea    := oModel:GetValue( "B3KMASTER", 'B3K_DATREA' )
		cCodCco    := oModel:GetValue( "B3KMASTER", 'B3K_CODCCO' )
		cTimeMov   := oModel:GetValue( "B3KMASTER", "B3K_HORMOV" )

		If ValType(cTimeMov) <> "U" .And. !Empty(cTimeMov)
			cHoraMov := cTimeMov
		EndIf

		/*/
			Caso tenha sido chamado
			de outra fonte
			a não ser o CenLoadModel
		/*/
		If !lDatAlt
			RetDadosAlt(oModel,aDadosAlt,@cCampos)
		EndIf

	EndIf

	//Se nao tiver crítica ou Se permite gravar mesmo criticado ou a Validacao e assincrona (Schedulada)
	If lGrava .AND. (lBenVld .OR. lGrvCritic .OR. !lVldSibSin )

		If lModelFake
			lValid	:= oModel:VldData()
			cRotUpd	:= 'oModel:commitData('+cValToChar(lEnvOpe)+')'
		Else
			cRotUpd	:= 'FWFormCommit( oModel )'
		EndIf

		If lValid

			lGravou :=  &(cRotUpd)

			If lGravou

				If nOpc == MODEL_OPERATION_DELETE
					lGravou := CnLmpCriBen(nRecno,"B3K")
					If lGravou
						lGravou := CnLmpHisBlo(cMatric)
						If lGravou
							lGravou := CnLmpMovSib(nRecno)
						EndIf
					EndIf
				Else
					//Atualizo a tabela de historico de operacoes do SIB
					If lUsaSib .AND. lEnvOpe

						If (cDesOpe $ "Incluir,Alterar,Transferir" .AND. !lBenNaAns)

						If ( cSitAns == 'A' .OR. lAltCancel)

							If cDesOpe == "Transferir"
								PlAtuHisOpe(B3K->(Recno()),"",dDatInc,SIB_MUDCONT,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco)
							ElseIf cDesOpe == "Alterar"
								PlAtuHisOpe(B3K->(Recno()),"",dDatInc,SIB_RETIFIC,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"",cSitAns,cCodCco)
							Else
								PlAtuHisOpe(B3K->(Recno()),"",dDatInc,SIB_INCLUIR,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco)
							EndIf


							//Se o beneficiario nao esta na ANS e veio bloqueado, eu gero um bloqueio pra ele
							If GetNewPar("MV_PLINBLS",.F.) .AND. !Empty(dDatBlo) .AND. !Empty(cMotBlo) .AND. cSitAns == "I"

								B3X->(DbSetOrder(3)) //B3X_FILIAL+B3X_BENEF+B3X_CAMPO+B3X_OPERA+B3X_ARQUIV+DTOS(B3X_DATA)
								If  !B3X->(MsSeek(xFilial("B3X")+PADL(AllTrim(Str(B3K->(Recno()))),10)+PADR("",tamSX3("B3X_CAMPO")[1])+SIB_CANCELA))
									//Atualizo o historico de cancelamentos
									PLInHisCanCO(dDatBlo,.T.,cMatric,cMotBlo,cHoraMov,cRegANS,cCodCco)
									PlAtuHisOpe(B3K->(Recno()),"",dDatBlo,SIB_CANCELA,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco)
								EndIf

							EndIf

						EndIf //(B3K->B3K_SITANS == 'A' .OR. lAltCancel)

					ElseIf cDesOpe == "Cancelar"

						If !lBenNaAns
							PlAtuHisOpe(B3K->(Recno()),"",dDatInc,SIB_INCLUIR,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco)
						EndIf
						//Atualizo o historico de cancelamentos
						PLInHisCanCO(dDatBlo,.T.,cMatric,cMotBlo,cHoraMov,cRegANS,cCodCco)
						PlAtuHisOpe(B3K->(Recno()),"",dDatBlo,SIB_CANCELA,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco)
						CnVldSibBn(.T.)

					ElseIf cDesOpe == "Reativar"
						//Atualizo o historico de cancelamentos
						PLInHisCanCO(dDatRea,.F.,cMatric,cMotBlo,cHoraMov,cRegANS,cCodCco)
						PlAtuHisOpe(B3K->(Recno()),"",dDatRea,SIB_REATIVA,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco)

					ElseIf cDesOpe == "Transferir"

						PlAtuHisOpe(B3K->(Recno()),"",dDatInc,SIB_MUDCONT,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHoraMov,"","",cCodCco)

					ElseIf lBenNaAns //As opeacoes abaixo so podem ser incluídas se o beneficiario ja esta na base da ANS.

						If cDesOpe == "Alterar" .AND. (cSitAns == 'A' .OR. lAltCancel)

							lGera := Len(aDadosAlt) == 0 .AND. Len(aDadEnv) > 0

							If lGera
								nLen := Len(aDadEnv)
								For nI := 1 to nLen
									/*/
											Quando enviado pela API movimentações de retificação que não possuem
											diferença entre o registro na central e os dados enviados na API,
											o array aDadEnv é preenchido com os campos enviados na API
											e gerado uma retificação com os campos enviados na requisição PUT
									/*/
									PlAtuHisOpe(B3K->(Recno()),aDadEnv[nI,CAMPO],dDatAlt,SIB_RETIFIC,cMatric,;
										cNome,lVldSibSin,lGrvCritic,cRegAns,,;
										cHoraMov,aDadEnv[nI,VALOR_NOVO],aDadEnv[nI,VALOR_NOVO],cCodCco,lChange)
								Next nI
							Else
								nLen := Len(aDadosAlt)
								For nI := 1 to nLen
									PlAtuHisOpe(B3K->(Recno()),aDadosAlt[nI,CAMPO],dDatAlt,SIB_RETIFIC,cMatric,;
										cNome,lVldSibSin,lGrvCritic,cRegAns,,;
										cHoraMov,aDadosAlt[nI,VALOR_ANTIGO],aDadosAlt[nI,VALOR_NOVO],cCodCco,lChange)
								Next nI
							EndIf

						EndIf //If cDesOpe == "Alterar"

					EndIf //If cDesOpe == "Incluir"

					CnVldSibBn(.T.)

				EndIf //If lUsaSib .AND. lEnvOpe

			EndIf //If nOpc != MODEL_OPERATION_DELETE

		EndIf

	EndIf //VldData

	EndIf //If lGrava .AND. (lBenVld .OR. lGrvCritic .OR. !lVldSibSin )

	If lUsaSib .AND. lEnvOpe
		If cDesOpe == "Alterar" .AND. lBenNaAns
			If !Empty(cCampos)
				lBenVld := PLSIBVLOP(cEmpAnt,cFilAnt,{},DTOS(dDataBase),cRegAns,cEmpAnt,oModel,JOB_VALID,aCrit,,,,cCampos,cDesOpe)
			EndIf
		Else
			lBenVld := PLSIBVLOP(cEmpAnt,cFilAnt,{},DTOS(dDataBase),cRegAns,cEmpAnt,oModel,JOB_VALID,aCrit,IIf(lGrava,B3X->(Recno()),0) ,,,cCampos,cDesOpe)
		EndIf
	EndIf

Return lGravou

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlGrvDesHis

Função que busca no banco a descrição do campo B3X_CAMPO com uma melhor descrição,
incluindo o campo B3X_DESCRI para traduzir o campo.

@author vinicius.nicolau
@since 23/06/2020
/*/
//--------------------------------------------------------------------------------------------------
Function PlGrvDesHis()

Return PlGrvDesCri(ALLTRIM(B3X->B3X_CAMPO))

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlGrvDesCri

Função que busca no banco a descrição do campo B3F_CAMPOS com uma melhor descrição,
incluindo o campo B3F_LEGEN para traduzir o campo.

@author vinicius.nicolau
@since 23/06/2020
/*/
//--------------------------------------------------------------------------------------------------

Function PlGrvDesCri(cCampos)

	Local cRet := ""
	Local cSep := " / "
	Local nCampo := 0
	Local aCampos := {}
	Default cCampos := AllTrim(B3F->B3F_CAMPOS)

	aCampos := StrTokArr(cCampos,".")

	For nCampo := 1 To Len(aCampos)
		Iif(nCampo > 1, cRet += cSep,)
		cRet += X3Desc(aCampos[nCampo])
	Next nCampo

Return cRet

Static Function X3Desc(cCampo)
	Local cDesc := ""
	SX3->( dbSetOrder(2) )
	If SX3->( dbSeek( cCampo ) )
		cDesc := X3Descric()
	EndIf
Return cDesc

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetOpe

Retorna o texto descritivo da operação do SIB

@param cOpera		Código da Operação SIB. 1=Incluir;2=Retificar;3=Mud.Contrat;4=Cancelar;5=Reativar;6=Atualizado ANS

@return cOpe		Descrição da Operação

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function RetOpeSIB(cOpera,lBenNaAns)
	Local cOpe := ""
	Default cOpera := "1"

	Do Case

		Case cOpera == '1' .OR. (cOpera == '2' .AND. !lBenNaAns)

			cOpe := "Incluir"

		Case cOpera == '2'

			cOpe := "Alterar"

		Case cOpera == '3'

			cOpe := "Transferir"

		Case cOpera == '4'

			cOpe := "Cancelar"

		Case cOpera == '5'

			cOpe := "Reativar"

	EndCase

Return cOpe

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PreencheModel

Verifico se o beneficiario ja foi incluído na base da ANS

@param cAlias		Area de trabalho corrente
@param oModel		Objeto do model de beneficiarios
@param aDados		Dados que vieram do ERP
@param aDadosAlt	Campos que serao enviados para a ANS

@author TOTVS PLS Team
@since 11/04/2016
/*/
//--------------------------------------------------------------------------------------------------
Function RetDadosAlt(oModel,aDadosAlt,cCampos)

	Local cNaoEnvia	:=  "B3K_TRADES,B3K_TRAORI,B3K_SITANS,B3K_MATANT,B3K_STASIB,B3K_DATREA,B3K_STAESP,"+;
		"B3K_STATUS,B3K_DATBLO,B3K_MOTBLO,B3K_UF,B3K_CODCCO,B3K_OPESIB,B3K_SUSEP,B3K_CODPRO,"+;
		"B3K_SCPA,B3K_CRINOM,B3K_CRIMAE,B3K_HRINVL,B3K_HRTEVL,B3K_NOMECO"

	Local cCampo	 := ""
	Local cValorAnt	 := ""
	Local cValorNovo := ""
	Local nI 		 := 0
	Local nLen 		 := 0
	Local lVlrMudou	 := 0

	Default oModel    := nil
	Default aDadosAlt := {}
	Default cCampos   := ""

	If oModel <> nil
		aCampos := FWFORMSTRUCT(1,"B3K"):aFields
		nLen := Len(aCampos)
		For nI := 1 to nLen

			cCampo := aCampos[nI,3]

			//So grava valores que foram alterados
			cValorNovo := oModel:GetValue( "B3KMASTER", cCampo)
			cValorAnt := &("B3K->"+cCampo)

			If ValType(cValorAnt) == 'C'
				cValorAnt := AllTrim(cValorAnt)
				cValorNovo := AllTrim(cValorNovo)
			EndIf

			//Para evitar atualizacoes desnecessarias, so atualizo se o valor mudou
			lVlrMudou := cValorNovo != Nil .AND. !(cValorNovo == cValorAnt)
			//Regra para saber se deve atualizar o valor no NIO
			If lVlrMudou .AND. !(cCampo $ cNaoEnvia) //Verifica se deve enviar o campo para a ANS
				aAdd(aDadosAlt, {cCampo,cValorNovo,cValorAnt} )
				cCampos += cCampo + "."
			EndIf

		Next nI

		//Remove o último ponto
		nLen := Len(AllTrim(cCampos))
		If nLen > 0
			cCampos := SubStr(cCampos ,1, nLen-1)
		EndIf

	EndIf //If oModel <> nil

Return len(aDadosAlt) > 0

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExibeCadastro

Funcao criada para exibir as telas de cadastros de beneficiario, produto ou despesa

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlCenCriBen()
	Local cFiltro := " B3F_FILIAL = xFilial( 'B3F' ) .AND. " +;
		" B3F_ORICRI = 'B3K' .AND. " +;
		" B3F_CHVORI = " + AllTrim( Str( B3K->( Recno() )  ) ) + " "
	PLBRWCrit(cFiltro)
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSENVANS

Força o envio de uma operação para a ANS

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSENVANS(cOpe, aMark, lJob, cEmp, cFil)

	Local lRet       := .T.
	Local lCSV
	Local cPath      := "\sib\"
	Local cNamArq    := "log_erros_movimentacoes"
	Local cMatric    := ""
	Local cMotBlo    := ""
	Local dDtRef     := iif(!lJob,dDataBase,date())
	Local dDatInc    := CTOD("")
	Local aBeneError := {}
	Local aBeneOK    := {}
	Local aHeaderCSV := {}
	Local aAreaB3K
	Local nBene
	Local nErrors
	Local oCSV
	Local cCodCco := ""
	Default cOpe  := SIB_INCLUIR
	Default aMark := {}
	Default lJob  := .F.
	Default cEmp  := ''
	Default cFil  := ''

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf

	DbSelectArea("B3K")
	aAreaB3K   := B3K->(GetArea())

	cNome 	:= B3K->B3K_NOMBEN
	dDatInc := B3K->B3K_DATINC
	cMatric := B3K->B3K_MATRIC
	cRegANS := B3K->B3K_CODOPE
	cCodCCO := B3K->B3K_CODCCO

	If Len(aMark)>0
		If !lJob
			ProcRegua(Len(aMark))
		EndIf
		aAreaB3K   := B3K->(GetArea())
		For nBene := 1 to len(aMark)
			If !lJob
				IncProc("Processando registro " + cValToChar(nBene) + " de " + cValToChar(Len(aMark)) + "...")
			EndIf
			lRet := .T.
			B3K->(DBGOTO(aMark[nBene][2]))

			cNome 	:= B3K->B3K_NOMBEN
			dDatInc := B3K->B3K_DATINC
			cMatric := B3K->B3K_MATRIC
			cRegANS := B3K->B3K_CODOPE
			cCodCCO := B3K->B3K_CODCCO

			If cOpe == SIB_INCLUIR
				If !Empty(B3K->B3K_CODCCO)

					aAdd(aBeneError,{B3K->B3K_MATRIC,B3K->B3K_CODCCO,"O Beneficiário já possui CCO, não é possível enviar uma inclusão."})
					lRet := .F.

				Else
					dDtRef := B3K->B3K_DATINC
					B3X->(DbSetOrder(3)) //B3X_FILIAL+B3X_BENEF+B3X_CAMPO+B3X_OPERA+B3X_ARQUIV+DTOS(B3X_DATA)
					If B3X->(MsSeek(xFilial("B3X")+PADL(AllTrim(Str(B3K->(Recno()))),10)+PADR("",tamSX3("B3X_CAMPO")[1])+cOpe ) )
						aAdd(aBeneError,{B3K->B3K_MATRIC,B3K->B3K_CODCCO,"O Beneficiário já possui um movimento de inclusão, não é possível enviar outra inclusão."})
						lRet := .F.
					EndIf
				EndIf

			ElseIf cOpe == SIB_CANCELA

				If Empty(B3K->B3K_DATBLO)
					aAdd(aBeneError,{B3K->B3K_MATRIC,B3K->B3K_CODCCO,"O beneficiário não possui dados de bloqueio. Realize o bloqueio pelo sistema de origem."})
					lRet := .F.
				Else
					DadosBloq("0",@dDtRef,@cMotBlo)
				EndIf

			ElseIf cOpe == SIB_REATIVA
				If Empty(B3K->B3K_DATREA)
					aAdd(aBeneError,{B3K->B3K_MATRIC,B3K->B3K_CODCCO,"O beneficiário não possui dados de desbloqueio. Realize o desbloqueio pelo sistema de origem."})
					lRet := .F.
				Else
					DadosBloq("1",@dDtRef,@cMotBlo)
				EndIf

			EndIf

			//Recupera valores

			If lRet
				cHoraMov := Time()
				sleep(750)

				If cOpe $ SIB_CANCELA + "," + SIB_REATIVA
					//Atualizo o histórico de cancelamentos
					PLInHisCanCO(dDtRef,cOpe==SIB_CANCELA,cMatric,cMotBlo,cHoraMov,cRegANS,cCodCco)
				EndIf

				PlAtuHisOpe(B3K->(Recno()),"",dDtRef,cOpe,cMatric,cNome,,,cRegANS,,cHoraMov,"","",cCodCCO)

				aAdd(aBeneOK,{B3K->B3K_MATRIC,"Movimentação incluída."})
			EndIf

		Next nBene
		RestArea(aAreaB3K)

	Elseif !isblind()
		Alert("Selecione ao menos um beneficiário")
	EndIf

	If len(aBeneOK) > 0 .AND. !isblind()
		msgInfo(cValtoChar(len(aBeneOK)) + ' movimentações incluídas. ', "Aviso")
	EndIf

	If len(aBeneError) > 0
		aHeaderCSV:={"Matrícula","CCO","Erro"}
		oCSV := CenCSV():New(aHeaderCSV)
		For nErrors := 1 to len(aBeneError)
			oCSV:AddLine(aBeneError[nErrors])
		Next nErrors
		If !lJob .AND. !ISBLIND()
			If MsgYesNo(cValtoChar(len(aBeneError)) + ' movimentações não incluídas. Deseja baixar o arquivo de log?')
				cPath := cGetFile("TOTVS","Selecione o diretorio",,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
				lCSV := oCSV:createFile(cPath, cNamArq)
				If lCSV
					msgInfo("Arquivo log gerado com sucesso.")
				EndIf
			EndIf
		Else
			cPath := "\sib\"
			lCSV := oCSV:createFile(cPath, cNamArq)
		EndIf

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DadosBloq

Retorna o RetMatric do beneficiário

@return lRet .T. pendente envio de inclusão

@author everton.mateus
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function DadosBloq(cTipo,dData,cMotBlo)

	Local lRet := .T.

	Default cTipo := "0" //0=Bloqueio;1=Desbloqueio
	Default dData := CTOD("")
	Default cMotBlo := ""

	If (cTipo =='0' .AND. Empty(B3K->B3K_DATBLO) ) .OR.;
			(cTipo =='1' .AND. Empty(B3K->B3K_DATREA) )//Se o beneficiário estiver ativo
		//Busco no histórico os dados do último (des)bloqueio para reenviar

		cSql := " SELECT B4W_DATA ,B4W_MOTBLO "
		cSql += " FROM " + RetSqlName("B4W") + " "
		cSql += " WHERE "
		cSql += "	B4W_FILIAL = '" + xFilial('B4W') + "' "
		cSql += "	AND B4W_MATRIC = '"+ B3K->B3K_MATRIC +"' "
		cSql += "	AND B4W_TIPO = '" + cTipo + "' "
		cSql += "	AND D_E_L_E_T_ = ' ' "
		cSql += " ORDER BY B4W_DATA DESC "

		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBLO",.F.,.T.)

		If TRBBLO->(Eof())
			lRet := .F.
		Else
			dData := TRBBLO->DATA
			cMotBlo := TRBBLO->B4W_MOTBLO
		EndIf

		TRBBLO->(DbCloseArea())

	Else
		If cTipo == "0"
			dData   := B3K->B3K_DATBLO
			cMotBlo := B3K->B3K_MOTBLO
		Else
			dData   := B3K->B3K_DATREA
			cMotBlo := B3K->B3K_MOTBLO
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} PLSVLDHIST
Verifica se o Histórico de bloqueio do beneficiario pode ser alterado
respeitando as regras da Central de Obrigações.
@author Roberto Barbosa
@since 09/2018
/*/
Function PLSVLDHIST(cMatric, aDadosBCA, dDatAnt,nLinha,cHoraLan)
	LOCAL lPermAlt    		:= .F.
	LOCAL cMotBlo 		:= PlMotBloANS(aDadosBCA[nLinha][1][11],aDadosBCA[nLinha][1][7])
	LOCAL cHora   		:=Iif ( Len(aDadosBCA[nLinha][1][18]) == 8, aDadosBCA[nLinha][1][18], Time()  ) // para evitar chave duplicada
	LOCAL dDataAtu		:= aDadosBCA[nLinha][1][6]
	LOCAL cCodInt 		:= Substr(cMatric,1,4)
	LOCAL cRegAns 		:= ""
	LOCAL cTpBloq 		:= aDadosBCA[nLinha][1][5]
	LOCAL nOpera 		:= IIF (cTpBloq == "0", SIB_CANCELA, SIB_REATIVA)
	LOCAL lSIBSincrono  := "2" $ GetNewPar("MV_PLOBRSI","1,2")
	Local lVldSibSin 	:= "2" $ GetNewPar("MV_PLVLDSI","2") .AND. lSIBSincrono
	LOCAL lGrvCritic	:= GetNewPar("MV_PLGRCRI",.T.)
	LOCAL cCodCCO       := ""

	cRegAns := POSICIONE("BA0",1,xFilial("BA0")+(cCodInt),"BA0_SUSEP")

	B3K->(DbSetOrder(1))
	B3K->(MsSeek(xFilial("B3K")+cRegAns+PADR(cMatric,tamSX3("B3K_MATRIC")[1])))

	cMatric := B3K->B3K_MATRIC
	cCodCCO := B3K->B3K_CODCCO
	//Verifico se a data alterada existe na B4W e se ela encontra-se ativa na B4W.
	B4W->(DbSetOrder(1))

	If B4W->(MsSeek(xFilial("B4W")+PADR(cMatric,tamSX3("B4W_MATRIC")[1])+DTOS(dDatAnt)+cTpBloq))
		If B4W->B4W_STATUS == '1'
			lPermAlt := .T.
			B3X->(DbSetOrder(9))
			If B3X->(MsSeek(xFilial("B3X")+padL(B3K->(Recno()), 10)+DTOS(dDatAnt)))
				If B3X->B3X_STATUS $('1,2,3,5') //Se não foi enviado o movimento, permito a alteração e atualizo as tabelas
					PlAtuHisOpe(B3K->(Recno()),"",dDataAtu,nOpera,cMatric,B3K->B3K_NOMBEN,lVldSibSin,lGrvCritic,cRegAns,,cHora,"","",cCodCCO)
					PLInHisCanCO(dDataAtu,.F.,cMatric, cMotBlo,cHora,cRegANS,cCodCco)

				ElseIf B3X->B3X_STATUS $('4,6') .AND. PLASTHIST(cMatric,nLinha,dDatAnt,cHoraLan) //Verifico se já foi enviado para a ANS e se é o ultimo movimento.
					PlAtuHisOpe(B3K->(Recno()),"",dDatBlo,SIB_RETIFIC,cMatric,cNome,lVldSibSin,lGrvCritic,cRegAns,,cHora,cSitAnsAnt,cSitAns,cCodCCO)
					lPermAlt := .T.
				Else
					lPermAlt := .F.
				EndIF

			Else
				PlAtuHisOpe(B3K->(Recno()),"",dDataAtu,nOpera,cMatric,B3K->B3K_NOMBEN,lVldSibSin,lGrvCritic,cRegAns,,cHora,"","",cCodCCO)
			EndIF

		ElseIf B4W->B4W_STATUS == '0' //Se o Movimento existir e estiver inativo, devo reativa-lo na B4W. reativo movimento na B3X
			PLInHisCanCO(dDataAtu,.T.,cMatric, cMotBlo,cHora,cRegANS,cCodCco)
			PlAtuHisOpe(B3K->(Recno()),"",dDataAtu,nOpera,cMatric,B3K->B3K_NOMBEN,lVldSibSin,lGrvCritic,cRegAns,,cHora,"","",cCodCCO)
			lPermAlt := .T.
		EndIf
	Else
		PlAtuHisOpe(B3K->(Recno()),"",dDataAtu,nOpera,cMatric,B3K->B3K_NOMBEN,lVldSibSin,lGrvCritic,cRegAns,,cHora,"","",cCodCCO)
		PLInHisCanCO(dDataAtu,.T.,cMatric, cMotBlo,cHoraLan,cRegANS,cCodCco)
		lPermAlt := .T.	//Permito a alteração no Histórico
	EndIf

Return lPermAlt

/*/{Protheus.doc} PLASTHIST
Verifico se o movimento que está sendo alterado na Central é o ultimo enviado para a ANS
é o ultimo registro.
@author Roberto Barbosa
@since 09/2018
/*/
Function PLASTHIST(cMatric,nLinha,dDatAnt,cHoraLan)
	Local cSql := ""
	LOCAL lUltMov := .F.
	DEFAULT dDatAnt := date()
	DEFAULT cHoraLan := time()

	cSql := " SELECT MAX(B3X_DATOPE), R_E_C_N_O_ FROM " + RetSqlName("B3X")
	cSql += " WHERE "
	cSql += " B3X_FILIAL = '" + xFilial('B3X') + "' "
	cSql += " AND B3X_IDEORI ='" + cMatric + "' "
	cSql += " AND B3X_STATUS IN  ('"+ENV_ANS+"','"+ACAT_ANS+"')"
	cSql += " AND B3X_OPERA in ('4','5') "
	cSql += " GROUP BY R_E_C_N_O_ "
	cSql += " ORDER by MAX(B3X_DATOPE) DESC"
	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBLAST",.F.,.T.)

	aAreaB3X := B3X->(GetArea())

	B3X->(DbGoTo(TRBLAST->R_E_C_N_O_))	//Pego o primeiro R_E_C_N_O_ da ordenação e posiciono na B3X
	If B3X->B3X_DATA == dDatAnt .AND. B3X->B3X_HORA == cHoraLan
		lUltMov := .T.
	EndIf

	RestArea(aAreaB3X)

Return lUltMov

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CnLmpHisBlo

Limpa o historico de bloqueio de um beneficiários

@return lRetorno	.F. registros nao apagados ou .T. registros apagados

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CnLmpHisBlo(cMatric)

	Local cSql			:= ""	//Query a ser executada
	Local lRet			:= .T.

	cSql := " DELETE FROM " + RetSqlName('B4W') + " "
	cSql += " WHERE "
	cSql += "	B4W_FILIAL = '" + xFilial('B4W') + "' "
	cSql += "	AND B4W_MATRIC = '" + cMatric + "' "

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
		nRet := TCSQLEXEC("COMMIT")
	Endif

	lRet := nRet >= 0

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CnVldSibBn

Executa a rotina de validação de regras gerais do SIB para o beneficiario selecionada

@author everton.mateus
@since 19/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CnVldSibBn(lAuto, aMark, lJob, cEmp, cFil)
	Local nBene
	local aAreaB3K

	Default	lAuto := .F.
	Default aMark := {}
	Default lJob  := .F.
	Default cEmp  := ''
	Default cFil  := ''

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf

	aAreaB3K := B3K->(GetArea())

	If len(aMark) > 0
		If !lJob
			ProcRegua(Len(aMark))
		EndIf
		For nBene := 1 to len(aMark)
			If !lJob
				IncProc("Processando registro " + cValToChar(nBene) + " de " + cValToChar(Len(aMark)) + "...")
			EndIf
			B3K->(DBGOTO(aMark[nBene][2]))
			PLSIBVLBN(cEmpAnt,cFilAnt,nil,DTOS(dDataBase),B3K->B3K_CODOPE,cEmpAnt,nil,"Incluir","1",nil,B3K->(RECNO()))
		Next nBene
		RestArea(aAreaB3K)
		if !lAuto .AND. !lJob
			msgInfo("Validação concluída!")
		EndIf

	Else
		if !lAuto .AND. !lJob
			msgAlert("Selecione ao menos um beneficiário para validar","Atenção")
		EndIf
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CnVldSipBn

Executa a rotina de validação de regras gerais do SIP para o beneficiario selecionada

@author everton.mateus
@since 19/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CnVldSipBn(lAuto, aMark, lJob, cEmp, cFil)

	Local nBene
	local aAreaB3K

	Default	lAuto := .F.
	Default aMark := {}
	Default lJob  := .F.
	Default cEmp  := ''
	Default cFil  := ''

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf

	aAreaB3K := B3K->(GetArea())

	If len(aMark) > 0
		If !lJob
			ProcRegua(Len(aMark))
		EndIf
		For nBene := 1 to len(aMark)
			If !lJob
				IncProc("Processando registro " + cValToChar(nBene) + " de " + cValToChar(Len(aMark)) + "...")
			EndIf
			B3K->(DBGOTO(aMark[nBene][2]))
			PLSIPVLBN(cEmpAnt,cFilAnt,nil,DTOS(dDataBase),B3K->B3K_CODOPE,cEmpAnt,B3K->(RECNO()),"1",.F.)
		Next nBene
		RestArea(aAreaB3K)
		if !lAuto .AND. !lJob
			msgInfo("Validação concluída!")
		EndIf

	Else
		if !lAuto .AND. !lJob
			msgAlert("Selecione ao menos um beneficiário para validar","Atenção")
		EndIf
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} checkMark

Verifica os registros selecionados no MarkBrowse da B3K

@author p.drivas
@since 22/10/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function checkMark(lMark)
	local aMark := {}
	local aAreaB3K := B3K->(GetArea())
	Default lMark := .T.
	If lMark
		B3K->( dbGoTop() )
		While !B3K->( EOF() )
			If oMark:IsMark(oMark:Mark())
				aAdd(aMark,{B3K->B3K_MATRIC,B3K->(Recno())})
			EndIf
			B3K->( dbSkip() )
		End
		RestArea(aAreaB3K)
	Else
		aAdd(aMark,{B3K->B3K_MATRIC,B3K->(Recno())})
	EndIf
Return aMark

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBAddMov

Verifica se a inclusao de movimento SIB sera via JOB

@author p.drivas
@since 26/10/2020
/*/
//--------------------------------------------------------------------------------------------------

function SIBAddMov(cOpe, lMark)
	local lJob  := .F.
	Local aMark := checkMark(lMark)
	if msgyesno("Deseja processar o(s) movimentos(s) em segundo plano?")
		msgAlert("Caso sejam encontrados erros em uma ou mais movimentação, será gerado um arquivo de nome log_erros_movimentacoes na pasta \sib do servidor. ")
		lJob := .T.
		startjob("PLSENVANS",getenvserver(),.F.,cOpe, aMark, lJob, cEmpAnt, cFilAnt)
	else
		Processa({|| PLSENVANS(cOpe, aMark)}, "Incluindo...")
	Endif
return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TypeVldBen

Verifica se a validação do beneficiário será via JOB

@author p.drivas
@since 27/10/2020
/*/
//--------------------------------------------------------------------------------------------------

function TypeVldBen(cType, lMark)
	local lJob  := .F.
	Local aMark := checkMark(lMark)
	if msgyesno("Deseja validar o(s) beneficiário(s) em segundo plano?")
		lJob := .T.
		If cType == 'SIB'
			startjob("CnVldSibBn",getenvserver(),.F.,.F., aMark, lJob, cEmpAnt, cFilAnt)
		ElseIf cType == 'SIP'
			startjob("CnVldSipBn",getenvserver(),.F.,, aMark, lJob, cEmpAnt, cFilAnt)
		EndIf
	else
		If cType == 'SIB'
			Processa({|| CnVldSibBn(.F., aMark)}, "Validando...")
		ElseIf cType == 'SIP'
			Processa({|| CnVldSipBn(, aMark)}, "Validando...")
		EndIf
	Endif
return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetMrkAll
Função para execução do MarkAll da MarkBrowse

/*/
//-------------------------------------------------------------------

Static Function SetMrkAll(oObjTmp As Object,cAliasMrk As Character,cFlag As Character)

	cMarca := oObjTmp:cMark

	(cAliasMrk)->(dbGotop())

	While (cAliasMrk)->(!Eof())
		RecLock(cAliasMrk,.F.)
		If Empty((cAliasMrk)->&(cFlag))
			(cAliasMrk)->&(cFlag)	:= cMarca
		Else
			(cAliasMrk)->&(cFlag)	:= "  "
		Endif
		MsUnlock()
		(cAliasMrk)->(dbSkip())
	EndDo

	(cAliasMrk)->(dbGotop())

	If oObjTmp <> nil
		oObjTmp:Refresh()
	Endif

Return
