#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#include "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} SCHEDESTMG
Processa mensagem de STOCKLEVEL automaticamente.

@author Totvs S/A
@since 01/10/2016
@version P12
/*/
//-------------------------------------------------------------------
Function SCHEDESTMG()
Local lRet		:= .T.
Local cJoin		:= ""
Local cHaving	:= ""
Local cQuery  	:= ""
Local cLista	:= cFilAnt
Local cAliasTemp:= ""
Local cAliasMsg	:= ""
Local dInicio	:= STOD("19970101")
Local dFim		:= dDataBase
Local cVlAltSB2 := ""

Private lBlind := IsBlind()

If SB2->(ColumnPos("B2_DMOV")) > 0 .AND. SB2->(ColumnPos("B2_HMOV")) > 0  //Verifique se utiliza Schedule no modelo de atualização com base na movimentação da SB2 e não mais na XX3

	cAliasTemp 	:= GetNextAlias()
	cQuery 		:= " SELECT SB2.B2_COD,  SB2.B2_LOCAL "
	cQuery 		+= " FROM " + RetSqlName("SB2") + " SB2 "
	cQuery 		+= " WHERE	 SB2.B2_FILIAL  = '" + xFilial("SB2") + "' "
	cQuery		+= " AND	(SB2.B2_DMOV||SB2.B2_HMOV >= SB2.B2_DULT||SB2.B2_HULT)  " 
	cQuery 		+= " AND 	 SB2.D_E_L_E_T_ = ' ' "
	
	cQuery 		:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTemp,.T.,.T.)
	
	While (cAliasTemp)->(!Eof())	
		//Posiciona tabela utilizada na mensagem unica 
		dbSelectArea('SB2')
		SB2->(dbSetOrder(1))	
		SB2->(dbSeek(xFilial('SB2')+(cAliasTemp)->(B2_COD)+(cAliasTemp)->(B2_LOCAL)))
		cVlAltSB2 := DToS(SB2->B2_DMOV) + SB2->B2_HMOV 

		FwIntegDef("MATA225")
			
		//Atualiza data e hora do ultimo envio
		If cVlAltSB2 == DToS(SB2->B2_DMOV) + SB2->B2_HMOV //-- Verifica se nao houve alteracao durante preparacao da msg
			RecLock("SB2",.F.)
			REPLACE	B2_DULT WITH dDataBase
			REPLACE	B2_HULT WITH Time()
			SB2->(MsUnlock())
		EndIf

		(cAliasTemp)->(dbSkip())
	EndDo
	(cAliasTemp)->(dbCloseArea())

ElseIf MsFile(RetSqlName("XX3"),,"TOPCONN")
	
	cAliasTemp	:= GetNextAlias()
	cAliasMsg	:= GetNextAlias()

	BeginSQL Alias cAliasMsg
		SELECT *
		FROM 	%Table:XX3%
		WHERE 	%NotDel%
		AND XX3_FUNCOD = 'STOCKLEVEL'
		ORDER BY XX3_TRHORA DESC
	EndSQL
	
	If (cAliasMsg)->(!Eof())
		dInicio:= STOD((cAliasMsg)->XX3_TRDATA)
	EndIf
	(cAliasMsg)->(dbCloseArea())
	
	//-- Analisa SD1
	cJoin += "	LEFT JOIN "+RetSqlName('SD1')+" SD1 ON SD1.D_E_L_E_T_ = ' ' AND "
	cJoin += "SD1.D1_FILIAL = SB2.B2_FILIAL AND "
	cJoin += "SD1.D1_COD = SB2.B2_COD AND "
	cJoin += "SD1.D1_LOCAL = SB2.B2_LOCAL AND "
	cJoin += "SD1.D1_DTDIGIT BETWEEN '" +DToS(dInicio) +"' AND '" +DToS(dFim) +"' "
	//-- Analisa SD2
	cJoin += "LEFT JOIN "+RetSqlName('SD2')+" SD2 ON SD2.D_E_L_E_T_ = ' ' AND "
	cJoin += "SD2.D2_FILIAL = SB2.B2_FILIAL AND "
	cJoin += "SD2.D2_COD = SB2.B2_COD AND "
	cJoin += "SD2.D2_LOCAL = SB2.B2_LOCAL AND "
	cJoin += "SD2.D2_EMISSAO BETWEEN '" +DToS(dInicio) +"' AND '" +DToS(dFim) +"' "
	//-- Analisa SD3
	cJoin += "LEFT JOIN "+RetSqlName('SD3')+" SD3 ON SD3.D_E_L_E_T_ = ' ' AND "
	cJoin += "SD3.D3_FILIAL = SB2.B2_FILIAL AND "
	cJoin += "SD3.D3_COD = SB2.B2_COD AND "
	cJoin += "SD3.D3_LOCAL = SB2.B2_LOCAL AND "
	cJoin += "SD3.D3_ESTORNO = ' ' AND "
	cJoin += "SD3.D3_EMISSAO BETWEEN '" +DToS(dInicio) +"' AND '" +DToS(dFim) +"' "
	
	//-- Analisa SD1
	cHaving += " HAVING COUNT(SD1.D1_FILIAL) > 0 OR COUNT(SD2.D2_FILIAL) > 0 OR COUNT(SD3.D3_FILIAL) > 0 "
	
	cQuery := " SELECT 	SB1.B1_FILIAL,"
	cQuery += " 			SB2.B2_FILIAL,"
	cQuery += " 			SB2.B2_COD"
	cQuery += " FROM " + RetSqlName("SB2") + " SB2"
	cQuery += " JOIN " + RetSqlName("SB1") + " SB1"
	cQuery += "     ON SB1.D_E_L_E_T_ = ' '"
	cQuery += "     AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += "     AND SB1.B1_COD = SB2.B2_COD"
	cQuery += "     AND SB1.B1_GCCUSTO = '" + CriaVar("B1_GCCUSTO") + "'"
	cQuery += "     AND SB1.B1_CCCUSTO = '" + CriaVar("B1_CCCUSTO") + "'"
	cQuery += "     AND SUBSTRING(SB1.B1_COD,1,3) <> 'MOD'"
	cQuery += cJoin
	cQuery += " WHERE SB2.D_E_L_E_T_ = ' '"
	cQuery += " AND RTRIM(SB2.B2_FILIAL) IN ('" + cLista + "')"
	cQuery += " GROUP BY SB1.B1_FILIAL, SB2.B2_FILIAL, SB2.B2_COD
	cQuery += cHaving
	cQuery += " ORDER BY SB2.B2_COD" 
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTemp,.F.,.T.)
	
	TCSetField(cAliasTemp,"B1_UCOM","D",8,0)
	TCSetField(cAliasTemp,"B1_UCALSTD","D",8,0)
	
	While !(cAliasTemp)->(EOF())
		SB1->(dbSetOrder(1))
		SB1->(dbSeek((cAliasTemp)->(B1_FILIAL+B2_COD)))
		SB5->(dbSeek((cAliasTemp)->(B1_FILIAL+B2_COD)))
		FwIntegDef("MATA225")
		(cAliasTemp)->(dbSkip())
	EndDo
	
	(cAliasTemp)->(DbCloseArea())  
EndIf

Return NIL

/*/{Protheus.doc} SchedDef
Definição de Schedule

@author Totvs S/A
@since 01/10/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function Scheddef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "ParamDef",;	//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            }				//Titulo

Return aParam
