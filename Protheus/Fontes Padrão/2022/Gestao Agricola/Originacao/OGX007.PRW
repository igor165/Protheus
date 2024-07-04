#INCLUDE "OGX007.ch"
#include "protheus.ch"

#define CRLF 	Chr(13)+Chr(10)
#define XCRLF 	Chr(13)+Chr(10)+Chr(13)+Chr(10)

/** {Protheus.doc} OGX007A
Funcao utilizada no gatilho do campo NJR_OPEFIS para utilizar a
TES inteligente sugerindo o campo NJR_TESEST

@param: 	Nil
@return:	lRetorno - .t. - verdadeiro / .f. - falso
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX007A()
Local cRetorno 	:= ""
Local nExp1		:= ""
Local cExp2		:= ""
Local cExp3		:= ""
Local cExp4		:= ""
Local cExp5		:= ""
Local cExp6		:= ""
Local cExp7		:= ""

NJ0->( dbSetOrder( 1 ) )
NJ0->( dbSeek( xFilial( "NJ0" ) + M->( NJR_CODENT ) + M->( NJR_LOJENT ) ) )

If M->( NJR_TIPO ) = "1"
	nExp1 := 1
ElseIf M->( NJR_TIPO ) = "2"
	nExp1 := 2
ElseIf M->( NJR_TIPO ) = "3"
	nExp1 := 1
ElseIf M->( NJR_TIPO ) = "4"
	nExp1 := 2
EndIf
cExp2 := M->( NJR_OPEFIS )
If M->( NJR_TIPO ) $ "1|3"
	cExp3 := NJ0->( NJ0_CODFOR ) 
	cExp4 := NJ0->( NJ0_LOJFOR )
	cExp5 := "F"
EndIf
If M->( NJR_TIPO ) $ "2|4"
	cExp3 := NJ0->( NJ0_CODCLI ) 
	cExp4 := NJ0->( NJ0_LOJCLI )
	cExp5 := "C"
EndIf
cExp6 := M->( NJR_CODPRO )

cRetorno := MaTesInt( nExp1, cExp2, cExp3, cExp4, cExp5, cExp6, cExp7 )

Return( cRetorno )


/** {Protheus.doc} OGX007E
Funcao padrao para exibição e gravação automatica das mensagens de erros
ocorridas nos modelos do modulo de originação.

@param: 	Nil
@return:	lRetorno - .t. - verdadeiro / .f. - falso
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX007E( oModel, lMostraErr )
Local aErro := {}
Local cErro := ""

Default lMostraErr := .t.

aErro := oModel:GetErrorMessage()

cErro += STR0001	+ " [" + AllToChar( aErro[1] ) + "]" + Chr(13)+Chr(10) //"Id do formulário de origem:"
cErro += STR0002 		+ " [" + AllToChar( aErro[2] ) + "]" + Chr(13)+Chr(10) //"Id do campo de origem: "
cErro += STR0003 	+ " [" + AllToChar( aErro[3] ) + "]" + Chr(13)+Chr(10) //"Id do formulário de erro: "
cErro += STR0004 		+ " [" + AllToChar( aErro[4] ) + "]" + Chr(13)+Chr(10) //"Id do campo de erro: "
cErro += STR0005 				+ " [" + AllToChar( aErro[5] ) + "]" + Chr(13)+Chr(10) //"Id do erro: "
cErro += STR0006 			+ " [" + AllToChar( aErro[6] ) + "]" + Chr(13)+Chr(10) //"Mensagem do erro: "
//cErro += "Mensagem da solução: " 		+ " [" + AllToChar( aErro[7] ) + "]" + Chr(13)+Chr(10)
cErro += STR0007 			+ " [" + AllToChar( aErro[8] ) + "]" + Chr(13)+Chr(10) //"Valor atribuído: "
cErro += STR0008 			+ " [" + AllToChar( aErro[9] ) + "]" + Chr(13)+Chr(10) //"Valor anterior: "

//AutoGrLog( cErro )

If lMostraErr
	//MostraErro()
	OGX007F( cErro, AllToChar( aErro[7] ) )
EndIf

Return( )


/** {Protheus.doc} OGX007F
Funcao padrao para exibição e gravação automatica das mensagens de erros
ocorridas nos modelos do modulo de originação.

@param: 	Nil
@return:	lRetorno - .t. - verdadeiro / .f. - falso
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX007F( cTextoUm, cTextoDois )
Local oJanela	:= Nil
Local oImagem	:= Nil
Local oPnlUm	:= Nil
Local oFntUm	:= tFont():New( "Courier new", , -12, .t. )
Local oSayUm	:= Nil
Local oPnlDois	:= Nil
Local oFntDois	:= tFont():New( "Courier new", , -12, .t. )
Local oSayDois	:= Nil
Local cEmail	:= ""

Default cTextoUm	:= STR0009 //"Texto da mensagem de aviso/problema"
Default cTextoDois	:= STR0010 //"Texto da mensagem de possível solução ou ajuda"

cEmail += "<p>Cliente: " 	+ FwFilialName( cEmpAnt, cFilAnt, 2 ) + XCRLF
cEmail += "<p>Mensagem: " 	+ CRLF + AllTrim( cTextoUm ) + XCRLF
cEmail += "<p>Ajuda: " 	+ CRLF + AllTrim( cTextoDois ) + XCRLF
cEmail += "<p>Usuário: " 	+ AllTrim( cUserName ) + CRLF
cEmail += "<p>Data/Hora: " + DTOC( Date() ) + " " + Time() + CRLF

oJanela := tDialog():New( 0, 0, 480, 640, OemToAnsi( STR0011 ), /*6*/, /*7*/, /*8*/, /*9*/, /*10*/CLR_BLACK, /*11*/CLR_WHITE, /*12*/, /*13*/, /*14*/.t., /*15*/, /*16*/, /*17*/, /*18*/, /*19*/ ) //"Mensagem ao usuário..."

oImagem	:= tBitmap():New( 0, 0, 488, 48, "LOGIN", , .f., oJanela, , , .f., .f., , , .f., , .t., , .f. )
oImagem:lAutoSize := .t.
//oImagem:Align := CONTROL_ALIGN_ALLCLIENT

oGrpUm 		:= tGroup():New(  49,  99, 212, 321, "", oJanela, , , .t. )
oPnlUm		:= tPanel():New(  50, 100, "", oJanela, , , , CLR_RED , CLR_HGRAY, 220, 80, .f., .f. )
oPnlDois	:= tPanel():New( 131, 100, "", oJanela, , , , CLR_BLUE, CLR_HGRAY, 220, 80, .f., .f. )

oSayUm	:= tSay():New( 0, 0, { | | OemToAnsi( "[Mensagem]" + XCRLF + cTextoUm ) }, oPnlUm, , oFntUm, , , , .t., CLR_RED, CLR_WHITE, 10, 10, , , , , , .t. )
oSayUm:Align := CONTROL_ALIGN_ALLCLIENT
oSayUm:lTransparent := .t.
oSayUm:lWordWrap := .t.

oSayDois	:= tSay():New( 0, 0, { | | OemToAnsi( "[Possível ajuda]" + XCRLF + cTextoDois ) }, oPnlDois, , oFntDois, , , , .t., CLR_BLUE, CLR_WHITE, 10, 10, , , , , , .t. )
oSayDois:Align := CONTROL_ALIGN_ALLCLIENT
oSayDois:lTransparent := .t.
oSayDois:lWordWrap := .t.

oBtnUm 		:= tButton():New( 220, 134, OemToAnsi( STR0012 )	, oJanela, { || OGX007G( cEmail ), oJanela:End() }, 60, 12, , , .f., .t., .f., , .f., , , .f. ) //"Enviar por Email"
oBtnDois 	:= tButton():New( 220, 196, OemToAnsi( STR0013 )	, oJanela, { || oJanela:End() }, 60, 12, , , .f., .t., .f., , .f., , , .f. ) //"Salvar como..."
oBtnTres 	:= tButton():New( 220, 258, OemToAnsi( STR0014 )			, oJanela, { || oJanela:End() }, 60, 12, , , .f., .t., .f., , .f., , , .f. ) //"Fechar"

/**
oBarra		:= TMsgBar():New( oJanela, OemToAnsi( "Originação de Grãos" ), .f., .f., .f., .f., CLR_BLACK, , oFntBarra, .f. )
oItemDois 	:= TMsgItem():New( oBarra, OemToAnsi( DTOC( Date() ) + " " + Time() ), 100, oFntBarra, CLR_BLACK, , .t. )
oItemUm 	:= TMsgItem():New( oBarra, OemToAnsi( cUserName ), 100, oFntBarra, CLR_RED, , .t. )
*/

oJanela:Activate( /*1*/, /*2*/, /*3*/, /*4*/.t., /*5*/, /*6*/, /*7*/, /*8*/, /*9*/ )

OGX007G( cEmail )

Return( )


/** {Protheus.doc} OGX007G
Funcao padrao para exibição e gravação automatica das mensagens de erros
ocorridas nos modelos do modulo de originação.

@param: 	Nil
@return:	lRetorno - .t. - verdadeiro / .f. - falso
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX007G( cCorpo )
Local oServer	:= Nil
Local oMessage	:= Nil
Local cErro		:=  "ERROR:" + oServer:GetErrorString(nErro)

Default cCorpo	:= STR0015 //"Conteudo do e-mail..."
//Cria a conexão com o server STMP ( Envio de e-mail )
oServer := TMailManager():New()
oServer:SetUseSSL( .t. )
oServer:SetUseTLS( .t. )
oServer:Init( "", STR0016, STR0017, "18121988", 0, 587 ) //"smtp.gmail.com"###"ricardotomasi.armazensgerais@gmail.com"

//Seta um tempo de time out com servidor em 60 segundos
If oServer:SetSmtpTimeOut( 120 ) != 0
	FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',STR0018 , 0, 0, {}) //"Falha ao definir o time out!"
	Return( .f. )
EndIf

//Faz a conexão SMTP
If oServer:SmtpConnect() != 0
	FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',STR0019 , 0, 0, {}) //"Falha ao conectar ao servidor!"
	Return( .f. )
EndIf

If oServer:SmtpAuth( STR0017, "18121988") != 0 //"ricardotomasi.armazensgerais@gmail.com"
	FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cErro , 0, 0, {})
    oServer:SMTPDisconnect()
    Return( .f. )
EndIf

//Apos a conexão, cria o objeto da mensagem
oMessage := TMailMessage():New()

//Limpa o objeto
oMessage:Clear()

//Popula com os dados de envio
oMessage:cFrom		:= STR0020 //"[TOTVS] - Originacao"
oMessage:cTo			:= STR0021 //"ricardo.tomasi@totvs.com.br"
oMessage:cCc			:= STR0022 //"fernando.pleite@totvs.com.br"
//oMessage:cBcc		:= "microsiga@microsiga.com.br"
oMessage:cSubject		:= STR0023 //"[ Inconsistencia do Processo ]"
oMessage:cBody		:= cCorpo

//Envia o e-mail
If oMessage:Send( oServer ) != 0
	FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',STR0024 , 0, 0, {}) //"Erro ao enviar o e-mail!"
	Return( .f. )
EndIf

//Desconecta do servidor
If oServer:SmtpDisconnect() != 0
	FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',STR0025 , 0, 0, {}) //"Erro ao desconectar do servidor SMTP!"
	Return( .f. )
EndIf

Return( .t. )

/** {Protheus.doc} OGXUtlOrig
Verifica se o módulo SIGAAGR está ativo 
@param: 	Nil
@return: .t. - verdadeiro / .f. - falso
@author: 	Vanilda 
@since: 	19/03/2015
@Uso: 		SIGAAGR - GESTAO AGRONDUSTRIA */
Function OGXUtlOrig()
Local aArea := GetArea()
Local lRet := SuperGetMv("MV_SIGAAGR",,.F.)

RestArea(aArea)

Return lRet


/** {Protheus.doc} OGXUTOG
Verifica  módulo SIGAAGR(ORIGINACAO) está ativo 
@param: 	Nil
@return: .t. - verdadeiro / .f. - falso
@author: 	Vanilda 
@since: 	01/04/2015
@Uso: 		SIGAAGR - Originação de Grãos */

Function OGXUTOG()
Return SuperGetMv("MV_AGRORI",,.F.)

