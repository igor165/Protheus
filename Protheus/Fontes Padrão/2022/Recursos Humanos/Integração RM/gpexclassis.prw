#INCLUDE "COLORS.CH"
#INCLUDE "GPEXCLASSIS.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³			                                                              ³±±
±±³      ROTINAS GENERICAS DE CONTEXTO RH/GESTAO PESSOAL USADAS           ³±±
±±³		 PELA INTEGRACAO PROTHEUS X RM CLASSISNET E RM BIBLIOS			  ³±±
±±³			                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ClsTpDoc  ³Autor  ³ Alberto Deviciente    ³ Data ³25/Jun/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao responsavel pela Integracao de Tipos de Documentos  ³±±
±±³          ³ entre os sistemas Protheus x RM Classis Net (RM)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Gera registro na tabela INT_CCUSTOLOG (.T.=Sim)    ³±±
±±³          ³ ExpC1 = Tipo Operacao: (I=Insert; U=Update D=Delete)       ³±±
±±³          ³ ExpC2 = Empresa                                            ³±±
±±³          ³ ExpC3 = Filial                                             ³±±
±±³          ³ ExpC4 = Cod. do Tipo de Documento                          ³±±
±±³          ³ ExpC5 = Descricao do Tipo de Documento                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ (.T.=Executado com Sucesso; .F.=Ocorreu inconsistencia)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³Integracao Protheus x RM Classis Net                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºOBS:	  	 ³Funcao antiga chamava-se IntRmTpDoc 						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ClsTpDoc(lGeraLog, cOperacao, cEmp, cFil, cCodigo, cDescricao)
Local nAmbTOP 		:= 0
Local nAmbCLASSIS 	:= 0
Local lTopOk  		:= .F.
Local lOracle		:= "ORACLE"$Upper(TCGetDB())
Local lRet 			:= .F.
Local cUsuGrava 	:= "PROTHEUS"
Local cRotImport  	:= "S" //Para qual Rotina sera importado (S=RM Classis Net)
Local cRotGrava 	:= "SX5"+cEmp+"0" //Qual rotina esta fazendo a Gravacao
Local cDtGrava 		:= ""
Local cQuery 		:= ""
Local nPAGREC	 	:= 1
Local nEDEVOLUCAO 	:= 0


cCodigo 	:= alltrim(cCodigo)
cDescricao 	:= alltrim(cDescricao)

//Verifica se alguma variavel esta vazia e atribui um espaco para nao gerar erro qdo. for Banco de dados Oracle
cCodigo		:= iif(empty(cCodigo), " ", cCodigo)
cDescricao	:= iif(empty(cDescricao), " ", cDescricao)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca a conexao com a base do Sistema RM  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lTopOk := _IntRMTpCon(@nAmbTOP,@nAmbCLASSIS,.T.)

if lTopOk
	lRet := .T.
	if cOperacao == "I" //Inclusao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seta a conexao do TOP com a base do Sistema RM ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TCSetConn(nAmbCLASSIS)
		
		/* Antes de inserir verifica se ainda nao existe o registro na tabela FTDO do RM */
		cQuery := "select count(CODTDO) QTD"
		cQuery += "  from FTDO "
		cQuery += " where CODCOLIGADA = "+cEmp
		cQuery += "   and CODTDO = '"+cCodigo+"'"
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_TPDOC", .F., .F. ) 
		
		if _TPDOC->QTD == 0 //Registro ainda nao existe, entao efetua a insercao 
			/* Efetua a Inclusao do registro na tabela FTDO */
			cQuery := "insert into FTDO "
			cQuery += " (CODCOLIGADA, CODTDO, DESCRICAO, PAGREC, EDEVOLUCAO) "
			cQuery += " values ("+cEmp+", '"+cCodigo+"', '"+cDescricao+"', "+alltrim(str(nPAGREC))+", "+alltrim(str(nEDEVOLUCAO))+")"
			if TcSqlExec(cQuery) < 0 //Verifica se ocorreu erro
				conout( STR0005 +" FTDO "+ STR0006 +Chr(10)+Chr(10)+alltrim(TcSqlError()))
				MsgStop(STR0005 +" FTDO "+ STR0006 +Chr(10)+Chr(10)+alltrim(TcSqlError()))
				lRet := .F.
			else
				TcSqlExec("COMMIT")
			endif
		else
			lRet := .F.
			if lGeraLog //Gera registro na tabela INT_TIPODOCLOG
				if lOracle //Se for Banco de Dados Oracle, trata o campo tipo DATA diferentemente
					cDtGrava := "to_date('"+dToS(dDataBase)+"','YYYYMMDD')"
				else //SQL Server
					cDtGrava := "'"+dToS(dDataBase)+"'"
				endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seta a conexao do TOP com a base da Protheus|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TCSetConn(nAmbTOP)
				
				//Inclui o registro da tabela INT_TIPODOCLOG, informando a inconsistência existente
				cQuery := "insert into INT_TIPODOCLOG "
				cQuery += " (TOD_COLIGADA,TOD_FILIAL,TOD_CODIGO,TOD_DESCRICAO,TOD_PAGREG,TOD_EDEVOLUCAO,TOD_DATAGRAVA,TOD_HORAGRAVA,TOD_USUGRAVA,TOD_STATUSIMPORT,TOD_ROTIMPORT,TOD_ROTGRAVA,TOD_OBSIMPORT,TOD_PROCIMPORT) "
				cQuery += "  values ("+cEmp+", '"+cFil+"', "+cCodigo+", '"+cDescricao+"', "+alltrim(str(nPAGREC))+", "+alltrim(str(nEDEVOLUCAO))+", "+cDtGrava+", '"+Time()+"', '"+cUsuGrava+"', '3', '"+cRotImport+"', '"+cRotGrava+"', 'Registro ja existente na tabela STITULACAO. Não é permitido incluir registro duplicado.', '"+cOperacao+"')"
				if TcSqlExec(cQuery) < 0 //Verifica se ocorreu erro
					conout( STR0005+" INT_TIPODOCLOG: "+Chr(10)+Chr(10)+alltrim(TcSqlError()))
					MsgStop(STR0005+" INT_TIPODOCLOG: "+Chr(10)+Chr(10)+alltrim(TcSqlError()))
				else
					TcSqlExec("COMMIT")
				endif
			endif
		endif
		_TPDOC->( dbCloseArea() )
	elseif cOperacao == "U" //Alteracao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seta a conexao do TOP com a base do Sistema RM ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TCSetConn(nAmbCLASSIS)
		
		/* Efetua a Alteracao */
		cQuery := "update FTDO "
		cQuery += " set DESCRICAO = '"+cDescricao+"', PAGREC = "+alltrim(str(nPAGREC))+", EDEVOLUCAO = "+alltrim(str(nEDEVOLUCAO))
		cQuery += " where CODCOLIGADA = "+cEmp
		cQuery += "   and CODTDO = '"+cCodigo+"'"
		if TcSqlExec(cQuery) < 0 //Verifica se ocorreu erro
			conout( STR0007+" STITULACAO "+ STR0006 +Chr(10)+Chr(10)+alltrim(TcSqlError()))
			MsgStop(STR0007+" STITULACAO "+ STR0006 +Chr(10)+Chr(10)+alltrim(TcSqlError()))
			lRet := .F.
		else
			TcSqlExec("COMMIT")
		endif
	elseif cOperacao == "D" //Exclusao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seta a conexao do TOP com a base da Protheus|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TCSetConn(nAmbTOP)
		
		//Antes de Excluir, verifica se pode ser excluido
		//Verifica se existe registro relacionado nas tabelas do Sistema RM	
		lCanEx := PxCRMCanEx( "FLAN", {"CODCOLIGADA", "CODTDO"}, {cEmp, cCodigo}, STR0008 + cCodigo + STR0009 +" FLAN "+ STR0010 ) //"Não é permitido excluir o Tipo de Documento "
		lCanEx := if(lCanEx,PxCRMCanEx( "SSERVICO", {"CODCOLIGADA", "CODTDO"}, {cEmp, cCodigo}, STR0008 + cCodigo + STR0009 +" SSERVICO "+ STR0010 ),.F.) //"Não é permitido excluir o Tipo de Documento "
		lCanEx := if(lCanEx,PxCRMCanEx( "SPSPROCESSOSELETIVO", {"CODCOLIGADA", "CODTDO"}, {cEmp, cCodigo}, STR0008 +cCodigo+ STR0009 +" SPSPROCESSOSELETIVO "+ STR0010 ),.F.) //"Não é permitido excluir o Tipo de Documento "
		
		if lCanEx //Pode excluir
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seta a conexao do TOP com a base do Sistema RM ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TCSetConn(nAmbCLASSIS)
			
			/* Efetua a Exclusao do registro na tabela FTDO */
			cQuery := "delete from FTDO"
			cQuery += " where CODCOLIGADA = "+cEmp
			cQuery += "   and CODTDO = '"+cCodigo+"'"
			if TcSqlExec(cQuery) < 0 //Verifica se ocorreu erro
				conout( STR0011 +" FTDO "+ STR0006 +Chr(10)+Chr(10)+alltrim(TcSqlError()))
				MsgStop(STR0011 +" FTDO "+ STR0006 +Chr(10)+Chr(10)+alltrim(TcSqlError()))
				lRet := .F.
			else
				TcSqlExec("COMMIT")
			endif
		else
			lRet := .F.
		endif
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seta a conexao do TOP com a base da Protheus|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TCSetConn( nAmbTOP )
	
	TCUNLINK(nAmbCLASSIS) //Finaliza a conexao do TOP com a base do Sistema RM
endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ClsTitula ³Autor  ³ Alberto Deviciente    ³ Data ³25/Jun/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao responsavel pela Integracao de Titulacao Docente    ³±±
±±³          ³ entre os sistemas Protheus x RM Classis Net (RM)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Gera registro na tabela INT_CCUSTOLOG (.T.=Sim)    ³±±
±±³          ³ ExpC1 = Tipo Operacao: (I=Insert; U=Update D=Delete)       ³±±
±±³          ³ ExpC2 = Empresa                                            ³±±
±±³          ³ ExpC3 = Filial                                             ³±±
±±³          ³ ExpC4 = Cod. da Titulacao                                  ³±±
±±³          ³ ExpC5 = Descricao da Titulacao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ (.T.=Executado com Sucesso; .F.=Ocorreu inconsistencia)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³Integracao Protheus x RM Classis Net                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºOBS:	  	 ³Funcao antiga chamava-se IntRmTitul 						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ClsTitula(lGeraLog, cOperacao, cEmp, cFil, cCodTitulacao, cDescricao)
Local nAmbTOP 		:= 0
Local nAmbCLASSIS 	:= 0
Local lTopOk  		:= .F.
Local lOracle		:= "ORACLE"$Upper(TCGetDB())
Local lRet 			:= .F.
Local cUsuGrava 	:= "PROTHEUS"
Local cRotImport  	:= "S" //Para qual Rotina sera importado (S=RM Classis Net)
Local cRotGrava 	:= "SX5"+cEmp+"0" //Qual rotina esta fazendo a Gravacao
Local cDtGrava 		:= ""
Local cQuery 		:= ""


cCodTitulacao 	:= alltrim(cCodTitulacao)
cDescricao 		:= alltrim(cDescricao)

//Verifica se alguma variavel esta vazia e atribui um espaco para nao gerar erro qdo. for Banco de dados Oracle
cCodTitulacao 	:= iif(empty(cCodTitulacao), " ", cCodTitulacao)
cDescricao 		:= iif(empty(cDescricao), " ", cDescricao)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca a conexao com a base do Sistema RM  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lTopOk := _IntRMTpCon(@nAmbTOP,@nAmbCLASSIS,.T.)

if lTopOk
	lRet := .T.
	if cOperacao == "I" //Inclusao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seta a conexao do TOP com a base do Sistema RM ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TCSetConn(nAmbCLASSIS)
		
		/* Antes de inserir verifica se ainda nao existe o registro na tabela STITULACAO do RM */
		cQuery := "select count(CODTITULACAO) QTD"
		cQuery += "  from STITULACAO "
		cQuery += " where CODTITULACAO = "+cCodTitulacao
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_TITULA", .F., .F. ) 
		
		if _TITULA->QTD == 0 //Registro ainda nao existe, entao efetua a insercao 
			/* Efetua a Inclusao do registro na tabela STITULACAO */
			cQuery := "insert into STITULACAO "
			cQuery += " (CODTITULACAO,NOME) "
			cQuery += " values ("+cCodTitulacao+", '"+cDescricao+"')"
			if TcSqlExec(cQuery) < 0 //Verifica se ocorreu erro
				conout( STR0005+" STITULACAO "+ STR0006 +Chr(10)+Chr(10)+alltrim(TcSqlError()))
				MsgStop(STR0005+" STITULACAO "+ STR0006 +Chr(10)+Chr(10)+alltrim(TcSqlError()))
				lRet := .F.
			else
				TcSqlExec("COMMIT")
			endif
		else
			lRet := .F.
			if lGeraLog //Gera registro na tabela INT_TITULACAOLOG
				if lOracle //Se for Banco de Dados Oracle, trata o campo tipo DATA diferentemente
					cDtGrava := "to_date('"+dToS(dDataBase)+"','YYYYMMDD')"
				else //SQL Server
					cDtGrava := "'"+dToS(dDataBase)+"'"
				endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seta a conexao do TOP com a base da Protheus|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TCSetConn(nAmbTOP)
				
				//Inclui o registro da tabela INT_TITULACAOLOG, informando a inconsistência existente
				cQuery := "insert into INT_TITULACAOLOG "
				cQuery += " (TTL_COLIGADA,TTL_FILIAL,TTL_CODIGO,TTL_DESCRICAO,TTL_DATAGRAVA,TTL_HORAGRAVA,TTL_USUGRAVA,TTL_STATUSIMPORT,TTL_ROTIMPORT,TTL_ROTGRAVA,TTL_OBSIMPORT,TTL_PROCIMPORT) "
				cQuery += "  values ("+cEmp+", '"+cFil+"', "+cCodTitulacao+", '"+cDescricao+"', "+cDtGrava+", '"+Time()+"', '"+cUsuGrava+"', '3', '"+cRotImport+"', '"+cRotGrava+"', 'Registro ja existente na tabela STITULACAO. Não é permitido incluir registro duplicado.', '"+cOperacao+"')"
				if TcSqlExec(cQuery) < 0 //Verifica se ocorreu erro
					conout( STR0005 +" INT_TITULACAOLOG: "+Chr(10)+Chr(10)+alltrim(TcSqlError()))
					MsgStop(STR0005 +" INT_TITULACAOLOG: "+Chr(10)+Chr(10)+alltrim(TcSqlError()))
				else
					TcSqlExec("COMMIT")
				endif
			endif
		endif
		_TITULA->( dbCloseArea() )
	elseif cOperacao == "U" //Alteracao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seta a conexao do TOP com a base do Sistema RM ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TCSetConn(nAmbCLASSIS)
		
		/* Efetua a Alteracao */
		cQuery := "update STITULACAO set NOME = '"+cDescricao+"'"
		cQuery += " where CODTITULACAO = "+cCodTitulacao
		if TcSqlExec(cQuery) < 0 //Verifica se ocorreu erro
			conout( STR0007 + " STITULACAO "+ STR0006 + Chr(10)+Chr(10)+alltrim(TcSqlError()))
			MsgStop(STR0007 + " STITULACAO "+ STR0006 + Chr(10)+Chr(10)+alltrim(TcSqlError()))
			lRet := .F.
		else
			TcSqlExec("COMMIT")
		endif
	elseif cOperacao == "D" //Exclusao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seta a conexao do TOP com a base da Protheus|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TCSetConn(nAmbTOP)
		
		//Antes de Excluir, verifica se pode ser excluido
		//Verifica se existe registro relacionado na tabela SPROFESSOR
		lCanEx := PxCRMCanEx( "SPROFESSOR", {"CODTITULACAO"}, {cCodTitulacao}, STR0012 +cCodTitulacao+ STR0013 +" SPROFESSOR "+ STR0010 ) //"Não é permitido excluir a titulação ###, pois existe um relacionamento com a tabela"
		
		if lCanEx //Pode excluir
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seta a conexao do TOP com a base do Sistema RM ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TCSetConn(nAmbCLASSIS)
			
			/* Efetua a Exclusao do registro na tabela STITULACAO */
			cQuery := "delete from STITULACAO"
			cQuery += " where CODTITULACAO = "+cCodTitulacao
			if TcSqlExec(cQuery) < 0 //Verifica se ocorreu erro
				conout( STR0011+" STITULACAO "+ STR0006 +Chr(10)+Chr(10)+alltrim(TcSqlError()))
				MsgStop(STR0011+" STITULACAO "+ STR0006 +Chr(10)+Chr(10)+alltrim(TcSqlError()))
				lRet := .F.
			else
				TcSqlExec("COMMIT")
			endif
		else
			lRet := .F.
		endif
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seta a conexao do TOP com a base da Protheus|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TCSetConn( nAmbTOP )
	
	TCUNLINK(nAmbCLASSIS) //Finaliza a conexao do TOP com a base do Sistema RM
endif

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ClsConsPrfºAutor  ³Alberto Deviciente  º Data ³ 20/Jan/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe registro do funcionario em questao      º±±
±±º          ³relacionado nas tabelas do RM Classis Net (RM Sistemas).    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Integracao Protheus x RM Classis Net                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºOBS:	  	 ³Funcao antiga chamava-se Gp010VerRM 						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ClsConsPrf(cCmpVld)
Local lRet 		:= .T.
Local aVerCanEx := {}
Local nInd		:= 0
Local cMsg 		:= ""

Default cCmpVld := ""

if cCmpVld == "RA_CATFUNC"
	cMsg := STR0001+" "+alltrim(Tabela("28",M->RA_CATFUNC,.F.))+STR0002 //Não é permitido alterar a categoria deste funcionário para ###, pois esse funcionário é um professor no sistema RM Classis Net.
endif

if empty(xFilial("SRA"))
//  	              TABELA A VERIFICAR		CAMPOS 					        		VALORES DO CAMPOS
	aAdd( aVerCanEx, { "SPLANOAULA"			,'{"CODCOLIGADA","CODPROF"}'			, '{SM0->M0_CODIGO,SRA->RA_MAT}' } )
	aAdd( aVerCanEx, { "SDISPPROFESSOR"		,'{"CODCOLIGADA","CODPROF"}'			, '{SM0->M0_CODIGO,SRA->RA_MAT}' } )
	aAdd( aVerCanEx, { "ZSFPPROFESSOR"		,'{"CODCOLIGADA","CODPROF"}'			, '{SM0->M0_CODIGO,SRA->RA_MAT}' } )
else
	aAdd( aVerCanEx, { "SPLANOAULA"			,'{"CODCOLIGADA","CODFILIAL","CODPROF"}', '{SM0->M0_CODIGO,SRA->RA_FILIAL,SRA->RA_MAT}' } )
	aAdd( aVerCanEx, { "SDISPPROFESSOR"		,'{"CODCOLIGADA","CODFILIAL","CODPROF"}', '{SM0->M0_CODIGO,SRA->RA_FILIAL,SRA->RA_MAT}' } )
	aAdd( aVerCanEx, { "ZSFPPROFESSOR"		,'{"CODCOLIGADA","CODFILIAL","CODPROF"}', '{SM0->M0_CODIGO,SRA->RA_FILIAL,SRA->RA_MAT}' } )
endif
aAdd( aVerCanEx, { "SPROFESSORTURMA"		, '{"CODCOLIGADA","CODPROF"}'			, '{SM0->M0_CODIGO,SRA->RA_MAT}' } )
aAdd( aVerCanEx, { "SDISCAUTORIZADA"		, '{"CODCOLIGADA","CODPROF"}'			, '{SM0->M0_CODIGO,SRA->RA_MAT}' } )
aAdd( aVerCanEx, { "SATIVIDADEPROFESSOR"	, '{"CODCOLIGADA","CODPROF"}'			, '{SM0->M0_CODIGO,SRA->RA_MAT}' } )
aAdd( aVerCanEx, { "SATENDIMENTO"			, '{"CODCOLIGADA","CODPROF"}'			, '{SM0->M0_CODIGO,SRA->RA_MAT}' } )
aAdd( aVerCanEx, { "SOBJETOAVALIADO"		, '{"CODCOLIGADA","CODPROF"}'			, '{SM0->M0_CODIGO,SRA->RA_MAT}' } )
aAdd( aVerCanEx, { "SOCORRENCIAALUNO"		, '{"CODCOLIGADA","CODPROF"}'			, '{SM0->M0_CODIGO,SRA->RA_MAT}' } )
aAdd( aVerCanEx, { "SOCORRENCIAPROFESSOR"	, '{"CODCOLIGADA","CODPROF"}'			, '{SM0->M0_CODIGO,SRA->RA_MAT}' } )
aAdd( aVerCanEx, { "SORIENTACAO"			, '{"CODCOLIGADA","CODPROF"}'			, '{SM0->M0_CODIGO,SRA->RA_MAT}' } )


for nInd :=1 to len(aVerCanEx)	
	if !PxCRMCanEx( aVerCanEx[nInd][1], &(aVerCanEx[nInd][2]), &(aVerCanEx[nInd][3]), cMsg ) //Verifica se existe registro relacionado na tabela em questao da base do RM Classis Net (RM Sistemas)
		lRet := .F. //Nao permite Alterar / Deletar
		Exit
	endif
next nInd

Return lRet 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ClsIncPrf ºAutor  ³Alberto Deviciente  º Data ³ 20/Jan/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua inclusao de registros na tabela INT_FUNC (Tabela de º±±
±±º          ³integracao de professores) referente a Integracao do        º±±
±±º          ³Protheus x RM Classis Net (RM Sistemas).                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Tipo de operaco executada:                          º±±
±±º          ³ (I=Inclusao, U=Alteracao, D=Exclusao)                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Integracao Protheus x RM Classis Net                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºOBS:	  	 ³Funcao antiga chamava-se Gp010IntPrf 						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ClsIncPrf(cOperacao, cRotina)
Local cQry 		:= ""
Local cTelefone := ""
Local cNome 	:= ""
Local cPriNom	:= "" //Aplicavel somente a ambiente mexico
Local cSegNom	:= "" //Aplicavel somente a ambiente mexico
Local cPriSobr	:= "" //Aplicavel somente a ambiente mexico
Local cSegSobr	:= "" //Aplicavel somente a ambiente mexico
Local cApelido 	:= ""
Local cEndereco := ""
Local cComplem 	:= ""
Local cBairro 	:= ""
Local cMunicip 	:= ""
Local cRG		:= ""
Local cTitEleit := ""
Local cZonaSec 	:= ""
Local cNumCp 	:= ""
Local cEmail 	:= ""
Local aInsere	:= {}
Local aEstCivil := {} //De-Para do estado civil
Local cEstCivil := ""
Local aGrauInst := {} //De-Para do grau de instrucao
Local cGrauInst := ""

//Busca o tamanho correto dos campos
Local nTamTelef 	:= ""
Local nTamNome  	   := ""
Local nTamApeli 	:= ""
Local nTamEnder 	:= ""
Local nTamCompl 	:= ""
Local nTamBairr 	:= ""
Local nTamMunic 	:= ""
Local nTamRG        := ""
Local nTamTitu 		:= ""
Local nTamZona 		:= ""
Local nTamNumCP 	:= ""
Local nTamEmail 	:= ""
Local nTamPriNom	:= 0
Local nTamSegNom	:= 0
Local nTamPriSob	:= 0
Local nTamSegSob	:= 0 

Local lDel			:= .T.

Local cMV_ACCATPR	:= GetMV("MV_ACCATPR") //Categorias de funcionarios que serao considerados professores
Local cMV_GPCFUPR	:= alltrim(GetNewPar("MV_GPCFUPR", "")) //Quais categorias de funcionário que podem ser também considerado professor.

Local cCodPes		:= "0"       //Matricula anterior em caso de Trasferência e/ou FUN_CODPESSOA da tabela INT_FUNC

TCSetConn(advConnection())

nTamTelef     := ClsTamCmp("FUN_TELEFONE", "INT_FUNC")        //Busca o tamanho correto do campo
nTamNome      := ClsTamCmp("FUN_NOME", "INT_FUNC")            //Busca o tamanho correto do campo
nTamApeli     := ClsTamCmp("FUN_APELIDO", "INT_FUNC")         //Busca o tamanho correto do campo
nTamEnder     := ClsTamCmp("FUN_ENDERECO", "INT_FUNC")        //Busca o tamanho correto do campo
nTamCompl     := ClsTamCmp("FUN_COMPLEMENTO", "INT_FUNC")     //Busca o tamanho correto do campo
nTamBairr     := ClsTamCmp("FUN_BAIRRO", "INT_FUNC")          //Busca o tamanho correto do campo
nTamMunic     := ClsTamCmp("FUN_CIDADE", "INT_FUNC")          //Busca o tamanho correto do campo
nTamRG        := ClsTamCmp("FUN_RG", "INT_FUNC")              //Busca o tamanho correto do campo
nTamTitu      := ClsTamCmp("FUN_TITULOELEITOR", "INT_FUNC")   //Busca o tamanho correto do campo
nTamZona      := ClsTamCmp("FUN_ZONASECAO", "INT_FUNC")       //Busca o tamanho correto do campo
nTamNumCP     := ClsTamCmp("FUN_CARTEIRATRAB", "INT_FUNC")    //Busca o tamanho correto do campo
nTamEmail     := ClsTamCmp("FUN_EMAIL", "INT_FUNC")           //Busca o tamanho correto do campo

//Busca o tamanho correto dos campos do mexico
if cPaisLoc == "MEX"
	nTamPriNom	:= ClsTamCmp("FUN_PRINOM", "INT_FUNC") //Busca o tamanho correto do campo
	nTamSegNom	:= ClsTamCmp("FUN_SEGNOM", "INT_FUNC") //Busca o tamanho correto do campo
	nTamPriSob	:= ClsTamCmp("FUN_PRISOBR","INT_FUNC") //Busca o tamanho correto do campo
	nTamSegSob	:= ClsTamCmp("FUN_SEGSOBR","INT_FUNC") //Busca o tamanho correto do campo
endif
     
//Monta o De-Para de legendas do Estado-Civil
//[x,1] - Codigo Microsiga 
//[x,2] - Codigo CorporeRM
aAdd(aEstCivil,{"C","C" }) //Casado
aAdd(aEstCivil,{"D","I" }) //Divorciado
aAdd(aEstCivil,{"M","O" }) //Marital
aAdd(aEstCivil,{"Q","D" }) //Desquitado
aAdd(aEstCivil,{"S","S" }) //Solteiro
aAdd(aEstCivil,{"V","V" }) //Viuvo

//Monta o De-Para de legendas do Grau de instrucao
//[x,1] - Codigo Microsiga 
//[x,2] - Codigo CorporeRM
aAdd(aGrauInst,{"10","1" }) //ANALFABETO
aAdd(aGrauInst,{"20","2" }) //ATE 4¦ SERIE INCOMPLETA (PRIMARIO INCOMPLETO)
aAdd(aGrauInst,{"25","3" }) //COM 4¦ SERIE COMPLETA DO 1§ GRAU (PRIMARIO COMPLETO) 
aAdd(aGrauInst,{"30","4" }) //PRIMEIRO GRAU (GINASIO) INCOMPLETO
aAdd(aGrauInst,{"35","5" }) //PRIMEIRO GRAU (GINASIO) COMPLETO
aAdd(aGrauInst,{"40","6" }) //SEGUNDO GRAU (COLEGIAL) INCOMPLETO
aAdd(aGrauInst,{"45","7" }) //SEGUNDO GRAU (COLEGIAL) COMPLETO
aAdd(aGrauInst,{"50","8" }) //SUPERIOR INCOMPLETO
aAdd(aGrauInst,{"55","9" }) //SUPERIOR COMPLETO
aAdd(aGrauInst,{"85","B" }) //POS-GRADUACAO/ESPECIALIZACAO
aAdd(aGrauInst,{"65","D" }) //MESTRADO COMPLETO
aAdd(aGrauInst,{"75","F" }) //DOUTORADO COMPLETO
aAdd(aGrauInst,{"95","H" }) //POS-DOUTORADO

//Define o Estado Civil
If !Empty(SRA->RA_ESTCIVI)
	cEstCivil := aEstCivil[aScan(aEstCivil,{|x| x[1] == alltrim(SRA->RA_ESTCIVI)}),2]
EndIf

//Define o Grau de Instrucao
If !Empty(SRA->RA_GRINRAI)
	cGrauInst := aGrauInst[aScan(aGrauInst,{|x| x[1] == alltrim(SRA->RA_GRINRAI)}),2]
EndIf

If cOperacao == "I"  //I=Inclusao
	If !(SRA->RA_CATFUNC $ cMV_ACCATPR) .and. !(SRA->RA_CATFUNC $ cMV_GPCFUPR)
		Return
	Elseif SRA->RA_CATFUNC $ cMV_GPCFUPR
		//Pergunta ao usuario se o funcionario cadastrado tambem exerce a funcao de professor
		If !MsgYesNo(STR0004) //Esse funcionário exerce a função de professor?
			Return
		Endif
	Endif
Elseif cOperacao == "U" //U=Alteracao
	If cRotina == "GPE010" 
		If GetMemVar( "RA_CATFUNC" ) $ cMV_ACCATPR
			//Funcionário já Processado pelo RM Classis. Exclui registro pendentes de processamento 
			//na tabela de integração INT_FUNC.
			ClsDropPr(SM0->M0_CODIGO, GetMemVar( "RA_MAT" ), @cCodPes, @cOperacao)
			//Endif
		Elseif GetMemVar( "RA_CATFUNC" ) $ cMV_GPCFUPR
			//Pergunta ao usuario se este funcionario exerce a funcao de professor para inclui o professor no RM Classis Net (RM Sistemas)
			If MsgYesNo(STR0004) //Esse funcionário exerce a função de professor?
				//Funcionário já Processado pelo RM Classis. Exclui registro pendentes de processamento
				//na tabela de integração INT_FUNC.
				ClsDropPr(SM0->M0_CODIGO, GetMemVar( "RA_MAT" ), @cCodPes, @cOperacao)
			Else
				Return
			Endif
		Elseif (GdFieldGet( "RA_CATFUNC" , 1 , .F. , aSraHeader , aSvSraCols ) $ cMV_ACCATPR) .or. (GdFieldGet( "RA_CATFUNC" , 1 , .F. , aSraHeader , aSvSraCols ) $ cMV_GPCFUPR)
			//Verifica se o professor existe na base de dados do RM Classis Net
			If ClsSeekPr(SM0->M0_CODIGO, GetMemVar( "RA_MAT" ))
				cOperacao := "D" //D=Exclusao
			Else
				Return
			Endif
		Else
			Return
		Endif
	ElseIf cRotina == "GPE180"
		If SRA->RA_CATFUNC $ cMV_ACCATPR
			//Funcionário já Processado pelo RM Classis e está sendo Transferido.
			// Exclui registro pendentes de processamento na tabela de integração INT_FUNC.
			ClsDropPr(SM0->M0_CODIGO, cMatDe, @cCodPes, @cOperacao)
		Else
			If SRA->RA_CATFUNC $ cMV_GPCFUPR
				//Pergunta ao usuario se este funcionario exerce a funcao de professor para inclui o professor no RM Classis Net (RM Sistemas)
				If MsgYesNo(STR0004) //Esse funcionário exerce a função de professor?
					//Funcionário já Processado pelo RM Classis e está sendo Transferido.
					// Exclui registro pendentes de processamento na tabela de integração INT_FUNC.
					ClsDropPr(SM0->M0_CODIGO, cMatDe, @cCodPes, @cOperacao)
				Else
					Return
				Endif
		  EndIf
		Endif
	ElseIf cRotina == "GPEM040"
		// Exclui registro pendentes de processamento na tabela de integração INT_FUNC.
		ClsDropPr(SM0->M0_CODIGO, SRA->RA_MAT, @cCodPes, @cOperacao)		
	Endif
Elseif cOperacao == "D"  //D=Exclusao
	If !(SRA->RA_CATFUNC $ cMV_ACCATPR)
		If !(SRA->RA_CATFUNC $ cMV_GPCFUPR)
			Return
		Else
			//Verifica se o professor nao existe na base de dados do RM Classis Net
			If !ClsSeekPr(SM0->M0_CODIGO, SRA->RA_MAT)
				Return
			Else
				lDel:= ClsDropPr(SM0->M0_CODIGO, GetMemVar( "RA_MAT" ), @cCodPes, @cOperacao)
				If !lDel
					Return
				Endif
			Endif
		Endif
	Else
		If !ClsSeekPr(SM0->M0_CODIGO, SRA->RA_MAT)
			Return
		Else
			lDel:= ClsDropPr(SM0->M0_CODIGO, GetMemVar( "RA_MAT" ), @cCodPes, @cOperacao)
			If !lDel
				Return
			Endif
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Elimina caracteres que fazem parte da Mascara³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTelefone := alltrim(SRA->RA_TELEFON)
If Empty(cTelefone)
	cTelefone:= Space(TamSX3("RA_TELEFON")[1])
Endif
cTelefone := SubStr(Replace(Replace(Replace(cTelefone,")",""),"(",""),"-",""),1,nTamTelef)

cNome 		:= SubStr(alltrim(SRA->RA_NOME),1,nTamNome)
cApelido 	:= SubStr(alltrim(SRA->RA_APELIDO),1,nTamApeli)
cEndereco 	:= SubStr(alltrim(SRA->RA_ENDEREC),1,nTamEnder)
cComplem 	:= SubStr(alltrim(SRA->RA_COMPLEM),1,nTamCompl)
cBairro 	:= SubStr(alltrim(SRA->RA_BAIRRO),1,nTamBairr)
cMunicip 	:= SubStr(alltrim(SRA->RA_MUNICIP),1,nTamMunic)
cRG			:= SubStr(SRA->RA_RG,1,nTamRG)
cTitEleit 	:= SubStr(SRA->RA_TITULOE,1,nTamTitu)
cZonaSec 	:= SubStr(SRA->RA_ZONASEC,1,nTamZona)
cNumCp 		:= SubStr(SRA->RA_NUMCP,1,nTamNumCP)
cEmail 		:= SubStr(alltrim(SRA->RA_EMAIL),1,nTamEmail)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe apostrofo nos campos abaixo e faz o tratamento necessario para    ³
//³nao dar erro na insercao do registro com apostrofo no banco de dados                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNome 		:= Replace(cNome,"'","''")
cApelido 	:= Replace(cApelido,"'","''")
cEndereco	:= Replace(cEndereco,"'","''")
cComplem 	:= Replace(cComplem,"'","''")
cBairro 	:= Replace(cBairro,"'","''")
cMunicip	:= Replace(cMunicip,"'","''")

cApelido 	:= if(empty(cApelido), 	" ", cApelido)
cEndereco	:= if(empty(cEndereco), " ", cEndereco)
cComplem 	:= if(empty(cComplem), 	" ", cComplem)
cBairro 	:= if(empty(cBairro), 	" ", cBairro)
cMunicip	:= if(empty(cMunicip), 	" ", cMunicip)
cRG 		:= if(empty(cRG), 		" ", cRG)
cTitEleit 	:= if(empty(cTitEleit), " ", cTitEleit)
cZonaSec   	:= if(empty(cZonaSec), 	" ", cZonaSec)
cNumCp 		:= if(empty(cNumCp), 	" ", cNumCp)
cEmail 		:= if(empty(cEmail), 	" ", cEmail)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adequa os campos do Mexico:                ³
//³1 - Ajusta tamanho, truncando se necessario³
//³2 - Remove aspas                           ³
//³3 - Adiciona espaco em branco, se vazio    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if cPaisLoc == "MEX"
	cPriNom		:= SubStr(alltrim(SRA->RA_PRINOME),1,nTamPriNom)
	cSegNom		:= SubStr(alltrim(SRA->RA_SECNOME),1,nTamSegNom)
	cPriSobr	:= SubStr(alltrim(SRA->RA_PRISOBR),1,nTamPriSob)
	cSegSobr	:= SubStr(alltrim(SRA->RA_SECSOBR),1,nTamSegSob)
	
	cPriNom		:= Replace(cPriNom ,"'","''")
	cSegNom		:= Replace(cSegNom ,"'","''")
	cPriSobr	:= Replace(cPriSobr,"'","''")
	cSegSobr	:= Replace(cSegSobr,"'","''")

	cPriNom		:= if(empty(cPriNom),  	" ", cPriNom) 
	cSegNom		:= if(empty(cSegNom),  	" ", cSegNom) 
	cPriSobr	:= if(empty(cPriSobr), 	" ", cPriSobr) 
	cSegSobr	:= if(empty(cSegSobr), 	" ", cSegSobr) 
endif

//Efetua a inclusao na tabela INT_FUNC
aAdd(aInsere,{"FUN_COLIGADA"  		,alltrim(str(val(SM0->M0_CODIGO)))	 })
aAdd(aInsere,{"FUN_FILIAL"  		,"'"+xFilial("SRA")+"'"				 })
aAdd(aInsere,{"FUN_MAT"  			,"'"+SRA->RA_MAT+"'"					 })
aAdd(aInsere,{"FUN_NOME"  			,"'"+cNome+"'"						 })
if cPaisLoc == "MEX"
	aAdd(aInsere,{"FUN_PRINOM"  	,"'"+cPriNom+"'"						 })
	aAdd(aInsere,{"FUN_SEGNOM"  	,"'"+cSegNom+"'"						 })
	aAdd(aInsere,{"FUN_PRISOBR"  	,"'"+cPriSobr+"'"						 })
	aAdd(aInsere,{"FUN_SEGSOBR"  	,"'"+cSegSobr+"'"						 })
	aAdd(aInsere,{"FUN_PROCESS"     ,"'"+SRA->RA_PROCES+"'"	 	 		 })
endif
aAdd(aInsere,{"FUN_APELIDO"  		,"'"+cApelido+"'"						 })
aAdd(aInsere,{"FUN_ESTADOCIVIL" 	,"'"+cEstCivil+"'"					 })
aAdd(aInsere,{"FUN_SEXO"  			,"'"+SRA->RA_SEXO+"'"				 })
aAdd(aInsere,{"FUN_NACIONAL"  		,"'"+SRA->RA_NACIONA+"'"				 })
aAdd(aInsere,{"FUN_ENDERECO"  		,"'"+cEndereco+"'"					 })
aAdd(aInsere,{"FUN_COMPLEMENTO" 	,"'"+cComplem+"'"						 })
aAdd(aInsere,{"FUN_CEP"  			,"'"+SRA->RA_CEP+"'"					 })
aAdd(aInsere,{"FUN_BAIRRO"  		,"'"+cBairro+"'"						 })
aAdd(aInsere,{"FUN_ESTADO"  		,"'"+SRA->RA_ESTADO+"'"				 })
aAdd(aInsere,{"FUN_CIDADE"  		,"'"+cMunicip+"'"						 })
aAdd(aInsere,{"FUN_REGISTROPROF"	,"'"+SRA->RA_REGISTR+"'"				 })
aAdd(aInsere,{"FUN_CPF"  			,"'"+SRA->RA_CIC+"'"					 })
aAdd(aInsere,{"FUN_TELEFONE"  		,"'"+cTelefone+"'"					 })
aAdd(aInsere,{"FUN_RG"  			,"'"+cRG+"'"							 	 })
aAdd(aInsere,{"FUN_RGORG"  			,"'"+SRA->RA_RGORG+"'"				 })
aAdd(aInsere,{"FUN_TITULOELEITOR"	,"'"+cTitEleit+"'"					 })
aAdd(aInsere,{"FUN_ZONASECAO"  		,"'"+cZonaSec+"'"						 })
aAdd(aInsere,{"FUN_CARTEIRATRAB" 	,"'"+substr(cNumCp,1,4)+"'"			 })
aAdd(aInsere,{"FUN_SERIECARTTRAB" 	,"'"+substr(SRA->RA_SERCP,1,4)+"'"	 })
aAdd(aInsere,{"FUN_UFCARTTRAB"  	,"'"+SRA->RA_UFCP+"'"				 })
aAdd(aInsere,{"FUN_HABILIT"  		,"'"+SRA->RA_HABILIT+"'"				 })
aAdd(aInsere,{"FUN_RESERVISTA"  	,"'"+SRA->RA_RESERVI+"'"				 })
aAdd(aInsere,{"FUN_NATURAL"  		,"'"+SRA->RA_NATURAL+"'"				 })
aAdd(aInsere,{"FUN_EMAIL"  			,"'"+cEmail+"'"						 })
aAdd(aInsere,{"FUN_RACACOR"  		,"'"+SRA->RA_RACACOR+"'"				 })
aAdd(aInsere,{"FUN_DEFISICA"  		,"'"+SRA->RA_DEFIFIS+"'"				 })
aAdd(aInsere,{"FUN_CARGO"  			,"'"+SRA->RA_CARGO+"'"				 })
aAdd(aInsere,{"FUN_PROFISSAO"  		,"'"+SRA->RA_CODIGO+"'"				 })
aAdd(aInsere,{"FUN_CODTITULACAO" 	,"'"+SRA->RA_CODTIT+"'"				 })
aAdd(aInsere,{"FUN_CODSITUACAO"  	,"'"+SRA->RA_SITFOLH+"'"				 })
aAdd(aInsere,{"FUN_FUNCAO"  		,"'"+SRA->RA_CODFUNC+"'"				 })
aAdd(aInsere,{"FUN_HORAGRAVA"  		,"'"+Time()+"'"						 })
aAdd(aInsere,{"FUN_STATUSIMPORT"  	,"'1'"									 })
aAdd(aInsere,{"FUN_OBSIMPORT"  		,"' '"		 							 })
aAdd(aInsere,{"FUN_USUGRAVA"  		,"'PROTHEUS'"		 					 })
aAdd(aInsere,{"FUN_ROTIMPORT"  		,"'S'"									 })
aAdd(aInsere,{"FUN_ROTGRAVA"  		,"'"+cRotina+"'"						 })
aAdd(aInsere,{"FUN_PROCIMPORT"  	,"'"+cOperacao+"'"					 })
aAdd(aInsere,{"FUN_CODPESSOA"  		,cCodPes								 })
aAdd(aInsere,{"FUN_ESTADONATAL"  	,"'"+SRA->RA_ESTADO+"'"				 })
aAdd(aInsere,{"FUN_DTNASCIMENTO"	,ClsQryDat(SRA->RA_NASC,.F.)		 })
aAdd(aInsere,{"FUN_ADMISSAO"  		,ClsQryDat(SRA->RA_ADMISSA,.F.)		 })
aAdd(aInsere,{"FUN_DATAGRAVA"  		,ClsQryDat(Date(),.F.)				 })
if cPaisLoc == "BRA"
	aAdd(aInsere,{"FUN_DTEMISSAORG" ,ClsQryDat(SRA->RA_DTRGEXP,.F.)	 })
elseif cPaisLoc == "MEX"
	//Data de emissao do RG recebe a data do IMSS (se houver baixa sera data da baixa) - SIGA3286
	If !Empty(SRA->RA_FECREI)
		aAdd(aInsere,{"FUN_DTEMISSAORG" ,ClsQryDat(SRA->RA_FECREI,.F.)	 })
	else
		aAdd(aInsere,{"FUN_DTEMISSAORG" ,ClsQryDat(SRA->RA_ADMISSA,.F.) })	
	endif
endif

If ClsVersion("FUN_GRAUINSTRUCAO")
	// preenche o campo Grau de Instrucao caso o mesmo esteja na versão.
	aAdd(aInsere,{"FUN_GRAUINSTRUCAO" 	,"'"+cGrauInst+"'"				 })
EndIf

cQry := ClsQryIns(aInsere,"INT_FUNC")

Begin Transaction
if TCSQLExec(cQry) < 0
	//Retornando erro
	conout( STR0003 +Chr(13)+Chr(10)+Chr(13)+Chr(10) + alltrim(TcSqlError()) ) 	//Erro ao tentar incluir registro na tabela de integração (INT_FUNC):
	MsgStop( STR0003 +Chr(13)+Chr(10)+Chr(13)+Chr(10) + alltrim(TcSqlError()) ) 	//Erro ao tentar incluir registro na tabela de integração (INT_FUNC):
else
	TcSqlExec("COMMIT")
endif
End Transaction

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ClsTamCmp ºAutor  ³ Alberto Deviciente º Data ³ 20/Jan/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca o tamanho correto do campo no banco de dados.         º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºParametros³ExpC1 - Campo que deseja saber o tamanho                    º±±
±±º          ³ExpC2 - Tabela cujo o campo pertence.                       º±±
±±º          ³       Exemplos: SA1010, INT_CLIENTE, INT_FUNC              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Integracao Protheus x RM Classis Net                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºOBS:	  	 ³Funcao antiga chamava-se Gp010TmCmp 						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ClsTamCmp(cCampo, cTabela)
Local cQuery 	:= ""
Local nRet 		:= 0
Local lOracle	:= "ORACLE"$Upper(TCGetDB())
Local aArea 	:= GetArea()

if lOracle //Banco ORACLE
	cQuery := "select COLUMN_NAME CAMPO, DATA_LENGTH TAMANHO"
	cQuery += "  from ALL_TAB_COLUMNS"
	cQuery += " where COLUMN_NAME = '"+cCampo+"'"
	cQuery += "   and TABLE_NAME = '"+cTabela+"'"
else //Banco SQL SERVER
	cQuery := "select name CAMPO,length TAMANHO"
	cQuery += "  from syscolumns"
	cQuery += " where name = '"+cCampo+"'"
	cQuery += "   and id = object_id('"+cTabela+"')"
endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "QRYTAMCMP", .F., .T.)

if QRYTAMCMP->( !EoF() )
	nRet := QRYTAMCMP->TAMANHO
endif

QRYTAMCMP->( dbCloseArea() )

RestArea(aArea)

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ClsSeekPr ºAutor  ³ Alberto Deviciente º Data ³ 01/Abr/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o professor jah existe na base do RM Classis Netº±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºParametros³ExpC1 - Empresa do Protheus (Coligada no RM)                º±±
±±º          ³ExpC2 - Matricula do Professor (RA_MAT)                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Integracao Protheus x RM Classis Net                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºOBS:	  	 ³Funcao antiga chamava-se Gp010SeekPr 						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ClsSeekPr(cEmp, cMatFunc)
Local lRet := .F.
Local cQuery := ""
Local lTopOk 		:= .T.
Local nAmbCLASSIS 	:= 0
Local nAmbTOP		:= 0
Local nFUN_ID 		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida as conexoes com as bases Protheus e Classis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lTopOk := _IntRMTpCon(@nAmbTOP,@nAmbCLASSIS)

cEmp := alltrim(str(val(cEmp)))

if lTopOk
	
	// Alterna o TOP para o ambiente do RM Classis Net (RM Sistemas)
	TCSetConn( nAmbCLASSIS )
	
	//Verifica se o Funcionario/Professor jah existe na base do RM Classis Net (tabela SPROFESSOR)
	cQuery := "SELECT COUNT(CODPROF) QTD"
	cQuery += "  FROM SPROFESSOR"
	cQuery += " WHERE CODCOLIGADA = "+cEmp
	cQuery += "   AND CODPROF = '"+alltrim(cMatFunc)+"'"
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "_QRYPROF", .F., .T.)
	
	lRet := _QRYPROF->( !EoF() ) .and. _QRYPROF->QTD > 0
	_QRYPROF->( dbCloseArea() )
	
	// Alterna o TOP para o ambiente padrao
	TCSetConn( nAmbTOP )
	
	TCUNLINK(nAmbCLASSIS) // Finaliza a conexao do TOP com o ambiente do RM Classis Net (RM Sistemas)
	
	//Se nao encoutrou na tabela SPROFESSOR do RM Classis Net, verifica se jah existe registro de inclusao 
	//do Funcionario/Professor na tabela de integracao (INT_FUNC) como "Pendente"
	if !lRet
		cQuery := "SELECT MAX(FUN_ID) FUN_ID"
		cQuery += "  FROM INT_FUNC"
		cQuery += " WHERE FUN_COLIGADA = "+cEmp
		cQuery += "   AND FUN_MAT = '"+alltrim(cMatFunc)+"'"
		cQuery += "   AND FUN_STATUSIMPORT IN ('1', '3')" //1=Pendente; 3=Inconsitente
		cQuery += "   AND FUN_PROCIMPORT = 'I'" //I=Inclusao
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "_QRYPROF", .F., .T.)
		
		if _QRYPROF->( !EoF() ) .and. _QRYPROF->FUN_ID > 0
			nFUN_ID := _QRYPROF->FUN_ID
			lRet := .T.
		endif
		_QRYPROF->( dbCloseArea() )
		
		if lRet
			//Verifica se existem registros com instrucao de exclusao do professor na tabela de integracao (INT_FUNC) como "Pendente"
			cQuery := "SELECT COUNT(FUN_MAT) QTD"
			cQuery += "  FROM INT_FUNC"
			cQuery += " WHERE FUN_COLIGADA = "+cEmp
			cQuery += "   AND FUN_MAT = '"+alltrim(cMatFunc)+"'"
			cQuery += "   AND FUN_STATUSIMPORT IN ('1', '3')" //1=Pendente; 3=Inconsitente
			cQuery += "   AND FUN_PROCIMPORT = 'D'" //D=Exclusao
			cQuery += "   AND FUN_ID > "+alltrim(str(nFUN_ID))
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "_QRYPROF", .F., .T.)		
			
			if _QRYPROF->( !EoF() ) .and. _QRYPROF->QTD > 0
				lRet := .F.
			else
				lRet := .T.
			endif
			_QRYPROF->( dbCloseArea() )
		endif
		
	endif
endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ClsGetAulaºAutor  ³Cesar A. Bianchi    º Data ³  09/17/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Coleta o total de aulas semanais deste professor dentro da  º±±
±±º          ³SPROFESSORTURMA, considerando o periodo de geracao.         º±±
±±º          ³ESTA FUNCAO EH PALIATIVA, POIS O TOTAL DE AULAS NA SEMANA DEº±±
±±º          ³VE SER GRAVADO NO CAMPO TAR_AULASEMANA PELO CLASSIS NET DU- º±±
±±º          ³RANTE A EXPORTACAO DA FOLHA								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ClsGetAula(cMatPrf,cDtIni,cDtFim)
Local cQuery := ""
Local aArea	 := getArea()
Local nRet	 := 0
Local lTopOk := .F.
Local nAmbCLASSIS 	:= 0
Local nAmbTOP		:= 0

lTopOk := _IntRMTpCon(@nAmbTOP,@nAmbCLASSIS)

If lTopOk

	TCSetConn(nAmbCLASSIS)
 
	cQuery := " SELECT SUM(AULASSEMANAISPROF) TOTAL FROM SPROFESSORTURMA "
	cQuery += " WHERE CODPROF = '" + alltrim(cMatPrf) + "' "
	cQuery += " AND CONVERT(VARCHAR, DTINICIO, 112) <= '" + cDtIni + "'"
	cQuery += " AND CONVERT(VARCHAR, DTFIM, 112) >= '" + cDtFim + "'"
	cQuery := ChangeQuery(cQuery)
	iif(Select('QRY')>0,QRY->(dbCloseArea()),Nil)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"QRY", .F., .T.)	
	nRet := QRY->TOTAL
	QRY->(dbCloseArea())
	
	TCSetConn(nAmbTOP)
	TcUnLink(nAmbCLASSIS)
EndIf


RestArea(aArea)
Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ClsMatExisºAutor  ³Cesar A. Bianchi    º Data ³  08/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna se uma matricula informada via parametro existe na  º±±
±±º          ³tabela SRA, desconsiderando a Filial.                       º±±
±±º          ³Estas buscas são necessarias pois o codigo de matricula nun-º±±
±±º          ³ca deve se repetir, mesmo com SRA exclusiva, haja vista que º±±
±±º          ³a SPROFESSOR (RM) nao contempla FILIAL. 					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ClsMatExis(cCodMat)
Local lRet 		:= .F.
Local aArea 	:= getArea()
Local cQuery    := ""
Default cCodMat := ""

If Empty(xFilial('SRA'))
	Return .F.
ElseIf !Empty(cCodMat)
	cQuery := " SELECT COUNT(*) TOTAL FROM " + RetSqlName('SRA') + " SRA "
	cQuery += " WHERE SRA.RA_FILIAL <> '" + xFilial('SRA') + "'" //(Pesquisa apenas em FILIALS DIFERENTES)
	cQuery += " AND SRA.RA_MAT = '" + cCodMat + "'"	
	cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	iif(Select('QRY')>0,QRY->(dbCloseArea()),Nil)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"QRY", .F., .T.)
	lRet := QRY->TOTAL > 0
	QRY->(dbCloseArea())
EndIf

RestArea(aArea)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ClsDropPr ºAutor  ³ Roney de Oliveira º Data ³ 07/Mai/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclui registros não processados pelo RM Classis           º±±
±±º          ³ na tabela INT_FUNC                                         º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºParametros³ExpC1 - Empresa do Protheus (Coligada no RM)                º±±
±±º          ³ExpC2 - Matricula do Professor (RA_MAT)                     º±±
±±º          ³ExpC3 - Codigo Pessoa (FUN_CCODPESSOA na INT_FUNC           º±±
±±º          ³ExpC4 - Codigo da operação que está sendo realizada         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Integracao Protheus x RM Classis Net                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºOBS:	  	 ³                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ClsDropPr(cEmp, cMatFunc, cCodPes, cOperacao)
Local lRet			:= .F.
Local cQuery		:= ""
Local lTopOk 		:= .T.
Local nAmbCLASSIS	:= 0
Local nAmbTOP		:= 0

Default cOperacao	:= "U"

If !TCIsConnected()
	TCSetConn(advConnection())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida as conexoes com as bases Protheus e Classis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lTopOk := _IntRMTpCon(@nAmbTOP, @nAmbCLASSIS)

// Alterna o TOP para o ambiente padrao
TCSetConn(nAmbTOP)

cEmp := alltrim(str(Val(cEmp)))

// Recupera o CodPessoa gerado pelo RM
cQuery := "SELECT FUN_CODPESSOA"
cQuery += "  FROM INT_FUNC"
cQuery += " WHERE FUN_MAT = '" + cMatFunc + "'"
cQuery += "   AND FUN_PROCIMPORT IN ('I', 'U')"
cQuery += "   AND FUN_STATUSIMPORT = '2'"

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "_QRYPROF", .F., .T.)

If _QRYPROF->(!EoF())
	cCodPes := cValToChar(_QRYPROF->FUN_CODPESSOA)
Else
	cCodPes := "0"
EndIf

_QRYPROF->(dbCloseArea())

If lTopOk
	// Alterna o TOP para o ambiente do RM Classis Net (RM Sistemas)
	TCSetConn(nAmbCLASSIS)

	//Verifica se o Funcionario/Professor jah existe na base do RM Classis Net (tabela SPROFESSOR)
	If cCodPes != "0"
		cQuery := "SELECT COUNT(SPROFESSORFILIAL.CODPROF) QTD"
		cQuery += "  FROM SPROFESSOR"
		cQuery += "  JOIN SPROFESSORFILIAL ON SPROFESSOR.CODCOLIGADA = SPROFESSORFILIAL.CODCOLIGADA"
		cQuery += "   AND SPROFESSOR.CODPROF = SPROFESSORFILIAL.CODPROF"
		cQuery += " WHERE SPROFESSOR.CODPESSOA = '" + cCodPes + "'"
		cQuery += "   AND SPROFESSOR.CODCOLIGADA = " + cEmp
	Else
		cQuery := "SELECT COUNT(CODPROF) QTD"
		cQuery += "  FROM SPROFESSOR"
		cQuery += " WHERE CODCOLIGADA = " + cEmp
		cQuery += "   AND CODPROF = '" + AllTrim(cMatFunc) + "'"
	EndIf

	dbUseArea(.T., "TOPCONN", TCGENQRY(, , cQuery), "_QRYPROF", .F., .T.)   

	lRet := _QRYPROF->(!EoF()) .and. _QRYPROF->QTD > 0
	_QRYPROF->(dbCloseArea())
	TCUNLINK(nAmbCLASSIS) // Finaliza a conexao do TOP com o ambiente do RM Classis Net (RM Sistemas)

	// Alterna o TOP para o ambiente padrao
	TCSetConn(nAmbTOP)

	If !lRet
		cOperacao := "I" //Inclusão
	Else
		If ValType(cOperacao) == 'C' .And. cOperacao <> "D"
			cOperacao := "U" //Alteração
		Endif
	EndIf

	//Exclui os registros não processados
	cQuery := "DELETE FROM INT_FUNC"
	cQuery += " WHERE FUN_COLIGADA = " + cEmp
	cQuery += "   AND (FUN_MAT = '" + AllTrim(cMatFunc) + "'"
	cQuery += "    OR (FUN_CODPESSOA = '" + AllTrim(cCodPes) + "'"
	cQuery += "   AND FUN_CODPESSOA <> '0' ) )"
	cQuery += "   AND FUN_STATUSIMPORT = '1'"
	cQuery += "   AND FUN_PROCIMPORT IN ('I', 'U')"

	If TcSqlExec(cQuery) < 0 //Verifica se ocorreu erro
		conout( STR0011 +" INT_FUNC "+ STR0006 +Chr(10)+Chr(10)+alltrim(TcSqlError()))
		MsgStop(STR0011 +" INT_FUNC "+ STR0006 +Chr(10)+Chr(10)+alltrim(TcSqlError()))
		lRet := .F.
	Else
		TcSqlExec("COMMIT")
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} _IntRMTpCon
Funcao GENERICA utilizada para clientes que possuem a integracao Protheus x Classis Net.
Busca conexao com as bases de dados (Protheus e CorporeRM)

@param 	nAmbTOP - (REFERENCIA) Variavel que contera o ID da conexao do banco de dados do protheus no TopConnect
	    nAmbCLASSIS - (REFERENCIA) Variavel que contera o ID da conexao do banco de dados do Corpore no TopConnect
	    lMsgPadr - Flag para controlar se exibe a mensagem padrao que nao conseguiu efetuar a integracao entre os bancos

@author  Alberto Deviciente
@version P10
@since 	 19/06/08
@return  lOk - .T. para conexoes OK / .F. para erro em alguma das conexoes.
/*/
//-------------------------------------------------------------------------------------
Function _IntRMTpCon(nAmbTOP,nAmbCLASSIS,lMsgPadr)
Local lTopOK 	:= .T.
Local cAlias 	:= getNextAlias() 
Local lOracle	:= "ORACLE" $ Upper(TCGetDB())
Local cMsgPadr 	:= ""

//Declara as variaveis de conexao com as bases protheus X corpore
Private cIniFile 		:= GetAdv97()
Private cLastConn		:= ""
Private cProtect		:= ""
Private nPort			:= 0
Private cTopDataBase 	:= ""
Private cTopAlias 		:= ""
Private cTopServer 		:= ""
Private cBaseRM         := ""

Default lMsgPadr 		:= .F. //Se for .T. , entao adiciona a mensagem padrao que nao conseguiu efetuar a integracao

if lMsgPadr //Se for .T. , entao adiciona a mensagem padrao que nao conseguiu efetuar a integracao
	cMsgPadr := STR0021 + Chr(13)+Chr(10)+Chr(13)+Chr(10)  //"Não foi possível completar a integração com o Sistema RM Classis Net."
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega conexao atual do Protheus com o TOP³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nAmbTOP		:= advConnection()

nAmbCLASSIS := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca no SERVER.INI o TopServer, TopDataBase e TopAlias utilizado.³
//³Para Microsiga 11, considera tanto o parametro precedido de "Top" ³
//³como tambem o parametro precedido de "db", pois em ambos os casos ³
//³funcionam - SIGA3286												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTopServer := GetPvProfString( GetEnvServer(), "DbServer"  , "", cIniFile )
if empty(cTopServer)
	cTopServer := GetPvProfString( GetEnvServer(), "TopServer"  , "", cIniFile )
Endif
cTopDataBase := GetPvProfString( GetEnvServer(), "DbDataBase", "", cIniFile )
If Empty(cTopDataBase)
	cTopDataBase := GetPvProfString( GetEnvServer(), "TopDataBase", "", cIniFile )
EndIf
cTopAlias := GetPvProfString( GetEnvServer(), "DbAlias"	, ""   , cIniFile )
If Empty(cTopAlias)
	cTopAlias := GetPvProfString( GetEnvServer(), "TopAlias"	, ""   , cIniFile )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao localizou as variaveis do Top declaradas dentro da secao de ambiente, ³
//³entao procura na Secao [TopConnect] (ou [dbAcess] caso seja P11)    			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if empty(cTopServer)
	cTopServer := GetPvProfString("dbAccess", "Server", "", cIniFile )	
	If Empty(cTopServer)
		cTopServer := GetPvProfString("TopConnect", "Server", "", cIniFile )
	EndIf	
	//Se mesmo assim nao localizou, entao printa mensagem de erro
	if empty(cTopServer)
		MsgSTop(cMsgPadr+STR0022+Chr(13)+Chr(10)+STR0020+ cIniFile) //"O TopServer não está configurado corretamente no arquivo "
		lTopOk := .F.
	endif
endif                                                             
if empty(cTopDataBase)  
	cTopDataBase := GetPvProfString( "dbAccess", "DataBase", "", cIniFile )
	If Empty(cTopDataBase)
		cTopDataBase := GetPvProfString( "TopConnect", "DataBase", "", cIniFile )
	EndIf
	//Se mesmo assim nao localizou, entao printa mensagem de erro
	if Empty(cTopDataBase)
		MsgSTop(cMsgPadr+STR0022+Chr(13)+Chr(10) + STR0019 + cIniFile)  //"O TopDataBase não está configurado corretamente no arquivo "
		lTopOk := .F.
	endif
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca o Alias da Base de Dados do CLASSIS.NET NA TABELA INT_ALIASBD ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lTopOk
	if TCCanOpen("INT_ALIASBD") 
		cQuery := "SELECT INT_ALIAS "
		cQuery += "  FROM INT_ALIASBD "
		cQuery += " WHERE INT_SISTEMA = 'RM'"
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
		
		if (cAlias)->( !EoF() )
			cBaseRM := alltrim((cAlias)->INT_ALIAS)
		endif
		(cAlias)->( dbCloseArea() )
	else
		MsgSTop(cMsgPadr+STR0022+Chr(13)+Chr(10)+STR0018) //"Não foi encontrada a tabela INT_ALIASBD na base de dados."
		lTopOk := .F.
	endif
endif
         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se a base do CORPORE esta configurada no TOPCONECT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lTopOk
	if empty(cBaseRM)
		MsgSTop(cMsgPadr+STR0022+Chr(13)+Chr(10)+ STR0014 )  //"O Alias para o Banco de Dados RM não foi encontrado ou está em branco. Verifique a tabela INT_ALIASBD"
		lTopOk := .F.
	endif
	if empty(cTopServer)
		MsgSTop(cMsgPadr+ STR0022 +Chr(13)+Chr(10)+ STR0015 + cIniFile) //"O TopServer não está configurado corretamente no arquivo "
		lTopOk := .F.
	endif
endif

if lTopOk
	cProtect  := GetPvProfString("TopConnect","ProtheusOnly","0",cIniFile)
	cProtect  := GetSrvProfString("TopProtheusOnly",cProtect)
	nPort     := Val(GetPvProfString("TopConnect","Port","0",cInIfile ))
	nPort     := Val(GetSrvProfString("TopPort",StrZero(nPort,4,0)))   //Soh Para Conexao TCPIP
	
	IF cProtect == "1"
		cProtect := "@@__@@"    //Assinatura para o TOP
	Else
		cProtect := ""
	Endif
	
	cLastConn := cTopDataBase+";"+cBaseRM+";"+cTopServer
	
	//Faz conexao com TOP para base de dados do CLASSIS.NET (RM)
	nAmbCLASSIS := TCLink(cProtect+"@!!@"+cTopDataBase+"/"+cBaseRM,cTopServer,nPort)  // Nao Comer Licenca do Top
	IF nAmbCLASSIS < 0 // menor que zero eh codigo de erro
		nAmbCLASSIS := TCLink(cProtect+cTopDataBase+"/"+cBaseRM,cTopServer,nPort)
	Endif
	
	If nAmbCLASSIS < 0 // menor que zero eh codigo de erro
		IF Empty(cProtect)
			if lOracle
				cMsgPadr += STR0022+Chr(13)+Chr(10)+"TOPCONN Connection Failed - Error ("+Str(nAmbCLASSIS,4,0)+")"+cLastConn+Chr(10)+Chr(10)+ STR0016 //"Verifique se a configuração no TOPConnect está correta para a Base de Dados do RM ClassisNet."
			else
				cMsgPadr += STR0022+Chr(13)+Chr(10)+"TOPCONN Connection Failed - Error ("+Str(nAmbCLASSIS,4,0)+")"+cLastConn+Chr(10)+Chr(10)+ STR0017 //"Verifique se a configuração ODBC está correta."
			endif
			MsgSTop(cMsgPadr)
			lTopOk := .F.
		Else
			if lOracle
				cMsgPadr += STR0022+Chr(13)+Chr(10)+"TOPProtect Connection Failed - Error ("+Str(nAmbCLASSIS,4,0)+")"+cLastConn+Chr(10)+Chr(10)+ STR0016 //"Verifique se a configuração no TOPConnect está correta para a Base de Dados do RM Classis Net."
			else
				cMsgPadr += STR0022+Chr(13)+Chr(10)+"TOPProtect Connection Failed - Error ("+Str(nAmbCLASSIS,4,0)+")"+cLastConn+Chr(10)+Chr(10)+ STR0017 //"Verifique se a configuração ODBC está correta."
			endif
			MsgSTop(cMsgPadr)
			lTopOk := .F.
		Endif
	EndIf
endif

Return lTopOk

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsVersion
Verifica se um campo de tabela intermediaria da integracao Protheus x TOTVS Educacional
esta apto para uso de acordo com a sua versao minima exigida na tabela INT_VERSION e a 
versao instalada do CorporeRM, alem do pais disponibilizado para utilizacao. 

Obs. Se a funcao for utilizada dentro do update U_UPDF011, entao faz a utilizacao de um 
"cache" para evitar problemas de performance (varias consultas consecutivas no BD da RM)
	   	
@author  Cesar A. Bianchi
@param	 cField - Nome do campo pesquisado
@version P10
@since 	 31/01/2011
@return  lRet - .T. para campo apto para uso, .F. para campo nao apto para uso.
/*/
//-------------------------------------------------------------------------------------
Function ClsVersion(cField)
Local lRet 	:= .F.
Local aArea := GetArea()
Local cVerRm:= ""
Local cVerMin:=""
Local cQuery:= ""
Local nAmbTop:= 0
Local nAmbClassis:= 0
Local cAlias := GetNextAlias()
Local lAmbDev:=	ClsIsDev()
Local lIsUpdF11 := alltrim(upper(FunName())) == "RPC"
Local nPos := 0
Local cPaisOri 	:= ""
Default cField 	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se esta executando via update, entao faz a consulta primeiro buscando no cache³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIsUpdF11 .and. ValType(aVerCache) == "A"
	nPos := aScan(aVerCache,{|x| Alltrim(x[1] ) == cField})
	If nPos > 0
		cVerRm	:= aVerCache[nPos,2]
		cVerMin	:= aVerCache[nPos,3]
		cPaisOri:= aVerCache[nPos,4]
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca as versoes na base da RM (se for cache e nao encontrou entao tambem busca)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPos <= 0 .and. _IntRMTpCon(@nAmbTOP,@nAmbCLASSIS) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem a versao instalada do corporeRM³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !lAmbDev .or. Empty(GetSrvProfString("VerMinRM",""))
		TCSetConn(nAmbCLASSIS)
		cQuery := "SELECT VERSAOMINIMA FROM GSISTEMA WHERE CODSISTCOMERCIAL = 'CN'"
		Iif(Select(cAlias)>0,(cAlias)->(dbCloseArea()),Nil)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
		cVerRM := substr((cAlias)->VERSAOMINIMA,1,5)
		(cAlias)->(dbCloseArea())
		TCSetConn(nAmbTOP)
		TcUnLink(nAmbCLASSIS)
	Else
	    /*Se for ambiente de desenvolvimento, pega a versao presente no ini do server.
	    Este tratamento eh uma alternativa aos programadores que necessitarem realizar debug
	    em um ambiente com versao X sem a necessidade de ter uma base do corpore nesta versao.*/
	    conout("  ")
	    conout("  ")
   	    conout("           ***********************************   ")
   	    conout("           *  WARNING: SISTEMA EM MODO DEBUG *   ")
   	    conout("           *  PARAMETRO 'VER_MIN_RM' LIGADO  *   ")
   	    conout("           *     CONTATE O SUPORTE TOTVS     *   ")
   	    conout("           ***********************************   ")
   	    conout("  ")
	    cVerRM := substr(GetSrvProfString("VerMinRM",""),1,5)
	    TCSetConn(nAmbTOP)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem a versao minima do Campo na INT_VERSION³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cQuery := "SELECT VER_MINIMA, VER_PAIS FROM INT_VERSION "
    cQuery += " WHERE VER_FIELDNAME = '" + cField + "'"
    cQuery += " AND (VER_PAIS = 'ALL' OR VER_PAIS = '" + cPaisLoc + "') "
	Iif(Select(cAlias)>0,(cAlias)->(dbCloseArea()),Nil)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
	cVerMin  := substr((cAlias)->VER_MINIMA,1,5)
	cPaisOri := alltrim(upper((cAlias)->VER_PAIS))
	(cAlias)->(dbCloseArea())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a consulta veio do update, entao grava o item buscado no array de cache³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lIsUpdF11 .and. ValType(aVerCache) == "A"
		aAdd(aVerCache,{cField,cVerRm,cVerMin,cPaisOri})
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a comparacao DA VERSAO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := cVerRM >= cVerMin

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a comparacao DO PAIS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	lRet := iif(cPaisOri=="ALL",.T.,cPaisLoc == cPaisOri)
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsQryDat
Realiza o tratamento de sintaxe entre Oracle e MsSql para as queries que possuam inserts de campo "DateTime" 

@param  dOpc1: Data a ser Convertida.
		lOpc2: Retornar Data + Hora (somente se MsSql)

@author  Cesar A. Bianchi
@version P10
@since 	 30/04/09
@return  cRet - Conteudo da query pronto para o insert (Se MsSql = 'AAAAMMDD', Se Oracle = TO_DATE('AAAAMMDD', 'YYYYMMDD'))
/*/
//-------------------------------------------------------------------------------------

Function ClsQryDat(dData,lTime)
Local cRet 		:= " "
Local lOracle	:= "ORACLE" $ Upper(TCGetDB())
Default dData 	:= CTOD("01/01/1900")
Default lTime	:= .F.

if empty(dtos(dData))
	dData := CTOD("01/01/1900")	
endif

if lOracle
	cRet := " TO_DATE('" + dtos(dData) + "', 'YYYYMMDD') "
else
    cRet :=  dtos(dData) + iif(lTime," " + Time(),"")
    cRet := " '" + cRet + "' "
endif

Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsQryIns
Retorna uma query do tipo "INSERT" de acordo c/ parametros. Solucao alternativa para 
facilitar a manutencao de queryes que possuam um numero muito grande de campos.

@param  aDados - Array com os campos + informacao a ser inserida, ex: {"CAMPO1","'VALOR1'"}
        cAlias - Alias da tabela a ser realizado o INSERT

@author  Cesar A. Bianchi
@version P10
@since 	 14/05/09 
@return  cQuery - Query de insert pronta para ser executada.
/*/
//-------------------------------------------------------------------------------------
Function ClsQryIns(aDados,cAlias)
Local cRet := ""
Local nX   := 0
Default aDados := {}
Default cAlias := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a primeira secao do INSERT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRet := " INSERT INTO " + alltrim(cAlias) + " ( "
For nX := 1 to len(aDados)
	cRet += alltrim(aDados[nX,1]) + iif(nX < len(aDados), "," ,"")
Next nX
cRet += " )"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a secao VALUES³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRet += " VALUES ( "
For nX := 1 to len(aDados)
	cRet += aDados[nX,2] + iif(nX < len(aDados), "," ,"")
Next nX
cRet += " )"

Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ClsIsDev
Retorna TRUE caso o ambiente em execucao seja um ambiente de programacao. 
(Que possui a chave Encrypted definida no appserver.ini)

@protected   	
@author  Cesar A. Bianchi
@version P10
@since 	 02/02/2011
@return  lRet - .T. para ambiente de desenvolvimento, .F. para ambiente de cliente
/*/
//-------------------------------------------------------------------------------------
Function ClsIsDev()
Local lRet := .F.

lRet := GetSrvProfString("Encrypted","") == cSenhaEnc

Return lRet
