#Include 'Protheus.ch'
#Include 'topconn.ch'

User Function wTMonitJob()

	Local cEmail    := U_GETZPA("EMAIL_ERRO_MERCANET","ZZ")        // E-mail para envio de avisos aos responsáveis
	Local _cDate    := dtos(date())
	Local _cDtATU   := substring(_cDate,1,4)+"-"+substring(_cDate,5,2)+"-"+substring(_cDate,7,2)+" "+time()+".000000" 
	Local _cQry     := ""
	Local nTempoMax := 10  // Tempo maximo em minutos para emitir alerta desde o ultimo processamento JOB Mercanet 
	Local lEmp01    := .F.
	Local lEmp02    := .F. 
	Local cTxtOcor1 := ""
	Local cTxtOcor2 := ""
	Local cEmp      := "01"
	Local cFil      := "01"
	
	//---------------------------------------------------------------------
	// Inicializa ambiente  
	//---------------------------------------------------------------------
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })
	
	//---------------------------------------------------------------------
	// Verifica semaforo de integracao para continuar  
	//---------------------------------------------------------------------
	cSemaforo := U_GETZPA("SEMAFORO_MERCANET","ZZ")
	if cSemaforo == "OFF"
		RpcClearEnv()
		return
	endif  

	//--------------------------------------------------------------------------------
	// Obtem data e hora do último processamento do JOB integração Pedidos Mercanet  
	// das empresas SANCHEZ e FINI 
	//--------------------------------------------------------------------------------
	cRet01 := U_GETZPA("STATUS_MERCANET","01")
	cRet02 := U_GETZPA("STATUS_MERCANET","02")

	cQry01 := " SELECT DATEDIFF(minute, '" + cRet01 + "', '" + _cDtATU + "') AS MINUTOS "
	cQry02 := " SELECT DATEDIFF(minute, '" + cRet02 + "', '" + _cDtATU + "') AS MINUTOS "

	TCQUERY cQry01 NEW ALIAS "TRBZP1"
	TCQUERY cQry02 NEW ALIAS "TRBZP2"

	//--------------------------------------------------------------------------------
	// Se data/hora do ultimo processamento for maior que o parametro de minutos 
	// dispara e-mail com alerta 
	//--------------------------------------------------------------------------------
	if TRBZP1->MINUTOS > nTempoMax 
		lEmp01 := .T. 
		cTxtOcor1+=" O processo de integração de pedidos Mercanet está há " + ALLTRIM(STR(TRBZP1->MINUTOS,8,0)) + " minutos sem processar.<br>"
		cTxtOcor1+=" Data e hora do último processamento: " + substring(cRet01,9,2)+"/"+substring(cRet01,6,2)+"/"+substring(cRet01,1,4)+"/"+substring(cRet01,12,8)
		cTxtOcor1+="<br><br>"
	endif 

	if TRBZP2->MINUTOS > nTempoMax 
		lEmp02 := .T. 
		cTxtOcor2+=" O processo de integração de pedidos Mercanet está há " + ALLTRIM(STR(TRBZP2->MINUTOS,8,0)) + " minutos sem processar.<br>"
		cTxtOcor2+=" Data e hora do último processamento: " + substring(cRet02,9,2)+"/"+substring(cRet02,6,2)+"/"+substring(cRet02,1,4)+"/"+substring(cRet02,12,8)
		cTxtOcor2+="<br><br>"
	endif 

	if lEmp01 .or. lEmp02 
		envMail(cEmail,lEmp01,lEmp02,cTxtOcor1,cTxtOcor2)
	endif 

	//-------------------------------------------
	// Fecha areas de trabalho 
	//-------------------------------------------
	TRBZP1->(dbCloseArea())
	TRBZP2->(dbCloseArea())
	
	//-------------------------------------------
	// Encerra ambiente 
	//-------------------------------------------
	RpcClearEnv()
	

Return





//------------------------------------------------------------------------
//
//
// Envia e-mail de alerta 
//
//------------------------------------------------------------------------
Static Function envMail(cEmail,lEmp01,lEmp02,cTxtOcor1,cTxtOcor2)

	cTitulo := "** Alerta Monitoramento ** - Integracao Pedidos MERCANET "

	cTexto  := ""
	cTexto  += '<table border="1">'
	cTexto  += "<tr>"
	cTexto  += "<td><b>Data da ocorrência</b></td>"
	cTexto  += "<td>"+space(05)+DTOC(date())+"</td>"
	cTexto  += "</tr>"
	cTexto  += "<tr>"
	cTexto  += "<td><b>Horário da ocorrência</b></td>"
	cTexto  += "<td>"+time()+"</td>"
	cTexto  += "</tr>"
	cTexto  += "<tr>"

	if lEmp01
		cTexto  += "<tr>"
		cTexto  += "<td><b>Empresa</b></td>"
		cTexto  += "<td>01-SANCHEZ CANO</td>" 
		cTexto  += "</tr>"
		cTexto  += "<tr>"
		cTexto  += "<td><b>Ocorrência</b></td>"
		cTexto  += "<td>"+cTxtOcor1+"</td>"
		cTexto  += "</tr>"
		cTexto  += "<tr>"
	endif
	
	if lEmp02
		cTexto  += "<tr>"
		cTexto  += "<td><b>Empresa</b></td>"
		cTexto  += "<td>02-FINI COMERCIALIZADORA</td>" 
		cTexto  += "</tr>"
		cTexto  += "<tr>"
		cTexto  += "<td><b>Ocorrência</b></td>"
		cTexto  += "<td>"+cTxtOcor2+"</td>"
		cTexto  += "</tr>"
		cTexto  += "<tr>"
	endif
	

	cTexto  += "</table>"
	cTexto  += "<BR><BR><hr>"
	_cAnexos := ""

	U_SUBEML(cEmail,cTitulo,cTexto,_cAnexos)

Return

