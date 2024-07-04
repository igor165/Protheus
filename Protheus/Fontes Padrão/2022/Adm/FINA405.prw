#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINA405.CH"

Static __lBlind	:= IsBlind()

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA405
Cadastro Repasse de IRPJ - tabela FOM

@author Leonardo Castro
@since 12/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Function FINA405()
Local oBrowse As Object

Static nTamRSoc As Numeric
Static nTamCGC As Numeric

nTamRSoc	:= TamSx3("A2_NOME")[1]
nTamCGC		:= TamSx3("A2_CGC")[1]

DBSelectArea("SA2")
DBSelectArea("FOM")
DBSelectArea("FON")
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("FOM")
oBrowse:SetDescription( OemToAnsi(STR0006) ) // "Cadastro repasse de IRPJ"
oBrowse:AddLegend( "F405Legend(1)"				,"GRAY"		, OemToAnsi(STR0008) )	// "Contém itens enviados para DIRF para DIRF"
oBrowse:AddLegend( "F405Legend(2)"				,"GREEN"	, OemToAnsi(STR0009) )	// "Aguardando envio para DIRF"
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef() As Array
Local aRotina As Array

aRotina := {}

ADD OPTION aRotina TITLE OemToAnsi(STR0001) ACTION "VIEWDEF.FINA405" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE OemToAnsi(STR0002) ACTION "VIEWDEF.FINA405" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE OemToAnsi(STR0003) ACTION "F405Altera"	 	 OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE OemToAnsi(STR0004) ACTION "F405Exclui"	 	 OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE OemToAnsi(STR0005) ACTION "VIEWDEF.FINA405" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef() As Object
// Cria a estrutura a ser usada no Modelo de Dados
Local oModel	As Object
Local oStruFOM	As Object
Local oStruFON	As Object
Local aRelacFON As Array
Local bFormPos, bLinePre, bLinePos	As CodeBlock

oStruFOM	:= FStructFOM(1)
oStruFON	:= FStructFON(1)

aRelacFON	:= {}
bFormPos	:= {||F405FrmPos()}
bLinePre	:= {||F405LinPre()}
bLinePos	:= {||F405LinPos()}

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("FINA405", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulario de edicao por campo
oModel:AddFields( "FOMMASTER", /*cOwner*/, oStruFOM, /*bPreValidacao*/, bFormPos/*bPosValidacao*/,  /*bLoad*/ )

// Adiciona ao modelo uma estrutura de grid de edicao por registros
oModel:AddGrid( "FONDETAIL", "FOMMASTER", oStruFON, bLinePre, bLinePos, /*bPre*/, /*bPos*/, /*bLoad*/)

//Cria Relacionamentos FON -> FOM
aAdd(aRelacFON	,{ "FON_FILIAL"	,"xFilial('FON')"} )
aAdd(aRelacFON	,{ "FON_IDDOC"	,"FOM_IDDOC" 	} )
oModel:SetRelation("FONDETAIL"	, aRelacFON	, FON->( IndexKey(1) ))

oModel:SetPrimaryKey( { "FOM_FILIAL", "FOM_FORNEC", "FOM_LOJA", "FOM_CODRET", "FOM_ANO" } )

// Adiciona UniqueLine por Item na Grid
oModel:GetModel( "FONDETAIL" ):SetUniqueLine( { "FON_MES" } )
oModel:GetModel( "FONDETAIL" ):SetDelAllLine( .F. )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( OemToAnsi(STR0007) ) // "Repasse de IRPJ"

oModel:GetModel( "FOMMASTER" ):SetDescription( OemToAnsi(STR0007) )

oModel:SetActivate()

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef() As Object

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel	As Object
Local oView		As Object
Local oFOM		As Object
Local oFON		As Object

oModel		:= FWLoadModel( "FINA405" )
oFOM		:= FStructFOM(2)
oFON		:= FStructFON(2)

// Cria o objeto de View
oView		:= FWFormView():New()

// Define qual o Modelo de dados sera utilizado
oView:SetModel( oModel )

// Cria box visual para separa‡?o dos elementos em tela.
oView:createHorizontalBox( "FORM", 25, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
oView:createHorizontalBox( "GRID", 75, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( "VIEWFOM", oFOM, "FOMMASTER" )

//Adiciona no nosso View um controle do tipo FormGrid(antiga getDados)
oView:AddGrid( "VIEWFON", oFON, "FONDETAIL" )

// Relaciona um formul rio/Grid ou uma pasta com um box visual.
oView:SetOwnerView( "VIEWFOM", "FORM" )
oView:SetOwnerView( "VIEWFON", "GRID" )

// Define campos que terao Auto Incremento
oView:AddIncrementField( "VIEWFON", "FON_ITEM" )

oView:EnableTitleView( "VIEWFON", OemToAnsi(STR0010) )// "Dados Complementares"

// Adiciona a descricao sobre objetivo da View
oView:SetDescription( OemToAnsi(STR0006) )

Return oView

//-------------------------------------------------------------------
/*/ {Protheus.doc} FStructFOM
Funcao de preparacao da estrutura da tabela FOM para Model/View.

@aparam	nTipo, indica se ‚ 1 = model ou 2 = view

@Return	oFOM Estrutura de campos da tabela FOM

@author	Leonardo Castro
@since	12/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function FStructFOM(nTipo As Numeric) As Object
Local oFOM		As Object
Local cOrdRaz, cOrdCNPJ, cOrdemLJ	As Character
Local aStruFOM	As Array

aStruFOM := FOM->(DbStruct())
cOrdemLJ := StrZero( aScan(aStruFOM,{ |x| Alltrim(x[1]) == "FOM_LOJA" }), 2 )
cOrdRaz	 := Soma1(cOrdemLJ)
cOrdCNPJ := Soma1(cOrdRaz)

DEFAULT nTipo := 1

If nTipo == 1 // Model

	oFOM 		:= FWFormStruct( 1, "FOM", /*bAvalCampo*/,/*lViewUsado*/ )

	oFOM:AddTrigger("FOM_FORNEC", "FOM_RAZAO"	, { || .T.}, { || FGetForn("FOM_RAZAO"	,1) })
	oFOM:AddTrigger("FOM_FORNEC", "FOM_CNPJ"	, { || .T.}, { || FGetForn("FOM_CNPJ"	,1) })
	oFOM:AddTrigger("FOM_LOJA"	, "FOM_RAZAO"	, { || .T.}, { || FGetForn("FOM_RAZAO"	,1) })
	oFOM:AddTrigger("FOM_LOJA"	, "FOM_CNPJ"	, { || .T.}, { || FGetForn("FOM_CNPJ"	,1) })

	// Chave Identificadora do Documento
	oFOM:SetProperty( "FOM_IDDOC"	, MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "FWUUIDV4()" ) )

	// Campos virtuais
	oFOM:SetProperty( "FOM_RAZAO"	, MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "FGetForn('FOM_RAZAO',2)" ) )
	oFOM:SetProperty( "FOM_CNPJ"	, MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "FGetForn('FOM_CNPJ',2)" ) )

	// Validacao de campo
	oFOM:SetProperty( "FOM_FORNEC"	, MODEL_FIELD_VALID, { || FValidFor(1) })
	oFOM:SetProperty( "FOM_LOJA"	, MODEL_FIELD_VALID, { || FValidFor(2) })

Else // View

	oFOM 		:= FWFormStruct( 2, "FOM", /*bAvalCampo*/,/*lViewUsado*/ )

	// Bloqueia edicao
	oFOM:SetProperty("FOM_RAZAO"	, MVC_VIEW_CANCHANGE, .F.)
	oFOM:SetProperty("FOM_CNPJ"		, MVC_VIEW_CANCHANGE, .F.)

	// Remove campos
	oFOM:RemoveField("FOM_IDDOC")
	oFOM:RemoveField("FOM_FILORI")

EndIf

Return oFOM

//-------------------------------------------------------------------
/*/ {Protheus.doc} FStructFON
Funcao de preparacao da estrutura da tabela FON para Model/View.

@aparam	nTipo, indica se ‚ 1 = model ou 2 = view

@Return	oFON Estrutura de campos da tabela FON

@author	Leonardo Castro
@since	12/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function FStructFON(nTipo As Numeric) As Object
Local oFON As Object
Local aMonth As Array

DEFAULT nTipo := 1

aMonth	 := { OemToAnsi(STR0015), OemToAnsi(STR0016), OemToAnsi(STR0017), OemToAnsi(STR0018), OemToAnsi(STR0019), OemToAnsi(STR0020),;
			  OemToAnsi(STR0021), OemToAnsi(STR0022), OemToAnsi(STR0023), OemToAnsi(STR0024), OemToAnsi(STR0025), OemToAnsi(STR0026) } // Meses

If nTipo == 1 // Model

	oFON 		:= FWFormStruct( 1, "FON", /*bAvalCampo*/,/*lViewUsado*/ )

	// Campo obrigatorio
	oFON:SetProperty("FON_IDDOC"	, MODEL_FIELD_OBRIGAT, .F.)
	oFON:SetProperty("FON_ITEM"		, MODEL_FIELD_OBRIGAT, .F.)
	oFON:SetProperty("FON_MES"		, MODEL_FIELD_OBRIGAT, .T.)

Else // View

	oFON		:= FWFormStruct( 2, "FON", /*bAvalCampo*/,/*lViewUsado*/ )

	// Bloqueia edicao
	oFON:SetProperty("FON_ITEM"		, MVC_VIEW_CANCHANGE, .F.)
	oFON:SetProperty("FON_DIRF"		, MVC_VIEW_CANCHANGE, .F.)

	// ComboBox
	oFON:SetProperty("FON_MES"		, MVC_VIEW_COMBOBOX,  aMonth )
	oFON:SetProperty("FON_DIRF"		, MVC_VIEW_COMBOBOX, { STR0033, STR0034 } )

	// Remove campos
	oFON:RemoveField("FON_FILIAL")
	oFON:RemoveField("FON_IDDOC")

EndIf

Return oFON

//-------------------------------------------------------------------
/*/{Protheus.doc} FGetForn()
Funcao para preenchimento dos campos virtuais do Fornecedor

@param cField - Campo a ser preenchido (Razao Social ou CNPJ)
@param nProperty - 1 = Gatilho / 2 = Inicializador padrao

@author Leonardo Castro
@since	12/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Function FGetForn(cField As Character, nProperty As Numeric) As Character

Local oModel, oFOM As Object
Local cFornece, Loja, cRet As Character
Local nOper		As Numeric

DEFAULT cField := " "
DEFAULT nProperty	:= 1

oModel		:= FWModelActive()
nOper		:= oModel:GetOperation()
cRet		:= If( nProperty == 1 .And. !Empty(cField), oModel:GetValue("FOMMASTER",cField) , " " )

If nProperty == 1 .Or. nOper != MODEL_OPERATION_INSERT

	cFornece	:= oModel:GetValue("FOMMASTER","FOM_FORNEC")
	cLoja		:= oModel:GetValue("FOMMASTER","FOM_LOJA")

	Do Case
		Case cField == "FOM_RAZAO"
			cRet	:= Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_NOME")
		Case cField == "FOM_CNPJ"
			cRet	:= Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_CGC")
	EndCase

Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FValidFor()
Funcao de validacao do Fornecedor e Loja digitado

@param nField campo de validacao - 1 = Fornecedor / 2 = Loja

@author Leonardo Castro
@since	12/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Function FValidFor(nField As Numeric) As Logical

Local oModel, oFOM As Object
Local cFornece, Loja As Character
Local lRet	As Logical

DEFAULT nField := 0

lRet		:= .T.
oModel		:= FWModelActive()

cFornece	:= oModel:GetValue("FOMMASTER","FOM_FORNEC")
cLoja		:= Alltrim( oModel:GetValue("FOMMASTER","FOM_LOJA") )

Do Case
	Case nField == 1
		lRet	:= ExistCpo( "SA2", cFornece+cLoja ) .And. Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_TIPO") == "J"
	Case nField == 2 .And. !Empty(cFornece)
		lRet	:= ExistCpo( "SA2", cFornece+cLoja ) .And. Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_TIPO") == "J"
EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F405Exclui()
Define operacao de exclusao

@author Leonardo Castro
@since	12/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F405Exclui()

Local oModel	As Object
Local nOpc		As Numeric
Local aEnableButtons	As Array
Local lDirf		As Logical

aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

nOpc		:= MODEL_OPERATION_DELETE

oModel		:= FwLoadModel("FINA405")
oModel:SetOperation(nOpc)
oModel:Activate()

lDirf		:= F405VldEnv(oModel) // Dados enviados para DIRF

If !lDirf
	FWExecView( OemToAnsi(STR0030),"FINA405", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel ) //'Excluir'
Else
	// Dados ja enviados para DIRF
	HELP(" ",1,"FA405ENV",,OemToAnsi(STR0029),1,0)//Documento de repasse ja enviado a DIRF, por gentileza selecione um documento aguardando envio pada DIRF
Endif
oModel:Deactivate()
oModel:Destroy()
oModel:= Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F405Altera()
Define operacao de exclusao

@author Leonardo Castro
@since	12/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F405Altera()

Local oModel	As Object
Local nOpc		As Numeric
Local aEnableButtons	As Array

aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

nOpc		:= MODEL_OPERATION_UPDATE

oModel		:= FwLoadModel("FINA405")
oModel:SetOperation(nOpc)
oModel:Activate()

FWExecView( OemToAnsi(STR0031), "FINA405", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel ) //'Alterar'

oModel:Deactivate()
oModel:Destroy()
oModel:= Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F405VldEnv()
Funcao de validacao dos dados enviados para DIRF

@author Leonardo Castro
@since	12/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F405VldEnv( oModel As Object ) As Logical

Local lRet		As Logical
Local oFON		As Object

DEFAULT oModel	:= FWLoadModel("FINA405")

lRet := .F.

oFON := oModel:GetModel("FONDETAIL")
lRet := oFON:SeekLine( { {"FON_DIRF", "1" } } )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F405Legend()
Define legenda para a rotina

@param nItem - Define numero da legenda 1 ou 2.

@author Leonardo Castro
@since	12/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F405Legend( nItem As Numeric ) As Logical

Local lRet	As Logical
Local aArea, aAreaFOM, aAreaFON		As Array

DEFAULT nItem		:= 1

aArea		:= GetArea()
DBSelectArea("FOM")
aAreaFOM	:= FOM->(GetArea())
DBSelectArea("FON")
aAreaFON	:= FON->(GetArea())
FON->( DbSetOrder(1) )
FON->( DbSeek( xFilial("FON",FOM->FOM_FILIAL) + FOM->FOM_IDDOC ) )

lRet := .F.

While FON->( !Eof() ) .And. FON->FON_IDDOC == FOM->FOM_IDDOC

	If FON->FON_DIRF == "1"
		lRet	:= .T.
		Exit
	EndIf

	FON->( DbSkip() )

EndDo

Do Case
	Case nItem == 1
		lRet := lRet
	Case nItem == 2
		lRet := !lRet
EndCase

RestArea(aAreaFON)
RestArea(aAreaFOM)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F405FrmPos()
Pos Validacao de preenchimento do FORM

@author Leonardo Castro
@since	12/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F405FrmPos() As Logical

Local lRet As Logical
Local oModel, oFOM As Object
Local nOper		As Numeric

oModel		:= FWModelActive()
nOper		:= oModel:GetOperation()
oFOM 		:= oModel:GetModel("FOMMASTER")
lRet		:= .T.

If nOper == MODEL_OPERATION_INSERT

	DBSelectArea("FOM")
	FOM->( DbSetOrder(1) )

	If FOM->( DbSeek( xFilial("FOM")+oFOM:GetValue("FOM_FORNEC")+oFOM:GetValue("FOM_LOJA")+oFOM:GetValue("FOM_ANO")+oFOM:GetValue("FOM_CODRET") ) )
		// Repasse ja cadastrado
		HELP(" ",1,"FA405DUP",,OemToAnsi(STR0032),1,0)
		lRet	:= .F.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F405LinPre()
Pre Validacao de preenchimento das linhas da GRID

@author Leonardo Castro
@since	12/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F405LinPre() As Logical

Local lRet As Logical
Local oModel, oFON As Object

oModel		:= FWModelActive()
oFON 		:= oModel:GetModel("FONDETAIL")
lRet		:= .T.

If oFON:GetValue("FON_DIRF") == "1"
	HELP(" ",1,"FA405ENV",,OemToAnsi(STR0029),1,0)//Documento de repasse ja enviado a DIRF, por gentileza selecione um documento aguardando envio pada DIRF
	lRet	:= .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F405LinPos()
Pos Validacao de preenchimento das linhas da GRID

@author Pâmela Bernardo
@since	25/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F405LinPos() As Logical

Local lRet As Logical
Local oModel, oFON As Object

oModel		:= FWModelActive()
oFON 		:= oModel:GetModel("FONDETAIL")
lRet		:= .T.

If oFON:GetValue("FON_IMPREC") > oFON:GetValue("FON_BASE")
	HELP(" ",1,"FA405VAL",,OemToAnsi(STR0037),1,0)//"Valor do retido não pode ser maior que a base"
	lRet	:= .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa405DIRF
Função para gravar os dados na DIRF

@param cPrograma, caracter, Informe se a chamada é do FINA401 ou FINA403
@param cFilCen , caracter , Filial centralizadora da DIRF
@param dDataIni, data, Data inicial do filtro
@param dDataFim, data, Data final do filtro
@param aSelFil, array, Array com as filiais para seleção

@author Karen Honda
@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------

Function Fa405DIRF(cPrograma As Character, aLog As Array, lGerLog As Logical, cFilCen As Character, dDataIni As Date, dDataFim As Date, aSelFil As Array) As Array

Local nAnoIni 	As Numeric
Local nAnoFim 	As Numeric
Local cMesIni 	As Character
Local cMesFim 	As Character
Local cQuery 		As Character
Local cAliasQry 	As Character
Local nI 			As Numeric
Local cFilRng		As Character
Local aTamVlBase	As Array
Local aTamVlImp	As Array
Local aTamCGC		As Array
Local aArea		As Array
Local lForExt 	As Logical
Local lTemNIF		As Logical
Local cNIFEX 		As Character
Local cRaMat		As Character
Local nTamTpRen	As Numeric
Local cCGCFor		As Character
Local lFa405Cmp	As Logical
Local cForLoja	As Character
Local cFilOri		As Character
Local aRecnoFon	As Array
Local nNaoTrib	As Numeric

aArea 	 := GetArea()
nAnoIni := Year(dDataIni)
nAnoFim := Year(dDataFim)
cMesIni := StrZero(Month(dDataIni),02)
cMesFim := StrZero(Month(dDataFim),02)

nTamTpRen	:= TamSx3( "R4_TIPOREN" )[1]
aTamVlBase	:= TamSx3("FON_BASE")
aTamVlImp	:= TamSx3("FON_IMPREC")
aTamCGC	:= TamSx3("RL_CGCFONT")
lFa405Cmp	:= ExistBlock("FA405CMP") // Complemento de gravacao do SR4
aRecnoFon	:= {}

DbSelectArea("FOM")
DbSelectArea("FON")

cFilRng := GetRngFil( aSelFil, "FOM", .T.,  )

If !Empty(cFilCen)
	SM0->(MsSeek(cEmpAnt+cFilCen))
Endif

DbSelectArea("SA2")
SA2->(DbSetOrder(1))

DbSelectArea("SRL")
SRL->(DBSetOrder(2)) // RL_FILIAL, RL_CGCFONT, RL_CODRET, RL_TIPOFJ, RL_CPFCGC, RL_NIFEX, R_E_C_N_O_, D_E_L_E_T_

DbSelectArea("SR4")
SR4->(DBSetOrder(1)) //R4_FILIAL, R4_MAT, R4_CPFCGC, R4_CODRET, R4_ANO, R4_MES, R4_TIPOREN, R4_PAIS, R4_NIFEX, R_E_C_N_O_, D_E_L_E_T_

For nI := nAnoIni to nAnoFim

	If nAnoIni <> nAnoFim
		If nI == nAnoIni
			cMesIni := StrZero(Month(dDataIni),02)
			cMesFim := "12"
		ElseIf nI == nAnoFim
			cMesIni := "01"
			cMesFim := StrZero(Month(dDataFim),02)
		Else
			cMesIni := "01"
			cMesFim := "12"
		EndIf
	EndIf

	cForLoja := ""
	cFilOri  := ""

	cQuery := "SELECT FOM.FOM_FILIAL,FOM.FOM_FORNEC, FOM.FOM_LOJA,FOM.FOM_CODRET,FOM.FOM_ANO, FOM.FOM_FILORI, "
	cQuery += "FON.FON_MES,FON.FON_RNDBRT,FON.FON_BASE,FON.FON_IMPREC,FON.FON_ITEM,FON.FON_IDDOC, FON.R_E_C_N_O_ RECNO "
	cQuery += "FROM " + RetSqlName("FOM") + " FOM "
	cQuery += " JOIN " + RetSqlName("FON") + " FON "
	cQuery += "ON (FOM.FOM_FILIAL = FON.FON_FILIAL AND FOM.FOM_IDDOC = FON.FON_IDDOC AND FON.D_E_L_E_T_ = ' ' ) "
	cQuery += "WHERE "
	cQuery += " FOM.FOM_FILIAL " +  cFilRng
	cQuery += " AND FOM.FOM_ANO = '"+ StrZero(nI,4) + "' "
	cQuery += " AND FON.FON_MES BETWEEN '" + cMesIni + "' AND '" + cMesFim + "' "
	cQuery += " AND FON.FON_DIRF = '2' "
	cQuery += " AND FOM.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY FOM.FOM_FORNEC,FOM.FOM_LOJA, FOM.FOM_ANO, FOM.FOM_CODRET, FON.FON_MES"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	TCSetField(cAliasQry, "FON_BASE", "N",aTamVlBase[1],aTamVlBase[2])
	TCSetField(cAliasQry, "FON_IMPREC", "N",aTamVlImp[1],aTamVlImp[2])

	(cAliasQry)->(dbGoTop())

	While (cAliasQry)->(!Eof())

		If cForLoja != (cAliasQry)->(FOM_FORNEC+FOM_LOJA) .or. cFilOri != (cAliasQry)->FOM_FILORI
			If SA2->( !DbSeek(xFilial("SA2",(cAliasQry)->FOM_FILORI)+(cAliasQry)->FOM_FORNEC+(cAliasQry)->FOM_LOJA ) )
				(cAliasQry)->(dbSkip())
				Loop
			EndIf
			cForLoja := (cAliasQry)->(FOM_FORNEC+FOM_LOJA)
			cFilOri  := (cAliasQry)->FOM_FILORI
		EndIf

		lForExt := .F.
		lTemNIF := .F.
		cNIFEX  := ""
		//tratamento para fornecedor exterior sem NIF
		If !EMPTY(SA2->A2_PAISEX) .AND. IsCodResExt((cAliasQry)->FOM_CODRET)
			lForExt := .T.
			If Empty(SA2->A2_NIFEX)
				cNIFEX := SA2->A2_COD +  SA2->A2_LOJA
				lTemNIF := .F.
			Else
				cNIFEX := SA2->A2_NIFEX
				lTemNIF := .T.
			EndIf
		EndIf

		cCGCFor := Padr(SA2->A2_CGC,aTamCGC[1])

		// Pesquisa cabecalho da DIRF
		If SRL->(!DbSeek(xFilial("SRL",cFilCen)+Padr(SM0->M0_CGC,aTamCGC[1])+ (cAliasQry)->FOM_CODRET +;
				"2"+ cCgcFor+ cNIFEX ))

			Reclock("SRL", .T.)

			cRaMat := GetSxENum("SRL", "RL_MAT")
			If Val(SRA->RA_MAT) < 900000 .And. Val(cRaMat) < 900000
				cRaMat := "900000"
			Else
				ConfirmSx8()
			EndIf

			SRL->RL_FILIAL  := xFilial("SRL",cFilCen)
			SRL->RL_MAT     := cRaMat
			SRL->RL_CODRET  := (cAliasQry)->FOM_CODRET
			SRL->RL_TIPOFJ  := "2"
			SRL->RL_CPFCGC  := SA2->A2_CGC
			SRL->RL_BENEFIC := Substr(SA2->A2_NOME,1,60)
			SRL->RL_ENDBENE := Alltrim(SA2->A2_END) + Alltrim(SA2->A2_NR_END)
			SRL->RL_UFBENEF := SA2->A2_EST
			SRL->RL_COMPLEM := SA2->A2_BAIRRO
			SRL->RL_CGCFONT := SM0->M0_CGC
			SRL->RL_NOMFONT := SM0->M0_NOMECOM
			SRL->RL_ORIGEM  := "2"
			SRL->RL_CGCEX   := SA2->A2_CGCEX
			SRL->RL_PAIS    := SA2->A2_PAISEX
			SRL->RL_NIFEX   := cNIFEX

			//Fornecedor exterior
			If  IsCodResExt((cAliasQry)->FOM_CODRET)
				SRL->RL_NEMPR := SA2->A2_NEMPR
				SRL->RL_TPCON := SA2->A2_TPCON
				SRL->RL_DTINI := SA2->A2_DTINIR
				SRL->RL_DTFIM := SA2->A2_DTFIMR
				SRL->RL_LOGEX := SA2->A2_LOGEX
				SRL->RL_NUMEX := SA2->A2_NUMEX
				SRL->RL_COMPL := SA2->A2_COMPLR
				SRL->RL_BAIEX := SA2->A2_BAIEX
				SRL->RL_POSEX := SA2->A2_POSEX
				SRL->RL_CIDEX := SA2->A2_CIDEX
				SRL->RL_ESTEX := SA2->A2_ESTEX
				SRL->RL_TELEX := SA2->A2_TELRE
				SRL->RL_BREEX := SA2->A2_BREEX
				SRL->RL_TPREX := SA2->A2_TPREX
				SRL->RL_TRBEX := SA2->A2_TRBEX
			EndIf
			SRL->(MsUnlock())
		Endif


		//Gera o rendimento tributável
		// R4_FILIAL+R4_MAT+R4_CPFCGC+R4_CODRET+R4_ANO+R4_MES+R4_TIPOREN+R4_PAIS+R4_NIFEX
		cChaveSr4 := xFilial("SR4",cFilCen)+SRL->RL_MAT+ cCGCFor + (cAliasQry)->FOM_CODRET + (cAliasQry)->FOM_ANO + (cAliasQry)->FON_MES

		If SR4->( !DbSeek( cChaveSr4 + padr("A",nTamTpRen) + SRL->RL_PAIS + SRL->RL_NIFEX  ))

			Reclock("SR4", .T.)

			SR4->R4_FILIAL  := xFilial("SR4",cFilCen)
			SR4->R4_MAT     := SRL->RL_MAT
			SR4->R4_CPFCGC  := cCGCFor
			SR4->R4_MES     := (cAliasQry)->FON_MES
			SR4->R4_TIPOREN := "A"
			SR4->R4_CODRET  := (cAliasQry)->FOM_CODRET
			SR4->R4_ANO     := (cAliasQry)->FOM_ANO
			SR4->R4_ORIGEM  := "2"

			If  !Empty(SRL->RL_PAIS)
				SR4->R4_PAIS  := SRL->RL_PAIS
				SR4->R4_NIFEX := SRL->RL_NIFEX
				SR4->R4_DTPGT := CTOD("01/"+SR4->R4_MES+"/"+SR4->R4_ANO)
				SR4->R4_ISNIF :=  Iif(lTemNIF,"1","2")
			EndIf

			If lFa405Cmp
				// Utilizado para gravar campos complementares do SR4
				ExecBlock("FA405CMP", .F.,.F.)
			Endif

		Else
			Reclock("SR4", .F.)
		EndIf

		SR4->R4_VALOR  += (cAliasQry)->FON_BASE
		SR4->(MsUnlock())

		// Gera Valor do Imposto do titulo
		If SR4->( !DBSeek( cChaveSr4 + padr("D",nTamTpRen) + SRL->RL_PAIS + SRL->RL_NIFEX ))

			Reclock("SR4", .T.)

			SR4->R4_FILIAL  := xFilial("SR4",cFilCen)
			SR4->R4_MAT     := SRL->RL_MAT
			SR4->R4_CPFCGC  := cCGCFor
			SR4->R4_MES     := (cAliasQry)->FON_MES
			SR4->R4_TIPOREN := "D"
			SR4->R4_CODRET  := (cAliasQry)->FOM_CODRET
		   	SR4->R4_ANO  	  := (cAliasQry)->FOM_ANO
			SR4->R4_ORIGEM  := "2"

			If !Empty(SRL->RL_PAIS)
				SR4->R4_PAIS  := SRL->RL_PAIS
				SR4->R4_NIFEX := SRL->RL_NIFEX
				SR4->R4_DTPGT := CTOD("01/"+SR4->R4_MES+"/"+SR4->R4_ANO)
				SR4->R4_ISNIF := Iif(lTemNIF,"1","2")
			EndIf

		Else
			Reclock("SR4", .F.)
		Endif

		SR4->R4_VALOR   += (cAliasQry)->FON_IMPREC

		SR4->(MsUnlock())

		nNaoTrib := (cAliasQry)->FON_RNDBRT -(cAliasQry)->FON_BASE
		If nNaoTrib > 0
			If SR4->(!DbSeek(cChaveSr4+padr("I",nTamTpRen)+ SRL->RL_PAIS + SRL->RL_NIFEX ))

				Reclock("SR4", .T.)

				SR4->R4_FILIAL  := xFilial("SR4")
				SR4->R4_MAT     := SRL->RL_MAT
				SR4->R4_CPFCGC  := cCGCFor
				SR4->R4_MES     := (cAliasQry)->FON_MES
				SR4->R4_TIPOREN := "I"
				SR4->R4_CODRET  := (cAliasQry)->FOM_CODRET
				SR4->R4_ANO  	  := (cAliasQry)->FOM_ANO
				SR4->R4_ORIGEM  := "2"

				If !Empty(SRL->RL_PAIS)
					SR4->R4_PAIS := SRL->RL_PAIS
					SR4->R4_NIFEX := SRL->RL_NIFEX
					SR4->R4_DTPGT := CTOD("01/"+SR4->R4_MES+"/"+SR4->R4_ANO)
					SR4->R4_ISNIF :=  IIF(lTemNIF,"1","2")
				EndIf

			Else
				Reclock("SR4", .F.)
			Endif

			SR4->R4_VALOR   += nNaoTrib

			SR4->(MsUnlock())
		Endif

		//Marca registro como enviado
		FON->(DBGoto((cAliasQry)->RECNO))
		Reclock("FON",.F.)
		FON->FON_DIRF = "1"
		FON->(MsUnlock())

		Aadd(aRecnoFon, (cAliasQry)->RECNO)

		(cAliasQry)->(DbSkip())
	EndDo

Next nI
If !Empty(cAliasQry)
	(cAliasQry)->(DbCloseArea())
EndIf

RestArea(aArea)
Return aClone(aRecnoFon)


Function Fa405Limpa(cFilCen As Character, dDataIni As Date, dDataFim As Date, nMultFil as Numeric)

Local cQuery 		As Character
Local nAnoIni 	As Numeric
Local nAnoFim 	As Numeric
Local cMesIni 	As Character
Local cMesFim 	As Character
Local cUpdate 	As Character
Local nI 			As Numeric

nAnoIni := Year(dDataIni)
nAnoFim := Year(dDataFim)
cMesIni := StrZero(Month(dDataIni),02)
cMesFim := StrZero(Month(dDataFim),02)

For nI := nAnoIni to nAnoFim

	If nAnoIni <> nAnoFim
		If nI == nAnoIni
			cMesIni := StrZero(Month(dDataIni),02)
			cMesFim := "12"
		ElseIf nI == nAnoFim
			cMesIni := "01"
			cMesFim := StrZero(Month(dDataFim),02)
		Else
			cMesIni := "01"
			cMesFim := "12"
		EndIf
	EndIf

	cQuery := "SELECT FON.R_E_C_N_O_ RECNO "
	cQuery += "  FROM " + RetSqlName("FOM") + " FOM "
	cQuery += "  JOIN " + RetSqlName("FON") + " FON "
	cQuery += "    ON (FOM.FOM_FILIAL = FON.FON_FILIAL AND FOM.FOM_IDDOC = FON.FON_IDDOC AND FON.D_E_L_E_T_ = ' ' ) "
	cQuery +=  "WHERE "
	If nMultFil <> 1
		cQuery += "   FOM.FOM_FILIAL = '" + cFilAnt + "' AND "
	Endif
	cQuery += "   FOM.FOM_ANO = '"+ StrZero(nI,4) + "' AND "
	cQuery += "   FON.FON_MES BETWEEN '" + cMesIni + "' AND '" + cMesFim + "' AND "
	cQuery += "   FOM.D_E_L_E_T_ = ' ' "
	//cQuery := ChangeQuery(cQuery)	//	Removido pq a query é genérica e em base BD2 está incluindo FOR READ ONLY, provocando ERROR.LOG

	cUpdate := "UPDATE " + RetSqlName("FON") + " SET FON_DIRF = '2' "
	cUpdate += " WHERE R_E_C_N_O_ IN(  "
	cUpdate += cQuery + ")"
	If TcSqlExec(cUpdate) <> 0
		MsgStop( STR0035 + TCSQLError() ) //"Erro ao limpar a flag dos registros de repasse IR: "
	EndIf

Next nI

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F405ValAno()
Valida o conteudo do campo ano

@return lret, true se conteudo do ano estiver ok

@author Leonardo Castro
@since 21/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F405ValAno() As Logical
Local lRet		As Logical
Local oModel	As Object
Local oFOM		As Object

lRet 	:= .T.
oModel	:= FWModelActive()
oFOM 	:= oModel:GetModel("FOMMASTER")

If Len(Alltrim(oFOM:GetValue("FOM_ANO"))) != 4
	lRet := .F.
	Help( ,,"FOM_ANOVAL",,STR0036, 1, 0 )//"Ano invalido! Informe o ano no formato AAAA."
EndIf

Return lRet