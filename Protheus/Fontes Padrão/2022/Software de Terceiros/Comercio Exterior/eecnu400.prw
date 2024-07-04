#INCLUDE "EECNU400.ch"
#INCLUDE "AVERAGE.CH"
/*
Programa..: EECNU400
Objetivo..: SOLICITACAO DE NUMERARIO
Autor.....: LUCIANO CAMPOS DE SANTANA
Data/Hora.: 07/11/2001 - 11:51
Obs.......:
*/
#include "EEC.CH"
#include 'ap5mail.ch'
*--------------------------------------------------------------------
FUNCTION EECNU400()
PRIVATE cCADASTRO := STR0001 //"Solicitacao de Numerario"

PswOrder(1)
PswSeek(__CUSERID,.T.)
Private aUsuario    := PswRet(1),;
        cServer     := AllTrim(GetNewPar("MV_RELSERV"," ")),;
        cAccount    := AllTrim(GetNewPar("MV_RELACNT"," ")),;
        cPassword   := AllTrim(GetNewPar("MV_RELPSW" ," ")),;
        lAutentica  := EasyGParam("MV_RELAUTH",,.F.),;    // GFP - 19/07/2012 - Inclusão de Autenticação de Email
        cUserAut    := Alltrim(EasyGParam("MV_RELAUSR",,cAccount)),;
        cPassAut    := Alltrim(EasyGParam("MV_RELAPSW",,cPassword)),;
        cFrom       := IF(!Empty(aUsuario[1][14]), AllTrim(aUsuario[1][14]), AllTrim(aUsuario[1][2])),;             
        lENVIO      := GETNEWPAR("MV_AVG0014",.T.),;
        lEmail      := If(EMPTY(cServer).OR.EMPTY(cAccount).OR.EMPTY(cPassword).OR.EMPTY(cFrom),.F.,.T.),;
        cDebAut     := AllTrim(GetNewPar("MV_AVG0013", " ")),;
        cAttachment := "",;
        lRelTLS     := GetMV("MV_RELTLS"),;
        lRelSLS     := GetMV("MV_RELSSL"),;
        cRelPor     := GetMV("MV_PORSMTP")
Private nTimeOut    := EasyGParam("MV_RELTIME",,120)//Tempo de Espera antes de abortar a Conexão
Private oMail, oMessage, nErro
*
Private lCallSap  := GetNewPar("MV_SAP_INT","N") == "S",;
        lPoint_NU := EasyEntryPoint("EECPNU01"),;
        lParamOk  := !Empty(AllTrim(GetNewPar("MV_RELSERV"," "))) .And.;//Caso os parametros não
                     !Empty(AllTrim(GetNewPar("MV_RELACNT"," "))) .And.;//estejam preenchidos
                     !Empty(AllTrim(GetNewPar("MV_RELPSW" ," ")))        //não envia e-mail.
PRIVATE lNAOALTERA := .T.  //TRP- 15/08/07 - Para incluir uma Nova Despesa através do Botão F3 
PRIVATE cEMAILTE,cEMAILCP
Private aROTINA  := MenuDef()

if at(":",cServer) > 0 .and. Empty(cRelPor)
  cRelPor := val( Substr( cServer , at(":",cServer)+1 , len(cServer) ) )
  cServer := Substr( cServer , 1 , at(":",cServer)-1 )
endif
*
cEMAILTE := ALLTRIM(GETNEWPAR("MV_AVG0015",""))  // E-MAIL DA TESOURARIA
cEMAILTE := IF(cEMAILTE=".","",cEMAILTE)
cEMAILCP := ALLTRIM(GETNEWPAR("MV_AVG0016",""))
cEMAILCP := IF(cEMAILCP=".","",cEMAILCP)
*
DBSELECTAREA("EEC")
EEC->(DBSETORDER(1))
MBROWSE(06,01,22,75,"EEC")
RETURN(NIL)           
 
/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 29/01/07 - 14:21
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  {{STR0002  ,"AxPesqui",0,1},; //"&Pesquisar"
                   {STR0003  ,"EECNUMAN",0,2},; //"&Visualizar"
                   {STR0004  ,"EECNUMAN",0,4}} //"&Manutencao"

If EasyEntryPoint("EECPNU01")
   ExecBlock("EECPNU01",.F.,.F.,"AROTINA")
EndIf
                        
// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("ENU400MNU")
	aRotAdic := ExecBlock("ENU400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

*--------------------------------------------------------------------
FUNCTION EECNUMAN(cP_ALIAS,nP_REG,nP_OPC)
LOCAL nOPC,aPOS,Z,nBTOP,;
      cPICTVAL  := AVSX3("EEC_TOTPED",AV_PICTURE),;
      aORDANT   := SAVEORD({"EEB","EEU","SY5","SYB"}),;
      bOK       := {|| nBTOP := 1,oDLG:End()},;
      bCANCEL   := {|| nBTOP := 0,oDLG:End()}
Local lLoop   // By JPP - 22/08/2005 - 17:50 
Local aDelfile := {}, i
*
PRIVATE cWORKEEU,cPREEMB,cDESPA,nEFETIVA,nNAOEFET,nTOTDESP,;
        aTELA[0,0],aGETS[0],;
        aCAMPOS    := ARRAY(EEU->(FCOUNT())),;
        lINVERTE   := lAltera := .F.,;
        aHEADER    := {},;
        cMARCA     := GETMARK(),;
        aDELETADOS := {},;
        aBUTTONS   := {},;
        oMSELECT,;
        cCpoMarca:=NIL,;
        aSEMSX3   := {{"RECNO","N",7,0}},;
        aCAMPOTRB  := {{{|| TRB->EEU_DESPES+" "+POSICIONE("SYB",1,xFILIAL("SYB")+TRB->EEU_DESPES,"YB_DESCR")},,AVSX3("EEU_DESPES",AV_TITULO),        },;
                       {"EEU_DT_DES"                                                                         ,,AVSX3("EEU_DT_DES",AV_TITULO),        },;
                       {"EEU_VALOR"                                                                          ,,AVSX3("EEU_VALOR" ,AV_TITULO),cPICTVAL},;
                       {{|| iIf(!Empty(TRB->EEU_BASEAD),If(TRB->EEU_BASEAD$cSIM,STR0005,STR0006),"")}        ,,AVSX3("EEU_BASEAD",AV_TITULO),        },; //"Sim"###"Nao" FSM - 26/07/2011
                       {{|| iIf(!Empty(TRB->EEU_PAGOPO),If(TRB->EEU_PAGOPO="1",STR0007,STR0008) ,"")}        ,,AVSX3("EEU_PAGOPO",AV_TITULO),        },; //"Despachente"###"Importador" FSM - 26/07/2011
                       {"EEU_DT_EFE"                                                                         ,,AVSX3("EEU_DT_EFE",AV_TITULO),        },; 
                       {"EEU_LIBERA"                                                                         ,,AVSX3("EEU_LIBERA",AV_TITULO),        }} 
*
//ER - 29/05/2007
Private lGravaAgente := GravaAgente()

//Integração com o Financeiro - WFS 03/02/2010
Private cAliasInt:= "EET",;
        cTipoTit := "",;    
        cFinForn := "",;
        cFinLoja := ""
Private lIntLogix:= AvFlags("EEC_LOGIX") //NCF - 05/08/2014
Private lIntLGXOK:= .T.                  //NCF - 18/08/2014
Private cBancoSE5   := Space(AVSX3("A6_COD",3)),; // MCF - 18/06/2015
		 cAgenciaSE5 := Space(AVSX3("A6_AGENCIA",3)),;
		 cContaSE5   := Space(AVSX3("A6_NUMCON",3)),;
		 cNomeSE5    := Space(AVSX3("A6_NOME",3)),;
     cDTVcSE5    := dDataBase
Private cNaturezaPA := ""
IF lPoint_NU
   ExecBlock("EECPNU01",.F.,.F.,"BROW_EEU")
EndIf
BEGIN SEQUENCE
   IF EEC->EEC_STATUS = ST_PC
      MSGSTOP(STR0009,STR0010) //"Processo de exportacao cancelado !"###"Aviso"
      BREAK
   ENDIF
   BUSCAEMPRESA(EEC->EEC_PREEMB,OC_EM,CD_DES)
   
   If !lGravaAgente
      IF EEB->(EOF() .OR. BOF())
         MSGSTOP(STR0011,STR0010) //"Processo nao tem depachante cadastrado "###"Aviso"
         BREAK
      ENDIF
   EndIf
   
   cDESPA := EEB->(EEB_CODAGE+"-"+EEB_NOME)
   IF nP_OPC = 3
      IF !EEC->(RECLOCK("EEC",.F.,,.T.)) // by CAF 20/07/2005 - 4o. parametro
         Break
      Endif
      AADD(aBUTTONS,{"BUDGET" ,{|| EECNULIB()          ,oMSELECT:oBrowse:Refresh()},STR0023}) // Efetivar
      AADD(aBUTTONS,{"IC_17"  ,{|| EECNUCAN()          ,oMSELECT:oBrowse:Refresh()},STR0024}) // Cancelar Efetivacao/ Canc. Efet.
      AADD(aBUTTONS,{"BMPINCLUIR" /*"EDIT"*/,{|| EECNUIAE("I",nP_OPC),oMSELECT:oBrowse:Refresh()},STR0012}) //"Incluir"
      AADD(aBUTTONS,{"EDIT" /*"ALT_CAD"*/   ,{|| EECNUIAE("A",nP_OPC),oMSELECT:oBrowse:Refresh()},STR0013}) //"Alterar"
      AADD(aBUTTONS,{"EXCLUIR",{|| EECNUIAE("E",nP_OPC),oMSELECT:oBrowse:Refresh()},STR0014}) //"Excluir"
   ENDIF
   
   //TRP - 27/01/07 - Campos do WalkThru
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
   
   IF lPOINT_NU
      EXECBLOCK("EECPNU01",.F.,.F.,"ENCHOICE_BAR")
   ENDIF

   cWORKEEU  := E_CRIATRAB("EEU",aSEMSX3,"TRB")
   
   If TRB->(FieldPos("EEU_POSIC")) > 0 //MCF - 30/07/2014
   	  //INDREGUA("TRB",cWORKEEU+OrdBagExt(),"EEU_DESPES+STR(EEU_POSIC,4,0)","AllwayTrue()","AllwaysTrue()",STR0015) //"Processando Arquivo"     	  
      FileTRB1:= E_Create(,.F.)
      IndRegua("TRB", FileTRB1+TEOrdBagExt(),"EEU_DESPES+STR(EEU_POSIC,4,0)")
      AADD(aDelFile,{,FileTRB1})
   Else
	  //INDREGUA("TRB",cWORKEEU+OrdBagExt(),"EEU_DESPES","AllwayTrue()","AllwaysTrue()",STR0015) //"Processando Arquivo" 
      FileTRB1:= E_Create(,.F.)
      IndRegua("TRB", FileTRB1+TEOrdBagExt(),"EEU_DESPES")
      AADD(aDelFile,{,FileTRB1})	  
   EndIf
   
   If lIntLogix             //NCF - 18/08/2014
      //INDREGUA("TRB",cWORKEEU+OrdBagExt(),"STR(RECNO,7,0)","AllwayTrue()","AllwaysTrue()",STR0015) //"Processando Arquivo"
      FileTRB2:= E_Create(,.F.)
      IndRegua("TRB",FileTRB2+TEOrdBagExt(),"STR(RECNO,7,0)")
      AADD(aDelFile,{,FileTRB2}) 
      //LRS - 22/10/2014
      SET INDEX TO (FileTRB1+TEOrdBagExt()),(FileTRB2+TEOrdBagExt())
   Else   
      SET INDEX TO (FileTRB1+TEOrdBagExt())
   EndIf
   
   nEFETIVA := nNAOEFET := nTOTDESP := 0
   EEU->(DBSETORDER(1))
   EEU->(DBSEEK(XFILIAL("EEU")+EEC->EEC_PREEMB))
   DO WHILE ! EEU->(EOF()) .AND.;
      EEU->(EEU_FILIAL+EEU_PREEMB) = (XFILIAL("EEU")+EEC->EEC_PREEMB)
      *
      TRB->(DBAPPEND())
      AVREPLACE("EEU","TRB")
      TRB->RECNO := EEU->(Recno())
      EECNUSOMA("A")
      TRB->TRB_ALI_WT:= "EEU"
      TRB->TRB_REC_WT:= EEU->(Recno())
      EEU->(DBSKIP())
   ENDDO
   TRB->(DBGOTOP())
   FOR Z := 1 TO EEU->(FCOUNT())
       M->&(EEU->(FIELDNAME(Z))) := EEU->(FIELDGET(Z))
   NEXT
   *
   nBTOP := 0
   bMarca:= {|| EECNUIAE("A",nP_OPC),oMSELECT:oBrowse:Refresh(),oDLG:REFRESH()}
   lTela:=.T.
   IF lPOINT_NU
      EXECBLOCK("EECPNU01",.F.,.F.,"INICIA_VARIAVEIS")
   ENDIF
   
   // by CRF 27/10/2010 - 15:20
   aCAMPOTRB := AddCpoUser(aCAMPOTRB,"EEU","2")


   DEFINE MSDIALOG oDlg TITLE STR0016 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Manutencao"
      aPOS    := POSDLGDOWN(oDLG)
      aPOS[1] := 85
      
      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //LRS - 25/03/2015 - Correção de telas.
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
      IF lTela
         @ 15,010 SAY STR0017                           OF oPanel  PIXEL //"Embarque:"
         @ 15,060 MSGET EEC->EEC_PREEMB  SIZE 80,08 WHEN(.F.) OF oPanel PIXEL
         @ 15,160 SAY STR0018                         OF oPanel PIXEL //"Despachante:"
         @ 15,210 MSGET cDESPA           SIZE 80,08 WHEN(.F.)OF oPanel PIXEL
         *
         @ 28,010 SAY STR0019                                     OF oPanel  PIXEL //"Vlr.Aprovado:"
         @ 28,060 MSGET nEFETIVA      PICTURE cPICTVAL SIZE 80,08 WHEN(.F.)OF oPanel PIXEL
         @ 28,160 SAY STR0020                                  OF oPanel PIXEL //"Vlr.Nao Aprovado:"
         @ 28,210 MSGET nNAOEFET      PICTURE cPICTVAL SIZE 80,08 WHEN(.F.)OF oPanel PIXEL
         *
         @ 41,010 SAY STR0021+EEC->EEC_MOEDA+":"                        OF oPanel PIXEL //"Vlr.Merc. "
         @ 41,060 MSGET EEC->EEC_TOTPED PICTURE cPICTVAL SIZE 80,08 WHEN(.F.)OF oPanel PIXEL
         @ 41,160 SAY STR0022                                    OF oPanel PIXEL //"Vlr.Tot.Despesas:"  
         @ 41,210 MSGET nTOTDESP        PICTURE cPICTVAL SIZE 80,08 WHEN(.F.)OF oPanel PIXEL
      *
      ENDIF
      
      IF lPOINT_NU
         EXECBLOCK("EECPNU01",.F.,.F.,"TELA_MANUT")
      ENDIF

      oMSELECT := MSSELECT():New("TRB",cCpoMarca,,aCAMPOTRB,@lInverte,@cMarca,aPOS)
      oMSELECT:BAVAL := bMarca
      oDlg:lMaximized := .T.
      *
   ACTIVATE MSDIALOG oDlg ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
   IF nBTOP = 1 .AND. nP_OPC = 3 .AND. If(lIntLogix,lIntLGXOK,.T.)         //NCF - 18/08/2014
      FOR Z := 1 To Len(aDeletados)
          EEU->(DBGOTO(aDeletados[Z]))
          EEU->(RecLock("EEU",.F.))
          EEU->(dbDelete())
          EEU->(MSUnlock())
      NEXT
      TRB->(dbGoTop())
      DO While ! TRB->(Eof())
         // By JPP - 22/08/2005 - 17:50 - Inclusão do ponto de entrada.
         IF EasyEntryPoint("EECPNU01")
            lLoop := Execblock("EECPNU01",.F.,.F.,"PE_INI_GRV_TRB")
            If ValType(lLoop) == "L" .And. lLoop
               TRB->(dbSkip())
               LOOP
            ENDIF
         EndIf
         
         IF TRB->RECNO = 0
            EEU->(RecLock("EEU",.T.)) // Append com lock
         ELSE
            EEU->(dbGoTo(TRB->RECNO))
            EEU->(RecLock("EEU",.F.))
         ENDIF
         // Grava campos no EEU ...
         AVREPLACE("TRB","EEU")
         EEU->EEU_FILIAL := xFilial("EEU")
         EEU->EEU_PREEMB := EEC->EEC_PREEMB
         If lPoint_NU
            ExecBlock("EECPNU01",.F.,.F.,"GRAVOU_DESP")
         EndIf
         EEU->(MSUNLOCK())
         TRB->(dbSkip())
      EndDo
      If lPoint_NU
         ExecBlock("EECPNU01",.F.,.F.,"GRAVOU_EEU")
      EndIf
   ENDIF 
   TRB->(E_EraseArq(cWorkEEU))
   
   FOR i := 1 TO LEN(aDelFile)                          //NCF - 18/08/2014
      cAlias:=aDelFile[i,1]
      cArq  :=aDelFile[i,2]
      IF cAlias # NIL
         (cAlias)->(E_EraseArq(cArq))
      ELSE
         FERASE(cArq+TEOrdBagExt())
      ENDIF
   NEXT 
     
END SEQUENCE
RESTORD(aORDANT)
DBSELECTAREA("EEC")
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION EECNUIAE(cP_IAE,nP_OPC)
LOCAL oDLG,Z,aPOS,oBTN,;
      cTITULO   := STR0025+IF(cP_IAE="I",STR0026,IF(cP_IAE="A",IF(nP_OPC=2,STR0027,STR0028),STR0029)),; //"Manutencao de Numerario - "###"Inclusao"###"Visualizacao"###"Alteracao"###"Exclusao"
      nBTOP     := 0,;
      aBUTTONS  := {},; 
      cALIAS    := ALIAS(),;
      bCANCEL   := {|| nBTOP := 0,oDLG:End()},;
      bOK       := {|| IF(NU400VAL(cP_IAE),EVAL({|| nBTOP := 1,oDLG:END()}),;
                                           nBTOP := 0)},;
      nRECANT   := TRB->(RECNO())

Private aMOSTRA   := {"EEU_PREEMB","EEU_DT_DES","EEU_DESPES","EEU_VALOR","EEU_BASEAD",;
                      "EEU_PAGOPO","EEU_DT_EFE","EEU_LIBERA","EEU_DESCDE","EEU_DOCTO",;
                      "EEU_RECEBE","EEU_REFREC"}

Private aALTERA   := IF(nP_OPC#3.OR.cP_IAE="E",{},;
                     {"EEU_PREEMB","EEU_DT_DES","EEU_DESPES","EEU_VALOR","EEU_BASEAD",;
                      /*"EEU_PAGOPO",*/"EEU_DT_EFE","EEU_LIBERA","EEU_DOCTO","EEU_RECEBE",; //nopado por WFS em 05/02/2010 - sempre será pago pelo despachante
                      "EEU_REFREC","EEU_DTVENC","EEU_NATURE"})

If lGravaAgente
   aAdd(aMOSTRA,"EEU_CODAGE")
   aAdd(aMOSTRA,"EEU_TIPOAG")
   aAdd(aMOSTRA,"EEU_NOME  ")
   
   If nP_OPC <> 3 .or. cP_IAE <> "E" 
      aAdd(aALTERA,"EEU_CODAGE")
   EndIf

EndIf
// by CRF 27/10/2010 - 15:56
aALTERA := AddCpoUser(aALTERA,"EEU","1")

PRIVATE aTELA[0,0],aGETS[0],nOpc_Ench,lSair:=.F.

nOpc_Ench:=cP_IAE

BEGIN SEQUENCE

   //WFS
   SX3->(DbSetOrder(2))
   If SX3->(dbSeek("EEU_DTVENC"))
      If X3Uso(SX3->X3_USADO)
         AAdd(aMostra, AllTrim(SX3->X3_CAMPO))
      EndIf
   EndIf

   If SX3->(dbSeek("EEU_NATURE"))
      If X3Uso(SX3->X3_USADO)
         AAdd(aMostra, AllTrim(SX3->X3_CAMPO))
      EndIf
   EndIf


   IF lPOINT_NU
      EXECBLOCK("EECPNU01",.F.,.F.,"MANUT_DESP_INICIO")
   ENDIF

   IF lSair
      BREAK
   ENDIF

   IF cP_IAE = "I"
      TRB->(DBGOBOTTOM(),DBSKIP())
   ELSEIF TRB->(EOF() .OR. BOF())
          HELP(" ",1,"REGNOIS")
          BREAK
   ELSEIF cP_IAE = "E" .AND. ! EMPTY(TRB->EEU_DT_EFE)
          MSGSTOP(STR0030,STR0010) //"Esta despesa foi aprovada e nao sera excluida !"
          BREAK
   ELSEIF cP_IAE = "A" .AND. ! EMPTY(TRB->EEU_DT_EFE) .And. nP_OPC == 3
          MSGINFO(STR0031,STR0010) //"Despesas efetivadas nao poderao ser alteradas ou excluidas !"
          BREAK
   ENDIF
   DBSELECTAREA("TRB")
   FOR Z := 1 TO TRB->(FCOUNT())
       M->&(TRB->(FIELDNAME(Z))) := TRB->(FIELDGET(Z))
   NEXT
   M->EEU_PREEMB := EEC->EEC_PREEMB
   //WFS 05/02/2010
   //O pagamento sempre será realizado pelo despachante. Pagamentos feitos pelo exportador devem ser lançados como despesa no processo.
   M->EEU_PAGOPO:= "1"
   If cP_IAE == "I" .And. TRB->(FieldPos("EEU_POSIC")) > 0
      M->EEU_POSIC :=  NU400ValPos(EEC->EEC_PREEMB) // MCF- 30/07/2014
   EndIf
   
   //OAP -09/11/2010- Inclusão de campos adicionadod pelo usuário   
   aMOSTRA := AddCpoUser(aMOSTRA,"EEU","1")
   If nP_OPC != 2 .AND. (cP_IAE == "I" .OR. cP_IAE == "A") 
      aALTERA := AddCpoUser(aALTERA,"EEU","1")
   EndIf
   
   DEFINE MSDIALOG oDlg TITLE cTITULO FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      aPOS := POSDLG(oDLG)
      ENCHOICE("EEU",0,3,,,,aMOSTRA,aPOS,aALTERA,3)
      oDlg:lMaximized:=.T.
   ACTIVATE MSDIALOG oDlg ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
   IF lPOINT_NU
      EXECBLOCK("EECPNU01",.F.,.F.,"MANUT_DESP")
   ENDIF
   IF nBTOP = 1
      IF AT(cP_IAE,"IA") # 0
         IF cP_IAE = "I"
            TRB->(DBAPPEND())
         ENDIF
         EECNUSOMA("M")
         AVREPLACE("M","TRB")
         nRECANT := TRB->(RECNO())
      ELSE
         If TRB->RECNO # 0
            AADD(aDeletados,TRB->RECNO)
         Endif
         TRB->(DBDELETE())
         M->EEU_VALOR := 0
         EECNUSOMA("M")
      ENDIF
   ENDIF
END SEQUENCE
TRB->(DBGOTO(nRECANT))
DBSELECTAREA(cALIAS)
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION EECNUSOMA(cP_MODO)
LOCAL dDATA,nVALOR
cP_MODO := IF(cP_MODO=NIL,"A",cP_MODO)
dDATA   := IF(cP_MODO="A",EEU->EEU_DT_EFE,M->EEU_DT_EFE)
nVALOR  := IF(cP_MODO="A",EEU->EEU_VALOR ,M->EEU_VALOR-TRB->EEU_VALOR)
IF ! EMPTY(dDATA)
   nEFETIVA := nEFETIVA+nVALOR
ELSE
   nNAOEFET := nNAOEFET+nVALOR
ENDIF
nTOTDESP := nTOTDESP+nVALOR
RETURN(NIL)
*--------------------------------------------------------------------
FUNCTION EECNULIB()
LOCAL lZERO  := .T.,;
      nRECNO := TRB->(RECNO())
*
/* Nopado por GFP - 10/04/2012 - Verificação de niveis de acesso deve ser customizado.
IF cNIVEL < 8
   HELP("",1, "cNivel")
ELSE
*/
   TRB->(DBGOTOP())
   DO WHILE ! TRB->(EOF())
      IF EMPTY(TRB->EEU_DT_EFE)
         lZERO := .F.
         TRB->(DBGOTO(nRECNO))
         EXIT
      ENDIF
      TRB->(DBSKIP())
   ENDDO
   IF lZERO
      MSGINFO(STR0036,STR0010) //"Nao existem despesas de adiantamento ao despachante a efetivar !!!"
   ELSEIF MSGYESNO(STR0068,STR0069) //"Confirma a efetivacao das despesas ?"###"Atencao"
          //RMD - 11/04/17 - Retirado o condicional de dentro do Transaction
          /*Begin Transaction
          If !NU400BancoSE5(.T.) //MCF - 18/06/2015
             break
          Endif
          PROCESSA({|| EECNU400EF() },STR0032) //"Vlr.Aprovado"
          End Transaction
          */
          If NU400BancoSE5(.T.) //MCF - 18/06/2015
             Begin Transaction
                PROCESSA({|| EECNU400EF(nRECNO) },STR0032) //"Vlr.Aprovado"
             End Transaction
          Endif
   ENDIF
   TRB->(DBGOTO(nRECNO))
//ENDIF
RETURN(NIL)
*--------------------------------------------------------------------
FUNCTION EECNUCAN()
LOCAL lZERO   := .T.,;
      cCODINT := TRB->EEU_CODINT,;
      nRECNO  := TRB->(RECNO())
Local nI
Private aValAdi := {} // By JPP - 25/02/2008 - 15:15 - O total do valor adiantado deve ser agrupado por empresa.
Private lCancel := .F.
*
/* Nopado por GFP - 10/04/2012 - Verificação de niveis de acesso deve ser customizado.
IF cNIVEL < 8
   HELP("",1, "cNivel")
ELSE
*/
   TRB->(DBGOTOP())
   DO WHILE ! TRB->(EOF())
      IF ! EMPTY(TRB->EEU_DT_EFE) .And. TRB->EEU_CODINT = cCODINT
         If TRB->EEU_PAGOPO = "1" .And. TRB->EEU_BASEAD $ cSIM // By JPP - 25/02/2008 - 15:15 - O total do valor adiantado deve ser agrupado por empresa.
            nI := Ascan(aValAdi, { |x| x[1]+x[2] == TRB->EEU_CODAGE + TRB->EEU_TIPOAG})
            If TRB->EEU_DESPES <> "901" .And. TRB->EEU_DESPES <> "902" .And. TRB->EEU_DESPES <> "903"
               If nI == 0                                                                
                  Aadd(aValAdi,{TRB->EEU_CODAGE,; // Código do Agente
                             TRB->EEU_TIPOAG,; // Tipo do Agente
                             TRB->EEU_VALOR,;  // Valor de Adiantamento da despesa de código 901.
                             TRB->RECNO})                // Numero do Registro na Qual foi gravada a despesa de código 901.
               Else
                  aValAdi[nI,3] := aValAdi[nI,3] + TRB->EEU_VALOR
               EndIf
            EndIf
         EndIf
         lZERO := .F.
         //TRB->(DBGOTO(nRECNO)) // By JPP - 29/02/2008 - 16:15
         //EXIT  // By JPP - 29/02/2008 - 16:15
      ENDIF
      TRB->(DBSKIP())
   ENDDO             
   TRB->(DBGOTO(nRECNO)) // By JPP - 29/02/2008 - 16:15       
   
   If EasyEntryPoint("EECNU400")
      ExecBlock("EECNU400",.F.,.F.,"CANCEL_EFETI")
   EndIf
   
   IF lZERO
      MSGINFO(STR0067,STR0010) //"Nao existe efetivacao de despesas para ser cancelada."###"Aviso"
   ELSEIF !lCancel .and. MSGYESNO(STR0033,STR0034) //"Confirma o cancelamento ?"###"Cancelamento da aprovacao"
          PROCESSA({|| EECNU400CA() },STR0032) //"Vlr.Aprovado"
   ENDIF
   TRB->(DBGOTO(nRECNO))
//ENDIF
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION EECNU400EF(nTrbRecno)
LOCAL aINFO,cBODY,nValEfet,nValEfetDe,cTO,cSUBJECT,cCC,cTO2,;
      cBODY2,cCC2,;
      cEMail   := "",;
      lPri     := .T.,;
      cAgNome  := "",;
      cFornece := "",;
      cLojaF   := ""
Local nI,i
Local aChaves
Local cNatureza:= ""
Local lRet := .T.
//Local lIntLogix  := AvFlags("EEC_LOGIX") //NCF - 05/08/2014
Local lEaiBuffer := .F.                  //NCF - 05/08/2014
Local aRecsEET   := {}                   //NCF - 05/08/2014
Local aCposEEU   := {}                   //NCF - 05/08/2014
Local aKeysEIU   := {}                   //NCF - 05/08/2014
Local lContinue  := .T.                  //NCF - 05/08/2014
*
PRIVATE nValAdi := nValDeb := nRec901 := 0,;
        cCodInt := ""
Private aValAdi := {} // By JPP - 25/02/2008 - 15:15 - O total do valor adiantado deve ser agrupado por empresa.
*

/* MPG - SE A NATUREZA FOR INVÁLIDA SAI DA ROTINA SEM EXECUTAR NADA
If ! SED->( DbSetOrder(1) , DBSEEK( xFilial("SED") + cNatureza ) )
  MSGSTOP( "Natureza inválida. Não é possível a integração com o financeiro" ,STR0010)
  Return
EndIf
*/

BEGIN SEQUENCE
PROCREGUA(TRB->(LASTREC()))
TRB->(DBGOTOP())
cUser := cEMail:=""

// *** GFP - 19/05/2011 :: 12h05 - Tratamento de WorkFlow no Numerario.
If AvFlags("WORKFLOW")
   aChaves := EasyGroupWF("NUMERARIO_EEC")
EndIf 

If lIntLogix
   If FindFunction("EasyEAIBuffer")
      lEaiBuffer := .T.
      EasyEAIBuffer("INICIO")
   EndIf
EndIf

DO WHILE ! TRB->(EOF())
   INCPROC(STR0035) //"Efetivando Despesas"
   If Empty(TRB->EEU_DT_EFE)
      If Empty(cCodInt)
         cCodInt := GetSXENum("EEU","EEU_CODINT")
         ConfirmSX8()
      EndIf
      If TRB->EEU_PAGOPO = "1" .And. TRB->EEU_BASEAD $ cSIM
         nI := Ascan(aValAdi, { |x| x[1]+x[2] == TRB->EEU_CODAGE + TRB->EEU_TIPOAG}) // By JPP - 25/02/2008 - 15:15 - O total do valor adiantado deve ser agrupado por empresa.
         If nI == 0
            Aadd(aValAdi,{TRB->EEU_CODAGE,; // Código do Agente
                          TRB->EEU_TIPOAG,; // Tipo do Agente
                          TRB->EEU_VALOR,;  // Valor de Adiantamento da despesa de código 901.
                          })                // Numero do Registro na Qual foi gravada a despesa de código 901.
         Else
            aValAdi[nI,3] := aValAdi[nI,3] + TRB->EEU_VALOR
         EndIf
         //nValAdi := nVALADI+TRB->EEU_VALOR // By JPP - 25/02/2008 - 15:15 - O total do valor adiantado deve ser agrupado por empresa.
      ElseIf TRB->EEU_PAGOPO = "2" .And. TRB->EEU_BASEAD $ cNAO
         nValDeb := nVALDEB+TRB->EEU_VALOR
      EndIf
      EET->(RECLOCK("EET",.T.))
      EET->EET_FILIAL := XFILIAL("EET")
      EET->EET_PEDIDO := EEC->EEC_PREEMB
      EET->EET_OCORRE := OC_EM
      EET->EET_DESPES := TRB->EEU_DESPES
      EET->EET_DESADI := dDATABASE
      EET->EET_VALORR := TRB->EEU_VALOR
      EET->EET_BASEAD := TRB->EEU_BASEAD
      EET->EET_DOCTO  := TRB->EEU_DOCTO
      EET->EET_PAGOPO := TRB->EEU_PAGOPO
      EET->EET_RECEBE := TRB->EEU_RECEBE
      EET->EET_REFREC := TRB->EEU_REFREC
      EET->EET_CODINT := cCODINT

      //WFS 03/02/10
      If TRB->(FieldPos("EEU_NATURE")) > 0
         EET->EET_NATURE := TRB->EEU_NATURE
      EndIf
      If TRB->(FieldPos("EEU_DTVENC")) > 0      
         EET->EET_DTVENC := TRB->EEU_DTVENC
      EndIf

      //ER - 29/05/2007
      If lGravaAgente
         
         EET->EET_CODAGE := TRB->EEU_CODAGE
         EET->EET_TIPOAG := TRB->EEU_TIPOAG
         
         SY5->(DbSetOrder(1)) 
         If SY5->(DbSeek(xFilial("SY5")+TRB->EEU_CODAGE))
            cAgNome  := SY5->Y5_NOME            
            cFornece := SY5->Y5_FORNECE
            cLojaF   := SY5->Y5_LOJAF 

            //Verifica se o fornecedor/loja nao está bloqueado
            SA2->(DbSetOrder(1))
            SA2->(dbSeek(xFilial("SA2")+cFornece+cLojaF))

            If SA2->A2_MSBLQL == "1"
              EasyHelp(StrTran(STR0082+Chr(13)+Chr(10)+Chr(13)+Chr(10)+STR0083, "xxx", TRB->EEU_DESPES), STR0010) //STR082:"O fornecedor utilizado está bloqueado para uso. Despesa: xxx" / STR083:"Selecione outro fornecedor ou desbloqueie o mesmo."
              lContinue := .F.
              EXIT
            EndIF            
         EndIf
         
         EET->EET_FORNEC := cFornece
         EET->EET_LOJAF  := cLojaF
         
         If !(EEB->( EEB->(DbSetOrder(1)) , DbSeek(xFilial("EEB")+EEC->EEC_PREEMB+EET->EET_OCORRE+TRB->EEU_CODAGE))) // +TRB->EEU_TIPOAG))) MPG-15/01/2018- Não existe tipo de agente no indice da tabela EEB
            
            EEB->(RecLock("EEB",.T.))
            
            EEB->EEB_FILIAL := xFilial("EEB")
            EEB->EEB_PEDIDO := EEC->EEC_PREEMB
            EEB->EEB_CODAGE := TRB->EEU_CODAGE
            EEB->EEB_TIPOAG := TRB->EEU_TIPOAG
            EEB->EEB_OCORRE := OC_EM
            EEB->EEB_TIPCOM := "2" 
            EEB->EEB_TIPCVL := "1"
            
            EEB->EEB_NOME   := cAgNome
            EEB->EEB_FORNEC := cFornece
            EEB->EEB_LOJAF  := cLojaF
                         
            EEB->(MsUnlock())
          EndIf
      EndIf
      
      If lIntLogix
         aAdd(aRecsEET,EET->(Recno()))             //NCF - 05/08/2014
      EndIf 
      
      /* WFS 03/02/2010
         Verifica se a integração com o Financeiro está habilidada.
         Quando o usuário informar a data de vencimento e a natureza da despesa, será
         gerado um título do tipo NF no Financeiro.
         Quando o usuário não informar a data de vencimento ou a natureza da despesa,
         não será gerado título no Financeiro. */
         
      If /*IsIntEnable("001") .And.*/ (!Empty(EET->EET_NATURE) .And. !Empty(EET->EET_DTVENC)) /*.OR. !IsIntEnable("001")*/ //.And. TRB->EEU_GERFIN $ cSim - WFS apenas teste/ avaliação.

         cTipoTit:= "NF"
         cFinForn:= cFornece
         cFinLoja:= cLojaF

         //Inicia a integração do título a pagar
         AvStAction("015")
      EndIf
      
      EET->(MSUNLOCK())
      
      IF lPOINT_NU
         EXECBLOCK("EECPNU01",.F.,.F.,"GRAVOU_SWD")
      EndIf
      TRB->EEU_DT_EFE := dDATABASE
      TRB->EEU_CODINT := cCODINT
      TRB->EEU_LIBERA := AllTrim(cUserName)
      IF TRB->RECNO = 0
         EEU->(RECLOCK("EEU",.T.)) // Append com lock
         TRB->RECNO := EEU->(RECNO())
      ELSE
         EEU->(DBGOTO(TRB->RECNO))
         EEU->(RECLOCK("EEU",.F.))
      ENDIF  
         
      //NCF - 05/08/2014 - Backup da TRB 
      If lIntLogix
         aAdd(aCposEEU,{ TRB->RECNO, TRB->(RECNO()) })
      EndIf
      
      AVREPLACE("TRB","EEU")
      EEU->EEU_FILIAL := XFILIAL("EEU")
      EEU->EEU_PREEMB := EEC->EEC_PREEMB
      EEU->(MsUnlock())                            //NCF - 06/08/2014
      nEFETIVA        := nEFETIVA+EEU->EEU_VALOR
      nNAOEFET        := nNAOEFET-EEU->EEU_VALOR
      IF lPri //Pode ocorrer que um usuario integre apos a liberacao e nao seja o mesmo da primeira integracao
         lPri := .F.
         PswOrder(1)
         IF PswSeek(ALLTRIM(EEU->EEU_USER),.T.)
            aInfo := PswRet(1)
            IF LEN(aInfo) > 0 .AND. LEN(aInfo[1]) > 0
               cEMail := ALLTRIM(aInfo[1,14])
            ENDIF   
         ENDIF   
      ENDIF   
   EndIf
   TRB->(dbSkip())
EndDo

//NCF - 05/08/2014 - Executar a Integração com LOGIX 
If lIntLogix
   If lEaiBuffer .And. !EasyEAIBuffer("FIM")
      //Montar aEasyBuffer para integrar reversão
      If FindFunction("EasyEAIBuffer")
         lEaiBuffer := .T.
         EasyEAIBuffer("INICIO")
      EndIf
      //Carrega Buffer dos registros da EET
      For i:=1 To Len(aRecsEET)
         EET->(DbGoTo(aRecsEET[i]))
         If EET->(FieldPos("EET_FINNUM")) > 0 .And. !Empty(EET->EET_FINNUM) //NCF - 06/08/2014
            AvStAction("016")
         EndIf
      Next i 
      //Executa a Integração(Exclusão de títulos)
      EasyEAIBuffer("FIM")
      //Restaura EET
      For i:=1 To Len(aRecsEET)
         EET->(DbGoTo(aRecsEET[i]))
         if EET->( !EOF() ) .and. EET->(RecLock("EET",.F.))
            EET->(DbDelete())
            EET->(MsUnlock())
         endif
      Next i
      //Restaura EEU/TRB/Totalizadores
      For i:=1 To Len(aCposEEU)
         EEU->(DbGoTo(aCposEEU[i][1] ))
         if EEU->( !eof() ) .and. EEU->(RecLock("EEU",.F.))
            EEU->EEU_DT_EFE := cToD("  /  /  ")
            EEU->EEU_CODINT := ""
            EEU->EEU_LIBERA := ""
            EEU->(MsUnlock()) 
         endif

         nEFETIVA -= EEU->EEU_VALOR
         nNAOEFET += EEU->EEU_VALOR
           
         TRB->(DbGoto(aCposEEU[i][2]))
         If TRB->(!Eof())                        //NCF - 13/08/14
            TRB->EEU_DT_EFE := cToD("  /  /  ")
            TRB->EEU_CODINT := ""
            TRB->EEU_LIBERA := "" 
         EndIf                               
      Next i      
      lContinue := .F.
   EndIf
EndIf

If lPoint_NU
   ExecBlock("EECPNU01",.F.,.F.,"EFETIVOU")
EndIf

TRB->(DBGOTOP())
//If nValAdi # 0 // By JPP - 25/02/2008 - 15:15 - O total do valor adiantado deve ser agrupado por empresa.
If Len(aValAdi) > 0 .and. lContinue// By JPP - 25/02/2008 - 15:15 - O total do valor adiantado deve ser agrupado por empresa.
  For nI := 1 To Len(aValAdi)     // NCF - 05/08/2014
    EET->(RECLOCK("EET",.T.))         
    If Left(aValAdi[nI,2],1) == CD_DES
      EET->EET_FILIAL := XFILIAL("EET")
      EET->EET_PEDIDO := EEC->EEC_PREEMB
      EET->EET_OCORRE := OC_EM
      EET->EET_DESPES := "901"
      EET->EET_DESADI := dDATABASE
      EET->EET_VALORR := aValAdi[nI,3] //nVALADI
      EET->EET_BASEAD := "1"
      EET->EET_DOCTO  := TRB->EEU_DOCTO
      EET->EET_PAGOPO := "1"
      EET->EET_CODINT := cCODINT

      //ER - 31/08/2007
      If lGravaAgente
        EET->EET_CODAGE := aValAdi[nI,1] // TRB->EEU_CODAGE  // By JPP - 26/02/2008 - 15:15 // TRB->EEU_CODAGE 
        EET->EET_TIPOAG := aValAdi[nI,2] //TRB->EEU_TIPOAG  // By JPP - 26/02/2008 - 15:15 
    
        SY5->(DbSetOrder(1)) 
        If SY5->(DbSeek(xFilial("SY5")+EET->EET_CODAGE))            
          cFornece := SY5->Y5_FORNECE
          cLojaF   := SY5->Y5_LOJAF 
        EndIf
    
        EET->EET_FORNEC := cFornece
        EET->EET_LOJAF  := cLojaF
      EndIf

      //nRec901         := EET->(RECNO())
      aValAdi[nI,4] := EET->(RECNO())

      /* WFS 03/02/2010
          Verifica se a integração com o Financeiro está habilidada.
          Será gerado um título de adiantamento no financeiro para cada empresa
          (conforme agrupamento).
          A natureza para os adiantamentos de despesas nacionais geradas a partir 
          da rotina de Numerários deve ser informada no parâmetro MV_AVG0187.
          Quando não informada, o título de adiantamento será gerado com o "AVG",
          caso o usuário opte por continuar com a operação. */

      If IsIntEnable("001")

         cTipoTit:= "PA"
         cFinForn:= cFornece
         cFinLoja:= cLojaF
         EET->EET_NATURE := cNaturezaPA
         EET->EET_DTVENC:= cDTVcSE5

          //Inicia a integração do título a pagar
         lRet := AvStAction("015")

		Else
        //Inicia a integração do título a pagar
        lRet := AvStAction("015")
      EndIf
    EndIf

    If ! lRet
      MsgInfo( STR0079,STR0010 )  // "A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
      TRB->( DbGoTo(nTrbRecno) )
      nEFETIVA -= TRB->EEU_VALOR
      nNAOEFET += TRB->EEU_VALOR
      TRB->EEU_DT_EFE := cTod("")
      TRB->EEU_CODINT := ""
      TRB->EEU_LIBERA := ""
      DisarmTransaction() // Mpg - 16/01/2018 - Caso retorne erro na geração do título no financeiro desfaz as operações já realizadas até esse ponto
      Return
    EndIf

    If lPoint_NU
        ExecBlock("EECPNU01",.F.,.F.,"GRAVOU_ADI")
    EndIf
    EET->(MSUNLOCK())   //Existe um campo sendo gravado na Funcao AVR3Numerario()
  Next
EndIf

If lParamOk .AND. lENVIO .And. lContinue  //NCF - 05/08/2014
   For nI := 1 To Len(aValAdi) // By JPP - 25/02/2008 - 15:15 - O despachante passou a ser lido do array aValAdi.
       If Left(aValAdi[nI,2],1) == CD_DES // 6 = Despachante 
          //BUSCAEMPRESA(EEC->EEC_PREEMB,OC_EM,CD_DES)
          SY5->(DBSETORDER(1))
          //SY5->(DBSEEK(XFILIAL("SY5")+EEB->EEB_CODAGE)) // By JPP - 25/02/2008 - 15:15
          SY5->(DBSEEK(XFILIAL("SY5")+aValAdi[nI,1])) 
          nValEfet := nValEfetDe := 0
          cBody    := ""
          cTo      := AllTrim(SY5->Y5_EMAIL)+Space(300)
          cSubject := AllTrim(STR0037+EEC->EEC_PREEMB) //"Liberacao de debito automatico Ref.Despach. "
          cBody    += STR0038+AllTrim(EEC->EEC_PREEMB)+STR0039+DTOC(EEC->EEC_DTPROC)+ENTER //"Embarque: "###" Data: "
          //BUSCAEMPRESA(EEC->EEC_PREEMB,OC_EM,CD_DES)
          //cBody    += STR0040+EEB->(EEB_CODAGE+" "+EEB_NOME)+ENTER //"Despacha: "
          cBody    += STR0040+aValAdi[nI,1]+" "+SY5->Y5_NOME+ENTER //"Despacha: "
          cCC      := AllTrim(aUsuario[1,14])
          cCC      += If(!EMPTY(cCC),",","")+cEMAILTE+If(!EMPTY(cEMail),",","")+cEMail
          BUSCAEMPRESA(EEC->EEC_PREEMB,OC_EM,CD_AGE)
          cBody    += STR0041+EEB->(EEB_CODAGE+" "+EEB_NOME)+ENTER //"Agente:   "
          cBody    += STR0042+Upper(AllTrim(Substr(cUsuario,7,15)))+ENTER //"Efetivado Por: "
          cCC      := cCC + SPACE(300)
          cBody    += "<HTML>"     
          cBody    += STR0043 //"Despesas efetivadas"
          cBody    += "<TABLE BORDER=0 CELLSPACING=10 WIDTH=100%>" 
          cBody    += "<TR ALIGN=LEFT>"
          cBody    += "<TH>"+STR0044    +"</TH>" //"Despesa"
          cBody    += "<TH>"+STR0045   +"</TH>" //"Dt.Pagto"
          cBody    += "<TH>"+STR0046   +"</TH>" //"Pago Por"
          cBody    += "<TH>"+STR0047     +"</TH>" //"Adiant"
          cBody    += "<TH>"+STR0048      +"</TH>" //"Valor"
          cBody    += "<TH>"+STR0049   +"</TH>" //"Dt.Efet."
          cBody    += "<TH>"+STR0050+"</TH>" //"Cod.Integr."
          cBody    += "</TR>"                            
          cBody    += "<TR ALIGN=LEFT>"
          cBody    += "<TH>"+"_______________________"+"</TH>"
          cBody    += "<TH>"+"________ "              +"</TH>"
          cBody    += "<TH>"+"___________ "           +"</TH>"                     
          cBody    += "<TH>"+"___________ "           +"</TH>" 
          cBody    += "<TH>"+"______ "                +"</TH>"  
          cBody    += "<TH>"+"________ "              +"</TH>" 
          cBody    += "<TH>"+"___________"            +"</TH>" 
          cBody    += "</TR>"
          //if nRec901 # 0
          //   EET->(DBGOTO(nREC901))      
          If !Empty(aValAdi[nI,4])
             EET->(DbGoTo(aValAdi[nI,4]))
             cTo2      := AllTrim(SY5->Y5_EMAIL)+Space(300)
             cBody2    := ""                              
             cBody2    += STR0038+AllTrim(EEC->EEC_PREEMB)+STR0039+DTOC(EEC->EEC_DTPROC)+ENTER //"Embarque: "###" Data: "
             //BUSCAEMPRESA(EEC->EEC_PREEMB,OC_EM,CD_DES)
             //cBody2    += STR0040+EEB->(EEB_CODAGE+" "+EEB_NOME)+ENTER //"Despacha: "
             cBody2    += STR0040+EEB->(aValAdi[nI,1]+" "+SY5->Y5_NOME)+ENTER //"Despacha: "
             cCC2      := AllTrim(aUsuario[1,14])
             cCC2      += If(!EMPTY(cCC2),",","")+cEMAILCP+If(!EMPTY(cEMail),",","")+cEMail
             cSubject2 := AllTrim(STR0051+EEC->EEC_PREEMB)  //"Liberacao de despesas de numerario Ref.Despach. "
             BUSCAEMPRESA(EEC->EEC_PREEMB,OC_EM,CD_AGE)
             cBody2    += STR0041+EEB->(EEB_CODAGE+" "+EEB_NOME)+ENTER //"Agente:   "
             cBody2    += STR0042+Upper(AllTrim(Substr(cUsuario,7,15)))+ENTER //"Efetivado Por: "
             cBody2    += STR0052+EET->EET_DOCTO //"No. do Documento: "
             cCC2      := cCC2 + SPACE(300)
             cBody2    += "<HTML>"       
             cBody2    += "<TABLE BORDER=0 CELLSPACING=10 WIDTH=100%>" 
             cBody2    += STR0043 //"Despesas efetivadas"
             cBody2    += "<TR ALIGN=LEFT>"
             cBody2    += "<TH>"+STR0044    +"</TH>" //"Despesa"
             cBody2    += "<TH>"+STR0045   +"</TH>" //"Dt.Pagto"
             cBody2    += "<TH>"+STR0046   +"</TH>" //"Pago Por"
             cBody2    += "<TH>"+STR0047     +"</TH>" //"Adiant"
             cBody2    += "<TH>"+STR0048      +"</TH>" //"Valor"
             cBody2    += "<TH>"+STR0049   +"</TH>" //"Dt.Efet."
             cBody2    += "<TH>"+STR0050+"</TH>" //"Cod.Integr."
             cBody2    += "</TR>"
             cBody2    += "<TR ALIGN=LEFT>"
             cBody2    += "<TH>"+"_______________________"+"</TH>"
             cBody2    += "<TH>"+"________ "              +"</TH>"
             cBody2    += "<TH>"+"___________ "           +"</TH>"
             cBody2    += "<TH>"+"___________ "           +"</TH>"
             cBody2    += "<TH>"+"______ "                +"</TH>"
             cBody2    += "<TH>"+"________ "              +"</TH>"
             cBody2    += "<TH>"+"___________"            +"</TH>"
             cBody2    += "</TR>"
          EndIf
          DO While ! TRB->(EOF())
             If TRB->EEU_CODINT = cCodInt .And. TRB->EEU_DESPES $ cDebAut  // II  IPI ICM TX.SISCOMES
                cBody    += "<TR ALIGN=LEFT>"
                cBody    += "<TD>"+TRB->EEU_DESPES+" "+LEFT(POSICIONE("SYB",1,xFILIAL("SYB")+TRB->EEU_DESPES,"YB_DESCR"),20)+"</TD>"
                cBody    += "<TD>"+If(TRB->(FieldPos("EEU_DTVENC")) > 0 .AND. !Empty(TRB->EEU_DTVENC),DTOC(TRB->EEU_DTVENC),DTOC(TRB->EEU_DT_DES))+"</TD>"
                cBody    += "<TD>"+BSCXBOX("EEU_PAGOPO", AllTrim(TRB->EEU_PAGOPO))+"</TD>"
                cBody    += "<TD>"+BSCXBOX("EEU_BASEAD", AllTrim(TRB->EEU_BASEAD))+"</TD>"
                cBody    += "<TD>"+TransForm(TRB->EEU_VALOR,"@E 999,999.99")+"</TD>"
                cBody    += "<TD>"+DTOC(TRB->EEU_DT_EFE)+"</TD>"
                cBody    += "<TD>"+TRB->EEU_CODINT+"</TD>"
                cBody    += "</TR>"
                nValEfet += TRB->EEU_VALOR
             //ElseIf nRec901 # 0 .And. TRB->EEU_CODINT = cCodInt .And. TRB->EEU_BASEAD $ cSim .And. TRB->EEU_PAGOPO = "1" // Despesas adiantadas para o despachante // By JPP - 29/02/2008
             ElseIf aValAdi[nI,4] # 0 .And. TRB->EEU_CODINT = cCodInt .And. TRB->EEU_BASEAD $ cSim .And. TRB->EEU_PAGOPO = "1" // Despesas adiantadas para o despachante // By JPP - 29/02/2008
                    cBody2     += "<TR ALIGN=LEFT>"
                    cBody2     += "<TD>"+TRB->EEU_DESPES+" "+LEFT(POSICIONE("SYB",1,xFILIAL("SYB")+TRB->EEU_DESPES,"YB_DESCR"),20)+"</TD>"
                    cBody2     += "<TD>"+If(TRB->(FieldPos("EEU_DTVENC")) > 0 .AND. !Empty(TRB->EEU_DTVENC),DTOC(TRB->EEU_DTVENC),DTOC(TRB->EEU_DT_DES))+"</TD>"
                    cBody2     += "<TD>"+BSCXBOX("EEU_PAGOPO",AllTrim(TRB->EEU_PAGOPO))+"</TD>"
                    cBody2     += "<TD>"+BSCXBOX("EEU_BASEAD",AllTrim(TRB->EEU_BASEAD))+"</TD>"
                    cBody2     += "<TD>"+TransForm(TRB->EEU_VALOR,"@E 999,999.99")+"</TD>"
                    cBody2     += "<TD>"+DTOC(TRB->EEU_DT_EFE)+"</TD>"
                    cBody2     += "<TD>"+TRB->EEU_CODINT+"</TD>"
                    cBody2     += "</TR>"
                    nValEfetDe += TRB->EEU_VALOR
             EndIf
             TRB->(dbSkip())
          EndDo
          If nValEfet > 0
             cBody  += "</TABLE>" 
          EndIf
          If nValEfetDe > 0   
             cBody2 += "</TABLE>"   
          EndIf

          If lEmail
            If nValEfet > 0
                cBody  += "_____________________________________________________________________________________"+ENTER
                cBody  += STR0053+TransForm(nValEfet,"@E 9,999,999.99")+ENTER //"TOTAL DEBITO AUTOMATICO EFETIVADO           "
                TelaMail(@cTo,@cCC,cSubject)
                IF EMPTY(cCC)
                   cCC := AllTrim(aUsuario[1,14])
                ENDIF

                  oMail := TMailManager():New()
                  if lRelSLS
                    oMail:SetUseSSL( .T. )
                  elseif lRelTLS
                    oMail:SetUseTLS( .T. )
                  endif
                  oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
                  oMail:SetSmtpTimeOut( nTimeOut )
                  
                  nErro := oMail:SmtpConnect()
                  if nErro <> 0
                    cErrorMsg := oMail:GetErrorString( nErro )
                    easyhelp(STR0054+": "+cErrorMsg,STR0010) //"Falha na Conexao com Servidor de E-Mail"
                  Else
                    if lAutentica
                        nErro := oMail:SmtpAuth( cUserAut,cPassAut )
                        If nErro <> 0
                          cErrorMsg := oMail:GetErrorString( nErro )
                          easyhelp(STR0077+": "+cErrorMsg,STR0076) //"Falha na Autenticacao do Usuario" ### "Erro"
                          oMail:SMTPDisconnect()
                          If nErro <> 0
                            cErrorMsg := oMail:GetErrorString( nErro )
                            easyhelp(STR0078+cErrorMsg,STR0076) //"Erro na Desconexão: " ### "Erro"
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
                        easyhelp(STR0055+": "+cErrorMsg,STR0010) //"Falha no Envio de E-Mail"
                      EndIf

                      oMail:SMTPDisconnect()
                      If nErro <> 0
                        cErrorMsg := oMail:GetErrorString( nErro )
                        easyhelp(STR0078+cErrorMsg,STR0076) //"Erro na Desconexão: " ### "Erro"
                      endif
                  endif
              Endif

              nValEfet := 0  // By JPP - 29/02/2008 - 17:30
            EndIf
            If nValEfetDesp > 0
                cBody2 += "_____________________________________________________________________________________"+ENTER
                cBody2 += STR0056+TransForm(nValEfetDesp, "@E 9,999,999.99")+ENTER //"TOTAL ADIANTAMENTO AO DESPACHANTE                 "
                TelaMail(@cTo2,@cCC2,cSubject2)
                IF EMPTY(cCC2)
                   cCC2 := AllTrim(aUsuario[1,14])         
                ENDIF

                  oMail := TMailManager():New()
                  if lRelSLS
                    oMail:SetUseSSL( .T. )
                  elseif lRelTLS
                    oMail:SetUseTLS( .T. )
                  endif
                  oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
                  oMail:SetSmtpTimeOut( nTimeOut )
                  
                  nErro := oMail:SmtpConnect()
                  if nErro <> 0
                    cErrorMsg := oMail:GetErrorString( nErro )
                    easyhelp(STR0054+": "+cErrorMsg,STR0010) //"Falha na Conexao com Servidor de E-Mail"
                  Else
                    if lAutentica
                        nErro := oMail:SmtpAuth( cUserAut,cPassAut )
                        If nErro <> 0
                          cErrorMsg := oMail:GetErrorString( nErro )
                          easyhelp(STR0077+": "+cErrorMsg,STR0076) //"Falha na Autenticacao do Usuario" ### "Erro"
                          oMail:SMTPDisconnect()
                          If nErro <> 0
                            cErrorMsg := oMail:GetErrorString( nErro )
                            easyhelp(STR0078+cErrorMsg,STR0076) //"Erro na Desconexão: " ### "Erro"
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
                        easyhelp(STR0055+": "+cErrorMsg,STR0010) //"Falha no Envio de E-Mail"
                      EndIf

                      oMail:SMTPDisconnect()
                      If nErro <> 0
                        cErrorMsg := oMail:GetErrorString( nErro )
                        easyhelp(STR0078+cErrorMsg,STR0076) //"Erro na Desconexão: " ### "Erro"
                      endif

                    endif
                  Endif
              nValEfetDesp := 0 // By JPP - 29/02/2008 - 17:30
            EndIf
          EndIf
       EndIf
   Next
EndIf
END SEQUENCE
TRB->(DBGOTOP())

// *** GFP - 28/03/2011 :: 17h05 - Tratamento de WorkFlow no Numerario.
If AvFlags("WORKFLOW")
   EasyGroupWF("NUMERARIO_EEC",aChaves)
EndIf
// *** Fim GFP

RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION EECNU400CA()
LOCAL cBODY,cTO,cSUBJECT,cCC,cTO2,cBODY2,cCC2,nI,;
	  nREC   := TRB->(RECNO()) 
Local aTitBaixa:= {}
Local cTitulos:= "",;
      cTxtDesp:= "",;
      cTxtTit := "",;
      cTitTemp:= ""
Local nCont
//Local lIntLogix  := AvFlags("EEC_LOGIX") //NCF - 05/08/2014
Local lEaiBuffer := .F.                  //NCF - 05/08/2014
Local aEEUEfetv  := {}                   //NCF - 05/08/2014
Local aRecsEET   := {}                   //NCF - 05/08/2014
Local i                                  //NCF - 05/08/2014 
*
PRIVATE nValAdi := nValDeb := nRec901 := 0,;                               
        cCodInt := TRB->EEU_CODINT
*
BEGIN SEQUENCE
   If lParamOk .AND. lENVIO
      For nI := 1 To Len(aValAdi) // By JPP - 25/02/2008 - 15:15 - O despachante passou a ser lido do array aValAdi. Neste Array existe um agrupamento de despesas por despachante. 
          If Left(aValAdi[ni,2],1) == CD_DES
             TRB->(dbGoTop())
             nValEfet  := nValEfetDe := 0
             cBody     := ""              
             cTo       := cEMAILCP+Space(300)
             cSubject  := AllTrim(STR0057+EEC->EEC_PREEMB) //"Cancelamento da liberacao das despesas de numerario Ref.Despach. "
             cBody     += STR0038+AllTrim(EEC->EEC_PREEMB)+STR0039+DTOC(EEC->EEC_DTPROC)+ENTER //"Embarque: "###" Data: "
             //BUSCAEMPRESA(EEC->EEC_PREEMB,OC_EM,CD_DES)
             cBody     += STR0040+EEB->(EEB_CODAGE+" "+EEB_NOME)+ENTER //"Despacha: "
             SY5->(DBSETORDER(1))
             SY5->(DBSEEK(XFILIAL("SY5")+aValAdi[ni,1]))
             cCC       := AllTrim(SY5->Y5_EMAIL)
             cCC       := cCC+If(!EMPTY(cCC),",","")+AllTrim(aUsuario[1,14])+SPACE(300)
             BUSCAEMPRESA(EEC->EEC_PREEMB,OC_EM,CD_AGE)
             cBody     += STR0041+EEB->(EEB_CODAGE+" "+EEB_NOME)+ENTER //"Agente:   "
             cBody     += STR0042+Upper(AllTrim(Substr(cUsuario,7,15)))+ENTER //"Efetivado Por: "
             cBody     += ""+ENTER
             cBody     += STR0058+ENTER //"CANCELAMENTO DA EFETIVACAO DAS DESPESAS DE NUMERARIO"
             cBody     += STR0052+TRB->EEU_DOCTO //"No. do Documento: "
             cBody     += "<HTML>"       
             cBody     += "<TABLE BORDER=0 CELLSPACING=10 WIDTH=100%>" 
             cBody     += "<TR ALIGN=LEFT>"
             cBody     += "<TH>"+STR0044+"</TH>" //"Despesa"
             cBody     += "<TH>"+STR0045+"</TH>" //"Dt.Pagto"
             cBody     += "<TH>"+STR0046+"</TH>" //"Pago Por"
             cBody     += "<TH>"+STR0047+"</TH>" //"Adiant"
             cBody     += "<TH>"+STR0048+"</TH>" //"Valor"
             cBody     += "<TH>"+STR0049+"</TH>" //"Dt.Efet."
             cBody     += "<TH>"+STR0050+"</TH>" //"Cod.Integr."
             cBody     += "</TR>"                          
             cBody     += "<TR ALIGN=LEFT>"
             cBody     += "<TH>"+"_______________________"+"</TH>"
             cBody     += "<TH>"+"________ "              +"</TH>"
             cBody     += "<TH>"+"___________ "           +"</TH>"
             cBody     += "<TH>"+"___________ "           +"</TH>"
             cBody     += "<TH>"+"______ "                +"</TH>"
             cBody     += "<TH>"+"________ "              +"</TH>"
             cBody     += "<TH>"+"___________"            +"</TH>"
             cBody     += "</TR>"
             cBody2    := ""
             //BUSCAEMPRESA(EEC->EEC_PREEMB,OC_EM,CD_DES)
             SY5->(DBSETORDER(1))
             //SY5->(DBSEEK(XFILIAL("SY5")+EEB->EEB_CODAGE))
             SY5->(DBSEEK(XFILIAL("SY5")+aValAdi[ni,1]))
             cTo2      := AllTrim(SY5->Y5_EMAIL)+SPACE(300)
             cSubject  := AllTrim(STR0057+EEC->EEC_PREEMB) //"Cancelamento da liberacao das despesas de numerario Ref.Despach. "
             cBody2    += STR0038+AllTrim(EEC->EEC_PREEMB)+STR0039+DTOC(EEC->EEC_DTPROC)+ENTER //"Embarque: "###" Data: "
             //cBody2    += STR0040+EEB->(EEB_CODAGE+" "+EEB_NOME)+ENTER //"Despacha: "
             cBody2    += STR0040+EEB->(aValAdi[nI,1]+" "+SY5->Y5_NOME)+ENTER //"Despacha: "
             cCC2      := AllTrim(aUsuario[1,14])+SPACE(300)
             BUSCAEMPRESA(EEC->EEC_PREEMB,OC_EM,CD_AGE)
             cBody2    += STR0041+EEB->(EEB_CODAGE+" "+EEB_NOME)+ENTER //"Agente:   "
             cBody2    += STR0042+Upper(AllTrim(Substr(cUsuario,7,15)))+ENTER //"Efetivado Por: "
             cBody2    += ""+ENTER
             cBody2    += STR0058+ENTER //"CANCELAMENTO DA EFETIVACAO DAS DESPESAS DE NUMERARIO"
             cBody2    += STR0052+TRB->EEU_DOCTO //"No. do Documento: "
             cBody2    += "<HTML>"       
             cBody2    += "<TABLE BORDER=0 CELLSPACING=10 WIDTH=100%>" 
             cBody2    += "<TR ALIGN=LEFT>"
             cBody2    += "<TH>"+STR0044    +"</TH>" //"Despesa"
             cBody2    += "<TH>"+STR0045   +"</TH>" //"Dt.Pagto"
             cBody2    += "<TH>"+STR0046   +"</TH>" //"Pago Por"
             cBody2    += "<TH>"+STR0047     +"</TH>" //"Adiant"
             cBody2    += "<TH>"+STR0048      +"</TH>" //"Valor"
             cBody2    += "<TH>"+STR0049   +"</TH>" //"Dt.Efet."
             cBody2    += "<TH>"+STR0050+"</TH>" //"Cod.Integr."
             cBody2    += "</TR>"                          
             cBody2    += "<TR ALIGN=LEFT>"
             cBody2    += "<TH>"+"_______________________"+"</TH>"
             cBody2    += "<TH>"+"________ "              +"</TH>"
             cBody2    += "<TH>"+"___________ "           +"</TH>"
             cBody2    += "<TH>"+"___________ "           +"</TH>"
             cBody2    += "<TH>"+"______ "                +"</TH>"
             cBody2    += "<TH>"+"________ "              +"</TH>"
             cBody2    += "<TH>"+"___________"            +"</TH>"
             cBody2    += "</TR>"
             DO While ! TRB->(Eof())
                IF ! EMPTY(TRB->EEU_DT_EFE)
                   If TRB->EEU_CODINT = cCodInt .And. TRB->EEU_DESPES $ cDebAut  // II  IPI ICM TX.SISCOMES
                      cBody    += "<TR ALIGN=LEFT>"
                      cBody    += "<TD>"+TRB->EEU_DESPES+" "+LEFT(POSICIONE("SYB",1,xFILIAL("SYB")+TRB->EEU_DESPES,"YB_DESCR"),20)+"</TD>"
                      cBody    += "<TD>"+If(TRB->(FieldPos("EEU_DTVENC")) > 0 .AND. !Empty(TRB->EEU_DTVENC),DTOC(TRB->EEU_DTVENC),DTOC(TRB->EEU_DT_DES))+"</TD>"
                      cBody    += "<TD>"+BSCXBOX("EEU_PAGOPO", AllTrim(TRB->EEU_PAGOPO))+"</TD>"
                      cBody    += "<TD>"+BSCXBOX("EEU_BASEAD", AllTrim(TRB->EEU_BASEAD))+"</TD>"
                      cBody    += "<TD>"+TransForm(TRB->EEU_VALOR,"@E 999,999.99")+"</TD>"
                      cBody    += "<TD>"+DTOC(TRB->EEU_DT_EFE)+"</TD>"
                      cBody    += "<TD>"+TRB->EEU_CODINT+"</TD>"
                      cBody    += "</TR>"
                      nValEfet += TRB->EEU_VALOR
                   ElseIf TRB->EEU_CODINT = cCodInt .And. TRB->EEU_BASEAD $ cSim .And. TRB->EEU_PAGOPO = "1" // Despesas adiantadas para o despachante
                          cBody2     += "<TR ALIGN=LEFT>"
                          cBody2     += "<TD>"+TRB->EEU_DESPES+" "+LEFT(POSICIONE("SYB",1,xFILIAL("SYB")+TRB->EEU_DESPES,"YB_DESCR"),20)+"</TD>"
                          cBody2     += "<TD>"+If(TRB->(FieldPos("EEU_DTVENC")) > 0 .AND. !Empty(TRB->EEU_DTVENC),DTOC(TRB->EEU_DTVENC),DTOC(TRB->EEU_DT_DES))+"</TD>"
                          cBody2     += "<TD>"+BSCXBOX("EEU_PAGOPO", AllTrim(TRB->EEU_PAGOPO))+"</TD>"
                          cBody2     += "<TD>"+BSCXBOX("EEU_BASEAD", AllTrim(TRB->EEU_BASEAD))+"</TD>"
                          cBody2     += "<TD>"+TransForm(TRB->EEU_VALOR,"@E 999,999.99")+"</TD>"
                          cBody2     += "<TD>"+DTOC(TRB->EEU_DT_EFE)+"</TD>"
                          cBody2     += "<TD>"+TRB->EEU_CODINT+"</TD>"
                          cBody2     += "</TR>"
                          nValEfetDe += TRB->EEU_VALOR
                   EndIf
                ENDIF
                TRB->(dbSkip())
             EndDo
             If nValEfet > 0
                cBody  += "</TABLE>" 
             EndIf
             If nValEfetDe > 0   
                cBody2 += "</TABLE>"   
             EndIf     
             If lEmail   
                If nValEfet > 0
                   cBody  += "_____________________________________________________________________________________"+ENTER
                   cBody  += STR0059+TransForm(nValEfet, "@E 9,999,999.99")+ENTER //"TOTAL DEBITO AUTOMATICO CANCELADO                 "
                   TelaMail(@cTo,@cCC,cSubject)
                   IF EMPTY(cCC)
                      cCC := AllTrim(aUsuario[1,14])         
                   ENDIF
                    oMail := TMailManager():New()
                    if lRelSLS
                      oMail:SetUseSSL( .T. )
                    elseif lRelTLS
                      oMail:SetUseTLS( .T. )
                    endif
                    oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
                    oMail:SetSmtpTimeOut( nTimeOut )
                    
                    nErro := oMail:SmtpConnect()
                    if nErro <> 0
                      cErrorMsg := oMail:GetErrorString( nErro )
                      easyhelp(STR0054+": "+cErrorMsg,STR0010) //"Falha na Conexao com Servidor de E-Mail"
                    Else
                      if lAutentica
                          nErro := oMail:SmtpAuth( cUserAut,cPassAut )
                          If nErro <> 0
                            cErrorMsg := oMail:GetErrorString( nErro )
                            easyhelp(STR0077+": "+cErrorMsg,STR0076) //"Falha na Autenticacao do Usuario" ### "Erro"
                            oMail:SMTPDisconnect()
                            If nErro <> 0
                              cErrorMsg := oMail:GetErrorString( nErro )
                              easyhelp(STR0078+cErrorMsg,STR0076) //"Erro na Desconexão: " ### "Erro"
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
                          easyhelp(STR0055+": "+cErrorMsg,STR0010) //"Falha no Envio de E-Mail"
                        EndIf

                        oMail:SMTPDisconnect()
                        If nErro <> 0
                          cErrorMsg := oMail:GetErrorString( nErro )
                          easyhelp(STR0078+cErrorMsg,STR0076) //"Erro na Desconexão: " ### "Erro"
                        endif

                      endif
                    Endif
                   nValEfet := 0 // By JPP - 29/02/2008 - 17:30
                EndIf
                If nValEfetDe > 0
                   cBody2 += "_____________________________________________________________________________________"+ENTER
                   cBody2 += STR0060+TransForm(nValEfetDesp, "@E 9,999,999.99")+ENTER //"TOTAL ADIANTAMENTO AO DESPACHANTE CANCELADO       "
                   TelaMail(@cTo2,@cCC2,cSubject)
                   IF EMPTY(cCC)
                      cCC := AllTrim(aUsuario[1,14])         
                   ENDIF

                    oMail := TMailManager():New()
                    if lRelSLS
                      oMail:SetUseSSL( .T. )
                    elseif lRelTLS
                      oMail:SetUseTLS( .T. )
                    endif
                    oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
                    oMail:SetSmtpTimeOut( nTimeOut )
                    
                    nErro := oMail:SmtpConnect()
                    if nErro <> 0
                      cErrorMsg := oMail:GetErrorString( nErro )
                      easyhelp(STR0054+": "+cErrorMsg,STR0010) //"Falha na Conexao com Servidor de E-Mail"
                    Else
                      if lAutentica
                          nErro := oMail:SmtpAuth( cUserAut,cPassAut )
                          If nErro <> 0
                            cErrorMsg := oMail:GetErrorString( nErro )
                            easyhelp(STR0077+": "+cErrorMsg,STR0076) //"Falha na Autenticacao do Usuario" ### "Erro"
                            oMail:SMTPDisconnect()
                            If nErro <> 0
                              cErrorMsg := oMail:GetErrorString( nErro )
                              easyhelp(STR0078+cErrorMsg,STR0076) //"Erro na Desconexão: " ### "Erro"
                            endif
                          endif
                      endif

                      if nErro == 0 
                        oMessage := TMailMessage():New()
                        oMessage:Clear()
                        oMessage:cFrom                  := cFrom
                        oMessage:cTo                    := cTo2
                        oMessage:cCc                    := cCC2
                        oMessage:cSubject               := cSubject
                        oMessage:cBody                  := cBody2

                        nErro := oMessage:Send( oMail )
                        if nErro <> 0
                          cErrorMsg := oMail:GetErrorString( nErro )
                          easyhelp(STR0055+": "+cErrorMsg,STR0010) //"Falha no Envio de E-Mail"
                        EndIf

                        oMail:SMTPDisconnect()
                        If nErro <> 0
                          cErrorMsg := oMail:GetErrorString( nErro )
                          easyhelp(STR0078+cErrorMsg,STR0076) //"Erro na Desconexão: " ### "Erro"
                        endif

                      endif
                    Endif
                   nValEfetDe := 0 // By JPP - 29/02/2008 - 17:30
                EndIf
             EndIf
          EndIf
      Next
   EndIf
   If lPoint_NU
      ExecBlock("EECPNU01",.F.,.F.,"CANC_EFETIV")
   EndIf
   aFornec := {}
   ProcRegua(TRB->(LastRec()))
   TRB->(dbGoTop())
   DO While ! TRB->(Eof())
      INCPROC(STR0061) //"Cancela Efetivacao das Despesas"
      If !Empty(TRB->EEU_DT_EFE) .And. TRB->EEU_CODINT == cCodInt //.And. TRB->EEU_POSIC == nREC    //MCF - 30/07/2014
                                                                  // NCF - 06/08/2014 - Nopado
         TRB->EEU_DT_EFE := cTod("")
         TRB->EEU_CODINT := ""
         TRB->EEU_LIBERA := ""
         IF TRB->RECNO > 0
            EEU->(dbGoTo(TRB->RECNO))
            
            //NCF - 06/08/2014  
            //Fazer Backup dos dados de efetivação para possivel reversão na integração
            If lIntLogix                       
               aAdd( aEEUEfetv,{ EEU->EEU_DT_EFE , EEU->EEU_CODINT , EEU->EEU_LIBERA , EEU->(Recno()) } )
            EndIf 
            
            EEU->(RecLock("EEU",.F.))
            EEU->EEU_DT_EFE := cTod("")
            EEU->EEU_CODINT := ""
            EEU->EEU_LIBERA := ""
            EEU->(MsUnlock())                  //NCF - 06/08/2014
         ENDIF
         nEfetiva := nEFETIVA-EEU->EEU_VALOR
         nNaoEfet := nNAOEFET+EEU->EEU_VALOR
      EndIf
      TRB->(dbSkip())
   EndDo
   TRB->(dbGoTop())
   EET->(DBSETORDER(1))
   EET->(DBSEEK(XFILIAL("EET")+AVKEY(EEC->EEC_PREEMB,"EET_PEDIDO")+OC_EM))


   /* WFS 03/02/2010
      Verifica se a integração com o Financeiro está habilidada.
      Quando estiver habilitada, exluir-se-a primeiramente no Financeiro
      todos os registros que possuem o mesmo código de integração (eeu_codint).
      Caso retorne que algum título não pode ser estornado, este não será excluído
      da tabela EET..*/

   If IsIntEnable("001")

      EET->(DBSetOrder(1)) //EET_FILIAL + EET_PEDIDO + EET_OCORRE

      Begin Transaction

         While EET->(!Eof()) .And.;
               EET->EET_FILIAL + EET->EET_PEDIDO + EET->EET_OCORRE == EET->(xFilial()) + AvKey(EEC->EEC_PREEMB, "EET_PEDIDO") + OC_EM
             
            EET->(RecLock("EET", .F.))
            If AllTrim(EET->EET_CODINT) == (cCodInt) .And. ((!EasyGParam('MV_EEC0043',,.F.) .And. !Empty(EET->EET_FINNUM)) .Or. (EasyGParam('MV_EEC0043',,.F.) .And. !Empty(EET->EET_PEDIDO)))

               //Inicia a exlusão do título a pagar
               cTitTemp:= EET->EET_FINNUM
               cTipoTit:= If(AllTrim(EET->EET_DESPES) == "901", "PA", "NF")
               If AvStAction("016")
                  EET->(DBDelete())
               Else
                  EET->EET_FINNUM:= cTitTemp
                  AAdd(aTitBaixa, EET->({AllTrim(EET_DESPES), AllTrim(EET_FINNUM)}))
               EndIf

            ElseIf AllTrim(EET->EET_CODINT) == (cCodInt) .And. Empty(EET->EET_FINNUM)
              EET->(DBDelete())
            EndIf

            EET->(MsUnlock())
            EET->(DBSkip())
         EndDo

      End Transaction

      Posicione("SX3", 2, "EET_DESPES", "X3_TITULO")
      cTxtDesp:= AllTrim(X3Titulo())
      Posicione("SX3", 2, "EET_FINNUM", "X3_TITULO")
      cTxtTit := AllTrim(X3Titulo())

      For nCont:= 1 To Len(aTitBaixa)
         cTitulos += ENTER
         cTitulos += cTxtDesp + ": " + aTitBaixa[nCont][1] + ", " + ;
                     cTxtTit  + ": " + aTitBaixa[nCont][2]
      Next

      If Len(aTitBaixa) > 0
         MsgInfo(STR0074 + cTitulos, STR0010) //O sistema não pode excluir a(s) despesa(s) abaixo. Consulte-a(s) no módulo SigaFin ou tente realizar esta operação a partir da manutenção do embarque. ############## / Aviso
      EndIf

   Else
      //NCF - 06/08/2014 - Inicia a bufferização para integração com Logix
      If lIntLogix
         If FindFunction("EasyEAIBuffer")
            lEaiBuffer := .T.
            EasyEAIBuffer("INICIO")
         EndIf
      EndIf
      
      DO WHILE ! EET->(EOF()) .AND.;
         EET->(EET_FILIAL+EET_PEDIDO+EET_OCORRE) = (XFILIAL("EET")+AVKEY(EEC->EEC_PREEMB,"EET_PEDIDO")+OC_EM)
         *
         IF EET->EET_CODINT = cCODINT
		    If AvStAction("016")
		       aAdd(aRecsEET,EET->(Recno()))           //NCF - 06/08/2014
               EET->(RECLOCK("EET",.F.))
               EET->(DBDELETE(),MSUNLOCK())
			EndIf
         ENDIF
         EET->(DBSKIP())
      ENDDO
      
      //NCF - 05/08/2014 - Executar a Integração com LOGIX 
      If lIntLogix
         If lEaiBuffer .And. !EasyEAIBuffer("FIM")
            //Montar aEasyBuffer para integrar reversão
            If FindFunction("EasyEAIBuffer")
               lEaiBuffer := .T.
               EasyEAIBuffer("INICIO")
            EndIf
            //Carrega Buffer dos registros da EET
            For i:=1 To Len(aRecsEET)
               EET->(DbGoTo(aRecsEET[i]))
               If EET->(FieldPos("EET_FINNUM")) > 0 .And. Empty(EET->EET_FINNUM)
                  AvStAction("015")
               EndIf
            Next i 
            //Executa a Integração(Inclusão dos títulos das despesas que tiveram seu título estornado)     
            EasyEAIBuffer("FIM")                 
            //Restaura EEU/TRB/Totalizadores
            For i:=1 To Len(aEEUEfetv)
               EEU->(DbGoTo(aEEUEfetv[i][4]))
               if EEU->(!eof()) .and. EEU->(RecLock("EEU",.F.))
                  EEU->EEU_DT_EFE := aEEUEfetv[i][1]
                  EEU->EEU_CODINT := aEEUEfetv[i][2]
                  EEU->EEU_LIBERA := aEEUEfetv[i][3]
                  EEU->(MsUnlock()) 
               endif
               nEfetiva += EEU->EEU_VALOR
               nNaoEfet -= EEU->EEU_VALOR 
               nOrder := TRB->(IndexOrd())
               TRB->(DbSetOrder(2))
               IF TRB->(DbSeek( aEEUEfetv[i][4] ))                      //NCF - 18/08/2014  
                  TRB->EEU_DT_EFE := aEEUEfetv[i][1]
                  TRB->EEU_CODINT := aEEUEfetv[i][2]
                  TRB->EEU_LIBERA := aEEUEfetv[i][3]
               EndIf 
               TRB->(DbSetOrder(nOrder))                               
            Next i      
         EndIf
         lIntLGXOK := .F.                                                        //NCF - 18/08/2014
      EndIf

   EndIf

END SEQUENCE
TRB->(DBGOTO(nREC))
Return(Nil)
*--------------------------------------------------------------------
Static Function TelaMail(cTo,cCC,cTitulo)
Local nOpcao:=0
DEFINE MSDIALOG oDlgMail TITLE cTitulo FROM @ 125,122 To 370,678 OF oMainWnd PIXEL
   @ 05,05  To 079,268                       OF oDlgMail PIXEL
   @ 18,13  Say STR0062 Size 012,08           OF oDlgMail PIXEL //"De: "
   @ 18,33  Get cFrom  Size 233,10 WHEN(.F.) OF oDlgMail PIXEL 
   *
   @ 33,13  Say STR0063 Size 016,08                       OF oDlgMail PIXEL //"Para:"
   @ 33,33  Get cTo     Size 233,10  VALID VALMAIL(cTo) OF oDlgMail PIXEL
   *
   @ 52,13  Say STR0064   Size 016,08 OF oDlgMail PIXEL //"CC:"
   @ 52,33  Get cCC     Size 233,10 OF oDlgMail PIXEL
   *
   DEFINE SBUTTON FROM 90,115 TYPE 1 ENABLE OF oDlgMail  ACTION (nOpcao:=1,oDlgMail:End())
ACTIVATE DIALOG oDlgMail Centered
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION VALMAIL(cGet)
Local lOK := .T.       
IF EMPTY(cGet)
   MsgInfo(STR0065,STR0010) //"Preencha com um endereco de E-Mail"
   lOK := .F.
ENDIF
RETURN(lOK)
*--------------------------------------------------------------------
STATIC FUNCTION NU400VAL(cP_IAE)
LOCAL lRET := .T.
IF cP_IAE # "E"
   IF ! OBRIGATORIO(aGETS,aTELA)
      lRET := .F.
   ELSEIF M->EEU_DESPES $ "101/104/901/902/903"
          MSGINFO(STR0066,STR0010) //"Este Codigo de Despesa nao pode ser Incluido !" ### Aviso
          lRET := .F.
   ENDIF
ENDIF
IF lPOINT_NU
   EXECBLOCK("EECPNU01",.F.,.F.,"VALID")
ENDIF
RETURN(lRET)
*--------------------------------------------------------------------

/*
Função      : GravaAgente()
Objetivo    : Verificar se a rotina de Numerário está preparada para
              o tratamento de Frete, Seguro e Comissão
Parametro   : Nenhum
Retorno     : .T./.F.
Autor       : Eduardo C. Romanini
Data e Hora : 29/05/2007
*/        
*---------------------------*
Static Function GravaAgente()
*---------------------------*
Local lRet := .F.

Local aCmp := {}
Local j    := 0

Begin Sequence
   
   If !EECFlags("FRESEGCOM")
      Break
   EndIf

   If EEU->(FieldPos("EEU_CODAGE")) > 0 .And. EEU->(FieldPos("EEU_TIPOAG")) > 0// .And.;

      /*
         Implementado consistência abaixo, para verificar a existencia de campos virtuais
         no dicionário de dados.
      */               
      aCmp := {"EEU_NOME"}

      For j := 1 To Len(aCmp)
         If !AvSX3(aCmp[j],,, .T.)
            Break
         EndIf
      Next

      lRet := .T.

   EndIf

End Sequence

Return lRet 

/*
Função      : NU400CpoValid()
Objetivo    : Realiza validações diversas para os campos
Parametro   : cCampo := Nome do Campo
Retorno     : .T./.F.
Autor       : Eduardo C. Romanini
Data e Hora : 29/05/2007
*/        
*----------------------------*
Function NU400CpoValid(cCampo)
*----------------------------*
Local lRet := .T.

Begin Sequence

   Do Case
      Case cCampo == "EEU_CODAGE"
           
           SY5->(DbSetOrder(1)) 
           If SY5->(DbSeek(xFilial("SY5")+M->EEU_CODAGE))
              If Left(SY5->Y5_TIPOAGE,1) == "3" //Agente Recebedor de Comissão.
                 MsgInfo(STR0070,STR0069)//"Para a Manutenção de Numerário o agente informado não pode ser Recebedor de Comissão."###"Atenção"
                 lRet := .F.
                 Break
              EndIf
           
              If Empty(SY5->Y5_FORNECE) .or. Empty(SY5->Y5_LOJAF)
                 MsgInfo(STR0071,STR0069)//"Empresa não permitida por não haver vinculo com o Fornecedor/Loja."###"Atenção"
                 lRet := .F.
                 Break
              EndIf
              
              M->EEU_TIPOAG:= SY5->Y5_TIPOAGE
              M->EEU_NOME  := SY5->Y5_NOME
           EndIf

   End Case

End Sequence

Return lRet

/*
Função      : NU400ValPos()
Objetivo    : Gera o campo posição da desepsa
Parametro   : cProcesso := Numero do Processo
Retorno     : cCount
Autor       : Marcos Cavini Filho
Data e Hora : 30/07/2014
Obs:Foi criado um campo adicional na tabela de despesa (EEU_POSIC) para ser utilizado como indíce,
sendo assim essa função responsável por gerar os numeros para este campo. Com essa alteração é permitido a inserção 
de duas despesas iguais.
  */    
*----------------------------*
Function NU400ValPos(cProcesso)
*----------------------------*
Local nCount := 0,nPosi
Local aOrd := SaveOrd({"TRB"})
Local nOrd := TRB->(IndexOrd())
Local nReg := TRB->(RecNo())

TRB->(DbGoTop())
If TRB->(!Eof())  
   IndRegua("TRB",cWORKEEU+TEOrdBagExt(),"STR(EEU_POSIC,4,0)")
   Do While TRB->(!Eof())
	  nCount++
	  nPosi := TRB->EEU_POSIC
	  TRB->(DbSkip())
   EndDo
EndIf
   
If nCount == 0
	nCount := 1
Else
 	If nCount == nPosi
		nCount := nCount+1
	Else
		nCount := nPosi+1
	EndIf
EndIf
                                       
RestOrd(aOrd)
TRB->(dbSetOrder(nOrd),dbGoTo(nReg))
Return nCount

/*
Função      : NU400BancoSE5()
Objetivo    : Apresenta tela de Seleção de Banco
Retorno     : -
Autor       : Marcos Roberto Ramos Cavini Filho
Data e Hora : 17/06/2015
*/    
*----------------------------*
Function NU400BancoSE5(lRet)
*----------------------------*
Local nOp:=0
Default lRet := .T.
cBancoSE5   := Space(AVSX3("A6_COD",3))
cAgenciaSE5 := Space(AVSX3("A6_AGENCIA",3))
cContaSE5   := Space(AVSX3("A6_NUMCON",3))
cNomeSE5    := Space(AVSX3("A6_NOME",3))
cDTVcSE5    := dDataBase
cNaturezaPA := AvKey(EasyGParam("MV_AVG0187",, ""),"E2_NATUREZ")

	DEFINE MSDIALOG oDlgF TITLE AVSX3("EEQ_BANC",5) FROM 091,232 TO 310 ,905 OF oMainWnd PIXEL
	
	oPanel:= TPanel():New(0, 0, "", oDlgF,, .F., .F.,,, 50, 165)
	oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

  If( EasyEntryPoint("EECNU400") , ExecBlock("EECNU400",.F.,.F.,{"CARREGA_BANCO"}) , ) //LRS - 28/11/2017

	//RMD - 11/04/17 - Revisão das validações/Pictures
	@ 012,012 Say AVSX3("A6_COD",5)           PIXEL of oPanel
	@ 012,048 MSGET cBancoSE5  Picture AVSX3("A6_COD",AV_PICTURE) F3 "SA6" Valid /*NAOVAZIO(cBancoSE5) .And. NU400ValidaBanco(cBancoSE5)*/NU400ValidaBanco() SIZE 060,008 PIXEL HASBUTTON of oPanel
	@ 012,112 Say AVSX3("A6_AGENCIA",5)       PIXEL of oPanel
   	@ 012,148 MSGET cAgenciaSE5  Picture AVSX3("A6_AGENCIA",AV_PICTURE)             Valid /*NAOVAZIO(cAgenciaSE5)*/NU400ValidaBanco(.T.) SIZE 060,008  PIXEL of oPanel
   	@ 012,212 Say AVSX3("A6_NUMCON",5)  PIXEL of oPanel
   	@ 012,248 MSGET cContaSE5          Picture AVSX3("A6_CONTA",AV_PICTURE)       Valid /*NAOVAZIO(cContaSE5)*/NU400ValidaBanco(,.T.) SIZE 060,008  PIXEL of oPanel
   	@ 028,012 Say AVSX3("A6_NOME",5)          PIXEL of oPanel
   	@ 028,048 MSGET cNomeSE5          When .F.        SIZE 260,008  PIXEL of oPanel
    // MPG - INCLUSAO DE DATA DE VENCIMENTO PARA O ITEM DE DESPESA
   	@ 044,012 Say AVSX3("EEU_DTVENC",5)       PIXEL of oPanel
   	@ 044,048 MSGET cDTVcSE5 Picture AVSX3("EEU_DTVENC",AV_PICTURE) Valid NUValidaData() SIZE 060,008 PIXEL HASBUTTON of oPanel
   	If IsIntEnable("001")
         @ 044,112 Say AVSX3("E2_NATUREZ",5)       PIXEL of oPanel
         @ 044,148 MSGET cNaturezaPA  Picture AVSX3("E2_NATUREZ",AV_PICTURE) F3 "SED"            Valid Vazio() .Or. ExistCpo("SED",cNaturezaPA,1) SIZE 060,008  PIXEL of oPanel HASBUTTON
      EndIf
   	ACTIVATE MSDIALOG oDlgF ON INIT EnchoiceBar(oDlgF,{|| If(NAOVAZIO(cBancoSE5) .And. NAOVAZIO(cAgenciaSE5) .And. NAOVAZIO(cContaSE5) .And. IIF(IsIntEnable("001"), NAOVAZIO(cNaturezaPA),.T.), (nOp:=1,oDlgF:End()), Nil)},{||nOp:=0,oDlgF:End()}) CENTERED
   	
   	IF nOp=1
   		lRet:=.T.
   	ELSE
   		lRet:=.F.
   	ENDIF

RETURN(lRet)

/*
Função      : NUValidaData()
Objetivo    : Validação de data de efetivação de numerario
Retorno     : -
Autor       : Miguel Prado Gontijo
Data e Hora : 16/01/2018
*/
Static Function NUValidaData()
Local lRet := .T.

If Empty(cDTVcSE5)
  MsgInfo( STR0080, STR0010 ) // "A data de vencimento não pode estar em branco."
  lRet := .F.  
ElseIf cDTVcSE5 < dDataBase
  MsgInfo( STR0081, STR0010 ) // "A data de vencimento não pode ser menor que a data base."
  lRet := .F.
EndIf

Return lRet
/*
Função      : NU400ValidaBanco()
Objetivo    : Validação de Banco
Retorno     : -
Autor       : Marcos Roberto Ramos Cavini Filho
Data e Hora : 17/06/2015
*/    
*----------------------------*
Function NU400ValidaBanco(lAgencia, lConta)
*----------------------------*
Local lRet := .T.
Default lAgencia := .F.
Default lConta := .F.

/*
IF !EMPTY(cBancoSE5)
   SA6->(DBSETORDER(1))
   IF !(SA6->(DBSEEK(XFILIAL("SA6")+cBancoSE5)))
      HELP(" ",1,"AVG0005104") //MSGINFO("Banco Inválido","Atenção")
      RETURN(.F.)
   ENDIF
   
   cBancoSE5   := SA6->A6_COD
   cAgenciaSE5 := SA6->A6_AGENCIA
   cContaSE5   := SA6->A6_NUMCON
   cNomeSE5    := SA6->A6_NOME
   
ENDIF
*/
   If !Empty(cBancoSE5) .And. (!Empty(cAgenciaSE5) .Or. !lAgencia) .And. (!Empty(cContaSE5) .Or. !lConta)
      SA6->(DBSETORDER(1))
      If !(lRet := SA6->(DbSeek(xFilial()+cBancoSE5+If(!Empty(cAgenciaSE5),cAgenciaSE5,"")+If(!Empty(cContaSE5),cContaSE5,""))))
         lRet := ExistCpo("SA6", cBancoSE5+If(lAgencia .Or. lConta, cAgenciaSE5, "")+If(lConta, cContaSE5, ""))
      EndIf
      If lRet
         cBancoSE5   := SA6->A6_COD
         cAgenciaSE5 := SA6->A6_AGENCIA
         cContaSE5   := SA6->A6_NUMCON
         cNomeSE5 := SA6->A6_NOME
      EndIf
   Else
      If !lAgencia .And. !lConta
         cBancoSE5   := Space(AVSX3("A6_COD",3))
      EndIf
      If lAgencia .Or. !lConta
         cAgenciaSE5 := Space(AVSX3("A6_AGENCIA",3))
      EndIf
      If lConta .Or. !lAgencia
         cContaSE5   := Space(AVSX3("A6_NUMCON",3))
      EndIf
      cNomeSE5    := Space(AVSX3("A6_NOME",3))
   EndIf

Return lRet
