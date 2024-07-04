#INCLUDE "pcosincco.ch"
#INCLUDE "PROTHEUS.CH"

Function PcoSincCO(cAlias,nOpc)
Local aArea	:= GetArea()
Local cSinc :=  SuperGetMV("MV_PCOSINC",.T.,"1")

If ExistBlock( "PCOSINC01" ) 
	ExecBlock("PCOSINC01",.F.,.F., {cSinc, cAlias, nOpc, .F.})
Else
	Do Case
		Case cSinc == "2" .And. cAlias == "CT1"
			Do Case
				Case nOpc == 1 .Or. nOpc == 2 // 1- Inclusao , 2- Alteracao
					dbSelectArea("AK5")
					dbSetOrder(1)
					If MsSeek(xFilial()+PadR(CT1->CT1_CONTA,Len(AK5->AK5_CODIGO)))
						RecLock("AK5",.F.)
					Else 
						RecLock("AK5",.T.)
					EndIf
					AK5->AK5_FILIAL	:= xFilial("AK5")
					AK5->AK5_CODIGO	:= CT1->CT1_CONTA
					AK5->AK5_DESCRI	:= CT1->CT1_DESC01
					AK5->AK5_TIPO 	:= CT1->CT1_CLASSE
					If 		CT1->CT1_NORMAL == "1"    //1=Devedora
							AK5->AK5_DEBCRE	:= "2"    //2=Despesa
					ElseIf 	CT1->CT1_NORMAL == "2"
							AK5->AK5_DEBCRE	:= "1"    //1=Receita
					EndIf		
					AK5->AK5_DTINC	:= MsDate()
					AK5->AK5_DTINI	:= CT1->CT1_DTEXIS
					AK5->AK5_COSUP	:= CT1->CT1_CTASUP
					AK5->AK5_MSBLQL	:= CT1->CT1_BLOQ
					MsUnlock()
				Case nOpc == 3 // 3 - Exclusao
					dbSelectArea("AK5")
					dbSetOrder(1)
					MsSeek(xFilial()+PadR(CT1->CT1_CONTA,Len(AK5->AK5_CODIGO)))
					RecLock("AK5",.F.,.T.)
					dbDelete()
					MsUnlock()
				Case nOpc == 4 // Verificacao periodica de sincronismo
					dbSelectArea("CT1")
					dbSetOrder(1)
					dbSeek(xFilial()+Replicate("z",Len(CT1->CT1_CONTA)),.T.)
					dbSkip(-1)
					If !Bof() .And. !Eof()
						dbSelectArea("AK5")
						dbSetOrder(1)
						If !MsSeek(xFilial()+PadR(CT1->CT1_CONTA,Len(AK5->AK5_CODIGO)))
						  	Processa({||SincCT1() },STR0001) //"Verificando sincronização do Plano de Contas. Aguarde..."
						Endif
					EndIf
			EndCase
		Case cSinc == "3" .And. cAlias == "CTT"
			Do Case
				Case nOpc == 1 .Or. nOpc == 2 // 1- Inclusao , 2- Alteracao
					dbSelectArea("AK5")
					dbSetOrder(1)
					If MsSeek(xFilial()+PadR(CTT->CTT_CUSTO,Len(AK5->AK5_CODIGO)))
						RecLock("AK5",.F.)
					Else 
						RecLock("AK5",.T.)
					EndIf
					AK5->AK5_FILIAL	:= xFilial("AK5")
					AK5->AK5_CODIGO	:= CTT->CTT_CUSTO
					AK5->AK5_DESCRI	:= CTT->CTT_DESC01
					AK5->AK5_TIPO 	:= CTT->CTT_CLASSE
					If 		CTT->CTT_NORMAL == "1"    //1=Devedora
							AK5->AK5_DEBCRE	:= "2"    //2=Despesa
					ElseIf 	CTT->CTT_NORMAL == "2"
							AK5->AK5_DEBCRE	:= "1"    //1=Receita
					EndIf		
					AK5->AK5_DTINC	:= MsDate()
					AK5->AK5_DTINI	:= CTT->CTT_DTEXIS
					AK5->AK5_COSUP	:= CTT->CTT_CCSUP
					AK5->AK5_MSBLQL	:= CTT->CTT_BLOQ
					MsUnlock()
				Case nOpc == 3 // 3 - Exclusao
					dbSelectArea("AK5")
					dbSetOrder(1)
					MsSeek(xFilial()+PadR(CTT->CTT_CUSTO,Len(AK5->AK5_CODIGO)))
					RecLock("AK5",.F.,.T.)
					dbDelete()
					MsUnlock()
				Case nOpc == 4 // Verificacao periodica de sincronismo
					dbSelectArea("CTT")
					dbSetOrder(1)
					dbSeek(xFilial()+Replicate("z",Len(CTT->CTT_CUSTO)),.T.)
					dbSkip(-1)
					If !Bof() .And. !Eof()
						dbSelectArea("AK5")
						dbSetOrder(1)
						If !MsSeek(xFilial()+PadR(CTT->CTT_CUSTO,Len(AK5->AK5_CODIGO)))
						  	Processa({||SincCTT() },"STR0001") //"Verificando sincronização do Plano de Contas. Aguarde..."
						Endif
					EndIf
			
		EndCase	
	EndCase
EndIf

RestArea(aArea)
Return


Function SincCT1()

If ExistBlock( "PCOSINC01" ) 
	ExecBlock("PCOSINC01",.F.,.F., {SuperGetMV("MV_PCOSINC",.T.,"1"), "CT1", 2, .T.})
Else
	dbSelectArea("CT1")
	dbSeek(xFilial())
	ProcRegua(LastRec())
	While !Eof() .And. xFilial("CT1")==CT1->CT1_FILIAL
		IncProc()
		PcoSincCO("CT1",2)
		dbSkip()
	End
EndIf

Return 
Function SincCTT()

If ExistBlock( "PCOSINC01" ) 
	ExecBlock("PCOSINC01",.F.,.F., {SuperGetMV("MV_PCOSINC",.T.,"1"), "CTT", 2, .T.})
Else
	dbSelectArea("CTT")
	dbSeek(xFilial())
	ProcRegua(LastRec())
	While !Eof() .And. xFilial("CTT")==CTT->CTT_FILIAL
		IncProc()
		PcoSincCO("CTT",2)
		dbSkip()
	End
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOVLDSINCºAutor  ³ Pedro Pereira Lima º Data ³  30/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se a sincronização do plano de contas (CTB) pode serº±±
±±º          ³ excluído sem deixar registros sem referencia na AKD.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOVLDSINC(cAlias,cCTTCT1)
Local aArea 	:= GetArea()
Local aAreaCT1 := CT1->(GetArea())
Local aAreaCTT := CTT->(GetArea())
Local aAreaAK5 := AK5->(GetArea())
Local lRet 		:= .T.
Local cAliasQry:= ""

If cAlias == "CT1"
	cAliasQry := "PCOAKDCT1"

	//Se encontrar aspas no codigo, realiza a troca por caractere que pode ser usado em query
	If ValType(cCTTCT1) == "C" .And. At("'", cCTTCT1) > 0
		cCTTCT1 := ClearAsp(cCTTCT1)
	Endif
	
	BeginSql Alias cAliasQry
		SELECT 
			COUNT(*) REGAKD 
		FROM 
			%TABLE:AKD% AKD LEFT JOIN %TABLE:CT1% CT1 
		ON 
			CT1_CONTA = AKD_CO 
		WHERE 
			CT1_FILIAL = %xFilial:CT1% AND AKD_FILIAL=%xFilial:AKD% AND CT1_CONTA = %EXP:cCTTCT1% AND AKD.%NotDel% AND CT1.%NotDel%
	EndSql                  
	
	lRet := (cAliasQry)->REGAKD == 0
	
	If !lRet
		Aviso(STR0002,STR0004,{STR0005})
	EndIf

	(cAliasQry)->(dbCloseArea())	
Else
	cAliasQry := "PCOAKDCTT"
	
	BeginSql Alias cAliasQry
		SELECT 
			COUNT(*) REGAKD
		FROM 
			%TABLE:AKD% AKD LEFT JOIN %TABLE:CTT% CTT 
		ON 
			CTT_CUSTO = AKD_CO OR CTT_CUSTO = AKD_CC 
		WHERE 
			CTT_FILIAL = %xFilial:CTT% AND AKD_FILIAL=%xFilial:AKD% AND CTT_CUSTO = %EXP:cCTTCT1% AND AKD.%NotDel% AND CTT.%NotDel%
	EndSql

	lRet := (cAliasQry)->REGAKD == 0
	
	If !lRet
		Aviso(STR0002,STR0003,{STR0005})
	EndIf	

	(cAliasQry)->(dbCloseArea())
EndIf

RestArea(aAreaAK5)
RestArea(aAreaCTT)
RestArea(aAreaCT1)
RestArea(aArea)
Return lRet
