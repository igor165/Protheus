#INCLUDE "LOJA901B.ch"
#Include 'Protheus.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA901
Função de teste integracao Protheus e-commerce CiaShop recebimento de Pedidos
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@sample LOJA901A
/*/
//-------------------------------------------------------------------

User Function ECOM013 //Teste e-commerce

	aParam := {"T1","D MG 01",,"DEBUG"}
	Loja901B(aParam)
	
REturn

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA901B
Função de teste integracao Protheus e-commerce CiaShop recebimento de Pedidos -dados extras
@param   	aParam - Array contendo os dados de execução em Schedule onde: [1] - Empresa, [2] - Filial, [4] - Tarefa
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA901B(aParam)
/*/
//-------------------------------------------------------------------
Function LOJA901B(aParam)
local _lJob := .F. //Execução em Job
Local _cEmp := nil //Empresa
Local _cFil := nil //Filial
Local cFunction := "LOJA901B" //Rotina
Local lLock := .F. //Bloqueado
Local oLJCLocker	:= Nil               		// Obj de Controle de Carga de dados
Local lCallStack := .F. 							//Chamada de uma pilha de chamadas (1 job que chama todas as rotinas)
Local cName := "" //Chave de travamento
Local cMessage := ""

If Valtype(aParam) != "A" 
	_cEmp := cEmpAnt
	_cFil := cFilant
	
	If Valtype(aParam) = "L"
		lCallStack := aParam
	EndIf
Else

	_lJob :=  .T.
	_cEmp := aParam[1]
	_cFil := aParam[2]
EndIf



If _lJob 
	RPCSetType(3)     
	RpcSetEnv(_cEmp, _cFil,,,"LOJ" ) 	// Seta Ambiente
EndIf


//Gera SEMAFORO - para não dar erro de execução simultanea
oLJCLocker  := LJCGlobalLocker():New()
cName := cFunction+cEmpAnt+cFilAnt

lLock := oLJCLocker:GetLock( cName )

If lLock

	If  ExistFunc("Lj904IntOk") //Verifica os parametros básicos da integração e-commerce CiaShop
		If  !lCallStack .AND. !Lj904IntOk(.T., @cMessage)
			Lj900XLg(cMessage,"") 	
		EndIf
	EndIf

	Lj900XLg(STR0001 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + IIF(_lJob, STR0002 + aParam[4] , STR0003) + " - EM: " + DTOC(Date()) + " - " + Time() ) //"INICIO DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "
	
	Lj901BPr(_lJob, , ,lCallStack)
	
	Lj900XLg(STR0004 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + IIF(_lJob, STR0002 + aParam[4] , STR0003) + STR0005 + DTOC(Date()) + " - " + Time()) //"FIM DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
Else
	If !IsBlind()
		MsgAlert(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]" )
	EndIf

	Lj900XLg(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + IIF(_lJob, STR0002 + aParam[4], STR0003) )	 //"JÁ EXISTE EXECUÇÃO DA ROTINA "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "
EndIf

If lLock
	oLJCLocker:ReleaseLock( cName )
EndIf

If _lJob
	RPCClearEnv()
EndIF


Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901BPr
Função de teste integracao Protheus e-commerce CiaShop recebimento de Pedidos - Dados extras 
@param   	lAJob - Job default .t.
@param   	cOrderID - Pedido
@param   	oWS - WebService
@param   	lCallStack - Chamada de Outra rotina
@param   	cEntity - Nome da entidade
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj901BPr(lAJob,cOrderID, oWS)
/*/
//-------------------------------------------------------------------
Function Lj901BPr(lAJob,cOrderID, oWS, lCallStack, cEntity)

Local cXML     := "" //XML envio
Local cError   := "" //Erro
Local cWarning := "" //Alerta
Local oRetXML	:= NIL //Retorno parseado
Local lErro    := .F. //Erro
Local cRetorno := "" //String de Retorno


Default lAJob := .T.
Default cOrderID := ""  
Default oWS := lj904WS()   
Default lCallStack := .F.
Default cEntity := "order"

If cOrderID <> ""

	cXML += ' <campo_extra_filtro xmlns="" entidade="' + cEntity +'" entidade_id="'+cOrderID+'" pacote="system"/>'

Endif

if !Empty(cXML)
	cXML := '<?xml version="1.0" encoding="utf-8" standalone="no" ?>' +;
	'<campos_extras_filtroList xmlns="dsReceipt.xsd">' +;
	cXML +;
	'</campos_extras_filtroList>'
endif

//Consome método
if !oWs:CamposExtras(, , @cXML)
	lErro := .T.
else
	iif(!lAJob, MemoWrit('retornoCamposExtra.xml', oWs:cXml), )
	//Retorna o XML parseado em um objeto com as tags em variáveis
	oRetXML := XmlParser( FwNoAccent(oWs:cXml), "_", @cError, @cWarning)

	IF !Empty(cError)
		cRetorno := STR0008 + Chr(13) + cError //"Erro no método XmlParser: "
		cRetorno += Chr(13) + "XML: " + oWs:cXml
		lErro := .T.
	Else
		cRetorno := oWs:cXml
	endif
endif

Return oRetXML 
 