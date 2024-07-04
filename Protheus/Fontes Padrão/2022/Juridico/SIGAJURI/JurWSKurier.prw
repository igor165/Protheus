#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

//----------------------------------------------------------------------------//
// WS dos serviços consumuidos pela Kurier
//----------------------------------------------------------------------------//
WsService JurWSKurier Description "Kurier"

	WsData nRecno	As Integer
	WsData nQtdProcesso As Integer
	WsData nQtd As Integer
	
	WsData rProcesso As String

	WsMethod QTDPROCESSO    Description "Quantidade de Processos."
	WsMethod FIRSTPROCESSO  Description "Primeiro Processo."
	WsMethod GETPROCESSO    Description "Retorna processo."
	WsMethod GETPROCESSOQTD Description "Retorna mais de um processo."

EndWsService

//-------------------------------------------------------------------
/*/{Protheus.doc} QTDPROCESSO
Método do web service que retorna a quantidade de processos

@author André Spirigoni Pinto
@since 20/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
WsMethod QTDPROCESSO WsReceive NullParam WsSend nQtdProcesso WsService JurWSKurier
Local lRet  := .T.

::nQtdProcesso := getQtdProcesso()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FIRSTPROCESSO
Método do web service que retorna o primeiro processo que existe na tabela virtual

@author André Spirigoni Pinto
@since 20/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
WsMethod FIRSTPROCESSO WsReceive NullParam WsSend nRecno WsService JurWSKurier
Local lRet  := .T.

::nRecno := getFirstProcesso()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GETPROCESSO
Método do web service que retorna um processo que existe na tabela virtual.
Ele recebe como parâmetro o R_E_C_N_O_ do processo

@author André Spirigoni Pinto
@since 20/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
WsMethod GETPROCESSO WsReceive nRecno WsSend rProcesso WsService JurWSKurier
Local lRet  := .T.

::rProcesso := getProcesso(nRecno,::rProcesso)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GETPROCESSOQTD
Método do web service que retorna um processo que existe na tabela virtual.
Ele recebe como parâmetro o R_E_C_N_O_ do processo

@author André Spirigoni Pinto
@since 20/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
WsMethod GETPROCESSOQTD WsReceive nRecno, nQtd WsSend rProcesso WsService JurWSKurier
Local lRet  := .T.

::rProcesso := getProcesso(nRecno,::rProcesso, nQtd)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getQtdProcesso
Função que cria a tabela temposária e retorna a quantidade de linhas
que ela possui.

@return nQtd Quantidade de processos encontrados na tabela virtual.

@author André Spirigoni Pinto
@since 20/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getQtdProcesso()
Local nQtd := 0
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local aEstrutura := {}
Local cKurier := "KURIER"


BeginSql Alias cAliasQry
	SELECT NSZ.NSZ_FILIAL, NSZ.NSZ_COD, NSZ.NSZ_CCLIEN, NSZ.NSZ_LCLIEN, NUQP.NUQ_NUMPRO AS PROC_ORIG, NUQ.NUQ_NUMPRO, NUQ.NUQ_INSTAN,
	NQC.NQC_DESC, SA1.A1_NOME, RD0.RD0_NOME, NT9I.NT9_NOME PARTEI, NQU.NQU_DESC, NRB.NRB_DESC,
	CC2.CC2_MUN, NUQ.NUQ_ESTADO, NT9C.NT9_NOME PARTEC, NT9A.NT9_NOME PARTEA, NQE.NQE_DESC,
	RD0.RD0_SIGLA, NSZ.R_E_C_N_O_ AS NSZRECNO, NT9I.NT9_TIPOCL AS PCONTCLIEN, NT9C.NT9_TIPOCL AS PATIVCLIEN
	FROM %table:NSZ% NSZ JOIN %table:NUQ% NUQ ON (NSZ.NSZ_COD = NUQ.NUQ_CAJURI AND NUQ.NUQ_INSATU='1' AND NUQ.%notDel% AND NUQ.NUQ_FILIAL = NSZ.NSZ_FILIAL )
	LEFT JOIN %table:NUQ% NUQP ON (NSZ.NSZ_CPRORI = NUQP.NUQ_CAJURI AND NUQP.NUQ_INSATU='1' AND NUQP.%notDel% AND NUQP.NUQ_FILIAL = NSZ.NSZ_FILIAL )
	LEFT JOIN %table:NQC% NQC  ON (NUQ.NUQ_CLOC2N = NQC.NQC_COD AND NUQ.NUQ_CCOMAR = NQC.NQC_CCOMAR AND NQC.%notDel% AND NQC.NQC_FILIAL = %xFilial:NQC%)
	LEFT JOIN %table:SA1% SA1  ON (NSZ.NSZ_CCLIEN = SA1.A1_COD AND NSZ.NSZ_LCLIEN = SA1.A1_LOJA AND SA1.%notDel% AND SA1.A1_FILIAL = %xFilial:SA1%)
	LEFT JOIN %table:RD0% RD0  ON (NSZ.NSZ_CPART1 = RD0.RD0_CODIGO AND RD0.%notDel% AND RD0.RD0_FILIAL = %xFilial:RD0%)
	LEFT JOIN %table:NT9% NT9I ON (NSZ.NSZ_COD = NT9I.NT9_CAJURI AND NT9I.NT9_TIPOCL='1' AND NT9I.NT9_PRINCI='1' AND NT9I.%notDel% AND NT9I.NT9_FILIAL = NSZ.NSZ_FILIAL)
	LEFT JOIN %table:NQU% NQU  ON (NUQ.NUQ_CTIPAC = NQU.NQU_COD AND NQU.%notDel% AND NQU.NQU_FILIAL = %xFilial:NQU%)
	LEFT JOIN %table:NRB% NRB  ON (NSZ.NSZ_CAREAJ = NRB.NRB_COD AND NRB.%notDel% AND NRB.NRB_FILIAL = %xFilial:NRB%)
	LEFT JOIN %table:CC2% CC2  ON (NSZ.NSZ_CMUNIC = CC2.CC2_CODMUN AND NSZ.NSZ_ESTADO = CC2.CC2_EST AND CC2.%notDel% AND CC2.CC2_FILIAL = %xFilial:CC2%)
	LEFT JOIN %table:NT9% NT9C ON (NSZ.NSZ_COD = NT9C.NT9_CAJURI AND NT9C.NT9_TIPOCL='2' AND NT9C.NT9_PRINCI='1' AND NT9C.NT9_CTPENV in ('01','02') AND NT9C.%notDel% AND NT9C.NT9_FILIAL = NSZ.NSZ_FILIAL)
	LEFT JOIN %table:NT9% NT9A ON (NSZ.NSZ_COD = NT9A.NT9_CAJURI AND NT9C.NT9_TIPOCL='1' AND NT9A.NT9_PRINCI='1' AND NT9A.NT9_CTPENV in ('01','02') AND NT9A.%notDel% AND NT9A.NT9_FILIAL = NSZ.NSZ_FILIAL)
	LEFT JOIN %table:NQE% NQE  ON (NUQ.NUQ_CLOC3N = NQE.NQE_COD AND NUQ.NUQ_CLOC2N = NQE.NQE_CLOC2N AND NQE.%notDel% AND NQE.NQE_FILIAL = %xFilial:NQE%)
	WHERE NSZ.%notDel%
EndSql

dbSelectArea(cAliasQry)
(cAliasQry)->(DbgoTop())

aEstrutura := (cAliasQry)->(dbStruct())

DBSqlExec(cKurier, 'DROP TABLE KURIER', 'SQLITE_SYS') //apaga a tabela para ter certeza que não exista

// Cria uma tabela chamada KURIER no SQLITE (usa a mesma estrutura da query)
DBCreate( cKurier, aEstrutura, 'SQLITE_SYS' )
 
// Coloca a tabela KURIER em uso
DBUseArea( .T., 'SQLITE_SYS', cKurier, cKurier, .F., .F. )
 
if &('DbTblCopy("' + cAliasQry + '","' + cKurier + '")') //execução via macro para evitar compilação como fonte de rpo
   nQtd := (cKurier)->( RECCOUNT())
endif
	
(cAliasQry)->(dbCloseArea())
(cKurier)->(dbCloseArea()) //não fecha a área

RestArea(aArea)

Return nQtd

//-------------------------------------------------------------------
/*/{Protheus.doc} getFirstProcesso
Função que retorna o R_E_C_N_O_ do primeiro processo da tabela virtual.

@author André Spirigoni Pinto
@since 20/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getFirstProcesso()
Local nRet  := 1
Local aArea := GetArea()
Local cKurier := "KURIER"

DBUseArea( .T., 'SQLITE_SYS', cKurier, cKurier, .F., .F. )

KURIER->(dbGoto(1))

If !KURIER->( EOF() )
	nRet := KURIER->(Recno())
Endif

KURIER->(dbCloseArea())

RestArea(aArea)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getProcesso(nRecno, rProcesso)
Função que retorna o processo completo a partir de um determinado R_E_C_N_O_

@param nRecno R_E_C_N_O_ do processo desejado
@param rProcesso Estrutura WSStruct que será preenchida com os campos do processo

@author André Spirigoni Pinto
@since 20/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getProcesso(nRecno, rProcesso)
Local lRet  := .T.
Local aArea := GetArea()
Local cKurier := "KURIER"
Local cQuery := ""

Default nQtd := 1

//define a consulta a base SQLLITE e faz a consulta usando intervalo de números
cQuery := 'SELECT * FROM KURIER WHERE R_E_C_N_O_ BETWEEN ' + AllTrim(str(nRecno)) + " AND " + AllTrim(str(nRecno+nQtd-1)) 

//limpa a variável String de retorno
rProcesso := ""

If DBSqlExec(cKurier, cQuery, 'SQLITE_SYS')
	While !KURIER->( EOF() )
		rProcesso += '<PROCESSO>' + CRLF
		rPRocesso += '<filial_processo>'+KURIER->NSZ_FILIAL+'</filial_processo>' + CRLF    
		rPRocesso += '<codInterno>'+KURIER->NSZ_COD+'</codInterno>' + CRLF
		rPRocesso += '<cod_Cliente>'+KURIER->NSZ_CCLIEN+'</cod_Cliente>' + CRLF
		rPRocesso += '<procOrigem>'+KURIER->PROC_ORIG+'</procOrigem>' + CRLF   
		rPRocesso += '<numProcesso>'+KURIER->NUQ_NUMPRO+'</numProcesso>' + CRLF     
		rPRocesso += '<instancia>'+KURIER->NUQ_INSTAN+'</instancia>'  + CRLF   
		rPRocesso += '<foro>'+KURIER->NQC_DESC+'</foro>' + CRLF   
		rPRocesso += '<descCliente>'+KURIER->A1_NOME+'</descCliente>' + CRLF    
		rPRocesso += '<advogado>'+KURIER->RD0_NOME+'</advogado>' + CRLF
		rPRocesso += '<advgParte></advgParte>' + CRLF
		rPRocesso += '<parteInt>'+KURIER->PARTEI+'</parteInt>' + CRLF    
		rPRocesso += '<tipoAcao>'+KURIER->NQU_DESC+'</tipoAcao>' + CRLF   
		rPRocesso += '<area>'+KURIER->NRB_DESC+'</area>' + CRLF        
		rPRocesso += '<cidade>'+KURIER->CC2_MUN+'</cidade>' + CRLF   
		rPRocesso += '<estado>'+KURIER->NUQ_ESTADO+'</estado>' + CRLF
		rPRocesso += '<row_id>'+AllTrim(STR(KURIER->NSZRECNO))+'</row_id>' + CRLF
		rPRocesso += '<parteContraria>'+KURIER->PARTEC+'</parteContraria>' + CRLF    
		rPRocesso += '<poloAtivo>'+KURIER->PARTEA+'</poloAtivo>' + CRLF
		rPRocesso += '<numProcessoAntigo></numProcessoAntigo>' + CRLF
		rPRocesso += '<vara>'+KURIER->NQE_DESC+'</vara>' + CRLF
		rPRocesso += '<partesPoloAtivo></partesPoloAtivo>' + CRLF    
		rPRocesso += '<partesPoloPassivo></partesPoloPassivo>' + CRLF
		rPRocesso += '<advgSigla>'+KURIER->RD0_SIGLA+'</advgSigla>' + CRLF           
		rPRocesso += '<parteContrariaCliente>'+ IIF(KURIER->PCONTCLIEN == '1','S','N')+ '</parteContrariaCliente> ' + CRLF
		rPRocesso += '<poloAtivoCliente>'+ IIF(KURIER->PATIVCLIEN == '1','S','N')+ '</poloAtivoCliente> ' + CRLF
		rPRocesso += '<parteIntCliente></parteIntCliente> ' + CRLF   
		rProcesso += '</PROCESSO>' + CRLF
		KURIER->( dbSkip() )
	End
Endif	

KURIER->(dbCloseArea())

RestArea(aArea)

Return rProcesso

//-------------------------------------------------------------------
/*/{Protheus.doc} Deactivate()
Função que apaga a tabela temporária criada no banco de dados.

@author André Spirigoni Pinto
@since 20/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static function deactivate()
Local cKurier := "KURIER"
DBSqlExec(cKurier, 'DROP TABLE KURIER', 'SQLITE_SYS')
Return Nil