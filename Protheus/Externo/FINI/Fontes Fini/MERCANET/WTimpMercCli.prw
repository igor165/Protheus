#INCLUDE "TOTVS.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "TOPCONN.CH"

/*
|==============================================================================|
|                           S A N C H E Z   C A N O                            |
|==============================================================================|
| Programa  | WTIMPMERCCLI    |Autor  Cristian Müller      |Data 03/04/2016    |
|-----------+------------------------------------------------------------------|
|           |                                                                  |
|           |                                                                  |
| Descrição | Rotina via JOB para integração de Clientes vindos                |
|           | do Mercanet.                                                     |
|           |                                                                  |
|           |                                                                  |
|           |                                                                  |
|           |                                                                  |
|-----------+------------------------------------------------------------------|
|    Uso    |   Protheus      | Móduto | Faturamento      | Chamado |          |
|------------------------------------------------------------------------------|
|>>>>>>>>>>>>>>>>>>>>>>>>>> Histórico de Alterações <<<<<<<<<<<<<<<<<<<<<<<<<<<|
|------------------------------------------------------------------------------|
|   Data    |               Alteração               |    Autor     |  Chamado  |
|-----------+---------------------------------------+--------------+-----------|
|==============================================================================|
*/

User Function impMercCli(_par01)

	Local   cEmp           := _par01
	Local   cFil           := "01"
	Local   cQry           := ""
	Local   cCliRet        := ""
	//Local   cFilBkp
	//Local   lEstOk

	//Private cMailCli       := U_GETZPA("EMAIL_CLIE_MERCANET","ZZ")        // E-mail para envio de aviso inclusao de novo cliente
	Private cDescEmp       := iif(cEmp=="01","01-SANCHEZ","02-FINI")
	Private cStatus        := ""
	Private cTxtErr        := ""
	Private cSemaforo      := ""

	//---------------------------------------------------------------------
	// Inicializa ambiente sem consumir licencas
	//---------------------------------------------------------------------
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

	//---------------------------------------------------------------------
	// Atualiza data e hora de execucao do JOB atual
	//---------------------------------------------------------------------
	U_PUTZPA("STATUS_MERCACLIENTE","ZZ",dtos(date())+space(01)+time())

	//---------------------------------------------------------------------
	// Verifica semaforo de integracao para continuar
	//---------------------------------------------------------------------
	cSemaforo := U_GETZPA("SEMAFORO_MERCACLIENT","ZZ")  // Semaforo do Cliente 
	cMailCli  := U_GETZPA("EMAIL_CLIE_MERCANET" ,"ZZ")  // E-mail para envio de aviso inclusao de novo cliente
	if cSemaforo == "OFF"
		ConOut( "(SEMAFORO_MERCACLIENT=OFF) "+dtoc( Date() )+" "+Time()+" Semaforo fechado para integracao de clientes." )
		RpcClearEnv()
		return
	else
		ConOut( "[MERCANET] "+dtoc( Date() )+" "+Time()+" Inicio processamento CLIENTES Versao 20210111 - "+cDescEmp )
	endif

	//---------------------------------------------------------------
	// Seleciona clientes pendentes enviados pelo Mercanet
	// Orderna por fila de entrada para processamento
	//---------------------------------------------------------------
	cQry := " SELECT * FROM " + retSqlName("Z1A") + " Z1A "
	cQry += " WHERE Z1A.D_E_L_E_T_ = '' "
	cQry += " AND Z1A.Z1A_STATUS = '' "
	cQry += " ORDER BY Z1A.Z1A_FILA "
	TCQUERY cQry NEW ALIAS "TRBZ1A"

	//-----------------------------------------------------------------
	// Gera Clientes via RECLOCK
	//-----------------------------------------------------------------
	dbSelectArea("TRBZ1A")
	DBGoTop()
	do while !TRBZ1A->(eof())

		cCliRet  := ""  // Codigo cliente gerado Protheus

		//----------------------------
		// Ordem por fila
		//----------------------------
		Z1A->(dbSetOrder(3))

		if Z1A->(dbSeek(TRBZ1A->Z1A_FILA))

			//------------------------------------------
			// Se linha já processada, ignora registro
			//------------------------------------------
			if !empty(Z1A->Z1A_STATUS)
				TRBZ1A->(dbSkip())
				loop
			endif

			//----------------------------------------------
			//- Mensagem de inicio de importacao no console
			//----------------------------------------------
			conout( "[MERCANET] "+dtoc( Date() )+" "+Time() + " " + cDescEmp + " -> Importando Cliente " + TRBZ1A->Z1A_NOME )

			//-------------------------------------------------------
			// Marca Status inicial como INI antes de rodar Execauto
			// Essa marca é necessaria pois caso ocorrer error log
			// os próximos pedidos da fila não serao prejudicados
			//-------------------------------------------------------
			Z1A->(reclock("Z1A",.F.))
			Z1A->Z1A_STATUS := "INI"
			Z1A->Z1A_DTINI  := DATE()
			Z1A->Z1A_HRINI  := TIME()
			Z1A->(msUnLock())

			//-------------------------------
			// Verifica pelo CNPJ se cliente
			// ja existe cadastrado no SA1
			//-------------------------------
			if chkCli(Z1A->Z1A_CGC)
				cTxtErr := "CNPJ " +Z1A->Z1A_CGC + " já existe cadastrado para o cliente " + Z1A->Z1A_NOME
				ConOut(cTxtErr) 
				cStatus := "ERR"
				// Envia e-mail avisando do cadastro do cliente
				envMail(cMailCli,.T.)
			else
				//-------------------------------
				// Inclui Cliente via MsExecAuto
				//-------------------------------
				dbSelectArea("TRBZ1A")
				cCliRet := geraCli()
			endif

			//---------------------------------------
			// Atualiza status final no Z1A
			//---------------------------------------
			Z1A->(reclock("Z1A",.F.))
			Z1A->Z1A_STATUS := cStatus
			Z1A->Z1A_DTFIM  := DATE()
			Z1A->Z1A_HRFIM  := TIME()
			Z1A->Z1A_ERRO   := cTxtErr
			Z1A->Z1A_COD    := cCliRet
			Z1A->Z1A_LOJA   := "01"
			Z1A->(msUnLock())

		endif

		//----------------------------
		// Proximo cliente a integrar
		//----------------------------
		TRBZ1A->(dbSkip())

	enddo

	//---------------------------------
	// Finaliza ambiente
	//---------------------------------
	TRBZ1A->(dbCloseArea())
	RpcClearEnv()

	ConOut( "[MERCANET] "+dtoc( Date() )+" "+Time()+" Final Processamento CLIENTES - "+cDescEmp )

Return



//=================================================================================
// 
//
// Funcao para a inclusao de Clientes vindos do Mercanet no Protheus via Execauto
//
//
//================================================================================= 
Static Function geraCli()

	//Local aDados           := {}
	//Local aLog             := {}
	Local cRet             := ""
	Local cContabil        := "101020101"  /// Define conta contábil cliente conforme regra solicitada via chamado nro 33458 - Suellen 
	Local _nX3			   := 0

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto	   := .T.
	Private lAutoErrNoFile := .T.

	conout( "[MERCANET] "+dtoc( Date() )+" "+Time() + " " + cDescEmp + " Filial " + cFilAnt + " -> Inserindo Cliente  " + TRBZ1A->Z1A_NOME )

	//---------------------------------------------------
	// Define codigo do cliente conforme parametro
	// Verifica se codigo ja existe e troca para o proximo
	//-----------------------------------------------------
	/*dbSelectArea("SA1")
	dbSetOrder(1)
	do while .t.
		cCod := ALLTRIM(GETMV("ZZ_SA1MERC"))
		if SA1->(dbSeek(xFilial("SA1")+cCod))
			cCod := SOMA1(cCod)
			PUTMV("ZZ_SA1MERC",cCod)
			loop
		else
			PUTMV("ZZ_SA1MERC",cCod)
			exit 
		endif
	enddo
	*/

	dbSelectArea("SA1")
	dbSetOrder(1)
	do while .t.
		cCod := getCodCli()
		if SA1->(dbSeek(xFilial("SA1")+cCod))
			loop
		else
			exit
		endif
	enddo

    
	//------------------------------------------------------------
	//- Usar reclock temporariamente
	//- Aguardando utilização de rotina via WorkFlow
	//- Não utiliza execauto pois muitos campos obrigatórios
	//- o Mercanet não envia informações desses campos
	//------------------------------------------------------------
	Begin TRANSACTION

		dbSelectArea("SA1")
		recLock("SA1",.T.)

		//--------------------------------------------------------------------
		//-- Atualiza Valores inicializador padrao conforme campo X3_RELACAO
		//--------------------------------------------------------------------
		_cAliasCampos := "SA1"
		INCLUI        := .T.
		For _nX3 := 1 To (_cAliasCampos)->(FCOUNT())
			_cCpoSA1   := "SA1->"+(FieldName(_nX3))
			_cIniPad   := Posicione("SX3",2,(FieldName(_nX3)),"X3_RELACAO")
			if !empty(_cIniPad)
				&_cCpoSA1  := &_cIniPad
			endif
		Next

		//----------------------------------------------
		// Valores Fixos para manter padrao
		//----------------------------------------------
		SA1->A1_PAIS    := "105"
		SA1->A1_DDI     := "55"
		SA1->A1_CODPAIS := "01058"

		//--------------------------------------------------
		// Atualiza valores vindos do Mercanet
		//--------------------------------------------------
		SA1->A1_COD    := cCod
		SA1->A1_LOJA   := "01"
		SA1->A1_NOME   := TRBZ1A->Z1A_NOME
		SA1->A1_PESSOA := TRBZ1A->Z1A_PESSOA
		SA1->A1_NREDUZ := TRBZ1A->Z1A_NREDUZ
		SA1->A1_END    := TRBZ1A->Z1A_END
		SA1->A1_EST    := TRBZ1A->Z1A_EST
		SA1->A1_MUN    := TRBZ1A->Z1A_MUN
		SA1->A1_COD_MUN:= TRBZ1A->Z1A_COD_MU
		SA1->A1_BAIRRO := TRBZ1A->Z1A_BAIRRO
		SA1->A1_ESTADO := TRBZ1A->Z1A_ESTADO
		SA1->A1_CEP    := TRBZ1A->Z1A_CEP
		SA1->A1_DDD    := SUBSTR(TRBZ1A->Z1A_TEL,2,2)
		SA1->A1_TEL    := SUBSTR(TRBZ1A->Z1A_TEL,5,20)
		SA1->A1_FAX    := TRBZ1A->Z1A_FAX
		SA1->A1_ENDCOB := TRBZ1A->Z1A_ENDCOB
		SA1->A1_CONTATO:= TRBZ1A->Z1A_CONTATO
		SA1->A1_CGC    := TRBZ1A->Z1A_CGC
		SA1->A1_INSCR  := TRBZ1A->Z1A_INSCR
		SA1->A1_VEND   := TRBZ1A->Z1A_VEND
		SA1->A1_BCO1   := TRBZ1A->Z1A_BCO1
		SA1->A1_COND   := TRBZ1A->Z1A_COND
		SA1->A1_LC     := TRBZ1A->Z1A_LC
		SA1->A1_ULTVIS := STOD(TRBZ1A->Z1A_ULTVIS)
		SA1->A1_MSBLQL := "1"
		SA1->A1_CXPOSTA:= TRBZ1A->Z1A_CXPOST
		SA1->A1_OBSERV := TRBZ1A->Z1A_OBSERV
		SA1->A1_BAIRROC:= TRBZ1A->Z1A_BAIRRC
		SA1->A1_CEPC   := TRBZ1A->Z1A_CEPC
		SA1->A1_MUNC   := TRBZ1A->Z1A_MUNC
		SA1->A1_ESTC   := TRBZ1A->Z1A_ESTC
		SA1->A1_EMAIL  := TRBZ1A->Z1A_EMAIL
		SA1->A1_HPAGE  := TRBZ1A->Z1A_HPAGE
		SA1->A1_ZZMERCA:= TRBZ1A->Z1A_CODMER
		SA1->A1_SATIV1 := TRBZ1A->Z1A_SATIV1
		SA1->A1_SATIV8 := TRBZ1A->Z1A_SATIV8
		//CM Solutions - Allan Constantino Bonfim - 18/10/2019 - CHAMADO 25982 - Gravação do campo segmento para o tratamento dos dados bancários por segmento.
		SA1->A1_CODSEG := TRBZ1A->Z1A_SATIV1
		SA1->A1_BLEMAIL:= "1"  //Adicionado para restruturar a pechecada dos boletos -> ALTERADO POR FELIPE PAZETTO 29/09 - NAO EXISTE 'S' OU 'N' MAIS, E SIM 1-Sim / 2-Nao...
        SA1->A1_CONTA  := cContabil
		//--------------------------------------------
		// Libera registro e marca como processado
		//--------------------------------------------
		SA1->(msUnLock())
		cStatus        := "PRO"
		cRet           := SA1->A1_COD
		confirmSX8()

	END TRANSACTION

	//---------------------------------------------
	// Envia e-mail avisando do cadastro do cliente
	//---------------------------------------------
	envMail(cMailCli,.F.)


	conout( "[MERCANET] "+dtoc( Date() )+" "+Time() + " " + cDescEmp + " -> Fim MsExecAuto - Cliente Protheus " + SA1->A1_COD + " gerado com sucesso." )


Return(cRet)


//===================================================================
//
// Rotina : getCodCli 
// Uso    :Localiza o proximo codigo de cliente vago
//
//===================================================================
Static Function getCodCli()

	Local cCod		:=""
	Local cQuery	:=""

	cQuery+=" SELECT TOP 1 CODCHAR FROM SA1_SEQCOD "
	cQuery+=" 	WHERE CODCHAR NOT IN (SELECT A1_COD FROM "+RetSqlName("SA1")+") "
	cQuery+=" AND USED=0 "
	cQuery+=" ORDER BY CODCHAR "
	TcQuery cQuery New Alias "SEQC"
	DbSelectArea("SEQC")
	DbGotop()
	cCod:=CODCHAR

// ---------------------------------------------------------------
// -- Marca que o codigo ja foi usado
// ---------------------------------------------------------------
	TcSQLExec("UPDATE SA1_SEQCOD SET USED=1 WHERE CODINT= "+alltrim(str(Val(CODCHAR))))


	SEQC->(DbCloseArea())

Return(cCod)


//------------------------------------------------------------------------
//
//
// Envia e-mail ao responsavel avisando inclusão de novo cliente  
//
//
//------------------------------------------------------------------------
Static Function envMail(cMailCli,lErro)

	cTitulo := if(lErro,"ERRO -> ","") + "Novo cliente Mercanet - " + TRBZ1A->Z1A_NOME

	if lErro 
	   cTexto  := "O cliente abaixo não foi integrado devido já existir um mesmo CNPJ cadastrado no Protheus."
	else
	   cTexto  := "O cliente abaixo foi integrado ao Protheus e está aguardando o complemento do seu cadastro para efetivar a liberação no sistema: "  + "<BR><BR>"
	endif 

	cTexto  += '<table border="1">'

	cTexto  += "<tr>"
	cTexto  += "<td><b>Data / Hora Integração</b></td>"
	cTexto  += "<td>"+dtoc(date())+"  -  "+time()+" hs.</td>"
	cTexto  += "</tr>"

	cTexto  += "<tr>"
	cTexto  += "<td><b>Código MERCANET</b></td>"
	cTexto  += "<td>"+TRBZ1A->Z1A_CODMER+"</td>"
	cTexto  += "</tr>"

    if !lErro
		cTexto  += "<tr>"
		cTexto  += "<td><b>Código PROTHEUS</b></td>"
		cTexto  += "<td>"+cCod+"</td>"
		cTexto  += "</tr>"
	endif 

	cTexto  += "<tr>"
	cTexto  += "<td><b>Razão Social</b></td>"
	cTexto  += "<td>"+TRBZ1A->Z1A_NOME+"</td>"
	cTexto  += "</tr>"

	cTexto  += "<tr>"
	cTexto  += "<td><b>Município</b></td>"
	cTexto  += "<td>"+alltrim(TRBZ1A->Z1A_MUN)+" - "+TRBZ1A->Z1A_EST+"</td>"
	cTexto  += "</tr>"

	cTexto  += "<tr>"
	cTexto  += "<td><b>CNPJ</b></td>"
	cTexto  += "<td>"+TRBZ1A->Z1A_CGC+"</td>"
	cTexto  += "</tr>"

	cTexto  += "<tr>"
	cTexto  += "<td><b>Vendedor</b></td>"
	cTexto  += "<td>"+TRBZ1A->Z1A_VEND+" - " +posicione("SA3",1,xFilial("SA3")+TRBZ1A->Z1A_VEND,"A3_NOME")+"</td>"
	cTexto  += "</tr>"

	cTexto  += "<tr>"
	cTexto  += "<td><b>Supervisor</b></td>"
	cTexto  += "<td>"+Posicione("ZOH",1,xFilial("ZOH")+TRBZ1A->Z1A_VEND+substr(dtos(DATE()),1,4),"ZOH_SUP")+"</td>"
	cTexto  += "</tr>"

	cTexto  += "<tr>"
	cTexto  += "<td><b>Gerente</b></td>"
	cTexto  += "<td>"+Posicione("ZOH",1,xFilial("ZOH")+TRBZ1A->Z1A_VEND+substr(dtos(DATE()),1,4),"ZOH_ATN")+"</td>"
	cTexto  += "</tr>"

	cTexto  += "</table>"
	_cAnexos := ""

	U_SUBEML(cMailCli,cTitulo,cTexto,_cAnexos)

Return


Static Function chkCli(_cCnpj)

    Local lAchou 

	SA1->(dbSetOrder(3))
	lAchou := SA1->(dbSeek(xFilial("SA1")+_cCnpj))

		
Return(lAchou)
