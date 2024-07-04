#Include "TMSA580.ch"
#INCLUDE "PROTHEUS.CH"
#Include "FwMvcDef.ch"

//===========================================================================================================
/* Tipos de Faturamento
@author  	VICCO
@version 	P11 R11.8
@build		700120420A
@since 		024/12/2013
@return 	*/
//===========================================================================================================

Function TMSA580()
Local oMBrowse  := Nil

Private aRotina := MenuDef()

//===========================================================================================================
// Funcao de BROWSE
//===========================================================================================================
	oMBrowse:= FwMBrowse():New()
	oMBrowse:SetAlias("DUZ")
	oMBrowse:SetDescription(OemToAnsi(STR0001))
	oMBrowse:Activate()
Return Nil

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Cadastro de Distancias
@author  	VICCO
@version 	P11 R11.7
@build		700120420A
@since 		24/12/2013
@return 	oModel - Modelo de Dados */
//===========================================================================================================
Static Function ModelDef()
Local oModel    := Nil
Local oStruDUZ  := FwFormStruct( 1, "DUZ" )
Local oStruDV0  := FWFormStruct(1 , 'DV0',{|cCampo| AllTrim(cCampo)+"|" $ "DV0_FILIAL|DV0_ITEM|DV0_VALDE|DV0_VALATE|DV0_DIAFAT|"})
// Validacoes dos Fields
Local bPreValid	:= { |oMdl| PreVldMdl(oMdl) }
Local bPosValid := { |oMdl| PosVldMdl(oMdl) }
Local bCommit 	:= Nil
Local bCancel	:= Nil
// Validacoes da Grid
Local bLinePost	:= { |oModel| PosVldLine(oModel) }

oModel := MpFormModel():New( "TMSA580", bPreValid , bPosValid , bCommit ,/*bCancel*/ )

oModel:SetDescriptin( STR0001 )

oModel:AddFields( "MdFieldDUZ", Nil, oStruDUZ )
oModel:AddGrid( "MdGridDV0", "MdFieldDUZ", oStruDV0, /*bLinePre*/ , bLinePost , /*bPre*/ , /*bPost*/,  /*bLoad*/)

oModel:SetRelation( "MdGridDV0",{	{	"DV0_FILIAL", "xFilial('DV0')" }   ,;
									{	"DV0_TIPFAT", "DUZ_TIPFAT"     } } ,;
										"DV0_FILIAL+DV0_TIPFAT" )

oModel:SetPrimaryKey( { "DUZ_FILIAL", "DUZ_TIPFAT" } )
oModel:GetModel( "MdGridDV0" ):SetMaxLine( 01 )
oModel:GetModel("MdGridDV0"):SetUseOldGrid()

Return( oModel )

//===========================================================================================================
/* Retorna a View (tela) da rotina Cadastro de Distancias
@author  	VICCO
@version 	P11 R11.7
@build		700120420A
@since 		24/12/2013
@return 	oView -  */
//===========================================================================================================
Static Function ViewDef()
Local oModel  := FwLoadModel("TMSA580")
Local oView   := Nil
Local oStruDUZ:= FwFormStruct( 2, "DUZ")
Local oStruDV0 := FWFormStruct(2, 'DV0',{|cCampo| AllTrim(cCampo)+"|" $ "DV0_FILIAL|DV0_ITEM|DV0_VALDE|DV0_VALATE|DV0_DIAFAT|"})

oView := FwFormView():New()

oView:SetModel(oModel)

oView:CreateHorizontalBox("FieldDUZ", 010)
oView:CreateHorizontalBox("GridDV0" , 090)

oView:AddField( "VwFieldDUZ", oStruDUZ, "MdFieldDUZ")
oView:AddGrid(  "VwGridDV0" , oStruDV0, "MdGridDV0" )

oView:SetOwnerView( "VwFieldDUZ", "FieldDUZ")
oView:SetOwnerView( "VwGridDV0" , "GridDV0" )

oView:AddIncrementField( "MdGridDV0", "DV0_ITEM" )

oView:SetFieldAction( "DUZ_TIPDIA", { |oModel | MaxLineGrd( oModel ) } )
Return( oView ) 

//---------------------------------------------------------
Static Function MaxLineGrd(oModel)
Local lRet := .F.

If	oModel:GetValue( "MdFieldDUZ", "DUZ_TIPDIA" ) == StrZero( 1, Len(DUZ->DUZ_TIPDIA))
	oModel:GetModel( "MdGridDV0"):SetMaxLine( 31 )
ElseIf oModel:GetModel( "MdGridDV0"):Length() <= 1
	oModel:GetModel( "MdGridDV0"):SetMaxLine( 01 )
EndIf

Return( lRet )

//---------------------------------------------------------
Static Function MenuDef()
aRotina := {	{ STR0002, "AxPesqui"			,0 , 1,,.F. },;	//"Pesquisar"
				{ STR0003, "VIEWDEF.TMSA580"	,0 , 2 },;			//"Visualizar"
				{ STR0004, "VIEWDEF.TMSA580"	,0 , 3 },;			//"Incluir"
				{ STR0005, "VIEWDEF.TMSA580"	,0 , 4 },;			//"Alterar"
				{ STR0006, "VIEWDEF.TMSA580"	,0 , 5 } }			//"Excluir"

If ExistBlock("TM580MNU")
	ExecBlock("TM580MNU",.F.,.F.)
EndIf

Return( aRotina )

//---------------------------------------------------------
Static Function PreVldMdl(oModel)
Local lRet      := .T.
If oModel <> Nil .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	If	DUZ->DUZ_TIPDIA == StrZero( 1, Len(DUZ->DUZ_TIPDIA))
		oModel:GetModel( "MdGridDV0"):SetMaxLine( 31 )
	ElseIf oModel:GetModel( "MdGridDV0"):Length() <= 1
		oModel:GetModel( "MdGridDV0"):SetMaxLine( 01 )
	EndIf
EndIf
Return lRet

//---------------------------------------------------------
Static Function PosVldMdl(oModel)
Local aArea     := GetArea()
Local cQuery    := ""
Local cAliasQry := ""
Local lRet      := .T.
Local nA        := 0
Local nDias     := 0
Local cTipDia   := IIf(INCLUI,M->DUZ_TIPDIA,DUZ->DUZ_TIPDIA)
Local oModelDV0

If oModel <> Nil .And. oModel:GetOperation() == MODEL_OPERATION_DELETE

	/* Verifca se o Tipo de Faturamento esta sendo utilizado no perfil do cliente(DUO). */
	cAliasQry := GetNextAlias()
	cQuery := "SELECT 1 "
	cQuery += "FROM " + RetSqlName("DUO") + " DUO "
	cQuery += "WHERE DUO.DUO_FILIAL = '" + xFilial("DUO") + "'"
	cQuery += "  AND DUO.DUO_TIPFAT = '" + DUZ->DUZ_TIPFAT  + "'"
	cQuery += "  AND DUO.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	If (cAliasQry)->(!Eof())
		Help(" ", 1, "TMSA58009") // "Esse tipo de faturamento esta sendo utilizado no perfil do cliente."
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())

ElseIf oModel <> Nil .And. (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE)

	oModelDV0 := oModel:GetModel("MdGridDV0")
	aHeader   := oModelDV0:aHeader
	aCols     := oModelDV0:aCols
	If cTipDia == StrZero(1, Len(DUZ->DUZ_TIPDIA))
		For nA := 1 To Len(aCols)
			If	!GDDeleted(nA)
				nDias += (GDFieldGet("DV0_VALATE", nA) - GDFieldGet("DV0_VALDE", nA)) + 1
			EndIf
		Next nA
		/* Para o tipo do dia mensal, verifica se a soma dos dia eh igual a 31. */
		If nDias != 31
			Help(" ", 1, "TMSA58007") // "Para o tipo de faturamento mensal as faixas cadastrais devem somar 31 dias."
			lRet := .F.
		EndIf
	EndIf

EndIf
RestArea(aArea)
Return lRet

//---------------------------------------------------------
Static Function PosVldLine(oModel)
Local aArea   := GetArea()
Local lRet    := .T.
Local nA      := 0
Local cTipDia := IIf(INCLUI,M->DUZ_TIPDIA,DUZ->DUZ_TIPDIA)

If Valtype(aHeader) == "U"
	Private aHeader := {}
	Private aCols	  := {}
EndIf

n		:= oModel:GetLine() //Controle de numero da linha
aHeader:= oModel:aHeader
aCols	:= oModel:aCols

If !GDdeleted(n)

	/* Verifica se a faixa De foi informada. */
	If (lRet:=MaCheckCols(aHeader,aCols,n))
		If Empty(GDFieldGet("DV0_VALDE" , n))
			Help(" ", 1, "TMSA58001") // "Informe a faixa 'De'."
			lRet := .F.
		EndIf
	EndIf

	/* Verifica se a faixa Ate foi informada. */
	If lRet .And. Empty(GDFieldGet("DV0_VALATE", n))
		Help(" ", 1, "TMSA58002") // "Informe a faixa 'Ate'."
		lRet := .F.
	EndIf
	/* Verifica se o dia da fatura foi informado. */
	If lRet .And. Empty(GDFieldGet("DV0_DIAFAT", n))
		Help(" ", 1, "TMSA58003") // "Informe o dia da fatura."
		lRet := .F.
	EndIf
	/* Verifica se a faixa De/Ate eh valida. */
	If lRet .And. cTipDia == StrZero(1, Len(DUZ->DUZ_TIPDIA)) .And. GDFieldGet("DV0_VALATE", n) < GDFieldGet("DV0_VALDE", n)
		Help(" ", 1, "TMSA58004") // "A faixa 'Ate' deve ser maior que a faixa 'De'."
		lRet := .F.
	EndIf
	/* Verifica se a faixa 'Ate' para o tipo de faturamento mensal eh valida. */
	If lRet .And. cTipDia == StrZero(1, Len(DUZ->DUZ_TIPDIA)) .And.;
		GDFieldGet("DV0_VALATE", n) > 31
		Help(" ", 1, "TMSA58005") // "Para tipo de faturamento mensal a faixa 'Ate' nao pode ser maior que 31."
		lRet := .F.
	EndIf
	/* Verifica se o dia da fatura para o tipo de faturamento mensal eh valido. */
	If lRet .And. cTipDia == StrZero(1, Len(DUZ->DUZ_TIPDIA)) .And.;
		GDFieldGet("DV0_DIAFAT", n) > 31
		Help(" ", 1, "TMSA58010") // "Para tipo de faturamento mensal o dia da fatura nao pode ser maior que 31."
		lRet := .F.
	EndIf
	/* Verifica se a faixa 'Ate' para o tipo de faturamento semanal eh valida. */
	If lRet .And. cTipDia == StrZero(2, Len(DUZ->DUZ_TIPDIA)) .And.;
		( GDFieldGet("DV0_VALDE", n) > 7 .Or. GDFieldGet("DV0_VALATE", n) > 7 )
		Help(" ", 1, "TMSA58006") // "Para tipo de faturamento semanal a faixa 'De' / 'Ate' nao pode ser maior que 7."
		lRet := .F.
	EndIf
	/* Verifica se o dia da fatura para o tipo de faturamento semanal eh valido. */
	If lRet .And. cTipDia == StrZero(2, Len(DUZ->DUZ_TIPDIA)) .And.;
		GDFieldGet("DV0_DIAFAT", n) > 7
		Help(" ", 1, "TMSA58011") // "Para tipo de faturamento semanal o dia da fatura nao pode ser maior que 7."
		lRet := .F.
	EndIf
EndIf
If lRet
	/* Verifica os intervalos entre as faixas. */
	For nA := 1 To Len(aCols)
		If	lRet .And. !GDDeleted(nA) .And. nA != 1
			If GDFieldGet("DV0_VALDE", nA) <= GDFieldGet("DV0_VALATE", (nA - 1))
				Help(" ", 1, "TMSA58012") // "A faixa De deve ser maior que a faixa Ate do intervalo anterior."
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nA
EndIf

RestArea(aArea)
Return( lRet )

//---------------------------------------------------------
Function TMSA580Vld()
Local lRet   := .T.
Local cCampo := ReadVar()
Local oModelGrid := FWModelActive()

If cCampo == "M->DUZ_TIPDIA"
	If &cCampo == StrZero(2, Len(DUZ->DUZ_TIPDIA)) // Tipo do Dia : "Semana"
		If oModelGrid:GetModel( "MdGridDV0"):Length() > 1
			lRet := .F.
		EndIf
	EndIf
EndIf
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA580XBI   ³ Autor ³ Robson Alves       ³ Data ³ 22/01/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a rotina de Inclusao de Tipos de Faturamento.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - DUZ                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA580XBI()
Local aArea := GetArea()

SAVEINTER()

FWExecView(STR0004,"VIEWDEF.TMSA580", MODEL_OPERATION_INSERT,, { || .T. } ,,  /*nPerReducTela*/ ) //'Incluir'

RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA580XBV   ³ Autor ³ Robson Alves       ³ Data ³ 22/01/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a rotina de Vizualizacao de Tipos de Faturamento.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consulta SXB - DUZ                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA580XBV()
Local aArea   := GetArea()
Local cOldFil := DC6->(dbFilter())
Local IncOld  := Inclui

Inclui := .F.
SAVEINTER()

FWExecView(STR0003,"VIEWDEF.TMSA580", MODEL_OPERATION_VIEW ,, { || .T. } ,, /*nPerReducTela*/ ) //'Visualizar'

If !Empty( cOldFil )
	Set Filter to &cOldFil
EndIf

Inclui := IncOld
RestArea(aArea)
Return Nil
