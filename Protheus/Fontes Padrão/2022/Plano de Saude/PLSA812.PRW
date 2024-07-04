#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'PLSA812.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA812
Gera Login e Senha para o Prestador com credenciamento Deferido
@author Oscar Zanin
@since 04/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA812(cCodU, cMailU, cCodLoc, cTipU, cBioU, nRecno, cNomeU, lAutoma)

Local cSenhaU		:= ""
Local cCodRDA 		:= ""
Local cCodUsr		:= PLS812CDUS() 	//Gera o sequencial do Usuário
Local cAcesso		:= AllTrim(GetNewPar("MV_CDPPRE","")) //Parâmetro para Acesso padrão do Prestador, deve estar preenchido para a Rotina funcionar
Local cPerfil		:= AllTrim(GetNewPar("MV_CDPERF",""))
Local lStatus		:= .F. 			//Indica se o usuário deu OK, ou abandonou a tela
Local aLogSen		:= {}				//Variável que vai receber o retorno do que foi digitado na tela de cadastro
										//de Login/Senha
Local lEntrada	:= .F.
Local cSenhaD		:= ""
Local lGrava		:= .F.

Default cTipU	  := "1"						 	//Tipo de Acesso
Default cBioU   := "0"						 	//Biometria
Default cNomeU  := cCodU
Default lAutoma := .F.

B9Y->(DbGoTo(nRecno))
	//Atribui o Código da RDA para validação e atribuição de Login padrão
	cCodRDA := AllTrim(B9Y->B9Y_CODRDA)
	cNomeU	 := AllTrim(Left(AllTrim(B9Y->B9Y_NOME), 40))
	
	If ExistBlock('PL812LOG')
		aLogSen := ExecBlock('PL812LOG', .F., .F.) //Ponto de entrada para customizar Login e senha
														 //O retorno do ponto de entrada deve preencher um array bidimensional
														 //aLogSen[1][x], sendo que a primeira posição (x = 1) corresponde ao 
														 // Login e a segunda posição (x = 2) corresponde à senha NÃO Criptografada
														 //Tamanho máximo do Login 20 caracteres, Tamanho máximo da senha 6 caracteres.
														 //O que for passado acima disso será truncado.
		lEntrada := .T.
	EndIF

If lEntrada
	//Caso o ponto de entrada seja utilizado
	cCodU 	 := Left(AllTrim(aLogSen[1][1]), 20) //atribui o retorno do Login
	cSenhaU := PLSCRIDEC( 1, PLS812CRSN(Left(AllTrim(aLogSen[1][2])), TamSX3("BSW_SENHA")[1]) ) //atribui o retorno da Senha
	cSenhaD := AllTrim(aLogSen[1][2])
	
Else
	//Atribui o Código da RDA para a variável que será o Login Padrão, caso cCodU venha vazio
	//Na chamada do PLSA813 o CodU é o CPF/CNPJ
	If Vazio(cCodU)
		cCodU := AllTrim(cCodRDA)
	EndIF
	//Atribui a senha padrão
	cSenhaD := AllTrim(PLS812CRSN(cCodRDA))
	cSenhaU := PLSCRIDEC( 1, cSenhaD ) //1 = Criptografa a senha
EndIf

//Verifica se existe o Código da RDA, caso não, significa que não foi deferido o credenciamento
//então não podemos permitir o cadastramento de senha, então exibimos a mensagem de erro
If AllTrim(cCodRDA) <> ""

	//Se não há acesso padrão, retorna erro devido à falta do parâmetro.
	If Empty(cAcesso)
	
		MsgInfo(STR0001 /*"Não foi possível gerar a senha, pois o Acesso padrão não está cadastrado. Favor cadastrar o Acesso padrão no Parâmetro MV_CDPPRE."*/)

	Elseif EmpTy(cPerfil)
		
		MsgInfo(STR0018) //"Não foi possível gerar a senha, pois o Perfil de acesso padrão não está cadastrado. Favor cadastrar o Perfil padrão no Parâmetro MV_CDPERF.")
	
	Else
		
		//Este parâmetro deve ser cadastrado para indicar se o cliente quer a geração "padrão" da senha, ou se
		//irá informar manualmente o Login e a Senha inicial
		If GetNewPar("MV_PLCRES", .F.)
		
			lGrava := .T.
		Else
			
			//Se foi optado pela geração manual, mostra o Dialog para input do Login e senha e retorna o resultado no Array
			AAdd(aLogSen, PLS812SL(NIL, "BSW_SENHA", .T., lAutoma) )
			cCodu		:= AllTrim(aLogSen[1][1])
			cSenhaU	:= PLSCRIDEC(1, AllTrim(alogSen[1][2]))
			cSenhaD	:= AllTrim(aLogSen[1][2])
			
			If aLogSen[1][3]				
				//Caso o usuário confirmou, com sucesso, o cadastro do Login/Senha, grava na BSW e BSO o novo usuário.
				lGrava 	:= aLogSen[1][3]			
			
			Else		
				//Caso o usuário abandone o cadastro, retorna mensagem de aviso
				MsgInfo(STR0003 /*"Cadastro de Senha cancelado pelo Usuário"*/)

			EndIf	
		EndIf
		
		If lGrava
			//Faz gravação do usuário no cadastro de usuários do Portal
			BEGIN TRANSACTION

			BSW->(RecLock( "BSW", .T. ))

				BSW->BSW_CODUSR := cCodUsr
				BSW->BSW_FILIAL := xFilial("BSW")
				BSW->BSW_LOGUSR := cCodU
				BSW->BSW_NOMUSR := cNomeU
				BSW->BSW_SENHA  := cSenhaU
				BSW->BSW_EMAIL  := cMailU
				BSW->BSW_CODACE := cAcesso
				BSW->BSW_TPPOR  := "1"
				BSW->BSW_TIPCAR := cTipU
				BSW->BSW_BIOMET := cBioU
				BSW->BSW_DTSEN  := dDataBase
				BSW->BSW_PERACE := cPerfil
	
			BSW->( MsUnLock() )

			BSO->(RecLock( "BSO", .T. ))
	
				BSO->BSO_FILIAL := xFilial("BSO")
				BSO->BSO_CODIGO := cCodRDA
				BSO->BSO_CODLOC := cCodLoc
				BSO->BSO_CODUSR := cCodUsr
				BSO->BSO_CODINT := PLSINTPAD()
	
			BSO->( MsUnLock() )
			
			//Replica para a tabela de Credenciamento
			B9Y->(DbGoTo(nRecno))
			B9Y->(RecLock( "B9Y", .F.))
			
				B9Y->B9Y_LOGIN := cCodU
				B9Y->B9Y_SENHA := cSenhaD
			
			B9Y->( MsUnlock() )

			lStatus := .T. //Controle se deu tudo certo, para exibir mensagem para o usuário

			END TRANSACTION
		EndIf
	EndIf

Else

	MsgInfo(STR0002 /*"Ainda não foi Deferida a solicitação de credenciamento! É necessário deferir a solicitação antes de gerar Login e Senha."*/)	

EndIf

//Retorna aviso se a gravação Foi bem sucedida, ou não
If lStatus
	
	MsgInfo(STR0004 /*"Login e Senha criados com sucesso!"*/)
	PLS812MAIL(cMailU)
	
Else
		
	MsgInfo(STR0005 /*"Atenção! Não foram gerados o Login e senha!"*/)
	
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS812CDUS
Prenche o Código do Usuário (Sequencial)
@author Oscar Zanin
@since 04/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS812CDUS()

LOCAL cCodUsr	:= ""
Local nTam 	:= Len( Space( TamSX3("BSW_CODUSR")[1])) //Verifica tamanho do campo

BSW->(DbSelectArea("BSW"))
BSW->(DbSetOrder(5)) //

BSW->( MsSeek(xFilial("B9Y")) )

//Busca o último CODUSR cadastrado
While( !BSW->(EOF()) .AND. BSW->(BSW_FILIAL) == xFilial("B9Y") )
	cCodUsr	:=	BSW->(BSW_CODUSR)
	BSW->( DbSkip() )
EndDo

//Incrementa o valor e formata a saída
cCodUsr := StrZero( Val(cCodUsr) + 1, nTam)

BSW->(DbCloseArea())

Return (cCodUsr)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS812SL
Permite ao usuário digitar a Senha/Login de sua preferência, caso não opte pelo Login/Senha padrões
@author Oscar Zanin
@since 05/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS812SL(oObj,cCampo,lSempre, lAutoma)

LOCAL oFont
LOCAL oDlg
Local cLogin		:= Space(TamSX3("BSW_LOGUSR")[1])
Local cLogCon		:= Space(TamSX3("BSW_LOGUSR")[1])
LOCAL cSenha 		:= Space(TamSX3("BSW_SENHA")[1])
LOCAL cSenConf 	:= Space(TamSX3("BSW_SENHA")[1])
LOCAL nOpca		:= 0
Local aRetorno 	:= {}
Local lStatus		:= .F.

DEFAULT lSempre := .F.
DEFAULT lAutoma := .F.

//Define a Fonte do Objeto
DEFINE FONT oFont NAME "Arial" SIZE 000,-012 BOLD

If !lAutoma
	//Cria a Dialog para interação do usuário
	DEFINE MSDIALOG oDlg TITLE STR0016 /*"Defina Login e Senha"*/ FROM 008.2,003.3 TO 020,055 OF GetWndDefault()

	//Campo Login
	@ 05,10 Say oSay PROMPT STR0006 /*"Login"*/ SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
	@ 18,10 MSGET oGet1 VAR cLogin SIZE 070,10 OF oDlg FONT oFont PIXEL PICTURE "@!"

	//Campo Confirmar Login
	@ 05,110 Say oSay PROMPT STR0007 /*"Confirmar Login"*/ SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
	@ 18,110 MSGET oGet2 VAR cLogCon SIZE 070,10 OF oDlg FONT oFont PIXEL PICTURE "@!"

	//Campo Senha
	@ 35,10 Say oSay PROMPT STR0008 /*"Senha"*/ SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
	@ 48,10 MSGET oGet3 VAR cSenha SIZE 070,10 OF oDlg FONT oFont PIXEL PASSWORD

	//Campo Confirmar Senha
	@ 35,110 Say oSay PROMPT STR0009 /*"Confirmar Senha"*/ SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
	@ 48,110 MSGET oGet4 VAR cSenConf SIZE 070,10 OF oDlg FONT oFont PIXEL PASSWORD

	//Botão Confirmar
	TButton():New(65,080, STR0010 /*'Confirmar'*/,,{|| Iif( PLS812VPRI(cLogin, cLogCon, cSenha, cSenConf, @lStatus) /*pré-validação e definição se houve interação com o botão confirmar*/, Eval( {|| nOpca:=1,oDlg:End() } ),Eval( {|| PLS812CONF(cLogin, cLogCon, cSenha, cSenConf) /*Gera alertas, caso encontre divergências no preenchimento*/,.F.} ) ) },040,012,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED
Else
	cLogin := 'ADMIN'
	cSenha := '12345678'
	lStatus := .T.
EndIf

//Grava retorno
AAdd(aRetorno, cLogin)
AAdd(aRetorno, cSenha)
AAdd(aRetorno, lStatus)

Return(aRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS812CONF
Confere o Preenchimento do Dialog de Login e Senha e dá o Alerta Correspondente.
@author Oscar Zanin
@since 05/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS812CONF(cLogin, cLogCon, cSenha, cSenConf)

Local lErro := .T.

If Empty(cLogin) //Verifica se foi informado o Login

	MsgInfo(STR0011 /*"Login em branco!"*/)
	lErro := .F.
		
ElseIf PLS812VLOG(cLogin) //Verifica se o Login informado já não existe

	MsgInfo(STR0012 /*"Login já cadastrado!"*/)
	lErro := .F.
	
ElseIf (cLogin <> cLogCon) //Verifica se o Login e a confirmação estão iguais

	MsgInfo(STR0013 /*"Login Não Confere!"*/)
	lErro := .F.
	
EndIf

If Empty(cSenha) .AND. lErro //Verifica se a senha foi digitadae se já não houve erro anterior

	MsgInfo(STR0014 /*"Senha em branco!"*/)
	lErro := .F.
	
ElseIf (cSenha <> cSenConf) .AND. lErro //Verifica se a senha e confirmação estão iguais e se já não houve erro anterior

	MsgInfo(STR0015 /*"Senha Não Confere!"*/)
	lErro := .F.
	
EndIf

Return (lErro)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS812VLOG
Valida se o Login escolhido já não foi Cadastrado
@author Oscar Zanin
@since 05/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS812VLOG(cLogin)

Local lRet := .F.

BSW->(DbSelectArea("BSW"))
BSW->(DbSetOrder(1))

If BSW->( MsSeek( xFilial("BSW") + cLogin ) )

	lRet := .T.

EndIf

BSW->(DbCloseArea())

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS812VPRI
Faz uma validação genérica do preenchimento, antes de realizar a posterior análise
@author Oscar Zanin
@since 05/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS812VPRI(cLogin, cLogCon, cSenha, cSenConf, lStatus)

Local lRet := .F.

If (!Empty(cSenha) .And. cSenConf==cSenha .AND. cLogCon == cLogin .AND. !Empty(cLogin) .AND. !(PLS812VLOG(cLogin)))

	lRet := .T.
	
EndIf

lStatus := .T.

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS812CRSN
Gera a senha padrão, modelo da senha 3 últimos dígitos do Protocolo + 3 últimos dígitod do CPF/CNPJ
@author Oscar Zanin
@since 05/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS812CRSN(cCodRDA)

Local cSenha := ""

B9Y->(DbSelectArea("B9Y"))
B9Y->(DbSetOrder(4))
B9Y->(MsSeek(xFilial("B9Y")+PLSINTPAD()+cCodRDA))

	cSenha := Right(AllTrim(B9Y->B9Y_NROPRO), 3)
	cSenha += Right(AllTrim(B9Y->B9Y_CPFCGC), 3)
	cSenha += PLSINTPAD()

B9Y->(DbCloseArea())

Return cSenha


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS812MAIL
Envio de e-mail conforme o passo
@author Oscar Zanin
@since 08/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS812MAIL(cMailCan)

	PLSinaliza("PLSA812     ",STR0017,1,cMailCan,"Login e Senha",;
				nil, "", "", .F., "",;
				.F., "", .F., "000002", "",;
				.F.,"")//"O e-mail referente ao envio do Login e Senha do Portal foi enviado com Sucesso!"

Return
