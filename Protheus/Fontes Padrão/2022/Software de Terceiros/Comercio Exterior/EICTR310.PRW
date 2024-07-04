#INCLUDE "Eictr310.ch"
//#include "FiveWin.ch"
#include "Average.ch"


#COMMAND E_RESET_AREA => If(SELECT("TRB") # 0,TRB->(E_EraseArq(WorkFile)),);
                       ; DBSELECTAREA(nOldArea)

#DEFINE   Tit310       STR0001 //" HISTÓRICO DA MOVIMENTAÇÃO "
#DEFINE   Largura       132
#DEFINE   Comprime      .T.
#DEFINE   MsgNao       STR0002 //" NÃO ENCONTRADO NO HISTÓRICO"
#DEFINE   Quantidade   STR0003 //"Por Quantidade    "
#DEFINE   Valor        STR0004 //"Por Valor em Dólar"
#DEFINE   CCUS_ARQ      1                        
#DEFINE   FORN_ARQ      2
#DEFINE   DESP_ARQ      3
#DEFINE   COMP_ARQ      4
#DEFINE   AGEN_ARQ      5
#DEFINE   ITEM_ARQ      6
#DEFINE   CLIE_ARQ      7


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICTR310 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 20.02.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Historico de Compras                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR310()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTR310

LOCAL WorkFile, nOldArea:=SELECT()

LOCAL aDados :={"TRB",;
                STR0005,;  //"Este relatório irá exibir uma estatística sobre"
                STR0006,;  //"o desempenho de "
                "",;
                "M",;
                 80,;
                "",;
                "",;
                STR0007,;  //"Histórico Mensal"
                { STR0008, 1,STR0009, 1, 2, 1, "",1 },;   //"Zebrado"###"Importação"
                "EICTR310",;
                { {|| .T. } , {|| .T. }  }  }


LOCAL T_DBF:= { NIL                   ,;
              {"WKMES"  , "C",  2, 0} ,;
              {"WKQTDE" , "N", 13, 3} ,;
              {"WKVARQ" , "N",  7, 2} ,;
              {"WKVALOR", "N", 15, 2} ,;
              {"WKVARV" , "N",  7, 2} ,;
              {"WKDESC" , "C", 40, 0} }

LOCAL TB_Funcoes:={ {"-4", STR0010   , "F5" , STR0010 } ,; //"Relatório"###"Relatório"
                    {"-9",{||TR310Graf()}, "F10", STR0011   } } //"Gráfico"

LOCAL TB_Campos:=;
    { {{||TR310Trans(.F.)},, STR0012},;   //"Código"
      {{||_Desc}          ,, STR0037},;   //"Descr."
      {{||_NMes}          ,, STR0013},;   //"Mês"
      {{||_Qtd}           ,, STR0014},;   //"Qtde."
      {{||_VarQ}          ,, STR0015},;   //"Var.(%)"
      {{||_Val}           ,, STR0016},;   //"Valor em US$"
      {{||_VarV}          ,, STR0015}    }//"Var.(%)"

LOCAL aRCampos:=;
    { {"TR310Trans(.T.)",STR0012,"E"},;    //"Código"
      {"_Desc"          ,STR0037,"E"},;    //"Descr."
      {"_NMes"          ,STR0013,"E"},;    //"Mês"
      {"_Qtd"           ,STR0014,"D"},;    //"Qtde."
      {"_VarQ"          ,STR0015,"D"},;    //"Var.(%)"
      {"_Val"           ,STR0016,"D"},;    //"Valor em US$"
      {"_VarV"          ,STR0015,"D"}    } //"Var.(%)"


LOCAL GETLIST:={}, L1:=5, indice, _mes, dUlt_Atz:=EasyGParam("MV_ULT_ATZ"),;
      num_opc, T_Fields:={}, MDescAtu:=STR0017, MPictGet:='@!' //"Atualizado até "

LOCAL lValidMes:=.F., lValidAno:=.F., nOpcA:=0, aLenCod:={5,6,3,3,3,LEN(SB1->B1_COD),6}

//LOCAL bValid:={||(lValidMes  .OR. TR300ValMes(TMes))  .AND. ;
//                 (lValidAno  .OR. TR300ValAno(TAno,MTipo)) }

LOCAL  MGet_MA:=MGet_Arq:=MGet_Cod:=.T., MDescArq, pos_ano, pos_tipo,;
      pos_cod:=0

Local lR4 := FindFunction("TRepInUse") .And. TRepInUse()

Local bImprime := {|| (If(!lR4,;
                           E_Report(aDados,aRCampos),;
                           (ReportDef(aDados, aRCampos), oReport:PrintDialog()) ))}

Private oReport, oSecao1

PRIVATE R_Dados:={Tit310,Largura,Comprime,NIL}, Mes_F,;
        R_Campos:={}, MQtdTot,MValTot, atabcod:={0,0,0,0,0,0,0}, MCodigo:=""

PRIVATE _Cod, _Desc, _NMes, _VarQ, _VarV, _Qtd, _Val, MPictQt , MPictItem,;
        R_Funcoes:={{|| .T. } , {|| .T. }}, TMes, TAno, TCodigo:=SPACE(LEN(SB1->B1_COD)),;
        T_Opcoes:={ PadR(AVSX3("W0__CC",5),15),;
                    STR0018 ,; //"Fornecedor     "
                    STR0019 ,; //"Despachante    "
                    STR0020 ,; //"Comprador      "
                    STR0021 ,; //"Agente         "
                    STR0022 ,; //"Item           "
                    STR0023 }, cCampoF4:="Y3_COD", cDescCpo:="Y3_DESC" //"Cliente        "

PRIVATE aArq:={{"SY3","Y3_DESC"  },;
               {"SA2","A2_NOME"  },;
               {"SY5","Y5_NOME"  },;
               {"SY1","Y1_NOME"  },;
               {"SY4","Y4_NOME"  },;
               {"SB1","B1_DESC_P"},;
               {"SA1","A1_NOME"  } }

PRIVATE cMarca := GetMark(), lInverte := .F., TQual:=1, TArq:=1

PRIVATE cCadastro := STR0024 //"Histórico da Movimentação" 
PRIVATE oDlg//chiba 
PRIVATE MTipo//chiba 

//PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
//        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999

PRIVATE aHeader[0],nUsado:=0
PRIVATE oPanel //LRL 27/04/04
num_opc:=LEN(TB_Campos)

FOR indice=1  TO  num_opc
    AADD(R_Campos,{TB_Campos[indice,1],TB_Campos[indice,2],"D"})
NEXT
R_Campos[1,1]:="TR310Trans(.T.)" ; R_Campos[1,3]:=R_Campos[2,3]:="E"

num_opc:=LEN(T_Opcoes)

TMes:=MONTH(dUlt_Atz)
TAno:=Str(YEAR(dUlt_Atz),4,0)

lPadrao:=.T.
IF(EasyEntryPoint("EICTR310"),Execblock("EICTR310",.F.,.F.,"INIVAR"),)//chiba


DO WHILE .T.

  MGet_MA:=MGet_Arq:=MGet_Cod:=.T. ; ASIZE(T_Fields,0)
  MQtdTot:=MValTot:=0
  TQual := 0
                       
  L1:=5
  IF lPadrao 
     DEFINE MSDIALOG oDlg FROM  9,10 TO 23,70 TITLE cCadastro OF oMainWnd
       
    @  6, 6   TO 96,  77 LABEL STR0025  OF oDlg  PIXEL //"Seleção"

        @ 16, 10 RADIO oRad1 VAR TArq  ITEMS T_Opcoes[1],T_Opcoes[2],T_Opcoes[3],;
                                             T_Opcoes[4],T_Opcoes[5],T_Opcoes[6],;
                                             T_Opcoes[7] 3D SIZE 55,10 PIXEL     ;
                       ON CHANGE TR_HistSet(TArq,@MTipo,@MPictQt,@MPictItem)

        @  6, 86 TO  48, 175 LABEL STR0026            OF oDlg PIXEL //"Data Base"
        @ 23, 89 SAY STR0027            SIZE 40,10 OF oDlg PIXEL //"Mês / Ano   "
        @ 23,120 MSGET TMes Picture "99"       SIZE 20,10 OF oDlg PIXEL ;

        //@ 23,132 SAY " / "                     SIZE 10,10 OF oDlg PIXEL
        @ 23,140 MSGET TAno Picture "9999"     SIZE 32,10 OF oDlg PIXEL ;

        SETKEY(VK_F4,{||TR300HLP()})
        @ 58, 86 TO 100, 233 LABEL ""                     OF oDlg PIXEL
        @ 75, 89  SAY STR0012  SIZE 30,10 OF oDlg PIXEL //"Código"
        @ 75, 210 SAY STR0028 SIZE 30,10 OF oDlg PIXEL //"F4-Help"
        @ 75,110 MSGET TCodigo Picture MPictGet SIZE 95,10 OF oDlg PIXEL

        //DEFINE SBUTTON FROM 10,180 TYPE 1 ACTION (IF(EVAL(bValid),oDlg:End(),)) ENABLE OF oDlg PIXEL
        DEFINE SBUTTON FROM 10,180 TYPE 1 ACTION (TQual:=1, oDlg:End()) ENABLE OF oDlg PIXEL
        DEFINE SBUTTON FROM 35,180 TYPE 2 ACTION (TQual:=0, oDlg:End()) ENABLE OF oDlg  PIXEL
     ACTIVATE MSDIALOG oDlg CENTERED

  ELSE 
     IF(EasyEntryPoint("EICTR310"),Execblock("EICTR310",.F.,.F.,"TELA_01"),) //chiba
  ENDIF
    

  If TQual = 0
     E_RESET_AREA
     Return .F.
  Endif

  TR_HistSet(TArq,@MTipo,@MPictQt,@MPictItem)
  IF !TR300ValMes(TMes)  .OR.  !TR300ValAno(TAno,MTipo)
  	 LOOP
  ENDIF
  
  cTitulo:= T_Opcoes[TArq]
  
  IF EMPTY(TCodigo)
     DBSEEK(xFilial()+MTipo+TAno)
  ELSE
//   IF(TArq#6,TCodigo:=LEFT(TCodigo,6),)
     IF(TArq#6,TCodigo:=RTRIM(TCodigo),)//AWR 05/04/2002
     MCodigo:=TCodigo
     DBSEEK(xFilial()+MTipo+TAno+TCodigo)
  ENDIF
  IF TMes # 0
     //Mes_I:=Mes_F:=TMes    
     Mes_I:=1     //TMes  // GFP - 20/08/2014
     Mes_F:=TMes  //12    // GFP - 20/08/2014    
     MDescMes:=Nome_Mes(TMes)+"/"+TAno+" - "
  ELSE
     Mes_I:=1 
     Mes_F:=12 
     MDescMes:=STR0029+" - " //"Todos os meses"
  ENDIF

  TR_HistArq(TArq,@WorkFile,T_DBF,Mes_I,Mes_F,T_Fields,@pos_ano,@pos_tipo,@pos_cod)

  TB_Campos[1,2]:= ( MDescArq:=ALLTRIM(T_Opcoes[TArq]) )
  R_Campos[1,2] := MDescArq
  R_Dados[1]    := ALLTRIM(cCadastro)+" - Por "+MDescArq
  R_Dados[4]    := MDescMes+MDescAtu+DTOC(dUlt_Atz)
  
  Processa({|lEnd| TR310Gera(WorkFile,T_Fields,MTipo,TAno,pos_ano,pos_tipo,pos_cod)} )

     IF TRB->(Easyreccount("TRB")) > 0

        oMainWnd:ReadClientCoors()
        DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+cTitulo;
               FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
                    OF oMainWnd PIXEL  
        @ 00,00 MsPanel oPanel Prompt "" Size 60,35 of oDlg //LRL 27/04/04
        @ 05,4   SAY MDescAtu   SIZE 40,10 OF oPanel PIXEL
        @ 05,48  MSGET dUlt_Atz SIZE 40,10 WHEN .F. OF oPanel PIXEL
        @ 20,4   SAY STR0012   SIZE 40,10 OF oPanel PIXEL //"Código"
        @ 20,48  MSGET MCodigo  SIZE 95,10 WHEN .F. OF oPanel PIXEL

        DEFINE SBUTTON FROM 08,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (Eval(bImprime)) ENABLE OF oPanel

        oMark:= MsSelect():New("TRB",,,TB_Campos,@lInverte,@cMarca,{45,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
		
		oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT   
        oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		
        ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
                                                        {||nOpca:=0,oDlg:End()})) //LRL 27/04/04 //Alinhamento MDI.                                                         
        If nOpca = 0
           E_RESET_AREA
           Return .F.
        Endif

     ENDIF

  IF TRB->(EasyRecCount("TRB")) == 0
     Help(" ",1,"EICSEMREG")
  ENDIF

ENDDO
*-----------------------------------------*
STATIC FUNCTION TR310Grava(PQtd,PVal, nMes)
*-----------------------------------------*
STATIC SaveQtd,SaveVal     

//IF TMes == 0 
  // nMes:=IF(nMes#NIL,++nMes,1) //traz até o mes indicado
//ELSE 
//  SaveMes:=TMes   //Traz somente do mes indicado
//ENDIF

IF PQtd+PVal # 0
   SaveQtd      := IF(SaveQtd#NIL,100*(PQtd/SaveQtd-1),0)
   SaveVal      := IF(SaveVal#NIL,100*(PVal/SaveVal-1),0)
   TRB->( DBAPPEND() )
   TRB->WKMES  := STRZERO(nMes,2) //PADL(SaveMes,2,'0')
   IF MQtdTot+MValTot=0
      IF TArq # 6
         TRB->WKCOD_I:= WK_CODIGO //PADL(WK_CODIGO,8,"0")
         TRB->WKDESC := MEMOLINE(BuscaGeral(SWK->WK_CODIGO,TArq),40)
      ELSE
         TRB->WKCOD_I:= WJ_CODIGO
         TRB->WKDESC := MEMOLINE(BuscaGeral(TRB->WKCOD_I,TArq),40)
      ENDIF
   ENDIF
   TRB->WKQTDE := PQtd
   TRB->WKVALOR:= PVal
   TRB->WKVARQ := IF(SaveQtd<9999.99,SaveQtd,9999.99)
   TRB->WKVARV := IF(SaveVal<9999.99,SaveVal,9999.99)
   SaveQtd:=IF(PQtd#0,PQtd,1) 
   SaveVal:=IF(PVal#0,PVal,1)
   MQtdTot+=PQtd 
   MValTot+=PVal
ENDIF

IF nMes = Mes_F
   nMes:=NIL
   IF MQtdTot+MValTot # 0
      TRB->( DBAPPEND() )
      TRB->WKMES  := "--"
      TRB->WKCOD_I:= REPL("-",LEN(TRB->WKCOD_I))
      TRB->WKDESC := REPLICATE("-",40)
      TRB->( DBAPPEND() )
      TRB->WKMES  := "**"
      TRB->WKCOD_I:= REPL("-",LEN(TRB->WKCOD_I))
      TRB->WKQTDE := MQtdTot
      TRB->WKVALOR:= MValTot
      TRB->( DBAPPEND() )
      TRB->WKMES  := "##"
      MQtdTot:=MValTot:=0 
      SaveQtd:=SaveVal:=NIL
  ENDIF
ENDIF
RETURN NIL
*----------------------------------------------------------------------------
FUNCTION TR310Trans(PRel)
*----------------------------------------------------------------------------
LOCAL MCod
DbSelectArea("TRB") /*; DbGoTop()*/
IF AT(WKMES,"--**##") # 0
   _Cod:=_Desc:=_NMes:=_VarQ:=_VarV:=' '
   _Qtd :=IF(TArq=6,"---------------","-----")
   _Val :="------------------"
   IF WKMES="**"
      _Qtd :=TRAN(WKQTDE,MPictQt)
      _Val :=TRAN(WKVALOR,"@E 999,999,999,999.99")
   ELSEIF WKMES="##"
      _Qtd :=_Val:=" "
   ENDIF
ELSE
   MCod :=IF(! EMPTY(WKCOD_I),TRAN(WKCOD_I,MPictItem),WKCOD_I)
// _Cod :=IF(PRel,MCod+" "+WKDESC,MCod+" "+SUBST(WKDESC,1,30))
   _Cod :=MCod
   _Desc:=SUBSTR(WKDESC,1,30)
   _NMes:=PADR(Nome_Mes(VAL(WKMES)),9)
   _Qtd :=TRAN(WKQTDE,MPictQt)
   _VarQ:=IF(WKVARQ#0,Alltrim(TRANS(WKVARQ,"@E 99,999.99")),SPACE(07))
   _Val :=TRAN(WKVALOR,"@E 999,999,999,999.99")
   _VarV:=IF(WKVARV#0,Alltrim(TRANS(WKVARV,"@E 99,999.99")),SPACE(07))
ENDIF
RETURN _Cod
*----------------------------------------------------------------------------
FUNCTION TR310Graf()
*----------------------------------------------------------------------------
LOCAL aMeses:=ARRAY(12,2), nOldRec:=RECNO(), cDesc
LOCAL lValor:=AT('Valor',ObjTab:GETCOLUMN(ObjTab:COLPOS):HEADING ) # 0

Msg(STR0030,0) //"PREPARANDO DADOS - AGUARDE..."

AEVAL(aMeses,{|mes,i| mes[1]:=0, mes[2]:=LEFT(Nome_Mes(i),3) })

WHILE EMPTY(WKCOD_I) .AND. ! BOF()
  DBSKIP(-1)
ENDDO

IF BOF()
   DBSKIP()
ENDIF

cDesc:=TRAN(WKCOD_I,MPictItem)+' '+LEFT(ALLTRIM(WKDESC),30)

WHILE ! EOF() .AND. AT(WKMES,"--**##") = 0
  aMeses[VAL(WKMES),1]+=IF(!lValor,WKQTDE,WKVALOR)
  DBSKIP()
ENDDO

Msg('',0)

AV_GRAF(aMeses,.F.,cDesc,STR0031+IF(!lValor,STR0032,STR0033),STR0034) //"POR "###"QUANTIDADE"###"VALOR"###"Evolução Mensal"

DBGOTO(nOldRec)

*---------------------------------------------------------------------------
Function TR310Gera(WorkFile,T_Fields,MTipo,TAno,pos_ano,pos_tipo,pos_cod)
*---------------------------------------------------------------------------

//DFS - 11/05/11 - Retirado tratamento por ter feito um novo no FOR
/*LOCAL b_Gravaw:={|| AEVAL(T_Fields,;
                   {|pos| TR310Grava( FIELDGET(pos[1]),FIELDGET(pos[2]) )})}*/

LOCAL nTot:=Easyreccount("TRB")

//DFS - 11/05/11 - Retirado tratamento por ter feito um novo no While
/*LOCAL b_Condition:={|| FIELDGET(pos_tipo)=MTipo .AND. ;
                       FIELDGET(pos_ano) =TAno  .AND. ;
                       (EMPTY(TCodigo) .OR. FIELDGET(pos_cod) = TCodigo) .AND. ;
                     FieldGet(FieldPos(Right(Alias(),2)+"_FILIAL")) == xFilial() } */
Local nMes
Local nCont                       

TRB->(avzap())

ProcRegua(nTot)                                                    

//DFS - 11/05/11 - Retirado porque no While e no FOR este tratamento já é feito
//DBEVAL({|| IncProc(STR0035), Eval(b_gravaw) },,b_condition) //"Pesquisando dados"

DbSetOrder(1)                                       

//DFS - 11/05/11 - Criado tratamento para trazer corretamente o Histórico Mensal.
While ! EOF() .AND. FIELDGET(pos_tipo)==MTipo .AND. ;
                    FIELDGET(pos_ano) ==TAno  .AND. ;
                    (EMPTY(TCodigo) .OR. FIELDGET(pos_cod) == TCodigo) .AND. ;
                    FieldGet(FieldPos(Right(Alias(),2)+"_FILIAL")) == xFilial()  
   nMes := 1  // GFP - 20/08/2014
   For nCont := 1 TO LEN(T_FIELDS)
      If (TMes == 0 .AND. nMes <= 12) .OR. nMes <= TMes   // GFP - 20/08/2014
         TR310Grava( FIELDGET(T_FIELDS[nCont][1]),FIELDGET(T_FIELDS[nCont][2]), nMes )
         nMes++
      EndIf
   Next
   DbSkip()
EndDo      

TCodigo:=SPACE(LEN(SB1->B1_COD))
DbSelectArea("TRB") ; DbGoTop()
RETURN .T.

*----------------------------------*
FUNCTION BuscaGeral( MCodigo,MArq )
*----------------------------------*
LOCAL RDesc

DO CASE
   CASE MArq = 1
        RDesc:= BuscaCCusto(MCodigo)
   CASE MArq = 2
        RDesc:= BuscaF_F(MCodigo)
   CASE MArq = 3
        RDesc:= BuscaDesp(MCodigo)
   CASE MArq = 4
        RDesc:= BuscaComprador(MCodigo)
   CASE MArq = 5
        RDesc:= BuscaAgente(MCodigo)
   CASE MArq = 6
        RETURN IF(SB1->(DBSEEK(xFilial("SB1")+MCodigo)),MSMM(SB1->B1_DESC_P,30,1),STR0036 ) //"ITEM NÃO CADASTRADO"
   CASE MArq = 7
        RDesc:= BuscaCliente(MCodigo)
   
   OTHERWISE//chiba
      IF(EasyEntryPoint("EICTR310"),RDesc:=Execblock("EICTR310",.F.,.F.,"BUSCAGERAL"),)//chiba
        
ENDCASE
RETURN RDesc

*-----------------------------------------*
Static Function ReportDef(aDados, aCampos)
*-----------------------------------------*
Local nInc, cCampo, bCodeBlock, nTamanho, nSeq := 1
Local aAlias := {"SY3", "SA2", "SY5", "SY1", "SY4", "SB1", "SA1"}
   
   oReport := TReport():New("EICTR310",aDados[9],"",{|oReport| ReportPrint(oReport)},aDados[2]+" "+aDados[3]+" "+aDados[4])
   oSecao1 := TRSection():New(oReport,"Estatísticas de Movimentação",aAlias,{})

   TRCell():New(oSecao1, "TR310Trans(.F.)", "TRB", STR0012, , 30,,{||TR310Trans(.F.)}  )//"Código"
   TRCell():New(oSecao1, "_Desc"          , "TRB", STR0037, , 40,,{||_Desc}  )//"Código"
   TRCell():New(oSecao1, "_NMes"          , "TRB", STR0013, , 12,,{||_NMes}  )//"Mês"
   TRCell():New(oSecao1, "_Qtd"           , "TRB", STR0014, , 20,,{||_Qtd}  )//"Qtde."
   TRCell():New(oSecao1, "_VarQ"          , "TRB", STR0015, , 10,,{||_VarQ}  )//"Var.(%)"
   TRCell():New(oSecao1, "_Val"           , "TRB", STR0016, , 20,,{||_Val}  )//"Valor em US$"
   TRCell():New(oSecao1, "_VarV"          , "TRB", STR0015, , 10,,{||_VarV}  )//"Var.(%)"

   //Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
   TRPosition():New(oReport:Section("Estatísticas de Movimentação"),"SY4",1,{|| xFilial("SY4") + TRB->WKCOD_I})
   
Return Nil

*----------------------------------*
Static Function ReportPrint(oReport)
*----------------------------------*
Local nRecno := TRB->(Recno())

oReport:SetMeter(TRB->(EasyRecCount("TRB")))
TRB->(DbGoTop())
oSecao1:Init()
While TRB->(!Eof()) .And. !oReport:Cancel()
   oSecao1:PrintLine()
   oReport:IncMeter()
   TRB->(DbSkip())
EndDo
oSecao1:Finish()

TRB->(DbGoTo(nRecno))
Return Nil

*----------------------------------------------------------------------------*
*     FIM DO PROGRAMA TR310
*----------------------------------------------------------------------------*
