#Include "AVINT101.CH"
#Include "EEC.CH"

Static __ELinkLastID := ""    // GFP - 20/08/2012
Static aBuffer := {}          // GFP - 20/08/2012
Static aLogID  := {}

/*
Programa   : AvInt101.prw
Objetivo   : Re�ne fun��es que controlam a chamada de a��es, eventos e servi�os
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Obs        :
*/

/*
Fun��o     : AvStAction(cAction)
Par�metros : cAction - C�digo da a��o
Retorno    : lRet - Indica resultado da contrata��o
Objetivos  : Inicia uma a��o do EasyLink
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    :
Obs.       :
*/
*-----------------------------------------------------------*
Function AvStAction(cAction, lInterface, __oProcess, cError)
*-----------------------------------------------------------*
//__oProcess - Par�metro Desativado. Mantido apenas para compatibilidade na chamada da fun��o.
Local lRet
Local bStart := {|| lRet := AvAction(cAction, lInterface) }
Local lEnv := Type("oMainWnd") == "O"
Private cErros := ""
Default lInterface := lEnv

   If Type("lELinkBlind") == "L"
      lInterface := !lELinkBlind
   EndIf

   If Empty(ELinkGetLastID())
      ELinkSetLastID()
   EndIf

	//RMD - 13/09/12 - Removido o "Processa". A barra passa a ser exibida somente por evento.
	Eval(bStart)
	cError := cErros

	If /*Type("lELinkAuto") == "L" .And. lELinkAuto .And.*/ !Empty(cErros)
		lMsErroAuto := .T.
		AutoGrLog(cErros)
	EndIf

Return lRet

Function AvCallAct()
Return EYB->EYB_CODAC

/*
Fun��o     : AvAction(cAction)
Par�metros : cAction - C�digo da a��o
Retorno    : lRet - Indica resultado da contrata��o
Objetivos  : Complementa a fun��o AvStAction, efetuando a chamada da a��o
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    :
Obs.       :
*/
*-------------------------------------*
Function AvAction(cAction, lInterface)
*-------------------------------------*
Local lRet   := .T.
Local cMsg := ""
Local aOrd := SaveOrd({})
Local oLog
Local lCondic := .T.//FSM - 15/08/2012
Local bStart := {|| lRet := AvStEvent(EYC->EYC_CODAC, EYC->EYC_CODINT, EYC->EYC_CODEVE, EYC->EYC_CODSRV, oLog, lInterface, oProcess) }
Local oProcess
Default cAction := ""
Default lInterface := Type("oMainWnd") == "O"

Begin Sequence

   cAction := AvKey(cAction, "EYB_CODAC")
   If EYB->(DbSeek(xFilial()+cAction))
      If EYC->(DbSeek(xFilial()+EYB->EYB_CODAC))
         While xFilial("EYC") == EYC->EYC_FILIAL .And. EYC->EYC_CODAC == EYB->EYB_CODAC
            lCondic := EYC->(FieldPos("EYC_CONDIC")) == 0  .Or. Empty( EYC->EYC_CONDIC ) .Or. &(EYC->EYC_CONDIC) //FSM - 15/08/2012
            If IsIntEnable(EYC->EYC_CODINT) .And. lCondic //FSM - 03/08/2012
               //RMD - 12/09/12 - Somente exibe a interface e grava o log se existir algum evento ativo
               If ValType(oLog) <> "O"
                  oLog := EasyLinkLog():New(cAction)
               EndIf

               //RMD - 31/10/14 - Ajuste para evitar error.log quando n�o existir interface
               If lInterface
                  oProcess := MsNewProcess():New(bStart, "Aguarde...", "Iniciando a��o '" + AllTrim(EYB->EYB_DESAC) + "'", .F.)
                  oProcess:Activate()
               Else
                  Eval(bStart)
               EndIf

            EndIf
            EYC->(DbSkip())
         EndDo
      EndIf
      //RMD - 12/09/12 - Somente exibe a interface e grava o log se existir algum evento ativo
      If ValType(oLog) == "O"
         oLog:AcMsg(cMsg, lRet)
         cErros += oLog:EndLog()
         If !lRet
            aLogID := oLog:GetLogID()
         EndIf         
      EndIf
   EndIf

End Sequence

RestOrd(aOrd, .T.)

Return lRet

/*
Fun��o     : AvStEvent(cAction, cInt, cEvent, cService, oLog)
Par�metros : cAction - C�digo da a��o
             cInt - C�digo da integra��o
             cEvent - C�digo do evento
             cService - C�digo do servi�o
             oLog - Objeto de controle de log
Retorno    : lRet - Indica resultado da contrata��o
Objetivos  : Incia um evento relacionada a uma a��o e integra��o
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    :
Obs.       :
*/
*-----------------------------------------------------------------*
Function AvStEvent(cAction, cInt, cEvent, cService, oLog, lInterface, oProcess)
*-----------------------------------------------------------------*
Local lRet := .F.
Local aOrd := SaveOrd({"EYB", "EYC"})
Local cMsg := ""
Default cEvent  := ""
Default cAction := ""
Default cInt    := ""
Default lInterface := Type("oMainWnd") == "O"

oLog:SetEvent(cInt, cEvent, cService)

Begin Sequence

   cEvent  := AvKey(cEvent, "EYC_CODEVE")
   cAction := AvKey(cAction, "EYC_CODAC")
   cInt    := AvKey(cInt, "EYC_CODINT")

   EYA->(DbSetOrder(1))
   If !EYA->(DbSeek(xFilial()+cInt))
      cMsg += StrTran(STR0005, "###", AllTrim(cInt))//"A integra��o '###' n�o est� cadastrada no sistema."
      Break
   EndIf

   EYC->(DbSetOrder(1))
   If lInterface
      oProcess:SetRegua1(2)
      oProcess:IncRegua1("Iniciando evento '" + AllTrim(EYC->EYC_CODAC) + "' ")
   EndIf

   If EYC->(DbSeek(xFilial()+cAction+cInt+cEvent))
      lRet := AvStService(EYC->EYC_CODINT, EYC->EYC_CODAC, EYC->EYC_CODSRV, oLog, lInterface, oProcess)
      If !lRet
         cMsg += STR0003//"Erro na contrata��o."
      EndIf
   Else
      cMsg += StrTran(StrTran(STR0004, "###", AllTrim(cEvent)), "$$$", AllTrim(cInt))//"O evento '###' n�o est� cadastrado no sistema para a integra��o '$$$'."
   EndIf

End Sequence

oLog:EvMsg(cMsg, lRet)
oLog:SaveLog()
oLog:EndEvent()
RestOrd(aOrd, .T.)

Return lRet

/*
Fun��o     : AvStService(cInt, cAction, cService, oLog)
Par�metros : cInt - C�digo da integra��o
             cAction - C�digo da a��o
             cService - C�digo do servi�o
             oLog - Objeto de controle de log
Retorno    : lRet - Indica resultada do contrata��o
Objetivos  : Contrata um servi�o associado a um evento
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    :
Obs.       :
*/
*------------------------------------------------------------------------*
Function AvStService(cInt, cAction, cService, oLog, lInterface, oProcess)
*------------------------------------------------------------------------*
Local lRet := .F.
Local aOrd := SaveOrd("EYE")
Local cMsg := ""
Local oService
Default cInt     := ""
Default cService := ""
Default lInterface := Type("oMainWnd") == "O"
Private cUltParc := ""  // GFP - 21/01/2014

Begin Sequence

   cInt     := AvKey(cInt,     "EYE_CODINT")
   cService := AvKey(cService, "EYE_CODSRV")

   EYE->(DbSetOrder(1))
   If EYE->(DbSeek(xFilial()+cInt+cService))
      If lInterface
         oProcess:SetRegua1(2)
         oProcess:IncRegua1("Iniciando servi�o '" + AllTrim(EYE->EYE_DESSRV) + "'")
         If !oProcess:lEnd
            oProcess:SetRegua2(6)
            oProcess:IncRegua2("Iniciando EasyLink")
         EndIf
         If EYE->(FieldPos("EYE_FUNCT")) > 0 .And. !Empty(EYE->EYE_FUNCT)
            cRdmake:=EYE->EYE_FUNCT+IF(AT("(",EYE->EYE_FUNCT)=0,"()","")
            lRet := &(cRdmake)
         Else
            oService := EasyLink():New(cInt, cAction, cService, EYE->EYE_ARQXML, oLog:dDataI, oLog:cHoraI)
            If !oProcess:lEnd
               oProcess:IncRegua2("Lendo o servi�o...")
            EndIf
            oService:ReadService()
            If !oProcess:lEnd
               oProcess:IncRegua2("Traduzindo...")
            EndIf
            oService:Translate()
            If !oProcess:lEnd
               oProcess:IncRegua2("Enviando...")
            EndIf
            oService:Send()
            If !oProcess:lEnd
              oProcess:IncRegua2("Recebendo...")
            EndIf
            oService:Receive()
         EndIf
         If !oProcess:lEnd
            oProcess:IncRegua2("Finalizado")
         EndIf
      Else
         If EYE->(FieldPos("EYE_FUNCT")) > 0 .And. !Empty(EYE->EYE_FUNCT)
            cRdmake:=EYE->EYE_FUNCT+IF(AT("(",EYE->EYE_FUNCT)=0,"()","")
            lRet := &(cRdmake)
         Else
            oService := EasyLink():New(cInt, cAction, cService, EYE->EYE_ARQXML, oLog:dDataI, oLog:cHoraI)
            oService:ReadService()
            oService:Translate()
            oService:Send()
            oService:Receive()
         ENDIF
      EndIf
      If EYE->(FieldPos("EYE_FUNCT")) == 0 .Or. Empty(EYE->EYE_FUNCT)
         lRet := Empty(oService:cError)
         If !Empty(oService:cError)
            cMsg += oService:cError + ENTER
         EndIf
         If !Empty(oService:cWarning)
            cMsg += oService:cWarning + ENTER
         EndIf
      EndIf
      oLog:SaveLog(oService)
   Else
      cMsg += StrTran(StrTran(STR0006, "###", AllTrim(cService)), "$$$", AllTrim(cInt))//"O servi�o '###' n�o est� cadastrado no sistema para a integra��o '$$$'."
   EndIf

End Sequence

oLog:EvMsg(cMsg, lRet)
RestOrd(aOrd, .T.)

Return lRet

/*
Fun��o     : AvLkGtLog(cID, cLog)
Par�metros : cID - Identifica��o da contrata��o
             cLog - Tipo de log (Ambiente ou Dados enviados)
Retorno    : cBuffer - Conte�do do Log
Objetivos  : Retorna o conte�do de um arquivo de log. Utilizada pelo Log Viewer
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    :
Obs.       :
*/
*---------------------------*
Function AvLkGtLog(cID, cLog)
*---------------------------*
Local cFile := EasyGParam("MV_AVG0135",,"\XML") + "\Log\" + cID
Local cBuffer := "", nBuffer, hFile

// PLB 14/08/07 - Acerta Diret�rio
If IsSrvUNIX()
   cFile := AllTrim(Lower(StrTran(cFile, '\', '/')))
EndIf

Begin Sequence

   cLog := Upper(cLog)
   Do Case
      Case cLog == "DATA"
         cFile += ".xml"

      Case cLog == "ENVIRONMENT"
         cFile += ".txt"

   End Case

   If !File(cFile)
      If EYF->EYF_STATUS == "02" .Or. EYF->EYF_STATUS == "04"
         cBuffer += "Servi�o contratado com sucesso." + ENTER + "N�o foi gerado arquivo de Log." + ENTER
      Else
         cBuffer += StrTran(STR0007, "###", AllTrim(cFile)) + ENTER + STR0009 + ENTER//"O Arquivo '###' n�o foi encontrado." "N�o ser� poss�vel apresentar o Log."
      EndIf
      Break
   EndIf
   hFile := FOpen(cFile,0)
   If hFile < 1
      cBuffer += StrTran(STR0008, "###", AllTrim(cFile)) + ENTER + STR0009 + ENTER//"Erro na abertura do arquivo '###'." "N�o ser� poss�vel apresentar o Log."
      Break
   EndIf
   nBuffer := FSeek(hFile,0,2)
   FSeek(hFile,0,0)
   cBuffer := Space(nBuffer)
   FRead(hFile,@cBuffer,nBuffer)
   FClose(hFile)

End Sequence

Return cBuffer

/*
Fun��o     : EECGetFinN
Par�metros :
Retorno    : cNum - Nova sequ�ncia de t�tulo dispon�vel para uso
Objetivos  : Obt�m uma nova seq��ncia de t�tulo no m�dulo financeiro
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    : WFS 05/02/2010
             Adapta��o para utiliza��o com as rotinas de integra��o com o contas a pagar,
             integradas a partir das despesas nacionais e numer�rios.
Obs.       :
*/
*----------------------------*
Function EECGetFinN(cAlias)
*----------------------------*
Local cNum := EasyGParam("MV_AVG0134",,Replicate("0", AvSx3("E1_NUM", AV_TAMANHO)))
Local aOrd := {}
Local cPreAlias:= ""

Default cAlias:= "SE1"

Begin Sequence

   aOrd := SaveOrd(cAlias)
   cPreAlias:= SubStr(cAlias, 2, 2)

      /* ordem 1 das tabelas SE1 e SE2
         E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
         E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA */

   (cAlias)->(DBSetOrder(1))

   IF Val(cNum) <= 0
      cNum := EasyGetMVSeq("MV_AVG0134_"+cAlias)
   Else
      //If (cAlias)->(DbSeek(xFilial()+"EEC"+cNum))
      If (cAlias)->(DbSeek(xFilial()+cModulo+cNum))
         While (cAlias)-> &(cPreAlias + "_FILIAL") == xFilial(cAlias) .And. (cAlias)->&(cPreAlias + "_PREFIXO") == cModulo
            cNum := (cAlias)->&(cPreAlias + "_NUM")
            (cAlias)->(DbSkip())
         EndDo
      EndIf
      cNum := SomaIt(cNum)  // GFP - 01/10/2014   //StrZero(Val(cNum) + 1, AvSx3(cPreAlias + "_NUM", AV_TAMANHO))
      If (cAlias)->(dbSeek(xFilial()+"EEC"+cNum))  // GFP - 01/10/2014
         Final(STR0015)   //"Erro na numera��o dos t�tulos prefixo EEC no m�dulo financeiro. Verifique o par�metro MV_AVG0134."
      EndIf
      PutMv("MV_AVG0134", cNum) //THTS - 507835 / MTRADE-644 - Msg de erro ao tentar salvar o conte�do do par�metro
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return cNum

/*
Fun��o     : EECGetFinParc
Par�metros : cParcela -> Numero da parcela do EASY. Ex.: "01", "02"..."10"
Retorno    : cParcela -> Nova parcela. Ex.: "1", "2"...."A"
Objetivos  : Gerar parcelas 1-9/A-Z
Autor      : Felipe Sales Martinez - FSM
Data/Hora  : 21/07/2012
*/
*-------------------------------*
Function EECGetFinParc(cParcela)
*-------------------------------*
Default cParcela := EEQ->EEQ_PARC

If EECFlags("TIT_PARCELAS") .And. !Empty(EEC->EEC_TITCAM) //FSM - 27/08/2012
   /* RMD - 06/10/12 - Considerando que est� sempre posicionado no EEQ, verifica se possui parcela de origem, caso possua, considera que
                       o t�tulo para esta parcela (quebra) � o mesmo t�tulo da parcela de origem.
   */
   If !Empty(EEQ->EEQ_PARVIN) .And. EECFlags("ALT_EASYLINK")//RMD - 02/10/14
      cParcela := RetAsc(EEQ->EEQ_PARVIN,AvSX3("E1_PARCELA",AV_TAMANHO),.T.)
   Else
      cParcela := RetAsc(cParcela,AvSX3("E1_PARCELA",AV_TAMANHO),.T.)
   EndIf
ElseIf "ESS" $ cModulo// IsInCallStack("ESSRS400") .Or. IsInCallStack("ESSRS403")
   cParcela := AvKey(EasyGetParc(1),"E1_PARCELA")
Else
   //cParcela := ' '
   cParcela:= AvKey(" ", "E1_PARCELA")
EndIf

Return cParcela

/*
Fun��o     : EECGetMotBx
Par�metros :
Retorno    : cXMotBx - Retorna o motivo de baixa para o avlink
Objetivos  : Validar o tipo de motivo de baixa a ser enviado
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    :
Obs.       :
*/
*--------------------*
Function EECGetMotBx(cAlias, lAdLiq)
*--------------------*
Local cXMotBx := ""
Local aOrd  := SaveOrd({"EF3","EF1"}) //FSM - 21/03/2012

Private cMotAux:= ""
Default cAlias := "EEQ"
Default lAdLiq := .F.

Begin Sequence

	If Type("lBxNfFat") == "L" .And. lBxNfFat
		cXMotBx := EasyGParam("MV_EEC0032",,"") //LBL - 08/11/2013
	Else
	   If AvFlags("SIGAEFF_SIGAFIN") .AND. EasyGParam("MV_EEC_EFF",,.F.) .AND. EasyGParam("MV_EFF",,.F.)
	      EF3->(dbSetOrder(2))
	      If EF3->(dbSeek(xFilial("EF3")+if((cAlias)->EEQ_TP_CON $ ("2/4"),"I","E")+"600"+(cAlias)->(EEQ_NRINVO+EEQ_PARC)) )
	         //FSM - 21/03/2012
	         EF1->( DbSetOrder(1) ) //EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVOIC+EF3_INVIMP+EF3_LINHA
	         If EF1->( DbSeek( xFilial("EF3")+EF3->EF3_TPMODU+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT ) )
	            cXMotBx := Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_MOTBXI")
	         EndIf

	      EndIf
	   EndIf
   EndIf

   if ismemvar("lGrvAdian") .and. lGrvAdian .AND. valtype(cMotBx) == "C" .and. !empty(cMotBx) //IsInCallStack("GRAVAADIAN")
      cXMotBx := cMotBx
   endif

  If Empty(cXMotBx)
     If (cAlias)->(FieldPos("EEQ_MOTIVO")) > 0 .And. !Empty((cAlias)->EEQ_MOTIVO)
        If (cAlias)->EEQ_TIPO == "A" .And. !lAdLiq .and. EasyGParam("MV_EEC0042",,.F.) //NCF - 13/03/2017 - Tipo de baixa CMP para comp. adiantamento
           cXMotBx := "CMP"
        Else
           cXMotBx := (cAlias)->EEQ_MOTIVO
        EndIf
     Else
        If (cAlias)->EEQ_TIPO == "A" .And. !lAdLiq .and. EasyGParam("MV_EEC0042",,.F.) //NCF - 13/03/2017 - Tipo de baixa CMP para comp. adiantamento
           cXMotBx := "CMP"
        Else
           cXMotBx := "NOR"
        EndIf
     EndIf
  EndIf

   If EasyEntryPoint("AVINT101")
      ExecBlock("AVINT101",.F.,.F.,"MOTIVO_BAIXA")
      if !empty(cMotAux)
         cXMotBx := cMotAux
      endif
   EndIf

End Sequence

RestOrd(aOrd, .T.)

Return cXMotBx
/*
Fun��o     : EECGetBanco
Par�metros : cOpcb - Representa qual ser� o retorno
Retorno    : cRet  - Retorna o valor para o devido campo
Objetivos  : Retornar banco, agencia e conta para o avlink
Autor      : Miguel Gontijo
Data/Hora  : 17/04/19
Revisao    :
Obs.       :
*/
Function EECGetBanco(cOpcb)
Local cRet := ""

   If (ismemvar("cBanco") .and. !empty(cBanco)) ; //IsInCallStack("EECBxFiTit") .OR. IsInCallStack("EECRABaixa")
      .and. ismemvar("cAgencia") .and. !empty(cAgencia) ;
      .and. ismemvar("cConta") .and. !empty(cConta)
      
      if cOpcb == "AUTBANCO"
         cRet := cBanco
      elseif cOpcb == "AUTAGENCIA"
         cRet := cAgencia
      elseif cOpcb == "AUTCONTA"
         cRet := cConta
      Endif

   else
      
      if cOpcb == "AUTBANCO"
         cRet := EEQ->EEQ_BANC
      elseif cOpcb == "AUTAGENCIA"
         cRet := EEQ->EEQ_AGEN
      elseif cOpcb == "AUTCONTA"
         cRet := EEQ->EEQ_NCON
      Endif

   Endif

Return cRet
/*
Fun��o     : EECInFin(__aInt, cInt, cOpc, nPar1, nPar2)
Par�metros : __aInt - Array de dados a serem enviados
             cInt - Tabela que ser� integrada
             cOpc - Tipo de opera��o (Inclus�o, Altera��o, Baixa, Estorno da baixa)
             nPar1 - Par�metro adicional
             nPar2 - Par�metro adicional
Retorno    : cMsg - Mensagem retornada pela fun��o de integra��o
Objetivos  : Faz a chamada de fun��es de integra��o com o m�dulo Financeiro
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    :
Obs.       :
*/
*-------------------------------------------------*
Function EECInFin(__aInt, cInt, cOpc, nPar1, nPar2,cFinNum,cAliasF)
*-------------------------------------------------*
Local bInt, i
Local nOpc := 0
Local cMsg := ""
Local cOldFunName := ""
Local nPosFilaSE2         //NCF - 26/04/2017
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
Private lc050Auto   := .T.
Private aIntTitFin  := {} // LGS - 01/07/2016

Default cOpc := ""
Default cInt := ""
Default cFinNum:= ""
Default cAliasF   := "EEQ"

//RMD - 22/05/18 - Verifica se existe log de uma execu��o anterior de ExecAuto e caso positivo apaga para n�o acusar erro na pr�xima execu��o
If NomeAutoLog() <> Nil .And. File(NomeAutoLog())
      FErase(NomeAutoLog())
      __cFileLog := Nil
EndIf

Begin Sequence
   If cInt == "SE1"
      //WFS 16/02/09
      //Cria��o de vari�veis de mem�ria exigidas pelo X7_CHAVE do campo E1_VALOR
      M->E1_VEND1 := ""
      M->E1_VEND2 := ""
      M->E1_VEND3 := ""
      M->E1_VEND4 := ""
      M->E1_VEND5 := ""
      If cOpc == "INCLUIR"
         bInt := {|aInt, nOpc| FINA040(aInt, nOpc)}
         nOpc := INCLUIR
      ElseIf cOpc == "ALTERAR" //FSM - 01/08/2012
         bInt := {|aInt, nOpc| FINA040(aInt, nOpc)}
         nOpc := ALTERAR
      ElseIf cOpc == "EXCLUIR"
         bInt := {|aInt, nOpc| FINA040(aInt, nOpc)}
         nOpc := EXCLUIR
      ElseIf cOpc == "BAIXA"
         bInt := {|aInt, nOpc| FINA070(aInt, nOpc)}
         nOpc := 3
      ElseIf cOpc == "ESTBAIXA"
         bInt := {|aInt, nOpc, nPar1, nPar2| Fina070(aInt, nOpc, nPar1, nPar2)}
         nOpc := EXCLUIR
      EndIf
   ElseIf cInt == "SE2"
      //LRS -10/09/2015
      cOldFunName:= FUNNAME()
      If cModulo == "ESS"
         SetFunName("ESSPA400")
      EndIf

      If cOpc == "INCLUIR"
         //TDF - 23/12/11 - Fecha a Work TMP para que a rotina FINA050 n�o a apague
         If Select("TMP") > 0
            TMP->(DbCloseArea())
         EndIF
         bInt := {|aInt, nOpc| FINA050(aInt,, nOpc)}
         nOpc := INCLUIR
      ElseIf cOpc == "ALTERAR"
         //TDF - 23/12/11 - Fecha a Work TMP para que a rotina FINA050 n�o a apague
         If Select("TMP") > 0
            TMP->(DbCloseArea())
         EndIF
         bInt := {|aInt, nOpc| FINA050(aInt,, nOpc)}
         nOpc := ALTERAR
      ElseIf cOpc == "EXCLUIR"
         bInt := {|aInt, nOpc| FINA050(aInt,, nOpc)}
         nOpc := EXCLUIR
      ElseIf cOpc == "BAIXA"
         //TDF - 23/12/11 - Fecha a Work TMP para que a rotina FINA050 n�o a apague
         If Select("TMP") > 0
            TMP->(DbCloseArea())
         EndIF
         bInt := {|aInt, nOpc| FINA080(aInt,nOpc)}
         nOpc := 3
      ElseIf cOpc == "ESTBAIXA"
         //TDF - 23/12/11 - Fecha a Work TMP para que a rotina FINA050 n�o a apague
         If Select("TMP") > 0
            TMP->(DbCloseArea())
         EndIF
         bInt := {|aInt, nOpc, nPar1, nPar2| Fina080(aInt, nOpc, nPar1, nPar2)}
         nOpc := EXCLUIR
      EndIf
   ElseIf cInt == "SE5" //Movimentacao Banc�ria
      If cOpc == "PAGAR"
         bInt := {|aInt, nOpc| FINA100(,aInt,nOpc)}
         nOpc := 3
      ElseIf cOpc == "RECEBER"
         bInt := {|aInt, nOpc| FINA100(,aInt,nOpc)}
         nOpc := 4
      ElseIf cOpc == "EXCLUIR"
         bInt := {|aInt, nOpc| FINA100(,aInt,nOpc)}
         nOpc := 5
      ElseIf cOpc == "CANCELAR"
         bInt := {|aInt, nOpc| FINA100(,aInt,nOpc)}
         nOpc := 6
      ElseIf cOpc == "TRANSFERENCIA"
         bInt := {|aInt, nOpc| FINA100(,aInt,nOpc)}
         nOpc := 7
      ElseIf cOpc == "ESTORNO_TRANSFERENCIA"
         bInt := {|aInt, nOpc| FINA100(,aInt,nOpc)}
         nOpc := 8
      EndIf
   EndIf
   If nOpc > 0 .And. ValType(__aInt) == "A" .And. Len(__aInt) > 0

      //THTS - 31/10/2018 - Tratamento para incluir um quarto parametro no array, quando foi baixa do contas a receber.
      //Este quarto par�metro serve para o financeiro nao recaulcular multa e juros para titulos vencidos.
      If cOpc == "BAIXA"
            If (nPosJurMul := aScan( __aInt,{|x|"AUTJUROS" $ x[1]})) > 0 .AND. Empty(__aInt[nPosJurMul,2])
                  aJurMul := {__aInt[nPosJurMul,1],__aInt[nPosJurMul,2],__aInt[nPosJurMul,3],.T.}
                  __aInt[nPosJurMul]  := aClone(aJurMul)
            EndIf
            If (nPosJurMul := aScan( __aInt,{|x|"AUTMULTA" $ x[1]})) > 0 .AND. Empty(__aInt[nPosJurMul,2])
                  aJurMul := {__aInt[nPosJurMul,1],__aInt[nPosJurMul,2],__aInt[nPosJurMul,3],.T.}
                  __aInt[nPosJurMul]  := aClone(aJurMul)
            EndIf
      EndIf

      // LGS - 01/07/2016
      If EasyEntryPoint("AVINT101")
         aIntTitFin := aClone(__aInt)
         ExecBlock("AVINT101",.F.,.F.,"ALT_ARRAY_FIN_AVINT101")
         __aInt := aClone(aIntTitFin)
      EndIf

      // GFP - 03/06/2015 - O EasyLink n�o est� enviando Nil na terceira posi��o, com isso as valida��es n�o s�o executadas.
      For i := 1 To Len(__aInt)
         __aInt[i][3] := Nil
      Next
      
      //NCF - 26/04/2017 - Fazer o backup da filial caso esteja liquidando parcela de c�mbio de uma filial vinculada a contrato de financiamento de outra filial.
      cFilAntBkp := cFilAnt
      If Type("lMultifil") == "L" .And. lMultifil .and. (nPosFilaSE2 := aScan( __aInt,{|x|"E2_FILIAL" $ x[1]})) > 0 .And. !Empty(__aInt[nPosFilaSE2][2]) .And. FWModeAccess("SE2",3) == "E" .And. __aInt[nPosFilaSE2][2] <> cFilAnt
         cFilAnt := __aInt[nPosFilaSE2][2]
      EndIf 
      
      MSExecAuto(bInt, __aInt, nOpc, nPar1, nPar2)
      
      cFilAnt := cFilAntBkp

	  IF cModulo == "ESS" //LRS -10/09/2015
         SetFunName(cOldFunName)
     Endif

      If ValType(NomeAutoLog()) == "C" .And. !Empty(MemoRead(NomeAutoLog()))
         cMsg := MemoRead(NomeAutoLog())

         /*
            Pode ocorrer de o financeiro alertar que o valor recebido � maior do que o a receber
            (varia��o cambial, etc.). Esta valida��o n�o � impeditiva, portanto iremos ignor�-la quando estiver no log.

            GFP - 15/09/2015 - Passou a ser impeditivo em cenarios que a moeda do Banco ser a mesma do processo.
         */
         //If At("VALORMAIOR", cMsg) > 0 .AND. cInt == "SE1" .AND. cOpc == "BAIXA"
         //   cMsg := ""
         //EndIf

         FErase(NomeAutoLog())
         __cFileLog := Nil
         Break
      //RRC - 25/02/2013 - Verifica tamb�m a vari�vel l�gica para ver se houve erro
      ElseIf lMsErroAuto
         EasyHelp("A grava��o n�o ocorreu devido � impossibilidade de integra��o com o m�dulo Financeiro.")
         Break
      Else
         If !Empty(cAliasF)
            If cAliasF == 'EEQ' .And. (!empty(cFinNum) .Or. cOpc == "BAIXA" .Or.  cOpc == "ESTBAIXA")
               EEQ->(RECLOCK("EEQ",.F.))
               If !empty(cFinNum) 
                  EEQ->EEQ_FINNUM := cFinNum
               EndIf
               If cOpc == "BAIXA"
                  EEQ->EEQ_SEQBX := EGetSeqSE5(__aInt)
               ElseIf cOpc == "ESTBAIXA"
                  EEQ->EEQ_SEQBX := ""
               EndIf
               EEQ->(MsUnlock())
            ElseIf cAliasF == 'EET' .And. !empty(cFinNum)
               EET->(RECLOCK("EET",.F.))
               EET->EET_FINNUM := cFinNum
               EET->(MsUnlock())
            EndIf               
         EndIf
      EndIf      
   EndIf

End Sequence

Return cMsg

/*
Fun��o     : EECInCom(__aInt, cInt, cOpc, nPar1, nPar2)
Par�metros : __aInt - Array de dados a serem enviados
             cInt - Tabela que ser� integrada
             cOpc - Tipo de opera��o (Inclus�o, Altera��o, Baixa, Estorno da baixa)
             nPar1 - Par�metro adicional
             nPar2 - Par�metro adicional
Retorno    : cMsg - Mensagem retornada pela fun��o de integra��o
Objetivos  : Faz a chamada de fun��es de integra��o com o m�dulo de Compras
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 16/01/15
Revisao    :
Obs.       :
*/
Function EECInCom(__aCab, __aItem, cInt, cOpc, nTipo)
Local bInt
Local nOpc := 0
Local cMsg := ""
Local i,j
Local cArqLog := If(NomeAutoLog() == NIL,"",NomeAutoLog()) //NCF - 21/02/2019
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

Private aCab := __aCab, aItem := __aItem

Default cOpc := ""
Default cInt := ""

//RMD - 22/05/18 - Verifica se existe log de uma execu��o anterior de ExecAuto e caso positivo apaga para n�o acusar erro na pr�xima execu��o
If !Empty(cArqLog) .And. File(cArqLog)
      FErase(cArqLog)
      __cFileLog := Nil
EndIf

Begin Sequence
   If cInt == "SC7"
      If cOpc == "INCLUIR"
         bInt := {|nTipo,aCab,aItem,nOpcao| Mata120(nTipo,aCab,aItem,nOpcao) }
         nOpc := INCLUIR
      ElseIf cOpc == "EXCLUIR"
         bInt := {|nTipo,aCab,aItem,nOpcao| Mata120(nTipo,aCab,aItem,nOpcao) }
         nOpc := EXCLUIR
      EndIf
   EndIf

   //*** RMD - 21/01/15 - Provis�rio - O EasyLink n�o est� enviando Nil na terceira posi��o, com isso as valida��es n�o s�o executadas.
   For i := 1 To Len(aCab)
      aCab[i][3] := Nil
   Next

   For i := 1 To Len(aItem)
      For j := 1 To Len(aItem[i])
         aItem[i][j][3] := Nil
      Next
   Next
   //***

   If EasyEntryPoint("AVINT101")
      ExecBlock("AVINT101",.F.,.F.,"EECINCOM")
   EndIf

   If nOpc > 0 .And. ValType(aCab) == "A" .And. Len(aCab) > 0
      MSExecAuto(bInt, nTipo,aCab,aItem,nOpc)
      If ValType(NomeAutoLog()) == "C" .And. !Empty(MemoRead(NomeAutoLog()))
         cMsg := MemoRead(NomeAutoLog())
         FErase(NomeAutoLog())
         __cFileLog := Nil
         Break
      ElseIf lMsErroAuto
         EasyHelp("A grava��o n�o ocorreu devido � impossibilidade de integra��o com o m�dulo de Compras.")
         Break
      EndIf
   EndIf

End Sequence

Return cMsg

/*
Fun��o     : EECBxFiTit
Par�metros : Nenhum
Retorno    : lRet - Indica se a fun��o foi executada corretamente.
Objetivos  : Gera titulo no SIGAFIN com base no valor no embarque e baixa os titulos provis�rios lan�ados em fase de pedido
             quando integrado com o SIGAFAT, quando o processo � embarcado. Ao estornar o embarque, estorna as opera��es tamb�m.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    :
Obs.       : Considera a WorkIp ativa e alimentada com os itens do embarque.
*/
*--------------------*
Function EECBxFiTit()
*--------------------*
Local lEstorno
//Local aPedFat := {}, aOrd := SaveOrd("SE5")
Local aOrd := SaveOrd("SE5")
Local nInc
Local lRet := .T.  // GFP - 05/09/2012
Private nValorBaixa, nParcEst
Private cPed, nTotalTit := 0
Private dDtEmba := M->EEC_DTEMBA
Private dEECDtEmba := EEC->EEC_DTEMBA
Private dDtBaixa
Private aBanco := xCxFina() //LRS
Private cBanco := aBanco[1], cAgencia := aBanco[2], cConta := aBanco[3]//LRS
//Private lRet := .T.  // Nopado por GFP - 05/09/2012

Private lBxNfFat := .T. //Indica que est� fazendo a baixa do t�tulo da Nota Fiscal

Begin Sequence

   /*ISS - 05/01/11 - Ponto de entrada para a altera��o da vari�vel dDTEMBA que guarda a data do campo M->EEC_DTEMBA,
                  este campo ser� usado em diversas valida��es abaixo. */
   If EasyEntryPoint("AVINT101")
      ExecBlock("AVINT101", .F., .F., "EECBXFITIT_ALTDTEMBA")
   EndIf

   /*ISS - 05/01/11 - Alterado uso do campo M->EEC_DTEMBA para a variavel private dDTEMBA
                      para atender o ponto de entrada "EECBXFITIT_ALTDTEMBA" */
   //If Empty(M->EEC_DTEMBA)
   If Empty(dDTEMBA)
      /*ISS - 19/01/11 - Alterado uso do campo EEC->EEC_DTEMBA para a variavel private dDTEMBA
                      para atender o ponto de entrada "EECBXFITIT_ALTDTEMBA" */
      //If nSelecao == INCLUIR .Or. Empty(EEC->EEC_DTEMBA)
      If nSelecao == INCLUIR .Or. Empty(dEECDtEmba)
         Break
      Else
         lEstorno := .T.
      EndIf
   Else
      /*ISS - 19/01/11 - Alterado uso do campo EEC->EEC_DTEMBA para a variavel private dDTEMBA
                         para atender o ponto de entrada "EECBXFITIT_ALTDTEMBA" */
      //If nSelecao == INCLUIR .Or. !Empty(EEC->EEC_DTEMBA)
      If nSelecao == INCLUIR .Or. !Empty(dEECDtEmba)
         Break
      Else
         lEstorno := .F.
      EndIf
   EndIf


   ////////////////////////////////////////////////////////////
   //Busca os t�tulos lan�ados para cada nota fiscal de sa�da//
   //{E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, RecNo}        //
   ////////////////////////////////////////////////////////////

   aTit:= AClone(INT101BuscaTit("WORKIP"))

   For nInc:= 1 To Len(aTit)

      //Posiciona no t�tulo
      //O t�tulo ser� baixado apenas quando o par�metro MV_MOEDTIT estiver como "N".
      //Cao o par�metro esteja como "S", o t�tulo apenas ser� baixado se n�o for PR.
      SE1->(DbSetOrder(1))
      SE1->(DBGoTo(aTit[nInc][5]))
      SE5->(DbSetOrder(7))

      If lEstorno

         If !AF201PosicSE5("SE1")
            SE1->(DbSkip())
            Loop
         EndIf

         nValorBaixa := SE5->E5_VALOR

         //Cancela Baixa
         If !(lRet := AvStAction("009"))
            //MsgInfo(STR0012,STR0013) //wfs  //"Impossibilidade de integra��o com o m�dulo Financeiro. Verifique o LogViewer" ### "Aviso"
            Break
         EndIf

      Else

         If AllTrim(EasyGParam("MV_MOEDTIT",, "N")) == "S"
            nValorBaixa := Round(SE1->E1_VALOR * BuscaTaxa(aTit[nInc][6], M->EEC_DTEMBA,,.F.), AvSx3("E1_VALOR", AV_DECIMAL))//Arredonda para o tamanho do decimal do campo valor para n�o ficar maior na integra��o
         Else
            nValorBaixa := SE1->E1_VALOR
         EndIf

         //Faz a baixa do total
         dDtBaixa := dDtEmba
         If !(lRet := AvStAction("008"))//Baixa de titulo da nota fiscal
            //MsgInfo(STR0012,STR0013) //wfs  //"Impossibilidade de integra��o com o m�dulo Financeiro. Verifique o LogViewer" ### "Aviso"
            Break
         EndIf

      EndIf

   Next

   // BAK - Fun�ao esta sendo chamada na funcao AF200GPARC
   //If lRet
   //   lRet := EECRABaixa(lEstorno)
   //EndIf


End Sequence

RestOrd(aOrd, .T.)

Return lRet

/*
Fun��o     : INT101BuscaTit()
Par�metros : cAlias - WorkIp ou EEQ
Retorno    : aRet - Array com os t�tulos gerados para o processo
Objetivos  : Retornar os t�tulos gerados a partir da nota fiscal vinculada ao processo de exporta��o
Autor      : Wilsimar Fabr�cio da Silva
Data/Hora  : 06/2011
Revisao    :
Obs.       :
*/
Function INT101BuscaTit(cAlias)
Local aNfFat:= {},;
      aRet  := {},;
      aOrd  := SaveOrd({"SE1", "SF2"})
Local cPrefixo:= ""
Local nRecnoIp:= 0,;
      nInc    := 0


Begin Sequence

   If !IsIntFat()
      Break
   EndIf

   Do Case
      Case Upper(cAlias) == "WORKIP"

         nRecnoIp:= WorkIp->(Recno())
         WorkIp->(DBGoTop())

         While WorkIp->(!Eof())
            If !Empty(WorkIp->WP_FLAG)
               If AScan(aNfFat, {|x| x[1] == WorkIp->EE9_NF .and. x[2] == WorkIp->EE9_SERIE}) == 0
                  AAdd(aNfFat, {WorkIp->EE9_NF, WorkIp->EE9_SERIE, WorkIp->EE9_PEDIDO})
               EndIf
            EndIf
            WorkIp->(DBSkip())
         EndDo

         WorkIp->(DBGoTo(nRecnoIp))

      Case Upper(cAlias) == "EEQ"

         EE9->(DBSetOrder(2))
         EE9->(DBSeek(xFilial() + M->EEQ_PREEMB))

         While EE9->(!Eof()) .And. EE9->EE9_FILIAL == EE9->(xFilial()) .And.;
               EE9->EE9_PREEMB == M->EEQ_PREEMB

            If AScan(aNfFat, {|x| x[1] == EE9->EE9_NF .and. x[2] == EE9->EE9_SERIE}) == 0
               AAdd(aNfFat, {EE9->EE9_NF, EE9->EE9_SERIE, EE9->EE9_PEDIDO})
            EndIf

            EE9->(DBSkip())
         EndDo

   End Case


   ////////////////////////////////////////////////////////////
   //Busca os t�tulos lan�ados para cada nota fiscal de sa�da//
   ////////////////////////////////////////////////////////////
   For nInc := 1 To Len(aNfFat)

      ///////////////////////////////
      //Carrega o prefixo do t�tulo//
      ///////////////////////////////
      cPrefixo := AllTrim(aNfFat[nInc][2])

      SF2->(dbSetOrder(1))
      If SF2->(DBSeek(xFilial()+AvKey(aNfFat[nInc][1],"F2_DOC")+AvKey(aNfFat[nInc][2],"F2_SERIE")))
         If !Empty(SF2->F2_PREFIXO)
            cPrefixo := SF2->F2_PREFIXO
         EndIf
      EndIf

      ///////////////////////
      //Carrega os t�tulos //
      ///////////////////////
      SE1->(DbSetOrder(1))
      If SE1->(DBSeek(xFilial("SE1")+AvKey(cPrefixo,"E1_PREFIXO")+AvKey(aNfFat[nInc][1],"E1_NUM")))

         While SE1->(!EOF()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == ;
                              xFilial("SE1")+AvKey(cPrefixo,"E1_PREFIXO")+AvKey(aNfFat[nInc][1],"E1_NUM")

            IF AvKey(SE1->E1_TIPO,"E1_TIPO") <> "NF" //LRS - 18/03/2015
              SE1->(DbSkip())
            else
            AAdd(aRet, {SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->(RecNo()), Posicione("EE7", 1, xFilial("EE7")+aNfFat[nInc][3], "EE7_MOEDA")})

            SE1->(DbSkip())
            EndIF
         EndDo
      EndIf

   Next



End Sequence

RestOrd(aOrd, .T.)
Return aRet

/*
Fun��o     : IsIntEnable(cInt)
Par�metros : cInt - C�digo da integra��o
Retorno    : lRet - Indica se a integra��o est� ativa
Objetivos  : Verifica se uma integra��o est� ativa, com base na condi��o definida no cadastro de integra��es
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    :
Obs.       :
*/
*------------------------*
Function IsIntEnable(cInt)
*------------------------*
Local aOrd := SaveOrd("EYA")
Local lRet := .F.
Local bError := ErrorBlock({|| .T. })
Default cInt := ""
cInt := AvKey(cInt, "EYA_CODINT")

Begin Sequence
   EYA->(DbSetOrder(1))
   If (lRet := EYA->(DbSeek(xFilial()+cInt)))
      If !Empty(EYA->EYA_COND)
         bCond := &("{|| " + EYA->EYA_COND  + "}")
         lRet := Eval(bCond)
         If ValType(lRet) <> "L"
            lRet := .F.
         EndIf
      EndIf
   EndIf
End Sequence

ErrorBlock(bError)
RestOrd(aOrd, .T.)
Return lRet

/*
Fun��o     : EECRABaixa(lEstorno)
Par�metros : lEstorno - Indica se ser� feito um estorno da baixa
Retorno    : lRet
Objetivos  : Efetua baixa de t�tulos de pagamento antecipado
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Revisao    :
Obs.       :
*/
*---------------------------*
Function EECRABaixa(lEstorno)
*---------------------------*
Local lRet := .T.
Local aOrd := SaveOrd({"EEQ", "SE1", "SE5"})
Local cFinNum  // RMD - 24/08/2012
Local aDadosRA
Private nValorBaixa:= 0, dDtBaixa
Private cParcIntBx:= AvKey(" ", "E1_PARCELA")
Private dDtTax := EEC->EEC_DTEMBA
Private aBanco := xCxFina() //LRS
Private cBanco := aBanco[1], cAgencia := aBanco[2], cConta := aBanco[3]//MPG

Begin Sequence

   If !EasyGParam("MV_AVG0039",,.f.)//Define se adiantamentos est�o habilitados no sistema
      Break
   EndIf

   EEQ->(DbSetOrder(6))
   SE1->(DbSetOrder(1))///E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
   EEQ->(DbSeek(xFilial("EEQ")+"E"+M->EEC_PREEMB))
   Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                                EEQ->EEQ_FASE   == "E" .And.;
                                EEQ->EEQ_PREEMB == EEC->EEC_PREEMB

      If EEQ->EEQ_TIPO == "A"

         //TRP - 22/12/2011 - Ponto de Entrada para tratar o campo Parcela do T�tulo a ser Baixado.
         If EasyEntryPoint("AVINT101")
            ExecBlock("AVINT101", .F., .F., "ALTERA_PARCELA")
         EndIf

         //IF !Empty(EEQ->EEQ_FINNUM) .And. (lRet := SE1->(DbSeek(xFilial()+"EEC"+EEQ->EEQ_FINNUM+AvKey(" ", "E1_PARCELA")+AvKey("RA","E1_TIPO"))))
         aDadosRA := GetRAFinNum()                                                                                                          //NCF - 04/07/2019
         IF !Empty(cFinNum := aDadosRA[1]) .And. (lRet := SE1->(DbSeek(xFilial()+"EEC"+cFinNum+cParcIntBx+AvKey(aDadosRA[2],"E1_TIPO"))))   // RMD - 24/08/2012
            If lEstorno
               SE5->(DbSetOrder(7))  //NCF - 14/03/2017 - Recup. e Posicion. com o SEQBX para posicionar a baixa correta em caso de chaves iguais
               IF Empty(EEQ->EEQ_SEQBX) //LRS - 25/01/2018 - Correcao para casos antigos que n�o tem o campo EEQ_SEQBX preenchido
                  lRet := AF201PosicSE5("SE1", EEQ->EEQ_PGT, EEQ->EEQ_EQVL)
               Else
                  lRet := SE5->(DbSeek(xFilial()+ SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA+AvKey(EEQ->EEQ_SEQBX,"E5_SEQ"))))
               EndIF

               If lRet 
                  nParcEst := Val(SE5->E5_SEQ)
                  If !(lRet := AvStAction("009"))//Estorno de Baixa de Titulo a Receber
                     Break
                  EndIf
               EndIf
            Else
               /*
               13/07/13 - 	Tratamento removido. Ao atualizar estas informa��es na baixa, perde-se a rastreabilidade da taxa de inclus�o.
               				A utiliza��o da taxa da data de embarque deve ocorrer somente na baixa do t�tulo (avlink006.xml), para gerar a varia��o cambial.
               */
               //If Reclock("EEQ",.F.)
               //   EEQ->EEQ_TX := BuscaTaxa(EEC->EEC_MOEDA, EEC->EEC_DTEMBA,,.F.)
               //   EEQ->EEQ_EQVL := Round(EEQ->EEQ_VL*BuscaTaxa(EEC->EEC_MOEDA, /*EEC->EEC_DTEMBA*/ dDtTax,,.T.),AvSX3("EEQ_EQVL",AV_DECIMAL)) //RRV - 11/03/2013
               //   EEQ->(MsUnLock())
               //EndIf

               //MFR OSSME-2277 12/02/2019               
               If !Empty(EEQ->EEQ_PGT) .OR. ( EasyVerModal() .AND. !Empty(EEQ->EEQ_DTCE) )
               
                  //13/07/13 - O valor recebido ir� considerar a taxa da data de embarque
                  nValorBaixa:= Round(EEQ->EEQ_VL*BuscaTaxa(EEC->EEC_MOEDA, dDtTax,,.T.),AvSX3("EEQ_EQVL",AV_DECIMAL))
                  dDtBaixa   := EEC->EEC_DTEMBA
                  If !(lRet := AvStAction("008"))//Baixa de Titulo a Receber
                     Break
                  EndIf
                  aOrdSE5Tmp := SaveOrd("SE5")     //NCF - 14/03/2017 - Se deu certo, a sequencia de Baixa � a �ltima gravada (mesmo que a chave seja igual)
                  SE5->(DbSetOrder(7))
                  SE5->(AvSeekLast(  xFilial()+ SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)  ))
                  If EEQ->(IsLocked())
                     EEQ->EEQ_SEQBX := SE5->E5_SEQ //NCF - 14/03/2017 - Grava��o do SEQBX para identificar a baixa em caso de chaves iguais
                  Else
                     EEQ->(RecLock("EEQ",.F.))
                     EEQ->EEQ_SEQBX := SE5->E5_SEQ //NCF - 14/03/2017 - Grava��o do SEQBX para identificar a baixa em caso de chaves iguais
                     EEQ->(MsUnlock())
                  EndIf
                  RestOrd(aOrdSE5Tmp ,.T.)
               EndIf
            EndIf
         EndIf
      EndIf
      EEQ->(DBSkip())
   EndDo

End Sequence
RestOrd(aOrd, .T.)

Return lRet   // RMD - 24/08/2012

/*
Fun��o:    GetRAFinNum()
Autor:     Rodrigo Mendes Diaz
Objetivos: Obter o n�mero do t�tulo da parcela original vinculada ao adiantamento do embarque (fase pedido ou cliente).
Data:      24/08/12
Obs:       04/07/2019 - Modificada o tipo de retorno por Nilson C�sar para retornar um array com mais informa��es da parcela de adiantamento.
*/
Static Function GetRAFinNum()
Local aOrd := SaveOrd("EEQ"), aFinNum := {"",""}

	EEQ->(DbSetOrder(6))
	If EEQ->(DbSeek(xFilial()+EEQ_FAOR+EEQ_PROR+EEQ_PAOR))
	   aFinNum[1] :=  EEQ->EEQ_FINNUM
         aFinNum[2] :=  TETpTitEEQ("EEQ")
	EndIf

RestOrd(aOrd, .T.)
Return aFinNum

/*
Fun��o     : AvGeraTit
Par�metros : cAliasOri  := Alias de Origem
             cAliasDest := Alias de Destino
             aCposInt   := Campos a serem verificados
Retorno    : lRet
Objetivos  : Verificar se houve altera��es significativas que
             permitem a altera��o no t�tulo do SigaFIN.
Autor      : Eduardo C. Romanini
Data/Hora  : 03/12/09
*/
*-----------------------------------------------*
Function AvGeraTit(cAliasOri,cAliasDest,aCposInt)
*-----------------------------------------------*
Local lRet := .F.

Local nInc := 0
Local nPosCpo                                    //NCF - 19/08/2014

Begin Sequence

   If !AvFlags("EEC_LOGIX")                      //NCF - 19/08/2014 - Permitir altera��o de vencimento na Integ. LOGIX

      If Empty(cAliasOri) .or. Empty(cAliasDest) .or. Empty(aCposInt)
         Break
      EndIf

      For nInc:= 1 To Len(aCposInt)
         //RMD - 06/10/12 - N�o recria t�tulos devido a altera��o no valor quando o tratamento de parcelas estiver ligado
         If aCposInt[nInc] == "EEQ_VL" .And. (EECFlags("TIT_PARCELAS") .And. EECFlags("ALT_EASYLINK")) .And. IsReceita(&(cAliasOri+"->"+"EEQ_EVENT"))//RMD - 31/10/14 - Este cen�rio somente ocorre quando temos ALT_EASYLINK habilitado
            Loop
         EndIf
         //RMD - 06/10/12 -
         If aCposInt[nInc] == "EEQ_VCT" .And. EECFlags("TIT_PARCELAS") .And. !Empty(&(cAliasDest+"->"+"EEQ_ORIGEM")) .And. cAliasOri <> "M" //RMD - 06/03/15 - N�o verifica a base quando o AliasOri for mem�ria.
            If (cAliasOri)->(AF200GetLastVct(EEQ_PREEMB, EEQ_ORIGEM, EEQ_PARC)) < &(cAliasDest+"->"+"EEQ_VCT")//(cAliasOri)->EEQ_VCT //RMD - 26/12/14 - Tratamento para quando o Alias for "M"
               lRet := .T.
               Break
            Else
         	   Loop
            EndIf
         EndIf

         If  aCposInt[nInc] == "EEQ_MODAL" .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. "121" $  &(cAliasOri+"->"+"EEQ_EVENT")
            If ( &(cAliasDest+"->"+aCposInt[nInc]) == '2' .And. &(cAliasOri+"->"+aCposInt[nInc]) == '1' .and. !Empty(&(cAliasDest+"->"+"EEQ_FINNUM")) ) // Altera��o de modalidade do c�mbio de conta gr�fica de "2-Movimento no Exterior" para "1 - C�mbio de Exporta��o" -> EXCLUI TITULO
               lIncCAPCCG := .F.
               lExcCAPCCG := .T.
               lRet := .T.
               Break
            ElseIf( &(cAliasDest+"->"+aCposInt[nInc]) == '1' .And. &(cAliasOri+"->"+aCposInt[nInc]) == '2' .and. Empty(&(cAliasDest+"->"+"EEQ_FINNUM")) ) // Altera��o de modalidade do c�mbio de conta gr�fica de "1 - C�mbio de Exporta��o" para "2-Movimento no Exterior"  -> INCLUI TITULO
               lIncCAPCCG := .T.
               lExcCAPCCG := .F.
               lRet := .T.
               Break
            EndIf
         EndIf

         If &(cAliasOri+"->"+aCposInt[nInc]) <> &(cAliasDest+"->"+aCposInt[nInc])
            lRet := .T.
            Break
         EndIf
      Next
   Else

      If Empty(cAliasOri) .or. Empty(cAliasDest) .or. Empty(aCposInt)
         Break
      EndIf
      //NCF - 19/08/2014 - Permitir integrar altera��o do vencimento do t�tulo no Logix
      If(nPosCpo := aScan(aCposInt,"EEQ_VCT")) > 0
         //NCF - 03/11/2014 - Verificar Adiantamentos
         If cAliasOri == "Work_Pgto"
            cAliasCheck := If( Work_Pgto->RECNO <> 0 , "EEQ" , "Work_Pgto" )
         ElseIf cAliasOri == "TMP"
            cAliasCheck := If( TMP->TMP_RECNO <> 0 , "EEQ" , "TMP" )
         Else
            cAliasCheck := "EEQ"
         EndIf
                                                                                                                    //NCF - 12/12/2014
         If &(cAliasOri+"->"+aCposInt[nPosCpo]) <> &(cAliasDest+"->"+aCposInt[nPosCpo]) .and. ;                     //      Verifica se h� altera��o de data na parcela em rela��o a base
         !Empty( &(cAliasDest+"->"+aCposInt[nPosCpo]) ) .and. ;                                                     //      Verifica se o vencimento da parcela da base n�o est� vazio (inclus�o de registro)
         aScan(aTMPAlt, {|X|  X[ (cAliasOri)->(FieldPos("EEQ_FILIAL")) ] == (cAliasCheck)->EEQ_FILIAL .And. ;       //      Verifica se h� vencimento maior nas parcelas que foram desmembradas a partir da atual
                              X[ (cAliasOri)->(FieldPos("EEQ_PREEMB")) ] == (cAliasCheck)->EEQ_PREEMB .And. ;
                              X[ (cAliasOri)->(FieldPos("EEQ_PARC"))   ] <> (cAliasCheck)->EEQ_PARC   .And. ;
                              X[ (cAliasOri)->(FieldPos("EEQ_FASE"))   ] == (cAliasCheck)->EEQ_FASE   .And. ;
                              X[ (cAliasOri)->(FieldPos("EEQ_FINNUM")) ] == (cAliasCheck)->EEQ_FINNUM .And. ;
                              X[ (cAliasOri)->(FieldPos("EEQ_VCT"))    ] >  (cAliasCheck)->EEQ_VCT            }) == 0

            lIntAltLGX := .T.
            lRet := .T.
            Break
         EndIf
      EndIf

      If(nPosCpo := aScan(aCposInt,"EET_DTVENC")) > 0  // GFP - 18/08/2016 - Tratamento de Despesas Nacionais
         If cAliasOri == "WorkDe"
            cAliasCheck := cAliasDest
         EndIf

         For nInc := 1 To Len(aCposInt)
            If (cAliasOri)->&(aCposInt[nInc]) <> (cAliasCheck)->&(aCposInt[nInc])

               lIntAltLGX := .T.
               lRet := .T.
               Break
            EndIf
         Next nInc
      EndIf

      //NCF - 15/05/2015 - Verificar se houve altera��o no adiantamento (inseriu data de liquida��o)
      If cAliasOri == "Work_Pgto" .And. (nPosCpoPgt := aScan(aCposInt,"EEQ_PGT")) > 0
         If !Empty( &(cAliasOri+"->"+aCposInt[nPosCpoPgt]) ) .And. Empty( &(cAliasDest+"->"+aCposInt[nPosCpoPgt]) )
            lRet := .T.
            Break
         EndIf
      EndIf

      If cAliasOri $ "EET|WorkDe" .And. (nPosCpoTit := (cAliasOri)->(FieldPos("EET_FINNUM")) ) > 0 .And. Empty((cAliasOri)->EET_FINNUM)
         lRet := .T.
         Break
      EndIf

   EndIf

End Sequence

Return lRet

/*
Fun��o     : IsTitBaixa
Par�metros :
Retorno    : lRet
Objetivos  : Verificar se o t�tulo est� baixado no financeiro.
Autor      : Eduardo C. Romanini
Data/Hora  : 03/12/09
*/
*--------------------------------------------*
Function IsTitBaixa(cPrefixo,cTitulo,cParcela)
*--------------------------------------------*
Local lRet := .F.
Local aSaveOrd := SaveOrd("SE2")
Default cPrefixo := "EEC"
Default cParcela := ""

Begin Sequence

   If Empty(cTitulo)
      Break
   EndIf

   SE2->(DbSetOrder(1)) //MCF - 02/07/2015
   If SE2->(DbSeek(xFilial("SE2")+AvKey(cPrefixo,"E2_PREFIXO")+AvKey(cTitulo,"E2_NUM")+AvKey(cParcela,"E2_PARCELA")))
      If !Empty(SE2->E2_BAIXA)
         lRet := .T.
         Break
      Endif
   EndIf

End Sequence

RestOrd(aSaveOrd)

Return lRet

/*
Fun��o     : INT101RetMod
Par�metros :
Retorno    : cAltMod
Objetivos  : Alterar a extens�o do campo cModulo
Autor      : Diogo Felipe dos Santos
Data/Hora  : 16/03/11
*/
*---------------------*
Function INT101RetMod()
*---------------------*

Local cAltMod := ""

Do Case

   Case cModulo == "EEC"
      cAltMod := "SIGAEEC"

   Case cModulo == "EIC"
      cAltMod := "SIGAEIC"

   Case cModulo == "EFF"
      cAltMod := "SIGAEFF"

   Case cModulo == "EDC"
      cAltMod := "SIGAEDC"

   Case cModulo == "ECO"
      cAltMod := "SIGAECO"

   //RRC - 27/02/2013
   Case cModulo == "ESS"
      cAltMod := "SIGAESS"

End Case

Return cAltMod

/*
Fun��o     : ELinkSetLastID
Par�metros :
Retorno    : Nil
Objetivos  : Armazena ID
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 20/08/2012 - 17:25
*/
Function ELinkSetLastID()
Local aOrd := SaveOrd("EYF")

   __ELinkLastID := ""

   EYF->(DbSetOrder(1))
   EYF->(DbGoBottom())
   If EYF->(!Eof())
      __ELinkLastID := EYF->EYF_ID
   EndIf

RestOrd(aOrd, .T.)
Return Nil

Function ELinkGetLastID()
Return __ELinkLastID

/*
Fun��o     : ELinkRollBackTran
Par�metros :
Retorno    : Nil
Objetivos  : Efetua backup da ultima transa��o antes de efetuar rollback
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 20/08/2012 - 17:25
*/
Function ELinkRollBackTran()
Local aOrd := SaveOrd("EYF"), cID := ""
Local nI

local aDados := {}

Begin Sequence
   /*If !Empty(ELinkGetLastID())
      EYF->(DbSetOrder(1))
      If EYF->(DbSeek(xFilial()+ELinkGetLastID()))
         EYF->(DbSkip())
      EndIf
   ElseIf EYF->(EasyRecCount()) > 0   // GFP - 30/09/2016 - Ajuste para cenarios em que a EYF, inicialmente, est� vazia e com isso, o ELinkGetLastID() retorna vazio, e n�o recupera os dados exclu�dos.
      EYF->(DbGoBottom())
      cID := EYF->EYF_IDORI
      EYF->(DbSetOrder(1))
      EYF->(DbSeek(xFilial()+AvKey(cID,"EYF_ID")))
   EndIf*/
   For nI := 1 To Len(aLogID)
      EYF->(dbGoTo(aLogID[nI][3]))
      aDados := if(len(aLogID[nI]) > 3 .and. valtype(aLogID[nI][4]) == "A", aLogID[nI][4], if( EYF->(Recno()) == aLogID[nI][3], EYF->({EYF_FILIAL, EYF_DESSTA, EYF_STATUS, EYF_DATAI, EYF_HORAI, EYF_DATAF, EYF_HORAF, EYF_ARQXML, EYF_USER, EYF_ID, EYF_IDORI, EYF_NOMINT, EYF_CODINT, EYF_CODAC, EYF_DESAC, EYF_CODEVE, EYF_CODSRV}),{}))
      if len(aDados) > 0
         aAdd(aBuffer,aClone(aDados))
      endif
      aSize(aDados, 0)
   Next
   RollBackDelTran("")
End Sequence

//DFS - 24/01/13 - Inclus�o de tratamento para que, grave o log viewer caso a transa��o n�o seja efetivada.
ELinkClearID()

RestOrd(aOrd, .T.)
Return Nil

/*
Fun��o     : ELinkClearID
Par�metros :
Retorno    : Nil
Objetivos  : Armazena dados do aBuffer na tabela EYF
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 20/08/2012 - 17:25
*/
Function ELinkClearID()
Local i

If !Empty(aBuffer)
   //DFS - 24/01/13 - S� deve gravar no log viewer os casos de a��o n�o conclu�da.
   For i := 1 To Len(aBuffer)
      If EYF->(RecLock("EYF",.T.)) .AND. aBuffer[i][3] == "01" .OR. aBuffer[i][3] == "03"
         EYF->EYF_FILIAL := aBuffer[i][1]
         EYF->EYF_DESSTA := aBuffer[i][2]
         EYF->EYF_STATUS := aBuffer[i][3]
         EYF->EYF_DATAI  := aBuffer[i][4]
         EYF->EYF_HORAI  := aBuffer[i][5]
         EYF->EYF_DATAF  := aBuffer[i][6]
         EYF->EYF_HORAF  := aBuffer[i][7]
         EYF->EYF_ARQXML := aBuffer[i][8]
         EYF->EYF_USER   := aBuffer[i][9]
         EYF->EYF_ID     := aBuffer[i][10]
         EYF->EYF_IDORI  := aBuffer[i][11]
         EYF->EYF_NOMINT := aBuffer[i][12]
         EYF->EYF_CODINT := aBuffer[i][13]
         EYF->EYF_CODAC  := aBuffer[i][14]
         EYF->EYF_DESAC  := aBuffer[i][15]
         EYF->EYF_CODEVE := aBuffer[i][16]
         EYF->EYF_CODSRV := aBuffer[i][17]
         EYF->(MsUnlock())
      EndIf
   Next i
EndIf

aBuffer := {}
aLogID  := {}
__ELinkLastID := ""

Return Nil

/*
Fun��o     : Int101GetCond()
Par�metros :
Retorno    : lRet
Objetivos  : Condi��o para habilitar a integra��o do Integracao SIGAESS x SIGAFIN
Autor      : Rafael Ramos Capuano
Data/Hora  : 08/03/2013 - 10:22
*/

Function Int101GetCond()
Local lRet := .F.

lRet := EasyGParam('MV_AVG0226',.T.) .And. EasyGParam('MV_AVG0226',,.F.)
//RRC - 22/08/2013 - Adicionados dois par�metros para separar a integra��o do SIGAESS com o SIGAFIN entre Aquisi��o e Venda
If lRet .And. AVFLAGS('CONTROLE_SERVICOS_VENDA') .And. AVFLAGS('CONTROLE_SERVICOS_AQUISICAO')
   If EEQ->EEQ_TPPROC == "A"
      lRet := EasyGParam("MV_ESS0016",,.T.)
   ElseIf EEQ->EEQ_TPPROC == "V"
      lRet := EasyGParam("MV_ESS0017",,.T.)
   ElseIF Empty(EEQ->EEQ_TPPROC)
      lRet := IF(EEQ->EEQ_FASE $ "3/4" .AND. IsIntEnable("001"),.T., )
   EndIf
EndIf

Return lRet

/*
Fun��o     : Int101Parc()
Par�metros : cParc - EEQ_PARC
Retorno    : cRet
Objetivos  : Retornar a parcela para integra��o do SIGAESS x SIGAFIN
Autor      : Rafael Ramos Capuano
Data/Hora  : 07/10/2013 - 16:55
*/
Function Int101Parc(cParc)
Local   cRet  := If(EEQ->EEQ_TPPROC == "A",AvKey("","E2_PARCELA"),AvKey("","E1_PARCELA"))
Default cParc := ""

If !Empty(cParc) //.And. Val(cParc) > 0  // GFP - 22/01/2014
   cRet := RetAsc(EEQ->EEQ_PARC,AVSX3("E2_PARCELA",AV_TAMANHO),.T.)
EndIf
Return cRet

/*
Fun��o     : EGetSeqSE5()
Par�metros : __aInt - Dados do titulo enviado para integra��o com o financeiro
Retorno    : cRet - Sequ�ncia de baixa do SE5 (E5_SEQ)
Objetivos  : Retornar a sequencia de baixa realizada para o t�tulo que foi integrado pelo __aInt
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 14/05/2020
*/
Static Function EGetSeqSE5(__aInt)
Local cRet := ""
Local nPre := aScan(__aInt,{|x| x[1] $ "E1_PREFIXO|E2_PREFIXO"})
Local nNum := aScan(__aInt,{|x| x[1] $ "E1_NUM|E2_NUM"})
Local nPar := aScan(__aInt,{|x| x[1] $ "E1_PARCELA|E2_PARCELA"})
Local nTip := aScan(__aInt,{|x| x[1] $ "E1_TIPO|E2_TIPO"})
Local nCli := aScan(__aInt,{|x| x[1] $ "E1_CLIENTE|E2_FORNECE"})
Local nLoj := aScan(__aInt,{|x| x[1] $ "E1_LOJA|E2_LOJA"})
Local nVal := aScan(__aInt,{|x| x[1] $ "AUTVALREC|AUTVLRME"})
Local nLen
Private aBaixaSE5 := {} //Utilizada pela Fun��o Sel070Baixa

Sel070Baixa("VL /V2 /BA /RA /CP /LJ /" , __aInt[nPre][2] , __aInt[nNum][2] , __aInt[nPar][2], __aInt[nTip][2] , , , __aInt[nCli][2] , __aInt[nLoj][2] ,, , , , , )

If !Empty(aBaixaSE5)
   aSort(aBaixaSE5,,, {|x,y| x[9] < y[9] } ) //Ordena pelo campo E5_SEQ
   nLen := Len(aBaixaSE5)
   If __aInt[nVal][2] == aBaixaSE5[nLen][8]
      cRet := aBaixaSE5[nLen][9] //Posi��o 9 � o E5_SEQ
   EndIf
EndIf

Return cRet
