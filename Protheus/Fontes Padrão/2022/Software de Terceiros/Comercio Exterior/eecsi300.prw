/*
Programa..: EECSI300.PRW
Objetivo..: Geracao de RV
Autor.....: Luciano Campos de Santana
Data/Hora.: 12/06/2002 - 13:43
Obs.......:                 
STATUS DA RV NO EE8: " " - NAO TEM RV PREPARADA
                     "P" - TEM RV PREPARADA
                     "E" - ERRO NO RETORNO DA RV
                     "R" - ESTA COM NUMERO DA RV
                     "G" - GERADO.
*/
#INCLUDE "eecsi300.ch"
#INCLUDE "EEC.cH"
#include "DBTREE.ch"

#DEFINE BLOCK_READ 1024    // Blocos de leitura
#DEFINE FO_READ       0    // Open for reading (default)
#DEFINE FO_EXCLUSIVE 16    // Exclusive use (other processes have no access)

*--------------------------------------------------------------------
FUNCTION EECSI300()
LOCAL aORD := SAVEORD({"EE7","EEY","SA2","SYD","EEF","SY9","SJ0","SYR","SYA","SAH","EE9"}),;
      oDLG,bOK,bCANCEL,aBUTTONS,nBTOP,cTON,cLBS,cFILEXT
PRIVATE cCADASTRO,cPATHOR,cPATHDT,aROTINA,cUNIDTON,cUNIDLBS
Private aAuxRotina //JPM
EEY->(DbSetOrder(1))
*
cUNIDTON  := ALLTRIM(EasyGParam("MV_AVG0030"))
cUNIDTON  := PADR(IF(cUNIDTON=".","",cUNIDTON),2," ")
cUNIDLBS  := ALLTRIM(EasyGParam("MV_AVG0032"))
cUNIDLBS  := PADR(IF(cUNIDLBS=".","",cUNIDLBS),2," ")
cCADASTRO := STR0001 //"Geração de RV"
cPATHOR   := ALLTRIM(EasyGParam("MV_AVG0002"))  // Path para gravacao dos txt
cPATHDT   := ALLTRIM(EasyGParam("MV_AVG0003"))  // Path de Retorno do txt 
//aAuxRotina := {1 ,; //Pesquisar
//               2 }   //Visualizar

Private lNewRv := EECFlags("NEW_RV")
Private lRv11  := EasyGParam("MV_AVG0103",,.F.) // JPM - 16/11/05 - Define se será o tratamento de R.V. 1 para 1 (.T.) ou não (.F. - R.V. Desvinculada)
Private lSI300 := .t. // para saber se a fixação de preço é chamada do SI300
Private aMemoItem :={{"EE8_DESC","EE8_VM_DES"}}

Private cFilBr, cFilEx
Private lIntermed  := EECFlags("INTERMED")
Private lCommodity := EECFlags("COMMODITY")

//THTS - 14/07/2017 - Funcao nopada, pois foram retiradas funcoes que manipulam dicionarios dos fontes.
//SI301Titulo()

If lNewRv
   Private aArqs := ap102setworks()// by CAF 23/11/2005
EndIf

aAuxRotina := {}
aROTINA   := MenuDef()

*
BEGIN SEQUENCE
   cFILEXT := ALLTRIM(EasyGParam("MV_AVG0024",,""))   
   cFILEXT := IF(cFILEXT=".","",cFILEXT)
   
   If !Empty(EasyGParam("MV_AVG0023",,"")) .And. !Empty(cFILEXT) .And.;
      (EE7->(FieldPos("EE7_INTERM")) # 0) .And. (EE7->(FieldPos("EE7_COND2")) # 0) .And.;
      (EE7->(FieldPos("EE7_DIAS2")) # 0) .And. (EE7->(FieldPos("EE7_INCO2")) # 0) .And.;
      (EE7->(FieldPos("EE7_PERC")) # 0) .And. (EE8->(FieldPos("EE8_PRENEG")) # 0) .AND.;
      cFILEXT = XFILIAL("EEC")
      *
      MSGINFO("Filial do Exterior não pode gerar dados para o SISCOMEX !","Atenção")
      BREAK
   ENDIF
   
   // VERIFICA A EXISTENCIA DO CAMPO, CASO NAO EXISTA TEM QUE INCLUIR NO SDU
   IF EEY->(FIELDPOS("EEY_PREMI1")) = 0
      MSGINFO(STR0084+ENTER+;  //"Campo 'Valor Premio 1' não existe na base."
              STR0085+ENTER+;  //"Crie o campo EEY_PREMI1 com as mesmas características do EEY_PREMI2, "
              STR0086+ENTER+;  //"alterando a Ordem para 12, Nome para EEY_PREMI1, Titulo para Premio 1,"
              STR0087+ENTER+;  //"Descrição para Valor do Premio 1, Valid para SI300V('EEY_PREMI1') e o"
              STR0088,STR0012) //"When para SI300W('EEY_PREMI1') ou entre em contato com o suporte da AVERAGE."###"Atenção"
      BREAK
   ENDIF
   
   // VERIFICA SE AS VARIAVEIS DE CONVERSAO ESTAO CONFIGURADAS
   IF EMPTY(cUNIDTON) .OR. EMPTY(cUNIDLBS)
      bOK      := {|| nBTOP := 1,IF(SI300V("cUNIDTON",cTON).AND.SI300V("cUNIDLBS",cLBS),oDLG:END(),nBTOP := 0)}
      bCANCEL  := {|| nBTOP := 0,oDLG:END()}
      aBUTTONS := {}
      nBTOP    := 0
      cTON     := cUNIDTON
      cLBS     := cUNIDLBS
      
      DEFINE MSDIALOG oDLG TITLE STR0068 FROM 00,00 TO 180,390 OF oMainWnd PIXEL //"Parametros" 102,270  //FSM - 10/08/2011
         
         oPanel:= TPanel():New(0, 0, "", oDLG,, .F., .F.,,, 90, 165) //MCF - 11/09/2015
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
         
         @ 15,05 SAY STR0069 PIXEL OF oPanel //"Configure os codigos para conversao de unidades:"
         @ 28,05 SAY STR0070 PIXEL OF oPanel //"Tonelada"
         @ 26,40 MSGET cTON PICTURE "@!" SIZE 15,08 PIXEL OF oPanel F3("SAH") VALID(SI300V("cUNIDTON",cTON))
         *
         @ 40,05 SAY STR0071 PIXEL OF oPanel //"Libra"
         @ 38,40 MSGET cLBS PICTURE "@!" SIZE 15,08 PIXEL OF oPanel F3("SAH") VALID(SI300V("cUNIDLBS",cLBS))
      
      ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS) CENTERED
      IF nBTOP = 1
         cUNIDTON := cTON
         cUNIDLBS := cLBS
         SETMV("MV_AVG0030",cUNIDTON)
         SETMV("MV_AVG0032",cUNIDLBS)
      ENDIF
   ENDIF

   // VERIFICANDO A EXISTENCIA DOS DIRETORIOS DO SISCOMEX
   cPATHOR := cPATHOR+IF(RIGHT(cPATHOR,1)="\","","\")
   cPATHDT := cPATHDT+IF(RIGHT(cPATHDT,1)="\","","\")
   IF ! LISDIR(LEFT(cPATHOR,LEN(cPATHOR)-1))
      MSGINFO(STR0007+cPATHOR+STR0008,STR0009) //"Diretorio para gravacao do txt não existe ("###") !"###"Aviso"
      BREAK
   ELSEIF ! LISDIR(LEFT(cPATHDT,LEN(cPATHDT)-1))
          MAKEDIR(cPATHDT)
   ENDIF      
   
   If lNewRv // JPM - 17/11/05 - Com os novos tratamentos de R.V., o R.V. é mostrado, e não os pedidos
      DBSELECTAREA("EEY")
      EEY->(DBSETORDER(1))
      MBROWSE(06,01,22,75,"EEY")
   Else
      DBSELECTAREA("EE7")
      EE7->(DBSETORDER(1))
      MBROWSE(06,01,22,75,"EE7")
   EndIf
   
END SEQUENCE

If lNewRv
   ap102delworks(aArqs) // by CAF 23/11/2005
EndIf

RESTORD(aORD)
RETURN(NIL)
*--------------------------------------------------------------------
FUNCTION SI300MAN(cP_ALIAS,nP_REG,nP_OPC)

LOCAL Z,aPOS,aENCHOICE,bOK,nBTOP,bCANCEL,cWORKEE8,aSEMSX3,aCAMPOTMP,oDLG,oGET,;
      cMESANOFIX
Local lTemEEY := .F.
Local nCursor := 0, lLastRec := .f.
Local aOrd := SaveOrd({"EEY","EE7"})

PRIVATE aBUTTONS,lALTERA,lINVERTE,cMARCA,aCAMPOS,aHEADER,cNCMRV,nMARCADOS,;
        nSEQEE8,nVALFOB, nOpc := nP_OPC

Private lCBRVItem := .F.

//JPM 
Private lRvPed11  := (Left(EEY->EEY_PEDIDO,1) <> "*")

*
BEGIN SEQUENCE
   nBTOP      := nMARCADOS := nVALFOB := 0
   nSEQEE8    := ""
   lALTERA    := .T.
   lINVERTE   := .F.
   cNCMRV     := SPACE(12)
   cMESANOFIX := SPACE(06)
   cMARCA     := GETMARK()
   aCAMPOS    := ARRAY(EE8->(FCOUNT()))
   aHEADER    := {}
   aCAMPOTMP  := { {"TMP_FLAG", "", "  "},;
                   COLBRW("EE8_POSIPI", "TMP"),;
                   COLBRW("EE8_DTQNCM", "TMP"),;
                   COLBRW("EE8_TPONCM", "TMP"),;
                   COLBRW("EE8_COD_I",  "TMP"),;
                   {"TMP_DESC", "", AvSX3("EE8_VM_DES",AV_TITULO)},;
                   COLBRW("EE8_UNIDAD", "TMP"),;
                   COLBRW("EE8_SLDINI", "TMP"),;
                   {{||Transf(TMP->EE8_PRECO, EECPreco("EE8_PRECO", AV_PICTURE))}, "", AvSX3("EE8_PRECO",AV_TITULO)},;
                   {{||Transf(TMP->EE8_PRCINC, EECPreco("EE8_PRCINC", AV_PICTURE))}, "", AvSX3("EE8_PRCINC",AV_TITULO)},;
                   COLBRW("EE8_DTPREM", "TMP"),;
                   COLBRW("EE8_DTENTR", "TMP"),;
                   COLBRW("EE8_PSLQTO", "TMP"),;
                   COLBRW("EE8_PSBRTO", "TMP") }
                  //COLBRW("EE8_PRECO" , "TMP"),;
                  //COLBRW("EE8_PRCINC", "TMP"),;

   aBUTTONS   := {}
   bOK        := {|| nBTOP := 1,IF(SI300V("BOK"),oDLG:END(),nBTOP := 0)}
   bCANCEL    := {|| nBTOP := 0,oDLG:END()}
   aSEMSX3    := {{"TMP_FLAG" ,"C",02,0},;
                  {"TMP_RECNO","N",07,0},;
                  {"TMP_DESC" ,"C",AVSX3("EE8_VM_DES",AV_TAMANHO),0}}
   aENCHOICE  := {"EEY_PEDIDO","EEY_CGCCPF","EEY_NCM"   ,"EEY_DTQNCM","EEY_TPONCM"  ,;
                  "EEY_DMERC1","EEY_DMERC2","EEY_IMPORT","EEY_DTVEND","EEY_CONDPA",;
                  "EEY_PREMI1","EEY_PREMI2","EEY_COMAGP","EEY_COMAGV","EEY_POREMB",;
                  "EEY_PAISDE","EEY_PEEMBI","EEY_PEEMBF","EEY_PECOTI","EEY_PECOTF",;
                  "EEY_MESFIX","EEY_ANOFIX","EEY_IMPEXP","EEY_PESLIQ","EEY_PESBRU",;
                  "EEY_PRCUNI","EEY_RATPRC","EEY_PERIMP","EEY_PEREXP","EEY_DTPEDI",;
                  "EEY_DTQNCM","EEY_TPONCM"}
   *
   
   If lNewRv // JPM
      If !SI301Valid("INICIO")// validações iniciais
         Break
      EndIf
      If Type("lPreparaRv") <> "L" .And. aAuxRotina[nP_OPC] <> 4 // se não for preparar
         EE7->(DbSetOrder(1))
         EE7->(DbSeek(xFilial()+EEY->EEY_PEDIDO)) //Posiciona no pedido correto.
      EndIf
   EndIf
   
   IF EE7->EE7_STATUS = ST_PC
      MSGINFO(STR0010,STR0009) //"Processo de exportação cancelado"###"Aviso"
      BREAK
   EndIf
   
//   If nP_OPC = 2 // VISUALIZA
   If aAuxRotina[nP_OPC] = 2
   
      EEY->(dbSetOrder(2))
      lTemEEY := EEY->(dbSeek(xFilial("EEY")+EE7->EE7_PEDIDO))
      IF ! lTemEEY
         MSGINFO(STR0011,STR0012) //"Processo nao possui RV. Gere o RV primeiro !"###"Atenção"
         BREAK
      ENDIF
      lALTERA := .F.
      SI300VIES(nP_OPC)
      BREAK   
   EndIf
   
//   IF nP_OPC = 4 // PREPARA
   IF Type("lPreparaRv") = "L" .Or. aAuxRotina[nP_OPC] = 4
       
       If Type("lPreparaRv") <> "L" .And. lNewRv
          If !SI301SelPed() //Seleciona pedido para gerar o arquivo.
             Break
          EndIf
       EndIf
       EE7->(RECLOCK("EE7",.F.))

       //EEY->(dbSetOrder(3))
       EEY->(dbSetOrder(2))
       lTemEEY := EEY->(dbSeek(xFilial("EEY")+EE7->EE7_PEDIDO))

       IF lTemEEY
          DO WHILE ! EEY->(EOF()) .AND.;
             EEY->(EEY_FILIAL+EEY_PEDIDO) = (XFILIAL("EEY")+EE7->EE7_PEDIDO)
             IF Empty( EEY->EEY_NUMRV )  // Verificar se ainda não houve retorno.
                cNCMRV := EEY->(EEY_NCM+EEY_DTQNCM+EEY_TPONCM)
                EXIT
             ENDIF

             EEY->(DBSKIP())

          ENDDO
       ENDIF
       
       If lNewRv
          lTemEEY := .f.
       EndIf

//   ELSEIF nP_OPC = 5 // GERA TXT.
   ELSEIF aAuxRotina[nP_OPC] = 5

          If lNewRv .And. !lRv11
             If !Empty(EEY->EEY_NUMRV)
                MsgInfo(STR0124,STR0012) //"Este R.V. já foi retornado."###"Atenção"
                Break
             EndIf
          EndIf
          
          EEY->(dbSetOrder(2))
          lTemEEY := EEY->(dbSeek(xFilial("EEY")+EE7->EE7_PEDIDO))
          
          IF lTemEEY
             DO WHILE !EEY->(EOF()) .AND.;
                EEY->(EEY_FILIAL+EEY_PEDIDO) = (XFILIAL("EEY")+EE7->EE7_PEDIDO)

                IF EMPTY(EEY->EEY_NUMRV)
                   cNCMRV := EEY->(EEY_NCM+EEY_DTQNCM+EEY_TPONCM)
                   EXIT
                ENDIF

                EEY->(DBSKIP())

             ENDDO
          ENDIF
          
          IF !lTemEEY .OR. EMPTY(cNCMRV)
             MSGINFO(STR0058,STR0012)      //"Processo nao possui RV. Prepare o RV primeiro !"###"Atenção"
          ELSEIF MSGYESNO(If(!Empty(EEY->EEY_TXTSIS),STR0123,"")+STR0059,STR0012) //"O arquivo já foi gerado. " ## "Confirma a geração do arquivo ?"###"Atenção"
             SI300GERA()
          ENDIF
          
          BREAK

//   ELSEIF nP_OPC = 6 /// RETORNA
   ELSEIF aAuxRotina[nP_OPC] = 6
          SI300RET()
          BREAK
//   ELSEIF nP_OPC = 7       // ESTORNO
   ELSEIF aAuxRotina[nP_OPC] = 7
          EE7->(RECLOCK("EE7",.F.))
          MSGINFO(STR0060+ENTER+; //"Esta rotina não estorna Registros de Venda (RV) no SISCOMEX,"
                  STR0061+ENTER+; //"esta apenas irá estornar os dados digitados na opção de Preparar RV e "
                  STR0062,STR0012) //"irá apagar o arquivo TXT gerado se ainda não processado."###"Atenção"
          EEY->(DBSETORDER(2))
          lTemEEY := EEY->(DBSEEK(XFILIAL("EEY")+EE7->EE7_PEDIDO))
          IF ! lTemEEY
             MSGINFO(STR0011,STR0012) //"Processo nao possui RV. Gere o RV primeiro !"###"Atenção"
             BREAK
          ENDIF

          If !SI301Valid("ESTORNO") // JPM - 06/12/05 - Validar o estorno
             Break
          EndIf

          lALTERA := .F.
          SI300VIES(nP_OPC)
          BREAK
   ENDIF
   *

   // GERA O TMP DOS ITENS DO PEDIDO
   cNCMRV   := If(Empty(cNCMRV), Space(12), cNCMRV)

   //TRP - 01/02/07 - Campos do WalkThru
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
   
   cWORKEE8 := E_CRIATRAB("EE8",aSEMSX3,"TMP")
   INDREGUA("TMP",cWORKEE8+TEOrdBagExt(),"EE8_POSIPI+EE8_DTQNCM+EE8_TPONCM","AllwayTrue()","AllwaysTrue()",STR0013) //"Processando Arquivo Temporario"

   EE8->(DBSETORDER(1))
   EE8->(DBSEEK(XFILIAL("EE8")+EE7->EE7_PEDIDO))

   DO WHILE ! EE8->(EOF()) .AND.;
      EE8->(EE8_FILIAL+EE8_PEDIDO) = (XFILIAL("EE8")+EE7->EE7_PEDIDO)

      If Val( EE8->EE8_SEQ_RV ) >  Val( nSEQEE8 ) // Armazena o maior nº seq. do RV.
         nSEQEE8 := EE8->EE8_SEQ_RV
      EndIf

      If EE8->EE8_STA_RV $ "G,R" // Verifica se já foi GERADO !
         EE8->(dbSkip())
         Loop
      EndIf

      // JPM - 28/11/05
      If lNewRv .And. EE8->EE8_STA_RV $ "P"
         EE8->(dbSkip())
         Loop
      EndIf

      If Empty( EE8->EE8_RV ) // Verifica se não houve RETORNO !
 
         TMP->( dbAppend() )
         AVReplace( "EE8", "TMP" )
         TMP->TMP_DESC  := EasyMSMM(EE8->EE8_DESC,LEN(TMP->TMP_DESC),1,,LERMEMO,,,"EE8","EE8_DESC") //AAF/NCF - 13/09/2013 - Ajustes para melhora de performance Integ. Pedido Expo. Msg. Unica
         TMP->TMP_RECNO := EE8->(RECNO())
         TMP->TRB_ALI_WT:= "EE8"
         TMP->TRB_REC_WT:= EE8->(Recno())
         
         If !Empty( EE8->EE8_STA_RV ) // Verifica se já está PREPARADO !
            TMP->TMP_FLAG := cMARCA
            nMARCADOS     := nMARCADOS+1
            IF EMPTY(cNCMRV)
               cNCMRV := EE8->(EE8_POSIPI+EE8_DTQNCM+EE8_TPONCM)
            ENDIF
         ENDIF

      EndIf
      
      EE8->( dbSkip() )

   ENDDO

   IF TMP->(EOF()) .AND. TMP->(BOF())
      If lNewRv
         MSGINFO(STR0121,STR0012) //"Todos os itens do pedido já possuem R.V. gerado e/ou preparado."###"Atenção"
      Else
         MSGINFO(STR0014,STR0012) //"Todos os itens do pedido já tem RV gerado !"###"Atenção"
      EndIf
      BREAK
   ENDIF

   TMP->(DBGOTOP())

   If lNewRv .And. Type("lPreparaRV") = "L" //JPM
      nBTOP := 1
      SI300BAVAL()
      lCBRVItem := .T.
   Else
      
   // by CRF 29/10/2010 - 09:32
   aCAMPOTMP:= AddCpoUser(aCAMPOTMP,"EE8","2","TMP")
   
   
      DEFINE MSDIALOG oDLG TITLE STR0001 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL  //"Geraçao de RV"
         @ 20,05 SAY AVSX3("EE7_PEDIDO",AV_TITULO) PIXEL
         @ 18,40 MSGET EE7->EE7_PEDIDO  PICTURE AVSX3("EE7_PEDIDO",AV_PICTURE) SIZE 90,08 PIXEL OF oDLG WHEN(.F.)
         *
         @ 20,155 SAY AVSX3("EE7_DTPEDI",AV_TITULO) PIXEL
         @ 18,190 MSGET EE7->EE7_DTPEDI  PICTURE AVSX3("EE7_DTPEDI",AV_PICTURE)SIZE 40,08 PIXEL OF oDLG WHEN(.F.)
         *
         @ 35,05 SAY STR0015 PIXEL //"NCM RV"
         @ 33,40 MSGET oGET VAR cNCMRV  PICTURE "@R 9999.99.9999-99"           SIZE 55,08 PIXEL OF oDLG WHEN(.F.)
         *
         @ 50, 05 CheckBox oCBRVItem Var lCBRVItem Prompt STR0089 Size 70,08 //"Gera RV por item"
   
         aPOS           := POSDLGDOWN(oDLG)
         //aPOS[1]        := aPOS[1]-(aPOS[1]/2)
         oMSELECT       := MSSELECT():New("TMP","TMP_FLAG",,aCAMPOTMP,@lINVERTE,@cMARCA,aPOS)
         oMSELECT:BAVAL := {|| SI300BAVAL(),oGET:REFRESH()}
      ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
      *
   EndIf
   
   IF nBTOP = 0
      BREAK
   ENDIF

   TMP->(dbGoTop())
   
   While !TMP->(Eof())
      If ! Empty(TMP->TMP_FLAG)
         Exit
      EndIf
      
      TMP->(dbSkip())
   Enddo

   /*
   Substituido a rotina, para não utilizar o indice EEY, ordem 3.
   Autor      : Alexsander Martins dos Santos
   Data e Hora: 01/07/2004 às 09:00.

   lTemEEY2 := .f.
   IF !Empty(TMP->EE8_SEQ_RV)
      lTemEEY2 := EEY->( dbSeek( xFilial( "EEY" ) + TMP->EE8_PEDIDO + TMP->EE8_SEQ_RV ) )
   Endif

   FOR Z := 1 TO EEY->(FCOUNT())
       M->&(EEY->(FieldName(Z))) := If(lTemEEY2, EEY->(FieldGet(Z)), CriaVar(EEY->(FieldName(Z))))
   NEXT
   */   

   If lTemEEY
      For z := 1 To EEY->(FCount())
         M->&(EEY->(FieldName(Z))) := EEY->(FieldGet(z))
      Next
   Else
      For z := 1 To EEY->(FCount())
         M->&(EEY->(FieldName(Z))) := CriaVar(EEY->(FieldName(Z)))
      Next
   EndIf

   cMESANOFIX    := STR(M->EEY_MESFIX,2,0)+STR(M->EEY_ANOFIX,4,0)
   M->EEY_FILIAL := XFILIAL("EEY")
   M->EEY_PEDIDO := EE7->EE7_PEDIDO
   
   If lNewRv //JPM
      M->EEY_STATUS := ST_NO
      M->EEY_DSCSTA := CriaVar("EEY_DSCSTA")
   EndIf
   
   //IF !lTemEEY .or. !lTemEEY2
   IF !lTemEEY
      IF ! EMPTY(EE7->(EE7_EXPORT+EE7_EXLOJA))
         SA2->(DBSETORDER(1))
         SA2->(DBSEEK(XFILIAL("SA2")+EE7->(EE7_EXPORT+EE7_EXLOJA)))
      ELSE
         SA2->(DBSETORDER(1))
         SA2->(DBSEEK(XFILIAL("SA2")+EE7->(EE7_FORN+EE7_FOLOJA)))
      ENDIF
      
      M->EEY_CGCCPF := SA2->A2_CGC
      M->EEY_NCM    := LEFT(cNCMRV,8)
      M->EEY_DTQNCM := SUBSTR(cNCMRV,11,2)
      M->EEY_TPONCM := RIGHT(cNCMRV,2)
      
      SI300V("EEY_TPONCM") //Validação dos campos.
      
      M->EEY_IMPORT := EE7->EE7_IMPODE
      M->EEY_CONDPA := EE7->EE7_MPGEXP
      
      IF EE7->EE7_TIPCVL = "2"
         Z             := EE7->((EE7_TOTPED+EE7_DESCON)-(EE7_FRPREV+EE7_FRPCOM+EE7_SEGPRE+EE7_DESPIN+AVGETCPO("EE7->EE7_DESP1")+AVGETCPO("EE7->EE7_DESP2")))
         M->EEY_COMAGP := (EE7->EE7_VALCOM/Z)*100
      ELSE    
         M->EEY_COMAGP := EE7->EE7_VALCOM
      ENDIF
      
      SY9->(DBSETORDER(2))
      SY9->(DBSEEK(XFILIAL("SY9")+EE7->EE7_ORIGEM))
      M->EEY_POREMB := SY9->Y9_URF   

      SYR->(DBSETORDER(1))
      SYR->(DBSEEK(XFILIAL("SYR")+EE7->(EE7_VIA+EE7_ORIGEM+EE7_DEST+EE7_TIPTRA)))
      M->EEY_PAISDE := SYR->YR_PAIS_DE
      M->EEY_DTVEND := dDATABASE

   ENDIF
   
   M->EEY_PESLIQ := M->EEY_PESBRU := nVALFOB := 0
   
   bOK := {|| nBTOP := 1,IF(SI300V("BOK_GERA",aENCHOICE), oDLG:END(), nBTOP := 0)}

   /*
   Preparação p/ gerar de RV por item / Pedido.
   Autor       : Alexsander Martins dos Santos
   Data e Hora : 18/11/2003 às 17:20.   
   */   
   TMP->(dbGoTop())
   
   While !TMP->(Eof())

      If Empty(TMP->TMP_FLAG)
         TMP->(dbSkip())
         Loop
      EndIf

      nCursor := nCursor + 1
      lLastRec := (nCursor == TMP->(EasyRecCount()))
    
      cNCMRV := TMP->(EE8_POSIPI+EE8_DTQNCM+EE8_TPONCM)
      M->EEY_NCM    := LEFT(cNCMRV,8)
      M->EEY_DTQNCM := SUBSTR(cNCMRV,11,2)
      M->EEY_TPONCM := RIGHT(cNCMRV,2)
      
      If lCBRVItem

         If Val(cMesAnoFix) = 0 .and. !lTemEEY
            cMesAnoFix := TMP->EE8_MESFIX
         EndIf

         If Empty(M->EEY_PEEMBI)
               M->EEY_PEEMBI := TMP->EE8_DTPREM
         EndIf

         If TMP->(FieldPos("EE8_UNPES")) <> 0
            M->EEY_PESLIQ := AVTransUni(TMP->EE8_UNPES,cUNIDTON,,TMP->EE8_PSLQTO,.F.)
            M->EEY_PESBRU := AVTransUni(TMP->EE8_UNPES,cUNIDTON,,TMP->EE8_PSBRTO,.F.)
         Else
            M->EEY_PESLIQ := AVTransUni(TMP->EE8_UNIDAD,cUNIDTON,,TMP->EE8_PSLQTO,.F.)
            M->EEY_PESBRU := AVTransUni(TMP->EE8_UNIDAD,cUNIDTON,,TMP->EE8_PSBRTO,.F.)
         EndIf

            M->EEY_PESBRU := Round(M->EEY_PESBRU,5) // JPM - 10/01/06
         nVALFOB := TMP->EE8_PRCINC

      Else

         If !Empty(TMP->TMP_FLAG)

            If Val(cMesAnoFix) = 0 .and. !lTemEEY
               cMesAnoFix := TMP->EE8_MESFIX
            EndIf

            If Empty(M->EEY_PEEMBI)
               M->EEY_PEEMBI := TMP->EE8_DTPREM
            EndIf

            If TMP->(FieldPos("EE8_UNPES")) <> 0
               M->EEY_PESLIQ := M->EEY_PESLIQ+AVTransUni(TMP->EE8_UNPES,cUNIDTON,,TMP->EE8_PSLQTO,.F.)
               M->EEY_PESBRU := M->EEY_PESBRU+AVTRANSUNI(TMP->EE8_UNPES,cUNIDTON,,TMP->EE8_PSBRTO,.F.)
            Else
               M->EEY_PESLIQ := M->EEY_PESLIQ+AVTransUni(TMP->EE8_UNIDAD,cUNIDTON,,TMP->EE8_PSLQTO,.F.)
               M->EEY_PESBRU := M->EEY_PESBRU+AVTRANSUNI(TMP->EE8_UNIDAD,cUNIDTON,,TMP->EE8_PSBRTO,.F.)
            EndIf
            M->EEY_PESBRU := Round(M->EEY_PESBRU,5) // JPM - 10/01/06

            nVALFOB := nVALFOB+TMP->EE8_PRCINC

         EndIf

      EndIf         
      
      If lCBRVItem .or. lLastRec      
      
         //AMS - 18/11/2003 às 18:00, Rotina p/ pegar o ultimo dia do mês.
         If !Empty(M->EEY_PEEMBI)
            M->EEY_PEEMBF := (M->EEY_PEEMBI+31)-(Day(M->EEY_PEEMBI+31)-1)-1
         EndIf   
   
         M->EEY_PRCUNI := nVALFOB/M->EEY_PESLIQ
         M->EEY_MESFIX := VAL(LEFT(cMESANOFIX,2))
         M->EEY_ANOFIX := VAL(RIGHT(cMESANOFIX,4))
   
         IF EasyEntryPoint("EECSI300")
            EXECBLOCK("EECSI300",.F.,.F.,{"CV_DLG_EEY",nP_OPC})
         ENDIF
   
         //bOK := {|| nBTOP := 1,IF(SI300V("BOK_GERA",aENCHOICE), oDLG:END(), nBTOP := 0)}
         
         DBSELECTAREA("EEY")
         DEFINE MSDIALOG oDLG TITLE If(lCBRVItem, STR0074 + AllTrim(Str(nCursor)) + "/" + AllTrim(Str(nMARCADOS)), STR0057) FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL  //"Geração de RV - Preparar"
            aPOS     := POSDLG(oDLG)
            ENCHOICE("EEY",EEY->(RECNO()),If(aAuxRotina[nP_OPC] = 0,AScan(aAuxRotina,5),nP_OPC),,,,aENCHOICE,aPOS,NIL)
         ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)

         IF nBTOP = 1 .AND. nP_OPC > 2 .AND. lALTERA
            PROCESSA({|| SI300PREP(lTemEEY)},STR0016) //"Processando"
         ENDIF  

      EndIf

      TMP->(dbSkip())

   End

END SEQUENCE

EE7->(MSUNLOCK())
IF SELECT("TMP") # 0
   //TMP->(dbCloseArea()) 
   TMP->(E_ERASEARQ(cWORKEE8))
ENDIF

RESTORD(aORD,If(aAuxRotina[nP_OPC] <> 0 .And. aAuxRotina[nP_OPC] <> 4,.t.,.f.))

RETURN (nBTOP == 1)
*--------------------------------------------------------------------
FUNCTION SI300V(cP_CAMPO,cP_PAR2)
LOCAL lRET,Z
*
lRET     := .T.
cP_CAMPO := IF(cP_CAMPO=NIL,"",cP_CAMPO)

// ** JPM - 31/01/06 - Validação para os campos numéricos, para não ficarem negativos
If !Empty(cP_CAMPO) .And. Type("M->"+cP_CAMPO) = "N" 
   If SX3->(IndexOrd()) <> 2
      SX3->(DbSetOrder(2))
   EndIf
   If SX3->(DbSeek(cP_CAMPO))
      If &("M->"+cP_CAMPO) < 0
         MsgInfo(StrTran(STR0126,"###",AllTrim(SX3->X3_TITULO)),STR0012) //"O campo ### não pode ficar negativo."###"Atenção"
         Return .F.
      EndIf
   EndIf
EndIf
// **

IF cP_CAMPO == "DATA"
   lRET := IF(EMPTY(cP_PAR2),;
              SPACE(08),;
              STRZERO(DAY(cP_PAR2),2,0)+STRZERO(MONTH(cP_PAR2),2,0)+STRZERO(YEAR(cP_PAR2),4,0))
ELSEIF cP_CAMPO == "BOK"
       If !lCBRVItem
          IF nMARCADOS = 0
             MSGINFO(STR0017,STR0012) //"Selecione pelo meno um item !"###"Atenção"
             lRET := .F.
          ENDIF
       EndIf
ELSEIF cP_CAMPO == "BOK_GERA"
       FOR Z := 1 TO LEN(cP_PAR2)
          IF ! SI300V(cP_PAR2[Z])
             lRET := .F.
             EXIT
          ENDIF
       NEXT
ELSEIF cP_CAMPO == "EEY_CGCCPF"
       IF ! CGC(M->EEY_CGCCPF,"M->EEY_CGCCPF")
          lRET := .F.
       ELSE
         SA2->(DBSETORDER(3))
         IF ! (SA2->(DBSEEK(XFILIAL("SA2")+M->EEY_CGCCPF)))
             MSGINFO(STR0018,STR0012) //"C.G.C./C.P.F. não cadastrado !"###"Atenção"
            lRET := .F.
         ENDIF
       ENDIF
ELSEIF cP_CAMPO == "EEY_NCM"
       SYD->(DBSETORDER(1))
       IF ! (SYD->(DBSEEK(XFILIAL("SYD")+AVKEY(M->EEY_NCM,"YD_TEC"))))
          MSGINFO(STR0019,STR0012) //"NCM não cadastrada !"###"Atenção"
          lRET := .F.
       ENDIF
       SI300V("EEY_TPONCM")
ELSEIF cP_CAMPO == "EEY_TPONCM"
       IF M->EEY_TPONCM $ "99/98" //ER - Para exportação à países que não pertencem ao Mercosul,foram reservados os Tipos 99 e 98.
          IF EMPTY(M->EEY_DMERC1+M->EEY_DMERC2)
             SYD->(DBSETORDER(1))
             SYD->(DBSEEK(XFILIAL("SYD")+AVKEY(M->EEY_NCM,"YD_TEC")))
             Z := STRTRAN(MSMM(SYD->YD_TEXTO,AVSX3("YD_VM_TEXT",AV_TAMANHO)),ENTER," ")
             M->EEY_DMERC1 := PADR(MEMOLINE(Z,AVSX3("EEY_DMERC1",AV_TAMANHO),1),AVSX3("EEY_DMERC1",AV_TAMANHO)," ")
             M->EEY_DMERC2 := PADR(MEMOLINE(Z,AVSX3("EEY_DMERC2",AV_TAMANHO),2),AVSX3("EEY_DMERC2",AV_TAMANHO)," ")
          ENDIF
       ELSE
          M->EEY_DMERC1 := SPACE(AVSX3("EEY_DMERC1",AV_TAMANHO))
          M->EEY_DMERC2 := SPACE(AVSX3("EEY_DMERC2",AV_TAMANHO))
       ENDIF
ELSEIF cP_CAMPO == "EEY_CONDPA"
       EEF->(DBSETORDER(1))
       IF ! (EEF->(DBSEEK(XFILIAL("EEF")+M->EEY_CONDPA)))
          MSGINFO(STR0020,STR0012) //"Condição de Pagamento não cadastrada !"###"Atenção"
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO == "EEY_POREMB"
       SJ0->(DBSETORDER(1))
       IF ! (SJ0->(DBSEEK(XFILIAL("SJ0")+M->EEY_POREMB)))
          MSGINFO(STR0021,STR0012) //"Porto de origem não cadastrado !"###"Atenção"
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO ==  "EEY_PAISDE"
       SYA->(DBSETORDER(1))
       IF ! (SYA->(DBSEEK(XFILIAL("SYA")+M->EEY_PAISDE)))
          MSGINFO(STR0022,STR0012) //"País de destino não cadastrado !"###"Atenção"
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO == "EEY_PEEMBI"
       IF DTOS(M->EEY_PEEMBI) < DTOS(M->EEY_DTVEND)
          MSGINFO(STR0023,STR0012) //"Data prevista do embarque inicial não pode ser menor que a data da venda !"###"Atenção"
          lRET := .F.
       ELSEIF DTOS(M->EEY_PEEMBI) > (DTOS(M->EEY_DTVEND+(30*12)))
              MSGINFO(STR0024,STR0012) //"Data prevista do embarque inicial superior a 12 meses da data da venda !"###"Atenção"
              lRET := .F.
       ENDIF
ELSEIF cP_CAMPO == "EEY_PEEMBF"
       IF DTOS(M->EEY_PEEMBF) < DTOS(M->EEY_PEEMBI)
          MSGINFO(STR0025,STR0012) //"Intervalo da data de previsão de embarque inválido !"###"Atenção"
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO == "EEY_PESLIQ"
       IF M->EEY_PESLIQ < 0
          MSGINFO(STR0026,STR0012) //"Peso liquido não pode ser negativo !"###"Atenção"
          lRET := .F.
       Else
          M->(EEY_PESBRU := Round(EEY_PESLIQ + ((EEY_PESLIQ/60)*0.5),5)	 ) // RMD - 19/01/06 - Peso Bruto = Peso Líquido + (qtd. sacas 60kg X 0.5). 0.5 é o peso de uma saca de 60KG
       ENDIF
ELSEIF cP_CAMPO == "EEY_PESBRU"
       IF M->EEY_PESBRU < 0
          MSGINFO(STR0027,STR0012) //"Peso bruto não pode ser negativo !"###"Atenção"
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO == "EEY_PRCUNI"
       IF M->EEY_PRCUNI < 0
          MSGINFO(STR0028,STR0012) //"Preço unitário FOB não pode ser negativo !"###"Atenção"
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO == "EEY_DTVEND"
       IF EMPTY(M->EEY_DTVEND)
          MSGINFO(AVSX3("EEY_DTVEND",AV_TITULO)+STR0063,STR0012) //" deve ser preenchida !"###"Atenção"
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO == "EEY_MESFIX"
       IF M->EEY_MESFIX <= 0 .OR. M->EEY_MESFIX > 12
          MSGINFO(STR0066,STR0012) //"Mes de fixação inválido !"###"Atenção"
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO == "EEY_ANOFIX"
       IF M->EEY_ANOFIX <= 0
          MSGINFO(STR0067,STR0012) //"Ano de fixação inválido !"###"Atenção"
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO == "cUNIDTON" .OR. cP_CAMPO == "cUNIDLBS"
       SAH->(DBSETORDER(1))
       IF ! (SAH->(DBSEEK(XFILIAL("SAH")+cP_PAR2)))
          MSGINFO(STR0072+RIGHT(cP_CAMPO,3)+STR0008,STR0073) //"Codigo de unidade invalido. ("###") !"###"Atencao"
          lRET := .F.
       ENDIF
       
ELSEIF cP_CAMPO == "EEY_PECOTI" .OR. cP_CAMPO == "EEY_PECOTF" // JPM - 31/01/06 - Validar período cotacional.
       If !Empty(M->EEY_PECOTF) .And. M->EEY_PECOTI > M->EEY_PECOTF
          MsgInfo(STR0125,STR0073) //"Período de cotação inválido. Data inicial maior que a final."###"Atencao"
          lRet := .F.
       EndIf
ENDIF
RETURN(lRET)
*--------------------------------------------------------------------
FUNCTION SI300W(cP_CAMPO)
LOCAL lRET
*
lRET     := lALTERA
cP_CAMPO := IF(cP_CAMPO=NIL,"",cP_CAMPO)
IF cP_CAMPO == "EEY_DMERC1" .OR.;
   cP_CAMPO == "EEY_DMERC2"
   *
   IF M->EEY_TPONCM # "99"
      lRET := .F.
   ENDIF
ENDIF
RETURN(lRET)
*--------------------------------------------------------------------
STATIC FUNCTION SI300PREP(lTemEEY)
LOCAL lRET
*
lRET := .T.
PROCREGUA(TMP->(LASTREC()))
BEGIN TRANSACTION
   // GRAVA DADOS DA RV
   nSEQEE8 := STRZERO(VAL(nSEQEE8)+1,LEN(EE8->EE8_SEQ_RV),0)
   IF ! lTemEEY
      EEY->(RECLOCK("EEY",.T.))  // INCLUI
   ELSE
      EEY->(RECLOCK("EEY",.F.))  // ALTERA
   ENDIF
   AVREPLACE("M","EEY")
   EEY->EEY_FILIAL := XFILIAL("EEY")
   EEY->EEY_SEQ    := nSEQEE8
   
   // ATUALIZA OS ITENS DO PEDIDO   
   If !lCBRVItem
      TMP->(DBGOTOP())
      DO WHILE ! TMP->(EOF())
         INCPROC()
         EE8->(DBGOTO(TMP->TMP_RECNO))
         EE8->(RECLOCK("EE8",.F.))
         IF ! EMPTY(TMP->TMP_FLAG)
            EE8->EE8_SEQ_RV := nSEQEE8
            EE8->EE8_STA_RV := "P"   // P-PREPAROU A RV
         ELSE
            EE8->EE8_SEQ_RV := ""
            EE8->EE8_STA_RV := ""
         ENDIF
         TMP->(DBSKIP())
      ENDDO
   Else
      INCPROC()
      EE8->(DBGOTO(TMP->TMP_RECNO))
      EE8->(RECLOCK("EE8",.F.))
      EE8->EE8_SEQ_RV := nSEQEE8
      EE8->EE8_STA_RV := "P"   // P-PREPAROU A RV
   EndIf   
   
   If lNewRv .And. !lRV11 .And. Empty(EEY->EEY_NUMRV) //RMD - 20/01/06 - Atualiza a quantidade e os pesos do pedido especial.
      EE8->EE8_SLDINI := EEY->EEY_PESLIQ
      EE8->EE8_SLDATU := EEY->EEY_PESLIQ
      EE8->EE8_PSLQTO := EEY->EEY_PESLIQ
      EE8->EE8_PSBRUN := EEY->(EEY_PESBRU / EEY_PESLIQ)
      EE8->EE8_PSBRTO := EEY->EEY_PESBRU
   EndIf
   
   EE8->(MsUnLock())  
 
   IF EasyEntryPoint("EECSI300")
      EXECBLOCK("EECSI300",.F.,.F.,{"GR_TXT_EEY"})
   ENDIF
   
END TRANSACTION
RETURN(lRET)
*--------------------------------------------------------------------
FUNCTION SI300RET()
LOCAL lRET,nSEQ,cFILE,hFILE,Z,cBUFFER,aARQERR,aFILESOK,aFILESERR,;
      bPROC,nREC,aORD
PRIVATE nPROC,aPROCS,aFILES,aEMBARQUE,nPOSARRAY,aDETALHE
*
aORD      := SAVEORD({"EEY"})
nREC      := EEY->(RECNO())
nPOSARRAY := nPROC := 0
aPROCS    := {}
aFILES    := {}
aEMBARQUE := {}
aDETALHE  := {}
aARQERR   := {}
aFILESOK  := ASORT(DIRECTORY(cPATHOR+"RV*.OK") ,,,{|N1,N2| N1[1] < N2[1]})
aFILESERR := ASORT(DIRECTORY(cPATHOR+"RV*.ERR"),,,{|N1,N2| N1[1] < N2[1]})
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
   BEGIN TRANSACTION
      bPROC := {|| PROCREGUA(LEN(aFILES)),aEVAL(aFILES,{|X| SI300LERTXT(X)})}
      PROCESSA(bPROC)
      IF VALTYPE(aEMBARQUE) # "U"
         SI300TREE()
      ENDIF
   END TRANSACTION
ENDIF
RESTORD(aORD)
EEY->(DBGOTO(nREC))
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION SI300LERTXT(cFILE)
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
SI300LERVE(cFILE+".OK" ,cFILE2)
SI300LERVE(cFILE+".ERR",cFILE2)
FOR nX := 1 TO LEN(aDETAILTXT)
    // ** Atualiza o EEY ...
    EEY->(DBSETORDER(2))
    IF (EEY->(DBSEEK(XFILIAL("EEY")+aDETAILTXT[nX,1]+cFILE)))
       EEY->(RECLOCK("EEY",.F.))
       // ** By JBJ - 16/10/02 - 13:51 ...
       //EEY->EEY_NUMRV := STRTRAN(aDETAILTXT[nX,2],"/","")
       EEY->EEY_NUMRV := aDETAILTXT[nX,2]
       EEY->EEY_DTRV  := aDETAILTXT[nX,3]
       EE8->(DBSETORDER(1))
       EE8->(DBSEEK(XFILIAL("EE8")+aDETAILTXT[nX,1]))
       DO WHILE ! EE8->(EOF()) .AND.;
          EE8->(EE8_FILIAL+EE8_PEDIDO) = (XFILIAL("EE8")+aDETAILTXT[nX,1])
          *
          IF EE8->EE8_SEQ_RV = EEY->EEY_SEQ
             EE8->(RECLOCK("EE8",.F.))
             IF aDETAILTXT[nX,5] = "OK"
                EE8->EE8_STA_RV := "R"
                EE8->EE8_RV     := EEY->EEY_NUMRV
                IF EE8->(FieldPos("EE8_DTRV")) > 0
                   EE8->EE8_DTRV   := aDETAILTXT[nX,3]
                Endif
                // ATUALIZA O EE9 CASO EXISTA
                EE9->(DBSETORDER(1))
                IF (EE9->(DBSEEK(XFILIAL("EE9")+EE8->(EE8_PEDIDO+EE8_SEQUEN))))
                   EE9->(RECLOCK("EE9",.F.))
                   EE9->EE9_RV   := EEY->EEY_NUMRV
                   IF EE9->(FieldPos("EE9_DTRV")) > 0
                      EE9->EE9_DTRV := aDETAILTXT[nX,3]
                   Endif
                   EE9->(MsUnLock())
                ENDIF
             ELSE
                EE8->EE8_STA_RV := "E"
             ENDIF
             EE8->(MsUnLock())
          ENDIF
          EE8->(DBSKIP())
       ENDDO
    Else
       // by CAF 12/06/2003 19:40
       MsgInfo(STR0090+aDETAILTXT[nX,1]+STR0091,STR0009) //"Não foi possivel localizar o registro de preparação para o Processo: "###" - (Verifique se o txt-inc foi gerado pelo sistema)"###"Aviso"
    ENDIF
NEXT
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION SI300LERVE(cFILE,cFILE2)
LOCAL cPREEMB,cHORA,dDATA,nLIDOS,hFILE,lFILEOK,aORD,nPOS,cOLDANEXO,;
      cOLDTXT,nPOSANEXO,nSIZE,nBYTES,nENDLINE,nVOLTA,cNUMRV,Z
PRIVATE cBUFFER,cAUX,cLINE
*
aORD    := SAVEORD({"EE7"})
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
      MSGINFO(STR0032+LTRIM(STR(FERROR())),STR0009) //"Erro do DOS nro. "###"Aviso"
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
            AADD(aEMBARQUE,{TRANSFORM(AVKEY(cPREEMB,"EE7_PEDIDO"),AVSX3("EE7_PEDIDO",AV_PICTURE)),{},{}}) // Embarque ...
            Z := LEN(aEMBARQUE)
         ENDIF
         INCPROC(AVSX3("EE7_PEDIDO",AV_TITULO)+" "+TRANSFORM(cPREEMB,AVSX3("EE7_PEDIDO",AV_PICTURE)))
         EE7->(DBSETORDER(1))
         EE7->(DBSEEK(xFILIAL("EE7")+AVKEY(cPREEMB,"EE7_PEDIDO")))
         IF ASCAN(aPROCS,cPREEMB) = 0
            AADD(aPROCS,cPREEMB)
         ENDIF
      ENDIF
      IF lFILEOK
         // ** By JBJ - 16/10/02 - 13:49
         // cNUMRV := AVKEY(SUBSTR(cLINE,21,20),"EEY_NUMRV")         
         cNumRv := AvKey(StrTran(SubStr(cLine,21,20),"/",""),"EEY_NUMRV")
         cHORA  := STRTRAN(SUBSTR(cLINE,51,5),":","")
         dDATA  := AVCTOD(SUBSTR(cLINE,41,10))
         AADD(aDETAILTXT,{cPREEMB,cNUMRV,dDATA,cHORA,"OK",cLINE})
         AADD(aEmbarque[Z,2],LEFT(cFile,8))  // ** Nome Txt.Ok
         EXIT
      ELSE
         lERRO  := .T.
         cHORA  := STRTRAN(SUBSTR(cLINE,33,5),":","")
         dDATA  := AVCTOD("")
         cNUMRV := ""
         AADD(aDETAILTXT,{cPREEMB,cNUMRV,dDATA,cHORA,"ERR",cLINE})
         AADD(aEmbarque[Z,3],LEFT(cFILE,8))  // ** Nome Txt.Err
      ENDIF
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
STATIC FUNCTION SI300TREE()
LOCAL lRET,bOK,aCOMBO,bCANCEL,aPROCS,aORD,nX
PRIVATE cCOMBO,cMEMO,oMEMO,oFONT,oTREE,oTREE2,oTREE3,oDLG,;
        aPAGINA,aROTINA,aPOS,lEXISTERRO,lEXISTEOK
*
cCOMBO  := cMEMO := ""
oFONT   := TFONT():NEW("Courier New",09,15)
aPAGINA := {}
aPOS    := {}
lRET    := .T.
bOK     := {||oDLG:END()}
bCANCEL := {||oDLG:END()}
aCOMBO  := {STR0033,STR0034,STR0035} //"Todos"###"Finalizados"###"Pendentes"
aPROCS  := {}
aORD    := SAVEORD("EE7")
nX      := 0
DEFINE MSDIALOG oDLG TITLE STR0036 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL  //"Retorno Siscomex"
   aPOS := POSDLG(oDLG)
   @ 15,03 SAY STR0037 SIZE 50,08  PIXEL  //"Processos:"
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
If cCombo == STR0033 //"Todos"
   oTree2:Hide()
   oTree3:Hide()
   oTree :Show()
ElseIf cCombo == STR0034 //"Finalizados"
       oTree :Hide()
       oTree3:Hide()
       oTree2:Show()
       If ! lExisteOk
          cMemo := STR0038 //"Nao ha itens para esta selecao."
          oMemo:Refresh()
          oMemo:Show()
       EndIf
Else // Pendente
   oTree :Hide()
   oTree2:Hide()
   oTree3:Show()
   If ! lExistErro
      cMemo := STR0038 //"Nao ha itens para esta selecao."
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
   EE7->(DbSetOrder(1))
   EE7->(DbSeek(xFilial("EE7")+cProcesso))
   // Carrega informações do processo de embarque ...
   cMemo += STR0039+Replic(ENTER,2) //" Dados do Processo de Exportação: "
   cMemo += IncSpace(Space(1)+AvSx3("EE7_PEDIDO",AV_TITULO),20,.f.)+": "+EE7->EE7_PEDIDO+ENTER 
   cMemo += IncSpace(Space(1)+AvSx3("EE7_DTPROC",AV_TITULO),20,.f.)+": "+Transf(EE7->EE7_DTPROC,"  /  /  ")+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EE7_STTDES",AV_TITULO),20,.f.)+": "+EE7->EE7_STTDES+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EE7_IMPODE",AV_TITULO),20,.f.)+": "+Posicione("SA1",1,xFilial("SA1")+EE7->EE7_IMPORT+EE7->EE7_IMLOJA,"A1_NOME")+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EE7_FORNDE",AV_TITULO),20,.f.)+": "+Posicione("SA2",1,xFilial("SA2")+EE7->EE7_FORN+EE7->EE7_FOLOJA,"A2_NOME")+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EE7_INCOTE",AV_TITULO),20,.f.)+": "+EE7->EE7_INCOTE+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EE7_MOEDA ",AV_TITULO),20,.f.)+": "+EE7->EE7_MOEDA+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EE7_CONDPA",AV_TITULO),20,.f.)+": "+SY6Descricao(EE7->EE7_CONDPA+Str(EE7->EE7_DIASPA,AVSX3("EE7_DIASPA",3),AVSX3("EE7_DIASPA",4)),EE7->EE7_IDIOMA,1)+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EE7_MPGEXP",AV_TITULO),20,.f.)+": "+EE7->EE7_MPGEXP+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EE7_TOTITE",AV_TITULO),20,.f.)+": "+AllTrim(Str(EE7->EE7_TOTITE,AVSX3("EE7_TOTITE",AV_TAMANHO),0))+ENTER
   cMemo += IncSpace(Space(1)+AvSx3("EE7_TOTPED",AV_TITULO),20,.f.)+": "+AllTrim(Transf(EE7->EE7_TOTPED,AvSX3("EE7_TOTPED",AV_PICTURE)))+ENTER
Else
   cFileTxt := AllTrim(cProcesso)
   nPosFile := aScan(aDetalhe,{|aX| aX[1] = cFileTxt})
   If nPosFile > 0
      cMemo += STR0040+Replic(ENTER,2)  //"Detalhes do arquivo de retorno : "
      cMemo += STR0041+AllTrim(aDetalhe[nPosFile,2,1,1])+ENTER //"Nome         : "
      cMemo += STR0042+AllTrim(Str(aDetalhe[nPosFile,2,1,2]))+STR0043+ENTER //"Tamanho      : "###" bytes"
      cMemo += STR0044+Transf (aDetalhe[nPosFile,2,1,3],"  /  /  ")+ENTER  //"Data geracao : "
      cMemo += STR0045+AllTrim(aDetalhe[nPosFile,2,1,4])+ENTER  //"Hora geracao : "
      cMemo += Replic(ENTER,2)
      cMemo += STR0046+IF(lERRO,STR0047,STR0048)+ENTER //"Conteudo do arquivo "###"de erro:"###"OK:"
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
STATIC FUNCTION SI300BAVAL(cP_MODO)
LOCAL c1,oDLG,aPOS,aENCHOICE,bOK,bCANCEL,aBUTTONS,nBTOP,Z
*
cP_MODO := IF(cP_MODO=NIL,"",cP_MODO)
IF EMPTY(cP_MODO)
   c1 := TMP->(AllTrim(EE8_POSIPI)+AllTrim(EE8_DTQNCM)+AllTrim(EE8_TPONCM))
   IF ! EMPTY(TMP->TMP_FLAG)
      TMP->TMP_FLAG := ""
      nMARCADOS     := nMARCADOS-1
      IF nMARCADOS = 0
         cNCMRV := SPACE(LEN(cNCMRV))
      ENDIF
// ELSEIF ! EMPTY(cNCMRV) .AND. c1 # cNCMRV
   ElseIf IsMarcado("TMP", "TMP_FLAG") .and. c1 <> ContentMark("TMP", "TMP_FLAG", "EE8_POSIPI+EE8_DTQNCM+EE8_TPONCM")
          MSGINFO(STR0049+TRANSFORM(cNCMRV,"@R 9999.99.9999-99")+STR0050,STR0012) //"Só podem ser selecionados os itens de NCMs+Destaque+Tipo iguais a "###" !"###"Atenção"
   ELSE
      IF EMPTY(cNCMRV)
         cNCMRV := c1
      ENDIF
      TMP->TMP_FLAG := cMARCA
      nMARCADOS     := nMARCADOS+1
   ENDIF
ELSE
   nBTOP     := 0
   aBUTTONS  := {}
   bOK       := {|| nBTOP := 1,oDLG:END()}
   bCANCEL   := {|| nBTOP := 0,oDLG:END()}
   aENCHOICE := {"EEY_PEDIDO","EEY_CGCCPF","EEY_NCM"   ,"EEY_DTQNCM","EEY_TPONCM"  ,;
                 "EEY_DMERC1","EEY_DMERC2","EEY_IMPORT","EEY_DTVEND","EEY_CONDPA",;
                 "EEY_PREMI1","EEY_PREMI2","EEY_COMAGP","EEY_COMAGV","EEY_POREMB",;
                 "EEY_PAISDE","EEY_PEEMBI","EEY_PEEMBF","EEY_PECOTI","EEY_PECOTF",;
                 "EEY_MESFIX","EEY_ANOFIX","EEY_IMPEXP","EEY_PESLIQ","EEY_PESBRU",;
                 "EEY_PRCUNI","EEY_RATPRC","EEY_PERIMP","EEY_PEREXP","EEY_DTPEDI",;
                 "EEY_DTQNCM","EEY_TPONCM","EEY_NUMRV" ,"EEY_DTRV"}
   EEY->(DBGOTO(TMP->TMP_RECNO))
   FOR Z := 1 TO EEY->(FCOUNT())
       M->&(EEY->(FIELDNAME(Z))) := EEY->(FIELDGET(Z))
   NEXT 
   
   //OAP - Inclusão de campos craidos pelo usuário para serem exibidos na Enchoice.
   aENCHOICE := AddCpoUser(aENCHOICE,"EEY","1")
   
   DEFINE MSDIALOG oDLG TITLE cP_MODO FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL 
      aPOS := POSDLG(oDLG)
      ENCHOICE("EEY",EEY->(RECNO()),2,,,,aENCHOICE,aPOS,NIL)
   ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
   IF nBTOP = 1
      IF TMP->(FIELDPOS("TMP_FLAG")) # 0
         IF EMPTY(TMP->TMP_FLAG)
            IF EMPTY(TMP->EEY_NUMRV) .OR.;
               MSGYESNO(STR0051,STR0012) //"NCM já tem RV. Deseja realmente estoná-la ?"###"Atenção"
               *
               TMP->TMP_FLAG := cMARCA
            ENDIF
         ELSE
            TMP->TMP_FLAG := ""
         ENDIF
      ENDIF
   ENDIF
ENDIF
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION SI300VIES(nP_OPC)
LOCAL oDLG,cTITULO,aBUTTONS,bOK,bCANCEL,nBTOP,aPOS,oMSELECT,cFLAG,cWORKEEY,;
      aSEMSX3,aCAMPOTMP,aFILE,hFILE,Z,cBUFFER,cMODO, lEstornado := .F.
*
nBTOP    := 0
aBUTTONS := {}
bCANCEL  := {|| nBTOP := 0,oDLG:END()}
aSEMSX3  := {{"TMP_RECNO","N",07,0}}
aBUTTONS := {{"RELATORIO" /*"ANALITICO"*/,{|| SI300BAVAL(cTITULO+cMODO)},STR0052}} //"Detalhes do RV"
bOK      := {|| nBTOP := 1,oDLG:END()}
cTITULO  := STR0001 //"Geração de RV"
//IF nP_OPC = 2
IF aAuxRotina[nP_OPC] = 2 //visualizar
   cFLAG     := ""
   aCAMPOTMP := {}
   cMODO     := STR0053 //" - Visualização"
ELSE
   cFLAG     := "TMP_FLAG"
   cMODO     := STR0054 //" - Estorno"
   aCAMPOTMP := {{"TMP_FLAG","","  "}}
   AADD(aSEMSX3,{"TMP_FLAG","C",02,0})
ENDIF
AADD(aCAMPOTMP,COLBRW("EEY_NUMRV" ,"TMP")) ; AADD(aCAMPOTMP,COLBRW("EEY_DTRV"  ,"TMP"))
AADD(aCAMPOTMP,COLBRW("EEY_NCM"   ,"TMP")) ; AADD(aCAMPOTMP,COLBRW("EEY_DTQNCM","TMP"))
AADD(aCAMPOTMP,COLBRW("EEY_TPONCM","TMP")) ; AADD(aCAMPOTMP,COLBRW("EEY_DTVEND","TMP"))
AADD(aCAMPOTMP,COLBRW("EEY_PREMI1","TMP")) ; AADD(aCAMPOTMP,COLBRW("EEY_POREMB","TMP"))
AADD(aCAMPOTMP,COLBRW("EEY_PAISDE","TMP")) ; AADD(aCAMPOTMP,COLBRW("EEY_PEEMBI","TMP"))
AADD(aCAMPOTMP,COLBRW("EEY_PEEMBF","TMP")) ; AADD(aCAMPOTMP,COLBRW("EEY_MESFIX","TMP"))
AADD(aCAMPOTMP,COLBRW("EEY_ANOFIX","TMP")) ; AADD(aCAMPOTMP,COLBRW("EEY_PESLIQ","TMP"))
AADD(aCAMPOTMP,COLBRW("EEY_PESBRU","TMP")) ; AADD(aCAMPOTMP,COLBRW("EEY_PRCUNI","TMP"))

//TRP - 06/02/07 - Campos do WalkThru
AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

// GERA TMP DE CONSULTA/ESTORNO
DbSelectArea("EEY")
cWORKEEY := E_CRIATRAB("EEY",aSEMSX3,"TMP")
INDREGUA("TMP",cWORKEEY+TEOrdBagExt(),"EEY_NUMRV","AllwayTrue()","AllwaysTrue()",STR0013) //"Processando Arquivo Temporario"

/*
Retirado o Seek na tabela EEY, pq antes de chamar está função(SI300VIES) já é dado o mesmo Seek.
Autor : Alexsander Martins dos Santos
Data e Hora : 30/06/2004 às 16:37.

EEY->(DBSETORDER(2))
EEY->(DBSEEK(XFILIAL("EEY")+EE7->EE7_PEDIDO))
*/

DO WHILE ! EEY->(EOF()) .AND.;
   EEY->(EEY_FILIAL+EEY_PEDIDO) = (XFILIAL("EEY")+EE7->EE7_PEDIDO)
   *
   TMP->(DBAPPEND())
   AVREPLACE("EEY","TMP")
   TMP->TMP_RECNO := EEY->(RECNO())
   TMP->TRB_ALI_WT:= "EEY"
   TMP->TRB_REC_WT:= EEY->(Recno())
   EEY->(DBSKIP())
ENDDO

// CRF - adicionar um campo de usuario para a msselect
aCAMPOTMP := AddCpoUser(aCAMPOTMP,"EEY","5","TMP")

TMP->(DBGOTOP())
DEFINE MSDIALOG oDLG TITLE cTITULO FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL 
   @ 18,005 SAY AVSX3("EE7_PEDIDO",AV_TITULO) PIXEL
   @ 16,040 MSGET EE7->EE7_PEDIDO  PICTURE AVSX3("EE7_PEDIDO",AV_PICTURE) SIZE 90,08 PIXEL OF oDLG WHEN(.F.)
   *
   @ 18,155 SAY AVSX3("EE7_DTPEDI",AV_TITULO) PIXEL
   @ 16,190 MSGET EE7->EE7_DTPEDI  PICTURE AVSX3("EE7_DTPEDI",AV_PICTURE)SIZE 40,08 PIXEL OF oDLG WHEN(.F.)
   *
   aPOS           := POSDLGDOWN(oDLG)
   aPOS[1]        := aPOS[1]-((aPOS[1]/2)+(aPOS[1]/2)/2)+5
   oMSELECT       := MSSELECT():New("TMP",cFLAG,,aCAMPOTMP,@lINVERTE,@cMARCA,aPOS)
   oMSELECT:BAVAL := {|| SI300BAVAL(cTITULO+cMODO)}
ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
IF nBTOP = 1 .AND. ! EMPTY(cFLAG)
   BEGIN TRANSACTION
      TMP->(DBGOTOP())
      DO WHILE ! TMP->(EOF())
         IF ! EMPTY(TMP->TMP_FLAG)
            lEstornado := .T.
            EEY->(DBGOTO(TMP->TMP_RECNO))
            EEY->(RECLOCK("EEY",.F.))
            EE8->(DBSETORDER(1))
            EE8->(DBSEEK(XFILIAL("EE8")+EE7->EE7_PEDIDO))
            DO WHILE ! EE8->(EOF()) .AND.;
               EE8->(EE8_FILIAL+EE8_PEDIDO) = (XFILIAL("EE8")+EE7->EE7_PEDIDO)
               *
               IF EE8->EE8_SEQ_RV = EEY->EEY_SEQ
                  EE8->(RECLOCK("EE8",.F.))
                  EE8->EE8_STA_RV := ""
                  EE8->EE8_RV     := ""
                  EE8->EE8_SEQ_RV := ""
                  EE8->(MsUnLock())
               ENDIF
               EE8->(DBSKIP())
            ENDDO
            FERASE(cPATHOR+EEY->EEY_TXTSIS)
            EEY->(DBDELETE())
         ENDIF
         TMP->(DBSKIP())
      ENDDO

      If !lEstornado // JPM - 31/01/06
         Break
      EndIf
      
      If lNewRv .And. !lRvPed11 //JPM - 22/11/05
         Tmp->(DbGoTop())
         If !Empty(TMP->TMP_FLAG)
            EE7->(DbSetOrder(1))
            If EE7->(DbSeek(xFilial()+EEY->EEY_PEDIDO))
               Ap100DelPed()
            EndIf
         EndIf
         
      EndIf

      // GERA O EECTOT.AVG             
      aFILE := DIRECTORY(cPATHOR+"*.INC")
      aFILE := ASORT(aFILE,,,{|X,Y| X[1] < Y[1]})
      hFILE := EasyCreateFile(cPATHOR+"EECTOT.AVG")
      IF hFILE < 0
         MSGINFO(STR0030+cPATHOR+"EECTOT.AVG",STR0009) //"Erro de criação do arquivo: "###"Aviso"
      ELSE
         FOR Z := 1 TO LEN(aFILE)
             cBUFFER := aFILE[Z,1]+ENTER
             FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
         NEXT
         cBUFFER := "####eof#####"+ENTER
         FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
         FCLOSE(hFILE)
         MSGINFO(STR0055,STR0009) //"Estorno realizado com sucesso !"###"Aviso"
      ENDIF
   END TRANSACTION
ENDIF
RETURN(NIL)
*--------------------------------------------------------------------
FUNCTION SI300GERA(lSemMsg)
LOCAL lRET,nSEQ,cFILE,hFILE,Z,cBUFFER,aFILE,nDP1,nDP2,nDCP,nDCV,nDIE,nDPL,;
      nDPB,nDPU,nDRP,nDIM,nDEX
Local cKSA2      
Local aEEY := {}
Local nPos := 0
Default lSemMsg := .f.
*
lRET := .T.
nDP1 := AVSX3("EEY_PREMI1",AV_DECIMAL)
nDP2 := AVSX3("EEY_PREMI2",AV_DECIMAL)
nDCP := AVSX3("EEY_COMAGP",AV_DECIMAL)
nDCV := AVSX3("EEY_COMAGV",AV_DECIMAL)
nDIE := AVSX3("EEY_IMPEXP",AV_DECIMAL)
nDPL := AVSX3("EEY_PESLIQ",AV_DECIMAL)
nDPB := AVSX3("EEY_PESBRU",AV_DECIMAL)
nDPU := AVSX3("EEY_PRCUNI",AV_DECIMAL)
nDRP := AVSX3("EEY_RATPRC",AV_DECIMAL)
nDIM := AVSX3("EEY_PERIMP",AV_DECIMAL)
nDEX := AVSX3("EEY_PEREXP",AV_DECIMAL)

/*
Rotina original alterada p/ criação do(s) arquivo(s) TXT para RV por item ou embarque.
Autor       : Alexsander Martins Santos
Data e Hora : 19/11/2003 às 14:58.
*/

//Begin Transaction

   /*
   Book Mark Lookup - A chave de índice é composto pelo campo EEY_TXTSIS, onde na rotina o seu conteudo
                      é alterado, perdendo assim a ordem anterior ao looping.
   */
   While EEY->(!Eof() .and. EEY_FILIAL == xFilial("EEY") .and. EEY_PEDIDO == EE7->EE7_PEDIDO)
      aAdd(aEEY, EEY->(Recno()))
      EEY->(dbSkip())
   End

Begin Transaction

   For nPos := 1 To Len(aEEY)
   //While !EEY->(Eof()) .and. EEY->(EEY_FILIAL + EEY_PEDIDO) = (XFILIAL("EEY") + EE7->EE7_PEDIDO)

      EEY->(dbGoto(aEEY[nPos]))

      EEY->(RecLock("EEY", .F.))
      
      If Empty(EEY->EEY_TXTSIS)
         SetMv("MV_AVG0025", ((nSeq := EasyGParam("MV_AVG0025")) + 1) )         
         EEY->EEY_TXTSIS := ((cFile := "RV" + Padl(nSeq, 6, "0") + ".INC"))
      Else
         cFile := AllTrim(EEY->EEY_TXTSIS)
      EndIf
      
      If((hFile := EasyCreateFile(cPathOR + cFile)) < 0)
         MsgInfo(STR0029 + cPathOR + cFile, STR0009)
      Else
         Z := (AVTRANSUNI(cUNIDTON,cUNIDLBS,,EEY->EEY_PREMI1/EEY->EEY_PESLIQ,.F.))*100

         EE8->(dbSetOrder(1))
         EE8->(dbSeek(xFilial("EE8")+EEY->EEY_PEDIDO))
         
         //Posiciona no registo do EE8 referente ao EEY.
         While !EE8->(Eof()) .and. EE8->(EE8_FILIAL+EE8_PEDIDO) = (XFILIAL("EE8")+EEY->EEY_PEDIDO)

            If EE8->EE8_SEQ_RV == EEY->EEY_SEQ .and. EE8->EE8_STA_RV = "P"
               EE8->(RecLock("EE8", .F.))
               EE8->EE8_DIFERE := Z
               EE8->EE8_STA_RV := "G"
               EE8->(MsUnLock())
            EndIf

            EE8->(dbSkip())

         End

         IF EasyEntryPoint("EECSI300")
            EXECBLOCK("EECSI300",.F.,.F.,{"GR_TXT_EEY"})
         ENDIF
      
         //Geração do TXT.
         cBuffer := ""
         
         IF EasyGParam("MV_AVG0036",.T.) // Verifica se o parametro existe
            
            IF ! Empty(EE7->EE7_EXPORT) .And. !Empty(Posicione("SA2",1,xFilial("SA2")+EE7->EE7_EXPORT+EE7->EE7_EXLOJA,"A2_CGC"))
               cKSA2 := EE7->EE7_EXPORT+EE7->EE7_EXLOJA
            Else
               cKSA2 := EE7->EE7_FORN+EE7->EE7_FOLOJA
            Endif
   
            cBuffer := cBuffer+"ID"
            cBuffer := cBuffer+IncSpace(Posicione("SA2",1,xFilial("SA2")+cKSA2,"A2_CGC"),14,.F.)
            cBuffer := cBuffer+IncSpace(EasyGParam("MV_AVG0036",,""),14)
            cBuffer := cBuffer+CRLF
         
         Endif      
         
         cBUFFER := cBuffer+"NP"                                // 001/002 - IDENTIFICADOR
         cBUFFER := cBUFFER+PADR(EEY->EEY_PEDIDO,20," ")+ENTER  // 003/022 - NUMERO DO PROCESSO
         FWRITE(hFILE,cBUFFER,LEN(cBUFFER))

         cBUFFER := "T1"                                        // 001/002 - IDENTIFICADOR T1
         cBUFFER := cBUFFER+PADR(EEY->(Left(EEY_NCM,8)+EEY_DTQNCM+EEY_TPONCM),12," ") // 003/014 - NCM/DESTAQUE/TIPO
         cBUFFER := cBUFFER+PADR(EEY->EEY_DMERC1,45," ")        // 015/059 - DESCRICAO DA MERCADORIA 1
         cBUFFER := cBUFFER+PADR(EEY->EEY_DMERC2,45," ")        // 060/104 - DESCRICAO DA MERCADORIA 2
         cBUFFER := cBUFFER+PADR(EEY->EEY_IMPORT,60," ")        // 105/164 - NOME DO IMPORTADOR
         cBUFFER := cBUFFER+SI300V("DATA",EEY->EEY_DTVEND)      // 165/172 - DATA DA VENDA
         cBUFFER := cBUFFER+PADR(EEY->EEY_CONDPA,03," ")        // 173/175 - COND.PAGTO
         cBUFFER := cBUFFER+STR(EEY->EEY_PREMI1,14,nDP1)        // 176/189 - PREMIO 1
         cBUFFER := cBUFFER+STR(EEY->EEY_PREMI2,13,nDP2)        // 190/202 - PREMIO 2
         cBUFFER := cBUFFER+STR(EEY->EEY_COMAGP,10,nDCP)        // 203/212 - COMISSAO - PERCENTUAL
         cBUFFER := cBUFFER+STR(EEY->EEY_COMAGV,10,nDCV)        // 213/222 - COMISSAO - DOLAR POR TONELADA
         cBUFFER := cBUFFER+PADR(EEY->EEY_POREMB,07," ")        // 223/229 - PORTO DE EMBARQUE
         SYA->(DBSETORDER(1))
         SYA->(DBSEEK(XFILIAL("SYA")+EEY->EEY_PAISDE))
         cBUFFER := cBUFFER+PADR(SYA->YA_SISEXP,04," ")         // 230/233 - PAIS DE DESTINO
         cBUFFER := cBUFFER+SI300V("DATA",EEY->EEY_PEEMBI)      // 234/241 - PERIODO-EMBARQUE 1
         cBUFFER := cBUFFER+SI300V("DATA",EEY->EEY_PEEMBF)      // 242/249 - PERIODO-EMBARQUE 2
         cBUFFER := cBUFFER+SI300V("DATA",EEY->EEY_PECOTI)      // 250/257 - PERIODO COTACIONAL 1
         cBUFFER := cBUFFER+SI300V("DATA",EEY->EEY_PECOTF)      // 258/265 - PERIODO COTACIONAL 2
         cBUFFER := cBUFFER+STR(EEY->EEY_MESFIX,02,0)           // 266/267 - MES/ANO DE FIXACAO 1
         cBUFFER := cBUFFER+STR(EEY->EEY_ANOFIX,04,0)           // 268/271 - MES/ANO DE FIXACAO 2
         cBUFFER := cBUFFER+STR(EEY->EEY_IMPEXP,06,nDIE)        // 272/277 - IMPOSTO DE RENDA (EXPORTACAO)
         cBUFFER := cBUFFER+STR(EEY->EEY_PESLIQ,18,nDPL)        // 278/295 - PESO LIQUIDO (t)
         cBUFFER := cBUFFER+STR(EEY->EEY_PESBRU,18,nDPB)        // 296/313 - PESO BRUTO
         cBUFFER := cBUFFER+STR(EEY->EEY_PRCUNI,14,nDPU)        // 314/327 - PRECO UNIT. FOB (US$/t)
         cBUFFER := cBUFFER+STR(EEY->EEY_RATPRC,13,nDRP)        // 328/340 - RATEIO PRECO MIN.GAR.(US/T)
         cBUFFER := cBUFFER+STR(EEY->EEY_PERIMP,05,nDIM)        // 341/345 - IMPORT(%)
         cBUFFER := cBUFFER+STR(EEY->EEY_PEREXP,05,nDEX)+ENTER  // 346/350 - EXPORT(%)
         FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
     
         cBUFFER := "####eof#####"+ENTER
         FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
         FCLOSE(hFILE)         
      
      EndIf

      //EEY->(dbSkip())

   //End
   Next

End Transaction
   
   //Geração do arquivo EECTOT.AVG.
   aFILE := DIRECTORY(cPATHOR+"*.INC")
   aFILE := ASORT(aFILE,,,{|X,Y| X[1] < Y[1]})         
   
   IF (hFILE := EasyCreateFile(cPATHOR+"EECTOT.AVG")) < 0
      MSGINFO(STR0030+cPATHOR+"EECTOT.AVG",STR0009) //"Erro de criação do arquivo: "###"Aviso"
   ELSE
      FOR Z := 1 TO LEN(aFILE)
         cBUFFER := aFILE[Z,1]+ENTER
         FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
      NEXT
         cBUFFER := "####eof#####"+ENTER
         FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
         FCLOSE(hFILE)
         If !lSemMsg
            MSGINFO(STR0031,STR0009) //"Arquivo gerado com sucesso !"###"Aviso"
         EndIf
   ENDIF

//End Transaction
Return(lRet)
//Final da rotina.

 /*
   EEY->(RECLOCK("EEY",.F.))  // INCLUI

   IF EMPTY(EEY->EEY_TXTSIS)
      nSEQ := EasyGParam("MV_AVG0025") // SEQUENCIA DA RV
      SETMV("MV_AVG0025",nSEQ+1)
      cFILE := "RV"+PADL(nSEQ,6,"0")+".INC"
      EEY->EEY_TXTSIS := cFILE
   ELSE
      cFILE := ALLTRIM(EEY->EEY_TXTSIS)
   ENDIF

   hFILE := EasyCreateFile(cPATHOR+cFILE)

   IF hFILE < 0
      MSGINFO(STR0029+cPATHOR+cFILE,STR0009) //"Erro na criação do arquivo: "###"Aviso"
   ELSE
      // CALCULANDO O DIFERENCIAL DE PRECO
      Z := (AVTRANSUNI(cUNIDTON,cUNIDLBS,,EEY->EEY_PREMI1/EEY->EEY_PESLIQ,.F.))*100

      EE8->(DBSETORDER(1))
      EE8->(DBSEEK(XFILIAL("EE8")+EEY->EEY_PEDIDO))

      DO WHILE ! EE8->(EOF()) .AND.;
         EE8->(EE8_FILIAL+EE8_PEDIDO) = (XFILIAL("EE8")+EEY->EEY_PEDIDO)
         *
//       IF EE8->EE8_SEQ_RV = EEY->EEY_SEQ
         If EE8->EE8_STA_RV = "P"          // Para todos os itens do processo que estiverem preparados seram gerados.
            EE8->(RECLOCK("EE8",.F.))
            EE8->EE8_DIFERE := Z
            EE8->EE8_STA_RV := "G"         //Grava como Gerado.

            // AMS - Gravação dos dados da RV no EEY.
            If EEY->( dbSeek( xFilial( "EEY" ) + EE8->EE8_PEDIDO + EE8->EE8_SEQ_RV ) )
               EEY->( RecLock( "EEY", .F. ) )
               EEY->EEY_TXTSIS := cFile
            EndIf

         ENDIF
         EE8->(DBSKIP())
      ENDDO

      IF EasyEntryPoint("EECSI300")
         EXECBLOCK("EECSI300",.F.,.F.,{"GR_TXT_EEY",nP_OPC})
      ENDIF

      // GERA O TXT COM OS DADOS
      cBuffer := ""
      
      // by CAF 19/07/2002
      // Verificar se gera o novo layout com as informacoes:
      // 1-CGC Representante e 2-CGC Representado   
      IF EasyGParam("MV_AVG0036",.T.) // Verifica se o parametro existe
         IF ! Empty(EE7->EE7_EXPORT) .And. !Empty(Posicione("SA2",1,xFilial("SA2")+EE7->EE7_EXPORT+EE7->EE7_EXLOJA,"A2_CGC"))
            cKSA2 := EE7->EE7_EXPORT+EE7->EE7_EXLOJA
         Else
            cKSA2 := EE7->EE7_FORN+EE7->EE7_FOLOJA
         Endif
   
         cBuffer := cBuffer+"ID"
         cBuffer := cBuffer+IncSpace(Posicione("SA2",1,xFilial("SA2")+cKSA2,"A2_CGC"),14,.F.)
         cBuffer := cBuffer+IncSpace(EasyGParam("MV_AVG0036",,""),14)
         cBuffer := cBuffer+CRLF
      Endif      
      
      cBUFFER := cBuffer+"NP"  // 001/002 - IDENTIFICADOR
      cBUFFER := cBUFFER+PADR(EEY->EEY_PEDIDO,20," ")+ENTER  // 003/022 - NUMERO DO PROCESSO
      FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
      cBUFFER := "T1"  // 001/002 - IDENTIFICADOR T1
      cBUFFER := cBUFFER+PADR(EEY->(Left(EEY_NCM,8)+EEY_DTQNCM+EEY_TPONCM),12," ") // 003/014 - NCM/DESTAQUE/TIPO
      cBUFFER := cBUFFER+PADR(EEY->EEY_DMERC1,45," ") // 015/059 - DESCRICAO DA MERCADORIA 1
      cBUFFER := cBUFFER+PADR(EEY->EEY_DMERC2,45," ") // 060/104 - DESCRICAO DA MERCADORIA 2
      cBUFFER := cBUFFER+PADR(EEY->EEY_IMPORT,60," ") // 105/164 - NOME DO IMPORTADOR
      cBUFFER := cBUFFER+SI300V("DATA",EEY->EEY_DTVEND) // 165/172 - DATA DA VENDA
      cBUFFER := cBUFFER+PADR(EEY->EEY_CONDPA,03," ") // 173/175 - COND.PAGTO
      cBUFFER := cBUFFER+STR(EEY->EEY_PREMI1,14,nDP1) // 176/189 - PREMIO 1
      cBUFFER := cBUFFER+STR(EEY->EEY_PREMI2,13,nDP2) // 190/202 - PREMIO 2
      cBUFFER := cBUFFER+STR(EEY->EEY_COMAGP,10,nDCP) // 203/212 - COMISSAO - PERCENTUAL
      cBUFFER := cBUFFER+STR(EEY->EEY_COMAGV,10,nDCV) // 213/222 - COMISSAO - DOLAR POR TONELADA
      cBUFFER := cBUFFER+PADR(EEY->EEY_POREMB,07," ") // 223/229 - PORTO DE EMBARQUE
      SYA->(DBSETORDER(1))
      SYA->(DBSEEK(XFILIAL("SYA")+EEY->EEY_PAISDE))
      cBUFFER := cBUFFER+PADR(SYA->YA_SISEXP,04," ") // 230/233 - PAIS DE DESTINO
      cBUFFER := cBUFFER+SI300V("DATA",EEY->EEY_PEEMBI) // 234/241 - PERIODO-EMBARQUE 1
      cBUFFER := cBUFFER+SI300V("DATA",EEY->EEY_PEEMBF) // 242/249 - PERIODO-EMBARQUE 2
      cBUFFER := cBUFFER+SI300V("DATA",EEY->EEY_PECOTI) // 250/257 - PERIODO COTACIONAL 1
      cBUFFER := cBUFFER+SI300V("DATA",EEY->EEY_PECOTF) // 258/265 - PERIODO COTACIONAL 2
      cBUFFER := cBUFFER+STR(EEY->EEY_MESFIX,02,0) // 266/267 - MES/ANO DE FIXACAO 1
      cBUFFER := cBUFFER+STR(EEY->EEY_ANOFIX,04,0) // 268/271 - MES/ANO DE FIXACAO 2
      cBUFFER := cBUFFER+STR(EEY->EEY_IMPEXP,06,nDIE) // 272/277 - IMPOSTO DE RENDA (EXPORTACAO)
      cBUFFER := cBUFFER+STR(EEY->EEY_PESLIQ,18,nDPL) // 278/295 - PESO LIQUIDO (t)
      cBUFFER := cBUFFER+STR(EEY->EEY_PESBRU,18,nDPB) // 296/313 - PESO BRUTO
      cBUFFER := cBUFFER+STR(EEY->EEY_PRCUNI,14,nDPU) // 314/327 - PRECO UNIT. FOB (US$/t)
      cBUFFER := cBUFFER+STR(EEY->EEY_RATPRC,13,nDRP) // 328/340 - RATEIO PRECO MIN.GAR.(US/T)
      cBUFFER := cBUFFER+STR(EEY->EEY_PERIMP,05,nDIM) // 341/345 - IMPORT(%)
      cBUFFER := cBUFFER+STR(EEY->EEY_PEREXP,05,nDEX)+ENTER // 346/350 - EXPORT(%)
      FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
      cBUFFER := "####eof#####"+ENTER
      FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
      FCLOSE(hFILE)
      
      // GERA O EECTOT.AVG             
      aFILE := DIRECTORY(cPATHOR+"*.INC")
      aFILE := ASORT(aFILE,,,{|X,Y| X[1] < Y[1]})
      hFILE := EasyCreateFile(cPATHOR+"EECTOT.AVG")
      IF hFILE < 0
         MSGINFO(STR0030+cPATHOR+"EECTOT.AVG",STR0009) //"Erro de criação do arquivo: "###"Aviso"
      ELSE
         FOR Z := 1 TO LEN(aFILE)
             cBUFFER := aFILE[Z,1]+ENTER
             FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
         NEXT
         cBUFFER := "####eof#####"+ENTER
         FWRITE(hFILE,cBUFFER,LEN(cBUFFER))
         FCLOSE(hFILE)
         MSGINFO(STR0031,STR0009) //"Arquivo gerado com sucesso !"###"Aviso"
      ENDIF
      
   ENDIF
END TRANSACTION
RETURN(lRET)
*/
*--------------------------------------------------------------------

/*
Função SI300RVD
Objetivo    : Manutenção e geração de RV desvinculada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 09/04/2004 às 16:06.
*/

Function SI300RVD(cAlias, nRecno, nOpc)

Local aOrd       := SaveOrd("EE7")
Local lRet       := .F.
Local lRetGerPed := .T.
Local nOpc2      := 0
Local bOk        := {|| If((lRet := SI300RVDVld()), (nOpc2 := 1,oDlg:End()),nOpc2 := 0)}
Local bCancel    := {|| nOpc2 := 0, oDlg:End()}
Local nLinha     := 8, nTira  := 0, nScan

Private cProcesso    := IncSpace(EasyGParam("MV_AVG0061",,"*"), 20, .F.)
Private cFornecedor  := Space(AVSX3("EE7_FORN",   AV_TAMANHO))
Private cLoja        := Space(AVSX3("EE7_FOLOJA", AV_TAMANHO))
Private cNCM         := Space(AVSX3("EE8_POSIPI", AV_TAMANHO))
Private cNCMDestaque := Space(AVSX3("EE8_DTQNCM", AV_TAMANHO))
Private cNCMTipo     := Space(AVSX3("EE8_TPONCM", AV_TAMANHO))
Private cPSTonelada  := 0
Private lPreparaRV   := .t.//para controle

Begin Sequence

   If lNewRv // JPM
      EE7->(DbSetOrder(1))
      If EE7->(AvSeekLast(xFilial()+"*"))
         cProcesso := "*"+AllTrim(StrZero(Val(SubStr(EE7->EE7_PEDIDO,2))+1,AvSx3("EE7_PEDIDO",AV_TAMANHO)-1))
      Else
         cProcesso := "*" + AllTrim(StrZero(1,AvSx3("EE7_PEDIDO",AV_TAMANHO)-1))
      EndIf
      IncSpace(cProcesso,AvSx3("EE7_PEDIDO",AV_TAMANHO),.f.)
   EndIf

   Define MSDialog oDlg Title STR0119 From 00, 00 To 150-nTira, 450 Of oMainWnd Pixel //"Criar R.V."

   AvBorda(oDlg)

   @ nLinha+=13, 05 Say AvSx3("EEY_PEDIDO",AV_TITULO) Pixel
   @ nLinha- 2 , 55 MSGet cProcesso Picture AVSX3("EEC_PEDREF", AV_PICTURE) When !lNewRv Size 75, 09 Pixel Of oDlg

   @ nLinha+=13, 05 Say STR0077 Pixel
   @ nLinha-2  , 55 MSGet cFornecedor Picture AVSX3("EE7_FORN", AV_PICTURE) Size 30, 09 Pixel Of oDlg F3("FOR")

   @ nLinha    , 110 Say STR0078 Pixel
   @ nLinha-2  , 150 MSGet cLoja Picture AVSX3("EE7_FOLOJA", AV_PICTURE) Size 15, 09 Pixel Of oDlg

   @ nLinha+=13, 05 Say STR0079 Pixel
   @ nLinha-2  , 55 MSGet cNCM Picture AVSX3("EE8_POSIPI", AV_PICTURE) Size 40, 09 Pixel Of oDlg F3("SYD")

   @ nLinha    , 110 Say STR0080 Pixel
   @ nLinha-2  , 150 MSGet cNCMDestaque Picture AVSX3("EE8_DTQNCM", AV_PICTURE) Size 10, 09 Pixel Of oDlg

   @ nLinha    , 175 Say STR0081 Pixel
   @ nLinha-2  , 205 MSGet cNCMTipo Picture AVSX3("EE8_TPONCM", AV_PICTURE) Size 10, 09 Pixel Of oDlg

   @ nLinha+=13, 05 Say STR0082 Pixel
   @ nLinha-2  , 55 MSGet cPSTonelada Picture AVSX3("EE8_PSLQUN", AV_PICTURE) Size 60, 09 Pixel Of oDlg VALID SI300RVDVld("cPSTonelada")

   IF EasyEntryPoint("EECSI300") // FJH 26/01/06
      EXECBLOCK("EECSI300",.F.,.F.,{"INI_GERA_RV"})
   ENDIF

   Activate MSDialog oDlg On Init Enchoicebar(oDlg, bOk, bCancel) Centered

   If nOpc2 = 1
      
      Begin Transaction
         If !ExistPedido(cProcesso)      
            If (lRetGerPed := lNewRv .Or. MsgYesNo(STR0092, STR0012)) //"O pedido informado não existe, deseja criar um para R.V. Desvinculada?"###"Atenção"
               MSAguarde({|| MSProcTxt(STR0093), lRetGerPed := SI300RVDGeraPed()}, STR0075) //"Gerando Pedido ..."
            EndIf
         Else
            If (lRetGerPed := MsgYesNo(STR0094, STR0012)) //"Deseja incluir um novo item para este pedido?"###"Atenção"
               MSAguarde({|| MSProcTxt(STR0095+ AllTrim(cProcesso) +" ..."), lRetGerPed := SI300RVDIncItem()}, STR0075) //"Incluindo Item para o pedido "
            EndIf
         EndIf
   
         If lRetGerPed
            nScan := If(AScan(aAuxRotina,4) > 0,4,0)
            If !SI300MAN(,,AScan(aAuxRotina,nScan)) .And. lNewRv //Gerar... (o Preparar pode não existir no aRotina)
               Ap100DelPed() // se não criou o R.V., exclui o Pedido
            ElseIf lNewRv .And. MsgYesNo(STR0127, STR0009)//"Deseja vincular com um R.V. manual?"###"Aviso"
               SI301RvMan()
            EndIf
         EndIf
      End Transaction
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return(lRet)

/*
Função SI300RVDVld
Objetivo    : Validar os dados de informado pelo usuário.
Autor       : Alexsander Martins dos Santos
Data e Hora : 09/04/2004 às 16:06.
*/

Static Function SI300RVDVld(cCampo)

Local lRet     := .F.
Local aSaveOrd := SaveOrd("SA2")
Local nQtdenaEmb := EasyGParam("MV_AVG0066",, 0.6)

Begin Sequence

   If cCampo == "cProcesso" .or. cCampo = Nil

      If Empty(cProcesso)
         MsgInfo(STR0096, STR0012) //"No. do Processo não informado."###"Atenção"
         lRet := .F.
         Break
      EndIf

      If Left(cProcesso, 1) <> "*"
         MsgInfo(STR0097, STR0012) //"Deve ser informado * no inicio do No. do Processo."###"Atenção"
         lRet := .F.
         Break
      EndIf
   EndIf

   If cCampo == "cFornecedor" .or. cCampo = Nil

      If Empty(cFornecedor)
         MsgInfo(STR0098, STR0012) //"Código do fornecedor não informado."###"Atenção"
         lRet := .F.
         Break
      EndIf

      SA2->(dbSetOrder(1))
      If SA2->(dbSeek(xFilial("SA2")+cFornecedor))
         lRet := .T.
      Else
         MsgInfo(STR0099, STR0012) //"Fornecedor não encontrado."###"Atenção"
         lRet := .F.
         Break
      EndIf

   EndIf

   If cCampo = "cLoja" .or. cCampo = Nil

      If Empty(cLoja)
         MsgInfo(STR0100, STR0012) //"Loja do fornecedor não informado."###"Atenção"
         lRet := .F.
         Break
      EndIf

      SA2->(dbSetOrder(1))
      If SA2->(dbSeek(xFilial("SA2")+cFornecedor+cLoja))
         cLoja := SA2->A2_LOJA
         lRet := .T.
      Else
         MsgInfo(STR0101, STR0012) //"Fornecedor/Loja não encontrado."###"Atenção"
         lRet := .F.
         Break
      EndIf

   EndIf

   If cCampo == "cNCM" .or. cCampo = Nil

      If Empty(cNCM)
         MsgInfo(STR0113, STR0012) //"No. NCM não informado."###"Atenção"
         lRet := .F.
         Break
      EndIf
      
      SYD->(dbSetOrder(1))
      If SYD->(dbSeek(xFilial("SYD")+cNCM))
         lRet := .T.
      Else
         MsgInfo(STR0112, STR0012) //"NCM não encontrada."###"Atenção"
         lRet := .F.
         Break         
      EndIf
   
   EndIf
   
   If cCampo == "cNCMDestaque" .or. cCampo = Nil
   
      If Empty(cNCMDestaque)
         MsgInfo(STR0102, STR0012) //"Destaque da NCM não informado."###"Atenção"
         lRet := .F.
         Break
      Else
         lRet := .T.
      EndIf
   
   EndIf
   
   If cCampo == "cNCMTipo" .or. cCampo = Nil
   
      If Empty(cNCMTipo)
         MsgInfo(STR0103, STR0073) //"Tipo da NCM não informado."###"Anteção"
         lRet := .F.
         Break
      Else
         lRet := .T.
      EndIf
   
   EndIf
   
   If cCampo == "cPSTonelada" .or. cCampo = Nil
      
      If Empty(cPSTonelada)
         MsgInfo(STR0105, STR0012) //"Peso em Tonelada, não informado."###"Atenção"
         lRet := .F.
         Break
      Else     

         If !EECFlags("CAFE") .And. (cPSTonelada % nQtdenaEmb) <> 0
            MsgInfo(STR0106, STR0012) //"Quantidade deve ser multipla pela qtde de embalagem!"
            lRet := .F.
            Break
         Endif 

         // Rodar a validação do campo peso liquido.         
         M->EEY_PESLIQ := cPSTonelada
         lRet := Eval(AVSX3("EEY_PESLIQ",AV_VALID))

      EndIf
      
   EndIf

End Sequence

RestOrd(aSaveOrd)

Return(lRet)


/*
Função      : ExistPedido
Parametro   : cPedido -> No. do pedido.
Objetivo    : Retornar .T., se encontrar o pedido e .F., caso contrário.
Autor       : Alexsander Martins dos Santos
Data e Hora : 10/04/2004 às 08:57.
*/

Static Function ExistPedido(cPedido)

Local lRet     := .F.
Local aSaveOrd := SaveOrd("EE7")

EE7->(dbSetOrder(1))
If EE7->(dbSeek(xFilial("EE7")+cPedido))
   lRet := .T.
EndIf

RestOrd(aSaveOrd)

Return(lRet)


/*
Função      : ExistFornecedor
Parametro   : cCodigo -> Código do Fornecedor
Objetivo    : Retornar .T., se encontrar o fornecedor e .F., caso contrário.
Autor       : Alexsander Martins dos Santos
Data e Hora : 10/04/2004 às 08:57.
*/

/*
Static Function ExistFornecedor(cCodigo)

Local lRet     := .F.
Local aSaveOrd := SaveOrd("SA2")

SA2->(dbSetOrder(1))
If SA2->(dbSeek(xFilial("SA2")+cCodigo))
   lRet := .T.
EndIf

RestOrd(aSaveOrd)

Return(lRet)
*/


/*
Função      : SI300RVDGeraPed()
Objetivo    : Preparação do pedido.
Autor       : Alexsander Martins dos Santos
Data e Hora : 10/04/2004 às 10:12
*/

Static Function SI300RVDGeraPed()

Local lRet     := .F.
Local aSaveOrd := SaveOrd({"SA1", "SY6", "EEF", "SYR", "SB1", "EE5"})
Local aVars    := {}
Local nCampo, nRec

Private Inclui := .T.

Begin Sequence
   
   If lNewRv // JPM
      If(Select("WorkIt")  > 0, WorkIt->(avzap()),nil)
      If(Select("WorkEm")  > 0, WorkEm->(avzap()),nil)
      If(Select("WorkAg")  > 0, WorkAg->(avzap()),nil)
      If(Select("WorkIn")  > 0, WorkIn->(avzap()),nil)
      If(Select("WorkDe")  > 0, WorkDe->(avzap()),nil)
      If(Select("WorkNo")  > 0, WorkNo->(avzap()),nil)
      If(Select("WorkDoc") > 0,WorkDoc->(avzap()),nil)
   Else
      //Criação das variaveis e work's do pedido.
      aVars := ap102SetWorks()
   EndIf

   For nCampo := 1 To EE7->(FCount())
      M->&(EE7->(FieldName(nCampo))) := CriaVar(EE7->(FieldName(nCampo)))
   Next     
   
   M->EE7_OBS    := ""
   M->EE7_MARCAC := ""
   M->EE7_OBSPED := ""
   M->EE7_GENERI := ""
     
   //Informações da capa do embarque.
   M->EE7_PEDIDO := cProcesso
   M->EE7_DTPROC := dDataBase
   M->EE7_DTPEDI := dDataBase
   
   SA1->(dbSetOrder(1))
   SA1->(dbSeek(xFilial("SA1")))
   M->EE7_IMPORT := SA1->A1_COD
   M->EE7_IMLOJA := SA1->A1_LOJA
   M->EE7_IMPODE := "PEDIDO ESPECIAL PARA RV SEM VINCULACAO"
   
   M->EE7_FORN   := cFornecedor
   M->EE7_FOLOJA := cLoja

   M->EE7_IDIOMA := PORTUGUES //"PORT. -PORTUGUES"
   
   SY6->(dbSetOrder(1))
   SY6->(dbSeek(xFilial("SY6")))   
   M->EE7_CONDPA := SY6->Y6_COD
   M->EE7_DIASPA := SY6->Y6_DIAS_PA
   
   EEF->(dbSetOrder(1))
   EEF->(dbSeek(xFilial("EEF")))
   M->EE7_MPGEXP := EEF->EEF_COD
   
   M->EE7_INCOTE := "FOB"   
   M->EE7_FRPPCC := "CC"
   
   M->EE7_CALCEM := "1"
   
   SYR->(dbSetOrder(1))
   SYR->(dbSeek(xFilial("SYR")))
   While !SYR->(Eof() .And. SYR->YR_FILIAL == xFilial("SYR"))
      If SYR->(!Empty(YR_VIA) .and. !Empty(YR_ORIGEM) .and. !Empty(YR_DESTINO) .and. !Empty(YR_TIPTRAN))
         M->EE7_VIA     := SYR->YR_VIA
         M->EE7_ORIGEM  := SYR->YR_ORIGEM
         M->EE7_DEST    := SYR->YR_DESTINO
         M->EE7_TIPTRA  := SYR->YR_TIPTRAN
         Exit
      EndIf   
      SYR->(dbSkip())
   End
   
   M->EE7_STATUS := ST_RV
   M->EE7_INTERM := "2"
   
   //Informações dos intens do pedido.
   WorkIt->(dbAppend())

   SB1->(dbSetOrder(1))
   SB1->(dbSeek(xFilial("SB1")))   
   WorkIt->EE8_COD_I  := SB1->B1_COD
   
   WorkIt->EE8_SEQUEN := "     1"
   WorkIt->EE8_VM_DES := STR0107 //"Item especial para R.V. sem vinculação."
   WorkIt->EE8_FORN   := M->EE7_FORN
   WorkIt->EE8_FOLOJA := M->EE7_FOLOJA

   If (WorkIt->EE8_UNIDAD := EasyGParam("MV_AVG0030",, ".")) == "."
      MsgInfo(STR0108, STR0012) //"O parametro MV_AVG0030 está vazio e deve ser preenchido com o código da unidade de médida da Tonelada"###"Atenção"
      Break
   EndIf

   WorkIt->EE8_QE     := 1
   WorkIt->EE8_QTDEM1 := 1

   EE5->(dbSetOrder(1))
   EE5->(dbSeek(xFilial("EE5")))
   WorkIt->EE8_EMBAL1 := EE5->EE5_CODEMB
   
   WorkIt->EE8_PRECO  := 0                 
   
   WorkIt->EE8_UNPES  := WorkIt->EE8_UNIDAD   
   WorkIt->EE8_UNPRC := EasyGParam("MV_AVG0030",, "")

   If Empty(WorkIt->EE8_UNPRC)
      WorkIt->EE8_UNPRC  := CriaVar("EE8_UNPRC")
   EndIf
   If Empty(WorkIt->EE8_UNPRC)
      WorkIt->EE8_UNPRC := WorkIt->EE8_UNIDAD
   EndIf

   WorkIt->EE8_PSLQUN := 1
   
   // Gravar as qtdes em KG
   WorkIt->EE8_SLDINI := AVTransUni(EasyGParam("MV_AVG0030"),WorkIt->EE8_UNIDAD,,cPSTonelada,.F.)
   
   WorkIt->EE8_SLDATU := WorkIt->EE8_SLDINI
   WorkIt->EE8_PSLQTO := WorkIt->EE8_SLDINI // em KG
   WorkIt->EE8_PSBRTO := WorkIt->EE8_PSLQTO
   WorkIt->(EE8_PSBRTO := EE8_PSLQTO + ((EE8_PSLQTO/60)*0.5) ) // JPM - 29/12/05 - Peso Bruto = Peso Líquido + (qtd. sacas 60kg X 0.5). 0.5 é o peso de uma saca de 60KG

   WorkIt->(EE8_PSBRUN := EE8_PSBRTO/EE8_SLDINI)
   
   WorkIt->EE8_POSIPI := cNCM   
   WorkIt->EE8_DTQNCM := cNCMDestaque
   WorkIt->EE8_TPONCM := cNCMTipo
   WorkIt->EE8_STATUS := ST_RV
   
   If lNewRv // JPM - tratamento para não gerar pedidos com mesmo numero, caso a gravação seja feita ao mesmo tempo por 2 ou mais usuários.
      SX6->(DbSetOrder(1))
      SX6->(DbSeek("  MV_AVG0061"))
      While SX6->(!MsRLock())
         AvDelay(1)
      EndDo
      nRec := EE7->(RecNo())
      EE7->(DbSetOrder(1))
      While EE7->(DbSeek(xFilial()+M->EE7_PEDIDO))
         M->EE7_PEDIDO := "*"+StrZero(Val(SubStr(AllTrim(M->EE7_PEDIDO),2))+1,AvSx3("EE7_PEDIDO",AV_TAMANHO)-1)
      EndDo
      If M->EE7_PEDIDO <> cProcesso
         MsgInfo(StrTran(STR0120,"###",AllTrim(M->EE7_PEDIDO)),STR0012) // "O número do processo foi modificado para ###, pois havia outro usuário criando R.V.."###"Atenção"
      EndIf
      EE7->(DbGoTo(nRec))
   EndIf

   //Gravação dos dados do pedido.
   If !ap102SetGrvPed(.T.)
      MsgInfo(STR0109, STR0012) //"Ocorreu um problema na gravação do pedido e o mesmo não foi gerado."###"Atenção"
      Break
   EndIf

   If lNewRv // JPM 
      If(Select("WorkIt")  > 0, WorkIt->(avzap()),nil)
      If(Select("WorkEm")  > 0, WorkEm->(avzap()),nil)
      If(Select("WorkAg")  > 0, WorkAg->(avzap()),nil)
      If(Select("WorkIn")  > 0, WorkIn->(avzap()),nil)
      If(Select("WorkDe")  > 0, WorkDe->(avzap()),nil)
      If(Select("WorkNo")  > 0, WorkNo->(avzap()),nil)
      If(Select("WorkDoc") > 0,WorkDoc->(avzap()),nil)
   Else
      //Exclusão das work's.
      If !ap102DelWorks(aVars)
         MsgInfo(STR0110, STR0012) //"Ocorreu um problema na deleção dos arquivos temporários."###"Atenção"
         Break
      EndIf
   EndIf

   SetMV("MV_AVG0061", cProcesso)

   lRet := .T.

End Sequence

If lNewRv // JPM 
   SX6->(DbSetOrder(1))
   SX6->(DbSeek("  MV_AVG0061"))
   SX6->(MsUnlock())
EndIf

RestOrd(aSaveOrd)

EE7->(MsUnlock())

Return(lRet)


/*
Função      : SI300RVDIncItem()
Objetivo    : Inclusão de Item.
Autor       : Alexsander Martins dos Santos
Data e Hora : 20/04/2004 às 11:37.
*/

Static Function SI300RVDIncItem()

Local lRet      := .F.
Local nCont     := 0
Local aSaveOrd  := SaveOrd("EE8")
Local nEE8Recno := 0
Local nSequen   := 0

Begin Sequence

   EE8->(dbSetOrder(1))
   EE8->(dbSeek(xFilial("EE8")+EE7->EE7_PEDIDO))

   //Pegar proxima sequencia.
   nEE8Recno := EE8->(Recno())
   While EE8->(!Eof() .and. EE8_FILIAL == xFilial("EE8") .and. EE8_PEDIDO == EE7->EE7_PEDIDO)
      nSequen := Val(EE8->EE8_SEQUEN)
      EE8->(dbSkip())   
   End   
   EE8->(dbGoto(nEE8Recno))

   For nCont := 1 To EE8->(FCount())
      M->&(EE8->(FieldName(nCont))) := EE8->(FieldGet(nCont))
   Next

   M->EE8_SEQUEN := Str(nSequen+1,AVSX3("EE8_SEQUEN",AV_TAMANHO))
   M->EE8_STA_RV := ""
   M->EE8_RV     := ""
   M->EE8_SEQ_RV := ""
   M->EE8_DTRV   := Ctod("")
   M->EE8_DTVCRV := Ctod("")

   M->EE8_QE     := 1
   M->EE8_PRECO  := 0                 
   
   // Gravar as qtdes em KG
   M->EE8_SLDINI := AVTransUni(AvKey(EasyGParam("MV_AVG0030"),"EE8_UNIDAD"),M->EE8_UNIDAD,,cPSTonelada,.F.)
      
   M->EE8_SLDATU := M->EE8_SLDINI
   M->EE8_PSLQTO := M->EE8_SLDINI
   M->EE8_PSBRTO := M->EE8_PSLQTO   
   
   M->EE8_POSIPI := cNCM   
   M->EE8_DTQNCM := cNCMDestaque
   M->EE8_TPONCM := cNCMTipo

   RecLock("EE8", .T.)
   AVReplace( "M", "EE8" )
   EE8->(MSUnLock())
   
   AP105CallPrecoI()
   
   lRet := .T.

End Sequence

RestOrd(aSaveOrd)

Return(lRet)


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 29/01/07 - 11:30
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := {{STR0002,"AXPESQUI",0,1},; //"Pesquisar"       1
                   {STR0003,"SI300MAN",0,2}}  //"Visualizar"      2
Local lRv11 := EasyGParam("MV_AVG0103",,.F.)//Verifica se os tratamentos de RV 1:1 estão habilitados
/*
Local aAuxRotina := {1 ,; //Pesquisar
                     2 }  //Visualizar
*/
aAuxRotina := {1 ,; //Pesquisar
               2 }  //Visualizar
If !lRv11
   aAdd(aRotina,{STR0119,"SI300RVD",0,3})  // "Criar R.V."
   AAdd(aAuxRotina,3)  // Criar
EndIf

If lRv11
   aAdd(aRotina,{STR0056,"SI300MAN",0,3}) //"Preparar"        4
   aAdd(aAuxRotina,4) //Preparar
EndIf

aAdd(aRotina,{STR0004,"SI300MAN",0,4}) //"Gerar"           5
aAdd(aAuxRotina,5) // Gerar
aAdd(aRotina,{STR0005,"SI300MAN",0,4}) //"Retorno"         6
aAdd(aAuxRotina,6) //Retorno

aAdd(aRotina,{STR0122,"SI301RvMan",0,4}) //"R.V. Manual"   
aAdd(aAuxRotina,13)
aAdd(aRotina,{STR0006,"SI300MAN",0,4}) //"Estorna"         7
aAdd(aAuxRotina,7) // Estorno

aAdd(aRotina,{STR0114,"AP100OpcFix",0,5}) //"Fixar Preço"
AAdd(aAuxRotina,8)

If !lRv11
   aAdd(aRotina,{STR0118,"SI301MAN"  ,0,4}) //"Baixa de R.V."
   aAdd(aAuxRotina,9)
EndIf

aRotina[2][2] := "SI301MAN" //Visualizar
aAdd(aRotina,{STR0115,"SI301MAN"  ,0,4}) //"Alterar"
aAdd(aAuxRotina,10)
aAdd(aRotina,{STR0116,"SI301MAN"  ,0,4}) //"Prorrogar"
aAdd(aAuxRotina,11)
aAdd(aRotina,{STR0117,"SI301Hist" ,0,2}) //"Histórico"
aAdd(aAuxRotina,12)

AAdd(aAuxRotina,0)

// P.E. utilizado para adicionar itens no Menu da mBrowse

If EasyEntryPoint("ESI300MNU")
	aRotAdic := ExecBlock("ESI300MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
