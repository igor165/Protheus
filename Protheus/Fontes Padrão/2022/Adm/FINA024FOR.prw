#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE 'FINA024FOR.CH'

//-----------------------------------------------------------------------------
/*/ {Protheus.doc} FINA024FOR
Detalhamento dos valores acessórios.

@author rodrigo.pirolo
@since  22/09/2017
@version 12
/*/	
//-----------------------------------------------------------------------------

Function FINA024FOR(nOpcZ)

Local oModel	:= Nil

Local aEnableButtons	:=	{	{ .F., Nil }, { .F., Nil }, ;
								{ .F., Nil }, { .F., Nil }, ;
								{ .F., Nil }, { .F., Nil }, ;
								{ .T., Nil }, { .T., Nil }, ;
								{ .F., Nil }, { .F., Nil }, ;
								{ .F., Nil }, { .F., Nil }, ;
								{ .F., Nil }, { .F., Nil }		} //"Confirmar"###"Fechar"

Default nOpcZ	:= 3

DbSelectArea("FOK")
FOK->( DbSetOrder(1) )

If nOpcZ == 2
	
	If FOK->( DbSeek( xFilial("FOK") + M->A2_COD + M->A2_LOJA ) )
		FWExecView( STR0001 ,"FINA024FOR", MODEL_OPERATION_VIEW, /**/, /**/, /**/, , aEnableButtons )		//"Tipos de Retenções x Fornecedores"
	Else
		Aviso( STR0002, STR0009, {STR0004},2)
	EndIf
	
ElseIf (!Empty(M->A2_COD) .AND. !Empty(M->A2_LOJA) ) .AND. Empty(cOldFor) .AND. nOpcZ == 3

	FWExecView( STR0001 ,"FINA024FOR", MODEL_OPERATION_INSERT, /**/, /**/, /**/, , aEnableButtons )		//"Tipos de Retenções x Fornecedores"

ElseIf (!Empty(M->A2_COD) .AND. !Empty(M->A2_LOJA) ) .AND. Empty(cOldFor)// .AND. nOpcZ == 4
	
	FWExecView( STR0001 ,"FINA024FOR", MODEL_OPERATION_UPDATE, /**/, /**/, /**/, , aEnableButtons )		//"Tipos de Retenções x Fornecedores"

ElseIf (!Empty(M->A2_COD) .AND. !Empty(M->A2_LOJA) ) .AND. !Empty(cOldFor) .AND. ( nOpcZ == 4 .OR. nOpcZ == 3 )
	
	oModel := FWLoadModel("FINA024FOR")
	oModel:SetOperation( MODEL_OPERATION_UPDATE )
	oModel:Activate()
	oModel:LoadXMLData( cOldFor )
	
	FWExecView( STR0001,"FINA024FOR", MODEL_OPERATION_UPDATE,/**/,/**/,/**/,,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/, oModel )//"Tipos de Retenções x Fornecedores"
ElseIf Empty(M->A2_COD) .OR. Empty(M->A2_LOJA)
	Aviso( STR0002, STR0003, {STR0004},2) // STR0002 "Atenção!" STR0003 "Para acessar esta opção, o campo Código e Loja do Fornecedor não pode estar em branco." STR0004 "Ok"
EndIf

FOK->( DbCloseArea() )

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
Local cCampos	:= If( FwIsInCallStack("F024FExAut"),'A2_FILIAL, A2_COD, A2_LOJA', 'A2_FILIAL, A2_COD, A2_LOJA, A2_NOME' )
Local oSA2		:= FWFormStruct(2, 'SA2', { |x| AllTrim(x) $ cCampos } )
Local oFOK		:= FWFormStruct(2, 'FOK', { |x| AllTrim(x) $ 'FOK_CODIGO' } )

oView := FWFormView():New()

oFOK:AddField(	"FOK_DESCR", "05", STR0005, STR0006, {}, "C", "@!", ;//"Descrição" "Detalhamento do tipo de imposto"
				/*bPictVar*/, /*cLookUp*/, .F./*lCanChange*/,/*cFolder*/, ;
				/*cGroup*/, /*aComboValues*/, /*nMaxLenCombo*/,/*cIniBrow*/,;
				.T., /*cPictVar*/, /*lInsertLine*/ )
				
oFOK:SetProperty('FOK_CODIGO', MVC_VIEW_LOOKUP, { || FN024FF3("FOK_CODIGO") } )

oView:SetModel(oModel)
oView:showUpdateMsg(.F.)
oView:showInsertMsg(.F.)
oView:AddField( 'FORMSA2', oSA2, 'SA2MASTER' )
oView:AddGrid( 'FORMFOK', oFOK, 'FOKTIPRET' )

oSA2:SetNoFolder()

oView:CreateHorizontalBox( 'BOXFORMSA2', 16)
oView:CreateHorizontalBox( 'BOXFORMFOK', 84)

oView:SetOwnerView('FORMFOK','BOXFORMFOK')
oView:SetOwnerView('FORMSA2','BOXFORMSA2')

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

Local oModel	:= MPFormModel():New( 'FINA024FOR', /*Pre*/, /*Pos*/, { || FN024FGrv() } /*Commit*/ )
Local cCampos	:= If( IsInCallStack("F024FExAut"), 'A2_FILIAL, A2_COD, A2_LOJA', 'A2_FILIAL, A2_COD, A2_LOJA, A2_NOME' )
Local oSA2		:= FWFormStruct( 1, 'SA2', { |x| ALLTRIM(x) $ cCampos } )
Local oFOK		:= FWFormStruct( 1, 'FOK',  )

oModel:AddFields( 'SA2MASTER', , oSA2 )

oFOK:AddField(	STR0005,;																// [01] Titulo do campo "Descrição"
				STR0006,;																// [02] ToolTip do campo 	"Detalhamento do tipo de retenção"
				"FOK_DESCR",;															// [03] Id do Field
				"C"	,;																	// [04] Tipo do campo
				40,;																	// [05] Tamanho do campo
				0,;																		// [06] Decimal do campo
				{ || .T. }	,;															// [07] Code-block de validação do campo
				{ || .T. }	,;															// [08] Code-block de validação When do campo
				,;																		// [09] Lista de valores permitido do campo
				.F.	,;																	// [10]	Indica se o campo tem preenchimento obrigatório
				FWBuildFeature(STRUCT_FEATURE_INIPAD, "F024FDRet('FOK_DESCR', 2)") ,;	// [11] Inicializador Padrão do campo
				,; 																		// [12] 
				,; 																		// [13] 
				.T.	) 																	// [14] Virtual

oFOK:AddTrigger("FOK_CODIGO", "FOK_DESCR", { || .T.}, { || F024FDRet("FOK_DESCR", 1) })

oSA2:SetProperty( 'A2_COD', MODEL_FIELD_WHEN, { || .F. } )
oSA2:SetProperty( 'A2_LOJA', MODEL_FIELD_WHEN, { || .F. } )

If !IsInCallStack("F024FExAut")
	oSA2:SetProperty( 'A2_NOME', MODEL_FIELD_WHEN, { || .F. } )
	oSA2:SetProperty( 'A2_NOME', MODEL_FIELD_OBRIGAT, .F. )
EndIf

oSA2:SetProperty( 'A2_COD', MODEL_FIELD_OBRIGAT, .F. )
oSA2:SetProperty( 'A2_LOJA', MODEL_FIELD_OBRIGAT, .F. )


oFOK:SetProperty( 'FOK_FORNEC', MODEL_FIELD_OBRIGAT, .F. )
oFOK:SetProperty( 'FOK_LOJA', MODEL_FIELD_OBRIGAT, .F. )

oModel:addGrid( 'FOKTIPRET', 'SA2MASTER', oFOK, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, /*bLoad*/ )

oModel:GetModel( 'FOKTIPRET'):SetUniqueLine( { 'FOK_FILIAL', 'FOK_FORNEC', 'FOK_LOJA', 'FOK_CODIGO' } )

oModel:SetRelation('FOKTIPRET', { { 'FOK_FILIAL', 'xFilial("FOK")' }, { 'FOK_FORNEC', 'A2_COD' }, { 'FOK_LOJA', 'A2_LOJA' } }, FOK->(IndexKey(1)) )

oModel:SetPrimaryKey( { 'A2_FILIAL', 'A2_COD', 'A2_LOJA' } )

oModel:GetModel('SA2MASTER'):SetDescription(STR0007) //STR0007'Fornecedor'
oModel:GetModel('SA2MASTER'):SetOnlyQuery( .T. )

//Define uma linha única para a grid
oModel:GetModel("FOKTIPRET"):SetUniqueLine({"FOK_CODIGO"})
oModel:GetModel("FOKTIPRET"):SetDelAllLine(.T.)
oModel:GetModel("FOKTIPRET"):SetOptional(.T.)

oModel:GetModel('FOKTIPRET'):SetDescription(STR0008) // 'Tipo de Retenção'

oModel:SetActivate( { |oModel| F024FInfo( oModel ) } )

Return oModel

//-----------------------------------------------------------------------------
/*/ {Protheus.doc} FN024FGrv
Gravação do modelo de dados.

@author rodrigo.pirolo	
@since  22/09/2017
@version 12
/*/	
//-----------------------------------------------------------------------------

Function FN024FGrv()

Local oModel	:= FWModelActive()

Local nX		:= 0

cOldFor	:= oModel:GetXMLData( , , , , , .T. )	//GetXMLData( lDetail, nOperation, lXSL, lVirtual, lDeleted, lEmpty, lDefinition, cXMLFile, lPK, lPKEncoded, aFilterFields, lFirstLevel, lInternalID ) 

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

Function F024FDRet( cField, nProperty )

Local nOper		:= 0

Local cCodigo	:= ""
Local cRet		:= ""

Local oModel	:= NIL

DEFAULT cField		:= " "
DEFAULT nProperty	:= 1

oModel	:= FWModelActive()
nOper	:= oModel:GetOperation()
cRet	:= If(nProperty == 1 .And. !Empty(cField), oModel:GetValue("FOKTIPRET", cField), " " )

If nProperty == 2
	If nOper == MODEL_OPERATION_INSERT
		cRet := ""
	ElseIf nOper == MODEL_OPERATION_UPDATE
		
		If Empty(cOldFor) .AND. !(FWIsInCallStack("ADDLINE"))
			
			If FOK->FOK_FORNEC <> SA2->A2_COD
				cRet := ""
			Else
				cRet := Posicione( "FKK", 3, xFilial("FKK") + "1" + FOK->FOK_CODIGO, "FKK_DESCR" )//
				If Empty(cRet)
					cRet := Posicione( "FKK", 3, xFilial("FKK") + "2" + FOK->FOK_CODIGO, "FKK_DESCR" )//
				EndIf
			EndIf 
		ElseIf FWIsInCallStack("ADDLINE")
			cRet := ""
		EndIf
	ElseIf nOper == MODEL_OPERATION_VIEW
		cRet := Posicione( "FKK", 3, xFilial("FKK") + "1" + FOK->FOK_CODIGO, "FKK_DESCR" )//
		If Empty(cRet)
			cRet := Posicione( "FKK", 3, xFilial("FKK") + "2" + FOK->FOK_CODIGO, "FKK_DESCR" )//
		EndIf
	EndIf
ElseIf (nProperty == 1 .Or. nOper != MODEL_OPERATION_INSERT)
	cCodigo := oModel:GetValue("FOKTIPRET", "FOK_CODIGO")	
	
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

Function FN024FLine()

Local oModel	:= FWModelActive()
Local oMdlSA2	:= oModel:GetModel("SA2MASTER")
Local oMdlFOK	:= oModel:GetModel("FOKTIPRET")

Local lRet		:= .T.

If !Empty( oMdlSA2:GetValue("A2_COD") )
	oMdlFOK:LoadValue("FOK_FORNEC", oMdlSA2:GetValue("A2_COD") )
	oMdlFOK:LoadValue("FOK_LOJA", oMdlSA2:GetValue("A2_LOJA") )
EndIf

Return lRet

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} F024FOK
 
@author rodrigo.pirolo
@since 26/09/2017
@version V12
/*/
//--------------------------------------------------------------------------------------

Function FN024FOK( lDeleta )

Local oModel:= NIL

Local nX	:= 0

Local lRet	:= .F.

Default lDeleta	:= .F.

If TableInDic('FOK')
	cOldFor := Iif(Type("cOldFor") == 'U', "" , cOldFor)
	
	If !Empty(cOldFor)
		If !lDeleta
			oModel := FWLoadModel("FINA024FOR")
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
		ElseIf lDeleta
			oModel := FWLoadModel("FINA024FOR")
			oModel:SetOperation( MODEL_OPERATION_DELETE )
		EndIf
		
		oModel:Activate()
		oModel:LoadXMLData( cOldFor )
				
		If oModel:VldData()
			lRet := FWFormCommit( oModel )
		EndIf
		
		oModel:Deactivate()
		oModel:Destroy
		oModel := NIL
		cOldFor := ""
	
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

Function F024FInfo( oModel )

Local oSubSA2	:= oModel:GetModel("SA2MASTER")
Local lRet		:= .T.
Local aArea		:= GetArea()

If Empty(cOldFor) .AND. (oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
	If FwIsInCallStack("F024FExAut")
		oSubSA2:LoadValue( "A2_COD",	SA2->A2_COD		)
		oSubSA2:LoadValue( "A2_LOJA",	SA2->A2_LOJA	)
	Else
		oSubSA2:LoadValue( "A2_COD",	M->A2_COD	)
		oSubSA2:LoadValue( "A2_LOJA",	M->A2_LOJA	)
		oSubSA2:LoadValue( "A2_NOME",	M->A2_NOME	)
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

Function FN024FF3( cCmpF3 )

Local cF3	:= ''

DEFAULT cCmpF3	:= ""

cF3		:=	""

If cCmpF3 $ 'FOK_CODIGO'
	cF3 :=	"FKK"
EndIf

Return cF3

//-------------------------------------------------------------------
/*/{Protheus.doc} F986ExAut
Funcao para carregar o model quando a inclusão do título for via execauto

@since  28/09/2017
@version P12
/*/
//-------------------------------------------------------------------

Function F024FExAut( aRotAuto, aRAutoFOK, nOpca )

Local cIdDoc 	:= ""
Local cChave 	:= ""
Local oModel	:= Nil
Local oSubSA2	:= Nil
Local oSubFOK	:= Nil
Local nPos		:= 1
Local nPosFOK	:= 1
Local nTotFOK	:= Len(aRAutoFOK)
Local nPosCod	:= 0
Local nPosFor	:= 0
Local nPosLoj	:= 0
Local lRet		:= .T.
Local lAlt		:= nOpca == MODEL_OPERATION_UPDATE
Local lNewLin	:= .F.

If nOpca <>  MODEL_OPERATION_VIEW
	
	If nOpca == MODEL_OPERATION_UPDATE
	
		cChave := SA2->A2_COD + SA2->A2_LOJA
		
		FOK->( DBSetOrder(1) )
		FOK->( DBSeek(xFilial("FOK") + cChave ) )
	EndIf
	
	If lRet
		oModel := FwLoadModel("FINA024FOR")
		oModel:SetOperation( nOpca )
		oModel:Activate()
		
		oSubSA2 := oModel:GetModel("SA2MASTER")
		oSubFOK := oModel:GetModel("FOKTIPRET")
		
		If nOpca <> MODEL_OPERATION_DELETE
		
			If nOpca == MODEL_OPERATION_INSERT
				oSubSA2:LoadValue( "A2_COD",	SA2->A2_FILIAL	)
				oSubSA2:LoadValue( "A2_COD",	SA2->A2_COD		)
				oSubSA2:LoadValue( "A2_LOJA",	SA2->A2_LOJA	)
			
				For nPos := 1 to nTotFOK
					nPosCod := aScan( aRAutoFOK[nPos], { |x| UPPER(AllTrim(x[1])) == "FOK_CODIGO" } )
					lNewLin := .F.
					For nPosFOK := 1 To Len(aRAutoFOK[nPos])
						
						oSubFOK:SetValue( aRAutoFOK[nPos][nPosFOK][1], aRAutoFOK[nPos][nPosFOK][2] )
						
					Next nPosFOK
					
					If oSubFOK:VldData()
						If nPos < nTotFOK
							oSubFOK:AddLine()
						EndIf
					Else
						lRet := .F.
					EndIf
					
				Next nPos
				
			ElseIf nOpca == MODEL_OPERATION_UPDATE
				
				For nPos := 1 To oSubFOK:Length()
					oSubFOK:GoLine(nPos)
					If !oSubFOK:IsDeleted()
						oSubFOK:DeleteLine()
					EndIf
				Next nPos
				
				For nPos := 1 To nTotFOK
					nPosFor := aScan( aRAutoFOK[nPos], { |x| UPPER(AllTrim(x[1])) == "FOK_FORNEC" } )
					nPosLoj := aScan( aRAutoFOK[nPos], { |x| UPPER(AllTrim(x[1])) == "FOK_LOJA" } )
					nPosCod := aScan( aRAutoFOK[nPos], { |x| UPPER(AllTrim(x[1])) == "FOK_CODIGO" } )
					
					lNewLin := .F.
					
					If !oSubFOK:SeekLine( {	{ aRAutoFOK[nPos][nPosFor][1], aRAutoFOK[nPos][nPosFor][2] },;
											{ aRAutoFOK[nPos][nPosLoj][1], aRAutoFOK[nPos][nPosLoj][2] },;
											{ aRAutoFOK[nPos][nPosCod][1], aRAutoFOK[nPos][nPosCod][2] } }, .T. )//Caso não consiga posicionar, adiciona a linha	
						oSubFOK:AddLine()
						lNewLin := .T.
					Else
						If oSubFOK:IsDeleted()
							oSubFOK:UnDeleteLine()
						EndIf
					EndIf
					
					For nPosFOK := 1 To Len(aRAutoFOK[nPos])
						If lNewLin
							oSubFOK:SetValue( aRAutoFOK[nPos][nPosFOK][1], aRAutoFOK[nPos][nPosFOK][2] )
						EndIf
					Next nPosFOK
					
					If !oSubFOK:VldData()
						lRet := .F.
					EndIf
					
				Next nPos
				
			EndIf
		EndIf	

		If lRet
			cOldFor := oModel:GetXMLData( , , , , lAlt, .T. ) 
			oModel:Deactivate()
			oModel:Destroy()
			oModel:= Nil
		EndIf
		
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN024FOK
validação do código (FOK_CODIGO)

@author Totvs Sa
@since 01/11/2017
@return Logico
/*/
//-------------------------------------------------------------------
Function FIN024FOK()
Local lRet As Logical
Local oModel As Object
Local cCodigo As Character
Local aArea As Array

oModel := FWModelActive()
cCodigo := oModel:GetValue("FOKTIPRET","FOK_CODIGO")
lRet := .F.

If !Empty(cCodigo )
	aArea := GetArea()	
	lRet := ExistCpo("FKK", "1" + cCodigo, 3)
	If lRet
		oModel:LoadValue('FOKTIPRET','FOK_IDFKK', FKK->FKK_IDRET)
	EndIf
	RestArea(aArea)
Endif

Return lRet