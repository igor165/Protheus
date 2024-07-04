#INCLUDE "PWSTMS20.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS2X  ºAutor  ³Gustavo Almeida  º Data ³  01/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com layout de Solicitação de Coleta.          º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºWEBFUNC.     ³ DESCRIÇÃO                                               º±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPWSTMS20     ³ Página inicial.                                         º±±
±±ºPWSTMS21     ³ Página de Visualização.                                 º±±
±±ºPWSTMS22     ³ Página de Inclusão.                                     º±±
±±ºPWSTMS23     ³ Página de Parametros para Listagem de Solicitações.     º±±
±±ºPWSTMS24     ³ Página de Listagem de Solicitações.                     º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS20  ºAutor  ³Gustavo Almeida  º Data ³  01/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina Página Inicial de Solicitação de Coleta.      º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS20()

Local cHtml := ""
Local oObj


WEB EXTENDED INIT cHtml START "InSite"

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

//-- Liberação de Sessões
HttpSession->APWSTMS22HEADERINFO := Nil
HttpSession->APWSTMS22ITEMINFO   := Nil
HttpSession->EXCITENS            := Nil

HttpSession->APWSTMS20INFO:= {Nil,Nil}

If oObj:GETHEADER("NUMSOLCOL")
	HttpSession->APWSTMS20INFO[1]:= oObj:oWSGETHEADERRESULT:oWSBRWHEADER[1]:cHEADERTITLE
	HttpSession->APWSTMS20INFO[2]:= oObj:oWSGETHEADERRESULT:oWSBRWHEADER[1]:nHEADERSIZE                    	
EndIf

cHtml += ExecInPage( "PWSTMS20" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS21  ºAutor  ³Gustavo Almeida  º Data ³  11/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina Página de Visualização.                       º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS21()

Local cHtml   := ""
Local nI      := 0
Local nJ      := 0
Local nX      := 0 
Local aPict   := {}
Local aStaCorDT5 := {"bt_verde.gif"  ,"bt_vermelho.gif","bt_amarelo.gif",;
                     "bt_azul.gif"   ,"bt_laranja.gif" ,"bt_cinza.gif"  ,;
                     "bt_marrom.gif" ,/*Sem Status 8 */,"bt_preto.gif"  }
Local oObj, oSolCol

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

oSolCol := WSTMSPICKUPORDER():NEW()
WsChgUrl(@oSolCol,"TMSPICKUPORDER.APW")		

//-- Session com { Título do erro/informação,Descrição do erro/informação, Título do cabeçalho}
HttpSession->PWSTMS19INFO   := {Nil, Nil, Nil, Nil}
HttpSession->PWSTMS19INFO[1]:= STR0001 //"Solicitação de Coleta"
HttpSession->PWSTMS21SOLCOL := HttpPost->cNumSol

//-- Verifica se Status já foi criado
If !Empty(HttpGet->nPos)
	If !Empty(HttpSession->APWSTMS44STA)
		HttpSession->APWSTMS21STA:= aClone(HttpSession->APWSTMS24STA)
	Else
		HttpSession->APWSTMS21STA:={}
	EndIf
Else
   HttpSession->APWSTMS21STA:={}
EndIf
	
//-- Dados da Solicitação  
If !Empty(HttpSession->PWSTMS21SOLCOL)
		
	//-- Cab. Solicitação	
	HttpSession->APWSTMS21HEADER := {}
				
	If oObj:GETHEADER("SOLCOLCAB")
		For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
			
			aAdd( HttpSession->APWSTMS21HEADER,{oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTITLE,;
														   oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERFIELD,;
													 	   oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTYPE,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:nHEADERSIZE,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:nHEADERDEC,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:lHEADEROBLIG,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERPICTURE,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERCOMBOBOX,;
															oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERF3})
		Next nI
	EndIf  
		 
	//-- Dados Cabeçalho	
	HttpSession->APWSTMS21HEADERINFO := {}
	
	oSolCol:GETPICKUPORDER(GetUsrCode(),HttpSession->PWSTMS21SOLCOL)
			
	If !Empty(oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER)
	 	aAdd( HttpSession->APWSTMS21HEADERINFO,{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:dPODATE                          ,"DATSOLV"})
	  	aAdd( HttpSession->APWSTMS21HEADERINFO,{TRANSFORM(oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPOTIME,"@R 99:99")    ,"HORSOLV"})                   
		aAdd( HttpSession->APWSTMS21HEADERINFO,{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPODDD                           ,"DDDV"   })
		aAdd( HttpSession->APWSTMS21HEADERINFO,{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPOTEL                           ,"TELV"   })
		aAdd( HttpSession->APWSTMS21HEADERINFO,{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPOCODSOL                        ,"CODSOLV"  })
		aAdd( HttpSession->APWSTMS21HEADERINFO,{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPONAME                          ,"NOMEV"  })
		aAdd( HttpSession->APWSTMS21HEADERINFO,{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPOADRESS                        ,"DT5ENDV"})
		aAdd( HttpSession->APWSTMS21HEADERINFO,{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPODISTRICT                      ,"BAIRROV"})
	  	aAdd( HttpSession->APWSTMS21HEADERINFO,{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPOADRESSSEQ                     ,"SEQENDA"})
		aAdd( HttpSession->APWSTMS21HEADERINFO,{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPOCITY                          ,"MUNV"   })
		aAdd( HttpSession->APWSTMS21HEADERINFO,{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPOOBS                           ,"OBSA"   })
		aAdd( HttpSession->APWSTMS21HEADERINFO,{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPOSTATE                         ,"ESTV"   })
		aAdd( HttpSession->APWSTMS21HEADERINFO,{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPOTRANSTYPE                     ,"TIPTRAA"})
	   aAdd( HttpSession->APWSTMS21HEADERINFO,{TRANSFORM(oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPOZIP,"@R 99999-999") ,"CEPV"   })
		aAdd( HttpSession->APWSTMS21HEADERINFO,{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPOAREACODE                      ,"CDRORIV"})
				
		//-- Status
	  	If Empty(HttpSession->APWSTMS21STA)
	  		
	  		oObj:GETSX3BOX("DT5_STATUS")
	  		
	    	For nX:= 1 To Len(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX)
			  	If oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBVALUE01 == oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPOSTATUS
			  		aAdd(HttpSession->APWSTMS21STA,{aStaCorDT5[VAL(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBVALUE01)],; 
			  	    	                             Alltrim(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBDESCRIPTION)})
			   EndIf
			Next nX
			
			HttpGet->nPos:= "1"
			
	   EndIf
		//-- Configuração para Campos de Gatilho para Header   
		//-- Descrição de Região de Origem
		oObj:GETTRGINFO("REGORI",oSolCol:oWSGETPICKUPORDERRESULT:oWSPOHEADER:cPOAREACODE)
		aAdd(HttpSession->APWSTMS21HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"REGORIV"})
		  
		//-- Cab. Itens
		HttpSession->APWSTMS21HEADERITEM:= {}
			
		If oObj:GETHEADER("SOLCOLITE")
			For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
				aAdd( HttpSession->APWSTMS21HEADERITEM,{oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTITLE,;
																    oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERFIELD,;
											  					 	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTYPE,;
														  	 	 	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:nHEADERSIZE,;
																 	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:nHEADERDEC,;
																 	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:lHEADEROBLIG,;
																  	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERPICTURE,;
																  	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERCOMBOBOX,;
															 	 	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERF3})
				//-- Tratamento para pictures em visualização de cotação
				If oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERFIELD == "PESOA"   .Or. ;
				   oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERFIELD == "PESOM3A" .Or. ;
				   oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERFIELD == "VALMERA"
					aAdd( aPict,oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERPICTURE)
				EndIf
			Next nI                       	
		EndIf 
		
		//-- Dados Itens
		
		HttpSession->APWSTMS21ITEMINFO := {}
			
		For nJ:=1 To Len(oSolCol:oWSGETPICKUPORDERRESULT:oWSPOITEM:oWSPOITEMVIEW)
			aAdd( HttpSession->APWSTMS21ITEMINFO, {} )                 
			aAdd( HttpSession->APWSTMS21ITEMINFO[nJ],{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOITEM:oWSPOITEMVIEW[nJ]:cPOITEM    ,"ITEMV"+Alltrim(Str(nJ))  })
			aAdd( HttpSession->APWSTMS21ITEMINFO[nJ],{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOITEM:oWSPOITEMVIEW[nJ]:cPOPRODUCT ,"CODPROA"+Alltrim(Str(nJ))})
			aAdd( HttpSession->APWSTMS21ITEMINFO[nJ],{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOITEM:oWSPOITEMVIEW[nJ]:cPOPACKING ,"CODEMBA"+Alltrim(Str(nJ))})
			aAdd( HttpSession->APWSTMS21ITEMINFO[nJ],{oSolCol:oWSGETPICKUPORDERRESULT:oWSPOITEM:oWSPOITEMVIEW[nJ]:nPOVOLQTY  ,"QTDVOLA"+Alltrim(Str(nJ))})
		 	aAdd( HttpSession->APWSTMS21ITEMINFO[nJ],{TRANSFORM(oSolCol:oWSGETPICKUPORDERRESULT:oWSPOITEM:oWSPOITEMVIEW[nJ]:nPOWEIGHT,   aPict[1]),"PESOA"+Alltrim(Str(nJ))  })
		 	aAdd( HttpSession->APWSTMS21ITEMINFO[nJ],{TRANSFORM(oSolCol:oWSGETPICKUPORDERRESULT:oWSPOITEM:oWSPOITEMVIEW[nJ]:nPOWEIGHT3,  aPict[2]),"PESOM3A"+Alltrim(Str(nJ))})
			aAdd( HttpSession->APWSTMS21ITEMINFO[nJ],{TRANSFORM(oSolCol:oWSGETPICKUPORDERRESULT:oWSPOITEM:oWSPOITEMVIEW[nJ]:nPOVALGOODS, aPict[3]),"VALMERA"+Alltrim(Str(nJ))})
		
			//-- Configuração para Campos de Gatilho para Itens
		   //-- Descrição de Produto
		   oObj:GETTRGINFO("CODPRO",oSolCol:oWSGETPICKUPORDERRESULT:oWSPOITEM:oWSPOITEMVIEW[nJ]:cPOPRODUCT)
			aAdd(HttpSession->APWSTMS21ITEMINFO[nJ],{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESPROV"+Alltrim(Str(nJ))})
			
			//-- Descrição de Embalagem
			oObj:GETTRGINFO("CODEMB",oSolCol:oWSGETPICKUPORDERRESULT:oWSPOITEM:oWSPOITEMVIEW[nJ]:cPOPACKING)
			aAdd(HttpSession->APWSTMS21ITEMINFO[nJ],{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESEMBV"+Alltrim(Str(nJ))})
			
		Next nJ
		                             
		cHtml += ExecInPage( "PWSTMS21" )
		
	Else
	
		HttpSession->PWSTMS19INFO[2] := "<center>"+STR0002+"<br/>"+STR0003+"</center>" //"<center>Nenhuma Solicitação encontrada" ### "Verifique se o numero da solicitação esta correto"
  		HttpSession->PWSTMS19INFO[3] := STR0004 //"Erro"
  		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
  		cHtml := ExecInPage( "PWSTMS19"  ) 
		
	EndIf	  	
Else
	HttpSession->PWSTMS19INFO[2] := "<center>"+STR0002+"<br/>"+STR0003+"</center>" //"<center>Nenhuma Solicitação encontrada" ### "Verifique se o numero da solicitação esta correto"
	HttpSession->PWSTMS19INFO[3] := STR0004 //"Erro"
	HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
	cHtml := ExecInPage( "PWSTMS19"  )
EndIf
		
WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS22  ºAutor  ³Gustavo Almeida  º Data ³  01/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina Página de Inclusão                            º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS22()

Local cHtml   := ""
Local nI      := 0
Local nJ      := 0
Local nIteTot := 0
Local nCompl  := 0
Local cSeqUsr := ""
Local cNumStr := ""
Local nX  := 0
Local oObj, oSolCol

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

oSolCol := WSTMSPICKUPORDER():NEW()
WsChgUrl(@oSolCol,"TMSPICKUPORDER.APW")		

HttpSession->PWSTMS19INFO    := {Nil, Nil, Nil, Nil}
HttpSession->PWSTMS19INFO[1] := STR0001 //"Solicitação de Coleta"
HttpSession->PWSTMS22ALERT   := Nil
        
//-- Foco na página
If !Empty(HttpPost->cCAMPFOCO)
	HttpSession->CPWSTMS22FOCO:= HttpPost->cCAMPFOCO
Else
	HttpSession->CPWSTMS22FOCO:= "SEQENDA"
EndIf	

//-- Verifica se é permitido fazer uma solicitação de coleta com mais de um produto.
If oObj:GETPARAMETERVALUE("MV_PRDDIV")
	HttpSession->PWSTMS22MV_PRDDIV:= oObj:cGETPARAMETERVALUERESULT 
EndIf

If Empty(HttpGet->cACT) .OR. HttpGet->cACT="NIT" 

	If Empty(HttpSession->APWSTMS22HEADER)  
	
		HttpSession->APWSTMS22HEADER := {}
		
		If oObj:GETHEADER("SOLCOLCAB")
			For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
				aAdd( HttpSession->APWSTMS22HEADER,{oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTITLE,;
															   oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERFIELD,;
														 	   oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTYPE,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:nHEADERSIZE,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:nHEADERDEC,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:lHEADEROBLIG,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERPICTURE,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERCOMBOBOX,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERF3})
			Next nI
		EndIf  
	EndIf

	//-- Valores Pré-definidos e/ou Já digitados
	
	If Empty(HttpSession->APWSTMS22HEADERINFO) 
		
		HttpSession->APWSTMS22HEADERINFO := {}
		
		If oSolCol:GETREQUESTORVIEW(GetUsrCode())

		 	If Len(oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW) > 0	 	
			 	aAdd( HttpSession->APWSTMS22HEADERINFO,{DATE(),"DATSOLV"})
			  	aAdd( HttpSession->APWSTMS22HEADERINFO,{TRANSFORM(TIME(),"@R 99:99"),"HORSOLV"})                   
				aAdd( HttpSession->APWSTMS22HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cREDDD         ,"DDDV"   })
				aAdd( HttpSession->APWSTMS22HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cRETEL         ,"TELV"   })
				aAdd( HttpSession->APWSTMS22HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cRECODSOL        ,"CODSOLV"  })
				aAdd( HttpSession->APWSTMS22HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cRENAME        ,"NOMEV"  })
				aAdd( HttpSession->APWSTMS22HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cREAREACODE    ,"CDRORIV"})
			 	aAdd( HttpSession->APWSTMS22HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cREAREAREQ     ,"REGORIV"})
			 	aAdd( HttpSession->APWSTMS22HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cREADRESS      ,"DT5ENDV"})
				aAdd( HttpSession->APWSTMS22HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cREDISTRICT    ,"BAIRROV"})
				aAdd( HttpSession->APWSTMS22HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cRECITY        ,"MUNV"   })
				aAdd( HttpSession->APWSTMS22HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cRESTATE       ,"ESTV"   })
			   aAdd( HttpSession->APWSTMS22HEADERINFO,{TRANSFORM(oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cREZIP,"@R 99999-999") ,"CEPV"})
			Else
		  		HttpSession->PWSTMS19INFO[2] := STR0022+GetWSCError() //"Erro de Execução : "
				HttpSession->PWSTMS19INFO[3] := STR0004 //"Erro"
				HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
				cHtml := ExecInPage( "PWSTMS19" ) 
				
				Return cHtml
			EndIf
	   EndIf
   
	ElseIf HttpGet->cACT="NIT" 
		
		HttpSession->APWSTMS22HEADERINFO := {}
		
		aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->DATSOLV,"DATSOLV"})
	  	aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->HORSOLV,"HORSOLV"})                   
		aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->DDDV   ,"DDDV"   })
		aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->TELV   ,"TELV"   })
		aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->CODSOLV ,"CODSOLV"})
		aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->NOMEV  ,"NOMEV"  })
		aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->CDRORIV,"CDRORIV"})
	 	aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->REGORIV,"REGORIV"})
	 	If Empty(HttpPost->cGATILHOCAMP)
			aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->DT5ENDV,"DT5ENDV"})
			aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->MUNV   ,"MUNV"   })
			aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->ESTV   ,"ESTV"   })
			aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->CEPV   ,"CEPV"   })
			aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->BAIRROV,"BAIRROV"})
  			aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->SEQENDA,"SEQENDA"})
  		EndIf
		aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->TIPTRAA,"TIPTRAA"})
	 	aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->OBSA   ,"OBSA"   })
		 	
	   //-- Mais Campos para SEQ com Gatilho
	   If !Empty(HttpPost->cGATILHOCAMP)
					
			If HttpPost->cGATILHOCAMP = "SEQENDA"
			   
			   cSeqUsr := GetUsrCode()
			   cSeqUsr += ";"
			   
			   If !Empty(&("HttpPost->"+HttpPost->cGATILHOCAMP))
					cSeqUsr += &("HttpPost->"+HttpPost->cGATILHOCAMP)
				Else
				   cSeqUsr += "NIL"
				EndIf             
				
				oObj:GETTRGINFO(Substr(HttpPost->cGATILHOCAMP,1,Len(HttpPost->cGATILHOCAMP)-1),cSeqUsr)
				
				//-- Auto-Preenchimento para campos de Sequencia de Endereços
							  	
				If Empty(oObj:oWSGETTRGINFORESULT:cTRGVALUE01)
					HttpSession->PWSTMS22ALERT:= STR0019 //"Sequencia de endereço não encontrada"
					HttpSession->CPWSTMS22FOCO:= "SEQENDA"
					aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->DT5ENDV,"DT5ENDV"})
					aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->MUNV   ,"MUNV"   })
					aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->ESTV   ,"ESTV"   })
					aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->CEPV   ,"CEPV"   })
					aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->BAIRROV,"BAIRROV"})
		  			aAdd( HttpSession->APWSTMS22HEADERINFO,{"","SEQENDA"})
			  	Else
				  	aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->SEQENDA,"SEQENDA"})
			   	aAdd( HttpSession->APWSTMS22HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DT5ENDV"})
					aAdd( HttpSession->APWSTMS22HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE02,"MUNV"})
					aAdd( HttpSession->APWSTMS22HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE03,"ESTV"})
			  		aAdd( HttpSession->APWSTMS22HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE04,"CEPV"})
			  		aAdd( HttpSession->APWSTMS22HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE05,"BAIRROV"})
			  	EndIf

		   Else                                                                      
		      aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->SEQENDA,"SEQENDA"})
				aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->DT5ENDV,"DT5ENDV"})
				aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->MUNV,"MUNV"})
				aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->ESTV,"ESTV"})
		   	aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->CEPV,"CEPV"})
		   	aAdd( HttpSession->APWSTMS22HEADERINFO,{HttpPost->BAIRROV,"BAIRROV"})
			   	
		   EndIf	
		EndIf
	EndIf  
	
   If Empty(HttpSession->APWSTMS22HEADERITEM)
		
		HttpSession->APWSTMS22HEADERITEM:= {}
		
  		If oObj:GETHEADER("SOLCOLITE")
			For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
					aAdd( HttpSession->APWSTMS22HEADERITEM,{oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTITLE,;
																	    oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERFIELD,;
												  					 	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTYPE,;
															  	 	 	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:nHEADERSIZE,;
																	 	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:nHEADERDEC,;
																	 	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:lHEADEROBLIG,;
																	  	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERPICTURE,;
																	  	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERCOMBOBOX,;
																 	 	 oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERF3})
			Next nI                       	
		EndIf 
	EndIf
	                                     
	If HttpGet->cACT="NIT"
		If Empty(HttpSession->APWSTMS22ITEMINFO) .Or. !Empty(HttpGet->X) .Or. !Empty(HttpGet->R) 
			HttpSession->APWSTMS22ITEMINFO:= {} 
		EndIf
			
		nIteTot := Val(HttpGet->nNUMITENS)
		
		//-- Inclusão/Exclusão
		If Empty(HttpGet->R)
			For nI:=1 To nIteTot
				
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->CODEMBA"+Alltrim(STR(nI))),"CODEMBA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->CODPROA"+Alltrim(STR(nI))),"CODPROA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->PESOM3A"+Alltrim(STR(nI))),"PESOM3A"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->PESOA"  +Alltrim(STR(nI))),"PESOA"  +Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->QTDVOLA"+Alltrim(STR(nI))),"QTDVOLA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->VALMERA"+Alltrim(STR(nI))),"VALMERA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->DESPROV"+Alltrim(STR(nI))+"H"),"DESPROV"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->DESEMBV"+Alltrim(STR(nI))+"H"),"DESEMBV"+Alltrim(STR(nI))})
				
			Next nI
		EndIf	
		
		//-- Exclusão de Itens
		If !Empty(HttpGet->X)
		
			If Empty(HttpSession->EXCITENS) 
				HttpSession->EXCITENS := {}
			EndIf            
			
			aAdd(HttpSession->EXCITENS,HttpGet->X)
			
		EndIf
			
		//-- Recuperação de Itens
		If !Empty(HttpGet->R)
		
			For nI:=1 To nIteTot
			
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->CODEMBA"+Alltrim(STR(nI))+"H"),"CODEMBA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->CODPROA"+Alltrim(STR(nI))+"H"),"CODPROA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->PESOM3A"+Alltrim(STR(nI))+"H"),"PESOM3A"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->PESOA"  +Alltrim(STR(nI))+"H"),"PESOA"  +Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->QTDVOLA"+Alltrim(STR(nI))+"H"),"QTDVOLA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->VALMERA"+Alltrim(STR(nI))+"H"),"VALMERA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->DESPROV"+Alltrim(STR(nI))+"H"),"DESPROV"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->DESEMBV"+Alltrim(STR(nI))+"H"),"DESEMBV"+Alltrim(STR(nI))})
			Next nI
			
		 	aDel(HttpSession->EXCITENS, Val(HttpGet->R))
		 	
		EndIf 
			
		//-- Configuração de Gatilhos para Itens de Solicitação de coleta
		If !Empty(HttpPost->cGATILHOCAMP)
			
			If Substr(HttpPost->cGATILHOCAMP,1,Len(HttpPost->cGATILHOCAMP)-1) = "CODPROA" 
			
				//-- Auto-Preenchimento para campos de Descricao de Produto
				//-- Com o código do produto é pego a sua descrição
				
				HttpSession->APWSTMS22ITEMINFO:={}
				oObj:GETTRGINFO(Substr(HttpPost->cGATILHOCAMP,1,Len(HttpPost->cGATILHOCAMP)-2),(&("HttpPost->"+HttpPost->cGATILHOCAMP)))
				
				For nI:=1 To nIteTot
				
					aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->CODEMBA"+Alltrim(STR(nI))),"CODEMBA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->CODPROA"+Alltrim(STR(nI))),"CODPROA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->PESOM3A"+Alltrim(STR(nI))),"PESOM3A"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->PESOA"  +Alltrim(STR(nI))),"PESOA"  +Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->QTDVOLA"+Alltrim(STR(nI))),"QTDVOLA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->VALMERA"+Alltrim(STR(nI))),"VALMERA"+Alltrim(STR(nI))})
					
					If Val(Substr(HttpPost->cGATILHOCAMP,Len(HttpPost->cGATILHOCAMP),Len(HttpPost->cGATILHOCAMP))) == nI
						//-- Adicionando a informaçao
						If !Empty(oObj:oWSGETTRGINFORESULT:cTRGVALUE01)
							aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->CODPROA"+Alltrim(STR(nI))),"CODPROA"+Alltrim(STR(nI))})
					   	aAdd( HttpSession->APWSTMS22ITEMINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESPROV"+Alltrim(Str(nI))})
					   Else
					   	HttpSession->PWSTMS22ALERT:= STR0020 //"Produto não encontrado"
					   	HttpSession->CPWSTMS22FOCO:= "CODPROA"+Alltrim(STR(nI))
					   	aAdd( HttpSession->APWSTMS22ITEMINFO,{"","CODPROA"+Alltrim(STR(nI))}) 
					   	aAdd( HttpSession->APWSTMS22ITEMINFO,{"","DESPROV"+Alltrim(Str(nI))})	
					   EndIf
					Else
						aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->DESPROV"+Alltrim(STR(nI))),"DESPROV"+Alltrim(Str(nI))})
				   EndIf 
				   
				   aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->DESEMBV"+Alltrim(STR(nI))),"DESEMBV"+Alltrim(Str(nI))})
				   
				Next nI
				
			ElseIf Substr(HttpPost->cGATILHOCAMP,1,Len(HttpPost->cGATILHOCAMP)-1) = "CODEMBA"
			
				//-- Auto-Preenchimento para campos de Descricao de Embalagem
				//-- Com o código do produto é pego a sua descrição
				
				HttpSession->APWSTMS22ITEMINFO:={}
				oObj:GETTRGINFO(Substr(HttpPost->cGATILHOCAMP,1,Len(HttpPost->cGATILHOCAMP)-2),(&("HttpPost->"+HttpPost->cGATILHOCAMP)))
				
				For nI:=1 To nIteTot
			  		aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->CODEMBA"+Alltrim(STR(nI))),"CODEMBA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->CODPROA"+Alltrim(STR(nI))),"CODPROA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->PESOM3A"+Alltrim(STR(nI))),"PESOM3A"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->PESOA"  +Alltrim(STR(nI))),"PESOA"  +Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->QTDVOLA"+Alltrim(STR(nI))),"QTDVOLA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->VALMERA"+Alltrim(STR(nI))),"VALMERA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->DESPROV"+Alltrim(STR(nI))),"DESPROV"+Alltrim(Str(nI))})
					
					If Val(Substr(HttpPost->cGATILHOCAMP,Len(HttpPost->cGATILHOCAMP),Len(HttpPost->cGATILHOCAMP))) == nI
					   //-- Adicionando a informaçao
						If !Empty(oObj:oWSGETTRGINFORESULT:cTRGVALUE01)
							aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->CODEMBA"+Alltrim(STR(nI))),"CODEMBA"+Alltrim(STR(nI))})
						   aAdd( HttpSession->APWSTMS22ITEMINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESEMBV"+Alltrim(Str(nI))})
					   Else
					   	HttpSession->PWSTMS22ALERT:= STR0021 //"Embalagem não encontrada"
					   	HttpSession->CPWSTMS22FOCO:= "CODEMBA"+Alltrim(STR(nI))
					   	aAdd( HttpSession->APWSTMS22ITEMINFO,{"","CODEMBA"+Alltrim(STR(nI))})
						   aAdd( HttpSession->APWSTMS22ITEMINFO,{"","DESEMBV"+Alltrim(Str(nI))})	
					   EndIf
					Else
						aAdd( HttpSession->APWSTMS22ITEMINFO,{&("HttpPost->DESEMBV"+Alltrim(STR(nI))),"DESEMBV"+Alltrim(Str(nI))})
				   EndIf 
				   				   
				Next nI
			EndIf 
		EndIf	
	EndIf
	//-- Tratamento para "voltar" em caso de erro na página
	If Valtype(HttpSession->APWSTMSHEADERBCKS) == 'A'
		//-- Zera Sessions preenchidas anteriormente
		HttpSession->APWSTMS22HEADERINFO:= {}
		HttpSession->APWSTMS22ITEMINFO  := {}
		
		//-- Recurpera valores
		HttpSession->APWSTMS22HEADERINFO:= HttpSession->APWSTMSHEADERBCKS
		HttpSession->APWSTMS22ITEMINFO  := HttpSession->APWSTMSITEMBCKS
		
		HttpSession->APWSTMSHEADERBCKS := nil
		HttpSession->APWSTMSITEMBCKS   := nil
	EndIf
	
  	cHtml += ExecInPage( "PWSTMS22" )
  	
ElseIf HttpGet->cACT = "INS"       

	//-- Montagem do Objeto para Inclusão da solicitação 
	
   If HttpGet->nNUMITENS = ""
	   nIteTot:= 1
	Else
	   nIteTot:= Val(HttpGet->nNUMITENS)
	EndIf
   	
		oSolCol:oWSPICKUPORDER:oWSPOHEADER:= {} 		
		oSolCol:oWSPICKUPORDER:oWSPOHEADER:= TMSPICKUPORDER_POHEADERVIEW():New()
			
		oSolCol:oWSPICKUPORDER:oWSPOHEADER:dPODATE      := Ctod(HttpPost->DATSOLVPRE)
		oSolCol:oWSPICKUPORDER:oWSPOHEADER:cPOTIME      := StrTran(Padr(HttpPost->HORSOLVPRE,5),':','')
		oSolCol:oWSPICKUPORDER:oWSPOHEADER:cPODDD       := HttpPost->DDDVPRE
		oSolCol:oWSPICKUPORDER:oWSPOHEADER:cPOTEL       := HttpPost->TELVPRE
		oSolCol:oWSPICKUPORDER:oWSPOHEADER:cPOCODSOL    := HttpPost->CODSOLVPRE
		oSolCol:oWSPICKUPORDER:oWSPOHEADER:cPOAREACODE  := HttpPost->CDRORIVPRE
		oSolCol:oWSPICKUPORDER:oWSPOHEADER:cPOADRESSSEQ := HttpPost->SEQENDA
		oSolCol:oWSPICKUPORDER:oWSPOHEADER:cPOTRANSTYPE := HttpPost->TIPTRAA
		oSolCol:oWSPICKUPORDER:oWSPOHEADER:cPOOBS       := HttpPost->OBSA 
		  	
		For nI := 1 To nIteTot
  				
			If nI == 1
				nX++
			  	oSolCol:oWSPICKUPORDER:oWSPOITEM := TMSPICKUPORDER_ARRAYOFPOITEMVIEW():New()
			Else
				nX++
			EndIf
			
			If Ascan(HttpSession->EXCITENS, {|x| x == StrZero(nI,2) }) > 0
				nX--
       		Loop
   		Else
   			Aadd(oSolCol:oWSPICKUPORDER:oWSPOITEM:oWSPOITEMVIEW,TMSPICKUPORDER_POITEMVIEW():New())        
				oSolCol:oWSPICKUPORDER:oWSPOITEM:oWSPOITEMVIEW[nX]:CPOITEM    := StrZero(nX,2)
				oSolCol:oWSPICKUPORDER:oWSPOITEM:oWSPOITEMVIEW[nX]:CPOPRODUCT := &("HttpPost->CODPROA"+Alltrim(Str(nI)))
				oSolCol:oWSPICKUPORDER:oWSPOITEM:oWSPOITEMVIEW[nX]:CPOPACKING := TRANSFORM(&("HttpPost->CODEMBA"+Alltrim(Str(nI))),"@!")
				oSolCol:oWSPICKUPORDER:oWSPOITEM:oWSPOITEMVIEW[nX]:NPOVOLQTY  := Val(&("HttpPost->QTDVOLA"+Alltrim(Str(nI))))
	         
				//-- Tratamento para Peso
				cNumStr:= StrTran(&("HttpPost->PESOA"+Alltrim(Str(nI))),".","")
				cNumStr:= StrTran(cNumStr,",",".",Len(cNumStr))
				
				oSolCol:oWSPICKUPORDER:oWSPOITEM:oWSPOITEMVIEW[nX]:NPOWEIGHT  := Val(cNumStr)
				
				//-- Tratamento para Peso M3
				cNumStr:= ""
				cNumStr:= StrTran(&("HttpPost->PESOM3A"+Alltrim(Str(nI))),".","")
				cNumStr:= StrTran(cNumStr,",",".",Len(cNumStr)) 
	
				oSolCol:oWSPICKUPORDER:oWSPOITEM:oWSPOITEMVIEW[nX]:NPOWEIGHT3 := Val(cNumStr)
				
				//-- Tratamento para Valor Merc.
				cNumStr:= ""
				cNumStr:= StrTran(&("HttpPost->VALMERA"+Alltrim(Str(nI))),".","")
				cNumStr:= StrTran(cNumStr,",",".",Len(cNumStr))
				
				oSolCol:oWSPICKUPORDER:oWSPOITEM:oWSPOITEMVIEW[nX]:NPOVALGOODS:= Val(cNumStr)
				
			EndIf
			
  		Next nI 
  		
		//-- Inclusão de Objeto			
		If oSolCol:PUTPICKUPORDER(oSolCol:oWSPICKUPORDER)
			HttpSession->PWSTMS19INFO[2] := oSolCol:cPUTPICKUPORDERRESULT
			HttpSession->PWSTMS19INFO[3] := STR0006 //"Inclusão de Solicitação de Coleta"
			If "sucesso" $ oSolCol:cPUTPICKUPORDERRESULT
				HttpSession->PWSTMS19INFO[4] := ""
			Else
				HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar" 
			EndIf
			cHtml := ExecInPage( "PWSTMS19" ) 
		Else
	  		HttpSession->PWSTMS19INFO[2] := STR0007+GetWSCError() //"Erro de Execução : "
			HttpSession->PWSTMS19INFO[3] := STR0004 //"Erro"
			HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
			cHtml := ExecInPage( "PWSTMS19" ) 
		Endif
Else 
	cHtml:= STR0008 //"Vazio"
EndIf

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS23  ºAutor  ³Gustavo Almeida  º Data ³  21/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina Página de Paramentros para Listagem de        º±±
±±º             ³ Solicitações.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS23()

Local cHtml := ""
Local oObj


WEB EXTENDED INIT cHtml START "InSite"

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

cHtml += ExecInPage( "PWSTMS23" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS24  ºAutor  ³Gustavo Almeida  º Data ³  22/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina Página de Listagem de Solicitações.           º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS24()

Local cHtml      := ""
Local cDatFrom   := ""
Local cDatTo     := ""
Local dDatLim    := "" 
Local dDatPreFrom:= ""
Local aStaCorDT5 := {"bt_verde.gif"  ,"bt_vermelho.gif","bt_amarelo.gif",;
                     "bt_azul.gif"   ,"bt_laranja.gif" ,"bt_cinza.gif"  ,;
                     "bt_marrom.gif" ,/*Sem Status 8 */,"bt_preto.gif"  }
Local nI         := 0
Local nX         := 0
Local oObj, oSolCol

WEB EXTENDED INIT cHtml START "InSite"

//-- Session com { Título do erro/informação,Descrição do erro/informação, Título do cabeçalho, voltar/fechar}
HttpSession->PWSTMS19INFO    := {Nil, Nil, Nil, Nil}
HttpSession->PWSTMS19INFO[1] := STR0001 //"Solicitação de Coleta"
HttpSession->APWSTMS24HEADER := {}
HttpSession->APWSTMS24INFO   := {}
HttpSession->CPWSTMS24TOTAL  := "0"
HttpSession->APWSTMS24STA    := {}

//-- Tratamento de Datas
cDatTo  := Dtos(Ctod(HttpPost->dDatPoTo))
If !Empty(cDatTo)
	dDatLim := Ctod(HttpPost->dDatPoTo)-90
Else
	HttpSession->PWSTMS19INFO[2] := "<center>"+STR0009+"<br/>"+STR0010+"</center>" //"'Data de' e/ou 'Data ate' invalida " ### " Informe uma data válida"
	HttpSession->PWSTMS19INFO[3] := STR0004 //"Erro"
	HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
	cHtml := ExecInPage( "PWSTMS19" )
EndIf
	
If Empty(HttpPost->dDatPoFrom)
	cDatFrom:= Dtos(dDatLim)
Else
   //-- Verifica se o periodo é maior que 90 dias
	dDatPreFrom:= Ctod(HttpPost->dDatPoFrom)
	If dDatPreFrom >= dDatLim 
		cDatFrom:= Dtos(Ctod(HttpPost->dDatPoFrom))
	Else
		HttpSession->PWSTMS19INFO[2] := "<center>"+STR0011+"<br/>"+STR0012+"</center>" //"Periodo inválido " ### " Informe periodos com 3 meses de diferença"
		HttpSession->PWSTMS19INFO[3] := STR0004 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml := ExecInPage( "PWSTMS19" )		
	EndIf 
EndIf

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

oSolCol := WSTMSPICKUPORDER():NEW()
WsChgUrl(@oSolCol,"TMSPICKUPORDER.APW")
                                                          
If cHtml == ""

	If oObj:GETHEADER("PICKUPORDERBRW")
		For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
		
			aAdd( HttpSession->APWSTMS24HEADER,{oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTITLE})
		
		Next nI
	EndIf 

	oSolCol:BRWPICKUPORDER(GetUsrCode(),cDatFrom,cDatTo)
	
	If !Empty(oSolCol:oWSBRWPICKUPORDERRESULT:oWSPOBROWSERVIEW)
      
      //-- Status
  		oObj:GETSX3BOX("DT5_STATUS")
          
   	For nI:= 1 To Len(oSolCol:oWSBRWPICKUPORDERRESULT:oWSPOBROWSERVIEW)

    		//-- Status
		   For nX:= 1 To Len(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX)
		   	If oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBVALUE01 == oSolCol:oWSBRWPICKUPORDERRESULT:oWSPOBROWSERVIEW[nI]:cPOBRWSTATUS
		   		aAdd(HttpSession->APWSTMS24STA,{aStaCorDT5[VAL(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBVALUE01)],; 
		   	    	                             Alltrim(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBDESCRIPTION)})
		      EndIf
		   Next nX
		    
	  		aAdd( HttpSession->APWSTMS24INFO,{oSolCol:oWSBRWPICKUPORDERRESULT:oWSPOBROWSERVIEW[nI]:cPOBRWPONUMB,;
									           Dtoc(oSolCol:oWSBRWPICKUPORDERRESULT:oWSPOBROWSERVIEW[nI]:dPOBRWDATE),;
									      TRANSFORM(oSolCol:oWSBRWPICKUPORDERRESULT:oWSPOBROWSERVIEW[nI]:cPOBRWTIME,"@R 99:99")})   
   	Next nI
	
		HttpSession->CPWSTMS24TOTAL := Str(Len(oSolCol:oWSBRWPICKUPORDERRESULT:oWSPOBROWSERVIEW))
	
		cHtml += ExecInPage( "PWSTMS24" )
	
	Else
		HttpSession->PWSTMS19INFO[2] := "<center>"+STR0013+"<br/>"+STR0014+"</center>" //"Nenhuma Solicitação encontrada no periodo informado " ### " Verifique o periodo"
		HttpSession->PWSTMS19INFO[3] := STR0004 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml := ExecInPage( "PWSTMS19" )
	EndIf
EndIf

WEB EXTENDED END

Return cHtml