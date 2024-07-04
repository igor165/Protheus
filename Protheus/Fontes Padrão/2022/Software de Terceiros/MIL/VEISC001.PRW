////////////////
// Versao 02  //
////////////////

#include "Protheus.ch"
#include "tbiconn.ch"
#include "VEISC001.CH"

/*/{Protheus.doc} VEISC001

	@author       Vinicius Gati
	@since        04/02/2015
	@description  Job de alteração de grupo de produto
/*/
Function VEISC001(aParams)
	Private lMenu := (VALTYPE(aParams) == "U")
	if !lMenu
		nModulo := 11
		cModulo := "VEI"
		__cInternet := 'AUTOMATICO'

		cEmpr   := aParams[1]
		cFil    := aParams[2]

		If Type("cArqTab")=="U"
		 cArqTab:=""
		EndIf

		cFOPENed := ""

		DbCloseAll()
		Prepare Environment Empresa cEmpr Filial cFil Modulo cModulo
	EndIf
	//
	If lMenu
		Alert(STR0005) //'Iniciando ajuste dos grupos de produtos'
	EndIf
	
	lOk := VSC001RGRV()
	
	If lMenu
		if lOk
			Alert(STR0006) //Ajuste do grupo de produtos finalizado com sucesso.
		Else
			Alert(STR0007) //Ocorreu um erro ao alterar o produto, favor verificar o log e entrar em contato com suporte.
		Endif
	EndIf
	//
	conout(STR0003) // Terminou!
Return .T.

/*/{Protheus.doc} VSC001RGRV

	@author       Vinicius Gati
	@since        04/02/2015
	@description  Regrava as alterações de grupo em modo exclusivo para ajuste de registros que podem ter sido executados apos update do grupo
/*/
Static Function VSC001RGRV()
Local cQuery          := ""
Local cAlias          := "SQLVR2"
Local cFilSALVA       := cFilAnt 
Local oLogger         := Mil_Logger():New('SCHEDULE_MUDANCA_B1_GRUPO.log')
conout(STR0004) // Iniciando alterações
cQuery := "SELECT R_E_C_N_O_ RECVR2 FROM " + RetSqlName('VR2') + " WHERE VR2_FILIAL = '" + xFilial('VR2') + "' AND VR2_STATUS = '0' AND D_E_L_E_T_ = ' ' ORDER BY VR2_CODIGO"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAlias, .F., .T. )
While !(cAlias)->(EOF())
	DbSelectArea("VR2")
	DbGoTo((cAlias)->( RECVR2 ))
	cFilAnt  := VR2->VR2_FILANT
	// manda regravar o grupo
	oPecDAO  := DMS_Peca():New()
	nErrCode := oPecDAO:UpdateGroup( VR2->VR2_CODSB1 , VR2->VR2_CODITE , VR2->VR2_GRUANT , VR2->VR2_GRUNOV , VR2->(RecNo()) )
	cFilAnt  := cFilSALVA //Retorna Cache
	If nErrCode == 0 // tudo ok
		cLogMessage :=	"SCHEDULE: B1_CODITE: " + VR2->VR2_CODITE + " B1_GRUPO:  " + VR2->VR2_GRUANT + STR0001 + " B1_GRUPO: " + VR2->VR2_GRUNOV
		conout(cLogMessage)
		oLogger:Log({'TIMESTAMP', cLogMessage})
	Else 
		cLogMessage := STR0002 +" "+ Alltrim(str(nErrCode)) + " RECNO VR2: " + Alltrim(str((cAlias)->( RECVR2 ))) // #####ERRO##### Um erro ocorreu ao tentar alterar o grupo, código do erro:
		conout(cLogMessage)
		oLogger:Log({'TIMESTAMP', cLogMessage})
		(cAlias)->(dbCloseArea())
		Return .F.
	EndIf
	(cAlias)->(DbSkip())
End
(cAlias)->(dbCloseArea())
Return .T.