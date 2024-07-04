#Include 'EICCD100.CH'
#Include 'Protheus.ch'
#Include 'Average.ch'
#INCLUDE "TOTVS.CH"

//Integração
#Define TAXAS		1
#Define NCM		2
#Define EX			3
#Define ANUENCIA	4
#Define LISTA 5

//Parametros de integração Taxas
#Define INT_COMPLETA 1
#Define INT_SIMPLES  2

//Parametros de integração NCM
#Define NCM_ATUAL "A"
#Define NCM_TODAS "T"

/*
Funcao     : EICCD100()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Integração Fiscosoft ComexData X Easy Import Control
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 17/03/2015 :: 12:52
*/
*--------------------*
Function EICCD100()
*--------------------*
Private nTpInt := 0, aLogs := {}, aGravaRet := {}, cLogErro := "", lExibeLog := .F.
Return NIL

/*
Funcao     : CD100CFCONT()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Definição de configurações para Integração TOTVS Comex Conteúdo
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 17/03/2015 :: 15:13
*/
*--------------------*
Function CD100CFCONT()
*--------------------*
Local oUserParams	:= EASYUSERCFG():New("EICCD100")
Local cUserCC := oUserParams:LoadParam("CNPJCC","","EICCD100") + Space(50)
//Local cPassCC := Space(50)
Local cUserCD := oUserParams:LoadParam("USRCD","","EICCD100") + Space(50)
Local cPassCD := Space(50)
Local bOk := {|| lRet := .T., oDlg:End() }
Local bCancel := {|| oDlg:End() }
Local nLin := 5, nCol := 12
Local lRet := .F.
Local oDlg
Local aCNPJ := SetCNPJ(FWGrpCompany(), .T.)

DEFINE MSDIALOG oDlg TITLE STR0001 FROM 320,400 TO 610,750 OF oMainWnd PIXEL  //"Configurações para o usuário: "
   
   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 17/11/2015 - Ajustes Tela P12.
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
   
   // PREFERENCIAS - COMEX CONTENT
   @ nLin, 6 To 110, 172 Label STR0002 Of oPanel Pixel  //"Preferências - Comex Content"
   nLin += 10
   
   @ nLin,nCol Say STR0003 Size 160,08 PIXEL OF oPanel  //"Usuário do sistema:"
   nLin += 10
   @ nLin,nCol MsGet UsrRetName(__cUserID) Size 150,08 WHEN .F. PIXEL OF oPanel
   
   nLin += 20
   @ nLin,nCol Say STR0038 Size 160,08 PIXEL OF oPanel  //"Informe o CNPJ de login:"
   nLin += 10
   @ nLin,nCol COMBOBOX cUserCC ITEMS aCNPJ SIZE 150,08 PIXEL OF oPanel
   nLin += 20

ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

If lRet
   oUserParams:SetParam("CNPJCC" , AllTrim(cUserCC)          ,"EICCD100")

   cUserCC := StrTran(cUserCC,".","")
   cUserCC := "TE"+SubStr(cUserCC,1,At("/",cUserCC)-1)
   oUserParams:SetParam("USRCC" , AllTrim(cUserCC)          ,"EICCD100")
EndIf

Return

/*
Funcao     : CD100CFQA()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Definição de configurações para Integração Comex Data QA
Obs:       : Separação das telas de configuração
Autor      : Marcos Roberto Ramos Cavini Filho - MCF
Data/Hora  : 03/02/2016 :: 15:13
*/
*--------------------*
Function CD100CFQA()
*--------------------*
Local oUserParams	:= EASYUSERCFG():New("EICCD100")
Local cUserCC := oUserParams:LoadParam("CNPJCC","","EICCD100") + Space(50)
//Local cPassCC := Space(50)
Local cUserCD := oUserParams:LoadParam("USRCD","","EICCD100") + Space(50)
Local cPassCD := Space(50)
Local bOk := {|| lRet := .T., oDlg:End() }
Local bCancel := {|| oDlg:End() }
Local nLin := 5, nCol := 12
Local lRet := .F.
Local oDlg
Local aCNPJ := SetCNPJ(FWGrpCompany(), .T.)

If !EasyGParam("MV_EIC0061",,.F.) .Or. !FindFunction("EasyComexDataQA") //MCF - 08/02/2016
   MsgInfo(STR0067,STR0064)
   Return
EndIf

DEFINE MSDIALOG oDlg TITLE STR0001 FROM 320,400 TO 610,750 OF oMainWnd PIXEL  //"Configurações para o usuário: "
   
   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 17/11/2015 - Ajustes Tela P12.
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
   
   // PREFERENCIAS - COMEX DATA QA
   @ nLin, 6 To 110, 172 Label STR0033 Of oPanel Pixel  //"Preferências - Comex Data QA"
   nLin += 10
   
   @ nLin,nCol Say STR0003 Size 160,08 PIXEL OF oPanel  //"Usuário do sistema:"
   nLin += 10 
   @ nLin,nCol MsGet UsrRetName(__cUserID) Size 150,08 WHEN .F. PIXEL OF oPanel
   
   nLin += 20
   @ nLin,nCol Say STR0004 Size 160,08 PIXEL OF oPanel  //"Usuário de acesso ao Comex Data QA:"
   nLin += 10
   @ nLin,nCol MsGet cUserCD Size 150,08 PIXEL OF oPanel

   nLin += 20
   @ nLin,nCol Say STR0005 Size 160,08 PIXEL OF oPanel  //"Senha de acesso ao Comex Data QA:"
   nLin += 10
   @ nLin,nCol MsGet cPassCD Size 150,08 Password VALID NaoVazio(cPassCD) PIXEL OF oPanel

ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

If lRet
   oUserParams:SetParam("USRCD" , AllTrim(cUserCD)        ,"EICCD100")
   oUserParams:SetParam("PSSCD" , ENCRYP(AllTrim(cPassCD)),"EICCD100")
EndIf

Return

/*
Funcao     : CD100IntTx()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Integração de Cotação de Taxas
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/03/2015 :: 08:04
*/
*----------------------------------------------------------*
Function CD100IntTx(cAlias,nReg,nOpc,lSchedule,cEmp,cFil)
*----------------------------------------------------------*
Local oUserParams
Local cDados := ""
Local dDtIni := CTOD(""), dDtFin := CTOD(""), i, j
Local lProcessado := .F.
Default lSchedule := .F.
Private cUsuario, cSenha

Begin Sequence
   
   If lSchedule
      RpcSetType(3)
      RpcSetEnv(cEmp,cFil)
   EndIf

   /* RMD - 16/10/20 - Passa a validar o usuário em uma única função   
   oUserParams	:= EASYUSERCFG():New("EICCD100")
   cUsuario := oUserParams:LoadParam("USRCC","","EICCD100")

   If Empty(cUsuario)
      If !lSchedule
         MsgInfo(STR0006,STR0007)  //"Não foram encontradas as configurações de usuario e senha necessárias para efetuar a integração solicitada." ## "Atenção"
      Else
         Conout(STR0006)   //"Não foram encontradas as configurações de usuario e senha necessárias para efetuar a integração solicitada."
      EndIf
      Break
   EndIf
   */
   If Empty(cUsuario := GetUsuario(lSchedule))
      Break
   EndIf
   
   If !Pergunte("EICCD01",!lSchedule)
      Break
   EndIf

   dDtIni    := If(!Empty(mv_par01) .And. !lSchedule,mv_par01,dDataBase)//RMD - 29/08/19 - Se estiver rodando via schedule força a data da execução
   dDtFin    := If(!Empty(mv_par02) .And. !lSchedule,mv_par02,dDataBase)//RMD - 29/08/19 - Se estiver rodando via schedule força a data da execução
   nTpInt    := If(!Empty(mv_par03),mv_par03,INT_COMPLETA)
   cMoed1    := If(!Empty(mv_par04),Posicione("SYF",1,xFilial("SYF")+AvKey(mv_par04,"YF_MOEDA"),"YF_COD_GI"),"")
   cMoed2    := If(!Empty(mv_par05),Posicione("SYF",1,xFilial("SYF")+AvKey(mv_par05,"YF_MOEDA"),"YF_COD_GI"),"")
   cMoed3    := If(!Empty(mv_par06),Posicione("SYF",1,xFilial("SYF")+AvKey(mv_par06,"YF_MOEDA"),"YF_COD_GI"),"")
   cMoed4    := If(!Empty(mv_par07),Posicione("SYF",1,xFilial("SYF")+AvKey(mv_par07,"YF_MOEDA"),"YF_COD_GI"),"")
   cMoed5    := If(!Empty(mv_par08),Posicione("SYF",1,xFilial("SYF")+AvKey(mv_par08,"YF_MOEDA"),"YF_COD_GI"),"")
   lExibeLog := If(SX1->(dbSeek("EICCD01"+Space(3)+"09")),mv_par09 == 1,.T.) //MCF - 18/02/2016

   aLogs := {}
   aGravaRet := {}
   For i := 1 To 5
      cMoeda := &("cMoed"+cValToChar(i))
      If !Empty(cMoeda)
         cDtIni := StrTran(DTOC(dDtIni),"/","-")
         cDtFin := StrTran(DTOC(dDtFin),"/","-")
         //RMD - 29/08/19 - Se a data estiver configurada com dois dígitos no ano, altera para 4 dígitos pois é o formato esperado pela interface
         If Len(cDtIni) == 8
            cDtIni := Left(cDtIni, 6) + "20" + Right(cDtIni, 2)
         EndIf
         If Len(cDtFin) == 8
            cDtFin := Left(cDtFin, 6) + "20" + Right(cDtFin, 2)
         EndIf
         If !lSchedule
            Processa({|| cDados := ConectaSite(MontaURL(TAXAS,{cMoeda,cDtIni,cDtFin}))} , STR0008, STR0009, .T.) //"Conexão" ## "Iniciando conexão com o site Fiscosoft..."
         Else
            cDados := ConectaSite(MontaURL(TAXAS,{cMoeda,cDtIni,cDtFin}))
         EndIf
         If !Empty(cDados)
            If Alltrim(cDados) $ "Acesso Negado|Senha incorreta|Usuário não cadastrado"
               If !lSchedule
                  MsgInfo(STR0032,STR0007)  //"Usuário sem acesso. Para atualizar automaticamente informações de comércio exterior, procure seu executivo de relacionamento e conheça mais sobre o TOTVS Comex Conteúdo." ## "Atenção"
               Else
                  Conout(STR0032)  //"Usuário sem acesso. Para atualizar automaticamente informações de comércio exterior, procure seu executivo de relacionamento e conheça mais sobre o TOTVS Comex Conteúdo."
               EndIf
               Break
            EndIf
         
            If !lSchedule
               Processa({|| lProcessado := ProcessaRet(TAXAS,cDados,@aGravaRet,lSchedule)} , STR0010, STR0011, .T.) //"Processando" ## "Processando dados..."
            Else
               lProcessado := ProcessaRet(TAXAS,cDados,@aGravaRet,lSchedule)
            EndIf
         EndIf
         If lProcessado
            If !lSchedule
               Processa({|| GravaRet(TAXAS,nTpInt,aGravaRet) },STR0036,STR0037 + STR0043 + STR0046,.T.)//"Gravação" ## "Gravando informações de " ### "Taxas" ### " na Base de Dados..."
            Else
               GravaRet(TAXAS,nTpInt,aGravaRet)
            EndIf
         Else
            If !lSchedule
               MsgInfo(STR0012,STR0007)  //"Ocorreu um erro durante o processamento dos dados." ## "Atenção"
            Else
               Conout(STR0012)  //"Ocorreu um erro durante o processamento dos dados."
            EndIf
         EndIf
      EndIf
   Next i
   If Len(aLogs) # 0
      //If !lSchedule //RMD - 29/08/19 - Grava log mesmo na execução
         GravaLog(TAXAS,,,lSchedule)
      //EndIf
   EndIf
End Sequence
IF(EasyEntryPoint("EICCD100"),Execblock("EICCD100",.F.,.F.,"INTEGRACAO_TAXAS"),)
Return


/*
Funcao     : CD100IntNCM()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Integração de NCM
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/03/2015 :: 08:23
*/
*---------------------------------------------------------*
Function CD100IntNCM(cAlias,nReg,nOpc,lSchedule,cEmp,cFil)
*---------------------------------------------------------*
Local oUserParams

Local cNCMIni := "", cNCMFin := "", cAcao := ""
Local lAddNew := .F.
Local dDtVige := CTOD("")
Local oDlg, oBtNCMAtu, oBtNCMTds
Local lBloqueia := .T.
Default lSchedule := .F.
Private cUsuario, cSenha

Begin Sequence

   If lSchedule
      RpcSetType(3)
      RpcSetEnv(cEmp,cFil)
   EndIf
   
   /* RMD - 16/10/20 - Passa a validar o usuário em uma única função   
   oUserParams	:= EASYUSERCFG():New("EICCD100")
   cUsuario := oUserParams:LoadParam("USRCC","","EICCD100")
   */

   If Empty(cUsuario := GetUsuario(lSchedule))
      Break
   EndIf 
   
   If !lSchedule
      DEFINE MSDIALOG oDlg TITLE STR0013 FROM 0,0 TO 9,30  // "Integração TOTVS Comex Conteúdo"

         @ 8,8 SAY STR0014 PIXEL  //"Quais NCMs deseja atualizar?"

         @ 2.5,4  BUTTON oBtNCMAtu PROMPT STR0015 SIZE 40,13 ACTION (cAcao := NCM_ATUAL, oDlg:End())   //"NCM Atual"
      
         @ 2.5,16 BUTTON oBtNCMTds PROMPT STR0016 SIZE 40,13 ACTION (cAcao := NCM_TODAS, oDlg:End())  //"Várias NCMs"
      
         oBtNCMAtu:cToolTip := STR0017  //"NCM atual, posicionada no browse"
         oBtNCMTds:cToolTip := STR0018  //"Todas as NCMs da base"

      ACTIVATE MSDIALOG oDlg CENTERED
   EndIf
      
   If !lSchedule
      If !Empty(cAcao)
         If cAcao == NCM_ATUAL  
            Pergunte("EICCD02",.F.)
            cNCMIni := AllTrim(SYD->YD_TEC)
            cNCMFin := AllTrim(SYD->YD_TEC)
            lExibeLog := .T.
         ElseIf cAcao == NCM_TODAS
            If !Pergunte("EICCD02",.T.)
               Break
            EndIf
            cNCMIni := AllTrim(mv_par01)
            cNCMFin := AllTrim(mv_par02)
            If !Empty(mv_par05)
               lExibeLog := mv_par05 == 1
            Else
               lExibeLog := .T.
            Endif
            If !Empty(mv_par06) //Pergunta de Bloqueia NCM 1-Sim;2-Não
               lBloqueia := mv_par06 == 1
            EndIf
         EndIf
         dDtVige := mv_par03
         lAddNew := mv_par04 == 1  
      EndIf
   Else
      cAcao := NCM_TODAS
      cNCMIni := "00000000"
      cNCMFin := "99999999"
      dDtVige := CTOD("")
      lAddNew := .T.
      lExibeLog := .F.
   EndIf
   
   If !Empty(cAcao)
      CD100ProcNCM(cAcao,dDtVige,cNCMIni,cNCMFin,lSchedule,lBloqueia) //MCF - 04/02/2016
   EndIf
   
End Sequence

Return

/*
Funcao     : CD100ProcNCM()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Processa Integração de NCM
Autor      : Marcos Roberto Ramos Cavini Filho - MCF
Data/Hora  : 04/02/2016 : 11:40
*/
*---------------------------------------------------------*
Function CD100ProcNCM(cAcao,dDtVige,cNCMIni,cNCMFin,lSchedule,lBloqueia)
*---------------------------------------------------------*
Local cDados := "",cDtVige := "", i, j
Local lProcessado := .F., aRange := {}
Local lFim := .F.
Local lCpoBloq
Local cRetBloq := ""
Local nTotNCMBlq := 0
Private aNCMLog := {}, nContNCM := 0
Private oProgress

If !lSchedule
   oProgress := EasyProgress():New()
EndIf

Begin Sequence

   aLogs := {}
   aGravaRet := {}
   cDtVige := If(!Empty(dDtVige),StrTran(DTOC(dDtVige),"/","-"),"")
   lCpoBloq := SYD->(FieldPos("YD_MSBLQL")) > 0
   If cAcao == NCM_TODAS
      If !lSchedule
         oProgress:SetProcess({|| lProcessado := RangeNCMs(cNCMIni,cNCMFin,cDtVige,NCM,lSchedule)}, STR0071) //MCF - 04/02/2016
         oProgress:Init()
      Else
         lProcessado := RangeNCMs(cNCMIni,cNCMFin,cDtVige,NCM,lSchedule)
      Endif
   ElseIf cAcao == NCM_ATUAL
      If !lSchedule
         Processa({|| cDados := ConectaSite(MontaURL(NCM,{cNCMIni,cNCMFin,cDtVige}))} , STR0008, STR0009, .T.) //"Conexão" ## "Conectando com TOTVS Comex Conteúdo..."
      Else
         cDados := ConectaSite(MontaURL(NCM,{cNCMIni,cNCMFin,cDtVige}))
      EndIf
      If !Empty(cDados)
         If Alltrim(cDados) $ "Acesso Negado|Senha incorreta|Usuário não cadastrado"
            If !lSchedule
               MsgInfo(STR0032,STR0007)  //"Usuário sem acesso. Para atualizar automaticamente informações de comércio exterior, procure seu executivo de relacionamento e conheça mais sobre o TOTVS Comex Conteúdo." ## "Atenção"
            Else
               Conout(STR0032)  //"Usuário sem acesso. Para atualizar automaticamente informações de comércio exterior, procure seu executivo de relacionamento e conheça mais sobre o TOTVS Comex Conteúdo."
            EndIf
            Break
         EndIf

         If !lSchedule
            Processa({|| lProcessado := ProcessaRet(NCM,cDados,@aGravaRet,lSchedule)} , STR0010, STR0011, .T.) //"Processando" ## "Processando dados..."
         Else
            lProcessado := ProcessaRet(NCM,cDados,@aGravaRet,lSchedule)
         EndIf
      EndIf
   EndIf 
   
   If lProcessado 
      If !lSchedule
         Processa({|| GravaRet(NCM,,aGravaRet) },STR0036,STR0037 + STR0044 + STR0046,.T.)//"Gravação" ## "Gravando informações de " ### "N.C.M." ### " na Base de Dados..."
      Else
         GravaRet(NCM,,aGravaRet)
      EndIf
      If lCpoBloq .And. lBloqueia //Existe o campo de bloqueio e a pergunta diz pra bloquear
         nTotNCMBlq := BloqNCM(cNCMIni,cNCMFin,DToS(dDataBase),@cRetBloq)
      EndIf
   Else
      If !lSchedule
         MsgInfo(STR0012 + ENTER + STR0030,STR0007)  //"Ocorreu um erro durante o processamento dos dados." ## "Verifique se os parâmetros passados são válidos para a busca solicitada." ## "Atenção"
      Else
         Conout(STR0012 + ENTER + STR0030)  //"Ocorreu um erro durante o processamento dos dados."
      EndIf
   EndIf
   If Len(aLogs) # 0
      If !lSchedule
         GravaLog(NCM,cNCMIni,cNCMFin,lSchedule) //MCF - 04/02/2016
      EndIf
   EndIf
   If !lProcessado
      BREAK
   Endif
   If !lSchedule
      //Processa({|| CD100IntEx(,,,,,,If(!lSchedule,cAcao,)) },STR0041,STR0042,.T.)  //"Atualização Ex-NCM" ## ""Atualizando Ex-NCM..."
      CD100IntEx(,,,,,,If(!lSchedule,cAcao,),nTotNCMBlq,cRetBloq) //MCF - 15/03/2016
   Else
      CD100IntEx(,,,lSchedule,,,If(!lSchedule,cAcao,),nTotNCMBlq,cRetBloq)
   EndIf

End Sequence
IF(EasyEntryPoint("EICCD100"),Execblock("EICCD100",.F.,.F.,"INTEGRACAO_NCM"),)
Return

/*
Funcao     : CD100IntEx()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Integração de Ex-NCM
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/03/2015 :: 08:23
*/
*--------------------------------------------------------------*
Function CD100IntEx(cAlias,nReg,nOpc,lSchedule,cEmp,cFil,cAcao,nTotNCMBlq,cRetBloq)
*--------------------------------------------------------------*
Local oUserParams
Local cNCMIni := "", cNCMFin := ""
Local lAddNew := .F.
Local dDtVige := CTOD("")
Default lSchedule := .F.
Default cAcao := NCM_TODAS
Private cUsuario, cSenha

Begin Sequence
   If lSchedule
      RpcSetType(3)
      RpcSetEnv(cEmp,cFil)
   EndIf
   
   /* RMD - 16/10/20 - Passa a validar o usuário em uma única função   
   oUserParams	:= EASYUSERCFG():New("EICCD100")
   cUsuario := oUserParams:LoadParam("USRCC","","EICCD100")
   */
   If Empty(cUsuario := GetUsuario(lSchedule))
      Break
   EndIf

   If !lSchedule
      Pergunte("EICCD02",.F.)
      If cAcao == NCM_ATUAL  
         cNCMIni := AllTrim(SYD->YD_TEC)
         cNCMFin := AllTrim(SYD->YD_TEC) 
      ElseIf cAcao == NCM_TODAS        
         cNCMIni := AllTrim(mv_par01)
         cNCMFin := AllTrim(mv_par02)
      EndIf
      dDtVige := mv_par03
      lAddNew := mv_par04 == 1
   Else
      cAcao := NCM_TODAS
      cNCMIni := "00000000"
      cNCMFin := "99999999"
      dDtVige := CTOD("")
      lAddNew := .T.
      lExibeLog := .F.
   EndIf
   
   CD100ProcExNCM(cAcao,dDtVige,cNCMIni,cNCMFin,lSchedule,nTotNCMBlq,cRetBloq) //MCF - 04/02/2016
    
End Sequence

Return

/*
Funcao     : CD100ProcExNCM()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Processa Integração de Ex-NCM
Autor      : Marcos Roberto Ramos Cavini Filho - MCF
Data/Hora  : 04/02/2016 : 11:40
*/
*--------------------------------------------------------------*
Function CD100ProcExNCM(cAcao,dDtVige,cNCMIni,cNCMFin,lSchedule,nTotNCMBlq,cRetBloq)
*--------------------------------------------------------------*
Local cDados := "", cDtVige := "",i, j
Local lProcessado := .F., aRange := {}

Begin Sequence
   
   aLogs := {}
   aGravaRet := {}
   cDtVige := If(!Empty(dDtVige),StrTran(DTOC(dDtVige),"/","-"),"")
   
   If cAcao == NCM_TODAS
      If !lSchedule
         oProgress:SetProcess({|| lProcessado := RangeNCMs(cNCMIni,cNCMFin,cDtVige,EX,lSchedule)} ,STR0042) //MCF - 04/02/2016
         oProgress:Init()
      Else
         lProcessado := RangeNCMs(cNCMIni,cNCMFin,cDtVige,EX,lSchedule)
      EndIf
   ElseIf cAcao == NCM_ATUAL
      If !lSchedule
         Processa({|| cDados := ConectaSite(MontaURL(EX,{cNCMIni,cNCMFin,cDtVige}))} , STR0008, STR0009, .T.) //"Conexão" ## "Iniciando conexão com o site Fiscosoft..."
      Else
         cDados := ConectaSite(MontaURL(EX,{cNCMIni,cNCMFin,cDtVige}))
      EndIf
      If !Empty(cDados)
         If Alltrim(cDados) $ "Acesso Negado|Senha incorreta|Usuário não cadastrado"
            If !lSchedule
               MsgInfo(STR0032,STR0007)  //"Usuário sem acesso. Para atualizar automaticamente informações de comércio exterior, procure seu executivo de relacionamento e conheça mais sobre o TOTVS Comex Conteúdo." ## "Atenção"
            Else
               Conout(STR0032)  //"Usuário sem acesso. Para atualizar automaticamente informações de comércio exterior, procure seu executivo de relacionamento e conheça mais sobre o TOTVS Comex Conteúdo."
            EndIf
            Break
         EndIf

         If !lSchedule
            Processa({|| lProcessado := ProcessaRet(EX,cDados,@aGravaRet,lSchedule)} , STR0010, STR0011, .T.) //"Processando" ## "Processando dados..."
         Else
            lProcessado := ProcessaRet(EX,cDados,@aGravaRet,lSchedule)
         EndIf
      Else
         lProcessado := .T. //MCF - 19/02/2016
      EndIf
   EndIf 

   If lProcessado
      If !lSchedule
         Processa({|| GravaRet(EX,,aGravaRet) },STR0036,STR0037 + STR0045 + STR0046,.T.)//"Gravação" ## "Gravando informações de " ### "Ex-N.C.M." ### " na Base de Dados..."
      Else
         GravaRet(EX,,aGravaRet)
      EndIf
   Else
      If !lSchedule
         MsgInfo(STR0012 + ENTER + STR0030,STR0007)  //"Ocorreu um erro durante o processamento dos dados." ## "Verifique se os parâmetros passados são válidos para a busca solicitada." ## "Atenção"
      Else
         Conout(STR0012 + ENTER + STR0030)  //"Ocorreu um erro durante o processamento dos dados."
      EndIf
   EndIf
   If Len(aLogs) # 0 .Or. lProcessado
      If !lSchedule
         GravaLog(EX,cNCMIni,cNCMFin,lSchedule,nTotNCMBlq,cRetBloq)
      EndIf
   EndIf

End Sequence
IF(EasyEntryPoint("EICCD100"),Execblock("EICCD100",.F.,.F.,"INTEGRACAO_EX"),)
Return

/*
Funcao     : CD100IntOrg()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Integração de Orgãos Anuentes
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 30/06/2015 :: 15:44
*/
*---------------------------------------------------------*
Function CD100IntOrg(cAlias,nReg,nOpc,lSchedule,cEmp,cFil)
*---------------------------------------------------------*
Local oUserParams
Local cDados := "", i, j
Local lProcessado := .F., aRange := {}
Local cNCMIni := "", cNCMFin := "", cAcao := "", cDtVige := ""
Local lAddNew := .F.
Local dDtVige := CTOD("")
Local oDlg, oBtNCMAtu, oBtNCMTds
Default lSchedule := .F.
Private cUsuario, cSenha

Begin Sequence
   
   If lSchedule
      RpcSetType(3)
      RpcSetEnv(cEmp,cFil)
   EndIf
   
   /* RMD - 16/10/20 - Passa a validar o usuário em uma única função   
   oUserParams	:= EASYUSERCFG():New("EICCD100")
   cUsuario := oUserParams:LoadParam("USRCC","","EICCD100")
   */
   If Empty(cUsuario := GetUsuario(lSchedule))
      Break
   EndIf
   
   aLogs := {}
   aGravaRet := {}
   
   If !lSchedule
      Processa({|| cDados := ConectaSite(MontaURL(ANUENCIA,{AllTrim(SYD->YD_TEC),}))} , STR0008, STR0009, .T.) //"Conexão" ## "Iniciando conexão com o site Fiscosoft..."
   Else
      cDados := ConectaSite(MontaURL(ANUENCIA,{AllTrim(SYD->YD_TEC)}))
   EndIf
   If !Empty(cDados)
      If Alltrim(cDados) $ "Acesso Negado|Senha incorreta|Usuário não cadastrado"
         If !lSchedule
            MsgInfo(STR0032,STR0007)  //"Usuário sem acesso. Para atualizar automaticamente informações de comércio exterior, procure seu executivo de relacionamento e conheça mais sobre o TOTVS Comex Conteúdo." ## "Atenção"
         Else
            Conout(STR0032)  //"Usuário sem acesso. Para atualizar automaticamente informações de comércio exterior, procure seu executivo de relacionamento e conheça mais sobre o TOTVS Comex Conteúdo."
         EndIf
         Break
      EndIf

      If !lSchedule
         Processa({|| lProcessado := ProcessaRet(ANUENCIA,cDados,@aGravaRet,lSchedule)} , STR0010, STR0011, .T.) //"Processando" ## "Processando dados..."
      Else
         lProcessado := ProcessaRet(ANUENCIA,cDados,@aGravaRet,lSchedule)
      EndIf
   EndIf
   If lProcessado
      If !lSchedule
         Processa({|| GravaRet(ANUENCIA,,aGravaRet) },STR0036,STR0037 + STR0055 + STR0046,.T.)//"Gravação" ## "Gravando informações de " ### "Órgãos Anuentes" ### " na Base de Dados..."
      Else
         GravaRet(ANUENCIA,,aGravaRet)
      EndIf
   Else
      If !lSchedule
         MsgInfo(STR0012 + ENTER + STR0030,STR0007)  //"Ocorreu um erro durante o processamento dos dados." ## "Verifique se os parâmetros passados são válidos para a busca solicitada." ## "Atenção"
      Else
         Conout(STR0012 + ENTER + STR0030)  //"Ocorreu um erro durante o processamento dos dados."
      EndIf
   EndIf
   If Len(aLogs) # 0
      If !lSchedule
         GravaLog(ANUENCIA,,,lSchedule)
      EndIf
   EndIf

End Sequence
IF(EasyEntryPoint("EICCD100"),Execblock("EICCD100",.F.,.F.,"INTEGRACAO_ORGAO"),)
Return

/*
Funcao     : MontaURL()
Parametros : Tipo Integração / Dados de filtro
Retorno    : URL gerada
Objetivos  : URL para acesso ao site da Fiscosoft
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/03/2015 :: 11:01
*/
*---------------------------------------*
Static Function MontaURL(nInt,aInfos)
*---------------------------------------*
Local cURL := ""
If nInt == TAXAS
   cURL := "http://www.comexdata.com.br/softway/integracao_moeda.php?moeda=" + aInfos[1] + "&vigencia_de=" + aInfos[2] + "&vigencia_ate=" + aInfos[3] + "&psw=" + GetLoginHash()
ElseIf nInt == NCM
   cURL := "http://www.comexdata.com.br/softway/integracao_aliquota.php?ncm_de=" + aInfos[1] + "&ncm_ate=" + aInfos[2] + "&vigencia_de=" + aInfos[3] + "&psw=" + GetLoginHash()
ElseIf nInt == EX
   cURL := "http://www.comexdata.com.br/softway/integracao_ex.php?ncm_de=" + aInfos[1] + "&ncm_ate=" + aInfos[2] + "&vigencia_de=" + aInfos[3] + "&psw="+ GetLoginHash()
ElseIf nInt == ANUENCIA
   cURL := "http://www.comexdata.com.br/softway/integracao_siscomex.php?ncm=" + aInfos[1] + "&psw="+ GetLoginHash()
ElseIf nInt == LISTA
   cURL := "http://www.comexdata.com.br/softway/integracao_ncm_validas.php?psw="+ GetLoginHash()
EndIf

Return cURL

*------------------------------*
Static Function GetLoginHash()
*------------------------------*
Return AllTrim(ValidaUsuario()) + "." + Md5(Md5(AllTrim(ValidaUsuario()) + CHAVE_FISCOSOFT + DToS(Date()))) 

/*
Funcao     : ConectaSite()
Parametros : Nenhum
Retorno    : URL gerada
Objetivos  : URL para acesso ao site da Fiscosoft
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/03/2015 :: 12:04
*/
*------------------------------*
Static Function ConectaSite(cURL)
*------------------------------*
Local nTimeOut := 200
Local aHeadOut := {}
Local cHeadRet := ""
Return HttpPost(cURL,"","",nTimeOut,aHeadOut,@cHeadRet)

/*
Funcao     : ProcessaRet()
Parametros : cDados - Dados retornados do site
Retorno    : .T./.F.
Objetivos  : Processamento de Retorno
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/03/2015 :: 13:56
*/
*-----------------------------------------------------------------*
Static Function ProcessaRet(nInt,cDados,aGravaRet,lSchedule,lBlind)
*-----------------------------------------------------------------*
Local lRet := .F., i, j, cDescP := "", cEx := ""
Local aGrava := {}, aDados := {}
Local cFilialSYD := xFilial("SYD")
Local cFilialEVJ := xFilial("EVJ")
Local cFilialSYE := xFilial("SYE")
Local cFilialEVL := xFilial("EVL")
Default lBlind := .F.
Begin Sequence

  If Empty(cDados)
      lRet := .T.
      Break
   EndIf
   aDados := StrTokArr(cDados,ENTER) 
    
   lRet := If(Len(aDados) # 0,.T.,.F.)
   If Len(aDados) == 1
      If !lSchedule .AND. !lBlind
         MsgInfo(STR0031 + ENTER + STR0030,STR0007)  // "A busca solicitada não retornou dados para atualização" ## "Verifique se os parâmetros passados são válidos para a busca solicitada." ##  "Atenção"
      Else
         Conout(STR0031 + ENTER + STR0030)  // "A busca solicitada não retornou dados para atualização"
      EndIf
      Break
   EndIf
   
   For i := 2 To Len(aDados)
      For j := 1 To 5  // Necessário preencher tags vazias, para manter posição informada abaixo.
         aDados[i] := StrTran(aDados[i],";;",";'';")
      Next j
      aDadoRet := StrTokArr(aDados[i],";")
      
      If nInt == TAXAS
         /*
         aDadoRet[1] - Codigo Moeda Siscomex
         aDadoRet[2] - Descrição Moeda
         aDadoRet[3] - Taxa PTAX
         aDadoRet[4] - Data PTAX
         aDadoRet[5] - Data Fiscal
         */
         aGrava := {}
         If Len(aDadoRet) # 0 
            aAdd(aGrava,{"YE_FILIAL" , cFilialSYE                                               , NIL})
            aAdd(aGrava,{"YE_DATA"   , STOD(aDadoRet[5])                                        , NIL})
            aAdd(aGrava,{"YE_MOEDA"  , Posicione("SYF",3,cFilialSYE+aDadoRet[1],"YF_MOEDA") , NIL})
            aAdd(aGrava,{"YE_VLFISCA", Val(aDadoRet[3])                                         , NIL})
            aAdd(aGravaRet,aGrava)
         EndIf
      ElseIf nInt == NCM
         Do While .T.
            If Len(aDadoRet) < 18
               aAdd(aDadoRet,"''")
            Else
               Exit
            EndIf
         EndDo
         For j := 1 To Len(aDadoRet)
            aDadoRet[j] := If(aDadoRet[j] == "''","",aDadoRet[j])
         Next j
         /*
         aDadoRet[1]  - Código NCM
         aDadoRet[2]  - Descrição NCM
         aDadoRet[3]  - Unidade de Medida
         aDadoRet[4]  - Alíquota II
         aDadoRet[5]  - Data Inicial Vigencia II
         aDadoRet[6]  - Data Final Vigencia II
         aDadoRet[7]  - Alíquota II Mercosul
         aDadoRet[8]  - Data Inicial Vigencia II Mercosul
         aDadoRet[9]  - Data Final Vigencia II Mercosul
         aDadoRet[10] - Alíquota IPI
         aDadoRet[11] - Data Inicial Vigencia IPI
         aDadoRet[12] - Data Final Vigencia IPI
         aDadoRet[13] - Alíquota PIS AdValorem
         aDadoRet[14] - Data Inicial Vigencia PIS
         aDadoRet[15] - Data Final Vigencia PIS
         aDadoRet[16] - Alíquota COFINS AdValorem
         aDadoRet[17] - Data Inicial Vigencia COFINS
         aDadoRet[18] - Data Final Vigencia COFINS
         */
         aGrava := {}
         If Len(aDadoRet) # 0
            aAdd(aGrava,{"YD_FILIAL" , cFilialSYD                          , NIL})
            aAdd(aGrava,{"YD_TEC"    , aDadoRet[1]                         , NIL})
            cDescP := StrTran(aDadoRet[2],"-- ","")
            cDescP := StrTran(cDescP     ,"- ","")
            aAdd(aGrava,{"YD_DESC_P" , cDescP                              , NIL})
            aAdd(aGrava,{"YD_UNID"   , DeParaUnid(aDadoRet[3])             , NIL})
            aAdd(aGrava,{"YD_PER_II" , Val(StrTran(aDadoRet[4],",","."))   , NIL})
            aAdd(aGrava,{"YD_PER_IPI", Val(StrTran(aDadoRet[10],",","."))  , NIL})
            aAdd(aGrava,{"YD_PER_PIS", Val(StrTran(aDadoRet[13],",","."))  , NIL})
            /*
            If SetMajoracao(Val(StrTran(aDadoRet[16],",",".")))  // GFP - 24/06/2015
               aAdd(aGrava,{"YD_PER_COF", Val(StrTran(aDadoRet[16],",","."))-1, NIL})
               aAdd(aGrava,{"YD_MAJ_COF", 1                                , NIL})
            Else
               aAdd(aGrava,{"YD_PER_COF", Val(StrTran(aDadoRet[16],",",".")), NIL})
               aAdd(aGrava,{"YD_MAJ_COF", 0                                , NIL})
            EndIf*/
            //THTS - 27/05/2020 - O arquivo ja contém o valor da majoração, não sendo necessário o IF acima
            aAdd(aGrava,{"YD_PER_COF", Val(StrTran(aDadoRet[16],",",".")) - Val(StrTran(aDadoRet[19],",",".")), NIL})
            aAdd(aGrava,{"YD_MAJ_COF", Val(StrTran(aDadoRet[19],",",".")), NIL})
            aAdd(aGrava,{"YD_DTINTE" , dDataBase                           , NIL})
            aAdd(aGravaRet,aGrava)
         EndIf
      
      ElseIf nInt == EX
         Do While .T.
            If Len(aDadoRet) < 8
               aAdd(aDadoRet,"''")
            Else
               Exit
            EndIf
         EndDo
         For j := 1 To Len(aDadoRet)
            aDadoRet[j] := If(aDadoRet[j] == "''","",aDadoRet[j])
         Next j
         /*
         aDadoRet[1] - Codigo NCM
         aDadoRet[2] - Numero EX
         aDadoRet[3] - Descrição
         aDadoRet[4] - Alíquota
         aDadoRet[5] - Codigo do assunto
         aDadoRet[6] - Data inicio de vigencia
         aDadoRet[7] - Data final de vigencia
         aDadoRet[8] - Observações
         */
         aGrava := {}
         cEx := StrTran(aDadoRet[2],"Ex","")
         If Len(aDadoRet) # 0
            aAdd(aGrava,{"EVJ_FILIAL" , cFilialEVJ                                               , NIL})
            aAdd(aGrava,{"EVJ_TEC"    , aDadoRet[1]                                              , NIL})
            aAdd(aGrava,{"EVJ_EX"     , AllTrim(cEx)                                             , NIL})
            aAdd(aGrava,{"EVJ_DESC"   , aDadoRet[3]                                              , NIL})
            aAdd(aGrava,{"EVJ_ALIQ"   , aDadoRet[4]                                              , NIL})
            aAdd(aGrava,{"EVJ_ASSUNT" , aDadoRet[5]                                              , NIL})
            aAdd(aGrava,{"EVJ_DTINI"  , STOD(aDadoRet[6])                                        , NIL})
            aAdd(aGrava,{"EVJ_DTFIN"  , STOD(aDadoRet[7])                                        , NIL})
            aAdd(aGrava,{"EVJ_OBS"    , aDadoRet[8]                                              , NIL})
            aAdd(aGravaRet,aGrava)
         EndIf 

      ElseIf nInt == ANUENCIA
         Do While .T.
            If Len(aDadoRet) < 22
               aAdd(aDadoRet,"''")
            Else
               Exit
            EndIf
         EndDo
         For j := 1 To Len(aDadoRet)
            aDadoRet[j] := If(aDadoRet[j] == "''","",aDadoRet[j])
         Next j
         /*If (nPos := aScan(aDadoRet, {|x| "DESTAQUE DE MERCADORIA" $ x})
            aDel(aDadoRet,nPos)
            aSize(aDadoRet,Len(aDadoRet)-1)
         EndIf*/
         /*
         aDadoRet[1]	 - 	NCM
         aDadoRet[2]	 - 	Orgao Anuente
         aDadoRet[3]	 - 	Indicadores
         aDadoRet[4]	 - 	Tratamento
         aDadoRet[5]	 - 	Ex-NCM
         aDadoRet[6]	 - 	Descricao EX
         aDadoRet[7]	 - 	Data Inicio Vigencia
         aDadoRet[8]	 - 	Data Final Vigencia
         aDadoRet[9]	 - 	Abrangencia
         aDadoRet[10] - 	Fundamento Legal
         aDadoRet[11] - 	Descricao Mercadoria
         aDadoRet[12] - 	Pais
         aDadoRet[13] - 	Funcao
         aDadoRet[14] - 	Regime
         aDadoRet[15] - 	Codigo Regime
         aDadoRet[16] - 	Regime Tributacao
         aDadoRet[17] - 	Codigo Regime Tributacao
         aDadoRet[18] - 	Texto
         aDadoRet[19] - 	Autorizado?
         */
         aGrava := {}
         If Len(aDadoRet) # 0
            aAdd(aGrava,{"EVL_FILIAL" , cFilialEVL                         , NIL})
            aAdd(aGrava,{"EVL_TEC"    , aDadoRet[1]                        , NIL})
            aAdd(aGrava,{"EVL_ORGAO"  , aDadoRet[2]                        , NIL})
            aAdd(aGrava,{"EVL_INDIC"  , aDadoRet[3]                        , NIL})
            aAdd(aGrava,{"EVL_TRATA"  , aDadoRet[4]                        , NIL})
            aAdd(aGrava,{"EVL_EX"     , aDadoRet[5]                        , NIL})
            aAdd(aGrava,{"EVL_DESCEX" , aDadoRet[6]                        , NIL})
            aAdd(aGrava,{"EVL_DTINI"  , StoD(aDadoRet[7])                  , NIL})
            aAdd(aGrava,{"EVL_DTFIN"  , StoD(aDadoRet[8])                  , NIL})
            aAdd(aGrava,{"EVL_ABRAN"  , aDadoRet[9]                        , NIL})
            aAdd(aGrava,{"EVL_FUNLEG" , aDadoRet[10]                       , NIL})
            aAdd(aGrava,{"EVL_DESCME" , aDadoRet[11]                       , NIL})
            aAdd(aGrava,{"EVL_PAIS"   , aDadoRet[12]                       , NIL})
            aAdd(aGrava,{"EVL_FUNCAO" , aDadoRet[13]                       , NIL})
            aAdd(aGrava,{"EVL_REGIME" , aDadoRet[14]                       , NIL})
            aAdd(aGrava,{"EVL_CODREG" , aDadoRet[15]                       , NIL})
            aAdd(aGrava,{"EVL_REGTRI" , aDadoRet[16]                       , NIL})
            aAdd(aGrava,{"EVL_CORETR" , aDadoRet[17]                       , NIL})
            aAdd(aGrava,{"EVL_TEXTO"  , aDadoRet[18]                       , NIL})
            aAdd(aGrava,{"EVL_LI"     , DeParaAnu(aDadoRet[19])            , NIL})

            aAdd(aGravaRet,aGrava)
         EndIf
      EndIf
      lRet := .T.
   Next i

End Sequence
IF(EasyEntryPoint("EICCD100"),Execblock("EICCD100",.F.,.F.,"PROCESSA_RET"),)
Return lRet

/*
Funcao     : GravaRet()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Gravação de dados na base
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/03/2015 :: 13:58
*/
*-------------------------------------------*
Static Function GravaRet(nInt,nTpInt,aGravaRet)
*-------------------------------------------*
Local lExiste := .F., i, j
Local aLog := {}
Local lExtCpoBlq := SYD->(FieldPos("YD_MSBLQL")) > 0
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

Begin Sequence

   ProcRegua(Len(aGravaRet))
   For i := 1 To Len(aGravaRet)
      If nInt == TAXAS
         IncProc(STR0037 + STR0043 + STR0046)  //"Gravando informações de " ### "Taxas" ### " na Base de Dados..."
         cLogErro := ""
         If nTpInt == INT_COMPLETA
            SYE->(DbSetOrder(1))  //YE_FILIAL+DTOS(YE_DATA)+YE_MOEDA
            nOpc := If(!SYE->(DbSeek(aGravaRet[i][1][2]+DTOS(aGravaRet[i][aScan(aGravaRet[i],{|x| x[1] == "YE_DATA"})][2])+AvKey(aGravaRet[i][aScan(aGravaRet[i],{|x| x[1] == "YE_MOEDA"})][2],"YE_MOEDA"))),3,4)        
            lMsErroAuto := .F.
            lAutoErrNoFile := .T.
            MsExecAuto({|x,y,z| EICA140(x, y, z) },aGravaRet[i], Nil, nOpc)
            If lMsErroAuto
               aErros := GetAutoGRLog()
               For j:= 1 To Len(aErros)
                  cLogErro += aErros[j]+ENTER
               Next j
            EndIf
         ElseIf nTpInt == INT_SIMPLES
            SYE->(DbSetOrder(1))  //YE_FILIAL+DTOS(YE_DATA)+YE_MOEDA
            lExiste := SYE->(DbSeek(aGravaRet[i][1][2]+AvKey(aGravaRet[i][aScan(aGravaRet[i],{|x| x[1] == "YE_DATA"})][2],"YE_DATA")+AvKey(aGravaRet[i][aScan(aGravaRet[i],{|x| x[1] == "YE_MOEDA"})][2],"YE_MOEDA")))  
            If RecLock("SYE",!lExiste)
               For j := 1 To Len(aGravaRet[i])
                 SYE->&(aGravaRet[i][j][1]) := aGravaRet[i][j][2]
               Next j
               SYE->(MsUnlock())
            EndIf
         EndIf
         If aScan(aLogs,{|x| x[1] == SYE->YE_MOEDA .AND. x[2] == DTOC(SYE->YE_DATA)}) == 0
            aLog := {}
            aAdd(aLog,SYE->YE_MOEDA)
            aAdd(aLog,DTOC(SYE->YE_DATA))
            aAdd(aLog,STRTran(cValToChar(SYE->YE_VLFISCA),".",","))
            aAdd(aLog,cLogErro)
            aAdd(aLogs,aLog)
         EndIf
      ElseIf nInt == NCM

         IncProc(STR0037 + STR0044 + STR0046)  //"Gravando informações de " ### "N.C.M." ### " na Base de Dados..."
         SYD->(DbSetOrder(1))  //YD_FILIAL+YD_TEC+YD_EX_NCM+YD_EX_NBM
         lExiste := SYD->(DbSeek(aGravaRet[i][1][2]+AvKey(aGravaRet[i][2][2],"YD_TEC")))
         aGravaRet[i][3][2] := If(lExiste,SYD->YD_DESC_P,aGravaRet[i][3][2])
         If RecLock("SYD",!lExiste)
            For j := 1 To Len(aGravaRet[i])
              SYD->&(aGravaRet[i][j][1]) := aGravaRet[i][j][2]
            Next j
            If lExtCpoBlq
               SYD->YD_MSBLQL := "2" //Nao Bloqueado
            EndIf
            SYD->(MsUnlock())
         EndIf
         If aScan(aLogs,{|x| x[1] == SYD->YD_TEC}) == 0
            aLog := {}
            aAdd(aLog,SYD->YD_TEC)
            aAdd(aLog,Upper(AllTrim(SYD->YD_DESC_P)))
            aAdd(aLog,AllTrim(SYD->YD_UNID))
            aAdd(aLog,STRTran(cValToChar(SYD->YD_PER_II),".",","))
            aAdd(aLog,STRTran(cValToChar(SYD->YD_PER_IPI),".",","))
            aAdd(aLog,STRTran(cValToChar(SYD->YD_PER_PIS),".",","))
            aAdd(aLog,STRTran(cValToChar(SYD->YD_PER_COF),".",","))
            If !Empty(SYD->YD_MAJ_COF)  // GFP - 11/05/2015
               aAdd(aLog,STRTran(cValToChar(SYD->YD_MAJ_COF),".",","))
            EndIf
            aAdd(aLogs,aLog)
         EndIf
      ElseIf nInt == EX
         IncProc(STR0037 + STR0045 + STR0046)  //"Gravando informações de " ### "Ex-N.C.M." ### " na Base de Dados..."
         EVJ->(DbSetOrder(1))  //EVJ_FILIAL+EVJ_TEC+EVJ_EX
         lExiste := EVJ->(DbSeek(aGravaRet[i][1][2]+AvKey(aGravaRet[i][2][2],"EVJ_TEC")+AvKey(aGravaRet[i][3][2],"EVJ_EX")+AvKey(aGravaRet[i][6][2],"EVJ_ASSUNT")+AvKey(aGravaRet[i][5][2],"EVJ_ALIQ")))
         If RecLock("EVJ",!lExiste)
            For j := 1 To Len(aGravaRet[i])
              EVJ->&(aGravaRet[i][j][1]) := aGravaRet[i][j][2]
            Next j
            EVJ->(MsUnlock())
         EndIf
         If aScan(aLogs,{|x| x[1] == EVJ->EVJ_TEC .AND. x[2] == EVJ->EVJ_EX}) == 0
            aLog := {}
            aAdd(aLog,EVJ->EVJ_TEC)
            aAdd(aLog,EVJ->EVJ_EX)
            aAdd(aLog,AllTrim(EVJ->EVJ_DESC))
            aAdd(aLogs,aLog)
         EndIf           
      ElseIf nInt == ANUENCIA
         IncProc(STR0037 + STR0055 + STR0046)  //"Gravando informações de " ### "Órgãos Anuentes" ### " na Base de Dados..."
         EVL->(DbSetOrder(1))  //EVL_FILIAL+EVL_TEC+EVL_EX+EVL_ORGAO
         lExiste := EVL->(DbSeek(aGravaRet[i][1][2]+AvKey(aGravaRet[i][2][2],"EVL_TEC")+AvKey(aGravaRet[i][6][2],"EVL_EX")+AvKey(aGravaRet[i][3][2],"EVL_ORGAO")))
         If RecLock("EVL",!lExiste)
            For j := 1 To Len(aGravaRet[i])
              EVL->&(aGravaRet[i][j][1]) := aGravaRet[i][j][2]
            Next j
            EVL->(MsUnlock())
         EndIf
         //If aScan(aLogs,{|x| x[1] == EVL->EVL_TEC}) == 0
            aLog := {}
            aAdd(aLog, EVL->EVL_TEC)
            aAdd(aLog, AllTrim(EVL->EVL_ORGAO)) 
            aAdd(aLog, AllTrim(EVL->EVL_INDIC)) 
            aAdd(aLog, AllTrim(EVL->EVL_TRATA))
            aAdd(aLog, AllTrim(EVL->EVL_EX)) 
            aAdd(aLog, AllTrim(EVL->EVL_DESCEX))
            aAdd(aLog, AllTrim(EVL->EVL_PAIS))  
            aAdd(aLog, AllTrim(If(EVL->EVL_LI == "1",STR0053,STR0054))) //"Sim" ## "Não"
            aAdd(aLogs,aLog)
         EndIf
      //EndIf
   Next i
   aGravaRet := {}

End Sequence
IF(EasyEntryPoint("EICCD100"),Execblock("EICCD100",.F.,.F.,"GRAVA_RET"),)
Return NIL

/*
Funcao     : GravaLog()
Parametros : Tipo de Mensagem
Retorno    : Nenhum
Objetivos  : Gravação de log
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/03/2015 :: 16:50
*/
*------------------------------*
Static Function GravaLog(nTipo,cNCMIni,cNCMFin,lSchedule,nTotNCMBlq,cRetBloq)
*------------------------------*
Local cMsg := "", i, j
Local cDir := cDirStart:=/*GetSrvProfString("ROOTPATH","")+*/"\comex\totvscomexconteudo\", hFile //MCF - 03/02/2016
Local cFile := "Log_ComexContent_"+If(nTipo == TAXAS,"TAXAS",If(nTipo == NCM,"NCM",If(nTipo == EX,"EX","ORGAO_ANUENTE")))+"_"+DTOS(dDataBase)+".txt"
Local cTempPath	:= If(!lSchedule, AllTrim(GetTempPath()+"\totvscomexconteudo\"), "")/*RMD - 29/08/19 - No schedule não é possível acessar o TempPath*/, cTituloMsg := "" //MCF - 03/02/2016
Local nCont := 0, nContEX :=0 //MCF - 03/02/2016
Local cMsgInfo
Default cNCMIni := "", cNCMFin := ""
Default nTotNCMBlq := 0

If !ExistDir(cDir) //MCF - 03/02/2016
   If MakeDir(cDir) <> 0
      If !lSchedule//RMD - 29/08/19
         MsgInfo(STR0066,STR0007) //"O sistema não pode criar os diretórios necessários para a integração." ## "Atenção"
      EndIf
      Break
   EndIf
EndIf

If !lSchedule .And. !ExistDir(cTempPath) //MCF - 03/02/2016 //RMD - 29/08/19
   If MakeDir(cTempPath) <> 0
      MsgInfo(STR0066,STR0007) //"O sistema não pode criar os diretórios necessários para a integração." ## "Atenção"
      Break
   EndIf
EndIf

If File(cDir+cFile)
   fErase(cDir+cFile)
EndIf

hFile := EasyCreateFile(cDir+cFile)

//MCF - 04/02/2016
cMsg := STR0021 + DToC(Date()) + ENTER //"Data: "
cMsg += STR0060 + Time() + ENTER //"Horário: "
cMsg += STR0062 + UsrRetName(__cUserID) + ENTER + ENTER //"Usuário: "

If !Empty(cNCMIni)
   cMsg +=  STR0061 + ENTER //"Filtro Selecionado: "
   cMsg +=  STR0058 + cNCMIni +ENTER //"NCM Inicial: "
   cMsg +=  STR0059 + cNCMFin + ENTER + ENTER //"NCM Final: "
Endif

cMsg += "===================================================="  + ENTER
cMsg += STR0019                                                 + ENTER  //"Os registros abaixo foram atualizados com sucesso:"  
cMsg += "===================================================="  + ENTER
fWrite(hFile,cMsg)

For i := 1 To Len(aLogs)   
   cMsg := ""
   cTituloMsg := ""
   If nTipo == TAXAS
      cMsg += STR0020 + aLogs[i][1]                             + ENTER  //"Moeda: "
      cMsg += STR0021 + aLogs[i][2]                             + ENTER  //"Data: "
      cMsg += STR0022 + aLogs[i][3]                             + ENTER  //"Taxa: "
      If !empty(aLogs[i][4])
         cMsg += STR0047 + aLogs[i][4]                          + ENTER  //"Erros :"
      EndIf
      cMsg += ENTER
      cTituloMsg := STR0056 //MCF - 03/02/2016
   ElseIf nTipo == NCM
      cMsg += STR0023 + aLogs[i][1]                             + ENTER  //"N.C.M.: "
      cMsg += STR0024 + aLogs[i][2]                             + ENTER  //"Descrição: "
      cMsg += STR0025 + aLogs[i][3]                             + ENTER  //"Unidade de Medida: "
      cMsg += STR0026 + aLogs[i][4]                             + ENTER  //"Percentual de I.I.: "
      cMsg += STR0027 + aLogs[i][5]                             + ENTER  //"Percentual de I.P.I.: "
      cMsg += STR0028 + aLogs[i][6]                             + ENTER  //"Percentual de PIS: "
      cMsg += STR0029 + aLogs[i][7]                             + ENTER  //"Percentual de COFINS: "
      If Len(aLogs[i]) > 7
         cMsg += STR0039 + aLogs[i][8]                          + ENTER  //"Majoração de COFINS: "
      EndIf
      cMsg += ENTER
   ElseIf nTipo == EX
      cMsg += STR0023 + aLogs[i][1]                             + ENTER  //"N.C.M.: "
      cMsg += STR0040 + aLogs[i][2]                             + ENTER  //"Ex - N.C.M.: "
      cMsg += STR0024 + aLogs[i][3]                             + ENTER  //"Descrição: "
      cMsg += ENTER
   ElseIf nTipo == ANUENCIA
      cMsg += STR0023 + aLogs[i][1]                             + ENTER  //"N.C.M.: "
      cMsg += STR0048 + aLogs[i][2]                             + ENTER  //"Órgão Anuente: "
      cMsg += STR0049 + aLogs[i][3]                             + ENTER  //"Indicadores: "
      cMsg += STR0050 + aLogs[i][4]                             + ENTER  //"Tratamentos: "
      cMsg += STR0040 + aLogs[i][5]                             + ENTER  //"Ex - N.C.M.: "
      cMsg += STR0024 + aLogs[i][6]                             + ENTER  //"Descrição: "
      cMsg += STR0051 + aLogs[i][7]                             + ENTER  //"País: "
      cMsg += STR0052 + aLogs[i][8]                             + ENTER  //"Autorizado? : "
      cTituloMsg := STR0055
   EndIf
   fWrite(hFile,cMsg)
   nCont++
Next i

fClose(hFile)

If !lSchedule//RMD - 29/08/19 - Se for Schedule não exibe mensagem e não copia arquivo para o temporário
   If nTipo == NCM

      CpyS2T(cDir+cFile,cTempPath,.F.) //MCF - 18/02/2016
      nContNCM := nCont
      aAdd(aNCMLog,{cFile,nContNCM})

   ElseIf nTipo == EX

      CpyS2T(cDir+cFile,cTempPath,.F.) //MCF - 18/02/2016
      nContEX := nCont
      aAdd(aNCMLog,{cFile,nContEX})

      cMsgInfo := STR0068 + STR0044 + " / " + STR0045 + STR0069 + ENTER +; //"Atualização de " ## " finalizada com sucesso!" ## "Registros Atualizados: "
                  STR0070 + " (" +STR0044 + ")" + ": "+ cValToChar(nContNCM) + ENTER +;
                  IIF(SYD->(FieldPos("YD_MSBLQL")) > 0,STR0072 + " (" +STR0044 + ")" + ": "+ cValToChar(nTotNCMBlq) + ENTER,"") +; //Registros Bloqueados
                  STR0070 + " (" +STR0045 + ")" + ": "+ cValToChar(nContEX)

      MsgInfo(cMsgInfo,STR0013)

      If lExibeLog
         For j:=1 To Len(aNCMLog)
            If aNCMLog[j][2] # 0
               WinExec("NotePad "+cTempPath+aNCMLog[j][1])
            Endif
         Next
      EndIf

   Else

      MsgInfo(STR0068 + cTituloMsg + STR0069 + ENTER + STR0070 + ": " + cValToChar(nCont),STR0013) //"Atualização de " ## " finalizada com sucesso!" ## "Registros Atualizados: "

      If lExibeLog
         CpyS2T(cDir+cFile,cTempPath,.F.) //MCF - 02/02/2016
         WinExec("NotePad "+cTempPath+cFile)
      Endif
   Endif
EndIf

Return NIL

/*
Funcao     : SetCNPJ()
Parametros : Nenhum
Retorno    : CNPJs
Objetivos  : Buscar todos os CNPJs do Grupo de Empresas corrente
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 23/03/2015 : 17:02
*/
*------------------------*
Static Function SetCNPJ(cGrpEmp, lPicture)
*------------------------*
Local aCNPJ := {}
//Local cGrpEmp := SM0->M0_CODIGO
Local cPict := "@R 99.999.999/9999-99"
Local aOrd := SaveOrd("SM0")
Local aFiliais 
Default cGrpEmp := ""
Default lPicture := .F.
/*
If Empty(cGrpEmp)
   SM0->(DbGoTop())
Else
   SM0->(DbSeek(cGrpEmp))
EndIf

Do While SM0->(!Eof()) .AND. If(Empty(cGrpEmp), .T., SM0->M0_CODIGO == cGrpEmp)
   aAdd(aCNPJ,If(lPicture, Trans(SM0->M0_CGC,cPict), SM0->M0_CGC))
   SM0->(DbSkip())
EndDo
*/
aFiliais := FWLoadSM0()
aEval( aFiliais , {|x| If(  If(Empty(cGrpEmp), .T., x[1] == cGrpEmp) , aAdd(aCNPJ,If(lPicture, Trans(x[18],cPict), x[18])) ,  ) })

RestOrd(aOrd,.T.)
Return aCNPJ

/*
Funcao     : RangeNCMs()
Parametros : cNCMIni,cNCMFin,cDtVige,nInt,lSchedule
Retorno    : NIL
Objetivos  : Verifica se NCMs passadas estão dentro do range de atualização
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 23/03/2015 : 17:02
*/
*------------------------------------------------------------------*
Static Function RangeNCMs(cNCMIni,cNCMFin,cDtVige,nInt,lSchedule)
*------------------------------------------------------------------*
Local i, j, lProcessado := .F., lAtuIni := .F.
Local cDados := "", cInicial := "", cFinal := ""
Local aRanges := {}, aAtualiza := {}

If nInt == NCM
   /*aAtualiza := {{"01012100","14011000"},;
                 {"14011000","28399090"},;
                 {"28399090","29242931"},;
                 {"29242931","30034010"},;
   				   {"30034010","39046990"},;
   				   {"39046990","51121100"},;
   				   {"51121100","62171000"},;
   				   {"62171000","76052190"},;
   				   {"76052190","84484910"},;
   				   {"84484910","85332120"},;
   				   {"85332120","93032000"},;
   				   {"93032000","97060000"},;
   				   {"97060000","99997104"}}*/
   aAtualiza := GetRangeNCM()

   If Len(aAtualiza) > 0
   
      For j := 1 To Len (aAtualiza) //MCF - 12/02/2016
         cInicial := If(Val(aAtualiza[j][1]) >= Val(cNcmIni),aAtualiza[j][1],cNcmIni)
         cFinal   := If(Val(cNcmFin) <= Val(aAtualiza[j][2]),cNcmFin,aAtualiza[j][2])
         
         If cInicial <= cFinal
            aAdd(aRanges,{cInicial,cFinal})
         Endif
      Next j
   
   EndIf

ElseIf nInt == EX
   /*
   aAtualiza := {{"01012100","05010000"},;
                 {"05010000","10011100"},;
                 {"10011100","15011000"},;
				   {"15011000","20011000"},;
				   {"20011000","25010011"},;
				   {"25010011","30012010"},;
				   {"30012010","35011000"},;
				   {"35011000","36011000"},;
				   {"36011000","37011000"},;
				   {"37011000","38011000"},;
				   {"38011000","39011000"},;
				   {"39011000","40011000"},;
				   {"40011000","45011000"},;
				   {"45011000","50010000"},;
				   {"50010000","55011000"},;
				   {"55011000","60011010"},;
				   {"60011010","65010000"},;
				   {"65010000","70010000"},;
				   {"70010000","75011000"},;
				   {"75011000","80011000"},;
				   {"80011000","81011000"},;
				   {"81011000","82011100"},;
				   {"82011100","83011100"},;
				   {"83011100","84011000"},;
				   {"84011000","84072190"},;
				   {"84072190","84081090"},;
				   {"84081090","84089090"},;
				   {"84089090","84101100"},;
				   {"84101100","84133090"},;
				   {"84133090","84141000"},;
				   {"84141000","84151011"},;
				   {"84151011","84172000"},;
				   {"84172000","84186920"},;
				   {"84186920","84193100"},;
				   {"84193100","84194010"},;
				   {"84194010","84195029"},;
				   {"84195029","84198920"},;
				   {"84198920","84198999"},;
				   {"84198999","84201010"},;
				   {"84201010","84201010"},;
				   {"84201010","84212100"},;
				   {"84212100","84212990"},;
				   {"84212990","84221900"},;
				   {"84221900","84223029"},;
				   {"84223029","84224030"},;
				   {"84224030","84248990"},;
				   {"84248990","84262000"},;
				   {"84262000","84271019"},;
				   {"84271019","84271090"},;
				   {"84271090","84272090"},;
				   {"84272090","84283990"},;
				   {"84283990","84289090"},;
				   {"84289090","84292090"},;
				   {"84292090","84301000"},;
				   {"84301000","84314390"},;
				   {"84314390","84334000"},;
				   {"84334000","84351000"},;
				   {"84351000","84385000"},;
				   {"84385000","84413010"},;
				   {"84413010","84431990"},;
				   {"84431990","84433910"},;
				   {"84433910","84439911"},;
				   {"84439911","84451110"},;
				   {"84451110","84483290"},;
				   {"84483290","84529091"},;
				   {"84529091","84543090"},;
				   {"84543090","84571000"},;
				   {"84571000","84581199"},;
				   {"84581199","84602100"},;
				   {"84602100","84614010"},;
				   {"84614010","84624100"},;
				   {"84624100","84649019"},;
				   {"84649019","84669360"},;
				   {"84669360","84705090"},;
				   {"84705090","84719012"},;
				   {"84719012","84735010"},;
				   {"84735010","84748090"},;
				   {"84748090","84771099"},;
				   {"84771099","84775990"},;
				   {"84775990","84778090"},;
				   {"84778090","84793000"},;
				   {"84793000","84798210"},;
				   {"84798210","84798290"},;
				   {"84798290","84798991"},;
				   {"84798991","84798999"},;
				   {"84799010","84807100"},;
				   {"84807100","84818092"},;
				   {"84818092","84834010"},;
				   {"84834010","84863000"},;
				   {"84863000","85011011"},;
				   {"85011011","85152100"},;
				   {"85152100","85176111"},;
				   {"85176111","85176299"},;
				   {"85176299","85301010"},;
				   {"85301010","85339000"},;
				   {"85339000","85372090"},;
				   {"85372090","85423299"},;
				   {"85423299","85444900"},;
				   {"85444900","86073000"},;
				   {"86073000","87042230"},;
				   {"87042230","87085011"},;
				   {"87085011","90011011"},;
				   {"90011011","90184911"},;
				   {"90184911","90214000"},;
				   {"90214000","90251190"},;
				   {"90251190","90275010"},;
				   {"90275010","90278099"},;
				   {"90278099","90303319"},;
				   {"90303319","90311000"},;
				   {"90311000","90314990"},;
				   {"90314990","90318099"},;
				   {"90318099","90328921"},;
				   {"90328921","92079090"},;
				   {"92079090","95030010"},;
				   {"95030010","99997104"}}*/

   aAtualiza := GetRangeNCM()
				   
   For j := 1 To Len (aAtualiza) //MCF - 12/02/2016
      cInicial := If(Val(aAtualiza[j][1]) >= Val(cNcmIni),aAtualiza[j][1],cNcmIni)
      cFinal   := If(Val(cNcmFin) <= Val(aAtualiza[j][2]),cNcmFin,aAtualiza[j][2])
      
      If cInicial <= cFinal
         aAdd(aRanges,{cInicial,cFinal})
      Endif
   Next j
   
EndIf

aGravaRet := {}
If !lSchedule
   oProgress:SetRegua(Len(aRanges))
EndIf
Begin Sequence
   For i := 1 To Len(aRanges)
      cInicial := If(Val(aRanges[i][1]) >= Val(cNcmIni),aRanges[i][1],cNcmIni)   //Max(Val(aRanges[i][1]),Val(cNcmIni))
      cFinal   := If(Val(cNcmFin) <= Val(aRanges[i][2]),cNcmFin,aRanges[i][2])   //Min(Val(cNcmFin),Val(aRanges[i][2]))
      
      If cInicial <= cFinal
         If !lSchedule
            /*Processa({|| */cDados := ConectaSite(MontaURL(nInt,{cInicial,cFinal,cDtVige}))/* } , STR0008, STR0009, .T.)*/ //"Conexão" ## "Conectando com TOTVS Comex Conteúdo..."
         Else
            cDados := ConectaSite(MontaURL(nInt,{cInicial,cFinal,cDtVige}))
         EndIf
         If !Empty(cDados)
            If Alltrim(cDados) $ "Acesso Negado|Senha incorreta|Usuário não cadastrado"
               If !lSchedule
                  MsgInfo(STR0032,STR0007)  //"Usuário sem acesso. Para atualizar automaticamente informações de comércio exterior, procure seu executivo de relacionamento e conheça mais sobre o TOTVS Comex Conteúdo." ## "Atenção"
               Else
                  Conout(STR0032)  //"Usuário sem acesso. Para atualizar automaticamente informações de comércio exterior, procure seu executivo de relacionamento e conheça mais sobre o TOTVS Comex Conteúdo."
               EndIf
               Break
            EndIf
         EndIf
         If !lSchedule
            If !oProgress:IncRegua()
               lProcessado := .F.
               BREAK
            EndIf
         EndIf
         If !lSchedule
            lProcessado := ProcessaRet(nInt,cDados,@aGravaRet,lSchedule)
         Else
            lProcessado := ProcessaRet(nInt,cDados,@aGravaRet,lSchedule)
         EndIf
      EndIf
   Next i 

End Sequence

Return lProcessado

/*RMD - 12/05/22 - Obtém os ranges a partir da lista de NCMs válidas, disponível no endpoint 'integracao_ncm_validas.php', e faz a quebra a cada 900 NCMs*/
Static Function GetRangeNCM(lSchedule, lBlind)
Local aRange := {}
Local cNCMList, aNCMList, nTotal := 2, nIncremento

      If !lSchedule
         Processa({|| cNCMList := ConectaSite(MontaURL(LISTA))} , STR0008, STR0009, .T.) //"Conexão" ## "Conectando com TOTVS Comex Conteúdo..."
      Else
         cNCMList := ConectaSite(MontaURL(LISTA))
      EndIf
      If !Empty(cNCMList)
         If Alltrim(cNCMList) $ "Acesso Negado|Senha incorreta|Usuário não cadastrado"
            If !lSchedule
               MsgInfo(STR0032,STR0007)  //"Usuário sem acesso. Para atualizar automaticamente informações de comércio exterior, procure seu executivo de relacionamento e conheça mais sobre o TOTVS Comex Conteúdo." ## "Atenção"
            Else
               Conout(STR0032)  //"Usuário sem acesso. Para atualizar automaticamente informações de comércio exterior, procure seu executivo de relacionamento e conheça mais sobre o TOTVS Comex Conteúdo."
            EndIf
         Else
            aNCMList := StrTokArr(cNCMList,ENTER)
            While nTotal <= Len(aNCMList)
               nIncremento := If(Len(aNCMList) < nTotal + 900, Len(aNCMList) - nTotal, 899)
               aAdd(aRange, {aNCMList[nTotal], aNCMList[nTotal + nIncremento]})
               nTotal += nIncremento + 1
            EndDo
         EndIf
      EndIf
      If Empty(cNCMList) .Or. Len(aRange) == 0
         If !lSchedule .AND. !lBlind
            MsgInfo(STR0031 + ENTER + STR0030,STR0007)  // "A busca solicitada não retornou dados para atualização" ## "Verifique se os parâmetros passados são válidos para a busca solicitada." ##  "Atenção"
         Else
            Conout(STR0031 + ENTER + STR0030)  // "A busca solicitada não retornou dados para atualização"
         EndIf
      EndIf

Return aRange

/*
Funcao     : DeParaUnid()
Parametros : nLoop,cNCMIni,cNCMFin
Retorno    : NIL
Objetivos  : Verifica se NCMs passadas estão dentro do range de atualização
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 23/03/2015 : 17:02
*/
*-------------------------------------------------------*
Static Function DeParaUnid(cUnid)
*-------------------------------------------------------*
Local cConv := ""
Local aUnidades := {}

aAdd(aUnidades,{"KG","10"})
aAdd(aUnidades,{"UN","11"})
aAdd(aUnidades,{"MU","12"})
aAdd(aUnidades,{"PS","13"})
aAdd(aUnidades,{"M" ,"14"})
aAdd(aUnidades,{"M²","15"})
aAdd(aUnidades,{"M³","16"})
aAdd(aUnidades,{"L" ,"17"})
aAdd(aUnidades,{"MW","18"})
aAdd(aUnidades,{"KE","19"})
aAdd(aUnidades,{"DZ","20"})
aAdd(aUnidades,{"GR","22"})
aAdd(aUnidades,{"TN","21"})

If (nPos := aScan(aUnidades, {|x| x[1] == cUnid })) # 0
   cConv := aUnidades[nPos][2]
EndIf
Return cConv

/*
Funcao     : DeParaAnu()
Parametros : cAutorizado
Retorno    : NIL
Objetivos  : Verifica se NCM passada é anuente ou não.
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 30/06/2015 :: 19:01
*/
*-------------------------------------------------------*
Static Function DeParaAnu(cAutorizado)
*-------------------------------------------------------*
Return If("Não Aut" $ cAutorizado,"2","1")

/*
Funcao     : ValidaUsuario()
Parametros : Usuario Fiscosoft informado nas Configurações
Retorno    : NIL
Objetivos  : Validação de Usuario
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 20/05/2015 :: 11:44
*/
*--------------------------------*
Static Function ValidaUsuario() 
*--------------------------------*
//RMD - 16/10/20 - Passa a retornar somente cUsuario, que é validado no início de cada execução
//Return If(!AllTrim("TE"+SubStr(SM0->M0_CGC,1,8)) == AllTrim(cUsuario),AllTrim("TE"+SubStr(SM0->M0_CGC,1,8)),cUsuario)
Return cUsuario

/*
RMD - 16/10/20 - Obtem o usuário a partir das configurações da rotina e valida se o CNPJ existe no SIGAMAT para o grupo de empresas
*/
Static Function GetUsuario(lSchedule)
Local cUser
Local oUserParams	:= EASYUSERCFG():New("EICCD100")
Local aCNPJ := SetCNPJ()
Local lCNPJ_OK := .F., cCNPJRaiz := ""

   cUser := oUserParams:LoadParam("USRCC","","EICCD100")

   If Empty(cUser)
      If !lSchedule
         MsgInfo(STR0006,STR0007)  //"Não foram encontradas as configurações de usuario e senha necessárias para efetuar a integração solicitada." ## "Atenção"
      Else
         Conout(STR0006)   //"Não foram encontradas as configurações de usuario e senha necessárias para efetuar a integração solicitada."
      EndIf
   Else
      cCNPJRaiz := StrTran(cUser, "TE", "")
      aEval(aCNPJ, {|x| If(Left(x, Len(cCNPJRaiz)) == cCNPJRaiz, lCNPJ_OK := .T.,) })
      If !lCNPJ_OK
         If !lSchedule
            MsgInfo(StrTran(StrTran(STR0073, "YYY", cCNPJRaiz), "XXX", cUser), STR0007) //"Erro ao validar o usuário (XXX). Não foi encontrada empresa com o CNPJ iniciado por 'YYY' no arquivo de empresas."
         Else
            Conout(StrTran(StrTran(STR0073, "YYY", cCNPJRaiz), "XXX", cUser))   //"Não foram encontradas as configurações de usuario e senha necessárias para efetuar a integração solicitada."
         EndIf
         cUser := ""
      EndIf
   EndIf

Return cUser

/*
Funcao     : CD100CDQA()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Comex Data QA
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 23/03/2015 : 14:36
*/
*----------------------*
Function CD100CDQA()
*----------------------*
Local oCDQA
Local oUserParams	:= EASYUSERCFG():New("EICCD100")
Local cUserCD := oUserParams:LoadParam("USRCD","","EICCD100")
Local cPassCD := DECRYP(oUserParams:LoadParam("PSSCD","","EICCD100"))

If !EasyGParam("MV_EIC0061",,.F.) .Or. !FindFunction("EasyComexDataQA") //MCF - 08/02/2016
   MsgInfo(STR0067,STR0064)
   Return
EndIf

If Empty(cUserCD) .OR. Empty(cPassCD)
   MsgInfo(STR0006,STR0007)  //"Não foram encontradas as configurações de usuario e senha necessárias para efetuar a integração solicitada." ## "Atenção"
   Return 
EndIf

oCDQA := EasyComexDataQA():New(,,cUserCD,cPassCD)
Return oCDQA:ShowDlg()

/*
Funcao     : CD100SchNCM()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Chamada via Schedule de integração NCM
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 24/03/2015 - 09:18
*/
*-----------------------------*
Function CD100SchNCM(aParams) 
*-----------------------------*
Return CD100IntNCM(,,,.T.,aParams[1],aParams[2])

/*
Funcao     : CD100SchTX()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Chamada via Schedule de integração de Taxas
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 23/03/2015 : 14:36
*/
*-----------------------------*
Function CD100SchTX(aParams) 
*-----------------------------*
Return CD100IntTx(,,,.T.,aParams[1],aParams[2])

/*
Funcao     : SetMajoracao()
Parametros : nValor - Valor da aliquota
Retorno    : .T./.F.
Objetivos  : Verifica aliquotas pretencentes a regra de Majoração.
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 11/05/2015 : 17:00
*/
*-----------------------------------*
Static Function SetMajoracao(nValor)
*-----------------------------------*
Local aAliquotas := {}

//Aliquotas pertencentes a regra de Majoração, conforme a lei 13137/2015.
aAdd(aAliquotas,4.02)
aAdd(aAliquotas,10.65)
aAdd(aAliquotas,13.57)
aAdd(aAliquotas,14.03)
aAdd(aAliquotas,13.35)
aAdd(aAliquotas,17.48)
aAdd(aAliquotas,15.37)
aAdd(aAliquotas,16.26)
aAdd(aAliquotas,18.23)

//Interpretação Fiscosoft - Fundamento Legal
aAdd(aAliquotas,1)
aAdd(aAliquotas,1.82)

Return aScan(aAliquotas,{|x| x == nValor}) # 0

/*
Funcao     : BloqNCM()
Parametros : cNCMIni - NCM inicial para o intervalo de atualização
             cNCMFim - NCM final para o intervalo de atualização
             cDtAtul - Data de atualização
Retorno    : -
Objetivos  : Efetua o bloqueio das NCMs que não foram atualizadas pela integração
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 28/05/2020
*/
Static Function BloqNCM(cNCMIni,cNCMFim,cDtAtul,cMsgErro)
Local cQuery
Local cUpdate
Local cWhere

Local nTot := 0

cUpdate := " UPDATE  " + RetSqlName("SYD") + " "
cUpdate += " SET YD_MSBLQL = '1' "

cQuery := " SELECT * FROM " + RetSqlName("SYD") +" "

cWhere := " WHERE YD_FILIAL ='" +xFilial("SYD") + "' "
cWhere += "   AND YD_TEC >= '" + cNCMIni + "' "
cWhere += "   AND YD_TEC <= '" + cNCMFim + "' "
cWhere += "   AND YD_EX_NBM = ' ' "
cWhere += "   AND YD_EX_NCM = ' ' "
cWhere += "   AND YD_DTINTE < '" + cDtAtul + "' "
cWhere += "   AND (YD_MSBLQL = '2' OR YD_MSBLQL = ' ' )"
cWhere += "   AND D_E_L_E_T_= ' ' "

nTot := EasyQryCount(cQuery + cWhere)

If nTot > 0 .And. TcSQLExec(cUpdate + cWhere) < 0
	cMsgErro := "TCSQLError() " + TCSQLError()
   nTot := 0
EndIf

Return nTot
