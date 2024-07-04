#INCLUDE "plsmvld.ch"
#include "TOPCONN.CH"
#include "PROTHEUS.CH"
#include "PLSMGER.CH" 
#include "PLSMCCR.CH"	


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ PLSVLDCON  ³ Autor ³ Tulio Cesar          ³ Data ³ 06.02.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Valida a parte contratual...                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cMatric    -> Matricula da Familia                            ³±±
±±³            ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 	
Function PLSVLDCON(cMatric,dData,cCodPad,cCodPro,cLocalExec,dDtDigi,aBD6,cCodRda,dDatImp,lDetalhe,cTpLocExec, lVldBlq,cHorPar) 
LOCAL aRet       	:= {}
LOCAL aRetFun    	:= {.T.}
LOCAL lContinua  	:= .T.                                                      
LOCAL nDiasBloq  	:= GetNewPar("MV_PLDIABL",0)
LOCAL nDiasNotIn 	:= GetNewPar("MV_PLSDRNI",180)
LOCAL dDtLimInt		:= stod('')
LOCAL nFor			:= 0
LOCAL nOrdBAU		:= 0
LOCAL nRecBAU  		:= 0
LOCAL lRdaOpe      	:= .F.
LOCAL lMudou       	:= .F.
LOCAL lBloFam      	:= .F.
LOCAL cAliasPesq	:= "BG1"
LOCAL dDatIniBlo	:= StoD("")
LOCAL dDatFinBlo	:= StoD("")
LOCAL cMotBlo		:= ""
LOCAL lInterc       := .F.  
LOCAL lPulacar      := .F.
LOCAL lInternado	:= .F.

DEFAULT cCodPad 	:= ""
DEFAULT cCodPro		:= ""
DEFAULT dData		:= dDataBase
DEFAULT cLocalExec 	:= "1"  
DEFAULT dDtDigi    	:= dData
DEFAULT aBD6       	:= {}
DEFAULT cCodRda    	:= ""
DEFAULT dDatImp	   	:= dDataBase // se ele pegar a database pode dar margem a erro!!
DEFAULT lDetalhe   	:= .T.
DEFAULT cTpLocExec 	:= '1' 
DEFAULT lVldBlq	 	:=	.T.
DEFAULT cHorPar		:= ""

//posiciona no beneficiario correto, de acordo com a matricula que chega por parametro em cMatric.
BA1->(DbSetOrder(2))
BA1->(MsSeek(xFilial("BA1")+cMatric))



BA3->(DbSetOrder(1))
BA3->(MsSeek(xFilial("BA3")+SubStr(cMatric,1,14))) 

//Verifica se foi bloqueado na data informada
if lVldBlq .and. PLSPOSGLO(PLSINTPAD(),__aCdCri008[1],__aCdCri008[2],cLocalExec,NIL,cTpLocExec) .And. PLSCHKCRI( {'BAU',cCodRda,__aCdCri008[1]} )
	
	If ! Empty(BA3->BA3_DATBLO)
		
		If  dData >= ( BA3->BA3_DATBLO + nDiasBloq )
			
			BC3->(DbSetOrder(1))
			BC3->(Dbseek(xFilial("BC3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)+dtos(BA3->BA3_DATBLO)+"0"))
			
			If BC3->BC3_NIVBLQ == "S"			//Bloqueio por SubContrato
				cAliasPesq := "BQU"
			ElseIf BC3->BC3_NIVBLQ == "F"		//Bloqueio por Familia
				cAliasPesq := "BG1"
			ElseIf BC3->BC3_NIVBLQ == "U"		//Bloqueio por Usuario
				cAliasPesq := "BG3"
			EndIf
			
			If Len(aBD6) == 0
				
				aadd(aRet,{__aCdCri008[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				
				If lDetalhe
					
					aadd(aRet,{"",STR0001 + dtoc( ( BA3->BA3_DATBLO + nDiasBloq ) - 1 ),"","","",cCodPad,cCodPro}) //"Familia bloqueado - guias podem ser digitadas somente ate "
					aadd(aRet,{"",STR0002,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Evento"
					aadd(aRet,{"",STR0003,dtoc(BA3->BA3_DATBLO),"","",cCodPad,cCodPro}) //"Data de Bloqueio"
					aadd(aRet,{"",STR0004,BA3->BA3_MOTBLO+" - "+Posicione(cAliasPesq,1,xFilial(cAliasPesq)+BA3->BA3_MOTBLO,cAliasPesq+"_DESBLO"),"","",cCodPad,cCodPro}) //"Motivo do Bloqueio"
					
					If BC3->(Found())
						aadd(aRet,{"",STR0005,BC3->BC3_OBS,"","",cCodPad,cCodPro}) //"Observacoes do Bloqueio"
					Endif
					
					// Alias e caminho da critica.
					PLSCOMPCRI(aRet,"BA3")
				Endif
				
			Else
				
				For nFor := 1 To Len(aBD6)
					
					cCodPad := aBD6[nFor,3]
					cCodPro := aBD6[nFor,4]
					
					aadd(aRet,{__aCdCri008[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					
					If lDetalhe
						
						aadd(aRet,{"",STR0001 + dtoc( ( BA3->BA3_DATBLO + nDiasBloq ) - 1 ),"","","",cCodPad,cCodPro}) //"Familia bloqueado - guias podem ser digitadas somente ate "
						aadd(aRet,{"",STR0002,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Evento"
						aadd(aRet,{"",STR0003,dtoc(BA3->BA3_DATBLO),"","",cCodPad,cCodPro}) //"Data de Bloqueio"
						aadd(aRet,{"",STR0004,BA3->BA3_MOTBLO+" - "+Posicione(cAliasPesq,1,xFilial(cAliasPesq)+BA3->BA3_MOTBLO,cAliasPesq+"_DESBLO"),"","",cCodPad,cCodPro}) //"Motivo do Bloqueio"
						
						If BC3->(Found())
							aadd(aRet,{"",STR0005,BC3->BC3_OBS,"","",cCodPad,cCodPro}) //"Observacoes do Bloqueio"
						Endif
						
						// Alias e caminho da critica.
						PLSCOMPCRI(aRet,"BA3")
					Endif
					
				Next
				
			Endif
			
			aRetFun 	:= {.F.,aRet,"BA3","1"}
			lContinua 	:= .F.
			lBloFam   	:= .T.
			
		elseIf lVldBlq .and. PlChHiBlo("BC3",dData,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG,@dDatIniBlo,@dDatFinBlo,@cMotBlo)
			
			BC3->(DbSetOrder(1))
			BC3->(msSeek( xFilial("BC3") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) + dtos(dData) + "0" ))
			
			If BC3->BC3_NIVBLQ == "S"			//Bloqueio por SubContrato
				cAliasPesq := "BQU"
			ElseIf BC3->BC3_NIVBLQ == "F"		//Bloqueio por Familia
				cAliasPesq := "BG1"
			ElseIf BC3->BC3_NIVBLQ == "U"		//Bloqueio por Usuario
				cAliasPesq := "BG3"
			EndIf
			
			If Len(aBD6) == 0
				
				aadd(aRet,{__aCdCri008[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				
				If lDetalhe
					
					aadd(aRet,{"",STR0001 + dtoc( dDatIniBlo - 1 ),"","","",cCodPad,cCodPro}) //"Familia bloqueado - guias podem ser digitadas somente ate "
					aadd(aRet,{"",STR0002,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Evento"
					aadd(aRet,{"",IIF(! Empty(dDatFinBlo),STR0029,STR0003),iIf(! Empty(dDatFinBlo),STR0030 + DtoC(dDatIniBlo) + STR0031 + DtoC(dDatFinBlo),DtoC(dDatIniBlo)),"","",cCodPad,cCodPro}) //"Periodo do Bloqueio" - "De ##/##/#### Até ##/##/####" ou "Data de Bloqueio"
					aadd(aRet,{"",STR0004,cMotBlo+" - "+Posicione(cAliasPesq,1,xFilial(cAliasPesq)+cMotBlo,cAliasPesq+"_DESBLO"),"","",cCodPad,cCodPro}) //"Motivo do Bloqueio"
					
					If BC3->(Found())
						aadd(aRet,{"",STR0005,BC3->BC3_OBS,"","",cCodPad,cCodPro}) //"Observacoes do Bloqueio"
					Endif
					
					// Alias e caminho da critica.
					PLSCOMPCRI(aRet,"BA1")
				Endif
				
			Else
				
				For nFor := 1 To Len(aBD6)
					
					cCodPad := aBD6[nFor,3]
					cCodPro := aBD6[nFor,4]
					
					aadd(aRet,{__aCdCri008[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					
					If lDetalhe
						
						aadd(aRet,{"",STR0001 + dtoc( dDatIniBlo - 1 ),"","","",cCodPad,cCodPro}) //"Familia bloqueado - guias podem ser digitadas somente ate "
						aadd(aRet,{"",STR0002,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Evento"
						aadd(aRet,{"",IIF(! Empty(dDatFinBlo),STR0029,STR0003),IIF(! Empty(dDatFinBlo),STR0030 + DtoC(dDatIniBlo) + STR0031 + DtoC(dDatFinBlo),DtoC(dDatIniBlo)),"","",cCodPad,cCodPro}) //"Periodo do Bloqueio" - "De ##/##/#### Até ##/##/####" ou "Data de Bloqueio"
						aadd(aRet,{"",STR0004,cMotBlo+" - "+Posicione(cAliasPesq,1,xFilial(cAliasPesq)+cMotBlo,cAliasPesq+"_DESBLO"),"","",cCodPad,cCodPro}) //"Motivo do Bloqueio"
						If BC3->(Found())
							aadd(aRet,{"",STR0005,BC3->BC3_OBS,"","",cCodPad,cCodPro}) //"Observacoes do Bloqueio"
						Endif
						
						// Alias e caminho da critica.
						PLSCOMPCRI(aRet,"BA1")
					Endif
				Next
				
			Endif
			
			aRetFun 	:= {.F.,aRet,"BA1","1"}
			lContinua 	:= .F.
			lBloFam   	:= .T.
		Endif
		
	Elseif lVldBlq .and. PlChHiBlo("BC3",dData,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG,@dDatIniBlo,@dDatFinBlo,@cMotBlo)
		
		BC3->(DbSetOrder(1))
		BC3->(Dbseek(xFilial("BC3") + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) + dtos(dData) + "0"))
		
		If BC3->BC3_NIVBLQ == "S"			//Bloqueio por SubContrato
			cAliasPesq := "BQU"
		ElseIf BC3->BC3_NIVBLQ == "F"		//Bloqueio por Familia
			cAliasPesq := "BG1"
		ElseIf BC3->BC3_NIVBLQ == "U"		//Bloqueio por Usuario
			cAliasPesq := "BG3"
		EndIf
		
		If ! empty(BA1->BA1_MOTBLO) .and. dData >= (BA1->BA1_DATBLO + nDiasBloq)
			return(aRetFun)
		endIf
		
		If Len(aBD6) == 0
			
			aadd(aRet,{__aCdCri008[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
			
			If lDetalhe
				
				aadd(aRet,{"",STR0001 + dtoc( dDatIniBlo - 1 ),"","","",cCodPad,cCodPro}) //"Familia bloqueado - guias podem ser digitadas somente ate "
				aadd(aRet,{"",STR0002,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Evento"
				aadd(aRet,{"",IIF(! Empty(dDatFinBlo),STR0029,STR0003),IIF(! Empty(dDatFinBlo),STR0030 + DtoC(dDatIniBlo) + STR0031 + DtoC(dDatFinBlo),DtoC(dDatIniBlo)),"","",cCodPad,cCodPro}) //"Periodo do Bloqueio" - "De ##/##/#### Até ##/##/####" ou "Data de Bloqueio"
				aadd(aRet,{"",STR0004,cMotBlo+" - "+Posicione(cAliasPesq,1,xFilial(cAliasPesq)+cMotBlo,cAliasPesq+"_DESBLO"),"","",cCodPad,cCodPro}) //"Motivo do Bloqueio"
				
				If BC3->(Found())
					aadd(aRet,{"",STR0005,BC3->BC3_OBS,"","",cCodPad,cCodPro}) //"Observacoes do Bloqueio"
				Endif
				
				// Alias e caminho da critica.
				PLSCOMPCRI(aRet,"BA1")
			Endif
			
		Else
			
			For nFor := 1 To Len(aBD6)
				
				cCodPad := aBD6[nFor,3]
				cCodPro := aBD6[nFor,4]
				
				aadd(aRet,{__aCdCri008[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				
				If lDetalhe
					
					aadd(aRet,{"",STR0001 + dtoc( dDatIniBlo - 1 ),"","","",cCodPad,cCodPro}) //"Familia bloqueado - guias podem ser digitadas somente ate "
					aadd(aRet,{"",STR0002,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Evento"
					aadd(aRet,{"",IIF(! Empty(dDatFinBlo),STR0029,STR0003),IIF(! Empty(dDatFinBlo),STR0030 + DtoC(dDatIniBlo) + STR0031 + DtoC(dDatFinBlo),DtoC(dDatIniBlo)),"","",cCodPad,cCodPro}) //"Periodo do Bloqueio" - "De ##/##/#### Até ##/##/####" ou "Data de Bloqueio"
					aadd(aRet,{"",STR0004,cMotBlo+" - "+Posicione(cAliasPesq,1,xFilial(cAliasPesq)+cMotBlo,cAliasPesq+"_DESBLO"),"","",cCodPad,cCodPro}) //"Motivo do Bloqueio"
					
					If BC3->(Found())
						aadd(aRet,{"",STR0005,BC3->BC3_OBS,"","",cCodPad,cCodPro}) //"Observacoes do Bloqueio"
					Endif
					
					// Alias e caminho da critica.
					PLSCOMPCRI(aRet,"BA1")
				Endif
				
			Next
			
		Endif
		
		aRetFun 	:= {.F.,aRet,"BA1","1"}
		lContinua 	:= .F.
		lBloFam   	:= .T.
	Endif
	
Endif                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o usuario esta ativo ou nao...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSPOSGLO(PLSINTPAD(),__aCdCri072[1],__aCdCri072[2],cLocalExec,NIL,cTpLocExec) .And. PLSCHKCRI( {'BAU',cCodRda,__aCdCri072[1]} )
   
   If BA1->(FieldPos("BA1_DTVLCE")) > 0 .And. ! Empty(BA1->BA1_DTVLCE) .And. dtos(dData) > dtos(BA1->BA1_DTVLCE)
      If Len(aBD6) == 0      
         aadd(aRet,{__aCdCri072[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
         
         If lDetalhe
	     
	         aadd(aRet,{"",STR0006,dtoc(BA1->BA1_DTVLCE),"","",cCodPad,cCodPro}) //"Data de Validade do Cartao da Empresa"
	         aadd(aRet,{"",STR0007,dtoc(dDataBase),"","",cCodPad,cCodPro}) //"Data do atendimento"
	         
	    	// Alias e caminho da critica.
	   		PLSCOMPCRI(aRet,"BA1")
	   		
      	 Endif
      	 
      Else
      
	     For nFor := 1 To Len(aBD6)     
	                                                  
	      	 cCodPad := aBD6[nFor,3]
	      	 cCodPro := aBD6[nFor,4]
         
             aadd(aRet,{__aCdCri072[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
         
             If lDetalhe
             
	             aadd(aRet,{"",STR0006,dtoc(BA1->BA1_DTVLCE),"","",cCodPad,cCodPro}) //"Data de Validade do Cartao da Empresa"
	             aadd(aRet,{"",STR0007,dtoc(dDataBase),"","",cCodPad,cCodPro}) //"Data do atendimento"
	             
	   			// Alias e caminho da critica.
	  		 	PLSCOMPCRI(aRet,"BA1")
         	 Endif
         	 
         Next
         
      Endif   
         
      aRetFun   := {.F.,aRet,"BA1","1"}
      lContinua := .F.
      
   Endif
   
Endif

//Para os casos em que o beneficiario esteja internado o sistema não deverá apresentar a critica de Usuario bloqueado DSAUBE-14286
lInternado := PLSUSRINTE( BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), dData )[1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o usuario esta ativo ou nao...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVldBlq .and. PLSPOSGLO(PLSINTPAD(),__aCdCri009[1],__aCdCri009[2],cLocalExec,NIL,cTpLocExec) .And. PLSCHKCRI( {'BAU',cCodRda,__aCdCri009[1]} ) .And. !lBloFam .and. 	!lInternado


	If ! empty(BA1->BA1_DATBLO) .and. dData >= (BA1->BA1_DATBLO + nDiasBloq) 
	
			BCA->(DbSetOrder(1))
			BCA->(Dbseek(xFilial("BCA")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)+dtos(BA1->BA1_DATBLO)+"0"))
		
			If BCA->BCA_NIVBLQ == "S"			//Bloqueio por SubContrato
				cAliasPesq := "BQU"
			ElseIf BCA->BCA_NIVBLQ == "F"		//Bloqueio por Familia
				cAliasPesq := "BG1"
			ElseIf BCA->BCA_NIVBLQ == "U"		//Bloqueio por Usuario
				cAliasPesq := "BG3"
			EndIf
		
			If Len(aBD6) == 0
				
				aadd(aRet,{__aCdCri009[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				
				If lDetalhe
					
					aadd(aRet,{"",STR0008 + dtoc( ( BA1->BA1_DATBLO + nDiasBloq ) - 1 ) + STR0009,"","","",cCodPad,cCodPro}) //"Somente guias ate "###" serao validas."
					aadd(aRet,{"",STR0002,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Evento"
					aadd(aRet,{"",STR0003,dtoc(BA1->BA1_DATBLO),"","",cCodPad,cCodPro}) //"Data de Bloqueio"
					aadd(aRet,{"",STR0004,BA1->BA1_MOTBLO+" - "+Posicione(cAliasPesq,1,xFilial(cAliasPesq)+BA1->BA1_MOTBLO,cAliasPesq+"_DESBLO"),"","",cCodPad,cCodPro}) //"Motivo do Bloqueio"
					
					If BCA->(Found())
						aadd(aRet,{"",STR0005,BCA->BCA_OBS,"","",cCodPad,cCodPro}) //"Observacoes do Bloqueio"
					Endif
				
					// Alias e caminho da critica.
					PLSCOMPCRI(aRet,"BA1")
					
				Endif
				
			Else
				
				For nFor := 1 To Len(aBD6)
				
					cCodPad := aBD6[nFor,3]
					cCodPro := aBD6[nFor,4]
					aadd(aRet,{__aCdCri009[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
					
					If lDetalhe
					
						aadd(aRet,{"",STR0008 + dtoc( ( BA1->BA1_DATBLO + nDiasBloq ) - 1 ) + STR0009,"","","",cCodPad,cCodPro}) //"Somente guias ate "###" serao validas."
						aadd(aRet,{"",STR0002,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Evento"
						aadd(aRet,{"",STR0003,dtoc(BA1->BA1_DATBLO),"","",cCodPad,cCodPro}) //"Data de Bloqueio"
						aadd(aRet,{"",STR0004,BA1->BA1_MOTBLO+" - "+Posicione(cAliasPesq,1,xFilial(cAliasPesq)+BA1->BA1_MOTBLO,cAliasPesq+"_DESBLO"),"","",cCodPad,cCodPro}) //"Motivo do Bloqueio"
					
						If BCA->(Found())
							aadd(aRet,{"",STR0005,BCA->BCA_OBS,"","",cCodPad,cCodPro}) //"Observacoes do Bloqueio"
						Endif
					
						// Alias e caminho da critica.
						PLSCOMPCRI(aRet,"BA1")
						
					Endif
				Next
			Endif
		
			aRetFun 	:= {.F.,aRet,"BA1","1"}
			lContinua 	:= .F.	
	
	Elseif lVldBlq .AND. PlChHiBlo("BCA",dData,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG,@dDatIniBlo,@dDatFinBlo,@cMotBlo,nil,nil,nil,nil,cHorPar)

		BCA->(DbSetOrder(1))
		BCA->(msSeek(xFilial("BCA")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG) + dtos(dData) + "0"))
	
		If BCA->BCA_NIVBLQ == "S"			//Bloqueio por SubContrato
			cAliasPesq := "BQU"
		ElseIf BCA->BCA_NIVBLQ == "F"		//Bloqueio por Familia
			cAliasPesq := "BG1"
		ElseIf BCA->BCA_NIVBLQ == "U"		//Bloqueio por Usuario
			cAliasPesq := "BG3"
		EndIf
	
		//retirei esse bloco pois a função PlChHiBlo verifica o historico de bloqueio, se ela retorna que o usuário está bloqueado,
		//porque eu devo olhar o BA1_DATBLO?
		//aconteceu a seguinte situação, suponha hoje dia 08/07/2017
		//há um bloqueii do dia 01/01/2017 até 31/07/2017, ou seja, dia 08/07 o beneficiário encontra-se bloqueado
		//colocamos um bloqueio futuri em 01/01/2018, o sistema coloca essa data no BA1_DATBLO		
		// 01/01/2018 é maior que 08/07/2017 ai esse if retorna o aRetFun com o usuário desbloqueado.

		If Len(aBD6) == 0
			
			aadd(aRet,{__aCdCri009[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
			
			If lDetalhe
				
				aadd(aRet,{"",STR0008 + dtoc( dDatIniBlo - 1 ) + STR0009,"","","",cCodPad,cCodPro}) //"Somente guias ate "###" serao validas."
				aadd(aRet,{"",STR0002,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Evento"
				aadd(aRet,{"",IIF(! Empty(dDatFinBlo),STR0029,STR0003),IIF(! Empty(dDatFinBlo),STR0030 + DtoC(dDatIniBlo) + STR0031 + DtoC(dDatFinBlo),DtoC(dDatIniBlo)),"","",cCodPad,cCodPro}) //"Periodo do Bloqueio" - "De ##/##/#### Até ##/##/####" ou "Data de Bloqueio"
				aadd(aRet,{"",STR0004,cMotBlo+" - "+Posicione(cAliasPesq,1,xFilial(cAliasPesq)+cMotBlo,cAliasPesq+"_DESBLO"),"","",cCodPad,cCodPro}) //"Motivo do Bloqueio"
				
				If BCA->(Found())
					aadd(aRet,{"",STR0005,BCA->BCA_OBS,"","",cCodPad,cCodPro}) //"Observacoes do Bloqueio"
				endIf
			
				// Alias e caminho da critica.
				PLSCOMPCRI(aRet,"BA1")
				
			Endif
			
		Else
		
			For nFor := 1 To Len(aBD6)
				
				cCodPad := aBD6[nFor,3]
				cCodPro := aBD6[nFor,4]
				
				aadd(aRet,{__aCdCri009[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				
				If lDetalhe
					aadd(aRet,{"",STR0008 + dtoc( ( BA1->BA1_DATBLO + nDiasBloq ) - 1 ) + STR0009,"","","",cCodPad,cCodPro}) //"Somente guias ate "###" serao validas."
					aadd(aRet,{"",STR0002,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Evento"
					aadd(aRet,{"",IIF(! Empty(dDatFinBlo),STR0029,STR0003),IIF(! Empty(dDatFinBlo),STR0030 + DtoC(dDatIniBlo) + STR0031 + DtoC(dDatFinBlo),DtoC(dDatIniBlo)),"","",cCodPad,cCodPro}) //"Periodo do Bloqueio" - "De ##/##/#### Até ##/##/####" ou "Data de Bloqueio"
					aadd(aRet,{"",STR0004,cMotBlo+" - "+Posicione(cAliasPesq,1,xFilial(cAliasPesq)+cMotBlo,cAliasPesq+"_DESBLO"),"","",cCodPad,cCodPro}) //"Motivo do Bloqueio"
					
					If BCA->(Found())
						aadd(aRet,{"",STR0005,BCA->BCA_OBS,"","",cCodPad,cCodPro}) //"Observacoes do Bloqueio"
					Endif

					// Alias e caminho da critica.
					PLSCOMPCRI(aRet,"BA1")
				Endif
				
			Next
			
		Endif
	
		aRetFun 	:= {.F.,aRet,"BA1","1"}
		lContinua 	:= .F.
	
	Endif
Endif   
//Verifico aqui se o BA1_DATINC foi alterado apos o desbloqueio do beneficiario (reativação), pois neste caso, no reembolso, passo a verificar somente se na data do evento estava bloqueado.
BCA->(Dbsetorder(1))
lPulacar:=FUNNAME()="PLSA001A".AND.BCA->(Dbseek(xFilial("BCA")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)+Dtos(BA1->BA1_DATCAR)+'1')).AND. ddata < BA1->BA1_DATCAR

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se nesta data o usuario ja estava no plano...                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSPOSGLO(PLSINTPAD(),__aCdCri024[1],__aCdCri024[2],cLocalExec,NIL,cTpLocExec) .And. PLSCHKCRI( {'BAU',cCodRda,__aCdCri024[1]} ) .And. ! Empty(BA1->BA1_DATINC) .And. ! Empty(BA1->BA1_DATCAR)
	If GetNewPar("MV_PLSUNI","0") == "1" .And. GetNewPar("MV_PLSGEIN","0050") == BA1->BA1_CODEMP
		lInterc := .T.
	EndIf
	If ((GetNewPar("MV_PLIDCAR","1") == "1" .And. (dtos(dData) < dtos(BA1->BA1_DATINC) .Or. (dtos(dData) < dtos(BA1->BA1_DATCAR) .And. !lInterc) )) .Or. ;
		(GetNewPar("MV_PLIDCAR","1") <> "1" .And. dtos(dData) < dtos(BA1->BA1_DATINC) )) .and. !lPulaCar
		
		
		
		If Len(aBD6) == 0
			
			aadd(aRet,{__aCdCri024[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
			
			If lDetalhe
				aadd(aRet,{"",STR0010,dtoc(BA1->BA1_DATINC),"","",cCodPad,cCodPro}) //"Data de inclusao do usuario"
				aadd(aRet,{"",STR0011,dtoc(BA1->BA1_DATCAR),"","",cCodPad,cCodPro}) //"Data base de carencia do usuario"
				aadd(aRet,{"",STR0012,dtoc(dData),"","",cCodPad,cCodPro}) //"Data de utilizacao do evento"
				
				// Alias e caminho da critica.
				PLSCOMPCRI(aRet,"BA1")
			Endif
			
		Else
			
			For nFor := 1 To Len(aBD6)
				
				cCodPad := aBD6[nFor,3]
				cCodPro := aBD6[nFor,4]
				
				aadd(aRet,{__aCdCri024[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
				
				If lDetalhe
					aadd(aRet,{"",STR0010,dtoc(BA1->BA1_DATINC),"","",cCodPad,cCodPro}) //"Data de inclusao do usuario"
					aadd(aRet,{"",STR0011,dtoc(BA1->BA1_DATCAR),"","",cCodPad,cCodPro}) //"Data base de carencia do usuario"
					aadd(aRet,{"",STR0012,dtoc(dData),"","",cCodPad,cCodPro}) //"Data de utilizacao do evento"
					
					// Alias e caminho da critica.
					PLSCOMPCRI(aRet,"BA1")
				Endif
				
			Next
			
		Endif
		
		aRetFun 	:= {.F.,aRet,"BA1","1"}
		lContinua := .F.
		
		
	Endif
Endif
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica data limite de atendimento....                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSPOSGLO(PLSINTPAD(),__aCdCri067[1],__aCdCri067[2],cLocalExec,NIL,cTpLocExec) .And. PLSCHKCRI( {'BAU',cCodRda,__aCdCri067[1]} )
   If ! Empty(BA3->BA3_LIMITE) .And. dtos(dData) > dtos(BA3->BA3_LIMITE)
      
      If Len(aBD6) == 0         			            
         aadd(aRet,{__aCdCri067[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
         If lDetalhe
	         aadd(aRet,{"",STR0013,dtoc(BA3->BA3_LIMITE),"","",cCodPad,cCodPro}) //"Data Limite para Atendimento"
	         aadd(aRet,{"",STR0007,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Atendimento"
	         aadd(aRet,{"",STR0014,str(dData - BA3->BA3_LIMITE,6),"","",cCodPad,cCodPro}) //"Qtd. de dias ultrapassados"
	         
	   	     // Alias e caminho da critica.
	   	  	 PLSCOMPCRI(aRet,"BA1")         
      	 Endif
      Else
     	 For nFor := 1 To Len(aBD6)                                                  
	      	 cCodPad := aBD6[nFor,3]
	      	 cCodPro := aBD6[nFor,4]
             aadd(aRet,{__aCdCri067[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
             If lDetalhe
	             aadd(aRet,{"",STR0013,dtoc(BA3->BA3_LIMITE),"","",cCodPad,cCodPro}) //"Data Limite para Atendimento"
	             aadd(aRet,{"",STR0007,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Atendimento"
	             aadd(aRet,{"",STR0014,str(dData-BA3->BA3_LIMITE,6),"","",cCodPad,cCodPro}) //"Qtd. de dias ultrapassados"
	             
	   	     	 // Alias e caminho da critica.
	   	   		 PLSCOMPCRI(aRet,"BA1")             
         	 Endif
         Next
      Endif
         
      aRetFun 	:= {.F.,aRet,"BA1","1"}
      lContinua := .F.
   Endif
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica data de validade do cartao do usuario...                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSPOSGLO(PLSINTPAD(),__aCdCri073[1],__aCdCri073[2],cLocalExec,NIL,cTpLocExec) .And. PLSCHKCRI( {'BAU',cCodRda,__aCdCri073[1]} )
   If ! Empty(BA1->BA1_DTVLCR) .And. dtos(dData) > dtos(BA1->BA1_DTVLCR) .And. !lInterc
      If Len(aBD6) == 0         			                  
         aadd(aRet,{__aCdCri073[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
         If lDetalhe
	         aadd(aRet,{"",STR0015,dtoc(BA1->BA1_DTVLCR),"","",cCodPad,cCodPro}) //"Data de validade do cartao magnetico"
	         aadd(aRet,{"",STR0007,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Atendimento"
	         aadd(aRet,{"",STR0014,str(dData - BA1->BA1_DTVLCR,6),"","",cCodPad,cCodPro}) //"Qtd. de dias ultrapassados"
	         
	      	 // Alias e caminho da critica.
	  		 PLSCOMPCRI(aRet,"BA1")
      	 Endif
      Else
     	 For nFor := 1 To Len(aBD6)                                                  
	      	 cCodPad := aBD6[nFor,3]
	      	 cCodPro := aBD6[nFor,4]
             aadd(aRet,{__aCdCri073[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
             If lDetalhe
	             aadd(aRet,{"",STR0015,dtoc(BA1->BA1_DTVLCR),"","",cCodPad,cCodPro}) //"Data de validade do cartao magnetico"
	             aadd(aRet,{"",STR0007,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Atendimento"
	             aadd(aRet,{"",STR0014,str(dData - BA1->BA1_DTVLCR,6),"","",cCodPad,cCodPro}) //"Qtd. de dias ultrapassados"
	             
	             // Alias e caminho da critica.
	   	   	     PLSCOMPCRI(aRet,"BA1")
         	 Endif
         Next
      Endif   
      
      aRetFun 	:= {.F.,aRet,"BA1","1"}
      lContinua := .F.
   Endif
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a RDA eh outra operadora                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ! empty(cCodRda)

    nOrdBAU := BAU->(IndexOrd())
    nRecBAU := BAU->(Recno())

    If  BAU->BAU_CODIGO <> cCodRda
        BAU->(DbSetOrder(1))
        BAU->(MsSeek(xFilial("BAU")+cCodRda))
        lMudou := .T.
    Else
        lMudou := .F.
    Endif

    If  BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")
        lRdaOpe := .T.
    Else
        lRdaOpe := .F.
    Endif
    
    If  lMudou
        BAU->(DbSetOrder(nOrdBAU))
        BAU->(DbGoTo(nRecBAU))
    Endif
    
Endif    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica periodo valido para recebimento de notas do intercambio...      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (!EMPTY(BA1->BA1_OPEORI) .And. BA1->BA1_OPEORI <> PLSINTPAD() .or. lRdaOpe) .And. ;
   PLSPOSGLO(PLSINTPAD(),__aCdCri033[1],__aCdCri033[2],cLocalExec,NIL,cTpLocExec).And. PLSCHKCRI( {'BAU',cCodRda,__aCdCri033[1]} )
 
   dDtLimInt := (dDatImp-nDiasNotIn)
    
   If dtos(dData) < dtos(dDtLimInt)
   
      If Len(aBD6) == 0         			                  
   
         aadd(aRet,{__aCdCri033[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
   
         If lDetalhe
	         aadd(aRet,{"",STR0016,dtoc(dDtLimInt)+" "+; //"Data limite para recebimento de notas para a operadora origem"
	                        AllTrim(str(nDiasNotIn))+STR0017,"","",cCodPad,cCodPro}) //" dia(s) "
	         aadd(aRet,{"",STR0007,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Atendimento"
	         aadd(aRet,{"",STR0014,str(dDtLimInt-dData,6),"","",cCodPad,cCodPro}) //"Qtd. de dias ultrapassados"
	         
	         // Alias e caminho da critica.
	   	   	 PLSCOMPCRI(aRet,"BA1")
	   	   	 
      	 Endif
      	 
      Else
      
     	 For nFor := 1 To Len(aBD6) 
     	                                                  
	      	 cCodPad := aBD6[nFor,3]
	      	 cCodPro := aBD6[nFor,4]
	      	 
             aadd(aRet,{__aCdCri033[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
             
             If lDetalhe
	         
	             aadd(aRet,{"",STR0016,dtoc(dDtLimInt)+" "+; //"Data limite para recebimento de notas para a operadora origem"
	                            AllTrim(str(nDiasNotIn))+STR0017,"","",cCodPad,cCodPro}) //" dia(s) "
	             aadd(aRet,{"",STR0007,dtoc(dData),"","",cCodPad,cCodPro}) //"Data do Atendimento"
	             aadd(aRet,{"",STR0014,str(dDtLimInt-dData,6),"","",cCodPad,cCodPro}) //"Qtd. de dias ultrapassados"
	           	 
	           	 // Alias e caminho da critica.
	   	   	 	 PLSCOMPCRI(aRet,"BA1")
	             
         	 Endif
         	 
         Next
         
      Endif
         
      aRetFun 	:= {.f.,aRet,"BA1","1"}
      lContinua := .F.
   Endif
   
Endif   

If ExistBlock("PLSAUT01")
   aRetFun := ExecBlock("PLSAUT01",.F.,.F.,{aRetFun,cMatric,dData,cCodPad,cCodPro})
Endif   

Return(aRetFun)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ PLSVLDFIN  ³ Autor ³ Tulio Cesar          ³ Data ³ 06.02.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Valida a parte financeira...                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cMatric    -> Matricula da Familia                            ³±±
±±³            ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDFIN(cMatric,dData,cCodPad,cCodPro,cLocalExec,aDadUsr,aBD6,lCheckFin,aDadAux,cTpLocExec) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cCodInt   := Subs(cMatric,atCodOpe[1],atCodOpe[2])
LOCAL cCodEmp   := Subs(cMatric,atCodEmp[1],atCodEmp[2])
LOCAL cMatrUs   := Subs(cMatric,atMatric[1],atMatric[2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conteudo do parametro MV_PLDIADB: 										 |
//| Sera numero de dias caso o parametro MV_PLTIPAT for 1 ou 2.              ³
//| Sera o numero de titulos em aberto caso o parametro MV_PLTIPAT for 3...  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nDiasPar  := 0 //GETMV("MV_PLDIADB")
LOCAL cPosTit   := alltrim(GetNewPar("MV_PLPOSTI","1")) // 1-titulos em aberto  2-titulos em aberto/baixados
LOCAL cTipAtr   := alltrim(GetNewPar("MV_PLTIPAT","2")) // 1-dias corridos  2-dias acumulados  3-Parcelas em aberto
LOCAL lDatBaixa := GetNewPar("MV_PLDATBA","0") == "1" // 0-Nao considera data da baixa /1-Considera data da baixa 
LOCAL nDiasAtr  := 0
LOCAL nAtraso   := 0
LOCAL nTits     := 0
LOCAL nSaldo    := 0
LOCAL aCodCri   := {}
LOCAL cCodCli   := ""
LOCAL cLoja     := ""
LOCAL nFor
LOCAL lGloFin   := .t.
LOCAL cDesFin   := ""
LOCAL cNivFin   := BCT->BCT_NIVEL
LOCAL cTipFin   := BCT->BCT_TIPO
LOCAL cNivCob   := ""           
LOCAL cCliGen   := GetNewPar("MV_PLSCLIG","999999")
LOCAL cMsg      := ""          
LOCAL aRetFun := {.T.,aCodCri}
LOCAL bPonto  := { || If(ExistBLock("PLSAUTF2"),ExecBLock("PLSAUTF2",.F.,.F.),.T.) }
LOCAL cConEmp   := ""
LOCAL cVerCon   := ""
LOCAL cSubCon   := ""
LOCAL cVerSub   := ""
LOCAL _cChavNiC := ""
LOCAL _bChavTit := {|| }
LOCAL lCritica	:= .F.
DEFAULT dData   	:= dDataBase
DEFAULT cCodPad 	:= ""
DEFAULT cCodPro 	:= ""
DEFAULT cLocalExec 	:= "1"
DEFAULT aDadUsr    	:= {}
DEFAULT aBD6       	:= {}
DEFAULT aDadAux		:= {}
DEFAULT lCheckFin  	:= .T.
DEFAULT cTpLocExec := '1' 

lGloFin   := PLSPOSGLO(PLSINTPAD(),__aCdCri017[1],__aCdCri017[2],cLocalExec,nil,cTpLocExec) 
cDesFin   := PLSBCTDESC()
If BA3->BA3_TIPOUS == "2" .And. BQC->(FieldPos("BQC_REGFIN")) > 0
   If BQC->BQC_REGFIN == "0"
      Return({.T.,aCodCri})
   Endif
Endif                   

If Len(aDadUsr) == 0 .and. Len(aDadAux) == 0  

   PLSPOSGLO(cCodInt,__aCdCri045[1],__aCdCri045[2],cLocalExec,nil,cTpLocExec)    

   If Len(aBD6) == 0         			                     
		  aadd(aCodCri,{__aCdCri045[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
	Else
   	  For nFor := 1 To Len(aBD6)                                                  
	      cCodPad := aBD6[nFor,3]
	      cCodPro := aBD6[nFor,4]
          aadd(aCodCri,{__aCdCri045[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})	      
      Next
   Endif   
   
   Return({.F.,aCodCri})
   
Elseif Len(aDadUsr) > 0
   cCodCli := aDadUsr[58]
   cLoja   := aDadUsr[59]
   cNivCob := aDadUsr[61]
   cConEmp := aDadUsr[9]
   cVerCon := aDadUsr[39]
   cSubCon := aDadUsr[41]
   cVerSub := aDadUsr[42]
   
Elseif Len(aDadAux) > 0
   cCodCli := aDadAux[1]
   cLoja   := aDadAux[2]
   cNivCob := aDadAux[3]
   cConEmp := aDadAux[4]
   cVerCon := aDadAux[5]
   cSubCon := aDadAux[6]
   cVerSub := aDadAux[7]
   
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Somente checar financeiro se a glosa estiver ativa e nao for intercambio ³
//³ eventual.                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCliGen == cCodCli //se for cliente generico nao critica...
   lGloFin := .F.
Endif

If lGloFin .And. cNivCob <> "5" .And. lCheckFin   //nivel 5 = operadora (intercambio)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o conteudo dos parametros sao validos                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! cPosTit $ "1,2" // 1-titulos em aberto  2-titulos em aberto/baixados
		cPosTit := "1"    // default = 1 porque os primeiros clientes tratavam assim
	Endif

	If ! cTipAtr $ "1,2,3"   // 1-Dias Corridos  2-Dias Acumulados  3-Parcelas em aberto
		cTipAtr := "2"      // default = 2 porque os primeiros clientes tratavam assim
   	Endif
                                   
	If cNivCob == "1" // Empresa
		_cChavNiC := cCodInt+cCodEmp
		_bChavTit := {|| SE1->(E1_CODINT+E1_CODEMP)}
		
	Elseif cNivCob == "2" //Nivel contrato
		_cChavNiC := cCodInt+cCodEmp+cConEmp+cVerCon
		_bChavTit := {|| SE1->(E1_CODINT+E1_CODEMP+E1_CONEMP+E1_VERCON)}
		
	Elseif cNivCob == "3"  //Nivel subcontrato
		_cChavNiC := cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub
		_bChavTit := {|| SE1->(E1_CODINT+E1_CODEMP+E1_CONEMP+E1_VERCON+E1_SUBCON+E1_VERSUB)}
		
	Elseif cNivCob == "4" //Nivel familia
		_cChavNiC := cCodInt+cCodEmp+cMatrUs
		_bChavTit := {|| SE1->(E1_CODINT+E1_CODEMP+E1_MATRIC)}
		
	Endif
		   		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	//³ Verifica a qtde Dias Inadimplencia ou Num Titulos Abertos...             ³
   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDiasPar:= PLSDIAIN(cNivCob, cMatric)

	If cPosTit == "1" // considerar apenas titulos em aberto
		If !lDatBaixa
		    SE1->(DbSetOrder(8))  
		    If SE1->(DbSeek(xFilial("SE1")+cCodCli+cLoja+"A"))
			    While ! SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_STATUS) == xFilial("SE1")+cCodCli+cLoja+"A"
				
				    //Tratamento ponto de entrada PLSAUTF2
				    If ! Eval(bPonto)
					    SE1->(DbSkip())
					    Loop
				    Endif
				
				    //Tratamento para nao considerar titulos NCC
				    If Alltrim(SE1->E1_TIPO) == "NCC"   
				        SE1->(DbSkip())
					    Loop
				    EndIf	
				
				    If dtos(dData) > dtos(SE1->E1_VENCREA)
					    If _cChavNiC == Eval(_bChavTit)
						    nAtraso   := dData - SE1->E1_VENCREA
    						If  cTipAtr == "1"
	    						nDiasAtr := If(nAtraso > nDiasAtr,nAtraso,nDiasAtr) // para dias corridos, utiliza o maior atraso
		    				Else
			    				nDiasAtr += nAtraso  // para dias acumulados, acumula os atrasos
				    		Endif
	    					nTits     += 1
		    				nSaldo    += SE1->E1_SALDO
			    		Endif
				    Endif
			    	SE1->(DbSkip())
    			Enddo
	    	Endif
		Else     
		    SE1->(DbSetOrder(2))  
		    If SE1->(DbSeek(xFilial("SE1")+cCodCli+cLoja))
			    While ! SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA) == xFilial("SE1")+cCodCli+cLoja
			  
				    //Tratamento ponto de entrada PLSAUTF2
			    	If ! Eval(bPonto)
			    		SE1->(DbSkip())
			    		Loop
			    	Endif    
				
			    	//Se estiver baixado e a baixa for inferior a data base pula o registro
			    	If SE1->E1_STATUS == "B" .And. SE1->E1_BAIXA <= dData
				        SE1->(DbSkip())
					    Loop
		    		Endif
				
		    		//Tratamento para nao considerar titulos NCC
		    		If Alltrim(SE1->E1_TIPO) == "NCC"   
			    	    SE1->(DbSkip())
			    		Loop
		        	EndIf	
				
			    	If dtos(dData) > dtos(SE1->E1_VENCREA)
				    	If _cChavNiC == Eval(_bChavTit)
					    	nAtraso   := dData - SE1->E1_VENCREA
						    If  cTipAtr == "1"
							    nDiasAtr := If(nAtraso > nDiasAtr,nAtraso,nDiasAtr) // para dias corridos, utiliza o maior atraso
		    				Else
			    				nDiasAtr += nAtraso  // para dias acumulados, acumula os atrasos
				    		Endif
					    	nTits     += 1
						    nSaldo    += IIF(SE1->E1_STATUS == "B",SE1->E1_VALOR,SE1->E1_SALDO)
    					Endif
	    			Endif
		    		SE1->(DbSkip())
			    Enddo
    		Endif
    	EndIf	
	Else  // considerar titulos em aberto/baixados
		dDatIni := dData - 365 // verifica ate 1 anos atras
		SE1->(DbSetOrder(8))
		If SE1->(DbSeek(xFilial("SE1")+cCodCli+cLoja))
			While ! SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA) == xFilial("SE1")+cCodCli+cLoja
				If dtos(dData)   >  dtos(SE1->E1_VENCREA) .and. ;
					dtos(dDatIni) <= dtos(SE1->E1_EMISSAO)
					
					//Tratamento ponto de entrada PLSAUTF2
					If ! Eval(bPonto)
						SE1->(DbSkip())
						Loop
					Endif
					
					//Tratamento para nao considerar titulos NCC
				    If Alltrim(SE1->E1_TIPO) == "NCC"   
				        SE1->(DbSkip())
					    Loop
				    EndIf	
					
					If _cChavNiC == Eval(_bChavTit)
						If  SE1->E1_SALDO == 0
							nAtraso   := SE1->E1_BAIXA - SE1->E1_VENCREA
						Else
							nAtraso   := dData - SE1->E1_VENCREA
						Endif
						If  cTipAtr == "1"
							nDiasAtr := If(nAtraso > nDiasAtr,nAtraso,nDiasAtr) // para dias corridos, utiliza o maior atraso
						Else
							nDiasAtr += nAtraso  // para dias acumulados, acumula os atrasos
						Endif
						If  SE1->E1_SALDO > 0
							nTits     += 1
						Endif
						nSaldo += SE1->E1_SALDO
					Endif
				Endif
				SE1->(DbSkip())
			Enddo
		Endif
	Endif

   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	//³ Valida o prazo maximo de dias em aberto...                               ³
   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  cTipAtr $ '1,2' .and. nDiasAtr > nDiasPar   	// 1-dias corridos  2-dias acumulados

		Do Case
			Case cPosTit == "1" .and. cTipAtr == "1"
				cMsg := STR0018 //"Dias Atrasados (dias corridos ref titulo em aberto mais antigo)"
			Case cPosTit == "1" .and. cTipAtr == "2"
				cMsg := STR0019 //"Dias Atrasados (dias acumulados ref titulos em aberto)"
			Case cPosTit == "2" .and. cTipAtr == "1"
				cMsg := STR0020 //"Dias Atrasados (dias corridos ref titulo com maior atraso)"
			Case cPosTit == "2" .and. cTipAtr == "2"
				cMsg := STR0021 //"Dias Atrasados (dias acumulados ref tit em aberto + tit pagos em atraso)"
		EndCase
		lCritica := .T.
		
	Elseif cTipAtr == '3' .and. nTits >= nDiasPar	// 3-Parcelas em aberto
		cMsg := STR0022 //"Parcelas(S) em Aberto"
		
		lCritica := .T.
	Endif
	
	If lCritica
		If Len(aBD6) == 0
			aadd(aCodCri,{__aCdCri017[1],cDesFin,"",cNivFin,cTipFin,cCodPad,cCodPro})
			aadd(aCodCri,{"",STR0022,AllTrim(Str(nTits)),"","",cCodPad,cCodPro}) //"Parcelas(S) em Aberto"
			If cTipAtr <> '3'
				aadd(aCodCri,{"",cMsg,AllTrim(Str(nDiasAtr)),"","",cCodPad,cCodPro})
			Endif
			aadd(aCodCri,{"",STR0023,AllTrim(Str(nSaldo,17,2)),"","",cCodPad,cCodPro}) //"Saldo Original"
		Else
  			For nFor := 1 To Len(aBD6)                                                  
	        	cCodPad := aBD6[nFor,3]
	          	cCodPro := aBD6[nFor,4]
              	aadd(aCodCri,{__aCdCri017[1],cDesFin,"",cNivFin,cTipFin,cCodPad,cCodPro})
              	aadd(aCodCri,{"",STR0022,AllTrim(Str(nTits)),"","",cCodPad,cCodPro}) //"Parcelas(S) em Aberto"
				If cTipAtr <> '3'
					aadd(aCodCri,{"",cMsg,AllTrim(Str(nDiasAtr)),"","",cCodPad,cCodPro})
				Endif
    			aadd(aCodCri,{"",STR0023,AllTrim(Str(nSaldo,17,2)),"","",cCodPad,cCodPro}) //"Saldo Original"
          	Next
       Endif   
       
       aRetFun := {.F.,aCodCri}
   Endif                                                          
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Ponto de entrada para validacao de regras financeiras do usuario         ³
   //³ obs: regras adicionais, alem das regras padroes do sistema               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If  ExistBlock("PLSAUTF1")
       aRetFun := ExecBlock("PLSAUTF1",.F.,.F.,{aRetFun,cMatric,dData,cLocalExec})
   Endif                                                          
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aRetFun)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ PLSVLDRDA  ³ Autor ³ Tulio Cesar          ³ Data ³ 06.02.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Valida a parte da rede de atendimento...                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDRDA(cLocalExec,cCodPad,cCodPro,aBD6,aRDAWeb,cAlias)
LOCAL nFor			:= 0
LOCAL nPos			:= 0
LOCAL nForCri       	:= 0
LOCAL cCodRda	 		:= ""
LOCAL aRet       		:= {}
LOCAL lRet       		:= .F.
LOCAL lAllRed			:= .F.
LOCAL aDadRDA    		:= PLSGETRDA()
LOCAL aDadUsr    		:= PLSGETUsr()
LOCAL aRedAtdRda 		:= {}
LOCAL aRedAtdUsr 		:= {}
LOCAL dDataProc		:= dDatabase  
LOCAL cOpePad        := PLSINTPAD()
LOCAL lFound         := .F.

	
DEFAULT cLocalExec 	:= "1"
DEFAULT cCodPad    	:= ""
DEFAULT cCodPro    	:= ""
DEFAULT aBD6       	:= {}
DEFAULT aRdaWeb    	:= {}
DEFAULT cAlias			:= ""

cCodRda := IiF(len(aDadRda) > 2 , aDadRda[2],"" )

if PLSPOSGLO(PLSINTPAD(),__aCdCri074[1],__aCdCri074[2],cLocalExec,"0",If(Len(aRDAWEb)> 0,"2","")) .And. PLSCHKCRI( {'BAU',cCodRda,__aCdCri074[1]} )

	if ( len(aDadRDA) > 0 .or. len(aRDAWeb)>0 ) .and. len(aDadUsr) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Todo tipo de rede de atendimento quer dizer o plano que esta definido na RDA 
		//³ e nao o produto do usuario. BI3_ALLRED=1
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		if len(aDadUsr) >= 24
			lAllRed := aDadUsr[24]=="1"
		endIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Somente entra para checar regras da BBK e BBI se BI3_ALLRED for igual a 0 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
      	if !lAllRed
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Primeiro verifica BBK com BB6 (Rede de Atendimento no cadastro da RDA) 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			if len(aRDAWeb) > 0
				aRedAtdRda := PLSRDAREF('BBK',aRDAWeb[1]+aRDAWeb[4]+aRDAWeb[3])
			else
				aRedAtdRda := if(len(aDadRda)>=26,aDadRda[26],{})
			endif
		  
			aRedAtdUsr := if(len(aDadUsr)>=57,aDadusr[57],{})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ BOPS 101091: Se esta marcado "Todos os Tipos de Rede de Atendimento" no "cadastro 
			//³              do produto saude" cadastrado para o usuario, permite qualquer RDA.   
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			for nFor := 1 to len(aRedAtdRda)
				nPos := ascan(aRedAtdUsr,{|x| x[1] == aRedAtdRda[nFor]})
				if nPos > 0 
					BB6->(dbSetOrder(1)) //BB6_FILIAL+BB6_CODIGO+BB6_VERSAO+BB6_CODRED
					If (BB6->(MsSeek(xFilial("BB6")+cOpePad+aDadUsr[11]+aDadUsr[12]+aRedAtdRda[nFor])) .AND. BB6->BB6_ATIVO !="0")
						lRet := .T.
						Exit
					EndIf
				endif
			next
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Segundo verifico o folder planos BBI (Cadastro da RDA) 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			if !lRet .and. len(aDadRDA) > 0
			
				BBI->(DbSetOrder(1))//BBI_FILIAL+BBI_CODIGO+BBI_CODINT+BBI_CODLOC+BBI_CODESP+BBI_CODPRO+BBI_VERSAO
				if BBI->(MsSeek(xFilial("BBI")+aDadRda[2]+aDadRda[14]+aDadRda[12]+aDadRda[15]+aDadUsr[11]+aDadUsr[12]))
					
					if BBI->BBI_ATIVO  == "1"        
				
						if FunName() == "PLSA092"
							dDataProc	:=	 M->BE4_DATVAL
						elseIf FunName() == "PLSA001"
							dDataProc	:=	 M->B44_DATPRO
						else
							dDataProc	:=	dDataBase
						endIf
				
						if PLSINTVAL("BBI","BBI_VIGDE","BBI_VIGATE",dDataProc)
							lRet := .T.
						endIf
					endIf
					
				endIf
				
			endIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o produto que o usuario possui, pode ser atendido por esta RDA - Solicitacao WEB        ³
			//³ OBS: No momento da verificacao no Portal, a especialidade ainda nao foi informada (Pre Atendimento) ³
			//³ assim, o sistema validara com base na primeira especialidade do local de atendimento                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !lRet .and. len(aRDAWeb) > 0
				BBI->(dbSetOrder(1))//BBI_FILIAL+BBI_CODIGO+BBI_CODINT+BBI_CODLOC+BBI_CODESP+BBI_CODPRO+BBI_VERSAO
				if BBI->(MsSeek(xFilial("BBI")+aRDAWeb[1]+aRDAWeb[4]+aRDAWeb[3]))
	
					while !BBI->(eof()) .and. BBI->(BBI_FILIAL+BBI_CODIGO+BBI_CODINT+BBI_CODLOC) = xFilial("BBI")+aRDAWeb[1]+aRDAWeb[4]+aRDAWeb[3]
	
						if BBI->BBI_CODPRO = aDadUsr[11] .and. BBI->BBI_ATIVO == "1"  .and. PLSINTVAL("BBI","BBI_VIGDE","BBI_VIGATE",dDataBase)
							lRet := .T.
							Exit
						endif
						BBI->(dbSkip())
					enddo
				endIf
			endIf
			//Verifico se há outro BBK liberado e sugiro a atualização (Apenas na validação do M->BE1_CODRDA)
			//acrescentado lRet pois mesmo tendo permissao estava entrando nessa funcao sem necessidade
			If !lRet .AND. AnyBBK(aDadRDA,aRedAtdUsr,cAlias,ReadVar()) .AND. len(aDadRDA) > 0
				lRet := .T.
			EndIf
			//Pesquiso se ha BB6. Isso quando o usuario digitar o codigo da Operadora diferente da minha Operadora 
			If !lRet .AND. len(aDadRDA) >= 14 .AND. aDadRda[14] <> PLSINTPAD() 
				BB6->(dbSetOrder(1))
				if BB6->(MsSeek(xFilial("BB6")+cOpePad+aDadUsr[11]+aDadUsr[12])) .AND. BB6->BB6_ATIVO =="1" 				   
				   lRet := .T.
				EndIf   
			EndIf

		else	
			lRet := .T.
		endIf
	else
		lRet := .T.
	endIf
else
	lRet := .T.
endIf
      
 if !lRet
	if len(aBD6) == 0
		aadd(aRet,{__aCdCri074[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
	else
		for nForCri := 1 to len(aBD6)
			cCodPad := aBD6[nForCri,3]
			cCodPro := aBD6[nForCri,4]
			aadd(aRet,{__aCdCri074[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
		next
	endIf
endIf

if len(aRet) > 0
	lFound := FdCrifor(M->BE1_NUMLIB,aRet,cCodRda,{},{},)
	if  lFound 
		  lRet := .T.
	      aRet := {}
	endIf
EndIf	
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina...                                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return({lRet,aRet})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ PLSDIAIN   ³ Autor ³ Totvs			       ³ Data ³27.12.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Verifica a Qtd dia Inadimplencia ou Titulos Abertos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cNivCob    -> Nivel Cobrança		                           ³±±
±±³            ³ cMatricula -> Código Matricula                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION PLSDIAIN(cNivCob, cMatricula)
// nDiasInad
// Verifica os niveis para verificar se o campo de dias de inadimplencia esta preenchido
// Sera numero de dias caso o parametro MV_PLTIPAT for 1 ou 2.         
// Sera o numero de titulos em aberto caso o parametro MV_PLTIPAT for 3. 
LOCAL aAlias 	:= GetArea()
LOCAL nDiasInad := GetNewPar("MV_PLDIADB",0)
LOCAL aRetCli   := {}

Default cNivCob 	:= ""
Default cMatricula  := ""

BA3->(DbSetOrder(1))
If BA3->( FieldPos("BA3_DIASIN") ) > 0 // .And. !Empty(cMatricula) .And. BA3->(MsSeek(xFilial("BA3")+cMatricula)) // Retirado pois a tabela ja esta posicionada e o seek nao funciona com pessoa fisica
 	
 	If Empty(cNivCob)
		// Verifica o nivel de cobranca...
		aRetCli := PLSRETNCB(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,BA3->BA3_CODINT)
		If aRetCli[1]           
			aDadAux := {aRetCli[2], aRetCli[3], aRetCli[5], BA3->BA3_CONEMP, BA3->BA3_VERCON, BA3->BA3_SUBCON, BA3->BA3_VERSUB}
		 	//Verifica o nivel de cobrança do usuario
		 	If Len(aDadAux) > 2
		 		cNivCob := aDadAux[3]
	        Endif
	    Endif
	Endif

 	If !Empty(cNivCob)
	 	If cNivCob == "1" // Empresa
			BG9->(DbSetOrder(1))
		    If BG9->( FieldPos("BG9_DIASIN") ) > 0 .And. BG9->(MsSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP))).And.;
		       BG9->BG9_DIASIN > 0
				nDiasInad := BG9->BG9_DIASIN
			Endif
		Elseif cNivCob == "2" //Nivel contrato
			BT5->(DbSetOrder(1))
		    If BT5->( FieldPos("BT5_DIASIN") ) > 0 .And. BT5->(MsSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON))) .And.;
		       BT5->BT5_DIASIN > 0
				nDiasInad := BT5->BT5_DIASIN
			Endif
		Elseif cNivCob == "3"  //Nivel subcontrato
			BQC->(DbSetOrder(1))
		    If BQC->( FieldPos("BQC_DIASIN") ) > 0 .And. BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)));
		     	.And. BQC->BQC_DIASIN > 0
				nDiasInad := BQC->BQC_DIASIN
			Endif	
		Elseif cNivCob == "4" //Nivel familia
		    If BA3->BA3_DIASIN > 0
				nDiasInad := BA3->BA3_DIASIN
			Endif
		Endif
	Endif	
Endif 

RestArea(aAlias)

Return nDiasInad

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ AnyBBK		³ Autor ³ Totvs				   ³ Data ³11.07.2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o  ³ Verifica se existe algum local/especialidade permitida na BBK ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ aDadRDA    -> Dados da Rede de Atendimento						  ³±±
±±³            ³ aRedAtdUsr -> Tipos de Planos aceitos							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AnyBBK(aDadRDA,aRedAtdUsr,cAlias,cCampo)

Local lRet := .F.
Local cBuf := ""
Local cSql := ""
Local lAtendPort := IsInCallStack("PLVLDPRE") .And. FunName() == "RPC" // Pré Atendimento - Portal do Prestador

If ! (cCampo $ "M->BE1_CODRDA|M->BE1_CODLOC") .And. !lAtendPort
	Return lRet
EndIf

If Len(aRedAtdUsr) > 0
	AEval(aRedAtdUsr,{|x| cbuf += x[1]+","})
	cBuf := SubStr(cBuf,1,Len(cBuf)-1)
EndIf

If Empty(cBuf)
	If !lAtendPort 	
		MsgStop(STR0032+Chr(13)+Chr(10)+STR0033,__aCdCri074[2])
	EndIf		
	
	Return .F.
EndIf

cSql := " SELECT BBK.BBK_CODINT, BB8.BB8_CODLOC, BB8.BB8_LOCAL, BB8.BB8_DESLOC, BB8.BB8_END, BB8.BB8_NR_END, BB8.BB8_COMEND, BB8.BB8_BAIRRO, "
cSql += " BBK.BBK_CODESP FROM "+RetSQLName("BBK")+" BBK, " + RetSQLName("BAX")+ " BAX, " + RetSQLName("BB8")+" BB8 "
cSql += " WHERE "
cSql += " BBK.BBK_FILIAL = BAX.BAX_FILIAL AND BBK.BBK_CODIGO = BAX.BAX_CODIGO AND BBK.BBK_CODINT = BAX.BAX_CODINT AND "
cSql += " BBK.BBK_CODLOC = BAX.BAX_CODLOC AND BBK.BBK_CODESP = BAX.BAX_CODESP AND BB8.BB8_FILIAL = BAX.BAX_FILIAL AND "
cSql += "	BB8.BB8_CODIGO = BAX.BAX_CODIGO AND BB8.BB8_CODINT = BAX.BAX_CODINT AND "
cSql += "	BB8.BB8_CODLOC = BAX.BAX_CODLOC AND BBK.BBK_FILIAL = '"+xFilial("BBK")+"' "
cSql += " AND BBK_CODIGO =  '"+aDadRda[2]+"' "
cSql += " AND BBK_CODINT =  '"+aDadRda[14]+"' "
cSql += " AND BBK_CODLOC =  '"+aDadRda[12]+"' "
cSql += " AND BBK_CODRED IN  ("+cBuf+") "
cSql += " AND BAX.BAX_DATBLO = ' ' AND BB8.BB8_DATBLO = ' ' "
cSql += " AND BBK.D_E_L_E_T_=' ' AND BAX.D_E_L_E_T_=' ' AND BB8.D_E_L_E_T_=' ' "

cSql += " UNION "

cSql += " SELECT BBK.BBK_CODINT, BB8.BB8_CODLOC, BB8.BB8_LOCAL, BB8.BB8_DESLOC, BB8.BB8_END, BB8.BB8_NR_END, BB8.BB8_COMEND, BB8.BB8_BAIRRO, "
cSql += " BBK.BBK_CODESP FROM "+RetSQLName("BBK")+" BBK, " + RetSQLName("BAX")+ " BAX, " + RetSQLName("BB8")+" BB8 "
cSql += " WHERE "
cSql += "	BBK.BBK_FILIAL = BAX.BAX_FILIAL AND BBK.BBK_CODIGO = BAX.BAX_CODIGO AND BBK.BBK_CODINT = BAX.BAX_CODINT AND "
cSql += " BBK.BBK_CODLOC = BAX.BAX_CODLOC AND BBK.BBK_CODESP = BAX.BAX_CODESP AND BB8.BB8_FILIAL = BAX.BAX_FILIAL AND "
cSql += "	BB8.BB8_CODIGO = BAX.BAX_CODIGO AND BB8.BB8_CODINT = BAX.BAX_CODINT AND BB8.BB8_CODLOC = BAX.BAX_CODLOC AND "
cSql += "	BBK.BBK_FILIAL =  '"+xFilial("BBK")+"' "
cSql += " AND BBK_CODIGO =  '"+aDadRda[2]+"' "
cSql += " AND BBK_CODINT =  '"+aDadRda[14]+"' "
cSql += " AND BBK_CODLOC <> '"+aDadRda[12]+"' "
cSql += " AND BBK_CODRED IN ("+cBuf+") "
cSql += " AND BAX.BAX_DATBLO = ' ' "
cSql += " AND BB8.BB8_DATBLO = ' ' "
cSql += " AND BBK.D_E_L_E_T_=' ' AND BAX.D_E_L_E_T_=' ' AND BB8.D_E_L_E_T_=' ' "

cSql := ChangeQuery(cSql)
TCQUERY cSQL New ALIAS "TRBBBK"

//Encontrou um 'Local/Especialidade/Codigo de Rede' que tem permissão de atendimento
If ! TRBBBK->(Eof()) .And. IIF(!lAtendPort,(!Empty(cAlias)) .And. MsgYesNo(IIf(cCampo == "M->BE1_CODRDA",STR0025+Chr(13)+Chr(10)+STR0026,STR0027+Chr(13)+Chr(10)+STR0028),__aCdCri074[2]),.T.)//"A Localidade e a especialidade carregadas por padrão não tem permissão de execução."###"Deseja atualizar para uma localidade e uma especialidade permitida?"###"A especialidade carregada por padrão não tem permissão de execução."###"Deseja atualizar para uma especialidade permitida?"
	While !TRBBBK->( Eof() )
		If !lAtendPort // Remote
			If TRBBBK->(BB8_CODLOC+BB8_LOCAL)== M->BE1_CODLOC  // posiciona no local de atendimento indicado no atendimento
				
				&("M->"+cAlias+"_CODLOC") := TRBBBK->(BB8_CODLOC+BB8_LOCAL)
				&("M->"+cAlias+"_DESLOC") := TRBBBK->BB8_DESLOC
				&("M->"+cAlias+"_ENDLOC") := AllTrim(TRBBBK->BB8_END)+"+"+AllTrim(TRBBBK->BB8_NR_END)+"-"+AllTrim(TRBBBK->BB8_COMEND)+"-"+AllTrim(TRBBBK->BB8_BAIRRO)
				&("M->"+cAlias+"_CODESP") := TRBBBK->BBK_CODESP
				&("M->"+cAlias+"_DESESP") := AllTrim(Posicione("BAQ",1,xFilial("BAQ")+TRBBBK->(BBK_CODINT+BBK_CODESP),"BAQ_DESCRI"))
				
				lRet := .T.
				
			endif
		Else // Portal Prestador
			If TRBBBK->(BB8_CODLOC+BB8_LOCAL) == aDadRda[18] // Local de Atendimento indicado no Portal
				lRet := .T.
			Endif
		EndIf
		TRBBBK->( DbSkip() )
	EndDo
		
	If !lRet .And. !lAtendPort  // caso o não exista no local de atendimento indicado pega o primeiro
		
		&("M->"+cAlias+"_CODLOC") := TRBBBK->(BB8_CODLOC+BB8_LOCAL)
		&("M->"+cAlias+"_DESLOC") := TRBBBK->BB8_DESLOC
		&("M->"+cAlias+"_ENDLOC") := AllTrim(TRBBBK->BB8_END)+"+"+AllTrim(TRBBBK->BB8_NR_END)+"-"+AllTrim(TRBBBK->BB8_COMEND)+"-"+AllTrim(TRBBBK->BB8_BAIRRO)
		&("M->"+cAlias+"_CODESP") := TRBBBK->BBK_CODESP
		&("M->"+cAlias+"_DESESP") := AllTrim(Posicione("BAQ",1,xFilial("BAQ")+TRBBBK->(BBK_CODINT+BBK_CODESP),"BAQ_DESCRI"))
		
		lRet := .T.
		
	Endif
endif  

TRBBBK->(DbCloseArea())
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ PlChHiBlo	³ Autor ³ Totvs				   ³ Data ³ 08.01.2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Verifica no historico de bloqueio (subcontrato/familia/usuario)³±±
±±³            ³ se a data do evento a ser executado esteve bloqueado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cAlias     -> Alias da Tabela que sera verificada              ³±±
±±³            ³ dData      -> Data do evento         					   	    ³±±
±±³            ³ cChave     -> Chave para posicionar a tabela de historicos     ³±±
±±³            ³ cTipReg    -> Tipo de registro do beneficiario                 ³±±
±±³            ³ dDatIniBlo -> Data do inicio do bloqueio                       ³±±
±±³            ³ dDatFinBlo -> Data do fim do bloqueio                          ³±±
±±³            ³ cMotBlo    -> Motivo do bloqueio                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
function PlChHiBlo(cAlias, dData, cChave, cTipReg, dDatIniBlo, dDatFinBlo, cMotBlo, lConsTole, aVgDatBlo, lConDatBCA, cHora, cHorPar) 
local lRet			:= .f.
local (cTabTemp)		:= getNextAlias()
local (cAliIni)		:= getNextAlias()
local (cAliFin)		:= getNextAlias()
local dDtLanBlo		:= stod("")	// Data do Lançamento do Bloqueio
local dDtLanDesb	:= stod("")	// Data do Lançamento do Desbloqueio
local cHoraBlq		:= time()	// Hora do Lançamento do Bloqueio
local cHoraDesb		:= time()  	// Hora do Lançamento do DesBloqueio
local nDiaBloq		:= getNewPar("MV_PLDIABL", 0) //Tolerância de dias para atendimento
local nPosBloq		:= 0
local cQuery       := ""
Local csql := ""

default aVgDatBlo   := {} //coloquei essa variavel como parametro pois há uma situação em que precisarei utilizar o historico de bloqueio, dessa forma não preciso fazer outra query na tabela 
default dDatIniBlo	:= stod("")
default dDatFinBlo	:= stod("")
default lConsTole   := .t. // Se deve considerar os dias de tolerancia do nDiaBloq 
default lConDatBCA  := .t. // Indica se considera a Data na verificacao da BCA (nao vai considerar quando precisar de bloqueio futuro).
Default cHora		:= time() // esse parametro se faz necessarios pois temos cliente que customizam e utilizam essa função para controle de de bloqueios retroativos
DEFAULT cHorPar		:= time()

if ! lConsTole 
	nDiaBloq := 0
endIf 

//Se a chave estiver em branco o retorno falso deve ser imediato 
if empty(cChave)
	return lRet
endIf

//Checando no nivel do usuario  
if cAlias == "BCA"
	
	//Procura todos os bloqueios e desbloqueios do beneficiário
	cQuery := " SELECT BCA_DATA, BCA_TIPO,BCA_DATLAN, BCA_MOTBLO, BCA_HORLAN FROM " + RetSqlName("BCA") + " BCA " 
	cQuery += " WHERE BCA_FILIAL = '"+xFilial("BCA")+"' "
	cQuery += " AND BCA_MATRIC = '" +cChave + "' " 
	cQuery += " AND BCA_TIPREG = '" +cTipReg+ "' "   
	if lConDatBCA
		cQuery += " AND BCA_DATA <= '"+Dtos(dData)+"' " 	
	endIf
	cQuery += " AND D_E_L_E_T_  = ' ' "
	cQuery += " ORDER BY BCA.R_E_C_N_O_ " 
	
//	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTabTemp,.F.,.T.)
	
	while ! ((cTabTemp))->(eof())			
		
		if (cTabTemp)->BCA_TIPO == "0" 
							
			aadd( aVgDatBlo, { stod( (cTabTemp)->BCA_DATA ) + nDiaBloq, YEARSUM( dData, 2 ), (cTabTemp)->BCA_MOTBLO, (cTabTemp)->BCA_HORLAN,(cTabTemp)->BCA_TIPO } )

		elseIf len(aVgDatBlo) > 0				

			aVgDatBlo[ len(aVgDatBlo), 2 ] := stod( (cTabTemp)->BCA_DATA )
			aVgDatBlo[ len(aVgDatBlo), 4 ] := (cTabTemp)->BCA_HORLAN
			aVgDatBlo[ len(aVgDatBlo), 5 ] := (cTabTemp)->BCA_TIPO

		endIf
		 
	(cTabTemp)->(dbSkip())
	endDo

	(cTabTemp)->(dbCloseArea())
	
	//Se encontrar o range de datas inferior e superior a data que consta no dData, o usuário está bloqueado.
	nPosBloq := aScan(aVgDatBlo,{ |x| dData >= x[1] .and. ( dData < x[2] .or. (dData == x[2] .and. cHorPar <= x[4]) ) } )
	
	if nPosBloq > 0
		lRet 		:= .t.
		dDatIniBlo 	:= aVgDatBlo[nPosBloq,1]
		dDatFinBlo	:= aVgDatBlo[nPosBloq,2]
		cMotBlo		:= aVgDatBlo[nPosBloq,3]
	endIf

//Checando no nivel da familia 
elseIf cAlias == "BC3"

	csql := " SELECT BC3.R_E_C_N_O_, BC3_DATA, BC3_MOTBLO,BC3_DATLAN,BC3_HORLAN FROM " + retSqlName("BC3") + " BC3 "
	csql += " WHERE BC3_FILIAL = '" + xfilial("BC3") + "' "
	csql += "	AND BC3_MATRIC  = '" + cChave + "' "
	csql += "	AND BC3_TIPO    = '0' "
	csql += "	AND BC3_DATA    <= '" + Dtos(dData) + "' "
	csql += "	AND BC3.D_E_L_E_T_ =  ' ' "
	csql += "	ORDER BY BC3.R_E_C_N_O_ "
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,csql),cAliIni,.F.,.T.)
	
	//Armazenando a data de bloqueio gravada no historico (se houver)
	if ! (cAliIni)->(eof())
		dDatIniBlo 	:= stod((cAliIni)->BC3_DATA) + nDiaBloq
		dDtLanBlo	:= stod((cAliIni)->BC3_DATLAN)
		cMotBlo		:= (cAliIni)->BC3_MOTBLO
		cHoraBlq	:= (cAliIni)->BC3_HORLAN
    endIf
	
	(cAliIni)->(DbCloseArea())

	csql := " SELECT BC3.R_E_C_N_O_, BC3_DATA, BC3_MOTBLO,BC3_DATLAN,BC3_HORLAN FROM " + retSqlName("BC3") + " BC3 "
	csql += " WHERE BC3_FILIAL = '" + xfilial("BC3") + "' "
	csql += "	AND BC3_MATRIC  = '" + cChave + "' "
	csql += "	AND BC3_TIPO    = '1' "
	csql += "	AND BC3_DATA    >= '" + Dtos(dDatIniBlo - nDiaBloq) + "' "
	csql += "	AND BC3_DATA    <= '" + Dtos(dData) + "' "
	csql += "	AND BC3.D_E_L_E_T_ =  ' ' "
	csql += "	ORDER BY BC3.R_E_C_N_O_ "
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,csql),cAliFin,.F.,.T.)
	
	//Armazenando a data de desbloqueio gravada no historico (se houver)  
	if ! (cAliFin)->(eof())
		dDatFinBlo 	:= stod((cAliFin)->BC3_DATA)
		dDtLanDesb	:= stod((cAliFin)->BC3_DATLAN)
		cHoraDesb	:= (cAliFin)->BC3_HORLAN
	endIf
	
	(cAliFin)->(DbCloseArea())
	
	if ! empty(dDatFinBlo) .and. ! empty(dDatIniBlo) .and. ( dData >= dDatIniBlo .and. dData < dDatFinBlo)
		
		lRet := .t.
		
	elseIf ! empty(dDatIniBlo) .and. empty(dDatFinBlo) .and. (dData >= dDatIniBlo) 
		
		lRet := .t.
	
	elseIf ! empty(dDatIniBlo) .and. ! empty(dDatFinBlo) .and. (dData == dDatFinBlo .and. time() <= cHoraDesb)

		lRet := .t.
		
	endIf
	
endIf

return lRet
