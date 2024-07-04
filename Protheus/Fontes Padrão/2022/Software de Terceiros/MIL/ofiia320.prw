// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 05     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.Ch"
#Include "OFIIA320.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ofiia320 ³ Autor ³ Luis Delorme          ³ Data ³ 08/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ CORES - Notas Fiscais de Servico - CONCESSIONARIA          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OFIIA320()

Private cPerg   :="OFI320"
Private aRotina := { 	{ STR0002 ,"axPesqui", 0 , 1},;
{ STR0003 ,"FS_IMPOFIIA320", 0 , 3 }}  //IMPORTA
Private aImpVetor := {}                                           
Private aVetCon   := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ValidPerg()

if !PERGUNTE("OFI320",.T.)
	return
endif

dbSelectArea("VIP")
dbSetOrder(1)

mBrowse( 6, 1,22,75,"VIP")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_IMPOFIIA320| Autor ³ Luis Delorme      ³ Data ³ 08/10/03 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FS_IMPOFIIA320()
/////////////////////////

Local cAliasSF2  := "SQLSF2"
Local cPrefOFI   := GetNewPar("MV_PREFOFI","OFI")

aVetCon := {}
aImpVetor := {} 

nLin  := 0
m_pag := 1

titulo:= STR0001
cabec1:= ""
cabec2:= ""

//DBSelectArea("SF2")
//DBSetOrder(5)//CUSTOMIZADO
//DBSeek(xFilial("SF2")+dtos(mv_par01),.t.)

aErros = {}
DBSelectArea("VOO")
DBSetOrder(4) // FILIAL + NUMNFI + SERIE
DBSelectArea("VOI")
DBSetOrder(1) // FILIAL + TIPTEM
DBSelectArea("VS1")
DBSetOrder(3) // FILIAL + NUMNFI + SERIE
DBSelectArea("VE4")
DBSetOrder(1) // O UNICO
DBSeek(xFilial("VE4"))
DBSelectArea("VS3")
DBSetOrder(1)
DBSelectArea("SA1")
DBSetOrder(1) // FILIAL + CODIGO
DBSelectArea("VG6")
DBSetOrder(5)
DBSelectArea("VG8")
DBSetOrder(1) // FILIAL + CODFAB + NUMOSV
DBSelectArea("VO1")
DBSetOrder(1) // FILIAL + NOMOSV
DbSelectArea("VV1")
DBSetOrder(1) // FILIAL + CHAINT
DBSelectArea("VO4")
DBSetOrder(7) // FILIAL + NUMNFI + SERIE
DBSelectArea("VO3")
DBSetOrder(5) // FILIAL + NUMNOT + SERIE
DBSelectArea("SD2")
DBSetOrder(3) // FILIAL + CODIGO
DBSelectArea("VIP")
DBSetOrder(1) // FILIAL + NUMNFI
DBGoTop()

if mv_par03 == 1
	while !(VIP->(EOF())) .and. VIP->VIP_FILIAL == xFilial("VIP")
		if VIP->VIP_TRANSM # "S"
			DBSelectArea("VIQ")
			DBSetOrder(1)
			DBSeek(xFilial("VIQ")+VIP->VIP_NUMNFI+ VIP->VIP_SERNFI)
			while !eof() .and. xFilial("VIQ") + VIP->VIP_SERNFI + VIP->VIP_NUMNFI == VIQ->VIQ_FILIAL+ VIQ->VIQ_SERNFI +VIQ->VIQ_NUMNFI
				RecLock("VIQ",.F.)
				VIQ->VIQ_TRANSM :="S"
				msunlock()
				DBSkip()
			enddo
			DBSelectArea("VIP")
			RecLock("VIP",.F.)
			VIP->VIP_TRANSM :="S"
			msunlock()
		endif
		DBSkip()
	enddo
endif

cTipNot := ""
cStatNot := "NF"

DBSelectArea("SF2")
DbSetOrder(1) //CUSTOMIZADO

cQuery := "SELECT SF2.F2_DOC,SF2.F2_VALICM,SF2.F2_SERIE,SF2.F2_EMISSAO,SF2.F2_TIPO ,SF2.F2_COND,SF2.F2_VEND1,SF2.F2_PREFIXO,SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_ICMSRET,SF2.F2_VALISS,SF2.F2_PREFORI,SF2.F2_VALBRUT,SF2.F2_BASEISS "
cQuery += "FROM "
cQuery += RetSqlName( "SF2" ) + " SF2 "
cQuery += "WHERE "
cQuery += "SF2.F2_FILIAL='"+ xFilial("SF2")+ "' AND SF2.F2_EMISSAO >= '"+dtos(mv_par01)+"' AND SF2.F2_EMISSAO <= '"+dtos(mv_par02)+"' AND "
cQuery += "SF2.F2_PREFORI = '"+cPrefOFI+"' AND "
cQuery += "SF2.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSF2, .T., .T. )


While !((cAliasSF2)->(Eof()))
	
	lProblema := .f.
	cOBS := "OK !"
	DBSelectArea("VOO")
	
	if DBSeek(xFilial("VOO") + (cAliasSF2)->F2_DOC + (cAliasSF2)->F2_SERIE)
		
		DBSelectArea("VOI")
		DBSeek(xFilial("VOI") + VOO->VOO_TIPTEM)
		
		if VOI->VOI_SITTPO == "2"  //GARANTIA OU CONTRATO
			
			DBSelectArea("VG6")
			DBSetOrder(1)
			DBSeek(xFilial("VG6")+VE4->VE4_PREFAB+VOO->VOO_NUMOSV)
			while !eof() .and.;
				xFilial("VG6")+VOO->VOO_NUMOSV==VG6->VG6_FILIAL+VG6->VG6_NUMOSV .and.;
				VG6->VG6_LIBVOO # VOO->VOO_LIBVOO   //VG6->VG6_TIPTEM # VOO->VOO_TIPTEM
				DBSkip()
				loop
			enddo
			
			if (VG6->VG6_TIPTEM # VOO->VOO_TIPTEM)
				dbSelectArea(cAliasSF2)
				DBSkip()
				Loop
			endif
			
			if Empty(VG6->VG6_NUMRRC)
				lProblema := .t.
				cOBS := STR0004
			endif
			
			if !lProblema
				DBSelectArea("VG8")
				DBSetOrder(1)
				DBSeek(xFilial("VG8")+VE4->VE4_PREFAB+VOO->VOO_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC)
				
				if !(VG8_TIPONF $  "1/2") //!(VG8_TIPONF $  "2/3")
					dbSelectArea(cAliasSF2)
					DBSkip()
					Loop
				endif
				
				IF VG8->VG8_TIPONF =="1"
					cTipNot :="NCG"    //GARANTIA //NCAM
				elseif VG8->VG8_TIPONF =="2"
					cTipNot :="NRM"    //CONTRATO
				else
					cTipNot := "NCAM"  //ACORDO
				endif
				
				cCodMar := VG8->VG8_CODMAR
			endif
			
			DBSelectArea("VO1")
			DBSeek(xFilial("VO1")+VOO->VOO_NUMOSV)
			DBSelectArea("VV1")
			DBSeek(xFilial("VV1")+VO1->VO1_CHAINT)
			DBSelectArea("SA1")
			DBSeek(xFilial("SA1")+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
			
			//=====================
			//ESTA TUDO POSICIONADO -- GRAVA NO VIP
			//=====================
			// se o cliente for a fabrica entao so vai o servico senao vai so as pecas
			
			vAccPeca := 0
			vAccServ := 0
			vAccICM  := 0
			vAccISS  := 0
			
			if VE4->VE4_CODFAB == SA1->A1_COD
				
				if !(lProblema)
					if Empty(VG8->VG8_DATCRE)
						lProblema := .t.
						cOBS := STR0005
					endif
					if Empty(VG8->VG8_NFCRED)
						lProblema := .t.
						cOBS := STR0006
					endif
				endif
				
				nICMSCon := 0                  //colocado em 08/08/07
				DBSelectArea("SD2")
				DBSetOrder(3)
				DBSeek(xFilial("SD2") + (cAliasSF2)->F2_DOC + (cAliasSF2)->F2_SERIE)
				
				while !eof().and.xFilial("SD2")+(cAliasSF2)->F2_DOC+ (cAliasSF2)->F2_SERIE==SD2->D2_FILIAL+SD2->D2_DOC+ SD2->D2_SERIE
					
					DBSelectArea("SF4")
					DBSetOrder(1)
					DBSeek(xFilial("SF4")+SD2->D2_TES)
					if SF4->F4_CREDICM == "S"
						if SD2->D2_BASEISS == 0
							nICMSCon += SD2->D2_VALICM
						endif
					Endif
					dbSelectArea("SD2")
					dbSkip()
					
				Enddo
				
				aadd(aImpVetor,{ (cAliasSF2)->F2_SERIE , (cAliasSF2)->F2_DOC , stod((cAliasSF2)->F2_EMISSAO) , VG8->VG8_DATCRE,;
				SA1->A1_NOME,VG6->VG6_NUMRRC,VG6->VG6_ANORRC,VV1->VV1_CHASSI,VV1->VV1_NUMMOT,;
				(cAliasSF2)->F2_VALBRUT,nICMSCon,(cAliasSF2)->F2_VALISS,VG8->VG8_NFCRED,"","",0,cTipNot,cOBS})
				
				if mv_par03 == 1 .and. !(lProblema)
					
					DBSelectArea("VIP")
					dbSetOrder(1)
					dbSeek(xFilial("VIP")+(cAliasSF2)->F2_DOC+ (cAliasSF2)->F2_SERIE)
					RecLock("VIP",!Found())
					VIP->VIP_TRANSM := "N"
					VIP->VIP_FILIAL := xFilial("VIP")
					VIP->VIP_CODCON := VE4->VE4_CODCON
					VIP->VIP_NUMNFI := (cAliasSF2)->F2_DOC
					VIP->VIP_SERNFI := (cAliasSF2)->F2_SERIE
					if FieldPos("VIP_SDOC") > 0
						VIP->VIP_SDOC := FGX_UFSNF((cAliasSF2)->F2_SERIE)
					endif
					VIP->VIP_DATEMI := stod((cAliasSF2)->F2_EMISSAO)
					VIP->VIP_DTCRED := VG8->VG8_DATCRE
					VIP->VIP_CGC    := SA1->A1_CGC
					VIP->VIP_NOME   := SA1->A1_NOME
					VIP->VIP_ANORRC := VG6->VG6_ANORRC // crra
					VIP->VIP_NUMRRC := VG6->VG6_NUMRRC // crr
					VIP->VIP_CHASSI := VV1->VV1_CHASSI
					VIP->VIP_NUMMOT := VV1->VV1_NUMMOT
					VIP->VIP_VALBRU := (cAliasSF2)->F2_VALBRUT // vAccServ
					VIP->VIP_VALICM := nICMSCon
					VIP->VIP_VALISS := (cAliasSF2)->F2_VALISS // vAccISS
					VIP->VIP_STATUS := cStatNot
					VIP->VIP_TIPNOT := cTipNot
					VIP->VIP_NFCRED := VG8->VG8_NFCRED
					if (cAliasSF2)->F2_BASEISS == 0
						VIP->VIP_TIPSEG := "NFP"
					else
						VIP->VIP_TIPSEG := "NFS"
					endif
					MsUnlock()
					DBSelectArea("SD2")
					DBSetOrder(3)
					DBSeek(XFilial("SD2")+(cAliasSF2)->F2_DOC+ (cAliasSF2)->F2_SERIE)
					while !eof().and.XFilial("SD2")+(cAliasSF2)->F2_DOC+ (cAliasSF2)->F2_SERIE ==SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE
						DBSelectArea("SB1")
						DBSetOrder(1)
						DBSeek(xFilial("SB1")+SD2->D2_COD)
						DBSelectArea("VIQ")
						dbSetOrder(1)
						dbSeek(xFilial("VIQ")+(cAliasSF2)->F2_DOC+ (cAliasSF2)->F2_SERIE+SB1->B1_CODITE)
						RecLock("VIQ",!Found())
						VIQ->VIQ_FILIAL := xFilial("VIQ")
						VIQ->VIQ_TRANSM :="N"
						VIQ->VIQ_CANCEL:="N"
						VIQ->VIQ_NUMNFI := (cAliasSF2)->F2_DOC
						VIQ->VIQ_SERNFI := (cAliasSF2)->F2_SERIE
						if FieldPos("VIQ_SDOC") > 0
							VIQ->VIQ_SDOC := FGX_UFSNF((cAliasSF2)->F2_SERIE)
						endif
						VIQ->VIQ_NUMSEQ := SD2->D2_ITEM
						VIQ->VIQ_CFOP   := SD2->D2_CF
						VIQ->VIQ_CODITE := SB1->B1_CODITE
						VIQ->VIQ_DESITE := SB1->B1_DESC
						VIQ->VIQ_QUANT  := SD2->D2_QUANT
						VIQ->VIQ_VALUNI := SD2->D2_PRCVEN
						VIQ->VIQ_VALTOT := SD2->D2_TOTAL
						if (cAliasSF2)->F2_BASEISS == 0 .and. nICMSCon > 0
							VIQ->VIQ_ALIICM := SD2->D2_PICM
							VIQ->VIQ_BASICM := SD2->D2_BASEICM
						else
							VIQ->VIQ_ALIICM := 0
							VIQ->VIQ_BASICM := 0
						endif
						VIQ->VIQ_BASISS := SD2->D2_BASEISS
						VIQ->VIQ_ALIISS := SD2->D2_ALIQISS
						VIQ->VIQ_ICMSUB := SD2->D2_ICMSRET
						msunlock()
						DBSelectArea("SD2")
						DBSkip()
					enddo
				endif // mv_par03 == 1 .and lproblema
			else
				// se o cliente nao eh a fabrica , vao as pecas
				// caso nao tenha sido importada a RR vamos buscar as pecas
				// no SD2 pelo VG6
				// faz o loop no vg8 para cada O.S. da nota
				if !(lProblema)
					IF VG8->VG8_TIPONF =="1"
						cTipNot :="NCG"    //GARANTIA //NCAM
					elseif VG8->VG8_TIPONF =="2"
						cTipNot :="NRM"    //CONTRATO
					else
						cTipNot := "NCAM"  //ACORDO
					endif
				endif
				//			VG6->(DBSetOrder(5))
				//			if VG6->(DBSeek(xFilial("VG6")+VG8->VG8_CODMAR+VG8->VG8_NUMOSV+VG8->VG8_ANORRC+VG8->VG8_NUMRRC))
				if !(lProblema)
					if Empty(VG8->VG8_DATCRE)
						lProblema := .t.
						cOBS := STR0005
					endif
					if Empty(VG8->VG8_NFCRED)
						lProblema := .t.
						cOBS := STR0006
					endif
				endif
				
				if VG8->VG8_TIPONF !="1"
					nISSCon := (cAliasSF2)->F2_VALISS
				else
					nISSCon := 0
				endif
				
				DBSelectArea("SD2")
				DBSetOrder(3)
				DBSeek(xFilial("SD2") + (cAliasSF2)->F2_DOC + (cAliasSF2)->F2_SERIE)
				nIcms := 0
				while !eof() .AND. xFilial("SD2") + (cAliasSF2)->F2_DOC + (cAliasSF2)->F2_SERIE == SD2->D2_FILIAL + SD2->D2_DOC +  SD2->D2_SERIE
					
					DBSelectArea("SF4")
					DBSetOrder(1)
					DBSeek(xFilial("SF4")+SD1->D1_TES)
					if SF4->F4_CREDICM == "S"
						if SD2->D2_BASEISS == 0
							nIcms += SD2->D2_VALICM
						endif
					Endif
					dbSelectArea("SD2")
					dbSkip()
				Enddo
				aadd(aImpVetor,{ (cAliasSF2)->F2_SERIE , (cAliasSF2)->F2_DOC , stod((cAliasSF2)->F2_EMISSAO) , VG8->VG8_DATCRE,;
				SA1->A1_NOME,VG6->VG6_NUMRRC,VG6->VG6_ANORRC,VV1->VV1_CHASSI,VV1->VV1_NUMMOT,;
				(cAliasSF2)->F2_VALBRUT,nIcms,nISSCon,VG8->VG8_NFCRED,"","",0,cTipNot,cOBS})
				if mv_par03 == 1 .and. !lProblema
					DBSelectArea("VIP")
					dbSetOrder(1)
					dbSeek(xFilial("VIP")+(cAliasSF2)->F2_DOC+ (cAliasSF2)->F2_SERIE )
					RecLock("VIP",!Found())
					VIP->VIP_TRANSM := "N"
					VIP->VIP_FILIAL := xFilial("VIP")
					VIP->VIP_CODCON := VE4->VE4_CODCON
					VIP->VIP_NUMNFI := (cAliasSF2)->F2_DOC
					VIP->VIP_SERNFI := (cAliasSF2)->F2_SERIE
					if fieldpos("VIP_SDOCNF") > 0
						VIP->VIP_SDOCNF := FGX_UFSNF((cAliasSF2)->F2_SERIE)
					endif
					VIP->VIP_DATEMI := stod((cAliasSF2)->F2_EMISSAO)
					VIP->VIP_DTCRED := VG8->VG8_DATCRE
					VIP->VIP_CGC    := SA1->A1_CGC
					VIP->VIP_NOME   := SA1->A1_NOME
					VIP->VIP_ANORRC := VG8->VG8_ANORRC
					VIP->VIP_NUMRRC := VG8->VG8_NUMRRC
					VIP->VIP_CHASSI := VV1->VV1_CHASSI
					VIP->VIP_NUMMOT := VV1->VV1_NUMMOT
					VIP->VIP_VALBRU := (cAliasSF2)->F2_VALBRUT
					VIP->VIP_VALICM := nIcms
					VIP->VIP_VALISS := nISSCon
					VIP->VIP_STATUS := cStatNot
					VIP->VIP_TIPNOT := cTipNot
					VIP->VIP_NFCRED := VG8->VG8_NFCRED
					if (cAliasSF2)->F2_BASEISS == 0
						VIP->VIP_TIPSEG := "NFP"
					else
						VIP->VIP_TIPSEG := "NFS"
					endif
					MsUnlock()
					DBSelectArea("SD2")
					DBSetOrder(3)
					DBSeek(XFilial("SD2") + (cAliasSF2)->F2_DOC + (cAliasSF2)->F2_SERIE)
					while !eof().and.XFilial("SD2")+(cAliasSF2)->F2_DOC+ (cAliasSF2)->F2_SERIE ==SD2->D2_FILIAL+SD2->D2_DOC+ SD2->D2_SERIE
						DBSelectArea("SB1")
						DBSetOrder(1)
						DBSeek(xFilial("SB1")+SD2->D2_COD)
						DBSelectArea("VIQ")
						dbSetOrder(1)
						dbSeek(xFilial("VIQ")+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+SB1->B1_CODITE)
						RecLock("VIQ",!Found())
						VIQ->VIQ_FILIAL := xFilial("VIQ")
						VIQ->VIQ_TRANSM :="N"
						VIQ->VIQ_CANCEL:="N"
						VIQ->VIQ_NUMNFI := (cAliasSF2)->F2_DOC
						VIQ->VIQ_SERNFI := (cAliasSF2)->F2_SERIE
						if fieldpos("VIQ_SDOC") > 0
							VIQ->VIQ_SDOC := FGX_UFSNF((cAliasSF2)->F2_SERIE)
						endif
						VIQ->VIQ_NUMSEQ := SD2->D2_ITEM
						VIQ->VIQ_CFOP   := SD2->D2_CF
						VIQ->VIQ_CODITE := SB1->B1_CODITE
						VIQ->VIQ_DESITE := SB1->B1_DESC
						VIQ->VIQ_QUANT  := SD2->D2_QUANT
						VIQ->VIQ_VALUNI := SD2->D2_PRCVEN
						VIQ->VIQ_VALTOT := SD2->D2_TOTAL
						if (cAliasSF2)->F2_BASEISS == 0 .and. nIcms > 0
							VIQ->VIQ_ALIICM := SD2->D2_PICM
							VIQ->VIQ_BASICM := SD2->D2_BASEICM
						else
							VIQ->VIQ_ALIICM := 0
							VIQ->VIQ_BASICM := 0
						endif
						VIQ->VIQ_BASISS := SD2->D2_BASEISS
						VIQ->VIQ_ALIISS := SD2->D2_ALIQISS
						VIQ->VIQ_ICMSUB := SD2->D2_ICMSRET
						msunlock()
						DBSelectArea("SD2")
						DBSkip()
					enddo
				endif
				//endif
			endif
			
		elseif VOI->VOI_SITTPO == "4"  //REVISAO OU ACORDO
			
			// pode ser acordo
			DBSelectArea("VGE")
			DBSetOrder(1)
			DBSeek(xFilial("VGE")+VOO->VOO_NUMOSV)
			// posiciona no SA1 para pegar *NOME DO CLIENTE* *CNPJ/CPF*
			DBSelectArea("SA1")
			DBSeek(xFilial("SA1")+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
			// posiciona no VO1 para chegar no VV1 pelo VO1_CHAINT
			DBSelectArea("VO1")
			DBSeek(xFilial("VO1")+VOO->VOO_NUMOSV)
			// posiciona no VV1 para pegar *ANO RECLAMACAO* e *NRO RECLAMACAO*
			DBSelectArea("VV1")
			DBSeek(xFilial("VV1")+VO1->VO1_CHAINT)
			
			if VGE->VGE_TIPONF = "1"
				cTipNot :=  "NCAM"  //ACORDO
			elseif VGE->VGE_TIPONF = "2"
				cTipNot :=  "NCR"   //REVISAO
			endif
			if !(lProblema)
				if Empty(VGE->VGE_DTACRE)
					lProblema := .t.
					cOBS := STR0005
				endif
				if Empty(VGE->VGE_NFCRED)
					lProblema := .t.
					cOBS := STR0006
				endif
			endif
			
			DBSelectArea("SD2")
			DBSetOrder(3)
			DBSeek(xFilial("SD2")+(cAliasSF2)->F2_DOC+ (cAliasSF2)->F2_SERIE)
			nIcms := 0
			while !eof() .AND. xFilial("SD2") + (cAliasSF2)->F2_DOC + (cAliasSF2)->F2_SERIE == SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE
				
				DBSelectArea("SF4")
				DBSetOrder(1)
				DBSeek(xFilial("SF4")+SD1->D1_TES)
				if SF4->F4_CREDICM == "S"
					if SD2->D2_BASEISS == 0
						nIcms += SD2->D2_VALICM
					endif
				Endif
				dbSelectArea("SD2")
				dbSkip()
			Enddo
			aadd(aImpVetor,{ (cAliasSF2)->F2_SERIE , (cAliasSF2)->F2_DOC,stod((cAliasSF2)->F2_EMISSAO),VGE->VGE_DTACRE,;
			SA1->A1_NOME,"","",VV1->VV1_CHASSI,VV1->VV1_NUMMOT,;
			(cAliasSF2)->F2_VALBRUT,nIcms,(cAliasSF2)->F2_VALISS,VGE->VGE_NFCRED,"","",0,cTipNot,cOBS})
			
			if mv_par03 == 1 .and. (!Empty(VGE->VGE_NFCRED) .or. !Empty(VGE->VGE_DTACRE))
				DBSelectArea("VIP")
				dbSetOrder(1)
				dbSeek(xFilial("VIP")+(cAliasSF2)->F2_DOC+ (cAliasSF2)->F2_SERIE)
				RecLock("VIP",!Found())
				VIP->VIP_TRANSM := "N"
				VIP->VIP_FILIAL := xFilial("VIP")
				VIP->VIP_CODCON := VE4->VE4_CODCON
				VIP->VIP_NUMNFI := (cAliasSF2)->F2_DOC
				VIP->VIP_SERNFI := (cAliasSF2)->F2_SERIE
				if fieldpos("VIP_SDOCNF") > 0
					VIP->VIP_SDOCNF := FGX_UFSNF( (cAliasSF2)->F2_SERIE )
				endif
				VIP->VIP_DATEMI := stod((cAliasSF2)->F2_EMISSAO)
				VIP->VIP_DTCRED := VGE->VGE_DTACRE
				VIP->VIP_CGC    := SA1->A1_CGC
				VIP->VIP_NOME   := SA1->A1_NOME
				VIP->VIP_ANORRC := ""
				VIP->VIP_NUMRRC := ""
				VIP->VIP_CHASSI := VV1->VV1_CHASSI
				VIP->VIP_NUMMOT := VV1->VV1_NUMMOT
				VIP->VIP_VALBRU := (cAliasSF2)->F2_VALBRUT
				if (cAliasSF2)->F2_BASEISS == 0  //colocado em 08/08/07, pois estava levando ICMS e ISS
					VIP->VIP_VALICM := nIcms
				endif
				VIP->VIP_VALISS := (cAliasSF2)->F2_VALISS
				VIP->VIP_STATUS := cStatNot
				VIP->VIP_TIPNOT := cTipNot
				VIP->VIP_TIPSEG := "NFS"  //NF SERVICO
				VIP->VIP_NFCRED := VGE->VGE_NFCRED
				MsUnlock()
				DBSelectArea("SD2")
				DBSetOrder(3)
				DBSeek(XFilial("SD2")+(cAliasSF2)->F2_DOC+ (cAliasSF2)->F2_SERIE)
				while !eof().and.XFilial("SD2")+(cAliasSF2)->F2_DOC+ (cAliasSF2)->F2_SERIE == SD2->D2_FILIAL+SD2->D2_DOC+ SD2->D2_SERIE
					DBSelectArea("SB1")
					DBSetOrder(1)
					DBSeek(xFilial("SB1")+SD2->D2_COD)
					DBSelectArea("VIQ")
					dbSetOrder(1)
					dbSeek(xFilial("VIQ")+(cAliasSF2)->F2_DOC+ (cAliasSF2)->F2_SERIE+SB1->B1_CODITE)
					RecLock("VIQ",!Found())
					VIQ->VIQ_FILIAL := xFilial("VIQ")
					VIQ->VIQ_TRANSM :="N"
					VIQ->VIQ_CANCEL:="N"
					VIQ->VIQ_NUMNFI := (cAliasSF2)->F2_DOC
					VIQ->VIQ_SERNFI := (cAliasSF2)->F2_SERIE
					if fieldpos("VIQ_SDOC") > 0
						VIQ->VIQ_SDOC := FGX_UFSNF( (cAliasSF2)->F2_SERIE )
					endif
					VIQ->VIQ_NUMSEQ := SD2->D2_ITEM
					VIQ->VIQ_CFOP   := SD2->D2_CF
					VIQ->VIQ_CODITE := SB1->B1_CODITE
					VIQ->VIQ_DESITE := SB1->B1_DESC
					VIQ->VIQ_QUANT  := SD2->D2_QUANT
					VIQ->VIQ_VALUNI := SD2->D2_PRCVEN
					VIQ->VIQ_VALTOT := SD2->D2_TOTAL
					if (cAliasSF2)->F2_BASEISS == 0 .and. nIcms > 0
						VIQ->VIQ_ALIICM := SD2->D2_PICM
						VIQ->VIQ_BASICM := SD2->D2_BASEICM
					else
						VIQ->VIQ_ALIICM := 0
						VIQ->VIQ_BASICM := 0
					endif
					VIQ->VIQ_BASISS := SD2->D2_BASEISS
					VIQ->VIQ_ALIISS := SD2->D2_ALIQISS
					VIQ->VIQ_ICMSUB := SD2->D2_ICMSRET
					msunlock()
					DBSelectArea("SD2")
					DBSkip()
				enddo
			endif
		else  // se nao eh SITTPO = 2 nem SITTPO = 4
			// essa nota nao serve !!
			DBSelectArea(cAliasSF2)
			DBSkip()
			Loop
		endif
		// se nao existe no VOO
	else
		// se nao existe no VOO pode ser pelo VS1
		DBSelectArea("VS1")
		if DBSeek(xFilial("VS1")+(cAliasSF2)->F2_DOC + (cAliasSF2)->F2_SERIE)
			// se faturou para a fabrica
			if VS1->VS1_CLIFAT == VE4->VE4_CODFAB
				/// posiciona item pelo NUMORC
				DBSelectArea("VS3")
				DBSeek(xFilial("VS3")+VS1->VS1_NUMORC)
				//
				if !Empty(VS3->VS3_FILCOM)
					// essa nota serve !!
					// sera uma nota de credito de comissao
					cTipNot :="NCC" // Nota de Cred. Comissao
					// posiciona no SA1 para pegar *NOME DO CLIENTE* e *CNPJ/CPF*
					DBSelectArea("SA1")
					DBSeek(xFilial("SA1")+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
					//=====================
					//ESTA TUDO POSICIONADO -- GRAVA NO VIP
					//=====================
					DBSelectArea("VIP")
					if !(lProblema)
						if Empty(VG8->VG8_DATCRE)
							lProblema := .t.
							cOBS := STR0005
						endif
						if Empty(VG8->VG8_NFCRED)
							lProblema := .t.
							cOBS := STR0006
						endif
						if Empty(VG6->VG6_NUMRRC)
							lProblema := .t.
							cOBS := STR0004
						endif
					endif
					
					DBSelectArea("SD2")
					DBSetOrder(3)
					DBSeek(xFilial("SD2")+(cAliasSF2)->F2_DOC+  (cAliasSF2)->F2_SERIE)
					nIcms := 0
					while !eof().and.xFilial("SD2")+(cAliasSF2)->F2_DOC+ (cAliasSF2)->F2_SERIE==SD2->D2_FILIAL+SD2->D2_DOC+  SD2->D2_SERIE
						
						DBSelectArea("SF4")
						DBSetOrder(1)
						DBSeek(xFilial("SF4")+SD1->D1_TES)
						if SF4->F4_CREDICM == "S"
							if SD2->D2_BASEISS == 0
								nIcms += SD2->D2_VALICM
							endif
						Endif
						dbSelectArea("SD2")
						dbSkip()
					Enddo
					aadd(aImpVetor,{ (cAliasSF2)->F2_SERIE ,(cAliasSF2)->F2_DOC,stod((cAliasSF2)->F2_EMISSAO),VS1->VS1_DTCRED,;
					SA1->A1_NOME,VG6->VG6_NUMRRC,VG6->VG6_ANORRC,VV1->VV1_CHASSI,VV1->VV1_NUMMOT,;
					(cAliasSF2)->F2_VALBRUT,nIcms,0,VS1->VS1_NFCRED,VS1->VS1_GRUPO,VS1->VS1_COTA,VS1->VS1_IRRF,cTipNot,cOBS})
					
					if mv_par03 == 1
						if DBSeek(xFilial("VIP")+(cAliasSF2)->F2_DOC+VG8->VG8_NUMRRC)
							RecLock("VIP",.F.)
						else
							RecLock("VIP",.T.)
						endif
						VIP->VIP_TRANSM := "N"
						VIP->VIP_FILIAL := xFilial("VIP")
						VIP->VIP_CODCON := VE4->VE4_CODCON
						VIP->VIP_NUMNFI := (cAliasSF2)->F2_DOC
						VIP->VIP_SERNFI := (cAliasSF2)->F2_SERIE
						if fieldpos("VIP_SDOCNF") > 0
							VIP->VIP_SDOCNF := FGX_UFSNF( (cAliasSF2)->F2_SERIE )
						endif
						VIP->VIP_DATEMI := stod((cAliasSF2)->F2_EMISSAO)
						VIP->VIP_CGC    := SA1->A1_CGC
						VIP->VIP_NOME   := SA1->A1_NOME
						VIP->VIP_ANORRC := VG8->VG8_ANORRC
						VIP->VIP_NUMRRC := VG8->VG8_NUMRRC
						VIP->VIP_CHASSI := VV1->VV1_CHASSI
						VIP->VIP_NUMMOT := VV1->VV1_NUMMOT
						VIP->VIP_VALBRU := (cAliasSF2)->F2_VALBRUT
						VIP->VIP_NFCRED := VS1->VS1_NFCRED
						VIP->VIP_NFISCA := VS1->VS1_NFISCA
						VIP->VIP_SERIE  := VS1->VS1_SERIE
						if fieldpos("VIP_SDOC") > 0
							VIP->VIP_SDOC := FGX_UFSNF( VS1->VS1_SERIE )
						endif
						VIP->VIP_GRUPO  := VS1->VS1_GRUPO
						VIP->VIP_COTA   := VS1->VS1_COTA
						VIP->VIP_IRRF   := VS1->VS1_IRRF
						VIP->VIP_DTCRED := VS1->VS1_DTCRED
						VIP->VIP_VALICM := nIcms
						VIP->VIP_VALISS := (cAliasSF2)->F2_VALISS
						VIP->VIP_STATUS := cStatNot
						VIP->VIP_TIPNOT := cTipNot
						VIP->VIP_NFCRED := VG8->VG8_NFCRED
						VIP->VIP_TIPSEG := "NFC"
						
						MsUnlock()
						
						DBSelectArea("SD2")
						DBSetOrder(3)
						DBSeek(XFilial("SD2")+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE)
						while !eof().and.XFilial("SD2") + (cAliasSF2)->F2_DOC + (cAliasSF2)->F2_SERIE== SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE
							DBSelectArea("SB1")
							DBSetOrder(1)
							DBSeek(xFilial("SB1")+SD2->D2_COD)
							DBSelectArea("VIQ")
							DBSetOrder(1)
							DBSeek(xFilial("VIQ")+SD2->D2_DOC+SD2->D2_SERIE+SB1->B1_CODITE)
							RecLock("VIQ",!Found())
							VIQ->VIQ_FILIAL := xFilial("VIQ")
							VIQ->VIQ_TRANSM :="N"
							VIQ->VIQ_CANCEL:="N"
							VIQ->VIQ_NUMNFI := (cAliasSF2)->F2_DOC
							VIQ->VIQ_SERNFI := (cAliasSF2)->F2_SERIE
							if fieldpos("VIQ_SDOC") > 0
								VIQ->VIQ_SDOC := FGX_UFSNF( (cAliasSF2)->F2_SERIE )
							endif
							VIQ->VIQ_NUMSEQ := SD2->D2_ITEM
							VIQ->VIQ_CFOP   := SD2->D2_CF
							VIQ->VIQ_CODITE := SB1->B1_CODITE
							VIQ->VIQ_DESITE := SB1->B1_DESC
							VIQ->VIQ_QUANT  := SD2->D2_QUANT
							VIQ->VIQ_VALUNI := SD2->D2_PRCVEN
							VIQ->VIQ_VALTOT := SD2->D2_TOTAL
							if (cAliasSF2)->F2_BASEISS == 0 .and.nIcms > 0
								VIQ->VIQ_ALIICM := SD2->D2_PICM
								VIQ->VIQ_BASICM := SD2->D2_BASEICM
							else
								VIQ->VIQ_ALIICM := 0
								VIQ->VIQ_BASICM := 0
							endif
							VIQ->VIQ_ALIISS := SD2->D2_ALIQISS
							VIQ->VIQ_BASISS := SD2->D2_BASEISS
							VIQ->VIQ_ICMSUB := SD2->D2_ICMSRET
							msunlock()
							DBSelectArea("SD2")
							DBSkip()
						enddo
					endif
				else
					// essa nota nao serve !!
					DBSelectArea(cAliasSF2)
					DBSkip()
					Loop
				endif
				// se a nota nao for faturada para a fabrica nao serve
			else
				// essa nota nao serve !!
				DBSelectArea(cAliasSF2)
				DBSkip()
				Loop
			endif
			// nao existe no VOO nem no SF2
		else
			// essa nota nao serve !!
			DBSelectArea(cAliasSF2)
			DBSkip()
			Loop
		endif // fim do if que ve se existe no SF2
	endif // fim do if que verifica se existe no VOO
	// se chegou ate aqui eh pq a nota serviu e passou pela funcao
	// seleciona a proxima e da continuidade
	DBSelectArea(cAliasSF2)
	DBSkip()
enddo // loop que varre o SF2

// percorre VIP a procura de canceladas
DBSelectArea("VIP")
DbGoTop()
if mv_par03 == 1
	while !(VIP->(EOF())) .and. VIP->VIP_FILIAL == xFilial("VIP")
		DBSelectArea("SF3")
		DBSetOrder(5)
		if DbSeek(xFilial("SF3") + VIP->VIP_SERNFI + VIP->VIP_NUMNFI)
			if !Empty(SF3->F3_DTCANC).and. VIP->VIP_CANCEL !="S"
				DBSelectArea("VIQ")
				DBSetOrder(1)
				DBSeek(xFilial("VIQ")+VIP->VIP_SERNFI+VIP->VIP_NUMNFI)
				while !eof() .and. xFilial("VIQ")+VIP->VIP_SERNFI+VIP->VIP_NUMNFI == VIQ->VIQ_FILIAL+VIQ->VIQ_SERNFI+VIQ->VIQ_NUMNFI
					RecLock("VIQ",.F.)
					VIQ->VIQ_TRANSM :="N"
					VIQ->VIQ_CANCEL:="S"
					msunlock()
					DBSkip()
				enddo
				DBSelectArea("VIP")
				reclock("VIP",.f.)
				VIP->VIP_CANCEL:="S"
				VIP->VIP_TRANSM:="N"
				msunlock()
			endif
		endif
		DBSelectArea("VIP")
		DBSkip()
	enddo
endif

DbSelectArea(cAliasSF2)
(cAliasSF2)->(DBCloseArea())

FS_GeraTXT()


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFun‡„o    FS_GeraTXT º Autor ³ Luis Delorme       º Data ³  13/07/01   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±³Descri‡„o ³ Gera arquivo TXT									          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GeraTXT()

Private cString     := "VIP"
Private limite      := 80
Private cTamanho    := "P"
Private cnomeprog   := "OFIIA320" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 15
Private aReturn     := { STR0022, 1, STR0023, 1, 2, 1, "", 1}
Private nLastKey    := 0
Private ctitulo     := STR0007
Private _nLin       := 80
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private imprime     := .T.
Private lServer     := .T.
Private cNomRel     := "NFSSCA" // Coloque aqui o nome do arquivo usado para impressao em disco
cAlias := "VIP"

cDesc1 := ""
cDesc2 := ""
cDesc3 := ""

Do While File(__RELDIR+cNomRel+".##R")
	Dele File &(__RELDIR+cNomRel+".##R")
EndDo

cNomRel := SetPrint(cString,cNomRel,nil ,@ctitulo,"","","",.F.,"",.F.,cTamanho,,,,,,)

If nLastKey == 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cAlias)
RptStatus({|lEnd| ImprimeTXT(@lEnd,cNomRel,cAlias)},cTitulo)

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	OurSpool(cNomRel)
Endif

Set Filter To

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFun‡„o    FS_GeraTXT º Autor ³ Luis Delorme       º Data ³  13/07/01   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ºDescricao            º Imprime arquivo TXT							  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ImprimeTXT(lEnd,wNomRel,cAlias)

Local nn := 0
Local lii := 0
Set Printer to &wNomRel
Set Printer On
Set Device  to Printer

Cabec1  := STR0008

Cabec2  :=""


_nLin := 0
For nn := 1 to len (aImpVetor)
	If _nlin > 55 .or. _nLin ==0// Salto de Página. Neste caso o formulario tem 60 linhas...
		Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho,nTipo)
		_nlin := 10
	Endif
	
	@_nLin++,1 psay aImpVetor[nn,2] +"/"+ FGX_UFSNF(aImpVetor[nn,1]) +" " + Left(aImpVetor[nn,5],18) +STR0009+aImpVetor[nn,6]+"/"+aImpVetor[nn,7] +STR0010+aImpVetor[nn,13] +"["+ aImpVetor[nn,17] +"]"
	@_nLin++,1 psay Left(STR0011+AllTrim(aImpVetor[nn,8]) +"/"+	AllTrim(aImpVetor[nn,9])+SPACE(50),50) 	+ STR0012 + Transform(aImpVetor[nn,10], "@E 99,999,999.99")
	@_nLin++,1 psay Left(STR0013+aImpVetor[nn,14]  +"/"+ aImpVetor[nn,15]+SPACE(50),50)	+ STR0014 + Transform(	aImpVetor[nn,16],   "@E 99,999,999.99")
	@_nLin++,1 psay Left(STR0015+ dtoc(aImpVetor[nn,3])+SPACE(50),50)	+ STR0016 + Transform(aImpVetor[nn,11], "@E 99,999,999.99")
	@_nLin++,1 psay Left(STR0017+ dtoc(aImpVetor[nn,4])+SPACE(50),50)	+ STR0018 + Transform(aImpVetor[nn,12], "@E 99,999,999.99")
	@_nLin++,1 psay "**"+aImpVetor[nn,18]
	_nLin++
next

_nLin := 0
For lii = 1 to len(aVetCon)
	If _nlin > 60 .or. _nLin ==0// Salto de Página. Neste caso o formulario tem 60 linhas...
		Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho,nTipo)
		_nlin := 10
	Endif
	@_nLin++,1 psay aVetCon[lii,1]+ "-"+aVetCon[lii,2]+" "+Left(aVetCon[lii,6]+space(7),7)+"/"+Left(aVetCon[lii,7]+space(4),4)+" - "+aVetCon[lii,5]
	
next



Set Printer to
Set Printer off
Set Device  to Screen

return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFun‡„o    ³VALIDPERG º Autor ³ Luis Delorme       º Data ³  13/07/01   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ºFun‡„o    ³Geracao das perguntes									      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg

local _sAlias := Alias()
local aRegs := {}
local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,LEN(SX1->X1_GRUPO))

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01",STR0019,"","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02",STR0020,"","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03",STR0021,"","","mv_ch3","N",1,0,1,"C","","mv_par03","Sim","Si","Yes","","","Nao","No","No","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return

