#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AUTHWSRH.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} function AuthWsRH
Rotina para cadastrar o usuariuo e senha no formato enconde64 no parametro MV_AUTHWS 
@author  Gisele Nuncherino
@since   25/09/2020
/*/
//-------------------------------------------------------------------
Function AuthWsRH()

	Local cSenha 	:= space(25)
	Local oSenha
	Local cUsr 		:= space(40)
	Local oUsr
	Local oDlg	
	Local cCadastro	:= OemToAnsi(STR0001) // Autenticação dos Webservices
	Local nOpt		:= 0
	Local cMsg1		:= ''
	Local cMsg2		:= ''
	Local aPswUser 	:= {}
	Local lAdm		:= .F.

	PswOrder(1)
	PswSeek(__cUserID, .T.)
	aPswUser:= PswRet()

	// verifica se o usuario logado pode fazer a alteracao para isso é necessário
	// fazer parte do grp de administradores do sistema.
	If ValType(aPswUser) == "A"
		If ascan(aPswUser[1][10], {|x| Alltrim(x) == "000000"}) > 0
			lAdm := .T.
		Endif
	EndIf

	If lAdm
		cMsg1 := OemToAnsi(STR0002) + CRLF //"Essa rotina permite configurar a autenticação de segurança dos webservices " 
		cMsg1 += OEMToAnsi(STR0003) + CRLF //"utilizados nas rotinas e portais do sistema." 

		cMsg2 := OEMToAnsi(STR0004) + CRLF //"Informar o usuário e senha de acesso ao Protheus para validação da integridade dos dados."
		cMsg2 += OEMToAnsi(STR0005) //"Essas informações serão utilizadas para a autenticação dos webservices. "

		DEFINE MSDIALOG oDlg TITLE cCadastro From 10,30 To 200,500 OF oMainWnd PIXEL

			@ 6,4  SAY OemToAnsi(cMsg1) OF oDlg  PIXEL
			@ 20,4 SAY OemToAnsi(cMsg2) OF oDlg  PIXEL

			@ 45,4  SAY OemToAnsi(STR0006) OF oDlg  PIXEL //"Usuário:"
			@ 44,30 MSGET oUsr VAR cUsr SIZE 80,08 PICTURE  VALID .T.  OF oDlg PIXEL

			@ 59,4  SAY OemToAnsi(STR0007) OF oDlg PIXEL //"Senha:"
			@ 58,30 MSGET oSenha VAR cSenha  SIZE 65,08 PICTURE  VALID .T. OF oDlg PIXEL PASSWORD 


			DEFINE SBUTTON FROM 75,10 TYPE 1 ACTION (nOpt := 1, if(ProcDados(cUsr,cSenha),oDlg:End(), .F.)) ENABLE OF oDlg
			DEFINE SBUTTON FROM 75,40 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
			
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		MsgAlert(OEMToAnsi(STR0012), OEMToAnsi(STR0008)) // "Atenção" # // "Usuário não possui acesso a rotina!"
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} function ProcDados(cUsr,cSenha)
Rotina para processar a validacao e gravacao dos dados no parametro
@author  Gisele Nuncherino
@since   25/09/2020
/*/
//-------------------------------------------------------------------
Static Function ProcDados(cUsr, cSenha)

	Local lRet 		:= .F.
	Local aPswUser	:= {}
	Local lAdm		:= .F.

	PswOrder(2)             		//Ordena a busca por  Nome do usuário/grupo
	If PswSeek(alltrim(cUsr))		//Procura o nome do usuário
		cUsr 	:= PswRet(1)[1][1]
		aPswUser:= PswRet()

		//verifica se o usuario faz parte do grp de administradores do sistema
		If ValType( aPswUser ) == "A"
			If ascan(aPswUser[1][10],{|x| Alltrim(x) == "000000"}) > 0
				lAdm := .T.
			Endif
		EndIf

		If lAdm
			PswOrder(1)
			//Posiciona no Cod. Usuário informado
			If PswSeek(cUsr, .T.)
				If Empty(Alltrim(cSenha))
					MsgAlert(OEMToAnsi(STR0014), OEMToAnsi(STR0008)) // "Atenção" # "É necessário informar uma senha e que usuário tenha uma senha cadastrada!"
					lRet := .F.
				Else
					// Verifica senha passada for válida conforme o cadastro do usuário
					If PswName(Alltrim(cSenha))
						//Grava o usuário e senha 
						If GetMV("MV_AUTHWS", .T.)
							If PutMv("MV_AUTHWS", rc4crypt( cUsr + ':' + alltrim(cSenha) ,"AuthWS#ReceiptID", .T.))
								MsgInfo(OemToAnsi(STR0011)) // "Autenticação do WS cadastrada com sucesso!"
								lRet := .T.
							EndIf
						Else
							MsgAlert(OEMToAnsi(STR0009), OEMToAnsi(STR0008)) // "Atenção" # "Parametro MV_AUTHWS não cadastrado!"
							lRet := .F.
						Endif					
					Else
						MsgAlert(OEMToAnsi(STR0015), OEMToAnsi(STR0008)) // "Atenção" # "A senha informada não confere com a senha cadastrada no usuário!"
						lRet := .F.
					Endif
				EndIf
			Endif
		Else
			MsgAlert(OEMToAnsi(STR0013), OEMToAnsi(STR0008)) // "Atenção" # "Usuário sem permissão para ser utilizado neste processo!"
			lRet := .F.
		Endif	
	Else
		MsgAlert(OEMToAnsi(STR0010), OEMToAnsi(STR0008)) // "Atenção" # "Dados não validados!"
		lRet := .F.
	Endif

Return lRet
