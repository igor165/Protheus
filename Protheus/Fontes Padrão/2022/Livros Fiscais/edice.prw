#Include "Protheus.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³EDICE     ³ Autor ³  Cleber S. A. Santos  ³ Data ³ 28.09.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³EDICE - Informacoes de Cargas Transportadas atraves do      ³±±
±±³          ³Estado do Ceara - CE                         		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ProcEDICE(cNumManIf,cTipArq,dDatIni,dDataFin)
Local aTrbs		:= {}
Private lEnd	:=	.F.
Private	nHandle

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivos temporarios            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTrbs := GeraTemp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Registros                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcReg(cNumManIf,cTipArq,dDatIni,dDataFin)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Temporária                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraEDICE()

Return( aTrbs )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcReg    ³ Autor ³Cleber S. A. Santos    ³ Data ³ 28.09.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa os documentos contidos nas Cargas                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcReg(cNumManIf,cTipArq,dDatIni,dDataFin)
Local aDud      := {"DUD",""}
Local aDtx      := {"DTX",""}
Local aDtc      := {"DTC",""}
Local cUFDes    :=""
Local cUFOri    :=""
Local nLinha    :=2
Local nTotalNF  :=0
Local nSeqRota  :=0
Local nNumManIf :=0
Local aEst      :={}
Local aAreaSM0  :={}

DTX->(dbSetOrder(3))
//Se for varios manIfestos considera periodo
IIf("2"$cTipArq;
,FsQuery(aDtx,1,"DTX_FILIAL='"+ xFilial("DTX")+"' AND DTX_FILORI='"+cFilAnt+"' AND DTX_DATMAN>='"+DTOS(dDatIni)+"' AND DTX_DATMAN<='"+DTOS(dDataFin)+"'",DTX->(IndexKey()));
,FsQuery(aDtx,1,"DTX_FILIAL='"+ xFilial("DTX")+"' AND DTX_FILORI='"+cFilAnt+"' AND DTX_MANIFE='"+cNumManIf+"'",DTX->(IndexKey())))
DTX->(dbGotop())

If !DTX->(Eof ())
	SequenTran(.T.)  //Faz com seja acresido o sequencial de transmição no estado selecionado na tabela LF.
EndIf

Do While !DTX->(Eof ())
	nSeqRota:= 0
	nTotalNF:= 0
	nTotalNF:= CalcNotas(DTX->DTX_FILORI,DTX->DTX_VIAGEM,DTX->DTX_FILMAN,DTX->DTX_MANIFE)

	aAreaSM0 := SM0->(GetArea())
	SM0->(dbSeek(cEmpAnt+DTX->DTX_FILDCA))
	cUFDes:= SM0->M0_ESTENT
	RestArea(aAreaSM0)
	aAreaSM0 := SM0->(GetArea())
	SM0->(dbSeek(cEmpAnt+DTX->DTX_FILORI))
	cUFOri:= SM0->M0_ESTENT
	RestArea(aAreaSM0)
	
	If cUFDes == "CE" .OR. cUFOri == "CE"
		cUFOri:=""
		//ManIfesto
		dbSelectArea("RT1")
		RecLock("RT1",.T.)
		nLinha++
		RT1->LINHA    := nLinha
		RT1->TPOREG   := "C02"
		RT1->NUMMAN   := Val(DTX->DTX_MANIFE)
		RT1->INSCDES  := ""
		RT1->UFDES    := cUFDes
		RT1->LACRES   := 0
		RT1->NOTAS    := nTotalNF
		RT1->VLRMERC  := DTX->DTX_VALMER
		RT1->PESO     := DTX->DTX_PESO
		RT1->CODPS    := ""
		MsUnlock()
		
		DTQ->(dbSetOrder(1))
		DTQ->(dbSeek(xFilial("DTQ") + DTX->DTX_VIAGEM))
		
		DTR->(dbSetOrder(1))
		DTR->(dbSeek(xFilial("DTR") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
		
		DA3->(dbSetOrder(1))
		DA3->(dbSeek(xFilial("DA3") + DTR->DTR_CODVEI))
		
		DA4->(dbSetOrder(1))
		DA4->(dbSeek(xFilial("DA4") + DA3->DA3_MOTORI))
		
		DUT->(dbSetOrder(1))
		DUT->(dbSeek(xFilial("DUT") + DA3->DA3_TIPVEI))
		
		//Motorista
		dbSelectArea("RT2")
		RecLock("RT2",.T.)
		nLinha++
		RT2->LINHA    := nLinha
		RT2->TPOREG   := "C04"
		RT2->CNHMOT   := Val(DA4->DA4_REGCNH)
		RT2->RGMOT    := DA4->DA4_RG
		RT2->ORGEXP   := DA4->DA4_RGORG
		RT2->UFEXP    := DA4->DA4_RGEST
		RT2->CPFMOT   := Val(DA4->DA4_CGC)
		RT2->NOMMOT   := DA4->DA4_NOME
		RT2->NUMMAN   := Val(DTX->DTX_MANIFE)
		MsUnlock()
		
		//Veiculos
		dbSelectArea("RT3")
		RecLock("RT3",.T.)
		nLinha++
		RT3->LINHA    := nLinha
		RT3->TPOREG   := "C05"
		//Se for Cavalo = M se for Carreta = C se for outros = U
		If DUT->DUT_CATVEI == "2"
			RT3->TPOVEI   := "M"
		ElseIf 	DUT->DUT_CATVEI == "3"
			RT3->TPOVEI   := "C"
		Else
			RT3->TPOVEI   := "U"
		EndIf
		
		RT3->RENAVAM  := DA3->DA3_RENAVA
		RT3->PLACAVEI := DA3->DA3_PLACA
		RT3->PESOTARA := DA3->DA3_TARA
		RT3->CAPPESO  := DA3->DA3_CAPACM
		RT3->CAPVOL   := DA3->DA3_VOLMAX
		RT3->NUMTRANS := ""
		RT3->NUMMAN   := Val(DTX->DTX_MANIFE)
		MsUnlock()
		
		//Fechamento Veiculo
		dbSelectArea("RT5")
		RecLock("RT5",.T.)
		nLinha++
		RT5->LINHA    := nLinha
		RT5->TPOREG   := "C07"
		RT5->NUMMAN   := Val(DTX->DTX_MANIFE)
		MsUnlock()
		
		DA8->(dbSetOrder(1))
		DA8->(dbSeek(xFilial("DA8") + DTQ->DTQ_ROTA))
		
		DUY->(dbSetOrder(1))
		DUY->(dbSeek(xFilial("DUY") + DA8->DA8_CDRORI))
		cUFOri := DUY->DUY_EST
		
		//Rota
		//Registro de Origem
		dbSelectArea("RT6")
		RecLock("RT6",.T.)
		nLinha++
		nSeqRota++
		RT6->LINHA  := nLinha
		RT6->TPOREG := "C08"
		RT6->SEQITI := nSeqRota
		RT6->TPOPAS := "O"
		RT6->UFROTA := cUFOri
		RT6->NUMMAN := Val(DTX->DTX_MANIFE)
		MsUnlock()

		//Para mesma Rota posso ter varios Estados por onde a carga irá passar
		DUD->(dbSetOrder(5))
		DUD->(dbSeek(xFilial("DUD") + DTX->DTX_FILORI + DTX->DTX_VIAGEM + DTX->DTX_FILMAN + DTX->DTX_MANIFE))
		
		Do While !DUD->(Eof()) .And.;
					DUD->( DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_FILMAN+DUD_MANIFE ) == xFilial("DUD") + DTX->( DTX_FILORI + DTX_VIAGEM + DTX_FILMAN + DTX_MANIFE )
			
			DT6->(dbSetOrder(1))
			DT6->(dbSeek(xFilial("DT6")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))
			
			DUY->(dbSetOrder(1))
			DUY->(dbSeek(xFilial("DUY") + DT6->DT6_CDRDES))
			
			If ASCAN (aEst,DUY->DUY_EST)==0 .AND. (DUY->DUY_EST<>cUFDes) .AND. (DUY->DUY_EST<>cUFOri)
				aEst:= {DUY->DUY_EST}
				
				dbSelectArea("RT6")
				RecLock("RT6",.T.)
				nLinha++
				nSeqRota++
				RT6->LINHA  := nLinha
				RT6->TPOREG := "C08"
				RT6->SEQITI := nSeqRota
				RT6->TPOPAS := "T"
				RT6->UFROTA := DUY->DUY_EST
				RT6->NUMMAN := Val(DTX->DTX_MANIFE)
				MsUnlock()
				
			EndIf
			
			DUD->(dbSkip())
		Enddo
		
		//Registro com o Destino
		dbSelectArea("RT6")
		RecLock("RT6",.T.)
		nLinha++
		nSeqRota++
		RT6->LINHA  := nLinha
		RT6->TPOREG := "C08"
		RT6->SEQITI := nSeqRota
		RT6->TPOPAS := "D"
		RT6->UFROTA := cUFDes
		RT6->NUMMAN := Val(DTX->DTX_MANIFE)
		MsUnlock()
		
		//Fechamento Motorista
		dbSelectArea("RT7")
		RecLock("RT7",.T.)
		nLinha++
		RT7->LINHA  := nLinha
		RT7->TPOREG := "C09"
		RT7->NUMMAN := Val(DTX->DTX_MANIFE)
		MsUnlock()

		//Conhecimento de Transporte
		DUD->(dbSetOrder(5))
		FsQuery(aDud,1,"DUD_FILIAL='"+ xFilial("DUD") +"' AND DUD_FILORI='"+ DTX->DTX_FILORI +"' AND DUD_VIAGEM='"+ DTX->DTX_VIAGEM+"' AND DUD_FILMAN='"+ DTX->DTX_FILMAN+"' AND DUD_MANIFE='"+ DTX->DTX_MANIFE+"'","DUD_FILIAL=='"+xFilial("DUD")+"' .AND. DUD_FILORI=='"+ DTX->DTX_FILORI +"' .AND. DUD_VIAGEM=='"+ DTX->DTX_VIAGEM +"' .AND. DUD_FILMAN=='"+ DTX->DTX_FILMAN+"' .AND. DUD_MANIFE=='"+ DTX->DTX_MANIFE+"'",DUD->(IndexKey()))
		DUD->(dbGotop())
		
		Do While !DUD->(Eof ())
			
			DT6->(dbSetOrder(1))
			DT6->(dbSeek(xFilial("DT6")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))
			
			SD2->(dbSetOrder(3))
			SD2->(dbSeek(xFilial("SD2")+DUD->DUD_DOC+DUD->DUD_SERIE))
			
			dbSelectArea("RT8")
			RecLock("RT8",.T.)
			nLinha++
			RT8->LINHA    := nLinha
			RT8->TPOREG   := "C10"
			RT8->MODDOC   := 8
			RT8->SERIEDOC := 	SerieNfId("DT6",2,"DT6_SERIE")			
			RT8->SUBSERIE := ""
			RT8->NUMDOC   := Val(DT6->DT6_DOC)
			RT8->CFOP     := Val(SD2->D2_CF)
			RT8->DTEMI    := DTOS(DT6->DT6_DATEMI)
			RT8->TPOFRETE := Val(DT6->DT6_TIPFRE)
			RT8->VALDOC   := DT6->DT6_VALTOT
			RT8->VALISEN  := 0
			RT8->BASEICM  := DT6->DT6_VALTOT
			RT8->VALICMS  := DT6->DT6_VALIMP
			RT8->VALOUTRA := 0
			RT8->VALMER   := DT6->DT6_VALMER
			RT8->NUMMAN   := Val(DTX->DTX_MANIFE)
			
			If DTW->(dbSeek(xFilial("DTW") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM + GetNewPar("MV_ATIVSAI", "")))
				RT8->DTSAIDA  := DTOS(DTW->DTW_DATREA)
			Else
				RT8->DTSAIDA  := DTOS(DT6->DT6_DATEMI)
			EndIf
			
			//Se o operador for o prestador do servico pegar o CNPJ do tomador
			If 	DT6->DT6_DEVFRE <> "4"
				//--1=Remetente---------
				If DT6->DT6_DEVFRE == "1"
					SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM))
					If(SA1->A1_PESSOA == "F")         			//Alteração foi feita de acordo com instruções da SEFAZ-CE
						RT8->CGCRDES  := Val(SM0->M0_CGC)		//estas informações estão anexadas ao chamado: SCFTYV
						RT8->INSCRDES := SM0->M0_INSC
						RT8->UFRDES   := SM0->M0_ESTENT
					Else
						RT8->CGCPART  := Val(SA1->A1_CGC)
						RT8->INSCPART := SA1->A1_INSCR
						RT8->UFPART   := SA1->A1_EST
					EndIf
					//--2=Destinatario---------
				ElseIf DT6->DT6_DEVFRE == "2"
					SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES))
					If(SA1->A1_PESSOA == "F")         			//Alteração foi feita de acordo com instruções da SEFAZ-CE
						RT8->CGCRDES  := Val(SM0->M0_CGC)		//estas informações estão anexadas ao chamado: SCFTYV
						RT8->INSCRDES := SM0->M0_INSC
						RT8->UFRDES   := SM0->M0_ESTENT
					Else
						RT8->CGCPART  := Val(SA1->A1_CGC)
						RT8->INSCPART := SA1->A1_INSCR
						RT8->UFPART   := SA1->A1_EST
					EndIf
					//--3=Consignatario---------
				ElseIf DT6->DT6_DEVFRE == "3"
					SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLICON+DT6->DT6_LOJCON))
					If(SA1->A1_PESSOA == "F")         			//Alteração foi feita de acordo com instruções da SEFAZ-CE
						RT8->CGCRDES  := Val(SM0->M0_CGC)		//estas informações estão anexadas ao chamado: SCFTYV
						RT8->INSCRDES := SM0->M0_INSC
						RT8->UFRDES   := SM0->M0_ESTENT
					Else
						RT8->CGCPART  := Val(SA1->A1_CGC)
						RT8->INSCPART := SA1->A1_INSCR
						RT8->UFPART   := SA1->A1_EST
					EndIf
				EndIf
			Else
				//--4=Despachante---------
				SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIDPC+DT6->DT6_LOJDPC))
				If(SA1->A1_PESSOA == "F")         	   		//Alteração foi feita de acordo com instruções da SEFAZ-CE
					RT8->CGCRDES  := Val(SM0->M0_CGC)		//estas informações estão anexadas ao chamado: SCFTYV
					RT8->INSCRDES := SM0->M0_INSC
					RT8->UFRDES   := SM0->M0_ESTENT
				Else
					RT8->CGCPART  := Val(SA1->A1_CGC)
					RT8->INSCPART := SA1->A1_INSCR
					RT8->UFPART   := SA1->A1_EST
				EndIf
			EndIf
			
			//Se o tomador do servico for o remetente pegar os dados do destinatario
			If DT6->DT6_DEVFRE == "1"
				SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES))
				If(SA1->A1_PESSOA == "F")         			//Alteração foi feita de acordo com instruções da SEFAZ-CE
					RT8->CGCRDES  := Val(SM0->M0_CGC)		//estas informações estão anexadas ao chamado: SCFTYV
					RT8->INSCRDES := SM0->M0_INSC
					RT8->UFRDES   := SM0->M0_ESTENT
				Else
					RT8->CGCRDES  := Val(SA1->A1_CGC)
					RT8->INSCRDES := SA1->A1_INSCR
					RT8->UFRDES   := SA1->A1_EST
				EndIf
				//Se o tomador do servico for o destinatario pegar os dados do remetente
			ElseIf DT6->DT6_DEVFRE == "2"
				SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM))
				If(SA1->A1_PESSOA == "F")         			//Alteração foi feita de acordo com instruções da SEFAZ-CE
					RT8->CGCRDES  := Val(SM0->M0_CGC)		//estas informações estão anexadas ao chamado: SCFTYV
					RT8->INSCRDES := SM0->M0_INSC
					RT8->UFRDES   := SM0->M0_ESTENT
				Else
					RT8->CGCRDES  := Val(SA1->A1_CGC)
					RT8->INSCRDES := SA1->A1_INSCR
					RT8->UFRDES   := SA1->A1_EST
				EndIf
			Else
				RT8->CGCRDES  := 0
				RT8->INSCRDES := ""
				RT8->UFRDES   := ""
			EndIf
			
			MsUnlock()

			DTC->(dbSetOrder(7))//Trazer as notas em ordem
			SA1->(dbSetOrder(1))
			SB1->(dbSetOrder(1))

			FsQuery(aDtc,1,"DTC_FILIAL='"+ xFilial("DTC") +"' AND DTC_DOC='"+ DT6->DT6_DOC +"' AND DTC_SERIE='"+ DT6->DT6_SERIE +"' AND DTC_FILDOC='"+ DT6->DT6_FILDOC+"'","DTC_FILIAL=='"+xFilial("DTC")+"' .AND. DTC_FILDOC=='"+ DT6->DT6_FILDOC +"' .AND. DTC_DOC=='"+ DT6->DT6_DOC+"' .AND. DTC_SERIE=='"+ DT6->DT6_SERIE+"'",DTC->(IndexKey()))
			DTC->(dbGotop())
			
			Do While !DTC->(Eof())

				dbSelectArea("RT9")
				//Se for a mesma nota apenas acumula os valores
				If  RT9->(dbseek(Str(Val(DTX->DTX_MANIFE),14)+Str(Val(DT6->DT6_DOC),10)+Str(Val(DTC->DTC_NUMNFC),10)+DTC->DTC_SERNFC))
					RecLock("RT9",.F.)
				else
					RecLock("RT9",.T.)
					nLinha++
					RT9->LINHA     := nLinha
					
					//Fechamento Nota Fiscal
					dbSelectArea("RT10")
					RecLock("RT10",.T.)
					nLinha++
					RT10->LINHA    := nLinha
					RT10->TPOREG   := "C16"
					RT10->NUMMAN   := Val(DTX->DTX_MANIFE)
					RT10->NUMDOC   := Val(DT6->DT6_DOC)
					RT10->SERIEDOC := DTC->DTC_SERNFC
					RT10->NUMNF    := Val(DTC->DTC_NUMNFC)
					MsUnlock()
					
				EndIf
				RT9->TPOREG := "C12"
				
				SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM))
				If SA1->A1_PESSOA == "J"
					RT9->CGCREM := Val(SA1->A1_CGC)
					RT9->CPFREM := 0
				Else
					RT9->CGCREM := 0
					RT9->CPFREM := Val(SA1->A1_CGC)
				EndIf
				
				RT9->INSCREM  := SA1->A1_INSCR
				RT9->UFREM    := SA1->A1_EST
				RT9->INSCSUB  := ""
				RT9->RAZAOREM := SA1->A1_NOME
				
				SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES))
				If SA1->A1_PESSOA == "J"
					RT9->CGCDES := Val(SA1->A1_CGC)
					RT9->CPFDES := 0
				Else
					RT9->CGCDES := 0
					RT9->CPFDES := Val(SA1->A1_CGC)
				EndIf
				
				RT9->INSCDES   	:= SA1->A1_INSCR
				RT9->UFDES     	:= SA1->A1_EST
				RT9->RAZAODES  	:= SA1->A1_NOME
				RT9->PAISDES   	:= 0
				RT9->DTEMINF   	:= DTOS(DTC->DTC_EMINFC)
				RT9->MODDOC    	:= 1
				RT9->SERIEDOC  	:= DTC->DTC_SERNFC
				RT9->NUMNF     	:= Val(DTC->DTC_NUMNFC)
				RT9->CFOPNF    	:= Val(DTC->DTC_CF)
				RT9->VALNF     	+= DTC->DTC_VALOR
				RT9->BASEICMS  	+= DTC->DTC_BASICM
				RT9->VALICMS   	+= DTC->DTC_VALICM
				RT9->VALISEN   	:= 0
				RT9->VALOUTRA  	:= 0
				RT9->VALDESC   	:= 0
				RT9->BASESUB   	+= DTC->DTC_BASESU
				RT9->ICMSSUB   	+= DTC->DTC_ICMRET
				RT9->VALDESP   	:= 0
				RT9->PESONF    	+= DTC->DTC_PESO
				RT9->TPOICENT  	:= 0
				RT9->INSCSUF   	:= 0
				RT9->OPDEBSUF  	:= 0
				RT9->QTDLACRE  	:= 0
				RT9->NUMMAN    	:= Val(DTX->DTX_MANIFE)
				RT9->NUMDOC   	:= Val(DT6->DT6_DOC)
				RT9->SDOCC  	 	:= SerieNfId("DTC",2,"DTC_SERNFC")
											
				MsUnlock()				
				
				DTC->(dbSkip())
				
			Enddo
			FsQuery (aDtc,2,)

			//Fechamento Conhecimento Transporte
			dbSelectArea("RT11")
			RecLock("RT11",.T.)
			nLinha++
			RT11->LINHA  := nLinha
			RT11->TPOREG := "C18"
			RT11->NUMMAN := Val(DTX->DTX_MANIFE)
			RT11->NUMDOC := Val(DT6->DT6_DOC)
			MsUnlock()
			
			DUD->(dbSkip())
		Enddo
		FsQuery (aDud,2,)
		
		//Fechamento ManIfesto de Carga
		dbSelectArea("RT12")
		RecLock("RT12",.T.)
		nLinha++
		RT12->LINHA  := nLinha
		RT12->TPOREG := "C19"
		RT12->NUMMAN := Val(DTX->DTX_MANIFE)
		MsUnlock()
		
	EndIf
	
	nNumManIf:= Val(DTX->DTX_MANIFE)
	DTX->(dbSkip())
Enddo
FsQuery (aDtx,2,)


//Encerramento Arquivo
dbSelectArea("RT13")
RecLock("RT13",.T.)
nLinha++
RT13->LINHA  := nLinha
RT13->TPOREG := "C99"
RT13->NUMMAN := nNumManIf
MsUnlock()

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Cleber S. A. Santos    ³ Data ³ 22.03.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()
Local aStruC02	:= {}
Local aStruC04	:= {}
Local aStruC05	:= {}
Local aStruC07  := {}
Local aStruC08  := {}
Local aStruC09  := {}
Local aStruC10  := {}
Local aStruC12  := {}
Local aStruC16  := {}
Local aStruC18  := {}
Local aStruC19  := {}
Local aStruC99  := {}
Local aStru5    := {}
Local aTrbs		:= {}
Local cArq		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo C02 - ManIfesto de Carga     											                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStruC02	:= {}
cArq    	:= ""
AADD(aStruC02,{"LINHA"		,"N" ,009 ,0})
AADD(aStruC02,{"TPOREG"		,"C" ,003 ,0})
AADD(aStruC02,{"NUMMAN"		,"N" ,014 ,0})
AADD(aStruC02,{"INSCDES"	,"C" ,014 ,0})
AADD(aStruC02,{"UFDES"		,"C" ,002 ,0})
AADD(aStruC02,{"LACRES"		,"N" ,005 ,0})
AADD(aStruC02,{"NOTAS"		,"N" ,005 ,0})
AADD(aStruC02,{"VLRMERC"	,"N" ,013 ,2})
AADD(aStruC02,{"PESO"     	,"N" ,009 ,3})
AADD(aStruC02,{"CODPS"		,"C" ,012 ,0})
cArq := CriaTrab(aStruC02)
dbUseArea(.T.,__LocalDriver,cArq,"RT1")
IndRegua("RT1",cArq,"Str(NUMMAN,14)")
AADD(aTrbs,{cArq,"RT1"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo C04 - IdentIficação do Motorista                 								                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aStruC04	:= {}
cArq      	:= ""
AADD(aStruC04,{"LINHA"     	,"N" ,009 ,0})
AADD(aStruC04,{"TPOREG"   	,"C" ,003 ,0})
AADD(aStruC04,{"CNHMOT"  	,"N" ,011 ,0})
AADD(aStruC04,{"RGMOT"    	,"C" ,015 ,0})
AADD(aStruC04,{"ORGEXP"    	,"C" ,006 ,0})
AADD(aStruC04,{"UFEXP"    	,"C" ,002 ,0})
AADD(aStruC04,{"CPFMOT"    	,"N" ,011 ,0})
AADD(aStruC04,{"NOMMOT"    	,"C" ,035 ,0})
AADD(aStruC04,{"NUMMAN"  	,"N" ,014 ,0})
cArq := CriaTrab(aStruC04)
dbUseArea(.T.,__LocalDriver,cArq,"RT2")
IndRegua("RT2",cArq,"Str(NUMMAN,14)")
AADD(aTrbs,{cArq,"RT2"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo C05 - IdentIficação do Veiculo Transportador                 								      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStruC05	:= {}
cArq	    := ""
AADD(aStruC05,{"LINHA"     	,"N" ,009 ,0})
AADD(aStruC05,{"TPOREG"   	,"C" ,003 ,0})
AADD(aStruC05,{"TPOVEI"  	,"C" ,001 ,0})
AADD(aStruC05,{"RENAVAM"   	,"C" ,009 ,0})
AADD(aStruC05,{"PLACAVEI"  	,"C" ,007 ,0})
AADD(aStruC05,{"PESOTARA"  	,"N" ,009 ,3})
AADD(aStruC05,{"CAPPESO"   	,"N" ,009 ,3})
AADD(aStruC05,{"CAPVOL"    	,"N" ,009 ,3})
AADD(aStruC05,{"NUMTRANS" 	,"C" ,020 ,0})
AADD(aStruC05,{"NUMMAN"  	,"N" ,014 ,0})
cArq := CriaTrab(aStruC05)
dbUseArea(.T.,__LocalDriver,cArq,"RT3")
IndRegua("RT3",cArq,"Str(NUMMAN,14)")
AADD(aTrbs,{cArq,"RT3"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo C07 - Fechamento de Veiculo                        								              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aStruC07	:= {}
cArq    	:= ""
AADD(aStruC07,{"LINHA"     	,"N" ,009 ,0})
AADD(aStruC07,{"TPOREG"   	,"C" ,003 ,0})
AADD(aStruC07,{"NUMMAN"  	,"N" ,014 ,0})
cArq := CriaTrab(aStruC07)
dbUseArea(.T.,__LocalDriver,cArq,"RT5")
IndRegua("RT5",cArq,"Str(NUMMAN,14)")
AADD(aTrbs,{cArq,"RT5"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo C08 - Definicao da Rota                        								              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aStruC08	:= {}
cArq    	:= ""
AADD(aStruC08,{"LINHA"     	,"N" ,009 ,0})
AADD(aStruC08,{"TPOREG"   	,"C" ,003 ,0})
AADD(aStruC08,{"SEQITI"   	,"N" ,002 ,0})
AADD(aStruC08,{"TPOPAS"   	,"C" ,001 ,0})
AADD(aStruC08,{"UFROTA"   	,"C" ,002 ,0})
AADD(aStruC08,{"NUMMAN"  	,"N" ,014 ,0})
cArq := CriaTrab(aStruC08)
dbUseArea(.T.,__LocalDriver,cArq,"RT6")
IndRegua("RT6",cArq,"Str(NUMMAN,14)")
AADD(aTrbs,{cArq,"RT6"})


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo C09 - Fechamento de Motorista                        								              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aStruC09	:= {}
cArq    	:= ""
AADD(aStruC09,{"LINHA"     	,"N" ,009 ,0})
AADD(aStruC09,{"TPOREG"   	,"C" ,003 ,0})
AADD(aStruC09,{"NUMMAN"  	,"N" ,014 ,0})
cArq := CriaTrab(aStruC09)
dbUseArea(.T.,__LocalDriver,cArq,"RT7")
IndRegua("RT7",cArq,"Str(NUMMAN,14)")
AADD(aTrbs,{cArq,"RT7"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo C10 - Conhecimento de Transporte                 								                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aStruC10	:= {}
cArq    	:= ""
AADD(aStruC10,{"LINHA"     	,"N" ,009 ,0})
AADD(aStruC10,{"TPOREG"   	,"C" ,003 ,0})
AADD(aStruC10,{"MODDOC"		,"N" ,002 ,0})
AADD(aStruC10,{"SERIEDOC"  	,"C" ,003 ,0})
AADD(aStruC10,{"SUBSERIE"  	,"C" ,003 ,0})
AADD(aStruC10,{"NUMDOC"    	,"N" ,010 ,0})
AADD(aStruC10,{"CFOP"  	    ,"N" ,004 ,0})
AADD(aStruC10,{"DTEMI" 	    ,"C" ,008 ,0})
AADD(aStruC10,{"TPOFRETE"	,"N" ,001 ,0})
AADD(aStruC10,{"VALDOC"		,"N" ,013 ,2})
AADD(aStruC10,{"VALISEN"	,"N" ,013 ,2})
AADD(aStruC10,{"BASEICM"	,"N" ,013 ,2})
AADD(aStruC10,{"VALICMS"  	,"N" ,013 ,2})
AADD(aStruC10,{"VALOUTRA" 	,"N" ,013 ,2})
AADD(aStruC10,{"VALMER" 	,"N" ,013 ,2})
AADD(aStruC10,{"DTSAIDA" 	,"C" ,008 ,0})
AADD(aStruC10,{"CGCPART" 	,"N" ,014 ,0})
AADD(aStruC10,{"INSCPART" 	,"C" ,014 ,0})
AADD(aStruC10,{"UFPART"   	,"C" ,002 ,0})
AADD(aStruC10,{"CGCRDES"	,"N" ,014 ,0})
AADD(aStruC10,{"INSCRDES"	,"C" ,014 ,0})
AADD(aStruC10,{"UFRDES"		,"C" ,002 ,0})
AADD(aStruC10,{"NUMMAN"		,"N" ,014 ,0})
cArq := CriaTrab(aStruC10)
dbUseArea(.T.,__LocalDriver,cArq,"RT8")
IndRegua("RT8",cArq,"Str(NUMMAN,14)")
AADD(aTrbs,{cArq,"RT8"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo C12 - Nota Fiscal                        								                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aStruC12	:= {}
cArq    	:= ""
AADD(aStruC12,{"LINHA"     	,"N" ,009 ,0})
AADD(aStruC12,{"TPOREG"   	,"C" ,003 ,0})
AADD(aStruC12,{"CGCREM" 	,"N" ,014 ,0})
AADD(aStruC12,{"CPFREM"		,"N" ,011 ,0})
AADD(aStruC12,{"INSCREM"   	,"C" ,014 ,0})
AADD(aStruC12,{"UFREM"   	,"C" ,002 ,0})
AADD(aStruC12,{"INSCSUB"   	,"C" ,014 ,0})
AADD(aStruC12,{"RAZAOREM" 	,"C" ,040 ,0})
AADD(aStruC12,{"CGCDES"  	,"N" ,014 ,0})
AADD(aStruC12,{"CPFDES"    	,"N" ,011 ,0})
AADD(aStruC12,{"INSCDES"  	,"C" ,014 ,0})
AADD(aStruC12,{"UFDES"  	,"C" ,002 ,0})
AADD(aStruC12,{"RAZAODES" 	,"C" ,040 ,0})
AADD(aStruC12,{"PAISDES"  	,"N" ,004 ,0})
AADD(aStruC12,{"DTEMINF"	,"C" ,008 ,0})
AADD(aStruC12,{"MODDOC"		,"N" ,002 ,0})
AADD(aStruC12,{"SERIEDOC"	,"C" ,TamSx3("DTC_SERNFC")[1] ,0})
AADD(aStruC12,{"NUMNF"		,"N" ,010 ,0})
AADD(aStruC12,{"CFOPNF"		,"N" ,004 ,0})
AADD(aStruC12,{"VALNF"		,"N" ,013 ,2})
AADD(aStruC12,{"BASEICMS"	,"N" ,013 ,2})
AADD(aStruC12,{"VALICMS"	,"N" ,013 ,2})
AADD(aStruC12,{"VALISEN"	,"N" ,013 ,2})
AADD(aStruC12,{"VALOUTRA"	,"N" ,013 ,2})
AADD(aStruC12,{"VALDESC"	,"N" ,013 ,2})
AADD(aStruC12,{"BASESUB"	,"N" ,013 ,2})
AADD(aStruC12,{"ICMSSUB"	,"N" ,013 ,2})
AADD(aStruC12,{"VALDESP"	,"N" ,013 ,2})
AADD(aStruC12,{"PESONF"		,"N" ,009 ,3})
AADD(aStruC12,{"TPOICENT"	,"N" ,001 ,0})
AADD(aStruC12,{"INSCSUF"	,"N" ,014 ,0})
AADD(aStruC12,{"OPDEBSUF"	,"N" ,001 ,0})
AADD(aStruC12,{"QTDLACRE"	,"N" ,004 ,0})
AADD(aStruC12,{"NUMMAN"		,"N" ,014 ,0})
AADD(aStruC12,{"NUMDOC"		,"N" ,010 ,0})
AADD(aStruC12,{"SDOCC"	,"C" ,003 ,0})
cArq := CriaTrab(aStruC12)
dbUseArea(.T.,__LocalDriver,cArq,"RT9")
IndRegua("RT9",cArq,"Str(NUMMAN,14)+ Str(NUMDOC,10) + Str(NUMNF,10) + SERIEDOC")
AADD(aTrbs,{cArq,"RT9"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo C16 -  Fechamento Nota Fiscal                        								              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStruC16	:= {}
cArq     	:= ""
AADD(aStruC16,{"LINHA"     	,"N" ,009 ,0})
AADD(aStruC16,{"TPOREG"   	,"C" ,003 ,0})
AADD(aStruC16,{"NUMMAN"  	,"N" ,014 ,0})
AADD(aStruC16,{"NUMDOC"		,"N" ,010 ,0})
AADD(aStruC16,{"SERIEDOC"	,"C" ,TamSx3("DTC_SERNFC")[1],0})
AADD(aStruC16,{"NUMNF"		,"N" ,010 ,0})
cArq := CriaTrab(aStruC16)
dbUseArea(.T.,__LocalDriver,cArq,"RT10")
IndRegua("RT10",cArq,"Str(NUMMAN,14)+ Str(NUMDOC,10)+ Str(NUMNF,10) + SERIEDOC")
AADD(aTrbs,{cArq,"RT10"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo C18 - Fechamento do Conhecimento Transporte                        							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStruC18	:= {}
cArq     	:= ""
AADD(aStruC18,{"LINHA"     	,"N" ,009 ,0})
AADD(aStruC18,{"TPOREG"   	,"C" ,003 ,0})
AADD(aStruC18,{"NUMMAN"  	,"N" ,014 ,0})
AADD(aStruC18,{"NUMDOC"		,"N" ,010 ,0})
cArq := CriaTrab(aStruC18)
dbUseArea(.T.,__LocalDriver,cArq,"RT11")
IndRegua("RT11",cArq,"Str(NUMMAN,14)+ Str(NUMDOC,10)")
AADD(aTrbs,{cArq,"RT11"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo C19 - Fechamento do ManIfesto de Carga                             							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStruC19	:= {}
cArq     	:= ""
AADD(aStruC19,{"LINHA"     	,"N" ,009 ,0})
AADD(aStruC19,{"TPOREG"   	,"C" ,003 ,0})
AADD(aStruC19,{"NUMMAN"  	,"N" ,014 ,0})
cArq := CriaTrab(aStruC19)
dbUseArea(.T.,__LocalDriver,cArq,"RT12")
IndRegua("RT12",cArq,"Str(NUMMAN,14)")
AADD(aTrbs,{cArq,"RT12"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo C99 - Encerramento do Arquivo                                  							      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStruC99	:= {}
cArq     	:= ""
AADD(aStruC99,{"LINHA"     	,"N" ,009 ,0})
AADD(aStruC99,{"TPOREG"   	,"C" ,003 ,0})
AADD(aStruC99,{"NUMMAN"  	,"N" ,014 ,0})
cArq := CriaTrab(aStruC99)
dbUseArea(.T.,__LocalDriver,cArq,"RT13")
IndRegua("RT13",cArq,"Str(NUMMAN,14)")
AADD(aTrbs,{cArq,"RT13"})

//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arquivo TXT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
aStru5	:=	{}
AADD(aStru5,{"NUMMAN","N",014,0})
AADD(aStru5,{"CAMPO","C",365,0})
cArq :=	CriaTrab(aStru5)
dbUseArea(.T.,__LocalDriver,cArq,"Arq")
IndRegua("Arq",cArq,"Str(NUMMAN,14)")
AADD(aTrbs,{cArq,"Arq"})

Return( aTrbs )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EDICEDel    ºAutor  ³Cleber S. A. Santos º Data ³ 28.09.2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³EDICEDel                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function EDICEDel(aDelArqs)
Local aAreaDel := GetArea()
Local nI := 0

For nI:= 1 To Len(aDelArqs)
	If File(aDelArqs[nI,1]+GetDBExtension())
		dbSelectArea(aDelArqs[ni,2])
		dbCloseArea()
		Ferase(aDelArqs[nI,1]+GetDBExtension())
		Ferase(aDelArqs[nI,1]+OrdBagExt())
	EndIf
Next

RestArea(aAreaDel)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunction³GeraEDICE     ºAutor  ³Sueli               º Data ³  23.06.06   º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³Gera Arquivo texto                                              º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso     ³                                                                º±±
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GeraEDICE()

dbSelectArea("RT1")
RT1->(dbGoTop())
While RT1->(!eof())
	
	If RT1->(dbSeek(Str(RT1->NUMMAN,14)))
		If !Arq->(dbSeek(Str(RT1->NUMMAN,14)))
			RecLocK("Arq",.T.)
			ARQ->NUMMAN :=RT1->NUMMAN
			ARQ->CAMPO  :=StrZero(RT1->LINHA,9)+RT1->TPOREG+StrZero(RT1->NUMMAN,14)+RT1->INSCDES;
			+RT1->UFDES+StrZero(RT1->LACRES,5)+StrZero(RT1->NOTAS,5)+NUM2CHR(RT1->VLRMERC,13,2);
			+NUM2CHR(RT1->PESO,9,3)+RT1->CODPS
			
			If RT2->(dbseek(Str(RT1->NUMMAN,14)))
				RecLocK("Arq",.T.)
				ARQ->NUMMAN := RT1->NUMMAN
				ARQ->CAMPO  :=StrZero(RT2->LINHA,9)+RT2->TPOREG+StrZero(RT2->CNHMOT,11)+RT2->RGMOT;
				+RT2->ORGEXP+RT2->UFEXP+StrZero(RT2->CPFMOT,11)+RT2->NOMMOT
			EndIf
			
			If RT3->(dbseek(Str(RT1->NUMMAN,14)))
				RecLocK("Arq",.T.)
				ARQ->NUMMAN := RT1->NUMMAN
				ARQ->CAMPO  :=StrZero(RT3->LINHA,9)+RT3->TPOREG+RT3->TPOVEI+RT3->RENAVAM+RT3->PLACAVEI;
				+ NUM2CHR(RT3->PESOTARA,9,3)+NUM2CHR(RT3->CAPPESO,9,3)+NUM2CHR(RT3->CAPVOL,9,3)+RT3->NUMTRANS
			EndIf
			
			If RT5->(dbseek(Str(RT1->NUMMAN,14)))
				RecLocK("Arq",.T.)
				ARQ->NUMMAN := RT1->NUMMAN
				Arq->CAMPO  := StrZero(RT5->LINHA,9)+RT5->TPOREG
			EndIf
			
			If RT6->(dbseek(Str(RT1->NUMMAN,14)))
				Do While !RT6->(Eof ()) .and. RT1->NUMMAN == RT6->NUMMAN
					RecLocK("Arq",.T.)
					ARQ->NUMMAN := RT1->NUMMAN
					Arq->CAMPO  := StrZero(RT6->LINHA,9)+RT6->TPOREG+StrZero(RT6->SEQITI,2)+RT6->TPOPAS+RT6->UFROTA
					RT6->(dbSkip())
				Enddo
			EndIf
			
			If RT7->(dbseek(Str(RT1->NUMMAN,14)))
				RecLocK("Arq",.T.)
				ARQ->NUMMAN := RT1->NUMMAN
				Arq->CAMPO  := StrZero(RT7->LINHA,9)+RT7->TPOREG
			EndIf
			
			If RT8->(dbseek(Str(RT1->NUMMAN,14)))
				Do While !RT8->(Eof ()) .and. RT1->NUMMAN == RT8->NUMMAN
					RecLocK("Arq",.T.)
					ARQ->NUMMAN := RT1->NUMMAN
					Arq->CAMPO  := StrZero(RT8->LINHA,9)+RT8->TPOREG+StrZero(RT8->MODDOC,2)+RT8->SERIEDOC+RT8->SUBSERIE;
					+StrZero(RT8->NUMDOC,10)+StrZero(RT8->CFOP,04)+RT8->DTEMI+AllTrim(Str(RT8->TPOFRETE))+NUM2CHR(RT8->VALDOC,13,2);
					+NUM2CHR(RT8->VALISEN,13,2)+NUM2CHR(RT8->BASEICM,13,2)+NUM2CHR(RT8->VALICMS,13,2)+NUM2CHR(RT8->VALOUTRA,13,2);
					+NUM2CHR(RT8->VALMER,13,2)+RT8->DTSAIDA+StrZero(RT8->CGCPART,14)+RT8->INSCPART+RT8->UFPART;
					+StrZero(RT8->CGCRDES,14)+ RT8->INSCRDES + RT8->UFRDES
					
					
					If RT9->(dbseek(Str(RT1->NUMMAN,14)+Str(RT8->NUMDOC,10)))
						Do While !RT9->(Eof ()) .and. (RT1->NUMMAN == RT9->NUMMAN) .and. (RT8->NUMDOC == RT9->NUMDOC)
							RecLocK("Arq",.T.)
							ARQ->NUMMAN := RT1->NUMMAN
							Arq->CAMPO  := StrZero(RT9->LINHA,9)+RT9->TPOREG+StrZero(RT9->CGCREM,14)+StrZero(RT9->CPFREM,11);
							+RT9->INSCREM+RT9->UFREM+RT9->INSCSUB+RT9->RAZAOREM+StrZero(RT9->CGCDES,14)+StrZero(RT9->CPFDES,11);
							+RT9->INSCDES+RT9->UFDES+RT9->RAZAODES+StrZero(RT9->PAISDES,4)+RT9->DTEMINF+StrZero(RT9->MODDOC,2);
							+RT9->SDOCC+StrZero(RT9->NUMNF,10)+ StrZero(RT9->CFOPNF,4)+NUM2CHR(RT9->VALNF,13,2)+NUM2CHR(RT9->BASEICMS,13,2);
							+NUM2CHR(RT9->VALICMS,13,2)+NUM2CHR(RT9->VALISEN,13,2)+NUM2CHR(RT9->VALOUTRA,13,2)+NUM2CHR(RT9->VALDESC,13,2);
							+NUM2CHR(RT9->BASESUB,13,2)+NUM2CHR(RT9->ICMSSUB,13,2)+NUM2CHR(RT9->VALDESP,13,2)+NUM2CHR(RT9->PESONF,9,3);
							+AllTrim(Str(RT9->TPOICENT))+StrZero(RT9->INSCSUF,14)+AllTrim(Str(RT9->OPDEBSUF))+StrZero(RT9->QTDLACRE,4)
							
							If RT10->(dbseek(Str(RT1->NUMMAN,14)+Str(RT8->NUMDOC,10)+Str(RT9->NUMNF,10)+RT9->SERIEDOC))
								RecLocK("Arq",.T.)
								ARQ->NUMMAN := RT1->NUMMAN
								Arq->CAMPO  := StrZero(RT10->LINHA,9)+RT10->TPOREG
							EndIf
							
							RT9->(dbSkip())
						Enddo
					EndIf

					If RT11->(dbseek(Str(RT1->NUMMAN,14)+Str(RT8->NUMDOC,10)))
						RecLocK("Arq",.T.)
						ARQ->NUMMAN := RT1->NUMMAN
						Arq->CAMPO  := StrZero(RT11->LINHA,9)+RT11->TPOREG
					EndIf
					
					RT8->(dbSkip())
				Enddo
			EndIf

			If RT12->(dbseek(Str(RT1->NUMMAN,14)))
				RecLocK("Arq",.T.)
				ARQ->NUMMAN := RT1->NUMMAN
				Arq->CAMPO  := StrZero(RT12->LINHA,9)+RT12->TPOREG
			EndIf
			
			If RT13->(dbseek(Str(RT1->NUMMAN,14)))
				RecLocK("Arq",.T.)
				ARQ->NUMMAN := RT13->NUMMAN
				Arq->CAMPO  := StrZero(RT13->LINHA,9)+RT13->TPOREG
			EndIf
			
		EndIf
	EndIf
	MsUnlock()
	RT1->(dbSkip())
EndDo

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CALCNOTAS ³ Autor ³Cleber Stenio A. Stos  ³ Data ³09/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o total de Notas Fiscais do Cliente do ManIfesto.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Total de registros                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CalcNotas(cCond1,cCond2,cCond3,cCond4)
Local aDtc    := {"DTC",""}
Local aDud    := {"DUD",""}
Local nRes    := 0
Local nContNF := 0
Local cNumNF  := ""

DbSelectArea ("DUD")
DUD->(dbSetOrder(5))
FsQuery(aDud,1,"DUD_FILIAL='"+ xFilial("DUD") +"' AND DUD_FILORI='"+ cCond1+"' AND DUD_VIAGEM='"+ cCond2+"' AND DUD_FILMAN='"+ cCond3+"' AND DUD_MANIFE='"+ cCond4+"'","DUD_FILIAL=='"+xFilial("DUD")+"' .AND. DUD_FILORI=='"+ cCond1+"' .AND. DUD_VIAGEM=='"+ cCond2+"' .AND. DUD_FILMAN=='"+ cCond3+"' .AND. DUD_MANIFE=='"+ cCond4+"'",DUD->(IndexKey()))
DUD->(dbGotop())

Do While !DUD->(Eof ())
	
	DbSelectArea ("DT6")
	DT6->(DbSetOrder (1))
	DT6->(dbSeek(xFilial("DT6")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))
	
	DbSelectArea ("DTC")
	DTC->(dbSetOrder(7))
	FsQuery(aDtc,1,"DTC_FILIAL='"+ xFilial("DTC") +"' AND DTC_FILDOC='"+ DT6->DT6_FILDOC +"' AND DTC_DOC='"+ DT6->DT6_DOC +"' AND DTC_SERIE='"+ DT6->DT6_SERIE+"'","DTC_FILIAL=='"+xFilial("DTC")+"' .AND. DTC_FILDOC=='"+ DT6->DT6_FILDOC +"' .AND. DTC_DOC=='"+ DT6->DT6_DOC+"' .AND. DTC_SERIE=='"+ DT6->DT6_SERIE+"'",DTC->(IndexKey()))
	DTC->(dbGotop())
		
	Do While !DTC->(Eof ())
		nContNF++
		cNumNF :=  (DTC->DTC_NUMNFC + DTC->DTC_SERNFC)
		
		DTC->(dbSkip())
		
		//Pular o registro repetido
		Do while cNumNF  ==  (DTC->DTC_NUMNFC + DTC->DTC_SERNFC)
			DTC->(dbSkip())
		EndDo
		
	Enddo
	FsQuery (aDtc,2,)
	
	DUD->(dbSkip())
Enddo

FsQuery (aDud,2,)

nRes:= nContNF

dbCloseArea()

Return( nRes )