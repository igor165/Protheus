#INCLUDE "PROTHEUS.CH"
#INCLUDE "PONERROR.CH"
    
/*/
зддддддддддбддддддддддддддбддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁInPonErrorExecЁAutor ЁMauricio MR		   Ё Data Ё05/02/2008Ё
цддддддддддеддддддддддддддаддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁExecutar Funcoes Dentro do PonError  	                     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁInPonErrorExec( cExecIn , aFormParam )						 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁuRet                                                 	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁClasse    ЁPONError      Ё Autor Ё Mauricio MR       Ё Data Ё26/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁClasse para a criacao do Objeto Error						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj	:= PONError():New() 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁNew           Ё Autor Ё Mauricio MR       Ё Data Ё05/02/2008Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para instanciar o objeto PONError					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj	:= PONError():New() 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/ 	
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
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁGetError      Ё Autor Ё Mauricio MR       Ё Data Ё05/02/2008Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para Obter Error  									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁGetError(cNumberError) 						    			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/ 	
Method GetError(cNumberError) class PONError

Local nError 
Local cError	:= ""

If !Empty( ( nError:=::SearchError(cNumberError) ) )
	cError:= ::aLogErrors[nError,2]
Endif	

Return (cError)

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁGetMsgError   Ё Autor Ё Mauricio MR       Ё Data Ё05/02/2008Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para Obter Memsagem de Erros							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁGetMsgError(cNumberError) 					    			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/ 	
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
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁSendError     Ё Autor Ё Mauricio MR       Ё Data Ё05/02/2008Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para registrar Erro									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁSendError(cNumberError) 									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/ 	
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
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁSearchError   Ё Autor Ё Mauricio MR       Ё Data Ё05/02/2008Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para pesquisar Erro									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁSearchError(cNumberError) 									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/ 	
Method SearchError(cNumberError) class PONError

Local nRet:= Ascan(::aLogErrors, {|x| ( x[1] = cNumberError ) })

Return(nRet)     

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁInitLogErrors Ё Autor Ё Mauricio MR       Ё Data Ё05/02/2008Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para registrar Erro									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁSearchError(cNumberError) 									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/ 	
Method InitLogErrors(aMsg) class PONError

::aLogErrors	:={}
::lErros		:= .F.
::aMsgErrors 	:= aMsg

Return()     

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁRecordError   Ё Autor Ё Mauricio MR       Ё Data Ё05/02/2008Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢                 		
ЁDescri┤└o ЁFuncao para registrar Erro			  						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRecordError(cNumberError) 									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/ 	
Method RecordError(cNumberError, cString) class PONError

aAdd(::aLogErrors, {cNumberError,cString})

::lErros:= .T.

Return(Nil) 

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁShowErrors()  Ё Autor Ё Mauricio MR       Ё Data Ё05/02/2008Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo mostrar os erros registrados							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj	:= PONError():New() 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/ 	
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
зддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁTelaError   Ё Autor ЁLeandro Drumond	   Ё Data Ё20/06/2008Ё
цддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMonta Tela de Erros do SIGAPON.	  							 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁTelaError()			  									 	 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<VOID>                                               		 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                                            	     	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONERROR					                                 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
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
зддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁMontaError  Ё Autor ЁLeandro Drumond	   Ё Data Ё19/06/2008Ё
цддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMonta Log de Erros do SIGAPON.	  							 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁFunction MontaError(oObjError)							 	 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<VOID>                                               		 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                                            	     	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONERROR					                                 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Method TelaError() class PONError
Local cFile    		:= 'LogPonER.LOG'
Local cMask    		:= 'Arquivos Texto (*.TXT) |*.txt|'
Local bSet15
Local bSet24
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё DeclaraГЦo de arrays para dimensionar tela		         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aButtons      := {}
/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Monta as Dimensoes dos Objetos         					   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
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
