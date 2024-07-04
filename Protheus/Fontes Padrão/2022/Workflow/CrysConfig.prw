#include "protheus.ch"
#include "crysconfig.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CrysConfig
Gatilho para Configura��o das chaves de acesso ao banco utilizadas 
pelo Crystal.

@author  Marcia Junko
@since   28/06/2019
/*/
//-------------------------------------------------------------------
Main Function CrysConfig()
	Local oDlgLogin	   := Nil
	Local oUserAdmin   := Nil	
	Local oPswAdmin	   := Nil
	Local cUserAdmin   := Space(50)	
	Local cPswAdmin	   := Space(50)	
	Local cMsg		   := ''

	DEFINE FONT oCHFont	NAME 'Arial' WEIGHT 10 BOLD 
	DEFINE FONT oCMFont	NAME 'Arial' WEIGHT 10

	//-------------------------------------------------------------------
	// Monta tela de login
	//-------------------------------------------------------------------
	DEFINE DIALOG oDlgLogin TITLE STR0001 FROM 050, 051 TO 250,400 PIXEL //"Crystal - Database Config"

			@ 40,05 SAY STR0002 OF oDlgLogin PIXEL FONT oCMFont //"Informe o usu�rio e senha do Protheus para realizar o login."

			@ 60,05 SAY STR0003 OF oDlgLogin PIXEL FONT oCHFont //"Usu�rio:"
			@ 60,35 MSGET oUserAdmin VAR cUserAdmin SIZE 130,10 OF oDlgLogin PIXEL 

			@ 80,05 SAY STR0004 OF oDlgLogin PIXEL FONT oCHFont //"Senha:"
			@ 80,35 MSGET oPswAdmin VAR cPswAdmin SIZE 130,10 OF oDlgLogin PIXEL PASSWORD	
	
	ACTIVATE DIALOG oDlgLogin CENTERED ON INIT EnchoiceBar( oDlgLogin, ;
	{ || ( Iif( ValidLogin( cUserAdmin, cPswAdmin, @cMsg ), ;
		( DBLoginInfo(), oDlgLogin:End()), ApMsgAlert(cMsg)) ) } , ;
	{ || oDlgLogin:End() }, .F., {},,,.F.,.F.,.F.,.T., .F. ) //"O usu�rio informado n�o � Administrador do sistema."###"Dados para login incorretos."

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidLogin
Fun��o para valida��o das informa��es de login do Protheus.

@param cUser, caracter, nome do usu�rio
@param cPsw, caracter, senha do usu�rio
@return lLogged, l�gico, define se foi poss�vel realizar o login
@return cMsg, caracter, mensagem de alerta

@author  Marcia Junko
@since   28/06/2019
/*/
//-------------------------------------------------------------------
Static Function ValidLogin( cUser, cPsw, cMsg )
	Local lLogged := .F.
	Local nReturn

	nReturn := PswAdmin(cUser, cPsw)
	
	if nReturn == 0 
		lLogged := .T.
	Else
		If nReturn == 1
			cMsg := STR0005
		ElseIf nReturn == 2
			cMsg := STR0006
		EndIf
	EndIf
	
Return lLogged


//-------------------------------------------------------------------
/*/{Protheus.doc} DBLoginInfo
Gatilho para Configura��o das chaves de acesso ao banco utilizadas 
pelo Crystal.

@author  Marcia Junko
@since   28/06/2019
/*/
//-------------------------------------------------------------------
Static Function DBLoginInfo()
	Local oDBLogin	   	:= Nil
	Local oDBUser   	:= Nil	
	Local oDBPsw	   	:= Nil
	Local cDBUser   	:= Space(30)	
	Local cDBPsw	   	:= Space(30)

	DEFINE FONT oCHFont	NAME 'Arial' WEIGHT 10 BOLD 
	DEFINE FONT oCMFont	NAME 'Arial' WEIGHT 10

	//-------------------------------------------------------------------
	// Monta tela de login
	//-------------------------------------------------------------------
	DEFINE DIALOG oDBLogin TITLE STR0001 FROM 050, 051 TO 250,450 PIXEL

			@ 40,05 SAY STR0007 OF oDBLogin PIXEL FONT oCMFont //"Informe o usu�rio e senha para acesso ao banco do Protheus."

			@ 60,05 SAY STR0008 OF oDBLogin PIXEL FONT oCHFont //"Usu�rio para acesso ao banco:"
			@ 60,95 MSGET oDBUser VAR cDBUser SIZE 100,10 OF oDBLogin PIXEL 

			@ 80,05 SAY STR0009 OF oDBLogin PIXEL FONT oCHFont //"Senha para acesso ao banco:"
			@ 80,95 MSGET oDBPsw VAR cDBPsw SIZE 100,10 OF oDBLogin PIXEL PASSWORD

	ACTIVATE DIALOG oDBLogin CENTERED ON INIT EnchoiceBar( oDBLogin, ;
	{ || ( Iif( VldDBLogin( cDBUser, cDBPsw ), ;
		( Iif( SaveDBLogin( cDBUser, cDBPsw ), ( ApMsgInfo(STR0010),  oDBLogin:End() ), oDBLogin:End() ) ), ( ApMsgStop(STR0011) ) ))  } , ;
	{ || oDBLogin:End() }, .F., {},,,.F.,.F.,.F.,.T., .F. ) //"Arquivo de configura��o salvo com sucesso"###"Dados necess�rios para a configura��o n�o foram fornecidos."

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} VldDBLogin
Fun��o para valida��o das informa��es de acesso ao banco

@param cDBUser, caracter, usu�rio para acesso ao banco
@param cDBPsw, caracter, senha para acesso ao banco
@return lValid, l�gico, retorna se as informa��es necess�rias foi passada.

@author  Marcia Junko
@since   28/06/2019
/*/
//-------------------------------------------------------------------
Static Function VldDBLogin( cDBUser, cDBPsw )
	Local lValid := .T.
	
	//---------------------------------------------------------------
	// Verifica se as informa��es de login do banco foram passadas
	//---------------------------------------------------------------
	If Empty( cDBUser ) .Or. Empty( cDBPsw )
		lValid := .F.
	EndIf
Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveDBLogin
Fun��o para valida��o das informa��es de acesso ao banco

@param cDBUser, caracter, usu�rio para acesso ao banco
@param cDBPsw, caracter, senha para acesso ao banco
@return lValid, l�gico, retorna se as informa��es necess�rias foi passada.

@author  Marcia Junko
@since   28/06/2019
/*/
//-------------------------------------------------------------------
Static Function SaveDBLogin( cDBUser, cDBPsw )
	Local cCrysPath 	:= '\crystal\'
	Local cRootPath		:= GetPvProfString( GetEnvServer(), "ROOTPATH", "", GetADV97() )
	Local cCrysFile		:= 'crysdb.ini'
	Local cCriptUser 	:= ''
	Local cCriptPsw		:= '' 
	Local lCreate		:= .F.
	
	//--------------------------------------------------
	// Garante que o diret�rio estar� criado
	//--------------------------------------------------  	   
	WFForceDir( cBIFixPath( cRootPath + cCrysPath, "\") )
	
	cCriptUser 	:= BICrypt( cDBUser )
	cCriptPsw 	:= BICrypt( cDBPsw )
	
	lCreate := MemoWrite (cCrysPath + cCrysFile, cCriptUser + CRLF + cCriptPsw ) 

Return lCreate
