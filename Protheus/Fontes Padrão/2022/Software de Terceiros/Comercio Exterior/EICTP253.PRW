#INCLUDE "Eictp253.ch"
#include "AVERAGE.CH"
//#include "FiveWin.ch"

                             
#define  Tit253       STR0001 //"DESEMBOLSO REALIZADO"
#define  MsgProc      STR0002 //"EM PROCESSAMENTO - AGUARDE..."
#define  MsgPesq      STR0003 //"PESQUISANDO DADOS - AGUARDE..."
#define  K_ESC         27
#define  _Analitico     1
#define  _Sintetico     2
#define  _PO            1
#define  _Despesa       2
#define  DESPESA_FOB    "101"
#define  VALOR_CIF      "104"

#DEFINE  New_Line     CHR(13)+CHR(10)
#DEFINE  EOF_Text     CHR(26)

#XTRANSLATE :Dt_Pagto   => \[1\]
#XTRANSLATE :Vl_Pagto   => \[2\]

// RA - 15/08/2003 - Inclusao Ponto de Entrada E_RESET_AREA
#COMMAND E_RESET_AREA => SW3->(DBSETORDER(1)) ; SW5->(DBSETORDER(1))   ;
                       ; SW7->(DBSETORDER(1)) ;
        		       ; IF(EasyEntryPoint("EICTP253"),ExecBlock("EICTP253",.F.,.F.,"E_RESET_AREA"),) ;
                       ; If(Select("Work")>0,Work->(E_EraseArq(WorkFile,WorkNTX2)),);
                       ; DBSELECTAREA(nOldArea)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥EICTP253   ≥ Autor ≥ AVERAGE/MJBARROS      ≥ Data ≥ 09.07.97 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥Desembolso Realizado                                         ≥±±
±±≥          ≥                                                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe e ≥                                                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                             ≥±±
±±≥          ≥                                                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ SIGAEIC                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function EICTP253()

LOCAL cDespSelo:=GetNewPar("MV_SELO"," ")
LOCAL WorkFile, WorkNTX2, WorkNTX3, nOldArea:=Select(),;
      MMes, MAno, TMes:=MONTH(dDataBase),;
      TAno:=YEAR(dDataBase), ind_dt, MMsg,lProcessa:=.T.

LOCAL bNewDate:={|mes,ano| AVCTOD('01/'+PADL(mes,2,'0')+'/'+STR(ano,4,0)) }

LOCAL bGrava:={||TPC253Grava(MTIPO,TPO_NUM,MOrdem,lProcessa),lProcessa:=.F. }

LOCAL bWhile:={||SWD->WD_FILIAL==cFilSWD}, cPictPo := ALLTRIM(X3Picture("W2_PO_NUM"))

LOCAL bCondPO:={||IncProc(STR0004+ALlTRIM(SWD->WD_HAWB)),; //"Pesquisando Processo: "
                  SWD->WD_DES_ADI >= TDT_I      .AND. ;
                  SWD->WD_DES_ADI <= TDT_F      .AND. ;
                  SUBS(SWD->WD_DESPESA,1,1)#"9" }

LOCAL TB_Campos:={;
{ "WKDT_PAGTO"                               ,, STR0005               }  ,; //"Data"
{{||TRAN(WKDESPESA,'@R 9.99')+' '+WKDESPDESC},, STR0006            }  ,; //"Despesa"
{ "WKPO_NUM"                                 ,, STR0007  ,cPictPo }  ,; //"No. P.O."
{ "WKVL_PAGTO"                               ,, STR0008,'@E 999,999,999,999.99'} ,; //"Valor"
{ "WKFORN_R"                                 ,, STR0009         }  ,; //"Fornecedor"
{ "WKDT_PAGTO"                               ,  STR0005      }  } //"Data"

// RA - 15/08/2003 - Alterada de LOCAL para Private a variavel aStruct
Private aStruct:={ { "WKDT_PAGTO" , "D" ,  8 , 0 }  ,;
                   { "WKDESPESA"  , "C" ,  3 , 0 }  ,;
                   { "WKPO_NUM"   , "C" , AVSX3("W7_PO_NUM",AV_TAMANHO) , 0 }  ,;
                   { "WKVL_PAGTO" , "N" , 15 , 2 }  ,;
                   { "WKDESPDESC" , "C" , 30 , 0 }  ,;
                   { "WKFORN_N"   , "C" , 30 , 0 }  ,;
                   { "WKFORN_R"   , "C" , 20 , 0 }  ,;
                   { "WKNUM_PC"   , "C" , 04 , 0 }  ,;
                   { "WKDT_EMB"   , "D" , 08 , 0 }  ,;
                   { "WKCONDICAO" , "C" , 08 , 0 }  ,;
                   { "WK_HAWB"    , "C" , AVSX3("W7_HAWB",AV_TAMANHO) , 0 }  ,;
                   { "WKFOBPERC"  , "N" , 12 , 2 }  ,;
                   { "WKFOBDIAS"  , "N" , 05 , 0 } }   
                   
// TDF - 09/06/10                                 
Private aTitulos:= { {"Data"               ,"WKDT_PAGTO"     ,"",,,"",,"D"},;
                     {"Despesa"            ,"WKDESPESA"      ,"",,,"",,"C"},;
                     {"PO"                 ,"WKPO_NUM"       ,"",,,"",,"C"},;
                     {"Valor Pagamento"    ,"WKVL_PAGTO"     ,"",,,"",,"N"},;
                     {"DescriÁ„o"          ,"WKDESPDESC"     ,"",,,"",,"C"},;
                     {"Fornecedor"         ,"WKFORN_N"       ,"",,,"",,"C"},;
                     {"Cod Fornecedor"     ,"WKFORN_R"       ,"",,,"",,"C"},;
                     {"Numero PC"          ,"WKNUM_PC"       ,"",,,"",,"C"},;
                     {"Data embarque"      ,"WKDT_EMB"       ,"",,,"",,"D"},;
                     {"CondiÁ„o"           ,"WKCONDICAO"     ,"",,,"",,"C"},;
                     {"Processo"           ,"WK_HAWB"        ,"",,,"",,"C"},;
                     {"Percentual FOB"     ,"WKFOBPERC"      ,"",,,"",,"N"},;
                     {"Dias FOB"           ,"WKFOBDIAS"      ,"",,,"",,"N"} }


// RA - 15/08/2003 - Alterada de LOCAL para Private a variavel bCondDesp
Private bCondDesp:={||IncProc(STR0004+ALlTRIM(SWD->WD_HAWB)),; //"Pesquisando Processo: "
                    SWD->WD_DES_ADI >= TDT_I   .AND. ;
                    SWD->WD_DES_ADI <= TDT_F   .AND. ;
                    (EMPTY(TDESP) .OR. SWD->WD_DESPESA==TDESP).AND.;
                    SWD->WD_VALOR_R # 0        .AND. ;
                    SUBS(SWD->WD_DESPESA,1,1)#"9" }

Private MSai, MSubTit, lDesvio, lTraco // RA - 15/08/2003
If(EasyEntryPoint("EICTP253"),ExecBlock("EICTP253",.F.,.F.,"ESTRU_WORK"),) // RA - 15/08/2003

PRIVATE cMarca := GetMark(), lInverte := .F.
Private oPanel //LRL 14/04/04 
PRIVATE cCadastro := Tit253

PRIVATE cSavScrVP,cSavScrHT,cSavScrHP,;
        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999

PRIVATE aHeader[0],nUsado:=0

PRIVATE TDT_I, TDT_F, MTipo:=1, MOrdem

//somente devido a macro-substituicao no Help
PRIVATE TImport:="  ", TPO_NUM:=SPACE(LEN(SW7->W7_PO_NUM)), TDESP:=SPACE(03), aPOnum:={}
PRIVATE MCLASS:="", MCLASSNOME:="", lDespICMS:=.F.

PRIVATE cFilSWD:=xFilial("SWD")
PRIVATE cFilSW7:=xFilial("SW7")
Private _PictPO:= cPictPo, _FirstYear := Right(Padl(Set(_SET_EPOCH),4,"0"),2)

Private M_Total := 0

Private cForn_N := "", cForn_R := "",lMostraForn := .T.  // JBS 03/09/2003  

SW6->(DBSEEK(xFILIAL()+SWD->WD_HAWB))//ACB - 03/08/2010
SWB->(DBSEEK(xFILIAL()+SWD->WD_HAWB))// TDF - 13/08/2010

IF (++TMes) > 12
   TMes:=1 ; TAno++
ENDIF

TDT_I:=EVAL(bNewDate,TMes,TAno)
TDT_F:=EVAL(bNewDate,IF(TMes+1>12,1,TMes+1),IF(TMes+1>12,TAno+1,TAno)) - 1

WorkFile := E_CriaTrab(,aStruct,"Work") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("Work",WorkFile+TEOrdBagExt(),"WKPO_NUM+DTOS(WKDT_PAGTO)+WKDESPESA")

WorkNTX2:=E_Create(aStruct,.F.)
IndRegua("Work",WorkNTX2+TEOrdBagExt(),"WKDESPESA+DTOS(WKDT_PAGTO)+WK_HAWB")

SET INDEX TO (WorkFile+TEOrdBagExt()),(WorkNTX2+TEOrdBagExt())

SW2->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SWD->(DBSETORDER(1))
SYT->(DBSETORDER(1))
SA2->(DBSETORDER(1))

DO WHILE .T.

  IF ! Pergunte("EI253A",.T.)
     E_RESET_AREA ; RETURN
  ENDIF

  TImport:=AvKey(mv_par01, "W2_IMPORT")
  MTipo  :=1
  MOrdem :=mv_par02

  IF ! EMPTY(TImport)
     IF ! SYT->(DBSEEK(xFilial()+TImport))
        HELP("",1,"AVG0000572")//"IMPORTADOR NAO ENCONTRADO"
        LOOP
     ENDIF
  ENDIF

  IF(MTipo = _Analitico, MSubTit:=STR0015,MSubTit:=STR0016) //"Analitico"###"Sintetico"

  IF MOrdem = _PO

     TDT_I:=AVCTOD('01/01/'+_FirstYear)
     TDT_F:=AVCTOD('31/12/49')
     TDESP:=SPACE(03)

     ASIZE(TB_Campos,5)
     TB_Campos[1]:= {"WKPO_NUM"  ,,                                  STR0007,    } //"No. P.O."
     TB_Campos[2]:= {"WKDT_PAGTO",,                                  STR0005,    } //"Data"
     TB_Campos[3]:= {{||TRAN(WKDESPESA,'@R 9.99 ')+' '+WKDESPDESC},, STR0006,    } //"Despesa"
     TB_Campos[4]:= {"WKVL_PAGTO",,                                  STR0017, '@E 999,999,999,999.99'} //"Valor R$"
     TB_Campos[5]:= {"WKFORN_R"  ,,                                  STR0009,    } //"Fornecedor"

     MSai:=.F.     
     DO WHILE .T.
        IF ! Pergunte("EI253B",.T.)
           MSai:=.T.
           EXIT
        ENDIF

        TPO_NUM := mv_par01

        IF ! EMPTY(TPO_NUM) .AND. ! SW2->(DBSEEK(xFilial()+TPO_NUM))
           HELP("",1,"AVG0000576") //"P.O. N«O CADASTRADO"
           LOOP
        ENDIF


        IF !EMPTY(TImport) .AND. !EMPTY(TPO_NUM) .AND. TImport # SW2->W2_IMPORT
           HELP("",1,"AVG0000578") //"P.O. PERTENCE A OUTRO IMPORTADOR"
           LOOP
        ENDIF

        lDespICMS:=.F.
        MSubTit+=IF(EMPTY(TPO_NUM),STR0020,; //', todos os P.O.s'
                                   STR0021+ TRAN(TPO_NUM,_PictPO)) //', P.O. No. '
        EXIT
        
     ENDDO

     IF MSai
        LOOP
     ENDIF
     IF ! TPC253Datas(@TDT_I,@TDT_F,MSubTit)
        LOOP
     ENDIF
  ENDIF

  IF MOrdem = _Despesa

     TPO_NUM:=SPACE(LEN(SW7->W7_PO_NUM))
     TDT_I:=AVCTOD('01/01/'+_FirstYear)
     TDT_F:=AVCTOD('31/12/49')

     ASIZE(TB_Campos,5)
     TB_Campos[1]:= { {||TRAN(WKDESPESA,'@R 9.99')+' '+WKDESPDESC},, STR0006, } //"Despesa"
     TB_Campos[2]:= { "WKDT_PAGTO",,                                 STR0005, } //"Data"
     TB_Campos[3]:= { "WK_HAWB"   ,,STR0049} //"Processo"
     TB_Campos[4]:= { "WKVL_PAGTO",,                                 STR0017,'@E 999,999,999,999.99'} //"Valor R$"
     TB_Campos[5]:= { "WKFORN_R"  ,,                                 STR0009, } //"Fornecedor"

     MSai:=.F.
     DO WHILE .T.
  
        lDesvio := .F. // RA - 15/08/2003
        If(EasyEntryPoint("EICTP253"),ExecBlock("EICTP253",.F.,.F.,"GET_DESPESA"),) // RA - 15/08/2003

        If !lDesvio // RA - 15/08/2003     

           IF ! Pergunte("EI253C",.T.)
              MSai:=.T.
              EXIT
           ENDIF

           TDESP:= mv_par01

           IF ! EMPTY(TDESP) .AND. ! SYB->(DBSEEK(xFilial()+TDESP))
              HELP("",1,"AVG0000581") //"DESPESA N«O CADASTRADA"
              LOOP
           ENDIF

           IF ! EMPTY(TDESP) .AND. TDESP = VALOR_CIF
              HELP("",1,"AVG0000584") //DESPESA NAO PODE SER VALOR C.I.F.
              LOOP
           ENDIF

           IF(TDESP $ "203",MSai:=TPC253class(,@MCLASS,@MCLASSNOME,@lDespICMS), )

           MSubTit+=IF(EMPTY(TDESP),STR0024,STR0025+; //', todas as despesas'###', despesa '
                    TRAN(TDESP,'@R 9.99 ')+ALLTRIM(LEFT(SYB->YB_DESCR,15)))

           MSubTit+=IF(TDESP $ "203",' - '+MCLASSNOME,"" )

        Endif
        
        EXIT
     ENDDO
     IF MSai
        LOOP
     ENDIF

     IF !TPC253Datas(@TDT_I,@TDT_F,MSubTit)
        LOOP
     ENDIF
  ENDIF

  Work->(avzap())
  lTabPoNum:=IF(MOrdem == _PO, .T., .F. ) 

  DO CASE
     CASE MOrdem = _PO
          Work->(DBSETORDER(1))
          SWD->(DBSETORDER(1))
          SWD->(DBSEEK(cFilSWD))
          Processa({||ProcRegua(SWD->(LASTREC())),;
                      SWD->(DBEVAL(bGrava,bCondPO,bWhile))},STR0026) //"Apurando Despesas"

     CASE MOrdem = _Despesa
          Work->(DBSETORDER(2))
          SWD->(DBSETORDER(2))
          IF(EMPTY(TDESP),SWD->(DBSEEK(cFilSWD)),SWD->(DBSEEK(cFilSWD+TDESP)))
          lProcessa:=.T.
          Processa({||ProcRegua(SWD->(LASTREC())),;
                      SWD->(DBEVAL(bGrava,bCondDesp,bWhile))},STR0026) //"Apurando Despesas"
  ENDCASE

  IF Work->(BOF()) .AND. Work->(EOF())
     HELP("",1,"AVG0000585") //"N«O EXISTEM REGISTROS PARA CONSULTA"
     LOOP
  ENDIF

  DBSELECTAREA("Work")
  M_TOTAL:=0
  WORK->(DBGOTOP())
  Work->(DBEVAL({||M_total+=WKVL_PAGTO},,{||!EOF()})) 
  WORK->(DBGOTOP())
  
  // TDF - 09/06/10
  //aCols:= GeraDados("Work")
  cTit:= "RelatÛrio de Desembolso Realizado"
  WORK->(DBGOTOP())
  
  oMainWnd:ReadClientCoors()
  DEFINE MSDIALOG oDlg TITLE cCadastro+' - '+MSubTit ;
         FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
       	      OF oMainWnd PIXEL                          
  @00,00 MsPanel oPanel Prompt "" Size 60,20 of oDlg //LRL 14/03/04 -Painel para alinhamento MDI.
  cImport:=IF(!EMPTY(TImport),TImport+' '+LEFT(SYT->YT_NOME,35),"")
  @ 05,8 SAY STR0028 SIZE 70,8 of oPanel PIXEL //"Importador :"
  @ 04.5,40 MSGET cImport SIZE 85,8 WHEN .F. of oPanel PIXEL

  @ 05,140 SAY STR0029 SIZE 40,8 of oPanel PIXEL //"Total :"
  @ 04.5,164 MSGET M_Total PICT '@E 999,999,999,999.99'  SIZE 60,8 WHEN .F. RIGHT of oPanel PIXEL
  //ACB - 16/04/2010 - Incluido bot„o do qual exporta para Excel
  //@5,(oDlg:nClientWidth-4)/2-150 BUTTON "Exporta Excel" Size 44,11 FONT oDlg:oFont;
           //ACTION AvExcel(WorkFile,"Work",.F.,,,"Desembolso Realizado") OF oPanel PIXEL
             //ACTION DlgToExcel({{"GETDADOS","RelatÛrio de Desembolso Realizado", aTitulos, aCols}}) OF oPanel PIXEL // TDF - 09/06/10 - TRATAMENTO DE EXPORTA«√O PARA EXCEL

  @5,(oDlg:nClientWidth-4)/2-100 BUTTON STR0010  SIZE 44,11 FONT oDlg:oFont ; //"Gera Arquivo"
          ACTION (TR350Arquivo("Work",,aTitulos,cTit)) OF oPanel PIXEL

  @5,(oDlg:nClientWidth-4)/2-50 BUTTON STR0011 SIZE 44,11 FONT oDlg:oFont ; //"Relatorio"
          ACTION (TPC253Print(M_Total,MTipo,MOrdem,TDT_I,TDT_F,MSubTit)) OF oPanel PIXEL

  oGet:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{42,2,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
  
  oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
  oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

  ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()})) //LRL 14/04/04 - Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

ENDDO   
           
*-----------------------------------------------------------*
FUNCTION TPC253Grava(PTIPO,TPO_NUM,MOrdem,lProcessa)
*-----------------------------------------------------------*
LOCAL MSOMA:=0,MSELO:=0, MFOBREPRES:=0,cFilSB1 := xFilial("SB1"), I
LOCAL lTemSelo:= .F.
Local cForn_Cod2:= "" // TDF - 25/02/2011
Local cForn_Cod:= "" //SA2->A2_COD + " - " + Alltrim(SA2->A2_NREDUZ) // TDF - 13/08/2010 nopado por WFS
//LOCAL bWhile_ID:={||SW7->(! EOF())                 .AND.;
//                    SW7->W7_FILIAL == cFilSW7      .AND.;
//                    SW7->W7_HAWB   == SWD->WD_HAWB .AND.;
//                    SW7->W7_PO_NUM == TPO_NUM }

//LOCAL lAchou := .F.

//LOCAL bSoma:={||MSOMA+=SW7->W7_QTDE * SW7->W7_PRECO,;
//                MSELO+=IF(SB1->(DBSEEK(cFilSB1+ SW7->W7_COD_I)).AND.lTemSelo ,SW7->W7_QTDE * SB1->B1_VLRSELO,0)}

//** TDF - 13/08/2010
Private dDt1
Private dDt2
Private nDiFob
Private nFobPerc

cFilSW7:=xFilial("SW7")
cFilSW8:=xFilial("SW8")
cFilSW9:=xFilial("SW9")

dDt1 := Posicione("SWB", 1, xFilial("SWB")+SWD->WD_HAWB, "WB_DT_VEN") 
dDt2 := Posicione("SW6", 1, xFilial("SW6")+SWD->WD_HAWB, "W6_DT_EMB")
nDiFob := DI500RetVal("TOT_INV", "TAB" , .T.)
nFobPerc := INT((SWB->WB_FOBMOE/nDiFob)*100) //INT((SWB->WB_FOBMOE/nDiFob)*1000)/100 - DFS - 21/09/2010 - Tratamento para n„o estourar o valor das casas decimais 
//** TDF - 13/08/2010

//calcular o valor do selo por pedido. AWR
SX3->(DBSETORDER(2))
lTemSelo := SX3->(DBSEEK("B1_VLRSELO")) .AND. ! Empty(cDespSelo:=GetNewPar('MV_SELO',' ')) 
SX3->(DBSETORDER(1))

IF lDespICMS
   SW7->(DBSETORDER(1))
   IF SW7->(DBSEEK(xFILIAL()+SWD->WD_HAWB ) )
      SW1->(DBSETORDER(1))
      SW1->(DBSEEK(xFILIAL()+SW7->W7_CC+SW7->W7_SI_NUM+SW7->W7_COD_I))
      IF SW1->W1_CLASS # MCLASS
         RETURN .F.
      ENDIF
   ENDIF
ENDIF

IF lTabPoNum   // caso .t. carrega tabela aPOnum
   TPC253TBpo()
ENDIF

FOR I:=1 TO IF(lTabPoNum,LEN(aPOnum),1)

   IF lTabPoNum
     TPO := aPOnum[I]
   ELSE
     SW7->(DBSETORDER(1))
     SW7->(DBSEEK(xFilial("SW7")+ SWD->WD_HAWB))
     TPO := SW7->W7_PO_NUM
   ENDIF  
    SW2->(DBSEEK(xFilial()+TPO))
    SA2->(DBSEEK(xFilial()+SW2->W2_FORN))
    cForn_N := SA2->A2_NOME        //  JBS - 03/09/2003
    cForn_R := SA2->A2_NREDUZ      //  JBS - 03/09/2003
    cForn_Cod:= SA2->A2_COD + " - " + Alltrim(SA2->A2_NREDUZ)

    IF !EMPTY(TImport) .AND. TImport # SW2->W2_IMPORT
       LOOP
    ENDIF

//    TPO_NUM:=IF(lTabPoNum,aPOnum[I],TPO_NUM)
    TPO_NUM:=IF(lTabPoNum,aPOnum[I],TPO)    //acb - 03/08/2010
    IF MORDEM == _PO
       MSOMA:=0

       SW8->(DBSETORDER(3))
       SW9->(DBSETORDER(1))
       SW7->(DBSETORDER(2))
       SW7->(DBSEEK(xFILIAL()+TPO_NUM+SWD->WD_HAWB ) )
       DO WHILE SW7->(! EOF())                 .AND.;
                SW7->W7_FILIAL == cFilSW7      .AND.;
                SW7->W7_HAWB   == SWD->WD_HAWB .AND.;
                SW7->W7_PO_NUM == TPO_NUM 

          IF SW8->(DBSEEK(cFilSW8+SW7->W7_HAWB+SW7->W7_PGI_NUM+SW7->W7_PO_NUM+SW7->W7_SI_NUM+AvKey(SW7->W7_CC, "W8_CC")+SW7->W7_COD_I+STR(SW7->W7_REG,4,0)))
             DO WHILE !SW8->(EOF()) .AND.;
                       SW8->W8_HAWB    == SW7->W7_HAWB    .AND. SW8->W8_COD_I  == SW7->W7_COD_I  .AND.;
                       SW8->W8_PGI_NUM == SW7->W7_PGI_NUM .AND. SW8->W8_SI_NUM == SW7->W7_SI_NUM .AND.;
                       SW8->W8_CC      == AvKey(SW7->W7_CC, "W8_CC") .AND. SW8->W8_REG    == SW7->W7_REG    .AND.;
                       SW8->W8_PO_NUM  == SW7->W7_PO_NUM  .AND. SW8->W8_FILIAL == cFilSW8

                 /*//TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
                 SW9->(DBSEEK(cFILSW9+SW8->W8_INVOICE+SW8->W8_FORN+SW8->W8_HAWB))*/
                 
                 SW9->(DBSEEK(cFILSW9+SW8->W8_INVOICE))
                 MSOMA+=(SW8->W8_PRECO*SW8->W8_QTDE)*SW9->W9_TX_FOB
                 SW8->(DBSKIP())
  
              ENDDO
          ENDIF
          IF lTemSelo  .AND. SB1->(DBSEEK(cFilSB1+SW7->W7_COD_I))
             MSELO+=SW7->W7_QTDE*SB1->B1_VLRSELO
          ENDIF

          SW7->(DBSKIP())
       ENDDO

       IF MSOMA == 0 
          RETURN .F.
       ELSE
          MFOBREPRES:=0
          IF SW6->(DBSEEK(xFILIAL()+SWD->WD_HAWB))
             MFOBREPRES:=(MSOMA/SW6->W6_FOB_TOT)
          ENDIF   
          IF !(lTemSelo .AND. cDespSelo == SWD->WD_DESPESA)
             MFOBREPRES:=(SWD->WD_VALOR_R * MFOBREPRES)
          ELSE
             MFOBREPRES:= MSELO
          ENDIF  
          IF MFOBREPRES == 0
             RETURN .F.
          ENDIF                                      
       ENDIF

    ENDIF
/*    IF MORDEM == _PO
       lAchou := Work->(DBSEEK(TPO_NUM+DTOS(SWD->WD_DES_ADI)+SWD->WD_DESPESA))
    ELSE
       lAchou := Work->(DBSEEK(SWD->WD_DESPESA+DTOS(SWD->WD_DES_ADI) +SWD->WD_HAWB))
    ENDIF*/

//    IF !lAchou  
       // TDF - 25/02/2011 - Posiciona no fornecedor da despesa
       SA2->(DBSEEK(xFilial()+SWD->WD_FORN))   // JBS - 03/09/2003 
       cForn_Cod2:= SA2->A2_COD + " - " + Alltrim(SA2->A2_NREDUZ)
        
       Work->( DBAPPEND() )
       Work->WKDT_PAGTO := SWD->WD_DES_ADI
       Work->WKDESPESA  := SWD->WD_DESPESA
       Work->WKPO_NUM   := TPO_NUM
       Work->WKDESPDESC := IF(SYB->(DBSEEK(xFILIAL()+SWD->WD_DESPESA)),SYB->YB_DESCR,SPACE(2) )
       Work->WKFORN_N   := IF(SWD->WD_DESPESA=="101",cForn_N,SA2->A2_NOME)  // JBS - 03/09/2003
       Work->WKFORN_R   := IF(SWD->WD_DESPESA=="101",cForn_Cod,cForn_Cod2) // TDF - 25/02/2011
       //Work->WKFORN_R   := IF(SWD->WD_DESPESA=="101",cForn_R,SA2->A2_NREDUZ )  // JBS - 03/09/2003
       Work->WKDT_EMB   := SW6->W6_DT_EMB//acb 03/08/2010
       Work->WKCONDICAO := If(empty(SWD->WD_COND),SW2->W2_COND_PA,SWD->WD_COND)//acb 03/08/2010
       Work->WK_HAWB    := SWD->WD_HAWB
       Work->WKFOBPERC  := nFobPerc // TDF - 13/08/2010
       If Empty(dDt2) .or. Empty(dDt1)
          Work->WKFOBDIAS  := 0 // TDF - 17/08/2010
       Else
          Work->WKFOBDIAS  := dDt1 - dDt2 // TDF - 13/08/2010
       EndIf 
       
       If(EasyEntryPoint("EICTP253"),ExecBlock("EICTP253",.F.,.F.,"GRAVA_WORK"),) // RA - 15/08/2003
  //  ENDIF

    Work->WKVL_PAGTO += IF(MOrdem =_PO,MFOBREPRES,SWD->WD_VALOR_R)

NEXT

RETURN

*-----------------------------------------------*
FUNCTION TPC253Datas(TDT_I,TDT_F,MSubTit)
*-----------------------------------------------*
WHILE .T.
        /*
        IF ! Pergunte("EIC010",.T.)
           RETURN .F.
        ENDIF
*/
		IF !Pergunte("EICDI3",.T.)      //NCF - 03/04/2009 - Alterado o para o Pergunte correto
           RETURN .F.
        ELSE
           If !EICDATA_VAL()           //Valid dos valores de datas.
              Loop
           EndIf       
        ENDIF 

        TDT_I:=mv_par01
        TDT_F:=mv_par02

        IF EMPTY(TDT_I)
           IF EMPTY(TDT_F)
           ELSE
              TDT_I:=AVCTOD('01/01/'+_FirstYear)
           ENDIF
           EXIT
        ENDIF

        IF EMPTY(TDT_F)
           TDT_F:=AVCTOD('31/12/49')
        ENDIF

        IF TDT_I > TDT_F
           HELP("",1,"AVG0000590") //'DATA INICIAL MAIOR QUE DATA FINAL'
           LOOP
        ENDIF
        MSubTit+=STR0031+DTOC(TDT_I)+STR0032+DTOC(TDT_F) //' - no periodo de '###" ate "
        EXIT
ENDDO
RETURN .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥TPC253Print≥ Autor ≥ ROBSON/AVERAGE        ≥ Data ≥ 30.06.97 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Impressao do Desembolso Realizado                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ SIGAEIC                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION TPC253Print(M_Total,MTipo,MOrdem,MDt_I,MDt_F,MSubTit)

LOCAL wnrel    := "EICTP253"
LOCAL cDesc1   := STR0033 //"Impressao do Relatorio de Desembolso Realizado"
LOCAL cDesc2   := MSubTit
LOCAL cDesc3   := " "
LOCAL cString  := "Work"
LOCAL cRegAnt  := Recno()

PRIVATE tamanho :="G"
PRIVATE Titulo  :=STR0001 //"Desembolso Realizado"
PRIVATE aReturn := { "Zebrado", 1,"Importacao", 2, 2, 1, "",0 }
PRIVATE	limite := 220
PRIVATE nomeprog:="EICTP253",nLastKey := 0,nBegin:=0,aLinha:={ }
PRIVATE aDriver :=ReadDriver()
PRIVATE cPerg   :=NIL

wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho,,.F.)

If nLastKey == 27
   Return
Endif

aReturn[4] := 2 
If aReturn[4] == 1// Comprimido
   @ 001,000 PSAY &(aDriver[1])
ElseIf aReturn[4] == 2// Normal
   @ 001,000 PSAY &(aDriver[2])
EndIf
SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

aMemo:={}

RptStatus({|lEnd| TPC253Rel(@lEnd,wnRel,cString,M_Total,MTipo,MOrdem,MDt_I,MDt_F)},Titulo)

Work->(DBGOTO(cRegAnt))
Return

*---------------------------------------------------------------------*
FUNCTION TPC253REL(lEnd,wnRel,cString,M_Total,MTipo,MOrdem,MDt_I,MDt_F)
*---------------------------------------------------------------------*
PRIVATE TDt_I := MDt_I ; TDt_F := MDt_F ; M_Pri:= .F.

limite := 130;li:= 80
MPag   := 0;MLin:= 60

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta a Regua                                                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
SetRegua(Work->(LASTREC()))

MLin    := 0
MPag    := 0
MConta  := 1
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Compoe o Driver de Impressao                                      ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//aDriver :=ReadDriver()
//If aReturn[4] == 1// Comprimido
//   @ 001,000 PSAY &(aDriver[1])
//ElseIf aReturn[4] == 2// Normal
//   @ 001,000 PSAY &(aDriver[2])
//EndIf
//@ 001,000 PSAY &(aDriver[1])

IF MTipo == _Analitico
   TPC253Ana(MOrdem,MDt_I,MDt_F,M_Total,MTipo,lEnd)
ELSE
// TPC253Sin(MOrdem,MDt_I,MDt_F,M_Total,MTipo,lEnd)
ENDIF

Set Device to Screen
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Se em disco, desvia para Spool                               ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
   Set Printer TO
   Commit
   OurSpool(wnrel)
Endif
MS_FLUSH()
Return .T.

*-------------------------------------------------------*
FUNCTION TPC253Ana(POrdem,MDt_I,MDt_F,M_Total,MTipo,lEnd)
*--------------------------------------------------------*
LOCAL   Indice:=0
PRIVATE TDt_I := MDt_I , TDt_F := MDt_F , MOrdem:= POrdem, TB_DtPos:={}

MPag := 0 ; MLin := 90 ; MTotal_1:= MTotal_2 := MCont_1 := MCont_2 := 0

nMemo:=1

nCol0:=021
nColA:=34//nCol0+13
nCol1:=nCol0+37 //032
nCol2:=nCol1+6  //037
nCol3:=nCol2+34 //071
nCol4:=nCol3+23 //094

Work->(DBGOTOP())

IF MOrdem == 1
   MPo_Ant   := WKPO_NUM
   MTexto    := STR0034 + IF(EMPTY(TPO_NUM),STR0035,TRAN(TPO_NUM,_PictPo)) + " )" //"Analitico - Por P.O. ( "###'Todos'
   MDizTot2  := STR0036 //"TOTAL DO DIA.....................:"
   MDizTot1  := STR0037 //"TOTAL DO P.O.....................:"
ELSE
   MDesp_Ant := WKDESPESA
   IF TDESP $ "203"
      MTexto:= STR0038 + IF(EMPTY(TDESP),STR0039,TRANSF(TDESP,'@R 9.99')) +" "+ALLTRIM(MCLASSNOME)+" )" //"Analitico - Por Despesa ( "###'Todas'
   ELSE
      MTexto:= STR0038 + IF(EMPTY(TDESP),STR0039,TRANSF(TDESP,'@R 9.99')) + " )" //"Analitico - Por Despesa ( "###'Todas'
   ENDIF
   MDizTot2  := STR0040 //"TOTAL DO DIA..............:"
   MDizTot1  := STR0041 //"TOTAL DA DESPESA..........:"
ENDIF
MDt_Ant := WKDT_PAGTO

MBate_1 := MBate_2 := .T.

DO WHILE ! WORK->(EOF())

   IncRegua()

   If lEnd
      @PROW()+1,001 PSAY STR0042 //"CANCELADO PELO OPERADOR"
      Exit
   Endif

   IF MLin > 58
      TPC253AnaCab()
   ENDIF

   IF MOrdem == 1
      IF MPo_Ant # WKPO_NUM
         TPC253QbAna(MDizTot2,MDizTot1,nCol1,nCol3,'G')
         MPo_Ant := WKPO_NUM
         MDt_Ant := WKDT_PAGTO
      ENDIF
      IF MDt_Ant # WKDT_PAGTO
         TPC253QbAna(MDizTot2,MDizTot1,nCol1,nCol3,'S')
         MDt_Ant := WKDT_PAGTO
         MLin +=1
      ENDIF
   ELSE
      IF MDesp_Ant # WKDESPESA
         TPC253QbAna(MDizTot2,MDizTot1,nColA+20,nCol3-10,'G')
         MDesp_Ant := WKDESPESA
         MDt_Ant := WKDT_PAGTO
      ENDIF
      IF MDt_Ant # WKDT_PAGTO
         TPC253QbAna(MDizTot2,MDizTot1,nColA+20,nCol3-10,'S')
         MDt_Ant := WKDT_PAGTO
         MLin +=1
      ENDIF
   ENDIF

   TPC253AnaDet()
   WORK->(DBSKIP())
ENDDO

M_TOTAL:=0
WORK->(DBGOTOP())
Work->(DBEVAL({||M_total+=WKVL_PAGTO},,{||!EOF()})) 

IF MPag > 0
   IF MOrdem == 1
      TPC253QbAna(MDizTot2,MDizTot1,nCol1,nCol3,'G')
      IF EMPTY(TPO_NUM)
         MLin +=1
         @MLin,nCol1 PSAY  STR0043 //"TOTAL GERAL......................:"
         @MLin,nCol3 PSAY  TRAN(M_Total,"@E 999,999,999,999.99")//M_TOTAL
      ENDIF

   ELSE
      TPC253QbAna(MDizTot2,MDizTot1,nColA+20,nCol3-10,'G')
      IF EMPTY(TDESP)
         MLin +=1
         @MLin,nColA+20 PSAY STR0044 //"TOTAL GERAL...............:"
         @MLin,nCol3-10 PSAY TRAN(M_Total,"@E 999,999,999,999.99")
      ENDIF
   ENDIF

//  EJECT

ENDIF

*----------------------*
FUNCTION TPC253AnaCab()
*----------------------*
aDriver:=ReadDriver()
MPag ++ ; MLin:= 1
@ 0,0 PSAY &(aDriver[5])
If(EasyEntryPoint("EICTP253"),ExecBlock("EICTP253",.F.,.F.,"CAB_REL"),) // RA - 15/08/2003
TPC252CabRel(220,Tit253,MPag,MTexto)
MLin +=1

IF EMPTY(TImport)
   @MLin,001 PSAY STR0045 + STR0046 //"Importador.: "###"Geral"
ELSE
   @MLin,001 PSAY STR0045 + TImport + " " + SYT->YT_NOME //"Importador.: "
ENDIF
MLin +=1

IF MOrdem == 1
   @++MLin,001   PSAY STR0047 //'No. P.O.'
   @  MLin,nCol0 PSAY STR0048 //'Data'
   @  MLin,nColA PSAY STR0049 //'Processo'
   @  MLin,nCol1 PSAY STR0050 //'Despesa'
   @  MLin,nCol3 PSAY STR0051 //'          Valor R$'
   lTraco := .F.
   If(EasyEntryPoint("EICTP253"),ExecBlock("EICTP253",.F.,.F.,"IMP_CAB"),) // RA - 15/08/2003
   @  MLin,nCol4 PSAY STR0052 //'Fornecedor'
   @++MLin,001   PSAY '---------------'
   @  MLin,nCol0 PSAY '-------'
   @  MLin,nColA PSAY '-----------------'
   @  MLin,nCol1 PSAY '-----------------------------------'
   @  MLin,nCol3 PSAY '------------------'
   lTraco := .T.
   If(EasyEntryPoint("EICTP253"),ExecBlock("EICTP253",.F.,.F.,"IMP_CAB"),) // RA - 15/08/2003
   @  MLin,nCol4 PSAY '---------------'
ELSE
// @++MLin,001 PSAY STR0053 //'Despesa                                Data                                     Valor R$    Fornecedor'
// @++MLin,001 PSAY '-----------------------------------    --------    -------------------------------------    -------------------------------------------'
   @++MLin,001      PSAY STR0050 //'Despesa'
   @  MLin,nCol0+20 PSAY STR0048 //'Data'
   @  MLin,nColA+20 PSAY STR0049 //'Processo'
   @  MLin,nCol3-10 PSAY STR0051 //'          Valor R$'
   lTraco := .F.
   If(EasyEntryPoint("EICTP253"),ExecBlock("EICTP253",.F.,.F.,"IMP_CAB"),) // RA - 15/08/2003
   @  MLin,nCol4-10 PSAY STR0052 //'Fornecedor'
   @++MLin,001      PSAY '-----------------------------------'
   @  MLin,nCol0+20 PSAY '---------'
   @  MLin,nColA+20 PSAY '----------------------'
   @  MLin,nCol3-10 PSAY '------------------'
   lTraco := .T.
   If(EasyEntryPoint("EICTP253"),ExecBlock("EICTP253",.F.,.F.,"IMP_CAB"),) // RA - 15/08/2003
   @  MLin,nCol4-10 PSAY '----------------------'
ENDIF

MBate_1 := MBate_2 := .T.

*Ordem Data
*Data        Despesa                                No. P.O.                     Valor R$   Tabela    Fornecedor         Embarque    Condicao Pagamento
*--------    -----------------------------------    ---------------    ------------------    ------    ---------------    --------    --------------------------------------------
*99/99/99    9.99 zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz    999999999999999    999,999,999,999.99     9999     zzzzzzzzzzzzzzz    99/99/99    9.9.999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*1           13                                     52                 71                    93        103                122         134
*
*Ordem P.O.
*No. P.O.           Data        Despesa                                          Valor R$    Fornecedor         Tabela    Embarque    Condicao Pagamento
*---------------    --------    -----------------------------------    ------------------    ---------------    ------    --------    --------------------------------------------
*999999999999999    99/99/99    9.99 zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz    999,999,999,999.99    zzzzzzzzzzzzzzz     9999     99/99/99    9.9.999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*1                  20          32                                     71                    93                 112       122         134
*
*Ordem Despesa
*Despesa                                Data        No P.O.                      Valor R$    Tabela    Fornecedor         Embarque    Condicao Pagamento
*-----------------------------------    --------    ---------------    ------------------    ------    ---------------    --------    --------------------------------------------
*9.99 zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz    99/99/99    zzzzzzzzzzzzzzz    999,999,999,999.99     9999     zzzzzzzzzzzzzzz    99/99/99    9.9.999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*1                                      40          52                 71                    93        103                122         134

RETURN
*-----------------------*
FUNCTION TPC253AnaDet()
*-----------------------*
IF MOrdem == 1
   IF MBate_1
      MlinAux:=MLin
      MLin +=1
      @MLin,001 PSAY TRAN(WKPO_NUM,_PictPo)
      MBate_1 := .F.
   ENDIF
   IF MBate_2
      @MLin,nCol0  PSAY DTOC(WKDT_PAGTO)
      MBate_2 := .F.
   ENDIF
   
   @MLin,34    PSAY  Work->WK_HAWB
   @MLin,nCol1 PSAY  TRAN(Work->WKDESPESA,"@R 9.99")
   @MLin,nCol2 PSAY  Work->WKDESPDESC
   @MLin,nCol3 PSAY  TRAN(Work->WKVL_PAGTO,"@E 999,999,999,999.99")
   If(EasyEntryPoint("EICTP253"),ExecBlock("EICTP253",.F.,.F.,"APOS_IMP_VAL"),) // RA - 15/08/2003
   
   //IF(Work->WKDESPESA == DESPESA_FOB,TPC253DetFob(),)
   // TDF - 25/02/2011 - Impress„o do fornecedor para todas as despesas
   TPC253DetFob()
   
ELSE
   IF MBate_1
      MLin +=1
      @MLin,001 PSAY TRAN(WKDESPESA,"@R 9.99")
      @MLin,006 PSAY WKDESPDESC
      MBate_1 := .F.
   ENDIF
   IF MBate_2
      @MLin,nCol0+20 PSAY WKDT_PAGTO 
      MBate_2:= .F.
   ENDIF
   @MLin,nColA+20 PSAY Work->WK_HAWB
   @MLin,nCol3-10 PSAY TRAN(WKVL_PAGTO,"@E 999,999,999,999.99")
   
   lMostraForn := .T. // JBS - 03/09/2003 - O RDM podera mudar para .F., para nao mostrar o fornecedor
   
   If(EasyEntryPoint("EICTP253"),ExecBlock("EICTP253",.F.,.F.,"APOS_IMP_VAL"),) // RA - 15/08/2003
   
   if lMostraForn
      //IF(WKDESPESA == DESPESA_FOB,TPC253DetFob(),)
      // TDF - 25/02/2011 - Impress„o do fornecedor para todas as despesas
      TPC253DetFob()
   endif
ENDIF

MTotal_1+= WKVL_PAGTO
MTotal_2+= WKVL_PAGTO
MCont_1 ++
MCont_2 ++
MLin++

RETURN

*---------------------------------------------------------*
FUNCTION TPC253QbAna(MTexto2,MTexto1,MCol1,MCol2,MGer_Sub)
*---------------------------------------------------------*
IF MGer_Sub == 'G'
   IF MCont_1 > 1
      IF MCont_2 > 1
         @MLin,MCol2 PSAY REPLI('-',18)
         MLin +=1
         @MLin,MCol1 PSAY MTexto2
         @MLin,MCol2 PSAY TRAN(MTotal_2,'@E 999,999,999,999.99')
      ENDIF

      MLin +=1
      @MLin,MCol1 PSAY MTexto1
      @MLin,MCol2 PSAY TRAN(MTotal_1,'@E 999,999,999,999.99')
      MLin += 1
      
   ENDIF
   
   MTotal_2  := MTotal_1:=  MCont_2:= MCont_1:= 0
   MBate_2   := MBate_1 := .T.; nMemo:= 1
ELSE
   IF EMPTY(TDESP)
      IF MCont_1 > 1
         @MLin,MCol2  PSAY REPLI('-',18)
         MLin +=1
         @MLin,MCol1  PSAY MTexto2
         @MLin,MCol2  PSAY TRAN(MTotal_2,'@E 999,999,999,999.99')
         MLin += 1
      ENDIF  
   ELSE
      IF MCont_1 >= 1
         @MLin,MCol2  PSAY REPLI('-',18)
         MLin +=1
         @MLin,MCol1  PSAY MTexto2
         @MLin,MCol2  PSAY TRAN(MTotal_2,'@E 999,999,999,999.99')
         MLin += 1
      ENDIF     
   ENDIF
   MTotal_2 := MCont_2 := 0 ; MBate_2 := .T.
ENDIF
RETURN

*----------------------------------------------------------------------------*
FUNCTION TPC253DetFob()
*----------------------------------------------------------------------------*
IF MOrdem = 1 
   @MLin,nCol4 PSAY Work->WKFORN_R
ELSE
   @MLin,nCol4-10 PSAY Work->WKFORN_R
ENDIF

*--------------------*
FUNCTION TPC253TBpo()
*--------------------*
aPOnum:={}
IF EMPTY(TPO_NUM)
   SW7->(DBSETORDER(1) )
   SW7->(DBSEEK(cFilSW7+SWD->WD_HAWB) )
   DO WHILE SW7->(! EOF())           .AND. ;
            SW7->W7_FILIAL== cFilSW7 .AND. ;
            SW7->W7_HAWB  == SWD->WD_HAWB
      IF ASCAN(aPOnum,SW7->W7_PO_NUM )=0
         AADD(aPOnum ,SW7->W7_PO_NUM)
      ENDIF
      SW7->( DBSKIP() )
   ENDDO
ELSE
   SW7->(DBSETORDER(2) )
   SW7->(DBSEEK(cFilSW7+TPO_NUM) )
   DO WHILE SW7->(! EOF())           .AND. ;
            SW7->W7_FILIAL== cFilSW7 .AND. ;
            SW7->W7_PO_NUM==TPO_NUM  
            
      IF ASCAN(aPOnum,SW7->W7_PO_NUM )=0
         AADD(aPOnum ,SW7->W7_PO_NUM)
      ENDIF
      SW7->( DBSKIP() )
   ENDDO
ENDIF
RETURN


*-----------------------------------------------------*
FUNCTION  TPC253class(L1,MCLASS,MCLASSNOME,lDespICMS)
*-----------------------------------------------------*
LOCAL TClassOp:=0, nOpca:=0, cDesp:=TDesp+'-'+SYB->YB_DESCR
LOCAL TB_Opcoes := {}

cClass:=" "

DEFINE MSDIALOG oDlgClass TITLE cCadastro+STR0057 From 7,0 To 18,50 OF oMainWnd //" - Classificacao"

@ 26,20 SAY STR0006 SIZE 40,8 PIXEL //"Despesa"
@ 26,44 MSGET cDesp WHEN .F. SIZE 80,8 PIXEL

@ 39,20 SAY STR0058 SIZE 40,8 PIXEL //"Tipo"
@ 39,44 MSGET cClass F3 "EY2" OF oDlgClass SIZE 10,08 VALID TPCValClass() PIXEL
//@ 3,5.5 COMBOBOX oCbx VAR cClass ITEMS TB_Opcoes OF oDlgClass SIZE 70,30

ACTIVATE MSDIALOG oDlgClass ON INIT;
         EnchoiceBar(oDlgClass,{||IF(TPCValClass(), (nOpca:=1,oDlgClass:End()) ,)},;
                               {||nOpca:=0,oDlgClass:End()}) CENTERED

IF nOpca == 0
   TClassOp:=0
   RETURN .T.
ENDIF

TClassOp:=VAL(LEFT(cClass,1))
lDespICMS:=!TClassOp==0
MCLASS   :=IF(TClassOp==0,"",STR(TClassOp,1))

SX5->(DBSEEK(xFilial()+"Y1"+cClass))
MCLASSNOME:=X5DESCRI()

RETURN .F.

*--------------------*
FUNCTION TPCValClass()
*--------------------*
IF !EMPTY(cClass)
   IF !ALLTRIM(cClass) $ "12345"
      HELP("",1,"AVG0000597") //"Tipo n∆o cadastrado"

      RETURN .F.
   ENDIF
ENDIF

RETURN .T.  
