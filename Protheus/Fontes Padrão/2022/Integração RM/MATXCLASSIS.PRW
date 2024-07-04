#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "MATXCLASSIS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³			                                                              ³±±
±±³        ROTINAS GENERICAS DE CONTEXTO "MATERIAIS" USADAS               ³±±
±±³		     PELA INTEGRACAO PROTHEUS X TOTVS EDUCACIONAL 				  ³±±
±±³		              (RM CLASSISNET E RM BIBLIOS)						  ³±±
±±³			                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsInBcoAg
Funcao responsavel pela Integracao de banco, Agencia e Conta entre os sistemas Protheus x TOTVS Educacional (RM)

@param	ExpL1  = .T.=Reprocessamento do registro; .F.=Proc. Normal
		ExpC1  = ID do Registro na tabela de Integracao
		ExpL2  = Gera registro na tabela INT_CONTACXALOG (.T.=Sim)
		ExpC2  = Tipo Operacao: (I=Insert; U=Update D=Delete)
		ExpC3  = Empresa
		ExpC4  = Filial
		ExpL3  = .T.=Caixa (Tesouraria); .F.=Conta Normal
		ExpC5  = Rotina Responsavel pela gravacao
		ExpC6  = Banco
		ExpC7  = Nome do Banco
		ExpC8  = Nome reduzido
		ExpC9  = Agencia
		ExpC10 = Nome da Agencia
		ExpC11 = Endereco Agencia
		ExpC12 = Bairro da Agencia
		ExpC13 = Municipio Agencia
		ExpC14 = Estado da Agencia
		ExpC15 = CEP Agencia
		ExpC16 = Telefone Agencia
		ExpC17 = Pais
		ExpC18 = Conta
		ExpC19 = Dig. da Conta
		ExpC20 = Cedente
		ExpN1  = Codigo Cedente
		ExpN2  = Tipo Carteira
		ExpC21 = Carteira
		ExpC22 = Codigo Conta Caixa
		ExpN3  = Saldo Atual
		ExpC23 = Bloqueado (1=Sim; 2=Nao)

@author  Alberto Deviciente
@version P10
@since 	 26/06/09
@return lRet - .T. para inclusao ok. / .F. para falhas durante a inclusao.
/*/
//-------------------------------------------------------------------------------------
Function ClsInBcoAg(lReproc,cIdReg,lGeraLog,cOperacao,cEmp,cFil,lCaixa,cRotGrava,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado)
Local aArea  		:= GetArea()
Local nAmbTOP 		:= 0
Local nAmbCLASSIS 	:= 0
Local lTopOk  		:= .F.
Local lRet 			:= .F.
Local cUsuGrava 	:= "PROTHEUS"
Local cRotImport  	:= "S" //Para qual Rotina sera importado (S=RM Classis Net)
Local cQuery 		:= ""
Local lContinue		:= .T.
Local cTipoCart 	:= Alltrim(str(nTipoCart))
Local cAtivo 		:= iif(cBloqueado == '2','1','2') //1=Ativo, 2=Inativo
Local cMsgLog 		:= ""

cBanco 	 	:= Alltrim(cBanco)
cNomeBco 	:= iif(lCaixa,STR0001,Alltrim(cNomeBco))   //CAIXA
cNomeReduz  := iif(lCaixa,STR0001,Alltrim(cNomeReduz))	//CAIXA
cAgencia	:= iif(lCaixa,STR0001,Alltrim(cAgencia))	//CAIXA
cNomeAge 	:= iif(lCaixa,STR0001,Alltrim(cNomeAge))	//CAIXA
cEndAge 	:= Alltrim(cEndAge)
cBairroAge	:= Alltrim(cBairroAge)
cMunAge 	:= Alltrim(cMunAge)
cEstAge 	:= iif(lCaixa,'SP',ClsEstMex(cEstAge)) 		//Caso seja caixa, manter como SP pois ESTADO eh FOREIGN KEY de GAGENCIA (?!)
cCepAge 	:= Alltrim(cCepAge)
cTelAge 	:= Alltrim(cTelAge)
cPais 		:= Alltrim(cPais)
cConta 		:= Alltrim(cConta)
cDigConta 	:= Alltrim(cDigConta)
cCedente 	:= Alltrim(cCedente)
cCodCed 	:= Alltrim(cCodCed)
cCarteira 	:= Alltrim(cCarteira)
cCodCXA 	:= Alltrim(cCodCXA)

//Verifica se alguma variavel esta vazia e atribui um espaco para nao gerar erro qdo. for Banco de dados Oracle
cBanco 	 	:= iif(empty(cBanco)," ",cBanco)
cNomeBco 	:= iif(empty(cNomeBco)," ",cNomeBco)
cNomeReduz  := iif(empty(cNomeReduz)," ",cNomeReduz)
cAgencia	:= iif(empty(cAgencia)," ",cAgencia)
cNomeAge 	:= iif(empty(cNomeAge)," ",cNomeAge)
cEndAge 	:= iif(empty(cEndAge)," ",cEndAge)
cBairroAge	:= iif(empty(cBairroAge)," ",cBairroAge)
cMunAge 	:= iif(empty(cMunAge)," ",cMunAge)
cEstAge 	:= iif(empty(cEstAge)," ",cEstAge)
cCepAge 	:= iif(empty(cCepAge)," ",cCepAge)
cTelAge 	:= iif(empty(cTelAge)," ",cTelAge)
cPais 		:= iif(empty(cPais)," ",cPais)
cConta 		:= iif(empty(cConta)," ",cConta)
cDigConta 	:= iif(empty(cDigConta)," ",cDigConta)
cCedente 	:= iif(empty(cCedente)," ",cCedente)
cCodCed 	:= iif(empty(cCodCed)," ",cCodCed)
cCarteira 	:= iif(empty(cCarteira)," ",cCarteira)
cCodCXA 	:= iif(empty(cCodCXA)," ",cCodCXA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca a conexao com a base do Sistema RM  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lTopOk := .F.

if lTopOk
	lRet := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for INCLUSAO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if cOperacao == "I" //Insert
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seta a conexao do TOP com a base do Sistema RM ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TCSetConn(nAmbCLASSIS)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³*** BANCO ***  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Antes de inserir verifica se ainda nao existe o registro na GBANCO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := " SELECT COUNT(NUMBANCO) TOTAL FROM GBANCO "
		cQuery += " WHERE NUMBANCO = '" + cBanco + "'"
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registro ainda nao existe, entao insere³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TCQ->TOTAL == 0
			cQuery := " INSERT INTO GBANCO "
			cQuery += "(NUMBANCO, NOME, NOMEREDUZIDO, NUMEROOFICIAL) "
			cQuery += "	VALUES ('" + cBanco + "','" + cNomeBco + "','" + cNomeReduz + "','" + cBanco + "')"
			If TCSqlExec(cQuery) < 0
				conout(STR0002 +" GBANCO "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar incluir o registro na tabela" ### "do sistema RM Classis Net: "
				MsgStop(STR0002+" GBANCO "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar incluir o registro na tabela" ### "do sistema RM Classis Net: "
				lRet := .F.
				lContinue := .F.
				
				cMsgLog := alltrim(TcSqlError())
				cStatusImport := "3"
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seta a conexao do TOP com a base da Protheus|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TCSetConn( nAmbTOP )
				
				if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
					//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
					ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
				else
					if lGeraLog //Gera LOG na tabela INT_CONTACXALOG	
						//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
						ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
					endif
				endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seta a conexao do TOP com a base do Sistema RM ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TCSetConn(nAmbCLASSIS)
			else
				TcSqlExec("COMMIT")
			endif
		endif
		TCQ->(dbCloseArea())
		
		if lContinue
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³*** AGENCIA ***³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Antes de inserir verifica se ainda nao existe o registro na tabela GAGENCIA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := " SELECT COUNT(NUMAGENCIA) TOTAL FROM GAGENCIA "
			cQuery += " WHERE NUMBANCO = '" + cBanco + "' AND NUMAGENCIA = '" + cAgencia + "'"
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Registro ainda nao existe, entao insere³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TCQ->TOTAL == 0
				cQuery := " INSERT INTO GAGENCIA "
				cQuery += " (NUMBANCO,NUMAGENCIA,NOME,RUA,BAIRRO,ESTADO,CIDADE,CEP,TELEFONE,PAIS) "
				cQuery += " VALUES ('" + cBanco + "','" + cAgencia + "','" + cNomeAge + "',"
				cQuery += "'" + cEndAge + "','" + cBairroAge + "','" + cEstAge + "','" + cMunAge + "',"
				cQuery += "'" + cCepAge + "','" + cTelAge + "','" + cPais + "')"
				If TCSqlExec(cQuery) < 0
					conout( STR0002+" GAGENCIA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar incluir o registro na tabela" ### "do sistema RM Classis Net: "
					MsgStop(STR0002+" GAGENCIA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar incluir o registro na tabela" ### "do sistema RM Classis Net: "
					lRet := .F.
					lContinue := .F.
					
					cMsgLog := alltrim(TcSqlError())
					cStatusImport := "3"
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base da Protheus|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn( nAmbTOP )
					
					if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
						//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
						ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
					else
						if lGeraLog //Gera LOG na tabela INT_CONTACXALOG	
							//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
							ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
						endif
					endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base do Sistema RM ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn(nAmbCLASSIS)
				else
					TcSqlExec("COMMIT")
				endif
			endif
			TCQ->(dbCloseArea())
		endif
		
		if lContinue
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³*** CONTA ***  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Antes de inserir verifica se ainda nao existe o registro na tabela FCONTA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := " SELECT COUNT(NROCONTA) TOTAL FROM FCONTA "
			cQuery += " WHERE CODCOLIGADA = " + cEmp
			cQuery += "   AND NUMBANCO    = '" + cBanco + "'"
			cQuery += "   AND NUMAGENCIA  = '" + cAgencia + "'"
			cQuery += "   AND NROCONTA    = '" + cConta + "'"
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Registro ainda nao existe, entao insere³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TCQ->TOTAL == 0
				cQuery := " INSERT INTO FCONTA "
				cQuery += " (CODCOLIGADA,NUMBANCO,NUMAGENCIA,NROCONTA,CEDENTE,CODCEDENTE,TIPOCARTEIRA,CARTEIRA,DIGCONTA) "
				cQuery += " VALUES (" + cEmp + ",'" + cBanco + "','" + cAgencia + "','" + cConta + "','" + cCedente + "',"
				cQuery += " '" + cCodCed + "'," + cTipoCart + ",'"  + cCarteira + "','" + cDigConta + "')"
				If TCSqlExec(cQuery) < 0
					conout( STR0002+" FCONTA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar incluir o registro na tabela" ### "do sistema RM Classis Net: "
					MsgStop(STR0002+" FCONTA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar incluir o registro na tabela" ### "do sistema RM Classis Net: "
					lRet := .F.
					lContinue := .F.
					
					cMsgLog := alltrim(TcSqlError())
					cStatusImport := "3"
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base da Protheus|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn( nAmbTOP )
					
					if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
						//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
						ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
					else
						if lGeraLog //Gera LOG na tabela INT_CONTACXALOG
							//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
							ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
						endif
					endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base do Sistema RM ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn(nAmbCLASSIS)
				else
					TcSqlExec("COMMIT")
				endif
			endif
			TCQ->(dbCloseArea())
		endif
		
		if lContinue
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³*** CONTA CAIXA (Banco, Agencia e Conta) *** ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Antes de inserir verifica se ainda nao existe o registro na tabela FCXA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := " SELECT COUNT(CODCXA) TOTAL FROM FCXA "
			cQuery += " WHERE CODCOLIGADA = " + cEmp
			cQuery += "   AND CODCXA = '" + cCodCXA + "'"
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Registro ainda nao existe, entao insere³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If TCQ->TOTAL == 0 .and. lContinue
				cQuery := " INSERT INTO FCXA "
				cQuery += " (CODCOLIGADA,CODCXA,DESCRICAO,SALDODATABASE,NUMBANCO,NUMAGENCIA,NROCONTA,"
				cQuery += " CODCOLCONTA,ATIVA, CODMOEDA, SALDONAOCOMPENSADO, DATABASECXA, SALDOINSTANTANEO,CODCOLPROP) "
				cQuery += " VALUES (" + cEmp + ",'" + cCodCXA + "','" + cNomeBco + "'," + alltrim(str(nSaldoAtu)) + ","
				cQuery += "'" + cBanco + "','" + cAgencia + "','" + cConta + "'," + cEmp + "," + cAtivo + ","
				cQuery += "'R$',0," + ClsQryDat(dDataBase,.T.) + ",0,"+ cEmp +")"
				If TCSqlExec(cQuery) < 0
					conout( STR0002+" FCXA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar incluir o registro na tabela" ### "do sistema RM Classis Net: "
					MsgStop(STR0002+" FCXA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar incluir o registro na tabela" ### "do sistema RM Classis Net: "
					lRet := .F.
					lContinue := .F.
					
					cMsgLog := alltrim(TcSqlError())
					cStatusImport := "3"
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base da Protheus|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn( nAmbTOP )
					
					if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
						//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
						ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
					else
						if lGeraLog //Gera LOG na tabela INT_CONTACXALOG
							//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
							ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
						endif
					endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base do Sistema RM ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn(nAmbCLASSIS)
				else
					TcSqlExec("COMMIT")
				endif
			endif
			TCQ->(dbCloseArea())
		endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for ALTERACAO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	elseif cOperacao == "U" //Update
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seta a conexao do TOP com a base do Sistema RM ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TCSetConn(nAmbCLASSIS)
		
		/* Efetua a Alteracao na tabela GBANCO*/ 
		cQuery := "UPDATE GBANCO SET "
		cQuery += " NOME = '"+cNomeBco+"', NOMEREDUZIDO = '"+cNomeReduz+"'"
		cQuery += " WHERE NUMBANCO = '"+cBanco+"'"
		if TCSqlExec(cQuery) < 0
			conout( STR0004+" GBANCO "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar atualizar o registro na tabela" ### "do sistema RM Classis Net: "
			MsgStop(STR0004+" GBANCO "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar atualizar o registro na tabela" ### "do sistema RM Classis Net: "
			lRet := .F.
			lContinue := .F.
			
			cMsgLog := alltrim(TcSqlError())
			cStatusImport := "3"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seta a conexao do TOP com a base da Protheus|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TCSetConn( nAmbTOP )
			
			if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
				//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
				ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
			else
				if lGeraLog //Gera LOG na tabela INT_CONTACXALOG
					//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
					ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
				endif
			endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seta a conexao do TOP com a base do Sistema RM ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TCSetConn(nAmbCLASSIS)
		else
			TcSqlExec("COMMIT")
		endif
		
		if lContinue
			/* Efetua a Alteracao na tabela GAGENCIA*/ 
			cQuery := "UPDATE GAGENCIA SET "
			cQuery += " NOME = '"+cNomeAge+"', RUA = '"+cEndAge+"', ESTADO = '"+ cEstAge+ "', BAIRRO = '" + cBairroAge + "'"
		 	cQuery += ",CIDADE = '" + cMunAge + "', CEP = '" + cCepAge + "', TELEFONE = '" + cTelAge + "', PAIS = '"+cPais+"'"
			cQuery += " WHERE NUMBANCO = '"+cBanco+"' AND NUMAGENCIA = '"+ cAgencia + "'"
			if TCSqlExec(cQuery) < 0
				conout( STR0004+" GAGENCIA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar atualizar o registro na tabela" ### "do sistema RM Classis Net: "
				MsgStop(STR0004+" GAGENCIA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar atualizar o registro na tabela" ### "do sistema RM Classis Net: "
				lRet := .F.
				lContinue := .F.
				
				cMsgLog := alltrim(TcSqlError())
				cStatusImport := "3"
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seta a conexao do TOP com a base da Protheus|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TCSetConn( nAmbTOP )
				
				if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
					//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
					ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
				else
					if lGeraLog //Gera LOG na tabela INT_CONTACXALOG
						//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
						ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
					endif
				endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seta a conexao do TOP com a base do Sistema RM ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TCSetConn(nAmbCLASSIS)
			else
				TcSqlExec("COMMIT")
			endif
		endif
		
		if lContinue
			/* Efetua a Alteracao na tabela FCONTA*/ 
			cQuery := "UPDATE FCONTA SET "
			cQuery += " CEDENTE = '"+cCedente+"', CODCEDENTE = '"+cCodCed+"', TIPOCARTEIRA = "+ cTipoCart
		 	cQuery += " ,CARTEIRA = '" + cCarteira + "', DIGCONTA = '" + cDigConta + "'"
			cQuery += " WHERE CODCOLIGADA = " + cEmp + " AND NUMBANCO = '"+cBanco+"' AND NUMAGENCIA = '"+ cAgencia + "'"
		    cQuery += " AND NROCONTA = '" + cConta + "'"  
			if TCSqlExec(cQuery) < 0
				conout( STR0004+" FCONTA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar atualizar o registro na tabela" ### "do sistema RM Classis Net: "
				MsgStop(STR0004+" FCONTA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar atualizar o registro na tabela" ### "do sistema RM Classis Net: "
				lRet := .F.
				lContinue := .F.
				
				cMsgLog := alltrim(TcSqlError())
				cStatusImport := "3"
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seta a conexao do TOP com a base da Protheus|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TCSetConn( nAmbTOP )
				
				if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
					//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
					ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
				else
					if lGeraLog //Gera LOG na tabela INT_CONTACXALOG
						//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
						ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
					endif
				endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seta a conexao do TOP com a base do Sistema RM ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TCSetConn(nAmbCLASSIS)
			else
				TcSqlExec("COMMIT")
			endif
		endif
	 	
	 	if lContinue
		 	/* Antes de atualizar verifica se existe o registro na tabela FCXA */ 
		   	cQuery := "SELECT COUNT(CODCXA) TOTAL"
		   	cQuery += "  FROM FCXA "
		   	cQuery += " WHERE CODCOLIGADA = "+ cEmp + " AND CODCXA = '"+ cCodCXA +"'"
		   	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)
		   	
		    if TCQ->TOTAL > 0 //Registro existe, entao efetua a atualizacao FCXA  
			   /* Efetua a Alteracao na tabela FCXA*/ 
			   cQuery := " UPDATE FCXA SET "
			   cQuery += " DESCRICAO = '"+cNomeBco+"', SALDODATABASE = " +alltrim(str(nSaldoAtu))+ ", CODCOLCONTA = "+cEmp + ", ATIVA = " + cAtivo
			   cQuery += "  WHERE CODCOLIGADA = " + cEmp + " AND CODCXA = '" + cCodCXA + "' AND NUMBANCO = '"+cBanco+"'"
		       cQuery += "    AND NUMAGENCIA = '"+ cAgencia + "' AND NROCONTA = '" + cConta + "'"
				if TCSqlExec(cQuery) < 0
					conout( STR0004+" FCXA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar atualizar o registro na tabela" ### "do sistema RM Classis Net: "
					MsgStop(STR0004+" FCXA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar atualizar o registro na tabela" ### "do sistema RM Classis Net: "
					lRet := .F.
					lContinue := .F.
					
					cMsgLog := alltrim(TcSqlError())
					cStatusImport := "3"
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base da Protheus|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn( nAmbTOP )
					
					if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
						//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
						ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
					else
						if lGeraLog //Gera LOG na tabela INT_CONTACXALOG
							//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
							ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
						endif
					endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base do Sistema RM ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn(nAmbCLASSIS)
				else
					TcSqlExec("COMMIT")
				endif
		   	else
				cMsgLog := STR0005 +cCodCXA+ STR0006 //"Ao tentar atualizar, a Conta Caixa "###" nao foi encontrada na tabela FCXA do sistema RM Classis Net."
				cStatusImport := "3"
				lRet := .F.
				lContinue := .F.
				
				conout(cMsgLog)
				MsgStop(cMsgLog)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seta a conexao do TOP com a base da Protheus|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TCSetConn( nAmbTOP )
				
				if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
					//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
					ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
				else
					if lGeraLog //Gera LOG na tabela INT_CONTACXALOG	
						//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
						ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
					endif
				endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seta a conexao do TOP com a base do Sistema RM ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TCSetConn(nAmbCLASSIS)
		    endif
			TCQ->(dbCloseArea())
		endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for EXCLUSAO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	elseif cOperacao == "D" //Delecao
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seta a conexao do TOP com a base do Sistema RM ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TCSetConn(nAmbCLASSIS)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclusao da Conta Caixa (Tabela FCXA)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "DELETE FROM FCXA "
		cQuery += " WHERE CODCOLIGADA = " +cEmp+ " AND CODCXA = '" +cCodCXA+ "'"
		cQuery += "   AND NUMBANCO = '"+cBanco+"' AND NUMAGENCIA = '"+cAgencia+ "'"
	    cQuery += "   AND NROCONTA = '" +cConta+ "'"
		if TCSqlExec(cQuery) < 0
			conout( STR0007+" FCXA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar excluir o registro na tabela" ### "do sistema RM Classis Net: "
			MsgStop(STR0007+" FCXA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar excluir o registro na tabela" ### "do sistema RM Classis Net: "
			lRet := .F.
			lContinue := .F.
			
			cMsgLog := alltrim(TcSqlError())
			cStatusImport := "3"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seta a conexao do TOP com a base da Protheus|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TCSetConn( nAmbTOP )
			
			if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
				//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
				ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
			else
				if lGeraLog //Gera LOG na tabela INT_CONTACXALOG
					//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
					ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
				endif
			endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seta a conexao do TOP com a base do Sistema RM ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TCSetConn(nAmbCLASSIS)
		else
			TcSqlExec("COMMIT")
		endif
		
		if lContinue
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exclusao da Conta (Tabela FCONTA)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/* Verifica se existe mais Conta Caixa utilizando o mesmo banco, agencia e conta */ 
		   	cQuery := "SELECT COUNT(NROCONTA) TOTAL "
		   	cQuery += "  FROM FCXA "
		   	cQuery += " WHERE CODCOLIGADA = " + cEmp + " AND NUMBANCO = '" + cBanco + "'"
		   	cQuery += "   AND NUMAGENCIA = '" + cAgencia + "' AND NROCONTA = '" + cConta + "'"
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)
		    
			if TCQ->TOTAL == 0  //Nao existe Registro utilizando o mesmo banco, agencia e conta, entao deleta a conta 
			   	/* Efetua a exclusao da conta na tabela FCONTA*/ 
			   	cQuery := "DELETE FCONTA " 
			   	cQuery += " WHERE CODCOLIGADA = " + cEmp + " AND NUMBANCO = '"+cBanco+"'"
			   	cQuery += "   AND NUMAGENCIA = '"+ cAgencia + "' AND NROCONTA = '" + cConta + "'"
				if TCSqlExec(cQuery) < 0
					conout( STR0007+" FCONTA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar excluir o registro na tabela" ### "do sistema RM Classis Net: "
					MsgStop(STR0007+" FCONTA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar excluir o registro na tabela" ### "do sistema RM Classis Net: "
					lRet := .F.
					lContinue := .F.
					
					cMsgLog := alltrim(TcSqlError())
					cStatusImport := "3"
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base da Protheus|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn( nAmbTOP )
					
					if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
						//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
						ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
					else
						if lGeraLog //Gera LOG na tabela INT_CONTACXALOG
							//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
							ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
						endif
					endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base do Sistema RM ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn(nAmbCLASSIS)
				else
					TcSqlExec("COMMIT")
				endif
			endif
			TCQ->(dbCloseArea())
		endif
		
		if lContinue
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exclusao da Agencia (Tabela GAGENCIA)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*verifica se existe mais alguma outra Conta utilizando o mesmo banco e agencia*/ 
		   	cQuery := "SELECT COUNT(NUMBANCO) TOTAL " 
		   	cQuery += "  FROM FCONTA "
		   	cQuery += " WHERE CODCOLIGADA = " +cEmp+ " AND NUMBANCO = '" +cBanco+ "' AND NUMAGENCIA = '"+cAgencia+ "'" 
		   	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)
			
			if TCQ->TOTAL == 0  //Nao existe Registro utilizando o mesmo banco e agencia, entao deleta agencia 
			   /* Efetua a exclusão na tabela GAGENCIA*/ 
			   cQuery := "DELETE FROM GAGENCIA "
			   cQuery += " WHERE NUMBANCO = '"+cBanco+"' AND NUMAGENCIA = '"+cAgencia+ "'"
				if TCSqlExec(cQuery) < 0
					conout( STR0007+" GAGENCIA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar excluir o registro na tabela" ### "do sistema RM Classis Net: "
					MsgStop(STR0007+" GAGENCIA "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar excluir o registro na tabela" ### "do sistema RM Classis Net: "
					lRet := .F.
					lContinue := .F.
					
					cMsgLog := alltrim(TcSqlError())
					cStatusImport := "3"
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base da Protheus|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn( nAmbTOP )
					
					if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
						//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
						ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
					else
						if lGeraLog //Gera LOG na tabela INT_CONTACXALOG
							//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
							ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
						endif
					endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base do Sistema RM ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn(nAmbCLASSIS)
				else
					TcSqlExec("COMMIT")
				endif
			endif
			TCQ->(dbCloseArea())
		endif
		
		if lContinue
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exclusao do Banco (Tabela GBANCO)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*verifica se existe mais alguma outra Conta utilizando o mesmo banco*/ 
		   	cQuery := "SELECT count(NUMBANCO) TOTAL "
		   	cQuery += "  FROM FCONTA "
		   	cQuery += " WHERE CODCOLIGADA = " +cEmp+ " AND NUMBANCO = '" +cBanco+ "'" 
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)
			
			if TCQ->TOTAL == 0  // nao existe Registro utilizando o mesmo banco, entao deleta banco 
				/* Efetua a exclusão na tabela GBANCO*/ 
			   	cQuery := "DELETE FROM GBANCO "
		       	cQuery += " WHERE NUMBANCO = '"+cBanco+"'" 
				if TCSqlExec(cQuery) < 0
					conout( STR0007+" GBANCO "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar excluir o registro na tabela" ### "do sistema RM Classis Net: "
					MsgStop(STR0007+" GBANCO "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar excluir o registro na tabela" ### "do sistema RM Classis Net: "
					lRet := .F.
					lContinue := .F.
					
					cMsgLog := alltrim(TcSqlError())
					cStatusImport := "3"
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base da Protheus|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn( nAmbTOP )
					
					if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
						//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
						ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
					else
						if lGeraLog //Gera LOG na tabela INT_CONTACXALOG
							//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
							ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
						endif
					endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seta a conexao do TOP com a base do Sistema RM ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TCSetConn(nAmbCLASSIS)
				else
					TcSqlExec("COMMIT")
				endif
			endif
			TCQ->(dbCloseArea())
		endif
		
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seta a conexao do TOP com a base da Protheus|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TCSetConn( nAmbTOP )
	
	TCUNLINK(nAmbCLASSIS) //Finaliza a conexao do TOP com a base do Sistema RM
endif

RestArea(aArea)
Return lRet 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsInBcoPr
Funcao responsavel pela Integracao de parametros de banco entre os sistemas Protheus x TOTVS Educacional (RM)

@param	lReproc		= .T.=Reprocessamento do registro; .F.=Proc. Normal
       	cIdReg			= ID do Registro na tabela de Integracao
       	lGeraLog		= Gera registro na tabela INT_CONTACXALOG (.T.=Sim)
       	cOperacao		= Tipo Operacao: (I=Insert; U=Update D=Delete)
       	cEmp			= Empresa
       	cFil			= Filial
       	cIDCONVENIO	= ID do convenio
       	cNUMBANCO		= Numero do Banco
       	cNUMAGENCIA	= Numero da Agencia
       	cNROCONTA		= Numero da Conta
       	cCONVENIO		= Numero do convenio
       	cNOMECARTEIRA	= 
       	cTIPOCARTEIRA	=
       	cCODCEDENTE	=
       	cTIPOCOB		=
       	cCODCXA 		=

@author  Caio Quiqueto dos Santos
@version P11
@since 	 01/04/2014
@return  lRet - .T. para inclusao ok. / .F. para falhas durante a inclusao.
/*/
//-------------------------------------------------------------------------------------

function ClsInBcoPr (lReproc,cIdReg,lGeraLog,cOperacao,cEmp,cFil,cIDCONVENIO,cNUMBANCO,cNUMAGENCIA,cNROCONTA,cCONVENIO,cNOMECARTEIRA,cTIPOCARTEIRA,cCODCEDENTE,cTIPOCOB,cCODCXA)
Local aArea  		:= GetArea()
Local nAmbTOP 		:= 0
Local nAmbCLASSIS 	:= 0
Local lTopOk  		:= .F.
Local lRet 			:= .F.
Local cUsuGrava 	:= "PROTHEUS"
Local cRotImport  	:= "S" //Para qual Rotina sera importado (S=RM Classis Net)
Local cQuery 		:= ""
Local lContinue		:= .T.
Local cMsgLog 		:= ""

	//Busca a conexao com a base do Sistema RM
	lTopOk := .F.
	
	if lTopOk
		lRet := .T.
		
		//Se for INCLUSAO
		if cOperacao == "I" //Insert
			//Convenio
			//Antes de inserir verifica se ainda nao existe o registro na tabela FCONVENIO
			cQuery := " SELECT COUNT(IDCONVENIO) TOTAL FROM FCONVENIO "
			cQuery += " WHERE CODCOLIGADA = " 	+ cEmp
			cQuery += " AND NUMBANCO = '"		+ cNUMBANCO +"'"
			cQuery += " AND NUMAGENCIA = '"		+ cNUMAGENCIA +"'"
			cQuery += " AND NROCONTA = '"		+ cNROCONTA	+"'"
			cQuery += " AND CODCXA = '" 		+ cCODCXA 	+ "'"
			cQuery += " AND CONVENIO = '"		+ cCONVENIO + "'"
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)
			
			//Registro ainda nao existe, entao insere
			If TCQ->TOTAL == 0 .and. lContinue
				//pega o proximo IDconveio
				cIDCONVENIO	:= ClsNxtGaut(nAmbTop,nAmbCLASSIS,"F","IDCONVENIO")
			
				cQuery := " INSERT INTO FCONVENIO "
				cQuery += " (CODCOLIGADA,IDCONVENIO,NUMBANCO,NUMAGENCIA,CODCOLCONTA,NROCONTA,CONVENIO,CARTEIRA,TIPOCARTEIRA,CODCEDENTE,TIPOCOB,CODCOLCXA,CODCXA,TIPONOSSONUMERO) "
				cQuery += " values ("+cEmp+",'"+str(cIDCONVENIO)+"','"+cNUMBANCO+"',"+cNUMAGENCIA+","+cEmp+","+cNROCONTA+","+cCONVENIO
				cQuery += ","+cNOMECARTEIRA+","+cTIPOCARTEIRA+","+cCODCEDENTE+","+cTIPOCOB+","+cEmp+",'"+cCODCXA+"',2)"
				If TCSqlExec(cQuery) < 0
					conout( STR0002+" FCONVENIO "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar incluir o registro na tabela" ### "do sistema RM Classis Net: "
					MsgStop(STR0002+" FCONVENIO "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar incluir o registro na tabela" ### "do sistema RM Classis Net: "
					lRet := .F.
					lContinue := .F.
					
					cMsgLog := alltrim(TcSqlError())
					cStatusImport := "3"
					
					//Seta a conexao do TOP com a base da Protheus
					TCSetConn( nAmbTOP )
					
					if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
						//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
						ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
					else
						if lGeraLog //Gera LOG na tabela INT_CONTACXALOG
							//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
							ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
						endif
					endif
					
					//Seta a conexao do TOP com a base do Sistema RM 
					TCSetConn(nAmbCLASSIS)
				else
					TcSqlExec("COMMIT")
				endif
			endif
			TCQ->(dbCloseArea())
		
		//Se for ALTERACAO
		elseif cOperacao == "U" //Update
		 	/* Antes de atualizar verifica se existe o registro na tabela FCONVENIO */ 
			cQuery := " SELECT COUNT(IDCONVENIO) TOTAL FROM FCONVENIO "
			cQuery += " WHERE CODCOLIGADA = " 	+ cEmp
			cQuery += " AND NUMBANCO = '"		+ cNUMBANCO +"'"
			cQuery += " AND NUMAGENCIA = '"		+ cNUMAGENCIA +"'"
			cQuery += " AND NROCONTA = '"		+ cNROCONTA +"'"
			cQuery += " AND CODCXA = '" 		+ cCODCXA 	+ "'"
			cQuery += " AND CONVENIO = '" 		+ cCONVENIO 	+ "'"
		   	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)
		   	
		    if TCQ->TOTAL > 0 //Registro existe, entao efetua a atualizacao FCONVENIO  
			   /* Efetua a Alteracao na tabela FCONVENIO*/ 
			   cQuery := " UPDATE FCONVENIO SET "
			   cQuery += " CARTEIRA = " +cNOMECARTEIRA+ ", TIPOCARTEIRA = "+cTIPOCARTEIRA+ ", CODCEDENTE = " + cCODCEDENTE +  ", TIPOCOB = " + cTIPOCOB
			   cQuery += "  WHERE CODCOLCONTA = " + cEmp + " AND CODCXA = '" + cCODCXA + "' AND NUMBANCO = '"+cNUMBANCO+"'"
		       cQuery += "    AND NUMAGENCIA = '"+ cNUMAGENCIA + "' AND NROCONTA = '" + cNROCONTA + "'"
				if TCSqlExec(cQuery) < 0
					conout( STR0004+" FCONVENIO "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar atualizar o registro na tabela" ### "do sistema RM Classis Net: "
					MsgStop(STR0004+" FCONVENIO "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar atualizar o registro na tabela" ### "do sistema RM Classis Net: "
					lRet := .F.
					lContinue := .F.
					
					cMsgLog := alltrim(TcSqlError())
					cStatusImport := "3"
					
					//Seta a conexao do TOP com a base da Protheus
					TCSetConn( nAmbTOP )
					
					if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
						//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
						ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
					else
						if lGeraLog //Gera LOG na tabela INT_CONTACXALOG
							//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
							ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
						endif
					endif
					
					//Seta a conexao do TOP com a base do Sistema RM 
					TCSetConn(nAmbCLASSIS)
				else
					TcSqlExec("COMMIT")
				endif
		   	else
				cMsgLog := STR0005 +cCodCXA+ STR0006 //"Ao tentar atualizar, a Conta Caixa "###" nao foi encontrada na tabela FCXA do sistema RM Classis Net."
				cStatusImport := "3"
				lRet := .F.
				lContinue := .F.
				
				conout(cMsgLog)
				MsgStop(cMsgLog)
				
				//Seta a conexao do TOP com a base da Protheus
				TCSetConn( nAmbTOP )
				
				if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
					//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
					ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
				else
					if lGeraLog //Gera LOG na tabela INT_CONTACXALOG	
						//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
						ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
					endif
				endif
				
				//Seta a conexao do TOP com a base do Sistema RM 
				TCSetConn(nAmbCLASSIS)
		    endif
			TCQ->(dbCloseArea())
			
		//Se for EXCLUSAO
		elseif cOperacao == "D" //Delecao
					
			//Seta a conexao do TOP com a base do Sistema RM 
			TCSetConn(nAmbCLASSIS)
			
			//Exclusao da Conta Caixa (Tabela FCONVENIO)
			cQuery := "DELETE FROM FCONVENIO "
			cQuery += "  WHERE CODCOLCONTA = " + cEmp + " AND CODCXA = '" + cCODCXA + "' AND NUMBANCO = '"+cNUMBANCO+"'"
			cQuery += "    AND NUMAGENCIA = '"+ cNUMAGENCIA + "' AND NROCONTA = '" + cNROCONTA + "'"
			if TCSqlExec(cQuery) < 0
				conout( STR0007+" FCONVENIO "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar excluir o registro na tabela" ### "do sistema RM Classis Net: "
				MsgStop(STR0007+" FCONVENIO "+STR0003+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar excluir o registro na tabela" ### "do sistema RM Classis Net: "
				lRet := .F.
				lContinue := .F.
				
				cMsgLog := alltrim(TcSqlError())
				cStatusImport := "3"
				
				//Seta a conexao do TOP com a base da Protheus
				TCSetConn( nAmbTOP )
				
				if lReproc //Reprocessamento atraves do Monitor de Transacoes da Integracao
					//Apenas atualiza a mensagem de erro na tabela de integracao INT_CONTACXALOG
					ClsBcAgLog(cIdReg,,,,,,,,,,,,,,,,,,,,,,,,,cMsgLog,,,,)
				else
					if lGeraLog //Gera LOG na tabela INT_CONTACXALOG
						//Inclui o registro da tabela INT_CONTACXALOG, informando a inconsistência existente
						ClsBcAgLog("",cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
					endif
				endif
				
				//Seta a conexao do TOP com a base do Sistema RM 
				TCSetConn(nAmbCLASSIS)
			else
				TcSqlExec("COMMIT")
			endif
			
		EndIf
		
	
		//Seta a conexao do TOP com a base da Protheus
	
		TCSetConn( nAmbTOP )
	
		TCUNLINK(nAmbCLASSIS) //Finaliza a conexao do TOP com a base do Sistema RM
	EndIf
	

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsBcAgLog
Funcao responsavel pela Integracao de banco, Agencia e Conta entre os sistemas 
Protheus x RM Classis Net (RM). Faz a gravacao de LOG na tabela INT_CONTACXALOG. 

@param	ExpC1 = ID do Registro na tabela de Integracao
		ExpC2 = Empresa
		ExpC3 = Empresa
		ExpC4 = Filial
		ExpC5 = Banco
		ExpC6 = Nome do Banco
		ExpC7 = Nome reduzido
		ExpC8 = Agencia
		ExpC9 = Nome da Agencia
		ExpC10 = Endereco Agencia
		ExpC11 = Bairro da Agencia
		ExpC12= Municipio Agencia
		ExpC13= Estado da Agencia
		ExpC14= CEP Agencia
		ExpC15= Telefone Agencia
		ExpC16= Pais
		ExpC17= Conta
		ExpC18= Dig. da Conta
		ExpC19= Cedente
		ExpN1 = Codigo Cedente
		ExpN2 = Tipo Carteira
		ExpC20= Carteira
		ExpC21= Codigo Conta Caixa
		ExpN3 = Saldo Atual
		ExpC22= Bloqueado (1=Sim; 2=Nao)
		ExpC23= Status Importacao (1=Pendente;2=Processado;3=Erro)
		ExpC24= Mensagem da Insconsistencia ocorrida.
		ExpC25= Usuario Responsavel pela gravacao.
		ExpC26= Rotina destino da Importacao. Ex.: (S=Classis)
		ExpC27= Rotina Responsavel pela gravacao.
		ExpC28= Operacao Executada (I=Insert; U=Update; D=Delete)

@author  Alberto Deviciente
@version P10
@since 	 03/07/09
@return lRet - .T. para inclusao de LOG ok. / .F. para falha durante o registro do log.
/*/
//-------------------------------------------------------------------------------------
Function ClsBcAgLog(cIdReg,cEmp,cFil,cBanco,cNomeBco,cNomeReduz,cAgencia,cNomeAge,cEndAge,cBairroAge,cMunAge,cEstAge,cCepAge,cTelAge,cPais,cConta,cDigConta,cCedente,cCodCed,nTipoCart,cCarteira,cCodCXA,nSaldoAtu,cBloqueado,cStatusImport,cMsgLog,cUsuGrava,cRotImport,cRotGrava,cOperacao)
Local lRet 		:= .T.
Local lOracle	:= "ORACLE"$Upper(TCGetDB())
Local cDtGrava 	:= ""
Local cQuery 	:= ""
Local cTipoCart := ""
Local cAtivo 	:= ""

cMsgLog := Replace(cMsgLog,"'","''")
cMsgLog := SubStr(cMsgLog,1,250)

if lOracle //Se for Banco de Dados Oracle, trata o campo tipo DATA diferentemente
	cDtGrava := "to_date('"+dToS(dDataBase)+"','YYYYMMDD')"
else //SQL Server
	cDtGrava := "'"+dToS(dDataBase)+"'"
endif

if empty(cIdReg)
	//Insere registro na tabela INT_CONTACXALOG informando a inconsistencia ocorrida
	cTipoCart := Alltrim(str(nTipoCart))
	cAtivo 	:= iif(cBloqueado == '2','1','2') //1=Ativo, 2=Inativo
	
	cQuery := " INSERT INTO INT_CONTACXALOG (CXA_COLIGADA,CXA_FILIAL,CXA_CODCXA, "
	cQuery += " CXA_DESCRICAO,CXA_BANCO,CXA_AGENCIA,CXA_NOMEAGE,CXA_CONTA,CXA_DIGCONTA, "
	cQuery += " CXA_CEDENTE,CXA_CODCEDENTE,CXA_CARTEIRA,CXA_TIPOCARTEIRA,CXA_NREDUZ, "
	cQuery += " CXA_SALATU,CXA_ATIVA,CXA_BAIRRO,CXA_END,CXA_EST,CXA_MUN,CXA_CEP, "
	cQuery += " CXA_PAIS,CXA_TEL,CXA_DATAGRAVA,CXA_HORAGRAVA,CXA_USUGRAVA,CXA_STATUSIMPORT, "
	cQuery += " CXA_ROTIMPORT,CXA_ROTGRAVA,CXA_OBSIMPORT,CXA_PROCIMPORT) "
	cQuery += " values (" + cEmp + ",'" + cFil + "','" + cCodCXA + "','" + cNomeBco + "','" + cBanco + "','" + cAgencia + "', "
	cQuery += "'" + cNomeAge + "','" + cConta + "','" + cDigConta + "', '" + cCedente + "','" + cCodCed + "', " 
	cQuery += "'" + cCarteira + "'," + cTipoCart + ",'" + cNomeReduz + "'," + alltrim(str(nSaldoAtu)) + ","
	cQuery += cAtivo + ",'" + cBairroAge + "','" + cEndAge + "', '" + cEstAge + "','" + cMunAge + "','" + cCepAge + "', "
	cQuery += "'" + cPais + "','" + cTelAge + "', " +  cDtGrava + ", '" + Time() + "','" + cUsuGrava + "','"+cStatusImport+"', "
	cQuery += "'"+cRotImport+"','"+cRotGrava+"','" + cMsgLog + "','" + cOperacao+ "')"
	if TcSqlExec(cQuery) < 0 //Verifica se ocorreu erro
		conout( STR0002 +" INT_CONTACXALOG: "+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar incluir o registro na tabela"###" INT_CONTACXALOG: "
		MsgStop(STR0002 +" INT_CONTACXALOG: "+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar incluir o registro na tabela"###" INT_CONTACXALOG: "
		lRet := .F.
	endif
else
	//Atualiza o registro na tabela INT_CONTACXALOG informando a inconsistencia ocorrida
	cQuery := "UPDATE INT_CONTACXALOG "
	cQuery += " SET CXA_DATAGRAVA = "+cDtGrava+", CXA_HORAGRAVA = '"+Time()+"', CXA_OBSIMPORT = '"+cMsgLog+"'"
	cQuery += " WHERE CXA_ID = "+cIdReg
	if TcSqlExec(cQuery) < 0 //Verifica se ocorreu erro
		conout( STR0004+" INT_CONTACXALOG: "+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar atualizar o registro na tabela"###" INT_CONTACXALOG: "
		MsgStop(STR0004+" INT_CONTACXALOG: "+Chr(10)+Chr(10)+alltrim(TcSqlError())) //"Ocorreu o seguinte erro ao tentar atualizar o registro na tabela"###" INT_CONTACXALOG: "
		lRet := .F.
	endif
endif

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsValDBco
Valida a exclusao das contas bancarias do sistema comparando com as tabelas do CorporeRM. 

@param cCodCli - Codigo de cliente a ser pesquisado
@author  Cesar A. Bianchi
@version P10
@since 	 05/08/09
@return lRet - .T. para exclusao OK.
/*/
//-------------------------------------------------------------------------------------
Function ClsValDBco()
Local lRet := .F.

//Manter em forma de "if's" por questoes de perfomance (varios acessos do TOP as bases)	- SIGA3286

lRet := PxCRMCanEx( "SSERVICO", {"CODCOLIGADA","CODCXA"}, {SM0->M0_CODIGO,SA6->A6_CODCXA} )
if lRet
	lRet := PxCRMCanEx( "SPSPROCESSOSELETIVO", {"CODCOLIGADA","CODCXA"}, {SM0->M0_CODIGO,SA6->A6_CODCXA})
endif
if lRet
	lRet := PxCRMCanEx( "FLAN", {"CODCOLIGADA","CODCXA"}, {SM0->M0_CODIGO,SA6->A6_CODCXA} )
endif

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsCodOk
Verifica se um determinado codigo de cliente esta disponivel para uso na SA1 e na FCFO

@param cCodCli - Codigo de cliente a ser pesquisado
@author  Cesar A. Bianchi
@version P10
@since 	 21/06/10
@return lRet - .T. para codigo disponivel para uso / .F. para codigo ja em uso.
/*/
//-------------------------------------------------------------------------------------
Function ClsCodOk(cCodCli)
Local lRet 			:= .F.
Local lTopOk 		:= .F.
Local cQuery 		:= ""
Local nAmbTOP		:= 0
Local nAmbCLASSIS   := 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³1* Etapa: Verifica disponibilidade na SA1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT COUNT(*) TOTAL FROM " + RetSqlName('SA1') + " SA1 "
cQuery += " WHERE SA1.A1_FILIAL = '" + xFilial('SA1') + "'"
cQuery += " 	AND SA1.A1_COD = '" + cCodCli + "'"
cQuery += " 	AND SA1.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
iif(Select('TCQ')>0,TCQ->(dbCloseArea()),Nil)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)

If TCQ->TOTAL == 0
	lRet := .T.
else
	lRet := .F.
	Aviso(STR0010,STR0011,{STR0013}) //Código de cliente ja utilizado dentro da SA1. Impossível continuar
endif
TCQ->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³2* Etapa: Verifica disponibilidade na FCFO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lRet
	
	//Busca a conexao com a base do Sistema RM
	lTopOk := .F.
	if lTopOk
		//Seta a conexao com a base do Sistema RM
		TCSetConn(nAmbCLASSIS)
	    
		//Varre a FCFO buscando este codigo
		cQuery := " SELECT COUNT(*) TOTAL FROM FCFO "
		cQuery += " WHERE CODCOLIGADA = " + SM0->M0_CODIGO 
		cQuery += " 	AND CODCFO = '" + cCodCli + "'"
		cQuery := ChangeQuery(cQuery)
		iif(Select('TCQ')>0,TCQ->(dbCloseArea()),Nil)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)
	    If TCQ->TOTAL == 0
			lRet := .T.
		else
			lRet := .F.
			Aviso(STR0010,STR0012,{STR0013}) //"Código de cliente ja utilizado dentro da FCFO (TOTVS Educacional). Impossível continuar"
		endif

		TCQ->(dbCloseArea())	
		TCSetConn(nAmbTOP) 			//Seta a conexao do TOP com a base da Protheus
		TcUnLink(nAmbCLASSIS) 		//Finaliza a conexao do TOP com a base do Sistema RM		
	endif
endif

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsEstMex
Retorna o codigo GETDMX do estado mexicano de acordo com seu codigo padrao


@param cEstMex - Codigo padrao do estado mexicano a ser pesquisado
@author  Cesar A. Bianchi
@version P10
@since 	 23/11/10
@return cCodRm - Codigo do estado mexicano na tabela GETDMX (CorporeRM)
/*/
//-------------------------------------------------------------------------------------
Function ClsEstMex(cEstMex)
Local cEstNum 		:= "  "
Local cQuery 		:= ""
Local nAmbTOP 		:= 0
Local nAmbCLASSIS 	:= 0
Local lTopOk		:= .F.
Default cEstMex 	:= "  "


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o codigo nao esta em branco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cEstNum := cEstMex
If !Empty(cEstMex) .and. cPaisLoc == "MEX"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca a conexao com a base do Sistema RM		   ³
	//³e seta a conexao do TOP com a base do Sistema RM³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lTopOk := .F.
	if lTopOk
		TCSetConn(nAmbCLASSIS)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca qual o codigo (numerico) do estado na GETDMX³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT CODETD FROM GETDMX WHERE CODETDMX = '" + alltrim(cEstMex) + "'"
		cQuery := ChangeQuery(cQuery)
		iif(Select('QRY')>0,QRY->(dbCloseArea()),Nil)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "QRY", .F., .T.)
        If QRY->(!Eof())
			cEstNum := alltrim(QRY->CODETD)
        EndIf
        QRY->(dbCloseArea())
   		TCSetConn(nAmbTOP) 			//Seta a conexao do TOP com a base da Protheus
		TcUnLink(nAmbCLASSIS) 		//Finaliza a conexao do TOP com a base do Sistema RM		        
	EndIf	
EndIf

Return cEstNum

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsPaisRM
Retorna o codigo (ID) do Pais nas tabelas da RM de acordo com a descricao passada como parametro.

@param	cNomePais - Nome padrao do Pais ser pesquisado na tabela GPAIS	
@author  Cesar A. Bianchi
@version P10
@since 	 27/01/11
@return aPais[1] - Codigo (ID) do Pais na GPAIS.
		aPais[2] - Descricao exata do Pais na GPAIS.
/*/
//-------------------------------------------------------------------------------------
Function ClsPaisRM(cNomePais)
Local cQuery := ""
Local cCodRM := 0
Local cDescRM:= ""
Local cBuffer:= ""
Local nX 	 := 1
Local nAmbTOP:= 0
Local nAmbCLASSIS 	:= 0
Local aArea	 		:= getArea()
Local cAlias		:= getNextAlias()
Local cLetters 		:= "ABCDEFGHIJKLMNOPQRSTUVXYWZ"
Local aWords 		:= {}
Local lTemPalavra	:= .T.
Local lTopOk  		:= .F.
Default cNomePais 	:= ""

if !Empty(cNomePais)
  	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Separa todas as palavras do pais a ser pesquisado dentro de um array.    ³
	//³Faz isto, pois em alguns casos o cadastro do pais no protheus eh formado ³
	//³por SOBRENOME, NOME.                                                     ³
	//³Ex: Caimas, Ilhas.                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNomePais := Upper(cNomePais)
	For nX := 1 to len(cNomePais)
		If upper(substr(cNomePais,nX,1)) $ cLetters
			cBuffer += substr(cNomePais,nX,1)
		else
			If !Empty(cBuffer)
				aAdd(aWords,upper(NoAcento(cBuffer)))
				cBuffer := ""
			EndIf
		endif
	Next nX
	If !Empty(cBuffer)
		aAdd(aWords,upper(NoAcento(cBuffer)))
		cBuffer := ""
	EndIf
  	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca a conexao com a base de dados do corpore³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTopOk
		TCSetConn(nAmbCLASSIS)
	  	 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Abre a tabela de Paises do Corpore (GPAIS)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := " SELECT IDPAIS, DESCRICAO FROM GPAIS "
		cQuery := ChangeQuery(cQuery)
		iif(Select(cAlias)>0,(cAlias)->(dbCloseArea()),Nil)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)
		While (cAlias)->(!Eof())
			cBuffer := upper(NoAcento(alltrim((cAlias)->DESCRICAO)))
			lTemPalavra := .T.
			
			//Verifica se todas as palavras que constituem o nome do pais estao no registro analisado
			For nX := 1 to len(aWords)

				lTemPalavra := aWords[nX] $ cBuffer
				If !lTemPalavra
					exit
				EndIf
			Next nX

			//Se tem todas as palavras, entao eh o pais pesquisado
			If lTemPalavra
				cCodRM := (cAlias)->IDPAIS
				cDescRM:= alltrim((cAlias)->DESCRICAO)
				exit
			EndIf
			(cAlias)->(dbSkip())
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fecha area, volta a conexao do top para 				 ³
		//³o banco do protheus e mata a conexao com o banco da RM³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		(cAlias)->(dbCloseArea())
   		TCSetConn(nAmbTOP) 
		TcUnLink(nAmbCLASSIS)
	EndIf
EndIf

RestArea(aArea) 
Return {cCodRM,cDescRM}

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsIncPais
Replica a inclusao de um pais cadastrado para dentro do CorporeRM

@param	 nRecSYA - R_E_C_N_O_ da SYA referente ao pais recen-cadastrado
@author  Cesar A. Bianchi
@version P10
@since 	 11/02/11
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Function ClsIncPais(nRecSYA)
Local aArea 		:= getArea()
Local nAmbTop		:= 0
Local nAmbClassis	:= 0
Local aDados		:= {}
Local cQuery		:= ""
Local lTopOk  		:= .F.

Default nRecSYA		:= 0

If nRecSYA > 0
	dbSelectArea('SYA')
	SYA->(dbSetOrder(1))
	SYA->(dbGoTo(nRecSYA))
	If !SYA->(Eof())
	
		//Monta a query de insert
     	aAdd(aDados,{"IDPAIS"		, alltrim(str(val(SYA->YA_CODGI)))									})
     	aAdd(aDados,{"CODPAIS"		, "'" + ClsPadr(SYA->YA_SIGLA,"GPAIS","CODPAIS",.T.) + "'" 		})
     	aAdd(aDados,{"DESCRICAO"	, "'" + ClsPadr(SYA->YA_DESCR,"GPAIS","DESCRICAO",.T.) + "'" 		})
		cQuery := ClsQryIns(aDados,"GPAIS")
		
		//Busca Conexao com a base do CorporeRM
		If lTopOk
			TCSetConn(nAmbCLASSIS)
			If TcSqlExec(cQuery)<0
				//Conout(TcSqlError())
			 	lOK := .F.
			Else
				TcSqlExec("COMMIT")
			 	lOK := .T.
			EndIf
			TCSetConn(nAmbTOP)
			TcUnLink(nAmbClassis)
		EndIf			
	EndIf
EndIf
	
RestArea(aArea)
Return lOk

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsProcCli
Replica a alteracao de um cliente para dentro do CorporeRM, exibindo uma mensagem do tipo
MsgRun ao usuario. Para uso exclusivo em rotinas com interface grafica.

@param nSA1Rec 		Recno da SA1 referente ao cliente alterado
	   cGeraINT 	Gera registro na INT_CLIENTE (1 - Sim, 0 - Nao)
	   cROTIMPORT   Nome da rotina responsavel pela alteraco (MAT030 por exemplo)
@author  Cesar A. Bianchi
@version P10
@since 	 26/01/11
@return Nil
/*/
//-------------------------------------------------------------------------------------
  Function ClsProcCli(nSA1Rec,cGeraINT,cROTIMPORT)
Local lRet := .T.

MsgRun(STR0008,STR0009,{|| lRet := ClsUpdCli(nSA1Rec,cGeraINT,cROTIMPORT) })  //"Replicando dados da integração Protheus x Corpore"

Return	lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsUpdCli
Replica a alteracao de um cliente para dentro do CorporeRM. Para uso em rotinas 
executadas em background (JOB, WEBSERVICES, RPC, Etc)

@param nSA1Rec 		Recno da SA1 referente ao cliente alterado
	   cGeraINT 	Gera registro na INT_CLIENTE (1 - Sim, 0 - Nao)
	   cROTIMPORT   Nome da rotina responsavel pela alteraco (MAT030 por exemplo)
	   
@author  Cesar A. Bianchi
@version P10
@since 	 26/01/11
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Static Function ClsUpdCli(nSA1Rec,cGeraINT,cROTIMPORT)
Local nAmbTOP 		:= 0
Local nAmbCLASSIS 	:= 0
Local nI			:= 0
Local aDados		:= {}
Local aWhere		:= {}
Local aArea			:= getArea()
Local cQuery		:= ""
Local lOk			:= .T.
Local cNomePais		:= ""
Local cMaskCPF		:= ""
Local cEnd			:= ""
Local cEndEnt		:= ""
Local cEndCob		:= ""
Local cBuffer		:= ""
Local lTopOk  		:= .F.

Default nSA1Rec 	:= 0
Default cRotImport  := ""
Default cGeraINT	:= '0'

If GetNewPar("MV_RMCLASS",.F.) .and. nSA1Rec > 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona na SA1 alterada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SA1')
	SA1->(dbSetOrder(1))
	SA1->(dbGoTo(nSA1Rec))
	If SA1->(!Eof())
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a conexao com as bases do Protheus e do Corpore³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTopOk     		
			TCSetConn(nAmbTop)
			
			//Define nome do Pais
			cNomePais := alltrim(Posicione('SYA',1,xFilial('SYA')+SA1->A1_PAIS,"YA_DESCR"))

			//Define mascara do CPF ou CNPJ
			cMaskCPF := iif(alltrim(SA1->A1_PESSOA) == "J","@R 99.999.999/9999-99","@R 999.999.999-99")

			//Define endereco DO CLIENTE, removendo o numero (OBS: Esta tratando pelo separador "-" [underscore] e "," [virgula])
			cBuffer := ""
			For nI := 1 to len(alltrim(SA1->A1_END))
				If substr(SA1->A1_END,nI,1) != "-"  .and. substr(SA1->A1_END,nI,1) != ","
					cBuffer += substr(SA1->A1_END,nI,1)
				Else
					cEnd := alltrim(cBuffer)
					exit
				EndIf
			Next nI

			//Define endereco DE ENTREGA, removendo o numero (OBS: Esta tratando pelo separador "-" [underscore] e "," [virgula])
			cBuffer := ""
			For nI := 1 to len(alltrim(SA1->A1_ENDENT))
				If substr(SA1->A1_ENDENT,nI,1) != "-"  .and. substr(SA1->A1_ENDENT,nI,1) != ","
					cBuffer += substr(SA1->A1_ENDENT,nI,1)
				Else
					cEndEnt := alltrim(cBuffer)
					exit
				EndIf
			Next nI

			//Define endereco DE COBRANCA, removendo o numero (OBS: Esta tratando pelo separador "-" [underscore] e "," [virgula])
			cBuffer := ""
			For nI := 1 to len(alltrim(SA1->A1_ENDCOB))
				If substr(SA1->A1_ENDCOB,nI,1) != "-"  .and. substr(SA1->A1_ENDCOB,nI,1) != ","
					cBuffer += substr(SA1->A1_ENDCOB,nI,1)
				Else
					cEndCob := alltrim(cBuffer)
					exit
				EndIf
			Next nI  

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta a query de update na FCFO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aDados := {}
			aAdd(aDados,{"NOME",			iif(Empty(SA1->A1_NOME)		,"NULL"		,"'" + ClsPadr(SA1->A1_NOME,"FCFO","NOME",.T.) + "'")							})
			aAdd(aDados,{"NOMEFANTASIA",	iif(Empty(SA1->A1_NREDUZ)	,"NULL"		,"'" + ClsPadr(SA1->A1_NREDUZ,"FCFO","NOMEFANTASIA",.T.) + "'")				})
			aAdd(aDados,{"PESSOAFISOUJUR",	iif(Empty(SA1->A1_PESSOA)	,"NULL"		,"'" + ClsPadr(SA1->A1_PESSOA,"FCFO","PESSOAFISOUJUR",.T.) + "'")				})
			aAdd(aDados,{"CIDENTIDADE",		iif(Empty(SA1->A1_RG)		,"NULL"		,"'" + ClsPadr(SA1->A1_RG,"FCFO","CIDENTIDADE",.T.) + "'")	 					})
			aAdd(aDados,{"TELEFONE",		iif(Empty(SA1->A1_TEL)		,"NULL"		,"'" + ClsPadr(SA1->A1_TEL,"FCFO","TELEFONE",.T.) + "'") 						})
			aAdd(aDados,{"TELEX",			iif(Empty(SA1->A1_TELEX)	,"NULL"		,"'" + ClsPadr(SA1->A1_TELEX,"FCFO","TELEX",.T.) + "'")						})
			aAdd(aDados,{"BAIRRO",			iif(Empty(SA1->A1_BAIRRO)	,"NULL"		,"'" + ClsPadr(SA1->A1_BAIRRO,"FCFO","BAIRRO",.T.) + "'")						})
			aAdd(aDados,{"BAIRROPGTO",		iif(Empty(SA1->A1_BAIRROC)	,"NULL"		,"'" + ClsPadr(SA1->A1_BAIRROC,"FCFO","BAIRROPGTO",.T.) + "'")					})
			aAdd(aDados,{"BAIRROENTREGA",	iif(Empty(SA1->A1_BAIRROE)	,"NULL"		,"'" + ClsPadr(SA1->A1_BAIRROE,"FCFO","BAIRROENTREGA",.T.) + "'")				})
			aAdd(aDados,{"CEP",				iif(Empty(SA1->A1_CEP)		,"NULL"		,"'" + ClsPadr(SA1->A1_CEP,"FCFO","CEP",.T.) + "'")							})
			aAdd(aDados,{"CEPPGTO",			iif(Empty(SA1->A1_CEPC)		,"NULL"		,"'" + ClsPadr(SA1->A1_CEPC,"FCFO","CEPPGTO",.T.) + "'")						})
			aAdd(aDados,{"CEPENTREGA",		iif(Empty(SA1->A1_CEPE)		,"NULL"		,"'" + ClsPadr(SA1->A1_CEPE,"FCFO","CEPENTREGA",.T.) + "'")					})
			aAdd(aDados,{"CGCCFO",			iif(Empty(SA1->A1_CGC)		,"NULL"		,"'" + ClsPadr(Transform(SA1->A1_CGC,cMaskCPF),"FCFO","CGCCFO",.T.) + "'")	})
			aAdd(aDados,{"CONTATO",			iif(Empty(SA1->A1_CONTATO)	,"NULL"		,"'" + ClsPadr(SA1->A1_CONTATO,"FCFO","CONTATO",.T.) + "'")		  			})
			aAdd(aDados,{"DTNASCIMENTO",	iif(Empty(SA1->A1_DTNASC)	,"NULL"		,ClsQryDat(SA1->A1_DTNASC,.F.)) 									  			})
			aAdd(aDados,{"EMAIL",			iif(Empty(SA1->A1_EMAIL)	,"NULL"		,"'" + ClsPadr(SA1->A1_EMAIL,"FCFO","EMAIL",.T.) + "'")			  			})
			aAdd(aDados,{"RUA",				iif(Empty(cEnd)				,"NULL"		,"'" + ClsPadr(cEnd,"FCFO","RUA",.T.) + "'")									})
			aAdd(aDados,{"RUAENTREGA",		iif(Empty(cEndEnt)			,"NULL"		,"'" + ClsPadr(cEndEnt,"FCFO","RUAENTREGA",.T.) + "'")							})
			aAdd(aDados,{"RUAPGTO",			iif(Empty(cEndCob)			,"NULL"		,"'" + ClsPadr(cEndCob,"FCFO","RUAPGTO",.T.) + "'")							})		
			aAdd(aDados,{"CODMUNICIPIO",	iif(Empty(SA1->A1_COD_MUN)	,"NULL"		,"'" + alltrim(ClsPadr(SA1->A1_COD_MUN,"FCFO","PAIS",.T.)) + "'")				})
			aAdd(aDados,{"CIDADE",			iif(Empty(SA1->A1_MUN)		,"NULL"		,"'" + ClsPadr(SA1->A1_MUN,"FCFO","CIDADE",.T.) + "'")							})
			aAdd(aDados,{"CIDADEPGTO",		iif(Empty(SA1->A1_MUNC)		,"NULL"		,"'" + ClsPadr(SA1->A1_MUNC,"FCFO","CIDADEPGTO",.T.) + "'")					})
			aAdd(aDados,{"CIDADEENTREGA",	iif(Empty(SA1->A1_MUNE)		,"NULL"		,"'" + ClsPadr(SA1->A1_MUNE,"FCFO","CIDADEENTREGA",.T.) + "'")					})
			aAdd(aDados,{"FAX",				iif(Empty(SA1->A1_FAX)		,"NULL"		,"'" + ClsPadr(SA1->A1_FAX,"FCFO","FAX",.T.)  + "'")							})
			aAdd(aDados,{"INSCRESTADUAL",	iif(Empty(SA1->A1_INSCR)	,"NULL"		,"'" + alltrim(ClsPadr(SA1->A1_INSCR,"FCFO","INSCRESTADUAL",.T.)) + "'"	)	})
			aAdd(aDados,{"INSCRMUNICIPAL",	iif(Empty(SA1->A1_INSCRM)	,"NULL"		,"'" + alltrim(ClsPadr(SA1->A1_INSCRM,"FCFO","INSCRMUNICIPAL",.T.)) + "'")	})
			If !Empty(SA1->A1_PAIS)
				aAdd(aDados,{"IDPAIS",		iif(Empty(SA1->A1_PAIS)		,"NULL"		,SA1->A1_PAIS)																	})
				aAdd(aDados,{"PAIS",		iif(Empty(cNomePais)		,"NULL"		,"'" + ClsPadr(cNomePais,"FCFO","PAIS",.T.) + "'")							})
			EndIf
			If cPaisLoc == "MEX"
				//Se pais eh mexico, entao coleta o codigo de estado da GETDMX, via funcao ClsEstMex
				If !Empty(SA1->A1_EST)
					aAdd(aDados,{"CODETD", 		iif(Empty(SA1->A1_EST),"NULL","'" + alltrim(ClsPadr(ClsEstMex(SA1->A1_EST),"FCFO","CODETD",.T.)) + "'")			})
				EndIf
				If !Empty(SA1->A1_ESTC)
					aAdd(aDados,{"CODETDPGTO",	iif(Empty(SA1->A1_ESTC),"NULL","'" + alltrim(ClsPadr(ClsEstMex(SA1->A1_ESTC),"FCFO","CODETDPGTO",.T.))  + "'") 	})
				EndIf
				If !Empty(SA1->A1_ESTE)
					aAdd(aDados,{"CODETDENTREGA",iif(Empty(SA1->A1_ESTE),"NULL","'" + alltrim(ClsPadr(ClsEstMex(SA1->A1_ESTE),"FCFO","CODETDENTREGA",.T.)) + "'")})
				EndIf
			Elseif cPaisLoc == "BRA"
				//Se pais eh brasil, entao coleta o codigo de estado da propria SA1
				If !Empty(SA1->A1_EST)
					aAdd(aDados,{"CODETD", 		iif(Empty(SA1->A1_EST),"NULL",		"'" + alltrim(ClsPadr(SA1->A1_EST ,"FCFO","CODETD",.T.)) + "'"	)				})
				EndIf
				If !Empty(SA1->A1_ESTC)
					aAdd(aDados,{"CODETDPGTO",	iif(Empty(SA1->A1_ESTC),"NULL",	"'" + alltrim(ClsPadr(SA1->A1_ESTC,"FCFO","CODETDPGTO",.T.))  + "'")			})
				EndIf
				If !Empty(SA1->A1_ESTE)
					aAdd(aDados,{"CODETDENTREGA",iif(Empty(SA1->A1_ESTE),"NULL","'" + alltrim(ClsPadr(SA1->A1_ESTE,"FCFO","CODETDENTREGA",.T.)) + "'")			})
				EndIf
			EndIf
			
			aWhere := {}
			aAdd(aWhere,{""		,"CODCOLIGADA"	,"="	, alltrim(str(val(SM0->M0_CODIGO)))   					})
			aAdd(aWhere,{"AND"	,"CODCFO"		,"=" 	, "'" + ClsPadr(SA1->A1_COD,"FCFO","CODCFO",.T.) + "'"	})
			cQuery := ClsQryUpd(aDados,aWhere,"FCFO")
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seta a conexao do top com a base da RM³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TCSetConn(nAmbCLASSIS)			
			If TcSqlExec(cQuery)<0
				Conout(TcSqlError())
				lOK := .F.
			Else
				TcSqlExec("COMMIT")
			 	lOK := .T.
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Finaliza a conexao com a base do Corpore³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   			TCSetConn(nAmbTOP) 			//Seta a conexao do TOP com a base da Protheus
			TcUnLink(nAmbCLASSIS) 		//Finaliza a conexao do TOP com a base do Sistema RM		
		EndIf	
	EndIf	
EndIf

RestArea(aArea)
Return	lOK


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsVerBsRM
Funcao responsavel por verificar na base RM qual a versão esta sendo ultilizada

@param	ExpL1  = .T.=Reprocessamento do registro; .F.=Proc. Normal
		ExpC1  = ID do Registro na tabela de Integracao
		ExpL2  = Gera registro na tabela INT_CONTACXALOG (.T.=Sim)
		ExpC2  = Tipo Operacao: (I=Insert; U=Update D=Delete)
		ExpC3  = Empresa
		ExpC4  = Filial
		ExpL3  = .T.=Caixa (Tesouraria); .F.=Conta Normal


@author  Caio Quiqueto dos Santos
@version P11
@since 	 01/04/2014
@return  cRet - Retorna a versão do RM
			Exemplo : cRet := "11.83"
/*/
//-------------------------------------------------------------------------------------

Function ClsVerBsRM ()
Local aArea  		:= GetArea()
Local nAmbTOP 		:= 0
Local nAmbCLASSIS 	:= 0
Local cQuery			:= ""
Local lTopOk  		:= .F.
Local cRet 			:= ""

	lTopOk := .F.
	
	If lTopOk
		cQuery := "Select VERSAOBASE from GPARAMS "
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)
		cRet := TCQ->VERSAOBASE
	Else
		cRet := "0"
	EndIf	
	
	TCSetConn( nAmbTOP )
	
	TCUNLINK(nAmbCLASSIS)
	
	
RestArea(aArea)
Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsNxtGaut
Funcao generica para busca do proximo codigo de Qualquer tabela de acordo com a GAUTOINC.
@param nSE1Rec		nAmbTop  - ID da conexao do top com o banco do Protheus
					nAmbClas - ID da conexao do top com o banco do CorporeRM
					nCodSis  - Codigo do Sistema
					nCodAut  - Codigo do autoinc
				
@author Caio Quiqueto
@version P11
@since 	 02/04/2014
@see ClsNxtGaut
@return cIdGaut
/*/
//-------------------------------------------------------------------------------------
Function ClsNxtGaut(nAmbTop,nAmbClas,nCodSis,nCodAut)
Local cNext := 0
Local cQuery := ""
Default nAmbTop  := 0
Default nAmbClas := 0
       

if nAmbTop > 0 .or. nAmbClas > 0
	
	//Antes de buscar verifica se o registro de controle de numeracao ja existe na tabela GAUTOINC
	
	cQuery := " SELECT COUNT(VALAUTOINC) TOTAL FROM GAUTOINC "
	cQuery += " WHERE CODCOLIGADA = " + substr(SM0->M0_CODIGO,1,2)
	cQuery += "   AND CODSISTEMA = '" + nCodSis + "' "
	cQuery += "   AND CODAUTOINC = '" + nCodAut + "'"
 	cQuery := ChangeQuery(cQuery)
	iif(Select('TCQ')>0,TCQ->(dbCloseArea()),Nil)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)							
	if TCQ->TOTAL > 0
		//Busca o proximo Valor para inserir na tabela FLAN
		cQuery := " SELECT (VALAUTOINC + 1) PROX FROM GAUTOINC "
		cQuery += " WHERE CODCOLIGADA = " + substr(SM0->M0_CODIGO,1,2)
		cQuery += "   AND CODSISTEMA = '" + nCodSis + "' "
		cQuery += "   AND CODAUTOINC = '" + nCodAut + "'"
	 	cQuery := ChangeQuery(cQuery)
		iif(Select('TCQ')>0,TCQ->(dbCloseArea()),Nil)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F., .T.)							
		cNext := TCQ->PROX								
		
		//Atualiza a tabela GAUTOINC para o campo 
		cQuery := "UPDATE GAUTOINC "
		cQuery += " SET VALAUTOINC = " + alltrim(str(cNext))
		cQuery += " WHERE CODCOLIGADA = " + substr(SM0->M0_CODIGO,1,2)
		cQuery += "   AND CODSISTEMA = '" + nCodSis + "' "
		cQuery += "   AND CODAUTOINC = '" + nCodAut + "'"
		TCSqlExec(cQuery)
		Conout(TcSqlError())
		TcSqlExec("COMMIT")
	else
		//Insere registro na tabela GAUTOINC para o campo
		cNext  := 1
		cQuery := " INSERT INTO GAUTOINC " 
		cQuery += " (CODCOLIGADA, CODSISTEMA, CODAUTOINC, VALAUTOINC) "
		cQuery += "  VALUES (" + substr(SM0->M0_CODIGO,1,2) + ",'" + nCodSis + "','" + nCodAut + "'," + alltrim(str(cNext)) + ")"
		TCSqlExec(cQuery)
		Conout(TcSqlError())
		TcSqlExec("COMMIT")
	endif
	iif(Select('TCQ')>0,TCQ->(dbCloseArea()),Nil)
endif

Return cNext

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsSa6par
Funcao generica para busca informações complementaraes na tabela de banco
@param nSE1Rec		cNUMBANCO		- Numero do banco
					cNUMAGENCIA	- Numero da agencia
					cNROCONTA		- Numero da conta
				
@author Caio Quiqueto
@version P11
@since 	 02/04/2014
@return aRet {cCODCXA,cCODCEDENTE,cNOMECARTEIRA}
/*/
//-------------------------------------------------------------------------------------
function ClsSa6par(cNUMBANCO,cNUMAGENCIA,cNROCONTA)
Local cQry		:=""
Local aRet		:={}
Local TCQ 		:= GetNextAlias()


	cQry := " Select A6_CARTEIR,A6_CODCED,A6_CODCXA from " + RetSqlName("SA6")
	cQry += " where A6_COD     = '" + cNUMBANCO	+ "'"
	cQry += " AND   A6_AGENCIA = '" + cNUMAGENCIA	+ "'"
	cQry += " AND   A6_NUMCON  = '" + cNROCONTA 	+ "'"
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry), TCQ, .F., .T.)
	
	aAdd(aRet,(TCQ)->A6_CARTEIR)
	aAdd(aRet,(TCQ)->A6_CODCED)
	aAdd(aRet,(TCQ)->A6_CODCXA)
	
return aRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsQryDat
Funcao criada para atender debitos tecnicos e deverá ser retirada apos definição do P.O.
@param
@author Francisco Oliveira
@version P12
@since 	 03/02/2021
@return cRet
/*/
//-------------------------------------------------------------------------------------

Static Function ClsQryDat(dData, lret)

Local cRet := ""

Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsPadr
Funcao criada para atender debitos tecnicos e deverá ser retirada apos definição do P.O.
@param
@author Francisco Oliveira
@version P12
@since 	 03/02/2021
@return cRet
/*/
//-------------------------------------------------------------------------------------

Static Function ClsPadr(cSigla, cPais, cCodPais, lRet )

Local cRet := ""

Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsQryIns
Funcao criada para atender debitos tecnicos e deverá ser retirada apos definição do P.O.
@param
@author Francisco Oliveira
@version P12
@since 	 03/02/2021
@return cRet
/*/
//-------------------------------------------------------------------------------------

Static Function ClsQryIns(aDados, cPais)

Local cRet := ""

Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsQryUpd
Funcao criada para atender debitos tecnicos e deverá ser retirada apos definição do P.O.
@param
@author Francisco Oliveira
@version P12
@since 	 03/02/2021
@return cRet
/*/
//-------------------------------------------------------------------------------------

Static Function ClsQryUpd(aDados,aWhere,cFCFO)

Local cRet := ""

Return cRet

