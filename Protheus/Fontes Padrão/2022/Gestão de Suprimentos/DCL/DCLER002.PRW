#INCLUDE "rwmake.ch"   

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLER002()
Relatorio de Saidas Diarias por Local
Adaptação da função TDCER002
@author Antonio Cordeiro
@since 01/12/1999
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLER002()
Local aStruc	:= {}
Local aTam		:= {} 
Local oTempTable

//Salva a integridade dos Arqquivos. //Define variaveis
Private _cArea    := Alias()
Private _nRec     := Recno()
Private _cInd     := IndexOrd()
Private nLinha    :=66
Private nDev20G   :=0
Private nDevFis   :=0
Private nTSaiFis  :=0
Private nTDevFis  :=0
Private nTLiqFis  :=0
Private nTSai20G  :=0
Private nTDev20G  :=0
Private nTLiq20G  :=0
Private nTamanho  := "M"
Private nLimite   := 132
Private cDesc1    := PadC("Este programa tem como objetivo imprimir o relatorio de   ",74)
Private cDesc2    := PadC("quantidades de saidas conforme dia informado.             ",74)
Private cDesc3    := PadC("Especifico                                                ",74)
Private wnrel     :="CER002"
Private _cPerg    :="CER002"
Private nomeprog  := "TDCER002"
Private nLastkey  :=  0
Private cString   := "SD2"
Private lContinua := .T.
Private _aRegs    :={}
Private cTitulo   := PadC("Estoque por Cessionario",74)
Private ctitulo2  := "Posicao de Saidas por Cessionaria na data de: "
Private Cabec1    :="                                                 |      F I S C A L   ( LITROS )        |          20 G R A U S  ( LITROS )        |"
Private cabec2    :="Local                 Produto                    |     SAIDA      DEVOLUCAO    LIQUIDO  |     SAIDA       DEVOLUCAO      LIQUIDO   |"
Private cLocal    :=""
Private aTotPro   :={}
Private m_pag:=   1
Private aReturn   := {"Branco",1,"Comercial",2,2,1,"",1}

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

//                 XX-XXXXXXXXXXXXXXXXX  XXXX - XXXXXXXXXXXXXXXXXXXX 999,999,999  999,999,999  999,999,999   999,999,999   999,999,999    999,999,999
//1  4                  23     30                   51           64           77            91            105            120

pergunte(_cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,wnrel,_cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.F.,nTamanho,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif

AaDd(aStruc,{ "FILIAL"			, "C" , 2,0 })
aTam := TamSX3("B2_COD")
AaDd(aStruc,{ "COD" , "C"		, aTam[1],aTam[2] })
aTam := TamSX3("B2_LOCAL")
AaDd(aStruc,{ "LOCAL1" , "C"	, aTam[1],aTam[2] })
aTam := TamSX3("D2_EMISSAO")
AaDd(aStruc,{ "EMISSAO" , "D"	, aTam[1],aTam[2] })
aTam := TamSX3("D2_QUANT")
AaDd(aStruc,{ "SAIDAS" , "N"	, aTam[1],aTam[2] })
AaDd(aStruc,{ "EQUALI" , "N"	, aTam[1],aTam[2] })

_cArqTrb := GetNextAlias()

oTempTable := FWTemporaryTable():New( "TRBDCL" )
oTempTable:SetFields(aStruc)
oTempTable:AddIndex("Ind01", {"LOCAL1","COD"} ) 
oTempTable:Create()

RptStatus({|| RptDetail()})

oTempTable:Delete()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RptDetail()
@author Antonio Cordeiro
@since 01/12/1999
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RptDetail()
Local I:=0

	DBSELECTAREA("SD2")
	DBSETORDER(5)
	DBSEEK(XFILIAL()+DTOS(MV_PAR01 - 5),.T.)
	SetRegua(RecCount())
	While ! Eof() .AND. xFilial("SD2") == SD2->D2_FILIAL .AND. SD2->D2_EMISSAO <= (MV_PAR01)
		
		IncRegua()
		
		IF SD2->D2_LOCAL < MV_PAR02  .OR. SD2->D2_LOCAL > MV_PAR03
			DBSKIP()
			LOOP
		ENDIF
		
		IF SD2->D2_COD < MV_PAR04 .OR.  SD2->D2_COD > MV_PAR05
			DBSKIP()
			LOOP
		ENDIF
		
		DbSelectArea("SF2")
		DbSetOrder(1)
		DbSeek(xFilial()+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
		IF SF2->F2_EMISSAO <> MV_PAR01 .AND. SF2->F2_EMISSAO <> MV_PAR01
			DbSelectArea("SD2")
			DbSkip()
			Loop
		Endif
		
		SB1->(DBSEEK(XFILIAL()+SD2->D2_COD))
		IF SF4->(DBSEEK(XFILIAL()+SD2->D2_TES)) .AND. SF4->F4_ESTOQUE=='S'
		ELSE
			DBSELECTAREA("SD2")
			DBSKIP()
			LOOP
		ENDIF
		
		DbSelectArea("DH3")
		DH3->(DbSetorder(1))
		DH3->(DbSeek(xFilial("DH3") + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)))
		
		DbSelectArea("DH5")
		DH5->(DbSetorder(1))
		DH5->(DbSeek(xFilial("DH5") + SB1->B1_COD))
		
		IF DH5->DH5_PREQUI <> "S"
		
			//PRODUTO NAO COMPOSTO POR ESTRUTURA
			DBSELECTAREA("TRBDCL")
			IF ! DBSEEK(SD2->D2_LOCAL+SD2->D2_COD)
				RECLOCK("TRBDCL",.T.)
				TRBDCL->COD    :=SD2->D2_COD
				TRBDCL->EMISSAO:=SD2->D2_EMISSAO
				TRBDCL->LOCAL1 :=SD2->D2_LOCAL
				TRBDCL->SAIDAS :=SD2->D2_QUANT
				IF ! EMPTY(SF2->F2_EMISSAO)
					TRBDCL->EQUALI := DH3->DH3_QTD1
				ENDIF
			ELSE
				RECLOCK("TRBDCL",.F.)
				TRBDCL->SAIDAS:=TRBDCL->SAIDAS + SD2->D2_QUANT
				IF ! EMPTY(SF2->F2_EMISSAO)
					TRBDCL->EQUALI:=TRBDCL->EQUALI + DH3->DH3_QTD1
				ENDIF
			ENDIF
		ELSE
			
			// PRODUTO COMPOSTO  POR ESTRUTURA
			DBSELECTAREA("SG1")
			SG1->(DbSetOrder(5))//G1_FILIAL+G1_COD+DTOS(G1_FIM)+G1_TRT
			SG1->(DBSEEK(XFILIAL()+SD2->D2_COD+DTOS(SD2->D2_EMISSAO),.T.))
			dFim:=SG1->G1_FIM
			WHILE SD2->D2_COD == SG1->G1_COD .AND. ! EOF() .AND. dFim == SG1->G1_FIM
				DBSELECTAREA("TRBDCL")
				_SEQ:=SUBSTR(SG1->G1_TRT,3,1)
				_QTD := "DH3->DH3_QTD1" + _SEQ
				DBSELECTAREA("TRBDCL")
				IF ! DBSEEK(SD2->D2_LOCAL+SG1->G1_COMP)
					RECLOCK("TRBDCL",.T.)
					TRBDCL->COD		:= SG1->G1_COMP
					TRBDCL->EMISSAO	:= SD2->D2_EMISSAO
					TRBDCL->LOCAL1	:= SD2->D2_LOCAL
					TRBDCL->SAIDAS	:= SD2->D2_QUANT * SG1->G1_QUANT
					IF ! EMPTY(SF2->F2_EMISSAO)
						TRBDCL->EQUALI:=&(_QTD)
					ENDIF
				ELSE
					RECLOCK("TRBDCL",.F.)
					TRBDCL->SAIDAS:=TRBDCL->SAIDAS + SD2->D2_QUANT*SG1->G1_QUANT
					IF ! EMPTY(SF2->F2_EMISSAO)
						TRBDCL->EQUALI:=TRBDCL->EQUALI+&(_QTD)
					ENDIF
				ENDIF
				MSUNLOCK()
				DBSELECTAREA("SG1")
				DBSKIP()
			ENDDO
		ENDIF
		DBSELECTAREA("SD2")
		DBSKIP()
	ENDDO
	
	DBSELECTAREA("TRBDCL")
	DBGOTOP()
	ctitulo2  := "Posicao de Saidas por Cessionaria na data de: "+DTOC(MV_PAR01)
	WHILE ! EOF()
		
		If nLinha > 60
			nLinha :=1
			cabec(ctitulo2,cabec1,cabec2,nomeprog,ntamanho)
			nLinha:=nLinha+8
		EndIf
		DBSELECTAREA("TRBDCL")
		@ nLinha,00 PSAY TRBDCL->LOCAL1+"-"+IIF(D35->(DBSEEK(XFILIAL()+TRBDCL->LOCAL1)),D35->D35_NREDUZ,"")
		cLocal:=TRBDCL->LOCAL1
		WHILE cLocal == TRBDCL->LOCAL1 .AND. ! EOF()
			DBSELECTAREA("SD1")
			DBSETORDER(7)
			IF DBSEEK(XFILIAL()+TRBDCL->COD+TRBDCL->LOCAL1+DTOS(MV_PAR01))
				WHILE TRBDCL->COD == SD1->D1_COD .AND. TRBDCL->LOCAL1 == SD1->D1_LOCAL .AND. SD1->D1_DTDIGIT == MV_PAR01
					IF SD1->D1_TIPO == "D"
						nDevFis:=nDevFis + SD1->D1_QUANT
						IF SD1->D1_X_ATUTQ=='S'
							nDev20G := nDev20g + DH3->DH3_QTD1
						ENDIF
					ENDIF
					DBSKIP()
				ENDDO
			ENDIF
			
			If nlinha > 60
				nlinha :=1
				cabec(ctitulo2,cabec1,cabec2,nomeprog,ntamanho)
				nLinha:=nLinha+1
				@LI,00 PSAY TRBDCL->LOCAL1+"-"+IIF(D35->(DBSEEK(XFILIAL()+TRBDCL->LOCAL1)),D35->D35_NREDUZ,"")
			EndIf
			SB1->(DBSEEK(XFILIAL()+TRBDCL->COD))
			
			@nLinha,023 PSAY ALLTRIM(SUBSTR(TRBDCL->COD,1,4))+" - "+substr(SB1->B1_DESC,1,20)
			
			@nLinha,051 PSAY TRBDCL->SAIDAS  PICTURE "@E 999,999,999"
			@nLinha,064 PSAY nDevFis       PICTURE "@E 999,999,999"
			@nLinha,077 PSAY (TRBDCL->SAIDAS-nDevFis) PICTURE "@E 999,999,999"
			
			@nLinha,091 PSAY TRBDCL->EQUALI PICTURE "@E 999,999,999"
			@nLinha,105 PSAY nDev20G       PICTURE "@E 999,999,999"
			@nLinha,120 PSAY (TRBDCL->EQUALI-nDev20G) PICTURE "@E 999,999,999"
			
			nPos := aScan(aTotPro,{ |X| X[1] == TRBDCL->COD })
			if nPos == 0
				Aadd(aTotPro,{TRBDCL->COD,SB1->B1_DESC,TRBDCL->SAIDAS,nDevFis,(TRBDCL->SAIDAS-nDevFis),TRBDCL->EQUALI,nDev20G,(TRBDCL->EQUALI-nDev20G)})
			else
				aTotPro[nPos,3] := aTotPro[nPos,3] + TRBDCL->SAIDAS
				aTotPro[nPos,4] := aTotPro[nPos,4] + nDevFis
				aTotPro[nPos,5] := aTotPro[nPos,5] + (TRBDCL->SAIDAS-nDevFis)
				aTotPro[nPos,6] := aTotPro[nPos,6] + TRBDCL->EQUALI
				aTotPro[nPos,7] := aTotPro[nPos,7] + nDev20G
				aTotPro[nPos,8] := aTotPro[nPos,8] + (TRBDCL->EQUALI-nDev20G)
			Endif
			nDevFis:=0
			nDev20g:=0
			DBSELECTAREA("TRBDCL")
			DBSKIP()
			nLinha:=nLinha+1
		ENDDO
		nLinha:=nLinha+2
	ENDDO
	If nLinha > 55
		nLinha :=1
		cabec(ctitulo2,cabec1,cabec2,nomeprog,ntamanho)
		nLinha:=nLinha+1
	EndIf
	
	@nLinha,000 PSAY "Totais dos Produtos"
	for i:=1 to len(aTotPro)
		@nlinha,023 PSAY ALLTRIM(SUBSTR(aTotPro[i,1],1,04))+" - "+ALLTRIM(SUBSTR(aTotPro[i,2],1,20))
		@nlinha,051 PSAY aTotPro[i,3] PICTURE "@E 999,999,999"
		@nlinha,064 PSAY aTotPro[i,4] PICTURE "@E 999,999,999"
		@nlinha,077 PSAY aTotPro[i,5] PICTURE "@E 999,999,999"
		@nlinha,091 PSAY aTotPro[i,6] PICTURE "@E 999,999,999"
		@nlinha,105 PSAY aTotPro[i,7] PICTURE "@E 999,999,999"
		@nlinha,120 PSAY aTotPro[i,8] PICTURE "@E 999,999,999"
		
		nLinha:=nLinha+1
		nTSaiFis:=nTSaiFis+aTotPro[i,3]
		nTDevFis:=nTDevFis+aTotPro[i,4]
		nTLiqFis:=nTLiqFis+aTotPro[i,5]
		nTSai20G:=nTSai20G+aTotPro[i,6]
		nTDev20G:=nTDev20G+aTotPro[i,7]
		nTLiq20G:=nTLiq20G+aTotPro[i,8]
		
	next
	nLinha:=nLinha+1
	
	@nLinha,023 PSAY "TOTAL GERAL"
	@nLinha,051 PSAY nTSaiFis  PICTURE "@E 999,999,999"
	@nLinha,064 PSAY nTDevFis  PICTURE "@E 999,999,999"
	@nLinha,077 PSAY nTLiqFis  PICTURE "@E 999,999,999"
	@nLinha,091 PSAY nTSai20G PICTURE "@E 999,999,999"
	@nLinha,105 PSAY nTDev20G  PICTURE "@E 999,999,999"
	@nLinha,120 PSAY nTLiq20G  PICTURE "@E 999,999,999"
	
	Roda(0," ",nTamanho)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta arquivos temporarios e Retorna Indices   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Set device to Screen
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se em disco, desvia para Spool                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif
	ms_flush()
	
	dbSelectArea(_cArea)
	dbSetOrder(_cInd)
	dbGoto(_nRec)

RETURN

