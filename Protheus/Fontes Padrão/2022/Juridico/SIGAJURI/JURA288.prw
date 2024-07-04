#include "Protheus.ch"
#include "FwMVCDef.ch"
#include "jura288.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} JURA288
Fonte responsavel pelo cadastro e manutenção da Gestão de relatórios Totvs Legal
( Função de referência no X2_SYSOBJ da Tabela O17. )

@since 07/01/2021
@version 1.0
/*/
//------------------------------------------------------------------------------
Function JURA288()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //'Gestão de relatórios'
oBrowse:SetAlias( "O17" )
oBrowse:SetLocate()
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@author 
@since 07/01/2021
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrO17	:= FWFormStruct(1,'O17')

oModel := MPFormModel():New('JURA288', /*bPreValidacao*/,  /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('O17MASTER',/*cOwner*/,oStrO17,/*bPre*/,/*bPos*/,/*bLoad*/)

oModel:SetDescription(STR0001)//'Gestão de relatórios'

oModel:GetModel('O17MASTER'):SetDescription(STR0001)	//'Gestão de relatórios' 

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} J288GestRel
Função responsavel para manipular o registro
@since 07/01/2021
@version 1.0
@param oJsonRel, json, Objeto json contendo os dados para serem inseridos ou atualizados
@return nRecno, return_description
/*/
//------------------------------------------------------------------------------
Function J288GestRel(oJsonRel)
Local aArea      := GetArea()
Local lInsert    := .T.
Local lOk        := .T.
Local nO17Perc   := 0

Default oJsonRel := J288JsonRel()

	DbSelectArea('O17')

	If oJsonRel['O17RECNO'] <> 0
		lInsert := .F.
		O17->(DbGoTo(oJsonRel['O17RECNO']))
		lOk := O17->(Recno()) == oJsonRel['O17RECNO']
	Endif

	If lOk

		// KillApp (Cancela thread)
		If !lInsert .AND. O17->O17_STATUS == '3'
			RpcClearEnv()
			KillApp(.T.)
		Endif
		
		nO17Perc := Iif(VALTYPE(oJsonRel['O17_PERC']) == 'N', oJsonRel['O17_PERC'], val(oJsonRel['O17_PERC']))

		RecLock('O17',lInsert)
			
			O17->O17_FILIAL := oJsonRel['O17_FILIAL']
			O17->O17_CODIGO := oJsonRel['O17_CODIGO']
			O17->O17_CODUSR := oJsonRel['O17_CODUSR']
			O17->O17_FILE   := oJsonRel['O17_FILE']  
			O17->O17_DESC   := oJsonRel['O17_DESC']  
			O17->O17_MIN    := oJsonRel['O17_MIN']   
			O17->O17_MAX    := oJsonRel['O17_MAX']   
			O17->O17_PERC   := Round( Iif( nO17Perc > 100 , 100, nO17Perc), 0)
			O17->O17_STATUS := oJsonRel['O17_STATUS']
			O17->O17_DATA   := Date()
			O17->O17_HORA   := Time()
			O17->O17_URLDWN := oJsonRel['O17_URLDWN']
			O17->O17_URLREQ := oJsonRel['O17_URLREQ']
			O17->O17_BODY   := oJsonRel['O17_BODY']  

		O17->(MsUnLock())
		
		oJsonRel['O17RECNO'] := O17->(Recno())

		If __lSX8
			ConfirmSX8()
		Else
			RollBackSX8()
		EndIf

	Endif

	RestArea(aArea)

Return oJsonRel

//------------------------------------------------------------------------------
/* /{Protheus.doc} J288JsonRel
@since 07/01/2021
@version 1.0
@return oJsonRel, objeto json com as propriedades básicas
/*/
//------------------------------------------------------------------------------
Function J288JsonRel()
Local oJsonRel := JsonObject():New()

	oJsonRel['O17_FILIAL'] := FWxFilial('O17')
	oJsonRel['O17_CODIGO'] := GetSxeNum('O17','O17_CODIGO')
	oJsonRel['O17_CODUSR'] := __CUSERID
	oJsonRel['O17_FILE']   := ""
	oJsonRel['O17_DESC']   := STR0002// "Preparando o arquivo"
	oJsonRel['O17_MIN']    := 0
	oJsonRel['O17_MAX']    := 0
	oJsonRel['O17_PERC']   := 0
	oJsonRel['O17_STATUS'] := '0' // em andamento
	oJsonRel['O17_URLDWN'] := ''
	oJsonRel['O17_URLREQ'] := ''
	oJsonRel['O17_BODY']   := ''
	oJsonRel['O17RECNO']   := 0

Return oJsonRel

//------------------------------------------------------------------------------
/* /{Protheus.doc} J288ChkRel
Função responsável por filtrar registros com erro ou cancelados pelo usuário

@since 16/08/2021
/*/
//------------------------------------------------------------------------------
Function J288ChkRel()

Local aArea   := GetArea()
Local cAlias  := GetNextAlias()
Local oJson   := JsonObject():new()
Local cQuery  := ""

	cQuery := " SELECT R_E_C_N_O_ O17RECNO, "
	cQuery +=        " O17_STATUS O17_STATUS "
	cQuery += " FROM "+ RetSqlName("O17") + " O17 "
	cQuery += " WHERE O17.O17_FILIAL = '" + xFilial("O17") + "' "
	cQuery +=     " AND O17.O17_STATUS NOT IN ('2')"
	cQuery +=     " AND O17.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		DbSelectArea("O17")

		While !(cAlias)->(EOF())

			O17->( dbGoTo((cAlias)->O17RECNO) )

			If O17->O17_STATUS <> '2' .And. !Empty(O17->O17_BODY)
				oJson:fromJson(O17->O17_BODY)
				If ValType(oJson["cIdThredExec"]) <> "U" .and. !Empty(oJson["cIdThredExec"])
					If LockByName(oJson["cIdThredExec"], .T., .T.)
						O17->(RecLock("O17", .F.))
							If (cAlias)->O17_STATUS == '3'
								O17->O17_DESC := STR0003 // "Geração cancelada pelo usuário"
							Else
								O17->O17_STATUS := '1' // erro
								O17->O17_DESC := STR0004 // "Erro na geração do arquivo"
							EndIf
							O17->O17_PERC := 100
						O17->(MsUnlock())
						UnLockByName(oJson["cIdThredExec"], .T., .T.)
					EndIf
				Endif

			EndIf
			(cAlias)->(DbSkip())
		End

	(cAlias)->(DbCloseArea())
	O17->(DbCloseArea())
	RestArea(aArea)

Return

