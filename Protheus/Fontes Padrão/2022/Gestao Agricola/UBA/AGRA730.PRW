#INCLUDE "AGRA730.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA730
Programação de Embarque

@author Cleber Maldonado
@since 02/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function AGRA730()
	Local oBrowse
	Local cFilDef 		:= ""
	
	Private cUserBenf	:= A655GETUNB( )
	 
	//TODO revisar  como vai ficar processo de expedição por foi removido 
	cFilDef := " DXR_CODUNB = '" + cUserBenf + "' "
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("DXR")
	oBrowse:SetDescription(STR0001) // Programação de embarque
	If !Empty(cUserBenf)
	oBrowse:SetFilterDefault( cFilDef )
	Endif
	oBrowse:SetLocate()
	oBrowse:Activate()

Return NIL
                                                                                    

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@author Cleber Maldonado
@since 02/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0003 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.AGRA730" OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.AGRA730" OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.AGRA730" OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.AGRA730" OPERATION 5 ACCESS 0 // Excluir

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da Programação de Embarque

@author Cleber Maldonado
@since 02/11/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel := NIL
	Local oStruHEAD := FWFormStruct( 1, "DXR", {|cCampo|   AllTRim(cCampo) $ "DXR_CODCTR|DXR_ITEMCT|DXR_TIPO|DXR_QTDCTR" } )
	Local oStruGRID := FWFormStruct( 1, "DXR", {|cCampo| !(AllTRim(cCampo) $ "DXR_CODCTR|DXR_ITEMCT|DXR_TIPO|DXR_QTDCTR" ) } )

//---------------------------
// Instancia o modelo de dados
//---------------------------
	oModel:= MPFormModel():New( "AGRA730", /*Pre-Validacao*/,{ |oModel| AGR730PMod( oModel ) }, ,/*Cancel*/)
	oModel:SetDescription(STR0002) // "Modelo de Dados - Programação de Embarque"

//-------------------------------
// Adiciona a estrutura da field
//-------------------------------
	oModel:AddFields( "MDFIELDDXR", NIL, oStruHEAD, /*Pre-Validacao*/, /*Pos-Validacao*/ )

//-------------------------------
// Adiciona a estrutura da Grid
//-------------------------------
	oModel:AddGrid  ( "MDGRIDDXR", "MDFIELDDXR", oStruGRID,{ |oModelGrid, nLine, cAction, cField| AGR730VldL(oModelGrid, nLine, cAction, cField) },{|AGRA730| AGR730PLin(oModel)}, /*bPre*/, /* Pós Validação - Model */)

//--------------------
// Seta Relacionamento 
//--------------------
	oModel:SetRelation("MDGRIDDXR",{ {"DXR_FILIAL",'xFilial("DXR")'}, {"DXR_CODCTR",'DXR_CODCTR'}, {"DXR_ITEMCT",'DXR_ITEMCT'} }, DXR->(IndexKey()) )

	oModel:GetModel("MDGRIDDXR"):SetDelAllLine(.T.)

//--------------------
// Seta Chave primaria
//--------------------
	oModel:SetPrimaryKey( {"DXR_FILIAL+DXR_CODCTR+DXR_ITEMCT+STR(DXR_ANO)+STR(DXR_MES)"} )

//--------------------
// Seta linha unica
//--------------------
	oModel:GetModel( 'MDGRIDDXR' ):SetUniqueLine( { 'DXR_ANO','DXR_MES' } )

//------------------------
// Adiciona totalizadores
//------------------------
	oModel:AddCalc( 'AGRA730CALC', "MDFIELDDXR", "MDGRIDDXR", 'DXR_QTDPRG', 'DXR_TOTPRO', 'SUM', { || .T. },, STR0008 )
	oModel:AddCalc( 'AGRA730CALC', "MDFIELDDXR", "MDGRIDDXR", 'DXR_QTDEMB', 'DXR_TOTEMB', 'SUM', { || .T. },, STR0009 )


//---------------------------------
// Valida apos a Ativação do model
//---------------------------------
	oModel:SetActivate( { |oModel| A730ACTIVE( oModel ) } )
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados da Programação de Embarque

@author Cleber Maldonado
@since 02/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
	Local oView
	Local oCalc1
	Local oModel    := FWLoadModel( "AGRA730" )
	Local oStruHEAD := FWFormStruct( 2, "DXR", {|cCampo| AllTRim(cCampo) $ "DXR_CODCTR|DXR_ITEMCT|DXR_TIPO|DXR_QTDCTR" } )
	Local oStruGRID := FWFormStruct( 2, "DXR", {|cCampo| !(AllTRim(cCampo) $ "DXR_CODCTR|DXR_ITEMCT|DXR_TIPO|DXR_QTDCTR" )} )

//------------------------
// Instancia a View
//------------------------
	oView := FWFormView():New()
	oView:SetModel( oModel )

//-------------------------------------------------
// Adiciona estrutura da Field e da Grid na View
//--------------------------------------------------
	oView:AddField( "AGRA730_VHEAD", oStruHead, "MDFIELDDXR"  )
	oView:AddGrid ( "AGRA730_VGRID", oStruGrid, "MDGRIDDXR"  )
	
	if!Empty(cUserBenf)
		oStruGrid:RemoveField('DXR_CODUNB')
	endif	
//----------------------------------
// Instancia a estrutura de calculo
//----------------------------------
	oCalc1 := FWCalcStruct( oModel:GetModel( 'AGRA730CALC') )
	oView:AddField( 'VIEW_CALC', oCalc1, 'AGRA730CALC' )

//----------
// Cria box 
//----------
	oView:CreateHorizontalBox( "DXRFIELDS", 20 )
	oView:CreateHorizontalBox( "DXRGRID"  , 70 )
	oView:CreateHorizontalBox( "DXRCALC"  , 10 )

//------------
// Seta Owner
//------------
	oView:SetOwnerView( "AGRA730_VHEAD", "DXRFIELDS" )
	oView:SetOwnerView( "AGRA730_VGRID", "DXRGRID" )
	oView:SetOwnerView( 'VIEW_CALC', "DXRCALC" )

	oView:SetDescription(STR0001) // "Programação de Embarque"
	oView:EnableControlBar( .T. )

Return oView
/** ------------------------------------------------------------------------------------------
{Protheus.doc} A730ACTIVE
Validação na ativação do model

@param: oModel - Modelo de dados da rotina
@author: Joaquim Burjack
@since: 06/07/2015
@Uso: AGRA730
------------------------------------------------------------------------------------------ **/
Static Function A730ACTIVE(oModel)
Local aArea		:= GetArea()
Local lRet		:= .T.

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		//Campo Unidade de Beneficiamento
		if!Empty(cUserBenf)
			oModel:LoadValue( "MDGRIDDXR", "DXR_CODUNB", cUserBenf )
		endif
	Endif	
RestArea(aArea)	
Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} AGR730PLin()
Valida se a somatória das linhas ultrapassou a quantidade do item do contrato de parceria - vendas

@author Cleber Maldonado
@since 15/11/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function AGR730PLin(oModel)

	Local lRet 		 := .T.
	Local aSaveLines := FWSaveRows()

	If FwFldGet("DXR_QTDEMB") > FwFldGet("DXR_QTDPRG")
		Help(" ",1,"AGR730EMB")
		lRet := .F.
	Endif

	If oModel:GetValue("AGRA730CALC","DXR_TOTPRO") > DXR_QTDCTR
		Help(" ",1,"AGR730CTR")
		lRet := .F.
	Endif

	FWRestRows( aSaveLines )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AGR730VldL()
Valida exclusão da linha

@author Cleber Maldonado
@since 15/11/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function AGR730VldL(oModel, nLinha, cAcao, cCampo)
	Local lRet     := .T.

	Local aSaveLines := FWSaveRows()
	If Procname(8) == "DELLINE" .or. cAcao == "DELETE"
		If FwFldGet("DXR_QTDEMB") > 0
			Help(" ",1,"AGR730DEL")
			lRet := .F.
		Endif
	Endif

	FWRestRows( aSaveLines )
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AGR730PMod()
Valida exclusão da programação de embarque

@author Cleber Maldonado
@since 15/11/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function AGR730PMod(oModel)

	Local aSaveLines := FWSaveRows()
	Local lRet := .T.
	Local nOperation := oModel:GetOperation()
	Local nSalEmb := oModel:GetValue("AGRA730CALC","DXR_TOTEMB")

	If nOperation == 5 .and. nSalEmb > 0
		Help(" ",1,"AGR730EXCL")
		lRet := .F.
	Endif

	FWRestRows( aSaveLines )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AGR730CTR()
Valida se ja existe programação de embarque para o contrato/item

@author Cleber Maldonado
@since 19/12/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function AGR730CTR()
	Local aAreaADB := ADB->(GetArea())
	Local lRet := .T.

	DXR->(DbSetorder(1))
	ADB->(DbSetorder(1))

	If ReadVar() == "M->DXR_CODCTR" .And. IsInCallStack("GETLKRET")
		M->DXR_ITEMCT := Space(TamSX3("DXR_ITEMCT")[1])
	EndIf

	If !ADB->(DbSeek(xFilial("ADB")+M->DXR_CODCTR+IIF(!Empty(M->DXR_ITEMCT),M->DXR_ITEMCT,"")))
		lRet := .F.
		Help(" ",1,"REGNOIS")
	EndIf

	If lRet .And. DXR->(DbSeek(xFilial("DXR")+M->DXR_CODCTR+M->DXR_ITEMCT))
		lRet := .F.
		Help(" ",1,"JAGRAVADO")
	EndIf

	RestArea(aAreaADB)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AGR730DAT()
Valida os campos mês e ano de embarque programado.

@author Cleber Maldonado
@since 31/01/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function AGR730DAT()

	Local lRet := .T.

	If ReadVar() == "M->DXR_MES"
		If M->DXR_MES <1 .OR. M->DXR_MES >12
			lRet := .F.
		Endif
	Endif

	If ReadVar() == "M->DXR_ANO"
		If M->DXR_ANO <1900 .OR. M->DXR_ANO >2049
			lRet := .F.
		Endif
	Endif

Return lRet

