#INCLUDE "PROTHEUS.CH"
#INCLUDE "PONERROR.CH"
    
/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �InPonErrorExec�Autor �Mauricio MR		   � Data �05/02/2008�
������������������������������������������������������������������������Ĵ
�Descri��o �Executar Funcoes Dentro do PonError  	                     �
������������������������������������������������������������������������Ĵ
�Sintaxe   �InPonErrorExec( cExecIn , aFormParam )						 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �uRet                                                 	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
�Uso       �Generico 													 �
��������������������������������������������������������������������������/*/
Function InPonErrorExec( cExecIn , aFormParam )
         
Local uRet

DEFAULT cExecIn		:= ""
DEFAULT aFormParam	:= {}

IF !Empty( cExecIn )
	cExecIn	:= BldcExecInFun( cExecIn , aFormParam )
	uRet	:= __ExecMacro( cExecIn )
EndIF

Return( uRet )

/*/
�����������������������������������������������������������������������Ŀ
�Classe    �PONError      � Autor � Mauricio MR       � Data �26/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Classe para a criacao do Objeto Error						�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj	:= PONError():New() 								�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/
class PONError  

    
    data aMsgErrors
	data aLogErrors  
	data aLogFile
	data aLogTitle
	data cTextError
	data lErros
	data lShowErrors
	data lWorkFlow
	data bLoadErrors
	
	method New() constructor
  	method SendError(cNumber)
	method GetError(cNumber) 
	method GetMsgError(cNumber)  
	method ShowErrors()
	method SearchError(cNumber)
	method RecordError(cNumberError,cString)
	method InitLogErrors(aMsg)
	method LoadCalError()
	method MontaError()
	method TelaError()

endclass

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �New           � Autor � Mauricio MR       � Data �05/02/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para instanciar o objeto PONError					�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj	:= PONError():New() 								�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/ 	
Method New() class PONError

	::aMsgErrors := {}
	::aLogErrors := {} 
	::aLogFile   := {}
	::aLogTitle  := {}
	::cTextError := ''
	::lErros	 := .F. 
	::lShowErrors:= .T.
	::lWorkFlow	 := .F.

Return(Nil)	

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �GetError      � Autor � Mauricio MR       � Data �05/02/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para Obter Error  									�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �GetError(cNumberError) 						    			�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/ 	
Method GetError(cNumberError) class PONError

Local nError 
Local cError	:= ""

If !Empty( ( nError:=::SearchError(cNumberError) ) )
	cError:= ::aLogErrors[nError,2]
Endif	

Return (cError)

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �GetMsgError   � Autor � Mauricio MR       � Data �05/02/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para Obter Memsagem de Erros							�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �GetMsgError(cNumberError) 					    			�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/ 	
Method GetMsgError(cNumberError) class PONError

Local nError 
Local cError	:= ""

If !Empty( ( nError:= Ascan(::aMsgErrors, {|x| ( x[1] = cNumberError ) }) ) )
	If !Empty(::aMsgErrors[nError,2])
		cError:= Space(4) + ::aMsgErrors[nError,2]
	EndIf
Endif	

Return (cError)

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �SendError     � Autor � Mauricio MR       � Data �05/02/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para registrar Erro									�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �SendError(cNumberError) 									�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/ 	
Method SendError(cNumberError,cStringError, lOnce) class PONError

DEFAULT lOnce			:= .T.
DEFAULT cStringError	:= ""

If lOnce
	If Empty(::SearchError(cNumberError))
	     ::RecordError(cNumberError, cStringError)
	endif    
else	                                     
   ::RecordError(cNumberError, cStringError)
Endif	
Return( Nil )
     
/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �SearchError   � Autor � Mauricio MR       � Data �05/02/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para pesquisar Erro									�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �SearchError(cNumberError) 									�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/ 	
Method SearchError(cNumberError) class PONError

Local nRet:= Ascan(::aLogErrors, {|x| ( x[1] = cNumberError ) })

Return(nRet)     

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �InitLogErrors � Autor � Mauricio MR       � Data �05/02/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para registrar Erro									�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �SearchError(cNumberError) 									�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/ 	
Method InitLogErrors(aMsg) class PONError

::aLogErrors	:={}
::lErros		:= .F.
::aMsgErrors 	:= aMsg

Return()     

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �RecordError   � Autor � Mauricio MR       � Data �05/02/2008�
�����������������������������������������������������������������������Ĵ                 		
�Descri��o �Funcao para registrar Erro			  						�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �RecordError(cNumberError) 									�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/ 	
Method RecordError(cNumberError, cString) class PONError

aAdd(::aLogErrors, {cNumberError,cString})

::lErros:= .T.

Return(Nil) 

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �ShowErrors()  � Autor � Mauricio MR       � Data �05/02/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo mostrar os erros registrados							�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj	:= PONError():New() 								�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/ 	
Method ShowErrors() class PONError
Local cFileLog := ''

    //Se existir erros e se deseja demonstra-los
    If ::lErros
    	::MontaError()
    EndIf
    
    If ::lShowErrors
		If ::lWorkFlow 
		
			cFileLog := fMakeLog(	::aLogFile 	  ,;	//01 - Array que contem os Detalhes de Ocorrencia de Log
									::aLogTitle	  ,;	//02 - Array que contem os Titulos de Acordo com as Ocorrencias
									NIL			  ,;	//03 - Pergunte a Ser Listado
									!(::lWorkFlow),;	//04 - Se Havera "Display" de Tela
									NIL   		  ,;	//05 - Nome Alternativo do Log
									NIL			  ,;	//06 - Titulo Alternativo do Log
									'M'			  ,;	//07 - Tamanho Vertical do Relatorio de Log ("P","M","G")
									NIL			  ,;	//08 - Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
									NIL			  ,;	//09 - Array com a Mesma Estrutura do aReturn
									NIL			  ;		//10 - Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
								  )
			ConOut("")
			ConOut( STR0002 + cFileLog ) 	//"Processamento Finalizado. Consulte SPOOL : "
			ConOut("")
		Else
			::TelaError()
		EndIf
	EndIf
	
Return(Nil)

/*
������������������������������������������������������������������������Ŀ
�Metodo    �TelaError   � Autor �Leandro Drumond	   � Data �20/06/2008�
������������������������������������������������������������������������Ĵ
�Descri��o �Monta Tela de Erros do SIGAPON.	  							 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �TelaError()			  									 	 �
������������������������������������������������������������������������Ĵ
�Parametros�<VOID>                                               		 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                            	     	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONERROR					                                 �
��������������������������������������������������������������������������*/
Method MontaError() class PONError

Local nX     		:= 0

If ::lWorkFlow
	::aLogTitle := { STR0001 + " " + Dtoc(dDatabase) + ' - ' + Time() }    // "Log de Erros do SIGAPON xx/xx/xx 99:99:99 "
		
	//Corre todas as linhas de erros
	::aLogFile := {{}}
	
	For nX:=1 to Len( ::aLogErrors )  
	    aAdd( ::aLogFile[1] , ::GetMsgError( ::aLogErrors[ nX, 1] ) + " " + ::aLogErrors[ nX, 2] )
	Next nX
Else
	::cTextError := STR0001 + " " + Dtoc(dDatabase) + ' - ' + Time() + ' '  + CHR(13) + CHR(10)    // "Log de Erros do SIGAPON xx/xx/xx 99:99:99 "
	
	//Corre todas as linhas de erros
	For nX:=1 to Len( ::aLogErrors )  
	    ::cTextError += ::GetMsgError( ::aLogErrors[ nX, 1] ) + " " + ::aLogErrors[ nX, 2] + CHR(13) + CHR(10)
	Next nX

	__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",::cTextError)
EndIf

Return(.T.)

/*
������������������������������������������������������������������������Ŀ
�Metodo    �MontaError  � Autor �Leandro Drumond	   � Data �19/06/2008�
������������������������������������������������������������������������Ĵ
�Descri��o �Monta Log de Erros do SIGAPON.	  							 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �Function MontaError(oObjError)							 	 �
������������������������������������������������������������������������Ĵ
�Parametros�<VOID>                                               		 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                            	     	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONERROR					                                 �
��������������������������������������������������������������������������*/
Method TelaError() class PONError
Local cFile    		:= 'LogPonER.LOG'
Local cMask    		:= 'Arquivos Texto (*.TXT) |*.txt|'
Local bSet15
Local bSet24
//��������������������������������������������������������������Ŀ
//� Declara��o de arrays para dimensionar tela		         �
//����������������������������������������������������������������
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aButtons      := {}
/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize			:= MsAdvSize()
aAdvSize[5]			:=	500 //horizontal
aAdvSize[3]			:=	252 // LARGURA
aAdvSize[4]			:=	113  // ALTURA	
aAdvSize[6]			:=  250 //Vertical	
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 2 , 2 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. ,.T.} )
aObjSize			:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE FONT oFont NAME "Mono AS" SIZE 5,12   //6,15
DEFINE MSDIALOG oDlg TITLE STR0001 From aAdvSize[7],0 to aAdvSize[6],aAdvSize[5] PIXEL       // "Log da atualizacao "

@ aObjSize[1][1],aObjSize[1][2] GET oMemo  VAR ::cTextError MEMO SIZE aObjSize[1][3],aObjSize[1][4] OF oDlg PIXEL 
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont:=oFont

bSet15 := {|| oDlg:End() }
bSet24 := {|| oDlg:End() }

aAdd( aButtons , {"SALVAR", {|| cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,::cTextError))} , STR0003 } )

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24, Nil, aButtons )CENTERED

Return(.T.)
