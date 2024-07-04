#include "Protheus.ch"
#INCLUDE "WFMAILBOX.ch"
#INCLUDE "protheus.ch"
#Include "SIGAWF.CH" 

class TWFQueueManager      
data cServer
data nPort
data cQEmp
data cQFil
data cEnvironment
data cMailbox 
data oRpcConnection  
data aQueues
data nNumberOfQueues  
data oSmallerQueue

method New() CONSTRUCTOR        
method GetTotalNumberOfEmails()  
method GetNumberOfEmail() 
method GetTheSmallerQueue()  

EndClass

method New(aQueues) class TWFQueueManager  
	::aQueues:=aQueues
	::nNumberOfQueues:=Len(::aQueues)
return Self

method GetNumberOfEmail(oMailbox)  Class TWFQueueManager   

	Local oOutboxFolder		:= Nil  
	Local nNumberOfMessages := 0  
	
	oOutboxFolder     := oMailBox:GetFolder( MBF_OUTBOX )   
	nNumberOfMessages :=  Len( oOutboxFolder:GetFiles("*.wfm") ) 
		
Return nNumberOfMessages     

method GetTheSmallerQueue() class TWFQueueManager         
	Local nQueueIndex:=1 
	Local nSmallerNumberOfEmail:= 999999
	Local nIndexOfSmallerQueue :=0 
	Local nNumberOfEmails := 0
	
	::nNumberOfQueues:=(Len(::aQueues))   
	oTWFSmallerQueue:=::aQueues[1]
	For nQueueIndex:=1 to ::nNumberOfQueues
	    nNumberOfEmails:= ::GetNumberOfEmail(::aQueues[nQueueIndex])
		If( nNumberOfEmails  < nSmallerNumberOfEmail) 
	 	    nIndexOfSmallerQueue:=nQueueIndex
	 	    nSmallerNumberOfEmail:=nNumberOfEmails
	 	EndIf  	
	Next
			       
Return  nIndexOfSmallerQueue  

Function __TWFQueueManager()
Return		   