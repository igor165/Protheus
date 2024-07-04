#INCLUDE "JURA075.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA075
Exc. Numeração Fat

@author David Gonçalves Fernandes
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA075()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NSE" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NSE" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author David Gonçalves Fernandes
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA075", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA075", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA075", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA075", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA075", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Exc. Numeração Fat

@author David Gonçalves Fernandes
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA075" )
Local oStruct := FWFormStruct( 2, "NSE" )

JurSetAgrp( 'NSE',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA075_VIEW", oStruct, "NSEMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA075_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Exc. Numeração Fat"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Exc. Numeração Fat

@author David Gonçalves Fernandes
@since 12/05/09
@version 1.0

@obs NSEMASTER - Dados do Exc. Numeração Fat

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NSE" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA075", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NSEMASTER", NIL, oStruct, /*Pre-Validacao*/,{|oX| JA075TUDOK(oX)} /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Exc. Numeração Fat"
oModel:GetModel( "NSEMASTER" ):SetDescription( STR0009 ) // "Dados de Exc. Numeração Fat"

JurSetRules( oModel, 'NSEMASTER',, 'NSE' )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} JA075TUDOK(oModel)

@author David Gonçalves Fernandes
@since 22/09/09

/*/
//-------------------------------------------------------------------
function JA075TUDOK(oModel)
	Local cResQRY  := GetNextAlias()
	Local aArea    := GetArea()
	Local lRet := .T.
	Local cQuery := ""
	Local cCodigo := oModel:GetValue('NSE_COD')
	Local nNumIni := oModel:GetValue('NSE_NUMINI')
	Local nNumFin := oModel:GetValue('NSE_NUMFIN')
	Local cEscrit := oModel:GetValue('NSE_CESC')

	If  nNumFin < nNumIni
  		jurmsgErro(STR0010)
  		lRet := .F.
	Else

		cQuery := "  SELECT COUNT(NSE.NSE_COD) COUNT "
		cQuery += "	   FROM "+ RetSqlName( "NSE" )   +" NSE   "
		cQuery += "	  WHERE NSE.NSE_FILIAL  = '" + xFilial( "NSE" ) + "' "
		cQuery += "	    AND NSE.NSE_CESC = '" + cEscrit + "' "
		cQuery += "	    AND NSE.NSE_COD <> '" + cCodigo + "' "
		cQuery += "	  	 AND (('"+ nNumIni+"' BETWEEN NSE_NUMINI AND NSE_NUMFIN "
		cQuery += "	  	 OR   '"+ nNumFin +"' BETWEEN NSE_NUMINI AND NSE_NUMFIN)"
		cQuery += "	  	 OR  (NSE_NUMINI BETWEEN '" + nNumIni + "' AND '" + nNumFin + "' "
		cQuery += "	  	 OR   NSE_NUMFIN BETWEEN '" + nNumIni + "' AND '" + nNumFin + "' )) "
		cQuery += "	    AND NSE.D_E_L_E_T_  = ' '"

		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cResQRY,.T.,.T.)

			If ((cResQRY)->COUNT > 0 )
		  		lRet := .F.
			  	JurMsgErro(STR0011) // "O intervalo já está contido em outra faixa"
			EndIf

	 	(cResQRY)->(DbCloseArea())

	EndIf

	RestArea( aArea )

Return lRet