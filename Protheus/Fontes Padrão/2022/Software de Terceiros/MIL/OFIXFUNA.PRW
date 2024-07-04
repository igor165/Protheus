#include "protheus.ch"
#include "OFIXFUNA.ch"
#include "OFIXDEF.ch"
#include "TOPCONN.CH"

Static lInconveniente := (GetNewPar("MV_INCORC","N") == "S")
Static lChkUserRules := FindFunction("ChkUserRules")
Static lCtrlLote   := GetNewPar("MV_RASTRO","N") == "S"
static PULALINHA := chr(13) + chr(10)
static oSqlHlpXFUNA := NIL
STATIC cSGBD := Upper(TcGetDb())

static cRpoVersion := NIL

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  19/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006248_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_VALHOR   บAutor  ณTakahashi       บ Data ณ  29/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o valor da Hora de Um Determinado Servico          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cTipTem  -> Tipo de Tempo                                  บฑฑ
ฑฑบ          ณ dDataRef -> Data de Referencia                             บฑฑ
ฑฑบ          ณ cVHRDIG  -> Flag indicando se o valor foi alterado na      บฑฑ
ฑฑบ          ณ             requisicao                                     บฑฑ
ฑฑบ          ณ nVlrComp -> Valor digitado na requisicao                   บฑฑ
ฑฑบ          ณ cCodMar  -> Marca do Veiculo                               บฑฑ
ฑฑบ          ณ cCodSrv  -> Codigo do Servico                              บฑฑ
ฑฑบ          ณ cTipSer  -> Tipo de Servico                                บฑฑ
ฑฑบ          ณ cCodCli  -> Cliente                                        บฑฑ
ฑฑบ          ณ cLojCli  -> Loja                                           บฑฑ
ฑฑบ          ณ cPMarcaVO6 -> Grupo de servico para pesquisa no VO6        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_VALHOR( cTipTem , dDataRef , cVHRDIG , nVlrComp , cCodMar , cCodSrv , cTipSer , cCodCli , cLojCli , cPMarcaVO6 , cModVei , cSegMod )

Local nRetValHor := 0
Local cSQL
Local cTipVei := " "

Default cVHRDIG  := "0" // Define como nao digitado pelo usuario
Default nVlrComp := 0
Default cCodSrv := " "
Default cTipSer := " "
Default cCodCli := " "
Default cLojCli := " "
Default cPMarcaVO6 := FG_MARSRV(cCodMar, cCodSrv)
Default cModVei := " "
Default cSegMod := " "

If cVHRDIG == "1" .and. nVlrComp <> 0
	nRetValHor := nVlrComp
EndIf

IF cTipVei == " "
	cTipVei := FM_SQL("SELECT VV2_TIPVEI FROM " + RetSQLName("VV2") + " WHERE VV2_FILIAL = '" + xFilial("VV2") + "' AND VV2_CODMAR = '" + cCodMar  + "' AND VV2_MODVEI = '" + cModVei  + "'AND VV2_SEGMOD = '" + cSegMod + "' AND D_E_L_E_T_ = ' '")
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ VZF - Valor da Hora por Cliente ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nRetValHor == 0
	If FWAliasInDic("VZF")

		If (VZF->(FieldPos("VZF_TIPVEI")) <> 0)
			If (!Empty(cTipSer) .OR. !Empty(cCodCli) .OR. !Empty(cLojCli) .OR. !Empty(cTipVei))
				cSQL := "SELECT VZF_VALHOR"
				cSQL +=  " FROM " + RetSQLName("VZF")
				cSQL += " WHERE VZF_FILIAL = '" + xFilial("VZF") + "'"
				cSQL +=   " AND VZF_TIPTEM = '" + cTipTem + "'"
				cSQL +=   " AND (VZF_TIPSER = '" + cTipSer + "' OR VZF_TIPSER = '  ')"
				cSQL +=   " AND (VZF_CODCLI = '" + cCodCli + "' OR VZF_CODCLI = '  ')"
				cSQL +=   " AND (VZF_LOJCLI = '" + cLojCli + "' OR VZF_LOJCLI = '  ')"
				cSQL +=   " AND (VZF_TIPVEI = '" + cTipVei + "' OR VZF_TIPVEI = '  ')"
				cSQL +=   " AND VZF_DATVIG <= '" + DtoS(dDataRef) + "'"
				cSQL +=   " AND D_E_L_E_T_ = ' '"
				
				If VZF->(FieldPos("VZF_MSBLQL")) > 0				
					cSql +=   " AND VZF_MSBLQL <> '1'"				
				EndIf
				
				cSQL += " ORDER BY VZF_CODCLI DESC, VZF_LOJCLI DESC, VZF_TIPSER DESC, VZF_TIPVEI DESC, VZF_DATVIG DESC"
				nRetValHor := FM_SQL(cSQL)
			Endif
		Else
			If (!Empty(cTipSer) .OR. !Empty(cCodCli))
				cSQL := "SELECT VZF_VALHOR"
				cSQL +=  " FROM " + RetSQLName("VZF")
				cSQL += " WHERE VZF_FILIAL = '" + xFilial("VZF") + "'"
				cSQL +=   " AND VZF_TIPTEM = '" + cTipTem + "'"
				cSQL +=   " AND (VZF_TIPSER = '" + cTipSer + "' OR VZF_TIPSER = '  ')"
				cSQL +=   " AND (VZF_CODCLI = '" + cCodCli + "' OR VZF_CODCLI = '  ')"
				cSQL +=   " AND (VZF_LOJCLI = '" + cLojCli + "' OR VZF_LOJCLI = '  ')"
				cSQL +=   " AND VZF_DATVIG <= '" + DtoS(dDataRef) + "'"
				cSQL +=   " AND D_E_L_E_T_ = ' '"

				If VZF->(FieldPos("VZF_MSBLQL")) > 0				
					cSql +=   " AND VZF_MSBLQL <> '1'"				
				EndIf

				cSQL += " ORDER BY VZF_CODCLI DESC, VZF_LOJCLI DESC, VZF_TIPSER DESC, VZF_DATVIG DESC"
				nRetValHor := FM_SQL(cSQL)
			EndIf
		EndIf

	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ VO6 - Tabela de Servicos ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nRetValHor == 0 .and. !Empty(cCodSrv)
	cSQL := "SELECT VO6_VALHOR"
	cSQL +=  " FROM " + RetSQLName("VO6")
	cSQL += " WHERE VO6_FILIAL = '" + xFilial("VO6") + "'"
	cSQL +=   " AND VO6_CODMAR = '" + cPMarcaVO6 + "'"
	cSQL +=   " AND VO6_CODSER = '" + cCodSrv + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	nRetValHor := FM_SQL(cSQL)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ VOI - Tipo de Tempo ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nRetValHor == 0
	cSQL := "SELECT VOI_VALHOR"
	cSQL +=  " FROM " + RetSQLName("VOI")
	cSQL += " WHERE VOI_FILIAL = '" + xFilial("VOI") + "'"
	cSQL +=   " AND VOI_TIPTEM = '" + cTipTem + "'"
	cSQL +=   " AND VOI_DATVIG <= '" + DtoS(dDataRef) + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	nRetValHor := FM_SQL(cSQL)
	//

	If nRetValHor == 0
		cSQL := "SELECT VOJ_VALHOR"
		cSQL +=  " FROM " + RetSQLName("VOJ")
		cSQL += " WHERE VOJ_FILIAL = '" + xFilial("VOJ") + "'"
		cSQL +=   " AND VOJ_TIPTEM = '" + cTipTem + "'"
		cSQL +=   " AND VOJ_DATVIG <= '" + DtoS(dDataRef) + "'"
		cSQL +=   " AND D_E_L_E_T_ = ' '"
		cSQL += " ORDER BY VOJ_DATVIG DESC , VOJ_HORVIG DESC"
		nRetValHor := FM_SQL(cSQL)
	EndIf

EndIf

if ExistBlock("PEVALHOR") // Ponto de entrada para manipulacao do valor da hora.
	nRetValHor := ExecBlock("PEVALHOR",.f.,.f.,{nRetValHor,cTipTem})
Endif

Return nRetValHor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_VALSER   บAutor  ณ Takahashi      บ Data ณ  12/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o valor do servico                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cTipTem  -> Tipo de Tempo                                  บฑฑ
ฑฑบ          ณ cTipSer  -> Tipo de Servico                                บฑฑ
ฑฑบ          ณ cCodMar  -> Codigo da Marca                                บฑฑ
ฑฑบ          ณ cCodSrv  -> Codigo do Servico                              บฑฑ
ฑฑบ          ณ cCodCli  -> Codigo do Cliente - Faturar Para               บฑฑ
ฑฑบ          ณ cLojCli  -> Codigo da Loja do Cliente - Faturar Para       บฑฑ
ฑฑบ          ณ cChaInt  -> Chassi Interno do veiculo                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_VALSER(cTipTem , cTipSer , cCodMar , cCodSrv , cCodCli , cLojCli , cChaInt, cModVei, cSegMod)

Local nValSrvc := 0
Local nValHora := 0
Local lVO6VALSER := (VO6->(FieldPos("VO6_VALSER")) <> 0)
Local cMarcaVO6 := FG_MARSRV(cCodMar,cCodSrv)
Local nTemPad := 0

If lVO6VALSER
	VO6->(dbSetOrder(2))
	If VO6->(MsSeek(xFilial("VO6")+ cMarcaVO6 + cCodSrv )) .and. VO6->VO6_VALSER <> 0
		Return VO6->VO6_VALSER
	EndIf
EndIf

VOK->(dbSetOrder(1))
VOK->(MsSeek(xFilial("VOK") + cTipSer ))

nTemPad  := FG_TEMPAD( cChaInt , cCodSrv , IIf( VOK->VOK_INCTEM == "3" , "1" , VOK->VOK_INCTEM) , VOK->VOK_INCMOB , cCodMar )
nValHora := FMX_VALHOR( cTipTem, dDataBase , "0" , 0 , cCodMar , cCodSrv , cTipSer , cCodCli , cLojCli , cMarcaVO6 , cModVei, cSegMod)
nValSrvc := (nTemPad /100) * nValHora

Return nValSrvc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_OSSTAT   บAutor  ณTakahashi       บ Data ณ  29/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o Status que deve ser gravado na OS                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_OSSTAT( cNumOsv )

Local cStatus := ""
Local cSQL
Local cAlias := "TOSSTAT"
Local oArea := GetArea()

cSQL := "SELECT VO3.VO3_DATDIS DATDIS, VO3.VO3_DATFEC DATFEC , VO3.VO3_DATCAN DATCAN"
cSQL +=  " FROM " + RetSQLName("VO2") + " VO2 "
cSQL +=         " JOIN " + RetSQLName("VO3") + " VO3 ON VO3.VO3_FILIAL = '" + xFilial("VO3") + "' AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' '"
cSQL += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
cSQL +=   " AND VO2.VO2_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VO2.VO2_TIPREQ = 'P'"
cSQL +=   " AND VO2.D_E_L_E_T_ = ' '"
cSQL += " UNION "
cSQL += "SELECT VO4.VO4_DATDIS DATDIS, VO4.VO4_DATFEC DATFEC , VO4.VO4_DATCAN DATCAN"
cSQL +=  " FROM " + RetSQLName("VO2") + " VO2 "
cSQL +=         " JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.D_E_L_E_T_ = ' '"
cSQL += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
cSQL +=   " AND VO2.VO2_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VO2.VO2_TIPREQ = 'S'"
cSQL +=   " AND VO2.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAlias , .F., .T. )
While !(cAlias)->(Eof())

	// Aberta ...
	If Empty((cAlias)->DATDIS) .and. Empty((cAlias)->DATFEC) .and. Empty((cAlias)->DATCAN)
		cStatus := "A"
	EndIf

	// Liberada ...
	If (Empty(cStatus) .or. cStatus $ "F,C") .and. !Empty((cAlias)->DATDIS) .and. Empty((cAlias)->DATFEC) .and. Empty((cAlias)->DATCAN)
		cStatus := "D"
	EndIf

	// Fechada ...
	If (Empty(cStatus) .or. cStatus == "C" ) .and. !Empty((cAlias)->DATFEC) .and. Empty((cAlias)->DATCAN)
		cStatus := "F"
	EndIf

	// Cancelada ...
	If Empty(cStatus) .and. !Empty((cAlias)->DATCAN)
		cStatus := "C"
	EndIf

	(cAlias)->(dbSkip())
End
(cAlias)->(dbCloseArea())

RestArea( oArea )
Return cStatus

/*/{Protheus.doc} FMX_GRVOSSTAT
Efetua a grava็ใo da data e hora de mudan็a do status da ordem de servi็o
@author Renato Vinicius
@since 15/08/2017
@version undefined
@param _cNumOsv, string, Numero da ordem de servi็o
@param _cStatus, string, Status da ordem de servi็o
@type function
/*/

Function FMX_GRVOSSTAT(_cNumOsv,_cStatus)

Local lVO1DATSTA := VO1->(FieldPos("VO1_DATSTA")) > 0
Local lVO1HORSTA := VO1->(FieldPos("VO1_HORSTA")) > 0

Default _cNumOsv := ""
Default _cStatus := ""
Default _cStatusA := ""

If !Empty(_cNumOsv)

	If Empty(_cStatus)

		_cStatus := FMX_OSSTAT( _cNumOsv )

	EndIf

	If _cStatus <> VO1->VO1_STATUS

		DbSelectArea("VO1")

		If ExistBlock("OXASTVO1")
			ExecBlock("OXASTVO1",.f.,.f.,{_cNumOsv,VO1->VO1_STATUS,_cStatus,iif(lVO1DATSTA,VO1->VO1_DATSTA,nil),iif(lVO1HORSTA,VO1->VO1_HORSTA,nil)})
		Endif

		If lVO1DATSTA
			VO1->VO1_DATSTA := dDataBase
		EndIf
		If lVO1HORSTA
			VO1->VO1_HORSTA := val(left(time(),2)+substr(time(),4,2))
		EndIf

	EndIf
EndIf

Return _cStatus

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_LJFAT    บAutor  ณ Takahashi      บ Data ณ  13/01/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao executada no momento da Finalizacao do Orcamento no บฑฑ
ฑฑบ          ณ Loja                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cOrcLoja = Numero do Orcamento do Loja                     บฑฑ
ฑฑบ          ณ cPesq = 1=Balcao/2=Oficina (L1_VEIPESQ)                    บฑฑ
ฑฑบ          ณ cNota = Nota Fiscal gerada                                 บฑฑ
ฑฑบ          ณ cSerie = Serie gerada                                      บฑฑ
ฑฑบ          ณ dDtEmissao = Data de Emissao da NF                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao SIGAOFI x SIGALOJA                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_LJFAT( cOrcLoja, cPesq, cNota , cSerie, dDtEmissao)

Local nHorFec := val(left(time(),2)+substr(time(),4,2))
Local cQuery
Local cAuxAlias := GetNextAlias()
Local cQueryNF
Local cQueryL2
Local cAliasNF := "TSD2"
Local lAtualizado := .f.

Local cVOONota  := ""
Local cVOOSerie := ""

Local lVECITENFI := (VEC->(FieldPos("VEC_ITENFI")) <> 0)
Local lVSCITENFI := (VSC->(FieldPos("VSC_ITENFI")) <> 0)

Local lVECPEDITE := (VEC->(FieldPos("VEC_PEDITE")) <> 0)
Local lVSCPEDITE := (VSC->(FieldPos("VSC_PEDITE")) <> 0)

If lVECITENFI .or. lVSCITENFI
	cQueryNF := "SELECT D2_ITEM "
	cQueryNF +=  " FROM " + RetSQLName("SD2")
	cQueryNF += " WHERE D2_FILIAL = '" + xFilial("SD2") + "'"
	cQueryNF +=   " AND D2_SERIE = '" + cSerie + "'"
	cQueryNF +=   " AND D2_DOC = '" + cNota + "'"
	cQueryNF +=   " AND D2_EMISSAO = '" + DtoS(dDtEmissao) + "'"
	cQueryNF +=   " AND D_E_L_E_T_ = '  '"
EndIf

dbSelectArea("VFE")
dbSetOrder(1)
dbSeek(xFilial("VFE")+cOrcLoja)
While !Eof() .and. VFE->VFE_FILIAL == xFilial("VFE") .and. VFE->VFE_NUMORC == cOrcLoja

	cVOONota  := ""
	cVOOSerie := ""

	If lVECPEDITE .or. lVSCPEDITE
		cQueryL2 := "SELECT L2_DOC, L2_SERIE, L2_ITEMNF, D2_PEDIDO, D2_ITEM " +;
			" FROM " + RetSQLName("SL2") + " SL2 " +;
				" JOIN " + RetSQLName("SD2") + " SD2 " +;
					" ON SD2.D2_FILIAL = '" + xFilial("SD2") + "' " +;
					" AND SD2.D2_DOC = SL2.L2_DOC " +;
					" AND SD2.D2_SERIE = SL2.L2_SERIE " +;
					" AND SD2.D2_ITEMPV = SL2.L2_ITEM " +; // Relaciona com o Item do Pedido de Venda, pois antes nใo estava sendo gravado na tabela SD2 o item da nota fiscal ...
					" AND SD2.D_E_L_E_T_ = ' ' " +;
			" WHERE SL2.L2_FILIAL = '" + xFilial("SL2") + "' " +;
			" AND SL2.D_E_L_E_T_ = ' '" +;
			" AND SL2.L2_NUM = '" + VFE->VFE_NUMORC + "'" +;
			" AND SL2.L2_ITEM = '"
	Endif

	//Atualiza Avaliacao de Pecas
	cQuery := "SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSQLName("VEC") + " VEC "
	cQuery += " WHERE VEC.VEC_FILIAL = '" + xFilial("VEC") + "'"
	cQuery +=   " AND VEC.VEC_NUMOSV = '" + VFE->VFE_NUMOSV + "'"
	cQuery +=   " AND VEC.VEC_TIPTEM = '" + VFE->VFE_TIPTEM + "'"
	cQuery +=   " AND VEC.VEC_LIBVOO = '" + VFE->VFE_LIBVOO + "'"
	cQuery +=  " AND VEC.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
	dbSelectArea("VEC")
	While !(cAuxAlias)->(Eof())
		lAtualizado := .f.
		VEC->(dbGoTo((cAuxAlias)->RECNO))
		RecLock("VEC",.f.)
		VEC->VEC_DATVEN := dDtEmissao

		If lVECITENFI .and. !Empty(VEC->VEC_PEDITE)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryL2 + VEC->VEC_PEDITE + "'" ), cAliasNF , .F., .T. )
			If !(cAliasNF)->(Eof())
				VEC->VEC_NUMNFI := (cAliasNF)->L2_DOC
				VEC->VEC_SERNFI := (cAliasNF)->L2_SERIE
				VEC->VEC_ITENFI := (cAliasNF)->L2_ITEMNF
				lAtualizado := .t.
			EndIf
			(cAliasNF)->(DbCloseArea())
			dbSelectArea("VEC")
		EndIf

		If !lAtualizado
			VEC->VEC_NUMNFI := cNota
			VEC->VEC_SERNFI := cSerie
			VEC->VEC_DATVEN := dDtEmissao
			If lVECITENFI .and. !Empty(VEC->VEC_PEDITE)
				VEC->VEC_ITENFI := FM_SQL(cQueryNF + " AND D2_ITEMPV = '" + VEC->VEC_PEDITE + "'")
			EndIf
		EndIf

		cVOONota  := VEC->VEC_NUMNFI
		cVOOSerie := VEC->VEC_SERNFI

		MsUnlock()
		(cAuxAlias)->(dbSkip())
	EndDo
	(cAuxAlias)->(dbCloseArea())
	dbSelectArea("VEC")
	//

	//Atualiza Avaliacao de Servicos
	cQuery := "SELECT R_E_C_N_O_ RECNO "
	cQuery +=  " FROM " + RetSQLName("VSC") + " VSC "
	cQuery += " WHERE VSC.VSC_FILIAL = '" + xFilial("VSC") + "'"
	cQuery +=   " AND VSC.VSC_NUMOSV = '" + VFE->VFE_NUMOSV + "'"
	cQuery +=   " AND VSC.VSC_TIPTEM = '" + VFE->VFE_TIPTEM + "'"
	cQuery +=   " AND VSC.VSC_LIBVOO = '" + VFE->VFE_LIBVOO + "'"
	cQuery +=   " AND VSC.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
	dbSelectArea("VSC")
	While !(cAuxAlias)->(Eof())
		lAtualizado := .f.
		VSC->(dbGoTo((cAuxAlias)->RECNO))
		RecLock("VSC",.f.)
		VSC->VSC_DATVEN := dDtEmissao

		If lVSCITENFI .and. !Empty(VSC->VSC_PEDITE)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryL2 + VSC->VSC_PEDITE + "'" ), cAliasNF , .F., .T. )
			If !(cAliasNF)->(Eof())
				VSC->VSC_NUMNFI := (cAliasNF)->L2_DOC
				VSC->VSC_SERNFI := (cAliasNF)->L2_SERIE
				VSC->VSC_ITENFI := (cAliasNF)->L2_ITEMNF
				lAtualizado := .t.
			EndIf
			(cAliasNF)->(DbCloseArea())
			dbSelectArea("VSC")
		EndIf

		If !lAtualizado
			VSC->VSC_NUMNFI := cNota
			VSC->VSC_SERNFI := cSerie
			If lVSCITENFI .and. !Empty(VSC->VSC_PEDITE)
				VSC->VSC_ITENFI := FM_SQL(cQueryNF + " AND D2_ITEMPV = '" + VSC->VSC_PEDITE + "'")
			EndIf
		EndIf

		If Empty(cVOONota)
			cVOONota  := VSC->VSC_NUMNFI
			cVOOSerie := VSC->VSC_SERNFI
		EndIf

		MsUnlock()
		(cAuxAlias)->(dbSkip())
	EndDo
	(cAuxAlias)->(dbCloseArea())
	dbSelectArea("VSC")
	//

	//Atualiza Requisicao de Pecas
	cQuery := "SELECT VO3.R_E_C_N_O_ RECNO "
	cQuery +=  " FROM " + RetSQLName("VO2") + " VO2 "
	cQuery +=  " JOIN " + RetSQLName("VO3") + " VO3 ON VO3.VO3_FILIAL = VO2.VO2_FILIAL AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
	cQuery +=   " AND VO2.VO2_NUMOSV = '" + VFE->VFE_NUMOSV + "'"
	cQuery +=   " AND VO2.VO2_TIPREQ = 'P'"	// Somente requisicao de pecas ...
	cQuery +=   " AND VO2.D_E_L_E_T_ = ' '"
	cQuery +=   " AND VO3.VO3_TIPTEM = '" + VFE->VFE_TIPTEM + "'"
	cQuery +=   " AND VO3.VO3_LIBVOO = '" + VFE->VFE_LIBVOO + "'"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
	dbSelectArea("VO3")
	While !(cAuxAlias)->(Eof())
		lAtualizado := .f.
		VO3->(dbGoTo((cAuxAlias)->RECNO))
		RecLock("VO3",.f.)
		VO3->VO3_DATFEC := dDtEmissao
		VO3->VO3_HORFEC := nHorFec

		If lVECITENFI .and. !Empty(VO3->VO3_PEDITE)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryL2 + VO3->VO3_PEDITE + "'" ), cAliasNF , .F., .T. )
			If !(cAliasNF)->(Eof())
				VO3->VO3_NUMNFI := (cAliasNF)->L2_DOC
				VO3->VO3_SERNFI := (cAliasNF)->L2_SERIE
				VO3->VO3_ITENFI := (cAliasNF)->L2_ITEMNF
				lAtualizado := .t.
			EndIf
			(cAliasNF)->(DbCloseArea())
			dbSelectArea("VO3")
		EndIf

		If !lAtualizado
			VO3->VO3_NUMNFI := cNota
			VO3->VO3_SERNFI := cSerie
			If lVECITENFI .and. !Empty(VO3->VO3_PEDITE)
				VO3->VO3_ITENFI := FM_SQL(cQueryNF + " AND D2_ITEMPV = '" + VO3->VO3_PEDITE + "'")
			EndIf
		EndIf
		MsUnlock()
		(cAuxAlias)->(dbSkip())
	EndDo
	(cAuxAlias)->(dbCloseArea())
	dbSelectArea("VO3")
	//

	//Atualiza Requisicao de Servicos
	cQuery := "SELECT VO4.R_E_C_N_O_ RECNO "
	cQuery +=  " FROM " + RetSQLName("VO2") + " VO2 "
	cQuery +=  " JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = VO2.VO2_FILIAL AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
	cQuery +=   " AND VO2.VO2_NUMOSV = '" + VFE->VFE_NUMOSV + "'"
	cQuery +=   " AND VO2.VO2_TIPREQ = 'S'"	// Somente requisicao de servicos ...
	cQuery +=   " AND VO2.D_E_L_E_T_ = ' '"
	cQuery +=   " AND VO4.VO4_TIPTEM = '" + VFE->VFE_TIPTEM + "'"
	cQuery +=   " AND VO4.VO4_LIBVOO = '" + VFE->VFE_LIBVOO + "'"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
	dbSelectArea("VO4")
	While !(cAuxAlias)->(Eof())
		lAtualizado := .f.
		VO4->(dbGoTo((cAuxAlias)->RECNO))
		RecLock("VO4",.f.)
		VO4->VO4_DATFEC := dDtEmissao
		VO4->VO4_HORFEC := nHorFec

		If lVSCITENFI .and. !Empty(VO4->VO4_PEDITE)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryL2 + VO4->VO4_PEDITE + "'" ), cAliasNF , .F., .T. )
			If !(cAliasNF)->(Eof())
				VO4->VO4_NUMNFI := (cAliasNF)->L2_DOC
				VO4->VO4_SERNFI := (cAliasNF)->L2_SERIE
				VO4->VO4_ITENFI := (cAliasNF)->L2_ITEMNF
				lAtualizado := .t.
			EndIf
			(cAliasNF)->(DbCloseArea())
			dbSelectArea("VO4")
		EndIf

		If !lAtualizado
			VO4->VO4_NUMNFI := cNota
			VO4->VO4_SERNFI := cSerie
			If lVSCITENFI .and. !Empty(VO4->VO4_PEDITE)
				VO4->VO4_ITENFI := FM_SQL(cQueryNF + " AND D2_ITEMPV = '" + VO4->VO4_PEDITE + "'")
			EndIf
		EndIf
		MsUnlock()
		(cAuxAlias)->(dbSkip())
	EndDo
	(cAuxAlias)->(dbCloseArea())
	dbSelectArea("VO4")
	//

	//Atualiza numero das notas
	dbSelectArea("VOO")
	dbSetOrder(1)
	if dbSeek(xFilial("VOO")+VFE->VFE_NUMOSV+VFE->VFE_TIPTEM+VFE->VFE_LIBVOO)
		RecLock("VOO",.f.)
		VOO->VOO_NUMNFI := cVOONota
		VOO->VOO_SERNFI := cVOOSerie
		MsUnlock()
	Endif
	//

	DbSelectArea("VO1")
	DbSetOrder(1)
	DbSeek( xFilial("VO1") + VFE->VFE_NUMOSV )
	RecLock("VO1",.f.)
	VO1->VO1_STATUS := FMX_GRVOSSTAT(VO1->VO1_NUMOSV," ")
	MsUnlock()

	dbSelectArea("VFE")
	dbSkip()
EndDo


Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_LJCAN    บAutor  ณ Takahashi      บ Data ณ  13/01/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao executada no momento do cancelamento do Cupom Fiscalบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cOrcLoja = Numero do Orcamento do Loja                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao SIGAOFI x SIGALOJA                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_LJCAN( cOrcLoja )

Local cQuery
Local cAuxAlias := GetNextAlias()
Local lVECITENFI := (VEC->(FieldPos("VEC_ITENFI")) <> 0)
Local lVSCITENFI := (VSC->(FieldPos("VSC_ITENFI")) <> 0)

dbSelectArea("VFE")
dbSetOrder(1)
dbSeek(xFilial("VFE")+cOrcLoja)
While !Eof() .and. VFE->VFE_NUMORC == SL1->L1_NUM

	//Atualiza numero das notas
	dbSelectArea("VOO")
	dbSetOrder(1)
	if dbSeek(xFilial("VOO")+VFE->VFE_NUMOSV+VFE->VFE_TIPTEM+VFE->VFE_LIBVOO)
		RecLock("VOO",.f.)
		VOO->VOO_NUMNFI := ""
		VOO->VOO_SERNFI := ""
		MsUnlock()
	Endif
	//

	//Atualiza Avaliacao de Pecas
	cQuery := "SELECT R_E_C_N_O_ RECNO "
	cQuery +=  " FROM " + RetSQLName("VEC") + " VEC "
	cQuery += " WHERE VEC.VEC_FILIAL = '" + xFilial("VEC") + "'"
	cQuery +=   " AND VEC.VEC_NUMOSV = '" + VFE->VFE_NUMOSV + "'"
	cQuery +=   " AND VEC.VEC_TIPTEM = '" + VFE->VFE_TIPTEM + "'"
	cQuery +=   " AND VEC.VEC_LIBVOO = '" + VFE->VFE_LIBVOO + "'"
	cQuery +=   " AND VEC.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
	dbSelectArea("VEC")
	While !(cAuxAlias)->(Eof())
		VEC->(dbGoTo((cAuxAlias)->RECNO))
		RecLock("VEC",.f.)
		VEC->VEC_NUMNFI := ""
		VEC->VEC_SERNFI := ""
		VEC->VEC_DATVEN := CtoD("")
		If lVECITENFI
			VEC->VEC_ITENFI := ""
		EndIf
		MsUnlock()
		(cAuxAlias)->(dbSkip())
	EndDo
	(cAuxAlias)->(dbCloseArea())
	dbSelectArea("VEC")
	//

	//Atualiza Avaliacao de Servicos
	cQuery := "SELECT R_E_C_N_O_ RECNO "
	cQuery +=  " FROM " + RetSQLName("VSC") + " VSC "
	cQuery += " WHERE VSC.VSC_FILIAL = '" + xFilial("VSC") + "'"
	cQuery +=   " AND VSC.VSC_NUMOSV = '" + VFE->VFE_NUMOSV + "'"
	cQuery +=   " AND VSC.VSC_TIPTEM = '" + VFE->VFE_TIPTEM + "'"
	cQuery +=   " AND VSC.VSC_LIBVOO = '" + VFE->VFE_LIBVOO + "'"
	cQuery +=   " AND VSC.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
	dbSelectArea("VSC")
	While !(cAuxAlias)->(Eof())
		VSC->(dbGoTo((cAuxAlias)->RECNO))
		RecLock("VSC",.f.)
		VSC->VSC_NUMNFI := ""
		VSC->VSC_SERNFI := ""
		VSC->VSC_DATVEN := CtoD("")
		If lVSCITENFI
			VSC->VSC_ITENFI := ""
		EndIf
		MsUnlock()
		(cAuxAlias)->(dbSkip())
	EndDo
	(cAuxAlias)->(dbCloseArea())
	dbSelectArea("VSC")
	//

	// Atualiza Requisicao de Pecas
	cQuery := "SELECT VO3.R_E_C_N_O_ RECNO "
	cQuery +=  " FROM " + RetSQLName("VO2") + " VO2 "
	cQuery +=  " JOIN " + RetSQLName("VO3") + " VO3 ON VO3.VO3_FILIAL = VO2.VO2_FILIAL AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
	cQuery +=   " AND VO2.VO2_NUMOSV = '" + VFE->VFE_NUMOSV + "'"
	cQuery +=   " AND VO2.VO2_TIPREQ = 'P'"	// Somente requisicao de pecas ...
	cQuery +=   " AND VO2.D_E_L_E_T_ = ' '"
	cQuery +=   " AND VO3.VO3_TIPTEM = '" + VFE->VFE_TIPTEM + "'"
	cQuery +=   " AND VO3.VO3_LIBVOO = '" + VFE->VFE_LIBVOO + "'"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
	dbSelectArea("VO3")
	While !(cAuxAlias)->(Eof())
		VO3->(dbGoTo((cAuxAlias)->RECNO))
		RecLock("VO3",.f.)
		VO3->VO3_NUMNFI := ""
		VO3->VO3_SERNFI := ""
		VO3->VO3_DATFEC := CtoD("")
		VO3->VO3_HORFEC := 0
		If lVECITENFI
			VO3->VO3_ITENFI := ""
		EndIf
		MsUnlock()
		(cAuxAlias)->(dbSkip())
	EndDo
	(cAuxAlias)->(dbCloseArea())
	dbSelectArea("VO3")
	//

	// Atualiza Requisicao de Servicos
	cQuery := "SELECT VO4.R_E_C_N_O_ RECNO "
	cQuery +=  " FROM " + RetSQLName("VO2") + " VO2 "
	cQuery +=  " JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = VO2.VO2_FILIAL AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
	cQuery +=   " AND VO2.VO2_NUMOSV = '" + VFE->VFE_NUMOSV + "'"
	cQuery +=   " AND VO2.VO2_TIPREQ = 'S'"	// Somente requisicao de servicos ...
	cQuery +=   " AND VO2.D_E_L_E_T_ = ' '"
	cQuery +=   " AND VO4.VO4_TIPTEM = '" + VFE->VFE_TIPTEM + "'"
	cQuery +=   " AND VO4.VO4_LIBVOO = '" + VFE->VFE_LIBVOO + "'"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
	dbSelectArea("VO4")
	While !(cAuxAlias)->(Eof())
		VO4->(dbGoTo((cAuxAlias)->RECNO))
		RecLock("VO4",.f.)
		VO4->VO4_NUMNFI := ""
		VO4->VO4_SERNFI := ""
		VO4->VO4_DATFEC := CtoD("")
		VO4->VO4_HORFEC := 0
		If lVSCITENFI
			VO4->VO4_ITENFI := ""
		EndIf
		MsUnlock()
		(cAuxAlias)->(dbSkip())
	EndDo
	(cAuxAlias)->(dbCloseArea())
	dbSelectArea("VO4")
	//

	// Atualiza o Status da OS ...
	//	DbSelectArea("VO1")
	//	DbSetOrder(1)
	//	DbSeek( xFilial("VO1") + VFE->VFE_NUMOSV )
	//	RecLock("VO1",.f.)
	//	VO1->VO1_STATUS := FMX_OSSTAT( VO1->VO1_NUMOSV )
	//	MsUnlock()

	dbSelectArea("VFE")
	dbSkip()
EndDo

Return .t.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_TELAINF  บAutor  ณ Takahashi      บ Data ณ  16/02/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe tela com informacao de documento gerado              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cTipo = Tipo da Janela a ser exibida                       บฑฑ
ฑฑบ          ณ aInf = Array com as informacoes que deve ser exibidas      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao SIGAOFI x SIGALOJA                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_TELAINF( cTipo , aInf )

Local oFont1 := TFont():New(,12,24,,.F.,,,,,,,,,,,)
Local oFont2 := TFont():New(,12,24,,.T.,,,,,,,,,,,)

Local nCont := 0
Local nLin

Local nAlturaJanela
Local lCriaScroll := .f.
Local nMax := 8
Local nLarguraJanela := 500

Do Case

	// Numero de Nota Fiscal
	Case cTipo == "1"

		If Len(aInf) > nMax
			nAlturaJanela := nMax * 44
			lCriaScroll := .t.
			nLarguraJanela := 520
		Else
			nAlturaJanela := Len(aInf) * 44
		EndIf

		oDlgInf := MSDIALOG():New(0,0, 68 + nAlturaJanela , nLarguraJanela ,STR0016,,,,128,,,,oMainWnd,.t.) // "Dados da Nota Fiscal"
		oDlgInf:lEscClose := .F.

		If lCriaScroll
			oContainer := TScrollBox():New(oDlgInf,00,00,10,10,.t. /* lVertical */ , .t. /* lHorizontal */, .f. /* lBorder */) 
			oContainer:Align := CONTROL_ALIGN_ALLCLIENT
		Else
			oContainer := oDlgInf
		EndIf
		TGroup():New( 02,04, 18 + (Len(aInf)*22),247,,oContainer,,,.t.,)

		@ 007,010 Say STR0018 OF oContainer PIXEL FONT oFont1 SIZE 80,20 // "S้rie"
		@ 007,055 Say STR0017 OF oContainer PIXEL FONT oFont1 SIZE 80,20 // "Documento"
		@ 007,137 Say STR0022 OF oContainer PIXEL FONT oFont1 SIZE 105,20 // "Observa็ใo"

		nLin := 20
		For nCont := 1 to Len(aInf)

			SetPrvt( "cFTISer" + AllTrim(Str(nCont)) )
			&("cFTISer" + AllTrim(Str(nCont)) + " := '" + aInf[nCont,1] + "'")

			SetPrvt( "cFTINf" + AllTrim(Str(nCont)) )
			&("cFTINf" + AllTrim(Str(nCont)) + " := '" + aInf[nCont,2] + "'")

			SetPrvt( "cFTIObs" + AllTrim(Str(nCont)) )
			&("cFTIObs" + AllTrim(Str(nCont)) + " := '" + aInf[nCont,3] + "'")

			TGet():New( nLin , 010 , &('{ | U | IF( PCOUNT() == 0, cFTISer' + AllTrim(Str(nCont)) + ',cFTISer' + AllTrim(Str(nCont)) + ' := U ) }'), oContainer , 020 , 015, "!!!",,,,oFont2,,,.t.,,,/* { || .f. } */ ,,,, .t. /* <.readonly.> */,,,,,,, .f. )
			TGet():New( nLin , 055 , &('{ | U | IF( PCOUNT() == 0, cFTINf'  + AllTrim(Str(nCont)) + ',cFTINf'  + AllTrim(Str(nCont)) + ' := U ) }'), oContainer , 080 , 015, "@!" ,,,,oFont2,,,.t.,,,/* { || .f. } */ ,,,, .t. /* <.readonly.> */,,,,,,, .f. )
			TGet():New( nLin , 137 , &('{ | U | IF( PCOUNT() == 0, cFTIObs' + AllTrim(Str(nCont)) + ',cFTIObs' + AllTrim(Str(nCont)) + ' := U ) }'), oContainer , 105 , 015, "@!" ,,,,oFont2,,,.t.,,,/* { || .f. } */ ,,,, .t. /* <.readonly.> */,,,,,,, .f. )

			nLin += 22
		Next nCont
		nLin += 2
		@ nLin,209 BUTTON oSair PROMPT STR0019 OF oContainer SIZE 33,11 PIXEL ACTION ( oDlgInf:End() ) // Sair
		ACTIVATE MSDIALOG oDlgInf CENTER

	// Orcamento no Loja
	Case cTipo == "2"

		oDlgInf := MSDIALOG():New(0,0,074,352,STR0020,,,,128,,,,oMainWnd,.t.) // "Dados do Or็amento no Loja"
		oDlgInf:lEscClose := .F.

		TGroup():New( 02,04,24,174,,oDlgInf,,,.t.,)
		@ 007,010 Say STR0021	OF oDlgInf PIXEL FONT oFont1 SIZE 105,20	// "Or็amento: "
		@ 006,070 Say aInf[1]	OF oDlgInf PIXEL FONT oFont2 SIZE 105,20

		@ 026,140 BUTTON oSair PROMPT STR0019 OF oDlgInf SIZE 33,11 PIXEL ACTION ( oDlgInf:End() ) // Sair
		ACTIVATE MSDIALOG oDlgInf CENTER

	// Documento
	Case cTipo == "4"

		oDlgInf := MSDIALOG():New(0,0, 68 + (Len(aInf)*44),500,STR0017,,,,128,,,,oMainWnd,.t.) // "Documento"
		oDlgInf:lEscClose := .F.

		@ 007,010 Say STR0017 OF oDlgInf PIXEL FONT oFont1 SIZE 80,20 // "Documento"
		@ 007,137 Say STR0022 OF oDlgInf PIXEL FONT oFont1 SIZE 105,20 // "Observa็ใo"

		TGroup():New( 02,04, 18 + (Len(aInf)*22),247,,oDlgInf,,,.t.,)

		nLin := 20
		For nCont := 1 to Len(aInf)

			SetPrvt( "cFTIDc" + AllTrim(Str(nCont)) )
			&("cFTIDc" + AllTrim(Str(nCont)) + " := '" + aInf[nCont,1] + "'")

			SetPrvt( "cFTIObs" + AllTrim(Str(nCont)) )
			&("cFTIObs" + AllTrim(Str(nCont)) + " := '" + aInf[nCont,2] + "'")

			TGet():New( nLin , 010 , &('{ | U | IF( PCOUNT() == 0, cFTIDc'  + AllTrim(Str(nCont)) + ',cFTIDc'  + AllTrim(Str(nCont)) + ' := U ) }'), oDlgInf , 120 , 015, "@!" ,,,,oFont2,,,.t.,,,/* { || .f. } */ ,,,, .t. /* <.readonly.> */,,,,,,, .f. )
			TGet():New( nLin , 137 , &('{ | U | IF( PCOUNT() == 0, cFTIObs' + AllTrim(Str(nCont)) + ',cFTIObs' + AllTrim(Str(nCont)) + ' := U ) }'), oDlgInf , 105 , 015, "@!" ,,,,oFont2,,,.t.,,,/* { || .f. } */ ,,,, .t. /* <.readonly.> */,,,,,,, .f. )

			nLin += 22
		Next nCont
		nLin += 2
		@ nLin,209 BUTTON oSair PROMPT STR0019 OF oDlgInf SIZE 33,11 PIXEL ACTION ( oDlgInf:End() ) // Sair
		ACTIVATE MSDIALOG oDlgInf CENTER

	Otherwise
		oDlgInf := MSDIALOG():New(0,0, 68 + (Len(aInf)*44),460,STR0020,,,,128,,,,oMainWnd,.t.) // "Dados do Or็amento no Loja"
		oDlgInf:lEscClose := .F.

		@ 007,010 Say STR0021 OF oDlgInf PIXEL FONT oFont1 SIZE 80,20 // "Or็amento"
		@ 007,092 Say STR0017 OF oDlgInf PIXEL FONT oFont1 SIZE 80,20 // "Documento"

		TGroup():New( 02,04, 18 + (Len(aInf)*22),227,,oDlgInf,,,.t.,)

		nLin := 20
		For nCont := 1 to Len(aInf)

			SetPrvt( "cFTIOrc" + AllTrim(Str(nCont)) )
			&("cFTIOrc" + AllTrim(Str(nCont)) + " := '" + aInf[nCont,1] + "'")

			SetPrvt( "cFTIObs" + AllTrim(Str(nCont)) )
			&("cFTIObs" + AllTrim(Str(nCont)) + " := '" + aInf[nCont,2] + "'")

			TGet():New( nLin , 010 , &('{ | U | IF( PCOUNT() == 0, cFTIOrc' + AllTrim(Str(nCont)) + ',cFTIOrc' + AllTrim(Str(nCont)) + ' := U ) }'), oDlgInf , 080 , 015, "@!" ,,,,oFont2,,,.t.,,,/* { || .f. } */ ,,,, .t. /* <.readonly.> */,,,,,,, .f. )
			TGet():New( nLin , 092 , &('{ | U | IF( PCOUNT() == 0, cFTIObs' + AllTrim(Str(nCont)) + ',cFTIObs' + AllTrim(Str(nCont)) + ' := U ) }'), oDlgInf , 125 , 015, "@!" ,,,,oFont2,,,.t.,,,/* { || .f. } */ ,,,, .t. /* <.readonly.> */,,,,,,, .f. )

			nLin += 22
		Next nCont
		nLin += 2
		@ nLin,189 BUTTON oSair PROMPT STR0019 OF oDlgInf SIZE 33,11 PIXEL ACTION ( oDlgInf:End() ) // Sair

		ACTIVATE MSDIALOG oDlgInf CENTER
EndCase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ FMX_CALSER บAutor  ณ Takahashi          บ Data ณ  15/10/10 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula valor de Servico de Uma OS/TT                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumOS = Numero da Ordem de Servico                        บฑฑ
ฑฑบ          ณ cTipTem = Tipo de Tempo                                    บฑฑ
ฑฑบ          ณ cGruSer = Grupo de Servico                                 บฑฑ
ฑฑบ          ณ cCodSer = Codigo de Servico                                บฑฑ
ฑฑบ          ณ lApont = Retorna apontamentos do Servicos                  บฑฑ
ฑฑบ          ณ lNegoc = Considera Valor de Negociacao Gravado (VZ1)       บฑฑ
ฑฑบ          ณ lRetAbe = Retorna Tipo de Tempo Aberto                     บฑฑ
ฑฑบ          ณ lRetLib = Retorna Tipo de Tempo Liberado                   บฑฑ
ฑฑบ          ณ lRetFec = Retorna Tipo de Tempo Fechado                    บฑฑ
ฑฑบ          ณ lRetCan = Retorna Tipo de Tempo Cancelado                  บฑฑ
ฑฑบ          ณ cLibVOO = Numero da Liberacao no VOO                       บฑฑ
ฑฑบ          ณ cFiltroSQL = Filtro SQL                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Verificar o Retorno no OFIXDEF.CH                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_CALSER(cNumOS, cTipTem, cGruSer, cCodSer, lApont, lNegoc, lRetAbe, lRetLib, lRetFec, lRetCan, cLibVOO, cFiltroSQL)

Local cSQL
Local cPMarcaVO6	:= ""	// Variavel com a Marca a ser utilizada para pesquisar servico VO6
Local cAliasSrvc	:= "TREQSRVC"
Local cAliasApon	:= "TAPOSRVC"
Local cAliasVZ1		:= "TVZ1SRVC"
Local cAliasVSC		:= "TVSCSRVC"
Local lVO6VALSER	:= (VO6->(FieldPos("VO6_VALSER")) <> 0)
Local lVO6SRVGEN	:= (VO6->(FieldPos("VO6_SRVGEN")) <> 0)
Local lVO4DESCONTO	:= (VO4->(FieldPos("VO4_PERDES")) <> 0 .AND. VO4->(FieldPos("VO4_VALDES")) <> 0)
Local lVO4SEQINC	:= (VO4->(FieldPos("VO4_SEQINC")) <> 0)
Local lVO4FUNDIS    := (VO4->(FieldPos("VO4_FUNDIS")) <> 0)
Local lVO4MPAUSA	:= (VO4->(FieldPos("VO4_MPAUSA")) <> 0)
Local lVO4PREKIL	:= (VO4->(FieldPos("VO4_PREKIL")) <> 0)
Local lVO4VALSER	:= (VO4->(FieldPos("VO4_VALSER")) <> 0)
Local lVZ1Contab :=  ( VZ1->(FieldPos("VZ1_CENCUS")) > 0 .and. VZ1->(FieldPos("VZ1_CONTA")) > 0 .and. VZ1->(FieldPos("VZ1_ITEMCT")) > 0 .and. VZ1->(FieldPos("VZ1_CLVL")) > 0 ) // Campos para a contabilizacao - VZ1
Local lVSCContab :=  ( VSC->(FieldPos("VSC_CENCUS")) > 0 .and. VSC->(FieldPos("VSC_CONTA")) > 0 .and. VSC->(FieldPos("VSC_ITEMCT")) > 0 .and. VSC->(FieldPos("VSC_CLVL")) > 0 ) // Campos para a contabilizacao - VSC
Local lVAICLAHAB := .F.
Local lVlrFixo		// Indica se o Servico tem Valor Fixo (VO6_VALSER)
Local nVlrSrvc		// Valor do Servico (Fixo ou Hora)
Local nPerDes, nValDes
Local nTamGRUINC	:= 0
Local nTamCODINC	:= 0
Local nTamSEQINC	:= 0
Local nTamDESINC	:= 0
Local lPEVALHOR     := ExistBlock("PEVALHOR")

Local cScanRetPd	:= "" // String Padrao utilizado no CodeBlock para procurar o item na matriz de retorno
Local cAuxScan		:= "" // String utilizado no CodeBlock para procurar o item na matriz de retorno
Local aRetorno := {}

Local nPosRet
Local nPosApon
Local oArea := GetArea()

Local nAuxPerc 		:= 0
Local nAuxVlrSer 	:= 0
Local nAuxTemCob 	:= 0
Local nAuxValor 	:= 0
Local nRecVO4       := 0

Local nCont
local nTamSX3VSCRECVO4 := 0


Local lVOIVLSVAC    := (VOI->(FieldPos("VOI_VLSVAC")) <> 0)
Local dDtReq

Default cTipTem := ""
Default cGruSer := ""
Default cCodSer := ""
Default lApont := .f.
Default lNegoc :=.f.
Default lRetAbe := .t.
Default lRetLib := .t.
Default lRetFec := .t.
Default lRetCan := .t.
Default cLibVOO := ""
Default cFiltroSQL := ""

_recvoi:=VOI->(recno())
_recvo1:=VO1->(recno())
_recvo4:=VO4->(recno())

If lVO4SEQINC
	nTamGRUINC := TamSX3("VST_GRUINC")[1]
	nTamCODINC := TamSX3("VST_CODINC")[1]
	nTamSEQINC := TamSX3("VST_SEQINC")[1]
	nTamDESINC := TamSX3("VST_DESINC")[1]
EndIf

// Block padrao para procurar o item na matriz de retorno ...
cScanRetPd := "x[02] == (cAliasSrvc)->VO4_CODSER"
cScanRetPd += " .and. x[03] == (cAliasSrvc)->VO1_NUMOSV"
cScanRetPd += " .and. x[04] == (cAliasSrvc)->VO4_TIPTEM"
cScanRetPd += " .and. x[05] == (cAliasSrvc)->VO4_TIPSER"
//cScanRetPd += " .and. x[25] == (cAliasSrvc)->VO4_CODFOR"
//cScanRetPd += " .and. x[26] == (cAliasSrvc)->VO4_FOLOJA"
//cScanRetPd += " .and. x[27] == (cAliasSrvc)->VO4_NUMTIT"
//cScanRetPd += " .and. x[28] == (cAliasSrvc)->VO4_TIPTIT"
cScanRetPd += " .and. x[38] == (cAliasSrvc)->VO4_LIBVOO"
If lInconveniente
	cScanRetPd += " .and. x[35] == (cAliasSrvc)->VO4_SEQINC"
EndIf
//

dbSelectArea("VO4")

cSQL := "SELECT VO1.VO1_CODMAR"
cSQL +=      ", VV1.VV1_MODVEI, VV1.VV1_SEGMOD"
cSQL +=      ", VO1.VO1_NUMOSV, VO1.VO1_DATATE, VO1.VO1_DATABE"
cSQL +=      ", VO4.VO4_TIPTEM, VO4.VO4_GRUSER, VO4.VO4_CODSER, VO4.VO4_SERINT, VO4.VO4_TIPSER, VO4.VO4_CODSEC"
cSQL +=      ", VO4.VO4_FATPAR, VO4.VO4_LOJA  , VO4.VO4_KILROD, VO4.VO4_NUMNFI"
cSQL +=      ", VO4.VO4_VALVEN, VO4.VO4_VALHOR, VO4.VO4_FUNFEC, VO4.VO4_LIBVOO, VSC_LIBVOO "
If lVO4DESCONTO
	cSQL +=  ", VO4.VO4_PERDES, VO4.VO4_VALDES"
EndIf
If lVO4SEQINC
	cSQL +=  ", VO4.VO4_SEQINC "
EndIf
If lVO4FUNDIS
	cSQL +=  ", VO4.VO4_FUNDIS "
EndIf
If lVO4PREKIL
	cSQL += " , VO4.VO4_PREKIL "
EndIf
If lVO4VALSER
	cSQL += " , VO4.VO4_VALSER "
EndIf
if lVSCContab
	cSQl +=  ", VSC_CENCUS , VSC_CONTA , VSC_ITEMCT , VSC_CLVL "
Endif
If lVZ1Contab
	cSQL += " , SB1.B1_CC, SB1.B1_CONTA, SB1.B1_ITEMCC, SB1.B1_CLVL"
Endif
cSQL +=      ", VO4.VO4_DEPINT, VO4.VO4_DEPGAR "
cSQL +=      ", VO4.VO4_VHRDIG, VO4.VO4_TEMPAD, SUM(VO4.VO4_TEMTRA) VO4_TEMTRA"
cSQL +=      ", VO4.VO4_DATDIS, VO4.VO4_DATFEC, VO4.VO4_DATCAN"
cSQL +=      ", VO4.VO4_NUMNFI, VO4.VO4_SERNFI"
cSQL +=      ", VO4.VO4_CODFOR, VO4.VO4_FOLOJA, VO4.VO4_NUMTIT, VO4.VO4_TIPTIT, VO4.VO4_DATPAG, VO4.VO4_CODPAG, VO4.VO4_NATURE, VO4.VO4_VALCUS"
cSQL +=      ", SUM(VO4.VO4_VALINT) VO4_VALINT"
cSQL +=      ", VOI.VOI_SITTPO"
If lVOIVLSVAC
	cSQl +=  ", VOI_VLSVAC "
EndIf
cSQL +=      ", VO2_DATREQ "
cSQL +=      ", VOK.VOK_INCMOB, VOK.VOK_INCTEM, VOK.VOK_PREKIL, VOK.VOK_DESSER"
cSQL +=      ", SUM(VSC.VSC_VALBRU) VSC_VALBRU, SUM(VSC.VSC_VALDES) VSC_VALDES, SUM(VSC.VSC_VALSER) VSC_VALSER "
cSQL +=      ", SUM(VSC.VSC_TEMTRA) VSC_TEMTRA, SUM(VSC.VSC_TEMCOB) VSC_TEMCOB, SUM(VSC.VSC_TOTIMP) VSC_TOTIMP "
cSQL +=      ", SUM(VSC.VSC_TEMPAD) VSC_TEMPAD, SUM(VSC.VSC_TEMVEN) VSC_TEMVEN"
cSQL +=      ", SUM(VSC.VSC_KILROD) VSC_KILROD "
cSQL +=      ", CASE VOK.VOK_INCMOB WHEN '2' THEN VO4.VO4_SEQUEN ELSE '      ' END AS VO4_SEQUEN"
cSQL +=      ", CASE VOK.VOK_INCMOB WHEN '2' THEN VO4.R_E_C_N_O_ ELSE 0        END AS RECNOVO4 "
cSQL +=      ", CASE VOK.VOK_INCMOB WHEN '2' THEN VO4.VO4_NOSNUM ELSE '      ' END AS VO4_NOSNUM "
// cSQL += IIF(VO4->(FieldPos("VO4_PERRAT")) <> 0, ", VO4_PERRAT",", 0 VO4_PERRAT ")
cSQL +=  " FROM " + RetSQLName("VO1") + " VO1 "
cSQL +=         " LEFT JOIN " + RetSQLName("VV1") + " VV1 ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1.VV1_CHAINT = VO1.VO1_CHAINT AND VV1.VV1_CHAINT <> ' ' AND VV1.D_E_L_E_T_ = ' '"
cSQL +=         " JOIN " + RetSQLName("VO2") + " VO2 ON VO2.VO2_FILIAL = '" + xFilial("VO2") + "' AND VO2.VO2_NUMOSV = VO1.VO1_NUMOSV AND VO2.D_E_L_E_T_ = ' '"
cSQL +=         " JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.D_E_L_E_T_ = ' '"
cSQL +=         " JOIN " + RetSQLName("VOI") + " VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO4.VO4_TIPTEM AND VOI.D_E_L_E_T_ = ' '"
cSQL +=         " JOIN " + RetSQLName("VOK") + " VOK ON VOK.VOK_FILIAL = '" + xFilial("VOK") + "' AND VOK.VOK_TIPSER = VO4.VO4_TIPSER AND VOK.D_E_L_E_T_ = ' '"
If lVZ1Contab
	cSQL +=       " JOIN " + RetSQLName("SB1") + " SB1 ON  SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_GRUPO   = VOK.VOK_GRUITE AND SB1.B1_CODITE = VOK.VOK_CODITE AND SB1.D_E_L_E_T_ = ' '"
EndIf
cSQL +=         " LEFT JOIN " + RetSQLName("VSC") + " VSC " +;
							"  ON VSC.VSC_FILIAL = '" + xFilial("VSC") + "'" +;
							" AND VSC.VSC_NUMOSV = VO1.VO1_NUMOSV " +;
							" AND VSC.VSC_TIPTEM = VO4.VO4_TIPTEM " +;
							" AND ( " +;
							    " ( " + iif( "POSTGRE" $ cSGBD , "CAST(VSC.VSC_RECVO4 as BIGINT) " , "VSC.VSC_RECVO4" ) + " = VO4.R_E_C_N_O_ AND VO4.VO4_VSCIDE = ' ' ) " +;
								 " OR " +;
							    " ( VSC.VSC_NUMIDE = VO4.VO4_VSCIDE AND VO4.VO4_VSCIDE <> ' ' ) " +;
								 " ) " +;
							" AND VSC.D_E_L_E_T_ = ' '"
cSQL += " WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "'"
cSQL +=   " AND VO1.VO1_NUMOSV = '" + cNumOS + "'"
cSQL +=   " AND VO1.D_E_L_E_T_ = ' '"
cSQL +=   " AND VO2.VO2_TIPREQ = 'S'" // Requisicao de Servico
If !Empty(cTipTem)
	cSQL +=   " AND VO4.VO4_TIPTEM = '" + cTipTem + "'"
EndIf
If !Empty(cGruSer)
	cSQL +=   " AND VO4.VO4_GRUSER = '" + cGruSer + "'"
EndIf
If !Empty(cCodSer)
	cSQL +=   " AND VO4.VO4_CODSER = '" + cCodSer + "'"
EndIf
If !lRetAbe
	cSQL +=   " AND ( VO4.VO4_DATDIS <> '        ' OR VO4.VO4_DATFEC <> '        ' OR VO4.VO4_DATCAN <> '        ' )"
EndIf
If !lRetLib
	cSQl +=   " AND VO4.VO4_DATDIS = '        '"
EndIf
If !lRetFec
	cSQl +=   " AND VO4.VO4_DATFEC = '        '"
EndIf
If !lRetCan
	cSQl +=   " AND VO4.VO4_DATCAN = '        '"
EndIf
If Len(cLibVOO) <> 0 .and. !Empty(cTipTem)
	cSQl +=   " AND VO4.VO4_LIBVOO = '" + cLibVOO + "'"
EndIf
If !Empty(cFiltroSQL)
	cSQL += " AND ( " + cFiltroSQL + " )"
EndIf
cSQL += " GROUP BY VO1_CODMAR, VO1_NUMOSV, VO1.VO1_DATATE, VO1.VO1_DATABE"
cSQL +=      ", VV1.VV1_MODVEI, VV1.VV1_SEGMOD"
cSQL +=      ", VO4_TIPTEM, VO4_GRUSER, VO4_CODSER, VO4_SERINT, VO4_TIPSER, VO4_CODSEC"
cSQL +=      ", VO4_DATFEC, VO4_FATPAR, VO4_LOJA  , VO4_KILROD, VO4_NUMNFI"
cSQL +=      ", VO4_VALVEN, VO4_VALHOR, VO4_FUNFEC, VO4_LIBVOO , VSC_LIBVOO "
If lVO4DESCONTO
	cSQL +=  ", VO4_PERDES, VO4_VALDES"
EndIf
If lVO4SEQINC
	cSQL +=  ", VO4_SEQINC "
EndIf
If lVO4FUNDIS
	cSQl +=  ", VO4_FUNDIS "
EndIf
if lVSCContab
	cSQl +=  ", VSC_CENCUS , VSC_CONTA , VSC_ITEMCT , VSC_CLVL "
Endif
If lVZ1Contab
	cSQL += " , B1_CC, B1_CONTA, B1_ITEMCC, B1_CLVL"
Endif
If lVO4PREKIL
	cSQL += " , VO4_PREKIL "
EndIf
If lVO4VALSER
	cSQL += " , VO4_VALSER "
EndIf
cSQL +=     ", VO4_DEPINT, VO4_DEPGAR "
cSQL +=     ", VO4_VHRDIG, VO4_TEMPAD"
cSQL +=     ", VO4_DATDIS, VO4_DATFEC, VO4_DATCAN"
cSQL +=     ", VO4_NUMNFI, VO4_SERNFI"
cSQL +=     ", VO4_CODFOR, VO4_FOLOJA, VO4_NUMTIT, VO4_TIPTIT, VO4_DATPAG, VO4_CODPAG, VO4_NATURE, VO4_VALCUS"
cSQL +=     ", VOI_SITTPO"
If lVOIVLSVAC
	cSQl += ", VOI_VLSVAC "
EndIf
cSQL +=     ", VO2_DATREQ "
cSQL +=     ", VOK_INCMOB, VOK_INCTEM, VOK_PREKIL, VOK_DESSER" // +IIF(VO4->(FieldPos("VO4_PERRAT")) <> 0, ", VO4_PERRAT ","")
cSQL +=     ", CASE VOK.VOK_INCMOB WHEN '2' THEN VO4.VO4_SEQUEN ELSE '      ' END"
cSQL +=     ", CASE VOK.VOK_INCMOB WHEN '2' THEN VO4.R_E_C_N_O_ ELSE 0        END"
cSQL +=     ", CASE VOK.VOK_INCMOB WHEN '2' THEN VO4.VO4_NOSNUM ELSE '      ' END"
cSQL += " ORDER BY VO1_NUMOSV, VO4_TIPTEM , VO4_GRUSER, VO4_CODSER"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasSrvc , .F., .T. )

While !(cAliasSrvc)->(Eof())

	cPMarcaVO6 := FG_MARSRV( (cAliasSrvc)->VO1_CODMAR, (cAliasSrvc)->VO4_CODSER )

	// Se o inconveniente estiver desligado, mas tiver conteudo na
	// coluna de inconveniente, deve quebrar por codigo de inconveniente
	If !lInconveniente .and. ( lVO4SEQINC .and. !Empty((cAliasSrvc)->VO4_SEQINC))
		cAuxScan := cScanRetPd + " .and. x[35] == (cAliasSrvc)->VO4_SEQINC"
	Else
		cAuxScan := cScanRetPd
	EndIf
	nPosRet := aScan( aRetorno , &("{ |x| " + cAuxScan + " }" ) )
	If nPosRet == 0

		VO6->(dbSetOrder(3))
		VO6->(DbSeek( xFilial("VO6") + cPMarcaVO6 + (cAliasSrvc)->VO4_GRUSER + (cAliasSrvc)->VO4_CODSER ))

		AADD( aRetorno, Array(SRVC_NTAM_RETORNO) )
		nPosRet := Len(aRetorno)
		aRetorno[ nPosRet , SRVC_GRUSER       ] := (cAliasSrvc)->VO4_GRUSER       // 01 - Grupo de Servico
		aRetorno[ nPosRet , SRVC_CODSER       ] := (cAliasSrvc)->VO4_CODSER       // 02 - Codigo do Servico
		aRetorno[ nPosRet , SRVC_NUMOSV       ] := (cAliasSrvc)->VO1_NUMOSV       // 03 - Numero da Ordem de Servico
		aRetorno[ nPosRet , SRVC_TIPTEM       ] := (cAliasSrvc)->VO4_TIPTEM       // 04 - Tipo de Tempo
		aRetorno[ nPosRet , SRVC_TIPSER       ] := (cAliasSrvc)->VO4_TIPSER       // 05 - Tipo de Servico
		aRetorno[ nPosRet , SRVC_INCMOB       ] := (cAliasSrvc)->VOK_INCMOB       // 06 - Tipo de Cobranca
		aRetorno[ nPosRet , SRVC_VALBRU       ] := 0                              // 07 - Valor do Servico (Valor Bruto)
		aRetorno[ nPosRet , SRVC_VALDES       ] := 0                              // 08 - Valor do Desconto
		aRetorno[ nPosRet , SRVC_VALLIQ       ] := 0                              // 09 - Valor do Servico (Valor Liquido)
		aRetorno[ nPosRet , SRVC_TEMPAD       ] := 0                              // 10 - Tempo Padrao
		aRetorno[ nPosRet , SRVC_TEMTRA       ] := 0                              // 11 - Tempo Trabalhado
		aRetorno[ nPosRet , SRVC_TEMCOB       ] := 0                              // 12 - Tempo Cobranca
		aRetorno[ nPosRet , SRVC_TEMVEN       ] := 0                              // 13 - Tempo Vendido
		aRetorno[ nPosRet , SRVC_APONT        ] := {}                             // 14 - Matriz de Apontamentos do Servico
		aRetorno[ nPosRet , SRVC_DESCRICAO    ] := VO6->VO6_DESSER                // 15 - Descricao do Servico
		aRetorno[ nPosRet , SRVC_DESCRTIPSER  ] := (cAliasSrvc)->VOK_DESSER       // 16 - Descricao do Tipo de Servico
		aRetorno[ nPosRet , SRVC_PERDES       ] := 0                              // 17 - Percentual de Desconto
		aRetorno[ nPosRet , SRVC_CODSEC       ] := (cAliasSrvc)->VO4_CODSEC       // 18 - Codigo da Secao
		aRetorno[ nPosRet , SRVC_KILROD       ] := 0                              // 19 - Kilometros Rodados
		aRetorno[ nPosRet , SRVC_CLIENTE      ] := (cAliasSrvc)->VO4_FATPAR       // 20 - Codigo do Cliente - Faturar Para
		aRetorno[ nPosRet , SRVC_LOJA         ] := (cAliasSrvc)->VO4_LOJA         // 21 - Loja do Cliente - Faturar Para
		aRetorno[ nPosRet , SRVC_DATLIB       ] := StoD((cAliasSrvc)->VO4_DATDIS) // 22 - Data de Liberacao
		aRetorno[ nPosRet , SRVC_DATCAN       ] := StoD((cAliasSrvc)->VO4_DATCAN) // 23 - Data de Cancelamento
		aRetorno[ nPosRet , SRVC_DATFEC       ] := StoD((cAliasSrvc)->VO4_DATFEC) // 24 - Data de Fechamento
		aRetorno[ nPosRet , SRVC_CODFOR       ] := (cAliasSrvc)->VO4_CODFOR       // 25 - (Srvc. Terceiros) - Fornecedor
		aRetorno[ nPosRet , SRVC_FOLOJA       ] := (cAliasSrvc)->VO4_FOLOJA       // 26 - (Srvc. Terceiros) - Loja
		aRetorno[ nPosRet , SRVC_NUMTIT       ] := (cAliasSrvc)->VO4_NUMTIT       // 27 - (Srvc. Terceiros) - Numero do Titulo (Financeiro)
		aRetorno[ nPosRet , SRVC_TIPTIT       ] := (cAliasSrvc)->VO4_TIPTIT       // 28 - (Srvc. Terceiros) - Tipo do Titulo (Financeiro)
		aRetorno[ nPosRet , SRVC_DATPAG       ] := StoD((cAliasSrvc)->VO4_DATPAG) // 29 - (Srvc. Terceiros) - Data do Pagamento
		aRetorno[ nPosRet , SRVC_CODPAG       ] := (cAliasSrvc)->VO4_CODPAG       // 30 - (Srvc. Terceiros) - Cond. de Pagamento
		aRetorno[ nPosRet , SRVC_NATURE       ] := (cAliasSrvc)->VO4_NATURE       // 31 - (Srvc. Terceiros) - Natureza
		aRetorno[ nPosRet , SRVC_VALCUS       ] := (cAliasSrvc)->VO4_VALCUS       // 32 - (Srvc. Terceiros) - Valor do Custo
		aRetorno[ nPosRet , SRVC_INCONV_GRUPO ] := ""                             // 33 - Inconveniente - Grupo
		aRetorno[ nPosRet , SRVC_INCONV_CODIGO] := ""                             // 34 - Inconveniente - Codigo
		aRetorno[ nPosRet , SRVC_INCONV_SEQ   ] := ""                             // 35 - Inconveniente - Sequencia
		aRetorno[ nPosRet , SRVC_INCONV_DESCR ] := ""                             // 36 - Inconveniente - Descricao
		aRetorno[ nPosRet , SRVC_SERINT       ] := (cAliasSrvc)->VO4_SERINT       // 37 - Codigo Interno do Servico
		aRetorno[ nPosRet , SRVC_LIBVOO       ] := ""                             // 38 - Numero da Liberacao do Tipo de Tempo (VOO_LIBVOO)
		aRetorno[ nPosRet , SRVC_VALIMP       ] := IIf( (cAliasSrvc)->VOK_INCMOB <> "2" , (cAliasSrvc)->VSC_TOTIMP , 0 ) // 39 - Valor total de Impostos
		aRetorno[ nPosRet , SRVC_NUMNFI       ] := (cAliasSrvc)->VO4_NUMNFI       // 40 - Numero da Nota Fiscal
		aRetorno[ nPosRet , SRVC_SERNFI       ] := (cAliasSrvc)->VO4_SERNFI       // 41 - Serie da Nota Fiscal
		aRetorno[ nPosRet , SRVC_FUNFEC       ] := (cAliasSrvc)->VO4_FUNFEC       // 42 - Funcionario que fechou o tipo de tempo
		aRetorno[ nPosRet , SRVC_VALHOR       ] := 0                              // 43 - Valor da Hora
		aRetorno[ nPosRet , SRVC_VALSER       ] := 0                              // 44 - Valor Fixo do Servico (quando gravado do VO4)
		aRetorno[ nPosRet , SRVC_DEPINT       ] := (cAliasSrvc)->VO4_DEPINT       // 45 - Departamento Interno
		aRetorno[ nPosRet , SRVC_DEPGAR       ] := (cAliasSrvc)->VO4_DEPGAR       // 46 - Departamento Garantia
		aRetorno[ nPosRet , SRVC_STATUS       ] := FMX_TTSTAT( (cAliasSrvc)->VO4_DATCAN , (cAliasSrvc)->VO4_DATFEC, (cAliasSrvc)->VO4_DATDIS ) // 47 - Status do Tipo de Tempo
		If lVSCContab
			aRetorno[ nPosRet , SRVC_CENCUS   ] := (cAliasSrvc)->VSC_CENCUS       // 48 - Centro de Custo
			aRetorno[ nPosRet , SRVC_CONTA    ] := (cAliasSrvc)->VSC_CONTA        // 49 - Centro de Conta
			aRetorno[ nPosRet , SRVC_ITEMCTA  ] := (cAliasSrvc)->VSC_ITEMCT       // 50 - Item da Conta
			aRetorno[ nPosRet , SRVC_CLVL     ] := (cAliasSrvc)->VSC_CLVL         // 51 - Classe Valor
		Endif
		aRetorno[ nPosRet , SRVC_INCTEM       ] := (cAliasSrvc)->VOK_INCTEM       // 52 - Tempo para Calculo
		aRetorno[ nPosRet , SRVC_GENERICO     ] := IIf( lVO6SRVGEN , ( VO6->VO6_SRVGEN == "1" ) , .F. )	// 53 - Servico Generico

		aRetorno[nPosRet,SRVC_LIBVOO          ] := (cAliasSrvc)->VO4_LIBVOO
		If lVO4FUNDIS
			aRetorno[nPosRet,SRVC_FUNDIS      ] := (cAliasSrvc)->VO4_FUNDIS       // 53 - Tecnico da Liberacao do Tipo de Tempo (VO4_FUNDIS)
		EndIf

		// Se tiver inconveniente ...
		If lVO4SEQINC .and. !Empty((cAliasSrvc)->VO4_SEQINC)
			aAuxInconv := OM420CONSINC( "2" , cNumOS , (cAliasSrvc)->VO4_SEQINC )
			aRetorno[ nPosRet , SRVC_INCONV_GRUPO	] := aAuxInconv[1] // Inconveniente - Grupo
			aRetorno[ nPosRet , SRVC_INCONV_CODIGO	] := aAuxInconv[2] // Inconveniente - Codigo
			aRetorno[ nPosRet , SRVC_INCONV_SEQ		] := aAuxInconv[4] // Inconveniente - Sequencia
			aRetorno[ nPosRet , SRVC_INCONV_DESCR	] := aAuxInconv[3] // Inconveniente - Descricao
			// Se nao tiver e o inconveniente estiver ligado, inicializa os campos ...
		ElseIf lInconveniente
			aRetorno[ nPosRet , SRVC_INCONV_GRUPO	] := Space(nTamGRUINC) // Inconveniente - Grupo
			aRetorno[ nPosRet , SRVC_INCONV_CODIGO	] := Space(nTamCODINC) // Inconveniente - Codigo
			aRetorno[ nPosRet , SRVC_INCONV_SEQ		] := Space(nTamSEQINC) // Inconveniente - Sequencia
			aRetorno[ nPosRet , SRVC_INCONV_DESCR	] := Space(nTamDESINC) // Inconveniente - Descricao
		EndIf
		//

		// Servico ja Fechado ...
		If !Empty((cAliasSrvc)->VO4_DATFEC) .and. ( !Empty((cAliasSrvc)->VO4_NUMNFI) .or. (cAliasSrvc)->VOI_SITTPO == "3" ) .and. !(cAliasSrvc)->VOK_INCMOB $ "256"
			// Se nao for tempo trabalhado, as colunas de tempo padrao e tempo vendido ja estao
			// totalizadas para todos os registros da VSC
//			If (cAliasSrvc)->VOK_INCTEM <> "3"
				cSQL := "SELECT VSC_TEMPAD, VSC_TEMVEN "
				cSQL += " FROM " + RetSQLName("VSC")
				cSQL += " WHERE VSC_FILIAL = '" + xFilial("VSC") + "'"
				cSQL +=   " AND VSC_NUMOSV = '" + (cAliasSrvc)->VO1_NUMOSV + "'"
				cSQL +=   " AND VSC_TIPTEM = '" + (cAliasSrvc)->VO4_TIPTEM + "'"
				cSQL +=   " AND VSC_CODSER = '" + (cAliasSrvc)->VO4_CODSER + "'"
				cSQL +=   " AND VSC_LIBVOO = '" + (cAliasSrvc)->VSC_LIBVOO + "'"
				cSQL += " AND D_E_L_E_T_ = ' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVSC , .F., .T. )
				If !(cAliasVSC)->(Eof())
					aRetorno[ nPosRet , SRVC_TEMPAD] := (cAliasVSC)->VSC_TEMPAD	// 10 - Tempo Padrao
					If (cAliasSrvc)->VOK_INCTEM <> "3"
						aRetorno[ nPosRet , SRVC_TEMVEN] := (cAliasVSC)->VSC_TEMVEN	// 13 - Tempo Vendido
					EndIf
				EndIf
				(cAliasVSC)->(dbCloseArea())
//			EndIf
			//
		EndIf
		//
	EndIf

	// Servico de Terceiro, retorna um registro e cria uma matriz com todas as requisicoes de servicos de terceiros
	If (cAliasSrvc)->VOK_INCMOB == "2"

		if nTamSX3VSCRECVO4 == 0
			nTamSX3VSCRECVO4 := FWTamSX3("VSC_RECVO4")[1]
		endif

		nPosApon := FMX_ADDAPONT(aRetorno[nPosRet,SRVC_APONT])
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_SEQUEN ] := (cAliasSrvc)->VO4_SEQUEN       // 07 - Sequencia
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_RECVO4 ] := (cAliasSrvc)->RECNOVO4         // 08 - RECNO do VO4
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_NOSNUM ] := (cAliasSrvc)->VO4_NOSNUM       // 09 - Nosso Numero de Requisicao
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_CODFOR ] := (cAliasSrvc)->VO4_CODFOR       // 25 - Fornecedor
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_FOLOJA ] := (cAliasSrvc)->VO4_FOLOJA       // 26 - Loja
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_NUMTIT ] := (cAliasSrvc)->VO4_NUMTIT       // 27 - Numero do Titulo (Financeiro)
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_TIPTIT ] := (cAliasSrvc)->VO4_TIPTIT       // 28 - Tipo do Titulo (Financeiro)
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_DATPAG ] := StoD((cAliasSrvc)->VO4_DATPAG) // 29 - Data do Pagamento
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_CODPAG ] := (cAliasSrvc)->VO4_CODPAG       // 30 - Cond. de Pagamento
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_NATURE ] := (cAliasSrvc)->VO4_NATURE       // 31 - Natureza
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_VALCUS ] := (cAliasSrvc)->VO4_VALCUS       // 32 - Valor do Custo
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_VALVEN ] := (cAliasSrvc)->VO4_VALVEN       // 32 - Valor de Venda
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_VALLIQ ] := (cAliasSrvc)->VO4_VALVEN       // 10 - Valor Liquido do Servico (Por Apontamento)
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_RECVSC ] := FM_SQL("SELECT R_E_C_N_O_ FROM " + RetSQLName("VSC") + " VSC WHERE VSC.VSC_FILIAL = '" + xFilial("VSC") + "' AND VSC.VSC_NUMOSV = '" + cNumOS + "' AND VSC.VSC_RECVO4 = '" + StrZero((cAliasSrvc)->RECNOVO4,nTamSX3VSCRECVO4) + "' AND VSC.D_E_L_E_T_ = ' '")
	EndIf

	// Servico ja Fechado ...
	If !Empty((cAliasSrvc)->VO4_DATFEC) .and. ( !Empty((cAliasSrvc)->VO4_NUMNFI) .or. (cAliasSrvc)->VOI_SITTPO == "3" )

		// Tipo de Tempo Interno ...
		If (cAliasSrvc)->VOI_SITTPO == "3"
			if (cAliasSrvc)->VOK_INCMOB == "2"
				aRetorno[ nPosRet , SRVC_VALBRU] += (cAliasSrvc)->VO4_VALVEN	// 07 - Valor do Servico (Valor Bruto)
				aRetorno[ nPosRet , SRVC_VALLIQ] += (cAliasSrvc)->VO4_VALVEN	// 09 - Valor do Servico (Valor Liquido)
			Else
				aRetorno[ nPosRet , SRVC_VALBRU] += (cAliasSrvc)->VO4_VALINT	// 07 - Valor do Servico (Valor Bruto)
				aRetorno[ nPosRet , SRVC_VALLIQ] += (cAliasSrvc)->VO4_VALINT	// 09 - Valor do Servico (Valor Liquido)
			EndIf
		Else
			aRetorno[ nPosRet , SRVC_VALBRU] += (cAliasSrvc)->VSC_VALBRU	// 07 - Valor do Servico (Valor Bruto)
			aRetorno[ nPosRet , SRVC_VALDES] += (cAliasSrvc)->VSC_VALDES	// 08 - Valor do Desconto
			aRetorno[ nPosRet , SRVC_VALLIQ] += (cAliasSrvc)->VSC_VALSER	// 09 - Valor do Servico (Valor Liquido)
		EndIf
		//
		aRetorno[ nPosRet , SRVC_TEMTRA] += (cAliasSrvc)->VSC_TEMTRA	// 11 - Tempo Trabalhado
		aRetorno[ nPosRet , SRVC_TEMCOB] += (cAliasSrvc)->VSC_TEMCOB	// 12 - Tempo Cobrado

		// Cobranca por tempo trabalhado
		If (cAliasSrvc)->VOK_INCTEM == "3"
			aRetorno[ nPosRet , SRVC_TEMVEN] += (cAliasSrvc)->VSC_TEMVEN	// 13 - Tempo Vendido
		EndIf
		//

		If (cAliasSrvc)->VOK_INCMOB == "2"
			aRetorno[ nPosRet , SRVC_VALIMP ] += (cAliasSrvc)->VSC_TOTIMP  // 39 - Valor total de Impostos
		EndIf

		aRetorno[ nPosRet , SRVC_KILROD ] += (cAliasSrvc)->VSC_KILROD  // 39 - Valor total de Impostos

	Else

		// Verifica se o Servico tem Valor Fixo (VO4_VALSER/VO6_VALSER)
		lVlrFixo := .f.
		nVlrSrvc := 0
		If lVO4VALSER .and. (cAliasSrvc)->VO4_VALSER <> 0
			lVlrFixo := .t.
			nVlrSrvc := (cAliasSrvc)->VO4_VALSER
			aRetorno[ nPosRet , SRVC_VALSER	] := nVlrSrvc
		EndIf
		If !lVlrFixo .and. lVO6VALSER
			VO6->(dbSetOrder(2))
			VO6->(MsSeek( xFilial("VO6") + cPMarcaVO6 + (cAliasSrvc)->VO4_CODSER ))
			If VO6->VO6_VALSER > 0
				lVlrFixo := .t.
				nVlrSrvc := VO6->VO6_VALSER
			EndIf
		EndIf
		//

		// Tipo de Cobranca -> 0 = Mao-de-Obra Gratuita
		Do Case
			Case (cAliasSrvc)->VOK_INCMOB == "0"
				aRetorno[ nPosRet , 11 ] += (cAliasSrvc)->VO4_TEMTRA
				// Tempo para Calculo - Trabalhado
				If (cAliasSrvc)->VOK_INCTEM == "3"
					aRetorno[ nPosRet , SRVC_TEMVEN ] += (cAliasSrvc)->VO4_TEMTRA
				// Tempo para Calculo - Fabrica / Concessionaria / Informado
				Else
					aRetorno[ nPosRet , SRVC_TEMVEN ] += (cAliasSrvc)->VO4_TEMPAD
				EndIf
				aRetorno[ nPosRet , SRVC_TEMPAD ] += (cAliasSrvc)->VO4_TEMPAD

			// Tipo de Cobranca -> 1 = Mao-de-Obra / 3 = Vlr Livre c/Base na Tabela / 4 = Retorno de Srv
			Case (cAliasSrvc)->VOK_INCMOB $ "1,3,4"

				// Calcula o Valor da Hora quando nao tem valor Fixo (VO6_VALSER)
				If !lVlrFixo

					if lPEVALHOR // Se existir o ponto de entrada, posicionar nas tabelas VOI/VO1/VO4.
						VOI->(dbSetOrder(1))
						VOI->(MSSeek(xFilial("VOI")+(cAliasSrvc)->VO4_TIPTEM))
						VO1->(dbSetOrder(1))
						VO1->(MSSeek(xFilial("VO1")+cNumOS))
						cSQL := "SELECT VO4.R_E_C_N_O_ RECVO4 "
						cSQL += "FROM "+RetSQLName("VO4")+" VO4 "
						cSQL += "WHERE VO4.VO4_FILIAL='"+xFilial("VO4")+"' AND "
						cSQL += "VO4.VO4_NUMOSV = '"+cNumOS+"' AND VO4.VO4_TIPTEM = '"+(cAliasSrvc)->VO4_TIPTEM+"' AND "
						cSQL += "VO4.VO4_GRUSER = '"+(cAliasSrvc)->VO4_GRUSER+"' AND VO4.VO4_CODSER = '"+(cAliasSrvc)->VO4_CODSER+"' AND "
						cSQL += "VO4.VO4_TIPSER = '"+(cAliasSrvc)->VO4_TIPSER+"' AND VO4.VO4_LIBVOO = '"+(cAliasSrvc)->VO4_LIBVOO+"' AND VO4.D_E_L_E_T_ = ' '"
						nRecVO4 := FM_SQL(cSQL)
						if nRecVO4 > 0
							VO4->(dbGoTo(nRecVO4))
						Endif

					Endif

					dDtReq := dDataBase
					If lVOIVLSVAC 
						If (cAliasSrvc)->VOI_VLSVAC == "1"
							dDtReq := Stod((cAliasSrvc)->VO2_DATREQ)
						ElseIf (cAliasSrvc)->VOI_VLSVAC == "3" // Valor da Data de Abertura da OS
							dDtReq := Stod( IIf( !Empty((cAliasSrvc)->VO1_DATATE), (cAliasSrvc)->VO1_DATATE , (cAliasSrvc)->VO1_DATABE ) )
						EndIf
					EndIf

					nVlrSrvc :=	FMX_VALHOR((cAliasSrvc)->VO4_TIPTEM, ;
											dDtReq, ;
											(cAliasSrvc)->VO4_VHRDIG,;
											(cAliasSrvc)->VO4_VALHOR,;
											(cAliasSrvc)->VO1_CODMAR,;
											(cAliasSrvc)->VO4_CODSER,;
											(cAliasSrvc)->VO4_TIPSER,;
											(cAliasSrvc)->VO4_FATPAR,;
											(cAliasSrvc)->VO4_LOJA,;
											cPMarcaVO6,;
											(cAliasSrvc)->VV1_MODVEI,;
											(cAliasSrvc)->VV1_SEGMOD)

					aRetorno[ nPosRet , SRVC_VALHOR ] := nVlrSrvc

				EndIf
				//

				aRetorno[ nPosRet , SRVC_TEMPAD ] += (cAliasSrvc)->VO4_TEMPAD
				aRetorno[ nPosRet , SRVC_TEMTRA ] += (cAliasSrvc)->VO4_TEMTRA

				// Tempo para Calculo - Trabalhado
				If (cAliasSrvc)->VOK_INCTEM == "3"
					// O Servico nao tem valor fixo (VO6_VALSER)
					If !lVlrFixo
						nVlrSrvc := round(((cAliasSrvc)->VO4_TEMTRA / 100) * nVlrSrvc , 2 )
					EndIf
					//
					aRetorno[ nPosRet , SRVC_TEMCOB ] += (cAliasSrvc)->VO4_TEMTRA
					aRetorno[ nPosRet , SRVC_TEMVEN ] += (cAliasSrvc)->VO4_TEMTRA

				// Tempo para Calculo - Fabrica / Concessionaria / Informado
				Else
					// O Servico nao tem valor fixo (VO6_VALSER)
					If !lVlrFixo
						nVlrSrvc := round(((cAliasSrvc)->VO4_TEMPAD / 100) * nVlrSrvc , 2 )
					EndIf
					//
					aRetorno[ nPosRet , SRVC_TEMCOB ] += (cAliasSrvc)->VO4_TEMPAD
					aRetorno[ nPosRet , SRVC_TEMVEN ] += (cAliasSrvc)->VO4_TEMPAD

				EndIf

			// Tipo de Cobranca -> 2 = Srv de Terceiro
			Case (cAliasSrvc)->VOK_INCMOB == "2"

				// O Servico nao tem valor fixo (VO6_VALSER)
				If !lVlrFixo
					nVlrSrvc := (cAliasSrvc)->VO4_VALVEN
				EndIf
				//

			// Tipo de Cobranca -> 5 = Km Socorro
			Case (cAliasSrvc)->VOK_INCMOB == "5"

				// O Servico nao tem valor fixo (VO6_VALSER)
				If !lVlrFixo
					If lVO4PREKIL .AND. (cAliasSrvc)->VO4_PREKIL <> 0
						nVlrSrvc := Round((cAliasSrvc)->VO4_KILROD * (cAliasSrvc)->VO4_PREKIL,2)
					Else
						nVlrSrvc := Round((cAliasSrvc)->VO4_KILROD * (cAliasSrvc)->VOK_PREKIL,2)
					EndIf
				EndIf
				//

				aRetorno[ nPosRet , SRVC_KILROD ] += (cAliasSrvc)->VO4_KILROD


			// Tipo de Cobranca -> 6 = Franquia
			Case (cAliasSrvc)->VOK_INCMOB == "6"

				// O Servico nao tem valor fixo (VO6_VALSER)
				If !lVlrFixo
					nVlrSrvc := (cAliasSrvc)->VO4_VALVEN
				EndIf
				//

		EndCase
		//

		nPerDes := 0
		nValDes := 0

		// Considera Negociacao salva ...
		If lNegoc

			// Procura negociacao salva ...

			cSQL := "SELECT VZ1_PERDES, VZ1_VALDES, VZ1_VALBRU"
			if lVZ1Contab
				cSQL += ",VZ1_CENCUS,VZ1_CONTA,VZ1_ITEMCT,VZ1_CLVL"
			Endif
			cSQL +=  " FROM " + RetSQLName("VZ1") + " VZ1"
			cSQL += " WHERE VZ1.VZ1_FILIAL = '" + xFilial("VZ1") + "'"
			cSQL +=   " AND VZ1.VZ1_NUMOSV = '" + (cAliasSrvc)->VO1_NUMOSV + "'"
			cSQL +=   " AND VZ1.VZ1_TIPTEM = '" + (cAliasSrvc)->VO4_TIPTEM + "'"
			cSQL +=   " AND VZ1.VZ1_PECSER = 'S'"
			cSQL +=   " AND VZ1.VZ1_TIPSER = '" + (cAliasSrvc)->VO4_TIPSER + "'"
			cSQL +=   " AND VZ1.VZ1_GRUSER = '" + (cAliasSrvc)->VO4_GRUSER + "'"
			cSQL +=   " AND VZ1.VZ1_CODSER = '" + (cAliasSrvc)->VO4_CODSER + "'"
			cSQl +=   " AND VZ1.VZ1_LIBVOO = '" + (cAliasSrvc)->VO4_LIBVOO + "'"
			cSQL +=   " AND VZ1.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVZ1 , .F., .T. )
			// Se a Negociacao ja tiver sido salva ...
			If !(cAliasVZ1)->(Eof())
				// Para servicos de terceiros, so considera o valor no primeiro processamento ...
				If (cAliasSrvc)->VOK_INCMOB == "2" .and. Len( aRetorno[ nPosRet , SRVC_APONT ] ) > 1
					nVlrSrvc := nValDes := nPerDes := 0
				Else
					nPerDes := (cAliasVZ1)->VZ1_PERDES
					nValDes := (cAliasVZ1)->VZ1_VALDES
					nVlrSrvc := (cAliasVZ1)->VZ1_VALBRU
				EndIf
				IF lVZ1Contab
					aRetorno[ nPosRet , SRVC_CENCUS ]  := (cAliasVZ1)->VZ1_CENCUS
					aRetorno[ nPosRet , SRVC_CONTA ]   := (cAliasVZ1)->VZ1_CONTA
					aRetorno[ nPosRet , SRVC_ITEMCTA ] := (cAliasVZ1)->VZ1_ITEMCT
					aRetorno[ nPosRet , SRVC_CLVL ]    := (cAliasVZ1)->VZ1_CLVL
				Endif
			Else
				// Grava Desconto ...
				If lVO4DESCONTO
					nPerDes := (cAliasSrvc)->VO4_PERDES
					nValDes := (cAliasSrvc)->VO4_VALDES
				EndIf
				IF lVZ1Contab
					aRetorno[ nPosRet , SRVC_CENCUS ]  := (cAliasSrvc)->B1_CC
					aRetorno[ nPosRet , SRVC_CONTA ]   := (cAliasSrvc)->B1_CONTA
					aRetorno[ nPosRet , SRVC_ITEMCTA ] := (cAliasSrvc)->B1_ITEMCC
					aRetorno[ nPosRet , SRVC_CLVL ]    := (cAliasSrvc)->B1_CLVL
				Endif
				//
			EndIf
			//
			(cAliasVZ1)->(DbCloseArea())
			dbSelectArea("VZ1")
		Else
			If lVO4DESCONTO
				nPerDes := (cAliasSrvc)->VO4_PERDES
				nValDes := (cAliasSrvc)->VO4_VALDES
			EndIf
		EndIf

		aRetorno[ nPosRet , SRVC_VALBRU ] += nVlrSrvc
		aRetorno[ nPosRet , SRVC_VALDES ] += nValDes
		aRetorno[ nPosRet , SRVC_VALLIQ ] += nVlrSrvc - nValDes

	EndIf
	//
	(cAliasSrvc)->(dbSkip())

End
(cAliasSrvc)->(dbCloseArea())
dbSelectArea("VO4")

// Se houver servicos de terceiros, procesa o valor de desconto
If aScan(aRetorno,{ |x| x[SRVC_INCMOB] == "2" .and. x[SRVC_VALDES] <> 0 }) <> 0

	For nPosRet := 1 to Len(aRetorno)
		If aRetorno[nPosRet,SRVC_INCMOB] <> "2"
			Loop
		EndIf
		aSort( aRetorno[nPosRet,SRVC_APONT] ,,,{|x,y| x[SRVC_APONT_VALVEN] < y[SRVC_APONT_VALVEN] })

		nAuxValor := 0
		For nCont := 1 to Len(aRetorno[nPosRet,SRVC_APONT])
			nPerRat := aRetorno[nPosRet,SRVC_APONT,nCont,SRVC_APONT_VALVEN] / aRetorno[nPosRet,SRVC_VALBRU]
			aRetorno[nPosRet,SRVC_APONT,nCont,SRVC_APONT_VALLIQ] := Round(aRetorno[nPosRet,SRVC_VALLIQ] * nPerRat,2)
			nAuxValor += aRetorno[nPosRet,SRVC_APONT,nCont,SRVC_APONT_VALLIQ]
		Next nCont
		If nAuxValor <> aRetorno[nPosRet,SRVC_VALLIQ]
			aRetorno[nPosRet,SRVC_APONT,Len(aRetorno[nPosRet,SRVC_APONT]),SRVC_APONT_VALLIQ] += aRetorno[nPosRet,SRVC_VALLIQ] - nAuxValor
		EndIf
	Next nPosRet

EndIf
// Calcula Percentual de Desconto
aEval( aRetorno , { |x| x[17] := Round(x[08] / x[07] * 100 ,2) } )
//

// Faz Levantamento de Apontamento ...
If lApont .and. Len(aRetorno) > 0

	cScanRetPd := StrTran(cScanRetPd,"cAliasSrvc","cAliasApon")

	lVAICLAHAB := (VAI->(FieldPos("VAI_CLAHAB")) <> 0)

	// Adiciona na Matriz, todos os apontamentos do servico
	cSQL := "SELECT VO1.VO1_NUMOSV , "
	cSQL +=       " VO2.VO2_FUNREQ, "
	cSQL +=       " VO4.VO4_CODSER, VO4.VO4_TIPTEM, VO4.VO4_CODPRO, VO4.VO4_DATINI, VO4.VO4_HORINI, "
	cSQL +=       " VO4.VO4_DATFIN, VO4.VO4_HORFIN, VO4.VO4_TEMTRA, VO4.VO4_SEQUEN, VO4.R_E_C_N_O_ RECNOVO4, "
	cSQL +=       " VO4.VO4_NOSNUM, VO4.VO4_DATFEC, VO4.VO4_CODFOR, VO4.VO4_FOLOJA, VO4.VO4_NUMTIT, "
	cSQL +=       " VO4.VO4_TIPTIT, VO4.VO4_SEQINC, VO4.VO4_VALINT, VO4.VO4_HOREXT, VO4.VO4_TIPSER, VO4.VO4_LIBVOO, "
	If lVO4FUNDIS
		cSQL += " VO4.VO4_FUNDIS, "
	EndIf
	If lVO4MPAUSA
		cSQL += " VO4.VO4_MPAUSA, "
	EndIf
	cSQL += IIF(VO4->(FieldPos("VO4_PERRAT")) <> 0, "VO4.VO4_PERRAT, "," 0 VO4_PERRAT, ")
	cSQL +=       " VOI.VOI_SITTPO, "
	cSQL +=       " VSC.VSC_VALSER, VSC.VSC_TEMCOB, VSC.VSC_TEMVEN, VSC.R_E_C_N_O_ RECNOVSC, "
	cSQL += IIF(VAI->(FieldPos("VAI_CUSTHR")) <> 0, "VAI.VAI_CUSTHR, "," 0 VAI_CUSTHR, ")
	If lVAICLAHAB
		cSQL +=       " VAI.VAI_CLAHAB, "
	Endif
	cSQL +=       " VAI.VAI_NOMTEC "
	cSQL +=  " FROM " + RetSQLName("VO1") + " VO1 "
	cSQL +=         " JOIN " + RetSQLName("VO2") + " VO2 ON VO2.VO2_FILIAL = '" + xFilial("VO2") + "' AND VO2.VO2_NUMOSV = VO1.VO1_NUMOSV AND VO2.D_E_L_E_T_ = ' '"
	cSQL +=         " JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.D_E_L_E_T_ = ' '"
	cSQL +=         " JOIN " + RetSQLName("VOK") + " VOK ON VOK.VOK_FILIAL = '" + xFilial("VOK") + "' AND VOK.VOK_TIPSER = VO4.VO4_TIPSER AND VOK.D_E_L_E_T_ = ' '"
	cSQL +=         " JOIN " + RetSQLName("VOI") + " VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO4.VO4_TIPTEM AND VOI.D_E_L_E_T_ = ' '"
	cSQL +=         " LEFT JOIN " + RetSQLName("VSC") + " VSC " +;
							"  ON VSC.VSC_FILIAL = '" + xFilial("VSC") + "'" +;
							" AND VSC.VSC_NUMOSV = VO1.VO1_NUMOSV " +;
							" AND VSC.VSC_TIPTEM = VO4.VO4_TIPTEM " +;
							" AND ( " +;
							    " ( " + iif( "POSTGRE" $ cSGBD , "CAST(VSC.VSC_RECVO4 as BIGINT) " , "VSC.VSC_RECVO4" ) + " = VO4.R_E_C_N_O_ AND VO4.VO4_VSCIDE = ' ' ) " +;
								 " OR " +;
							    " ( VSC.VSC_NUMIDE = VO4.VO4_VSCIDE AND VO4.VO4_VSCIDE <> ' ' ) " +;
								 " ) " +;
							" AND VSC.D_E_L_E_T_ = ' '"

	cSQL +=         " LEFT JOIN " + RetSQLName("VAI") + " VAI ON VAI.VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI.VAI_CODTEC = VO4.VO4_CODPRO AND VAI.D_E_L_E_T_ = ' '"
	cSQL += " WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "'"
	cSQL +=   " AND VO1.VO1_NUMOSV = '" + cNumOS + "'"
	cSQL +=   " AND VO1.D_E_L_E_T_ = ' '"
	cSQL +=   " AND VOK.VOK_INCMOB <> '2'" // Nao processa servico de terceiros
	cSQL +=   " AND VO2.VO2_TIPREQ = 'S'" // Requisicao de Servico
	If !Empty(cTipTem)
		cSQL +=   " AND VO4.VO4_TIPTEM = '" + cTipTem + "'"
	EndIf
	If !Empty(cGruSer)
		cSQL +=   " AND VO4.VO4_GRUSER = '" + cGruSer + "'"
	EndIf
	If !Empty(cCodSer)
		cSQL +=   " AND VO4.VO4_CODSER = '" + cCodSer + "'"
	EndIf
	If Len(cLibVOO) <> 0 .and. !Empty(cTipTem)
		cSQl +=   " AND VO4.VO4_LIBVOO = '" + cLibVOO + "'"
	EndIf
	If !Empty(cFiltroSQL)
		cSQL += " AND ( " + cFiltroSQL + " )"
	EndIf

	cSQL += " ORDER BY VO4.VO4_CODSER, VO4.VO4_CODPRO, VO4.VO4_DATINI, VO4.VO4_HORINI "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasApon , .F., .T. )
	While !(cAliasApon)->(Eof())

		// Se o inconveniente estiver desligado, mas tiver conteudo na
		// coluna de inconveniente, deve quebrar por codigo de inconveniente
		If !lInconveniente .and. ( lVO4SEQINC .and. !Empty((cAliasApon)->VO4_SEQINC))
			cAuxScan := cScanRetPd + " .and. x[35] == (cAliasApon)->VO4_SEQINC"
		Else
			cAuxScan := cScanRetPd
		EndIf
		nPosRet := aScan( aRetorno , &("{ |x| " + cAuxScan + " }" ) )
		If nPosRet == 0
			(cAliasApon)->(dbSkip())
			Loop
		EndIf
		nPosApon := FMX_ADDAPONT( @aRetorno[nPosRet,SRVC_APONT] )
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_CODIGO ] := (cAliasApon)->VO4_CODPRO			// 14,01 - Codigo do Produtivo
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_DATINI ] := StoD((cAliasApon)->VO4_DATINI)	// 14,02 - Data Inicial do Apontamento
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_HORINI ] := (cAliasApon)->VO4_HORINI			// 14,03 - Hora Inicial do Apontamento
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_DATFIN ] := StoD((cAliasApon)->VO4_DATFIN)	// 14,04 - Data Final do Apontamento
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_HOTFIN ] := (cAliasApon)->VO4_HORFIN			// 14,05 - Hora Final do Apontamento
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_TEMTRA ] := (cAliasApon)->VO4_TEMTRA			// 14,06 - Tempo Trabalhado
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_SEQUEN ] := (cAliasApon)->VO4_SEQUEN			// 14,07 - Sequencia
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_RECVO4 ] := (cAliasApon)->RECNOVO4				// 14,08 - RECNO do VO4
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_NOSNUM ] := (cAliasApon)->VO4_NOSNUM			// 14,09 - Nosso Numero de Requisicao
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_NOME   ] := (cAliasApon)->VAI_NOMTEC			// 14,12 - Nome do Produtivo
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_FUNREQ ] := (cAliasApon)->VO2_FUNREQ			// 14,14 - Funcionario que requisitou
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_PERRAT ] := (cAliasApon)->VO4_PERRAT			// 14,15 - Percentual de Rateio
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_CUSHOR ] := (cAliasApon)->VAI_CUSTHR			// 14,26 - Custo da Hora Trabalhada (Custo de Hora por Produtivo)
		aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_HOREXT ] := (cAliasApon)->VO4_HOREXT			// 14,28 - Tipo da Hora

		If lVAICLAHAB
			aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_CLAHAB ] := (cAliasApon)->VAI_CLAHAB		// 14,29 - Classifica็ใo da Habilidade
		EndIf

		If !Empty((cAliasApon)->VO4_DATFEC)
			// Tipo de Tempo Interno ...
			If (cAliasApon)->VOI_SITTPO == "3"
				aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_VALLIQ ] := (cAliasApon)->VO4_VALINT	// 14,10 - Valor Liquido do Servico (Por Apontamento)
			Else
				aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_VALLIQ ] := (cAliasApon)->VSC_VALSER	// 14,10 - Valor Liquido do Servico (Por Apontamento)
			EndIf
			aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_RECVSC ] := (cAliasApon)->RECNOVSC			// 14,11 - RECNO do VSC
			aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_TEMCOB ] := (cAliasApon)->VSC_TEMCOB		// 14,13 - Tempo Cobrado proporcional ao Tempo Trabalhado
		EndIf

		If lVO4MPAUSA
			aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_MPAUSA ] := (cAliasApon)->VO4_MPAUSA		// 14,15 - Motivo da Pausa
		EndIf

		(cAliasApon)->(dbSkip())
	End
	(cAliasApon)->(dbCloseArea())
	dbSelectArea("VO4")

	// Calcula valor do servico e tempo cobrado por apontamento quando servico
	// nใo estiver faturado
	For nPosRet := 1 to Len(aRetorno)

		If aRetorno[nPosRet,SRVC_INCMOB] == "2"
			Loop
		EndIf

		nAuxPerc := 0
		nAuxVlrSer := 0
		nAuxTemCob := 0
		nAuxTemVen := 0
		nAuxValor := 0
		For nPosApon := 1 to Len(aRetorno[nPosRet,SRVC_APONT])

			nAuxPerc := aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_TEMTRA ] / aRetorno[ nPosRet , SRVC_TEMTRA ]

			If Empty(aRetorno[nPosRet,SRVC_DATFEC])
				If aRetorno[ nPosRet , SRVC_VALLIQ ] <> 0
					// Calcula o valor do servico proporcional
					nAuxValor := Round( aRetorno[ nPosRet , SRVC_VALLIQ ] * nAuxPerc , 2 )
					nAuxVlrSer += nAuxValor
					If nPosApon == Len(aRetorno[nPosRet , SRVC_APONT ]) .and. nAuxVlrSer <> aRetorno[ nPosRet , SRVC_VALLIQ ]
						nAuxValor += (aRetorno[ nPosRet , SRVC_VALLIQ ] - nAuxVlrSer)
					EndIf
					aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_VALLIQ ] := nAuxValor
					//
				EndIf

				If aRetorno[ nPosRet , SRVC_TEMCOB ] <> 0
					// Calcula o tempo cobrado proporcional
					nAuxValor := Round( aRetorno[ nPosRet , SRVC_TEMCOB ] * nAuxPerc , 0 )
					nAuxTemCob += nAuxValor
					If nPosApon == Len(aRetorno[ nPosRet , SRVC_APONT ]) .and. nAuxTemCob <> aRetorno[ nPosRet , SRVC_TEMCOB ]
						nAuxValor += (aRetorno[ nPosRet , SRVC_TEMCOB ] - nAuxTemCob)
					EndIf
					aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_TEMCOB ] := nAuxValor
					//
				EndIf
			EndIf

			// Calcula tempo vendido porporcional
			nAuxValor := Round( aRetorno[ nPosRet , SRVC_TEMVEN ] * nAuxPerc , 0 )
			nAuxTemVen += nAuxValor
			If nPosApon == Len(aRetorno[nPosRet , SRVC_APONT ]) .and. nAuxTemVen <> aRetorno[ nPosRet , SRVC_TEMVEN ]
				nAuxValor += (aRetorno[ nPosRet , SRVC_TEMVEN ] - nAuxTemVen)
			EndIf
			aRetorno[ nPosRet , SRVC_APONT , nPosApon , SRVC_APONT_TEMVEN ] := nAuxValor // 14,27 - Tempo Vendido
			//

		Next nPosApon
	Next nPosRet
	//

EndIf

if lPEVALHOR // Se existir o ponto de entrada, posicionar nas tabelas VOI/VO1/VO4.
	VOI->(dbgoto(_recvoi))
	VO1->(dbgoto(_recvo1))
	VO4->(dbgoto(_recvo4))
Endif
RestArea( oArea )

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออ/อัออออออออออออออหอออออออัออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_ADDAPONT  บAutor  ณTakahashi       บ Data ณ  22/12/10  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Adiciona linha na matriz de apontamento                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao FMX_CALSER                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FMX_ADDAPONT( aAuxApont )

AADD( aAuxApont , { ;
	" "       ,; // SRVC_APONT_CODIGO - 01 - Codigo do Produtivo
	CtoD(" ") ,; // SRVC_APONT_DATINI - 02 - Data Inicial
	0         ,; // SRVC_APONT_HORINI - 03 - Hora Inicial
	CtoD(" ") ,; // SRVC_APONT_DATFIN - 04 - Data Final
	0         ,; // SRVC_APONT_HOTFIN - 05 - Hora Final
	0         ,; // SRVC_APONT_TEMTRA - 06 - Tempo Trabalhado (MINUTOS CENTESIMAL)
	""        ,; // SRVC_APONT_SEQUEN - 07 - Sequencia (VO4_SEQUEN)
	0         ,; // SRVC_APONT_RECVO4 - 08 - Recno da VO4
	""        ,; // SRVC_APONT_NOSNUM - 09 - Nosso Numero Requisicao (VO4_NOSNUM)
	0         ,; // SRVC_APONT_VALLIQ - 10 - Valor Liquido do Servico (Por Apontamento)
	0         ,; // SRVC_APONT_RECVSC - 11 - Recno da VSC
	" "       ,; // SRVC_APONT_NOME   - 12 - Nome do Produtivo
	0         ,; // SRVC_APONT_TEMCOB - 13 - Tempo cobrado proporcional ao Tempo Trabalhado
	""        ,; // SRVC_APONT_FUNREQ - 14 - Funcionario que requisitou
	""        ,; // SRVC_APONT_MPAUSA - 15 - Motivo da Pausa
	0         ,; // SRVC_APONT_PERRAT - 16 - Perc. de Rateio
	""        ,; // SRVC_APONT_CODFOR - 17 - (Srvc. Terceiros) - Fornecedor
	""        ,; // SRVC_APONT_FOLOJA - 18 - (Srvc. Terceiros) - Loja
	""        ,; // SRVC_APONT_NUMTIT - 19 - (Srvc. Terceiros) - Numero do Titulo (Financeiro)
	""        ,; // SRVC_APONT_TIPTIT - 20 - (Srvc. Terceiros) - Tipo do Titulo (Financeiro)
	CtoD(" ") ,; // SRVC_APONT_DATPAG - 21 - (Srvc. Terceiros) - Data do Pagamento
	""        ,; // SRVC_APONT_CODPAG - 22 - (Srvc. Terceiros) - Cond. de Pagamento
	""        ,; // SRVC_APONT_NATURE - 23 - (Srvc. Terceiros) - Natureza
	0         ,; // SRVC_APONT_VALCUS - 24 - (Srvc. Terceiros) - Valor do Custo
	0         ,; // SRVC_APONT_VALVEN - 25 - (Srvc. Terceiros) - Valor da Venda
	0         ,; // SRVC_APONT_CUSHOR - 26 - Custo da Hora Trabalhada (Custo de Hora por Produtivo)
	0         ,; // SRVC_APONT_TEMVEN - 27 - Tempo vendido
	""        ,; // SRVC_APONT_TEMVEN - 28 - Tipo da Hora
	""         ; // SRVC_APONT_CLAHAB - 29 - Classifica็ao da Habilidade
	})

Return Len( aAuxApont )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ FMX_CALPEC บAutor  ณ Takahashi          บ Data ณ  01/06/11 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula valor de requisicao de Pecas de Uma OS/TT          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumOS = Numero da Ordem de Servico                        บฑฑ
ฑฑบ          ณ cTipTem = Tipo de Tempo                                    บฑฑ
ฑฑบ          ณ cGruIte = Grupo do Item                                    บฑฑ
ฑฑบ          ณ cCodIte = Codigo do Item                                   บฑฑ
ฑฑบ          ณ lMov = Gera matriz com movimentacoes da peca               บฑฑ
ฑฑบ          ณ lNegoc = Considera Valor de Negociacao Gravado (VZ1)       บฑฑ
ฑฑบ          ณ lReqZerada = Remove itens com qtde zerada                  บฑฑ
ฑฑบ          ณ lRetAbe = Retorna Tipo de Tempo Aberto                     บฑฑ
ฑฑบ          ณ lRetLib = Retorna Tipo de Tempo Liberado                   บฑฑ
ฑฑบ          ณ lRetFec = Retorna Tipo de Tempo Fechado                    บฑฑ
ฑฑบ          ณ lRetCan = Retorna Tipo de Tempo Cancelado                  บฑฑ
ฑฑบ          ณ cLibVOO = Numero da Liberacao no VOO                       บฑฑ
ฑฑบ          ณ cFiltroSQL = Filtro SQL                                    บฑฑ
ฑฑบ          ณ lRetRem = Calcula saldo de pe็as em remessa para at. ext.  บฑฑ
ฑฑบ          ณ lAgrInc = Agrupa PECAS por Inconveniente ?                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Verificar o Retorno no OFIXDEF.CH                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_CALPEC(cNumOS,cTipTem,cGruIte,cCodIte,lMov,lNegoc,lReqZerada,lRetAbe,lRetLib,lRetFec,lRetCan,cLibVOO,cFiltroSQL,lRetRem,lAgrInc)

Local cSQL         := ""
Local cAliasPec	   := "TREQPEC"
Local lVO3VALLIQ   := (VO3->(FieldPos("VO3_VALLIQ")) <> 0)
Local lVO3SEQINC   := (VO3->(FieldPos("VO3_SEQINC")) <> 0)
Local lVZ1FORMUL   := (VZ1->(FieldPos("VZ1_FORMUL")) <> 0)
Local lVZ1Acresc   := (VZ1->(FieldPos("VZ1_ACRESC")) <> 0)
Local lVO3VECREL   := (VO3->(FieldPos("VO3_VECREL")) <> 0)
Local lVZ1Contab :=  ( VZ1->(FieldPos("VZ1_CENCUS")) > 0 .and. VZ1->(FieldPos("VZ1_CONTA")) > 0 .and. VZ1->(FieldPos("VZ1_ITEMCT")) > 0 .and. VZ1->(FieldPos("VZ1_CLVL")) > 0 ) // Campos para a contabilizacao - VZ1
Local lVECContab :=  ( VEC->(FieldPos("VEC_CENCUS")) > 0 .and. VEC->(FieldPos("VEC_CONTA")) > 0 .and. VEC->(FieldPos("VEC_ITEMCT")) > 0 .and. VEC->(FieldPos("VEC_CLVL")) > 0 ) // Campos para a contabilizacao - VEC
Local lVO3FUNDIS   := (VO3->(FieldPos("VO3_FUNDIS")) <> 0)
Local aAreaSA1	   := SA1->(GetArea())
Local aAreaVOI	   := VOI->(GetArea())
Local aAreaVO1	   := VO1->(GetArea())
Local aAreaVO2	   := VO2->(GetArea())
Local aAreaVO3	   := VO3->(GetArea())
Local aAreaVZ1	   := VZ1->(GetArea())
Local cProdAtu	   := "" // Produto que esta sendo processado atualmente, utilizado para nao chamar funcao de calculo de produto varias vezes sem necessidade
Local nMulti	     := 1  // Utilizado para converter valor qtde / valor (Requisicao / Devolucao)
Local nPos		     := 0
Local nPosMov	     := 0
Local oArea 	     := GetArea()
Local lJaFec	     := .f. // Controla se a requisicao ja foi fechada ...
Local aAuxInconv   := {}
Local nTamGRUINC   := 0
Local nTamCODINC   := 0
Local nTamSEQINC   := 0
Local nTamDESINC   := 0

Local nVO3ValPec   := 0 // Valor da Peca gravada na VO3, quando estiver faturado considera o valor da VEC

Local cScanRetPd   := "" // String Padrao utilizado no CodeBlock para procurar o item na matriz de retorno
Local cAuxScan	   := "" // String utilizado no CodeBlock para procurar o item na matriz de retorno
Local aRetorno	   := {}
Local nCont



Local lExistVZ1    := .f.
Local nRecVZ1      := 0
Local lFecAnt      := .f. // Indica se a OS foi fechada antes da criacao do item da nota fiscal
Local lPrecoReq    := .f.

Default cTipTem	   := ""
Default cGruIte	   := ""
Default cCodIte	   := ""
Default lMov       := .f.
Default lNegoc 	   := .f.
Default lReqZerada := .f.
Default lRetAbe    := .t.
Default lRetLib    := .t.
Default lRetFec    := .t.
Default lRetCan    := .t.
Default cLibVOO    := ""
Default cFiltroSQL := ""
Default lRetRem    := .f. // Indica se calcula o saldo de pecas em remessa
Default lAgrInc    := .t.

// Se calcula pecas em remessa, verifica se existe a tabela de movimentacao de remessa de pecas
If lRetRem .and. !AliasInDic("VDR")
	lRetRem := .f.
EndIf

If lVO3SEQINC
	nTamGRUINC := TamSX3("VST_GRUINC")[1]
	nTamCODINC := TamSX3("VST_CODINC")[1]
	nTamSEQINC := TamSX3("VST_SEQINC")[1]
	nTamDESINC := TamSX3("VST_DESINC")[1]
EndIf

// Block padrao para procurar o item na matriz de retorno ...
cScanRetPd := "x[01] == (cAliasPec)->VO3_GRUITE"
cScanRetPd += " .and. x[02] == (cAliasPec)->VO3_CODITE"
cScanRetPd += " .and. x[03] == (cAliasPec)->VO3_TIPTEM"
cScanRetPd += " .and. x[04] == (cAliasPec)->VO2_NUMOSV"
//cScanRetPd += " .and. x[06] == nVO3ValPec"
//cScanRetPd += " .and. x[09] == nValPec"
cScanRetPd += " .and. x[25] == (cAliasPec)->VO3_LIBVOO"
If lInconveniente .and. lAgrInc
	cScanRetPd += " .and. x[22] == (cAliasPec)->VO3_SEQINC"
EndIf
cScanRetPd += " .and. x[24] == cAuxTES"
If lCtrlLote
	cScanRetPd += " .and. x[43] == (cAliasPec)->VO3_LOTECT"
	cScanRetPd += " .and. x[44] == (cAliasPec)->VO3_NUMLOT"
EndIf
//

SA1->(dbSetOrder(1))
VZ1->(dbSetOrder(3))
VSF->(dbSetOrder(1))

cSQL := "SELECT VO2.VO2_NUMOSV, VO2.VO2_NOSNUM, VO2.VO2_DEVOLU ,VO2.VO2_DATREQ, VO2_FUNREQ "
cSQL +=       " , VO3_GRUITE, VO3_CODITE, VO3_TIPTEM, VO3_OPER, VO3_CODTES, VO3_VALPEC, VO3_DEPINT, VO3_DEPGAR, VO3_QTDREQ, VO3_FATPAR, VO3_LOJA, VO3_FORMUL "
cSQL +=       " , VO3_FATPAR, VO3_LOJA, VO3_PROREQ , VO3_FUNFEC "
cSQL +=       " , VO3_DATDIS, VO3_DATCAN, VO3_DATFEC, VO3_NUMNFI, VO3_SERNFI, VO3_LIBVOO "
If lVO3VALLIQ
	cSQL += " , VO3_VALDES , VO3_VALLIQ "
EndIf
If lVO3SEQINC
	cSQL += " , VO3_SEQINC"
EndIf
If lCtrlLote
	cSQL += " , VO3_NUMLOT, VO3_LOTECT "
EndIf
If lVO3FUNDIS
	cSQL += " , VO3_FUNDIS"
EndIf
if lVECContab
	cSQL += " , VEC_CENCUS,VEC_CONTA,VEC_ITEMCT,VEC_CLVL"
Endif
If lVZ1Contab
	cSQL += " , B1_CC, B1_CONTA, B1_ITEMCC, B1_CLVL"
Endif
cSQL +=       " , B1_DESC, B1_MSBLQL"
cSQL +=       " , VOI_VLPCAC"
cSQL +=       " , VO2.R_E_C_N_O_ RECNOVO2, VO3.R_E_C_N_O_ RECNOVO3"
If lVO3VECREL
	cSQL +=       " , VO3_VECREL "
	cSQL +=       " , VEC_QTDITE, VEC_VALBRU, VEC_VALDES, VEC_VALVDA, VEC_ICMSRT, VEC_TOTIMP, VEC_CUSTOT "
EndIf
cSQL +=       " , F4_INCSOL "
cSQL +=  " FROM " + RetSQLName("VO2") + " VO2 "
cSQL +=         " JOIN " + RetSQLName("VO3") + " VO3 ON VO3.VO3_FILIAL = '" + xFilial("VO3") + "' AND VO3_NOSNUM = VO2_NOSNUM AND VO3.VO3_NUMOSV = VO2.VO2_NUMOSV AND VO3.D_E_L_E_T_ = ' '"
cSQL +=         " JOIN " + RetSQLName("VOI") + " VOI ON VOI.VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO3.VO3_TIPTEM AND VOI.D_E_L_E_T_ = ' '"
cSQL +=         " JOIN " + RetSQLName("SB1") + "  B1 ON B1.B1_FILIAL = '" + xFilial("SB1") + "' AND B1.B1_GRUPO = VO3.VO3_GRUITE AND B1.B1_CODITE = VO3.VO3_CODITE AND B1.D_E_L_E_T_ = ' '"
cSQL +=         " JOIN " + RetSQLName("SF4") + "  F4 ON F4.F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = VO3.VO3_CODTES AND F4.D_E_L_E_T_ = ' '"
//cSQL +=         " LEFT JOIN " + RetSQLName("VEC") + " VEC ON VEC.VEC_FILIAL = '" + xFilial("VEC") + "' AND VEC.VEC_NUMOSV = VO2.VO2_NUMOSV AND VEC.VEC_TIPTEM = VO3.VO3_TIPTEM AND VEC.VEC_PECINT = VO3.VO3_PECINT AND VEC.D_E_L_E_T_ = ' '"
If lVO3VECREL
	cSQL +=      " LEFT JOIN " + RetSQLName("VEC") + " VEC ON VEC.VEC_FILIAL = '" + xFilial("VEC") + "' AND VEC.VEC_NUMOSV = VO2.VO2_NUMOSV AND VEC.VEC_NUMREL = VO3.VO3_VECREL AND VO3.VO3_VECREL <> '  ' AND VEC.D_E_L_E_T_ = ' '"
EndIf
cSQL += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
cSQL +=   " AND VO2.VO2_NUMOSV = '" + cNumOS + "'"
cSQL +=   " AND VO2.VO2_TIPREQ = 'P'" // Requisicao de Pecas
cSQL +=   " AND VO2.D_E_L_E_T_ = ' '"
If !Empty(cTipTem)
	cSQL +=   " AND VO3.VO3_TIPTEM = '" + cTipTem + "'"
EndIf
If !Empty(cGruIte)
	cSQL +=   " AND VO3.VO3_GRUITE = '" + cGruIte + "'"
EndIf
If !Empty(cCodIte)
	cSQL +=   " AND VO3.VO3_CODITE = '" + cCodIte + "'"
EndIf
If !lRetAbe
	cSQL +=   " AND ( VO3.VO3_DATDIS <> '        ' OR VO3.VO3_DATFEC <> '        ' OR VO3.VO3_DATCAN <> '        ' )"
EndIf
If !lRetLib
	cSQL +=   " AND VO3.VO3_DATDIS = '        '"
EndIf
If !lRetFec
	cSQL +=   " AND VO3.VO3_DATFEC = '        '"
EndIf
If !lRetCan
	cSQL +=   " AND VO3.VO3_DATCAN = '        '"
EndIf
If !Empty(cTipTem) .and. Len(cLibVOO) <> 0
	cSQL +=   " AND VO3.VO3_LIBVOO = '" + cLibVOO + "'"
EndIf
If !Empty(cFiltroSQL)
	cSQL += " AND ( " + cFiltroSQL + " )"
EndIf
cSQL += " ORDER BY VO2_NUMOSV, VO3_TIPTEM , VO3_GRUITE, VO3_CODITE , VO2_NOSNUM "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasPec , .F., .T. )

While !(cAliasPec)->(Eof())

	lJaFec := .F.
	lFecAnt := .f.
	lPrecoReq := .f.

	// Peca ja Fechada ...
	If !Empty((cAliasPec)->VO3_DATFEC) .and. !Empty((cAliasPec)->VO3_NUMNFI)
		If lVO3VECREL .and. !Empty((cAliasPec)->VO3_VECREL)
			// F4_INCSOL - "S":agrega o valor do ICMS solidario no total da Nota Fiscal
			If (cAliasPec)->F4_INCSOL == "S"
				nValPecLiq := ((cAliasPec)->VEC_VALVDA + (cAliasPec)->VEC_ICMSRT) / (cAliasPec)->VEC_QTDITE
				nVO3ValPec := nValPec := ((cAliasPec)->VEC_VALVDA + (cAliasPec)->VEC_ICMSRT + (cAliasPec)->VEC_VALDES) / (cAliasPec)->VEC_QTDITE
			Else
				nValPecLiq := (cAliasPec)->VEC_VALVDA / (cAliasPec)->VEC_QTDITE
				nVO3ValPec := nValPec := ((cAliasPec)->VEC_VALVDA + (cAliasPec)->VEC_VALDES) / (cAliasPec)->VEC_QTDITE
			EndIf
			lJaFec     := .t.
		Else
			lFecAnt := .t.
			nValPecLiq := nVO3ValPec := nValPec := 0
			nVO3ValPec := (cAliasPec)->VO3_VALPEC
		EndIf

	Else

		nVO3ValPec := (cAliasPec)->VO3_VALPEC

		// Valor da Peca ้ o Valor da Requisicao
		IF (cAliasPec)->VOI_VLPCAC == "1"
			// Valor da Peca sem Desconto
			nValPecLiq := nValPec := (cAliasPec)->VO3_VALPEC
			IF lVO3VALLIQ .and. (cAliasPec)->VO3_VALLIQ > 0
				nValPecLiq := (cAliasPec)->VO3_VALLIQ
			ENDIF
		// Valor da Peca ้ o Valor da Atual
		ElseIf (cAliasPec)->VOI_VLPCAC == "2"

			// So processa funcao para calculo do valor da peca quando
			// for produto diferente, pois senao ira chamar varias vezes sem necessidade
			If cProdAtu <> ((cAliasPec)->VO3_GRUITE + (cAliasPec)->VO3_CODITE + (cAliasPec)->VO3_FORMUL)

				cProdAtu := ((cAliasPec)->VO3_GRUITE + (cAliasPec)->VO3_CODITE + (cAliasPec)->VO3_FORMUL)

				SA1->(dbSeek( xFilial("SA1") + (cAliasPec)->VO3_FATPAR + (cAliasPec)->VO3_LOJA ))
				VOI->(dbSeek( xFilial("VOI") + (cAliasPec)->VO3_TIPTEM ))
				VO1->(dbSeek( xFilial("VO1") + cNumOS ))
				VO2->(dbGoTo( (cAliasPec)->RECNOVO2 ))
				VO3->(dbGoTo( (cAliasPec)->RECNOVO3 ))
				nValPecLiq := nValPec := FG_VALPEC( (cAliasPec)->VO3_TIPTEM,;
													(cAliasPec+"->VO3_FORMUL"),;
													(cAliasPec)->VO3_GRUITE,;
													(cAliasPec)->VO3_CODITE,;
													,;
													.f.,;
													.t.)
			EndIf
			//
		EndIf

	EndIf

	// Requisicao
	If (cAliasPec)->VO2_DEVOLU == '1'
		nMulti := 1
	// Devolucao
	Else
		nMulti := -1
	EndIf

	cAuxTES := (cAliasPec)->VO3_CODTES

	// Procura Negociacao salva ...
	If lNegoc .or. lJaFec

		cSQL := "SELECT R_E_C_N_O_ RECVZ1 "
		cSQL +=  " FROM " + RetSQLName("VZ1")
		cSQL += " WHERE VZ1_FILIAL = '" + xFilial("VZ1") + "' "
		cSQL +=   " AND VZ1_NUMOSV = '" + (cAliasPec)->VO2_NUMOSV + "' "
		cSQL +=   " AND VZ1_TIPTEM = '" + (cAliasPec)->VO3_TIPTEM + "' "
		cSQL +=   " AND VZ1_PECSER = 'P' "
		cSQL +=   " AND VZ1_GRUITE = '" + (cAliasPec)->VO3_GRUITE + "' "
		cSQL +=   " AND VZ1_CODITE = '" + (cAliasPec)->VO3_CODITE + "' "
		cSQL +=   " AND VZ1_LIBVOO = '" + (cAliasPec)->VO3_LIBVOO + "' "
		If lVZ1FORMUL
			cSQL += " AND VZ1_FORMUL = '" + (cAliasPec)->VO3_FORMUL + "' "
		EndIf
		// Utiliza o valor da peca da requisicao
		IF (cAliasPec)->VOI_VLPCAC == "1"
			cSQL +=   " AND VZ1_VALUNI = " + Alltrim(str(nVO3ValPec)) + " "
		EndIf
		cSQL +=   " AND D_E_L_E_T_ = ' '"
		nRecVZ1 := FM_SQL(cSQL)
		lExistVZ1 := .f.
		If nRecVZ1 > 0
			//
			VZ1->(DbGoTo(nRecVZ1))
			//
			lExistVZ1 := .t.
			cAuxTES   := VZ1->VZ1_CODTES
			//
		EndIf

	EndIf
	//

	cAuxScan := cScanRetPd

	// Se o TT estแ configurado para considerar preco de peca atual, verifica se existe mais de um VEC
	// Se existir, provavelmente o TT estava configurado para utilizar o preco da requisicao da peca
	IF (cAliasPec)->VOI_VLPCAC == "2" .and. lFecAnt
		cSQL := "SELECT COUNT(*) "
		cSQL +=  " FROM " + RetSQLName("VEC") + " VEC "
		cSQL += " WHERE VEC.VEC_FILIAL = '" + xFilial("VEC") + "'"
		cSQL +=   " AND VEC.VEC_NUMOSV = '" + (cAliasPec)->VO2_NUMOSV + "'"
		cSQL +=   " AND VEC.VEC_TIPTEM = '" + (cAliasPec)->VO3_TIPTEM + "'"
		cSQL +=   " AND VEC.VEC_GRUITE = '" + (cAliasPec)->VO3_GRUITE + "'"
		cSQL +=   " AND VEC.VEC_CODITE = '" + (cAliasPec)->VO3_CODITE + "'"
		cSQL +=   " AND VEC.VEC_LIBVOO = '" + (cAliasPec)->VO3_LIBVOO + "'"
		cSQL +=   " AND VEC.D_E_L_E_T_ = ' ' "
		lPrecoReq := (FM_SQL(cSQL) > 1)
	EndIf

	// Se ja foi fechado, e existir registro na VSF trata-se de um fechamento pelo OFIOM160, nesse caso soma as requisicoes
	// pois era fechado com o valor medio das requisicoes ...
	If !( !Empty((cAliasPec)->VO3_DATFEC) .and. lFecAnt .and. VSF->(dbSeek(xFilial("VSF") + (cAliasPec)->VO2_NUMOSV )) )
		// Utiliza o valor da peca da requisicao
		IF ((cAliasPec)->VOI_VLPCAC == "1" .or. lPrecoReq)
			cAuxScan += " .and. x[06] == nVO3ValPec"
			cAuxScan += " .and. x[09] == nValPec"
		EndIf
		//
		cAuxScan += " .and. x[27] == (cAliasPec)->VO3_FORMUL"
	EndIf
	// Ja foi fechada e possui o campo de relacionamento com VO3
	If lJaFec .and. !lFecAnt
		cAuxScan += " .and. x[37] == (cAliasPec)->VO3_VECREL "
	EndIf
	// Se o inconveniente estiver desligado, mas tiver conteudo na
	// coluna de inconveniente, deve quebrar por codigo de inconveniente
	If !lInconveniente .and. ( lVO3SEQINC .and. !Empty((cAliasPec)->VO3_SEQINC))
		cAuxScan += " .and. x[22] == (cAliasPec)->VO3_SEQINC"
	EndIf
	//
	nPos := aScan( aRetorno , &( "{ |x| " + cAuxScan + " }" ) )
	If nPos == 0
		AADD( aRetorno, Array(PECA_NTAM_RETORNO) )
		nPos := Len(aRetorno)
		aRetorno[nPos,PECA_GRUITE			] := (cAliasPec)->VO3_GRUITE			// 01 - Grupo do Item
		aRetorno[nPos,PECA_CODITE			] := (cAliasPec)->VO3_CODITE			// 02 - Codigo do Item
		aRetorno[nPos,PECA_TIPTEM			] := (cAliasPec)->VO3_TIPTEM			// 03 - Tipo de Tempo
		aRetorno[nPos,PECA_NUMOSV			] := (cAliasPec)->VO2_NUMOSV			// 04 - Numero da Ordem de Servico
		aRetorno[nPos,PECA_QTDREQ			] := 0									// 05 - Qtde da Peca Requisitada
		aRetorno[nPos,PECA_VALVO3			] := nVO3ValPec							// 06 - Valor da Item Gravado na VO3
		aRetorno[nPos,PECA_VALDES			] := 0									// 07 - Valor do Desconto
		aRetorno[nPos,PECA_PERDES			] := 0									// 08 - Percentual de Desconto
		aRetorno[nPos,PECA_VALOR 			] := nValPec							// 09 - Valor do Item no Fechamento (Pode ser diferente do VO3 dependendo do Tipo de Tempo )
		aRetorno[nPos,PECA_VALBRU			] := 0									// 10 - Valor Bruto Total do Item
		aRetorno[nPos,PECA_DEPINT			] := (cAliasPec)->VO3_DEPINT			// 11 - Departamento Interno
		aRetorno[nPos,PECA_DEPGAR			] := (cAliasPec)->VO3_DEPGAR			// 12 - Departamento Garantia
		aRetorno[nPos,PECA_DESCRICAO		] := (cAliasPec)->B1_DESC				// 13 - Descricao do Produto
		aRetorno[nPos,PECA_MOV				] := {}									// 14 - Matriz com movimentacoes de produto
		aRetorno[nPos,PECA_CLIENTE			] := (cAliasPec)->VO3_FATPAR			// 15 - Codigo do Cliente - Faturar Para
		aRetorno[nPos,PECA_LOJA 			] := (cAliasPec)->VO3_LOJA				// 16 - Loja do Cliente - Faturar Para
		aRetorno[nPos,PECA_DATLIB			] := StoD((cAliasPec)->VO3_DATDIS)		// 17 - Data de Liberacao
		aRetorno[nPos,PECA_DATCAN			] := StoD((cAliasPec)->VO3_DATCAN)		// 18 - Data de Cancelamento
		aRetorno[nPos,PECA_DATFEC			] := StoD((cAliasPec)->VO3_DATFEC)		// 19 - Data de Fechamento
		aRetorno[nPos,PECA_INCONV_GRUPO	    ] := ""									// 20 - Inconveniente - Grupo
		aRetorno[nPos,PECA_INCONV_CODIGO	] := ""									// 21 - Inconveniente - Codigo
		aRetorno[nPos,PECA_INCONV_SEQ		] := ""									// 22 - Inconveniente - Sequencia
		aRetorno[nPos,PECA_INCONV_DESCR	    ] := ""									// 23 - Inconveniente - Descricao
		aRetorno[nPos,PECA_TES				] := cAuxTES							// 24 - TES1
		aRetorno[nPos,PECA_LIBVOO			] := ""									// 25 - Numero da Liberacao do Tipo de Tempo (VOO_LIBVOO)
		aRetorno[nPos,PECA_OPER				] := (cAliasPec)->VO3_OPER				// 26 - Tipo de Operacao (TES Inteligente)
		aRetorno[nPos,PECA_FORMULA			] := (cAliasPec)->VO3_FORMUL			// 27 - Formula
		aRetorno[nPos,PECA_VALIMP			] := 0									// 28 - Total de Impostos
		aRetorno[nPos,PECA_NUMNFI			] := (cAliasPec)->VO3_NUMNFI			// 29 - Numero da Nota Fiscal
		aRetorno[nPos,PECA_SERNFI			] := (cAliasPec)->VO3_SERNFI			// 30 - Serie da Nota Fiscal
		aRetorno[nPos,PECA_CUSTOT			] := 0									// 31 - Custo da Mercadoria
		aRetorno[nPos,PECA_FUNFEC			] := (cAliasPec)->VO3_FUNFEC			// 32 - Funcionario que fechou o Tipo de Tempo
		aRetorno[nPos,PECA_ICMST			] := 0									// 33 - ICMS ST
		aRetorno[nPos,PECA_QTDREM			] := 0									// 34 - Saldo de Pecas em remessa para atendimento externo
		aRetorno[nPos,PECA_ACRESC			] := 0									// 35 - Acrescimo
		aRetorno[nPos,PECA_PROCFEC			] := 0									// 36 - Indica se foi processado no levantamento de VEC (Uso interno)
		aRetorno[nPos,PECA_VECREL			] := ""									// 37 - Relacionamento com VEC
		aRetorno[nPos,PECA_STATUS			] := FMX_TTSTAT( (cAliasPec)->VO3_DATCAN , (cAliasPec)->VO3_DATFEC, (cAliasPec)->VO3_DATDIS ) // 38 - Status do Tipo de Tempo
		aRetorno[nPos,PECA_LOTECT           ] := IIf( lCtrlLote , (cAliasPec)->VO3_LOTECT , "" ) // 43 - Lote
		aRetorno[nPos,PECA_NUMLOT           ] := IIf( lCtrlLote , (cAliasPec)->VO3_NUMLOT , "" ) // 44 - Sub-Lote
		if lVECContab
			aRetorno[nPos,PECA_CENCUS		] := (cAliasPec)->VEC_CENCUS
			aRetorno[nPos,PECA_CONTA		] := (cAliasPec)->VEC_CONTA
			aRetorno[nPos,PECA_ITEMCTA		] := (cAliasPec)->VEC_ITEMCT
			aRetorno[nPos,PECA_CLVL			] := (cAliasPec)->VEC_CLVL
		Endif

		aRetorno[nPos,PECA_LIBVOO			] := (cAliasPec)->VO3_LIBVOO
		If lVO3FUNDIS
			aRetorno[nPos,PECA_FUNDIS		] := (cAliasPec)->VO3_FUNDIS			// 47 - Tecnico da Liberacao do Tipo de Tempo (VO3_FUNDIS)
		EndIf

		aRetorno[nPos,PECA_MARLUC		] := IIf( lExistVZ1 , VZ1->VZ1_MARLUC , 0 )
		aRetorno[nPos,PECA_QTDVEC		] := 0

		// Se tiver inconveniente ...
		If lVO3SEQINC .and. !Empty((cAliasPec)->VO3_SEQINC)
			aAuxInconv := OM420CONSINC( "2" , cNumOS , (cAliasPec)->VO3_SEQINC )
			aRetorno[nPos,PECA_INCONV_GRUPO	] := aAuxInconv[1] // Inconveniente - Grupo
			aRetorno[nPos,PECA_INCONV_CODIGO	] := aAuxInconv[2] // Inconveniente - Codigo
			aRetorno[nPos,PECA_INCONV_SEQ		] := aAuxInconv[4] // Inconveniente - Sequencia
			aRetorno[nPos,PECA_INCONV_DESCR	] := aAuxInconv[3] // Inconveniente - Descricao
		// Se nao tiver e o inconveniente estiver ligado, inicializa os campos ...
		ElseIf lInconveniente
			aRetorno[nPos,PECA_INCONV_GRUPO	] := Space(nTamGRUINC) // Inconveniente - Grupo
			aRetorno[nPos,PECA_INCONV_CODIGO	] := Space(nTamCODINC) // Inconveniente - Codigo
			aRetorno[nPos,PECA_INCONV_SEQ		] := Space(nTamSEQINC) // Inconveniente - Sequencia
			aRetorno[nPos,PECA_INCONV_DESCR	] := Space(nTamDESINC) // Inconveniente - Descricao
		EndIf
		//

		If lVO3VECREL
			aRetorno[nPos,PECA_VECREL] := (cAliasPec)->VO3_VECREL
			aRetorno[nPos,PECA_VALBRU] := (cAliasPec)->VEC_VALBRU
		EndIf

		If lJaFec
			aRetorno[nPos,PECA_QTDVEC] := (cAliasPec)->VEC_QTDITE
			aRetorno[nPos,PECA_VALDES] := (cAliasPec)->VEC_VALDES
			If !lFecAnt
				aRetorno[nPos,PECA_VALIMP	] := (cAliasPec)->VEC_TOTIMP
				aRetorno[nPos,PECA_CUSTOT	] := (cAliasPec)->VEC_CUSTOT
				aRetorno[nPos,PECA_ICMST	] := (cAliasPec)->VEC_ICMSRT
			EndIf
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Se a Negociacao ja tiver sido salva ...                             ณ
			//ณ Considera o desconto neste ponto pois do contrario entraria no laco ณ
			//ณ de requisicoes e poderia considerar o valor mais de uma vez ...		ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			if lExistVZ1
				aRetorno[nPos, PECA_VALDES] += VZ1->VZ1_VALDES * (nMulti)
				If lVZ1Acresc
					aRetorno[nPos, PECA_ACRESC] += VZ1->VZ1_ACRESC
				EndIf
				// aRetorno[nPos, PECA_VALOR ] += ( VZ1->VZ1_ACRESC / (cAliasPec)->VO3_QTDREQ )
			endif
			//
		EndIf
		If lVZ1Contab
			if lExistVZ1
				aRetorno[nPos,PECA_CENCUS] := VZ1->VZ1_CENCUS
				aRetorno[nPos,PECA_CONTA]  := VZ1->VZ1_CONTA
				aRetorno[nPos,PECA_ITEMCTA]:= VZ1->VZ1_ITEMCT
				aRetorno[nPos,PECA_CLVL]   := VZ1->VZ1_CLVL
			Else // Ticket DMS 1668523 - Inicializa com Conte๚do da SB1, como ้ feito na Pedido de Venda (A410EntCtb)
				aRetorno[nPos,PECA_CENCUS] := (cAliasPec)->B1_CC
				aRetorno[nPos,PECA_CONTA]  := (cAliasPec)->B1_CONTA
				aRetorno[nPos,PECA_ITEMCTA]:= (cAliasPec)->B1_ITEMCC
				aRetorno[nPos,PECA_CLVL]   := (cAliasPec)->B1_CLVL
			Endif
		Endif

	EndIf


	aRetorno[nPos,PECA_QTDREQ] += (cAliasPec)->VO3_QTDREQ * (nMulti)
			
	If !lJaFec
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Se a Nใo tiver Negociacao ja tiver sido salva ... ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		if !lExistVZ1
			if !lVO3VALLIQ .or. (cAliasPec)->VO3_VALLIQ <= 0
				aRetorno[nPos,PECA_VALDES] += (cAliasPec)->VO3_QTDREQ * (nValPec - nValPecLiq) * nMulti
			else
				aRetorno[nPos,PECA_VALDES] += (cAliasPec)->VO3_VALDES * nMulti
			endif
		endif
		//
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava Movimentacao do Item ... ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lMov
		AADD( aRetorno[nPos,PECA_MOV] , Array(08) )
		nPosMov := Len(aRetorno[nPos,PECA_MOV])
		aRetorno[ nPos , PECA_MOV , nPosMov , PECA_MOV_NOSNUM ] := (cAliasPec)->VO2_NOSNUM
		aRetorno[ nPos , PECA_MOV , nPosMov , PECA_MOV_DATREQ ] := StoD((cAliasPec)->VO2_DATREQ)
		aRetorno[ nPos , PECA_MOV , nPosMov , PECA_MOV_REQDEV ] := (cAliasPec)->VO2_DEVOLU
		aRetorno[ nPos , PECA_MOV , nPosMov , PECA_MOV_QTDREQ ] := (cAliasPec)->VO3_QTDREQ
		aRetorno[ nPos , PECA_MOV , nPosMov , PECA_MOV_RECVO3 ] := (cAliasPec)->RECNOVO3
		aRetorno[ nPos , PECA_MOV , nPosMov , PECA_MOV_VALPEC ] := nValPec
		aRetorno[ nPos , PECA_MOV , nPosMov , PECA_MOV_FUNREQ ] := (cAliasPec)->VO2_FUNREQ
		aRetorno[ nPos , PECA_MOV , nPosMov , PECA_MOV_PROREQ ] := (cAliasPec)->VO3_PROREQ
	EndIf
	//

	(cAliasPec)->(dbSkip())
End
(cAliasPec)->(dbCloseArea())

For nPos := 1 to len(aRetorno) // Corrigir Impostos, Descontos e Valor Total
	If ! Empty(aRetorno[ nPos , PECA_DATFEC ]) .and. aRetorno[nPos,PECA_QTDVEC] <> 0
		aRetorno[nPos,PECA_VALIMP] := round( ( aRetorno[nPos,PECA_VALIMP] / aRetorno[nPos,PECA_QTDVEC] ) * aRetorno[nPos,PECA_QTDREQ] , 2 )
		aRetorno[nPos,PECA_CUSTOT] := round( ( aRetorno[nPos,PECA_CUSTOT] / aRetorno[nPos,PECA_QTDVEC] ) * aRetorno[nPos,PECA_QTDREQ] , 2 )
		aRetorno[nPos,PECA_ICMST ] := round( ( aRetorno[nPos,PECA_ICMST ] / aRetorno[nPos,PECA_QTDVEC] ) * aRetorno[nPos,PECA_QTDREQ] , 2 )
		aRetorno[nPos,PECA_VALDES] := round( ( aRetorno[nPos,PECA_VALDES] / aRetorno[nPos,PECA_QTDVEC] ) * aRetorno[nPos,PECA_QTDREQ] , 2 )
		aRetorno[nPos,PECA_VALBRU] := round( ( aRetorno[nPos,PECA_VALBRU] / aRetorno[nPos,PECA_QTDVEC] ) * aRetorno[nPos,PECA_QTDREQ] , 2 )
	EndIf
Next

// Verifica se existe algum TT Fechado ...
If aScan(aRetorno,{ |x| !Empty(x[PECA_DATFEC]) }) <> 0

	nDecQtd := TamSX3("VO3_QTDREQ")[2]
	nDecVda := TamSX3("VO3_VALPEC")[2]

	nAuxQtde := Val(Replicate("9",15 - nDecQtd - 1)) // Utilizado para aSort

	aSort( aRetorno ,,, { |x,y| StrZero(x[PECA_VALVO3],10,nDecVda) + StrZero( nAuxQtde - x[PECA_QTDREQ],15,nDecQtd) < StrZero(y[PECA_VALVO3],10,nDecVda) + StrZero( nAuxQtde - y[PECA_QTDREQ],15,nDecQtd) } )

	SF4->(dbSetOrder(1))

	For nPos := 1 to Len(aRetorno)

		// Se nao foi fechado ou registro ja foi processado ...
		If Empty(aRetorno[nPos,PECA_DATFEC]) .or. (aRetorno[nPos,PECA_PROCFEC] == aRetorno[nPos,PECA_QTDREQ])
			Loop
		EndIf
		//

		// Se foi criado campo de relacionamento VEC x VO3 e tem conteudo = ja foi processando ...
		If lVO3VECREL .and. !Empty(aRetorno[nPos,PECA_VECREL])
			Loop
		EndIf
		//

		nAuxQtde := 0

		SF4->(MsSeek(xFilial("SF4") + aRetorno[nPos,PECA_TES] ))

		cSQL := "SELECT (VEC_VALVDA/VEC_QTDITE) VALUNIT , VEC_QTDITE, VEC_VALBRU, VEC_VALDES, VEC_VALVDA, VEC_ICMSRT, VEC_TOTIMP, VEC_CUSTOT "
		cSQL +=  " FROM " + RetSQLName("VEC") + " VEC "
		cSQL += " WHERE VEC.VEC_FILIAL = '" + xFilial("VEC") + "'"
		cSQL +=   " AND VEC.VEC_NUMOSV = '" + aRetorno[nPos,PECA_NUMOSV] + "'"
		cSQL +=   " AND VEC.VEC_TIPTEM = '" + aRetorno[nPos,PECA_TIPTEM] + "'"
		cSQL +=   " AND VEC.VEC_GRUITE = '" + aRetorno[nPos,PECA_GRUITE] + "'"
		cSQL +=   " AND VEC.VEC_CODITE = '" + aRetorno[nPos,PECA_CODITE] + "'"
		cSQL +=   " AND VEC.VEC_LIBVOO = '" + aRetorno[nPos,PECA_LIBVOO] + "'"
		cSQL +=   " AND VEC.D_E_L_E_T_ = ' '"
		cSQL += " ORDER BY 1 , 2 DESC "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasPec , .F., .T. )
		While !(cAliasPec)->(Eof())

			nValVda := (cAliasPec)->VALUNIT
			nAuxQtde := (cAliasPec)->VEC_QTDITE
			nCont := 0

			// Distribui a quantidade encontrada na VEC
			While nAuxQtde > 0 .and. nCont <= 99

				++nCont

				// Procura registro com a mesma quantidade o mesmo valor unitario ...
				If (nAuxPos := aScan(aRetorno,{ |x| x[PECA_QTDREQ] == (cAliasPec)->VEC_QTDITE .and. x[PECA_VALVO3] == nValVda .and. x[PECA_PROCFEC] < x[PECA_QTDREQ] .and.;
																x[PECA_NUMOSV] == aRetorno[nPos,PECA_NUMOSV] .and. x[PECA_TIPTEM] == aRetorno[nPos,PECA_TIPTEM] .and. x[PECA_GRUITE] == aRetorno[nPos,PECA_GRUITE] .and. x[PECA_CODITE] == aRetorno[nPos,PECA_CODITE] .and. x[PECA_LIBVOO] == aRetorno[nPos,PECA_LIBVOO] }, nPos )) > 0
					FMX_ATPECFEC(nAuxPos,@nAuxQtde,@aRetorno,cAliasPec)
				// Procura registro com o mesmo valor unitario ...
				ElseIf (nAuxPos := aScan(aRetorno,{ |x| x[PECA_QTDREQ] > 0 .and. x[PECA_VALVO3] == nValVda .and. x[PECA_PROCFEC] < x[PECA_QTDREQ] .and.;
																	x[PECA_NUMOSV] == aRetorno[nPos,PECA_NUMOSV] .and. x[PECA_TIPTEM] == aRetorno[nPos,PECA_TIPTEM] .and. x[PECA_GRUITE] == aRetorno[nPos,PECA_GRUITE] .and. x[PECA_CODITE] == aRetorno[nPos,PECA_CODITE] .and. x[PECA_LIBVOO] == aRetorno[nPos,PECA_LIBVOO] }, nPos )) > 0
					FMX_ATPECFEC(nAuxPos,@nAuxQtde,@aRetorno,cAliasPec)
				// Procura registro com a mesma quantidade ...
				ElseIf (nAuxPos := aScan(aRetorno,{ |x| x[PECA_QTDREQ] > 0 .and. nAuxQtde == x[PECA_QTDREQ] .and. x[PECA_PROCFEC] < x[PECA_QTDREQ] .and.;
																	x[PECA_NUMOSV] == aRetorno[nPos,PECA_NUMOSV] .and. x[PECA_TIPTEM] == aRetorno[nPos,PECA_TIPTEM] .and. x[PECA_GRUITE] == aRetorno[nPos,PECA_GRUITE] .and. x[PECA_CODITE] == aRetorno[nPos,PECA_CODITE] .and. x[PECA_LIBVOO] == aRetorno[nPos,PECA_LIBVOO] }, nPos )) > 0
					FMX_ATPECFEC(nAuxPos,@nAuxQtde,@aRetorno,cAliasPec)
				// Procura registro com o quantidade disponivel (FECHADA) menor do que a quantidade requisitada ...
				ElseIf (nAuxPos := aScan(aRetorno,{ |x| x[PECA_QTDREQ] > 0 .and. nAuxQtde <= (x[PECA_QTDREQ] - x[PECA_PROCFEC]) .and. x[PECA_PROCFEC] < x[PECA_QTDREQ] .and.;
																	x[PECA_NUMOSV] == aRetorno[nPos,PECA_NUMOSV] .and. x[PECA_TIPTEM] == aRetorno[nPos,PECA_TIPTEM] .and. x[PECA_GRUITE] == aRetorno[nPos,PECA_GRUITE] .and. x[PECA_CODITE] == aRetorno[nPos,PECA_CODITE] .and. x[PECA_LIBVOO] == aRetorno[nPos,PECA_LIBVOO] }, nPos )) > 0
					FMX_ATPECFEC(nAuxPos,@nAuxQtde,@aRetorno,cAliasPec)
				// Procura registro com o quantidade disponivel ...
				ElseIf (nAuxPos := aScan(aRetorno,{ |x| x[PECA_QTDREQ] > 0 .and. x[PECA_PROCFEC] < x[PECA_QTDREQ] .and.;
																	x[PECA_NUMOSV] == aRetorno[nPos,PECA_NUMOSV] .and. x[PECA_TIPTEM] == aRetorno[nPos,PECA_TIPTEM] .and. x[PECA_GRUITE] == aRetorno[nPos,PECA_GRUITE] .and. x[PECA_CODITE] == aRetorno[nPos,PECA_CODITE] .and. x[PECA_LIBVOO] == aRetorno[nPos,PECA_LIBVOO] }, nPos )) > 0
					FMX_ATPECFEC(nAuxPos,@nAuxQtde,@aRetorno,cAliasPec)
				Else
					UserException(CHR(13) + CHR(10) + STR0029 + CHR(13) + CHR(10) + ; // "Erro ao processar cแlculo das pe็as."
									AllTrim(RetTitle("VO1_FILIAL")) + ": " + xFilial("VO1") + CHR(13) + CHR(10) + ;
									AllTrim(RetTitle("VO1_NUMOSV")) + ": " + aRetorno[nPos,PECA_NUMOSV] + CHR(13) + CHR(10) + ;
									AllTrim(RetTitle("VO3_TIPTEM")) + ": " + aRetorno[nPos,PECA_TIPTEM] + CHR(13) + CHR(10) + ;
									AllTrim(RetTitle("VOO_LIBVOO")) + ": " + aRetorno[nPos,PECA_LIBVOO] + CHR(13) + CHR(10) + ;
									AllTrim(RetTitle("VO3_CODITE")) + ": " + aRetorno[nPos,PECA_GRUITE] + " - " + aRetorno[nPos,PECA_CODITE] + CHR(13) + CHR(10) )
				EndIf

			End

			If nAuxQtde <> 0
					UserException(CHR(13) + CHR(10) + STR0030 + CHR(13) + CHR(10) + ; // "Nใo foi possํvel distribuir a quantidade da pe็a fechada entre as requisi็๕es."
									AllTrim(RetTitle("VO1_FILIAL")) + ": " + xFilial("VO1") + CHR(13) + CHR(10) + ;
									AllTrim(RetTitle("VO1_NUMOSV")) + ": " + aRetorno[nPos,PECA_NUMOSV] + CHR(13) + CHR(10) + ;
									AllTrim(RetTitle("VO3_TIPTEM")) + ": " + aRetorno[nPos,PECA_TIPTEM] + CHR(13) + CHR(10) + ;
									AllTrim(RetTitle("VOO_LIBVOO")) + ": " + aRetorno[nPos,PECA_LIBVOO] + CHR(13) + CHR(10) + ;
									AllTrim(RetTitle("VO3_CODITE")) + ": " + aRetorno[nPos,PECA_GRUITE] + " - " + aRetorno[nPos,PECA_CODITE] + CHR(13) + CHR(10) )
			EndIf
			(cAliasPec)->(dbSkip())
		End
		(cAliasPec)->(dbCloseArea())

	Next nPos
EndIf
//

// Calcula saldo de pe็as em remessa para atendimento externo ...
If lRetRem
	cSQL := "SELECT VDR_TIPTEM, VDR_GRUITE, VDR_CODITE, SUM(VDR_QTDREM) AS VDR_QTDREM"
	cSQL +=  " FROM " + RetSQLName("VDR")
	cSQL += " WHERE VDR_FILIAL = '" + xFilial("VDR") + "'"
	cSQL +=   " AND VDR_NUMOSV = '" + cNumOS + "'"
	If !Empty(cTipTem)
		cSQL += " AND VDR_TIPTEM = '" + cTipTem + "'"
	EndIf
	If !Empty(cGruIte)
		cSQL += " AND VDR_GRUITE = '" + cGruIte + "'"
	EndIf
	If !Empty(cCodIte)
		cSQL += " AND VDR_CODITE = '" + cCodIte + "'"
	EndIf
	cSQL += " AND VDR_NFENUM = '         '" // Somente notas que nao foram devolvidas
	cSQL += " AND D_E_L_E_T_ = ' '"
	cSQL += " GROUP BY VDR_TIPTEM, VDR_GRUITE, VDR_CODITE"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasPec , .F., .T. )
	While !(cAliasPec)->(Eof())
		nPos := aScan(aRetorno, { |x| x[PECA_TIPTEM] == (cAliasPec)->VDR_TIPTEM .and. x[PECA_GRUITE] == (cAliasPec)->VDR_GRUITE .and. x[PECA_CODITE] == (cAliasPec)->VDR_CODITE } )
		If nPos <> 0
			aRetorno[nPos,PECA_QTDREM] := (cAliasPec)->VDR_QTDREM
		Else
			MsgInfo(STR0028 + chr(13) + chr(10) + chr(13) + chr(10) + RetTitle("VDR_CODITE") + (cAliasPec)->VDR_GRUITE + "-" + AllTrim((cAliasPec)->VDR_CODITE)) // "Pe็a nใo encontrada na matriz de retorno"
		EndIf
		(cAliasPec)->(dbSkip())
	End
	(cAliasPec)->(dbCloseArea())
EndIf
//

RestArea( aAreaSA1 )
RestArea( aAreaVOI )
RestArea( aAreaVO1 )
RestArea( aAreaVO2 )
RestArea( aAreaVO3 )
RestArea( aAreaVZ1 )
RestArea( oArea )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Remove itens com qtde requisitada zerada ou ZERA campo de desconto... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPos := 1
While nPos <= Len(aRetorno)
	If aRetorno[nPos,PECA_QTDREQ] == 0
		If lReqZerada
			aDel (aRetorno, nPos)
			aSize(aRetorno, Len(aRetorno) - 1)
			Loop
		Else
			aRetorno[nPos,PECA_VALDES] := 0
		EndIf
	EndIf
	nPos++
End
//

// Calcula total e percentual de desconto das pecas ...
For nPos := 1 to Len(aRetorno)

	// Se tiver conteudo, ja pegou o valor da VEC
	If aRetorno[nPos, PECA_VALBRU] == 0
		aRetorno[nPos, PECA_VALBRU] := A410Arred( aRetorno[nPos, PECA_QTDREQ] * aRetorno[nPos, PECA_VALOR] + aRetorno[nPos, PECA_ACRESC] , "C6_VALOR")
	EndIf
	If aRetorno[nPos, PECA_VALDES] <> 0
		// Calcula Percentual de Desconto ...
		if Type("aHeader") == "U" // A fun็ใo FtDescItem (FATA080) utiliza este Array
			aHeader := {}
		Endif
		FtDescItem( aRetorno[nPos,PECA_VALOR],;		//ExpN1: Preco de lista aplicado o desconto de cabecalho
					aRetorno[nPos, PECA_VALOR],;		//ExpN2: Preco de Venda
					aRetorno[nPos, PECA_QTDREQ],;		//ExpN3: Quantidade vendida
					aRetorno[nPos, PECA_VALBRU],;		//ExpN4: Valor Total (do item)
					@aRetorno[nPos, PECA_PERDES],;	//ExpN5: Percentual de desconto
					aRetorno[nPos, PECA_VALDES],;		//ExpN6: Valor do desconto
					aRetorno[nPos, PECA_VALDES],;		//ExpN7: Valor do desconto original
					2)						//ExpN8: Tipo de Desconto (1 % OU 2 R$)
	EndIf
Next nPos
//

aSort( aRetorno ,,, { |x,y| ;
	x[PECA_TIPTEM] + x[PECA_INCONV_SEQ] + x[PECA_STATUS] + x[PECA_GRUITE] + x[PECA_CODITE] < ;
	y[PECA_TIPTEM] + y[PECA_INCONV_SEQ] + x[PECA_STATUS] + y[PECA_GRUITE] + y[PECA_CODITE] } )

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออ/อัออออออออออออออหอออออออัออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_ATPECFEC  บAutor  ณTakahashi       บ Data ณ  22/12/10  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza informacoes da matriz de retorno da funcao        บฑฑ
ฑฑบ          ณ FMX_CALPEC                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FMX_ATPECFEC(nAuxPos,nAuxQtde,aRetorno,cAliasPec)

Local nQuant

// Verifica se a qtde a ser processada do registro da VEC...
If (aRetorno[nAuxPos,PECA_QTDREQ] - aRetorno[nAuxPos,PECA_PROCFEC]) > nAuxQtde
	nQuant := nAuxQtde
Else
	nQuant := aRetorno[nAuxPos,PECA_QTDREQ] - aRetorno[nAuxPos,PECA_PROCFEC]
EndIf

// F4_INCSOL - "S":agrega o valor do ICMS solidario no total da Nota Fiscal
If SF4->F4_INCSOL == "S"
	nValPec := ((cAliasPec)->VEC_VALVDA + (cAliasPec)->VEC_ICMSRT + (cAliasPec)->VEC_VALDES) / (cAliasPec)->VEC_QTDITE
Else
	nValPec := ((cAliasPec)->VEC_VALVDA + (cAliasPec)->VEC_VALDES) / (cAliasPec)->VEC_QTDITE
EndIf

aRetorno[nAuxPos,PECA_VALOR	] := nValPec								// 09 - Valor do Item no Fechamento (Pode ser diferente do VO3 dependendo do Tipo de Tempo )
aEval(aRetorno[nAuxPos,PECA_MOV] ,{ |x| x[PECA_MOV_VALPEC] := nValPec })

aRetorno[nAuxPos,PECA_VALIMP	] := ((cAliasPec)->VEC_TOTIMP / (cAliasPec)->VEC_QTDITE) * nQuant	// 28 - Total de Impostos
aRetorno[nAuxPos,PECA_CUSTOT	] := ((cAliasPec)->VEC_CUSTOT / (cAliasPec)->VEC_QTDITE) * nQuant	// 31 - Custo da Mercadoria
aRetorno[nAuxPos,PECA_ICMST	] := ((cAliasPec)->VEC_ICMSRT / (cAliasPec)->VEC_QTDITE) * nQuant	// 33 - ICMS ST
aRetorno[nAuxPos,PECA_VALDES	] := ((cAliasPec)->VEC_VALDES / (cAliasPec)->VEC_QTDITE) * nQuant

aRetorno[nAuxPos,PECA_PROCFEC	] += nQuant
nAuxQtde -= nQuant

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออ/อัออออออออออออออหอออออออัออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_TTSTAT    บAutor  ณTakahashi       บ Data ณ  22/12/10  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o status do tipo de tempo                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao FMX_CALSER / FMX_CALPEC                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FMX_TTSTAT( dDatCan , dDatFec, dDatLib )

Local cRetorno := "A"
If !Empty(dDatCan)
	cRetorno := "C"
ElseIf !Empty(dDatFec)
	cRetorno := "F"
ElseIf !Empty(dDatLib)
	cRetorno := "L"
EndIf

Return cRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_TEMLIB   บAutor  ณTakahashi       บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna se a OS possui TT liberados                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cNumOsv = Numero da OS                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_TEMLIB( cNumOsv )

Local lRetorno := .f.
Local cSQL
Local cAlias := "TOSLIB"
Local oArea := GetArea()

cSQL := "SELECT VO3.VO3_TIPTEM"
cSQL +=  " FROM " + RetSQLName("VO2") + " VO2 "
cSQL +=         " JOIN " + RetSQLName("VO3") + " VO3 ON VO3.VO3_FILIAL = '" + xFilial("VO3") + "' AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' '"
cSQL += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
cSQL +=   " AND VO2.VO2_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VO2.VO2_TIPREQ = 'P'"
cSQL +=   " AND VO2.D_E_L_E_T_ = ' '"
cSQL +=   " AND VO3.VO3_DATDIS <> '" + Space(8) + "'"
cSQL +=   " AND VO3.VO3_DATFEC = '" + Space(8) + "'"
cSQL +=   " AND VO3.VO3_DATCAN = '" + Space(8) + "'"
cSQL += " UNION "
cSQL += "SELECT VO4.VO4_TIPTEM"
cSQL +=  " FROM " + RetSQLName("VO2") + " VO2 "
cSQL +=         " JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.D_E_L_E_T_ = ' '"
cSQL += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
cSQL +=   " AND VO2.VO2_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VO2.VO2_TIPREQ = 'S'"
cSQL +=   " AND VO2.D_E_L_E_T_ = ' '"
cSQL +=   " AND VO4.VO4_DATDIS <> '" + Space(8) + "'"
cSQL +=   " AND VO4.VO4_DATFEC = '" + Space(8) + "'"
cSQL +=   " AND VO4.VO4_DATCAN = '" + Space(8) + "'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAlias , .F., .T. )

If !(cAlias)->(Eof())
	lRetorno := .t.
EndIf
(cAlias)->(dbCloseArea())

RestArea( oArea )

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_CANUSETT บAutor  ณTakahashi       บ Data ณ  20/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se pode realizar alguma operacao em determinado   บฑฑ
ฑฑบ          ณ tipo de tempo                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cTipOper - Tipo de Operacao que sera realizada             บฑฑ
ฑฑบ          ณ            1 - Requisicao de Peca                          บฑฑ
ฑฑบ          ณ            2 - Alteracao de Requisicao de Peca             บฑฑ
ฑฑบ          ณ            3 - Requisicao de Servico                       บฑฑ
ฑฑบ          ณ            4 - Alteracao de Requisicao de Servico          บฑฑ
ฑฑบ          ณ            5 - Liberacao                                   บฑฑ
ฑฑบ          ณ            6 - Faturamento                                 บฑฑ
ฑฑบ          ณ cNumOsv - Numero da Ordem de Servico                       บฑฑ
ฑฑบ          ณ cTipTem - Tipo de Servico                                  บฑฑ
ฑฑบ          ณ lNovaReq - Indica se eh uma requisicao nova. Utilizado     บฑฑ
ฑฑบ          ณ            para requisicao de servicos                     บฑฑ
ฑฑบ          ณ lExibeAlert - Indica se sera exibido alert com msg de erro บฑฑ
ฑฑบ          ณ cMsgErro - Recebera o motivo do erro                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_CANUSETT( cTipOper , cNumOsv , cTipTem , lNovaReq, lExibeAlert, cMsgErro , nRecVO3 , nRecVO4 )

Local lRetorno := .t.
Local cSQL := ""
Local cAuxAlias := GetNextAlias()
Local oArea := GetArea()
Local aAuxArea

Default lNovaReq 	:= .f.
Default lExibeAlert := .t.
Default nRecVO3 := 0
Default nRecVO4 := 0

// Requisicao de Servico, nao pode encontrar VO2
If cTipOper == "3" .and. lRetorno .and. lNovaReq
	aAuxArea := VO2->(GetArea())
	VO2->(dbSetOrder(1))
	If VO2->(dbSeek( xFilial("VO2") + cNumOsv + "S" ))
		If lExibeAlert
			MsgAlert(STR0010,STR0008) // "Ja existe requisicao de servico para esta OS"
		EndIf
		cMsgErro := STR0010
		lRetorno := .f.
	EndIf
	RestArea(aAuxArea)
EndIf
//
// Liberacao
If cTipOper == "5" .and. lRetorno
	aAuxArea := VOO->(GetArea())
	VOO->(dbSetOrder(1))
	If VOO->(dbSeek( xFilial("VOO") + cNumOsv + cTipTem ))
		If lExibeAlert
			MsgAlert(STR0009 + " " + AllTrim(cTipTem) + " " + STR0005,STR0008) // "Tipo de tempo XXXX jแ foi liberado"
		EndIf
		cMsgErro := STR0009 + " " + AllTrim(cTipTem) + " " + STR0005
		lRetorno := .f.
	Endif
	RestArea(aAuxArea)
EndIf
//
// Fechamento
If cTipOper == "6" .and. lRetorno
	aAuxArea := VOO->(GetArea())
	VOO->(dbSetOrder(1))
	If VOO->(dbSeek( xFilial("VOO") + cNumOsv + cTipTem ))
		If !Empty(VOO->VOO_PESQLJ)
			If lExibeAlert
				MsgAlert(STR0009 + " " + AllTrim(cTipTem) + " " + STR0011,STR0008) // "Tipo de tempo XXXX jแ possui or็amento no loja"
			EndIf
			cMsgErro := STR0009 + " " + AllTrim(cTipTem) + " " + STR0011
			lRetorno := .f.
		Endif
		If !Empty(VOO->VOO_NUMNFI)
			If lExibeAlert
				MsgAlert(STR0009 + " " + AllTrim(cTipTem) + " " + STR0007,STR0008) // "Tipo de tempo XXXX jแ foi faturado"
			EndIf
			cMsgErro := STR0009 + " " + AllTrim(cTipTem) + " " + STR0007
			lRetorno := .f.
		EndIf
	Else
		If lExibeAlert
			MsgAlert(STR0009 + " " + AllTrim(cTipTem) + " " + STR0012,STR0008) // "Tipo de tempo XXXX nใo possui libera็ใo"
		EndIf
		cMsgErro := STR0009 + " " + AllTrim(cTipTem) + " " + STR0012
		lRetorno := .f.
	Endif
	RestArea(aAuxArea)
EndIf
//

If lRetorno
	cSQL := "SELECT DISTINCT VO3_DATCAN, VO3_DATFEC, VO3_DATDIS"
	cSQL +=  " FROM " + RetSQLName("VO2") + " VO2 JOIN " + RetSQLName("VO3") + " VO3 ON VO3.VO3_FILIAL = '" + xFilial("VO3") + "' AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' '"
	cSQL += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
	cSQL +=   " AND VO2.VO2_NUMOSV = '" + cNumOsv + "'"
	cSQL +=   " AND VO2.VO2_TIPREQ = 'P'"	// Requisicao de Peca
	cSQL +=   " AND VO2.D_E_L_E_T_ = ' '"
	cSQL +=   " AND VO3.VO3_TIPTEM = '" + cTipTem + "'"
	cSQL += IIf( nRecVO3 <> 0 , " AND VO3.R_E_C_N_O_ = " + AllTrim(Str(nRecVO3)) , "" )
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAuxAlias , .F., .T. )
	While !(cAuxAlias)->(Eof())
		If lRetorno .and. !Empty((cAuxAlias)->VO3_DATCAN) .and. cTipOper $ ( "1/3/5/6/" + IIf( nRecVO3 <> 0 , "2/4" , "" )) //"1/2/3/4/5/6"
			cMsgErro := STR0009 + " " + AllTrim(cTipTem) + " " + STR0006 // "Tipo de tempo XXXX jแ foi cancelado"
			lRetorno := .f.
			Exit
		EndIf
		If lRetorno .and. !Empty((cAuxAlias)->VO3_DATFEC) .and. cTipOper $ ( "1/3/5/6/" + IIf( nRecVO3 <> 0 , "2/4" , "" )) //"1/2/3/4/5/6"
			cMsgErro := STR0009 + " " + AllTrim(cTipTem) + " " + STR0007 // "Tipo de tempo XXXX jแ foi faturado"
			lRetorno := .f.
			Exit
		EndIf
		If lRetorno .and. !Empty((cAuxAlias)->VO3_DATDIS) .and. cTipOper $ ( "1/3/5/" + IIf( nRecVO3 <> 0 , "2/4" , "" )) //"1/2/3/4/5"
			cMsgErro := STR0009 + " " + AllTrim(cTipTem) + " " + STR0005 // "Tipo de tempo XXXX jแ foi liberado"
			lRetorno := .f.
			Exit
		EndIf
		If lRetorno .and. Empty((cAuxAlias)->VO3_DATDIS) .and. cTipOper $ "6"
			cMsgErro := STR0009 + " " + AllTrim(cTipTem) + " " + STR0012 // "Tipo de tempo XXXX nใo possui libera็ใo"
			lRetorno := .f.
			Exit
		EndIf
		(cAuxAlias)->(dbSkip())
	End
	(cAuxAlias)->(dbCloseArea())

	If !lRetorno .and. !Empty(cMsgErro) .and. lExibeAlert
		MsgAlert(cMsgErro,STR0008)
	EndIf

EndIf

If lRetorno
	cSQL := "SELECT DISTINCT VO4_DATCAN, VO4_DATFEC, VO4_DATDIS"
	cSQL +=  " FROM " + RetSQLName("VO2") + " VO2 JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.D_E_L_E_T_ = ' '"
	cSQL += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
	cSQL +=   " AND VO2.VO2_NUMOSV = '" + cNumOsv + "'"
	cSQL +=   " AND VO2.VO2_TIPREQ = 'S'"	// Requisicao de Servico
	cSQL +=   " AND VO2.D_E_L_E_T_ = ' '"
	cSQL +=   " AND VO4.VO4_TIPTEM = '" + cTipTem + "'"
	cSQL += IIf( nRecVO4 <> 0 , " AND VO4.R_E_C_N_O_ = " + AllTrim(Str(nRecVO4)) , "" )
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAuxAlias , .F., .T. )
	While !(cAuxAlias)->(Eof())
		If lRetorno .and.!Empty((cAuxAlias)->VO4_DATCAN) .and. cTipOper $ ( "1/3/5/6/" + IIf( nRecVO4 <> 0 , "2/4" , "" )) // "1/2/3/4/5/6"
			cMsgErro := STR0009 + " " + AllTrim(cTipTem) + " " + STR0006 // "Tipo de tempo XXXX jแ foi cancelado"
			lRetorno := .f.
			Exit
		EndIf
		If lRetorno .and. !Empty((cAuxAlias)->VO4_DATFEC) .and. cTipOper $ ( "1/3/5/6/" + IIf( nRecVO4 <> 0 , "2/4" , "" )) // "1/2/3/4/5/6"
			cMsgErro := STR0009 + " " + AllTrim(cTipTem) + " " + STR0007 // "Tipo de tempo XXXX jแ foi faturado"
			lRetorno := .f.
			Exit
		EndIf
		If lRetorno .and. !Empty((cAuxAlias)->VO4_DATDIS) .and. cTipOper $ ( "1/3/5/" + IIf( nRecVO4 <> 0 , "2/4" , "" ))
			cMsgErro := STR0009 + " " + AllTrim(cTipTem) + " " + STR0005 // "Tipo de tempo XXXX jแ foi liberado"
			lRetorno := .f.
			Exit
		EndIf
		If lRetorno .and. Empty((cAuxAlias)->VO4_DATDIS) .and. cTipOper $ "6"
			cMsgErro := STR0009 + " " + AllTrim(cTipTem) + " " + STR0012 // "Tipo de tempo XXXX nใo possui libera็ใo"
			lRetorno := .f.
			Exit
		EndIf
		(cAuxAlias)->(dbSkip())
	End
	(cAuxAlias)->(dbCloseArea())

	If !lRetorno .and. !Empty(cMsgErro) .and. lExibeAlert
		MsgAlert(cMsgErro,STR0008)
	EndIf


EndIf

RestArea( oArea )

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    | FM_CKCLINI ณ Autor ณ Andre Luis Almeida  ณ Data ณ 19/10/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Checa/Mostra Nivel de Importacia do Cliente para o usuario ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Geral                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FM_CKCLINI(cCliLoj)
Local aArea  := {}
Local lAtual := .f.
Local OXFig
Local lMostra:= .f.
Local cHrMin := left(time(),5)
Local cPRW   := FunName()
DEFINE FONT oFCliNIR NAME "Arial" SIZE 08,15 BOLD
lMostra := SX6->(DbSeek(xFilial("SX6")+"MV_CKCLIXX")) // Atualiza Parametro
If lMostra
	// Salva posicoes originais dos Arquivos
	aArea := sGetArea(aArea,Alias())
	aArea := sGetArea(aArea,"VCF")
	aArea := sGetArea(aArea,"VCB")
	aArea := sGetArea(aArea,"SA1")
	aArea := sGetArea(aArea,"VAI")
	If Alltrim(GetMV("MV_CKCLIXX")) # Alltrim( cPRW +" "+ cHrMin +" "+ __CUSERID +" "+ cCliLoj )
		DbSelectArea("VCF")
		DbSetOrder(1)
		If DbSeek( xFilial("VCF") + cCliLoj ) // Posiciona nos dados do Cliente
			If VCF->VCF_NIVIMP $ GetNewPar("MV_CKCLINI","AA") // Verifica o nivel do Cliente se esta no Parametro
				lAtual := .t.
				DbSelectArea("VCB")
				DbSetOrder(1)
				DbSeek(xFilial("VCB") + VCF->VCF_AREVEN )
				DbSelectArea("SA1")
				DbSetOrder(1)
				DbSeek(xFilial("SA1") + cCliLoj )
				DbSelectArea("VAI")
				DbSetOrder(4)
				DbSeek( xFilial("VAI") + __CUSERID )

				DEFINE MSDIALOG oCliNI FROM 000,000 TO 011,055 TITLE (STR0001+" "+VCF->VCF_NIVIMP) OF oMainWnd
				@ 016,015 SAY VAI->VAI_NOMUSU SIZE 180,08 OF oCliNI PIXEL COLOR CLR_RED FONT oFCliNIR
				DEFINE SBUTTON FROM 013,333 TYPE 15 ENABLE OF oCliNI // Botao VISUALIZAR
				DEFINE SBUTTON FROM 013,175 TYPE 1 ACTION (oCliNI:End()) ENABLE OF oCliNI // Botao OK
				@ 033,015 SAY (STR0002+"( "+VCF->VCF_NIVIMP+" )") SIZE 180,08 OF oCliNI PIXEL COLOR CLR_BLUE FONT oFCliNIR
				If !Empty(VCF->VCF_AREVEN)
					@ 045,015 SAY (STR0003+VCF->VCF_AREVEN+" - "+VCB->VCB_DESREG) SIZE 180,08 OF oCliNI PIXEL COLOR CLR_BLUE FONT oFCliNIR
				EndIf
				@ 060,015 SAY SA1->A1_NOME SIZE 180,08 OF oCliNI PIXEL COLOR CLR_HBLUE FONT oFCliNIR
				@ 005,007 TO 077,211 LABEL "" OF oCliNI PIXEL // Caixa Sair
				ACTIVATE MSDIALOG oCliNI CENTER
			EndIf
		EndIf
		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek(xFilial("SA1") + cCliLoj )
			If SA1->A1_RISCO $ GetNewPar("MV_CKCLINR","E") // Verifica o risco do Cliente se esta no Parametro
				lAtual := .t.
				DbSelectArea("VAI")
				DbSetOrder(4)
				DbSeek( xFilial("VAI") + __CUSERID )
				DEFINE MSDIALOG oCliNR FROM 000,000 TO 011,055 TITLE (STR0004+SA1->A1_RISCO) OF oMainWnd
				@ 016,015 SAY VAI->VAI_NOMUSU SIZE 180,08 OF oCliNR PIXEL COLOR CLR_BLUE FONT oFCliNIR
				DEFINE SBUTTON FROM 013,333 TYPE 15 ENABLE OF oCliNR // Botao VISUALIZAR
				DEFINE SBUTTON FROM 013,175 TYPE 1 ACTION (oCliNR:End()) ENABLE OF oCliNR // Botao OK
				@ 030,014 BITMAP OXFig RESOURCE "SVM" OF oCliNR PIXEL ADJUST NOBORDER SIZE 40,40
				@ 040,062 SAY ("<<< "+STR0004+SA1->A1_RISCO+" >>>") SIZE 140,08 OF oCliNR PIXEL COLOR CLR_HRED FONT oFCliNIR
				@ 056,062 SAY SA1->A1_NOME SIZE 140,08 OF oCliNR PIXEL COLOR CLR_HBLUE FONT oFCliNIR
				@ 005,007 TO 077,211 LABEL "" OF oCliNR PIXEL // Caixa Sair
				ACTIVATE MSDIALOG oCliNR CENTER
			EndIf
		EndIf
		If lAtual
			If SX6->(DbSeek(xFilial("SX6")+"MV_CKCLIXX")) // Atualiza Parametro
				RecLock("SX6",.f.)
				SX6->X6_CONTEUD := ( cPRW +" "+ cHrMin +" "+ __CUSERID +" "+ cCliLoj )
				SX6->X6_CONTSPA := ( cPRW +" "+ cHrMin +" "+ __CUSERID +" "+ cCliLoj )
				SX6->X6_CONTENG := ( cPRW +" "+ cHrMin +" "+ __CUSERID +" "+ cCliLoj )
				MsUnlock()
			EndIf
		EndIf
	EndIf
	// Volta posicoes originais dos Arquivos
	sRestArea(aArea)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออัออออออออออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFM_GVECVSCณLuis / Manoel               | Data ณ  19/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออฯออออออออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravacao da tabela VEC e VSC                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcNroDoc - Numero da Nota Fiscal de Saida                    บฑฑ
ฑฑบ          ณcSerDoc - Serie da Nota Fiscal de Saida                     บฑฑ
ฑฑบ          ณcTabela - "VEC" grava VEC, "VSC" grava VSC, "" grava AMBOS  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGestao de Concessionarias                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FM_GVECVSC(cNroDoc,cSerDoc,cTabela)

Local lVECVALIRR := VEC->(FieldPos("VEC_VALIRR")) > 0
Local lVECVALCSL := VEC->(FieldPos("VEC_VALCSL")) > 0

Default cTabela := "VEC.VSC"

DbSelectArea("SF2")
DbsetOrder(1)
DbSeek(xFilial("SF2")+cNroDoc+cSerDoc)

DbSelectArea("VS1")
DbsetOrder(3)
lTemOrc := DbSeek(xFilial("VS1")+cNroDoc+cSerDoc)

DbSelectArea("SD2")
DbsetOrder(3)
DbSeek(xFilial("SD2")+cNroDoc+cSerDoc)

While !Eof() .and. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE == xFilial("SD2")+cNroDoc+cSerDoc

	If "VEC" $ cTabela // Grava Pecas

		dbSelectArea("SFT")
		dbSetOrder(1)  // FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM
		nValICM := 0
		if dbSeek(xFilial("SFT")+"S"+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM)
			nValICM := SFT->FT_VALICM
		endif

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+SD2->D2_COD)

		If FM_TipPro(SB1->B1_COD) <> "P" // retorna o Tipo de Produto
			DbSelectArea("SD2")
			DbSkip()
			Loop
		Endif

		dbSelectarea("SF4")
		dbSeek(xFilial("SF4")+SD2->D2_TES)

		dbSelectArea("VEC")

		RecLock("VEC",.T.)
		If lTemOrc
			VEC_NUMORC := VS1->VS1_NUMORC
		Endif
		VEC_NUMREL := GetSXENum("VEC","VEC_NUMREL")
		ConfirmSx8()
		VEC_NUMIDE := GetSXENum("VEC","VEC_NUMIDE")
		ConfirmSx8()
		if FieldPos("VEC_ALQICM")>0
			if nValICM > 0
				VEC_ALQICM := SD2->D2_PICM
			endif
		endif
		VEC_FILIAL := xFilial("VEC")
		VEC_GRUITE := SB1->B1_GRUPO
		VEC_CODITE := SB1->B1_CODITE
		VEC_VALVDA := SD2->D2_TOTAL
		VEC_VALBRU := SD2->D2_TOTAL + SD2->D2_VALFRE + SD2->D2_SEGURO + SD2->D2_DESPESA + SD2->D2_VALIPI + SD2->D2_ICMSRET + SD2->D2_DESCON
		VEC_VALDES := SD2->D2_DESCON
		VEC_QTDITE := SD2->D2_QUANT
		VEC_VALICM := nValICM

		SBM->(dbSetOrder(1))
		SBM->(dbSeek(xFilial("SBM")+SB1->B1_GRUPO))
		cCodMar := SBM->BM_CODMAR

		VEC_CODMAR := cCodMar //Posicione("SBM",1, xFilial("SBM")+SB1->B1_GRUPO,"SBM->BM_CODMAR")
		VEC_PECINT := SB1->B1_COD

		VEC->VEC_CUSMED := SD2->D2_CUSTO1

		VEC->VEC_VALFRE := SD2->D2_VALFRE
		VEC->VEC_VALSEG := SD2->D2_SEGURO
		VEC->VEC_DESACE := SD2->D2_DESPESA
		VEC->VEC_ICMSRT := SD2->D2_ICMSRET
		VEC->VEC_VALIPI := SD2->D2_VALIPI
		If lVECVALIRR
			VEC->VEC_VALIRR := SD2->D2_VALIRRF
			VEC->VEC_VMFIRR := FG_CALCMF( {{SD2->D2_EMISSAO,VEC->VEC_VALIRR}} )
		EndIf
		If lVECVALCSL
			VEC->VEC_VALCSL := SD2->D2_VALCSL
			VEC->VEC_VMFCSL := FG_CALCMF( {{SD2->D2_EMISSAO,VEC->VEC_VALCSL}} )
		EndIf	

		VEC->VEC_LUCBRU := (VEC->VEC_VALBRU-VEC->VEC_VALDES) - VEC->VEC_TOTIMP - VEC->VEC_CUSMED - VEC->VEC_ICMSRT + VEC->VEC_ICMSST + VEC->VEC_DCLBST + VEC->VEC_COPIST
		VEC->VEC_LUCLIQ := VEC->VEC_LUCBRU - VEC->VEC_JUREST - VEC->VEC_DESVAR - VEC->VEC_DESDEP - VEC->VEC_DESADM - VEC->VEC_DESFIX  //LUCRO MARGINAL
		VEC->VEC_RESFIN := VEC->VEC_LUCLIQ - VEC->VEC_CUSFIX  //LAIR

		VEC_DATVEN := SD2->D2_EMISSAO

		VEC_NUMNFI := SD2->D2_DOC
		VEC_SERNFI := SD2->D2_SERIE


		VEC_VALCOF := SD2->D2_VALIMP5
		VEC_VALPIS := SD2->D2_VALIMP6
		VEC_TOTIMP := VEC_VALICM + VEC_VALCOF + VEC_VALPIS
		VEC_JUREST := 0
		VEC_CUSTOT := VEC_CUSMED + VEC_JUREST
		VEC_LUCBRU := VEC_VALVDA - VEC_TOTIMP - VEC_CUSMED

		//Comissao
		if SF4->F4_OPEMOV == "05" // Venda
			aValCom    := FG_COMISS("P",SF2->F2_VEND1,VEC_DATVEN,VEC_GRUITE,VEC_VALVDA,"T",VEC_NUMIDE)
			VEC_COMVEN := aValCom[1]
			VEC_COMGER := aValCom[2]
		Else
			VEC_COMVEN := 0
			VEC_COMGER := 0
		Endif

		VEC_DESVAR := VEC_COMVEN + VEC_COMGER
		VEC_LUCLIQ := VEC_LUCBRU - VEC_JUREST - VEC_DESVAR - VEC_DESDEP - VEC_DESADM - VEC_DESFIX
		VEC_DESFIX := 0
		VEC_CUSFIX := 0
		VEC_DESDEP := 0
		VEC_DESADM := 0
		VEC_RESFIN := 0
		VEC_BALOFI := "B" //Balcao
		VEC_DEPVEN := ""
		VEC_TIPTEM := ""  //Gravar qdo Ordem de Servico
		VEC_NUMOSV := ""  //Gravar qdo Ordem de Servico
		VEC_RESFIN := VEC_LUCLIQ - VEC_CUSFIX
		VEC_ITENFI := SD2->D2_ITEM

		VEC_VMFBRU := FG_CALCMF( { {dDataBase,VEC_VALBRU} })
		VEC_VMFVDA := VEC_VMFBRU - FG_CALCMF( {{SD2->D2_EMISSAO,VEC_VALDES}} )
		VEC_VMFICM := FG_CALCMF( { {FG_RTDTIMP("ICM",SD2->D2_EMISSAO),VEC_VALICM} })
		VEC_VMFPIS := FG_CALCMF( { {FG_RTDTIMP("PIS",SD2->D2_EMISSAO),VEC_VALPIS} })
		VEC_VMFCOF := FG_CALCMF( { {FG_RTDTIMP("COF",SD2->D2_EMISSAO),VEC_VALCOF} })
		VEC_TMFIMP := VEC_VMFICM + VEC_VMFCOF + VEC_VMFPIS
		VEC_CMFMED := FG_CALCMF( { {SD2->D2_EMISSAO,VEC_CUSMED} })
		VEC_JMFEST := FG_CALCMF( { {SD2->D2_EMISSAO,VEC_JUREST} })
		VEC_CMFTOT := VEC_CMFMED + VEC_JMFEST
		VEC_LMFBRU := VEC_VMFVDA - VEC_TMFIMP - VEC_CMFTOT

		VEC_CMFVEN := FG_CALCMF( { {FG_RTDTIMP("PIS",SD2->D2_EMISSAO),VEC_COMVEN} })
		VEC_CMFGER := FG_CALCMF( { {FG_RTDTIMP("PIS",SD2->D2_EMISSAO),VEC_COMGER} })

		VEC_DMFVAR := VEC_CMFVEN + VEC_CMFGER
		VEC_LMFLIQ := VEC_LMFBRU - VEC_DMFVAR
		VEC_DMFFIX := 0
		VEC_CMFFIX := 0
		VEC_CMFDEP := 0
		VEC_DMFADM := 0
		VEC_RMFFIN := VEC_LMFLIQ - VEC_DMFFIX - VEC_CMFFIX - VEC_DMFDEP - VEC_DMFADM

		dbSelectArea("VEC")
		MsUnlock()

		If ExistBlock("OX001VEC") // Ponto de Entrada para Atualizacao dos campos referentes ao ST (VEC_ICMSST + VEC_DCLBST + VEC_COPIST)
			ExecBlock("OX001VEC",.f.,.f.,{VEC->VEC_PECINT,VEC->VEC_DATVEN,SD2->D2_TES,SD2->D2_BASEICM,VEC->VEC_QTDITE,"VEC"})
		EndIf

	Endif

	DbSelectArea("SD2")
	DbSkip()

Enddo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออัออออออออออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFM_TIPPRO ณManoel / Andre / Luis       | Data ณ  19/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออฯออออออออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o Tipo de Produto                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcCodPro - Codigo do Produto (B1_COD)                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGestao de Concessionarias                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FM_TIPPRO(cCodPro)
Local cRet   := "P"
Local cQuery := ""
Local cQSB1  := "SQLTIPPRO"
cQuery := "SELECT SBM.BM_TIPGRU FROM "+RetSQLName("SB1")+" SB1"
cQuery += " JOIN "+RetSQLName("SBM")+" SBM ON (SBM.BM_FILIAL = '"+xFilial("SBM")+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.D_E_L_E_T_ = ' ')"
cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
cQuery +=   " AND SB1.B1_COD    = '" + cCodPro + "'"
cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQSB1, .F., .T. )
If !( cQSB1 )->(Eof())
	If Alltrim(( cQSB1 )->BM_TIPGRU)  == "4"
		cRet := "S"
	ElseIf Alltrim(( cQSB1 )->BM_TIPGRU)  == "7"
		cRet := "V"
	Else
		cRet := "P"
	Endif
Endif
( cQSB1 )->( DbCloseArea() )
Return cRet

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFM_GerLog  ณ Autor ณ Rafael Goncalves     ณ Data ณ 13/09/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Cria log de Alteracao de Fase do Orcamento                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณOFIXI001                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ1-cTipo = F - Fases do Orcamento / P - Pausa Servico        ณฑฑ
ฑฑณ          ณ          L - Autoriza Utilizar Inconveniente nao valido.   ณฑฑ
ฑฑณ          ณ2-cnumIde = (cTipo=F) cNumIde = Numero Orcamento            ณฑฑ
ฑฑณ          ณ3-cText    = Texto para impressao na linha do log.          ณฑฑ
ฑฑณ          ณ4-cFilialGL= Filial do registro                             ณฑฑ
ฑฑณ          ณ5-cObsGL  = Texto livre para gravacao do log                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FM_GerLog(cTipo,cNumIde,cTexto,cFilialGL,cObsGL)
Local cNomeArq := ""
Local nHnd := 0
Local _sAlias := Alias()
Local cUsuLog  := Alltrim(substr(cUsuario,7,11)) //Usuarios
Local cCabecLog := FunName()+ " - Dia: " + FWTimeStamp(2) + "h Usr: "+__cUserID+" - "+Alltrim(cUsuLog)
Local llopp := .f.
Default ctipo := ""
Default cTexto := ""
Default cNumIde := ""
Default cFilialGL := ""
Default cObsGL := ""


If cTipo == "F"//fases do orcamento
	DBSelectArea("VS1")
	DBSetOrder(1)
	DBSeek(xFilial("VS1")+cNumIde)

	cNomeArq := "\logsmil\Orcamentos\Orc_"+dtos(DDATABASE)+".txt"
	nHnd := FOPEN(cNomeArq,2)

	if nHnd == -1
		nHnd := FCREATE(cNomeArq,0)
	endif

	if nHnd >=0
		FSeek(nHnd,0,2)

		FWrite(nHnd,cCabecLog+" alt.VS1_STATUS: "+cFilialGL+"/"+cNumIde+": "+cObsGL+" -> " + VS1->VS1_STATUS + " - Chamada: " + ProcName(1) + " - " + cValToChar(ProcLine(1)) + " " + cTexto + CHR(13)+CHR(10) )

		FClose(nHnd)
	else
		makeDir( "\logsmil" )
		makeDir( "\logsmil\Orcamentos" )
		FM_GerLog(cTipo,cNumIde)
		If llopp
			MsgAlert(STR0013,STR0008)
			dbSelectArea(_sAlias)
			Return
		EndIF
		llopp := .t.
	endif
ElseIf cTipo == "P" //Pausa Servico
	cNomeArq := "\logsmil\PausaServico\Ser_"+dtos(DDATABASE)+".txt"
	nHnd := FOPEN(cNomeArq,2)

	if nHnd == -1
		nHnd := FCREATE(cNomeArq,0)
	endif

	if nHnd >=0
		FSeek(nHnd,0,2)

		FWrite(nHnd,Left(cCabecLog+cTexto,175)+CHR(13)+CHR(10))

		FClose(nHnd)
	else
		makeDir( "\logsmil" )
		makeDir( "\logsmil\PausaServico" )
		FM_GerLog(cTipo,cNumIde,cTexto)
		If llopp
			MsgAlert(STR0014,STR0008)
			dbSelectArea(_sAlias)
			Return
		EndIF
		llopp := .t.
	endif
ElseIf cTipo == "L" //Libera utilizar incinveniente fora da validade
	cNomeArq := "\logsmil\inconFPV\FPV_"+dtos(DDATABASE)+".txt"
	nHnd := FOPEN(cNomeArq,2)

	if nHnd == -1
		nHnd := FCREATE(cNomeArq,0)
	endif

	if nHnd >=0
		FSeek(nHnd,0,2)

		FWrite(nHnd,cCabecLog+cTexto+CHR(13)+CHR(10))

		FClose(nHnd)
	else
		makeDir( "\logsmil" )
		makeDir( "\logsmil\inconFPV" )
		FM_GerLog(cTipo,cNumIde,cTexto)
		If llopp
			MsgAlert(STR0015,STR0008)
			dbSelectArea(_sAlias)
			Return
		EndIF
		llopp := .t.
	endif
EndIF

dbSelectArea(_sAlias)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_AMIIN  บ Autor ณ Andre Luis Almeida บ Data ณ 29/10/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Verificar se um dos fontes contidos no vetor esta na pilha บฑฑ
ฑฑบ          ณ de chamadas e este eh o mesmo que foi chamado no MENU      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aFontes  -> Vetor com os fontes a serem verificados        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MIL                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_AMIIN(aFontes)
Local lRet      := .f.
Local ni        := 0
Default aFontes := {}
////////////////////////////////////////////////////////
// Deixar passar quando chamado do < CTRL > + < F12 > //
////////////////////////////////////////////////////////
If FM_PILHA("U_MILAXTABELA")
	lRet := .t.
Else
	For ni := 1 to len(aFontes)
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Verifica se um dos fontes contidos no vetor esta na pilha de chamadas e este eh o mesmo que foi chamado no MENU //
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		If 	( FM_PILHA(aFontes[ni]) .and. FunName() == aFontes[ni] ) .or. ;
			( FM_PILHA("U_"+aFontes[ni]) .and. FunName() == aFontes[ni] ) .or. ;
			( FM_PILHA("U_"+aFontes[ni]) .and. FunName() == "U_"+aFontes[ni] )
			lRet := .t.
			Exit
		EndIf
	Next
EndIf
If !lRet
	Alert(STR0023,STR0008) // O Objeto selecionado nao pertence ao modulo escolhido. / Atencao
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_LEVXNU   บAutor  ณTakahashi       บ Data ณ  28/02/13   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna uma matriz com os acessos do menu do usuแrio       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nAuxModulo -> Numero do Modulo                             บฑฑ
ฑฑบ          ณ cProgExec  -> Nome do programa a ser procurado no menu.    บฑฑ
ฑฑบ          ณ               Deixe em branco para todos.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_LEVXNU(nAuxModulo,cProgExec)

Local cAuxBrowse := ""

Default nAuxModulo := nModulo
Default cProgExec := ""

If lChkUserRules .or. nModulo <> nAuxModulo
	If !ChkUserRules(cProgExec,cAcesso,STR0024) // Usuแrio sem acesso!
		Return cAuxBrowse
	EndIf
EndIf
cAuxBrowse := FMX_FUNCAC(nAuxModulo,cProgExec)

Return cAuxBrowse


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_FUNCAC   บAutor  ณTakahashi       บ Data ณ  28/02/13   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Levanta os acessos do menu de um usuario                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nAuxModulo -> Numero do Modulo                             บฑฑ
ฑฑบ          ณ cProgExec  -> Nome do programa a ser procurado no menu.    บฑฑ
ฑฑบ          ณ               Deixe em branco para todos.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FMX_LEVXNU                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FMX_FUNCAC(nAuxModulo,cProgExec)

Local nX     := 0
Local aLoad  := {}
Local aRet   := {}
Local aMenus := {}
//
If GetVersao(.f.) == "P10" // VERSAO 10
	PswOrder(2)
	PswSeek( cUserName, .T. )
	aMenus    := PswRet ( 3 )
	nPosMenu  := Ascan(aMenus[1],{|x| Left(x,2) == StrZero(nAuxModulo,2) })
	If nPosMenu > 0
		aLoad := XNULOAD(Substr(aMenus[1,nPosMenu],4))
	Endif
Else // VERSOES ATUAIS
	aLoad := XNULOAD(FWGetMnuFile())
EndIf
//
For nX:= 1 To Len(aLoad)
	FMX_GETMENU( aLoad[nX][3], @aRet , cProgExec)
Next nX
//
Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_GETMENU  บ Autor ณ Takahashi      บ Data ณ  28/02/13   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Levanta os acessos do menu de um usuario                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FMX_FUNCAC                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FMX_GETMENU( aLoad, aRet , cProgExec )

Local nX

For nX:=1 To Len(aLoad)
	If ValType(aLoad[nX][3]) == "A" .AND. aLoad[nX][2] == "E"
		FMX_GETMENU( aLoad[nX][3], @aRet , cProgExec)
	Else
		If aLoad[nX][2] == "E" .and. (aLoad[nX][3] == cProgExec .or. Empty(cProgExec))
			aAdd( aRet, { aLoad[nX][3], aLoad[nX][5],aLoad[nX][7] } )
		EndIf
	EndIf
Next

Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    | FGX_MntTab | Autor | Andr้ Delorme         | Data | 17/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Function FGX_MntTab(_oPrinter, _aData, _marTop, _marLeft,_aInfo,nLarg,nComp,cAlign,oFontPM)
Local nCntFor
Default _aInfo = {}
Default nLarg = 16
Default nComp = 10
Default oFontPM = oVerdana9
Default cAlign = "Center"
nMax := 0
for nCntFor := 1 to Len(_aData)
	nAngle := 0
	if (Len(_aData[nCntFor]) > 8)
		nAngle := _aData[nCntFor,9]
	endif
	nLinhaLin = _aData[nCntfor,2] * nComp + _marTop
	nColunLin = _aData[nCntfor,3] * nLarg + _marLeft
	nComprLin = _aData[nCntfor,5] * nComp
	nLargLin  = _aData[nCntfor,4] * nLarg
	//
	_oPrinter:Line(nLinhaLin,nColunLin,nLinhaLin + nComprLin, nColunLin)
	_oPrinter:Line(nLinhaLin,nColunLin,nLinhaLin, nColunLin + nLargLin)
	_oPrinter:Line(nLinhaLin,nColunLin+nLargLin, nLinhaLin + nComprLin ,nColunLin + nLargLin)
	_oPrinter:Line(nLinhaLin+nComprLin,nColunLin, nLinhaLin + nComprLin ,nColunLin + nLargLin)

	xValor := iif(Len(_aInfo)>0 .and. Len(_aInfo) >= nCntfor  .and. _aData[nCntfor,8] == "",_aInfo[nCntfor],_aData[nCntfor,8])
	if _aData[nCntfor,6] == "N"
		cInfo := Transform(xValor,_aData[nCntfor,7])
	else
		cInfo := xValor
	endif

	if nAngle == 0
		_oPrinter:SayAlign(nLinhaLin + IIF(cAlign=="Top",0, nComprLin/2 - 4) , nColunLin,cInfo,oFontPM,nLargLin,nComprLin,CLR_BLACK,2,0)
	else
		nWidth = _oPrinter:GetTextWidth(cInfo,oFontPM) * 0.3
		_oPrinter:Say(nLinhaLin + (nComprLin/2) +(nWidth/2) , nColunLin + (nLargLin / 2) + 2 ,cInfo, oFontPM, , , 270 )
	endif

	if nLinhaLin+ nComprLin > nMax
		nMax := nLinhaLin+ nComprLin
	endif
next
//
return nMax

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_GERNFS   บ Autor ณ Manoel Filho   บ Data ณ  06/08/13     บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescricao ณ Gera็ใo de NF de Saida                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParamet 1 ณaVetCb - Vetor do Cabe็alho (UniDimensional)                  บฑฑ
ฑฑบ			 ณ         Elemento 01 - Codigo do Cliente                      บฑฑ
ฑฑบ			 ณ         Elemento 02 - Loja do Cliente                        บฑฑ
ฑฑบ			 ณ         Elemento 03 - Vendedor                               บฑฑ
ฑฑบ			 ณ         Elemento 04 - Condi็ใo de Pagamento                  บฑฑ
ฑฑบ			 ณ         Elemento 05 - Natureza Financeira                    บฑฑ
ฑฑบ			 ณ         Elemento 06 - Banco                                  บฑฑ
ฑฑบParamet 2 ณaVetIt - Vetor dos Itens (MultiDimensional)                   บฑฑ
ฑฑบ			 ณ         Elemento 01 - Produto                                บฑฑ
ฑฑบ			 ณ         Elemento 02 - Valor                                  บฑฑ
ฑฑบParamet 3 ณlMsg - Mostra tela com o Nro/Serie da NF gerada? (.t./.f.)    บฑฑ
ฑฑบParamet 4 ณcDMSPrefOri - Prefixo de Origem                               บฑฑ
ฑฑบParamet 5 ณaVetE1 - Vetor dos Titulos (MultiDimensional)                 บฑฑ
ฑฑบ			 ณ         Elemento 01 - Vetor aHeader Campos do SE1 (UniDimens)บฑฑ
ฑฑบ			 ณ         Elemento 02 - Vetor aCols Titulos (MultiDimensional) บฑฑ
ฑฑบParamet 6 ณcTipCli - Tipo de Cliente                                     บฑฑ
ฑฑบParamet 7 ณcIndPre - Indicador de Presenca                               บฑฑ
ฑฑบParamet 8 cUF      - UF                                                  บฑฑ
ฑฑบParamet 9 cMun     - Municipio                                           บฑฑ
ฑฑบParamet 10ณcIntFin - Intermediador Financeiro                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_GERNFS(aVetCb,aVetIt,lMsg,cDMSPrefOri,aVetE1,cTipCli,cIndPre,cUF,cMun,cIntFin)
//
Local cNumPed
Local nCntFor       := 0
Local nCntCol       := 0
Local cNumIte       := "00"
Local lRet	        := .f.
Local nQtdLib       := 0

Local cMsgSC9       := ""
Local aParc         := {}
Local cParc         := ""
Local aIteTempPV    := {}
//
Local lExistPET     := (ExistBlock("PEGERNFT"))
Local aAuxParc      := {}
//
Private aCabPV      := {}
Private aItePV      := {}
Private cSerie      := {}
Private cNota       := {}
//
Default aVetCb      := {}
Default aVetIt      := {}
Default lMsg        := .f.
Default cDMSPrefOri := ""
Default aVetE1      := {}
Default cTipCli     := ""
Default cIndPre     := ""
Default cUF         := ""
Default cMun        := ""
Default cIntFin     := ""
//
If len(aVetCb) > 0
	aAdd(aCabPV,{"C5_TIPO"   ,"N"	 	 ,Nil})
	aAdd(aCabPV,{"C5_CLIENTE",aVetCb[1]	 ,Nil})
	aAdd(aCabPV,{"C5_LOJACLI",aVetCb[2]	 ,Nil})
	aAdd(aCabPV,{"C5_VEND1"  ,aVetCb[3]	 ,Nil})
	aAdd(aCabPV,{"C5_CONDPAG",aVetCb[4]	 ,Nil})
	aAdd(aCabPV,{"C5_COMIS1" ,0		   	 ,Nil})
	aAdd(aCabPV,{"C5_EMISSAO",ddatabase	 ,Nil})
	if LEN(aVetCb) >= 8
		aAdd(aCabPV,{"C5_MENPAD" , aVetCb[9] ,Nil})
		aAdd(aCabPV,{"C5_MENNOTA", aVetCb[8] ,Nil})
	EndIF
	If !Empty(aVetCb[6])
		aAdd(aCabPV,{"C5_BANCO",aVetCb[6],Nil})
	EndIf
	If !Empty(aVetCb[5]) .and. SC5->(FieldPos("C5_NATUREZ")) > 0
		aAdd(aCabPV,{"C5_NATUREZ",aVetCb[5],Nil})
	EndIf
	If Empty(cTipCli)
		cTipCli := FM_SQL("SELECT A1_TIPO FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+aVetCb[1]+"' AND A1_LOJA='"+aVetCb[2]+"' AND D_E_L_E_T_=' '")
	EndIf
	If !Empty(cTipCli)
		aAdd(aCabPV,{"C5_TIPOCLI",cTipCli,Nil})
	EndIf
	If !Empty(cIndPre) .and. SC5->(FieldPos("C5_INDPRES")) > 0
		aAdd(aCabPV,{"C5_INDPRES",cIndPre,Nil})
	EndIf
	If !Empty(cUF)
		aAdd(aCabPV,{"C5_ESTPRES",cUF,Nil})
	Endif
	If !Empty(cMun)
		aAdd(aCabPV,{"C5_MUNPRES",cMun,Nil})
	Endif
	If !Empty(cIntFin) .and. SC5->(FieldPos("C5_CODA1U")) > 0
		aAdd(aCabPV,{"C5_CODA1U",cIntFin,Nil})
	EndIf
EndIf
//
For nCntFor := 1 to Len(aVetIt)
	//
	DBSelectArea("SB1")
	DBSetOrder(1)
	DBSeek(xFilial("SB1")+aVetIt[nCntFor,1])
	//Pega a classificacao fiscal de acordo com o estado do cliente
	//cCFiscal := FG_CLAFIS(SB1->B1_TS)
	//
	cNumIte := SOMA1(cNumIte)
	//
	aIteTempPV := {}
	//
	aAdd(aIteTempPV,{"C6_ITEM"   ,cNumIte			,nil})
	aAdd(aIteTempPV,{"C6_PRODUTO",SB1->B1_COD  		,nil})
	aAdd(aIteTempPV,{"C6_QTDVEN" ,1					,nil})
	aAdd(aIteTempPV,{"C6_ENTREG" ,dDataBase  		,nil})
	aAdd(aIteTempPV,{"C6_UM"     ,SB1->B1_UM        ,nil})
	aAdd(aIteTempPV,{"C6_TES"    ,SB1->B1_TS  		,nil})
	aAdd(aIteTempPV,{"C6_LOCAL"  ,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"),nil})
	aAdd(aIteTempPV,{"C6_PRUNIT" ,aVetIt[nCntFor,2] ,nil})
	aAdd(aIteTempPV,{"C6_PRCVEN" ,aVetIt[nCntFor,2] ,nil})
	aAdd(aIteTempPV,{"C6_VALOR"  ,aVetIt[nCntFor,2] ,nil})
	aAdd(aIteTempPV,{"C6_VALDESC",0				  	,nil})
	aAdd(aIteTempPV,{"C6_CLI"    ,aVetCb[1]			,nil})
	aAdd(aIteTempPV,{"C6_LOJA"   ,aVetCb[2]			,nil})
	aAdd(aItePv,aClone(aIteTempPV))
	//
	//
Next
// PE para Altera็ใo dos Vetores aCabPV e aItePV, antes da Gera็ใo do Pedido de Venda
if ExistBlock("PEGERNFS")
	if !ExecBlock("PEGERNFS",.f.,.f.)
		Return({"",""})
	Endif
Endif
// Gera็ใo do pedido de Venda
lMsErroAuto := .f.
MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItePv,3)
//
If lMsErroAuto
	MostraErro()
	Return {"",""}
EndIf
//
cNumPed := SC5->C5_NUM
//
// Gera็ใo da NF
//
lCredito := .t.
lEstoque := .t.
lLiber   := .t.
lTransf  := .f.
//
SC9->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SC6->(dbSeek(xFilial("SC6") + cNumPed + "01"))
While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed
	//
	If !SC9->(dbSeek(xFilial("SC9")+cNumPed+SC6->C6_ITEM))
		nQtdLib := SC6->C6_QTDVEN
		nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.t.,lLiber,lTransf)
	EndIf
	//
	SC6->(dbSkip())
Enddo
//
aPvlNfs := {}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Selecionando Itens para Faturamento ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SB1->(dbSetOrder(1))
SC5->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SB5->(dbSetOrder(1))
SB2->(dbSetOrder(1))
SF4->(dbSetOrder(1))
SE4->(dbSetOrder(1))
SC9->(dbSeek(xFilial("SC9") + cNumPed + "01"))
While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .and. SC9->C9_PEDIDO == cNumPed
	If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
		SC5->(dbSeek( xFilial("SC5") + SC9->C9_PEDIDO ))
		SC6->(dbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM ))
		SB1->(dbSeek( xFilial("SB1") + SC9->C9_PRODUTO ))
		SB2->(dbSeek( xFilial("SB2") + SB1->B1_COD ))
		SB5->(dbSeek( xFilial("SB5") + SB1->B1_COD ))
		SF4->(MsSeek( xFilial("SF4") + SC6->C6_TES ))
		SE4->(MsSeek( xFilial("SE4") + SC5->C5_CONDPAG ))
		aAdd(aPvlNfs,{SC9->C9_PEDIDO,;
						SC9->C9_ITEM,;
						SC9->C9_SEQUEN,;
						SC9->C9_QTDLIB,;
						SC9->C9_PRCVEN,;
						SC9->C9_PRODUTO,;
						SF4->F4_ISS=="S",;
						SC9->(RecNo()),;
						SC5->(RecNo()),;
						SC6->(RecNo()),;
						SE4->(RecNo()),;
						SB1->(RecNo()),;
						SB2->(RecNo()),;
						SF4->(RecNo())})
	Else
		If !Empty(SC9->C9_BLCRED)
			cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLCRED"))+": "+SC9->C9_BLCRED+CHR(13)+CHR(10)
		EndIf
		If !Empty(SC9->C9_BLEST)
			cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLEST"))+": "+SC9->C9_BLEST+CHR(13)+CHR(10)
		EndIf
	EndIf
	SC9->(dbSkip())
	If !Empty(cMsgSC9)
		MsgStop(STR0026+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsgSC9,STR0002) // Pedido sem itens liberados! / Atencao
		Return({"",""})
	EndIf
Enddo
//
ConfirmSx8()
//
lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))
If !lRet
	Return({"",""})
EndIf
If Len(aPvlNfs) > 0
	PERGUNTE("MT460A",.f.)
	cNota := MaPvlNfs(aPvlNfs,cSerie,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1), .F., 0, 0, .T., .F.)
	If lMsErroauto
		MostraErro()
		Return({"",""})
	EndIf
EndIf
//
if lMsErroAuto
	MostraErro()
	Return({"",""})
Endif
//
If Empty(SF2->F2_PREFORI) .or. Empty(SF2->F2_DUPL)
	DbSelectArea("SF2")
	RecLock("SF2",.f.)
		If Empty(SF2->F2_PREFORI) .and. !Empty(cDMSPrefOri)
			SF2->F2_PREFORI  := cDMSPrefOri
		EndIf
		// Titulos gerados devido a Condi็ใo de Pagamento Padrใo
		If Empty(SF2->F2_DUPL) .and. FMX_VALFIN( SF2->F2_PREFIXO , SF2->F2_DOC , SF2->F2_CLIENTE , SF2->F2_LOJA ) <> 0
			SF2->F2_DUPL := SF2->F2_DOC
		EndIf
	MsUnLock()
EndIf
//
If len(aVetE1) > 1 // MAIOR QUE UM ( aHeader e aCols )
	// Titulos a serem gerados apos a gera็ใo da NF devido a Condi็ใo de Pagamento do tipo Negociada
	If Empty(SF2->F2_DUPL)
		DbSelectArea("SF2")
		RecLock("SF2",.f.)
			SF2->F2_DUPL := SF2->F2_DOC // Gravar a Numera็ใo dos Titulos ( mesmo nro da NF )
		MsUnLock()
	EndIf
	For nCntFor := 1 to len(aVetE1[2])
		cParc := FM_SQL("SELECT MAX(SE1.E1_PARCELA) FROM "+RetSQLName("SE1")+" SE1 WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND SE1.E1_PREFIXO='"+SF2->F2_PREFIXO+"' AND SE1.E1_NUM='"+SF2->F2_DUPL+"' AND SE1.E1_TIPO='NF' AND SE1.E1_FILORIG='"+SF2->F2_FILIAL+"'")
		If Empty(cParc)
			cParc := strzero(0,TamSX3("E1_PARCELA")[1])
		EndIf
		While .t.
			cParc := Soma1(cParc)
			If cParc <> FM_SQL("SELECT SE1.E1_PARCELA FROM "+RetSQLName("SE1")+" SE1 WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND SE1.E1_PREFIXO='"+SF2->F2_PREFIXO+"' AND SE1.E1_NUM='"+SF2->F2_DUPL+"' AND SE1.E1_PARCELA='"+cParc+"' AND SE1.E1_TIPO='NF' AND SE1.E1_FILORIG='"+SF2->F2_FILIAL+"'")
				Exit
			EndIf
		EndDo
		aParc := {}
		aAdd(aParc,{"E1_PREFIXO",SF2->F2_PREFIXO,nil})
		aAdd(aParc,{"E1_NUM"    ,SF2->F2_DUPL   ,nil})
		aAdd(aParc,{"E1_PARCELA",cParc          ,nil})
		If !Empty(aVetCb[5])
			aAdd(aParc,{"E1_NATUREZ",aVetCb[5]  ,nil})
		EndIf
		aAdd(aParc,{"E1_CLIENTE",SF2->F2_CLIENTE,nil})
		aAdd(aParc,{"E1_LOJA"   ,SF2->F2_LOJA   ,nil})
		aAdd(aParc,{"E1_TIPO"   ,"NF"           ,nil})
		aAdd(aParc,{"E1_PREFORI",SF2->F2_PREFORI,nil})
		aAdd(aParc,{"E1_PEDIDO" ,cNumPed        ,nil})
		aAdd(aParc,{"E1_NUMNOTA",SF2->F2_DOC    ,nil})
		aAdd(aParc,{"E1_SERIE"  ,SF2->F2_SERIE  ,nil})
		aAdd(aParc,{"E1_EMISSAO",dDataBase      ,nil})
		aAdd(aParc,{"E1_VEND1"  ,SF2->F2_VEND1  ,nil})
		If !Empty(aVetCb[6])
			aAdd(aParc,{"E1_PORTADO",aVetCb[6]  ,nil})
		EndIf
		aAdd(aParc,{"E1_ORIGEM" ,"MATA460"      ,nil})
		For nCntCol := 1 to len(aVetE1[1])
			If aVetE1[2,nCntFor,nCntCol] <> NIL
				aAdd(aParc,{aVetE1[1,nCntCol],aVetE1[2,nCntFor,nCntCol],nil})
			EndIf
		Next
		If lExistPET
			aAuxParc := ExecBlock("PEGERNFT",.f.,.f.,{ aClone(aParc) })
			If ValType(aAuxParc) == "A"
				aParc := aClone(aAuxParc)
			EndIf
		EndIf
		If len(aParc) > 0
			Pergunte("FIN040",.f.)
			lMsErroAuto := .f.
			MSExecAuto({|x| FINA040(x)},aParc)
			If lMsErroAuto
				MostraErro()
			EndIf
		EndIf
	Next
EndIf
//
DbSelectArea("SE1")
DbSetOrder(1)
DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL)
While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. SE1->E1_PREFIXO==SF2->F2_PREFIXO .and. SE1->E1_NUM==SF2->F2_DUPL
	If !( SE1->E1_TIPO $ MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVPIABT )
		RecLock("SE1",.f.)
		If Empty(SE1->E1_PORTADO) .and. !Empty(aVetCb[6])
			SE1->E1_PORTADO := aVetCb[6]
		EndIf
		If Empty(SE1->E1_PREFORI) .and. !Empty(SF2->F2_PREFORI)
			SE1->E1_PREFORI := SF2->F2_PREFORI
		EndIf
		MsUnLock()
	EndIf
	DbSkip()
EndDo
//
If lMsg
	FMX_TELAINF( "1" , { { Alltrim(cSerie) , Alltrim(cNota) , STR0025 } } )
Endif
//
Return({cNota,cSerie})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_EXCNFS   บ Autor ณ Manoel Filho   บ Data ณ  08/08/13 	บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescricao ณ Exclusใo de NF de Saida                                    	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParamet 1 ณ Nro da NF                                                    บฑฑ
ฑฑบParamet 2 ณ Serie da NF                                                  บฑฑ
ฑฑบParamet 3 ณ lMsg - Mostra tela com o Nro/Serie da NF cancelada? (.t./.f.)บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_EXCNFS(cNumNfi,cSerNfi,lMsg)
Local aRegSD2   := {}
Local aRegSE1   := {}
Local aRegSE2   := {}
//
DbSelectArea("SC6")
DbSetOrder(4)
DbSeek(xFilial("SC6")+cNumNfi+cSerNfi)
cNumPed := SC6->C6_NUM
DbSetOrder(1)
//
DbSelectArea("SF2")
DbSetOrder(1)
If DbSeek(xFilial("SF2") + cNumNFI + cSerNFI )
	If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2) // Verifica se o estorno do documento de saida pode ser feito
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Estorna o documento de saida                                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PERGUNTE("MTA521",.f.)
		SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
	Else
		Return .f.
	EndIf
EndIf
//
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cancelar PEDIDO                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//
lMsErroAuto := .f.
DbSelectArea("SC5")
DbSetOrder(1)
If DbSeek(xFilial("SC5")+cNumPed)
	aMata410Cab   := {{"C5_NUM"      , cNumPed,Nil}}   //Numero do pedido SC5
	aMata410Itens := {{"C6_NUM"      , cNumPed,Nil}}   //Numero do Pedido SC6
	//Exclui Pedido
	SC9->(dbSetOrder(1))
	SC9->(dbSeek(xFilial("SC9")+cNumPed))
	While !SC9->(Eof()) .And. xFilial("SC9") == SC9->C9_FILIAL .and. cNumPed == SC9->C9_PEDIDO
		SC9->(a460Estorna())
		SC9->(dbSkip())
	EndDo
	MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5)
EndIf
//
If lMsErroAuto
	MostraErro()
	Return .f.
Else
	If lMsg
		FMX_TELAINF( "1" , { { Alltrim(cSerNfi) , Alltrim(cNumNfi) , STR0027 } } )
	Endif
Endif
//
Return(.t.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_RETXML   บAutor  ณ Takahashi      บ Data ณ  01/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o conteudo de um determinado NO de um objeto XML   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oAuxXML - Objeto XML                                       บฑฑ
ฑฑบ          ณ cNode - Nome do No do arquivo XML                          บฑฑ
ฑฑบ          ณ cDefVal - Valor Default                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Conteudo do NO especificado                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_RETXML(oAuxXML,cNode,cDefVal)

Local oAuxObj := XmlChildEx(oAuxXML,cNode)

Default cDefVal := ""

If oAuxObj <> NIL
	cDefVal := oAuxObj:TEXT
EndIf

Return cDefVal

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_RETMAR   บAutor  ณ Takahashi      บ Data ณ  01/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna codigo da marca de cadastrado pelo usuario de uma  บฑฑ
ฑฑบ          ณ marca especifica (tabela 028 da VX5)                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCodMarFab - Codigo da Marca a ser consultado              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Codigo da marca da VE4                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_RETMAR(cCodMarFab)

Local cCodMar

cCodMar := FM_SQL("SELECT VE1_CODMAR FROM " + RetSQLName("VE1") + " WHERE VE1_FILIAL = '" + xFilial("VE1") + "' AND VE1_MARFAB = '" + cCodMarFab + "' AND D_E_L_E_T_ = ' '")

Return cCodMar


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_SQLGC    บAutor  ณ Takahashi      บ Data ณ  01/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa uma consulta SQL no banco de dados e retorna o     บฑฑ
ฑฑบ          ณ conteudo executado                                         บฑฑ
ฑฑบ          ณ Preparado para trabalhar com Gestao Coorporativa           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cSQL -> SQL a ser executado no banco                       บฑฑ
ฑฑบ          ณ Pode enviar varios campos na string                        บฑฑ
ฑฑบ          ณ Campo de Filial deve ser transmitido entre '[ ]'.          บฑฑ
ฑฑบ          ณ Ex: " WHERE VMY_FILIAL = '[VMY]'"                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Matriz com conteudo dos campos enviados como parametro     บฑฑ
ฑฑบ          ณ Se nao encontrar registro, retorna uma matriz vazia.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_SQLGC(cSQL)

Local aRet       := {}
Local cAliasSQL  := "TSQLGC"
Local aFilAtu    := FWArrFilAtu()
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt := cFilAnt
Local nCont      := 0
Local nCont2     := 0
Local cQuery     := cSQL
Local aArea := GetArea()
Local aAuxCPO
Local axFilial := {}

// Obtem do cSQL somente os campos ...
cQuery  := StrTran(cQuery,"SELECT","")
cQuery  := Left(cQuery,At("FROM",cQuery)-1)
aAuxCPO := StrTokArr(cQuery,",")
//

cQuery := cSQL
While .t.
	nCont := At("[",cQuery)
	If nCont == 0
		Exit
	EndIf

	AADD(axFilial,SubStr(cQuery,nCont+1,3))
	cQuery := SubStr(cQuery,nCont+4)
End

For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]

	cQuery := cSQL
	// Troca todas as filial
	aEval( axFilial, { |cValue| cQuery := StrTran(cQuery,"["+cValue+"]",&("xFilial('"+cValue+"')")) } )
	//
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSQL , .F., .T. )
	If !( cAliasSQL )->( Eof() )
		For nCont2 := 1 to Len(aAuxCPO)
			AADD(aRet, &(cAliasSQL+"->"+AllTrim(aAuxCPO[nCont2])))
		Next nCont2
		( cAliasSQL )->( dbCloseArea() )
		Exit
	EndIf
	( cAliasSQL )->( dbCloseArea() )
Next
cFilAnt := cBkpFilAnt
RestArea( aArea )
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_CNPJLB   บAutor  ณ Luis Delorme   บ Data ณ  24/01/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica CNPJs de clientes de Gestใo de Concessionaria     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina / Veํculos / Autope็as                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_CNPJLB()
Local cVldCNPJ := Left(SM0->M0_CGC,8)
Local lRet := .f.
Do Case
	Case cVldCNPJ == '26429167'                                        // TERRA UTIL COMERCIO DE FERRAMENTAS E UTILIDADES LTDA
		lRet := .t.
	Case cVldCNPJ == '07144507'                                        // MAQUINAS TERRA PRODUTOS METALURGICOS LTDA
		lRet := .t.
	Case cVldCNPJ $ '16823130/07773452/07791111/13126043/05916486/'    // MAQNELSON
		lRet := .t.
	Case cVldCNPJ $ '67041111/52656352/71220016/10593676/11089483/'    // MAZA
		lRet := .t.
	Case cVldCNPJ == '45109691'                                        // FURLAN
		lRet := .t.
EndCase
return lRet

/*/{Protheus.doc} FMX_OFIPASS
Funcao para calculo de passagens da oficina.

@author Rubens
@since 04/02/2015
@version 1.0
@param dDtInicio, data, Data Inicial
@param dDtFim, data, Data Final
@return aRetorno, Quantidade de Passagens do Periodo Informado - Col 1 = Filial / Col 2 = Quantidade de Passagens

/*/
Function FMX_OFIPASS( dDtInicio, dDtFim , lAllFil )

Local oFilHelp := Mil_FilialHelper():New()
Local aSM0 := oFilHelp:GetAllFilEmpresa(lAllFil)
Local cBkpCFilAnt := cFilAnt
Local nCont
Local aRetorno := {}
Local cSQL
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	cSQL := "SELECT COUNT(*) FROM ("
	cSQL += "SELECT VO1_FILIAL, VO1_CHASSI, VO1_DATABE"
	cSQL +=  " FROM " + RetSQLName("VO1") + " VO1"
	cSQL += " WHERE VO1.VO1_FILIAL = '" + xFilial("VO1") + "'"
	cSQL +=   " AND VO1.VO1_DATABE BETWEEN '" + DtoS(dDtInicio) + "' AND '" + DtoS(dDtFim) + "'"
	cSQL +=   " AND VO1.VO1_STATUS NOT IN ('C')"
	cSQL +=   " AND VO1.D_E_L_E_T_ = ' '"
	cSQL += ") TEMP"
	AADD(aRetorno, { cFilAnt , FM_SQL(cSQL) } )
Next nCont
cFilAnt := cBkpCFilAnt
Return aRetorno

/*/{Protheus.doc} FMX_CHKLOJA
Verifica se o DMS pode integrar com o Loja/Venda Direta.

@author Rubens
@since 13/02/2015
@version 1.0
@return lOk, Retorna se ้ possํvel integrar com o Loja/Venda Direta

/*/
Function FMX_CHKLOJA()

Local lOk := .t.
Local aCpoIntLoja := { "LQ_VEICTIP","LQ_VEIPESQ","L1_VEICTIP","L1_VEIPESQ" }
Local nCont
Local cErros := ""

If VOO->(FieldPos("VOO_TIPOCL")) <> 0
	AADD( aCpoIntLoja , "LQ_TIPOCLI" )
	AADD( aCpoIntLoja , "L1_TIPOCLI" )
EndIf

SX3->(dbSetOrder(2))
For nCont := 1 to Len(aCpoIntLoja)
	If !SX3->(dbSeek(aCpoIntLoja[nCont]))
		cErros += STR0031 + ": " + aCpoIntLoja[nCont] + CRLF // "Campo nใo encontrado"
	Else
		If !X3Uso(SX3->X3_USADO)
			cErros += STR0032 + ": " + aCpoIntLoja[nCont] + CRLF // "Campo marcado como nใo usado"
		EndIf
	EndIf
Next nCont

If !Empty(cErros)
	cErros := STR0034 + CRLF + CRLF + cErros // "Nใo ้ possํvel continuar. Verifique o(s) abaixo(s):"
	Aviso( STR0008 , cErros  , { STR0033 } , 3 )
	lOk := .f.
EndIf
Return lOk


/*/{Protheus.doc} FMX_FEXPGA

Funcao responsavel por retornar o conteudo da formula que deverแ ser executada para exporta็ใo dos dados de garantia da Oficina

@author Rubens
@since 30/03/2015
@version 1.0

@param cQdoExp, character, Configuracao de quando a exportacao de garantia deve ser executada
@param cTipTem, character, Tipo de Tempo
@param cCodMar, character, Codigo da Marca

@return cFunExp, Formula que serแ utilizada para exportar informacao de garantia

/*/
Function FMX_FEXPGA(cQdoExp,cTipTem,cCodMar)

Local cFunExp := ""
Local cQdoImp := ""
Local cSQL := ""
Local cAliasEXP := "TXEP"
Local aAliasAtu

Default cQdoExp := ""

// Verifica se foi configurado no tipo de tempo o controle de exportacao de garantia ...
If (VOI->(FieldPos("VOI_QDOIMP")) <> 0)
	aAliasAtu := GetArea()
	cSQL := "SELECT VOI.VOI_QDOIMP , VEG.VEG_FORMUL "
	cSQL +=  " FROM " + RetSQLName("VOI") + " VOI "
	cSQL +=         " LEFT JOIN " + RetSQLName("VEG") + " VEG ON VEG_FILIAL = '" + xFilial("VEG") + "' AND VEG_CODIGO = VOI_FOREXP AND VEG.D_E_L_E_T_ = ' '"
	cSQL += " WHERE VOI.VOI_FILIAL = '" + xFilial("VOI") + "' "
	cSQL +=   " AND VOI.VOI_TIPTEM = '" + cTipTem + "'"
	cSQL +=   " AND VOI.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasEXP , .F., .T. )
	If !(cAliasEXP)->(Eof()) .and. (cAliasEXP)->VOI_QDOIMP <> "0"
		cQdoImp := (cAliasEXP)->VOI_QDOIMP
		If Empty( cQdoExp ) .or. cQdoExp == cQdoImp
			cFunExp := AllTrim((cAliasEXP)->VEG_FORMUL)
		EndIf
	End
	(cAliasEXP)->(dbCloseArea())
	RestArea(aAliasAtu)
EndIf

// Verifica se gera garantia pelo parametro da marca
If Empty(cFunExp) .and. cQdoImp <> "0"
	cSQL := "SELECT VEG_FORMUL "
	cSQL +=  " FROM " + RetSQLName("VE4") + " VE4 "
	cSQL +=         " LEFT JOIN " + RetSQLName("VEG") + " VEG ON VEG_FILIAL = '" + xFilial("VEG") + "' AND VEG_CODIGO = VE4_FOREXP AND VEG.D_E_L_E_T_ = ' '"
	cSQL += " WHERE VE4.VE4_FILIAL = '" + xFilial("VE4") + "' "
	cSQL +=   " AND VE4.VE4_PREFAB IN " + FormatIN(cCodMar, "/")
	cSQL +=   IIf( !Empty( cQdoExp ) , " AND VE4.VE4_QDOIMP IN ('" + cQdoExp + "','3')" , " AND VE4.VE4_QDOIMP <> '0' " )
	cSQL +=   " AND VE4.VE4_FOREXP <> ' '"
	cSQL +=   " AND VE4.D_E_L_E_T_ = ' '"
	cFunExp := AllTrim(FM_SQL(cSQL))
EndIf
//

Return cFunExp

/*/{Protheus.doc} FMX_TTVLDCLIENTE

Funcao responsavel por garantir que um tipo de tempo possui somente um cliente em todas as suas requisi็๕es

@author Rubens
@since 14/04/2015
@version 1.0
@param cNumOsv, character, Numero da Ordem de Servi็o
@param cTipTem, character, Tipo de Tempo
@param cCliente, character, Cliente
@param cLoja, character, Loja
@return lRet, logico , Retorna se ้ possํvel utilizar o cliente/loja passado como parametro no tipo de tempo

/*/
Function FMX_TTVLDCLIENTE( cNumOsv, cTipTem , cCliente , cLoja )

Local cSQL
Local lRet := .t.
Local cAliasVLD := "TVLD"
Local aArea := GetArea()

cSQL := "SELECT VO3_FATPAR FATPAR, VO3_LOJA LOJA"
cSQL += " FROM " + RetSQLName("VO3") + " VO3 "
cSQL += " WHERE VO3.VO3_FILIAL = '" + xFilial("VO3") + "'"
cSQL +=   " AND VO3.VO3_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VO3.VO3_TIPTEM = '" + cTipTem + "'"
cSQL +=   " AND (VO3.VO3_DATDIS <> '  ' OR VO3.VO3_DATFEC <> '  ')"
cSQL +=   " AND VO3.D_E_L_E_T_ = ' '"
cSQL += " UNION "
cSQL += "SELECT VO4_FATPAR, VO4_LOJA"
cSQL += " FROM " + RetSQLName("VO4") + " VO4 "
cSQL += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
cSQL +=   " AND VO4.VO4_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VO4.VO4_TIPTEM = '" + cTipTem + "'"
cSQL +=   " AND (VO4.VO4_DATDIS <> '  ' OR VO4.VO4_DATFEC <> '  ')"
cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVLD , .F., .T. )
While !(cAliasVLD)->(Eof())
	If (cAliasVLD)->FATPAR <> cCliente .or. (cAliasVLD)->LOJA <> cLoja
		Help("  ",1,"MILOXFUNA01")
		lRet := .f.
		Exit
	EndIf
	(cAliasVLD)->(dbSkip())
End
(cAliasVLD)->(dbCloseArea())
RestArea( aArea )

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_F3INCORC บAutor  ณRenato Vinicius บ Data ณ  06/07/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta F3 Incoveniente Orcamento(VSLVF0)                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cGruInc -> Grupo de Incoveniente                           บฑฑ
ฑฑบ          ณ VV1 posicionado                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_F3INCORC()

Local lRet := .f.
Local cQuery := ""
Local aArea := GetArea()
Private aVetVSL := {}

VSL->(DbSetOrder(2))

cQuery := "SELECT CASE WHEN VSL.VSL_CODINC IS NULL THEN VF1.VF1_CODINC ELSE VSL.VSL_CODINC END VSL_CODINC "
cQuery += "FROM "+RetSqlName("VSL")+" VSL, "+RetSqlName("VV2")+" VV2, "+RetSqlName("VF0")+" VF0, "+RetSqlName("VF1")+" VF1 "
cQuery += "WHERE VSL.VSL_FILIAL = '"+xFilial("VSL")+"' AND VSL.VSL_CODGRU = '"+cGruInc+"' AND "
cQuery += "( VSL.VSL_TIPO = '1' OR  "
cQuery += "  ( VSL.VSL_TIPO <> '1' AND "
cQuery += "    ( VV2.VV2_FILIAL = '"+xFilial("VV2")+"' AND VV2.VV2_MODVEI = '"+VV1->VV1_MODVEI+"' AND "
cQuery += "      ( VV2.VV2_PLAREV = ' ' OR "
cQuery += "        ( "
cQuery += "          ( ( VF0.VF0_FILIAL = '"+xFilial("VF0")+"' AND VV2.VV2_CODMAR = VF0.VF0_CODMAR AND VF0.VF0_CODPLA = VV2.VV2_PLAREV AND "
cQuery += "              ( VF0.VF0_MODVEI =' ' OR VV2.VV2_MODVEI = VF0.VF0_MODVEI ) AND VF1.VF1_FILIAL = '"+xFilial("VF1")+"' AND "
cQuery += "              VF1.VF1_CODPLA = VF0.VF0_CODPLA AND VF1.VF1_CODMAR = VF0.VF0_CODMAR AND VF1.VF1_CODGRU = VSL.VSL_CODGRU AND VF1.D_E_L_E_T_ = ' '"
cQuery += "             ) "
cQuery += "           ) "
cQuery += "         ) "
cQuery += "       ) "
cQuery += "     ) "
cQuery += "   ) "
cQuery += ") AND VSL.D_E_L_E_T_ = ' ' AND VV2.D_E_L_E_T_ = ' ' AND VF0.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY CASE WHEN VSL.VSL_CODINC IS NULL THEN VF1.VF1_CODINC ELSE VSL.VSL_CODINC END"

TcQuery cQuery New Alias "TMPVSL"

While !(TMPVSL->(Eof()))
	VSL->(DbSeek(xFilial("VSL")+TMPVSL->VSL_CODINC))
	aAdd(aVetVSL,{TMPVSL->VSL_CODINC,VSL->VSL_DESINC,VSL->(RecNo())})
	TMPVSL->(DbSkip())
EndDo

TMPVSL->(DbCloseArea())
RestArea( aArea )

If Len(aVetVSL) == 0
	aadd(aVetVSL,{"","",0})
Endif

nOpca := 1
DEFINE MSDIALOG oDlgConInc TITLE STR0035 FROM  9,20 TO 34,84 OF oMainWnd

@ 22,.1 LISTBOX oLbConInc FIELDS HEADER   OemToAnsi(STR0036),;
OemToAnsi(STR0037),;
COLSIZES 60,80;
SIZE 254,151 OF oDlgConInc PIXEL ON DBLCLICK ( FS_SELINC(), nOpca := 1, oDlgConInc:End() )

oLbConInc:SetArray(aVetVSL)
oLbConInc:bLine := { || {aVetVSL[oLbConInc:nAt,01],;
aVetVSL[oLbConInc:nAt,02]}}

ACTIVATE MSDIALOG oDlgConInc CENTER ON INIT EnchoiceBar(oDlgConInc, { || FS_SELINC(), nOpca := 1, oDlgConInc:End() } , { || nOpca := 2, oDlgConInc:End() } )

lRet := .t.

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SELINC บAutor  ณRenato Vinicius     บ Data ณ  07/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para posicionar na VSL de acordo com o item          บฑฑ
ฑฑบ          ณselecionado na pesquisa VSLVF0                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Estatica da Funcao FMX_F3INCORC                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_SELINC()

If aVetVSL[oLbConInc:nAt,03] > 0  // Posicao do Vetor com RECNO da VSL
	VSL->(DbGoTo(aVetVSL[oLbConInc:nAt,03]))
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_CancPed  บAutor  ณ Vinicius Gati  บ Data ณ  11/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cancela pedido caso tenha permissใo para o mesmo.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCodPed -> Pedido que serแ cancelado                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_CancBOPed( cCodPed )
	Local oPedido := DMS_Pedido():New()

	DbSelectArea("VAI")
	DbSetOrder(4)
	DbSeek( xFilial("VAI") + __CUSERID )

	If FMX_TEMSUGC( cCodPed )
		If FieldPos('VAI_CANCBO') > 0 .AND. VAI->VAI_CANCBO == '1' // pode cancelar!
			if MsgYesNo( STR0039 + chr(13) + chr(10) + STR0040 /*"Or็amentos afetados:"*/ + FMX_ORCSAFET(cCodPed) /* "Tem certeza que deseja cancelar um item com pedido pendente? O pedido serแ perdido, esta a็ใo nใo poderแ ser desfeita." */ , STR0008 /* "Aten็ใo" */)
				return oPedido:DelBoPed( xFilial('SC7'), cCodPed )
			Else
				return .F.
			EndIf
		Else
			MsgAlert(STR0038 /*"Seu usuแrio nใo possui permissใo para cancelar um pedido com sugestใo."*/, STR0008 /*"Aten็ใo"*/)
		EndIf
	EndIf
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_ICancBo  บAutor  ณ Vinicius Gati  บ Data ณ  20/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cancela pedido caso tenha permissใo para o mesmo.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCodPed -> Pedido que serแ cancelado                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_ICancBo(cCodPed, cProPed, cItePed)

	Local oPedido := DMS_Pedido():New()

	DbSelectArea("VAI")
	DbSetOrder(4)
	DbSeek( xFilial("VAI") + __CUSERID )

	If FMX_ITEMSUGC( cCodPed, cProPed )
		If FieldPos('VAI_CANCBO') > 0 .AND. VAI->VAI_CANCBO == '1' // pode cancelar! averiguar antes de realmente fazer
			if MsgYesNo( STR0039 + chr(13) + chr(10) + STR0040 /*"Or็amentos afetados:"*/ + FMX_ORCSAFET(cCodPed) /* "Tem certeza que deseja cancelar um item com pedido pendente? O pedido serแ perdido, esta a็ใo nใo poderแ ser desfeita." */ , STR0008 /* "Aten็ใo" */)
				return oPedido:DelBoPed(xFilial('SC7'), cCodPed, cProPed, cItePed )
			Else
				return .F.
			EndIf
		Else
			MsgAlert(STR0038 /*"Seu usuแrio nใo possui permissใo para cancelar um pedido com sugestใo."*/, STR0008 /*"Aten็ใo"*/)
			Return .F.
		Endif
	EndIf
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_TEMSUGC  บAutor  ณ Vinicius Gati  บ Data ณ  11/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o pedido nao tem orcamento aguardando          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCodPed -> Pedido que serแ cancelado                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_TEMSUGC( cCodPed ) // tem sugestao compra nesse pedido?
	Local cQuery := ""
	Local oPedido := DMS_Pedido():New()
	cQuery += " SELECT COALESCE(count(*), 0) QTD_REGS FROM " + RetSQLName("SFJ")
	cQuery += " WHERE FJ_FILIAL = '" + xFilial('SFJ') + "' AND FJ_SOLICIT = '" + cCodPed + "' AND D_E_L_E_T_ = ' ' AND FJ_FORPED = '"+oPedido:GtTpPedBO()+"' "
Return FM_SQL(cQuery) > 0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_ITEMSUGC บAutor  ณ Vinicius Gati  บ Data ณ  11/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o pedido nao tem orcamento aguardando          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCodPed -> Pedido que serแ cancelado                       บฑฑ
ฑฑบParametrosณ cProdut -> B1_COD do produto que serแ averiguado           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_ITEMSUGC( cCodPed, cProdut ) // tem sugestao compra nesse pedido nesse item+sequen(iteped)?
	Local cQuery := ""
	Local oSqlHlp := DMS_SqlHelper():New()
	Local oPedido := DMS_Pedido():New()
	// verifica se existe VE6 esperando itens deste pedido, se tiver nใo pode deletar a menos que tenha permissใo para tal
	cQuery += "    SELECT COALESCE( count(*), 0 ) QTD "
	cQuery += "      FROM "+oSqlHlp:NoLock('SFJ')+" "
	cQuery += "      JOIN "+oSqlHlp:NoLock('SDF')+" ON SDF.DF_FILIAL  = '"+xFilial('SDF')+"' AND SDF.DF_CODIGO  = FJ_CODIGO  AND SDF.D_E_L_E_T_ = '' "
	cQuery += "      JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL  = '"+xFilial('SB1')+"' AND SB1.B1_COD     = DF_PRODUTO AND SB1.D_E_L_E_T_ = '' "
	cQuery += " LEFT JOIN "+oSqlHlp:NoLock('SC7')+" ON SC7.C7_FILIAL  = '"+xFilial('SC7')+"' AND SC7.C7_NUM     = FJ_SOLICIT AND SC7.C7_PRODUTO = SDF.DF_PRODUTO AND SC7.D_E_L_E_T_ = '' "
	cQuery += " LEFT JOIN "+oSqlHlp:NoLock('VE6')+" ON VE6.VE6_FILIAL = '"+xFilial('VE6')+"' AND VE6.VE6_SUGCOM = FJ_CODIGO  AND VE6.VE6_GRUITE = SB1.B1_GRUPO   AND VE6.VE6_CODITE = SB1.B1_CODITE AND VE6.D_E_L_E_T_ = '' "
	cQuery += "     WHERE SFJ.FJ_FILIAL =  '"+xFilial('SFJ')+"' AND SFJ.D_E_L_E_T_ = '' " // AND FJ_TIPGER = '2' AND -- verificar com rubens
	cQuery += "       AND C7_NUM = '"+cCodPed+"' AND C7_PRODUTO = '"+SB1->B1_COD+"' AND FJ_FORPED = '"+oPedido:GtTpPedBO()+"' "
	//
Return FM_SQL( cQuery ) > 0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_ORCSAFET บAutor  ณ Vinicius Gati  บ Data ณ  03/12/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna em string os pedidos que poderใo ser afetados pela  ฑฑ
ฑฑ             exclusใo das sugest๕es do pedido                            ฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCodPed -> Pedido que serแ cancelado                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_ORCSAFET(cCodPed)
	Local cNumOrcs := ""
	
	Local cQuery := ""
	Local oSqlHlp := DMS_SqlHelper():New()
	cQuery += "    SELECT VE6_NUMORC "
	cQuery += "      FROM "+oSqlHlp:NoLock('SFJ')+" "
	cQuery += "      JOIN "+oSqlHlp:NoLock('SDF')+" ON SDF.DF_FILIAL  = '"+xFilial('SDF')+"' AND SDF.DF_CODIGO  = FJ_CODIGO  AND SDF.D_E_L_E_T_ = '' "
	cQuery += "      JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL  = '"+xFilial('SB1')+"' AND SB1.B1_COD     = DF_PRODUTO AND SB1.D_E_L_E_T_ = '' "
	cQuery += " LEFT JOIN "+oSqlHlp:NoLock('SC7')+" ON SC7.C7_FILIAL  = '"+xFilial('SC7')+"' AND SC7.C7_NUM     = FJ_SOLICIT AND SC7.C7_PRODUTO = SDF.DF_PRODUTO AND SC7.D_E_L_E_T_ = '' "
	cQuery += " LEFT JOIN "+oSqlHlp:NoLock('VE6')+" ON VE6.VE6_FILIAL = '"+xFilial('VE6')+"' AND VE6.VE6_SUGCOM = FJ_CODIGO  AND VE6.VE6_GRUITE = SB1.B1_GRUPO   AND VE6.VE6_CODITE = SB1.B1_CODITE AND VE6.D_E_L_E_T_ = '' "
	cQuery += "     WHERE SFJ.FJ_FILIAL =  '"+xFilial('SFJ')+"' AND SFJ.D_E_L_E_T_ = '' " // AND FJ_TIPGER = '2' AND -- verificar com rubens
	cQuery += "       AND C7_NUM = '"+cCodPed+"'  "
	cQuery += " GROUP BY VE6_NUMORC "
	aObjs := oSqlHlp:GetSelect({;
		{'campos', {'VE6_NUMORC'}},;
		{'query' , cQuery        } ;
	})
	aEval( aObjs, {|oObj| cNumOrcs += oObj:GetValue('VE6_NUMORC')} )
Return cNumOrcs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_DELPED  บAutor  ณ Vinicius Gati  บ Data ณ  11/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o pedido nao tem orcamento aguardando          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcTipDel-> P-Cancela Pedido Total / L-Cancela Item do Pedido บฑฑ
ฑฑบ          ณcNumPed-> Numero do Pedido                                  บฑฑ
ฑฑบ          ณcProPed-> Produto                                           บฑฑ
ฑฑบ          ณcItePed-> Item do Pedido                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_DELPED( cTipPed, cNumPed, cProPed, cItePed )

If cTipPed == "P" // Calcela Pedido Total
	return FMX_CancBOPed(cNumPed)
Else //If cTipPed == "L" // Item do Pedido
	return FMX_ICancBo(cNumPed, cProPed, cItePed)
Endif

Return(.t.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_AJSX1   บAutor  ณ Rubens Takahashi บ Data ณ  25/02/16  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria pergunte no dicionแrio de Dados                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_AJSX1(cPergParam, aPergs)

Local aCposSX1
Local n
Local aArea

Private cKeyHelp := ""
Private cPerg    := ""

Default cPergParam := ""

If cRpoVersion == NIL
	cRpoVersion := GetRpoRelease()
EndIf

cFunc := "EngSX1" + SubStr( cRpoVersion,4,1 ) + SubStr( cRpoVersion,7,2 )
If cFunc > "EngSX1117" // as fun็๕es ENGSX s๓ sใo validas at้ a release 12.1.17
	return
Endif

aCposSX1 := {}
n        := 0
aArea    := GetArea()

cPerg := cPergParam

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
			"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
			"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
			"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
			"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
			"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
			"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
			"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP", "X1_PICTURE"}

SX1->(dbSetOrder(1))

cPerg := PadR( cPerg , Len(SX1->X1_GRUPO) , " " )

aTstPergs := aClone(aPergs)
nX := 0

For n:=1 to Len(aTstPergs)
	nX := n

	If ValType(aTstPergs[nx][Len(aTstPergs[nx])]) = "A"
		aHelpSpa := aTstPergs[nx][Len(aTstPergs[nx])]
	Else
		aHelpSpa := {}
	Endif

	If ValType(aTstPergs[nx][Len(aTstPergs[nx])-1]) = "A"
		aHelpEng := aTstPergs[nx][Len(aTstPergs[nx])-1]
	Else
		aHelpEng := {}
	Endif

	If ValType(aTstPergs[nx][Len(aTstPergs[nx])-2]) = "A"
		aHelpPor := aTstPergs[nx][Len(aTstPergs[nx])-2]
	Else
		aHelpPor := {}
	Endif

	cFunc := "EngSX1" + SubStr( GetRpoRelease(),4,1 ) + SubStr( GetRpoRelease(),7,2 )

	&(cFunc + "('" + cPerg + "'," + ; //cGrupo
				"Right( Alltrim( aTstPergs[nX][11] ) , 2)," + ;//cOrdem
				"aTstPergs[nx][01]," + ; //cPergunt
				"aTstPergs[nx][02]," + ; //cPerSpa
				"aTstPergs[nx][03]," + ; //cPerEng
				"aTstPergs[nx][04]," + ; //cVar
				"aTstPergs[nx][05]," + ; //cTipo
				"aTstPergs[nx][06]," + ; //nTamanho
				"aTstPergs[nx][07]," + ; //nDecimal
				"aTstPergs[nx][08]," + ; //nPresel
				"aTstPergs[nx][09]," + ; //cGSC
				"aTstPergs[nx][10]," + ; //cValid
				"aTstPergs[nx][36]," + ; //cF3
				"aTstPergs[nx][37]," + ; //cGrpSxg
				"aTstPergs[nx][38]," + ; //cPyme
				"aTstPergs[nx][11]," + ; //cVar01
				"aTstPergs[nx][12]," + ; //cDef01
				"aTstPergs[nx][13]," + ; //cDefSpa1
				"aTstPergs[nx][14]," + ; //cDefEng1
				"aTstPergs[nx][15]," + ; //cCnt01
				"aTstPergs[nx][17]," + ; //cDef02
				"aTstPergs[nx][18]," + ; //cDefSpa2
				"aTstPergs[nx][19]," + ; //cDefEng2
				"aTstPergs[nx][22]," + ; //cDef03
				"aTstPergs[nx][23]," + ; //cDefSpa3
				"aTstPergs[nx][24]," + ; //cDefEng3
				"aTstPergs[nx][27]," + ; //cDef04
				"aTstPergs[nx][28]," + ; //cDefSpa4
				"aTstPergs[nx][29]," + ; //cDefEng4
				"aTstPergs[nx][32]," + ; //cDef05
				"aTstPergs[nx][33]," + ; //cDefSpa5
				"aTstPergs[nx][34]," + ; //cDefEng5
				"aHelpPor," + ; //aHelpPor
				"aHelpEng," + ; //aHelpEng
				"aHelpSpa)") //aHelpSpa

		cKeyHelp := "P."+AllTrim(cPerg)+AllTrim(Right( Alltrim( aTstPergs[nX][11] ) , 2))+"."
		// Caso exista um help com o mesmo nome, atualiza o registro.
		cFunc := "EngHLP" + SubStr( GetRpoRelease(),4,1 ) + SubStr( GetRpoRelease(),7,2 )
		&(cFunc+"( cKeyHelp,aHelpPor,aHelpEng,aHelpSpa )")
Next
RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FMX_TESTIP   บAutor  ณ Thiago			  บ Data ณ  28/03/16   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna se a TES ้ de Entrada ou Saida.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MIL				                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FMX_TESTIP(cTES)
Local cEntSai   := ""

cQuery := "SELECT SF4.F4_TIPO "
cQuery += "FROM "
cQuery += RetSqlName( "SF4" ) + " SF4 "
cQuery += "WHERE "
cQuery += "SF4.F4_FILIAL='"+ xFilial("SF4")+ "' AND SF4.F4_CODIGO = '"+cTES+"' AND "
cQuery += "SF4.D_E_L_E_T_=' '"

cEntSai := FM_SQL(cQuery)

Return(cEntSai)

/*/{Protheus.doc} FMX_TPTIT

Fun็ใo utilizada para retornar os tipos dos titulos que serใo analisados no momento da exclusใo da Nota Fiscal

@author Rubens
@since 07/12/2016
@param cTipoParc, characters, Tipo de Parcela (E1_TIPO) parametro deve ser passado por referencia
@param cPrefixoTit, characters, Prefixo do titulo, sera utilizado no select da SE1
@param cNumTit, characters, Numero do titulo, sera utilizado no select da SE1
@param cClieFor, characters, Cliente, sera utilizado no select da SE1
@param cLoja, characters, Loja, sera utilizado no select da SE1
@type function
/*/
Function FMX_TPTIT( cTipoParc , cPrefixoTit , cNumTit , cClieFor , cLoja )
	Local cSQL
	Local oSqlHlp := DMS_SqlHelper():New()
	Local oArrayHlp := DMS_ArrayHelper():New()
	Local aTipTit
	If !FWIsInCallStack("VEIXI001")	// NAO eh Cancelamento do Atendimento de Veiculo Modelo 2
		cSQL := "SELECT DISTINCT E1_TIPO " + ;
			" FROM " + RetSQLName("SE1") + " E1 " + ;
			" WHERE E1.E1_FILIAL = '" + xFilial("SE1") + "' " + ;
			" AND E1.E1_PREFIXO = '" + cPrefixoTit + "' " + ;
			" AND E1.E1_NUM = '" + cNumTit + "' " + ;
			" AND E1.E1_CLIENTE = '" + cClieFor + "' " + ;
			" AND E1.E1_LOJA = '" + cLoja + "' " + ;
			" AND E1.E1_TIPO NOT IN " + FormatIN(MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVPIABT,"|") + ;
			" AND E1.D_E_L_E_T_ = ' '"
		aTipTit := oSqlHlp:GetSelectArray(cSQL)
		If Len(aTipTit) > 0
			cTipoParc += "|" + oArrayHlp:Join(aTipTit,"|")
		EndIf
	EndIf
Return cTipoParc


/*/{Protheus.doc} OFIXFUNA01_SelecaoFiliais

Fun็ใo para selecionar filiais/empresas a qual o usแrio tem permissใo

@author Vinicius Gati
@since 19/04/2017
@type function

/*/
Function OFIXFUNA01_SelecaoFiliais(aEmpr)
	Local oIHelp    := DMS_InterfaceHelper():New()
	Local oFilHlp   := DMS_FilialHelper():New()
	Local oArrHlp   := DMS_ArrayHelper():New()
	Local aSizeAut  := MsAdvSize(.T.)
	Local lCancel   := .F.
	Local nCont     := 1
	Local aSelecao  := {}
	Local aVetEmp   := {}
	Local cBkpFil   := cFilAnt
	Local oSizePri  := Nil
	
	Private o1ListB := Nil
	Private oOk     := LoadBitmap( GetResources(), "LBOK" )
	Private oNo     := LoadBitmap( GetResources(), "LBNO" )
	Default aEmpr   := {}

	aAuxFil := oFilHlp:GetAllFilPermis(.F.)
	if EMPTY(aAuxFil)
		return aEmpr
	end
	For nCont := 1 to Len( aAuxFil )
		cFilAnt      := aAuxFil[nCont]
		aFWArrFilAtu := FWArrFilAtu()
		ni := aScan(aEmpr,{|x| x == cFilAnt })
		aAdd(aVetEmp, { ni > 0, aFWArrFilAtu[SM0_EMPRESA], aFWArrFilAtu[SM0_UNIDNEG], aFWArrFilAtu[SM0_FILIAL], FWFilialName(), aAuxFil[nCont] })
	Next
	cFilAnt := cBkpFil
	oIHelp:nOpc := 2

	aDivTela := { ;
		{ "TOP"    , aSizeAut[5]*0.5, ((aSizeAut[5]*0.5)-020) , .T. , .T. } ,; // Cabecalho
		{ "BOTTOM" , aSizeAut[5]*0.5,                    020  , .T. , .F. }  ; // Listbox
	}

	oSizePri := oIHelp:CreateDefSize(.f., aDivTela,,0, 0.5)
	oSizePri:Process()
	oIHelp:SetDefSize(oSizePri)
	oDlg := oIHelp:CreateDialog(STR0041) // "Consulta de importa็๕es JDPRISM"
	oIHelp:SetDialog(oDlg)


	oIHelp:Clean()
	oIHelp:SetDefSize(oSizePri, "TOP")
	oIHelp:addColLBox({;
		{'CABEC' ,    ''},;
		{'IMAGEM'  , .T.},;
		{'SELECAO' , .T.},;
		{'TAMANHO' ,  15} ;
	})
	oIHelp:addColLBox({;
		{'CABEC'  , STR0042},;
		{'TAMANHO',   30},;
		{'PICTURE', "@!"} ;
	})
	oIHelp:addColLBox({;
		{'CABEC'  , STR0043},;
		{'TAMANHO',   30},;
		{'PICTURE', "@!"} ;
	})
	oIHelp:addColLBox({;
		{'CABEC'  , STR0044},;
		{'TAMANHO',   30},;
		{'PICTURE', "@!"} ;
	})
	oIHelp:addColLBox({;
		{'CABEC'  , STR0045},;
		{'TAMANHO',     30},;
		{'PICTURE',   "@!"} ;
	})

	o1ListB := oIHelp:CreateLBox("o1ListB")
	o1ListB:bChange := { ||  }
	o1ListB:SetArray( aVetEmp )
	o1ListB:Refresh()

	oIHelp:Clean()
	oIHelp:SetDefSize(oSizePri, "BOTTOM")

	oBtnOk := TButton():New(;
		oSizePri:GetDimension("BOTTOM","LININI"), ;
		oSizePri:GetDimension("BOTTOM","COLINI"), ;
		STR0046, ;
		oDlg , { || aSelecao := o1ListB:aArray, oDlg:End() }, ;
		30 ;
		, 010,,,.F.,.T.,.F.,,.F.,,,.F. )

	oBtnCancel := TButton():New(;
		oSizePri:GetDimension("BOTTOM","LININI"), ;
		oSizePri:GetDimension("BOTTOM","COLINI")+32, ;
		STR0047, ;
		oDlg , { || lCancel := .T., oDlg:End() }, ;
		30 ;
		, 010,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTER

	if lCancel
		return aEmpr
	end

	aSelecao := oArrHlp:Select(aSelecao, {|aDados| aDados[1] })

Return oArrHlp:Map(aSelecao, {|aDados| aDados[6] })

Function FMX_INPUTBOX(pcTitulo,pcInitPad)

Local aParParambox := {}
Local aRetParamBox := {}

AADD( aParParamBox , { 1 , pcTitulo, pcInitPad, "", "", "", "", 40, .t. })
While .t.
	If ParamBox(aParParamBox,"Input Box",@aRetParamBox,,,,,,,, .f., .f.)
		Exit
	End
End
Return aRetParamBox[1]


/*/{Protheus.doc} FMX_CDELF2
Funcao chamada pela MaCanDelF2 para verificar se uma determinada nota fiscal de saida podera ser excluida.
Se a nota nao puder ser excluida, serแ exibido a mensagem de Help "NAOEXCNFS"

@author Rubens
@since 13/10/2017
@version 1.0

@return logical, Indica se a NF podera ser excluida
@param cAlias, characters, Alias do Cursor com os dados ta SF2
@param cMensagem, characters, Variavel que recebera o conteudo a ser exibido quando a nota nao for excluida
@param lJob, logical, Indica se a funcao esta sendo chamada atraves do JOB FatJobNFE

@type function

/*/
Function FMX_CDELF2(cAlias, cMensagem, lJob)

	Local lRetorno := .t.
	Local cMVPREFVEI
	Local cMVPREFBAL
	Local cMVPREFOFI
	Local cMVMIL0160

	If (cAlias)->(ColumnPos("F2_PREFORI")) == 0
		Return .t.
	EndIf

	// Se vier de JOB nao pode validar, pois o cancelamento esta agendado no TSS e o TSS pode aprovar.
	// Quando nao era verificado se estแ em JOB, o Protheus excluia SF2 e mantia os registros da SD2
	If lJob
		Return .t.
	EndIf
	//

	cMVPREFVEI := Alltrim(GetNewPar("MV_PREFVEI","VEI")) // Prefixo NF/Titulos de Venda de Veiculos
	cMVPREFBAL := Alltrim(GetNewPar("MV_PREFBAL","BAL")) // Prefixo NF/Titulos de Venda de Balcao de Pecas
	cMVPREFOFI := Alltrim(GetNewPar("MV_PREFOFI","OFI")) // Prefixo NF/Titulos de Venda de Oficina
	cMVMIL0160 := Alltrim(GetNewPar("MV_MIL0160","DMS")) // Prefixo NF/Titulos de Venda de Servi็os Diversos ( Comissใo Consorcio/Seguros/Srv.Diversos/... )

	cDMSPrefOri := cMVPREFVEI + "/" + cMVPREFBAL + "/" + cMVPREFOFI + "/" + cMVMIL0160
	If Alltrim( (cAlias)->F2_PREFORI) $ cDMSPrefOri .and. !(FM_PILHA("OFI") .or. FM_PILHA("VEI"))

		cMensagem := " " + STR0048 + " " // Nใo ้ possํvel excluir esse documento pelo fato da sua origem ter ocorrido no M๓dulo de Concessionแrias. Seu Cancelamento s๓ serแ possํvel no m๓dulo

		Do Case
		Case Alltrim( (cAlias)->F2_PREFORI) == cMVPREFVEI ; cMensagem += " SIGAVEI."
		Case Alltrim( (cAlias)->F2_PREFORI) == cMVPREFBAL ; cMensagem += " SIGAPEC."
		Case Alltrim( (cAlias)->F2_PREFORI) == cMVPREFOFI ; cMensagem += " SIGAOFI."
		Case Alltrim( (cAlias)->F2_PREFORI) == cMVMIL0160 ; cMensagem += " SIGAVEI/SIGAPEC/SIGAOFI."
		End Case

		lRetorno := .F.

	Endif

Return lRetorno

/*/{Protheus.doc} FMX_VALFIN

Fun็ใo para retornar o Vlr.Financeiro (Contas a Receber) desconsiderando titulos de Abatimento

@author Andre Luis Almeida
@since 19/10/2017
@type function
@param cPrefixo, characters, Prefixo do Titulo
@param cDupl, characters, Numero do Titulo
@param cCliente, characters, Codigo do Cliente
@param cLoja, characters, Loja do Cliente

/*/
Function FMX_VALFIN( cPrefixo , cDupl , cCliente , cLoja )
Local cSQL := 	"SELECT SUM(E1_VALOR) " + ;
				" FROM " + RetSQLName("SE1") + " " + ;
				" WHERE E1_FILIAL = '"   + xFilial("SE1") + "' " + ;
				"   AND E1_PREFIXO = '"  + cPrefixo       + "' " + ;
				"   AND E1_NUM = '"      + cDupl          + "' " + ;
				"   AND E1_CLIENTE = '"  + cCliente       + "' " + ;
				"   AND E1_LOJA = '"     + cLoja          + "' " + ;
				"   AND E1_TIPO NOT IN " + FormatIN(MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVPIABT,"|") + ;
				"   AND D_E_L_E_T_ = ' '"
Return FM_SQL(cSQL)


/*/{Protheus.doc} FMX_FILSXB

Fun็ใo para retornar filtro dentro do Banco de Dados utilizando o Registro 6 da SXB

@author Manoel Filho
@since 01/02/2018
@type function
@param cCodSXB, characters, C๓digo da Consulta na SXB

/*/
Function FMX_FILSXB( cCodSXB )
Local cFiltro := ""
Local cGruVei := ""
//
Do Case
Case cCodSXB == "BM2"
	cFiltro := "@BM_CODMAR IN (" + FS_MARCAS() + ") AND BM_TIPGRU NOT IN ('4 ','7 ') "
Case cCodSXB == "B12"
	If ReadVar() == "M->VE9_ITEANT"
		cFiltro := "@B1_GRUPO = '" + M->VE9_GRUITE + "' "
	ElseIf ReadVar() == "M->VE9_ITENOV"
		cFiltro := "@B1_GRUPO = '" + M->VE9_GRUNOV + "' "
	EndIf
Case cCodSXB == "V61"
	cFiltro := "@(VO6_CODMAR = '"+VE1->VE1_CODMAR+"' OR VO6_CODMAR = ' ') AND VO6_GRUSER = '"+M->VS4_GRUSER+"'"
Case cCodSXB == "B00"
	cFiltro := "@B1_GRUPO = '"+RetGrupo()+"'"
Case cCodSXB == "B01"
	cGruVei := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
	If !Empty(M->VO3_GRUITE)
		cFiltro := "@B1_GRUPO = '"+M->VO3_GRUITE+"'"
		If M->VO3_GRUITE == cGruVei // se o Grupo digitado for o mesmo do Grupo de Veiculos ( NAO TRAZER NADA )
			cFiltro += " AND B1_GRUPO <> '"+cGruVei+"'" // Desconsiderar Veiculos
		EndIf
	Else
		cFiltro := "@B1_GRUPO <> '"+cGruVei+"'" // Desconsiderar Veiculos
	EndIf
Case cCodSXB == "B02"
	cFiltro := "@B1_GRUPO = '"+M->VO8_GRUITE+"'"
Case cCodSXB == "B03"
	cFiltro := "@B1_GRUPO = '"+M->VE6_GRUITE+"'"
Case cCodSXB == "B03A"
	cFiltro := "@B1_GRUPO = '"+M->VE6_GRUITE+"'"
Case cCodSXB == "B03B"
	cFiltro := "@B1_GRUPO = '"+M->VZZ_GRUITE+"'"
Case cCodSXB == "B04"
	cFiltro := "@B1_GRUPO = '"+M->VG5_GRUITE+"'"
Case cCodSXB == "B05"
	cFiltro := "@B1_GRUPO = '"+M->VG6_GRUITE+"'"
Case cCodSXB == "B06"
	cFiltro := "@B1_GRUPO = '"+M->VG8_GRUITE+"'"
Case cCodSXB == "B08KIT"
	cFiltro := "@B1_GRUPO = '"+M->VE8_GRUITE+"'"
Case cCodSXB == "B10"
	cFiltro := "@B1_GRUPO = '"+IIf(Type("M->VV6_GRUITE")!="U", M->VV6_GRUITE,M->VVW_GRUITE)+"'"
Case cCodSXB == "B11"
	cFiltro := "@B1_GRUPO = '"+IIf(Type("get_grupo")#"U",get_grupo,MV_PAR01)+"'"
Case cCodSXB == "B13"
	cFiltro := "@B1_GRUPO = '"+M->VF8_GRUITE+"'"
Case cCodSXB == "B14KIT"
	cFiltro := "@B1_GRUPO = '"+M->VEH_GRUKIT+"'"
Case cCodSXB == "B16"
	cFiltro := "@B1_GRUPO = '"+cGruIte+"'"
Case cCodSXB == "B17"
	cFiltro := "@B1_GRUPO = '"+M->VVT_GRUITE+"'"
Case cCodSXB == "B18"
	If !Empty(ACOLS[N,FG_POSVAR("VEN_GRUITE")])
		cFiltro := "@B1_GRUPO = '"+ACOLS[N,FG_POSVAR("VEN_GRUITE")]+"'"
	Endif
Case cCodSXB == "B19"
	cFiltro := "@B1_GRUPO = '"+M->VVM_GRUITE+"'"
Case cCodSXB == "B20"
	If Type("cGrupo")!="U"
		cFiltro := "@B1_GRUPO = '"+cGrupo+"'"
	Endif
Case cCodSXB == "B21"
	cFiltro := "@B1_GRUPO = '"+M->VAJ_GRUPEC+"'"
Case cCodSXB == "B22"
	cFiltro := "@B1_GRUPO = '"+M->VSS_GRUITE+"'"
Case cCodSXB == "B23"
	If Type("cGrupoA")!="U"
		cFiltro := "@B1_GRUPO = '"+cGrupoA+"'"
	Endif'
Case cCodSXB == "SB1V40"
	cFiltro := "@B1_GRUPO = '" + cGruIte + "'"
Case cCodSXB == "OX6"
	cFiltro := "@VO6_CODMAR = '"+M->VG8_CODMAR+"'"
Case cCodSXB == "OX7"
	cFiltro := "@VO6_CODMAR = '"+M->VZG_CODMAR+"'"
Case cCodSXB == "V6F"
	cFiltro := "@VF6_CODMAR = '"+M->VF6_CODMAR+"' AND VF6_MODVEI = '"+M->VF6_MODVEI+"'"
Case cCodSXB == "V6P"
	cFiltro := "@VO6_CODMAR = '"+M->VOC_CODMAR+"'"
Case cCodSXB == "V7P"
	cFiltro := "@VO7_CODMAR = '"+M->VO6_CODMAR+"' AND VO7_MODVEI = '"+M->VO6_MODVEI+"'"
Case cCodSXB == "VAD"
	If !Empty(M->VAJ_CODMAR)
		cFiltro := "@VO6_CODMAR = '"+M->VAJ_CODMAR+"' AND VO6_GRUSER = '"+ACOLS[N,FG_POSVAR("VAJ_GRUSER")]+"'"
	Else
		cFiltro := "@VO6_FILIAL = '"+xFilial("VO6")+"'"
	Endif
Case cCodSXB == "VAH"
	cFiltro := "@B1_GRUPO = '"+ACOLS[N,FG_POSVAR("VAJ_GRUPEC")]+"'"
Case cCodSXB == "VB1"
	cFiltro := "@B1_GRUPO = '"+M->VSD_GRUITE+"'"
Case cCodSXB == "VB3"
	cFiltro := "@B1_GRUPO = '"+M->VSS_GRUITE+"'"
Case cCodSXB == "VGS"
	cFiltro := "@VO6_CODMAR = '"+M->VGA_CODMAR+"'"
Case cCodSXB == "VO1VGA"
	cFiltro := "@VO1_CODMAR = '"+M->VGA_CODMAR+"'"
Case cCodSXB == "VO5"
	cFiltro := "@VO5_CHAINT = '"+M->VO5_CHAINT+"'"
Case cCodSXB == "VO6VZ7"
	cFiltro := "@VO6_CODMAR = '"+VE1->VE1_CODMAR+"' AND VO6_GRUSER = '"+M->VZ7_GRUSER+"'"
Case cCodSXB == "VO8"
	cFiltro := "@VO6_CODMAR = '"+M->VFA_CODMAR+"' AND VO6_GRUSER = '"+M->VFA_GRUSER+"'"
Case cCodSXB == "VZ6SB1"
	If Type("M->VZ6_GRUITE")=="C"
		cFiltro := "@B1_GRUPO = '"+M->VZ6_GRUITE+"'"
	Else
		cFiltro := "@B1_GRUPO = '"+M->VZ7_GRUITE+"'"
	Endif
Case cCodSXB == "VQT"
	If Type("cVDK_TIPFAS")!="U"
		If Empty(cVDK_TIPFAS) .or. cVDK_TIPFAS == "1"
			cFiltro := "@VQT_TIPETA IN (' ','1')"
		Else
			cFiltro := "@VQT_TIPETA = '"+cVDK_TIPFAS+"'"
		EndIf
	EndIf
Case cCodSXB == "VDKFAS"
	cFiltro := "@VDK_TIPFAS IN (' ','1')" // Veiculos/Maquinas
Case cCodSXB == "VDKFA2"
	cFiltro := "@VDK_TIPFAS = '2'" // Pe็as Balcใo
Case cCodSXB == "VDKFA3"
	cFiltro := "@VDK_TIPFAS = '3'" // Pe็as/Servi็os Oficina
Case cCodSXB == "VV2PRV"
	//
	If Type("_VV2CODMAR_Filtro") <> "U" .and. ! Empty(_VV2CODMAR_Filtro)
		cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_CODMAR = '" + _VV2CODMAR_Filtro + "'"
	EndIf
	If Type("_VV2GRUMOD_Filtro") <> "U" .and. ! Empty(_VV2GRUMOD_Filtro)
		cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_GRUMOD = '" + _VV2GRUMOD_Filtro + "'"
	EndIf
	If Type("_VV2MODVEI_Filtro") <> "U" .and. ! Empty(_VV2MODVEI_Filtro)
		cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_MODVEI = '" + _VV2MODVEI_Filtro + "'"
	EndIf

	If ! Empty(cFiltro)
		cFiltro := "@" + cFiltro
	EndIf
Case cCodSXB == "VV2MOD"
	//
	If Type("_VV2CODMAR_Filtro") <> "U" .and. ! Empty(_VV2CODMAR_Filtro)
		cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_CODMAR = '" + _VV2CODMAR_Filtro + "'"
	EndIf
	If Type("_VV2GRUMOD_Filtro") <> "U" .and. ! Empty(_VV2GRUMOD_Filtro)
		cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_GRUMOD = '" + _VV2GRUMOD_Filtro + "'"
	EndIf

	If ! Empty(cFiltro)
		cFiltro := "@" + cFiltro
	EndIf

EndCase

Return cFiltro

/*/{Protheus.doc} FS_MARCAS

Fun็ใo para retornar as Marcas utilizadas pelo Concessionแrio

@author Manoel Filho
@since 01/02/2018
@type function

/*/
Static Function FS_MARCAS()
Local cRet      := ""
Local cQuery    := ""
Local cAuxAlias := GetNextAlias()
//
cQuery := "SELECT VE1_CODMAR "
cQuery += " FROM " + RetSQLName("VE1")
cQuery += " WHERE VE1_FILIAL = '" + xFilial("VE1") + "'"
cQuery +=   " AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VE1_CODMAR"
//
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
//
While !(cAuxAlias)->(Eof())
	cRet+= "'" + (cAuxAlias)->(VE1_CODMAR) + "',"
	(cAuxAlias)->(DbSkip())
EndDo
(cAuxAlias)->(DbCloseArea())
//
cRet += "'   '"
//	
Return cRet

/*/{Protheus.doc} FMX_VLDSE4
Funcao que valida FAIXAS de VALOR SUPERIOR e INFERIOR possiveis na Condi็ใo de Pagamento (SE4)
@author Andre Luis Almeida
@since 20/04/2018
@param cCondSE4, characters, C๓digo da Condicao de Pagamento
@param nVlrTotParc, numeric, Valor Total (soma das Parcelas)
/*/
Function FMX_VLDSE4(cCondSE4,nVlrTotParc)
Local lRet          := .t.
Default cCondSE4    := "" // Se vier em branco, ้ pq ja esta posicionado no SE4!
Default nVlrTotParc := 0  // Se vier zerado, ้ pq o TES NAO gera duplicata
If !Empty(cCondSE4)
	SE4->(DbSetOrder(1))
	If !SE4->(MsSeek(xFilial("SE4")+cCondSE4))
		lRet := .f.
	EndIf
EndIf
If lRet .and. nVlrTotParc > 0
	Do Case
		Case nVlrTotParc > SE4->E4_SUPER .AND. SE4->E4_SUPER <> 0
			Help(" ","1","LJLIMSUPER")
			lRet := .F.
		Case nVlrTotParc < SE4->E4_INFER .AND. SE4->E4_INFER <> 0
			Help(" ","1","LJLIMINFER")
			lRet := .F.	
	EndCase
EndIf
Return lRet

/*/{Protheus.doc} FMX_MDIBar
Fun็ใo para retornar os dados corretamente na barra

@author Fernando Vitor Cavani
@since 16/10/2018
@type function
/*/	
Function FMX_MDIBar()
If !SetMDIChild(0)
	SetMDIBar(SPACE(2) + oApp:oMsgItem1:cMsg + Chr(9) + cUserName + Chr(9) + oApp:oMsgItem2:cMsg + Chr(9) + Capital(AllTrim(FWGrpName(cEmpAnt))) + " / " + Capital(AllTrim(FWFilialName(cEmpAnt, cFilAnt, 1))))
	oApp:SetStatusBarText(GetMDIBar())
Else
	__cMDIBar := " " + OemToAnsi(GetVersao()) + Chr(9) + cUserName + Chr(9) + Dtoc(dDataBase) + Chr(9) + Capital(AllTrim(FWGrpName(cEmpAnt))) + " / " + Capital(AllTrim(FWFilialName(cEmpAnt, cFilAnt, 1))) + chr(9) + "#fw_rodape_logo_siga"
	SetMDIBar(__cMDIBar)
	oApp:SetStatusBarText(__cMDIBar)
EndIf
Return .t.

/*/{Protheus.doc} FMX_OwnerFunc
Retorna nome da rotina para ser utilizada na funcao de declaracao de variavel private

@author Rubens
@since 10/05/2021
@version 1.0
@type function

/*/
Function FMX_OwnerFunc()
	Local cFunOrig := AllTrim(FunName())
	If FunType() == 3 .and. Left(cFunOrig,2) <> "U_"
		cFunOrig := "U_" + StrTran(cFunOrig,"#","")
	EndIf
Return cFunOrig

/*/{Protheus.doc} FMX_HELP

Exibe janela de HELP
@author Rubens
@since 06/12/2018
@version 1.0
@param cNomeHelp, characters, Nome do HELP
@param cTexto, characters, Erro
@param cSolucao, characters, Solucao
@type function
/*/
Function FMX_HELP(cNomeHelp, cTexto, cSolucao)
	Default cSolucao := ""

	Help(;
		NIL, NIL,; // cRotina , nLinha
		cNomeHelp,; // cCampo
		,; // cNome
		cTexto,; // cMensagem
		1,; // nLinha1
		0,; // nColuna
		NIL, NIL, NIL, NIL,; // lPop , hWnd , nHeight , nWidth  
		NIL,; // lGravaLog
		{ cSolucao } ) // aSoluc

Return

/*/
{Protheus.doc} FMX_SXBVV2
Funcao que realiza o tratamento de filtro de consultas padrao para retornar dados referente ao cadastro de modelos (tabela VV2).
@type   Function
@author Rubens Takahashi
@since  
@param  cCodSXB,	Caractere,  Codigo da consulta padrao.
@return cFiltro,    Caractere,  Filtro a ser considerado na consulta padrao.
/*/
Function FMX_SXBVV2( cCodSXB )
	Local cFiltro := ""
	Local cReadVar
	//
	Do Case
	Case cCodSXB == "VV2SE1"
		cReadVar := ReadVar()
		Do Case
		Case cReadVar == "M->VRK_MODVEI"
			If !Empty(FWFldGet("VRK_CODMAR"))
				cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_CODMAR = '" + FWFldGet("VRK_CODMAR") + "'"
			EndIf
			If !Empty(FWFldGet("VRK_GRUMOD"))
				cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_GRUMOD = '" + FWFldGet("VRK_GRUMOD") + "'"
			EndIf
		Case cReadVar == "M->VJK_MODVEI"
			If !Empty(FWFldGet("VJK_CODMAR"))
				cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_CODMAR = '" + FWFldGet("VJK_CODMAR") + "'"
			EndIf
		EndCase
	Case cCodSXB == "VV2SE2"
		cReadVar := ReadVar()
		Do Case
		Case cReadVar == "M->VRK_SEGMOD"
			If !Empty(FWFldGet("VRK_CODMAR"))
				cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_CODMAR = '" + FWFldGet("VRK_CODMAR") + "'"
			EndIf
			If !Empty(FWFldGet("VRK_MODVEI"))
				cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_MODVEI = '" + FWFldGet("VRK_MODVEI") + "'"
			EndIf
		Case cReadVar == "M->VJK_SEGMOD"
			If !Empty(FWFldGet("VJK_CODMAR"))
				cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_CODMAR = '" + FWFldGet("VJK_CODMAR") + "'"
			EndIf
		EndCase
	Case cCodSXB == "VV2VFG"
		cReadVar := ReadVar()
		Do Case
		Case cReadVar == "M->VRK_SEGMOD"
			If !Empty(FWFldGet("VRK_CODMAR"))
				cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_CODMAR = '" + FWFldGet("VRK_CODMAR") + "'"
			EndIf
			If !Empty(FWFldGet("VRK_MODVEI"))
				cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_MODVEI = '" + FWFldGet("VRK_MODVEI") + "'"
			EndIf
		Case cReadVar == "M->VJK_SEGMOD"
			If !Empty(FWFldGet("VJK_CODMAR"))
				cFiltro += IIf( !Empty(cFiltro) , " AND " , "" ) + "VV2_CODMAR = '" + FWFldGet("VJK_CODMAR") + "'"
			EndIf
		EndCase
	EndCase

	//Criar consulta padrใo para a VVRVFG no update e coloca-la no campo
	//Criar consulta padrใo para a VV2 no update
	//Criar a funcionalidade da consulta padrใo da VV2 aqui

	If !Empty(cFiltro)
		cFiltro := "@" + cFiltro
	EndIf

Return cFiltro



/*/{Protheus.doc} FMX_NCCCliente
Retorna o cliente que deverแ ser usado na gera็ใo da NCC referente a uma devolu็ใo de venda.
O cliente pode ser diferente do cliente da nota fiscal quando se trata de uma venda de veํculo utiliza็ใo um financiamento ou
faturamento de peca de ordem de servi็o de garantia.

@author rubens.takahashi
@since 28/07/2020
@version 1.0
@return .t.
@param cF1DOC, characters, Numero da nota fiscal de devolucao
@param cF1SERIE, characters, Serie da nota fiscal de devolucao
@param cF1FORNECE, characters, Fornecedor da devolucao
@param cF1LOJA, characters, Loja da devolucao
@param cE1Cliente, characters, Variavel passada por REFERENCIA que recebera o codigo do cliente a ser utilizado na NCC
@param cE1Loja, characters, Variavel passada por REFERENCIA que recebera o codigo da loja do cliente a ser utilizado na NCC
@param cE1NReduz, characters, Variavel passada por REFERENCIA que recebera o nome do cliente a ser utilizado na NCC
@type function
/*/
Function FMX_NCCCliente(cF1DOC, cF1SERIE, cF1FORNECE, cF1LOJA, cE1Cliente, cE1Loja, cE1NReduz)

	Local cAlOrig := ""
	Local lTipoA := .f.
	Local aAuxArea := GetArea()

	cAlOrig := "DMSNFORI"

	cQuery := "SELECT DISTINCT E4.E4_TIPO "
	cQuery +=  " FROM " + RetSQLName("SD1") + " D1"
	cQuery +=  " JOIN " + RetSQLName("SD2") + " D2 ON D2.D2_FILIAL = D1.D1_FILORI AND D2.D2_DOC = D1.D1_NFORI AND D2.D2_SERIE = D1.D1_SERIORI AND D2.D2_ITEM = D1.D1_ITEMORI AND D2.D_E_L_E_T_ = ' '"
	cQuery +=  " JOIN " + RetSQLName("SC5") + " C5 ON C5.C5_FILIAL = '" + xFilial("SC5") + "' AND C5.C5_NUM = D2.D2_PEDIDO AND C5.D_E_L_E_T_ = ' '"
	cQuery +=  " LEFT JOIN " + RetSQLName("SE4") + " E4 ON E4.E4_FILIAL = '  ' AND E4.E4_CODIGO = C5.C5_CONDPAG AND E4.D_E_L_E_T_ = ' '"
	cQuery += " WHERE D1.D1_FILIAL  = '" + xFilial("SD1") + "'"
	cQuery +=   " AND D1.D1_DOC     = '" + cF1DOC + "'"
	cQuery +=   " AND D1.D1_SERIE   = '" + cF1SERIE + "'"
	cQuery +=   " AND D1.D1_FORNECE = '" + cF1FORNECE + "'"
	cQuery +=   " AND D1.D1_LOJA    = '" + cF1LOJA + "'"
	cQuery +=   " AND D1.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlOrig , .F., .T. )
	If ! (cAlOrig)->(Eof())
		lTipoA := ((cAlOrig)->E4_TIPO == "A")
		(cAlOrig)->(dbSkip())
		If ! (cAlOrig)->(Eof())
			lTipoA := .f. // Nao processa troca do cliente se existir mais de um tipo de pagamento envolvido 
		EndIf
	EndIf
	(cAlOrig)->(dbCloseArea())

	If ! lTipoA
		RestArea( aAuxArea )
		Return .f.
	EndIf

	// Procura cliente da duplicata
	cQuery := "SELECT F2_PREFIXO,F2_DUPL, E1_CLIENTE, E1_LOJA, A1_NREDUZ"
	cQuery +=  " FROM " + RetSQLName("SD1") + " D1"
	cQuery +=  " JOIN " + RetSQLName("SF2") + " F2 ON F2.F2_FILIAL = D1.D1_FILORI AND F2.F2_DOC = D1.D1_NFORI AND F2.F2_SERIE = D1.D1_SERIORI AND F2.D_E_L_E_T_ = ' '"
	cQuery +=  " JOIN " + RetSQLName("SE1") + " E1 ON E1.E1_FILIAL = '" + xFilial("SE1") + "' AND E1.E1_PREFIXO = F2.F2_PREFIXO AND E1.E1_NUM = F2.F2_DUPL AND E1.D_E_L_E_T_ = ' '"
	cQuery +=  " JOIN " + RetSQLName("SA1") + " A1 ON A1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1.A1_COD = E1.E1_CLIENTE AND A1.A1_LOJA = E1.E1_LOJA AND A1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE D1.D1_FILIAL  = '" + xFilial("SD1") + "'"
	cQuery +=   " AND D1.D1_DOC     = '" + cF1DOC + "'"
	cQuery +=   " AND D1.D1_SERIE   = '" + cF1SERIE + "'"
	cQuery +=   " AND D1.D1_FORNECE = '" + cF1FORNECE + "'"
	cQuery +=   " AND D1.D1_LOJA    = '" + cF1LOJA + "'"
	cQuery +=   " AND D1.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY E1.E1_PREFIXO, E1.E1_NUM, E1.E1_PARCELA"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlOrig , .F., .T. )
	If ! (cAlOrig)->(Eof())
		cE1Cliente := (cAlOrig)->E1_CLIENTE
		cE1Loja    := (cAlOrig)->E1_LOJA
		cE1NReduz  := (cAlOrig)->A1_NREDUZ
	EndIf
	(cAlOrig)->(dbCloseArea())

	RestArea( aAuxArea )

Return .t.

/*/{Protheus.doc} OFXFA0016_VerificaMetodoEmClasse
Retornar se um determinado m้todo existe dentro da classe especificada

@author Fernando Vitor Cavani
@since 27/12/2018
@param oClasse , object    , Objeto (Classe)
@param cMetodo , characters, Nome do M้todo
@return boolean, .t.|.f.   , Se bloqueado ou nใo
@type function
/*/
Function OFXFA0016_VerificaMetodoEmClasse(oClasse, cMetodo)
Local nCont   := 0
Local aClasse := {}
Local lRet    := .F.

Default oClasse := ""
Default cMetodo := ""

If !Empty(oClasse) .And. !Empty(cMetodo)
	aClasse := ClassMethArr(oClasse)
	If !Empty(aClasse)
		For nCont := 1 to Len(aClasse)
			If Upper(aClasse[nCont,1]) == Upper(cMetodo)
				lRet := .t.
			EndIf
		Next
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OFXFA0024_FormatIN
	Valores strings para gerar o IN
	
	@type function
	@author Vinicius Gati
	@since 12/02/2020
/*/
function OFXFA0024_FormatIN(aValues, lIncAspas)
	local cIn := ""
	Default lIncAspas := .t.
	if lIncAspas
		aeval(aValues, {|cEl| cIn += "'" + cEl + "'," })
	else
		aeval(aValues, {|cEl| cIn += "" + cEl + "," })
	endif
return StrTran("(" + cIn + ")", ",)", ")")

/*/{Protheus.doc} OFXFA0034_AlgumaPecaSemSaldo
	Fun็ใo para padronizar mensagem de falta de saldo em or็amentos
	
	@type function
	@author Vinicius Gati
	@since 13/02/2020
/*/
function OFXFA0034_AlgumaPecaSemSaldo(aOrcs, lMostraTelaResumo)
	local oSqlHlp := DMS_SqlHelper():New()
	local nCntFor, cPecAnt, cPec, cMensagem, aFaltantes
	local cQuery := "  SELECT VS3.VS3_NUMORC, SB1.B1_COD, VS3.VS3_GRUITE, VS3.VS3_CODITE, VS3.VS3_QTDITE, SB2.B2_QATU "
	cQuery += "  FROM "+RetSqlName("VS3")+" VS3 "
	cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_GRUPO = VS3.VS3_GRUITE  AND SB1.B1_CODITE = VS3.VS3_CODITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '"+xFilial("SB2")+"' AND SB2.B2_COD   = SB1.B1_COD      AND SB2.B2_LOCAL  = VS3.VS3_LOCAL  AND SB2.D_E_L_E_T_ = ' '  "
	cQuery += " WHERE VS3.VS3_FILIAL = '"+xFilial("VS3")+"' "
	cQuery += "   AND VS3.VS3_NUMORC IN "+OFXFA0024_FormatIN(aOrcs)
	cQuery += "   AND SB1.B1_COD IN ( "
	cQuery += "        SELECT SB2_e.B2_COD "
	cQuery += "          FROM "+RetSqlName("VS3")+" VS3_e "
	cQuery += "          JOIN "+RetSqlName("SF4")+" SF4_e ON SF4_e.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4_e.F4_CODIGO = VS3_e.VS3_CODTES AND SF4_e.F4_ESTOQUE = 'S'              AND SF4_e.D_E_L_E_T_ = ' ' "
	cQuery += "          JOIN "+RetSqlName("SB1")+" SB1_e ON SB1_e.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1_e.B1_GRUPO  = VS3_e.VS3_GRUITE AND SB1_e.B1_CODITE  = VS3_e.VS3_CODITE AND SB1_e.D_E_L_E_T_ = ' ' "
	cQuery += "          JOIN "+RetSqlName("SB2")+" SB2_e ON SB2_e.B2_FILIAL = '"+xFilial("SB2")+"' AND SB2_e.B2_COD    = SB1_e.B1_COD     AND SB2_e.B2_LOCAL   = VS3_e.VS3_LOCAL  AND SB2_e.D_E_L_E_T_ = ' ' "
	cQuery += "         WHERE VS3_e.VS3_FILIAL   = '"+xFilial("VS3")+"' "
	cQuery += "           AND VS3_e.VS3_NUMORC  IN "+OFXFA0024_FormatIN(aOrcs)
	cQuery += "           AND VS3_e.VS3_CODITE   = VS3.VS3_CODITE "
	cQuery += "           AND VS3_e.VS3_GRUITE   = VS3.VS3_GRUITE "
	cQuery += "           AND VS3_e.D_E_L_E_T_ = ' ' "
	cQuery += "      GROUP BY SB2_e.B2_COD "
	cQuery += "        HAVING SUM(SB2_e.B2_QATU) < SUM(VS3_e.VS3_QTDITE) "
	cQuery += "   ) "
	cQuery += "   AND VS3.D_E_L_E_T_ = ' ' "
	cQuery += "   ORDER BY SB1.B1_CODITE, VS3.VS3_NUMORC "
	aFaltantes := oSqlHlp:GetSelectArray(cQuery, 6)

	if len(aFaltantes) > 0
		cPecAnt := aFaltantes[1]
		cMensagem := STR0049 + " '" + alltrim(cPecAnt[2]) + "' " + STR0050 + ": " + cValToChar(cPecAnt[6]) + PULALINHA // // produto XXXXX disponํvel 5

		For nCntFor := 1 to Len(aFaltantes)
			cPec := aFaltantes[nCntFor]

			if cPecAnt[2] != cPec[2]
				cMensagem += PULALINHA + PULALINHA
				cMensagem += STR0049 + " '" + alltrim(cPec[2]) + "' " + STR0050 + ": " + cValToChar(cPec[6]) + PULALINHA // produto XXXXX disponํvel 5
			endif
			cMensagem += "    " + STR0051 + " '" + alltrim(cPec[1]) + "' "+STR0052+": " + cValToChar(cPec[5]) + PULALINHA // or็amento 00000 quantidade 10

			cPecAnt := cPec
		Next
		if lMostraTelaResumo
			AVISO(STR0053, cMensagem, { STR0054 }, 3) // "Pe็as indisponํveis para atender o pedido"
		endif
		return .t.
	endif
return .f.
