#INCLUDE "PWSTMS40.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS4X  ºAutor  ³Gustavo Almeida  º Data ³  08/03/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com layout de Cotação de Frete.               º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºWEBFUNC.     ³ DESCRIÇÃO                                               º±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPWSTMS40     ³ Página inicial.                                         º±±
±±ºPWSTMS41     ³ Visualização de Cotação de Frete.                       º±±
±±ºPWSTMS42     ³ Inclusão de Cotação de Frete.                           º±±
±±ºPWSTMS43     ³ Param. de Listagem de Cotação de Frete.                 º±±
±±ºPWSTMS44     ³ Listagem de Cotação de Frete.                           º±±        
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS40  ºAutor  ³Gustavo Almeida  º Data ³  08/03/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina Página Inicial de Cotação de Frete.           º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS40()

Local cHtml := ""
Local oObj


WEB EXTENDED INIT cHtml START "InSite"

//-- Liberação de Sessões
HttpSession->APWSTMS42HEADERINFO := Nil
HttpSession->APWSTMS42ITEMINFO   := Nil
HttpSession->EXCITENS            := Nil

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

cHtml += ExecInPage( "PWSTMS40" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS41  ºAutor  ³Gustavo Almeida  º Data ³  08/03/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ Visualização de Cotação de Frete.                       º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS41()

Local cHtml    := ""
Local nI       := 0
Local nJ       := 0
Local nX       := 0
Local aPict    := {}
Local aStaCorDT4 := {"bt_amarelo.gif" ,"bt_vermelho.gif","bt_verde.gif"   ,;
                     "bt_azul.gif"    ,/*Sem Status 5 */,/*Sem Status 6 */,;
                     /*Sem Status 7 */,/*Sem Status 8 */,"bt_preto.gif"  }
Local oObj, oCotFre, oSolCol

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

oSolCol := WSTMSPICKUPORDER():NEW()
WsChgUrl(@oSolCol,"TMSPICKUPORDER.APW")

oCotFre := WSTMSFREIGHTQUOTATION():NEW()
WsChgUrl(@oCotFre,"TMSFREIGHTQUOTATION.APW")		

//-- Session com { Título do erro/informação,Descrição do erro/informação, Título do cabeçalho}
HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil}
HttpSession->PWSTMS19INFO[1] := "Cotação de Frete"
HttpSession->PWSTMS41COTFRE := HttpPost->cNumCot

//-- Verifica se Status já foi criado
If !Empty(HttpGet->nPos)
	If !Empty(HttpSession->APWSTMS44STA)
		HttpSession->APWSTMS41STA:= aClone(HttpSession->APWSTMS44STA)
	Else
		HttpSession->APWSTMS41STA:={}
	EndIf
Else
   HttpSession->APWSTMS41STA:={}
EndIf
	
//-- Dados da Cotação  
If !Empty(HttpSession->PWSTMS41COTFRE)
	
	//-- Cab. Cotação	
	HttpSession->APWSTMS41HEADER := {}
				
	If oObj:GETHEADER("COTFRECAB")
		For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
			
			aAdd( HttpSession->APWSTMS41HEADER,{oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTITLE,;
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
	HttpSession->APWSTMS41HEADERINFO := {}
	
	oCotFre:GETFREIGHTQUOTATION(GetUsrCode(),HttpSession->PWSTMS41COTFRE)
				
	If !Empty(oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER) 
								
	 	aAdd( HttpSession->APWSTMS41HEADERINFO,{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:dFQDATE                      ,"DATCOTV"})
	  	aAdd( HttpSession->APWSTMS41HEADERINFO,{TRANSFORM(oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQTIME,"@R 99:99"),"HORCOTV"})                   
		aAdd( HttpSession->APWSTMS41HEADERINFO,{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQDDD                       ,"DDDV"   })
		aAdd( HttpSession->APWSTMS41HEADERINFO,{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQTEL                       ,"TELV"   })  
		aAdd( HttpSession->APWSTMS41HEADERINFO,{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQCODSOL                    ,"CODSOLV"}) 
		aAdd( HttpSession->APWSTMS41HEADERINFO,{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQSRCEREGCOD                ,"CDRORIA"})
		aAdd( HttpSession->APWSTMS41HEADERINFO,{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQTRGTREGCOD                ,"CDRDESA"})
		aAdd( HttpSession->APWSTMS41HEADERINFO,{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQTRANSTYPE                 ,"TIPTRAA"})
		aAdd( HttpSession->APWSTMS41HEADERINFO,{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQTRANSSERV                 ,"SERTMSA"})
		If oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQFREIGHTTYP == "1"
			aAdd( HttpSession->APWSTMS41HEADERINFO,{"CIF","TIPFREA"})
		ElseIf oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQFREIGHTTYP == "2"
			aAdd( HttpSession->APWSTMS41HEADERINFO,{"FOB","TIPFREA"})
		EndIf
		aAdd( HttpSession->APWSTMS41HEADERINFO,{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:dFQVALIDTERM                 ,"PRZVALV"})
		aAdd( HttpSession->APWSTMS41HEADERINFO,{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQOBS                       ,"OBSA"})
	  
		//-- Status
		If Empty(HttpSession->APWSTMS41STA)
		 		
			oObj:GETSX3BOX("DT5_STATUS")
				
		  	For nX:= 1 To Len(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX)
			  	If oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBVALUE01 == oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQSTATUS
			  		aAdd(HttpSession->APWSTMS41STA,{aStaCorDT4[VAL(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBVALUE01)],; 
			  	    	                             Alltrim(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBDESCRIPTION)})
			   EndIf
			Next nX
				
			HttpGet->nPos:= "1"
				
	   EndIf 
						
		//-- Configuração para Campos de Gatilho para Header   
		//-- Descrição de Região de Origem
		
		oObj:GETTRGINFO("REGORI",oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQSRCEREGCOD, Nil )
		aAdd(HttpSession->APWSTMS41HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"REGORIV"}) 
		
		//-- Descrição de Região de Destino
		oObj:GETTRGINFO("REGORI",oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQTRGTREGCOD, Nil )
		aAdd(HttpSession->APWSTMS41HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"REGDESV"})
		
		//-- Descrição de Solicitante
		If oSolCol:GETREQUESTORVIEW(GetUsrCode())   
	   		aAdd( HttpSession->APWSTMS41HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cRECODSOL,"CODSOLV"})
			aAdd( HttpSession->APWSTMS41HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cRENAME,"NOMSOLV"})
		EndIf
		
		//-- Descrição de Serviço de Transporte
		oObj:GETTRGINFO("SERTMS",oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQTRANSSERV, Nil )
		aAdd(HttpSession->APWSTMS41HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESSVTV"})
		
		//-- Descrição de Tipo de Transporte
		oObj:GETTRGINFO("TIPTRA",oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQHEADER:cFQTRANSTYPE, Nil )
		aAdd(HttpSession->APWSTMS41HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESTPTV"})
		
		//-- Cab. Itens
		HttpSession->APWSTMS41HEADERITEM:= {}
				
		If oObj:GETHEADER("COTFREITE")
			For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
				aAdd( HttpSession->APWSTMS41HEADERITEM,{oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTITLE,;
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
		HttpSession->APWSTMS41ITEMINFO := {}
		For nJ:=1 To Len(oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQITEM:oWSFQITEMVIEW)                  
		   aAdd( HttpSession->APWSTMS41ITEMINFO, {} )
			aAdd( HttpSession->APWSTMS41ITEMINFO[nJ],{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQITEM:oWSFQITEMVIEW[nJ]:cFQITEM    ,"ITEMV"+Alltrim(Str(nJ))  })
			aAdd( HttpSession->APWSTMS41ITEMINFO[nJ],{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQITEM:oWSFQITEMVIEW[nJ]:cFQPRODUCT ,"CODPROA"+Alltrim(Str(nJ))})
			aAdd( HttpSession->APWSTMS41ITEMINFO[nJ],{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQITEM:oWSFQITEMVIEW[nJ]:cFQPACKING ,"CODEMBA"+Alltrim(Str(nJ))})
			aAdd( HttpSession->APWSTMS41ITEMINFO[nJ],{oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQITEM:oWSFQITEMVIEW[nJ]:nFQVOLQTY  ,"QTDVOLA"+Alltrim(Str(nJ))})
		 	aAdd( HttpSession->APWSTMS41ITEMINFO[nJ],{TRANSFORM(oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQITEM:oWSFQITEMVIEW[nJ]:nFQWEIGHT,   aPict[1]),"PESOA"+Alltrim(Str(nJ))  })
		 	aAdd( HttpSession->APWSTMS41ITEMINFO[nJ],{TRANSFORM(oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQITEM:oWSFQITEMVIEW[nJ]:nFQWEIGHT3,  aPict[2]),"PESOM3A"+Alltrim(Str(nJ))})
			aAdd( HttpSession->APWSTMS41ITEMINFO[nJ],{TRANSFORM(oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQITEM:oWSFQITEMVIEW[nJ]:nFQVALGOODS, aPict[3]),"VALMERA"+Alltrim(Str(nJ))})

			//-- Configuração para Campos de Gatilho para Itens
		   //-- Descrição de Produto
		   oObj:GETTRGINFO("CODPRO",oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQITEM:oWSFQITEMVIEW[nJ]:cFQPRODUCT, Nil )
			aAdd(HttpSession->APWSTMS41ITEMINFO[nJ],{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESPROV"+Alltrim(Str(nJ))})
				
			//-- Descrição de Embalagem
			oObj:GETTRGINFO("CODEMB",oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQITEM:oWSFQITEMVIEW[nJ]:cFQPACKING, Nil )
			aAdd(HttpSession->APWSTMS41ITEMINFO[nJ],{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESEMBV"+Alltrim(Str(nJ))})
				
		Next nJ
				
		//-- Total de Frete
		HttpSession->cFrete  := TRANSFORM(oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQCALC:nFQCALFREIGHT   ,"@E 999,999,999.99")
		HttpSession->cImposto:= TRANSFORM(oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQCALC:nFQCALTAX       ,"@E 999,999,999.99")
		HttpSession->cFreImp := TRANSFORM(oCotFre:oWSGETFREIGHTQUOTATIONRESULT:oWSFQCALC:nFQCALFREIGHTTAX,"@E 999,999,999.99")                            
		
		cHtml += ExecInPage( "PWSTMS41" )
		
	Else
		
		HttpSession->PWSTMS19INFO[2] := "<center>"+STR0001+"<br/>"+STR0002+"</center>" //"Nenhuma Cotação encontrada" ### "Verifique se o numero da cotação esta correto"
		HttpSession->PWSTMS19INFO[3] := STR0003 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0004 //"voltar"
		cHtml := ExecInPage( "PWSTMS19"  ) 
			
	EndIf	  	
Else
	HttpSession->PWSTMS19INFO[2] := "<center>"+STR0001+"<br/>"+STR0002+"</center>" //"Nenhuma Cotação encontrada" ### "Verifique se o numero da cotação esta correto"
	HttpSession->PWSTMS19INFO[3] := STR0003 //"Erro"
	HttpSession->PWSTMS19INFO[4] := STR0004 //"voltar"
	cHtml := ExecInPage( "PWSTMS19"  )
EndIf	  	

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS42  ºAutor  ³Gustavo Almeida  º Data ³  08/03/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina Página de inclusão para Cotação de Frete.     º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS42()

Local cHtml     := ""
Local nI        := 0
Local nJ        := 0
Local nX        := 0
Local nIteTot   := 0
Local nCompl    := 0
Local aItensTot := {}
Local bItem     := {|| }
Local	nPosItem  := 0
Local lConfirm  := .F.
Local cNumStr   := ""
Local oObj, oCotFre, oSolCol

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

oSolCol := WSTMSPICKUPORDER():NEW()
WsChgUrl(@oSolCol,"TMSPICKUPORDER.APW")		

oCotFre := WSTMSFREIGHTQUOTATION():NEW()
WsChgUrl(@oCotFre,"TMSFREIGHTQUOTATION.APW")

HttpSession->PWSTMS19INFO    := {Nil, Nil, Nil, Nil}
HttpSession->PWSTMS19INFO[1] := STR0005 //"Cotação de Frete"
HttpSession->CPWSTMS42FOCO   := ""
                                               
//-- Foco na página
If !Empty(HttpPost->cCAMPFOCO)
	If HttpPost->cGATILHOCAMP == "CDRORIA" 
		HttpSession->CPWSTMS42FOCO:= HttpPost->cCAMPFOCO
	ElseIf Empty(&("HttpPost->"+HttpPost->cGATILHOCAMP))
		HttpSession->CPWSTMS42FOCO:= ""
	Else
		HttpSession->CPWSTMS42FOCO:= HttpPost->cCAMPFOCO
	EndIf
Else
	HttpSession->CPWSTMS42FOCO:= "CDRORIA" 
EndIf

//-- Verifica se é permitido fazer uma cotação de frete com mais de um produto.
If oObj:GETPARAMETERVALUE("MV_PRDDIV")
	HttpSession->PWSTMS42MV_PRDDIV:= oObj:cGETPARAMETERVALUERESULT 
EndIf

If Empty(HttpGet->cACT) .OR. HttpGet->cACT="NIT"
 
	//-- Inicializa as variaveis de cal. de frete   
	HttpSession->cFrete  := TRANSFORM(0,"@E 999,999.99")
	HttpSession->cImposto:= TRANSFORM(0,"@E 999,999.99")
	HttpSession->cFreImp := TRANSFORM(0,"@E 999,999.99")

	If Empty(HttpSession->APWSTMS42HEADER)  
	
		HttpSession->APWSTMS42HEADER := {}
		
		If oObj:GETHEADER("COTFRECAB")
			For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
				aAdd( HttpSession->APWSTMS42HEADER,{oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTITLE,;
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
	
	If Empty(HttpSession->APWSTMS42HEADERINFO) 
		
		HttpSession->APWSTMS42HEADERINFO := {}
		
		If oSolCol:GETREQUESTORVIEW(GetUsrCode())
		 	If Len(oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW) > 0	
			 	aAdd( HttpSession->APWSTMS42HEADERINFO,{DATE(),"DATCOTV"})
			  	aAdd( HttpSession->APWSTMS42HEADERINFO,{TRANSFORM(TIME(),"@R 99:99"),"HORCOTV"})                   
				aAdd( HttpSession->APWSTMS42HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cREDDD     ,"DDDV"   })
				aAdd( HttpSession->APWSTMS42HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cRETEL     ,"TELV"   })  
				aAdd( HttpSession->APWSTMS42HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cRECODSOL  ,"CODSOLV"})
				aAdd( HttpSession->APWSTMS42HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cRENAME    ,"NOMSOLV"})
				aAdd( HttpSession->APWSTMS42HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cREAREACODE,"CDRORIA"})
			 	aAdd( HttpSession->APWSTMS42HEADERINFO,{oSolCol:oWSGETREQUESTORVIEWRESULT:oWSREQUESTORVIEW[1]:cREAREAREQ ,"REGORIV"})
			 	
			 	//-- Verifica Prazo de Validade pelo parametro MV_VLDCOT
				If oObj:GETPARAMETERVALUE("MV_VLDCOT")
	       		aAdd( HttpSession->APWSTMS42HEADERINFO,{DATE()+Val(oObj:cGETPARAMETERVALUERESULT),"PRZVALV"   })
	    		EndIf
	    	Else
		  		HttpSession->PWSTMS19INFO[2] := STR0027+GetWSCError() //"Erro de Execução : "
				HttpSession->PWSTMS19INFO[3] := STR0003 //"Erro"
				HttpSession->PWSTMS19INFO[4] := STR0004 //"voltar"
				cHtml := ExecInPage( "PWSTMS19" ) 
				
				Return cHtml
			EndIf    		
	   EndIf
      
	ElseIf HttpGet->cACT="NIT"
		
		HttpSession->APWSTMS42HEADERINFO := {}
      
	  	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->DATCOTVPRE,"DATCOTV"   })
	  	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->HORCOTVPRE,"HORCOTV"   })                     
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->DDDVPRE   ,"DDDV"      })
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->TELVPRE   ,"TELV"      }) 
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->CODSOLVPRE,"CODSOLV"   })
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->NOMSOLVPRE,"NOMSOLV"   })
	 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->REGORIVPRE,"REGORIV"   })
	 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->REGORIVPRE,"REGDESV"   })
	 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->DESSVTVPRE,"DESSVTV"   })
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->DESTPTVPRE,"DESTPTV"   })
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->PRZVALVPRE,"PRZVALV"   })
		
	  	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->DATCOTVPRE,"DATCOTVPRE"})
	  	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->HORCOTVPRE,"HORCOTVPRE"})                   
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->DDDVPRE   ,"DDDVPRE"   })
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->TELVPRE   ,"TELVPRE"   }) 
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->CODSOLVPRE,"CODSOLVPRE"})
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->NOMSOLVPRE,"NOMSOLVPRE"})
	 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->REGORIVPRE,"REGORIVPRE"})
	 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->REGDESVPRE,"REGDESVPRE"})
	 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->DESSVTVPRE,"DESSVTVPRE"})
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->DESTPTVPRE,"DESTPTVPRE"})
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->PRZVALVPRE,"PRZVALVPRE"})
	 	                                                                      
	 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->CDRORIA   ,"CDRORIA"   })
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->CDRDESA   ,"CDRDESA"   })
	 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->SERTMSA   ,"SERTMSA"   })
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->TIPTRAA   ,"TIPTRAA"   })  
		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->TIPFREA   ,"TIPFREA"})
	 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->OBSA      ,"OBSA"   })
	
		//-- Gatilho
	   If !Empty(HttpPost->cGATILHOCAMP)
	   	//-- Região de Origem
			If HttpPost->cGATILHOCAMP = "CDRORIA"
				oObj:GETTRGINFO(Substr(HttpPost->cGATILHOCAMP,1,Len(HttpPost->cGATILHOCAMP)-1),(&("HttpPost->"+HttpPost->cGATILHOCAMP)), Nil )
				If Empty(oObj:oWSGETTRGINFORESULT:cTRGVALUE01)
					HttpSession->PWSTMS42ALERT:= STR0021 //"Região de origem não encontrada"
					HttpSession->CPWSTMS42FOCO:= "CDRORIA"
					aAdd( HttpSession->APWSTMS42HEADERINFO,{"","CDRORIA"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{"","REGORIV"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{"","REGORIVPRE"})
				Else
					aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->CDRORIA   ,"CDRORIA"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"REGORIV"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"REGORIVPRE"})
				EndIf
			//-- Região de Destino
			ElseIf HttpPost->cGATILHOCAMP = "CDRDESA"
				oObj:GETTRGINFO(Substr(HttpPost->cGATILHOCAMP,1,Len(HttpPost->cGATILHOCAMP)-1),(&("HttpPost->"+HttpPost->cGATILHOCAMP)), Nil )
				If Empty(oObj:oWSGETTRGINFORESULT:cTRGVALUE01)
					HttpSession->PWSTMS42ALERT:= STR0022 //"Região de destino não encontrada"
					HttpSession->CPWSTMS42FOCO:= "CDRDESA"
					aAdd( HttpSession->APWSTMS42HEADERINFO,{"","CDRDESA"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{"","REGDESV"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{"","REGDESVPRE"})
				Else
					aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->CDRDESA   ,"CDRDESA"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"REGDESV"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"REGDESVPRE"})
				EndIf
			//-- Tipo de Transporte	
			ElseIf HttpPost->cGATILHOCAMP = "TIPTRAA"
				oObj:GETTRGINFO(Substr(HttpPost->cGATILHOCAMP,1,Len(HttpPost->cGATILHOCAMP)-1),(&("HttpPost->"+HttpPost->cGATILHOCAMP)), Nil )
				If Empty(oObj:oWSGETTRGINFORESULT:cTRGVALUE01)
					HttpSession->PWSTMS42ALERT:= STR0023 //"Tipo de Transporte não encontrado"
					HttpSession->CPWSTMS42FOCO:= "TIPTRAA"
					aAdd( HttpSession->APWSTMS42HEADERINFO,{"","TIPTRAA"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{"","DESTPTV"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{"","DESTPTVPRE"})
				Else
					aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->TIPTRAA   ,"TIPTRAA"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESTPTV"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESTPTVPRE"})
				EndIf
		   ElseIf HttpPost->cGATILHOCAMP = "SERTMSA" 
		   //-- Serviço de Transporte                                                                      
				oObj:GETTRGINFO(Substr(HttpPost->cGATILHOCAMP,1,Len(HttpPost->cGATILHOCAMP)-1),(&("HttpPost->"+HttpPost->cGATILHOCAMP)), Nil )
				If Empty(oObj:oWSGETTRGINFORESULT:cTRGVALUE01)
					HttpSession->PWSTMS42ALERT:= STR0024 //"Serviço de Transporte não encontrado"
					HttpSession->CPWSTMS42FOCO:= "SERTMSA"
					aAdd( HttpSession->APWSTMS42HEADERINFO,{"","SERTMSA"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{"","DESTPTV"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{"","DESTPTVPRE"})
				Else
					aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->SERTMSA   ,"SERTMSA"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESSVTV"})
					aAdd( HttpSession->APWSTMS42HEADERINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESSVTVPRE"})
				EndIf  	
		   EndIf
		Else
			aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->CDRORIA   ,"CDRORIA"   })
			aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->REGORIVPRE,"REGORIV"   })
		 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->REGORIVPRE,"REGORIVPRE"})
		 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->CDRDESA   ,"CDRDESA"   })
		 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->REGDESVPRE,"REGDESV"   })
	 		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->REGDESVPRE,"REGDESVPRE"})
	 		aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->SERTMSA   ,"SERTMSA"   })
		 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->DESSVTVPRE,"DESSVTV"   })
		 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->DESSVTVPRE,"DESSVTVPRE"})
		 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->TIPTRAA   ,"TIPTRAA"   })
		 	aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->DESTPTVPRE,"DESTPTV"   })
			aAdd( HttpSession->APWSTMS42HEADERINFO,{HttpPost->DESTPTVPRE,"DESTPTVPRE"})	
		EndIf
	 	
	EndIf  
	
   If Empty(HttpSession->APWSTMS42HEADERITEM)
		
		HttpSession->APWSTMS42HEADERITEM:= {}
		
  		If oObj:GETHEADER("COTFREITE")
			For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
					aAdd( HttpSession->APWSTMS42HEADERITEM,{oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTITLE,;
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
		If Empty(HttpSession->APWSTMS42ITEMINFO) .Or. !Empty(HttpGet->X) .Or. !Empty(HttpGet->R) 
			HttpSession->APWSTMS42ITEMINFO:= {} 
		EndIf
			
		nIteTot := Val(HttpGet->nNUMITENS)
		
		//-- Inclusão/Exclusão
		If Empty(HttpGet->R)
			For nI:=1 To nIteTot
				
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->CODEMBA"+Alltrim(STR(nI))),"CODEMBA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->CODPROA"+Alltrim(STR(nI))),"CODPROA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->PESOM3A"+Alltrim(STR(nI))),"PESOM3A"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->PESOA"  +Alltrim(STR(nI))),"PESOA"  +Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->QTDVOLA"+Alltrim(STR(nI))),"QTDVOLA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->VALMERA"+Alltrim(STR(nI))),"VALMERA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->DESPROV"+Alltrim(STR(nI))+"H"),"DESPROV"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->DESEMBV"+Alltrim(STR(nI))+"H"),"DESEMBV"+Alltrim(STR(nI))})
				
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
			
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->CODEMBA"+Alltrim(STR(nI))+"H"),"CODEMBA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->CODPROA"+Alltrim(STR(nI))+"H"),"CODPROA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->PESOM3A"+Alltrim(STR(nI))+"H"),"PESOM3A"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->PESOA"  +Alltrim(STR(nI))+"H"),"PESOA"  +Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->QTDVOLA"+Alltrim(STR(nI))+"H"),"QTDVOLA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->VALMERA"+Alltrim(STR(nI))+"H"),"VALMERA"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->DESPROV"+Alltrim(STR(nI))+"H"),"DESPROV"+Alltrim(STR(nI))})
				aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->DESEMBV"+Alltrim(STR(nI))+"H"),"DESEMBV"+Alltrim(STR(nI))})
				
			Next nI
			
		 	aDel(HttpSession->EXCITENS, Val(HttpGet->R))
		 	
		EndIf
		
		//-- Configuração de Gatilhos para Itens de Cotação de Frete
		If !Empty(HttpPost->cGATILHOCAMP)
			
			If Substr(HttpPost->cGATILHOCAMP,1,Len(HttpPost->cGATILHOCAMP)-1) = "CODPROA"
			   
				//-- Descricao de Produto
				HttpSession->APWSTMS42ITEMINFO:={}
				
				oObj:GETTRGINFO(Substr(HttpPost->cGATILHOCAMP,1,Len(HttpPost->cGATILHOCAMP)-2),(&("HttpPost->"+HttpPost->cGATILHOCAMP)), Nil )
				
				For nI:=1 To nIteTot
				   
					aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->CODEMBA"+Alltrim(STR(nI))),"CODEMBA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->CODPROA"+Alltrim(STR(nI))),"CODPROA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->PESOM3A"+Alltrim(STR(nI))),"PESOM3A"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->PESOA"  +Alltrim(STR(nI))),"PESOA"  +Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->QTDVOLA"+Alltrim(STR(nI))),"QTDVOLA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->VALMERA"+Alltrim(STR(nI))),"VALMERA"+Alltrim(STR(nI))})
					
					If Val(Substr(HttpPost->cGATILHOCAMP,Len(HttpPost->cGATILHOCAMP),Len(HttpPost->cGATILHOCAMP))) == nI
						//-- Adicionando a informaçao
						If !Empty(oObj:oWSGETTRGINFORESULT:cTRGVALUE01)
							aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->CODPROA"+Alltrim(STR(nI))),"CODPROA"+Alltrim(STR(nI))})
					   	aAdd( HttpSession->APWSTMS42ITEMINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESPROV"+Alltrim(Str(nI))})
					   Else
					   	HttpSession->PWSTMS42ALERT:= STR0025 //"Produto não encontrado"
					   	HttpSession->CPWSTMS42FOCO:= "CODPROA"+Alltrim(STR(nI))
					   	aAdd( HttpSession->APWSTMS42ITEMINFO,{"","CODPROA"+Alltrim(STR(nI))}) 
					   	aAdd( HttpSession->APWSTMS42ITEMINFO,{"","DESPROV"+Alltrim(Str(nI))})	
					   EndIf
					Else
						aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->DESPROV"+Alltrim(STR(nI))+"H"),"DESPROV"+Alltrim(Str(nI))})
				   EndIf 
				   
				   aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->DESEMBV"+Alltrim(STR(nI))+"H"),"DESEMBV"+Alltrim(Str(nI))})
				   
				Next nI
				
			ElseIf Substr(HttpPost->cGATILHOCAMP,1,Len(HttpPost->cGATILHOCAMP)-1) = "CODEMBA"
			
				//-- Descricao de Embalagem
				
				HttpSession->APWSTMS42ITEMINFO:={}
				oObj:GETTRGINFO(Substr(HttpPost->cGATILHOCAMP,1,Len(HttpPost->cGATILHOCAMP)-2),(&("HttpPost->"+HttpPost->cGATILHOCAMP)), Nil )
				
				For nI:=1 To nIteTot
				   
					aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->CODEMBA"+Alltrim(STR(nI))),"CODEMBA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->CODPROA"+Alltrim(STR(nI))),"CODPROA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->PESOM3A"+Alltrim(STR(nI))),"PESOM3A"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->PESOA"  +Alltrim(STR(nI))),"PESOA"  +Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->QTDVOLA"+Alltrim(STR(nI))),"QTDVOLA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->VALMERA"+Alltrim(STR(nI))),"VALMERA"+Alltrim(STR(nI))})
					aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->DESPROV"+Alltrim(STR(nI))+"H"),"DESPROV"+Alltrim(Str(nI))})
					 
					If Val(Substr(HttpPost->cGATILHOCAMP,Len(HttpPost->cGATILHOCAMP),Len(HttpPost->cGATILHOCAMP))) == nI
						//-- Adicionando a informaçao
						If !Empty(oObj:oWSGETTRGINFORESULT:cTRGVALUE01)
							aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->CODEMBA"+Alltrim(STR(nI))),"CODEMBA"+Alltrim(STR(nI))})
						   aAdd( HttpSession->APWSTMS42ITEMINFO,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"DESEMBV"+Alltrim(Str(nI))})
					   Else
					   	HttpSession->PWSTMS42ALERT:= STR0026 //"Embalagem não encontrada"
					   	HttpSession->CPWSTMS42FOCO:= "CODEMBA"+Alltrim(STR(nI))
					   	aAdd( HttpSession->APWSTMS42ITEMINFO,{"","CODEMBA"+Alltrim(STR(nI))})
						   aAdd( HttpSession->APWSTMS42ITEMINFO,{"","DESEMBV"+Alltrim(Str(nI))})	
					   EndIf
					Else
						aAdd( HttpSession->APWSTMS42ITEMINFO,{&("HttpPost->DESEMBV"+Alltrim(STR(nI))+"H"),"DESEMBV"+Alltrim(Str(nI))})
				   EndIf 
				   				   
				Next nI          
			EndIf 
		EndIf	
			
		//-- Calcular Frete	
		If HttpGet->lCalc == "T" 
			nX:= 0
		   //-- Obj. Header Cotação
		   oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:= {}
			oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:= TMSFREIGHTQUOTATION_FQHEADERVIEW():New()
	  		
	  		oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:dFQDATE      := Ctod(HttpPost->DATCOTV)
			oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQTIME      := StrTran(Padr(HttpPost->HORCOTV,5),':','')
			oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQDDD       := HttpPost->DDDV
			oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQTEL       := HttpPost->TELV 
			oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQCODSOL    := HttpPost->CODSOLVPRE
	  		oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQSRCEREGCOD:= HttpPost->CDRORIA
			oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQTRGTREGCOD:= HttpPost->CDRDESA
			oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQTRANSSERV := HttpPost->SERTMSA
			oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQTRANSTYPE := HttpPost->TIPTRAA
			If HttpPost->TIPFREA = "CIF" 
				oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQFREIGHTTYP:= "1"
			ElseIf HttpPost->TIPFREA = "FOB"
				oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQFREIGHTTYP:= "2"
			EndIf
			oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:dFQVALIDTERM := Ctod(HttpPost->PRZVALV)
			oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQOBS       := HttpPost->OBSA 
			
			//-- Itens da Cotação
			For nI := 1 To nIteTot
	       	If Ascan(HttpSession->EXCITENS, {|x| x == StrZero(nI,2) }) > 0
	       		If nI == 1
				  		oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM := TMSFREIGHTQUOTATION_ARRAYOFFQITEMVIEW():New() 
				  		Loop
					Else 
						Loop
					EndIf
				EndIf
						
				If nI == 1
				  	oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM := TMSFREIGHTQUOTATION_ARRAYOFFQITEMVIEW():New()
				  	aAdd(oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW,TMSFREIGHTQUOTATION_FQITEMVIEW():New())
				Else 
					aAdd(oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW,TMSFREIGHTQUOTATION_FQITEMVIEW():New())
				EndIf
	         
		  		nX++ //-- Ordem de Itens

				oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:CFQITEM    := StrZero(nX,2)
				oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:CFQPRODUCT := &("HttpPost->CODPROA"+Alltrim(Str(nI)))
					
				//-- Verifica se o produto já foi digitado
				bItem := {|x| x == &("HttpPost->CODPROA"+Alltrim(Str(nI)))}
				nPosItem := aScan(aItensTot,bItem)
					
				If nPosItem == 0
					aAdd(aItensTot,&("HttpPost->CODPROA"+Alltrim(Str(nI))))
				EndIf
									
				oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:CFQPACKING := TRANSFORM(&("HttpPost->CODEMBA"+Alltrim(Str(nI))),"@!")
				oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:NFQVOLQTY  := Val(&("HttpPost->QTDVOLA"+Alltrim(Str(nI))))
				
				//-- Tratamento para Peso
				cNumStr:= StrTran(&("HttpPost->PESOA"+Alltrim(Str(nI))),".","")
				cNumStr:= StrTran(cNumStr,",",".",Len(cNumStr))
				
				oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:NFQWEIGHT := Val(cNumStr)
				
				//-- Tratamento para Peso M3
				cNumStr:= ""
				cNumStr:= StrTran(&("HttpPost->PESOM3A"+Alltrim(Str(nI))),".","")
				cNumStr:= StrTran(cNumStr,",",".",Len(cNumStr)) 

				oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:NFQWEIGHT3 := Val(cNumStr)
				
				//-- Tratamento para Valor Merc.
				cNumStr:= ""
				cNumStr:= StrTran(&("HttpPost->VALMERA"+Alltrim(Str(nI))),".","")
				cNumStr:= StrTran(cNumStr,",",".",Len(cNumStr))
				
				oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:NFQVALGOODS:= Val(cNumStr)
  			Next nI		
	  			  			
  			If nPosItem == 0 
  				If oCotFre:CLCFREIGHTQUOTATION(GetUsrCode(),oCotFre:oWSFREIGHTQUOTATION)
					HttpSession->cFrete  := TRANSFORM(oCotFre:oWSCLCFREIGHTQUOTATIONRESULT:nFQCALFREIGHT,"@E 999,999.99")
			  		HttpSession->cImposto:=	TRANSFORM(oCotFre:oWSCLCFREIGHTQUOTATIONRESULT:nFQCALTAX,"@E 999,999.99")
			  		HttpSession->cFreImp := TRANSFORM(oCotFre:oWSCLCFREIGHTQUOTATIONRESULT:nFQCALFREIGHTTAX,"@E 999,999.99")
		  		Else
					HttpSession->PWSTMS19INFO[2] := "<center>"+STR0006+"<br/>"+STR0028+"<center>" ////"Erro de Execução de Calculo : "###"Erro ao localizar contrato para uso do portal"
					HttpSession->PWSTMS19INFO[3] := STR0003 //"Erro"
					HttpSession->PWSTMS19INFO[4] := STR0004 //"voltar"
					cHtml += ExecInPage( "PWSTMS19" ) 
					lConfirm := .T.
		  		EndIf		  		 		
		  	ElseIf nPosItem <> 0                 
		  	
		  		HttpSession->PWSTMS19INFO[2] := "<center>"+STR0007+"<br/>"+STR0008+"</center>" //"Erro na execução do calculo de frete para itens repetidos" ### "Favor inserir itens diferentes."
		  		HttpSession->PWSTMS19INFO[3] := STR0003 //"Erro"
		  		HttpSession->PWSTMS19INFO[4] := STR0004 //"voltar"
				cHtml += ExecInPage( "PWSTMS19" )  
				lConfirm := .T.
				
			Else
			
		  		HttpSession->PWSTMS19INFO[2] := STR0006+GetWSCError() //"Erro de Execução de Calculo : "
				HttpSession->PWSTMS19INFO[3] := STR0003 //"Erro"
				HttpSession->PWSTMS19INFO[4] := STR0004 //"voltar"
				cHtml += ExecInPage( "PWSTMS19" )
				lConfirm := .T. 
			Endif
			
		EndIf
	  	
	EndIf 
	 	
ElseIf HttpGet->cACT = "INS"  
	
	//-- Montagem do Objeto para Inclusão da Cotação
   If HttpGet->nNUMITENS = ""
	   nIteTot:= 1
	Else
	   nIteTot:= Val(HttpGet->nNUMITENS)
	EndIf
		
  	oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:= {}
	oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:= TMSFREIGHTQUOTATION_FQHEADERVIEW():New()
  		
	oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:dFQDATE      := Ctod(HttpPost->DATCOTVPRE)
	oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQTIME      := StrTran(Padr(HttpPost->HORCOTVPRE,5),':','')
	oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQDDD       := HttpPost->DDDVPRE
	oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQTEL       := HttpPost->TELVPRE
	oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQCODSOL    := HttpPost->CODSOLVPRE
  	oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQSRCEREGCOD:= HttpPost->CDRORIA
	oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQTRGTREGCOD:= HttpPost->CDRDESA
	oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQTRANSSERV := HttpPost->SERTMSA
	oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQTRANSTYPE := HttpPost->TIPTRAA
	If HttpPost->TIPFREA = "CIF" 
		oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQFREIGHTTYP:= "1"
	ElseIf HttpPost->TIPFREA = "FOB"
		oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQFREIGHTTYP:= "2"
	EndIf
	oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:dFQVALIDTERM := Ctod(HttpPost->PRZVALVPRE)
	oCotFre:oWSFREIGHTQUOTATION:oWSFQHEADER:cFQOBS       := HttpPost->OBSA
		
	For nI := 1 To nIteTot
     
		If nI == 1
			nX++
			oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM := TMSFREIGHTQUOTATION_ARRAYOFFQITEMVIEW():New() 
		Else
			nX++
		EndIf
			
		If Ascan(HttpSession->EXCITENS, {|x| x == StrZero(nI,2) }) > 0
			nX--
      	Loop
   	Else
   		aAdd(oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW,TMSFREIGHTQUOTATION_FQITEMVIEW():New()) 
			oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:CFQITEM    := StrZero(nX,2)
			oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:CFQPRODUCT := &("HttpPost->CODPROA"+Alltrim(Str(nI)))
			oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:CFQPACKING := &("HttpPost->CODEMBA"+Alltrim(Str(nI)))
			oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:NFQVOLQTY  := Val(&("HttpPost->QTDVOLA"+Alltrim(Str(nI))))
					
			//-- Tratamento para Peso
			cNumStr:= ""
			cNumStr:= StrTran(&("HttpPost->PESOA"+Alltrim(Str(nI))),".","")
			cNumStr:= StrTran(cNumStr,",",".",Len(cNumStr))
					
			oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:NFQWEIGHT := Val(cNumStr)
					
			//-- Tratamento para Peso M3
			cNumStr:= ""
			cNumStr:= StrTran(&("HttpPost->PESOM3A"+Alltrim(Str(nI))),".","")
			cNumStr:= StrTran(cNumStr,",",".",Len(cNumStr)) 
	
			oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:NFQWEIGHT3 := Val(cNumStr)
				
			//-- Tratamento para Valor Merc.
			cNumStr:= ""
			cNumStr:= StrTran(&("HttpPost->VALMERA"+Alltrim(Str(nI))),".","")
			cNumStr:= StrTran(cNumStr,",",".",Len(cNumStr))
			
			oCotFre:oWSFREIGHTQUOTATION:oWSFQITEM:oWSFQITEMVIEW[nX]:NFQVALGOODS:= Val(cNumStr)
		EndIf
					
	Next nI		

	If oCotFre:PUTFREIGHTQUOTATION(GetUsrCode(),oCotFre:oWSFREIGHTQUOTATION)
		HttpSession->PWSTMS19INFO[2] := oCotFre:cPUTFREIGHTQUOTATIONRESULT
		HttpSession->PWSTMS19INFO[3] := STR0009 //"Inclusão de Cotação de Frete"
		If "sucesso" $ oCotFre:cPUTFREIGHTQUOTATIONRESULT
			HttpSession->PWSTMS19INFO[4] := ""
		Else
			HttpSession->PWSTMS19INFO[4] := STR0004 //"voltar"
		EndIf
		cHtml += ExecInPage( "PWSTMS19" ) 
		lConfirm := .T.
	Else
  		HttpSession->PWSTMS19INFO[2] := STR0010+GetWSCError() //"Erro de Execução : "
		HttpSession->PWSTMS19INFO[3] := STR0003 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0004 //"voltar"
		cHtml += ExecInPage( "PWSTMS19" ) 
		lConfirm := .T.
	Endif
EndIf

If !lConfirm
	//-- Tratamento para "voltar" em caso de erro na página
	If Valtype(HttpSession->APWSTMSHEADERBCKC) == 'A'
		//-- Zera Sessions preenchidas anteriormente
		HttpSession->APWSTMS42HEADERINFO:= {}
		HttpSession->APWSTMS42ITEMINFO  := {}
		
		//-- Recurpera valores
		HttpSession->APWSTMS42HEADERINFO:= HttpSession->APWSTMSHEADERBCKC
		HttpSession->APWSTMS42ITEMINFO  := HttpSession->APWSTMSITEMBCKC
		
		HttpSession->APWSTMSHEADERBCKC := nil
		HttpSession->APWSTMSITEMBCKC   := nil
		
	EndIf                   
	
	cHtml += ExecInPage( "PWSTMS42" )
EndIf

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS43  ºAutor  ³Gustavo Almeida  º Data ³  08/03/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina Página de parametros para Cotação de Frete.   º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS43()

Local cHtml := ""
Local oObj


WEB EXTENDED INIT cHtml START "InSite"

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

cHtml += ExecInPage( "PWSTMS43" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS44 ºAutor  ³Gustavo Almeida  º Data ³ 08/03/11     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina Página de Listagem de Cotação de Frete.       º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS44()

Local cHtml      := ""
Local cDatFrom   := ""
Local cDatTo  	  := ""
Local dDatLim    := "" 
Local dDatPreFrom:= "" 
Local aStaCorDT4 := {"bt_amarelo.gif" ,"bt_vermelho.gif","bt_verde.gif"   ,;
                     "bt_azul.gif"    ,/*Sem Status 5 */,/*Sem Status 6 */,;
                     /*Sem Status 7 */,/*Sem Status 8 */,"bt_preto.gif"  }
Local nI         := 0
Local nX         := 0
Local oObj, oCotfre

WEB EXTENDED INIT cHtml START "InSite"

//-- Session com { Título do erro/informação,Descrição do erro/informação, Título do cabeçalho}
HttpSession->PWSTMS19INFO    := {Nil, Nil, Nil, Nil}
HttpSession->PWSTMS19INFO[1] := STR0005 //"Cotação de Frete"
HttpSession->APWSTMS44HEADER := {}
HttpSession->APWSTMS44INFO   := {}
HttpSession->CPWSTMS44TOTAL  := "0"
HttpSession->APWSTMS44STA    := {}

//-- Tratamento de Datas
cDatTo  := Dtos(Ctod(HttpPost->dDatFqTo))
If !Empty(cDatTo)
	dDatLim := Ctod(HttpPost->dDatFqTo)-90
Else
	HttpSession->PWSTMS19INFO[2] := "<center>"+STR0011+"<br/>"+STR0012+"</center>" //"'Data de' e/ou 'Data ate' invalida " ### "Informe uma data válida"
	HttpSession->PWSTMS19INFO[3] := STR0003 //"Erro"
	HttpSession->PWSTMS19INFO[4] := STR0004 //"voltar"
	cHtml := ExecInPage( "PWSTMS19" )
EndIf
	
If Empty(HttpPost->dDatFqFrom)
	cDatFrom:= Dtos(dDatLim)
Else 
   //-- Verifica se o periodo é maior que 90 dias
	dDatPreFrom:= Ctod(HttpPost->dDatFqFrom)
	If dDatPreFrom >= dDatLim 
		cDatFrom:= Dtos(Ctod(HttpPost->dDatFqFrom))
	Else
		HttpSession->PWSTMS19INFO[2] := "<center>"+STR0013+"<br/>"+STR0014+"</center>" //"Periodo inválido" ### "Informe periodos com 3 meses de diferença"
		HttpSession->PWSTMS19INFO[3] := STR0003 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0004 //"voltar"
		cHtml := ExecInPage( "PWSTMS19" )		
	EndIf 
EndIf                               

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

oCotfre := WSTMSFREIGHTQUOTATION():NEW()
WsChgUrl(@oCotfre,"TMSFREIGHTQUOTATION.APW")
                                                          

If cHtml == ""

	If oObj:GETHEADER("FREIGHTQUOTATION")
		For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
		
			aAdd( HttpSession->APWSTMS44HEADER,{oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTITLE})
		
		Next nI
	EndIf
	
	oCotfre:BRWFREIGHTQUOTATION(GetUsrCode(),cDatFrom,cDatTo)
	
	If !Empty(oCotfre:oWSBRWFREIGHTQUOTATIONRESULT:oWSFQBROWSERVIEW)
      
   //-- Status
  	oObj:GETSX3BOX("DT4_STATUS")
	
	
 		For nI:= 1 To Len(oCotfre:oWSBRWFREIGHTQUOTATIONRESULT:oWSFQBROWSERVIEW)
 		
 			//-- Status
		   For nX:= 1 To Len(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX)
		   	If oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBVALUE01 == oCotfre:oWSBRWFREIGHTQUOTATIONRESULT:oWSFQBROWSERVIEW[nI]:cFQBRWSTATUS
		   		aAdd(HttpSession->APWSTMS44STA,{aStaCorDT4[VAL(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBVALUE01)],; 
		   	    	                             Alltrim(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBDESCRIPTION)})
		      EndIf
		   Next nX
 		
			aAdd( HttpSession->APWSTMS44INFO,{oCotfre:oWSBRWFREIGHTQUOTATIONRESULT:oWSFQBROWSERVIEW[nI]:cFQBRWFQNUMB,;
									           Dtoc(oCotfre:oWSBRWFREIGHTQUOTATIONRESULT:oWSFQBROWSERVIEW[nI]:dFQBRWDATE),;
									      TRANSFORM(oCotfre:oWSBRWFREIGHTQUOTATIONRESULT:oWSFQBROWSERVIEW[nI]:cFQBRWTIME,"@R 99:99")})   
   	Next nI
	
		HttpSession->CPWSTMS44TOTAL := Str(Len(oCotfre:oWSBRWFREIGHTQUOTATIONRESULT:oWSFQBROWSERVIEW))
	
		cHtml += ExecInPage( "PWSTMS44" )
	
	Else
		HttpSession->PWSTMS19INFO[2] := "<center>"+STR0015+"<br/>"+STR0016+"</center>" //"Nenhuma Cotação encontrada no periodo informado" ### "Verifique o periodo"
		HttpSession->PWSTMS19INFO[3] := STR0003 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0004 //"voltar"
		cHtml := ExecInPage( "PWSTMS19" )
	EndIf
EndIf

WEB EXTENDED END

Return cHtml
