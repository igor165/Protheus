#INCLUDE "Eictr500.ch"
#include "AVERAGE.CH"
//#include "FiveWin.ch"

#COMMAND E_RESET_AREA => SA5->(DBSETORDER(1)) ; SY9->(DBSETORDER(1))   ;
                         ; Work->(E_EraseArq(WorkFile)) ;
  	                     ; DBSELECTAREA(nOldArea)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR500 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 02.10.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lead Time                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR500()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTR500()

EICTR500R3(.T.)
Return .t.

Function EICTR500R3(p_R4)
LOCAL WorkFile, nOldArea:=SELECT(), cSubTit:=""
LOCAL _PictItem := ALLTRIM(X3Picture("B1_COD"))
LOCAL cSaveMenuh, nCnt, cTitulo, oDlg, oPanel ,oGet, nOpcA:=0, bMsg
LOCAl QData:="", TData:=dDataBase,;
      TCod_I:=SA5->A5_PRODUTO, TForn:=SA5->A5_FORNECE

LOCAL T_DBF:={{ "WKVIA"      , "C" , 15 , 0 } ,;
               { "WKORI_DES"  , "C" , 07 , 0 } ,;
               { "WKDT_SI"    , "D" , 08 , 0 } ,;
               { "WKDT_PO"    , "D" , 08 , 0 } ,;
               { "WKDT_EMB"   , "D" , 08 , 0 } ,;
               { "WKDT_ATR"   , "D" , 08 , 0 } ,;
               { "WKDT_DES"   , "D" , 08 , 0 } ,;
               { "WKDT_ENT"   , "D" , 08 , 0 } ,;
               { "WKLEAD"     , "N" , 06 , 0 } ,;
               { "WKFABR"     , "C" , AVSX3("A2_COD",3)+AVSX3("A2_NREDUZ",3) , 0 } ,;
               { "WKFORN"     , "C" , AVSX3("A2_COD",3)+AVSX3("A2_NREDUZ",3) , 0 } }

//FSM - 03/08/2011
If EICLoja()
   aAdd(T_DBF,{ "WKFORLOJ" , AVSX3("A2_LOJA",AV_TIPO), AVSX3("A2_LOJA",AV_TAMANHO), AVSX3("A2_LOJA",AV_DECIMAL) })
   aAdd(T_DBF,{ "WKFABLOJ" , AVSX3("A2_LOJA",AV_TIPO), AVSX3("A2_LOJA",AV_TAMANHO), AVSX3("A2_LOJA",AV_DECIMAL) })
EndIf
   

PRIVATE TB_Campos:={}//igorchiba 01/07/2010 alterar nos pontos entrada
PRIVATE aRCampos :={} //igorchiba 01/07/2010 alterar nos pontos entrada
PRIVATE cMarca   := GetMark(), lInverte := .F.
PRIVATE cCadastro := STR0001 //"Lead Time"
PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
PRIVATE aHeader[0],nUsado:=0, lEmail := .F.
PRIVATE lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()

bCampo  := {|nCPO| Field(nCPO) }

aDados :={"Work",;
          STR0030,; //"Este relatorio irá  Imprimir Lead Time"
          "",;
          "",;
          "G",;
          180,;
          "",;
          "",;
          STR0001,; //"Lead Time"
          { "Zebrado", 1,"Importação", 1, 2, 1, "",1 },;
          "EICTR500",;
          ""  }


IF TYPE("__cInternet") # "U" .AND. __cInternet # NIL
   lEmail:= .T.
   E_Init()
ENDIF

SY9->(DBSETORDER(2))
SA5->(DBSETORDER(2))
SB1->(DBSETORDER(1))

WorkFile := E_CriaTrab(,T_DBF,"Work") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("Work",WorkFile+TEOrdBagExt(),"WKVIA+WKFORN+WKORI_DES")

DO WHILE .T.      
   IF !Pergunte("EIR500", IF(!lEmail,.T.,.F.) )
      EXIT
   ENDIF            
   
   IF lEmail
      aReturn   := aDados[10]
      aDados[11]:= SetPrint(aDados[1],aDados[11],,@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
   ENDIF

   QData  := VAL(MV_PAR01)
   TData  := MV_PAR02    
   TCod_I := MV_PAR03
   TForn  := MV_PAR04 
   TForLoj:= mv_par05

    ASIZE(TB_Campos,0)
    ASIZE(aRCampos,0)
    AADD(TB_Campos,{"WKVIA","",STR0018}) //"Via Transporte"
		
    IF !EMPTY(TCod_I)
       IF EMPTY(TForn)  .and. IIF(EICLoja(),Empty(TForLoj),.T.)   // GFP - 02/08/2013
          AADD(TB_Campos,{"WKFORN","",STR0017}) //"Fornecedor"
          IF EICLoja()
             AADD(TB_Campos,{"WKFORLOJ",,"Loja Forn."})
          EndIf
       ENDIF
       AADD(TB_Campos,{"WKFABR","",STR0019}) //"Fabricante"
       If EICLoja()
          AADD(TB_Campos,{"WKFABLOJ","","Loja Fabr."})
       EndIf
    ENDIF
		
    AADD(TB_Campos,{"WKORI_DES","",STR0020}) //"Origem/Destino"
    AADD(TB_Campos,{"WKDT_SI"  ,"",STR0021}) //"Data S.I."
    AADD(TB_Campos,{"WKDT_PO"  ,"",STR0022}) //"Data P.O."
    AADD(TB_Campos,{"WKDT_EMB" ,"",STR0023}) //"Embarque"
    AADD(TB_Campos,{"WKDT_ATR" ,"",STR0024}) //"Atracação"
    AADD(TB_Campos,{"WKDT_DES" ,"",STR0025}) //"Desembaraço"
    AADD(TB_Campos,{"WKDT_ENT" ,"",STR0026}) //"Entrega"
    AADD(TB_Campos,{"WKLEAD"   ,"",STR0001}) //"Lead Time"
		
    IF !EMPTY(TCod_I) .AND. (EMPTY(TForn) .And. IIF(EICLoja(),EMPTY(TForLoj),.T.))
       aDados[4]:=STR0027 +TRANS(TCod_I,_PictItem) //"Item.: "
    ELSEIF ! EMPTY(TCod_I) .AND. (! EMPTY(TForn).And. IIF(EICLoja(),!EMPTY(TForLoj),.T.))
       aDados[4]:=STR0027 +TRANS(TCod_I,_PictItem)+STR0028+BuscaFabr_Forn(TFORN+IIF(EICLoja(),TForLoj,"")) //"Item.: "###" / Fornecedor.: "
    ENDIF
		
    IF !EMPTY(TCod_I)
       R_Funcoes:={ {||TR500Qb("D")},{||TR500Qb("F")} }
    ELSE
       R_Funcoes:={ {|| .T.},{|| .T.} }
    ENDIF
    aDados[12]:= { R_Funcoes[1], R_Funcoes[2]  }
    aRCampos:=E_CriaRCampos(TB_Campos,"C")
		
    cTitulo := IF(SX5->(dbSeek(xFilial()+"YG"+STR(QData,1))), ALLTRIM(SX5->X5_Descri), "" )

    IF lEmail
       TR500Grava(,TData,QData,TCod_I,TForn,TForLoj)
       IF Work->(Easyreccount("Work")) > 0
          E_Report(aDados,aRCampos,,.F.)
       ENDIF
       EXIT
    ELSE    
       bMsg:={|msg| MsProcTxt(msg)}
       Processa({|lEnd| TR500Grava(bMsg,TData,QData,TCod_I,TForn,TForLoj)} )
		
       IF Work->(Easyreccount("Work")) > 0
          oMainWnd:ReadClientCoors()
          
          lPadrao :=.T.
          IF(EasyEntryPoint("EICTR500"),Execblock("EICTR500",.F.,.F.,"ANT_TELA"),)//igorchiba 01/07/2010 burlar tela
          
          IF lPadrao //chiba
             DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+cTitulo ;
	         From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL
             
             @ 00,00 MsPanel oPanel Prompt "" Size 60,20 of oDlg      //LRL 28/04/04
             //DEFINE SBUTTON FROM 03,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (If(lR4,(oReport := ReportDef(),oReport:PrintDialog()),E_Report(aDados,aRCampos))) ENABLE OF oPanel
		  
		     @ 0.4,0.5 SAY STR0016 of oPanel //"Código do Item"
		     @ 0.4,6   MSGET TCod_I SIZE 107,10 WHEN .F. of oPanel
		     @ 0.4,20  SAY STR0017 of oPanel //"Fornecedor"
		     @ 0.4,25  MSGET TForn  SIZE 50,10 WHEN .F. of oPanel
		     @ 0.4,35  SAY "Loja Forn" of oPanel //"Loja Fornecedor" //FSM - 03/08/2011 - Ajuste no posicionamento do campo
             @ 0.4,40  MSGET TForLoj  SIZE 50,10 WHEN .F. of oPanel   
		     DEFINE SBUTTON FROM 03,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (If(lR4,(oReport := ReportDef(),oReport:PrintDialog()),E_Report(aDados,aRCampos))) ENABLE OF oPanel // TLM 08/11/2007
		
		     oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{34,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
			 
			 oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT             
	         oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
			 
             ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
	                                                         {||nOpca:=0,oDlg:End()}))  //LRL 28/04/04 //Alinhamento MDI  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
          
          ELSE      
             IF(EasyEntryPoint("EICTR500"),Execblock("EICTR500",.F.,.F.,"GERTELA"),)//igorchiba 01/07/2010 manipular tela customizada
          
          ENDIF
          
          If nOpca = 0
             EXIT
          Endif
       ELSE
          Help(" ",1,"EICSEMREG")
       ENDIF
    ENDIF
ENDDO
E_RESET_AREA
Return .F.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR500Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 01.10.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR500Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICSIGA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------------------------------------------------------
STATIC FUNCTION TR500Grava(bMsg,TData,QData,TCod_I,TForn,TForLoj)
*----------------------------------------------------------------------------
LOCAL nTot, nRec:=0

Work->(avzap())

SYR->(dbSeek(xFilial())) ; nTot:=SYR->(Easyreccount("SYR"))
    
IF !lEmail
   ProcRegua(nTot)
ENDIF

SYR->(DBEVAL({|| IF(!lEmail,IncProc(),), TR500Grv(TData,QData,TCod_I,TForn,TForLoj) },,{||YR_FILIAL == xFilial("SYR")} ))

dbSelectArea("Work")
dbGoTop()
Return .T.

*----------------------------------------------------------------------------
FUNCTION TR500Grv(TData,QData,TCod_I,TForn,TForLoj)
*----------------------------------------------------------------------------
LOCAL data_si:=data_po:=data_emb:=data_atr:=data_des:=data_ent:=AVCTOD(''),Prazo:=0
LOCAL cOrigem

IF EMPTY(SYR->YR_PAIS_OR)//ASR - 14/10/2005 - QUANDO O PAIS DE ORIGEM ESTIVER VAZIO A ROTA É DE EXPORTAÇÃO E NÃO É MOSTRADO
	RETURN .T.
ENDIF

SY9->(DBSEEK(xFilial()+SYR->YR_DESTINO))

IF ! EMPTY(TCod_I)
   IF (! EMPTY(TForn) .And. IIF(EICLoja(),!EMPTY(TForLoj),.T.))
      SA5->(DBSEEK(xFilial()+TCod_I+TForn))
      //EICSFabFor(xFilial("SA5")+TCod_I+TForn, , TForLoj) - FSM - 03/08/2011
   ELSE
      SA5->(DBSEEK(xFilial()+TCod_I))
   ENDIF

   DO WHILE ! SA5->(EOF()) .AND. SA5->A5_PRODUTO == TCod_I .AND. SA5->A5_FILIAL == xFilial("SA5")
      IF (! EMPTY(TForn) .And. IIF(EICLoja(),!EMPTY(TForLoj),.T.)) .AND. (TForn # SA5->A5_FORNECE .And. IIF(EICLoja(),TForLoj # SA5->A5_LOJA,.T.))
         EXIT
      ENDIF

      SA2->(DBSEEK(xFilial()+SA5->A5_FORNECE+EICRetLoja("SA5","A5_LOJA")))
      cOrigem:=SA2->A2_ORIG_1+SA2->A2_ORIG_2+SA2->A2_ORIG_3

      IF AT(SYR->YR_ORIGEM,cOrigem) == 0
         SA5->(DBSKIP()) ; LOOP
      ENDIF
      
      lLoop:=.F.//chiba
      IF(EasyEntryPoint("EICTR500"),Execblock("EICTR500",.F.,.F.,"LOOP"),)//igorchiba 01/07/2010 validar pela customizacao
      IF lLoop 
         SA5->(DBSKIP()) 
         LOOP
      ENDIF
      Work->(DBAPPEND())
      Work->WKVIA     := SYR->YR_VIA+" "+SY9->Y9_DESCR
      Work->WKORI_DES := SYR->YR_ORIGEM+"/"+SYR->YR_DESTINO

      TR500Data(QData,TData,SA5->A5_LEAD_T,@data_si,@data_po,@data_emb,@data_atr,@data_des,@data_ent,@Prazo,TCod_I)

      Work->WKDT_SI   := data_si
      Work->WKDT_PO   := data_po
      Work->WKDT_EMB  := data_emb
      Work->WKDT_ATR  := data_atr
      Work->WKDT_DES  := data_des
      Work->WKDT_ENT  := data_ent
      Work->WKLEAD    := Prazo
      Work->WKFORN    := SA5->A5_FORNECE +" "+SA2->A2_NREDUZ
      Work->WKFABR    := SA5->A5_FABR    +" "+(SA2->(DBSEEK(xFilial()+SA5->A5_FABR)),SA2->A2_NREDUZ)
      SA5->(DBSKIP())
   ENDDO
ELSE
   Work->(DBAPPEND())
   Work->WKVIA        := SYR->YR_VIA+" "+SY9->Y9_DESCR
   Work->WKORI_DES    := SYR->YR_ORIGEM+"/"+SYR->YR_DESTINO

   TR500Data(QData,TData,0,@data_si,@data_po,@data_emb,@data_atr,@data_des,@data_ent,@Prazo,TCod_I)

   Work->WKDT_SI   := data_si
   Work->WKDT_PO   := data_po
   Work->WKDT_EMB  := data_emb
   Work->WKDT_ATR  := data_atr
   Work->WKDT_DES  := data_des
   Work->WKDT_ENT  := data_ent
   Work->WKLEAD    := Prazo
ENDIF
RETURN .T.
*-----------------------------------------------------------------------------------------------------
FUNCTION TR500Data(QData,TData,TLt_Fo,data_si,data_po,data_emb,data_atr,data_des,data_ent,Prazo,TCod_I)
*-----------------------------------------------------------------------------------------------------
LOCAL _Lead := 0

IF EMPTY(TCod_I) .OR. ! SB1->(DBSEEK(xFilial()+TCod_I)) .OR. SB1->B1_ANUENTE $ cSim
   IF TLt_Fo > EasyGParam("MV_LT_LICE") + EasyGParam("MV_LT_PROF")
      _Lead := TLt_Fo
   ELSE
      _Lead := EasyGParam("MV_LT_LICE") + EasyGParam("MV_LT_PROF")
   ENDIF
ELSE      
   _Lead := TLt_Fo
ENDIF

DO CASE
   CASE QData = 1
        data_si  := TData
        data_po  := data_si  + EasyGParam("MV_LT_COMP")
        data_emb := data_po  + _Lead
        data_atr := data_emb + SYR->YR_TRANS_T
        data_des := data_atr + SY9->Y9_LT_DES
        data_ent := data_des + SY9->Y9_LT_TRA

   CASE QData = 2
        data_po  := TData
        data_si  := data_po - EasyGParam("MV_LT_COMP")
        data_emb := data_po  + _Lead
        data_atr := data_emb + SYR->YR_TRANS_T
        data_des := data_atr + SY9->Y9_LT_DES
        data_ent := data_des + SY9->Y9_LT_TRA

   CASE QData = 3
        data_emb := TData
        data_po  := data_emb - _Lead
        data_si  := data_po  - EasyGParam("MV_LT_COMP")
        data_atr := data_emb + SYR->YR_TRANS_T
        data_des := data_atr + SY9->Y9_LT_DES
        data_ent := data_des + SY9->Y9_LT_TRA

   CASE QData = 4
        data_atr := TData
        data_emb := data_atr - SYR->YR_TRANS_T
        data_po  := data_emb - _Lead
        data_si  := data_po  - EasyGParam("MV_LT_COMP")
        data_des := data_atr + SY9->Y9_LT_DES
        data_ent := data_des + SY9->Y9_LT_TRA

   CASE QData = 5
        data_des := TData
        data_atr := data_des - SY9->Y9_LT_DES
        data_emb := data_atr - SYR->YR_TRANS_T
        data_po  := data_emb - _Lead
        data_si  := data_po  - EasyGParam("MV_LT_COMP")
        data_ent := data_des + SY9->Y9_LT_TRA
  
   CASE QData = 6
        data_ent := TData
        data_des := data_ent - SY9->Y9_LT_TRA
        data_atr := data_des - SY9->Y9_LT_DES
        data_emb := data_atr - SYR->YR_TRANS_T
        data_po  := data_emb - _Lead
        data_si  := data_po  - EasyGParam("MV_LT_COMP")

ENDCASE
Prazo:=EasyGParam("MV_LT_COMP")+_Lead+SYR->YR_TRANS_T+SY9->Y9_LT_TRA+SY9->Y9_LT_DES
RETURN NIL
*----------------------------------------------------------------------------
FUNCTION TR500ValData(TData)
*----------------------------------------------------------------------------
If Empty(TData)
   Help("",1,"AVG0001012") //"Informe a data para pesquisa"###"Informação"
   Return .F.
Endif
Return .T.

*----------------------------------------------------------------------------
FUNCTION TR500ValItem(TCod_I,TForn,TForLoj)
*----------------------------------------------------------------------------
If Empty(TCod_I)
   TForn  :=SPACE(LEN(SA5->A5_FORNECE))
   TForLoj:=SPACE(LEN(SA5->A5_LOJA)) 
   Return .T.
Endif

If !SA5->(DBSEEK(xFilial()+TCod_I))
   Help("",1,"AVG0001013") //"Não há  Fornecedores p/ este Ítem"###"Informação"
   Return .F.
Endif

Return .T.
*----------------------------------------------------------------------------
FUNCTION TR500ValForn(TCod_I,TForn,TForLoj)
*----------------------------------------------------------------------------
IF !Empty(mv_par04) .and. !ExistCpo("SA2",mv_par04)  //wfs 04/09/2013
   Return .F.
ENDIF

IF Empty(TForn) .And. IIF(EICLoja(),Empty(TForLoj),.T.)
   Return .T.
ENDIF                                     
//DFS - 03/02/13 - Comentado, visto que, essa validação impedia de verificar o relatório, quando digitado apenas o Fornecedor. Caso não encontre, o sistema já valida automaticamente.
/*If ! SA5->(DBSEEK(xFilial()+TCod_I+TForn+IIF(EICLoja(),TForLoj,"")))
//IF !EICSFabFor(xFilial("SA5")+TCod_I+TForn,, TForLoj)
   Help("",1,"AVG0001014") //"Fornecedor não cadastrado p/ este Item"###"Informação"
   Return .F.
Endif         */
Return .T.

*-----------------------------------*
FUNCTION TR500Qb(PTipo)
*-----------------------------------*
LOCAL  MCod:=WKVIA+WKFORN
STATIC SavVia, _Primeiro

_Primeiro:=IF(_Primeiro=NIL,.T.,.F.)
IF MCod # SavVia
   SavVia:= MCod
   IF ! _Primeiro
      IF(PTipo = "F",Linha++,)
      @ ++Linha,01 PSAY REPL("-",136)
      Linha++
   ENDIF
ENDIF
IF PTipo = "F"
   SavVia := NIL ; _Primeiro := NIL
ENDIF
RETURN .T.


//TRP - 01/08/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SYR","SY9"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EICTR500",STR0001,"EIR500",{|oReport| ReportPrint(oReport)},STR0030)

//ER - 20/10/2006 - Inicia o relatório como paisagem. 
oReport:oPage:lLandScape := .T. 
oReport:oPage:lPortRait := .F. 

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Previsão de Datas",aTabelas,aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"WKVIA"       ,"Work"   ,STR0018      ,/*Picture*/                       ,15            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKORI_DES"   ,"Work"   ,STR0020      ,/*Picture*/                       ,07            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKDT_SI"     ,"Work"   ,STR0021      ,/*Picture*/                       ,/*08*/ 14     ,/*lPixel*/,/*{|| code-block de impressao }*/) // GFP - 29/03/2012 - Ajuste no tamanho de data.
TRCell():New(oSecao1,"WKDT_PO"     ,"Work"   ,STR0022      ,/*Picture*/                       ,/*08*/ 14     ,/*lPixel*/,/*{|| code-block de impressao }*/) // GFP - 29/03/2012 - Ajuste no tamanho de data.
TRCell():New(oSecao1,"WKDT_EMB"    ,"Work"   ,STR0023      ,/*Picture*/                       ,/*08*/ 14     ,/*lPixel*/,/*{|| code-block de impressao }*/) // GFP - 29/03/2012 - Ajuste no tamanho de data.
TRCell():New(oSecao1,"WKDT_ATR"    ,"Work"   ,STR0024      ,/*Picture*/                       ,/*08*/ 14     ,/*lPixel*/,/*{|| code-block de impressao }*/) // GFP - 29/03/2012 - Ajuste no tamanho de data.
TRCell():New(oSecao1,"WKDT_DES"    ,"Work"   ,STR0025      ,/*Picture*/                       ,/*08*/ 14     ,/*lPixel*/,/*{|| code-block de impressao }*/) // GFP - 29/03/2012 - Ajuste no tamanho de data.
TRCell():New(oSecao1,"WKDT_ENT"    ,"Work"   ,STR0026      ,/*Picture*/                       ,/*08*/ 14     ,/*lPixel*/,/*{|| code-block de impressao }*/) // GFP - 29/03/2012 - Ajuste no tamanho de data.
TRCell():New(oSecao1,"WKLEAD"      ,"Work"   ,STR0001      ,/*Picture*/                       ,08            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   
//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport


************************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section("Seção 1")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Previsão de Datas"),"SYR",1,{|| xFilial("SYR")})

TRPosition():New(oReport:Section("Previsão de Datas"),"SY9",1,{|| xFilial("SY9") + SYR->YR_DESTINO})

//oSection:Print()
oReport:SetMeter(Work->(EasyRecCount("Work")))
Work->( dbGoTop() )


//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Previsão de Datas"):Init()


//Laço principal
Do While Work->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Previsão de Datas"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   Work->(dbSkip())
EndDo
Work->(DBGOTOP())

//Fim da impressão da seção 1
oReport:Section("Previsão de Datas"):Finish() 

Return .T.   
   
