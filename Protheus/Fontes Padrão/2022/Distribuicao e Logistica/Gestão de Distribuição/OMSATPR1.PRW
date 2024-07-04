#INCLUDE "PROTHEUS.CH"
#include "FWMVCDEF.CH"
#include "OMSATPR1.CH"

Static oBrowse 	 := Nil
Static oTTPed 	 := Nil
Static oTTVei 	 := Nil
Static cAliasPED := Nil
Static cAliasVEI := Nil
Static lMarkAll  := .F. 
Static oObjTTPed := Nil
Static oObjTTVei := Nil
Static cMarca 	 := GetMark()
Static oTTBKP 	 := Nil
Static cAliasBKP := Nil
Static oObjTTBKP := Nil
Static lAutomato := .F.
Static nTipoTela := 0
Static nQtdVei 	 := 0
Static nTotalKg  := 0
Static nTotalVol := 0
Static bKeyF5    := {|| RefreshBrw(.F.,@oBrowse)}
Static bKeyF6 	 := {|| Pergunte("OMSATPR1A",.T.,STR0058),Pergunte("OMSATPR1",.F.) }//"Parâmetros do planejamento" 
Static bKey12 	 := {|| RefreshBrw(.T.,@oBrowse)}
Static llogTPR   := .F.

/*/{Protheus.doc} OMSATPR1 
** Envio de pedidos para a Neolog
@author Equipe OMS
@since 25/08/2021
/*/
Function OMSATPR1(lAuto)
	
	Local aStrPedid 	:= {}
	Local aFilTT 		:= {}
	Local aColPedido 	:= {}
	Local aSeekPed 		:= {}
	Local aStrVeic 		:= {}
	Default lAuto := .F.

	llogTPR 			:= SuperGetMV("MV_TPRCLOG",.F.,.T.)
	SetKey( VK_F5, bKeyF5 )
	SetKey( VK_F6, bKeyF6 )
	SetKey( VK_F12, bKey12 )

	lAutomato := lAuto
	If !lAutomato
		Pergunte("OMSATPR1",.T.,STR0057)// "Filtro para pedidos"
		nTipoTela := MV_PAR14
	EndIf

	aStrPedid 	:= TTPedStrut()
	aFilTT 		:= TTPedFilt() 
	aColPedido 	:= TTPedCols(aStrPedid)
	aSeekPed 	:= TTPedSeek()
	aStrVeic 	:= TTVeiStrut()


	cAliasPED  := GetNextAlias()
	cAliasVEI  := GetNextAlias()
	FwMsgRun(,{|| GeraTTPed(aStrPedid, cAliasPED) }, STR0005, STR0004) //"Realizando a busca de pedidos Aguarde"
	FwMsgRun(,{|| GeraTTVei(aStrVeic, cAliasVEI) }, STR0006, STR0004)   //"Realizando a busca de veículos Aguarde"

	If !lAutomato
		oBrowse := FWMarkBrowse():New()
		oBrowse:SetDescription(STR0003) //Envio de Pedidos - Integração TOTVS Planejamento de Rotas (TPR)
		oBrowse:SetMenuDef("OMSATPR1")
		oBrowse:SetTemporary(.T.)
		oBrowse:SetAlias(cAliasPED)
		oBrowse:AddStatusColumns({||StatusInt((cAliasPED)->TMP_STINT)}, {||OMSTPRLeg("INTROT")})
		oBrowse:AddStatusColumns({||StatusPed((cAliasPED)->TMP_SITPED)}, {||OMSTPRLeg("SITPED")})
		oBrowse:SetFieldMark("TMP_MARK")
		oBrowse:SetMark(cMarca)
		oBrowse:SetAllMark({||AllMark(oBrowse)})
		oBrowse:SetColumns(aColPedido)
		oBrowse:SetOnlyFields({})
		oBrowse:oBrowse:SetFieldFilter( aFilTT )
		oBrowse:oBrowse:SetUseFilter()
		oBrowse:DisableDetails()
		oBrowse:SetSeek(/*bSeek*/,aSeekPed)

		// If nTipoTela == 1
		// 	oBrowse:oBrowse:DelColumn(5)
		// 	oBrowse:oBrowse:DelColumn(6)
		// 	oBrowse:oBrowse:DelColumn(11)
		// 	oBrowse:oBrowse:DelColumn(12)
		// EndIf
		oBrowse:Activate()
	EndIf
	DelTabTmp(cAliasVEI,oTTVei)
	DelTabTmp(cAliasPED,oTTPed)
	SetKey(VK_F5, Nil)
	SetKey(VK_F6, Nil)
	SetKey(VK_F12, Nil)
Return

/*/{Protheus.doc} MenuDef
** Opcoes da tela principal
@author Equipe OMS
@since 25/08/2021
/*/
Static Function MenuDef()
	Private aRotina := {}
	Add OPTION aRotina TITLE STR0001 ACTION "OMSEnvTPR()"  OPERATION 3 ACCESS 0  //"Enviar"
	Add OPTION aRotina TITLE STR0002 ACTION "OMSVeiTPR()"  OPERATION 4 ACCESS 0  //"Veículos"
	Add OPTION aRotina TITLE STR0056 ACTION "OMSCanTPR()"  OPERATION 5 ACCESS 0  //"Excluir rejeições/falhas marcadas"
	Add OPTION aRotina TITLE STR0058 ACTION "OMSPer1TPR()" OPERATION 4 ACCESS 0  //"Parâmetros do planejamento"
	Add OPTION aRotina TITLE STR0057 ACTION "OMSPer2TPR()" OPERATION 4 ACCESS 0  //"Filtro para pedidos
	Add OPTION aRotina TITLE STR0059 ACTION "OMSVisTPR()"  OPERATION 2 ACCESS 0  //"Integrações do Item" 
Return aRotina


/*/{Protheus.doc} OMSPer1TPR
** Pergunte do filtro
@author Equipe OMS
@since 20/09/2021
/*/
Function OMSPer1TPR()
	Pergunte('OMSATPR1A',.T.,STR0058) //"Parâmetros do planejamento"
Return


/*/{Protheus.doc} OMSPer2TPR
** Pergunte dos parametros
@author Equipe OMS
@since 20/09/2021
/*/
Function OMSPer2TPR()
	Pergunte('OMSATPR1',.T.,STR0057)
Return


/*/{Protheus.doc} OMSVisTPR
** Busca DMR e DMS do pedido ou item pedido.
Caso tenha mais de um, apresenta tela para selecao
@author Equipe OMS
@since 19/09/2021
/*/
Function OMSVisTPR()
	Local aArea  := GetArea()
	Local lRet := .T.
	Local cQuery := ""
	Local cAliasQry := ""
	Local aPedDMR    := {}
	Local nRecDMR := 0

	If (cAliasPED)->TMP_STINT = '0'
		MsgAlert(STR0060) //"O pedido não foi enviado para integração."
		lRet := .F.
	EndIf

	If lRet
		If nTipoTela == 1
			cQuery := "Select DISTINCT DMR_FILIAL,DMR_FILROT,DMR_IDROT,DMR.R_E_C_N_O_ RECNODMR FROM  " + RetSqlName("DMR") + " DMR"
			cQuery += 	" INNER JOIN " + RetSqlName("DMS") + " DMS ON(DMS.DMS_FILIAL  = DMR.DMR_FILIAL "
			cQuery += 	" AND DMS.DMS_FILROT  = DMR.DMR_FILROT"
			cQuery += 	" AND DMS.DMS_IDROT  = DMR.DMR_IDROT"
			cQuery += 	" AND DMS.D_E_L_E_T_ = ' ')"
			cQuery += 	" WHERE"
			cQuery += 	" DMR.D_E_L_E_T_ = ' '"
			cQuery += 	" AND DMR.DMR_FILIAL = '"+FwXFilial("DMR")+"'"
			cQuery += 	" AND (DMS.DMS_STATUS = '"+(cAliasPED)->TMP_STINT+"'"
			cQuery += 	" OR DMS.DMS_STATUS = '3')"

			cQuery += 	" AND SUBSTRING(DMS.DMS_CHVENT,1,"+cValtoChar(TamSX3('C9_FILIAL')[1]+TamSX3('C9_PEDIDO')[1])+") = '"+(cAliasPED)->TMP_FILIAL+(cAliasPED)->TMP_PEDIDO+"'"

			cQuery += 	" ORDER BY DMR.DMR_IDROT"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
			(cAliasQry)->( dbGoTop() )
			If !(cAliasQry)->( Eof() )
				While !(cAliasQry)->( Eof() )
					Aadd(aPedDMR, {(cAliasQry)->DMR_FILROT,(cAliasQry)->DMR_IDROT, (cAliasQry)->RECNODMR})
				(cAliasQry)->( dbSkip() )
				EndDo
				If Len(aPedDMR) > 1
					lRet := OMSTPRSel(aPedDMR, @nRecDMR)
				Else
					lRet := .T.
					nRecDMR := IIF(!Empty(aPedDMR[1]),aPedDMR[1][3],0)
				EndIf
			Else
				MsgAlert(STR0060) //"O pedido não foi enviado para integração."
			EndIf
			If lRet .And. nRecDMR != 0
				DMR->(DbGoTo(nRecDMR))
				//FwExecView(,"TMSAC19",MODEL_OPERATION_VIEW ,,{||.T.})
				TMSAC19( "DMR_FILIAL == '"+ DMR->DMR_FILIAL + "' .AND. DMR_FILROT == '"+DMR->DMR_FILROT + "' .AND. DMR_IDROT == '"+DMR->DMR_IDROT + "'")
			EndIf
			(cAliasQry)->(DbCloseArea())
		Else
			lRet := .F.
			DMS->(DbSetOrder(2))
			If DMS->(DbSeeK(FwxFilial("DMS")+'SC9'+(cAliasPED)->TMP_FILIAL+(cAliasPED)->TMP_PEDIDO+(cAliasPED)->TMP_ITEM+(cAliasPED)->TMP_SEQUEN+(cAliasPED)->TMP_CODPRO))
				DMS->(DbSetOrder(1))
				If DMR->(DbSeeK(DMS->DMS_FILIAL + DMS->DMS_FILROT + DMS->DMS_IDROT))
					lRet := .T.
					//FwExecView(,"TMSAC19",MODEL_OPERATION_VIEW ,,{||.T.})
					TMSAC19( "DMR_FILIAL == '"+ DMR->DMR_FILIAL + "' .AND. DMR_FILROT == '"+DMR->DMR_FILROT + "' .AND. DMR_IDROT == '"+DMR->DMR_IDROT + "'")
				EndIf
			EndIf
			If !lRet
				MsgAlert(STR0061)//"O item de pedido não foi enviado para integração."
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
	SetKey( VK_F5, bKeyF5 )
	SetKey( VK_F6, bKeyF6 )
	SetKey( VK_F12, bKey12 )
Return


/*/{Protheus.doc} OMSTPRSel
** Apresenta tela para selecao de integracao ja realizada
@author Equipe OMS
@since 19/09/2021
/*/
Static Function OMSTPRSel(aPedDMR, nRecDMR)
	Local oDlg
	Local oListDMR
	Local oPanel
	Local lRet := .T.

	DEFINE MSDIALOG oDlg FROM 0, 0 TO 150,300 PIXEL TITLE OemToAnsi(STR0066) //"Integrações do pedido"
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,370,80,.T., .T. )
		oPanel:Align := CONTROL_ALIGN_BOTTOM
		oPanel:nHeight := 30
		oListDMR := TCBrowse():New(0,0,10,10,,,,oDlg,,,,, {||  nRecDMR := aPedDMR[oListDMR:nAt,3], oDlg:End() },,,,,,,,,.T.,,,,.T.,)
		oListDMR:AddColumn(TCColumn():New(STR0062,{||aPedDMR[oListDMR:nAt,1]},,,,,070,.F.,.F.,,,,,))//"Filial Planejamento"
		oListDMR:AddColumn(TCColumn():New(STR0063,    {||aPedDMR[oListDMR:nAt,2]},,,,,070,.F.,.F.,,,,,))//"Id Planejamento"
		oListDMR:SetArray( aPedDMR)
		oListDMR:Align := CONTROL_ALIGN_ALLCLIENT
		TButton():New( 62, 75, STR0064, oDlg,{|| nRecDMR := 0,oDlg:End() },30,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"
		TButton():New( 62, 110,STR0065, oDlg,{|| nRecDMR := aPedDMR[oListDMR:nAt,3], oDlg:End() },30,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Confirmar"
	ACTIVATE MSDIALOG oDlg CENTERED

	If nRecDMR = 0
		lRet := .F.
	EndIf

Return lRet


/*/{Protheus.doc} TTPedStrut
** Campos da Tabela Temporaria
@author Equipe OMS
@since 25/08/2021
/*/
Static Function TTPedStrut()
	Local aC9TT := {}

	aAdd(aC9TT,{ "TMP_MARK" , "C", 2, 0, , }) //Selecao
	aAdd(aC9TT,{ "TMP_STINT" , "C", 1, 0, STR0007, "@!"}) //Status Integ
	aAdd(aC9TT,{ "TMP_SITPED" , "C", 1, 0, STR0008, "99999"}) //Status Pedid
	aAdd(aC9TT,{ "TMP_TIPO",  TamSX3("C5_TIPO")[3],  TamSX3("C5_TIPO")[1],  TamSX3("C5_TIPO")[2], OMSTITULO("C5_TIPO"),  PesqPict("SC5", "C5_TIPO")})
	aAdd(aC9TT,{ "TMP_FILIAL",TamSX3("C9_FILIAL")[3],TamSX3("C9_FILIAL")[1],TamSX3("C9_FILIAL")[2],OMSTITULO("C9_FILIAL"),PesqPict("SC9", "C9_FILIAL")})
	aAdd(aC9TT,{ "TMP_PEDIDO",TamSX3("C9_PEDIDO")[3],TamSX3("C9_PEDIDO")[1],TamSX3("C9_PEDIDO")[2],OMSTITULO("C9_PEDIDO"),PesqPict("SC9", "C9_PEDIDO") })
	aAdd(aC9TT,{ "TMP_ITEM" , TamSX3("C9_ITEM")[3],  TamSX3("C9_ITEM")[1],  TamSX3("C9_ITEM")[2] , STR0009 ,			  PesqPict("SC9", "C9_ITEM") })//"Item Pedido"
	aAdd(aC9TT,{ "TMP_SEQUEN",TamSX3("C9_SEQUEN")[3],TamSX3("C9_SEQUEN")[1],TamSX3("C9_SEQUEN")[2],STR0010,				  PesqPict("SC9", "C9_SEQUEN") })//"Seq.Lib.Ped."
	aAdd(aC9TT,{ "TMP_QTDLIB",TamSX3("C9_QTDLIB")[3],TamSX3("C9_QTDLIB")[1],TamSX3("C9_QTDLIB")[2],STR0011,               PesqPict("SC9", "C9_QTDLIB")})//"Qtd.Liberada"
	aAdd(aC9TT,{ "TMP_PSLIQ", TamSX3("B1_PESO")[3],  TamSX3("B1_PESO")[1],  TamSX3("B1_PESO")[2],  STR0012 ,           	  PesqPict("SB1", "B1_PESO")})// "Peso Liq"
	aAdd(aC9TT,{ "TMP_PESOBR",TamSX3("B1_PESO")[3],  TamSX3("B1_PESO")[1],  TamSX3("B1_PESO")[2],  STR0013 ,              PesqPict("SB1", "B1_PESO")})//"Peso Bruto"
	aAdd(aC9TT,{ "TMP_VOL",   TamSX3("B5_COMPRLC")[3],  TamSX3("B5_COMPRLC")[1],  TamSX3("B5_COMPRLC")[2],  STR0014 ,     PesqPict("SB5", "B5_COMPRLC")})//'Vol. Total'
	aAdd(aC9TT,{ "TMP_CODPRO",TamSX3("B1_COD")[3],   TamSX3("B1_COD")[1],   TamSX3("B1_COD")[2],   STR0015 ,              PesqPict("SB1", "B1_COD")})//'Produto'
	aAdd(aC9TT,{ "TMP_DESPRO",TamSX3("B1_DESC")[3],  TamSX3("B1_DESC")[1],  TamSX3("B1_DESC")[2],  STR0016 ,              PesqPict("SB1", "B1_DESC")})//'Desc. Prod.'
	aAdd(aC9TT,{ "TMP_FILFCL",TamSX3("A1_FILIAL")[3],TamSX3("A1_FILIAL")[1],TamSX3("A1_FILIAL")[2],STR0017 ,              PesqPict("SA1", "A1_FILIAL")})//"Fil Forn/Cli"
	aAdd(aC9TT,{ "TMP_CODFCL",TamSX3("A1_COD")[3],   TamSX3("A1_COD")[1],   TamSX3("A1_COD")[2],   STR0018 ,              PesqPict("SB1", "A1_COD")})//"Cod Forn/Cli"
	aAdd(aC9TT,{ "TMP_LOJFCL",TamSX3("A1_LOJA")[3],  TamSX3("A1_LOJA")[1],  TamSX3("A1_LOJA")[2],  STR0019 ,              PesqPict("SB1", "A1_LOJA")})//"LJ Forn/Cli"
	aAdd(aC9TT,{ "TMP_NOMFAN",TamSX3("A1_NOME")[3],  TamSX3("A1_NOME")[1],  TamSX3("A1_NOME")[2],  STR0020 ,              PesqPict("SB1", "A1_NOME")})//"Nm. Fantasia"
	aAdd(aC9TT,{ "TMP_CGCCLI",TamSX3("A1_CGC")[3],   TamSX3("A1_CGC")[1],   TamSX3("A1_CGC")[2],   OMSTITULO("A1_CGC") ,  PesqPict("SA1", "A1_CGC")})
	aAdd(aC9TT,{ "TMP_CEP",   TamSX3("A1_CEP")[3],   TamSX3("A1_CEP")[1],   TamSX3("A1_CEP")[2],   OMSTITULO("A1_CEP") ,  PesqPict("SA1", "A1_CEP")})
	aAdd(aC9TT,{ "TMP_END",   TamSX3("A1_END")[3],   TamSX3("A1_END")[1],   TamSX3("A1_END")[2],   OMSTITULO("A1_END") ,  PesqPict("SA1", "A1_END")})
	aAdd(aC9TT,{ "TMP_BAIRRO",TamSX3("A1_BAIRRO")[3],TamSX3("A1_BAIRRO")[1],TamSX3("A1_BAIRRO")[2],OMSTITULO("A1_BAIRRO"),PesqPict("SA1", "A1_BAIRRO")})
	aAdd(aC9TT,{ "TMP_MUN",   TamSX3("A1_MUN")[3],   TamSX3("A1_MUN")[1],   TamSX3("A1_MUN")[2],   OMSTITULO("A1_MUN") ,  PesqPict("SA1", "A1_MUN")})
	aAdd(aC9TT,{ "TMP_EST",   TamSX3("A1_EST")[3],   TamSX3("A1_EST")[1],   TamSX3("A1_EST")[2],   OMSTITULO("A1_EST") ,  PesqPict("SA1", "A1_EST")})
	aAdd(aC9TT,{ "TMP_PAIS",  TamSX3("YA_DESCR")[3], TamSX3("YA_DESCR")[1], TamSX3("YA_DESCR")[2], STR0021 , 			  PesqPict("SYA", "YA_DESCR")})//"País"
	aAdd(aC9TT,{ "TMP_REDESP",TamSX3("A4_COD")[3],   TamSX3("A4_COD")[1],   TamSX3("A4_COD")[2],   STR0022 ,              PesqPict("SA4", "A4_COD")})//'Redesp'
	aAdd(aC9TT,{ "TMP_NMRED", TamSX3("A4_NOME")[3],  TamSX3("A4_NOME")[1],  TamSX3("A4_NOME")[2],  STR0023 ,              PesqPict("SA4", "A4_NOME")})//'Nome Redes'
	aAdd(aC9TT,{ "TMP_EMISSA",TamSX3("C5_EMISSAO")[3],TamSX3("C5_EMISSAO")[1],TamSX3("C5_EMISSAO")[2],OMSTITULO("C5_EMISSAO"),PesqPict("SC5", "C5_EMISSAO")})
	aAdd(aC9TT,{ "TMP_ENTIDA",TamSX3("DAR_ENTIDA")[3],TamSX3("DAR_ENTIDA")[1],TamSX3("DAR_ENTIDA")[2],OMSTITULO("DAR_ENTIDA"),PesqPict("DAR", "DAR_ENTIDA")})
	aAdd(aC9TT,{ "TMP_LATITU",TamSX3("DAR_LATITU")[3],TamSX3("DAR_LATITU")[1],TamSX3("DAR_LATITU")[2],OMSTITULO("DAR_LATITU"),PesqPict("DAR", "DAR_LATITU")})
	aAdd(aC9TT,{ "TMP_LONGIT",TamSX3("DAR_LONGIT")[3],TamSX3("DAR_LONGIT")[1],TamSX3("DAR_LONGIT")[2],OMSTITULO("DAR_LONGIT"),PesqPict("DAR", "DAR_LONGIT")})

Return aC9TT


Static function TTPedSeek()
    Local nTam 			:= 0
	Local aSeek := {}
    //Monta "chave" do pesquisar
	nTam := TamSX3("C9_FILIAL")[1] + TamSX3("C9_PEDIDO")[1] + TamSX3("C9_ITEM")[1] + TamSX3("C9_SEQUEN")[1]
	Aadd(aSeek,{"Filial+Pedido+Item+Sequen" ,{{"", 'C' , nTam, 0 , "@!" }}, 1, .T. } ) //Filial+Pedido+Item

Return aSeek

/*/{Protheus.doc} TTPedFilt
** Campos da Opcao Filtrar do Browse
@author Equipe OMS
@since 25/08/2021
/*/
Static Function TTPedFilt()
	Local aFldFil := {}

	aAdd(aFldFil, {"TMP_FILIAL", OMSTITULO("C9_FILIAL") ,TamSX3("C9_FILIAL")[3], TamSX3("C9_FILIAL")[1], TamSX3("C9_FILIAL")[2], PesqPict("SC9", "C9_FILIAL")} )
	aAdd(aFldFil, {"TMP_PEDIDO", OMSTITULO("C9_PEDIDO") ,TamSX3("C9_PEDIDO")[3], TamSX3("C9_PEDIDO")[1], TamSX3("C9_PEDIDO")[2], PesqPict("SC9", "C9_PEDIDO")} )
	aAdd(aFldFil, {"TMP_ITEM",  OMSTITULO("C9_ITEM")  ,TamSX3("C9_ITEM")[3],  TamSX3("C9_ITEM")[1],  TamSX3("C9_ITEM")[2] , PesqPict("SC9", "C9_ITEM") } )
	aAdd(aFldFil, {"TMP_SEQUEN", OMSTITULO("C9_SEQUEN") ,TamSX3("C9_SEQUEN")[3], TamSX3("C9_SEQUEN")[1], TamSX3("C9_SEQUEN")[2], PesqPict("SC9", "C9_SEQUEN")} )
	aAdd(aFldFil, {"TMP_CODPRO", STR0015 ,TamSX3("B1_COD")[3], TamSX3("B1_COD")[1], TamSX3("B1_COD")[2], PesqPict("SB1", "B1_COD")} )
	aAdd(aFldFil, {"TMP_DESPRO", STR0016 ,TamSX3("B1_DESC")[3], TamSX3("B1_DESC")[1], TamSX3("B1_DESC")[2], PesqPict("SB1", "B1_DESC")} )
	aAdd(aFldFil, {"TMP_CODFCL", STR0018 ,TamSX3("A1_COD")[3], TamSX3("A1_COD")[1], TamSX3("A1_COD")[2], PesqPict("SA1", "A1_COD")} )
	aAdd(aFldFil, {"TMP_LOJFCL", STR0019 ,TamSX3("A1_LOJA")[3], TamSX3("A1_LOJA")[1], TamSX3("A1_LOJA")[2], PesqPict("SA1", "A1_LOJA")} )
	aAdd(aFldFil, {"TMP_NOMFAN", STR0020 ,TamSX3("A1_NOME")[3], TamSX3("A1_NOME")[1], TamSX3("A1_NOME")[2], PesqPict("SA1", "A1_NOME")} )
	aAdd(aFldFil, {"TMP_CGCCLI", OMSTITULO("A1_CGC") ,TamSX3("A1_CGC")[3], TamSX3("A1_CGC")[1], TamSX3("A1_CGC")[2], PesqPict("SA1", "A1_CGC")} )
	aAdd(aFldFil, {"TMP_BAIRRO", OMSTITULO("A1_BAIRRO") ,TamSX3("A1_BAIRRO")[3], TamSX3("A1_BAIRRO")[1], TamSX3("A1_BAIRRO")[2], PesqPict("SA1", "A1_BAIRRO")} )
	aAdd(aFldFil, {"TMP_MUN",    OMSTITULO("A1_MUN") ,TamSX3("A1_MUN")[3], TamSX3("A1_MUN")[1], TamSX3("A1_MUN")[2], PesqPict("SA1", "A1_MUN")} )
	aAdd(aFldFil, {"TMP_EST",    OMSTITULO("A1_EST") ,TamSX3("A1_EST")[3], TamSX3("A1_EST")[1], TamSX3("A1_EST")[2], PesqPict("SA1", "A1_EST")} )
	aAdd(aFldFil, {"TMP_EMISSA", OMSTITULO("C5_EMISSAO") ,TamSX3("C5_EMISSAO")[3], TamSX3("C5_EMISSAO")[1], TamSX3("C5_EMISSAO")[2], PesqPict("SC5", "C5_EMISSAO")} )

Return aFldFil


/*/{Protheus.doc} AllMark
** Repassa marcacao para a temporaria
@author Equipe OMS
@since 25/08/2021
/*/
Static Function AllMark(oBrowse)
Local aAreaTmp  := (cAliasPED)->(GetArea())
Local cAliasBrw := ""
Local cMark     := ""

	lMarkAll := !lMarkAll
	cMark    := Iif(lMarkAll,oBrowse:Mark(),Space(2))
	// Busca alias do próprio browse, que neste caso é cAliasPED
	cAliasBrw := oBrowse:Alias()
	// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
	// a regra de marcação será executada apenas para os registros que o usuário vê em tela
	(cAliasBrw)->(DbGoTop())
	While (cAliasBrw)->(!Eof())
		Reclock(cAliasPED,.F.)
		(cAliasPED)->TMP_MARK := cMark
		(cAliasPED)->(MsUnlock())
		(cAliasBrw)->(DbSkip())
	EndDo

RestArea(aAreaTmp)
oBrowse:Refresh()
Return


/*/{Protheus.doc} TTPedData
** Query para os dados da Temporaria
@author Equipe OMS
@since 25/08/2021
/*/
Static Function TTPedData()
	Local cOperaOra  := IIf(Upper(TcGetDb())$'ORACLE',.T.,.F.)
	Local cQuery := ""
	Local nTamA1COD := TamSX3('A1_COD')[1]
	Local nTamA1LOJ := TamSX3('A1_LOJA')[1]
	Local nTamA2COD := TamSX3('A2_COD')[1]
	Local nTamA2LOJ := TamSX3('A2_LOJA')[1]
	Local nTamC9Fil := TamSX3('C9_FILIAL')[1]
	Local nTamC9Ped := TamSX3('C9_PEDIDO')[1]
	Local nTamC9Ite := TamSX3('C9_ITEM')[1]
	Local nTamC9Seq := TamSX3('C9_SEQUEN')[1]
	Local nTamC9Prd := TamSX3('C9_PRODUTO')[1]


	Pergunte("OMSATPR1",.F.)

	If nTipoTela == 1

		cQuery += "Select cAliasTT.* FROM ("

		cQuery += "SELECT ' ' AS TMP_MARK,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN STATUS_INT  = '1' THEN '1'"
		cQuery += 				" WHEN STATUS_INT  = '2' THEN '2'"
		cQuery += 				" WHEN STATUS_INT  = '3' THEN '3'"
		cQuery += 				" WHEN STATUS_INT  = '4' THEN '4'"
		cQuery += 				" ELSE '0' "
		cQuery += 			" END TMP_STINT,"

		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_LIBEROK = ' ' AND SC5.C5_NOTA = ' ' AND SC5.C5_BLQ = ' ') THEN '1'"
		cQuery += 				" WHEN (SC5.C5_LIBEROK <> ' ' AND SC5.C5_NOTA = ' ' AND SC5.C5_BLQ = ' ') THEN '3'"
		cQuery += 				" WHEN SC5.C5_BLQ = '1' THEN '4'"
		cQuery += 				" WHEN SC5.C5_BLQ = '2' THEN '5'"
		cQuery += 			" END TMP_SITPED,"
		cQuery += 			" SC5.C5_TIPO,"
		cQuery += 			" SC5.C5_FILIAL,"
		cQuery +=			" SC5.C5_NUM,"
		cQuery += 			" ' ' AS C9_ITEM,"
		cQuery += 			" ' ' AS C9_SEQUEN,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN PEDQTDLIB IS NULL THEN SUM(C9_QTDLIB)"
		cQuery += 				" ELSE PEDQTDLIB"
		cQuery += 			" END AS TMP_QTDLIB,"
		//Inicio graos
		cQuery += 			"  CASE
		cQuery += 			"    WHEN PEDPESOLQ IS NOT NULL THEN PEDPESOLQ"
		cQuery += 			"    WHEN SB5.B5_TIPUNIT = '1' THEN SUM(SB1.B1_PESO)"
		cQuery += 			"    ELSE SUM(C9_QTDLIB * SB1.B1_PESO)"
		cQuery += 			"  END AS TMP_PESOLQ,"
		cQuery += 			"  CASE
		cQuery += 			"    WHEN PEDPESOBR IS NOT NULL THEN PEDPESOBR"
		cQuery += 			"    WHEN SB5.B5_TIPUNIT = '1' THEN SUM(SB1.B1_PESBRU)"
		cQuery += 			"    ELSE SUM(C9_QTDLIB * SB1.B1_PESBRU)"
		cQuery += 			"  END AS PEDPESOBR,"
		//Final graos

		If cOperaOra
			cQuery += 			" NVL(PEDVOL, 0) AS TMP_VOL,"
		Else
			cQuery += 			" CASE"
			cQuery += 				" WHEN PEDVOL IS NULL THEN 0"
			cQuery += 				" ELSE PEDVOL"
			cQuery += 			" END AS TMP_VOL,"
		EndIf

		cQuery += 			" ' ' AS B1_COD,"
		cQuery += 			" ' ' AS B1_DESC,"
		cQuery += 			" CASE"
		cQuery +=				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery +=					" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_FILIAL"
		cQuery +=				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery +=					" OR SC5.C5_REDESP = ' ')"
		cQuery +=					" AND SC5.C5_TIPO IN ('B',"
		cQuery +=						" 'D') THEN SA2.A2_FILIAL"
		cQuery +=				" ELSE SA1.A1_FILIAL" //A filial do cliente do pedido precisa ser a mesma da filial do cliente entrega
		cQuery +=			" END AS TMP_FILFCL,"
		cQuery +=  			" CASE"
		cQuery +=				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery +=					" AND SC5.C5_REDESP <> ' ') THEN SC5.C5_REDESP"
		cQuery +=				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery +=					" OR SC5.C5_REDESP = ' ')"
		cQuery +=					" AND SC5.C5_TIPO IN ('B',"
		cQuery +=					" 'D') THEN SC5.C5_CLIENT"
		cQuery +=				" ELSE SC5.C5_CLIENT"
		cQuery +=			" END AS TMP_CODFCL,"
		cQuery +=			" CASE"
		cQuery +=				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery +=					" AND SC5.C5_REDESP <> ' ') THEN ' '"
		cQuery +=				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 					" OR SC5.C5_REDESP = ' ')"
		cQuery +=					" AND SC5.C5_TIPO IN ('B',"
		cQuery += 						" 'D') THEN SC5.C5_LOJAENT"
		cQuery += 				" ELSE SC5.C5_LOJAENT"
		cQuery += 			" END AS TMP_LOJFCL,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 			"           AND SC5.C5_REDESP <> ' ') THEN SA4.A4_NREDUZ"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 						" OR SC5.C5_REDESP = ' ')"
		cQuery += 						" AND SC5.C5_TIPO IN ('B',"
		cQuery += 								" 'D') THEN SA2.A2_NREDUZ"
		cQuery += 				" ELSE SA1.A1_NREDUZ"
		cQuery += 			" END AS TMP_NOMFAN,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 						" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_CGC"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 						" OR SC5.C5_REDESP = ' ')"
		cQuery += 						" AND SC5.C5_TIPO IN ('B',"
		cQuery += 								" 'D') THEN SA2.A2_CGC"
		cQuery += 				" ELSE SA1.A1_CGC"
		cQuery += 			" END AS TMP_CGCCLI,"

		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 						" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_CEP"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 						" OR SC5.C5_REDESP = ' ')"
		cQuery += 						" AND SC5.C5_TIPO IN ('B',"
		cQuery += 								" 'D') THEN SA2.A2_CEP"
		cQuery += 				" ELSE SA1.A1_CEP"
		cQuery += 			" END AS TMP_CEP,"

		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 					" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_END"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 					" OR SC5.C5_REDESP = ' ')"
		cQuery += 					" AND SC5.C5_TIPO IN ('B',"
		cQuery += 							" 'D') THEN SA2.A2_END"
		cQuery += 				" ELSE SA1.A1_END"
		cQuery += 			" END AS TMP_END,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 					" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_BAIRRO"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 						" OR SC5.C5_REDESP = ' ')"
		cQuery += 						" AND SC5.C5_TIPO IN ('B',"
		cQuery += 							" 'D') THEN SA2.A2_BAIRRO"
		cQuery += 				" ELSE SA1.A1_BAIRRO"
		cQuery += 			" END AS TMP_BAIRRO,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 						" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_MUN"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 						" OR SC5.C5_REDESP = ' ')"
		cQuery += 						" AND SC5.C5_TIPO IN ('B',"
		cQuery += 							" 'D') THEN SA2.A2_MUN"
		cQuery += 				" ELSE SA1.A1_MUN"
		cQuery += 			" END AS TMP_MUN,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 					" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_EST"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 					" OR SC5.C5_REDESP = ' ')"
		cQuery += 					" AND SC5.C5_TIPO IN ('B',"
		cQuery += 								" 'D') THEN SA2.A2_EST"
		cQuery += 				" ELSE SA1.A1_EST"
		cQuery += 			" END AS TMP_EST,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN YA_SIGLA IS NULL THEN 'BRA'"
		cQuery += 				" ELSE YA_SIGLA"
		cQuery += 			" END AS TMP_PAIS,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN A4_COD IS NULL THEN ' '"
		cQuery += 				" ELSE A4_COD"
		cQuery += 			" END A4_COD,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN A4_NOME IS NULL THEN ' '"
		cQuery += 				" ELSE A4_NOME"
		cQuery += 			" END A4_NOME,"
		cQuery += 			" SC5.C5_EMISSAO,"

		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 					" AND SC5.C5_REDESP <> ' ') THEN 'SA4'"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 					" OR SC5.C5_REDESP = ' ')"
		cQuery += 					" AND SC5.C5_TIPO IN ('B',"
		cQuery += 								" 'D') THEN 'SA2'"
		cQuery += 				" ELSE 'SA1'"
		cQuery += 			" END AS TMP_ENTIDA,"

		cQuery += 			" CASE"
		cQuery += 				" WHEN DAR.DAR_LATITU IS NULL THEN ' ' "
		cQuery += 				" ELSE DAR.DAR_LATITU"
		cQuery += 			" END AS TMP_LATITU,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN DAR.DAR_LONGIT IS NULL THEN ' ' "
		cQuery += 				" ELSE DAR.DAR_LONGIT"
		cQuery += 			" END AS TMP_LONGIT"

		cQuery += " FROM  " + RetSqlName("SC5") + "  SC5"
		cQuery += " INNER JOIN  " + RetSqlName("SC6") + "  SC6 ON SC6.C6_FILIAL = SC5.C5_FILIAL"
		cQuery += 		" AND SC6.C6_NUM = SC5.C5_NUM"
		cQuery += 		" AND SC6.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN  " + RetSqlName("SC9") + "  SC9 ON SC9.C9_FILIAL = SC5.C5_FILIAL"
		cQuery += 		" AND SC9.C9_PEDIDO = SC5.C5_NUM"
		cQuery += 		" AND SC9.C9_ITEM = SC6.C6_ITEM"
		cQuery += 		" AND SC9.C9_DATALIB BETWEEN '" +DtoS(MV_PAR07)+"' AND '" +DtoS(MV_PAR08)+"'"

		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
		cQuery += " AND SB1.B1_COD = SC9.C9_PRODUTO"
		cQuery += " AND SB1.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN " + RetSqlName("SB5") + " SB5 ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
		cQuery += " AND SB5.B5_COD = SB1.B1_COD"
		cQuery += " AND SB5.D_E_L_E_T_ = ' '"

		cQuery += " LEFT JOIN  " + RetSqlName("SA2") + "  SA2 ON SA2.A2_FILIAL = '" + FwxFilial("SA2") + "'"
		cQuery += 		" AND SA2.A2_COD = SC5.C5_CLIENT"
		cQuery += 		" AND SA2.A2_LOJA = SC5.C5_LOJAENT"
		cQuery += 		" AND SA2.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN  " + RetSqlName("SA1") + "  SA1 ON SA1.A1_FILIAL = '" + FwxFilial("SA1") + "'"
		cQuery += 		" AND SA1.A1_COD = SC5.C5_CLIENT"
		cQuery +=		" AND SA1.A1_LOJA = SC5.C5_LOJAENT"
		cQuery += 		" AND SA1.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN  " + RetSqlName("SA4") + "  SA4 ON SA4.A4_FILIAL = '" + FwxFilial("SA4") + "'"
		cQuery += 		" AND SA4.A4_COD = SC5.C5_REDESP"
		cQuery += 		" AND SA4.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN  " + RetSqlName("SYA") + "  SYA ON (SYA.YA_FILIAL= '" + FwxFilial("SYA") + "'"
		cQuery += 		" AND SYA.YA_CODGI = A1_PAIS"
		cQuery +=		 " AND SYA.D_E_L_E_T_ = ' ')"
		cQuery += 		" OR (SYA.YA_FILIAL= '" + FwxFilial("SYA") + "'"
		cQuery += 		" AND SYA.YA_CODGI = A2_PAIS"
		cQuery += 		" AND SYA.D_E_L_E_T_ = ' ')"

		cQuery += " LEFT JOIN  " + RetSqlName("DAR") + "  DAR ON "
		cQuery += 		" (((SC5.C5_REDESP IS NULL OR SC5.C5_REDESP = ' ') AND SC5.C5_TIPO NOT IN ('B','D')) "
		cQuery += 			" AND (DAR.DAR_FILENT = A1_FILIAL"
		cQuery += 			" AND SUBSTRING(DAR.DAR_CODENT,1,"+cValtoChar(nTamA1COD)+") = SA1.A1_COD"
		cQuery += 			" AND SUBSTRING(DAR.DAR_CODENT,"+cValtoChar(nTamA1COD+1)+","+cValtoChar(nTamA1LOJ)+") = SA1.A1_LOJA"
		cQuery += 			" AND DAR.DAR_ENTIDA = 'SA1'"
		cQuery += 			" AND DAR.D_E_L_E_T_ = ' '))"
		cQuery += 		" OR (((SC5.C5_REDESP IS NULL OR SC5.C5_REDESP = ' ') AND SC5.C5_TIPO IN ('B','D'))"
		cQuery += 			" AND (DAR.DAR_FILENT = A2_FILIAL"
		cQuery += 			" AND SUBSTRING(DAR.DAR_CODENT,1,"+cValtoChar(nTamA2COD)+") = SA2.A2_COD"
		cQuery += 			" AND SUBSTRING(DAR.DAR_CODENT,"+cValtoChar(nTamA2COD+1)+","+cValtoChar(nTamA2LOJ)+") = SA2.A2_LOJA"
		cQuery += 			" AND DAR.DAR_ENTIDA = 'SA2'"
		cQuery += 			" AND DAR.D_E_L_E_T_ = ' '))"
		cQuery += 		" OR ((SC5.C5_REDESP IS NOT NULL AND SC5.C5_REDESP <> ' ') "
		cQuery += 			" AND (DAR.DAR_FILENT = A4_FILIAL"
		cQuery += 			" AND DAR.DAR_CODENT = SA4.A4_COD"
		cQuery += 			" AND DAR.DAR_ENTIDA = 'SA4')"	
		cQuery += 			" AND DAR.D_E_L_E_T_ = ' ')"

		cQuery += 	" LEFT JOIN
		cQuery += 		" (SELECT SC91.C9_FILIAL,SC91.C9_PEDIDO,
		cQuery += 			" DMS_STATUS AS STATUS_INT,
		cQuery += 			" SUM(C9_QTDLIB) AS PEDQTDLIB,
		//Inicio Graos
		cQuery += 	" CASE
		cQuery += 	" 	WHEN SB5.B5_TIPUNIT = '1' THEN SUM(SB1.B1_PESO)"
		cQuery += 	" 	ELSE SUM(C9_QTDLIB * SB1.B1_PESO)
		cQuery += 	" END AS PEDPESOLQ,
				
		cQuery += 	" CASE
		cQuery += 	" 	WHEN SB5.B5_TIPUNIT = '1' THEN SUM(SB1.B1_PESBRU)"
		cQuery += 	" 	ELSE SUM(C9_QTDLIB * B1_PESBRU)
		cQuery += 	" END AS PEDPESOBR,
		//Final Graos

		If cOperaOra
			cQuery += 			" SUM((NVL(SB5.B5_ALTURLC, 0) * NVL(SB5.B5_LARGLC, 0) * NVL(SB5.B5_COMPRLC, 0))*C9_QTDLIB) AS PEDVOL,
		Else
			cQuery += " CASE "
			cQuery +=		" WHEN SUM((SB5.B5_ALTURLC * SB5.B5_LARGLC * SB5.B5_COMPRLC)*C9_QTDLIB) IS NULL "
			cQuery += 			" THEN 0 "
			cQuery += 		" ELSE  SUM((SB5.B5_ALTURLC * SB5.B5_LARGLC * SB5.B5_COMPRLC)*C9_QTDLIB)"
			cQuery += 		" END AS PEDVOL,"
		EndIf

		cQuery += 			"SC91.C9_CARGA AS CARGA "
		cQuery += 				" FROM " + RetSqlName("SC9") + " SC91
		cQuery += 					" LEFT JOIN " + RetSqlName("DMS") + " DMS ON DMS.DMS_FILIAL = '"+FWxFilial("DMS")+"'"
		cQuery += 					" AND DMS.DMS_FILROT = '"+cFilAnt+"'"
		cQuery += 					" AND DMS.DMS_ENTIDA = 'SC9'
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,1,"+cValtoChar(nTamC9Fil)+") = SC91.C9_FILIAL"
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+1)+","+cValtoChar(nTamC9Ped)+") = SC91.C9_PEDIDO"		
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+1)+","+cValtoChar(nTamC9Ite)+") = SC91.C9_ITEM"			
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+1)+","+cValtoChar(nTamC9Seq)+") = SC91.C9_SEQUEN"
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+nTamC9Seq+1)+","+cValtoChar(nTamC9Prd)+") = SC91.C9_PRODUTO"
		cQuery += 					" AND DMS.D_E_L_E_T_ = ' '"
		cQuery += 						" INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + FwxFilial("SB1") + "'"
		cQuery += 							" AND SB1.B1_COD = SC91.C9_PRODUTO
		cQuery += 							" AND SB1.D_E_L_E_T_ = ' '
		cQuery += 						" LEFT JOIN " + RetSqlName("SB5") + " SB5 ON SB5.B5_FILIAL = '" + FwxFilial("SB5") + "'"
		cQuery += 							" AND SB5.B5_COD = SB1.B1_COD
		cQuery += 							" AND SB5.D_E_L_E_T_ = ' '

		cQuery += 					" WHERE SC91.D_E_L_E_T_ = ' '"
		cQuery += 					" AND SC91.C9_FILIAL = '"+FWxFilial("SC9")+"'"
		cQuery += 					" AND SC91.C9_CARGA = ' '"
		cQuery += 					" AND (SC91.C9_BLEST = ' ' AND SC91.C9_BLCRED = ' ')"

		cQuery += 								" GROUP BY SC91.C9_FILIAL,SC91.C9_PEDIDO,SC91.C9_CARGA,"
		//Inicio Graos
		cQuery += 								" SB5.B5_TIPUNIT,"
		//Final Graos

		cQuery += 									" DMS_STATUS"
		cQuery += 		" ) SC9C ON SC9C.C9_FILIAL = SC9.C9_FILIAL"
		cQuery += 		" AND SC9C.C9_PEDIDO = SC9.C9_PEDIDO "

		cQuery += " WHERE SC5.C5_FILIAL BETWEEN '"+ MV_PAR01+"' AND '"+MV_PAR02+"'" 
		cQuery += 	" AND SC5.C5_NUM BETWEEN '"+   MV_PAR03+"' AND '"+MV_PAR04+"'"
		cQuery += 	" AND SC5.C5_EMISSAO BETWEEN '" +DtoS(MV_PAR05)+"' AND '" +DtoS(MV_PAR06)+"'"
		cQuery += 	" AND SC5.C5_CLIENTE BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'"
		cQuery += 	" AND SC5.C5_TPCARGA = '1'"
		cQuery += 	" AND SC5.D_E_L_E_T_ = ' '"
		cQuery += "   AND SC5.C5_NOTA = ' '"
		cQuery += 	" AND SC9.C9_FILIAL = '" + FwxFilial("SC9") + "'"
		cQuery += 	" AND (SC9.C9_BLEST = ' ' AND SC9.C9_BLCRED = ' ' AND SC9.C9_CARGA = ' '"
		cQuery += 	" AND SC9.C9_SEQCAR = ' ' AND SC9.C9_SEQENT = ' ')"
		cQuery += 	" AND SC9.D_E_L_E_T_ = ' '"
		cQuery += "   AND SC9.C9_TPCARGA = '1'"
				
		cQuery += 	" GROUP BY SC5.C5_FILIAL,"
		cQuery += 			"SC5.C5_NUM,"
		cQuery += 			"SC5.C5_EMISSAO,"
		cQuery += 			"SC5.C5_TIPO,"
		cQuery += 			"SC5.C5_LIBEROK,"
		cQuery +=			"SC5.C5_NOTA,"
		cQuery += 			"SC5.C5_BLQ,"
		cQuery += 			"SA1.A1_FILIAL,"
		cQuery += 			"SA2.A2_FILIAL,"
		cQuery += 			"SA4.A4_FILIAL,"
		cQuery += 			"SC5.C5_CLIENT,"
		cQuery += 			"SC5.C5_LOJAENT,"
		cQuery += 			"SA4.A4_COD,"
		cQuery += 			"DAR.DAR_ENTIDA,"
		cQuery += 			"DAR.DAR_LATITU,"
		cQuery += 			"DAR.DAR_LONGIT,"
		cQuery += 			"SC5.C5_FECENT,"
		cQuery += 			"SC5.C5_REDESP,"
		cQuery +=			"SA2.A2_NOME,"
		cQuery += 			"SA1.A1_NOME,"
		cQuery += 			"SA4.A4_NOME,"
		cQuery += 			"SA2.A2_NREDUZ,"
		cQuery += 			"SA1.A1_NREDUZ,"
		cQuery += 			"SA4.A4_NREDUZ,"
		cQuery += 			"SA2.A2_CGC,"
		cQuery += 			"SA1.A1_CGC,"
		cQuery += 			"SA4.A4_CGC,"
		cQuery += 			"SA2.A2_CEP,"
		cQuery += 			"SA1.A1_CEP,"
		cQuery += 			"SA4.A4_CEP,"
		cQuery += 			"SA2.A2_END,"
		cQuery += 			"SA1.A1_END,"
		cQuery += 			"SA4.A4_END,"
		cQuery += 			"SA2.A2_BAIRRO, "
		cQuery += 			"SA1.A1_BAIRRO, "
		cQuery += 			"SA4.A4_BAIRRO, "
		cQuery += 			"SA2.A2_MUN,"
		cQuery += 			"SA1.A1_MUN,"
		cQuery += 			"SA4.A4_MUN,"
		cQuery += 			"SA2.A2_EST,"
		cQuery += 			"SA1.A1_EST,"
		cQuery += 			"SA4.A4_EST,"
		cQuery += 			"SYA.YA_SIGLA,"
		//Inicio Graos
		cQuery += 			"SB5.B5_TIPUNIT,"
		//Final Graos
		cQuery += 			"SC5.C5_PESOL,"
		cQuery += 			"SC5.C5_PBRUTO,"

		cQuery += 			"STATUS_INT,
		cQuery += 			"PEDQTDLIB,
		cQuery += 			"PEDPESOLQ,
		cQuery += 			"PEDPESOBR,
		cQuery += 			"PEDVOL

 		cQuery += 			" ) cAliasTT"

		If MV_PAR13 != 5
			cQuery += 			" WHERE TMP_STINT = '"+CValToChar(OMSTPRStat(MV_PAR13))+"'"
		EndIf

	Else

		cQuery += "Select cAliasTT.* FROM ("

		cQuery += " SELECT ' ' AS TMP_MARK,"

		cQuery += 			" CASE"
		cQuery += 				" WHEN STATUS_INT  = '1' THEN '1'"
		cQuery += 				" WHEN STATUS_INT  = '2' THEN '2'"
		cQuery += 				" WHEN STATUS_INT  = '3' THEN '3'"
		cQuery += 				" WHEN STATUS_INT  = '4' THEN '4'"
		cQuery += 				" ELSE '0' "
		cQuery += 			" END TMP_STINT,"

		cQuery +=            " CASE "
		cQuery +=                " WHEN (SC5.C5_LIBEROK = ' ' AND SC5.C5_NOTA = ' ' AND SC5.C5_BLQ = ' ') THEN 1"
		cQuery +=                " WHEN (SC5.C5_LIBEROK <> ' ' AND SC5.C5_NOTA = ' ' AND SC5.C5_BLQ = ' ') THEN 3"
		cQuery +=                " WHEN SC5.C5_BLQ = '1' THEN 4"
		cQuery +=                " WHEN SC5.C5_BLQ = '2' THEN 5"
		cQuery +=            " END TMP_SITPED,"
		cQuery +=            " C5_TIPO,"
		cQuery +=            " SC9.C9_FILIAL,"
		cQuery +=            " SC9.C9_PEDIDO,"
		cQuery +=            " SC9.C9_ITEM,"
		cQuery +=            " SC9.C9_SEQUEN,"
		cQuery +=            " C9_QTDLIB,"

		//Inicio Graos
		cQuery += 			" CASE" 
		cQuery += 				" WHEN SB5.B5_TIPUNIT = '1' THEN SB1.B1_PESO"
		cQuery += 				" ELSE  C9_QTDLIB * B1_PESO "
		cQuery += 			" END AS TMP_PESOLQ,"

		cQuery += 			" CASE" 
		cQuery += 				" WHEN SB5.B5_TIPUNIT = '1' THEN SB1.B1_PESBRU"
		cQuery += 				" ELSE  C9_QTDLIB * B1_PESBRU "
		cQuery += 			" END AS TMP_PESOBR,"
		//Final Graos
		If cOperaOra
			cQuery +=            " (NVL(SB5.B5_ALTURLC, 0) * NVL(SB5.B5_LARGLC, 0) * NVL(SB5.B5_COMPRLC, 0))*C9_QTDLIB AS TMP_VOL,"
		Else
			cQuery += "CASE "
			cQuery +=		" WHEN (SB5.B5_ALTURLC * SB5.B5_LARGLC * SB5.B5_COMPRLC)*C9_QTDLIB IS NULL "
			cQuery += 			" THEN 0 "
			cQuery += 		" ELSE  (SB5.B5_ALTURLC * SB5.B5_LARGLC * SB5.B5_COMPRLC)*C9_QTDLIB"
			cQuery += 		" END AS TMP_VOL,"
		EndIf

		cQuery +=            " B1_COD,"
		cQuery +=            " B1_DESC,"


		cQuery +=			" CASE"
		cQuery +=				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery +=					" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_FILIAL"
		cQuery +=				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery +=					" OR SC5.C5_REDESP = ' ')"
		cQuery +=					" AND SC5.C5_TIPO IN ('B',"
		cQuery +=						" 'D') THEN SA2.A2_FILIAL"
		cQuery +=					" ELSE SA1.A1_FILIAL" //A filial do cliente do pedido precisa ser a mesma da filial do cliente entrega
		cQuery +=			" END AS TMP_FILFCL,"
		cQuery +=			" CASE"
		cQuery +=				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery +=					" AND SC5.C5_REDESP <> ' ') THEN SC5.C5_REDESP"
		cQuery +=				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery +=					" OR SC5.C5_REDESP = ' ')"
		cQuery +=					" AND SC5.C5_TIPO IN ('B',"
		cQuery +=						" 'D') THEN SC5.C5_CLIENT"
		cQuery +=				" ELSE SC5.C5_CLIENT"
		cQuery +=			" END AS TMP_CODFCL,"
		cQuery +=			" CASE"
		cQuery +=				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery +=					" AND SC5.C5_REDESP <> ' ') THEN ' '"
		cQuery +=				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery +=					" OR SC5.C5_REDESP = ' ')"
		cQuery +=					" AND SC5.C5_TIPO IN ('B',"
		cQuery +=					" 'D') THEN SC5.C5_LOJAENT"
		cQuery +=				" ELSE SC5.C5_LOJAENT"
		cQuery +=			" END AS TMP_LOJFCL,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 			"           AND SC5.C5_REDESP <> ' ') THEN SA4.A4_NREDUZ"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 						" OR SC5.C5_REDESP = ' ')"
		cQuery += 						" AND SC5.C5_TIPO IN ('B',"
		cQuery += 								" 'D') THEN SA2.A2_NREDUZ"
		cQuery += 				" ELSE SA1.A1_NREDUZ"
		cQuery += 			" END AS TMP_NOMFAN,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 						" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_CGC"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 						" OR SC5.C5_REDESP = ' ')"
		cQuery += 						" AND SC5.C5_TIPO IN ('B',"
		cQuery += 								" 'D') THEN SA2.A2_CGC"
		cQuery += 				" ELSE SA1.A1_CGC"
		cQuery += 			" END AS TMP_CGCCLI,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 						" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_CEP"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 						" OR SC5.C5_REDESP = ' ')"
		cQuery += 						" AND SC5.C5_TIPO IN ('B',"
		cQuery += 								" 'D') THEN SA2.A2_CEP"
		cQuery += 				" ELSE SA1.A1_CEP"
		cQuery += 			" END AS TMP_CEP,"

		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 					" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_END"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 					" OR SC5.C5_REDESP = ' ')"
		cQuery += 					" AND SC5.C5_TIPO IN ('B',"
		cQuery += 							" 'D') THEN SA2.A2_END"
		cQuery += 				" ELSE SA1.A1_END"
		cQuery += 			" END AS TMP_END,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 					" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_BAIRRO"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 						" OR SC5.C5_REDESP = ' ')"
		cQuery += 						" AND SC5.C5_TIPO IN ('B',"
		cQuery += 							" 'D') THEN SA2.A2_BAIRRO"
		cQuery += 				" ELSE SA1.A1_BAIRRO"
		cQuery += 			" END AS TMP_BAIRRO,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 						" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_MUN"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 						" OR SC5.C5_REDESP = ' ')"
		cQuery += 						" AND SC5.C5_TIPO IN ('B',"
		cQuery += 							" 'D') THEN SA2.A2_MUN"
		cQuery += 				" ELSE SA1.A1_MUN"
		cQuery += 			" END AS TMP_MUN,"
		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 					" AND SC5.C5_REDESP <> ' ') THEN SA4.A4_EST"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 					" OR SC5.C5_REDESP = ' ')"
		cQuery += 					" AND SC5.C5_TIPO IN ('B',"
		cQuery += 								" 'D') THEN SA2.A2_EST"
		cQuery += 				" ELSE SA1.A1_EST"
		cQuery += 			" END AS TMP_EST,"
		cQuery +=            " CASE"
		cQuery +=            "     WHEN YA_SIGLA IS NULL THEN 'BRA'"
		cQuery +=            "     ELSE YA_SIGLA"
		cQuery +=            " END AS TMP_PAIS,"
		cQuery +=            " CASE"
		cQuery +=            "     WHEN A4_COD IS NULL THEN ' '"
		cQuery +=            "     ELSE A4_COD"
		cQuery +=            " END A4_COD,"
		cQuery +=            " CASE"
		cQuery +=            "     WHEN A4_NOME IS NULL THEN ' '"
		cQuery +=            "     ELSE A4_NOME"
		cQuery +=            " END A4_NOME,"
		cQuery +=            " SC5.C5_EMISSAO,"

		cQuery += 			" CASE"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NOT NULL"
		cQuery += 					" AND SC5.C5_REDESP <> ' ') THEN 'SA4'"
		cQuery += 				" WHEN (SC5.C5_REDESP IS NULL"
		cQuery += 					" OR SC5.C5_REDESP = ' ')"
		cQuery += 					" AND SC5.C5_TIPO IN ('B',"
		cQuery += 								" 'D') THEN 'SA2'"
		cQuery += 				" ELSE 'SA1'"
		cQuery += 			" END AS TMP_ENTIDA,"
		
		cQuery +=            " CASE"
		cQuery +=            		" WHEN DAR.DAR_LATITU IS NULL THEN ' ' "
		cQuery +=            		" ELSE DAR.DAR_LATITU"
		cQuery +=            " END AS TMP_LATITU,"
		cQuery +=            " CASE"
		cQuery +=            		" WHEN DAR.DAR_LONGIT IS NULL THEN ' ' "
		cQuery +=            		" ELSE DAR.DAR_LONGIT"
		cQuery +=            " END AS TMP_LONGIT"
		cQuery += " FROM  " + RetSqlName("SC5") + "  SC5"
		cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON SC6.C6_FILIAL = SC5.C5_FILIAL"
		cQuery += " AND SC6.C6_NUM = SC5.C5_NUM"
		cQuery += " AND SC6.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_FILIAL = '"+xFilial("SA2")+"'"
		cQuery += " AND SA2.A2_COD = SC5.C5_CLIENT"
		cQuery += " AND SA2.A2_LOJA = SC5.C5_LOJAENT"
		cQuery += " AND SA2.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
		cQuery += " AND SA1.A1_COD = SC5.C5_CLIENT"
		cQuery += " AND SA1.A1_LOJA = SC5.C5_LOJAENT"
		cQuery += " AND SA1.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN " + RetSqlName("SA4") + " SA4 ON SA4.A4_FILIAL = '"+xFilial("SA4")+"'"
		cQuery += " AND SA4.A4_COD = SC5.C5_REDESP"
		cQuery += " AND SA4.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN " + RetSqlName("SC9") + " SC9 ON SC9.C9_FILIAL = SC6.C6_FILIAL"
		cQuery += " AND SC9.C9_PEDIDO = SC6.C6_NUM"
		cQuery += " AND SC9.C9_ITEM = SC6.C6_ITEM"
		cQuery += " AND SC9.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
		cQuery += " AND SB1.B1_COD = SC9.C9_PRODUTO"
		cQuery += " AND SB1.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN " + RetSqlName("SB5") + " SB5 ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
		cQuery += " AND SB5.B5_COD = SB1.B1_COD"
		cQuery += " AND SB5.D_E_L_E_T_ = ' '"

		cQuery += " LEFT JOIN  " + RetSqlName("DAR") + "  DAR ON "
		cQuery += 		" (((SC5.C5_REDESP IS NULL OR SC5.C5_REDESP = ' ') AND SC5.C5_TIPO NOT IN ('B','D')) "
		cQuery += 			" AND (DAR.DAR_FILENT = A1_FILIAL"
		cQuery += 			" AND SUBSTRING(DAR.DAR_CODENT,1,"+cValtoChar(nTamA1COD)+") = SA1.A1_COD"
		cQuery += 			" AND SUBSTRING(DAR.DAR_CODENT,"+cValtoChar(nTamA1COD+1)+","+cValtoChar(nTamA1LOJ)+") = SA1.A1_LOJA"
		cQuery += 			" AND DAR.DAR_ENTIDA = 'SA1'"
		cQuery += 			" AND DAR.D_E_L_E_T_ = ' '))"
		cQuery += 		" OR (((SC5.C5_REDESP IS NULL OR SC5.C5_REDESP = ' ') AND SC5.C5_TIPO IN ('B','D'))"
		cQuery += 			" AND (DAR.DAR_FILENT = A2_FILIAL"
		cQuery += 			" AND SUBSTRING(DAR.DAR_CODENT,1,"+cValtoChar(nTamA2COD)+") = SA2.A2_COD"
		cQuery += 			" AND SUBSTRING(DAR.DAR_CODENT,"+cValtoChar(nTamA2COD+1)+","+cValtoChar(nTamA2LOJ)+") = SA2.A2_LOJA"
		cQuery += 			" AND DAR.DAR_ENTIDA = 'SA2'"
		cQuery += 			" AND DAR.D_E_L_E_T_ = ' '))"
		cQuery += 		" OR ((SC5.C5_REDESP IS NOT NULL AND SC5.C5_REDESP <> ' ') "
		cQuery += 			" AND (DAR.DAR_FILENT = A4_FILIAL"
		cQuery += 			" AND DAR.DAR_CODENT = SA4.A4_COD"
		cQuery += 			" AND DAR.DAR_ENTIDA = 'SA4')"	
		cQuery += 			" AND DAR.D_E_L_E_T_ = ' ')"

		cQuery  += " LEFT JOIN " + RetSQLName("SYA") + " SYA"
		cQuery  += " ON (SYA.YA_FILIAL = '" + FwxFilial("SYA") + "'"
		cQuery  += " AND SYA.YA_CODGI = A1_PAIS"
		cQuery  += " AND SYA.D_E_L_E_T_ = ' ') OR"
		cQuery  += " (SYA.YA_FILIAL = '" + FwxFilial("SYA") + "'"
		cQuery  += " AND SYA.YA_CODGI = A2_PAIS"
		cQuery  += " AND SYA.D_E_L_E_T_ = ' ')"

		cQuery  += 	" LEFT JOIN
		cQuery  += 		" (SELECT SC91.C9_FILIAL,SC91.C9_PEDIDO,SC91.C9_ITEM,SC91.C9_SEQUEN,SC91.C9_PRODUTO,
	 	cQuery  += "		 DMS_STATUS AS STATUS_INT
		cQuery  += 			" FROM " + RetSQLName("SC9") + " SC91

		cQuery += 					" INNER JOIN " + RetSqlName("DMS") + " DMS ON DMS.DMS_FILIAL = '"+FWxFilial("DMS")+"'"
		cQuery += 					" AND DMS.DMS_FILROT = '"+cFilAnt+"'"
		cQuery += 					" AND DMS.DMS_ENTIDA = 'SC9'
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,1,"+cValtoChar(nTamC9Fil)+") = SC91.C9_FILIAL"
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+1)+","+cValtoChar(nTamC9Ped)+") = SC91.C9_PEDIDO"		
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+1)+","+cValtoChar(nTamC9Ite)+") = SC91.C9_ITEM"			
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+1)+","+cValtoChar(nTamC9Seq)+") = SC91.C9_SEQUEN"
		cQuery += 						" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+nTamC9Seq+1)+","+cValtoChar(nTamC9Prd)+") = SC91.C9_PRODUTO"
		cQuery  += 					" AND DMS.D_E_L_E_T_ = ' '
		cQuery  += 					" AND SC91.D_E_L_E_T_ = ' '
		cQuery  += 						" INNER JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + FwxFilial("SB1") + "'"
		cQuery  += 							" AND SB1.B1_COD = SC91.C9_PRODUTO
		cQuery  += 							" AND SB1.D_E_L_E_T_ = ' '
		cQuery  += 						" LEFT JOIN " + RetSQLName("SB5") + " SB5 ON SB5.B5_FILIAL = '" + FwxFilial("SB5") + "'"
		cQuery  += 							" AND SB5.B5_COD = SB1.B1_COD
		cQuery  += 							" AND SB5.D_E_L_E_T_ = ' '
	
		cQuery  += 			" ) SC9C ON SC9C.C9_FILIAL = SC9.C9_FILIAL
		cQuery  += 					" AND SC9C.C9_PEDIDO = SC9.C9_PEDIDO 
		cQuery  += 					" AND  SC9C.C9_ITEM= SC9.C9_ITEM 
		cQuery  += 					" AND  SC9C.C9_SEQUEN= SC9.C9_SEQUEN 
		cQuery  += 					" AND  SC9C.C9_PRODUTO= SC9.C9_PRODUTO 

		cQuery += " WHERE SC5.C5_FILIAL >= '"+MV_PAR01+"'"
		cQuery += "   AND SC5.C5_FILIAL <= '"+MV_PAR02+"'"
		cQuery += "   AND SC5.C5_NUM >= '"+MV_PAR03+"'"
		cQuery += "   AND SC5.C5_NUM <= '"+MV_PAR04+"'"
		cQuery += "   AND SC5.C5_CLIENTE >= '"+MV_PAR09+"'"
		cQuery += "   AND SC5.C5_CLIENTE <= '"+MV_PAR10+"'"
		cQuery += "   AND SC5.C5_EMISSAO >= '" +DtoS(MV_PAR05)+"'"
		cQuery += "   AND SC5.C5_EMISSAO <= '" +DtoS(MV_PAR06)+"'"
		cQuery += "   AND SC5.D_E_L_E_T_ = ' '"
		cQuery += "   AND SC5.C5_NOTA = ' '"
		cQuery += "   AND SC9.C9_CARGA = '      '"
		cQuery += "   AND SC9.C9_SEQCAR = '  '"
		cQuery += "   AND SC9.C9_SEQENT = '  '"
		cQuery += "   AND SC9.C9_DATALIB >= '" +DtoS(MV_PAR07)+"'"
		cQuery += "   AND SC9.C9_DATALIB <= '"+DtoS(MV_PAR08)+"'"
		cQuery += "   AND SC9.C9_BLCRED = '  '"
		cQuery += "   AND SC9.C9_BLEST = '  '"
		cQuery += "   AND SC9.C9_TPCARGA = '1'"

 		cQuery += 			" ) cAliasTT"

		If MV_PAR13 != 5
			cQuery += 			" WHERE TMP_STINT = '"+CValToChar(OMSTPRStat(MV_PAR13))+"'"
		EndIf

	EndIf

	
	OMSTPRCLOG(llogTPR, "OMSATPR1", STR0094 + STR0095 + cQuery ) //"TOTVS Planejamento de Rotas(TPR) - "+"(Query dos Pedidos): "

	WmsQry2Tmp(cAliasPED,oTTPed:oStruct:aFields,cQuery,oTTPed,,.T.)
Return 


/*/{Protheus.doc} OMSTPRStat
	(Recebe o codigo do parametro para definir o status para a query)
	@type  Static Function
	@author user
	@since 21/09/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OMSTPRStat(nStatus)
	Local cStatus := '0'

	Do Case
		Case nStatus = 2  //Pendente
			cStatus := "1"
		Case nStatus = 3 //Rejeitado
			cStatus := "2"
		Case nStatus = 4  //Falha de processamento
			cStatus := "4"
		Case nStatus = 1  //Não enviado  
			cStatus := "0"
	EndCase
	
Return cStatus


/*/{Protheus.doc} TTPedCols
** Campos que aparecerao no browse
@author Equipe OMS
@since 25/08/2021
/*/
Static Function TTPedCols(aStrPedid)
	Local nCol 			:= 0
	Local nX 			:= 0
	Local aColPed 		:= {}
	Local cRemovCpo 	:=  "TMP_MARK,TMP_STINT,TMP_SITPED,TMP_TIPO"

	nCol := 1
	For nx := 1 to Len(aStrPedid)
		If !(aStrPedid[nX,1] $ cRemovCpo)
			AAdd(aColPed,FWBrwColumn():New())
			aColPed[nCol]:SetData(&("{||"+aStrPedid[nX,1]+"}"))
			aColPed[nCol]:SetTitle(aStrPedid[nX,5])
			aColPed[nCol]:SetPicture(aStrPedid[nX,6])
			aColPed[nCol]:SetType(aStrPedid[nX,2])
			aColPed[nCol]:SetSize(aStrPedid[nX,3])
			aColPed[nCol]:SetReadVar(aStrPedid[nX,1])
			nCol++
		Endif
	Next nX
Return aColPed

/*/{Protheus.doc} GeraTTPed
** Criacao da TT de Pedidos
@author Equipe OMS
@since 07/09/2021
/*/
Static Function GeraTTPed(aStrPedid, cAliasPED)
	Local aIndex 		:= {}
	aAdd(aIndex,"TMP_FILIAL+TMP_PEDIDO+TMP_ITEM+TMP_SEQUEN+TMP_CODPRO")
	aAdd(aIndex,"TMP_FILFCL+TMP_CODFCL+TMP_LOJFCL")
	oObjTTPed := CriaTabTmp(aStrPedid,aIndex,@cAliasPED,@oTTPed)
	TTPedData() //Carrega os dados na temporaria
Return

Static Function RefreshBrw(lPergunta, oBrowse)
	Default lPergunta   := .F.
	lMarkAll := .F.

	If Pergunte('OMSATPR1', lPergunta, STR0057) .Or. !lPergunta
		FwMsgRun(,{|| RefrConf(@oBrowse) }, STR0005, STR0004) //"Realizando a busca de pedidos"Aguarde"
	EndIf
Return .F.

Static Function RefrConf(oBrowse)

	// If nTipoTela != MV_PAR14
	// 	nTipoTela := MV_PAR14
	// 	If nTipoTela == 1
	// 		oBrowse:oBrowse:DelColumn(6)
	// 		oBrowse:oBrowse:DelColumn(7)
	// 		oBrowse:oBrowse:DelColumn(12)
	// 		oBrowse:oBrowse:DelColumn(13)
	// 	Else
	// 		oBrowse:oBrowse:RecoveryColumn(6)
	// 		oBrowse:oBrowse:RecoveryColumn(7)
	// 		oBrowse:oBrowse:RecoveryColumn(12)
	// 		oBrowse:oBrowse:RecoveryColumn(13)
	// 	EndIf
	// 	oBrowse:oBrowse:UpdateBrowse()
	// 	oBrowse:oBrowse:Save()
	// EndIf
	TTPedData()
	TTVeiData()
	nQtdVei := 0
	nTotalKg := 0
	nTotalVol := 0
	oBrowse:Refresh(.T.)
Return 


Static Function GeraTTVei(aStrVeic, cAliasVEI)
	Local aIndex 		:= {}
	aAdd(aIndex,"TMP_FILIAL+TMP_COD")
	oObjTTVei := CriaTabTmp(aStrVeic,aIndex,@cAliasVEI,@oTTVei)
Return


Static Function TTVeiData()
	local cQuery := ""

	cQuery += " SELECT ' ' AS TMP_MARK,"
	cQuery += 		" DA3.DA3_FILIAL,"
	cQuery += 		" DA3.DA3_COD,"
	cQuery += 		" DA3.DA3_PLACA,"
	cQuery += 		" DA3.DA3_DESC,"
	cQuery += 		" DA3.DA3_TIPVEI,"
	cQuery += 		" DUT.DUT_DESCRI,"
	cQuery += 		" DA3_CAPACN,"
	cQuery += 		" DA3_VOLMAX,"
	cQuery += 		" DA3_VELOC,"

	cQuery += 		" DA3_QTDEIX,"
	cQuery += 		" DA3_QTEIXV"

	cQuery += 	" FROM " + RetSqlName("DA3") + " DA3"
	cQuery += 	" INNER JOIN " + RetSqlName("DUT") + " DUT ON DUT_FILIAL = '"+FWxFilial("DUT")+"'"
	cQuery += 		" AND DUT_TIPVEI = DA3_TIPVEI"
	cQuery += 		" AND DUT.D_E_L_E_T_ = ' '"
	cQuery += 		" WHERE DA3.D_E_L_E_T_ = ' '"
	cQuery += 	" ORDER BY DA3_TIPVEI"

	WmsQry2Tmp(cAliasVEI,oTTVei:oStruct:aFields,cQuery,oTTVei,,.T.)

Return

/*/{Protheus.doc} TTVeiStrut
** Campos da Tabela Temporaria
@author Equipe OMS
@since 25/08/2021
/*/
Static Function TTVeiStrut()
	Local aDA3TT := {}

	aAdd(aDA3TT,{ "TMP_MARK" , "C", 4, 0, , }) //Selecao
	aAdd(aDA3TT,{ "TMP_FILIAL",   TamSX3("DUT_FILIAL")[3],  TamSX3("DUT_FILIAL")[1],  TamSX3("DUT_FILIAL")[2],  OMSTITULO("DUT_FILIAL"),  PesqPict("DUT", "DUT_FILIAL")})
	aAdd(aDA3TT,{ "TMP_COD",TamSX3("DA3_COD")[3],TamSX3("DA3_COD")[1],TamSX3("DA3_COD")[2],OMSTITULO("DA3_COD"),PesqPict("DA3", "DA3_COD") })
	aAdd(aDA3TT,{ "TMP_PLACA",   TamSX3("DA3_PLACA")[3],  TamSX3("DA3_PLACA")[1],  TamSX3("DA3_PLACA")[2],  STR0033,  PesqPict("DA3", "DA3_PLACA")})
	aAdd(aDA3TT,{ "TMP_VEIDES",TamSX3("DA3_DESC")[3],35/* TamSX3("DA3_DESC")[1]*/,TamSX3("DA3_DESC")[2],STR0073,PesqPict("DA3", "DA3_DESC")})
	aAdd(aDA3TT,{ "TMP_TIPVEI",   TamSX3("DUT_TIPVEI")[3],  TamSX3("DUT_TIPVEI")[1],  TamSX3("DUT_TIPVEI")[2],  STR0034,  PesqPict("DUT", "DUT_TIPVEI")})
	aAdd(aDA3TT,{ "TMP_TIPDES",TamSX3("DUT_DESCRI")[3],TamSX3("DUT_DESCRI")[1],TamSX3("DUT_DESCRI")[2],STR0074,PesqPict("DUT", "DUT_DESCRI")})
	aAdd(aDA3TT,{ "TMP_PESO",TamSX3("DA3_CAPACN")[3],TamSX3("DA3_CAPACN")[1],TamSX3("DA3_CAPACN")[2],OMSTITULO("DA3_CAPACN"),PesqPict("DA3", "DA3_CAPACN") })
	aAdd(aDA3TT,{ "TMP_VOL" , TamSX3("DA3_VOLMAX")[3],  TamSX3("DA3_VOLMAX")[1],  TamSX3("DA3_VOLMAX")[2] ,OMSTITULO("DA3_VOLMAX") ,PesqPict("DA3", "DA3_VOLMAX") })
	aAdd(aDA3TT,{ "TMP_VELOC",TamSX3("DA3_VELOC")[3],TamSX3("DA3_VELOC")[1],TamSX3("DA3_VELOC")[2],OMSTITULO("DA3_VELOC") ,PesqPict("DA3", "DA3_VELOC") })
	
	aAdd(aDA3TT,{ "TMP_QTDEIX",TamSX3("DA3_QTDEIX")[3],TamSX3("DA3_QTDEIX")[1],TamSX3("DA3_QTDEIX")[2],OMSTITULO("DA3_QTDEIX"),PesqPict("DA3", "DA3_QTDEIX") })
	aAdd(aDA3TT,{ "TMP_QTEIXV",TamSX3("DA3_QTEIXV")[3],TamSX3("DA3_QTEIXV")[1],TamSX3("DA3_QTEIXV")[2],OMSTITULO("DA3_QTEIXV"),PesqPict("DA3", "DA3_QTEIXV") })
Return aDA3TT

/*/{Protheus.doc} TTPedCols
** Campos que aparecerao no browse
@author Equipe OMS
@since 25/08/2021
/*/
Static Function TTVeiCols(aStrVeic)
	Local nCol 			:= 0
	Local nX 			:= 0
	Local aColVeic 	:= {}
	Local cRemovCpo := "TMP_MARK,TMP_FILIAL"

	nCol := 1
	For nx := 1 to Len(aStrVeic)
		If !(aStrVeic[nX,1] $ cRemovCpo)
			AAdd(aColVeic,FWBrwColumn():New())
			aColVeic[nCol]:SetData(&("{||"+aStrVeic[nX,1]+"}"))
			aColVeic[nCol]:SetTitle(aStrVeic[nX,5])
			aColVeic[nCol]:SetPicture(aStrVeic[nX,6])
			aColVeic[nCol]:SetType(aStrVeic[nX,2])
			aColVeic[nCol]:SetSize(aStrVeic[nX,3])
			aColVeic[nCol]:SetReadVar(aStrVeic[nX,1])
			nCol++
		Endif
	Next nX
Return aColVeic


/*/{Protheus.doc} OMSTPRLeg
** Significado de cada cor da legenda
@author Equipe OMS
@since 25/08/2021
/*/
Static Function OMSTPRLeg(cTipo)
	Local oLegend  :=  FWLegend():New()

	If cTipo == "INTROT"
		oLegend:Add("","BR_BRANCO"  , STR0042 ) // "Não enviado"
		oLegend:Add("","BR_AMARELO" , STR0068 ) // Pendente
		oLegend:Add("","BR_VERMELHO", STR0069 ) // Rejeitado
		oLegend:Add("","BR_CANCEL"  , STR0070 ) // Falha de Integração
	ElseIf cTipo == "SITPED"
		oLegend:Add("","BR_VERDE"   , STR0071 ) // Pedido em Aberto
		oLegend:Add("","BR_AMARELO" , STR0072 ) // Pedido Liberado
	EndIf

	oLegend:Activate()
	oLegend:View()
	oLegend:DeActivate()

Return


/*/{Protheus.doc} StatusPed
** Define a cor para o status do pedido
@author Equipe OMS
@since 25/08/2021
/*/
Static Function StatusPed(cStatus)
Local cRetorno := ""
	If cStatus == '1' //Pedido em Aberto
		cRetorno := "BR_VERDE"
	ElseIf cStatus == '3' //Pedido Liberado
		cRetorno := "BR_AMARELO"
	EndIf
Return cRetorno


Static Function StatusInt(cStatus)
	Local cRetorno := ""

	If cStatus = '0'
		cRetorno := "BR_BRANCO"
	ElseIf cStatus = '1'
		cRetorno := "BR_AMARELO"
	ElseIf cStatus = '2'
		cRetorno := "BR_VERMELHO"
	ElseIf cStatus = '3'
		cRetorno := "BR_VERDE"
	ElseIf cStatus = '4'
		cRetorno := "BR_CANCEL"
	Else
		cRetorno := "BR_CINZA"
	EndIf

Return cRetorno


/*/{Protheus.doc} OMSTITULO
** Busca descricao do campo
@author Equipe OMS
@since 25/08/2021
/*/
Function OMSTITULO(cCampo)
    Local cTitLab := Space(12)
    cTitLab := FWX3Titulo(cCampo)
Return cTitLab

/*/{Protheus.doc} GeraTTBKP
** Gera bkp da TT de veiculos para caso o usuario cancele operacoes
@author Equipe OMS
@since 25/08/2021
/*/
Static Function GeraTTBKP(oObjTTBKP,oTTBKP,aStrBKP, cAliasBKP,oTTVei)
	Local aIndex := {}
	Local cQuery := ""

	aAdd(aIndex,"TMP_FILIAL+TMP_COD")
	oObjTTBKP := CriaTabTmp(aStrBKP,aIndex,@cAliasBKP,@oTTBKP)
	cQuery += " Select TMP_MARK,TMP_FILIAL,TMP_COD,TMP_PLACA,TMP_VEIDES,TMP_TIPVEI,TMP_TIPDES,TMP_PESO,TMP_VOL,TMP_VELOC,TMP_QTDEIX,TMP_QTEIXV FROM "+oTTVei:GetRealName()

	WmsQry2Tmp(@cAliasBKP,oTTVei:oStruct:aFields,cQuery,@oTTBKP,,.T.)
Return cAliasBKP

Function OMSVeiTPR()
	Local oBrowseVei
	Local aCords      := FWGetDialogSize( oMainWnd )
	Local oFWL
	Local oPnlWnd1
	Local oPnlWnd2
	Local oSize1
	Local oSize2
	Local aStrVeic 	:= TTVeiStrut() 
	Local aColVeic
	Local cAliasBkp
	Local oGetPedKg
	Local oGetPedVol
	Local oGetQtdV
	Local oGetTKg
	Local oGetTVol
	Local nPedKg
	Local nPedVol
	Local nQtdVeiBKP := nQtdVei
	Local nTotalKBKP := nTotalKg
	Local nTotalVBKP := nTotalVol

	Local nLinha  := 1
	Local nColuna := 1

	If (cAliasVEI)->( Eof() )
		TTVeiData() 
	EndIf

	//Totalizadores de Pedido KG e Pedido Volume
	OMSMkPedKg(@nPedKg, @nPedVol)

	cAliasBKP := GetNextAlias()
	cAliasBKP := GeraTTBKP(oObjTTBKP,@oTTBKP,aStrVeic, cAliasBKP,oTTVei)

	DEFINE DIALOG oDlg TITLE STR0002 FROM aCords[ 1 ], aCords[ 2 ] TO (aCords[3]*nLinha), (aCords[ 4 ]*nColuna) PIXEL //"Veículos"

	oDlg:lEscClose := .F.

	// Instancia o layer
	oFWL := FWLayer():New()
	// Inicia o Layer
	oFWL:init( oDlg, .F. )
	// Cria uma linha unica para o Layer
	oFWL:addLine( 'TOTAL', 90 , .F.)

	// Cria colunas
	oFWL:addCollumn( 'DIR', 100, .F., 'TOTAL' )
	
	oFWL:addWindow( 'DIR' , 'Wnd1', STR0024    ,  80, .F., .T.,, 'TOTAL' ) //"Veículos Cadastrados"
	oFWL:addWindow( 'DIR' , 'Wnd2', STR0025    ,  20, .F., .T.,, 'TOTAL' ) //"Totais para o planejamento"

    oPnlWnd1:= oFWL:getWinPanel( 'DIR', 'Wnd1', 'TOTAL' )
	oPnlWnd2:= oFWL:getWinPanel( 'DIR', 'Wnd2', 'TOTAL' )

    //- Recupera coordenadas da area superior da linha e coluna a direita do container
    oSize1 := FWDefSize():New(.F.)
    oSize1:AddObject('SUPER',100,100,.T.,.T.)
    oSize1:SetWindowSize({0,0,oPnlWnd1:NHEIGHT,oPnlWnd1:NWIDTH})
    oSize1:lProp     := .T.
    oSize1:aMargins := {0,0,0,0}
    oSize1:Process()

	    //- Recupera coordenadas da area superior da linha e coluna a direita do container
    oSize2 := FWDefSize():New(.F.)
    oSize2:AddObject('SUPER',100,100,.T.,.T.)
    oSize2:SetWindowSize({0,0,oPnlWnd2:NHEIGHT,oPnlWnd2:NWIDTH})
    oSize2:lProp     := .T.
    oSize2:aMargins := {0,0,0,0}
    oSize2:Process()

	@001, 005 Say STR0026	 SIZE 80, 07 	Of oPnlWnd2 Pixel   //"Pedidos Kg"
	@009, 05 MSGET oGetPedKg  VAR nPedKg    PICTURE "@E 999,999,999.99" When .F. SIZE 60, 10	Of oPnlWnd2 Pixel
	@001, 080 Say STR0027	 SIZE 80, 07 	Of oPnlWnd2 Pixel //"Pedidos Vol."
	@009, 080 MSGET oGetPedVol  VAR nPedVol PICTURE PesqPict("SB5", "B5_ALTURLC") When .F. SIZE 60, 10	Of oPnlWnd2 Pixel


	@001, 160 Say STR0028	 SIZE 80, 07 	Of oPnlWnd2 Pixel //"Qtd Veiculos"
	@009, 160 MSGET oGetQtdV  VAR nQtdVei   When .F. SIZE 60, 10	Of oPnlWnd2 Pixel
	@001, 240 Say STR0029	 SIZE 80, 07 	Of oPnlWnd2 Pixel    //"Capacid Kg"
	@009, 240 MSGET oGetTKg  VAR nTotalKg   PICTURE "@E 999,999,999.99" When .F. SIZE 60, 10	Of oPnlWnd2 Pixel
	@001, 320 Say STR0030	 SIZE 80, 07 	Of oPnlWnd2 Pixel    //"Capacid Vol"
	@009, 320 MSGET oGetTVol  VAR nTotalVol PICTURE PesqPict("DA3", "DA3_VOLMAX") When .F. SIZE 60, 10	Of oPnlWnd2 Pixel

	aColVeic 	:= TTVeiCols(aStrVeic)

    oBrowseVei := fwBrowse():New()
	oBrowseVei:SetOwner(oPnlWnd1)
	oBrowseVei:SetDataTable(.T.)
    oBrowseVei:disableConfig()
    oBrowseVei:disableReport()
 	oBrowseVei:SetAlias(cAliasVEI)
    oBrowseVei:SetLocate() 
    oBrowseVei:AddMarkColumns({|| IIF(!Empty((cAliasVEI)->TMP_MARK), "LBOK", "LBNO")}, {|| TPRLine(@oBrowseVei,@oGetQtdV,@nQtdVei,@oGetTKg,@nTotalKg,@oGetTVol,@nTotalVol)}, {|| TPRAll(@oBrowseVei,@oGetQtdV,@nQtdVei,@oGetTKg,@nTotalKg,@oGetTVol,@nTotalVol)}) //Code-Block Header Click
 	oBrowseVei:SetColumns(aColVeic)
    oBrowseVei:setEditCell( .T. , { || .T. } ) 
   	oBrowseVei:acolumns[10]:ledit := .t.
	oBrowseVei:acolumns[11]:ledit := .t. 
    oBrowseVei:Activate(.T.)

    ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg, { || OMSTPR1Con(cAliasVei), oDlg:End() }, ;
	{ ||  OMSTPR1Can(@oTTBKP,oTTVei,aStrVeic,cAliasVei,nQtdVeiBKP,nTotalKBKP,nTotalVBKP) ,oDlg:End() },,,,,,,.F.) CENTERED

return

/*/{Protheus.doc} OMSTPR1Can
** Volta bkp da tt pois o usuario cancelou operacao
@author Equipe OMS
@since 30/08/2021
/*/
Static Function OMSTPR1Con(cAliasVei)
	DelTabTmp(cAliasBKP,oObjTTBKP)
Return

/*/{Protheus.doc} OMSTPR1Can
** Volta bkp da tt pois o usuario cancelou operacao
@author Equipe OMS
@since 30/08/2021
/*/
Static Function OMSTPR1Can(oTTBKP,oTTVei,aStrVeic,cAliasVei,nQtdVeiBKP,nTotalKBKP,nTotalVBKP)
	Local cQuery := ""
	nQtdVei   := nQtdVeiBKP
	nTotalKg  := nTotalKBKP
	nTotalVol := nTotalVBKP

	cQuery +=   " Select TMP_MARK,TMP_FILIAL,TMP_COD,TMP_PLACA,TMP_VEIDES,TMP_TIPVEI,TMP_TIPDES,TMP_PESO,TMP_VOL,TMP_VELOC,TMP_QTDEIX,TMP_QTEIXV FROM "+oTTBKP:GetRealName()

 	WmsQry2Tmp(cAliasVei,aStrVeic,cQuery,oTTVei,.F.,.T.)
	DelTabTmp(cAliasBKP,oObjTTBKP)
Return

/*/{Protheus.doc} TPRLine
** Ao marcar uma linha dos veiculos, atualiza marcadores e os campos de totalizadores
@author Equipe OMS
@since 13/09/2021
/*/
Static Function TPRLine(oBrowseVei,oGetQtdV,nQtdVei,oGetTKg,nTotalKg,oGetTVol,nTotalVol)

	If Empty((cAliasVEI)->TMP_MARK )
		(cAliasVEI)->TMP_MARK := cMarca

		nQtdVei   +=1
		nTotalKg  +=(cAliasVEI)->TMP_PESO
		nTotalVol +=(cAliasVEI)->TMP_VOL
	else
		(cAliasVEI)->TMP_MARK := ""

		nQtdVei -=1
		nTotalKg  -=(cAliasVEI)->TMP_PESO
		nTotalVol -=(cAliasVEI)->TMP_VOL
	EndIf

	// nQtdVei   := IIf((cAliasVEI)->TMP_MARK == cMarca,                    ,)
	// nTotalKg  := IIf((cAliasVEI)->TMP_MARK == cMarca,,)
	// nTotalVol := IIf((cAliasVEI)->TMP_MARK == cMarca,, )
	oGetQtdV:Refresh(.T.)
	oGetTKg:Refresh(.T.)
	oGetTVol:Refresh(.T.)
Return .T.


/*/{Protheus.doc} TPRAll
** Ao marcar todos os veiculos, atualiza marcadores e os campos de totalizadores
@author Equipe OMS
@since 13/09/2021
/*/
Static Function TPRAll(oBrowseVei,oGetQtdV,nQtdVei,oGetTKg,nTotalKg,oGetTVol,nTotalVol)
	Local aAreaTmp  := (cAliasVEI)->(GetArea())
	Local cAliasBrw := ""
	Local cMark     := ""
	lMarkAll := !lMarkAll
	cMark    := Iif(lMarkAll,cMarca, space(2))
	// Busca alias do próprio browse, que neste caso é cAliasPED
	cAliasBrw := oBrowseVei:Alias()
	// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
	// a regra de marcação será executada apenas para os registros que o usuário vê em tela
	(cAliasBrw)->(DbGoTop())
	While (cAliasBrw)->(!Eof())
		If (cAliasVEI)->TMP_MARK != cMark
			nQtdVei   := IIf(lMarkAll,nQtdVei   +=1                    ,nQtdVei -=1)
			nTotalKg  := IIf(lMarkAll,nTotalKg  +=(cAliasVEI)->TMP_PESO,nTotalKg  -=(cAliasVEI)->TMP_PESO)
			nTotalVol := IIf(lMarkAll,nTotalVol +=(cAliasVEI)->TMP_VOL , nTotalVol -=(cAliasVEI)->TMP_VOL)
		EndIf
		Reclock(cAliasVEI,.F.)
		(cAliasVEI)->TMP_MARK := cMark
		(cAliasVEI)->(MsUnlock())
		(cAliasBrw)->(DbSkip())
	EndDo
	RestArea(aAreaTmp)
	oGetQtdV:Refresh(.T.)
	oGetTKg:Refresh(.T.)
	oGetTVol:Refresh(.T.)
	oBrowseVei:Refresh()
Return




/*/{Protheus.doc} OMSMkPedKg
** Soma de KG dos pedidos marcados. Usado na tela de Veiculos
@author Equipe OMS
@since 25/08/2021
/*/
Static Function OMSMkPedKg(nPedKg, nPedVol)
	Local cQuery := ""
	Local cAliasQry := ""
	Default nPedKg := 0
	Default nPedVol := 0
	cQuery := "SELECT SUM(TMP_PESOBR) AS TMP_PESOBR, SUM(TMP_VOL) AS TMP_VOL FROM  "+ oTTPed:GetRealName()+" TMP"
	cQuery += 	" WHERE TMP.TMP_MARK   = '"+oBrowse:Mark()+"'"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	(cAliasQry)->( dbGoTop() )
	If !(cAliasQry)->( Eof() )
		nPedKg := (cAliasQry)->TMP_PESOBR
		nPedVol := (cAliasQry)->TMP_VOL
	EndIf
	(cAliasQry)->(DbCloseArea())
Return


/*/{Protheus.doc} OMSEnvTPR
** Envia Pedidos para integracao
@author Equipe OMS
@since 25/08/2021
/*/
Function OMSEnvTPR()
	Local aErrors := {}
	Local lRet 	  := .F.

	lRet := OMSPedMark() //Validar se tem pedido marcado
	If lRet
		lRet := OMSVeiMark()//Validar se tem veiculo marcado
	EndIf
	If lRet
		lRet := OMSPedGrao()//Validar se tem pedido do tipo grao e critério de integração como diferente de peso
	EndIf
	If lRet
		Pergunte("OMSATPR1A",.F.)
		lRet := OMSATPR1A(@aErrors,oTTPed,oTTVei,oBrowse, cAliasPED, cMarca, nTipoTela)

		If !lRet .And. !Empty(aErrors)
			Aadd(aErrors, STR0075)//"Os pedidos não foram enviados para o TPR."
			Aadd(aErrors, STR0076)//"Verifique as inconsistências."
		EndIf

		Pergunte("OMSATPR1",.F.)
	EndIf
	If !lRet .And. !Empty(aErrors)
		OmsShowWng(aErrors)
	EndIf

	If lRet
		FwMsgRun(,{|| RefrConf(@oBrowse) }, STR0041, STR0004) //"Aguarde"Atualizando
	EndIf

Return

/*/{Protheus.doc} OMSPedMark
** Valida se existe pedido veiculo marcado para poder iniciar o processo de roteirização
@author Equipe OMS
@since 14/09/2021
/*/
Static Function OMSPedMark(aErrors)
	Local lRet 		:= .T.
	Local cQuery := ""
	Local cAliasQry := ""
	cQuery := "SELECT TMP_MARK FROM  "+ oTTPed:GetRealName()+" TMP"
	cQuery += 	" WHERE TMP.TMP_MARK   = '"+oBrowse:Mark()+"'"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	(cAliasQry)->( dbGoTop() )
	If (cAliasQry)->( Eof() )
		MsgAlert(STR0036)//"Nenhum pedido marcado para o Planejamento de Rotas."
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
Return lRet


/*/{Protheus.doc} OMSPedGrao
** Se existem itens do tipo grao, o tipo do calculo devera ser PESO
@author Equipe OMS
@since 20/09/2021
/*/
Static Function OMSPedGrao(aErrors)
	Local lRet 		:= .T.
	Local cQuery := ""
	Local cAliasQry := ""

	Pergunte("OMSATPR1A",.F.)
	cQuery := "SELECT TMP.TMP_FILIAL,TMP.TMP_PEDIDO,"
	If nTipoTela = 2
		cQuery += " TMP.TMP_ITEM,TMP.TMP_SEQUEN,"
	EndIf
	cQuery += " SC9.C9_PRODUTO FROM  "+ oTTPed:GetRealName()+" TMP"
	cQuery += 		" INNER JOIN " + RetSqlName("SC9") + " SC9 ON (SC9.C9_FILIAL = TMP.TMP_FILIAL"
	cQuery += 		" AND SC9.C9_PEDIDO = TMP.TMP_PEDIDO"
	If nTipoTela = 2
		cQuery += 		" AND SC9.C9_ITEM = TMP.TMP_ITEM"
		cQuery += 		" AND SC9.C9_SEQUEN = TMP.TMP_SEQUEN"
		cQuery += 		" AND SC9.C9_PRODUTO = TMP.TMP_CODPRO"
	EndIf
	cQuery += 		" AND SC9.D_E_L_E_T_ = ' ')"
	cQuery +=  		" INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + FwxFilial("SB1") + "'"
	cQuery +=  			" AND SB1.B1_COD = SC9.C9_PRODUTO"
	cQuery +=  			" AND SB1.D_E_L_E_T_ = ' '"
	cQuery +=  		" LEFT JOIN " + RetSqlName("SB5") + " SB5 ON SB5.B5_FILIAL = '" + FwxFilial("SB5") + "'"
	cQuery +=  			" AND SB5.B5_COD = SB1.B1_COD"
	cQuery +=  			" AND SB5.D_E_L_E_T_ = ' '"
	cQuery += 	" WHERE TMP.TMP_MARK  = '"+oBrowse:Mark()+"'"
	cQuery += 	" AND SB5.B5_TIPUNIT = '1'"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	(cAliasQry)->( dbGoTop() ) 
	If !(cAliasQry)->( Eof() ) .And. MV_PAR01 != 1
		MsgAlert(STR0067)//"Existem pedidos do tipo grãos (B5_TIPUNIT = '1') e o critério da capacidade não está parametrizado como peso. Verifique os parâmetros de integração (F6)."
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
	Pergunte("OMSATPR1",.F.)
Return lRet


/*/{Protheus.doc} OMSVeiMark
** Valida se existe algum veiculo marcado para poder iniciar o processo de roteirização
@author Equipe OMS
@since 14/09/2021
/*/
Static Function OMSVeiMark()
	Local lRet 		:= .T.
	Local cQuery := ""
	Local cAliasQry := ""
	cQuery := "SELECT TMP_MARK FROM  "+ oTTVei:GetRealName()+" TMP"
	cQuery += 	" WHERE TMP.TMP_MARK  = '"+cMarca+"'"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	(cAliasQry)->( dbGoTop() )
	If (cAliasQry)->( Eof() )
		MsgAlert(STR0035)// "Nenhum veículo selecionado para o Planejamento de Rotas."
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
Return lRet


/*/{Protheus.doc} OMSCanTPR
** Exclusão de todos os itens de uma requisição de roteirização. Tabela DMS.
O usuario só consegue usar caso ocorra problemas de roteirização.
@author Equipe OMS
@since 14/09/2021
/*/
Function OMSCanTPR()
	Local aDoctosDMS := {}
	Local cQuery := ""
	Local cAliasQry := ""
	Local aErrors := {}
	Local lRet := .T.
	Local aDoctosDMR := {}
	Local nX := 0
	Local nY := 0
	Local cIdRot := ""
	Local cCHVDMR := ""
	Local cCHVDMS := ""
	Local cCHVStat := ""
	Local cOperMais  := IIf(Upper(TcGetDb())$'ORACLE.POSTGRES.DB2.INFORMIX','||','+')
	Local nTamC9Fil := TamSX3('C9_FILIAL')[1]
	Local nTamC9Ped := TamSX3('C9_PEDIDO')[1]
	Local nTamC9Ite := TamSX3('C9_ITEM')[1]
	Local nTamC9Seq := TamSX3('C9_SEQUEN')[1]
	Local nTamC9Prd := TamSX3('C9_PRODUTO')[1]

	cQuery := " SELECT TMP.TMP_MARK"
	cQuery += 		" FROM  "+ oTTPed:GetRealName()+" TMP"
	cQuery += 		" WHERE TMP.TMP_MARK   = '"+oBrowse:Mark()+"'"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	(cAliasQry)->( dbGoTop() )
	If  (cAliasQry)->( Eof() )
		lRet := .F.
		Aadd(aErrors, STR0093)//"Nenhum registro marcado para exclusão do planejamento."
	EndIf
	(cAliasQry)->(DbCloseArea())

	If lRet
		cQuery := " SELECT TMP.TMP_FILIAL,TMP.TMP_PEDIDO,"
		If nTipoTela = 2
			cQuery += " TMP.TMP_ITEM,TMP.TMP_SEQUEN,TMP.TMP_CODPRO,"
		EndIf
		cQuery += " TMP.TMP_STINT AS STATUS
		cQuery += 		" FROM  "+ oTTPed:GetRealName()+" TMP"
		cQuery += 		" WHERE TMP.TMP_MARK   = '"+oBrowse:Mark()+"'"
		cQuery += 		" AND (TMP.TMP_STINT <> '2' AND TMP.TMP_STINT <> '4')"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		(cAliasQry)->( dbGoTop() )
		If  !(cAliasQry)->( Eof() )
			Aadd(aErrors, STR0038)//"Não foi possível realizar a exclusão. Motivos:"
			While !(cAliasQry)->( Eof() )
				lRet := .F.
				Aadd(aErrors, STR0040 + (cAliasQry)->TMP_PEDIDO + IIF(nTipoTela=2, ", " + STR0009 +":" + (cAliasQry)->TMP_ITEM+ ", " +  STR0010+":" + (cAliasQry)->TMP_SEQUEN+;
							", " +  STR0015+":" + AllTrim((cAliasQry)->TMP_CODPRO),"") + STR0039 +   IIF((cAliasQry)->STATUS == "0",STR0042,X3CboxDesc( "DMS_STATUS", (cAliasQry)->STATUS ))+".")
				//"Pedido: "" Item: "" Seq. Liberação: "" Produto: "" possui status " STR0042
			(cAliasQry)->( dbSkip() )
			EndDo
		EndIf
		(cAliasQry)->(DbCloseArea())

		If lRet
			If nTipoTela = 1
				//"Ao selecionar visualização por pedidos e solicitar a exclusão, 
				//todos os itens do pedido marcado serão eliminados do histórico de integração. Confirma?"
				lRet := MsgYesNo(STR0037)
			EndIf
			If lRet

				cQuery := " SELECT SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_SEQUEN,SC9.C9_PRODUTO,"
				cQuery += " SC9.C9_FILIAL"+cOperMais+"SC9.C9_PEDIDO"+cOperMais+"SC9.C9_ITEM"+cOperMais+"SC9.C9_SEQUEN"+cOperMais+"SC9.C9_PRODUTO AS CHAVE,"
				cQuery += " DMS.DMS_FILIAL"+cOperMais+"DMS.DMS_FILROT"+cOperMais+"DMS.DMS_IDROT AS CHAVEDMR, TMP.TMP_STINT AS STATUS"
				cQuery += 		" FROM  "+ oTTPed:GetRealName()+" TMP"
				cQuery += 		" INNER JOIN " + RetSqlName("SC9") + " SC9 ON (SC9.C9_FILIAL = TMP.TMP_FILIAL"
				cQuery += 		" AND SC9.C9_PEDIDO = TMP.TMP_PEDIDO"
				cQuery += 		" AND SC9.D_E_L_E_T_ = ' ')"
				cQuery += 		" INNER JOIN  " + RetSqlName("DMS") + " DMS ON (DMS.DMS_FILROT = SC9.C9_FILIAL"
				cQuery += 		" AND DMS.DMS_ENTIDA = 'SC9'"
				cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,1,"+cValtoChar(nTamC9Fil)+") = SC9.C9_FILIAL"
				cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+1)+","+cValtoChar(nTamC9Ped)+") = SC9.C9_PEDIDO"		
				cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+1)+","+cValtoChar(nTamC9Ite)+") = SC9.C9_ITEM"			
				cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+1)+","+cValtoChar(nTamC9Seq)+") = SC9.C9_SEQUEN"
				cQuery += 			" AND SUBSTRING(DMS.DMS_CHVENT,"+cValtoChar(nTamC9Fil+nTamC9Ped+nTamC9Ite+nTamC9Seq+1)+","+cValtoChar(nTamC9Prd)+") = SC9.C9_PRODUTO"
				cQuery += 		" AND DMS.D_E_L_E_T_ = ' '"
				cQuery += 		" AND DMS.DMS_STATUS = TMP.TMP_STINT"
				cQuery += 		" AND (DMS.DMS_STATUS = '2' OR DMS.DMS_STATUS = '4'))"
				cQuery += 		" INNER JOIN " + RetSqlName("DMR") + " DMR ON (DMR.DMR_FILIAL = DMS.DMS_FILIAL "
				cQuery += 		" AND DMR.DMR_FILROT = DMS.DMS_FILROT "
				cQuery += 		" AND DMR.DMR_IDROT = DMS.DMS_IDROT"
				cQuery += 		" AND DMR.D_E_L_E_T_ = ' ' )"
				cQuery += 		" WHERE TMP.TMP_MARK   = '"+oBrowse:Mark()+"'"
				cQuery += 		" AND (SC9.C9_BLEST = ' '"
				cQuery += 		" AND SC9.C9_BLCRED = ' ')"
				cQuery := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
				(cAliasQry)->( dbGoTop() )
				While !(cAliasQry)->( Eof() )
					If cIdRot != (cAliasQry)->CHAVEDMR
						nX+= 1
						cIdRot := (cAliasQry)->CHAVEDMR	
						Aadd(aDoctosDMR, {(cAliasQry)->CHAVEDMR})
						aDoctosDMS := {(cAliasQry)->CHAVE,(cAliasQry)->STATUS}
						Aadd(aDoctosDMR[nX], aDoctosDMS)
					else
						aDoctosDMS := {(cAliasQry)->CHAVE,(cAliasQry)->STATUS}
						Aadd(aDoctosDMR[nX], aDoctosDMS)
					EndIf
					(cAliasQry)->( dbSkip() )
				EndDo
				(cAliasQry)->(DbCloseArea())

				For nX := 1 To Len(aDoctosDMR)
					DMR->(DbSetOrder(1))
					cCHVDMR := aDoctosDMR[nX][1]
					If DMR->(DbSeek(cCHVDMR))

						oModel := FWLoadModel( 'TMSAC19' )
						oModel:SetOperation( 4 )
						oModel:Activate()

						oMdFldDMR:= oModel:GetModel("MdFieldDMR")
						oMdGrdDMS:= oModel:GetModel("MdGridDMS")

						For nY := 1 To Len(aDoctosDMR[nX])
							If nY == 1
								Loop
							EndIf
							cCHVDMS := aDoctosDMR[nX][nY][1]
							cCHVStat := aDoctosDMR[nX][nY][2]
							oMdGrdDMS:SeekLine({{"DMS_IDROT",cCHVDMR},{"DMS_ENTIDA",'SC9'},{"DMS_CHVENT",cCHVDMS},{"DMS_STATUS",cCHVStat}})
							oMdGrdDMS:DeleteLine()
						Next nY
						lRet := oModel:VldData()
						If lRet 
							oModel:CommitData()
						Else
							Aadd(aErrors,  oModel:GetErrorMessage()[6] )
						EndIf
						oModel:Destroy()
						oModel:= Nil	
					EndIf

					//Se excluir todas as linhas da DMS, excluir também o planejamento.
					DMS->(DbSetOrder(1))
					If !DMS->(DbSeek(cCHVDMR))
						DMR->(DbSetOrder(1))
						If DMR->(DbSeek(cCHVDMR))
							oModel := FWLoadModel( 'TMSAC19' )
							oModel:SetOperation( 5 )
							oModel:Activate()
							lRet := oModel:VldData()
							If lRet 
								oModel:CommitData()
							Else
								Aadd(aErrors,  oModel:GetErrorMessage()[6] )
							EndIf
							oModel:Destroy()
							oModel:= Nil	
						EndIf
					EndIf
				Next nX
			EndIf
		EndIf
	EndIf
	If lRet
		FwMsgRun(,{|| RefrConf(@oBrowse) }, STR0041, STR0004) // "Atualizando...""Aguarde"
	Else
		OmsShowWng(aErrors)
	EndIf

Return

