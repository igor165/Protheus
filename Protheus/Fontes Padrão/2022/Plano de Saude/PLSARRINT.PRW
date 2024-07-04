#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArrEsp	  บAutor  ณMicrosiga           บ Data ณ  02/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por inserir os dados das especialidades บฑฑ
ฑฑบ          ณ em um Array para que entใo sejam lidos e gerado arquivo XMLบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ   
ฑฑบParโmetrosณ lCarIni - Indica se ้ carga inicial ou nใo								  บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ArrEsp(lCarIni)  
/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOrdem em que os itens devem estar no array: 			 ณ
//ณ1 - BAQ->BAQ_CODESPE											 	 			 ณ
//ณ2 - BAQ->BAQ_DESCRI												 			 ณ
//ณ3 - BAQ->BAQ_CODINT    										 			 ณ
//ณ4 - a็ใo("3"=inclusใo/"4"=altera็ใo/"5"-exclusใo) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ<ู
ENDDOC*/
Local aEsp := {}
Local bCondBAQ := {}
Local nCont:= 0

If !lCarIni
	SET DELETED OFF
	bCondBAQ := {|| BAQ->BAQ_FILIAL == xFilial("BAQ") .And. AllTrim(BAQ->BAQ_AOINT) == "N"}
Else
    bCondBAQ := {|| BAQ->BAQ_FILIAL == xFilial("BAQ") .And. AllTrim(BAQ->BAQ_AOINT) != "S"}	
EndIf         

If !BAQ->(Used())
	DBSelectArea("BAQ")
EndIf	
BAQ->(DbSetOrder(1))
BAQ->(DbSetFilter(bCondBAQ,""))
BAQ->(dbGoTop())

While !BAQ->(EOF())
	If !BAQ->(DELETED()) .Or. (BAQ->(DELETED()) .And. AllTrim(BAQ->BAQ_AOINT) == "N")
		AADD(aEsp,{BAQ->BAQ_CODESP,AllTrim(BAQ->BAQ_DESCRI),BAQ->BAQ_CODINT,IIF(!Empty(BAQ->BAQ_ACAO),BAQ->BAQ_ACAO,"3")})//o ultimo elemento ้ a a็ใo(3=inclusใo/4=altera็ใo/5-exclusใo) 
	EndIf	
	BAQ->(DbSkip())
EndDo                    
BAQ->(DbCloseArea()) 
SET DELETED ON							                  	
Return aEsp 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArrRDA	  บAutor  ณMicrosiga           บ Data ณ  02/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por inserir os dados da RDA em um Array บฑฑ
ฑฑบ          ณ para que entใo sejam lidos e gerado arquivo XML						บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบParโmetrosณ lCarIni - Indica se ้ carga inicial ou nใo								  บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ArrRDA(lCarIni)
	/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOrdem em que os itens devem estar no array:     							 ณ
//ณ1  - BAU->BAU_DTINCL                                          ณ
//ณ2  - BAU->BAU_CODIGO                                          ณ
//ณ3  - BAU->BAU_NOME                                            ณ
//ณ4  - cShortName --> BAU->BAU_NFANTA/BAU->BAU_NREDUZ					 ณ
//ณ5  - 1 --> colocado fixo enquanto nใo ้ decidido              ณ
//ณ6  - BAU->BAU_INSS                                            ณ
//ณ7  - aCrRDA --> BAU->BAU_SIGLCR,BAU->BAU_CONREG,BAU->BAU_ESTCRณ
//ณ								BAU->BAU_SIGCR2,BAU->BAU_CONRE2,BAU->BAU_ESTCR2ณ
//ณ8  - SA2->A2_NUMCON                                           ณ
//ณ9  - SA6->A6_DVCTA                                            ณ
//ณ10 - SA2->A2_AGENCIA                                          ณ
//ณ11 - SA2->A2_BANCO                                            ณ
//ณ12 - cSexo -->BAU->BAU_SEXO                                   ณ
//ณ13 - BAU->BAU_NASFUN                                          ณ
//ณ14 - BAU->BAU_CPFCGC                                          ณ
//ณ15 - "H" colocado fixo enquanto nใo ้ decidido 							 ณ
//ณ16 - cEstCivil --> BAU->BAU_ESTCIV                            ณ
//ณ17 - BAU->BAU_ISS                                             ณ
//ณ18 - cStatus --> BAU->BAU_CODBLO conforme bloqueio            ณ
//ณ19 - BAU->BAU_DIRTEC                                          ณ
//ณ20 - BAU->BAU_DIRREG                                          ณ
//ณ21 - BAU->BAU_SIGDIR                                          ณ
//ณ22 - BAU->BAU_UFCDIR                                          ณ
//ณ23 - aOpRDA () --> BAW->BAW_CODINT Lista de operadoras	  		 ณ
//ณ24 - a็ใo("3"=inclusใo/"4"=altera็ใo/"5"-exclusใo) 					 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  */
Local aOpRDA 		:= {}
  Local aRDA   	  := {}
Local aCrRDA 		:= {}
Local bCondicao := {} 
Local bCondBAU  := {}
Local cShortName:= ""
Local cEstCivil := ""
Local cStatus		:= ""
Local cStatusOpe	:= ""
Local cSexo 		:= "" 

If !lCarIni
	SET DELETED OFF
	bCondBAU := {|| BAU->BAU_FILIAL == xFilial("BAU") .And. AllTrim(BAU->BAU_AOINT) == "N"} 
Else
	bCondBAU := {|| BAU->BAU_FILIAL == xFilial("BAU") .And. AllTrim(BAU->BAU_AOINT) != "S"}	
EndIf

  
If !BAU->(Used())
	DBSelectArea("BAU")
EndIf	
BAU->(DbSetOrder(1))
BAU->(DbSetFilter(bCondBAU,""))
BAU->(DbGoTop())

If !SA2->(Used())						
	DbSelectArea("SA2")
EndIf	
SA2->(DbSetOrder(1))

If !SA6->(Used())						
	DbSelectArea("SA6")
ENdIf	
SA6->(DbSetOrder(1))
						        
If !BAW->(Used())						
	DbSelectArea("BAW")
EndIf	
BAW->(DbSetOrder(1))

Sleep(100)
While !BAU->(EOF()) 
	If !BAU->(DELETED()) .Or. (BAU->(DELETED()) .And. AllTrim(BAU->BAU_AOINT) == "N")
		SA2->(MsSeek(xFilial("BAU") + BAU->BAU_CODSA2 + BAU->BAU_LOJSA2)) 
		SA6->(MsSeek(xFilial("SA2") + SA2->A2_BANCO + SA2->A2_AGENCIA + SA2->A2_NUMCON))
								
		bCondicao := {|| BAW->BAW_FILIAL == xFilial("BAW") .And. ;
		 	  							BAW->BAW_CODIGO == BAU->BAU_CODIGO .And. BAW->BAW_AOINT != "S"}
		BAW->(DbSetFilter(bCondicao,""))										
		BAW->(DbGoTop())             			
		/*BEGINDOC
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณS๓ serแ verificado se a RDA possui operadoras na carga inicial, pois quando nใo tiver, no programa PLSA360 ้ feita essa verifica็ใoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ENDDOC*/	
		If BAW->(EOF())
			BAU->(DbSkip())
			Loop
		Else                 
			aOpRDA := {}
			/*BEGINDOC
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ`ฟ
			//ณStatus conforme c๓digo de bloqueioณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ`ู
			ENDDOC*/
			If AllTrim(BAU->BAU_CODBLO) != ""
				If BAU->BAU_CODBLO == GetNewPar("MV_PLRDAD",.F.)
					cStatus := "D" 	
				Else
					cStatus := "I"						
				EndIf
			Else 
				cStatus := "A"	
			EndIf  
			
			While !BAW->(EOF()) .And. BAW->BAW_FILIAL == xFilial("BAW")
			    If cStatus = "D" .Or. BAW->BAW_ACAO = "5" .Or. BAW->(DELETED()) .Or. (BAW->BAW_VIGFIN <= Date() .And. !Empty(BAW->BAW_VIGFIN))
			    	cStatusOpe := "D"//Descredenciada
			    ElseIf cStatus = "I"
			    	cStatusOpe := "I"//Inativa
			    Else
			    	cStatusOpe := "A"//Credenciada
			    EndIf
			    											 
				AADD(aOpRDA,{BAW->BAW_CODINT,BAW->BAW_VIGINI,BAW->BAW_VIGFIN,cStatusOpe})									
				BAW->(DbSkip())
			EndDo
			/*BEGINDOC
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤค[ฟ
			//ณpessoa jurํdica -> nome fantasia ณ
			//ณpessoa fํsica   -> nome reduzido ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤค[ู
			ENDDOC*/
			If BAU->BAU_TIPPE == "J" .And. AllTrim(BAU->BAU_NFANTA) != ""
				cShortName := IIF(!Empty(AllTrim(BAU->BAU_NFANTA)),AllTrim(BAU->BAU_NFANTA),AllTrim(BAU->BAU_NREDUZ))
			Else
				cShortName := AllTrim(BAU->BAU_NREDUZ)
			EndIf	
									
			/*BEGINDOC
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Est. Civil GRC: ณ
			//ณW - Indeterminadoณ
			//ณD - Vi๚vo        ณ
			//ณA - Separado     ณ
			//ณS - Solteiro     ณ
			//ณM - Casado       ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			ENDDOC*/
			If BAU->BAU_ESTCIV != ""					
				If BAU->BAU_ESTCIV == "C"
					cEstCivil := "M"
				ElseIf BAU->BAU_ESTCIV == "D"
					cEstCivil := "A"	
				ElseIf BAU->BAU_ESTCIV == "S"					
					cEstCivil := "S"	                  
				ElseIf BAU->BAU_ESTCIV == "V"										
					cEstCivil := "D"
				Else
					cEstCivil := "W"										
				EndIf
			Else	                                  
				cEstCivil := "W"
			EndIf
									
									
			If AllTrim(BAU->BAU_SEXO) == "0"     
				cSexo := "M"
			ElseIf AllTrim(BAU->BAU_SEXO) == "1" 
				cSexo := "F"
			Else
				cSexo := ""
			EndIf	
									
			aCrRDA :={}
			AADD(aCrRDA,{Substr(AllTrim(BAU->BAU_SIGLCR),1,7),Substr(AllTrim(BAU->BAU_CONREG),1,7),Substr(AllTrim(BAU->BAU_ESTCR),1,7)})								
			If AllTrim(BAU->BAU_SIGCR2) != ""	
				AADD(aCrRDA,{Substr(AllTrim(BAU->BAU_SIGCR2),1,7),Substr(AllTrim(BAU->BAU_CONRE2),1,7),Substr(AllTrim(BAU->BAU_ESTCR2),1,7)})										
			EndIf
								
			AADD(aRDA,{BAU->BAU_DTINCL,;
			   		   AllTrim(BAU->BAU_CODIGO),;
			   		   AllTrim(BAU->BAU_NOME),;
			   		   cShortName,;
			   		   BAU->BAU_COPCRE,;
			   		   AllTrim(BAU->BAU_INSS),;
					   aCrRDA,;
					   AllTrim(SA2->A2_NUMCON),;
					   AllTrim(SA6->A6_DVCTA),;
					   AllTrim(SA2->A2_AGENCIA),;
					   AllTrim(SA2->A2_BANCO),;
					   cSexo,;
					   BAU->BAU_NASFUN,;
					   AllTrim(BAU->BAU_CPFCGC),;
					   BAU->BAU_TIPPRE,;
					   cEstCivil,;
					   AllTrim(BAU->BAU_ISS),;
					   cStatus,;
					   AllTrim(BAU->BAU_DIRTEC),;
					   AllTrim(BAU->BAU_DIRREG),;
					   AllTrim(BAU->BAU_SIGDIR),;
					   AllTrim(BAU->BAU_UFCDIR),;
					   aOpRDA,;
					   IIF(!Empty(BAU->BAU_ACAO),BAU->BAU_ACAO,"3")})//o ultimo elemento ้ a a็ใo(3=inclusใo/4=altera็ใo/5-exclusใo)
		EndIf
	EndIf	
	BAU->(DbSkip()) 									
EndDo
BAU->(DbCloseArea()) 
BAW->(DbCloseArea())
SET DELETED ON
Return aRDA


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArrLoc	  บAutor  ณMicrosiga           บ Data ณ  02/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por inserir os dados de local de atend. บฑฑ
ฑฑบ          ณ em um Array para que entใo sejam lidos e gerado arquivo XMLบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบParโmetrosณ lCarIni - Indica se ้ carga inicial ou nใo								  บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/             
Function ArrLoc(lCarIni)
/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOrdem em que os itens devem estar no array: 				ณ
//ณ1  - BAU->BAU_DTINCL												 				ณ
//ณ2  - BAU->BAU_CODIGO												 				ณ
//ณ3  - BB8->BB8_TEL    											 				ณ
//ณ4  - BB8->BB8_DDD    											 				ณ		
//ณ5  - BB8->BB8_FAX    											 				ณ
//ณ6  - BB8->BB8_EMAIL  											 				ณ
//ณ7  - BB8->BB8_CORRES 											 				ณ
//ณ8  - BB8->BB8_NR_END 											 				ณ
//ณ9  - BB8->BB8_COMEND 											 				ณ
//ณ10 - BB8->BB8_CEP    											 				ณ
//ณ11 - BB8->BB8_BAIRRO 											 				ณ
//ณ12 - BB8->BB8_END    											 				ณ
//ณ13 - BB8->BB8_CODINT 											 				ณ
//ณ14 - BB8->BB8_LOCAL  											 				ณ
//ณ15 - BB8->BB8_CODLOC 											 				ณ
//ณ16 - BB8->BB8_CNES   											 				ณ
//ณ17 - BB8->BB8_CODMUN 											 				ณ
 	//ณ18 - a็ใo("3"=inclusใo/"4"=altera็ใo/"5"-exclusใo) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ<ู
ENDDOC*/
Local aLoc 		 := {}                               
Local bCondBB8 := {}

If !lCarIni
	SET DELETED OFF
	bCondBB8 := {|| BB8->BB8_FILIAL == xFilial("BB8") .And. AllTrim(BB8->BB8_AOINT) == "N"}
Else
	bCondBB8 := {|| BB8->BB8_FILIAL == xFilial("BB8") .And. AllTrim(BB8->BB8_AOINT) != "S"}	
EndIf


If !BB8->(Used())
	DbSelectArea("BB8")  
EndIf	
BB8->(DbSetOrder(1))
BB8->(DbSetFilter(bCondBB8,""))
BB8->(DbGoTop())
If !BAU->(Used())
	DbSelectArea("BAU")
EndIf	
BAU->(DbSetOrder(1))//BAU_FILIAL+BAU_CODIGO                
						
While !BB8->(EOF()) 
	If !BB8->(DELETED()) .Or. (BB8->(DELETED()) .And. AllTrim(BB8->BB8_AOINT) == "N")
		BAU->(MsSeek(xFilial("BB8") + BB8->BB8_CODIGO)) 
		AADD(aLoc,{BAU->BAU_DTINCL,;
							 AllTrim(BB8->BB8_CODIGO),;
							 AllTrim(BB8->BB8_TEL),;
							 AllTrim(BB8->BB8_DDD),;
							 AllTrim(BB8->BB8_FAX),;
							 AllTrim(BB8->BB8_EMAIL),;
							 IIF(AllTrim(BB8->BB8_CORRES) == "1", "S", "N"),;
							 AllTrim(BB8->BB8_NR_END),;
							 AllTrim(BB8->BB8_COMEND),;
							 AllTrim(BB8->BB8_CEP),;
							 AllTrim(BB8->BB8_BAIRRO),;
							 AllTrim(BB8->BB8_END),;
							 AllTrim(BB8->BB8_CODINT),;
							 AllTrim(BB8->BB8_LOCAL),;
							 AllTrim(BB8->BB8_CODLOC),;
							 AllTrim(BB8->BB8_CNES),;
							 AllTrim(BB8->BB8_CODMUN),;
							 IIF(!Empty(BB8->BB8_ACAO),BB8->BB8_ACAO,"3")})//o ultimo elemento ้ a a็ใo(3=inclusใo/4=altera็ใo/5-exclusใo)
	EndIf
	BB8->(DbSkip())
EndDo
BB8->(DBCloseArea()) 
BAU->(DBCloseArea()) 
SET DELETED ON
Return aLoc	  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArrEspLoc บAutor  ณMicrosiga           บ Data ณ  02/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por inserir os dados de especialidades  บฑฑ
ฑฑบ          ณ de um local de atend. em um Array para que entใo sejam 		บฑฑ
ฑฑบ					 ณ lidos e gerado arquivo XML																	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบParโmetrosณ lCarIni - Indica se ้ carga inicial ou nใo								  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ArrEspLoc(lCarIni)
/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ 
//ณOrdem em que os itens devem estar no array:			 ณ
//ณ1 - BAU->BAU_DTINCL															 ณ
//ณ2 - BAU->BAU_CODIGO								 							 ณ
//ณ3 - BAU->BAU_SIGLCR --> Possui CRM ?							 ณ	
//ณ4 - BAX->BAX_CODESP								 							 ณ
//ณ5 - BAX->BAX_CODLOC								 							 ณ
//ณ6 - BAX->BAX_CODINT								 							 ณ
//ณ7 - a็ใo("3"=inclusใo/"4"=altera็ใo/"5"-exclusใo) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/                                        
Local aEspLoc  := {}
Local bCondBAX := {}

If !lCarIni
	SET DELETED OFF
	bCondBAX := {|| BAX->BAX_FILIAL == xFilial("BAX") .And. AllTrim(BAX->BAX_AOINT) == "N"}
Else
	bCondBAX := {|| BAX->BAX_FILIAL == xFilial("BAX") .And. AllTrim(BAX->BAX_AOINT) != "S"}	
EndIf


If !BAX->(Used())
	DbSelectArea("BAX")  
EndIf	
BAX->(DbSetOrder(1))
BAX->(DbSetFilter(bCondBAX,""))
BAX->(DbGoTop())

If !BAU->(Used())	
	DbSelectArea("BAU")
EndIf	
BAU->(DbSetOrder(1))//BAU_FILIAL+BAU_CODIGO  

While !BAX->(EOF())
	If !BAX->(DELETED()) .Or. (BAX->(DELETED()) .And. AllTrim(BAX->BAX_AOINT) == "N")
		BAU->(MsSeek(xFilial("BAX") + BAX->BAX_CODIGO))
		AADD(aEspLoc,{BAU->BAU_DTINCL,;
									AllTrim(BAX->BAX_CODIGO),;
									IIF(AllTrim(BAU->BAU_SIGLCR) == "CRM" .Or. AllTrim(BAU->BAU_SIGCR2) == "CRM","S","N"),;
									BAX->BAX_CODESP,;
									BAX->BAX_CODLOC,;
									BAX->BAX_CODINT,;
									BAX->BAX_DATBLO,;
									IIF(!Empty(BAX->BAX_ACAO),BAX->BAX_ACAO,"3")})//o ultimo elemento ้ a a็ใo(3=inclusใo/4=altera็ใo/5-exclusใo)			
	EndIf	                                                                                                                       
	BAX->(DbSkip())
EndDo	
BAX->(DbCloseArea()) 
SET DELETED ON
Return aEspLoc 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArrProcs บAutor  ณYves           			 บ Data ณ  03/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por inserir os dados de procedimentos   บฑฑ
ฑฑบ          ณ em um Array para que entใo sejam lidos e gerado arquivo XMLบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบParโmetrosณ lCarIni - Indica se ้ carga inicial ou nใo								  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ArrProcs(lCarIni)
/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOrdem em que os itens devem estar no array: 			 ณ
//ณ1 - BR4->BR4_CODPAD											 	 			 ณ
//ณ2 - BR4->BR4_DESCRI												 			 ณ
//ณ3 - Array = BR8->BR8_CODPAD, BR8->BR8_DESCRI			 ณ
//ณ4 - a็ใo("3"=inclusใo/"4"=altera็ใo/"5"-exclusใo) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ<ู
ENDDOC*/ 
Local aProcs 	 := {}
Local aAux		 := {}
Local bCondBR8 := {}
Local bCondBR4 := {|| BR4->BR4_FILIAL == xFilial("BR4") .And. BR4->BR4_SEGMEN == "01"}//segmento plano de sa๚de
Local cCondBR8 := ""

If !lCarIni
	SET DELETED OFF
	bCondBR8 := {|| BR8->BR8_FILIAL == xFilial("BR8") .And. BR8->BR8_AOINT == "N"}
Else
	bCondBR8 := {|| BR8->BR8_FILIAL == xFilial("BR8") .And. BR8->BR8_CODPAD == BR4->BR4_CODPAD .And. AllTrim(BR8->BR8_AOINT) != "S"}	
EndIf

If !BR4->(Used())	
	DbSelectArea("BR4")
EndIf              
BR4->(DbSetOrder(1))
BR4->(DbSetFilter(bCondBR4,""))
BR4->(DbGoTop())

If !BR8->(Used())	
	DbSelectArea("BR8")
EndIf  
BR8->(DbSetOrder(3))           	
  
  /*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNa carga inicial o array ้ montado conforme as tabelas padrใo de procedimentos       	  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/ 
If lCarIni
	While !BR4->(EOF())		
		BR8->(DbSetFilter(bCondBR8,cCondBR8))		
		BR8->(DbGoTop())		                                              
		aAux := {} 
		//aProcs := {}
		While !BR8->(EOF())  
			If !Empty(BR8->BR8_CODPSA) .And. !Empty(BR4->BR4_CODPAD)     
				AADD(aAux,{BR8->BR8_CODPSA,AllTrim(BR8->BR8_DESCRI),IIF(!Empty(BR8->BR8_ACAO),BR8->BR8_ACAO,"3"), BR8->BR8_CODPAD})					
			EndIf
			BR8->(DbSkip())		                                              
		EndDo
		If Len(aAux) > 0
  		  AADD(aProcs,{BR4->BR4_CODPAD,;
				     AllTrim(BR4->BR4_DESCRI),;
					   aAux})		  
		EndIf
		BR4->(DbSkip())
	EndDo 
Else		 
	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuando nใo for carga inicial, os dados sใo buscados diretamente na tabela BR8ณ
	//ณe nใo separados por tabela padrใo                                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ENDDOC*/
	BR8->(DbSetFilter(bCondBR8,""))
	BR8->(dbGoTop())	
	While !BR8->(EOF())  
		BR4->(MsSeek(xFilial("BR4") + BR8->BR8_CODPAD + "01")) //01 = Segmento PLS
		AADD(aProcs,{BR4->BR4_CODPAD,;
				       	 AllTrim(BR4->BR4_DESCRI),;
					   		 {{BR8->BR8_CODPSA,AllTrim(BR8->BR8_DESCRI),IIF(!Empty(BR8->BR8_ACAO),BR8->BR8_ACAO,"3"),BR8->BR8_CODPAD}}})										 
		BR8->(DBSkip())											 
	EndDo	
EndIf	
BR4->(DbCloseArea())
BR8->(DbCloseArea()) 
SET DELETED ON
Return aProcs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArrProcNAu บAutor  ณYves         			 บ Data ณ  03/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina responsแvel por inserir os dados de procedimentos   บฑฑ
ฑฑบ          ณ nใo autorizados da RDA em um Array para que entใo sejam  	บฑฑ
ฑฑบ					 ณ lidos e gerado arquivo XML																	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบParโmetrosณ lCarIni - Indica se ้ carga inicial ou nใo								  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ArrProcNAu(lCarIni) 
/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOrdem em que os itens devem estar no array: 			 ณ
//ณ1 - BBN->BBN_CODIGO											 	 			 ณ
//ณ2 - BBN->BBN_CODINT												 			 ณ
//ณ3 - BBN->BBN_CODLOC								 							 ณ
//ณ4 - BBN->BBN_CODESP															 ณ
//ณ5 - Array = BBN->BBN_CODPAD, BBN->BBN_CODPSA	  	 ณ
//ณ6 - a็ใo("3"=inclusใo/"4"=altera็ใo/"5"-exclusใo) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ<ู
ENDDOC*/                                                

Local aProcNao := {}
Local aProcs	 := {}
Local bCondBBN := {}  
Local bCondBAX := {}
Local nCont		 := 0
Local cNivel 	 := ""

If !lCarIni
	SET DELETED OFF
	bCondBBN := {|| BBN->BBN_FILIAL == xFilial("BBN") .And. BBN->BBN_AOINT == "N"}		
Else
	bCondBBN := {|| BBN->BBN_FILIAL == xFilial("BBN") .And. BBN->BBN_CODIGO == BAX->BAX_CODIGO .And. BBN->BBN_CODINT == BAX->BAX_CODINT .And.;
									BBN->BBN_CODLOC == BAX->BAX_CODLOC .And. BBN->BBN_CODESP == BAX->BAX_CODESP .And.;
									BBN->BBN_AOINT != "S"}	
EndIf                                          

If !BAX->(Used())
	DBSelectArea("BAX")
EndIf
BAX->(DbSetOrder(1))      
BAX->(DbSetFilter({|| BAX->BAX_FILIAL == xFilial("BAX")},""))

If !BBN->(Used())
	DBSelectArea("BBN")
EndIf		
BBN->(DbSetOrder(1))      

/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNa carga inicial o array ้ montado conforme as especialidades do local de atendimento	  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/
If lCarIni	
	While !BAX->(EOF())
		BBN->(DbSetFilter(bCondBBN,""))
		BBN->(dbGoTop())
		If !BBN->(EOF())
			aProcs := {}
			While !BBN->(EOF())
				AADD(aProcs,{BBN->BBN_CODPAD,;
							 BBN->BBN_CODPSA,;
							 BBN->BBN_NIVEL})					 						 
				BBN->(DbSkip())
			EndDo           
			AADD(aProcNao,{BAX->BAX_CODIGO,;
		 				   BAX->BAX_CODINT,;
						   BAX->BAX_CODLOC,;
						   BAX->BAX_CODESP,;
			 			   aProcs,;
						   IIF(!Empty(BBN->BBN_ACAO),BBN->BBN_ACAO,"3")})//o ultimo elemento ้ a a็ใo(3=inclusใo/4=altera็ใo/5-exclusใo)          
		EndIf
		BAX->(DbSkip())
	EndDo	
Else
	BBN->(DbSetFilter(bCondBBN,""))
	BBN->(dbGoTop())	
	While !BBN->(EOF())
		AADD(aProcNao,{BBN->BBN_CODIGO,;
					   BBN->BBN_CODINT,;
					   BBN->BBN_CODLOC,;
					   BBN->BBN_CODESP,;
					   {{BBN->BBN_CODPAD,BBN->BBN_CODPSA,BBN->BBN_NIVEL}},;
					        IIF(!Empty(BBN->BBN_ACAO),BBN->BBN_ACAO,"3")})										 
		BBN->(DBSkip())											 
	EndDo
EndIf	
	
BBN->(DbCloseArea())
BAX->(DbCloseArea()) 
SET DELETED ON							                  	
Return aProcNao