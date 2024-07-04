#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSQ020   ºAutor  ³Telso Carneiro      º Data ³  22/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pagina inicial de item Documentos do menu principal.       º±±
±±º          ³ Escopo do filtro                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal QDO                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSQ020()

Local cHtml := ""
Local oObj
Local nA	:= 0

WEB EXTENDED INIT cHtml

HttpSession->WSQDO20AHEADRESL := {}
HttpSession->WSQDO20ACOLSCOMP := {}                              

oObj := WSQDODOCUMENTS():New()
oObj:cUSERCODE := httpSession->USR_INFO[1]:cUserCode // Usuario do Portal

IF oObj:GetaHeadDoc()//aHeader	
	For nA:=1 To Len(oObj:oWSGETAHEADDOCRESULT:oWSAHEADQDHVIEW)  	
		AAdd(HttpSession->WSQDO20AHEADRESL,{ ;
			oObj:oWSGETAHEADDOCRESULT:oWSAHEADQDHVIEW[nA]:CX3_TITULO ,;
			oObj:oWSGETAHEADDOCRESULT:oWSAHEADQDHVIEW[nA]:CX3_CAMPO  ,;
			oObj:oWSGETAHEADDOCRESULT:oWSAHEADQDHVIEW[nA]:CX3_PICTURE} )		
	Next
Endif                                                                                   

IF oObj:GetQDOPaths() //paths
	HttpSession->WSQDO20QDOPATH := {;  	    
		oObj:oWSGETQDOPATHSRESULT:oWSAQDOMVPATHVIEW[1]:CQPATH    ,;
		oObj:oWSGETQDOPATHSRESULT:oWSAQDOMVPATHVIEW[1]:CQPATHD   ,;
		oObj:oWSGETQDOPATHSRESULT:oWSAQDOMVPATHVIEW[1]:CQPATHTRM ,;
		oObj:oWSGETQDOPATHSRESULT:oWSAQDOMVPATHVIEW[1]:CTEXTOD   ,;
		oObj:oWSGETQDOPATHSRESULT:oWSAQDOMVPATHVIEW[1]:CQPATHHTM ,;
		oObj:oWSGETQDOPATHSRESULT:oWSAQDOMVPATHVIEW[1]:CPATHVIEW ,;
		oObj:oWSGETQDOPATHSRESULT:oWSAQDOMVPATHVIEW[1]:CUSAVIEW  ,; 
		oObj:oWSGETQDOPATHSRESULT:oWSAQDOMVPATHVIEW[1]:CQPATHDIR ,;
		oObj:oWSGETQDOPATHSRESULT:oWSAQDOMVPATHVIEW[1]:CUSAHTML }	
Endif

IF oObj:GetDocument() //aCols	
	For nA:=1 To Len(oObj:oWSGETDOCUMENTRESULT:oWSACOLSQDHVIEW) 
	    AAdd(HttpSession->WSQDO20ACOLSCOMP,{ ;
			oObj:oWSGETDOCUMENTRESULT:oWSACOLSQDHVIEW[nA]:CFILIALDOC ,;
			oObj:oWSGETDOCUMENTRESULT:oWSACOLSQDHVIEW[nA]:CTIPODOC   ,;
			oObj:oWSGETDOCUMENTRESULT:oWSACOLSQDHVIEW[nA]:CCODIGODOC ,;
			oObj:oWSGETDOCUMENTRESULT:oWSACOLSQDHVIEW[nA]:CRVDOC     ,;
			oObj:oWSGETDOCUMENTRESULT:oWSACOLSQDHVIEW[nA]:CTITULODOC ,;
			oObj:oWSGETDOCUMENTRESULT:oWSACOLSQDHVIEW[nA]:CPENDUSR   ,;
			oObj:oWSGETDOCUMENTRESULT:oWSACOLSQDHVIEW[nA]:CDTOIE     ,;
			oObj:oWSGETDOCUMENTRESULT:oWSACOLSQDHVIEW[nA]:CNOMDOC    ,;
			oObj:oWSGETDOCUMENTRESULT:oWSACOLSQDHVIEW[nA]:CDESCTIPO    } )	
	Next      
ENDIF   
      
       
IF Len(HttpSession->WSQDO20AHEADRESL) >0 .AND. Len(HttpSession->WSQDO20ACOLSCOMP ) > 0
	cHtml += ExecInPage( "PWSQ020" )
Endif
WEB EXTENDED END

Return cHtml
