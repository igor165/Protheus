#Include "OFIOR530.ch"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOR530 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Vendas por Vendedor com Prazo Medio                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR530()

Local cDesc1	 := ""
Local cDesc2	 := ""
Local cDesc3	 := ""
Local cAlias	 := "SF2"
Private nLin 	 := 1
Private aReturn := {STR0002,1,STR0003,2,2,1,"",1}
Private cTamanho:= "G"           // P/M/G
Private Limite  := 220           // 80/132/220
Private aOrdem  := {}           // Ordem do Relatorio
Private cTitulo := STR0001
Private cNomProg:= "OFIOR530"
Private cNomeRel:= "OFIOR530"
Private nLastKey:= 0
Private cPerg   := "OFR530"
Private nPis    := ( GetMv("MV_TXPIS")   / 100 )
Private nCof    := ( GetMv("MV_TXCOFIN") / 100 )
Private nContpis:= 0
Private nContcof:= 0
Private nContjur:= 0
Private nContbru:= 0
Private nContvar:= 0
Private nContcom:= 0
Private nContliq:= 0
Private nContfix:= 0
Private nContfin:= 0
Private cNF := "INICIAL"
Private aNF := {}
Private nTotSrv := 0

cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf
PERGUNTE(cPerg,.f.)
SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| Imp_OFR530(@lEnd,cNomeRel,cAlias) } , cTitulo )
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Imp_OFR530³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao Vendas por Vendedor com Prazo Medio              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Imp_OFR530(lEnd,wNRel,cAlias)
Local nLin := 1 , nPos := 0 , ni := 0 , nj := 0
Local cCodCli := ""
Local cLojCli := ""
Private cPula := "NAO" , cOutVdas := "SIM" , cGrupo := "" , cConfere := "" , nTipo := 0
Private cImpOfi := "  " , cMudou := "INICIAL" , cMudou2:= "INICIAL" , cTipo := "INICIAL"
Private cContinua := "" , nk := 1 , na := 1 , nl := 0 , cTemDev := "" , cImpDev := ""
Private nVtotven := 0 , nVimpven := 0 , nVicmven := 0 , nVissven := 0 , nVdesven := 0
Private nVpisven := 0 , nVcofven := 0 , nVcusven := 0 , nVlucbru := 0 , nVprzmd1 := 0
Private nVprzmd2 := 0 , nVjurest := 0 , nVtotdes := 0 , nVcomven := 0 , nVlucliq := 0
Private nVdesfix := 0 , nVresult := 0
Private aTotVen  := {} //vetor Totais
Private aGrpVen  := {} //vetor Nome dos Vendedores
Private aNumVen  := {} //vetor de Vendedores
Private aPrzMed  := {} //vetor Prazo Medio
Private aCDCI    := {} //vetor CDCI por Vendedor
Private cabec1 , cabec2 , nomeprog , tamanho , nCaracter
Private cbTxt   := Space(10)
Private cbCont  := 0
Private cString := "SF2"
Private Li      := 220
Private m_Pag   := 1
Private lAbortPrint := .f.
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
cTitulo := STR0004 + "( " + Transform(MV_PAR01,"@D") + STR0005 + Transform(MV_PAR02,"@D") + " )"
cabec1 := STR0006
cabec2 := ""
nomeprog:="OFIOR530"
tamanho:="G"
nCaracter:=15

nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1

aAdd(aTotVen,{"TOT" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })//TOTAL
aAdd(aTotVen,{"VEI" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })//VEI
aAdd(aTotVen,{"BAL" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })//BAL
aAdd(aTotVen,{"OFI" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })//OFI
aAdd(aTotVen,{"OFP" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })//OFI-PEC
aAdd(aTotVen,{"OFS" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })//OFI-SRV
aAdd(aTotVen,{"OVD" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })//OUT.VENDAS
aAdd(aTotVen,{"DES" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })//DESP.ACESS
aAdd(aTotVen,{"DEV" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })//DEVOLUCOES

aAdd(aCDCI,{ "1" , STR0015 , 0 , 0 , 0 , 0 , 0 , "" })//CDCI

DbSelectArea("SD2")
DbSetOrder(5)
DbSeek( xFilial("SD2") + DTOS(MV_PAR01) , .t. )
DbSelectArea("SF2")
DbSetOrder(1)
DbSeek( xFilial("SF2") + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA )
SetRegua((RecCount()/15))
nCont := 0
While !Eof() .and. ( SF2->F2_FILIAL == xFilial("SF2") ) .and. ( SF2->F2_EMISSAO <= MV_PAR02 )
	nCont++
	If nCont == 15
		nCont := 0
		IncRegua()
	EndIf
	If ( SF2->F2_VEND1 < MV_PAR03 .or. SF2->F2_VEND1 > MV_PAR04 )
		DbSelectArea("SF2")
		Dbskip()
		Loop
	EndIf
	If !Empty(Alltrim(MV_PAR06+MV_PAR07)) .and.( SF2->F2_CLIENTE+SF2->F2_LOJA # MV_PAR06+MV_PAR07 )
		DbSelectArea("SF2")
		Dbskip()
		Loop
	EndIf
	
	cGrupo := ""
	nk := 1
	
	nVtotven := nVimpven := nVicmven := nVissven := 0
	nVpisven := nVcofven := nVcusven := nVlucbru := 0
	nVprzmd1 := nVprzmd2 := nVjurest := nVtotdes := 0
	nVcomven := nVlucliq := nVdesfix := nVresult := 0
	
	If SF2->F2_TIPO # "D"
		
		cOutVdas := "SIM"
		
		Do Case
			Case SF2->F2_PREFORI == GetNewPar("MV_PREFVEI","VEI")		//  V E I C U L O S
				cTipo := "1VEI"
				nTipo := 2
				DbSelectArea( "VV0" )
				DbSetOrder(4)
				If DbSeek( xFilial("VV0") + SF2->F2_DOC + SF2->F2_SERIE )
					DbSelectArea( "VVA" )
					DbSetOrder(1)
					DbSeek( xFilial("VVA") + VV0->VV0_NUMTRA )
					DbSelectArea( "SF4" )
					DbSetOrder(1)
					DbSeek( xFilial("SF4") + VVA->VVA_CODTES )
					If SF4->F4_DUPLIC == "N" .or. Alltrim(SF4->F4_ATUATF) == "S"
						DbSelectArea("SF2")
						Dbskip()
						loop
					EndIf
					cCodCli := VV0->VV0_CODCLI
					cLojCli := VV0->VV0_LOJA
					// LEASING -> Cliente Banco //
					If VV0->VV0_CATVEN == "7" .and. !Empty(VV0->VV0_CLIALI+VV0->VV0_LOJALI)
						cCodCli := VV0->VV0_CLIALI
						cLojCli := VV0->VV0_LOJALI
					EndIf
					DbSelectArea( "SD2" )
					DbSetOrder(3)
					DbSeek( xFilial("SD2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI + cCodCli + cLojCli + VVA->VVA_CHAINT , .t. )
					nVtotven += SD2->D2_TOTAL
					nVicmven += SD2->D2_VALICM
					nVissven += 0
					nVpisven += VVA->VVA_PISVEN
					nVcofven += VVA->VVA_COFVEN
					nVimpven += VVA->VVA_TOTIMP
					nVlucbru += (SD2->D2_TOTAL-(SD2->D2_CUSTO1+VVA->VVA_TOTIMP))
					nVcusven += SD2->D2_CUSTO1
					nVjurest += VVA->VVA_JUREST
					nVtotdes += VVA->VVA_TOTDES
					nVcomven += (VVA->VVA_COMVDE+VVA->VVA_COMGER)
					nVlucliq += VVA->VVA_LUCLQ1
					nVdesfix += VVA->VVA_DESFIX
					nVresult += VVA->VVA_LUCLQ2
					If MV_PAR05 >= 3
						nk := ( SD2->D2_TOTAL / SF2->F2_VALBRUT )
						cGrupo := "VEI "
					EndIf
					Grv_OFR530()
				EndIf
				
			Case SF2->F2_PREFORI == GetNewPar("MV_PREFBAL","BAL")		//  B A L C A O
				If SF2->F2_VALISS > 0 // OUTRAS VENDAS
					cTipo := "4OVD"
					nTipo := 7
					nVissven := SF2->F2_VALISS
				Else	//  B A L C A O
					cTipo := "2BAL"
					nTipo := 3
				EndIf
				
				cConfere := ""
				DbSelectArea( "VEC" )
				DbSetOrder(4)
				
				If DbSeek( xFilial("VEC") + SF2->F2_DOC + SF2->F2_SERIE )
					While !Eof() .and. ( VEC->VEC_FILIAL == xFilial("VEC") ) .and. ( ( VEC->VEC_NUMNFI + VEC->VEC_SERNFI ) == ( SF2->F2_DOC + SF2->F2_SERIE ) )
						cConfere := VEC->VEC_NUMNFI + VEC->VEC_SERNFI + VEC->VEC_GRUITE + VEC->VEC_CODITE
						DbSelectArea("VEC")
						Dbskip()
						If ( cConfere == ( VEC->VEC_NUMNFI + VEC->VEC_SERNFI + VEC->VEC_GRUITE + VEC->VEC_CODITE ) )
							DbSelectArea("VEC")
							Loop
						EndIf
						DbSelectArea("VEC")
						Dbskip(-1)
						DbSelectArea( "VOI" )
						DbSetOrder(1)
						DbSeek( xFilial("VOI") + VEC->VEC_TIPTEM , .f. )
						If VOI->VOI_SITTPO == "3"
							DbSelectArea("VEC")
							Dbskip()
							Loop
						EndIf
						DbSelectArea( "VS1" )
						DbSetOrder(3)
						If !DbSeek( xFilial("VS1") + VEC->VEC_NUMNFI + VEC->VEC_SERNFI )
							DbSelectArea("VEC")
							Dbskip()
							Loop
						EndIf
						If ( Alltrim(VS1->VS1_NOROUT) == "2" .and. Alltrim(VEC->VEC_GRUITE) == "SRVC" ) // OUTRAS VENDAS
							cTipo := "4OVD"
							nTipo := 7
						Else	//  B A L C A O
							cTipo := "2BAL"
							nTipo := 3
						EndIf
						DbSelectArea( "SD2" )
						DbSetOrder(3)
						If !DbSeek( xFilial("SD2") + VEC->VEC_NUMNFI + VEC->VEC_SERNFI + SF2->F2_CLIENTE + SF2->F2_LOJA + VEC->VEC_PECINT , .f. )
							DbSelectArea("VEC")
							Dbskip()
							Loop
						EndIf
						DbSelectArea( "SF4" )
						DbSetOrder(1)
						DbSeek( xFilial("SF4") + SD2->D2_TES )
						If SF4->F4_DUPLIC == "N"
							DbSelectArea("VEC")
							Dbskip()
							Loop
						EndIf
						If SF4->F4_ESTOQUE == "N" // OUTRAS VENDAS
							cTipo := "4OVD"
							nTipo := 7
							nVissven := SF2->F2_VALISS
						Else	//  B A L C A O
							cTipo := "2BAL"
							nTipo := 3
						EndIf
						nVtotven += SD2->D2_TOTAL
						nVicmven += SD2->D2_VALICM
						nVdesven += SD2->D2_DESPESA
						nVissven += 0
						nVpisven += VEC->VEC_VALPIS
						nVcofven += VEC->VEC_VALCOF
						nVimpven := ( nVpisven + nVcofven + nVicmven )
						nVlucbru += VEC->VEC_LUCBRU
						nVcusven += SD2->D2_CUSTO1
						nVjurest += VEC->VEC_JUREST
						nVtotdes += VEC->VEC_DESVAR
						nVcomven += (VEC->VEC_COMVEN+VEC->VEC_COMGER)
						nVlucliq += VEC->VEC_LUCLIQ
						nVdesfix += (VEC->VEC_DESFIX+VEC->VEC_CUSFIX)
						nVresult += VEC->VEC_RESFIN
						If MV_PAR05 >= 3 .and. nVtotven # 0
							nk := ( SD2->D2_TOTAL / SF2->F2_VALBRUT )
							cGrupo := VEC->VEC_GRUITE
							Grv_OFR530()
						EndIf
						DbSelectArea("VEC")
						Dbskip()
					EndDo
					If nVtotven # 0 .and. MV_PAR05 < 3
						Grv_OFR530()
					EndIf
				EndIf
				
			Case SF2->F2_PREFORI == GetNewPar("MV_PREFOFI","OFI")		//  O F I C I N A
				cConfere := ""
				cTipo    := "3OFP"
				nTipo    := 4
				nContven := 0
				nConticm := 0
				nContcus := 0
				nContpis := 0
				nContcof := 0
				nContjur := 0
				nContbru := 0
				nContvar := 0
				nContcom := 0
				nContliq := 0
				nContfix := 0
				nContfin := 0
				DbSelectArea( "VEC" )
				DbSetOrder(4)
				If DbSeek( xFilial("VEC") + SF2->F2_DOC + SF2->F2_SERIE )
					While !Eof() .and. ( VEC->VEC_FILIAL == xFilial("VEC") ) .and. ( ( VEC->VEC_NUMNFI + VEC->VEC_SERNFI ) == ( SF2->F2_DOC + SF2->F2_SERIE ) )
						nContpis += VEC->VEC_VALPIS
						nContcof += VEC->VEC_VALCOF
						nContjur += VEC->VEC_JUREST
						nContbru += VEC->VEC_LUCBRU
						nContvar += VEC->VEC_DESVAR
						nContcom += (VEC->VEC_COMVEN+VEC->VEC_COMGER)
						nContliq += VEC->VEC_LUCLIQ
						nContfix += (VEC->VEC_DESFIX+VEC->VEC_CUSFIX)
						nContfin += VEC->VEC_RESFIN
						cConfere := VEC->VEC_NUMNFI + VEC->VEC_SERNFI + VEC->VEC_GRUITE + VEC->VEC_CODITE
						DbSelectArea("VEC")
						Dbskip()
						If ( cConfere == ( VEC->VEC_NUMNFI + VEC->VEC_SERNFI + VEC->VEC_GRUITE + VEC->VEC_CODITE ) )
							DbSelectArea("VEC")
							Loop
						EndIf
						DbSelectArea("VEC")
						Dbskip(-1)
						DbSelectArea( "VOI" )
						DbSetOrder(1)
						DbSeek( xFilial("VOI") + VEC->VEC_TIPTEM , .f. )
						If VOI->VOI_SITTPO == "3"
							DbSelectArea("VEC")
							Dbskip()
							Loop
						EndIf
						DbSelectArea( "VOO" )
						DbSetOrder(4)
						If !DbSeek( xFilial("VOO") + VEC->VEC_NUMNFI + VEC->VEC_SERNFI , .f. )
							DbSelectArea("VEC")
							Dbskip()
							Loop
						EndIf
						DbSelectArea( "SD2" )
						DbSetOrder(3)
						If !DbSeek( xFilial("SD2") + VEC->VEC_NUMNFI + VEC->VEC_SERNFI + VOO->VOO_FATPAR + VOO->VOO_LOJA + VEC->VEC_PECINT , .f. )
							DbSelectArea("VEC")
							Dbskip()
							Loop
						EndIf
						DbSelectArea( "SF4" )
						DbSetOrder(1)
						DbSeek( xFilial("SF4") + SD2->D2_TES )
						If SF4->F4_DUPLIC == "N"
							DbSelectArea("VEC")
							Dbskip()
							Loop
						EndIf
						nContven += SD2->D2_TOTAL
						nConticm += SD2->D2_VALICM
						nContcus += SD2->D2_CUSTO1
						If MV_PAR05 >= 3 .and. nContven # 0
							na := ( (SF2->F2_VALBRUT-SF2->F2_BASEISS) / SF2->F2_VALBRUT )
							nk := ( SD2->D2_TOTAL / ( SF2->F2_VALBRUT - SF2->F2_BASEISS ) )
							cGrupo := VEC->VEC_GRUITE
							nVtotven := nContven
							nVicmven := nConticm
							nVissven := 0
							nVpisven := nContpis
							nVcofven := nContcof
							nVimpven := ( nVpisven + nVcofven + nVicmven )
							nVlucbru := nContbru
							nVcusven := nContcus
							nVjurest := nContjur
							nVtotdes := nContvar
							nVcomven := nContcom
							nVlucliq := nContliq
							nVdesfix := nContfix
							nVresult := nContfin
							nContven := nConticm := nContcus := nContpis := nContcof := nContjur := 0
							nContbru := nContvar := nContcom := nContliq := nContfix := nContfin := 0
							Grv_OFR530()
						EndIf
						DbSelectArea("VEC")
						Dbskip()
					EndDo
					nVtotven += nContven
					nVicmven += nConticm
					nVissven += 0
					nVpisven += nContpis
					nVcofven += nContcof
					nVimpven := ( nVpisven + nVcofven + nVicmven )
					nVlucbru += nContbru
					nVcusven += nContcus
					nVjurest += nContjur
					nVtotdes += nContvar
					nVcomven += nContcom
					nVlucliq += nContliq
					nVdesfix += nContfix
					nVresult += nContfin
					If nVtotven # 0 .and. MV_PAR05 < 3
						Grv_OFR530()
					EndIf
				EndIf
				
				nVtotven := nVimpven := nVicmven := nVissven := 0
				nVpisven := nVcofven := nVcusven := nVlucbru := 0
				nVprzmd1 := nVprzmd2 := nVjurest := nVtotdes := 0
				nVcomven := nVlucliq := nVdesfix := nVresult := 0
				
				cTipo := "3OFS"
				nTipo := 4
				DbSelectArea( "VSC" )
				DbSetOrder(6)
				If DbSeek( xFilial("VSC") + SF2->F2_DOC + SF2->F2_SERIE )
					While !Eof() .and. ( VSC->VSC_FILIAL == xFilial("VSC") ) .and. ( ( VSC->VSC_NUMNFI + VSC->VSC_SERNFI ) == ( SF2->F2_DOC + SF2->F2_SERIE ) )
						nVtotven += VSC->VSC_VALSER
						nVicmven += 0
						nVissven += VSC->VSC_VALISS
						nVpisven += VSC->VSC_VALPIS
						nVcofven += VSC->VSC_VALCOF
						nVimpven += VSC->VSC_TOTIMP
						nVlucbru += VSC->VSC_LUCBRU
						nVcusven += VSC->VSC_CUSSER
						nVjurest += 0
						nVtotdes += VSC->VSC_DESVAR
						nVcomven += (VSC->VSC_COMVEN+VSC->VSC_COMGER)
						nVlucliq += VSC->VSC_LUCLIQ
						nVdesfix += (VSC->VSC_DESFIX+VSC->VSC_CUSFIX)
						nVresult += VSC->VSC_RESFIN
						If MV_PAR05 >= 3 .and. nVtotven # 0
							na := ( SF2->F2_BASEISS / SF2->F2_VALBRUT )
							nk := ( VSC->VSC_VALSER / SF2->F2_BASEISS )
							cGrupo := "SRVC "+ VSC->VSC_TIPSER
							Grv_OFR530()
						EndIf
						DbSelectArea("VSC")
						Dbskip()
					EndDo
					If nVtotven # 0 .and. MV_PAR05 < 3
						Grv_OFR530()
					EndIf
				EndIf
				
		EndCase
		
		
		// O U T R A S   V E N D A S
		
		If cOutVdas == "SIM"
			cTipo := "4OVD"
			nTipo := 7
			nVissven := SF2->F2_VALISS
			DbSelectArea( "VEC" )
			DbSetOrder(4)
			If DbSeek( xFilial("VEC") + SF2->F2_DOC + SF2->F2_SERIE )
				While !Eof() .and. ( VEC->VEC_FILIAL == xFilial("VEC") ) .and. ( ( VEC->VEC_NUMNFI + VEC->VEC_SERNFI ) == ( SF2->F2_DOC + SF2->F2_SERIE ) )
					DbSelectArea( "VOI" )
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VEC->VEC_TIPTEM , .f. )
					If VOI->VOI_SITTPO == "3"
						DbSelectArea("VEC")
						Dbskip()
						Loop
					EndIf
					DbSelectArea( "SD2" )
					DbSetOrder(3)
					If !DbSeek( xFilial("SD2") + VEC->VEC_NUMNFI + VEC->VEC_SERNFI + SF2->F2_CLIENTE + SF2->F2_LOJA + VEC->VEC_PECINT , .f. )
						DbSelectArea("VEC")
						Dbskip()
						Loop
					EndIf
					DbSelectArea( "SF4" )
					DbSetOrder(1)
					DbSeek( xFilial("SF4") + SD2->D2_TES )
					If SF4->F4_DUPLIC == "N"
						DbSelectArea("VEC")
						Dbskip()
						Loop
					EndIf
					nVtotven += SD2->D2_TOTAL
					nVicmven += SD2->D2_VALICM
					nVissven += 0
					nVpisven += VEC->VEC_VALPIS
					nVcofven += VEC->VEC_VALCOF
					nVimpven := ( nVpisven + nVcofven + nVicmven )
					nVlucbru += VEC->VEC_LUCBRU
					nVcusven += SD2->D2_CUSTO1
					nVjurest += VEC->VEC_JUREST
					nVtotdes += VEC->VEC_DESVAR
					nVcomven += (VEC->VEC_COMVEN+VEC->VEC_COMGER)
					nVlucliq += VEC->VEC_LUCLIQ
					nVdesfix += (VEC->VEC_DESFIX+VEC->VEC_CUSFIX)
					nVresult += VEC->VEC_RESFIN
					If MV_PAR05 >= 3 .and. nVtotven # 0
						nk := ( SD2->D2_TOTAL / SF2->F2_VALBRUT )
						cGrupo := VEC->VEC_GRUITE
						Grv_OFR530()
					EndIf
					DbSelectArea("VEC")
					Dbskip()
				EndDo
				If nVtotven # 0 .and. MV_PAR05 < 3
					Grv_OFR530()
				EndIf
			EndIf
		EndIf
		
		
		
		// D E S P E S A S   A C E S S O R I A S
		
		cTipo := "5DES"
		nTipo := 8
		nVtotven := SF2->F2_DESPESA
		nVicmven := 0
		nVissven := 0
		nVPisVen := ( SF2->F2_DESPESA * nPis )
		nVCofVen := ( SF2->F2_DESPESA * nCof )
		nVimpven := 0
		nVlucbru := 0
		nVcusven := 0
		nVjurest := 0
		nVtotdes := 0
		nVcomven := 0
		nVlucliq := 0
		nVdesfix := 0
		nVresult := 0
		If MV_PAR05 >= 3
			na := 1
			nk := 1
			cGrupo := "DESP"
		EndIf
		If nVtotven # 0
			Grv_OFR530()
		EndIf
		
	EndIf
	
	DbSelectArea("SF2")
	Dbskip()
EndDo

DbSelectArea( "SF1" )
DbSetOrder(1)
DbSeek( xFilial("SF1") )
While !Eof() .and. SF1->F1_FILIAL == xFilial("SF1")
	If (!Empty(MV_PAR01) .and. (SF1->F1_DTDIGIT < MV_PAR01)) .or. (!Empty(MV_PAR02) .and. (SF1->F1_DTDIGIT > MV_PAR02))
		DbSelectArea("SF1")
		Dbskip()
		loop
	EndIf
	If SF1->F1_TIPO == "D"
		IncRegua()
		If !Empty(Alltrim(MV_PAR06+MV_PAR07)) .and.( SF1->F1_FORNECE+SF1->F1_LOJA # MV_PAR06+MV_PAR07 )
			DbSelectArea("SF1")
			Dbskip()
			Loop
		EndIf
		
		nVtotven := nVimpven := nVicmven := nVissven := 0
		nVpisven := nVcofven := nVcusven := nVlucbru := 0
		nVprzmd1 := nVprzmd2 := nVjurest := nVtotdes := 0
		nVcomven := nVlucliq := nVdesfix := nVresult := 0
		
		cTipo := "6DEV"
		nTipo := 9
		cNFSD1:= ""
		DbSelectArea( "SD1" )
		DbSetOrder(1)
		DbSeek( xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )
		
		While !Eof() .and. SD1->D1_FILIAL == xFilial("SD1") .and. SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA == SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
			
			DbSelectArea( "SF4" )
			DbSetOrder(1)
			DbSeek( xFilial("SF4") + SD1->D1_TES )
			
			If SF4->F4_ESTOQUE == "S"
				nVtotven += ( SD1->D1_TOTAL + SD1->D1_DESPESA - SD1->D1_VALDESC )
				nVimpven += ( SD1->D1_VALICM + SD1->D1_VALISS )
				nVicmven += SD1->D1_VALICM
				nVissven += SD1->D1_VALISS
				nVpisven += 0
				nVcofven += 0
				nVcusven += SD1->D1_CUSTO
				nVlucbru += ( SD1->D1_TOTAL + SD1->D1_DESPESA - SD1->D1_VALDESC - SD1->D1_VALICM - SD1->D1_VALISS - SD1->D1_CUSTO )
				cNFSD1 := SD1->D1_NFORI + SD1->D1_SERIORI
				
				////////////////////////////////////////////////////////////////////////////
				//                     Subtrair do Resumo por Grupo                       //
				////////////////////////////////////////////////////////////////////////////
				If !Empty(cNFSD1)
					DbSelectArea( "SF2" )
					DbSetOrder(1)
					DbSeek( xFilial("SF2") + cNFSD1 )
					If MV_PAR05 >= 3
						If SF2->F2_PREFORI # GetNewPar("MV_PREFOFI","OFI")
							cPrefix := SF2->F2_PREFORI
						Else
							cPrefix := "OFP"
						EndIf
						nPos := 0
						nPos := aScan(aPrzMed,{|x| substr(x[1],2,3)+substr(x[2],1,4) == cPrefix + SD1->D1_GRUPO })
						If nPos > 0
							aPrzMed[nPos,3] -= ( SD1->D1_TOTAL + SD1->D1_DESPESA - SD1->D1_VALDESC )
							aPrzMed[nPos,4] -= ( SD1->D1_VALICM + SD1->D1_VALISS )
							aPrzMed[nPos,5] -= SD1->D1_VALICM
							aPrzMed[nPos,6] -= SD1->D1_VALISS
							aPrzMed[nPos,7] -= 0
							aPrzMed[nPos,8] -= 0
							aPrzMed[nPos,9] -= SD1->D1_CUSTO
							aPrzMed[nPos,10]-= ( SD1->D1_TOTAL + SD1->D1_DESPESA - SD1->D1_VALDESC - SD1->D1_VALICM - SD1->D1_VALISS - SD1->D1_CUSTO )
						EndIf
					EndIf
				EndIf
				////////////////////////////////////////////////////////////////////////////
				
			EndIf
			DbSelectArea("SD1")
			Dbskip()
		EndDo
		If !Empty(cNFSD1)
			If ( SF2->F2_VEND1 < MV_PAR03 .or. SF2->F2_VEND1 > MV_PAR04 )
				DbSelectArea("SF1")
				Dbskip()
				Loop
			EndIf
			
			////////////////////////////////////////////////////////////////////////////////////////
			//  Andre Luis Almeida - 01/04/2004 - Mostrar Vendedor com Devolucao mesmo SEM Venda  //
			////////////////////////////////////////////////////////////////////////////////////////
			cTp := cTipo
			Do Case
				Case SF2->F2_PREFORI == GetNewPar("MV_PREFVEI","VEI")		//  V E I C U L O S
					cTp := "1VEI"
				Case SF2->F2_PREFORI == GetNewPar("MV_PREFBAL","BAL")		//  B A L C A O
					If SF2->F2_VALISS > 0 // OUTRAS VENDAS
						cTp := "4OVD"
					Else	//  B A L C A O
						cTp := "2BAL"
					EndIf
				Case SF2->F2_PREFORI == GetNewPar("MV_PREFOFI","OFI")		//  O F I C I N A
					cTp := "3OFP"
			EndCase
			DbSelectArea( "SA3" )
			DbSetOrder(1)
			DbSeek( xFilial("SA3") + SF2->F2_VEND1 )
			cVendedor := SF2->F2_VEND1 + " " + left(SA3->A3_NOME,17)
			nPos := 0
			nPos := aScan(aGrpVen,{|x| x[1]+x[2] == cTp + cVendedor })
			If nPos == 0
				aAdd(aGrpVen,{ cTp , cVendedor , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , SF2->F2_PREFORI })
				nPos := 0
				cVendedor := SF2->F2_VEND1 + STR0016
				nPos := aScan(aNumVen,{|x| x[1]+x[2]+x[19] == cTp + cVendedor + SF2->F2_PREFORI })
				If nPos == 0
					aAdd(aNumVen,{ cTp , cVendedor , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , SF2->F2_PREFORI , 0 })
				EndIf
				cVendedor := SF2->F2_VEND1 + " " + left(SA3->A3_NOME,17)
			EndIf
			////////////////////////////////////////////////////////////////////////////////////////
			
			nPos := 0
			nPos := aScan(aGrpVen,{|x| x[1]+x[2] == cTipo + cVendedor })
			If nPos == 0
				aAdd(aGrpVen,{ cTipo , cVendedor , nVtotven , nVimpven , nVicmven ,	nVissven , nVpisven , nVcofven , nVcusven , nVlucbru , nVprzmd1 , nVprzmd2 , nVjurest , nVtotdes , nVcomven , nVlucliq , nVdesfix , nVresult , SF2->F2_PREFORI })
			Else
				aGrpVen[nPos,3] += nVtotven
				aGrpVen[nPos,4] += nVimpven
				aGrpVen[nPos,5] += nVicmven
				aGrpVen[nPos,6] += nVissven
				aGrpVen[nPos,7] += nVpisven
				aGrpVen[nPos,8] += nVcofven
				aGrpVen[nPos,9] += nVcusven
				aGrpVen[nPos,10]+= nVlucbru
			EndIf
			cVendedor := SF2->F2_VEND1 + STR0017
			nPos := 0
			nPos := aScan(aNumVen,{|x| x[1]+x[2]+x[19] == cTipo + cVendedor + SF2->F2_PREFORI })
			If nPos == 0
				nTotSrv := 1
				aAdd(aNumVen,{ cTipo , cVendedor , nVtotven , nVimpven , nVicmven ,	nVissven , nVpisven , nVcofven , nVcusven , nVlucbru , nVprzmd1 , nVprzmd2 , nVjurest , nVtotdes , nVcomven , nVlucliq , nVdesfix , nVresult , SF2->F2_PREFORI , nTotSrv })
			Else
				aNumVen[nPos,3] += nVtotven
				aNumVen[nPos,4] += nVimpven
				aNumVen[nPos,5] += nVicmven
				aNumVen[nPos,6] += nVissven
				aNumVen[nPos,7] += nVpisven
				aNumVen[nPos,8] += nVcofven
				aNumVen[nPos,9] += nVcusven
				aNumVen[nPos,10]+= nVlucbru
				aNumVen[nPos,20]+= nTotSrv
			EndIf
			////////// GRUPO //////////
			aTotVen[nTipo,2] += nVtotven
			aTotVen[nTipo,3] += nVimpven
			aTotVen[nTipo,4] += nVicmven
			aTotVen[nTipo,5] += nVissven
			aTotVen[nTipo,6] += nVpisven
			aTotVen[nTipo,7] += nVcofven
			aTotVen[nTipo,8] += nVcusven
			aTotVen[nTipo,9] += nVlucbru
		EndIf
	EndIf
	DbSelectArea("SF1")
	Dbskip()
EndDo


// C D C I

DbSelectArea("SEM")
DbSetOrder(2)
DbSeek( xFilial("SEM") + DTOS(MV_PAR01) , .t. )
While !Eof() .and. SEM->EM_FILIAL == xFilial("SEM") .and. SEM->EM_EMISSAO <= MV_PAR02
	DbSelectArea( "SF2" )
	DbSetOrder(1)
	DbSeek( xFilial("SF2") + SEM->EM_NRONOTA + SEM->EM_SERIE )
	If ( SF2->F2_VEND1 < MV_PAR03 .or. SF2->F2_VEND1 > MV_PAR04 )
		DbSelectArea("SEM")
		Dbskip()
		Loop
	EndIf
	If !Empty(Alltrim(MV_PAR06+MV_PAR07)) .and.( SEM->EM_CLIENTE+SEM->EM_LOJA # MV_PAR06+MV_PAR07 )
		DbSelectArea("SEM")
		Dbskip()
		Loop
	EndIf
	DbSelectArea( "SEN" )
	DbSetOrder(1)
	DbSeek( xFilial("SEN") + SEM->EM_PLANO )
	aCDCI[1,3] += SEM->EM_VALOR
	aCDCI[1,4] += SEM->EM_ENTRADA
	aCDCI[1,5] += SEM->EM_VLRFIN
	aCDCI[1,6] += ( SEM->EM_TOTFIN - ( SEM->EM_VLRFIN + SEM->EM_ENTRADA ) )
	aCDCI[1,7] += SEM->EM_TOTFIN
	If MV_PAR05 >= 2
		DbSelectArea( "SA3" )
		DbSetOrder(1)
		DbSeek( xFilial("SA3") + SF2->F2_VEND1 )
		cVendedor := "   "+left(SF2->F2_VEND1+" "+SA3->A3_NOME+space(25),25)
		nPos := 0
		nPos := aScan(aCDCI,{|x| x[1]+substr(x[2],1,10)+x[8] == "2" + substr(cVendedor,1,10)+space(6) })
		If nPos == 0
			aAdd(aCDCI,{ "2", cVendedor , SEM->EM_VALOR , SEM->EM_ENTRADA , SEM->EM_VLRFIN , ( SEM->EM_TOTFIN - ( SEM->EM_VLRFIN + SEM->EM_ENTRADA ) ) , SEM->EM_TOTFIN , space(6) })//CDCI
		Else
			aCDCI[nPos,3] += SEM->EM_VALOR
			aCDCI[nPos,4] += SEM->EM_ENTRADA
			aCDCI[nPos,5] += SEM->EM_VLRFIN
			aCDCI[nPos,6] += ( SEM->EM_TOTFIN - ( SEM->EM_VLRFIN + SEM->EM_ENTRADA ) )
			aCDCI[nPos,7] += SEM->EM_TOTFIN
		EndIf
		If MV_PAR05 >= 3
			DbSelectArea( "SA1" )
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA )
			aAdd(aCDCI,{ "2", cVendedor , SEM->EM_VALOR , SEM->EM_ENTRADA , SEM->EM_VLRFIN , ( SEM->EM_TOTFIN - ( SEM->EM_VLRFIN + SEM->EM_ENTRADA ) ) , SEM->EM_TOTFIN , space(5)+left(SEM->EM_NRONOTA+"-"+Alltrim(SEM->EM_SERIE)+" "+SA1->A1_NOME,23) })//CDCI
		EndIf
	EndIf
	DbSelectArea("SEM")
	Dbskip()
EndDo

aSort(aNumVen,1,,{|x,y| x[1]+x[2] < y[1]+y[2]})
For ni:=1 to Len(aNumVen)
	If cMudou # left(aNumVen[ni,2],6)
		cMudou := left(aNumVen[ni,2],6)
		If aNumVen[ni,1] == "1VEI"
			nPos := 2
		ElseIf aNumVen[ni,1] == "2BAL"
			nPos := 3
		ElseIf left(aNumVen[ni,1],3) == "3OF"
			If aNumVen[ni,1] == "3OFP"
				nPos := 4
				nl := 0
				nl := aScan(aNumVen,{|x| x[1]+left(x[2],6) == "6DEV" + left(aNumVen[ni,2],6) })
				If nl # 0
					aTotVen[nPos,2] -= aNumVen[nl,3]
					aTotVen[nPos,3] -= aNumVen[nl,4]
					aTotVen[nPos,4] -= aNumVen[nl,5]
					aTotVen[nPos,5] -= aNumVen[nl,6]
					aTotVen[nPos,6] -= aNumVen[nl,7]
					aTotVen[nPos,7] -= aNumVen[nl,8]
					aTotVen[nPos,8] -= aNumVen[nl,9]
					aTotVen[nPos,9] -= aNumVen[nl,10]
				EndIf
				nPos := 5
			ElseIf aNumVen[ni,1] == "3OFS"
				nPos := 6
			EndIf
		ElseIf aNumVen[ni,1] == "4OVD"
			nPos := 7
		ElseIf aNumVen[ni,1] == "5DES"
			nPos := 8
		ElseIf aNumVen[ni,1] == "6DEV"
			nPos := 9
		EndIf
		If str(nPos,1) $ "2/3/4/5"
			nl := 0
			nl := aScan(aNumVen,{|x| x[1]+left(x[2],6) == "6DEV" + left(aNumVen[ni,2],6) })
			If nl # 0
				aNumVen[nl,1]:= "XYZZ"
				aTotVen[nPos,2] -= aNumVen[nl,3]
				aTotVen[nPos,3] -= aNumVen[nl,4]
				aTotVen[nPos,4] -= aNumVen[nl,5]
				aTotVen[nPos,5] -= aNumVen[nl,6]
				aTotVen[nPos,6] -= aNumVen[nl,7]
				aTotVen[nPos,7] -= aNumVen[nl,8]
				aTotVen[nPos,8] -= aNumVen[nl,9]
				aTotVen[nPos,9] -= aNumVen[nl,10]
			EndIf
		EndIf
	EndIf
Next
For ni:=1 to Len(aNumVen)
	if aNumVen[ni,1]="XYZZ"
		aNumVen[ni,1]="6DEV"
	endif
next

///////////////////////////////////////////////////////////
//                                                       //
//          I   M   P   R   E   S   S   A   O            //
//                                                       //
///////////////////////////////////////////////////////////

@ nLin++ , 00 psay left( Repl("*",100)+STR0018+Repl("*",120),220)
@ nLin++ , 01 psay STR0007 ;
+ Transform(aTotVen[1,2],"@E 999,999,999.99"); // Venda Total
+ Transform(aTotVen[1,3],"@E 99999,999.99");	  // Impostos
+ Transform(aTotVen[1,4],"@E 99999,999.99");	  // ICMS
+ Transform(aTotVen[1,5],"@E 9999,999.99");	  // ISS
+ Transform(aTotVen[1,6],"@E 9999,999.99");	  // PIS
+ Transform(aTotVen[1,7],"@E 9999,999.99");	  // Cofins
+ Transform(aTotVen[1,8],"@E 99,999,999.99");  // Custos
+ Transform(aTotVen[1,9],"@E 99,999,999.99") + Transform(((aTotVen[1,9]/aTotVen[1,2])*100),"@E 9999.9"); // Lucro Bruto
+ Transform((aTotVen[1,10]/aTotVen[1,11]),"@E 9999999.9");        // Prazo Medio
+ Transform(aTotVen[1,12],"@E 99,999,999.99"); // Juro Estoque
+ Transform(aTotVen[1,13],"@E 99,999,999.99"); // Desp Var
+ Transform(aTotVen[1,14],"@E 99,999,999.99"); // Comissoes
+ Transform(aTotVen[1,15],"@E 99,999,999.99"); // Lucro Liq
+ Transform(aTotVen[1,16],"@E 99,999,999.99"); // Cst/Dsp Fix
+ Transform(aTotVen[1,17],"@E 99,999,999.99")  // Resultado Final
@ nLin++ , 01 psay STR0008 ;
+ Transform((aTotVen[1,2]-aTotVen[9,2]),"@E 999,999,999.99"); // Venda Total
+ Transform((aTotVen[1,3]-aTotVen[9,3]),"@E 99999,999.99");	  // Impostos
+ Transform((aTotVen[1,4]-aTotVen[9,4]),"@E 99999,999.99");	  // ICMS
+ Transform((aTotVen[1,5]-aTotVen[9,5]),"@E 9999,999.99");	  // ISS
+ Transform((aTotVen[1,6]-aTotVen[9,6]),"@E 9999,999.99");	  // PIS
+ Transform((aTotVen[1,7]-aTotVen[9,7]),"@E 9999,999.99");	  // Cofins
+ Transform((aTotVen[1,8]-aTotVen[9,8]),"@E 99,999,999.99");  // Custos
+ Transform((aTotVen[1,9]-aTotVen[9,9]),"@E 99,999,999.99") + Transform((((aTotVen[1,9]-aTotVen[9,9])/(aTotVen[1,2]-aTotVen[9,2]))*100),"@E 9999.9"); // Lucro Bruto
+ Transform((aTotVen[1,10]/aTotVen[1,11]),"@E 9999999.9");        // Prazo Medio
+ Transform(aTotVen[1,12],"@E 99,999,999.99"); // Juro Estoque
+ Transform(aTotVen[1,13],"@E 99,999,999.99"); // Desp Var
+ Transform(aTotVen[1,14],"@E 99,999,999.99"); // Comissoes
+ Transform(aTotVen[1,15],"@E 99,999,999.99"); // Lucro Liq
+ Transform(aTotVen[1,16],"@E 99,999,999.99"); // Cst/Dsp Fix
+ Transform(aTotVen[1,17],"@E 99,999,999.99")  // Resultado Final
@ nLin++ , 01 psay STR0009 ;
+ Transform(aTotVen[2,2],"@E 999,999,999.99"); // Venda Total
+ Transform(aTotVen[2,3],"@E 99999,999.99");	  // Impostos
+ Transform(aTotVen[2,4],"@E 99999,999.99");	  // ICMS
+ Transform(aTotVen[2,5],"@E 9999,999.99");	  // ISS
+ Transform(aTotVen[2,6],"@E 9999,999.99");	  // PIS
+ Transform(aTotVen[2,7],"@E 9999,999.99");	  // Cofins
+ Transform(aTotVen[2,8],"@E 99,999,999.99");  // Custos
+ Transform(aTotVen[2,9],"@E 99,999,999.99") + Transform(((aTotVen[2,9]/aTotVen[2,2])*100),"@E 9999.9"); // Lucro Bruto
+ Transform((aTotVen[2,10]/aTotVen[2,11]),"@E 9999999.9");        // Prazo Medio
+ Transform(aTotVen[2,12],"@E 99,999,999.99"); // Juro Estoque
+ Transform(aTotVen[2,13],"@E 99,999,999.99"); // Desp Var
+ Transform(aTotVen[2,14],"@E 99,999,999.99"); // Comissoes
+ Transform(aTotVen[2,15],"@E 99,999,999.99"); // Lucro Liq
+ Transform(aTotVen[2,16],"@E 99,999,999.99"); // Cst/Dsp Fix
+ Transform(aTotVen[2,17],"@E 99,999,999.99")  // Resultado Final
@ nLin++ , 01 psay STR0010 ;
+ Transform((aTotVen[3,2]+aTotVen[5,2]),"@E 999,999,999.99");  // Venda Total
+ Transform((aTotVen[3,3]+aTotVen[5,3]),"@E 99999,999.99");	   // Impostos
+ Transform((aTotVen[3,4]+aTotVen[5,4]),"@E 99999,999.99");	   // ICMS
+ Transform((aTotVen[3,5]+aTotVen[5,5]),"@E 9999,999.99");	   // ISS
+ Transform((aTotVen[3,6]+aTotVen[5,6]),"@E 9999,999.99");	   // PIS
+ Transform((aTotVen[3,7]+aTotVen[5,7]),"@E 9999,999.99");	   // Cofins
+ Transform((aTotVen[3,8]+aTotVen[5,8]),"@E 99,999,999.99");   // Custos
+ Transform((aTotVen[3,9]+aTotVen[5,9]),"@E 99,999,999.99") + Transform((((aTotVen[3,9]+aTotVen[5,9])/(aTotVen[3,2]+aTotVen[5,2]))*100),"@E 9999.9"); // Lucro Bruto
+ Transform(((aTotVen[3,10]+aTotVen[5,10])/(aTotVen[3,11]+aTotVen[5,11])),"@E 9999999.9");        // Prazo Medio
+ Transform((aTotVen[3,12]+aTotVen[5,12]),"@E 99,999,999.99"); // Juro Estoque
+ Transform((aTotVen[3,13]+aTotVen[5,13]),"@E 99,999,999.99"); // Desp Var
+ Transform((aTotVen[3,14]+aTotVen[5,14]),"@E 99,999,999.99"); // Comissoes
+ Transform((aTotVen[3,15]+aTotVen[5,15]),"@E 99,999,999.99"); // Lucro Liq
+ Transform((aTotVen[3,16]+aTotVen[5,16]),"@E 99,999,999.99"); // Cst/Dsp Fix
+ Transform((aTotVen[3,17]+aTotVen[5,17]),"@E 99,999,999.99")  // Resultado Final
@ nLin++ , 01 psay STR0011 ;
+ Transform(aTotVen[6,2],"@E 999,999,999.99"); // Venda Total
+ Transform(aTotVen[6,3],"@E 99999,999.99");	  // Impostos
+ Transform(aTotVen[6,4],"@E 99999,999.99");	  // ICMS
+ Transform(aTotVen[6,5],"@E 9999,999.99");	  // ISS
+ Transform(aTotVen[6,6],"@E 9999,999.99");	  // PIS
+ Transform(aTotVen[6,7],"@E 9999,999.99");	  // Cofins
+ Transform(aTotVen[6,8],"@E 99,999,999.99");  // Custos
+ Transform(aTotVen[6,9],"@E 99,999,999.99") + Transform(((aTotVen[6,9]/aTotVen[6,2])*100),"@E 9999.9"); // Lucro Bruto
+ Transform((aTotVen[6,10]/aTotVen[6,11]),"@E 9999999.9");  // Prazo Medio
+ Transform(aTotVen[6,12],"@E 99,999,999.99"); // Juro Estoque
+ Transform(aTotVen[6,13],"@E 99,999,999.99"); // Desp Var
+ Transform(aTotVen[6,14],"@E 99,999,999.99"); // Comissoes
+ Transform(aTotVen[6,15],"@E 99,999,999.99"); // Lucro Liq
+ Transform(aTotVen[6,16],"@E 99,999,999.99"); // Cst/Dsp Fix
+ Transform(aTotVen[6,17],"@E 99,999,999.99")  // Resultado Final
@ nLin++ , 01 psay STR0012 ;
+ Transform(aTotVen[7,2],"@E 999,999,999.99"); // Venda Total
+ Transform(aTotVen[7,3],"@E 99999,999.99");	  // Impostos
+ Transform(aTotVen[7,4],"@E 99999,999.99");	  // ICMS
+ Transform(aTotVen[7,5],"@E 9999,999.99");	  // ISS
+ Transform(aTotVen[7,6],"@E 9999,999.99");	  // PIS
+ Transform(aTotVen[7,7],"@E 9999,999.99");	  // Cofins
+ Transform(aTotVen[7,8],"@E 99,999,999.99");  // Custos
+ Transform(aTotVen[7,9],"@E 99,999,999.99") + Transform(((aTotVen[7,9]/aTotVen[7,2])*100),"@E 9999.9"); // Lucro Bruto
+ Transform((aTotVen[7,10]/aTotVen[7,11]),"@E 9999999.9");  // Prazo Medio
+ Transform(aTotVen[7,12],"@E 99,999,999.99"); // Juro Estoque
+ Transform(aTotVen[7,13],"@E 99,999,999.99"); // Desp Var
+ Transform(aTotVen[7,14],"@E 99,999,999.99"); // Comissoes
+ Transform(aTotVen[7,15],"@E 99,999,999.99"); // Lucro Liq
+ Transform(aTotVen[7,16],"@E 99,999,999.99"); // Cst/Dsp Fix
+ Transform(aTotVen[7,17],"@E 99,999,999.99")  // Resultado Final
@ nLin++ , 01 psay STR0013 ;
+ Transform(aTotVen[8,2],"@E 999,999,999.99"); // Venda Total
+ Transform(aTotVen[8,3],"@E 99999,999.99");	  // Impostos
+ Transform(aTotVen[8,4],"@E 99999,999.99");	  // ICMS
+ Transform(aTotVen[8,5],"@E 9999,999.99");	  // ISS
+ Transform(aTotVen[8,6],"@E 9999,999.99");	  // PIS
+ Transform(aTotVen[8,7],"@E 9999,999.99");	  // Cofins
+ Transform(aTotVen[8,8],"@E 99,999,999.99");  // Custos
+ Transform(aTotVen[8,9],"@E 99,999,999.99") + Transform(((aTotVen[8,9]/aTotVen[8,2])*100),"@E 9999.9"); // Lucro Bruto
+ Transform((aTotVen[8,10]/aTotVen[8,11]),"@E 9999999.9");  // Prazo Medio
+ Transform(aTotVen[8,12],"@E 99,999,999.99"); // Juro Estoque
+ Transform(aTotVen[8,13],"@E 99,999,999.99"); // Desp Var
+ Transform(aTotVen[8,14],"@E 99,999,999.99"); // Comissoes
+ Transform(aTotVen[8,15],"@E 99,999,999.99"); // Lucro Liq
+ Transform(aTotVen[8,16],"@E 99,999,999.99"); // Cst/Dsp Fix
+ Transform(aTotVen[8,17],"@E 99,999,999.99")  // Resultado Final
@ nLin++ , 01 psay STR0014 ;
+ Transform(aTotVen[9,2],"@E 999,999,999.99"); // Venda Total
+ Transform(aTotVen[9,3],"@E 99999,999.99");	  // Impostos
+ Transform(aTotVen[9,4],"@E 99999,999.99");	  // ICMS
+ Transform(aTotVen[9,5],"@E 9999,999.99");	  // ISS
+ Transform(aTotVen[9,6],"@E 9999,999.99");	  // PIS
+ Transform(aTotVen[9,7],"@E 9999,999.99");	  // Cofins
+ Transform(aTotVen[9,8],"@E 99,999,999.99");  // Custos
+ Transform(aTotVen[9,9],"@E 99,999,999.99") + Transform(((aTotVen[9,9]/aTotVen[9,2])*100),"@E 9999.9"); // Lucro Bruto
+ Transform((aTotVen[9,10]/aTotVen[9,11]),"@E 9999999.9");  // Prazo Medio
+ Transform(aTotVen[9,12],"@E 99,999,999.99"); // Juro Estoque
+ Transform(aTotVen[9,13],"@E 99,999,999.99"); // Desp Var
+ Transform(aTotVen[9,14],"@E 99,999,999.99"); // Comissoes
+ Transform(aTotVen[9,15],"@E 99,999,999.99"); // Lucro Liq
+ Transform(aTotVen[9,16],"@E 99,999,999.99"); // Cst/Dsp Fix
+ Transform(aTotVen[9,17],"@E 99,999,999.99")  // Resultado Final
@ nLin++ , 00 psay Repl("*",220)

If MV_PAR05 == 1
	nLin++
	nLin++
EndIf
nLin++
@ nLin++ , 01 psay STR0007 ;
+ Transform(aTotVen[1,2],"@E 999,999,999.99"); // Venda Total
+ Transform(aTotVen[1,3],"@E 99999,999.99");	  // Impostos
+ Transform(aTotVen[1,4],"@E 99999,999.99");	  // ICMS
+ Transform(aTotVen[1,5],"@E 9999,999.99");	  // ISS
+ Transform(aTotVen[1,6],"@E 9999,999.99");	  // PIS
+ Transform(aTotVen[1,7],"@E 9999,999.99");	  // Cofins
+ Transform(aTotVen[1,8],"@E 99,999,999.99");  // Custos
+ Transform(aTotVen[1,9],"@E 99,999,999.99") + Transform(((aTotVen[1,9]/aTotVen[1,2])*100),"@E 9999.9"); // Lucro Bruto
+ Transform((aTotVen[1,10]/aTotVen[1,11]),"@E 9999999.9");        // Prazo Medio
+ Transform(aTotVen[1,12],"@E 99,999,999.99"); // Juro Estoque
+ Transform(aTotVen[1,13],"@E 99,999,999.99"); // Desp Var
+ Transform(aTotVen[1,14],"@E 99,999,999.99"); // Comissoes
+ Transform(aTotVen[1,15],"@E 99,999,999.99"); // Lucro Liq
+ Transform(aTotVen[1,16],"@E 99,999,999.99"); // Cst/Dsp Fix
+ Transform(aTotVen[1,17],"@E 99,999,999.99")  // Resultado Final
nLin++
@ nLin++ , 01 psay STR0008 ;
+ Transform((aTotVen[1,2]-aTotVen[9,2]),"@E 999,999,999.99"); // Venda Total
+ Transform((aTotVen[1,3]-aTotVen[9,3]),"@E 99999,999.99");	  // Impostos
+ Transform((aTotVen[1,4]-aTotVen[9,4]),"@E 99999,999.99");	  // ICMS
+ Transform((aTotVen[1,5]-aTotVen[9,5]),"@E 9999,999.99");	  // ISS
+ Transform((aTotVen[1,6]-aTotVen[9,6]),"@E 9999,999.99");	  // PIS
+ Transform((aTotVen[1,7]-aTotVen[9,7]),"@E 9999,999.99");	  // Cofins
+ Transform((aTotVen[1,8]-aTotVen[9,8]),"@E 99,999,999.99");  // Custos
+ Transform((aTotVen[1,9]-aTotVen[9,9]),"@E 99,999,999.99") + Transform((((aTotVen[1,9]-aTotVen[9,9])/(aTotVen[1,2]-aTotVen[9,2]))*100),"@E 9999.9"); // Lucro Bruto
+ Transform((aTotVen[1,10]/aTotVen[1,11]),"@E 9999999.9");        // Prazo Medio
+ Transform(aTotVen[1,12],"@E 99,999,999.99"); // Juro Estoque
+ Transform(aTotVen[1,13],"@E 99,999,999.99"); // Desp Var
+ Transform(aTotVen[1,14],"@E 99,999,999.99"); // Comissoes
+ Transform(aTotVen[1,15],"@E 99,999,999.99"); // Lucro Liq
+ Transform(aTotVen[1,16],"@E 99,999,999.99"); // Cst/Dsp Fix
+ Transform(aTotVen[1,17],"@E 99,999,999.99")  // Resultado Final

If MV_PAR05 == 1
	nLin++
	nLin++
EndIf
aSort(aNumVen,1,,{|x,y| x[1]+x[2] < y[1]+y[2]})
For ni:=1 to Len(aNumVen)
	IncRegua()
	If nLin >= 60
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
		nLin++
		@ nLin++ , 01 psay cContinua
		nLin++
	EndIf
	If cMudou # aNumVen[ni,1]
		cMudou := aNumVen[ni,1]
		cMudou2:= "INICIAL"
		If aNumVen[ni,1] == "1VEI"
			cTipo := STR0019
			cContinua := STR0020
			nPos  := 2
		ElseIf aNumVen[ni,1] == "2BAL"
			cTipo := STR0021
			cContinua := STR0022
			nPos  := 3
		ElseIf aNumVen[ni,1] == "3OFP"
			If cImpOfi # "JA"
				cTipo := STR0023
				nPos  := 4
				nLin++
				@ nLin++ , 01 psay cTipo ;
				+ Transform(aTotVen[nPos,2],"@E 999,999,999.99"); // Venda Total
				+ Transform(aTotVen[nPos,3],"@E 99999,999.99");	  // Impostos
				+ Transform(aTotVen[nPos,4],"@E 99999,999.99");	  // ICMS
				+ Transform(aTotVen[nPos,5],"@E 9999,999.99");	  // ISS
				+ Transform(aTotVen[nPos,6],"@E 9999,999.99");	  // PIS
				+ Transform(aTotVen[nPos,7],"@E 9999,999.99");	  // Cofins
				+ Transform(aTotVen[nPos,8],"@E 99,999,999.99");  // Custos
				+ Transform(aTotVen[nPos,9],"@E 99,999,999.99") + Transform(((aTotVen[nPos,9]/aTotVen[nPos,2])*100),"@E 9999.9"); // Lucro Bruto
				+ Transform((aTotVen[nPos,10]/aTotVen[nPos,11]),"@E 9999999.9");        // Prazo Medio
				+ Transform(aTotVen[nPos,12],"@E 99,999,999.99"); // Juro Estoque
				+ Transform(aTotVen[nPos,13],"@E 99,999,999.99"); // Desp Var
				+ Transform(aTotVen[nPos,14],"@E 99,999,999.99"); // Comissoes
				+ Transform(aTotVen[nPos,15],"@E 99,999,999.99"); // Lucro Liq
				+ Transform(aTotVen[nPos,16],"@E 99,999,999.99"); // Cst/Dsp Fix
				+ Transform(aTotVen[nPos,17],"@E 99,999,999.99")  // Resultado Final
				cImpOfi := "JA"
			EndIf
			cTipo := STR0024
			cContinua := STR0025
			nPos  := 5
		ElseIf aNumVen[ni,1] == "3OFS"
			If cImpOfi # "JA"
				cTipo := STR0023
				nPos  := 4
				nLin++
				@ nLin++ , 01 psay cTipo ;
				+ Transform(aTotVen[nPos,2],"@E 999,999,999.99"); // Venda Total
				+ Transform(aTotVen[nPos,3],"@E 99999,999.99");	  // Impostos
				+ Transform(aTotVen[nPos,4],"@E 99999,999.99");	  // ICMS
				+ Transform(aTotVen[nPos,5],"@E 9999,999.99");	  // ISS
				+ Transform(aTotVen[nPos,6],"@E 9999,999.99");	  // PIS
				+ Transform(aTotVen[nPos,7],"@E 9999,999.99");	  // Cofins
				+ Transform(aTotVen[nPos,8],"@E 99,999,999.99");  // Custos
				+ Transform(aTotVen[nPos,9],"@E 99,999,999.99") + Transform(((aTotVen[nPos,9]/aTotVen[nPos,2])*100),"@E 9999.9"); // Lucro Bruto
				+ Transform((aTotVen[nPos,10]/aTotVen[nPos,11]),"@E 9999999.9");        // Prazo Medio
				+ Transform(aTotVen[nPos,12],"@E 99,999,999.99"); // Juro Estoque
				+ Transform(aTotVen[nPos,13],"@E 99,999,999.99"); // Desp Var
				+ Transform(aTotVen[nPos,14],"@E 99,999,999.99"); // Comissoes
				+ Transform(aTotVen[nPos,15],"@E 99,999,999.99"); // Lucro Liq
				+ Transform(aTotVen[nPos,16],"@E 99,999,999.99"); // Cst/Dsp Fix
				+ Transform(aTotVen[nPos,17],"@E 99,999,999.99")  // Resultado Final
				cImpOfi := "JA"
			EndIf
			cTipo := STR0026
			cContinua := STR0027
			nPos  := 6
		ElseIf aNumVen[ni,1] == "4OVD"
			cTipo := STR0028
			cContinua := STR0029
			nPos  := 7
		ElseIf aNumVen[ni,1] == "5DES"
			cTipo := STR0030
			cContinua := STR0031
			nPos  := 8
		ElseIf aNumVen[ni,1] == "6DEV"
			cTipo := STR0032
			cContinua := STR0033
			nPos  := 9
		EndIf
		nLin++
		@ nLin++ , 01 psay cTipo ;
		+ Transform(aTotVen[nPos,2],"@E 999,999,999.99"); // Venda Total
		+ Transform(aTotVen[nPos,3],"@E 99999,999.99");	  // Impostos
		+ Transform(aTotVen[nPos,4],"@E 99999,999.99");	  // ICMS
		+ Transform(aTotVen[nPos,5],"@E 9999,999.99");	  // ISS
		+ Transform(aTotVen[nPos,6],"@E 9999,999.99");	  // PIS
		+ Transform(aTotVen[nPos,7],"@E 9999,999.99");	  // Cofins
		+ Transform(aTotVen[nPos,8],"@E 99,999,999.99");  // Custos
		+ Transform(aTotVen[nPos,9],"@E 99,999,999.99") + Transform(((aTotVen[nPos,9]/aTotVen[nPos,2])*100),"@E 9999.9"); // Lucro Bruto
		+ Transform((aTotVen[nPos,10]/aTotVen[nPos,11]),"@E 9999999.9");        // Prazo Medio
		+ Transform(aTotVen[nPos,12],"@E 99,999,999.99"); // Juro Estoque
		+ Transform(aTotVen[nPos,13],"@E 99,999,999.99"); // Desp Var
		+ Transform(aTotVen[nPos,14],"@E 99,999,999.99"); // Comissoes
		+ Transform(aTotVen[nPos,15],"@E 99,999,999.99"); // Lucro Liq
		+ Transform(aTotVen[nPos,16],"@E 99,999,999.99"); // Cst/Dsp Fix
		+ Transform(aTotVen[nPos,17],"@E 99,999,999.99")  // Resultado Final
		If MV_PAR05 == 2
			nLin++
		EndIf
	EndIf
	
	If MV_PAR05 >= 2
		If ( cMudou2 # ( aNumVen[ni,1] + left(aNumVen[ni,2],6) ) )
			cMudou2 := aNumVen[ni,1] + left(aNumVen[ni,2],6)
			nj := 0
			nj := aScan(aGrpVen,{|x| x[1]+left(x[2],6) == cMudou2 })
			If MV_PAR05 >= 3
				nLin++
			EndIf
			cTemDev := "NAO"
			If aNumVen[ni,1] $ "1VEI/2BAL/3OFP" //"1VEI/2BAL/3OFP/3OFS"
				nl := 0
				nl := aScan(aNumVen,{|x| x[1]+left(x[2],6)+x[19] == "6DEV" + left(aNumVen[ni,2],6) + aNumVen[ni,19] })
				If nl # 0
					cTemDev := "SIM"
					aGrpVen[nj,3] -= aNumVen[nl,3]
					aGrpVen[nj,4] -= aNumVen[nl,4]
					aGrpVen[nj,5] -= aNumVen[nl,5]
					aGrpVen[nj,6] -= aNumVen[nl,6]
					aGrpVen[nj,7] -= aNumVen[nl,7]
					aGrpVen[nj,8] -= aNumVen[nl,8]
					aGrpVen[nj,9] -= aNumVen[nl,9]
					aGrpVen[nj,10]-= aNumVen[nl,10]
				EndIf
			EndIf
			@ nLin++ , 05 psay aGrpVen[nj,2] ; // Cod. e Nome Vendedor
			+ Transform(aGrpVen[nj,3],"@E 999,999,999.99"); // Venda Total
			+ Transform(aGrpVen[nj,4],"@E 99999,999.99");   // Impostos
			+ Transform(aGrpVen[nj,5],"@E 99999,999.99");   // ICMS
			+ Transform(aGrpVen[nj,6],"@E 9999,999.99");	   // ISS
			+ Transform(aGrpVen[nj,7],"@E 9999,999.99");	   // PIS
			+ Transform(aGrpVen[nj,8],"@E 9999,999.99");	   // Cofins
			+ Transform(aGrpVen[nj,9],"@E 99,999,999.99");  // Custos
			+ Transform(aGrpVen[nj,10],"@E 99,999,999.99") + Transform(((aGrpVen[nj,10]/aGrpVen[nj,3])*100),"@E 9999.9"); // Lucro Bruto
			+ Transform((aGrpVen[nj,11]/aGrpVen[nj,12]),"@E 9999999.9");  // Prazo Medio
			+ Transform(aGrpVen[nj,13],"@E 99,999,999.99"); // Juro Estoque
			+ Transform(aGrpVen[nj,14],"@E 99,999,999.99"); // Desp Var
			+ Transform(aGrpVen[nj,15],"@E 99,999,999.99"); // Comissoes
			+ Transform(aGrpVen[nj,16],"@E 99,999,999.99"); // Lucro Liq
			+ Transform(aGrpVen[nj,17],"@E 99,999,999.99"); // Cst/Dsp Fix
			+ Transform(aGrpVen[nj,18],"@E 99,999,999.99")  // Resultado Final
		EndIf
	EndIf
	
	If MV_PAR05 >= 3
		If substr(aNumVen[ni,2],7,3) # "VDA"
			if substr(aNumVen[ni,2],7,4) == "SRVC"
				@ nLin++ , 06 psay transform(aNumVen[ni,20], "@E 9999")+" "+substr(aNumVen[ni,2],7,18) ; // NF / Grupo
				+ Transform(aNumVen[ni,3],"@E 999,999,999.99"); // Venda Total
				+ Transform(aNumVen[ni,4],"@E 99999,999.99");   // Impostos
				+ Transform(aNumVen[ni,5],"@E 99999,999.99");   // ICMS
				+ Transform(aNumVen[ni,6],"@E 9999,999.99");	   // ISS
				+ Transform(aNumVen[ni,7],"@E 9999,999.99");	   // PIS
				+ Transform(aNumVen[ni,8],"@E 9999,999.99");	   // Cofins
				+ Transform(aNumVen[ni,9],"@E 99,999,999.99");  // Custos
				+ Transform(aNumVen[ni,10],"@E 99,999,999.99") + Transform(((aNumVen[ni,10]/aNumVen[ni,3])*100),"@E 9999.9"); // Lucro Bruto
				+ Transform((aNumVen[ni,11]/aNumVen[ni,12]),"@E 9999999.9");  // Prazo Medio
				+ Transform(aNumVen[ni,13],"@E 99,999,999.99"); // Juro Estoque
				+ Transform(aNumVen[ni,14],"@E 99,999,999.99"); // Desp Var
				+ Transform(aNumVen[ni,15],"@E 99,999,999.99"); // Comissoes
				+ Transform(aNumVen[ni,16],"@E 99,999,999.99"); // Lucro Liq
				+ Transform(aNumVen[ni,17],"@E 99,999,999.99"); // Cst/Dsp Fix
				+ Transform(aNumVen[ni,18],"@E 99,999,999.99")  // Resultado Final
			Else
				@ nLin++ , 07 psay substr(aNumVen[ni,2],7,22) ; // NF / Grupo
				+ Transform(aNumVen[ni,3],"@E 999,999,999.99"); // Venda Total
				+ Transform(aNumVen[ni,4],"@E 99999,999.99");   // Impostos
				+ Transform(aNumVen[ni,5],"@E 99999,999.99");   // ICMS
				+ Transform(aNumVen[ni,6],"@E 9999,999.99");	   // ISS
				+ Transform(aNumVen[ni,7],"@E 9999,999.99");	   // PIS
				+ Transform(aNumVen[ni,8],"@E 9999,999.99");	   // Cofins
				+ Transform(aNumVen[ni,9],"@E 99,999,999.99");  // Custos
				+ Transform(aNumVen[ni,10],"@E 99,999,999.99") + Transform(((aNumVen[ni,10]/aNumVen[ni,3])*100),"@E 9999.9"); // Lucro Bruto
				+ Transform((aNumVen[ni,11]/aNumVen[ni,12]),"@E 9999999.9");  // Prazo Medio
				+ Transform(aNumVen[ni,13],"@E 99,999,999.99"); // Juro Estoque
				+ Transform(aNumVen[ni,14],"@E 99,999,999.99"); // Desp Var
				+ Transform(aNumVen[ni,15],"@E 99,999,999.99"); // Comissoes
				+ Transform(aNumVen[ni,16],"@E 99,999,999.99"); // Lucro Liq
				+ Transform(aNumVen[ni,17],"@E 99,999,999.99"); // Cst/Dsp Fix
				+ Transform(aNumVen[ni,18],"@E 99,999,999.99")  // Resultado Final
			Endif
		EndIf
		If cTemDev == "SIM" .and. aNumVen[ni,1] # "3OFS"
			cImpDev := "NAO"
			If ni < Len(aNumVen)
				If ( ( aNumVen[ni,1] + substr(aNumVen[ni,2],1,6) ) # ( aNumVen[ni+1,1] + substr(aNumVen[ni+1,2],1,6) ) )
					cImpDev := "SIM"
				EndIf
			Else
				cImpDev := "SIM"
			EndIf
			If cImpDev == "SIM"
				if substr(aNumVen[ni,2],7,4) == "SRVC"
					@ nLin++ , 06 psay transform(aNumVen[ni,20], "@E 9999")+" "+substr(aNumVen[nl,2],7,18) ; // NF / Grupo
					+ Transform((aNumVen[nl,3]*(-1)),"@E 999,999,999.99"); // Venda Total
					+ Transform((aNumVen[nl,4]*(-1)),"@E 99999,999.99");   // Impostos
					+ Transform((aNumVen[nl,5]*(-1)),"@E 99999,999.99");   // ICMS
					+ Transform((aNumVen[nl,6]*(-1)),"@E 9999,999.99");	 // ISS
					+ Transform((aNumVen[nl,7]*(-1)),"@E 9999,999.99");	 // PIS
					+ Transform((aNumVen[nl,8]*(-1)),"@E 9999,999.99");	 // Cofins
					+ Transform((aNumVen[nl,9]*(-1)),"@E 99,999,999.99");  // Custos
					+ Transform((aNumVen[nl,10]*(-1)),"@E 99,999,999.99") + Transform(((aNumVen[nl,10]/aNumVen[nl,3])*100),"@E 9999.9"); // Lucro Bruto
					+ "      0,0         0,00         0,00         0,00         0,00         0,00         0,00"
				Else
					@ nLin++ , 07 psay substr(aNumVen[nl,2],7,22) ; // NF / Grupo
					+ Transform((aNumVen[nl,3]*(-1)),"@E 999,999,999.99"); // Venda Total
					+ Transform((aNumVen[nl,4]*(-1)),"@E 99999,999.99");   // Impostos
					+ Transform((aNumVen[nl,5]*(-1)),"@E 99999,999.99");   // ICMS
					+ Transform((aNumVen[nl,6]*(-1)),"@E 9999,999.99");	 // ISS
					+ Transform((aNumVen[nl,7]*(-1)),"@E 9999,999.99");	 // PIS
					+ Transform((aNumVen[nl,8]*(-1)),"@E 9999,999.99");	 // Cofins
					+ Transform((aNumVen[nl,9]*(-1)),"@E 99,999,999.99");  // Custos
					+ Transform((aNumVen[nl,10]*(-1)),"@E 99,999,999.99") + Transform(((aNumVen[nl,10]/aNumVen[nl,3])*100),"@E 9999.9"); // Lucro Bruto
					+ "      0,0         0,00         0,00         0,00         0,00         0,00         0,00"
				Endif
			EndIf
		EndIf
	EndIf
Next

If Len(aCDCI) > 1 .or. MV_PAR05 == 1
	nLin++
	@ nLin++ , 00 psay Repl("*",220)
	aSort(aCDCI,1,,{|x,y| x[1]+x[2]+x[8] < y[1]+y[2]+y[8] })
	nLin++
	If nLin >= 57
		nLin := 1
		nLin := cabec(ctitulo,"",cabec2,nomeprog,tamanho,nCaracter) + 1
		nLin++
	EndIf
	@ nLin++ , 30 psay STR0034
	For ni:=1 to Len(aCDCI)
		If Empty(Alltrim(aCDCI[ni,8])) .and. MV_PAR05 >= 3
			nLin++
		EndIf
		If nLin >= 60
			nLin := 1
			nLin := cabec(ctitulo,"",cabec2,nomeprog,tamanho,nCaracter) + 1
			nLin++
			@ nLin++ , 01 psay STR0035
			nLin++
			@ nLin++ , 30 psay STR0034
			nLin++
		EndIf
		@ nLin++ , 01 psay IIf(Empty(Alltrim(aCDCI[ni,8])),aCDCI[ni,2],aCDCI[ni,8]) ;
		+ Transform(aCDCI[ni,3],"@E 999,999,999.99");	// Vlr Nota Fiscal
		+ Transform(aCDCI[ni,4],"@E 999,999,999.99");	// Vlr Entrada
		+ Transform(aCDCI[ni,5],"@E 999,999,999.99");	// Vlr Financiado
		+ Transform(aCDCI[ni,6],"@E 999,999,999.99");	// Vlr Encargos
		+ Transform(aCDCI[ni,7],"@E 999,999,999.99")	// Vlr Total
		If aCDCI[ni,1]=="1" .and. MV_PAR05 == 2
			nLin++
		EndIf
	Next
EndIf
nLin++
@ nLin++ , 00 psay Repl("*",220)

If MV_PAR05 == 4
	nLin := 1
	nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	@ nLin++ , 92 psay STR0036
	nLin++
	@ nLin++ , 01 psay STR0007 ;
	+ Transform(aTotVen[1,2],"@E 999,999,999.99");	// Venda Total
	+ Transform(aTotVen[1,3],"@E 99999,999.99");	// Impostos
	+ Transform(aTotVen[1,4],"@E 99999,999.99");	// ICMS
	+ Transform(aTotVen[1,5],"@E 9999,999.99");		// ISS
	+ Transform(aTotVen[1,6],"@E 9999,999.99");		// PIS
	+ Transform(aTotVen[1,7],"@E 9999,999.99");		// Cofins
	+ Transform(aTotVen[1,8],"@E 99,999,999.99");  // Custos
	+ Transform(aTotVen[1,9],"@E 99,999,999.99") + Transform(((aTotVen[1,9]/aTotVen[1,2])*100),"@E 9999.9"); // Lucro Bruto
	+ Transform((aTotVen[1,10]/aTotVen[1,11]),"@E 9999999.9");        // Prazo Medio
	+ Transform(aTotVen[1,12],"@E 99,999,999.99"); // Juro Estoque
	+ Transform(aTotVen[1,13],"@E 99,999,999.99"); // Desp Var
	+ Transform(aTotVen[1,14],"@E 99,999,999.99"); // Comissoes
	+ Transform(aTotVen[1,15],"@E 99,999,999.99"); // Lucro Liq
	+ Transform(aTotVen[1,16],"@E 99,999,999.99"); // Cst/Dsp Fix
	+ Transform(aTotVen[1,17],"@E 99,999,999.99")  // Resultado Final
	nLin++
	@ nLin++ , 01 psay STR0008 ;
	+ Transform((aTotVen[1,2]-aTotVen[9,2]),"@E 999,999,999.99"); // Venda Total
	+ Transform((aTotVen[1,3]-aTotVen[9,3]),"@E 99999,999.99");	  // Impostos
	+ Transform((aTotVen[1,4]-aTotVen[9,4]),"@E 99999,999.99");	  // ICMS
	+ Transform((aTotVen[1,5]-aTotVen[9,5]),"@E 9999,999.99");	  // ISS
	+ Transform((aTotVen[1,6]-aTotVen[9,6]),"@E 9999,999.99");	  // PIS
	+ Transform((aTotVen[1,7]-aTotVen[9,7]),"@E 9999,999.99");	  // Cofins
	+ Transform((aTotVen[1,8]-aTotVen[9,8]),"@E 99,999,999.99");  // Custos
	+ Transform((aTotVen[1,9]-aTotVen[9,9]),"@E 99,999,999.99") + Transform((((aTotVen[1,9]-aTotVen[9,9])/(aTotVen[1,2]-aTotVen[9,2]))*100),"@E 9999.9"); // Lucro Bruto
	+ Transform((aTotVen[1,10]/aTotVen[1,11]),"@E 9999999.9");        // Prazo Medio
	+ Transform(aTotVen[1,12],"@E 99,999,999.99"); // Juro Estoque
	+ Transform(aTotVen[1,13],"@E 99,999,999.99"); // Desp Var
	+ Transform(aTotVen[1,14],"@E 99,999,999.99"); // Comissoes
	+ Transform(aTotVen[1,15],"@E 99,999,999.99"); // Lucro Liq
	+ Transform(aTotVen[1,16],"@E 99,999,999.99"); // Cst/Dsp Fix
	+ Transform(aTotVen[1,17],"@E 99,999,999.99")  // Resultado Final
	
	cMudou := "INICIAL"
	cImpOfi:= "NAO"
	aSort(aPrzMed,1,,{|x,y| x[1]+x[2] < y[1]+y[2]})
	For ni:=1 to Len(aPrzMed)
		If nLin >= 60
			nLin := 1
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
			nLin++
		EndIf
		If cMudou # aPrzMed[ni,1]
			cMudou := aPrzMed[ni,1]
			If aPrzMed[ni,1] == "1VEI"
				cTipo := STR0019
				nPos  := 2
			ElseIf aPrzMed[ni,1] == "2BAL"
				cTipo := STR0021
				nPos  := 3
			ElseIf aPrzMed[ni,1] == "3OFP"
				If cImpOfi # "JA"
					cTipo := STR0023
					nPos  := 4
					nLin++
					@ nLin++ , 01 psay cTipo ;
					+ Transform(aTotVen[nPos,2],"@E 999,999,999.99"); // Venda Total
					+ Transform(aTotVen[nPos,3],"@E 99999,999.99");	  // Impostos
					+ Transform(aTotVen[nPos,4],"@E 99999,999.99");	  // ICMS
					+ Transform(aTotVen[nPos,5],"@E 9999,999.99");	  // ISS
					+ Transform(aTotVen[nPos,6],"@E 9999,999.99");	  // PIS
					+ Transform(aTotVen[nPos,7],"@E 9999,999.99");	  // Cofins
					+ Transform(aTotVen[nPos,8],"@E 99,999,999.99");  // Custos
					+ Transform(aTotVen[nPos,9],"@E 99,999,999.99") + Transform(((aTotVen[nPos,9]/aTotVen[nPos,2])*100),"@E 9999.9"); // Lucro Bruto
					+ Transform((aTotVen[nPos,10]/aTotVen[nPos,11]),"@E 9999999.9");        // Prazo Medio
					+ Transform(aTotVen[nPos,12],"@E 99,999,999.99"); // Juro Estoque
					+ Transform(aTotVen[nPos,13],"@E 99,999,999.99"); // Desp Var
					+ Transform(aTotVen[nPos,14],"@E 99,999,999.99"); // Comissoes
					+ Transform(aTotVen[nPos,15],"@E 99,999,999.99"); // Lucro Liq
					+ Transform(aTotVen[nPos,16],"@E 99,999,999.99"); // Cst/Dsp Fix
					+ Transform(aTotVen[nPos,17],"@E 99,999,999.99")  // Resultado Final
					cImpOfi := "JA"
				EndIf
				cTipo := STR0024
				nPos  := 5
			ElseIf aPrzMed[ni,1] == "3OFS"
				If cImpOfi # "JA"
					cTipo := STR0023
					nPos  := 4
					nLin++
					@ nLin++ , 01 psay cTipo ;
					+ Transform(aTotVen[nPos,2],"@E 999,999,999.99"); // Venda Total
					+ Transform(aTotVen[nPos,3],"@E 99999,999.99");	  // Impostos
					+ Transform(aTotVen[nPos,4],"@E 99999,999.99");	  // ICMS
					+ Transform(aTotVen[nPos,5],"@E 9999,999.99");	  // ISS
					+ Transform(aTotVen[nPos,6],"@E 9999,999.99");	  // PIS
					+ Transform(aTotVen[nPos,7],"@E 9999,999.99");	  // Cofins
					+ Transform(aTotVen[nPos,8],"@E 99,999,999.99");  // Custos
					+ Transform(aTotVen[nPos,9],"@E 99,999,999.99") + Transform(((aTotVen[nPos,9]/aTotVen[nPos,2])*100),"@E 9999.9"); // Lucro Bruto
					+ Transform((aTotVen[nPos,10]/aTotVen[nPos,11]),"@E 9999999.9");        // Prazo Medio
					+ Transform(aTotVen[nPos,12],"@E 99,999,999.99"); // Juro Estoque
					+ Transform(aTotVen[nPos,13],"@E 99,999,999.99"); // Desp Var
					+ Transform(aTotVen[nPos,14],"@E 99,999,999.99"); // Comissoes
					+ Transform(aTotVen[nPos,15],"@E 99,999,999.99"); // Lucro Liq
					+ Transform(aTotVen[nPos,16],"@E 99,999,999.99"); // Cst/Dsp Fix
					+ Transform(aTotVen[nPos,17],"@E 99,999,999.99")  // Resultado Final
					cImpOfi := "JA"
				EndIf
				cTipo := STR0026
				nPos  := 6
			ElseIf aPrzMed[ni,1] == "4OVD"
				cTipo := STR0028
				nPos  := 7
			ElseIf aPrzMed[ni,1] == "5DES"
				cTipo := STR0030
				nPos  := 8
			ElseIf aPrzMed[ni,1] == "6DEV"
				cTipo := STR0032
				nPos  := 9
			EndIf
			nLin++
			@ nLin++ , 01 psay cTipo ;
			+ Transform(aTotVen[nPos,2],"@E 999,999,999.99"); // Venda Total
			+ Transform(aTotVen[nPos,3],"@E 99999,999.99");	  // Impostos
			+ Transform(aTotVen[nPos,4],"@E 99999,999.99");	  // ICMS
			+ Transform(aTotVen[nPos,5],"@E 9999,999.99");	  // ISS
			+ Transform(aTotVen[nPos,6],"@E 9999,999.99");	  // PIS
			+ Transform(aTotVen[nPos,7],"@E 9999,999.99");	  // Cofins
			+ Transform(aTotVen[nPos,8],"@E 99,999,999.99");  // Custos
			+ Transform(aTotVen[nPos,9],"@E 99,999,999.99") + Transform(((aTotVen[nPos,9]/aTotVen[nPos,2])*100),"@E 9999.9"); // Lucro Bruto
			+ Transform((aTotVen[nPos,10]/aTotVen[nPos,11]),"@E 9999999.9");        // Prazo Medio
			+ Transform(aTotVen[nPos,12],"@E 99,999,999.99"); // Juro Estoque
			+ Transform(aTotVen[nPos,13],"@E 99,999,999.99"); // Desp Var
			+ Transform(aTotVen[nPos,14],"@E 99,999,999.99"); // Comissoes
			+ Transform(aTotVen[nPos,15],"@E 99,999,999.99"); // Lucro Liq
			+ Transform(aTotVen[nPos,16],"@E 99,999,999.99"); // Cst/Dsp Fix
			+ Transform(aTotVen[nPos,17],"@E 99,999,999.99")  // Resultado Final
		EndIf
		if substr(aPrzMed[ni,2],1,4) == "SRVC"
			@ nLin++ , 06 psay transform(aPrzMed[ni,20], "@E 9999")+" "+substr(aPrzMed[ni,2],1,18) ; // Grupo
			+ Transform(aPrzMed[ni,3],"@E 999,999,999.99"); // Venda Total
			+ Transform(aPrzMed[ni,4],"@E 99999,999.99");   // Impostos
			+ Transform(aPrzMed[ni,5],"@E 99999,999.99");   // ICMS
			+ Transform(aPrzMed[ni,6],"@E 9999,999.99");	   // ISS
			+ Transform(aPrzMed[ni,7],"@E 9999,999.99");	   // PIS
			+ Transform(aPrzMed[ni,8],"@E 9999,999.99");	   // Cofins
			+ Transform(aPrzMed[ni,9],"@E 99,999,999.99");  // Custos
			+ Transform(aPrzMed[ni,10],"@E 99,999,999.99") + Transform(((aPrzMed[ni,10]/aPrzMed[ni,3])*100),"@E 9999.9"); // Lucro Bruto
			+ Transform((aPrzMed[ni,11]/aPrzMed[ni,12]),"@E 9999999.9");  // Prazo Medio
			+ Transform(aPrzMed[ni,13],"@E 99,999,999.99"); // Juro Estoque
			+ Transform(aPrzMed[ni,14],"@E 99,999,999.99"); // Desp Var
			+ Transform(aPrzMed[ni,15],"@E 99,999,999.99"); // Comissoes
			+ Transform(aPrzMed[ni,16],"@E 99,999,999.99"); // Lucro Liq
			+ Transform(aPrzMed[ni,17],"@E 99,999,999.99"); // Cst/Dsp Fix
			+ Transform(aPrzMed[ni,18],"@E 99,999,999.99")  // Resultado Final
		Else
			@ nLin++ , 07 psay substr(aPrzMed[ni,2],1,22) ; // Grupo
			+ Transform(aPrzMed[ni,3],"@E 999,999,999.99"); // Venda Total
			+ Transform(aPrzMed[ni,4],"@E 99999,999.99");   // Impostos
			+ Transform(aPrzMed[ni,5],"@E 99999,999.99");   // ICMS
			+ Transform(aPrzMed[ni,6],"@E 9999,999.99");	   // ISS
			+ Transform(aPrzMed[ni,7],"@E 9999,999.99");	   // PIS
			+ Transform(aPrzMed[ni,8],"@E 9999,999.99");	   // Cofins
			+ Transform(aPrzMed[ni,9],"@E 99,999,999.99");  // Custos
			+ Transform(aPrzMed[ni,10],"@E 99,999,999.99") + Transform(((aPrzMed[ni,10]/aPrzMed[ni,3])*100),"@E 9999.9"); // Lucro Bruto
			+ Transform((aPrzMed[ni,11]/aPrzMed[ni,12]),"@E 9999999.9");  // Prazo Medio
			+ Transform(aPrzMed[ni,13],"@E 99,999,999.99"); // Juro Estoque
			+ Transform(aPrzMed[ni,14],"@E 99,999,999.99"); // Desp Var
			+ Transform(aPrzMed[ni,15],"@E 99,999,999.99"); // Comissoes
			+ Transform(aPrzMed[ni,16],"@E 99,999,999.99"); // Lucro Liq
			+ Transform(aPrzMed[ni,17],"@E 99,999,999.99"); // Cst/Dsp Fix
			+ Transform(aPrzMed[ni,18],"@E 99,999,999.99")  // Resultado Final
		Endif
	Next
	@ nLin++ , 00 psay Repl("*",220)
Else
	If Len(aNF) > 0
		nLin := 1
		nLin := cabec(ctitulo,"",cabec2,nomeprog,tamanho,nCaracter) + 1
	EndIf
EndIf


If Len(aNF) > 0
	aSort(aNF,1,,{|x,y| x[1] < y[1]})
	nLin++
	@ nLin++ , 78 psay STR0037
	nLin++
	@ nLin++ , 89 psay STR0038
	nLin++
	For ni:=1 to Len(aNF)
		If nLin >= 60
			nLin := 1
			nLin := cabec(ctitulo,"",cabec2,nomeprog,tamanho,nCaracter) + 1
			nLin++
			@ nLin++ , 01 psay STR0039
			nLin++
			@ nLin++ , 89 psay STR0038
			nLin++
		EndIf
		@ nLin++ , 89 psay aNF[ni,1] + Transform(aNF[ni,2],"@E 99999,999,999")
	Next
EndIf

Ms_Flush()
Set Printer to
Set Device  to Screen

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Grv_OFR530³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Vendas por Vendedor com Prazo Medio    (Grava no Vetor)    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Grv_OFR530()

cOutVdas := "NAO"

nVprzmd1 := 0
nVprzmd2 := 0
DbSelectArea("SE1")
DbSetOrder(1)
DbSeek( xFilial("SE1") + SF2->F2_PREFIXO + SF2->F2_DUPL )
While !Eof() .and. ( SE1->E1_FILIAL == xFilial("SE1") ) .and. ( ( SF2->F2_PREFIXO + SF2->F2_DUPL ) == ( SE1->E1_PREFIXO + SE1->E1_NUM ) )
	nVprzmd1 += ( ( nk * ( SE1->E1_VALOR * na ) ) * ( SE1->E1_VENCTO - SF2->F2_EMISSAO ) )
	nVprzmd2 += ( nk * ( SE1->E1_VALOR * na )  )
	If Alltrim(SE1->E1_TIPO) == "CD" // CDCI - sem prazo medio
		nVprzmd1 := 0
	EndIf
	DbSelectArea("SE1")
	Dbskip()
EndDo

DbSelectArea( "SA3" )
DbSetOrder(1)
DbSeek( xFilial("SA3") + SF2->F2_VEND1 )
cVendedor := SF2->F2_VEND1 + " " + left(SA3->A3_NOME,17)

If cNF # SF2->F2_DOC + SF2->F2_SERIE
	cNF  := SF2->F2_DOC + SF2->F2_SERIE
	nPos := 0
	nPos := aScan(aNF,{|x| x[1] == cVendedor })
	If nPos == 0
		aAdd(aNF,{ cVendedor , 1 })
	Else
		aNF[nPos,2]++
	EndIf
EndIf

nPos := 0
nPos := aScan(aGrpVen,{|x| x[1]+x[2] == cTipo + cVendedor })
If nPos == 0
	aAdd(aGrpVen,{ cTipo , cVendedor , nVtotven , nVimpven , nVicmven ,	nVissven , nVpisven , nVcofven , nVcusven , nVlucbru , nVprzmd1 , nVprzmd2 , nVjurest , nVtotdes , nVcomven , nVlucliq , nVdesfix , nVresult , SF2->F2_PREFORI })
Else
	aGrpVen[nPos,3] += nVtotven
	aGrpVen[nPos,4] += nVimpven
	aGrpVen[nPos,5] += nVicmven
	aGrpVen[nPos,6] += nVissven
	aGrpVen[nPos,7] += nVpisven
	aGrpVen[nPos,8] += nVcofven
	aGrpVen[nPos,9] += nVcusven
	aGrpVen[nPos,10]+= nVlucbru
	aGrpVen[nPos,11]+= nVprzmd1
	aGrpVen[nPos,12]+= nVprzmd2
	aGrpVen[nPos,13]+= nVjurest
	aGrpVen[nPos,14]+= nVtotdes
	aGrpVen[nPos,15]+= nVcomven
	aGrpVen[nPos,16]+= nVlucliq
	aGrpVen[nPos,17]+= nVdesfix
	aGrpVen[nPos,18]+= nVresult
EndIf

If MV_PAR05 == 5
	DbSelectArea( "SE4" )
	DbSetOrder(1)
	DbSeek( xFilial("SE4") + SF2->F2_COND )
	cVendedor := SF2->F2_VEND1 + SF2->F2_COND +"  "+ left(SE4->E4_DESCRI+space(20),20)
	nPos := 0
	nPos := aScan(aPrzMed,{|x| x[1]+x[2] == cTipo + substr(cVendedor,7,100) })
	If nPos == 0
		nTotSrv := 1
		aAdd(aPrzMed,{ cTipo , substr(cVendedor,7,100) , nVtotven , nVimpven , nVicmven , nVissven , nVpisven , nVcofven , nVcusven , nVlucbru , nVprzmd1 , nVprzmd2 , nVjurest , nVtotdes , nVcomven , nVlucliq , nVdesfix , nVresult , SF2->F2_PREFORI , nTotSrv })
	Else
		aPrzMed[nPos,3] += nVtotven
		aPrzMed[nPos,4] += nVimpven
		aPrzMed[nPos,5] += nVicmven
		aPrzMed[nPos,6] += nVissven
		aPrzMed[nPos,7] += nVpisven
		aPrzMed[nPos,8] += nVcofven
		aPrzMed[nPos,9] += nVcusven
		aPrzMed[nPos,10]+= nVlucbru
		aPrzMed[nPos,11]+= nVprzmd1
		aPrzMed[nPos,12]+= nVprzmd2
		aPrzMed[nPos,13]+= nVjurest
		aPrzMed[nPos,14]+= nVtotdes
		aPrzMed[nPos,15]+= nVcomven
		aPrzMed[nPos,16]+= nVlucliq
		aPrzMed[nPos,17]+= nVdesfix
		aPrzMed[nPos,18]+= nVresult
		aPrzMed[nPos,20]+= nTotSrv
	EndIf
ElseIf MV_PAR05 == 4
	If	substr(cGrupo,1,4) # "SRVC"
		DbSelectArea( "SBM" )
		DbSetOrder(1)
		DbSeek( xFilial("SBM") + cGrupo , .f. )
		cVendedor := SF2->F2_VEND1 + cGrupo + " " + SBM->BM_DESC + space(30)
	Else
		DbSelectArea( "VOK" )
		DbSetOrder(1)
		DbSeek( xFilial("VOK") + substr(cGrupo,6,3) , .f. )
		cVendedor := SF2->F2_VEND1 + cGrupo + " " + VOK->VOK_DESSER + space(30)
	EndIf
	nPos := 0
	nPos := aScan(aPrzMed,{|x| x[1]+x[2] == cTipo + substr(cVendedor,7,100) })
	If nPos == 0
		nTotSrv := 1
		aAdd(aPrzMed,{ cTipo , substr(cVendedor,7,100) , nVtotven , nVimpven , nVicmven , nVissven , nVpisven , nVcofven , nVcusven , nVlucbru , nVprzmd1 , nVprzmd2 , nVjurest , nVtotdes , nVcomven , nVlucliq , nVdesfix , nVresult , SF2->F2_PREFORI , nTotSrv })
	Else
		aPrzMed[nPos,3] += nVtotven
		aPrzMed[nPos,4] += nVimpven
		aPrzMed[nPos,5] += nVicmven
		aPrzMed[nPos,6] += nVissven
		aPrzMed[nPos,7] += nVpisven
		aPrzMed[nPos,8] += nVcofven
		aPrzMed[nPos,9] += nVcusven
		aPrzMed[nPos,10]+= nVlucbru
		aPrzMed[nPos,11]+= nVprzmd1
		aPrzMed[nPos,12]+= nVprzmd2
		aPrzMed[nPos,13]+= nVjurest
		aPrzMed[nPos,14]+= nVtotdes
		aPrzMed[nPos,15]+= nVcomven
		aPrzMed[nPos,16]+= nVlucliq
		aPrzMed[nPos,17]+= nVdesfix
		aPrzMed[nPos,18]+= nVresult
		aPrzMed[nPos,20]+= nTotSrv
	EndIf
Else
	DbSelectArea( "SA1" )
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA )
	cVendedor := SF2->F2_VEND1 + SF2->F2_DOC + IIf(!Empty(SF2->F2_SERIE),"-"+Alltrim(SF2->F2_SERIE)+" "," ")+left(SA1->A1_NOME,15)
EndIf
nPos := 0
nPos := aScan(aNumVen,{|x| x[1]+x[2] == cTipo + cVendedor })
If nPos == 0
	nTotSrv := 1
	aAdd(aNumVen,{ cTipo , cVendedor , nVtotven , nVimpven , nVicmven , nVissven , nVpisven , nVcofven , nVcusven , nVlucbru , nVprzmd1 , nVprzmd2 , nVjurest , nVtotdes , nVcomven , nVlucliq , nVdesfix , nVresult , SF2->F2_PREFORI , nTotSrv })
Else
	aNumVen[nPos,3] += nVtotven
	aNumVen[nPos,4] += nVimpven
	aNumVen[nPos,5] += nVicmven
	aNumVen[nPos,6] += nVissven
	aNumVen[nPos,7] += nVpisven
	aNumVen[nPos,8] += nVcofven
	aNumVen[nPos,9] += nVcusven
	aNumVen[nPos,10]+= nVlucbru
	aNumVen[nPos,11]+= nVprzmd1
	aNumVen[nPos,12]+= nVprzmd2
	aNumVen[nPos,13]+= nVjurest
	aNumVen[nPos,14]+= nVtotdes
	aNumVen[nPos,15]+= nVcomven
	aNumVen[nPos,16]+= nVlucliq
	aNumVen[nPos,17]+= nVdesfix
	aNumVen[nPos,18]+= nVresult
	aNumVen[nPos,20]+= nTotSrv
EndIf

////////// TOTAL //////////
aTotVen[1,2] += nVtotven
aTotVen[1,3] += nVimpven
aTotVen[1,4] += nVicmven
aTotVen[1,5] += nVissven
aTotVen[1,6] += nVpisven
aTotVen[1,7] += nVcofven
aTotVen[1,8] += nVcusven
aTotVen[1,9] += nVlucbru
aTotVen[1,10]+= nVprzmd1
aTotVen[1,11]+= nVprzmd2
aTotVen[1,12]+= nVjurest
aTotVen[1,13]+= nVtotdes
aTotVen[1,14]+= nVcomven
aTotVen[1,15]+= nVlucliq
aTotVen[1,16]+= nVdesfix
aTotVen[1,17]+= nVresult
////////// GRUPO //////////
aTotVen[nTipo,2] += nVtotven
aTotVen[nTipo,3] += nVimpven
aTotVen[nTipo,4] += nVicmven
aTotVen[nTipo,5] += nVissven
aTotVen[nTipo,6] += nVpisven
aTotVen[nTipo,7] += nVcofven
aTotVen[nTipo,8] += nVcusven
aTotVen[nTipo,9] += nVlucbru
aTotVen[nTipo,10]+= nVprzmd1
aTotVen[nTipo,11]+= nVprzmd2
aTotVen[nTipo,12]+= nVjurest
aTotVen[nTipo,13]+= nVtotdes
aTotVen[nTipo,14]+= nVcomven
aTotVen[nTipo,15]+= nVlucliq
aTotVen[nTipo,16]+= nVdesfix
aTotVen[nTipo,17]+= nVresult
///////// OFICINA /////////
If nTipo == 4
	If cTipo == "3OFP"
		nTipo := 5
	Else // cTipo == "3OFS"
		nTipo := 6
	EndIf
	aTotVen[nTipo,2] += nVtotven
	aTotVen[nTipo,3] += nVimpven
	aTotVen[nTipo,4] += nVicmven
	aTotVen[nTipo,5] += nVissven
	aTotVen[nTipo,6] += nVpisven
	aTotVen[nTipo,7] += nVcofven
	aTotVen[nTipo,8] += nVcusven
	aTotVen[nTipo,9] += nVlucbru
	aTotVen[nTipo,10]+= nVprzmd1
	aTotVen[nTipo,11]+= nVprzmd2
	aTotVen[nTipo,12]+= nVjurest
	aTotVen[nTipo,13]+= nVtotdes
	aTotVen[nTipo,14]+= nVcomven
	aTotVen[nTipo,15]+= nVlucliq
	aTotVen[nTipo,16]+= nVdesfix
	aTotVen[nTipo,17]+= nVresult
	nTipo := 4
EndIf

If MV_PAR05 >= 3
	nVtotven := nVimpven := nVicmven := nVissven := 0
	nVpisven := nVcofven := nVcusven := nVlucbru := 0
	nVprzmd1 := nVprzmd2 := nVjurest := nVtotdes := 0
	nVcomven := nVlucliq := nVdesfix := nVresult := 0
	na := 1
	nk := 1
EndIf

Return