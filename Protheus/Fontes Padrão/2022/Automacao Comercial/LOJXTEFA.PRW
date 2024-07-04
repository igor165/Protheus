#INCLUDE "DEFECF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJXTEFA.CH"


Function LOJXTEFA ; Return  	// "dummy" function - Internal Use 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJACENTPAG       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse abstrata, que realiza integracao com CP (Tef do Mexico )	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJACENTPAG
   			
	Data oTotvsAPI				//Objeto do tipo LJCTotvsAPI
	Data oMensagens				//Objeto do tipo LJCMensagensECF
	Data lAtivo					//Objeto do tipo LJCMensagensECF
	Data lTefOk					//Objeto do tipo LJCMensagensECF
	Data cVoucher				//Voucher para Impressao
	Data aReb					//Dados para tr
	Data aRetCartao				//Retorno das Tr's, para impressใo
	Data nNumOp					//Numero de Operacao
	Data cData					//Data
	Data nTrans					//Transacao
	Data nValTr					//Vlr da Tr
	Data cBs_User  				//Usuario 	
	Data cBs_Pwd               	//Senha Usuario
	Data cBs_UsrTransaction 	//Usuario Transacio 
	Data cBs_Company  			//Comanhia
	Data cBs_Branch  			//N filial
	Data cBs_Country 			//Pais
	Data cCc_Type  				//Tipo
	Data cTx_Merchant          	//Filial 
	Data cTx_Reference			//Referencia
	Data cTx_OperationType 		//Tipo de Operacao
	Data cTx_Currency  			//Moeda
	Data cTxtCvvAmex 			//Codigo de Seguranca 
	Data cSetURL				//eNDEREวO DO servidor
	
	Method New(oTotvsAPI)									
	Method EnviarCom(oParams)								
	Method PrepParam(aDados)                              	
	Method TratarRet(cRetorno)    							
	Method Operacoes(aReb)
	Method PrpStaTrn()									
	Method GetInfCard()	
	Method EnvVend()
	Method FechaTrn()
	Method CloseTef()
	Method ImpCupTef()
	Method EnvCan()
	Method LimpaTef()
	Method CancPend()
	Method EnvRee()
	Method ImpCupAdm()
EndClass


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew   	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LJAEcf.       			    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1 (1 - oTotvsAPI) - Objeto do tipo LJCTotvsApi.    			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New() Class LJACentPag

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	
	::oTotvsAPI 	:= LJCTotvsApi():New()	
	::oTotvsAPI:AbrirCom()

	::cBs_User  			:= AllTrim(LjGetStation("LG_USERCP"))	//Usuario 	
	::cBs_Pwd              	:= AllTrim(LjGetStation("LG_PWDCP"))	//Senha Usuario
	::cBs_UsrTransaction 	:= AllTrim(LjGetStation("LG_USERCP"))	//Usuario Transacio 
	::cBs_Company  			:= AllTrim(LjGetStation("LG_COMPANY"))	//Comanhia
	::cBs_Branch  			:= AllTrim(LjGetStation("LG_BRANCH"))	//N filial
	::cBs_Country 			:= AllTrim(LjGetStation("LG_COUNTRY"))	//Pais
	::cTx_Merchant         	:= AllTrim(LjGetStation("LG_MERCHAN"))	//Filial 
	::cTx_OperationType 	:= AllTrim(LjGetStation("LG_OPTYPE"))	//Tipo de Operacao
	::cTx_Currency  		:= AllTrim(LjGetStation("LG_CURRENC"))	//Moeda
	
	::cSetURL 			:= AllTrim(LjGetStation("LG_SETURL"))						//Codigo de Seguranca 	
	::cTx_Reference		:= "REF"										//Referencia
	
	oParams		:= ::PrepParam({"7","PutdbgSetUrl", ::cSetURL , "0"}) 	
	
	cRetorno 	:= ::EnviarCom(oParams)        
	
	oParams		:= ::PrepParam({"7","GetdbgSetUrl"}) 		
	cRetorno 	:= ::EnviarCom(oParams)        
   	
	oParams		:= ::PrepParam({"7","dbgSetCommPort", "", "1"}) 		
	cRetorno 	:= ::EnviarCom(oParams)           	
    
	If !Empty(SLG->LG_LOGTEF)
	 	::CancPend()		
	EndIf 	
	
	::LimpaTef()

Return Self
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณEnviarCom	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em enviar o comando para TotvsApi.dll/so.	    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1 (1 - oParams) - Objeto do tipo LJCParamsApi.				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EnviarCom(oParams) Class LJACentPag
	
	Local cRetorno 	:= ""	//Retorno do metodo
	
	cRetorno := ::oTotvsAPI:EnviarCom(oParams)
	
Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณPrepParam	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em preparar os parametros de envio para TotvsApi.dll/soบฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPA1 (1 - aDados) - Array com os parametros.     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method PrepParam(aDados) Class LJACentPag
	
	Local oParams 	:= Nil		//Objeto do tipo LJCParamsAPI
	Local oParam 	:= Nil     	//Objeto do tipo LJCParamAPI
	Local nCount	:= 0       // Contador
	
	oParams := LJCParamsAPI():New()
	
	For nCount := 1 To Len(aDados)
		
		oParam := LJCParamAPI():New(aDados[nCount])
		
		oParams:ADD(nCount, oParam)
	Next
	
Return oParams

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณPrpStaTrn	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvia trasacao ao servidor                                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPA1 (1 - aDados) - Array com os parametros.     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNil               											     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method PrpStaTrn(aReb) Class LJACentPag

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	
	::lTefOk := .T.
	::cVoucher 	:= ""
	::nValTr	:= aReb[2]
	
	oParams		:= ::PrepParam({"7","dbgStartTxEMV", cValToChar(aReb[2])}) 		
	       	
	LjTefMsRun( STR0022	,; // "Passe ou insira o cartใo no leitor (Pin-Pad)"
				PADL(STR0023, 20) 	+"  "+aReb[8]	,;  // "Administradora:"
				PADL(STR0024, 20) 	+"  "+AllTrim(Transform(aReb[2],PesqPict("SE1","E1_VALOR"))),; // "Valor Transa็ใo:"
				STR0025 , { || cRetorno 	:= ::EnviarCom(oParams)  } )  // "Centro de Pagamentos"
 	                                
	If !Empty(cRetorno)
		MsgAlert(STR0026 + cRetorno + chr(13) +; 
				STR0027	) //"Retorno Pinpad: "  "Verifique configura็๕es na cadastro de esta็๕es: "
    	oTef:lTefOk := .F.
  	EndIf
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณGetInfCard	   บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca Informa็๕es													 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNil           												     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetInfCard() Class LJACentPag
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
    Local cMsg		:= STR0001 + Chr(10)+Chr(13) // "Identicica็ใo"

	oParams		:= ::PrepParam({"7","GetchkCc_Number"}) 		
	cRetorno 	:= ::EnviarCom(oParams)           	
	
	If !Empty(cRetorno) 
	
		cMsg		+= cRetorno + Chr(13)
		
		oParams		:= ::PrepParam({"7","GetchkCc_Name"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           	
		cMsg		+= cRetorno + Chr(13)
	
	
		oParams		:= ::PrepParam({"7","GetchkCc_ExpMonth"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           	
		cMsg		+= cRetorno + Chr(13)
		
		oParams		:= ::PrepParam({"7","GetchkCc_ExpYear"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           	
		cMsg		+= cRetorno + Chr(13)
	
		MsgAlert(cMsg)
    Else
    	::lTefOk := .F.
    EndIf
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณPrepParam	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em preparar os parametros de envio para TotvsApi.dll/soบฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPA1 (1 - aDados) - Array com os parametros.     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EnvVend() Class LJACentPag
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	
	
	::cCc_Type 		:= "V/MC"
	::cTxtCvvAmex 	:= AllTrim(LjGetStation("LG_SERIE"))		//Codigo de Seguranca 	
	
	oParams		:= ::PrepParam({"7","sndVtaDirectaEMV", ::cBs_User, ::cBs_Pwd, ::cBs_User, ::cBs_Company, ::cBs_Branch, ::cBs_Country, ::cCc_Type, ::cTx_Merchant , ::cTx_Reference, ::cTx_OperationType, ::cTx_Currency ,"","0","0" }) 		
	
	cRetorno 	:= ::EnviarCom(oParams)           		
	::lTefOk := .T.

Return(.T.)                                                       	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFechaTrn	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFechar e grava informacoes do CP									 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPA1 (1 - aDados) - Array com os parametros.     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FechaTrn() Class LJACentPag
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local cMsg 		:= ""			//Mensagem
	Local cNumOp    := ""      		//Numero de Operacao
	Local cAuth    	:= ""			//Autori
	Local nPos		:= 0			//Posicao retorno do cartao 				

	oParams		:= ::PrepParam({"7","getRspDsResponse"}) 		
	cRetorno 	:= ::EnviarCom(oParams)           	
	
	If cRetorno == "error"
		oParams		:= ::PrepParam({"7","getRspDsError"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           			
		cMsg 		+=	cRetorno + Chr(10)+Chr(13)	

		oParams		:= ::PrepParam({"7","getRspCdError"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           			
		cMsg 		+=	STR0002 + cRetorno // "C๓digo erro: "
		::lTefOk := .F.
		MsgAlert(cMsg)	
		::CloseTef()
	ElseIf cRetorno == "approved"	

		oParams		:= ::PrepParam({"7","getRspDsResponse"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           			
		cMsg 		+=	cRetorno + Chr(10)+Chr(13)		

		oParams		:= ::PrepParam({"7","getRspOperationNumber"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           			
		cMsg 		+=	STR0003 + cRetorno + Chr(10)+Chr(13) // "Numero de Opera็ใo: "
		cNumOp		:= cRetorno
		
		oParams		:= ::PrepParam({"7","getRspAuth"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           			
		cMsg 		+=	STR0004 + cRetorno + Chr(10)+Chr(13) // "Numero da Autoriza็ใo: "
	    cAuth		:= cRetorno

		RecLock("SLG",.F.)
		SLG->LG_LOGTEF :=  AllTrim(SLG->LG_LOGTEF)  +  cAuth + "|" + cNumOp + "|" + cValToChar(::nValTr) + Chr(10)
		SLG->(MsUnLock())						

		MsgAlert(cMsg)	

		oParams		:= ::PrepParam({"7","getRspVoucher"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           			
    	::cVoucher 	:= cRetorno
		Aadd(::aRetCartao,		{})
		nPos := Len(::aRetCartao)
		If Len(::aRetCartao)>0
			::aRetCartao[Len(::aRetCartao)] := MSRetCartao():New()
		Else
			::aRetCartao[1] := MSRetCartao():New()		 
		EndIf
		oTef:aRetCartao[nPos]:cNsuAutor    	:= cNumOp 	// Numero de Opera็ใo
		oTef:aRetCartao[nPos]:cAutoriza    	:= cAuth	// Numero da Autoriza็ใo
		oTef:aRetCartao[nPos]:cDescAdm     	:= ""   // 
		oTef:aRetCartao[nPos]:cCupom01		:= ::cVoucher
		::lTefOk := .T.
	Else 
		cMsg := cRetorno + Chr(10)+Chr(13)	
		
		oParams		:= ::PrepParam({"7","getRspDsError"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           			
		cMsg 		+=	cRetorno + Chr(10)+Chr(13)	

		oParams		:= ::PrepParam({"7","getRspCdError"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           			
		cMsg 		+=	STR0005 + cRetorno // "C๓digo erro: "
		::lTefOk := .F.
		MsgAlert(cMsg)	
		::CloseTef()		
	EndIf	

Return(cRetorno)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณCloseTef	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFechar CP                                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNil           												     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CloseTef() Class LJACentPag 
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial	
	
	oParams		:= ::PrepParam({"7","dbgEndOperation"}) 		
	cRetorno 	:= ::EnviarCom(oParams)           			
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณImpCupAdm	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprimi cupom Tef                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ImpCupAdm() Class LJACentPag 
    
    Local cTexto 		:= ""		// a ser impresso
	Local oParams		:= ::PrepParam({"7","getRspVoucher"}) // armazena parametro a serem enviados
	Local cRetorno 		:= ::EnviarCom(oParams)           			// retorno da totvs api
	
	cTexto := LjxFormTxt(cRetorno)	
	IFTxtNFis(nHdlEcf, cTexto, 1 )
	::LimpaTef()

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณImpCupTef	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprimi cupom Tef                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ImpCupTef() Class LJACentPag 

    Local nFor := 0				// Contador
	Local cTickForm := ""       // Retorno do Voucher
	
	If ValType(oTef:aRetCartao) == "A"
		For nFor := 1 To Len(oTef:aRetCartao)
			If !Empty(oTef:aRetCartao[nFor]:cCupom01)
				cTickForm += oTef:aRetCartao[nFor]:cCupom01 + Chr(10)
			EndIf
		Next nFor
	EndIf

	cTexto := cTickForm
	cTexto := LjxFormTxt(cTickForm)	
	IFTxtNFis(nHdlEcf, cTexto, 1 )
	::LimpaTef()

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณLimpaTef	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em reniciar propriedades 								 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LimpaTef() Class LJACentPag 
	::aRetCartao 	:= {}
	::lAtivo 		:= .T.
	::lTefOk 		:= .T.
	::cVoucher 		:= ""
	::cData			:= dtos(dDatabase)	
	::nTrans		:= 1
	RecLock("SLG",.F.)
	SLG->LG_LOGTEF := ""
	SLG->(MsUnLock())						
Return()                                         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณOperacoes	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณOpera็ใo TR                                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPA1 (1 - aDados) - Array com os parametros.     				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Operacoes(aReb) Class LJACentPag 
	
	Local aRebTr := {} 		// Array por transacao
	Local nCount	:= 1  	// COntador de opera็๕es
	
	::aReb	:= aClone(aReb)	
	aRebTr	:= aClone(::aReb[1])	
	// Loop de todas as transacoes
	While nCount <=  Len(::aReb)
		// S๓ faz transacao aque ainda nใo foi realizada.
		If nCount >= ::nTrans
			aRebTr := aClone(::aReb[nCount])	
			oTef:PrpStaTrn(aRebTr)
			If oTef:lTefOk
				oTef:GetInfCard()
				If oTef:lTefOk
					oTef:EnvVend()
				EndIf		
				cTexto := oTef:FechaTrn()
				oTef:CloseTef()
				If oTef:lTefOk
					::nTrans += 1
				Else
					Exit				
				EndIf
			Else
				Exit				
			EndIF		
		EndIf
		// Proxima transa็ใo
		nCount += 1		
	End
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณCancPend	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCancela Tr pendente                                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CancPend() Class LJACentPag 
	
 	Local aPend 	:= StrToArray(SLG->LG_LOGTEF , chr(10)) 	// Tr Pendentes  
 	Local aDadPen 	:= {}										// Armazena Backuo de Tr pendente
	Local nCont 	:= 0 										// Nomero de transacoes a serem canceladas
    Local cMsg	    := STR0006+Chr(10)+Chr(13) + ; 			//"Venda nใo efetuada, pagamentos com cartใo serใo cancelados"
    				   Padr(STR0007, 15)  + Padr(STR0008, 15)	+ Padr(STR0009, 5) +Chr(10) + Chr(13)  // "Autotiza็ใo" "Opera็ใo" "Valor"
    
    For nCont := 1 To Len(aPend) 
		
		aDadPen := strtoarray(aPend[nCont], "|")
		cMsg  += PadR(aDadPen[1], 15 ) + PadR(aDadPen[2], 15) + PadR(aDadPen[3], 5 )	+ Chr(13)
	
	Next nCont   
    
    MsgAlert(cMsg)
    
    For nCont := 1 To Len(aPend) 
		
		aDadPen := strtoarray(aPend[nCont], "|")
		::EnvCan(aDadPen[1], aDadPen[2], aDadPen[3])	
	
	Next nCont

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณEnvCan	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvia Cancelamento ao servidor 									 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 - Autorizacao     				 							 บฑฑ
ฑฑบ			 ณEXPC2 - Operacao													 บฑฑ
ฑฑบ			 ณEXPC3 - Valor     				 								 บฑฑ
ฑฑบ			 ณEXPL4 - Imprimi     				 								 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EnvCan(cAut, cNumOp, cValor, lImprimi) Class LJACentPag 

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cMsg		:= ""     	//Mensagem

	Default cAut 	:= ""
	Default cNumOp	:= ""
	Default cValor	:= ""
	Default lImprimi := .F.
	
	oParams		:= ::PrepParam({"7","sndCancelacion", ::cBs_User, ::cBs_Pwd,	;
								::cBs_Company, ::cBs_Branch,::cBs_Country, 	;
								cValor ,cNumOp,cAut}) 		
	
	cRetorno 	:= ::EnviarCom(oParams)           		
	
	oParams		:= ::PrepParam({"7","getRspDsResponse"}) 		
	cRetorno 	:= ::EnviarCom(oParams)           	
	
	If cRetorno == "error"
		oParams		:= ::PrepParam({"7","getRspDsError"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           			
		cMsg 		+=	cRetorno + Chr(10)+Chr(13)	
		oParams		:= ::PrepParam({"7","getRspCdError"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           			
		cMsg 		+=	STR0010 + cRetorno + Chr(10)+Chr(13) // "C๓digo erro: "	
		cMsg 		+=	STR0011 + cNumOp + STR0012 + cAut		//"Num. Opera็ใo " ", Autoriza็ใo "
		MsgAlert(cMsg)	
	ELseIf cRetorno == "approved"
		If lImprimi 
			::ImpCupAdm()
		Else
			cMsg 		+=	STR0013+ Chr(10)+Chr(13)			//"Cancelado"
			cMsg 		+=	STR0014 + cNumOp + STR0012 + cAut // "Num. Opera็ใo " ", Autoriza็ใo "
			MsgAlert(cMsg)
		EndIf 
	EndIf	
	
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณEnvRee	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvia Cancelamento ao servidor 									 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 - Autorizacao     				 							 บฑฑ
ฑฑบ			 ณEXPC2 - Operacao													 บฑฑ
ฑฑบ			 ณEXPC3 - Valor     				 								 บฑฑ
ฑฑบ			 ณEXPL4 - Imprimi     				 								 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EnvRee(cAut, cNumOp, cValor, lImprimi) Class LJACentPag 

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cMsg		:= ""     	//Mensagem

	Default cAut 	:= ""
	Default cNumOp	:= ""
	Default cValor	:= ""
	Default lImprimi := .F.
	
	oParams		:= ::PrepParam({"7","sndReimpresion", ::cBs_User, ::cBs_Pwd,	;
								::cBs_Company, ::cBs_Branch,::cBs_Country, 	;
								cNumOp}) 		
	
	cRetorno 	:= ::EnviarCom(oParams)           		
	
	oParams		:= ::PrepParam({"7","getRspDsResponse"}) 		
	cRetorno 	:= ::EnviarCom(oParams)           	
	
	If cRetorno == "error"
		oParams		:= ::PrepParam({"7","getRspDsError"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           			
		cMsg 		+=	cRetorno + Chr(10)+Chr(13)	
		oParams		:= ::PrepParam({"7","getRspCdError"}) 		
		cRetorno 	:= ::EnviarCom(oParams)           			
		cMsg 		+=	STR0010 + cRetorno + Chr(10)+Chr(13) // "C๓digo erro: "	
		cMsg 		+=	STR0011 + cNumOp + STR0012 + cAut		//"Num. Opera็ใo " ", Autoriza็ใo "
		MsgAlert(cMsg)	
	ELseIf cRetorno == "approved"
		If lImprimi 
			::ImpCupAdm()
	 	EndIf
	EndIf	
	
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LjTefMsRun บAutorณ Vendas Clientes    บ Data ณ  17/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Run especifico para o CP                            		  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ Lj850Tela(ExpC1)		    						          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 - Texto 01 a ser formatado                           บฑฑ
ฑฑบ          ณ ExpC2 - Texto 02 a ser formatado                           บฑฑ
ฑฑบ          ณ ExpC3 - Texto 03 a ser formatado                           บฑฑ 
ฑฑบ          ณ ExpC4 - Titulo                                             บฑฑ
ฑฑบ          ณ ExpB5 - Bloco de execu็ใo                                  บฑฑ
ฑฑบ          ณ ExpC6 - Cor da tela                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function LjTefMsRun(cCaption01, cCaption02,cCaption03, cTitle,;
					 bAction, cCor )

Local oDlg		:= Nil 	// Objeto de tela 
Local nWidth	:= 0	// tamanho da tela
Local oFont		:= Nil	// Objeto define fonte

DEFINE FONT oFont 		NAME "Arial" SIZE 6,14 BOLD
DEFINE FONT oFontMens	NAME "Arial" SIZE 08,15 BOLD			


DEFAULT cCaption01 	:= ""  
DEFAULT cCaption02 	:= ""  
DEFAULT cCaption03 	:= ""  
DEFAULT cTitle		:= ""
DEFAULT bAction		:= { || Inkey( 1 ) }

DEFINE DIALOG oDlg ;
FROM 0,0 TO 6, Max( Len( cCaption01 ), Len( cTitle ) ) - 3;
TITLE cTitle ;
STYLE DS_MODALFRAME
oDlg:SetFont(oFont)
nWidth := oDlg:nRight - oDlg:nLeft
@ 2,3  Say cCaption01 FONT oFontMens of oDlg PIXEL COLOR CLR_RED
@ 14,0 Say CCaption02 	 of oDlg PIXEL
@ 24,0 Say cCaption03 	 of oDlg PIXEL

oDlg:bStart := { || Eval( bAction, oDlg ), oDlg:End()}
oDlg:cMsg	:= cCaption01

ACTIVATE DIALOG oDlg CENTER
oFont:End()

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LjxFormTxt บAutorณ Vendas Clientes    บ Data ณ  17/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a formatao de texto para impressao de comprovante  บฑฑ 
ฑฑบ          ณ de TEF                            		  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ LjxFormTxt(ExpC1)								          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 - Texto a ser formatado                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpC1 - Texto formatado									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function LjxFormTxt(cTxt)

Local aTxt 		:= {}        // Array para formatar texto por linha
Local nX   		:= 0         // Controle de laco
Local cNewTXT   := ""        // Texto Formatado
Local cTxtCase  := ""        // Texto para comparacao no case  

Default cTxt := ""		     // Texto a ser formatado para impressao do comprovante

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ	****	A FORMATACAO DO TEXTO SEGUIRA AS CONFIGURACOES ABAIXO	****                                   ณ
//ณ                                                                                                        ณ
//ณ EXEMPLO: "@cnb"  Nova linha de texto com alinhamento no centro, tamanho normal em negrito              ณ
//ณ                                                                                                        ณ
//ณ +------------- @ = Indicador de nova linha e inicio de novo formato 								   ณ
//ณ |  +---------- Alinhamento do texto (l = left(Esquerda), c = center(Centro) , r = right(Direita))      ณ
//ณ |  |  +------- Tamanho do texto     (n = normal        , s = small(Pequeno) , b = big(Grande))         ณ
//ณ |  |  |  +---- Densidade da letra   (n = normal        , b = bold (Negrito) , l = light(Claro))        ณ
//ณ |  |  |  |   																						   ณ
//ณ |  |  |  |   																						   ณ
//ณ @  c  n  b 																							   ณ
//ณ                                                                                                        ณ
//ณ @br = pular linha apenas                                                                               ณ   
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//Retira formatacao anterior
cTxt := StrTran(cTxt,Chr(10))
cTxt := StrTran(cTxt,Chr(13))

// Divide o texto em um array separado por "@"
aTxt := StrTokArr(cTxt,"@")

For nX := 1 To Len(aTxt)  
	cTxtCase := Lower(SubStr(aTxt[nX],1,1))
	Do Case                              
		Case cTxtCase = "l"		// Alinha a esquerda
			cNewTXT +=  PADR(AllTrim(Stuff(aTxt[nX], 1, 4, "")),40)  
		Case cTxtCase = "c"		// Alinha no centro
			cNewTXT +=  PADC(AllTrim(Stuff(aTxt[nX], 1, 4, "")),40)  
		Case cTxtCase = "r"		// Alinha a direita
			cNewTXT +=  PADL(AllTrim(Stuff(aTxt[nX], 1, 4, "")),40)  						
	EndCase 
	//Pula Linha
	cNewTXT	+= Chr(10) //+Chr(13)    
Next nX

Return (cNewTXT)    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Loj854Cam  บAutorณ Vendas Clientes    บ Data ณ  17/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cancela CP												  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ Loj854Cam()									         	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function Loj854Cam()

Local aDadCan := {} // Retorno com dados que usuario digitou

aDadCan :=	Lj850Tela(STR0015) // "Cancelamento"

If Len(aDadCan) == 3
	OTEF:EnvCan(aDadCan[2], aDadCan[1], aDadCan[3], .T. )
EndIf 
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Loj854Ree  บAutorณ Vendas Clientes    บ Data ณ  17/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Reemite CP												  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ Loj854Ree()								         	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja/FrontLoja                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function Loj854Ree()

Local aDadRee := {} /// Retorno com dados que usuario digitou

aDadRee :=	Lj850Tela(STR0016) // "Reimpressใo"

If Len(aDadRee) == 3
	OTEF:EnvRee(aDadRee[2], aDadRee[1], aDadRee[3], .T. )
EndIf
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Lj850Tela  บAutorณ Vendas Clientes    บ Data ณ  17/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela generica para cancelamento e reimpressao de com-บฑฑ 
ฑฑบ          ณ provante CP                         		  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ Lj850Tela(ExpC1)		    						          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 - Texto a ser formatado                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ ExpA1 - Dados da Tela									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ \\ SigaLoja/FrontLoja //                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function Lj850Tela(cTitulo)

Local oGetNumAut   	:= Nil			// Obrjeto Numero de autoriza็ใo
Local cGetNumAut 	:= Space(10)	// Obrjeto Numero de autoriza็ใo
Local oGetNumOp		:= Nil			// Obrjeto Numero de Operacao
Local cGetNumOp 	:= Space(10)	// Obrjeto Numero de Operacao
Local oSay1			:= Nil          // Titulo de tela Num Auto
Local oSay2			:= Nil			// Titulo de Num Oper
Local oSay3			:= Nil			// Titulo de Num Valor
Local oSay4			:= Nil			// Titulo da tela
Local oSButton1		:= Nil			// Button1 Confirma็ใo
Local oSButton2		:= Nil			// Button2 saida
Local oValor		:= Nil			// Objeto de valor
Local cValor 		:= Space(12)	// Objeto de valor
Local oDlg     		:= Nil			// Objeto de Tela
Local aRet			:= {}			// Variavel de retorno
Local nValor    	:= 0.00			// Valor

Default cTitulo := STR0017 //"Administrativa Centro de Pagos"

DEFINE MSDIALOG oDlg TITLE STR0018 FROM 000, 000  TO 250, 230 COLORS 0, 16777215 PIXEL // "Centro de Pagamento"

@ 007, 025 SAY oSay1 PROMPT cTitulo SIZE 077, 011 OF oDlg COLORS 255, 16777215 PIXEL
@ 025, 024 SAY oSay2 PROMPT STR0019  SIZE 100, 006 OF oDlg COLORS 0, 16777215 PIXEL 	// "Numero Opera็ใo:"
@ 047, 024 SAY oSay3 PROMPT STR0020 SIZE 100, 009 OF oDlg COLORS 0, 16777215 PIXEL		// "Numero Autoriza็ใo:"
@ 032, 024 MSGET oGetNumOp VAR cGetNumOp SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 056, 024 MSGET oGetNumAut VAR cGetNumAut SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 079, 024 MSGET oValor VAR nValor	   	PICTURE "999999999.99"  SIZE 060, 010 OF oDlg  COLORS 0, 16777215 PIXEL
@ 070, 024 SAY oSay4 PROMPT STR0021 SIZE 060, 005 OF oDlg COLORS 0, 16777215 PIXEL // VALOR
DEFINE SBUTTON oSButton1 FROM 099, 066 TYPE 02 OF oDlg ENABLE ACTION (oDlg:End())
DEFINE SBUTTON oSButton2 FROM 099, 024 TYPE 01 OF oDlg ENABLE ACTION ( aRet := {cGetNumOp, cGetNumAut, cValToChar(nValor) } , oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

Return(aRet)