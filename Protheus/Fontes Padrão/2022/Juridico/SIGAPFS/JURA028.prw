#INCLUDE "JURA028.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA028
Historico Tab Honor Padrao

@author David Gonçalves Fernandes
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA028()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NVP" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NVP" )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
            [n,1] Nome a aparecer no cabecalho
            [[n,2] Nome da Rotina associada            
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
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA028", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA028", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA028", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA028", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Historico Tab Honor Padrao

@author David Gonçalves Fernandes
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA028" )
Local oStruct := FWFormStruct( 2, "NVP" )

JurSetAgrp( "NVP",, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA028_VIEW", oStruct, "NVPMASTER" )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA028_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Historico Tab Honor Padrao"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Historico Tab Honor Padrao

@author David Gonçalves Fernandes
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NVP" )

oModel:= MPFormModel():New( "JURA028", /*Pre-Validacao*/, { | oX | JA028TUDOK( oX ) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NVPMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Historico Tab Honor Padrao"
oModel:GetModel( "NVPMASTER" ):SetDescription( STR0009 ) // "Dados de Historico Tab Honor Padrao"
JurSetRules( oModel, "NVPMASTER",, "NVP",, "JURA028" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA028TUDOK
Pré-validação ao confirmar as alterações no model

@author David Gonçalves Fernandes
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA028TUDOK( oModel )
	Local lRet := .T.

	If !JA028VLDAM( oModel )
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA028VLDAM
Valida a sobreposição de períodos

@author David Gonçalves Fernandes
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA028VLDAM(oModel)
	Local lRet     := .T.
	Local cQuery   := ""
	Local cResQRY  := GetNextAlias()
	Local cMsg     := ""
	Local aArea    := GetArea()
	Local aAreaNVP := NVP->( GetArea() )
	Local cAMIni   := oModel:GetValue('NVPMASTER','NVP_AMINI')
	Local cAmFim   := oModel:GetValue('NVPMASTER','NVP_AMFIM')
	Local cRecno   := ''

	If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4

		If oModel:GetOperation() == 3
			cRecno := '-1'
		Else
			cRecno := str(NVP->(Recno()))
		EndIf

		If Empty(cAmFim)
			cQuery := " SELECT COUNT(NVP.NVP_AMINI) COUNTNVP"
			cQuery +=   " FROM "+RetSqlName("NVP")+" NVP "
			cQuery +=  " WHERE NVP.D_E_L_E_T_ = ' ' "
			cQuery +=    " AND NVP.R_E_C_N_O_ <> " + cRecno
			cQuery +=    " AND NVP.NVP_FILIAL = '" + xFilial( "NVP" ) + "' "
			cQuery +=    " AND NVP.NVP_AMFIM = ''"
	
			cQuery := ChangeQuery(cQuery)
		
			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)
	
			If (cResQRY)->COUNTNVP > 0
				lRet := .F.
				cMsg := STR0013 //"Não é permitido incluir dois históricos com ano-mês final em branco."
			EndIf
			dbSelectArea(cResQRY)
			(cResQRY)->(DbCloseArea())
		EndIf
		
		If lRet
			cQuery := " SELECT COUNT(NVP.NVP_AMINI) COUNTNVP"
			cQuery +=   " FROM " + RetSqlName("NVP") + " NVP "
			cQuery +=  " WHERE NVP.D_E_L_E_T_ = ' ' "
			cQuery +=    " AND NVP.R_E_C_N_O_ <> " + cRecno
			cQuery +=    " AND NVP.NVP_FILIAL = '" + xFilial( "NVP" ) + "' "
			cQuery +=    " AND (    '" + cAmIni + "' BETWEEN NVP.NVP_AMINI AND NVP.NVP_AMFIM  "
			cQuery +=          " OR '" + cAmFim + "' BETWEEN NVP.NVP_AMINI AND NVP.NVP_AMFIM  "
			cQuery +=          " OR  NVP.NVP_AMINI BETWEEN '" + cAmIni + "' AND '" + cAmFim + "' "
			cQuery +=          " OR  NVP.NVP_AMFIM BETWEEN '" + cAmIni + "' AND '" + cAmFim + "' "
			If Empty(cAmFim)
				cQuery +=      " OR ( '"+cAmIni+"' <= NVP.NVP_AMINI ) "
			Else
				cQuery +=      " OR ( '"+cAmFim+"' >= NVP.NVP_AMINI AND NVP.NVP_AMFIM ='' ) "
			EndIf
			
			cQuery +=        " )"
	
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)
		
			If (cResQRY)->COUNTNVP > 0
				lRet := .F.
				cMsg := STR0011 //"Não é possível incluir este período pois há sobreposição com outros períodos."
			EndIf

			dbSelectArea(cResQRY)
			(cResQRY)->(DbCloseArea())
		
		EndIf
		
		If !lRet
			JurMsgErro( cMsg )
		EndIf

	EndIf

	RestArea( aAreaNVP )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA184VLDCP
Função para validação dos campos o cadastro de cliente

@author David Gonçalves Fernandes
@since 10/11/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA028VLDCP(cCampo)
	Local lRet    := .T.
	Local cAMI    := ''
	Local cAMF    := ''
	Local cMsg    := ''

	If cCampo == 'NVP_AMFIM' .Or. cCampo == 'NVP_AMINI'

		If !Empty(FwFldGet('NVP_AMINI')) .Or. !Empty(FwFldGet('NVP_AMFIM'))
			cAMI := Substr(FwFldGet('NVP_AMINI'), 5, 2)
			cAMF := Substr(FwFldGet('NVP_AMFIM'), 5, 2)
			If (cAMI = '00' .Or. cAMI > '12') .Or. (cAMF = '00' .Or. cAMF > '12')
				lRet := .F.
				cMsg := STR0014  // Mês inválido
			EndIf
		EndIf
		
		If lRet .And. !Empty(FwFldGet('NVP_AMFIM')) .And. !Empty(FwFldGet('NVP_AMINI'))
			lRet := ( FwFldGet('NVP_AMINI') <= FwFldGet('NVP_AMFIM') )
			cMsg := STR0010//"O ano-mês final deve ser maior do que o inicial"
		EndIf

		If lRet .And. FwFldGet('NVP_AMINI') > AnoMes(MsDate())
			cMsg := STR0012 // "Não é permitido gravar histórico futuros"
			lRet := .F.
		EndIf
		If lRet .And. !Empty(FwFldGet('NVP_AMFIM')) .And. FwFldGet('NVP_AMFIM') > AnoMes(MsDate())
			cMsg := STR0012 // "Não é permitido gravar histórico futuros"
			lRet := .F.
		EndIf

	EndIf

	If !lRet
		JurMsgErro( cMsg )
	EndIf

Return lRet
