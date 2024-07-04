#Include "Protheus.Ch"          


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³EDIPE     ³ Autor ³  Cleber S. A. Santos  ³ Data ³ 28.09.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³EDIPE - Informações de Cargas Transportadas através do      ³±±
±±³          ³Estado de Pernambuco - PE                         		    ³±±
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
Function ProcEDIPE(cTipArq,cNumManif,cTipMan,dDatIni,dDataFin)
	Local aTrbs		:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera arquivos temporarios            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTrbs := GeraTemp()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa Registros                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
    ProcReg(cTipArq,cNumManif,cTipMan,dDatIni,dDataFin)                          

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
Static Function ProcReg(cTipArq,cNumManif,cTipMan,dDatIni,dDataFin)
   Local aDud         	:= {"DUD",""}
   Local aDtx         	:= {"DTX",""}
   Local aDtc        	:= {"DTC",""}
   Local cCGCDest	   :=	""
   Local cCGCRem	   		:=	""
   Local cIEDest	   		:=	""
   Local cIERem	    	:=	""
   Local cUFDest     	:=	""
   Local cUFRem     	:=	""
   Local nCont      	:=	0
   Local nValorICMS  	:=	0
   Local nValorNF    	:=	0
   Local nValorICMSSUB	:=	0 
   Local nTotalNF    	:=	0
   Local cNumNF      	:=	""
       
   DTX->(dbSetOrder(3))
   //Se for varios manifestos considera periodo
   IiF("2"$cTipMan,FsQuery(aDtx,1,"DTX_FILIAL='"+ xFilial("DTX")+"' AND DTX_DATMAN>='"+DTOS(dDatIni)+"' AND DTX_DATMAN<='"+DTOS(dDataFin)+"'",DTX->(IndexKey())),FsQuery(aDtx,1,"DTX_FILIAL='"+ xFilial("DTX") +"' AND DTX_MANIFE='"+cNumManif+"'",DTX->(IndexKey())))
   DTX->(dbGotop())
			    			
	Do While !DTX->(Eof ())
		nCont:=0
		nCont++
		nTotalNF:= 0
		nTotalNF:= CalcNFCS(DTX->DTX_FILORI,DTX->DTX_VIAGEM,DTX->DTX_FILMAN,DTX->DTX_MANIFE)
		
		If nTotalNF > 0
			
			dbSelectArea("RT1")
			
			RecLock("RT1",.T.)
			RT1->SEQH       := nCont
			RT1->TIPO       := 1
			RT1->TPOMFTO    :="MANIFESTO"
			RT1->NROMFTO    := DTX->DTX_MANIFE
			RT1->DTAGER     := FormDate(dDataBase)
			RT1->HORGER     := TIME()
			RT1->RETIFIC    := Iif ("1"$cTipArq,"N","S")
			RT1->HEADERF    := ""
			RT1->TOTNF      := nTotalNF
			
			MsUnlock()
			
			DUD->(dbSetOrder(5))
			FsQuery(aDud,1,"DUD_FILIAL='"+ xFilial("DUD") +"' AND DUD_FILORI='"+ DTX->DTX_FILORI +"' AND DUD_VIAGEM='"+ DTX->DTX_VIAGEM+"' AND DUD_FILMAN='"+ DTX->DTX_FILMAN+"' AND DUD_MANIFE='"+ DTX->DTX_MANIFE+"'","DUD_FILIAL=='"+xFilial("DUD")+"' .AND. DUD_FILORI=='"+ DTX->DTX_FILORI +"' .AND. DUD_VIAGEM=='"+ DTX->DTX_VIAGEM +"' .AND. DUD_FILMAN=='"+ DTX->DTX_FILMAN+"' .AND. DUD_MANIFE=='"+ DTX->DTX_MANIFE+"'",DUD->(IndexKey()))
			DUD->(dbGotop())
			
			Do While !DUD->(Eof ())
				
				DT6->(dbSetOrder(1))
				DT6->(dbSeek(xFilial("DT6")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))
				
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES))
				cCGCDest := SA1->A1_CGC
				cIEDest  := SA1->A1_INSCR
				cUFDest  := SA1->A1_EST
				
				SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM))
				cCGCRem := SA1->A1_CGC
				cIERem  := SA1->A1_INSCR
				cUFRem  := SA1->A1_EST
				
				If cUFDest=="PE"
					
					DTC->(dbSetOrder(7))//Usa-se esse indice para que ele traga em ordem as notas fiscais
					FsQuery(aDtc,1,"DTC_FILIAL='"+ xFilial("DTC") +"' AND DTC_FILDOC='"+ DT6->DT6_FILDOC +"' AND DTC_DOC='"+ DT6->DT6_DOC +"' AND DTC_SERIE='"+ DT6->DT6_SERIE+"'","DTC_FILIAL=='"+xFilial("DTC")+"' .AND. DTC_FILDOC=='"+ DT6->DT6_FILDOC +"' .AND. DTC_DOC=='"+ DT6->DT6_DOC+"' .AND. DTC_SERIE=='"+ DT6->DT6_SERIE+"'",DTC->(IndexKey()))
					DTC->(dbGotop())
					
					Do While !DTC->(Eof())
												
						dbSelectArea("RT2")
						
						RecLock("RT2",.T.)
						nCont++						
						
						RT2->SEQD       := nCont
						RT2->TIPO       := 2
						RT2->UFEMIT     := cUFRem
						RT2->CNPJREM    := cCGCRem
						RT2->INSCREM    := cIERem
						RT2->UFDEST     := cUFDest
						RT2->CNPJDEST   := cCGCDest
						RT2->INSCDEST   := cIEDest
						RT2->NF         := RetNf(DTC->DTC_NUMNFC,07,"N")
						RT2->SERIE      := aFisFill(SerieNfId("DTC",2,"DTC_SERNFC"),02)
						RT2->DTEMI      := FormDate(DTC->DTC_EMINFC)
						
						cNumNF           := (DTC->DTC_NUMNFC + DTC->DTC_SERNFC)
						
						//Caso exista mais que uma nota somar os valores
						Do while cNumNF  ==  (DTC->DTC_NUMNFC + DTC->DTC_SERNFC)

							nValorNF      := nValorNF + DTC->DTC_VALOR
							nValorICMS    := nValorICMS + DTC->DTC_VALICM
							nValorICMSSUB := nValorICMSSUB + DTC->DTC_ICMRET
							
							DTC->(dbSkip())
						enddo
						
						RT2->VALORNF    := nValorNF
						RT2->VALORICM   := nValorICMS
						RT2->ICMSUBST   := nValorICMSSUB
						RT2->BASEICM    := nValorNF
						RT2->ICMSFRETE  := 0
						RT2->PESO       := DT6->DT6_PESO
						RT2->NROMFTO    := DTX->DTX_MANIFE
						
						//Zerar variaveis
						nValorNF        :=0
						nValorICMS      :=0
						nValorICMSSUB   :=0
						
						MsUnlock()
						
					Enddo
					FsQuery (aDtc,2,)
					
				Endif
				
				DUD->(dbSkip())
			Enddo
			FsQuery (aDud,2,)
			
			dbSelectArea("RT3")
			RecLock("RT3",.T.)
			
			nCont++
			RT3->SEQT       := nCont
			RT3->TPOREGT    := 9
			RT3->QTDREG     := nCont
			RT3->TRAF       := ""
			RT3->NROMFTO    := DTX->DTX_MANIFE
			MsUnlock()
		EndIf
		
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
//³Registro Tipo 1 - Informações dos Manifestos (Header)											              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru1	:= {}
cArq	:= ""
AADD(aStru1,{"SEQH"         	,"N",006,0})	//Sequencia
AADD(aStru1,{"TIPO"         	,"N",001,0})	//Tipo do Registro
AADD(aStru1,{"TPOMFTO"   		,"C",015,0})	//Tipo do Arquivo
AADD(aStru1,{"NROMFTO"    		,"C",020,0})	//Numero Manifesto
AADD(aStru1,{"DTAGER"    	    ,"C",010,0})	//Data Geracao
AADD(aStru1,{"HORGER"    		,"C",010,0})	//Hora Geracao
AADD(aStru1,{"RETIFIC"  		,"C",001,0})	//Retificacao 'S' ou 'N'
AADD(aStru1,{"HEADERF"    		,"C",098,0})	//Brancos
AADD(aStru1,{"TOTNF"    		,"N",009,0})	//Total de NFs
cArq := CriaTrab(aStru1)
dbUseArea(.T.,__LocalDriver,cArq,"RT1")
IndRegua("RT1",cArq,"NROMFTO")
AADD(aTrbs,{cArq,"RT1"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 2 - Informações das Notas Fiscais do Manifesto (Detalhe)   								      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru2	:= {}
cArq	:= ""
AADD(aStru2,{"SEQD"      	,"N",006,0})	//Sequencia
AADD(aStru2,{"TIPO"     	,"N",001,0})	//Tipo do Registro
AADD(aStru2,{"UFEMIT"    	,"C",002,0})	//UF REMETENTE
AADD(aStru2,{"CNPJREM"    	,"C",014,0})	//CNPJ REMETENTE
AADD(aStru2,{"INSCREM"    	,"C",020,0})	//INSCRICAO ESTADUAL REMETENTE
AADD(aStru2,{"UFDEST"    	,"C",002,0})	//UF DESTINATARIO
AADD(aStru2,{"CNPJDEST"   	,"C",014,0})	//CNPJ DESTINATARIO
AADD(aStru2,{"INSCDEST"    	,"C",020,0})	//INSCRICAO ESTADUAL DESTINATARIO
AADD(aStru2,{"NF"   		,"C",007,0})	//NOTA FISCAL
AADD(aStru2,{"SERIE"   		,"C",002,0})	//SERIE NF
AADD(aStru2,{"DTEMI"   		,"C",010,0})	//DATA EMISSAO NOTA FISCAL
AADD(aStru2,{"VALORNF"  	,"N",011,2})	//VALOR NOTA FISCAL
AADD(aStru2,{"VALORICM" 	,"N",011,2})	//VALOR ICMS
AADD(aStru2,{"ICMSUBST" 	,"N",011,2})	//VALOR ICMS RETIDO SUBST. TRIB.
AADD(aStru2,{"ICMSFRETE"  	,"N",011,2})	//VALOR ICMS FRETE
AADD(aStru2,{"BASEICM"  	,"N",011,2})	//VALOR BASE ICMS
AADD(aStru2,{"PESO"  		,"N",008,2})	//PESO
AADD(aStru2,{"NROMFTO"    	,"C",020,0})	//Numero Manifesto
cArq := CriaTrab(aStru2)
dbUseArea(.T.,__LocalDriver,cArq,"RT2")
IndRegua("RT2",cArq,"NROMFTO + NF + SERIE")
AADD(aTrbs,{cArq,"RT2"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 9 - Totalizador do Manifesto (Trailler)													      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru3	:= {}
cArq	:= ""
AADD(aStru3,{"SEQT"   	    ,"N",006,0})	//Sequencia
AADD(aStru3,{"TPOREGT"    	,"N",001,0}) 	//Tipo do Registro
AADD(aStru3,{"QTDREG"      	,"N",007,0})	//Quantidade de Registros
AADD(aStru3,{"TRAF"  		,"C",147,0})	//Brancos
AADD(aStru3,{"NROMFTO"  	,"C",020,0})	//Numero Manifesto
cArq := CriaTrab(aStru3)
dbUseArea(.T.,__LocalDriver,cArq,"RT3")
IndRegua("RT3",cArq,"NROMFTO")
AADD(aTrbs,{cArq,"RT3"})

	
Return (aTrbs)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EDIPEDel    ºAutor  ³Cleber S. A. Santos º Data ³ 28.09.2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³EDIPEDel                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
         
Function EDIPEDel(aDelArqs)
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
±±³Program   ³CALCNFCS  ³ Autor ³Cleber Stenio A. Stos  ³ Data ³09/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o total de Notas Fiscais do Cliente para o Docto.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³Retorno   ³ Total de registros                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CalcNFCS(cCond1,cCond2,cCond3,cCond4)

	Local   aDtc        := {"DTC",""}
	Local   aDud        := {"DUD",""}
	Local   nRes        := 0
	Local   nContNF   	:= 0
	Local   cNumNF   	:= ""
	
	DbSelectArea ("DUD")
	DUD->(dbSetOrder(5))
	FsQuery(aDud,1,"DUD_FILIAL='"+ xFilial("DUD") +"' AND DUD_FILORI='"+ cCond1+"' AND DUD_VIAGEM='"+ cCond2+"' AND DUD_FILMAN='"+ cCond3+"' AND DUD_MANIFE='"+ cCond4+"'","DUD_FILIAL=='"+xFilial("DUD")+"' .AND. DUD_FILORI=='"+ cCond1+"' .AND. DUD_VIAGEM=='"+ cCond2+"' .AND. DUD_FILMAN=='"+ cCond3+"' .AND. DUD_MANIFE=='"+ cCond4+"'",DUD->(IndexKey()))
	DUD->(dbGotop())
	
	Do While !DUD->(Eof ())
		
		DbSelectArea ("DT6")
		DT6->(DbSetOrder (1))
		DT6->(dbSeek(xFilial("DT6")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))
		
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES))
		cUFDest  := SA1->A1_EST
		
		If cUFDest=="PE"
			
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
			
		EndIf
		
		DUD->(dbSkip())
	Enddo
	
	FsQuery (aDud,2,)
	
	nRes:= nContNF
	
	dbCloseArea()
	
Return(nRes)

