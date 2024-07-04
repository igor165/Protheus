#INCLUDE "PWSTMS30.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS3X  �Autor  �Gustavo Almeida  � Data �  01/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina com layout de Tracking.                       ���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������ͼ��
���WEBFUNC.     � DESCRI��O                                               ��� 
�����������������������������������������������������������������������������
���PWSTMS30     � P�gina inicial.                                         ���
���PWSTMS31     � Visualiza��o de Tracking.                               ���
���PWSTMS32     � Param. de Listagem de Documentos/Notas de Tracking.     ���
���PWSTMS33     � Listagem de Documentos/Notas de Tracking.               ���        
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS30  �Autor  �Gustavo Almeida  � Data �  01/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina P�gina Inicial de Tracking.                   ���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSTMS30()

Local cHtml := ""
Local oObj


WEB EXTENDED INIT cHtml START "InSite"

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

HttpSession->APWSTMS30INFO:= {STR0001,STR0002} //"Nota Fiscal"###"Docto. Transporte"

cHtml += ExecInPage( "PWSTMS30" )

WEB EXTENDED END

Return cHtml

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS31  �Autor  �Gustavo Almeida  � Data �  01/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina P�gina Visualiza��o de Tracking.              ���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSTMS31()

Local cHtml    := ""
Local nI       := 0
Local cFilDoc  := ""
Local cDoc     := ""
Local cSerieDoc:= ""
Local cDocType := ""
Local oObj,oTrack,oDoc 

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

oTrack := WSTMSTRACKING():NEW()
WsChgUrl(@oTrack,"TMSTRACKING.APW")

HttpSession->APWSTMS31HEADER:= {}
HttpSession->APWSTMS31INFO  := {}
HttpSession->CPWSTMS31DOC   := ""

//-- Cabe�alho de Tracking
aAdd( HttpSession->APWSTMS31HEADER,{STR0003} ) //"Data"
aAdd( HttpSession->APWSTMS31HEADER,{STR0004} ) //"Hora"
aAdd( HttpSession->APWSTMS31HEADER,{STR0005} ) //"Operacao/Ocorrencia"
aAdd( HttpSession->APWSTMS31HEADER,{STR0006} ) //"Filial"
aAdd( HttpSession->APWSTMS31HEADER,{STR0007} ) //"Viagem"
aAdd( HttpSession->APWSTMS31HEADER,{STR0008} ) //"Serv. Transporte"

//-- Itens de Tracking
If !Empty(HttpPost->cDoc)
	cFilDoc   := HttpPost->cFilDoc
	cDoc      := HttpPost->cDoc
	cSerieDoc := HttpPost->cSerieDoc
	cDocType  := HttpPost->cTipoDoc
Else
	cFilDoc   := HttpGet->cFilDoc
	cDoc      := HttpGet->cDoc
	cSerieDoc := HttpGet->cSerieDoc
	cDocType  := HttpGet->cTipoDoc
EndIf 

//-- Documento a Ser Exibido
oDoc:= oTrack:OWSTRACKINGDOC

oDoc:cTdBranch    := cFilDoc 
oDoc:cTdDocNumber := cDoc
oDoc:cTdDocSeries := cSerieDoc

If oTrack:GETTRACKINGVIEW(GetUsrCode(),cDocType,oDoc)
	
	HttpSession->CPWSTMS31DOC:= cDoc
	 
	For nI:=1 to Len(oTrack:oWSGETTRACKINGVIEWRESULT:oWSTRACKINGVIEW)
		aAdd( HttpSession->APWSTMS31INFO,{oTrack:oWSGETTRACKINGVIEWRESULT:oWSTRACKINGVIEW[nI]:dTVDATE,;
												    oTrack:oWSGETTRACKINGVIEWRESULT:oWSTRACKINGVIEW[nI]:cTVTIME,;
									  			 	 oTrack:oWSGETTRACKINGVIEWRESULT:oWSTRACKINGVIEW[nI]:cTVOPEROCCUR,;
												 	 oTrack:oWSGETTRACKINGVIEWRESULT:oWSTRACKINGVIEW[nI]:cTVBRANCH,;
													 oTrack:oWSGETTRACKINGVIEWRESULT:oWSTRACKINGVIEW[nI]:cTVTRIP,;
												 	 oTrack:oWSGETTRACKINGVIEWRESULT:oWSTRACKINGVIEW[nI]:cTVTRANSSERV})
	Next nI 
	
EndIf

cHtml += ExecInPage( "PWSTMS31" )

WEB EXTENDED END

Return cHtml

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS32  �Autor  �Gustavo Almeida  � Data �  01/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina P�gina de parametros para Tracking.           ���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSTMS32()

Local cHtml := ""
Local oObj
HttpSession->PWSTMS32TIPODOC := HttpPost->cTipoDoc

WEB EXTENDED INIT cHtml START "InSite"

If HttpPost->cTipoDoc == "1"
	HttpSession->APWSTMS32INFO:= {HttpSession->APWSTMS30INFO[1],HttpSession->APWSTMS30INFO[2]}
Else
	HttpSession->APWSTMS32INFO:= {HttpSession->APWSTMS30INFO[2],HttpSession->APWSTMS30INFO[1]}
EndIf

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

cHtml += ExecInPage( "PWSTMS32" )

WEB EXTENDED END

Return cHtml

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS33 �Autor  �Gustavo Almeida  � Data � 01/03/11    ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina P�gina de Listagem de Tracking.               ���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSTMS33()

Local cHtml      := ""
Local cDatFrom   := ""
Local dDatLim    := ""
Local dDatPreFrom:= ""
Local cDatTo     := ""
Local aStaCorDT6 := {"bt_verde.gif"  ,"bt_vermelho.gif","bt_amarelo.gif",;
                     "bt_laranja.gif","bt_azul.gif"    ,"bt_cinza.gif"  ,;
                     "bt_marron.gif" ,"bt_pink.gif"    ,"bt_preto.gif"   }
Local nI         := 0
Local nX         := 0
Local oObj, oTrack

WEB EXTENDED INIT cHtml START "InSite"

//-- Session com { T�tulo do erro/informa��o,Descri��o do erro/informa��o, T�tulo do cabe�alho, Voltar/Fechar}
HttpSession->PWSTMS19INFO    := {Nil, Nil, Nil, Nil}
HttpSession->PWSTMS19INFO[1] := STR0009 //"Tracking"

HttpSession->APWSTMS31STA    := {}  

HttpSession->APWSTMS33INFO   := {}
HttpSession->CPWSTMS33TOTAL  := "0"
HttpSession->CPWSTMS33DOCTYPE:= HttpPost->cTipoDoc
HttpSession->CPWSTMS33DOCBK  := HttpPost->cDoc

//-- Descri��o : Cabe�alho	
HttpSession->APWSTMS33HEADER := {}

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")
	
oTrack := WSTMSTRACKING():NEW()
WsChgUrl(@oTrack,"TMSTRACKING.APW")
			
If oObj:GETHEADER("TRACKINGBRW")
	For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
		
		aAdd( HttpSession->APWSTMS33HEADER,{oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTITLE})
		
	Next nI
EndIf 


If Empty(HttpPost->cDoc)

	//-- Tratamento de Datas
	cDatTo  := Dtos(Ctod(HttpPost->dDatPoTo))
	If !Empty(cDatTo)
		dDatLim := Ctod(HttpPost->dDatPoTo)-90
	Else
		HttpSession->PWSTMS19INFO[2] := "<center>"+STR0010+"<br/>"+STR0011+"</center>" //"'Data de' e/ou 'Data at�' inv�lida" ### "Informe uma data v�lida"
		HttpSession->PWSTMS19INFO[3] := STR0012 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0013 //"voltar"
		cHtml := ExecInPage( "PWSTMS19" )
	EndIf
	
	If Empty(HttpPost->dDatPoFrom)
		cDatFrom:= Dtos(dDatLim)
	Else
	   //-- Verifica se o periodo � maior que 90 dias
		dDatPreFrom:= Ctod(HttpPost->dDatPoFrom)
		If dDatPreFrom >= dDatLim 
			cDatFrom:= Dtos(Ctod(HttpPost->dDatPoFrom))
		Else
			HttpSession->PWSTMS19INFO[2] := "<center>"+STR0014+"<br/>"+STR0015+"</center>" //"<center>Periodo inv�lido" ### "Informe periodos com 3 meses de diferen�a"
			HttpSession->PWSTMS19INFO[3] := STR0012 //"Erro"
			HttpSession->PWSTMS19INFO[4] := STR0013 //"voltar"
			cHtml := ExecInPage( "PWSTMS19" )		
		EndIf 
	EndIf
	
EndIf

If cHtml == ""

	//-- Status
	oObj:GETSX3BOX("DT6_STATUS") 
	                                                          
	If !Empty(cDatFrom) .And. !Empty(cDatTo)
	
		oTrack:GETBRWTRACKING(GetUsrCode(),HttpPost->cTipoDoc,"",cDatFrom,cDatTo)
		
		If !Empty(oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC)
			  
			For nI:= 1 To Len(oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC)
		   	//-- Status
		   	For nX:= 1 To Len(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX)
		   		If oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBVALUE01 == oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:cTDSTATUS
		   			aAdd(HttpSession->APWSTMS31STA,{aStaCorDT6[VAL(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBVALUE01)],; 
		   		    	                             Alltrim(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBDESCRIPTION)}) 
		   	   ElseIf oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:cTDSTATUS == "0"  //-- Sem Documento de Transporte
		   	   	aAdd(HttpSession->APWSTMS31STA,{"bt_branco.gif",STR0016})  //"N�o h� documento de transporte"
		   	   EndIf
		   	NexT nX 
		   	
				aAdd( HttpSession->APWSTMS33INFO,{oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:cTDBRANCH,;
										                oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:cTDDOCNUMBER,;
										                oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:cTDDOCSERIES,;
										                oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:dTDDATE,;
										                TRANSFORM(oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:cTDTIME,"@R 99:99")})   
		   Next nI
	
			HttpSession->CPWSTMS33TOTAL := Str(Len(oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC))
			
			cHtml += ExecInPage( "PWSTMS33" )
			
		Else
			If HttpPost->cTipoDoc == "1"
				HttpSession->PWSTMS19INFO[2] := "<center>"+STR0017+"<br/>"+STR0018+"</center>" //"<center>Nenhuma Nota Fiscal encontrada no periodo informado" ### "Verifique o periodo"
			Else 
				HttpSession->PWSTMS19INFO[2] := "<center>"+STR0019+"<br/>"+STR0018+"</center>" //"<center>Nenhum Docto. Transporte encontrado no periodo informado" ### "Verifique o periodo"
			EndIf
			HttpSession->PWSTMS19INFO[3] := STR0012 //"Erro"
			HttpSession->PWSTMS19INFO[4] := STR0013 //"voltar"
			cHtml := ExecInPage( "PWSTMS19" )
		EndIf
	Else
	  
		oTrack:GETBRWTRACKING(GetUsrCode(),HttpPost->cTipoDoc,HttpPost->cDoc,"","")
		
		If !Empty(oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC)
		          
		   For nI:= 1 To Len(oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC)
		   	//-- Status
		   	For nX:= 1 To Len(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX)
		   		If oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBVALUE01 == oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:cTDSTATUS
		   			aAdd(HttpSession->APWSTMS31STA,{aStaCorDT6[VAL(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBVALUE01)],; 
		   		    	                             Alltrim(oObj:oWSGETSX3BOXRESULT:oWSSX3BOX[nX]:cSBDESCRIPTION)}) 
		   	   ElseIf oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:cTDSTATUS == "0"  //-- Sem Documento de Transporte
		   	   	aAdd(HttpSession->APWSTMS31STA,{"bt_branco.gif",STR0016})  //"N�o h� documento de transporte"
		   	   EndIf
		   	NexT nX                         
	
				aAdd( HttpSession->APWSTMS33INFO,{oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:cTDBRANCH,;
										                oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:cTDDOCNUMBER,;
										                oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:cTDDOCSERIES,;
										                oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:dTDDATE,;
										                TRANSFORM(oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC[nI]:cTDTIME,"@R 99:99")})   
		   Next nI
			
			HttpSession->CPWSTMS33TOTAL := Str(Len(oTrack:oWSGETBRWTRACKINGRESULT:OWSTRACKINGDOC))
			
			cHtml += ExecInPage( "PWSTMS33" )
			
		Else
			If HttpPost->cTipoDoc == "1"
				HttpSession->PWSTMS19INFO[2] := "<center>"+STR0020+"<br/>"+STR0021+"</center>" //"Nota Fiscal n�o encontrada" ### "Verifique a nota fiscal informada"
			Else 
				HttpSession->PWSTMS19INFO[2] := "<center>"+STR0022+"<br/>"+STR0023+"</center>" //"Docto. Transporte n�o encontrado" ### "Verifique o docto. transporte informado"
			EndIf
			HttpSession->PWSTMS19INFO[3] := STR0012 //"Erro"
			HttpSession->PWSTMS19INFO[4] := STR0013 //"voltar"
			cHtml := ExecInPage( "PWSTMS19" )
		EndIf
	EndIf
EndIf

WEB EXTENDED END

Return cHtml