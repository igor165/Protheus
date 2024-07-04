#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Cat63     ºAutor  ³Andressa Ataides    º Data ³ 05/09/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna valores da tabela SFI de acordo com a Situacao      º±±
±±º          ³Tributaria                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaFis                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Cat63(dDtIni,dDtFim)
                 
Local cAliasSFI := "SFI"
Local cAliasSD2 := "SD2"
Local cProd		:= ""
Local lQuery    := .F.
Local nX        := 0
Local aTrbs     := {}
Local aArq1		:= {"SD1",""}
Local aArq2		:= {"SD2",""}
Local nAliq     := 0

#IFDEF TOP
	Local nSFI := 0
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria arq. temporarios ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTrbs := CriaTrbs()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Registro Tipo 60³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->(LastRec()) > 0
	dbSelectArea(cAliasSFI)
	dbSetOrder(1)
	#IFDEF TOP
	    If TcSrvType()<>"AS/400"
		    cAliasSFI:= "A940aSFI"
		  	lQuery   := .T.
			aStruSFI := SFI->(dbStruct())		
			cQuery := "SELECT * "
			cQuery += "FROM "
			cQuery += RetSqlName("SFI") + " SFI "
			cQuery += "WHERE "
			cQuery += "SFI.FI_FILIAL = '"+xFilial("SFI")+"' AND "
			cQuery += "SFI.FI_DTMOVTO>='"+Dtos(dDtIni)+"' AND "
			cQuery += "SFI.FI_DTMOVTO<='"+Dtos(dDtFim)+"' AND "
			cQuery += "SFI.D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY "+SqlOrder(SFI->(IndexKey()))
			
			cQuery := ChangeQuery(cQuery)
		    	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFI)
			
			For nSFI := 1 To Len(aStruSFI)
				If aStruSFI[nSFI][2] <> "C" 
					TcSetField(cAliasSFI,aStruSFI[nSFI][1],aStruSFI[nSFI][2],aStruSFI[nSFI][3],aStruSFI[nSFI][4])
				EndIf
			Next nSFI
		Else
	#ENDIF
			dbSelectArea(cAliasSFI)
			cIndex := CriaTrab(,.F.)
			cKey := IndexKey()	
			cFilter := 'FI_FILIAL == "'+xFilial("SFI")+'" .And. (Dtos(FI_DTMOVTO) >= "'+Dtos(dDtIni)+'" .And. Dtos(FI_DTMOVTO) <= "'+Dtos(dDtFim)+'")'
			IndRegua(cAliasSFI,cIndex,cKey,,cFilter,"Selecionando Registros...")
			dbGotop()
	#IFDEF TOP
		Endif
	#ENDIF	
	dbSelectArea(cAliasSFI)		

	While (cAliasSFI)->(!Eof())
		If !M60->(MsSeek(DTOS((cAliasSFI)->FI_DTMOVTO)+StrZero(Val((cAliasSFI)->FI_PDV),3)))
			RecLock("M60",.T.)
			M60->M60_EMISS  := (cAliasSFI)->FI_DTMOVTO
			M60->M60_NUMFAB := (cAliasSFI)->FI_SERPDV
			M60->M60_PDV    := STRZERO(VAL((cAliasSFI)->FI_PDV),3)
			M60->M60_MODELO := "2D"
			M60->M60_NUMINI := (cAliasSFI)->FI_NUMINI
			M60->M60_NUMFIM := (cAliasSFI)->FI_NUMFIM
			M60->M60_REDUCZ := (cAliasSFI)->FI_NUMREDZ
			M60->M60_GTINI	:= (cAliasSFI)->FI_GTINI
		    M60->M60_GTFIM	:= (cAliasSFI)->FI_GTFINAL
			MsUnlock()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Totaliza cupons fiscais pela Situacao Tributaria             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cAliasSFI)->FI_SUBTRIB > 0
				RecLock("A60",.T.)
				A60->A60_EMISS	:=	(cAliasSFI)->FI_DTMOVTO
				A60->A60_PDV	:=	STRZERO(VAL((cAliasSFI)->FI_PDV),3)
				A60->A60_SITTRI	:=	"F"
				A60->A60_VALOR	:=	(cAliasSFI)->FI_SUBTRIB
				MsUnlock() 
			EndIf
			If (cAliasSFI)->FI_ISENTO >0
			  	RecLock("A60",.T.)
				A60->A60_EMISS	:=	(cAliasSFI)->FI_DTMOVTO
				A60->A60_PDV	:=	STRZERO(VAL((cAliasSFI)->FI_PDV),3)
				A60->A60_SITTRI	:=	"I"
				A60->A60_VALOR	:=	(cAliasSFI)->FI_ISENTO
				MsUnlock()
			EndIf
			If (cAliasSFI)->FI_CANCEL >0
				RecLock("A60",.T.)
				A60->A60_EMISS	:=	(cAliasSFI)->FI_DTMOVTO
				A60->A60_PDV	:=	STRZERO(VAL((cAliasSFI)->FI_PDV),3)
				A60->A60_SITTRI	:=	"CANC"
				A60->A60_VALOR	:=	(cAliasSFI)->FI_CANCEL
				MsUnlock()
			EndIf         
			If (cAliasSFI)->FI_NTRIB >0
				RecLock("A60",.T.)
				A60->A60_EMISS	:=	(cAliasSFI)->FI_DTMOVTO
 				A60->A60_PDV	:=	STRZERO(VAL((cAliasSFI)->FI_PDV),3)
				A60->A60_SITTRI	:=	"N"
				A60->A60_VALOR	:=	(cAliasSFI)->FI_NTRIB
				MsUnlock()
			EndIf    
			If (cAliasSFI)->FI_DESC >0
				RecLock("A60",.T.)
				A60->A60_EMISS	:=	(cAliasSFI)->FI_DTMOVTO
				A60->A60_PDV	:=	STRZERO(VAL((cAliasSFI)->FI_PDV),3)
				A60->A60_SITTRI	:=	"DESC"
				A60->A60_VALOR	:=	(cAliasSFI)->FI_DESC
				MsUnlock()
			EndIf
			aStruSFI := (cAliasSFI)->(dbStruct())
			For nX := 1 To Len(aStruSFI)
				If "FI_BAS"$(cAliasSFI)->(FieldName(nX))
					If (cAliasSFI)->(FieldGet(nX))>0
						RecLock("A60",.T.)
						A60->A60_EMISS	:=	(cAliasSFI)->FI_DTMOVTO
						A60->A60_PDV	:=	STRZERO(VAL((cAliasSFI)->FI_PDV),3)
			    		A60->A60_SITTRI	:=	aFISFill(Num2Chr(Val(SubStr((cAliasSFI)->(FieldName(nX)),7)),4),4)
						A60->A60_VALOR	:=	(cAliasSFI)->(FieldGet(nX))
						MsUnlock()
					EndIf
				EndIf
			Next nX	
		Endif
		(cAliasSFI)->(dbSkip())
	EndDo
    If lQuery
	    dbSelectArea(cAliasSFI)
		dbCloseArea()
	Else
       	dbSelectArea("SFI")
		RetIndex("SFI")
		dbClearFilter()
		Ferase(cIndex+OrdBagExt())
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Registros Tipo 60D           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->(LastRec()) > 0 
	dbSelectArea("SF2")	
	dbSetOrder(1)
	
	dbSelectArea("SD2")
	ProcRegua(LastRec())
	#IFDEF TOP
	     If TcSrvType()<>"AS/400"
		     cAliasSD2 := "a940ASD2"
			 aStru  := SD2->(dbStruct())
			 cQuery := "SELECT * "
			 cQuery += "FROM "+RetSqlName("SD2")+" "
			 cQuery += "WHERE D2_FILIAL='"+xFilial("SD2")+"' AND "
			 cQuery += "D2_EMISSAO>='"+Dtos(dDtIni)+"' AND "
	         cQuery += "D2_EMISSAO<='"+Dtos(dDtFim)+"' AND "
   			 cQuery += "D2_TIPO <> 'S' AND "
   			 cQuery += "D2_ICMSRET >0  AND "
			 cQuery += "D2_PDV <> ' ' AND "
			 cQuery += "D_E_L_E_T_ = ' ' "
			 cQuery += "ORDER BY D2_FILIAL, D2_PDV, D2_EMISSAO"
	           	
			 cQuery := ChangeQuery(cQuery)
			 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
	
			 For nX := 1 To Len(aStru)
				 If aStru[nX][2] <> "C" 
					 TcSetField(cAliasSD2,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				 EndIf
			 Next nX
			 dbSelectArea(cAliasSD2)
		 Else
	#ENDIF	
		     cIndex2 := CriaTrab(NIL,.F.)
			 cKey	 := 'D2_FILIAL+D2_PDV+DTOS(D2_EMISSAO)'
			 cFilter := 'D2_FILIAL == "'+xFilial("SD2")+'" .And. (Dtos(D2_EMISSAO) >= "'+Dtos(dDtIni)+'" .And. Dtos(D2_EMISSAO) <= "'+Dtos(dDtFim)+'")'
			 cFilter += '.And. !Empty(D2_PDV)'
 			 cFilter += '.And. D2_TIPO <> "S" '
 			 cFilter += '.And. D2_ICMSRET >0 '
 			 			 
			 IndRegua(cAliasSD2,cIndex2,cKey,,cFilter,)
			 nIndex := RetIndex("SD2")
			 #IFNDEF TOP
			 	dbSetIndex(cIndex2+OrdBagExt())
			 #ENDIF			 
			 dbSelectArea("SD2")
			 dbSetOrder(nIndex+1)
	
			 dbSelectArea(cAliasSD2)
			 dbGotop()			 
	#IFDEF TOP
		 EndIf
	#ENDIF
	
    While (cAliasSD2)->(!Eof())
		If SF2->(MsSeek(xFilial("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
		    If SF2->F2_ECF <> "S" .Or. !Empty(SF2->F2_NFCUPOM)
		    	(cAliasSD2)->(dbSkip())
		    	Loop
		    Endif	
		Endif
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta Registro Tipo 60D           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			D60->(dbSetOrder(2))
			If D60->(MsSeek(Dtos((cAliasSD2)->D2_EMISSAO)+(cAliasSD2)->D2_COD))
				RecLock("D60",.F.)
				D60->D60_QUANT  += (cAliasSD2)->D2_QUANT
				D60->D60_VLICM  += (cAliasSD2)->D2_BRICMS   // Base de Calculo da Retencao 
				D60->D60_BSICM  += (cAliasSD2)->D2_BASEICM  // Bse de Calculo do ICMS
				MsUnlock()
			Else         
				RecLock("D60",.T.)
				D60->D60_EMISS  := (cAliasSD2)->D2_EMISSAO
				D60->D60_PDV    := 	STRZERO(VAL((cAliasSD2)->D2_PDV),3)
				D60->D60_QUANT  := (cAliasSD2)->D2_QUANT
				D60->D60_VLICM  := (cAliasSD2)->D2_BRICMS
				D60->D60_BSICM  := (cAliasSD2)->D2_BASEICM
				D60->D60_CODPRO := (cAliasSD2)->D2_COD
				MsUnlock()
			Endif
	   	(cAliasSD2)->(dbSkip())
	EndDo
	If lQuery
    	dbSelectArea(cAliasSD2)
		dbCloseArea()
    Else
       	dbSelectArea("SD2")
		RetIndex("SD2")
		dbClearFilter()
		Ferase(cIndex2+OrdBagExt())
    EndIf 
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Registros Tipo 04 - Mercadoria com Movimentacao           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TMP")
dbSetOrder(1)
dbSelectArea("SD1")
dbSetOrder(2)
FsQuery (aArq1 ,1,"D1_FILIAL='"+xFilial("SD1")+"' AND D1_DTDIGIT>='"+DTOS(dDtIni)+"' AND D1_DTDIGIT<='"+DTOS(dDtFim)+"' AND D1_TIPO<>'S'", "D1_FILIAL=='"+xFilial ("SD1")+"' .And. DTOS(D1_DTDIGIT)>='"+DTOS (dDtIni)+"' .And. DTOS (D1_DTDIGIT)<='"+DTOS (dDtFim)+"' .And. D1_TIPO <> 'S'",SD1->(IndexKey()),nil,{"SFK", "FK_FILIAL='"+xFilial ("SFK")+"' AND D1_COD=FK_PRODUTO"} )
dbGoTop()

While SD1->(!Eof())
    If cProd <> SD1->D1_COD
		cProd := SD1->D1_COD
		RecLock("TMP",.T.)
		TMP->TMP_COD 	:= SD1->D1_COD
		TMP->TMP_DESC 	:= Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
		TMP->TMP_UNID	:= Posicione("SB1",1,xFilial("SB1")+cProd,"B1_UM")
		TMP->(MsUnlock())
		Cat63SFK (cProd,dDtIni,dDtFim) 
	Endif
	SD1->(Dbskip())
Enddo
FsQuery(aArq1,2)

dbSelectArea("SD2")
dbSetOrder(1)
FsQuery (aArq2,1,"D2_FILIAL='"+xFilial("SD2")+"' AND D2_EMISSAO>='"+DTOS(dDtIni)+"' AND D2_EMISSAO<='"+DTOS(dDtFim)+"' AND D2_TIPO<>'S'", "D2_FILIAL=='"+xFilial ("SD2")+"' .And. DTOS(D2_EMISSAO)>='"+DTOS (dDtIni)+"' .And. DTOS (D2_EMISSAO)<='"+DTOS (dDtFim)+"' .And. D2_TIPO <> 'S'",SD2->(IndexKey()),nil,{"SFK", "FK_FILIAL='"+xFilial ("SFK")+"' AND D2_COD=FK_PRODUTO"} )
dbGoTop()
                                                                           
While SD2->(!Eof())

	If TMP->(!dbSeek(SD2->D2_COD))
	    If cProd <> SD2->D2_COD
			cProd := SD2->D2_COD
			RecLock("TMP",.T.)
			TMP->TMP_COD 	:= SD2->D2_COD
			TMP->TMP_DESC 	:= Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
			TMP->TMP_UNID	:= Posicione("SB1",1,xFilial("SB1")+cProd,"B1_UM")
			TMP->(MsUnlock())
		Cat63SFK (cProd,dDtIni,dDtFim) 
		Endif
	Endif
	SD2->(Dbskip())
Enddo
FsQuery(aArq2,2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Registros Tipo 05 - Aliquota de ICMS                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("ICM")
dbSetOrder(1)	

dbSelectArea("SD1")
FsQuery (aArq1,1,"D1_FILIAL='"+xFilial("SD1")+"' AND D1_DTDIGIT>='"+DTOS(dDtIni)+"' AND D1_DTDIGIT<='"+DTOS(dDtFim)+"' AND D1_TIPO<>'S'", "D1_FILIAL=='"+xFilial ("SD1")+"' .And. DTOS(D1_DTDIGIT)>='"+DTOS (dDtIni)+"' .And. DTOS (D1_DTDIGIT)<='"+DTOS (dDtFim)+"' .And. D1_TIPO <> 'S'", "D1_COD+STR(D1_PICM,5,2)+DTOS(D1_EMISSAO)",nil,{"SFK", "FK_FILIAL='"+xFilial ("SFK")+"' AND D1_COD=FK_PRODUTO"} )
dbGoTop()
            
While SD1->(!Eof())
	nAliq := GetAdvFVal("SFK","FK_AICMS",xFilial("SFK") + SD1->D1_COD,1,0)
	Iif(nAliq > 0,0,nAliq := GetAdvFVal("SB1","B1_PICM",xFilial("SB1") + SD1->D1_COD,1,0))

	If ICM->(!dbSeek(SD1->D1_COD+STR(nAliq,5,2)))

		RecLock("ICM",.T.)
		ICM->ICM_COD 	:= SD1->D1_COD
		ICM->ICM_ALIQ 	:= nAliq//SD1->D1_PICM
		ICM->ICM_DTINI 	:= DTOS(dDtIni)
		ICM->ICM_DTFIM 	:= DTOS(SD1->D1_DTDIGIT)

	Else
		RecLock("ICM",.F.)
		ICM->ICM_DTFIM 	:= DTOS(SD1->D1_DTDIGIT)
	Endif	                
	ICM->(MsUnlock())
	SD1->(Dbskip())
	nAliq := 0
Enddo

FsQuery(aArq1,2)

dbSelectArea("SD2")
FsQuery (aArq2,1,"D2_FILIAL='"+xFilial("SD2")+"' AND D2_EMISSAO>='"+DTOS(dDtIni)+"' AND D2_EMISSAO<='"+DTOS(dDtFim)+"' AND D2_TIPO<>'S'", "D2_FILIAL=='"+xFilial ("SD2")+"' .And. DTOS(D2_EMISSAO)>='"+DTOS (dDtIni)+"' .And. DTOS (D2_EMISSAO)<='"+DTOS (dDtFim)+"' .And. D2_TIPO <> 'S'", "D2_COD+STR(D2_PICM,5,2)+DTOS(D2_EMISSAO)",nil,{"SFK", "FK_FILIAL='"+xFilial ("SFK")+"' AND D2_COD=FK_PRODUTO"} )
dbGoTop()
            
While SD2->(!Eof())
	nAliq := GetAdvFVal("SFK","FK_AICMS",xFilial("SFK") + SD2->D2_COD,1,0)
	Iif(nAliq > 0,0,nAliq := GetAdvFVal("SB1","B1_PICM",xFilial("SB1") + SD2->D2_COD,1,0))

	If ICM->(!dbSeek(SD2->D2_COD+STR(nAliq,5,2)))

		RecLock("ICM",.T.)
		ICM->ICM_COD 	:= SD2->D2_COD
		ICM->ICM_ALIQ 	:= nAliq //SD2->D2_PICM
		ICM->ICM_DTINI 	:= DTOS(dDtIni)
		ICM->ICM_DTFIM 	:= DTOS(SD2->D2_EMISSAO)

	Else
		RecLock("ICM",.F.)
		ICM->ICM_DTFIM 	:= DTOS(SD2->D2_EMISSAO)
	Endif	                
	ICM->(MsUnlock())

	SD2->(Dbskip())
Enddo

FsQuery(aArq2,2)

If ExistBlock("CAT63TRB")
	ExecBlock("CAT63TRB",.F.,.F.,{"TMP","SDI","ICM",dDtIni,dDtFim})
EndIf

Return(aTrbs)
                  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao ³CriaTrbs     ºAutor  ³ Andressa Ataides   º Data ³  05/09/05   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³Montagem dos arquivos de trabalho.                             º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno³ExpA -> aTrbs - Array contendo alias abertos pela funcao       º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    ³ Funcao CAT63                                                  º±±
±±ÈÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaTrbs ()

Local cArq060M  	:= ""
Local cArq060A  	:= ""
Local cArq060D  	:= ""
Local cArq060B  	:= ""
Local cArqTMP	  	:= ""
Local cArqICM	  	:= ""
Local cArqSDI	  	:= ""
Local aStru060M 	:= {}
Local aStru060A 	:= {}
Local aStru060D 	:= {}
Local aStruTMP   	:= {}
Local aStruICM   	:= {}
Local aStruSDI   	:= {}
Local aTrbs			:= {}
Local aTam  		:= TAMSX3("D1_COD")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao os arquivos de trabalho                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro 060 - ECF(Mestre do equipamento)                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aStru060M,{"M60_EMISS"	 ,"D",008,0})   // Data Emissao
    AADD(aStru060M,{"M60_PDV"	 ,"C",003,0})   // Numero da Maq.Registradora
	AADD(aStru060M,{"M60_NUMFAB" ,"C",015,0})  // Numero de Serie de Fabr. da Maq. 
	AADD(aStru060M,{"M60_MODELO" ,"C",002,0})  // Modelo
	AADD(aStru060M,{"M60_NUMINI" ,"C",TamSX3("F2_DOC")[1],0})  // Numero Inicial de Ordem
	AADD(aStru060M,{"M60_NUMFIM" ,"C",TamSX3("F2_DOC")[1],0})  // Numero Final de Ordem
	AADD(aStru060M,{"M60_REDUCZ" ,"C",006,0})  // Numero do Contador de Reducao
	AADD(aStru060M,{"M60_GTINI"	 ,"N",016,2})   //Grande Total Inicial
	AADD(aStru060M,{"M60_GTFIM"	 ,"N",016,2})   //Grande Total Final

	cArq060M :=	CriaTrab(aStru060M)
	dbUseArea(.T.,__LocalDriver,cArq060M,"M60")
	IndRegua("M60",cArq060M,"DTOS(M60_EMISS)+M60_PDV")               
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro 060A - ECF(Analitico)                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aStru060A,{"A60_EMISS"	 ,"D",008,0})
	AADD(aStru060A,{"A60_PDV"    ,"C",003,0})
	AADD(aStru060A,{"A60_SITTRI" ,"C",004,0})
	AADD(aStru060A,{"A60_VALOR"	 ,"N",012,2})
	
	cArq060A	:=	CriaTrab(aStru060A)
	dbUseArea(.T.,__LocalDriver,cArq060A,"A60")
	IndRegua("A60",cArq060A,"DTOS(A60_EMISS)+A60_PDV+A60_SITTRI")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro 060D - ECF ( Resumo Diario )                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aStru060D,{"D60_EMISS"	 ,"D",008,0})
	AADD(aStru060D,{"D60_PDV"    ,"C",003,0})
    AADD(aStru060D,{"D60_QUANT"  ,"N",013,0})
	AADD(aStru060D,{"D60_VLICM"  ,"N",013,2})
	AADD(aStru060D,{"D60_BSICM"  ,"N",013,2})
	AADD(aStru060D,{"D60_CODPRO" ,"C",014,0})

	cArq060D	:=	CriaTrab(aStru060D)
	dbUseArea(.T.,__LocalDriver,cArq060D,"D60")
	IndRegua("D60",cArq060D,"DTOS(D60_EMISS)+D60_PDV")
	dbClearIndex()
	//
	cArq060B := CriaTrab(Nil,.F.)
	IndRegua("D60",cArq060B,"DTOS(D60_EMISS)+D60_CODPROD")
	dbClearIndex()
	//
	dbSelectArea("D60")
	dbSetIndex(cArq060D+OrdBagExt())
	dbSetIndex(cArq060B+OrdBagExt())
	dbSetOrder(1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo 04 - Mercadoria com Movimentacao                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aStruTMP,{"TMP_COD"	,"C",014,0})
	AADD(aStruTMP,{"TMP_DESC"   ,"C",075,0})
	AADD(aStruTMP,{"TMP_UNID"   ,"C",003,0})
	
	cArqTMP	:=	CriaTrab(aStruTMP)
	dbUseArea(.T.,__LocalDriver,cArqTMP,"TMP")
	IndRegua("TMP",cArqTMP,"TMP_COD")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo 05 - Aliquota de ICMS                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aStruICM,{"ICM_COD"	,"C",aTam[1],0})
	AADD(aStruICM,{"ICM_ALIQ"   ,"N",005,2})
	AADD(aStruICM,{"ICM_DTINI"  ,"C",008,2})
	AADD(aStruICM,{"ICM_DTFIM"  ,"C",008,2})

	cArqICM	:=	CriaTrab(aStruICM)
	dbUseArea(.T.,__LocalDriver,cArqICM,"ICM")
	IndRegua("ICM",cArqICM,"ICM_COD+STR(ICM_ALIQ, 5, 2)")
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo 02 - Saldos Inicias   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aStruSDI,{"SDI_COD"	,"C",aTam[1],0})
	AADD(aStruSDI,{"SDI_QTDE"	,"N",013,3})
	AADD(aStruSDI,{"SDI_BRICMS" ,"N",013,2})
	
	cArqSDI	:=	CriaTrab(aStruSDI)
	dbUseArea(.T.,__LocalDriver,cArqSDI,"SDI")
	IndRegua("SDI",cArqSDI,"SDI_COD")  
	
    aTrbs	:=	{{cArq060M,"M60"},{cArq060A,"A60"},{cArq060D,"D60"},{cArqTMP,"TMP"},{cArqICM,"ICM"},{cArqSDI,"SDI"}}
	
Return (aTrbs)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³Cat63DelArqºAutor  ³ Andressa Ataides   º Data ³  05/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Apaga arquivos temporarios criados para gerar o arquivo     º±±
±±º         ³ Magnetico                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Funcao CAT63                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Cat63DelArq(aDelArqs)

Local aAreaDel := GetArea()
Local nI := 0

For nI:= 1 To Len(aDelArqs)
	If File(aDelArqs[ni,1]+GetDBExtension())
		dbSelectArea(aDelArqs[ni,2])
		dbCloseArea()
		Ferase(aDelArqs[ni,1]+GetDBExtension())
		Ferase(aDelArqs[ni,1]+OrdBagExt())
	Endif	
Next

RestArea(aAreaDel)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CAT63CDM  ºAutor  ³Angelica Rabelo     º Data ³ 28/10/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna valores da tabela SFI de acordo com a Situacao      º±±
±±º          ³Tributaria e para Entradas/Saidas sera verificada tabela CDMº±±
±±º          ³gerada pela rotina que calcula Credito ICMS Art.271/RICMS/SPº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaFis                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                 
Function CAT63CDM(dDtIni,dDtFim)
                 
Local cAliasSFI := "SFI"
Local cAliasSD2 := "SD2"
Local cProd		:= ""
Local lQuery    := .F.
Local nX        := 0
Local aTrbs     := {}
Local aArqCDM   := {"CDM",""}
Local nAliq     := 0

#IFDEF TOP
	Local nSFI := 0
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria arq. temporarios ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTrbs := CriaTrbs()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Registro Tipo 60³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->(LastRec()) > 0
	dbSelectArea(cAliasSFI)
	dbSetOrder(1)
	#IFDEF TOP
	    If TcSrvType()<>"AS/400"
		    cAliasSFI:= "A940aSFI"
		  	lQuery   := .T.
			aStruSFI := SFI->(dbStruct())		
			cQuery := "SELECT * "
			cQuery += "FROM "
			cQuery += RetSqlName("SFI") + " SFI "
			cQuery += "WHERE "
			cQuery += "SFI.FI_FILIAL = '" + xFilial("SFI") + "' AND "
			cQuery += "SFI.FI_DTMOVTO>='" + Dtos(dDtIni)   + "' AND "
			cQuery += "SFI.FI_DTMOVTO<='" + Dtos(dDtFim)   + "' AND "
			cQuery += "SFI.D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY " + SqlOrder(SFI->(IndexKey()))	
			cQuery := ChangeQuery(cQuery)		    	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFI)			
			For nSFI := 1 To Len(aStruSFI)
				If aStruSFI[nSFI][2] <> "C" 
					TcSetField(cAliasSFI,aStruSFI[nSFI][1],aStruSFI[nSFI][2],aStruSFI[nSFI][3],aStruSFI[nSFI][4])
				EndIf
			Next nSFI
		Else
	#ENDIF
			dbSelectArea(cAliasSFI)
			cIndex := CriaTrab(,.F.)
			cKey := IndexKey()	
			cFilter := 'FI_FILIAL == "'+xFilial("SFI")+'" .And. (Dtos(FI_DTMOVTO) >= "'+Dtos(dDtIni)+'" .And. Dtos(FI_DTMOVTO) <= "'+Dtos(dDtFim)+'")'
			IndRegua(cAliasSFI,cIndex,cKey,,cFilter,"Selecionando os Registros...")
			dbGotop()
	#IFDEF TOP
		Endif
	#ENDIF	
	dbSelectArea(cAliasSFI)		

	While (cAliasSFI)->(!Eof())
		If !M60->(MsSeek(DTOS((cAliasSFI)->FI_DTMOVTO)+StrZero(Val((cAliasSFI)->FI_PDV),3)))
			RecLock("M60",.T.)
			M60->M60_EMISS  := (cAliasSFI)->FI_DTMOVTO
			M60->M60_NUMFAB := (cAliasSFI)->FI_SERPDV
			M60->M60_PDV    := STRZERO(VAL((cAliasSFI)->FI_PDV),3)
			M60->M60_MODELO := "2D"
			M60->M60_NUMINI := (cAliasSFI)->FI_NUMINI
			M60->M60_NUMFIM := (cAliasSFI)->FI_NUMFIM
			M60->M60_REDUCZ := (cAliasSFI)->FI_NUMREDZ
			M60->M60_GTINI	:= (cAliasSFI)->FI_GTINI
		    M60->M60_GTFIM	:= (cAliasSFI)->FI_GTFINAL
			MsUnlock()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Totaliza cupons fiscais pela Situacao Tributaria             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cAliasSFI)->FI_SUBTRIB > 0
				RecLock("A60",.T.)
				A60->A60_EMISS	:=	(cAliasSFI)->FI_DTMOVTO
				A60->A60_PDV	:=	STRZERO(VAL((cAliasSFI)->FI_PDV),3)
				A60->A60_SITTRI	:=	"F"
				A60->A60_VALOR	:=	(cAliasSFI)->FI_SUBTRIB
				MsUnlock() 
			EndIf
			If (cAliasSFI)->FI_ISENTO >0
			  	RecLock("A60",.T.)
				A60->A60_EMISS	:=	(cAliasSFI)->FI_DTMOVTO
				A60->A60_PDV	:=	STRZERO(VAL((cAliasSFI)->FI_PDV),3)
				A60->A60_SITTRI	:=	"I"
				A60->A60_VALOR	:=	(cAliasSFI)->FI_ISENTO
				MsUnlock()
			EndIf
			If (cAliasSFI)->FI_CANCEL >0
				RecLock("A60",.T.)
				A60->A60_EMISS	:=	(cAliasSFI)->FI_DTMOVTO
				A60->A60_PDV	:=	STRZERO(VAL((cAliasSFI)->FI_PDV),3)
				A60->A60_SITTRI	:=	"CANC"
				A60->A60_VALOR	:=	(cAliasSFI)->FI_CANCEL
				MsUnlock()
			EndIf         
			If (cAliasSFI)->FI_NTRIB >0
				RecLock("A60",.T.)
				A60->A60_EMISS	:=	(cAliasSFI)->FI_DTMOVTO
 				A60->A60_PDV	:=	STRZERO(VAL((cAliasSFI)->FI_PDV),3)
				A60->A60_SITTRI	:=	"N"
				A60->A60_VALOR	:=	(cAliasSFI)->FI_NTRIB
				MsUnlock()
			EndIf    
			If (cAliasSFI)->FI_DESC >0
				RecLock("A60",.T.)
				A60->A60_EMISS	:=	(cAliasSFI)->FI_DTMOVTO
				A60->A60_PDV	:=	STRZERO(VAL((cAliasSFI)->FI_PDV),3)
				A60->A60_SITTRI	:=	"DESC"
				A60->A60_VALOR	:=	(cAliasSFI)->FI_DESC
				MsUnlock()
			EndIf
			aStruSFI := (cAliasSFI)->(dbStruct())
			For nX := 1 To Len(aStruSFI)
				If "FI_BAS"$(cAliasSFI)->(FieldName(nX))
					If (cAliasSFI)->(FieldGet(nX))>0
						RecLock("A60",.T.)
						A60->A60_EMISS	:=	(cAliasSFI)->FI_DTMOVTO
						A60->A60_PDV	:=	STRZERO(VAL((cAliasSFI)->FI_PDV),3)
			    		A60->A60_SITTRI	:=	aFISFill(Num2Chr(Val(SubStr((cAliasSFI)->(FieldName(nX)),7)),4),4)
						A60->A60_VALOR	:=	(cAliasSFI)->(FieldGet(nX))
						MsUnlock()
					EndIf
				EndIf
			Next nX	
		Endif
		(cAliasSFI)->(dbSkip())
	EndDo
    If lQuery
	    dbSelectArea(cAliasSFI)
		dbCloseArea()
	Else
       	dbSelectArea("SFI")
		RetIndex("SFI")
		dbClearFilter()
		Ferase(cIndex+OrdBagExt())
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Registros Tipo 60D           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SFI->(LastRec()) > 0 
	dbSelectArea("SF2")	
	dbSetOrder(1)
	
	dbSelectArea("SD2")
	ProcRegua(LastRec())
	#IFDEF TOP
	     If TcSrvType()<>"AS/400"
		     cAliasSD2 := "a940ASD2"
			 aStru  := SD2->(dbStruct())
			 cQuery := "SELECT * "
			 cQuery += "FROM "+RetSqlName("SD2")+" "
			 cQuery += "WHERE D2_FILIAL='"+xFilial("SD2")+"' AND "
			 cQuery += "D2_EMISSAO>='"+Dtos(dDtIni)+"' AND "
	         cQuery += "D2_EMISSAO<='"+Dtos(dDtFim)+"' AND "
   			 cQuery += "D2_TIPO <> 'S' AND "
   			 cQuery += "D2_ICMSRET >0  AND "
			 cQuery += "D2_PDV <> ' ' AND "
			 cQuery += "D_E_L_E_T_ = ' ' "
			 cQuery += "ORDER BY D2_FILIAL, D2_PDV, D2_EMISSAO"
	           	
			 cQuery := ChangeQuery(cQuery)
			 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
	
			 For nX := 1 To Len(aStru)
				 If aStru[nX][2] <> "C" 
					 TcSetField(cAliasSD2,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				 EndIf
			 Next nX
			 dbSelectArea(cAliasSD2)
		 Else
	#ENDIF	
		     cIndex2 := CriaTrab(NIL,.F.)
			 cKey	 := 'D2_FILIAL+D2_PDV+DTOS(D2_EMISSAO)'
			 cFilter := 'D2_FILIAL == "'+xFilial("SD2")+'" .And. (Dtos(D2_EMISSAO) >= "'+Dtos(dDtIni)+'" .And. Dtos(D2_EMISSAO) <= "'+Dtos(dDtFim)+'")'
			 cFilter += '.And. !Empty(D2_PDV)'
 			 cFilter += '.And. D2_TIPO <> "S" '
 			 cFilter += '.And. D2_ICMSRET >0 '
 			 			 
			 IndRegua(cAliasSD2,cIndex2,cKey,,cFilter,)
			 nIndex := RetIndex("SD2")
			 #IFNDEF TOP
			 	dbSetIndex(cIndex2+OrdBagExt())
			 #ENDIF			 
			 dbSelectArea("SD2")
			 dbSetOrder(nIndex+1)
	
			 dbSelectArea(cAliasSD2)
			 dbGotop()			 
	#IFDEF TOP
		 EndIf
	#ENDIF
	
    While (cAliasSD2)->(!Eof())
		If SF2->(MsSeek(xFilial("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
		    If SF2->F2_ECF <> "S" .Or. !Empty(SF2->F2_NFCUPOM)
		    	(cAliasSD2)->(dbSkip())
		    	Loop
		    Endif	
		Endif
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta Registro Tipo 60D.             		               |
		//³Somente vai gerar D60 caso a NF Saida esteja na tabela CDM  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   				
		dbSelectArea("CDM")
		dbSetOrder(2)
		IF CDM->(MsSeek(xFilial("CDM")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)+(cAliasSD2)->D2_ITEM+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_NUMSEQ+(cAliasSD2)->D2_TIPO)
			D60->(dbSetOrder(2))
			If D60->(MsSeek(Dtos((cAliasSD2)->D2_EMISSAO)+(cAliasSD2)->D2_COD))
				RecLock("D60",.F.)
				D60->D60_QUANT  += (cAliasSD2)->D2_QUANT
				D60->D60_VLICM  += (cAliasSD2)->D2_BRICMS   // Base de Calculo da Retencao 
				D60->D60_BSICM  += (cAliasSD2)->D2_BASEICM  // Base de Calculo do ICMS
				MsUnlock()
			Else         
				RecLock("D60",.T.)
				D60->D60_EMISS  := (cAliasSD2)->D2_EMISSAO
				D60->D60_PDV    := 	STRZERO(VAL((cAliasSD2)->D2_PDV),3)
				D60->D60_QUANT  := (cAliasSD2)->D2_QUANT
				D60->D60_VLICM  := (cAliasSD2)->D2_BRICMS
				D60->D60_BSICM  := (cAliasSD2)->D2_BASEICM
				D60->D60_CODPRO := (cAliasSD2)->D2_COD
				MsUnlock()
			Endif
	   	ENDIF
	   	(cAliasSD2)->(dbSkip())
	EndDo
	If lQuery
    	dbSelectArea(cAliasSD2)
		dbCloseArea()
    Else
       	dbSelectArea("SD2")
		RetIndex("SD2")
		dbClearFilter()
		Ferase(cIndex2+OrdBagExt())
    EndIf 
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Registros Tipo 04 - Mercadoria com Movimentacao           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ENTRADAS
dbSelectArea("CDM")
dbSetOrder(1)
FsQuery (aArqCDM,1,"CDM_FILIAL='"+xFilial("CDM")+"' AND CDM_DTENT>='"+DTOS(dDtIni)+"' AND CDM_DTENT<='"+DTOS(dDtFim)+"' AND CDM_TIPODB<>'S' AND CDM_BSERET >0 AND CDM_TIPO = 'S'", "CDM_FILIAL=='"+xFilial ("CDM")+"' .And. DTOS(CDM_DTENT)>='"+DTOS (dDtIni)+"' .And. DTOS (CDM_DTENT)<='"+DTOS (dDtFim)+"' .And. CDM_TIPODB <> 'S' .And. CDM_BSERET >0 .And. CDM_TIPO = 'S' ",CDM->(IndexKey()))
dbGoTop()
While !Eof()
    If cProd <> CDM->CDM_PRODUT
		cProd := CDM->CDM_PRODUT
		RecLock("TMP",.T.)
		TMP->TMP_COD 	:= CDM->CDM_PRODUT
		TMP->TMP_DESC 	:= Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
		TMP->TMP_UNID	:= Posicione("SB1",1,xFilial("SB1")+cProd,"B1_UM")
		Cat63SFK (cProd,dDtIni,dDtFim) 
		MsUnlock()
	Endif
	dbSelectArea("CDM")
	Dbskip()
Enddo
FsQuery(aArqCDM,2)
          
//SAIDAS
dbSelectArea("CDM")
dbSetOrder(2)
FsQuery (aArqCDM,1,"CDM_FILIAL='"+xFilial("CDM")+"' AND CDM_DTSAI>='"+DTOS(dDtIni)+"' AND CDM_DTSAI<='"+DTOS(dDtFim)+"' AND CDM_TIPODB<>'S' AND CDM_BSSRET >0 AND CDM_TIPO = 'M'", "CDM_FILIAL=='"+xFilial ("CDM")+"' .And. DTOS(CDM_DTSAI)>='"+DTOS (dDtIni)+"' .And. DTOS (CDM_DTSAI)<='"+DTOS (dDtFim)+"' .And. CDM_TIPODB <> 'S' .And. CDM_BSSRET >0 .And. CDM_TIPO = 'M'",CDM->(IndexKey(2)))
dbGoTop()                                                                         
While !Eof()
	dbSelectArea("TMP")
	dbSetOrder(1)	
	If !dbSeek(CDM->CDM_PRODUT)
	    If cProd <> CDM->CDM_PRODUT
			cProd := CDM->CDM_PRODUT
			RecLock("TMP",.T.)
			TMP->TMP_COD 	:= CDM->CDM_PRODUT
			TMP->TMP_DESC 	:= Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
			TMP->TMP_UNID	:= Posicione("SB1",1,xFilial("SB1")+cProd,"B1_UM")
			Cat63SFK (cProd,dDtIni,dDtFim) 
			MsUnlock()
		Endif
	Endif	
	dbSelectArea("CDM")
	Dbskip()
Enddo
FsQuery(aArqCDM,2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Registros Tipo 05 - Aliquota de ICMS                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ENTRADAS
dbSelectArea("CDM")
FsQuery (aArqCDM,1,"CDM_FILIAL='"+xFilial("CDM")+"' AND CDM_DTENT>='"+DTOS(dDtIni)+"' AND CDM_DTENT<='"+DTOS(dDtFim)+"' AND CDM_TIPODB<>'S' AND CDM_BSERET >0 AND CDM_TIPO = 'S' ", "CDM_FILIAL=='"+xFilial ("CDM")+"' .And. DTOS(CDM_DTENT)>='"+DTOS (dDtIni)+"' .And. DTOS (CDM_DTENT)<='"+DTOS (dDtFim)+"' .And. CDM_TIPODB <> 'S' .And. CDM_BSERET >0 ", "CDM_PRODUT+STR(CDM_ALQENT,5,2)+DTOS(CDM_DTENT)")
dbGoTop()
            
While !Eof()
	nAliq := GetAdvFVal("SFK","FK_AICMS",xFilial("SFK") + CDM->CDM_PRODUT,1,"")
	iif(naliq > 0,0,nAliq := GetAdvFVal("SB1","B1_PICM",xFilial("SB1") + CDM->CDM_PRODUT,1,""))
	dbSelectArea("ICM")
	dbSetOrder(1)	
	If !dbSeek(CDM->CDM_PRODUT+STR(CDM->CDM_ALQENT,5,2))
		RecLock("ICM",.T.)
		ICM->ICM_COD 	:= CDM->CDM_PRODUT
		ICM->ICM_ALIQ 	:= nAliq //CDM->CDM_ALQENT
		ICM->ICM_DTINI 	:= DTOS(dDtIni)
		ICM->ICM_DTFIM 	:= DTOS(CDM->CDM_DTENT)
		MsUnlock()
	Else
		RecLock("ICM",.F.)
		ICM->ICM_DTFIM 	:= DTOS(CDM->CDM_DTENT)
	Endif	                
	dbSelectArea("CDM")
	Dbskip()
	nAliq := 0
Enddo
FsQuery(aArqCDM,2)

//SAIDAS
dbSelectArea("CDM")
FsQuery (aArqCDM,1,"CDM_FILIAL='"+xFilial("CDM")+"' AND CDM_DTSAI>='"+DTOS(dDtIni)+"' AND CDM_DTSAI<='"+DTOS(dDtFim)+"' AND CDM_TIPODB<>'S' AND CDM_BSSRET >0 ", "CDM_FILIAL=='"+xFilial ("CDM")+"' .And. DTOS(CDM_DTSAI)>='"+DTOS (dDtIni)+"' .And. DTOS (CDM_DTSAI)<='"+DTOS (dDtFim)+"' .And. CDM_TIPODB <> 'S' .And. CDM_BSSRET >0 ", "CDM_PRODUT+STR(CDM_ALQSAI,5,2)+DTOS(CDM_DTSAI)")
dbGoTop()
            
While !Eof()
	nAliq := GetAdvFVal("SFK","FK_AICMS",xFilial("SFK") + CDM->CDM_PRODUT,1,"")
	iif(naliq > 0,0,nAliq := GetAdvFVal("SB1","B1_PICM",xFilial("SB1") + CDM->CDM_PRODUT,1,""))
	dbSelectArea("ICM")
	dbSetOrder(1)	
	If !dbSeek(CDM->CDM_PRODUT+STR(CDM->CDM_ALQSAI,5,2))
		RecLock("ICM",.T.)
		ICM->ICM_COD 	:= CDM->CDM_PRODUT
		ICM->ICM_ALIQ 	:= nAliq //CDM->CDM_ALQSAI
		ICM->ICM_DTINI 	:= DTOS(dDtIni)
		ICM->ICM_DTFIM 	:= DTOS(CDM->CDM_DTSAI)
		MsUnlock()
	Else
		RecLock("ICM",.F.)
		ICM->ICM_DTFIM 	:= DTOS(CDM->CDM_DTSAI)
	Endif	                
	dbSelectArea("CDM")
	Dbskip()
	nAliq := 0
Enddo
FsQuery(aArqCDM,2)

If ExistBlock("CAT63TRB")
	ExecBlock("CAT63TRB",.F.,.F.,{"TMP","SDI","ICM",dDtIni,dDtFim})
EndIf

Return(aTrbs)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao ³Cat63SFK     ºAutor  ³ Natalia Antonucci  º Data ³  09/11/11   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³  Saldo Iniciais (SFK)                                         º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    ³ Funcao CAT63                                                  º±±
±±ÈÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Cat63SFK (cProd,dDtIni,dDtFim) 

Local cAliasSFK:= "SFK" 
LOcal lQuery := .F.
 
	DbSelectArea (cAliasSFK)
	(cAliasSFK)->(DbSetOrder (1))
	#IFDEF TOP
	    If (TcSrvType ()<>"AS/400")
	    	lQuery := .T.
	    	cAliasSFK	:=	GetNextAlias()

		   	BeginSql Alias cAliasSFK
				
				COLUMN FK_DATA AS DATE
		    	
				SELECT
			   		SFK.FK_FILIAL, SFK.FK_DATA, SFK.FK_PRODUTO, SFK.FK_QTDE, SFK.FK_BRICMS
				FROM 
					%Table:SFK% SFK
				WHERE 					
					SFK.FK_FILIAL = %xFilial:SFK% AND 
					SFK.FK_DATA >= %Exp:DToS(dDtIni)% AND 
					SFK.FK_DATA <= %Exp:DToS(dDtFim)% AND 
					SFK.FK_PRODUTO = %Exp:cProd%  AND  
					SFK.%NotDel%
						
				EndSql
		Else
	#ENDIF  
		    
		    cIndex	:= CriaTrab(NIL,.F.)
		 	cFiltro	:= "FK_FILIAL == '" + xFilial("SFK") + "' .AND. "
			cFiltro += "DToS (FK_DATA) >= '"+DToS(dDtIni)+"' .AND. " 
			cFiltro += "DToS (FK_DATA) <= '"+DToS(dDtFim)+"' .AND. "  
			cFiltro += "FK_PRODUTO = '"+cProd+ ' "
  			IndRegua (cAliasSFK, cIndex, SFK->(IndexKey ()),, cFiltro)
		    nIndex := RetIndex(cAliasSFK)

			#IFNDEF TOP
				DbSetIndex (cIndex+OrdBagExt ())
			#ENDIF
			
			DbSelectArea (cAliasSFK)
		    DbSetOrder (nIndex+1)
	#IFDEF TOP
		Endif
	#ENDIF                  
 	While !(cAliasSFK)->(Eof ())
	   
		RecLock( "SDI", .T.)
		SDI_COD 	:= (cAliasSFK)->FK_PRODUTO
		SDI_QTDE 	:= (cAliasSFK)->FK_QTDE  	
		SDI_BRICMS	:= (cAliasSFK)->FK_BRICMS 
   		SDI->(MsUnlock()) 
   		(cAliasSFK)->(dbSkip())
   Enddo

 	If lQuery
	    dbSelectArea(cAliasSFK)
		dbCloseArea()
	Else
       	dbSelectArea("SFK")
		RetIndex("SFK")
		dbClearFilter()
		Ferase(cIndex+OrdBagExt())
	Endif
Return
