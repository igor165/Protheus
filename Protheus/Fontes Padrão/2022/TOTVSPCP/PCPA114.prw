#INCLUDE "PROTHEUS.CH"
#Include "PCPA114.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA114

Programa de envia as Ordens de Produção do APS com o PCFactory.

@author  Michelle Ramos Henriques
@version P12
@since   23/10/2017
/*/
//-------------------------------------------------------------------------------------------------
Function PCPA114()
	Local cIntgPPI  := "0"

	//Validação da integração ativa ou não. Só deixa processar se a integração estiver ativa.
	If !PCPIntgPPI()
		//CONOUT(STR0002) //"Integração com o PCFactory desativada. Processamento não permitido.", "Atenção"
		Return .F.
	EndIf

	//Valida se haverá integração das ordens de produção do APS com o PCFactory
	If FindFunction("PCPIntgAPS")
		cIntgPPI := PCPIntgAPS()
	EndIf

	If (cIntgPPI == "0")
		//CONOUT(STR0001) //"Integração de ordem do APS não está ativa no PCPA109. Processamento não permitido.", "Atenção"
		Return .F.
	EndIf

	If processar() == .T. 
		Return .T.
	Else
		Return .F. 
	EndIf

Return Nil


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Processar

Função principal de processamento dos dados.

@author  Michelle RAmos Henriques
@version P12
@since   23/10/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function Processar()
	Local cAliasTop := GetNextAlias()
	Local cBanco    := Upper(TcGetDb())
	Local cQuery    := ""

	dbSelectArea("SC2")
	SC2->(dbSetOrder(1))

	dbSelectArea("SHY")
	SHY->(dbSetOrder(1))

	cQuery := " SELECT DISTINCT SC2.R_E_C_N_O_ RECTAB " 
	cQuery += " FROM " + RetSqlName("SC2") + " SC2, " + RetSqlName("SHY") + " SHY" 
	cQuery += " WHERE SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
	cQuery += " AND (SC2.C2_IDAPS <> ' ' "
	cQuery += " AND  SC2.C2_IDAPS IS NOT NULL) " 
	cQuery += " AND SC2.D_E_L_E_T_ = ' ' " 
	cQuery += " AND SHY.HY_FILIAL = '" + xFilial("SHY") + "' "
	cQuery += " AND SHY.HY_OP      = (C2_NUM+C2_ITEM+C2_SEQUEN) "  
	cQuery += " AND SHY.D_E_L_E_T_ = ' ' "
	cQuery += " AND (NOT EXISTS (SELECT DISTINCT SOJ.R_E_C_N_O_  "
	cQuery += "                    FROM " + RetSqlName("SOJ") + " SOJ" 
	cQuery += "                   WHERE SOJ.OJ_FILIAL  = '" + xFilial("SOJ") + "' "
	cQuery += "                     AND SOJ.OJ_NUM     = SC2.C2_NUM "
	cQuery += "                     AND SOJ.OJ_ITEM    = SC2.C2_ITEM "
	cQuery += "                     AND SOJ.OJ_SEQUEN  = SC2.C2_SEQUEN "
	cQuery += "                     AND SOJ.OJ_ITEMGRD = SC2.C2_ITEMGRD "
	cQuery += "                     AND SOJ.D_E_L_E_T_ = ' ' "

	If cBanco $ "ORACLE"
		cQuery += "                     AND (TO_CHAR(SOJ.OJ_XMLMES) IS NULL OR TO_CHAR(SOJ.OJ_XMLMES) = ' '))"
	Else
		cQuery += "                     AND (SOJ.OJ_XMLMES IS NULL OR SOJ.OJ_XMLMES = ' '))"
	ENDIF

	cQuery += " OR EXISTS ( SELECT DISTINCT SOJ.R_E_C_N_O_ "
	cQuery += "                    FROM " + RetSqlName("SOJ") + " SOJ" 
	cQuery += "                   WHERE SOJ.OJ_FILIAL  = '" + xFilial("SOJ") + "' "
	cQuery += "                     AND SOJ.OJ_NUM     = SC2.C2_NUM "
	cQuery += "                     AND SOJ.OJ_ITEM    = SC2.C2_ITEM "
	cQuery += "                     AND SOJ.OJ_SEQUEN  = SC2.C2_SEQUEN "
	cQuery += "                     AND SOJ.OJ_ITEMGRD = SC2.C2_ITEMGRD "
	cQuery += "                     AND SOJ.OJ_ENVMES  = 'N' "
	cQuery += "                     AND SOJ.D_E_L_E_T_ = ' '  "

	If cBanco $ "ORACLE"
		cQuery += "                     AND (TO_CHAR(SOJ.OJ_XMLMES) IS NULL OR TO_CHAR(SOJ.OJ_XMLMES) = ' '))"
	Else		
		cQuery += "                     AND (SOJ.OJ_XMLMES IS NULL OR SOJ.OJ_XMLMES = ' '))"
	EndIf
	cQuery += ") "

	//Se não for SQL Server, troca o comando de concatenação de + por ||
	If !("MSSQL" $ cBanco)
		cQuery := StrTran(cQuery, "+", "||")
	EndIf

	//cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)

	While !(cAliasTop)->(Eof())
		SC2->(dbGoTo((cAliasTop)->(RECTAB)))
		mata650PPI(, SC2->(C2_NUM+C2_ITEM+C2_SEQUEN), .T., .T., .F., .T.)
		SC2->(dbGoTo((cAliasTop)->(RECTAB))) 
		PCPA114APS(SC2->C2_NUM,SC2->C2_ITEM,SC2->C2_SEQUEN,SC2->C2_ITEMGRD,'S')
		(cAliasTop)->(dbSkip())
	End

	(cAliasTop)->(dbCloseArea())

	/*
		Faz o processamento das ordens que foram excluídas pelo APS
	*/
	cQuery := " SELECT SOJ.R_E_C_N_O_ OJREC "
	cQuery +=   " FROM " + RetSqlName("SOJ") + " SOJ "
	cQuery +=  " WHERE SOJ.OJ_FILIAL  = '" + xFilial("SOJ") + "' "
	cQuery +=    " AND SOJ.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SOJ.OJ_ENVMES  = 'N' "

	If cBanco $ "ORACLE"
		cQuery +=    " AND TO_CHAR(SOJ.OJ_XMLMES)  IS NOT NULL "
		cQuery +=    " AND TO_CHAR(SOJ.OJ_XMLMES)  <> ' ' "
	Else
		cQuery +=    " AND SOJ.OJ_XMLMES  IS NOT NULL "
		cQuery +=    " AND SOJ.OJ_XMLMES  <> ' ' "
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	cAliasTop := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
	While !(cAliasTop)->(Eof())
		SOJ->(dbGoTo((cAliasTop)->(OJREC)))
		mata650PPI(SOJ->OJ_XMLMES, SOJ->(OJ_NUM+OJ_ITEM+OJ_SEQUEN+OJ_ITEMGRD), .T., .T., .T., .F.)
		PCPA114APS(SOJ->OJ_NUM,SOJ->OJ_ITEM,SOJ->OJ_SEQUEN,SOJ->OJ_ITEMGRD,'S')
		SOJ->(dbGoTo((cAliasTop)->(OJREC))) //Necessário reposicionar na SOJ, pois a função PCPA114APS faz seek na SOJ.
		PCPA114DEL(SOJ->OJ_NUM,SOJ->OJ_ITEM,SOJ->OJ_SEQUEN,SOJ->OJ_ITEMGRD)
		(cAliasTop)->(dbSkip())
	End
	(cAliasTop)->(dbCloseArea())
Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA114APS

Função Atualizar a SOJ informando que a OP do APS foi enviada para o TOTVS MES.

@author  Michelle RAmos Henriques
@version P12
@since   26/10/2017
/*/
//-------------------------------------------------------------------------------------------------

Function PCPA114APS(cNumOP,cItem,cSequen,cItemGrd,cEnvMES,cXmlMES)

Default cXmlMES    := ''
Default lAutoMacao := .F.
/*
	O campo OJ_XMLMES será utilizado apenas para exclusão de ordens.
*/

If TableInDic("SOJ",.F.)
	dbSelectArea("SOJ")
	SOJ->(dbSetOrder(1))

	If SOJ->(dbSeek(xFilial("SOJ")+cNumOP+cItem+cSequen+cItemGrd)) 
		RecLock("SOJ",.F.)
		Replace  OJ_ENVMES With cEnvMES
		If !Empty(cXmlMES)
			Replace  OJ_XMLMES With cXmlMES
		EndIf
		MsUnLock()
	Else
		IF !lAutoMacao
			RecLock("SOJ",.T.)
			SOJ->OJ_FILIAL  := xFilial("SOJ")
			SOJ->OJ_NUM     := cNumOP
			SOJ->OJ_ITEM    := cItem
			SOJ->OJ_SEQUEN  := cSequen
			SOJ->OJ_ITEMGRD := cItemGrd
			SOJ->OJ_ENVMES  := cEnvMES
			SOJ->OJ_XMLMES  := cXmlMES
			MsUnLock()
		ENDIF
	EndIf

	SOJ->(dbCloseArea())	
EndIf

Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA114DEL

Exclui a tabela SOJ

@author  Michelle RAmos Henriques
@version P12
@since   30/10/2017
/*/
//-------------------------------------------------------------------------------------------------

Function PCPA114DEL(cNumOP,cItem,cSequen,cItemGrd)
Default lAutoMacao := .F.

If TableInDic("SOJ",.F.)
	dbSelectArea("SOJ")
	SOJ->(dbSetOrder(1))

	If SOJ->(dbSeek(xFilial("SOJ")+cNumOP+cItem+cSequen+cItemGrd))
		IF !lAutoMacao
			RecLock("SOJ",.F.)
			dbDelete()
			MsUnLock()
		ENDIF
	EndIf

	SOJ->(dbCloseArea())
EndIf

Return .T.


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SchedDef

Executar o programa PCPA114 no schedule

@author  Michelle RAmos Henriques
@version P12
@since   23/10/2017
/*/
//-------------------------------------------------------------------------------------------------


Static Function SchedDef()
Local aOrd := {}
Local aParam := {}
aParam := { "P",;
"PARAMDEF",;
"SC2",;
aOrd,;
}
Return aParam

