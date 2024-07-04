#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE cCodUser "MSALPHA"


// Funcao generica para chamada de HTML's de usuario
Web Function PwsaHtmUsr()

Local cHtml 	:= ""

WEB EXTENDED INIT cHtml  

//	cHtml := "<script>window.location='htmls-rh/"+HttpGet->cPage+"';</script>"                      
	cHtml := "<script>window.location='"+HttpGet->cPage+"';</script>"                      

WEB EXTENDED END

Return cHtml

