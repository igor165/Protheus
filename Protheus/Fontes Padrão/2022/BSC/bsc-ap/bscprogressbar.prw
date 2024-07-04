// ######################################################################################
// Projeto: BSC
// Modulo : 
// Fonte  : BSCProgressbar.prw
// ---------+---------------------------------+------------------------------------------
// Data     | Autor                           | Descricao
// ---------+---------------------------------+------------------------------------------
// 02.05.06 | 1776 - Alexandre Alves da Silva | KpiProgressBar (SGI)
// 22.06.09 | 3510 - Gilmar P. Santos         | Migração para o BSC - FNC 00000008745/2009
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "BscDefs.ch"
#include "BscProgressBar.ch"

class BSCProgressbar from TBIObject
    data	oThreadFile 	//Arquivo de gravacao.
	data 	oXMLThread 		//Use para adicionar um nova propriedades.
	data	oXMLRespostas 	//Dados a serem gravados.
	data	oNodeStatus		//Status atual do processamento.
	data	oNodePercent	//Porcentagem do processamento.
	data 	oNodeMessage	//No de mensagens.

	method New() constructor
	method setup(cArquivo)
	method setStatus(nStatus)
	method setPercent(nPercent)
	method setMessage(cMessage)
	method endProgress()
endclass

method New() class BSCProgressbar
return

method setup(cArquivo) class BSCProgressbar
	local oResposta
	local oRetornos
	local oAttrib	
	cArquivo += ".xml"
	::oThreadFile := TBIFileIO():New(::oOwner():cBscPath()+"thread\"+cArquivo)

	//Se existir o arquivo de thread, exclui
	if ::oThreadFile:lExists()
		if(!::oThreadFile:lErase())
			::oOwner():Log(STR0003+" ["+cArquivo+"]", BSC_LOG_SCRFILE) //Arquivo de controle de thread ja esta em uso
			::oOwner():Log(STR0002, BSC_LOG_SCRFILE)					 //Operação abortada
			return .F.
		endif               
	endif

	// Cria o arquivo de Thread Collector
	if ! ::oThreadFile:lCreate(FO_READWRITE,.T.)
		::oOwner():Log(STR0004+" ["+cArquivo+"]", BSC_LOG_SCRFILE)	//Erro na criação do arquivo de Thread Collector
		::oOwner():Log(STR0002, BSC_LOG_SCRFILE)						//Operação abortada
		return .F.
	endif	

	// Cria a estrutura do arquivo de Thread Collector
	::oXMLRespostas:= TBIXMLNode():New("REPOSTAS")
	
	oResposta		:= 	::oXMLRespostas:oAddChild(TBIXMLNode():New("RESPOSTA"))
	//oResposta:oAddChild(TBIXMLNode():New("STATUS",0,))
	oRetornos		:=	oResposta:oAddChild(TBIXMLNode():New("RETORNOS"))
	::oXMLThread	:=	oRetornos:oAddChild(TBIXMLNode():New("THREAD"))

	oAttrib 	:= TBIXMLAttrib():New()
	oAttrib:lSet("DATA", Date())
	oAttrib:lSet("HORA", Time())
	
	::oNodeStatus	:=	TBIXMLNode():New("STATUS",PROGRESS_BAR_OK)
	::oNodePercent	:=	TBIXMLNode():New("PERCENT",0)
	::oNodeMessage	:=	TBIXMLNode():New("MESSAGE",STR0001) //"Iniciando o processamento"

	::oXMLThread:oAddChild(TBIXMLNode():New("BEGIN",,oAttrib))
	::oXMLThread:oAddChild(::oNodeStatus)
	::oXMLThread:oAddChild(::oNodePercent)
	::oXMLThread:oAddChild(::oNodeMessage)

	// Grava estrutura XML no arquivo de Thread Collector
	::oThreadFile:nWrite(::oXMLRespostas:cXMLString(.T., "ISO-8859-1"))     
	::oThreadFile:lClose()	
	
return .T.

method setStatus(nStatus) class BSCProgressbar  
	local lOpen := .T.
	
	if ! ::oThreadFile:lIsOpen()	
		if ! ::oThreadFile:lCreate(FO_READWRITE,.T.)
			::oThreadFile:Free()
			lOpen	:=	 .F.
		endif
	endif			
	
	if lOpen
		::oThreadFile:nGoBOF()
		::oNodeStatus:SetValue(nStatus)	
		::oThreadFile:nWrite(::oXMLRespostas:cXMLString(.T., "ISO-8859-1"))	
	endif

	::oThreadFile:lClose()				
	
return .T.

method setPercent(nPercent) class BSCProgressbar  
	local lOpen := .T.

	if ! ::oThreadFile:lIsOpen()	
		if ! ::oThreadFile:lCreate(FO_READWRITE,.T.)
			::oThreadFile:Free()
			lOpen	:=	 .F.
		endif
	endif			

	if lOpen
		::oThreadFile:nGoBOF()
		::oNodePercent:SetValue(nPercent)
		::oThreadFile:nWrite(::oXMLRespostas:cXMLString(.T., "ISO-8859-1"))		
	endif

	::oThreadFile:lClose()	
	
return .T.


method setMessage(cMessage) class BSCProgressbar  
	local lOpen := .T.

	if ! ::oThreadFile:lIsOpen()	
		if ! ::oThreadFile:lCreate(FO_READWRITE,.T.)
			::oThreadFile:Free()
			lOpen	:=	 .F.
		endif
	endif			

	if lOpen
		::oThreadFile:nGoBOF()
		::oNodeMessage:SetValue(cMessage)
		::oThreadFile:nWrite(::oXMLRespostas:cXMLString(.T., "ISO-8859-1"))		
	endif

	::oThreadFile:lClose()	
	
return .T.


method endProgress() class BSCProgressbar  
	// Cria estrutura de finalização de processos no arquivo de Thread Collector		
	local oAttrib 	:= TBIXMLAttrib():New()
	oAttrib:lSet("DATA", Date())
	oAttrib:lSet("HORA", Time())
		
	::oXMLThread:oAddChild(TBIXMLNode():New("END",,oAttrib))

	// Grava estrutura XML no arquivo de Thread Collector
	::oThreadFile:nGoBOF()
	::oThreadFile:nWrite(::oXMLRespostas:cXMLString(.T., "ISO-8859-1"))
	                  
	// Fecha arquivo de Thread Collector
	::oThreadFile:lClose()

	::setStatus(PROGRESS_BAR_END)

return .T.

function _BSCProgressbar()
return