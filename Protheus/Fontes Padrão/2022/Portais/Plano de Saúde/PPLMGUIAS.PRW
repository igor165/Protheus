#INCLUDE "APWEBEX.CH"
#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLCHAALT
Função que preenche as guias para carregar na tela
@author Karine Riquena Limp
@since 20/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Web Function PPLCHAALT()
LOCAL nI      	:= 0
LOCAL oObj	  	:= NIL
LOCAL cResult 	:= "true|"
LOCAL cValGDExe	:= ""
LOCAL cTipGui 	:= HttpGet->cTipGui
LOCAL cMatric 	:= ""
LOCAL cNumGuia	:= ""
LOCAL lOdonto	:= IIF(cTipGui == "4", .T., .F.)
LOCAL lResInt	:= IIF(cTipGui == "5", .T., .F.)
LOCAL cHtml 	:= ""
Local nValor
Local nVlApr	:= 0
local cRelacExc	:= ""
WEB EXTENDED INIT cHtml START "InSite"

//-------------------------------------------------------------------
// Web Service
//-------------------------------------------------------------------
oObj := WSPLSGUIAS():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSGUIAS.APW" )
//-------------------------------------------------------------------
// Parametros de entrada
//-------------------------------------------------------------------
oObj:cUserCode 		 := "MSALPHA"
oObj:cRecno   		 := AllTrim(HttpGet->cRecno)
oObj:lOdonto   		 := lOdonto
oObj:lResumoInt		 := lResInt
//-------------------------------------------------------------------
// Executa metodo para retorno da liberacao
//-------------------------------------------------------------------
If cTipGui == "1"
	If oObj:CarregaConsulta()
		//-------------------------------------------------------------------
		//Cabecalho
		//-------------------------------------------------------------------
		cMatric := oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cOpeUsr
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cCodEmp
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cMatric
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cTipReg
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cDigito

		For nI:=1 To Len(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS)
			cResult +=  	"cCodPro!" + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPro) 	+"|"+;
				"dDtAtend!"		+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:dDtPro))		+"|"+;
				"cCodPad!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPad)			+"|"+;
				"cVlrPro!" 		+ AllTrim( TransForm( oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nVlrApr,"@U 999,999,999.99" ) )+"|"
		Next

		cResult +=	"cRegAns!"    + alltrim(oObj:OWSCARREGACONSULTARESULT:cRegAns)				+"|"+;
			"cNumPre!"    	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cNumImp)					+"|"+;
			"cNumeCart!"  	+ alltrim(cMatric)													+"|"+;
			"cLibAte!"    	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cLibAte)					+"|"+;
			"cAtendRN!"   	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cAteRna)		+"|"+;
			"cNomeUsu!"   	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cNomUsr)		+"|"+;
			"cCnpfCpf!"   	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCpfCnpjRda)	+"|"+;
			"cNomeRdaExe!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cNomRda)		+"|"+;
			"cCodSigExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cSigCr)			+"|"+;
			"cEstSigExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cEstProf)		+"|"+;
			"cProSolDesc!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cNomProf)		+"|"+;
			"cProSol!"    	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cCdProf)		+"|"+;
			"cNumCrExe!"  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cNumCr)			+"|"+;
			"cNomeSocial!"  + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cNomSoci)		+"|"+;
			"cCobertEsp!"  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cCobEspNwS)					+"|"+;
			"cRegAtendim!"  + alltrim(oObj:OWSCARREGACONSULTARESULT:cRegAtdNwS)					+"|"+;
			"cSaudeOcupac!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cSaudOcNwS)					+"|"

		If !Empty(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cEspProf)
			cResult +=	 "cCbosExe!"   + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cEspProf)+"|"
		Else
			cResult +=	 "cCbosExe!"   + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCodEsp) +"|"
		EndIf
		cResult +=	"cIndAcid!"   + alltrim(oObj:OWSCARREGACONSULTARESULT:cIndAci)			+"|"+;
			"cTpCon!"     + alltrim(oObj:OWSCARREGACONSULTARESULT:cTipCon)					+"|"
		If !Empty(oObj:OWSCARREGACONSULTARESULT:cObs)
			cResult +=	 "cObs!" + alltrim(oObj:OWSCARREGACONSULTARESULT:cObs) 				+"|"
		Else
			cResult +=	 "cObs!" + alltrim(oObj:OWSCARREGACONSULTARESULT:cMsg01+ " " +oObj:OWSCARREGACONSULTARESULT:cMsg02)+"|"
		EndIf
		cResult += "cOriMov!"  + alltrim(oObj:OWSCARREGACONSULTARESULT:cOriMov)				+"|<"
	Else
		cResult += "ERRO"
	EndIf

	//-------------------------------------------------------------------
	// Guia SADT
	//-------------------------------------------------------------------
Elseif cTipGui == "2"

	if oObj:CarregaConsulta()
		//-------------------------------------------------------------------
		//  Cabecalho
		//-------------------------------------------------------------------
		cMatric := oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cOpeUsr
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cCodEmp
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cMatric
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cTipReg
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cDigito

		cNumGuia := oObj:OWSCARREGACONSULTARESULT:cCodOpe
		cNumGuia += oObj:OWSCARREGACONSULTARESULT:cAnoPag
		cNumGuia += oObj:OWSCARREGACONSULTARESULT:cMesPag
		cNumGuia += oObj:OWSCARREGACONSULTARESULT:cNumAut

		cResult +=	"cRegAns!"    + alltrim(oObj:OWSCARREGACONSULTARESULT:cRegAns)					+"|"+;
			"cNumAut!"    	+ alltrim(cNumGuia) 													+"|"+;
			"cNumPre!"    	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cNumImp)						+"|"+;
			"cNumeCart!"  	+ alltrim(cMatric)														+"|"+;
			"cLibAte!"    	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cLibAte)						+"|"+;
			"cAtendRN!"   	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cAteRna)			+"|"+;
			"cNomeUsu!"   	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cNomUsr)			+"|"+;
			"cNumInt!"    	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cNrlBor)						+"|"+;
			"cCnpfCpf!"   	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCpfCnpjRda)		+"|"+;
			"cCnes!"      	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCnes)				+"|"+;
			"cCnesExe!"   	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCnes)				+"|"+;
			"cNomeRdaExe!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cNomRda)			+"|"+;
			"cCnpjCpfExe!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSContExec:cCpfCnpjRda)		+"|"+;
			"cCodSigExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cSigCr)				+"|"+;
			"cEstSigExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cEstProf)			+"|"+;
			"cProSol!"    	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cCdProf)				+"|"+;
			"cProSolDesc!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cNomProf)			+"|"+;
			"cNumCrExe!"  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cNumCr)				+"|"+;
			"cCobertEsp!"  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cCobEspNwS)						+"|"+;
			"cRegAtendim!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cRegAtdNwS)						+"|"+;
			"cSaudeOcupac!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cSaudOcNwS)						+"|"

		If !Empty(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cEspProf)
			cResult +=	 "cCbosExe!"   + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cEspProf)	+"|"
		Else
			cResult +=	 "cCbosExe!"   + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCodEsp)		+"|"
		EndIf

		cResult +=	"cIndAcid!"   + alltrim(oObj:OWSCARREGACONSULTARESULT:cIndAci)					+"|"+;
			"cTpCon!"     	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cTipCon)						+"|"+;
			"cCnpjCpfSol!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCpfCnpjRda)		+"|"+;
			"cNomeRdaSol!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cNomRda)			+"|"+;
			"cNomeSol!"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cNomProf)			+"|"+;
			"cCodSigSol!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cSigCr)				+"|"+;
			"cNumCrSol!"  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cNumCr)				+"|"+;
			"cEstSigSol!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cEstProf)			+"|"+;
			"cCbosSol!"   	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cEspProf)			+"|"+;
			"cOpeSol!"    	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cCodOpe)				+"|"+;
			"cIndCliSol!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cIndCli)						+"|"+;
			"cTpAteExe!"  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cTipAte)						+"|"+;
			"dDtSolicit!" 	+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:dDatSol))					+"|"+;
			"cTpSai!"     	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cTipSai)						+"|"+;
			"cTipCon!"    	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cTipCon)						+"|"+;
			"cCarSolicit!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cTipAdm)						+"|"+;
			"cVlOutDesp!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cVlOutS)						+"|"

		cResult +=	"dDtRlz!"		+ alltrim(iif(empty(oObj:OWSCARREGACONSULTARESULT:dDtRelS) , "", DToC(oObj:OWSCARREGACONSULTARESULT:dDtRelS)))  +"|"+;
			"dDtRlz2!"		+ alltrim(iif(empty(oObj:OWSCARREGACONSULTARESULT:dDtRelS2), "", DToC(oObj:OWSCARREGACONSULTARESULT:dDtRelS2))) +"|"+;
			"dDtRlz3!"		+ alltrim(iif(empty(oObj:OWSCARREGACONSULTARESULT:dDtRelS3), "", DToC(oObj:OWSCARREGACONSULTARESULT:dDtRelS3))) +"|"+;
			"dDtRlz4!"		+ alltrim(iif(empty(oObj:OWSCARREGACONSULTARESULT:dDtRelS4), "", DToC(oObj:OWSCARREGACONSULTARESULT:dDtRelS4))) +"|"+;
			"dDtRlz5!"		+ alltrim(iif(empty(oObj:OWSCARREGACONSULTARESULT:dDtRelS5), "", DToC(oObj:OWSCARREGACONSULTARESULT:dDtRelS5))) +"|"+;
			"dDtRlz6!"		+ alltrim(iif(empty(oObj:OWSCARREGACONSULTARESULT:dDtRelS6), "", DToC(oObj:OWSCARREGACONSULTARESULT:dDtRelS6))) +"|"+;
			"dDtRlz7!"		+ alltrim(iif(empty(oObj:OWSCARREGACONSULTARESULT:dDtRelS7), "", DToC(oObj:OWSCARREGACONSULTARESULT:dDtRelS7))) +"|"+;
			"dDtRlz8!"		+ alltrim(iif(empty(oObj:OWSCARREGACONSULTARESULT:dDtRelS8), "", DToC(oObj:OWSCARREGACONSULTARESULT:dDtRelS8))) +"|"+;
			"dDtRlz9!"		+ alltrim(iif(empty(oObj:OWSCARREGACONSULTARESULT:dDtRelS9), "", DToC(oObj:OWSCARREGACONSULTARESULT:dDtRelS9))) +"|"+;
			"dDtRlz1!"		+ alltrim(iif(empty(oObj:OWSCARREGACONSULTARESULT:dDtRelS1), "", DToC(oObj:OWSCARREGACONSULTARESULT:dDtRelS1))) +"|"

		If !Empty(oObj:OWSCARREGACONSULTARESULT:cObs)
			cResult +=	 "cObs!" + alltrim(oObj:OWSCARREGACONSULTARESULT:cObs)					+ "|"
		Else
			cResult +=	 "cObs!" + alltrim(oObj:OWSCARREGACONSULTARESULT:cMsg01+ " " +oObj:OWSCARREGACONSULTARESULT:cMsg02)+"|"
		EndIf

		If !Empty(oObj:OWSCARREGACONSULTARESULT:cProtoc)
			cResult +=	 "cProtoc!" + alltrim(oObj:OWSCARREGACONSULTARESULT:cProtoc)			+ "|"
		EndIf

		cResult += "cOriMov!"    + alltrim(oObj:OWSCARREGACONSULTARESULT:cOriMov)				+"|<"
		//-------------------------------------------------------------------
		//  Procedimentos Executados
		//-------------------------------------------------------------------
		For nI:=1 To Len(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS)
			//Executados
			nValor := ( (oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nVlrApr * ;
				oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd) )
			if (oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl > 0)
				nVlApr	:= (oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nVlrApr /;
					oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl)
			else
				nVlApr	:= (oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nVlrApr)
			EndIf

			cResult +="cTpServ!S@cExibe!S@"+;
				"cSeqMov!"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cSeqMov)			+"@"+;
				"cCodPad!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPad)			+"@"+;
				"cCodPro!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPro) 			+"@"+;
				"cDesPro!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cDesPro)	 		+"@"+;
				"nQtdSol!" 		+ AllTrim(STR(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd))		+"@"+;
				"nQtdAut!" 		+ AllTrim(STR(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd))		+"@"+;
				"nVlrApr!" 		+ AllTrim( TransForm( nVlApr,"@E 999,999,999.99" )) +"@"+;
				"cHorIni!" 		+ alltrim(transform(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cHorIni, "@R 99:99")) +"@"+;
				"cHorFim!" 		+ alltrim(transform(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cHorFim, "@R 99:99")) +"@"+;
				"cViaAc!"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodVia)  			+"@"+;
				"dDtExePro!" 	+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:dDtPro))			+"@"+;
				"cTecUt!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cTecUti)				+"@"+;
				"nRedAcre!"		+ AllTrim( TransForm( oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl,"@U 999,999,999.99" )) +"@"+;
				"cTpProc!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cTipProc)				+"@"+;
				"nVlrTAp!"		+ AllTrim( TransForm( nValor, "@E 999,999,999.99" ) ) +"~"

			cValGDExe :="cTpServ$S;cExibe$S;"+;
				"cSeqMov$"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cSeqMov)			+";"+;
				"cCodPadSExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPad)			+";"+;
				"cCodProSExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPro) 			+";"+;
				"cDesProSExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cDesPro)	 		+";"+;
				"cQtdSExe$" 	+ AllTrim(STR(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd))		+";"+;
				"nVlrUni$" 		+ AllTrim( TransForm( nVlApr,"@E 999,999,999.99" ) )											+";"+;
				"nVlrApr$" 		+ AllTrim( TransForm( nVlApr,"@E 999,999,999.99" ) )											+";"+;
				"nVlrUniSExe$" 	+ AllTrim( TransForm( nVlApr,"@E 999,999,999.99" ) )											+";"+;
				"dDtExe$" 	    + alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:dDtPro))		+";"+;
				"cHorIniSExe$"  + alltrim(transform(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cHorIni, "@R 99:99"))		+";"+;
				"cHorFimSExe$" 	+ alltrim(transform(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cHorFim, "@R 99:99"))		+";"+;
				"cViaSExe$"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodVia)  		+";"+;
				"cStatus$"		+ alltrim(Iif(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cStatus=='1','S','N'))		+";"+;
				"dDtExePro$" 	+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:dDtPro))		+";"+;
				"cTecSExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cTecUti) 			+";"+;
				'nRedAcreSExe$'	+ AllTrim( TransForm( oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl,"@U 999,999,999.99" ) )																				+";"+;
				"nVlrTotSExe$"	+ AllTrim( TransForm( nValor,"@E 999,999,999.99" ) )											+";"+;
				"nVlrTAp$" 		+ AllTrim( TransForm( nValor,"@E 999,999,999.99" ) )											+";"+;
				"nQtdUs$"		+ AllTrim(STR(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd))		+";"+;
				"cTpProc$" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cTipProc)			+";"+;
				"cVlrPro$" 		+ AllTrim( TransForm( nVlApr,"@E 999,999,999.99" ) )

			If !Empty(cValGDExe)
				PTrGdLib(cValGDExe,"TabExeSer")
			EndIf
		Next

		//GRID Executantes não será populada neste momento
		cResult += "|-|"
		For nI:=1 To Len(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7)
			cResult +="cTpServ!S@cExibe!S@nSeqRef!" 	 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSequen)			+"@"+;
				"cGraPartExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cGrPart)			+"@"+;
				"cCpfExe!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cDocPro)			+"@"+;
				"cProExe!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cCdProf)      	+"@"+;
				"cProExeDesc!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNomProf)      	+"@"+;
				"cCodSigExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSigCr) 			+"@"+;
				"cNumCrExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNumCr) 		+"@"+;
				"cEstSigExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cEstProf)		+"@"+;
				"cCbosExe!" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cEspProf) +"*" + oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNomEsp +"$"


			cValGDExe := "cTpServ$S;cExibe$S;nSeqRef$" 	 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSequen)	+";"+;
				"cGraPartExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cGrPart)			+";"+;
				"cCpfExe$" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cDocPro)			+";"+;
				"cProExe!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cCdProf)     	+";"+;
				"cProExeDesc$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNomProf)      	+";"+;
				"cCodSigExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSigCr) 			+";"+;
				"cNumCrExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNumCr) 			+";"+;
				"cEstSigExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cEstProf)		+";"+;
				"cCbosExe$" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cEspProf)		+ "*" + oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNomEsp +"$"

			If !Empty(cValGDExe)
				PTrGdLib(cValGDExe,"TabExe")
			EndIf
		Next
	EndIf

	//-------------------------------------------------------------------
	// Guia Odonto
	//-------------------------------------------------------------------
elseIf lOdonto
	if oObj:CarregaConsulta()

		//-------------------------------------------------------------------
		//  Cabecalho
		//-------------------------------------------------------------------
		cMatric := oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cOpeUsr
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cCodEmp
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cMatric
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cTipReg
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cDigito

		cResult +=	"cRegAns!"    + alltrim(oObj:OWSCARREGACONSULTARESULT:cRegAns)					+"|"+;
			"cNumPre!"    	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cNumImp)						+"|"+;
			"cNumeCart!"  	+ alltrim(cMatric)														+"|"+;
			"cAtendRN!"   	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cAteRna)			+"|"+;
			"cNomeUsu!"   	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cNomUsr)			+"|"+;
			"cCnpfCpfExe!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCpfCnpjRda)		+"|"+;
			"cCnes!"      	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCnes)				+"|"+;
			"cNomeRdaExe!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cNomRda)			+"|"+;
			"cCodSigExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cSigCr)				+"|"+;
			"cEstSigExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cEstProf)			+"|"+;
			"cNumCrExe!"  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cNumCr)				+"|"+;
			"cProExe!" 	  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cCdProf)			+"|"+;
			"cProExeDesc!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cNomProf)			+"|"+;
			"cIndAcid!"   	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cIndAci)						+"|"+;
			"cTpCon!"     	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cTipCon)						+"|"+;
			"cProSol!"    	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cCdProf)				+"|"+;
			"cProSolDesc!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cNomProf)			+"|"+;
			"cCodSigSol!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cSigCr)				+"|"+;
			"cNumCrSol!"  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cNumCr)				+"|"+;
			"cEstSigSol!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cEstProf)			+"|"+;
			"cCbosSol!"   	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cEspProf) + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cCodBAQ) +'$'+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cDesBAQ) + "|"+;
			"cOpeSol!"    	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFSOL:cCodOpe)				+"|"+;
			"dDtEmissao!" 	+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:dDatPro))					+"|"+;
			"cCnpjCpfExe!"	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSContExec:cCpfCnpjRda)		+"|"+;
			"cNumCrExe!"  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cNumCr)				+"|"+;
			"cEstSigExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cEstProf)			+"|"+;
			"cCbosExe!"   	+ Alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cEspProf + oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cCodBAQ) + "|"+;
			"cTpAto!"     	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cTipAto)						+"|"+;
			"cTpFat!"     	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cTipFat) 						+"|"+;
			"cObs!"       	+ Alltrim(oObj:OWSCARREGACONSULTARESULT:cObs)							+"|"+;
			"cNumAut!"	  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cNrlBor)				 		+"|"+;
			"dDtAut!"	  	+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:dDtAutO))		 			+"|"+;
			"cSenha!"	  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cSenha) 						+"|"+;
			"dDtValid!"	  	+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:dDtVldO))					+"|"+;
			"nVlrTot!"	  	+ AllTrim(TransForm(oObj:OWSCARREGACONSULTARESULT:nvalTotHon,"@E 999,999,999.99")) +"|"	+;
			"cExstSolic!" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:cProcLib) 						+"|"	+;
			"cOriMov!"    	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cOriMov)						+"|<"

		//Procedimentos Executados
		For nI:=1 To Len(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS)
			cResult += "cTpServ!S@cExibe!S@"+;
				"cSeqMov!"		+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cSeqMov)			+"@"+;
				"dDtExe!" 	   	+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:dDtPro))		+"@"+;
				"cCodPadSE!" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPad)			+"@"+;
				"cCodProSE!" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPro)			+"@"+;
				"cDesProSE!" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cDesPro)			+"@"+;
				"cQtdSE!" 		+ AllTrim(STR(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd))		+"@"+;
				"cViaSExe!"		+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodVia)			+"@"+;
				"cDenteReg!" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cDenReg) /*+ "-" + AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cDesReg)*/ +"@"+;
				"cFaceNova!"	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cFadent) /*+ "-" + AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cFacDes)*/ +"@"+;
				"nVlrUniSE!" 	+ AllTrim( TransForm( oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nVlrApr,"@E 999,999,999.99" ) )+"@"+;
				"nVlrTotSExe!" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPad)			+"@"+;
				"cStatus!"		+ Iif(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cStatus=='1','S','N') +"@"+;
				"cAutSE!" 		+ Iif(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cStatus=='1','S','N') +"~"
		Next
	EndIf
	//-------------------------------------------------------------------
	// Outras despesas
	//-------------------------------------------------------------------
elseif cTipGui == "12"

	oObj:cNumGuiRef := HttpGet->cNumGuiRef
	oObj:cTpGuiRef  := HttpGet->cTpGuiRef
	oObj:cRecGuiRef := HttpGet->cRecGuiRef

	if oObj:CarregaOutDesp()

		//-------------------------------------------------------------------
		//  Cabecalho
		//-------------------------------------------------------------------
		cResult += "cRegAns!"	  + alltrim(oObj:oWSCarregaOutDespResult:cRegAns)    +"|"+;
			"cGuiRef!"	  + alltrim(oObj:oWSCarregaOutDespResult:cNumGuiRef) +"|"+;
			"cCid!" 	  	  + alltrim(oObj:oWSCarregaOutDespResult:cCid)		  +"|"+;
			"cAteRn!" 	  + alltrim(oObj:oWSCarregaOutDespResult:cAteRn)     +"|"+;
			"cCodOpe!"	  + alltrim(oObj:oWSCarregaOutDespResult:oWSContExec:cCodRda) +"|"

		if HttpGet->cTpGuiRef == '5'
			cResult += "cDatIniFat!" 	+ alltrim(DTOC(oObj:oWSCarregaOutDespResult:ddtIniFat))     +"|"+;
				"cDatFimFat!"	  	+ alltrim(DTOC(oObj:oWSCarregaOutDespResult:ddtFimFat)) +"|"
		endif

		cResult += "cNomeRdaExe!" 	+ alltrim(oObj:oWSCarregaOutDespResult:oWSContExec:cNomRda) +"|"+;
			"cAutCnes!" 	 	+ alltrim(oObj:oWSCarregaOutDespResult:oWSContExec:cCnes)   +"|<"

		For nI:=1 To Len(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos)
			//Executados
			cResult +=		"cTpServ!E@cExibe!S@"
			cResult +=		"cSeqMov!"			+ alltrim(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cSeqMov)	+"@"
			cResult +=		"cCodDesp!"		+ alltrim(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cCodDes)	+"@"
			cResult +=		"dDtExe!"			+ alltrim(dToC(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:dDtPro))	+"@"
			cResult +=		"cHorIniSExe!"	+ alltrim( transform(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cHorIni, "@R 99:99"))	+"@"
			cResult +=		"cHorFimSExe!"	+ alltrim( transform(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cHorFim, "@R 99:99"))	+"@"
			cResult +=		"cCodPadSExe!"	+ alltrim( oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cCodPad )	+"@"
			cResult +=		"cCodProSExe!"	+ alltrim(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cCodPro)	+"@"
			cResult +=		"cQtdSExe!"		+ alltrim( str(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:nQtd))+"@"
			cResult +=		"cUnMedidaSExe!"+ alltrim( oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cUniMedida ) +"@"
			cResult +=		"nRedAcreSExe!"	+ alltrim( transform(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:nPrPrRl,"@U 999,999,999.99" ) )	+"@"
			cResult +=		"nVlrUniSExe!"	+ alltrim( transform( oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:nVlrApr,"@E 999,999,999.99" ) )	+"@"
			cResult +=		"nVlrTotSExe!"	+ alltrim( transform((oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:nVlrApr * oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:nQtd),"@E 999,999,999.99"))	+"@"
			cResult +=		"cRegAnvisa!"	+ alltrim( oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cRegAnvisa ) + "@"
			cResult +=		"cRefFabricante!"	+ alltrim( oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cRefMatFab ) + "@"
			cResult +=		"cAutFuncEmp!"	+ alltrim( oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cAutFun ) + "@"
			cResult +=		"cDesProSExe!"	+ alltrim(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cDesPro)	+"~"

			cValGDExe :=	"cTpServ$E;cExibe$S;"
			cValGDExe +=	"cSeqMov$"			+ alltrim(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cSeqMov)	+";"
			cValGDExe +=	"cCodDesp$"		+ alltrim(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cCodDes)	+";"
			cValGDExe +=	"dDtExe$"			+ alltrim(dToC(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:dDtPro))	+";"
			cValGDExe +=	"cHorIniSExe$"	+ alltrim(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cHorIni)	+";"
			cValGDExe +=	"cHorFimSExe$"	+ alltrim(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cHorFim)	+";"
			cValGDExe +=	"cCodPadSExe$"	+ alltrim( oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cCodPad )	+";"
			cValGDExe +=	"cCodProSExe$"	+ alltrim(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cCodPro)	+";"
			cValGDExe +=	"cQtdSExe$"		+ alltrim( str(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:nQtd))+";"
			cValGDExe +=	"cUnMedidaSExe$"+ alltrim( oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cUniMedida ) +";"
			cValGDExe +=	"nRedAcreSExe$"	+ alltrim( transForm(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:nPrPrRl,"@U 999,999,999.99" ) )	+";"
			cValGDExe +=	"nVlrUniSExe$"	+ alltrim( transForm( oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:nVlrApr,"@E 999,999,999.99" ) )	+";"
			cValGDExe +=	"nVlrTotSExe$"	+ alltrim( transForm((oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:nVlrApr * oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:nQtd),"@E 999,999,999.99"))	+";"
			cValGDExe +=	"cRegAnvisa$"	+ alltrim( oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cRegAnvisa ) + ";"
			cValGDExe +=	"cRefFabricante$"	+ alltrim( oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cRefMatFab ) + ";"
			cValGDExe +=	"cAutFuncEmp$"	+ alltrim( oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cAutFun ) + ";"
			cValGDExe +=	"cDesProSExe$"	+ alltrim(oObj:oWSCarregaOutDespResult:oWsProcedimentos:oWsProcedimentos[nI]:cDesPro)	+";"

			If !Empty(cValGDExe)
				PTrGdLib(alltrim(cValGDExe),"TabOutDesp")
			EndIf

		Next
		cResult := alltrim(cResult)
	Endif

	//-------------------------------------------------------------------
	// Guia Honorários
	//-------------------------------------------------------------------
elseif cTipGui == "6"
	If oObj:CarregaConsulta()

		//Matricula
		cMatric := oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cOpeUsr
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cCodEmp
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cMatric
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cTipReg
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cDigito

		//Numero da guia
		cNumGuia := oObj:OWSCARREGACONSULTARESULT:cCodOpe
		cNumGuia += oObj:OWSCARREGACONSULTARESULT:cAnoPag
		cNumGuia += oObj:OWSCARREGACONSULTARESULT:cMesPag
		cNumGuia += oObj:OWSCARREGACONSULTARESULT:cNumAut

		//Campos do cabeçalho - Dados da Guia
		cResult +=	"cRegAns!"    	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:cRegAns) +"|"+;
			"cGuiaInter!" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:cGuiPri) +"|"+;
			"cSenha!" 			+ AllTrim(oObj:OWSCARREGACONSULTARESULT:cSenha)  +"|"+;
			"cGuiaOpe!"		+ AllTrim(cNumGuia)+"|"

		if !empty(AllTrim(oObj:OWSCARREGACONSULTARESULT:cGuiPri))
			cResult += "cGuiaInter!" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:cGuiPri) +"|"
		else
			cResult += "cGuiaInter!" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:cNrlBor) +"|"
		endif

		cResult += "cNumMaxAux!" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:cNumAux) +"|"

		//Dados do beneficiário
		cResult += "cNumeCart!"		+ AllTrim(cMatric)+"|"+;
			"cNomeUsu!"		+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cNomUsr) +"|"+;
			"cAtendRN!"		+ IIF(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cAteRna=="0","2","1")+"|"

		//Dados do contratado
		cResult += "cCnpjCpfAut!"	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:cCnpjRdaInt) +"|"+;
			"cNomeRdaAut!"	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:cNomeRdaInt) +"|"+;
			"cCnesAut!"		+ AllTrim(oObj:OWSCARREGACONSULTARESULT:cCnesRdaInt) +"|"

		//Dados do contratado executante
		cResult += "cCnpjCpfExe!"	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCpfCnpjRda)+"|"+;
			"cNomeRdaExe!"	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCodRda)+"|"+;
			"cCnesExe!"		+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCnes)+"|"

		//Dados da internação
		cResult += "dDataIniFat!"	+ DTOC(oObj:OWSCARREGACONSULTARESULT:ddtIniFat) +"|"+;
			"dDadaFimFat!"	+ DTOC(oObj:OWSCARREGACONSULTARESULT:ddtFimFat) +"|"

		//Dados de assinatura e observações
		cResult += "nVlrTotHor!"	+ AllTrim(TransForm(oObj:OWSCARREGACONSULTARESULT:nvalTotHon,"@U 999,999,999.99")) +"|"
		cResult +=	 "cObs!" + AllTrim(oObj:OWSCARREGACONSULTARESULT:cObs) + "|"
		cResult += "dDtEmissao!"	+ DTOC(oObj:OWSCARREGACONSULTARESULT:dDtDigi) +"|<"

		//Procedimentos Executados
		For nI:=1 To Len(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS)

			nValor := ( (oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nVlrApr * ;
				oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd) )
			if (oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl > 0)
				nVlApr	:= (oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nVlrApr /;
					oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl)
			else
				nVlApr	:= (oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nVlrApr)
			EndIf

			cResult +="cTpServ!S@cExibe!S@"+;
				"cSeqMov!"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cSeqMov)							+"@"+;
				"cCodPad!" 		+ Alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPad)	+"@"+;
				"cCodPro!" 		+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPro) 	+"@"+;
				"cDesPro!" 		+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cDesPro)	+"@"+;
				"cQtd!" 			+ Alltrim(STR(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd))													+"@"+;
				"nQtdSol!" 		+ Alltrim(STR(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd))													+"@"+;
				"dDtAtend!" 	+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:dDtPro))					+"@"+;
				"cHorIni!" 		+ alltrim(transform(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cHorIni, "@R 99:99"))							+"@"+;
				"cHorFim!" 		+ alltrim(transform(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cHorFim, "@R 99:99"))							+"@"+;
				"cViaAc!"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodVia)							+"@"+;
				"cStatus!"		+ alltrim(Iif(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cStatus=='1','S','N')) 	+"@"+;
				"dDtExePro!" 	+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:dDtPro))					+"@"+;
				"cTecUt!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cTecUti)							+"@"+;
				'nRedAcreSExe!'	+ AllTrim( TransForm( oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl,"@U 9.99" ) )							+"@"+;
				'nVlrTAp!'		+ AllTrim( TransForm( nValor ,"@U 999,999,999.99" ) )	+"@"+;
				'nVlrUniSExe!'	+ AllTrim( TransForm( nVlApr,"@U 999,999,999.99" ) )+"@"+;
				"nVlrTotSExe!"	+ AllTrim( TransForm( nValor,"@U 999,999,999.99" ) )	+"@"+;
				"cSeqBD6!"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cSeqMov) 							+"@"+;
				"nVlrApr!" 		+ AllTrim( TransForm( nVlApr,"@U 999,999,999.99" ) )																		+"@"+;
				'nRedAcre!'	  	+ AllTrim( TransForm( oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl,"@U 9.99" ) )	+"~"

			cValGDExe :="cTpServ$S;cExibe$S;"+;
				"cSeqMov$"			+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cSeqMov)							+";"+;
				"cCodPadSExe$" 	+ Alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPad)	+";"+;
				"cCodProSExe$" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPro) 	+";"+;
				"cDesProSExe$" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cDesPro)	+";"+;
				"cQtdSExe$" 		+ Alltrim(STR(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd))	 												+";"+;
				"nVlrApr$" 		+ AllTrim( TransForm( nVlApr,"@U 999,999,999.99" ) )+";"+;
				"nVlrUniSExe$" 	+ AllTrim( TransForm( nVlApr,"@U 999,999,999.99" ) )	+";"+;
				"dDtExe$" 	    	+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:dDtPro))					+";"+;
				"cHorIniSExe$"  	+ alltrim(transform(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cHorIni, "@R 99:99"))				+";"+;
				"cHorFimSExe$" 	+ alltrim(transform(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cHorFim, "@R 99:99"))				+";"+;
				"cViaSExe$"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodVia)  						+";"+;
				"cStatus$"			+ alltrim(Iif(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cStatus=='1','S','N'))		+";"+;
				"dDtExePro$" 		+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:dDtPro))					+";"+;
				"cTecSExe$" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cTecUti)	   						+";"+;
				"nRedAcreSExe$"	+ AllTrim( TransForm( oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl,"@U 9.99" ) )				+";"+;
				"nVlrTotSExe$"	+ AllTrim( TransForm( nValor ,"@U 999,999,999.99" ) )																				+";"+;
				"nVlrTAp$" 		+ AllTrim( TransForm( nValor ,"@U 999,999,999.99" ) )																				+";"+;
				"nRedAcre$"	   	+ AllTrim( TransForm( oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl,"@U 9.99" ) )				+";"+;
				"cTecUt$" 			+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cTecUti)	   						+";"+;
				"nQtdUs$"			+ alltrim(STR(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd))	    				+";"+;
				"cVlrPro$" 		+ AllTrim( TransForm( nVlApr,"@U 999,999,999.99" ) )	+";"+;
				"cSeqBD6$"			+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cSeqMov) 							+";"


			If !Empty(cValGDExe)
				PTrGdLib(cValGDExe,"TabExeSer")
			EndIf
		Next

		//-------------------------------------------------------------------
		//GRID Executantes
		//-------------------------------------------------------------------
		cResult += "|-|"
		For nI:=1 To Len(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7)
			cResult +="nSeqRef!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSequen)			+"@"+;
				"cGraPartExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cGrPart)			+"@"+;
				"cCpfExe!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cDocPro)			+"@"+;
				"cProExe!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cCdProf) 			+"@"+;
				"cProExeDesc!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNomProf) 		+"@"+;
				"cCodSigExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSigCr) 			+"@"+;
				"cNumCrExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNumCr) 			+"@"+;
				"cEstSigExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cEstProf)			+"@"+;
				"cCbosExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cCbos)			+"@"+;
				"cSeqBD7!" 	 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSequen)			+"$"

			cValGDExe := "nSeqRef$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSequen)			+";"+;
				"cGraPartExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cGrPart)			+";"+;
				"cCpfExe$" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cDocPro)			+";"+;
				"cProExe$" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cCdProf) 			+";"+;
				"cProExeDesc$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNomProf)       	+";"+;
				"cCodSigExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSigCr) 			+";"+;
				"cNumCrExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNumCr) 			+";"+;
				"cEstSigExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cEstProf)			+";"+;
				"cCbosExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cCbos)			+";"+;
				"cSeqBD7$" 	 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSequen)			+ ";"

			If !Empty(cValGDExe)
				PTrGdLib(cValGDExe,"TabExe")
			EndIf
		Next
	EndIf

	//Guia de Resumo de Internação
Elseif cTipGui == "5"

	if oObj:CarregaConsulta()
		//-------------------------------------------------------------------
		//  Cabecalho
		//-------------------------------------------------------------------
		cMatric := oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cOpeUsr
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cCodEmp
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cMatric
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cTipReg
		cMatric += oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cDigito

		cNumGuia := oObj:OWSCARREGACONSULTARESULT:cCodOpe
		cNumGuia += oObj:OWSCARREGACONSULTARESULT:cAnoPag
		cNumGuia += oObj:OWSCARREGACONSULTARESULT:cMesPag
		cNumGuia += oObj:OWSCARREGACONSULTARESULT:cNumAut

		cResult +=	"cRegAns!"    + alltrim(oObj:OWSCARREGACONSULTARESULT:cRegAns)					+"|"+;
			"cNumAut!"    + alltrim(cNumGuia) 													+"|"+;
			"cNumPre!"    + alltrim(oObj:OWSCARREGACONSULTARESULT:cNumImp)					+"|"+;
			"cGuiaInter!" + AllTrim(oObj:OWSCARREGACONSULTARESULT:cNrlBor) +"|"+;
			"dDtAut!" 		+ alltrim(DTOC(oObj:OWSCARREGACONSULTARESULT:dDatPro)) 			+"|"+;
			"cSenha!" 		+ AllTrim(oObj:OWSCARREGACONSULTARESULT:cSenha)  +"|"+;
			"cGuiaOpe!"	+ AllTrim(cNumGuia)+"|"+;
			"cNumeCart!"  + alltrim(cMatric)													+"|"+;
			"cLibAte!"    + alltrim(oObj:OWSCARREGACONSULTARESULT:cLibAte)					+"|"+;
			"cAtendRN!"   + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cAteRna)	+"|"+;
			"cNomeUsu!"   + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cNomUsr)	+"|"+;
			"cVldCarteira!" + alltrim(DTOC(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:dValCar))+"|"+;
			"cNumInt!"    + alltrim(oObj:OWSCARREGACONSULTARESULT:cNrlBor)					+"|"+;
			"cCnpfCpf!"   + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCpfCnpjRda)+"|"+;
			"cCnes!"      + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCnes)		+"|"+;
			"cNomeRdaExe!"+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cNomRda)	+"|"+;
			"cCnpjCpfExe!"+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSContExec:cCpfCnpjRda)+"|"+;
			"cCodSigExe!" + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cSigCr)		+"|"+;
			"cEstSigExe!" + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cEstProf)	+"|"+;
			"cNumCrExe!"  + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cNumCr)		+"|"+;
			"cCid!"  		+ alltrim(oObj:OWSCARREGACONSULTARESULT:cCid)						+"|"+;
			"cCid2!"  		+ alltrim(oObj:OWSCARREGACONSULTARESULT:cCid2)					+"|"+;
			"cCid3!"  		+ alltrim(oObj:OWSCARREGACONSULTARESULT:cCid3)					+"|"+;
			"cCid4!"  		+ alltrim(oObj:OWSCARREGACONSULTARESULT:cCid4)					+"|"+;
			"cCidObt!"  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cCidObt)					+"|"+;
			"cNumDecVivo!"+ alltrim(oObj:OWSCARREGACONSULTARESULT:cNumDcViv)				+"|"+;
			"cNumDecObt!" + alltrim(oObj:OWSCARREGACONSULTARESULT:cNumDcObt)				+"|"+;
			"cRegInt!"  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cRegInt)					+"|"+;
			"cTipFat!"  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cTipFat)					+"|"+;
			"cNumCarSau!" + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cNumCNS) 	+"|"+;
			"cIndicRN!"  	+ alltrim(oObj:OWSCARREGACONSULTARESULT:cIndDORN)				+"|"+;
			"nTotGerGui!"	+ AllTrim(TransForm(oObj:OWSCARREGACONSULTARESULT:nvalTotHon,"@U 999,999,999.99")) +"|"+;
			"cObs!"  		+ AllTrim(oObj:OWSCARREGACONSULTARESULT:cMSG01)+"|"

		if(valtype(AllTrim(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cNomSoci)) == "C")
			cResult += "cNomeSocial!" +alltrim(oObj:OWSCARREGACONSULTARESULT:oWSDADBENEF:cNomSoci) +"|"	
		endif

		//Dados Faturamento
		cResult += "dDataIniFat!"	+ alltrim(DTOC(oObj:OWSCARREGACONSULTARESULT:ddtIniFat)) 	+"|"+;
			"dDataFimFat!"	+ alltrim(DTOC(oObj:OWSCARREGACONSULTARESULT:ddtFimFat)) 	+"|"+;
			"cHorIniFat!"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:cHrInicFat)			+"|"+;
			"cHorFimFat!"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:cHrFimcFat)			+"|"+;
			"cRegInter!"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:cRegInt)				+"|"+;
			"cTpIntern!"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:cTipIntR)			+"|"

		cResult += "cNumMaxAux!" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:cNumAux) +"|"

		If !Empty(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cEspProf)
			cResult +=	 "cCbosExe!"  + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROFEXEC:cEspProf)	+"|"
		Else
			cResult +=	 "cCbosExe!"  + alltrim(oObj:OWSCARREGACONSULTARESULT:oWSCONTEXEC:cCodEsp)	+"|"
		EndIf

		cResult +=	"cIndAcid!"   + alltrim(oObj:OWSCARREGACONSULTARESULT:cIndAci)					+"|"+;
			"cTpCon!"     + alltrim(oObj:OWSCARREGACONSULTARESULT:cTipCon)					+"|"+;
			"cTpAteExe!"  + alltrim(oObj:OWSCARREGACONSULTARESULT:cTipAte)					+"|"+;
			"cTpSai!"     + alltrim(oObj:OWSCARREGACONSULTARESULT:cTipSai)					+"|"+;
			"cTipCon!"    + alltrim(oObj:OWSCARREGACONSULTARESULT:cTipCon)					+"|"+;
			"cCarSolicit!"+ alltrim(oObj:OWSCARREGACONSULTARESULT:cTipAdm)					+"|"+;
			"cVlOutDesp!" + alltrim(oObj:OWSCARREGACONSULTARESULT:cVlOutS)					+"|"

		If !Empty(oObj:OWSCARREGACONSULTARESULT:cProtoc)
			cResult +=	 "cProtoc!" + alltrim(oObj:OWSCARREGACONSULTARESULT:cProtoc)		 		+ "|"
		EndIf

		cResult += "cOriMov!"     + alltrim(oObj:OWSCARREGACONSULTARESULT:cOriMov)				+"|<"
		//-------------------------------------------------------------------
		//  Procedimentos Executados
		//-------------------------------------------------------------------
		For nI:=1 To Len(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS)
			//Executados

			nValor := ( (oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nVlrApr * ;
				oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd) )
			if (oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl > 0)
				nVlApr	:= (oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nVlrApr /;
					oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl)
			else
				nVlApr	:= (oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nVlrApr)
			EndIf

			cResult +="cTpServ!S@cExibe!S@"+;
				"cSeqMov!"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cSeqMov)	+"@"+;
				"cCodPad!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPad)	+"@"+;
				"cCodPro!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPro)	+"@"+;
				"cDesPro!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cDesPro)	+"@"+;
				"nQtdSol!" 		+ AllTrim(STR(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd))+"@"+;
				"nQtdAut!" 		+ AllTrim(STR(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd))+"@"+;
				"nVlrApr!" 		+ AllTrim( TransForm( nVlApr,"@U 999,999,999.99" )) +"@"+;
				"cHorIni!" 		+ alltrim(transform(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cHorIni, "@R 99:99")) +"@"+;
				"cHorFim!" 		+ alltrim(transform(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cHorFim, "@R 99:99")) +"@"+;
				"cViaAc!"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodVia)	+"@"+;
				"dDtExePro!" 	+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:dDtPro))						+"@"+;
				"cTecUt!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cTecUti)	+"@"+;
				"nRedAcre!"		+ AllTrim( TransForm( oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl,"@U 999,999,999.99" )) +"@"+;
				"nVlrTAp!"		+ AllTrim( TransForm( nValor, "@U 999,999,999.99" ) ) +"~"

			cValGDExe :="cTpServ$S;cExibe$S;"+;
				"cSeqMov$"			+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cSeqMov)		+";"+;
				"cCodPadSExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPad)	+";"+;
				"cCodProSExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodPro) 		+";"+;
				"cDesProSExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cDesPro)	 	+";"+;
				"cQtdSExe$" 		+ AllTrim(STR(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd))+";"+;
				"nVlrUni$" 		+ AllTrim( TransForm( nVlApr,"@U 999,999,999.99" ) )+";"+;
				"nVlrApr$" 		+ AllTrim( TransForm( nVlApr,"@U 999,999,999.99" ) )+";"+;
				"nVlrUniSExe$" 	+ AllTrim( TransForm( nVlApr,"@U 999,999,999.99" ) )+";"+;
				"dDtExe$" 	    	+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:dDtPro))+";"+;
				"cHorIniSExe$"  	+ alltrim(transform(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cHorIni, "@R 99:99"))		+";"+;
				"cHorFimSExe$" 	+ alltrim(transform(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cHorFim, "@R 99:99"))		+";"+;
				"cViaSExe$"		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cCodVia)  								+";"+;
				"cStatus$"			+ alltrim(Iif(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cStatus=='1','S','N'))				+";"+;
				"dDtExePro$" 		+ alltrim(DToC(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:dDtPro))							+";"+;
				"cTecSExe$" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:cTecUti) +";"+;
				'nRedAcreSExe$'	+ AllTrim( TransForm( oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nPrPrRl,"@U 999,999,999.99" ) )+";"+;
				"nVlrTotSExe$"	+ AllTrim( TransForm( nValor,"@U 999,999,999.99" ) )+";"+;
				"nVlrTAp$" 		+ AllTrim( TransForm( nValor,"@U 999,999,999.99" ) )+";"+;
				"nQtdUs$"			+ AllTrim(STR(oObj:OWSCARREGACONSULTARESULT:oWSPROCEDIMENTOS:oWSPROCEDIMENTOS[nI]:nQtd))+";"+;
				"cVlrPro$" 		+ AllTrim( TransForm( nVlApr,"@U 999,999,999.99" ) )

			If !Empty(cValGDExe)
				PTrGdLib(cValGDExe,"TabExeSer")
			EndIf
		Next

		//GRID Executantes não será populada neste momento
		cResult += "|-|"
		For nI:=1 To Len(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7)
			cResult +="cTpServ!S@cExibe!S@nSeqRef!" 	 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSequen)	+"@"+;
				"cGraPartExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cGrPart)						+"@"+;
				"cCpfExe!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cDocPro)						+"@"+;
				"cProExe!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cCdProf)      				+"@"+;
				"cProExeDesc!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNomProf)      				+"@"+;
				"cCodSigExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSigCr) 						+"@"+;
				"cNumCrExe!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNumCr) 						+"@"+;
				"cEstSigExe!" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cEstProf)						+"@"+;
				"cCbosExe!" 		+ AllTrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cEspProf +"*" + oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNomEsp) +"$"


			cValGDExe := "cTpServ$S;cExibe$S;nSeqRef$" 	 + alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSequen)	+";"+;
				"cGraPartExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cGrPart)							+";"+;
				"cCpfExe$" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cDocPro)							+";"+;
				"cProExe!" 		+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cCdProf)      					+";"+;
				"cProExeDesc$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNomProf)      					+";"+;
				"cCodSigExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSigCr) 							+";"+;
				"cNumCrExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNumCr) 							+";"+;
				"cEstSigExe$" 	+ alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cEstProf)							+";"+;
				"cCbosExe$" 	+ AllTrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cEspProf	+ "*" + oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNomEsp) +"$"

			cRelacExc += alltrim(oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cCdProf + "&" +oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cSigCr + "&" + oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cNumCr + ;
				"&" + oObj:OWSCARREGACONSULTARESULT:OWSPROFISBD7:OWSSProfisBD7[nI]:cEstProf + "&*")
			If !Empty(cValGDExe)
				PTrGdLib(cValGDExe,"TabExe")
			EndIf
		Next
	EndIf
	cResult := cResult + "-&-" + cRelacExc

EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLITODE
Validação de itens(procedimentos) de outras despesas

@author  Karine Riquena Limp
@version P12
@since   01.07.2016
/*/
//-------------------------------------------------------------------
Web Function PPLITODE()

LOCAL nI	  	:= 0
LOCAL nQtd		:= 0
LOCAL nPos	  	:= 0
LOCAL nPosRDA   := 0
LOCAL cResult 	:= "true|"
LOCAL aMat 	  	:= {}
LOCAL oObj	  	:= Nil
LOCAL cString 	:= HttpGet->cString
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//-------------------------------------------------------------------
//  Pega o conteudo
//-------------------------------------------------------------------
If !Empty(cString)
	While ( nPos := At( "|", cString ) ) > 0
		AaDd( aMat,SubStr( cString, 1, nPos-1 ) )
		cString := SubStr( cString, nPos+1, Len(cString) )
	EndDo
EndIf
//-------------------------------------------------------------------
//   Verifica se foi enviado algum registro para tratamento
//-------------------------------------------------------------------
If Len(aMat) >= 2
	//-------------------------------------------------------------------
	//   Registro no WS
	//-------------------------------------------------------------------
	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )
	oObj:cUSERCODE := "MSALPHA"


	//-------------------------------------------------------------------
	//  Monta Matriz de itens ja executados
	//-------------------------------------------------------------------
	If Len(aMat) > 3

		oObj:oWSSAUTPROC:oWSAUTITEM := PLSXFUN_ARRAYOFAUTITEMVIEW():New()

		For nI:=3 To Len(aMat)
			If !Empty(aMat[nI])
				//-------------------------------------------------------------------
				//  Monta dados dos itens
				//-------------------------------------------------------------------
				aMatIte := PPLSALIMA(aMat[nI]+'||')
				//-------------------------------------------------------------------
				//  Alimenta a estrutura para envio dos procedimentos ja executados
				//-------------------------------------------------------------------
				AaDd( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW, PLSXFUN_AUTITEMVIEW():New() )
				//-------------------------------------------------------------------
				//  Quantidade de itens
				//-------------------------------------------------------------------
				nQtd := Len( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW )
				//-------------------------------------------------------------------
				//  Atribui dados ao obj
				//-------------------------------------------------------------------
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cCODPAD 				:= AllTrim( PPLSERGET('cCodPadSExe',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cPROCEDURECODE 		:= AllTrim( PPLSERGET('cCodProSExe',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:nPROCEDUREQUANTITY	:= Val( PPLSERGET('cQtdSExe',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cHORINI				:= AllTrim( PPLSERGET('cHorIniSExe',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cDENTE					:= ""
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cFACE					:= ""
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cSEQUENCE				:= aMat[1]
			EndIf
		Next
	EndIf
	//-------------------------------------------------------------------
	//   Rda
	//-------------------------------------------------------------------
	If ValType(HttpSession->RDAVIEW) == 'A'
		nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == HttpGet->cRda .And. x:cCodLoc == HttpGet->cCodLoc} )
	EndIf
	//-------------------------------------------------------------------
	//   Verifica RDA
	//-------------------------------------------------------------------
	If nPosRDA > 0
		//-------------------------------------------------------------------
		//   Parametros de envio
		//-------------------------------------------------------------------
		oObj:oWSSAUTPROC:cRda		:= HttpGet->cRDA
		oObj:oWSSAUTPROC:cCodLoc		:= HttpGet->cCodLoc
		oObj:oWSSAUTPROC:cOpeRda 	:= HttpSession->RDAVIEW[nPosRDA]:cCodOpe
		oObj:oWSSAUTPROC:cTipPre 	:= HttpSession->RDAVIEW[nPosRDA]:cTipPE
		oObj:oWSSAUTPROC:cRegAte 	:= HttpSession->RDAVIEW[nPosRDA]:cRegAtend
		oObj:oWSSAUTPROC:cMatric 	:= HttpSession->aVldCartao[2]
		oObj:oWSSAUTPROC:cCodExe		:= HttpGet->cRDA //mudar aqui para pegar o CODIGO DO PROFISSIONAL EXECUTANTE DA SADT/RESUMO
		oObj:oWSSAUTPROC:cCdpfSo 	:= ""
		oObj:oWSSAUTPROC:cTipGui 	:= StrZero( val(HttpGet->cTpGuiRef), 2)
		oObj:oWSSAUTPROC:cPadInt 	:= ""
		oObj:oWSSAUTPROC:cPadCon 	:= ""
		oObj:oWSSAUTPROC:cAreaAbr	:= HttpSession->aVldCartao[7]
		oObj:oWSSAUTPROC:dDatPro 	:= Date()
		oObj:oWSSAUTPROC:cHorPro 	:= HttpGet->cHorIniSExe
		oObj:oWSSAUTPROC:cSequen 	:= aMat[1]
		oObj:oWSSAUTPROC:cMatRet 	:= aMat[2]+"~"
		oObj:oWSSAUTPROC:cCodPad 	:= HttpGet->cCodPadSExe
		oObj:oWSSAUTPROC:cCodPro 	:= HttpGet->cCodProSExe
		oObj:oWSSAUTPROC:nQtdPro 	:= Val(HttpGet->cQtdSExe)
		oObj:oWSSAUTPROC:cCid	 	:= HttpGet->cCid
		oObj:oWSSAUTPROC:cAteRN 		:= HttpGet->cAteRN
		oObj:oWSSAUTPROC:cGrpInt 	:= ""
		oObj:oWSSAUTPROC:cDente  	:= ""
		oObj:oWSSAUTPROC:cFace  		:= ""
		oObj:oWSSAUTPROC:cChavLib	:= AllTrim(StrTran(StrTran(HttpGet->cNumGuiRef,".",""),"-",""))
		oObj:oWSSAUTPROC:cTipoProc	:= "E"
		oObj:oWSSAUTPROC:cCbos		:= ""
		oObj:oWSSAUTPROC:cEndCon		:= ""
		oObj:oWSSAUTPROC:cChvBD6		:= HttpGet->cChvBD6
		oObj:oWSSAUTPROC:cValorApr	:= HttpGet->cVlrUniSExe
		oObj:oWSSAUTPROC:cOutDesp	:= "1"
		//-------------------------------------------------------------------
		//  Executa o metodo pega o retorno
		//-------------------------------------------------------------------
		If oObj:AutProc()
			//-------------------------------------------------------------------
			//  Se foi autorizado ou negado
			//-------------------------------------------------------------------
			If oObj:oWSAUTPROCRESULT:lPROAUT
				cResult += "1|"
			Else
				cResult += "Critica(s)|"
			EndIf
			//-------------------------------------------------------------------
			//  Matriz que retorna os resultados formatados campo a campo do formulario
			//-------------------------------------------------------------------
			cResult += oObj:oWSAUTPROCRESULT:cMatRetRes+"|"
			//-------------------------------------------------------------------
			//  Monta a string de retorno
			//-------------------------------------------------------------------
			cResult += oObj:oWSAUTPROCRESULT:cAUTORI+"|"+;
				oObj:oWSAUTPROCRESULT:cCHAVE+"|"+;
				oObj:oWSAUTPROCRESULT:cNIVEL+"|"
			//-------------------------------------------------------------------
			//  Monta as criticas
			//-------------------------------------------------------------------
			For nI:=1 To Len(oObj:oWSAUTPROCRESULT:oWSMATCRI:oWSGenericStruct)
				cResult += 	oObj:oWSAUTPROCRESULT:oWSMATCRI:oWSGenericStruct[nI]:cCode+" - "+;//0
					oObj:oWSAUTPROCRESULT:oWSMATCRI:oWSGenericStruct[nI]:cDescription//1
			Next
			cResult += "|"

			If ValType(oObj:oWSAUTPROCRESULT:cLembrete) <> 'U'
				cResult += oObj:oWSAUTPROCRESULT:cLembrete+"|"
			EndIf

			For nI:=1 To Len(oObj:oWSAUTPROCRESULT:oWSALERTA:oWSGenericStruct)
				cResult += oObj:oWSAUTPROCRESULT:oWSALERTA:oWSGenericStruct[nI]:cCode+" - "+;//0
					oObj:oWSAUTPROCRESULT:oWSALERTA:oWSGenericStruct[nI]:cDescription//1
			Next

			If Len(oObj:oWSAUTPROCRESULT:oWSALERTA:oWSGenericStruct) > 0

				If !oObj:oWSAUTPROCRESULT:lPROAUT
					cResult += "| e Alerta(s)|"
				Else
					cResult += "|Alerta(s)|"
				EndIf

			EndIf

		Else
			cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
		EndIf
	Else
		cResult := "false|RDA invalida"
	EndIf
Else
	cResult := "false|Nenhum registro para tratamento"
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLGROUDES
Função que grava itens das outras despesas

@author  Karine Riquena Limp
@version P12
@since   06.07.2016
/*/
//-------------------------------------------------------------------
Web Function PPLGROUDES()
local cResult := "true|"
local aAddedItems		:= HttpPost->cAddedItems
local aDeletedItems 	:= HttpPost->cDeletedItems
local aEditedItems 	:= HttpPost->cEditedItems

local cNumGuiRef 		:= HttpPost->cNumGuiRef
local cTpGuiRef 		:= HttpPost->cTpGuiRef
local cRecGuiRef 		:= HttpPost->cRecGuiRef
local oObj				:= nil
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//-------------------------------------------------------------------
// Instância do Web Service
//-------------------------------------------------------------------
oObj := WSPLSGUIAS():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSGUIAS.APW" )

//-------------------------------------------------------------------
// Parametros de entrada	 do WebService
//-------------------------------------------------------------------
oObj:cUserCode		:= "MSALPHA"
oObj:cNumGuiRef		:= cNumGuiRef
oObj:cTpGuiRef		:= cTpGuiRef
oObj:cRecGuiRef		:= cRecGuiRef
oObj:cAddedItems		:= aAddedItems
oObj:cEditedItems		:= aEditedItems
oObj:cDeletedItems	:= aDeletedItems

if oObj:grvOutDes()
	cResult := oObj:cGrvOutDesResult
endIf

WEB EXTENDED END

return PLSDECODE(cResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLGRODO
Função que grava itens da guia odontologica quando é alteracao.

@author  Rodrigo Morgon
@version P12
@since   08.07.2016
/*/
//-------------------------------------------------------------------
Web Function PPLGRODO()

local oObj	  			:= NIL
local cResult 		:= "true|"
local cEditedCab		:= HttpPost->cCabecalhoEdited
local cAddedItems		:= HttpPost->cAddedItems
local cDeletedItems 	:= HttpPost->cDeletedItems
local cEditedItems 	:= HttpPost->cEditedItems
local cTipoConfirm	:= IIF(Valtype(HttpGet->cTipoConfirm)== "U", "", HttpGet->cTipoConfirm)
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//-------------------------------------------------------------------
// Instância do Web Service
//-------------------------------------------------------------------
oObj := WSPLSGUIAS():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSGUIAS.APW" )

//-------------------------------------------------------------------
// Parametros de entrada	 do WebService
//-------------------------------------------------------------------
oObj:cUserCode		:= "MSALPHA"
oObj:cAddedItems		:= cAddedItems
oObj:cEditedItems		:= cEditedItems
oObj:cDeletedItems	:= cDeletedItems
oObj:cEditedCab		:= cEditedCab
oObj:cRecno 			:= AllTrim(HttpGet->cRecno)
oObj:cTipoConfirm		:= cTipoConfirm

//-------------------------------------------------------------------
// Executa método para gravação da alteração
//-------------------------------------------------------------------
if oObj:GrvOdonto()
	cResult := oObj:cGrvOdontoResult
endIf

WEB EXTENDED END

return PLSDECODE(cResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLGRSADT
Função que grava itens da guia sadt quando é alteracao.

@author  Karine Riquena Limp
@version P12
@since   26.08.2016
/*/
//-------------------------------------------------------------------
Web Function PPLGRSADT()

local oObj	  			:= NIL
local cResult 			:= "true|"
local cEditedCab		:= HttpPost->cCabecalhoEdited
local cAddedItems		:= HttpPost->cAddedItems
local cDeletedItems 	:= HttpPost->cDeletedItems
local cEditedItems 		:= HttpPost->cEditedItems
local cTipoConfirm		:= IIF(Valtype(HttpGet->cTipoConfirm)== "U", "", HttpGet->cTipoConfirm)
LOCAL cHtml 			:= ""
WEB EXTENDED INIT cHtml START "InSite"

//-------------------------------------------------------------------
// Instância do Web Service
//-------------------------------------------------------------------
oObj := WSPLSGUIAS():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSGUIAS.APW" )

//-------------------------------------------------------------------
// Parametros de entrada	 do WebService
//-------------------------------------------------------------------
oObj:cUserCode			:= "MSALPHA"
oObj:cAddedItems		:= cAddedItems
oObj:cEditedItems		:= cEditedItems
oObj:cDeletedItems		:= cDeletedItems
oObj:cEditedCab			:= cEditedCab
oObj:cRecno 			:= AllTrim(HttpGet->cRecno)
oObj:cTipoConfirm		:= cTipoConfirm //Z

//-------------------------------------------------------------------
// Executa método para gravação da alteração
//-------------------------------------------------------------------
if oObj:GrvSADT()
	cResult := oObj:cGrvSADTResult
endIf

WEB EXTENDED END

return PLSDECODE(cResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLGRHON
Função que grava itens da guia de honorários quando é alteracao.

@author  Karine Riquena Limp
@version P12
@since   26.08.2016
/*/
//-------------------------------------------------------------------
Web Function PPLGRHON()

local oObj	  			:= NIL
local cResult 		:= "true|"
local cEditedCab		:= HttpPost->cCabecalhoEdited
local cAddedItems		:= HttpPost->cAddedItems
local cDeletedItems 	:= HttpPost->cDeletedItems
local cEditedItems 	:= HttpPost->cEditedItems
local cAddedExec 		:= HttpPost->cAddedExec
local cDeletedExec 	:= HttpPost->cDeletedExec
local cTipoConfirm	:= IIF(Valtype(HttpGet->cTipoConfirm)== "U", "", HttpGet->cTipoConfirm)

local cTipGui			:= IIF(Valtype(HttpGet->cTipGui)== "U", "", HttpGet->cTipGui)

local cNumGuiRes    	:= IIF(Valtype(HttpGet->cNumGuiRes)== "U", "", HttpGet->cNumGuiRes)
local cNumGuiRef    	:= IIF(Valtype(HttpGet->cNumGuiRef)== "U", "", HttpGet->cNumGuiRef)

LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//-------------------------------------------------------------------
// Instância do Web Service
//-------------------------------------------------------------------
oObj := WSPLSGUIAS():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSGUIAS.APW" )

//-------------------------------------------------------------------
// Parametros de entrada	 do WebService
//-------------------------------------------------------------------
oObj:cUserCode		:= "MSALPHA"
oObj:cEditedCab		:= cEditedCab
oObj:cAddedItems		:= cAddedItems
oObj:cEditedItems		:= cEditedItems
oObj:cDeletedItems	:= cDeletedItems
oObj:cAddedExec		:= cAddedExec
oObj:cDeletedExec		:= cDeletedExec
oObj:cRecno 			:= AllTrim(HttpGet->cRecno)
oObj:cTipoConfirm		:= cTipoConfirm //Z
oObj:cTipGui			:= cTipGui //Z
oObj:cNumGuiRes			:= cNumGuiRes //Z
oObj:cNumGuiRef			:= cNumGuiRef //Z

//-------------------------------------------------------------------
// Executa método para gravação da alteração
//-------------------------------------------------------------------
if oObj:GrvHON()
	cResult := oObj:cGrvHONResult
endIf

WEB EXTENDED END

return PLSDECODE(cResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLGRDEX
Atualiza grid de executantes sempre que um procedimento é excluido e tem executantes vinculados a ele

@author  Karine Riquena Limp
@version P12
@since   01.11.2016
/*/
//-------------------------------------------------------------------
Web Function PPLGRDEX()
local cResult     := "true|"
local cLinhas     := ""
local cSeqDelExec := httpget->cSeqDelExec
local cGrid	    := "TabExe"
local nPos        := 0
local nPosGrd     := 0
local nI          := 1
local nJ          := 1
local nQtdReg     := 1
local nQtdPag     := 1
local nRegPagina  := 1
local nNumAux     := 0
local nLen        := 0
local nLenHeader  := 0
local nLenCols    := 0
local aHeader     := {}
local aCols       := {}
LOCAL xHeader     := "[{}]"
local xCols       := ""
LOCAL 	cHtml := ""
local cfim			:= ""
WEB EXTENDED INIT cHtml START "InSite"

//-------------------------------------------------------------------
//Encontra o grid na session
//-------------------------------------------------------------------
nPosGrd := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid } )

If nPosGrd > 0

	aHeader	:= HttpSession->aCmpGuia[nPosGrd]:OWSAHEADER:CSTRING
	aCols		:= HttpSession->aCmpGuia[nPosGrd]:OWSACOLS:CSTRING

	//-------------------------------------------------------------------
	//Verifica se o aCols e aHeader estão vazios
	//-------------------------------------------------------------------
	If ValType(aHeader) <> 'A'
		aHeader := {}
		HttpSession->aCmpGuia[nPosGrd]:OWSAHEADER:CSTRING := {}
	EndIf

	If ValType(aCols) <> 'A'
		aCols := {}
		HttpSession->aCmpGuia[nPosGrd]:OWSACOLS:CSTRING := {}
	EndIf

	nLenCols := Len(aCols)

	xCols += "[{"

	while nI <= nLenCols

		nPos := aScan(aHeader[nI], {|x| x == "nSeqRef"})
		if  nPos > 0 .and. aCols[nI][nPos] == cSeqDelExec
			aDel(aCols,nI)
			aSize(aCols,Len(aCols)-1)
			aDel(aHeader,nI)
			aSize(aHeader,Len(aHeader)-1)
			nLenCols := Len(aCols)
			nI = iif(nLenCols > 0, nI - 1, nI)
		else

			nPos := aScan(aHeader[nI], {|x| x == "nSeqRef"})
			if  nPos > 0 .and. val(aCols[nI][nPos]) > val(cSeqDelExec)
				aCols[nI][nPos] := strZero((val(aCols[nI][nPos])-1),3)
			endIf

			nNumAux := -1
			nNumAux++
			xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'0#" + AllTrim(Str(nI)) + "," + cGrid + ".id,2'}," //Botão Alterar

			nNumAux++
			xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'1#" + AllTrim(Str(nI)) + "," + cGrid + ".id,5,true," + '""' + " ," + '""' + " ,cCampoDefault,true,true,false'}," //Botão Excluir

			nLenHeader := Len(aHeader[nI])-1
			For nJ := 1 to nLenHeader
				nNumAux++
				xCols += cValToChar(nNumAux) + ":{field:'"+ aHeader[nI][nJ]+ "', value:'" + aCols[nI][nJ] + "'} " + Iif( nLenHeader != nJ ,",","}" )
			Next nJ

			xCols += Iif( nLenCols != nI ,",{","]" )
		endIf

		nI++

	endDo

	//se não tem nenhum executante restante
	if xCols == "[{"
		xCols := ""
	elseif RIGHT(xCols, 1) <> "]"
		xCols += "]"
	endIf

	nQtdReg		:= 1
	nQtdPag 		:= 1
	nRegPagina 	:= 1

	if right(xCols,3) == ",{]"
		cfim := len(xCols)
		xCols := substr(xCols, 1, (cfim - 3)) + "]"
	endif

	//Indica que a linha deve ser marcada
	nLenCols := len(aCols)
	nLen     := len(HttpSession->aCmpGuia[nPosGrd]:OWSCMPGRID:OWSSCMPGRID)
	For nI := 1 to nLenCols
		If aCols[nI][nLen+1] <> "1"
			cLinhas += AllTrim(str(nI))+"&"
		EndIf
	Next nI

	//Verifica se não houve problemas na montagem e caso haja, fecha o xHeader
	If RAT(xHeader,",") == 0
		xHeader := Left(xHeader,Len(xHeader)-1)+"]"
	EndIf

	HttpSession->aCmpGuia[nPosGrd]:CXHEADER := iif(len(aCols) <= 0,xHeader,HttpSession->aCmpGuia[nPos]:CXHEADER)
	HttpSession->aCmpGuia[nPosGrd]:CXCOLS   := xCols
	HttpSession->aCmpGuia[nPosGrd]:OWSAHEADER:CSTRING := aClone(aHeader)
	HttpSession->aCmpGuia[nPosGrd]:OWSACOLS:CSTRING := aClone(aCols)

	cResult := "true|" +;
		cValToChar(nI-1) + "|" + ;
		cValToChar(nQtdPag) + "|" + ;
		cValToChar(nRegPagina) + "|" + ;
		xHeader + "|" +	;
		xCols + "|" + ;
		"" + "|" + ;
		"true" + "|" + ;
		"1" + "|" + ;
		"" + "|" + ;
		"true" + "|" + ;
		cGrid + "|" + ;
		"5" + "|" +;
		"" + "|" +;
		"true" + "|" +;
		"" + "|" +;
		cLinhas + "|"+;
		"true" + "|"+;
		"true" + "|"+;
		"false" + "|"+;
		"" + "|"+;
		"" + "|"+;
		"000" + "|"

Else

	cResult := "false|Não foi encontrado o grid especificado!"

EndIf

WEB EXTENDED END

return PLSDECODE(cResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLVLDEX
Função que valida a inclusão de executante na guia.

@author  Francisco Edcarlo
@version P12
@since   17.02.2017
/*/
//-------------------------------------------------------------------
Web Function PPLVLDEX()

local oObj	  			:= NIL
local cResult 		:= "true|"
local nRecno			:= HttpGet->nRecno
local cTable			:= HttpGet->cTable
local nOpc				:= HttpGet->nOpc
local cCodPad			:= HttpGet->cCodPad
local cCodPro			:= HttpGet->cCodPro
local dDatPro			:= HttpGet->dDatPro
local cCodRda			:= HttpGet->cCodRda
local cCodEsp			:= HttpGet->cCodEsp
local cGrPart			:= HttpGet->cGrPart
local nQtGrPart		:= HttpGet->nQtGrPart
local cCodLoc		:= HttpGet->cCodLoc
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//-------------------------------------------------------------------
// Instância do Web Service
//-------------------------------------------------------------------
oObj := WSPLSGUIAS():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSGUIAS.APW" )

//-------------------------------------------------------------------
// Parametros de entrada	 do WebService
//-------------------------------------------------------------------
oObj:cUserCode		:= "MSALPHA"

oObj:oWSExecutante	:= PLSGUIAS_SEXECUTANTE():New()
oObj:oWSExecutante:oWSProfissional	:= PLSGUIAS_SProfisBD7():New()
oObj:oWSExecutante:oWSProcedimento	:= PLSGUIAS_Procedimentos():New()
oObj:oWSExecutante:cCodRda := cCodRda
oObj:oWSExecutante:cQtGrPart := nQtGrPart
oObj:oWSExecutante:cCodLoc := cCodLoc


oObj:oWSExecutante:oWSProfissional:cCbos := cCodEsp
oObj:oWSExecutante:oWSProfissional:cGrPart := cGrPart

oObj:oWSExecutante:oWSProcedimento:cCodPad := cCodPad
oObj:oWSExecutante:oWSProcedimento:cCodPro := cCodPro
oObj:oWSExecutante:oWSProcedimento:dDtPro := ctod(dDatPro)

//-------------------------------------------------------------------
// Executa método para validação de executante
//-------------------------------------------------------------------
oObj:VldExe()
if Empty(oObj:cVldExeResult)
	cResult := "true|"+nRecno+"|"+cTable+"|"+nOpc
else
	cResult := "true|grau_invalido|" + oObj:cVldExeResult
endIf

WEB EXTENDED END

return PLSDECODE(cResult)


//-------------------------------------------------------------------
/*/{Protheus.doc} PPLObsAudA
Web Function para retornar dados das observações realizadas pelo auditor (B53 e B72).
@version P12
@since   12/2021
/*/
//-------------------------------------------------------------------
Web Function PPLObsAudA()

lOCAL cHtml 	:= ""
local cResult 	:= "true|"

WEB EXTENDED INIT cHtml START "InSite"

//Web Service						
oObj := WSPLSGUIAS():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSGUIAS.APW" )

oObj:cUSERCODE 			:= "MSALPHA"
//Parametros de entrada			
oObj:oWSDadGuiAud:cALIMOV		:= HttpGet->cAlias
oObj:oWSDadGuiAud:cANOAUT 		:= HttpGet->cAnoAut
oObj:oWSDadGuiAud:cCODOPE 		:= HttpGet->cCodOpe
oObj:oWSDadGuiAud:cMESAUT		:= HttpGet->cMesAut
oObj:oWSDadGuiAud:cNUMAUT		:= HttpGet->cNumAut
oObj:oWSDadGuiAud:cSEQPROC		:= HttpGet->cSeqProc

if oObj:GetObsAudito()
	cResult += oObj:cGETOBSAUDITORESULT
else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
endif

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)
