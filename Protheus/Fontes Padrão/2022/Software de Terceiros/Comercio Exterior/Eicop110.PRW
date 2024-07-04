#INCLUDE "Eicop110.ch"
#include "AVERAGE.CH"
//#include "FiveWin.ch"

#COMMAND E_RESET_AREA => SW7->(DBSETORDER(1)) ; SWZ->(DBSETORDER(1)) ;
                       ; Work->(E_EraseArq(WorkFile)) ;
                       ; DBSELECTAREA(nOldArea)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICOP110 ³ Autor ³ AVERAGE/CRISTIANO     ³ Data ³ 15.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao de Apropriacao de CFO                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void EICOP110()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION EICOP110

local _PictItem := ALLTRIM(X3Picture("B1_COD"))
local _PictPGI  := ALLTRIM(X3Picture("W4_PGI_NUM"))
LOCAL WorkFile, nOldArea:=SELECT()
LOCAL oDlg, oGet, nOpcA:=0, nLastRec := 0
LOCAL aOrdEIJ := {} //NCF-18/05/2010
LOCAL cFilEIJ := ""
LOCAL aButtons := {}//FDR-27/12/11
PRIVATE aButtonsPE := {}

PRIVATE T_DBF := {{"WKPLI_NUM" ,"C",10,0} ,;
                  {"WKOPERACA" ,"C",05,0} }  // Coloquei mais pra baixo RHP

PRIVATE Tb_Campos:={{"WKPLI_NUM","",STR0001,_PictPGI} ,; //"NR. PLI"
                    {{|| Work->WKOPERACA+' '+IF(SWZ->(DBSEEK(xFilial()+Work->WKOPERACA)),LEFT(SWZ->WZ_DESC,20),SPACE(20))}, "", STR0002}} //"Operação"

PRIVATE  cHawb_Num:=SW6->W6_HAWB
PRIVATE cMarca := GetMark(), lInverte := .F., MAbandona:=.F.
PRIVATE nOpRad := 1, oCboNCM, oCboPLI, oCboPO, cNCM, cPLI, cPO
PRIVATE aNCMs := {}, aPLIs := {}, aPOs := {}
Private cMsg  := ""
Private lLoop := .T.


IF EasyEntryPoint("IC086DI2")
  EXECBLOCK("IC086DI2",.F.,.F.,{1,NIL})
ENDIF                  

IF EasyEntryPoint("EICOP110")
   Execblock("EICOP110",.F.,.F.,"WORK_ESTRU")
   IF !Empty(aButtonsPE)
      aButtons := AClone(aButtonsPE)
   ENDIF
ENDIF

AADD(T_DBF, {"WKCOD_I"   ,"C",AVSX3("W3_COD_I",3),0} )
AADD(T_DBF, {"WKNRDI"    ,AVSX3("W6_DI_NUM",2),AVSX3("W6_DI_NUM",3),0} )
AADD(T_DBF, {"WKHAWB"    ,"C",AVSX3("W7_HAWB"   ,AV_TAMANHO),0} )
AADD(T_DBF, {"WKDESCR"   ,"C",22,0} )
AADD(T_DBF, {"WKQTDE"    ,"N",13,3} )
AADD(T_DBF, {"WKVALOR"   ,"N",14,2} )
AADD(T_DBF, {"WKRECNO"   ,"N",08,0} )
AADD(T_DBF, {"WKREG"     ,"N",AVSX3("W7_REG"    ,AV_TAMANHO),0} )
AADD(T_DBF, {"WKNCM"     ,"C",AVSX3("W7_NCM"    ,AV_TAMANHO),0} )
AADD(T_DBF, {"WKPLI"     ,"C",AVSX3("W7_PGI_NUM",AV_TAMANHO),0} )
AADD(T_DBF, {"WKPO"      ,"C",AVSX3("W7_PO_NUM" ,AV_TAMANHO),0} )
AADD(T_DBF, {"WKSINUM"   ,"C",AVSX3("W7_SI_NUM" ,AV_TAMANHO),0} )
AADD(T_DBF, {"WKCC"      ,"C",AVSX3("W7_CC"     ,AV_TAMANHO),0} )

AADD(Tb_Campos,{{||TRAN(Work->WKCOD_I,_PictItem)+' '+Work->WKDESCR}, "", STR0003})//"Item"
AADD(Tb_Campos,{"WKHAWB","", STR0004 }) //"House"
AADD(Tb_Campos,{"WKNRDI", "", STR0005} ) //"Nr. D.I."
AADD(Tb_Campos,{"WKQTDE","",STR0007,"@E 999,999,999.999"}) //"Qtde"
AADD(Tb_Campos,{"WKVALOR","",STR0008,"@E 99,999,999,999.99"}) //"Valor"
AADD(Tb_Campos,{"WKREG","",STR0009} ) //"Parcela"

IF EasyEntryPoint("EICOP110")
   Execblock("EICOP110",.F.,.F.,"APOS_WORK_ESTRU")//ASR 02/01/2006
ENDIF

WorkFile := E_CriaTrab(,T_DBF,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("Work",WorkFile+TEOrdBagExt(),"WKPLI_NUM+WKCOD_I+STR(WKREG,"+Alltrim(Str(AVSX3("W7_REG",3)))+")")

SW7->(DbSetOrder(1)) // FILIAL+Hawb (Itens Declaracao)
SWZ->(DbSetOrder(2)) // FILIAL+OPERACAO (Operacao)

//FDR - 27/12/2011 - Alterado botões para o Ações Relacionadas    
//DFS - 03/05/13 - Inclusão de refresh nos botões para atualização da tela de Apropriação de CFOP.
Aadd(aButtons,{"EDIT",{|| OP110Edita(),oMark:oBrowse:Refresh()},STR0024})// "Altera"
Aadd(aButtons,{"RESPONSA",{|| OP110Selec(),oMark:oBrowse:Refresh()},STR0025})// "Altera Todos"

WHILE .T.
  DEFINE MSDIALOG oDlg TITLE STR0010 From 9,0 To 20,50 OF GetWndDefault() //"Manutenção da Apropriação de CFO"
  
  oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 20/07/2015
  oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
  
  nOpcA:=0
  @ 1.4,0.8 SAY OemToAnsi(STR0011) OF oPanel //" N§ do Processo"
  @ 1.4,8.0 MSGET cHawb_Num F3 "SW6" SIZE 65,10 VALID( OP110ChkPo(cHawb_Num) ) OF oPanel

  ACTIVATE MSDIALOG oDlg ON INIT ;
                    EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
                                     {||nOpca:=0,oDlg:End()})   CENTERED

  If nOpca = 0
     E_RESET_AREA
     Return .F.
  Endif

  //NCF - 18/05/2010 - Quando o CFO é apropriado por fora, o fator impeditivo de alteração é se existir algum item com apropriação feita no regime de tributação.
  aOrdEIJ := SaveOrd({"EIJ"})
  IF EIJ->(FIELDPOS("EIJ_OPERAC")) # 0 .AND. SW8->(FIELDPOS("W8_OPERACA")) # 0 //AWR - 18/10/2008 NFE
     cFilEIJ:=xFilial("EIJ")
     lTemOperacaoEIJ:=.F.
     IF EIJ->(DbSeek(cFilEIJ+cHawb_Num))
        DO While !EIJ->(EOF()) .AND. EIJ->EIJ_FILIAL == cFilEIJ .AND. EIJ->EIJ_HAWB == cHawb_Num
           IF !EMPTY(EIJ->EIJ_OPERAC)
              lTemOperacaoEIJ:=.T.
              EXIT
           ENDIF
           EIJ->( DBSKIP() )
        ENDDO
     ENDIF
     
     IF lTemOperacaoEIJ
        cMsg := "Já existe CFO apropriado por regime de tributação. Para prosseguir, remova as adições e verifique as informações do(s) regime(s) de tributação"
        lLoop := .T.
        
        IF EasyEntryPoint("EICOP110")
           Execblock("EICOP110",.F.,.F.,"APROPRIA_CFO")
        ENDIF
        
        If !Empty(cMsg)
           MsgInfo(cMsg, "Aviso")
        EndIf
        
        If lLoop
           LOOP
        EndIf
     ENDIF
  ENDIF 
  RestOrd(aOrdEIJ)
  
  Processa({|| ;
           SW7->(DBSEEK(xFilial()+cHawb_Num)),;
           nLastRec := 0,;
           SW7->(DBEval({||++nLastRec},;
                        {||SW7->W7_SEQ = 0 },;
                       {||!SW7->(EOF()) .AND.;
                           SW7->W7_FILIAL == xFilial("SW7") .AND.;
                           SW7->W7_HAWB   == cHawb_NUM})),;
           ProcRegua(nLastRec),;
           OP110Grava(cHawb_Num) }) // Grava informacoes no work.
  
  If(EasyEntryPoint("EICOP110"),ExecBlock("EICOP110",.F.,.F.,"ORDENA_CFO"),)  // LGS - 01/08/2013 - CRIAÇÃO DE PONTO DE ENTRADA PARA ORDENAÇÃO DE C.F.O. NA TELA DE APROPRIAÇÃO
  
  IF Work->(Easyreccount("Work")) > 0
     Work->(DBGOTOP())
     oMainWnd:ReadClientCoords()//So precisa declarar uma fez para o Programa todo
     
     DEFINE MSDIALOG oDlg TITLE STR0012+cHawb_Num ; //"Manutenção da Apropriação de CFO - Nº de Processo: "
            FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
            TO oMainWnd:nBottom-60,oMainWnd:nRight-5 OF oMainWnd PIXEL
          
     oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{18,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
     oMark:oBrowse:bLDblClick := {|| OP110Edita()}
	 
	 oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oMark:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	 //FDR - 27/12/2011 - Alterado para EnchoiceBar
     ACTIVATE MSDIALOG oDlg ON INIT ;
        (EnchoiceBar( oDlg,{|| If (OP110VldOk(),(nOpca:=1,IF(OP110ChkPo(cHawb_Num),oDlg:End(),)),)},;
                    {||nOpca:=0,oDlg:End()},,aButtons))
     
     //Nopado por FDR - 27/12/2011 - Alterado para EnchoiceBar
     /*
     ACTIVATE MSDIALOG oDlg ON INIT ;
           (OP110Bar( oDlg,{|| If (OP110VldOk(), (nOpca:=1,IF(OP110ChkPo(cHawb_Num),oDlg:End(),)),)},;
                          {||nOpca:=0,oDlg:End()},; // {|| OP110Edita()},;
                          {|| OP110Edita()},;
                          {|| OP110Selec()}))  // CENTERED//LRL 08/04/04 - Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT            
     */

     If nOpca = 0
        LOOP
     Endif

     Work->(DBGOTOP())

     Processa( ;
        {||   ProcRegua(Work->(Easyreccount("Work"))),;
              Work->(DBEVAL({||;
                 SW7->(DBGOTO(Work->WKRECNO)) ,;
                 SW7->(RecLock("SW7",.F.))           ,;
                 SW7->W7_OPERACA:=Work->WKOPERACA    ,;
                 IF(EasyEntryPoint("EICOP110"),EXECBLOCK("EICOP110",.F.,.F.,"GRAVA_SW7"),),;
                 OP110AtuOPerac(Work->WKHAWB,Work->WKCOD_I, Work->WKPLI_NUM,Work->WKSINUM,Work->WKPO,Work->WKCC,Work->WKREG,Work->WKOPERACA ),;
                 SW7->(MSUNLOCK()) },,;
                 {|| IncProc(STR0013+Work->WKOPERACA),; //"Atualizando Operação "
                 !SW7->(EOF()) } ))  })

  ENDIF

  IF Work->(Easyreccount("Work")) == 0
     Help(" ",1,"EICSEMREG")
  ENDIF
ENDDO

RETURN (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OP110ChkPo³ Autor ³ AVERAGE/CRISTIANO     ³ Data ³ 15.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz consistencias do campo PO                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OP110ChkPo( cHawb_Num )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICOP110                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION OP110ChkPo ( cHawb_Num )
IF ! SW7->(DBSEEK(xFilial()+cHawb_Num))
   HELP(" ",1,"REGNOIS")
   RETURN (.F.)
ENDIF

//ASR 21/10/2005
SF1->(DBSETORDER(5))
IF SF1->(DBSEEK(xFilial()+cHawb_Num+"1")) .OR. SF1->(DBSEEK(xFilial()+cHawb_Num+"3"))//TIPO 1 PRIMEIRA E TIPO 3 UNICA
   MSGINFO(STR0033)//"Não é possível apropriar CFO para este Processo, pois o mesmo já possui Nota Fiscal"
   RETURN (.F.)
ENDIF

RETURN (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OP110Grava³ Autor ³ AVERAGE/CRISTIANO     ³ Data ³ 15.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava informacoes no arquivo de Work.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void OP110Grava(cHawb_Num)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICOP110                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION OP110Grava( cHawb_Num )

Work->(avzap())

IF ! SW7->(DBSEEK(xFilial()+cHawb_Num))
   HELP(" ",1,"REGNOIS")
   RETURN (.F.)
ENDIF

//TRP-03/11/08 - Zera os arrays antes de carregar as informações referentes ao processo selecionado.
aNCMs:= {}
aPLIs:= {}
aPOs:= {}

ChkFile("EYJ")
EYJ->(DBSetOrder(1)) //EYJ_FILIAL+EYJ_COD
WHILE ! SW7->(EOF()) .AND. XFILIAL("SW7")=SW7->W7_FILIAL .AND. SW7->W7_HAWB = cHawb_NUM
  IF SW7->W7_SEQ != 0
     SW7->(DBSKIP())
     LOOP
  ENDIF

  IncProc(STR0014) //"Gerando arquivo de trabalho ... "

  Work->(DBAPPEND())
  Work->WKPLI_NUM := SW7->W7_PGI_NUM
  Work->WKOPERACA := SW7->W7_OPERACA

  /* Carregar a informação, conforme o cadastro de produto - dados complementares */
  If Empty(Work->WKOPERACA)
      If EYJ->(DBSeek(xFilial() + SW7->W7_COD_I)) .And. EYJ->(FieldPos("EYJ_OPERAC")) > 0 .AND. !Empty(EYJ->EYJ_OPERAC)
         Work->WKOPERACA := EYJ->EYJ_OPERAC
      EndIf
  EndIf

  SW6->(DBSEEK(xFilial("SW6")+SW7->W7_HAWB))
  IF EasyEntryPoint("IC086DI2")
    EXECBLOCK("IC086DI2",.F.,.F.,{2,Work->WKOPERACA})
  ENDIF
  
  IF EasyEntryPoint("EICOP110")
     Execblock("EICOP110",.F.,.F.,"GRAVA_WORK")
  ENDIF

  Work->WKCOD_I  := SW7->W7_COD_I
  Work->WKDESCR  := IF(SB1->(DBSEEK(xFilial()+SW7->W7_COD_I)),MSMM(SB1->B1_DESC_P,22,1),"")
  Work->WKQTDE   := SW7->W7_QTDE
  Work->WKVALOR  := SW7->W7_QTDE*SW7->W7_PRECO
  Work->WKREG    := SW7->W7_REG
  Work->WKHAWB   := SW7->W7_HAWB
  Work->WKNRDI   := SW6->W6_DI_NUM
  Work->WKRECNO  := SW7->(RECNO())
  Work->WKNCM    := SW7->W7_NCM
  Work->WKPLI    := SW7->W7_PGI_NUM
  Work->WKPO     := SW7->W7_PO_NUM
  Work->WKSINUM  := SW7->W7_SI_NUM
  Work->WKCC     := SW7->W7_CC
  
  // EOS 
  IF ASCAN( aNCMs, SW7->W7_NCM ) == 0
     AADD( aNCMs, SW7->W7_NCM )
  ENDIF
  IF ASCAN( aPLIs, SW7->W7_PGI_NUM ) == 0
     AADD( aPLIs, SW7->W7_PGI_NUM )
  ENDIF
  IF ASCAN( aPOs, SW7->W7_PO_NUM ) == 0
     AADD( aPOs, SW7->W7_PO_NUM )
  ENDIF
  
  SW7->(DBSKIP())
END

RETURN NIL


RETURN (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OP110Edita³ Autor ³ AVERAGE/CRISTIANO     ³ Data ³ 15.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Edita informacoes no arquivo de Work.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void OP110Edita()                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICOP110                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OP110Edita()
#DEFINE ALTURA_LINHA 1
LOCAL nOpcA, nAreaOld := SELECT()
LOCAL cOperacao := Work->WKOPERACA
LOCAL cOp_Descr := Space(20)
local _PictItem := ALLTRIM(X3Picture("B1_COD"))
LOCAL cItem     := TraNsf(Work->WKCOD_I,_PictItem)+' '+Work->WKDESCR
LOCAL oGetOperacao, oGetOp_Descr
LOCAL bOp_Descr := {|| SWZ->(DbSetOrder(2)),;
                       cOp_Descr:=IF(SWZ->(DBSEEK(xFilial()+cOperacao)),LEFT(SWZ->WZ_DESC,20),SPACE(20)),;
                       oGetOp_Descr:Refresh() }
LOCAL bAltera   := {|| Work->WKOPERACA := cOperacao }
LOCAL cPictDI   := ALLTRIM(X3Picture("W6_DI_NUM"))
PRIVATE oDlgOP , nLin := 0.4
PRIVATE cCod1,cCod2,cDesc1,cDesc2  // Codigos genericos para uso em campos novos via RDMAKE - RHP
PRIVATE oCod1,oCod2,oDesc1,oDesc2

DEFINE MSDIALOG oDlgOP TITLE STR0015 From 7,12 To 27,78 OF oMainWnd //ERA 26,78 //"Apropriação de CFO - Altera"
   nOpcA:=0
   @ nLin,0.8 SAY STR0001 OF oDlgOP //"Nr. PLI"
   @ nLin,6.0 MSGET Work->WKPLI_NUM SIZE 40,10 OF oDlgOP
   nLin += ALTURA_LINHA

   @ nLin,0.8 SAY STR0002 OF oDlgOP //"Operação"
   @ nLin,6.0 MSGET oGetOperacao VAR cOperacao F3 "SWZ" Valid( Eval(bOp_Descr), OP110ChkOp(cOperacao,.f.,oGetOperacao),IF(EasyEntryPoint("IC086DI2"),EXECBLOCK("IC086DI2",.F.,.F.,{5,cOperacao}),.T.) ) ;
        SIZE 14,10 OF oDlgOP

   @ nLin,12 MSGET oGetOp_Descr VAR cOp_Descr SIZE 95,10 OF oDlgOP
   nLin += ALTURA_LINHA
   IF EasyEntryPoint("IC086DI2")
      EXECBLOCK("IC086DI2",.F.,.F.,{3,cOperacao})
   ENDIF
  
   IF EasyEntryPoint("EICOP110")
      Execblock("EICOP110",.F.,.F.,"TELA_WORK")
   ENDIF

   @ nLin,0.8 SAY STR0003 OF oDlgOP //"Item"
   @ nLin,6.0 MSGET cItem SIZE 140,10 OF oDlgOP

   nLin += ALTURA_LINHA
   @ nLin,0.8 SAY STR0004 OF oDlgOP //"House"
   @ nLin,6.0 MSGET Work->WKHAWB SIZE 62,10 OF oDlgOP

   nLin += ALTURA_LINHA
   @ nLin,0.8 SAY STR0005 OF oDlgOP //"Nr. D.I."
   @ nLin,6.0 MSGET Work->WKNRDI SIZE 35,10 OF oDlgOP PICTURE cPictDI

   nLin += ALTURA_LINHA
   @ nLin,0.8 SAY STR0007 OF oDlgOP //"Qtde"
   @ nLin,6.0 MSGET Work->WKQTDE SIZE 40,10 OF oDlgOP

   nLin += ALTURA_LINHA
   @ nLin,0.8 SAY STR0008 OF oDlgOP //"Valor"
   @ nLin,6.0 MSGET Work->WKVALOR SIZE 43,10 OF oDlgOP

   nLin += ALTURA_LINHA
   @ nLin,0.8 SAY STR0009 OF oDlgOP //"Parcela"
   @ nLin,6.0 MSGET Work->WKREG SIZE 8,10 OF oDlgOP

   AEval( oDlgOP:aControls, {|obj| If( obj:ClassName() == "TGET", obj:Disable(), ) })
   oGetOperacao:Enable()
   oGetOperacao:SetFocus()
   Eval( bOp_Descr )

   nLin += 3*ALTURA_LINHA

   @ nLin,19 BUTTON "&Ok" SIZE 35,12 OF oDlgOP Action (nOpca:=1,;
           If(OP110ChkOp(cOperacao,.T.,oGetOperacao),;
              (Eval(bAltera),IF(EasyEntryPoint("IC086DI2"),EXECBLOCK("IC086DI2",.F.,.F.,{2,cOperacao}),),;
              IF(EasyEntryPoint("EICOP110"),EXECBLOCK("EICOP110",.F.,.F.,"GRAVA_WORK"),),;
              oDlgOP:End(),oMark:oBrowse:Refresh()), ) )

   @ nLin,32 BUTTON STR0016 SIZE 35,12 OF oDlgOP Action (nOpca:=0,oDlgOP:End()) //"&Cancel"

ACTIVATE MSDIALOG oDlgOP CENTERED
  
SELECT(nAreaOld)

If nOpca = 0
   RETURN (NIL)
Endif

Eval(bAltera)

RETURN (NIL)

*-------------------------------------*
Static Function OP110ChkOp(cOperacao,lOk,oGet)
*-------------------------------------*
DEFAULT lOk := .F.

IF !EMPTY(cOperacao) .AND. !SWZ->(DbSeek(xFilial()+cOperacao)) // .AND. !EMPTY(cOperacao) .Or. EMPTY(cOperacao) .AND. lOk
   Help(" ",1,"REGNOIS")
   oGet:SetFocus()
   RETURN .F.
ENDIF

RETURN .T.

*-----------------------------------------------*
Function OP110Selec()
*-----------------------------------------------*               
LOCAL oDlg, bBtnOk, bBtnCancel, nSelOp, oRadio 
LOCAL cOperacao  := Work->WKOPERACA
LOCAL cOp_Descr  := Space(20), oGetOperacao, oGetOp_Descr
LOCAL bOp_Descr := {|| SWZ->(DbSetOrder(2)),;
                       cOp_Descr:=IF(SWZ->(DBSEEK(xFilial()+cOperacao)),LEFT(SWZ->WZ_DESC,20),SPACE(20)),;
                       oGetOp_Descr:Refresh() }
Begin Sequence

   nSelOp := 0
   
   oMainWnd:ReadClientCoords()        
    
/*   DEFINE MSDIALOG oDlg TITLE STR0001 FROM ; 
                   oMainWnd:nTop+170,oMainWnd:nLeft+10 TO ;
                   oMainWnd:nBottom-170,oMainWnd:nRight-90 OF oMainWnd PIXEL	*/

   //Johann - 12/08/2005 - chamado 014870
   DEFINE MSDIALOG oDlg TITLE STR0001 FROM ; 
                   0, 0 TO 234, 708 OF oMainWnd PIXEL
          
      bBtnOk     := {|| nSelOp:= 1, oDlg:End() }
      bBtnCancel := {|| nSelOp:= 0, oDlg:End() }
      
      @ 14, 30 TO 75, 85 LABEL "Selecao" OF oDlg PIXEL 
 
      @ 19, 35 RADIO oRadio VAR nOpRad ITEMS "Todos", "NCM","PLI","PO" 3D SIZE 45,13 ;
                                              PIXEL OF oDlg ON CHANGE (OP110CBOX(ODLG)) 
                                   
      @ 03, 142 SAY OemToAnsi("NCM") OF oDlg PIXEL                                               
      @ 10, 140 COMBOBOX oCboNCM VAR cNCM ITEMS aNCMs SIZE 70,18 PIXEL WHEN {||nOpRad==2 }
      
      @ 28, 142 SAY OemToAnsi("PLI") OF oDlg PIXEL
      @ 35, 140 COMBOBOX oCboPLI VAR cPLI ITEMS aPLIs SIZE 70,18 PIXEL WHEN {||nOpRad==3 }
      
      @ 53, 142 SAY OemToAnsi("PO") OF oDlg PIXEL
      @ 60, 140 COMBOBOX oCboPO  VAR cPO  ITEMS aPOs  SIZE 70,18 PIXEL WHEN {||nOpRad==4 }
      
      @ 90, 030 SAY STR0018 OF oDlg PIXEL //"Operação "
      @ 90, 065 MSGET oGetOperacao Var cOperacao F3 "SWZ" ;
                      Valid( Eval(bOp_Descr), OP110ChkOp(cOperacao,.f.,oGetOperacao) );
                      SIZE 14,10 PIXEL OF oDlg
  
      @ 90, 110 SAY STR0019 OF oDlg PIXEL //"Descrição "
      @ 90, 140 MSGET oGetOp_Descr VAR cOp_Descr SIZE 95,10 PIXEL OF oDlg
      oGetOp_Descr:Disable()
      Eval(bOp_Descr)

      @ 30, 260 BUTTON "&Ok"     SIZE 35,14 PIXEL OF oDlg Action ; //( EVAL(bBtnOk) )
                 If(OP110ChkOp(cOperacao,.T.,oGetOperacao),(nSelOp:=1, oDlg:End()), )                    
      @ 60, 260 BUTTON "&Cancel" SIZE 35,14 PIXEL OF oDlg Action ( EVAL(bBtnCancel) ) //"&Cancel"

   ACTIVATE MSDIALOG oDlg CENTERED

   IF nSelOp > 0         
      IF nOpRad == 0
         BREAK
      ELSEIF nOpRad == 1
         bBlocSel := {|| !Work->(EOF()) }
      ELSEIF nOpRad == 2
         bBlocSel := {|| ALLTRIM(Work->WKNCM) == ALLTRIM(cNCM)}
      ELSEIF nOpRad == 3
         bBlocSel := {|| ALLTRIM(Work->WKPLI) == ALLTRIM(cPLI)}      
      ELSEIF nOpRad == 4
         bBlocSel := {|| ALLTRIM(Work->WKPO) == ALLTRIM(cPO)}
      ENDIF
      nRegWork := Work->(Recno())
      Work->(dbGoTop())
      DO WHILE !Work->(EOF())
         IF EVAL(bBlocSel)
            Work->WKOPERACA := cOperacao
         ENDIF
         Work->(dbSkip())
      ENDDO
      Work->(dbGoTo(nRegWork))   
   ENDIF
    
End Sequence
Return NIL

*------------------------------*
FUNCTION OP110CBOX(ODLG)
*------------------------------*
IF nOpRad==1
  oCboNCM:DISABLE()
  oCboPLI:DISABLE()  
  oCboPO:DISABLE()
ELSEIF nOpRad==2  // Escolheu NCM, inibe combo ref. a PLI e PO e habilita o de NCM
  oCboNCM:ENABLE()
  oCboPLI:DISABLE()  
  oCboPO:DISABLE()
ELSEIF nOpRad==3  // Escolheu PLI, inibe combo ref. a NCM e PO e habilita o de PLI
  oCboPLI:ENABLE()
  oCboNCM:DISABLE()  
  oCboPO:DISABLE()
ELSEIF nOpRad==4  // Escolheu PO, inibe combo ref. a NCM e PLI e habilita o de PO
  oCboPO:ENABLE()
  oCboNCM:DISABLE()  
  oCboPLI:DISABLE()  
ENDIF
RETURN .T.

/*
Funcao          : OP110VldOk()
Parametros      : OP110VldOk_CFO
Objetivos       : Retornar .T. ou .F. no botão Ok final do CFO
Autor           : Diogo Felipe dos Santos
Data/Hora       : 02/12/2010 - 15:10
Revisao         : 
Obs             :
*/      

*------------------------------*
Function OP110VldOk()
*------------------------------*
                                 
Private lValidCFO := .T.

IF EasyEntryPoint("EICOP110") 
   ExecBlock("EICOP110",.F.,.F.,"OP110VldOk_CFO")
Endif

Return lValidCFO

/*
Funcao          : OP110AtuOperac()
Parametros      : cHawb,cItem,cPGi,cSi,cPo,cCc,cReg,cOperac
Objetivos       : Atualizar o campo Operação nos itens da Invoice
Autor           : Thiago Rinaldi Pinto
Data/Hora       : 25/11/2011 
Revisao         : 
Obs             : Atualizar o CFO da tabela SW8 para que o CFO da Nota Fiscal fique correto quando CFO apropriado manualmente.
*/  
*------------------------------------------------------------------------*
Static Function OP110AtuOperac(cHawb,cItem,cPGi,cSi,cPo,cCc,cReg,cOperac)
*------------------------------------------------------------------------*
Local aOrdSW8:= {}
Local cChave:=cHawb+cPgi+cPo+cSi+AvKey(cCc,"W8_CC")+cItem+STR(cReg,AVSX3("W1_REG",3),0)//FDR - 02/10/12 - Ajuste na variável cCc para seek

If EIJ->(FIELDPOS("EIJ_OPERAC")) # 0 .AND. SW8->(FIELDPOS("W8_OPERACA")) # 0
   aOrdSW8 := SaveOrd({"SW8"})
   SW8->(DbSetOrder(3)) 
   If SW8->(dbSeek(xFilial("SW8")+ cChave))
      SW8->(Reclock("SW8",.F.))
      SW8->W8_OPERACA:= cOperac
      SW8->(MsUnlock())
   Endif
   RestOrd(aOrdSW8,.T.)
Endif

Return Nil
