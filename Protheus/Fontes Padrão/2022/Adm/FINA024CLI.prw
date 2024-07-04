#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE 'FINA024CLI.CH'

//-----------------------------------------------------------------------------
/*/ {Protheus.doc} FINA024CLI
Detalhamento dos valores acessórios.

@author rodrigo.pirolo
@since  22/09/2017
@version 12
/*/	
//-----------------------------------------------------------------------------

Function FINA024CLI(nOpcZ)

Local oModel	:= Nil

Local aEnableButtons	:=	{	{ .F., Nil }, { .F., Nil }, ;
								{ .F., Nil }, { .F., Nil }, ;
								{ .F., Nil }, { .F., Nil }, ;
								{ .T., Nil }, { .T., Nil }, ;
								{ .F., Nil }, { .F., Nil }, ;
								{ .F., Nil }, { .F., Nil }, ;
								{ .F., Nil }, { .F., Nil }		} //"Confirmar"###"Fechar"

Default nOpcZ	:= 3

DbSelectArea("FOJ")
FOJ->( DbSetOrder(1) )

If nOpcZ == 2
	
	If FOJ->( DbSeek( xFilial("FOJ") + M->A1_COD + M->A1_LOJA ) )
		FWExecView( STR0001 ,"FINA024CLI", MODEL_OPERATION_VIEW, /**/, /**/, /**/, , aEnableButtons )		//"Tipos de Retenções x Fornecedores"
	Else
		Aviso( STR0002, STR0009, {STR0004},2)
	EndIf
	
ElseIf ( !Empty(M->A1_COD) .AND. !Empty(M->A1_LOJA) ) .AND. Empty(cOldCli) .AND. nOpcZ == 3

	FWExecView( STR0001 ,"FINA024CLI", MODEL_OPERATION_INSERT, /**/, /**/, /**/, , aEnableButtons )		//"Tipos de Retenções x Fornecedores"

ElseIf ( !Empty(M->A1_COD) .AND. !Empty(M->A1_LOJA) ) .AND. Empty(cOldCli)// .AND. nOpcZ == 4
	
	FOJ->( DbSeek(xFilial("FOJ") + M->A1_COD + M->A1_LOJA ) )

	FWExecView( STR0001 ,"FINA024CLI", MODEL_OPERATION_UPDATE, /**/, /**/, /**/, , aEnableButtons )		//"Tipos de Retenções x Fornecedores"

ElseIf ( !Empty(M->A1_COD) .AND. !Empty(M->A1_LOJA) ) .AND. !Empty(cOldCli) .AND. ( nOpcZ == 4 .OR. nOpcZ == 3 )
	
	oModel := FWLoadModel("FINA024CLI")
	oModel:SetOperation( MODEL_OPERATION_UPDATE )
	oModel:Activate()
	oModel:LoadXMLData( cOldCli )
	
	FWExecView( STR0001 ,"FINA024CLI", MODEL_OPERATION_UPDATE,/**/,/**/,/**/,,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/, oModel ) //"Tipos de Retenções x Fornecedores"
	
ElseIf Empty(M->A1_COD) .OR. Empty(M->A1_LOJA)
	Aviso( STR0002, STR0003, {STR0004},2)// "Atenção!" "Para acessar esta opção, os campos Código e Loja do Cliente não podem estar em branco." "Ok"
EndIf

FOJ->( DbCloseArea() )

Return

//-------------------------------------------------------------------
/*/ {Protheus.doc} ViewDef
Definição do interface

@author rodrigo.pirolo
@since  22/09/2017
@version 12
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView
Local oModel	:= ModelDef()
Local cCampos	:= If( FwIsInCallStack("F024CExAut"), 'A1_FILIAL, A1_COD, A1_LOJA', 'A1_FILIAL, A1_COD, A1_LOJA, A1_NOME' )
Local oSA1		:= FWFormStruct(2, 'SA1', { |x| AllTrim(x) $ cCampos } )
Local oFOJ		:= FWFormStruct(2, 'FOJ', { |x| AllTrim(x) $ 'FOJ_CODIGO|FOJ_IDFKK' } )

oView := FWFormView():New()

oFOJ:AddField(	"FOJ_DESCR",;
				"05",;
				STR0005,;	// "Descrição"
				STR0006,;	// "Detalhamento do tipo de imposto"
				{},;
				"C",;
				"@!",;
				/*bPictVar*/,;
				/*cLookUp*/,;
				.F./*lCanChange*/,;
				/*cFolder*/,;
				/*cGroup*/,;
				/*aComboValues*/,;
				/*nMaxLenCombo*/,;
				/*cIniBrow*/,;
				.T.,;
				/*cPictVar*/,;
				/*lInsertLine*/ )

oFOJ:SetProperty('FOJ_CODIGO', MVC_VIEW_LOOKUP, { || FN024CF3("FOJ_CODIGO") } )

oView:SetModel(oModel)
oView:showUpdateMsg(.F.)
oView:showInsertMsg(.F.)
oView:AddField( 'FORMSA1', oSA1, 'SA1MASTER' )
oView:AddGrid( 'FORMFOJ', oFOJ, 'FOJDETAIL' )

oSA1:SetNoFolder()

oView:CreateHorizontalBox( 'BOXFORMSA1', 16)
oView:CreateHorizontalBox( 'BOXFORMFOJ', 84)

oView:SetOwnerView('FORMFOJ','BOXFORMFOJ')
oView:SetOwnerView('FORMSA1','BOXFORMSA1')

Return oView

//-------------------------------------------------------------------
/*/ {Protheus.doc} ModelDef
Definição do modelo de Dados

@author rodrigo.pirolo
@since  22/09/2017
@version 12
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel	:= MPFormModel():New( 'FINA024CLI', /*Pre*/, /*Pos*/, { || FN024CGrv() } /*Commit*/ )
Local cCampos	:= If( FwIsInCallStack("F024CExAut"), 'A1_FILIAL, A1_COD, A1_LOJA', 'A1_FILIAL, A1_COD, A1_LOJA, A1_NOME' )
Local oSA1		:= FWFormStruct( 1, 'SA1', { |x| ALLTRIM(x) $ cCampos } )
Local oFOJ		:= FWFormStruct( 1, 'FOJ'  )

oModel:AddFields( 'SA1MASTER', , oSA1 )

oFOJ:AddField(	STR0005,;																// [01] Titulo do campo 		"Descrição"
				STR0006,;																// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"//
				"FOJ_DESCR",;															// [03] Id do Field
				"C"	,;																	// [04] Tipo do campo
				40,;																	// [05] Tamanho do campo
				0,;																		// [06] Decimal do campo
				{ || .T. }	,;															// [07] Code-block de validação do campo
				{ || .T. }	,;															// [08] Code-block de validação When do campo
				,;																		// [09] Lista de valores permitido do campo
				.F.	,;																	// [10]	Indica se o campo tem preenchimento obrigatório
				FWBuildFeature( STRUCT_FEATURE_INIPAD, "F024CDRet('FOJ_DESCR', 2 )" ),;	// [11] Inicializador Padrão do campo
				,; 																		// [12] 
				,; 																		// [13] 
				.T.	) 																	// [14] Virtual

oFOJ:AddTrigger("FOJ_CODIGO", "FOJ_DESCR", { || .T.}, { || F024CDRet("FOJ_DESCR", 1) })

oSA1:SetProperty( 'A1_COD', MODEL_FIELD_WHEN, { || .F. } )
oSA1:SetProperty( 'A1_LOJA', MODEL_FIELD_WHEN, { || .F. } )

If !FwIsInCallStack("F024CExAut")
	oSA1:SetProperty( 'A1_NOME', MODEL_FIELD_WHEN, { || .F. } )
	oSA1:SetProperty( 'A1_NOME', MODEL_FIELD_OBRIGAT, .F. )
EndIf

oFOJ:SetProperty( 'FOJ_CLIENT', MODEL_FIELD_OBRIGAT, .F. )
oFOJ:SetProperty( 'FOJ_LOJA', MODEL_FIELD_OBRIGAT, .F. )

oModel:addGrid( 'FOJDETAIL', 'SA1MASTER', oFOJ, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, /*bLoad*/ )

oModel:GetModel( 'FOJDETAIL'):SetUniqueLine( { 'FOJ_FILIAL', 'FOJ_CLIENT', 'FOJ_LOJA', 'FOJ_CODIGO' } )

oModel:SetRelation('FOJDETAIL', { { 'FOJ_FILIAL', 'xFilial("FOJ")' }, { 'FOJ_CLIENT', 'A1_COD' }, { 'FOJ_LOJA', 'A1_LOJA' } }, FOJ->(IndexKey(1)) )

oModel:SetPrimaryKey( { 'A1_FILIAL', 'A1_COD', 'A1_LOJA' } )

//Define uma linha única para a grid
oModel:GetModel("FOJDETAIL"):SetUniqueLine({"FOJ_CODIGO"})
oModel:GetModel("FOJDETAIL"):SetDelAllLine(.T.)
oModel:GetModel("FOJDETAIL"):SetOptional(.T.)

oModel:GetModel('SA1MASTER'):SetDescription(STR0007) // "Cliente"
oModel:GetModel('SA1MASTER'):SetOnlyQuery( .T. )

oModel:GetModel('FOJDETAIL'):SetDescription(STR0008) //'Tipo de Retenção'

oModel:SetActivate( { |oModel| FN024CInfo( oModel ) } )

Return oModel

//-----------------------------------------------------------------------------
/*/ {Protheus.doc} FN024FGrv
Gravação do modelo de dados.

@author rodrigo.pirolo	
@since  22/09/2017
@version 12
/*/	
//-----------------------------------------------------------------------------

Function FN024CGrv()

Local oModel	:= FWModelActive()

Local nX		:= 0

cOldCli	:= oModel:GetXMLData( , , , , , .T. )	//GetXMLData( lDetail, nOperation, lXSL, lVirtual, lDeleted, lEmpty, lDefinition, cXMLFile, lPK, lPKEncoded, aFilterFields, lFirstLevel, lInternalID ) 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FGetTpRet()
Funcao para preenchimento dos campos virtuais do tipo retenção

@param cField - Campo a ser preenchido do campo FOI_CODIGO
@param nProperty - 2 = Gatilho / 1 = Inicializador padrao

@author Totvs Sa
@since	14/09/2017
@version 12
/*/
//-------------------------------------------------------------------

Function F024CDRet( cField, nProperty )

Local nOper		:= 0

Local cCodigo	:= ""
Local cRet		:= ""

Local oModel	:= NIL

DEFAULT cField		:= " "
DEFAULT nProperty	:= 1

oModel	:= FWModelActive()
nOper	:= oModel:GetOperation()
cRet	:= If(nProperty == 1 .And. !Empty(cField), oModel:GetValue("FOJDETAIL", cField), " " )

If nProperty == 2
	If nOper == MODEL_OPERATION_INSERT
		cRet := ""
	ElseIf nOper == MODEL_OPERATION_UPDATE
		
		If Empty(cOldCli) .AND. !(FWIsInCallStack("ADDLINE"))
			If FOJ->FOJ_CLIENT <> SA1->A1_COD
				cRet := ""
			Else
				cRet := Posicione( "FKK", 3, xFilial("FKK") + "1" + FOJ->FOJ_CODIGO, "FKK_DESCR" )//
				If Empty(cRet)
					cRet := Posicione( "FKK", 3, xFilial("FKK") + "2" + FOJ->FOJ_CODIGO, "FKK_DESCR" )//
				EndIf
			EndIf
		ElseIf FWIsInCallStack("ADDLINE")
			cRet := ""
		EndIf
	ElseIf nOper == MODEL_OPERATION_VIEW
		cRet := Posicione( "FKK", 1, xFilial("FKK") + FOJ->FOJ_IDFKK, "FKK_DESCR" )//
	EndIf
ElseIf (nProperty == 1 .Or. nOper != MODEL_OPERATION_INSERT)
	cCodigo := oModel:GetValue("FOJDETAIL", "FOJ_CODIGO")
	
	If !Empty(cCodigo)
		cRet := Posicione("FKK", 3, xFilial("FKK") + "1" + cCodigo, "FKK_DESCR")
	EndIf
EndIf

Return cRet

//-----------------------------------------------------------------------------
/*/ {Protheus.doc} FN024FLine
Gravação do modelo de dados.

@author rodrigo.pirolo	
@since  22/09/2017
@version 12
/*/	
//-----------------------------------------------------------------------------

Function FN024CLine()

Local oModel	:= FWModelActive()
Local oMdlSA1	:= oModel:GetModel("SA1MASTER")
Local oMdlFOJ	:= oModel:GetModel("FOJDETAIL")

Local lRet		:= .T.

If !Empty( oMdlSA1:GetValue("A1_COD") )
	oMdlFOJ:LoadValue("FOJ_CLIENT", oMdlSA1:GetValue("A1_COD") )
	oMdlFOJ:LoadValue("FOJ_LOJA", oMdlSA1:GetValue("A1_LOJA") )
EndIf

Return lRet

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} F024FOJ
 
@author rodrigo.pirolo
@since 26/09/2017
@version V12
/*/
//--------------------------------------------------------------------------------------

Function FN024FOJ(lDeleta)

Local oModel:= NIL

Local nX	:= 0

Local lRet	:= .F.

Default lDeleta	:= .F.

If TableInDic('FOJ')
	cOldCli := Iif(Type("cOldCli") == 'U', "" , cOldCli)
	
	If !Empty(cOldCli)
		If !lDeleta
			oModel := FWLoadModel("FINA024CLI")
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
		ElseIf lDeleta
			oModel := FWLoadModel("FINA024CLI")
			oModel:SetOperation( MODEL_OPERATION_DELETE )
		EndIf
		
		oModel:Activate()
		oModel:LoadXMLData( cOldCli )
		
		If oModel:VldData()
			lRet := FWFormCommit( oModel )
		EndIf
		
		oModel:Deactivate()
		oModel:Destroy
		oModel := NIL
		cOldCli := ""
	
	EndIf		
EndIf

Return lRet

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} F024FInfo
 
@author pequim
@since 15/08/2016
@version undefined
@param lCancel
/*/
//--------------------------------------------------------------------------------------

Function FN024CInfo( oModel )

Local oSubSA1	:= oModel:GetModel("SA1MASTER")
Local lRet		:= .T.
Local aArea		:= GetArea()

If Empty(cOldCli) .AND. ( oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE )
	If FwIsInCallStack("F024CExAut")
		oSubSA1:LoadValue( "A1_COD",	SA1->A1_COD	)
		oSubSA1:LoadValue( "A1_LOJA",	SA1->A1_LOJA	)
	Else
		oSubSA1:LoadValue( "A1_COD",	M->A1_COD	)
		oSubSA1:LoadValue( "A1_LOJA",	M->A1_LOJA	)
		oSubSA1:LoadValue( "A1_NOME",	M->A1_NOME	)
	EndIf
EndIf	
	
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FN024FF3
consulta Padrão SXB

@author	rodrigo.pirolo
@since	25/09/2017
@version 12
/*/
//-------------------------------------------------------------------

Function FN024CF3( cCmpF3 )

Local cF3	:= ""

DEFAULT cCmpF3	:= ""

cF3		:=	""

If cCmpF3 $ 'FOJ_CODIGO'
	cF3 :=	"FKKREC"
EndIf

Return cF3

//-------------------------------------------------------------------
/*/{Protheus.doc} F986ExAut
Funcao para carregar o model quando a inclusão do título for via execauto

@since  28/09/2017
@version P12
/*/
//-------------------------------------------------------------------

Function F024CExAut( aRotAuto, aRAutoFOJ, nOpca )

Local cIdDoc 	:= ""
Local cChave 	:= ""
Local oModel	:= Nil
Local oSubSA1	:= Nil
Local oSubFOJ	:= Nil
Local nPos		:= 1
Local nPosFOJ	:= 1
Local nTotFOJ	:= Len(aRAutoFOJ)
Local nPosCod	:= 0
Local nPosFor	:= 0
Local nPosLoj	:= 0
Local lRet		:= .T.
Local lAlt		:= nOpca == MODEL_OPERATION_UPDATE
Local lNewLin	:= .F.

If nOpca <>  MODEL_OPERATION_VIEW
	
	If nOpca == MODEL_OPERATION_UPDATE
	
		cChave := SA1->A1_COD + SA1->A1_LOJA
		
		FOJ->( DBSetOrder(1) )
		FOJ->( DBSeek(xFilial("FOJ") + cChave ) )
	EndIf
	
	If lRet
		oModel := FwLoadModel("FINA024CLI")
		oModel:SetOperation( nOpca )
		oModel:Activate()
		
		oSubSA1 := oModel:GetModel("SA1MASTER")
		oSubFOJ := oModel:GetModel("FOJDETAIL")
		
		If nOpca <> MODEL_OPERATION_DELETE
		
			If nOpca == MODEL_OPERATION_INSERT
				oSubSA1:LoadValue( "A1_COD",	SA1->A1_FILIAL	)
				oSubSA1:LoadValue( "A1_COD",	SA1->A1_COD		)
				oSubSA1:LoadValue( "A1_LOJA",	SA1->A1_LOJA	)
			
				For nPos := 1 to nTotFOJ
					nPosCod := aScan( aRAutoFOJ[nPos], { |x| UPPER(AllTrim(x[1])) == "FOJ_CODIGO" } )
					lNewLin := .F.
					For nPosFOJ := 1 To Len(aRAutoFOJ[nPos])
						
						oSubFOJ:SetValue( aRAutoFOJ[nPos][nPosFOJ][1], aRAutoFOJ[nPos][nPosFOJ][2] )
						
					Next nPosFOJ
					//aErro
					If oSubFOJ:VldData()
						If nPos < nTotFOJ
							oSubFOJ:AddLine()
						EndIf
					Else
						lRet := .F.
					EndIf
					
				Next nPos
				
			ElseIf nOpca == MODEL_OPERATION_UPDATE
				
				For nPos := 1 To oSubFOJ:Length()
					oSubFOJ:GoLine(nPos)
					If !oSubFOJ:IsDeleted()
						oSubFOJ:DeleteLine()
					EndIf
				Next nPos
				
				For nPos := 1 To nTotFOJ
					nPosFor := aScan( aRAutoFOJ[nPos], { |x| UPPER(AllTrim(x[1])) == "FOJ_CLIENT"	} )
					nPosLoj := aScan( aRAutoFOJ[nPos], { |x| UPPER(AllTrim(x[1])) == "FOJ_LOJA"		} )
					nPosCod := aScan( aRAutoFOJ[nPos], { |x| UPPER(AllTrim(x[1])) == "FOJ_CODIGO"	} )
					
					lNewLin := .F.
					
					If !oSubFOJ:SeekLine( {	{ aRAutoFOJ[nPos][nPosFor][1], aRAutoFOJ[nPos][nPosFor][2] },;
											{ aRAutoFOJ[nPos][nPosLoj][1], aRAutoFOJ[nPos][nPosLoj][2] },;
											{ aRAutoFOJ[nPos][nPosCod][1], aRAutoFOJ[nPos][nPosCod][2] } }, .T. )//Caso não consiga posicionar, adiciona a linha	
						oSubFOJ:AddLine()
						lNewLin := .T.
					Else
						If oSubFOJ:IsDeleted()
							oSubFOJ:UnDeleteLine()
						EndIf
					EndIf
					
					For nPosFOJ := 1 To Len(aRAutoFOJ[nPos])
						If lNewLin
							oSubFOJ:SetValue( aRAutoFOJ[nPos][nPosFOJ][1], aRAutoFOJ[nPos][nPosFOJ][2] )
						EndIf
					Next nPosFOJ
					
					If !oSubFOJ:VldData()
						lRet := .F.
					EndIf
					
				Next nPos
				
			EndIf
		EndIf

		If lRet
			cOldCli := oModel:GetXMLData( , , , , lAlt, .T. ) 
			oModel:Deactivate()
			oModel:Destroy()
			oModel:= Nil
		EndIf
		
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FGetTpRet()
Funcao para preenchimento dos campos virtuais do tipo retenção

@param cField - Campo a ser preenchido do campo FOI_CODIGO
@param nProperty - 2 = Gatilho / 1 = Inicializador padrao

@author Totvs Sa
@since	14/09/2017
@version 12
/*/
//-------------------------------------------------------------------

Function A010FOJTRet(oView)

Local oModel := oView:GetModel()
Local oViewTpRet
Local oExecView
Local oStr
Local aMT020FIL
Local cFieldsBanco :=  "FOJ_CODIGO"
	
	oStr:= FWFormStruct(2, 'FOJ', {|cField| AllTrim(Upper(cField)) $ AllTrim(Upper(cFieldsBanco)) })
	
	oStr:AddField(	"FOJ_DESCR", "05", STR0003, STR0004, {}, "C", "@!", ;//"Descrição" 
							/*bPictVar*/, /*cLookUp*/, .F./*lCanChange*/,/*cFolder*/, ;
							/*cGroup*/, /*aComboValues*/, /*nMaxLenCombo*/,/*cIniBrow*/,;
							.T., /*cPictVar*/, /*lInsertLine*/ )
	
	oStr:SetProperty('FOJ_CODIGO', MVC_VIEW_LOOKUP, { || FN024CF3("FOJ_CODIGO") } )
	
	//--------------------------------------------------------------------------------
	//	Monta a view para exibir o grid
	// oView é passado por parametro para indicar que oViewBancos é filho do oView
	//--------------------------------------------------------------------------------
	oViewTpRet := FWFormView():New(oView) 	
	oViewTpRet:SetModel(oModel)
	oViewTpRet:AddGrid('FORMFOJDETAIL' , oStr,'FOJDETAIL' )	
	oViewTpRet:CreateHorizontalBox( 'BOXFOJDETAIL', 100)
	oViewTpRet:SetOwnerView('FORMFOJDETAIL','BOXFOJDETAIL')
	oViewTpRet:SetCloseOnOk({|| .T.})
	
	//--------------------------------------------------------------------------------
	// Monta a janela para exibir o view. Não é usado o FWExecView porque o FWExecView
	// obriga a passar o fonte para carregar a View e aqui já temos a view pronta
	//--------------------------------------------------------------------------------
	oExecView := FWViewExec():New()
	oExecView:SetView(oViewTpRet)
	oExecView:setTitle(STR0005)//"Tipos de Retenções"
	oExecView:SetModel(oModel)
	oExecView:setModal(.F.)
	oExecView:setOperation(oModel:GetOperation())
	oExecView:openView(.F.)	
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C980CDesc()
Funcao para preenchimento dos campos virtuais do tipo retenção

@param cField - Campo a ser preenchido do campo FOj_CODIGO
@param nProperty - 2 = Gatilho / 1 = Inicializador padrao

@author Totvs Sa
@since	14/09/2017
@version 12
/*/
//-------------------------------------------------------------------

Function C980CDesc( cField, nProperty )

Local nOper		:= 0

Local cCodigo	:= ""
Local cRet		:= ""

Local oModel	:= NIL

DEFAULT cField	:= " "
DEFAULT nProperty	:= 1

oModel	:= FWModelActive()
nOper	:= oModel:GetOperation()
cRet	:= If(nProperty == 1 .And. !Empty(cField), oModel:GetValue("FOJDETAIL", cField), " " )

If nProperty == 2
	If nOper == MODEL_OPERATION_INSERT
		cRet := ""
	ElseIf nOper == MODEL_OPERATION_UPDATE
		
		If !(FWIsInCallStack("ADDLINE"))
			If FOJ->FOJ_CLIENT <> SA1->A1_COD
				cRet := ""
			Else
				cRet := Posicione( "FKK", 1, xFilial("FKK") + FOJ->FOJ_IDFKK, "FKK_DESCR" )// Posicione( "FKK", 3, xFilial("FKK") + "1" + FOJ->FOJ_CODIGO, "FKK_DESCR" )//
			EndIf
			
		ElseIf FWIsInCallStack("ADDLINE")
			cRet := ""
		EndIf
	Else
		cRet := Posicione( "FKK", 1, xFilial("FKK") + FOJ->FOJ_IDFKK, "FKK_DESCR" )// Posicione( "FKK", 3, xFilial("FKK") + "1" + FOJ->FOJ_CODIGO, "FKK_DESCR" )
	EndIf
ElseIf (nProperty == 1 .Or. nOper != MODEL_OPERATION_INSERT)
	cCodigo := oModel:GetValue("FOJDETAIL", "FOJ_CODIGO")	
	
	If !Empty(cCodigo)
		nRecFKK := FinFKKVig(cCodigo, dDataBase)
		If nRecFKK > 0
			cRet := FKK->FKK_DESCR
		Endif
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN024FOJ
validação do código (FOJ_CODIGO)

@author Totvs Sa
@since 01/11/2017
@return Logico
/*/
//-------------------------------------------------------------------
Function FIN024FOJ()
Local lRet As Logical
Local oModel As Object
Local cCodigo As Character
Local aArea As Array

oModel := FWModelActive()
cCodigo := oModel:GetValue("FOJDETAIL","FOJ_CODIGO")
lRet := .F.

If !Empty(cCodigo )
	aArea := GetArea()	
	nRecFKK := FinFKKVig(cCodigo, dDataBase)
	If nRecFKK > 0
		oModel:LoadValue('FOJDETAIL','FOJ_IDFKK', FKK->FKK_IDRET)
		lRet := .T.
	Endif
	RestArea(aArea)
Endif

Return lRet