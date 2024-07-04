#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA530B.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSLARegisteบAutor  ณVendas Clientes     บ Data ณ  07/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDescreve um registro de SLA (Acordo de Nivel de Servico).   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class SLARegister
Data registerID
Data item
Data keyInfo
Data details
Data entities
Data createdDate
Data createdHour
Data dateToExpire
Data hourToExpire
Data finishedDate
Data finishedHour
Data previousCode
Data updatedDate
Data updatedHour
Data severityCode
Data SlaFound
Data SlaResponsible
Data OldRegister
Data StatusRegister
Data cbWhenDelayed
Data Paused
Data PausedTime
Data oPersist
Data dateTimeToExpire

Method new() Constructor                 
Method load(registerID, keyInfo, item)
Method save()
Method delete()
Method createPersist()
Method start(entities, severityCode, codProtheusUser, funcName, cTimeShift, cDtInicioSLA, cHrInicioSLA, nTimePaused, lReproSLA, cDtExpRepro, cHrExpRepro)
Method update(entities, severityCode, codProtheusUser, cNewSLA, lToPause, cTimeShift, nForcePause, lReproSLA)
Method pause(entities, severityCode, codProtheusUser, cNewSLA, cTimeShift)
Method finish()
Method getNextResponsible()
Method findSLA(entities)
Method findSeverity(cSLA, severityCode)
Method getExpireDateTime()  
Method getTimeElapsed(oDTStart, oDTFinished, cTurno)
Method getTimeShift()
Method getTerm()
Method free()

EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณNew          บAutor  ณ Vendas Clientes บ Data ณ  16/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe SLARegister                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method new() Class SLARegister
Self:registerID			:= ""
Self:item				:= ""
Self:keyInfo	   		:= ""
Self:details	  		:= ""
Self:entities	  		:= {}
Self:createdDate  		:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
Self:createdHour   		:= ""
Self:dateToExpire  		:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
Self:hourToExpire		:= ""
Self:finishedDate		:= ""
Self:finishedHour  		:= ""
Self:previousCode  		:= ""
Self:updatedDate   		:= ""
Self:updatedHour   		:= ""
Self:severityCode  		:= 0
Self:SlaFound	   		:= ""
Self:SlaResponsible		:= ""
Self:OldRegister		:= ""
Self:StatusRegister		:= "0"
Self:cbWhenDelayed		:= ""
Self:oPersist 			:= Self:createPersist() 
Self:PausedTime			:= 0 
Self:Paused				:= .F.
Self:dateTimeToExpire	:= TMKDateTime():New()

Return Self


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณload      บAutor  ณVendas Clientes     บ Data ณ  16/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo que aciona a operacao de carregar registro de SLA   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method load(registerID, keyInfo, item) Class SLARegister
Local lRet := .F.			//Variavel de retorno do metodo

Default keyInfo := ""		//Campo Opcional

Self:registerID := registerID
Self:keyInfo	:= keyInfo  
Self:item		:= item

lRet := Self:oPersist:load(Self)
If !lRet 
	Self:registerID := ""
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณsave      บAutor  ณVendas Clientes     บ Data ณ  16/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo que aciona a operacao de salvar registro de SLA     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method save() Class SLARegister
Local lRet := .F.			//Variavel de retorno do metodo

lRet := Self:oPersist:save(Self)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณdelete    บAutor  ณVendas Clientes     บ Data ณ  16/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo que aciona a operacao de excluir registro de SLA    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method delete() Class SLARegister
Local lRet := .F.			//Variavel de retorno do metodo

lRet := Self:oPersist:delete(Self)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณcreatePersist บAutor  ณVendas Clientes บ Data ณ  16/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a classe de acesso ao banco de dados.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method createPersist() Class SLARegister
Local obj			//Objeto de retorno da classe de Persistencia

obj := SLARegisterTop():New()

Return obj


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณstart			บAutor  ณVendas Clientes บ Data ณ  16/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicia um novo registro de SLA                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method start(entities, severityCode, codProtheusUser, funcName, cTimeShift, cDtInicioSLA, cHrInicioSLA, nTimePaused, lReproSLA, cDtExpRepro, cHrExpRepro) Class SLARegister

Local lRet			:= .T.				// Indica se encontrou SLA
Local oSLA 			:= SLA():New()		// Obj. da classe SLA
Local dDataExpir	:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )			// Data p/ expirar o registro de SLA
Local cHoraExpir	:= Time()			// Hora p/ expirar o registro de SLA
Local nSomaHs		:= 0				// Nr. de horas faltantes p/ o SLA expirar 
Local oDateTime		:= Nil				// DateTime para o cแlculo da data de expira็ใo
Local lTk530HRE  	:= ExistBlock("TK530HRE")
Local nNewSomaHs 	:= 0

Default funcName := ""
Default lReproSLA 	:= .F.				// Indica se houve uma reprograma็ใo no prazo do SLA no chamado
Default cDtExpRepro := If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )	// Data de expira็ใo ap๓s a reprograma็ใo
Default cHrExpRepro := Time()			// Hora de expira็ใo ap๓s a reprograma็ใo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicia e preenche os dados do novo registro de SLA ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณData e Hora de Inicio do SLA sao recebidos e passados por valor para suporte aosณ
//ณcasos de transferencia de chamados entre filiais. Sera criado um novo registro  ณ
//ณcom base no contrato de SLA da filial destino mas serao mantidos a data, a hora ณ
//ณinicial assim como o montante de tempo de pausa passados pela filial origem.    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Self:createdDate	:= If(Empty(cDtInicioSLA),If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ),cDtInicioSLA)
Self:createdHour	:= If(Empty(cHrInicioSLA),Time(),cHrInicioSLA)
Self:PausedTime		:= If(Empty(nTimePaused),0,nTimePaused)
Self:cbWhenDelayed	:= funcName

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se o respons. nao for informado, pega o respons. pelo contrato de SLA ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(codProtheusUser)
	oSLA:load( Self:SlaFound )
	Self:SlaResponsible	:= oSLA:responsible
Else
	Self:SlaResponsible	:= codProtheusUser
EndIf

If !lReproSLA
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Busca o nr. de horas da sev. e calcula data/hora para o SLA expirar ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	dDataExpir	:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
	cHoraExpir	:= Time()
	DbSelectArea("SK9")
	DbSetOrder(1)	//K9_SEVE + K9_CODSLA
	If DbSeek(xFilial("SK9") + Padr(Self:severityCode,TamSX3("K9_SEVE")[1]) + Self:SlaFound)
		nSomaHs	:= SK9->K9_HREXPIR

		If lTk530HRE
			nNewSomaHs := ExecBlock("TK530HRE", .F., .F., { nSomaHs })
			If ValType(nNewSomaHs) == "N" .And. nNewSomaHs > 0
				nSomaHs := nNewSomaHs
			EndIf
		EndIf
			
		If cTimeShift == Nil .Or. Empty(cTimeShift)
			cTimeShift := Self:getTimeShift(SK9->K9_CODSLA)
		EndIf
		If cTimeShift == Nil .Or. Empty(cTimeShift)
			SomaDiaHor(@dDataExpir, @cHoraExpir, nSomaHs)
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Verifica se deve calcular o vencimento para dias uteis 	   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea("SK6")
			DbSetOrder(1) 	//K6_CODSLA
			If DbSeek(xFilial("SK6") + SK9->K9_CODSLA) .AND. SK6->K6_DSUTEIS == '1'
				dDataExpir := DataValida(dDataExpir) 
			EndIf
			Self:dateToExpire	:= dDataExpir
			Self:hourToExpire	:= cHoraExpir + ":00"
		Else
			If Self:dateTimeToExpire:getDate() == cToD("01/01/01")
				oDateTime := TMKDateTime():this(If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ), Time())
				oDateTime := Self:getExpireDateTime(oDateTime, cTimeShift, nSomaHs)
				Self:dateToExpire	:= oDateTime:getDate()
				Self:hourToExpire	:= oDateTime:getTime()
			Else
				Self:dateToExpire	:= Self:dateTimeToExpire:getDate()
				Self:hourToExpire	:= Self:dateTimeToExpire:getTime()
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Calcula o novo prazo de vencimento, onde ้ ignorado as severidades ณ
	//ณ do contrato, pois tem que ser respeitado a data/hora que foram     ณ
	//ณ informados na reprograma็ใo do prazo do SLA (TMK006).			   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dDataExpir	:= cDtExpRepro
	cHoraExpir	:= cHrExpRepro

	If cTimeShift == Nil .Or. Empty(cTimeShift)
		SomaDiaHor(@dDataExpir, @cHoraExpir, nSomaHs)	
		dDataExpir := DataValida(dDataExpir) 
		Self:dateToExpire	:= dDataExpir
		Self:hourToExpire	:= cHoraExpir + ":00"
	Else	
		oDateTime := TMKDateTime():This(dDataExpir, cHoraExpir)
		oDateTime := Self:getExpireDateTime(oDateTime, cTimeShift, nSomaHs) 
		Self:dateToExpire	:= oDateTime:getDate()
		Self:hourToExpire	:= oDateTime:getTime()				
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณupdate		บAutor  ณVendas Clientes บ Data ณ  16/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza o prazo do SLA, esta opera็ใo devera finalizar o   บฑฑ
ฑฑบ          ณcontrole de SLA anterior, localizar um novo SLA e escolher  บฑฑ
ฑฑบ          ณo prazo do SLA conforme a severidade informada.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method update(entities, severityCode, codProtheusUser, cNewSLA, lToPause, cTimeShift, nForcePause, lReproSLA) Class SLARegister
Local cOldSLARegister	:= Self:registerID		// Cod. do registro do SLA anterior (origem)
Local dCreatedDate		:= Self:createdDate		// Data de criacao do SLA (mantem-se na atualizacao)
Local dCreatedHour		:= Self:createdHour		// Hora de criacao do SLA (mantem-se na atualizacao)
Local cFuncName			:= Self:cbWhenDelayed	// Code block a exeuctar quando o SLA estiver atrasado
Local lRet 				:= .T.					// Indica retorno da funcao
Local lPaused			:= .F.					// Se o registro encerrado foi pausado
Local oSLA 				:= SLA():New()			// Obj. da classe SLA
Local dDataExpir		:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )				// Data p/ expirar o registro de SLA
Local cHoraExpir		:= Time()				// Hora p/ expirar o registro de SLA
Local nSomaHs			:= 0					// Nr. de horas faltantes p/ o SLA expirar
Local oDateTime			:= Nil					// DateTime para o cแlculo da data de expira็ใo do SLA.
Local nPausedTime		:= 0
Local oPausedDate
Local oUpdateDate
Local lTk530HRE  		:= ExistBlock("TK530HRE")
Local nNewSomaHs 		:= 0

Default lToPause := .F. 
Default lReproSLA := .F.						// Indica se houve uma reprograma็ใo no prazo do SLA no chamado

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o turno do contrato, caso nใo seja informado.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cTimeShift == Nil .Or. Empty(cTimeShift)
	cTimeShift := Self:getTimeShift(cNewSLA)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o registro estiver pausado, pega o tempo da pausa, paraณ
//ณque possa ser adicionado no total de horas disponํveis.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Self:Paused

	lPaused		:= .T.

	If nForcePause == Nil
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณProcura o registro anterior a pausa para pegar a data de atualiza็ใo dele.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SK5")
		DbSetOrder(1)
		If DbSeek( xFilial("SK5") + Self:previousCode + Self:item )
			oPausedDate := TMKDateTime():This(SK5->K5_DTATUA, SK5->K5_HRATUA)
			oUpdateDate := TMKDateTime():This(If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ), Time())
			nPausedTime := Self:getTimeElapsed(oPausedDate, oUpdateDate, cTimeShift)
		Else
			nPausedTime := 0
		EndIf
	Else
		nPausedTime := nForcePause
	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Encerrar o controle de SLA anterior ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Self:finish()
Self:save()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Limpar os atributos do objeto para iniciar um novo registro de SLA	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Self:registerID		:= ""
Self:item			:= ""
Self:keyInfo		:= ""
Self:details		:= ""
Self:createdDate	:= dCreatedDate
Self:createdHour	:= dCreatedHour
If !lToPause
	Self:dateToExpire	:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
	Self:hourToExpire	:= ""
EndIf
Self:finishedDate	:= ""
Self:severityCode	:= severityCode
Self:SlaFound		:= cNewSLA
Self:SlaResponsible	:= ""
Self:OldRegister	:= cOldSLARegister
Self:cbWhenDelayed	:= cFuncName

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe for para pausar o registro SLA.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (lToPause)
	Self:StatusRegister	:= "2"
	Self:Paused		:= .T.
Else
	Self:StatusRegister	:= "0"
	Self:Paused	:= .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o registro estava pausado antes.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lPaused
	Self:PausedTime 	+= nPausedTime
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se o respons. nao for informado, pega o respons. pelo contrato de SLA ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(codProtheusUser)
	oSLA:load( Self:SlaFound )
	Self:SlaResponsible	:= oSLA:responsible
Else
	Self:SlaResponsible	:= codProtheusUser
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Busca o nr. de horas a partir da severid. e calcula data/hora para  ณ
//ณ o novo registro de SLA expirar 										ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
If !lToPause
	If !lReproSLA
		dDataExpir	:= dCreatedDate
		cHoraExpir	:= dCreatedHour
		DbSelectArea("SK9")
		DbSetOrder(1)	//K9_SEVE + K9_CODSLA
		If DbSeek(xFilial("SK9") + Padr(severityCode,TamSX3("K9_SEVE")[1]) + cNewSLA)
			nSomaHs	:= SK9->K9_HREXPIR

			If lTk530HRE
				nNewSomaHs := ExecBlock("TK530HRE", .F., .F., { nSomaHs })
				If ValType(nNewSomaHs) == "N" .And. nNewSomaHs > 0
					nSomaHs := nNewSomaHs
				EndIf
			EndIf
			
			nSomaHs += Self:PausedTime		
	
			If cTimeShift == Nil .Or. Empty(cTimeShift)
				SomaDiaHor(@dDataExpir, @cHoraExpir, nSomaHs)	
			
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Verifica se deve calcular o vencimento para dias uteis 	   ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				DbSelectArea("SK6")
				DbSetOrder(1) 	//K6_CODSLA
				If DbSeek(xFilial("SK6") + SK9->K9_CODSLA) .AND. SK6->K6_DSUTEIS == '1'
					dDataExpir := DataValida(dDataExpir) 
				EndIf
				Self:dateToExpire	:= dDataExpir
				Self:hourToExpire	:= cHoraExpir + ":00"
			Else
				If Self:dateTimeToExpire:getDate() == cToD("01/01/01")
					oDateTime := TMKDateTime():This(dCreatedDate, dCreatedHour)
					oDateTime := Self:getExpireDateTime(oDateTime, cTimeShift, nSomaHs)
					Self:dateToExpire	:= oDateTime:getDate()
					Self:hourToExpire	:= oDateTime:getTime()
				Else
					Self:dateToExpire	:= Self:dateTimeToExpire:getDate()
					Self:hourToExpire	:= Self:dateTimeToExpire:getTime()
				EndIf
			EndIf
		Else
			lRet := .F.
		EndIf
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Calcula o novo prazo de vencimento, onde ้ ignorado as severidades ณ
		//ณ do contrato, pois tem que ser respeitado a data/hora que foram     ณ
		//ณ informados na reprograma็ใo do prazo do SLA (TMK006).			   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dDataExpir	:= SK5->K5_DTEXPIR
		cHoraExpir	:= SK5->K5_HREXPIR

		If lPaused
			nSomaHs	:= nPausedTime
		EndIf
		
		If cTimeShift == Nil .Or. Empty(cTimeShift)
			SomaDiaHor(@dDataExpir, @cHoraExpir, nSomaHs)	
			dDataExpir := DataValida(dDataExpir) 
			Self:dateToExpire	:= dDataExpir
			Self:hourToExpire	:= cHoraExpir + ":00"
		Else	
			oDateTime := TMKDateTime():This(dDataExpir, cHoraExpir)
			oDateTime := Self:getExpireDateTime(oDateTime, cTimeShift, nSomaHs) 
			Self:dateToExpire	:= oDateTime:getDate()
			Self:hourToExpire	:= oDateTime:getTime()				
		EndIf	
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณpause 	บ Autor  ณVendas Clientes บ Data ณ  16/01/08      บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPausa o prazo do SLA, esta opera็ใo devera finalizar o      บฑฑ
ฑฑบ          ณcontrole de SLA anterior, localizar um novo SLA e escolher  บฑฑ
ฑฑบ          ณo prazo do SLA conforme a severidade informada.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method pause(entities, severityCode, codProtheusUser, cNewSLA, cTimeShift) Class SLARegister
Local lRet 				:= .T.					//Indica retorno da funcao

lRet := Self:update(entities, severityCode, codProtheusUser, cNewSLA, .T., cTimeShift)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณfinish		บAutor  ณVendas Clientes บ Data ณ  16/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEncerrar controle de SLA e processos relacionados           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method finish() Class SLARegister
Self:finishedDate	:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
Self:details		:= STR0001 //"Registro de SLA encerrado"
Self:StatusRegister	:= "2"		//status de encerrado

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณfindSLA		บAutor  ณVendas Clientes บ Data ณ  16/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLocaliza o contrato de SLA que mais se aproxime das         บฑฑ
ฑฑบ          ณentidades informadas no Servico de SLA                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method findSLA(entities) Class SLARegister
Local nI	 		:= 0		//Usada em lacos For...Next
Local nPesoEntid	:= 0		//Peso total das entidades do SLA
Local cAlias 		:= "SK7"	//Alias do arquivo de Entidades
Local cCodSLA		:= ""		//Codigo de contrato de SLA encontrado
Local aSLAEntid		:= {}		//Array de SLA x Total de Entidades
Local cPrecedSLA	:= SuperGetMV("MV_SLAENTI",,"1")
Local nValPeso 		:= 0		//Indica o peso da entidade corrente
Local nEnt			:= 0		//Indica a entidada atual
Local lExistEnt		:= .T.		//Indica se encontrou as entidades
Local cValue		:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Efetua a busca em todas as entidades informadas 			 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nI := 1 To Len(entities)
	If ValType(entities[nI]:entityValue) <> "C"
		cValue	:= AllTrim(Str(entities[nI]:entityValue))
	Else
		cValue	:= entities[nI]:entityValue
	EndIf
	
	cAlias 	:=	GetNextAlias()
	BeginSQL alias cAlias
		SELECT 	K7_CODSLA,	K7_NOMEENT, K7_CODENT,	K7_PESO
		FROM	%table:SK7% SK7
		WHERE	SK7.K7_FILIAL = %xFilial:SK7% AND
		SK7.%NOTDEL% AND
		((SK7.K7_NOMEENT = %EXP:entities[nI]:entityName% AND
		RTrim(SK7.K7_CODENT) = %EXP:RTrim(cValue)%) OR
		(SK7.K7_NOMEENT = %EXP:entities[nI]:entityName% AND SK7.K7_CODENT = ' '))
	EndSql
	
	While (cAlias)->(!Eof())
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica se o Contrato esta Ativo e dentro da vigencia ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SK6")
		DbSetOrder(1)
		If DbSeek(xFilial("SK6")+(cAlias)->K7_CODSLA)
			If	( SK6->K6_STATUS <> '1' ) .OR. ;	//Status Inativo
				( !Empty(SK6->K6_INIVIG) .AND. SK6->K6_INIVIG > dDataBase ) .OR. ;
					( !Empty(SK6->K6_FIMVIG) .AND. SK6->K6_FIMVIG < dDataBase )
				
				(cAlias)->(DbSkip())
				Loop
			EndIf
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica se o SLA ja esta incluido no array                        ณ
		//ณ Caso positivo, incrementa o nr. entidades encontradas para este SLAณ
		//ณ Caso contrario, adiciona um novo SLA no array                      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nPos := aScan(aSLAEntid, { |x| x[1] == (cAlias)->K7_CODSLA } )
		If nPos > 0
			aSLAEntid[nPos][2] := aSLAEntid[nPos][2] + 1						//Total de Entidades
			aSLAEntid[nPos][3] := aSLAEntid[nPos][3] + (cAlias)->K7_PESO		//Somatoria do peso das entidades
		Else
			nTotEntidades := 1
			
			//Verifica quando a Entidade for generica (codigo em branco)
			//qual eh a precedencia a ser usada para desempate do peso (definida no param.)
			If Empty( Alltrim( (cAlias)->K7_CODENT ) )
				If cPrecedSLA == "0"
					nValPeso := (cAlias)->K7_PESO + 1
				Else
					nValPeso := (cAlias)->K7_PESO - 1
				EndIf
			Else
				nValPeso := (cAlias)->K7_PESO
			EndIf
			
			aAdd(aSLAEntid, {	(cAlias)->K7_CODSLA,;		//Cod. do SLA encontrado na Entidade
								nTotEntidades,;				//Nr. de entidades pertencentes a este SLA
								nValPeso,;					//Somatoria do peso das entidades do SLA
								.T.			})				//Indica se o contrato ้ valido
		EndIf
		
		(cAlias)->(dbSkip())
	End
	
	
	DbSelectArea(cAlias)
	DbCloseArea()
	
Next nI


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ    
//| Verifica se o contrato de SLA atende apenas as entidades solicitadas |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nI := 1 To Len(aSLAEntid)
	
	cAlias 	:=	GetNextAlias()
	BeginSQL alias cAlias
		SELECT 	K7_CODSLA,	K7_NOMEENT, K7_CODENT,	K7_PESO
		FROM	%table:SK7% SK7
		WHERE	SK7.K7_FILIAL = %xFilial:SK7% AND
		SK7.%NOTDEL% AND
		SK7.K7_CODSLA = %EXP:aSLAEntid[nI][1]%
	EndSql
	
	While (cAlias)->(!Eof())
		lExistEnt := .F.
		For nEnt := 1 To Len(entities)
			If ValType(entities[nEnt]:entityValue) <> "C"
				cValue	:= AllTrim(Str(entities[nEnt]:entityValue))
			Else
				cValue	:= entities[nEnt]:entityValue
			EndIf
			If (AllTrim(entities[nEnt]:entityName) == AllTrim((cAlias)->K7_NOMEENT) .AND.;
					(RTrim(cValue) == RTrim((cAlias)->K7_CODENT) .OR.;
					Empty((cAlias)->K7_CODENT)))
				lExistEnt := .T.
				Exit
			EndIf
		Next nEnt
		If !lExistEnt
			Exit
		EndIf
		(cAlias)->(dbSkip())
	End
	If !lExistEnt
		//Invalida o contrato de SLA
		aSLAEntid[nI][4] := .F.
	EndIf
	
	
	DbSelectArea(cAlias)
	DbCloseArea()
	
Next nI


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Analisar qual eh o melhor SLA dentre os encontrados ณ
//ณ de acordo com o criterio de maior nr. de entidades  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTotEntidades := 0
If Len(aSLAEntid) > 0
	
	//Ordena o array pelo total de entidades para encontrar o SLA vencedor 
	ASort(aSLAEntid,,, {|x,y| x[2] > y[2]} )
	
	cCodSLA := ""
	
	For nI := 1 To Len(aSLAEntid)
		
		If !aSLAEntid[nI][4]
			Loop
		EndIf   
		
		If Empty(cCodSLA)
			//Marca o primeiro SLA encontrado
			cCodSLA 	  := aSLAEntid[nI][1]
			nTotEntidades := aSLAEntid[nI][2]  
			nPesoEntid	:= aSLAEntid[nI][3]
		Endif

		//Verifica qual tem o maior peso total de entidades (criterio de desempate)
		If aSLAEntid[nI][3] == nPesoEntid		
			//Verifica se ocorreu empate de SLA pelo total de entidades
			If aSLAEntid[nI][2] > nTotEntidades	
				nPesoEntid	:= aSLAEntid[nI][3]
				cCodSLA		:= aSLAEntid[nI][1]
				nTotEntidades := aSLAEntid[nI][2]  
			EndIf
		ElseIf aSLAEntid[nI][3] > nPesoEntid                           
			nPesoEntid	:= aSLAEntid[nI][3]
			cCodSLA		:= aSLAEntid[nI][1]
			nTotEntidades := aSLAEntid[nI][2]  		
		EndIf
	Next nI	
	
EndIf

If 	(!Empty(cCodSLA) .AND. Self:Paused) .OR.;
	!Self:Paused

	Self:SlaFound := cCodSLA
Else
	cCodSLA := Self:SlaFound 
EndIf

Return cCodSLA


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณgetNextResponsบAutor  ณVendas Clientes บ Data ณ  19/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLocalizar o proximo responsavel. Caso um responsavel ja     บฑฑ
ฑฑบ          ณtenha sido notificado, o sistema deve localizar o seu       บฑฑ
ฑฑบ          ณsuperior imediato.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method getNextResponsible() Class SLARegister
Local cNextResponsible	:= ""							//Codigo do proximo responsavel pelo SLA
Local oSLAResponsible	:= SLAResponsible():New()		//Objeto da classe SLAResponsible
Local objSLA											//Objeto da classe SLA

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega os dados do responsavel ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If oSLAResponsible:load( Self:SlaResponsible )
	cNextResponsible := oSLAResponsible:codSuperior
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Excecao: Se nao encontrou prox. responsavel    ณ
//ณ Pega o responsav. informado no contrato de SLA ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(cNextResponsible)
	objSLA := SLA():New()
	If objSLA:load( Self:SlaFound )
		cNextResponsible := objSLA:responsible
	Else
		cNextResponsible := Self:SlaResponsible
	EndIf
EndIf

Return cNextResponsible


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณfindSeverity	บAutor  ณVendas Clientes บ Data ณ  18/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLocalizar e preencher dados de severidade para o SLA e nivelบฑฑ
ฑฑบ          ณde severidade informados                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method findSeverity(cSLA, nSeverityCode, cShowDialog, cTimeShift, aDataHoraSLA ) Class SLARegister
Local cAlias 		:=	"SK9"					// Alias temporario da query
Local lRet			:= .T.						// Indica o retorno da funcao
Local nSeverAprox	:= 0						// Severidade mais proxima
Local aSeveridades	:= {}						// Array com as severidades do SLA corrente
Local oDlgSev		:= Nil						// Objeto Dialog de Severid.
Local oLbx1			:= Nil						// ListBox usado na Dialog
Local nSeveridade 	:= 0			 			// Nivel de Severidade do chamado 
Local nOpcA			:= 0						// Opcao de retorno da Dialog 
Local cPosLbx		:= ""						// Variavel do ListBox
Local dDataExpir	:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )					// Data inicial para cแlculo do SLA
Local cHoraExpir	:= Time()					// Hora inicial para cแlculo do SLA
Local nSomaHs		:= 0						// Quantidade de horas do SLA
Local oDateTime		:= Nil						// Objeto TMKDateTime utilizado para cแluclo do SLA
Local lPaused		:= .F.	 					// Se o registro encerrado foi pausado
Local nPausedTime	:= 0						// Tempo pausado
Local nPos			:= 0						// Resultado da pesquisa no array de severidades
Local oPausedDate	:= Nil
Local oUpdateDate	:= Nil
Local nCount		:= 0
Local lTk530DTH 	:= ExistBlock("TK530DTH")
Local lTk530FSC 	:= ExistBlock("TK530FSC")
Local aNewSeveri	:= {}
Local aRetDtHr		:= {}
Local lContinua		:= .T.
Local lTk530HRE  	:= ExistBlock("TK530HRE")
Local nNewSomaHs 	:= 0

Default cShowDialog := "2"						//Padrao eh nao exibir tela de confirmacao  
Default aDataHoraSLA:= {}						//Previsao de termino para a severidade selecionada
   
cAlias 	:=	GetNextAlias()
If TK510NewFields()
	BeginSQL alias cAlias
		
		SELECT 	K9_CODSLA,	K9_SEVE,	K9_HREXPIR,	K9_HRPSEXP, K9_NOME
		FROM	%table:SK9% SK9
		WHERE	SK9.K9_FILIAL = %xFilial:SK9% AND
		SK9.%NOTDEL% AND
		SK9.K9_CODSLA = %EXP:cSLA%
		
	EndSql
Else
	BeginSQL alias cAlias
		
		SELECT 	K9_CODSLA,	K9_SEVERID,	K9_HREXPIR,	K9_HRPSEXP, K9_NOME
		FROM	%table:SK9% SK9
		WHERE	SK9.K9_FILIAL = %xFilial:SK9% AND
		SK9.%NOTDEL% AND
		SK9.K9_CODSLA = %EXP:cSLA%
		
	EndSql
EndIf

If (cAlias)->(Eof())
	lRet := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o turno do contrato, caso nใo seja informado.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cTimeShift == Nil .Or. Empty(cTimeShift)
	cTimeShift := Self:getTimeShift(cSLA)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o registro estiver pausado, pega o tempo da pausa, paraณ
//ณque possa ser adicionado no total de horas disponํveis.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Self:Paused
	lPaused		:= .T.

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณProcura o registro anterior a pausa para pegar a data de atualiza็ใo dele.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SK5")
	DbSetOrder(1)
	If DbSeek( xFilial("SK5") + Self:previousCode + Self:item )
		oPausedDate := TMKDateTime():This(SK5->K5_DTATUA, SK5->K5_HRATUA)
		oUpdateDate := TMKDateTime():This(If(!IsInCallStack("GenRecurrence"), Date(), dDatabase ), Time())
		nPausedTime := Self:getTimeElapsed(oPausedDate, oUpdateDate, cTimeShift)
	Else
		nPausedTime := 0
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe o registro estava pausado antes.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lPaused
	Self:PausedTime += nPausedTime
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Localiza qual severid. esta mais proxima do valor enviado na funcao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nDifAnt := 999
nDif	:= 0
nSeverAprox	:= 0
While (cAlias)->(!Eof())

	nSomaHs	:= (cAlias)->K9_HREXPIR

	If lTk530HRE
		nNewSomaHs := ExecBlock("TK530HRE", .F., .F., { nSomaHs })
		If ValType(nNewSomaHs) == "N" .And. nNewSomaHs > 0
			nSomaHs := nNewSomaHs
		EndIf
	EndIf
	
	nSomaHs += Self:PausedTime     

	If TK510NewFields()          
		aAdd(aSeveridades, { Val((cAlias)->K9_SEVE), (cAlias)->K9_NOME, dDataExpir, cHoraExpir, nSomaHs } )
	Else
		aAdd(aSeveridades, { (cAlias)->K9_SEVERID, (cAlias)->K9_NOME, dDataExpir, cHoraExpir, nSomaHs } )
	EndIf	
	
	nDif := nSeverityCode - aSeveridades[Len(aSeveridades)][1]
	If nDif < 0		
		//Transforma numero negativo em positivo 
		nDif := ((nDif) * (-1))
	EndIf
	
	If nDif <= nDifAnt
		nDifAnt := nDif
		nSeverAprox	:= aSeveridades[Len(aSeveridades)][1]
		
		nAt := Len(aSeveridades)
	EndIf              
	
	(cAlias)->( DbSkip() )
End     

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalcula as datas e horas das severidades encontradas.     ณ
//ณSe for rotina automแtica, s๓ calcula para o item que serแ ณ
//ณselecionado. Evitando processamento desnecessแrio.        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nCount := 1 To Len(aSeveridades)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe for rotina automแtica, s๓ serแ calculado SLA para o itemณ
	//ณque serแ selecionado automaticamente.                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (cShowDialog == '2' .Or. IsBlind()) .And. nAt != nCount
		Loop
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Busca o nr. de horas da sev. e calcula data/hora para o SLA expirar ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	If !Empty(Self:createdDate) .And. !Empty(Self:createdHour)
		dDataExpir	:= Self:createdDate		// Data de criacao do SLA (mantem-se na atualizacao)
		cHoraExpir	:= Self:createdHour		// Hora de criacao do SLA (mantem-se na atualizacao)
	Else
		dDataExpir	:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
		cHoraExpir	:= Time()

		If lTk530DTH
			aNewSeveri := ExecBlock("TK530DTH", .F., .F., {dDataExpir,cHoraExpir})
			If ValType(aNewSeveri) == "A" .And. Len(aNewSeveri) == 2
		 		dDataExpir	:= aNewSeveri[1]
		  		cHoraExpir	:= aNewSeveri[2]
			EndIf
		EndIf
	EndIf

	If cTimeShift == Nil .Or. Empty(cTimeShift)
		SomaDiaHor(@dDataExpir, @cHoraExpir, aSeveridades[nCount][5])
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica se deve calcular o vencimento para dias uteis 	   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SK6")
		DbSetOrder(1) 	//K6_CODSLA
		If DbSeek(xFilial("SK6") + SK9->K9_CODSLA) .AND. SK6->K6_DSUTEIS == '1'
			dDataExpir := DataValida(dDataExpir) 
		EndIf
		dDataExpir	:= dDataExpir
		cHoraExpir	:= cHoraExpir + ":00"
	Else
		If lTk530FSC
			aRetDtHr := ExecBlock("TK530FSC", .F., .F., {dDataExpir,cHoraExpir,aSeveridades[nCount][5],cTimeShift})
			If ValType(aRetDtHr) == "A" .And. Len(aRetDtHr) == 2
				dDataExpir := aRetDtHr[1]
				cHoraExpir := aRetDtHr[2]
				lContinua  := .F.
			EndIf        
		EndIf
		If lContinua
			oDateTime 	:= TMKDateTime():This(dDataExpir, cHoraExpir)
			oDateTime 	:= Self:getExpireDateTime(oDateTime, cTimeShift, aSeveridades[nCount][5])
			dDataExpir	:= oDateTime:getDate()
			cHoraExpir	:= oDateTime:getTime()    			
		Endif		

	EndIf
	
	aSeveridades[nCount][3] := dDataExpir
	aSeveridades[nCount][4] := cHoraExpir
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Caso a opcao de Exibir confirmacao esteja ativa ณ
//ณ Monta tela p/ escolha da severidade pelo usuarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cShowDialog == '1' .AND. !IsBlind() .AND. Len(aSeveridades) > 0
	DEFINE MSDIALOG oDlgSev FROM 50,003 TO 330,500 TITLE STR0002 PIXEL  //"Severidades do SLA "
	
		@ 01,10 SAY STR0003 + Str(nSeverityCode,3,0) SIZE 100,12 PIXEL //"Criticidade calculada pelo Sistema: "
		@ 12,10 SAY STR0004 + cSLA + " - " + Posicione("SK6", 1, xFilial("SK6")+cSLA, "K6_NOME") SIZE 300,12 PIXEL //"Contrato de SLA encontrado: "
		@ 23,10 SAY STR0005 + Str(nSeverAprox,3,0) + " - " + Posicione("SK9",1,xFilial("SK9")+Str(nSeverAprox,3,0), "K9_NOME") SIZE 300,12 PIXEL //"Severidade encontrada: "
		
		@ 35,10 LISTBOX oLbx1 VAR cPosLbx FIELDS HEADER STR0006,STR0007,STR0010,STR0011 SIZE 233,60 PIXEL NOSCROLL OF oDlgSev //"Severidade" # "Nome Severidade" # "Data" # "Hora"
		
		oLbx1:SetArray(aSeveridades)
	    oLbx1:bLine:={||{aSeveridades[oLbx1:nAt,1],;
						 AllTrim(aSeveridades[oLbx1:nAt,2]),;
						 aSeveridades[oLbx1:nAt,3],;
						 aSeveridades[oLbx1:nAt,4]}}
	
	    oLbx1:BlDblClick := {||(nOpcA:=1, nPos:=oLbx1:nAt, oDlgSev:End())}
	    //oLbx1:NROWPOS := nAt	//Posiciona na severidade encontrada
	    If Type("nAt") <> "U"
	    	oLbx1:nAt := nAt	//Posiciona na severidade encontrada
		EndIf
		oLbx1:Refresh()
		
		@ 098,10 SAY STR0008 SIZE 300,12 PIXEL //"Selecione e confirme uma outra Severidade"
	    @ 110,10 SAY STR0009 SIZE 300,12 PIXEL //"Ou clique Cancelar para utilizar a severidade encontrada"
	    
	    DEFINE SBUTTON FROM 122,175 TYPE 1 ENABLE OF oDlgSev ACTION (nOpcA:= 1,nPos := oLbx1:nAt,oDlgSev:End())
	    DEFINE SBUTTON FROM 122,210 TYPE 2 ENABLE OF oDlgSev ACTION (nOpcA:= 0,oDlgSev:End())
	
	ACTIVATE MSDIALOG oDlgSev CENTERED 

	If nOpcA == 1
		//Confirmou: utiliza a severid. selecionada
		If nPos > 0
			nSeveridade := aSeveridades[nPos,1]	
			Self:dateTimeToExpire:setDate(aSeveridades[nPos,3])	
			Self:dateTimeToExpire:setTime(aSeveridades[nPos,4])	
		Else
			nSeveridade := nSeverAprox
		EndIf
	Else
		//Cancelou: mantem a severidade mais proxima encontrada
		nSeveridade := nSeverAprox
	EndIf
Else
	//Se nao encontrou nenhum SLA/Severidade ou a tela nao foi exibida, assume a severidade inicial
	If Len(aSeveridades) > 0 .AND. nAt > 0 
		nSeveridade := aSeveridades[nAt,1]
		Self:dateTimeToExpire:setDate(aSeveridades[nAt,3])	
		Self:dateTimeToExpire:setTime(aSeveridades[nAt,4])	
	Else
	  	nSeveridade := nSeverityCode
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza no atributo da classe a severidade escolhida p/ calculo do SLA   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Self:severityCode := nSeveridade

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza a quantidade prevista de horas para a severidade selecionadaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (nPos := aScan(aSeveridades,{|x| x[1] == nSeveridade })) > 0
	aDataHoraSLA := {aSeveridades[nPos][3],aSeveridades[nPos][4]}
EndIf

DbSelectArea(cAlias)
DbCloseArea()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบMetodo    ณgetExpireDateTime	บAutor  ณVendas CRM      บ Data ณ 04/03/09บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณCalcula a data de expiracao do SLA baseado em um turno e umaบฑฑ
ฑฑบ          ณquantidade de horas definida.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method getExpireDateTime(oDateTime, cTurno, nHoras) Class SLARegister
	Local aTabPadrao		:= {}
	Local aCalend			:= {}
	Local aExceptions		:= {}
	Local nCounter			:= 0
	Local oDTIni1			:= Nil
	Local oDTFim1			:= Nil
	Local oDTIni2			:= Nil
	Local oDTFim2			:= Nil
	Local lEncontrou		:= .F.
	Local nHorasRestantes	:= 0
	Local nHorasAAdicionar	:= 0
	Local nHorasDisponiveis	:= 0
	Local nRepeticoes		:= 0
	Local nBackup			:= 0
	Local lFound			:= .F.
	
	oDateTime := oDateTime:clone()
			
	If ( fTabTurno(@aTabPadrao) )
		For nCounter := 1 To Len(aTabPadrao)
			aTabPadrao[nCounter][1] := xFilial("SRA") // Falar com Mauro Testoni
		Next

		If ( CriaCalend(oDateTime:getDate(),oDateTime:getDate(),cTurno,"01",aTabPadrao,@aCalend,xFilial("SR6")) )
		
			GetExceTop( xFilial("SRA")				,; //01 -> Filial
						Space(TamSX3("P2_MAT")[1])	,; //02 -> Matricula
						Space(TamSX3("P2_CC")[1])	,; //03 -> Centro de Custo
						{{cTurno}}					,; //04 -> Array com os Turnos do Funcionario
						oDateTime:getDate()			,; //05 -> Periodo Inicial
						oDateTime:getDate()			,; //06 -> Periodo Final
						@aExceptions 	 			; //07 -> Array a ser carregado com as Excecoes
						)		
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica a Proxima data                                                 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			lFound := .F.
			While ( !lFound )
				CriaCalend(oDateTime:getDate(),oDateTime:getDate(),cTurno,"01",aTabPadrao,@aCalend,xFilial("SR6"))
				If ( aCalend[1][6]=="S" ) .And. aScan(aExceptions, {|x| x[2] <= oDateTime:getDate() .And. oDateTime:getDate() <= x[3] .And. x[25] <> "S" .And. x[4] == cTurno}) == 0 // Dia Trabalhado
					lFound := .T.
				Else
					oDateTime:plusDays(1)
				EndIf
			EndDo
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPega os DateTime dos dois perํodos tratados.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oDTIni1 := TMKDateTime():this(oDateTime:getDate(), StrZero(Int(aCalend[1][3]),2)+":"+StrZero(((aCalend[1][3]-Int(aCalend[1][3]))*100),2))
			oDTFim1 := TMKDateTime():this(oDateTime:getDate(), StrZero(Int(aCalend[2][3]),2)+":"+StrZero(((aCalend[2][3]-Int(aCalend[2][3]))*100),2))
			oDTIni2	:= TMKDateTime():this(oDateTime:getDate(), IIF(Len(aCalend)>2,StrZero(Int(aCalend[3][3]),2)+":"+StrZero(((aCalend[3][3]-Int(aCalend[3][3]))*100),2),"00:00"))
			oDTFim2 := TMKDateTime():this(oDateTime:getDate(), IIF(Len(aCalend)>3,StrZero(Int(aCalend[4][3]),2)+":"+StrZero(((aCalend[4][3]-Int(aCalend[4][3]))*100),2),"00:00"))

			nHorasRestantes := nHoras

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณEnquanto nใo acabar as horas que devem ser adicionadas.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			While nHorasRestantes > 0
				nBackup := nHorasRestantes
			
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณPosiciona a data/hora de cแlculo em uma data/hora vแlida.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If oDateTime:lessThan(oDTIni1)
					oDateTime := oDTIni1:clone()
				ElseIf Len(aCalend)>2 .And. (oDateTime:greaterThan(oDTFim1) .Or. oDateTime:equals(oDTFim1)) .And. oDateTime:lessThan(oDTIni2)
					oDateTime := oDTIni2:clone()                 
				ElseIf Len(aCalend)>3 .And. (oDateTime:equals(oDTFim2) .Or. oDateTime:greaterThan(oDTFim2))
					oDateTime := oDTIni1:clone()                 
					lEncontrou := .F.
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณProcura o pr๓ximo dia com horแrio disponํvel e que sejaณ
					//ณtrabalhado.                                            ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					While !lEncontrou 
						oDateTime:plusDays(1)
						CriaCalend(oDateTime:getDate(),oDateTime:getDate(),cTurno,"01",aTabPadrao,@aCalend,xFilial("SR6"))
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณVerifica a Proxima data                                                 ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						lFound := .F.
						While ( !lFound )
							CriaCalend(oDateTime:getDate(),oDateTime:getDate(),cTurno,"01",aTabPadrao,@aCalend,xFilial("SR6"))
							If ( aCalend[1][6]=="S" ) .And. aScan(aExceptions, {|x| x[2] <= oDateTime:getDate() .And. oDateTime:getDate() <= x[3] .And. x[25] <> "S" .And. x[4] == cTurno}) == 0 // Dia Trabalhado // Dia Trabalhado
								lFound := .T.
							Else
								oDateTime:plusDays(1)
							EndIf				
						EndDo		
						If Len(aCalend) >= 4
							oDTIni1 := TMKDateTime():this(oDateTime:getDate(), StrZero(Int(aCalend[1][3]),2)+":"+StrZero(((aCalend[1][3]-Int(aCalend[1][3]))*100),2))
							oDTFim1 := TMKDateTime():this(oDateTime:getDate(), StrZero(Int(aCalend[2][3]),2)+":"+StrZero(((aCalend[2][3]-Int(aCalend[2][3]))*100),2))
							oDTIni2	:= TMKDateTime():this(oDateTime:getDate(), StrZero(Int(aCalend[3][3]),2)+":"+StrZero(((aCalend[3][3]-Int(aCalend[3][3]))*100),2))
							oDTFim2 := TMKDateTime():this(oDateTime:getDate(), StrZero(Int(aCalend[4][3]),2)+":"+StrZero(((aCalend[4][3]-Int(aCalend[4][3]))*100),2))						
							If ( aCalend[1][6]=="S" ) // Dia Trabalhado
								lEncontrou := .T.
							EndIf
						EndIf
   					End
				EndIf
								
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerifica o intervalo disponํvel de horas.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 				If (oDateTime:greaterThan(oDTIni1) .Or. oDateTime:equals(oDTIni1)) .And. (oDateTime:lessThan(oDTFim1) .Or. oDateTime:equals(oDTFim1))
					nHorasDisponiveis := oDateTime:diffInHours(oDTFim1,,.T.,.T.)					
				ElseIf Len(aCalend)>2 .And. (oDateTime:greaterThan(oDTIni2) .Or. oDateTime:equals(oDTIni2)) .And. (oDateTime:lessThan(oDTFim2) .Or. oDateTime:equals(oDTFim2))
					nHorasDisponiveis := oDateTime:diffInHours(oDTFim2,,.T.,.T.)					
				EndIf								

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCalcula quantas horas ainda faltam ser consumidas.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If ( nHorasRestantes < nHorasDisponiveis)
					nHorasAAdicionar := nHorasRestantes
					nHorasRestantes := 0
				Else
					nHorasAAdicionar := nHorasDisponiveis
					nHorasRestantes -= nHorasDisponํveis
				EndIf
				
				If Round(nHorasRestantes,2) == 0
					nHorasRestantes := 0
				EndIf

				oDateTime:plusHours(nHorasAAdicionar)
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณProte็ใo contra loop infinito.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If nHorasRestantes == nBackup
					nRepeticoes++
				EndIf
				If nRepeticoes > 20
					Exit
				EndIf
			End
		EndIf
	EndIf
Return oDateTime

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบMetodo    ณgetTimeElapsed	บAutor  ณVendas CRM      บ Data ณ 17/06/09บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณCalcula o tempo decorrido entre duas datas considerando o   บฑฑ
ฑฑบ          ณturno e o calendario.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method getTimeElapsed(oDTStart, oDTFinished, cTurno) Class SLARegister
Local nTimeElapsed 	:= 0	// Indica o numero de horas entre duas datas
Local aSiglaMarc	
Local nSizeSiglaMarc:= TabMarc( "SPJ" , @aSiglaMarc )
Local aInfoCalend	:= Array( 12 )
Local dStartDate	:= If(!IsInCallStack("GenRecurrence"), Date(), dDatabase )
Local nStartDate	:= 0
Local nFinishDate	:= 0   
Local aTabCalend	:= {}
Local aTurnos		:= {}          
Local nPosCalend	:= 0  
Local aTabPadrao	:= {}
Local nCounter		:= 0   
Local bAscanOrdem	:= { |x| x[ 02 ] == StrZero( nStartDate , 02 ) .and. x[ 04 ] == "1E" }
Local nMarc			:= 0
Local nHorasTrab	:= 0.00
Local nHorasInte	:= 0.00
Local cPagInt		:= "" 
Local nHoras		:= 0
Local nMinutos		:= 0

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณInicializa Todos os Elementos de aInfoCalend com Zeros        ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
aFill( aInfoCalend , 0.00  )

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณDefine o Periodo Para Carga das Informacoes em aInfoCalend    ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
dStartDate	:= oDTStart:getDate()
nFinishDate	:= (( oDTFinished:getDate() - oDTStart:getDate() ) + 1)

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณInicializa as Variaveis para o Calendario                     ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
aTabCalend	:= {}
aTurnos		:= {}

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณCria o Calendario de Marcacoes de Acordo com o Periodo Passadoณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/  
If !Empty(cTurno) .AND. ( fTabTurno(@aTabPadrao) )
	For nCounter := 1 To Len(aTabPadrao)
		aTabPadrao[nCounter][1] := xFilial("SRA") // Falar com Mauro Testoni
	Next    

	If CriaCalend(oDTStart:getDate(),oDTFinished:getDate(),cTurno,"01",aTabPadrao,@aTabCalend,xFilial("SR6"))
		If nFinishDate > 1
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณDias diferentesณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	 	
	
			For nStartDate := 1.00 To nFinishDate
				/*
				ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				ณA Pesquisa da Data em aTabCalend devera ser Feita Baseada   naณ
				ณOrdem                  									   ณ
				ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
				If ( nPosCalend := aScan( aTabCalend , bAscanOrdem ) ) == 0.00
					dStartDate++
				Else
					dStartDate := aTabCalend[ nPosCalend , 01 ]
				EndIf
	
				cPagInt := GetInfoPosTab( 35 , "1E" , dStartDate , aTabCalend )
	
				/*
				ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				ณApura o Numero de Horas Trabalhadas na Tabela.                ณ
				ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/			
				nHorasTrab := nHorasInte := 0.00
				For nMarc := 1 To nSizeSiglaMarc  				
				    				
					If nStartDate < nFinishDate
						/*
						ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						ณSe a Regra Define o Pagamento do Intervalo, considera as Horasณ
						ณde Intervalo como Horas Trabalhadas						   ณ
						ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
						If ( ( "I" + SubStr( aSiglaMarc[ nMarc ] , 1 , 1 ) ) $ cPagInt )
							nHorasInte := __TimeSum( nHorasInte , GetInfoPosTab(07,aSiglaMarc[nMarc],dStartDate,aTabCalend) )
						EndIf						
						
						If nStartDate == 1.00 				
							If "E" $ aSiglaMarc[nMarc] 
		                        
		                        // Periodo procurado (Data de Pausa)
							    oDt1 := TMKDateTime():New() 			    
							    oDt1:setHour(oDTStart:getHour())
							    oDt1:setMinute(oDTStart:getMinute()) 							
								
								// Inicio do Periodo
							    oDt2 := TMKDateTime():New() 
							    nHoras 	:=  GetInfoPosTab( 03 , aSiglaMarc[nMarc] , dStartDate , aTabCalend )
							    nMinutos:=	nHoras - Int(nHoras)
							    nMinutos:=	nMinutos * 100
							    nHoras	:=	Int(nHoras)	  
							    oDt2:setHour(nHoras)   
							    oDt2:setMinute(nMinutos)							    
							                                
							    // Fim do Periodo
							    oDt3 := TMKDateTime():New() 
							    nHoras 	:=  GetInfoPosTab( 03 , aSiglaMarc[nMarc+1] , dStartDate , aTabCalend )
							    nMinutos:=	nHoras - Int(nHoras)
							    nMinutos:=	nMinutos * 100
							    nHoras	:=	Int(nHoras)	  
							    oDt3:setHour(nHoras)   
							    oDt3:setMinute(nMinutos)							    
							    
							    If oDt2:lessThan(oDt1) .AND. oDt3:greaterThan(oDt1)
							    	nTimeElapsed -= oDt1:diffInMinutes(oDt2)/60	 
							    	nTimeElapsed += __TimeSum( nHorasTrab , GetInfoPosTab(07,aSiglaMarc[nMarc],dStartDate,aTabCalend) )
							    ElseIf oDt1:lessThan(oDt3) .AND. oDt3:getHour() > 0
								    nTimeElapsed += __TimeSum( nHorasTrab , GetInfoPosTab(07,aSiglaMarc[nMarc],dStartDate,aTabCalend) )
							    EndIf					    
							EndIf  						
						Else
							If "E" $ aSiglaMarc[nMarc]
						        nTimeElapsed  += __TimeSum( nHorasTrab , GetInfoPosTab(07,aSiglaMarc[nMarc],dStartDate,aTabCalend) )
						    EndIf
						EndIf	   																						
					Else
						If "E" $ aSiglaMarc[nMarc] 
	                        
	                        // Periodo procurado (Data de Reabertura)
						    oDt1 := TMKDateTime():New() 			    
						    oDt1:setHour(oDTFinished:getHour())
						    oDt1:setMinute(oDTFinished:getMinute())    						
							
							
							// Inicio do Periodo
						    oDt2 := TMKDateTime():New() 
						    nHoras 	:=  GetInfoPosTab( 03 , aSiglaMarc[nMarc] , dStartDate , aTabCalend )
						    nMinutos:=	nHoras - Int(nHoras)
						    nMinutos:=	nMinutos * 100
						    nHoras	:=	Int(nHoras)	  
						    oDt2:setHour(nHoras)   
						    oDt2:setMinute(nMinutos)						    		
						                                
						    // Fim do Periodo
						    oDt3 := TMKDateTime():New()                                
						    nHoras 	:=  GetInfoPosTab( 03 , aSiglaMarc[nMarc+1] , dStartDate , aTabCalend )
						    nMinutos:=	nHoras - Int(nHoras)
						    nMinutos:=	nMinutos * 100
						    nHoras	:=	Int(nHoras)	  
						    oDt3:setHour(nHoras)   
						    oDt3:setMinute(nMinutos)						    		
						    
						    If oDt2:lessThan(oDt1) .AND. oDt3:greaterThan(oDt1)
						    	nTimeElapsed += oDt2:diffInMinutes(oDt1)/60	 
						    ElseIf oDt1:greaterThan(oDt2) .AND. oDt2:getHour() > 0  
						    	nTimeElapsed += __TimeSum( nHorasTrab , GetInfoPosTab(07,aSiglaMarc[nMarc],dStartDate,aTabCalend) )					    
						    EndIf					    
						EndIf										
					EndIf
				Next nMarc	 			
				nTimeElapsed +=	__TimeSum( aInfoCalend[ 02 ] , __TimeSum( nHorasTrab , nHorasInte ) )
			Next nStartDate
	  	Else
	  	
			//ฺฤฤฤฤฤฤฤฤฤฟ
			//ณMesmo diaณ
			//ภฤฤฤฤฤฤฤฤฤู
			cPagInt := GetInfoPosTab( 35 , "1E" , dStartDate , aTabCalend )

			/*
			ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			ณApura o Numero de Horas Trabalhadas na Tabela.                ณ
			ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/			
			nHorasTrab := nHorasInte := 0.00
			For nMarc := 1 To nSizeSiglaMarc

				If "E" $ aSiglaMarc[nMarc] 
	                        
	                // Periodo procurado (Data de Solu็ใo)
				    oDt1 := TMKDateTime():New() 			    
				    oDt1:setHour(oDTStart:getHour())
				    oDt1:setMinute(oDTStart:getMinute())    						
					
					
					// Inicio do Periodo
				    oDt2 := TMKDateTime():New()
				    nHoras 	:=  GetInfoPosTab( 03 , aSiglaMarc[nMarc] , dStartDate , aTabCalend )
				    nMinutos:=	nHoras - Int(nHoras)
				    nMinutos:=	nMinutos * 100
				    nHoras	:=	Int(nHoras)
				    oDt2:setHour(nHoras)   
				    oDt2:setMinute(nMinutos)
				                                
				    // Fim do Periodo
				    oDt3 := TMKDateTime():New() 
				    nHoras 	:=  GetInfoPosTab( 03 , aSiglaMarc[nMarc+1] , dStartDate , aTabCalend )
				    nMinutos:=	nHoras - Int(nHoras)
				    nMinutos:=	nMinutos * 100
				    nHoras	:=	Int(nHoras)				    
				    oDt3:setHour(nHoras)  					    
				    oDt3:setMinute(nMinutos)
				    
	                // Periodo procurado (Data de Reabertura)
				    oDt4 := TMKDateTime():New() 			    
				    oDt4:setHour(oDTFinished:getHour())
				    oDt4:setMinute(oDTFinished:getMinute())   				    
				    
				    If 	oDt2:lessThan(oDt1) .AND. oDt3:greaterThan(oDt1) .AND.;
				    	oDt2:lessThan(oDt4) .AND. oDt3:greaterThan(oDt4)
				    	
				    	// Data de solu็ใo e reabertura na mesma hora				    	
				    	nTimeElapsed += oDt1:diffInMinutes(oDt4)/60				    	
				    Else				    
					    If oDt2:lessThan(oDt1) .AND. oDt3:greaterThan(oDt1) 
					    
					    	// Periodo da data inicial at้ a solu็ใo
					    	nTimeElapsed += oDt3:diffInMinutes(oDt1)/60	 
					    		    
					    ElseIf 	oDt1:lessThan(oDt2) .AND. oDt2:getHour() > 0 .AND.;
					    		oDt4:greaterThan(oDt3) .AND. oDt3:getHour() > 0  
					    
					    	// Quando o perํodo esta entre a hora de solu็ใo e a hora de reabertura 					    		
					    	nTimeElapsed += __TimeSum( nHorasTrab , GetInfoPosTab(07,aSiglaMarc[nMarc],dStartDate,aTabCalend) )					    
					    
					    ElseIf 	oDt2:lessThan(oDt4) .AND. oDt3:greaterThan(oDt4)   
					    
					    	// Periodo da data inicial at้ a Reabertura 
					    	nTimeElapsed += oDt2:diffInMinutes(oDt4)/60	 
					    EndIf
					EndIf 				    
				EndIf
			Next nMarc	  	
	    EndIf
	EndIf  
Else         	
	nTimeElapsed := oDTStart:diffInHours(oDTFinished,,.F.,.F.)
EndIf

Return nTimeElapsed

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณgetTimeShift	บAutor  ณVendas CRM      บ Data ณ  04/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPega o turno de um SLA.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method getTimeShift(cSLA) Class SLARegister
	Local aArea := GetArea()
	Local cTurn	:= Nil
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se deve calcular o vencimento para dias uteis 	   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SK6")
	DbSetOrder(1) 	//K6_CODSLA
	
	If DbSeek(xFilial("SK6") + cSLA) .AND. !Empty(SK6->K6_TURNO)
		cTurn := SK6->K6_TURNO
	EndIf	
	
	RestArea(aArea)
Return cTurn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณgetTerm       บAutor  ณVendas CRM      บ Data ณ  01/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetnora a previsao do prazo do SLA                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method getTerm(cSLA,nSeverityCode,cTimeShift) Class SLARegister

Local aDtHoraPrev	:= {}

Self:findSeverity(cSLA, nSeverityCode, "1", cTimeShift, @aDtHoraPrev)

Return aDtHoraPrev

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณfree       	บAutor  ณVendas Clientes บ Data ณ  30/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Libera a mem๓ria dos objetos utilizados.    			 	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method free() Class SLARegister

TMKFree( Self:oPersist )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_TMKA530B     บAutor  ณVendas Clientes บ Data ณ  07/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao dummy apenas para o programa aparecer no inspetor de บฑฑ
ฑฑบ          ณobjetos                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                   
FUNCTION _TMKA530B()
RETURN NIL
