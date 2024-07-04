
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³EDIMS     ³ Autor ³  Cleber S. A. Santos  ³ Data ³ 28.09.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³EDIMS - Informações de Cargas Transportadas através do      ³±±
±±³          ³Estado de Mato Grosso do Sul - MS                 		  ³±±
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
Function ProcDoctos(cTipMan,cFilori,cViagem)
	Local aTrbs		:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera arquivos temporarios            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTrbs := GeraTemp()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa Registros                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
    ProcReg(cTipMan,cFilori,cViagem)                          


Return (aTrbs)

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
Static Function ProcReg(cTipMan,cFilori,cViagem)
   Local aDud          := {"DUD",""}
   Local aDtx          := {"DTX",""}
   Local aDtc          := {"DTC",""}
   Local cCGCDest	   :=""
   Local cCGCRem	   :=""
   Local cIEDest	   :=""
   Local cIERem	       :=""
   Local cUFDest       :=""
   Local cUFRem        :=""
   Local nContDoc      :=0
   Local nContIten     :=0   
   Local aTotais :={} 
    
   DTX->(dbSetOrder(3))
   FsQuery(aDtx,1,"DTX_FILIAL='"+ xFilial("DTX") +"' AND DTX_FILORI='"+ cFilori+"' AND DTX_VIAGEM='"+  cViagem +"'","DTX_FILIAL=='"+ xFilial("DTX") +"' .AND. DTX_FILORI=='"+ cFilori+"' .AND. DTX_VIAGEM=='"+ cViagem+"'",DTX->(IndexKey()))
   DTX->(dbGotop())
			
    aTotais:= CalcDoctos(DTX->DTX_FILORI,DTX->DTX_VIAGEM,DTX->DTX_FILMAN,DTX->DTX_MANIFE)
			
   Do While !DTX->(Eof ()) 			
	 nContDoc       :=0
     	dbSelectArea("RT1")
	 
     	 RecLock("RT1",.T.) 
     	     	 			
			RT1->TPOREG     := 30
			RT1->CHAVE      := " "
			RT1->ESP1       := " "
			RT1->NUMMAN     := VAL(DTX->DTX_MANIFE)
			RT1->ESP2       := " "
			RT1->TPOMAN     := cTipMan
			RT1->ESP3       := " "
			RT1->QTDNF      := aTotais[1]
			RT1->ESP4       := " "
			RT1->VALNFS     := aTotais[2]
			RT1->ESP5       := " "
			RT1->PESOTOT    := aTotais[3]
			RT1->ESP6       := " "
			RT1->POSTSAI    := " "
			
		
         MsUnlock() 

	    DUD->(dbSetOrder(5))
 		FsQuery(aDud,1,"DUD_FILIAL='"+ xFilial("DUD") +"' AND DUD_FILORI='"+ DTX->DTX_FILORI +"' AND DUD_VIAGEM='"+ DTX->DTX_VIAGEM+"' AND DUD_FILMAN='"+ DTX->DTX_FILMAN+"' AND DUD_MANIFE='"+ DTX->DTX_MANIFE+"'","DUD_FILIAL=='"+xFilial("DUD")+"' .AND. DUD_FILORI=='"+ DTX->DTX_FILORI +"' .AND. DUD_VIAGEM=='"+ DTX->DTX_VIAGEM +"' .AND. DUD_FILMAN=='"+ DTX->DTX_FILMAN+"' .AND. DUD_MANIFE=='"+ DTX->DTX_MANIFE+"'",DUD->(IndexKey()))
 		DUD->(dbGotop())
        
        Do While !DUD->(Eof ()) 	  

   			DT6->(dbSetOrder(1)) 
   			DT6->(dbSeek(xFilial("DT6")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE)) 
             

			 DTC->(dbSetOrder(3))
			 SA1->(dbSetOrder(1)) 
			 SB1->(dbSetOrder(1)) 

			FsQuery(aDtc,1,"DTC_FILIAL='"+ xFilial("DTC") +"' AND DTC_FILDOC='"+ DT6->DT6_FILDOC +"' AND DTC_DOC='"+ DT6->DT6_DOC +"' AND DTC_SERIE='"+ DT6->DT6_SERIE+"'","DTC_FILIAL=='"+xFilial("DTC")+"' .AND. DTC_FILDOC=='"+ DT6->DT6_FILDOC +"' .AND. DTC_DOC=='"+ DT6->DT6_DOC+"' .AND. DTC_SERIE=='"+ DT6->DT6_SERIE+"'",DTC->(IndexKey()))
			DTC->(dbGotop())
			
			Do While !DTC->(Eof ()) 	  
			
			 SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES))
			 SB1->(dbSeek(xFilial("SB1")+DTC->DTC_CODPRO))
			 cCGCDest := SA1->A1_CGC
             

             If "E"$cTipMan
               cIEDest := SA1->A1_INSCR
             else
               cIEDest :=" "               
             endif                         
             
             cUFDest := SA1->A1_EST
			 SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM))
			 cCGCRem := SA1->A1_CGC


             If "S"$cTipMan
               cIERem := SA1->A1_INSCR
             else
               cIERem := " "
             endif          

			 cUFRem := SA1->A1_EST
			 

			  If (("E"$cTipMan) .AND. (cUFDest=="MS").AND.(cUFRem<>"MS" )) .OR. (("S"$cTipMan) .AND. (cUFDest<>"MS").AND.(cUFRem=="MS" )) .OR. (("G"$cTipMan) .AND. (cUFDest<>"MS").AND.(cUFRem<>"MS" ))
			  
      		          
					  SBM->(dbSeek(xFilial("SBM")+SB1->B1_GRUPO))
		               
		              dbSelectArea("RT2")
		              
					   RecLock("RT2",.T.)
			           nContDoc++         
			           nContIten:=0
			            
					    RT2->TPOREG     := 40
					    RT2->CHAVE      := " "
					    RT2->ESP1       := " "
						RT2->NUMMAN     := VAL(DTX->DTX_MANIFE)
						RT2->ESP2       := " "
						RT2->SEQDOCM    := nContDoc
						RT2->ESP3       := " "
						RT2->TIPPROD    := VAL(SBM->BM_TIPGRU)
						RT2->ESP4       := " "
						RT2->NATUOPE    := 1
						RT2->ESP5       := " "
						RT2->CNPJREM    := cCGCRem
						RT2->ESP6       := " "
						RT2->UFREM      := cUFRem
						RT2->ESP7       := " "
						RT2->CNPJDES    := cCGCDest
						RT2->ESP8       := " "
						RT2->UFDES      := cUFDest
						RT2->ESP9       := " "
						RT2->IEDES      := cIEDest
						RT2->ESP10      := " "
						RT2->IEREM      := cIERem
						RT2->ESP11      := " "
						RT2->NUMNF      := PADL(DTC->DTC_NUMNFC,8)
						RT2->ESP12      := " "
						RT2->DATEMI     := DataInt(DTC->DTC_EMINFC)
						RT2->ESP13      := " "
						RT2->VALNF      := DTC->DTC_VALOR
						RT2->ESP14      := " " 
						RT2->ICMSSUB    := DTC->DTC_ICMRET
						RT2->ESP15      := " "
						RT2->TIPDOC     := "N"
						RT2->ESP16      := " "
						RT2->DESMERC    := SB1->B1_DESC 
						RT2->ESP17      := " "
						RT2->NUMCON     := val(DT6->DT6_DOC)  
						
				      MsUnlock() 
				 
				     			
				    If (SBM->BM_TIPGRU ="2") .OR. (SBM->BM_TIPGRU ="3")
				    
				     dbSelectArea("RT3")
		              RecLock("RT3",.T.)	 
					    nContIten++
						RT3->TPOREG     := 50
						RT3->CHAVE      := " "
						RT3->ESP1       := " "
						RT3->NUMMAN     := VAL(DTX->DTX_MANIFE)
						RT3->ESP2       := " "
						RT3->SEQDOC     := nContIten 
						RT3->ESP3       := " "
						RT3->NUMNF      := PADL(DTC->DTC_NUMNFC,8)
						RT3->ESP4       := " "
						RT3->CODPRO     := Replicate(" ",8-Len(Alltrim(DTC->DTC_CODPRO))) + Alltrim(DTC->DTC_CODPRO)
						RT3->ESP5       := " "
						RT3->DESPROD    := SB1->B1_DESC
						RT3->ESP6       := " "
						RT3->UNI        := SB1->B1_UM
						RT3->ESP7       := " "
						RT3->QTDPROD    := DTC->DTC_QTDVOL
						RT3->ESP8       := " "
						RT3->VALUNI     := DTC->DTC_VALOR
						RT3->NUMCON     := val(DT6->DT6_DOC)
					
		              MsUnlock() 
		            EndIf  
		      EndIf        
                       
            DTC->(dbSkip())
            Enddo
            FsQuery (aDtc,2,)
            
        DUD->(dbSkip())
        Enddo
        FsQuery (aDud,2,)

   DTX->(dbSkip())
   Enddo     
   FsQuery (aDtx,2,) 
                          
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
	Local aStru1	:= {}
	Local aStru2	:= {}
    Local aStru3	:= {}
    Local aTrbs		:= {}
	Local cArq		:= ""
	                        
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo 30 - Informações dos Manifestos 											          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	aStru1	:= {}
	cArq	:= ""
	AADD(aStru1,{"TPOREG"   	,"N",002,0})	//Tipo do Registro
    AADD(aStru1,{"CHAVE"   		,"C",033,0})	//Chave
    AADD(aStru1,{"ESP1"    		,"C",001,0})	//Epaco
    AADD(aStru1,{"NUMMAN"    	,"N",008,0})	//Numero Manifesto
    AADD(aStru1,{"ESP2"    		,"C",001,0})	//Epaco
    AADD(aStru1,{"TPOMAN"  		,"C",001,0})	//TIPO DE MANIFESTO
    AADD(aStru1,{"ESP3"    		,"C",001,0})	//Epaco
    AADD(aStru1,{"QTDNF"   		,"N",003,0})	//QUANTIDADE DE NOTAS
    AADD(aStru1,{"ESP4"    		,"C",001,0})	//Epaco    
    AADD(aStru1,{"VALNFS"  		,"N",015,2})	//VALOR TOTAL DAS NOTAS
    AADD(aStru1,{"ESP5"    		,"C",001,0})	//Epaco    
    AADD(aStru1,{"PESOTOT" 		,"N",009,3})	//PESO TOTAL
    AADD(aStru1,{"ESP6"    		,"C",001,0})	//Epaco        
    AADD(aStru1,{"POSTSAI"    	,"C",003,0})	//POSTSAI
    cArq := CriaTrab(aStru1)
	dbUseArea(.T.,__LocalDriver,cArq,"RT1")                      	
	IndRegua("RT1",cArq,"Str(NUMMAN,8)")
	AADD(aTrbs,{cArq,"RT1"})
	                   
	
		
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo 40 - Informações das Notas Fiscais do Manifesto 											      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aStru2	:= {}
	cArq	:= ""
	AADD(aStru2,{"TPOREG"   	,"N",002,0})	//Tipo do Registro
    AADD(aStru2,{"CHAVE"   		,"C",033,0})	//Chave
    AADD(aStru2,{"ESP1"    		,"C",001,0})	//Epaco
    AADD(aStru2,{"NUMMAN"    	,"N",008,0})	//Numer	o Manifesto
    AADD(aStru2,{"ESP2"    		,"C",001,0})	//Epaco
    AADD(aStru2,{"SEQDOCM"    	,"N",004,0})	//Sequencia Documento Manifesto
    AADD(aStru2,{"ESP3"    		,"C",001,0})	//Epaco
    AADD(aStru2,{"TIPPROD"    	,"N",001,0})	//Tipo do Produto
    AADD(aStru2,{"ESP4"    		,"C",001,0})	//Epaco    
    AADD(aStru2,{"NATUOPE"    	,"N",001,0})	//Natureza 
    AADD(aStru2,{"ESP5"    		,"C",001,0})	//Epaco    
    AADD(aStru2,{"CNPJREM"    	,"C",014,0})	//CNPJ REMETENTE
    AADD(aStru2,{"ESP6"    		,"C",001,0})	//Epaco        
    AADD(aStru2,{"UFREM"   		,"C",002,0})	//UF REMETENTE
    AADD(aStru2,{"ESP7"    		,"C",001,0})	//Epaco 
    AADD(aStru2,{"CNPJDES"    	,"C",014,0})	//CNPJ DESTINATARIO    
    AADD(aStru2,{"ESP8"    		,"C",001,0})	//Epaco         
    AADD(aStru2,{"UFDES"   		,"C",002,0})	//UF DESTINATARIO
    AADD(aStru2,{"ESP9"    		,"C",001,0})	//Epaco                                                                      
    AADD(aStru2,{"IEDES"   		,"C",009,0})	//INSCRICAO ESTADUAL DESTINATARIO                                                                      
    AADD(aStru2,{"ESP10"   		,"C",001,0})	//Epaco                                                                      
    AADD(aStru2,{"IEREM"   		,"C",009,0})	//INSCRICAO ESTADUAL REMETENTE                                                                      
    AADD(aStru2,{"ESP11"  		,"C",001,0})	//Epaco                                                                          
    AADD(aStru2,{"NUMNF"  		,"C",008,0})	//NOTA FISCAL                                                                         
    AADD(aStru2,{"ESP12"  		,"C",001,0})	//Epaco                                                                          
    AADD(aStru2,{"DATEMI"  		,"C",008,0})	//DATA EMISSAO NOTA FISCAL                                                                          
    AADD(aStru2,{"ESP13"  		,"C",001,0})	//Epaco                                                                          
    AADD(aStru2,{"VALNF"  		,"N",015,2})	//VALOR NOTA FISCAL
    AADD(aStru2,{"ESP14"  		,"C",001,0})	//Epaco
    AADD(aStru2,{"ICMSSUB" 		,"N",015,2})	//VALOR ICMS RETIDO SUBST. TRIB.                                                                                                                                                        
    AADD(aStru2,{"ESP15"  		,"C",001,0})	//Epaco
    AADD(aStru2,{"TIPDOC"  		,"C",001,0})	//TIPO DE DOCUMENTO
    AADD(aStru2,{"ESP16"  		,"C",001,0})	//Epaco
    AADD(aStru2,{"DESMERC"  	,"C",030,0})	//DESC. MERCADORIA    
    AADD(aStru2,{"ESP17"  		,"C",001,0})	//Epaco
    AADD(aStru2,{"NUMCON"  		,"N",008,0})	//NUMERO DO CONHECIMENTO
    cArq := CriaTrab(aStru2)
	dbUseArea(.T.,__LocalDriver,cArq,"RT2")                      	
	IndRegua("RT2",cArq,"Str(NUMMAN,8)+Str(SEQDOCM,4)")
	AADD(aTrbs,{cArq,"RT2"})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo 50 - Itens das Notas Fiscais                                                                     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru3	:= {}
	cArq	:= ""	
	AADD(aStru3,{"TPOREG"   	,"N",002,0})	//Tipo do Registro
	AADD(aStru3,{"CHAVE"    	,"C",033,0}) 	//CHAVE
	AADD(aStru3,{"ESP1"      	,"C",001,0})	//ESPACO
	AADD(aStru3,{"NUMMAN"  		,"N",008,0})	//NUMERO MANIFESTO
	AADD(aStru3,{"ESP2"    		,"C",001,0}) 	//ESPACO
	AADD(aStru3,{"SEQDOC"    	,"N",004,0})	//SEQUENCIA DOCTO
	AADD(aStru3,{"ESP3"  		,"C",001,0})	//ESPACO	
	AADD(aStru3,{"NUMNF"       	,"C",008,0})	//Numero NF
	AADD(aStru3,{"ESP4"  		,"C",001,0})	//ESPACO
	AADD(aStru3,{"CODPRO"      	,"C",008,0})	//CODIGO PRODUTO
	AADD(aStru3,{"ESP5"      	,"C",001,0})	//ESPACO
	AADD(aStru3,{"DESPROD"     	,"C",030,0})	//DESC. PRODUTO
	AADD(aStru3,{"ESP6"      	,"C",001,0})	//ESPACO
	AADD(aStru3,{"UNI"       	,"C",003,0})	//UNIDADE MEDIDA
	AADD(aStru3,{"ESP7"      	,"C",001,0})	//ESPACO
	AADD(aStru3,{"QTDPROD"      ,"N",010,3})	//QUANTIDADE PRODUTO
	AADD(aStru3,{"ESP8" 	    ,"C",001,0})	//ESPACO
	AADD(aStru3,{"VALUNI"      	,"N",013,2})	//VALOR UNITARIO
	AADD(aStru3,{"NUMCON"  		,"N",008,0})	//NUMERO DO CONHECIMENTO
	cArq := CriaTrab(aStru3)
	dbUseArea(.T.,__LocalDriver,cArq,"RT3")
	IndRegua("RT3",cArq,"NUMNF+Str(NUMCON,8)+ Str(NUMMAN,8)+Str(SEQDOC,4)")
	AADD(aTrbs,{cArq,"RT3"})
	
Return (aTrbs)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EDIMSDel    ºAutor  ³Cleber S. A. Santos º Data ³ 28.09.2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³EDIMSDel                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
         
Function EDIMSDel(aDelArqs)
	Local aAreaDel := GetArea()
	Local nI := 0
	
	For nI:= 1 To Len(aDelArqs)
		If File(aDelArqs[nI,1]+GetDBExtension())
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[nI,1]+GetDBExtension())
			Ferase(aDelArqs[nI,1]+OrdBagExt())
		Endif	
	Next
	
	RestArea(aAreaDel)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CALCMANIF ³ Autor ³Cleber Stenio A. Stos  ³ Data ³08/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o total de Manifestos para a viagem informada.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³Retorno   ³ Total de registros                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CalcManif(cCond1,cCond2)         
Local   aDtx        := {"DTX",""}
Local   nRes        := 0
Local   nContManif  := 0         
    
		    DbSelectArea ("DTX")
		    DTX->(dbSetOrder(3))
		    FsQuery(aDtx,1,"DTX_FILIAL='"+ xFilial("DTX") +"' AND DTX_FILORI='"+ cCond1+"' AND DTX_VIAGEM='"+ cCond2+"'","DTX_FILIAL=='"+ xFilial("DTX") +"' AND DTX_FILORI=='"+ cCond1+"' AND DTX_VIAGEM=='"+ cCond2+"'",DTX->(IndexKey()))
		    DTX->(dbGotop())
            
            Do While !DTX->(Eof ())              		  
              nContManif++                                
  
              DTX->(dbSkip())		           
	        Enddo   
	        
	        nRes:= nContManif	                      
            FsQuery (aDtx,2,)	 
          	dbCloseArea()
	
Return(nRes)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CALCDOCTOS³ Autor ³Cleber Stenio A. Stos  ³ Data ³09/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o total de documentos(NF) do manifesto informado.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³Retorno   ³ Total de registros                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CalcDoctos(cCond1,cCond2,cCond3,cCond4)         
Local   aDud        := {"DUD",""}
Local   nRes        := {}
Local   nContDOC   	:= 0 
Local   nSomaVal    := 0     
Local   nSomaPeso   := 0
    
		    DbSelectArea ("DUD")
		    DUD->(dbSetOrder(5))
		    FsQuery(aDud,1,"DUD_FILIAL='"+ xFilial("DUD") +"' AND DUD_FILORI='"+ cCond1+"' AND DUD_VIAGEM='"+ cCond2+"' AND DUD_FILMAN='"+ cCond3+"' AND DUD_MANIFE='"+ cCond4+"'","DUD_FILIAL=='"+xFilial("DUD")+"' .AND. DUD_FILORI=='"+ cCond1+"' .AND. DUD_VIAGEM=='"+ cCond2+"' .AND. DUD_FILMAN=='"+ cCond3+"' .AND. DUD_MANIFE=='"+ cCond4+"'",DUD->(IndexKey()))
		    DUD->(dbGotop())
            
            Do While !DUD->(Eof ())              		  
              nContDOC++   
              
                DbSelectArea ("DT6")
				DT6->(DbSetOrder (1))
				DT6->(dbSeek(xFilial("DT6")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))
              
                nSomaVal:= nSomaVal + (DT6->DT6_VALMER)
                nSomaPeso:= nSomaPeso + (DT6->DT6_PESO)                                
  
              DUD->(dbSkip())		           
	        Enddo   
	        
	        nRes:= {nContDOC,nSomaVal,nSomaPeso}	                      
	        
	        FsQuery (aDud,2,)	 
          	dbCloseArea()
          	dbCloseArea()
          	
	
Return(nRes)                              
