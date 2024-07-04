// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 02     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼ 
#Include "PROTHEUS.CH"
#include "fileio.ch"
#include "OFINJD26.CH"

/*/{Protheus.doc} OFINJD26

Rotina de processamento responsável por atualizar o status das solicitações de garantia com o status do portal da John Deere

@author Rubens
@since 24/07/2015
@version 1.0

/*/
Function OFINJD26()

Local oTProces
Local cPerg := "OFINJD26"
Local cMsg

Private cVMBStat := "'04','05','06','07','08','12','15'"

cMsg := STR0002 + OFNJD26STRING() + "."

CriaSX1(cPerg)

oTProces := tNewProcess():New(;
/* 01 */				"OFINJD26",;
/* 02 */				STR0001,;
/* 03 */				{ |oSelf| OFNJD26PROC(oSelf) },;
/* 04 */				cMsg,;
/* 05 */				cPerg ,;
/* 06 */				/* aInfoCustom */ ,;
/* 07 */				.t. /* lPanelAux */ ,;
/* 08 */				/* nSizePanelAux */ ,;
/* 09 */				/* cDescriAux */ ,;
/* 10 */				.t. /* lViewExecute */ ,;
/* 11 */				.t. /* lOneMeter */ )

Return()

/*/{Protheus.doc} OFNJD26PROC

Processa atualizacao dos status da Solicitacoes de Garantia

@author Rubens
@since 24/07/2015
@version 1.0
@param oTProces, objeto, Objeto do tipo TNewProcess

/*/
Static Function OFNJD26PROC(oTProces)

Local cSQL := ""
Local cTMPVMB := "TVMB"
Local oWS // Instancia da Classe de WebService da John Deere
Local lJaProc := .f.
Local nCont

If !MsgYesNo(STR0005) // "Confirma atualização?"
	Return
EndIf

cSQL +=  " FROM " + RetSQLName("VMB") + " VMB "
cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "'"
cSQL +=   " AND VMB_NUMOSV BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cSQL +=   " AND VMB_STATUS NOT IN (" + cVMBStat + ")"
cSQL +=   " AND VMB_STATSG NOT IN ('2','5')"
cSQL +=   " AND VMB.D_E_L_E_T_ = ' '"

nCont := FM_SQL( "SELECT COUNT(*) " + cSQL )
If nCont == 0
	MsgInfo(STR0006,STR0007) // "Não existem registros para processar."
	Return
EndIf

oTProces:SetRegua1( nCont )

oWS := WSJohnDeere_Garantia():New("RetrieveClaim")
//oWS:SetDebug(.f.)

cSQL := "SELECT R_E_C_N_O_ VMBRECNO " + cSQL + " ORDER BY VMB_NUMOSV, VMB_REPARO "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cTMPVMB , .F., .T. )
DbSelectArea("VMB")
While !(cTMPVMB)->(Eof())

	VMB->(DbGoTo((cTMPVMB)->VMBRECNO))

	oTProces:IncRegua1(VMB->VMB_NUMOSV + "-" + VMB->VMB_REPARO)

	oWS:oRetrieveClaim_INPUT:cDEALERACCOUNT := AllTrim(VMB->VMB_DEALER)
	oWS:oRetrieveClaim_INPUT:cWO  := AllTrim(VMB->VMB_NUMOSV)
	oWS:oRetrieveClaim_INPUT:cSEG := AllTrim(VMB->VMB_REPARO)
	
	If !oWS:RetrieveClaim()
		(cTMPVMB)->(dbSkip())
		Loop
	EndIf
	
	If oWS:oOUTPUT:oSUCCESS:cTYPE $ "E/X"
		(cTMPVMB)->(dbSkip())
		Loop
	EndIf

	If oWS:oOUTPUT:oSUCCESS:cTYPE == "S"
	
		lJaProc := .f.
		// Se retornar mais de uma SG, verifica se existe alguma com status APROVADO (03) / AGUARDANDO NF (09) / NF ATUALIZADA (12)
		// por algum motivo, algumas SG's ficaram duplicadas no portal ...
		If Len(oWS:oOUTPUT:oCLAIM) > 1
			For nCont := 1 to Len(oWS:oOUTPUT:oCLAIM)
				If oWS:oOUTPUT:oCLAIM[nCont]:cSTATUS $ "03/09/12"
					OFNJD15GST(oWS:oOUTPUT:oCLAIM[nCont])
					lJaProc := .t.
					Exit
				EndIf
			Next nCont
		EndIf
		//
		
		If !lJaProc
			For nCont := 1 to Len(oWS:oOUTPUT:oCLAIM)
				OFNJD15GST(oWS:oOUTPUT:oCLAIM[nCont])
			Next nCont
		EndIf

	EndIf

	(cTMPVMB)->(dbSkip())
End
(cTMPVMB)->(dbCloseArea())

oWS := NIL

MsgInfo(STR0008,STR0007) // "Solicitações atualizadas"

Return

/*/{Protheus.doc} OFNJD26STRING

Monta string com os status que serao processados

@author Rubens
@since 24/07/2015
@version 1.0

/*/
Static Function OFNJD26STRING()

Local cSQL
Local cAliasVX5 := "TVX5"
Local cMSG := ""

cSQL := "SELECT VX5_CODIGO, VX5_DESCRI"
cSQL +=  " FROM " + RetSQLName("VX5") + " VX5 "
cSQL += " WHERE VX5.VX5_FILIAL = '" + xFilial("VX5") + "'"
cSQL +=   " AND VX5.VX5_CHAVE = '016'"
cSQL +=   " AND VX5.VX5_CODIGO NOT IN (" + cVMBStat + ")"
cSQL +=   " AND VX5.D_E_L_E_T_ = ' '"
cSQL += " ORDER BY VX5_CODIGO"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVX5 , .F., .T. )
While !(cAliasVX5)->(Eof())
	cMSG += ALlTrim((cALiasVX5)->VX5_CODIGO) + "-" + AllTrim((cAliasVX5)->VX5_DESCRI) + ", "
	(cAliasVX5)->(dbSkip())
End
(cAliasVX5)->(dbCloseArea())

cMSG := Left(cMSG, Len(cMSG) - 2 )

Return cMSG


/*/{Protheus.doc} CriaSX1

Cria pergunte com parametros da rotina

@author Rubens
@since 24/07/2015
@version 1.0
@param cPerg, character, Nome do grupo de pergunta que sera acriado

/*/
Static Function CriaSX1(cPerg)

Local aRegs := {}

AADD(aRegs,{STR0003,STR0003,STR0003,'MV_CH1','C',8,0,,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{"Informe o numero de ordem de serviço"," inicial."},{},{}})
AADD(aRegs,{STR0004,STR0004,STR0004,'MV_CH2','C',8,0,,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{"Informe o numero de ordem de serviço"," final."},{},{}})

FMX_AJSX1(cPerg,aRegs)

Return