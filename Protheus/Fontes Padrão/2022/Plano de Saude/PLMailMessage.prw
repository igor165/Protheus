#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLMailMessage
Classe do Plano de Saúde (SIGAPLS) responsavel por enviar email 

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 07/03/2022
/*/
//------------------------------------------------------------------- 
Class PLMailMessage

    Data lMailAuth As Boolean 
    Data cMailServer As String 
    Data cMailConta	As String 
    Data cMailSenha	As String 
    Data lUseSSL As Boolean 
    Data lUseTLS As Boolean 
    Data nSMTPPort As Integer 
    Data cUserAuth As String
    Data nSMTPTime As Integer
    Data oManager As Object
    Data oMessage As Object
    Data cMsgError As String
    Data lConnect As Boolean
    Data cDirRelatorio As String
    Data lAutomacao As Boolean

    Method New() CONSTRUCTOR
    Method Connect()
    Method SendEmail(lDisconnect)
    
    Method SetEmailTo(cEmail)
    Method SetSubject(cSubject)
    Method SetMessage(cMessage)
    Method SetAttachment(aAnexos)

    Method GetMessageError()
    Method SetAutomacao()

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor da Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 07/03/2022
/*/
//------------------------------------------------------------------- 
Method New() Class PLMailMessage

    Local nPos := 0
 
    Self:oManager := TMailManager():New()
    Self:oMessage := TMailMessage():New()
    Self:oMessage:Clear()

    Self:lMailAuth := SuperGetMv("MV_RELAUTH", .F., .F.) // Se o servidor de e-mail requer autenticação
    Self:cMailServer := SuperGetMv("MV_RELSERV", .F., "") // Nome do servidor de envio de e-mail
    Self:cMailConta	:= SuperGetMV("MV_RELACNT", .F., "") // Conta utilizada no envio de e-mail
    Self:cMailSenha	:= SuperGetMV("MV_RELPSW", .F., "") // Senha da conta de e-mail     
    Self:lUseSSL := SuperGetMV("MV_RELSSL", .F., .F.) // Informe se o servidor de SMTP possui conexão do tipo segura ( SSL/TLS )
    Self:lUseTLS := SuperGetMV("MV_RELTLS", .F., .F.) // Informe se o servidor de SMTP possui conexão do tipo segura ( SSL/TLS )  
    Self:nSMTPPort := SuperGetMV("MV_PORSMTP", .F., 25) // Porta do servidor SMTP
    Self:cUserAuth := SuperGetMV("MV_RELAUSR", .F., "") // Usuário para autenticação no servidor
    Self:nSMTPTime := SuperGetMV("MV_RELTIME", .F., 120) // TimeOut no envio de e-mail 
    Self:oMessage:cFrom := IIf(!Empty(SuperGetMV("MV_RELFROM", .F., "")), SuperGetMV("MV_RELFROM", .F., ""), Self:cMailConta) // Email utilizado no campo FROM (Remetente)
    Self:cDirRelatorio := SuperGetMV("MV_RELT", .F., "")

    Self:cMsgError := ""
    Self:lConnect := .F.
    Self:lAutomacao := .F.

    If (nPos := AT(":", Self:cMailServer)) > 0
        Self:cMailServer := SubStr(Self:cMailServer, 1, nPos - 1)	
    EndIf
   
Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} Connect
Realiza a conexão/Autenticação com o Servidor de Email

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 07/03/2022
/*/
//------------------------------------------------------------------- 
Method Connect() Class PLMailMessage

    Local nError := 0

    Self:oManager:SetUseSSL(Self:lUseSSL)
    Self:oManager:SetUseTLS(Self:lUseTLS)
    Self:oManager:Init("", Self:cMailServer, Self:cMailConta, Self:cMailSenha, 0, Self:nSMTPPort)
    Self:oManager:SetSMTPTimeout(Self:nSMTPTime)

    nError := Self:oManager:SMTPConnect()

    If nError == 0 .Or. Self:lAutomacao
        If Self:lMailAuth
            nError := Self:oManager:SmtpAuth(Self:cUserAuth, Self:cMailSenha)

            If nError <> 0 .Or. Self:lAutomacao
                Self:cUserAuth := SubStr(Self:cUserAuth, 1, At("@", Self:cUserAuth) - 1)        
                nError := Self:oManager:SmtpAuth(Self:cUserAuth, Self:cMailSenha)
            EndIf
        EndIf     
    EndIf

    If nError == 0 .Or. Self:lAutomacao
        Self:lConnect := .T.
    Else
        Self:lConnect := .F.
        Self:cMsgError := Self:oManager:getErrorString(nError)
    EndIf

Return Self:lConnect


//-------------------------------------------------------------------
/*/{Protheus.doc} SendEmail
Realiza o Envio do E-mail 

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 07/03/2022
/*/
//------------------------------------------------------------------- 
Method SendEmail(lDisconnect) Class PLMailMessage

    Local lEnvio := .F.
    Local nError := 0

    Default lDisconnect := .T.

    If Self:lConnect .And. Empty(Self:cMsgError)
        nError := Self:oMessage:Send(Self:oManager)

        Self:cMsgError := IIf(nError == 0 .Or. Self:lAutomacao, "", Self:oManager:getErrorString(nError))

        If nError == 0 .Or. Self:lAutomacao
            lEnvio := .T.
        EndIf

        If lDisconnect
            Self:oManager:SmtpDisconnect()  
            Self:lConnect := .F.
        EndIf
    EndIf

Return lEnvio


//-------------------------------------------------------------------
/*/{Protheus.doc} SetEmailTo
Set o E-mail do Destinatário

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 07/03/2022
/*/
//------------------------------------------------------------------- 
Method SetEmailTo(cEmail) Class PLMailMessage

    Default cEmail := ""

    Self:oMessage:cTo := Alltrim(cEmail)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} SetSubject
Set o Assunto do E-mail

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 07/03/2022
/*/
//------------------------------------------------------------------- 
Method SetSubject(cSubject) Class PLMailMessage

    Default cSubject := ""

    Self:oMessage:cSubject := Alltrim(cSubject)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} SetMessage
Set a Mensagem do E-mail

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 07/03/2022
/*/
//------------------------------------------------------------------- 
Method SetMessage(cMessage) Class PLMailMessage

    Default cMessage := ""

    Self:oMessage:cBody := Alltrim(cMessage)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} SetAttachment
Set Arquivo como Anexo no E-mail

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 07/03/2022
/*/
//------------------------------------------------------------------- 
Method SetAttachment(aAnexos) Class PLMailMessage

    Local lAnexo := .T.
    Local cDirArquivo := ""
    Local cNomeArquivo := ""
    Local lCopyArquivo := .F.
    Local nX := 0

    Default aAnexos := {}

    If Len(aAnexos) > 0
        For nX := 1 To Len(aAnexos)

            cDirArquivo := Alltrim(aAnexos[nX])
            cNomeArquivo := Substr(cDirArquivo, RAt("\",cDirArquivo) + 1)
            
            If !File(Self:cDirRelatorio+cNomeArquivo)
                lCopyArquivo := CpyT2S(cDirArquivo, Self:cDirRelatorio)
            Else
                lCopyArquivo := .T.
            EndIf
                
            If lCopyArquivo .And. Self:oMessage:AttachFile(Self:cDirRelatorio+cNomeArquivo) >= 0
                Self:oMessage:AddAttHTag('Content-ID: <ID_conf_'+cNomeArquivo+'>')
                lAnexo := .T.
            Else
                Self:cMsgError := "Falha ao anexar arquivo: "+cNomeArquivo
                lAnexo := .F.
                Exit
            EndIf

        Next nX
    EndIf

Return lAnexo


//-------------------------------------------------------------------
/*/{Protheus.doc} GetMessageError
Retorna Messagem de Error

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 08/03/2022
/*/
//------------------------------------------------------------------- 
Method GetMessageError() Class PLMailMessage

Return Self:cMsgError


//-------------------------------------------------------------------
/*/{Protheus.doc} SetAutomacao
Define classe como teste automatizado

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 21/03/2022
/*/
//------------------------------------------------------------------- 
Method SetAutomacao() Class PLMailMessage

    Self:lAutomacao := .T.

Return