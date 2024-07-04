#INCLUDE "AVERAGE.CH"
#include 'ap5mail.ch'
#Define ENTER CHR(13) + CHR(10)

Function EasyServerSMTP()
Return nil

/*==============================================================================================================*
* Classe    : EasyServerSMTP
* Descri��o : Responsavel por conex�o com o servidor SMTP, assim como tamb�m responsavel pela desconex�o 
              e autentica��o no servidor
* Autor     : Bruno Akyo Kubagawa
* Data/Hora : 24 de Mar�o de 2011 - 09:30
* Obs.      :
*===============================================================================================================*/
Class EasyServerSMTP

Data oServerSMTP       // Indica o objeto da classe TMailManager
Data cSmtpServer       // Indica o endere�o ou alias do servidor de e-mail SMTP.
Data nSmtpPort         // Indica a porta de comunica��o para conex�o SMTP (Padr�o 25). 
Data cAccount          // Indica a conta de e-mail do usu�rio no servidor de e-mail para conex�o
Data cPassword         // Indica a senha do usu�rio no servidor de e-mail para conex�o
Data lAutentica        // Indica se o Servidor de Email necessita de Autentica��o
Data nTryConnection    // Indica o numero de tentativas de acesso ao servidor de emails. Caso nao seja informado o valor � 1
Data nTimeout          // Indica o Timeout no Envio de EMAIL.
Data cUserAuth         // Indica a conta de e-mail do usu�rio no servidor de e-mail para autentica��o
Data cPswAuth          // Indica a senha do usu�rio no servidor de e-mail para autentica��o
Data cErro             // Mensagem de erros

Method New(cSmtpServer,cSmtpPort,cAccount,cPassword,lAutentica,nTryConnection,nTimeout,cUserAuth,cPswAuth) Constructor
Method ConectarSMTP()  // Responsavel pela conexao com o servidor SMTP
Method DesconecSMTP()  // Responsavel pela desconexao com o servidor SMTP
Method AuthSMTP()      // Responsavel pela autentica��o no servidor de e-mail SMTP 

End Class

/*==============================================================================================================*
* M�todo    : New(cSmtpServer,cAccount,cPassword,lAutentica,nTryConnection,nTimeout,cUserAuth,cPswAuth)
* Parametro : cSmtpServer    - Nome do Servidor SMTP(envio de mensagem).
              cAccount       - Usu�rio para Autentica��o no Servidor de Email.
              cPassword      - Senha para Autentica��o no Servidor de Email
              lAutentica     - Determina se o Servidor de Email necessita de Autentica��o
              nTryConnection - Numero de tentativas de acesso ao servidor de emails. Caso nao seja informado o valor � 1
              nTimeout       - Timeout no Envio de EMAIL.
              cUserAuth      - Conta de e-mail do usu�rio no servidor de e-mail para autentica��o.
              cPswAuth       - Senha do usu�rio no servidor de e-mail para autentica��o.
* Retorno   : Self
* Classe    : EasyServerSMTP
* Descri��o : Responsavel pela instancia��o do objeto da classe (m�todo construtor)
* Autor     : Bruno Akyo Kubagawa
* Data/Hora : 24 de Mar�o de 2011 - 09:30
* Obs.      : Se o servidor utiliza uma porta diferente de 25 (padr�o), informar junto com o nome do servidor 
              no parametro "MV_WFSMTP".
              Se os parametros forem informados como nil, os atributos da classe ser�o carregadas com as 
              informa��es passada por parametros da fun��o.
*===============================================================================================================*/
Method New(cSmtpServer,cSmtpPort,cAccount,cPassword,lAutentica,nTryConnection,nTimeout,cUserAuth,cPswAuth)  Class EasyServerSMTP
Local nAt         := 0
Local cSmtpServer := cSmtpServer

   Self:cSmtpServer    := cSmtpServer
   Self:nSmtpPort      := cSmtpPort

   If (nAt := At(":",cSmtpServer)) > 0
      Self:cSmtpServer := SubStr(cSmtpServer,1,nAt-1)
      Self:nSmtpPort   := Val(SubStr(cSmtpServer,nAt+1,Len(cSmtpServer)))
   EndIf
 
   Self:cAccount       := cAccount
   Self:cPassword      := cPassword
   Self:lAutentica     := lAutentica
   Self:nTryConnection := nTryConnection
   Self:nTimeout       := nTimeout
   Self:cUserAuth      := cUserAuth
   Self:cPswAuth       := cPswAuth
   Self:cErro          := "" 
     
Return Self

/*==============================================================================================================*
* M�todo    : ConectarSMTP()
* Parametro : 
* Retorno   : nRet - Retorna zero se foi efetuado com sucesso a conex�o, sen�o retorna o valor do erro.
* Classe    : EasyServerSMTP
* Descri��o : Responsavel pela conexao com o servidor SMTP e instancia��o do objeto da classe TMailManager.
* Autor     : Bruno Akyo Kubagawa
* Data/Hora : 24 de Mar�o de 2011 - 09:30
* Obs.      : 
*===============================================================================================================*/
Method ConectarSMTP() Class EasyServerSMTP

Begin Sequence                             	
         
   //RRV - 04/10/2012 - Realiza a conex�o SMTP 
   CONNECT SMTP SERVER Self:cSmtpServer+If(Self:nSmtpPort > 0, ":" + AllTrim(Str(Self:nSmtpPort)), "") ACCOUNT Self:cAccount PASSWORD Self:cPassword TIMEOUT Self:nTimeOut Result lRet

    If(!lRet)
      GET MAIL ERROR Self:cErro
    EndIf

   
End Sequence

Return lRet

/*==============================================================================================================*
* M�todo    : DesconecSMTP()
* Parametro : 
* Retorno   : nRet - Retorna zero se foi efetuado com sucesso a desconex�o, sen�o retorna o valor do erro.
* Classe    : EasyServerSMTP
* Descri��o : Responsavel pela desconexao com o servidor SMTP.
* Autor     : Bruno Akyo Kubagawa
* Data/Hora : 24 de Mar�o de 2011 - 09:30
* Obs.      : 
*===============================================================================================================*/
Method DesconecSMTP() Class EasyServerSMTP
Local cErrorMsg
//RRV - 04/10/2012 - Desconecta do servidor
DISCONNECT SMTP SERVER RESULT lRet
   IF !lRet
      GET MAIL ERROR cErrorMsg
      MSGINFO("Erro na Desconex�o:"+cErrorMsg,"Desconex�o com servidor SMTP")
   ENDIF   

Return lRet

/*==============================================================================================================*
* M�todo    : AuthSMTP()
* Parametro : 
* Retorno   : nRet - Retorna zero se foi efetuado com sucesso a autentica��o, sen�o retorna o valor do erro.
* Classe    : EasyServerSMTP
* Descri��o : Responsavel pela autentica��o no servidor de e-mail SMTP 
* Autor     : Bruno Akyo Kubagawa
* Data/Hora : 24 de Mar�o de 2011 - 09:30
* Obs.      : 
*===============================================================================================================*/
Method AuthSMTP() Class EasyServerSMTP
Local lRet := .T.

   If !MailAuth(Self:cUserAuth,Self:cPswAuth) //RRV - 04/10/2012 - Verifica autentica��o com o servidor SMTP.
      GET MAIL ERROR Self:cErro
      lRet := .F.
   EndIf

Return lRet

/*==============================================================================================================*
* Classe    : EasyMessageSMTP
* Descri��o : Responsavel pelo envio do email e a constru��o da mensagem que sera enviado pelo email, como 
              destino (com c�pia ou c�pia oculta), o corpo, o assunto e o anexo. 
* Autor     : Bruno Akyo Kubagawa
* Data/Hora : 24 de Mar�o de 2011
* Obs.      :
*===============================================================================================================*/
Class EasyMessageSMTP

Data oMessage             // Indica o objeto do servidor
Data oServer              // Indica o obejto da classe TMailMessage
Data cAnexosExtras        // Indica os anexos
Data aAnexos              // Indica todos os anexos 
Data cMascara             // Indica o nome do arquivo ou m�scara.
Data cErro
Data cAssunto             // Assunto do e-mail FSY - 24/09/2013
Data cTextoMail           // Texto do e-mail   FSY - 24/09/2013

Method New() Constructor
Method SetObjServer(oServer) // Responsavel por Set qual objeto do servidor
Method SetAnexo(cAttach)     // Responsavel por anexar apenas um arquivo por vez no objeto oMessage
Method EnviaMail()           // Responsavel pelo envio do mail
Method ViewMail()            // Responsavel pela representa��o da tela para preenchimentos dos dados do email a ser enviado

End Class 

/*==============================================================================================================*
* M�todo    : New(cFrom,cTo,cCc,cBcc,cSubject,cBody)
* Parametro : cFrom    - Indica o remetente do email para o objeto da classe TMailMessage
              cTo      - Indica os destinat�rios do email para o objeto da classe TMailMessage, separados por ";"
              cCc      - Indica os destinat�rios com c�pia do email para o objeto da classe TMailMessage, 
                         separados por ";"
              cBcc     - Indica os destinat�rios com c�pia oculta do email para o objeto da classe TMailMessage,
                         separados por ";"
              cSubject - Indica o assunto do email para o objeto da classe TMailMessage
              cBody    - Indica o corpo (mensagem) do email para o objeto da classe TMailMessage
* Retorno   : Self
* Classe    : EasyMessageSMTP
* Descri��o : Responsavel pela instancia��o do objeto da classe (m�todo construtor) e da classe TMailMessage
* Autor     : Bruno Akyo Kubagawa
* Data/Hora : 24 de Mar�o de 2011 - 09:30
* Obs.      : 
*===============================================================================================================*/
Method New(cFrom,cTo,cCc,cBcc,cSubject,cBody) Class EasyMessageSMTP

   Self:oMessage := TMailMessage():New()
   Self:oMessage:Clear()
   If !Empty(cFrom)
      Self:oMessage:cFrom := AllTrim(cFrom)
   EndIf

   If !Empty(cTo)
      Self:oMessage:cTo := AllTrim(cTo)
   EndIf

   If !Empty(cCc)
      Self:oMessage:cCc := AllTrim(cCc)
   EndIf

   If !Empty(cBcc)
      Self:oMessage:cBcc := AllTrim(cBcc)
   EndIf

   If !Empty(cSubject)
      Self:oMessage:cSubject := AllTrim(cSubject)
   EndIf
   
   If !Empty(cBody)
      Self:oMessage:cBody := AllTrim(cBody)
   EndIf

   Self:cAnexosExtras := ""
   Self:aAnexos       := {}
   Self:cErro         := ""
   Self:cAssunto      := ""//FSY - 24/09/2013
   Self:cTextoMail    := ""//FSY - 24/09/2013

Return Self
 

/*==============================================================================================================*
* M�todo    : SetObjServer(oServer)
* Parametro : oServer - Indica o objeto do servidor para ser enviado.
* Retorno   : Nil
* Classe    : EasyMessageSMTP
* Descri��o : Responsavel obter qual objeto do servidor ser� utilizado, objeto SMTP.
* Autor     : Bruno Akyo Kubagawa
* Data/Hora : 24 de Mar�o de 2011 - 09:30
* Obs.      : 
*===============================================================================================================*/
Method SetObjServer(oServer) Class EasyMessageSMTP

   If Valtype(oServer) == "O"
      Self:oServer := oServer
   EndIf
   
Return nil

/*==============================================================================================================*
* M�todo    : SetAnexo(cAttach)
* Parametro : cAttach - Indica o arquivo que ser� anexado a partir da pasta ROOTPATH
* Retorno   : lRet    - .T. se o arquivo foi anexado com sucesso e .F. se o arquivo foi anexado incorretamente.
* Classe    : EasyMessageSMTP
* Descri��o : Responsavel por anexar um arquivo no objeto oMessage
* Autor     : Bruno Akyo Kubagawa
* Data/Hora : 24 de Mar�o de 2011 - 09:30
* Obs.      : 
*===============================================================================================================*/
Method SetAnexo(cAttach) Class EasyMessageSMTP

Local nRet
Local lRet := .T.   

Begin Sequence
   If !Empty(cAttach)
      If ASCAN(Self:aAnexos,cAttach) = 0
         Self:cAnexosExtras+= SubStr(cAttach,Rat(If(IsSrvUnix(),"/","\"),cAttach)+1,Len(cAttach))+CHR(13)+CHR(10)    //RRV - 25/09/2012 - Ajuste para ambiente Linux ("/")
         AADD(Self:aAnexos,cAttach)
      Else
         Self:cErro := "Arquivo ja anexado."
         lRet := .F.
         Break
      EndIf
      // Adiciona o arquivo no objeto
      //MFR 23/07/2020 OSSME-4948
      cAttach := alltrim(cAttach)
      nRet := Self:oMessage:AttachFile(cAttach)                   
      If nRet <> 0
         Self:cErro := "Erro ao anexar o arquivo." + ENTER +; // RRV - 20/09/2012 - Informa o erro ao usu�rio
                       Self:oServer:oServerSMTP:GetErrorString(nRet)
         Conout("Erro ao anexar o arquivo.")
         lRet := .F.
         Break
      Else
         //adiciona uma tag informando que � um attach e o nome do arq
         Self:oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cAttach)
      EndIf
   EndIf

End Sequence

Return lRet

/*==============================================================================================================*
* M�todo    : EnviaMail()
* Parametro : 
* Retorno   : nRet - Retorna zero se foi efetuado com sucesso o envio, sen�o retorna o valor do erro.
* Classe    : EasyMessageSMTP
* Descri��o : Responsavel pelo envio do email.
* Autor     : Bruno Akyo Kubagawa
* Data/Hora : 24 de Mar�o de 2011 - 09:30
* Obs.      : 
*===============================================================================================================*/
Method EnviaMail() Class EasyMessageSMTP

Local lRet := .T., cAttachment := ""

aEval(Self:aAnexos, {|x| If(Len(cAttachment)<>0, cAttachment += ",",), cAttachment += AllTrim(x) })

Begin Sequence

   //RRV - 04/10/2012 - Envia o e-mail
   SEND MAIL FROM Self:oMessage:cFrom TO Self:oMessage:cTo CC Self:oMessage:cCC BCC Self:oMessage:cBcc SUBJECT Self:oMessage:cSubject BODY Self:oMessage:cBody ATTACHMENT cAttachment RESULT lRet
   
   If !lRet
      GET MAIL ERROR Self:cErro
      Break
   EndIf

End Sequence

Return lRet

/*==============================================================================================================*
* M�todo    : ViewMail()
* Parametro : 
* Retorno   : nRet - Retorna zero se foi efetuado com sucesso o envio, sen�o retorna o valor do erro.
* Classe    : EasyMessageSMTP
* Descri��o : Responsavel pela constru��o do email, ou seja, a janela para o usuario.
* Autor     : Bruno Akyo Kubagawa
* Data/Hora : 24 de Mar�o de 2011 - 09:30
* Obs.      : 
*===============================================================================================================*/
Method ViewMail() Class EasyMessageSMTP

Local oDlg
Local cFrom    := Self:oServer:cAccount
Local cTo      := Self:oMessage:cTo + Space(200-Len(Self:oMessage:cTo))
Local cCc      := Space(200)
Local cBcc     := Space(200)
Local cSubject := If ( Empty(Self:cAssunto)  , Space(100) , PADR(Self:cAssunto,100,CHAR(32)) )//FSY - 23/09/2013
Local cBody    := If ( Empty(Self:cTextoMail), ""         , Self:cTextoMail )//FSY - 23/09/2013
Local nCol1    := 8
Local nCol2    := 31
Local nSize    := 233  
Local nLinha   := 10 
Local nOp      := 0                       
Local lRet     := .T.
Local nLabel   := 0
Local cTexto   := "Informe um ou mais destin�rios, separados por ponto e v�rgula (;)."

DEFINE MSDIALOG oDlg OF oMainWnd FROM 0,0 TO 440,540 PIXEL TITLE "Enviar Email"

   nLabel := nLinha
   @ nLinha-2,nCol1          BUTTON oButEnv PROMPT "Enviar"  Action (If(!Empty(cTo),(oDlg:End(),nOp:=1),(Msginfo(cTexto)))) SIZE 22,18+nLinha  Of oDLG PIXEL

   @ nLinha,nCol2+2          Say   oBjtDe   VAR "De:"    Size 016,08                OF oDlg PIXEL
   @ nLinha-2,nCol1+nCol2+10 MSGet              cFrom    Size nSize-nCol2+15,10     WHEN .F.  OF oDlg PIXEL 
     nLinha+=15

   @ nLinha,nCol2+2          Say   oBjtPara VAR "Para:"  Size 016,08                OF oDlg PIXEL 
   @ nLinha-2,nCol1+nCol2+10 MSGet oBjtTo   VAR cTo      Size nSize-nCol2+15,10     OF oDlg PIXEL 
     nLinha+=15

   @ nLinha,nCol2+2          Say   oBjtCC   VAR "CC:"    Size 016,08                OF oDlg PIXEL
   @ nLinha-2,nCol1+nCol2+10 MSGet oBjtCCC  VAR cCC      Size nSize-nCol2+15,10     OF oDlg PIXEL
     nLinha+=15

   @ nLinha,nCol2+2          Say   oBjtCco  VAR "CCO:"   Size 016,08                OF oDlg PIXEL
   @ nLinha-2,nCol1+nCol2+10 MSGet oBjtBcc  VAR cBcc     Size nSize-nCol2+15,10     OF oDlg PIXEL
     nLinha+=15
    
   @ nLabel-6,nCol1-4 To nLinha, 268 LABEL OF oDlg PIXEL
     
     nLinha += 10
     nLabel := nLinha
     nLinha += 4
   @ nLinha,nCol1          Get oBjtAnexo VAR Self:cAnexosExtras Size nSize+nCol2-nCol1,12  MEMO WHEN .F.  OF oDlg PIXEL
     oBjtAnexo:EnableVScroll(.F.)
     oBjtAnexo:EnableHScroll(.F.)

   @ nLabel-6,nCol1-4 To nLinha+17, 268 LABEL "Anexo" OF oDlg PIXEL

     nLinha+=27
     nLabel := nLinha
     nLinha+=4
   @ nLinha,nCol1          Say   oBjtAss VAR "Assunto:"    Size 021,08                         OF oDlg PIXEL
   @ nLinha-2,nCol2        MSGet oBjtSub VAR cSubject      Size nSize,10                       OF oDlg PIXEL
     nLinha+=15

   @ nLinha-2,nCol1        Get   oBjtBody VAR  cBody       Size nSize+(nCol2-nCol1-1),82  MEMO OF oDlg PIXEL  HSCROLL
     nLinha+=93
     oBjtBody:EnableVScroll(.T.)
     oBjtBody:EnableHScroll(.T.)
   @ nLabel-6,nCol1-4 To nLinha-7, 268 LABEL "Email" OF oDlg PIXEL

   ACTIVATE MSDIALOG oDlg CENTERED

   If nOp == 1

      If !Empty(cFrom)
         Self:oMessage:cFrom := AllTrim(cFrom)
      EndIf

      If !Empty(cTo)
         Self:oMessage:cTo := AllTrim(cTo)
      EndIf

      If !Empty(cCc)
         Self:oMessage:cCc := AllTrim(cCc)
      EndIf

      If !Empty(cBcc)
         Self:oMessage:cBcc := AllTrim(cBcc)
      EndIf

      If !Empty(cSubject)
         Self:oMessage:cSubject := AllTrim(cSubject)
      EndIf
   
      If !Empty(cBody)
         Self:oMessage:cBody := AllTrim(cBody)
      EndIf
      lRet := Self:EnviaMail()
   EndIf  

Return lRet