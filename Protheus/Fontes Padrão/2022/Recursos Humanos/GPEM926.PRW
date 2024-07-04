#Include "PROTHEUS.CH"
#Include "TBICONN.CH"
#Include "GPEM926.CH"

/*/{Protheus.doc} GPEM926
Criação de tela para preenchimento dos dados de autenticação dos webservices da NG
@type function
@version 12.1.27
@author felipe.alves
@since 11/12/2020
@return
/*/

Function GPEM926()
Local lNG as Logical
Local cCadastro as Character
Local oURING as Object
Local oUsrNG as Object
Local oPassNG as Object
Local cURING as Character
Local cUsrNG as Character
Local cPassNG as Character
Local cMsg1 as Character
Local cMsg2 as Character
Local oDlg as Object
Local nOpc as Numeric

lNG := GetNewPar("MV_RHNG", .F.)

If (lNG)
    cCadastro := STR0001//"Autenticação dos webservices NG"
    oURING    := Nil
    oUsrNG    := Nil
    oPassNG   := Nil
    cURING    := Iif(!Empty(GetNewPar("MV_URIQR", Space(255))), GetNewPar("MV_URIQR", Space(255)) + Space(255 - Len(GetNewPar("MV_URIQR", Space(255)))), Space(255))
    cUsrNG    := Iif(!Empty(GetNewPar("MV_EMAILQR", Space(255))), Decode64(GetNewPar("MV_EMAILQR", Space(255))) + Space(255 - Len(Decode64(GetNewPar("MV_EMAILQR", Space(255))))), Space(255))
    cPassNG   := Iif(!Empty(GetNewPar("MV_SENHAQR", Space(255))), Decode64(GetNewPar("MV_SENHAQR", Space(255))) + Space(255 - Len(Decode64(GetNewPar("MV_SENHAQR", Space(255))))), Space(255))

    cMsg1     := OemToAnsi(STR0002) + CRLF //"Essa rotina permite configurar a autenticação de segurança dos webservices"
    cMsg1     += OemToAnsi(STR0003) + CRLF //"utilizados nas rotinas de integração NG."

    cMsg2     := OemToAnsi(STR0004) + CRLF //"Informar URI, usuário e senha de acesso ao Protheus para validação de integridade dos dados."
    cMsg2     += OemToAnsi(STR0005) + CRLF //"Essas informações serão utilizadas para a autenticação dos webservices de integração NG."

	DEFINE MSDIALOG oDlg TITLE cCadastro From 10,30 To 220,500 OF oMainWnd PIXEL

		@ 6,4  SAY OemToAnsi(cMsg1) OF oDlg  PIXEL
		@ 20,4 SAY OemToAnsi(cMsg2) OF oDlg  PIXEL

		@ 45,4  SAY OemToAnsi(STR0006) OF oDlg  PIXEL //"URI"
		@ 44,30 MSGET oURING VAR cURING SIZE 80,08 PICTURE  VALID .T.  OF oDlg PIXEL

        @ 59,4  SAY OemToAnsi(STR0007) OF oDlg  PIXEL //"Usuário"
		@ 58,30 MSGET oUsrNG VAR cUsrNG SIZE 80,08 PICTURE  VALID .T.  OF oDlg PIXEL

		@ 73,4  SAY OemToAnsi(STR0008) OF oDlg PIXEL //"Senha"
		@ 72,30 MSGET oPassNG VAR cPassNG  SIZE 65,08 PICTURE  VALID .T. OF oDlg PIXEL PASSWORD 


		DEFINE SBUTTON FROM 89,10 TYPE 1 ACTION (nOpc := 1, Iif(ProcDados(cURING, cUsrNG, cPassNG), oDlg:End(), .F.)) ENABLE OF oDlg
		DEFINE SBUTTON FROM 89,40 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		
	ACTIVATE MSDIALOG oDlg CENTERED
Else
    Help(Nil, Nil, STR0009, Nil, STR0010, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0011}) //"MV_RHNG"##"A integração SIGAGPE x NG não está configurada neste ambiente."##"Verifique a configuração do parâmetro MV_RHNG."
Endif

Return()

/*/{Protheus.doc} ProcDados
Função que realiza a gravação dos parâmetros dos dados de autenticação dos webservices da NG
@type function
@version 12.1.27
@author felipe.alves
@since 11/12/2020
@return logical, retorna se função foi processada com sucesso.
/*/

Static Function ProcDados(cURING as Character, cUsrNG as Character, cPassNG as Character)
Local lRet as Logical

Default cURING := ""
Default cUsrNG := ""
Default cPassNG := ""

lRet := .T.

If !(Empty(cURING))
	PutMv("MV_URIQR", cURING)
Endif

If !(Empty(cUsrNG))
	PutMv("MV_EMAILQR", Encode64(AllTrim(cUsrNG)))
Endif

If !(Empty(cPassNG))
	PutMv("MV_SENHAQR", Encode64(AllTrim(cPassNG)))
Endif

MsgInfo(OemToAnsi(STR0012)) //Parâmetros atualizados com sucesso.

Return(lRet)
