#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1140.CH"

// O protheus necessita ter ao menos uma função pública para que o fonte seja exibido na inspeção de fontes do RPO.
Function LOJA1140() ; Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadChildRequester

Classe responsável por efetuar a requisição de execução da carga nos 
clientes filhos de um determinado cliente.   
 
@author Vendas CRM
@since  07/02/10
/*/
//--------------------------------------------------------------------
Class LJCInitialLoadChildRequester
	Data oFather
	Data lDownload
	Data lImport
	Data lActInChildren
	Data lKillOtherThreads
	Data aSelection
	Data lLoadPSS

	Method New()
	Method StartIL()
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New()

Contrutor
  
@param oFather Objeto LJCInitialLoadClient com o cliente pai.  
@param lDownload .T. para efetuar o download no cliente, .F. não. 
@param lImport .T. para efetuar importação no cliente, .F. não.  
@param lActInChildren .T. para replicar ação para os filhos, .F. não.
@param lKillOtherThreads .T. para se necessário derrubar os processos, .F. não
@param aSelection Array com as cargas marcadas para atualizar (mesmo indice do array de cargas) 

@return Self

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method New( oFather, lDownload, lImport, lActInChildren, lKillOtherThreads, aSelection, lLoadPSS ) Class LJCInitialLoadChildRequester
	Default lLoadPSS := .F.
	
	
	Self:oFather			:= oFather
	Self:lDownload		:= lDownload
	Self:lImport			:= lImport
	Self:lActInChildren	:= lActInChildren
	Self:lKillOtherThreads	:= lKillOtherThreads
	Self:aSelection		:= aSelection
	Self:lLoadPSS			:= lLoadPSS
	
Return                        


//-------------------------------------------------------------------
/*/{Protheus.doc} StartIL()

Solicita ao clientes filhos o início da carga.   
  
@param oClient Se informado será solicitado somente a esse cliente.
@param lUpdateAll .T. = atualizcao completa do ambiente (aplica todas as cargas incrementais pendentes no ambiente) 

@return Nil

@author Vendas CRM
@since 07/02/10

/*/
//--------------------------------------------------------------------
Method StartIL( oClient, lUpdateAll ) Class LJCInitialLoadChildRequester
	Local oLJCMessageManager		:= GetLJCMessageManager()
	Local oLJFatherMessenger	:= LJCInitialLoadMessenger():New( Self:oFather )
	Local aClientsToInitialize	:= {}
	Local oLJILResult			:= Nil
	Local oRequest				:= Nil	
	Local cFileServerURL		:= ""
	Local nCount				:= 1
	Local oLJMessenger			:= Nil
	Local oSelectorLoad		:= Nil

	Local oLJILConfiguration		:= LJCInitialLoadConfiguration():New()
	
	Default lUpdateAll := .F.
	
	LjGrvLog( "Carga","Solicita ao clientes filhos o início da carga ")
	
	If !oLJCMessageManager:HasError()	
		// Se não for informado o cliente que deve ser iniciado, inicia todos os clientes
		If oClient == Nil
			aClientsToInitialize	:= oLJFatherMessenger:GetChildren()
		Else
			aClientsToInitialize	:= { oClient }
		EndIf
		
		If Len( aClientsToInitialize ) > 0
			If !oLJCMessageManager:HasError()						
				oLJILResult	:= oLJFatherMessenger:GetILResult()
				
				If !oLJCMessageManager:HasError() .And. oLJILResult != Nil
					cFileServerURL := oLJFatherMessenger:GetFileServerURL()
					
					If !oLJCMessageManager:HasError() .And. !Empty(cFileServerURL)			
						For nCount := 1 To Len( aClientsToInitialize )
															
							oRequest := LJCInitialLoadRequest():New( oLJILResult, aClientsToInitialize[nCount], Self:lDownload, Self:lImport, Self:lActInChildren, Self:lKillOtherThreads, Self:aSelection , lUpdateAll, .F. , Self:lLoadPSS )
							
							If lUpdateAll //se for pra atualizar todo o ambiente muda a selecao de cargas recebida para a selecao baseada nas cargas pendentes do ambiente
								oSelectorLoad := LJCInitialLoadSelector():New(oLJILResult, oRequest)	
								oSelectorLoad:MarkIncLoad(aClientsToInitialize[nCount])							
							EndIf
														
							oLJMessenger := LJCInitialLoadMessenger():New( aClientsToInitialize[nCount] )
													
							oLJMessenger:StartLoadOnClient( oRequest:ToXML(.F.), cFileServerURL )
						Next
					Else
						oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadChildRequester", 1, STR0001 ) ) // "O servidor responsável por esses clientes não está configurado como servidor de arquivo."
					EndIf			
				Else
					oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadChildRequester", 1, STR0002 ) ) // "A carga inicial não está disponível no servidor responsável."
				EndIf
			EndIf
		EndIf
	EndIf	
Return