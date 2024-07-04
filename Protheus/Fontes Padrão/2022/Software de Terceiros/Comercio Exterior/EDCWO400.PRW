//
#include "EDCWO400.ch"
#include "Average.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "AP5MAIL.CH"
#include "tbiconn.ch"

/*
Programa        : EDCWO400.PRW
Objetivo        : Tarefa de verificação de Vencimento de A.C.
Autor           : Gustavo Carreiro
Data/Hora       : 
Obs.            : 
*/

*-----------------------*
Function EDCWO400(aParam)
*-----------------------*
Local cFrom, cTo, cCC, cSubject, cBody:="", lOk
Local cServer, cAccount, cPassword
Local nDias, dDtVal, cFilED0, cError, cBodyAux:=""
Local cEasyOpenFileed:=""
// LOCAL lOpened:=.F. -- ACSJ - 01/12/2004 - Variavel não é usada.

default aParam := { "01", "01" }

cEasyOpenFileed += IIF(TYPE("xNaoAbre")!="U","SX5","SA1SA2SA3SA4SA5SA6SI1SX5")

AvReadMnu("SIGA"+aParam[3]+".MNU",@cEasyOpenFileed)

PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2]

AvOpenTb(cEasyOpenFileed)

E_Init(.T.) //para criação de variáveis
If Empty(cUserName)
   cUserName:=Space(6)+"WorkFlow            "
Endif

cFilED0 := xFilial("ED0")
nDias   := EasyGParam("MV_DIASAVI",,0)

If nDias > 0 //Valor do parâmetro deve ser maior que Zero
   ED0->(dbGoTop())
   Do While !ED0->(EOF()) .and. ED0->ED0_FILIAL == cFilED0
      dDtVal := ApDtValid()
      If !Empty(dDtVal) .and. !Empty(ED0->ED0_AC) .and. Empty(ED0->ED0_DT_ENC) .and.;
      (dDataBase + nDias) >= dDtVal
         cBodyAux += "<TR VALIGN=TOP>"
         cBodyAux += "<TD WIDTH=33%>"
         cBodyAux += "<P>"+ED0->ED0_AC
         cBodyAux += "</P>"
         cBodyAux += "</TD>"
         cBodyAux += "<TD WIDTH=33%>"
         cBodyAux += "<P>"+ED0->ED0_PD
         cBodyAux += "</P>"
         cBodyAux += "</TD>"
         cBodyAux += "<TD WIDTH=33%>"
         cBodyAux += "<P>"+DtoC(dDtVal)
         cBodyAux += "</P>"
         cBodyAux += "</TD>"
         cBodyAux += "</TR>"
      EndIf
      ED0->(dbSkip())
   EndDo
   If !Empty(cBodyAux)
      cServer   := EasyGParam("MV_WFSMTP")
      cAccount  := EasyGParam("MV_WFACC")
      cPassword := EasyGParam("MV_WFPASSW")
      cFrom     := EasyGParam("MV_WFMAIL")
      cTo       := EasyGParam("MV_MAILAVI")
      cCC       := "" //:= EasyGParam("MV_WFSMTP")
      cSubject  := STR0003 //"Notificacao de Vencimento de Ato Concessorio"
      //Monta E-Mail
      cBody += "<HTML>"
      cBody += "<BODY>"
      cBody += "<P ALIGN=CENTER><FONT FACE='Courier New, monospace'>"+STR0004 //"Segue lista de "
      cBody += STR0005+Alltrim(Str(nDias))+STR0006 //"Atos Concess&oacute;rios que est&atilde;o para vencer em " # " dias:"
      cBody += "<BR><BR></FONT><BR>"
      cBody += "</P>"
      cBody += "<TABLE WIDTH=100% BORDER=1 CELLPADDING=4 CELLSPACING=3>"
      cBody += "<COL WIDTH=85*>"
      cBody += "<COL WIDTH=85*>"
      cBody += "<COL WIDTH=85*>"
      cBody += "<THEAD>"
      cBody += "<TR BGCOLOR='#ffffff' VALIGN=TOP>"
      cBody += "<TD WIDTH=33%>"
      cBody += "<P ALIGN=CENTER><B>"+STR0007+"</B></P>" //"Ato Concess&oacute;rio"
      cBody += "</TD>"
      cBody += "<TD WIDTH=33%>"
      cBody += "<P ALIGN=CENTER><B>"+STR0008+"</B></P>" //"Pedido de Drawback"
      cBody += "</TD>"
      cBody += "<TD WIDTH=33%>"
      cBody += "<P ALIGN=CENTER><B>"+STR0009+"</B></P>" //"Data de Vencimento"
      cBody += "</TD>"
      cBody += "</TR>"
      cBody += "</THEAD>"
      cBody += "<TBODY>"
      cBody += cBodyAux
      cBody += "</TBODY>"
      cBody += "</TABLE>"
      cBody += "<P ALIGN=CENTER><BR><BR>"
      cBody += "</P>"
      cBody += "</BODY>"
      cBody += "</HTML>"
      
      CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk
      If lOk
         If !Empty(cCC)
            SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody Result lOk
         Else
            SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody Result lOk
         EndIf
         If !lOk
            GET MAIL ERROR cError
            ConOut("EDCWO400 - "+STR0001+cError) // "Erro no envio de Email - "
         EndIf
      Else
         GET MAIL ERROR cError
         ConOut("EDCWO400 - "+STR0002+cError) // "Erro na conexao com o servidor de Email - "
      EndIf
      DISCONNECT SMTP SERVER
      
   EndIf
EndIf

Return .T.

*---------------------------------------*
Static Function AvReadMnu(cMenu,cEasyOpenFileed)
*---------------------------------------*
Local nHdlMnu,nbytes,xBuff,nCont, i, lSAH := .F.

nHdlMnu:=EasyOpenFile(cMenu, 2 + 64 )

IF nHdlMnu = -1
   EasyCreateFile("NAOLEU"+Right(cMenu,3)+".AVE")
   Return ""
ENDIF

nbytes := FSeek(nHdlMnu,0,2)
xBuff  := Space(102)
FSEEK(nHdlMnu,0,0)
xBuff  := SPACE(133)
nCont  := 0

Do While nCont < nBytes
   FREAD(nHdlMnu,@xBuff,133)
   nCont:=nCont+133
   If SubStr(xBuff,31,1)=="T"
      For i:=32 TO 119 STEP 3
          cArq:=SubStr(xBuff,i,3)
          If cArq == "..."
             Exit
          Else
             If AT(cArq,cEasyOpenFileed)==0 .And. !Empty(cArq)
                cEasyOpenFileed:=cEasyOpenFileed+cArq
             Endif
             If ( cArq == "SB1" .And. !lSAH )
                  cEasyOpenFileed:=cEasyOpenFileed+"SAH"
                  lSAH := .T.
             ElseIf ( cArq == "SAH" )
                      lSAH := .T.
             Endif
          Endif
      Next i
   Endif
Enddo

Fclose(nHdlMnu)

If !("SM2"$cEasyOpenFileed)
  cEasyOpenFileed := cEasyOpenFileed + "SM2"
EndIf
If !("SM4"$cEasyOpenFileed)
  cEasyOpenFileed := cEasyOpenFileed + "SM4"
EndIf

Return cEasyOpenFileed

*--------------------------------*
Static Function AvOpenTb(cEasyOpenFileed)
*--------------------------------*
Local i, nHdl

For i:=1 To Len(cEasyOpenFileed) Step 3
    If ! ChkFile(Subs(cEasyOpenFileed,i,3))
         nHdl:=EasyCreateFile("OPERR"+Subs(cEasyOpenFileed,i,3)+".AVE")
         FClose(nHdl)
         Return
    Endif   
Next

*-------------------------*
Static Function ApDtValid()
*-------------------------*
Local dData

If !Empty(ED0->ED0_DT_ENC)
   dData:=ED0->ED0_DT_ENC
ElseIf ED0->ED0_PROAP3 = "1"
   dData:=ED0->ED0_DT_PR3
ElseIf ED0->ED0_PROAP2 = "1"
   dData:=ED0->ED0_DT_PR2
ElseIf ED0->ED0_PROAP1 = "1"
   dData:=ED0->ED0_DT_PR1
ElseIf !Empty(ED0->ED0_DT_VA2)
   dData:=ED0->ED0_DT_VA2
Else
   dData:=ED0->ED0_DT_VA1
EndIf

Return dData

//No arquivo Scheduler.wf situado no Sigaadv pode-se configurar empresa, filial e environment que
//serão abertos a partir no jobs pela função WFOnStart. É possível abrir jobs para n empresas, 
//separando a configuração por ponto e vírgula(;).
