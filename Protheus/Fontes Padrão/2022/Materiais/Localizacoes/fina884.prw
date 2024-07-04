#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
// #INCLUDE "FINA884.CH"
#INCLUDE "FINA884.CH"

//Constantes
#Define CLR_AZUL      RGB(058,074,119)                                  //Cor Azul

//Variaveis
Static COL_T1   := 001              //Primeira Coluna da tela
Static COL_T2   := 123              //Segunda Coluna da tela
Static COL_T3   := 245              //Terceira Coluna da tela
Static COL_T4   := 367              //Quarta Coluna da tela
Static ESP_CAMPO    := 038              //EspaÁamento do campo para coluna
Static TAM_FILIAL   := FWSizeFilial()   //Tamanho do campo Filial

/*/
GREEN	Para a cor Verde
RED    	Para a cor Vermelha
YELLOW 	Para a cor Amarela
ORANGE 	Para a cor Laranja
BLUE   	Para a cor Azul
GRAY   	Para a cor Cinza
BROWN  	Para a cor Marrom
BLACK  	Para a cor Preta
PINK   	Para a cor Rosa
WHITE  	Para a cor Branca
/*/
/*/{Protheus.doc} FINA884
IntegraciÛn Plaid
@type
@author mayra.camargo
@since 25/01/2019
@version 1.0
/*/

Function FINA884()
	Local oBrowse		:= Nil
	Local cFilSZ1QRY	:= ""
	Local lPrcPLAID 	:= SuperGetMv("MV_PLINTOL",.F.,.F.)
	Local cOpcPLAID 	:= SuperGetMv("MV_PLDASPO",.F.,"3")//1-Dashboard PO,2-Perguntar,3=Nao mostrar PO
	Local lShowPlaid    :=.F.

	Private aRotina		:= MenuDef() 			// ALTERADO PARA SIGA
	Private cCadastro	:= OemtoAnsi(STR0011)	//"PLAID INTEGRATION"
	Private cParam3		:= ""
	Private cParam4		:= ""
	Private cParam5		:= ""
	Private aRecSel		:= {}

	If (Pergunte("FINRVS",.T.))

		cParam3 := MV_PAR03
		cParam4 := MV_PAR04
		cParam5 := MV_PAR05



		If cOpcPLAID=="1"
			lShowPlaid:=.T.
		ElseIf cOpcPLAID=="2"
			lShowPlaid:=MsgYesNo("Open PO UI dashboard?")
		Endif

		
		If lPrcPLAID
			Processa( {|| SchMovPLAID(lShowPlaid)} )
		EndIf

		If lShowPlaid
			A884PO()
		Else
			// Instanciamento da Classe de Browse
			oBrowse := FWMBrowse():New()

			// DefiniÁ„o da tabela do Browse
			oBrowse:SetAlias('RVS')

			// DefiniÁ„o da legenda
			oBrowse:AddLegend( "RVS_STATUS==9", "GREEN"   	, STR0024 ) //"Cuentas por Pagar"   Payments
			oBrowse:AddLegend( "RVS_STATUS==1", "YELLOW"	, STR0027 ) // "Cuentas por Cobrar"  Accounts receivable
			oBrowse:AddLegend( "RVS_STATUS==2", "BLUE"  	, STR0026 ) //"RelaciÛn Incompleta"
			oBrowse:AddLegend( "RVS_STATUS==0", "RED"   	, STR0025 ) //"RelaciÛn Completa"

			SetKey( VK_F12 ,{|| Pergunte("FINRVS",.T.)},)

			cFilSZ1QRY := "RVS_FILIAL == '" + xFilial('RVS') + "' .AND. RVS_COD == '" + MV_PAR03 + "' .AND. RVS_AGENCIA == '" + MV_PAR04 + "' .AND. RVS_NUMCON == '"  + MV_PAR05 +  "' .AND. dtos(RVS_DATA) >= '" + Dtos(MV_PAR01)+ "' .AND. dtos(RVS_DATA) <= '" + Dtos(MV_PAR02)+ "' "// + xFilial('SZH') + "'" // .And.  DTOS(RVS_DATA) == '"+Dtos(MV_PAR01)+"' "

			If MV_PAR06 = 1
				cFilSZ1QRY += " .AND. RVS_VALDEB > 0 "
			ElseIf MV_PAR06 = 2
				cFilSZ1QRY += " .AND. RVS_VALCRE > 0 "
			EndIf

			oBrowse:SetFilterDefault( cFilSZ1QRY)
			// Titulo da Browse
			oBrowse:SetDescription(STR0049) // 'Moviment PLAID'
			// AtivaÁ„o da Classe
			oBrowse:Activate()
			SetKey(VK_F12,Nil)
		EndIf
	EndIf

Return NIL

/*/{Protheus.doc} SchMovPLAID
Obtiene los movimientos plaid de las tablas correspondientes.
@type
@author mayra.camargo
@since 25/01/2019
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SchMovPLAID(lShowPlaid)

	Local lValid 		:= .T.
	Local nX 			:= 0
	Local nW 			:= 0
	Local nY 			:= 0
	Local dStart		:= CTOD(' / / ')
	Local dEnd			:= CTOD(' / / ')
	Local nQuantTrans 	:= 0
	Local cCodeBank 	:= ""
	Local cNumMov 		:= ""
	Local cDataOrig   	:= ""
	Local cDataorig1 	:= ""
	Local cDataMov		:= ""
	Local cValorMov		:= ""
	Local nValorMov   	:= 0
	Local cTipoMov		:= ""
	Local cDescMov 		:= ""
	Local cDebCred		:= ""
	Local cDescrMov		:= ""
	Local cAgencia		:= ""
	Local cConta		:= ""
	Local nTamIdPLAID 	:= TamSX3("RVS_IDPLAID")[1]
	Local lNewReg 		:= .T.
	Local nTamSeq		:= TamSX3("RVT_ITEM")[1]
	Local cSequencia 	:= Replicate("0",nTamSeq)
	Local cAliasSE1 	:= GetNextAlias()
	Local cAliasSE5 	:= GetNextAlias()
	Local cAliasSE2 	:= GetNextAlias()
	Local aRecNSel 		:= {}
	Local aRecSSel 		:= {}
	Local cNumRVS 		:= ""
	Local nValMov 		:= 0
	Local nTamTipo 		:= TamSX3("RVT_TIPO")[1]
	Local oConnection	:= Nil
	Local cAccessToken 	:=""
	Local nQuantAccounts:= 0
	Local oLista 		:= Nil
	Local nI 			:= 0
	Local nLine 		:= 0
	Local xBank 		:= ""
	Local dRanDiaIni 	:= CTOD(' / / ')
	Local lNexDate		:= .T.
	Local dRanDiaFin 	:= CTOD(' / / ')
	Local aRegPLAID		:= {}
	Local aArea 		:= getArea()
	Local cAliasRVS     := GetNextAlias()
	Local cFilSE2   := xFilial("SE2")
	Local cFilSA2   := xFilial("SA2")
	Local cFilSE5   := xFilial("SE5")
	Local cFilSE1   := xFilial("SE1")
	Local cFilSA1   := xFilial("SA1")
	Local cFilRVS	:=xFilial("RVS"),cNumId
	Private nSaveSX8 	:= GetSX8Len()
	Private aCols		:= {}
	Private aHeader  	:= {}

	//---------------------------------------------------------------------///
	//  1.0 - Check Ifthe access_code is valid
	//---------------------------------------------------------------------///

	Dbselectarea("RVR")
	RVR->(dbsetOrder(2)) // RVR_FILIAL + RVR_USERID
	If RVR->(MsSeek(xFilial("RVR")+mv_par03+mv_par04+mv_par05))
		cAccessToken := RVR->RVR_ATOKEN

		DbselectArea("SA6")
		SA6->(DbSetOrder(1))  // A6_FILIAL + A6_COD+A6_AGENCIA+A6_NUMCON
		If SA6->(MsSeek(xFilial("SA6")+mv_par03+mv_par04+mv_par05))

			If Empty(SA6->A6_BANKID)
				oConnection := PlaidReAcc(alltrim(cAccessToken))
				If Valtype(oConnection) <> "O"
					Return
				EndIf

				///-----------------------------------------------------------------//
				/// 3 - Connection for pick Accounts_ID up
				///----------------------------------------------------------------//

				nQuantAccounts 	:= len(oConnection:accounts)

				///-------------------------------------------------------------------------------------///
				/// 4 - Call screen to choose which account_ID is for this specific bank
				///------------------------------------------------------------------------------------///

				DEFINE MSDIALOG oAccount TITLE STR0051 FROM 000, 000  TO 300, 700  PIXEL // "Account Bank"
				// FIELDS FOR HEADER
				Aadd(aHeader, {"Mask","Mask","",06,0,"","","C","","R","","",""})
				Aadd(aHeader, {"Name","Name","",60,0,"","","C","","R","","",""})

				//CREATE BROWSE
				oLista := MsNewGetDados():New( 053, 078, 415, 775,, STR0050, STR0050, STR0050,,,, STR0050, "", STR0050, oAccount, aHeader, aCols) // "AllwaysTrue"

				//INSERT DATA INSIDE BROWSE
				For nI := 1 to nQuantAccounts
					aAdd(aCols,{AllTrim(oConnection:accounts[nI]:Mask),AllTrim(oConnection:accounts[nI]:name),AllTrim(oConnection:accounts[nI]:account_ID),.F.})
				Next
				oLista:SetArray(aCols,.T.)

				//REFRESH DATA IN BROWSE
				oLista:Refresh()

				// ALIGN THE GRID  OCCUPS ALL FORM
				oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

				//OPEN THE WINDOWS WITH FOCUS IN GRID
				oLista:oBrowse:SetFocus()
				EnchoiceBar(oAccount, {|| oAccount:End() }, {|| oAccount:End() },,)
				ACTIVATE MSDIALOG oAccount CENTERED

				nLine := oLista:nAt
				xBank := GDFieldGet("Mask",nLine)
				If nLine <> 0
					If RecLock("SA6",.F.)
						SA6->A6_BANKID := xBank
						MsUnlock()
					EndIf
				EndIf
			EndIf
		Else
			MsgInfo(OemToAnsi(STR0014),OemToAnsi(STR0012)) // "CÛdigo del Banco no existe en la base de datos."  "Aviso-SchMovPLAID"
			lValid := .F.
		EndIf
	Else
		MsgInfo(OemToAnsi(STR0014),OemToAnsi(STR0012))		// "CÛdigo del Banco no existe en la base de datos."  "Aviso-SchMovPLAID"
		lValid := .F.
		Return lValid
	EndIf

	//----------------------------------------------------------------
	// 2.1 - Connection with PLAID for pick transaction up
	//----------------------------------------------------------------

	dRanDiaIni := mv_par01
	lNexDate := .T.
	While lNexDate
		dRanDiaFin := dRanDiaIni + 15
		If dRanDiaFin < mv_par02
			dStart  := Substr(dtoc(dRanDiaIni),7,4)+"-"+Substr(dtoc(dRanDiaIni),1,2)+"-"+Substr(dtoc(dRanDiaIni),4,2)
			dEnd := Substr(dtoc(dRanDiaFin),7,4)+"-"+Substr(dtoc(dRanDiaFin),1,2)+"-"+Substr(dtoc(dRanDiaFin),4,2)
			dRanDiaIni := dRanDiaFin
		Else
			dStart  := Substr(dtoc(dRanDiaIni),7,4)+"-"+Substr(dtoc(dRanDiaIni),1,2)+"-"+Substr(dtoc(dRanDiaIni),4,2)
			dEnd := Substr(dtoc(mv_par02),7,4)+"-"+Substr(dtoc(mv_par02),1,2)+"-"+Substr(dtoc(mv_par02),4,2)
			lNexDate := .F.
		EndIf
		oTransactions :=  PlaidTrans(cAccessToken, dStart, dEnd)

		If	Valtype(oTransactions) <> "O"
			MsgInfo(OemToAnsi(STR0015),OemToAnsi(STR0012))  // "Sin conexiÛn de bancos, entre en contacto con el administrador."  "Aviso-SchMovPLAID"
			lValid := .F.
			Return lValid
		EndIf

		//-------------------------------------
		// 3.2 - Insert data in WorkArea
		//-------------------------------------
		ProcRegua(nQuantTrans)
		nQuantTrans 	:= len(oTransactions:transactions)

		For nY := 1 to len(oTransactions:accounts)
			IncProc("")
			If AllTrim(oTransactions:accounts[nY]:Mask) == AllTrim(SA6->A6_BANKID)
				cCodeBank := oTransactions:accounts[nY]:account_id
				For nX := 1 to nQuantTrans
					If AllTrim(oTransactions:transactions[nX]:account_id) == AllTrim(cCodeBank) .And. oTransactions:transactions[nX]:pending <> .T.
						cNumMov 	:=	 AllTrim(oTransactions:transactions[nX]:transaction_id)
						cDataOrig	:=  substr(oTransactions:transactions[nX]:date,6,2)+"/"+substr(oTransactions:transactions[nX]:date,9,2)+"/"+substr(oTransactions:transactions[nX]:date,1,4)
						nValorMov	:=	 oTransactions:transactions[nX]:amount
						cDescMov	:=  oTransactions:transactions[nX]:name
						cDataMov	:=  substr(oTransactions:transactions[nX]:date,1,4)+ substr(oTransactions:transactions[nX]:date,6,2)+substr(oTransactions:transactions[nX]:date,9,2)
						If aScan(aRegPLAID, { |x,y| x[2] == cNumMov }) == 0
							aadd(aRegPLAID,{cDataOrig,cNumMov,nValorMov,cDescMov,cDataMov})
						EndIf
					EndIf
				Next nX
			EndIf
		Next nY
	EndDo

	ASORT(aRegPLAID, , , { | x,y | x[1] < y[1] } )

	For nX := 1 to Len(aRegPLAID)
		IncProc("")
		cNumMov 	:=	aRegPLAID[nX,2]
		cDataOrig	:=  aRegPLAID[nX,1]
		cDataorig1	:=  Ctod( cDataOrig)
		cDataMov	:=  dtoc(cDataorig1)
		cValorMov	:=	IIF( aRegPLAID[nX,3] < 0,Transform(aRegPLAID[nX,3] * -1,"@E 999999999999.99"),Transform(aRegPLAID[nX,3],"@E 999999999999.99"))
		cTipoMov	:=  STR0048  // "Type of Moviment"
		cDescMov 	:= 	aRegPLAID[nX,4]
		cDebCred	:=	IIF(aRegPLAID[nX,3] > 0, "3","4")
		cDescrMov	:= 	aRegPLAID[nX,4]
		cAgencia	:=	SA6->A6_AGENCIA
		cConta		:=	SA6->A6_NUMCON
		cNumMov 	:=  AllTrim(cNumMov) + space(nTamIdPLAID - len(AllTrim(cNumMov)))
		lNewReg 	:=  .T.
		cDataOrig	:=  aRegPLAID[nX,5]
		nValMov 	:=  val(cValorMov)

		BeginSql alias cAliasRVS
			SELECT RVS_IDPLAI,RVS_DESCRI,RVS_VALDEB,RVS_VALCRE,RVS_DATA
			FROM %table:RVS% RVS    
			WHERE RVS.RVS_FILIAL = %xFilial:RVS%
				AND RVS.RVS_COD = %exp:cParam3%
				AND RVS.RVS_AGENCI = %exp:cParam4% 
				AND RVS.RVS_NUMCON = %exp:cParam5%
				AND RVS.RVS_IDPLAI = %exp:cNumMov%
				AND RVS.%notDel% 													
		EndSql

		cDescMov:=Left(cDescMov,250)
		While (cAliasRVS)->( !Eof())
			If AllTrim((cAliasRVS)->RVS_DESCRI) == AllTrim(cDescMov) ;
					.and. ((cAliasRVS)->RVS_VALDEB == val(cValorMov) .or. (cAliasRVS)->RVS_VALCRE == val(cValorMov));
					.and. (cAliasRVS)->RVS_DATA == cDataOrig
				lNewReg := .F.
			EndIf
			(cAliasRVS)->( DbSkip() )
		EndDo
		(cAliasRVS)->(DbCloseArea())

		If lNewReg .AND. nValMov <> 0
			cNumId:=GETSXENUM("RVS","RVS_ID")
			RVS->(DbSetOrder(1))
			Do While RVS->(DbSeek(cFilRVS+cNumId ))
				ConfirmSX8()
				cNumId:=GETSXENUM("RVS","RVS_ID")
			EndDo

			If RecLock("RVS",.T.)
				RVS->RVS_FILIAL		:= xFilial("RVS")
				RVS->RVS_ID			:= cNumId
				RVS->RVS_DATA		:= cDataorig1
				RVS->RVS_DESCRI		:= cDescMov
				RVS->RVS_CATEGORY	:= cDebCred
				RVS->RVS_VALDEB		:= IIF(cDebCred == "3",nValMov,0)
				RVS->RVS_VALCRE		:= IIF(cDebCred == "4",nValMov,0)
				RVS->RVS_COD		:= SA6->A6_COD
				RVS->RVS_AGENCI		:= SA6->A6_AGENCIA
				RVS->RVS_NUMCON		:= SA6->A6_NUMCON
				RVS->RVS_NOMEAGE	:= SA6->A6_NOME
				RVS->RVS_IDPLAI		:= cNumMov
				RVS->RVS_IDBANK     := cCodeBank
				RVS->RVS_STATUS		:= IIF(cDebCred == "3",9,1)
				RVS->(MsUnlock())
				ConfirmSX8()
			EndIf
			/*/
			ValidaciÛn de ocurrencia en los movimientos de cuentas por cobrar
			/*/
			aRecSSel 	:= {}
			aRecNSel  	:= {}
			cSequencia 	:= Replicate("0",nTamSeq)
			cNumRVS 	:= RVS->RVS_ID
			nRecnoRVS 	:= RVS->(recno())

			If RVS->RVS_STATUS == 1
				If TcGetDb() $ "ORACLE"
					BeginSql alias cAliasSE1
						SELECT SE1.E1_NUM,SE1.E1_PREFIXO,SE1.E1_VALOR,SE1.E1_SALDO,SE1.E1_TIPO,SE1.E1_PARCELA,
							SE1.E1_SLPLAID,SE1.E1_CLIENTE,SE1.E1_LOJA,SE1.R_E_C_N_O_ E1_RECNO,
							SA1.A1_NREDUZ
						FROM %table:SE1% SE1,%table:SA1% SA1 
						WHERE SE1.E1_FILIAL = %exp:cFilSE1%
							AND  SA1.A1_FILIAL = %exp:cFilSA1%
							AND SE1.E1_CLIENTE || SE1.E1_LOJA = SA1.A1_COD ||SA1.A1_LOJA
							AND SE1.E1_SALDO >= 0
							AND SE1.E1_EMISSAO <= %exp:cDataOrig%
							AND SE1.E1_TIPO IN ('NF ','NDC')
							AND E1_SLPLAID = %exp:RVS->RVS_VALCRE%  
							AND SE1.%notDel% 
							AND SA1.%notDel% 
							AND (SE1.E1_PORTADO = %exp:cParam3%  OR SE1.E1_PORTADO = ' ')
					EndSql
				Else
					BeginSql alias cAliasSE1
						SELECT SE1.E1_NUM,SE1.E1_PREFIXO,SE1.E1_VALOR,SE1.E1_SALDO,SE1.E1_TIPO,SE1.E1_PARCELA,
							SE1.E1_SLPLAID,SE1.E1_CLIENTE,SE1.E1_LOJA,SE1.R_E_C_N_O_ E1_RECNO,
							SA1.A1_NREDUZ
						FROM %table:SE1% SE1,%table:SA1% SA1 
						WHERE SE1.E1_FILIAL = %exp:cFilSE1%
							AND  SA1.A1_FILIAL = %exp:cFilSA1%
							AND SE1.E1_CLIENTE + SE1.E1_LOJA = SA1.A1_COD + SA1.A1_LOJA
							AND SE1.E1_SALDO >= 0
							AND SE1.E1_EMISSAO <= %exp:cDataOrig%
							AND SE1.E1_TIPO IN ('NF ','NDC')
							AND E1_SLPLAID = %exp:RVS->RVS_VALCRE%  
							AND SE1.%notDel% 
							AND SA1.%notDel% 
							AND (SE1.E1_PORTADO = %exp:cParam3%  OR SE1.E1_PORTADO = ' ')
					EndSql
				EndIf
				While (cAliasSE1)->( !Eof())
					lExiSE1 := .T.
					If AllTrim((cAliasSE1)->A1_NREDUZ) $  AllTrim(cDescMov)
						AADD(aRecSSel,{(cAliasSE1)->E1_RECNO,(cAliasSE1)->E1_CLIENTE, (cAliasSE1)->E1_LOJA, (cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_VALOR,(cAliasSE1)->E1_SALDO,(cAliasSE1)->E1_SLPLAID,(cAliasSE1)->E1_TIPO,(cAliasSE1)->E1_PARCELA,"SE1",AllTrim((cAliasSE1)->A1_NREDUZ)})
					Else
						AADD(aRecNSel,{(cAliasSE1)->E1_RECNO,(cAliasSE1)->E1_CLIENTE, (cAliasSE1)->E1_LOJA, (cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_VALOR,(cAliasSE1)->E1_SALDO,(cAliasSE1)->E1_SLPLAID,(cAliasSE1)->E1_TIPO,(cAliasSE1)->E1_PARCELA,"SE1",AllTrim((cAliasSE1)->A1_NREDUZ)})
					EndIf
					(cAliasSE1)->( DbSkip() )
				EndDo
				(cAliasSE1)->(DbCloseArea())

				If TcGetDb() $ "ORACLE"
					BeginSql alias cAliasSE5
						SELECT SE5.R_E_C_N_O_ E5_RECNO,SE5.E5_CLIFOR,SE5.E5_LOJA,SE5.E5_VALOR,
								SE5.E5_NUMCHEQ,SE5.E5_NUMERO,SE5.E5_DOCUMEN,E5_BENEF,E5_HISTOR,E5_TIPODOC 
						FROM %table:SE5% SE5
						WHERE SE5.E5_RECPAG = 'R'
							AND SE5.E5_SITUACA NOT IN ('C','X','E')
							AND SE5.E5_BANCO = %exp:cParam3% 		 
							AND SE5.E5_AGENCIA = %exp:cParam4%	
							AND SE5.E5_CONTA = %exp:cParam5%
							AND SE5.E5_DATA <= %exp:cDataOrig%	
							AND SE5.E5_TIPODOC IN ('CH','MT','DC','JR','TR','BA','VL','RA',' ')   
							AND SE5.E5_INTPLAI = ' '	
							AND UPPER(E5_HISTOR) NOT LIKE '%REVERSE%'
							AND SE5.E5_FILIAL ||SE5.E5_BANCO ||SE5.E5_TIPO || SE5.E5_MOEDA||SE5.E5_NUMERO||SE5.E5_PREFIXO||SE5.E5_PARCELA||
							SE5.E5_CLIENTE||SE5.E5_LOJA||SE5.E5_MOTBX||SE5.E5_SEQ 
							not in (SELECT SE5CAN.E5_FILIAL || SE5CAN.E5_BANCO || SE5CAN.E5_TIPO || SE5CAN.E5_MOEDA || SE5CAN.E5_NUMERO||SE5CAN.E5_PREFIXO||SE5CAN.E5_PARCELA||SE5CAN.E5_CLIENTE||SE5CAN.E5_LOJA||SE5CAN.E5_MOTBX||SE5CAN.E5_SEQ
								FROM %table:SE5% SE5CAN 
								WHERE SE5CAN.E5_FILIAL = E5_FILIAL AND SE5CAN.E5_RECPAG = 'P' AND SE5CAN.E5_SITUACA <> 'C' 
									AND SE5CAN.E5_BANCO = E5_BANCO AND SE5CAN.E5_TIPODOC IN ('ES','EC')
									AND SE5CAN.E5_NUMERO||SE5CAN.E5_PREFIXO||SE5CAN.E5_PARCELA||SE5CAN.E5_CLIENTE||SE5CAN.E5_LOJA = E5_NUMERO||E5_PREFIXO||E5_PARCELA||E5_CLIENTE||E5_LOJA 
									AND SE5CAN.D_E_L_E_T_ =' ')
							AND E5_FILIAL = %exp:cFilSE5%
							AND SE5.%notDel%
							AND SE5.E5_VALOR = %exp:RVS->RVS_VALCRE%
					EndSql
				Else
					BeginSql alias cAliasSE5
					SELECT SE5.R_E_C_N_O_ E5_RECNO,SE5.E5_CLIFOR,SE5.E5_LOJA,SE5.E5_VALOR,
						SE5.E5_NUMCHEQ,SE5.E5_NUMERO,SE5.E5_DOCUMEN,E5_BENEF,E5_HISTOR,E5_TIPODOC 
					FROM %table:SE5% SE5
					WHERE SE5.E5_RECPAG = 'R'
						AND SE5.E5_SITUACA NOT IN ('C','X','E')
						AND SE5.E5_BANCO = %exp:cParam3% 		 
						AND SE5.E5_AGENCIA = %exp:cParam4%	
						AND SE5.E5_CONTA = %exp:cParam5%	
						AND SE5.E5_DATA <= %exp:cDataOrig%
						AND SE5.E5_TIPODOC IN ('CH','MT','DC','JR','TR','BA','VL','RA',' ') 
						AND SE5.E5_INTPLAI = ' '	
						AND UPPER(E5_HISTOR) NOT LIKE '%REVERSE%' 
						AND SE5.E5_FILIAL + SE5.E5_BANCO + SE5.E5_TIPO + SE5.E5_MOEDA+SE5.E5_NUMERO+SE5.E5_PREFIXO+SE5.E5_PARCELA+
						SE5.E5_FORNECE+SE5.E5_LOJA+SE5.E5_MOTBX+SE5.E5_SEQ 
						not in (SELECT SE5CAN.E5_FILIAL + SE5CAN.E5_BANCO + SE5CAN.E5_TIPO + SE5CAN.E5_MOEDA + SE5CAN.E5_NUMERO+SE5CAN.E5_PREFIXO+SE5CAN.E5_PARCELA+SE5CAN.E5_FORNECE+SE5CAN.E5_LOJA+SE5CAN.E5_MOTBX+SE5CAN.E5_SEQ
						FROM %table:SE5% SE5CAN 
						WHERE SE5CAN.E5_FILIAL = E5_FILIAL AND SE5CAN.E5_RECPAG = 'P' AND SE5CAN.E5_SITUACA <> 'C' 
							AND SE5CAN.E5_BANCO = E5_BANCO AND SE5CAN.E5_TIPODOC IN ('ES','EC')
							AND SE5CAN.E5_NUMERO+SE5CAN.E5_PREFIXO+SE5CAN.E5_PARCELA+SE5CAN.E5_FORNECE+SE5CAN.E5_LOJA = E5_NUMERO+E5_PREFIXO+E5_PARCELA+E5_FORNECE+E5_LOJA 
							AND SE5CAN.D_E_L_E_T_ =' ')
							AND E5_FILIAL = %exp:cFilSE5%
							AND SE5.%notDel%
							AND SE5.E5_VALOR = %exp:RVS->RVS_VALCRE%
					EndSql
				EndIf
				While (cAliasSE5)->( !Eof())
					lExiSE5 := .T.
					If AllTrim((cAliasSE5)->E5_NUMCHEQ+(cAliasSE5)->E5_DOCUMEN) $  AllTrim(cDescMov)
						AADD(aRecSSel,{(cAliasSE5)->E5_RECNO,(cAliasSE5)->E5_CLIFOR, (cAliasSE5)->E5_LOJA,AllTrim((cAliasSE5)->E5_NUMCHEQ+(cAliasSE5)->E5_NUMERO),"",(cAliasSE5)->E5_VALOR,(cAliasSE5)->E5_VALOR,(cAliasSE5)->E5_VALOR,AllTrim((cAliasSE5)->E5_TIPODOC) + space(nTamTipo - len(AllTrim((cAliasSE5)->E5_TIPODOC))),"","SE5",(cAliasSE5)->E5_BENEF})
					Else
						AADD(aRecNSel,{(cAliasSE5)->E5_RECNO,(cAliasSE5)->E5_CLIFOR, (cAliasSE5)->E5_LOJA,AllTrim((cAliasSE5)->E5_NUMCHEQ+(cAliasSE5)->E5_NUMERO),"",(cAliasSE5)->E5_VALOR,(cAliasSE5)->E5_VALOR,(cAliasSE5)->E5_VALOR,AllTrim((cAliasSE5)->E5_TIPODOC) + space(nTamTipo - len(AllTrim((cAliasSE5)->E5_TIPODOC))),"","SE5",(cAliasSE5)->E5_BENEF})
					EndIf
					(cAliasSE5)->( DbSkip() )
				EndDo
				(cAliasSE5)->(DbCloseArea())

				aRecSSel:={}
				
				If Len(aRecSSel) > 0
					RVS->(DbGoto(nRecnoRVS))
					If RecLock("RVS",.F.)
						RVS->RVS_STATUS  := 2
						MsUnlock()
					EndIf

					For nW := 1 to Len(aRecSSel)
						cSequencia := Soma1(cSequencia,nTamSeq)

						If RecLock("RVT",.T.)
							RVT->RVT_FILIAL		:= xFilial("RVT")
							RVT->RVT_ITEM		:= cSequencia
							RVT->RVT_ID	  		:= cNumRVS
							RVT->RVT_DOC   		:= aRecSSel[nW][4]
							RVT->RVT_SERIE		:= aRecSSel[nW][5]
							RVT->RVT_CLIPRO		:= aRecSSel[nW][2]
							RVT->RVT_LOJA  		:= aRecSSel[nW][3]
							RVT->RVT_DATAMO		:= RVS->RVS_DATA
							RVT->RVT_VALOR  	:= aRecSSel[nW][6]
							RVT->RVT_SALDO  	:= aRecSSel[nW][7]
							RVT->RVT_SLPLAI  	:= aRecSSel[nW][8]
							RVT->RVT_TIPO  		:= aRecSSel[nW][9]
							RVT->RVT_PARCEL  	:= aRecSSel[nW][10]
							RVT->RVT_ORIGEN  	:= aRecSSel[nW][11]
							RVT->RVT_SEQ  		:= IIf(aRecSSel[nW][11]=="SE5", aRecSSel[nW][1],0)
							RVT->RVT_NAME  		:= aRecSSel[nW][12]
							MsUnLock()
						EndIf

						If aRecSSel[nW][11]=="SE5"
							SE5->(DbGoto(aRecSSel[nW][1]))
							If RecLock("SE5",.F.)
								SE5->E5_INTPLAI  :="I"
								MsUnlock()
							EndIf
						EndIf
					Next
				EndIf

				If Len(aRecNSel) > 0
					RVS->(DbGoto(nRecnoRVS))
					If RecLock("RVS",.F.)
						RVS->RVS_STATUS  := 2
						MsUnlock()
					EndIf

					For nW := 1 to Len(aRecNSel)
						cSequencia := Soma1(cSequencia,nTamSeq)
						If RecLock("RVT",.T.)
							RVT->RVT_FILIAL		:= xFilial("RVT")
							RVT->RVT_ITEM  		:= cSequencia
							RVT->RVT_ID	  		:= cNumRVS
							RVT->RVT_DOC   		:= aRecNSel[nW][4]
							RVT->RVT_SERIE  	:= aRecNSel[nW][5]
							RVT->RVT_CLIPRO  	:= aRecNSel[nW][2]
							RVT->RVT_LOJA  		:= aRecNSel[nW][3]
							RVT->RVT_DATAMO  	:= RVS->RVS_DATA
							RVT->RVT_VALOR  	:= aRecNSel[nW][6]
							RVT->RVT_SALDO  	:= aRecNSel[nW][7]
							RVT->RVT_SLPLAI  	:= aRecNSel[nW][8]
							RVT->RVT_TIPO  		:= aRecNSel[nW][9]
							RVT->RVT_PARCEL  	:= aRecNSel[nW][10]
							RVT->RVT_ORIGEN  	:= aRecNSel[nW][11]
							RVT->RVT_SEQ  		:= Iif(aRecNSel[nW][11]=="SE5", aRecNSel[nW][1],0)
							RVT->RVT_NAME  		:= aRecNSel[nW][12]
							MsUnLock()
						EndIf

						If aRecNSel[nW][11]=="SE5"
							SE5->(DbGoto(aRecNSel[nW][1]))
							If RecLock("SE5",.F.)
								SE5->E5_INTPLAI  :="I"
								MsUnlock()
							EndIf
						EndIf
					Next
				EndIf
			Else
				/*/
				ValidaciÛn de ocurrencia en los movimientos de cuentas por Pagar
				/*/				
				If TcGetDb() $ "ORACLE"
					BeginSql alias cAliasSE2
						SELECT SE2.E2_NUM,SE2.E2_PREFIXO,SE2.E2_VALOR,SE2.E2_SALDO,SE2.E2_TIPO,SE2.E2_PARCELA,
							SE2.E2_SLPLAID,SE2.E2_FORNECE,SE2.E2_LOJA,SE2.R_E_C_N_O_ E2_RECNO,
							SA2.A2_NREDUZ
						FROM %table:SE2% SE2,%table:SA2% SA2 
						WHERE SE2.E2_FILIAL = %exp:cFilSE2%
							AND  SA2.A2_FILIAL = %exp:cFilSA2%
							AND SE2.E2_FORNECE || SE2.E2_LOJA = SA2.A2_COD ||SA2.A2_LOJA
							AND SE2.E2_SALDO >= 0
							AND SE2.E2_EMISSAO <= %exp:cDataOrig%
							AND SE2.E2_TIPO IN ('NF ','NDP')
							AND SE2.E2_SLPLAID = %exp:RVS->RVS_VALDEB%  
							AND SE2.%notDel% 
							AND SA2.%notDel% 
							AND (SE2.E2_BCOPAG = %exp: cParam3%  OR SE2.E2_BCOPAG = '')
					EndSql
				Else
					BeginSql alias cAliasSE2
						SELECT SE2.E2_NUM,SE2.E2_PREFIXO,SE2.E2_VALOR,SE2.E2_SALDO,SE2.E2_TIPO,SE2.E2_PARCELA,
							SE2.E2_SLPLAID,SE2.E2_FORNECE,SE2.E2_LOJA,SE2.R_E_C_N_O_ E2_RECNO,
							SA2.A2_NREDUZ
						FROM %table:SE2% SE2,%table:SA2% SA2 
						WHERE SE2.E2_FILIAL = %exp:cFilSE2%
							AND  SA2.A2_FILIAL = %exp:cFilSA2%
							AND SE2.E2_FORNECE + SE2.E2_LOJA = SA2.A2_COD +SA2.A2_LOJA
							AND SE2.E2_SALDO >= 0
							AND SE2.E2_EMISSAO <= %exp:cDataOrig%
							AND SE2.E2_TIPO IN ('NF ','NDP')
							AND SE2.E2_SLPLAID = %exp:RVS->RVS_VALDEB%  
							AND SE2.%notDel% 
							AND SA2.%notDel% 
							AND (SE2.E2_BCOPAG = %exp: cParam3%  OR SE2.E2_BCOPAG = '')
					EndSql
				EndIf
				While (cAliasSE2)->( !Eof())
					lExiSE1 := .T.
					If AllTrim((cAliasSE2)->A2_NREDUZ) $  AllTrim(cDescMov)
						AADD(aRecSSel,{(cAliasSE2)->E2_RECNO,(cAliasSE2)->E2_FORNECE, (cAliasSE2)->E2_LOJA, (cAliasSE2)->E2_NUM,(cAliasSE2)->E2_PREFIXO,(cAliasSE2)->E2_VALOR,(cAliasSE2)->E2_SALDO,(cAliasSE2)->E2_SLPLAID,(cAliasSE2)->E2_TIPO,(cAliasSE2)->E2_PARCELA,"SE2",AllTrim((cAliasSE2)->A2_NREDUZ)})
					Else
						AADD(aRecNSel,{(cAliasSE2)->E2_RECNO,(cAliasSE2)->E2_FORNECE, (cAliasSE2)->E2_LOJA, (cAliasSE2)->E2_NUM,(cAliasSE2)->E2_PREFIXO,(cAliasSE2)->E2_VALOR,(cAliasSE2)->E2_SALDO,(cAliasSE2)->E2_SLPLAID,(cAliasSE2)->E2_TIPO,(cAliasSE2)->E2_PARCELA,"SE2",AllTrim((cAliasSE2)->A2_NREDUZ)})
					EndIf
					(cAliasSE2)->( DbSkip() )
				EndDo
				(cAliasSE2)->(DbCloseArea())

				If TcGetDb() $ "ORACLE"
					BeginSql alias cAliasSE5
						SELECT SE5.R_E_C_N_O_ E5_RECNO,SE5.E5_CLIFOR,SE5.E5_LOJA,SE5.E5_VALOR,
							SE5.E5_NUMCHEQ,SE5.E5_NUMERO,SE5.E5_DOCUMEN,E5_BENEF,E5_HISTOR,E5_TIPODOC 
						FROM %table:SE5% SE5
						WHERE SE5.E5_RECPAG = 'P'
							AND SE5.E5_SITUACA NOT IN ('C','X','E')
							AND SE5.E5_BANCO = %exp:cParam3% 		 
							AND SE5.E5_AGENCIA = %exp:cParam4%	
							AND SE5.E5_CONTA = %exp:cParam5%	
							AND SE5.E5_DATA <= %exp:cDataOrig%
							AND SE5.E5_TIPODOC IN ('CH','MT','DC','JR','TR','BA','VL','PA',' ')  
							AND SE5.E5_INTPLAI = ' '	 
							AND SE5.E5_FILIAL ||SE5.E5_BANCO ||SE5.E5_NUMCHEQ|| SE5.E5_MOEDA||SE5.E5_NUMERO||SE5.E5_PREFIXO||SE5.E5_PARCELA||
								SE5.E5_FORNECE||SE5.E5_LOJA||SE5.E5_MOTBX||SE5.E5_SEQ 
							not in (SELECT SE5CAN.E5_FILIAL || SE5CAN.E5_BANCO ||SE5CAN.E5_NUMCHEQ || SE5CAN.E5_MOEDA || SE5CAN.E5_NUMERO||SE5CAN.E5_PREFIXO||SE5CAN.E5_PARCELA||SE5CAN.E5_FORNECE||SE5CAN.E5_LOJA||SE5CAN.E5_MOTBX||SE5CAN.E5_SEQ
									FROM %table:SE5% SE5CAN 
									WHERE SE5CAN.E5_FILIAL = E5_FILIAL AND SE5CAN.E5_RECPAG = 'R' AND SE5CAN.E5_SITUACA <> 'C' 
										AND SE5CAN.E5_BANCO = E5_BANCO AND SE5CAN.E5_TIPODOC IN ('ES','EC')
										AND SE5CAN.E5_NUMERO||SE5CAN.E5_PREFIXO||SE5CAN.E5_PARCELA||SE5CAN.E5_FORNECE||SE5CAN.E5_LOJA||SE5CAN.E5_NUMCHEQ||SE5CAN.E5_SEQ = E5_NUMERO||E5_PREFIXO||E5_PARCELA||E5_FORNECE||E5_LOJA||E5_NUMCHEQ||E5_SEQ
										AND SE5CAN.D_E_L_E_T_ =' ')
							AND E5_FILIAL = %exp:cFilSE5%
							AND SE5.%notDel%
							AND SE5.E5_VALOR = %exp:RVS->RVS_VALDEB%
					EndSql
				Else
					BeginSql alias cAliasSE5
						SELECT SE5.R_E_C_N_O_ E5_RECNO,SE5.E5_CLIFOR,SE5.E5_LOJA,SE5.E5_VALOR,
							SE5.E5_NUMCHEQ,SE5.E5_NUMERO,SE5.E5_DOCUMEN,E5_BENEF,E5_HISTOR,E5_TIPODOC 
						FROM %table:SE5% SE5
						WHERE SE5.E5_RECPAG = 'P'
							AND SE5.E5_SITUACA NOT IN ('C','X','E')
							AND SE5.E5_BANCO = %exp: cParam3% 		 
							AND SE5.E5_AGENCIA = %exp:  cParam4%	
							AND SE5.E5_CONTA = %exp:cParam5%	
							AND SE5.E5_DATA <= %exp:cDataOrig%
							AND SE5.E5_TIPODOC IN ('CH','MT','DC','JR','TR','BA','VL','PA',' ')  
							AND SE5.E5_INTPLAI = ' '	 
							AND SE5.E5_FILIAL +SE5.E5_BANCO +SE5.E5_NUMCHEQ + SE5.E5_MOEDA+SE5.E5_NUMERO+SE5.E5_PREFIXO+SE5.E5_PARCELA+
							SE5.E5_FORNECE+SE5.E5_LOJA+SE5.E5_MOTBX+SE5.E5_SEQ 
							not in (SELECT SE5CAN.E5_FILIAL + SE5CAN.E5_BANCO + SE5CAN.E5_NUMCHEQ + SE5CAN.E5_MOEDA + SE5CAN.E5_NUMERO+SE5CAN.E5_PREFIXO+SE5CAN.E5_PARCELA+SE5CAN.E5_FORNECE+SE5CAN.E5_LOJA+SE5CAN.E5_MOTBX+SE5CAN.E5_SEQ
								FROM %table:SE5% SE5CAN 
								WHERE SE5CAN.E5_FILIAL = E5_FILIAL AND SE5CAN.E5_RECPAG = 'R' AND SE5CAN.E5_SITUACA <> 'C' 
									AND SE5CAN.E5_BANCO = E5_BANCO AND SE5CAN.E5_TIPODOC IN ('ES','EC')
									AND SE5CAN.E5_NUMERO+SE5CAN.E5_PREFIXO+SE5CAN.E5_PARCELA+SE5CAN.E5_FORNECE+SE5CAN.E5_LOJA+SE5CAN.E5_NUMCHEQ+SE5CAN.E5_SEQ  = E5_NUMERO+E5_PREFIXO+E5_PARCELA+E5_FORNECE+E5_LOJA+E5_NUMCHEQ+E5_SEQ
									AND SE5CAN.D_E_L_E_T_ =' ')
							AND E5_FILIAL = %exp:cFilSE5%
							AND SE5.%notDel%
							AND SE5.E5_VALOR = %exp:RVS->RVS_VALDEB%
					EndSql
				EndIf
				While (cAliasSE5)->( !Eof())
					lExiSE5 := .T.
					If AllTrim((cAliasSE5)->E5_HISTOR) $  AllTrim(cDescMov)
						AADD(aRecSSel,{(cAliasSE5)->E5_RECNO,(cAliasSE5)->E5_CLIFOR, (cAliasSE5)->E5_LOJA,(cAliasSE5)->E5_NUMERO,"",(cAliasSE5)->E5_VALOR,(cAliasSE5)->E5_VALOR,(cAliasSE5)->E5_VALOR,(cAliasSE5)->E5_TIPODOC,"","SE5",(cAliasSE5)->E5_BENEF})
					Else
						AADD(aRecNSel,{(cAliasSE5)->E5_RECNO,(cAliasSE5)->E5_CLIFOR, (cAliasSE5)->E5_LOJA,(cAliasSE5)->E5_NUMERO,"",(cAliasSE5)->E5_VALOR,(cAliasSE5)->E5_VALOR,(cAliasSE5)->E5_VALOR,(cAliasSE5)->E5_TIPODOC,"","SE5",(cAliasSE5)->E5_BENEF})
					EndIf
					(cAliasSE5)->( DbSkip() )
				EndDo
				(cAliasSE5)->(DbCloseArea())

				If Len(aRecSSel) > 0
					RVS->(DbGoto(nRecnoRVS))
					If RecLock("RVS",.F.)
						RVS->RVS_STATUS  := 2
						MsUnlock()
					EndIf

					For nW := 1 to Len(aRecSSel)
						cSequencia := Soma1(cSequencia,nTamSeq)

						If RecLock("RVT",.T.)
							RVT->RVT_FILIAL		:= xFilial("RVT")
							RVT->RVT_ITEM  		:= cSequencia
							RVT->RVT_ID	  		:= cNumRVS
							RVT->RVT_DOC   		:= aRecSSel[nW][4]
							RVT->RVT_SERIE  	:= aRecSSel[nW][5]
							RVT->RVT_CLIPRO  	:= aRecSSel[nW][2]
							RVT->RVT_LOJA  		:= aRecSSel[nW][3]
							RVT->RVT_DATAMO  	:= RVS->RVS_DATA
							RVT->RVT_VALOR  	:= aRecSSel[nW][6]
							RVT->RVT_SALDO  	:= aRecSSel[nW][7]
							RVT->RVT_SLPLAI  	:= aRecSSel[nW][8]
							RVT->RVT_TIPO  		:= aRecSSel[nW][9]
							RVT->RVT_PARCEL  	:= aRecSSel[nW][10]
							RVT->RVT_ORIGEN  	:= aRecSSel[nW][11]
							RVT->RVT_SEQ  		:= IIf(aRecSSel[nW][11]=="SE5", aRecSSel[nW][1],0)
							RVT->RVT_NAME  		:= aRecSSel[nW][12]
							MsUnLock()
						EndIf

						If aRecSSel[nW][11]=="SE5"
							SE5->(DbGoto(aRecSSel[nW][1]))
							If RecLock("SE5",.F.)
								SE5->E5_INTPLAI  :="I"
								MsUnlock()
							EndIf
						EndIf
					Next
				EndIf
				If Len(aRecNSel) > 0
					RVS->(DbGoto(nRecnoRVS))
					If RecLock("RVS",.F.)
						RVS->RVS_STATUS  := 2
						MsUnlock()
					EndIf
					For nW := 1 to Len(aRecNSel)
						cSequencia := Soma1(cSequencia,nTamSeq)
						If RecLock("RVT",.T.)
							RVT->RVT_FILIAL		:= xFilial("RVT")
							RVT->RVT_ITEM  		:= cSequencia
							RVT->RVT_ID	  		:= cNumRVS
							RVT->RVT_DOC   		:= aRecNSel[nW][4]
							RVT->RVT_SERIE  	:= aRecNSel[nW][5]
							RVT->RVT_CLIPRO  	:= aRecNSel[nW][2]
							RVT->RVT_LOJA  		:= aRecNSel[nW][3]
							RVT->RVT_DATAMO  	:= RVS->RVS_DATA
							RVT->RVT_VALOR  	:= aRecNSel[nW][6]
							RVT->RVT_SALDO  	:= aRecNSel[nW][7]
							RVT->RVT_SLPLAI  	:= aRecNSel[nW][8]
							RVT->RVT_TIPO 		:= aRecNSel[nW][9]
							RVT->RVT_PARCEL  	:= aRecNSel[nW][10]
							RVT->RVT_ORIGEN  	:= aRecNSel[nW][11]
							RVT->RVT_SEQ  		:= Iif(aRecNSel[nW][11]=="SE5", aRecNSel[nW][1],0)
							RVT->RVT_NAME  		:= aRecNSel[nW][12]
							MsUnLock()
						EndIf

						If aRecNSel[nW][11]=="SE5"
							SE5->(DbGoto(aRecNSel[nW][1]))
							If RecLock("SE5",.F.)
								SE5->E5_INTPLAI  :="I"
								MsUnlock()
							EndIf
						EndIf
					Next
				EndIf
			EndIf
		EndIf
	Next nX
	RestArea(aArea)
Return
/*/{Protheus.doc} PLAIDrECET2
Obtiene movimientos bancarios de Ingreso
@type
@author mayra.camargo
@since 25/01/2019
@version 1.0
/*/
Function plaidrecet2()
	Local aCpos		:= {}
	Local aCampos	:= {}
	Local nI		:= 0
	Local cCondicao	:=""
	Local oModel
	Local oModelZA2
	Local nLinha 	:= 0
	Local lAux 		:= .T.
	Local oStruct
	Local aAux    	:= {}
	Local oView   	:= FWViewActive()
	Local nX 		:= 1
	Local lRet 		:= .T.
	Local cDataOrig
	Local cExclTip 	:= AllTrim(GETMV("MV_PLEXTCR",,""))

	Private cAlias		:= "SE1"
	Private aRotina   	:= {}
	Private cCadastro 	:= STR0060 //"Accts. Receivable"

	aRecSel 	:= {}

	oModel		:= FWModelActive()
	oModelZA2	:= oModel:GetModel( 'RVTDETAIL' )
	oModelRVS	:= oModel:GetModel( 'RVSMASTER' )
	oStruct  	:= oModelZA2:GetStruct()
	aAux	 	:= oStruct:GetFields()
	nLinha 		:= oModelZA2:Length()
	cDataOrig 	:= dtos(oModelRVS:GetValue("RVS_DATA"))

	If oModelRVS:GetValue("RVS_STATUS") == 0
		lRet := .F.
		MsgInfo(OemToAnsi(STR0016),OemToAnsi(STR0017)) //"WARNING-COMP021LPRE"  "Combination OK"
	Else
		If oModelRVS:GetValue("RVS_VALDEB") <> 0
			MsgInfo(OemToAnsi(STR0037),OemToAnsi(STR0036)) //"Transaction invalid"  "Warning-plaidrecet2"
		Else

			AADD(aRotina,{STR0053, "AxPesqui",0,1}) // "Search""
			If cVersao == "11"
				AADD(aRotina,{STR0054,"AxVisual"	 ,0,2}) // "View"
			Else
				AADD(aRotina,{STR0054,"fVisualiza()" ,0,2}) // "View"
			EndIf
			AADD(aRotina,{STR0055	,"VisLote2()" 	,0,3}) // "Confirm"
			AADD(aRotina,{STR0057	,"LimpaMarca()"  	,0,4}) // "Clean"

			AADD(aCpos,	"E1_OK"	)
			If SE1->(ColumnPos('E1_NREDUZ')) > 0
				AADD(aCpos,	"E1_NREDUZ"	)
			EndIf
			AADD(aCpos,	"E1_CLIENTE"	)
			AADD(aCpos,	"E1_LOJA"	)
			AADD(aCpos,	"E1_NUM"	)
			AADD(aCpos,	"E1_PREFIXO"	)
			AADD(aCpos,	"E1_VALOR"	)
			AADD(aCpos,	"E1_SALDO"	)
			AADD(aCpos,	"E1_SLPLAID"	)
			AADD(aCpos,	"E1_TIPO"	)
			AADD(aCpos,	"E1_PARCELA")

			For nI := 1 To Len(aCpos)
				AADD(aCampos,{aCpos[nI],"",IIF(nI==1,"",AllTrim(GetSX3Cache( aCpos[nI] ,"X3_TITENG" ))),;
				AllTrim(GetSX3Cache( aCpos[nI] ,"X3_PICTURE" ))})
			Next

			aDatas:=A884PERG("SE1")
			cCondicao   := "E1_FILIAL = '" + xFilial("SE1")+ "'"
			cCondicao 	+= " AND E1_PORTADO IN ('" + cParam3 + "','   ')"
			cCondicao 	+= " AND E1_SLPLAID > 0 "
			cCondicao 	+= " AND E1_SALDO> 0 "


			If !Empty(cExclTip)
				cCondicao += "AND E1_TIPO NOT IN "+FormatIn(cExclTip,";")
			EndIf

			If !Empty(aDatas[1])
				cCondicao 	+= " AND E1_EMISSAO >= '" +  Dtos(aDatas[1])  +  "' "
			EndIf

			If !Empty(aDatas[2])
				cCondicao 	+= " AND E1_EMISSAO <= '" +  Dtos(aDatas[2])  +  "' "
			EndIf


			If !Empty(aDatas[3])
				cCondicao 	+= " AND E1_VENCTO >= '" +  Dtos(aDatas[3])  +  "' "
			EndIf

			If !Empty(aDatas[4])
				cCondicao 	+= " AND E1_VENCTO <= '" +  Dtos(aDatas[4])  +  "' "
			EndIf


			For nX = 1 to nLinha
				oModelZA2:GoLine( nX )
				If !oModelZA2:IsDeleted() .AND. !Empty(AllTrim(oModelZA2:GetValue("RVT_CLIPRO")))
					If TcGetDb() $ "ORACLE"
						cCondicao 	+= " And RTrim(LTrim(E1_CLIENTE))||RTrim(LTrim(E1_LOJA))||RTrim(LTrim(E1_TIPO))||RTrim(LTrim(E1_NUM))||RTrim(LTrim(E1_PREFIXO)) <> '" + AllTrim(oModelZA2:GetValue("RVT_CLIPRO")) + AllTrim(oModelZA2:GetValue("RVT_LOJA")) + AllTrim(oModelZA2:GetValue("RVT_TIPO")) + AllTrim(oModelZA2:GetValue("RVT_DOC")) + AllTrim(oModelZA2:GetValue("RVT_SERIE")) + "'"
					Else
						cCondicao 	+= " And RTrim(LTrim(E1_CLIENTE))+RTrim(LTrim(E1_LOJA))+RTrim(LTrim(E1_TIPO))+RTrim(LTrim(E1_NUM))+RTrim(LTrim(E1_PREFIXO)) <> '" + AllTrim(oModelZA2:GetValue("RVT_CLIPRO")) + AllTrim(oModelZA2:GetValue("RVT_LOJA")) + AllTrim(oModelZA2:GetValue("RVT_TIPO")) + AllTrim(oModelZA2:GetValue("RVT_DOC")) + AllTrim(oModelZA2:GetValue("RVT_SERIE")) + "'"
					EndIf
				EndIf
			Next

			DbSelectArea(cAlias)
			DbSetOrder(1)
			MarkBrow(cAlias,aCpos[1],,aCampos,.F.,GetMark(,"SE1","E1_OK"),,,,,,,cCondicao)

			If Len(aRecSel) > 0
				For nX := 1 to Len(aRecSel)
					If aRecSel[nX][12] == .T.
						oModelZA2:GoLine( nLinha )
						If !Empty(oModelZA2:GetValue("RVT_DATAMO"))
							nLinha++
							lRet := oModelZA2:AddLine() == nLinha
						EndIf
						If lRet
							lAux := oModelZA2:SETVALUE("RVT_FILIAL"		,xFilial("RVT"))
							lAux := oModelZA2:SETVALUE("RVT_DOC"		,aRecSel[nX][4])
							lAux := oModelZA2:SETVALUE("RVT_SERIE"		,aRecSel[nX][5])
							lAux := oModelZA2:SETVALUE("RVT_VALOR"		,aRecSel[nX][6])
							lAux := oModelZA2:SETVALUE("RVT_SLPLAI"	,aRecSel[nX][8])
							lAux := oModelZA2:SETVALUE("RVT_CLIPRO"		,aRecSel[nX][2])
							lAux := oModelZA2:SETVALUE("RVT_LOJA"		,aRecSel[nX][3])
							lAux := oModelZA2:SETVALUE("RVT_DATAMO"		,oModelRVS:GetValue("RVS_DATA"))
							lAux := oModelZA2:SETVALUE("RVT_TIPO"		,aRecSel[nX][9])
							lAux := oModelZA2:SETVALUE("RVT_SALDO"		,aRecSel[nX][7])
							lAux := oModelZA2:SETVALUE("RVT_PARCEL"	,aRecSel[nX][10])
							lAux := oModelZA2:SETVALUE("RVT_ORIGEN"		,aRecSel[nX][11])
						EndIf
					EndIf
				Next nX
			EndIf
			oModelZA2:GoLine( 1 )
		EndIf
	EndIf
	oView:Refresh()
Return

/*/{Protheus.doc} plaidexpe2
FunciÛn que permite presentar los Titulos por pagar
pendientes de integrar con PLAID
@type
@author mayra.camargo
@since 25/01/2019
@version 1.0
/*/
Function plaidexpe2()
	Local aCpos		:= {}
	Local aCampos	:= {}
	Local nI		:= 0
	Local cCondicao	:=""
	Local oModel	:= Nil
	Local oModelZA2:= Nil
	Local oModelRVS	:= Nil
	Local nLinha 	:= 0
	Local lAux 		:= .T.
	Local oStruct	:= nil
	Local aAux		:= {}
	Local oView		:= FWViewActive()
	Local nX 		:= 1
	Local lRet 		:= .T.
	Local cDataOrig	:= ""
	Local aDatas
	Local cExclTip 	:= AllTrim(GETMV("MV_PLEXTCP",,""))

	Private aRotina	:= {}
	Private cCadastro	:= STR0071 //"Accounts Payable"
	Private cAlias		:= "SE2"

	aRecSel	:= {}

	oModel		:= FWModelActive()
	oModelZA2  	:= oModel:GetModel('RVTDETAIL')
	oModelRVS  	:= oModel:GetModel('RVSMASTER')
	oStruct  	:= oModelZA2:GetStruct()
	aAux	 	:= oStruct:GetFields()
	nLinha 		:= oModelZA2:Length()
	cDataOrig 	:= dtos(oModelRVS:GetValue("RVS_DATA"))

	If oModelRVS:GetValue("RVS_STATUS") == 0
		lRet := .F.
		MsgInfo(OemToAnsi(STR0016),OemToAnsi(STR0017))  // "AVISO DE ALERTA-COMP021LPRE"  "CombinaciÛn est· OK"
	Else
		If oModelRVS:GetValue("RVS_VALCRE") <> 0
			MsgInfo(OemToAnsi(STR0038),OemToAnsi(STR0037)) // "Aviso-plaidexpe2" "TransacciÛn no v·lida"
		Else

			AADD(aRotina,{STR0053,"AxPesqui"	 ,0,1}) // "Search"
			If cVersao == "11"
				AADD(aRotina,{STR0054,"AxVisual"	 ,0,2}) // "View"
			Else
				AADD(aRotina,{STR0054,"fVisualiza()" ,0,2}) // "View"
			EndIf
			AADD(aRotina,{STR0055	,"Vislote2()" 	,0,3}) // "Confirm"
			AADD(aRotina,{STR0057	,"LimpaMarca()" 	,0,4}) // "Clean"

			AADD(aCpos,	"E2_OK"	)
			AADD(aCpos,	"E2_FORNECE")
			AADD(aCpos,	"E2_LOJA"	)
			AADD(aCpos,	"E2_NUM"	)
			AADD(aCpos,	"E2_PREFIXO")
			AADD(aCpos,	"E2_VALOR"	)
			AADD(aCpos,	"E2_SALDO"	)
			AADD(aCpos,	"E2_SLPLAID")
			AADD(aCpos,	"E2_TIPO"	)
			AADD(aCpos,	"E2_PARCELA")

			For nI := 1 To Len(aCpos)
				AADD(aCampos,{aCpos[nI],"",IIF(nI==1,"",AllTrim(GetSX3Cache( aCpos[nI] ,"X3_TITENG" ))),;
				AllTrim(GetSX3Cache( aCpos[nI] ,"X3_PICTURE" ))  })
			Next

			aDatas:=A884PERG("SE2")
			cCondicao   := " E2_FILIAL = '" + xFilial("SE2")+ "'"
			cCondicao 	+= " AND E2_BCOPAG IN ('" + cParam3 + "', '   ')"
			cCondicao 	+= " AND E2_SLPLAID > 0 "
			cCondicao 	+= " AND E2_SALDO > 0 "

			If !Empty(aDatas[1])
				cCondicao 	+= " AND E2_EMISSAO >= '" +  Dtos(aDatas[1])  +  "' "
			EndIf

			If !Empty(aDatas[2])
				cCondicao 	+= " AND E2_EMISSAO <= '" +  Dtos(aDatas[2])  +  "' "
			EndIf


			If !Empty(aDatas[3])
				cCondicao 	+= " AND E2_VENCTO >= '" +  Dtos(aDatas[3])  +  "' "
			EndIf

			If !Empty(aDatas[4])
				cCondicao 	+= " AND E2_VENCTO <= '" +  Dtos(aDatas[4])  +  "' "
			EndIf

			If !Empty(cExclTip)
				cCondicao += "AND E2_TIPO NOT IN "+FormatIn(cExclTip,";")
			EndIf

			For nX = 1 to nLinha
				oModelZA2:GoLine( nX )
				If !oModelZA2:IsDeleted() .AND. !Empty(AllTrim(oModelZA2:GetValue("RVT_CLIPRO")))
					If TcGetDb() $ "ORACLE"
						cCondicao 	+= " And RTrim(LTrim(E2_FORNECE))||RTrim(LTrim(E2_LOJA))||RTrim(LTrim(E2_TIPO))||RTrim(LTrim(E2_NUM))||RTrim(LTrim(E2_PREFIXO)) <> '" + AllTrim(oModelZA2:GetValue("RVT_CLIPRO")) + AllTrim(oModelZA2:GetValue("RVT_LOJA")) + AllTrim(oModelZA2:GetValue("RVT_TIPO")) + AllTrim(oModelZA2:GetValue("RVT_DOC")) + AllTrim(oModelZA2:GetValue("RVT_SERIE")) + "'"
					Else
						cCondicao 	+= " And RTrim(LTrim(E2_FORNECE))+RTrim(LTrim(E2_LOJA))+RTrim(LTrim(E2_TIPO))+RTrim(LTrim(E2_NUM))+RTrim(LTrim(E2_PREFIXO)) <> '" + AllTrim(oModelZA2:GetValue("RVT_CLIPRO")) + AllTrim(oModelZA2:GetValue("RVT_LOJA")) + AllTrim(oModelZA2:GetValue("RVT_TIPO")) + AllTrim(oModelZA2:GetValue("RVT_DOC")) + AllTrim(oModelZA2:GetValue("RVT_SERIE")) + "'"
					EndIf
				EndIf
			Next

			DbSelectArea(cAlias)
			DbSetOrder(1)
			MarkBrow(cAlias,aCpos[1],,aCampos,.F.,GetMark(,"SE2","E2_OK"),,,,,,,cCondicao,,)

			If Len(aRecSel) > 0
				For nX := 1 to Len(aRecSel)
					If aRecSel[nX][12] == .T.
						oModelZA2:GoLine( nLinha )
						If !Empty(oModelZA2:GetValue("RVT_DATAMO"))
							nLinha++
							lRet := oModelZA2:AddLine() == nLinha
						EndIf

						If lRet
							lAux := oModelZA2:SETVALUE("RVT_DOC"	,aRecSel[nX][4])
							lAux := oModelZA2:SETVALUE("RVT_SERIE"	,aRecSel[nX][5])
							lAux := oModelZA2:SETVALUE("RVT_VALOR"	,aRecSel[nX][6])
							lAux := oModelZA2:SETVALUE("RVT_SLPLAI"	,aRecSel[nX][8])
							lAux := oModelZA2:SETVALUE("RVT_CLIPRO"	,aRecSel[nX][2])
							lAux := oModelZA2:SETVALUE("RVT_LOJA"	,aRecSel[nX][3])
							lAux := oModelZA2:SETVALUE("RVT_DATAMO"	,oModelRVS:GetValue("RVS_DATA"))
							lAux := oModelZA2:SETVALUE("RVT_TIPO"	,aRecSel[nX][9])
							lAux := oModelZA2:SETVALUE("RVT_SALDO"	,aRecSel[nX][7])
							lAux := oModelZA2:SETVALUE("RVT_PARCEL"	,aRecSel[nX][10])
							lAux := oModelZA2:SETVALUE("RVT_ORIGEN"	,aRecSel[nX][11])
						EndIf
					EndIf
				Next nX
			EndIf
			oModelZA2:GoLine( 1 )
		EndIf
		oView:Refresh()
	EndIf
Return

Function plaidbank2()
	Local aArea := GetArea()
	Local aCpos		:= {}
	Local aCampos	:= {}
	Local nI		:= 0
	Local cCondicao	:=""
	Local oModel
	Local oModelZA2 := nil
	Local oModelRVS
	Local nLinha 	:= 0
	Local lAux 		:= .T.
	Local oStruct
	Local aAux   	:= {}
	Local oView  	:= FWViewActive()
	Local nX 		:= 1
	Local lRet 		:= .T.
	Local cDataOrig
	Local aSaveLines := FWSaveRows()

	Private aRotina	:= {}
	Private cCadastro 	:= STR0056 // "Bill PAYEE"
	Private cAlias		:= "SE5"

	aRecSel 	:= {}

	oModel		:= FWModelActive()
	oModelZA2	:= oModel:GetModel( 'RVTDETAIL' )
	oModelRVS	:= oModel:GetModel( 'RVSMASTER' )
	oStruct  	:= oModelZA2:GetStruct()
	aAux	 	:= oStruct:GetFields()
	nLinha 		:= oModelZA2:Length()
	cDataOrig 	:= dtos(oModelRVS:GetValue("RVS_DATA"))

	AADD(aRotina,{STR0053,"AxPesqui" ,0,1}) // "Search"
	If cVersao == "11"
		AADD(aRotina,{STR0054,"AxVisual" ,0,2}) // "View"
	EndIf
	AADD(aRotina,{STR0055	,"VisLote2()" 	,0,3}) // "Confirm"
	AADD(aRotina,{STR0057	,"LimpaMarca()"  	,0,4}) // "Clean"

	AADD(aCpos	,	"E5_OK"		)
	AADD(aCpos	,	"E5_BENEF"	)
	AADD(aCpos	,	"E5_VALOR"	)
	AADD(aCpos	,	"E5_NUMERO"	)
	AADD(aCpos	,	"E5_PREFIXO")
	AADD(aCpos	,	"E5_NUMCHEQ")
	AADD(aCpos	,	"E5_HISTOR"	)


	For nI := 1 To Len(aCpos)
		AADD(aCampos,{aCpos[nI],"",IIF(nI==1,"",AllTrim(GetSX3Cache( aCpos[nI] ,"X3_TITENG" ))),;
		AllTrim(GetSX3Cache( aCpos[nI] ,"X3_PICTURE" ))})
	Next

	If oModelRVS:GetValue("RVS_STATUS") == 0
		lRet := .F.
		MsgInfo(OemToAnsi(STR0016),OemToAnsi(STR0017)) //"WARNING-COMP021LPRE"   "Combination OK"
	Else
		If oModelRVS:GetValue("RVS_VALDEB") <> 0
			If TcGetDb() $ "ORACLE"
				cCondicao   := " E5_FILIAL = '" + xFilial("SE5")+ "'"
				cCondicao 	+= " AND E5_RECPAG = 'P'"
				cCondicao 	+= " AND E5_SITUACA NOT IN ('C','X','E') "
				cCondicao 	+= " AND E5_BANCO = '" +  cParam3  +  "' "
				cCondicao 	+= " AND E5_AGENCIA = '" +  cParam4  +  "' "
				cCondicao 	+= " AND E5_CONTA = '" +  cParam5  +  "' "
				cCondicao 	+= " AND E5_TIPODOC IN ('CH','MT','DC','JR','TR','BA','VL','PA',' ' )"
				cCondicao 	+= " AND E5_INTPLAI = ' '"
				cCondicao 	+= " AND E5_FILIAL ||E5_BANCO ||E5_NUMCHEQ|| E5_MOEDA||E5_NUMERO||E5_PREFIXO||E5_PARCELA||"
				cCondicao 	+= "E5_FORNECE||E5_LOJA||E5_MOTBX||E5_SEQ "
				cCondicao 	+= " not in (SELECT SE5CAN.E5_FILIAL || SE5CAN.E5_BANCO ||SE5CAN.E5_NUMCHEQ ||"
				cCondicao 	+= " SE5CAN.E5_MOEDA||SE5CAN.E5_NUMERO||SE5CAN.E5_PREFIXO||SE5CAN.E5_PARCELA||SE5CAN.E5_FORNECE||SE5CAN.E5_LOJA||SE5CAN.E5_MOTBX||SE5CAN.E5_SEQ"
				cCondicao 	+= " FROM " + RetSqlName("SE5") + "  SE5CAN WHERE SE5CAN.E5_FILIAL = E5_FILIAL AND SE5CAN.E5_RECPAG = 'R' AND SE5CAN.E5_SITUACA <> 'C' "
				cCondicao 	+= " AND SE5CAN.E5_BANCO = E5_BANCO AND SE5CAN.E5_TIPODOC IN ('ES','EC')"
				cCondicao 	+= " AND SE5CAN.E5_NUMERO||SE5CAN.E5_PREFIXO||SE5CAN.E5_PARCELA||SE5CAN.E5_FORNECE||SE5CAN.E5_LOJA||SE5CAN.E5_NUMCHEQ||SE5CAN.E5_SEQ = E5_NUMERO||E5_PREFIXO||E5_PARCELA||E5_FORNECE||E5_LOJA||E5_NUMCHEQ||E5_SEQ "
				cCondicao 	+= " AND SE5CAN.D_E_L_E_T_ =' ')"
			Else
				cCondicao   := " E5_FILIAL = '" + xFilial("SE5")+ "'"
				cCondicao 	+= " AND E5_RECPAG = 'P'"
				cCondicao 	+= " AND E5_SITUACA NOT IN ('C','X','E') "
				cCondicao 	+= " AND E5_BANCO = '" +  cParam3  +  "' "
				cCondicao 	+= " AND E5_AGENCIA = '" +  cParam4  +  "' "
				cCondicao 	+= " AND E5_CONTA = '" +  cParam5  +  "' "
				cCondicao 	+= " AND E5_TIPODOC IN ('CH','MT','DC','JR','TR','BA','VL','PA',' ') "
				cCondicao 	+= " AND E5_INTPLAI = ' '"
				cCondicao 	+= " AND E5_FILIAL +E5_BANCO + E5_NUMCHEQ + E5_MOEDA+E5_NUMERO+E5_PREFIXO+E5_PARCELA+"
				cCondicao 	+= "E5_FORNECE+E5_LOJA+E5_MOTBX+E5_SEQ "
				cCondicao 	+= " not in (SELECT SE5CAN.E5_FILIAL + SE5CAN.E5_BANCO +SE5CAN.E5_NUMCHEQ +"
				cCondicao 	+= " SE5CAN.E5_MOEDA+SE5CAN.E5_NUMERO+SE5CAN.E5_PREFIXO+SE5CAN.E5_PARCELA+SE5CAN.E5_FORNECE+SE5CAN.E5_LOJA+SE5CAN.E5_MOTBX+SE5CAN.E5_SEQ"
				cCondicao 	+= " FROM " + RetSqlName("SE5") + " SE5CAN WHERE SE5CAN.E5_FILIAL = E5_FILIAL AND SE5CAN.E5_RECPAG = 'R' AND SE5CAN.E5_SITUACA <> 'C' "
				cCondicao 	+= " AND SE5CAN.E5_BANCO = E5_BANCO AND SE5CAN.E5_TIPODOC IN ('ES','EC')"
				cCondicao 	+= " AND SE5CAN.E5_NUMERO+SE5CAN.E5_PREFIXO+SE5CAN.E5_PARCELA+SE5CAN.E5_FORNECE+SE5CAN.E5_LOJA+SE5CAN.E5_NUMCHEQ+SE5CAN.E5_SEQ  = E5_NUMERO+E5_PREFIXO+E5_PARCELA+E5_FORNECE+E5_LOJA+E5_NUMCHEQ+E5_SEQ  "
				cCondicao 	+= " AND SE5CAN.D_E_L_E_T_ =' ')"
			EndIf
		Else
			If TcGetDb() $ "ORACLE"
				cCondicao   := " E5_FILIAL = '" + xFilial("SE5")+ "'"
				cCondicao 	+= " AND E5_RECPAG = 'R'"
				cCondicao 	+= " AND E5_SITUACA NOT IN ('C','X','E') "
				cCondicao 	+= " AND E5_BANCO = '" +  cParam3  +  "' "
				cCondicao 	+= " AND E5_AGENCIA = '" +  cParam4  +  "' "
				cCondicao 	+= " AND E5_CONTA = '" +  cParam5  +  "' "
				cCondicao 	+= " AND E5_DATA <= '" +  cDataOrig  +  "' "
				cCondicao 	+= " AND E5_TIPODOC IN ('CH','MT','DC','JR','TR','BA','VL','RA',' ') "
				cCondicao 	+= " AND E5_INTPLAI = ' '"
				cCondicao 	+= " AND UPPER(E5_HISTOR) NOT LIKE '%REVERSE%'"
				cCondicao 	+= " AND E5_HISTOR not like '%REVERSE%'"
				cCondicao 	+= " AND E5_FILIAL||E5_BANCO||E5_TIPO||E5_MOEDA||E5_NUMERO||E5_PREFIXO||E5_PARCELA||"
				cCondicao 	+= "E5_CLIENTE||E5_LOJA||E5_MOTBX||E5_SEQ "
				cCondicao 	+= " not in (SELECT SE5CAN.E5_FILIAL || SE5CAN.E5_BANCO ||SE5CAN.E5_TIPO ||"
				cCondicao 	+= " SE5CAN.E5_MOEDA||SE5CAN.E5_NUMERO||SE5CAN.E5_PREFIXO||SE5CAN.E5_PARCELA||SE5CAN.E5_CLIENTE||SE5CAN.E5_LOJA||SE5CAN.E5_MOTBX||SE5CAN.E5_SEQ"
				cCondicao 	+= " FROM " + RetSqlName("SE5") + " SE5CAN WHERE SE5CAN.E5_FILIAL = E5_FILIAL AND SE5CAN.E5_RECPAG = 'P' AND SE5CAN.E5_SITUACA <> 'C' "
				cCondicao 	+= " AND SE5CAN.E5_BANCO = E5_BANCO AND SE5CAN.E5_TIPODOC IN ('ES','EC')"
				cCondicao 	+= " AND SE5CAN.E5_NUMERO||SE5CAN.E5_PREFIXO||SE5CAN.E5_PARCELA||SE5CAN.E5_CLIENTE||SE5CAN.E5_LOJA = E5_NUMERO||E5_PREFIXO||E5_PARCELA||E5_CLIENTE||E5_LOJA "
				cCondicao 	+= " AND SE5CAN.D_E_L_E_T_ =' ')"
			Else
				cCondicao   := " E5_FILIAL = '" + xFilial("SE5")+ "'"
				cCondicao 	+= " AND E5_RECPAG = 'R'"
				cCondicao 	+= " AND E5_SITUACA NOT IN ('C','X','E') "
				cCondicao 	+= " AND E5_BANCO = '" +  cParam3  +  "' "
				cCondicao 	+= " AND E5_AGENCIA = '" +  cParam4  +  "' "
				cCondicao 	+= " AND E5_CONTA = '" +  cParam5  +  "' "
				cCondicao 	+= " AND E5_DATA <= '" +  cDataOrig  +  "' "
				cCondicao 	+= " AND E5_TIPODOC IN ('CH','MT','DC','JR','TR','BA','VL','RA',' ') "
				cCondicao 	+= " AND E5_INTPLAI = ' '"
				cCondicao 	+= " AND UPPER(E5_HISTOR) NOT LIKE '%REVERSE%'"
				cCondicao 	+= " AND E5_FILIAL +E5_BANCO +E5_TIPO + E5_MOEDA+E5_NUMERO+E5_PREFIXO+E5_PARCELA+"
				cCondicao 	+= " E5_CLIENTE+E5_LOJA+E5_MOTBX+E5_SEQ "
				cCondicao 	+= " NOT IN (SELECT SE5CAN.E5_FILIAL + SE5CAN.E5_BANCO +SE5CAN.E5_TIPO +"
				cCondicao 	+= " SE5CAN.E5_MOEDA+SE5CAN.E5_NUMERO+SE5CAN.E5_PREFIXO+SE5CAN.E5_PARCELA+SE5CAN.E5_CLIENTE+SE5CAN.E5_LOJA+SE5CAN.E5_MOTBX+SE5CAN.E5_SEQ"
				cCondicao 	+= " FROM " + RetSqlName("SE5") + " SE5CAN WHERE SE5CAN.E5_FILIAL = E5_FILIAL AND SE5CAN.E5_RECPAG = 'P' AND SE5CAN.E5_SITUACA <> 'C' "
				cCondicao 	+= " AND SE5CAN.E5_BANCO = E5_BANCO AND SE5CAN.E5_TIPODOC IN ('ES','EC')"
				cCondicao 	+= " AND SE5CAN.E5_NUMERO+SE5CAN.E5_PREFIXO+SE5CAN.E5_PARCELA+SE5CAN.E5_CLIENTE+SE5CAN.E5_LOJA = E5_NUMERO+E5_PREFIXO+E5_PARCELA+E5_CLIENTE+E5_LOJA "
				cCondicao 	+= " AND SE5CAN.D_E_L_E_T_ =' ')"
			EndIf
		EndIf

		For nX = 1 to nLinha
			oModelZA2:GoLine( nX )
			If !oModelZA2:IsDeleted()
				If AllTrim(oModelZA2:GetValue("RVT_TIPO")) $ "NF/TB/BA/VL/CH/PA/RA" .OR. Empty(AllTrim(oModelZA2:GetValue("RVT_TIPO")))
					cCondicao 	+= " AND R_E_C_N_O_ <> " + Str(oModelZA2:GetValue("RVT_SEQ")) + " "
				EndIf
			EndIf
		Next
		cCondicao+=" And E5_ORIGEM<>'FINA884' "
		DbSelectArea("SE5")
		SE5->(DbSetOrder(2))
		MarkBrow("SE5",aCpos[1],,aCampos,.F.,GetMark(,"SE5","E5_OK"),,,,,,,cCondicao)
		nLinha := oModelZA2:Length()
		If Len(aRecSel) > 0
			For nX := 1 to Len(aRecSel)
				If aRecSel[nX][11] == .T.
					oModelZA2:GoLine( nLinha )
					If oModelZA2:IsInserted() .and. Empty(oModelZA2:GetValue("RVT_DATAMO"))
						If nLinha == 1
							lRet := .T.
						Else
							If !Empty(oModelZA2:GetValue("RVT_DATAMO"))
								nLinha++
							EndIf
							lRet := oModelZA2:AddLine() == nLinha
						EndIf
					Else
						nLinha++
						lRet := oModelZA2:AddLine() == nLinha
					EndIf
					If lRet
						lAux := oModelZA2:SETVALUE("RVT_FILIAL"		,Xfilial("RVT"))
						lAux := oModelZA2:SETVALUE("RVT_DOC"		,aRecSel[nX][4])
						lAux := oModelZA2:SETVALUE("RVT_SERIE"		,aRecSel[nX][5])
						lAux := oModelZA2:SETVALUE("RVT_VALOR"		,aRecSel[nX][6])
						lAux := oModelZA2:SETVALUE("RVT_SLPLAI"		,aRecSel[nX][6])
						lAux := oModelZA2:SETVALUE("RVT_CLIPRO"		,aRecSel[nX][2])
						lAux := oModelZA2:SETVALUE("RVT_LOJA"		,aRecSel[nX][3])
						lAux := oModelZA2:SETVALUE("RVT_DATAMO"		,oModelRVS:GetValue("RVS_DATA"))
						If !Empty(aRecSel[nX][7])
							lAux := oModelZA2:SETVALUE("RVT_TIPO"		,aRecSel[nX][7])
						EndIf
						lAux := oModelZA2:SETVALUE("RVT_SALDO"		,aRecSel[nX][6])
						lAux := oModelZA2:SETVALUE("RVT_PARCEL"		,aRecSel[nX][8])
						lAux := oModelZA2:SETVALUE("RVT_SEQ"		,aRecSel[nX][1])
						lAux := oModelZA2:SETVALUE("RVT_ORIGEN"		,aRecSel[nX][10])
					EndIf
				EndIf
			Next nX
		EndIf
		oModelZA2:GoLine( 1 )
		FWRestRows( aSaveLines )
		oView:Refresh()
	EndIf
	RestArea(aArea)
Return

/*/{Protheus.doc} COMP23BUT
FunciÛn que permite presenta botones adicionales y ejecuta acciÛn 
para poder seleccionar los registros de ingresos y gastos
@type
@author mayra.camargo
@since 25/01/2019
@version 1.0
/*/
Static Function COMP23BUT( oPanel )

	// Ancoramos os objetos no oPanel passado
	@ 10, 10 Button STR0041  Size 40, 13 Message STR0045 Pixel Action IIf(Altera, Processa({|| plaidrecet2()}),)	Of oPanel //832Ingresos  ## 'Movimientos de Ingresos'
	@ 30, 10 Button STR0042  Size 40, 13 Message STR0046 Pixel Action IIf(Altera, Processa({|| plaidexpe2() }),)	Of oPanel //923Egresos ## 'Movimientos de Egresos'
	@ 50, 10 Button STR0043  Size 40, 13 Message STR0047 Pixel Action IIf(Altera, Processa({|| plaidbank2() }),)	Of oPanel //1118Bancos ##'Movimientos Bancarios'
	@ 90, 10 Button STR0044  Size 40, 13 Message STR0058 Pixel Action IIf(Altera, Processa({|| PlaidMatch() }),)	Of oPanel //Relacionar 'MATCH'

Return NIL

/*/{Protheus.doc} VisLote
FunÁ„o utilizada para el recurso da MarkBrowse
@type
@author ARNALDO RAYMUNDO JR.
@since 25/01/2019
@version 1.0
/*/
Function VisLote()
	Local cMarca	:= ThisMark()
	Local nX	:= 0
	Local lInvert	:= ThisInv()
	Local LEXTMOV := .T.

	If cAlias == "SE2"
		If !IsMark("E2_OK", cMarca, lInvert)
			If RecLock("SE2",.F.)
				SE2->E2_OK := cMarca
				MsUnLock()
			EndIf
		Else
			If RecLock("SE2",.F.)
				SE2->E2_OK := space(2)
				MsUnLock()
			EndIf

			For nX := 1 to Len(aRecSel)
				If aRecSel[nX][1] == SE2->(Recno())
					aRecSel[nX][12] := .F.
					lExtMov := .F.
				EndIf
			Next nX
		EndIf
		If SE2->E2_OK == cMarca .AND. !lInvert
			If Len(aRecSel) > 0
				For nX := 1 to Len(aRecSel)
					If aRecSel[nX][1] == SE2->(Recno())
						aRecSel[nX][12] := .T.
						lExtMov := .F.
					EndIf
				Next nX
			EndIf
			If lExtMov
				AADD(aRecSel,{SE2->(Recno()),SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_VALOR,SE2->E2_SALDO,SE2->E2_SLPLAID,SE2->E2_TIPO,SE2->E2_PARCELA,cAlias,.T.})
			EndIf
		ElseIf SE2->E2_OK != cMarca .AND. lInvert .And. AllTrim(SE2->E2_OK) <> ""
			AADD(aRecSel,{SE2->(Recno()),SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_VALOR,SE2->E2_SALDO,SE2->E2_SLPLAID,SE2->E2_TIPO,SE2->E2_PARCELA,cAlias,.T.})
		EndIf
	ElseIf cAlias == "SE1"
		If !IsMark("E1_OK", cMarca, lInvert)
			If RecLock("SE1",.F.)
				SE1->E1_OK := cMarca
				MsUnLock()
			EndIf
		Else
			If RecLock("SE1",.F.)
				SE1->E1_OK := space(2)
				MsUnLock()
			EndIf
			For nX := 1 to Len(aRecSel)
				If aRecSel[nX][1] == SE1->(Recno())
					aRecSel[nX][12] := .F.
					lExtMov := .F.
				EndIf
			Next nX
		EndIf
		If SE1->E1_OK == cMarca .AND. !lInvert
			If Len(aRecSel) > 0
				For nX := 1 to Len(aRecSel)
					If aRecSel[nX][1] == SE1->(Recno())
						aRecSel[nX][12] := .T.
						lExtMov := .F.
					EndIf
				Next nX
			EndIf
			If lExtMov == .T.
				AADD(aRecSel,{SE1->(Recno()),SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_NUM,SE1->E1_PREFIXO,SE1->E1_VALOR,SE1->E1_SALDO,SE1->E1_SLPLAID,SE1->E1_TIPO,SE1->E1_PARCELA,cAlias,.T.})
			EndIf
		ElseIf SE1->E1_OK != cMarca .AND. lInvert .And. AllTrim(SE1->E1_OK) <> ""
			AADD(aRecSel,{SE1->(Recno()),SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_NUM,SE1->E1_PREFIXO,SE1->E1_VALOR,SE1->E1_SALDO,SE1->E1_SLPLAID,SE1->E1_TIPO,SE1->E1_PARCELA,cAlias,.T.})
		EndIf
	ElseIf cAlias == "SE5"
		If !IsMark("E5_OK", cMarca, lInvert)
			If RecLock("SE5",.F.)
				SE5->E5_OK := cMarca
				MsUnLock()
			EndIf
		Else
			If RecLock("SE5",.F.)
				SE5->E5_OK := space(2)
				MsUnLock()
			EndIf
			For nX := 1 to Len(aRecSel)
				If aRecSel[nX][1] == SE5->(Recno())
					aRecSel[nX][11] := .F.
					lExtMov := .F.
				EndIf
			Next nX
		EndIf
		If SE5->E5_OK == cMarca .AND. !lInvert
			If Len(aRecSel) > 0
				For nX := 1 to Len(aRecSel)
					If aRecSel[nX][1] == SE5->(Recno())
						aRecSel[nX][11] := .T.
						lExtMov := .F.
					EndIf
				Next nX
			EndIf
			If lExtMov == .T.
				AADD(aRecSel,{SE5->(Recno()),SE5->E5_CLIFOR, SE5->E5_LOJA, IIF(Empty(AllTrim(SE5->E5_NUMERO)),SUBSTR(AllTrim(SE5->E5_NUMCHEQ),1,13),AllTrim(SE5->E5_NUMERO)),SE5->E5_PREFIXO,SE5->E5_VALOR,SE5->E5_TIPODOC,SE5->E5_PARCELA,SE5->E5_SEQ,cAlias,.T.})
			EndIf

		ElseIf SE5->E5_OK != cMarca .AND. lInvert .And. AllTrim(SE5->E5_OK) <> ""
			AADD(aRecSel,{SE5->(Recno()),SE5->E5_CLIFOR, SE5->E5_LOJA, IIF(Empty(AllTrim(SE5->E5_NUMERO)),SUBSTR(AllTrim(SE5->E5_NUMCHEQ),1,13),AllTrim(SE5->E5_NUMERO)),SE5->E5_PREFIXO,SE5->E5_VALOR,SE5->E5_TIPODOC,SE5->E5_PARCELA,SE5->E5_SEQ,cAlias,.T.})
		EndIf
	EndIf
	MARKBREFRESH()
Return .T.

/*/{Protheus.doc} VisLote2
FunÁ„o utilizada para el recurso da MarkBrowse
@type
@author ARNALDO RAYMUNDO JR.
@since 25/01/2019
@version 1.0
/*/
Function VisLote2()
	Local cMarca	:= ThisMark()
	Local cAliasSE2	:= GetNextAlias()
	Local cFilSE2 	:= xFilial("SE2")
	Local cAliasSE1	:= GetNextAlias()
	Local cFilSE1 	:= xFilial("SE1")
	Local cAliasSE5	:= GetNextAlias()
	Local cFilSE5 	:= xFilial("SE5")
	Local oMark 	:= GetMarkBrow()

	aRecSel := {}

	If cAlias == "SE2"
		BeginSql alias cAliasSE2
				
			SELECT SE2.R_E_C_N_O_ RECNOSE2,
				SE2.E2_FORNECE, SE2.E2_LOJA, SE2.E2_NUM,SE2.E2_PREFIXO,SE2.E2_VALOR,
				SE2.E2_SALDO,SE2.E2_SLPLAID,SE2.E2_TIPO,SE2.E2_PARCELA
			FROM %table:SE2% SE2   
			WHERE SE2.E2_FILIAL = %exp:cFilSE2%
				AND SE2.E2_OK = %exp:cMarca%
				AND SE2.%notDel% 
								
		EndSql
		If (cAliasSE2)->(Eof())
			MsgInfo(OemToAnsi(STR0018),OemToAnsi(STR0005))  // "Ning˙n Ìtem seleccionado" "CONSEJO"
		Else
			While (cAliasSE2)->(!Eof())
				AADD(aRecSel,{(cAliasSE2)->RECNOSE2,(cAliasSE2)->E2_FORNECE, (cAliasSE2)->E2_LOJA, (cAliasSE2)->E2_NUM,(cAliasSE2)->E2_PREFIXO,(cAliasSE2)->E2_VALOR,(cAliasSE2)->E2_SALDO,(cAliasSE2)->E2_SLPLAID,(cAliasSE2)->E2_TIPO,(cAliasSE2)->E2_PARCELA,cAlias,.T.})
				(cAliasSE2)->( DbSkip() )
			EndDo
			MsgInfo(OemToAnsi(STR0004),OemToAnsi(STR0005)) // "Seleccionar Ìtem OK." "CONSEJO"
		EndIf

		(cAliasSE2)->(DbCloseArea())
	ElseIf cAlias == "SE1"
		BeginSql alias cAliasSE1
					
			SELECT SE1.R_E_C_N_O_ RECNOSE1,
				SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NUM,SE1.E1_PREFIXO,SE1.E1_VALOR,
				SE1.E1_SALDO,SE1.E1_SLPLAID,SE1.E1_TIPO,SE1.E1_PARCELA
			FROM %table:SE1% SE1   
			WHERE SE1.E1_FILIAL = %exp:cFilSE1%
				AND SE1.E1_OK = %exp:cMarca%
				AND SE1.%notDel% 								
		EndSql
		If (cAliasSE1)->(Eof())
			MsgInfo(OemToAnsi(STR0018),OemToAnsi(STR0005)) 	// "Seleccionar Ìtem OK." "CONSEJO"
		Else
			While (cAliasSE1)->(!Eof())
				AADD(aRecSel,{(cAliasSE1)->RECNOSE1,(cAliasSE1)->E1_CLIENTE, (cAliasSE1)->E1_LOJA, (cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_VALOR,(cAliasSE1)->E1_SALDO,(cAliasSE1)->E1_SLPLAID,(cAliasSE1)->E1_TIPO,(cAliasSE1)->E1_PARCELA,cAlias,.T.})
				(cAliasSE1)->( DbSkip() )
			EndDo
			MsgInfo(OemToAnsi(STR0004),OemToAnsi(STR0005)) //  "Seleccionar Ìtem OK." "CONSEJO"
		EndIf
		(cAliasSE1)->(DbCloseArea())

	ElseIf cAlias == "SE5"
		BeginSql alias cAliasSE5
			SELECT SE5.R_E_C_N_O_ RECNOSE5,
				SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_NUMERO,SE5.E5_NUMCHEQ,SE5.E5_DOCUMEN,SE5.E5_PREFIXO,SE5.E5_VALOR,
				SE5.E5_TIPODOC,SE5.E5_PARCELA,SE5.E5_SEQ
			FROM %table:SE5% SE5   
				WHERE SE5.E5_FILIAL = %exp:cFilSE5%
				AND SE5.E5_OK = %exp:cMarca%
				AND SE5.%notDel% 							
		EndSql

		If (cAliasSE5)->(Eof())
			MsgInfo(OemToAnsi(STR0018),OemToAnsi(STR0005)) //"No item selected."  "ADVICE"
		Else
			While (cAliasSE5)->(!Eof())
				AADD(aRecSel,{(cAliasSE5)->RECNOSE5,(cAliasSE5)->E5_CLIFOR, (cAliasSE5)->E5_LOJA, IIF(Empty(AllTrim((cAliasSE5)->E5_NUMERO)),SUBSTR(AllTrim((cAliasSE5)->E5_NUMCHEQ),1,13),AllTrim((cAliasSE5)->E5_NUMERO)),(cAliasSE5)->E5_PREFIXO,(cAliasSE5)->E5_VALOR,(cAliasSE5)->E5_TIPODOC,(cAliasSE5)->E5_PARCELA,(cAliasSE5)->E5_SEQ,cAlias,.T.})
				(cAliasSE5)->( DbSkip() )
			EndDo
			MsgInfo(OemToAnsi(STR0004),OemToAnsi(STR0005)) // "Seleccionar Ìtem OK." "CONSEJO"
		EndIf
		(cAliasSE5)->(DbCloseArea())
	EndIf
	MARKBREFRESH()
	oMark:oBrowse:Gotop()
	If cVersao == "11"
		CloseBrowse()
	Else
		oMark:oBrowse:Hide()
		CloseBrowse()
	EndIf
Return .T.


/*/{Protheus.doc} LimpaMarca
FunÁ„o utilizada para el limpiar marca de MarkBrowse
@type
@author ARNALDO RAYMUNDO JR.
@since 25/01/2019
@version 1.0
/*/
Function LimpaMarca()

	Local cMarca	:= ThisMark()
	Local lInvert	:= ThisInv()
	Local cAliasSE2 := GetNextAlias()
	Local cFilSE2   := xFilial("SE2")
	Local oMark := GetMarkBrow()

	If cAlias == "SE2"
		SE2->(DbGoTop())
		While SE2->(!Eof())
			RecLock("SE2",.F.)
			SE2->E2_OK := SPACE(2)
			SE2->(MsUnLock())
			SE2->(DBSkip())
		EndDo
	ElseIf cAlias == "SE1"
		SE1->(DbGoTop())
		While SE1->(!Eof())
			RecLock("SE1",.F.)
			SE1->E1_OK := SPACE(2)
			SE1->(MsUnLock())
			SE1->(DBSkip())
		EndDo
	Else
		SE5->(DbGoTop())
		While SE5->(!Eof())
			RecLock("SE5",.F.)
			SE5->E5_OK := SPACE(2)
			SE5->(MsUnLock())
			SE5->(DBSkip())
		EndDo
	EndIf
	aRecSel := {}
	MARKBREFRESH()
	oMark:oBrowse:Gotop()
Return

/*/{Protheus.doc} COMP021LPRE
Prevalidacion modelo del grid
@type
@author Mayra.Camargo
@since 25/01/2019
@version 1.0
/*/
Static Function COMP021LPRE( oModelGrid )

	Local lRet       := .T.
	Local oModel     := FWModelActive()
	Local cValLine := ""
	Local cValLinx := ""
	Local nNumLine := 0
	Local nQtdLin :=  0
	Local nX := 0

	If RVS->RVS_STATUS == 0
		lRet := .F.
		MsgInfo(OemToAnsi(STR0016),OemToAnsi(STR0017)) //"WARNING-COMP021LPRE" "Combination OK"
	ElseIf oModelGrid:IsDeleted()
		cValLine := oModelGrid:GetValue("RVT_DOC") + oModelGrid:GetValue("RVT_SERIE")+ oModelGrid:GetValue("RVT_CLIPRO") + oModelGrid:GetValue("RVT_LOJA") + oModelGrid:GetValue("RVT_TIPO")
		nNumLine := oModelGrid:nLine
		nQtdLin :=  oModelGrid:GetQtdLine()
		For nX := 1 to nQtdLin
			If nX <> nNumLine
				oModelGrid:GoLine( nX )
				cValLinx := oModelGrid:GetValue("RVT_DOC")+oModelGrid:GetValue("RVT_SERIE")+oModelGrid:GetValue("RVT_CLIPRO")+oModelGrid:GetValue("RVT_LOJA")+oModelGrid:GetValue("RVT_TIPO")

				If cValLine == cValLinx .and. !oModelGrid:IsDeleted()
					lRet := .F.
					MsgInfo(OemToAnsi(STR0019),OemToAnsi(STR0016)) // "Õtem existe en el GRID." "AVISO DE ALERTA-COMP021LPRE"
					Exit
				EndIf
			EndIf
		Next
		oModelGrid:GoLine( nNumLine )
	EndIf
Return lRet
/*/{Protheus.doc} COMP021LPOS
ValidaciÛn lÌnea de grid
@type
@author Mayra.Camargo
@since 25/01/2019
@version 1.0
/*/
Static Function COMP021LPOS( oModelGrid )

	Local lRet       	:= .T.
	Local oModel     	:= FWModelActive()
	Local nOperation 	:= iif(Empty(oModel),oModelGrid:GetOperation(),oModel:GetOperation())
	Local nValLine 		:= 0
	Local nNumLine 		:= 0
	Local nQtdLin 		:=  0
	Local nX 			:= 0

	// Valida se pode ou n„o apagar uma linha do Grid
	If nOperation == MODEL_OPERATION_UPDATE
		nValLine := oModelGrid:GetValue("RVT_OPPLAI")
		nNumLine := oModelGrid:nLine
		nQtdLin :=  oModelGrid:GetQtdLine()

		For nX := 1 to nQtdLin
			oModelGrid:GoLine( nX )
			If nX <> nNumLine .and. !(oModelGrid:isdeleted())
				nValLinx := oModelGrid:GetValue("RVT_OPPLAI")
				nValLine += nValLinx
				If nValLine >  IIF(RVS->RVS_VALDEB <> 0, RVS->RVS_VALDEB, RVS->RVS_VALCRE)
					lRet := .F.
					MsgInfo(OemToAnsi(STR0021),OemToAnsi(STR0020)) // "valor total de los Ìtems es mayor que el valor total PLAID." "Help-COMP021LPOS"
					Exit
				EndIf
			EndIf
		Next
	EndIf
	oModelGrid:GoLine(nNumLine)

Return lRet
/*/{Protheus.doc} ZIValIMP
FunciÛn DE VALIDACION utilizada en campo RVT_OPPLAI
@type
@author Mayra.Camargo
@since 25/01/2019
@version 1.0
/*/
Function ZIValIMP()
	Local lRet       	:= .T.
	Local oModel     	:= FWModelActive()
	Local oModelGrid	:= oModel:GetModel('RVTDETAIL')
	Local oModelCab   	:= oModel:GetModel('RVSMASTER')
	Local nValSld 		:= oModelGrid:GetValue("RVT_SLPLAI")
	Local nValLine 		:= oModelGrid:GetValue("RVT_OPPLAI")
	Local nSldTit 		:= oModelGrid:GetValue("RVT_SALDO")
	Local cCategory 	:= oModelGrid:GetValue("RVT_CATEGO")
	Local cTipo 		:= oModelGrid:GetValue("RVT_TIPO")



	If nValLine > nValSld .and. Empty(AllTrim(cCategory)) .and. !Empty(AllTrim(cTipo))
		MsgInfo(OemToAnsi(STR0028),OemToAnsi(STR0022))  // "Õtem total m·s total de MOVIMIENTO PLAID." "Aviso-ZIValIMP"
		Conout( "Linha "+AllTrim(Str(ProcLine())))
		lRet := .F.
	EndIf

	If nValLine > nSldTit .and. Empty(AllTrim(cCategory)) .and. Empty(AllTrim(cTipo))
		lAux := oModelGrid:SETVALUE("RVT_VLDOP",0)
	EndIf

	If nValLine >  IIF(oModelCab:GetValue("RVS_VALDEB") <> 0, oModelCab:GetValue("RVS_VALDEB"), oModelCab:GetValue("RVS_VALCRE"))
		lRet := .F.
		MsgInfo(OemToAnsi(STR0028),OemToAnsi(STR0022)) // "Õtem total m·s total de MOVIMIENTO PLAID." "Aviso-ZIValIMP"
		Conout( "Linha "+AllTrim(Str(ProcLine())))
	EndIf

	If nSldTit < nValLine .and. !Empty(AllTrim(oModelGrid:GetValue("RVT_ORIGEN")))
		lRet := .F.
		MsgInfo(OemToAnsi(STR0029),OemToAnsi(STR0022))// "Õtem total m·s total de MOVIMIENTO PLAID." "Aviso-ZIValIMP"
		Conout( "Linha "+AllTrim(Str(ProcLine())))
	EndIf

Return lRet

/*/{Protheus.doc} ZIValIMP2
FunciÛn DE VALIDACION utilizada en campo RVT_VLDOP 
@type
@author Mayra.Camargo
@since 25/01/2019
@version 1.0
/*/
Function ZIValIMP2()
	Local lRet       	:= .T.
	Local oModel     	:= FWModelActive()
	Local oModelGrid	:= oModel:GetModel( 'RVTDETAIL' )
	Local oModelCab   	:= oModel:GetModel( 'RVSMASTER' )
	Local nValLine 		:= oModelGrid:GetValue("RVT_OPPLAI")
	Local nSldTit 		:= oModelGrid:GetValue("RVT_SALDO")
	Local nOPTit 		:= oModelGrid:GetValue("RVT_VLDOP")
	Local cTipo 		:= oModelGrid:GetValue("RVT_TIPO")

	If nOPTit > nSldTit .and. !Empty(AllTrim(cTipo))
		Conout( "Linha "+AllTrim(Str(ProcLine())))
		MsgInfo(OemToAnsi(STR0031),OemToAnsi(STR0030)) //"Value applied ZI_VLDOP greater than VALUE OF THE BILL."     "Warning-ZIValIMP2"
		lAux := oModelGrid:SETVALUE("RVT_VLDOP",0)
		lRet := .F.
	EndIf

	If nOPTit > nValLine
		Conout( "Linha "+AllTrim(Str(ProcLine())))
		MsgInfo(OemToAnsi(STR0032),OemToAnsi(STR0030))// "Value applied ZI_VLDOP greater than PLAID Value."    "Warning-ZIValIMP2"
		lAux := oModelGrid:SETVALUE("RVT_VLDOP",0)
		lRet := .F.
	EndIf

	If nOPTit >  IIF(oModelCab:GetValue("RVS_VALDEB") <> 0, oModelCab:GetValue("RVS_VALDEB"), oModelCab:GetValue("RVS_VALCRE"))
		Conout( "Linha "+AllTrim(Str(ProcLine())))
		lRet := .F.
		MsgInfo(OemToAnsi(STR0033),OemToAnsi(STR0030)) //"VLDOP M¡S VAL ENCABEZADO PLAID" "Aviso-ZIValIMP2"
	EndIf

Return lRet

//-------------------------------------
/*	Modelo de Dados
@author  	Leandro Paulino / Jefferson Tomaz
@version 	P10 R1.4
@build		7.00.101202A
@since 		06/04/2011
@Return 		oModel Objeto do Modelo*/
//-------------------------------------
Static Function ModelDef()
	Local oModel 	   	:= Nil
	Local oStructRVS	:= Nil
	Local oStructRVT	:= Nil
	Local nTamTot		:= TamSX3('RVS_VALDEB')[1]		// Tamanho do campo.
	Local nDecTot		:= TamSX3('RVS_VALDEB')[2]		// Numero de decimais do campo.
    
	oStructRVS := FwFormStruct(1,"RVS")
	oStructRVT := FwFormStruct(1,"RVT")

	oModel := MPFormModel():New('COMPRVSM',,{ |oMdl |GrvItPlaid(oMdl ) } )
	oModel:AddFields( 'RVSMASTER', /*cOwner*/, oStructRVS)
	oModel:AddGrid( 'RVTDETAIL', 'RVSMASTER', oStructRVT,{ |oModelGrid| COMP021LPRE((oModelGrid)) },{ |oModelGrid| COMP021LPOS((oModelGrid)) }) 
	oModel:AddCalc("CALC", "RVSMASTER", "RVTDETAIL", "RVT_OPPLAI", "RVT__AVP1", "SUM", {||.T.}, /*bInitValue*/, /*cTitle*/ STR0063, /*bFormula*/ /*{|| U_FTMDLAVP(1)}*/ ) //  "Total Posted"
	//-- Total Geral
	oModel:AddCalc('CALC','RVSMASTER',"RVTDETAIL","RVT_OPPLAI","RVT__TOTPL","FORMULA",{|| .T. },/*bInitValue*/, STR0064,{|oModel| ( oModel:GetValue("RVSMASTER",'RVS_VALDEB') + oModel:GetValue("RVSMASTER",'RVS_VALCRE')) - oModel:GetValue("CALC",'RVT__AVP1')  },nTamTot,nDecTot) // "Saldo Restante

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'RVTDETAIL', { { 'RVT_FILIAL', 'xFilial( "RVT" )' }, { 'RVT_ID', 'RVS_ID' } }, RVT->( IndexKey( 1 ) ) )

	oModel:SetDescription(STR0006)
	oModel:GetModel('RVSMASTER'):SetDescription('Descripcion del MODELDEF_1')
	oModel:GetModel('RVTDETAIL'):SetDescription('Descripcion del MODELDEF_2')
	oModel:GetModel('RVTDETAIL'):SetOptional( .T. )	
	oModel:SetPrimaryKey({"RVS_COD","RVS_AGENCIA","RVS_NOMEAGE"})

Return ( oModel )

//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'FINA884' )
	// Cria a estrutura a ser usada na View
	Local oStruRVS := FWFormStruct( 2, 'RVS' )
	Local oStruRVT := FWFormStruct( 2, 'RVT' )
	Local oView  
	Local oStr4		:= FWCalcStruct( oModel:GetModel('CALC') )

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser· utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('VIEW_RVS', oStruRVS, 'RVSMASTER' )
	oView:AddGrid( 'VIEW_RVT', oStruRVT, 'RVTDETAIL' )
	oView:AddField('FORM9', oStr4,'CALC')
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox('SUPERIOR', 30)
	oView:CreateHorizontalBox('INFERIOR', 60)
	oView:CreateHorizontalBox('BOXFORM9', 10)
	// Quebra em 2 "box" vertical para receber algum elemento da view
	oView:CreateVerticalBox('EMBAIXOESQ', 90, 'INFERIOR')
	oView:CreateVerticalBox('EMBAIXODIR', 10, 'INFERIOR')
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('VIEW_RVS', 'SUPERIOR')
	oView:SetOwnerView('VIEW_RVT', 'EMBAIXOESQ')
	oView:SetOwnerView('FORM9','BOXFORM9')
	// Liga a identificacao do componente
	oView:EnableTitleView('VIEW_RVT', "PLAID VS SIGAFIN")

	// Define campos que terao Auto Incremento
	oView:AddIncrementField('VIEW_RVT', 'RVT_ITEM')
	oView:AddOtherObject("OTHER_PANEL", {|oView| COMP23BUT(oView)})
	// Associa ao box que ira exibir os outros objetos
	oView:SetOwnerView("OTHER_PANEL",'EMBAIXODIR')

Return oView
/*/{Protheus.doc} PlaidMatch
Obtiene movimientos bancarios
@type method
@author mayra.camargo
@since 25/01/2019
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function PlaidMatch()

	Local oModel		:= FWModelActive()
	Local oModelZA2		:= oModel:GetModel( 'RVTDETAIL' )
	Local oModelRVS		:= oModel:GetModel( 'RVSMASTER' )
	Local nLinha 		:= oModelZA2:Length()
	Local nX 			:= 0
	Local nValPPlaid 	:= 0
	Local nValGenOP 	:= 0
	Local lUpdateLin 	:= .F.
	Local lInserLin 	:= .F.
	Local lDeletLin 	:= .F.
	Local cFilSE2Doc 	:= ""
	Local cFilRVTDoc 	:= ""
	Local lMatch		:= .F.
	Local lAux 			:= .T.
	Local oView     	:= FWViewActive()
	Local cHistory 		:= ""
	Local cCategor 		:= "NOR"
	Local lReload		:=.F.

	Private cHistor 	:= ""
	Private cDocRel   	:= ""
	Private nOpcBan 	:= 3
	Private cNaturez 	:= ""
	Private cContSA6 	:= ""
	Private cTipoDoc 	:= ""
	Private dMovBank

	If oModelRVS:GetValue("RVS_STATUS") == 0
		MsgInfo(OemToAnsi(STR0034),OemToAnsi(STR0017))  //  "WARNING-PlaidMatch"   "Combination OK"
		Return .F.
	EndIf


	For nX := 1 to nLinha
		oModelZA2:GoLine( nX )

		If oModelZA2:IsDeleted()
			Loop
		EndIf

		nValPPlaid += oModelZA2:GetValue("RVT_OPPLAI")
		If	oModelZA2:GetValue("RVT_TIPO") $ "NF" .and. Empty(oModelZA2:GetValue("RVT_ORIGEN"))
			MsgInfo(OemToAnsi(STR0035),OemToAnsi(STR0040))  //"Total value of items other than Plaid value"    "Invalid Document Type"
			lMatch := .F.
			Return(lMatch)
		EndIf

	Next

	If nValPPlaid <> IIF(oModelRVS:GetValue("RVS_VALDEB") <> 0, oModelRVS:GetValue("RVS_VALDEB"),oModelRVS:GetValue("RVS_VALCRE"))
		MsgInfo(OemToAnsi(STR0035),OemToAnsi(STR0034)) //"Total value of items other than Plaid value"  "WARNING-PlaidMatch"
		lMatch := .F.
		Return(lMatch)
	EndIf


	For nX := 1 to nLinha
		oModelZA2:GoLine( nX )
		lUpdateLin 	:= oModelZA2:IsUpdated()
		lInserLin  	:= oModelZA2:IsInserted()
		lDeletLin  	:= oModelZA2:IsDeleted()
		nValPPlaid 	:= oModelZA2:GetValue("RVT_OPPLAI")
		nValGenOP  	:= oModelZA2:GetValue("RVT_VLDOP")
		cOrigen    	:= oModelZA2:GetValue("RVT_ORIGEN")
		cTipoDoc   	:= oModelZA2:GetValue("RVT_TIPO")
		cNaturez	:= oModelZA2:GetValue("RVT_CATEGO")
		cContSA6   	:= POSICIONE("SED",1,xFilial("SED")+oModelZA2:GetValue("RVT_CATEGO"),"ED_CONTA")
		cHistor    	:= oModelZA2:GetValue("RVT_OBS")
		cDocRel  	:= oModelZA2:GetValue("RVT_DOC")
		dMovBank  	:= oModelRVS:GetValue("RVS_DATA")

		If oModelRVS:GetValue("RVS_VALDEB") <> 0
			nOpcBan := 3
		Else
			nOpcBan := 4
		EndIf

		If (!lDeletLin .and. !lInserLin .and. lUpdateLin) .or. (!lDeletLin .and. lInserLin ) .or. (!lDeletLin .and. !lInserLin .and. !lUpdateLin)
			If cOrigen == "SE2"
				DbSelectArea("SE2")

				cFilSE2Doc := xFilial("SE2") + oModelZA2:GetValue("RVT_SERIE")+oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")+ oModelZA2:GetValue("RVT_CLIPRO")+oModelZA2:GetValue("RVT_LOJA")
				If oModelZA2:GetValue("RVT_OPPLAI") == 0
					oModelZA2:DeleteLine()
				Else
					cHistory += AllTrim(oModelZA2:GetValue("RVT_DOC")) +"-"+ AllTrim(oModelZA2:GetValue("RVT_SERIE")) + "-" + AllTrim(oModelZA2:GetValue("RVT_PARCEL")) + "-" + AllTrim(oModelZA2:GetValue("RVT_TIPO")) + "-" + AllTrim(oModelZA2:GetValue("RVT_CLIPRO")) + "-" + AllTrim(oModelZA2:GetValue("RVT_LOJA"))+"/ "
				EndIf
				If SE2->(MsSeek(cFilSE2Doc))
					If(!lDeletLin .and. lInserLin )
						If Reclock("SE2",.F.)
							Replace SE2->E2_SLPLAID With  SE2->E2_SLPLAID - nValPPlaid
							SE2->(MSUnlock())
						EndIf
					Else
						DbSelectArea("RVT")
						DbSetorder(1)
						cFilRVTDoc := xFilial("RVT") +oModelZA2:GetValue("RVT_ID")  + oModelZA2:GetValue("RVT_ITEM") //+ oModelZA2:GetValue("RVT_SERIE")+oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")+ oModelZA2:GetValue("RVT_CLIPRO")+oModelZA2:GetValue("RVT_LOJA")
						If RVT->(MsSeek(cFilRVTDoc))
							nSLPLAID := RVT->RVT_OPPLAI - nValPPlaid
							If Reclock("SE2",.F.)
								Replace SE2->E2_SLPLAID With  SE2->E2_SLPLAID + nSLPLAID
								SE2->(MSUnlock())
							EndIf
						EndIf
					EndIf
					If nValGenOP > 0
						lMatch:=PlaidBxTit("SE2",SE2->(Recno()),nValGenOP,cCategor)
						lAux :=  oModelZA2:SETValue("RVT_SEQ",SE5->(RECNO()))
					EndIf
				EndIf
			ElseIf cOrigen == "SE1"
				DbSelectArea("SE1")
				DbSetorder(2)
				cFilSE2Doc := xFilial("SE1") + oModelZA2:GetValue("RVT_CLIPRO")+oModelZA2:GetValue("RVT_LOJA") + oModelZA2:GetValue("RVT_SERIE")+oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")
				If oModelZA2:GetValue("RVT_OPPLAI") == 0
					oModelZA2:DeleteLine()
				Else
					cHistory += AllTrim(oModelZA2:GetValue("RVT_DOC")) +"-"+ AllTrim(oModelZA2:GetValue("RVT_SERIE")) + "-" + AllTrim(oModelZA2:GetValue("RVT_PARCEL")) + "-" + AllTrim(oModelZA2:GetValue("RVT_TIPO")) + "-" + AllTrim(oModelZA2:GetValue("RVT_CLIPRO")) + "-" + AllTrim(oModelZA2:GetValue("RVT_LOJA"))+"/"
				EndIf
				If SE1->(MsSeek(cFilSE2Doc))
					If(!lDeletLin .and. lInserLin )
						If Reclock("SE1",.F.)
							Replace SE1->E1_SLPLAID With  SE1->E1_SLPLAID - nValPPlaid
							MSUnlock()
						EndIf
					Else
						DbSelectArea("RVT")
						DbSetorder(1)
						cFilRVTDoc := xFilial("RVT") +oModelZA2:GetValue("RVT_ID")  + oModelZA2:GetValue("RVT_ITEM")
						If RVT->(MsSeek(cFilRVTDoc))
							nSLPLAID := RVT->RVT_OPPLAI - nValPPlaid
							If Reclock("SE1",.F.)
								Replace SE1->E1_SLPLAID With  SE1->E1_SLPLAID + nSLPLAID
								MSUnlock()
							EndIf
						EndIf
					EndIf

					If nValGenOP > 0
						lMatch:=PlaidBxTit("SE1",SE1->(Recno()),nValGenOP,cCategor)
						lAux :=  oModelZA2:SETValue("RVT_SEQ",SE5->(RECNO()))
					EndIf
				EndIf

			ElseIf cOrigen == "SE5"
				DbSelectArea("SE5")
				SE5->(DbGoto(oModelZA2:GetValue("RVT_SEQ")))
				If oModelZA2:GetValue("RVT_OPPLAI") == 0
					oModelZA2:DeleteLine()
				ElseIf !SE5->(eof())
					cHistory +=  AllTrim(oModelZA2:GetValue("RVT_CATEGO")) + "-" + AllTrim(oModelZA2:GetValue("RVT_DOC")) + "-" + AllTrim(oModelZA2:GetValue("RVT_TIPO"))+"/ "
					lMatch:=.T.
					If Reclock("SE5",.F.)
						Replace SE5->E5_INTPLAI With  "I"
						SE5->(MSUnlock())
					EndIf

				EndIf
			ElseIf Empty(AllTrim(cOrigen))
				If nValPPlaid > 0
					cHistory +=  AllTrim(oModelZA2:GetValue("RVT_CATEGO")) + "-" + AllTrim(oModelZA2:GetValue("RVT_DOC")) + "-" + AllTrim(oModelZA2:GetValue("RVT_TIPO"))+"/ "
					If oModelRVS:GetValue("RVS_VALCRE") > 0
						lMatch:=PlaidBxTit("SE5",0,nValPPlaid,cCategor,4)
					Else
						lMatch:=PlaidBxTit("SE5",0,nValPPlaid,cCategor,3)
					EndIf
					lReload		:=.T.
				Else
					oModelZA2:DeleteLine()
				EndIf
			EndIf
		ElseIf (lDeletLin .and. !lInserLin)
			If cOrigen == "SE2"
				DbSelectArea("SE2")
				DbSetorder(1)
				cFilSE2Doc := xFilial("SE2") + oModelZA2:GetValue("RVT_SERIE")+oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")+ oModelZA2:GetValue("RVT_CLIPRO")+oModelZA2:GetValue("RVT_LOJA")
				If SE2->(MsSeek(cFilSE2Doc))
					DbSelectArea("RVT")
					DbSetorder(1)
					cFilRVTDoc := xFilial("RVT") +oModelZA2:GetValue("RVT_ID")  + oModelZA2:GetValue("RVT_ITEM") //+ oModelZA2:GetValue("RVT_SERIE")+oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")+ oModelZA2:GetValue("RVT_CLIPRO")+oModelZA2:GetValue("RVT_LOJA")
					If RVT->(MsSeek(cFilRVTDoc))
						nSLPLAID := RVT->RVT_OPPLAI

						If Reclock("SE2",.F.)
							Replace SE2->E2_SLPLAID With  SE2->E2_SLPLAID + nSLPLAID
							MSUnlock()
						EndIf
					EndIf
				EndIf
			ElseIf cOrigen == "SE1"
				DbSelectArea("SE1")
				DbSetorder(2)
				cFilSE2Doc := xFilial("SE1") + oModelZA2:GetValue("RVT_CLIPRO")+oModelZA2:GetValue("RVT_LOJA") + oModelZA2:GetValue("RVT_SERIE")+oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")

				If SE1->(MsSeek(cFilSE2Doc))
					DbSelectArea("RVT")
					DbSetorder(1)
					cFilRVTDoc := xFilial("RVT") + oModelZA2:GetValue("RVT_ID")  + oModelZA2:GetValue("RVT_ITEM")
					If RVT->(MsSeek(cFilRVTDoc))
						nSLPLAID := RVT->RVT_OPPLAI
						If Reclock("SE1",.F.)
							Replace SE1->E1_SLPLAID With  SE1->E1_SLPLAID + nSLPLAID
							MSUnlock()
						EndIf
					EndIf
				EndIf
			ElseIf cOrigen == "SE5"
				DbSelectArea("SE5")
				SE5->(DbGoto(oModelZA2:GetValue("RVT_SEQ")))
				If!eof()
					If Reclock("SE5",.F.)
						Replace SE5->E5_INTPLAI With  " "
						MSUnlock()
					EndIf
				EndIf
			EndIf
		EndIf
	Next nX

	If lMatch
		lAux := oModelRVS:SETVALUE("RVS_STATUS",0)
		lAux := oModelRVS:SETVALUE("RVS_DOCREL",AllTrim(cHistory))
		DbSelectArea("RVS")
		DbSetorder(1)
		If RVS->(MsSeek(xFilial("RVS") + oModelRVS:GetValue("RVS_ID")))
			If Reclock("RVS",.F.)
				Replace RVS->RVS_STATUS	With 0
				Replace RVS->RVS_DOCREL	With AllTrim(cHistory)
				MsUnlock()
			EndIf
		EndIf

		oView:Refresh()
		oView:SetCloseOnOk({||.T.})
		oView:ButtonOkAction(.T.)

	EndIf

Return lMatch
/*/{Protheus.doc} GrvItPlaid
funcion para generar relaciÛn entre movimientos plaid y movimientos bancarios
@type define
@author mayra.camargo
@since 25/01/2019
@version 1.0
/*/
Static Function GrvItPlaid(oMdl)

	Local oModel		:= FWModelActive()
	Local oModelZA2		:= oMdl:GetModel('RVTDETAIL')
	Local oModelRVS		:= oMdl:GetModel('RVSMASTER')
	Local nLinha 		:= oModelZA2:Length()
	Local nX 			:= 0
	Local nValPPlaid 	:= 0
	Local nValGenOP 	:= 0
	Local lUpdateLin 	:= .F.
	Local lInserLin 	:= .F.
	Local lDeletLin 	:= .F.
	Local cFilSE2Doc 	:= ""
	Local cFilRVTDoc 	:= ""
	Local nOperation 	:= iif(Empty(oModel),oMdl:GetOperation(),oModel:GetOperation())
	Local lRet 			:= .T.
	Local nLinDel 		:= 0

	If oModelRVS:GetValue("RVS_STATUS") == 0
		lRet := .F.
		MsgInfo(OemToAnsi(STR0039),OemToAnsi(STR0017))  // "Successfully "     "Combination OK"
	ElseIf	nOperation == MODEL_OPERATION_DELETE .and. oModelRVS:GetValue("RVS_STATUS") <> 0

		For nX := 1 to nLinha
			oModelZA2:GoLine( nX )
			lUpdateLin 	:= oModelZA2:IsUpdated()
			lInserLin  	:= oModelZA2:IsInserted()
			lDeletLin  	:= oModelZA2:IsDeleted()

			nValPPlaid	:= oModelZA2:GetValue("RVT_OPPLAI")
			nValGenOP  	:= oModelZA2:GetValue("RVT_VLDOP")
			cOrigen    	:= oModelZA2:GetValue("RVT_ORIGEN")

			If cOrigen == "SE2"
				DbSelectArea("SE2")
				DbSetorder(1)
				cFilSE2Doc := xFilial("SE2") + oModelZA2:GetValue("RVT_SERIE") + oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")+ oModelZA2:GetValue("RVT_CLIPRO") + oModelZA2:GetValue("RVT_LOJA")

				If SE2->(MsSeek(cFilSE2Doc)) .and.  oModelZA2:GetValue("RVT_SEQ") == 0
					DbSelectArea("RVT")
					DbSetorder(1)
					cFilRVTDoc := xFilial("RVT") +oModelZA2:GetValue("RVT_ID")  + oModelZA2:GetValue("RVT_ITEM")
					If RVT->(MsSeek(cFilRVTDoc))
						nSLPLAID := RVT->RVT_OPPLAI
						If Reclock("SE2",.F.)
							Replace SE2->E2_SLPLAID With  SE2->E2_SLPLAID + nSLPLAID
							MSUnlock()
						EndIf
					EndIf
				Else
					DbSelectArea("SE5")
					SE5->(DbGoto(oModelZA2:GetValue("RVT_SEQ")))
					If !eof()
						If Reclock("SE5",.F.)
							Replace SE5->E5_INTPLAI With  " "
							MSUnlock()
						EndIf
					EndIf
					lAux := oModelRVS:SETVALUE("RVS_STATUS",2)
					DbSelectArea("RVS")
					DbSetorder(1)
					If RVS->(MsSeek(xFilial("RVS") + oModelRVS:GetValue("RVS_ID")))
						If Reclock("RVS",.F.)
							Replace RVS->RVS_STATUS With 2
							MsUnlock()
						EndIf
					EndIf
				EndIf
			ElseIf cOrigen == "SE1"
				DbSelectArea("SE1")
				DbSetorder(2)
				cFilSE2Doc := xFilial("SE1") + oModelZA2:GetValue("RVT_CLIPRO")+oModelZA2:GetValue("RVT_LOJA") + oModelZA2:GetValue("RVT_SERIE")+oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")
				If SE1->(MsSeek(cFilSE2Doc)) .and.  oModelZA2:GetValue("RVT_SEQ") == 0
					DbSelectArea("RVT")
					DbSetorder(1)
					cFilRVTDoc := xFilial("RVT") +oModelZA2:GetValue("RVT_ID")  + oModelZA2:GetValue("RVT_ITEM")
					If RVT->(MsSeek(cFilRVTDoc))
						nSLPLAID := RVT->RVT_OPPLAI
						If Reclock("SE1",.F.)
							Replace SE1->E1_SLPLAID With  SE1->E1_SLPLAID + nSLPLAID
							MSUnlock()
						EndIf
					EndIf
				EndIf
			ElseIf cOrigen == "SE5"
				DbSelectArea("SE5")
				SE5->(DbGoto(oModelZA2:GetValue("RVT_SEQ")))
				If!eof()
					If Reclock("SE5",.F.)
						Replace SE5->E5_INTPLAI With  " "
						MSUnlock()
					EndIf
				EndIf
			EndIf
		Next nX
	ElseIf	nOperation == MODEL_OPERATION_UPDATE
		For nX := 1 to nLinha
			oModelZA2:GoLine( nX )
			lUpdateLin := oModelZA2:IsUpdated()
			lInserLin  := oModelZA2:IsInserted()
			lDeletLin  := oModelZA2:IsDeleted()
			If lDeletLin
				nLinDel += 1
			EndIf
			nValPPlaid 	:= oModelZA2:GetValue("RVT_OPPLAI")
			nValGenOP	:= oModelZA2:GetValue("RVT_VLDOP")
			cOrigen    	:= oModelZA2:GetValue("RVT_ORIGEN")

			If(!lDeletLin .and. !lInserLin .and. lUpdateLin) .or. (!lDeletLin .and. lInserLin )
				If cOrigen == "SE2"
					DbSelectArea("SE2")
					DbSetorder(1)// E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
					cFilSE2Doc := xFilial("SE2") + oModelZA2:GetValue("RVT_SERIE")+oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")+ oModelZA2:GetValue("RVT_CLIPRO")+oModelZA2:GetValue("RVT_LOJA")

					If SE2->(MsSeek(cFilSE2Doc)) .and. oModelZA2:GetValue("RVT_SEQ") == 0
						If(!lDeletLin .and. lInserLin )
							If Reclock("SE2",.F.)
								Replace SE2->E2_SLPLAID With  SE2->E2_SLPLAID - nValPPlaid
								MSUnlock()
							EndIf
						Else
							DbSelectArea("RVT")
							DbSetorder(1) // RVT_FILIAL + RVT_ID + RVT_ITEM
							cFilRVTDoc := xFilial("RVT") +oModelZA2:GetValue("RVT_ID")  + oModelZA2:GetValue("RVT_ITEM") //+ oModelZA2:GetValue("RVT_SERIE")+oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")+ oModelZA2:GetValue("RVT_CLIPRO")+oModelZA2:GetValue("RVT_LOJA")
							If RVT->(MsSeek(cFilRVTDoc))
								nSLPLAID := RVT->RVT_OPPLAI - nValPPlaid
								If Reclock("SE2",.F.)
									Replace SE2->E2_SLPLAID With  SE2->E2_SLPLAID + nSLPLAID
									MSUnlock()
								EndIf
							EndIf
						EndIf
					EndIf
				ElseIf cOrigen == "SE1"
					DbSelectArea("SE1")
					DbSetorder(2) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					cFilSE2Doc := xFilial("SE1") + oModelZA2:GetValue("RVT_CLIPRO")+oModelZA2:GetValue("RVT_LOJA") + oModelZA2:GetValue("RVT_SERIE")+oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")

					If SE1->(MsSeek(cFilSE2Doc)) .and. oModelZA2:GetValue("RVT_SEQ") == 0
						If(!lDeletLin .and. lInserLin )
							If Reclock("SE1",.F.)
								Replace SE1->E1_SLPLAID With  SE1->E1_SLPLAID - nValPPlaid
								MSUnlock()
							EndIf
						Else
							DbSelectArea("RVT")
							DbSetorder(1) // RVT_FILIAL + RVT_ID + RVT_ITEM
							cFilRVTDoc := xFilial("RVT") +oModelZA2:GetValue("RVT_ID")  + oModelZA2:GetValue("RVT_ITEM")
							If RVT->(MsSeek(cFilRVTDoc))
								nSLPLAID := RVT->RVT_OPPLAI - nValPPlaid
								If Reclock("SE1",.F.)
									Replace SE1->E1_SLPLAID With  SE1->E1_SLPLAID + nSLPLAID
									MSUnlock()
								EndIf
							EndIf
						EndIf
						lAux := oModelRVS:SETVALUE("RVS_STATUS",2)
						DbSelectArea("RVS")
						DbSetorder(1) // RVS_FILIAL + RVS_ID
						If RVS->(MsSeek(xFilial("RVS") + oModelRVS:GetValue("RVS_ID")))
							If Reclock("RVS",.F.)
								Replace RVS->RVS_STATUS With 2
								MsUnlock()
							EndIf
						EndIf
					EndIf
				ElseIf cOrigen == "SE5"
					DbSelectArea("SE5")
					SE5->(DbGoto(oModelZA2:GetValue("RVT_SEQ")))
					If !eof()
						If Reclock("SE5",.F.)
							Replace SE5->E5_INTPLAI With  "I"//SE1->E1_SLPLAID - nValPPlaid
							MSUnlock()
						EndIf
					EndIf
				EndIf

				lAux := oModelRVS:SETVALUE("RVS_STATUS",2)
				DbSelectArea("RVS")
				DbSetorder(1) // RVS_FILIAL + RVS_ID
				If RVS->(MsSeek(xFilial("RVS") + oModelRVS:GetValue("RVS_ID")))
					If Reclock("RVS",.F.)
						Replace RVS->RVS_STATUS With 2
						MsUnlock()
					EndIf
				EndIf
			ElseIf(lDeletLin .and. !lInserLin) .or. (lDeletLin .and. oModelZA2:GetValue("RVT_SEQ") <> 0 )
				If cOrigen == "SE2"
					DbSelectArea("SE2")
					DbSetorder(1) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					cFilSE2Doc := xFilial("SE2") + oModelZA2:GetValue("RVT_SERIE")+oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")+ oModelZA2:GetValue("RVT_CLIPRO")+oModelZA2:GetValue("RVT_LOJA")

					If SE2->(MsSeek(cFilSE2Doc)) .and.  oModelZA2:GetValue("RVT_SEQ") == 0
						DbSelectArea("RVT")
						DbSetorder(1) // // RVT_FILIAL + RVT_ID + RVT_ITEM
						cFilRVTDoc := xFilial("RVT") +oModelZA2:GetValue("RVT_ID")  + oModelZA2:GetValue("RVT_ITEM") //+ oModelZA2:GetValue("RVT_SERIE")+oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")+ oModelZA2:GetValue("RVT_CLIPRO")+oModelZA2:GetValue("RVT_LOJA")
						If RVT->(MsSeek(cFilRVTDoc))
							nSLPLAID := RVT->RVT_OPPLAI

							If Reclock("SE2",.F.)
								Replace SE2->E2_SLPLAID With  SE2->E2_SLPLAID + nSLPLAID
								MSUnlock()
							EndIf
						EndIf
					Else
						DbSelectArea("SE5")
						SE5->(DbGoto(oModelZA2:GetValue("RVT_SEQ")))
						If !eof()
							If Reclock("SE5",.F.)
								Replace SE5->E5_INTPLAI With  " "//SE1->E1_SLPLAID - nValPPlaid
								MSUnlock()
							EndIf
						EndIf

						lAux := oModelRVS:SETVALUE("RVS_STATUS",2)
						DbSelectArea("RVS")
						DbSetorder(1)// RVS_FILIAL + RVS_ID
						If RVS->(MsSeek(xFilial("RVS") + oModelRVS:GetValue("RVS_ID")))
							If Reclock("RVS",.F.)
								Replace RVS->RVS_STATUS With 2
								MsUnlock()
							EndIf
						EndIf
					EndIf
				ElseIf cOrigen == "SE1"
					DbSelectArea("SE1")
					DbSetorder(2) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					cFilSE2Doc := xFilial("SE1") + oModelZA2:GetValue("RVT_CLIPRO")+oModelZA2:GetValue("RVT_LOJA") + oModelZA2:GetValue("RVT_SERIE")+oModelZA2:GetValue("RVT_DOC")+ oModelZA2:GetValue("RVT_PARCEL") + oModelZA2:GetValue("RVT_TIPO")
					If SE1->(MsSeek(cFilSE2Doc)) .and.  oModelZA2:GetValue("RVT_SEQ") == 0
						DbSelectArea("RVT")
						DbSetorder(1)// RVT_FILIAL + RVT_ID + RVT_ITEM
						cFilRVTDoc := xFilial("RVT") +oModelZA2:GetValue("RVT_ID")  + oModelZA2:GetValue("RVT_ITEM")
						If RVT->(MsSeek(cFilRVTDoc))
							nSLPLAID := RVT->RVT_OPPLAI
							If Reclock("SE1",.F.)
								Replace SE1->E1_SLPLAID With  SE1->E1_SLPLAID + nSLPLAID
								MSUnlock()
							EndIf
						EndIf
					EndIf
				ElseIf cOrigen == "SE5"
					DbSelectArea("SE5")
					SE5->(DbGoto(oModelZA2:GetValue("RVT_SEQ")))
					If !eof()
						If Reclock("SE5",.F.)
							Replace SE5->E5_INTPLAI With  " "
							MSUnlock()
						EndIf
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf

	If nLinha == nLinDel
		If oModelRVS:GetValue("RVS_VALDEB") > 0
			lAux := oModelRVS:SETVALUE("RVS_STATUS",9)
			DbSelectArea("RVS")
			DbSetorder(1)// RVS_FILIAL + RVS_ID
			If RVS->(MsSeek(xFilial("RVS") + oModelRVS:GetValue("RVS_ID")))
				If Reclock("RVS",.F.)
					Replace RVS->RVS_STATUS With 9
					MsUnlock()
				EndIf
			EndIf
		Else
			lAux := oModelRVS:SETVALUE("RVS_STATUS",1)
			DbSelectArea("RVS")
			DbSetorder(1)// RVS_FILIAL + RVS_ID
			If RVS->(MsSeek(xFilial("RVS") + oModelRVS:GetValue("RVS_ID")))
				If Reclock("RVS",.F.)
					Replace RVS->RVS_STATUS With 1
					MsUnlock()
				EndIf
			EndIf
		EndIf
	EndIf
Return .T.
/*/{Protheus.doc} PlaidBxTit
Baja de tÌtulos de integraciÛn con plaid.
@type function
@author mayra.camargo
@since 25/01/2019
@version 1.0
/*/
Static Function PlaidBxTit(cAliasPl,nrecPlaid,nValLiq,cCategor,nOpcBan)
	Local lRetorno :=.T.
	Local nOpc    := 3
	Local aTitBx  := {}
	Local cCarteira
	Private lMsErroAuto := .F.


	SA6->(dbsetorder(1)) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	SA6->(MsSeek(Xfilial("SA6")+cParam3+cParam4+cParam5))

	If cAliasPl =="SE2"


		SE2->(Dbgoto(nrecPlaid))

		Aadd(aTitBx, {"E2_PREFIXO",    SE2->E2_PREFIXO,   NIL})
		Aadd(aTitBx, {"E2_NUM",        SE2->E2_NUM,       NIL})
		Aadd(aTitBx, {"E2_PARCELA",    SE2->E2_PARCELA,   NIL})
		Aadd(aTitBx, {"E2_TIPO",       SE2->E2_TIPO,      NIL})
		Aadd(aTitBx, {"E2_FORNECE",    SE2->E2_FORNECE,   NIL})
		Aadd(aTitBx, {"E2_LOJA",       SE2->E2_LOJA,      NIL})
		Aadd(aTitBx, {"AUTMOTBX",      cCategor,          NIL})
		Aadd(aTitBx, {"AUTDTBAIXA",    dMovBank,          NIL})
		Aadd(aTitBx, {"AUTHIST",       AllTrim(cHistor),  NIL})
		Aadd(aTitBx, {"AUTBANCO",      SA6->A6_COD,       NIL})
		Aadd(aTitBx, {"AUTAGENCIA",    SA6->A6_AGENCIA,   NIL})
		Aadd(aTitBx, {"AUTCONTA",      SA6->A6_NUMCON,    NIL})
		Aadd(aTitBx, {"AUTVLRPG",      nValLiq,           NIL})
		Aadd(aTitBx, {"AUTCHEQUE",       "",              NIL})

		FWVetByDic ( aTitBx, "SE2", .F. )
		MsExecAuto({|x, y| FINA080(x, y)}, aTitBx, nOpc)
		If lMsErroAuto
			lRetorno :=.F.
			MostraErro()
			ConOut(Repl("-", 80))
			ConOut(PadC("FINA080 finalizado con error!", 80))
			ConOut(PadC("Fin: " + Time(), 80))
			ConOut(Repl("-", 80))
		Else
			ConOut(Repl("-", 80))
			ConOut(PadC("FINA080 finalizado con Exito!", 80))
			ConOut(PadC("Fin: " + Time(), 80))
			ConOut(Repl("-", 80))
		EndIf
	ElseIf cAliasPl == "SE1"

		SE1->(Dbgoto(nrecPlaid))

		Aadd(aTitBx, {"E1_PREFIXO",    SE1->E1_PREFIXO,    NIL})
		Aadd(aTitBx, {"E1_NUM",        SE1->E1_NUM,        NIL})
		Aadd(aTitBx, {"E1_PARCELA",    SE1->E1_PARCELA,    NIL})
		Aadd(aTitBx, {"E1_TIPO",       SE1->E1_TIPO,       NIL})
		Aadd(aTitBx, {"E1_CLIENTE",    SE1->E1_CLIENTE,    NIL})
		Aadd(aTitBx, {"E1_LOJA",       SE1->E1_LOJA,       NIL})
		Aadd(aTitBx, {"AUTMOTBX",      cCategor,              NIL})
		Aadd(aTitBx, {"AUTDTBAIXA",    dMovBank,          NIL})
		Aadd(aTitBx, {"AUTHIST",       AllTrim(cHistor),      NIL})
		Aadd(aTitBx, {"AUTBANCO",       SA6->A6_COD,      NIL})
		Aadd(aTitBx, {"AUTAGENCIA",       SA6->A6_AGENCIA,      NIL})
		Aadd(aTitBx, {"AUTCONTA",       SA6->A6_NUMCON,      NIL})
		Aadd(aTitBx, {"AUTVALREC",       nValLiq,      NIL})
		Aadd(aTitBx, {"AUTDTCREDITO",       dMovBank,      NIL})

		FWVetByDic ( aTitBx, "SE1", .F. )
		MsExecAuto({|x, y| FINA070(x, y)}, aTitBx, nOpc)

		If lMsErroAuto
			lRetorno :=.F.
			MostraErro()
			ConOut(Repl("-", 80))
			ConOut(PadC("FINA070 finalizado con error!", 80))
			ConOut(PadC("Fin: " + Time(), 80))
			ConOut(Repl("-", 80))
		Else
			ConOut(Repl("-", 80))
			ConOut(PadC("FINA070 finalizado con Exito!", 80))
			ConOut(PadC("Fin: " + Time(), 80))
			ConOut(Repl("-", 80))
		EndIf
	ElseIf cAliasPl =="SE5"

		cCarteira:=Iif(nOpcBan==3,"P","R")

		Aadd(aTitBx, {"E5_FILIAL",  	xFilial("SE5"),    NIL})
		Aadd(aTitBx, {"E5_DATA",  		dMovBank,    NIL})
		Aadd(aTitBx, {"E5_DTDIGIT",  	MsDate(),    NIL})
		Aadd(aTitBx, {"E5_MOEDA",       "M1",        NIL})
		Aadd(aTitBx, {"E5_VALOR",       nValLiq,      NIL})
		Aadd(aTitBx, {"E5_BANCO",       SA6->A6_COD,      NIL})
		Aadd(aTitBx, {"E5_AGENCIA",     SA6->A6_AGENCIA,      NIL})
		Aadd(aTitBx, {"E5_CONTA",       SA6->A6_NUMCON,      NIL})
		Aadd(aTitBx, {"E5_HISTOR",       AllTrim(cDocRel)+"-"+AllTrim(cHistor),        NIL})
		Aadd(aTitBx, {"E5_BENEF",        "",        NIL})
		Aadd(aTitBx, {"E5_INTPLAI",      "I",        NIL})
		Aadd(aTitBx, {"E5_NATUREZ",      AllTrim(cNaturez),        NIL})
		Aadd(aTitBx, {"E5_DEBITO",       cContSA6,       NIL})
		Aadd(aTitBx, {"E5_ORIGEM",       "FINA884" ,       NIL})
		Aadd(aTitBx, {"E5_RECPAG",        cCarteira,       NIL})



		If AllTrim(cTipoDoc) $ "CH"
			Aadd(aTitBx, {"E5_NUMCHEQ",       cDocRel,       NIL})
			Aadd(aTitBx, {"E5_DOCUMEN",       "CH-"+cDocRel,       NIL})
		Else
			Aadd(aTitBx, {"E5_DOCUMEN",       cDocRel,       NIL})
			Aadd(aTitBx, {"E5_NUMERO",       cDocRel,       NIL})
		EndIf

		aTitBx:=FWVetByDic ( aTitBx, "SE5", .F.,1 )

		aDados:={cEmpAnt, cFilAnt,aTitBx,nOpcBan}
		lMsErroAuto:=A884JOB(aDados)
		// lMsErroAuto :=Startjob("A884JOB" ,GetEnvServer(),.T.,aDados)

		If lMsErroAuto
			lRetorno :=.F.
			MostraErro()
			ConOut(Repl("-", 80))
			ConOut(PadC("FINA100 finalizado con error!", 80))
			ConOut(PadC("Fin: " + Time(), 80))
			ConOut(Repl("-", 80))
		Else
			FwClearHLP()
			ConOut(Repl("-", 80))
			ConOut(PadC("FINA100 finalizado con Exito!", 80))
			ConOut(PadC("Fin: " + Time(), 80))
			ConOut(Repl("-", 80))
		EndIf
	EndIf

Return lRetorno

/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥Programa  ≥MenuDef   ≥ Autor ≥ C…SAR bAUTISTA     	≥ Data ≥30/04/2018≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥DescriáÖo ≥ Utilizacao de menu Funcional                               ≥±±
	±±≥          ≥                                                            ≥±±
	±±≥          ≥                                                            ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Retorno   ≥Array com opcoes da rotina.                                 ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥Parametros do array a Rotina:                               ≥±±
	±±≥          ≥1. Nome a aparecer no cabecalho                             ≥±±
	±±≥          ≥2. Nome da Rotina associada                                 ≥±±
	±±≥          ≥3. Reservado                                                ≥±±
	±±≥          ≥4. Tipo de TransaáÑo a ser efetuada:                        ≥±±
	±±≥          ≥	  1 - Pesquisa e Posiciona em um Banco de Dados           ≥±±
	±±≥          ≥    2 - Simplesmente Mostra os Campos                       ≥±±
	±±≥          ≥    3 - Inclui registros no Bancos de Dados                 ≥±±
	±±≥          ≥    4 - Altera o registro corrente                          ≥±±
	±±≥          ≥    5 - Remove o registro corrente do Banco de Dados        ≥±±
	±±≥          ≥5. Nivel de acesso                                          ≥±±
	±±≥          ≥6. Habilita Menu Funcional                                  ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥   DATA   ≥ Programador   ≥Manutencao efetuada                         ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥          ≥               ≥                                            ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function MenuDef()
	Private aRotinaSZH := {}
	// ALTERADO PARA SIGAGSP
	aAdd(aRotinaSZH, {OemToAnsi(STR0007),"VIEWDEF.FINA884" 	, 0, 2, 0, Nil})	//"Visualizar"
	aAdd(aRotinaSZH, {OemToAnsi(STR0009),"VIEWDEF.FINA884" 	, 0, 4, 4, Nil})	//"Modificar"
	aAdd(aRotinaSZH, {OemToAnsi(STR0010),'VIEWDEF.FINA884'	, 0, 5, 0, Nil})	//"Borrar"
	aAdd(aRotinaSZH, {OemToAnsi(STR0023),"FPLAIDLg"			, 0, 2, 0, .F.})	//"Leyenda"

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If ExistBlock("FINPIDMNU")
		ExecBlock("FINPIDMNU",.F.,.F.)
	EndIf
Return(aRotinaSZH)

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒø±±
	±±≥FunáÑo    ≥A110Legenda≥ Autor ≥ Edson Maricate       ≥ Data ≥18.08.2000 ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥          ≥Exibe uma janela contendo a legenda da mBrowse.              ≥±±
	±±≥          ≥                                                             ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Parametros≥Nenhum Codigo do comprador                                   ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Uso       ≥ Exclusivo MATA110                                           ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function FPLAIDLg()

	Local aCores     := {}
	aAdd(aCores,{"ENABLE"		, STR0024}) // "Cuentas por Pagar"
	aAdd(aCores,{"DISABLE"		, STR0025}) // "RelaciÛn Completa"
	aAdd(aCores,{"BR_AMARELO"	, STR0027}) // "Cuentas por Cobrar"
	aAdd(aCores,{"BR_AZUL"		, STR0026}) // "RelaciÛn Incompleta"

	BrwLegenda(cCadastro, STR0023, aCores) //"Leyenda"

Return

/*/
	Inicio de Rutinas para integraciÛn de conexiÛn con PLAID
/*/
///------------------------------------------------------------------------
// Biblioteca de functions para integra√ß√£o do Plaid.
// Criado por : Adriano Azevedo
// Data : 06/26/2017
// Local: Juritis USA - Weston / FL/ USA
///------------------------------------------------------------------------
//  Function PlaidCrItm 				 - Create connect with Bank and receive the public_token (Reemplazada)
//  Function PlaidTokenExchange 	- Exchange the plublic_token by access_token
//  Function PlaidRetrAccounts 			- Search the information of bank's account
//  Function PlaidTransations 			- Search the information of transactions
//  Function PlaidImportBank          	- Import Bank's data of the Plaid

//-----------------------------------------------------------------------------------------
// BEGIN OF PlaidTokenExChange
//------------------------------------------------------------------------------------------
Function PlaidTExCh(nIPLAID, cPublicToken)

	Local cURLPlaid		:= AllTrim(GETMV("MV_PLURL"))
	Local oRestClient 	:= FWRest():New(cURLPlaid)
	Local aHeader 		:= {}
	Local cJSON			:= ""
	Local oObj			:= Nil
	Local cUserID		:= AllTrim(GETMV("MV_PLLOGIN"))
	Local cPassID		:= AllTrim(GETMV("MV_PLPASS"))

	If nIPLAID <> "1" .or. Empty(AllTrim(cPublicToken))
		Return(" ")
	EndIf

	aAdd(aHeader,"Content-Type: application/json" )
	oRestClient:setPath("/item/public_token/exchange")

	cJSON := '{'
	CJSON += '  "client_id": "'+cUserID+'",'
	CJSON += '  "secret": "'+cPassID+'",'
	CJSON += '   "public_token": "'+alltrim(cPublicToken)+'"'
	CJSON += '}'

	oRestClient:SetPostParams(cJSon)

	If oRestClient:Post(aHeader)
		If FWJsonDeserialize(oRestClient:GetResult(),@oObj)
			Conout("Create Item in Plaid - Access_token: " + oObj:access_token)
			// A884Log("CREATE" ,"Create connect with Bank and receive the public_token" )
		EndIf
		dbselectarea("RVR")
		dbsetorder(1) // RVR_FILIAL + RVR_TOKEN
		If RVR->(MsSeek(xfilial("RVR")+cPublicToken))
			If RecLock("RVR",.F.)
				Replace RVR->RVR_ATOKEN With oObj:access_token
				MsUnlock()
			EndIf
		EndIf
	Else
		Alert(STR0070 + oRestClient:GetLastError()) // "Error create Access_token: "
		
		Return(STR0069) // "Error while creating Access_token"
	EndIf

Return(oObj:access_token)

//-----------------------------------------------------------------------------------------
// END OF PlaidTokenExChange
//------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------
// BEGIN OF PlaidRetrAccounts
//------------------------------------------------------------------------------------------
Static Function PlaidReAcc(cAccessToken)

	Local cURLPlaid		:= 	AllTrim(GETMV("MV_PLURL"))
	Local oRestClient 	:= 	FWRest():New(cURLPlaid)
	Local aHeader 		:= 	{}
	Local cJSON			:= 	""
	Local oObj			:= 	nil
	Local 	cUserID		:=	GETMV("MV_PLLOGIN")
	Local 	cPassID		:= 	GETMV("MV_PLPASS")

	aAdd(aHeader,"Content-Type: application/json" )
	oRestClient:setPath("/accounts/get")

	cJSON := '{'
	CJSON += '  "client_id": "'+AllTrim(cUserID)+'",'
	CJSON += '  "secret": "'+AllTrim(cPassID)+'",'
	CJSON += '   "access_token": "'+AllTrim(cAccessToken)+'"'
	CJSON += '}'

	oRestClient:SetPostParams(cJSon)

	If oRestClient:Post(aHeader)
		If FWJsonDeserialize(oRestClient:GetResult(),@oObj)
			conout(oObj:accounts[1]:balances:available)
		EndIf
	Else
		// A884Log("RETURN", oRestClient:GetLastError())
		If "ITEM_LOGIN_REQUIRED" $ oRestClient:GetResult() .and. "400 BadRequest" $ oRestClient:GetLastError()
			If RVR->(msSeek(Xfilial("RVR")+cParam3+cParam4+cParam5))
				If RecLock("RVR",.F.)
					DbDelete()
					MsUnlock()
				EndIf
			EndIf

			PlaidNaveg()
			cPublicToken:= AllTrim(Posicione("RVR"	,2,xFilial("RVR")+ cParam3+cParam4+cParam5,"RVR_TOKEN"))
			cAccToken 	:= IIf(!Empty(cPublicToken)	,PlaidTExCh("1"	, cPublicToken),"")
			cAccToken	:= IIf("Error" $ AllTrim(cAccToken) ,"",cAccToken )

			If Empty(AllTrim(cPublicToken)) .OR. Empty(AllTrim(cAccToken))
				Help( ,, STR0067,, STR0065, 1, 0) // 'Invalid Keys'	 'Contact software Administrator'
			Else
				Help( ,, STR0068,, STR0066	, 1, 0)// 'Valid Keys''Restart the Process Plaid transaction'
			EndIf
		EndIf
	EndIf
Return(oObj)  // the Return will be the code of transaction

//-----------------------------------------------------------------------------------------
// END OF PlaidRetrAccounts
//------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------
// BEGIN OF PlaidTransations
//------------------------------------------------------------------------------------------
Static Function PlaidTrans(cAccessToken, dStart, dEnd)
	Local cURLPlaid		:= AllTrim(GETMV("MV_PLURL"))
	Local oRestClient 	:= FWRest():New(cURLPlaid)
	Local aHeader 		:= {}
	Local cJSON			:= ""
	Local oObj  		:= Nil
	Local cUserID		:= 	GETMV("MV_PLLOGIN")
	Local cPassID		:= 	GETMV("MV_PLPASS")
	Local cResulRest	:= Nil
	conout('------------------------------------inicia fina884 PlaidTrans------------------------------------')
	aAdd(aHeader,"Content-Type: application/json" )
	conout('previo: oRestClient:setPath("/transactions/get")')
	oRestClient:setPath("/transactions/get")
	conout('Posterior: oRestClient:setPath("/transactions/get")')
	// ConstrucciÛn Json
	cJSon := '{'
	cJSon += '	"client_id": "'		+ alltrim(cUserID) 		+ '",'
	cJSon += '  "secret": "'		+ alltrim(cPassID) 		+ '",'
	cJSon += '  "access_token": "'	+ alltrim(cAccessToken)	+ '",'
	cJSon += '  "start_date": "'	+ alltrim(dStart) 		+ '",'
	cJSon += '  "end_date": "'		+ alltrim(dEnd)			+ '" '
	cJSon += ' }'

	conout('posterior variable cJSon :' + cJSon			)
	conout('previo: oRestClient:SetPostParams(cJSon)'	)

	oRestClient:SetPostParams(cJSon)
	conout('posterior: oRestClient:SetPostParams(cJSon)')

	conout('previo: oRestClient:Post(aHeader)')
	If oRestClient:Post(aHeader)
		conout('posterior: oRestClient:Post(aHeader)')
		conout('previo: cResulRest')
		cResulRest := oRestClient:GetResult()
		conout('posterior cResulRest:' + cResulRest)

		conout('previo: FWJsonDeserialize(cResulRest,@oObj)')
		If FWJsonDeserialize(cResulRest,@oObj)
			conout(oObj:accounts[1]:balances:available)
		EndIf
		conout('posterior: FWJsonDeserialize(cResulRest,@oObj)')
	Else
		// A884Log("TRANSACTION", oRestClient:GetLastError())
		If "ITEM_LOGIN_REQUIRED" $ oRestClient:GetResult() .and. "400 BadRequest" $ oRestClient:GetLastError()

			If RVR->(msSeek(Xfilial("RVR")+cParam3+cParam4+cParam5))
				If RecLock("RVR",.F.)
					DbDelete()
					MsUnlock()
				EndIf
			EndIf

			PlaidNaveg()
			cPublicToken:= AllTrim(Posicione("RVR",2,xFilial("RVR")+cParam3+cParam4+cParam5,"RVR_TOKEN"))
			cAccToken 	:= IIf(!Empty(cPublicToken),PlaidTExCh("1", cPublicToken),"")
			cAccToken	:= IIf("Error" $ AllTrim(cAccToken) ,"",cAccToken )

			If Empty(AllTrim(cPublicToken)) .OR. Empty(AllTrim(cAccToken))
				Help( ,, STR0067,, STR0065, 1, 0 ) // 'Invalid Keys' 'Contact software Administrator'
			Else
				Help( ,, STR0068,, STR0066, 1, 0 ) // 'Valid Keys' 'Restart the Process Plaid Transaction'
			EndIf
		EndIf
	EndIf
	conout('------------------------------------finaliza fina884 PlaidTrans-------------------------------------')
	oRestClient := Nil

Return(oObj)

/*/{Protheus.doc} ${function_method_class_name}
(long_description)
@type function
@author mayra.camargo
@since 25/01/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PlaidNaveg()

	Local cHTML						:= ''
	Local cAbrir					:= ''
	Local nError					:= 0
	Local cLibVersion
	Local nRet := GetRemoteType ( [ @cLibVersion] )

	cHTML := Plaidcrhml() // genera mi html
	cAbrir := IIf(nRet==2,"file://","")+Plaidgfile(cHTML) // URL archivo

	OpenHtml(cAbrir,cHTML)
	Ferase(cAbrir)

	Dbselectarea("RVR")
	Dbsetorder(2) // RVR_FILIAL + RVR_USERID
	If RVR->(msSeek(Xfilial("RVR")+"INTEGRATIONPLAID"))
		If Reclock("RVR",.F.)
			RVR_FILIAL := xfilial("RVR")
			RVR_USERID := M->A6_COD+M->A6_AGENCIA+M->A6_NUMCON
			MsUnlock()
		EndIf
	EndIf
Return
/*/{Protheus.doc} Plaidcrhml
Genera ventana de conexiÛn con plaid. 
@type function
@author mayra.camargo
@since 25/01/2019
@version 1.0
/*/
Static Function Plaidcrhml()
	Local cHTML			:= ''
	Local cPublicKey 	:= GETMV("MV_PLPUBK")
	Local cURLNET 		:= GETMV("MV_PLURNET")
	Local cUserNET 		:= GETMV("MV_PLUSNET")
	Local cPassNET 		:= GETMV("MV_PLPANET")
	Local cEnvPlaid 	:= GETMV("MV_PLEMENT")

	cHTML := '<!DOCTYPE html>' + CRLF
	cHTML += '<html lang="en">' + CRLF
	cHTML += '<head>' + CRLF
	cHTML += '	<meta charset="UTF-8">' + CRLF
	cHTML += '	<meta name="viewport" content="width=device-width, initial-scale=1.0">' + CRLF
	cHTML += '	<meta http-equiv="X-UA-Compatible" content="ie=edge">' + CRLF
	cHTML += '	<title>TOTVS Plaid Integration</title>' + CRLF
	cHTML += '</head>' + CRLF
	cHTML += '<body id="page-top">' + CRLF
	cHTML += '	<button id="link-button" class="btn btn:hover ">Log In</button>' + CRLF
	cHTML += '	<div class="sty01">TOTVS Integration</div>' + CRLF
	cHTML += '	<br>' + CRLF
	cHTML += '	<div>Please Log In</div>' + CRLF
	cHTML += '	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.2.3/jquery.min.js"></script>' + CRLF
	cHTML += '	<script src="https://cdn.plaid.com/link/v2/stable/link-initialize.js"></script>' + CRLF
	cHTML += '	<style>' + CRLF
	cHTML += '		.btn {' + CRLF
	cHTML += '			background: #3498db;' + CRLF
	cHTML += '			background-image: -webkit-linear-gradient(top, #3498db, #2980b9);' + CRLF
	cHTML += '			margin-top: 100px;' + CRLF
	cHTML += '			background-image: -moz-linear-gradient(top, #3498db, #2980b9);' + CRLF
	cHTML += '			background-image: -ms-linear-gradient(top, #3498db, #2980b9);' + CRLF
	cHTML += '			background-image: -o-linear-gradient(top, #3498db, #2980b9);' + CRLF
	cHTML += '			background-image: linear-gradient(to bottom, #3498db, #2980b9);' + CRLF
	cHTML += '			-webkit-border-radius: 28;' + CRLF
	cHTML += '			-moz-border-radius: 28;' + CRLF
	cHTML += '			border-radius: 28px;' + CRLF
	cHTML += '			font-family: Arial;' + CRLF
	cHTML += '			color: #ffffff;' + CRLF
	cHTML += '			font-size: 20px;' + CRLF
	cHTML += '			padding: 10px 20px 10px 20px;' + CRLF
	cHTML += '			text-decoration: none;' + CRLF
	cHTML += '		}' + CRLF
	cHTML += '' + CRLF
	cHTML += '		.btn:hover {' + CRLF
	cHTML += '			background: #3cb0fd;' + CRLF
	cHTML += '			background-image: -webkit-linear-gradient(top, #3cb0fd, #3498db);' + CRLF
	cHTML += '			background-image: -moz-linear-gradient(top, #3cb0fd, #3498db);' + CRLF
	cHTML += '			background-image: -ms-linear-gradient(top, #3cb0fd, #3498db);' + CRLF
	cHTML += '			background-image: -o-linear-gradient(top, #3cb0fd, #3498db);' + CRLF
	cHTML += '			background-image: linear-gradient(to bottom, #3cb0fd, #3498db);' + CRLF
	cHTML += '			text-decoration: none;' + CRLF
	cHTML += '		}' + CRLF
	cHTML += '' + CRLF
	cHTML += '		.sty01 {' + CRLF
	cHTML += '			font-family: "Arial Black", Gadget, sans-serif;' + CRLF
	cHTML += '			font-size: 21px;' + CRLF
	cHTML += '			letter-spacing: 0px;' + CRLF
	cHTML += '			word-spacing: 2px;' + CRLF
	cHTML += '			color: #002FFF;' + CRLF
	cHTML += '			font-weight: normal;' + CRLF
	cHTML += '			text-decoration: none;' + CRLF
	cHTML += '			font-style: normal;' + CRLF
	cHTML += '			font-variant: normal;' + CRLF
	cHTML += '			text-transform: none;' + CRLF
	cHTML += '			margin-top: 20px;' + CRLF
	cHTML += '		}' + CRLF
	cHTML += '' + CRLF
	cHTML += '		* {' + CRLF
	cHTML += '			box-sizing: border-box;' + CRLF
	cHTML += '		}' + CRLF
	cHTML += '' + CRLF
	cHTML += '		body {' + CRLF
	cHTML += '			background-repeat: repeat;' + CRLF
	cHTML += '			border-top: 5px solid rgba(235, 235, 235, 0.5);' + CRLF
	cHTML += '			color: #474747;' + CRLF
	cHTML += '			font-family: sans-serif;' + CRLF
	cHTML += '			width: 100%;' + CRLF
	cHTML += '			text-align: center;' + CRLF
	cHTML += '			margin: 0px auto;' + CRLF
	cHTML += '			display: block;' + CRLF
	cHTML += '			padding: 0px 5px;' + CRLF
	cHTML += '			width: 100%;' + CRLF
	cHTML += '			text-align: center;' + CRLF
	cHTML += '			margin: 0px auto;' + CRLF
	cHTML += '			display: block;' + CRLF
	cHTML += '			padding: 0px 5px;' + CRLF
	cHTML += '		}' + CRLF
	cHTML += '	</style>' + CRLF
	cHTML += '	<script>' + CRLF
	cHTML += '		$.urlParam = function (name) {' + CRLF
	cHTML += '			var results = new RegExp("[\?&]" + name + "=([^&#]*)").exec(window.location.href);' + CRLF
	cHTML += '			if(results == null) {' + CRLF
	cHTML += '				return null;' + CRLF
	cHTML += '			}' + CRLF
	cHTML += '			else {' + CRLF
	cHTML += '				return decodeURI(results[1]) || 0;' + CRLF
	cHTML += '			}' + CRLF
	cHTML += '		}' + CRLF
	cHTML += '	</script>' + CRLF


	//TODO - IMPLEMENTAR NO PADRAO
	//ALTERADO BRUNO - 20190816
	cHTML += "	<script> " + CRLF
	cHTML += "		// The one and only way of getting global scope in all environments " + CRLF
	cHTML += "		// https://stackoverflow.com/q/3277182/1008999 " + CRLF
	cHTML += "		var _global = typeof window === 'object' && window.window === window " + CRLF
	cHTML += "		  ? window : typeof self === 'object' && self.self === self " + CRLF
	cHTML += "		  ? self : typeof global === 'object' && global.global === global " + CRLF
	cHTML += "		  ? global " + CRLF
	cHTML += "		  : this " + CRLF + CRLF
	cHTML += "		function bom (blob, opts) {" + CRLF
	cHTML += "		  if (typeof opts === 'undefined') opts = { autoBom: false }" + CRLF
	cHTML += "		  else if (typeof opts !== 'object') {" + CRLF
	cHTML += "			console.warn('Deprecated: Expected third argument to be a object')" + CRLF
	cHTML += "			opts = { autoBom: !opts }" + CRLF
	cHTML += "		  }" + CRLF + CRLF
	cHTML += "		// prepend BOM for UTF-8 XML and text/* types (including HTML) " + CRLF
	cHTML += "		// note: your browser will automatically convert UTF-16 U+FEFF to EF BB BF " + CRLF
	cHTML += "		  if (opts.autoBom && /^\s*(?:text\/\S*|application\/xml|\S*\/\S*\+xml)\s*;.*charset\s*=\s*utf-8/i.test(blob.type)) { " + CRLF
	cHTML += "			return new Blob([String.fromCharCode(0xFEFF), blob], { type: blob.type }) " + CRLF
	cHTML += "		  } " + CRLF
	cHTML += "		  return blob " + CRLF
	cHTML += "		} " + CRLF + CRLF
	cHTML += "		function download (url, name, opts) {" + CRLF
	cHTML += "		  var xhr = new XMLHttpRequest()" + CRLF
	cHTML += "		  xhr.open('GET', url)" + CRLF
	cHTML += "		  xhr.responseType = 'blob'" + CRLF
	cHTML += "		  xhr.onload = function () {" + CRLF
	cHTML += "			saveAs(xhr.response, name, opts)" + CRLF
	cHTML += "		  }" + CRLF
	cHTML += "		  xhr.onerror = function () {" + CRLF
	cHTML += "			console.error('could not download file')" + CRLF
	cHTML += "		  }" + CRLF
	cHTML += "		  xhr.send()" + CRLF
	cHTML += "		}" + CRLF
	cHTML += "		function corsEnabled (url) {" + CRLF
	cHTML += "		  var xhr = new XMLHttpRequest()" + CRLF
	cHTML += "		  // use sync to avoid popup blocker" + CRLF
	cHTML += "		  xhr.open('HEAD', url, false)" + CRLF
	cHTML += "		  try {" + CRLF
	cHTML += "			xhr.send()" + CRLF
	cHTML += "		  } catch (e) {}" + CRLF
	cHTML += "		  return xhr.status >= 200 && xhr.status <= 299" + CRLF
	cHTML += "		}" + CRLF + CRLF
	cHTML += "		// `a.click()` doesn't work for all browsers (#465)" + CRLF
	cHTML += "		function click (node) {" + CRLF
	cHTML += "		  try {" + CRLF
	cHTML += "			node.dispatchEvent(new MouseEvent('click'))" + CRLF
	cHTML += "		  } catch (e) {" + CRLF
	cHTML += "			var evt = document.createEvent('MouseEvents')" + CRLF
	cHTML += "			evt.initMouseEvent('click', true, true, window, 0, 0, 0, 80," + CRLF
	cHTML += "								  20, false, false, false, false, 0, null)" + CRLF
	cHTML += "			node.dispatchEvent(evt)" + CRLF
	cHTML += "		  }" + CRLF
	cHTML += "		}" + CRLF + CRLF
	cHTML += "		var saveAs = _global.saveAs || (" + CRLF
	cHTML += "		  // probably in some web worker" + CRLF
	cHTML += "		  (typeof window !== 'object' || window !== _global)" + CRLF
	cHTML += "			? function saveAs () { /* noop */ }" + CRLF + CRLF
	cHTML += "		  // Use download attribute first if possible (#193 Lumia mobile)" + CRLF
	cHTML += "		  : 'download' in HTMLAnchorElement.prototype" + CRLF
	cHTML += "		  ? function saveAs (blob, name, opts) {" + CRLF
	cHTML += "			var URL = _global.URL || _global.webkitURL" + CRLF
	cHTML += "			var a = document.createElement('a')" + CRLF
	cHTML += "			name = name || blob.name || 'download'" + CRLF + CRLF
	cHTML += "			a.download = name" + CRLF
	cHTML += "			a.rel = 'noopener' // tabnabbing" + CRLF + CRLF
	cHTML += "			// TODO: detect chrome extensions & packaged apps" + CRLF
	cHTML += "			// a.target = '_blank'" + CRLF + CRLF
	cHTML += "			if (typeof blob === 'string') {" + CRLF
	cHTML += "			  // Support regular links" + CRLF
	cHTML += "			  a.href = blob" + CRLF
	cHTML += "			  if (a.origin !== location.origin) {" + CRLF
	cHTML += "				corsEnabled(a.href)" + CRLF
	cHTML += "				  ? download(blob, name, opts)" + CRLF
	cHTML += "				  : click(a, a.target = '_blank')" + CRLF
	cHTML += "			  } else {" + CRLF
	cHTML += "				click(a)" + CRLF
	cHTML += "			  }" + CRLF
	cHTML += "			} else {" + CRLF
	cHTML += "			  // Support blobs" + CRLF
	cHTML += "			  a.href = URL.createObjectURL(blob)" + CRLF
	cHTML += "			  setTimeout(function () { URL.revokeObjectURL(a.href) }, 4E4) // 40s" + CRLF
	cHTML += "			  setTimeout(function () { click(a) }, 0)" + CRLF
	cHTML += "			}" + CRLF
	cHTML += "		  }" + CRLF + CRLF
	cHTML += "		  // Use msSaveOrOpenBlob as a second approach" + CRLF
	cHTML += "		  : 'msSaveOrOpenBlob' in navigator" + CRLF
	cHTML += "		  ? function saveAs (blob, name, opts) {" + CRLF
	cHTML += "			name = name || blob.name || 'download'" + CRLF + CRLF
	cHTML += "			if (typeof blob === 'string') {" + CRLF
	cHTML += "			  if (corsEnabled(blob)) {" + CRLF
	cHTML += "				download(blob, name, opts)" + CRLF
	cHTML += "			  } else {" + CRLF
	cHTML += "				var a = document.createElement('a')" + CRLF
	cHTML += "				a.href = blob" + CRLF
	cHTML += "				a.target = '_blank'" + CRLF
	cHTML += "				setTimeout(function () { click(a) })" + CRLF
	cHTML += "			  }" + CRLF
	cHTML += "			} else {" + CRLF
	cHTML += "			  navigator.msSaveOrOpenBlob(bom(blob, opts), name)" + CRLF
	cHTML += "			}" + CRLF
	cHTML += "		  }" + CRLF + CRLF
	cHTML += "		  // Fallback to using FileReader and a popup" + CRLF
	cHTML += "		  : function saveAs (blob, name, opts, popup) {" + CRLF
	cHTML += "			// Open a popup immediately do go around popup blocker" + CRLF
	cHTML += "			// Mostly only available on user interaction and the fileReader is async so..." + CRLF
	cHTML += "			popup = popup || open('', '_blank')" + CRLF
	cHTML += "			if (popup) {" + CRLF
	cHTML += "			  popup.document.title =" + CRLF
	cHTML += "			  popup.document.body.innerText = 'downloading...'" + CRLF
	cHTML += "			}" + CRLF + CRLF
	cHTML += "			if (typeof blob === 'string') return download(blob, name, opts)" + CRLF + CRLF
	cHTML += "			var force = blob.type === 'application/octet-stream'" + CRLF
	cHTML += "			var isSafari = /constructor/i.test(_global.HTMLElement) || _global.safari" + CRLF
	cHTML += "			var isChromeIOS = /CriOS\/[\d]+/.test(navigator.userAgent)" + CRLF + CRLF
	cHTML += "			if ((isChromeIOS || (force && isSafari)) && typeof FileReader !== 'undefined') {" + CRLF
	cHTML += "			  // Safari doesn't allow downloading of blob URLs" + CRLF
	cHTML += "			  var reader = new FileReader()" + CRLF
	cHTML += "			  reader.onloadend = function () {" + CRLF
	cHTML += "				var url = reader.result" + CRLF
	cHTML += "				url = isChromeIOS ? url : url.replace(/^data:[^;]*;/, 'data:attachment/file;')" + CRLF
	cHTML += "				if (popup) popup.location.href = url" + CRLF
	cHTML += "				else location = url" + CRLF
	cHTML += "				popup = null // reverse-tabnabbing #460" + CRLF
	cHTML += "			  }" + CRLF
	cHTML += "			  reader.readAsDataURL(blob)" + CRLF
	cHTML += "			} else {" + CRLF
	cHTML += "			  var URL = _global.URL || _global.webkitURL" + CRLF
	cHTML += "			  var url = URL.createObjectURL(blob)" + CRLF
	cHTML += "			  if (popup) popup.location = url" + CRLF
	cHTML += "			  else location.href = url" + CRLF
	cHTML += "			  popup = null // reverse-tabnabbing #460" + CRLF
	cHTML += "			  setTimeout(function () { URL.revokeObjectURL(url) }, 4E4) // 40s" + CRLF
	cHTML += "			}" + CRLF
	cHTML += "		  }" + CRLF
	cHTML += "		)" + CRLF + CRLF
	cHTML += "		_global.saveAs = saveAs.saveAs = saveAs" + CRLF + CRLF
	cHTML += "		if (typeof module !== 'undefined') {" + CRLF
	cHTML += "		  module.exports = saveAs;" + CRLF
	cHTML += "		}" + CRLF
	cHTML += "	</script>" + CRLF+ CRLF
	//TODO - IMPLEMENTAR NO PADRAO
	// ALTERADO BRUNO - 20190816 - FIM -->

	//TODO - IMPLEMENTAR NO PADRAO
	// ALTERADO BRUNO - 20190819 -->
	cHTML += "	<script>" + CRLF
	cHTML += "	function leftPad(value, totalWidth, paddingChar) {" + CRLF
	cHTML += "					  var length = totalWidth - value.toString().length + 1;" + CRLF
	cHTML += "					  return Array(length).join(paddingChar || '0') + value;" + CRLF
	cHTML += "					};" + CRLF
	cHTML += "	</script>" + CRLF+ CRLF
	//TODO - IMPLEMENTAR NO PADRAO
	// ALTERADO BRUNO - 20190819 - FIM -->
	cHTML += '	<script>' + CRLF
	cHTML += '			(function ($) {' + CRLF
	cHTML += '				var handler = Plaid.create({' + CRLF
	cHTML += '					clientName: "Juritis Plaid",' + CRLF
	cHTML += '					env: "' + AllTrim(cEnvPlaid) + '",' + CRLF
	cHTML += '					key: "'+ AllTrim(cPublicKey) + '",' + CRLF
	cHTML += '					product: ["transactions", "auth"],' + CRLF
	cHTML += '					webhook: "https://requestb.in",' + CRLF
	cHTML += '					onSuccess: function (public_token, metadata) {' + CRLF
	cHTML += '						var results = {}' + CRLF
	cHTML += '						results["token"] = public_token;' + CRLF
	cHTML += '						results["session_id"] = $.urlParam("session_id");' + CRLF
	cHTML += '						$.ajax({' + CRLF
	cHTML += '							url: "' + AllTrim(cURLNET) + '",' + CRLF
	cHTML += '							type: "POST",' + CRLF
	cHTML += '							data: JSON.stringify(results),' + CRLF
	cHTML += '							contentType: "application/json; charset=utf-8",' + CRLF
	cHTML += '							headers: { '
	cHTML += '										"Authorization": "Basic " + btoa("' + AllTrim(cUserNET) + '" + ":" + "' + AllTrim(cPassNET) + '")' + CRLF
	cHTML += '									  }' + CRLF
	cHTML += '						});' + CRLF
	//TODO - IMPLEMENTAR NO PADRAO
	//ALTERADO BRUNO - TESTE PARA VERIFICAR LOG DE ERROS - 20190819
	cHTML += '					},' + CRLF
	cHTML += '					onExit: function(error, metadata) {' + CRLF
	cHTML += '						if(error != null){' + CRLF
	cHTML += '							var cMessageTxt = "Display Message: "+error.display_message' + CRLF
	cHTML += '								+"\n" + "Error Code: "+error.error_code ' + CRLF
	cHTML += '								+"\n" + "Error Message: "+error.error_message' + CRLF
	cHTML += '								+"\n" + "Error Type: "+error.error_type' + CRLF
	cHTML += '								+"\n\n\n" + "Meta Data link_session_id: "+metadata.link_session_id' + CRLF
	cHTML += '								+"\n" + "Status: "+metadata.status' + CRLF
	cHTML += '								+"\n" + "Institution Name: "+metadata.institution.name' + CRLF
	cHTML += '								+"\n" + "Institution Id: "+metadata.institution.id;' + CRLF
	cHTML += '							var cMessageAlert = "Erro: "+error.display_message' + CRLF
	cHTML += '							try {' + CRLF
	cHTML += '								var isFileSaverSupported = !!new Blob;' + CRLF
	cHTML += '							} catch (e) {}' + CRLF
	cHTML += '							if (isFileSaverSupported)' + CRLF
	cHTML += '							{' + CRLF
	//adicionando quebra de linha para formatacao da mensagem.
	cHTML += '								cMessageTxt = cMessageTxt.replace(/(^|\r\n|\n)([^*]|$)/g, "$1\r\n$2");' + CRLF
	cHTML += '								var dNow = new Date();' + CRLF
	cHTML += '								var cNomeTxt = "plaid_"+ leftPad(dNow.getDate(),2) + "/" + leftPad(dNow.getMonth()+1,2) + "/" + dNow.getFullYear()' + CRLF
	cHTML += "												+ '-' + leftPad(dNow.getHours(),2) + ':' + leftPad(dNow.getMinutes(),2) + ':' + leftPad(dNow.getSeconds(),2) +'.txt';" + CRLF
	cHTML += '								var blob = new Blob([cMessageTxt], {type: "text/plain;charset=utf-8"});	' + CRLF
	cHTML += '								saveAs(blob,cNomeTxt);' + CRLF
	cHTML += '							}else{' + CRLF
	cHTML += '								cMessageAlert = cMessageTxt;' + CRLF
	cHTML += '							}' + CRLF
	cHTML += '							alert(cMessageAlert);' + CRLF
	cHTML += '						}' + CRLF
	cHTML += '					}' + CRLF
	//TODO - IMPLEMENTAR NO PADRAO
	//ALTERADO BRUNO - TESTE PARA VERIFICAR LOG DE ERROS - 20190819

	cHTML += '				});' + CRLF
	cHTML += '				$("#link-button").on("click", function (e) {' + CRLF
	cHTML += '					handler.open();' + CRLF
	cHTML += '				});' + CRLF
	cHTML += '			})(jQuery);  ' + CRLF
	cHTML += '	</script>' + CRLF
	cHTML += '</body>' + CRLF
	cHTML += '</html>

Return cHTML
/*/{Protheus.doc} Plaidgfile
Escribe archivo htmls de ventana plaid
@type function
@author mayra.camargo
@since 25/01/2019
@version 1.0
/*/																				
Static Function Plaidgfile(cImprText)
	Local nRet              := GetRemoteType ( [ @cLibVersion] )
	Local cTempPath			:= allTrim(GetTempPath(.T.))
	Local cHTMLPath			:= Iif(nRet== 2,"1:","") + cTempPath + 'plaid.html'
	Default cImprText		:= ''

	MemoWrite(cHTMLPath, cImprText)


Return cHTMLPath

/*/{Protheus.doc} PlaidData
Fecha de movimientos Plaid
@type function
@author mayra.camargo
@since 25/01/2019
@version 1.0
/*/
Function PlaidData()
	Local oView		:= FWViewActive()
	Local oModel  	:= FWModelActive()
	Local oModelZA2	:= oModel:GetModel('RVTDETAIL')
	Local oModelRVS	:= oModel:GetModel('RVSMASTER')
	Local dDatamov	:= oModelRVS:GetValue("RVS_DATA")

	If !Empty(oModelZA2:GetValue("RVT_CLIPRO"))
		dDatamov := oModelZA2:GetValue("RVS_DATAMOV")
	EndIf

Return dDatamov

////////////////////////////////////////////////////////////////
//Funcion que visualiza los campos de un registro seleccionado//
//                                                            //
////////////////////////////////////////////////////////////////
Function fVisualiza()

	Local  oDlgy, oSize, oMasterPanel

	aSize := MSADVSIZE(.F.)

	DEFINE MSDIALOG oDlgy TITLE STR0059 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL // "MASTER"
	//Defino o tamanho dos componentes atravÈs do mÈtodo FwDefSize(), amarrando ao objeto oDlg
	oSize := FwDefSize():New(.F.,,,oDlgy)
	oSize:lLateral := .F.
	oSize:lProp := .T.
	oSize:AddObject("MASTER",100,100,.T.,.T.)
	oSize:Process()

	//Instancio um painel "master" como container
	oMasterPanel := TPanel():New(oSize:GetDimension("MASTER","LININI"),oSize:GetDimension("MASTER","COLINI"),;
		,oDlgy,,,,,,oSize:GetDimension("MASTER","XSIZE"),oSize:GetDimension("MASTER","YSIZE"),.F.,.F.)

	axVisual(Alias(),Recno(),2,,,,,,.F./*lMaximized*/,,.T.,oMasterPanel,,,,,)
	ACTIVATE MSDIALOG oDlgy ON INIT EnchoiceBar(oDlgy,{||,oDlgy:End()},{||,oDlgy:End(),},,/*oMark:oBrowse:Gotop()*/) CENTERED

Return

Function FINA884WHE(cCampo)
	Local lRetorno
	Local oModel
	Local oModelRVT

	If cCampo=='RVT_DOC'
		oModel	:= FWModelActive()
		oModelRVT	:= oModel:GetModel( 'RVTDETAIL' )
		lRetorno:=Empty(oModelRVT:GetValue("RVT_ORIGEN"))
	EndIf

Return lRetorno


Function A884JOB(aDados)
	// Local cEmpAtu	:=aDados[1]
	// Local cFilAtu	:=aDados[2]
	Local aTitBx	:=aDados[3]
	Local nOpcBan	:=aDados[4]
	Local nAutoOpc:=3
	Local cFunName:=FunName()
	Local aRotAtu
	Local oView	:= FWViewActive()


	Private lMsErroAuto:=.F.

	If Type("aRotina")=="A"
		aRotAtu:=aClone(aRotina)
	EndIf

	// RpcClearEnv()
	// RpcSetType(3)
	// RpcSetEnv(cEmpAtu,cFilAtu)
	SetFunName("FINA100")

	aRotina :=  { 	{ OemToAnsi("Localizar"),"AxPesqui" , 0 , 1},;  //
	{ OemToAnsi("Visualizar"),"AxVisual('SE5',SE5->(RecNo()),2,,,,,aButtons)" , 0 , 2},;  //
	{ OemToAnsi("Pagar"),"fA100Pag" , 0 , IIf(nAutoOpc == 3,3,2)},;  //
	{ OemToAnsi("Receber"),"fA100Rec" , 0 , IIf(nAutoOpc == 4,3,2)},;  //
	{ OemToAnsi("Excluir"),"fA100Can" , 0 , IIf(nAutoOpc == 5,5,2)},;  //
	{ OemToAnsi("Cancelar"),"fA100Can" , 0 , IIf(nAutoOpc == 6,6,2),53},;  //
	{ OemToAnsi("Transf"),"fA100Tran", 0 , IIf(nAutoOpc == 7,3,2)},;  //
	{ OemToAnsi("eSt.trnsf"),"fA100Est" , 1 , IIf(nAutoOpc == 8,5,2)},;  //
	{ OemToAnsi("Classif"),"fA100Clas", 0 , IIf(nAutoOpc == 9,5,2)},;  //
	{ OemToAnsi("Tracker Cont·bil"),"CTBC662", 0 , 9},;  //
	{ OemToAnsi("Legenda"),"F100Legenda", 0 , IIf(nAutoOpc == 10,6,2), ,.F.} } //

	MsExecAuto({|w,x, y| FINA100(w, x, y)}, 0 , aTitBx, nOpcBan)
	SetFunName(cFunName)
	If Len(aRotAtu)>0
		aRotina:=aClone(aRotAtu)
	EndIf


Return lMsErroAuto


Static Function A884PERG(cTabela)
	Local aAreaAtu	:=GetArea()
	Local aParamBox 	:= {}
	Local aRet 	:= {}
	Local aMvs	:={mv_par01,mv_par02,mv_par03,mv_par04}
	Local aDatas :={ Ctod(""),Ctod(""),Ctod("") ,Ctod("")  }



	aAdd(aParamBox,{1,"From issue date",Ctod(""),"","","","",50,.F.})
	aAdd(aParamBox,{1,"To issue date"  ,Ctod(""),"","","","",50,.F.})

	If cTabela=="SE1"
		aAdd(aParamBox,{1,"From Maturity date"  ,Ctod(""),"","","","",50,.F.})
		aAdd(aParamBox,{1,"To  Maturity date"   ,Ctod(""),"","","","",50,.F.})
	Else
		aAdd(aParamBox,{1,"From due date"  ,Ctod(""),"","","","",50,.F.})
		aAdd(aParamBox,{1,"To due date"   ,Ctod(""),"","","","",50,.F.})
	EndIf

	If (ParamBox(aParamBox,"Filter",@aRet,,,,,,,,.F.,.T.))
		aDatas[1]:=aRet[1]
		aDatas[2]:=aRet[2]
		aDatas[3]:=aRet[3]
		aDatas[4]:=aRet[4]
	EndIf

	mv_par01:=aMvs[1]
	mv_par02:=aMvs[2]
	mv_par03:=aMvs[3]
	mv_par04:=aMvs[4]

	RestArea(aAreaAtu)
Return aDatas

Static Function A884PO()
	FwCallApp("FINA884")
Return

Static Function JsToAdvpl(oWebChannel,cType,cContent)
	Local oJson:=JsonObject():New()

	Do Case
	Case cType == "preLoad"
		oJson['empresa']:=AllTrim(FWGrpCompany())
		oJson['filial']:=AllTrim(FWCodFil())
		oJson['backendUrl']:=GetMv(AllTRim("MV_PLURNET"))
		oJson['rvsRegistro']:=RVS->(Recno())
		oJson['idioma']:=__LANGUAGE

		// extrato
		oJson['dataInicial']:=Dtos(MV_PAR01)
		oJson['dataFinal']:=Dtos(MV_PAR02)
		oJson['banco']:=(MV_PAR03)
		oJson['agencia']:=(MV_PAR04)
		oJson['conta']:=(MV_PAR05)
		oJson['tabela']:='RVS'
		oJson['rotina']:='RVS_BROWSE'
		oJson['tipo']:=MV_PAR06

		oWebChannel:AdvPLToJS('payload', oJson:toJSON())
		oWebChannel:AdvPLToJS('redirectTo', 'bank-reconciliation')


		oWebChannel:AdvPLToJS('empresa'		, AllTrim(FWGrpCompany()))
		oWebChannel:AdvPLToJS('filial'		,AllTrim(FWCodFil()))
		oWebChannel:AdvPLToJS('backendUrl'	, GetMv(AllTRim("MV_PLURNET")))
		oWebChannel:AdvPLToJS('rvsRegistro'	,   AllTrim(Str(RVS->(Recno()) )))
		oWebChannel:AdvPLToJS('idioma'		,__LANGUAGE)

		oJson:=Nil

	Case cType == "close"
		If MsgYesNo("Deseja realmente fechar a aplicaÁ„o:","Encerrando App...")
			oWebChannel:Disconnect()
			oDlg:End()
		EndIf
	EndCase

Return

Static function OpenHtml(cGlobalLink,cHTML)
	Local oDlg
	Private oWebChannel

	DEFINE DIALOG oDlg TITLE "TOTVS Integration" FROM 180,180 TO 900,700 PIXEL
	oDlg:setCss("QPushButton{borderDummy: 1px solid black;}")

	// TWebChannel eh responsavel pelo trafego SmartClient/HTML
	oWebChannel := TWebChannel():New()
	oWebChannel:connect()

	if !oWebChannel:lConnected
		MsgStop("Erro na conexao com o WebSocket")
		return
	endif

	oWebEngine := TWebEngine():New(oDlg, 0, 0, 100, 100)
	oWebEngine:navigate(cGlobalLink)
	oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE DIALOG oDlg CENTERED

Return


/*/{Protheus.doc} zCadSX6
Lista par‚metros ao usu·rio com as opÁıes de incluir, alterar e excluir
@author Atilio
@since 14/11/2014
@version 1.0
    @param aParams, Array, Par‚metros que ser„o listados ao usu·rio para ediÁ„o
    @param lCombo, LÛgico, Define se os par‚metros ser„o mostrados em combo quando houver inclus„o
    @param lDelet, LÛgico, Define se ser· possÌvel a exclus„o de par‚metros
    @example
    aParams := { "MV_X_AMBOF","MV_X_USERS"}
    u_zCadSX6(aParams, .T., .T.)
/*/
Function A884PARAM()
	Local aParametros:={}

	AAdd(aParametros,"MV_PLDASPO")
	AAdd(aParametros,"MV_PLEMENT")
	AAdd(aParametros,"MV_PLEXTCP")
	AAdd(aParametros,"MV_PLEXTCR")
	AAdd(aParametros,"MV_PLINTOL")
	AAdd(aParametros,"MV_PLLOGIN")
	AAdd(aParametros,"MV_PLPANET")
	AAdd(aParametros,"MV_PLPUBK")
	AAdd(aParametros,"MV_PLURL")
	AAdd(aParametros,"MV_PLURNET")
	AAdd(aParametros,"MV_PLUSNET")
	AAdd(aParametros,"MV_PLTOLER")
	AAdd(aParametros,"MV_GCTPURL")
	If FWIsAdmin(__cUserID)
		AAdd(aParametros,"MV_PLPASS")
	EndIf

	
	zCadSX6(aParametros, .t., .f.)
Return

Static Function zCadSX6(aParams, lCombo, lDelet)
	Local aArea   := GetArea()
	// Local aAreaX6 := SX6->(GetArea())
	Local nAtual  := 0
	Local nColuna := 6
	Default lCombo := .T.
	Default lDelet := .F.
	Default aParams := {}
	Private lComboPvt := lCombo
	Private aParamsPvt := {}
	Private cParamsPvt := ""
	//Tamanho da Janela
	Private aTamanho := MsAdvSize()
	Private nJanLarg := aTamanho[5]
	Private nJanAltu := aTamanho[6]
	Private nColMeio := (nJanLarg)/4
	Private nEspCols := ((nJanLarg/2)-12)/4
	COL_T1  := 003
	COL_T2  := COL_T1+nEspCols
	COL_T3  := COL_T2+nEspCols
	COL_T4  := COL_T3+nEspCOls
	//Objetos gr·ficos
	Private oDlgParam
	//GetDados
	Private oMsGet
	Private aHeader     := {}
	Private aCols       := {}
	//Botıes
	Private aButtons    := {}

	aAdd(aButtons,{STR0072, "{|| oDlgParam:End()}", "oBtnSair"})    // "Quit"


	aParamsPvt := aParams
	cParamsPvt := ""

	//Percorrendo os par‚metros e adicionando
	For nAtual := 1 To Len(aParamsPvt)
		cParamsPvt += aParamsPvt[nAtual]+";"
	Next


	//Adicionando cabeÁalho
	aAdd(aHeader,{STR0074,  "ZZ_FILIAL",    "@!",   TAM_FILIAL, 0,  ".F.",  ".F.",  "C",    "", ""  ,})    //"Branch"
	aAdd(aHeader,{STR0075,  "ZZ_PARAME",    "@!",   010,            0,  ".F.",  ".F.",  "C",    "", ""  ,})//"Parameter"
	aAdd(aHeader,{STR0076,  "ZZ_TIPO",      "@!",   001,            0,  ".F.",  ".F.",  "C",    "", ""  ,})//"Type"
	aAdd(aHeader,{STR0077,  "ZZ_DESCRI",    "@!",   150,            0,  ".F.",  ".F.",  "C",    "", ""  ,})//"Description"
	aAdd(aHeader,{STR0078,  "ZZ_CONTEU",    "@!",   250,            0,  ".F.",  ".F.",  "C",    "", ""  ,})//"Conteud"
	aAdd(aHeader,{"Recno",  "ZZ_RECNUM",    "",     018,            0,  ".F.",  ".F.",  "N",    "", ""  ,})

	//Atualizando o aCols
	fAtuaCols(.T.)

	//Criando a janela
	DEFINE MSDIALOG oDlgParam TITLE STR0073 FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	oMsGet := MsNewGetDados():New(  3,;                                     //nTop
	3,;                                     //nLeft
	(nJanAltu/2)-33,;                       //nBottom
	(nJanLarg/2)-3,;                        //nRight
	GD_INSERT+GD_DELETE+GD_UPDATE,;     //nStyle
	"AllwaysTrue()",;                       //cLinhaOk
	,;                                      //cTudoOk
	"",;                                    //cIniCpos
	,;                                      //aAlter
	,;                                      //nFreeze
	999999,;                                //nMax
	,;                                      //cFieldOK
	,;                                      //cSuperDel
	,;                                      //cDelOk
	oDlgParam,;                               //oWnd
	aHeader,;                               //aHeader
	aCols)                                  //aCols
	oMsGet:lActive := .F.

	//Grupo Legenda
	@ (nJanAltu/2)-30, 003  GROUP oGrpLeg TO (nJanAltu/2)-3, (nJanLarg/2)-3     PROMPT STR0079       OF oDlgParam COLOR 0, 16777215 PIXEL  //"Actions"
	//Adicionando botıes
	For nAtual := 1 To Len(aButtons)
		@ (nJanAltu/2)-20, nColuna  BUTTON &(aButtons[nAtual][3]) PROMPT aButtons[nAtual][1]   SIZE 60, 014 OF oDlgParam  PIXEL
		(&(aButtons[nAtual][3]+":bAction := "+aButtons[nAtual][2]))
		nColuna += 63
	Next
	ACTIVATE MSDIALOG oDlgParam CENTERED

	// RestArea(aAreaX6)
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fInclui                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  14/11/2014                                                   |
 | Desc:  FunÁ„o de inclus„o de par‚metro                              |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function fInclui()
    Local nAtual   := oMsGet:nAt
    Local aColsAux := oMsGet:aCols
    Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })
     
    fMontaTela(3, 0)
Return
 
/*---------------------------------------------------------------------*
 | Func:  fAltera                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  14/11/2014                                                   |
 | Desc:  FunÁ„o de alteraÁ„o de par‚metro                             |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function fAltera()
    Local nAtual   := oMsGet:nAt
    Local aColsAux := oMsGet:aCols
    Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })
     
    //Se tiver recno v·lido
	If aColsAux[nAtual][nPosRecNo] != 0
        fMontaTela(4, aColsAux[nAtual][nPosRecNo])
	EndIf
Return
 
/*---------------------------------------------------------------------*
 | Func:  fExclui                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  14/11/2014                                                   |
 | Desc:  FunÁ„o de exclus„o de par‚metro                              |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function fExclui()
    Local nAtual   := oMsGet:nAt
    Local aColsAux := oMsGet:aCols
    Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })
     
    //Se tiver recno v·lido
	If aColsAux[nAtual][nPosRecNo] != 0
        fMontaTela(5, aColsAux[nAtual][nPosRecNo])
	EndIf
Return
 
/*---------------------------------------------------------------------*
 | Func:  Visualiza                                                   |
 | Autor: Daniel Atilio                                                |
 | Data:  14/11/2014                                                   |
 | Desc:  FunÁ„o de visualizaÁ„o de par‚metro                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function Visualiza()
    Local nAtual   := oMsGet:nAt
    Local aColsAux := oMsGet:aCols
    Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })
     
    //Se tiver recno v·lido
	If aColsAux[nAtual][nPosRecNo] != 0
        fMontaTela(2, aColsAux[nAtual][nPosRecNo])
	EndIf
Return
 
/*---------------------------------------------------------------------*
 | Func:  fAtuaCols                                                    |
 | Autor: Daniel Atilio                                                |
 | Data:  14/11/2014                                                   |
 | Desc:  FunÁ„o que atualiza o aCols com os par‚metros                |
 | Obs.:  Como a intenÁ„o È ter poucos par‚metros, sempre ele ir·      |
 |        percorrer a SX6 e adicionar no aCols                         |
 *---------------------------------------------------------------------*/
 
Static Function fAtuaCols(lFirst)
	Local aAreaAtu := GetArea()
	Local cDescricao
	Local cFilParam
	Local cFilComp:=Space( FWSizeFilial() )
	Local nInd,nYnd

	OpenSxs(,,,,cEmpAnt,"__SX6","SX6",,.F.)

	aCols := {}

	For nInd:=1 To Len(aParamsPvt)

		For nYnd:=1 To 2

			cFilParam:=IIf(nYnd==1,cFilComp,cFilAnt  )

			If !__SX6->(DbSeek( cFilParam+aParamsPvt[nInd] ) )
				Loop
			EndIf

			If __LANGUAGE=="ENGLISH"
				cDescricao:=(__SX6->X6_DSCENG+__SX6->X6_DSCENG1+__SX6->X6_DSCENG2)
			ElseIf __LANGUAGE=="SPANISH"
				cDescricao:=(__SX6->X6_DSCSPA+__SX6->X6_DSCSPA1+__SX6->X6_DSCSPA2)
			Else
				cDescricao:=(__SX6->X6_DESCRIC+__SX6->X6_DESC1+__SX6->X6_DESC2)
			EndIf

			aAdd( aCols, {  __SX6->X6_FIL,__SX6->X6_VAR,__SX6->X6_TIPO,cDescricao,__SX6->X6_CONTEUD,SX6->(RecNo()),.F.})

		Next
	Next

	//Se tiver zerada, adiciona conte˙do em branco
	If Len(aCols) == 0
		aAdd( aCols, {  	"","","","","",0,.F.})
	EndIf

	//Sen„o for a primeira vez, atualiza grid
	If !lFirst
		oMsGet:setArray(aCols)
	EndIf


	RestArea(aAreaAtu)
Return
 
/*---------------------------------------------------------------------*
 | Func:  fMontaTela                                                   |
 | Autor: Daniel Atilio                                                |
 | Data:  14/11/2014                                                   |
 | Desc:  FunÁ„o que atualiza o aCols com os par‚metros                |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function fMontaTela(nOpcP, nRecP)
    Local nColuna := 6
    Local nEsp := 15
	Local nAtual
    Private nOpcPvt := nOpcP
    Private nRecPvt := nRecP
    Private aOpcTip := {" ", "C - Caracter", "N - Number", "L - Boolean", "D - Date", "M - Memo"}
    Private oFontNeg := TFont():New("Tahoma")
    Private oDlgEdit
    //Campos
    Private oGetFil, cGetFil
    Private oGetPar, cGetPar
    Private oGetTip, cGetTip
    Private oGetDes, cGetDes
    Private oGetCon, cGetCon
    Private oGetRec, nGetRec
    //Botıes
    Private aBtnPar := {}
    aAdd(aBtnPar,{STR0055,   "{|| fBtnEdit(1)}", "oBtnConf"})    // "Confirm"
    aAdd(aBtnPar,{STR0080,    "{|| fBtnEdit(2)}", "oBtnCanc"})	// "Cancel"
 
    //Se n„o for inclus„o, pega os campos conforme array
	If nOpcP != 3
        aColsAux := oMsGet:aCols
        nLinAtu  := oMsGet:nAt
        nPosFil  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_FILIAL" })
        nPosPar  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_PARAME" })
        nPosTip  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_TIPO" })
        nPosDes  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_DESCRI" })
        nPosCon  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_CONTEU" })
        nPosRec  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })
 
        //Atualizando gets
        cGetFil := aColsAux[nLinAtu][nPosFil]
        cGetPar := aColsAux[nLinAtu][nPosPar]
        cGetTip := aColsAux[nLinAtu][nPosTip]
        cGetDes := aColsAux[nLinAtu][nPosDes]
        cGetCon := aColsAux[nLinAtu][nPosCon]
        nGetRec := aColsAux[nLinAtu][nPosRec]
 
        //Caracter
		If cGetTip == "C"
            cGetTip := aOpcTip[2]
        //NumÈrico
		ElseIf cGetTip == "N"
            cGetTip := aOpcTip[3]
        //LÛgico
		ElseIf cGetTip == "L"
            cGetTip := aOpcTip[4]
        //Data
		ElseIf cGetTip == "D"
            cGetTip := aOpcTip[5]
        //Memo
		ElseIf cGetTip == "M"
            cGetTip := aOpcTip[6]
		EndIf
 
    //Sen„o, deixa os campos zerados
	Else
     
        //Atualizando gets
        cGetFil := Space(TAM_FILIAL)
        cGetPar := Space(010)
        cGetTip := aOpcTip[1]
        cGetDes := Space(150)
        cGetCon := Space(250)
        nGetRec := 0
	EndIf
 
    oFontNeg:Bold := .T.

    //Criando a janela
    DEFINE MSDIALOG oDlgEdit TITLE "Dados:" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        nLinAux := 6
            //Filial
            @ nLinAux    , COL_T1                       SAY             oSayFil PROMPT  STR0074                       SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL                           PIXEL  //"Branch"
            @ nLinAux-003, COL_T1+ESP_CAMPO             MSGET           oGetFil VAR     cGetFil                     SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215                        PIXEL
            //Par‚metro
            @ nLinAux    , COL_T2                       SAY             oSayPar PROMPT  STR0075                  SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL       FONT oFontNeg       PIXEL  //"Parameter"
	If lComboPvt
                @ nLinAux-003, COL_T2+ESP_CAMPO         MSCOMBOBOX      oGetPar VAR     cGetPar ITEMS aParamsPvt        SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215                        PIXEL
	Else
                @ nLinAux-003, COL_T2+ESP_CAMPO         MSGET           oGetPar VAR     cGetPar                     SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215    VALID (cGetPar $ cParamsPvt)    PIXEL
	EndIf
            //Tipo
            @ nLinAux    , COL_T3                       SAY             oSayTip PROMPT  STR0076                     SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL       FONT oFontNeg       PIXEL //"Type"
            @ nLinAux-003, COL_T3+ESP_CAMPO             MSCOMBOBOX      oGetTip VAR     cGetTip ITEMS aOpcTip       SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215                        PIXEL
            //RecNo
            @ nLinAux    , COL_T4                       SAY             oSayRec PROMPT  "RecNo:"                        SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL                           PIXEL
            @ nLinAux-003, COL_T4+ESP_CAMPO             MSGET           oGetRec VAR     nGetRec                     SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215                        PIXEL
        nLinAux += nEsp
            //DescriÁ„o
            @ nLinAux    , COL_T1                       SAY             oSayDes PROMPT  STR0077                    SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL       FONT oFontNeg       PIXEL//"Description"
            @ nLinAux-003, COL_T1+ESP_CAMPO             MSGET           oGetDes VAR     cGetDes                     SIZE 300, 010 OF oDlgEdit COLORS 0, 16777215                        PIXEL
        nLinAux += nEsp
            //Conte˙do
            @ nLinAux    , COL_T1                       SAY             oSayCon PROMPT  STR0078                 SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL       FONT oFontNeg       PIXEL //"Conteud"
            @ nLinAux-003, COL_T1+ESP_CAMPO             MSGET           oGetCon VAR     cGetCon                     SIZE 300, 010 OF oDlgEdit COLORS 0, 16777215                        PIXEL
     
        //Grupo Legenda
        @ (nJanAltu/2)-30, 003  GROUP oGrpLegEdit TO (nJanAltu/2)-3, (nJanLarg/2)-3     PROMPT STR0078      OF oDlgEdit COLOR 0, 16777215 PIXEL//"Conteud"
        //Adicionando botıes
	For nAtual := 1 To Len(aBtnPar)
            @ (nJanAltu/2)-20, nColuna  BUTTON &(aBtnPar[nAtual][3]) PROMPT aBtnPar[nAtual][1]   SIZE 60, 014 OF oDlgEdit  PIXEL
            (&(aBtnPar[nAtual][3]+":bAction := "+aBtnPar[nAtual][2]))
            nColuna += 63
	Next
         
        //Se for visualizaÁ„o ou exclus„o, todos os gets ser„o desabilitados
	If nOpcP == 2 .Or. nOpcP == 5
            oGetFil:lActive := .F.
            oGetPar:lActive := .F.
            oGetTip:lActive := .F.
            oGetDes:lActive := .F.
            oGetCon:lActive := .F.
	Else
            //Se for alteraÁ„o, desabilita a Filial, Par‚metro e Tipo
		If nOpcP == 4
                oGetFil:lActive := .F.
                oGetPar:lActive := .F.
                oGetTip:lActive := .F.
		EndIf
	EndIf
         
        //Campo de RecNo sempre ser· desabilitado
        oGetRec:lActive := .F.
    ACTIVATE MSDIALOG oDlgEdit CENTERED
Return
 
/*---------------------------------------------------------------------*
 | Func:  fBtnEdit                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  16/12/2014                                                   |
 | Desc:  FunÁ„o que confirma a tela                                   |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function fBtnEdit(nConf)
   
Return
