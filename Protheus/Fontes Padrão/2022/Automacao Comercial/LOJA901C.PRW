#include 'protheus.ch'
#INCLUDE "LOJA901C.CH"

/*
	Job de envio
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900
Fun��o de teste integracao Protheus e-commerce CiaShop recebimento de cadastros 
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@sample LOJA900
/*/
//-------------------------------------------------------------------

User Function ECOM0017 //Teste e-commerce

	Loja901C("T1", "D MG 01")
	
REturn

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900
Fun��o de teste integracao Protheus e-commerce CiaShop recebimentod de cadastros
@param   	aParam - Array contendo os dados de execu��o em Schedule onde: [1] - Empresa, [2] - Filial, [4] - Tarefa
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA900()
/*/
//-------------------------------------------------------------------
Function LOJA901C(uParam, cFil)
local _lJob := .F. //Execu��o em Job
Local _cEmp := nil //Empresa
Local _cFil := nil //Filial
Local cFunction := "LOJA901C" //Rotina
Local lLock := .F. //Bloqueado
Local oLJCLocker	:= Nil               		// Obj de Controle de Carga de dados
Local lCallStack := .T. 							//Se esta rotina estiver configurada, independente de job ou scheduler, ser� considerada uma pilha de chamadas
Local cName := "" //Chave de travamento
Local cMessage := ""

DEFAULT uParam := nil
DEFAULT cFil := NIL

If Valtype(uParam) != "A" 
	If ValType(uParam) <> "C" .AND. !Empty(cEmpAnt)
		_cEmp := cEmpAnt
		_cFil := cFilant
	Else
		_cEmp := uParam
		_cFil := cFil
		_lJob  := .T.
	EndIf
Else

	_lJob :=  .T.
	_cEmp := uParam[1]
	_cFil := uParam[2]
EndIf

//Aguarda para evitar erro de __CInternet
Sleep(5000)

If _lJob 
	RPCSetType(3)     
	RpcSetEnv(_cEmp, _cFil,,,"LOJ" ) 	// Seta Ambiente
EndIf

//Gera SEMAFORO - para n�o dar erro de execu��o simultanea
oLJCLocker  := LJCGlobalLocker():New()
cName := cFunction+cEmpAnt+cFilAnt

lLock := oLJCLocker:GetLock( cName )

If lLock  

	If  ExistFunc("Lj904IntOk") //Verifica os parametros b�sicos da integra��o e-commerce CiaShop
		If  !Lj904IntOk(.T., @cMessage)
			Lj900XLg(cMessage,"") 	
		EndIf
	EndIf

	Lj900XLg(STR0001 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + STR0002 + DTOC(Date()) + " - " + Time() ) //"INICIO DO PROCESSO "###" - EM: "
	
	LJ901CPr(_lJob, lCallStack)
	
	Lj900XLg(STR0003 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + STR0002 + DTOC(Date()) + " - " + Time()) //"FIM DO PROCESSO "######" - EM: "###" - "
	
Else
	If !IsBlind()
		MsgAlert(STR0004 + cFunction + "[" + cEmpAnt+cFilAnt + "]" ) //"J� existe execu��o da rotina"
	EndIf

	Lj900XLg( STR0004 + cFunction + "[" + cEmpAnt+cFilAnt + "]"   )	 //"J� existe execu��o da rotina"
EndIf

If lLock
	oLJCLocker:ReleaseLock( cName )
EndIf

If _lJob
	RPCClearEnv()
EndIF


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ901CPr(_lJob, lCallStack)
Fun��o de teste integracao Protheus e-commerce CiaShop recebimendo de dados
@param   	lAJob- Execu��o em Job - Default .f.
@param		lCallStack - Execu��o em pilha de chamadas default .F.
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LJ900Pr(.F.)
/*/
//-------------------------------------------------------------------
Function LJ901CPr(lAJob, lCallStack) 

	Local cSeq      := "" //Sequencia de Execu��o
	Local lErro     := .F. //Erro WS
	Local dDataIni := Date() //Data Inicial do Job
	Local cHoraIni := Time() //Hora Inicial do Job

	Default lAJob := .F.
	Default lCallStack := .F.

	//Resultado da sincroniza��o
	cSeq := GETSXENUM("MGM","MGM_SEQ")
	CONFIRMSX8()
	
	//Prepara a exeu��o das rotinas
	//Pedido
	LOJA901A(lCallStack)
	//Pilha de chamadas da rotina LOJA901A:
		//LOJA901 - Clientes
		//LOJA901A - Pedidos
		//Lj901BPr - Dados complementares de Pedido
		
	dbSelectArea("MGM")
	RECLOCK("MGM", .T.)
	MGM->MGM_FILIAL  := xFilial("MGM")
	MGM->MGM_SERVIC := "LOJA901C"
	MGM->MGM_SEQ     := cSeq
	MGM->MGM_DATA    := dDataIni
	MGM->MGM_HORAIN  := cHoraIni
	MGM->MGM_XMLENV := ""
	MGM->MGM_XMLRET  := ""
	MGM->MGM_HORAFI := Time()
	IF !lErro
		MGM->MGM_RESULT := "1"
	Else
		MGM->MGM_RESULT := "2"
	EndIF
	MGM->( msUnLock() )

Return 