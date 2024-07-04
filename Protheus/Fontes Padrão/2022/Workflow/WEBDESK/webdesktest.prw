// **** DESCOMENTAR ESTE CÓDIGO PARA REALIZAR TESTES ****
// **** NãO ENVIAR AO SOURCESAFE COM CÓDIGO DESCOMENTADO! ****

//<!-- BEGIN TESTE

/*

#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

//Inicializa processo         
user function initProc( cTpProc, cIdPrt, cIdProc, cData, aAttach, cComments,cUsr, cPwd )
	local aRet := {}   
	local nPos := 0
	
  	aRet := BIStartTask( cTpProc, cIdPrt, cIdProc, cComments, cData, aAttach, .T., 0, {}, cUsr, cPwd)

  	varInfo("aRet", aRet)

	nPos := aScan( aRet, { |x| x[1] == "ERROR" } ) 	
  	if nPos > 0
  		msgStop( "Erro ao inicializar processo - " + aRet[nPos][2] )
  	endif
	
return aRet

//recupera form
user function getCard( cProcessId, cUsr, cPwd )
	local cRet := ""
	local nPos := 0

	cRet := BIGetCardData( cProcessId, cUsr, cPwd )
	
  	varInfo("cRet", cRet)

  	if valtype( cRet ) == "A"
		nPos := aScan( cRet, { |x| x[1] == "ERROR" } ) 	
	  	if nPos > 0
	  		msgStop( "Erro ao recuperar formulário - " + cRet[nPos][2] )
	  	else
			msgStop( "Erro ao recuperar formulário" )
	  	endif
  	endif

return cRet

//Atualiza processo         
user function updProc( xIdProc, cData, aAttach, cUsr, cPwd )
	local aRet := {}
	local nPos := 0

  	aRet := BIUpdateTask( xIdProc, "UPDATE PROCESS - PROTHEUS", cData, aAttach, .T., 0, {} ,cUsr, cPwd )

  	varInfo("aRet", aRet)

	nPos := aScan( aRet, { |x| x[1] == "ERROR" } ) 	
  	if nPos > 0
  		msgStop( "Erro ao atualizar processo - " + aRet[nPos][2] )
  	endif

return aRet

//testes auxiliares
user function biSaveEcm()

	prepare environment empresa "99" filial "01"

	//biPrtEcm( cTpProc, cCodPrt, cCodECM )
	msgInfo( "TESTE 1.1 -> .T. == " + iif( biPrtEcm( "SC", "10", "20" ), ".T.", ".F." ) )	//OK
	msgInfo( "TESTE 1.2 -> .F. == " + iif( biPrtEcm( "SC", "12", "20" ), ".T.", ".F." ) )	//CHAVE DUPLICADA
	msgInfo( "TESTE 1.3 -> .T. == " + iif( biPrtEcm( "PD", "10", "20" ), ".T.", ".F." ) )	//OK
	msgInfo( "TESTE 1.4 -> .F. == " + iif( biPrtEcm( "SC", "10", "25" ), ".T.", ".F." ) )	//CHAVE DUPLICADA
	msgInfo( "TESTE 1.5 -> .T. == " + iif( biPrtEcm( "SC", "15", "25" ), ".T.", ".F." ) )	//OK

	//biEcm2Prt( cTpProc, cCodEcm )	
	msgInfo( "TESTE 2.1 -> '  ' == '" + alltrim( biEcm2Prt( "SC", "10" ) ) + "'" )	// -> ""
	msgInfo( "TESTE 2.2 -> '10' == '" + alltrim( biEcm2Prt( "SC", "20" ) ) + "'" )	// -> 10
	msgInfo( "TESTE 2.3 -> '15' == '" + alltrim( biEcm2Prt( "SC", "25" ) ) + "'" ) // -> 15
	msgInfo( "TESTE 2.4 -> '  ' == '" + alltrim( biEcm2Prt( "PD", "10" ) ) + "'" ) // -> ""
	msgInfo( "TESTE 2.5 -> '10' == '" + alltrim( biEcm2Prt( "PD", "20" ) ) + "'" ) // -> 10

	//biPrt2Ecm( cTpProc, cCodPrt )
	msgInfo( "TESTE 3.1 -> '20' == '" + alltrim( biPrt2Ecm( "SC", "10" ) ) + "'" )	// -> 20
	msgInfo( "TESTE 3.2 -> '  ' == '" + alltrim( biPrt2Ecm( "SC", "20" ) ) + "'" )	// -> ''
	msgInfo( "TESTE 3.3 -> '  ' == '" + alltrim( biPrt2Ecm( "SC", "12" ) ) + "'" ) // -> ''
	msgInfo( "TESTE 3.4 -> '20' == '" + alltrim( biPrt2Ecm( "PD", "10" ) ) + "'" ) // -> 20
	msgInfo( "TESTE 3.5 -> '25' == '" + alltrim( biPrt2Ecm( "SC", "15" ) ) + "'" ) // -> 25

return
         
// User function que trata requisições do TOTVS ECM (ponto de entrada)
user function ecmInteg()
	local cRet := ""

	local cTpProc := PARAMIXB[1]
	local cCodPrt := PARAMIXB[2]
	local cCodECM := PARAMIXB[3]
	local cParam := PARAMIXB[4]

	cRet := "TRATAMENTO PERSONALIZADO" + " | "

	cRet += "TP PROCESSO: "		+ cTpProc	+ " | "

	cRet += "ID ECM: "			+ cCodECM	+ " | "

	cRet += "PARAM RECEBIDO: "	+ cParam		+ " | "

	cRet += "ID PRT: "			+ cCodPrt	+ " | "

return cRet



//Testes de processo
user function ecmTest()
	local aRet			:= {}
	local aAttach1		:= {}
	local aAttach2		:= {}

	local cXML			:= ""
	local cData			:= ""
	local cReadData	:= ""

	local cError		:= ""
	local cWarning		:= ""

	local oXML			:= nil

	local nProcess		:= 0

  	prepare environment empresa "99" filial "01"

	cXML := 	'<?xml version="1.0" encoding="UTF-8"?>' + ;
				'<COMP020_MVC>' + ;
				'	<COMP020_MVC_ZA1>' + ;
				'		<DA0_Nota_fornecedor>' + ;
				'			<value />' + ;
				'		</DA0_Nota_fornecedor>' + ;
				'		<DA0_PEDIDO_ENTREGA>' + ;
				'			<value />' + ;
				'		</DA0_PEDIDO_ENTREGA>' + ;
				'		<DA0_Nota_comprador>' + ;
				'			<value />' + ;
				'		</DA0_Nota_comprador>' + ;
				'		<OMSA010_DA1>' + ;
				'			<items>' + ;
				'				<item>' + ;
				'					<DA1_FORNEC />' + ;
				'					<DA1_QUANT />' + ;
				'					<DA1_ITEM />' + ;
				'					<DA1_Prazo />' + ;
				'					<DA1_Aprovado />' + ;
				'					<DA1_PRECO />' + ;
				'				</item>' + ;
				'			</items>' + ;
				'		</OMSA010_DA1>' + ;
				'		<DA0_NOTA_preco>' + ;
				'			<value />' + ;
				'		</DA0_NOTA_preco>' + ;
				'		<DA0_PEDIDO_preco>' + ;
				'			<value />' + ;
				'		</DA0_PEDIDO_preco>' + ;
				'		<DA0_NOTA_ITEM>' + ;
				'			<value />' + ;
				'		</DA0_NOTA_ITEM>' + ;
				'		<DA0_PEDIDO_Quantidade>' + ;
				'			<value />' + ;
				'		</DA0_PEDIDO_Quantidade>' + ;
				'		<DA0_SOLICITACAO>' + ;
				'			<value />' + ;
				'		</DA0_SOLICITACAO>' + ;
				'		<DA0_PEDIDO_ITEM>' + ;
				'			<value />' + ;
				'		</DA0_PEDIDO_ITEM>' + ;
				'		<DA0_PEDIDO_FORNECEDOR>' + ;
				'			<value />' + ;
				'		</DA0_PEDIDO_FORNECEDOR>' + ;
				'		<DA0_NOTA_Quantidade>' + ;
				'			<value />' + ;
				'		</DA0_NOTA_Quantidade>' + ;
				'		<DA0_NOTA_ENTREGA>' + ;
				'			<value />' + ;
				'		</DA0_NOTA_ENTREGA>' + ;
				'		<DA0_SOLIC>' + ;
				'			<value />' + ;
				'		</DA0_SOLIC>' + ;
				'		<DA0_MOTIVO>' + ;
				'			<value />' + ;
				'		</DA0_MOTIVO>' + ;
				'	</COMP020_MVC_ZA1>' + ;
				'</COMP020_MVC>'

	aAttach1 := {"Teste 001", "Teste.txt", "Teste de arquivo texto criado no Protheus"}
	aAttach2 := {} //{"Teste 002", "Teste2.txt", "Teste de arquivo texto 2 criado no Protheus"}
	//Inicializa processo no ECM
	
	//Atualiza XML
	oXml := XmlParser( cXML, '_', @cError, @cWarning )
	oXml:_COMP020_MVC:_COMP020_MVC_ZA1:_DA0_SOLICITACAO:_value:TEXT := ""
	oXml:_COMP020_MVC:_COMP020_MVC_ZA1:_DA0_SOLIC:_value:TEXT := "ADRIANO"
	cData := XMLSaveStr( oXml )
	
	msgInfo( "Inicializar Processo" )
	aRet := u_initProc( "SCC", substr( time(), 7, 2), "Solicitação de Compras", cData, aAttach1, "START PROCESS - PROTHEUS", "PROTHEUSECM", "MD5:" + md5("ecm") )

	if valtype( aRet ) == "A" .and. len(aRet) == 3
		msgInfo( "OK" )
	else
		msgInfo( "ERRO" )
		return
	endif

	nProcess := val( aRet[2][2] )

	msgInfo( nProcess )

	//Lê formulário do processo ECM	
	msgInfo( "Ler formulário" )
	cReadData := u_getCard( nProcess, "aprovadorSolicit", "MD5:" + md5("adm") )
	
	if valtype( cReadData ) == "C"
		msgInfo( "OK" )
	else
		msgInfo( "ERRO" )
		return
	endif
	
	msgInfo( cReadData )

	//Atualiza XML
	oXml := XmlParser( cReadData, '_', @cError, @cWarning )
	oXml:_COMP020_MVC:_COMP020_MVC_ZA1:_DA0_SOLIC:_value:TEXT := "APROVACAO SOLICIT - PROTHEUS"
	cData := XMLSaveStr( oXml )

	//Atualiza formulário
	msgInfo( "Aprovar Solicitação" )	
	aRet := u_updProc( nProcess, cData, aAttach2, "aprovadorSolicit", "MD5:" + md5("adm") )
	
	if valtype( aRet ) == "A" .and. len(aRet) == 2
		msgInfo( "OK" )
	else
		msgInfo( "ERRO" )
		return
	endif
	
	//Lê formulário do processo ECM
	msgInfo( "Ler formulário" )
	cReadData := u_getCard( nProcess, "forncedor1", "MD5:" + md5("adm") )

	if valtype( cReadData ) == "C"
		msgInfo( "OK" )
	else
		msgInfo( "ERRO" )
		return
	endif

	msgInfo( cReadData )

	//Atualiza XML
	oXml := XmlParser( cReadData, '_', @cError, @cWarning )
	oXml:_COMP020_MVC:_COMP020_MVC_ZA1:_DA0_SOLIC:_value:TEXT := "COTACAO 1 - PROTHEUS"
	cData := XMLSaveStr( oXml )
	
	//Atualiza formulário
	msgInfo( "Cotação 1" )
	aRet := u_updProc( nProcess, cData, aAttach2, "forncedor1", "MD5:" + md5("adm") )

	if valtype( aRet ) == "A" .and. len(aRet) == 2
		msgInfo( "OK" )
	else
		msgInfo( "ERRO" )
		return
	endif


	//Atualiza XML
	oXml := XmlParser( cReadData, '_', @cError, @cWarning )
	oXml:_COMP020_MVC:_COMP020_MVC_ZA1:_DA0_SOLIC:_value:TEXT := "COTACAO 2 - PROTHEUS"
	cData := XMLSaveStr( oXml )
	
	//Atualiza formulário
	msgInfo( "Cotação 2" )
	aRet := u_updProc( nProcess, cData, aAttach2, "fornecedor2", "MD5:" + md5("adm") )

	if valtype( aRet ) == "A" .and. len(aRet) == 2
		//msgInfo( aRet[2][2] )
		msgInfo( "OK" )
	else
		msgInfo( "ERRO" )
		return
	endif


	//Atualiza XML
	oXml := XmlParser( cReadData, '_', @cError, @cWarning )
	oXml:_COMP020_MVC:_COMP020_MVC_ZA1:_DA0_SOLIC:_value:TEXT := "COTACAO 3 - PROTHEUS"
	cData := XMLSaveStr( oXml )

	//Atualiza formulário
	msgInfo( "Cotação 3" )
	aRet := u_updProc( nProcess, cData, aAttach2, "fornecedor3", "MD5:" + md5("adm") )

	if valtype( aRet ) == "A" .and. len(aRet) == 2
		//msgInfo( aRet[2][2] )
		msgInfo( "OK" )
	else
		msgInfo( "ERRO" )
		return
	endif


	//Atualiza XML
	oXml := XmlParser( cReadData, '_', @cError, @cWarning )
	oXml:_COMP020_MVC:_COMP020_MVC_ZA1:_DA0_SOLIC:_value:TEXT := "APROVACAO COTACAO - PROTHEUS"
	cData := XMLSaveStr( oXml )

	//Atualiza formulário
	msgInfo( "Aprovar cotação" )
	aRet := u_updProc( nProcess, cData, aAttach2, "aprovadorcot", "MD5:" + md5("adm") )

	if valtype( aRet ) == "A" .and. len(aRet) == 2
		//msgInfo( aRet[2][2] )
		msgInfo( "OK" )
	else
		msgInfo( "ERRO" )
		return
	endif


	//Atualiza XML
	oXml := XmlParser( cReadData, '_', @cError, @cWarning )
	oXml:_COMP020_MVC:_COMP020_MVC_ZA1:_DA0_SOLIC:_value:TEXT := "APROVACAO PEDIDO - PROTHEUS"
	cData := XMLSaveStr( oXml )

	//Atualiza formulário
	msgInfo( "Aprovar pedido" )
	aRet := u_updProc( nProcess, cData, aAttach2, "aprovadorped", "MD5:" + md5("adm") )

	if valtype( aRet ) == "A" .and. len(aRet) == 2
		//msgInfo( aRet[2][2] )
		msgInfo( "OK" )
	else
		msgInfo( "ERRO" )
		return
	endif

return

user function wzdecm()

	prepare environment empresa "99" filial "01"

	CFGBIECMWZ()

return

//--> END TESTE

*/  

function biEcmInteg( cTpProc, cCodPrt, cCodECM, cParam )
	Local cRet := ""
	
	cRet := "TRATAMENTO PADRÃO" + " | "

	cRet += "TP PROCESSO: "		+ cTpProc	+ " | "

	cRet += "ID ECM: "			+ cCodECM	+ " | "

	cRet += "PARAM RECEBIDO: "	+ cParam		+ " | "

	cRet += "ID PRT: "			+ cCodPrt	+ " | "

return  cRet  

