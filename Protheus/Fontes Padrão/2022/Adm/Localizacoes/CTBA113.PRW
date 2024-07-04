#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBA113.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBA113  ³ Autor ³ Wilson Possani          ³ Data ³ 24-04-2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro Agrupador                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba113()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ P120                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³  Data  ³    BOPS     ³         Motivo de Alteracion          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Marco A.  ³29/11/16³SERINN001-107³ Se integra CTREE para quitar la gene- ³±±
±±³            ³        ³             ³ racion de tablas temporales en System.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBA113()

	Local aCores      := {{ "!Empty(CWS->CWS_LANC)", "BR_VERDE"}}
	Private cCadastro := STR0001
	Private aRotina   := MenuDef()
	Private cAlias    := "CWS"

	DbSelectArea(cAlias)
	MBrowse(6, 1, 22, 75, cAlias, , , , , 2,aCores, , , )

Return NIL

/*/{Protheus.doc} MENUDEF
Menu de opções definido na Browse

@author Wilson.Possani
@since 27/04/2014
@version P120
@Return Retorna as Opções de Menu para Manutenção da Base de Dados no Formulario
/*/

Static Function Menudef()

	Local aRotina := 	{;
						{ STR0002,	"AxPesqui"            ,0,1},; //"Buscar"
						{ STR0003,	"C113Visu('CWS',2,2)" ,0,2},; //"Visualizar"
						{ STR0004,	"C113Gera"			 	 ,0,3},; //"Gerar"
						{ STR0005,	"C113Desf"            ,0,5},; //"Desfazer"
						{ STR0006,	"C113Renu"            ,0,3},; //"Renumerar"
						{ STR0007,	"C113Leg"	         	 ,0,2};  //"Legenda"
						}
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} C113Gera()
Chama a rotina de geração de agrupadores através de uma MsgRun

@author Pedro Alencar
@since 03/06/2014
@version P12
/*/
//-------------------------------------------------------------------
Function C113Gera()
	MsgRun ( OemToAnsi(STR0036), "C113Gera", { || C113Processa() } ) //"Gerando agrupador..."
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} C113Processa()
Gerar os Agrupamentos para o Diário e SubDiário

@author Wilson.Possani
@since 27/04/2014
@version P120
/*/
//-------------------------------------------------------------------
Function C113Processa()

	Local cNumAsi	:= ""
	Local dDataAsi	:= Ctod("//")
	Local cMesAno	:= ""
	Local cModReg	:= ""
	Local __nRegs	:= ""
	Local lSumari	:= .T.
	Local nT		:= 0
	Local nY		:= 0
	Local nDebito	:= 0
	Local nCredito	:= 0
	Local cTabCWP	:= ""
	Local cTabCWS	:= ""
	Local cTabCT2	:= ""
	Local cTabCT2A	:= ""
	Local cTabCT2B	:= ""
	Local cTabCT2C	:= ""
	Local cLote		:= ""
	Local cSBlote	:= ""
	Local cDoc		:= ""
	Local cCta		:= ""
	Local dDtLanc	:= Ctod("//")
	Local aLotes	:= {}
	Local cTpSld	:= ""
	Local cArqCT2
	Local lContinua	:= .T.
	
	Private oTmpTable := Nil
	
	lContinua := Pergunte("CTBA113",.T.)
	
	CWP->(DbSetOrder(1))
	If lContinua .And. MV_PAR02 < MV_PAR01
		MsgStop(STR0008)
		lContinua := .F.
	Else
		If CWP->(DbSeek(xFilial("CWP") + MV_PAR03))
			If CWP->CWP_STATUS <> "1" // Valida se o Grupo está Ativo
				Help(" ",1,"STATINAT",,STR0009,1,0)  //"Lote está Inativo !"
				lContinua:= .F.
			EndIf
		Else
			Help(" ",1,"GRPLOTEINXISTENTE",,STR0038 + ": " + AllTrim(MV_PAR03),1,0)		//"Grupo de lotes não encontrado"
			lContinua := .F.
		EndIf
	EndIf
		
	If lContinua
		lSumari := If(CWP->CWP_SUMARI=="1", .T., .F.)
		cModReg := CWP->CWP_MODREG
		cDesAgp := CWP->CWP_DESGR
		dbSelectArea("CWR")
		dbSeek(xFilial("CWR")+MV_PAR03)
		While !(EOF()) .AND. CWR->CWR_CODIGO == MV_PAR03
			aAdd(aLotes, {CWR->CWR_LOTEIN, CWR->CWR_LOTEFI})
			CWR->(DbSkip())
		End
		
		For nY:=1 To Len(AllTrim(Str(MV_PAR04)))
			If nY <> 1
				cTpSld+= ","
			EndIf
			cTpSld+= "'"+Substr(AllTrim(Str(MV_PAR04)),nY,1)+"'"
		Next nY
			
		MsgRun(AllTrim(STR0039) + "...",STR0001,{|| cArqCT2 := C113RegsCT2(aLotes,cTpSld,cModReg,lSumari)}) 	//"Selecionando Registros..."###"Agrupadores"
			
		If Empty(cArqCT2)
			Help(" ",1,"AGRULANC",,STR0010,1,0)  //"Não existem Lançamentos para o agrupar !"
		Else
			Begin Transaction
				
				ProcRegua((cArqCT2)->(RecCount()))
				
				/* nao sumariza por conta */
				dDataAsi := MV_PAR02
				cMesAno  := Strzero(Month(dDataAsi),2) + Strzero(Year(dDataAsi),4)
				If !lSumari
					If cModReg $ "1|2"			/* nao sumarizado/agrupado e desagrupado */
						cNumAsi  := GetSX8Num("CWS", "CWS_LANC")
						RecLock( "CWS", .T. )
						CWS->CWS_FILIAL 	:= xFilial("CWS")
						CWS->CWS_LANC   	:= cNumAsi
						CWS->CWS_MESANO 	:= cMesAno
						CWS->CWS_DTLANC 	:= dDataAsi
						CWS->CWS_GRUPO  	:= MV_PAR03
						CWS->CWS_DSCGRP 	:= cDesAgp
						MsUnLock()
						cItem := StrZero(0,TamSX3("CWT_ITEM")[1])
						While !((cArqCT2)->(Eof()))
							CT2->(DbGoTo((cArqCT2)->REGCT2))
							RecLock( "CT2", .F. )
							CT2->CT2_LANC := cNumAsi
							MsUnLock()
							If (cArqCT2)->CT2_CONTA == (cArqCT2)->CT2_DEBITO
								cItem := Soma1(cItem)
								RecLock( "CWT", .T.)
								CWT->CWT_FILIAL 	:= xFilial("CWT")
								CWT->CWT_ITEM   	:= cItem
								CWT->CWT_LANC   	:= cNumAsi
								CWT->CWT_LOTE   	:= (cArqCT2)->CT2_LOTE
								CWT->CWT_SUBLOT		:= (cArqCT2)->CT2_SBLOTE
								CWT->CWT_DOC		:= (cArqCT2)->CT2_DOC
								CWT->CWT_CONTA  	:= (cArqCT2)->CT2_DEBITO
								CWT->CWT_CREDIT 	:= 0
								CWT->CWT_DEBITO 	:= (cArqCT2)->CT2_VALOR
								MsUnLock()
							EndIf
							If (cArqCT2)->CT2_CONTA == (cArqCT2)->CT2_CREDIT
								cItem := Soma1(cItem)
								RecLock( "CWT", .T.)
								CWT->CWT_FILIAL 	:= xFilial("CWT")
								CWT->CWT_ITEM   	:= cItem
								CWT->CWT_LANC   	:= cNumAsi
								CWT->CWT_LOTE   	:= (cArqCT2)->CT2_LOTE
								CWT->CWT_SUBLOT		:= (cArqCT2)->CT2_SBLOTE
								CWT->CWT_DOC		:= (cArqCT2)->CT2_DOC
								CWT->CWT_CONTA  	:= (cArqCT2)->CT2_CREDIT
								CWT->CWT_CREDIT 	:= (cArqCT2)->CT2_VALOR
								CWT->CWT_DEBITO 	:= 0 
								MsUnLock()
							EndIf  
							(cArqCT2)->(DbSkip())
							IncProc()
						Enddo
						ConfirmSX8()
					ElseIf cModReg == "3"		/* nao sumarizado/individual */
						While !((cArqCT2)->(Eof()))
							cLote := (cArqCT2)->CT2_LOTE
							cSBlote := (cArqCT2)->CT2_SBLOTE
							cDoc := (cArqCT2)->CT2_DOC 
							dDtLanc := (cArqCT2)->CT2_DATA
							cMesAno := Strzero(Month(dDataAsi),2) + Strzero(Year(dDataAsi),4)
							cNumAsi := GetSX8Num("CWS", "CWS_LANC")
							RecLock( "CWS", .T. )
							CWS->CWS_FILIAL 	:= xFilial("CWS")
							CWS->CWS_LANC   	:= cNumAsi
							CWS->CWS_MESANO 	:= cMesAno
							CWS->CWS_DTLANC 	:= dDataAsi
							CWS->CWS_GRUPO  	:= MV_PAR03
							CWS->CWS_DSCGRP 	:= cDesAgp
							MsUnLock()
							cItem := StrZero(0,TamSX3("CWT_ITEM")[1])
							While !((cArqCT2)->(Eof())) .And. (cArqCT2)->CT2_LOTE == cLote .And. (cArqCT2)->CT2_SBLOTE == cSBLote .And. (cArqCT2)->CT2_DOC == cDoc .And. (cArqCT2)->CT2_DATA == dDtLanc
								CT2->(DbGoTo((cArqCT2)->REGCT2))
								RecLock( "CT2", .F. )
								CT2->CT2_LANC := cNumAsi
								MsUnLock()
								If (cArqCT2)->CT2_CONTA == (cArqCT2)->CT2_DEBITO
									cItem := Soma1(cItem)
									RecLock( "CWT", .T.)
									CWT->CWT_FILIAL 	:= xFilial("CWT")
									CWT->CWT_ITEM   	:= cItem
									CWT->CWT_LANC   	:= cNumAsi
									CWT->CWT_LOTE   	:= (cArqCT2)->CT2_LOTE
									CWT->CWT_SUBLOT		:= (cArqCT2)->CT2_SBLOTE
									CWT->CWT_DOC		:= (cArqCT2)->CT2_DOC
									CWT->CWT_CONTA  	:= (cArqCT2)->CT2_DEBITO
									CWT->CWT_CREDIT 	:= 0
									CWT->CWT_DEBITO 	:= (cArqCT2)->CT2_VALOR
									MsUnLock()
								EndIf
								If (cArqCT2)->CT2_CONTA == (cArqCT2)->CT2_CREDIT
									cItem := Soma1(cItem)
									RecLock( "CWT", .T.)
									CWT->CWT_FILIAL 	:= xFilial("CWT")
									CWT->CWT_ITEM   	:= cItem
									CWT->CWT_LANC   	:= cNumAsi
									CWT->CWT_LOTE   	:= (cArqCT2)->CT2_LOTE
									CWT->CWT_SUBLOT		:= (cArqCT2)->CT2_SBLOTE
									CWT->CWT_DOC		:= (cArqCT2)->CT2_DOC
									CWT->CWT_CONTA  	:= (cArqCT2)->CT2_CREDIT
									CWT->CWT_CREDIT 	:= (cArqCT2)->CT2_VALOR
									CWT->CWT_DEBITO 	:= 0 
									MsUnLock()
								EndIf
								(cArqCT2)->(DbSkip())
								IncProc()
							Enddo
							ConfirmSX8()
						Enddo
					EndIf
				Else
					/* sumariza por conta */
					If cModReg == "1" /* sumarizado/Desagrupado */
						cNumAsi  := GetSX8Num("CWS", "CWS_LANC")
						RecLock( "CWS", .T. )
						CWS->CWS_FILIAL 	:= xFilial("CWS")
						CWS->CWS_LANC   	:= cNumAsi
						CWS->CWS_MESANO 	:= cMesAno
						CWS->CWS_DTLANC 	:= dDataAsi
						CWS->CWS_GRUPO  	:= MV_PAR03
						CWS->CWS_DSCGRP 	:= cDesAgp
						MsUnLock()
						cItem := StrZero(0,TamSX3("CWT_ITEM")[1])
						While !((cArqCT2)->(Eof()))
							cLote := (cArqCT2)->CT2_LOTE
							cSBlote := (cArqCT2)->CT2_SBLOTE
							cDoc := (cArqCT2)->CT2_DOC 
							cCta := (cArqCT2)->CT2_CONTA
							nDebito := 0
							nCredito := 0
							While !((cArqCT2)->(Eof())) .And. (cArqCT2)->CT2_LOTE == cLote .And. (cArqCT2)->CT2_SBLOTE == cSBLote .And. (cArqCT2)->CT2_DOC == cDoc .And. (cArqCT2)->CT2_CONTA == cCta
								CT2->(DbGoTo((cArqCT2)->REGCT2))
								RecLock( "CT2", .F. )
								CT2->CT2_LANC := cNumAsi
								MsUnLock()
								If (cArqCT2)->CT2_DEBITO == cCta
									nDebito += (cArqCT2)->CT2_VALOR
								EndIf
								If (cArqCT2)->CT2_CREDIT == cCta
									nCredito += (cArqCT2)->CT2_VALOR
								EndIf  
								(cArqCT2)->(DbSkip())
								IncProc()
							Enddo
							cItem := Soma1(cItem)
							RecLock( "CWT", .T.)
							CWT->CWT_FILIAL 	:= xFilial("CWT")
							CWT->CWT_ITEM   	:= cItem
							CWT->CWT_LANC   	:= cNumAsi
							CWT->CWT_LOTE   	:= cLote
							CWT->CWT_SUBLOT		:= cSBLote
							CWT->CWT_DOC		:= cDoc
							CWT->CWT_CONTA  	:= cCta
							CWT->CWT_CREDIT 	:= nCredito
							CWT->CWT_DEBITO 	:= nDebito
							MsUnLock()
						Enddo
						ConfirmSX8()
					ElseIf cModReg == "2"		/* sumarizado/agregrado */
						cNumAsi  := GetSX8Num("CWS", "CWS_LANC")
						RecLock( "CWS", .T. )
						CWS->CWS_FILIAL 	:= xFilial("CWS")
						CWS->CWS_LANC   	:= cNumAsi
						CWS->CWS_MESANO 	:= cMesAno
						CWS->CWS_DTLANC 	:= dDataAsi
						CWS->CWS_GRUPO  	:= MV_PAR03
						CWS->CWS_DSCGRP 	:= cDesAgp
						MsUnLock()
						cItem := StrZero(0,TamSX3("CWT_ITEM")[1])
						While !((cArqCT2)->(Eof()))
							cCta := (cArqCT2)->CT2_CONTA
							nDebito := 0
							nCredito := 0
							While !((cArqCT2)->(Eof())) .And. (cArqCT2)->CT2_CONTA == cCta
								CT2->(DbGoTo((cArqCT2)->REGCT2))
								RecLock( "CT2", .F. )
								CT2->CT2_LANC := cNumAsi
								MsUnLock()
								If (cArqCT2)->CT2_DEBITO == cCta
									nDebito += (cArqCT2)->CT2_VALOR
								EndIf
								If (cArqCT2)->CT2_CREDIT == cCta
									nCredito += (cArqCT2)->CT2_VALOR
								EndIf  
								(cArqCT2)->(DbSkip())
								IncProc()
							Enddo
							cItem := Soma1(cItem)
							RecLock( "CWT", .T.)
							CWT->CWT_FILIAL 	:= xFilial("CWT")
							CWT->CWT_ITEM   	:= cItem
							CWT->CWT_LANC   	:= cNumAsi
							CWT->CWT_CONTA  	:= cCta
							CWT->CWT_CREDIT 	:= nCredito
							CWT->CWT_DEBITO 	:= nDebito
							MsUnLock()
						Enddo
						ConfirmSX8()
					ElseIf cModReg == "3"		/* sumarizado/Individual */						
						cMesAno  := Strzero(Month(dDataAsi),2) + Strzero(Year(dDataAsi),4)
						While !((cArqCT2)->(Eof()))
							cLote := (cArqCT2)->CT2_LOTE
							cSBlote := (cArqCT2)->CT2_SBLOTE
							cDoc := (cArqCT2)->CT2_DOC
							dDtLanc := (cArqCT2)->CT2_DATA
							cNumAsi  := GetSX8Num("CWS", "CWS_LANC")
							RecLock( "CWS", .T. )
							CWS->CWS_FILIAL 	:= xFilial("CWS")
							CWS->CWS_LANC   	:= cNumAsi
							CWS->CWS_MESANO 	:= cMesAno
							CWS->CWS_DTLANC 	:= dDataAsi
							CWS->CWS_GRUPO  	:= MV_PAR03
							CWS->CWS_DSCGRP 	:= cDesAgp
							MsUnLock()
							cItem := StrZero(0,TamSX3("CWT_ITEM")[1])
							While !((cArqCT2)->(Eof())) .And. (cArqCT2)->CT2_LOTE == cLote .And. (cArqCT2)->CT2_SBLOTE == cSBLote .And. (cArqCT2)->CT2_DOC == cDoc .And. (cArqCT2)->CT2_DATA == dDtLanc
								cCta := (cArqCT2)->CT2_CONTA
								nDebito := 0
								nCredito := 0
								While !((cArqCT2)->(Eof())) .And. (cArqCT2)->CT2_LOTE == cLote .And. (cArqCT2)->CT2_SBLOTE == cSBLote .And. (cArqCT2)->CT2_DOC == cDoc .And. (cArqCT2)->CT2_CONTA == cCta .And. (cArqCT2)->CT2_DATA == dDtLanc
									CT2->(DbGoTo((cArqCT2)->REGCT2))
									RecLock( "CT2", .F. )
									CT2->CT2_LANC := cNumAsi
									MsUnLock()
									If (cArqCT2)->CT2_DEBITO == cCta
										nDebito += (cArqCT2)->CT2_VALOR
									EndIf
									If (cArqCT2)->CT2_CREDIT == cCta
										nCredito += (cArqCT2)->CT2_VALOR
									EndIf  
									(cArqCT2)->(DbSkip())
									IncProc()
								Enddo
								cItem := Soma1(cItem)
								RecLock( "CWT", .T.)
								CWT->CWT_FILIAL 	:= xFilial("CWT")
								CWT->CWT_ITEM   	:= cItem
								CWT->CWT_LANC   	:= cNumAsi
								CWT->CWT_LOTE   	:= cLote
								CWT->CWT_SUBLOT		:= cSBLote
								CWT->CWT_DOC		:= cDoc
								CWT->CWT_CONTA  	:= cCta
								CWT->CWT_CREDIT 	:= nCredito
								CWT->CWT_DEBITO 	:= nDebito
								MsUnLock()
							Enddo
							ConfirmSX8()
						Enddo
					EndIf
				EndIf
			End Transaction
		EndIf
		
		If oTmpTable <> Nil
			oTmpTable:Delete()
			oTmpTable := Nil
		Endif
		
		DbSelectArea("CWP")
		MsUnlockAll()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C113Desf()
Chama a rotina de cancelamento de agrupadores através de uma MsgRun

@author Pedro Alencar
@since 03/06/2014
@version P12
/*/
//-------------------------------------------------------------------
Function C113Desf(cAlias, nRec)
	MsgRun ( OemToAnsi(STR0037), "C113Desf", { || C113Desfaz(cAlias, nRec) } ) //"Desfazendo agrupador..."
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} C113Desfaz()
Defazer os Agrupamentos para o Diário e SubDiário

@author Wilson.Possani
@since 27/04/2014
@version P120

/*/
//-------------------------------------------------------------------
Function C113Desfaz(cAlias,nRec)

	Local lRet := .T.

	Local nI := 1
	Local nX := 0
	Local nY := 0
	Local aLotes:= {}
	Local cTabCWT:= ""
	Local aArea:= GetArea()
	Local cLanc
	Local cTpSld := ""
	Local nRecCWS := nRec
	Local cAliasCWS := cAlias
	Local nTotReg := 0


	If MsgYesNo(STR0013) //"Deseja Desfazer estes Lançamentos?"

		Begin Transaction

			dbSelectArea(cAliasCWS)
			DbGoto(nRecCWS)
			cLanc := CWS_LANC
	
			//Busca Lançamentos na CWT
			DbSelectArea("CWT")
			CWT->(dbSetOrder(1))
			cTabCWT	:= GetNextAlias()
			cQuerY		:= ""
			cQuery		+= "SELECT"
			cQuery		+= " * "
			cQuery		+= " FROM "+RetSQLName("CWT")+" TMP"
			cQuery		+= " WHERE"
			cQuery		+= " CWT_LANC = '"+cLanc+"' AND "
			cQuery     += " TMP.D_E_L_E_T_ = ' ' "
		
			If Select(cTabCWT)<>0
				DbSelectArea(cTabCWT)
				DbCloseArea()
			EndIf
		
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabCWT,.T.,.T.)
		
			Count To nTotReg
			ProcRegua(nTotReg)
			(cTabCWT)->(DbGoTop())
			While !((cTabCWT)->(Eof()))
				//Desfazendo Registro da CWT
				IncProc(STR0014) //"Desfazendo registros CWT..."
				CWT->(DbGoto((cTabCWT)->R_E_C_N_O_))
				RecLock( "CWT", .F. )
				CWT->(DbDelete())
				CWT->(MsUnlock())
				(cTabCWT)->(DbSkip())
			End

			DbSelectArea(cTabCWT)
			DbCloseArea()

			// Limpa campo CT2_LANC
			DbSelectArea("CT2")
			CT2->(dbSetOrder(1))
		
			cTabCT2	  := GetNextAlias()
			cQuerY		:= ""
			cQuery		+= "SELECT"
			cQuery		+= " * "
			cQuery		+= " FROM "+RetSQLName("CT2")+" TMP"
			cQuery		+= " WHERE"
			cQuery		+= " CT2_LANC = '"+cLanc+"' AND "
			cQuery     += " TMP.D_E_L_E_T_ = ' ' "
		
			If Select(cTabCT2)<>0
				DbSelectArea(cTabCT2)
				DbCloseArea()
			EndIf

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabCT2,.T.,.T.)
		
			Count To nTotReg
			ProcRegua(nTotReg)
			(cTabCT2)->(DbGoTop())
			While !((cTabCT2)->(Eof()))
				//Limpa Campo CT2_LANC
				IncProc(STR0015) //"Desfazendo registros CT2..."
				CT2->(DbGoto((cTabCT2)->R_E_C_N_O_))
				RecLock("CT2", .F.)
				CT2->CT2_LANC   	:= ""
				CT2->(MsUnlock())
				(cTabCT2)->(DbSkip())
			End
		
			DbSelectArea(cTabCT2)
			DbCloseArea()
						
			//Apaga Registro da CWS
			IncProc(STR0016) //"Desfazendo registros CWS..."
			dbSelectArea(cAliasCWS)
			(cAliasCWS)->(DbGoto(nRecCWS))
			RecLock( cAliasCWS, .F. )
			(cAliasCWS)->(DbDelete())
			MsUnlock()
						
			RestArea(aArea)
		End Transaction
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} C113Renu()
Renumerar os Agrupamentos para o Diário e SubDiário

@author Wilson.Possani
@since 29/04/2014
@version P120

/*/
//-------------------------------------------------------------------
Function C113Renu()

	If MsgYesNo(STR0017) //"Deseja renumerar os Lançamento? Lembre que este processo é irreversivel!"
		oProcess := MsNewProcess():New({|lEnd| C113M(@lEnd)}, STR0018, STR0019, .F.)//"Atualizando"#"Espere, renumerando..."
		oProcess:Activate()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C113M(lEnd)
Renumerar os Agrupamentos para o Diário e SubDiário

@author Wilson.Possani
@since 29/04/2014
@version P120

/*/
//-------------------------------------------------------------------
Static Function C113M(lEnd)
	Local nAlter	:= 0
	Local nCWS		:= 0
	Local nCWT		:= 0
	Local nCT2		:= 0
	Local cTabCWS	:= ""
	Local cTabCWT	:= ""
	Local cTabCT2	:= ""
	Local lContinua	:= .T.
	Local cLancAnt	:= ""
	Local cPriAsi	:= ""
	Local aArea		:= {}

	lContinua := Pergunte("CTBA113R", .T.)

	If lContinua
		aArea := GetArea()
		cTabCWS := GetNextAlias()
		cQry1 := " SELECT R_E_C_N_O_ "
		cQry1 += " FROM "+RetSqlName("CWS")
		cQry1 += " WHERE "
		cQry1 += " CWS_FILIAL = '" + xFilial("CWS") + "'"
		cQry1 += " AND CWS_MESANO = '"+MV_PAR01+"' "
		cQry1 += " AND D_E_L_E_T_ = ' ' "
		cQry1 += " ORDER BY CWS_LANC"
	
		If Select(cTabCWS)<>0
			DbSelectArea(cTabCWS)
			DbCloseArea()
		EndIf
	
		cQry1 := ChangeQuery(cQry1)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),cTabCWS,.T.,.T.)
	
		Count To nCWS
		oProcess:SetRegua1(nCWS)
	
		(cTabCWS)->(DbGoTop())
		Begin Transaction
			While (cTabCWS)->(!Eof())
				CWS->(DbGoTo((cTabCWS)->R_E_C_N_O_))
				oProcess:IncRegua1(STR0020+CWS->CWS_LANC)//"Lotes: "
				RecLock("CWS",.F.)
				cPriAsi	:= GetSx8Num("CWS","CWS_LANC")
				/*
				Tratamento para os registros de agrupamento */ 
				cTabCWT := GetNextAlias()
				cQry2 := " SELECT R_E_C_N_O_ "
				cQry2 += " FROM "+RetSqlName("CWT")
				cQry2 += " WHERE"
				cQry2 += " CWT_FILIAL = '" + xFilial("CWT") + "'" 
				cQry2 += " AND CWT_LANC = '"+CWS->CWS_LANC+"' "
				cQry2 += " AND D_E_L_E_T_ = ' ' "
		
				If Select(cTabCWT)<>0
					DbSelectArea(cTabCWT)
					DbCloseArea()
				EndIf
		
				cQry2 := ChangeQuery(cQry2)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry2),cTabCWT,.T.,.T.)
		
				Count To nCWT
				oProcess:SetRegua2(nCWT)
		
				(cTabCWT)->(DbGoTop())
				While (cTabCWT)->(!Eof())
					CWT->(DbGoTo((cTabCWT)->R_E_C_N_O_))
					RecLock("CWT",.F.)
					oProcess:IncRegua2(STR0021+CWT->CWT_ITEM)//"Agrupadores: "
					/*
					Tratamento para os lancamentos de um determinado agrupamento */
					cTabCT2 := GetNextAlias()
					cQry3 := " SELECT R_E_C_N_O_ "
					cQry3 += " FROM "+RetSqlName("CT2")
					cQry3 += " WHERE "
					cQry3 += " CT2_FILIAL = '" + xFilial("CT2") + "'"
					cQry3 += " AND CT2_LANC = '"+CWS->CWS_LANC+"' "
					cQry3 += " AND D_E_L_E_T_ = ' ' "
			
					If Select(cTabCT2)<>0
						DbSelectArea(cTabCT2)
						DbCloseArea()
					EndIf
		
					cQry3 := ChangeQuery(cQry3)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry3),cTabCT2,.T.,.T.)
		
					While (cTabCT2)->(!Eof())
						CT2->(DbGoTo((cTabCT2)->R_E_C_N_O_))
						RecLock("CT2",.F.)
						CT2->CT2_LANC := cPriAsi
						(cTabCT2)->(DbSkip())
					Enddo
					CWT->CWT_LANC := cPriAsi
					CWT->(MsUnLock())
					(cTabCWT)->(DbSkip())
				Enddo
				CWS->CWS_LANC := cPriAsi
				CWS->(MsUnLock())
				ConfirmSX8()		
				nAlter++
				(cTabCWS)->(DbSkip())
			Enddo
		End Transaction
		If nAlter == 0
			Help(" ",1,"AGRULANC",,STR0040,1,0)		//"Não há lançamentos para renumerar no período selecionado!"
		EndIf
		RestArea(aArea)
		Asize(aArea,0)
		aArea := Nil
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C113Visu(cAliasMB,nReg,nOpcX)
Visualizar Cadastro

@author Wilson.Possani
@since 29/04/2014
@version P120

/*/
//-------------------------------------------------------------------
Function C113Visu(cAliasMB,nReg,nOpcX)

	Processa({| | C113Proc(cAliasMB,nReg,nOpcX)}, STR0023, STR0024)//"Processando "#"Espere..."
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C113Proc(cAliasMB,nReg,nOpcX)
Visualizar Cadastro

@author Wilson.Possani
@since 29/04/2014
@version P120

/*/
//-------------------------------------------------------------------
Function C113Proc(cAliasMB,nReg,nOpcX)
	Local aModReg		:= {STR0025, STR0026, STR0027}	//"1-Desagregado","2-Agregado","3-Individual"
	Local oSize			:= Nil
	Local nCol			:= 0
	Local nLin			:= 0
	
	Private VISUAL		:= (nOpcX == 2)
	Private INCLUI		:= (nOpcX == 3)
	Private ALTERA		:= (nOpcX == 4)
	Private DELETA		:= (nOpcX == 5)
	Private cQrya		:= ""
	Private cAsien		:= ""
	Private cAgrp		:= ""
	Private cDesAgp		:= ""
	Private cModReg		:= ""
	Private dFcAsie		:= CTOD("//")
	Private aCampos		:= {}
	Private oVar		:= Nil
	Private oVar1		:= Nil
	Private oVar2		:= Nil
	Private oVar3		:= Nil
	Private oVar4		:= Nil
	Private oCombo		:= Nil
	Private oGetCWT		:= Nil
	Private _oDlgAgr	:= Nil
	
	oSize := FWDefSize():New(.T.)
		oSize:lLateral := .F.
		oSize:AddObject("PNLTOP",100,15,.T.,.T.)
		oSize:AddObject("PNLCEN",100,85,.T.,.T.)
		oSize:lProp	:= .T.             
		oSize:aMargins := {3,3,3,3} 
		oSize:Process()

	_oDlgAgr  := TDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],OemToAnsi(STR0028),,,,,,,,oMainWnd,.T.)	//"Cadastro de Lançamentos"

	cAsien  	:= CWS->CWS_LANC
	cAgrp   	:= CWS->CWS_GRUPO
	cDesAgp 	:= CWS->CWS_DSCGRP
	dFcAsie 	:= CWS->CWS_DTLANC
	DbSelectArea("CWP")
	DbSeek(xFilial("CWP")+CWS->CWS_GRUPO)

	cModReg := aModreg[Val(CWP->CWP_MODREG)]
	
	nLin := oSize:GetDimension("PNLTOP","LININI") + 5
	nCol := oSize:GetDimension("PNLTOP","COLINI") 

	@nLin,nCol Say STR0029 Pixel Of _oDlgAgr //"Lancto: "
	@nLin + 10,nCol MsGet oVar Var cAsien Size 80,10 Pixel Of _oDlgAgr When .F.

	@nLin,nCol + 110 Say STR0030 Pixel Of _oDlgAgr //"Dt Lancto: "
	@nLin + 10,nCol + 110 MsGet oVar1 Var dFcAsie Size 45,10 Pixel Of _oDlgAgr When .F.

	@nLin,nCol + 200 Say STR0031 Pixel Of _oDlgAgr //"Grupo"
	@nLin + 10,nCol + 200 MsGet oVar2 Var cAgrp Size 15,10 Pixel Of _oDlgAgr When .F.

	@nLin,nCol + 265  Say STR0032 Pixel Of _oDlgAgr //"Descrição"
	@nLin + 10,nCol + 265 MsGet oVar3 Var cDesAgp Size 80,10 Pixel Of _oDlgAgr When .F.

	@nLin,nCol + 390 Say STR0033 Pixel Of _oDlgAgr //"Mod.Reg.: "
	@nLin + 10,nCol + 390  ComboBox oCombo Var cModReg Items aModReg Size 60,13 Pixel Of _oDlgAgr When .F.

	//C113VerIt(oSize:GetDimension("PNLCEN","LININI"),oSize:GetDimension("PNLCEN","COLINI"),oSize:GetDimension("PNLCEN","XSIZE"),oSize:GetDimension("PNLCEN","YSIZE"))
	C113VerIt(oSize:GetDimension("PNLCEN","LININI"),oSize:GetDimension("PNLCEN","COLINI"),oSize:GetDimension("PNLCEN","COLEND"),oSize:GetDimension("PNLCEN","LINEND"))

	EnchoiceBar(_oDlgAgr,{||  _oDlgAgr:End() },{||  _oDlgAgr:End()   },,,,,,,.F.,.F.)

	_oDlgAgr:Activate(,,,.T.)
	
	oVar := Nil
	oVar1 := Nil
	oVar2 := Nil
	oVar3 := Nil
	oVar4 := Nil
	oCombo := Nil
	oGetCWT := Nil
	_oDlgAgr := Nil
	oDlg := Nil 
	FreeObj(oSize)
	oSize := Nil
	Asize(aCampos,0)
	aCampos := Nil
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} C113VerIt()
Visualizar Itens Cadastro

@author Wilson.Possani
@since 29/04/2014
@version P120

/*/
//-------------------------------------------------------------------
Static Function C113VerIt(nLin,nCol,nLar,nAlt)
	Local acols      	:= {}
	Local aHeader    	:= {}
	Local aDados     	:= {}
	Local nX		   	:= 0
	Local aCpoGDa	   	:= {"CWT_ITEM", "CWT_LOTE", "CWT_SUBLOT", "CWT_DOC", "CWT_CONTA", "CWT_DEBITO", "CWT_CREDIT"}
	Local aAlter     	:= {""}
	Local nOpc       	:= GD_INSERT+GD_DELETE+GD_UPDATE
	Local nY         	:= 0
	Local cLinhaOk   	:= "AllwaysTrue"
	Local cTudoOk    	:= "AllwaysTrue"
	Local cIniCpos   	:= ""
	Local nFreeze    	:= 000
	Local nMax       	:= 999
	Local cCampoOk   	:= "AllwaysTrue"
	Local cSuperApagar  := ""
	Local cApagaOk   	:= "AllwaysTrue"

	If CWP->CWP_MODREG == "2"
		aCpoGDa := {"CWT_ITEM", "CWT_CONTA", "CWT_DEBITO", "CWT_CREDIT"}
	EndIf

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aCpoGDa)
		If SX3->(DbSeek(aCpoGDa[nX]))
			Aadd(aHeader,{  AllTrim(X3Titulo()),;
				SX3->X3_CAMPO	,;
				SX3->X3_PICTURE ,;
				SX3->X3_TAMANHO ,;
				SX3->X3_DECIMAL ,;
				SX3->X3_VALID	,;
				SX3->X3_USADO	,;
				SX3->X3_TIPO	,;
				SX3->X3_F3 		,;
				SX3->X3_CONTEXT ,;
				SX3->X3_CBOX	,;
				SX3->X3_RELACAO})
		EndIf
	Next nX
	cTabCWT := GetNextAlias()
	cQryz := " SELECT * "+CRLF
	cQryz += " FROM "+RetSqlName("CWT")+CRLF
	cQryz += " WHERE CWT_LANC = '"+CWS->CWS_LANC+"' "+CRLF
	cQryz += " AND D_E_L_E_T_ = ' ' "+CRLF

	If Select(cTabCWT)<>0
		DbSelectArea(cTabCWT)
		DbCloseArea()
	EndIf

	cQryz := ChangeQuery(cQryz)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryz),cTabCWT,.T.,.T.)

	(cTabCWT)->(DbGoTop())
	While (cTabCWT)->(!EOF())
		IncProc(STR0024) //"Processando arquivo..."
		aDados := {}
		For nY := 1 To Len(aCpoGDa)
			Aadd(aDados, (cTabCWT)->&(aCpoGDa[nY]))
		Next
		Aadd(aDados, .F.)
		Aadd(aCols, aDados)
		(cTabCWT)->(DbSkip())
	End

	oGetCWT:= MsNewGetDados():New(nLin,nCol,nAlt,nLar,nOpc,cLinhaOk,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,_oDlgAgr,aHeader,aCols)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} C113RegsCT2()
Selectiona os lançamentos para serem agrupados

@author Marcello
@since 13/06/2014
@version P120
/*/
//-------------------------------------------------------------------
Function C113RegsCT2(aLotes,cTpSld,cModReg,lSumari)

	Local cArqCT2	:= ""
	Local cQuery	:= ""
	Local cAliasCT2	:= ""
	Local nT		:= 0
	Local nX		:= 0
	Local aEstrCT2	:= {}
	Local aArea		:= {}
	Local aOrdem1	:= {}
	Local aOrdem2	:= {}
	Local aOrdem3	:= {}
	Local aOrdem4	:= {}
	Local aOrdem5	:= {}
	
	Default cTpSld	:= "'1'"
	Default aLotes	:= {}
	Default cModReg	:= "2"
	Default lSumari	:= .F.
	
	If !Empty(aLotes)
		aArea := GetArea()
		/*-*/
		Aadd(aEstrCT2,{"CT2_DATA","D",8,0})
		Aadd(aEstrCT2,{"CT2_DC","C",TamSX3("CT2_DC")[1],0})
		Aadd(aEstrCT2,{"CT2_LOTE","C",TamSX3("CT2_LOTE")[1],TamSX3("CT2_LOTE")[2]})
		Aadd(aEstrCT2,{"CT2_SBLOTE","C",TamSX3("CT2_SBLOTE")[1],TamSX3("CT2_SBLOTE")[2]})
		Aadd(aEstrCT2,{"CT2_DOC","C",TamSX3("CT2_DOC")[1],TamSX3("CT2_DOC")[2]})
		Aadd(aEstrCT2,{"CT2_LINHA","C",TamSX3("CT2_LINHA")[1],TamSX3("CT2_LINHA")[2]})
		Aadd(aEstrCT2,{"CT2_DEBITO","C",TamSX3("CT2_DEBITO")[1],TamSX3("CT2_DEBITO")[2]})
		Aadd(aEstrCT2,{"CT2_CREDIT","C",TamSX3("CT2_CREDIT")[1],TamSX3("CT2_CREDIT")[2]})
		Aadd(aEstrCT2,{"CT2_VALOR","N",TamSX3("CT2_VALOR")[1],TamSX3("CT2_VALOR")[2]})
		Aadd(aEstrCT2,{"CT2_TPSALD","C",TamSX3("CT2_TPSALD")[1],TamSX3("CT2_TPSALD")[2]})
		Aadd(aEstrCT2,{"CT2_CONTA","C",TamSX3("CT2_DEBITO")[1],TamSX3("CT2_DEBITO")[2]})
		Aadd(aEstrCT2,{"REGCT2","N",10,0})
		/*-*/
		For nT := 1 To Len(aLotes)
			//CT2_DC || 1=Debito;2=Credito;3=Partida Doble;4=Cont.Hist;5=Prorrateo;6=Asto Estandar
			cAliasCT2 := GetNextAlias()
			cQuery := "SELECT CT2_DATA, CT2_DC, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_MOEDLC, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_TPSALD, R_E_C_N_O_"
			cQuery += " FROM " + RetSQLName("CT2")
			cQuery += " WHERE"
			cQuery += " CT2_FILIAL = '" + xFilial("CT2") + "' AND"
			cQuery += " CT2_DATA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND"
			cQuery += " CT2_LOTE BETWEEN '" + aLotes[nT][1] + "' AND '" +aLotes[nT][2] + "' AND"
			cQuery += " CT2_TPSALD IN ("+cTpSld+") AND"
			cQuery += " CT2_DC <> '4' AND "
			cQuery += " CT2_MOEDLC = '01' AND"
			cQuery += " CT2_LANC = '" + Space(Len(CT2->CT2_LANC)) + "' AND"
			cQuery += " D_E_L_E_T_ = ' '"		
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT2,.F.,.T.)
			If !((cAliasCT2)->(Eof()))
				If Empty(cArqCT2)
					cArqCT2	:= "cArqCT2"
					oTmpTable := FWTemporaryTable():New(cArqCT2)
					oTmpTable:SetFields(aEstrCT2)	
				Endif	
				
			If lSumari
				Do Case
					Case cModReg == "1"
						aOrdem1	:=	{"CT2_LOTE", "CT2_SBLOTE", "CT2_DOC", "CT2_CONTA"}
						oTmpTable:AddIndex("INDEX1", aOrdem1)
					Case cModReg == "2"
						aOrdem2	:= {"CT2_CONTA"}
						oTmpTable:AddIndex("INDEX2", aOrdem2)
					Case cModReg == "3"
						aOrdem3	:= {"CT2_LOTE", "CT2_SBLOTE", "CT2_DOC", "CT2_DATA", "CT2_CONTA"}
						oTmpTable:AddIndex("INDEX3", aOrdem3)
				EndCase
			Else
				If cModReg == "3"
						aOrdem4	:= {"CT2_LOTE", "CT2_SBLOTE", "CT2_DOC", "CT2_DATA"}
						oTmpTable:AddIndex("INDEX4", aOrdem4)
				Else
						aOrdem5	:= {"CT2_LOTE", "CT2_SBLOTE", "CT2_DOC"}
						oTmpTable:AddIndex("INDEX5", aOrdem5)
				EndIf
			EndIf
			
			oTmpTable:Create()
			
			DbSelectArea(cArqCT2)
				
				For nX := 1 To 10 
					If !(aEstrCT2[nX,2] == "C")
						TcSetField(cAliasCT2,aEstrCT2[nX,1],aEstrCT2[nX,2],aEstrCT2[nX,3],aEstrCT2[nX,4])
					EndIf
				Next nX
				
				While !((cAliasCT2)->(Eof()))
					If !Empty((cAliasCT2)->CT2_DEBITO)
						RecLock(cArqCT2,.T.)
						For nX := 1 To 10	
							Replace (cArqCT2)->(&(aEstrCT2[nX,1])) With (cAliasCT2)->(&(aEstrCT2[nX,1])) 
						Next
						Replace (cArqCT2)->CT2_CONTA With (cAliasCT2)->CT2_DEBITO
						Replace (cArqCT2)->REGCT2 With (cAliasCT2)->R_E_C_N_O_
					EndIf
					If !Empty((cAliasCT2)->CT2_CREDIT)
						RecLock(cArqCT2,.T.)
						For nX := 1 To 10
							Replace (cArqCT2)->(&(aEstrCT2[nX,1])) With (cAliasCT2)->(&(aEstrCT2[nX,1])) 
						Next
						Replace (cArqCT2)->CT2_CONTA With (cAliasCT2)->CT2_CREDIT
						Replace (cArqCT2)->REGCT2 With (cAliasCT2)->R_E_C_N_O_
					EndIf
					(cAliasCT2)->(DbSkip())
				Enddo
			EndIf
			DbSelectArea(cAliasCT2)
			DbCloseArea()
		Next
		
		RestArea(aArea)
	EndIf

Return (cArqCT2)


//-------------------------------------------------------------------
/*/{Protheus.doc} C113Leg()
Legenda

@author Wilson.Possani
@since 29/04/2014
@version P120

/*/
//-------------------------------------------------------------------
Function C113Leg()
	Local aLegenda := {}
	Local cCadastro:= STR0022 //"Lançamentos"
	aLegenda := {{"BR_VERDE"   , STR0035  }} //"Lançamento Gerado"

	BrwLegenda(cCadastro, STR0007, aLegenda) //"Legenda"
Return
