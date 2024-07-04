
#INCLUDE "Eictr600.ch"
#include "AVERAGE.CH"

#DEFINE   aPagar      "2"
#DEFINE   Fornecedor  "3"
#DEFINE   Pagas       "4"
#DEFINE   MSGPROC     STR0001 //"Gravando Processo: "
#DEFINE   MSGPESQ     STR0002 //"Pesquisando informa‡äes..."
#DEFINE   TAM_INVOICES 66

#COMMAND E_RESET_AREA => Work->(E_EraseArq(WorkFile,WorkFile1,WorkFile2,WorkFile3));
                       ; SW9->(DbSetOrder(1)) ; SWB->(DbSetOrder(1))


*---------------------*
FUNCTION EICTR600S()//Chamado do Schedule SXD
*---------------------*
E_Init()
EICTR600(.T.)
RETURN .T.
  
//Funcao    : EICTR600 
//Autor     : AVERAGE/MJBARROS      
//Data      : 10.09.97
//Descri‡ao : Controle de Pagamentos - Valores Vencidos e Nao Pagos por Fornecedor
//Sintaxe   : EICTR600()
//Revisão	: GCC - 28/08/2013 - Tratamento para trazer os valores de pagamento antecipado vinculado a PO quanto a Fornecedor
//Uso       : SIGAEIC
*--------------------------------*
Function EICTR600(lSXD)
*--------------------------------*
LOCAL oDlg, oGet, nOpcA:=0, cTit1 , oPanel, nPos:= 0
Local aButtons:= {{"",  {|| IIf(PPrograma = Fornecedor .OR. PPrograma = Pagas,TR600Rel(aDados),;
                  TR600CallReport(aDados, R_Campos, TB_Campos, nColIni :=If(PPrograma = Fornecedor .OR. PPrograma = Pagas,2,1), ))}, STR0041, STR0041 }} //"Imprimir" //DFS - 21/12/12 - Inclusão de tratamento para verificar qual tipo de filtro foi utilizado.
Private nColIni
PRIVATE aDados:={"Work",;
                STR0003,; //"Emite Relacao de Vencidos e Nao Pagos, Invoices a Pagar e"
                STR0004,; //"Invoices Pagas"
                "",;
                "P",;
                132,;
                "",;
                "",;
                "",;
                { "Zebrado", 1,"Importação", 1, 2, 1, "",1 },;
                "EICTR600",;
                { {||.T.} , {||.T.} }  }
PRIVATE cSimbDolar:=BuscaDolar()/*GetNewPar("MV_SIMB2","US$")*/, cTitulo
PRIVATE TDt_I,TDt_F,TOpcao,bWhile:={||.T.},TForn,TForLoj := ""
PRIVATE TB_Campos:={}, cTit2
PRIVATE cCadastro, PPrograma, cPag
PRIVATE R_Campos:={}, _Primeiro:=.T.,CMesAno, R_Funcoes
PRIVATE wForn, nTam, MVlr_Inv:= MVlr_Tot:= MVlr_TR := 0, nColTot ,Ttipo  := " "
PRIVATE nVlrGeralInv:= nVlrGeralTot:= 0
PRIVATE cPictTotal:='@E 999,999,999.99'
PRIVATE lExisteRdmake:=EasyEntryPoint("EICTR600")
PRIVATE T_DBF:={{"WKFORN"     , "C" , AVSX3("A2_COD",3), 0 } ,;
               { "WKNOMFOR"   , "C" , 40 , 0 } ,;
               { "WKVALOR"    , "N" , 15 , 2 } ,;
               { "WKTIPO"     , "C" , 01 , 0 } ,; 
               { "WKMOEDA"    , "C" , 03 , 0 } ,;
               { "WKVLR_INV"  , "N" , 15 , 2 } ,;
               { "WKDIA"      , "N" , 03 , 0 } ,;
               { "WKAWB"      , "C" , AVSX3("W6_MAWB",3)+1 , 0 } ,;
               { "WKHAWB"     , "C" , AVSX3("W6_HAWB",3)   , 0 } ,;
               { "WKDT_VEN"   , "D" , 08 , 0 },;
               { "WKDT_DESE"  , "D" , AVSX3("WB_DT_DESE",3),AVSX3("WB_DT_DESE",4) } ,;  //LRL 07/06/04               
               { "WKNREDUZ"   , "C" , AVSX3("A6_NREDUZ",3),AVSX3("A6_NREDUZ",4) } ,;  //LRL 08/06/04               
               { "WKVENCTO"   , "D" , 08 , 0 },; //GFC 03/12/03
               { "WKCONEVE1"  , "C" , /*AVSX3("W6_CONEVE1",3)*/18, 0 },; //GFC 03/12/03
               { "WKCA_TX"    , "N" , /*AVSX3("WB_CA_TX",3)*/12,5/*AVSX3("WB_CA_TX",4)*/ } ,;  //GFC 03/12/03
               { "WKINVOICE"  , "C" , /*AVSX3("WB_INVOICE",3)*/TAM_INVOICES,0 } ,;  //GFC 03/12/03
               { "WKDTREG_D"  , "D" , 08 , 0 },;
               { "WKIMP"      , "C" , 01 , 0 }}

Private aTotal := {}, aTotalForn:= {}
PRIVATE lEMail:=(!lSXD = NIL)
PRIVATE lImpObs := .F.
PRIVATE lCposAdto:=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado
Private cFornAtu := "", cForLoj := ""  
//Define se o sistema possui os novos tratamentos de impressão a aprtir do release 4.
Private lR4 := FindFunction("TRepInUse") .And. TRepInUse()

cSimbDolar:=IF(EMPTY(cSimbDolar),"US$",cSimbDolar)

If EICLOJA() .And. (nPos := aScan(T_DBF, {|x| x[1] == "WKFORN" })) > 0
   aAdd(T_DBF, Nil)
   aIns(T_DBF, nPos + 1)
   T_DBF[nPos+1] := {"WKLOJA", "C", AVSX3("WB_LOJA",3),0}
EndIf

SW9->(DbSetOrder(3))
SWB->(DbSetOrder(3))

IF lExisteRdmake
   ExecBlock("EICTR600",.F.,.F.,"ESTRUTURA")
ENDIF

WorkFile := E_CriaTrab(,T_DBF,"Work") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("Work",WorkFile +TEOrdBagExt(),"WKDIA")//1

WorkFile1:=E_Create({},.F.)
IndRegua("Work",WorkFile1+TEOrdBagExt(),"DTOS(WKDT_VEN)")//2

If EICLoja()
   WorkFile2:=E_Create({},.F.)
   IndRegua("Work",WorkFile2+TEOrdBagExt(),"WKNOMFOR+WKFORN+WKLOJA+DTOS(WKDT_VEN)+WKHAWB+WKIMP")//3
   
   WorkFile3:=E_Create({},.F.)
   IndRegua("Work",WorkFile3+TEOrdBagExt(),"WKFORN+WKLOJA")//4
Else
   WorkFile2:=E_Create({},.F.)
   IndRegua("Work",WorkFile2+TEOrdBagExt(),"WKNOMFOR+WKFORN+DTOS(WKDT_VEN)+WKHAWB+WKIMP")//3  
   
   WorkFile3:=E_Create({},.F.)
   IndRegua("Work",WorkFile3+TEOrdBagExt(),"WKFORN")//4
EndIf


WorkFile3:=E_Create({},.F.)
IndRegua("Work",WorkFile3+TEOrdBagExt(),"WKFORN")//4

SET INDEX TO (WorkFile +TEOrdBagExt()),(WorkFile1+TEOrdBagExt()),;
             (WorkFile2+TEOrdBagExt()), (WorkFile3+TEOrdBagExt())

IF lExisteRdmake
   ExecBlock("EICTR600",.F.,.F.,"INDICE")
ENDIF

mv_par05 := space(10)

DO While .T.

  //AOM - 04/01/2011 - Criada função generica para adicionar o campo loja no grupo do SX1
  //VerLojaSX1("EIR600")
 
  IF !Pergunte("EIR600",IF(lEmail,.F.,.T.),FunDesc()) .AND. !lEmail// AWR 
     E_RESET_AREA ; RETURN 
  ENDIF
  
  IF lEMail      //AWR
     aReturn   := aDados[10]
     aDados[11]:= SetPrint(aDados[1],aDados[11],"EIR600",@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
     aDados[10]:= aReturn
  ENDIF
  
  PPrograma := PADL(mv_par01,1)
  TForn     := mv_par02
  TForLoj   := mv_par03
  TDT_I     := mv_par04
  TDT_F     := mv_par05
  tTipo     := IF(empty(mv_par06),SPACE(10),If(ValType(mv_par06)=="N", Str(mv_par06),mv_par06))
  cPag      := mv_par08
  TOpcao    := 0

  IF lExisteRdmake
     ExecBlock("EICTR600",.F.,.F.,"INICIA_VARIAVEIS")
  ENDIF

  //IF PPrograma == aPagar
     TOpcao := If(ValType(mv_par06)== "N",mv_par06,Val(mv_par06))
  //ENDIF

  SA2->(DbSeek(xFilial()+TForn+IIF(EICLoja(),TForLoj,"")))
  //Iniciando todas as variaveis
  cCadastro:=IF(PPrograma=Fornecedor,STR0006,; //" Relacao de Invoices a Pagar - Fornecedor "
             IF(PPrograma=aPagar,;
             IF(TOpcao==2,STR0007,; //" Relacao Sintetica de Invoices a Pagar "
                          STR0008),; //" Relacao Analitica de Invoices a Pagar "
             IF(PPrograma=Pagas, STR0009,; //" Relacao de Invoices Pagas "
                                 STR0010))) //" Relatorio de Vencidos e Nao Pagos "
  cCadastro := IF(!EMPTY(mv_par06),ALLTRIM(cCadastro)+" - "+ TR600Tipo(tTipo),cCadastro)                                 
  bWhile    :={||.T.}
  _Primeiro :=.T.
  cTitulo   :=If(EMPTY(TForn),"TODOS",TForn+IIF(EICLoja()," - "+TForLoj,"")+" - "+SA2->A2_NOME)
  R_Funcoes:={{||IF(PPrograma=aPagar.AND.TOpcao# 2,TR600Sub(),.T.)},;
              {|| TR600Tot(TOpcao)}}

  IF PPrograma = aPagar .AND. (!EMPTY(TForn) .And. IIF(EICLoja(),!EMPTY(TForLoj),.T.))
     aDados[08]:=STR0011+TForn+IIF(EICLoja()," - "+TForLoj,"")+" - "+BuscaFabr_Forn(TForn,TForLoj) //"Fornecedor-> "
  ENDIF

  IF PPrograma = Fornecedor .OR. PPrograma = Pagas 
     R_Funcoes:={ {||TR600Quebra(.T.,@cabec2)} ,{||TR600Quebra(.T.,@cabec2),ImpTotais()}}
  ENDIF

  IF PPrograma = aPagar
     IF TOpcao == 2
        Work->(DBSETORDER(1))
     ELSE
        Work->(DBSETORDER(3)) // DFS - Alterada a ordem para validação de todos fornecedores (Revisado por TRP)
     ENDIF
  ELSE
     Work->(DBSETORDER(3))
  ENDIF

  TData_I := CToD("  /  /  ")
  
  IF TData_I < TDt_I
     TData_I := TDt_I
  ENDIF

  ASIZE(TB_Campos,0) 
  ASIZE(R_Campos,0)

  IF lExisteRdmake
     ExecBlock("EICTR600",.F.,.F.,"ACERTA_VARIAVEIS")
  ENDIF

  DBSelectArea("Work")
  
  IF PPrograma = aPagar
     cTit2:= STR0024 //"Valor US$"
     IF TOpcao == 2
        AADD(TB_Campos,{{||IF(WKDIA=999,'+ 360 Dias','  '+PADL(WKDIA,3,'0')+' Dias')},, " "})
     ELSE
        //Campo duplicado - WFS - 19/01/12
        //AADD(TB_Campos,{{|| If(WKIMP=="1", WORK->WKDT_VEN, "") } ,, STR0012}) //"Vencimento"

        AADD(TB_Campos,{{|| If(WKIMP=="1", (WKFORN+IIF(EICLoja()," - "+WKLOJA,"")+' '+WKNOMFOR), "") },, STR0014}) //"Fornecedor"
        AADD(TB_Campos,{{|| If(WKIMP=="1", WKDT_VEN, "") } ,, STR0012}) //"Vencimento"
        //AADD(TB_Campos,{{||TR600Busca('Invoice')}    ,, STR0016}) //"Invoices" 
        AADD(TB_Campos,{"WKINVOICE"                    ,, STR0016}) //"Invoices" 
        AADD(TB_Campos,{"WKHAWB"  ,, STR0018 }) //"Processo"
        AADD(TB_Campos,{{|| If(WKIMP =="1", WKMOEDA, ""  )} ,, STR0021     }) //"Moeda"
        AADD(TB_Campos,{{|| If(WKIMP =="1", Transform(WKVLR_INV, '@E 999,999,999,999.99'), "")} ,, STR0022}) //"Valor da Invoice" //
        AADD(TB_Campos,{{|| If(WKIMP =="1", Transform(WKVALOR, cPictTotal), "")},,cTit2})

     ENDIF

     IF !EMPTY(TDt_F)
        bWhile := {|| EMPTY(SWB->WB_CA_DT) .AND. SWB->WB_DT_VEN >= TData_I .AND. SWB->WB_DT_VEN <= TDt_F }
     ELSE
        bWhile := {|| EMPTY(SWB->WB_CA_DT) .AND. SWB->WB_DT_VEN >= TData_I }
     ENDIF

  ELSEIF PPrograma = Fornecedor 
     AADD(TB_Campos,{{||WKFORN+IIF(EICLoja()," - "+WKLOJA,"")+' '+WKNOMFOR},, STR0014}) //"Fornecedor"
     AADD(TB_Campos,{"WKDT_VEN"                     ,, STR0012})
     AADD(TB_Campos,{{||TR600Busca('Pedido')}       ,, STR0015}) //"P.O."
     //AADD(TB_Campos,{{||TR600Busca('Invoice')}    ,, STR0016}) //"Invoices"
     AADD(TB_Campos,{"WKINVOICE"                    ,, STR0016}) //"Invoices"
     AADD(TB_Campos,{"WKAWB"                        ,, STR0017  }) //"AWB"
     AADD(TB_Campos,{"WKHAWB"                       ,, STR0018 }) //"Processo"
//     AADD(TB_Campos,{{||TR600Busca('Guia')}         ,, STR0019 }) //"P.L.I."
//     AADD(TB_Campos,{{||TRAN(IF(SW6->(DBSEEK(xFilial()+Work->WKHAWB)),PADL(SW6->W6_DI_NUM,10,'0'),'0000000000'),'@R 99/9999999-9')},,STR0020}) //"D.I."
     AADD(TB_Campos,{{||TRAN(IF(SW6->(DBSEEK(xFilial()+Work->WKHAWB)),PADL(SW6->W6_DI_NUM,10,'0'),'0000000000'),AVSX3("W6_DI_NUM",AV_PICTURE))},,STR0020}) //"D.I." // ACB - 16/04/2010
     AADD(TB_Campos,{"WKMOEDA"   ,, STR0021     }) //"Moeda"
     AADD(TB_Campos,{"WKVLR_INV" ,, STR0022,'@E 999,999,999,999.99'}) //"Valor da Invoice"
     IF !EMPTY(TDt_F)
        bWhile := {|| EMPTY(SWB->WB_CA_DT) .AND. SWB->WB_DT_VEN >= TData_I .AND. SWB->WB_DT_VEN <= TDt_F }
     ELSE
        bWhile := {|| EMPTY(SWB->WB_CA_DT) .AND. SWB->WB_DT_VEN >= TData_I }
     ENDIF
  ELSEIF PPrograma = Pagas
	 //BHF**-19/05/09
	 IF TOpcao == 2 // - Se Sintético 
        AADD(TB_Campos,{"WKDT_VEN"                     ,, STR0013}) //"Pagamento"
     ELSE
     AADD(TB_Campos,{{||WKFORN+IIF(EICLoja()," - "+WKLOJA,"")+' '+WKNOMFOR},, STR0014}) //"Fornecedor"
     AADD(TB_Campos,{"WKDT_VEN"                     ,, STR0013}) //"Pagamento" 
     AADD(TB_Campos,{"WKVENCTO"                     ,, STR0012}) //"Vencimento" 
     AADD(TB_Campos,{{||TR600Busca('Pedido')}       ,, STR0015}) //"P.O."
     AADD(TB_Campos,{"WKINVOICE"                    ,, STR0016}) //"Invoices"
     //AADD(TB_Campos,{{||TR600Busca('Invoice')}      ,, STR0016}) //"Invoices"
     AADD(TB_Campos,{"WKCONEVE1"                    ,, STR0038}) //"Navio"
     AADD(TB_Campos,{"WKHAWB"                       ,, STR0018}) //"Processo"
//     AADD(TB_Campos,{{||TR600Busca('Guia')}         ,, STR0019 }) //"P.L.I."
//     AADD(TB_Campos,{{||TRAN(IF(SW6->(DBSEEK(xFilial()+Work->WKHAWB)),PADL(SW6->W6_DI_NUM,10,'0'),'0000000000'),'@R 99/9999999-9')},,STR0020}) //"D.I."
//     AADD(TB_Campos,{{||TRAN(IF(SW6->(DBSEEK(xFilial()+Work->WKHAWB)),PADL(SW6->W6_DI_NUM,10,'0'),'0000000000'),AVSX3("W6_DI_NUM",AV_PICTURE))},,STR0020}) //"D.I."   //ACB - 16/04/2010
     AADD(TB_Campos,{{||TRAN(IF(SW6->(DBSEEK(xFilial("SW6")+Work->WKHAWB)),SW6->W6_DI_NUM,''),AVSX3("W6_DI_NUM",AV_PICTURE))},,STR0020}) //"D.I."   //FDR - 20/07/12
     AADD(TB_Campos,{"WKDTREG_D"                    ,, STR0039}) //"Dt.DI"
     IF !EMPTY(TDt_F)
        bWhile := {|| SWB->WB_CA_DT <= TDt_F }
     ENDIF
     ENDIF
     //BHF**
  ELSE
     AADD(TB_Campos,{{||WKFORN+IIF(EICLoja()," - "+WKLOJA,"")+' '+WKNOMFOR},, STR0014}) //"Fornecedor"
     IF !EMPTY(TDt_F)
        bWhile := {|| EMPTY(SWB->WB_CA_DT) .AND. SWB->WB_DT_VEN < dDataBase .AND. SWB->WB_DT_VEN <= TDt_F }
     ELSE
        bWhile := {|| EMPTY(SWB->WB_CA_DT) .AND. SWB->WB_DT_VEN < dDataBase }
     ENDIF
  ENDIF

  cTit2:=IF(PPrograma=Pagas,STR0023,STR0024) //"Valor R$"###"Valor US$"

  IF PPrograma = Pagas
     IF TOpcao == 1 //BHF-19/05/09 - Só aparece no analítico.
     AADD(Tb_Campos,{{||TR600Tipo(WKTIPO)}                            ,,STR0035                                                      })
     AADD(TB_Campos,{"WKDT_DESE"                                      ,,STR0040             ,AVSX3("WB_DT_DESE",6)                   })//LRL 07/06/04
     AADD(TB_Campos,{"WKNREDUZ"                                       ,,AVSX3("A6_NREDUZ",5),AVSX3("A6_NREDUZ",6)                    })//LRL 08/06/04     
     AADD(TB_Campos,{{|| WKMOEDA+' '+Transform(WKVLR_INV,cPictTotal)} ,,AVSX3("WB_FOBMOE",5)                                         }) //LRL 08/06/04
     AADD(TB_Campos,{"WKCA_TX"                                        ,,AVSX3("WB_CA_TX" ,5),/*AVSX3("WB_CA_TX",6)*/"@E 99,999.99999"})
     ENDIF
  ENDIF

   IF !(PPrograma = aPagar)
      AADD(TB_Campos,{"WKVALOR",,cTit2,cPictTotal})
   EndIf

  IF PPrograma = Fornecedor 
     AADD(Tb_Campos,{{||TR600Tipo(WKTIPO)},,STR0035  })
  ENDIF

  nColIni :=If(PPrograma = Fornecedor .OR. PPrograma = Pagas,2,1)

  DBSELECTAREA("Work")
  AvZap()

  MTotal  := 0
  MVlr_Sub:= 0
  IF PPrograma = aPagar .AND. TOpcao == 2
     Work->(DBAPPEND()) ; Work->WKDIA := 7
     Work->(DBAPPEND()) ; Work->WKDIA := 14
     Work->(DBAPPEND()) ; Work->WKDIA := 21
     Work->(DBAPPEND()) ; Work->WKDIA := 28
     Work->(DBAPPEND()) ; Work->WKDIA := 60
     Work->(DBAPPEND()) ; Work->WKDIA := 90
     Work->(DBAPPEND()) ; Work->WKDIA := 120
     Work->(DBAPPEND()) ; Work->WKDIA := 150
     Work->(DBAPPEND()) ; Work->WKDIA := 180
     Work->(DBAPPEND()) ; Work->WKDIA := 360
     Work->(DBAPPEND()) ; Work->WKDIA := 999
  ENDIF

  SWB->(DbSetOrder(3))
  IF PPrograma = Pagas
     SWB->(DbSeek(xFilial()+DTOS(IF(EMPTY(TDt_I),AVCTOD("01/01/1965"),TDt_I)),.T.))
  ELSE
     SWB->(DbSeek(xFilial()+DTOS(AVCTOD(''))+;
                  DTOS(IF(PPrograma=aPagar .OR. PPrograma=Fornecedor,TData_I,;
                       IF(EMPTY(TDt_I),AVCTOD("01/01/1965"),TDt_I))),.T.))
  ENDIF
  nCont:=0
  
  IF lExisteRdmake
     ExecBlock("EICTR600",.F.,.F.,"ANTES_GRV_WORK")
  ENDIF
  
  R_Campos:=E_CriaRCampos(TB_Campos,"E",nColIni)

  cFilSW7:=xFilial("SW7")
  cFilSW2:=xFilial("SW2")
    
  IF lEMail      //AWR
     SWB->(DBEVAL( {|| TR600Grv(TOpcao,TForn,TForLoj)},,{|| SWB->WB_FILIAL==xFilial("SWB") .AND. EVAL(bWhile)} ))
  ELSE
     Processa({|| ProcRegua(50),;
                  SWB->(DBEVAL({|| TR600Grv(TOpcao,TForn,TForLoj)},,{|| SWB->WB_FILIAL==xFilial("SWB") .AND. EVAL(bWhile)})) },MSGPESQ)
  ENDIF
  IF lExisteRdmake
     ExecBlock("EICTR600",.F.,.F.,"DEPOIS_GRV_WORK")
  ENDIF

  IF PPrograma = aPagar .AND. TOpcao == 2
     Work->(DBGOTOP())
     DO WHILE ! Work->(EOF())
        IF Work->WKVALOR = 0
           Work->(DBDELETE())
        ENDIF
        Work->(DBSKIP())
     ENDDO

     DBSELECTAREA("Work") 
     PACK
  ENDIF

  IF Work->(Bof()) .And. Work->(Eof())
     IF !lEmail
        Help("",1,"AVG0001015") //"NÆo h  Registros a serem listados"###"Informação"
        LOOP
     ELSE
        EXIT
     ENDIF
  ENDIF

  aDados[07]:=IF(PPrograma=Pagas,STR0027,STR0028)+DTOC(TDt_I)+STR0029+DTOC(TDt_F) //'Pagamentos de '###'Vencimentos de '###' ate '
  aDados[09]:=cCadastro
  aDados[12]:=R_Funcoes
  aDados[05]:=IF(PPrograma=Pagas .OR. PPrograma = Fornecedor,'G','M')
  nTam      :=LEN(cCadastro)

  IF lEMail      //AWR
     IF PPrograma = Fornecedor .OR. PPrograma = Pagas
        TR600Rel(aDados)
     ELSE
        //E_Report(aDados,R_Campos,,.F.)
        TR600CallReport(aDados, R_Campos, TB_Campos, nColIni, .F.)
     ENDIF
     nOpcA:=0
  ELSE
     oMainWnd:ReadClientCoors()
     DEFINE MSDIALOG oDlg TITLE cCadastro;
         FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
 	           OF oMainWnd PIXEL  
        @00,00 MsPanel oPanel Prompt "" Size 60,20 of oDlg //LRL 14/04/04 - Painel para alinhamento mdi.
        @005,001 SAY   STR0014  of oPanel PIXEL SIZE 40,10 //"Fornecedor"

        @4.5,035 MSGET cTitulo When .F. of oPanel PIXEL SIZE 160,8

        //Retirara a opção para que seja utilizada a do TReport - WFS - 19/01/12
        If !lR4
           @05,(oDlg:nClientWidth-4)/2-100 BUTTON STR0030 SIZE 40,11 FONT oDlg:oFont ACTION ((TR350Arquivo("Work"),oMark:oBrowse:Refresh())) of oPanel  PIXEL //"Gera Arquivo"
        EndIf

        /*Opção colocada nas ações relacionadas
        DEFINE SBUTTON FROM 05,(oDlg:nClientWidth-4)/2-50 TYPE 6 ACTION ;
        (IF(PPrograma = Fornecedor .OR. PPrograma = Pagas,TR600Rel(aDados),;
            TR600CallReport(aDados, R_Campos, TB_Campos, nColIni, ))) ENABLE of oPanel */
            
        Work->(DBGOTOP())

        oMark:= MsSelect():New("Work",,,TB_Campos,.F.,"",{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})

        nOpcA:=0
     
	 oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	 oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	 
     ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()},,aButtons)) //LRL 14/04/04 - Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

  ENDIF
  If nOpcA = 0
     Exit
  Endif
  DBSELECTAREA("Work") ; AvZap()
ENDDO
E_RESET_AREA   
Return 

*----------------------------------------------------------------------------
FUNCTION TR600Grv(TOpcao,TForn,TForLoj)
*----------------------------------------------------------------------------
LOCAL cNome:='',lLancDi := .T.
Local lLoja := .T.
PRIVATE nVlrSWB := 0 // TDF - 17/03/10

IF !lEMail
   IF nCont > 50 
      ProcRegua(50)
      nCont:=0
   ENDIF
   nCont++
   IncProc(MSGPROC+SWB->WB_HAWB)
ENDIF

IF lCposAdto //Se prevê pgto antecipado, trata de forma diferenciada  os seeks e variáveis
   IF SWB->WB_PO_DI == "A"	
      lLancDi := .F.
      lImpObs := .T.
      nVlrSWB := SWB->WB_PGTANT
      SW2->(DbSeek(xFilial()+Alltrim(SWB->WB_HAWB)))
   ElseIf (SWB->WB_PO_DI == "C" .Or. SWB->WB_PO_DI == "F")	// GCC - 28/08/2013 - Tratamento das novas modalidades de pagamento ( Fornecedor e Crédito)
      lLancDi := .F.
      lImpObs := .T.
      nVlrSWB := SWB->WB_PGTANT
      SWA->(DbSeek(xFilial()+Alltrim(SWB->WB_HAWB)))
   ELSEIF Left(SWB->WB_TIPOREG,1) == "P" .AND. !EMPTY(SWB->WB_NUMPO)  
      RETURN .F. //Despreza os registros referentes a adiantamentos das parcelas de cambio da DI
   ENDIF 
ENDIF 

IF lLancDi                               
   IF SWB->WB_FOBMOE <= 0
      RETURN .F.
   ENDIF
   nVlrSWB := SWB->WB_FOBMOE
   SW7->(DbSeek(xFilial()+SWB->WB_HAWB))
   SW2->(DbSeek(xFilial()+SW7->W7_PO_NUM))
ENDIF  

IF (!Empty(TForn) .AND. ((RTRIM(TForn) #  RTRIM(SWB->WB_FORN) .Or. IIF(EICLoja(),RTRIM(TForLoj) #  RTRIM(SWB->WB_LOJA),.F.))))  // SW2->W2_FORN EFOI ALTERADO //RRV - 14/11/2012 - Ajustado para correto funcionamento do filtro quando o retorno do eicloja() for .F.  
   RETURN .F.                                               // PARA TRABALHARMOS COM VARIOS
ENDIF                                                       // FORNECEDORES NA DI - RJB 31/10/2001

IF !EMPTY(tTipo)
   IF ALLTRIM(tTipo) # ALLTRIM(SWB->WB_TIPOREG)
      RETURN .F.
   ENDIF
ENDIF  

lLoop:=.F.
IF lExisteRdmake
   ExecBlock("EICTR600",.F.,.F.,"VALID_GRV_WORK")
ENDIF
IF lLoop
   RETURN .F.
ENDIF

cNome:=BuscaF_F(SWB->WB_FORN,,SWB->WB_LOJA)

If EICLoja()
   lLoja:= TForLoj == SWB->WB_LOJA  .Or. Empty(TForLoj)
EndIf

IF PPrograma = Pagas

   SW6->(dbSeek(xFilial("SW6")+SW7->W7_HAWB))

   If cPag == 1 .and. SWB->WB_CA_DT > SW6->W6_DTREG_D .And. ! Empty(SW6->W6_DTREG_D)
      Return .F.
   ElseIf cPag == 2 .and. (SWB->WB_CA_DT < SW6->W6_DTREG_D .Or. Empty(SW6->W6_DTREG_D))
      Return .F.
   EndIf
   
   If lLoja
      Work->(DBAPPEND())
      Work->WKFORN   := SWB->WB_FORN
      If EICLoja()
         Work->WKLOJA   := SWB->WB_LOJA
      EndIf
      Work->WKNOMFOR := cNome
      // Tratamento na gravacao da Work se pgto antecipado  
      IF lCposAdto .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	// GCC - 28/08/2013
         Work->WKHAWB := "* "+SWB->WB_HAWB
         Work->WKCONEVE1:= "" //FDR - 27/07/2012 
      ELSE
         //Work->WKAWB  := SW6->W6_MAWB
         Work->WKHAWB := SW7->W7_HAWB
         Work->WKCONEVE1:= SW6->W6_IDENTVE
      ENDIF
      Work->WKDT_VEN := SWB->WB_CA_DT
      Work->WKVENCTO := SWB->WB_DT_VEN
      Work->WKVALOR  := nVlrSWB * SWB->WB_CA_TX
      Work->WKTIPO   := Left(SWB->WB_TIPOREG,1)
      Work->WKDT_DESE:= SWB->WB_DT_DESE //LRL 07/06/04
      Work->WKMOEDA  := SWB->WB_MOEDA //LRL 07/06/04
      Work->WKVLR_INV:= nVlrSWB//SWB->WB_FOBMOE
      Work->WKCA_TX  := SWB->WB_CA_TX
      Work->WKINVOICE:= SWB->WB_INVOICE
      //FDR - 20/07/12
      If lLancDi
         Work->WKDTREG_D:= SW6->W6_DTREG_D     
      Else 
         Work->WKDTREG_D:= CToD("  /  /  ")
      EndIf   
      If SA6->(dbSeek(xFilial()+SWB->WB_BANCO))
         Work->WKNREDUZ:= SA6->A6_NREDUZ
      Else
         Work->WKNREDUZ:="   "
      EndIf   
      IF lExisteRdmake
         ExecBlock("EICTR600",.F.,.F.,"GRV_WK_PAGAS")
      ENDIF
   EndIf
   RETURN NIL
ENDIF

IF PPrograma = aPagar .OR. PPrograma = Fornecedor
   IF PPrograma = aPagar
      lExecuta:=.T.
      IF lExisteRdmake
         ExecBlock("EICTR600",.F.,.F.,"GRV_WK_APAGAR")
      ENDIF

      IF lExecuta
         IF TOpcao == 2
            IF SWB->WB_DT_VEN-dDataBase <= 999
               Work->(DBSEEK(SWB->WB_DT_VEN-dDataBase,.T.))
            ELSE
               Work->(DBGOBOTTOM())
            ENDIF
         ELSE 
            POSICIONE("SA2",1,xFilial("SA2")+SWB->WB_FORN+IIF(EICLoja(),SWB->WB_LOJA,""),"A2_COD") //DFS - Posicionar o fornecedor pelo SA2
            cChaveBusca := SA2->A2_NOME + SA2->A2_COD+ IIF(EICLoja(),SA2->A2_LOJA,"")+ DTOS(SWB->WB_DT_VEN)+if(lCposAdto .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C"),  "* "+SWB->WB_HAWB, SW7->W7_HAWB)	// GCC - 28/08/2013
            IF !WORK->(DbSeek(cChaveBusca+"1")) .Or. (cFornAtu <> SWB->WB_FORN .And. IIF(EICLoja(),cForLoj <> SWB->WB_LOJA,.T.))
               cFornAtu := SWB->WB_FORN
               If EICLoja()
                  cForLoj  := SWB->WB_LOJA
               EndIf
               
               If lLoja
                  Work->(DBAPPEND())
                  Work->WKIMP := "1"
                  Work->WKDT_VEN := SWB->WB_DT_VEN
                  //BHF**-19/05/09
                  Work->WKFORN   := SWB->WB_FORN 
                  If EICLoja()
                     Work->WKLOJA:= SWB->WB_LOJA
                  EndIf
                  Work->WKNOMFOR := cNome
                  Work->WKMOEDA  := SW2->W2_MOEDA
                  Work->WKVLR_INV:= nVlrSWB
      		      IF lCposAdto .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C") //Tratamento na gravacao da Work se pgto antecipado	// GCC - 28/08/2013
         	         Work->WKHAWB := "* "+SWB->WB_HAWB 
      	 	      ELSE
      	 	         Work->WKAWB  := SW6->W6_MAWB
         		     Work->WKHAWB := SW7->W7_HAWB
      		      ENDIF                          
      		      Work->WKDT_VEN := SWB->WB_DT_VEN
      		      Work->WKTIPO   := Left(SWB->WB_TIPOREG,1)
      		      Work->WKINVOICE:= SWB->WB_INVOICE

               Work->WKVALOR   := Work->WKVALOR + nVlrSWB * BuscaTaxa(SW2->W2_MOEDA,dDataBase,,.F.) / BuscaTaxa(cSimbDolar,dDataBase,,.F.)
               MTotal += ROUND(nVlrSWB * BuscaTaxa(SW2->W2_MOEDA,dDataBase,,.F.) / BuscaTaxa(cSimbDolar,dDataBase,,.F.),2)
               EndIf
      		   //BHF**
            Else
               //DFS - 
               If lLoja
                  Work->WKVLR_INV := Work->WKVLR_INV + nVlrSWB
                  Work->WKVALOR   := Work->WKVALOR + nVlrSWB * BuscaTaxa(SW2->W2_MOEDA,dDataBase,,.F.) / BuscaTaxa(cSimbDolar,dDataBase,,.F.)
                  MTotal += ROUND(nVlrSWB * BuscaTaxa(SW2->W2_MOEDA,dDataBase,,.F.) / BuscaTaxa(cSimbDolar,dDataBase,,.F.),2)
               
               If ((Len(AllTrim(WORK->WKINVOICE)) + Len(AllTrim(SWB->WB_INVOICE))) > TAM_INVOICES)
                  lCriaLinha := .T.
                  WORK->(DbSeek(cChaveBusca+"2"))
                  While WORK->(!Eof() .And. WKNOMFOR+WKFORN+DTOS(WKDT_VEN)+WKHAWB == cChaveBusca)
                     If ((Len(AllTrim(WORK->WKINVOICE)) + Len(AllTrim(SWB->WB_INVOICE))) <= TAM_INVOICES)
                        lCriaLinha := .F.
                        Exit
                     EndIf
                     WORK->(DbSkip())
                  EndDo
               Else
                  lCriaLinha := .F.
               EndIf
               
                  If lCriaLinha
                     Work->(DBAPPEND())
                     WORK->WKIMP := "2"
                     Work->WKDT_VEN := SWB->WB_DT_VEN
                     Work->WKFORN   := SWB->WB_FORN
                     If EICLoja()
                        Work->WKLOJA:= SWB->WB_LOJA
                     EndIf
                     Work->WKNOMFOR := cNome
                     Work->WKMOEDA  := If(SWB->WB_PO_DI == "A",SW2->W2_MOEDA,SWB->WB_MOEDA)
                     IF lCposAdto .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	//Tratamento na gravacao da Work se pgto antecipado	// GCC - 28/08/2013
                        Work->WKHAWB := "* "+SWB->WB_HAWB 
                     ELSE
                        Work->WKAWB  := SW6->W6_MAWB
                        Work->WKHAWB := SW7->W7_HAWB
                     ENDIF                          
                     Work->WKDT_VEN := SWB->WB_DT_VEN
                     Work->WKTIPO   := Left(SWB->WB_TIPOREG,1)
                     Work->WKVLR_INV:= nVlrSWB
                     Work->WKINVOICE:= SWB->WB_INVOICE
                  Else
                     Work->WKINVOICE := AllTrim(Work->WKINVOICE) + ", " + SWB->WB_INVOICE
                  EndIf
               EndIf
            ENDIF
         ENDIF
      ENDIF
   ELSE
      If lLoja
         Work->(DBAPPEND())
         Work->WKFORN   := SWB->WB_FORN
         If EICLoja()
            Work->WKLOJA:= SWB->WB_LOJA
         EndIf
         Work->WKNOMFOR := cNome
         Work->WKMOEDA  := If(SWB->WB_PO_DI == "A",SW2->W2_MOEDA,SWB->WB_MOEDA)
         Work->WKVLR_INV:= nVlrSWB
         IF lCposAdto .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")	//Tratamento na gravacao da Work se pgto antecipado	// GCC - 28/08/2013
            Work->WKHAWB := "* "+SWB->WB_HAWB 
         ELSE
            Work->WKAWB  := SW6->W6_MAWB
            Work->WKHAWB := SW7->W7_HAWB
         ENDIF
         Work->WKDT_VEN := SWB->WB_DT_VEN
         Work->WKTIPO   := Left(SWB->WB_TIPOREG,1)
         Work->WKINVOICE:= SWB->WB_INVOICE
         IF lExisteRdmake
            ExecBlock("EICTR600",.F.,.F.,"GRV_WK_FORN")
         ENDIF
      EndIf
   ENDIF
ELSE
   IF !Work->(DBSEEK(cNome+SWB->WB_FORN+SWB->WB_LOJA))
      If lLoja 
         Work->(DBAPPEND())
         Work->WKFORN   := SWB->WB_FORN 
         If EICLoja()
            Work->WKLOJA:= SWB->WB_LOJA
         EndIf
         Work->WKNOMFOR := cNome
         IF lExisteRdmake
            ExecBlock("EICTR600",.F.,.F.,"GRV_WK_NAO_PAGAS")
         ENDIF
      EndIf
   ENDIF
ENDIF

If !(PPrograma = aPagar)
   If lLoja
      Work->WKVALOR   := Work->WKVALOR + nVlrSWB * BuscaTaxa(SW2->W2_MOEDA,dDataBase,,.F.) / BuscaTaxa(cSimbDolar,dDataBase,,.F.)
      MTotal += ROUND(nVlrSWB * BuscaTaxa(SW2->W2_MOEDA,dDataBase,,.F.) / BuscaTaxa(cSimbDolar,dDataBase,,.F.),2) 
   EndIf
EndIf
RETURN NIL

*----------------------------------------------------------------------------
FUNCTION TR600Tot(TOpcao)
*----------------------------------------------------------------------------
Linha++ 
// T_Len --> private array da funcao relatorio, que contem na coluna 1 o
//           tamanho do campo e na coluna 2 a coluna a ser impressa. Cada
//           ocorrencia se refere a um campo em conformidade com o especifi-
//           cado em R_Campos (vide inicio deste programa - MJBarros)

IF PPrograma=aPagar .AND. TOpcao# 2
   @ Linha,T_Len[LEN(T_Len),2] PSAY REPL("-",T_Len[LEN(T_Len),1])
   @ Linha,T_Len[1,2] PSAY STR0031 //"Total Mes"
   Linha++
   @ Linha,T_Len[1,2] PSAY SUBSTR(cMesAno,5,2)+"/"+SUBSTR(cMesAno,1,4)
   @ Linha,T_Len[LEN(T_Len),2] PSAY TRAN(MVlr_Sub,cPictTotal)
   Linha++
   cMesano := PADL(YEAR(Work->WKDT_VEN),4)+PADL(MONTH(Work->WKDT_VEN),2,"0")
   MVlr_Sub:= 0
ENDIF

@ Linha,T_Len[LEN(T_Len),2] PSAY REPL("-",T_Len[LEN(T_Len),1])
Linha++
IF PPrograma=aPagar .AND. TOpcao# 2
   @ Linha,T_Len[1,2] PSAY STR0032 //"Geral"
ENDIF
@ Linha,T_Len[LEN(T_Len),2] PSAY TRAN(MTotal,cPictTotal)
_Primeiro := .T.

RETURN .T.

*----------------------------------------------------------------------------
FUNCTION TR600Sub()
*----------------------------------------------------------------------------
IF _Primeiro
   cMesano := PADL(YEAR(Work->WKDT_VEN),4)+PADL(MONTH(Work->WKDT_VEN),2,"0")
   _Primeiro := .F.
ENDIF

IF cMesano # PADL(YEAR(Work->WKDT_VEN),4)+PADL(MONTH(Work->WKDT_VEN),2,"0")
   Linha++
   @ Linha,T_Len[LEN(T_Len),2] PSAY REPL("-",T_Len[LEN(T_Len),1])
   @ Linha,T_Len[1,2] PSAY STR0031 //"Total Mes"
   Linha++
   @ Linha,T_Len[1,2] PSAY SUBSTR(cMesAno,5,2)+"/"+SUBSTR(cMesAno,1,4)
   @ Linha,T_Len[LEN(T_Len),2] PSAY TRAN(MVlr_Sub,cPictTotal)

   cMesano := PADL(YEAR(Work->WKDT_VEN),4)+PADL(MONTH(Work->WKDT_VEN),2,"0")
   MVlr_Sub:= 0
   MVlr_Sub+= Work->WKVALOR
   Linha++ 
ELSE
   MVlr_Sub+= Work->WKVALOR
ENDIF
RETURN .T.

*----------------------------------------------------------------------------
FUNCTION TR600Rel(aDados)
*----------------------------------------------------------------------------
LOCAL cDesc
Work->(DBGOTOP())
wForn := Work->WKFORN

IF EICLOJA()
   wLoja:= Work->WKLOJA
ENDIF

cDesc := BuscaFabr_Forn(WKFORN,IF(EICLOJA(),WKLOJA,""))
aDados[08]:= STR0011+wForn+" - "+IF(EICLOJA(),wLoja,"")+ALLTRIM(cDesc) //"Fornecedor-> "

//E_Report(aDados,R_Campos,,!lEmail)
TR600CallReport(aDados, R_Campos, TB_Campos, nColIni, !lEmail)

RETURN NIL

*----------------------------------------------------------------------------
FUNCTION TR600Quebra(PTotal,cabec2)
*----------------------------------------------------------------------------
LOCAL cDesc,i

IF wForn # Work->WKFORN
   wForn := Work->WKFORN
   IF EICLOJA()
      wLoja:= Work->WKLOJA
   ENDIF
   cDesc := BuscaFabr_Forn(WKFORN,IF(EICLOJA(),WKLOJA,""))
   cabec2:= STR0011+wForn+" - "+IF(EICLOJA(),wLoja,"")+ALLTRIM(cDesc) //"Fornecedor-> "
   Work->(DBSKIP(-1))
   IF(PTotal,Linha++,)
   IF PPrograma = Fornecedor
      @ Linha,T_Len[09,2] PSAY REPL("-",T_Len[09,1])
      @ Linha,T_Len[10,2] PSAY REPL("-",T_Len[10,1])
      Linha++
      @ Linha,T_Len[09,2] PSAY TRAN(MVlr_Inv,'@E 999,999,999,999.99')
      @ Linha,T_Len[10,2] PSAY TRAN(MVlr_Tot,cPictTotal)
   ELSE            //LRL 08/06/04
      PulaLinha(1)
      @ Linha, 167 PSAY "TOTAL DO FORNECEDOR POR MOEDA:"
      PulaLinha(1)
      aSort(aTotalForn)
      for i:= 1 to len (aTotalForn)
        @ Linha, 167 PSAY aTotalForn[i,1]
        @ Linha, 172 PSAY TRANS(aTotalForn[i,2],cPictTotal)
        PulaLinha(1)
      next
        @ Linha, 167 PSAY "R$ "
        @ Linha, 172 PSAY TRAN(MVlr_Tot,cPictTotal)
      /*@ Linha,T_Len[LEN(T_Len),2] PSAY REPL("-",T_Len[LEN(T_Len),1])
      Linha++
      @ Linha,T_Len[LEN(T_Len),2] PSAY TRAN(MVlr_Tot,cPictTotal)*/
   ENDIF
   
   IF lImpObs
      Linha++
      @Linha,T_Len[1,2] PSAY STR0037 //"Os processos iniciados com * referem-se a Adiantamentos - Número do Pedido"
   ENDIF    
   
   MVlr_Inv:= MVlr_Tot:= 0
   aTotalForn:={}
   Linha:=99
   RETURN .F.
ELSE
   MVlr_Inv+= WKVLR_INV
   MVlr_Tot+= WKVALOR
ENDIF
AcumTotais() //LRL 08/06/04
RETURN .T.

*----------------------------------------------------------------------------
FUNCTION TR600Busca(PTipo)
*----------------------------------------------------------------------------
LOCAL _Retorno:='',_Conta:=0, _Sai:= .F.,cTamanho:=0
DO CASE
   CASE PTipo == 'Invoice'
        cTamanho := 40
        SW9->(DbSetOrder(3))
        IF SW9->(DbSeek(xFilial("SW9")+Work->WKHAWB))
           Do WHILE !SW9->(EOF()) .AND. Work->WKHAWB == SW9->W9_HAWB .and. SW9->W9_FILIAL == xfilial("SW9")
              IF _Conta = 2
                 _Sai := .T.
                 EXIT
              ENDIF
              _Conta++ ; _Retorno+= ALLTRIM(SW9->W9_INVOICE)+","
              SW9->(DBSKIP())
           ENDDo
        ENDIF
        _Retorno := SUBSTR(_Retorno,1,(LEN(_Retorno)-1))
        If(Empty(_Retorno), _Retorno:=Work->WKINVOICE, )
   CASE PTipo == 'Pedido'
        If Left(WORK->WKHAWB,1)=="*" //Adiantamento
          _Retorno :=AllTrim(SubStr(WORK->WKHAWB,2))
        Else
           SWA->(DbSeek(xFilial()+Work->WKHAWB))
           cFil:=xFilial("SWA") // usada no APE100
           _Retorno := APE100_PO("P")
        EndIf
        
   CASE PTipo == 'Guia'
        SW7->(DbSeek(xFilial()+Work->WKHAWB))
        SW4->(DbSeek(xFilial()+SW7->W7_PGI_NUM))
        If Left(SW4->W4_GI_NUM,1) = "*"
           _Retorno := Space(Len(SW4->W4_GI_NUM))
        Else
           _Retorno := TRAN(SW4->W4_GI_NUM,'@R 9999-99/999999-9')
        Endif
ENDCASE
_Retorno := _Retorno+IF(_Sai,STR0033,"") //" E DEMAIS"
RETURN _Retorno+SPACE(cTamanho-LEN(_Retorno))

*----------------------------------------------------------------------------
FUNCTION TR600Valid(cParam)
*----------------------------------------------------------------------------

DO CASE
   CASE cParam=="FORN"
      If !Empty(mv_par02) .AND. ! SA2->(DbSeek(xFilial()+mv_par02))
        Help(" ",1,"REGNOIS")
        Return .F.
      Endif         
   CASE cParam=="DATAS"
     IF !EMPTY(mv_par05) .AND. mv_par04 > mv_par05
          Help("",1,"AVG0001016") //"Data Final menor que Data Inicial"###"Informação"
         RETURN .F.
     ENDIF
   CASE cParam=="TIPO"
   //LRS - 17/11/2015 - Validação do tamanho do Array, para evitar erro log
      IF  mv_par01==2  //COMO SX1 NAO CONTEM WHEN UTILIZAMOS O OBJETO PARA HABILITAR E DESABILITAR
//       __ODLG:ACONTROLS[13]:ENABLE() VI 03/11/03
//       __ODLG:ACONTROLS[14]:ENABLE() VI 03/11/03
         If Len(__ODLG:ACONTROLS) >= 11
	         __ODLG:ACONTROLS[11]:ENABLE() //VI 03/11/03
	      EndIF
	      If Len(__ODLG:ACONTROLS) >= 13
	         __ODLG:ACONTROLS[13]:ENABLE() //VI 03/11/03
         EndIF
      ELSE 
//       __ODLG:ACONTROLS[13]:DISABLE() VI 03/11/03
//       __ODLG:ACONTROLS[14]:DISABLE() VI 03/11/03
         If Len(__ODLG:ACONTROLS) >= 11
	         __ODLG:ACONTROLS[11]:DISABLE() // Tipo do Relatorio
	     EndIF
	     If Len(__ODLG:ACONTROLS) >= 13
	         __ODLG:ACONTROLS[13]:DISABLE() // Analitico ou Sintético
         EndIF
      ENDIF
      If mv_par01<>4
         If Len(__ODLG:ACONTROLS) >= 15
	         __ODLG:ACONTROLS[15]:DISABLE() // Pagamento?
         EndIF
      Else
      If Len(__ODLG:ACONTROLS) >= 15
	         __ODLG:ACONTROLS[15]:ENABLE() //VI 03/11/03
         EndIf
      EndIf
ENDCASE

RETURN .T.

*----------------------------------------------------------------------------
FUNCTION TR600Tipo(pTipo)
*----------------------------------------------------------------------------
IF SX5->(DBSEEK(xFilial("SX5")+"Y6"+If(ValType(pTipo)=="N",Str(pTipo),pTipo)))
   Return LEFT(X5DESCRI(),15)
ENDIF
RETURN SPACE(15)

*--------------------------*
Function AcumTotais()   //LRL 08/06/04
*--------------------------*
Local nPosGer,nPosForn
 //Acumula Total Geral
   nPosGer := ASCAN(aTotal,{ |x| x[1] = Work->WKMOEDA })
   if nPosGer = 0
      AADD(aTotal,{Work->WKMOEDA,Work->WKVLR_INV})
   else
      aTotal[nPosGer,2] += Work->WKVLR_INV
   endif 
      nPosForn := ASCAN(aTotalForn,{ |x| x[1] = Work->WKMOEDA })
 //Acumula Total por Fornecedor  
   if nPosForn = 0
      AADD(aTotalForn,{Work->WKMOEDA,Work->WKVLR_INV})
   else
      aTotalForn[nPosForn,2] += Work->WKVLR_INV
   endif
MVlr_TR+= WKVALOR    
Return .T.
*---------------------------*
Function ImpTotais() //LRL 08/06/04
*---------------------------* 
// Total Geral                
Local i
If PPrograma=Pagas
   PulaLinha(2)
   PulaLinha(2)
   PulaLinha(2)
   @ Linha, 010 PSAY "TOTAL GERAL POR MOEDA:"
   aSort(aTotal)
   for i:= 1 to len (aTotal)
        @ Linha, 055 PSAY aTotal[i,1]
        @ Linha, 060 PSAY TRANS(aTotal[i,2],cPictTotal)
        PulaLinha(2)
   next   
   @ Linha, 055 PSAY "R$ "
   @ Linha, 060 PSAY TRAN(MVlr_TR,cPictTotal)
   PulaLinha(2)
   MVlr_TR:=0
   aTotal:= {}
EndIf     
*---------------------------*
Function PulaLinha(nTipo) //LRL 08/06/04
*---------------------------* 
IF Linha >= 54
  Linha:=0
  Linha := Cabec(aDados[9],aDados[7],If(nTipo ==1,aDados[8],""),aDados[11],aDados[5])
  Linha++
Else
  Linha++
EndIf    
RETURN .T.

/*
Funcao      : TR600CallReport(aDados, R_Campos, lEmail)
Parametros  : aDados, R_Campos, lEmail
Retorno     : Nenhum
Objetivos   : Define a função correta de impressão do relatório, a partir do release utilizado.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 18/08/06
Revisao     :
Obs.        :
*/
Static Function TR600CallReport(aDados, R_Campos, TB_Campos, nColIni, lEmail)
Private oReport, oCabec, oSecaoD, oBrk1, oTotal1, oTotal2, oRodape
Private aDadosRel := aDados, aHeader := {}, aMoedas := {}
Private cTotalMes := "", cForn := ""
Private nInd := 1
//Define se o sistema possui os novos tratamentos de impressão a aprtir do release 4.
//Private lR4 := FindFunction("TRepInUse") .And. TRepInUse()

If !lR4
   E_Report(aDados,R_Campos,,If(ValType(lEmail)=="L", lEmail, Nil))
Else
   ReportDef(aDados, TB_Campos, nColIni)
   oReport:PrintDialog()
EndIf

DBSelectArea("Work")

Return Nil

/*
Funcao      : ReportDef
Parametros  : aDados, aCampos, nColIni
Retorno     : Nenhum
Objetivos   : Definições do relatório personalizável
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 18/08/06
Revisao     :
Obs.        :                                           
*/
*--------------------------------------------------*
Static Function ReportDef(aDados, aCampos, nColIni)
*--------------------------------------------------*
Local nPos := 1
Local nInc, nSeq := 1, nTamanho
Local cCampo
Local bMesAno := {|| AllTrim(StrZero(Month(Work->WKDT_VEN), 2)) + "/" + AllTrim(Str(Year(Work->WKDT_VEN))) }
Default nColIni := 1

Begin Sequence

   //Cria o objeto principal de controle do relatório.
   //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
   oReport := TReport():New("EICTR600",aDados[9],"EIR600",{|oReport| ReportPrint(oReport)},aDados[2]+" "+aDados[3]+" "+aDados[4])

   oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina 
   oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem 

   //Define os objetos com as seções do relatório
   //Cabeçalho
   oCabec  := TRSection():New(oReport,"Cabeçalho","Work",)
   TRCell():New(oCabec,  "01","", /*Titulo*/ "Processo",,500,,{|| Eval(aHeader[nInd]) })
   //Detalhes
   oSecaoD := TRSection():New(oCabec,"Invoices","Work",/*aOrdem*/)

   //Definições das celulas com base no relatório antigo
   For nInc := nColIni To Len(aCampos)
      If ValType(aCampos[nInc][1]) == "B"
         cCampo     := StrZero(nSeq, 10)
         bCodeBlock := aCampos[nInc][1]
         xCont      := Eval(bCodeBlock)
         If ValType(xCont) == "D"
            xCont := Dtoc(xCont)
         EndIf
         nTamanho   := Len(xCont)
         nSeq++       
      ElseIf ValType(aCampos[nInc][1]) == "C"
         cCampo     := aCampos[nInc][1]
         bCodeBlock := Nil
         //nTamanho   := If(ValType(Work->(cCampo)) == "C", Len(Work->(cCampo)), Len(Str(Work->(cCampo))))
         //** PLB - 29/03/07
         nPos := AScan( T_DBF, { |x| x[1] == cCampo } )
         If T_DBF[nPos][2] == "N"
            nTamanho := T_DBF[nPos][3] + Int((T_DBF[nPos][3] - T_DBF[nPos][4])/3)// + 1 // Soma o tamanho do campo com a quantidade de caracteres da picture numérica, inclusive a vírgula de decimais
            IF Len(aCampos[nInc][3]) > nTamanho //**JVR** - 19/05/09 - Acertar tamanho da coluna, para não haver cortes de palavras.
               ntamanho := Len(aCampos[nInc][3]) + 3
            EndIf
         Else
            nTamanho := T_DBF[nPos][3] //**JVR** - 19/05/09
            If Len(aCampos[nInc][3]) > nTamanho
                ntamanho := Len(aCampos[nInc][3]) + 3
            EndIf
         EndIf
         //**
      Else
         Loop
      EndIf

      TRCell():New(oSecaoD,;
                   cCampo,;//Nome do campo - Se for um codeblock o nome será um sequencial
                   "Work",;//Nome da work
                   aCampos[nInc][3],;//Titulo
                   If(Len(aCampos[nInc]) >= 4, aCampos[nInc][4], ""),;//Picture
                   nTamanho,;//Tamanho
                   ,;//Pixel
                   bCodeBlock)//Codeblock (se existir, ao contrário será Nil)
     
      IF PPrograma = Pagas
         IF cCampo="WKDT_VEN"
            oCabec:Section("Invoices"):Cell("WKDT_VEN")  :SetColSpace(1)
         ELSEIF cCampo="WKVENCTO"
            oCabec:Section("Invoices"):Cell("WKVENCTO")  :SetColSpace(1)
         ELSEIF cCampo="WKHAWB"
            oCabec:Section("Invoices"):Cell("WKHAWB")    :SetColSpace(1)
         ELSEIF cCampo="WKDTREG_D"
            oCabec:Section("Invoices"):Cell("WKDTREG_D") :SetColSpace(1)
         ELSEIF cCampo="WKCA_TX"
            oCabec:Section("Invoices"):Cell("WKCA_TX")   :SetColSpace(1)
         ELSEIF cCampo="WKNREDUZ"
            oCabec:Section("Invoices"):Cell("WKNREDUZ")  :SetColSpace(1)
         ELSEIF aCampos[nInc][3]=STR0015 // Pedido
            oCabec:Section("Invoices"):Cell("0000000001"):SetColSpace(1)         
         ELSEIF aCampos[nInc][3]=STR0020 // DI
            oCabec:Section("Invoices"):Cell("0000000002"):SetColSpace(1)
         ELSEIF aCampos[nInc][3]=STR0035 // TIPO
            oCabec:Section("Invoices"):Cell("0000000003"):SetColSpace(1)
         ELSEIF aCampos[nInc][3]=AVSX3("WB_FOBMOE",5) //VALOR MOEDA
            oCabec:Section("Invoices"):Cell("0000000004"):SetColSpace(1)
         ENDIF   
      ENDIF   
   Next
   
   //Cabeçalho
   aAdd(aHeader, &("{|| '" + aDadosRel[7] + "' }"))
   
   //Define os agrupamentos e Totalizadores
   Do Case
      //Vencidos e não Pagos
      Case !(PPrograma $ aPagar+Fornecedor+Pagas)

         //Inclui totalizador do valor da invoice
         oTotal1 := TRFunction():New(oSecaoD:Cell("WKVALOR"),NIL,"SUM",,"",,{|| Work->WKVALOR},.F.,.T.)
         oReport:SetTotalText("")
         oReport:SetTotalInLine(.F.)

      //Invoices a Pagar
      Case PPrograma == aPagar

         If TOpcao == 2//Sintética
            oTotal1 := TRFunction():New(oSecaoD:Cell("WKVALOR"),NIL,"SUM",,"",,{|| Work->WKVALOR},.F.,.T.)
         Else//Analítica
            //Define agrupamento por mês
            oBrk1   := TRBreak():New(oSecaoD,{|| Month(Work->WKDT_VEN) }, "",.F.)

            //Informa o mês e o ano no final do agrupamento
            oBrk1:SetTotalText({|| Work->(DBSKIP(-1)), cTotalMes := STR0031 + Space(2) + Eval(bMesAno), Work->(DBSKIP()), cTotalMes})//"Total Mês"
         
            //Inclui totalizador por mês
            oTotal1 := TRFunction():New(oSecaoD:aCell[Len(oSecaoD:aCell)-1],NIL,"SUM",oBrk1,"",,{|| Transform(Work->WKVLR_INV,cPictTotal)},.T.,.F.)
            oTotal1 := TRFunction():New(oSecaoD:aCell[Len(oSecaoD:aCell)],NIL,"SUM",oBrk1,"",,{|| Transform(Work->WKVALOR,cPictTotal)},.T.,.F.)

            oSecaoD:SetTotalText("")//"Geral"
            oSecaoD:SetTotalInLine(.F.)
         
            oReport:oPage:lPortrait := .F.//Sugere impressão em formato paisagem para evitar problemas no layout.
         EndIf

      //Invoices a Pagar - Fornecedor
      Case PPrograma == Fornecedor
         //Cabeçalho
         aAdd(aHeader, {|| STR0011 + cForn + " - "+IF(EICLOJA(),TForLoj,"") + AllTrim(BuscaFabr_Forn(Work->WKFORN,IF(EICLOJA(),Work->WKLOJA,""))) } )//"Fornecedor-> "

         //Define agrupamento por mês
         oBrk1   := TRBreak():New(oSecaoD,{|| Month(Work->WKDT_VEN) }, "",.F.)

         //Informa o mês e o ano no final do agrupamento
         oBrk1:SetTotalText({|| Work->(DBSKIP(-1)), cTotalMes := STR0031 + Space(2) + Eval(bMesAno), Work->(DBSKIP()), cTotalMes})//"Total Mês"
         
         //Inclui totalizador por mês
         oTotal1 := TRFunction():New(oSecaoD:aCell[Len(oSecaoD:aCell)-2],NIL,"SUM",oBrk1,"",,{|| Transform(Work->WKVLR_INV,cPictTotal)},.T.,.F.)
         oTotal1 := TRFunction():New(oSecaoD:aCell[Len(oSecaoD:aCell)-1],NIL,"SUM",oBrk1,"",,{|| Transform(Work->WKVALOR,cPictTotal)},.T.,.F.)
         
         //Inclui totalizador por valor total e total das invoices
         //oTotal2 := TRFunction():New(oSecaoD:Cell("WKVLR_INV"),NIL,"SUM",/*oBrk*/,"",,{|| Transform(Work->WKVLR_INV,cPictTotal)},.T.,.F.)
         //oTotal3 := TRFunction():New(oSecaoD:Cell("WKVALOR"),NIL,"SUM",/*oBrk*/,"",,{|| Work->WKVALOR},.T.,.F.)

         oSecaoD:SetTotalText("")//"Geral"
         oSecaoD:SetTotalInLine(.F.)
         
         oReport:oPage:lPortrait := .F.//Sugere impressão em formato paisagem para evitar problemas no layout.
      

      Case PPrograma == Pagas//Invoices Pagas
         //Cabeçalho
         aAdd(aHeader, {|| STR0011 + cForn + " - " +IF(EICLOJA(),TForLoj,"")+ AllTrim(BuscaFabr_Forn(Work->WKFORN,IF(EICLOJA(),Work->WKLOJA,""))) } )//"Fornecedor-> "
         oRodape  := TRSection():New(oCabec,"Rodape",,)
         TRCell():New(oRodape,  "01","","Total por Moeda:",,500,,{|| Eval({|| aMoedas[nInc2][1] + Tran(aMoedas[nInc2][2], cPictTotal)}) })
         oReport:oPage:lPortrait := .F.//Sugere impressão em formato paisagem para evitar problemas no layout.
         aMoedas := GetTotaisMoeda()
      
   EndCase
   
End Sequence

Return Nil

/*
Funcao      : ReportPrint
Parametros  : oReport
Retorno     : .T.
Objetivos   : Impressão dos dados do relatório personalizável
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 18/08/06
Revisao     :
Obs.        :
*/
*-------------------------------------------*
Static Function ReportPrint(oReport, lPrint)
*-------------------------------------------*
Local nRecno := Work->(Recno()), nInc  
Private nInc2 //FDR - 21/05/13
Default lPrint := .F.

Begin Sequence

   Work->(DbGoTop())
   
   If lPrint
      oCabec:Init()
      For nInc := 1 To Len(aHeader)
         nInd := nInc
         oCabec:PrintLine()
      Next
      oSecaoD:Print()
      If PPrograma == Pagas
         oRodape:Init()
         nInd:= 0 //DFS - 27/12/12 - Iniciar a variavel sempre com zero
         For nInc := 1 To Len(aMoedas)
            If aMoedas[nInc][3] == cForn
               nInc2 := nInc//FDR - 21/05/13
               nInd++ //DFS - 27/12/12 - Somar valor ao nInd até o tamanho do aMoedas
               oRodape:PrintLine()
            EndIf
         Next
         oRodape:Finish()
      EndIf
      oReport:IncMeter()
      oCabec:Finish()
   Else
      oReport:SetMeter(Work->(EasyRecCount()))
      If PPrograma $ Fornecedor+Pagas
         While Work->(!Eof()) .And. !oReport:Cancel()
            If cForn <> Work->WKFORN
               If Work->(!Bof())
                  //Troca de página
                  oReport:EndPage()
               EndIf
               cForn := Work->WKFORN
               nRecno2:=Work->(Recno())
               Work->(DbSetFilter({||WKFORN == cForn}, "WKFORN == cForn"))
               //Imprime os dados
               ReportPrint(oReport, .T.)
               Work->(DbClearFilter())
               Work->(DbGoTo(nRecno2))
            EndIf
            Work->(DbSkip())
            oReport:IncMeter()

         EndDo
         If PPrograma == Pagas
            //Imprime total geral
            aMoedas := GetTotaisMoeda(aMoedas, .T.)
            oRodape:Init()
            For nInc := 1 To Len(aMoedas)
               nInc2 := nInc
               oRodape:PrintLine()
            Next
            oRodape:Finish()
         EndIf
      Else      
         ReportPrint(oReport, .T.)
      EndIf
      Work->(DbGoTo(nRecno))
   EndIf
   
End Sequence
   
Return .T.

Static Function GetTotaisMoeda(aAgrupa, lAgrupa)
Local nRecno := Work->(Recno()), nInd, nInc
Local aMoedas := {}
Default aAgrupa := {}
Default lAgrupa := .F.

If lAgrupa
   For nInc := 1 To Len(aAgrupa)
      If (nInd := aScan(aMoedas, {|x| x[1] == aAgrupa[nInc][1] })) > 0
         aMoedas[nInd][2] += aAgrupa[nInc][2]
      Else
         aAdd(aMoedas, {aAgrupa[nInc][1], aAgrupa[nInc][2], ""})
      EndIf
   Next
Else
   Work->(DbGoTop())
   While Work->(!Eof())
      If (nInd := aScan(aMoedas, {|x| x[1] == Work->WKMOEDA .And. x[3] == Work->WKFORN })) > 0
         aMoedas[nInd][2] += Work->WKVLR_INV
      Else
         aAdd(aMoedas, {Work->WKMOEDA, Work->WKVLR_INV, Work->WKFORN})
      EndIf
      If (nInd := aScan(aMoedas, {|x| x[1] == "R$ " .And. x[3] == Work->WKFORN })) > 0
         aMoedas[nInd][2] += Work->WKVALOR
      Else
         aAdd(aMoedas, {"R$ ", Work->WKVALOR, Work->WKFORN})
      EndIf
      Work->(DbSkip())
   EndDo
   Work->(DbGoTo(nRecno))
EndIf

Return aMoedas
