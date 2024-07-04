// #########################################################################################
// Projeto: Facturacion electronica
// Modulo : SIGAFAT
// Fonte  : RFATC01
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 25/04/14 | Rafael Yera Barchi| Consulta de status de documento fiscal via webservice.  
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE 	"PROTHEUS.CH"
#INCLUDE 	"TOTVS.CH"
#INCLUDE	"FISA057.CH" 

#DEFINE 	cEOL			Chr(13) + Chr(10)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RFATC01
Consulta de status de documento fiscal via webservice.

@author    Rafael Yera Barchi
@version   1.00
@since     25/04/2014

getEstadoComprobanteDGI(Texto rutEmisor,Entero idTipoComprobante, Texto
serie, Entero numeroComprobante);

Args:

- cRUTEmi: Registro Unico Tributario do Emissor
- nIdTipo: Id Tipo Documento
- cSerDoc: Serie do Documento
- nNumDoc: Numero do Documento
- nCall: Tipo da chamada (1= Sem interface, 2= Com interface)


Retorno: xRet

- cRet: String de retorno (nCall == 1)
	cCodRec + cMotivo + cDescri

- aRet: Array de retorno (nCall <> 1)
	aRet[1] => lRet: Indica se conseguiu executar a consulta
	aRet[2] => cCodRec: Código de recusa
	aRet[3] => cMotivo: Motivo da recusa
	aRet[4] => cDescri: Descrição

/*/
//------------------------------------------------------------------------------------------
User Function RFATC01(cRUTEmi, nIdTipo, cSerDoc, nNumDoc, nCall, lAuto,cVerWs,cUser,cPass)
	
	 
Local Ret		:= Nil
Local cRet		:= ""
Local aRet		:= {}
Local cStatus		:= ""
Local cMensagem	:= ""
Local lAvisos		:= !IsBlind()
Local lRet		:= .F.
Local oRet		:= Nil
Local cCodRec		:= ""
Local cMotivo		:= ""
Local cDescri		:= ""
Local aParam		:= {}
Local cWsVersao		:= GetNewPar("MV_URUVWS","3.1")	//Versao 2.0 (antiga) ou Versao 3.1 (nova)    
Local cAviso:=" "
Local cWarning:=""            
Local cWsCustId		:= GetNewPar("MV_URUSUCU","1")
Local cWsUser			:= GetNewPar("MV_URUUSER","")
Local cWsPass			:= GetNewPar("MV_URUPASW","")
	
Private 	cPerg		:= PadR("RFATC01", 10)

Default nCall		:= 1	
Default lAuto		:= .F.
	
If !Empty(cRUTEmi)
	AAdd(aParam, cRUTEmi)
	AAdd(aParam, nIdTipo)
	AAdd(aParam, cSerDoc)
	AAdd(aParam, nNumDoc)
EndIf

If Len(aParam) > 0
	mv_par01 := aParam[1]
	mv_par02 := aParam[2]
	mv_par03 := aParam[3]
	mv_par04 := aParam[4]
Else
	ValidPerg()
	If !Pergunte(cPerg, .T.)
		Return ""
	EndIf
EndIf
	
	
_cRUTEmi := AllTrim(mv_par01)
_nIdTipo := mv_par02
_cSerDoc := AllTrim(mv_par03)
_nNumDoc := mv_par04
_cWsUser := cUser
_cWsPass := cPass
_cVer    := cVerWs
    
If cWsVersao $ "2.0"
	MsgInfo(STR0148)
	lRet := .F.
ElseIf  cWsVersao $ "3.1"                  
	oWS3 := WSRondanetService():New()
	oWS3:_URL 				:= GetNewPar("MV_IPWSRON","")
	oWS3:crutEmisor 		:= Alltrim(SM0->M0_CGC)
	oWS3:cusuario			:= cWsUser
	oWS3:cpassword 			:= cWsPass
	oWS3:nnumeroComprobante	:= _nNumDoc
	oWS3:ntipoComprobante	:=_nIdTipo
	oWS3:cserie	:=_cSerDoc

	If oWS3:obtenerEstadoComprobanteDGI()//(cRUTEmi,usuario,senha, nIdTipo, cSerDoc, nNumDoc)      
		lRet	:= .T.
		oRet	:= XMLParser(oWS3:cReturn,'_',@cAviso,@cWarning)
	Else
		lRet	:= .F.
		cSvcError 	:= GetWSCError()
	  	If Left(cSvcError, 9) == "WSCERR048"
	   		cSoapFCode 	:= AllTrim(SubStr(GetWSCError(3), 1, At(":", GetWSCError(3)) - 1))
			cSoapFDescr := AllTrim(SubStr(GetWSCError(3), At(":", GetWSCError(3)) + 1, Len(GetWSCError(3))))
	   		cMensagem 	:= Time() + " - Erro na consulta (WS3 - Método obtenergetEstadoComprobanteDGI:" + cSoapFDescr + " -> " + cSoapFCode
	  	Else
	   		cMensagem := Time() + " - " + "Sem comunicação com o webservice 2: " + If(oWS3:_URL <> Nil, oWS3:_URL, "")
		EndIf
	  	If Empty(cAviso) .And. Empty(cWarning)
	  	   //	Aviso("TOTVS", cMensagem, {"OK"}, 3)
	  	   ConOut(cMensagem)
	  	Else
	  		ConOut(cMensagem)
	  	EndIf
	EndIf
	
    	If oRet <> Nil    	
   		If AT("CODIGO", oWS3:cReturn) > 0
    			cCodRec :=   oRet :_RESPUESTA_WS:_CODIGO:TEXT      // oRet:_ESTADO
    			cMotivo :=   oRet :_RESPUESTA_WS:_CODIGO:TEXT     // oRet:_MOTIVO
    			cDescri :=   oRet :_RESPUESTA_WS:_DESCRIPCION:TEXT
    		Else
	    		cCodRec :=   oRet:_RESPUESTA_WS:_ESTADOCOMPROBANTE:_ESTADO:TEXT      // oRet:_ESTADO
    			cMotivo :=    oRet:_RESPUESTA_WS:_ESTADOCOMPROBANTE:_MOTIVO:TEXT     // oRet:_MOTIVO
    			cDescri :=   oRet:_RESPUESTA_WS:_ESTADOCOMPROBANTE:_DETALLE:TEXT   // oRet:_DETALHE	
    		EndiF
	Else
    		If !lAvisos .And. !lAuto
	    		MsgAlert("Não foi possível realizar a consulta (WS3)! ")
	    	Else
	    		ConOut("Não foi possível realizar a consulta (WS3)! ")
	   	EndIf
        EndIf    
EndIf
If nCall == 1
	cRet := cCodRec + " / " + cMotivo + " / " + cDescri
    	xRet := cRet
Else
    AAdd(aRet, lRet) 
    AAdd(aRet, cCodRec)
    AAdd(aRet, cMotivo)
    AAdd(aRet, cDescri)	    
    xRet := {}
    xRet := AClone(aRet)	    
EndIf
	
Return xRet



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
Rotina para criação de perguntas.

@author    Rafael Yera Barchi
@version   1.xx
@since     29/04/2014
/*/
//------------------------------------------------------------------------------------------
Static Function ValidPerg()
	
	//--< Variáveis >-----------------------------------------------------------------------
	Local aAreaX1 := GetArea()
	
	
	//--< Procedimentos >-------------------------------------------------------------------
	PutSX1(cPerg, "06", "RUT Emissor?"         	, "RUT Emissor?"	, "RUT Emissor?"	, "mv_ch6"	, "C", TamSX3("A2_CGC")[1]	, 0, 1, "G", "", ""	, "", "", "mv_par01", ""			, "", "", "", ""			, "", "", "", "", "", "", "", "", "", ""		, "", {}, {}, {})
	PutSX1(cPerg, "07", "Id Tipo Doc.?"        	, "Id Tipo Doc.?"	, "Id Tipo Doc.?"	, "mv_ch7"	, "N", 05					, 0, 1, "G", "", ""	, "", "", "mv_par02", ""			, "", "", "", ""			, "", "", "", "", "", "", "", "", "", ""		, "", {}, {}, {})
	PutSX1(cPerg, "08", "Serie Doc.?"          	, "Serie Doc.?"		, "Serie Doc.?"		, "mv_ch8"	, "C", 03					, 0, 1, "G", "", ""	, "", "", "mv_par03", ""			, "", "", "", ""			, "", "", "", "", "", "", "", "", "", ""		, "", {}, {}, {})
	PutSX1(cPerg, "09", "Numero Doc.?"       	, "Numero Doc.?"	, "Numero Doc.?"	, "mv_ch9"	, "N", 15					, 0, 1, "G", "", ""	, "", "", "mv_par04", ""			, "", "", "", ""			, "", "", "", "", "", "", "", "", "", ""		, "", {}, {}, {})
	
	RestArea(aAreaX1)
	
Return
