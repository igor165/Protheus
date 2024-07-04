#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'GPEA924.CH'

Static lRAZAtu	:= ("RAZ_CATEG" $ FWX2Unico("RAZ"))

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁFuncao    	Ё GPEA924    Ё Autor Ё Glaucia M.			  	                Ё Data Ё 18/09/2013 Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescricao 	Ё Multiplos Vinculos                                                                Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   	Ё GPEA924()                                                    	  		            Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       	Ё ATENCAO: EXCLUSIVO GPEA090 e GPEM260, rotina nao pode ser colocada no MENU.       Ё╠╠
╠╠цдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.               			            Ё╠╠
╠╠цдддддддддддддбддддддддддбддддддддддддддддбдддддддддбддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁAnalista     Ё Data     Ё FNC/Requisito  Ё Chamado Ё  Motivo da Alteracao                        Ё╠╠
╠╠цдддддддддддддеддддддддддеддддддддддддддддедддддддддеддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRaquel Hager Ё11/08/2014Ё00000026544/2014ЁTQHIID   ЁInclusao de fonte na Versao 12.				Ё╠╠
╠╠ЁEduardo.     Ё24/05/2017ЁDRHESOCP-293/273|Ajustes e Chamada de Tela de MultiVinc e inclusao de   Ё╠╠
╠╠Ё			    Ё          Ё                |  novos campos										    Ё╠╠
╠╠юдддддддддддддаддддддддддаддддддддддддддддадддддддддаддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function GPEA924()

Local aCoors  		:= FWGetDialogSize( oMainWnd )
Local cIdBrowse
Local cIdGrid
Local oPanelUp
Local oTela
Local oPanelDown
Local oRelacRAW
Local aIndexSRA		:= {}
Local cFiltraRH		:= ""

Private oDlgPrinc

Private oBrowseUp
Private oBrowseDwn

Define MsDialog oDlgPrinc Title OemToAnsi(STR0001) From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] OF oMainWnd Pixel  //"Multiplos Vinculos"

// Cria o conteiner onde serЦo colocados os paineis
oTela     := FWFormContainer():New( oDlgPrinc )
cIdBrowse := oTela:CreateHorizontalBox( 60 )
cIdGrid   := oTela:CreateHorizontalBox( 35 )

oTela:Activate( oDlgPrinc, .F. )

//Cria os paineis onde serao colocados os browses
oPanelUp  	:= oTela:GeTPanel( cIdBrowse )
oPanelDown  := oTela:GeTPanel( cIdGrid )

// FWmBrowse Superior: Funcionarios
oBrowseUp:= FWmBrowse():New()
oBrowseUp:SetOwner( oPanelUp )                  // Aqui se associa o browse ao componente de tela
oBrowseUp:SetDescription( OemToAnsi(STR0023) )	//"FuncionАrios"
oBrowseUp:SetAlias( 'SRA' )
oBrowseUp:SetMenuDef( 'GPEXYZ' )              // Define de onde virao os botoes deste browse
oBrowseUp:DisableDetails()
oBrowseUp:SetProfileID( '1' )
oBrowseUp:SetCacheView (.F.)
oBrowseUp:ExecuteFilter(.T.)

GpLegMVC(@oBrowseUp)

cFiltraRh := ChkRh("GPEA924","SRA","1")

oBrowseUp:SetFilterDefault(cFiltraRh)

oBrowseUp:Activate()

// FWmBrowse Inferior: Cabecalhos de Multiplos Vinculos
oBrowseDwn:= FWMBrowse():New()
oBrowseDwn:SetOwner( oPanelDown )
oBrowseDwn:SetDescription( OemToAnsi(STR0001) )	//"Multiplos Vinculos"
oBrowseDwn:DisableDetails()
oBrowseDwn:SetAlias( 'RAW' )
oBrowseDwn:SetChgAll(.T.)
oBrowseDwn:SetProfileID( '2' )
oBrowseDwn:ForceQuitButton()					//sempre que existem dois menudefs na tela, deve-se indicar em qual browse vai ficar o botao 'Sair'
oBrowseDwn:SetCacheView (.F.)
oBrowseDwn:ExecuteFilter(.T.)

// Relacionamento entre os Paineis
oRelacRAW:= FWBrwRelation():New()
oRelacRAW:AddRelation( oBrowseUp  , oBrowseDwn , { { 'RAW_FILIAL', 'RA_FILIAL' }, { 'RAW_MAT' , 'RA_MAT'  } } )
oRelacRAW:Activate()

oBrowseDwn:Activate()

oBrowseUp:Refresh()
oBrowseDwn:Refresh()

Activate MsDialog oDlgPrinc Center

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Glaucia M.       Ё Data Ё19/09/2013Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCriacao do Menu do Browse.                                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA924                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0002)  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0003)  Action 'VIEWDEF.GPEA924'	OPERATION 2 ACCESS 0 //"Visualizar"

If ALLTRIM(FUNNAME()) $ '|GPEA090|GPEM260|GPEA580'
	ADD OPTION aRotina Title OemToAnsi(STR0024)  Action 'VIEWDEF.GPEA924'	OPERATION 3 ACCESS 0 //"Incluir"
EndIf

ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'VIEWDEF.GPEA924'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA924'	OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ModelDef		ЁAutorЁ  Glaucia M.       Ё Data Ё19/09/2013Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Modelagem da gravacao.                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA924                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁModel em uso.												Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ModelDef()

Local aArea			:= GetArea('SRA')
Local oModel		:= Nil
Local oStruSRA 		:= FWFormStruct(1, 'SRA')
Local oStruRAW		:= FWFormStruct(1, 'RAW')
Local oStruRAZ		:= FWFormStruct(1, 'RAZ')
Local cSRAFil		:= {||SRA->RA_FILIAL}
Local cSRAMat		:= {||SRA->RA_MAT}
Local cSRANome		:= {||SRA->RA_NOME}
Local cSRAAdm		:= {||SRA->RA_ADMISSA}
Local cSRYTipo		:= {|| SRY->RY_TIPO}
Local aPerAtual		:= {}
Local cRotTipo		:= ""

oModel     	:= MPFormModel():New('GPEA924',,{ |oModel| fGP924LOK('VALOR') })
oStruSRA	:= FWFormStruct(1,"SRA",{|cCampo|  AllTrim(cCampo) $ "|RA_MAT|RA_NOME|RA_ADMISSA|"})

If (IsInCallStack("GPEA090") .OR. IsInCallStack("GPEM260") .Or. IsInCallStack("GPEA580") .Or. IsInCallStack("GPEA924") .Or. IsInCallStack("GPEA550"))
	oModel:AddFields( 'RAWMASTER', , oStruRAW)
	oModel:AddFields( 'SRATITLE','RAWMASTER', oStruSRA)
	oModel:AddGrid	( 'RAZDETAIL', 'RAWMASTER', oStruRAZ,,)

	If IsInCallStack("GPEA550")
		cProcesso	:= SRA->RA_PROCES

		If Type("cRot") != "U"
			cRoteiro := cRot
			cPeriodo := AnoMes(dIniPg)

			SRY->(DbSetOrder(1))
			SRY->(dbSeek(xFilial("SRY",cFil)+cRoteiro))

			cSRYTipo	:= {||SRY->RY_TIPO}
		Else
			cSRYTipo := {||cTpFol}
		EndIf


	EndIf

	IF TYPE("cRoteiro") <> "U"
		cRotTipo := fGetTipoRot(cRoteiro)

		IF !EMPTY(cRotTipo)
			cSRYTipo := {|| IIF(cRotTipo == "6", "2", "1")}
		ENDIF
	ENDIF

	IF !IsInCallStack("GPEA924")
		oStruRAW:SetProperty('RAW_ROTEIR',	MODEL_FIELD_WHEN, {|| .F.})
		oStruRAW:SetProperty('RAW_PROCES',	MODEL_FIELD_WHEN, {|| .F.})
		oStruRAW:SetProperty('RAW_SEMANA',	MODEL_FIELD_WHEN, {|| .F.})
	ENDIF

	oStruSRA:SetProperty('*',MODEL_FIELD_VIRTUAL, .T.)
	oStruSRA:SetProperty('RA_MAT'		,MODEL_FIELD_INIT, cSRAMat)
	oStruSRA:SetProperty('RA_NOME'		,MODEL_FIELD_INIT, cSRANome)
	oStruSRA:SetProperty('RA_ADMISSA'	,MODEL_FIELD_INIT, cSRAAdm)

	oStruRAW:SetProperty('RAW_FILIAL'	,MODEL_FIELD_INIT, cSRAFil)
	oStruRAW:SetProperty('RAW_MAT'		,MODEL_FIELD_INIT, cSRAMat)
	oStruRAW:SetProperty('RAW_PROCES'	,MODEL_FIELD_INIT, {||cProcesso})
	oStruRAW:SetProperty('RAW_FOLMES'	,MODEL_FIELD_INIT, {||cPeriodo})
	oStruRAW:SetProperty('RAW_TPFOL'	,MODEL_FIELD_INIT, cSRYTipo)
	oStruRAW:SetProperty('RAW_SEMANA'	,MODEL_FIELD_INIT, {||cSemana})	
	oStruRAW:SetProperty('RAW_ROTEIR'	,MODEL_FIELD_INIT, {||cRoteiro})
	oStruRAZ:SetProperty('RAZ_FILIAL'	,MODEL_FIELD_INIT, cSRAFil)
	oStruRAZ:SetProperty('RAZ_MAT'		,MODEL_FIELD_INIT, cSRAMat)

	oStruRAZ:AddTrigger('RAZ_TPINS', 'RAZ_INSCR', {|oFW| FWInitTrg(oFW,'RAZ_TPINS','RAZ_INSCR'),xRetorno:=(FWMVCEvalTrigger(oFW,'M->RAZ_TPINS=="2"','L','RAZ_TPINS','003')),FwCloseTrg(oFW,'RAZ_TPINS','RAZ_INSCR',xRetorno) }, {|oFW| FWInitTrg(oFW,'RAZ_TPINS','RAZ_INSCR'),xRetorno:=(FWMVCEvalTrigger( oFW,'""','C','RAZ_TPINS','003')),FwCloseTrg(oFW,'RAZ_TPINS','RAZ_INSCR',xRetorno) })
Else
	oModel:AddFields( 'SRATITLE', , oStruSRA)
	oModel:AddFields( 'RAWMASTER','SRATITLE', oStruRAW)
	oModel:AddGrid	( 'RAZDETAIL', 'RAWMASTER', oStruRAZ,,{ |oGrid| fGP924LOK('VALOR') })

	oModel:SetRelation('RAWMASTER', {{'RAW_FILIAL', 'RA_FILIAL'}, {'RAW_MAT', 'RA_MAT'} }, RAW->(IndexKey(1)))
EndIf

oModel:GetModel( 'RAWMASTER' ):SetDescription(OemToAnsi(STR0001)) //Multiplos Vinculos

oModel:SetRelation('RAZDETAIL', {{'RAZ_FILIAL', 'RAW_FILIAL'}, {'RAZ_MAT', 'RAW_MAT'}, {'RAZ_FOLMES', 'RAW_FOLMES'},{'RAZ_TPFOL','RAW_TPFOL'} }, RAZ->(IndexKey(1)))
If !lRAZAtu
	oModel:GetModel( "RAZDETAIL" ):SetUniqueLine( { 'RAZ_FILIAL', 'RAZ_MAT','RAZ_FOLMES', 'RAZ_TPFOL', 'RAZ_INSCR' } )
Else
	oModel:GetModel( "RAZDETAIL" ):SetUniqueLine( { 'RAZ_FILIAL', 'RAZ_MAT','RAZ_FOLMES', 'RAZ_TPFOL', 'RAZ_TPINS', 'RAZ_INSCR', 'RAZ_CATEG' } )
EndIf

oModel:GetModel( "SRATITLE" ):SetOnlyView(.T.)
oModel:GetModel( "SRATITLE" ):SetOnlyQuery(.T.)
oModel:AddRules( 'RAZDETAIL','RAZ_TPINS','RAWMASTER', 'RAW_TPREC' , 1 )
oModel:AddRules( 'RAZDETAIL','RAZ_INSCR' , 'RAZDETAIL', 'RAZ_TPINS', 1 )
oModel:AddRules( 'RAZDETAIL','RAZ_VALOR', 'RAZDETAIL',  'RAZ_INSCR', 1 )

If ALLTRIM(FUNNAME()) # '|GPEA090|GPEM260|GPEA580|'
	oModel:SetActivate( { |oModel| fGP924RAW( oModel )} )
EndIf

RestArea(aArea)
Return( oModel )
/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef		ЁAutorЁ  Glaucia M.       Ё Data Ё19/09/2013Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Interface com o Usuario                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA924                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁView em uso.    											Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Static Function ViewDef()
Local oView		:= NIL
Local oModel   := FWLoadModel('GPEA924')
Local oStruSRA	:= FWFormStruct(2, 'SRA')
Local oStruRAW := FWFormStruct(2, 'RAW')
Local oStruRAZ := FWFormStruct(2, 'RAZ')

oStruSRA	:= FWFormStruct(2,"SRA",{|cCampo|  AllTrim(cCampo) $ "|RA_MAT|RA_NOME|RA_ADMISSA|"})

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_SRA",oStruSRA,"SRATITLE")
oView:AddField("VIEW_RAW", oStruRAW, 'RAWMASTER')
oView:AddGrid ("VIEW_RAZ", oStruRAZ, 'RAZDETAIL')

oStruSRA:RemoveField("RA_FILIAL")
oStruSRA:SetNoFolder()

oStruRAW:RemoveField( 'RAW_MAT' )
oStruRAW:RemoveField( 'RAW_TPFOL' )

oStruRAZ:RemoveField( 'RAZ_MAT' )
oStruRAZ:RemoveField( 'RAZ_FOLMES' )
oStruRAZ:RemoveField( 'RAZ_TPFOL' )

oView:SetOnlyView('VIEW_SRA')
oView:CreateHorizontalBox( 'SUPERIOR'	, 15 )
oView:CreateHorizontalBox( 'MEIO'		, 35 )
oView:CreateHorizontalBox( 'INFERIOR'	, 50 )

oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RAW', 'MEIO')
oView:SetOwnerView('VIEW_RAZ', 'INFERIOR')

oView:EnableTitleView('VIEW_SRA', OemToAnsi(STR0007)) // "Funcionario"
oView:EnableTitleView('VIEW_RAW', OemToAnsi(STR0001)) // "Multiplo Vinculos"
oView:EnableTitleView('VIEW_RAZ', OemToAnsi(STR0006)) // "Detalhes Multiplos Vinculos"

oView:SetViewCanActivate({|oView| fVldView(oView)})

Return oView

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fGP924RAW()	ЁAutorЁ  Glaucia M.       Ё Data Ё19/09/2013Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁInicializa campos RAW na alteracao.                         Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA924                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁNenhum														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁoModel = ModelDef em uso na rotina.	     					Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fGP924RAW( oModel )

	Local aArea      := GetArea()
	Local aAreaRAW   := RAW->( GetArea() )
	Local aCampos    := {}
	Local nI         := 0
	Local nOperation := oModel:GetOperation()
	Local oModelRAW
	Local xInit      := ""

	If nOperation == MODEL_OPERATION_UPDATE
		oModelRAW := oModel:GetModel( 'RAWMASTER')

		RAW->( dbSetOrder( 1 ) )
		If !RAW->( dbSeek( xFilial( 'RAW' ) + oModel:GetValue( 'SRATITLE', 'RA_MAT' )+ oModel:GetValue( 'RAWMASTER', 'RAW_FOLMES' )+ oModel:GetValue( 'RAWMASTER', 'RAW_TPFOL' )  ) )
			aCampos := oModelRAW:GetStruct():GetFields()

			For nI :=  1 to Len( aCampos )
				If aCampos[nI][MODEL_FIELD_INIT] <> NIL
					xInit := oModelRAW:InitValue( aCampos[nI][MODEL_FIELD_IDFIELD] )
					If !Empty( xInit )
						oModelRAW:LoadValue( aCampos[nI][MODEL_FIELD_IDFIELD], xInit )
					EndIf
				EndIf
			Next
		EndIf
	EndIf

	RestArea( aAreaRAW )
	RestArea( aArea )

Return NIL


/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fGP924INSC()	ЁAutorЁ  Glaucia M.       Ё Data Ё20/09/2013Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁComplemento da validaГЦo do campo RAZ_INSCR                 Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁfGP924INSC()                 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA924 - Campo RAZ_INSCR                                   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁBoolean														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁNenhum 								    					Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fGP924INSC()

	Local lRet		:=	.T.
	Local cTpIns	:= FwFldGet("RAZ_TPINS")
	Local aEmpr		:= FWLoadSM0(.T.,.F.)//.T.,F.)	// seleГЦo das principais informaГoes do SIGAMAT.EMP
	Local cInscr	:= Alltrim(FwFldGet("RAZ_INSCR"))
	Local lGatilho	:= IsInCallStack("RunTrigger")

	If lGatilho
		Return .T.
	ElseIf cTpIns =="1"
		If (cInscr =='00000000000000') .OR. (EMPTY(cInscr)) .OR. (LEN(cInscr) < 14) .OR. !(CNPJ(cInscr))
			Return .F.
		ElseIf Len(aEmpr) > 0 .And. ( aScan( aEmpr, { |x| x[1] == FWGrpCompany() .And. x[2] == SRA->RA_FILIAL .And. SubStr(x[18], 1, 8) == SubStr(cInscr, 1, 8) } ) > 0)
			lRet := .F.
			Help( ,, 'HELP',, OemToAnsi(STR0010), 1, 0 ) //"A raiz do CNPJ informado deve ser diferente da raiz do CNPJ da filial do funcionАrio, pois apenas deve ser informado para empresa diferente."
		EndIf
	ElseIf cTpIns =="2"
		If Empty(cInscr) .Or. cInscr == "00000000000" .Or. Len(cInscr) > 11 .Or. !ChkCPF(cInscr)
			lRet := .F.
		ElseIf cInscr == SRA->RA_CIC
			lRet := .F.
			Help( ,, 'HELP',,OemToAnsi(STR0025) , 1, 0 ) //"O CPF deve ser diferente do CPF do trabalhador"
		ElseIf Len(aEmpr) > 0 .And. ( aScan( aEmpr, { |x| x[1] == FWGrpCompany() .And. x[2] == SRA->RA_FILIAL .And. Len(AllTrim(x[18])) == 11 .And. AllTrim(x[18]) == cInscr } ) > 0)
			lRet := .F.
			Help( ,, 'HELP',,OemToAnsi(STR0026) , 1, 0 ) //"O CPF deve ser diferente do CPF do empregador"
		EndIf
	EndIf

Return lRet

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fGP924VAL()	ЁAutorЁ  Glaucia M.       Ё Data Ё23/09/2013Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁComplemento da validaГЦo do campo RAZ_INSCR                 Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁfGP924VAL()                 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA924 - Campo RAZ_VALOR                                   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁBoolean														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁNenhum 								    					Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function fGP924VAL(cOrigem)

	Local lRet		:=	.T.
	Local oModel	:= FwModelActive()
	Local oGridRAZ 	:= oModel:GetModel( 'RAZDETAIL' )
	Local cTpRecolh	:= FwFldGet('RAW_TPREC')
	Local nValor	:= FwFldGet('RAZ_VALOR')

	If !oGridRAZ:IsDeleted()
		If (cTpRecolh $'3' .AND. nValor < 0)
			lRet:= .F.
		ElseIf (cTpRecolh $ '1|2') .AND. !(nValor > 0) .AND. (fGP924LOK(cOrigem ))
			lRet:= .F.
			Help( ,, 'HELP',, OemToAnsi(STR0012), 1, 0 ) //"O 'Valor Remun' deverA ser diferente de ZERO, pois o campo 'Tp Recolhim.' e diferente de '3'."
		EndIf
	EndIf

Return lRet

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fGP924LOK()	ЁAutorЁ  Glaucia M.       Ё Data Ё23/09/2013Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁLinhaok oGrid RAZ                                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁfGP924LOK()                 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA924 - Linha OK                                          Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁBoolean														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁNenhum 								    					Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fGP924LOK(cOrigem )

Local oModel	:= FwModelActive()
Local oGridRAZ 	:= oModel:GetModel( 'RAZDETAIL' )
Local oGridRAW 	:= oModel:GetModel( 'RAWMASTER' )
Local lRet		:= .T.
Local cTpRec	:= FwFldGet("RAW_TPREC")
Local nI		:= 0
Local aSaveLine	:= FWSaveRows()
Local nLinhaRAZ	:= oGridRAZ:GetQtdLine()
Local cMsg		:= " "+OemToAnsi(STR0012) //"O 'Valor Remun' deverA ser diferente de ZERO, pois o campo 'Tp Recolhim.' e diferente de '3'."
Local nLinhaDel	:= 0
Local nQtdMeses	:= 0
Local dMesAnoPer:= ""
Local aArea			:= GetArea()

DEFAULT cOrigem:='VALOR'

If EMPTY(cTpRec)
	Help( ,, 'HELP',,OemToAnsi(STR0013) , 1, 0 ) //"E necessArio preencher primeiramente o campo 'Tp Recolhim.', para validaCAo adequada do campo 'Valor Remun'."
	Return .F.
ElseIf nLinhaRaz > 0
	For nI := 1 To oGridRAZ:GetQtdLine()
		oGridRAZ:GoLine( nI )
		If !oGridRAZ:IsDeleted()
			If lRet .AND. (Empty(oGridRAZ:GetValue('RAZ_TPINS')) .OR. Empty(oGridRAZ:GetValue('RAZ_INSCR')))
				lRet := .F.
				Help( ,, 'HELP',, OemToAnsi(STR0017)+" "+CVALTOCHAR(nI)+OemtoAnsi(STR0022), 1, 0 )	//"Na linha " ### "O campo 'Tp Inscr.' ou 'Nr InscriГЦo' estЦo vazios, e sЦo campo obrigatСrios."
			ElseIf lRet .AND. (((cTpRec # '3') .AND. oGridRAZ:GetValue( 'RAZ_VALOR' )== 0))
				lRet := .F.
				If cOrigem == 'TPREC'
					cMsg:= cMsg + CRLF+CRLF+ OemToAnsi(STR0014)+","+CRLF+OemToAnsi(STR0015)+", "+CRLF+OemToAnsi(STR0016) //"Alternativa: NЦo altere o campo 'Tp Recolhim'." ##" e na linha indicada, altere o 'Valor Remun' (diferente ZERO) ##"e depois altere o campo 'Tp Recolhim.'. "
				EndIf
				Help( ,, 'HELP',, OemToAnsi(STR0017)+CVALTOCHAR(nI)+cMsg, 1, 0 )	//"Na linha "
			EndIf
		Else
			nLinhaDel:=nLinhaDel+1
		EndIf

	Next nI

EndIf

FWRestRows( aSaveLine )

If IsInCallStack("GPEA550ger")	// Multiplas gravaГУes na RAZ/RAW se vier da rotina GPEA550 (LanГamentos Fixos)
	aArea			:= GetArea()
	If Type("dIniPg") != "U"
		dMesAnoPer := AnoMes(dIniPg)
		nQtdMeses := DateDiffMonth(dIniPg,dFimPg)
	Else
		dMesAnoPer := aPerAtual[1][1]
		nLinhaPos := aScan(aCols,{|x| Alltrim(x[nPosPd]) == GdFieldGet("RG1_PD")})
		nQtdMeses := DateDiffMonth(aCols[nLinhaPos][nPosIniPg],aCols[nLinhaPos][nPosData])
	EndIf

	For nI := 1 To nQtdMeses
		dMesAnoPer := SomaMesAno(dMesAnoPer)

		RAW->(dbSetOrder(1))
		If RAW->( dbSeek( xFilial("RAW",cFil) + cMat+ dMesAnoPer+ oGridRAW:GetValue('RAW_TPFOL')  ) )
			RecLock("RAW", .F.)
		Else
			RecLock("RAW", .T.)
		Endif	

		RAW->RAW_FILIAL	:= xFilial("RAW",cFil)
		RAW->RAW_MAT	:= cMat
		RAW->RAW_FOLMES	:= dMesAnoPer
		RAW->RAW_TPFOL	:= oGridRAW:GetValue('RAW_TPFOL')
		RAW->RAW_TPREC	:= oGridRAW:GetValue('RAW_TPREC')
		RAW->RAW_PROCES	:= oGridRAW:GetValue('RAW_PROCES')
		RAW->RAW_SEMANA	:= oGridRAW:GetValue('RAW_SEMANA')
		RAW->RAW_ROTEIR	:= oGridRAW:GetValue('RAW_ROTEIR')

		RAQ->(MsUnLock()) // Confirma e finaliza a operaГЦo

		RAZ->(dbSetOrder(1))
		If RAZ->( dbSeek( xFilial("RAZ",cFil) + cMat+ dMesAnoPer+ oGridRAZ:GetValue('RAZ_TPFOL')  ) )
			RecLock("RAZ", .F.)
		Else
			RecLock("RAZ", .T.)
		Endif	
		RAZ->RAZ_FILIAL	:= xFilial("RAZ",cFil)
		RAZ->RAZ_MAT	:= cMat
		RAZ->RAZ_FOLMES	:= dMesAnoPer
		RAZ->RAZ_TPFOL	:= oGridRAZ:GetValue('RAZ_TPFOL')
		RAZ->RAZ_TPINS	:= oGridRAZ:GetValue('RAZ_TPINS')
		RAZ->RAZ_INSCR	:= oGridRAZ:GetValue('RAZ_INSCR')
		RAZ->RAZ_VALOR	:= oGridRAZ:GetValue('RAZ_VALOR')
		RAZ->RAZ_CATEG	:= oGridRAZ:GetValue('RAZ_CATEG')

		RAZ->(MsUnLock()) // Confirma e finaliza a operaГЦo

	Next
	RestArea( aArea )
EndIf

Return lRet

/*/{Protheus.doc} fVldView
Valida abertura da view  
@type      	Static Function
@author Allyson Mesashi
@since 12/03/2020
@version	1.0
@return		lEdit,		logic
/*/
Static Function fVldView(oView)

Local oModel 	:= oView:GetModel()

oModel:Activate()

If !lRAZAtu
	fAlertRAZ()
EndIf

oModel:DeActivate()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fAlertRAZ
FunГЦo para exibiГЦo de alerta e link para o TDN com orientaГЦo sobre atualizaГЦo da tabela RAZ
@author Allyson Mesashi
@since 12/03/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fAlertRAZ()
Local oButton1
Local oButton2
Local oCheckBo1
Local lCheckBo1 	:= .F.
Local oGroup1
Local oPanel1
Local oSay1
Local cSession		:= "AlertaRAZ"
Local lChkMsg 		:= fwGetProfString(cSession,"MSG_JOBRAZ_" + cUserName,'',.T.) == ""
Static oDlg

If lChkMsg
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0027) FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL //"AtualizaГЦo de dicionАrio"

		@ 000, 000 MSPANEL oPanel1 SIZE 300, 150 OF oDlg COLORS 0, 16777215 RAISED
		@ 005, 012 GROUP oGroup1 TO 055, 237 PROMPT OemToAnsi(STR0028) OF oPanel1 COLOR 0, 16777215 PIXEL //"AtenГЦo"
		@ 013, 017 SAY oSay1 PROMPT OemToAnsi(STR0029) SIZE 215, 035 OF oPanel1 COLORS 0, 16777215 PIXEL //'Foi liberada uma atualizaГЦo de dicionАrio para a tabela RAZ no pacote de expediГЦo contМnua do RH (a partir do dia 27/03/2020) e tambИm no pacote de atualizaГЦo do eSocial (a partir de 04/2020) que permite a inclusЦo de mais de um vМnculo para a mesma inscriГЦo, mas de categorias diferentes. Clique em "Abrir Link" para consultar a documentaГЦo no TDN'
		@ 080, 012 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT OEMToAnsi(STR0030) SIZE 067, 008 OF oPanel1 COLORS 0, 16777215 PIXEL //"NЦo exibir novamente"
		@ 070, 160 BUTTON oButton1 PROMPT STR0031 SIZE 037, 012 OF oPanel1 PIXEL//"Abrir Link"
		@ 070, 200 BUTTON oButton2 PROMPT "OK" SIZE 037, 012 OF oPanel1 PIXEL

		oButton1:bLClicked := {|| ShellExecute("open","https://tdn.totvs.com/x/-c5eI","","",1) }
		oButton2:bLClicked := {|| oDlg:End() }

	ACTIVATE MSDIALOG oDlg CENTERED

	If lCheckBo1
		fwWriteProfString(cSession, "MSG_JOBRAZ_" + cUserName, 'CHECKED', .T.)
	EndIf	
EndIf

Return
