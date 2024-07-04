#INCLUDE "Eicpo556.ch"
#include "AVERAGE.CH"
#include "avprint.ch"

#COMMAND E_RESET_AREA => SA5->(DBSETORDER(1)) ;
                        ; Work->(E_EraseArq(FileWork)) ;
                        ; WorkComp->(E_EraseArq(FileWork_C)) ;
                        ; DBSELECTAREA(nOldArea) ;
                        ; Return .F.
/*

Funcao      : EICPO556
Objetivos   : Ajustar o relatório para a versão 811 - Release 4
Autor       : Juliano Paulino Alves - JPA
Data 	    : 11/08/2006
Obs         :
Revisão     :
*/
***********************
Function EICPO556
***********************
lRet := EICPO556R3(.T.)
RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICPO556R3 ³ Autor ³ AVERAGE/MJBARROS    ³ Data ³ 22.10.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Shipment Confirmation                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICPO556R3()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICPO556R3(p_R4)

// incluir variaveis para o relatorio padrao

LOCAL _PictItem := ALLTRIM(X3Picture("B1_COD"))
LOCAL _PictSI   := ALLTRIM(X3Picture("W0__NUM"))
LOCAL _PictGI   := ALLTRIM(X3Picture("WP_REGIST"))
LOCAL aDados :={"Work",;
	                STR0001,; //"Este relatório imprimirá o Shipping Confirmation"
                "",;
                "",;
                "G",;
                220,;
                "",;
                "",;
                STR0002,; //"Shipping Confirmation"
                { "Zebrado", 1,"Importa‡Æo", 1, 2, 1, "",1 },;
                "EICPO556",;
                { {|| .T. } , {|| .T. }  }  }

LOCAL nOldArea:=SELECT(), TB_Campos:={}, cSaveMenuh, nCnt

LOCAL Struct1:= { {"WKFORN","C",AVSX3("A2_COD",3),0}   , {"WKCOMPRA","C",3,0} ,; //SO.:0026 OS.: 0244/02 FCD
                  {"WKDT_PO","D",8,0}} , FileWork_C

LOCAL Struct2:= { {"WKFORN","C",AVSX3("A2_COD",3),0}   , {"WKTIPO","C",7,0}    ,;//SO.:0026 OS.: 0244/02 FCD
                  {"WKPO_NUM","C",AvSx3("W2_PO_NUM", AV_TAMANHO),0}, {"WKPART_N","C",LEN(IF(SW3->(FieldPos("W3_PART_N")) # 0,SW3->W3_PART_N,SA5->A5_CODPRF)),0} ,;
                  {"WKCOMPRA","C",3,0} , {"WKDT_EMB2","D",8,0} ,;
                  {"WKGI_NUM","C",AvSx3("W5_PGI_NUM", AV_TAMANHO),0}, {"WKCOD_I" ,"C",AVSX3("W5_COD_I",3),0} ,;
                  {"WKNUM_SI","C",AVSX3("W0__NUM",3),0} , {"WKQTDE","N",AVSX3("W5_SALDO_Q",3),AVSX3("W5_SALDO_Q",4)}   ,;//SO.:0026 OS.: 0244/02 FCD
                  {"WKDT_EMB","D",8,0} , {"WKOBS","C",35,0}    ,;
                  {"WKPRECO","N",AVSX3("W5_PRECO",3),AVSX3("W5_PRECO",4)}} , FileWork

LOCAL /*TData:=dDataBase,*/TImport:=SW4->W4_IMPORT, TPedido := space(AVSX3("W2_PO_NUM",3))

LOCAL cTitulo,oDlg, oGet, nOpcA:=0, lValDt:=.F., lValFo:=.F., lValIm:=.F., oPanel,lValDtFim := .F., lValDtIni := .F./*, lValPo:= .F.//acb*/

LOCAl aRCampos:={}

LOCAL bValid:={||( lValDt    .OR. PO556Val("DATA",TData    )) .AND. ;
				 ( lValDtIni .OR. PO556Val("DATA",TDataIni )) .AND. ;
                 ( lValDtFim .OR. PO556Val("DATA",TDataFim )) .AND. ;//acb //acb
                 ( lValFo    .OR. PO556Val("FORN",TForn    )) .AND. ;
                 ( lValIm    .OR. PO556Val("IMPO",TImport  )) }            
                 
                 //( lValPo    .OR. PO556Val("PO",TPedido    )) .AND. ;

Local aButtons:={}                 
      

PRIVATE cMarca := GetMark(), lInverte := .F., MAbandona:= .F., oPrn
Private _PictQtde := ALLTRIM(X3Picture("W3_QTDE")), _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))

PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999

PRIVATE M_Nome    := SPACE(01) ,;
        M_Contato := SPACE(01) ,;
        M_Fax     := SPACE(20) ,;
        M_Fones   := SPACE(20)

PRIVATE aHeader[0],nUsado:=0, TForn:=SW5->W5_FORN ,TForLoj:= EICRetLoja("SW5","W5_FORLOJ"), nLinha

PRIVATE cCadastro := OemtoAnsi(STR0003) //"Shipment Confirmation"
PRIVATE cArqF3SA2:="SA2", cCampoF3SA2:="A2_COD"
PRIVATE cArqF3SYT:="SYT", cCampoF3SYT:="YT_COD", Tab_Forn:={}
PRIVATE cArqF3SW2:="SW2"//acb 06/07/2010

//JPA - 11/08/2006 - Relatório Personalizavel - Release 4
Private oReport
Private lR4   := If(p_R4 == NIL,.F.,.T.) .AND. FindFunction("TRepInUse") .And. TRepInUse()  

Private  TDataFim := dDatabase, TData := dDataBase, TDataIni := dDataBase       //acb - 07/07/2010
If EICLOJA() .And. (nPos := aScan(Struct2, {|x| x[1] == "WKFORN" })) > 0
   aAdd(Struct2, Nil)
   aIns(Struct2, nPos + 1)
   Struct2[nPos+1] := {"WKFORLOJ", "C", AvSx3("W5_FORLOJ", AV_TAMANHO),0}
EndIf   

If EICLOJA() .And. (nPos := aScan(Struct1, {|x| x[1] == "WKFORN" })) > 0
   aAdd(Struct1, Nil)
   aIns(Struct1, nPos + 1)
   Struct1[nPos+1] := {"WKFORLOJ", "C", AvSx3("W5_FORLOJ", AV_TAMANHO),0}
EndIf 

SA5->(DBSETORDER(3))

FileWork_C := E_CriaTrab(,Struct1,"WorkComp") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! USED()
   Help("", 1, "AVG0000451")//"NÆo h   rea dispon¡vel para abertura do Cadastro de Work"###"Informa‡Æo"
   E_RESET_AREA
   Return .F.
ENDIF

If EICLoja()
   IndRegua("WorkComp",FileWork_C+TEOrdBagExt(),"WKFORN+WKFORLOJ",;
            "AllwaysTrue()",;
            "AllwaysTrue()",;
            STR0006) //"Processando Arquivo Temporário..."
Else
   IndRegua("WorkComp",FileWork_C+TEOrdBagExt(),"WKFORN",;
            "AllwaysTrue()",;
            "AllwaysTrue()",;
            STR0006) //"Processando Arquivo Temporário..."

EndIf

FileWork := E_CriaTrab(,Struct2,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! USED()
   Help("", 1, "AVG0000451")//"NÆo h   rea dispon¡vel para abertura do Cadastro de Work"###"Informa‡Æo"
   E_RESET_AREA
   Return .F.
ENDIF

If EICLoja()
   IndRegua("Work",FileWork+TEOrdBagExt(),"WKFORN+WKFORLOJ+WKTIPO+WKPO_NUM",;
            "AllwaysTrue()",;
            "AllwaysTrue()",;
            STR0006) //"Processando Arquivo Temporário..."
Else
   IndRegua("Work",FileWork+TEOrdBagExt(),"WKFORN+WKTIPO+WKPO_NUM",;
            "AllwaysTrue()",;
            "AllwaysTrue()",;
            STR0006) //"Processando Arquivo Temporário..."
EndIf

WHILE .T.

  MAbandona:=.F.

  DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 33,55 OF GetWndDefault()
  
  oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 22/01/2016 - Ajustes Tela P12.
  oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
                                
  //acb 06-07-2010          
  @ 1.4,4.8 SAY "Data Base" OF oPanel
  @ 2.6,4.8 SAY "Data Inicial" OF oPanel 
  @ 3.8,4.8 SAY "Data Final" OF oPanel
  @ 5.0,4.8 SAY "Pedido" OF oPanel
  @ 6.2,4.8 SAY STR0008 OF oPanel //"Fornecedor"
  IF EICLOJA()
     @ 7.4,4.8 SAY "Loja" OF oPanel
     @ 8.6,4.8 SAY STR0009 OF oPanel //"Importador"
  ELSE
     @ 7.4,4.8 SAY STR0009 OF oPanel//"Importador"
  ENDIF
  //@ 7.4,4.8 SAY STR0009 //"Importador"
  //acb 06-07-2010
  @ 1.4,10.0 MSGET TData                 VALID (lValDt    :=PO556Val("DATA",TData   )) SIZE 40,8 OF oPanel
  @ 2.6,10.0 MSGET TDataIni              VALID (lValDt    :=PO556Val("DATA",TDataIni)) SIZE 40,8 OF oPanel
  @ 3.8,10.0 MSGET TDataFim              VALID (lValDtFim :=PO556Val("DATA",tDataFim)) SIZE 40,8 OF oPanel
  @ 5.0,10.0 MSGET TPedido  F3 cArqF3SW2 SIZE 50,8 OF oPanel
  @ 6.2,10.0 MSGET TForn    F3 cArqF3SA2 VALID (lValFo    :=PO556Val("FORN",TForn   )) SIZE 20,8 PICT "@!" OF oPanel
  
  IF EICLOJA()
     @ 7.4,10.0 MSGET TForLoj F3 cArqF3SA2 VALID (lValFo:=PO556Val("FORN",,TForLoj))  SIZE 20,8 PICT "@!" OF oPanel//CAMPO LOJA
     @ 8.6,10.0 MSGET TImport F3 cArqF3SYT VALID (lValIm:=PO556Val("IMPO",TImport,))  SIZE 10,8 OF oPanel
  ELSE
     @ 7.4,10.0 MSGET TImport  F3 cArqF3SYT VALID (lValIm    :=PO556Val("IMPO",TImport )) SIZE 10,8 OF oPanel
  ENDIF
  
  ACTIVATE MSDIALOG oDlg ON INIT ;
           EnchoiceBar(oDlg,{||nOpca:=1,If(EVAL(bValid),oDlg:End(),)},;
                            {||nOpca:=0,oDlg:End()}) CENTERED

  If nOpca = 0
     E_RESET_AREA
     Return .F.     
  Endif

  TB_Campos:={}

  IF EMPTY(TForn) .And. IIF(EICLoja(),EMPTY(TForLoj),.T.)
     AADD(TB_Campos,{{||Work->WKFORN+" "+BuscaFabr_Forn(Work->WKFORN)},"", "Fornecedor" })
     If EICLoja()
        AADD(TB_Campos,{{||Work->WKFORLOJ},"", "Loja" })
     EndIf
     adados[7]:=STR0008+": "+STR0010 //"Todos"
     cTitulo:=STR0010 //"Todos"
     cLoja  :=STR0010 //"Todos"
  ELSE
     SA2->(DbSeek(xFilial()+Avkey(TForn, "A2_COD")+If(EicLoja(), AvKey(TForLoj, "A2_LOJA"), "")))
     adados[7]:=STR0008+": "+SA2->A2_NREDUZ
     cTitulo:=SA2->A2_NREDUZ
     cLoja  :=TForLoj
  ENDIF

  AADD(TB_Campos,{"WKTIPO"    ,"", " "})
  AADD(TB_Campos,{"WKPO_NUM"  ,"", OemToAnsi(STR0011),_PictPo}) //"N§ P.O."
  AADD(TB_Campos,{"WKPART_N"  ,"", STR0012}) //"P/N"
  AADD(TB_Campos,{"WKGI_NUM"  ,"",STR0013,_PictGI}) //"I/L Number"
  AADD(TB_Campos,{"WKCOD_I"   ,"",OemToAnsi(STR0014),_PictItem}) //"Item"
  AADD(TB_Campos,{"WKNUM_SI"  ,"",OemToAnsi(STR0015),_PictSI}) //"N§ S.I."
  AADD(TB_Campos,{"WKQTDE"    ,"",STR0016,E_TrocaVP(1,_PictQtde)}) //"Quantidade"
  AADD(TB_Campos,{"WKDT_EMB2" ,"",STR0017   }) //"Dt. Emb. no P.O."
  AADD(TB_Campos,{"WKDT_EMB"  ,"",STR0018}) //"Embarque"
  AADD(TB_Campos,{"WKOBS"     ,"",STR0019}) //"Status"

  aRCampos:= E_CriaRCampos(TB_Campos,"C")
  IF EMPTY(TForn) .And. IIF(EICLoja(),EMPTY(TForLoj),.T.)
     aRCampos[1,1]:="WKFORN+' '+EICRETLOJA('WORK', 'WKFORLOJ') + ' ' + BuscaFabr_Forn(WKFORN+EICRETLOJA('WORK', 'WKFORLOJ'))"
     aRCampos[1,2]:="Fornecedor"
     aRCampos[1,3]:="C"
  ENDIF

  lInterrompe:=.T.

  Processa({|lEnd| PO556_Grava(TData,TDataIni,TDataFim,TPedido,TForn,TImport,@lEnd,TForLoj)},;
           STR0020) //"Pesquisando Embarques..."

  IF Work->(Easyreccount("Work")) > 0 .And. ! MAbandona

     DO WHILE .T.

        nOpca:=0
        
        Work->(DBGOTOP())

        oMainWnd:ReadClientCoors()
        DEFINE MSDIALOG oDlg TITLE cCadastro ;
        From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL
        
        //ISS - 30/11/10 - Alteração dos tamanhos dos campos para que seja mostrado o fornecedor completamente  
        @ 00,00 MsPanel oPanel Prompt "" Size 60,20 of oDlg //LRL 02/04/04 - Painel para Alinhamento MDI
        @ 0.5,0.6  SAY   STR0008 of oPanel //"Fornecedor"
        @ 0.5,14.0 SAY   "Loja"  of oPanel //"Loja"
        @ 0.5,21.5 SAY   STR0009 of oPanel //"Importador"
        @ 0.4,5.0  MSGET cTitulo      WHEN .F. SIZE  70,10 of oPanel
        @ 0.4,16.0 MSGET cLoja        WHEN .F. SIZE  40,10 of oPanel
        @ 0.4,25.5 MSGET SYT->YT_NOME WHEN .F. SIZE 110,10 of oPanel

        oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{34,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
        
        //If lR4     //JPA - 11/08/2006
           //oReport := ReportDef()
        //EndIf        
	  oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

//        MFR 07/03/2019 OSSME-2428		          
          aButtons := {}
          AAdd (aButtons, {"IMPRIMIR", {|| If(lR4,(oReport := ReportDef(),oReport:PrintDialog()),PO556REL(aDados,aRCampos,oMark)) } , STR0080 })
          AAdd (aButtons, {"CARTAS", {|| nOpca:=2,oDlg:End() } , STR0021 })
          ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=0,oDlg:End()},{||nOpca:=1,oDlg:End()},, aButtons))                                         

        DO CASE

           CASE nOpca = 0; EXIT

           CASE nOpca = 1; E_RESET_AREA

           CASE nOpca = 2
                If Pergunte("EIC556")
                   PO556_Carta(TForn, TForLoj, oMark)
                Endif
        ENDCASE

     ENDDO

  ENDIF

ENDDO

*---------------------------------------*
Function PO556Rel(aDados,aRCampos,oMark)
*---------------------------------------*
LOCAL nRecno:=RECNO()
E_Report(aDados,aRCampos)
DBGOTO(nRecno)
oMark:oBrowse:Refresh()
RETURN .T.
*----------------------------------------------------------------------------
FUNCTION PO556Val(cQual,Campo,TForLoj)
*----------------------------------------------------------------------------
Default TForLoj := ""

DO CASE
/*   CASE cQual = "DATA"
        If Empty(Campo)
           Help("", 1, "AVG0000452")//"Data Base deve ser informada"###"Informa‡Æo"
           Return .F.
        Endif*/
   CASE cQual = "DATA"
      If tDataFim < tDataIni 
         MsgStop("Data Final não pode ser menor que Data Inicial","Aviso") 
         Return .F.
      EndIf  

   CASE cQual = "FORN"
        If ! Empty(Campo) .And. ! SA2->(DbSeek(xFilial()+Campo+TForLoj))
           Help("", 1, "AVG0000453")//"Fornecedor nÆo cadastrado"###"Informa‡Æo"
           Return .F.
        Endif

   CASE cQual = "IMPO"
        If Empty(Campo)
           Help("", 1, "AVG0000454")//"Importador deve ser informado"###"Informa‡Æo"
           Return .F.
        ElseIf ! SYT->(DbSeek(xFilial()+Campo))
               Help("", 1, "AVG0000455")//"Importador nÆo cadastrado"###"Informa‡Æo"
               Return .F.
        Endif
        //Acb 06-07-2010
   CASE cQual = "PO"
        If Empty(Campo)
           return .f.
        ElseIf !Sw3->(Dbseek(xFilial()+Campo)) 
           Alert("Pedido não cadastrado")
        EndIf
ENDC

Return .T.
*----------------------------------------------*
FUNCTION  PO556_Grava(TData,TDataIni,TDataFim,TPedido,TForn,TImport,lEnd,TForLoj)
*----------------------------------------------*
LOCAL cFilSW5:=xFilial("SW5")
LOCAL _PictItem := ALLTRIM(X3Picture("B1_COD"))
LOCAL cQuery

DBSELECTAREA("Work")
AvZap()

Tab_Forn:={}

MAbandona:= .F.

MPo_Dt    := AVCTOD(SPACE(08))
MComprador:= 0

SW5->(DBSEEK(xFilial()))

ProcRegua(SW5->(Easyreccount("SW5")))
//MFR 29/04/2019 OSSME-2591
cQuery := "Select * From " + RetSqlName("SW5") + " SW5 inner join " + RetSqlName("SW2") + " SW2 on SW5.W5_PO_NUM = SW2.W2_PO_NUM and SW5.W5_FILIAL = SW2.W2_FILIAL "
          cQuery += " where W5_FILIAL = '" + cFilSW5 + "'"
          cQuery += " and W5_SEQ = 0 and W5_SALDO_Q > 0 and W5_FLUXO <>'5'"
          If !Empty(TPedido) 
             cQuery += " and W2_PO_NUM = '" + TPedido + "'"
          EndIf   
          If !Empty(TDataIni) .and. !Empty(TDataFim) .and. Empty(TPedido)
             cQuery += " and W5_DT_EMB >= '" + dtos(TDataIni) + "' and W5_DT_EMB  <= '" + dtos(TDataFim) +"'"
          EndIf     
          If ! EMPTY(TForn) 
             cQuery += " and W5_FORN = '" + TForn +"'  and W5_FORLOJ = '" + TForLoj +"'"
          EndIf   
          If ! EMPTY(Timport) 
             cQuery += " and W2_IMPORT = '" + Timport +"'"               
          EndIf
          cQuery +=  " And SW5.D_E_L_E_T_ <> '*' order by W5_PO_NUM" //rever se o order by deve ser ese mesmo
cQuery := ChangeQuery(cQuery)
DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "QryPo556", .T., .T.) 

EasyTCFields("QryPo556")

QryPo556->(DBGotop())


WHILE !QryPo556->(EOF()) .AND. !MAbandona

   IncProc(STR0026+ALLTRIM(QryPo556->W5_COD_I)) //"Processando Item: "

  
   SW4->(DBSEEK(xFilial()+QryPo556->W5_PGI_NUM))   && acd

   TObs := SPACE(33)
   MTipo:= ' '

   TObs:= STR0027+DTOC(QryPo556->W5_DT_EMB) //"AGUARDANDO EMBARQUE PARA "

   IF QryPo556->W5_DT_EMB <= TData
      TObs := STR0028+DTOC(QryPo556->W5_DT_EMB) + STR0029 //"NAO EMBARCADO EM "###" /AGUARDANDO"
      MTipo:= STR0030 //"Atraso"
   ELSE
      TObs := STR0027+DTOC(QryPo556->W5_DT_EMB) //"AGUARDANDO EMBARQUE PARA "
      MTipo:= STR0031 //"Preven"
   ENDIF

   IF ! EMPTY( QryPo556->W5_DOCTO_FU )
      TObs := STR0032 + DTOC(QryPo556SW5->W5_DT_EMB) //"EMBARQUE CONFIRMADO P/ "
      IF QryPo556->W5_DT_EMB <= TData
         MTipo:= STR0030 //"Atraso"
      ELSE
         MTipo:= STR0031 //"Preven"
      ENDIF
   ENDIF

   IF ! EMPTY(SW4->W4_DTSDCEX)
      IF ! EMPTY(QryPo556->W5_HAWB)
         SW6->(DBSEEK(xFilial()+QryPo556->W5_HAWB))
         IF EMPTY(SW6->W6_CHEG)
            IF SW6->W6_DT_EMB >= TData
               TObs:= STR0033+DTOC(SW6->W6_DT_EMB) //"EMBARQUE CONFIRMADO PARA "
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   IF (Empty(TForn) .And. IIF(EICLoja(),Empty(TForLoj),.T.)) .Or.  (QryPo556->W5_FORN == TForn .And. IIF(EICLoja(),QryPo556->W5_FORLOJ == TForLoj,.T.))
      WorkComp->(DBAPPEND())
      WorkComp->WKFORN   := QryPo556->W5_FORN
      WorkComp->WKCOMPRA := QryPo556->W2_COMPRA
      WorkComp->WKDT_PO  := QryPo556->W2_PO_DT
      If EICLoja()
         WorkComp->WKFORLOJ:= QryPo556->W5_FORLOJ
      EndIf
   ELSE
      IF SW2->W2_PO_DT > WorkComp->WKDT_PO 
         WorkComp->(DBAPPEND())
         WorkComp->WKCOMPRA := QryPo556->W2_COMPRA
         WorkComp->WKDT_PO  := QryPo556->W2_PO_DT
      ENDIF
   ENDIF
   
   IF !EICSFabFor(xFilial("SA5")+QryPo556->W5_COD_I+QryPo556->W5_FABR+QryPo556->W5_FORN, EICRetLoja("QryPo556","W5_FABLOJ"), EICRetLoja("QryPo556","W5_FORLOJ"))
      Help("", 1, "AVG0000462",,TRAN(QryPo556->W5_COD_I,_PictItem)+QryPo556->W5_FABR+ " " + EICRetLoja("QryPo556","W5_FABLOJ") +STR0037,1,26)//"COD. DO ITEM/FABR./FORN. "###" NÇO CADASTRADO NO LI000 - IG/LI"###"Informa‡Æo"
      SW5->(DBSKIP()) ; LOOP
   ENDIF

   IF ASCAN( Tab_Forn, {|x| x[1]+x[2] == QryPo556->(W5_FORN+EICRetLoja("QryPo556","W5_FORLOJ"))}) = 0
      AADD(Tab_Forn, {QryPo556->W5_FORN, EICRetLoja("QryPo556","W5_FORLOJ")})
   ENDIF

   SWP->(DBSEEK(xFilial()+QryPo556->W5_PGI_NUM+QryPo556->W5_SEQ_LI))
   PosO1_ItPedidos(QryPo556->W5_PO_NUM,QryPo556->W5_CC,QryPo556->W5_SI_NUM,QryPo556->W5_COD_I,QryPo556->W5_FABR,QryPo556->W5_FORN,SW5->W5_REG,QryPo556->W5_SEQ,EICRetLoja("QryPo556","W5_FABLOJ"),EICRetLoja("QryPo556","W5_FORLOJ"))
   
   If (Empty(TForn) .And. IIF(EICLoja(),Empty(TForLoj),.T.)) .Or. ;
      (QryPo556->W5_FORN == TForn .And. IIF(EICLoja(),QryPo556->W5_FORLOJ == TForLoj,.T.))
      Work->(DBAPPEND())
      Work->WKFORN   := QryPo556->W5_FORN
      Work->WKCOMPRA := QryPo556->W2_COMPRA
      Work->WKPO_NUM := QryPo556->W5_PO_NUM
      Work->WKTIPO   := MTipo
      Work->WKCOD_I  := QryPo556->W5_COD_I
      Work->WKGI_NUM := SWP->WP_REGIST
      Work->WKQTDE   := QryPo556->W5_SALDO_Q
      Work->WKNUM_SI := QryPo556->W5_SI_NUM
      //Work->WKPART_N := SA5->A5_CODPRF
      Work->WKDT_EMB := QryPo556->W5_DT_EMB
      Work->WKDT_EMB2:= SW3->W3_DT_EMB
      Work->WKPRECO  := QryPo556->W5_PRECO
      Work->WKOBS    := TObs
   
      If EICLoja()
         Work->WKFORLOJ:= QryPo556->W5_FORLOJ
      EndIf

      If SW3->(FieldPos("W3_PART_N")) # 0  //ASK 08/10/2007
         SW3->(DbSetOrder(8))
         SW3->(DbSeek(xFilial("SW3") + QryPo556->W5_PO_NUM +QryPo556->W5_POSICAO ))
         If !Empty(SW3->W3_PART_N)
            Work->WKPART_N := SW3->W3_PART_N
         Else
            Work->WKPART_N := SA5->A5_CODPRF         
         EndIf   
      Else 
         Work->WKPART_N := SA5->A5_CODPRF
      EndIf
   EndIf
   QryPo556->(DBSKIP())
ENDDO

MAbandona:=lEnd
ASORT(Tab_Forn,,,{|x,y| x[1] > x[1]})
Work->(DBGOTOP())

IF EOF() .AND. BOF()
   Help("", 1, "AVG0000463")//MSGINFO(STR0038,OemToAnsi(STR0005)) //"Nenhum registro foi selecionado"###"Informa‡Æo"
ENDIF

QryPo556->(DbCloseArea())
RETURN .T.
*--------------------------*
FUNCTION Po556_Carta(TForn, TForLoj)
*--------------------------*
Opc_Carta:=MV_PAR01

DBSelectArea("Work")
Work->(DBGOTOP())
lTem:=.T.
IF Opc_Carta # 3
   lTem:=.F.
   WHILE Work->(!EOF())
      IF WKTIPO = IF(Opc_Carta=1,"Preven","Atraso")
         lTem:=.T.
         EXIT
      ENDIF
      Work->(DBSKIP())
   ENDDO
ENDIF
IF !lTem
   Help("", 1, "AVG0000464")//"NÆo existe Embarques para essa carta."###"Informa‡Æo"
   RETURN NIL
ENDIF

#xtranslate :TIMES_NEW_ROMAN_12            => \[1\]
#xtranslate :COURIER_12                    => \[2\]
#xtranslate :TIMES_NEW_ROMAN_14_BOLD       => \[3\]
#xtranslate :TIMES_NEW_ROMAN_14_UNDERLINE  => \[4\]
#xtranslate :TIMES_NEW_ROMAN_12_UNDERLINE  => \[5\]
#xtranslate :TIMES_NEW_ROMAN_12_BOLD       => \[6\]
#xtranslate :COURIER_8                     => \[7\]


AVPRINT oPrn NAME STR0040 //"Emissao de Carta com Confirmacao de Embarque"


  DEFINE FONT oFont1  NAME "Times New Roman"    SIZE 0,12                  OF oPrn
  DEFINE FONT oFont2  NAME "Courier New"        SIZE 0,12                  OF oPrn
  DEFINE FONT oFont3  NAME "Times New Roman"    SIZE 0,14  BOLD            OF oPrn
  DEFINE FONT oFont4  NAME "Times New Roman"    SIZE 0,14  BOLD UNDERLINE  OF oPrn
  DEFINE FONT oFont5  NAME "Times New Roman"    SIZE 0,12       UNDERLINE  OF oPrn
  DEFINE FONT oFont6  NAME "Times New Roman"    SIZE 0,12  BOLD            OF oPrn
  DEFINE FONT oFont7  NAME "Courier New"        SIZE 0,08                  OF oPrn

  aFontes := { oFont1, oFont2, oFont3, oFont4, oFont5, oFont6, oFont7 }

  AVPAGE

    Processa({||PO556Print(TForn, TForLoj)},STR0041) //"Processando Relatorio..."

  AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()
oFont5:End()
oFont6:End()
oFont7:End()

MS_FLUSH()


RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PO556Print³ Autor ³MJBARROS/ROBSON         ³ Data ³ 16.06.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Impressao de Shipping Confirmation              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ EICPO556                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION PO556Print(TForn, TForLoj)
local Wind
nCol1:= 390//Coluna do Part Number
nCol2:= 770//Coluna do Codigo do Item
lNovaPag :=.F.

IF ! EMPTY( TForn )

   ProcRegua(Work->(Easyreccount("Work")))
   IF Opc_Carta = 1
      Po556Sh1(TForn, TForLoj)
   ELSEIF Opc_Carta = 2
      Po556Sh2(TForn, TForLoj)
   ELSE
      Po556Sh1(TForn, TForLoj)
      Po556Sh2(TForn, TForLoj)
   ENDIF

ELSE
   ProcRegua(LEN(Tab_Forn)+Work->(Easyreccount("Work")))

   For Wind = 1 TO LEN(Tab_Forn)

       IncProc(STR0042+Tab_Forn[Wind][1]) //"Imprimindo Fornecedor: " //DFS - 23/05/11 - Adicionado posicionamento no array. 
       IF Opc_Carta = 1
          Po556Sh1(Tab_Forn[Wind][1], Tab_Forn[Wind][2])
       ELSEIF Opc_Carta = 2
          Po556Sh2(Tab_Forn[Wind][1], Tab_Forn[Wind][2])
       ELSE
          Po556Sh1(Tab_Forn[Wind][1], Tab_Forn[Wind][2])
          Po556Sh2(Tab_Forn[Wind][1], Tab_Forn[Wind][2])
       ENDIF

   NEXT

ENDIF

RETURN NIL

*--------------------------*
FUNCTION Po556Sh1(P_Forn, TForLoj)
*--------------------------*

PRIVATE M_Nome, M_Contato

//P_Forn:=TForn

DBSELECTAREA("Work")
IF ! DBSEEK(P_Forn + TForLoj + 'Preven')
   RETURN ''
ENDIF
WorkComp->(DBSEEK(P_Forn+TForLoj))
SY1->(DBSEEK(xFilial()+WorkComp->WKCOMPRA))

PO556Header(P_Forn, TForLoj)

oPrn:oFont := aFontes:TIMES_NEW_ROMAN_12

oPrn:Say( nLinha+=150, 110 ,STR0043) //'SUBJECT: SHIPPING CONFIRMATION '

oPrn:Say( nLinha+=150, 110 ,STR0044) //"PLEASE SEND TO US A FORWARDER SHIPPERS LETTER'S COPY, COMMERCIAL INVOICE, HAWB NUMBER FOR"
oPrn:Say( nLinha+= 70, 110 ,STR0045) //"ITEMS IN ATTACH, IF THE SHIPMENT HAD BEEN ALREADY EFFECTED."

oPrn:Say( nLinha+=170, 110 ,STR0046) //"FOR ITEMS THAT THE SHIPMENT WERE NOT SHIPPED IN THE ABOVE DATE, PLEASE INFORM TO US WHEN"
oPrn:Say( nLinha+= 70, 110 ,STR0047) //"YOU'LL BE ABLE TO SHIP IT. THANK YOU VERY MUCH AND BEST REGARDS,"

oPrn:Say( nLinha+=150, 110 ,ALLTRIM(SYT->YT_NOME))

oPrn:oFont := aFontes:COURIER_8

Po556_Emite('Preven',P_Forn, TForLoj)

RETURN ""

*---------------------*
Function PO556Header(P_Forn, TForLoj)
*---------------------*
IF lNovaPag
   AVNEWPAGE
ENDIF
lNovaPag:=.T.
nLinha:=100

IF ! SA2->(DBSEEK(xFilial()+P_Forn+TForLoj))
   M_Nome    := SPACE(01)
   M_Contato := SPACE(01)
   M_Fax     := SPACE(20)
   M_Fones   := SPACE(20)
ELSE
   M_Nome    := IF( ! EMPTY(SA2->A2_REPRES), SA2->A2_REPRES , SA2->A2_NOME  )
   M_Contato := IF( ! EMPTY(SA2->A2_REPRES), SA2->A2_REPCONT, SA2->A2_CONTATO )
   M_Fax     := IF( ! EMPTY(SA2->A2_REPRES), SA2->A2_REPRFAX, SA2->A2_FAX     )
   M_Fones   := IF( ! EMPTY(SA2->A2_REPRES), SA2->A2_REPRTEL, SA2->A2_TEL     )
ENDIF

//oPrn:Say( nLinha, 1240 ,SYT->YT_NOME, aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2 )
//oPrn:Say( nLinha+=60, 1240 ,SYT->YT_ENDE, aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2 )
//WEND:=ALLTRIM(SYT->YT_CIDADE)+' -  '+ALLTRIM(SYT->YT_ESTADO)+'-'+ALLTRIM(SYT->YT_PAIS)+'-'+ALLTRIM(SYT->YT_CEP)
//oPrn:Say( nLinha+=60, 1240 ,WEND, aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2 )
//oPrn:Say( nLinha+=60, 1240 ,SYT->YT_TEL_IMP, aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2 )
//oPrn:Say( nLinha+=60, 1240 ,SYT->YT_FAX_IMP, aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2 )
//oPrn:Box( nLinha+=100,110  , nLinha+1 , 2330 )
//oPrn:Say( nLinha+=20,1240 ,STR0048, aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2 ) //'SHIPMENT CONFIRMATION'
//oPrn:Box( nLinha+=70,110  , nLinha+1 , 2330 )
//oPrn:Say( nLinha+=50,100 ,dtoc(dDatabase))

Linha:=nLinha
PrintCab(oPrn,STR0048,oPrn:nPage,@Linha,,"EICPO556") //'SHIPMENT CONFIRMATION'
nLinha:=Linha

oPrn:oFont := aFontes:COURIER_12

oPrn:Say( nLinha+=150,100 ,STR0049 + M_Nome) //"TO.........: "
oPrn:Say( nLinha+=50 ,100 ,STR0050 + SUBSTR(M_Contato,1,20)) //"ATTN.......: "
oPrn:Say( nLinha+=50 ,100 ,STR0051 + M_Fax) //"FAX NR.....: "
oPrn:Say( nLinha+=50 ,100 ,STR0052 + M_Fones) //"PHONE NR...: "
RETURN NIL

*---------------------------*
FUNCTION Po556Sh2(P_Forn, TForLoj)
*---------------------------*

PRIVATE M_Nome, M_Contato

//P_Forn:=TForn
DBSELECTAREA("Work")
IF ! DBSEEK(P_Forn + TForLoj + 'Atraso')
   RETURN ''
ENDIF

WorkComp->(DBSEEK(P_Forn+TForLoj))
SY1->(DBSEEK(xFilial()+WorkComp->WKCOMPRA))

PO556Header(P_Forn, TForLoj)

oPrn:oFont := aFontes:TIMES_NEW_ROMAN_12
oPrn:Say( nLinha+=150, 110 ,STR0043) //'SUBJECT: SHIPPING CONFIRMATION '

oPrn:Say( nLinha+=150, 110 ,STR0053) //"PLEASE SEND  US  SHIPPING  DETAILS, COPY  OF  COMMERCIAL  INVOICE, HAWB OR B/L  NUMBER  FOR  THE"
oPrn:Say( nLinha+=100, 110 ,STR0054) //"ATTACHED ITEMS, IF SHIPMENT IS ALREADY EFFECTED."
oPrn:Say( nLinha+=150, 110 ,STR0055) //"OTHERWISE,  PLEASE  INFORM US THE  SHIPPING SCHEDULE, AS SOON AS POSSIBLE.  WE' RE"
oPrn:Say( nLinha+=100, 110 ,STR0056) //"WAITING FOR YOUR URGENT REPLY."
oPrn:Say( nLinha+=150, 110 ,STR0057) //"THANKS AND REGARDS"

oPrn:oFont := aFontes:COURIER_8

Po556_Emite('Atraso',P_Forn, TForLoj)

RETURN ""

*---------------------------------*
FUNCTION Po556_Emite(MTipo,P_Forn, TForLoj)
*---------------------------------*
LOCAL M_PoNum
LOCAL _PictItem := ALLTRIM(X3Picture("B1_COD"))

LOCAL _PictGI   := ALLTRIM(X3Picture("WP_REGIST"))

*5         15                     38                57 59         71 73     81 83         95 97      107 109                       135
*+=================================================================================================================================+
*|Number PO| Part Number          | I/L Number       | Part Number | S. I.   | Quantity    | Req.Ship. | Confirmed Ship. DATE      |
*|6        | 17                   | 40               |   "+N_F+"   |         |             |   DATE    |                           |
*|=========|======================|==================|=============|=========|=============|===========|===========================|
*|9999/99! | xxxxxxxxxxxxxxxxxxxx | 9999-99/999999-9 | 99999-99-9  | 9999/99 | 999,999,999 | 99/99/99  | 99/99/99 1234567890123456 |


*5         15                     38                57 59         71 73     81        9193            108       118                135
*+=================================================================================================================================+
*|Number PO| Part Number          | I/L Number       | Part Number |        S. I.     | Quantity    | Req.Ship. | Confirmed Ship.  |
*|6        | 17                   | 40               |   "+N_F+"   |                  |             |   DATE    |     DATE         |
*|=========|======================|==================|=============|==================|=============|===========|==================|
*|9999/99! | xxxxxxxxxxxxxxxxxxxx | 9999-99/999999-9 | 99999-99-9  | 9999999999999/99 | 999,999,999 | 99/99/99  | 99/99/99 12345678|
*                                                                                                       110
*1         15                     38                57 59         71 73                 93            108         120 124          135
*+=================================================================================================================================+
*|   Number PO   | Part Number         | I/L Number       |Part Number | S. I.           | S.I.  | Quantity    |Req.Ship|Confirmed Ship.  |
*|6              | 17                  | 40               |  "+N_F+"   |                         |            |  DATE  |DATE             |                        |
*|===============|=====================|==================|======================================|============|========|=================|
*|123456789012345| xxxxxxxxxxxxxxxxxxxx| 9999-99/999999-9 |123456789012345678901234567890 9999/99|999,999,999 |99/99/99|99/99/99 12345678|
*|123456789012345| xxxxxxxxxxxxxxxxxxxx| 9999-99/999999-9 |123456789012345678901234567890 9999/99|999,999,999 |99/99/99|99/99/99 12345678|

nLinha+=100
MPag:= 00
DBSELECTAREA("Work")
DBSEEK(P_Forn + TForLoj + MTipo)
MPo_Num:= WKPO_NUM
oPrn:oFont := aFontes:COURIER_8
lRodape:=.F.
lBateu:=.F.
IF !EOF()
   lRodape:=.T.
   Po556SubCab()
   lBateu:=.T.
ENDIF
WHILE ! EOF()

   IncProc(STR0058+ALLTRIM(Work->WKCOD_I)) //"Imprimindo Item: "

   IF WKFORN <> P_Forn .And. (!EICLoja() .Or. WKFORLOJ <> TForLoj)
      EXIT                                                                    
   ENDIF

   IF WKTIPO <> MTipo
      EXIT
   ENDIF

   IF nLinha > 2900
      PO556Header(P_Forn, TForLoj)

      oPrn:oFont := aFontes:COURIER_8

/*    IF MPag # 0
         oPrn:Box( nLinha,110  , nLinha+1 , 2330 )
         nLinha+=25
      ENDIF
      IF MPag > 1
         oPrn:Say( nLinha,110 ,STR0059) //'REMARKS: PLEASE INFORM THE CONFIRMED SHIP DATE IN THIS PAPER'
         nLinha+=50
      ENDIF*/

      MPag++

      Po556SubCab()
      lBateu:=.T.

   ENDIF

   oPrn:oFont := aFontes:COURIER_8

   IF WKPO_NUM <> M_PoNum
      IF !EMPTY(M_PoNum) .AND. !lBateu
         oPrn:Box( nLinha,110  , nLinha+1 , 2330 )
         nLinha+=20
      ENDIF
      M_PoNum:= WKPO_NUM
   ENDIF
   lBateu:=.F.

   oPrn:Say( nLinha, 110 ,TRAN(WKPO_NUM,_PictPO))
   oPrn:Say( nLinha,nCol1,WKPART_N)
   oPrn:Say( nLinha,nCol2,TRAN(WKCOD_I,_PictItem))
   oPrn:Say( nLinha,1075 ,TRAN(WKGI_NUM,_PictGI))
//   oPrn:Say( nLinha,1328 ,TRAN(WKNUM_SI,_PictSI))  SO.:0026/02 OS.: 0244/02 Por definicao, nao sera impresso o numero SI. FCD
   oPrn:Say( nLinha,1560 ,TRAN(WKQTDE,AVSX3("W5_SALDO_Q",6)),,,,,1)//1660

   oPrn:Say( nLinha,1640 ,DTOC(WKDT_EMB2)) //1700
   oPrn:Say( nLinha,1850 ,DTOC(WKDT_EMB))  //1890
/*

   oPrn:Say( nLinha, 110 ,TRAN(WKPO_NUM,_PictPO))
   oPrn:Say( nLinha,nCol1,WKPART_N)
   oPrn:Say( nLinha,nCol2,TRAN(WKCOD_I,_PictItem))
   oPrn:Say( nLinha,1075 ,TRAN(WKGI_NUM,_PictGI))
   oPrn:Say( nLinha,1328 ,TRAN(WKNUM_SI,_PictSI))  //AQUI fcd
   oPrn:Say( nLinha,1660 ,TRAN(WKQTDE,AVSX3("W5_SALDO_Q",6)),,,,,1)

   oPrn:Say( nLinha,1700 ,DTOC(WKDT_EMB2))
   oPrn:Say( nLinha,1890 ,DTOC(WKDT_EMB))
*/   
   nLinha+=50

   DBSKIP()

ENDDO

IF lRodape
   oPrn:Box( nLinha+=50,110  , nLinha+1 , 2330 )
   oPrn:Say( nLinha+=20,110  , STR0059) //'REMARKS: PLEASE INFORM THE CONFIRMED SHIP DATE IN THIS PAPER'
ENDIF

RETURN ''

*---------------------*
FUNCTION Po556SubCab()
*---------------------*

oPrn:oFont := aFontes:COURIER_8

nLinha+=50
oPrn:Box( nLinha,110  , nLinha+1 , 2330 )
nLinha+=20
oPrn:Say( nLinha, 110 ,STR0060) //'NUMBER PO'
oPrn:Say( nLinha,nCol1,STR0061) //'PART NUMBER'
oPrn:Say( nLinha,nCol2,ALLTRIM(SM0->M0_NOME))
oPrn:Say( nLinha,1075 ,STR0062) //'I/L NUMBER'
//oPrn:Say( nLinha,1328 ,STR0063) //'S.I.'
oPrn:Say( nLinha,1392 ,STR0064) //'QUANTITY'  //1492
oPrn:Say( nLinha,1640 ,STR0065) //'REQ.SHIP'  //1700
oPrn:Say( nLinha,1850 ,STR0065) //'REQ.SHIP'  //1890
oPrn:Say( nLinha,2000 ,STR0066) //'CONFIRMED SHIP.'//2055
nLinha+=50

oPrn:Say( nLinha,nCol2,STR0068) //'CODE'
oPrn:Say( nLinha,1640 ,STR0067    ) //'DATE P.O.'
oPrn:Say( nLinha,1850 ,STR0069         ) //'DATE'
oPrn:Say( nLinha,2000 ,STR0070) //'DATE DD/MM/YY'
nLinha+=50
oPrn:Box( nLinha,110  , nLinha+1 , 2330 )
nLinha+=20

*--------------------*
PROCEDURE Po556_Relat
*--------------------*




L1 := 7
L2 := 22
C1 := 0
C2 := 79

*-----------------*
FUNCTION Po556_Cab
*-----------------*
LOCAL _PictItem := ALLTRIM(X3Picture("B1_COD"))
LOCAL MTam_PO := LEN(TRANS(WKPO_NUM,_PictPO)), MTam_IT := LEN(TRANS(WKCOD_I,_PictItem))

IF MTam_PO < 9
   MTam_PO := 9
ENDIF

IF MTam_IT < 6
   MTam_IT := 6
ENDIF

*2         12                   33               50         61          73            87       96
*Part Number          I/L Number       Quantidade    Valor Unit. Dt. Emb. STATUS
*-------------------- ---------------- ----------- ------------- -------- ---------------------------------
*9999/99!  xxxxxxxxxxxxxxxxxxxx 9999-99/999999-9 99999-99-9 999,999,999 9999,999,9999 99/99/99 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

MPag:= MPag + 1
Cabec(109+MTam_PO+MTam_IT, STR0071, MPag ) //' RELATORIO DO SHIPPING INFORMATION  '

oPrn:oFont := aFontes:COURIER_8

MLin:= MLin + 1

@MLin,002 SAY STR0072 //'Num. P.O.'
@MLin,MCol_A SAY STR0061 //'Part Number'
@MLin,MCol_B SAY STR0062 //'I/L Number'
@MLin,MCol_C SAY STR0073 //'Quantidade'
@MLin,MCol_D SAY STR0074 //'Valor Unit.'
@MLin,MCol_E SAY STR0075 //'Dt. Emb.'
@MLin,MCol_F SAY STR0076 //'STATUS'
@MLin,MCol_G SAY STR0077 //'Codigo'

MLin:= MLin + 1

@MLin,002 SAY REPLI('-',MTam_PO)
@MLin,MCol_A SAY REPLI('-',20)
@MLin,MCol_B SAY REPLI('-',16)
@MLin,MCol_C SAY REPLI('-',11)
@MLin,MCol_D SAY REPLI('-',13)
@MLin,MCol_E SAY REPLI('-',08)
@MLin,MCol_F SAY REPLI('-',33)
@MLin,MCol_G SAY REPLI('-',MTam_IT)

MLin:= MLin + 1

RETURN ''
/*
*---------------------------*
FUNCTION PO556Cab(ImprimePag)
*---------------------------*
MLin:=1
??H_CGTIMES_MISTO_TIT
PO150Header(@MLin)
?? H_CGTIMES_MISTO_07
Center2(77,STR0002,MLin) //"SHIPPING CONFIRMATION"
MLin++
@ MLin,001 SAY STR0078+PO150ConvData(MSDATE()) //"Date: "
IF ImprimePag !=NIL
   @ MLin,069 SAY STR0079+PADL(++MPag,3,'0') //"Page: "
ENDIF
??COMPRIMIDO
PO552ATTN(NIL,M_Comprador)
??COMPRIMIDO
RETURN NIL
*/

//JPA - 11/08/2006 - Definições do relatório personalizável
****************************
Static Function ReportDef()
****************************                     
Local PicItem := ALLTRIM(X3Picture("B1_COD"))
Local PicSI   := ALLTRIM(X3Picture("W0__NUM"))
Local PicGI   := ALLTRIM(X3Picture("WP_REGIST"))

//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SW5", "SW2", "SWP", "SA5", "SW3"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EICPO556", STR0002, "EIC556"  , {|oReport| ReportPrint(oReport)}, STR0001)

//ER - 20/10/2006 - Inicia o relatório como paisagem. 
oReport:oPage:lLandScape := .F. 
oReport:oPage:lPortRait := .T. 

//Define os objetos com as seções do relatório
oSecao1 := TRSection():New(oReport,"Pedidos",aTabelas,aOrdem)
oSecao2 := TRSection():New(oReport,"Fornecedor",{"Work","SA2"},{})

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1, "WKTIPO"   , "Work", "_______" , /*Picture*/          , 07                   , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKPO_NUM" , "Work", STR0011   , /*Picture*/          , 15                   , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKPART_N" , "Work", STR0012   , /*Picture*/          , 20                   , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKGI_NUM" , "Work", STR0013   , PicGI                , 14                   , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKCOD_I"  , "Work", STR0014   , PicItem              , AVSX3("W5_COD_I",3)+3, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKNUM_SI" , "Work", STR0015   , PicSI                , AVSX3("W0__NUM",3)   , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKQTDE"   , "Work", STR0016   , AVSX3("W5_SALDO_Q",6), AVSX3("W5_SALDO_Q",3), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKDT_EMB2", "Work", STR0017   , /*Picture*/          , 10                   , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKDT_EMB" , "Work", STR0018   , /*Picture*/          , 10                   , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKOBS"    , "Work", STR0019   , /*Picture*/          , 35                   , /*lPixel*/, /*{|| code-block de impressao }*/)
                                                    
//Definição das colunas de impressão da seção 2 
TRCell():New(oSecao2,"WKFORN" , "Work", STR0008  , /*Picture*/, AVSX3("A2_COD",3) , /*lPixel*/, /*{|| code-block de impressao }*/)
IF EICLoja()
   TRCell():New(oSecao2,"WKFORLOJ" , "Work", "Loja"  , /*Picture*/, AVSX3("A2_LOJA",3) , /*lPixel*/, /*{|| code-block de impressao }*/)
   oBreak := TRBreak():New(oReport:Section("Fornecedor"),{||Work->(WKFORN+WKFORLOJ)},,.F.) //Quebra por Fornecedor e Loja
ELSE
   oReport:Section("Fornecedor"):Cell("WKFORN"):SetCellBreak() //Quebra por fornecedor
ENDIF
                                 
oReport:bOnPageBreak :={||oReport:Section("Fornecedor"):PrintLine()} 

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("Pedidos")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Pedidos"),"SW5",1,{|| xFilial()})
TRPosition():New(oReport:Section("Pedidos"),"SW2",1,{|| xFilial()+SW5->W5_PO_NUM})
TRPosition():New(oReport:Section("Pedidos"),"SWP",1,{|| xFilial()+SW5->W5_PGI_NUM+SW5->W5_SEQ_LI})
TRPosition():New(oReport:Section("Pedidos"),"SA5",1,{|| xFilial()+SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN})
TRPosition():New(oReport:Section("Pedidos"),"SW3",5,{|| xFilial()+DTOS(W3_DT_EMB)})
TRPosition():New(oReport:Section("Fornecedor"),"SA2",1,{|| xFilial()+Work->WKFORN})

oReport:SetMeter(Work->(EasyRecCount("Work")))
Work->(dbGoTop())

oReport:Section("Fornecedor"):Init()
//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Pedidos"):Init()

//Laço principal
Do While Work->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Pedidos"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Pedidos"):Finish()
//Fim da impressão da seção 2
oReport:Section("Fornecedor"):Finish()                                

return .T.

*----------------------------------------------------------------------------*
*     FIM DO PROGRAMA PO556
*----------------------------------------------------------------------------*
