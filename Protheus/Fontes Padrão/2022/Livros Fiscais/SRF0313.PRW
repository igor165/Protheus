#Include "Protheus.Ch"
/*/                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SRF0313   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 05.07.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Instrucao Normativa SRF 313                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array[1] - Numero do Registro de Exportacao                 ³±±
±±³          ³Array[2] - Codigo do Pais de Destino                        ³±±
±±³          ³Array[3] - Numero do Despacho de Exportacao                 ³±±
±±³          ³Array[4] - Data de Embarque de Exportacao                   ³±±
±±³          ³Array[5] - Valor Total do Despacho na Moeda Negociada       ³±±
±±³          ³Array[6] - Codigo da Moeda Negociada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SRF0313()

Local aArea	:= GetArea()
Local lEEC		:= GetNewPar("MV_EECFAT",.F.)	//Integracao com SIGAEEC - Modulo de Exportacao (Average)
Local aRet		:= {"","","",CtoD(""),0,""}
Local cCampo	:= &(GetMv("MV_REGEXP"))

If lEEC
    dbSelectArea("SD2")		//Tabela de Itens da Nota Fiscal de Saida
    dbSetOrder(3)
    If dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	
		dbSelectArea("EEC")		//Capa do Processo de Embarque
		dbSetOrder(1)
		If dbSeek(xFilial("EEC")+SD2->D2_PREEMB)
			aRet[4] := EEC->EEC_DTEMBA		//Data de Embarque da Exportacao
			aRet[5] := EEC->EEC_TOTPED		//Valor Total do Despacho na Moeda Negociada
			
			dbSelectArea("SYA")
			dbSetOrder(1)
			If dbSeek(xFilial("SYA")+EEC->EEC_PAISDT)
				aRet[2] := Left(Alltrim(SYA->YA_SISEXP),3)		//Codigo do Pais de Destino
			Endif
			
			dbSelectArea("SYF")
			dbSetOrder(1)
			If dbSeek(xFilial("SYF")+EEC->EEC_MOEDA)
				aRet[6] := Alltrim(SYF->YF_COD_GI)		//Codigo da Moeda Negociada
			Endif
		Endif
		
		dbSelectArea("EEX")		//Capa da DDE
		dbSetOrder(1)
		If dbSeek(xFilial("EEX")+SD2->D2_PREEMB)
			aRet[3] := Left(Alltrim(EEX->EEX_NUM),11)		//Numero do Despacho de Exportacao
		Endif

		dbSelectArea("EE9")		//Itens do Processo de Embarque
		dbSetOrder(3)
		If dbSeek(xFilial("EE9")+SD2->D2_PREEMB)
			While !Eof() .And. EE9_FILIAL+EE9_NF+EE9_SERIE == xFilial("EE9")+SD2->D2_DOC+SD2->D2_SERIE
				If SD2->D2_PEDIDO == Posicione("EE7",1,xFilial("EE7")+EE9->EE9_PEDIDO,"EE7_PEDFAT") .And. ;
					SD2->D2_ITEMPV == Posicione("EE8",1,xFilial("EE8")+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN,"EE8_FATIT")
					aRet[1]:= Val(EE9->EE9_RE)	//Numero do Registro de Exportacao
					Exit
                Endif
				dbSelectArea("EE9")
				dbSkip()
			Enddo
		Endif

	Endif
ElseIf !Empty(cCampo) 
	If ValType(cCampo)== "C"
		cCampo:= Val(cCampo)
	EndIf
	aRet[1] := IIf(Empty(GetNewPar("MV_REGEXP","")),aRet[1],cCampo)		//Numero do Registro de Exportacao
	aRet[2] := IIf(Empty(GetNewPar("MV_PAISDES","")),aRet[2],&(GetMv("MV_PAISDES")))	//Codigo do Pais de Destino
	aRet[3] := IIf(Empty(GetNewPar("MV_DESPEX","")),aRet[3],&(GetMv("MV_DESPEX")))		//Numero do Despacho de Exportacao
	aRet[4] := IIf(Empty(GetNewPar("MV_DTEXP","")),aRet[4],&(GetMv("MV_DTEXP")))		//Data de Embarque da Exportacao
	aRet[5] := IIf(Empty(GetNewPar("MV_VLEXP","")),aRet[5],&(GetMv("MV_VLEXP")))	 	//Valor Total do Despacho na Moeda Negociada
	aRet[6] := IIf(Empty(GetNewPar("MV_CODMOEX","")),aRet[6],&(GetMv("MV_CODMOEX")))	//Codigo da Moeda Negociada
Else //Complemento Exportacao
    dbSelectArea("CDL")		
    dbSetOrder(1)
    If dbSeek(xFilial("CDL")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
		aRet[1] := CDL->CDL_NRREG																//Numero do Registro de Exportacao
		aRet[2] := Left(Alltrim(CDL->CDL_PAIS),3)												//Codigo do Pais de Destino
		aRet[3] := CDL->CDL_NRDESP																//Numero do Despacho de Exportacao
		aRet[4] := CDL->CDL_DTAVB																//Data de Embarque da Exportacao (Averbação)
		aRet[5] := CDL->CDL_VLREXP															 	//Valor Total do Despacho na Moeda Negociada
		aRet[6] := CDL->CDL_CODMOE																//Codigo da Moeda Negociada
	Endif	
Endif

RestArea(aArea)

Return(aRet)

