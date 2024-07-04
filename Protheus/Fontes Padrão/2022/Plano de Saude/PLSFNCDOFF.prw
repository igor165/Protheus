#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'MSOBJECT.CH'
#INCLUDE "FWMVCDEF.CH"
#include "TOPCONN.CH"  
#include "TBICONN.CH"
#INCLUDE "fileio.ch"
#INCLUDE "PLSMGER.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PLSFNCDOFF.CH"

/*/{Protheus.doc} PLSSALLIB
Atualiza os status da BD5, BD6 e BD7 para cancelado quando chamada a fun��o do Portal, do m�dulo de Digita��o de Guias Off-Line

@author Roberto Arruda
@since 01/06/2016
@version P12
/*/
function PLSSALLIB(cIdenBD5, cNumLib)
local nQtdPro := 0
local cSequen := 0 
local nQtdTotalLib := 0
//Posiciona na guia de Libera��o/Solicita��o
BEA->( DbGoTop() )
BEA->( DbSetOrder(1) )//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO

If !BEA->( MsSeek( xFilial("BEA") + STrTran(StrTran(cNumLib, ".", ""), "-", "") ) )
	return
EndIf

//Atualiza stalib
PLSATUCS("1")

BD6->(DbSetOrder(1))
If BD6->( MsSeek(xFilial("BD6") + cIdenBD5))//BD5->(BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_ORIMOV)) )
	
	While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD5") + cIdenBD5
		//Quantidade do procedimento na execucao
		nQtdPro := BD6->BD6_QTDPRO
		cSequen := BD6->BD6_SEQUEN
		
		BE2->(DbSetOrder(6))
		cChvBE2Aux := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) + BD6->BD6_CODPAD + BD6->BD6_CODPRO
		
		Begin transaction
		
			If BE2->(MsSeek( xFilial("BE2") + cChvBE2Aux))
			
				While ! BE2->(Eof()) .And. xFilial("BE2") + BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) + BD6->BD6_CODPAD + BD6->BD6_CODPRO == xFilial("BE2") + cChvBE2Aux
					nQtdTotalLib += BE2->BE2_QTDSOL
					
					BE2->( RecLock("BE2",.F.) )
					BE2->BE2_QTDPRO := BE2->BE2_QTDSOL
					BE2->( MsUnLock() )
					
					BE2->(DbSkip())
				enddo
				
				if nQtdPro > nQtdTotalLib
					nQtdPro := nQtdTotalLib
				endif
				
			endif
			
			PLSATUSS(nil,.F.,nil,nil,"1",.F.,cNumLib + cSequen,1,nil,nil,nil,nQtdPro, BD6->BD6_CODPAD, BD6->BD6_CODPRO,BD6->BD6_DENREG,BD6->BD6_FADENT,"OffLine")
			
		end transaction
		
		BD6->(DbSkip())
	Enddo
	
Endif    

return

/*/{Protheus.doc} PLSCNCGCOB
Atualiza os status da BD5, BD6 e BD7 para cancelado quando chamada a fun��o do Portal, do m�dulo de Digita��o de Guias Off-Line
@author Renan Martins
@since 01/06/2016
@version P12
/*/
function PLSCNCGCOB(cRecno, cSituac, cMotBloq, cTipo)
Local cAlias		:= ""
LOCAL cChaveBDH := ""
LOCAL cRet		:= ""
Local nRecno		:= 0

Default cSituac	:= "2"
Default cMotBloq	:= ""
Default cTipo		:= ""

//Defini��o de Chaves de procura conforme Alias - BE4 ou BD5. Se cTipo for 3 - Interna��o ou 5 - Resumo de Interna��o, fica BE4
cAlias 	:= Iif ( ( Empty(cTipo) .Or. !cTipo $ ("3,5") ), "BD5", "BE4" )

//Posiciono na BD5, conforme RECNO recebido
//Tratamento para converter letra em n�mero e se n�mero, manter, pois VAL d� erro se n�merico
nRecno := IIF ( Valtype(cRecno) == "C", Val(cRecno), IIF(Valtype(cRecno) == "N", cRecno, "") )

Iif ( cAlias == "BD5", BD5->(DbGoTo(nRecno)), BE4->(DbGoTo(nRecno)) )

//Valida��o de local de digita��o e fase da guia para cancelamento.
//Regras: Caso guia esteja faturada (fase 4) ou codldp = 9999 ou 0003, nao permite o cancelamento

if ( &(cAlias+"->"+cAlias+"_FASE") = '4' )
	return STR0001 //"Guias faturadas n�o podem ser canceladas."
elseif !( &(cAlias+"->"+cAlias+"_CODLDP") $ (PLSRETLDP(9)+PLSRETLDP(4)) )
	return STR0002 //"Esta guia n�o pode ser cancelada, pois foi originada pelo atendimento. Consulte a operadora."
endif

if ( cAlias == "BD5" .And. !empty(alltrim(BD5->BD5_NRLBOR)) )
	PLSSALLIB(BD5->(BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_ORIMOV), BD5->BD5_NRLBOR)
endif

//Verifico se tem cobran�a aberta por seguran�a
IF ( !PLSVERCCBG( &(cAlias+"->"+cAlias+"_OPEUSR")+&(cAlias+"->"+cAlias+"_CODEMP")+&(cAlias+"->"+cAlias+"_MATRIC")+;
                  &(cAlias+"->"+cAlias+"_TIPREG"),&(cAlias+"->"+cAlias+"_ANOPAG"),&(cAlias+"->"+cAlias+"_MESPAG"),&(cAlias+"->"+cAlias+"_SEQPF")) ) 
	
	cChaveBDH := &(cAlias+"->"+cAlias+"_OPEUSR")+&(cAlias+"->"+cAlias+"_CODEMP")+&(cAlias+"->"+cAlias+"_MATRIC")+&(cAlias+"->"+cAlias+"_TIPREG")+;
	             &(cAlias+"->"+cAlias+"_ANOPAG")+&(cAlias+"->"+cAlias+"_MESPAG")+&(cAlias+"->"+cAlias+"_SEQPF")
	             
	BDH->(DbSetOrder(3))
	If BDH->(DbSeek(xFilial("BDH")+cChaveBDH))  
        PLSM180Del() //Se esta consolidado exclui todos as ligacoes de eventos relativos a esta consolidacao
        BDH->(RecLock("BDH",.F.)) //Exclui a consolidacao referente a guia atual e a outras que estajam ligadas
        BDH->(DbDelete())
        BDH->(MsUnLock())
    Endif   
    
    //Atualiza��o das tabelas, com refer�ncia ao status de cancelamento
    //Primeiro, Atualizo a BD5
	&(cAlias)->(RecLock(cAlias,.F.))                             
		&(cAlias+"->"+cAlias+"_SITUAC") := cSituac //Cancelado por Default
		&(cAlias+"->"+cAlias+"_MOTBLO") := cMotBloq		
    &(cAlias)->(MsUnLock())

    //Segundo, atualizo a BD6 e seus itens relativos
    BD6->(DbSetOrder(1))
    If BD6->( MsSeek(xFilial("BD6") + &(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV")) )
    	
    	While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == ;
                              xFilial(cAlias)+&(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV")
                             
        	BD6->(RecLock("BD6",.F.))
        		BD6->BD6_SITUAC := cSituac //Cancelado por Default
            BD6->(MsUnLock())          
                      
            BD6->(DbSkip())
    	Enddo
    	
    Endif         

    //Terceiro, atualizo a BD7 e suas participa��e
    BD7->(DbSetOrder(1))
    If BD7->( MsSeek(xFilial("BD7") + &(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV")) )
    	
    	While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV) == ;
                             xFilial(cAlias)+&(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV")
        	BD7->(RecLock("BD7",.F.))
        		BD7->BD7_SITUAC := cSituac //Cancelado por Default
            BD7->(MsUnLock())    
            BD7->(DbSkip())
    	Enddo
    	
    Endif         
            
else
	cRet := STR0003 //"Guia j� cobrada e n�o pode ser cancelada"
endIf

Return (cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVRPEGOF

Verifica se existe PEG aberta ou necessita de inclus�o.

@author Renan Martins
@since 02/06/2016
@version P12
@obs Por conven��o, quando se tratar de Guia Off-line, a PEG gerada ou editada sempre estar� na Fase de Em Digita��o, pois se trata
de PEG tempor�ria, at� que o prestador resolva gerar PEG pelo Portal, onde a Guia � transferida para outra PEG, conforme processo padr�o.
Par�metros:
cOrigem: Via Portal ou Remote / cTipoInc: Inclus�o eletr�nica ou manual / cNomeArq: nome do arquivo, caso venha por XML
cDatAte: data do atendimento, pois se n�o informar, caso seja inclus�o de PEG, o sistema considera a data atual e desconsidera cAno e cMes
cDatRecP: data de recebimento da PEG / nQtdGuia: quantidade de guias a serem inseridas na PEG / nQtdItens: quantidade de procedimentos das guias inseridas
nVlrTot: valor total da guia / lDigoff: Se � inser��o pelo Digita��o Off-Line
/*/
//-------------------------------------------------------------------
function PLSVRPEGOF(cOpeMov, cOpeRDA, cCodRDA, cAno, cMes, cTipGuia, cSituac, cLotGui, cFase, cCodLdp, cOrigem,;
 					cTipoInc, cNomeArq, dDatAte, dDatRecP, nQtdGuia, nQtdItens, nVlrTot, lDigOff)
LOCAL aBCI			:= {}

LOCAL cChaveBCI		:= ""
LOCAL cCodLDD		:= ""
LOCAL cOriMov		:= ""
Local cArq 		:= ""
Local cDgOffL		:= ""
Local dDtaPeg

DEFAULT lDigOff 	:= .T. //Se vazio, ir� tratar como guia de Digita��o off-Line
DEFAULT cNomeArq		:= "" 
DEFAULT cOpeMov		:= ""
DEFAULT cOpeRDA		:= ""
DEFAULT cCodRDA		:= ""
DEFAULT cAno		:= ""
DEFAULT cMes		:= ""
DEFAULT cTipGuia 	:= ""
DEFAULT cSituac		:= IIF (lDigOff, "1", cSituac) 	//1=Ativa
DEFAULT cLotGui		:= IIF (lDigOff, "" , cLotGui)	
DEFAULT cFase		:= IIF (lDigOff, "1", cFase) 	// Padr�o "Em Digita��o". Quando Off-Line, a PEG � apenas tempor�ria, at� gera��o do Protocolo de PEG.
DEFAULT cCodLDp		:= ""
DEFAULT cOrigem		:= IIF (lDigOff, "1", cOrigem) 	// 1- Via Portal 
DEFAULT cTipoInc 	:= IIF (lDigOff, "2", cTipoInc) //1-Pelo Remote / 2-Por via eletr�nica

DEFAULT dDatRecP	:= IIF (!Empty(dDatRecP), dDatRecP, dDatabase)

DEFAULT nQtdGuia	:= 1	//Quantidade de Guias que est�o sendo inseridas na PEG.
DEFAULT nQtdItens	:= 0 	//Itens presentes nas guias (procedimentos)
DEFAULT nVlrTot		:= 0	//Valor total dos procedimentos da guia

cDgOffL	:= IIF (lDigOff, "1", "0") //1 - Se inclus�o de PEG pelo Digita��o, preciso gravar no campo BCI_DIGOFF
cCodLDD := IIF (lDigOff, PLSRETLDP(4), IIF (!Empty(cCodLdp), cCodLdp, PLSRETLDP(5)) )
cArq	:= IIF (!Empty(cNomeArq), cNomeArq, "") //Se vier por XML, necessita de nome do arquivo
dDtaPeg	:= IIF (!Empty(dDatAte), dDatAte, nil)

//Localizo a guia na BCL, para recuperar o tipo de Movimento
BCL->( DbSetOrder(1) )
BCL->( MsSeek( xFilial("BCL") + cOpeMov + cTipGuia ) )
cOriMov := BCL->BCL_CDORIT // 1=Guias de Consultas/Servicos;2=Guia de Internacao;3=Outros;4=Autorizacao Odontologica. Grava na BD5, BD6 e BD7->_ORIMOV

//Monto a chave para pesquisa na BCI
cChaveBCI := cOpeRDA + cCodRDA + cAno + cMes + cTipoInc + cFase + cSituac + cTipGuia + (cCodLDD + Space( TamSX3("BCI_CODLDP")[1]-Len( AllTrim(cCodLDD))))

BCI->(dbSetOrder(4)) //BCI_FILIAL, BCI_OPERDA, BCI_CODRDA, BCI_ANO, BCI_MES, BCI_TIPO, BCI_FASE, BCI_SITUAC, BCI_TIPGUI, BCI_CODLDP
If !BCI->( MsSeek(xFilial("BCI")+upper(cChaveBCI)) ) .and. !BCI->( MsSeek(xFilial("BCI")+lower(cChaveBCI)) )
	//Se n�o encontrar, insiro nova PEG
	PLSIPP(cOpeMov, cCodLDD, cOpeRDA, cCodRDA, cMes, cAno , dDatRecP, cTipGuia, cLotGui, nil, cFase, cArq, nQtdItens, nQtdGuia, nVlrTot, cOrigem, cSituac, dDtaPeg, cDgOffL)
Else 
	//Atualizo a PEG localizada
	PLSATUPP( nQtdItens, nVlrTot, nQtdGuia, .F., BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG )
EndIf

//Retornar os dados da BCI para grava��o
//Array: 1� C�digo da PEG, 2� C�digo Local de Digita��o, 3� Origem Movimento, 4� Situa��o, 5� Fase, 6� M�s, 7� Ano, 8� RECNO BCI
aBCI := { BCI->BCI_CODPEG, BCI->BCI_CODLDP, cOriMov, cSituac, cFase, cMes, cAno, BCI->(recno()) }

Return (aBCI)

/*/{Protheus.doc} PLSMFMTOF
Muda Fase da guia quando o prestador seleciona a op��o que deseja finalizar a edi��o da guia no Portal
@author Renan Martins
@since 03/06/2016
@version P12
@obs A rotina ir� receber os par�metros de Alias (que no digita��o Off-Line ser� BD5) / RECNO do registro na BD5 (opcional) ou
a Chave (BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO), para encontrar o registro / RECNO BCI pois o sistema necessita
cMulti se deseja que a mudan�a seja feita em Multithread ou n�o: "S"-Usar Multithread / "N"-N�o usar MultiThread / "C"-Conforme cadastro BSO
cCodRDA: Se cMulti for S, cCodRDA � opcional.
/*/
Function PLSMFMTOF(cAlias, nReg, cChave, nRecBCI, cMulti, cCodRda)
local cRpcServer	:= getNewPar("MV_PLSSRV", "")  				//Server de conex�o
local cRPCEnv 		:= getNewPar("MV_PLSENV", getEnvServer())	//Environment
local nRPCPort 		:= getNewPar("MV_PLSPRT", 0)				//Porta de Conex�o
local cBKPFase		:= ""
local lMulCad		:= .f.
local oServer		:= nil
local aDadosMF		:= {}
local aRETMF		:= {}

default cChave 		:= "" 
default nReg		:= 0
default cAlias		:= "BD5"
default cMulti		:= "C"
default cCodRDA		:= "XX"

//Verifico se nReg e cChave est�o vazios. Se ambos est�o vazios, n�o � poss�vel localizar o registro, pois n�o estamos posicionados e saio da Fun��o.
if ( empty(cChave) .and. nReg == 0 ) .or. empty(nRecBCI)
	return(aRETMF)
endIf

//Array para passar par�metros: 1� POSI��O: cAlias / 2� POSI��O: n�mero do registro (BD5) / 3� POSI��O: numero da guia 
aDadosMF := { cAlias, nReg, cChave, nRecBCI, cEmpAnt, cFilAnt }

//Verificar cadastro da RDA para Multithread Mudan�a de Fase
if cMulti == "C"

	BAU->( DbSetOrder(1))
	if BAU->( msSeek( xFilial("BAU") + cCodRDA) )  
		lMulCad	:= iIf(BAU->BAU_MULTTH == "1", .t., .f.)
	else
		lMulCad	:= .f.
	endIf
		
endIf

//Verifico se o multitherads est� ativo ou n�o, conforme configura��o
if cMulti == "N" .or. ( cMulti == "C" .and. ! lMulCad )
 
	aRETMF := PLSMFDGOFF(aDadosMF, .f.)
	
	return(aRETMF)
	
endIf

//Pego por seguran�a o c�digo da Fase da BD5, j� qie iremos mascarar isso enquanto a MF por Job � executada, para n�o exibir no grid do Digita��o
cBKPFase := (cAlias)->&( cAlias + "_FASE" ) 

(cAlias)->( recLock(cAlias, .f.) )
	(cAlias)->&(cAlias + "_FASE") := "5"
(cAlias)->( msUnlock() )

// Vai chamar a fun��o inicial de posicionamento e depois a PLSA500FAS
if empty(cRpcServer)

	startJob("PLSMFDGOFF", getEnvServer(), .f., aDadosMF, .t., cBKPFase)
	
else
	
	oServer := TRPC():new( cRPCEnv )
	
	if oServer:Connect( cRpcServer, nRPCPort )
		oServer:startJob("PLSMFDGOFF", .f., aDadosMF, .t., cBKPFase)
		oServer:disconnect()
	endIf
	
endIf

return(aRETMF)

/*/{Protheus.doc} PLSMFDGOFF

Permite a mudan�a de fase em startjob (Multi Threads), para as guias off-line. Passa os par�metros necess�rios para o posicionamento. 

@author Renan Martins
@since 03/06/2016
@version P12
@obs A rotina ir� utilizar Multi Threads, pois algumas guias podem conter in�meros procedimentos
cAlias: Alias da pesquisa (BD5) / nReg: RECNO do alias / cChave: Chave de Pesquisa , caso n�o tenha o RECNO do Registro
O retorno aRetM ir� armazenar as informa��es da seguinte forma: 1� POSI��O: Mensagem de retorno (Sucesso ou Falha)
/*/
Function PLSMFDGOFF(aDadosMF, lMulti, cBKPFase) 
local cAlias	:= aDadosMF[1]
local cCodOpe	:= ""
local cFase   	:= ""
local cMsg		:= ""
local cSituac 	:= ""
local cTipGui	:= ""
local dDatPro 	:= nil
local lRet		:= .t.
local aRetM		:= {}
local aCriticas	:= {}

if lMulti
	rpcSetType(3)
	rpcSetEnv(aDadosMF[5], aDadosMF[6],,,'PLS',, )
endIf

//Verifico se a BCI est� posicionada no registro informado pelo Recno BCI. Se n�o estiver reposiciono.
if ( BCI->(recno()) <> aDadosMF[4] )
	BCI->( dbGoTo(aDadosMF[4]) ) 
endIf

//Verifico se foi passado o nReg das BD5 - POSI��O 2
if ( ! empty(aDadosMF[2]) )
	
	(cAlias)->( dbGoTo(aDadosMF[2]) )
	
else
	
	(cAlias)->( dbSetOrder(1)) //BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_SITUAC + BD5_FASE + dtos(BD5_DATPRO) + BD5_OPERDA + BD5_CODRDA
	
	if !(cAlias)->( msSeek( xFilial(cAlias) + aDadosMF[3]) )
	
		lRet := .f.
		cMsg := STR0004 //"Ocorreu algum erro e n�o foi poss�vel efetuar a Mudan�a de Fase da Guia"
		
	endIf	
endIf

//Com registro posicionado pelo RECNO ou chave de pesquisa, pego a Fase, situa��o, data do procedimento, C�digo Operadora e Tipo de Guia.
if lRet

	cFase   := Iif(lMulti, cBKPFase, (cAlias)->&( cAlias + "_FASE" ) )
	cSituac := (cAlias)->&( cAlias + "_SITUAC" )
	cCodOpe	:= (cAlias)->&( cAlias + "_CODOPE" )
	cTipGui	:= (cAlias)->&( cAlias + "_TIPGUI" )
	dDatPro := (cAlias)->&( cAlias + "_DATPRO" )
	
	//Verifico se tem cobran�a aberta por seguran�a
	If PLSVERCCBG((cAlias)->&( cAlias + "_OPEUSR" ) + (cAlias)->&( cAlias + "_CODEMP" ) + (cAlias)->&( cAlias + "_MATRIC" )+;
	              (cAlias)->&( cAlias + "_TIPREG" ), (cAlias)->&( cAlias + "_ANOPAG" ), (cAlias)->&( cAlias + "_MESPAG" ),;
	              (cAlias)->&( cAlias + "_SEQPF" ) )
		
		lRet := .f.
		cMsg := STR0003 //"Guia j� cobrada e n�o pode ser cancelada"
		     
	endIf              
	
	if lRet
	
		//Verificamos se o registro posicionado pode ter sua fase mudada, se possui data de procedimento e caso Resumo de interna��o, se tem Data de Alta                 
		if ! ( (cFase $ "1") .And. (cSituac == "1") )
		
			lRet := .f.
			cMsg := STR0005 //"Guia n�o pode ter sua fase alterada! " 
		
		elseIf ( empty(dDatPro) )
			
			lRet := .f.
			cMsg := STR0006 //"Guia n�o pode ter sua fase alterada, pois est� sem a data do procedimento!"
			
		endIf
		
		if lRet	
			
			// Execu��o da Mudan�a de Fase. Segundo par�metro indica se trata de Mudan�a de fase apenas de guia "1" ou se � da PEG toda - "2". Como � guia, 
			// passamos o identificador "1". A fun��o est� no fonte PLSMCTMD                       
			aRet := PLSXMUDFAS(	cAlias, '1', cCodOpe, cTipGUi, dDatPro, .f., /*cNextFase*/, /*nVlrPAG*/, /*nVlrGlo*/, .f., /*aItensGlo*/,;
				    			/*aFiltro*/, /*lReanaliza*/, .f., /*oBrwIte*/, /*lProcRev*/, /*nIndRecBD6*/, /*nTotEventos*/, /*aThreads*/, /*nCont*/, /*cUserName*/,;
				    			/*lSolicit*/, /*aPLS475*/, /*lPagAto*/, /*cChaveLib*/, /*lNegProPac*/, /*lGetCri*/, .f., /*lRecGlo*/, /*aSequen*/, /*isPLSA502*/)
								   					   
			//Verifico se realmente houve a mudan�a de fase e se o campo da BD5_FAse est� preenchido. Se n�o, passo novamente o valor do Fase_Backup
			If ( (cAlias)->&( cAlias + "_FASE" ) == "5" .or. empty( (cAlias)->&( cAlias + "_FASE" ) ) )
			
				&(cAlias)->( recLock(cAlias, .f.) )
					(cAlias)->&(cAlias + "_FASE") := cBKPFase
				&(cAlias)->( msUnlock() )		
			
			endIf	
			
			lRet := aRet[1]
			 				   					   
			if lRet 
				cMsg := STR0007 //"Sucesso, Guia Finalizada!" //"Mudanca de Fase concluida com sucesso !!!"
			else	
				cMsg := STR0008 //"Ocorreram algumas cr�ticas com a guia:"
			endIf

			aCriticas := aRet[2] 			
			
		endIf	
		
	endIf	
	
endIf

aadd(aRetM, lRet)
aadd(aRetM, cMsg)
aadd(aRetM, aCriticas)

return(aRetM)

/*/{Protheus.doc} PLSPGDRECN

Permite a mudan�a de fase em startjob (Multi Threads), para as guias off-line. Passa os par�metros necess�rios para o posicionamento. 

@author Renan Martins
@since 03/06/2016
@version P12
@obs Recebo o array com os dados que s�o permitidos para altera��o
1� n�mero da guia / 2� Tipo de atendimento / 3� Indica��o de Acidente / 4� Tipo de Consulta
5� Tipo de Sa�da / 6� Valor Consulta
/*/
function PLSPGDRECN(aDados, aItens)
LOCAL cCodPeg	:= ""
LOCAL cNumero	:= ""
LOCAL cCodLdp	:= ""
LOCAL cCodOpe	:= ""
LOCAL cChave	:= ""
LOCAL lRet		:= .F.
LOCAL nOBS1		:= (TamSX3("BEA_MSG01")[1])

LOCAL nI		:= 0
LOCAl nRecBD5	:= 0
LOCAL nRecBCI	:= 0

BEGIN TRANSACTION
	//Posiciono nos �ndices
	BEA->( DbSetOrder(1) )
	BD5->( DbSetOrder(1) )
	BD6->( DbSetOrder(1) )
	BCI->( DbSetOrder(1) )
	
	//verifico se existe a chave na BEA
	IF ( BEA->( MsSeek(xFilial("BEA")+aDados[1]) ) ) 
		cCodPeg	:= BEA->BEA_CODPEG
		cNumero	:= BEA->BEA_NUMGUI
		cCodLdp	:= BEA->BEA_CODLDP
		cCodOpe := BEA->BEA_OPEMOV	
		
		//Atualizo as tabelas de atendimento
		BEA->(RecLock("BEA",.F.))
		FOR nI := 2 TO LEN (aDados) //Pois a primeira posi��o SEMPRE ser� o n�mero da guia
			aSep := {}
			aSep := Separa(aDados[nI], ':', .F.)
			IF (!Empty(aSep[2]))
				cChave := Alltrim("BEA->BEA_"+aSep[1])

				IF ( !cChave $ ("BEA->BEA_OBSERV, BEA->BEA_CDPFRE") )  //Pois a observa��o grava em v�rios campos, n�o � memo.......................
					cPrep := PrepColTI(aSep[2], cChave)
					&(cChave) := Alltrim(cValtoChar(cPrep))
				ELSEIF (cChave == "BEA->BEA_CDPFRE" .AND. BEA->BEA_CDPFRE <> aSep[2] )
					PLSVRFPEC(aSep[2], "BEA")	
				ELSE	
					BEA->BEA_MSG01 := SubStr(AllTrim(aSep[2]),1, nOBS1)
					BEA->BEA_MSG02 := IIF (Len(aSep[2]) > nOBS1, SubStr(AllTrim(aSep[2]),nOBS1+1,Len( AllTrim(ASep[2]) ) ), "")  
				ENDIF	
			
			ENDIF	                                                                                                                                                                        
		NEXT
		BEA->(msUnLock())
		
		//Atualizo as tabelas de cobran�a
		//BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_SITUAC + BD5_FASE + dtos(BD5_DATPRO) + BD5_OPERDA + BD5_CODRDA
		IF BD5->( MsSeek(xFilial("BD5") + cCodOpe + cCodLdp + cCodPeg + cNumero ) ) 
			nRecBD5 := BD5->(RECNO())
			BD5->(RecLock("BD5",.F.))
			FOR nI := 2 TO LEN (aDados) //Pois a primeira posi��o SEMPRE ser� o n�mero da guia
				aSep := {}
				aSep := Separa(aDados[nI], ':', .F.)
				IF (!Empty(aSep[2]))
					cChave := Alltrim("BD5->BD5_"+aSep[1])
	
					IF ( !cChave $ ("BD5->BD5_OBSERV, BD5->BD5_CDPFRE") )  //Pois a observa��o n�o grava na BD5...............
						cPrep := PrepColTI(aSep[2], cChave)
						&(cChave) := Alltrim(cValtoChar(cPrep))
					ELSEIF (cChave == "BD5->BD5_CDPFRE" .AND. BD5->BD5_CDPFRE <> aSep[2] )
						PLSVRFPEC(aSep[2], "BD5")	
					ENDIF	
				
				ENDIF	                                                                                                                                                                        
			NEXT                                                                                                                                                               
			BD5->(msUnLock())
		ENDIF
		lRet := .T.
	ENDIF
	
	
	//Valor da consulta. Ser� gravado o valor nas tabelas BE2 e BD6 e depois, a Fase ser� retornada e mudada novamente, para que o sistema realize todos os c�lculos
	IF (!Empty(aItens) .AND. nRecBD5 <> 0)
	
		//Vou retornar a Fase da Guia, devido a mudan�a de valor, para que o sistema recalcule os pagamentos
		IF (BCI->(MsSeek(xFilial("BCI")+cCodOpe+cCodLdp+cCodPeg)))
			nRecBCI := BCI->(RECNO())
		ENDIF
		
		//Retorno a Fase da Guia
		IF ( PLSA500RFS("BD5",nRecBD5,6,,.F.,.T.) )	
		
			//Se verdadeiro, conseguir retornar a fase para Digita��o
			IF BE2->( MsSeek(xFilial("BE2")+aDados[1]) )
				BE2->(RecLock("BE2",.F.))
				FOR nI := 1 TO LEN (aItens) 
					aSep := {}
					aSep := Separa(aItens[nI], ':', .F.)
					IF (!Empty(aSep[2])) //Por enquanto, apenas valor 
						cChave := Alltrim("BE2->BE2_"+aSep[1])
						&(cChave) := Val(AllTrim(StrTran(aSep[2],",","")))
					ENDIF	                                                                                                                                                                        
				NEXT
				BE2->(msUnLock())	
			ENDIF
		
			//Atualizo as tabelas de cobran�a BD6
			IF BD6->( MsSeek(xFilial("BD6") + cCodOpe + cCodLdp + cCodPeg + cNumero ) ) 
				nRecBD6 := BD6->(RECNO())
				BD6->(RecLock("BD6",.F.))
				FOR nI := 1 TO LEN (aItens) 
					aSep := {}
					aSep := Separa(aItens[nI], ':', .F.)
					IF (!Empty(aSep[2])) //Por enquanto, apenas valor 
						cChave := Alltrim("BD6->BD6_"+aSep[1])
						&(cChave) := Val(AllTrim(StrTran(aSep[2],",","")))
					endIf	                                                                                                                                                                        
				next                                                                                                                                                               
				BD6->(msUnLock())
			endIf
		else
			lRet := .F.  //Deixo retorno como falso
		endIf
	
		//Vou Mudar de Fase com Thread, utilizando a fun��o do Portal, para revalorizar a guia e proceder com todas as altera��es necess�rias.
		if lRet
			PLSMFMTOF("BD5", nRecBD5, nil, nRecBCI)
		endIf
		
	endIf
	
END TRANSACTION

return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVRFPEC

Procurar executrantes no caso da guia de Consulta. 

@author Renan Martins
@since 03/06/2016
@version P12
@obs 
/*/
//-------------------------------------------------------------------
Function PLSVRFPEC(cCod, cAlias)
LOCAL cCod 	:= Alltrim(cCod)

BB0->( DbSetOrder(1) ) //BB0_FILIAL + BB0_CODIGO
IF ( BB0->( MsSeek(xFilial("BB0")+cCod )) ) 
	IF (cAlias == "BEA")
		BEA->BEA_SIGEXE := BB0->BB0_CODSIG   
		BEA->BEA_REGEXE := BB0->BB0_NUMCR
		BEA->BEA_ESTEXE := BB0->BB0_ESTADO
		BEA->BEA_NOMEXE := BB0->BB0_NOME
	ELSE
		BD5->BD5_SIGEXE := BB0->BB0_CODSIG   
		BD5->BD5_REGEXE := BB0->BB0_NUMCR
		BD5->BD5_ESTEXE := BB0->BB0_ESTADO
	ENDIF	
ENDIF	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PrepColTI

Realizar De/Para nos campos alterados utilizando PLSGETVINC
@author Renan Martins
@since 03/06/2016
@version P12
@obs 
/*/
//-------------------------------------------------------------------
Function PrepColTI(cCod, cChave)
LOCAL cCodRet := ""

//PLSGETVINC (cColuna, cAlias, lMsg, cCodTab , cVlrTiss, lPortal, aTabDup, cPadBkp )
Do Case
	Case cChave $ ("BEA->BEA_INDACI, BD5->BD5_INDACI")
		cCodRet := PLSGETVINC("BTU_CDTERM", "BEA", .F., "36",  cCod,.T.)
	
	Case cChave $ ("BEA->BEA_TIPCON, BD5->BD5_TIPCON")
		cCodRet := PLSGETVINC("BTU_CDTERM", "", .F., "52",  cCod,.T.)
	
	Case cChave $ ("BEA->BEA_TIPSAI, BD5->BD5_TIPSAI")
		cCodRet := PLSGETVINC("BTU_CDTERM", "BEA", .F., "39",  cCod,.T.)
	
	Case cChave $ ("BEA->BEA_TIPATE, BD5->BD5_TIPATE")
		cCodRet := PLSGETVINC("BTU_CDTERM", "", .F., "50",  cCod,.T.)

EndCase
Return( IIF(!Empty(cCodRet), cCodRet, cCod) )


//Retorna Dados dos Profissionais
Function PLSREBD7PRO (cRecno, lResumoInt)
LOCAL aParticip := {}
LOCAL cSQL 		:= ""
LOCAL cCodLdp 	:= ""
LOCAL cCodPEG 	:= ""
LOCAL cNumero 	:= ""
LOCAL cOrimov 	:= ""
LOCAL cCodOpe 	:= ""
LOCAL cRec			:= IIF (Valtype(cRecno) == "N", cRecno, Val(cRecno))
LOCAL cCGC			:= ""
LOCAL lPos			:= .T.

DEFAULT lResumoInt := .F.

BB0->( DbSetOrder(1) ) //BB0_FILIAL + BB0_CODIGO - Para pegar apenas CNPJ/CPF 

IF !lResumoInt
	 BD5->( DbGoto(cRec) )
	 lPos := BD5->(Recno()) == cRec
ELSE
	BE4->( DbGoto(cRec) )
	lPos := BE4->(Recno()) == cRec
ENDIF

IF ( lPos )

	if	!lResumoInt
		cCodLdp 	:= BD5->BD5_CODLDP
		cCodPEG 	:= BD5->BD5_CODPEG
		cNumero 	:= BD5->BD5_NUMERO
		cOrimov 	:= BD5->BD5_ORIMOV
		cCodOpe 	:= BD5->BD5_CODOPE
	else
		cCodLdp 	:= BE4->BE4_CODLDP
		cCodPEG 	:= BE4->BE4_CODPEG
		cNumero 	:= BE4->BE4_NUMERO
		cOrimov 	:= BE4->BE4_ORIMOV
		cCodOpe 	:= BE4->BE4_CODOPE
	endIf
	
	cSql := " SELECT DISTINCT BD7_CODRDA, BD7_REGPRE,BD7_NOMPRE, BD7_CDPFPR, BD7_SIGLA, BD7_ESTPRE, BD7_SEQUEN, BD7_CODTPA, BD7_ESPEXE, BD7_DESESP "
	cSql += iif(BD7->(fieldpos("BD7_CBOEXE"))>0, ", BD7_CBOEXE", ", '' AS BD7_CBOEXE" ) 
	cSql += " FROM " + RetSqlName("BD7") 
	cSql += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_CODOPE = '" + cCodOpe + "'"
	cSql += " AND BD7_CODLDP = '" + cCodLdp + "' AND BD7_CODPEG = '" + cCodPEG + "'"
	cSql += " AND BD7_NUMERO = '" + cNumero + "' AND BD7_ORIMOV = '" + cOrimov + "' AND D_E_L_E_T_ = ' ' "  
	cSql += " ORDER BY BD7_SEQUEN, BD7_CODTPA " 

	cSQL := ChangeQuery(cSQL)
	TCQUERY cSQL NEW Alias "DADOSBD7"

	If !DADOSBD7->(Eof())
	
	    While !DADOSBD7->( Eof() )
	    
	    	cCGC := ''
			If ( BB0->( MsSeek(xFilial("BB0") + DADOSBD7->BD7_CDPFPR)) )
			
				If empty(BB0->BB0_CGC)
				
					BAU->(dbSetOrder(5))
					
					If ( BAU->( MsSeek(xFilial("BAU") + DADOSBD7->BD7_CDPFPR)) )
					
						cCGC := BAU->BAU_CPFCGC
						
					EndIf
					
				Else
				
					cCGC := BB0->BB0_CGC
					
				EndIf
				
			 	if(!empty(DADOSBD7->BD7_NOMPRE))
			 		aAdd (aParticip, {DADOSBD7->BD7_SEQUEN, DADOSBD7->BD7_CODTPA, cCGC, DADOSBD7->BD7_NOMPRE, DADOSBD7->BD7_SIGLA, DADOSBD7->BD7_REGPRE, DADOSBD7->BD7_ESTPRE, DADOSBD7->BD7_ESPEXE, DADOSBD7->BD7_CDPFPR, DADOSBD7->BD7_DESESP, DADOSBD7->BD7_CBOEXE})
				endIf
			
			Else
			
				if(!empty(DADOSBD7->BD7_NOMPRE))
					aAdd (aParticip, {DADOSBD7->BD7_SEQUEN, DADOSBD7->BD7_CODTPA, '000000000', DADOSBD7->BD7_NOMPRE, DADOSBD7->BD7_SIGLA, DADOSBD7->BD7_REGPRE, DADOSBD7->BD7_ESTPRE, DADOSBD7->BD7_ESPEXE, DADOSBD7->BD7_CDPFPR, DADOSBD7->BD7_DESESP,DADOSBD7->BD7_CBOEXE})
				endIf
			
			EndIf
			
			DADOSBD7->( DbSkip() )	
			
		EndDo
		
	EndIf
	
	DADOSBD7->( DbCloseArea() )  	
	
EndIf
       
Return (aParticip)

/*/{Protheus.doc} PLSMDFSGDIG
Realizar De/Para nos campos alterados utilizando PLSGETVINC
@author Renan Martins
@since 03/06/2016
@version P12
@obs 
/*/
function PLSMDFSGDIG(nRecno, cTipGui, cThread)
local aCriticas := {}
local nRecnoBCI := 0
local cAlias	:= ""

default cThread := "C"
default cTipGui	:= ""

cAlias	:= iIf( empty(cTipGui) .or. cTipGui <> "5", "BD5", "BE4" )

if valType(nRecno) == 'C'
	nRecno := val(nRecno)
endIf

if ( nRecno != (cAlias)->(recno()) )
	(cAlias)->(dbGoTo(nRecno))
endIf

cOpeMov	:= (cAlias)->&( cAlias + "_CODOPE" )  
cCodRDA	:= (cAlias)->&( cAlias + "_CODRDA" )
cCodLDP	:= (cAlias)->&( cAlias + "_CODLDP" )
cCodPEG	:= (cAlias)->&( cAlias + "_CODPEG" )

//Monto a chave para pesquisa na BCI
cChaveBCI := cOpeMov + cCodLDP + cCodPeg

BCI->(DbSetOrder(1)) 
if BCI->( msSeek( xFilial("BCI") + cChaveBCI) )
  nRecnoBCI := BCI->(recno())
endIf

aCriticas := PLSMFMTOF(cAlias, nRecno, "", nRecnoBCI, cThread, cCodRda)

return(aCriticas)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSMFCRITP

Monta array com cr�ticas para exibir no portal
@author Renan Martins
@since 03/06/2016
@version P12
@obs 
/*/
//-------------------------------------------------------------------
Function PLSMFCRITP(cChave)
LOCAL aCrit 	:= {}
LOCAL cCodPro	:= ""
LOCAL cCodGlo := ""

BDX->(DbSetOrder(1))
BDX->(MsSeek(xFilial("BDX")+cChave))

While !BDX->(EOF()) .AND. BDX->(BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO + BDX_ORIMOV) == cChave
	IF (!Empty(BDX->BDX_NIVEL) .and. (cCodGlo <> BDX->BDX_CODGLO .or. cCodPro <> BDX->BDX_CODPAD + BDX->BDX_CODPRO))
		aAdd( aCrit, {BDX->BDX_CODPRO + " - " + BDX->BDX_DESPRO, PLSRETCRI (AllTrim(BDX->BDX_CODGLO))} )
		cCodPro := BDX->BDX_CODPAD + BDX->BDX_CODPRO
		cCodGlo := BDX->BDX_CODGLO
	ENDIF
	BDX->(DbSkip())
	
ENDDO

Return aCrit

/*/{Protheus.doc} PLSExbCrOff

Verifica se a RDA pode ou n�o exibir as cr�ticas dos procedimentos ao finalizar a guia no Digita��o Off-line.
Se for Multithread, exibir apenas modal com aviso para checar mais tarde.
@author Renan Martins
@since 04/2017
@version P12
@obs 
/*/
function PLSExbCrOff (nRecno, cAliasCabec)
local cCodRda	:= ""
local lNMultTh	:= .t.

default cAliasCabec := "BD5"

//Verifico se estou posicionado no Recno correto da BD5, para pegar o valor da RDA
if nRecno != (cAliasCabec)->( recno() )
	(cAliasCabec)->( dbGoTo(nRecno) )
endif

cCodRda := &(cAliasCabec+"->"+cAliasCabec+"_CODRDA") 

BAU->( dbSetOrder(1))

if BAU->( msSeek( xFilial("BAU") + cCodRDA) )  
	lNMultTh := iIf(BAU->BAU_MULTTH == "0" .or. empty(BAU->BAU_MULTTH), .t., .f.)  //Se 0, n�o trabalha com MultiThreads
endIf

return(lNMultTh)

/*/{Protheus.doc} PLS063MFNOV

Cr�ticar as guais do off-line, caso tenham iguais no sistema
@since 07/2017
@version P12
@obs 
/*/
Function PLS063MFNOV(cCodPeg, cCodRda, cCodOpe, cCodLdp, cTipGui)
Local cSql 		:= ""
Local cNameBD6	:= retSqlname("BD6")
Local cNameBD7	:= retSqlName("BD7")
Local cAUX		:= getNewPar("MV_PLSCAUX","AUX")
Local cChave	:= ""
Local cAlias	:= Iif(cTipGui == "03", "BE4", "BD5")
Local cCLNotIN	:= "'" + PLSRETLDP(9) + "','" + PLSRETLDP(4) + "'"
Local dDatPro	:= nil
Local lRet		:= .f.
Local nRecno	:= 0
Local aChv		:= {}
Local nRecBCI 	:= 0

cSql := " SELECT BD71.R_E_C_N_O_ REC1, BD71.BD7_CODOPE, BD71.BD7_CODLDP, BD71.BD7_CODPEG, "
cSql += " BD71.BD7_NUMERO, BD71.BD7_ORIMOV, BD71.BD7_CODPAD, BD71.BD7_CODPRO, BD71.BD7_SEQUEN, BD72.R_E_C_N_O_ REC2 "
cSql += " FROM " + cNameBD7 + " BD71 "

cSql += "   INNER JOIN " + cNameBD6 + " BD61 "
cSql += " 		 ON BD61.BD6_FILIAL = BD71.BD7_FILIAL "
cSql += " 		AND BD61.BD6_CODOPE = BD71.BD7_CODOPE "
cSql += " 		AND BD61.BD6_CODLDP = BD71.BD7_CODLDP "
cSql += " 		AND BD61.BD6_CODPEG = BD71.BD7_CODPEG "
cSql += " 		AND BD61.BD6_NUMERO = BD71.BD7_NUMERO "
cSql += " 		AND BD61.BD6_ORIMOV = BD71.BD7_ORIMOV "
cSql += " 		AND BD61.BD6_SEQUEN = BD71.BD7_SEQUEN "
cSql += " 		AND BD61.BD6_CODPAD = BD71.BD7_CODPAD "
cSql += " 		AND BD61.BD6_CODPRO = BD71.BD7_CODPRO "
cSql += " 		AND BD61.D_E_L_E_T_ = ''              "	

cSql += "   INNER JOIN " + cNameBD7 + " BD72 "
cSql += "  	     ON BD72.BD7_FILIAL = '" + xFilial("BD7") + "' "
cSql += " 		AND BD72.BD7_OPEUSR = BD71.BD7_OPEUSR  "
cSql += " 		AND BD72.BD7_CODEMP = BD71.BD7_CODEMP  "
cSql += " 		AND BD72.BD7_MATRIC = BD71.BD7_MATRIC  "
cSql += " 		AND BD72.BD7_TIPREG = BD71.BD7_TIPREG  "
cSql += " 		AND BD72.BD7_CODPAD = BD71.BD7_CODPAD  "
cSql += " 		AND BD72.BD7_CODPRO = BD71.BD7_CODPRO  "
cSql += " 		AND BD72.R_E_C_N_O_ <> BD71.R_E_C_N_O_ "
cSql += " 		AND BD72.BD7_BLOPAG <> '1'             "
cSql += " 		AND BD72.BD7_CODLDP NOT IN (" + cCLNotIN + ") "
cSql += "		AND BD72.BD7_CODESP = BD71.BD7_CODESP   "
cSql += "       AND ( (BD72.BD7_CODUNM = '" + cAUX + "' AND BD72.BD7_CODTPA = BD71.BD7_CODTPA) OR "
cSql += "		      (BD72.BD7_CODUNM = BD71.BD7_CODUNM ) )"	
cSql += "       AND BD72.BD7_NLANC = BD71.BD7_NLANC    "
cSql += "		AND BD72.D_E_L_E_T_ = '' "			

cSql += "   INNER JOIN " + cNameBD6 + " BD62            "
cSql += " 		 ON BD62.BD6_FILIAL = BD72.BD7_FILIAL  "
cSql += " 		AND BD62.BD6_CODOPE = BD72.BD7_CODOPE "
cSql += " 		AND BD62.BD6_CODLDP = BD72.BD7_CODLDP "
cSql += " 		AND BD62.BD6_CODPEG = BD72.BD7_CODPEG "
cSql += " 		AND BD62.BD6_NUMERO = BD72.BD7_NUMERO "
cSql += " 		AND BD62.BD6_ORIMOV = BD72.BD7_ORIMOV "
cSql += " 		AND BD62.BD6_SEQUEN = BD72.BD7_SEQUEN "
cSql += " 		AND BD62.BD6_CODPAD = BD72.BD7_CODPAD "
cSql += " 		AND BD62.BD6_CODPRO = BD72.BD7_CODPRO "
cSql += " 		AND BD62.BD6_FASE IN ('3','4') 		   "
cSql += " 		AND BD62.BD6_SITUAC <> '2'            "	
cSql += " 		AND BD62.D_E_L_E_T_ = ''              "	
 
cSql += " 		AND BD62.BD6_DATPRO = BD61.BD6_DATPRO "
cSql += " 		AND BD62.BD6_HORPRO = BD61.BD6_HORPRO "
cSql += " 		AND BD62.BD6_CODPAD = BD61.BD6_CODPAD "
cSql += " 		AND BD62.BD6_CODPRO = BD61.BD6_CODPRO "
cSql += " 		AND BD62.R_E_C_N_O_ <> BD61.R_E_C_N_O_"
 
cSql += "		AND ( (  BD62.BD6_NUMERO <> BD71.BD7_NUMERO   AND "
cSql += "                BD62.BD6_CODPEG = BD71.BD7_CODPEG )  OR "
cSql += "    			 ( BD62.BD6_NUMERO = BD71.BD7_NUMERO  AND "
cSql += "      			 BD62.BD6_CODPEG <> BD71.BD7_CODPEG ) OR " 
cSql += "    			 ( BD62.BD6_NUMERO <> BD71.BD7_NUMERO AND " 
cSql += "	  			 BD62.BD6_CODPEG <> BD71.BD7_CODPEG ) )  "
	
cSql += "	WHERE BD71.BD7_FILIAL = '" + xFilial("BD7") + "' "
cSql += "	  AND BD71.BD7_CODOPE = '" + cCodOpe + "' "
cSql += "	  AND BD71.BD7_CODLDP = '" + cCodLdp + "' "
cSql += " 	  AND BD71.BD7_CODPEG = '" + cCodPeg + "' "
cSql += "     AND BD71.BD7_CODRDA = '" + cCodRda + "' "
cSql += " 	  AND BD71.D_E_L_E_T_ = '' "	

cSQL := changeQuery(cSql)
TCQUERY cSQL New ALIAS "PLSITEN063"

if !PLSITEN063->(eof())

	while !PLSITEN063->(eof())
		cChave := xFilial("BD7") + PLSITEN063->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)
		
		If aScan(aChv, cChave) > 0
			PLSITEN063->(dbSkip())
			Loop
		endIf
		
		aadd(aChv, cChave)
		//Vamos posicionar no BD5/BE4 de acordo com o tipo de guia e depois, chamar a fun��o de Retorno de Fase
		(cAlias)->(dbSetorder(1))
		if (cAlias)->( msSeek(cChave) )
			nRecno 	:= (cAlias)->(recno())
			dDatPro	:= (cAlias)->&( cAlias + "_DATPRO" )
			lRet 	:= PLSA500RFS( cAlias, nRecno , 6,, .f., .t. )
		endIf
		nRecBCI := BCI->(Recno())

		//Agora, iremos mudar a fase da guia novamente, para executar a cr�tica 063
		if lRet
			
			//Verifico se o alias est� posicionado corretamente. Se n�o, for�o o posicionamento.
			if nRecno <> (cAlias)->(recno())
				(cAlias)->(dbGoTo(nRecno))
			endIf
			
			// Execu��o da Mudan�a de Fase. Segundo par�metro indica se trata de Mudan�a de fase apenas de guia "1" ou se � da PEG toda - "2". Como � guia, 
			// passamos o identificador "1". A fun��o est� no fonte PLSMCTMD                       
			aRet := PLSXMUDFAS(	cAlias, '1', cCodOpe, cTipGUi, dDatPro, .f., /*cNextFase*/, /*nVlrPAG*/, /*nVlrGlo*/, .f., /*aItensGlo*/,;
	    			/*aFiltro*/, /*lReanaliza*/, .f., /*oBrwIte*/, /*lProcRev*/, /*nIndRecBD6*/, /*nTotEventos*/, /*aThreads*/, /*nCont*/, /*cUserName*/,;
	    			/*lSolicit*/, /*aPLS475*/, /*lPagAto*/, /*cChaveLib*/, /*lNegProPac*/, /*lGetCri*/, .f., /*lRecGlo*/, /*aSequen*/, /*isPLSA502*/)
		endIf
		BCI->(RecLock("BCI",.F.))
			BCI->BCI_FASE := PLSMDVFA(nRecBCI, .F.)[1]
		BCI->(MsUnLock())
	PLSITEN063->(dbSkip())
	endDo

endIf

PLSITEN063->(dbCloseArea())

Return

/*/{Protheus.doc} PlsVrIntAl

Verifica situa��es, para permtir a inclus�o do Recurso de Glosa
@author Renan Martins
@since 03/2017
@version P12 
/*/
Function PlsVrIntAl (cGuia, dData, cNumGuiTrc, cMatric, cRdaCode)
Local cRet		:= ""

Default cRdaCode := ""

cGuia := StrTran(strtran(cGuia,'.',''),'-','') 
BE4->( DbSetOrder(2) )//BE4_FILIAL + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
If ( BE4->( DbSeek(xFilial("BE4")+cGuia) ) )

 	cNumGuiTrc :=  BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO) 
 	cMatric    :=  BE4->(BE4_CODOPE + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG + BE4_DIGITO)
 	
 	if (alltrim(cRdaCode) <> alltrim(BE4->BE4_CODRDA))
 	
		cRet := STR0012 //"Guia n�o localizada!"
		
 	elseIf (BE4->BE4_TIPGUI == '05')
 		
 		cRet := STR0013 //"Guia informada � de Resumo de Interna��o. Informe corretamente o n�mero da guia de Solicita��o de Interna��o." 
 		
	ElseIf (BE4->BE4_STATUS == '3' .Or. BE4->BE4_CANCEL == '1')    //3-N�o Autorizada ou Cancelada
		
		cRet := STR0009 //"Guia N�o Autorizada ou Cancelada. Verifique o n�mero ou situa��o da Guia!"
		
	ElseIf ( !Empty(BE4->BE4_DTALTA) .And. (CtoD(dData) > BE4->BE4_DTALTA) )
		
		cRet := STR0010 //"Data do Atendimento informada � superior a data da Alta."
 	
 	elseIf EmpTy(BE4->BE4_DATPRO)
 	
 		cRet := STR0014//"N�o foi informada a data da interna��o do benefici�rio para esta solicita��o!"
 			
	ElseIf (CtoD(dData) < BE4->BE4_DATPRO)
		cRet := STR0011 //"Data do atendimento informada � menor que a data de Interna��o"
	Elseif (alltrim(cRdaCode) <> alltrim(BE4->BE4_CODRDA))
		cRet := STR0012 //"Guia n�o localizada!"
	EndIf
Else
	cRet := STR0012 //"Guia n�o localizada!"
EndIf		

Return cRet


Function MntResDad(cCarater, cCodRda, cCnes,  cCodLoc, cMatric, cCodEsp, cCid, cCid2, cCid3,cCid4, cCid5, cTipSai, cTipFat, cIndAci,;
 				    cTipInt, cRegInt, cNumSol, cAtenRn, cDtIniF, cHrIniF, cDtFimF, cHrFimF, cNumGuiTrc, cObs, cPadCon, cPadInt, dDatPro)


	/*Campos Cabe�alho*/
	aDadosBOW := {{ "TP_CLIENTE", "WEB" },;							//Tipo de Cliente
				  { "CARSOL"    , cCarater },; 								//Carater da solicitacao
				  { "OPEMOV"	, PLSINTPAD() },;						//Operadora de movimento
				  { "TPGRV"		, "2" },;								//Tipo de Gravacao
				  { "TIPOMAT"   , "1" },;								//Matricula Siga
				  { "GERSEN"	, GetNewPar("MV_PLGSENW",.T.) },;	//Gera senha de autoriza��o
				  { "CODLDP"	, PLSRETLDP(4)},;//LOCAL de Digitacao
				  { "CODRDA"	, cCodRda },;				//Rda
				  { "CNES"		, cCnes   },;					//CNES
				  { "CODLOC"	, cCodLoc },;				//LOCAL de atendimento
				  { "USUARIO"	, cMatric },;						//Matricula
				  { "ORIGEM"    , "1" },;								//Origem 1=Autorizacao ou 2=Liberacao
				  { "RPC"  		, .T. },;								//.F. vem do remote .T web, pos
				  { "HORAPRO"	, SubStr( StrTran( Time(), ":", "" ), 1, 4 ) },; //Hora
				  { "DATPRO"	, /*Date()*/dDatPro },;				//Data de digita��o
				  { "CIDPRI"	, cCid },;             				//Cid Principal
				  { "CID2"		, cCid2 },;								//Cid 2
				  { "CID3"		, cCid3 },;								//Cid 3
				  { "CID4"		, cCid4 },;								//Cid 4
				  { "CID5"		, cCid5 },;								//Cid 5
				  { "TIPO"      , "05" },;								//Tipo de Guia
				  { "TIPGUI"      , "05" },;								//Tipo de Guia				 
				  { "TIPSAI"    , cTipSai },; 								//Tipo de Saida
				  { "TIPFAT"    , cTipFat },; 								//Tipo de Faturamento
				  { "INDACI"    , cIndAci },; 								//Indicacao de Acidente				  
				  { "TIPINT"    , cTipInt },;								//Tipo de Internacao
				  { "REGINT"    , cRegInt },;								//Regime da Internacao
				  { "NUMSOL"    , cNumGuiTrc/*cNumSol*/ },;								//Guia Principal				  
				  { "INTERN"    , .T. },; 								//Internacao
				  { "RESINT"    , .T. },;
				  { "ATENRN"	, cAtenRn },; 								//Atendimento RN
				  { "INIFAT"	, cDtIniF },;
				  { "FIMFAT"	, cDtFimF },;
				  { "HRINIFAT"	, cHrIniF },; 		
				  { "HRFIMFAT"	, cHrFimF },; 
				  { "OBSERVAC"	, cObs },; 		
				  { "PADCON"		, cPadCon },; 
				  { "PADINT"		, cPadInt},;		
				  { "GUIPRE"	, "" }} // Numero 2-Guia Prestador na guia de Consulta via Portal do Prestador.
				  
return aDadosBOW

Function MntResIte(cSeqMov, cCodPro, cCodPad, nQtdPro, nQtdAut, cVlrApr, cHorIni, cHorFim, cViaAc, cTecUt, nRedAc, cStProc, dDatPro)
	local aItens := {} 
	
	local cTecUtVinc := ""
	local nValor	
		
	if !empty(alltrim(cTecUt))
		cTecUtVinc := alltrim(PLSVARVINC('48', nil, cTecUt) )
	endif
	
	if nRedAc > 0
		nValor := Val( StrTran(strtran(cVlrApr,',',''),'.','') )/100 * nRedAc
	else 
		nValor := Val( StrTran(strtran(cVlrApr,',',''),'.','') )/100
	endif
	
	AaDd( aItens, {{ "SEQMOV", strzero(val(cSeqMov), 3)},;
					 { "CODPRO", cCodPro },;
					 { "CODPAD", cCodPad },;
					 { "QTD"   , nQtdPro },;
					 { "QTDAUT", nQtdAut },;
					 { "VLRAPR", nValor },;
					 { "RESAUT", "" },;
					 { "INDCLIEVO", "" },;
					 { "DENTE" , ""  },;
					 { "FACE"  , "" },;
					 { "HORINI", Substr(StrTran(cHorIni,':',''),1,4) },;
					 { "HORFIM", Substr(StrTran(cHorFim,':',''),1,4) },;
					 { "VIAAC",  cViaAc },;
					 { "TECUT",  cTecUtVinc},;
					 { "PERVIA",  plRtPerV(cViaAc)},;
					 { "REDAC",  nRedAc },;
					 { "ATPPAR", {} },;
					 { "STPROC", cStProc } ,;
					 { "SLVPRO", cCodPro } ,;
					 { "SLVPAD", cCodPad } ,;
					 { "DIAGNO", "" },; 
					 { "DATPRO", dDatPro } } )

		aItens[1] := WsAutoOpc( aItens[1] )

return aItens


/*/{Protheus.doc} PlsVrIntPro
Realiza pesquisa na solicita��o de interna��o e prorroga��o para veriricar os procedimentos que possuem auxiliar e a quantidade m�xima de cada.
@author Renan Martins
@since 01/2018
@version P12 
/*/
Function PlsVrIntPro (cGuia)
Local aArBE4		:= BE4->(GetArea())
Local aArBQV		:= BQV->(GetArea())
Local aArB4Q		:= B4Q->(GetArea())
Local aArBEJ		:= BEJ->(GetArea())
Local aProc		:= {} 
Local aProcAux	:= {}
Local aTab			:= {}
Local nRet			:= 0
Local nI			:= 1
local cAux			:= getNewPar("MV_PLSCAUX","AUX")
local nTamCODUNM	:= BD7->( tamSX3("BD7_CODUNM")[1] )

Default cGuia := ""

BE4->(DbSetorder(2)) //BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
B4Q->(DbSetOrder(4)) //B4Q_FILIAL+B4Q_GUIREF
BEJ->(DbSetOrder(1)) //BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN
BQV->(DbSetOrder(1)) //BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
BD4->(DbSetOrder(1)) //BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO+DTOS(BD4_VIGINI)

if (Empty(cGuia))
	nRet := 0
endif

if BE4->( MsSeek(xFilial("BE4") + cGuia) )
	//As informa��es ser�o semelhantes para a solicita��o e prorroga��o
	aProcAux := {BE4->BE4_DATPRO, BE4->BE4_CODOPE, BE4->BE4_CODRDA, BE4->BE4_CODESP, BE4->(BE4_CODLOC+BE4_LOCAL),;
						   BE4->BE4_DATPRO,BE4->BE4_OPERDA}
		
	if ( BEJ->( MsSeek(xFilial("BEJ") + cGuia)) )
		While ! BEJ->(Eof()) .And. BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT) == xFilial("BE4") + cGuia
			aAdd(aProc, {BEJ->BEJ_CODPAD, BEJ->BEJ_CODPRO, BEJ->BEJ_DATPRO}) 			
			BEJ->(DbSkip())
		EndDo
	EndIf
endif

If ( B4Q->( MsSeek(xFilial("B4Q") + cGuia)) )
	While ! B4Q->(Eof()) .And. B4Q->(B4Q_FILIAL+B4Q_GUIREF) == xFilial("BE4") + cGuia
		if ( BQV->(MsSeek(xFilial("BQV")+B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT))) )
			While ! BQV->(Eof()) .And. BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == B4Q->(B4Q_FILIAL+B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT)
				aAdd(aProc, {BQV->BQV_CODPAD, BQV->BQV_CODPRO, BQV->BQV_DATPRO})
				BQV->(DbSkip())
			EndDo
		endif	
		B4Q->(DbSkip())
	enddo	
endif	

//Tenho que chamar o PLSRETTAB para poder pesquisar na BD4 a participa��o de AUX.
for nI = 1 to len(aProc)	
	aTab := PLSRETTAB(aProc[nI,1], aProc[nI,2],aProc[nI,3],;
                     aProcAux[2],aProcAux[3],aProcAux[4],"",aProcAux[5],;
                     aProc[nI,3],,aProcAux[7],,"1","1")
        
	if ( BD4->(MsSeek( xFilial("BD4") + aProcAux[2] + aTab[3] + aProc[nI,1] + aProc[nI,2] + padr(cAux, nTamCODUNM) )) )
		if ( ((dtos(aProc[nI,3]) >= dtos(BD4->BD4_VIGINI) ) .and. ( dtos(aProc[nI,3]) <= dtos(BD4->BD4_VIGFIM) .or. empty(BD4->BD4_VIGFIM)) ) .or. ;
							(empty(BD4->BD4_VIGINI) .and. empty(BD4->BD4_VIGFIM)) )
			nRet := iif (nRet > BD4->BD4_VALREF, nRet, BD4->BD4_VALREF)
		endif
	endif 
next

RestArea(aArBE4)		
RestArea(aArBQV)		
RestArea(aArB4Q)		
RestArea(aArBEJ)	
Return nRet
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Funcao   � PLSEQNFR � Autor � Daher		          � Data � 08.02.2008 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o de campos										  ���
��������������������������������������������������������������������������ٱ�         
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PLSEQNFR(cAliaSup)
LOCAL cRet 		  := ""     
DEFAULT cAliaSup  := ""

If Empty(cAliaSup)
	If Type("M->BE4_SEQNFS") <> 'U'
		cRet := M->BE4_SEQNFS
	Endif
	If Type("M->BD5_SEQNFS") <> 'U'
		cRet := M->BD5_SEQNFS
	Endif             
Endif

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PlLogWsFn1
Armazena log espec�fico do WS de PEG
@since 07/2020
@version P12 
/*/
//-------------------------------------------------------------------
Function PlLogWsFn1(cColMarc, cColNaoMarc, cSemaforo, lMostraGuia, cFunName, lGrvVlrApr, cTipoGuia, cWhere, lGerPeg )
local cNomeLog	:= "PPLSETPEG_controle_" +  strtran(left(time(), 2), ":","") + "_00.LOG"
local cTextLog	:= ""
local cCodRDA	:= iif(!empty(cSemaforo), substr(cSemaforo,7,6), "")

cTextLog := "PEG WS ERRO - RDA: " + cCodRDA + " - " + strtran(time(), ":", "_") + CRLF
cTextLog += "cWhere		: " + cvaltochar(cWhere) + CRLF
cTextLog += "cColsCk 	: " + cvaltochar(cColMarc) + CRLF
cTextLog += "cColUnCK 	: " + cvaltochar(cColNaoMarc) + CRLF
cTextLog += "cSemaforo 	: " + cvaltochar(cSemaforo) + CRLF
cTextLog += "lGerPeg 	: " + cvaltochar(lGerPeg) + CRLF
cTextLog += "lMosGui 	: " + cvaltochar(lMostraGuia) + CRLF
cTextLog += "cFunName 	: " + cvaltochar(cFunName) + CRLF
cTextLog += "lGrvVlrApr	: " + cvaltochar(lGrvVlrApr) + CRLF
cTextLog += "cTipoGuia 	: " + cvaltochar(cTipoGuia) + CRLF
cTextLog += "Detalhes	: " + FunName() + " - " + iif(findfunction('dwcallstack'), dwcallstack(0,,.f.),'' ) + CRLF
cTextLog += "===========================" + CRLF
PlsLogFil(cTextLog, cNomeLog)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PlRtCmpDaR
Posicionar e retornar texto, conforme passagem de par�metros. Usado no SX7, devido ao d�bito de SX9
@since 04/2021
@version P12 
/*/
//-------------------------------------------------------------------
function PlRtCmpDaR(cAlias, cChave, cCmpRet, nIndex, lPosic)
local aAreaPos	:= (cAlias)->(GetArea())
local cRetTxt	:= ""
default nIndex	:= 1
default lPosic	:= .f.

cChave	:= iif( empty(alltrim(cChave)), "--", cChave ) 

(cAlias)->(dbSetOrder(nIndex))	
if ( (cAlias)->(DbSeek(xFilial(cAlias) + cChave)) )
	cRetTxt := (cAlias)->&(cCmpRet)
endif

if !lPosic
	RestArea(aAreaPos)
endif

return cRetTxt


//-------------------------------------------------------------------
/*/{Protheus.doc} PlRetObsB72
Retorna as observa��es realizadas pelo auditor, buscando a guia na auditoria (B53) e ap�s, pegando a observa��o na B72
@since 12/2021
@version P12 
/*/
//-------------------------------------------------------------------
function PlRetObsB72(cAlias, cCodOpe, cAnoAut, cMesAut, cNumGuia, cSequen)
local aAreaB53	:= B53->(GetArea())
local aAreaB72	:= B72->(GetArea())
local cRetAud	:= "<p>"+ STR0015 + "</p>" //Guia n�o passou pelo processo de auditoria.

B53->(DbSetOrder(1)) //B53_FILIAL+B53_NUMGUI+B53_ORIMOV
B72->(DbSetOrder(1)) //B72_FILIAL+B72_ALIMOV+B72_RECMOV+B72_SEQPRO+B72_CODGLO+B72_CODPAD+B72_CODPRO

if B53->( MsSeek(xFilial("B53") + cCodOpe + cAnoAut + cMesAut + cNumGuia) )
	if B72->( MsSeek(xFilial("B72") + B53->(B53_ALIMOV + B53_RECMOV) + cSequen) )
		cRetAud := "<p> <strong>" + STR0016 + "</strong> " 	+ iif( B72->B72_PARECE == "0", STR0017, STR0018 ) + CRLF + "</p>" //Parecer / AUTORIZADO / NEGADO
		cRetAud += "<p> <strong>" + STR0019 + "</strong>" 	+ iif( empty(B72->B72_OBSANA), " - ",PlRetPonto(B72->B72_OBSANA) ) + "</p>" //Observa��es:
	else
		cRetAud := "<p>" + STR0020 + "</p>" //Item n�o auditado ou em espera pela auditoria.
	endif
endif

RestArea(aAreaB53)
RestArea(aAreaB72)

return fwcutoff(cRetAud)
