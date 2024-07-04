#include "MTECMLIB.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE "totvs.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"

Static aModulo := Array(2)
/*-------------------------------------------------------------------
EXPERI�NCIAS COM O FLUIG|ECM
--------------------------------------------------------------------*/

//-------------------------------------------------------------------
/*/{Protheus.doc} PutCard
Esta fun��o coloca/atualiza um ficheiro no ECM

@author guilherme.pimentel
@param cView View que ser� colocada no formul�rio
@param cProcess Descri��o do processo, se informado atualiza o formul�rio relacionado ao processo sen�o cria um novo
@param cDesc Descri��o do ficheiro

@since 24/01/2014
@version P12
@return Nil
/*/
//-------------------------------------------------------------------

Function PutCard(cView,cProcess,cDesc,lMostraHelp,nNovoModulo) 

Local oView := nil
Local cProcessId := cProcess // se informado atualiza o formul�rio relacionado ao processo sen�o cria um novo
Local cDescription := cDesc
Local cCardDescription := ""
Local aEvents := Array(1,2) // eventos que ser�o customizados para o formulario
Local nFormId := 0
Local aFiles
Local nModuloAnt := 0

Default lMostraHelp := .T.
Default nNovoModulo := nModulo

nModuloAnt := nModulo
nModulo := Val(nNovoModulo)

oView := FWLoadView(cView)

If oView == NIL
	MsgStop(STR0006) //"Ocorreu um erro na cria��o do formul�rio, verifique se fonte da View existe no reposit�rio"
Else
	oView:setOperation(MODEL_OPERATION_INSERT)
	
	aFiles := oView:GetFluigForm()
	aEvents[1][1] := "DisplayFields" // nome do evento
	aEvents[1][2] := "function displayFields(form, customHTML) {"+;
							"form.setValue('ecmvalidate', '1');"+;
							"form.setValue('WKDef',getValue('WKDef'));"+;						
							"form.setValue('WKVersDef',getValue('WKVersDef'));"+;						
							"form.setValue('WKNumProces',getValue('WKNumProces'));"+;						
							"form.setValue('WKNumState',getValue('WKNumState'));"+;
							"log.info('Teste de chamada de fun��o - DisplayFields');"+;
						"}"
	
	nFormId := FWECMPutCard(cProcessId,cDescription,cCardDescription,aFiles,aEvents) // retorna o codigo do fich�rio no ECM
		
	If FWWFIsError()
		Help(" ",1,"PUTCARD",,FWWFGetError()[2],1,1)
	Else
		If lMostraHelp
			MsgInfo(STR0002+ AllTrim(Str(nFormId)) +STR0001)//" atualizado com sucesso"//"Fich�rio "
		EndIf
	EndIf
EndIf

nModulo := nModuloAnt

Return(nFormId)

//-------------------------------------------------------------------
/*/{Protheus.doc} StartProcess
Esta fun��o inicializa uma solicita��o no ECM

@author guilherme.pimentel

@param cProcess C�digo do processo
@param cUser usu�rio solicitante
@param aUserList Lista de usu�rios respons�veis ({'admin'})
@param nTaks C�digo da atividade inicial
@param lMessage Exibe mensagens de Aviso
@param lComplete Completa a Tarefa ao mudar a atividade
@param aAttach Array com anexos
@param aNextTask [1] Proxima Etapa
				   [2] C�digo do usu�rio solicitante	
				   [3] Lista de colaboradores que receber�o a taref
@param lFlgSCR	 Atualiza campo CR_FLUIG da al�ada

@return aRet[1] C�digo da Solicita��o
@return aRet[2] Identificador do formul�rio daquela solicita��o

@since 27/01/2014
@version P12
@return Nil
/*/
//-------------------------------------------------------------------

Function StartProcess(cProcess,cUser,aUserList,nTaks,lMessage,lComplete,aAttach,aNextTask,lFlgSCR)
Local nRet 		:= 0
Local nCardId 	:= 0
Local lRet		:= .T.
Local cErrorMsg	:= ''
Local aDados 	:= {}
Local oModel 	:= Nil
Local oView 	:= NIl
Local xValue 	:= Nil
Local aRet 		:= {}
Local nRetM		:= 0
Local lEnvFluig	:= .T.

Default aNextTask	:= {}
Default aAttach		:= {}
Default nTaks		:= 0
Default lMessage	:= .T.
Default lComplete	:= .F.
Default lFlgSCR		:= .F.

dbSelectArea("CPF")
CPF->(dbSetOrder(1))
CPF->(dbGoTop())

// -----------------------------------------------------------------------
// Valida��es se ser� possivel executar o StartProcess
// -----------------------------------------------------------------------
If !CPF->(DbSeek(xFilial('CPF')+cProcess))
	lRet := .F.	
ElseIf CPF->CPF_STATUS == '4'
	lRet := .F.
Elseif CPF->CPF_STATUS $ '1|3' .And. CPF->CPF_MODULO $ '02|04|69' .And. !ProcFlgSCR(cProcess) 
	lRet := .F.		
ElseIf !Empty(CPF->CPF_PREEXE)
// -----------------------------------------------------------------------
// Executa a fun��o desejada, verificando seu retorno, se for um retorno logico
// ele ser� atribuido ao lRet, msgs de erro dev�o estar dentro da fun��o chamada
// -----------------------------------------------------------------------	
	xValue := &(CPF->CPF_PREEXE)
	
	If ValType(xValue) <> 'L'
		cErrorMsg := MTSetMsg('H','CFG115Blq',STR0015,lMessage) //'A fun��o informada n�o retorna um valor l�gico'
		lRet := .T.
	Else
		lRet := xValue
	EndIf
EndIf

If lRet .And. ExistBlock("ECMStart") .And. Len(aNextTask) >= 3 .And. Len(aNextTask[3]) >= 1
	lEnvFluig := ExecBlock("ECMStart",.F.,.F.,{cProcess,aNextTask[3,1]})
	If Valtype(lEnvFluig) == 'L'
		lRet := lEnvFluig
	Endif
Endif

// -----------------------------------------------------------------------
// Execu��o do StartProcess
// -----------------------------------------------------------------------
If lRet   
	
	oModel := FWLoadModel(CPF->CPF_MODEL)
	oView := FWLoadView(CPF->CPF_VIEW)
			
	oModel:SetOperation(4)
	
	If oModel:Activate()
	   
	    oView:SetModel( oModel )	
		aDados := FWViewCardData(oView)
		
		aAdd(aDados,{'ecmvalidate','0'})
		
		nRet:= FWECMStartProcess(cProcess,;							  //cProcessId C�digo do processo no ECM
							 nTaks,;								  //nNextTask N�mero da atividade no ECM. Se informado 0 a solicita��o inicia na primeira atividade
							 STR0008,;  		  						//cComments Coment�rios da tarefa //'Inicializa��o de solicita��o'
							 aDados ,;								//cXMLData XML com os dados do formul�rio. Para usar certifique-se que o fluxo possua um fich�rio.
							 aAttach,;								//aAttach Documentos anexos da solicita��o
							 cUser,;	  							  //cUserId Matricula do colaborador que ir� iniciar a solicita��o. Ver documenta��o do ECM sobre mecanismo de atribui��o.
							 aUserList,;	  						  //aColleagueIds Lista de colaboradores que receber�o a tarefa. Ver documenta��o do ECM sobre mecanismo de atribui��o.
							 lComplete,;							  //lComplete Indica se deve ou completar a tarefa. Se a tarefa n�o for completa o fluxo n�o muda de atividade no ECM.
							 @nCardId)								 			  
			
		// -----------------------------------------------------------------------
		// StartProcess com movimenta��o autom�tica
		// -----------------------------------------------------------------------
		If !Empty(aNextTask) .And. !FWWFIsError()
		
			nRetM:= FWECMMoveProcess(nRet,;						 // cProcessId C�digo do processo no ECM
								 aNextTask[1],;					 // nNextTask N�mero da atividade no ECM. Se informado 0 a solicita��o inicia na primeira atividade
								 '',;  		 					 // cComments Coment�rios da tarefa
								 NIL ,;			 				 // cXMLData XML com os dados do formul�rio. Para usar certifique-se que o fluxo possua um fich�rio.
								 {},;								 // aAttach Documentos anexos da solicita��o
								 aNextTask[2],;			  		 // cUserId Matricula do colaborador que ir� iniciar a solicita��o. Ver documenta��o do ECM sobre mecanismo de atribui��o.
								 aNextTask[3],;					 // aColleagueIds Lista de colaboradores que receber�o a tarefa. Ver documenta��o do ECM sobre mecanismo de atribui��o.
								 .T.,;								 // lComplete Indica se deve ou completar a tarefa. Se a tarefa n�o for completa o fluxo n�o muda de atividade no ECM.
								 @nCardId)								 			  
		EndIf
		
		// Preenche c�digo do processo Fluig
		If nRet > 0 .And. lFlgSCR 
			Reclock('SCR',.F.)
			SCR->CR_FLUIG := cValToChar(nRet)
			SCR->(MSUnlock())
		Endif
		
		// -----------------------------------------------------------------------
		// Tratamento de erro
		// -----------------------------------------------------------------------
		If FWWFIsError()
		   aError := FWWFGetError()
		   cErrorMsg := MTSetMsg('MS',,aError[2],lMessage)
		EndIf
	EndIf	
EndIf

AADD(aRet,nRet)
AADD(aRet,nCardId)
AADD(aRet,cErrorMsg) 

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MTSetMsg
Fun��o responsavel pelo controle das mensagens

@author guilherme.pimentel

@param cType Tipo da Mensagem
@param cId Identificador da mensagem
@param cError Mensagem de erro
@param lMessage Exibe mensagens de Aviso

@since 02/07/2014
@version P12
@return Nil
/*/
//-------------------------------------------------------------------

Function MTSetMsg(cType,cId,cError,lMessage)

If lMessage
	If cType == 'H'
		Help(" ",1,cId,,cError,4,1)
	ElseIf cType == 'MS'
		MsgStop(cError)
	ElseIf cType == 'MI'
		MsgInfo(cError)
	EndIf
EndIf

Return cError

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateCard
Esta fun��o atualiza uma solicita��o no ECM

@author paulo.henrique

@param cProcess C�digo do processo
@param nCardId Numero da solicitacao
@param lMessage Exibe mensagens de Aviso

@since 02/07/2014
@version P12
@return Nil
/*/
//-------------------------------------------------------------------

Function UpdateCard(cProcess,nCardId,lMessage)
Local lRet := .T.
Local aDados := {}
Local oModel := Nil
Local oView := NIl

Default cProcess := ""
Default nCardId := 0
Default lMessage := .T.

dbSelectArea("CPF")
CPF->(dbSetOrder(1))
CPF->(dbGoTop())

// -----------------------------------------------------------------------
// Valida��es se ser� possivel executar o StartProcess
// -----------------------------------------------------------------------
If !CPF->(DbSeek(xFilial('CPF')+cProcess))
	lRet := .F.
	If lMessage
		Help(" ",1,'UpdateCard',,STR0004+cProcess+STR0009,4,1) //'Processo ' //' n�o encontrado.'
	EndiF
ElseIf CPF->CPF_STATUS == '4'
	lRet := .F.
	If lMessage
		Help(" ",1,'UpdateCard',,STR0010,4,1) //'O processo est� bloqueado, favor verificar.'
	EndIf
EndIf

// -----------------------------------------------------------------------
// Execu��o do FWECMUpdCard
// -----------------------------------------------------------------------
If lRet   
	oModel := FWLoadModel(CPF->CPF_MODEL)
	oView := FWLoadView(CPF->CPF_VIEW)
			
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	
	If oModel:Activate()
	   
	    oView:SetModel( oModel )	
					
		aDados := FWViewCardData(oView)
		
		aAdd(aDados,{'ecmvalidate','0'})
		
		FWECMUpdCard(nCardId, aDados)
		
		If FWWFIsError()
		   lRet := .F.
		   aError := FWWFGetError()
		   MsgStop(aError[2])
		ElseIf lMessage
		 //MsgInfo(STR0004+AllTrim(Str(nRet))+STR0003)//" iniciado com sucesso"//"Processo "
		EndIf
	EndIf	
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MoveProcess
Esta fun��o move a etapa de uma solicita��o no ECM

@author paulo.henrique

@param cProcess C�digo do processo
@param nInstanceId  Numero da solicita��o no ECM
@param cUser usupario solicitante
@param aUserList Lista de usu�rios respons�veis ({'admin'})
@param nNextTask C�digo da Proxima atividade se 0 vai para a atividade seguinte
@param cComments Coment�rios da tarefa
@param lMessage Exibe mensagens de Aviso

@since 07/07/2014
@version P12
@return Nil
/*/
//-------------------------------------------------------------------

Function MoveProcess(cProcess,nInstanceId,cUser,aUserList,nNextTask,cComments,lMessage)
Local nRet := 0
Local aDados := {}
Local oModel := Nil
Local oView := NIl
Local lRet	:= .T.
Local nCardId := 0	
Local aRet := {}

Default cProcess := ""
Default nInstanceId := 0
Default cUser := 'admin'
Default aUserList := {'admin'}
Default nNextTask := 0
Default cComments := STR0011 //"Movimenta��o de solicita��o"
Default lMessage := .T.

dbSelectArea("CPF")
dbSetOrder(1)
dbGoTop()

// -----------------------------------------------------------------------
// Valida��es se ser� possivel executar o StartProcess
// -----------------------------------------------------------------------
If !CPF->(DbSeek(xFilial('CPF')+cProcess))
	lRet := .F.
	If lMessage
		Help(" ",1,'MoveProcess',,STR0004+cProcess+STR0009,4,1) //'Processo '//' n�o encontrado.'
	EndiF
ElseIf CPF->CPF_STATUS == '4'
	lRet := .F.
	If lMessage
		Help(" ",1,'MoveProcess',,STR0010,4,1)//'O processo est� bloqueado, favor verificar.'
	EndIf
EndIf

// -----------------------------------------------------------------------
// Execu��o do MoveProcess
// -----------------------------------------------------------------------
If lRet   
	oModel := FWLoadModel(CPF->CPF_MODEL)
	oView := FWLoadView(CPF->CPF_VIEW)
			
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	
	If oModel:Activate()
	   
	    oView:SetModel( oModel )	
					
		aDados := FWViewCardData(oView) // Verificar
		
		aAdd(aDados,{'ecmvalidate','0'})
		
		nRet:= FWECMMoveProcess(nInstanceId,;							 // cProcessId C�digo do processo no ECM
							 nNextTask,;								 // nNextTask N�mero da atividade no ECM. Se informado 0 a solicita��o inicia na primeira atividade
							 cComments,;  		 						 // cComments Coment�rios da tarefa
							 NIL ,;			 							 // cXMLData XML com os dados do formul�rio. Para usar certifique-se que o fluxo possua um fich�rio.
							 {},;									     // aAttach Documentos anexos da solicita��o
							 cUser,;							  		 // cUserId Matricula do colaborador que ir� iniciar a solicita��o. Ver documenta��o do ECM sobre mecanismo de atribui��o.
							 aUserList,;								 // aColleagueIds Lista de colaboradores que receber�o a tarefa. Ver documenta��o do ECM sobre mecanismo de atribui��o.
							 .T.,;										 // lComplete Indica se deve ou completar a tarefa. Se a tarefa n�o for completa o fluxo n�o muda de atividade no ECM.
							 @nCardId)								 			  
		
		
		If FWWFIsError()
		   aError := FWWFGetError()
		   MsgStop(aError[2])
		ElseIf lMessage
		//  MsgInfo(STR0004+AllTrim(Str(nRet))+STR0003)//" iniciado com sucesso"//"Processo "
		EndIf
	EndIf	
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CancelProcess
Rotina para cancelamento de Solicita��es no Fluig

@author guilherme.pimentel
@return Nil
@since 14/03/2013
@version P11
/*/
//-------------------------------------------------------------------

Function CancelProcess(nInstanceId,cUserId,cComments,lMessage)
Local lRet := .T.
Local aError := {}

Default lMessage := .T.

If Empty(nInstanceId)
	If lMessage
		Help("",1,"CancelProcess",,STR0012,1,1) //'� necess�rio informa o c�digo da atividade.'
	EndIf
ElseIf Empty(cUserId)
	If lMessage
		Help("",1,"CancelProcess",,STR0013,1,1) //'Favor informar o c�digo do usu�rio.'
	EndIf
ElseIf Empty(cComments)
	If lMessage
		Help("",1,"CancelProcess",,STR0014,1,1) //'� obrigat�rio informar o motivo do cancelamento.'
	EndIf
Else
	
	lRet := FWECMCancelProcess(nInstanceId,cUserId,cComments)
	
	If FWWFIsError()
		aError := FWWFGetError()
		MsgStop(aError[2])
	ElseIf lMessage
		MsgInfo(STR0004+AllTrim(Str(nInstanceId))+STR0005)//" cancelado com sucesso"//"Processo "
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MTaEvtDef
Default do array padr�o de eventos dos processos do ECM

@author guilherme.pimentel

@since 11/02/2014
@version P12
@return Nil
/*/
//-------------------------------------------------------------------

Function MTaEvtDef()
Local aEvents := Array(3,2)
Local oModel := FWModelActive()

Private __ECMEVENT := 1, __ECMINC := oModel:GetValue('CPFMASTER','CPF_MODO') == '2'

// -----------------------------------------------------------------------
// Caso venha do configurador o beforeTaskSave sera definido por um campo
// O script do MTAtuIncWF.aph foi descontinuado, sendo tratado no MTAtuWF.aph
// -----------------------------------------------------------------------
aEvents[1][1] := "beforeTaskSave"
aEvents[1][2] := AllTrim(h_MTAtuWF())

aEvents[2][1] := "beforeStateEntry"
aEvents[2][2] := 'function beforeStateEntry(sequenceId) {'+;
 		'if (sequenceId  != "1") {'+;
       	'log.info("BSE - Troca do ecmvalidate");'+;
			'hAPI.setCardValue("ecmvalidate","1");'+;
			'log.info("BSE - Novo ecmvalidate = "+hAPI.getCardValue("ecmvalidate"));'+;
    	'}'+;		
'}' 

// -----------------------------------------------------------------------
// Tratamento de tarefa conjunta
// -----------------------------------------------------------------------
__ECMEVENT := 2
aEvents[3][1] := "calculateAgreement"
aEvents[3][2] := AllTrim(h_MTAtuWF())
Return aEvents

//-------------------------------------------------------------------
/*/{Protheus.doc} MTaPropDef
Default do array padr�o de propriedades dos processos do ECM

@author guilherme.pimentel

@param oModel Modelo ativo
@param oView View ativa
@since 11/02/2014
@version P12
@return Nil
/*/
//-------------------------------------------------------------------

Function MTaPropDef(oModel,oView,cModel,cReturn,cUpdStates,cUpdSolic)
Local aProperties	:= Array(7,2)

Default cReturn	:= '2' //N�o
Default cUpdStates := ''

//PROPRIEDADES
aProperties[1][1] := "FWMODEL" // RESPONSAVEL PELA VALIDA��O DO MODELO
aProperties[1][2] := If(Empty(cModel),oModel:GetId(),cModel) // valor

aProperties[2][1] := "FWRETURN" // TRATAMENTO PARA WF QUE EXIGEM ATUALIZA��O NO FORMUL�RIO AP�S COMMIT NO MODELO
aProperties[2][2] := cReturn // valor

aProperties[3][1] := "SPECIALKEY"
aProperties[3][2] := Upper(GetSrvProfString("SpecialKey", ""))

aProperties[4][1] := "FWUPDSTATES" // VERIFICA EM QUAIS ETAPAS FAZ ATUALIZA��O NO PROTHEUS
aProperties[4][2] := cUpdStates

aProperties[5][1] := "FWUPDSOLIC" // VERIFICA SE SEMPRE EXECUTAR� A DESCIDA DE DADOS DO FLUIG P/ O PROTHEUS NA MOVIMENTA��O
aProperties[5][2] := cUpdSolic

aProperties[6][1] := "APPLICATIONID" // ID DO APLICATIVO DO PROTHEUS NO IDENTITY (USADO NAS A��ES RELACIONADAS DO FORMUL�RIO)
aProperties[6][2] := If(FindFunction('FluigAppId'),FluigAppId(),'')

aProperties[7][1] := "IDENTITYURL" // ENDERE�O DO FLUIG IDENTITY (USADO NAS A��ES RELACIONADAS DO FORMUL�RIO)
aProperties[7][2] := If(FindFunction('FluigIdmUrl'),FluigIdmUrl(),'')

Return aProperties

//-------------------------------------------------------------------
/*/{Protheus.doc} MTFluig115
Esta fun��o cria/atualiza qualquer processo no gerador

@author guilherme.pimentel

@since 22/04/2014
@version P12
@return Nil
/*/
//-------------------------------------------------------------------

Function MTFluig115(cCodPrc,cDesPrc,cModel,cView,cModo,cInst,nModulo,aStates,aSequence,aAux)
Local oModel 		:= FWLoadModel('CFGA115')
Local oModelCPF 	:= oModel:GetModel('CPFMASTER')
Local oModelCPG	:= oModel:GetModel('CPGDETAIL')
Local oModelCPU	:= oModel:GetModel('CPUDETAIL')
Local nLineCPG	:= 0
Local nStates		:= 0
Local nX := 0
Local nY := 0
Local lRet			:= .T.

If CPF->(DbSeek(xFilial('CPF')+cCodPrc))
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
Else
	oModel:SetOperation(MODEL_OPERATION_INSERT)
EndIf

If oModel:Activate()
	
	// --------------------------------------------------
	// Processo
	// --------------------------------------------------
	oModelCPF:SetValue('CPF_CODPRC',cCodPrc)
	oModelCPF:SetValue('CPF_DESPRC',cDesPrc)
	oModelCPF:SetValue('CPF_PROPRI','1')
	oModelCPF:SetValue('CPF_MODEL',cModel)
	oModelCPF:SetValue('CPF_VIEW',cView) //Verificar
	oModelCPF:SetValue('CPF_STATUS','1')
	oModelCPF:SetValue('CPF_MODO','1')
	oModelCPF:SetValue('CPF_ATUFOR',.T.)
	oModelCPF:SetValue('CPF_INSTRU',cInst)
	oModelCPF:SetValue('CPF_MODULO',Alltrim(Str(nModulo)))
	
	// --------------------------------------------------
	// Atividades
	// --------------------------------------------------
	For nX:=1 to len(aStates)
		If nX<>1
			oModelCPG:AddLine()
		EndIf
		oModelCPG:SetValue('CPG_ITEM',STRZERO(nX,TamSX3("CPG_ITEM")[1]))
		oModelCPG:SetValue('CPG_DESATV',aStates[nX][2])
		oModelCPG:SetValue('CPG_MECAT',Alltrim(Str(aStates[nX][5])))
		If Str(aStates[nX][5]) == '1'
			oModelCPG:SetValue('CPG_MAGRP',aStates[nX][6])
		ElseIf Str(aStates[nX][5]) == '2'
			oModelCPG:SetValue('CPG_MAUSER',aStates[nX][6])
		EndIf
		
		aStates[nX][8] := oModelCPG:getLine()
		
	Next nX
	
	// --------------------------------------------------
	// Sequencia
	// --------------------------------------------------
	For nX:=1 to len(aSequence)
		//Pegar o item que vai receber a sequencia e posicionar
		nLineCPG := aStates[aScan(aStates,{|x|x[7] == aSequence[nX][1]})][8]  
		oModelCPG:GoLine( nLineCPG )
		
		//Pegar o item que � a proxima sequencia e colocar no CPU dentro de um for
		For nY := 2 to Len(aSequence[nX])
			If nY <> 2
				oModelCPU:AddLine()
			EndIf
			nStates := aScan(aStates,{|x|x[7] == aSequence[nX][nY]})
			oModelCPU:SetValue('CPU_SEQ',oModelCPG:GetValue('CPG_ITEM',aStates[nStates][8]))
		Next nY			
	Next nX
	
EndIf

If oModel:VldData()
	lRet := oModel:CommitData()
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SCProcess
Esta fun��o coloca/atualiza um processo de solicita��o de compras no ECM

@author guilherme.pimentel
@param oModel Modelo de dados
@param nFichaId C�digo do fich�rio

@since 06/02/2014
@version P12
@return Nil
/*/
//-------------------------------------------------------------------

Function SCProcess(oModel,oView,nFichaId)
//FLUIG
Local cProcessId := "MATA110_MVC"
Local cDescription := STR0023//"Solicitacoes"
Local cInstruction := STR0023//"Solicitacoes"
Local nFormId := nFichaId // id do fich�rio adicionado no ECM no passo anterior
Local aStates := {} // atividades do processo em sequencia para cria��o autom�tica dos fluxos
Local aEvents := {} // eventos que ser�o customizados para o processo
Local aProperties := {} // propriedades que ser�o utilizadas nos scripts dos eventos do processo
Local aSequence := {} //Array de defini��o do fluxo do processo
Local aError
Local nMv_TimeFlg := SuperGetMv('MV_TIMEFLG',.F.,14400)

aAdd(aStates,{STR0024,; // atividade //'In�cio'
              STR0024,; // descri��o //'In�cio'
              "",; // instru��es
              60,; //prazo de conclus�o em segundos
              0,; // mecanismo de atribui��o (zeoro para nenhum, 1 para grupo ou 2 para usu�rio)
              ""}) // c�digo do grupo ou usu�rio no ECM caso o mecanismo de atribui��o seja diferente de zero
                  
aAdd(aStates,{STR0025,; // atividade //'Aprova��o'
              STR0025,; // descri��o //'Aprova��o'
              "",; // instru��es
              60,; //prazo de conclus�o em segundos
              0,; // mecanismo de atribui��o (zeoro para nenhum, 1 para grupo ou 2 para usu�rio)
              ""}) // c�digo do grupo ou usu�rio no ECM caso o mecanismo de atribui��o seja diferente de zero

aAdd(aStates,{STR0026,; // atividade //'Fim'
              STR0026,; // descri��o //'Fim'
              "",; // instru��es
              nMV_TimeFlg,; //prazo de conclus�o em segundos
              0,; // mecanismo de atribui��o (zeoro para nenhum, 1 para grupo ou 2 para usu�rio)
              ""}) // c�digo do grupo ou usu�rio no ECM caso o mecanismo de atribui��o seja diferente de zero

aAdd(aSequence,{1,2})
aAdd(aSequence,{2,3})

//EVENTOS
aEvents := MTaEvtDef()
      
//PROPRIEDADES
aProperties := MTaPropDef(oModel,oView)
        
FWECMProcess(cProcessId, cDescription, cInstruction, nFormId, aStates, aEvents, aProperties, aSequence,.F.)

If FWWFIsError()
	aError := FWWFGetError()
    MsgStop(aError[2])
Else
	Conout(STR0018) //'Processo Importado com sucesso'
EndIf


MsgInfo(STR0007)//"Processo finalizado!"


Return

/*-------------------------------------------------------------------
{Protheus.doc} CFGSmartPr
Atualiza o processo definido no configurador de processos CFGA115

@author Alex Egydio
@since 21/02/2014
@version P12
-------------------------------------------------------------------*/
Function CFGSmartPr(oModel,oView,nFichaId)
Local aAux			:= {}
Local aStates		:= {} // Atividades do processo em sequencia para cria��o autom�tica dos fluxos
Local aEvents		:= {} // Eventos que ser�o customizados para o processo
Local aSequence	:= {} // Array de defini��o do fluxo do processo
Local aSeqRet		:= {} // Array de defini��o da Sequencia de Retorno
Local aProperties	:= {} // Propriedades que ser�o utilizadas nos scripts dos eventos do processo
Local aErro		:= {}
Local aSeqAux		:= {}
Local aSeqRetAux	:= {}
Local cProcessId	:= ""
Local cDescription:= ""
Local cInstruction:= ""
Local cProx		:= ""
Local cMecAt		:= ""
Local cUpdStates	:= ""
Local lFind		:= .F.
Local n1Cnt		:= 0
Local n2Cnt		:= 0
Local nPos			:= 1
Local oModelCPF	:= oModel:GetModel("CPFMASTER")
Local oModelCPG	:= oModel:GetModel("CPGDETAIL")
Local oModelCPU	:= oModel:GetModel("CPUDETAIL")
Local lRet			:= .T.
Local nModuloAnt	:= nModulo
Local aStateColumns	:= {'sequence','version','agreementPercentage'}
Local aStateValues	:= {}
Local nSequence	:= 0
Local cUpdSolic	:= ""
Local lUpdStates := oModelCPG:GetStruct():HasField('CPG_ATUPRT')
Local lUpdSolic := oModelCPG:GetStruct():HasField('CPG_DSCATV')
Local nMv_TimeFlg := SuperGetMv('MV_TIMEFLG',.F.,14400)
Local lAtuProtheus:= oModelCPF:GetStruct():HasField('CPF_ATUPRT')

nModulo := Val(oModelCPF:GetValue('CPF_MODULO'))

oModelCPG:GoLine(1)

For n1Cnt := 1 To oModelCPG:Length(.T.)
	oModelCPG:GoLine(n1Cnt)
	AAdd(aAux,{oModelCPG:GetValue('CPG_ITEM'),nPos})
	nPos += 1
Next
// --------------------------------------------------
// Elaboracao do array de posicoes e fluxos
// --------------------------------------------------
For n1Cnt := 1 To oModelCPG:Length(.T.)
	oModelCPG:GoLine(n1Cnt)
	nPos := AScan(aAux,{|x|x[1]==oModelCPG:GetValue('CPG_ITEM')})
	If	nPos > 0
		// --------------------------------------------------
		// Define mecanismo de atribui��o
		// --------------------------------------------------
		If oModelCPG:GetValue('CPG_MECAT') = '1'
			cMecAt := oModelCPG:GetValue('CPG_MAGRP')
		ElseIf oModelCPG:GetValue('CPG_MECAT') = '2'
			cMecAt := FWWFColleagueId(oModelCPG:GetValue('CPG_MAUSER'))
			If Empty(cMecAt)
				cMecAt := "000000"
			EndIf	
		ElseIf oModelCPG:GetValue('CPG_MECAT') = '3'
			cMecAt := Alltrim(oModelCPG:GetValue('CPG_MCPO'))
		Else
			cMecAt := ''
		EndIf
		// --------------------------------------------------
		// Insere etapas do processo
		// --------------------------------------------------
		nSequence++
		AAdd(aStates,{oModelCPG:GetValue('CPG_DESATV'),; // atividade
						oModelCPG:GetValue('CPG_DESATV'),; // descri��o
						"",; // instru��es
						nMV_TimeFlg,; //prazo de conclus�o em segundos
						Val(oModelCPG:GetValue('CPG_MECAT')),; // mecanismo de atribui��o (zero para nenhum, 1 para grupo ou 2 para usu�rio)
						cMecAt,; // c�digo do grupo ou usu�rio no ECM caso o mecanismo de atribui��o seja diferente de zero
						nSequence,;
						oModelCPG:GetValue('CPG_ATVCOM'),;
						Max(oModelCPG:GetValue('CPG_CONSEN'),1)})
		
		If oModelCPG:GetValue('CPG_ATVCOM')
			Aadd(aStateValues, {nSequence,'1',oModelCPG:GetValue('CPG_CONSEN')})
		EndIf
		
		// --------------------------------------------------
		// Etapas definidas para o fluxo
		// --------------------------------------------------
		aSeqAux := {}
		aSeqRetAux := {}
		oModelCPU:GoLine(1)
		If AScan(aAux,{|x|x[1]==oModelCPU:GetValue('CPU_SEQ')}) > 0
			AAdd(aSeqAux,nPos)
			For n2Cnt := 1 to oModelCPU:Length()
				oModelCPU:GoLine(n2Cnt)
				AAdd(aSeqAux,AScan(aAux,{|x|x[1]==oModelCPU:GetValue('CPU_SEQ')}))
				AAdd(aSeqRetAux,oModelCPU:GetValue('CPU_PERRET'))
			Next n2Cnt
			AAdd(aSequence,aSeqAux)
			AAdd(aSeqRet,aSeqRetAux)
		EndIf
		// --------------------------------------------------
		// Verifica��o se atualiza Protheus
		// --------------------------------------------------
		If lUpdStates .and. oModelCPG:GetValue('CPG_ATUPRT')
			If Empty(cUpdStates)
				cUpdStates += '|'
			EndIf
			cUpdStates += AllTrim(Str(nSequence)) + '|'
		EndIf
		
		// --------------------------------------------------
		// Verifica��o se a etapa sempre ter� descida do Fluig para o Protheus
		// --------------------------------------------------
		If lUpdSolic .and. oModelCPG:GetValue('CPG_DSCATV') == '1'
			If Empty(cUpdSolic)
				cUpdSolic += '|'
			EndIf
			cUpdSolic += AllTrim(Str(nSequence)) + '|'
		EndIf
	EndIf
Next

If lAtuProtheus .And. oModelCPF:GetValue('CPF_ATUPRT') == '2'
	cUpdStates := '|0|'
Endif

// Preven��o para n�o enviar chave vazia, criticas em BD Oracle
If lUpdSolic .And. Empty(cUpdSolic)
	cUpdSolic := '|0|'
Endif

// --------------------------------------------------
// Eventos
// --------------------------------------------------
aEvents := MTaEvtDef()
// --------------------------------------------------
// Propriedades
// --------------------------------------------------
aProperties := MTaPropDef(oModel,;
							  FWLoadView(oModel:GetValue('CPFMASTER','CPF_VIEW')),;
							  AllTrim(oModel:GetValue('CPFMASTER','CPF_MODEL')),;
							  If(oModel:GetValue('CPFMASTER','CPF_ATUFOR'),'1','2'),;
							  cUpdStates,cUpdSolic)
// --------------------------------------------------
// Defini��o dos variaveis de controle atraves do modelo
// --------------------------------------------------
cProcessId		:= AllTrim(oModelCPF:GetValue('CPF_CODPRC'))
cDescription	:= AllTrim(oModelCPF:GetValue('CPF_DESPRC'))
cInstruction	:= AllTrim(oModelCPF:GetValue('CPF_INSTRU'))
// --------------------------------------------------
// Processamento
// --------------------------------------------------
FWECMProcess(cProcessId, cDescription, cInstruction, nFichaId, aStates, aEvents, aProperties, aSequence,.F., aSeqRet)

If FWWFIsError()
   aError := FWWFGetError()
   MsgStop(aError[2])
   lRet := .F.
Else
	FWECMDataSet(cProcessId + '_STATE', aStateColumns, aStateValues)
   Conout(STR0018) //'Processo importado com sucesso!'
   MsgInfo(STR0018)//'Processo importado com sucesso!'
EndIf

nModulo := nModuloAnt

Return lRet

/*/{Protheus.doc} MTFluigAtv()
Fun��o para verificar se um determinado processo do fluig

@param cRotinaWF	Identifica��o da rotina que ser� utilizada para gerar as solicita��es no Fluig. Ex. WFFINA677
@param cCodProc	Identifica��o do processo de WF gerado no Fluig

@return lRet		Retorna se o processo do WF no Fluig est� cadastro e liberado para o ambiente Fluig.    

@author	Marylly Ara�jo Silva
@since	26/11/2015
@version	P12.1.8
@sample	Local lFluig	:= MTFluigAtv("WFFINA785","SOLAPR")
		If lFluig
			WFFINA785( oFWJMdl:GetValue("FWJ_USUCRI"), oFWJMdl:GetValue("FWJ_CODIGO"), MODEL_OPERATION_INSERT, aUser, .F.)
		EndIf	
/*/
Function MTFluigAtv(cRotinaWF,cCodProc,cUserFn)
Local aAreaCPF	:= {}
Local lRet		:= .F.
Local cURLDoc	:= "https://centraldeatendimento.totvs.com/hc/pt-br/articles/360060829373-Descontinua&#xE7;&#xE3;o-de-funcionalidade-para-envio-de-Workflow-em-rotinas-do-Backoffice"

DEFAULT cRotinaWF	:= ""
DEFAULT cCodProc	:= ""
Default cUserFn		:= ""

cRotinaWF := PADR(cRotinaWF, TamSX3("CPF_VIEW")[1]," ")

DbSelectArea("CPF") // Configurador de Processos
aAreaCPF := CPF->(GetArea())
CPF->(DbSetOrder(2)) // Filial + Rotina + Processo

If CPF->(DbSeek(FWxFilial("CPF") + cRotinaWF + cCodProc ))
	If CPF->CPF_STATUS == '2' // Liberado
		If ExistBlock(cUserFn,.F.,.F.)
			lRet := .T.
		Else
			Help(,,"NOWFFLUIG",,STR0035,1,0,,,,,{STR0036}) //"O processo de workflow padr�o dos processos via Fluig foi descontinuado.";
														  // "Saiba como continuar a utiliz�-los na p�gina que ser� aberta em seu navegador."

			ShellExecute("Open", cURLDoc, "", "", 1)
		EndIf
	EndIf
EndIf

RestArea(aAreaCPF)
Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} ProcFlgSCR
Verifica se o processo de Al�ada (SCR) existe no Fluig

@author rd.santos
@since 06/01/2020
@version P12
-------------------------------------------------------------------*/
Function ProcFlgSCR(cProcesso)
Local lRet 		:= .F.
Local cAliasAux	:= GetNextAlias()
Local cTipo 	:= Alltrim(cProcesso)

	BeginSQL Alias cAliasAux

			SELECT 	COUNT(R_E_C_N_O_) AS CNTREC
			FROM 	%Table:SCR% SCR
			WHERE 	SCR.CR_FILIAL 	= %xFilial:SCR%
					AND SCR.CR_TIPO = %Exp:cTipo%
					AND SCR.CR_FLUIG <> %Exp:''%
					AND SCR.%NotDel%
	EndSQL
	

	lRet := (cAliasAux)->CNTREC > 0 //Se for maior que Zero encontrou registro.

	(cAliasAux)->(DbCloseArea())

Return lRet

