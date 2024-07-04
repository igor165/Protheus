#Include "PROTHEUS.CH"
#include "fileio.ch"
#include "OFINJD16.CH"

Static cMVGARJD_T := OFNJD15SIMU() // Sistema configurado em modo de Simulacao

#define lDebug .f.
#define __cDIRLOG__ "\logsmil\ofnjd16"

// TODO - tratar quando nao ha servico, so vem warrmemo com o credit memo, nao fica aguardando nf de servico.
//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFINJD16 º Autor ³ Rubens Takahashi    º Data ³ 14/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processamento do Arquivo WarrMemo - JD                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFINJD16()

Local lSchedule := FWGetRunSchedule()

Local bProcess := { |oSelf| OFNJD16PROC(oSelf , lSchedule) }
Local oTProces
Local cPerg := "OFINJD16"
Local aInfoCustom := {}

Private oLboxArquivo

// Local nOpcGetFil := GETF_RETDIRECTORY
// AADD(aRegs,{STR0008,STR0008,STR0008,"MV_CH1","C",99,0,0,"G","!Vazio().or.(MV_PAR01:=cGetFile('Diretorio','',,,,"+AllTrim(Str(nOpcGetFil))+"))","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",{STR0009},{},{}}) // Diretório

If lSchedule
	OFNJD16PROC( NIL , lSchedule)
Else

	Aadd( aInfoCustom , { STR0015 , { |oCenterPanel| OFNJD16VISLOG(oCenterPanel)} , "WATCH" }) // "Log Processamento WarrMemo"

	oTProces := tNewProcess():New(;
	/* 01 */				"OFINJD16",;
	/* 02 */				STR0001,;
	/* 03 */				bProcess,;
	/* 04 */				STR0002,;
	/* 05 */				cPerg ,;
	/* 06 */				aInfoCustom ,;
	/* 07 */				.t. /* lPanelAux */ ,;
	/* 08 */				 /* nSizePanelAux */ ,;
	/* 09 */				/* cDescriAux */ ,;
	/* 10 */				.t. /* lViewExecute */ ,;
	/* 11 */				.t. /* lOneMeter */ )
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFNJD16PROC º Autor ³ Rubens Takahashi  º Data ³ 14/05/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processamento do Arquivo MEMO                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OFNJD16PROC(oTProces,lSchedule)

Local oWS
Local cDiretorio := AllTrim(MV_PAR01)
Local nPos
Local nCont
Local nCont2
Local oObjAux
Local lOk

Local cAuxNomeNovo
Local cSQL
Local cAuxTipTem

Local cCodConc := AllTrim(GetNewPar("MV_MIL0005",""))

Local cAliasVMC := "TVMC"







Local lTemPeca := .f.

Local nRecVolta := 0
Local lAchouReg := 0

Local aVldZSPA := {0,0,0,0}

Local nDifZSPA := 0

Local aConvUM := {}
Local nPosConvUM
Local cUM
Local aAuxConv
Local lAtuSG

Default oTProces := ""

Private lB1CODFAB := (SB1->(FieldPos("B1_CODFAB")) <> 0)

Private aLogSchedule := {}

If Empty(cCodConc)
	OFNJD16LOG(oTProces, lSchedule, STR0003 , "MSGSTOP") // "Parâmetro de código de concessionário não cadastrado (MV_MIL0005)."
	Return
EndIf

// Nao veio do Schedule e está configurado para simulacao ...
If cMVGARJD_T
	aFiles := Directory(cDiretorio + "JD2DLR_*_WARRMEMO.xml")
Else
	aFiles := Directory(cDiretorio + "jd2dlr_" + cCodConc + "*_WARRMEMO.xml")
EndIf

If Len(aFiles) <= 0
	OFNJD16LOG(oTProces, lSchedule, STR0004 , "MSGINFO" ) // "Não existe arquivo para processar"
	Return
EndIf

// Conversao de Unidade de Medida
If !Empty(MV_PAR38)
	aConvUM := StrTokArr(AllTrim(MV_PAR38),";")
Else
	AADD( aConvUM , "BD/L " )
EndIf
//

lPrimeiro := .t.
If lSchedule
	VAI->(dbSetOrder(4))
	If !VAI->(dbSeek(xFilial("VAI")+__cUserID))
		OFNJD16LOG(oTProces, lSchedule, STR0016 + 'PULALINHA' + 'PULALINHA' + __cUserID , "MSGINFO" ) // "Usuário sem cadastro na equipe técnica"
		OFNJD16GRVLOG()
		Return .f.
	EndIf
	If Empty(VAI->VAI_FABUSR) .OR. Empty(VAI->VAI_FABPWD)
		OFNJD16LOG(oTProces, lSchedule, STR0017 + 'PULALINHA' + 'PULALINHA' + AllTrim(RetTitle("VAI_CODUSR")) + ": " + VAI->VAI_CODUSR, "MSGINFO" ) // "Técnico sem usuário/senha do portal da John Deere"
		OFNJD16GRVLOG()
		Return .f.
	EndIf
EndIf

VMB->(dbSetOrder(3))
VMC->(dbSetOrder(2))

oWS := WSJohnDeere_Garantia():New()
For nCont := 1 to Len(aFiles)

	If !oWS:ProcWarrMemo(cDiretorio + aFiles[nCont,1])
		Return .f.
	EndIf

	// Verifica se o arquivo é da filial correta
	If oWS:oOUTPUT:oHEADER:cDEALERACCOUNT <> cCodConc .and. !cMVGARJD_T
		Loop
	EndIf
	//

	// Não processar arquivos sem a TAG memotype
	If Empty(oWS:oOUTPUT:oHEADER:cMEMOTYPE)
		Loop
	EndIf
	//

	lOk := .t.

	If !VMB->(dbSeek(xFilial("VMB") + oWS:oOUTPUT:oHEADER:cSAPCLAIMNO )) .or. lDebug
		OFNJD16LOG(oTProces, lSchedule, ;
			STR0005 + 'PULALINHA' + 'PULALINHA' + ;
			"Dealer: " + oWS:oOUTPUT:oHEADER:cDEALERACCOUNT + 'PULALINHA' + ;
			"Claim: " + oWS:oOUTPUT:oHEADER:cSAPCLAIMNO + 'PULALINHA' + ;
			STR0011 + ": " + AllTrim(aFiles[nCont,1]) ;
			,"MSGINFO" ) // "Solicitação de garantia não encontrada"
		If !lDebug
			Loop
		EndIf
	EndIf

	If (!Empty(VMB->VMB_WARRME) .and. oWS:oOUTPUT:oHEADER:cMEMOTYPE == "4") .or. lDebug
		OFNJD16LOG(oTProces, lSchedule, ;
			STR0006 + 'PULALINHA' + 'PULALINHA' + ;
			AllTrim(RetTitle("VMB_CODGAR")) + ": " + VMB->VMB_CODGAR + 'PULALINHA' + ;
			AllTrim(RetTitle("VMB_NUMOSV")) + ": " + VMB->VMB_NUMOSV + 'PULALINHA' + ;
			AllTrim(RetTitle("VMB_REPARO")) + ": " + VMB->VMB_REPARO + 'PULALINHA' + ;
			STR0011 + ": " + AllTrim(aFiles[nCont,1]) ;
			,"MSGINFO" ) // "Arquivo de Warranty Memo da Solicitação de Garantia já foi processado"
		If !lDebug
			Loop
		EndIf
	EndIf

	If !VMC->(dbSeek(xFilial("VMC") + VMB->VMB_CODGAR)) .or. lDebug
		OFNJD16LOG(oTProces, lSchedule, ;
			STR0007 + 'PULALINHA' + 'PULALINHA' + ;
			AllTrim(RetTitle("VMB_CODGAR")) + ": " + VMB->VMB_CODGAR + 'PULALINHA' + ;
			AllTrim(RetTitle("VMB_NUMOSV")) + ": " + VMB->VMB_NUMOSV + 'PULALINHA' + ;
			AllTrim(RetTitle("VMB_REPARO")) + ": " + VMB->VMB_REPARO + 'PULALINHA' + ;
			STR0011 + ": " + AllTrim(aFiles[nCont,1]) ;
			,"MSGINFO" ) // "Solicitação de garantia sem itens."
		If !lDebug
			Loop
		EndIf
	EndIf

	// Se for Garantia Especial, verifica se a soma do rateio é resulta no total da SG
	If VMB->VMB_TIPGAR == "ZSPA" .or. lDebug
		aVldZSPA := {0,0,0,0}
		For nCont2 := 1 to Len(oWS:oOUTPUT:oPRICINGDETAIL)
			Do Case
			// Total da John Deere
			Case oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:cCondition == "ZCOM"
				aVldZSPA[1] :=  oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:nAmt
			// Total da Concessionaria
			Case oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:cCondition == "ZDLR"
				aVldZSPA[2] :=  oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:nAmt
			// Total do Cliente
			Case oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:cCondition == "ZCUS"
				aVldZSPA[3] :=  oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:nAmt
			// Total da S.G.
			Case oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:cCondition == "ZTOL"
				aVldZSPA[4] :=  oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:nAmt
			EndCase
		Next nCont2
		nDifZSPA := Abs(aVldZSPA[4] - (aVldZSPA[1] + aVldZSPA[2] + aVldZSPA[3]))
		If nDifZSPA > 0.03 .or. lDebug
			OFNJD16LOG(oTProces, lSchedule, ;
				STR0018 + 'PULALINHA' + ; // "A soma do rateio da garantia especial não está de acordo com o total da solicitação de garantia."
				STR0019 + 'PULALINHA' + ; // "Por favor, entre em contato com o suporte da John Deere."
				STR0020 + 'PULALINHA' + 'PULALINHA' + ; // "O arquivo não será processado."
				RetTitle("VMB_NUMOSV") + ": " + VMB->VMB_NUMOSV + 'PULALINHA' + ;
				RetTitle("VMB_CLAIM" ) + ": " + VMB->VMB_CLAIM  + 'PULALINHA' + ;
				STR0021 + ": " + aFiles[nCont,1] + 'PULALINHA' + 'PULALINHA' + ; // "Arquivo"
				STR0022 + ": " + IIF( aVldZSPA[1] <> 0 , Transform(aVldZSPA[1],"@E 9,999,999.99") , "" ) + 'PULALINHA' + ; // Contribuição da John Deere
				STR0023 + ": " + IIF( aVldZSPA[2] <> 0 , Transform(aVldZSPA[2],"@E 9,999,999.99") , "" ) + 'PULALINHA' + ; // Contribuição da Concessionária
				STR0024 + ": " + IIF( aVldZSPA[3] <> 0 , Transform(aVldZSPA[3],"@E 9,999,999.99") , "" ) + 'PULALINHA' + ; // "Contribuição do Cliente
				STR0025 + ": " + Transform(aVldZSPA[1]+aVldZSPA[2]+aVldZSPA[3],"@E 9,999,999.99") + 'PULALINHA' + 'PULALINHA' + ; // Contribuição Total
				STR0026 + ": " + Transform(aVldZSPA[4],"@E 9,999,999.99") + 'PULALINHA' ; // Total da Garantia
				,"AVISO" )

			If !lDebug
				Loop
			EndIf
		EndIf
	EndIf
	//

	If lDebug
		VMB->(dbSetOrder(1))
		VMB->(dbSeek(xFilial("VMB") + "00000447"))
		lAtuSG := OFNJD15AS("VMB" ,VMB->(Recno()), 3 , .f. , , , lSchedule )
		If lSchedule .and.  !lAtuSG
			Loop
		EndIf
		If lTemPeca
			lAtuSG := OFNJD15CM("VMB",VMB->(Recno()),3,lSchedule)
			If lSchedule .and.  !lAtuSG
				Loop
			EndIf
		EndIf

		Loop
	EndIf

	If lSchedule .and. lPrimeiro
		lAtuSG := OFNJD15AS("VMB" ,VMB->(Recno()),3,.f.,,,lSchedule)
		If !lAtuSG
			cMsgWSCError := GetWSCError(1)
			OFNJD16LOG(oTProces, lSchedule, ;
				STR0027 + 'PULALINHA' + 'PULALINHA' + ; // "Erro na atualização do Status da Solicitação de Garantia"
				IIf("WSCERR044" $ cMsgWSCError , STR0028 + 'PULALINHA' + 'PULALINHA', "" ) + ; // "Verifique o usuário e senha do portal da John Deere"
				cMsgWSCError ;
				,"MSGINFO" )
			OFNJD16GRVLOG()
			Return .f.
		EndIf
		lPrimeiro := .f.
	EndIf

	lTemPeca := .f.

	BEGIN TRANSACTION

	dbSelectArea("VMC")

	// Pagamento realizado
	If oWS:oOUTPUT:oHEADER:cMEMOTYPE == "1"

		dbSelectArea("VMB")
		RecLock("VMB",.f.)
		VMB->VMB_CRMEMO := oWS:oOUTPUT:oHEADER:cCRMEMONO
		VMB->(MSUnlock())
		lOk := .t.

	EndIf
	//
	If oWS:oOUTPUT:oHEADER:cMEMOTYPE == "4" .or. (oWS:oOUTPUT:oHEADER:cMEMOTYPE == "1" .and. oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORGRANDTOTAL == 0)

		// INICIO - Manoel - 02/04/2014 - Limpa Valores antes do Reprocessamento
		VMC->(dbSetOrder(5))
		If VMC->(dbSeek(xFilial("VMC") + VMB->VMB_CODGAR + "P" ))

			While !eof() .and. VMC->VMC_FILIAL+VMC->VMC_CODGAR+VMC->VMC_TIPOPS == xFilial("VMC") + VMB->VMB_CODGAR + "P"
				RecLock("VMC",.f.)
				VMC->VMC_VUPECR := 0
				VMC->VMC_VTPECR := 0
				VMC->VMC_QPCRET := 0
				Msunlock()
				VMC->(DbSkip())
			Enddo

		Endif
		// FIM - Manoel - 02/04/2014 - Limpa Valores antes do Reprocessamento

		// Processamento das Peças
		For nCont2 := 1 to Len(oWS:oOUTPUT:oREPLACEPART)

			lTemPeca := .t.

			oObjAux := oWS:oOUTPUT:oREPLACEPART[nCont2]
			//	WSDATA cPARTNO      AS string
			//	WSDATA cDESCRIPTION AS string
			//	WSDATA nQTY         AS float
			//	WSDATA nPRICE       AS float
			//	WSDATA nTOTAL       AS float

			If !VMC->(dbSeek(xFilial("VMC") + VMB->VMB_CODGAR + "P" + oObjAux:cPARTNO))

				// Se não encontrar e qtde retornada for 0, nao faz nada ...
				If oObjAux:nQTY == 0
					Loop
				EndIf
				//

				If lB1CODFAB
					SB1->(dbOrderNickName("CODFAB"))	// B1_CODFAB
					SB1->(dbSeek( xFilial("SB1") + PadR(AllTrim(oObjAux:cPARTNO),TamSX3("B1_CODFAB")[1])))
				Else
					SB1->(dbSetOrder(1))
					SB1->(dbSeek( xFilial("SB1") + PadR(AllTrim(oObjAux:cPARTNO),TamSX3("B1_COD")[1])))
				EndIf

				RecLock("VMC",.T.)
				VMC->VMC_FILIAL := xFilial("VMC")
				VMC->VMC_CODGAR := VMB->VMB_CODGAR
				VMC->VMC_SEQGAR := OFNJD15SEQ(xFilial("VMC"),VMB->VMB_CODGAR)
				VMC->VMC_TIPOPS := "P"
				VMC->VMC_GRUITE := SB1->B1_GRUPO // "JD"
				VMC->VMC_CODITE := SB1->B1_CODITE
				VMC->VMC_PARTNO := oObjAux:cPARTNO
				VMC->VMC_ORIGEM := "3"

				// Verifica se deve fazer conversao de UM ...
				cUM := SB1->B1_UM
				If (nPosConvUM := aScan(aConvUM,{ |x| SB1->B1_UM $ AllTrim(x) })) <> 0
					aAuxConv := StrTokArr(aConvUM[nPosConvUM],"/")

					If Len(aAuxConv) == 2 .and. AllTrim(aAuxConv[1]) == AllTrim(SB1->B1_UM) .and. AllTrim(aAuxConv[2]) == AllTrim(SB1->B1_SEGUM)
						cUM   := SB1->B1_SEGUM
					EndIf
				EndIf
				VMC->VMC_UM := cUM
				//


				// Verifica se existe alguma peça, se encontrar utiliza o mesmo tipo de tempo ...
				cSQL := "SELECT VMC_TIPTEM "
				cSQL +=  " FROM " + RetSQLName("VMC")
				cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
				cSQL +=   " AND VMC_CODGAR = '" + VMC->VMC_CODGAR + "'"
				cSQL +=   " AND VMC_TIPOPS = 'P'" // Pecas
				cSQL +=   " AND D_E_L_E_T_ = ' '"
				cAuxTipTem := FM_SQL(cSQL)
				If !Empty(cAuxTipTem)
					VMC->VMC_TIPTEM := cAuxTipTem
				EndIf
				//

			Else
				// INICIO - Manoel - 02/04/2014 - tenta achar o item correspondente
				If (VMC->VMC_QTDPEC <> oObjAux:nQTY) .or. (VMC->VMC_VUPECR <> 0)
					nRecVolta := VMC->(Recno())
					VMC->(DbSkip())
					lAchouReg := .f.
					While VMC->VMC_FILIAL+VMC->VMC_CODGAR+VMC->VMC_TIPOPS+Alltrim(VMC->VMC_PARTNO) == xFilial("VMC") + VMB->VMB_CODGAR + "P" + alltrim(oObjAux:cPARTNO)

						If VMC->VMC_QTDPEC == oObjAux:nQTY  .and. VMC->VMC_VUPECR == 0
							lAchouReg := .t.
							exit
						Endif

							VMC->(Dbskip())

					Enddo
					If !lAchouReg
						VMC->(dbgoto(nRecVolta))
						While VMC->VMC_FILIAL+VMC->VMC_CODGAR+VMC->VMC_TIPOPS+Alltrim(VMC->VMC_PARTNO) == xFilial("VMC") + VMB->VMB_CODGAR + "P" + alltrim(oObjAux:cPARTNO)

							If VMC->VMC_VUPECR == 0
								lAchouReg := .t.
								exit
							Endif

							VMC->(Dbskip())

						Enddo
						If !lAchouReg
							VMC->(dbgoto(nRecVolta))
						Endif
					Endif
				Endif
				// FIM - Manoel - 02/04/2014 - tenta achar o item correspondente
				RecLock("VMC",.f.)
			EndIf

			// Garatia Especial ...
			If VMB->VMB_TIPGAR == "ZSPA"
				VMC->VMC_VUPECR := oObjAux:nPRICE						// Valor Unitario (Retorno)
			Else
				VMC->VMC_VUPECR := ( oObjAux:nTOTAL / oObjAux:nQTY )	// Valor Unitario (Retorno)
			EndIf
			//
			VMC->VMC_VTPECR := oObjAux:nTOTAL	// Valor Total (Retorno)
//			VMC->VMC_ADITIV := oObjAux:nPRICE // valor Individual que a JD cobra do Cliente + Concessionaria na Garantia Especioal
			VMC->VMC_QPCRET := oObjAux:nQTY	// Qtde (Retorno)
			VMC->(MsUnlock())

			VMC->(dbGoTo(VMC->(Recno())))

		Next nCont2
		//

		// Processamento servicos ...
		// Cria matriz com todos os servicos retornados por TIPO e LOCAL DE TRABALHO
		aAuxSrvc := {}
		VMC->(dbSetOrder(2))
		For nCont2 := 1 to Len(oWS:oOUTPUT:oLABOR)
			oObjAux := oWS:oOUTPUT:oLABOR[nCont2]

			If oObjAux:nTOTAL <> 0
				nPos := aScan( aAuxSrvc , { |x| AllTrim(x[1]) == AllTrim(oObjAux:cTYPE) .and. AllTrim(x[2]) == AllTrim(oObjAux:cSUBTYPE) } )
				If nPos == 0
					AADD( aAuxSrvc , { PadR(oObjAux:cTYPE   ,TamSX3("VMC_TIPTRA")[1]),;
											PadR(oObjAux:cSUBTYPE,TamSX3("VMC_LOCTRA")[1]),;
											oObjAux:nHOURS,;
											oObjAux:nTOTAL,;
											0,; // Qtde de horas auxiliar (utilizado no rateio)
											oObjAux:nHOURS * oObjAux:nRATE } ) // Calcula valor total (Utilizado na SG Especial)
				Else
					aAuxSrvc[nPos,3] += oObjAux:nHOURS
					aAuxSrvc[nPos,4] += oObjAux:nTOTAL
					aAuxSrvc[nPos,6] += oObjAux:nHOURS * oObjAux:nRATE // Calcula valor total (Utilizado na SG Especial)
				EndIf
			EndIf
		Next nCont2
		//

		// Verifica se possui servico de fabrica, pois possui prioridade no retorno
		cSQL := "SELECT R_E_C_N_O_ VMCRECNO "
		cSQL +=  " FROM " + RetSQLName("VMC")
		cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
		cSQL +=   " AND VMC_CODGAR = '" + VMB->VMB_CODGAR + "'"
		cSQL +=   " AND VMC_TIPOPS = 'S'"
		cSQL +=   " AND VMC_ORIGEM = '1'" // Registro originado pela fabrica
		cSQL +=   " AND D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVMC , .F., .T. )
		While !(cAliasVMC)->(Eof())
			VMC->(dbGoTo((cAliasVMC)->VMCRECNO))

			// Procura um servico do mesmo tipo, local de trabalho e quantidade trabalhada para baixar
			nPos := aScan( aAuxSrvc , { |x| x[1] == VMC->VMC_TIPTRA .and. x[2] == VMC->VMC_LOCTRA .and. x[3] == VMC->VMC_QTDTRA } )
			If nPos <> 0
				dbSelectArea("VMC")
				RecLock("VMC",.f.)
				VMC->VMC_QSRRET := aAuxSrvc[nPos,3] // oObjAux:nHOURS
				VMC->VMC_VTSERR := (aAuxSrvc[nPos,4] + oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORSALESTAX ) // (oObjAux:nTOTAL + oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORSALESTAX)
				VMC->VMC_VALHRR := VMC->VMC_VTSERR / aAuxSrvc[nPos,3]

				VMC->(MsUnlock())

				// Remove linha para atualizacao ...
				aDel(aAuxSrvc,nPos)
				aSize(aAuxSrvc,Len(aAuxSrvc)-1)
				//

				//
				(cAliasVMC)->(dbSkip())
				Loop
				//

			EndIf

			// Se nao encontrar, verifica se existe algum servico com quantidade de horas menor
			// pode acontecer da John Deere manipular a quantidade de horas
			nPos := 1
			While nPos <= Len(aAuxSrvc)
				If aAuxSrvc[nPos,1] == VMC->VMC_TIPTRA .and. aAuxSrvc[nPos,2] == VMC->VMC_LOCTRA .and. aAuxSrvc[nPos,3] < VMC->VMC_QTDTRA
					dbSelectArea("VMC")
					RecLock("VMC",.f.)
					VMC->VMC_QSRRET := aAuxSrvc[nPos,3] // oObjAux:nHOURS
					VMC->VMC_VTSERR := (aAuxSrvc[nPos,4] + oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORSALESTAX ) // (oObjAux:nTOTAL + oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORSALESTAX)
					VMC->VMC_VALHRR := VMC->VMC_VTSERR / aAuxSrvc[nPos,3]

					VMC->(MsUnlock())

					// Remove linha para atualizacao ...
					aDel(aAuxSrvc,nPos)
					aSize(aAuxSrvc,Len(aAuxSrvc)-1)
					//

					//
					(cAliasVMC)->(dbSkip())
					Loop
					//
				EndIf
				++nPos
			End
			//

			(cAliasVMC)->(dbSkip())
		End
		(cAliasVMC)->(dbCloseArea())
		//

		// Se for PMP e existir algum servico ainda nao processado,
		// verifica se o é servico originado pela fabrica mas com quantidade de horas diferente...
		// pode ocorrer da John Deere alterar o valor de horas ...
		If VMB->VMB_TIPGAR $ "ZPIP/ZZMK" .and. Len(aAuxSrvc) > 0

			nPos := 1
			While nPos <= Len(aAuxSrvc)

				cSQL := "SELECT R_E_C_N_O_ VMCRECNO "
				cSQL +=  " FROM " + RetSQLName("VMC")
				cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
				cSQL +=   " AND VMC_CODGAR = '" + VMB->VMB_CODGAR + "'"
				cSQL +=   " AND VMC_TIPOPS = 'S'"
				cSQL +=   " AND VMC_ORIGEM = '1'" // Registro originado pela fabrica
				cSQL +=   " AND D_E_L_E_T_ = ' '"
				cSQL +=   " AND VMC_TIPTRA = '" + aAuxSrvc[nPos,1] + "'"
				cSQL +=   " AND VMC_LOCTRA = '" + aAuxSrvc[nPos,2] + "'"
				cSQL +=   " AND VMC_QTDTRA <> " + AllTrim(Str(aAuxSrvc[nPos,3],15,3))
				nAuxRecno := FM_SQL(cSQL)
				If nAuxRecno <> 0

					VMC->(dbGoTo(nAuxRecno))

					dbSelectArea("VMC")
					RecLock("VMC",.f.)
					VMC->VMC_QSRRET := aAuxSrvc[nPos,3] // oObjAux:nHOURS
					VMC->VMC_VTSERR := (aAuxSrvc[nPos,4] + oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORSALESTAX ) // (oObjAux:nTOTAL + oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORSALESTAX)
					VMC->VMC_VALHRR := VMC->VMC_VTSERR / aAuxSrvc[nPos,3]

					VMC->(MsUnlock())

					// Remove linha para atualizacao ...
					aDel(aAuxSrvc,nPos)
					aSize(aAuxSrvc,Len(aAuxSrvc)-1)
					//
				EndIf
				++nPos
			End
			//
		EndIf

		// Verifica os servicos requisitados na concessionaria ...
		For nCont2 := 1 to Len(aAuxSrvc)

			cSQL :=  " FROM " + RetSQLName("VMC")
			cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
			cSQL +=   " AND VMC_CODGAR = '" + VMB->VMB_CODGAR + "'"
			cSQL +=   " AND VMC_TIPOPS = 'S'"
			cSQL +=   " AND VMC_ORIGEM <> '1'" // Registro NAO originado pela fabrica
			cSQL +=   " AND VMC_TIPTRA = '" + aAuxSrvc[nCont2,1] + "'"
			cSQL +=   " AND VMC_LOCTRA = '" + aAuxSrvc[nCont2,2] + "'"
			cSQL +=   " AND D_E_L_E_T_ = ' '"
			nContReg := FM_SQL("SELECT COUNT(*) " + cSQL )

			nContRegAux := 0

			nAuxVlTotCalc := 0
			nAuxVlTotSrvc := aAuxSrvc[nCont2,4] + oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORSALESTAX // (oObjAux:nTOTAL + oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORSALESTAX)
			nAuxVlHora    := nAuxVlTotSrvc / aAuxSrvc[nCont2,3]
			nAuxVlHSPA    := aAuxSrvc[nCont2,6] / aAuxSrvc[nCont2,3] // Valor da Hora Retornada para Garantia Especial

			cSQL := "SELECT R_E_C_N_O_ VMCRECNO " + cSQL + " ORDER BY VMC_QTDTRA "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVMC , .F., .T. )
			While !(cAliasVMC)->(Eof())
				VMC->(dbGoTo((cAliasVMC)->VMCRECNO))

				dbSelectArea("VMC")
				RecLock("VMC",.f.)
				// Somente um Servico ...
				If nContReg == 1
					VMC->VMC_QSRRET := aAuxSrvc[nCont2,3] // oObjAux:nHOURS

					VMC->VMC_VTSERR := nAuxVlTotSrvc
					VMC->VMC_VALHRR := VMC->VMC_VTSERR / aAuxSrvc[nCont2,3]

				// Deve Ratear o servico
				Else
					nContRegAux++

					// Valor de horas enviada Menor ...
					If VMC->VMC_QTDTRA <= aAuxSrvc[nCont2,3] .and. nContRegAux <> nContReg

						VMC->VMC_QSRRET := VMC->VMC_QTDTRA // oObjAux:nHOURS
						VMC->VMC_VTSERR := Round(nAuxVlHora * VMC->VMC_QSRRET,TamSX3("VMC_VALHRR")[2])
						VMC->VMC_VALHRR := nAuxVlHora

						nAuxVlTotCalc      += VMC->VMC_VTSERR
						aAuxSrvc[nCont2,3] -= VMC->VMC_QTDTRA

					Else

						nAuxVlTotSrvc -= nAuxVlTotCalc

						VMC->VMC_QSRRET := aAuxSrvc[nCont2,3] // oObjAux:nHOURS
						VMC->VMC_VTSERR := nAuxVlTotSrvc
						VMC->VMC_VALHRR := Round(VMC->VMC_VTSERR / VMC->VMC_QSRRET,TamSX3("VMC_VALHRR")[2])

						aAuxSrvc[nCont2,3] -= aAuxSrvc[nCont2,3]

					EndIf


				EndIf

				// Se for Garantia especial Ajusta o valor da Hora Enviada para calcular corretamente
				// o rateio ...
				If VMB->VMB_TIPGAR == "ZSPA"
					VMC->VMC_VALHRE := Round(nAuxVlHSPA,2)
				EndIf
				//

				VMC->(MsUnlock())
				(cAliasVMC)->(dbSkip())

				// Verifica se ainda existe horas a ratear
				If aAuxSrvc[nCont2,3] <= 0
					Exit
				EndIf
				//

			End
			(cAliasVMC)->(dbCloseArea())

		Next nCont2

		// Se for PMP/Revisao e existir algum servico ainda nao processado,
		// verifica se o local de trabalho foi alterado pela John Deere...
		If VMB->VMB_TIPGAR $ "ZPIP/ZZMK" .and. Len(aAuxSrvc) > 0

			nPos := 1
			While nPos <= Len(aAuxSrvc)

				cSQL := "SELECT R_E_C_N_O_ VMCRECNO "
				cSQL +=  " FROM " + RetSQLName("VMC")
				cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
				cSQL +=   " AND VMC_CODGAR = '" + VMB->VMB_CODGAR + "'"
				cSQL +=   " AND VMC_TIPOPS = 'S'"
				cSQL +=   " AND D_E_L_E_T_ = ' '"
				cSQL +=   " AND VMC_TIPTRA = '" + aAuxSrvc[nPos,1] + "'"
				cSQL +=   " AND VMC_LOCTRA <> '" + aAuxSrvc[nPos,2] + "'"
				cSQL +=   " AND VMC_QTDTRA = " + AllTrim(Str(aAuxSrvc[nPos,3],15,3))
				nAuxRecno := FM_SQL(cSQL)
				If nAuxRecno <> 0

					VMC->(dbGoTo(nAuxRecno))

					dbSelectArea("VMC")
					RecLock("VMC",.f.)
					VMC->VMC_LOCTRA := aAuxSrvc[nPos,2]
					VMC->VMC_QSRRET := aAuxSrvc[nPos,3] // oObjAux:nHOURS
					VMC->VMC_VTSERR := (aAuxSrvc[nPos,4] + oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORSALESTAX ) // (oObjAux:nTOTAL + oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORSALESTAX)
					VMC->VMC_VALHRR := VMC->VMC_VTSERR / aAuxSrvc[nPos,3]

					VMC->(MsUnlock())

					// Remove linha para atualizacao ...
					aDel(aAuxSrvc,nPos)
					aSize(aAuxSrvc,Len(aAuxSrvc)-1)
					//
				EndIf
				++nPos
			End
			//
		EndIf


		// Atualiza deslocamento
		If oWS:oOUTPUT:oCLAIMTOTALS:oOTHERCREDITS:nTRAVELCREDIT <> 0
			cSQL := "SELECT R_E_C_N_O_ "
			cSQL +=  " FROM " + RetSQLName("VMC")
			cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
			cSQL +=   " AND VMC_CODGAR = '" + VMB->VMB_CODGAR + "'"
			cSQL +=   " AND VMC_TIPOPS = 'O'" // Outros Creditos
			cSQL +=   " AND VMC_CODMAT = 'WTYSUBL8'" // Fixed Travel
			cSQL +=   " AND D_E_L_E_T_ = ' '"
			nAuxRecno := FM_SQL(cSQL)
			If nAuxRecno == 0
				RecLock("VMC",.T.)
				VMC->VMC_FILIAL := xFilial("VMC")
				VMC->VMC_CODGAR := VMB->VMB_CODGAR
				VMC->VMC_SEQGAR := OFNJD15SEQ(xFilial("VMC"),VMB->VMB_CODGAR)
				VMC->VMC_TIPOPS := "O"
				VMC->VMC_CODMAT := "WTYSUBL8"
				VMC->VMC_ORIGEM := "3" //Fabrica (retorno)
			Else
				VMC->(dbGoTo(nAuxRecno))
				RecLock("VMC",.f.)
			EndIf
			VMC->VMC_CUSMAR := oWS:oOUTPUT:oCLAIMTOTALS:oOTHERCREDITS:nTRAVELCREDIT
			VMC->(MsUnlock())
		EndIf
		//

		// Atualiza outros creditos
		If oWS:oOUTPUT:oCLAIMTOTALS:oOTHERCREDITS:nOTHERTOTAL <> 0

			nAuxOutros := oWS:oOUTPUT:oCLAIMTOTALS:oOTHERCREDITS:nOTHERTOTAL

			nContOutros := FM_SQL("SELECT COUNT(*) FROM " + RetSQLName("VMC") + " WHERE VMC_FILIAL = '" + xFilial("VMC") + "' AND VMC_CODGAR = '" + VMB->VMB_CODGAR + "' AND VMC_TIPOPS = 'O' AND VMC_CODMAT <> 'WTYSUBL8' AND D_E_L_E_T_ = ' '")

			cSQL := "SELECT R_E_C_N_O_ VMCRECNO"
			cSQL +=  " FROM " + RetSQLName("VMC")
			cSQL += " WHERE VMC_FILIAL = '" + xFilial("VMC") + "'"
			cSQL +=   " AND VMC_CODGAR = '" + VMB->VMB_CODGAR + "'"
			cSQL +=   " AND VMC_TIPOPS = 'O'" // Outros Creditos
			cSQL +=   " AND VMC_CODMAT <> 'WTYSUBL8'" // Nao processa registro de deslocamento ...
			cSQL +=   " AND D_E_L_E_T_ = ' '"
			cSQL += " ORDER BY VMC_ORIGEM, VMC_CUSMAT "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVMC , .F., .T. )
			nTotCusMat := 0
			nPerOutCrd := 0
			While !(cAliasVMC)->(Eof())
				VMC->(dbGoTo((cAliasVMC)->VMCRECNO))

				If VMB->VMB_TIPGAR == "ZSPA" .and. nContOutros <> 0
					nTotCusMat += VMC->VMC_CUSMAT
				EndIf

				(cAliasVMC)->(dbSkip())
			End
			nPerOutCrd := nAuxOutros/nTotCusMat

			(cAliasVMC)->(dbGoTop())
			While !(cAliasVMC)->(Eof())
				VMC->(dbGoTo((cAliasVMC)->VMCRECNO))
				RecLock("VMC",.f.)

				If VMB->VMB_TIPGAR == "ZSPA" .and. nContOutros <> 0
					nAuxVlrTran := Round(VMC->VMC_CUSMAT * (nPerOutCrd),2)
				Else
					nAuxVlrTran := VMC->VMC_CUSMAT
				EndIf

				// Possui saldo para distribuicao
				If nAuxOutros >= nAuxVlrTran .and. nContOutros > 1
					VMC->VMC_CUSMAR := nAuxVlrTran
					nAuxOutros -= nAuxVlrTran
				Else
					VMC->VMC_CUSMAR := nAuxOutros
					nAuxOutros -= nAuxOutros
				EndIf
				//

				// Se for o ultimo registro e o saldo a distribuir for muito pequeno, pode ser problema de arredondamento
				// nesses casos, vamos jogar a diferenca ultimo registro processado ...
				If VMB->VMB_TIPGAR == "ZSPA" .and. (cAliasVMC)->(Eof()) .and. nAuxOutros <= 0.02
					VMC->VMC_CUSMAR -= nAuxOutros
				EndIf
				//

				VMC->(MsUnlock())
				(cAliasVMC)->(dbSkip())
			End
			(cAliasVMC)->(dbCloseArea())

			// Se ainda tiver saldo, gerar um registro "em branco"
			If nAuxOutros > 0
				RecLock("VMC",.T.)
				VMC->VMC_FILIAL := xFilial("VMC")
				VMC->VMC_CODGAR := VMB->VMB_CODGAR
				VMC->VMC_SEQGAR := OFNJD15SEQ(xFilial("VMC"),VMB->VMB_CODGAR)
				VMC->VMC_TIPOPS := "O"
				VMC->VMC_CODMAT := "WTYSUBL7"
				VMC->VMC_CUSMAR := nAuxOutros
				VMC->VMC_ORIGEM := "3" //Proc Warmemo

				If nAuxOutros == oWS:oOUTPUT:oCLAIMTOTALS:oOTHERCREDITS:nOTHERTOTAL .and. VMB->VMB_TIPGAR == "ZSPA"
					For nCont2 := 1 to Len(oWS:oOUTPUT:oPRICINGDETAIL)
						// Total de Outros Creditos
						If oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:cCondition == "ZOTH"
							VMC->VMC_CUSMAT := oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:nAmt
							Exit
						EndIf
					Next nCont2
				EndIf

				VMC->(MsUnlock())
			EndIf
			//

		EndIf
		//
	EndIf

	// Se tiver tudo OK atualiza a data de proc. do Warranty Memo
	If lOk

		dbSelectArea("VMB")
		RecLock("VMB",.f.)
		VMB->VMB_DTWMEM := dDataBase
		VMB->VMB_WARRME := AllTrim(aFiles[nCont,1])
		VMB->VMB_MEMTYP := oWS:oOUTPUT:oHEADER:cMEMOTYPE

		// Atualiza Totais ...
		VMB->VMB_STOTPC := oWS:oOUTPUT:oCLAIMTOTALS:oPARTS:nPARTSUBTOTAL
		VMB->VMB_ADITPC := oWS:oOUTPUT:oCLAIMTOTALS:oPARTS:nPARTSALLOW
		VMB->VMB_RETEPC := oWS:oOUTPUT:oCLAIMTOTALS:oPARTS:nPARTSSALESTAX
		VMB->VMB_TOTAPC := oWS:oOUTPUT:oCLAIMTOTALS:oPARTS:nPARTGRANDTOTAL
		VMB->VMB_STOTSV := oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORSUBTOTAL
		VMB->VMB_ADITSV := oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORALLOW
		VMB->VMB_RETESV := oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORSALESTAX
		VMB->VMB_TOTASV := oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORGRANDTOTAL
		VMB->VMB_DESLOC := oWS:oOUTPUT:oCLAIMTOTALS:oOTHERCREDITS:nTRAVELCREDIT
		VMB->VMB_OUTRAS := oWS:oOUTPUT:oCLAIMTOTALS:oOTHERCREDITS:nOTHERTOTAL
		VMB->VMB_TOTALW := oWS:oOUTPUT:oCLAIMTOTALS:nMEMOTOTAL
		//

		// PMP com matriz de reembolso
		If VMB->VMB_TIPGAR == "ZPIP"
			For nCont2 := 1 to Len(oWS:oOUTPUT:oPRICINGDETAIL)
				If AllTrim(oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:cCondition) == "ZAJL"
					VMB->VMB_MREEMS := oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:nAMT
				EndIf
				If AllTrim(oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:cCondition) == "ZAJP"
					VMB->VMB_MREEMP := oWS:oOUTPUT:oPRICINGDETAIL[nCont2]:nAMT
				EndIf
			Next nCont2
		EndIf
		//

		// Grava MEMO
		M->VMB_WAROBS := oWS:oOUTPUT:oHEADER:cHEADERCOMMENTS
		MSMM(VMB->VMB_WARMEM,TamSx3("VMB_WAROBS")[1],,M->VMB_WAROBS,1,,,"VMB","VMB_WARMEM")
		//
		If VMB->VMB_MEMTYP == "1"
			VMB->VMB_STATSG := "5"
		EndIf
		If VMB->VMB_MEMTYP == "4" .or. ( VMB->VMB_MEMTYP == "1" .and. oWS:oOUTPUT:oCLAIMTOTALS:oLABOR:nLABORGRANDTOTAL == 0)
			VMB->VMB_STATSG := "4"
		EndIf
		VMB->(MSUnlock())

		// Atualiza o Status da SG
		lAtuSG := OFNJD15AS("VMB" ,VMB->(Recno()),3   ,.f.      ,         ,      ,lSchedule)
		If lSchedule .and. !lAtuSG
			DisarmTransaction()
			MsUnlockAll()
			OFNJD16GRVLOG()
			Return .f.
		EndIf
		If lTemPeca
			lAtuSG := OFNJD15CM("VMB",VMB->(Recno()),3,lSchedule)
			If lSchedule .and. !lAtuSG
				DisarmTransaction()
				MsUnlockAll()
				OFNJD16GRVLOG()
				Return .f.
			EndIf
		EndIf
		//

	EndIf
	//

	END TRANSACTION

	// TO DO
	// Renomear arquivo de warrmemo ou transferir para outra pasta ...
	cAuxNomeNovo := AllTrim(aFiles[nCont,1])
	cAuxNomeNovo := Left(aFiles[nCont,1],Len(cAuxNomeNovo) - 3)
	cAuxNomeNovo += StrTran(DtoC(dDataBase),"/","")
	cAuxNomeNovo += "_" + StrTran(Time(),":","")
	FRENAMEEX(cDiretorio + aFiles[nCont,1], cDiretorio + cAuxNomeNovo )

Next nCont

oWS := NIL

OFNJD16GRVLOG()

If !lSchedule
	MsgInfo(STR0029 , STR0010 ) // "Fim do processamento."
EndIf

Return


/*/{Protheus.doc} OFNJD16LOG
Empilha log de processamento para gravacao posterior
@author Rubens
@since 17/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oTProces, object, descricao
@param lSchedule, logical, descricao
@param cMensagem, characters, descricao
@param cFuncName, characters, descricao
@type function
/*/
Static Function OFNJD16LOG( oTProces, lSchedule, cMensagem , cFuncName )
	If lSchedule == .f.
		If cFuncName == "AVISO"
			AVISO(STR0010, StrTran(cMensagem,'PULALINHA',CHR(13) + CHR(10)) , { "Ok" } , 3)
		Else
			&(cFuncName + '("' + StrTran(cMensagem,'PULALINHA','" + CHR(13) + CHR(10) + "') + '","' + STR0010 + '")' )
		EndIf
	Else
		AADD(aLogSchedule, " ")
		AADD(aLogSchedule, StrTran(cMensagem,'PULALINHA',CHR(13) + CHR(10)) )
		AADD(aLogSchedule, " ")
		AADD(aLogSchedule, Replicate("-",50))
		If lDebug
			Conout(StrTran(cMensagem,'PULALINHA',CHR(13) + CHR(10)))
		EndIf
	EndIf
Return

/*/{Protheus.doc} SchedDef
Definiciao de parametro que sera chamada pela rotina de Schedule
@author Rubens
@since 17/11/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function SchedDef()

	Local aParam := {;
		"P",;
		"OFINJD16",;
		"",;
		"",;
		"" ;
	}

Return aParam


/*/{Protheus.doc} OFNJD16VISLOG
Visualiza LOG de Processamento
@author Rubens
@since 17/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oPanel, object, descricao
@type function
/*/
Static Function OFNJD16VISLOG(oPanel)
	Local aFiles := {}
	Local oTPanelBOTTOM
	Local aArquivos := {}

	Local oOk := LoadBitmap( GetResources(), "LBOK" )
	Local oNo := LoadBitmap( GetResources(), "LBNO" )
	Local nCont

	aFiles := Directory(__cDIRLOG__ + "\" + AllTrim(cEmpAnt) + AllTrim(cFilAnt) + "*.log")

	If Len(aFiles) <= 0
		Return
	EndIf

	oTPanelBOTTOM := TPanel():New(0,0,"",oPanel,NIL,.T.,.F.,NIL,NIL,0,14,.T.,.F.)
	oTPanelBOTTOM:Align := CONTROL_ALIGN_BOTTOM

	For nCont := 1 to Len(aFiles)
  		aAdd(aArquivos,{.f.,aFiles[nCont,1]})
	Next

	oLboxArquivo := TWBrowse():New( 12,01,20,20,,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLboxArquivo:Align := CONTROL_ALIGN_ALLCLIENT
	oLboxArquivo:nAt := 1
	oLboxArquivo:SetArray(aArquivos)
	oLboxArquivo:addColumn( TCColumn():New( ""      , { || IIf(oLboxArquivo:aArray[oLboxArquivo:nAt,01],oOk,oNo) } ,,,,"LEFT" ,05,.t.,.F.,,,,.F.,) )
	oLboxArquivo:addColumn( TCColumn():New( STR0011 , { || oLboxArquivo:aArray[oLboxArquivo:nAt,02] }				 ,,,,"LEFT" ,60,.F.,.F.,,,,.F.,) ) // "Arquivo"
	oLboxArquivo:bLDblClick   := { || oLboxArquivo:aArray[oLboxArquivo:nAt,01] := !oLboxArquivo:aArray[oLboxArquivo:nAt,01] }
	oLboxArquivo:Refresh()

	TButton():New( 02, 02,STR0014, oTPanelBOTTOM , { || OFNJD16IMPLOG( aClone( oLboxArquivo:aArray ) ) }, 70 , 10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Visualizar"

Return

/*/{Protheus.doc} OFNJD16IMPLOG
Imprime log de processamento
@author Rubens
@since 17/11/2017
@version 1.0
@return ${return}, ${return_description}
@param aArquivos, array, descricao
@type function
/*/
Static Function OFNJD16IMPLOG(aArquivos)

	Local nCont
	Local cLogs := ""
	

	For nCont := 1 to Len(aArquivos)
		If !aArquivos[nCont,1]
			Loop
		EndIf

		oFReader := FWFileReader():New(__cDIRLOG__ + "\" + AllTrim(aArquivos[nCont,2]))
		If !oFReader:Open()
			Return .f.
		EndIf

		cLogs += Replicate("=",80) + CHR(13) + CHR(10)
		cLogs += PadC(STR0011 + " - " + AllTrim(aArquivos[nCont,2]),80) + CHR(13) + CHR(10) // "Arquivo"
		cLogs += Replicate("=",80) + CHR(13) + CHR(10)

		While oFReader:HasLine()
			cLogs += oFReader:GetLine() + CHR(13) + CHR(10)
		End
		oFReader:Close()

	Next nCont


	DEFINE MSDIALOG oDlgVisualiza FROM 00,00 TO 400,600 TITLE STR0012 OF oMainWnd PIXEL // "Log de Processamento"

	oTPanelTOP := TPanel():New(0,0,"",oDlgVisualiza,NIL,.T.,.F.,NIL,NIL,0,14,.T.,.F.)
	oTPanelTOP:Align := CONTROL_ALIGN_TOP

	oTPanelBOTTOM := TPanel():New(0,0,"",oDlgVisualiza,NIL,.T.,.F.,NIL,NIL,0,14,.T.,.F.)
	oTPanelBOTTOM:Align := CONTROL_ALIGN_BOTTOM

	oGetLogs := TMultiGet():New( 002, 002, { | u | If( PCount() == 0, cLogs, cLogs := u ) },oDlgVisualiza, 333, 120, (TFont():New("Courier New",0,-11, .T. , .T. )),.F.,,,,.T.,,.F.,,.F.,.F.,.T.,,,.F.,, )
	oGetLogs:Align := CONTROL_ALIGN_ALLCLIENT

	TButton():New( 02, 02,STR0013, oTPanelBOTTOM , { || oDlgVisualiza:End() }, 70 , 10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Fechar"

	ACTIVATE MSDIALOG oDlgVisualiza CENTER


Return

/*/{Protheus.doc} OFNJD16GRVLOG
Gera um log de processamento
@author Rubens
@since 17/11/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OFNJD16GRVLOG()
	Local cNome
	Local oLogger

	If Len(aLogSchedule) == 0
		Return
	EndIf

	cNome := AllTrim(cEmpAnt) + AllTrim(cFilAnt) + "_" + ALlTrim(FWTimeStamp(1)) + ".log"
	oLogger := DMS_LOGGER():New(cNome,__cDIRLOG__)
	oLogger:Log(aLogSchedule)

Return
