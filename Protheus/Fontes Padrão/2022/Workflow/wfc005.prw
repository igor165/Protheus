#INCLUDE "PROTHEUS.CH"  
#include "SIGAWF.CH"
#INCLUDE "WFC005.CH" 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WFC005
Fun��o para configura��o e execu��o de limpeza de Workflow.
   
@param 		Array contendo Empresa, Filial e n�mero de dias. 
@author    	Valdiney V. Gomes 
@author     Pedro I. Gomes
@version   	P11
@since      06/10/2011
/*/
//-------------------------------------------------------------------------------------  
Function WFCleanUp( aParams ) 
	Local oStream		:= WFStream()
   	Local pcEmpresa		:= ""
   	Local pcFilial     	:= ""
   	Local pnDays        := 0
        
    Default aParams 	:= {"99", "01", 01 }  
              
	pcEmpresa 	:= cBIStr( aParams[1] )
	pcFilial    := cBIStr( aParams[2] )
	pnDays      := nBIVal( aParams[3] )

	WFConOut( STR0001 , oStream, .F., .F. ) //"Manuten��o de Diret�rios do Workflow"
  	WFConOut( STR0002 + pcEmpresa , oStream, .F., .F.  )//"Empresa: "   
   	WFConOut( STR0003 + pcFilial	, oStream, .F., .F.  )//"Filial: "     
    WFConOut( STR0004 + cBIStr( Date() - pnDays ) , oStream, .F., .F.  ) //"Arquivos anteriores �: " 
	
	WFClean(oStream, pcEmpresa, pcFilial, pnDays)  
	WFNotifyAdmin( , WF_NOTIFY, oStream:GetBuffer( .T. ) ) 
Return  
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WFC005
Fun��o para configura��o e execu��o de limpeza de Workflow.
   
@param 		Objeto de stream de Log.  
@param      Empresa corrente
@param      Filial corrente  
@param 		N�mero de dias que em que os arquivos ser�o mantidos.
@author    	Valdiney V. Gomes 
@author     Pedro I. Gomes
@version   	P11
@since      06/10/2011
/*/
//-------------------------------------------------------------------------------------  
Static Function WFClean( oStream, pcEmpresa, pcFilial, pnDays )
	Local oWF 		:= TWorkflow():New( { pcEmpresa, pcFilial } )       
	Local oMailBox 	:= oWF:oMail:GetMailBox( AllTrim( oWF:cMailBox ) )              

	WFClearSent( oStream, oMailBox,  pnDays )
	WFClearArchive( oStream, oMailBox,  pnDays ) 
	WFClearIgnored( oStream,  oMailBox, pnDays ) 	
 	WFClearError( oStream, oMailBox, pnDays ) 
 	WFClearProcess( oStream, oWF, pnDays )       
Return  
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WFC005
Fun��o para a limpeza dos diret�rios de emails enviados.
   
@param 		Objeto de stream de Log.
@param 		Objeto da inst�ncia do MailBox.  
@param 		N�mero de dias que em que os arquivos ser�o mantidos.
@author    	Valdiney V. Gomes 
@author     Pedro I. Gomes
@version   	P11
@since      06/10/2011
/*/
//-------------------------------------------------------------------------------------   
Static Function WFClearSent( oStream, poMailBox, pnDays )   
	WFConOut( STR0005 + "[Sent]" , oStream, .T., .T., .T. ) // "Manuten��o do diret�rio " 
	WFMailCleaner( oStream, poMailBox, MBF_SENT,  pnDays )
return .t.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WFC005
Fun��o para a limpeza dos diret�rios de arquivos.
	
@param 		Objeto de stream de Log.
@param 		Objeto da inst�ncia do MailBox.  
@param 		N�mero de dias que em que os arquivos ser�o mantidos.
@author    	Valdiney V. Gomes 
@author     Pedro I. Gomes
@version   	P11
@since      06/10/2011
/*/
//-------------------------------------------------------------------------------------  
Static Function WFClearArchive( oStream, poMailBox, pnDays )   
	WFConOut( STR0005 + "[Archive]", oStream, .T., .T., .T. )// "Manuten��o do diret�rio " 
	WFMailCleaner( oStream, poMailBox, MBF_ARCHIVE,  pnDays )
return .t.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WFC005
Fun��o para a limpeza dos diret�rios de arquivos ignorados.
	
@param 		Objeto de stream de Log.
@param 		Objeto da inst�ncia do MailBox.  
@param 		N�mero de dias que em que os arquivos ser�o mantidos.
@author    	Valdiney V. Gomes 
@author     Pedro I. Gomes
@version   	P11
@since      06/10/2011
/*/
//-------------------------------------------------------------------------------------   
Static Function WFClearIgnored( oStream, poMailBox, pnDays ) 
	WFConOut( STR0005 + "[Ignored]", oStream, .T., .T., .T. )// "Manuten��o do diret�rio " 
	WFMailCleaner( oStream, poMailBox, MBF_IGNORED, pnDays )
return .t.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WFC005
Fun��o para a limpeza dos diret�rios de erros

@param 		Objeto de stream de Log.
@param 		Objeto da inst�ncia do MailBox.  
@param 		N�mero de dias que em que os arquivos ser�o mantidos.
@author    	Valdiney V. Gomes 
@author     Pedro I. Gomes
@version   	P11
@since      06/10/2011
/*/
//-------------------------------------------------------------------------------------  
Static Function WFClearError( oStream, poMailBox, pnDays )   
	WFConOut( STR0005 + "[Error]", oStream, .T., .T., .T. )// "Manuten��o do diret�rio " 
	WFMailCleaner( oStream, poMailBox, MBF_OUTBOX + MBF_ERROR, pnDays )
return .t.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WFC005
Fun��o para a limpeza dos diret�rios de processo
    
@param 		Objeto de stream de Log.
@param 		Objeto da inst�ncia do Workflow.  
@param 		N�mero de dias que em que os arquivos ser�o mantidos.
@author    	Valdiney V. Gomes 
@author     Pedro I. Gomes
@version   	P11
@since      06/10/2011
/*/
//------------------------------------------------------------------------------------- 
Static Function WFClearProcess( oStream, poWF, pnDays )
	Local cProcess		:= ""   //C�digo do Processo a ser verificado na WF3
	Local cTask			:= ""  	//C�digo da Tarefa a ser verificada na WF3                   
    Local nFile			:= 0    //Contador 
    Local cDirectory 	:= ""	//Diret�rio dos arquivos de processo do WF 
    Local cPath			:= ""   //Caminho completo do arquivo a ser processado. 
    Local aFiles		:= {}	//Arquivos de processo '.val'    
          
    Default poWF 		:= Nil
    Default pnDays		:= 0 
                 
    cDirectory 	:= cBIFixPath( poWF:cProcessDir, "\" )  
 	aFiles		:= Directory( cDirectory + "*.val" )  
     
    WFConOut( STR0005 + "[Process]", oStream, .T., .T., .T. )   
	
    For nFile := 1 To Len( aFiles )                           
	 	cFile  		:= StrTran( Lower( aFiles [nFile, 1 /*F_NAME*/] ), ".val" ) 
	 	cProcess 	:= extProcID( cFile )
		cTask  		:= extTaskID( cFile )          
         
        //Remove todos os arquivos de processos/tarefas finalizadas.                                             
		If ( WFChkProcEvent( cProcess, cTask, EV_FINISH ) ) 
		   	cPath := cDirectory + cFile + ".val"   
      		WFConOut( cFile + ".val" )           
            
            //Remove os arquivos '.val'.                                
			If ( FErase( cPath ) == 0 )      
				cPath := cDirectory + cFile + ".oct" 
                
				//Remove os arquivos '.oct'.
			    If ( File( cPath ) )
			    	WFConOut( cFile + ".oct" ) 
               		FErase( cPath )
				EndIf
			EndIf		
		EndIf	                              
    Next nFile 
Return Nil      
    
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WFC005
Fun��o gen�rica para a limpeza dos diret�rios de email do Workflow
		
@param 		Objeto de stream de Log.
@param 		Objeto do MailBox corrente.
@param 		Diret�rio a ser limpo.  
@param 		N�mero de dias que em que os arquivos ser�o mantidos.
@author    	Valdiney V. Gomes 
@author     Pedro I. Gomes
@version   	P11
@since      06/10/2011
/*/
//------------------------------------------------------------------------------------- 
Static Function WFMailCleaner( oStream, poMailBox, cFolder, pnDays )
    Local cDirectory 	:= ""	//Diret�rio dos arquivos do WF. 
    Local cPath			:= ""   //Caminho completo do arquivo a ser processado.  
    Local aFiles		:= {}	//Arquivos e diret�rios.    
    Local aFilesInDir	:= {}	//Arquivos  contidos em diret�rios de data.      
    Local nFile			:= 0    //Contador de arquivos. 
    Local nFileInDir	:= 0    //Contador de arquivos contidos em diret�rios de data.  
	Local dDate			:= Nil  //Nome de diret�rios de datas. 
	Local oFolder  		:= Nil  //Objeto do diret�rio do mailbox. 
	
	Default poMailBox	:= Nil
    Default cFolder		:= ""
    Default pnDays		:= 0    
                   
	oFolder		:= poMailBox:GetFolder( cFolder )
	cDirectory 	:= cBIFixPath( oFolder:cRootPath, "\" ) 
 	aFiles		:= Directory( cBIFixPath( cDirectory, "\" ) + "*.*", "D" ) 

 	For nFile := 1 To Len( aFiles )           
 		cFile := Lower( aFiles [nFile, 1 /*F_NAME*/] )
        
		//Identifica se � um diret�rio ou um arquivo. 
 		If ( aFiles [nFile, 5 /*F_ATT*/] == "D" ) 
 			dDate 	:= STod( cFile ) 	 
 		                             
 			If ! ( Empty( StrTran ( cBIStr( dDate ) , "/" ) ) ) 
 				//Remove os arquivos contifos nos diret�rios que estejam fora do per�odo. 
		 		if( Date() > ( dDate + pnDays ) )                                               
		 			cPath 		:= cBIFixPath( cDirectory + cFile , "\" )
		 			aFilesInDir  := Directory( cPath + "*.*" ) 
		 			 
		 			//Remove os arquivos.           
					For nFileInDir := 1 to Len( aFilesInDir )  
						WFConOut( aFilesInDir[nFileInDir, 1 /*F_NAME*/] )                                                              
			  			FErase( cPath + aFilesInDir[nFileInDir, 1 /*F_NAME*/] )
			  		Next nFileInDir
			  		
			  		//Remove o diret�rio.  
			  		WFConOut(  STR0006 + cBIStr( SToD( cFile ) ) + " " +  STR0007, oStream ) // "Arquivos de: "  data da pasta    "removidos!" 
			  		DirRemove ( cPath )  		 		
				EndIf
			EndIf   
		else
 			dDate 	:= aFiles [nFile, 3 /*F_DATE*/]	 
  		   	cPath	:= cDirectory + cFile 

  		   	//Remove todos os arquivos que estejam fora do per�odo. 
  		    If( Date() > ( dDate + pnDays ) ) 
  		    	WFConOut( cFile )  
  		       	FErase( cPath )
  		    EndIf
 		EndIf 
   	Next nFile    
Return Nil 