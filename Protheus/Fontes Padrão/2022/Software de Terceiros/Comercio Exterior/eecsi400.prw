/*
Programa..: EECSI400.PRW
Objetivo..: Geracao de DDE
Autor.....: Luciano Campos de Santana
Data/Hora.: 27/05/2002 - 10:54
Obs.......:
*/
#INCLUDE "EEC.CH"
#include "DBTREE.ch"
#INCLUDE "eecsi400.ch"
#DEFINE BLOCK_READ 1024    // Blocos de leitura
#DEFINE FO_READ       0    // Open for reading (default)
#DEFINE FO_EXCLUSIVE 16    // Exclusive use (other processes have no access)
#Define Prepara 3          // Opção selecionada..

#Define NAO_ENVIADO	"N"
#Define ENVIADO		"E"
#Define ENTER CHR(13)+CHR(10)
*--------------------------------------------------------------------
FUNCTION EECSI400()

LOCAL aORD := SAVEORD({"EEC","EEX","EEZ"}),;
      cFILEXT
Local aStatus:= {}

If Type("lDSE") = "U"
   Private lDSE := .F.
EndIf

PRIVATE cCadastro := If(lDSE, STR0061, STR0001),;   //"Geração de DDE"
        cPATHOR   := ALLTRIM(EasyGParam("MV_AVG0002")),; //Path para gravacao dos txt
        cPATHDT   := ALLTRIM(EasyGParam("MV_AVG0003")),; //Path de Retorno do txt
        aROTINA   := MenuDef(If(ProcName(1) == "EECSI40A", "EECSI40A", "EECSI400"))

Private aFilesDir := Directory(cPathOr)//FSY-19/12/2013

BEGIN SEQUENCE
   //LGS-09/06/2015 - Trava para não permitir utilizar a rotina antiga quando já se criou uma DDE-Web através na rotina na central de integrações.
   /*If EEX->(FieldPos("EEX_ID"))>0 .And. EEZ->(FieldPos("EEZ_ID"))>0
      EEX->(Bof())
      If !Empty(EEX->EEX_ID)
         MsgInfo("Não é possivel utilizar esta rotina para este processo. Consultar a integração de DDE através da rotina 'Siscomex Web'.","Atenção")
         Break
      EndIf
   EndIf*/

   cFILEXT := ALLTRIM(EasyGParam("MV_AVG0024",,""))
   cFILEXT := IF(cFILEXT=".","",cFILEXT)
   If !Empty(EasyGParam("MV_AVG0023",,"")) .And. !Empty(cFILEXT) .And.;
      (EE7->(FieldPos("EE7_INTERM")) # 0) .And. (EE7->(FieldPos("EE7_COND2")) # 0) .And.;
      (EE7->(FieldPos("EE7_DIAS2")) # 0) .And. (EE7->(FieldPos("EE7_INCO2")) # 0) .And.;
      (EE7->(FieldPos("EE7_PERC")) # 0) .And. (EE8->(FieldPos("EE8_PRENEG")) # 0) .AND.;
      cFILEXT = XFILIAL("EEC")
      *
      MSGINFO(STR0101,STR0011) //"Filial do Exterior não pode gerar dados para o SISCOMEX !"###"Atenção"
      BREAK
   ENDIF
   // VERIFICANDO A EXISTENCIA DOS DIRETORIOS DO SISCOMEX
   cPATHOR := cPATHOR+IF(RIGHT(cPATHOR,1)="\","","\")
   cPATHDT := cPATHDT+IF(RIGHT(cPATHDT,1)="\","","\")
   IF ! LISDIR(LEFT(cPATHOR,LEN(cPATHOR)-1))
      MSGINFO(STR0006+cPATHOR+STR0007,STR0008) //"Diretorio para gravacao do txt não existe ("###") !"###"Aviso"
      BREAK
   ELSEIF ! LISDIR(LEFT(cPATHDT,LEN(cPATHDT)-1))
          MAKEDIR(cPATHDT)
   ENDIF

   //WFS 19/06/09 ---
   //FSY - 12/12/2013 - Ajuste do status para aumentar o desempenho.
   //Flags de Status
   AAdd(aStatus, {"EEX->(DBSeek(xFilial() + EEC->EEC_PREEMB)) .And. !Empty(EEX->EEX_NUM)"         , "BR_AZUL"    })
   AAdd(aStatus, {"EEX->(DBSeek(xFilial() + EEC->EEC_PREEMB)) .And. " +;
                         "Empty(EEX->EEX_NUM)                 .And. " +;
                         "!Empty(EEX->EEX_TXTSIS)             .And. " +;
                         "Len(Si400File(cPathOr + SubStr(EEX->EEX_TXTSIS, 1, 8) + '.ok')) > 0"    , "BR_VERMELHO"})

   AAdd(aStatus, {"EEX->(DBSeek(xFilial() + EEC->EEC_PREEMB)) .And."  +;
                         "Empty(EEX->EEX_NUM)                 .And."  +;
                         "!Empty(EEX->EEX_TXTSIS)             .And."  +;
                         "Len(Si400File(cPathOr + SubStr(EEX->EEX_TXTSIS, 1, 8) + '.inc')) > 0"   , "BR_LARANJA" })

   AAdd(aStatus, {"EEX->(DBSeek(xFilial() + EEC->EEC_PREEMB)) .And."  +;
                         "Empty(EEX->EEX_NUM)                 .And."  +;
                         "(Empty(EEX->EEX_TXTSIS)             .Or. "  +;
                         "(!Empty(EEX->EEX_TXTSIS)            .And."  +;
                         "Len(Si400File(cPathOr + SubStr(EEX->EEX_TXTSIS, 1, 8) + '.ok')) == 0))" , "BR_AMARELO" })

   AAdd(aStatus, {"!EEX->(DBSeek(xFilial() + EEC->EEC_PREEMB))"                                   , "BR_VERDE"   })
   //---

   DBSELECTAREA("EEC")
   EEC->(DBSETORDER(1))
   MBROWSE(06,01,22,75,"EEC",,,,,,aStatus)
END SEQUENCE
RESTORD(aORD)
RETURN(NIL)
*--------------------------------------------------------------------
FUNCTION SI400MAN(cP_ALIAS,nP_REG,nP_OPC, lShowDlg, lNewDDE)
LOCAL Z,/*oDLG,*/aPOS,/*nBTOP,*/bCANCEL,aSEMSX3,aORD,aRE,;
      nQTDEM1,aEMBA,c1,aNF
Local nPesLiq, nPesTot
Local lDDEWeb
Local aCmpNotDSE  := {}
Local aCmpDSE     := {}
Local nPos        := 0
Local cNFs        := ""
Local aOpc        := {STR0067, STR0068, STR0098, STR0099} //"Preparação"###"Geração"###"Retorno"###"Estorno"
Local lDetMSGetdb := EasyGParam("MV_AVG0093",, .F.)
//Local oGetdb
Local lLockEEX := .F., lLockEEC := .F. // JPM - 21/02/06
Local oFld
// Local cUnKg := EasyGParam("MV_AVG0031",, ".")
Local aDelEEZ := {}, i, y
Local aCpsTWY := {}
Private oDlg, nBTop
Private cUnKg := EasyGParam("MV_AVG0031",, ".")
PRIVATE aBUTTONS,aCAMPOS,aHEADER,cWORKEEZ,aCAMPOTMZ,lINVERTE,cMARCA,aDELETE,;
        cUSER,lALTERA

Private aFieldEspecie := {}
Private aFieldRE      := {}
PRIVATE oGetdb, oGetdbNF, oGetdbRE // by CRF - 04/05/2011 - passado para Private para criar um tratamento de Refresh especifico
PRIVATE aTELA[0,0],aGETS[0]
Private oMSELECT     // JPP - 18/05/2005 - 15:30 - Esta variavel deixou de ser local para ser visivel em outras funções.
Private aENCHOICE    // By JPP - 23/11/2006 - 13:40 - Passado de local para private, para customização em ponto de entrada.
Private oGetTotNFs
Private nGetTotNFs := 0
Private lTabConvUnid := Select("SJ5") <> 0
Private bOk
Private lSair := .F.  // DFS - Criação da variável para alteração no ponto de entrada
//TRP - 09/01/07 - Para acesso via ponto de entrada
PRIVATE nP_OPC_Aux:= nP_OPC, lVal_EEX := .T., /*lShowDlg := .T.,*/ cChaveEEX, cChaveEEZ, cChaveEE9
//WFS 16/06/09 ---
Default lShowDlg:=  .T.
Default lNewDDE :=  .F.

//LGS - 17/06/2015 - Nova rotina de DE-WEB
lDDEWeb := (EEX->(FieldPos("EEX_ID"))>0 .And. EEZ->(FieldPos("EEZ_ID"))>0 .And. lNewDDE)

If ValType(lShowDlg) <> "L"
   lShowDlg:=  .T.
EndIf

If Type("cPathOr") == "U"
   cPathOr:= AllTrim(EasyGParam("MV_AVG0002")) //Path para gravaçãoo dos txts
   cPathOr:= cPathOr + If(Right(cPathOr, 1) = "\", "", "\")
EndIf
If Type("cPathDt") == "U"
   cPathDt:= AllTrim(EasyGParam("MV_AVG0003")) //Path de Retorno do txt
   cPathDt:= cPathDt + If(Right(cPathDt, 1) = "\", "", "\")
EndIf
If Type("lDSE") = "U"
   Private lDSE:= .F.
EndIf
//---
IF SX2->(DbSeek("SJ5"))
   lTabConvUnid := .T.
Else
   lTabConvUnid := .F.
EndIF
__KeepUsrFiles := .F.//FSY - 10/10/2013 - variavel private utilizada para habilitar a EECCTRIATRAB()
EECSetKeepUsrFiles() //FSY - 10/10/2013 - função responsavel para validar a variavel __KeepUsrFiles
*
BEGIN SEQUENCE
   aORD      := SAVEORD({"SA2","SYQ","EE9","EE5","EEM","EE9"})

   If lDDEWeb
      cChaveEEX := XFILIAL("EEX")+EEC->EEC_PREEMB+EWJ->EWJ_ID
      cChaveEEZ := XFILIAL("EEZ")+EEC->EEC_PREEMB+EWJ->EWJ_ID
   Else
      cChaveEEX := XFILIAL("EEX")+EEC->EEC_PREEMB
      cChaveEEZ := XFILIAL("EEZ")+EEC->EEC_PREEMB
   EndIf

   lSair := .F. // DFS - Criação de variável para ponto de entrada
   If EasyEntryPoint("EECSI400")
      ExecBlock("EECSI400", .F., .F., {"PE_SI400MAN_INI"})
   EndIf
   If lSair
      Return Nil
   Endif

   EEX->(DBSETORDER(1))
   EEX->(DBSEEK(cChaveEEX))
   // ** JPM - 21/02/06 - Controle de usuários
   IF nP_OPC = 3 .Or. nP_OPC = 4 // Gera ou Prepara
      If !EECLock("EEC")
         Break
      EndIf
      lLockEEC := .T.
   EndIf

   If nP_OPC = 3 .Or. nP_OPC = 5 .Or. nP_OPC = 6 // Prepara, Retorno ou Estorno
      If EEX->(Found())
         If !EECLock("EEX")
            Break
         EndIf
         lLockEEX := .T.
      EndIf
   EndIf
   // ** JPM - Fim

   EEX->(DBSETORDER(1))
   EEX->(DBSEEK(cChaveEEX))
   nBTOP     := nQTDEM1 := 0
   lINVERTE  := .F.
   lALTERA   := .T.
   cWORKEEZ  := cUSER := ""
   cMARCA    := GETMARK()
   aCAMPOTMZ := ARRAYBROWSE("EEZ","TMZ")
   aCAMPOS   := ARRAY(EEX->(FCOUNT()))
   aNF       := {}
   aEMBA     := {}
   aRE       := {}
   aDELETE   := {}
   aHEADER   := {}
   aBUTTONS  := {}
   bOK       := {|| nBTOP := 1, If(SI400VldPre( lDDEWeb ), oDlg:End(),)}
   bCANCEL   := {|| nBTOP := 0, oDLG:END()}
   aSEMSX3   := {{"TMZ_RECNO","N",07,0}}
   aENCHOICE := {"EEX_PREEMB","EEX_CNPJ"  ,"EEX_CNPJ_R","EEX_VIAINT","EEX_PESLIQ",;
                 "EEX_PESBRU","EEX_TOTCV" ,"EEX_QTDEST","EEX_SDLNA" ,"EEX_ID_VT" ,;
                 "EEX_CARGAF","EEX_DPOST" ,"EEX_QTDTOT",;
                 "EEX_ESP1"  ,"EEX_QTD1"  ,"EEX_MARK1" ,"EEX_ESP2"  ,"EEX_QTD2"  ,;
                 "EEX_MARK2" ,"EEX_ESP3"  ,"EEX_QTD3"  ,"EEX_MARK3" ,"EEX_ESP4"  ,;
                 "EEX_QTD4"  ,"EEX_MARK4" ,"EEX_ESP5"  ,"EEX_QTD5"  ,"EEX_MARK5" ,;
                 "EEX_ESP6"  ,"EEX_QTD6"  ,"EEX_MARK6" ,"EEX_ESP7"  ,"EEX_QTD7"  ,;
                 "EEX_MARK7" ,"EEX_DVIAIN","EEX_DESP1" ,"EEX_DESP2" ,"EEX_DESP3" ,;
                 "EEX_DESP4" ,"EEX_DESP5" ,"EEX_DESP6" ,"EEX_DESP7"}
   *
   If !lDDEWeb
      aENCHOICE := {"EEX_RE1"   ,"EEX_RE1C"  ,"EEX_RE2"   ,"EEX_RE2C"  ,"EEX_RE3"   ,;
      				"EEX_RE3C"  ,"EEX_RE4"   ,"EEX_RE4C"  ,"EEX_RE5"   ,"EEX_RE5C"  ,;
      				"EEX_RE6"   ,"EEX_RE6C" }
   EndIf

   If EEX->(FieldPos("EEX_RLFJ")) > 0
      aAdd(aEnchoice, "EEX_RLFJ")
   EndIf

   If !lDse   // By JPP - 21/03/2007 - 09:00 - Campo utilizado para preenchimento de uma nova perguanta na tela do Siscomex(DDE), para destino final MercoSul
      If EEX->(FieldPos("EEX_PTCROM")) > 0
         aAdd(aEnchoice, "EEX_PTCROM") // Nesta DDE existem mercadorias amparadas por CCPTC ou CCROM? (S/N):
      EndIf
   EndIf

   If lDDEWeb
      aAdd(aEnchoice, "EEX_ID")
      aAdd(aEnchoice, "EEX_TRANS")
      aAdd(aEnchoice, "EEX_CUBAGE")
      aAdd(aEnchoice, "EEX_ULDESP")
      aAdd(aEnchoice, "EEX_ULEMBA")
      aAdd(aEnchoice, "EEX_TIPOPX")
      aAdd(aEnchoice, "EEX_DETOPX")
      aAdd(aEnchoice, "EEX_SDETOP")
      //LGS-06/01/2016
      If EEX->(FieldPos("EEX_ODLTIP")) > 0
         aAdd(aEnchoice, "EEX_ODLTIP")
         aAdd(aEnchoice, "EEX_ODLIDT")
      EndIf
   EndIf

   IF EEC->EEC_STATUS = ST_PC
      MSGINFO(STR0009,STR0008) //"Processo de exportação cancelado"###"Aviso"
      BREAK
   ENDIF

   If lDSE

      /*
      AMS - 23/12/2004 às 10:47 - DSE. Condição para não permitir a preparação ou geração de DSE, quando o embarque
                                       estiver embarcado ou possuir itens com RE ou DDE.
      */
      If nP_OPC >= 3

         If !Empty(EEC->EEC_DTEMBA)
            MsgStop(aOpc[nP_OPC-2]+STR0066, STR0011) //"de DSE não permitida para este embarque, pois o mesmo já se encontra embarcado."###"Atenção"
            Break
         EndIf

         EE9->(dbSetOrder(2))
         EE9->(dbSeek(xFilial()+EEC->EEC_PREEMB))

         While EE9->(!Eof() .and. EE9_PREEMB == EEC->EEC_PREEMB)

            If EE9->(!Empty(EE9_RE) .or. !Empty(EE9_NRSD))
               MsgStop(aOpc[nP_OPC-2]+STR0065, STR0011) //"de DSE não permitida para este embarque, pois existem itens com RE ou DDE."###"Atenção"
               Break
            EndIf

            EE9->(dbSkip())

         End

      EndIf

      /*
      Remove campos não utilizados na preparação da DSE.
      */
      aCmpNotDSE := { "EEX_PESLIQ", "EEX_QTDEST", "EEX_SDLNA",;
                      "EEX_CARGAF", "EEX_DPOST",  "EEX_RE1"  ,;
                      "EEX_RE1C",   "EEX_RE2",    "EEX_RE2C" ,;
                      "EEX_RE3",    "EEX_RE3C",   "EEX_RE4"  ,;
                      "EEX_RE4C",   "EEX_RE5",    "EEX_RE5C" ,;
                      "EEX_RE6",    "EEX_RE6C" }

      For z := 1 To Len(aCmpNotDSE)

         If (nPos := aScan(aEnchoice, aCmpNotDSE[z])) > 0
            aDel(aEnchoice, nPos)
            aSize(aEnchoice, Len(aEnchoice)-1)
         EndIf

      Next

      /*
      Adiciona campos para preparação da DSE.
      */
      aCmpDSE := { "EEX_TIPEXP", "EEX_NATUOP", "EEX_DESCNO",;
                   "EEX_DOCIN1", "EEX_DOCIN2", "EEX_DOCIN3",;
                   "EEX_INFCO1", "EEX_INFCO2", "EEX_INFCO3",;
                   "EEX_ULDESP", "EEX_ULEMBA", "EEX_CSA",   ;
                   "EEX_CSATIP", "EEX_NF1",    "EEX_NF2",   ;
                   "EEX_NF3" }

      /*
      aFieldEspecie := FieldEspecie()

      For z := 1 To Len(aFieldEspecie)

         For nPos := 1 To 4

            If aScan(aEnchoice, aFieldEspecie[z][nPos]) = 0
               aAdd(aEnchoice, aFieldEspecie[z][nPos])
            EndIf

         Next

      Next
      */

      For z := 1 To Len(aCmpDSE)

         If aScan(aEnchoice, aCmpDSE[z]) = 0
            aAdd(aEnchoice, aCmpDSE[z])
         EndIf

      Next

   Else

      /*
      AMS - 21/03/2005. Implementação para adicionar os campos de finalidade 1,2 e 3.
      */
      If EEX->( FieldPos("EEX_FNLDD1") > 0 .and.;
                FieldPos("EEX_FNLDD2") > 0 .and.;
                FieldPos("EEX_FNLDD3") > 0 )

         If aScan(aEnchoice, "EEX_FNLDD1") = 0
            aAdd(aEnchoice, "EEX_FNLDD1")
         EndIf

         If aScan(aEnchoice, "EEX_FNLDD2") = 0
            aAdd(aEnchoice, "EEX_FNLDD2")
         EndIf

         If aScan(aEnchoice, "EEX_FNLDD3") = 0
            aAdd(aEnchoice, "EEX_FNLDD3")
         EndIf

      EndIf

      /*
      AMS - 17/01/2005. Implementação para adicionar até 99 grupo de campos para o RE.
      */
      aFieldRE := FieldRE()

      For z := 1 To Len(aFieldRE)

         If aScan(aEnchoice, aFieldRE[z][1]) = 0
            aAdd(aEnchoice, aFieldRE[z][1])
         EndIf

         If aScan(aEnchoice, aFieldRE[z][2]) = 0
            aAdd(aEnchoice, aFieldRE[z][2])
         EndIf

      Next

   EndIf

   /*
   AMS - 17/01/2005 às 18:00 Implementação para permitir a geração de até 99 espécies para DDE/DSE.
   */
   aFieldEspecie := FieldEspecie()

   If lDDEWeb
      aSaveOrd := SaveOrd("SX3", 2)
      If SX3->(dbSeek("EEX_PESB"))
         nFieldQTD := 5
      EndIf
      RestOrd(aSaveOrd)
   Else
      nFieldQTD := 4
   EndIf

   For z := 1 To Len(aFieldEspecie)
      For nPos := 1 To nFieldQTD
         If aScan(aEnchoice, aFieldEspecie[z][nPos]) = 0
            aAdd(aEnchoice, aFieldEspecie[z][nPos])
         EndIf
      Next
   Next

   IF nP_OPC = 2  // VISUALIZA
      IF lVal_EEX .And. !EEX->(FOUND())
         MSGINFO(If(lDSE, STR0062, STR0010) ,STR0011) //"Processo nao possui dados a visualizar. Gere a DDE primeiro !"###"Atenção"
         BREAK
      ENDIF
      If lDSE
         aAdd(aEnchoice, "EEX_NDSE")
         aAdd(aEnchoice, "EEX_DDSE")
      Else
         AADD(aENCHOICE,"EEX_NUM")
         AADD(aENCHOICE,"EEX_DATA")
      EndIf
      lALTERA := .F.
   ELSEIF nP_OPC = 3  // PREPARA
          // JPM - já faz o lock no começo. EEC->(RECLOCK("EEC",.F.))
          IF lVal_EEX .And. EEX->(FOUND())
             IF ! EMPTY(EEX->EEX_NUM)
                MSGINFO(If(lDSE, STR0063, STR0012), STR0011) //"Processo já possui número de DDE !"###"DSE"###"Atenção"
                If lDSE
                   aAdd(aEnchoice, "EEX_NDSE")
                   aAdd(aEnchoice, "EEX_DDSE")
                Else
                   AADD(aENCHOICE,"EEX_NUM")
                   AADD(aENCHOICE,"EEX_DATA")
                EndIf
                lALTERA  := .F.
                EEC->(MSUNLOCK())
             ELSE
                If !lDetMSGetdb .And. !lDDEWeb
                   // CARREGA OS BOTOES DE INCLUSAO, ALTERACAO E EXCLUSAO
                   // conteudo oMSELECT abaixo foi comentado pois o refresh foi criado direto na função SI400IAE  -CRF 04/05/2011
                   AADD(aBUTTONS,{"BMPINCLUIR" /*"EDIT"*/   ,{|| SI400IAE("I",lDDEWeb),/*oMSELECT:oBrowse:Refresh()*/},STR0014}) //"Incluir"
                   AADD(aBUTTONS,{"EDIT" /*"ALT_CAD"*/,{|| SI400IAE("A",lDDEWeb),/*oMSELECT:oBrowse:Refresh()*/},STR0015}) //"Alterar"
                   AADD(aBUTTONS,{"EXCLUIR",{|| SI400IAE("E",lDDEWeb),/*oMSELECT:oBrowse:Refresh()*/},STR0016}) //"Excluir"
                EndIf
             ENDIF
          ELSE
             If !lDetMSGetdb .And. !lDDEWeb
                // CARREGA OS BOTOES DE INCLUSAO, ALTERACAO E EXCLUSAO
                AADD(aBUTTONS,{"BMPINCLUIR" /*"EDIT"*/   ,{|| SI400IAE("I",lDDEWeb),/*oMSELECT:oBrowse:Refresh()*/},STR0014}) //"Incluir"
                AADD(aBUTTONS,{"EDIT" /*"ALT_CAD"*/,{|| SI400IAE("A",lDDEWeb),/*oMSELECT:oBrowse:Refresh()*/},STR0015}) //"Alterar"
                AADD(aBUTTONS,{"EXCLUIR",{|| SI400IAE("E",lDDEWeb),/*oMSELECT:oBrowse:Refresh()*/},STR0016}) //"Excluir"
             EndIf
          ENDIF

          /*
          DSE - Retira os botões para matenção dos detalhes da DDE.
          */
          If lDSE
             aButtons := {}
          EndIf

   ELSEIF nP_OPC = 4  // GERA
          If SI400HaArq()  .And. !lDSE// By JPP - 15/07/2005 9:40 - O usuário deverá processar a rotina de retorno antes de
             Msginfo(STR0123,STR0011) // "Antes da Geração é necessário processar as rotinas de retorno."###"Atenção"
             Break
          EndIf
          If lVal_EEX .And. !Empty(EEX->EEX_NUM)
             MsgInfo(If(lDSE, STR0063, STR0012), STR0011) //"Processo já possui número de DDE !"###"DSE"###"Atenção"
             Break
          EndIf
          IF lVal_EEX .And. !EEX->(FOUND())
             MSGINFO(If(lDSE, STR0064, STR0060), STR0011) //"Processo nao tem DDE preparada. Prepare a DDE primeiro !"###//"Atenção"
          ELSE
             MSAGUARDE({|| SI400GERA()})
          ENDIF
          BREAK

   ELSEIF nP_OPC = 5 // RETORNA

          If lVal_EEX .And. !Empty(EEX->EEX_NUM)
             MsgInfo(If(lDSE, STR0063, STR0012), STR0011) //"Processo já possui número de DDE !"###"DSE"###"Atenção"
             Break
          EndIf

          If lDSE
             DSERetorno()
          Else
             SI400RET()
          EndIf

          Break

   ElseIf nP_OPC = 6 // Estorno
          SI400Estorno()
          Break

   ENDIF
   *
   //TRP - 29/01/07 - Campos do WalkThru
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

   If !lDSE
      // GERA ARQUIVO DE DETALHES DA DDE/DSE.
      aSEMSX3   := AddWkCpoUser(aSEMSX3,"EEZ")
      //cWORKEEZ  := E_CRIATRAB("EEZ",aSEMSX3,"TMZ")
      aAdd(aSEMSX3,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
      cWORKEEZ  := EECCriaTrab("EEZ",aSEMSX3,"TMZ")//FSY - 10/10/2013 - Ajustada para otimizar a rotina para reutilizar o arquivo work em DBF
      //INDREGUA("TMZ",cWORKEEZ+OrdBagExt(),"EEZ_PREEMB+EEZ_CNPJ+EEZ_SER+EEZ_NF" ,"AllwayTrue()","AllwaysTrue()",STR0017) //"Processando Arquivo Temporario"
      EECIndRegua("TMZ",cWORKEEZ+TEOrdBagExt(),"EEZ_PREEMB+EEZ_CNPJ+EEZ_SER+EEZ_NF" ,"AllwayTrue()","AllwaysTrue()",STR0017) //"Processando Arquivo Temporario"
      Set Index to (cWORKEEZ+TEOrdBagExt()) // By JPP - 13/07/2005 - 11:30

      If lDDEWeb
         aSX3EWY:={{"EWY_RECNO","N",07,0}}
         AADD(aSX3EWY,{"EWY_FILIAL" ,AvSx3("EWY_FILIAL", AV_TIPO),AvSx3("EWY_FILIAL", AV_TAMANHO),AvSx3("EWY_FILIAL", AV_DECIMAL)})
         aSX3EWY   := AddWkCpoUser(aSX3EWY,"EWY")
         aAdd(aSX3EWY,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
         cWORKEWY  := EECCriaTrab("EWY",aSX3EWY,"TWY")
      EndIf
   EndIf

   //TRP-14/06/2007
   If EasyEntryPoint("EECSI400")
      ExecBlock("EECSI400", .F., .F., {"ANTES_CARREGA"})
   EndIf

   // CARREGA DADOS DA CAPA DO DDE/DSE.
   FOR Z := 1 TO EEX->(FCOUNT())
       M->&(EEX->(FIELDNAME(Z))) := EEX->(FIELDGET(Z))
   NEXT

   IF ! EEX->(FOUND())
      M->EEX_FILIAL := XFILIAL("EEX")
      M->EEX_PREEMB := EEC->EEC_PREEMB
      IF ! EMPTY(EEC->(EEC_EXPORT+EEC_EXLOJA))
         SA2->(DBSETORDER(1))
         SA2->(DBSEEK(XFILIAL("SA2")+EEC->(EEC_EXPORT+EEC_EXLOJA)))
      ELSE
         SA2->(DBSETORDER(1))
         SA2->(DBSEEK(XFILIAL("SA2")+EEC->(EEC_FORN+EEC_FOLOJA)))
      ENDIF

      M->EEX_CNPJ := SA2->A2_CGC
      If lDDEWeb
         M->EEX_ID    := EWJ->EWJ_ID
         M->EEX_TRANS := "2"
         M->EEX_CUBAGE:= EEC->EEC_CUBAGE
         M->EEX_DETOPX:= "1"
         M->EEX_TIPOPX:= "1"
         M->EEX_SDETOP:= "1"
         //LGS-06/01/2016
         If M->(FieldPos("EEX_ODLTIP")) > 0
            M->EEX_ODLTIP:= ""
            M->EEX_ODLIDT:= CriaVar("EEX_ODLIDT")
         EndIf
      EndIf
      SYQ->(DBSETORDER(1))
      SYQ->(DBSEEK(XFILIAL("SYQ")+EEC->EEC_VIA))
      M->EEX_VIAINT := LEFT(SYQ->YQ_COD_DI,1)
      //M->EEX_PESLIQ := EEC->EEC_PESLIQ
      //M->EEX_PESBRU := EEC->EEC_PESBRU
      M->EEX_TOTCV  := EEC->EEC_TOTPED

      If !lDse   // By JPP - 21/03/2007 - 09:00 - Campo utilizado para preenchimento de uma nova perguanta na tela do Siscomex(DDE), para destino final MercoSul
         If EEX->(FieldPos("EEX_PTCROM")) > 0 .And. EEC->(FieldPos("EEC_PTCROM")) > 0
            M->EEX_PTCROM := EEC->EEC_PTCROM
         EndIf
      EndIf

      // CARREGANDO AS REs / EMBALAGENS
      nPesLiq := nPesTot := 0

      EE9->(DBSETORDER(3))
      EE9->(DBSEEK(XFILIAL("EE9")+EEC->EEC_PREEMB))
      DO WHILE ! EE9->(EOF()) .AND.;
         EE9->(EE9_FILIAL+EE9_PREEMB) = (XFILIAL("EE9")+EEC->EEC_PREEMB)
         *
         nQTDEM1 := nQTDEM1+EE9->EE9_QTDEM1  // TOTAL DE EMBALAGENS

         If !lDSE
            // AGRUPA AS REs
            Z := ASCAN(aRE,{|Z| Z[1] = LEFT(EE9->EE9_RE,9)})
            IF Z = 0
               EE9->(AADD(aRE,{LEFT(EE9_RE,9),RIGHT(EE9_RE,3),RIGHT(EE9_RE,3)}))
            ELSEIF aRE[Z,2] > RIGHT(EE9->EE9_RE,3)
                   aRE[Z,2] := RIGHT(EE9->EE9_RE,3)
            ELSEIF aRE[Z,3] < RIGHT(EE9->EE9_RE,3)
                   aRE[Z,3] := RIGHT(EE9->EE9_RE,3)
            ENDIF

            If lDDEWeb //LGS-17/06/2015
               TWY->(DBAPPEND())
               TWY->EWY_FILIAL	:= EE9->EE9_FILIAL
               TWY->EWY_ID		:= EWJ->EWJ_ID
               TWY->EWY_PREEMB	:= EE9->EE9_PREEMB
               TWY->EWY_RE		:= EE9->EE9_RE
               TWY->EWY_RECNO	:= EWY->(RECNO())
            EndIf
         EndIf

         If lDDEWeb
            If EE9->(FieldPos("EE9_UNPES")) # 0 .And. !Empty(EE9->EE9_UNPES) .And. !Empty(cUnKg) .And. AllTrim(cUnKg) <> "."
               nPesTot := AVTransUnid(EE9->EE9_UNPES, AvKey(AllTrim(cUnKg),"EE9_UNPES"), EE9->EE9_COD_I, EE9->EE9_PSBRTO, .F.)
            Else
               nPesTot := EE9->EE9_PSBRTO
            EndIf
         EndIf

         // AGRUPA AS ESPECIES
         EE5->(DBSETORDER(1))
         IF (EE5->(DBSEEK(XFILIAL("EE5")+EE9->EE9_EMBAL1)))
            Z := ASCAN(aEMBA,{|Z| Z[1] = LEFT(EE5->EE5_SISESP,2)})  //Tabela de Embalagens(EE5) e adiciona no aEmba o codido da especie de embalagem no SISCOMEX.
            IF Z = 0
               If lDDEWeb
                  AADD(aEMBA,{LEFT(EE5->EE5_SISESP,2),EE9->EE9_QTDEM1,nPesTot,EE5->EE5_CODEMB})
               Else
                  AADD(aEMBA,{LEFT(EE5->EE5_SISESP,2),EE9->EE9_QTDEM1})
               EndIf
            ELSE
               aEMBA[Z,2] := aEMBA[Z,2]+EE9->EE9_QTDEM1
               If lDDEWeb
                  aEMBA[Z,3] := aEMBA[Z,3]+nPesTot
               EndIf
            ENDIF
         ENDIF

         /* By JBJ - 03/05/04 (17:23) Converte o peso liquido total para Kg caso o campo EE9_UNPES
                                      (Un.Med.Peso) existir no ambiente. Utiliza o MV_AVG0031
                                      (Código da Un.Med. Kg padrão do sistema) para conversão. */

         If EE9->(FieldPos("EE9_UNPES")) # 0 .And. !Empty(EE9->EE9_UNPES) .And. !Empty(cUnKg) .And. AllTrim(cUnKg) <> "."
            nPesLiq += AVTransUnid(EE9->EE9_UNPES, AvKey(AllTrim(cUnKg),"EE9_UNPES"), EE9->EE9_COD_I, EE9->EE9_PSLQTO, .F.)
         Else
            nPesLiq += EE9->EE9_PSLQTO
         EndIf

         EE9->(DBSKIP())
      ENDDO

      M->EEX_PESLIQ := Round(nPesLiq,AVSX3("EEX_PESLIQ",AV_DECIMAL))

      /* By JBJ - 03/05/04 (17:23) Converte o peso bruto total para Kg caso o campo EEC_UNIDAD
                                   estiver preenchido. Utiliza o MV_AVG0031
                                   (Código da Un.Med. Kg padrão do sistema) para conversão. */

      If !Empty(EEC->EEC_UNIDAD) .And.  !Empty(cUnKg) .And. AllTrim(cUnKg) <> "."
         M->EEX_PESBRU := Round(AVTransUnid(EEC->EEC_UNIDAD, AvKey(AllTrim(cUnKg),"EEC_UNIDAD");
                                            ,,EEC->EEC_PESBRU,.f.),AvSx3("EEX_PESBRU",AV_DECIMAL))
      Else
         M->EEX_PESBRU := Round(EEC->EEC_PESBRU,AVSX3("EEX_PESBRU",AV_DECIMAL))
      EndIf

      // CARREGA AS REs
      /*
      FOR Z := 1 TO 6
          IF Z > LEN(aRE)
             EXIT
          ENDIF
          &("M->EEX_RE"+STR(Z,1,0)) := aRE[Z,1]+aRE[Z,2]
          IF aRE[Z,2] # aRE[Z,3]
             &("M->EEX_RE"+STR(Z,1,0)+"C") := aRE[Z,3]
          ENDIF
      NEXT
      */

      If !lDSE
	      For z := 1 To Len(aFieldRE)
	         If z > Len(aRE)
	            Exit
	         EndIf
	         M->&(aFieldRE[z][1]) := aRE[z][1]+aRE[z][2] //R.E. + Sufixo inicial.
	         M->&(aFieldRE[z][2]) := aRE[z][3]           //Sufixo final.
	      Next
      EndIf

      M->EEX_QTDTOT := TRANSFORM(nQTDEM1,"99999999")
      // CARREGA AS ESPECIES/QTDE/MARCACAO
      If lDDEWeb
         c1 := STRTRAN(MSMM(EEC->EEC_CODMAR,AVSX3("EEC_MARCAC",AV_TAMANHO)),ENTER," ")
         c1 := STRTRAN(c1,CHR(10)," ")
      Else
         c1 := STRTRAN(MSMM(EEC->EEC_CODMAR,AVSX3("EEC_MARCAC",AV_TAMANHO)),ENTER," ")
      EndIf

      For z := 1 To Len(aFieldEspecie)
         If z > Len(aEmba)
            Exit
         EndIf
         M->&(aFieldEspecie[z][1]) := aEmba[z][1]
         M->&(aFieldEspecie[z][3]) := Transform(aEmba[z][2], AVSX3(aFieldEspecie[z][3], AV_PICTURE))
         If lDDEWeb
            M->&(aFieldEspecie[z][4]) := Alltrim(RTrim(c1))
            M->&(aFieldEspecie[z][5]) := Round(aEmba[z][3],AVSX3(aFieldEspecie[z][5], AV_DECIMAL))
            M->&(aFieldEspecie[z][6]) := aEmba[z][4]
         Else
            M->&(aFieldEspecie[z][4]) := IncSpace(LTrim(c1), AVSX3(aFieldEspecie[z][4], AV_TAMANHO), .F.)
         EndIf
      Next

      /*
      FOR Z := 1 TO 7
         IF Z > LEN(aEMBA)
            EXIT
         ENDIF
         &("M->EEX_ESP"+STR(Z,1,0))  := aEMBA[Z,1]
         &("M->EEX_QTD"+STR(Z,1,0))  := TRANSFORM(aEMBA[Z,2],"99999")
         &("M->EEX_MARK"+STR(Z,1,0)) := PADR(MEMOLINE(c1,LEN(EEX->EEX_MARK1),1),LEN(EEX->EEX_MARK1)," ")
      NEXT
      */

      // BUSCANDO AS NOTAS FISCAIS
      EEM->(DBSETORDER(1))
      EEM->(DBSEEK(XFILIAL("EEM")+EEC->EEC_PREEMB+"N"))
      DO WHILE ! EEM->(EOF()) .AND.;
         EEM->(EEM_FILIAL+EEM_PREEMB+EEM_TIPOCA) = (XFILIAL("EEM")+EEC->EEC_PREEMB+"N")
         *

         If EEM->(FieldPos("EEM_CHVNFE")) > 0
            If Empty(EEM->EEM_CHVNFE)
               SF2->(DbSetOrder(1))
               If SF2->(DBSEEK(xFilial("SF2")+AvKey(EEM->EEM_NRNF,"F2_DOC")+AvKey(EEM->EEM_SERIE,"F2_SERIE") ))
                  If !EEM->( IsLocked() )
                     EEM->(RecLock("EEM",.F.))
                     EEM->EEM_CHVNFE := SF2->F2_CHVNFE
                     EEM->(MsUnlock())
                  Else
                     EEM->EEM_CHVNFE := SF2->F2_CHVNFE
                  EndIf
               EndIf
            EndIf
         EndIf

         If EEM->EEM_TIPONF == EEM_CP // By JPP 23/06/2006 - 11:30 - Nota fiscal complementar
            EEM->(DbSkip())
            Loop
         EndIf
         If EEM->(FieldPos("EEM_CHVNFE")) > 0
            EEM->(AADD(aNF,{M->EEX_CNPJ,EEM_SERIE,EEM_NRNF,EEM_CHVNFE}))
         Else
            EEM->(AADD(aNF,{M->EEX_CNPJ,EEM_SERIE,EEM_NRNF}))
         EndIf
         EEM->(DBSKIP())
      ENDDO

      /*
      AMS - 14/06/2005. Carrega a identificação do veiculo transpotador.
      */
      M->EEX_ID_VT := Posicione("EE6", 1, xFilial("EE6")+EEC->EEC_EMBARC, "EE6_NOME")

      If lDDEWeb .And. !lDSE
         M->EEX_ULDESP := EEC->EEC_URFDSP
         M->EEX_ULEMBA := EEC->EEC_URFENT
      EndIf

      If lDSE

         If Len(aNF) > 0

            cNFs := NFStr(aNF)

            If !Empty(cNFs)

               M->EEX_DOCIN1 := Left(cNFs, 75)

               If Len(cNFs) > 75
                  M->EEX_DOCIN2 := SubStr(cNFs, 76, 150)
               EndIf

               If Len(cNFs) > 150
                  M->EEX_DOCIN3 := SubStr(cNFs, 151)
               EndIf

            EndIf

         EndIf

         /*
         AMS - 14/06/2005. Carrega os campos URF de Embarque/Despacho do processo.
         */
         M->EEX_ULDESP := EEC->EEC_URFDSP
         M->EEX_ULEMBA := EEC->EEC_URFENT

      Else
         aNF := ASORT(aNF,,,{|X,Y| X[1]+X[2]+X[3] < Y[1]+Y[2]+Y[3]})
         FOR Z := 1 TO LEN(aNF)
             TMZ->(DbSetorder(1))  // By JPP - 13/07/2005 - 14:50
             IF ! (TMZ->(DBSEEK(EEC->EEC_PREEMB+aNF[Z,1]+AVKEY(aNF[Z,2],"EEZ_SER"))))
                TMZ->(DBAPPEND())
                TMZ->EEZ_PREEMB := EEC->EEC_PREEMB
                TMZ->EEZ_CNPJ   := aNF[Z,1]  // CNPJ
                TMZ->EEZ_SER    := aNF[Z,2]  // SERIE
                TMZ->EEZ_NF     := aNF[Z,3]  // NOTA INICIAL
                If !lDDEWeb
                   TMZ->EEZ_A_SER  := aNF[Z,2]  // SERIE
                   TMZ->EEZ_A_NF   := aNF[Z,3]  // NOTA FINAL
                EndIf
                If lDDEWeb .And. EEM->(FieldPos("EEM_CHVNFE")) > 0
                   TMZ->EEZ_CHVNFE := aNF[Z,4]
                EndIf
                TMZ->TRB_ALI_WT := "EEZ"
                If lDDEWeb
                   TMZ->EEZ_ID  := EWJ->EWJ_ID
                EndIf
                TMZ->TRB_REC_WT := EEZ->(Recno())
             ELSE
                DO WHILE ! TMZ->(EOF())
                   IF (VAL(TMZ->EEZ_A_NF)+1) = VAL(aNF[Z,3])
                      TMZ->EEZ_A_NF := aNF[Z,3]
                   ELSE
                      TMZ->(DBSKIP())
                      IF ! TMZ->(EOF()) .AND.;
                         TMZ->(EEZ_PREEMB+EEZ_CNPJ+EEZ_SER) = (EEC->EEC_PREEMB+aNF[Z,1]+AVKEY(aNF[Z,2],"EEZ_SER"))
                         *
                         LOOP
                      ENDIF
                      TMZ->(DBAPPEND())
                      TMZ->EEZ_PREEMB := EEC->EEC_PREEMB
                      TMZ->EEZ_CNPJ   := aNF[Z,1]  // CNPJ
                      TMZ->EEZ_SER    := aNF[Z,2]  // SERIE
                      TMZ->EEZ_NF     := aNF[Z,3]  // NOTA INICIAL
                      If !lDDEWeb
                         TMZ->EEZ_A_SER  := aNF[Z,2]  // SERIE
                         TMZ->EEZ_A_NF   := aNF[Z,3]  // NOTA FINAL
                      EndIf
                      If lDDEWeb .And. EEM->(FieldPos("EEM_CHVNFE")) > 0
                         TMZ->EEZ_CHVNFE := aNF[Z,4]
                      EndIf
                      TMZ->TRB_ALI_WT := "EEZ"
                      If lDDEWeb
                         TMZ->EEZ_ID  := EWJ->EWJ_ID
                      EndIf
                      TMZ->TRB_REC_WT := EEZ->(Recno())
                   ENDIF
                   EXIT
               ENDDO
             ENDIF
         NEXT
      EndIf

   ELSE
      // CARREGA AS NOTAS FISCAIS DA DDE
      If !lDSE
         EEZ->(DBSETORDER(1))
         EEZ->(DBSEEK(cChaveEEZ))
         DO WHILE ! EEZ->(EOF()) .AND.;
            EEZ->(EEZ_FILIAL+EEZ_PREEMB) = cChaveEEZ
            *
            TMZ->(DBAPPEND())
            AVREPLACE("EEZ","TMZ")
            TMZ->TMZ_RECNO := EEZ->(RECNO())
            TMZ->TRB_ALI_WT:= "EEZ"
            TMZ->TRB_REC_WT:= EEZ->(Recno())
            EEZ->(DBSKIP())
         ENDDO
      EndIf
   ENDIF

   If !lDSE
      TMZ->(DBGOTOP())
   EndIf

   If EasyEntryPoint("EECSI400")
      ExecBlock("EECSI400", .F., .F., {"PRE_DSE"})
   EndIf

   DBSELECTAREA("EEX")

   If lShowDlg

   DEFINE MSDIALOG oDLG TITLE If(lDSE, STR0061, STR0001) FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Geração de DSE"###"Geração de DDE"

      If lDSE
         aPos := PosDlg(oDlg)
      Else
         aPOS := POSDLGUP(oDLG)
      EndIf

      If Type("aROTINA") <> "A" //LGS-03/06/2015
         aROTINA   := MenuDef(If(ProcName(1) == "EECSI40A", "EECSI40A", "EECSI400"))
      EndIf

      If lDDEWeb //Retira todos os campos de DE da tela.
         aOrdX3 := SaveOrd({"SX3"})
         SX3->(dbSeek("EEX"))
         aDelEEZ := {}
         Do While SX3->(!Eof())
            If SX3->X3_FOLDER == '2'
               aAdd(aDelEEZ, Alltrim(SX3->X3_CAMPO))
            EndIf
            SX3->(DbSkip())
         EndDo
         For i:= 1 To Len(aDelEEZ)
           For y:= 1 To Len(aENCHOICE)
               If Alltrim(aENCHOICE[y]) == aDelEEZ[i]
                  aENCHOICE := aDel(aENCHOICE,y)
                  aENCHOICE := aSize(aENCHOICE,Len(aENCHOICE)-1)
                  Exit
               EndIf
           Next
         Next
         RestOrd(aOrdX3,.T.)
      EndIf

      ENCHOICE("EEX",EEX->(RECNO()),nP_OPC,,,,aENCHOICE,aPOS,NIL)

      If !lDSE

         aPos    := PosDlgDown(oDlg)
         aPos[3] := aPos[3]-20

         lDetMSGetdb := .T.
         If lDetMSGetdb

            If IsVazio("TMZ")

               If nP_Opc = Prepara
                  TMZ->(dbAppend())
                  TMZ->EEZ_CNPJ := M->EEX_CNPJ     // By JPP - 01/08/2005 - 14:20
                  TMZ->TRB_ALI_WT:= "EEZ"
                  TMZ->TRB_REC_WT:= EEZ->(Recno())
               EndIf

            Else

               nGetTotNFs := NFSumRange()

            EndIf

            aHeader := FieldsGetdb("EEZ")
            aHeader := AddCpoUser(aHeader,"EEZ","4")
            If lDDEWeb
               aDelEEZ := {"EEZ_A_NF","EEZ_A_SER","EEZ_ID"}
               For i:= 1 To Len(aDelEEZ)
                   For y:= 1 To Len(aHeader)
                       If Alltrim(aHeader[y][2]) == aDelEEZ[i]
                          aHeader := aDel(aHeader,y)
                          aHeader := aSize(aHeader,Len(aHeader)-1)
                          Exit
                       EndIf
                   Next
               Next
            EndIf

            TMZ->(Dbsetorder(0)) // By JPP - 13/07/2005 - 11:40

            If lDDEWeb

               TWY->(DbGoTop())
               nAltura  := int((oDLG:nBottom-oDLG:nTop)/2)
               nLargura := int((oDLG:nRight-oDLG:nLeft)/2)
               oPanelNF := TPanel():New(aPos[1]+2,aPos[2]             ,"",oDLG,,.F.,.F.,,,(nLargura/2),(nAltura/3)+30,,)
               oPanelRE := TPanel():New(aPos[1]+2,aPos[2]+(nLargura/2),"",oDLG,,.F.,.F.,,,(nLargura/2),(nAltura/3)+30,,)

               oGetdbNF	:= MSGetdb():New(aPos[1], aPos[2], (nLargura/2), (nAltura/3)+30,nP_Opc, "DDEVldNF",,,.T.,,,.T.,,"TMZ",,,.F.,oPanelNF,.T.,,"DDEVldDelNF")
               oGetdbNF:oBrowse:Align	:= CONTROL_ALIGN_ALLCLIENT

               //AADD(aHeader,{AVSX3("EEX_PREEMB",5),"EWY_PREEMB" ,AVSX3("EE9_PREEMB",6),AVSX3("EE9_PREEMB", 3),AVSX3("EE9_PREEMB",4),""          ,""      ,"C"    ,""        ,""} )
               AADD(aHeader,{AVSX3("EE9_RE",5)    ,"EWY_RE"     ,AVSX3("EE9_RE",6)    ,AVSX3("EE9_RE", 3)    ,AVSX3("EE9_RE",4)    ,""          ,""      ,"C"    ,""        ,""} )
               oGetdbRE	:= MsGetDb():New(aPos[1], aPos[2]+(nLargura/2), (nLargura/2), (nAltura/3)+30,nP_Opc,,,,.T.,,,.T.,,"TWY",,,.F.,oPanelRE,.T.,,"DDEVldDelRE")
               oGetdbRE:oBrowse:Align	:= CONTROL_ALIGN_ALLCLIENT

            Else
               oGetdb := MSGetdb():New(aPos[1], aPos[2], aPos[3], aPos[4], nP_Opc,"DDEVldNF",,,.T.,,,.T.,,"TMZ",,,.F.,oDLG,.T.,, "DDEVldDelNF")
            EndIf
         Else

            oMSelect := MSSelect():New("TMZ",,, aCampoTMZ, @lInverte, @cMarca, aPos)
            oMSelect:bAval := {|| SI400IAE("V",lDDEWeb), /*oMSelect:oBrowse:Refresh()*/}

         EndIf

         @ aPos[3]-2, aPos[2] To aPos[3]+22, aPos[4] Pixel

         @ aPos[3]+08, aPos[2]+04 Say STR0109 Pixel //"Total de NF's"
         @ aPos[3]+06, aPos[2]+42 MSGet oGetTotNFs Var nGetTotNFs When .F. Size 50, 6 Right Pixel

      EndIf

   ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)

   EndIf
   If lDDEWeb
      M->EEX_SDETOP := If(M->EEX_DETOPX <> "9", "", M->EEX_SDETOP)
   EndIf
   //WFS 16/06/09
   If lShowDlg == .F. .And. nP_OPC == Prepara
      nBTop:= 1
   EndIf
   //---
   IF nBTOP = 1 .AND. nP_OPC > 2 .AND. lALTERA
      If lDDEWeb //LGS-02/03/2016
         M->EEX_SEQLOT := AllTrim(cValToChar(nSequenDDE++))
      EndIf
      PROCESSA({|| SI400PREP(lDDEWeb)})
   ENDIF
END SEQUENCE
IF nP_OPC > 2
   EEC->(MSUNLOCK())
ENDIF
IF SELECT("TMZ") # 0
   TMZ->(E_ERASEARQ(cWORKEEZ))
ENDIF
IF SELECT("TWY") # 0
   TWY->(E_ERASEARQ(cWORKEWY))
ENDIF

// ** JPM - 21/02/06 - Controle de usuários
If lLockEEC
   EEC->(MsUnLock())
EndIf
If lLockEEX
   EEX->(MsUnlock())
EndIf
// **

   aFilesDir := Directory(cPathOr)

RESTORD(aORD)
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION SI400IAE(nP_OPC,lDEWeb)
LOCAL oDLG,cTITULO,aPOS,nREC,Z,aMOSTRA,aALTERA,aBUTTONS,bOK,bCANCEL,nBTOP
PRIVATE aTELA[0,0],aGETS[0]
Default lDEWeb := .F.
*
nBTOP    := 0
cTITULO  := IF(nP_OPC="I",STR0019,; //"Inclusão"
                          IF(nP_OPC="A",STR0020,; //"Alteração"
                                        IF(nP_OPC="V",STR0021,;  //"Visualização"
                                                      STR0022))) //"Exclusão"
aALTERA  := {}
aBUTTONS := {}
nREC     := TMZ->(RECNO())
bCANCEL  := {|| nBTOP := 0,oDLG:END()}
bOK      := IF(AT(nP_OPC,"EV")#0,{||nBTOP := 1,oDLG:END()},;
                                 {||nBTOP := 1,IF(OBRIGATORIO(aGETS,aTELA),;
                                                  oDLG:END(),;
                                                  nBTOP := 0)})
If lDEWeb
   aMOSTRA  := {"EEZ_CNPJ","EEZ_NF","EEZ_SER","EEZ_CHVNFE"}
   aALTERA  := IF(AT(nP_OPC,"EV")#0, {}, {"EEZ_CNPJ","EEZ_NF","EEZ_SER","EEZ_CHVNFE"})
Else
   aMOSTRA  := {"EEZ_CNPJ","EEZ_NF","EEZ_SER","EEZ_A_NF","EEZ_A_SER"}
   aALTERA  := IF(AT(nP_OPC,"EV")#0,;
               {},;
               {"EEZ_CNPJ","EEZ_NF","EEZ_SER","EEZ_A_NF","EEZ_A_SER"})
EndIf
*
BEGIN SEQUENCE
   IF nP_OPC = "I"
      TMZ->(DBGOBOTTOM())
      TMZ->(DBSKIP())
   ELSEIF EMPTY(TMZ->EEZ_PREEMB)
          MSGINFO(STR0023+cTITULO+STR0024,STR0011) //"Nao a dados para "###"."###"Atenção"
          BREAK
   ENDIF
   FOR Z := 1 TO TMZ->(FCOUNT())
       M->&(TMZ->(FIELDNAME(Z))) := TMZ->(FIELDGET(Z))
   NEXT
   M->EEZ_PREEMB := M->EEX_PREEMB
   M->EEZ_CNPJ   := IF(nP_OPC="I",M->EEX_CNPJ,M->EEZ_CNPJ)
   DBSELECTAREA("TMZ")

   // by OAP 29/10/2010 - 12:00
   If nP_OPC == "A" .Or. nP_OPC == "I"
      aALTERA := AddCpoUser( aALTERA,"EEZ","1")
      aMOSTRA := AddCpoUser( aMOSTRA,"EEZ","1")
   EndIf

   DEFINE MSDIALOG oDLG TITLE cTITULO FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      aPOS := POSDLG(oDLG)
      ENCHOICE("EEZ",0,3,,,,aMOSTRA,aPOS,aALTERA,3)
   ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
   IF nBTOP = 1 .AND. nP_OPC # "V"
      IF nP_OPC = "E"
         TMZ->(DBDELETE())
         IF ! EMPTY(TMZ->TMZ_RECNO)
            AADD(aDELETE,TMZ->TMZ_RECNO)
         ENDIF
      ELSE
         IF nP_OPC = "I"
            TMZ->(DBAPPEND())
            nREC := TMZ->(RECNO())
         ENDIF
         AVREPLACE("M","TMZ")
      ENDIF
   ENDIF
END SEQUENCE
TMZ->(DBGOTO(nREC))

//CRF - 04/05/2011
// substituido do bloco de codigo

If ValType(oGetDb) == "O"
   oGetDb:oBrowse:Refresh()
ElseIf ValType(oMSelect) == "O"
   oMSelect:oBrowse:Refresh()
EndIf


RETURN(NIL)
*--------------------------------------------------------------------
FUNCTION SI400VAL(cP_CAMPO)
LOCAL lRET,aORD,c1,I,c2,l1
Local nTotVol := 0
*
aORD     := SAVEORD({"SA2","SYQ","SX5"})
lRET     := .T.
cP_CAMPO := IF(cP_CAMPO=NIL,"",cP_CAMPO)
IF (cP_CAMPO == "EEX_CNPJ")                                .OR.;
   (cP_CAMPO == "EEX_CNPJ_R" .AND. ! EMPTY(M->EEX_CNPJ_R)) .OR.;
   (cP_CAMPO == "EEZ_CNPJ"   .AND. ! EMPTY(M->EEZ_CNPJ))
   *
   IF ! CGC(&("M->"+cP_CAMPO))
      lRET := .F.
   ELSE

      If EEX->(FieldPos("EEX_RLFJ") > 0 .and. M->EEX_RLFJ = "F")

         SY5->(Eval({|x| lRet := .F.,;
                         dbGoTop(),;
                         dbEval({|| lRet := .T.}, {|| Y5_NRCPFCG == AvKey(M->EEX_CNPJ_R, "Y5_NRCPFCG")}, {|| !lRet}),;
                         dbGoTo(x)}, Recno()))

         If !lRet
            MsgInfo(STR0122, STR0011) //"O Despachante com o CPF informado não foi encontrado no cadastro de empresas."###"Atenção"
         EndIf

      Else

         SA2->(dbSetOrder(3))
         If !SA2->(dbSeek(xFilial()+M->&(cP_CAMPO)))
            MsgInfo(STR0025,STR0011) //"C.G.C./C.P.F. não cadastrado !"###"Atenção"
            lRet := .F.
         EndIf

      EndIf

      /*
      SA2->(DBSETORDER(3))
      IF ! (SA2->(DBSEEK(XFILIAL("SA2")+&("M->"+cP_CAMPO))))
         MSGINFO(STR0025,STR0011) //"C.G.C./C.P.F. não cadastrado !"###"Atenção"
         lRET := .F.
      ENDIF
      */

   ENDIF
ELSEIF cP_CAMPO = "EEX_VIAINT"
       c1 := PADR(TABELA("Y3",M->EEX_VIAINT,.T.),20," ")
       IF EMPTY(c1)
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO = "EEX_PESLIQ"
       IF M->EEX_PESLIQ < 0
          MSGINFO(STR0026,STR0011) //"Peso liquido total não pode ser negativo !"###"Atenção"
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO = "EEX_PESBRU"
       IF M->EEX_PESBRU < 0
          MSGINFO(STR0027,STR0011) //"Peso bruto total não pode ser negativo !"###"Atenção"
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO = "EEX_TOTCV"
       IF M->EEX_TOTCV < 0
          MSGINFO(STR0028,STR0011) //"Valor total na condição de venda não pode ser negativo !"###"Atenção"
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO = "EEX_QTDTOT"
       IF ! EMPTY(M->EEX_QTDTOT)
          l1 := .F.
          c1 := ALLTRIM(M->EEX_QTDTOT)
          c2 := ""
          BEGIN SEQUENCE
             FOR I := 1 TO LEN(c1)
                 IF AT(SUBSTR(c1,I,1),"0123456789") = 0
                    MSGINFO(AVSX3("EEX_QTDTOT",AV_TITULO)+STR0029,STR0011) //" deve ser branco ou ter um valor numérico !"###"Atenção"
                    lRET := .F.
                    BREAK
                 /*
                 ELSEIF SUBSTR(c1,I,1) $ ",."
                        IF l1
                           MSGINFO(AVSX3("EEX_QTDTOT",AV_TITULO)+STR0029,STR0011) //" deve ser branco ou ter um valor numérico !"###"Atenção"
                           lRET := .F.
                           BREAK
                        ENDIF
                        l1 := .T.
                 */
                 ENDIF
                 c2 := c2+IF(SUBSTR(c1,I,1)=",",".",SUBSTR(c1,I,1))
             NEXT
             M->EEX_QTDTOT := TRANSFORM(VAL(c2),"99999999")
          END SEQUENCE
       ENDIF
ELSEIF cP_CAMPO == "EE5_SISESP"
       IF ! EMPTY(M->EE5_SISESP)
          c1 := TABELA("CL",LEFT(M->EE5_SISESP,2),.T.)
          IF ! EMPTY(c1)
             M->EE5_SISESP := LEFT(SX5->X5_CHAVE,2)+"-"+PADR(c1,29," ")
          ELSE
             lRET := .F.
          ENDIF
       ENDIF
ELSEIF cP_CAMPO == "EEX_ESP1" .OR. cP_CAMPO == "EEX_ESP2" .OR.;
       cP_CAMPO == "EEX_ESP3" .OR. cP_CAMPO == "EEX_ESP4" .OR.;
       cP_CAMPO == "EEX_ESP5" .OR. cP_CAMPO == "EEX_ESP6" .OR.;
       cP_CAMPO == "EEX_ESP7"
       *
       IF ! EMPTY(&("M->"+cP_CAMPO))
          c1 := TABELA("CL",&("M->"+cP_CAMPO),.T.)
          IF EMPTY(c1)
             lRET := .F.
          ENDIF
       ENDIF

       If Empty(M->&(cP_Campo))
          M->&("EEX_QTD"+SubStr(cP_Campo, 8)) := CriaVar("EEX_QTD"+SubStr(cP_Campo, 8))
       EndIf

ELSEIF cP_CAMPO == "EEX_QTD1" .OR. cP_CAMPO == "EEX_QTD2" .OR.;
       cP_CAMPO == "EEX_QTD3" .OR. cP_CAMPO == "EEX_QTD4" .OR.;
       cP_CAMPO == "EEX_QTD5" .OR. cP_CAMPO == "EEX_QTD6" .OR.;
       cP_CAMPO == "EEX_QTD7"

       If !Empty(M->&(cP_Campo))
          If Empty(M->&("EEX_ESP"+SubStr(cP_Campo, 8)))
             MsgStop(STR0100, STR0011) //"A espécie não foi preenchida. Informe a espécie primeiro para depois informar a Qtde."###"Atenção"
             M->&(cP_CAMPO) := CriaVar(cP_CAMPO)
          EndIf
       EndIf

       IF ! EMPTY(&("M->"+cP_CAMPO)) .and. lRet
          IF VAL(&("M->"+cP_CAMPO)) < 0
             MSGINFO(STR0030,STR0011) //"Quantidade não pode ser negativa. Informe um valor positivo !"###"Atenção"
             lRET := .F.
          ENDIF
       ENDIF

       aEval(aFieldEspecie, {|x| nTotVol += Val(M->&(x[3]))})
       M->EEX_QTDTOT := Transform(nTotVol, "99999999")

ElseIf aScan(aFieldEspecie, {|x| x[1] = cP_CAMPO}) > 0
       If !Empty(&("M->"+cP_CAMPO))
          c1 := Tabela("CL", &("M->"+cP_CAMPO), .T.)
          If Empty(c1)
             lRet := .F.
          EndIf
       EndIf

       If Empty(M->&(cP_Campo))
          M->&("EEX_QTD"+SubStr(cP_Campo, 8)) := CriaVar("EEX_QTD"+SubStr(cP_Campo, 8))
       EndIf

ElseIf aScan(aFieldEspecie, {|x| x[3] = cP_CAMPO}) > 0
       If !Empty(M->&(cP_Campo))
          If Empty(M->&("EEX_ESP"+SubStr(cP_Campo, 8)))
             MsgStop(STR0100, STR0011) //"A espécie não foi preenchida. Informe a espécie primeiro para depois informar a Qtde."###"Atenção"
             M->&(cP_CAMPO) := CriaVar(cP_CAMPO)
          EndIf
       EndIf

       If !Empty(&("M->"+cP_CAMPO)) .and. lRet
          If Val(&("M->"+cP_CAMPO)) < 0
             MsgInfo(STR0030, STR0011) //"Quantidade não pode ser negativa. Informe um valor positivo !"###"Atenção"
             lRet := .F.
          EndIf
       EndIf

       aEval(aFieldEspecie, {|x| nTotVol += Val(M->&(x[3]))})
       M->EEX_QTDTOT := Transform(nTotVol, "99999999")

/*
AMS - 13/06/2005. Validação dos campos de NF(s).
*/
ElseIf cP_Campo == "EEZ_NF"

       Do Case

          Case Empty(M->EEZ_NF)
             MsgStop(STR0110, STR0011) //"Informe a NF de inicial."###"Atenção"
             lRet := .F.

          Case NFNumber(M->EEZ_NF) = 0
             MsgStop(STR0111, STR0011) //"A NF informada é invalida. A NF deve ser informada da seguinte forma: NF01, onde 01 é número da NF."###"Atenção"
             lRet := .F.

       End Case

ElseIf cP_Campo == "EEZ_A_NF"

       Do Case

          Case Empty(M->EEZ_A_NF)
             MsgStop(STR0112, STR0011) //"Informe a NF de final."###"Atenção"
             lRet := .F.

          Case NFNumber(M->EEZ_A_NF) = 0
             MsgStop(STR0113, STR0011) //"A NF informada é invalida. A NF deve ser informada da seguinte forma: NF09, onde 09 é número da NF."###"Atenção"
             lRet := .F.

       End Case

ENDIF
RESTORD(aORD)
RETURN(lRET)
*--------------------------------------------------------------------
FUNCTION SI400W(cP_CAMPO)
LOCAL lRET
//LGS-06/01/2016
Do Case
   Case cP_CAMPO == "EEX_SDETOP"
        If M->EEX_DETOPX == '9'
           lRET := .T.
        Else
           lRET := .F.
        EndIf

   Case cP_CAMPO == "EEX_ODLIDT"
        If !Empty(M->EEX_ODLTIP)
           lRET := .T.
        Else
           M->EEX_ODLIDT := CriaVar("EEX_ODLIDT")
           lRET := .F.
        EndIf

   OtherWise
        lRET     := lALTERA
        cP_CAMPO := IF(cP_CAMPO=NIL,"",cP_CAMPO)
End Case

RETURN(lRET)
*--------------------------------------------------------------------
STATIC FUNCTION SI400GERA(nP_OPC)
LOCAL lRET,nSEQ,cFILE,hFILE,Z,cBUFFER,aFILE
Local cKSA2
Local nContadorT6

Local aSaveOrd     := SaveOrd("EE9", 2)
Local VlTotNCM     := 0
Local cDe
Local cPara
Local nPesKG       := 0
Local aErrorLog    := {}
Local aItens       := {}
Local nAgrupamento := 0
Local nPos         := 0
Local cMsg         := ""
Local lRESpace     := .F.
Local lEspSpace    := .F.
Local cFileDDE     := "DDE.001"
Local hFileDDE
Local aEEZ, nEEZ
Local cOldCNPJ     := ""
Local aT8          := {}
Local nQtdItem     := 0
Local nQtdItem_NCM := 0
Local cCodUE
Local cLojUE
Local nOpcCNPJ
Local aT8_Ord     := {}, cCnpj,cRe,cComerc,cNcmQtd,cPeso,cReOrd    // By JPP - 12/07/2005 - 13:30
Local aCMD        := {{"avgiww.bat", "avgiww.exe", "dig_re.cmd", "killtask.exe"},; //programa iww
                      {"avgpackre.exe", "avgpack.exe", "dig_re.cmd"}} //programa packet
Local cPathCmd    := ""
Local nTerminal   := EasyGParam("MV_AVG0091",, 0) //Parâmetro que define qual o terminal do siscomex o cliente usa (1=IWW/ 2=Packet)

Private cCodIt    := ""
Private cDescIt   := ""

*
lRET      := .T.

Begin Sequence

	If lDSE

	   If !ChkFile("SJ5")
   	      MsgStop(STR0070, STR0011) //"A Tabela com a Conversão de Unidade de Medida não está ativa. Ative a tabela e informe as conversões para as unidades de medida."###"Atenção"
	      Break
	   EndIf

	   If (nAgrupamento := DSESelAgrup()) = 0
	      Break
	   EndIf

	EndIf

	//BEGIN TRANSACTION
	   // CRIA O TXT DA DDE/DSE.

	   IF EMPTY(EEX->EEX_TXTSIS)
	      If lDSE
	         nSeq := EasyGParam("MV_AVG0027") // Sequencia da DSE.
	         SetMV("MV_AVG0027", nSeq+1)
	         cFile := "DS"+Padl(nSeq, 6, "0")+".INC"
	      Else
	         nSEQ := EasyGParam("MV_AVG0026") // SEQUENCIA DA DDE
	         SETMV("MV_AVG0026",nSEQ+1)
	         cFILE := "DD"+PADL(nSEQ,6,"0")+".INC"
	      EndIf
	   ELSE
	      cFILE := ALLTRIM(EEX->EEX_TXTSIS)
	   ENDIF

	   hFILE := EasyCreateFile(cPATHOR+cFILE)
	   IF hFILE < 0
	      MSGINFO(STR0031+cPATHOR+cFILE,STR0008) //"Erro na criação do arquivo: "###"Aviso"
	   ELSE
	      // GRAVA DADOS DA CAPA DA DDE
	      EEX->(RECLOCK("EEX",.F.))  // TRAVA
	      EEX->EEX_TXTSIS := cFILE
	      // GERA O TXT COM OS DADOS DA CAPA

	      cBuffer := ""

	      // Verificar se gera o novo layout com as informacoes:
	      // 1-CGC Representante e 2-CGC Representado
	      If lDSE
	         cBuffer += "ID" +;
	                    IncSpace(EEX->EEX_CNPJ, 14, .F.) +;
	                    IncSpace(EEX->EEX_CNPJ_R, 14, .F.) +;
	                    CRLF
	      Else
	         IF EasyGParam("MV_AVG0036",.T.) // Verifica se o parametro existe
	            IF ! Empty(EEC->EEC_EXPORT) .And. !Empty(Posicione("SA2",1,xFilial("SA2")+EEC->EEC_EXPORT+EEC->EEC_EXLOJA,"A2_CGC"))
   	            cKSA2 := EEC->EEC_EXPORT+EEC->EEC_EXLOJA
	            Else
	               cKSA2 := EEC->EEC_FORN+EEC->EEC_FOLOJA
	            Endif

	            cBuffer := cBuffer+"ID"
	            cBuffer := cBuffer+IncSpace(Posicione("SA2",1,xFilial("SA2")+cKSA2,"A2_CGC"),14,.F.)
	            cBuffer := cBuffer+IncSpace(EasyGParam("MV_AVG0036",,""),14)
	            cBuffer := cBuffer+CRLF
	         Endif
	      EndIf

	      cBUFFER := cBuffer+"NP"  // 01/02 - IDENTIFICADOR
	      cBUFFER := cBUFFER+PADR(EEX->EEX_PREEMB,20," ")+ENTER  // 03/22 - NUMERO DO PROCESSO NO EMBARQUE
	      SI400FWrite(hFILE, cBUFFER, LEN(cBUFFER), "ID")
	      //FWRITE(hFILE,cBUFFER,LEN(cBUFFER))

	      cBUFFER := "T1"  // 01/02 - IDENTIFICADOR T1
	      If lDSE
	         cBuffer := cBuffer+EEX->EEX_TIPEXP
	         cBuffer := cBuffer+EEX->EEX_NATUOP
	         cBuffer := cBuffer+IncSpace(EEX->EEX_ULDESP, 7, .F.)
	         cBuffer := cBuffer+IncSpace(EEX->EEX_ULEMBA, 7, .F.)
	         cBuffer := cBuffer+If(EEX->EEX_CSA = "1", "S", If(EEX->EEX_CSA = "2", "N", Space(1)))
             cBuffer := cBuffer+If(Empty(EEX->EEX_CSATIP), Space(1), EEX->EEX_CSATIP)
	         cBuffer := cBuffer+CRLF
	      Else
	         IF LEN(ALLTRIM(EEX->EEX_CNPJ)) > 11
	            cBUFFER := cBUFFER+PADR(EEX->EEX_CNPJ,14," ")+SPACE(11)+ENTER  // 03/27 - CGC DA PESSOA JURIDICA
	         ELSE                                                              //               OU
	            cBUFFER := cBUFFER+SPACE(14)+PADR(EEX->EEX_CNPJ,11," ")+ENTER  // 03/27 - CPF DA PESSOA JURIDICA
	         ENDIF
	      EndIf
	      Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), "T1")

	      cBUFFER := "T2"  // 01/02 - IDENTIFICADOR T2
	      If lDSE
	         /*
	         AMS - 09/08/2005. Substituido o envio do CNPJ do representante legal pelo CNPJ do exportador.
	         cBuffer := cBuffer+Padr(EEX->EEX_CNPJ_R, 14, " ")+ENTER
    	      */
             If EEX->EEX_TIPEXP == "11"  // By JPP - 15/03/2007 - 14:00 - Quando o tipo de exportador for "11" = pessoa física deve-se enviar ao Siscomex o CPF e o Nome. Caso contrário envia-se apenas o CNPJ.
                cBuffer := cBuffer+Padr(EEX->EEX_CNPJ, 11, " ")
                SA2->(dbSetOrder(3))
                SA2->(dbSeek(xFilial("SA2")+EEX->EEX_CNPJ))
                cBuffer := cBuffer+Padr(SA2->A2_NOME,55," ")+ENTER
             Else
                cBuffer := cBuffer+Padr(EEX->EEX_CNPJ, 66, " ")+ENTER
             EndIf
	      Else
	         IF LEN(ALLTRIM(EEX->EEX_CNPJ_R)) > 11
	            cBUFFER := cBUFFER+PADR(EEX->EEX_CNPJ_R,14," ")+SPACE(11)+ENTER  // 03/27 - CGC DO REPRESENTANTE LEGAL
	         ELSE                                                                //               OU
	            cBUFFER := cBUFFER+SPACE(14)+PADR(EEX->EEX_CNPJ_R,11," ")+ENTER  // 03/27 - CPF DO REPRESENTANTE LEGAL
	         ENDIF
	      EndIf
	      Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), "T2")
	      //FWRITE(hFILE,cBUFFER,LEN(cBUFFER))

	      cBUFFER := "T3"  // 01/02 - IDENTIFICADOR T3
	      If lDSE
	         cBuffer := cBuffer+EEC->EEC_PAISDT
	      EndIf

	      Z := EEX->EEX_VIAINT
	      IF Z > "9"
	         Z := (ASC(Z)-65)+10
	      ELSE
	         Z := VAL(EEX->EEX_VIAINT)
	      ENDIF
	      cBUFFER := cBUFFER+PADR(STRZERO(Z,2,0),2," ")  // 03/04 - VIA DE TRANSPORTE INTERNACIONAL

	      If lDSE

	         cBuffer := cBuffer+IncSpace(EEX->EEX_ID_VT, 25, .F.)

	         EE9->(dbSeek(xFilial()+EEC->EEC_PREEMB))

  	         While EE9->(!Eof() .and. EE9_FILIAL == xFilial() .and. EE9_PREEMB == EEC->EEC_PREEMB)

	            cDe      := EE9->(If(Empty(EE9_UNPES), "KG", EE9_UNPES))
	            cPara    := "KG"
	            nPesKG   := 0

	            /*
	            AMS - Retirada a consistência abaixo, pq o peso bruto a ser enviado para o SISCOMEX foi alterado para
	                  ser pego da capa da DSE (EEX_PESBRU) e não da totalização dos itens, como estava sendo feito.
	                  Essa alteração foi feita pq, caso o peso bruto total seja alterado na gravação do embarque a
	                  DSE será gerada com o peso alterado pelo usuário.

    	        Consistência para não permitir a geração de DSE quando a unidade de medida do item não estiver
	            cadastrada na tabela de conversão unidades.

	            If lTabConvUnid .and. EasyGParam("MV_AVG0065", .F., .T.)

	               If (nPesKG := AVTransUnid(cDe, cPara, EE9->EE9_COD_I, EE9->EE9_PSBRTO, .T.)) <> Nil
	                  nPesBruTotKg += nPesKG
	               Else
	                  If aScan(aErrorLog, {|x| x[1] == cDe .and. x[2] == cPara}) = 0
	                     aAdd(aErrorLog, {cDe, cPara})
	                  EndIf
	               EndIf

	            Else

	               nPesKG       := AVTransUnid(cDe, cPara, EE9->EE9_COD_I, EE9->EE9_PSBRTO, .F.)
	               nPesBruTotKg += nPesKG

	            EndIf
                */

	            VlTotNCM  += EE9->EE9_PRCTOT

	            /*
	            Agrupamento dos detalhes por: 1 - Item  + Unidade de Comercialização ou
	                                          2 - N.C.M + Unidade de Comercialização.
	            */
               nPos := aScan(aItens, {|x| x[nAgrupamento]+x[3] == EE9->(If(nAgrupamento = 1, EE9_COD_I, EE9_POSIPI)+EE9_UNIDAD)})

               IF lTabConvUnid
                  /*
                  Converte o peso liquido para KG.
                  */
                  nPesKG := AVTransUnid(cDe, cPara, EE9->EE9_COD_I, EE9->EE9_PSLQTO, .F.)
               Else
                  nPesKG := EE9->EE9_PSLQTO
               EndIF

               If nPos = 0

                  aAdd( aItens, { EE9->EE9_COD_I ,;
                                  EE9->EE9_POSIPI,;
                                  EE9->EE9_UNIDAD,;
                                  EE9->EE9_SLDINI,;
                                  nPesKG,;
                                  EE9->EE9_PRCTOT,;
                                  EE9->EE9_DESC,;
                                  SI400DestNCM(EE9->EE9_PEDIDO, EE9->EE9_SEQUEN) } )

               Else

                  aItens[nPos][4] += EE9->EE9_SLDINI
                  aItens[nPos][5] += nPesKG
                  aItens[nPos][6] += EE9->EE9_PRCTOT

               EndIf

	            EE9->(dbSkip())

	         End

	         If Len(aErrorLog) > 0

               cMsg += STR0084 + Replicate(ENTER, 2) //"Foram encontradas unidades de medidas sem o cadastro na tabela de Conversão de Unidades."
               cMsg += STR0085 + Space(1) + STR0086 + ENTER //"  De  "###" Para "
               cMsg += "------" + Space(1) + "------" + ENTER

	            For nPos := 1 To Len(aErrorLog)
	               cMsg += Padc(aErrorLog[nPos][1], 6) + Space(1) + Padc(aErrorLog[nPos][2], 6) + ENTER
	            Next

	            cMsg += ENTER +;
	                    STR0087 + ENTER +; //"Para concluir a geração da DSE é necessário que as unidades de medidas"
	                    STR0088            //"relacionadas, sejam cadastradas na tabela de conversão de unidades."

	            EECView(cMsg, STR0089)

	            fClose(hFile)

	            Break

	         EndIf

	         cBuffer := cBuffer+StrTran(StrZero(EEX->EEX_PESBRU, 20, 5), ".", "")
	         cBuffer := cBuffer+Posicione("SYF", 1, xFilial("SYF")+EEC->EEC_MOEDA, "YF_COD_GI")
	         cBuffer := cBuffer+StrTran(StrZero(VlTotNCM, 18, 2), ".", "")

	      Else

     	     cBUFFER := cBUFFER+STRTRAN(STRZERO(EEX->EEX_PESLIQ,18,5),".","") // 05/21 - PESO LIQUIDO TOTAL DOS REs DO DESPACHO
	         cBUFFER := cBUFFER+STRTRAN(STRZERO(EEX->EEX_PESBRU,20,5),".","") // 22/40 - PESO BRUTO TOTAL DOS REs DO DESPACHO
	         cBUFFER := cBUFFER+STRTRAN(STRZERO(EEX->EEX_TOTCV,18,2),".","")  // 41/57 - TOTAL COND. VENDA DOS REs DO DESPACHO(NA MOEDA NEG.)

	         /*
	         Nopado por ER - 08/05/2007

	         FOR Z := 1 TO 6
	          //IF !EMPTY( &( "EEX->EEX_RE" + STR( Z, 1, 0 ) ) )
	            cBUFFER := cBUFFER + PADR( &( "EEX->EEX_RE" + STR( Z, 1, 0) ), 12, " ")       //03/14 - NUMERO DA RE
	            cBUFFER := cBUFFER + PADR( &( "EEX->EEX_RE" + STR( Z, 1, 0) + "C" ), 03, " ") //15/17 - COMPLEMENTO DA RE
	          //ENDIF
	         NEXT
             */
	         /*
	         AMS - 17/01/2005 às 15:48. Implementação para gerar até 99 RE+Complemento.
	         */
            //For z := 13 To Len(aFieldRE)
            For z := 1 To Len(aFieldRE)
               If !Empty(EEX->&(aFieldRE[z][1]))
                  /*
                  Nopado por ER - 08/05/2007

                  If Len(AllTrim(aFieldRE[z][1])) = 7
                     cBuffer += Padr(EEX->&(aFieldRE[z][1]), 12, " ")
                  Else
                     cBuffer += Padr(EEX->&(aFieldRE[z][1]), 03, " ")
                  EndIf
                  */
 	              cBUFFER := cBUFFER + PADR(EEX->&(aFieldRE[z][1] ), 12, " ") //NUMERO DA RE
   	              cBUFFER := cBUFFER + PADR(EEX->&(aFieldRE[z][2] ), 03, " ") //COMPLEMENTO DA RE
                  lRESpace := .T.
               Else
                  If z <= 6
                     cBUFFER := cBUFFER + PADR(EEX->&(aFieldRE[z][1] ), 12, " ") //NUMERO DA RE
   	                 cBUFFER := cBUFFER + PADR(EEX->&(aFieldRE[z][2] ), 03, " ") //COMPLEMENTO DA RE
   	              EndIf
               EndIf
            Next

            //Adiciona um Espaço em branco após o último RE.
            If lRESpace
               cBuffer += Space(1)
            EndIf

            /*
            Nopado por ER - 08/05/2007

            If !Empty(EEX->EEX_RE6) .or. lRESpace
               cBuffer += Space(1)
            EndIf
            */

		   EndIf

		   cBUFFER += ENTER
		   Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), "T3")
		   //FWRITE( hFILE, cBUFFER, Len( cBUFFER ) )

	      cBUFFER := "T4"               // 01/02 - IDENTIFICADOR T4
	      If lDSE
            cBuffer := cBuffer + EEX->EEX_QTDTOT + ENTER
         Else
   	      cBUFFER := cBUFFER+"S"+ENTER  // 03/03 - CONFIRMA A DECLARACAO (S/N)
	      EndIf
	      Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), "T4")
	      //FWRITE(hFILE,cBUFFER,LEN(cBUFFER))

	      If lDSE
            For z := 1 To Len(aFieldEspecie)
               If !Empty(EEX->&(aFieldEspecie[z][1]))
        	         cBuffer := "T4B"
                  cBuffer := cBuffer+IncSpace(EEX->&(aFieldEspecie[z][1]),2,.F.)  //WFS 02/10/08
                  cBuffer := cBuffer+IncSpace(EEX->&(aFieldEspecie[z][3]),5,.F.)  //WFS 02/10/08
                  cBuffer := cBuffer+IncSpace(EEX->&(aFieldEspecie[z][4]),36,.F.) + ENTER //WFS 02/10/08
                  Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), "T4B")
                  //fWrite(hFile, cBuffer, Len(cBuffer))
               EndIf
            Next
	      EndIf

         If lDSE
            For nPos := 1 To Len(aItens)
               cBuffer := "T5"                                                 // 01/02 - IDENTIFICADOR T5
               cBuffer += IncSpace(aItens[nPos][2], 8, .F.) +;                 //Código.
                          IncSpace(aItens[nPos][8], 2, .F.) +;                 //Destaque da NCM.
                          StrTran(StrZero(aItens[nPos][4], 18, 5), ".", "") +; //Qtde na unid.de medida.
                          IncSpace(aItens[nPos][3], 20, .F.) +;                //Unidade Comercializada.
                          StrTran(StrZero(aItens[nPos][4], 18, 5), ".", "") +; //Qtde na unid.Comerc.
                          StrTran(StrZero(aItens[nPos][5], 18, 5), ".", "") +; //Peso Liquido Total (KG).
                          StrTran(StrZero(aItens[nPos][6], 18, 2), ".", "") //Valor na moeda.

//                        MFR TE-5651 WCC-515968
//                        IncSpace(StrTran(MSMM(aItens[nPos][7], AVSX3("EE9_VM_DES", AV_TAMANHO)), ENTER, " "), 225, .F.) + ENTER //Descrição do Item.
                          cCodIt := IncSpace(aItens[nPos][2], 8, .F.)
                          cDescIt:= StrTran(MSMM(aItens[nPos][7], AVSX3("EE9_VM_DES", AV_TAMANHO)), ENTER, " ")
                          //cDescIt = IncSpace(StrTran(MSMM(aItens[nPos][7], AVSX3("EE9_VM_DES", AV_TAMANHO)), ENTER, " "), 225, .F.)  //Descrição do Item.
                          If EasyEntryPoint("EECSI400")
                            ExecBlock("EECSI400",.F.,.F.,"DESC_ITEM_DSE")
                          Endif

               cBuffer += IncSpace(StrTran(cDescIt, ENTER, " "), 225, .F.)  //Descrição do Item. + ENTER
     	         Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), "T5")
     	         //fWrite(hFile, cBuffer, Len(cBuffer))
            Next
	      Else
            cBUFFER := "T5"                                       // 01/02 - IDENTIFICADOR T5
	         cBUFFER := cBUFFER+PADR(EEX->EEX_QTDEST,2," ")        // 03/04 - QTDE. ESTAB. PARTICIPANTES DO DESPACHO
	         cBUFFER := cBUFFER+PADR(EEX->EEX_SDLNA,10," ")        // 05/14 - NUMERO DA SOLICITACAO DE DESPACHO EM LOCAL NAO ALFANDEGADO
	         cBUFFER := cBUFFER+PADR(EEX->EEX_ID_VT,25," ")        // 15/39 - IDENTIFICACAO DO VEICULO TRANSPORTADOR
	         cBUFFER := cBUFFER+IF(EEX->EEX_CARGAF $ cSIM,"S","N") // 40/40 - DESPACHO DE CARGA FRACIONADA (S/N)
	         cBUFFER := cBUFFER+IF(EEX->EEX_DPOST  $ cSIM,"S","N") // 41/41 - DESPACHO POSTERIORI (S/N)
            // By JPP - 21/03/2007 - 09:00 - O campo abaixo passou a ser utilizado para preenchimento de uma nova perguanta na tela do Siscomex(DDE), para destino final MercoSul
            If EEX->(FieldPos("EEX_PTCROM")) > 0 // Nesta DDE existem mercadorias amparadas por CCPTC ou CCROM? (S/N):
               If SI400VerMercoSul(EEC->EEC_PAISDT)
                   If Empty(EEX->EEX_PTCROM)
                     cBUFFER := cBUFFER + "N"
                  Else
                     cBUFFER := cBUFFER + If(EEX->EEX_PTCROM $ cSIM,"S","N")
                  EndIf
               Else
                  cBUFFER := cBUFFER + Space(1)
               EndIf
            Else
               cBUFFER := cBUFFER + Space(1)
            EndIf
            cBUFFER := cBUFFER+PADR(StrTran(EEX->EEX_QTDTOT,",","."),8," ")        // 42/49 - QTDE. TOTAL DE VOLUMES
	         //FWRITE(hFILE,cBUFFER,LEN(cBUFFER))

	         FOR Z := 1 TO 7
	//          IF ! EMPTY(&("EEX->EEX_ESP"+STR(Z,1,0)))
	//             cBUFFER := "T6"  // 01/02 - IDENTIFICADOR T6
	               cBUFFER := cBUFFER+PADR(&("EEX->EEX_ESP" +STR(Z,1,0)),02," ") // 03/04 - ESPECIE
	               cBUFFER := cBUFFER+PADR(&("EEX->EEX_QTD" +STR(Z,1,0)),05," ") // 05/09 - QUANTIDADE
	               cBUFFER := cBUFFER+PADR(&("EEX->EEX_MARK"+STR(Z,1,0)),36," ") // 10/45 - MARCACAO
	//          ENDIF
	         NEXT

	         /*
	         AMS
	         */
	         For z := 8 To Len(aFieldEspecie)
               If !Empty(EEX->&(aFieldEspecie[z][1]))
                  cBuffer   := cBuffer+EEX->&(aFieldEspecie[z][1])
                  cBuffer   := cBuffer+EEX->&(aFieldEspecie[z][3])
                  cBuffer   := cBuffer+EEX->&(aFieldEspecie[z][4])
                  lEspSpace := .T.
               EndIf
            Next
	         //Final.

            If !Empty(EEX->EEX_ESP7) .or. lEspSpace
               cBuffer += Space(1)
            EndIf

	        cBUFFER += ENTER
            Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), "T5")
            //FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
	      EndIf

	      /*WFS em 13/04/11
	      A linha T7 é lida antes da T6 quando a modalidade é regime especial de exportação temporária*/
          If !lDSE

             If EEX->( FieldPos("EEX_FNLDD1") > 0 .and.;
                       FieldPos("EEX_FNLDD2") > 0 .and.;
                       FieldPos("EEX_FNLDD3") > 0 )

                cBuffer := "T7"
                cBuffer += EEX->EEX_FNLDD1 +;
                           EEX->EEX_FNLDD2 +;
                           EEX->EEX_FNLDD3

                cBuffer += ENTER
                SI400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), "T7")
             EndIf

          EndIf

	      // GRAVA DADOS DOS DETALHES DA DDE E GERA O TXT
	      cBUFFER := "T6"  // 01/02 - IDENTIFICARDOR T6

	      If lDSE
	         cBuffer += EEX->EEX_DOCIN1 +;
	                    EEX->EEX_DOCIN2 +;
	                    EEX->EEX_DOCIN3 +;
	                    EEX->EEX_INFCO1 +;
	                    EEX->EEX_INFCO2 +;
	                    EEX->EEX_INFCO3 +;
	                    "N"
	      Else
	         EEZ->(DBSETORDER(1))
	         EEZ->(DBSEEK(XFILIAL("EEZ")+EEX->EEX_PREEMB))

             /*
             // by CAF 17/06/2003 Novo Layout todas as NFs na mesma linha
	         nContadorT6 := 1
   	         DO WHILE ! EEZ->(EOF()) .AND.;
	            EEZ->(EEZ_FILIAL+EEZ_PREEMB) = (XFILIAL("EEZ")+EEX->EEX_PREEMB)
	            // GERA O TXT COM OS DETALHES DA DDE
	            IF nContadorT6 == 1 // by CAF 17/06/2003
  	               cBUFFER := cBUFFER+SUBSTR(EEZ->EEZ_CNPJ,09,4)       // 03/06 - 4 DIGITOS DO CGC DEPOIS DA BARRA
	               cBUFFER := cBUFFER+SUBSTR(EEZ->EEZ_CNPJ,13,2)       // 07/08 - 2 DIGITOS FINAIS DO CGC
	            Endif
	            cBUFFER := cBUFFER+STRZERO(VAL(EEZ->EEZ_NF),8,0)    // 09/16 - NOTA FISCAL INICIAL
	            cBUFFER := cBUFFER+PADR(EEZ->EEZ_SER,2," ")         // 17/18 - SERIE INICIAL
	            cBUFFER := cBUFFER+STRZERO(VAL(EEZ->EEZ_A_NF),8,0)  // 19/26 - NOTA FISCAL FINAL
	            cBUFFER := cBUFFER+PADR(EEZ->EEZ_A_SER,2," ")       // 27/28 - SERIE FINAL
	            nContadorT6 ++
	            EEZ->(DBSKIP())
	         ENDDO

	         IF nContadorT6 == 1
	            cBuffer := cBuffer+Space(6)
	         Endif

	         For nContadorT6 := nContadorT6 To 10
	            cBUFFER := cBUFFER+Space(20)
	         Next
	         */

	         /*
	         AMS - 06/06/2005. Geração de NF por CNPJ.
	         */
	         aEEZ := {}

	         EEZ->(dbEval({|| aAdd(aEEZ, {EEZ_CNPJ,;
	                                      EEZ_NF,;
	                                      Transform(EEZ_SER, AvSx3("EEM_SERIE", AV_PICTURE)),;//EEZ_SER,; // RMD - 24/02/15 - Projeto Chave NF
	                                      EEZ_A_NF,;
	                                      Transform(EEZ_A_SER, AvSx3("EEM_SERIE", AV_PICTURE))})},, {|| EEZ_FILIAL == xFilial() .and. EEZ_PREEMB == EEX->EEX_PREEMB}))//EEZ_A_SER})},, {|| EEZ_FILIAL == xFilial() .and. EEZ_PREEMB == EEX->EEX_PREEMB})) // RMD - 24/02/15 - Projeto Chave NF

	         aSort(aEEZ,,, {|x, y| x[1]+x[2] < y[1]+y[2]})

	         For nEEZ := 1 To Len(aEEZ)

	            If aEEZ[nEEZ][1] <> cOldCNPJ
                   If nEEZ > 1
                      cBuffer += "/"
                   EndIf
   	               cBuffer += SubStr(aEEZ[nEEZ][1], 09, 04)+;  //4 digitos do CGC depois da barra.
	                          SubStr(aEEZ[nEEZ][1], 13, 02)    //2 digitos finais do CGC.
                EndIf

	            cBuffer += StrZero(Val(aEEZ[nEEZ][2]), 8, 0)+; //N.F. inicial.
	                       Padr(aEEZ[nEEZ][3], 2, " ")+;       //Nº Serie inicial.
	                       StrZero(Val(aEEZ[nEEZ][4]), 8, 0)+; //N.F. final.
	                       Padr(aEEZ[nEEZ][5], 2, " ")         //Nº Serie final.

	            cOldCNPJ := aEEZ[nEEZ][1]

	         Next

             //cBuffer += "/" + Space(1) nopado por WFS em 19/06/09

             //WFS 19/06/09
             //Total de lançamentos: 10 notas.
             //NF (8) série (2) a NF (8) série (2)
             cBuffer += IncSpace("", (10 - Len(aEEZ)) * 20, .F.)

	      EndIf
          cBuffer += ENTER
          SI400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), "T6")

	      /*
	      AMS - 21/03/2005. Implementação da linha T7 com os campos Finalidade 1, 2 e 3.
	      */
	      /* Trecho comentado por WFS em 13/04/11
	      A linha T7 é lida antes da T6 quando a modalidade é regime especial de exportação temporária
          If !lDSE

             If EEX->( FieldPos("EEX_FNLDD1") > 0 .and.;
                       FieldPos("EEX_FNLDD2") > 0 .and.;
                       FieldPos("EEX_FNLDD3") > 0 )

                cBuffer += ENTER
                Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), "T6")
                //fWrite(hFile, cBuffer, Len(cBuffer))

                cBuffer := "T7"
                cBuffer += EEX->EEX_FNLDD1 +;
                           EEX->EEX_FNLDD2 +;
                           EEX->EEX_FNLDD3

             EndIf

          EndIf

          cBuffer += ENTER
          Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), "T7")*/
          //fWrite(hFile, cBuffer, Len(cBuffer))

	      /*
	      AMS - 17/06/2005. Implementação da linha T8 com dados dos itens do processo.
	      */
	      If !lDSE

	         cBuffer := "T8"

	         EE9->(dbSeek(xFilial()+EEC->EEC_PREEMB))

	         While EE9->(!Eof() .and. EE9_FILIAL == xFilial() .and. EE9_PREEMB == EEC->EEC_PREEMB)

                cDe      := EE9->EE9_UNIDAD
                cPara    := BuscaNCM(EE9->EE9_POSIPI, "YD_UNID")
                nQtdItem := EE9->EE9_SLDINI

	            /*
                Verifica se está habilitado o parametro que liga as consistências para conversões de
                unidade de medidas.
	            */
                If lTabConvUnid .and. EasyGParam("MV_AVG0065",, .T.)

                   /*
                   Verifica se existe conversão da unid.med. do item para unid.med. da NCM.
                   */
                   If AvTransUnid(cDe, cPara, EE9->EE9_COD_I, nQtdItem, .T.) = Nil
                      If aScan(aErrorLog, {|x| x[1] == cDe .and. x[2] == cPara}) = 0
                         aAdd(aErrorLog, {cDe, cPara})
                      EndIf
                   EndIf

                EndIf

                If Len(aErrorLog) > 0
                   EE9->(dbSkip())
                   Loop
                EndIf

                If lTabConvUnid
                   /*
                   Converte a qtde. no item para qtde. na unid.med. da NCM.
                   */
                   nQtdItem_NCM := AvTransUnid(cDe, cPara, EE9->EE9_COD_I, nQtdItem, .F.)
                Else
                   nQtdItem_NCM := nQtdItem
                EndIF

                /*
                Agrupa os itens do processo por RE+Sufixo.
                */
                If (nPos := aScan(aT8, {|x| x[5] == EE9->EE9_RE})) = 0

                   If EE9->(FieldPos("EE9_CODUE") > 0 .and. FieldPos("EE9_LOJUE") > 0)
                      cCodUE   := EE9->EE9_CODUE
                      cLojUE   := EE9->EE9_LOJUE
                      nOpcCNPJ := 1
                   Else
                      cCodUE   := ""
                      cLojUE   := ""
                      nOpcCNPJ := 2
                   EndIf

                   IF lTabConvUnid
                      aAdd(aT8, { CNPJUnidExp(EE9->EE9_PREEMB, EE9->EE9_SEQEMB),; //CNPJUnidExp(cCodUE, cLojUE, nOpcCNPJ)
                               nQtdItem,;
                               nQtdItem_NCM,;
                               AvTransUnid(EE9->EE9_UNPES, cUnKg, EE9->EE9_COD_I, EE9->EE9_PSLQTO, .F.),;
                               EE9->EE9_RE })
                   Else
                      aAdd(aT8, { CNPJUnidExp(EE9->EE9_PREEMB, EE9->EE9_SEQEMB),;
                               nQtdItem,;
                               nQtdItem_NCM,;
                               EE9->EE9_PSLQTO,;
                               EE9->EE9_RE })

                   EndIF
                Else

                   aT8[nPos][2] += nQtdItem
                   aT8[nPos][3] += nQtdItem_NCM
                   IF lTabConvUnid
                      aT8[nPos][4] += AvTransUnid(EE9->EE9_UNPES, cUnKg, EE9->EE9_COD_I, EE9->EE9_PSLQTO, .F.)
                   Else
                      aT8[nPos][4] += EE9->EE9_PSLQTO
                   EndIF

                EndIf

	            EE9->(dbSkip())

	         End

	         /*
	         Montagem e apresentação das conversões não encontradas na tab. de conversões de unidades.
	         */
	         If Len(aErrorLog) > 0

                aEval(aErrorLog, {|x| cMsg += Padc(x[1], 6)+Space(1)+Padc(x[2], 6)+ENTER})

                cMsg := STR0084+Replicate(ENTER, 2)+;    //"Foram encontradas unidades de medidas sem o cadastro na tabela de Conversão de Unidades."
                        STR0085+Space(1)+STR0086+ENTER+; //"  De  "###" Para "
                        "------"+Space(1)+"------"+ENTER+;
                        cMsg+ENTER+;
                        STR0114+ENTER+; //"Para concluir a geração da DDE é necessário que as unidades de medidas"
                        STR0088 //"relacionadas, sejam cadastradas na tabela de conversão de unidades."

	            EECView(cMsg, STR0089)

                fClose(hFile)
                fErase(cPathOr+cFile)

	            lRet := .F.
	            Break

	         EndIf

        /*     aSort(aT8,,, {|x, y| x[5] < y[5]})    // By JPP - 12/07/2005 -13:30 - Alterado para o novo lay-out

	         For nPos := 1 To Len(aT8)
	            cBuffer += IncSpace(aT8[nPos][1], 7, .F.) +; //CNPJ
	                       IncSpace(Transf(aT8[nPos][2], AVSX3("EE9_SLDINI", AV_PICTURE)), 18) +; //Qtde. U.M. Comercializada em KG.
	                       IncSpace(Transf(aT8[nPos][3], AVSX3("EE9_SLDINI", AV_PICTURE)), 18) +; //Qtde. U.M. NCM em KG.
	                       IncSpace(Str(aT8[nPos][4], 15, 5), 18) +;                              //Peso Liquido em KG.
	                       IncSpace(Transf(aT8[nPos][5], AVSX3("EE9_RE", AV_PICTURE)), 14)+;      //R.E. + Sufixo.
	                       "/"+Space(1)
	         Next */
	         For nPos :=1 to len(aT8)  // Converte os dados para o formato de geração do Txt.
	             cCnpj := Right(AllTrim(aT8[nPos][1]), 6)
	             cCnpj := IncSpace(Left(cCnpj,4)+" - "+Right(cCnpj,2),9) //CNPJ
	             cRe   := IncSpace(Transf(aT8[nPos][5], AVSX3("EE9_RE", AV_PICTURE)), 14) //R.E. + Sufixo.
	             cComerc := Transf(aT8[nPos][2], "@E 999999999.99999")
	             cComerc := IncSpace(StrTran(cComerc,",",""),17)  //Qtde. U.M. Comercializada em KG.
	             cNcmQtd := Transf(aT8[nPos][3], "@E 999999999.99999")
	             cNcmQtd := IncSpace(StrTran(cNcmQtd,",",""),17)  //Qtde. U.M. NCM em KG.
	             cPeso   := Str(aT8[nPos][4], 15, 5)
	             cPeso   := IncSpace(StrTran(cPeso,".",""),17) //Peso Liquido em KG.
	             cReOrd  := aT8[nPos][5] // R.E. + Sufixo, sem formatação.
	             aAdd(aT8_Ord,{cCnpj,cRe,cComerc,cNcmQtd,cPeso,cReOrd})
	         Next
            aSort(aT8_Ord,,, {|x, y| x[6]+x[1] < y[6]+y[1]})  // Ordem RE + CNPJ.
            For nPos := 1 To Len(aT8_Ord)
                cBuffer += aT8_Ord[nPos][1]+; //CNPJ
                           aT8_Ord[nPos][2]+; //R.E. + Sufixo.
                           aT8_Ord[nPos][3]+; //Qtde. U.M. Comercializada em KG.
                           aT8_Ord[nPos][4]+; //Qtde. U.M. NCM em KG.
                           aT8_Ord[nPos][5]   //Peso Liquido em KG.
                If nPos < Len(aT8_Ord)
                   If aT8_Ord[nPos][1] <> aT8_Ord[nPos + 1][1]   // Se os CNPJ forem diferentes
                      cBuffer += "/"
                   EndIf
                EndIf
            Next
            cBuffer += "/ "
	      EndIf

          cBuffer += ENTER
          Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), "T8")
          //fWrite(hFile, cBuffer, Len(cBuffer))

	      cBUFFER := "####eof#####"+ENTER
	      Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), "####eof#####")
	      //FWRITE(hFILE,cBUFFER,LEN(cBUFFER))

	      FCLOSE(hFILE)

	      /*
	      AMS - 18/01/2005. Geração do arquivo DDE.001 para identificar novo layout.
	      */
	      If !lDSE
	         If !File(cPathOr+cFileDDE)
	            hFileDDE := EasyCreateFile(cPathOr+cFileDDE)
	            fClose(hFileDDE)
	         EndIf
	      EndIf

	      // GERA O EECTOT.AVG
	      aFILE := DIRECTORY(cPATHOR+"*.INC")
	      aFILE := ASORT(aFILE,,,{|X,Y| X[1] < Y[1]})
	      hFILE := EasyCreateFile(cPATHOR+"EECTOT.AVG")
	      IF hFILE < 0
	         MSGINFO(STR0032+cPATHOR+cFILE,STR0008) //"Erro de criação do arquivo: "###"Aviso"
	      ELSE
	         FOR Z := 1 TO LEN(aFILE)
	             cBUFFER := aFILE[Z,1]+ENTER
	             Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER), aFILE[Z,1])
	             //FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
	         NEXT
	         cBUFFER := "####eof#####"+ENTER
	         Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER),"####eof#####" )
	         //FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
	         FCLOSE(hFILE)
	         MSGINFO(STR0033,STR0008) //"Arquivo gerado com sucesso !"###"Aviso"
	      ENDIF
	   ENDIF

	//END TRANSACTION

    //WFS 19/06/09
    //Fornece ao usuário a alternativa de se conectar ao Siscomex e realizar a integração,
    //uma vez que os arquivos já foram gerados.
    If MsgYesNo(STR0130, STR0008) //Deseja se conectar ao Siscomex e realizar a integração?, Aviso
       //Verificação do terminal do Siscomex
       If nTerminal == 0
          MsgInfo(STR0030, STR0002) //A integração não pode prosseguir pois o terminal do Siscomex não foi definido. Edite o parâmetro MV_AVG0091 e reinicie o processo., Aviso
          Break
       EndIf

      //Vefiricação da existência dos programas necessários para a integração.
      //Diretório onde encontram-se os arquivos CMD de integração.
      cPathCmd:= AllTrim(SubStr(cPathOr, 1, At("ORISISC", cPathOr) - 1))
      cMsg:= ""
      For z:= 1 To Len(aCMD[nTerminal])
         If !File(cPathCmd + aCMD[nTerminal][z])
            cMsg += aCMD[nTerminal][z] + ENTER
         EndIf
      Next
      If !Empty(cMsg)
         MsgInfo(STR0131 + ENTER + cMsg, STR0008) //Os arquivos necessários para a integração não foram encontrados. ### , Aviso
         Break
      Else
         If SI401IntDDE(CNPJUnidExp(EEC->EEC_PREEMB, "1"), 1, 1, cPathCmd + aCMD[nTerminal][1])
            SI400RET()
         EndIf
      EndIf
   EndIf

End Sequence

RestOrd(aSaveOrd)

RETURN(lRET)
*--------------------------------------------------------------------
//STATIC FUNCTION SI400RET()
FUNCTION SI400RET()
LOCAL lRET,nSEQ,cFILE,hFILE,Z,cBUFFER,aARQERR,aFILESOK,aFILESERR,;
      bPROC,nREC,aORD
Local aFilesInc, nInd  // JPP - 28/07/2005 - 16:43
PRIVATE nPROC,aPROCS,aFILES,aEMBARQUE,nPOSARRAY,aDETALHE

//WFS 16/06/09
If Type("cPathOr") == "U"
   cPathOr:= AllTrim(EasyGParam("MV_AVG0002")) //Path para gravaçãoo dos txts
   cPathOr:= cPathOr + If(Right(cPathOr, 1) = "\", "", "\")
EndIf
If Type("cPathDt") == "U"
   cPathDt:= AllTrim(EasyGParam("MV_AVG0003")) //Path de Retorno do txt
   cPathDt:= cPathDt + If(Right(cPathDt, 1) = "\", "", "\")
EndIf
//---
*
aORD      := SAVEORD({"EEX"})
nREC      := EEX->(RECNO())
nPOSARRAY := nPROC := 0
aPROCS    := {}
aFILES    := {}
aEMBARQUE := {}
aDETALHE  := {}
aARQERR   := {}
aFILESOK  := ASORT(DIRECTORY(cPATHOR+"DD*.OK") ,,,{|N1,N2| N1[1] < N2[1]})
aFILESERR := ASORT(DIRECTORY(cPATHOR+"DD*.ERR"),,,{|N1,N2| N1[1] < N2[1]})

IF ! LISDIR(LEFT(cPATHOR,LEN(cPATHOR)-1))
   MSGINFO(STR0006+cPATHOR+STR0007,STR0008) //"Diretorio para gravacao do txt não existe ("###") !"###"Aviso"
   BREAK
ELSEIF ! LISDIR(LEFT(cPATHDT,LEN(cPATHDT)-1))
   MAKEDIR(cPATHDT)
ENDIF

// Carrega array com o(s) nome(s) do(s) txt(s) gerado(s) no retorno do siscomex...
For Z := 1 To Len(aFilesOk)
   cFile := Substr(aFilesOk[Z,1],1,At(".",aFilesOk[Z,1])-1)
   If aScan(aFiles,cFile) = 0
      aAdd(aFiles,cFile)
   EndIf
Next
FOR Z := 1 TO LEN(aFILESERR)
    cFILE := SUBSTR(aFILESERR[Z,1],1,AT(".",aFILESERR[Z,1])-1)
    IF ASCAN(aFILES,cFILE) = 0
       AADD(aFILES,cFILE)
    ENDIF
NEXT
IF LEN(aFILES) = 0
   HELP(" ",1,"AVG0005070") //"Não existem arquivos de retorno para o processamento !","Aviso"
ELSE
   bPROC := {|| PROCREGUA(LEN(aFILES)), aEVAL(aFILES,{|X| SI400LERTXT(X)})}
   PROCESSA(bPROC)
   IF VALTYPE(aEMBARQUE) # "U"
      SI400TREE()
      If EasyEntryPoint("EECSI400")  // By JPP - 24/08/2005 - 17:30 - Inclusão do ponto de entrada
         ExecBlock("EECSI400", .F., .F., {"PE_FIM_RET_DDE"})
      EndIf
   ENDIF

   // JPP - 28/07/2005 - 16:43 - Após o retorno excluir todos os Arquivos ".INC" restantes.
   aFilesInc := DIRECTORY(cPATHOR+"*.INC")
   For nInd := 1 To Len(aFilesInc)
       If File(cPathor+aFilesInc[nInd][1])
          Copy File (cPathor+aFilesInc[nInd][1]) To (cPathdt+aFilesInc[nInd][1])
          FErase(cPathor+aFilesInc[nInd][1])
       EndIf
   Next
ENDIF
RESTORD(aORD)
EEX->(DBGOTO(nREC))
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION SI400LERTXT(cFILE)
LOCAL nX,cFILE2
PRIVATE aDETAILTXT,lERRO
*
aDETAILTXT := {}
lERRO      := .f.
// Monta o nome do arquivo (original)
cFILE2 := cFILE
IF FILE(cPATHOR+cFILE2+".INC")
   cFILE2 += ".INC"
ELSEIF FILE(cPATHOR+cFILE2+".ALT")
       cFILE2 += ".ALT"
ENDIF
SI400LERVE(cFILE+".OK" ,cFILE2)
SI400LERVE(cFILE+".ERR",cFILE2)
SI400ApagaAvg()     // By JPP - 15/07/2005 08:45

cChaveEEX := XFILIAL("EEX")+EEC->EEC_PREEMB
cChaveEE9 := XFILIAL("EE9")+EEC->EEC_PREEMB

FOR nX := 1 TO LEN(aDETAILTXT)

    If EasyEntryPoint("EECSI400")  // ER - 23/01/2007
       ExecBlock("EECSI400", .F., .F., {"PE_LOOP_LERTXT",nX})
    EndIf

    // ** Atualiza o EEX ...
    EEX->(DBSETORDER(1))
    IF (EEX->(DBSEEK(cChaveEEX)))
       EEX->(RECLOCK("EEX",.F.))
       EEX->EEX_NUM  := aDETAILTXT[nX,2]
       EEX->EEX_DATA := aDETAILTXT[nX,3]

       //DFS - 21/03/13 - Ponto de entrada para manipular o retorno da DDE
       If EasyEntryPoint("EECSI400")
          ExecBlock("EECSI400", .F., .F., {"RETORNO_DDE1"})
       EndIf

       //AMS - 01/07/2003 - Gravando o Nº e Data da DDE no EE9.
       EE9->( dbSetOrder( 3 ) )
       EE9->( dbSeek( cChaveEE9 ) )

       While EE9->( !Eof() .and. EE9_FILIAL+EE9_PREEMB == cChaveEE9 )
          EE9->( RecLock( "EE9", .F. ) )
          EE9->EE9_NRSD   := aDETAILTXT[nX,2]
//        EE9->EE9_DTAVRB := aDETAILTXT[nX,3]
          If EE9->(FieldPos("EE9_DTDDE")) > 0
             EE9->EE9_DTDDE  := aDETAILTXT[nX,3]
          EndIf
          EE9->( dbSkip() )
       End

    ENDIF
NEXT

If EasyEntryPoint("EECSI400")  // TRP - 09/01/2007 - 10:30 - Inclusão do ponto de entrada
   ExecBlock("EECSI400", .F., .F., {"PE_FIM_LERTXT"})
EndIf

RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION SI400LERVE(cFILE,cFILE2)
LOCAL cPREEMB,cHORA,dDATA,nLIDOS,hFILE,lFILEOK,aORD,nPOS,cOLDANEXO,Z,;
      cOLDTXT,nPOSANEXO,nSIZE,nBYTES,nENDLINE,nVOLTA,cNUMDDE
PRIVATE cBUFFER,cAUX,cLINE
*
aORD    := SAVEORD({"EEC"})
cLINE   := cPREEMB := cHORA := cOLDANEXO := cOLDTXT := ""
dDATA   := AVCTOD("")
nLIDOS  := nPOSANEXO := 0
lFILEOK := .F.
nBYTES  := BLOCK_READ
BEGIN SEQUENCE
   IF ! FILE(cPATHOR+cFILE)
      BREAK
   ENDIF
   hFILE := EasyOpenFile(cPATHOR+cFILE,FO_READ+FO_EXCLUSIVE)
   nSIZE := FSEEK(hFILE,0,2)
   FSEEK(hFILE,0,0)
   IF FERROR() # 0
      MSGINFO(STR0034+LTRIM(STR(FERROR())),STR0008) //"Erro do DOS nro. "###"Aviso"
      BREAK
   ELSEIF RIGHT(cFILE,3) = ".OK"
          lFILEOK := .t.
   ENDIF
   DO WHILE nLIDOS < nSIZE
      nLidos += SI100ReadLn(hFile,@cLine,nSize)
      IF Empty(cLINE) .OR.;
         (! lFILEOK .AND. LEFT(cLINE,2) # "NP")
         LOOP
      ENDIF
      IF EMPTY(cPREEMB)
         cPREEMB := IF(lFILEOK,LEFT(cLINE,20),SUBSTR(cLINE,3,20))
         Z       := ASCAN(aEMBARQUE,{|Z| Z[1]=cPREEMB})
         IF Z = 0
            AADD(aEMBARQUE,{TRANSFORM(AVKEY(cPREEMB,"EEC_PREEMB"),AVSX3("EEC_PREEMB",AV_PICTURE)),{},{}}) // Embarque ...
            Z := LEN(aEMBARQUE)
         ENDIF
         INCPROC(AVSX3("EEC_PREEMB",AV_TITULO)+" "+TRANSFORM(cPREEMB,AVSX3("EEC_PREEMB",AV_PICTURE)))
         EEC->(DBSETORDER(1))
         EEC->(DBSEEK(xFILIAL()+AVKEY(cPREEMB,"EEC_PREEMB")))
         IF ASCAN(aPROCS,cPREEMB) = 0
            AADD(aPROCS,cPREEMB)
         ENDIF
      ENDIF
      IF lFILEOK
         cNUMDDE := AVKEY(SUBSTR(cLINE,21,20),"EEX_NUM")
         cHORA   := STRTRAN(SUBSTR(cLINE,51,5),":","")
         dDATA   := AVCTOD(SUBSTR(cLINE,41,10))
         AADD(aDETAILTXT,{cPREEMB,cNUMDDE,dDATA,cHORA,"OK",cLINE})
         AADD(aEmbarque[Z,2],LEFT(cFile,8))  // ** Nome Txt.Ok
         EXIT
      ELSE
         lERRO   := .T.
         cHORA   := STRTRAN(SUBSTR(cLINE,33,5),":","")
         dDATA   := AVCTOD("")
         cNUMDDE := ""
         AADD(aDETAILTXT,{cPREEMB,cNUMDDE,dDATA,cHORA,"ERR",cLINE})
         AADD(aEmbarque[Z,3],LEFT(cFILE,8))  // ** Nome Txt.Err
      Endif
   ENDDO
   AADD(aDETALHE,{cFILE,DIRECTORY(cPATHOR+cFILE)})
   FCLOSE(hFILE)
   // ** Apaga os arquivos do diretorio ORISISC
   IF FILE(cPATHOR+cFILE)
     COPY FILE (cPATHOR+cFILE) TO (cPATHDT+cFILE)
     FERASE(cPATHOR+cFILE)
   ENDIF
   IF FILE(cPATHOR+cFILE2)
     COPY FILE (cPATHOR+cFILE2) TO (cPATHDT+cFILE2)
     FERASE(cPATHOR+cFILE2)
   ENDIF
END SEQUENCE
RESTORD(aORD)
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION SI400TREE()
LOCAL lRET,bOK,aCOMBO,bCANCEL,aPROCS,aORD,nX
PRIVATE cCOMBO,cMEMO,oMEMO,oFONT,oTREE,oTREE2,oTREE3,oGETDB,oDLG,;
        aPAGINA,aROTINA,aPOS,lEXISTERRO,lEXISTEOK
*
cCOMBO  := cMEMO := ""
oFONT   := TFONT():NEW("Courier New",09,15)
aPAGINA := {}
aPOS    := {}
lRET    := .T.
bOK     := {||oDLG:END()}
bCANCEL := {||oDLG:END()}
aCOMBO  := {STR0035,STR0036,STR0037} //"Todos"###"Finalizados"###"Pendentes"
aPROCS  := {}
aORD    := SAVEORD("EEC")
nX      := 0
DEFINE MSDIALOG oDLG TITLE STR0047 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Retorno Siscomex"
   aPOS := POSDLG(oDLG)
   @ 15,03 SAY STR0048 SIZE 50,08  PIXEL //"Processos:"
   @ 15,35 COMBOBOX cCOMBO ITEMS aCOMBO SIZE aPOS[4]-35,8 ON CHANGE LOADPROCES(oTree,oTree2,oTree3) PIXEL
   oTree  := DbTree():New(028,002,aPos[3],102,oDlg,,,.T.) // Tree com todas as opcoes...
   oTree2 := DbTree():New(028,002,aPos[3],102,oDlg,,,.T.) // Tree somente com os arquivos ok ...
   oTree3 := DbTree():New(028,002,aPos[3],102,oDlg,,,.T.) // Tree somente com os arquivos erro ...
   LoadTree(oTree,oTree2,oTree3)
   // ** Tree com todos os processos (Txt Ok e Txt Err)
   oTree:bChange := {|| If(Left(oTree:GetCargo(),1)=="P" ,LoadMemo(SubStr(oTree:GetCargo(),2,20),.f.),Nil),;
                        If(Left(oTree:GetCargo(),2)=="TO",LoadMemo(SubStr(oTree:GetCargo(),3,8)+".OK",.t.),Nil),;
                        If(Left(oTree:GetCargo(),2)=="TE",LoadMemo(SubStr(oTree:GetCargo(),3,8)+".ERR",.t.,.t.),Nil)}
   // ** Tree com os processos finalizados ... (.Ok)
   oTree2:bChange := {||If(Left(oTree2:GetCargo(),1)=="P" ,LoadMemo(SubStr(oTree2:GetCargo(),2,20),.f.),Nil),;
                        If(Left(oTree2:GetCargo(),2)=="TO",LoadMemo(SubStr(oTree2:GetCargo(),3,8)+".OK",.t.),Nil)}
   // ** Tree com os processos com erro ...(.Err)
   oTree3:bChange := {|| If(Left(oTree3:GetCargo(),1)=="P" ,LoadMemo(SubStr(oTree3:GetCargo(),2,20),.f.),Nil),;
                         If(Left(oTree3:GetCargo(),2)=="TE",LoadMemo(SubStr(oTree3:GetCargo(),3,8)+".ERR",.t.,.t.),Nil)}
   @ 28,102 GET oMemo VAR cMemo MEMO HSCROLL SIZE aPos[4]-102,aPos[3]-28 READONLY FONT oFont OF oDlg UPDATE PIXEL
   oMemo:lWordWrap := .F.
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)
RestOrd(aOrd)
RETURN(lRET)
*--------------------------------------------------------------------
STATIC FUNCTION LOADPROCESS(oTREE,oTREE2,oTREE3)
LOCAL lRET
*
lRET  := .T.
cMemo := ""
oMemo:Refresh()
If cCombo == STR0035 //"Todos"
   oTree2:Hide()
   oTree3:Hide()
   oTree :Show()
ElseIf cCombo == STR0036 //"Finalizados"
       oTree :Hide()
       oTree3:Hide()
       oTree2:Show()
       If ! lExisteOk
          cMemo := STR0049 //"Nao ha itens para esta selecao."
          oMemo:Refresh()
          oMemo:Show()
       EndIf
Else // Pendente
   oTree :Hide()
   oTree2:Hide()
   oTree3:Show()
   If ! lExistErro
      cMemo := STR0049 //"Nao ha itens para esta selecao."
      oMemo:Refresh()
      oMemo:Show()
   EndIf
EndIf
RETURN(lRet)
*--------------------------------------------------------------------
STATIC FUNCTION LOADMEMO(cProcesso,lTxt,lErro)
LOCAL cFileTxt,nPosFile,lRet
*
Default lErro:=.f.
cFILETXT := ""
lRET     := .T.
nPOSFILE := 0
cMemo    := ""
n        := 1
oMemo:Show()
If ! lTxt
   EEC->(DbSetOrder(1))
   EEC->(DbSeek(xFilial("EEC")+cProcesso))
   // Carrega informações do processo de embarque ...
   cMemo += STR0050+Replic(ENTER,2) //" Dados do Processo de Embarque: "
   cMemo += IncSpace(Space(1)+AvSx3("EEC_PREEMB",AV_TITULO),20,.f.)+": "+EEC->EEC_PREEMB+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_DTPROC",AV_TITULO),20,.f.)+": "+Transf(EEC->EEC_DTPROC,"  /  /  ")+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_STTDES",AV_TITULO),20,.f.)+": "+EEC->EEC_STTDES+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_IMPODE",AV_TITULO),20,.f.)+": "+Posicione("SA1",1,xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA,"A1_NOME")+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_FORNDE",AV_TITULO),20,.f.)+": "+Posicione("SA2",1,xFilial("SA2")+EEC->EEC_FORN+EEC->EEC_FOLOJA,"A2_NOME")+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_INCOTE",AV_TITULO),20,.f.)+": "+EEC->EEC_INCOTE+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_MOEDA ",AV_TITULO),20,.f.)+": "+EEC->EEC_MOEDA+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_CONDPA",AV_TITULO),20,.f.)+": "+SY6Descricao(EEC->EEC_CONDPA+Str(EEC->EEC_DIASPA,AVSX3("EEC_DIASPA",3),AVSX3("EEC_DIASPA",4)),EEC->EEC_IDIOMA,1)+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_MPGEXP",AV_TITULO),20,.f.)+": "+EEC->EEC_MPGEXP+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_LIBSIS",AV_TITULO),20,.f.)+": "+If(!Empty(EEC->EEC_LIBSIS),Transf(EEC->EEC_LIBSIS,"  /  /  ")+ENTER,ENTER)
   cMemo += IncSpace(Space(1)+AvSx3("EEC_URFDSP",AV_TITULO),20,.f.)+": "+EEC->EEC_URFDSP+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_URFENT",AV_TITULO),20,.f.)+": "+EEC->EEC_URFENT+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_INSCOD",AV_TITULO),20,.f.)+": "+EEC->EEC_INSCOD+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_ENQCOD",AV_TITULO),20,.f.)+": "+EEC->EEC_ENQCOD+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_TOTITE",AV_TITULO),20,.f.)+": "+AllTrim(Str(EEC->EEC_TOTITE,AVSX3("EEC_TOTITE",AV_TAMANHO),0))+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EEC_TOTPED",AV_TITULO),20,.f.)+": "+AllTrim(Transf(EEC->EEC_TOTPED,AvSX3("EEC_TOTPED",AV_PICTURE)))+ENTER
Else
   cFileTxt := AllTrim(cProcesso)
   nPosFile := aScan(aDetalhe,{|aX| aX[1] = cFileTxt})
   If nPosFile > 0
      cMemo += STR0051+Replic(ENTER,2) //"Detalhes do arquivo de retorno : "
      cMemo += STR0052+AllTrim(aDetalhe[nPosFile,2,1,1])+ENTER //"Nome         : "
      cMemo += STR0053+AllTrim(Str(aDetalhe[nPosFile,2,1,2]))+STR0054+ENTER //"Tamanho      : "###" bytes"
      cMemo += STR0055+Transf (aDetalhe[nPosFile,2,1,3],"  /  /  ")+ENTER //"Data geracao : "
      cMemo += STR0056+AllTrim(aDetalhe[nPosFile,2,1,4])+ENTER //"Hora geracao : "
      cMemo += Replic(ENTER,2)
      cMemo += STR0057+IF(lERRO,STR0058,"OK:")+ENTER //"Conteudo do arquivo "###"de erro:"
      cMemo += Replic("_",28)+Replic(ENTER,3) // ** Inclui uma divisória entre os dados do arquivo e seu conteúdo...
      // ** Carrega todo o conteúdo do arquivo de erro...
      cMemo += MemoRead(cPATHDT+cFileTxt)
   EndIf
EndIf
oMemo:EnableVScroll(.t.)
oMemo:EnableHScroll(.t.)
oMemo:Refresh()
RETURN(lRET)
*--------------------------------------------------------------------
STATIC FUNCTION LOADTREE(oTree)
LOCAL lRET,cCARGO,nX,nZ,nP,nNIVEL
*
lRet   := .t.
cCargo := ""
nX     := nZ := nP := nNivel := 0
For nX := 1 To Len(aEmbarque)
    // Carrega o Tree com todos os arquivos         *
    nNivel := 0
    // ** Adiciona um embarque ao Tree...
    DBADDTREE oTree PROMPT aEmbarque[nX,1] OPENED RESOURCE 'PMSDOC' CARGO "P"+aEmbarque[nX,1]
    // ** Adiciona Txt.Ok ...
    For nZ := 1 To Len(aEmbarque[nX,2])
        If ValType(aEmbarque[nX,2,nZ]) = "C"
           // ** Adiciona um Txt.Ok ao Tree ...
           If nNivel > 0
              DBENDTREE oTree
           EndIf
           DBADDTREE oTree PROMPT aEmbarque[nX,2,nZ] OPENED RESOURCE 'CHECKED' CARGO "TO"+aEmbarque[nX,2,nZ]
           nNivel++
        Else
           For nP := 1 To Len(aEmbarque[nX,2,nZ])
               // ** Adiciona um Anexo ao Tree ...
               If ValType(aEmbarque[nX,2,nZ,nP]) = "C"
                  DBADDITEM oTree PROMPT  SubStr(aEmbarque[nX,2,nZ,nP],1,14)  RESOURCE 'RELATORIO' CARGO +"A"+SubStr(aEmbarque[nX,2,nZ,nP],15,6)+SubStr(aEmbarque[nX,2,nZ,nP],21,20)
               EndIf
           Next
        EndIf
    Next
    // ** Adiciona Txt.err
    For nZ := 1 To Len(aEmbarque[nX,3])
        If ! Empty(aEmbarque[nX,3,nZ])
           If nNivel > 0
              DBENDTREE oTree
           EndIf
           DBADDTREE oTree PROMPT aEmbarque[nX,3,nZ] RESOURCE 'NOCHECKED' CARGO "TE"+aEmbarque[nX,3,nZ]
           nNivel++
        EndIf
    Next
    DBENDTREE oTree;DBENDTREE oTree
    oTree:Refresh()
    oTree:SetFocus()
    // Carrega o Tree2 com todos os arquivos Ok       *
    nNivel := 0
    If Len(aEmbarque[nX,3]) = 0
       // ** Adiciona um embarque ao Tree...
       DBADDTREE oTree2 PROMPT aEmbarque[nX,1] OPENED RESOURCE 'PMSDOC' CARGO "P"+aEmbarque[nX,1]
       // ** Adiciona Txt.Ok ...
       For nZ := 1 To Len(aEmbarque[nX,2])
           If ValType(aEmbarque[nX,2,nZ]) = "C"
              // ** Adiciona um Txt.Ok ao Tree ..
              If nNivel>0
                 DBENDTREE oTree2
              EndIf
              DBADDTREE oTree2 PROMPT aEmbarque[nX,2,nZ] OPENED RESOURCE 'CHECKED' CARGO "TO"+aEmbarque[nX,2,nZ]
              nNivel++
              lExisteOk := .t.
           Else
              For nP := 1 To Len(aEmbarque[nX,2,nZ])
                  // ** Adiciona um Anexo ao Tree ..
                  If ValType(aEmbarque[nX,2,nZ,nP]) = "C"
                     DBADDITEM oTree2 PROMPT  SubStr(aEmbarque[nX,2,nZ,nP],1,14)  RESOURCE 'RELATORIO' CARGO +"A"+SubStr(aEmbarque[nX,2,nZ,nP],15,6)+SubStr(aEmbarque[nX,2,nZ,nP],21,20)
                  EndIf
              Next
           EndIf
       Next
       DBENDTREE oTree2;DBENDTREE oTree2
    EndIf
    // Carrega o Tree3 com todos os arquivos ERR     *
    nNivel := 0
    If Len(aEmbarque[nX,3]) > 0
       // ** Adiciona um embarque ao Tree...
       DBADDTREE oTree3 PROMPT aEmbarque[nX,1] OPENED RESOURCE 'PMSDOC' CARGO "P"+aEmbarque[nX,1]
       // ** Adiciona Txt.err
       For nZ := 1 To Len(aEmbarque[nX,3])
           If ! Empty(aEmbarque[nX,3,nZ])
              If nNivel > 0
                 DBENDTREE oTree3
              EndIf
              DBADDTREE oTree3 PROMPT aEmbarque[nX,3,nZ] RESOURCE 'NOCHECKED' CARGO "TE"+aEmbarque[nX,3,nZ]
              nNivel++
              lExistErro := .t.
           EndIf
       Next
       DBENDTREE oTree3;DBENDTREE oTree3
    EndIf
Next
oTree2:Hide()
oTree3:Hide()
oTree :Show() //Deixa sempre o tree (Todos os arquivos) ativo como padrão.
RETURN(lRET)
*--------------------------------------------------------------------
STATIC FUNCTION SI400PREP(lNewDDE)
Local lRET,cFILE,hFILE,Z,aFILE
Local cBuffer := ""
Local nCount  := 1
Local lDDEWeb
Local cChaveEEX

Default lNewDDE := .F.

//LGS - 17/06/2015 - Nova rotina de DE-WEB
lDDEWeb := (EEX->(FieldPos("EEX_ID"))>0 .And. EEZ->(FieldPos("EEZ_ID"))>0 .And. lNewDDE)

*
lRET := .T.
BEGIN TRANSACTION
   // CRIA O TXT DA DDE/DSE.
   IF !lDDEWeb
      IF ! EMPTY(EEX->EEX_TXTSIS)
         cFILE := ALLTRIM(EEX->EEX_TXTSIS)
         hFILE := FERASE(cPATHOR+cFILE)
         cFILE := ""
      ENDIF
   ENDIF

   If !lDSE
      PROCREGUA(TMZ->(LASTREC()))
   EndIf

   // GRAVA DADOS DA CAPA DA DDE
   //IF ! EEX->(FOUND()) - AST - 11/09/08
   If lDDEWeb
      cChaveEEX := xFilial("EEX")+M->EEX_PREEMB+M->EEX_ID
   Else
      cChaveEEX := xFilial("EEX")+M->EEX_PREEMB
   EndIf

   EEX->(dbSetOrder(1))
   //IF !EEX->(DbSeek(xFilial("EEX")+M->EEX_PREEMB))
   IF !EEX->(DbSeek(cChaveEEX))
      EEX->(RECLOCK("EEX",.T.))  // INCLUI
   ELSE
      EEX->(RECLOCK("EEX",.F.))  // TRAVA
   ENDIF
   AVREPLACE("M","EEX")
   EEX->EEX_FILIAL := XFILIAL("EEX")
   If !lDDEWeb
      EEX->EEX_TXTSIS := cFILE
   EndIf
   
   EEX->(MsUnlock()) //THTS - 17/10/2017 - Nao estava dando o Unlock, mantendo o registro travado
   
   If !lDSE
      // DELETA OS DETALHES DA DDE
      FOR Z := 1 TO LEN(aDELETE)
          EEZ->(DBGOTO(aDELETE[Z]))
          EEZ->(RECLOCK("EEZ",.F.))
          EEZ->(DBDELETE())
      NEXT

      // GRAVA DADOS DOS DETALHES DA DDE E GERA O TXT
      TMZ->(DBGOTOP())
      DO WHILE ! TMZ->(EOF())
         INCPROC()
         If Empty(TMZ->EEZ_CNPJ)
            TMZ->(dbSkip())
            Loop
         EndIf
         If Empty(TMZ->EEZ_NF) .And. Empty(TMZ->EEZ_A_NF)  // By JPP - 01/08/2005 - 14:20
            TMZ->(DbSkip())
            Loop
         EndIf
         If lDDEWeb .And. TMZ->DBDELETE //LGS-07/01/2016
            TMZ->(DbSkip())
            Loop
         EndIf
         IF EMPTY(TMZ->TMZ_RECNO)
            EEZ->(RECLOCK("EEZ",.T.))
            /*
            EEZ->EEZ_FILIAL := XFILIAL("EEZ")
            EEZ->EEZ_PREEMB := EEC->EEC_PREEMB
            */
         ELSE
            EEZ->(DBGOTO(TMZ->TMZ_RECNO))
            EEZ->(RECLOCK("EEZ",.F.))
         ENDIF
         AVREPLACE("TMZ","EEZ")
         EEZ->EEZ_FILIAL := XFILIAL("EEZ")
         //EEZ->EEZ_PREEMB := Substr(cChaveEEZ,3,AVSX3("EEC_PREEMB",AV_TAMANHO))//EEC->EEC_PREEMB
         EEZ->EEZ_PREEMB := Substr(cChaveEEZ,FWSizeFilial()+1,AVSX3("EEC_PREEMB",AV_TAMANHO))//RMD - 06/09/17 - Considerar o tamanho correto do campo Filial ### THTS - 17/10/2017
         EEZ->(MSUnlock())
         TMZ->(DBSKIP())
      ENDDO

      //GRAVA AS REs DO PROCESSO
      If lDDEWeb
         TWY->(DBGOTOP())
         DO WHILE TWY->(!EOF())
            If !TWY->DBDELETE
               EWY->(RECLOCK("EWY",.T.))
               EWY->EWY_FILIAL	:= TWY->EWY_FILIAL
               EWY->EWY_ID		:= TWY->EWY_ID
               EWY->EWY_PREEMB	:= TWY->EWY_PREEMB
               EWY->EWY_RE		:= TWY->EWY_RE
               EWY->EWY_SEQ_RE	:= cValToChar(nCount++)
               EWY->(MSUnlock())
            EndIf
            TWY->(DBSKIP())
         ENDDO
      EndIf
   EndIf

   //ER - 09/02/2007
   If EasyEntryPoint("EECSI400")
      ExecBlock("EECSI400",.F.,.F.,"PE_PREP")
   EndIf

   // GERA O EECTOT.AVG
   If !lDDEWeb
      aFILE := DIRECTORY(cPATHOR+"*.INC")
      aFILE := ASORT(aFILE,,,{|X,Y| X[1] < Y[1]})
      hFILE := EasyCreateFile(cPATHOR+"EECTOT.AVG")
      IF hFILE < 0
         MSGINFO(STR0032+cPATHOR+cFILE,STR0008) //"Erro de criação do arquivo: "###"Aviso"
      ELSE
         For z := 1 To Len(aFile)
             cBuffer += aFile[z][1] + ENTER
         Next
         cBuffer += "####eof#####" + ENTER
         Si400FWRITE(hFILE,cBUFFER,LEN(cBUFFER),"####eof#####")
         //FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
         FCLOSE(hFILE)
      ENDIF
   EndIf

END TRANSACTION
RETURN(lRET)
*--------------------------------------------------------------------

/*
Função      : EECSI40A
Objetivo    : Direcionar a execução para a função EECSI400, tendo como flag o lDSE.
Autor       : Alexsander Martins dos Santos
Data e Hora : 09/12/2004 às 15:07
*/

Function EECSI40A()

Private lDSE := .T.

Begin Sequence

   If SX2->(DbSeek("EXL"))
      DbSelectArea("EXL")
   EndIf

   If Select("EXL") = 0
     MsgStop(STR0108, STR0011) //"Não foi possivel carregar o arquivo EXL. Verifique se o mesmo, se encontra no dicionário de dados e na base de dados. Em caso de dúvidas entre em contato com o suporte técnico da Average Técnologia."###"Atenção"
     Break
   EndIf

   EECSI400()

End Sequence

Return(Nil)


/*
Função      : NFStr()
Parametro   : aNF = Array com os dados da NF(s)/Serie(s).
Objetivo    : Montar uma string com o número da(s) NF(s)/Serie(s).
Autor       : Alexsander Martins dos Santos
Data e Hora : 03/01/2005 às 13:43.
Observação  : A string gerada com a(s) NF(s) terá um limite máximo de 225(3linhas de 75char) caracteres.
*/

Static Function NFStr(aNF)

Local cRet       := STR0069 //"NF/Serie: "
Local nPos       := 0
Local cNFInicial := ""
Local nCount     := 0

Begin Sequence

   aSort(aNF,,, {|x, y| x[3]+x[2] < y[3]+y[2]})

   For nPos := 1 To Len(aNF)

      If nCount = 0
         cNFInicial := AllTrim(aNF[nPos][3]) + "/" + AllTrim(aNF[nPos][2])
      EndIf

      If nPos = Len(aNF) .or. (Val(aNF[nPos][3])+1 <> Val(aNF[nPos+1][3]) .or. aNF[nPos][2] <> aNF[nPos+1][2])

         If Len(cRet+cNFInicial)+20 > 225
            cRet += "..."
            Break
         EndIf

         cRet += cNFInicial

         If nCount > 1
            cRet += STR0115 + AllTrim(aNF[nPos][3]) + "/" + AllTrim(aNF[nPos][2]) //" até "
         EndIf

         If nPos < Len(aNF)

            cRet += ", "

            If nCount = 1
               cRet += AllTrim(aNF[nPos][3])+"/"+AllTrim(aNF[nPos][2]) + If(nPos < Len(aNF), ", ", ".")
            EndIf

         Else

            If nCount = 1
               cRet +=  ", " + AllTrim(aNF[nPos][3])+"/"+AllTrim(aNF[nPos][2])
            EndIf

            cRet += "."

         EndIf

         nCount := 0

      Else

         nCount++

      EndIf

   Next

End Sequence

Return(cRet)


/*
Função      : FieldEspecie
Objetivo    : Retornar um Array com todas as especies que existem no SX3.
Autor       : Alexsander Martins dos Santos
Data e Hora : 04/01/2005 às 15:10
*/

Static Function FieldEspecie()

Local aRet     := {}
Local aSaveOrd := SaveOrd("SX3", 2)
Local cEspecie := ""
Local lDEWeb   := .F.

Begin Sequence

   If SX3->(dbSeek("EEX_PESB"))
      lDEWeb := .T.
   EndIf

   SX3->(dbSeek("EEX_ESP"))

   While SX3->(!Eof() .and. Left(X3_CAMPO, 7) = "EEX_ESP")

      cEspecie := SubStr(AllTrim(SX3->X3_CAMPO), 8)
      If lDEWeb
         aAdd( aRet, { AllTrim(SX3->X3_CAMPO),;
                        "EEX_DESP" + cEspecie,;
                        "EEX_QTD"  + cEspecie,;
                        "EEX_MARK" + cEspecie,;
                        "EEX_PESB" + cEspecie,;
                        "EEX_EMB"  + cEspecie,;
                        SX3->X3_ORDEM } )
      Else
         aAdd( aRet, { AllTrim(SX3->X3_CAMPO),;
                        "EEX_DESP" + cEspecie,;
                        "EEX_QTD"  + cEspecie,;
                        "EEX_MARK" + cEspecie,;
                        SX3->X3_ORDEM } )
      EndIf

      SX3->(dbSkip())

   End

   If lDEWeb
      aSort(aRet,,, {|x, y| x[7] < y[7]})
   Else
      aSort(aRet,,, {|x, y| x[5] < y[5]})
   EndIf

End Sequence

RestOrd(aSaveOrd)

Return(aRet)


/*
Função      : DSESelAgrup
Objetivo    : Tela de seleção de agrupamento do itens da DSE.
Retorno     : 1 - Agrupamento por Item.
              2 - Agrupamento por N.C.M.
Autor       : Alexsander Martins dos Santos
Data e Hora : 05/01/2005 às 15:10
*/

Static Function DSESelAgrup()

Local nRet := 0
Local oDlg

Define MSDialog oDlg Title STR0072 From 9,0 To 15,30 Of oMainWnd //"Agrupamento"

@ 05,005 To 42,115 Label STR0071 Pixel //"Selecione a forma de agrupamento"

@ 21,025 Button STR0073 Size 35,12 Action (nRet := 1, oDlg:End()) Of oDlg Pixel //"Item"
@ 21,065 Button STR0074 Size 35,12 Action (nRet := 2, oDlg:End()) Of oDlg Pixel //"N.C.M."

Activate MsDialog oDlg Centered

Return(nRet)


/*
Função      : DSERetorno()
Objetivo    : Carregar o retorno através do arquivo binário com extensão *.OK.
Autor       : Alexsander Martins dos Santos
Data e Hora : 06/01/2005 às 17:46.
*/

Static Function DSERetorno()

Local cFile    := EEX->EEX_TXTSIS
Local cMsg     := ""
Local aSaveOrd := SaveOrd("EXL", 1)
Local lEECView := .F.
Local hFile, nSize

Private cLine

Begin Sequence

   If Empty(cFile)
      MsgStop(STR0075, STR0011) //"Processo sem geração de DSE. Deve-se primeiro gerar a DSE para depois obter o retorno."###"Atenção"
      Break
   EndIf

   cFile := AllTrim(cFile)
   cFile := Left(cFile, At(".", cFile)) + "OK"

   If !File(cPathOR+cFile)
      MsgStop(STR0076, STR0011) //"Arquivo de retorno não encontrado."###"Atenção"
      Break
   EndIf

   hFile := EasyOpenFile(cPathOR+cFile, FO_READ+FO_EXCLUSIVE)
   nSize := fSeek(hFile, 0, 2)

   fSeek(hFile, 0, 0)

   If fError() <> 0
      MsgStop(STR0034 + Ltrim(Str(fError())), STR0011)
      Break
   EndIf

   nLidos := SI100ReadLn(hFile, @cLine, nSize)

   If AVKey(Left(cLine, 20), "EEC_PREEMB") <> EEC->EEC_PREEMB
      MsgStop(STR0091, STR0011) //"A chave de identificação do processo que se encontra no arquivo de retorno é invalida."###"Atenção"
      fClose(hFile)
      Break
   EndIf

   cMsg += STR0077 + Replicate(ENTER, 2) //"Retorno da DSE"

   cMsg += STR0078 + Left(cLine, 20)       + ENTER +;            //"Processo : "
           STR0079 + SubStr(cLine, 21, 20) + ENTER +;            //"Nº. DSE  : "
           STR0080 + SubStr(cLine, 41, 10) + ENTER +;            //"Data     : "
           STR0081 + SubStr(cLine, 51,  5) + Replicate(ENTER, 3) //"Hora     : "

   cMsg += STR0082 + ENTER +; //"Para confirmar o retorno da DSE, escolha o botão Ok, caso contrário"
           STR0083            //"Cancelar."

   lEECView := EECView(cMsg, STR0077) //"Retorno da DSE"

   If lEECView

      RecLock("EEX", .F.)

      EEX->EEX_NUM  := SubStr(cLine, 21, 20)
      EEX->EEX_DATA := Ctod(SubStr(cLine, 41, 10))

      //DFS - 21/03/13 - Ponto de entrada para manipular o retorno da DDE
      If EasyEntryPoint("EECSI400")
         ExecBlock("EECSI400", .F., .F., {"RETORNO_DDE2"})
      EndIf

      EEX->(MSUnlock())

      /*
      Atualização dos campos na capa do Embarque (EXL).
      */
      EXL->(dbSeek(xFilial()+AVKey(Left(cLine, 20), "EEC_PREEMB")))

      RecLock("EXL", .F.)

      EXL->EXL_DSE   := SubStr(cLine, 21, 20)
      EXL->EXL_DTDSE := Ctod(SubStr(cLine, 41, 10))

      EXL->(MSUnlock())

      If EasyEntryPoint("EECSI400")  // By JPP - 24/08/2005 - 17:30 - Inclusão do ponto de entrada
         ExecBlock("EECSI400", .F., .F., {"PE_FIM_RET_DSE"})
      EndIf

   EndIf

   fClose(hFile)

   /*
   Move o arquivo para a pasta HISSISC.
   */
   If lEECView

      Copy File (cPathOR+cFile) To (cPathDT+cFile)
      fErase(cPathOR+cFile)

      cFile := Left(cFile, At(".", cFile)) + "INC"

      Copy File (cPathOR+ cFile ) To (cPathDT+cFile)
      fErase(cPathOR+cFile)

      MsgInfo(STR0090, STR0011) //"Retorno da DSE concluído com sucesso."###"Atenção"

   EndIf

End Sequence

RestOrd(aSaveOrd)

Return(Nil)


/*
Função      : SI400Estorno
Objetivo    : Estornar a Preparação e Geração da DDE e DSE.
Retorno     : Nil
Autor       : Alexsander Martins dos Santos
Data e Hora : 13/01/2005 às 09:30
*/

Static Function SI400Estorno()

Local cOpcao := If(lDSE, "DSE", "DDE")
Local aSaveOrd

If lDSE
   aSaveOrd := SaveOrd({"EE9", "EEZ", "EXL"}) //DSE
Else
   aSaveOrd := SaveOrd({"EE9", "EEZ"}) //DDE
EndIf

Begin Sequence

   If lVal_EEX .And. !EEX->(Found())
      MsgStop(STR0093+cOpcao+STR0094, STR0011) //"Processo sem preparação de "###" para estornar."###"Atenção"
      Break
   EndIf

   If !MsgYesNo(STR0095+cOpcao+".", STR0011) //"Confirma o estorno da preparação e geração da "###"Atenção"
      Break
   EndIf

   If EasyEntryPoint("EECSI400")
      ExecBlock("EECSI400", .F., .F., {"PE_EST"})
   EndIf

   If lDSE

      EXL->(dbSetOrder(1))
      If EXL->(dbSeek(xFilial()+EEC->EEC_PREEMB))

      RecLock("EXL", .F.)

      EXL->EXL_DSE   := ""
      EXL->EXL_DTDSE := AVCtod("")

      EXL->(MSUnlock())
      EndIf
   Else

      EE9->(dbSetOrder(2))
      EE9->(dbSeek(xFilial()+EEC->EEC_PREEMB))

      While EE9->(!Eof() .and. EE9_FILIAL == xFilial() .and. EE9_PREEMB == EEC->EEC_PREEMB)

         RecLock("EE9", .F.)

         EE9->EE9_NRSD   := ""
         EE9->EE9_DTAVRB := AVCtod("")

         If EE9->(Fieldpos("EE9_DTDDE")) > 0 // By JPP - 12/07/2005 - 17:45
            EE9->EE9_DTDDE := AVCtod("")
         EndIf

         EE9->(MSUnlock())

         EE9->(dbSkip())

      End

      EEZ->(dbSetOrder(1))
      EEZ->(dbSeek(xFilial()+EEC->EEC_PREEMB))

      While EEZ->(!Eof() .and. EEZ_FILIAL == xFilial() .and. EEZ_PREEMB == EEC->EEC_PREEMB)

         RecLock("EEZ", .F.)
         EEZ->(dbDelete())
         EEZ->(MSUnlock())

         EEZ->(dbSkip())

      End

   EndIf

   RecLock("EEX", .F.)
   EEX->(dbDelete())
   EEX->(MSUnlock())

   MsgInfo(STR0096+cOpcao+STR0097, STR0011) //"Estorno da "###" concluído com sucesso."###"Atenção"

End Sequence

RestOrd(aSaveOrd)

Return(Nil)


/*
Funcao      : SI400VldPre
Objetivo    : Validação da Preaparação da DDE/DSE.
Return      : .T. = Dados consistentes.
              .F. = Dados inconsistentes.
Autor       : Alexsander Martins dos Santos
Data e Hora : 13/01/2005 às 18:17.
*/

Function SI400VldPre(lDEWeb)
Local lRet    := .F.
Local nTotVol := 0
Local nPos    := 0
local lMsg := lTMZ := lTWY := lDocInst := .F.
Default lDEWeb:= .F.

Begin Sequence

   If !Obrigatorio(aGets,aTela)
      Break
   EndIf

   If lDSE

      /*
      If M->EEX_CSA = SIM .and. Empty(M->EEX_CSATIP)
         MsgStop(STR0102+AVSX3("EEX_CSATIP", 15)+STR0103+AVSX3("EEX_CSA", AV_TITULO)+STR0104+AVSX3("EEX_CSATIP", AV_TITULO)+".", STR0011) //"Na pasta "###", o campo Tipo não foi preenchido. Devido o campo "###" for igual à Sim é obrigatório o preenchimento do campo "
         Break
      EndIf
      */

   Else

      /*
      Consistência para não permitir R.E. + Sufixo inicial sem Sufixo final ou ao contrário.
      */
      For nPos := 1 To Len(aFieldRE)

         If Empty(M->&(aFieldRE[nPos][1])) .and. !Empty(M->&(aFieldRE[nPos][2]))
            MsgStop(STR0105 +AVSX3(aFieldRE[nPos][1], 15)+ STR0106 +AVSX3(aFieldRE[nPos][1], AV_TITULO)+ STR0107, STR0011) //"Na pasta "###", o campo "###" não foi preenchido. O mesmo deve ser preenchido para confirmação da preparação."###"Atenção"
            Break
         EndIf

         If Empty(M->&(aFieldRE[nPos][2])) .and. !Empty(M->&(aFieldRE[nPos][1]))
            MsgStop(STR0105 +AVSX3(aFieldRE[nPos][2], 15)+ STR0106 +AVSX3(aFieldRE[nPos][2], AV_TITULO)+ STR0107, STR0011) //"Na pasta "###", o campo "###" não foi preenchido. O mesmo deve ser preenchido para confirmação da preparação."###"Atenção"
            Break
         EndIf

      Next

      /*
      Consistência para não permitir CNPJ/CPF do representante legal, esteja vazio e o tipo(Fisica/Juridica) esteja selecionado.
      */
      If EEX->(FieldPos("EEX_RLFJ")) > 0 .and. !Empty(M->EEX_RLFJ) .and. Empty(M->EEX_CNPJ_R)
         MsgStop(STR0116 +Replicate(ENTER, 2)+; //"CNPJ/CPF do Representante Legal não informado."
                 STR0117+AVSX3("EEX_CNPJ_R", AV_TITULO)+STR0118+AVSX3("EEX_RLFJ", AV_TITULO)+STR0119, STR0011) //"O campo "###" deve ser informado, devido o campo "###" estar preenchido."###"Atenção"
         Break
      EndIf

   EndIf

   aEval(aFieldEspecie, {|x| nTotVol += Val(M->&(x[3]))})
   M->EEX_QTDTOT := Transform(nTotVol, "99999999")

   If lDEWeb
      cMsg01 := cMsg02 := cMsg03 := cMsg04 := cMsg05 := cMsg06 := ""
      TMZ->(DbGoTop())
      Do While TMZ->(!Eof())
         If Empty(TMZ->EEZ_ID) //Qdo inclui uma NF em modo de edição entra nesse cenario.
            TMZ->(RecLock("TMZ",.F.))
            TMZ->EEZ_PREEMB := M->EEX_PREEMB
            TMZ->EEZ_ID     := M->EEX_ID
            TMZ->(MsUnlock())
         EndIf
         TMZ->(DbSkip())
      EndDo

      TMZ->(DbGoTop())
      Do While TMZ->(!Eof()) .And. TMZ->(EEZ_PREEMB+EEZ_ID) == M->(EEX_PREEMB+EEX_ID)
         If !TMZ->DBDELETE .And. !Empty(TMZ->EEZ_CHVNFE) .And. Len(Alltrim(TMZ->EEZ_CHVNFE)) <> 44
            lTMZ := lMsg := .T.
            cMsg01 += ENTER + "NF " + Alltrim(cValToChar(TMZ->EEZ_NF)) + " " + Alltrim(cValToChar(TMZ->EEZ_SER)) +;
                              " - chave de acesso com tamanho diferente de 44 digitos." + ENTER
         EndIf
         If !TMZ->DBDELETE .And. Empty(TMZ->EEZ_CHVNFE)
            lTMZ := lMsg := .T.
            cMsg02 += ENTER + "NF " + Alltrim(cValToChar(TMZ->EEZ_NF)) + " " + Alltrim(cValToChar(TMZ->EEZ_SER)) +;
                              " - informar a chave de acesso de 44 digitos." + ENTER
         EndIf
         TMZ->(DbSkip())
      EndDo

      TWY->(DbGoTop())
      Do While TWY->(!Eof())
         If !TWY->DBDELETE .And. Empty(TWY->EWY_ID)
            TWY->(RecLock("TWY",.F.))
            TWY->EWY_PREEMB := M->EEX_PREEMB
            TWY->EWY_ID		:= M->EEX_ID
            TWY->EWY_FILIAL := EE9->EE9_FILIAL
            TWY->(MsUnlock())
         EndIf
         If !TWY->DBDELETE .And. Empty(TWY->EWY_RE)
            lTWY := lMsg := .T.
            cMsg03 := ENTER + "Revise as RE(s) do processo, existem RE(s) sem número." + ENTER
         EndIf
         If !TWY->DBDELETE .And. !Empty(TWY->EWY_RE) .And. Len(Alltrim(TWY->EWY_RE)) <> 12
            lTWY := lMsg := .T.
            cMsg04 += ENTER + "RE " + Alltrim(cValToChar(TWY->EWY_RE)) + " está com o tamanho diferente de 12 digitos" + ENTER
         EndIf
         TWY->(DbSkip())
      EndDo

      If !lTWY .And. !lTMZ
         TMZ->(DbGoTop())
         TWY->(DbGoTop())
         Do While TMZ->(!Eof())
            If TMZ->DBDELETE
               TMZ->(RecLock("TMZ",.F.))
               TMZ->(dbDelete())
               TMZ->(__dbPack())
               TMZ->(MsUnlock())
            EndIf
            TMZ->(DbSkip())
         EndDo
         Do While TWY->(!Eof())
            If TWY->DBDELETE
               TWY->(RecLock("TMZ",.F.))
               TWY->(dbDelete())
               TWY->(__dbPack())
               TWY->(MsUnlock())
            EndIf
            TWY->(DbSkip())
         EndDo
      EndIf

      TMZ->(DbGoTop())
      If TMZ->(Eof()) .And. Empty(M->EEX_ODLTIP)
         lDocInst := lMsg := .T.
         cMsg05 += ENTER + STR0145
      Else
         If !Empty(M->EEX_ODLTIP) .And. Empty(M->EEX_ODLIDT)
            lDocInst := lMsg := .T.
            cMsg06 += ENTER + STR0146
         EndIf
      EndIf
      TMZ->(DbGoTop())
      TWY->(DbGoTop())

   EndIf

   If lMsg
      If lTMZ
         cMsg := "Problema(s) na validação da(s) chave(s) de acesso da(s) NF(s):" +;
                 ENTER + cMsg01 + cMsg02
                 EECView(cMsg)
      EndIf
      If lTWY
         cMsg := "Problema(s) na validação da(s) RE(s):" + ENTER + cMsg03 + cMsg04
         EECView(cMsg)
      EndIf
      If lDocInst
         cMsg := STR0149 + ENTER + cMsg05 + cMsg06
         EECView(cMsg)
      EndIf
      lRet := .F.
   Else
      lRet := .T.
   EndIf

   If lDEWeb
      If ValType(oDLG) == "O"
         oDLG:Refresh()
      EndIf
      If ValType(oGetdbNF) == "O"
         oGetdbNF:oBrowse:Refresh()
      EndIf
      If ValType(oGetdbRE) == "O"
         oGetdbRE:oBrowse:Refresh()
      EndIf
   EndIf

End Sequence
Return(lRet)


/*
Função      : FieldRE
Objetivo    : Retornar um Array com todos os campos do RE que existem no SX3.
Autor       : Alexsander Martins dos Santos
Data e Hora : 17/01/2005 às 13:41.
*/

Static Function FieldRE()

Local aRet     := {}
Local aSaveOrd := SaveOrd("SX3", 1) //SaveOrd("SX3", 2)
Local cRE      := ""

Begin Sequence
   //FSY - 10/10/2013 - Nopado sendo substitudo pelo While abaixo.
   /*
   SX3->(dbSeek("EEX_RE1"))
   SX3->(dbEval({|| aAdd(aRet, {RTrim(X3_CAMPO), X3_ORDEM})},, {|| Left(X3_CAMPO, 6) = "EEX_RE"},,, .F.))
   aSort(aRet,,, {|x, y| x[2] < y[2]})
   */
   /*
   SX3->(dbSeek("EEX"),;
         dbEval({|| aAdd(aRet, {X3_CAMPO, RTrim(X3_CAMPO)+"C"})}, {|| Left(X3_CAMPO, 6) == "EEX_RE" .and. X3_TAMANHO = 12}))

   */
   //FSY - 10/10/2013 - Ajuste para melhorar o desempenho da rotina
   SX3->(dbSetorder(2))
   SX3->(dbSeek("EEX_RE"))
   Do While "EEX_RE" $ SX3->X3_CAMPO
      If SX3->X3_TAMANHO == 12
         aAdd(aRet,{SX3->X3_CAMPO,RTrim(SX3->X3_CAMPO)+"C"})
      End If
      SX3->(dbSkip())
   End Do
   //FSY - 10/10/2013 - Ajuste para melhorar o desempenho da rotina
End Sequence

RestOrd(aSaveOrd)

Return(aRet)

/*
Função    : SI400DestNCM()
Objetivo  : Retonar o Destaque da NCM.
Parametro : cPedido    = Codigo do pedido.
            cSequencia = Sequencia do item no pedido.
*/

Static Function SI400DestNCM(cPedido, cSequencia)

Local cDestNCM := ""

Begin Sequence

   If EE8->(FieldPos("EE8_DTQNCM")) > 0
      cDestNCM := Posicione("EE8", 1, xFilial("EE8")+AVKey(cPedido, "EE8_PEDIDO")+AVKey(cSequencia, "EE8_PEDIDO"), "EE8_DTQNCM")
   EndIf

   If Empty(cDestNCM)
   // cDestNCM := Posicione("SYD", 1, xFilial("SYD")+EE9->EE9_POSIPI, "YD_SISCEXP")
      cDestNCM := Posicione("SYD", 1, xFilial("SYD")+EE9->EE9_POSIPI, "YD_DESTAQU") //SVG 11/09/08
   EndIf

End Sequence

Return(cDestNCM)


/*
Função      : DDEVldNF
Objetivo    : Validar a inclusão ou alteração da NF.
Returno     : .T. = Dados consistentes.
              .F. = Dados inconsistentes.
Autor       : Alexsander Martins dos Santos
Data - Hora : 08/06/2005 - 10:38.
*/

Function DDEVldNF()

Local lRet := .F.

Begin Sequence

   If !Obrigatorio(aGets, aTela)
      Break
   EndIf

   lRet := .T.

End Sequence

Return(lRet)


/*
Função      : DDEVldDelNF
Objetivo    : Validar a exclusão da NF.
Returno     : .T. = Exclusão permitida.
              .F. = Exclusão não permitida.
Autor       : Alexsander Martins dos Santos
Data - Hora : 08/06/2005 - 10:38.
*/

Function DDEVldDelNF()

Local lRet   := .F.
Local nRecno

Begin Sequence

   nRecno := TMZ->TMZ_RECNO

   If !TMZ->DBDELETE

      /*
      Exclusão da NF.
      */
      If !MsgYesNo(STR0120, STR0011) //"Confirma a exclusão da NF?"###"Atenção"
         Break
      EndIf

      If !Empty(nRecno)
         aAdd(aDelete, nRecno)
      EndIf

      nGetTotNFs := (NFSumRange() - NFRange(TMZ->EEZ_NF, TMZ->EEZ_A_NF))

   Else

      /*
      Recuperação da NF.
      */
      If !MsgYesNo(STR0121, STR0011) //"Confirma a recuperação da NF?"###"Atenção"
         Break
      EndIf

      If !Empty(nRecno)
         aDel(aDelete, aScan(aDelete, nRecno))
         aSize(aDelete, Len(aDelete)-1)
      EndIf

      nGetTotNFs := (NFSumRange() + NFRange(TMZ->EEZ_NF, TMZ->EEZ_A_NF))

   EndIf

   oGetTotNFs:Refresh()

   lRet := .T.

End Sequence

Return(lRet)

/*
Função      : DDEVldDelRE
Objetivo    : Validar a exclusão da re.
Returno     : .T. = Exclusão permitida.
              .F. = Exclusão não permitida.
Autor       : Laercio G Souza Jr
Data - Hora : 26/06/2015 10:39
*/
Function DDEVldDelRE()
Local lRet   := .F.

Begin Sequence

   If !TWY->DBDELETE
      If !MsgYesNo("Confirma a exclusão da RE?", STR0011) //###"Atenção"
         Break
      EndIf
      TWY->(RecLock("TWY",.F.))
      TWY->DBDELETE := .T.
      TWY->(MsUnlock())
   Else
      If !MsgYesNo("Confirma a recuperação da RE?", STR0011) //###"Atenção"
         Break
      EndIf
      TWY->(RecLock("TWY",.F.))
      TWY->DBDELETE := .F.
      TWY->(MsUnlock())
   EndIf

   If ValType(oDLG) == "O"
      oDLG:Refresh()
   EndIf
   If ValType(oGetdbRE) == "O"
      oGetdbRE:oBrowse:Refresh()
   EndIf
End Sequence

Return(lRet)

/*
Função      : FieldsGetdb
Objetivo    : Montar e retornar um array com os campos que devem ser apresentados no MSGetdb.
Parametro   : cAlias      = Alias da tabela que terão os campos analisados e adicionados no array de retorno.
Retorno     : aRet[x][1]  = Título
                     [2]  = Campo
                     [3]  = Picture
                     [4]  = Tamanho
                     [5]  = Decimal
                     [6]  = Validação
                     [7]  = Reservado
                     [8]  = Tipo
                     [9]  = Reservado
                     [10] = Reservado
Autor       : Alexsander Martins dos Santos
Data - Hora : 08/06/2005 - 11:07.
*/

Function FieldsGetdb(cAlias)

Local aRet     := {}
Local aSaveOrd := SaveOrd("SX3", 1)

Begin Sequence

   SX3->(dbSeek(cAlias))

   While SX3->(!Eof() .and. X3_ARQUIVO = cAlias)

      If SX3->(X3_NIVEL > cNivel .or. !X3Uso(X3_USADO) .or. X3_TIPO = "M" .or. X3_BROWSE <> "S")
         SX3->(dbSkip())
         Loop
      EndIf

      SX3->(aAdd(aRet, {X3_TITULO,;
                        X3_CAMPO,;
                        X3_PICTURE,;
                        X3_TAMANHO,;
                        X3_DECIMAL,;
                        X3_VALID,;
                        "",;
                        X3_TIPO,;
                        "",;
                        "" }))

      SX3->(dbSkip())

   End

End Sequence

RestOrd(aSaveOrd, .T.)

Return(aRet)


/*
Função      : NFSumRange
Objetivo    : Totalizar a escala de NF's através da faixa estabeleciada entre NF(incio) e NF(fim).
Retorno     : nRet = Total de NF's.
Autor       : Alexsander Martins dos Santos
Data - Hora : 10/06/2005 - 14:51
*/

Static Function NFSumRange()

Local nRet := 0

Begin Sequence

   TMZ->(Eval({|x| dbGoTop(),;
                   dbEval({|| nRet += NFRange(EEZ_NF, EEZ_A_NF)}, {|| !DBDELETE}),;
                   dbGoTo(x)}, Recno()))

End Sequence

Return(nRet)


/*
Função      : NFRange
Objetivo    : Retorna a escala da NF entre a faixa determinda entre NF(inicio) e NF(fim).
Parametro   : cNFa = NF de inicio.
              cNFb = NF de fim.
Retorno     : nRet = Qtde de NF´s entre cNFB e cNFE.
Autor       : Alexsander Martins dos Santos
Data - Hora : 10/06/2005 - 14:59
*/

Static Function NFRange(cNFa, cNFb)

Local nRet := 0

Begin Sequence

   nRet := (NFNumber(cNFb)-NFNumber(cNFa))+1

End Sequence

Return(nRet)


/*
Função      : NFNumber
Objetivo    : Tratar a string passada como parametro e retornar o número da NF.
Parametro   : cString = String com o número da NF.
Retorno     : nNF     = Número da NF.
Autor       : Alexsander Martins dos Santos
Data - Hora : 10/06/2005 - 15:29.
*/

Static Function NFNumber(cString)

Local nRet := 0
Local nPos := 1

Begin Sequence

   cString := AllTrim(cString)

   While .T.

      If !IsDigit(Right(cString, nPos)) .or. nPos = Len(cString)
         nPos--
         Exit
      EndIf

      nPos++

   End

   nRet := Val(Right(cString, nPos))

End Sequence

Return(nRet)


/*
Função      : EEZTrigger
Objetivo    : Executar gatilho para os campos EEZ_NF e EEZ_A_NF.
Parametros  : cCampo     = Campo originario da chamada.
              cSequencia = Sequencia de execução.
Retorno     : xRet       = Conteúdo a ser retornado no campo contra dominio.
Autor       : Alexsander Martins dos Santos
Data - Hora : 13/06/2005 - 11:10.
*/

Function EEZTrigger(cCampo, cSequencia)

Local xRet

Begin Sequence

   Do Case

      Case cCampo == "EEZ_NF"

         If cSequencia == "001"

            If Empty(TMZ->EEZ_A_NF)
               xRet := M->EEZ_NF
            Else
               xRet := TMZ->EEZ_A_NF
            EndIf

            nGetTotNFs := (NFSumRange() - NFRange(TMZ->EEZ_NF, TMZ->EEZ_A_NF)) + NFRange(M->EEZ_NF, xRet)

         EndIf

      Case cCampo == "EEZ_A_NF"

         If cSequencia == "001"
            xRet := M->EEZ_A_NF
         EndIf

         nGetTotNFs := (NFSumRange() - NFRange(TMZ->EEZ_NF, TMZ->EEZ_A_NF)) + NFRange(TMZ->EEZ_NF, xRet)

   End Case

   oGetTotNFs:Refresh()

End Sequence

Return(xRet)


/*
Função      : BuscaNCM
Objetivo    : Localizar a NCM no cadastro de NCM e retornar o conteúdo do campo passado como parametro.
Parametro   : cNCM    = Codigo da NCM.
              cField  = Campo a ter seu conteúdo retornado.
Retorno     : xRet    = Conteúdo do campo passado como parametro(cField)
Autor       : Alexsander Martins dos Santos
Date - Hora : 17/06/2005 - 16:48.
*/

Function BuscaNCM(cNCM, cField)

Local aSaveOrd := SaveOrd("SYD", 1)
Local xRet

Begin Sequence

   SYD->( dbSeek(xFilial()+cNCM),;
          xRet := &cField )

End Sequence

RestOrd(aSaveOrd)

Return(xRet)
/*
Funcao      : SI400ApagaAvg()
Parametros  : Nenhum
Retorno     : NIL
Objetivos   : Apagar os arquivos com extensão AVG.
Autor       : Julio de Paula Paz
Data/Hora   : 15/07/2005 08:15
Revisao     :
Obs.        :
*/
Static Function SI400ApagaAvg()
Local aFile,nInd
Begin Sequence
   aFILE := DIRECTORY(cPATHOR+"*.AVG")
   For nInd := 1 to Len(aFile)
       FErase(cPATHOR+aFILE[nInd][1])
   Next
End Sequence
Return Nil
/*
Funcao      : SI400HaArq()
Parametros  : Nenhum
Retorno     : .T./.F.
Objetivos   : Verifica se Existe Arquivos com a Extensão ".ERR" e ".OK"
Autor       : Julio de Paula Paz
Data/Hora   : 15/07/2005 09:15
Revisao     :
Obs.        :
*/
Static Function SI400HaArq()
Local aFile1,aFile2,lRet := .F.
Begin Sequence
   aFile1 := DIRECTORY(cPATHOR+"*.ERR")
   aFile2 := DIRECTORY(cPATHOR+"*.OK")
   If Len(aFile1) > 0 .Or. Len(aFile2) > 0
      lRet := .T.
   EndIf
End Sequence
Return lRet

/*
Funcao      : SI400FWrite
Parametros  : hFile  - Identificação do arquivo
              cTexto - Conteúdo a ser gravado
              nTam   - Tamanho do conteúdo a ser gravado
              cId    - Identificação da gravação
Retorno     : nRet - Retorno da função FWrite
Objetivos   : Gravar o conteúdo da integração no arquivo texto
Autor       : Thiago Rinaldi Pinto
Data/Hora   : 09/01/2007
Revisao     :
Obs.        :
*/
Function SI400FWrite(hFile, cTexto, nTam, cId)
Local nRet
Default cTexto  := ""
Default nTam    := 0
Private cBuffer := cTexto
Private nLen    := nTam

Begin Sequence

   If EasyEntryPoint("EECSI400")
      ExecBlock("EECSI400", .F., .F., {"PE_FWRITE", cId})
   EndIf

   nRet := FWrite(hFile, cBuffer, nLen)

End Sequence

Return nRet

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 27/01/07 - 17:44
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina  := {{STR0002, "AXPESQUI", 0, 1},;//"Pesquisar"
                   {STR0003, "SI400MAN", 0, 2},;//"Visualizar"
                   {STR0059, "SI400MAN", 0, 4},;//"Preparar"
                   {STR0004, "SI400MAN", 0, 4},;//"Gerar"
                   {STR0005, "SI400MAN", 0, 4},;//"Retornar"
                   {STR0092, "SI400MAN", 0, 4}} //"Estornar"
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

//WFS 19/06/09 ---
If EasyGParam("MV_AVG0181",, .F.) .And. cOrigem == "EECSI400"
   AAdd(aRotina, {STR0124, "EECSI401", 0, 4}) //Retornar via R.E.
EndIf
AAdd(aRotina, {STR0125, "SI400Leg", 0, 2}) //Legenda
//---

If EasyEntryPoint("EECSI400")
   ExecBlock("EECSI400", .F., .F.,{"AROTINA"})
EndIf

If cOrigem $ "EECSI40A"
   If EasyEntryPoint("ESI40AMNU")
	  aRotAdic := ExecBlock("ESI40AMNU",.f.,.f.)
   EndIf
Else
   If EasyEntryPoint("ESI400MNU")
      aRotAdic := ExecBlock("ESI400MNU",.f.,.f.)
   EndIf
EndIf


If ValType(aRotAdic) == "A"
   aEval(aRotAdic,{|x| AAdd(aRotina,x)})
EndIf


Return aRotina

/*
Funcao      : SI400VerMercoSul(cPais)
Parametros  : cPais  - Código do País
Retorno     : .T./.F.
Objetivos   : Verificar se o País informado pertence ou não ao mercosul
Autor       : Julio de Paula Paz
Data/Hora   : 21/03/2007 - 09:50
Revisao     :
Obs.        :
*/
Static Function SI400VerMercoSul(cPais)
Local lRet := .F., aOrd := SaveOrd("SYA")
Begin Sequence
   cPais := AvKey(cPais,"EEC_PAISDT")
   SYA->(DbSetOrder(1))
   SYA->(DbSeek(xFilial("SYA")+cPais))
   IF SYA->YA_MERCOSU $ cSim
      lRet := .T.
   Endif
End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Funcao     : SI400Leg()
Parametros :
Retorno    :
Objetivos  :
Autor      : Wilsimar Fabricio da Silva
Data/Hora  : Jun/2009
*/

Function SI400Leg()
Local aLegenda:= {}

   AAdd(aLegenda, {"BR_VERDE"   , STR0126}) //Aguardando preparação
   AAdd(aLegenda, {"BR_AMARELO" , STR0127}) //Aguardando geração
   AAdd(aLegenda, {"BR_LARANJA" , STR0132}) //Arquivos gerados
   AAdd(aLegenda, {"BR_VERMELHO", STR0128}) //Aguardando retorno
   AAdd(aLegenda, {"BR_AZUL"    , STR0129}) //Concluido

   BrwLegenda(cCadastro, STR0125, aLegenda) //Legenda

Return

/*
Funcao     : Si400File()
Parametros : cFile - Diretorio c:\p11\protheus_data
Retorno    : aRet
Objetivos  : Retornar um vetor com os nome dos arquivos
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 12/12/2013
*/
Function Si400File(cFile)
Local aRet := {}
Local nPos

   If (nPos := aScan(aFilesDir, {|x| x[1] == cFile })) > 0
      aRet := aClone(aFilesDir[nPos])
   EndIf

Return aRet

/*
Funcao     : Si400TelaGets()
Parametros : cServico - "DE"
Retorno    : lRet
Objetivos  : Retorna .T. ou .F. para efetivar a transação entre as tabelas EWJ, EEX, EEZ
Autor      : Laercio G S Junior
Data/Hora  : 11/06/2015
*/
*----------------------------------------*
Function Si400TelaGets(cServico)
*----------------------------------------*
Local oDlg, oBrowse
Local aCampos	:= {}
Local aSemSx3	:= {}
Local nBotao
Local bOk		:={|| If(WorkLote->(EasyReccount("WorkLote")) == 0,(oDlg:End(),nBotao:=5),;
                    If(MsgYesNo("Confirma Gravacao do Lote de integração DDE?"),(oDlg:End(),nBotao:=5),)) }
Local bCancel	:={|| If(WorkLote->(EasyReccount("WorkLote")) == 0,(oDlg:End(),nBotao:=0),;
                    If(MsgYesNo("Tem certeza que deseja excluir este lote de integração DDE?"),(oDlg:End(),nBotao:=0),)) }
Local lRet		:= .T.
Private cMrcProc:=GetMark()
Private aBotoes :={}
Private oMark2
Private nSequenDDE := 1 //LGS - 02/03/2016 - Sequenciador do lote DDE-Web

Begin Sequence

	AADD(aSemSX3,{"WK_PREEMB" ,AvSx3("EEC_PREEMB", AV_TIPO),AvSx3("EEC_PREEMB", AV_TAMANHO),AvSx3("EEC_PREEMB", AV_DECIMAL)})
	AADD(aSemSX3,{"WK_DTPROC" ,AvSx3("EEC_DTPROC", AV_TIPO),AvSx3("EEC_DTPROC", AV_TAMANHO),AvSx3("EEC_DTPROC", AV_DECIMAL)})
	AADD(aSemSX3,{"WK_LIBSIS" ,AvSx3("EEC_LIBSIS", AV_TIPO),AvSx3("EEC_LIBSIS", AV_TAMANHO),AvSx3("EEC_LIBSIS", AV_DECIMAL)})
	AADD(aSemSX3,{"WK_LOTE"   ,AvSx3("EWJ_ID"    , AV_TIPO),AvSx3("EWJ_ID"    , AV_TAMANHO),AvSx3("EWJ_ID"    , AV_DECIMAL)})
	AADD(aSemSX3,{"WKRECNO"   ,"N",15,0})
	aAdd(aSemSX3,{"DBDELETE"  ,"L",1 ,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
    cFileItens:=E_CriaTrab(,aSemSX3,"WorkLote")
	IndRegua("WorkLote",cFileItens+TEOrdBagExt(),"WK_PREEMB+WK_LOTE")

	AADD(aCampos,{"WK_PREEMB",,AVSX3("EEC_PREEMB",5),AVSX3("EEC_PREEMB",6)})
	AADD(aCampos,{"WK_DTPROC",,AVSX3("EEC_DTPROC",5),AVSX3("EEC_DTPROC",6)})
	AADD(aCampos,{"WK_LIBSIS",,AVSX3("EEC_LIBSIS",5),AVSX3("EEC_LIBSIS",6)})

	AADD(aBotoes,{"INCLUIR"    ,{|| Si400PesqEmb() },"Inclusao de Declaração" ,"Incluir"})
	AADD(aBotoes,{"EXCLUIR"    ,{|| Si400DelDDE()  },"Exclusao de Declaração" ,"Excluir"})


	DEFINE MSDIALOG oDlg TITLE "Declaração de Despacho de Exportação - WEB" ;
	FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL

	oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 280, 30)

	@010,015 SAY AVSX3("EWJ_LOTE",5) SIZE 20,8 OF oPanel PIXEL//"Lote "
	@010,030 MSGET cServico VAR EWJ->EWJ_ID WHEN .F. SIZE 65,8 RIGHT OF oPanel PIXEL

	nLinha:=5
	WorkLote->(DBGOTOP())
	oMark2:= MsSelect():New("WorkLote",,"",aCampos,.F.,@cMrcProc,{nLinha,01,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2},,,oDlg)
	oPanel:Align      := CONTROL_ALIGN_TOP
	oMark2:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
	oDlg:lMaximized   := .T.

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aBotoes))

	If nBotao == 0
	   If WorkLote->(EasyReccount("WorkLote")) == 0
	      lRet := .F.
	   Else
	      Si400DelDDE(.T.)
	      lRet := .F.
	   EndIf
	ElseIf (nBotao == 5 .And. WorkLote->(EasyReccount("WorkLote")) == 0) .Or. nBotao == NIL
	   lRet := .F.
	EndIf


End Sequence
WorkLote->((E_EraseArq(cFileItens)))

Return lRet

/*
Funcao     : Si400PesqEmb()
Objetivos  : Posicionar na EEC e chamar a função SI400MAN() para gravar a DDE
Autor      : Laercio G S Junior
Data/Hora  : 11/06/2015
*/
*----------------------------------------*
Function Si400PesqEmb()
*----------------------------------------*
Local oDlg, cPedido := Space(AVSX3("EEC_PREEMB",AV_TAMANHO))
Local bValid := {|| NaoVazio(cPedido).And.ExistEmbarq(cPedido)}
Local nOpcA  := 0
Local bOk    := {||nOpcA:=1,If(Eval(bValid),oDlg:End(),nOpcA:=0)}
Local aOrd   := SaveOrd({"EEC","EEX"})
Local aOrdEWJ:= SaveOrd({"EWJ"})

Begin Sequence

	If WorkLote->( EasyReccount("WorkLote")) == 100
	   MsgInfo("Para a geração da DDE-WEB o numero maximo de processo que podem compor um lote é 100","Atenção")
	   Break
	EndIf

	DEFINE MSDIALOG oDlg TITLE "Seleção de "+AVSX3("EEC_PREEMB",AV_TITULO) From 9,0 To 18,45 OF oMainWnd

		oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 9, 18)
		oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

		@ 010,015 SAY AVSX3("EEC_PREEMB",AV_TITULO)+" <F3>" OF oPanel PIXEL
		@ 020,015 MSGET cPedido F3 "EEC" SIZE 80,8 VALID Eval(bValid) PICTURE AVSX3("EEC_PREEMB",AV_PICTURE) OF oPanel PIXEL

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,{||oDlg:End()}) CENTERED

		IF nOpcA == 0
		   Break

		Else
		   EEC->(DbSetOrder(1))
		   EEX->(DbSetOrder(1))
		   EEC->(DbSeek(xFilial("EEC")+cPedido))

		   If GeraMsg()
		      Break
		   EndIf

		   If EEX->(DbSeek(xFilial("EEX") + EEC->EEC_PREEMB))
		      EWJ->(DbSetOrder(1))
		      EWJ->(DbSeek(xFilial("EWJ") + EEX->EEX_ID))
		      If EWJ->EWJ_SERVIC = 'DE' .And. (EWJ->EWJ_STATUS == NAO_ENVIADO .Or. EWJ->EWJ_STATUS == ENVIADO)
		         MsgInfo("O processo selecionado " + Alltrim(cValToChar(cPedido)) + " ja está vinculado ao lote DDE-WEB " +;
		                 Alltrim(cValToChar(EWJ->EWJ_ID)) + "." + ENTER +;
		                 "É necessario que o lote esteja cancelado para que possa utilizar novamente este processo.","Atencao")
		         Break
		      EndIf
		   EndIf
		   RestOrd(aOrdEWJ,.T.)

		   If !EEX->(DbSeek(xFilial("EEX") + EEC->EEC_PREEMB + EWJ->EWJ_ID))

		      SI400MAN("EEC",EEC->(RECNO()),3,,.T.)

		      If EEX->(DbSeek(xFilial("EEX") + EEC->EEC_PREEMB + EWJ->EWJ_ID))
		         WorkLote->(DBAPPEND())
		         WorkLote->WK_PREEMB := EEX->EEX_PREEMB
		         WorkLote->WK_DTPROC := EEC->EEC_DTPROC
		         WorkLote->WK_LIBSIS := EEC->EEC_LIBSIS
		         WorkLote->WK_LOTE   := EEX->EEX_ID
		         WorkLote->WKRECNO   := EEX->(RECNO())
		      EndIf
		   Else
		      MsgInfo("O processo numero " + AllTrim(cValToChar(EEC->EEC_PREEMB)) + " já está selecionado para este lote de integração DDE","Aviso")
		   EndIf

		   WorkLote->(DbGoTop())
		   If oMark2 # NIL
		      oMark2:oBrowse:Refresh()
		   EndIf
		EndIf

End Sequence

RestOrd(aOrd,.T.)
Return Nil

/*
Funcao     : Si400DelDDE()
Parametros : lAuto
Objetivos  : Excluir os registros das tabelas EWJ, EEX, EEZ qdo um lote em edição for cancelado sem que confirme a gravação.
Autor      : Laercio G S Junior
Data/Hora  : 11/06/2015
*/
*----------------------------------------*
Function Si400DelDDE(lAuto)
*----------------------------------------*
Local lDelEEX  := lDelEEZ := lDelEWY := lDelWrk := lDelProc := .F.
Local aProcDDE := {}
Local i
Default lAuto  := .F.

Begin Sequence

   If lAuto
      Do While WorkLote->(!Eof())
         AAdd(aProcDDE,{WorkLote->WK_PREEMB,WorkLote->WK_LOTE})
         WorkLote->(DbSkip())
      EndDo
   Else
      If WorkLote->(EasyReccount("WorkLote")) == 0
         MsgInfo("Lote de integração de DDE, não possui processos.","Atenção")
         Break
      Else
         lDelProc := MsgYesNo("Tem certeza que deseja exluir o(s) processo(s) selecionado(s) deste lote de integração de DDE?","Atenção")
         If lDelProc
            AAdd(aProcDDE,{WorkLote->WK_PREEMB,WorkLote->WK_LOTE})
         Else
            Break
         EndIf
      EndIf
   EndIf

   If !Empty(aProcDDE)
      EEC->(DbSetOrder(1))
      EEX->(DbSetOrder(1))
      EEZ->(DbSetOrder(2))
      EEX->( MsUnlock() )
      EEZ->( MsUnlock() )

      For i:=1 To Len(aProcDDE)

         EEC->(DbSeek(xFilial("EEC")+AvKey(aProcDDE[i][1],"EEC_PREEMB")))
         lDelEEX := EEX->(DbSeek(xFilial("EEX")+AvKey(aProcDDE[i][1],"EEX_PREEMB")+AvKey(aProcDDE[i][2],"EEX_ID")))
         lDelEEZ := EEZ->(DbSeek(xFilial("EEZ")+AvKey(aProcDDE[i][1],"EEZ_PREEMB")+AvKey(aProcDDE[i][2],"EEZ_ID")))
         lDelEWY := EWY->(DbSeek(xFilial("EWJ")+AvKey(aProcDDE[i][2],"EWY_ID")+AvKey(aProcDDE[i][1],"EWY_PREEMB")))
         lDelWrk := WorkLote->(DbSeek(AvKey(aProcDDE[i][1],"EEC_PREEMB")+AvKey(aProcDDE[i][2],"EWJ_ID")))

         If lDelWrk
            WorkLote->(RecLock("WorkLote",.F.))
            WorkLote->DBDELETE := .T.
            WorkLote->(dbDelete())
            WorkLote->(__dbPack())
            WorkLote->(MsUnlock())
         EndIf
         If lDelEEX
            RecLock("EEX", .F.)
            EEX->(dbDelete())
            EEX->(MsUnlock())
         EndIf
         If lDelEEZ
            Do While EEZ->(!Eof()) .And. EEZ->EEZ_PREEMB == AvKey(aProcDDE[i][1],"EEZ_PREEMB");
                                   .And. EEZ->EEZ_ID == AvKey(aProcDDE[i][2],"EEZ_ID")
               RecLock("EEZ", .F.)
               EEZ->(dbDelete())
               EEZ->(MsUnlock())
               EEZ->(DbSkip())
            EndDo
         EndIf
         If lDelEWY
            Do While EWY->(!Eof()) .And. EWY->EWY_PREEMB == AvKey(aProcDDE[i][1],"EWY_PREEMB");
                                   .And. EWY->EWY_ID == AvKey(aProcDDE[i][2],"EWY_ID")
               RecLock("EWY", .F.)
               EWY->(dbDelete())
               EWY->(MsUnlock())
               EWY->(DbSkip())
            EndDo
         EndIf
      Next
      If !lAuto
         WorkLote->(DbGoTop())
         If oMark2 # NIL
            oMark2:oBrowse:Refresh()
         EndIF
      EndIf
   EndIf

End Sequence
Return Nil

/*
Funcao     : Si400Cargas()
Objetivos  : Utilizado na GerNewRE para gerar o xml de lote DE-WEB
Autor      : Laercio G S Junior
Data/Hora  : 19/06/2015
*/
*----------------------------------------*
Function Si400Cargas()
*----------------------------------------*
Local aCarga := {}
Local i, cEspecie, aOrdSX3 := SaveOrd({"SX3"})

SX3->(DbSetOrder(2))
SX3->(dbSeek("EEX_ESP"))
Do While SX3->(!Eof() .and. Left(SX3->X3_CAMPO, 7) = "EEX_ESP")
   cEspecie := SubStr(AllTrim(SX3->X3_CAMPO), 8)
   aAdd( aCarga, {	"EEX_ESP"+cEspecie , "EEX_EMB"+cEspecie, "EEX_QTD"+cEspecie,;
						"EEX_MARK"+cEspecie, "EEX_PESB"+cEspecie, SX3->X3_ORDEM } )
   SX3->(DbSkip())
EndDo
aSort(aCarga,,, {|x, y| x[6] < y[6]})
RestOrd(aOrdSX3,.T.)

	WCarga1->(avzap())
	For i:=1 To Len(aCarga)
	  If !Empty(EEX->&(aCarga[i][1])) .And. (EEX->&(aCarga[i][1]) == "37" .And. EEX->&(aCarga[i][3]) <> "0")
	     EE5->(DbSeek(xFilial("EE5")+EEX->&(aCarga[i][2]) ))
	     WCarga1->(DBAPPEND())
	     WCarga1->WKESP  := EEX->&(aCarga[i][1])
	     WCarga1->WKEMB  := Alltrim(SubStr(EE5->EE5_SISESP,1,2))
	     WCarga1->WKQTD  := Alltrim(EEX->&(aCarga[i][3]))
	     WCarga1->WKMARK := Alltrim(SubStr(EEX->&(aCarga[i][4]),1,50))
	     WCarga1->WKPESB := EEX->&(aCarga[i][5])
	     WCarga1->WKRECNO  := Recno()
	  EndIf
	Next

	WCarga2->(avzap())
	For i:=1 To Len(aCarga)
	  If !Empty(EEX->&(aCarga[i][1])) .And. (EEX->&(aCarga[i][1]) <> "37" .And. EEX->&(aCarga[i][3]) <> "0")
	     EE5->(DbSeek(xFilial("EE5")+EEX->&(aCarga[i][2]) ))
	     WCarga2->(DBAPPEND())
	     WCarga2->WKESP  := EEX->&(aCarga[i][1])
	     WCarga2->WKEMB  := Alltrim(SubStr(EE5->EE5_SISESP,1,2))
	     WCarga2->WKQTD  := Alltrim(EEX->&(aCarga[i][3]))
	     WCarga2->WKMARK := Alltrim(SubStr(EEX->&(aCarga[i][4]),1,50))
	     WCarga2->WKPESB := EEX->&(aCarga[i][5])
	     WCarga2->WKRECNO  := Recno()
	  EndIf
	Next

	WCarga1->(DbGoTop())
	WCarga2->(DbGoTop())

Return Nil

/*
Funcao     : GeraMsg()
Objetivos  : Utilizado na GerNewRE para gerar o xml de lote DE-WEB
Autor      : Laercio G S Junior
Data/Hora  : 19/06/2015
*/
*----------------------------------------*
Static Function GeraMsg()
*----------------------------------------*
Local cMsg := "O processo de embarque possui campos que precisam ser preenchidos:" + ENTER
Local lMsg := .F.

	If Empty(EEC->EEC_URFDSP)
		lMsg := .T.
		cMsg += ENTER
		cMsg += "O campo " + cValToChar(AvSX3("EEC_URFDSP",5)) + " (EEC_URFDSP)" + ENTER + "deve ter seu conteudo preenchido no embarque."+ ENTER
	EndIf
	If Empty(EEC->EEC_URFENT)
		lMsg := .T.
		cMsg += ENTER
		cMsg += "O campo " + cValToChar(AvSX3("EEC_URFENT",5)) + " (EEC_URFENT)" + ENTER + "deve ter seu conteudo preenchido no embarque."+ ENTER
	EndIf
	If Empty(EEC->EEC_VIA)
		lMsg := .T.
		cMsg += ENTER
		cMsg += "O campo " + cValToChar(AvSX3("EEC_VIA",5)) + " (EEC_VIA)" + ENTER + "deve ter seu conteudo preenchido no embarque." + ENTER
	EndIf
	cMarcac := MSMM(EEC->EEC_CODMAR,AVSX3("EEC_MARCAC",AV_TAMANHO))
	cMarcac := ALLTRIM(STRTRAN(cMarcac,CHR(10),' '))
	If Empty(cMarcac)
	    lMsg := .T.
		cMsg += ENTER
		cMsg += "O campo " + cValToChar(AvSX3("EEC_MARCAC",5)) + " (EEC_MARCAC)" + ENTER + "deve ter seu conteudo preenchido no embarque." + ENTER
	EndIf

	If lMsg
		EECView(cMsg)
	EndIf

Return lMsg

/*
Funcao     : SI400GeraBox()
Objetivos  : Utilizado para montar os combobox utilizados na geração da DDE
Autor      : Laercio G S Junior
Data/Hora  : 02/07/2015
*/
*----------------------------------------*
Function SI400GeraBox(cCampo,cLang)
*----------------------------------------*
Local cBuffer  := cTabela := cX5CHAVE := "", i
Local aCombo   :={}
Default cCampo := ""
Default cLang  := "P"

Do Case
   Case cCampo == "EEX_TIPOPX"
        cTabela:= "E4" //E4 - Tipo de Operação de Exportação
   Case cCampo == "EEX_DETOPX"
        cTabela:= "E5" //E5 - Detalhamento da Operação de Exportação
   Case cCampo == "EEX_SDETOP"
        cTabela:= "E6" //E6 - Subdetalhamento da Operação de Exportação
   Case cCampo == "EEX_ODLTIP"
        cTabela:= "E8" //E8 - Tipo de Documentos Instrutivos
EndCase

Do Case
   Case cLang == "P" //PORTUGUES
        cX5CHAVE := "X5_DESCRI"
   Case cLang == "S" //ESPANHOL
        cX5CHAVE := "X5_DESCSPA"
   Case cLang == "E" //INGLES
        cX5CHAVE := "X5_DESCENG"
EndCase

If SX5->(DbSeek(xFilial('SX5')+cTabela))
   Do While SX5->(!Eof()) .And. SX5->X5_TABELA == cTabela
      aAdd(aCombo,{SX5->X5_CHAVE, SX5->&(cX5CHAVE), Val(SX5->X5_CHAVE)})
      SX5->(DbSkip())
   EndDo

   aSort(aCombo,,, {|x, y| x[3] < y[3]})

   For i:=1 To Len(aCombo)
       cBuffer += cValToChar( Alltrim(aCombo[i][1])+"="+aCombo[i][2]+";" )
   Next
EndIf

Return cBuffer

/*
Funcao     : SI400GeraBox()
Objetivos  : Utilizado para montar os combobox utilizados na geração da DDE
Autor      : Laercio G S Junior
Data/Hora  : 02/07/2015
*/
Function SI400DETF3()
Local cArqTemp, nRadOpc := 1, lOK :=.F., lMsgAviso := .T.
Local aSemSX3 := {}, TB_Campos :={}
Local bOK  :={|| lOK := .T., oDlg:End() }, bSetF3 := SetKey(VK_F3), OldWork := SELECT(), oDlg
Local bRadio := {|x| If(PCount() > 0, nRadOpc:= x, nRadOpc)}
Private aCampos := {}

Begin Sequence
    AAdd(aSemSX3, {"WKVIAGEM", AVSX3("EEC_VIAGEM",AV_TIPO),AVSX3("EEC_VIAGEM",AV_TAMANHO),AVSX3("EEC_VIAGEM",AV_DECIMAL) })
    AAdd(aSemSX3, {"WKCTRC"  , AVSX3("EEC_NRCONH",AV_TIPO),AVSX3("EEC_NRCONH",AV_TAMANHO),AVSX3("EEC_NRCONH",AV_DECIMAL) })
    cArqTemp:= E_CriaTrab(,aSEMSX3,"WorkNV")

    WorkNV->(DbAppend())
    WorkNV->WKVIAGEM := EEC->EEC_VIAGEM
    WorkNV->WKCTRC   := EEC->EEC_NRCONH
    WorkNV->(DbGoTop())

    AADD(Tb_Campos,{ {||WorkNV->WKVIAGEM},,STR0133 } )//"Navio/Viagem"
    AADD(Tb_Campos,{ {||WorkNV->WKCTRC}  ,,STR0134 } )//"Nr.Conh.Transp"

    If (!Empty(WorkNV->WKVIAGEM) .And. !Empty(WorkNV->WKCTRC))
       lWhen := .T.
    Else
       If !Empty(WorkNV->WKVIAGEM)
          nRadOpc := 1 //"Navio/Viagem"
       Else
          nRadOpc := 2 //"Nr.Conh.Transp"
       EndIf
       lWhen := .F.
    EndIf

    DEFINE MSDIALOG oDlg TITLE STR0135 FROM 62,15 TO 285,382 OF oMainWnd PIXEL //"Informações Navio/Viagem - Conhecimento de Transporte"

       @ 005, 005 GROUP oGroup1 TO 040, 182 PROMPT STR0136 OF oDlg COLOR 0, 16777215 PIXEL
       TRadMenu():New(15, 08, {STR0133,STR0137}, bRadio, oDlg,,,,,,,{|| lWhen }, 127, 24,,,, .T.)

       oMark:= MsSelect():New("WorkNV",,,TB_Campos,.F.,@cMarca,{45,05,90,182})
       oMark:bAval:=bOk

       DEFINE SBUTTON FROM 095,05 TYPE 1  ACTION (Eval(oMark:baval)) ENABLE OF oDlg PIXEL
       DEFINE SBUTTON FROM 095,40 TYPE 2  ACTION (oDlg:End()) ENABLE OF oDlg PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

    If lOK
       M->EEX_ODLIDT := If(nRadOpc==1, WorkNV->WKVIAGEM, WorkNV->WKCTRC)
       TMZ->(DbGoTop())
       Do While TMZ->(!Eof())
          If !TMZ->DBDELETE
             lMsgAviso := .F.
             Exit
          EndIf
          TMZ->(DbSkip())
       EndDo
       If lMsgAviso
          MsgInfo(STR0138,STR0011)
       EndIf
    EndIf

    WorkNV->(E_EraseArq(cArqTemp))
End Sequence

SetKey(VK_F3,bSetF3)
DbSelectArea(OldWork)

RETURN lOK
