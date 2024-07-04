//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "EICTR330.CH"

#COMMAND E_RESET_AREA => SW2->(DBSETORDER(1)) ; SW5->(DBSETORDER(1)) ;
                       ; SW7->(DBSETORDER(1)) ;
                       ; Work->(E_EraseArq(WorkFile)) ; DBSELECTAREA(nOldArea)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR330 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 28.09.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Avalia‡Æo de Fornecedores em P.O.s                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR330()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// EOS - OS 579/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICTR330
// um parametro como .T. identificando que é schedulado 
******************
Function EICTR330S
******************
EICTR330(.T.)
RETURN NIL

/*
Funcao      : EICTR330
Objetivos   : Ajustar o relatório para a versão 811 - Release 4
Autor       : Juliano Paulino Alves - JPA
Data 	    : 11/08/2006
Obs         :
*/
***********************
Function EICTR330(lSXD)
***********************
EICTR330R3(lSXD,.T.)
Return .T.

******************************
Function EICTR330R3(lSXD,p_R4)
******************************
LOCAL _PictItem := ALLTRIM(X3Picture("B1_COD")), TForn:=SW2->W2_FORN, TForLoj:= EICRetLoja("SW2","W2_FORLOJ")
LOCAL WorkFile, nOldArea:=SELECT(), cForn, TDt_I, TDt_F, TTipo, nI, cLoja:=""
LOCAL cSaveMenuh, nCnt, cTitulo, oDlg, oGet, oPanel, lValidForn:=.F., bMsg 
PRIVATE  nOpcA:=0
//Igor chiba 01/07/2010 para alterar no ponto de entrada
PRIVATE aDados :={STR0001,; //"Work"    
                STR0002,; //"Este relatorio objetiva mostrar o desempenho"
                STR0003,; //"do fornecedor no que se refere ao prazo de "
                STR0004,; //"embarque"
                "M",;
                132,;
                "",;
                "",;
                STR0005,; //"Prazo do Fornecedor em P.O.s"
                { "Zebrado", 1,"Importação", 1, 2, 1, "",1 },;
                STR0006,; //"EICTR330"
                { {||EICTR330totFil() } , {|| TotalPrzMed(.T.)} }  }

Private nPrazoMed:=0
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
PRIVATE T_DBF:={ { "WKFILIAL" , "C" , AVSX3("W2_FILIAL",3) , 0 } ,;
               { "WKNOMFIL"   , "C" , 21,0},;   
               { "WKPO_NUM"   , "C" , AVSX3("W2_PO_NUM",3) , 0 } ,;
               { "WKPO_DT"    , "D" ,  8 , 0 } ,;
               { "WKPODT_PRO" , "D" ,  8 , 0 } ,;
               { "WKCOD_I"    , "C" , AVSX3("W3_COD_I",3) , 0 } ,;
               { "WKPOVL_US"  , "N" , 15 , 2 } ,;
               { "WKDESCR"    , "C" ,  9 , 0 } ,;
               { "WKDT_REQ"   , "D" ,  8 , 0 } ,;
               { "WKDT_EFE"   , "D" ,  8 , 0 } ,;
               { "WKPRAZO"    , "N" ,  5 , 0 } ,;
               { "WKORDEM"    , "C" ,  5 , 0 } } //THTS - 06/11/2017 - Utilizado para ordenar os registros

IF(EasyEntryPoint("EICTR330"),Execblock("EICTR330",.F.,.F.,"ESTR_WORK"),)

PRIVATE TB_Campos:={ {"WKNOMFIL"   ,"", AVSX3("W2_FILIAL",5),AVSX3("W2_FILIAL",6) },;   // "Filial"
                   {"WKCOD_I"    ,"", STR0007,_PictItem           } ,; //"Item"
				   {"WKPO_NUM"   ,"", STR0008,_PictPo  	          } ,; //"Nº P.O."
				   {"WKPO_DT"    ,"", STR0009                     } ,; //"Data P.O."
				   {"WKPODT_PRO" ,"", STR0011                     } ,; //"Proforma"
				   {"WKDT_REQ"   ,"", STR0013                     } ,; //"Req.Ship."
				   {"WKDT_EFE"   ,"", STR0014                     } ,; //"Embarque"
				   {"WKPRAZO"    ,"", STR0015,"@E 99,999"         } ,; //"Prazo"
				   {"WKPOVL_US"  ,"", STR0016,"@E 999,999,999.99" } ,; //"Valor em US$"
				   {"WKDESCR"    ,"", STR0030                     } }, aRCampos:={} //"Descrição"

//JPA - 11/08/2006 - Relatório Personalizavel - Release 4
Private oReport
Private lR4   := If(p_R4 == NIL,.F.,.T.) .AND. FindFunction("TRepInUse") .And. TRepInUse()

IF(EasyEntryPoint("EICTR330"),Execblock("EICTR330",.F.,.F.,"TB_CAMPOS"),)

PRIVATE _PictGI := ALLTRIM(X3Picture("W4_GI_NUM"))
PRIVATE cMarca := GetMark(), lInverte := .F.
PRIVATE cCadastro := STR0017//"Avaliação de Fornecedores em P.O.s"
PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private aHeader[0], nUsado:=0, aReturn := aDados[10], aPrzMedFil:={}, nTotalMedFil:=0
Private lEmail := !lSXD = NIL  // EOS - OS 579/02

bCampo  := {|nCPO| Field(nCPO) }

SW2->(DBSETORDER(2))
SW5->(DBSETORDER(3))
SW7->(DBSETORDER(2))  // JBS - 12/09/2003 ORDER(3)

WorkFile := E_CriaTrab(,T_DBF,"Work") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

Work->(avzap())
IndRegua("Work",WorkFile+TEOrdBagExt(),"WKFILIAL+WKORDEM")

WHILE .T.
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Variaveis utilizadas para parametros                         ³
  //³ mv_par01      // Fornecedor                                  ³
  //³ mv_par02      // Data inicial                                ³  
  //³ mv_par03      // Data final                                  ³
  //³ mv_par04      // Tipo                                        ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  // EOS - OS 579/02 Se for schedulado, chama o pergunte como .F. somente para
  // inicializar as variaveis mv_par?? e atraves do setprint carrega as variaveis
  
  //AOM - 04/01/2011 - Criada função generica para adicionar o campo loja no grupo do SX1   
  //VerLojaSX1("EIC330")   //THTS - nopada a funcao, pois nao podera mais dar reclock nos fontes. Os campos loja estao corretos no AtuSX.
  IF !Pergunte("EIC330",IIF(lEmail,.F.,.T.))
     E_RESET_AREA
     RETURN .F.
  ENDIF

  
  aFilSW2:=AvgSelectFil(.T.,"SW2") // RS 03/01/06    - Filiais Selecionadas 
  
  IF lEmail  // EOS - OS 576/02
     aDados[11] := SetPrint(aDados[1],aDados[11],,@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
  ENDIF
  TForn  :=mv_par01
  TForLoj:=mv_par02
  TDt_I  :=mv_par03
  TDt_F  :=mv_par04
  TTipo  :=mv_par05
  IF(EasyEntryPoint("EICTR330"),Execblock("EICTR330",.F.,.F.,"INIVAR"),)//Igor chiba 01/07/2010 para alterar no ponto de entrada pergunte

  cForn  :=TForn+" "+BuscaFabr_Forn(TForn+IIF(EICLoja(),TForLoj,""))
  cTitulo:=" De "+DTOC(TDt_I)+" … "+DTOC(TDt_F)+;
           IF(TTipo=1," ("+STR0023+")",IF(TTipo=2," ("+STR0024+")"," ("+STR0031+")")) //"Em Aberto"###"Encerrados"###"Ambos
  
  IF EICLOJA()
     cLoja:= TForLoj
  ENDIF
  
  cFilAntOld:=cFilAnt  // Salva a Filial Atua - RS 03/01/06
  FilAtu:="*"
  
  nTotalMedFil:=0
  
      
  IF lEmail
  
     for nI:=1 to Len(aFilSW2)
         cFilSW2:=aFilSW2[nI]
         If !Empty(aFilSW2[nI])  //ASK
            cFilAnt:=cFilSW2   // seta a filial atual com as filiais habilitadas para o usuario 
                            // nas chamadas à xfilial(alias), caso alias = "Exclusivo" retornara cFilAnt, senao "  "
                            // RS - 03/01/06
         EndIf
         TR330Grava(bMsg,TForn,TDt_I,TDt_F,TTipo,@nPrazoMed,TForLoj)
     next
     cFilAnt:=cFilAntOld   // Restaura a filial - RS 03/01/05
          
     IF Work->(Easyreccount("Work")) > 0
        FilAtu:="*"
        E_Report(aDados,aRCampos,.T.,.F.)
     ENDIF
     EXIT	      
  ELSE  
     for nI:=1 to Len(aFilSW2)
         cFilSW2:=aFilSW2[nI]
         cFilAnt:=cFilSW2   // seta a filial atual com as filiais habilitadas para o usuario 
                            // nas chamadas à xfilial(alias), caso alias = "Exclusivo" retornara cFilAnt, senao "  "
                            // RS - 03/01/06
  
         Processa({|lEnd|TR330Grava(bMsg,TForn,TDt_I,TDt_F,TTipo,@nPrazoMed,TForLoj)},STR0019) //"Pesquisando informa‡äes..."
     next    
     cFilAnt:=cFilAntOld   // Restaura a filial - RS 03/01/05
     
     IF Work->(Easyreccount("Work")) > 0
        Work->(dbGoTop())
        
        aDados[7]:="Fornecedor "+cForn+" - "+cTitulo
        
        aSvTb_Campos:=ACLONE(Tb_Campos)  // Salva Tb_Campos com o nome da Filial - RS 04/01/06
        
        npos:=ASCAN(Tb_Campos,{|aTab|aTab[1]=="WKNOMFIL"})
        IF nPos <> 0
           ADEL(Tb_Campos,nPos)
           ASIZE(Tb_Campos,LEN(Tb_Campos)-1)
        ENDIF

	    aRCampos:=E_CriaRCampos(Tb_Campos)
        aRCampos[7,3]:="D"
        
        Tb_Campos:=ACLONE(aSvTb_Campos)  // Restaura a Tb_Campos com a Filial - RS 04/01/06        
        
        nPrazoMed:=nTotalMedFil/Work->(Easyreccount("Work"))
              	
        //AEVAL(aPrzMedFil,{|aTab|nPrazoMed+=aTab[3]})
        lPadrao:=.T.//Igor chiba 01/07/2010 
		IF(EasyEntryPoint("EICTR330"),Execblock("EICTR330",.F.,.F.,"ANTES_TELA"),)//Igor chiba 01/07/2010 desviar tela
        
        oMainWnd:ReadClientCoors()
        IF lPadrao //Igor chiba 01/07/2010 para alterar no ponto de entrada
           DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+cTitulo;
               FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
 	           OF oMainWnd PIXEL  
           @ 00,00 MsPanel oPanel Prompt "" Size 60,20 of oDlg       //LRL 28/04/04 - Alinhamento MDI.
           @ 5,6  SAY STR0020 SIZE 40,8 of oPanel PIXEL //"Fornecedor"
           @ 3,40 MSGET cForn WHEN .F. SIZE 100,10 of oPanel  PIXEL 
           
           IF EICLOJA()
              @ 5,160 SAY "Loja" SIZE 40,8 of oPanel PIXEL 
              @ 3,200 MSGET cLoja WHEN .F. SIZE 40,10 of oPanel PIXEL
           ENDIF
           
           @ 5,300 SAY STR0021 SIZE 60,8 of oPanel PIXEL //"Prazo Médio"
           @ 3,360 MSGET nPrazoMed WHEN .F. SIZE 40,10 of oPanel PIXEL  PICT "@E 999.99"
                                      
           DEFINE SBUTTON FROM 4,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (FilAtu:="*",If (lR4,(oReport := ReportDef(),oReport:PrintDialog()),E_Report(aDados,aRCampos))/*JPA - 11/08/06*/) ENABLE OF oPanel

           oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
		   
		   oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT             
           oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		   
        ACTIVATE MSDIALOG oDlg ON INIT (Work->(DBGOTOP()),EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
                                                                         {||nOpca:=0,oDlg:End()}))  //LRL 28/04/04//Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
        
        ELSE 
           IF(EasyEntryPoint("EICTR330"),Execblock("EICTR330",.F.,.F.,"GER_TELA"),)//Igor chiba 01/07/2010 
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
RETURN NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR330Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 28/09/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR330Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICSIGA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------------------------------------------------------
STATIC FUNCTION TR330Grava(bMsg,TForn,TDt_I,TDt_F,TTipo,nPrazoMed,TForLoj)
*----------------------------------------------------------------------------
LOCAL  MValor_Us:=0, MAberto:='N'
LOCAL _PictItem := ALLTRIM(X3Picture("B1_COD"))
LOCAL nSaldo_Q  := 0, nQuant:= 0, nPreco:= 0, nRegPo:= 0

//DBSELECTAREA("Work")
//ZAP


//DBSELECTAREA("SW3")

IF !EMPTY(TDt_I) 
   SW2->( DBSEEK(xFilial("SW2") + TForn + IIF(EICLoja(),TForLoj,"")+ DTOS(TDt_I),.T.) )
ELSE
   SW2->( DBSEEK(xFilial("SW2") + TForn + IIF(EICLoja(),TForLoj,""), .T.) )
ENDIF   

IF !lEmail  // EOS OS 578/02 Se schedulado, desvia as apresentações em tela
   ProcRegua(SW2->(Easyreccount("SW2"))-1)
ENDIF
nQtdeRegFil:=0
nPrazoMed:=0
DO WHILE !SW2->(EOF()) .AND. SW2->W2_FILIAL = cFilSW2 .AND. (SW2->W2_FORN = TForn .And. IIF(EICLoja(),SW2->W2_FORLOJ == TForLoj,.T.));
                      .AND. If(!EMPTY(TDt_F), SW2->W2_PO_DT <= TDt_F, .T.) 

   
   SW3->(DBSEEK(xFilial("SW3")+SW2->W2_PO_NUM))
   
   IF !lEmail // EOS OS 578/02 Se schedulado, desvia as apresentações em tela	                      
      IncProc(STR0022+TRAN(SW3->W3_PO_NUM,_PictPO)+" - Ötem "+TRAN(SW3->W3_COD_I,_PictItem)) //"Processando P.O. "
   ENDIF

   MAberto  := 'N'
   DO WHILE !SW3->(EOF()) .AND. SW3->W3_FILIAL == xFilial("SW3") ;
                          .AND. SW3->W3_PO_NUM = SW2->W2_PO_NUM 
      MValor_Us:= 0
      IF SW3->W3_FLUXO = "5" .OR. SW3->W3_SEQ <> 0 
         SW3->(DBSKIP()) 
         LOOP
      ENDIF
      
      lLoop:=.F.//Igor chiba 01/07/2010 validar
      IF(EasyEntryPoint("EICTR330"),Execblock("EICTR330",.F.,.F.,"LOOP"),)
      IF lLoop  
         SW3->(DBSKIP()) 
         LOOP  
      ENDIF  //Igor chiba 01/07/2010 validar          
      
      IF SW3->W3_FLUXO == "7"
		 nRegPo:= SW3->(RECNO())
         SW3->(DBSKIP())         
         nPGI := SW3->W3_PGI_NUM 
         SW3->(DBGOTO(nRegPo))

         IF PosOrd1_It_Guias(nPGI,SW3->W3_CC,SW3->W3_SI_NUM,SW3->W3_COD_I,SW3->W3_FABR,SW3->W3_FORN,SW3->W3_REG,SW3->W3_SEQ,SW3->W3_PO_NUM,EICRetLoja("SW3","W3_FABLOJ"),EICRetLoja("SW3","W3_FORLOJ")) // LDR 07/04/2004
			nSaldo_Q := SW5->W5_SALDO_Q
			nQuant   := SW5->W5_QTDE
    		nPreco   := SW5->W5_PRECO 
		 ELSE
            SW3->(DBSKIP())
			LOOP
		 ENDIF
      ELSE
         nSaldo_Q := SW3->W3_SALDO_Q
         nQuant   := SW3->W3_QTDE
         nPreco   := SW3->W3_PRECO 
      ENDIF       
      
      IF TTipo = 1
         IF nSaldo_Q <= 0  // JBS - 19/07/2004 Alterei para testar Saldo <= 0
			SW3->(DBSKIP())
			LOOP
		 ENDIF
         MValor_Us+=CalcFob_Us( nSaldo_Q , nPreco )
         MAberto  := 'S'         
         
      ELSEIF TTipo = 2
      	 IF nSaldo_Q > 0   // JBS - 19/07/2004 Alterei para testar Saldo > 0 
            SW3->(DBSKIP())
            LOOP
         ENDIF
         MValor_Us+=CalcFob_Us( nQuant , nPreco )
         MAberto  := 'N'
         
      ELSE
         IF nSaldo_Q > 0  // JBS - 19/07/2004 Alterei para testar Saldo > 0
            MValor_Us+=CalcFob_Us( nSaldo_Q , nPreco )
            MAberto  := 'S'
         ELSE
         	MValor_Us+=CalcFob_Us( nQuant , nPreco )          
         ENDIF
      ENDIF

      IF MValor_Us = 0
         SW3->(DBSKIP())
         LOOP
      ENDIF

      //SW7->(DBSEEK(xFilial()+SW3->W3_CC+SW3->W3_SI_NUM))

      lTemEmbarque := .F.      
      SW7->(DBSEEK(xFilial("SW7")+SW3->W3_PO_NUM))
      DO WHILE !SW7->(EOF()) .AND. SW7->W7_FILIAL == xFilial("SW7") .AND. ;
                                   SW7->W7_PO_NUM == SW3->W3_PO_NUM        
         IF SW7->W7_COD_I == SW3->W3_COD_I   .AND. ;
            (SW7->W7_FABR  == SW3->W3_FABR    .AND. IIF(EICLoja(),SW7->W7_FABLOJ  == SW3->W3_FABLOJ,.T.)) .AND. ;
            (SW7->W7_FORN  == SW3->W3_FORN    .AND. IIF(EICLoja(),SW7->W7_FORLOJ  == SW3->W3_FORLOJ,.T.)) .AND. ;
            SW7->W7_REG   == SW3->W3_REG 	 
		                  
            lTemEmbarque := .T. 
            IF !SW6->( DBSEEK(xFilial("SW6")+SW7->W7_HAWB) )
               MDt_Efe:= dDataBase
            ELSE
               MDt_Efe:= IF(!EMPTY(SW6->W6_DT_EMB),SW6->W6_DT_EMB,IF(!EMPTY(SW6->W6_DT_ETD),SW6->W6_DT_ETD,dDataBase))
            ENDIF
		
            Work->( DBAPPEND() )
            Work->WKFILIAL  := SW2->W2_FILIAL
            Work->WKNOMFIL  := SW2->W2_FILIAL+'-'+AvgFilName({SW2->W2_FILIAL})[1]
            Work->WKPO_NUM  := SW2->W2_PO_NUM
            Work->WKPO_DT   := SW2->W2_PO_DT
            Work->WKPODT_PRO:= SW2->W2_DT_PRO
            Work->WKCOD_I   := SW3->W3_COD_I
            Work->WKDT_REQ  := SW3->W3_DT_EMB
            Work->WKDT_EFE  := MDt_Efe
            Work->WKPOVL_US := MValor_Us
            Work->WKDESCR   := IF(MAberto='S',STR0023,STR0024) //'Em Aberto'###'Encerrado' 
            Work->WKPRAZO   := E_VerPrazo (Work->WKDT_EFE - Work->WKDT_REQ)
            Work->WKORDEM   := STR(99999-Work->WKPRAZO,5,0) //THTS - 06/11/2017 - Utilizado para ordenar os registros
            
            nQtdeRegFil++
            IF(EasyEntryPoint("EICTR330"),Execblock("EICTR330",.F.,.F.,"GRAVA_WORK"),)
            
      	    nPrazoMed+=Work->WKPRAZO
      	    nTotalMedFil+=Work->WKPRAZO
      	    

         ENDIF	
         SW7->(DBSKIP())
      ENDDO
      
      IF !lTemEmbarque
         MDt_Efe:= dDataBase
		
         Work->( DBAPPEND() )
         Work->WKFILIAL  := SW2->W2_FILIAL
         Work->WKNOMFIL  := SW2->W2_FILIAL+'-'+AvgFilName({SW2->W2_FILIAL})[1]
         Work->WKPO_NUM  := SW2->W2_PO_NUM
         Work->WKPO_DT   := SW2->W2_PO_DT
         Work->WKPODT_PRO:= SW2->W2_DT_PRO
         Work->WKCOD_I   := SW3->W3_COD_I
	     Work->WKDT_REQ  := SW3->W3_DT_EMB
	     Work->WKDT_EFE  := MDt_Efe
	     Work->WKPOVL_US := MValor_Us
	     Work->WKDESCR   := IF(MAberto='S',STR0023,STR0024) //'Em Aberto'###'Encerrado' 
         Work->WKPRAZO   := E_VerPrazo (Work->WKDT_EFE - Work->WKDT_REQ)
         Work->WKORDEM   := STR(99999-Work->WKPRAZO,5,0) //THTS - 06/11/2017 - Utilizado para ordenar os registros
                   
         IF(EasyEntryPoint("EICTR330"),Execblock("EICTR330",.F.,.F.,"GRAVA_WORK"),)
         
         nPrazoMed+=Work->WKPRAZO
         nQtdeRegFil++
                  
    	 nTotalMedFil+=Work->WKPRAZO
    	 

      ENDIF
      SW3->(DBSKIP())
   ENDDO
   SW2->( DBSKIP() )
ENDDO


IF Work->(Easyreccount("Work")) > 0
   nPrazoMed:=ROUND((nPrazoMed/nQtdeRegFil * 100)/100,0) 
   AADD(aPrzMedFil,{cFilSW2,AvgFilName({cFilSW2})[1],nPrazoMed})
ENDIF

RETURN .T.
                                               

*----------------------------------------------------------------------------
FUNCTION TR330ValForn(TForn)
*----------------------------------------------------------------------------
If !ExistCpo("SA2",mv_par01)
   Return .F.
Else
   If Empty(mv_par02)
      SA2->(DbSeek(xFilial()+mv_par01))
      mv_par02 := If(SA2->(FieldPos("A2_LOJA")) > 0,SA2->A2_LOJA,"")   // GFP - 25/04/2012 - Gatilha Loja
   EndIf
EndIf

If Empty(TForn)
   Help("",1,"AVG0001001") //"Informe o Código do Fornecedor"###"Informação"
   Return .F.
Endif
If !SW2->(DBSEEK(xFilial("SW2")+TForn))
   Help("",1,"AVG0001002") //"Não há P.O.s p/ este Fornecedor"###"Informação"
   Return .F.
Endif
Return .T. 

*----------------------------------------------------------------------------
FUNCTION TR330ValData(dDataIni, dDataFim)
*----------------------------------------------------------------------------
IF !EMPTY(dDataFim)
   IF dDataIni > dDataFim
      Help("", 1, "AVG0003006")//"Data Inicial Maior que Data Final",1)
      RETURN .F.
   ENDIF
ENDIF
RETURN .T.
*---------------------------------------------------------------------------
User Function Rodape_Rel()
*---------------------------------------------------------------------------

IF(EasyEntryPoint("EICTR330"),Execblock("EICTR330",.F.,.F.,"RODAPE_REL"),)

Return .T.


*----------------------------------------------------------------------------
FUNCTION EICTR330totFil()                                                    
*----------------------------------------------------------------------------
IF FilAtu == "*" 
   PulaLinha()
   @ Linha,01 PSAY AVSX3("W2_FILIAL",5)+".: "+Work->WKNOMFIL  //"Filial : "
   PulaLinha()
   FilAtu:=Work->WKFILIAL
ENDIF   

if FilAtu#Work->WKFILIAL            
   
   TotalPrzMed()
   PulaLinha()
   PulaLinha()
        
   FilAtu:=Work->WKFILIAL
   
   @ Linha,01 PSAY AVSX3("W2_FILIAL",5)+".: "+Work->WKNOMFIL  //"Filial : "    
   PulaLinha()      
ENDIF
RETURN .T.

*---------------------*
STATIC Function TotalPrzMed(lUlt)
*---------------------*
Local nPos

IF(EasyEntryPoint("EICTR330"),Execblock("EICTR330",.F.,.F.,"RODAPE_REL"),)
   
IF FilAtu=="*"
   FilAtu:=cFilSW2
ENDIF

npos:=ASCAN(aPrzMedFil,{|fil|fil[1] == FilAtu})
TR_RelMed(75,aPrzMedFil[npos,3])
PulaLinha()       
return .t.

*--------------------------*                 
Static Function PulaLinha(cTexto)           
*--------------------------*
IF(valtype(cTexto) = "U", cTexto:="",.T.)
IF Linha >= 60
   Linha := 0
   Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
   If ! Empty(cTexto)
     Linha += 1
     @ Linha, 010 PSAY cTexto
   EndIf
Else                                                                     
   Linha++
Endif

Return .T.

//JPA - 11/08/2006 - Definições do relatório personalizável
****************************
Static Function ReportDef()
****************************                     
Local PicItem := ALLTRIM(X3Picture("B1_COD")), TForn:=SW2->W2_FORN, TForLoj:= EICRetLoja("SW2","W2_FORLOJ")
Local PicPO   := ALLTRIM(X3Picture("W2_PO_NUM"))

//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SW2", "SW3"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EICTR330", STR0005, "EIC330"  , {|oReport| ReportPrint(oReport)}, STR0002+" "+STR0003+" "+STR0004)

//Define os objetos com as seções do relatório
oSecao2 := TRSection():New(oReport,"Filial",{"Work"},{})
oSecao1 := TRSection():New(oReport,"Itens",aTabelas,aOrdem)


//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1, "WKCOD_I"   , "Work", STR0007   , PicItem            , AVSX3("W3_COD_I",3) , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKPO_NUM"  , "Work", STR0008   , PicPO              , AVSX3("W2_PO_NUM",3), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKPO_DT"   , "Work", STR0009   , /*Picture*/        , 08                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKPODT_PRO", "Work", STR0011   , /*Picture*/        , 08                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKDT_REQ"  , "Work", STR0013   , /*Picture*/        , 08                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKDT_EFE"  , "Work", STR0014   , /*Picture*/        , 08                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKPRAZO"   , "Work", STR0015   , "@E 99,999"        , 05                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKPOVL_US" , "Work", STR0016   , "@E 999,999,999.99", 15                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKDESCR"   , "Work", STR0030   , /*Picture*/        , 10                  , /*lPixel*/, /*{|| code-block de impressao }*/)
                                                                               
oSecao1:SetTotalInLine(.F.)
oSecao1:SetTotalText("Prazo Médio em Dias")

oTotal:= TRFunction():New(oSecao1:Cell("WKPRAZO"),NIL,"SUM",/*oBreak*/,"",/*"@E 99,999"*/,{|| Work->WKPRAZO/Work->(Easyreccount("Work")) },.T.,.F.)
oTotal:SetTotalInLine(.F.)
                                                    
//Definição das colunas de impressão da seção 2 
TRCell():New(oSecao2,"WKNOMFIL" , "Work", AVSX3("W2_FILIAL",5), /*Picture*/, 22 , /*lPixel*/, /*{|| code-block de impressao }*/)
oReport:Section("Filial"):Cell("WKNOMFIL"):SetCellBreak()
                                 
oReport:bOnPageBreak :={||oReport:Section("Filial"):PrintLine()} 

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("Itens")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Itens"),"SW2",1,{|| xFilial("SW2")+W2_FORN+EICRetLoja("SW2","W2_FORLOJ")})
TRPosition():New(oReport:Section("Itens"),"SW3",1,{|| xFilial("SW3")+SW2->W2_PO_NUM})

oReport:SetMeter(Work->(EasyRecCount("Work")))
Work->(dbGoTop())

oReport:Section("Filial"):Init()
//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Itens"):Init()

//Laço principal
Do While Work->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Itens"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Itens"):Finish()
//Fim da impressão da seção 2
oReport:Section("Filial"):Finish()                                

return .T.


