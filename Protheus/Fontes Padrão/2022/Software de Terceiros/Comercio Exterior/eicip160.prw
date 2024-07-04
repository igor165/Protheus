#INCLUDE "Eicip160.ch"                                                                                                                     
//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "avprint.ch"

#xtranslate :TIMES_NEW_ROMAN_10_BOLD  => \[1\]
#xtranslate :TIMES_NEW_ROMAN_14_BOLD  => \[2\]
#xtranslate :COURIER_08               => \[3\]
#xtranslate :TIMES_NEW_ROMAN_08_BOLD  => \[4\]
#COMMAND  TRSEEK   => DBSEEK(xFilial()+" 0        0.001",.T.)


#DEFINE POR_ITEM  STR0001 //"Por Produto"
#DEFINE POR_PO    STR0002 //"Por Pedido"
#DEFINE POR_FORN  STR0003 //"Por Fornecedor"

#DEFINE POR_COMPRADOR STR0004 //"Por Comprador"
#DEFINE POR_FAMILIA   STR0005 //"Por Familia"

#COMMAND E_RESET_AREA => DBSELECTAREA(nOldArea) ; TRB->(E_EraseArq(cNomArq)) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICIP160 ³ Autor ³ AVERAGE/RS            ³ Data ³ 11.03.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Controle Geral                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICIP160()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³ Cristiano A. Ferreira (Protheus) 23/11/1999 11:00          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EicIp160

Local oChkFam, lChkFam := .f., oChkCom, lChkCom := .f.
Local oRdFam, oRdCom, nRdCom := 1         //NCCF - 19/05/09

Local bOk, bCancel
Local cPictQde :=AVSX3("W1_QTDE",6)
Local nOldArea := Select()

Private bTelaCom, bTelaFam,nRdFam := 1 //igorchiba 07/07/2010 variaveis utilizadas em pontos de entrada

Private cCadastro := STR0006,oGetCodigo,oGetLoja:=SPACE(AVSX3("A2_LOJA",3)),oSayLoja //"Relatorio Geral"
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))

// aRotina declarada apenas para compatibilizar com GetDadDB
Private aHeader[0],nUsado:=0,nOpc:=0,cArquivo:=""

Private cMarca := GetMark(), lInverte := .F.
Private cNomArq
Private lPadrao  :=.T.//igorchiba 07/07/2010  desviar da tela padrao

 // ISS - Exclusão do campo W2_DT_SHIP o mesmo não é usado mais.
// INCLUIR O CAMPO W2_DT_SHIP NO array aCampos
PRIVATE aCampos:={"B1_FPCOD"  ,;
                  "W0_COMPRA" ,;
                  "W0_COMPRAN",;
                  "W1_COD_I"	,;
                  "W1_PO_NUM" ,;
                  "W1_CC"		,;
                  "Y3_DESC"	,;
                  "Y2_DESC" 	,;
                  "W1_QTDE"   ,;
                  "A2_NREDUZ" ,;
                  "A2_LOJA"	,;
                  "W0__DT"    ,;
                  "W2_DT_IMP" ,;
                  "WP_TRANSM"	,;
                  "W1_SI_NUM" ,;
                  "W1_DT_EMB" ,;
                  "W1_DTENTR_",;
                  "W6_IDENTVE",;
                  "W6_PRVDESE",;
                  "W2_DES_IPI",;
                  "W6_DT_NF"	,;
                  "W6_DT_EMB"	,;
                  "W6_CHEG"	,;
                  "Y9_DESCR"  ,;
                  "W6_DT_DESE",;
                  "W6_DT_ENTR",;
                  "W6_DT_ETA"	,;
                  "B1_DESC"	 }

Private aSemSx3   := { { "W2_DT_SHIP","D",8,0 } }
                       
PRIVATE      aTitulos := {{"Cod. Familia","","",""},; // "B1_FPCOD"  ,
				 {"Cod. Compr.","","",""}              ,; // "W0_COMPRA" ,
				 {"Comprador","","",""}                ,; // "W0_COMPRAN",
				 {"Cod.Item","","",""}                 ,; // "W1_COD_I"	,
				 {"Num. PO","","",""}                  ,; // "W1_PO_NUM" ,
				 {"C.Custo","","",""}                  ,; // "W1_CC"		,
				 {"Unid. Requisit.","","",""}          ,; // "Y3_DESC"	,
				 {"Local entreg.","","",""}            ,; // "Y2_DESC" 	,
				 {"Quantidade","","",""}               ,; // "W1_QTDE"   ,
				 {"Nome Fantasia","","",""}            ,; // "A2_NREDUZ" ,
				 {"Loja do Fornecedor","","",""}       ,; // "A2_LOJA"	,
				 {"Data SI","","",""}                  ,; // "W0__DT"    ,
				 {"Data Importa.","","",""}            ,; // "W2_DT_IMP" ,
				 {"Transmissão","","",""}              ,; // "WP_TRANSM"	,
				 {"Num. SI","","",""}                  ,; // "W1_SI_NUM" ,
				 {"Embarque","","",""}                 ,; // "W1_DT_EMB" ,
				 {"Entrega","","",""}                  ,; // "W1_DTENTR_",
				 {"Embarcação","","",""}               ,; // "W6_IDENTVE",
				 {"Prev. Desembarque","","",""}        ,; // "W6_PRVDESE",
				 {"Desc. Generica","","",""}           ,; // "W2_DES_IPI",
				 {"Data NFE","","",""}                 ,; // "W6_DT_NF"	,
				 {"Data Emb.","","",""}                ,; // "W6_DT_EMB"	,
				 {"Data Atracação","","",""}           ,; // "W6_CHEG"	,
				 {"Porto/Aeroporto","","",""}          ,; // "Y9_DESCR"  ,
				 {"Data Desemb.","","",""}             ,; // "W6_DT_DESE",
				 {"Data Entrada","","",""}             ,; // "W6_DT_ENTR",
				 {"Data ETA","","",""}                 ,; // "W6_DT_ETA"	,
				 {"Produto","","",""}                  ,; // "B1_DESC"	}
				 {"Autor.emb.","","",""}                } // "W2_DT_SHIP"


PRIVATE TB_Campos := { { "W1_PO_NUM"  ,"",STR0007} ,; //"Nr. Pedido"
                       { "W1_CC"      ,"",STR0008} ,; //"C.Custo"
                       { "Y3_DESC"    ,"",STR0009} ,; //"Descricao"
                       { "W1_QTDE"    ,"",STR0010,cPictQde} ,; //"Qtde"
                       { "A2_NREDUZ"  ,"",STR0011} ,; //"Fornecedor"
                       { "A2_LOJA"    ,"",STR0087} ,; //"Loja"
                       { "W2_DES_IPI" ,"",STR0012} ,; //"Status Atual"
                       { "W0__DT"     ,"",STR0013} ,; //"Data da S.I."
                       { "W2_DT_IMP"  ,"",STR0014} ,; //"Data da Imp."
                       { "WP_TRANSM"  ,"",STR0015} ,; //"Data Trans.L.I."
                       { "W1_SI_NUM"  ,"",STR0016} ,; //"Nr. S.I."
                       { "W6_DT_NF"   ,"",STR0017} ,; //"Validade L.I."
                       { "W2_DT_SHIP" ,"",STR0018} ,; //"Autor.Emb."                       
                       { "W1_DT_EMB"  ,"",STR0019} ,; //"Prv. Emb."
                       { "W1_DTENTR_" ,"",STR0020} ,; //"Prv. Ent."
                       { "W6_IDENTVE" ,"",STR0021} ,; //"Veiculo"
                       { "W6_DT_EMB"  ,"",STR0022} ,; //"Dt. Emb."
                       { "W6_CHEG"    ,"",STR0023} ,; //"Dt. Ent."
                       { "Y9_DESCR"   ,"",STR0024} ,; //"Porto/Aeroporto"
                       { "W6_PRVDESE" ,"",STR0025} ,; //"Prv. Desemb."
                       { "W6_DT_DESE" ,"",STR0026} ,; //"Dt. Desemb."
                       { "W6_DT_ENTR" ,"",STR0023} } //"Dt. Ent." 
                      
Private cTitulos := "Impressão EXCEL - Relatorio Geral"

Private cLoja:= SPACE(AVSX3("A2_LOJA", AV_TAMANHO))

Private aButtons:= {}

IF EasyEntryPoint("EICIP160")
   Execblock("EICIP160",.F.,.F.,"INIVAR")//igorchiba 07/07/2010  alterar todas variaveis declaradas ate aqui como privates
ENDIF

aArq:={POR_COMPRADOR,POR_FAMILIA }
aSelect:={POR_ITEM,POR_PO,POR_FORN}
SA2->(DBSETORDER(1))

cArquivo  :=aArq[1]
TSelect   :=aSelect[1]
cPict     :="@!"
cCodigo   :=SPACE(30)//BHF - 06/01/09
cComprador:=SPACE(03)
cFamilia  :=SPACE(LEN(SYC->YC_COD))

//AADD(aButtons,{"NOTE",{|| nOpca:=2,oDlg:End() },"Imprimir","Imprimir"})  //TRP - 28/10/2011 - Transferência do botão Imprimir para a Enchoicebar.

nOpc:=0

DO WHILE .T.
   /*
   DEFINE MSDIALOG oDlg TITLE STR0006 FROM 0,0 TO 220,360 OF oMainWnd PIXEL //"Relatorio Geral"
   	   
   bTelaFam := {|x| lChkFam:=x,lChkCom:=!lChkFam,if(x,oGetFam:Enable(),oGetFam:Disable()),oChkCom:Refresh()}
   bTelaCom := {|x| lChkCom:=x,lChkFam:=!lChkCom,if(x,oGetCom:Enable(),oGetCom:Disable()),oChkFam:Refresh()}
   
     
   @ 17,10 CHECKBOX oChkFam VAR lChkFam PROMPT STR0005 PIXEL OF oDlg ; //"Por Familia"
            ON CLICK (Eval(bTelaFam,.t.),Eval(bTelaCom,.f.)) SIZE 63,08
   @ 26,10 MSGET oGetFam VAR cFamilia F3 "SYC" PICTURE cPict SIZE 63,08 OF oDlg PIXEL
            
   @ 40,10 CHECKBOX oChkCom VAR lChkCom PROMPT STR0004 PIXEL OF oDlg ; //"Por Comprador"
            ON CLICK (Eval(bTelaCom,.t.),Eval(bTelaFam,.f.)) SIZE 63,08
   @ 49,10 MSGET oGetCom VAR cComprador F3 "SY1" PICTURE cPict SIZE 63,08 OF oDlg PIXEL
   
   @ 63,10 COMBOBOX oOSelect VAR TSelect ITEMS aSelect ON CHANGE IP160F3() SIZE 63,35 OF oDlg PIXEL
   @ 75,10 MSGET oGetCodigo VAR cCodigo F3 "SB1" PICTURE cPict VALID IP160VALID() SIZE 106,08 OF oDlg PIXEL
   IP160F3()
   
   bOk := {|| IF(IP160VALID(),(cArquivo:=if(lChkCom,aArq[1],aArq[2]),nOpc:=1,oDlg:End()),) }
   bCancel := {|| nOpc:=0,oDlg:End() }
   
   Eval(oChkFam:bChange)

   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)
   */
   
   cNomArq:=E_CriaTrab(,aSemSx3) //THTS - 07/11/2017
   lRelatPdr:=.T.//igorchiba 07/07/2010  se vai ser o relatorio padrao ou customizado

   IF EasyEntryPoint("EICIP160")
      Execblock("EICIP160",.F.,.F.,"ANTPARAM")//igorchiba 07/07/2010
   ENDIF  
   IF lPadrao//igorchiba 07/07/2010
         //NCF - 19/05/09 - Modificada esta tela para a troca de Checkbox para RadioButton
      DEFINE MSDIALOG oDlg TITLE STR0006 FROM 0,0 TO 310,390 OF oMainWnd PIXEL //"Relatorio Geral"
      
      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 21/07/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
      bTelaFam := {|x| if(x == 1,oGetFam:Enable(),oGetFam:Disable()),oRdFam:Refresh()}
      bTelaCom := {|x| if(x == 2,oGetCom:Enable(),oGetCom:Disable()),oRdFam:Refresh()}
   
      @ 27,10 RADIO oRdFam VAR nRdFam ITEMS STR0005,STR0004 PIXEL OF oPanel ; //"Por Familia"
               ON CLICK (Eval(bTelaFam,nRdFam),Eval(bTelaCom,nRdFam)) SIZE 63,08
               
      @ 27,75 MSGET oGetFam VAR cFamilia F3 "SYC" PICTURE cPict SIZE 63,08 OF oPanel PIXEL
               
      @ 38,75 MSGET oGetCom VAR cComprador F3 "SY1" PICTURE cPict SIZE 63,08 OF oPanel PIXEL
      
      @ 63,10 COMBOBOX oOSelect VAR TSelect ITEMS aSelect ON CHANGE IP160F3() SIZE 63,35 OF oPanel PIXEL
      @ 82,10 MSGET oGetCodigo VAR cCodigo F3 "SB1" PICTURE cPict VALID IP160VALID() SIZE 106,08 OF oPanel PIXEL
      
      IP160F3()
      
      bOk := {|| IF(IP160VALID(),(cArquivo:=if(nRdFam == 2,aArq[1],aArq[2]),nOpc:=1,oDlg:End()),) }
      bCancel := {|| nOpc:=0,oDlg:End() }
      
      Eval(oRdFam:bChange)
   
      ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)
   ELSE
      IF EasyEntryPoint("EICIP160")
         Execblock("EICIP160",.F.,.F.,"GERTELA")//igorchiba 07/07/2010 gerar tela customizada
      ENDIF 
   ENDIF
   
   
   IF nOpc == 1 .AND. IP160MontaNTX()      
      LOOP
   ENDIF

   EXIT
ENDDO

If Select("TRB") > 0
  E_RESET_AREA
EndIf
RETURN .F.

*-----------------------*
Function IP160MontaNTX()
*-----------------------*
LOCAL cChave
LOCAL oMark
LOCAL oPanel

IF cArquivo == aArq[1]      // Por Comprador
   cChave:="W0_COMPRA+"
ELSE
   cChave:="B1_FPCOD+"
ENDIF

DO CASE
   CASE TSelect = aSelect[1]   // Por Produto
        cChave+="W1_COD_I"

   CASE TSelect = aSelect[2]   // Por P.O
        cChave+="W1_PO_NUM"

   CASE TSelect = aSelect[3]   // Por Forn
        cChave+="A2_NREDUZ"
ENDCASE

If EICLoja() .And. "A2_NREDUZ" $ cChave
   cChave+= "+A2_LOJA" 
EndIf

DBSELECTAREA("TRB")
AvZap()

IndRegua("TRB",cNomArq+TEOrdBagExt(),cChave)

Processa({|| IP160GeraWk()}, STR0027) //"Pesquisando Informacoes ..."
TRB->(DBGOTOP())
                                      
IF TRB->(BOF()) .AND. TRB->(EOF())
   Help("",1,"AVG0001038") //"NÆo h  informa‡äes para consulta"###"Informa‡Æo"
   TRB->(OrdListClear())
   FERASE(cNomArq+TEOrdBagExt())
   RETURN .T.
ENDIF                                

nOpca:=0
DO WHILE .T.
   TRB->(DBGOTOP())
   
   oMainWnd:ReadClientCoors()

   DEFINE MSDIALOG oDlg TITLE cCadastro ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
    	    OF oMainWnd PIXEL                
    	    
      @00,00 MSPanel oPanel Size 20,45 of oDlg    	    
      oMark := MsSelect():New("TRB",,,TB_Campos,@lInverte,@cMarca,{34,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
                                       
      DEFINE SBUTTON FROM 18,(oDlg:nClientWidth-2)/2-30 TYPE 6 ACTION (nOpca:=2,oDlg:End()) ENABLE OF oPanel
      
      	@ 18,(oDlg:nClientWidth-4)/2-70 BUTTON "Excel" SIZE 030, 011 Pixel ACTION;
       (Processa({|| TR350Arquivo("TRB",,aTitulos,cTitulos)},"Exportando para Excel")) of oPanel 	//LRS - 7/11/2013  Imprimir em Excel 
        					 
      					
      oPanel:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT	   
   ACTIVATE MSDIALOG oDlg ON INIT ;
            (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
                             {||nOpca:=0,oDlg:End()},,aButtons)) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   IF nOpca == 2
      Processa({||IP160Relatorio()},STR0030) //"Imprimindo..."
      LOOP
   ENDIF

   EXIT 

ENDDO

TRB->(OrdListClear())

//FERASE(cNomArq+TEOrdBagExt())
E_EraseArq(cNomArq) //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

RETURN .T.

*---------------------*
Function IP160GeraWk()
*---------------------*
ProcRegua(SW1->(LastRec())+SW3->(LastRec())+SW5->(LastRec())+SW6->(LastRec()))
                                  
//DFS - 28/08/12 - Inclusão de tratamento para não aceitar somente a loja como parâmetro de filtro
IF TSelect == POR_FORN .AND. EicLoja() .AND. !Empty(cLoja) .AND. Empty(cCodigo) 
   MsgInfo(STR0085,STR0086)
   Return NIL
ELSE
   IP160Gr_IS000()
   IP160Gr_IP000()
   IP160Gr_IG000()
   IP160Gr_ID000()
Endif

Return NIL

*-------------------------*
Function IP160Gr_IS000()
*-------------------------*
Local lLoja := .T.
DBSELECTAREA("SW1")
SW1->(DBSETORDER(4))
TRSEEK   && DIRETIVA



DO WHILE !SW1->(EOF()) .AND. SW1->W1_FILIAL == xFilial("SW1")
   IncProc(STR0031) //"Lendo Dados dos Itens da S.I"
   TObs := SPACE(33)

   IF SW1->W1_SEQ <> 0
      EXIT
   ENDIF

   IF SW1->W1_SALDO_Q == 0
      EXIT
   ENDIF

   SW0->(DBSETORDER(1))
   SW0->(DBSEEK(xFilial()+SW1->W1_CC+SW1->W1_SI_NUM))

   SB1->(DBSETORDER(1))
   SB1->(DBSEEK(xFilial()+SW1->W1_COD_I))

   DO CASE
      CASE cArquivo == POR_COMPRADOR
           IF ! EMPTY(cComprador)
              IF SW0->W0_COMPRA <> cComprador
                 SW1->(DBSKIP())
                 LOOP
              ENDIF
           ENDIF
      CASE cArquivo == POR_FAMILIA
           IF ! EMPTY(cFamilia)
              IF SB1->B1_FPCOD <> cFamilia
                 SW1->(DBSKIP())
                 LOOP
              ENDIF
           ENDIF
   ENDCASE

   DO CASE 
                     
      CASE TSelect == POR_PO                               //NCF -  11/05/09 - Adicionado os cases "POR_PO" e "POR_FORN"
      IF ! EMPTY(cCodigo)                                  //       para que sejam filtrados corretamente os registros da SW1
         IF ALLTRIM(W1_PO_NUM) <> ALLTRIM(cCodigo)         //       exibidos no relatório de controle geral.  
            RETURN .F.                                    
         ENDIF
      ENDIF
      
      CASE TSelect == POR_ITEM
         IF ! EMPTY(cCodigo)
            IF ALLTRIM(SW1->W1_COD_I) <> ALLTRIM(cCodigo)
               SW1->(DBSKIP())
               LOOP
            ENDIF
         ENDIF
           
      CASE TSelect == POR_FORN //ASK
         //FDR - 21/08/12 - Filtro somente por fornecedor
         IF EICLoja() .AND. EMPTY(cLoja) .AND. !Empty(cCodigo) //DFS - 28/08/12 - Inclusão de tratamento para quando o codigo do fornecedor estiver preenchido 
            IF (ALLTRIM(SW1->W1_FORN) <> ALLTRIM(cCodigo))
               SW1->(DBSKIP())
               LOOP
            ENDIF
         ELSEIF ! EMPTY(cCodigo) .AND. IIF(EICLoja(),!EMPTY(cLoja),.T.)
            //IF (ALLTRIM(W1_FORN) <> ALLTRIM(cCodigo) .AND. IIF(EICLoja(),ALLTRIM(W1_FORLOJ) <> ALLTRIM(cLoja),.T.))
            // TDF - 15/02/2011 - Inclusão do tratamento de loja
            IF (ALLTRIM(W1_FORN) <> ALLTRIM(cCodigo) .OR. IIF(EICLoja(),ALLTRIM(W1_FORLOJ) <> ALLTRIM(cLoja),.F.)) 
               SW1->(DBSKIP())
               LOOP
            ENDIF 
         ENDIF 
                        
   ENDCASE 
   
   lLoop:=.F.
   IF EasyEntryPoint("EICIP160")
      Execblock("EICIP160",.F.,.F.,"LOOPSI")//igorchiba 07/07/2010  validacao customizada da fase SI
   ENDIF     
   IF lLoop
      SW1->(DBSKIP())
      LOOP
   ENDIF

   MWData := SW0->W0__DT

   TObs:=STR0032 //"EM NEGOCIACAO"

   //TRB->(DBAPPEND()) //ISS - 07/02/11 - Append retirado pois o mesmo acaba gerando "linhas em branco" na work TRB.

   SY1->(DBSETORDER(1))
   SY1->(DBSEEK(xFilial("SY1")+SW0->W0_COMPRA))

   SY2->(DBSETORDER(1))
   SY2->(DBSEEK(xFilial("SY2")+SW0->W0__POLE))

   SY3->(DBSETORDER(1))
   SY3->(DBSEEK(xFilial("SY3")+SW1->W1_CC))
   
   SA2->(DBSEEK(xFilial("SA2")+SW1->W1_FORN+EICRetLoja("SW1","W1_FORLOJ")))// TDF-18/02/11 

   If EICLoja() .AND. !Empty(cLoja)//FDR - 21/08/12
      lLoja:= AllTrim(cLoja) == AllTrim(SW1->W1_FORLOJ)
   EndIf 
   If lLoja
  
      TRB->(DBAPPEND())
      TRB->B1_FPCOD    :=    SB1->B1_FPCOD
      TRB->B1_DESC     :=    SB1->B1_DESC
      TRB->W0_COMPRA   :=    SW0->W0_COMPRA
      TRB->W0_COMPRAN  :=    SY1->Y1_NOME
      TRB->W1_COD_I    :=    SW1->W1_COD_I
      TRB->W1_CC       :=    SW1->W1_CC
      TRB->Y3_DESC     :=    SUBS(SY3->Y3_DESC,1,25)
      TRB->Y2_DESC     :=    SY2->Y2_DESC
      TRB->W1_QTDE     :=    SW1->W1_SALDO_Q
      TRB->W0__DT      :=    SW0->W0__DT
      TRB->W1_SI_NUM   :=    SW1->W1_SI_NUM
      TRB->W1_DT_EMB   :=    SW1->W1_DT_EMB
      TRB->W1_DTENTR_  :=    SW1->W1_DTENTR_
      TRB->W2_DES_IPI  :=    TObs 
      TRB->A2_NREDUZ   :=    SA2->A2_NREDUZ// TDF-18/02/11
      If EICLoja() 
         TRB->A2_LOJA  := SA2->A2_LOJA
      EndIf
   
   EndIf
   IF EasyEntryPoint("EICIP160")
      Execblock("EICIP160",.F.,.F.,"GRVSI")//igorchiba 07/07/2010 gravaçao de novos campos de SI
   ENDIF     
   
   SW1->(DBSKIP())

ENDDO

Return NIL

*------------------------*
FUNCTION IP160Gr_IP000()
*------------------------*
Local lLoja := .T.
Private aOrdSY9          //NCF-11/05/09
DBSELECTAREA("SW3")
SW3->(DBSETORDER(6))
TRSEEK   && DIRETIVA

W_Pont := 0

TObs := STR0033 //"CONFECCAO P.L.I."

DO WHILE !SW3->(EOF()) .AND. SW3->W3_FILIAL == xFilial("SW3")

   IncProc(STR0034) //"Lendo dados dos Itens do P.O."

   MQtde :=SW3->W3_SALDO_Q

   IF SW3->W3_SEQ <> 0 .OR. SW3->W3_SALDO_Q == 0
      EXIT
   ENDIF

   IF ! IP160_SelPO(SW3->W3_PO_NUM,SW3->W3_COD_I,SW3->W3_FORN,EICRetLoja("SW3","W3_FORLOJ"))
      SW3->(DBSKIP())
      LOOP
   ENDIF

   IF ! SW2->(DBSEEK(XFILIAL("SW2")+SW3->W3_PO_NUM))
      SW3->(DBSKIP())
      LOOP
   ENDIF

   W_Pont := 0

   IF cArquivo == POR_COMPRADOR
      IF !EMPTY(cComprador)
         IF SW2->W2_COMPRA <> cComprador
            SW3->(DBSKIP())
            LOOP
         ENDIF
      ENDIF
   ENDIF

   DBSELECTAREA("SW1")
   IF ! PosO1_It_Solic(SW3->W3_CC,SW3->W3_SI_NUM,;
                       SW3->W3_COD_I,SW3->W3_REG,0)
      SW3->(DBSKIP())
      LOOP
   ENDIF

   IF ! SB1->(DBSEEK(xFILIAL("SB1")+SW1->W1_COD_I))
      SW3->(DBSKIP())
      LOOP
   ENDIF

   IF cArquivo == POR_FAMILIA
     IF ! EMPTY(cFamilia)
        IF SB1->B1_FPCOD <> cFamilia
           SW3->(DBSKIP())
           LOOP
        ENDIF
     ENDIF
   ENDIF

   SA5->(DBSETORDER(3))
   //IF ! SA5->(DBSEEK(xFilial("SA5")+SW3->W3_COD_I + SW3->W3_FABR + SW3->W3_FORN))
   IF !EICSFabFor(xFilial("SA5")+SW3->W3_COD_I + SW3->W3_FABR + SW3->W3_FORN, EICRetLoja("SW3","W3_FABLOJ"), EICRetLoja("SW3","W3_FORLOJ"))
      SW3->(DBSKIP())
      LOOP
   ENDIF

   IF ! SW0->(DBSEEK(xFilial("SW0")+SW1->W1_CC+SW1->W1_SI_NUM))
      SW3->(DBSKIP())
      LOOP
   ENDIF 
   
    lLoop:=.F.
    IF EasyEntryPoint("EICIP160")
       Execblock("EICIP160",.F.,.F.,"LOOPPO")//igorchiba 07/07/2010  validacao customizada da fase PO
    ENDIF     
    IF lLoop
      SW3->(DBSKIP())
      LOOP
   ENDIF

   IF ! EMPTY(SW2->W2_DT_ALTE)
      MDt_IncAlt := SW2->W2_DT_ALTE
   ELSE
      MDt_IncAlt := SW2->W2_PO_DT
   ENDIF

   MWData := SW3->W3_DT_ENTR

   //TRB->(DBAPPEND())//ISS - 07/02/11 - Append retirado pois o mesmo acaba gerando "linhas em branco" na work TRB.

   SY2->(DBSETORDER(1))
   SY2->(DBSEEK(xFilial("SY2")+SW0->W0__POLE))

   SY3->(DBSETORDER(1))
   SY3->(DBSEEK(xFilial("SY3")+SW3->W3_CC))
   SA2->(DBSEEK(xFilial("SA2")+SW3->W3_FORN+EICRetLoja("SW3","W3_FORLOJ")))

   IF EICLoja() .AND. !Empty(cLoja)//FDR - 21/08/12
      lLoja := AllTrim(cLoja) == AllTrim(SW3->W3_FORLOJ) 
   EndIf 
   
   If lLoja
      TRB->(DBAPPEND())
      TRB->B1_FPCOD   := SB1->B1_FPCOD
      TRB->B1_DESC    := SB1->B1_DESC
      TRB->W0_COMPRA  := SW2->W2_COMPRA
      TRB->W1_PO_NUM  := SW3->W3_PO_NUM
      TRB->A2_NREDUZ  := SA2->A2_NREDUZ
      If EICLoja() 
         TRB->A2_LOJA := SA2->A2_LOJA
      EndIf
      TRB->W1_CC      := SW3->W3_CC
      TRB->Y3_DESC    := SUBS( SY3->Y3_DESC,1,25 )
      TRB->Y2_DESC    := SY2->Y2_DESC
      TRB->W1_QTDE    := MQtde
      TRB->W0__DT     := SW0->W0__DT
      TRB->W2_DT_IMP  := SW2->W2_DT_IMP
      TRB->WP_TRANSM  := SWP->WP_TRANSM
      TRB->W1_DT_EMB  := SW3->W3_DT_EMB
      TRB->W1_SI_NUM  := SW3->W3_SI_NUM
   // TRB->W1_DTENTR_ := SW1->W1_DTENTR_
      TRB->W1_DTENTR_ := SW3->W3_DT_ENTR
      TRB->W2_DES_IPI := TOBS
   EndIf 
   IF EasyEntryPoint("EICIP160")
      Execblock("EICIP160",.F.,.F.,"GRVPO")//igorchiba 07/07/2010 gravar PO 
   ENDIF     

   SW3->(DBSKIP())
ENDDO

Return NIL

*------------------------*
FUNCTION  IP160Gr_IG000()
*------------------------*
Local lLoja := .T.
DBSELECTAREA("SW5")
SW5->(DBSETORDER(6))
TRSEEK   && DIRETIVA

DO WHILE !SW5->(EOF()) .AND. SW5->W5_FILIAL == xFilial("SW5")

   IncProc(STR0035) //"Lendo dados dos Itens da L.I"

   MQtde := SW5->W5_SALDO_Q

   IF SW5->W5_SEQ <> 0 .OR. SW5->W5_SALDO_Q = 0
      EXIT
   ENDIF

   IF ! IP160_SelPO(SW5->W5_PO_NUM,SW5->W5_COD_I,SW5->W5_FORN,EICRetLoja("SW5","W5_FORLOJ"))
      SW5->(DBSKIP())
      LOOP
   ENDIF

   IF ! SW2->(DBSEEK( xFILIAL("SW2")+SW5->W5_PO_NUM ))
      SW5->(DBSKIP())
      LOOP
   ENDIF

   IF cArquivo == POR_COMPRADOR
      IF ! EMPTY(cComprador)
         IF SW2->W2_COMPRA <> cComprador
            SW5->(DBSKIP())
            LOOP
         ENDIF
      ENDIF
   ENDIF

   //TRP-12/12/07
   IF ! SB1->(DBSEEK(xFILIAL("SB1")+SW1->W1_COD_I))         
      SW5->(DBSKIP())
      LOOP
   ENDIF
                                                  
   //TRP-12/12/07 - Filtro por família
   IF cArquivo == POR_FAMILIA                     
     IF ! EMPTY(cFamilia)
        IF SB1->B1_FPCOD <> cFamilia
           SW5->(DBSKIP())
           LOOP
        ENDIF
     ENDIF
   ENDIF
   IF SW5->W5_FLUXO  == '1'
      SWP->(DBSEEK(xFILIAL("SWP")+SW5->W5_PGI_NUM+SW5->W5_SEQ_LI))
   ENDIF

   SW4->(DBSEEK(xFILIAL("SW4")+SW5->W5_PGI_NUM))

   IF SW5->W5_DT_EMB < dDataBase
      TObs := STR0036+DTOC(SW5->W5_DT_EMB) + STR0037 //"NAO EMBARCADO EM "###" /AGUARDANDO"
      W_Pont := 9
   ELSE
      TObs := STR0038+DTOC(SW5->W5_DT_EMB) //"AGUARDANDO EMBARQUE PARA "
      W_Pont := 6
   ENDIF

   IF ! EMPTY( SW5->W5_DOCTO_FU )
      TObs := STR0039 + DTOC(SW5->W5_DT_EMB) //"EMBARQUE CONFIRMADO PARA "
      W_Pont := 7
      IF SW5->W5_DT_EMB < dDataBase
         TObs := STR0036+DTOC(SW5->W5_DT_EMB) + " ** " //"NAO EMBARCADO EM "
         W_Pont := 9
      ENDIF
   ENDIF

   IF SW5->W5_FLUXO == "5"
      TObs := STR0040 //"AG. PROCESSO DE NACIONALIZACAO"
      W_Pont := 20
   ENDIF

   DBSELECTAREA("SW5")
   IF SW5->W5_DEF_REQ == 'S'
      TObs := STR0041 //"AG. DEFINICAO DO REQUISITANTE"
      W_Pont := 10
   ENDIF

   DBSELECTAREA("SW4")
   IF SW4->W4_SUFRAMA == "S"
      IF EMPTY(W4_DT_SUFR) && .AND. GIEMITIDA = "S"
         TObs := STR0042 //"AGUARDANDO ENVIO AO SUFRAMA"
         W_Pont := 18
      ENDIF
   ELSE
      IF W4_PORTASN # "S" .AND. W4_FLUXO # "7"
         IF W4_FLUXO # "4"
            IF SWP->(FOUND()) .AND. EMPTY(SWP->WP_MICRO)
               TObs := STR0043 //"AGUARDANDO ENVIO AO ORIENTADOR"
               W_Pont := 4
            ELSE
               IF SWP->(FOUND()) .AND. EMPTY(SWP->WP_TRANSM)
                   TObs := STR0044 //"AGUARDANDO ENVIO AO ORGAO ANUENTE"
                   W_Pont := 4
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   IF SW4->W4_SUFRAMA == "S"
      IF ! EMPTY(SW4->W4_DT_SUFR)
         IF SW4->W4_PORTASN # "S" .AND. SW4->W4_FLUXO # "7"
            IF EMPTY(SW4->W4_DTEDCEX)
               TObs := STR0045+DTOC(SW4->W4_DT_SUFR) //"PROC. NA SUFRAMA DESDE "
               W_Pont := 19
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   IF W4_PORTASN # "S" .AND. W4_FLUXO # "7"
      IF SWP->(FOUND()) .AND. ! EMPTY(SWP->WP_TRANSM) .AND. EMPTY(SWP->WP_VENCTO)
         TObs := STR0046+DTOC(SWP->WP_TRANSM) //"EM ANUENCIA DESDE "
         W_Pont := 5
       ENDIF
   ENDIF

   //IF !SB1->(DBSEEK(xFILIAL("SB1")+SW5->W5_COD_I))
      //SW5->(DBSKIP())
      //LOOP
   //ENDIF

   SA5->(DBSETORDER(3))
   //IF ! SA5->(DBSEEK(xFILIAL("SA5")+SW5->W5_COD_I + SW5->W5_FABR + SW5->W5_FORN))
   If !EICSFabFor(xFILIAL("SA5")+SW5->W5_COD_I + SW5->W5_FABR + SW5->W5_FORN, EICRetLoja("SW5","W5_FABLOJ"), EICRetLoja("SW5","W5_FORLOJ"))
      SW5->(DBSKIP())
      LOOP
   ENDIF

   IF !SW0->(DBSEEK(xFILIAL("SW0")+SW5->W5_CC+SW5->W5_SI_NUM))
      SW5->(DBSKIP())
      LOOP
   ENDIF

   DBSELECTAREA("SW1")
   IF ! PosO1_It_Solic(SW5->W5_CC,SW5->W5_SI_NUM,;
                       SW5->W5_COD_I,SW5->W5_REG,0)
      SW5->(DBSKIP())
      LOOP
   ENDIF
   lLoop:=.F.
   IF EasyEntryPoint("EICIP160")
       Execblock("EICIP160",.F.,.F.,"LOOPGI")//igorchiba 07/07/2010 validacao na fase GI 
   ENDIF     
   IF lLoop
      SW5->(DBSKIP())
      LOOP
   ENDIF

   IF ! EMPTY(SW2->W2_DT_ALTE)
      MDt_IncAlt := SW2->W2_DT_ALTE
   ELSE
      MDt_IncAlt := SW2->W2_PO_DT
   ENDIF

   IF ! EMPTY( SW5->W5_DOCTO_FU )
      MWData := SW5->W5_DT_ENTR
   ELSE
      MWData := SW0->W0__DT + 35
      IF MWData <  SW1->W1_DTENTR_
         MWData :=  SW1->W1_DTENTR_
      ENDIF
   ENDIF

   SW5->(PosO1_ItPedidos(W5_PO_NUM,W5_CC,W5_SI_NUM,W5_COD_I,W5_FABR,W5_FORN,;
                              W5_REG,0,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")))

   SY2->(DBSETORDER(1))
   SY2->(DBSEEK(xFilial()+SW0->W0__POLE))

   SY3->(DBSETORDER(1))
   SY3->(DBSEEK(xFilial("SY3")+SW5->W5_CC))
   SA2->(DBSEEK(xFilial("SA2")+SW5->W5_FORN+EICRetLoja("SW5","W5_FORLOJ")))
   If lLoja
   
      DBSELECTAREA("TRB")    // Rotina Grava_IG000(PBlock)
      TRB->(DBAPPEND())
      TRB->B1_FPCOD   := SB1->B1_FPCOD
      TRB->B1_DESC    := SB1->B1_DESC
      TRB->W0_COMPRA  := SW2->W2_COMPRA
      TRB->W1_PO_NUM  := SW5->W5_PO_NUM
      TRB->A2_NREDUZ  := SA2->A2_NREDUZ
      If EICLoja()
         TRB->A2_LOJA := SA2->A2_LOJA
      EndIF
      TRB->W1_CC      := SW5->W5_CC
      TRB->Y3_DESC    := SUBS(SY3->Y3_DESC,1,25)
      TRB->Y2_DESC    := SY2->Y2_DESC
      TRB->W1_QTDE    := MQtde
      TRB->W0__DT     := SW0->W0__DT
      TRB->W2_DT_IMP  := SW2->W2_DT_IMP
      TRB->WP_TRANSM  := SWP->WP_TRANSM
      TRB->W1_DT_EMB  := SW5->W5_DT_EMB
      // TRB->W1_DTENTR_ := SW1->W1_DTENTR_
      TRB->W1_SI_NUM  := SW5->W5_SI_NUM
      TRB->W1_DTENTR_ := SW5->W5_DT_ENTR
      TRB->W2_DES_IPI := TOBs
      TRB->W6_DT_NF   := SW4->W4_DT 
   // NCF - 11/05/09 - Adicionado tratamento para verificação do porto de destino do PO                 
   aOrdSY9 := SaveOrd({"SY9","SW2"})
   SY9->(DbSetOrder(2))
   SY9->(DBSEEK(xFilial("SY9")+Posicione("SW2", 1, xFilial("SW2")+SW5->W5_PO_NUM , "W2_DEST")))
   TRB->Y9_DESCR   := SY9->Y9_DESCR
   RestOrd(aOrdSY9,.T.)

   EndIf
   IF EasyEntryPoint("EICIP160")
       Execblock("EICIP160",.F.,.F.,"GRVGI")//igorchiba 07/07/2010 gravacao de novos campos da fase GI 
   ENDIF  
   SW5->(DBSKIP())
ENDDO

Return NIL

*------------------------*
FUNCTION  IP160Gr_ID000()
*------------------------*
LOCAL MTesta
LOCAL Chave , _Qtde := 0
Local lPrint:= .T.   //TRP-11/02/2010
Local lLoja := .T.

W_Pont:= 0

//TRP-11/02/2010 - Permite que sejam impressos também os processos que já foram entregues há mais de 4 dias.
//If MsgYesNo("Deseja imprimir também os processos entregues há mais de 4 dias?")
//TDF - 15/02/2011 - Alteração da mensagem para melhor entendimento
If MsgYesNo("Deseja incluir na seleção de dados do relatório, os processos entregues há mais de 4 dias?")   
   lPrint:= .F.
Endif

SW6->(DBSETORDER(4))
SW6->(DBSEEK(xFilial()))

DO WHILE ! SW6->(EOF()) .AND. SW6->W6_FILIAL == xFilial("SW6")

   IncProc(STR0047) //"Lendo dados dos Itens da D.I"

   SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))

   DO WHILE ! SW7->(EOF()) .AND. SW6->W6_HAWB == SW7->W7_HAWB   .AND. ;
                                 xFilial("SW7") == SW7->W7_FILIAL

      IF ! IP160_SelPO(SW7->W7_PO_NUM,SW7->W7_COD_I,SW7->W7_FORN,EICRetLoja("SW7","W7_FORLOJ"))
         SW7->(DBSKIP())
         LOOP
      ENDIF

      IF ! SW2->(DBSEEK(xFilial("SW2")+SW7->W7_PO_NUM))
         SW7->(DBSKIP())
         LOOP
      ENDIF

      IF cArquivo == POR_COMPRADOR
         IF ! EMPTY(cComprador)
             IF SW2->W2_COMPRA <> cComprador
                SW7->(DBSKIP())
                LOOP
             ENDIF
         ENDIF
      ENDIF

      IF ! SB1->(DBSEEK(xFILIAL("SB1")+ SW7->W7_COD_I ))
         SW7->(DBSKIP())
         LOOP
      ENDIF

      //TRP-12/12/07 - Filtro por família
      IF cArquivo == POR_FAMILIA                     
         IF ! EMPTY(cFamilia)
           IF SB1->B1_FPCOD <> cFamilia
              SW7->(DBSKIP())
              LOOP
           ENDIF
        ENDIF
      ENDIF
      SA5->(DBSETORDER(3))
      //IF ! SA5->(DBSEEK(xFILIAL("SA5")+SW7->W7_COD_I + SW7->W7_FABR + SW7->W7_FORN))
      IF !EICSFabFor(xFILIAL("SA5")+SW7->W7_COD_I + SW7->W7_FABR + SW7->W7_FORN, EICRetLoja("SW7","W7_FABLOJ"), EICRetLoja("SW7","W7_FORLOJ"))
         SW7->(DBSKIP())
         LOOP
      ENDIF

      TObs   := SPACE(33)
      W_Pont := 0
      MWData := AVCTOD(SPACE(08))

      MTesta :=.T.

      IF ! EMPTY(SW6->W6_DT_DESE)
         IF SW4->(DBSEEK(xFILIAL("SW4")+SW7->W7_PGI_NUM))
            IF SW4->W4_PORTASN == "S" .AND. SW4->W4_EMITIDA <> "S"
               MTesta := .F.
            ENDIF
         ENDIF
      ENDIF

      IF MTesta
         IF ! EMPTY(SW6->W6_DT_ENTR) .AND. SW6->W6_DT_ENTR < dDataBase - 4 .AND. lPrint     //TRP-11/02/2010
            SW7->(DBSKIP())
            LOOP
          ENDIF
      ENDIF

      IF ! EMPTY(SW6->W6_DT_EMB)
         IF EMPTY(SW6->W6_CHEG)
             TObs   := STR0048 + DTOC(SW6->W6_DT_HAWB) //"EM TRANSITO DESDE "
             MWData := SW6->W6_DT_EMB + 15
             W_Pont := 11
         ELSE
             TObs   := STR0049 + DTOC(SW6->W6_CHEG) //"ATRACADO EM "
             MWData := SW6->W6_DT_EMB + 15
             W_Pont := 11
         ENDIF
      ENDIF

      /*
      IF ! EMPTY(SW6->W6_CHEG)
         IF EMPTY(SW6->W6_DT) .AND. ! EMPTY(SW6->W6_DT_AVE)
            TObs   = STR0050 + DTOC(SW6->W6_DT_AVE) //"AG. PGTO IMPOSTOS DESDE "
            MWData = SW6->W6_CHEG + 8
            W_Pont = 13
         ENDIF
      ENDIF
      */

      IF ! EMPTY(SW6->W6_DT)
         IF EMPTY(SW6->W6_DT_DESEM)

            MDiasUteis := 0
            MDias := 0

            TObs := STR0051 + DTOC(SW6->W6_DT+MDias) //"AG. DESEMBARACO DESDE "
            MWData := SW6->W6_DT+MDias + 4
            W_Pont := 14
         ELSE
            TObs := STR0052 //"AGUARDANDO ENTREGA    "
            MWData := AVCTOD(SPACE(08))
            W_Pont := 15
         ENDIF
      ENDIF

      SY9->(DBSETORDER(2))
      IF EMPTY(SW6->W6_DT)  && Alterado em 27-04-93 pedido p/ Atilio
         IF ! EMPTY(SW6->W6_DTRECDOC) .AND. ! EMPTY(SW6->W6_CHEG)
            IF SY9->(DBSEEK(xFILIAL("SY9")+SW6->W6_LOCAL)) .AND. SY9->Y9_DAP $ cSim
               TObs   := STR0053 //"MAT. AGUARDANDO NO DAP"
               W_Pont := 12
            ENDIF
         ENDIF
      ENDIF

      MQtde := SW7->W7_QTDE
      IF SW7->W7_FLUXO = "4"
         IF ! EMPTY(SW6->W6_DA_DT)
            TObs := STR0054+DTOC(SW6->W6_DA_DT) //"ENTREPOSTADO EM "
            W_Pont := 21
            Chave := SW7->W7_FILIAL+SW7->W7_HAWB+SW7->W7_COD_I
            _Qtde := 0
            MQtde := VAL(STR(MQtde - _Qtde,AVSX3("W7_QTDE",3),AVSX3("W7_QTDE",4)))

            IF VAL(STR(SW7->W7_QTDE - _Qtde,AVSX3("W7_QTDE",3),AVSX3("W7_QTDE",4))) <= 0
               SW7->(DBSKIP())
               LOOP
            ENDIF

         ENDIF
      ENDIF

      IF ! EMPTY(SW6->W6_DT_ENTR)
         TObs   := STR0055 + DTOC(SW6->W6_DT_ENTR) //"ENTREGUE EM "
         W_Pont := 16
      ENDIF

      IF ! SW0->(DBSEEK(xFilial("SW0")+SW7->W7_CC+SW7->W7_SI_NUM))
         SW7->(DBSKIP())
         LOOP
      ENDIF

      IF ! PosO1_It_Solic(SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,;
                          SW7->W7_REG,0)
         SW7->(DBSKIP())
         LOOP
      ENDIF

      DBSELECTAREA("SW5")
      IF PosOrd1_It_Guias(SW7->W7_PGI_NUM,SW7->W7_CC,SW7->W7_SI_NUM,;
                          SW7->W7_COD_I,SW7->W7_FABR,;
                          SW7->W7_FORN,SW7->W7_REG,0,SW7->W7_PO_NUM,EICRetLoja("SW7","W7_FABLOJ"),EICRetLoja("SW7","W7_FORLOJ")) // LDR 07/04/2004

         MChave1 :=  SW7->W7_PGI_NUM + SW7->W7_CC + SW7->W7_SI_NUM + ;
                     SW7->W7_COD_I

         MChave2 :=  SW5->W5_PGI_NUM + SW5->W5_CC + SW5->W5_SI_NUM + SW5->W5_COD_I

         DO WHILE ! SW5->(EOF()) .AND. MChave1 == MChave2      .AND.;
                                       SW5->W5_HAWB  == SW7->W7_HAWB .AND.;
                                       SW5->W5_FILIAL==xFilial("SW5")

            IF (SW7->W7_FABR <> SW5->W5_FABR .AND. IIF(EICLoja(),SW7->W7_FABLOJ <> SW5->W5_FABLOJ,.T.)) .OR. ;
               (SW7->W7_FORN <> SW5->W5_FORN .AND. IIF(EICLoja(),SW7->W7_FORLOJ <> SW5->W5_FORLOJ,.T.)) .OR. ;
               SW7->W7_REG  <> SW5->W5_REG
               SW5->(DBSKIP())
               LOOP
            ENDIF

            IF SW5->W5_HAWB == SW7->W7_HAWB
               EXIT
            ENDIF

            SW5->(DBSKIP())
         ENDDO

         IF EOF() .OR. MChave1 <> MChave2
            SW7->(DBSKIP())
            LOOP
         ENDIF
      ELSE
         SW7->(DBSKIP())
         LOOP
      ENDIF    
      
      lLoop:=.F.
      IF EasyEntryPoint("EICIP160")
         Execblock("EICIP160",.F.,.F.,"LOOPDI")//igorchiba 07/07/2010 validacao da fase DI
      ENDIF     
      IF lLoop
         SW7->(DBSKIP())
         LOOP
      ENDIF

      IF ! EMPTY(SW2->W2_DT_ALTE)
         MDt_IncAlt := SW2->W2_DT_ALTE
      ELSE
         MDt_IncAlt := SW2->W2_PO_DT
      ENDIF

      IF EMPTY( MWData )
         IF ! EMPTY( SW5->W5_DOCTO_FU )   &&Atilio SOLICITOU EM 03/05/93
            MWData := SW5->W5_DT_ENTR
         ELSE
            MWData := SW0->W0__DT + 35
            IF MWData <  SW1->W1_DTENTR_
               MWData :=  SW1->W1_DTENTR_
            ENDIF
         ENDIF
      ENDIF

      IF SUBSTR(TObs,1,17) == STR0056 //"EM TRANSITO DESDE"
         IF MWData <= dDataBase
           MWData := dDataBase + 15
         ENDIF
      ENDIF

      SW7->(PosO1_ItPedidos(W7_PO_NUM,W7_CC,W7_SI_NUM,W7_COD_I,;
                                      W7_FABR,W7_FORN,W7_REG,0,EICRetLoja("SW5","W5_FABLOJ"),EICRetLoja("SW5","W5_FORLOJ")) )

      IF ! SW7->W7_PGI_NUM == SW4->W4_PGI_NUM
         SW4->(DBSEEK(xFILIAL("SW4")+SW7->W7_PGI_NUM))
      ENDIF

      IF SW7->W7_FLUXO =='1'
         SWP->(DBSEEK(xFILIAL("SWP")+SW7->W7_PGI_NUM+SW7->W7_SEQ_LI))
      ENDIF

      //TRB->(DBAPPEND())//ISS - 07/02/11 - Append retirado pois o mesmo acaba gerando "linhas em branco" na work TRB.

      SY1->(DBSETORDER(1))
      SY1->(DBSEEK(xFilial("SY1")+SW0->W0_COMPRA))

      SY2->(DBSETORDER(1))
      SY2->(DBSEEK(xFilial("SY2")+SW0->W0__POLE))

      SY9->(DBSETORDER(2))
      SY9->(DBSEEK(xFilial("SY9")+SW6->W6_LOCAL))
      SY3->(DBSETORDER(1))
      SY3->(DBSEEK(xFilial("SY3")+SW7->W7_CC))
      SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7","W7_FORLOJ"))) 

      If EICLoja() .AND. !Empty(cLoja)
         lLoja:= AllTrim(cLoja) == AllTrim(SW7->W7_FORLOJ)
      EndIf
      
      If lLoja
         // ISS - 13/04/10 - Alteração da fonte de dados dos "TRB->W2_DT_SHIP", "TRB->W1_DT_EMB" e "TRB->W1_DTENTR_"
         TRB->(DBAPPEND())
         TRB->B1_FPCOD     := SB1->B1_FPCOD
         TRB->B1_DESC      := SB1->B1_DESC
         TRB->W0_COMPRA    := SW0->W0_COMPRA
         TRB->W0_COMPRAN   := SY1->Y1_NOME
         TRB->W1_COD_I     := SW1->W1_COD_I
         TRB->W1_PO_NUM    := SW7->W7_PO_NUM
         TRB->W1_CC        := SW7->W7_CC
         TRB->Y3_DESC      := SUBS(SY3->Y3_DESC,1,25)
         TRB->Y2_DESC      := SY2->Y2_DESC
         TRB->W1_QTDE      := SW7->W7_QTDE
         TRB->A2_NREDUZ    := SA2->A2_NREDUZ
         IF EICLoja() 
            TRB->A2_LOJA := SA2->A2_LOJA
         ENDIF 
         TRB->W0__DT       := SW0->W0__DT
         TRB->W2_DT_IMP    := SW2->W2_DT_IMP
         TRB->WP_TRANSM    := SWP->WP_TRANSM
         TRB->W1_SI_NUM    := SW7->W7_SI_NUM
         TRB->W2_DT_SHIP   := SW6->W6_CONEET1
         TRB->W1_DT_EMB    := SW6->W6_DT_ETD
         TRB->W1_DTENTR_   := SW6->W6_PRVENTR
         TRB->W6_IDENTVE   := SW6->W6_IDENTVE
         TRB->W6_PRVDESE   := SW6->W6_PRVDESE
         TRB->W2_DES_IPI   := TObs
         TRB->W6_DT_NF     := SW4->W4_DT
         TRB->W6_DT_ETA    := SW6->W6_DT_ETA
         TRB->W6_DT_EMB    := SW6->W6_DT_EMB
         TRB->W6_CHEG      := SW6->W6_CHEG
         TRB->Y9_DESCR     := SY9->Y9_DESCR
         TRB->W6_DT_DESE   := SW6->W6_DT_DESE
         TRB->W6_DT_ENTR   := SW6->W6_DT_ENTR 
      // NCF - 11/05/09 - Adicionado tratamento para verificação do porto de destino quando LOCAL estiver em branco no SW6                 
      IF EMPTY(SW6->W6_LOCAL)
         aOrdSY9 := SaveOrd("SY9")
         SY9->(DbSetOrder(2))
         SY9->(DBSEEK(xFilial("SY9")+SW6->W6_DEST))
         TRB->Y9_DESCR   := SY9->Y9_DESCR
         RestOrd(aOrdSY9,.T.)
      ELSE
         TRB->Y9_DESCR     := SY9->Y9_DESCR
      ENDIF
      
      ENDIF
      IF EasyEntryPoint("EICIP160")
         Execblock("EICIP160",.F.,.F.,"GRVDI")//igorchiba 07/07/2010 gravacao novos campos fase di
      ENDIF             
      
      SW7->(DBSKIP())
   ENDDO

   SW6->(DBSKIP())
ENDDO

Return NIL

*------------------------------------------------*
FUNCTION IP160_SelPO(PPO_NUM,PCOD_ITEM,PCOD_FORN,PCOD_FORLOJ)
*------------------------------------------------*

DO CASE

   CASE TSelect == POR_PO
      IF ! EMPTY(cCodigo)
         IF ALLTRIM(PPO_NUM) <> ALLTRIM(cCodigo)  //NCF - 11/05/09
            RETURN .F.
         ENDIF
      ENDIF

   CASE TSelect == POR_ITEM
      IF ! EMPTY(cCodigo)
         IF ALLTRIM(PCOD_ITEM) <> ALLTRIM(cCodigo) //NCF - 11/05/09
            RETURN .F.
         ENDIF
      ENDIF
      
   CASE TSelect == POR_FORN //ASK
      //FDR - 21/08/12 - Filtro somente por fornecedor
      IF EICLoja() .AND. EMPTY(cLoja) .AND. !Empty(cCodigo) //DFS - 28/08/12 - Inclusão de tratamento para quando o codigo do fornecedor estiver preenchido   
         IF (ALLTRIM(PCOD_FORN) <> ALLTRIM(cCodigo))
            RETURN .F.
         ENDIF   
      ELSEIF ! EMPTY(cCodigo) .AND. IIF(EICLoja(),!EMPTY(cLoja),.T.)
         //IF (ALLTRIM(PCOD_FORN) <> ALLTRIM(cCodigo) .AND. IIF(EICLoja(),ALLTRIM(PCOD_FORLOJ)<>ALLTRIM(cLoja),.T.))
         // TDF - 15/02/2011 - Inclusão do tratamento de loja
         IF (ALLTRIM(PCOD_FORN) <> ALLTRIM(cCodigo) .OR. IIF(EICLoja(),ALLTRIM(PCOD_FORLOJ)<>ALLTRIM(cLoja),.F.))
            RETURN .F.
         ENDIF
      ENDIF              
ENDCASE

RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±±±±
±±±±±³Fun‡…o   ³IP160Relatorio        ³ Autor ³ A.C.D. / AVERAGE  ³ Data ³ 08.12.97 ³±±±±±±
±±±±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±±±±
±±±±±³Descri‡…o³Impressao do Controle Geral de Importacoes                          ³±±±±±±
±±±±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±±±±
±±±±±³Sintaxe  ³IP160Relatorio()                                                    ³±±±±±±
±±±±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±±±±
±±±±±³Uso      ³SigaEIC                                                             ³±±±±±±
±±±±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function IP160Relatorio()
Private nColAdic := 9  //SO.:0026 OS.:0233/02 FCD
Private oPrn, oFont1, oFont2, oFont3, oFont4, Linha := 0
PRIVATE nPag:=0

PRINT oPrn NAME ""
   oPrn:SetLandsCape()
ENDPRINT

Trb->( DbGoTop() )

AVPRINT oPrn NAME STR0057 //"Controle Geral de Importação"

   ProcRegua(TRB->(LASTREC()))

   DEFINE FONT oFont1  NAME "Times New Roman"    SIZE 0,10  BOLD   OF  oPrn
   DEFINE FONT oFont2  NAME "Times New Roman"    SIZE 0,14  BOLD   OF  oPrn
   DEFINE FONT oFont3  NAME "Courier New"        SIZE 0,08         OF  oPrn
   DEFINE FONT oFont4  NAME "Times New Roman"    SIZE 0,08  BOLD   OF  oPrn

   aFontes := { oFont1, oFont2, oFont3, oFont4 }


  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³ Inicio da Impressao                                     ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
   AVPAGE

        Trb->( DbGoTop() )

        IP160Cabecalho()

        DO WHILE !Trb->( EOF() )

            IncProc(STR0030) //"Imprimindo..."

          /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            ³ Verifica se ha salto de formulario - quebra de pagina        ³
            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
           If Linha >= 2255
              AVNEWPAGE
              IP160Cabecalho()
           Endif

           oPrn:Box( Linha, 1040, Linha+140, 1047 )
//           oPrn:Box( Linha, 1710, Linha+140, 1717 )
           oPrn:Box( Linha, 1715, Linha+140, 1722 )
           oPrn:Box( Linha, 2670, Linha+140, 2677 )

          /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            ³ Imprime a primeira linha                                     ³
            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
           Linha+=30

           oPrn:Say( Linha, xCol(  0), Trans( Trb->W1_PO_NUM, _PictPo ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol( 16), LEFT(Trb->Y3_DESC,15) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol( 32), LEFT(TRB->B1_DESC,25) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol( 58), DTOC( Trb->W0__DT ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol( 68), DTOC( Trb->W2_DT_IMP ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol( 81), DTOC( Trb->WP_TRANSM ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol( 91), DTOC( Trb->W2_DT_SHIP ),aFontes:COURIER_08)          
           oPrn:Say( Linha, xCol(100), DTOC( Trb->W1_DT_EMB ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol(109), DTOC( Trb->W6_DT_ETA ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol(118), Trb->W6_IDENTVE ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol(145), DTOC( Trb->W6_PRVDESE ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol(156), DTOC( Trb->W1_DTENTR_ ) ,aFontes:COURIER_08)
          

          /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            ³ Imprime a segunda linha                                      ³
            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
           Linha+=30

           oPrn:Say( Linha, xCol(  0), Trans( Trb->W1_QTDE, AVSX3("W1_QTDE",6) ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol( 16), Trb->A2_NREDUZ ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol( 58), Trb->W1_SI_NUM ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol( 66+nColAdic), Trans( Trb->W1_PO_NUM, _PictPo ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol( 82+nColAdic), DTOC( Trb->W6_DT_NF ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol(100+nColAdic), DTOC( Trb->W6_DT_EMB ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol(109+nColAdic), DTOC( Trb->W6_CHEG ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol(118+nColAdic), Trb->Y9_DESCR ,aFontes:COURIER_08)
// ACL 12/10/06
//           oPrn:Say( Linha, xCol(145+nColAdic), DTOC( Trb->W6_DT_DESE ) ,aFontes:COURIER_08)
//           oPrn:Say( Linha, xCol(156+nColAdic), DTOC( Trb->W6_DT_ENTR ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol(145), DTOC( Trb->W6_DT_DESE ) ,aFontes:COURIER_08)
           oPrn:Say( Linha, xCol(156), DTOC( Trb->W6_DT_ENTR ) ,aFontes:COURIER_08)
           IF EasyEntryPoint("EICIP160")
              Execblock("EICIP160",.F.,.F.,"ITEMSEC2")//igorchiba 07/07/2010 impressao de item sessao 2
           ENDIF  
          


          /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            ³ Imprime a terceira linha                                     ³
            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
           Linha+=30

           oPrn:Say( Linha, xCol(  0), Left( Trb->W2_DES_IPI, 57 ) ,aFontes:COURIER_08)


          /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            ³ Imprime o separador de registros                             ³
            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
           Linha+=20

           oPrn:Box( Linha+=30,    0, Linha+2, 3200 )


           Trb->( DbSkip() )


        ENDDO

  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³ Fim da Impressao                                        ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
   AVENDPAGE

AVENDPRINT

TRB->(DBGOTOP())
oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±±±±
±±±±±³Fun‡…o   ³IP160Cabecalho        ³ Autor ³ A.C.D. / AVERAGE  ³ Data ³ 08.12.97 ³±±±±±±
±±±±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±±±±
±±±±±³Descri‡…o³Impressao do Cabecalho Principal                                    ³±±±±±±
±±±±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±±±±
±±±±±³Sintaxe  ³IP160Cabecalho()                                                    ³±±±±±±
±±±±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±±±±
±±±±±³Uso      ³SigaEIC                                                             ³±±±±±±
±±±±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function IP160Cabecalho()

Linha:=100

oPrn:Box( Linha    ,    0, Linha+7, 3200 )
//oPrn:Box( Linha+=07,    0, Linha+1, 3200 )

oPrn:Say( Linha+=10, 1650, ALLTRIM(SM0->M0_NOME)      ,aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2) //A.W.R. 4/5/98
oPrn:Say( Linha    , 3175, STR0058+PADL(++nPag,3,"0") ,aFontes:TIMES_NEW_ROMAN_10_BOLD,,,,1) //A.W.R. 4/5/98 //"Pag.: "
//oPrn:Say( Linha+=50, 1650, STR0059                    ,aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2) //"DEPARTAMENTO DE IMPORTACAO"   //NCF-11/05/09 - Comentado para melhoria de produto
oPrn:Say( Linha+=50, 1650, STR0060                    ,aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2) //"CONTROLE GERAL DE IMPORTACOES: DIR. LOGISTICA"
oPrn:Say( Linha    , 3175, STR0061+DTOC(dDataBase)    ,aFontes:TIMES_NEW_ROMAN_10_BOLD,,,,1) //A.W.R. 4/5/98 //"Data: "

oPrn:Box( Linha+=60,    0, Linha+7, 3200 )

IF ! EMPTY(cComprador)
   SY1->(DBSEEK(xFilial("SY1")+ALLTRIM(cComprador)))
   oPrn:Say( Linha+=35, 1750, STR0062+cComprador+" - "+SY1->Y1_NOME,aFontes:TIMES_NEW_ROMAN_10_BOLD,,,,2) //"COMPRADOR: "
ELSEIF ! EMPTY(cFamilia)
   SYC->(DBSEEK(xFilial("SYC")+ALLTRIM(cFamilia)))
   oPrn:Say( Linha+=35, 1750, STR0063+cFamilia+" - "+SYC->YC_NOME,aFontes:TIMES_NEW_ROMAN_10_BOLD,,,,2) //"FAMILIA: "
ENDIF

oPrn:Box( Linha+=060,   0, Linha+7, 3200 )


oPrn:Say( Linha+=07, 1400, STR0064,aFontes:TIMES_NEW_ROMAN_10_BOLD,,,,2) //"LICENCIAMENTO"
oPrn:Say( Linha    , 2185, STR0065,aFontes:TIMES_NEW_ROMAN_10_BOLD,,,,2) //"EMBARQUE"
oPrn:Say( Linha    , 2925, STR0066,aFontes:TIMES_NEW_ROMAN_10_BOLD,,,,2) //"DESEMBARAÇO"

oPrn:Box( Linha    , 1040, Linha+178, 1047 )
// ACL 12/10/06
//oPrn:Box( Linha    , 1710, Linha+178, 1717 )
oPrn:Box( Linha    , 1715, Linha+178, 1722 )
oPrn:Box( Linha    , 2670, Linha+178, 2677 )
oPrn:Box( Linha+=50,    0, Linha+7  , 3200 )

Linha+=30


oPrn:Say( Linha, xCol(  0), STR0067 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"P.O."
oPrn:Say( Linha, xCol( 16), STR0068 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"U.R."
oPrn:Say( Linha, xCol( 32), STR0069 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"DISCRIMINACAO"
oPrn:Say( Linha, xCol( 58), STR0070 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"DT S.I."
oPrn:Say( Linha, xCol( 69), STR0071 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"NEC.EMB."
oPrn:Say( Linha, xCol( 80), STR0072 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"DT TRANS. LI"
oPrn:Say( Linha, xCol( 91), STR0073 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"AUT.EMB."
oPrn:Say( Linha, xCol(100), STR0074 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"PRV.EMB."
oPrn:Say( Linha, xCol(109), STR0075 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"PRV.ATRAC."
oPrn:Say( Linha, xCol(119), STR0076 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"EMBARCADO"
oPrn:Say( Linha, xCol(144), STR0077 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"PRV.DESEMB."
oPrn:Say( Linha, xCol(155), STR0078 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"DT ENTREGA"


Linha+=30

oPrn:Say( Linha, xCol(  0), STR0010 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"QTDE"
oPrn:Say( Linha, xCol( 16), STR0011 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"FORNECEDOR"
oPrn:Say( Linha, xCol( 58), STR0079 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"NR S.I."
oPrn:Say( Linha, xCol( 71+nColAdic), STR0067 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"P.O."
oPrn:Say( Linha, xCol( 82+nColAdic), STR0080 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"VALID. LI"
oPrn:Say( Linha, xCol(100+nColAdic), STR0022 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"DT. EMB."
oPrn:Say( Linha, xCol(110+nColAdic), STR0081 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"DT. ATRAC." //NCF - 20/05/09 - Acerto do posicionamento do título
oPrn:Say( Linha, xCol(119+nColAdic), STR0082 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"LOCAL"
// ACL 12/10/06
//oPrn:Say( Linha, xCol(144+nColAdic), STR0026 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"DT. DESEMB."
//oPrn:Say( Linha, xCol(156+nColAdic), STR0083 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"EFETIVA"
oPrn:Say( Linha, xCol(144), STR0026 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"DT. DESEMB."
oPrn:Say( Linha, xCol(156), STR0083 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"EFETIVA"  
IF EasyEntryPoint("EICIP160")
   Execblock("EICIP160",.F.,.F.,"CABSEC2")//igorchiba 07/07/2010 impressao do cabecalho sessao 2
ENDIF

Linha+=30

oPrn:Say( Linha, xCol(  0), STR0084 ,aFontes:TIMES_NEW_ROMAN_08_BOLD) //"STATUS ATUAL:"
oPrn:Box( Linha+=30,    0, Linha+7, 3200 )
    

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±±±±
±±±±±³Fun‡…o   ³xCol                  ³ Autor ³ A.C.D. / AVERAGE  ³ Data ³ 09.12.97 ³±±±±±±
±±±±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±±±±
±±±±±³Descri‡…o³Retorna um numero de coluna calculado para letra COURIE 8           ³±±±±±±
±±±±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±±±±
±±±±±³Sintaxe  ³IP160BuscaMemo( numero-coluna-normal)                               ³±±±±±±
±±±±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±±±±
±±±±±³Uso      ³SigaEIC                                                             ³±±±±±±
±±±±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function xCol( pnColuna )
Return ( pnColuna * 19 )

*----------------------*
FUNCTION IP160VALID()
*----------------------*
DO CASE 
   CASE !EMPTY(cCodigo) .AND. TSelect == aSelect[1]   // Por Produto
      RETURN ExistCpo("SB1",ALLTRIM(cCodigo))
   CASE !EMPTY(cCodigo) .AND. TSelect == aSelect[2]   // Por P.O
      RETURN ExistCpo("SW2",ALLTRIM(cCodigo))
   CASE !EMPTY(cCodigo) .AND. TSelect == aSelect[3]   // Por Forn
        RETURN ExistCpo("SA2",ALLTRIM(cCodigo))
   CASE EICLoja() .And. !EMPTY (cLoja) .AND. TSelect == aSelect[3]
        RETURN ExistCpo("SA2",ALLTRIM(cLoja))
   //CASE EICLoja() .And. EMPTY (cLoja) .AND. TSelect == aSelect[3]
        //RETURN Posicione("SA2", 1, xFilial("SA2")+cCodigo, "A2_LOJA")

ENDCASE

RETURN .T.         

*-----------------*
FUNCTION IP160F3()
*-----------------*
DO CASE 
   CASE TSelect == aSelect[1]   // Por Produto
      oGetCodigo:cF3:="SB1"
   CASE TSelect == aSelect[2]   // Por P.O
      oGetCodigo:cF3:="SW2"
   CASE TSelect == aSelect[3]   // Por Forn
        oGetCodigo:cF3:="FOR" //FDR - 17/08/12 - Alterado consulta padrão para retorno de loja
ENDCASE 

// TDF - 15/02/2011 - Inclusão do tratamento de loja
If EICLOJA() .AND. TSelect == aSelect[3]
   @ 95,10 SAY oSayLoja VAR "Loja" Of oPanel SIZE 23,8 PIXEL
   @ 95,35 MSGET oGetLoja VAR cLoja PICTURE cPict VALID IP160VALID() SIZE 33,08 OF oPanel PIXEL
EndIf    

If Type("oSayLoja") == "O" .and. !(TSelect == aSelect[3])
   oSayLoja:Hide()
   oSayLoja:Refresh()
EndIf
If Type("oGetLoja") == "O" .and. !(TSelect == aSelect[3])
   oGetLoja:Hide()
   oGetLoja:Refresh()
EndIf

RETURN  

//--------------------------------------------------------------------------------------*
// FIM DO PROGRAMA EICIP160.PRW                                                         *
//--------------------------------------------------------------------------------------*
