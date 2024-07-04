#Include "Protheus.Ch"          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³EDIPI     ³ Autor ³  Cleber S. A. Santos  ³ Data ³ 28.09.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³EDIPI - Informações de Cargas Transportadas através do      ³±±
±±³          ³Estado do Piaui - PI                         		          ³±±
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
Function ProcEDIPI(cFilMan,cNumManif,cTipArq,cTipMan,cEmail,dDatIni,dDataFin)

Local 		Trbs	:= {}
Private 	lEnd	:= .F.
Private	nHandle

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivos temporarios            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTrbs := GeraTemp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Registros                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
ProcReg(cFilMan,cNumManif,cTipArq,cTipMan,cEmail,dDatIni,dDataFin)
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Temporária                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraEDIPI()
	
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
Static Function ProcReg(cFilMan,cNumManif,cTipArq,cTipMan,cEmail,dDatIni,dDataFin)

Local cAliasDTX 	:= GetNextAlias()
Local cAliasDUD 	:= GetNextAlias()
Local cAliasDTC 	:= GetNextAlias()
Local aDud		:= {"DUD","",cAliasDUD}
Local aDtx		:= {"DTX","",cAliasDTX}
Local aDtc		:= {"DTC","",cAliasDTC}
Local cCGCDest	:=	""
Local cCGCRem		:=	""
Local cIEDest		:=	""
Local cIERem		:=	""
Local cUFDest		:=	""
Local cUFRem		:=	""
Local cDatIni		:=	DTOS(dDatIni)
Local cDatFin		:=	DTOS(dDataFin) 
Local lEdiPiMan	:=	ExistBlock("EDIPIMAN")
Local aManif		:= {}
Local cEstDes		:= ""
       
//Se for varios manifestos considera periodo
IiF("2"$cTipArq,FsQuery(aDtx,;
	1,;
	"DTX_FILIAL='"+ xFilial("DTX")+"' AND DTX_FILMAN ='"+cFilMan +"' AND DTX_DATMAN BETWEEN '"+cDatIni+"' AND '"+cDatFin+"'",DTX->(IndexKey())),;
	FsQuery(aDtx,;
	1,;
	"DTX_FILIAL='"+ xFilial("DTX") +"' AND DTX_FILMAN='"+cFilMan +"' AND DTX_MANIFE LIKE ('"+AllTrim(cNumManif)+"%')",DTX->(IndexKey())))

(cAliasDTX)->(dbGotop())

//Carrego todos os manifestos referentes a viagem
Do While !(cAliasDTX)->(Eof ())
	AADD(aManif,{AllTrim((cAliasDTX)->DTX_MANIFE)})
	(cAliasDTX)->(dbSkip())
EndDo

//Executo ponto de entrada
If lEdiPiMan
	aManif := ExecBlock('EDIPIMAN',.F.,.F.,aManif)
EndIf

(cAliasDTX)->(dbGotop())
Do While !(cAliasDTX)->(Eof())
	//------------------------------------------------------------------------------------------
	//Este tratamento foi feito para que não ocorra a duplicidade na impressão dos manifestos
	//no arquivo, quando o manifesto tiver algum campo CARACTERE devido a tratamentos diversos.
	//------------------------------------------------------------------------------------------
	If (aScan(aManif, { |x|  x[1] == AllTrim( (cAliasDTX)->DTX_MANIFE ) }) > 0)
		//------------------------------------------------------------------------------------------
		aAreaSM0 := SM0->(GetArea())
		SM0->(dbSeek(cEmpAnt+(cAliasDTX)->DTX_FILDCA))
		cEstDes := SM0->M0_ESTENT
		RestArea(aAreaSM0)
		
		If (cEstDes == "PI")
			
			nTotalNF:= 0
			nTotalNF:= VerNFPI((cAliasDTX)->DTX_FILORI,(cAliasDTX)->DTX_VIAGEM,(cAliasDTX)->DTX_FILMAN,(cAliasDTX)->DTX_MANIFE,cTipMan)
			
			If nTotalNF > 0
				
				DbSelectArea("RT1")
				
				RecLock("RT1",.T.)
				RT1->TIPO    := "MC"
				RT1->CNPJT   := SM0->M0_CGC
				RT1->NROMANI := Val((cAliasDTX)->DTX_MANIFE)
				RT1->TPOMANI := SubStr(cTipMan,1,1)
				RT1->EMAIL   := cEmail
				
				MsUnlock()
				
				DUD->(dbSetOrder(5))
				FsQuery(aDud,;
					1,;
					"DUD_FILIAL='"+ xFilial("DUD") +"' AND DUD_FILORI='"+ (cAliasDTX)->DTX_FILORI +"' AND DUD_VIAGEM='"+ (cAliasDTX)->DTX_VIAGEM+;
					"' AND DUD_FILMAN='"+ (cAliasDTX)->DTX_FILMAN+"' AND DUD_MANIFE='"+ (cAliasDTX)->DTX_MANIFE+"'","DUD_FILIAL=='"+xFilial("DUD")+;
					"' .AND. DUD_FILORI=='"+ (cAliasDTX)->DTX_FILORI +"' .AND. DUD_VIAGEM=='"+ (cAliasDTX)->DTX_VIAGEM +"' .AND. DUD_FILMAN=='"+ (cAliasDTX)->DTX_FILMAN+;
					"' .AND. DUD_MANIFE=='"+ (cAliasDTX)->DTX_MANIFE+"'",DUD->(IndexKey()))
				(cAliasDUD)->(dbGotop())
				
				Do While !(cAliasDUD)->(Eof ())
					
					DT6->(dbSetOrder(1))
					DT6->(dbSeek(xFilial("DT6")+(cAliasDUD)->DUD_FILDOC+(cAliasDUD)->DUD_DOC+(cAliasDUD)->DUD_SERIE))
					
					SA1->(dbSetOrder(1))
					SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES))
					cCGCDest := SA1->A1_CGC
					cIEDest  := SA1->A1_INSCR
					cUFDest  := SA1->A1_EST
					
					SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM))
					cCGCRem := SA1->A1_CGC
					cIERem  := SA1->A1_INSCR
					cUFRem  := SA1->A1_EST
					
					If (at(Substr(cTipMan,1,1),"EIN")>0 .AND. cUFDest=="PI") .Or. (at(Substr(cTipMan,1,1),"SX")>0 .AND. cUFDest<>"PI")
						SF2->(dbSetOrder(1))
						SF2->(dbSeek(xFilial("SF2")+(cAliasDUD)->DUD_DOC+(cAliasDUD)->DUD_SERIE))
						
						DVA->(dbSetOrder(1))
						DVA->(dbSeek(xFilial("DVA")+DT6->DT6_CDRORI+DT6->DT6_CDRDES+DT6->DT6_TIPTRA))
						
						DbSelectArea("RT2")
						RecLock("RT2",.T.)
						
						RT2->TIPO		:= "CC"
						RT2->NROMANI   := Val((cAliasDTX)->DTX_MANIFE)
						RT2->NROCON    := Val(DT6->DT6_DOC)
						RT2->CNPJEM    := SM0->M0_CGC
						RT2->UFEMI     := SM0->M0_ESTENT
						RT2->CSERIE    := SerieNfId("DT6",2,"DT6_SERIE")
						RT2->BASECON   := DT6->DT6_VALTOT
						RT2->VALICMS   := SF2->F2_VALICM
						RT2->VALFRETE  := DT6->DT6_VALFRE
						RT2->DISTAN    := DVA->DVA_KM
						
						MsUnlock()
						
						DTC->(dbSetOrder(3))
						FsQuery(aDtc,1,"DTC_FILIAL='"+ xFilial("DTC") +"' AND DTC_FILDOC='"+ DT6->DT6_FILDOC +"' AND DTC_DOC='"+ DT6->DT6_DOC +;
							"' AND DTC_SERIE='"+ DT6->DT6_SERIE+"'","DTC_FILIAL=='"+xFilial("DTC")+"' .AND. DTC_FILDOC=='"+ DT6->DT6_FILDOC +;
							"' .AND. DTC_DOC=='"+ DT6->DT6_DOC+"' .AND. DTC_SERIE=='"+ DT6->DT6_SERIE+"'",DTC->(IndexKey()))
						(cAliasDTC)->(dbGotop())
						
						Do While !(cAliasDTC)->(Eof())
							
							dbSelectArea("RT3")
							
							If  RT3->(dbseek(Str(Val((cAliasDTX)->DTX_MANIFE),16)+Str(Val(DT6->DT6_DOC),16)+Str(Val((cAliasDTC)->DTC_NUMNFC),16)+(cAliasDTC)->DTC_SERNFC))
								RecLock("RT3",.F.)
							Else
								RecLock("RT3",.T.)
							Endif
							
							RT3->TIPO       := "NF"
							RT3->NROMANI    := Val((cAliasDTX)->DTX_MANIFE)
							RT3->NF			:= Val((cAliasDTC)->DTC_NUMNFC)
							RT3->SERIE		:= (cAliasDTC)->DTC_SERNFC
							RT3->UFREM		:= cUFRem
							RT3->CNPJREM	:= cCGCRem
							RT3->DTEMI		:= DATAINT((cAliasDTC)->DTC_EMINFC)
							RT3->CNPJDEST	:= cCGCDest
							RT3->UFDEST     := cUFDest
							RT3->BASEICM    += (cAliasDTC)->DTC_BASICM
							RT3->VALORICM   += (cAliasDTC)->DTC_VALICM
							RT3->BASESUB    += (cAliasDTC)->DTC_BASESU
							RT3->ICMSUBST   += (cAliasDTC)->DTC_ICMRET
							RT3->VALORNF    += (cAliasDTC)->DTC_VALOR
							RT3->NROCON     := Val(DT6->DT6_DOC)
							RT3->CNPJEM     := SM0->M0_CGC
							RT3->SDOC			:= SerieNfId(cAliasDTC,2,"DTC_SERNFC")
							
							MsUnlock()
							(cAliasDTC)->(dbSkip())
							
						Enddo
						FsQuery (aDtc,2,)
						
					Endif
					
					(cAliasDUD)->(dbSkip())
				Enddo
				
				FsQuery (aDud,2,)
				
				DbSelectArea("RT4")
				RecLock("RT4",.T.)
				
				RT4->TIPO    := "RC"
				RT4->CNPJT   := SM0->M0_CGC
				RT4->NROMANI := Val((cAliasDTX)->DTX_MANIFE)
				
				MsUnlock()
				
			EndIf
		EndIf
	EndIf
	(cAliasDTX)->(dbSkip())
Enddo
FsQuery (aDtx,2,)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Cleber S. A. Santos    ³ Data ³ 28.09.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()

Local aStru1		:= {}
Local aStru2		:= {}
Local aStru3		:= {}
Local aStru4    	:= {}
Local aStru5    	:= {}
Local aTrbs		:= {}
Local cArq		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo MC - Informações dos Manifestos     											                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
aStru1	:= {}
cArq	:= ""
AADD(aStru1,{"TIPO"         	,"C",002,0})	//Tipo do Registro
AADD(aStru1,{"CNPJT"    		,"C",014,0})	//CNPJ Transportadora
AADD(aStru1,{"NROMANI"    		,"N",016,0})	//Numero Manifesto
AADD(aStru1,{"TPOMANI"    	    ,"C",001,0})	//Tipo Manifesto
AADD(aStru1,{"EMAIL"    		,"C",100,0})	//Email
cArq := CriaTrab(aStru1)
dbUseArea(.T.,__LocalDriver,cArq,"RT1")
IndRegua("RT1",cArq,"Str(NROMANI,16)")
AADD(aTrbs,{cArq,"RT1"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo CC - Informações Conhecimento                 								                      ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aStru2	:= {}
cArq	:= ""
AADD(aStru2,{"TIPO"     	,"C",002,0})	//Tipo do Registro
AADD(aStru2,{"NROMANI"   	,"N",016,0})	//Numero Manifesto
AADD(aStru2,{"NROCON"  		,"N",016,0})	//Numero Conhecimento
AADD(aStru2,{"CNPJEM"    	,"C",014,0})	//CNPJ Emissor
AADD(aStru2,{"UFEMI"    	,"C",002,0})	//UF Emissor
AADD(aStru2,{"CSERIE"    	,"C",003,0})	//Serie Conhecimento
AADD(aStru2,{"BASECON"  	,"N",011,2})	//Valor Conhecimento
AADD(aStru2,{"VALICMS"  	,"N",011,2})	//VALOR ICMS
AADD(aStru2,{"VALFRETE" 	,"N",011,2})	//VALOR FRETE
AADD(aStru2,{"DISTAN"   	,"N",005,0})	//Distancia Percorrida (Percurso)
cArq := CriaTrab(aStru2)
DbUseArea(.T.,__LocalDriver,cArq,"RT2")
IndRegua("RT2",cArq,"Str(NROMANI,16)+Str(NROCON,16) + CSERIE ")
AADD(aTrbs,{cArq,"RT2"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo NF - Informacoes Notas Fiscais													                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru3	:= {}
cArq	:= ""	
AADD(aStru3,{"TIPO"      	,"C",002,0}) 	//Tipo do Registro
AADD(aStru3,{"NROMANI" 		,"N",016,0})	//Numero Manifesto   
AADD(aStru3,{"NF"   		,"N",016,0})	//NOTA FISCAL
AADD(aStru3,{"SERIE"   		,"C",TamSx3("DTC_SERNFC")[1],0})	//SERIE NF	
AADD(aStru3,{"UFREM"    	,"C",002,0})	//UF REMETENTE 
AADD(aStru3,{"CNPJREM"   	,"C",014,0})	//CNPJ REMETENTE
AADD(aStru3,{"DTEMI"   		,"C",008,0})	//DATA EMISSAO NOTA FISCAL
AADD(aStru3,{"CNPJDEST"   	,"C",014,0})	//CNPJ DESTINATARIO
AADD(aStru3,{"UFDEST"    	,"C",002,0})	//UF DESTINATARIO 
AADD(aStru3,{"BASEICM"  	,"N",011,2})	//VALOR BASE ICMS        
AADD(aStru3,{"VALORICM" 	,"N",011,2})	//VALOR ICMS                                                                          
AADD(aStru3,{"BASESUB"  	,"N",011,2})	//VALOR BASE SUBSTITUICAO TRIBUTARIA            
AADD(aStru3,{"ICMSUBST" 	,"N",011,2})	//VALOR ICMS RETIDO SUBST. TRIB.                                                                                                                                                            
AADD(aStru3,{"VALORNF"  	,"N",011,2})	//VALOR NOTA FISCAL                                                                         
AADD(aStru3,{"NROCON"    	,"N",016,0})	//NUMERO CONHECIMENTO
AADD(aStru3,{"CNPJEM"    	,"C",014,0})	//CNPJ Emissor
AADD(aStru3,{"SDOC"   		,"C",003,0})	//SERIE NF	
cArq := CriaTrab(aStru3)
dbUseArea(.T.,__LocalDriver,cArq,"RT3")
IndRegua("RT3",cArq,"Str(NROMANI,16)+Str(NROCON,16)+Str(NF,16)+ SERIE")
AADD(aTrbs,{cArq,"RT3"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo RC - Informacoes Rodape Manifesto													              |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru4	:= {}
cArq	:= ""	
AADD(aStru4,{"TIPO"      	,"C",002,0}) 	//Tipo do Registro
AADD(aStru4,{"CNPJT"   		,"C",014,0})	//CNPJ Transportadora
AADD(aStru4,{"NROMANI" 		,"N",016,0})	//Numero Manifesto
cArq := CriaTrab(aStru4)
dbUseArea(.T.,__LocalDriver,cArq,"RT4")
IndRegua("RT4",cArq,"Str(NROMANI,16)")
AADD(aTrbs,{cArq,"RT4"})
    
//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arquivo TXT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÙ 
aStru5	:=	{}
AADD(aStru5,{"NROMANI","N",016,0})
AADD(aStru5,{"CAMPO","C",146,0})
cArq :=	CriaTrab(aStru5)
dbUseArea(.T.,__LocalDriver,cArq,"Arq")
IndRegua("Arq",cArq,"Str(NROMANI,16)") 
AADD(aTrbs,{cArq,"Arq"})

Return (aTrbs)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EDIPIDel    ºAutor  ³Cleber S. A. Santos º Data ³ 28.09.2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³EDIPIDel                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/       
Function EDIPIDel(aDelArqs)

Local aAreaDel 	:= GetArea()
Local nI 			:= 0    
	
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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunction³GeraEDIPI     ºAutor  ³Cleber S. A. Santos º Data ³  28.09.07   º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³Gera Arquivo texto                                              º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso     ³                                                                º±±
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GeraEDIPI()
	
dbSelectArea("RT1")
RT1->(dbGoTop())
If RT1->(dbSeek(Str(RT1->NROMANI,16)))
	If !Arq->(dbSeek(Str(RT1->NROMANI,16)))
		While RT1->(!EoF())
			RecLocK("Arq",.T.)
			ARQ->NROMANI :=RT1->NROMANI
			ARQ->CAMPO	 :=RT1->TIPO+RT1->CNPJT+StrZero(RT1->NROMANI,16)+RT1->TPOMANI+RT1->EMAIL
			MsUnlock()
			
			If RT2->(dbseek(Str(RT1->NROMANI,16)))
				While RT2->(!EoF()) .and.RT1->NROMANI == RT2->NROMANI
					RecLocK("Arq",.T.)
					ARQ->NROMANI := RT1->NROMANI
					ARQ->CAMPO	 :=RT2->TIPO+STRZERO(RT2->NROCON,16)+RT2->CNPJEM+RT2->UFEMI+RT2->CSERIE+NUM2CHR(RT2->BASECON,11,2)+ NUM2CHR(RT2->VALICMS,11,2)+NUM2CHR(RT2->VALFRETE,11,2)+ALLTRIM(STRZERO(RT2->DISTAN,5))
					RT2->(dbSkip())
					MsUnlock()
				EndDo
			EndIf
			
			If RT3->(dbseek(Str(RT1->NROMANI,16)))
				While RT3->(!EoF()) .and.RT1->NROMANI == RT3->NROMANI
					RecLocK("Arq",.T.)
					ARQ->NROMANI :=RT1->NROMANI
					ARQ->CAMPO	 :=RT3->TIPO+ STRZERO(RT3->NF,16)+RT3->SDOC+RT3->UFREM+RT3->CNPJREM+;
						RT3->DTEMI+RT3->CNPJDEST+RT3->UFDEST+NUM2CHR(RT3->BASEICM,11,2)+NUM2CHR(RT3->VALORICM,11,2)+;
						NUM2CHR(RT3->BASESUB,11,2)+NUM2CHR(RT3->ICMSUBST,11,2)+NUM2CHR(RT3->VALORNF,11,2)+STRZERO(RT3->NROCON,16)+RT3->CNPJEM
					RT3->(dbSkip())
					MsUnlock()
				EndDo
			EndIf
			
			If RT4->(dbseek(Str(RT1->NROMANI,16)))
				RecLocK("Arq",.T.)
				ARQ->NROMANI :=RT1->NROMANI
				Arq->CAMPO	 := RT4->TIPO + RT4->CNPJT + StrZero(RT4->NROMANI,16)
				RT4->(dbSkip())
				MsUnlock()
			EndIf
			
			RT1->(dbSkip())
		EndDo
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³VerNFPI  ³ Autor ³Cleber Stenio A. Stos  ³ Data ³09/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VerIfica se existem Notas Fiscais Validas para o Envio     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³Retorno   ³ Total de registros                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VerNFPI(cCond1,cCond2,cCond3,cCond4,cTipMan)

Local cAliasDUD 	:= GetNextAlias()
Local cAliasDTC 	:= GetNextAlias()
Local aDud		:= {"DUD","",cAliasDUD}
Local aDtc		:= {"DTC","",cAliasDTC}
Local nRes      := 0
Local nContNF   	:= 0
Local cNumNF   	:= ""

DbSelectArea ("DUD")
DUD->(dbSetOrder(5))
FsQuery(aDud,1;
	,"DUD_FILIAL='"+ xFilial("DUD") +"' AND DUD_FILORI='"+ cCond1+"' AND DUD_VIAGEM='"+ cCond2+"' AND DUD_FILMAN='"+ cCond3+;
	"' AND DUD_MANIfE='"+ cCond4+"'","DUD_FILIAL=='"+xFilial("DUD")+"' .AND. DUD_FILORI=='"+ cCond1+"' .AND. DUD_VIAGEM=='"+ cCond2+;
	"' .AND. DUD_FILMAN=='"+ cCond3+"' .AND. DUD_MANIfE=='"+ cCond4+"'",DUD->(IndexKey()))
(cAliasDUD)->(dbGotop())

Do While !(cAliasDUD)->(EoF ())
	
	DbSelectArea ("DT6")
	DT6->(DbSetOrder (1))
	DT6->(dbSeek(xFilial("DT6")+(cAliasDUD)->DUD_FILDOC+(cAliasDUD)->DUD_DOC+(cAliasDUD)->DUD_SERIE))
	
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES))
	cUFDest  := SA1->A1_EST
	
	If (at(Substr(cTipMan,1,1),"EIN")>0 .AND. cUFDest=="PI") .Or. (at(Substr(cTipMan,1,1),"SX")>0 .AND. cUFDest<>"PI")
		
		DbSelectArea ("DTC")
		DTC->(dbSetOrder(7))
		FsQuery(aDtc,1,"DTC_FILIAL='"+ xFilial("DTC") +"' AND DTC_FILDOC='"+ DT6->DT6_FILDOC +"' AND DTC_DOC='"+ DT6->DT6_DOC +;
			"' AND DTC_SERIE='"+ DT6->DT6_SERIE+"'","DTC_FILIAL=='"+xFilial("DTC")+"' .AND. DTC_FILDOC=='"+ DT6->DT6_FILDOC +;
			"' .AND. DTC_DOC=='"+ DT6->DT6_DOC+"' .AND. DTC_SERIE=='"+ DT6->DT6_SERIE+"'",DTC->(IndexKey()))
		(cAliasDTC)->(dbGotop())
		
		Do While !(cAliasDTC)->(EoF ())
			nContNF++
			cNumNF :=  ((cAliasDTC)->DTC_NUMNFC + (cAliasDTC)->DTC_SERNFC)
			(cAliasDTC)->(dbSkip())
			//Pular o registro repetido
			Do while cNumNF  ==  ((cAliasDTC)->DTC_NUMNFC + (cAliasDTC)->DTC_SERNFC)
				(cAliasDTC)->(dbSkip())
			EndDo
		Enddo
		FsQuery (aDtc,2,)
	EndIf
	(cAliasDUD)->(dbSkip())
Enddo

FsQuery (aDud,2,)
nRes:= nContNF
dbCloseArea()

Return(nRes)

