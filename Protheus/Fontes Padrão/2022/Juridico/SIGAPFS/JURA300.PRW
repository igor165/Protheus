#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA300.CH"

Static __cVersao := "0"
Static __lCheck  := .F.
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA300
Controle de Versão do LegalDesk

@author Glória Maria Ribeiro
@since 04/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA300()
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de controle de versão do LegalDesk

@author Glória Maria Ribeiro
@since 04/08/2022
@version 1.0
@return oModel - Modelo de dados do Controle de versão
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructOI1 := FWFormStruct( 1, "OI1" )

	oModel:= MPFormModel():New( "JURA300", /*Pre-Validacao*/, /*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oModel:AddFields( "OI1MASTER", NIL, oStructOI1, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0001 ) //"Controle de Versão LegalDesk"
	oModel:GetModel( "OI1MASTER" ):SetDescription( STR0002 ) //"Versão do LegalDesk"

	JurSetRules( oModel, 'OI1MASTER',, 'OI1' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J300ChkVer
Busca a ultima versao do legaldesk

@author Glória Maria Ribeiro
@since 04/08/2022
@version 1.0
@return cVersao - Ultima versão do LD
/*/
//-------------------------------------------------------------------
Function J300ChkVer(cChkVer)
Local lRet        := .F.
Local cQuery      := ""
Local cTmpAlias   := NIL

Default cChkVer   := "1.0.0"

Default __cVersao := "0"
Default __lCheck  := .F.

	If !__lCheck .and. FwAliasInDic('OI1')
		__lCheck := .T.
		cTmpAlias := GetNextAlias()

		cQuery += " SELECT MAX(OI1_VERSAO) VERSAO "
		cQuery += " FROM "+ RetSqlName('OI1')+" OI1"
		cQuery += " WHERE " 
		cQuery += " OI1.D_E_L_E_T_ = ' ' "

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTmpAlias, .T., .T.)

		If (cTmpAlias)->(!EOF())
			__cVersao := (cTmpAlias)->VERSAO
		Endif

		(cTmpAlias)->(DbCloseArea())
	Endif

	If __cVersao >= cChkVer
		lRet := .T.
	Endif

Return lRet
