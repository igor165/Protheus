#Include "Protheus.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CAT85TMP  ºAutor  ³Luciana Pires       º Data ³ 14/01/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a estrutura das notas fiscais a serem apresentadas    º±±
±±º          ³cabecalho - itens                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CAT85                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CAT85TMP(dDataIni,dDataFin,cNfini,cSrini,cNffim,cSrfim,aFilsCalc)

Local aTemp 	:= GeraTmp85(dDataIni,dDataFin)
Local cAliasSF3	:= "SF3"
Local cMvSerie	:= ""
Local cCNPJ		:= ""
Local cNome 		:= ""
Local cEnd		:= ""
Local cBairro		:= ""
Local cMun		:= ""
Local cUF			:= ""
Local cCep		:= ""
Local cFone		:= ""
Local cTipo		:= ""
Local cData		:= ""
Local cChaveSF3 	:= ""
Local cCpoSerie	:= SerieNfId("SF3",3,"F3_SERIE")
Local lQuery	:= .F.
Local lImpItens	:= .T.
Local nDesc		:= 0
Local nId		:= 0
Local nItem		:= 0

#IFDEF TOP
	Local aCamposSF3	:= {}
	Local aStruSF3		:= {}
	Local cQuery		:= ""
	Local cCmpQry		:= ""	
	Local nX			:= 0
#ELSE
	Local cArqInd		:= ""
	Local cChave		:= ""
	Local cFiltro		:= ""
#ENDIF

Local nForFilial:= 0
Local cFilOrig	:= cFilAnt
Default aFilsCalc	:= { { .T., cFilAnt } }

//Buscando conteudo do parametro MV_SERIE, onde devera ser verificado varias vezes porque podem  existir varios 
//parametros MV_SERIE Exemplo MV_SERIE0, MV_SERIE1, MV_SERIE2, MV_SERIE3.
DbSelectArea("SX6")
SX6->(DbSetOrder(1))

SX6->(DbGoTop())
SX6->(DbSeek(xFilial("SX6")+"MV_SERIE"))

While !SX6->(Eof()) .And. xFilial ("SX6")==SX6->X6_FIL .And. "MV_SERIE"$SX6->X6_VAR
	cMvSerie += Iif(Right(Alltrim(cMvSerie),1) == "/",Alltrim(SX6->X6_CONTEUD),Alltrim(SX6->X6_CONTEUD)+"/")
	DbSkip()
Enddo 

If Empty(cNffim) 
	cNffim := "ZZZZZZZZZ"
Endif
If Empty(cSrfim)
	cSrfim := "ZZZ"
Endif

aAdd(aCamposSF3,"F3_FILIAL")
aAdd(aCamposSF3,"F3_ENTRADA")
aAdd(aCamposSF3,"F3_NFISCAL")
aAdd(aCamposSF3,"F3_SERIE")
aAdd(aCamposSF3,"F3_CLIEFOR")
aAdd(aCamposSF3,"F3_LOJA")
aAdd(aCamposSF3,"F3_VALCONT")
aAdd(aCamposSF3,"F3_TIPO")
aAdd(aCamposSF3,"F3_CFO")
aAdd(aCamposSF3,"F3_CODISS")
aAdd(aCamposSF3,"F3_DESPESA")
aAdd(aCamposSF3,"F3_ICMSRET")
aAdd(aCamposSF3,"F3_VALIPI")
aAdd(aCamposSF3,"F3_ESPECIE")
aAdd(aCamposSF3,"F3_VALOBSE")
aAdd(aCamposSF3,"F3_PDV")

If cCpoSerie == "F3_SDOC"
	aAdd(aCamposSF3,"F3_SDOC")
EndIf
cAliasSF3 := "SF3CAT85"

aStruSF3  := SF3->(Str85(aCamposSF3,@cCmpQry))

For nForFilial := 1 to Len(aFilsCalc)
	If aFilsCalc[nForFilial, 1]
		cFilAnt := aFilsCalc[ nForFilial, 2 ]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processamento dos documentos Fiscais                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF3")
		SF3->(dbSetOrder(1))
		
		#IFDEF TOP
		  
		    If TcSrvType()<>"AS/400"   
		
				lQuery    := .T.			
				cQuery	:= "SELECT "
				cQuery	+= cCmpQry
				cQuery	+= "FROM " + RetSqlName("SF3") + " SF3 "
				cQuery	+= "WHERE "
				cQuery	+= "F3_FILIAL = '" + xFilial("SF3") + "' AND "
				cQuery	+= "F3_ENTRADA >= '" + Dtos(dDataIni) + "' AND "
				cQuery	+= "F3_ENTRADA <= '" + Dtos(dDataFin) + "' AND "
		      	cQuery	+= "F3_NFISCAL >= '" + cNfini + "' AND "
		      	cQuery	+= "F3_NFISCAL <= '" + cNffim + "' AND "   	
		      	cQuery	+= cCpoSerie + " >= '" + cSrini + "' AND "
		      	cQuery	+= cCpoSerie + " <= '" + cSrfim + "' AND "      	 			
				cQuery	+= "F3_CFO >= '5' AND "
				cQuery	+= "F3_TIPO IN('N','D','B','') AND "
				cQuery	+= "F3_CODISS = '' AND "
				cQuery	+= "F3_PDV = '" + Space(Len(SF3->F3_PDV)) + "' "
				cQuery	+= " AND F3_DTCANC = ' ' AND F3_OBSERV <> 'NF CANCELADA'"
				cQuery	+= "ORDER BY F3_ENTRADA,F3_SERIE,F3_NFISCAL,F3_TIPO,F3_CLIEFOR,F3_LOJA"
			
				cQuery 	:= ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)	
				
				For nX := 1 To len(aStruSF3)
					If aStruSF3[nX][2] <> "C" 
						TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
					EndIf
				Next nX
			
				dbSelectArea(cAliasSF3)	
			Else
		
		#ENDIF
				cArqInd	:=	CriaTrab(NIL,.F.)
				cChave		:=	"DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_TIPO+F3_CLIEFOR+F3_LOJA"
				cFiltro 	:= 	"F3_FILIAL == '" + xFilial("SF3") + "' .AND.
				cFiltro	+=	"DtoS(F3_ENTRADA) >= '" + DtoS(dDataIni) + "' .And. DtoS(F3_ENTRADA) <= '" + DtoS(dDataFin) + "' .And. "
				cFiltro 	+= 	"F3_NFISCAL >= '" + cNfini + "' .And. "
				cFiltro 	+= 	"F3_NFISCAL <= '" + cNffim + "' .And. "
				cFiltro	+=	"F3_SERIE >= '" + cSrini + "' .And. "
				cFiltro 	+=	"F3_SERIE <= '" + cSrfim + "' .And. "
				cFiltro	+= 	"F3_CFO >= '5' .And. "
				cFiltro	+=	"F3_TIPO$'NDB ' .And. "
				cFiltro	+=	"Empty(F3_CODISS) .And."
				cFiltro	+=	"Empty(F3_PDV) .And."
				cFiltro	+=	"Empty(F3_DTCANC)"
					
				IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,"Selecionando Registros")
				#IFNDEF TOP
					DbSetIndex(cArqInd+OrdBagExt())
				#ENDIF                
				(cAliasSF3)->(dbGotop())
		
		#IFDEF TOP
			Endif    
		#ENDIF
		
		DbSelectArea(cAliasSF3)
		ProcRegua(LastRec())
		(cAliasSF3)->(DbGoTop())
		
		While (cAliasSF3)->(!Eof())                  
		
			If cChaveSF3 <> (cAliasSF3)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)
				IncProc()
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica o cliente do movimento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCNPJ		:= ""
				cNome 		:= ""
				cEnd		:= ""
				cBairro		:= ""
				cMun		:= ""
				cUF			:= ""
				cCep		:= ""
				cFone		:= ""    
				cTipo		:= ""
				cData		:= ""
				nDesc		:= 0        
				lImpItens 	:= .T.
						
				If !((cAliasSF3)->F3_TIPO) $ "DB"
					
					DbSelectArea("SA1")
					SA1->(dbSetOrder(1))
			
					If !(SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)))
						(cAliasSF3)->(dbSkip())
						Loop
					Endif 
					cCNPJ	:= SA1->A1_CGC
					cNome 	:= Alltrim(SA1->A1_NOME)           
					cEnd	:= Alltrim(SA1->A1_END)
					cBairro	:= Alltrim(SA1->A1_BAIRRO)
					cMun	:= Alltrim(SA1->A1_MUN)
					cUF		:= Alltrim(SA1->A1_EST)
					cCep	:= Alltrim(SA1->A1_CEP)
					cFone	:= Alltrim(SubStr(aRetDig(SA1->A1_TEL,.F.),1,8))
					cTipo	:= Alltrim(SA1->A1_TIPO)
				Else
					DbSelectArea("SA2")
					SA2->(dbSetOrder(1))
				
					If !(SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)))
						(cAliasSF3)->(dbSkip())
						Loop
					Endif 
					cCNPJ	:= SA2->A2_CGC
					cNome	:= Alltrim(SA2->A2_NOME)
					cEnd	:= Alltrim(SA2->A2_END)
					cBairro	:= Alltrim(SA2->A2_BAIRRO)
					cMun	:= Alltrim(SA2->A2_MUN)
					cUF		:= Alltrim(SA2->A2_EST)
					cCep	:= Alltrim(SA2->A2_CEP)
					cFone	:= Alltrim(SubStr(aRetDig(SA2->A2_TEL,.F.),1,8))
					cTipo	:= Alltrim(SA2->A2_TPESSOA)
				Endif
				             	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cabecalho do documento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cData	:= StrZero(Day((cAliasSF3)->F3_ENTRADA),2)+"/"+StrZero(Month((cAliasSF3)->F3_ENTRADA),2)+"/"+StrZero(Year((cAliasSF3)->F3_ENTRADA),4)
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciona tabela SF2  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
				DbSelectArea("SF2")
				SF2->(dbSetOrder(1))
			
				If SF2->(MsSeek(F3Filial("SF2",cAliasSF3)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))	
			
					If !NF1->(dbSeek(cData+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+cCNPJ))
						RecLock("NF1",.T.)
						
						nId += 1
						lImpItens := .T.
								
						NF1->ID_CAB		:= StrZero(nId,15)
						NF1->SERIE   		:= SubStr(cMvSerie,Iif(At(SubStr((cAliasSF3)->F3_SERIE,1,3),cMvSerie)>0,At(SubStr((cAliasSF3)->F3_SERIE,1,3),cMvSerie)+4,At(SubStr((cAliasSF3)->F3_SERIE,1,3),cMvSerie)+5),2)
						NF1->ESPECIE		:= Alltrim((cAliasSF3)->F3_ESPECIE)
						NF1->NF       	:= RetNf((cAliasSF3)->F3_NFISCAL,9,"N")
						NF1->EMISSAO  	:= StrZero(Day((cAliasSF3)->F3_ENTRADA),2)+"/"+StrZero(Month((cAliasSF3)->F3_ENTRADA),2)+"/"+StrZero(Year((cAliasSF3)->F3_ENTRADA),4)
						NF1->SAIDA    	:= StrZero(Day((cAliasSF3)->F3_ENTRADA),2)+"/"+StrZero(Month((cAliasSF3)->F3_ENTRADA),2)+"/"+StrZero(Year((cAliasSF3)->F3_ENTRADA),4)
						NF1->CNPJCPF  	:= cCNPJ
						NF1->NOME     	:= cNome
						NF1->ENDERECO 	:= Alltrim(Substr(cEnd,1,At(" ",cEnd))+Substr(cEnd,At(" ",cEnd)+1,(At(",",cEnd)-At(" ",cEnd))-1))
						NF1->NUMERO   	:= Replicate("0",5-Len(Alltrim(Substr(cEnd,At(",",cEnd)+1,Len(AllTrim(cEnd))))))+Alltrim(Substr(cEnd,At(",",cEnd)+1,Len(AllTrim(cEnd))))
						NF1->BAIRRO  		:= cBairro
						NF1->CIDADE  		:= cMun
						NF1->UF       	:= cUF
						NF1->CEP      	:= cCep
						NF1->TELEFONE 	:= cFone
						NF1->TIPO			:= cTipo
						NF1->VLPRODUT  	:= SF2->F2_VALBRUT + SF2->F2_DESCONT - SF2->F2_DESPESA
						NF1->VLDESC  		:= SF2->F2_DESCONT
						NF1->VLFRETE  	:= SF2->F2_FRETE
						NF1->VLSEGURO 	:= SF2->F2_SEGURO
						NF1->VLDESPESA 	:= SF2->F2_DESPESA - SF2->F2_FRETE - SF2->F2_SEGURO
						NF1->VLTOTAL  	:= SF2->F2_VALBRUT + SF2->F2_DESPESA - SF2->F2_FRETE - SF2->F2_SEGURO
						NF1->PRECVISTA	:= SF2->F2_VALBRUT + SF2->F2_DESPESA - SF2->F2_FRETE - SF2->F2_SEGURO
						NF1->PRECFINAL	:= SF2->F2_VALBRUT + SF2->F2_DESPESA - SF2->F2_FRETE - SF2->F2_SEGURO
						NF1->SDOC		   	:= SubStr(cMvSerie,Iif(At(SubStr(SerieNfId(cAliasSF3,2,"F3_SERIE"),1,3),cMvSerie)>0,At(SubStr(SerieNfId(cAliasSF3,2,"F3_SERIE"),1,3),cMvSerie)+4,At(SubStr(SerieNfId(cAliasSF3,2,"F3_SERIE"),1,3),cMvSerie)+5),2)
										
						MsUnLock()		
					Else
						lImpItens := .F.
					Endif
			    Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciona tabela SD2/SB1  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SD2")
				SD2->(dbSetOrder(3))
				If SD2->(MsSeek(F3Filial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))		
				
				 	nItem := 0
				 	
				 	While lImpItens .And. !SD2->(Eof()) .And. D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA == F3Filial("SF3")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
						
						If SD2->D2_BASEISS == 0 .And. SD2->D2_VALISS == 0
							
							DbSelectArea("SB1")
							SB1->(dbSetOrder(1))
							If SB1->(MsSeek(F3Filial("SB1")+SD2->D2_COD))	
						
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Itens do movimento        ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								RecLock("NF2",.T.)
								
								nItem ++
								NF2->ID_CAB		:= StrZero(nId,15)                                     
								NF2->ITEM 		:= StrZero(nItem,3)
								NF2->CODPROD 	:= Alltrim(SB1->B1_COD)
								NF2->TIPREC  	:= Iif((cAliasSF3)->F3_ICMSRET>0,"3",Iif((cAliasSF3)->F3_VALIPI>0,"2","1"))
								NF2->DESCR   	:= Alltrim(SB1->B1_DESC)
								NF2->QTDE    	:= SD2->D2_QUANT
								NF2->VLUNIT   	:= SD2->D2_PRCVEN+(SD2->D2_DESCON/SD2->D2_QUANT)
								NF2->VLTOTAL  	:= SD2->D2_TOTAL+SD2->D2_DESCON
							
								MsUnLock()	
							Endif
						Endif
						SD2->(dbSkip())
					Enddo	
				Endif
			EndIf
			cChaveSF3 := (cAliasSF3)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)
			(cAliasSF3)->(dbSkip())
		Enddo          
		
		If !lQuery
			RetIndex("SF3")	
			dbClearFilter()	
			Ferase(cArqInd+OrdBagExt())
		Else
			(cAliasSF3)->(dbCloseArea())
		Endif
		
	EndIf

Next

cFilAnt := cFilOrig
Return(aTemp)                       
                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraTmp85 ºAutor  ³Luciana Pires       º Data ³ 14/01/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria as tabelas temporarias                                 º±±
±±º          ³cabecalho - itens                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³aTemp: [01] Alias do temporario                             º±±
±±º          ³       [02] Nome fisico da tabela temporaria                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CAT85                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraTmp85()

Local aTemp 	:= {}
Local aCab		:= {}
Local aItens 	:= {}

Local cArqCab	:= ""
Local cArqIte	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cabecalho do documento fiscal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCab,{"ID_CAB"		,"C",015,0})
AADD(aCab,{"SERIE"		,"C",TamSx3("F3_SERIE")[1],0})
AADD(aCab,{"ESPECIE"		,"C",005,0})
AADD(aCab,{"NF"			,"C",009,0})
AADD(aCab,{"EMISSAO"		,"C",010,0})
AADD(aCab,{"SAIDA"		,"C",010,0})
AADD(aCab,{"CNPJCPF"		,"C",014,0})
AADD(aCab,{"NOME"		,"C",060,0})
AADD(aCab,{"ENDERECO"	,"C",060,0})
AADD(aCab,{"NUMERO"		,"C",005,0})
AADD(aCab,{"BAIRRO"		,"C",030,0})
AADD(aCab,{"CIDADE"		,"C",030,0})
AADD(aCab,{"UF"			,"C",002,0})
AADD(aCab,{"CEP"			,"C",008,0})
AADD(aCab,{"TELEFONE"	,"C",010,0})
AADD(aCab,{"TIPO"		,"C",001,0})
AADD(aCab,{"VLPRODUT"	,"N",018,2})
AADD(aCab,{"VLDESC"		,"N",018,2})
AADD(aCab,{"VLFRETE"		,"N",018,2})
AADD(aCab,{"VLSEGURO"	,"N",018,2})
AADD(aCab,{"VLDESPESA"	,"N",018,2})
AADD(aCab,{"VLTOTAL"		,"N",018,2})
AADD(aCab,{"PRECVISTA"	,"N",018,0})
AADD(aCab,{"PRECFINAL"	,"N",018,0})
AADD(aCab,{"SDOC"		,"C",002,0})
cArqCab	:=	CriaTrab(aCab)
dbUseArea(.T.,__LocalDriver,cArqCab,"NF1")
IndRegua("NF1",cArqCab,"EMISSAO+NF+SERIE+CNPJCPF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Itens do documento fiscal    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aItens,{"ID_CAB"	,"C",015,0})
AADD(aItens,{"ITEM"		,"C",003,0})
AADD(aItens,{"CODPROD"	,"C",015,0})
AADD(aItens,{"TIPREC"	,"C",001,0})
AADD(aItens,{"DESCR"	,"C",120,0})
AADD(aItens,{"QTDE"		,"N",014,3})
AADD(aItens,{"VLUNIT"	,"N",018,2})
AADD(aItens,{"VLTOTAL"	,"N",018,2})
cArqIte	:=	CriaTrab(aItens)
dbUseArea(.T.,__LocalDriver,cArqIte,"NF2")
IndRegua("NF2",cArqIte,"ID_CAB+ITEM")

aTemp	:=	{{cArqCab,"NF1"},{cArqIte,"NF2"}}

Return(aTemp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³DelArq85   ºAutor  ³ Luciana Pires      º Data ³ 14/01/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Apaga arquivos temporarios criados para gerar o arquivo      º±±
±±º         ³Magnetico                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³CAT85                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DelArq85(aDelArqs)

Local aAreaDel	:= GetArea()

Local nI 		:= 0

For nI := 1 To Len(aDelArqs)

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
±±ºPrograma  ³Str85     ºAutor  ³Luciana Pires       º Data ³ 14/01/2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar um array apenas com os campos utiLizados na query    º±±
±±º          ³para passagem na funcao TCSETFIELD                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aCampos: campos a serem tratados na query                   º±±
±±º          ³cCmpQry: string contendo os campos para select na query     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CAT85                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
#IFDEF TOP

	Static Function Str85(aCampos,cCmpQry)
	
	Local	aRet	:=	{}
	Local	nX		:=	0
	Local	aTamSx3	:=	{}
	
	For nX := 1 To Len(aCampos)
		If(FieldPos(aCampos[nX])>0)
			aTamSx3 := TamSX3(aCampos[nX])
			aAdd (aRet,{aCampos[nX],aTamSx3[3],aTamSx3[1],aTamSx3[2]})
			cCmpQry	+=	aCampos[nX]+", "
		EndIf
	Next(nX)
	
	If(Len(cCmpQry)>0)
		cCmpQry	:=	" " + SubStr(cCmpQry,1,Len(cCmpQry)-2) + " "
	EndIf 
		
	Return(aRet)        
	
#ENDIF
