#INCLUDE "Eicnu400.ch"
//#include "FiveWin.ch"
#include "Average.ch"
#include 'ap5mail.ch'
#INCLUDE "FWBROWSE.CH"
#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define FINAL_ENCHOICE MEIO_DIALOG-1
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define FINAL_SELECT   (oDlg:nClientHeight-6)/2

/*
Funcao    ³ EICNU400
Autor     ³ AVERAGE/LUIZ CLAUDIO BARBOSA
Data      ³ 20.10.2000
Descricao ³ Solicitação de numerario
Sintaxe   ³ EICNU400()
Uso       ³ SIGAEIC
Revisão   ³ Guilherme Fernandes Pilan - GFP
Data      ³ 20/01/2016 :: 08:58
Descricao ³ Adaptação de função para ExecAuto
*/

Function EICNU400(aCabAux,nOpcAux,bFunAux) 
Local cOldAlias   := Alias()
Local cAlias      := "SW6", i

Private aCabAuto := aCabAux
Private nOpcAuto := nOpcAux
Private bFuncAuto := bFunAux
Private lNotErroAuto := .T.
Private lMSErroAuto := .F.
Private lExecAut := ( aCabAuto <> NIL ) .AND. ( nOpcAuto <> NIL ) .AND. ( bFuncAuto <> NIL )
Private lFinanceiro:= EasyGParam("MV_EASYFIN",,"N") $ cSim

Private lCallSap  := GetNewPar("MV_SAP_INT","N") == "S",lNaoAltera:=.T.
PRIVATE lPoint_NU := EasyEntryPoint("EICPNU01")
PRIVATE cCadastro := STR0018
PRIVATE aRotina   := MenuDef()
PswOrder(1)
PswSeek(__CUSERID,.T.)
Private aUsuario    := PswRet(1)
Private cServer     := AllTrim(GetNewPar("MV_RELSERV"," ")) // "mailhost.average.com.br" //Space(50)
Private cAccount    := AllTrim(GetNewPar("MV_RELACNT"," ")) //Space(50)
Private cPassword   := AllTrim(GetNewPar("MV_RELPSW" ," "))  //Space(50)
Private nTimeOut    := EasyGParam("MV_RELTIME",,120)//Tempo de Espera antes de abortar a Conexão
Private lAutentica  := EasyGParam("MV_RELAUTH",,.F.)//Determina se o Servidor de Email necessita de Autenticação
Private cUserAut    := Alltrim(EasyGParam("MV_RELAUSR",,cAccount))//Usuário para Autenticação no Servidor de Email
Private cPassAut    := Alltrim(EasyGParam("MV_RELAPSW",,cPassword))//Senha para Autenticação no Servidor de Email
Private cFrom       := IF(!Empty(aUsuario[1][14]) .and. empty(AllTrim(GetNewPar("MV_RELFROM" ," "))) , AllTrim(aUsuario[1][14]), AllTrim(GetNewPar("MV_RELFROM" ," ")) )
Private lRelTLS     := GetMV("MV_RELTLS")
Private lRelSLS     := GetMV("MV_RELSSL")
Private cRelPor     := GetMV("MV_PORSMTP")
Private lEmail      := .T.//Utilizado para enviar ou nao o email por ponto de entrada. //If(EMPTY(cServer).OR.EMPTY(cAccount).OR.EMPTY(cPassword).OR.EMPTY(cFrom),.F.,.T.)
Private cDebAut     := AllTrim(GetNewPar("MV_DEBAUT", " "))
Private cAttachment := "",lOK:= .T.
Private oMail, oMessage, nErro
PRIVATE lGeraPO := IF(GetNewPar("MV_EASYFPO","S")="S",.T.,.F.)
Private lEmailDespForn:= EasyGParam("MV_DESPFOR",,.F.)  //Envia email para o Fornecedor quando este parametro estiver ligado - RS 04/09/07
lNaoAltera:=.T. //Para incluir uma Nova Despesa através do Botão F3
PRIVATE lTemSW6 := .T.

Private lParamOk  := !Empty(cServer) .AND. !EMPTY(cFrom)

PRIVATE lAvIntFinEIC:= AvFlags("AVINT_FINANCEIRO_EIC")
Private oDI500IntProv
Private cSubject2 := "" //LRS - 29/11/2018

if at(":",cServer) > 0
   if Empty(cRelPor)
      cRelPor := val( Substr( cServer , at(":",cServer)+1 , len(cServer) ) )
   endif
   cServer := Substr( cServer , 1 , at(":",cServer)-1 )
endif

If AvFlags("EIC_EAI")
   CriarEvento()
   If AvFlags("AVINT_PRE_EIC")
      oDI500IntProv := AvIntProv():New()
   EndIf
EndIf

DbSelectArea("EIC")
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
NEXT

If !lExecAut
   IF lTemSW6
      mBrowse( 6, 01, 22, 75, cAlias)
   ENDIF
Else
   Begin Transaction
      EIC->(DbSetOrder(1))
      If EIC->(DbSeek(xFilial("EIC")+aCabAuto[1][2]))
         MBrowseAuto(4,aCabAuto,cAlias)

         If !lNotErroAuto
            RollBackDelTran("")
         EndIf
	  EndIf
   End Transaction
EndIf

dbSelectArea(cOldAlias)

Return .T.

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 26/01/07 - 11:00
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  {{ STR0001,           "AxPesqui"   , 0, 1},; //"Pesquisar"
                   { OemToAnsi(STR0002),"NU400Manut" , 0, 4},; //"Manutenção"
                   { STR0003,           "NU400AP100" , 0, 4}}  //"Integração"

If EasyEntryPoint("EICPNU01")
   ExecBlock("EICPNU01",.F.,.F.,"AROTINA")
EndIf

If EasyEntryPoint("EICNU400")
   Execblock("EICNU400",.F.,.F.,"AROTINA")
EndIf

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("INU400MNU")
	aRotAdic := ExecBlock("INU400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

*------------------------------------*
Function NU400Manut(cAlias,nReg,nOpc)
*------------------------------------*
local aInfo:={}, i:=0, _nx:=0
Local aSemSX3   := { {"EIC_NOME", "C",AVSX3("EIC_USER",3),0},;
                     {"RECNO"   , "N", 7, 0} }
Local cAliasOld := Alias(), cOldFilter := "", cFilter := ""
Local aButtons := {} // FDR - 16/08/2011
Local nInc := 0
Local oBrowse, aUserCpos
Local aFilter := {}
Local aSeek := {}
Local cNomeCampo := ""
Local lEnvWf     := .F. //RNLP 14-07-20 -- controle de envio de workflow -- quando aprovaçao envio se da pela funcao NU400Efetiva
Private nOpRotina:=nOpc//AWR - 13/11/2004 - Para os rdmakes
PRIVATE aCpos:= {}, aDeletados := {}
PRIVATE cPictValor:=X3Picture("EIC_VALOR")
PRIVATE cIniBrw := "{||"+AVSX3("EIC_PAGOPO",14,"TRB")+"}"
PRIVATE bIniBrw := &cIniBrw
// SVG - 11/06/2010 -
Private cBody:=Cbody2:=""
AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
AADD(aSemSX3,{"TRB_RECOLD","N",10,0})
aAdd(aSemSX3, {"TRB_MARK", "C", 4, 0})

AADD(aCpos,{SX3->X3_CAMPO, AVSX3(SX3->X3_CAMPO, AV_TAMANHO), AVSX3(SX3->X3_CAMPO, 5)})
aCpos:= { {{|| TRB->EIC_DESPES+" "+if(SYB->(dbSeek(xFilial()+TRB->EIC_DESPES)),SYB->YB_DESCR,"")}, AVSX3("EIC_DESPES", AV_TAMANHO) + AVSX3("YB_DESCR", AV_TAMANHO),AVSX3("EIC_DESPES",5), "", "EIC_DESPES"},; //"Despesa"
          {"EIC_DT_DES", AVSX3("EIC_DT_DES", AV_TAMANHO),AVSX3("EIC_DT_DES",5), "", "EIC_DT_DES"},; //"Valor R$"
          {"EIC_VALOR" , AVSX3("EIC_VALOR", AV_TAMANHO),AVSX3("EIC_VALOR",5), cPictValor, "EIC_VALOR"},; //"Valor R$"
          {"EIC_FORN"  , AVSX3("EIC_FORN", AV_TAMANHO),AVSX3("EIC_FORN"  ,5), "", "EIC_FORN"},;  // JBS - 13/05/2004 - OC 0030/04 OS 0707/04
          {"EIC_LOJA"  , AVSX3("EIC_LOJA", AV_TAMANHO),AVSX3("EIC_LOJA"  ,5), "", "EIC_LOJA"},;  // JBS - 13/05/2004 - OC 0030/04 OS 0707/04
          {"EIC_CODINT"  , AVSX3("EIC_CODINT", AV_TAMANHO),AVSX3("EIC_CODINT"  ,5), "", "EIC_CODINT"},;
          {{|| If(TRB->EIC_BASEAD$cSim,STR0019,STR0020)}, 3,AVSX3("EIC_BASEAD",5), "", "EIC_BASEAD"},; //"Adianta/o ?"
          {bIniBrw, AVSX3("EIC_PAGOPO", AV_TAMANHO),AVSX3("EIC_PAGOPO",5), , "EIC_PAGOPO" },;
          {"EIC_DT_EFE", AVSX3("EIC_DT_EFE", AV_TAMANHO), AVSX3("EIC_DT_EFE",5), "", "EIC_DT_EFE"},;
          {"EIC_LIBERA", AVSX3("EIC_LIBERA", AV_TAMANHO), AVSX3("EIC_LIBERA",5), "", "EIC_LIBERA"},;
          {"EIC_ARQ"   , AVSX3("EIC_ARQ", AV_TAMANHO), AVSX3("EIC_ARQ",5), "", "EIC_ARQ"},;
          {"EIC_NOME"  , AVSX3("EIC_USER", AV_TAMANHO), AVSX3("EIC_USER",5), "", "EIC_USER"} }
//        {{|| If(TRB->EIC_PAGOPO$cSim,STR0021,STR0022)},,AVSX3("EIC_PAGOPO",5) },;

If lPoint_NU
   ExecBlock("EICPNU01",.F.,.F.,"BROW_EIC")
EndIf
nOpc := If(lExecAut,nOpcAuto,nOpc)
//JAP - 18/08/06 - Alteração de Variáveis para utilização na DEICMAR
SY5->(dbSeek(xFilial("SY5")+SW6->W6_DESP))
PRIVATE M->W6_HAWB    := SW6->W6_HAWB
PRIVATE M->W6_DESP    := SW6->W6_DESP
PRIVATE M->W6_FOB_TOT := SW6->W6_FOB_TOT
PRIVATE M->W6_DT_HAWB := SW6->W6_DT_HAWB
PRIVATE M->W6_TIPOFEC := SW6->W6_TIPOFEC
PRIVATE M->W6_REF_DES := SW6->W6_REF_DES

IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"BROW_EIC"),)

PRIVATE cMarca := GetMark(), lInverte := .F.
PRIVATE aCampos:= Array(EIC->(fCount()))
PRIVATE aHeader:= {}
PRIVATE nEfetiva := nNaoEfet := nTotDesp := 0
Private oPanel //LRL 02/04/04
PRIVATE aCoord := {}
PRIVATE nLinBota1 := 15
PRIVATE nLinBota2 := 27
PRIVATE nLinBota3 := 39
PRIVATE nColBota1
PRIVATE nColBota2
PRIVATE nColBota3
Private cControle := "" //RRV - 22/02/2013
Private dDataEfe := "" //RRV - 22/02/2013
Private aChaves := {}  // GFP - 19/01/2016
Private cNWorkEIC:= "" //LGS - 27/01/2016

DbSelectArea("EIC")
FOR i := 1 TO FCount()
    aadd( aCampos, FieldGet(i) )
NEXT

//GFP 19/10/2010
aSemSX3 := AddWkCpoUser(aSemSX3,"EIC")
cNomeTemp := E_CriaTrab("EIC",aSemSX3)  // Criacao do arquivo de Trabalho
IndRegua("TRB",cNomeTemp+TEOrdBagExt(),"EIC_HAWB+EIC_DESPES")
if lEmailDespForn             // RS - 04/09/07
   cIndex:=E_Create(,.F.)     // RS - 04/09/07
   IndRegua("TRB",cIndex+TEOrdBagExt(), "EIC_FORN+EIC_DESPES")   // RS - 04/09/07
   SET INDEX TO (cNomeTemp+TEOrdBagExt()),(cIndex+TEOrdBagExt())            // RS - 04/09/07
endif                                                                   // RS - 04/09/07

dbSelectArea("EIC")
cChave := If(!lExecAut,xFilial("EIC")+M->W6_HAWB,xFilial("EIC")+aCabAuto[1][2])
EIC->(DBSETORDER(1)) //EIC_FILIAL+EIC_HAWB+EIC_DESPES
EIC->(dbSeek(cChave))
Do While !EIC->(Eof()) .And. EIC->EIC_FILIAL + EIC->EIC_HAWB == cChave
   If lExecAut .AND. (nPosID := aScan(aCabAuto,{|x| x[1] $ "EIC_ID_APR"}) ) # 0
      If EIC->EIC_ID_APR <> AvKey(aCabAuto[nPosID][2],"EIC_ID_APR")
         EIC->(dbSkip())
         LOOP
      EndIf
   EndIf
   lLoop:=.F.
   IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"GRAVA_TRB"),)
   IF lLoop
      EIC->(dbSkip())
      LOOP
   ENDIF
   RecLock("TRB", .T.)
   For _nX := 1 To EIC->(fCount())

      _xConteudo := EIC->(FieldGet(_nX))
      _nPos      := TRB->(FieldPos(EIC->(Field(_nX))))
      If _nPos > 0
         TRB->(FieldPut(_nPos, _xConteudo))
         cNomeCampo := TRB->(FieldName(_nPos))
         AAdd(aFilter, {cNomeCampo, AvSx3(cNomeCampo, AV_TITULO), AvSx3(cNomeCampo, AV_TIPO), AvSx3(cNomeCampo, AV_TAMANHO), AvSx3(cNomeCampo, AV_DECIMAL), AvSx3(cNomeCampo, AV_PICTURE)})
      EndIf
   Next

   TRB->TRB_ALI_WT:= "EIC"
   TRB->TRB_REC_WT:=  EIC->(Recno())

   PswOrder(1)
   IF !lExecAut .AND. PswSeek(ALLTRIM(TRB->EIC_USER),.T.)
      aInfo:=PswRet(1)
      IF LEN(aInfo) > 0 .AND. LEN(aInfo[1]) > 0
         TRB->EIC_NOME:=ALLTRIM(aInfo[1][2])
      ENDIF
   ELSE
      TRB->EIC_NOME:=""
   ENDIF
   TRB->RECNO  := EIC->(Recno())
   //TRP - 23/05/2007
   If EasyEntryPoint("EICNU400")
      ExecBlock("EICNU400",.F.,.F.,"CARREGA_CAMPO")
   EndIf
   If !Empty(EIC->EIC_DT_EFE)
      nEfetiva += EIC->EIC_VALOR
   Else
      nNaoEfet += EIC->EIC_VALOR
   EndIf
   nTotDesp += EIC->EIC_VALOR

   TRB->(MSUnlock())
   EIC->(dbSkip())
EndDo

IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"INICIA_VARIAVEIS"),)

   // FDR - 16/08/2011 - Botões da EnchoiceBar
   Aadd(aButtons,{"EDIT"    ,{|| NU400Enchoice(1), oBrowse:Refresh(.T.)},"Incluir","Incluir"})// Incluir
   Aadd(aButtons,{"IC_17"   ,{|| NU400Enchoice(2), oBrowse:Refresh()},"Alterar","Alterar"})// Alterar
   Aadd(aButtons,{"EXCLUIR" ,{|| NU400Enchoice(3), oBrowse:Refresh(.T.)},"Excluir","Excluir"}) // Excluir

   AAdd(aButtons, {"", {|| NU400PreCalc(), oBrowse:Refresh(), nOpcao := 2, oDlg:End()}, STR0107}) //LGS-23/01/2016 - "Previsões do pré-calculo"

   If cNivel >= EasyGParam("MV_EICNUSU",,8)
      AAdd(aButtons, {"", {|| If(validNoMk(), (Processa({||  NU400Efetiva() }, STR0024), oBrowse:Refresh(), nOpcao := 2, oDlg:End()), oBrowse:Refresh(.T.))}, STR0007}) //Liberar Adiantamento
      AAdd(aButtons, {"", {|| If(NU400CanLote(),(oBrowse:Refresh(),nOpcao := 2,oDlg:End()),)}, STR0008}) //Cancelar Aprovação
      If lEmailDespForn .And. lParamOk
         AAdd(aButtons, {"", {|| Processa({|| If(NU400VerifDesp(),NU400ReenvioMail(),MsgStop(STR0083)) }, STR0082),oBrowse:Refresh(),nOpcao := 2,oDlg:End()}, STR0081}) //Reenviar E-Mail - TRP-09/10/07
      EndIf
   EndIf
   aChaves := {}

  //GFP 19/10/2010
  aUserCpos := AddCpoUser(,"EIC","2")
  For i := 1 To Len(aUserCpos)
  aAdd(aUserCpos[i], aCpos[i][5]) // Adicionando nome do campo
  aUserCpos[i][2] := AVSX3(aUserCpos[i][1], AV_TAMANHO) // Atribuindo tamanho
  aAdd(aCpos, aUserCpos[i])
  Next

  AAdd(aSeek, {AvSx3("EIC_HAWB", AV_TITULO) + " + " + AvSx3("EIC_DESPES", AV_TITULO),{{"", AvSx3("EIC_HAWB", AV_TIPO)     , AvSx3("EIC_HAWB", AV_TAMANHO)     , AvSx3("EIC_HAWB", AV_DECIMAL)     , AvSx3("EIC_HAWB", AV_TITULO)},{"", AvSx3("EIC_DESPES", AV_TIPO) , AvSx3("EIC_DESPES", AV_TAMANHO) , AvSx3("EIC_DESPES", AV_DECIMAL) , AvSx3("EIC_DESPES", AV_TITULO)}}, 1})
  If lEmailDespForn
    AAdd(aSeek, {AvSx3("EIC_FORN", AV_TITULO) + " + " + AvSx3("EIC_DESPES", AV_TITULO),{{"", AvSx3("EIC_FORN", AV_TIPO)     , AvSx3("EIC_FORN", AV_TAMANHO)     , AvSx3("EIC_FORN", AV_DECIMAL)     , AvSx3("EIC_FORN", AV_TITULO)},{"", AvSx3("EIC_DESPES", AV_TIPO) , AvSx3("EIC_DESPES", AV_TAMANHO) , AvSx3("EIC_DESPES", AV_DECIMAL) , AvSx3("EIC_DESPES", AV_TITULO)}}, 2})
  EndIf
DO While .T.
   nOpcao := 0
   If !lExecAut
      If !SW6->(IsLocked())
        SoftLock("SW6")
      EndIf
      DEFINE MSDIALOG oDlg TITLE STR0018 ; //"Manuten‡Æo"
         FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
         OF oMainWnd PIXEL
         oDlg:lMaximized:=.T.
         aCoord    := {55,4,FINAL_SELECT,COLUNA_FINAL}
         nColBota1 := COLUNA_FINAL-55
         nColBota2 := COLUNA_FINAL-55
         nColBota3 := COLUNA_FINAL-55

         IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"VALORES_TELA"),)

         oPanel := TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 50)
         oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
         @ 07,010 Say STR0027+":"                                                      of oPanel PIXEL //Processo
         @ 07,060 MSGET W6_HAWB                                    SIZE 80,08 WHEN .F. of oPanel PIXEL
         @ 20,010 Say STR0024+":"                                                      of oPanel PIXEL //Vlr.Aprovado
         @ 20,060 MSGET nEfetiva   PICTURE X3Picture("W6_FOB_TOT") SIZE 80,08 WHEN .F. of oPanel PIXEL
         @ 33,010 Say STR0028+" "+SW6->W6_FOBMOE+":"                                   of oPanel PIXEL //Vlr.Merc.
         @ 33,060 MSGET W6_FOB_TOT PICTURE X3Picture("W6_FOB_TOT") SIZE 80,08 WHEN .F. of oPanel PIXEL

         @ 07,160 Say STR0021+":"                                                      of oPanel PIXEL //Despachante
         @ 07,210 MSGET W6_DESP                                    SIZE 80,08 WHEN .F. of oPanel PIXEL
         @ 20,160 Say STR0025+":"                                                      of oPanel PIXEL //Vlr.Não Aprovado
         @ 20,210 MSGET nNaoEfet   PICTURE X3Picture("W6_FOB_TOT") SIZE 80,08 WHEN .F. of oPanel PIXEL
         @ 33,160 Say STR0026+":"                                                      of oPanel PIXEL //Vlr.Tot.Despesas
         @ 33,210 MSGET nTotDesp   PICTURE X3Picture("W6_FOB_TOT") SIZE 80,08 WHEN .F. of oPanel PIXEL

         IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"TELA_MANUT"),)

        
        TRB->(dbGoTop())
        oPanelBrow := TPanel():New(0, 0, "", oDlg,, .F., .F.)
        oPanelBrow:Align:=CONTROL_ALIGN_ALLCLIENT
        DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "TRB" OF oPanelBrow
        oBrowse:SetDoubleClick({|| NU400Enchoice(2), oBrowse:Refresh()})
        addMarkCol(oBrowse)
        For i := 1 To Len(aCpos)
          uData := If(ValType(aCpos[i][1]) == "C", &("{|| TRB->" + aCpos[i][1] + "}"), aCpos[i][1])
          ADD COLUMN oColumn DATA uData TITLE aCpos[i][3] SIZE aCpos[i][2] PICTURE If(Len(aCpos[i]) != Nil, aCpos[i][4], "") OF oBrowse
        Next
        oBrowse:SetUseFilter()
        //oBrowse:SetFieldFilter(aFilter) //O aFilter está montado, mas esta dando erro no objeto, provavelmente erro de framework. Apos corrigir, voltar este comando
        oBrowse:SetSeek(,aSeek)
        oBrowse:lCanCancelFilter := .T.
	     oBrowse:Activate()
        

      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcao := 1,oDlg:End()},{||nOpcao := 0,oDlg:End()},,aButtons )) //LRL 02/04/04 - Alinhamento MDI // FDR - 16/08/2011 //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   Else
      Processa(bFuncAuto,STR0101)  //"Processando..."
      nOpcao := 1
   EndIf

   If nOpcao == 2       // *** Em processamento
      Loop
   ElseIf nOpcao == 1   // *** Clicou em Ok.
      If !lExecAut
         lLoop := .F.
         If(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"LOOP_TELA_MANUT"),)
         If lLoop
            Loop
         EndIf
      EndIf
    
      *----------------------------------------------------------*
      * INICIO DA TRANSACAO                                      *
      *----------------------------------------------------------*

      Begin Transaction

         For i:=1 To Len(aDeletados)
             EIC->(dbGoTo(aDeletados[i]))
             EIC->(RecLock("EIC",.F.))
             EIC->(dbDelete())
             EIC->(MSUnlock())
         Next i
         TRB->(dbGoTop())
         DO While TRB->(!Eof())
            lLoop:=.F.
            IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"GRAVA_EIC"),)
            IF lLoop
               TRB->(dbSkip())
               LOOP
            ENDIF
            IF TRB->RECNO == 0
               EIC->(RecLock("EIC",.T.)) // Append com lock               
            ELSE
               EIC->(dbGoTo(TRB->RECNO))
               EIC->(RecLock("EIC",.F.))
            ENDIF

            If AvFlags("WORKFLOW")  // GFP - 19/01/2016
               If TRB->RECNO == 0 .Or. TRB->EIC_VALOR <> EIC->EIC_VALOR
                  M->EIC_HAWB := TRB->EIC_HAWB
                  M->EIC_DESPES := TRB->EIC_DESPES
                  aChaves := {}
                  aChaves := EasyGroupWF("NUMERARIO_EIC")
                  lEnvWf := .T. //RNLP 14-07-20 -- controle de envio de workflow -- quando aprovaçao envio se da pela funcao NU400Efetiva                
               EndIf   
            EndIf

            // Grava campos no EIC ...
            For _nX := 1 To EIC->(fCount())
               If TRB->(FieldPos(EIC->(Field(_nX)))) > 0
                  _xConteudo := TRB->(FieldGet(TRB->(FieldPos(EIC->(Field(_nX))))))
                  EIC->(FieldPut(_nX, _xConteudo))
               EndIf
            Next
            EIC->EIC_FILIAL := xFilial("EIC")

            If lPoint_NU
               ExecBlock("EICPNU01",.F.,.F.,"GRAVOU_DESP")
            EndIf
            IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"GRAVOU_DESP"),)
            EIC->(MSUNLOCK())
            
            If AvFlags("WORKFLOW") .And. lEnvWf // GFP - 19/01/2016 -- RNLP 14-07-20 -- controle de envio de workflow -- quando aprovaçao envio se da pela funcao NU400Efetiva                
               EasyGroupWF("NUMERARIO_EIC",aChaves)
               lEnvWf := .F.
            EndIf

            TRB->(dbSkip())
         EndDo

         EvalTrigger()

      End Transaction

      If lPoint_NU
         ExecBlock("EICPNU01",.F.,.F.,"GRAVOU_EIC")
      EndIf
      IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"GRAVOU_EIC"),)

      *----------------------------------------------------------*
      * FIM DA TRANSACAO                                         *
      *----------------------------------------------------------*
   EndIf
   /* Integração EAI para atualização dos PREs.
      Independente da manutenção das despesas que compõem o numerário,
      será verificado se houve atualização dos provisórios, com base nas aprovações
      ou cancelamento das aprovações.*/
   If AvFlags("EIC_EAI")
      If AvFlags("AVINT_PRE_EIC")
         If Type("oDI500IntProv") == "O"
            oDI500IntProv:Grava()
            oDI500IntProv := AvIntProv():New() //wfs abr/2017 - duplicação de títulos PRE
         EndIf
      EndIf
   EndIf

   Exit
EndDo

TRB->(E_EraseArq(cNomeTemp,if(lEmailDespForn,cIndex,NIL)))    // RS - 04/09/07
IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"FINAL"),)

dbSelectArea(cAliasOld)

Return(Nil)

Static Function addMarkCol(oBrowse)
  Local bMark := {|| markLote({|| msgJaSel()}), oBrowse:Refresh()}

  TRB->(dbGoTop())
  TRB->(dbeval( {|| markInitial() } ))

  ADD MARKCOLUMN oColumn DATA {|| TRB->TRB_MARK } DOUBLECLICK bMark HEADERCLICK {|| mkAllTog(), oBrowse:Refresh()} OF oBrowse
  oBrowse:aColumns[1]:SetTitle(STR0114)
Return

Static Function msgJaSel()
  Local cMsg := STR0112 // A despesa selecionada já foi liberada em XX/XX/XX no lote 'XXXX'
  cMsg := StrTran(cMsg, "{1}", DtoC(TRB->EIC_DT_EFE))
  cMsg := StrTran(cMsg, "{2}", TRB->EIC_CODINT)
  EasyHelp(cMsg)
Return

Static Function markLote(bCantMark)
  Default bCantMark := {||}

  If !Empty(TRB->EIC_DT_EFE)
    Eval(bCantMark)
    Return
  EndIf
  
  If TRB->TRB_MARK == "LBNO" .And. CambFreSeg(TRB->EIC_DESPES)
    EasyHelp(STR0117,STR0090)//"Não é possível marcar esta despesa, pois ela possui câmbio liquidado. Para que seja possível selecionar esta despesa, realize o Estorno da Liquidação na rotina Controle de Câmbio."
    Return
  EndIf

  If TRB->TRB_MARK == "LBOK"
    TRB->TRB_MARK := "LBNO"
  Else
    TRB->TRB_MARK := "LBOK"
  EndIf
Return

// Marca tudo ou desmarca tudo, de acordo com condições
Static Function mkAllTog()
  Local recno := TRB->(RecNo())
  Local nMark := 0
  Local nTotalVld := totalValid(@nMark)

  If nMark < nTotalVld
    markAll()
  ElseIf nMark == nTotalVld
    unmarkAll()
  EndIf
  TRB->(dbGoTo(recno))
Return

Static Function markAll()
  TRB->(dbGoTop())
  While !TRB->(Eof())
    If Empty(TRB->EIC_DT_EFE) .And. !CambFreSeg(TRB->EIC_DESPES)
      mkIfUnmk()
    EndIf
    TRB->(dbSkip())
  EndDo
Return

Static Function unmarkAll()
  TRB->(dbGoTop())
  While !TRB->(Eof())
    If Empty(TRB->EIC_DT_EFE)
      unmkIfMk()
    EndIf
    TRB->(dbSkip())
  EndDo
Return

Static Function markInitial()
  
  If Empty(TRB->EIC_DT_EFE) .And. !CambFreSeg(TRB->EIC_DESPES)
    TRB->TRB_MARK := "LBOK"
  Else
    TRB->TRB_MARK := "LBNO"
  EndIf

Return

Static Function mkIfUnmk()
  If TRB->TRB_MARK == "LBNO" .Or. Empty(TRB->TRB_MARK)
    TRB->TRB_MARK := "LBOK"
  EndIf
Return

Static Function unmkIfMk()
   If TRB->TRB_MARK == "LBOK"
    TRB->TRB_MARK := "LBNO"
  EndIf
Return
/*
 * Retorna o total de registos que não foram liberados
 * Passar por referência o parâmetro nMark para retornar o número de registros marcados
 */
Static Function totalValid(nMark)
  Local nTotal := 0
  Default nMark := 0
  TRB->(dbGoTop())
  While !TRB->(Eof())
    If Empty(TRB->EIC_DT_EFE) .And. !CambFreSeg(TRB->EIC_DESPES)
      nTotal += 1
      If TRB->TRB_MARK == "LBOK"
        nMark += 1
      EndIf
    EndIf
    TRB->(dbSkip())
  EndDo
Return nTotal

Static Function validNoMk()
  Local nMark := 0
    totalValid(@nMark)
  If nMark == 0
    EasyHelp(STR0115)
    Return .F.
  EndIf
Return .T.


Static Function CambFreSeg(cDespesa)
Local lRet    := .F.
Local cQuery  := ""
Local aAreaAtu
Local cAliasWb

If (cDespesa == "102" .And. AvFlags("GERACAO_CAMBIO_FRETE")) .Or. (cDespesa == "103" .And. AvFlags("GERACAO_CAMBIO_SEGURO"))
  
  aAreaAtu := getArea()
  cAliasWb := getNextAlias()
  
  cQuery := " SELECT WB_DESPESA "
  cQuery += " FROM " + RetSQLName("SWB")
  cQuery += " WHERE WB_FILIAL = '" + xFilial("SWB") + "' "
  cQuery += "   AND WB_HAWB	= '" + M->W6_HAWB + "' "
  cQuery += "   AND WB_PO_DI	= 'D' "
  cQuery += "   AND WB_EVENT	= '" + cDespesa + "' "
  cQuery += "   AND WB_CA_DT	<> ' ' "
  cQuery += "   AND D_E_L_E_T_= ' ' "

  EasyQry(cQuery,cAliasWb)

  If (cAliasWb)->(!EOF())
    lRet := .T. //Existe cambio liquidado para a despesa
  EndIf
  (cAliasWb)->(dbCloseArea())
  RestArea(aAreaAtu)

EndIf

Return lRet


*-------------------------------------------*
Function NU400AP100(oDlg,bOk,bCancel)
*-------------------------------------------*
lRet := EICIN100(13,, .T.)
Return(Nil)

*----------------------------------*
Function NU400Enchoice(nOpc)
*----------------------------------*
Local cOper, IP, _nx
Local nAlteraVal:=0
Local aRotinaAux
Local lRet := .T. //MCF 10/09/2014

// variaveis p/ EnChoice
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE bCampo, nCampos := 0
PRIVATE aEnchoice := {} //Nil
PRIVATE aAlteraca := If(nOpc == 3, {}, Nil)
PRIVATE oEnch1 //LRL 02/04/04
If nOpc == 1
   aRotina[2,4]:=3
   cOper       := STR0014  //"Inclusão"
ElseIf nOpc == 2
   aRotina[2,4]:=4
   cOper       := STR0015  //"Alteração"
ElseIf nOpc == 3
   aRotina[2,4]:=6
   cOper       := STR0016  //"Exclusão"
EndIf

bCampo := {|x| Field(x) }
nOpRotina:=nOpc  //Atualização da variável nOpRotina para gravação de campo memo

aRotinaAux := aClone(aRotina)

dbSelectArea("TRB")

If Bof() .And. Eof() .And. nOpc <> 1
   Help(" ",1,"REGNOIS")
   Return(.F.)
EndIf

If Alltrim(TRB->EIC_DESPES) $ "701|702|703"
   if EICCambAut(Alltrim(TRB->EIC_DESPES))
      MsgStop(STR0109,STR0090) //"Despesas 701, 702 ou 703 não podem sofrer manutenção pois são geradas automaticamente pelo sistema para controle de variação cambial do FOB, Frete e Seguro! / Atenção "
      Return(.F.)
   endif
EndIf

While lRet
   nOpcA:=1

	If !Empty(SW6->W6_DT_ENCE) .And. nOpc=1 //MCF 10/09/2014
 		HELP("", 1, "EASY0000000001") //Não  foi possível incluir a despesa, pois o processo já esta encerrado.
  		lRet := .F.
  		Loop
	EndIf


  dbSelectArea("TRB")
   //Alterado por WFS em abr/2017 - exibição do campo de descrição (virtual)
   //For IP := 1 To EIC->(fCount())
   SX3->(DBSetOrder(1)) //X3_ARQUIVO + X3_ORDEM
   SX3->(DBSeek("EIC"))
   While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "EIC"
      //If (nPos:=TRB->(FieldPos(EIC->(Field(IP))))) > 0
      cCpoEIC:= SX3->X3_CAMPO
      If (nPos:= TRB->(FieldPos(cCpoEIC))) > 0
         M->&(EVAL(bCampo,nPos)):=If(nOpc==1,CRIAVAR(TRB->(FIELDNAME(nPos))),TRB->(FieldGet(nPos)))

         // EOS - 18/05/04 - para nao mostrar na enchoice o campo EIC_GERFIN
         //cCpoEIC := EIC->(Field(IP))
         If cCpoEic <> "EIC_GERFIN"
            AADD(aEnchoice, cCpoEIC)
         Elseif nOpc == 1
            M->EIC_GERFIN := "2"
         Endif

         //AHAC - 07/07/2014 - Campos não editaveis qnd integrado com Logix
         If AvFlags("EIC_EAI") .AND. nOpc <> 3 .AND. !(cCpoEIC $ "EIC_PAGOPO / EIC_FORN / EIC_LOJA")
            If(aAlteraca == Nil,aAlteraca := {},)//Inicia array, pois a primeira passada ele será NIL
            aAdd(aAlteraca,cCpoEic)
         EndIf
      EndIf

      SX3->(DBSkip())
   EndDo
   //Next

    //TRP - 23/05/2007
   If EasyEntryPoint("EICNU400")
      ExecBlock("EICNU400",.F.,.F.,"ANTES_ENCHOICE")
   EndIf

      //AHAC - 07/07/2014 - Inclusão do teste da Variável AvFlags("EIC_EAI") (Integração com Logix)
      IF cPaisLoc == "BRA" .AND. ( AvFlags("EIC_EAI") .OR. EasyGParam("MV_EASYFIN",,"N") $ cSim )
         IF nOpc = 1
            SY5->(DBSETORDER(1))
            IF SY5->(DBSEEK(xFilial()+M->W6_DESP))
               M->EIC_FORN:=SY5->Y5_FORNECE
               M->EIC_LOJA:=SY5->Y5_LOJAF
               //oEnch1:Refresh()
            ENDIF

            //AHAC - 07/07/2014 - Valida se Fornecedor ou loja estão em branco na Integração com Logix
            If AvFlags("EIC_EAI") .AND. (Empty(M->EIC_FORN) .OR. Empty(M->EIC_LOJA))
               EasyHelp(STR0089,STR0090) //"Os campos Fornecedor e/ou Loja não foram informados. Acesse o cadastro do Despachante e faça a vinculação à um Fornecedor."###"Atenção"
            EndIf

         ENDIF
      ENDIF

   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG Odlg1 TITLE STR0018+" - "+cOper ;
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL

	     oEnch1:=MsMget():New("EIC",TRB->(Recno()), 2, , , , aEnchoice,{15,1,FINAL_SELECT,COLUNA_FINAL}, aAlteraca, 3,,,, oDlg1,, .T.)

         oDlg1:lMaximized:=.T. //LRL 02/04/04 - Maximiliza Janela MDI.
	     oEnch1:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   ACTIVATE MSDIALOG Odlg1 ON INIT ;
        (EnchoiceBar(Odlg1,;
                  {|| If(!NU100VALID(nOpc), nOpca := 4,;
                      If(nOpc == 3,If(MsgYesNo(STR0017+cOper,; //"Confirma a ExclusÆo ?"
                                        STR0018+" - "+cOper),; //"ExclusÆo de Despesas"
                       (nOpca := 2,Odlg1:End()),), (nOpca := 2,Odlg1:End())))},;
                      {|| nOpca:=1,Odlg1:End()}))//LRL 02/04/04 - Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   If lPoint_NU
      ExecBlock("EICPNU01",.F.,.F.,"MANUT_DESP")
   EndIf
   IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"MANUT_DESP"),)

   If nOpca == 4
      Loop
   ElseIF nOpcA == 2
      If nOpc == 3
         If !Empty(TRB->EIC_DT_EFE)
            Help("", 1, "AVG0000301")//MsgStop(STR0032)
         Else
            nNaoEfet -= TRB->EIC_VALOR
            nTotDesp -= TRB->EIC_VALOR

            If TRB->RECNO != 0
               aAdd(aDeletados,TRB->RECNO)
            Endif
            dbSelectArea("TRB")
            dbDelete()
            dbskip(-1)
            IF Bof()
               dbSkip()
               If Eof()
                  Pack  // Corrige problema do browse qdo nao existe reg. valido.
               Endif
            Endif
         EndIf
      Else
         If nOpc == 1
            RecLock("TRB", .T.)
         EndIf

         For _nX := 1 To EIC->(fCount())
         		 IF _nX == 5
         			   nAlteraVal := TRB->EIC_VALOR
         			ENDIF
            _xConteudo := "M->"+EIC->(FieldName(_nX))
            _xConteudo := &_xConteudo
            _nPos      := TRB->(FieldPos(EIC->(Field(_nX))))
            If _nPos > 0
               TRB->(FieldPut(_nPos, _xConteudo))
            EndIf
         Next
         TRB->TRB_ALI_WT:= "EIC"
         TRB->TRB_MARK := "LBNO"
         TRB->TRB_REC_WT:=  EIC->(Recno())

         If nOpc == 1
            nNaoEfet += TRB->EIC_VALOR
            nTotDesp += TRB->EIC_VALOR
            //Loop
         ElseIf nOpc == 2
            nNaoEfet +=(TRB->EIC_VALOR - nAlteraVal )
            nTotDesp +=(TRB->EIC_VALOR - nAlteraVal )
         EndIf
      EndIf

   Endif


   //TRP - 23/05/2007
   If EasyEntryPoint("EICNU400")
      ExecBlock("EICNU400",.F.,.F.,"GRAVA_MEMO")
   EndIf

   If nOpc == 1 .and. nOpcA == 2
      aRotina := aClone(aRotinaAux)
      Loop
   EndIf

   Exit
End
aRotina[2,4]:=4
Return(Nil)

*------------------------------*
Function NU400Efetiva()
*------------------------------*
LOCAL cEMail:="",aInfo:={},lPri:=.T., _nx:=0
LOCAL nPosAdi := 0    // JBS - 12/05/2004 - OC 0030/04 OS 0707/04
LOCAL nFor    := 0    // JBS - 12/05/2004 - OC 0030/04 OS 0707/04
LOCAL cForn_Loja := 0 // JBS - 12/05/2004 - OC 0030/04 OS 0707/04
Local lRetPE     := .T.
Local aDocto     := {}
Local aChaves
Local lSaiu      := .F.
Local nOldNaoEfet, nOldNaoEfet
Local aSWD102 := {}
Local lAddAdtSWD := .T.
Private nValAdi := 0,nValDeb:=0
Private cCodInt := ""

Private nRec901 := 0 //Usado na Integração com SAP
Private aForDesp:= {} // JBS - 12/05/2004 - OC 0030/04 OS 0707/04

SX3->(dbSetOrder(2))
Private lTemNumera:=(SX3->(dbSeek("WD_NUMERA")))
Private lLoop102 := lLoop103 := .F. //LGS-26/11/2015

SX3->(dbSetOrder(1))
ProcRegua(TRB->(LastRec()))
TRB->(dbGoTop())
cUser:=cEMail:=""
/*   EOS - 18/05/04 - No numerario nao havera mais nenhuma gravacao de titulo no financeiro
IF EasyGParam("MV_EASYFIN",,"N") $ cSim // Jonato OS 1188/03 Ocorrência 0111/03
   DeleImpDesp(SW6->W6_NUMDUP,"PR","DI",.T.)
ENDIF
*/

//TRP - 21/05/2007
If EasyEntryPoint("EICNU400")
   lRetPE := ExecBlock("EICNU400",.F.,.F.,"VALIDA_DESPESAS")
   If ValType(lRetPE) == "L" .And. !lRetPE
      Return
   EndIf
EndIf
if lEmailDespForn
   aEmailForn:={}  // RS - 04/09/07 - Enviar email para os fornecedores
endif

nOldEfetiva:= nEfetiva
nOldNaoEfet:= nNaoEfet

//AAF 02/02/2017 - Tela movida para fora da transação.
If !lExecAut .AND. EasyGParam("MV_EIC0023",,.F.) .AND. !AvFlags("EIC_EAI")
   //RRV - 22/02/2013 - Tela de escolha da data de vencimento dos títulos provisórios de numerário.
  Private dDtVenc    := &(EasyGParam("MV_EIC0024",,"dDataBase"))
  cControle  := "Inclusao"
  DEFINE MSDIALOG oDlgData TITLE "Data de Vencimento"  FROM 156,165 TO 250,450 OF oMainWnd PIXEL
	 @ 0.3,01  TO 3.1,17 LABEL "" OF oDlgData

	 @ 1.0,02 SAY STR0091 //"Data de Vencimento:"
	 @ 1.0,09 MSGET dDtVenc SIZE 50,7

	 @2.5,13 BUTTON STR0092  SIZE 34,11 FONT oDlgData:oFont ACTION (EVAL({|| IF(NaoVazio(dDtVenc),oDlgData:End(),) })) OF oDlgData //"OK"
  ACTIVATE MSDIALOG oDlgData CENTERED
EndIf

//LGS-23/11/2015 - Executa a função para verificar as despesas 102 e 103
NU400Desp('SW6')

Begin Transaction //AHAC - 07/07/2014 - Integração Logix
While !(TRB->(Eof()))
   //LGS-26/11/2015
   If TRB->TRB_MARK == "LBNO"
      TRB->(dbSkip())
      Loop
   EndIf
   If lLoop102 .And. TRB->EIC_DESPES == '102'
      TRB->(DbSkip())
      Loop
   EndIf

   If lLoop103 .And. TRB->EIC_DESPES == '103'
      TRB->(DbSkip())
      Loop
   EndIf

   IncProc("Efetivando Despesas")
   If Empty(TRB->EIC_DT_EFE)
      if lEmailDespForn  .and. ! empty(TRB->EIC_FORN)
         if Ascan(aEmailForn,TRB->EIC_FORN) == 0
	        aadd(aEmailForn,TRB->EIC_FORN)
	     endif
      endif
      If Empty(cCodInt)
         IF FindFunction("AvgNumSeq")//AVGERAL.PRW
            cCodInt := AvgNumSeq("EIC","EIC_CODINT")
         ELSE
            cCodInt := GetSXENum("EIC","EIC_CODINT")
            ConfirmSX8()
         EndIf
      EndIf      

      cCodInt:=LEFT(cCodInt,LEN(EIC->EIC_CODINT))
      If TRB->EIC_PAGOPO # "2" .And. TRB->EIC_BASEAD $ cSIM
         // JBS - 12/05/2004 - Inicio
         cForn_Loja := TRB->(EIC_FORN+EIC_LOJA)
         If Empty(cForn_Loja)
            If SY5->(dbSeek(xFilial("SY5")+M->W6_DESP))
               cForn_Loja := SY5->(Y5_FORNECE+Y5_LOJAF)
            EndIf
         EndIf
         If (nPosAdi:=Ascan(aForDesp,{|x| x[1] == cForn_Loja}))== 0
            aadd(aForDesp,{cForn_Loja,TRB->EIC_VALOR,0})//AWF - 18/07/2014 - 3o Posicao para grava o recno
         Else
            aForDesp[nPosAdi,2] += TRB->EIC_VALOR
         EndIf
         // JBS - 12/05/2004 - Fim
         nValAdi += TRB->EIC_VALOR // Não eliminei para manter compatibilidade com RDmakes - JBS - 12/05/2004
      ElseIf TRB->EIC_PAGOPO $ cNAO .And. TRB->EIC_BASEAD $ cNAO
         nValDeb += TRB->EIC_VALOR
      EndIf
      AADD(aDocto,TRB->EIC_DOCTO)
      lAddAdtSWD := .T.

      If AVFLAGS("EIC_EAI")
         If Len(aSWD102 := NU400At102("GET")) > 0
            SWD->(DbGoto(aSWD102[1]))
            lAddAdtSWD := .F.
            NU400At102("CLR")
         EndIf
      EndIf

      RecLock("SWD", lAddAdtSWD/*.T.*/)
      SWD->WD_FILIAL  := xFilial("SWD")
      SWD->WD_HAWB    := M->W6_HAWB
      SWD->WD_DESPESA := TRB->EIC_DESPES
      SWD->WD_DES_ADI := dDataBase
      SWD->WD_VALOR_R := If(lAddAdtSWD,TRB->EIC_VALOR,SWD->WD_VALOR_R)
      SWD->WD_BASEADI := TRB->EIC_BASEAD
      SWD->WD_INTEGRA := .T.
      SWD->WD_PAGOPOR := TRB->EIC_PAGOPO
      SWD->WD_DA      := IF(M->W6_TIPOFEC='DA','1','2')
      SWD->WD_GERFIN  := TRB->EIC_GERFIN
      SWD->WD_DOCTO   := TRB->EIC_DOCTO
      SWD->WD_CODINT  := cCodInt
      SWD->WD_FORN    := TRB->EIC_FORN
      SWD->WD_LOJA    := TRB->EIC_LOJA

      If lAvIntFinEIC
         SWD->WD_VALOR_R := 0
         SWD->WD_VALOR_A := TRB->EIC_VALOR
         SYB->(dBSeek(xFilial("SYB")+SWD->WD_DESPESA))
         SA2->(dBSeek(xFilial("SA2")+SWD->WD_FORN+SWD->WD_LOJA))
         SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))
         SWD->WD_FGDEBCC := SYB->YB_FGDEBCC
         SWD->WD_FGTITUL := SYB->YB_FGTITUL //"2"  //TRP - 24/10/2012
         SWD->WD_BANCO   := SYT->YT_BANCO
         SWD->WD_AGENCIA := SYT->YT_AGENCIA
         SWD->WD_CONTA   := SYT->YT_CONTA
         SWD->WD_BAN_REC := SA2->A2_BANCO
         SWD->WD_AGE_REC := SA2->A2_AGENCIA
         SWD->WD_CON_REC := SA2->A2_NUMCON
         SWD->WD_LINHA   := DI500SWDLin()
      EndIf
      // ACL 29/05/03 - Para estorno de despesas pelo Desemb./Despesas quando for integrado com SIGAFIN
      If GetNewPar("MV_EASYFIN","N") = "S"
         If lTemNumera
            SWD->WD_NUMERA := .T.
         Endif
      Endif
      If lPoint_NU
         ExecBlock("EICPNU01",.F.,.F.,"GRAVOU_SWD")
      EndIf
      IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"GRAVOU_SWD"),)
      SWD->(MSUNLOCK())

      TRB->EIC_DT_EFE := dDataBase
      TRB->EIC_CODINT := cCodInt
      If !lExecAut
         TRB->EIC_LIBERA := AllTrim(cUserName)
      Else
         If (nPos := aScan(aCabAuto,{|x| x[1] $ "EIC_LIBERA"}) ) # 0
            TRB->EIC_LIBERA := aCabAuto[nPos][2]
         Else
            TRB->EIC_LIBERA := STR0102  //"Rotina Automatica"
         EndIf
      EndIf

      TRB->TRB_RECOLD:= TRB->RECNO
      IF TRB->RECNO == 0
         EIC->(RecLock("EIC",.T.)) // Append com lock
         TRB->RECNO  := EIC->(Recno())
      ELSE
         EIC->(dbGoTo(TRB->RECNO))
         EIC->(RecLock("EIC",.F.))
      ENDIF

      //GFP - 19/05/2011
      If AvFlags("WORKFLOW")
         M->EIC_HAWB := TRB->EIC_HAWB
         M->EIC_DESPES := TRB->EIC_DESPES
         aChaves := {}
         aChaves := EasyGroupWF("NUMERARIO_EIC")
      EndIf

      // Grava campos no EIC ...
      For _nX := 1 To EIC->(fCount())
         If TRB->(FieldPos(EIC->(Field(_nX)))) > 0
            _xConteudo := TRB->(FieldGet(TRB->(FieldPos(EIC->(Field(_nX))))))
            EIC->(FieldPut(_nX, _xConteudo))
         EndIf
      Next
      EIC->EIC_FILIAL := xFilial("EIC")

      IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"GRAVO_EIC"),)

      EIC->(MSUNLOCK())

      If AvFlags("WORKFLOW")  // GFP - 19/01/2016
         EasyGroupWF("NUMERARIO_EIC",aChaves)
      EndIf

      nEfetiva += EIC->EIC_VALOR
      nNaoEfet -= EIC->EIC_VALOR
      IF lPri//Pode ocorrer que um usuario integre apos a liberacao e nao seja o mesmo da primeira integracao
         lPri:=.F.
         PswOrder(1)
         IF PswSeek(ALLTRIM(TRB->EIC_USER),.T.)
            aInfo:= PswRet(1)
            IF LEN(aInfo) > 0 .AND. LEN(aInfo[1]) > 0
               cEMail:=ALLTRIM(aInfo[1][14])
            ENDIF
         ENDIF
      ENDIF

      IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"GRAVOU_TUDO"),)

   EndIf
   TRB->(dbSkip())
EndDo

If lPoint_NU
   ExecBlock("EICPNU01",.F.,.F.,"EFETIVOU")
EndIf
IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"EFETIVOU"),)
TRB->(dbGoTop())

If len(aForDesp) > 0
   For nFor:=1 to len(aForDesp)
      RecLock("SWD", .T.)
      SWD->WD_FILIAL  := xFilial("SWD")
      SWD->WD_HAWB    := M->W6_HAWB
      SWD->WD_DESPESA := "901"
      If !lExecAut .AND. EasyGParam("MV_EIC0023",,.F.) .AND. !AvFlags("EIC_EAI")
         SWD->WD_DES_ADI := dDtVenc //AAF 02/02/2017 - Grava a data digitada pelo usuário.
      Else
         SWD->WD_DES_ADI := dDataBase 
      EndIf
      SWD->WD_VALOR_R := aForDesp[nFor,2]
      SWD->WD_BASEADI := "1"
      SWD->WD_PAGOPOR := "1"
      SWD->WD_FORN    := SubStr(aForDesp[nFor,1],1,len(EIC->EIC_FORN))
      SWD->WD_LOJA    := SubStr(aForDesp[nFor,1],len(EIC->EIC_FORN)+1,len(EIC->EIC_LOJA))
      SWD->WD_DOCTO   := aDocto[nFor] //TRB->EIC_DOCTO      RPM - 04/11/10
      SWD->WD_DA      := IF(M->W6_TIPOFEC='DA','1','2')
      SWD->WD_GERFIN  := IF(AvFlags("EIC_EAI"),"1","2") //AHAC - 07/07/2014 - Integração com logix GerFin = 1, caso contrario sempre 2
      SWD->WD_CODINT  := cCodInt
      If GetNewPar("MV_EASYFIN","N") = "S"
         If lTemNumera
            SWD->WD_NUMERA := .T.
         Endif
      Endif
      nRec901 := SWD->(RECNO())

      If lAvIntFinEIC
         SYB->(dBSeek(xFilial("SYB")+SWD->WD_DESPESA))
         SA2->(dBSeek(xFilial("SA2")+SWD->WD_FORN+SWD->WD_LOJA))
         SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))
         SWD->WD_FGDEBCC := SYB->YB_FGDEBCC
         SWD->WD_FGTITUL := SYB->YB_FGTITUL
         SWD->WD_BANCO   := SYT->YT_BANCO
         SWD->WD_AGENCIA := SYT->YT_AGENCIA
         SWD->WD_CONTA   := SYT->YT_CONTA
         SWD->WD_BAN_REC := SA2->A2_BANCO
         SWD->WD_AGE_REC := SA2->A2_AGENCIA
         SWD->WD_CON_REC := SA2->A2_NUMCON
         SWD->WD_LINHA := DI500SWDLin()
      EndIf

      //AHAC - 07/07/2014 - Integração Logix
      If AvFlags("EIC_EAI")
         SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))
         SWD->WD_BANCO   := SYT->YT_BANCO
         SWD->WD_AGENCIA := SYT->YT_AGENCIA
         SWD->WD_CONTA   := SYT->YT_CONTA
         SWD->WD_DT_VENC := dDataBase
      EndIf

      If lPoint_NU
         ExecBlock("EICPNU01",.F.,.F.,"GRAVOU_ADI")
      EndIf
      IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"GRAVOU_ADI"),)
      SWD->(MSUNLOCK())//Existe um campo sendo gravado na Funcao AVR3Numerario()

      aForDesp[nFor,3]:=SWD->(RECNO())//AWF - 18/07/2014 - Gravando recno para usar no EICFI411.PRW

      If lCallSap
         EasyExRdm("AVR3Numerario", .T.,nRec901)         
      EndIf
   Next nFor

/*   EOS - 18/05/04 - No numerario nao havera mais nenhuma gravacao de titulo no financeiro
IF EasyGParam("MV_EASYFIN",,"N") $ cSim // Jonato OS 1188/03 Ocorrência 0111/03
  EICFI400("NUMERARIO") // Chamada do Fi400 para titulos
//   AVPOS_DI(SW6->W6_HAWB,.T.)
ENDIF
*/



   //AHAC 07/07/2014 - Integração com Logix
   IF AvFlags("EIC_EAI") .AND. !EICFI411("SWD",3)
      DisarmTransaction()
      lSaiu := .T.

      nEfetiva:= nOldEfetiva
      nNaoEfet:= nOldNaoEfet
   ENDIF

ElseIf nValDeb == 0 .And. !len(aForDesp) > 0
   If(!lExecAut,Help("", 1, "AVG0000302"),)//MsgInfo(STR0029) // "Não existem despesas de adiantamento ao despachante efetivar!!!"
   lSaiu:= .T. //RETURN .F.
EndIf

End Transaction //AHAC - 07/07/2014 - Integração Logix

//WFS - movido para fora do controle de transações para que, caso a integração dos provisórios não sejam efetivadas, não impactem na gravação das despesas
IF !lSaiu
   If AvFlags("EIC_EAI")
      If AvFlags("AVINT_PRE_EIC")
         /* A cada efetivação, o sistema efetuará a atualização do oDI500IntProv através do EICFI400("POS_GRV_DI") para
            exclusão do PR e do AvFluxo - AvPos_DI() - para atualização de todos os provisórios. Para que não haja replicação
            de informação, o objeto será reiniciado. */
         If Type("oDI500IntProv") == "O"
            /* comentado por wfs abr/2017 - duplicação de títulos PRE
            If Len(oDI500IntProv:aProvDel) > 0 .Or. Len(oDI500IntProv:aProvInc) > 0
               oDI500IntProv := AvIntProv():New()
            EndIf*/
            oDI500IntProv:DelAllProv(, SW6->W6_HAWB, "PRE")
         EndIf
      EndIf
   Else
      DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.T.)
   EndIf
   EICFI400("POS_GRV_DI","I")
ENDIF

If lSaiu
   TRB->(DBGOTOP())
   DO While !TRB->(EOF())
      IF TRB->EIC_CODINT == cCodInt
         TRB->EIC_DT_EFE := cTod("")
         TRB->EIC_CODINT := ""
         TRB->EIC_LIBERA := ""
         TRB->RECNO      := TRB->TRB_RECOLD //AHAC - 07/08/2014 - Caso a Despesa ja esteja gravada no EIC não pode zerar o RecNo
      EndIf
      TRB->(DBSKIP())
   EndDo
   Return .F.
EndIf


//TRP-04/05/07- Verifica se os parâmetros necessários para confecção do email estão ligados. Se sim pergunta c deseja enviar email.
//If lParamOk  .and. lGeraEmail.and. MsgYesNo(STR0079,STR0080)
Begin Sequence

   IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"EMAIL_LIBERA_ADI"),)

   If lParamOk
      TRB->(dbGoTop())

      if lEmailDespForn
         cSubject  := AllTrim(STR0034+M->W6_REF_DES) //"Liberação de débito automático Ref.Despach. "
	      cSubject2 := AllTrim(STR0053+M->W6_REF_DES) //"Liberação de despesas de numerário Ref.Despach. "
         NU400EmailForn(.F.)
         TRB->(dbsetorder(1))
         Return(nil)
      endif

      //TRP-09/10/07
      If !lExecAut
         If !MsgYesNo(emailMsg()) // Deseja enviar e-mail informativo da liberação ao fornecedor 'XXXX' (Código: YYY Loja: YY)?
            Break
         Endif
      EndIf

      SY4->(msSeek(xFilial("SY4")+SW6->W6_AGENTE))
      SY5->(msSeek(xFilial("SY5")+SW6->W6_DESP))

      nValEfet  := nValEfetDesp := 0
      cTo       := AllTrim(SY5->Y5_EMAIL)+Space(300)
      cCC       := AllTrim(aUsuario[1,14])
      cCC       += If(!empty(cCC) .and. !empty(GetNewPar("MV_EMAILTE","")) ,"," + AllTrim(GetNewPar("MV_EMAILTE","")) ,"") 
      cCC       += If(!empty(cCC) .and. !empty(cEMail),"," + cEMail ,"")
      cCC       += SPACE(300)
      cSubject  := AllTrim(STR0034+M->W6_REF_DES) //"Liberação de débito automático Ref.Despach. "

      cBody := "<HTML>"
      cBody += "<BODY>"
      cBody += "<h2 align=left>"+STR0068 + alltrim(TRB->EIC_DOCTO)+"</h2>"  //"No. do Documento: "
      cBody += "<table border=1 width=70% align=left>"
      cBody +=   "<tbody align=left>"
      cBody +=     "<tr>"  // "Processo: "
      cBody +=          "<th> " + STR0035 +             " </th>"
      cBody +=          "<td> " + AllTrim(SW6->W6_HAWB) + " </td>"
      cBody +=     "</tr>"
      cBody +=     "<tr>" // "Despach."
      cBody +=      	 "<th> " + STR0037 +                                          " </th>"
      cBody +=      	 "<td> " + alltrim(SW6->W6_DESP) +" - " + alltrim(SY5->Y5_NOME) + " </td>"
      cBody +=     "</tr>"
      cBody +=     "<tr>" // "Agente:   "
      cBody +=          "<th> " + STR0038 +                                             " </th>"
      cBody +=          "<td> " + alltrim(SW6->W6_AGENTE)+" - "+alltrim(SY4->Y4_NOME) + " </td>"
      cBody +=     "</tr>"
      cBody +=     "<tr>" // "Efetivado Por: "
      cBody +=          "<th> " + STR0039 +                               " </th>"
      cBody +=          "<td> " + Upper(AllTrim(Substr(cUsuario,7,15))) + " </td>"
      cBody +=     "</tr>"
      cBody +=     "<tr>" // " Data: "
      cBody +=      	   "<th>"+ STR0036 + "</th>"
      cBody +=      	   "<td>"+ DTOC(M->W6_DT_HAWB) +"</td>"
      cBody +=     "</tr>
      cBody +=   "</tbody>"
      cBody += "</table>"
      cBody += "<br><br><br><br><br><br><br><br>"
      cBody += "<hr br=1 color=black width=99% align=center>"
      cBody += "<h2 align=left> "+ STR0040 +" </h2>" //"Despesas liberadas"
      cBody += "<TABLE BORDER=1 WIDTH=80% align=left>"
      cBody += "	<tbody>"
      cBody += "		<TR ALIGN=LEFT>"
      cBody += "			<TH>"+STR0054+"</TH>"  // "Despesa"
      cBody += "			<TH>"+STR0088+"</TH>"  // "Dt.Efet."
      cBody += "			<TH>"+STR0056+"</TH>"  // "Pago Por"
      cBody += "			<TH>"+STR0057+"</TH>"  // "Adiant"
      cBody += "			<TH>"+STR0058+"</TH>"  // "Valor"
      cBody += "			<TH>"+STR0087+"</TH>"  // "Dt.Emissão"
      cBody += "			<TH>"+STR0060+"</TH>"  // "Cod.Integr."
      cBody += "		</TR>"

      if nRec901 # 0
         SWD->(dbgoto(nRec901))
         cTo2      := AllTrim(SY5->Y5_EMAIL)+Space(300)
         cCC2      := AllTrim(aUsuario[1,14])
         cCC2      += If(!empty(cCC2) .and. !empty(GetNewPar("MV_EMAILCP","")) ,"," + AllTrim(GetNewPar("MV_EMAILCP","")) ,"")
         cCC2      += If(!empty(cCC2) .and. !empty(cEMail),"," + cEMail ,"")
         cCC2      += SPACE(300)
         cSubject2 := AllTrim(STR0053+M->W6_REF_DES) //"Liberação de despesas de numerário Ref.Despach. "

         cBody2 := "<HTML>"
         cBody2 += "<BODY>"
         cBody2 += "<h2 align=left>"+STR0068 + alltrim(SWD->WD_DOCTO)+"</h2>"  //"No. do Documento: "
         cBody2 += "<table border=1 width=70% align=left>"
         cBody2 +=   "<tbody align=left>"
         cBody2 +=     "<tr>"  // "Processo: "
         cBody2 +=          "<th> " + STR0035 +             " </th>"
         cBody2 +=          "<td> " + AllTrim(SW6->W6_HAWB) + " </td>"
         cBody2 +=     "</tr>"
         cBody2 +=     "<tr>" // "Despach."
         cBody2 +=      	 "<th> " + STR0037 +                                          " </th>"
         cBody2 +=      	 "<td> " + alltrim(SW6->W6_DESP) +" - " + alltrim(SY5->Y5_NOME) + " </td>"
         cBody2 +=     "</tr>"
         cBody2 +=     "<tr>" // "Agente:   "
         cBody2 +=          "<th> " + STR0038 +                                             " </th>"
         cBody2 +=          "<td> " + alltrim(SW6->W6_AGENTE)+" - "+alltrim(SY4->Y4_NOME) + " </td>"
         cBody2 +=     "</tr>"
         cBody2 +=     "<tr>" // "Efetivado Por: "
         cBody2 +=          "<th> " + STR0039 +                               " </th>"
         cBody2 +=          "<td> " + Upper(AllTrim(Substr(cUsuario,7,15))) + " </td>"
         cBody2 +=     "</tr>"
         cBody2 +=     "<tr>" // " Data: "
         cBody2 +=      	   "<th>"+ STR0036 + "</th>"
         cBody2 +=      	   "<td>"+ DTOC(M->W6_DT_HAWB) +"</td>"
         cBody2 +=     "</tr>
         cBody2 +=   "</tbody>"
         cBody2 += "</table>"
         cBody2 += "<br><br><br><br><br><br><br><br>"
         cBody2 += "<hr br=1 color=black width=99% align=center>"
         cBody2 += "<h2 align=left> "+ STR0040 +" </h2>" //"Despesas liberadas"
         cBody2 += "<TABLE BORDER=1 WIDTH=80% align=left>"
         cBody2 += "	<tbody>"
         cBody2 += "		<TR ALIGN=LEFT>"
         cBody2 += "			<TH>"+STR0054+"</TH>"  // "Despesa"
         cBody2 += "			<TH>"+STR0088+"</TH>"  // "Dt.Efet."
         cBody2 += "			<TH>"+STR0056+"</TH>"  // "Pago Por"
         cBody2 += "			<TH>"+STR0057+"</TH>"  // "Adiant"
         cBody2 += "			<TH>"+STR0058+"</TH>"  // "Valor"
         cBody2 += "			<TH>"+STR0087+"</TH>"  // "Dt.Emissão"
         cBody2 += "			<TH>"+STR0060+"</TH>"  // "Cod.Integr."
         cBody2 += "		</TR>"
      EndIf

      While !(TRB->(Eof()))
         If TRB->EIC_CODINT == cCodInt .And. TRB->EIC_DESPES $ cDebAut .And. TRB->EIC_BASEAD $ cNAO  // II  IPI ICM TX.SISCOMES
            cBody    += "<TR ALIGN=LEFT>"
            cBody    += "<TD>"+TRB->EIC_DESPES+" "+if(SYB->(dbSeek(xFilial()+TRB->EIC_DESPES)),Substr(SYB->YB_DESCR,1,20),"")+"</TD>"
            cBody    += "<TD>"+DTOC(TRB->EIC_DT_DES)+"</TD>"
            cBody    += "<TD>"+BSCXBOX("EIC_PAGOPO", AllTrim(TRB->EIC_PAGOPO))+"</TD>"
            cBody    += "<TD>"+BSCXBOX("EIC_BASEAD", AllTrim(TRB->EIC_BASEAD))+"</TD>"
            cBody    += "<TD>"+TransForm(TRB->EIC_VALOR, AvSx3("EIC_VALOR",AV_PICTURE))+"</TD>" //LRS - 27/08/2015 - Correção do tamanho do campo valor na Impressão
            cBody    += "<TD>"+DTOC(TRB->EIC_DT_EFE)+"</TD>"
            cBody    += "<TD>"+TRB->EIC_CODINT+"</TD>"
            cBody    += "</TR>"
            nValEfet += TRB->EIC_VALOR
         ElseIf nRec901 # 0 .And. TRB->EIC_CODINT == cCodInt .And. TRB->EIC_BASEAD $ cSim .And. AllTrim(TRB->EIC_PAGOPO) $ cSIM // Despesas adiantadas para o despachante
            cBody2   += "<TR ALIGN=LEFT>"
            cBody2   += "<TD>"+TRB->EIC_DESPES+" "+if(SYB->(dbSeek(xFilial()+TRB->EIC_DESPES)),Substr(SYB->YB_DESCR,1,20),"")+"</TD>"
            cBody2   += "<TD>"+DTOC(TRB->EIC_DT_DES)+"</TD>"
            cBody2   += "<TD>"+BSCXBOX("EIC_PAGOPO", AllTrim(TRB->EIC_PAGOPO))+"</TD>"
            cBody2   += "<TD>"+BSCXBOX("EIC_BASEAD", AllTrim(TRB->EIC_BASEAD))+"</TD>"
            cBody2   += "<TD>"+TransForm(TRB->EIC_VALOR, AvSx3("EIC_VALOR",AV_PICTURE))+"</TD>" //LRS - 27/08/2015 - Correção do tamanho do campo valor na Impressão
            cBody2   += "<TD>"+DTOC(TRB->EIC_DT_EFE)+"</TD>"
            cBody2   += "<TD>"+TRB->EIC_CODINT+"</TD>"
            cBody2   += "</TR>"
            nValEfetDesp += TRB->EIC_VALOR
         EndIf
         TRB->(dbSkip())
      EndDo

      If nValEfet > 0
         cBody += "	</tbody>"
         cBody += "</TABLE>"
         cBody += "<br/><br/><br/><br/><br/><br/>"
         cBody += "<hr color=black width=99% align=center>"
      EndIf

      If nValEfetDesp > 0
         cBody2 += "	</tbody>"
         cBody2 += "</TABLE>"
         cBody2 += "<br/><br/><br/><br/><br/><br/>"
         cBody2 += "<hr color=black width=99% align=center>"
      EndIf

      //ER - 05/12/2006
      If EasyEntryPoint("EICNU400")
         ExecBlock("EICNU400",.F.,.F.,"EMAIL")
      EndIf

      If lEmail

         If nValEfet > 0 //.AND. ! EMPTY(cTo)
            cBody += "<h2>" + STR0044 + TransForm(nValEfet    , AvSx3("EIC_VALOR",AV_PICTURE)) + "</h2>" // "TOTAL DEBITO AUTOMATICO LIBERADO"
            cBody += "</BODY>"
            cBody += "</HTML>"

            // SVG - 11/06/2010 -
            If EasyEntryPoint("EICNU400")
               ExecBlock("EICNU400",.F.,.F.,"CBODY_EFETIVA")
            EndIf

            if ! TelaMail(@cTo,@cCC,cSubject)
               return nil
            endif
            IF ! AllTrim(aUsuario[1,14]) $ cCC
               if empty(cCc)
                  cCC := AllTrim(aUsuario[1,14])
               else
                  cCC += ";" + AllTrim(aUsuario[1,14])
               ENDIF
            ENDIF

            oMail := TMailManager():New()
            if lRelSLS
               oMail:SetUseSSL( .T. )
            endif
            if lRelTLS
               oMail:SetUseTLS( .T. )
            endif
            oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
            oMail:SetSmtpTimeOut( nTimeOut )
            
            nErro := oMail:SmtpConnect()
            if nErro <> 0
              cErrorMsg := oMail:GetErrorString( nErro )
              easyhelp("Falha na Conexao com Servidor de E-Mail: "+cErrorMsg,"Erro")
            Else
              if lAutentica
                  nErro := oMail:SmtpAuth( cUserAut,cPassAut )
                  If nErro <> 0
                    cErrorMsg := oMail:GetErrorString( nErro )
                    easyhelp("Falha na Autenticacao do Usuario: "+cErrorMsg,"Erro")
                    oMail:SMTPDisconnect()
                    If nErro <> 0
                      cErrorMsg := oMail:GetErrorString( nErro )
                      easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                    endif
                  endif
              endif

              if nErro == 0 
                oMessage := TMailMessage():New()
                oMessage:Clear()
                oMessage:cFrom                  := cFrom
                oMessage:cTo                    := cTo
                oMessage:cCc                    := cCC
                oMessage:cSubject               := cSubject
                oMessage:cBody                  := cBody

                nErro := oMessage:Send( oMail )
                if nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Falha no Envio de E-Mail: "+cErrorMsg,"Erro")
                EndIf

                oMail:SMTPDisconnect()
                If nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                endif

              endif
            Endif
         EndIf

         If nValEfetDesp > 0 //.AND. ! EMPTY(cTo2)
            cBody2 += "<h2>" + STR0050 + TransForm(nValEfetDesp, AvSx3("EIC_VALOR",AV_PICTURE)) + "</h2>" // "TOTAL ADIANTAMENTO AO DESPACHANTE"
            cBody2 += "</BODY>"
            cBody2 += "</HTML>"

            // SVG - 11/06/2010 -
            If EasyEntryPoint("EICNU400")
               ExecBlock("EICNU400",.F.,.F.,"CBODY2_EFETIVA")
            EndIf

            if ! TelaMail(@cTo2,@cCC2,cSubject2)
               return nil
            endif
            IF ! AllTrim(aUsuario[1,14]) $ cCC2
               if empty(cCc2)
                  cCC2 := AllTrim(aUsuario[1,14])
               else
                  cCC2 += ";" + AllTrim(aUsuario[1,14])
               ENDIF
            ENDIF

            oMail := TMailManager():New()
            if lRelSLS
               oMail:SetUseSSL( .T. )
            endif
            if lRelTLS
               oMail:SetUseTLS( .T. )
            endif
            oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
            oMail:SetSmtpTimeOut( nTimeOut )
            
            nErro := oMail:SmtpConnect()
            if nErro <> 0
              cErrorMsg := oMail:GetErrorString( nErro )
              easyhelp("Falha na Conexao com Servidor de E-Mail: "+cErrorMsg,"Erro")
            Else
              if lAutentica
                  nErro := oMail:SmtpAuth( cUserAut,cPassAut )
                  If nErro <> 0
                    cErrorMsg := oMail:GetErrorString( nErro )
                    easyhelp("Falha na Autenticacao do Usuario: "+cErrorMsg,"Erro")
                    oMail:SMTPDisconnect()
                    If nErro <> 0
                      cErrorMsg := oMail:GetErrorString( nErro )
                      easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                    endif
                  endif
              endif

              if nErro == 0 
                oMessage := TMailMessage():New()
                oMessage:Clear()
                oMessage:cFrom                  := cFrom
                oMessage:cTo                    := cTo2
                oMessage:cCc                    := cCC
                oMessage:cSubject               := cSubject2
                oMessage:cBody                  := cBody2

                nErro := oMessage:Send( oMail )
                if nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Falha no Envio de E-Mail: "+cErrorMsg,"Erro")
                EndIf

                oMail:SMTPDisconnect()
                If nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                endif

              endif
            Endif
         EndIf

      EndIf
   EndIf
End Sequence
Return(Nil)

Static Function emailMsg()
  Local cMsgFornEmail := STR0084 // Deseja enviar e-mail informativo da liberação ao fornecedor 'XXXX' (Código: YYY Loja: YY)?
  cMsgFornEmail := StrTran(cMsgFornEmail, "{1}", Trim(Posicione("SY5", 1, xFilial("SY5")+M->W6_DESP, "Y5_NOME")))
  cMsgFornEmail := StrTran(cMsgFornEmail, "{2}", Trim(Posicione("SY5", 1, xFilial("SY5")+M->W6_DESP, "Y5_COD")))
  cMsgFornEmail := StrTran(cMsgFornEmail, "{3}", Posicione("SY5", 1, xFilial("SY5")+M->W6_DESP, "Y5_LOJAF"))
Return cMsgFornEmail

*-------------------------------*
Static Function NU400CancEfe()
*-------------------------------*
//BHF-19/05/09
Local aOrd := SaveOrd("SWD")
Local cMsg
Local cChave:= ""
Local cDespInt:= ""

Private cCodInt := TRB->EIC_CODINT
cControle := "Cancela" //RRV - 22/02/2013

If TRB->(Bof() .And. Eof())
   Help(" ",1,"REGNOIS")
   Return(.F.)
EndIf

//**BHF-19/05/2009-->Inicio
//Se encontrar titulo, não faz cancelamento, cancelar o PA em Financeiro\Geracao PA, para o titulo.
SWD->(DbSetOrder(1))
If SWD->(DbSeek(xFilial("SWD")+M->W6_HAWB+"901"+DtoS(TRB->EIC_DT_EFE)))

   SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

   //DFS - 09/08/10 - Criação de tratamento para cancelar aprovação na solicitação de Numerário
   Do While !(SWD->(Eof())) .And. SWD->WD_FILIAL+SWD->WD_HAWB == xFilial("SWD")+M->W6_HAWB

      If SWD->WD_CODINT == cCodInt
         cChave:="EIC"+SWD->WD_CTRFIN1+SWD->WD_PARCELA+SWD->WD_TIPO+SWD->WD_FORN+SWD->WD_LOJA
         Exit
      Else
         SWD->(dbSkip())
      EndIf
   EndDo
   If SE2->(DbSeek(xFilial()+cChave))
      cMsg := "Despesa já possui título!" + ENTER
      cMsg += "Faça o cancelamento do PA no Financeiro."
      MsgInfo(cMsg,"Aviso")
      Return .F.
   EndIf
   If	lAvIntFinEIC
      If !Empty(SWD->WD_TITERP)
         cMsg := "Despesa possui Título ERP gerado!" + ENTER
         cMsg += "Envie ou aguarde o processamento do estorno do Título."
         MsgInfo(cMsg,"Aviso")
         Return .F.
      EndIf
      IF !Empty(SWD->WD_CTRLERP)
         cMsg := "Despesa já foi enviada ao ERP para criação do Título!" + ENTER
         cMsg += "Aguarde o retorno do ERP antes de cancelar a aprovação do numerário."
         MsgInfo(cMsg,"Aviso")
         Return .F.
      EndIf
   EndIf

   //AHAC 07/07/2014 - Integração com Logix
   If AvFlags("EIC_EAI") .AND. !Empty(SWD->WD_CTRFIN1) .AND. !EICFI411("SWD",5)
      Return (.F.) //Caso processo integrado e falha no estorno não estorna
   EndIf

EndIf

//LRS - 29/09/2016
SWD->(dbSetOrder(1))
SWD->(dbSeek(xFilial("SWD")+M->W6_HAWB))
DO While !(SWD->(Eof())) .And. !Empty(cCodInt) .And. SWD->WD_FILIAL+SWD->WD_HAWB == xFilial("SWD")+M->W6_HAWB

   IF SWD->WD_CODINT == cCodInt .AND. !Empty(SWD->WD_NF_COMP) .AND. !Empty(SWD->WD_SE_NFC)
       IF MSGYesNo("Existe(m) despesa(s) neste numerário que possuem Nota Fiscal, essas despesas não serão excluidas, deseja cancelar mesmo assim? ","Aviso")
	       Exit
	    Else
	       Return Nil
       EndIF
   Else
       SWD->(dbSkip())
   EndIF
End DO


RestOrd(aOrd,.T.)
//**BHF-->Fim

IF EasyGParam("MV_EASYFIN",,"N") $ cSim
   lNoCanc:=FI400BAIXOU(M->W6_HAWB,cCodInt) //ASK 23/01/08 - Adicionado o parâmetro cCodInt
   IF lNocanc
      EICFI400('MENSAGEM')
      RETURN NIL
   ENDIF
ENDIF

lSair:=.F.
IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"VALIDA_CANCELA_EFETIV"),)
IF lSair
   Return(.F.)
ENDIF

//   EOS - 18/05/04 - No numerario nao havera mais nenhuma gravacao de titulo no financeiro
//IF EasyGParam("MV_EASYFIN",,"N") $ cSim // Jonato OS 1188/03 Ocorrência 0111/03
//   DeleImpDesp(SW6->W6_NUMDUP,"PR","DI",.T.)
//ENDIF
//If lParamOk .and. lGeraEmail .and. MsgYesNo(STR0079,STR0080)
if lEmailDespForn   // RS 04/09/07
   aEmailForn:={}  // RS 04/09/07
endif              // RS 04/09/07

Begin Sequence
   If lParamOk
      TRB->(dbGoTop())

      WHILE lEmailDespForn .and. ! TRB->(EOF())

        If ! Empty(TRB->EIC_DT_EFE) .and. ! empty(TRB->EIC_FORN)
            if Ascan(aEmailForn,TRB->EIC_FORN) == 0
	           aadd(aEmailForn,TRB->EIC_FORN)
	        endif
        endif
        TRB->(dbskip())
      END

      if lEmailDespForn
         cSubject  := AllTrim(STR0045+M->W6_REF_DES) //Space(200)
	     cSubject2 := cSubject
         NU400EmailForn(.F.)
         TRB->(dbsetorder(1))
         break
      endif

      //TRP-09/10/07
      If !MsgYesNo(emailMsg())
         Break
      Endif

      SY4->(msSeek(xFilial("SY4")+SW6->W6_AGENTE))
      SY5->(msSeek(xFilial("SY5")+SW6->W6_DESP))

      nValEfet  := nValEfetDesp := 0
      cTo       := AllTrim(EasyGParam("MV_EMAILCP"))+Space(300)
      cCC       := AllTrim(SY5->Y5_EMAIL)
      cCC       += If(!EMPTY(cCC) .and. !empty(aUsuario[1,14]) ,","+AllTrim(aUsuario[1,14]) ,"")
      cCC       += SPACE(300)
      cSubject  := AllTrim(STR0045+M->W6_REF_DES) //Space(200)

      //-----------------------------//
      // Alterado por Marcos Cesar   //
      // Data.:  20/03/2001          //
      //-----------------------------//

      cBody := "<HTML>"
      cBody += "<BODY>"
      cBody += "<h2 align=left>"+STR0068 + alltrim(TRB->EIC_DOCTO)+"</h2>"  //"No. do Documento: "
      cBody += "<table border=1 width=70% align=left>"
      cBody +=   "<tbody align=left>"
      cBody +=     "<tr>"  // "Processo: "
      cBody +=          "<th> " + STR0035 +             " </th>"
      cBody +=          "<td> " + AllTrim(SW6->W6_HAWB) + " </td>"
      cBody +=     "</tr>"
      cBody +=     "<tr>" // "Despach."
      cBody +=      	 "<th> " + STR0037 +                                          " </th>"
      cBody +=      	 "<td> " + alltrim(SW6->W6_DESP) +" - " + alltrim(SY5->Y5_NOME) + " </td>"
      cBody +=     "</tr>"
      cBody +=     "<tr>" // "Agente:   "
      cBody +=          "<th> " + STR0038 +                                             " </th>"
      cBody +=          "<td> " + alltrim(SW6->W6_AGENTE)+" - "+alltrim(SY4->Y4_NOME) + " </td>"
      cBody +=     "</tr>"
      cBody +=     "<tr>" // "Efetivado Por: "
      cBody +=          "<th> " + STR0039 +                               " </th>"
      cBody +=          "<td> " + Upper(AllTrim(Substr(cUsuario,7,15))) + " </td>"
      cBody +=     "</tr>"
      cBody +=     "<tr>" // " Data: "
      cBody +=      	   "<th>"+ STR0036 + "</th>"
      cBody +=      	   "<td>"+ DTOC(M->W6_DT_HAWB) +"</td>"
      cBody +=     "</tr>
      cBody +=   "</tbody>"
      cBody += "</table>"
      cBody += "<br><br><br><br><br><br><br><br>"
      cBody += "<hr br=1 color=black width=99% align=center>"
      cBody += "<h2 align=left> "+ STR0046 +" </h2>" //"Despesas liberadas"
      cBody += "<TABLE BORDER=1 WIDTH=80% align=left>"
      cBody += "	<tbody>"
      cBody += "		<TR ALIGN=LEFT>"
      cBody += "			<TH>"+STR0054+"</TH>"  // "Despesa"
      cBody += "			<TH>"+STR0088+"</TH>"  // "Dt.Efet."
      cBody += "			<TH>"+STR0056+"</TH>"  // "Pago Por"
      cBody += "			<TH>"+STR0057+"</TH>"  // "Adiant"
      cBody += "			<TH>"+STR0058+"</TH>"  // "Valor"
      cBody += "			<TH>"+STR0087+"</TH>"  // "Dt.Emissão"
      cBody += "			<TH>"+STR0060+"</TH>"  // "Cod.Integr."
      cBody += "		</TR>"

      cTo2      := AllTrim(SY5->Y5_EMAIL)+SPACE(300)
      cCC2      := AllTrim(aUsuario[1,14])//+SPACE(300)
      cCC2      += If(!EMPTY(cCC2) .and. !empty(EasyGParam("MV_EMAILCP")) ,"," + AllTrim(EasyGParam("MV_EMAILCP"))+SPACE(300) ,"")
      cSubject2 := AllTrim(STR0045+M->W6_REF_DES) //Space(200)

      cBody2 := "<HTML>"
      cBody2 += "<BODY>"
      cBody2 += "<h2 align=left>"+STR0068 + alltrim(TRB->EIC_DOCTO)+"</h2>"  //"No. do Documento: "
      cBody2 += "<table border=1 width=70% align=left>"
      cBody2 +=   "<tbody align=left>"
      cBody2 +=     "<tr>"  // "Processo: "
      cBody2 +=          "<th> " + STR0035 +             " </th>"
      cBody2 +=          "<td> " + AllTrim(SW6->W6_HAWB) + " </td>"
      cBody2 +=     "</tr>"
      cBody2 +=     "<tr>" // "Despach."
      cBody2 +=      	 "<th> " + STR0037 +                                          " </th>"
      cBody2 +=      	 "<td> " + alltrim(SW6->W6_DESP) +" - " + alltrim(SY5->Y5_NOME) + " </td>"
      cBody2 +=     "</tr>"
      cBody2 +=     "<tr>" // "Agente:   "
      cBody2 +=          "<th> " + STR0038 +                                             " </th>"
      cBody2 +=          "<td> " + alltrim(SW6->W6_AGENTE)+" - "+alltrim(SY4->Y4_NOME) + " </td>"
      cBody2 +=     "</tr>"
      cBody2 +=     "<tr>" // "Efetivado Por: "
      cBody2 +=          "<th> " + STR0039 +                               " </th>"
      cBody2 +=          "<td> " + Upper(AllTrim(Substr(cUsuario,7,15))) + " </td>"
      cBody2 +=     "</tr>"
      cBody2 +=     "<tr>" // " Data: "
      cBody2 +=      	   "<th>"+ STR0036 + "</th>"
      cBody2 +=      	   "<td>"+ DTOC(M->W6_DT_HAWB) +"</td>"
      cBody2 +=     "</tr>
      cBody2 +=   "</tbody>"
      cBody2 += "</table>"
      cBody2 += "<br><br><br><br><br><br><br><br>"
      cBody2 += "<hr br=1 color=black width=99% align=center>"
      cBody2 += "<h2 align=left> "+ STR0046 +" </h2>" //"Despesas liberadas"
      cBody2 += "<TABLE BORDER=1 WIDTH=80% align=left>"
      cBody2 += "	<tbody>"
      cBody2 += "		<TR ALIGN=LEFT>"
      cBody2 += "			<TH>"+STR0054+"</TH>"  // "Despesa"
      cBody2 += "			<TH>"+STR0088+"</TH>"  // "Dt.Efet."
      cBody2 += "			<TH>"+STR0056+"</TH>"  // "Pago Por"
      cBody2 += "			<TH>"+STR0057+"</TH>"  // "Adiant"
      cBody2 += "			<TH>"+STR0058+"</TH>"  // "Valor"
      cBody2 += "			<TH>"+STR0087+"</TH>"  // "Dt.Emissão"
      cBody2 += "			<TH>"+STR0060+"</TH>"  // "Cod.Integr."
      cBody2 += "		</TR>"

      While !(TRB->(Eof()))
         If TRB->EIC_CODINT == cCodInt .And. TRB->EIC_DESPES $ cDebAut  // II  IPI ICM TX.SISCOMES
            cBody    += "<TR ALIGN=LEFT>"
            cBody    += "<TD>"+TRB->EIC_DESPES+" "+if(SYB->(dbSeek(xFilial()+TRB->EIC_DESPES)),Substr(SYB->YB_DESCR,1,20),"")+"</TD>"
            cBody    += "<TD>"+DTOC(TRB->EIC_DT_DES)+"</TD>"
            cBody    += "<TD>"+BSCXBOX("EIC_PAGOPO", AllTrim(TRB->EIC_PAGOPO))+"</TD>"
            cBody    += "<TD>"+BSCXBOX("EIC_BASEAD", AllTrim(TRB->EIC_BASEAD))+"</TD>"
            cBody    += "<TD>"+TransForm(TRB->EIC_VALOR, AvSx3("EIC_VALOR",AV_PICTURE))+"</TD>" //LRS - 27/08/2015 - Correção do tamanho do campo valor na Impressão
            cBody    += "<TD>"+DTOC(TRB->EIC_DT_EFE)+"</TD>"
            cBody    += "<TD>"+TRB->EIC_CODINT+"</TD>"
            cBody    += "</TR>"
            nValEfet += TRB->EIC_VALOR
         ElseIf TRB->EIC_CODINT == cCodInt .And. TRB->EIC_BASEAD $ cSim .And. AllTrim(TRB->EIC_PAGOPO) $ cSIM // Despesas adiantadas para o despachante
            cBody2       += "<TR ALIGN=LEFT>"
            cBody2       += "<TD>"+TRB->EIC_DESPES+" "+if(SYB->(dbSeek(xFilial()+TRB->EIC_DESPES)),Substr(SYB->YB_DESCR,1,20),"")+"</TD>"
            cBody2       += "<TD>"+DTOC(TRB->EIC_DT_DES)+"</TD>"
            cBody2       += "<TD>"+BSCXBOX("EIC_PAGOPO", AllTrim(TRB->EIC_PAGOPO))+"</TD>"
            cBody2       += "<TD>"+BSCXBOX("EIC_BASEAD", AllTrim(TRB->EIC_BASEAD))+"</TD>"
            cBody2       += "<TD>"+TransForm(TRB->EIC_VALOR, AvSx3("EIC_VALOR",AV_PICTURE))+"</TD>" //LRS - 27/08/2015 - Correção do tamanho do campo valor na Impressão
            cBody2       += "<TD>"+DTOC(TRB->EIC_DT_EFE)+"</TD>"
            cBody2       += "<TD>"+TRB->EIC_CODINT+"</TD>"
            cBody2       += "</TR>"
            nValEfetDesp += TRB->EIC_VALOR
         EndIf
         TRB->(dbSkip())
      EndDo

      If nValEfet > 0
         cBody += "	</tbody>"
         cBody += "</TABLE>"
         cBody += "<br/><br/><br/><br/><br/><br/>"
         cBody += "<hr color=black width=99% align=center>"
      EndIf

      If nValEfetDesp > 0
         cBody2 += "	</tbody>"
         cBody2 += "</TABLE>"
         cBody2 += "<br/><br/><br/><br/><br/><br/>"
         cBody2 += "<hr color=black width=99% align=center>"
      EndIf

      If EasyEntryPoint("EICNU400")
         ExecBlock("EICNU400",.F.,.F.,"EMAIL_CANCELA")
      EndIf

      If lEmail

         If nValEfet > 0 //.AND. ! EMPTY(cTo)
            cBody += "<h2>" + STR0044 + TransForm(nValEfet    , AvSx3("EIC_VALOR",AV_PICTURE)) + "</h2>" // TOTAL DEBITO AUTOMATICO CANCELADO
            cBody += "</BODY>"
            cBody += "</HTML>"

            // SVG - 11/06/2010 -
            If EasyEntryPoint("EICNU400")
               ExecBlock("EICNU400",.F.,.F.,"CBODY_CANC_EFET")
            EndIf

            if ! TelaMail(@cTo,@cCC,cSubject)
               return nil
            endif
            IF ! AllTrim(aUsuario[1,14]) $ cCC
               if empty(cCc)
                  cCC := AllTrim(aUsuario[1,14])
               else
                  cCC += ";" + AllTrim(aUsuario[1,14])
               ENDIF
            ENDIF

            oMail := TMailManager():New()
            if lRelSLS
               oMail:SetUseSSL( .T. )
            endif
            if lRelTLS
               oMail:SetUseTLS( .T. )
            endif
            oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
            oMail:SetSmtpTimeOut( nTimeOut )
            
            nErro := oMail:SmtpConnect()
            if nErro <> 0
              cErrorMsg := oMail:GetErrorString( nErro )
              easyhelp("Falha na Conexao com Servidor de E-Mail: "+cErrorMsg,"Erro")
            Else
              if lAutentica
                  nErro := oMail:SmtpAuth( cUserAut,cPassAut )
                  If nErro <> 0
                    cErrorMsg := oMail:GetErrorString( nErro )
                    easyhelp("Falha na Autenticacao do Usuario: "+cErrorMsg,"Erro")
                    oMail:SMTPDisconnect()
                    If nErro <> 0
                      cErrorMsg := oMail:GetErrorString( nErro )
                      easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                    endif
                  endif
              endif

              if nErro == 0 
                oMessage := TMailMessage():New()
                oMessage:Clear()
                oMessage:cFrom                  := cFrom
                oMessage:cTo                    := cTo
                oMessage:cCc                    := cCC
                oMessage:cSubject               := cSubject
                oMessage:cBody                  := cBody

                nErro := oMessage:Send( oMail )
                if nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Falha no Envio de E-Mail: "+cErrorMsg,"Erro")
                EndIf

                oMail:SMTPDisconnect()
                If nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                endif

              endif
            Endif
         EndIf

         If nValEfetDesp > 0 //.AND. ! EMPTY(cTo2)
            cBody2 += "<h2>" + STR0051 + TransForm(nValEfetDesp, AvSx3("EIC_VALOR",AV_PICTURE)) + "</h2>" // TOTAL ADIANTAMENTO AO DESPACHANTE CANCELADO
            cBody2 += "</BODY>"
            cBody2 += "</HTML>"

           // SVG - 11/06/2010 -
           If EasyEntryPoint("EICNU400")
              ExecBlock("EICNU400",.F.,.F.,"CBODY2_CANC_EFET")
           EndIf

            if ! TelaMail(@cTo2,@cCC2,cSubject2)
               break
            endif
            IF ! AllTrim(aUsuario[1,14]) $ cCC2
               if empty(cCc2)
                  cCC2 := AllTrim(aUsuario[1,14])
               else
                  cCC2 += ";" + AllTrim(aUsuario[1,14])
               ENDIF
            ENDIF

            oMail := TMailManager():New()
            if lRelSLS
               oMail:SetUseSSL( .T. )
            endif
            if lRelTLS
               oMail:SetUseTLS( .T. )
            endif
            oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
            oMail:SetSmtpTimeOut( nTimeOut )
            
            nErro := oMail:SmtpConnect()
            if nErro <> 0
              cErrorMsg := oMail:GetErrorString( nErro )
              easyhelp("Falha na Conexao com Servidor de E-Mail: "+cErrorMsg,"Erro")
            Else
              if lAutentica
                  nErro := oMail:SmtpAuth( cUserAut,cPassAut )
                  If nErro <> 0
                    cErrorMsg := oMail:GetErrorString( nErro )
                    easyhelp("Falha na Autenticacao do Usuario: "+cErrorMsg,"Erro")
                    oMail:SMTPDisconnect()
                    If nErro <> 0
                      cErrorMsg := oMail:GetErrorString( nErro )
                      easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                    endif
                  endif
              endif

              if nErro == 0 
                oMessage := TMailMessage():New()
                oMessage:Clear()
                oMessage:cFrom                  := cFrom
                oMessage:cTo                    := cTo2
                oMessage:cCc                    := cCC
                oMessage:cSubject               := cSubject2
                oMessage:cBody                  := cBody2

                nErro := oMessage:Send( oMail )
                if nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Falha no Envio de E-Mail: "+cErrorMsg,"Erro")
                EndIf

                oMail:SMTPDisconnect()
                If nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                endif

              endif
            Endif
         EndIf
      EndIf
   EndIf
End Sequence

If lPoint_NU
   ExecBlock("EICPNU01",.F.,.F.,"CANC_EFETIV")
EndIf
IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"CANC_EFETIV"),)
aFornec:={}
nCount:=0
ProcRegua(TRB->(LastRec()))
TRB->(dbGoTop())
While !(TRB->(Eof())) .And. !Empty(cCodInt)
   IncProc("Cancelando efetivacao das despesas...")
   If !Empty(TRB->EIC_DT_EFE) .And. TRB->EIC_CODINT == cCodInt
      nCount++
      TRB->EIC_DT_EFE := cTod("")
      TRB->EIC_CODINT := ""
      TRB->EIC_LIBERA := ""
      If EIC->(FieldPos("EIC_ID_APR")) # 0
         TRB->EIC_ID_APR := ""
      EndIf
      IF TRB->RECNO > 0
         EIC->(dbGoTo(TRB->RECNO))
         EIC->(RecLock("EIC",.F.))
         EIC->EIC_DT_EFE := cTod("")
         EIC->EIC_CODINT := ""
         EIC->EIC_LIBERA := ""
         If EIC->(FieldPos("EIC_ID_APR")) # 0
            EIC->EIC_ID_APR := ""
         EndIf
         IF EasyGParam("MV_EASYFIN",,"N") $ cSim
            IF !EMPTY(EIC->EIC_FORN)
               AADD(aFornec,{EIC->EIC_DESPES,EIC->EIC_FORN,EIC->EIC_LOJA})
            ENDIF
         ENDIF
         EIC->(MSUNLOCK())
      ENDIF

      //ER - 05/02/2007
      If EasyEntryPoint("EICNU400")
         ExecBlock("EICNU400",.F.,.F.,"CANCEFE")
      EndIf

      nEfetiva -= EIC->EIC_VALOR
      nNaoEfet += EIC->EIC_VALOR
   EndIf
   TRB->(dbSkip())
EndDo
TRB->(dbGoTop())
ProcRegua(nCount)
SWD->(dbSetOrder(1))
SYB->(DBSetOrder(1))
SWD->(dbSeek(xFilial("SWD")+M->W6_HAWB))
cDespInt:= ""
DO While !(SWD->(Eof())) .And. !Empty(cCodInt) .And. SWD->WD_FILIAL+SWD->WD_HAWB == ;
   xFilial("SWD")+EIC->EIC_HAWB
   IncProc("Cancelando efetivacao das despesas...")
   If SWD->WD_CODINT == cCodInt .AND. (Empty(SWD->WD_NF_COMP) .AND. Empty(SWD->WD_SE_NFC)) //LRS - 29/09/2016

       If (lAvIntFinEIC .AND. SWD->WD_VALOR_R > 0) .AND. Left(SWD->WD_DESPESA,1) <> "9"
         RecLock("SWD", .F.)
         SWD->WD_VALOR_A := 0
         SWD->(MsUnLock())
      Else
         If lPoint_NU
            ExecBlock("EICPNU01",.F.,.F.,"DELETA_ADI")
         EndIf

         If SWD->WD_GERFIN  == "1"

            //WFS 30/08/2014 - exclusão do documento do ERP, quando EAI.
            //O título de adiantamento, neste momento, não existirá mais; a exclusão será realizada no início do processamento
            If AvFlags("EIC_EAI") .AND. !Empty(SWD->WD_CTRFIN1) .And. SubStr(SWD->WD_DESPESA, 1, 1) <> "9"

               //Caso não consiga realizar a exclusão do documento no ERP, não realizará a exclusão da despesa.
               If !EICFI411("SWD", 5)
                  //Armazena a informação para exibir ao usuário
                  SYB->(DBSeek(xFilial() + SWD->WD_DESPESA))
                  cDespInt:= cDespInt + ENTER + AllTrim(SWD->WD_DESPESA) + " - " + AllTrim(SYB->YB_DESCR)
                  SWD->(DBSkip())
                  Loop
               EndIf
            Else
               EICFI400("ESTORNO_DESPESA_DI")
            EndIf
         ENDIF

         IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"DELETA_SWD"),)
         RecLock("SWD", .F.)
         SWD->(dbDelete())
         SWD->(MsUnLock())
      EndIf
   ElseIF SWD->WD_CODINT == cCodInt  //LRS - 29/09/2016
       RecLock("SWD", .F.)
       SWD->WD_CODINT := ""
       SWD->(MsUnLock())
   EndIf
   SWD->(dbSkip())
EndDo

If !Empty(cCodInt)
   If AvFlags("EIC_EAI")
      If AvFlags("AVINT_PRE_EIC")
         If Type("oDI500IntProv") == "O"
            oDI500IntProv:DelAllProv(, M->W6_HAWB, "PRE")
         EndIf
      EndIf
   Else
      //RRV - 22/02/2013 - Tratamento de títulos provisórios de numerário.
      DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.T.)
   EndIf
   EICFI400("POS_GRV_DI","I")
EndIf

//WFS 30/08/2014 - mensagem ao usuário
If !Empty(cDespInt)
   MsgInfo(STR0093 + cDespInt, STR0090) //"Não foi possível realizar a exclusão de uma ou mais despesas. Acesse a rotina de despesas do desembaraço e tente realizar a exclusão individual. Despesa(s): "###"Atenção"
EndIf

Return(Nil)

*-------------------------------*
Static Function NU100VALID(nOpc)
*-------------------------------*
Local lRet := .T.
If nOpc < 3
   If nOpc <> 1 .And. !Empty(TRB->EIC_DT_EFE)
      Help("", 1, "AVG0000303")//MsgInfo(STR0023)   // "Despesas efetivadas não poderão ser alteradas ou excluidas"
      lRet := .F.
   ElseIf !Obrigatorio(aGets,aTela)
      lRet := .F.
   ElseIf M->EIC_DESPES $ "101/104/901/902/903"
      Help("", 1, "AVG0000304")//MsgInfo(STR0052)   // "Este Código de Despesa não pode ser Incluído"
      lRet := .F.

   ElseIf EasyGParam("MV_EASYFIN") == "S" .AND. M->EIC_BASEAD == "1" .AND. (Empty(M->EIC_FORN) .OR. Empty(M->EIC_LOJA))
      EasyHelp(STR0113) // O fornecedor deve ser informado para a geração do pagamento antecipado.
      lRet := .F.
   EndIf

   //AHAC - 07/07/2014 - Valida se Fornecedor ou loja estão em branco na Integração com Logix
   If AvFlags("EIC_EAI") .AND. (Empty(M->EIC_FORN) .OR. Empty(M->EIC_LOJA))
      EasyHelp(STR0094,STR0090) //"Os campos Fornecedor e/ou Loja não foram informados. Acesse o cadastro do Despachante e faça a vinculação à um Fornecedor."###"Atenção"
      lRet := .F.
   EndIf

ElseIf nOpc == 3
   If !Empty(TRB->EIC_DT_EFE)
      Help("", 1, "AVG0000303")//MsgInfo(STR0023)   // "Despesas efetivadas não poderão ser alteradas ou excluidas"
      lRet := .F.
   EndIf
EndIf

If lPoint_NU
   ExecBlock("EICPNU01",.F.,.F.,"VALID")
EndIf
IF(EasyEntryPoint("EICNU400"),Execblock("EICNU400",.F.,.F.,"VALID"),)

Return(lRet)


*-------------------------------*
Function NU100MUDAGET()
*-------------------------------*
LOCAL cVar:=UPPER(ReadVar())

DO CASE
   CASE cVAR=="M->EIC_GERFIN"
        IF M->EIC_BASEAD $ cSIM
           M->EIC_GERFIN := "2"//Nao Precisa perguntar de existe campo (AWR)
           RETURN .F.
        ENDIF
   CASE cVAR=="M->EIC_BASEAD"
        IF M->EIC_BASEAD $ cSIM
           IF !AvFlags("EIC_EAI") //AHAC - 07/07/2014 - Só muda valor do EIC_PAGOPO se não for integrado com Logix
              M->EIC_PAGOPO := "1"
           ENDIF
           M->EIC_GERFIN := "2"  //"1"//Nao Precisa perguntar de existe campo (AWR)
        ELSE
           IF !AvFlags("EIC_EAI") //AHAC - 07/07/2014 - Só muda valor do EIC_PAGOPO se não for integrado com Logix
              M->EIC_PAGOPO := "2"
           ENDIF
        ENDIF
ENDCASE


RETURN .T.


Function NU100ACGET()
//AWR 22/05/2001 tem que "dar" get do fornecedor sempre
//AWR A função tem que existir porque tem em clientes
//IF EasyGParam("MV_EASYFIN",,"N") $ cSim
// IF M->EIC_PAGOPO $ cNAO
//    RETURN .T.
// ELSE
//    RETURN .F.
// ENDIF
//ENDIF
RETURN .T.
*----------------------------------------*
Static Function TelaMail(cTo,cCC,cTitulo)
*----------------------------------------*
Local lRet  := .T.

   DEFINE MSDIALOG oDlgMail TITLE cTitulo FROM 125,122 To 370,678 OF oMainWnd PIXEL

         oPnl:= TPanel():New(0, 0, "", oDlgMail,, .F., .F.,,, 1, 1)
         oPnl:Align:= CONTROL_ALIGN_ALLCLIENT

         @ 5,5  To 079,268   OF oPnl PIXEL
         @ 18,13  Say STR0069  Size 12,8             OF oPnl PIXEL //"De: "
         @ 33,13  Say STR0070  Size 16,8             OF oPnl PIXEL //"Para:"
         @ 52,13  Say STR0071  Size 16,8             OF oPnl PIXEL //"CC:"

         @ 18,33  Get cFrom    Size 233,10  WHEN .F.          OF oPnl PIXEL
         @ 33,33  Get cTo      Size 233,10  VALID VALMAIL(cTo)OF oPnl PIXEL
         @ 52,33  Get cCC      Size 233,10                    OF oPnl PIXEL

   ACTIVATE DIALOG oDlgMail ON INIT EnchoiceBar(oDlgMail, {||lRet:=.T.,oDlgMail:End()}, {||lRet:=.F.,oDlgMail:End()}, ,,,,,,.F.) Centered

Return lRet

*---------------------------*
STATIC FUNCTION VALMAIL(cGet)
*---------------------------*
Local lOK := .T.
IF EMPTY(cGet)
   MsgInfo(STR0072)//"Preencha com um Endereço de E-Mail"
   lOK := .F.
ENDIF
RETURN lOK

*--------------------------------*
Function NU400EmailForn(lReenvia)
*--------------------------------*
Local nI
LOCAL cEMail:=""

if type("nRec901") <> "U"
   SWD->(dbgoto(nRec901))
endif

if type("nRec901")=="U"
   nRec901:=-1
endif

For nI:=1 to LEN(aEmailForn)

   SA2->(dbseek(xFilial("SA2")+aEmailForn[nI]))
   SY4->(msSeek(xFilial("SY4")+SW6->W6_AGENTE))
   SY5->(msSeek(xFilial("SY5")+SW6->W6_DESP))
  
   If !lExecAut
         If !MsgYesNo(STR0085+aEmailForn[nI]+" ?")
         Loop
         Endif
   EndIf
   cUser:=cEMail:=""

   nValEfet  := nValEfetDesp := 0
   cTo       := AllTrim(SA2->A2_EMAIL)+Space(300)
   cCC       := AllTrim(aUsuario[1,14])
   cCC       += If(!empty(cCC) .and. !empty(GetNewPar("MV_EMAILTE","")) ,"," + AllTrim(GetNewPar("MV_EMAILTE","")) ,"")
   cCC       += If(!empty(cCC) .and. !empty(cEMail),"," +cEMail ,"")
   cCC       += SPACE(300)

   cBody := "<HTML>"
   cBody += "<BODY>"
   cBody += "<h2 align=left>"+STR0068 + alltrim(TRB->EIC_DOCTO)+"</h2>"  //"No. do Documento: "
   cBody += "<table border=1 width=70% align=left>"
   cBody +=   "<tbody align=left>"
   cBody +=     "<tr>"  // "Processo: "
   cBody +=          "<th> " + STR0035 +             " </th>"
   cBody +=          "<td> " + AllTrim(SW6->W6_HAWB) + " </td>"
   cBody +=     "</tr>"
   cBody +=     "<tr>" // "Despach."
   cBody +=      	 "<th> " + STR0037 +                                          " </th>"
   cBody +=      	 "<td> " + alltrim(SA2->A2_COD) +" - " + alltrim(SA2->A2_NOME) + " </td>"
   cBody +=     "</tr>"
   cBody +=     "<tr>" // "Agente:   "
   cBody +=          "<th> " + STR0038 +                                             " </th>"
   cBody +=          "<td> " + alltrim(SW6->W6_AGENTE)+" - "+alltrim(SY4->Y4_NOME) + " </td>"
   cBody +=     "</tr>"
   cBody +=     "<tr>" // "Efetivado Por: "
   cBody +=          "<th> " + STR0039 +                               " </th>"
   cBody +=          "<td> " + Upper(AllTrim(Substr(cUsuario,7,15))) + " </td>"
   cBody +=     "</tr>"
   cBody +=     "<tr>" // " Data: "
   cBody +=      	   "<th>"+ STR0036 + "</th>"
   cBody +=      	   "<td>"+ DTOC(M->W6_DT_HAWB) +"</td>"
   cBody +=     "</tr>
   cBody +=   "</tbody>"
   cBody += "</table>"
   cBody += "<br><br><br><br><br><br><br><br>"
   cBody += "<hr br=1 color=black width=99% align=center>"
   cBody += "<h2 align=left> "+ STR0040 +" </h2>" //"Despesas liberadas"
   cBody += "<TABLE BORDER=1 WIDTH=80% align=left>"
   cBody += "	<tbody>"
   cBody += "		<TR ALIGN=LEFT>"
   cBody += "			<TH>"+STR0054+"</TH>"  // "Despesa"
   cBody += "			<TH>"+STR0088+"</TH>"  // "Dt.Efet."
   cBody += "			<TH>"+STR0056+"</TH>"  // "Pago Por"
   cBody += "			<TH>"+STR0057+"</TH>"  // "Adiant"
   cBody += "			<TH>"+STR0058+"</TH>"  // "Valor"
   cBody += "			<TH>"+STR0087+"</TH>"  // "Dt.Emissão"
   cBody += "			<TH>"+STR0060+"</TH>"  // "Cod.Integr."
   cBody += "		</TR>"

  if nRec901 # 0
      cTo2      := AllTrim(SA2->A2_EMAIL)+Space(300)
      cCC2      := AllTrim(aUsuario[1,14])
      cCC2      += If(!empty(cCC2) .and. !empty(GetNewPar("MV_EMAILCP","")) ,"," + AllTrim(GetNewPar("MV_EMAILCP","")),"")
      cCC2      += If(!empty(cCC2) .and. !empty(cEMail),"," + cEMail,"")
      cCC2      += SPACE(300)

      cBody2 := "<HTML>"
      cBody2 += "<BODY>"
      cBody2 += "<h2 align=left>"+STR0068 + alltrim(TRB->EIC_DOCTO)+"</h2>"  //"No. do Documento: "
      cBody2 += "<table border=1 width=70% align=left>"
      cBody2 +=   "<tbody align=left>"
      cBody2 +=     "<tr>"  // "Processo: "
      cBody2 +=          "<th> " + STR0035 +             " </th>"
      cBody2 +=          "<td> " + AllTrim(SW6->W6_HAWB) + " </td>"
      cBody2 +=     "</tr>"
      cBody2 +=     "<tr>" // "Despach."
      cBody2 +=      	 "<th> " + STR0037 +                                          " </th>"
      cBody2 +=      	 "<td> " + alltrim(SA2->A2_COD) +" - " + alltrim(SA2->A2_NOME) + " </td>"
      cBody2 +=     "</tr>"
      cBody2 +=     "<tr>" // "Agente:   "
      cBody2 +=          "<th> " + STR0038 +                                             " </th>"
      cBody2 +=          "<td> " + alltrim(SW6->W6_AGENTE)+" - "+alltrim(SY4->Y4_NOME) + " </td>"
      cBody2 +=     "</tr>"
      cBody2 +=     "<tr>" // "Efetivado Por: "
      cBody2 +=          "<th> " + STR0039 +                               " </th>"
      cBody2 +=          "<td> " + Upper(AllTrim(Substr(cUsuario,7,15))) + " </td>"
      cBody2 +=     "</tr>"
      cBody2 +=     "<tr>" // " Data: "
      cBody2 +=      	   "<th>"+ STR0036 + "</th>"
      cBody2 +=      	   "<td>"+ DTOC(M->W6_DT_HAWB) +"</td>"
      cBody2 +=     "</tr>
      cBody2 +=   "</tbody>"
      cBody2 += "</table>"
      cBody2 += "<br><br><br><br><br><br><br><br>"
      cBody2 += "<hr br=1 color=black width=99% align=center>"
      cBody2 += "<h2 align=left> "+ STR0040 +" </h2>" //"Despesas liberadas"
      cBody2 += "<TABLE BORDER=1 WIDTH=80% align=left>"
      cBody2 += "	<tbody>"
      cBody2 += "		<TR ALIGN=LEFT>"
      cBody2 += "			<TH>"+STR0054+"</TH>"  // "Despesa"
      cBody2 += "			<TH>"+STR0088+"</TH>"  // "Dt.Efet."
      cBody2 += "			<TH>"+STR0056+"</TH>"  // "Pago Por"
      cBody2 += "			<TH>"+STR0057+"</TH>"  // "Adiant"
      cBody2 += "			<TH>"+STR0058+"</TH>"  // "Valor"
      cBody2 += "			<TH>"+STR0087+"</TH>"  // "Dt.Emissão"
      cBody2 += "			<TH>"+STR0060+"</TH>"  // "Cod.Integr."
      cBody2 += "		</TR>"
  EndIf

  TRB->(dbsetorder(2))     // FORN+DESPESA - RS 04/09/07
  TRB->(dbseek(aEmailForn[nI]))

  While !(TRB->(Eof())) .and. TRB->EIC_FORN == aEmailForn[nI]
      If ((lReenvia .OR. TRB->EIC_CODINT == cCodInt) .And. TRB->EIC_DESPES $ cDebAut .And. TRB->EIC_BASEAD $ cNAO) .or. ;
        (nRec901 = -1 .and. (lReenvia .OR. TRB->EIC_CODINT == cCodInt) .And. TRB->EIC_DESPES $ cDebAut )        // II  IPI ICM TX.SISCOMES
        cBody    += "<TR ALIGN=LEFT>"
        cBody    += "<TD>"+TRB->EIC_DESPES+" "+if(SYB->(dbSeek(xFilial()+TRB->EIC_DESPES)),Substr(SYB->YB_DESCR,1,20),"")+"</TD>"
        cBody    += "<TD>"+DTOC(TRB->EIC_DT_DES)+"</TD>"
        cBody    += "<TD>"+BSCXBOX("EIC_PAGOPO", AllTrim(TRB->EIC_PAGOPO))+"</TD>"
        cBody    += "<TD>"+BSCXBOX("EIC_BASEAD", AllTrim(TRB->EIC_BASEAD))+"</TD>"
        cBody    += "<TD>"+TransForm(TRB->EIC_VALOR, AvSx3("EIC_VALOR",AV_PICTURE))+"</TD>" //LRS - 27/08/2015 - Correção do tamanho do campo valor na Impressão
        cBody    += "<TD>"+DTOC(TRB->EIC_DT_EFE)+"</TD>"
        cBody    += "<TD>"+TRB->EIC_CODINT+"</TD>"
        cBody    += "</TR>"
        nValEfet += TRB->EIC_VALOR
      ElseIf nRec901 # 0 .And. (lReenvia .OR.TRB->EIC_CODINT == cCodInt) .And. TRB->EIC_BASEAD $ cSim .And. AllTrim(TRB->EIC_PAGOPO) $ cSIM // Despesas adiantadas para o despachante
        cBody2   += "<TR ALIGN=LEFT>"
        cBody2   += "<TD>"+TRB->EIC_DESPES+" "+if(SYB->(dbSeek(xFilial()+TRB->EIC_DESPES)),Substr(SYB->YB_DESCR,1,20),"")+"</TD>"
        cBody2   += "<TD>"+DTOC(TRB->EIC_DT_DES)+"</TD>"
        cBody2   += "<TD>"+BSCXBOX("EIC_PAGOPO", AllTrim(TRB->EIC_PAGOPO))+"</TD>"
        cBody2   += "<TD>"+BSCXBOX("EIC_BASEAD", AllTrim(TRB->EIC_BASEAD))+"</TD>"
        cBody2   += "<TD>"+TransForm(TRB->EIC_VALOR, AvSx3("EIC_VALOR",AV_PICTURE))+"</TD>" //LRS - 27/08/2015 - Correção do tamanho do campo valor na Impressão
        cBody2   += "<TD>"+DTOC(TRB->EIC_DT_EFE)+"</TD>"
        cBody2   += "<TD>"+TRB->EIC_CODINT+"</TD>"
        cBody2   += "</TR>"
        nValEfetDesp += TRB->EIC_VALOR
      EndIf
      TRB->(dbSkip())
  EndDo

   If nValEfet > 0
      cBody += "	</tbody>"
      cBody += "</TABLE>"
      cBody += "<br/><br/><br/><br/><br/><br/>"
      cBody += "<hr color=black width=99% align=center>"
   EndIf

   If nValEfetDesp > 0
      cBody2 += "	</tbody>"
      cBody2 += "</TABLE>"
      cBody2 += "<br/><br/><br/><br/><br/><br/>"
      cBody2 += "<hr color=black width=99% align=center>"
   EndIf

   //ER - 05/12/2006
   If EasyEntryPoint("EICNU400")
      ExecBlock("EICNU400",.F.,.F.,"EMAIL2")
   EndIf

   If lEmail

      If nValEfet > 0 //.AND. ! EMPTY(cTo)
         cBody += "<h2>" + STR0044 + TransForm(nValEfet    , AvSx3("EIC_VALOR",AV_PICTURE)) + "</h2>" // "TOTAL DEBITO AUTOMATICO LIBERADO"
         cBody += "</BODY>"
         cBody += "</HTML>"

        // SVG - 11/06/2010 -
        If EasyEntryPoint("EICNU400")
            ExecBlock("EICNU400",.F.,.F.,"CBODY_EMAILFORN")
        EndIf

        if ! TelaMail(@cTo,@cCC,cSubject)
            return nil
         endif
        IF ! AllTrim(aUsuario[1,14]) $ cCC // EMPTY(cCC)
            if empty(cCc)
               cCC := AllTrim(aUsuario[1,14])
            else
               cCC += ";" + AllTrim(aUsuario[1,14])
            ENDIF
        ENDIF

        oMail := TMailManager():New()
         if lRelSLS
            oMail:SetUseSSL( .T. )
         endif
         if lRelTLS
            oMail:SetUseTLS( .T. )
         endif
        oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
        oMail:SetSmtpTimeOut( nTimeOut )
        
        nErro := oMail:SmtpConnect()
        if nErro <> 0
          cErrorMsg := oMail:GetErrorString( nErro )
          easyhelp("Falha na Conexao com Servidor de E-Mail: "+cErrorMsg,"Erro")
        Else
          if lAutentica
              nErro := oMail:SmtpAuth( cUserAut,cPassAut )
              If nErro <> 0
                cErrorMsg := oMail:GetErrorString( nErro )
                easyhelp("Falha na Autenticacao do Usuario: "+cErrorMsg,"Erro")
                oMail:SMTPDisconnect()
                If nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                endif
              endif
          endif

          if nErro == 0 
            oMessage := TMailMessage():New()
            oMessage:Clear()
            oMessage:cFrom                  := cFrom
            oMessage:cTo                    := cTo
            oMessage:cCc                    := cCC
            oMessage:cSubject               := cSubject
            oMessage:cBody                  := cBody

            nErro := oMessage:Send( oMail )
            if nErro <> 0
              cErrorMsg := oMail:GetErrorString( nErro )
              easyhelp("Falha no Envio de E-Mail: "+cErrorMsg,"Erro")
            EndIf

            oMail:SMTPDisconnect()
            If nErro <> 0
              cErrorMsg := oMail:GetErrorString( nErro )
              easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
            endif

          endif
        Endif
      EndIf
      //EndIf

      If nValEfetDesp > 0 //.AND. ! EMPTY(cTo2)
         cBody2 += "<h2>" + STR0050 + TransForm(nValEfetDesp, AvSx3("EIC_VALOR",AV_PICTURE)) + "</h2>" // "TOTAL ADIANTAMENTO AO DESPACHANTE"
         cBody2 += "</BODY>"
         cBody2 += "</HTML>"

        // SVG - 11/06/2010 -
        If EasyEntryPoint("EICNU400")
            ExecBlock("EICNU400",.F.,.F.,"CBODY2_EMAILFORN")
        EndIf

        if ! TelaMail(@cTo2,@cCC2,cSubject2)
            return nil
         endif
        IF ! AllTrim(aUsuario[1,14]) $ cCC2
            if empty(cCc2)
               cCC2 := AllTrim(aUsuario[1,14])
            else
               cCC2 += ";" + AllTrim(aUsuario[1,14])
            ENDIF
        ENDIF

        oMail := TMailManager():New()
        if lRelSLS
          oMail:SetUseSSL( .T. )
        endif
        if lRelTLS
          oMail:SetUseTLS( .T. )
        endif
        oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
        oMail:SetSmtpTimeOut( nTimeOut )
        
        nErro := oMail:SmtpConnect()
        if nErro <> 0
          cErrorMsg := oMail:GetErrorString( nErro )
          easyhelp("Falha na Conexao com Servidor de E-Mail: "+cErrorMsg,"Erro")
        Else
          if lAutentica
              nErro := oMail:SmtpAuth( cUserAut,cPassAut )
              If nErro <> 0
                cErrorMsg := oMail:GetErrorString( nErro )
                easyhelp("Falha na Autenticacao do Usuario: "+cErrorMsg,"Erro")
                oMail:SMTPDisconnect()
                If nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                endif
              endif
          endif

          if nErro == 0 
            oMessage := TMailMessage():New()
            oMessage:Clear()
            oMessage:cFrom                  := cFrom
            oMessage:cTo                    := cTo2
            oMessage:cCc                    := cCC2
            oMessage:cSubject               := cSubject2
            oMessage:cBody                  := cBody2

            nErro := oMessage:Send( oMail )
            if nErro <> 0
              cErrorMsg := oMail:GetErrorString( nErro )
              easyhelp("Falha no Envio de E-Mail: "+cErrorMsg,"Erro")
            EndIf

            oMail:SMTPDisconnect()
            If nErro <> 0
              cErrorMsg := oMail:GetErrorString( nErro )
              easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
            endif

          endif
        Endif
      EndIf
  EndIf
Next

Return(nil)
//TRP-09/10/07-Verifica se as datas de efetivação das despesas estão preenchidas.
*--------------------------------*
Static Function NU400VerifDesp()
*--------------------------------*
Local lRetorno := .T.
Local nInc := 0

TRB->(dbGoTop())

While !(TRB->(Eof()))

   If (Empty(TRB->EIC_DT_EFE))
      nInc+= 1
   Endif

   TRB->(DbSkip())

Enddo

If nInc > 0
   lRetorno:= .F.
Endif

Return lRetorno

//TRP-09/10/07- Reenvia email para fornecedor ou despachante.
*--------------------------------*
Static Function NU400ReenvioMail()
*--------------------------------*
LOCAL cEMail:=""

Begin Sequence
   If lParamOk
      TRB->(dbGoTop())

      if lEmailDespForn
         aEmailForn:={}
      endif

      While !(TRB->(Eof()))
         if lEmailDespForn  .and. ! empty(TRB->EIC_FORN)
            if Ascan(aEmailForn,TRB->EIC_FORN) == 0
	           aadd(aEmailForn,TRB->EIC_FORN)
	        endif
         endif

         TRB->(DbSkip())

      Enddo

      if lEmailDespForn
        cSubject  := AllTrim(STR0034+M->W6_REF_DES) //"Liberação de débito automático Ref.Despach. "
	      cSubject2 := AllTrim(STR0053+M->W6_REF_DES) //"Liberação de despesas de numerário Ref.Despach. "

        If LEN(aEmailForn) > 0
          NU400EmailForn(.T.)
        Else
          MsgInfo(STR0108, STR0090) // "Não foi possível reenviar o e-mail. Fornecedor da(s) despesa(s) não informado.", "Atenção"
        EndIf
        TRB->(dbsetorder(1))
        Return(nil)
      endif

      //TRP-09/10/07
      If !MsgYesNo(emailMsg())
         Break
      Endif

      SY4->(msSeek(xFilial("SY4")+SW6->W6_AGENTE))
      SY5->(msSeek(xFilial("SY5")+SW6->W6_DESP))

      TRB->(dbGoTop())
      cUser:=cEMail:=""
      nValEfet  := nValEfetDesp := 0
      cTo       := AllTrim(SY5->Y5_EMAIL)+Space(300)
      cCC       := AllTrim(aUsuario[1,14])
      cCC       += If(!empty(cCC) .and. !empty(GetNewPar("MV_EMAILTE","")) ,"," + AllTrim(GetNewPar("MV_EMAILTE","")) ,"") 
      cCC       += If(!empty(cCC) .and. !empty(cEMail) ,"," + cEMail ,"")
      cCC       += SPACE(300)
      cSubject  := AllTrim(STR0034+M->W6_REF_DES) //"Liberação de débito automático Ref.Despach. "

      cBody := "<HTML>"
      cBody += "<BODY>"
      cBody += "<h2 align=left>"+STR0068 + alltrim(TRB->EIC_DOCTO)+"</h2>"  //"No. do Documento: "
      cBody += "<table border=1 width=70% align=left>"
      cBody +=   "<tbody align=left>"
      cBody +=     "<tr>"  // "Processo: "
      cBody +=          "<th> " + STR0035 +             " </th>"
      cBody +=          "<td> " + AllTrim(SW6->W6_HAWB) + " </td>"
      cBody +=     "</tr>"
      cBody +=     "<tr>" // "Despach."
      cBody +=      	 "<th> " + STR0037 +                                          " </th>"
      cBody +=      	 "<td> " + alltrim(SW6->W6_DESP) +" - " + alltrim(SY5->Y5_NOME) + " </td>"
      cBody +=     "</tr>"
      cBody +=     "<tr>" // "Agente:   "
      cBody +=          "<th> " + STR0038 +                                             " </th>"
      cBody +=          "<td> " + alltrim(SW6->W6_AGENTE)+" - "+alltrim(SY4->Y4_NOME) + " </td>"
      cBody +=     "</tr>"
      cBody +=     "<tr>" // "Efetivado Por: "
      cBody +=          "<th> " + STR0039 +                               " </th>"
      cBody +=          "<td> " + Upper(AllTrim(Substr(cUsuario,7,15))) + " </td>"
      cBody +=     "</tr>"
      cBody +=     "<tr>" // " Data: "
      cBody +=      	   "<th>"+ STR0036 + "</th>"
      cBody +=      	   "<td>"+ DTOC(M->W6_DT_HAWB) +"</td>"
      cBody +=     "</tr>
      cBody +=   "</tbody>"
      cBody += "</table>"
      cBody += "<br><br><br><br><br><br><br><br>"
      cBody += "<hr br=1 color=black width=99% align=center>"
      cBody += "<h2 align=left> "+ STR0040 +" </h2>" //"Despesas liberadas"
      cBody += "<TABLE BORDER=1 WIDTH=80% align=left>"
      cBody += "	<tbody>"
      cBody += "		<TR ALIGN=LEFT>"
      cBody += "			<TH>"+STR0054+"</TH>"  // "Despesa"
      cBody += "			<TH>"+STR0088+"</TH>"  // "Dt.Efet."
      cBody += "			<TH>"+STR0056+"</TH>"  // "Pago Por"
      cBody += "			<TH>"+STR0057+"</TH>"  // "Adiant"
      cBody += "			<TH>"+STR0058+"</TH>"  // "Valor"
      cBody += "			<TH>"+STR0087+"</TH>"  // "Dt.Emissão"
      cBody += "			<TH>"+STR0060+"</TH>"  // "Cod.Integr."
      cBody += "		</TR>"

         cTo2      := AllTrim(SY5->Y5_EMAIL)+Space(300)
         cCC2      := AllTrim(aUsuario[1,14])
         cCC2      += If(!EMPTY(cCC2) .AND. !empty(GetNewPar("MV_EMAILCP","")) ,"," + AllTrim(GetNewPar("MV_EMAILCP",""))  ,"")
         cCC2      += If(!EMPTY(cCC2) .and. !empty(cEMail) ,"," + cEMail ,"")
         cCC2      += SPACE(300)
         cSubject2 := AllTrim(STR0053+M->W6_REF_DES) //"Liberação de despesas de numerário Ref.Despach. "

         cBody2 := "<HTML>"
         cBody2 += "<BODY>"
         cBody2 += "<h2 align=left>"+STR0068 + alltrim(TRB->EIC_DOCTO)+"</h2>"  //"No. do Documento: "
         cBody2 += "<table border=1 width=70% align=left>"
         cBody2 +=   "<tbody align=left>"
         cBody2 +=     "<tr>"  // "Processo: "
         cBody2 +=          "<th> " + STR0035 +             " </th>"
         cBody2 +=          "<td> " + AllTrim(SW6->W6_HAWB) + " </td>"
         cBody2 +=     "</tr>"
         cBody2 +=     "<tr>" // "Despach."
         cBody2 +=      	 "<th> " + STR0037 +                                          " </th>"
         cBody2 +=      	 "<td> " + alltrim(SW6->W6_DESP) +" - " + alltrim(SY5->Y5_NOME) + " </td>"
         cBody2 +=     "</tr>"
         cBody2 +=     "<tr>" // "Agente:   "
         cBody2 +=          "<th> " + STR0038 +                                             " </th>"
         cBody2 +=          "<td> " + alltrim(SW6->W6_AGENTE)+" - "+alltrim(SY4->Y4_NOME) + " </td>"
         cBody2 +=     "</tr>"
         cBody2 +=     "<tr>" // "Efetivado Por: "
         cBody2 +=          "<th> " + STR0039 +                               " </th>"
         cBody2 +=          "<td> " + Upper(AllTrim(Substr(cUsuario,7,15))) + " </td>"
         cBody2 +=     "</tr>"
         cBody2 +=     "<tr>" // " Data: "
         cBody2 +=      	   "<th>"+ STR0036 + "</th>"
         cBody2 +=      	   "<td>"+ DTOC(M->W6_DT_HAWB) +"</td>"
         cBody2 +=     "</tr>
         cBody2 +=   "</tbody>"
         cBody2 += "</table>"
         cBody2 += "<br><br><br><br><br><br><br><br>"
         cBody2 += "<hr br=1 color=black width=99% align=center>"
         cBody2 += "<h2 align=left> "+ STR0040 +" </h2>" //"Despesas liberadas"
         cBody2 += "<TABLE BORDER=1 WIDTH=80% align=left>"
         cBody2 += "	<tbody>"
         cBody2 += "		<TR ALIGN=LEFT>"
         cBody2 += "			<TH>"+STR0054+"</TH>"  // "Despesa"
         cBody2 += "			<TH>"+STR0088+"</TH>"  // "Dt.Efet."
         cBody2 += "			<TH>"+STR0056+"</TH>"  // "Pago Por"
         cBody2 += "			<TH>"+STR0057+"</TH>"  // "Adiant"
         cBody2 += "			<TH>"+STR0058+"</TH>"  // "Valor"
         cBody2 += "			<TH>"+STR0087+"</TH>"  // "Dt.Emissão"
         cBody2 += "			<TH>"+STR0060+"</TH>"  // "Cod.Integr."
         cBody2 += "		</TR>"

      While !(TRB->(Eof()))
         If  TRB->EIC_DESPES $ cDebAut .And. TRB->EIC_BASEAD $ cNAO  // II  IPI ICM TX.SISCOMES
            cBody    += "<TR ALIGN=LEFT>"
            cBody    += "<TD>"+TRB->EIC_DESPES+" "+if(SYB->(dbSeek(xFilial()+TRB->EIC_DESPES)),Substr(SYB->YB_DESCR,1,20),"")+"</TD>"
            cBody    += "<TD>"+DTOC(TRB->EIC_DT_DES)+"</TD>"
            cBody    += "<TD>"+BSCXBOX("EIC_PAGOPO", AllTrim(TRB->EIC_PAGOPO))+"</TD>"
            cBody    += "<TD>"+BSCXBOX("EIC_BASEAD", AllTrim(TRB->EIC_BASEAD))+"</TD>"
            cBody    += "<TD>"+TransForm(TRB->EIC_VALOR, AvSx3("EIC_VALOR",AV_PICTURE))+"</TD>" //LRS - 27/08/2015 - Correção do tamanho do campo valor na Impressão
            cBody    += "<TD>"+DTOC(TRB->EIC_DT_EFE)+"</TD>"
            cBody    += "<TD>"+TRB->EIC_CODINT+"</TD>"
            cBody    += "</TR>"
            nValEfet += TRB->EIC_VALOR
         ElseIf TRB->EIC_BASEAD $ cSim .And. AllTrim(TRB->EIC_PAGOPO) $ cSIM // Despesas adiantadas para o despachante
            cBody2   += "<TR ALIGN=LEFT>"
            cBody2   += "<TD>"+TRB->EIC_DESPES+" "+if(SYB->(dbSeek(xFilial()+TRB->EIC_DESPES)),Substr(SYB->YB_DESCR,1,20),"")+"</TD>"
            cBody2   += "<TD>"+DTOC(TRB->EIC_DT_DES)+"</TD>"
            cBody2   += "<TD>"+BSCXBOX("EIC_PAGOPO", AllTrim(TRB->EIC_PAGOPO))+"</TD>"
            cBody2   += "<TD>"+BSCXBOX("EIC_BASEAD", AllTrim(TRB->EIC_BASEAD))+"</TD>"
            cBody2   += "<TD>"+TransForm(TRB->EIC_VALOR, AvSx3("EIC_VALOR",AV_PICTURE))+"</TD>" //LRS - 27/08/2015 - Correção do tamanho do campo valor na Impressão
            cBody2   += "<TD>"+DTOC(TRB->EIC_DT_EFE)+"</TD>"
            cBody2   += "<TD>"+TRB->EIC_CODINT+"</TD>"
            cBody2   += "</TR>"
            nValEfetDesp += TRB->EIC_VALOR
         EndIf
         TRB->(dbSkip())
      EndDo

      If nValEfet > 0
         cBody += "	</tbody>"
         cBody += "</TABLE>"
         cBody += "<br/><br/><br/><br/><br/><br/>"
         cBody += "<hr color=black width=99% align=center>"
      EndIf

      If nValEfetDesp > 0
         cBody2 += "	</tbody>"
         cBody2 += "</TABLE>"
         cBody2 += "<br/><br/><br/><br/><br/><br/>"
         cBody2 += "<hr color=black width=99% align=center>"
      EndIf

      //ER - 05/12/2006
      If EasyEntryPoint("EICNU400")
         ExecBlock("EICNU400",.F.,.F.,"EMAIL")
      EndIf

      If lEmail

         If nValEfet > 0 //.AND. ! EMPTY(cTo)
            cBody += "<h2>" + STR0044 + TransForm(nValEfet    , AvSx3("EIC_VALOR",AV_PICTURE)) + "</h2>" // "TOTAL DEBITO AUTOMATICO LIBERADO"
            cBody += "</BODY>"
            cBody += "</HTML>"

            // SVG - 11/06/2010 -
            If EasyEntryPoint("EICNU400")
               ExecBlock("EICNU400",.F.,.F.,"CBODY_REEVIOEMAIL")
            EndIf

            if ! TelaMail(@cTo,@cCC,cSubject)
               return nil
            endif
            IF ! AllTrim(aUsuario[1,14]) $ cCC
               if empty(cCc)
                  cCC := AllTrim(aUsuario[1,14])
               else
                  cCC += ";" + AllTrim(aUsuario[1,14])
               ENDIF
            ENDIF

            oMail := TMailManager():New()
            if lRelSLS
               oMail:SetUseSSL( .T. )
            endif
            if lRelTLS
               oMail:SetUseTLS( .T. )
            endif
            oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
            oMail:SetSmtpTimeOut( nTimeOut )
            
            nErro := oMail:SmtpConnect()
            if nErro <> 0
              cErrorMsg := oMail:GetErrorString( nErro )
              easyhelp("Falha na Conexao com Servidor de E-Mail: "+cErrorMsg,"Erro")
            Else
              if lAutentica
                  nErro := oMail:SmtpAuth( cUserAut,cPassAut )
                  If nErro <> 0
                    cErrorMsg := oMail:GetErrorString( nErro )
                    easyhelp("Falha na Autenticacao do Usuario: "+cErrorMsg,"Erro")
                    oMail:SMTPDisconnect()
                    If nErro <> 0
                      cErrorMsg := oMail:GetErrorString( nErro )
                      easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                    endif
                  endif
              endif

              if nErro == 0 
                oMessage := TMailMessage():New()
                oMessage:Clear()
                oMessage:cFrom                  := cFrom
                oMessage:cTo                    := cTo
                oMessage:cCc                    := cCC
                oMessage:cSubject               := cSubject
                oMessage:cBody                  := cBody

                nErro := oMessage:Send( oMail )
                if nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Falha no Envio de E-Mail: "+cErrorMsg,"Erro")
                EndIf

                oMail:SMTPDisconnect()
                If nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                endif

              endif
            Endif
         EndIf
         //EndIf

         If nValEfetDesp > 0 //.AND. ! EMPTY(cTo2)
            cBody2 += "<h2>" + STR0050 + TransForm(nValEfetDesp, AvSx3("EIC_VALOR",AV_PICTURE)) + "</h2>" // "TOTAL ADIANTAMENTO AO DESPACHANTE"
            cBody2 += "</BODY>"
            cBody2 += "</HTML>"

            // SVG - 11/06/2010 -
            If EasyEntryPoint("EICNU400")
               ExecBlock("EICNU400",.F.,.F.,"CBODY2_REEVIOEMAIL")
            EndIf
            if ! TelaMail(@cTo2,@cCC2,cSubject2)
               return nil
            endif
            IF ! AllTrim(aUsuario[1,14]) $ cCC2
               if empty(cCc2)
                  cCC2 := AllTrim(aUsuario[1,14])
               else
                  cCC2 += ";" + AllTrim(aUsuario[1,14])
               ENDIF
            ENDIF

            oMail := TMailManager():New()
            if lRelSLS
               oMail:SetUseSSL( .T. )
            endif
            if lRelTLS
               oMail:SetUseTLS( .T. )
            endif
            oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
            oMail:SetSmtpTimeOut( nTimeOut )
            
            nErro := oMail:SmtpConnect()
            if nErro <> 0
              cErrorMsg := oMail:GetErrorString( nErro )
              easyhelp("Falha na Conexao com Servidor de E-Mail: "+cErrorMsg,"Erro")
            Else
              if lAutentica
                  nErro := oMail:SmtpAuth( cUserAut,cPassAut )
                  If nErro <> 0
                    cErrorMsg := oMail:GetErrorString( nErro )
                    easyhelp("Falha na Autenticacao do Usuario: "+cErrorMsg,"Erro")
                    oMail:SMTPDisconnect()
                    If nErro <> 0
                      cErrorMsg := oMail:GetErrorString( nErro )
                      easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                    endif
                  endif
              endif

              if nErro == 0 
                oMessage := TMailMessage():New()
                oMessage:Clear()
                oMessage:cFrom                  := cFrom
                oMessage:cTo                    := cTo2
                oMessage:cCc                    := cCC2
                oMessage:cSubject               := cSubject2
                oMessage:cBody                  := cBody2

                nErro := oMessage:Send( oMail )
                if nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Falha no Envio de E-Mail: "+cErrorMsg,"Erro")
                EndIf

                oMail:SMTPDisconnect()
                If nErro <> 0
                  cErrorMsg := oMail:GetErrorString( nErro )
                  easyhelp("Erro na Desconexão: "+cErrorMsg,"Erro") 
                endif

              endif
            Endif
         EndIf
      EndIf
   EndIf
End Sequence
Return(Nil)

/*
Função     : MailUser()
Autor      : Rodrigo Mendes Diaz
Data       : 11/12/08
Parâmetros : Nenhum
Retorno    : lRet
Objetivo   : Exibir tela para nova tentativa de login no servidor de SMTP (tratamento copiado da função de Spool de impressão do ERP)
*/
Static Function MailUser()
Local cUser := Space(100)
Local cPsw := Space(30)
Local oDlg
Local lRet := .F.
Local aBtn := Array(2)

DEFINE MSDIALOG oDlg TITLE "Identificação" FROM 0,0 TO 100,200 PIXEL

   oPnl:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 1, 1)
   oPnl:Align:= CONTROL_ALIGN_ALLCLIENT

   @06,05 SAY "Usuário:" OF oPnl PIXEL
   @05,30 GET cUser PIXEL SIZE 70,10 OF oPnl VALID !Empty(cUser)

   @21,05 SAY "Senha:" PIXEL
   @20,30 GET cPsw PIXEL SIZE 70,10 OF oPnl PASSWORD

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If( MailAuth(AllTrim(cUser),AllTrim(cPsw)),;
                                                        (lRet := .T.,oDlg:End()),;
                                                        APMSGSTOP("Usuário ou senha inválido"+Chr(13)+Chr(10)+;
                                                                  "Error:"+AllTrim(MailGetErr()),;
                                                                  OemToAnsi("Atenção")));
                                                },;
                                                {||oDlg:End()},,,,,,,.F.) CENTER

If lRet
   cUserAut := AllTrim(cUser)
   cPassAut := AllTrim(cPsw)
EndIf

Return lRet

/*
Funcao     : CriarEvento
Parametros : Nenhum
Objetivos  : Criar o Evento 151 - "Adiantamento de despesas"
Autor      : WFS
Data/Hora  : 23/08/2014
*/

Static Function CriarEvento()

EC6->(DBSetOrder(1)) //EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC

If !EC6->(DBSeek(xFilial()+ AvKey("IMPORT", "EC6_TPMODU") + AvKey("151", "EC6_ID_CAM")))
   EC6->(RecLock("EC6", .T.))
   EC6->EC6_FILIAL := EC6->(xFilial())
   EC6->EC6_TPMODU := "IMPORT"
   EC6->EC6_ID_CAM := "151"
   EC6->EC6_DESC   := "ADIANTAMENTO DE DESPESAS"
   EC6->(MsUnlock())
EndIf

Return

/*
Funcao     : NU400Desp
Parametros : Nenhum
Objetivos  : Validar as despesas 102 e 103 incluidas pelo numerario
Autor      : Laercio G S Junior
Data/Hora  : 23/11/2015
*/
Function NU400Desp(cDic,lGeraFreWB,lGeraSegWB)
Local aEICDesp  := {}, i, n := 0
Local cMsgInfo  := ""
Local lTem102   := lTem103    := .F.
Local lAtu      := .F.
Local lIndiceSWB:= .T. //MCF - 22/01/2016
Local lDelSwdSw6:= .T.
Local aOrd      := {}
Local lSWB		:= .F.
Local cPict     := "@E 999,999,999.99"
//LRS - 11/08/2016 - Parametro para definir se vai atualizar o valor da despesa, quando é preenchido o valor e taxa, mas sem data vencimento
Local lDespndata := IF(!Empty(M->W6_VLFRECC) .AND. !Empty(M->W6_TX_FRET) .AND. Empty(M->W6_VENCFRE),.T.,.F. )
Local lAtDp102W6 := .F.
Local cAlisSW6 := "SW6" //LRS - 08/05/2017
Static aTRBSWDAtu := {}
Default cDic    := ""
Default lGeraFreWB := .T.
Default lGeraSegWB := .T.

Begin Sequence

      If !Empty(cDic)

         If cDic == "SW6"
            cAlias := "TRB"
            aOrd := SaveOrd({cAlias,"SWD","SWB"})

            If SIX->(DbSeek("SWB7")) //MCF - 22/01/2016
               SWB->(DbSetOrder(7))
            Else
               SWB->(DbSetOrder(1))
               lIndiceSWB := .F.
            EndIf

            If TRB->(DbSeek(SW6->W6_HAWB+'102')) .And. Empty(TRB->EIC_DT_EFE) .And. TRB->TRB_MARK == "LBOK" //-FRETE
              lSWB := .F.
              If AvFlags("GERACAO_CAMBIO_FRETE")
                lSWB := .T.
              EndIf

               AAdd(aEICDesp,{"102", "SW6_102", AvValidFre(,,"SW6") , lSWB })
            EndIf

            If TRB->(DbSeek(SW6->W6_HAWB+'103')) .And. Empty(TRB->EIC_DT_EFE) .And. TRB->TRB_MARK == "LBOK" //-SEGURO
               lSWB := .F.
              If AvFlags("GERACAO_CAMBIO_SEGURO")
                lSWB := .T.
              EndIf

               AAdd(aEICDesp,{"103", "SW6_103", AvValidSeg(,,"SW6"), lSWB })
            EndIf
         
         ElseIF cDic == "EIC" //LRS - 08/05/2017
            cAlias := "EIC"
            aOrd := SaveOrd({cAlias,"SWD"})
            
            If EIC->(DbSeek(xFilial("EIC")+M->W6_HAWB+'102')) .And. !Empty(EIC->EIC_DT_EFE) //-FRETE
               AAdd(aEICDesp,{"102", "SWB", AvValidFre(,,"M"), lSWB }) //MCF - 10/08/2016
            EndIf
            If EIC->(DbSeek(xFilial("EIC")+M->W6_HAWB+'103')) .And. !Empty(EIC->EIC_DT_EFE) //-SEGURO
               AAdd(aEICDesp,{"103", "SWB", AvValidSeg(,,"M"), lSWB })
            EndIf
            
         Else
            cAlias := "EIC"
            aOrd := SaveOrd({cAlias,"SWD"})
            
            If EIC->(DbSeek(xFilial("EIC")+(cAlisSW6)->W6_HAWB+'102')) .And. !Empty(EIC->EIC_DT_EFE) //-FRETE
               AAdd(aEICDesp,{"102", "SWB", AvValidSeg(,,cAlisSW6), lSWB }) //MCF - 10/08/2016
               lGeraFreWB := .F.
            EndIf
            If EIC->(DbSeek(xFilial("EIC")+(cAlisSW6)->W6_HAWB+'103')) .And. !Empty(EIC->EIC_DT_EFE) //-SEGURO
               AAdd(aEICDesp,{"103", "SWB", AvValidSeg(,,cAlisSW6), lSWB })
               lGeraSegWB := .F.
            EndIf
         EndIf       
      Else
         Break
      EndIf

      &(cAlias)->(dbGoTop())
      SWD->(DbSetOrder(1)) //WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)

      For i:=1 To Len(aEICDesp)
        If SWD->(DbSeek(xFilial("SWD") + SW6->W6_HAWB + AvKey(aEICDesp[i][1],"WD_DESPESA") ))
           cMsgInfo += StrTran( StrTran(STR0097,"XXX",aEICDesp[i][1]),"YYYY", AllTrim( Transform(SWD->WD_VALOR_R,cPict) ) ) + ENTER
           If aEICDesp[i][1] == "102"
              lTem102 := .T.
              If AVFLAGS("EIC_EAI")
                 NU400At102("SET")
              EndIf
           Else
              lTem103 := .T.
           EndIf
           n++
        EndIf
      Next

      If cDic == "SWB"
         If Len(aEICDesp) == 0
            aOrd := SaveOrd({"SWB"})

            If SIX->(DbSeek("SWB7")) //MCF - 22/01/2016
               SWB->(DbSetOrder(7))
            Else
               SWB->(DbSetOrder(1))
               lIndiceSWB := .F.
            EndIf

            If lIndiceSWB
               lTem102 := SWB->(DbSeek(xFilial("SWB") + SW6->W6_HAWB + AvKey("102","WB_EVENT") )) .And. Empty(SWB->WB_NUMDUP)
               lTem103 := SWB->(DbSeek(xFilial("SWB") + SW6->W6_HAWB + AvKey("103","WB_EVENT") )) .And. Empty(SWB->WB_NUMDUP)
            Else
               lTem102 := .F.
               SWB->(DbSeek(xFilial("SWB")+SW6->W6_HAWB)) //MCF - 22/01/2016
               Do While SWB->(!Eof()) .And. SWB->WB_HAWB == SW6->W6_HAWB
                  If SWB->WB_EVENT == AvKey("102","WB_EVENT")
                     lTem102 := .T.
                     Exit
                  EndIf
                  SWB->(DbSkip())
               EndDo

               lTem103 := .F.
               SWB->(DbSeek(xFilial("SWB")+SW6->W6_HAWB)) //MCF - 22/01/2016
               Do While SWB->(!Eof()) .And. SWB->WB_HAWB == SW6->W6_HAWB
                  If SWB->WB_EVENT == AvKey("103","WB_EVENT")
                     lTem103 := .T.
                     Exit
                  EndIf
                  SWB->(DbSkip())
               EndDo
            Endif
         EndIf
         cMsgInfo := ""
         lAtu     := .F.
      EndIf

      If !Empty(cMsgInfo)
         lAtu := MsgYesNo( cMsgInfo + ENTER + If(n == 2, STR0099, STR0100) + If(AvFlags("EIC_EAI"),ENTER+"Obs: Caso opte por substituição, a despesa só terá o valor aprovado caso não possua Fornecedor+Loja informados "+;
                                                                                                         " na capa do embarque, pois tais informações remetem ao fato de que a despesa possui título financeiro.","") , STR0090)
         lAtu := If(  AvFlags("EIC_EAI"),;
                      lAtu .And. If(lTem102,Empty(SW6->W6_FORNECF) .And. Empty(SW6->W6_LOJAF),.T.) .And. If(lTem103,Empty(SW6->W6_FORNECS) .And. Empty(SW6->W6_LOJAS),.T.) ,;
                      lAtu )
      EndIf

      Do Case
         Case !lAtu .And. ( lTem102 .Or. lTem103 )
              /**********
              Optou por nao substituir os valores das despesas, por este motivo não seram efetivadas
              ***************************************************************************************/
              If lTem102
                 lLoop102 := .T.
              EndIf
              If lTem103
                 lLoop103 := .T.
              EndIf

         Case lAtu .And. ( lTem102 .Or. lTem103 )
              /**********
              Optou pela substituição das despesas, exclui a parcela no Financeiro (SE2) e na SWD antes de recriar
              ****************************************************************************************************/
              For i:=1 To Len(aEICDesp)

                If !AvFlags("EIC_EAI")  //NCF - 15/12/2016 - Em caso de integração com outro ERP Via Msg. Única, somente atualiza a despesa com o valor do efetivo.

                   If SWD->(DbSeek(xFilial("SWD") + SW6->W6_HAWB + AvKey(aEICDesp[i][1],"WD_DESPESA") )) .And. aEICDesp[i][3] .And. !aEICDesp[i][4]
                      If !FI400TITFIN(aEICDesp[i][2],"4",.T.) //Exclui a Parcela de Frete  do SE2 (Financeiro)
                         MsgInfo( StrTran(STR0098,"XXX",aEICDesp[i][1]), "Atenção")
                         lDelSwdSw6 := .F.
                         If aEICDesp[i][1] == '102'
                            lLoop102 := .T.
                         Else
                            lLoop103 := .T.
                         EndIf
                      EndIf
                      If lDelSwdSw6
                        SWD->(RecLock("SWD",.F.))
                        SWD->(DbDelete())
                        SWD->(MsUnlock())

                        SW6->(RecLock("SW6",.F.))
                        If lTem102 .And. aEICDesp[i][1] == "102" //FRETE
                          SW6->W6_PREFIXF := ""
                          SW6->W6_NUMDUPF := ""
                          SW6->W6_TIPOF   := ""
                          SW6->W6_PARCELF := ""
                        EndIf

                        If lTem103 .And. aEICDesp[i][1] == "103" //SEGURO
                          SW6->W6_PREFIXS := ""
                          SW6->W6_NUMDUPS := ""
                          SW6->W6_TIPOS   := ""
                          SW6->W6_PARCELS := ""
                        EndIf
                        SW6->(MsUnLock())
                      EndIf
                   Else
                      lDelSwdSw6 := .F.
                      SWB->(DbGoTop())
                      SWB->(DbSetOrder(1)) //MCF - 22/01/2016
                      SWB->(DbSeek(xFilial("SWB") + SW6->W6_HAWB))
                      //SWB->(DbSeek(xFilial("SWB") + SW6->W6_HAWB + AvKey(aEICDesp[i][1],"WB_EVENT") ))

                      Do While SWB->(!Eof()) .And. SWB->WB_HAWB == SW6->W6_HAWB
                         //SWB->(DbSetOrder(1))
                         If SWB->WB_EVENT == AvKey(aEICDesp[i][1],"WB_EVENT")
                            If !FI400TITFIN("SWB","4",.T.)
                                MsgInfo( StrTran(STR0098,"XXX",aEICDesp[i][1]), "Atenção")
                                If aEICDesp[i][1] == '102'
                                  lLoop102 := .T.
                                Else
                                  lLoop103 := .T.
                                EndIf
                                Exit
                            EndIf

                            If !SWB->( IsLocked() )
                                SWB->(RecLock("SWB",.F.))
                            EndIf
                            SWB->(DbDelete())
                            SWB->(MsUnlock())
                         EndIf
                         SWB->(DbSkip())
                      EndDo

                      If SWD->(DbSeek(xFilial("SWD") + SW6->W6_HAWB + AvKey(aEICDesp[i][1],"WD_DESPESA") ))
                        If !SWD->( IsLocked() )
                          SWD->(RecLock("SWD",.F.))
                        EndIf
                        SWD->(DbDelete())
                        SWD->(MsUnlock())
                      EndIf
                   EndIF
                Else
                  IF lDespndata
                     lAtDp102W6 := .T.
                     cAliasW6 := "M"
                  ElseIf If( AvFlags("EIC_EAI"), !Empty(SW6->W6_VLFRECC) .AND. !Empty(SW6->W6_TX_FRET) ,.F.)//NCF - 15/12/2016
                     lAtDp102W6 := .T.
                     cAliasW6 := "SW6"
                  EndIf
                   
                  If lAtDp102W6
                     SWD->(DbSeek(xFilial("SWD") + SW6->W6_HAWB + AvKey(aEICDesp[i][1],"WD_DESPESA") ))
                     IF SWD->WD_DESPESA == '102'
                        SWD->(RecLock("SWD",.F.))
                        If cAliasW6 == "M" //wfs abr/2017 - errorlog quando o alias é a memória
                           SWD->WD_VALOR_R := M->W6_VLFRECC * M->W6_TX_FRET
                        Else                         
                           SWD->WD_VALOR_R := (cAliasW6)->W6_VLFRECC * (cAliasW6)->W6_TX_FRET
                        EndIf
                        SWD->(MsUnlock())
                        NU400At102("CNF",SWD->(Recno())) // Confirma alteração da despesa no SWD
	                  EndIF
                  EndIF
                EndIf
              Next
      EndCase

      &(cAlias)->(dbGoTop())
End Sequence

RestOrd(aOrd,.T.)
Return

/*
Funcao     : NU400PreCalc
Parametros : Nenhum
Objetivos  : Apresentar as despesas pré-calculadas para inclusão no numerário.
Autor      : Laercio G S Junior
Data/Hora  : 23/01/2016
*/
*--------------------------*
FUNCTION NU400PreCalc()
*--------------------------*
Local aButtons := {}
Local cMark    := GetMark()
Local nOp      := 0
Local cDespachante
Private lEICNU400 := .T.
Private oMark1

Begin sequence

    cDespachante:= SW6->W6_DESP
    Processa({|| EICTP252({SW6->W6_HAWB,SW6->W6_IMPORT})}, STR0103)//"Lendo despesas do pré-calculo"

    If SELECT("WorkTP") == 0
       MsgInfo(STR0104,STR0090) //"Este processo não possui tabela de pré-calculo associado para geração das previsões"
       Break
    EndIf

    aSemSX3 := { {"WK_FLAG"  , "C", 2,  0},;
    	          {"WK_BASEAD", "C", 20, 0},;
    	          {"WK_PAGOPO", "C", 20, 0},;
    	          {"WK_FILIAL", AvSx3("EIC_FILIAL",AV_TIPO), AvSx3("EIC_FILIAL",AV_TAMANHO), AvSx3("EIC_FILIAL",AV_DECIMAL)}}

    If Select("WorkEIC") == 0
       cNWorkEIC  := E_CriaTrab("EIC",aSemSX3,"WorkEIC")
       IndRegua("WorkEIC",cNWorkEIC+TEOrdBagExt(),"EIC_HAWB+EIC_DESPES+EIC_FORN+EIC_LOJA")
    Else
       AvZap("WorkEIC")
    EndIf

    TB_Campos := { {"WK_FLAG"    ,,,"@!"},;
    	            {"EIC_HAWB"   ,,AVSX3("EIC_HAWB"  ,5),"@!"},;
                   {"EIC_DT_DES" ,,AVSX3("EIC_DT_DES",5)},;
                   {"EIC_DESPES" ,,AVSX3("EIC_DESPES",5),"@!"},;
                   {"EIC_DESCDE" ,,AVSX3("EIC_DESCDE",5),"@!"},;
                   {"EIC_VALOR"  ,,AVSX3("EIC_VALOR" ,5),"@E 99,999,999,999.99"},;
                   {"WK_BASEAD"  ,,AVSX3("EIC_BASEAD",5),"@!"},;
                   {"WK_PAGOPO"  ,,AVSX3("EIC_PAGOPO",5),"@!"},;
                   {"EIC_FORN"   ,,AVSX3("EIC_FORN"  ,5),"@!"},;
                   {"EIC_LOJA"   ,,AVSX3("EIC_LOJA"  ,5),"@!"}}

    WorkTP->(DbGoTop())
    SYB->(DbSetOrder(1))
    WORKEIC->(DBSETORDER(1))
    Do While WorkTp->(!Eof())

       SYB->(DbSeek(xFilial("SYB")+AvKey(WorkTP->WKDESPESA,"YB_DESP")))

       If SYB->YB_DESP == "101" .OR. LEFT(SYB->YB_DESP,1) == "8" .OR. LEFT(SYB->YB_DESP,1) == "9"
          WorkTp->(DbSkip())
          Loop
       EndIf

       /* Despesas que já foram migradas ou já constam no numerário não devem ser enviadas novamente */
       If TRB->(DBSeek(WorkTP->WK_HAWB + WorkTP->WKDESPESA))
          WorkTp->(DBSkip())
          Loop
       EndIf

       IF WORKEIC->(DBSEEK(WorkTP->WK_HAWB + WORKTP->WKDESPESA))
         WorkEIC->(RecLock("WorkEIC", .F.))
         If AllTrim(WorkTP->WKMOEDA) <> BuscaDolar()
            WorkEIC->EIC_VALOR+= WORKTP->WKVLPAGTO2 * (BuscaTaxa(BuscaDolar(),ddatabase,.T.,.F.,.T.)/BuscaTaxa(WorkTP->WKMOEDA,ddatabase,.T.,.F.,.T.))
         Else
            WorkEIC->EIC_VALOR+= WORKTP->WKVLPAGTO2 * BuscaTaxa(BuscaDolar(),ddatabase,.T.,.F.,.T.)
         EndIf
         WorkEIC->(MsUnlock())
       ELSE 
         WorkEIC->(RecLock("WorkEIC", .T.))

         WorkEIC->WK_FILIAL  := xFilial("EIC")
         WorkEIC->EIC_HAWB   := WorkTP->WK_HAWB
         WorkEIC->EIC_DT_DES := WorkTP->WKDT_PAGTO
         WorkEIC->EIC_DESPES := SYB->YB_DESP
         WorkEIC->EIC_DESCDE := SYB->YB_DESCR
         WorkEIC->EIC_BASEAD := "1" //sim
         WorkEIC->WK_BASEAD  := BSCXBOX("EIC_BASEAD", AllTrim(WorkEIC->EIC_BASEAD))
         WorkEIC->EIC_PAGOPO := "1" //despachante
         WorkEIC->WK_PAGOPO  := BSCXBOX("EIC_PAGOPO", AllTrim(WorkEIC->EIC_PAGOPO))

         /*If AllTrim(WorkTP->WKMOEDA) <> "R$"
            WorkEIC->EIC_VALOR:= DITRANS(WorkTP->WKVL_PAGTO * BuscaTaxa(BuscaDolar(),WorkTP->WKDT_PAGTO,.T.,.F.,.T.),2)
         Else
            WorkEIC->EIC_VALOR:= WorkTP->WKVL_PAGTO
         EndIf*/
         /* conversão para reais
            substituição do campo WKVL_PAGTO por WKVLPAGTO2, ficando igual à geração dos títulos provisórios */
         If AllTrim(WorkTP->WKMOEDA) <> BuscaDolar()
            WorkEIC->EIC_VALOR:= WORKTP->WKVLPAGTO2 * (BuscaTaxa(BuscaDolar(),ddatabase,.T.,.F.,.T.)/BuscaTaxa(WorkTP->WKMOEDA,ddatabase,.T.,.F.,.T.))
         Else
            WorkEIC->EIC_VALOR:= WORKTP->WKVLPAGTO2 * BuscaTaxa(BuscaDolar(),ddatabase,.T.,.F.,.T.)
         EndIf

         /* A despesa será base de adiantamento, logo, o fornecedor deve ser o associado ao despachante. */
         SY5->(DBSetOrder(1))
         SY5->(DBSeek(xFilial() + cDespachante))

         WorkEIC->EIC_FORN   := SY5->Y5_FORNECE
         WorkEIC->EIC_LOJA   := SY5->Y5_LOJAF
         WorkEIC->EIC_USER   := cUserName
         WorkEIC->EIC_GERFIN := "2"
         WorkEIC->WK_FLAG    := ""

         WorkEIC->(MsUnlock())
       ENDIF

       If EasyEntryPoint("EICNU400")
          ExecBlock("EICNU400",.F.,.F.,"NU400PRECALC_DESP")
       EndIf

       WorkTp->(DbSkip())
    EndDo

    WorkEIC->(DbGoTop())

    If WorkEIC->(Eof())
       MsgInfo(STR0105,STR0090)//"Não há despesas do pré-calculo para serem incluidas"
       Break
    EndIf

    Aadd(aButtons,{""    ,{|| NU400Mark(cMark,.T.), oMark1:oBrowse:Refresh()},STR0106,STR0106}) //"Marca/Desmarca Todos"

    DEFINE MSDIALOG oDlgPrC TITLE STR0107 FROM oMainWnd:nTop,oMainWnd:nLeft;
                            TO oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL //"Previsões do pré-calculo"
        oDlgPrC:lMaximized := .T.

        oMark1:= MsSelect():New("WorkEIC","WK_FLAG",,TB_Campos,@lInverte,@cMark,PosDLG(oDlgPrC))
        oMark1:bAval:={||NU400Mark(cMark), oMark1:oBrowse:Refresh()}

    ACTIVATE MSDIALOG oDlgPrC ON INIT EnchoiceBar(oDlgPrC, {||nOp:=1, oDlgPrC:End()}, {||nOp:=0, oDlgPrC:End()},,aButtons)

    If nOp == 1
       WorkEIC->(DbGoTop())
       Do While WorkEIC->(!Eof())
          If !Empty(WorkEIC->WK_FLAG)
             TRB->(DbAppend())
             AvReplace("WorkEIC","TRB")
             TRB->TRB_ALI_WT:= "EIC"
             TRB->TRB_REC_WT:=  EIC->(Recno())
             nNaoEfet += WorkEIC->EIC_VALOR
             nTotDesp += WorkEIC->EIC_VALOR
          EndIf
          WorkEIC->(DbSkip())
       EndDo
       TRB->(DbGoTop())
    EndIf

    If !Empty(cNWorkEIC)
       WorkEIC->(E_EraseArq(cNWorkEIC))
    Else
       AvZap("WorkEIC")
       WorkEIC->(DbCloseArea())
    EndIf

    If SELECT("WorkTP") # 0
       AvZap("WorkTP")
       WorkTP->(DbCloseArea())
    EndIf

End sequence
RETURN Nil

Static Function NU400Mark(cMarca, lMTodos)
Default lMTodos := .F.

Begin sequence
	RecLock("WorkEIC",.F.)

	If lMTodos
	   WorkEIC->(DbGoTop())

	   If !Empty(WorkEIC->WK_FLAG)
	      cMarca := ""
	   EndIf

	   Do While WorkEIC->(!Eof())
	      WorkEIC->WK_FLAG := cMarca
	      WorkEIC->(DbSkip())
	   EndDo
	Else
	   If Empty(WorkEIC->WK_FLAG)
	      WorkEIC->WK_FLAG    := cMarca
	   Else
	      WorkEIC->WK_FLAG := ""
	   EndIf
	EndIf

	WorkEIC->(MsUnlock())
	WorkEIC->(DbGoTop())
	oMark1:oBrowse:Refresh()

End sequence
Return .T.



Function NU400At102(cOpc,nRec)

Local aRet := {}, nPos := 0
Default cOpc := ""
Default nRec := 0

If !Empty(cOpc)
   If cOpc == "SET"
      aAdd(aTRBSWDAtu,{SWD->(Recno()),.F.})
   ElseIf cOpc == "GET"
      If Len(aTRBSWDAtu) > 0
         aEval(aTRBSWDAtu,{|x| If(x[2],aRet := aClone(x),)   })
      EndIf
   ElseIf cOpc == "CLR"
      aTRBSWDAtu := {}
   ElseIf cOpc == "CNF"
      If nRec <> 0
         If (nPos := aScan(aTRBSWDAtu,{|x| x[1] == nRec})) > 0
            aTRBSWDAtu[nPos][2] := .T.
         EndIf
      EndIf
   EndIf
EndIf

REturn If(cOpc <> "GET",NIL,aRet)


Function NU400Vld(cCpo)
Local lRet   := .T.
Local aDespVarCamb := {{"701","Variação Cambial FOB"},{"702","Variação Cambial FRETE"},{"703","Variação Cambial SEGURO"}}
Local nPosDesp     := 0
Default cCpo := ""

Do Case
   Case cCpo == "EIC_DESPES"
      If Alltrim(M->EIC_DESPES) $ "701|702|703"
         if EICCambAut(Alltrim(M->EIC_DESPES))
            nPosDesp := aScan( aDespVarCamb , {|x| x[1] == Alltrim(M->EIC_DESPES) } )
            EasyHelp( STR0110 + aDespVarCamb[nPosDesp][1] + STR0111 + aDespVarCamb[nPosDesp][2]  )  //"Não é possível utilizar o código de despesa "" ###  
            lRet := .F.                                                                            //" uma vez que as mesma é utilizada internamente pelo sistema para registro de " ###
         endif
      EndIf
End Case

Return lRet

/*
Funcao     : NU400Cancel()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Processar o cancelamento de um lote de liberação do numerario
Autor      : Tiago Henrique Tudisco dos Santos
Data/Hora  : 05/04/2019
*/
Static Function NU400CanLote()
Local lRet := .T.
If !Empty(TRB->EIC_CODINT)
    If MsgYesNo(STR0031 + " " + TRB->EIC_CODINT, STR0030)
        Processa({||NU400CancEfe() }, STR0024)
    EndIf
Else
    EasyHelp(STR0116)//"Para Cancelar uma Liberação, é necessário selecionar uma Despesa que possua "Lote de Aprovação"."
    lRet:= .F.
EndIf
Return lRet