#INCLUDE "EDCEA150.ch"
#INCLUDE "Average.ch"
#INCLUDE "TOPCONN.CH"

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#xTranslate :COURIER_10         => \[1\]
#xTranslate :COURIER_10_NEGRITO => \[2\]
#xTranslate :COURIER_12_NEGRITO => \[3\]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ EDCEA150 ³ Autor ³ Thomaz               ³ Data ³ 01.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Relatório de Extrato da Anterioridade                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observação³ Uso - Sigaedc                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*------------------------*
Function EDCEA150()
*------------------------*
Local nOpca := 1, lRet := .F.
Local bOk:={||(nOpca:=1, oDlg:End())}
Local bCancel:={||(nOpca:=0,oDlg:End())}
Local nOrdSX3 := SX3->(IndexOrd())

Private cFilSB1 := xFilial("SB1"), cAto, cPreemb, dDtIniRe, dDtFimRe
Private cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1" //Para utilizar produtos de outra Empresa/Filial
Private cFilED0 := xFilial("ED0") //TRP-16/08/07
Private lTop, cNomArq, oFont, lReturn:= .T., cPergunte:= "EDCEA1"
Private aHeader[0],aCampos:={} 
//Private lDiExt := EasyGParam("MV_EDCDIE",,.F.) NOPADO POR AOM - 04/11/10
//AJP 27/06/2007
Private lMultiFil  := VerSenha(115)  ;
                      .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EE9","X2_MODO") == "E" ;
                      .And.  Posicione("SX2",1,"SW8","X2_MODO") == "E" ;
                      .And.  ED1->( FieldPos("ED1_FILORI") ) > 0  ;
                      .And.  ED2->( FieldPos("ED2_FILORI") ) > 0  ;
                      .And.  EDD->( FieldPos("EDD_FILIMP") ) > 0  ;
                      .And.  EDD->( FieldPos("EDD_FILEXP") ) > 0

Private aFil := IIF(lMultiFil,AvgSelectFil(.F.,,"ED0"),{cFilED0}) //AJP 27/06/2007

// ACSJ - 19/11/2004 ----------------------

SX3->(DBSETORDER(2))
Private lAbriuEDD  := SX3->(dbSeek("EDD_FILIAL"))
SX3->(DBSETORDER(nOrdSX3))
if .not. lAbriuEDD    
   MsgInfo( STR0034 + Chr(13) +;
            STR0035 )
   Return .t.
Endif

// ---------------------------------- ACSJ 

Private cAliasEDD  := "EDD", cFilEDD:= xFilial("EDD")
Private cPictHawb := AVSX3("EDD_HAWB", 06), cPictPo:= AVSX3("EDD_PO_NUM", 06)
Private cPictInv  := AVSX3("EDD_INVOIC", 06), cPictItem:= AVSX3("EDD_ITEM", 06)
Private cPictQtd  := AVSX3("EDD_QTD", 06), cPictDi:= AVSX3("W6_DI_NUM", 06)
Private cPictDt   := AVSX3("EDD_DTRE", 06), cPictPrem:= AVSX3("EDD_PREEMB", 06)
Private cPictPed  := AVSX3("EDD_PEDIDO", 06), cPictProd:= AVSX3("EDD_PROD", 06)
Private cPictAc   := AVSX3("EDD_AC", 06)   
Private cPictRe:= AVSX3("EE9_RE", 06)
Private cGrupo := Space(12)

If Select("SB1EXP") = 0
   lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
Else
   lAbriuExp := .T.
Endif

If lAbriuExp
   cAliasSB1  := "SB1EXP"
   cFilSB1Aux := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
   If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
Endif

EA150CriaWork()

#IFDEF TOP
   lTop := .T.
#ElSE
   lTop := .F.
#ENDIF

While .T.

   DBSelectArea("SX1")
   If !Pergunte(cPergunte,.T.)
      Exit
   EndIf

   cAto     := mv_par01
   cPreemb  := mv_par02
   dDtIniRe := mv_par03
   dDtFimRe := mv_par04

   If !E_PERIODO_OK(@dDtIniRe,@dDtFimRe)
      Loop
   Endif

   If nOpca == 1
      MsAguarde({|| lRet := EDCEA150GERA()}, STR0001) //"Aguarde... Lendo Dados do Arquivo..."
      If lTop
         If Select(cAliasEDD) <> 0
            (cAliasEDD)->(DbCloseArea())
         Endif
      Endif
   Else
      Exit
   Endif

   If !lRet
      Exit
   Endif

EndDo

WORK->(E_EraseArq(cNomArq))

Return lReturn

*-----------------------------*
STATIC FUNCTION EDCEA150GERA()
*-----------------------------*
Local oDlg, nOpc, oMark
Private cMarca := GetMark(), lInverte := .F. , lPrim:= .T.
Private aRCampos:={}, aDados, TB_Campos := {}

If lTop
   cAliasEDD := "EDDQUERY"
   Processa({|| GeraQuery()}, STR0002) //"Aguarde Pesquisando Dados"
Endif

MsAguarde({|| EA150GRVWORK() }, STR0003) //"Atualizando Arquivos..."

aRCampos:={}
aDados := {"WORK",;
           STR0004,; //"Este Relatório trará um Extrato "
           STR0005,; //"da Anterioridade - Drawback "
           "",;
           "G",;
           220,;
           "",;
           "",;
           STR0006,; //"Extrato da Anterioridade"
           {STR0007, 1, STR0008 , 2, 2, 1, "",1 },; //"ZEBRADO"###"IMPORTAÇÃO"
           "EDCEA150",;       
           { {|| EA150MENSA() } , { || .T.  } } } 

//AADD(TB_Campos,{{ ||Transf(Work->EDD_AC, cPictAc )}      , "", STR0009 } ) //"Ato Concess."

AADD(TB_Campos,{{ ||Transf(Work->EDD_HAWB, cPictHawb )}  , "", STR0010 } ) //"Proc. Importação"
//AADD(TB_Campos,{{ ||Transf(Work->EDD_PO_NUM, cPictPo )}  , "", STR0011 } ) //"Nro. do P.O."   - NOPADO - POR AOM - 08/08/2011
AADD(TB_Campos,{{ ||Transf(Work->EDD_INVOIC, cPictInv )} , "", STR0012 } ) //"Invoice"
AADD(TB_Campos,{{ ||Transf(Work->EDD_ITEM, cPictItem   )}, "", STR0013 } ) //"Item"
AADD(TB_Campos,{{ ||Transf(Work->EDD_QTD, cPictQtd     ) + "/" + WORK->ED4_UMITEM} , "", STR0014 } ) //"Qtde. Importada"
AADD(TB_Campos,{{ ||Transf(Work->EDD_DI_NUM, cPictDi   )}, "", STR0015 } ) //"Nro. da D.I."
AADD(TB_Campos,{{ ||Transf(Work->EDD_DTREG, cPictDt    )}, "", STR0016 } ) //"Dt. Imp."
AADD(TB_Campos,{{ ||Transf(Work->EDD_PREEMB, cPictPrem )}, "", STR0017 } ) //"Proc. Exportação"
//AADD(TB_Campos,{{ ||Transf(Work->EDD_PEDIDO, cPictPed )} , "", STR0018 } ) //"Pedido Venda" - NOPADO - POR AOM - 08/08/2011
AADD(TB_Campos,{{ ||Transf(IIF(IG400BuscaItem("E",Work->EDD_PROD,Work->EDD_PD) <> Work->EDD_PROD,"*"," ")+Work->EDD_PROD,  cPictProd )} , "", STR0019 } ) //"Produto"
AADD(TB_Campos,{{ ||Transf(Work->EDD_QTD_EX, cPictQtd ) + "/" + WORK->ED3_UMPROD} , "", STR0020 } ) //"Qtde. Exportada"
AADD(TB_Campos,{{ ||Transf(Work->EDD_RE     , cPictRe  )}, "", STR0021 } ) //"Nro. do R.E."
AADD(TB_Campos,{{ ||Transf(Work->EDD_DTRE   , cPictDt  )}, "", STR0022 } ) //"Dt. Exp."

//AADD(TB_Campos,{{ ||If(!Empty(Work->MENSA), Work->MENSA, )}, "", "Mensagem" } )

aRCampos:= E_CriaRCampos(TB_Campos,"C")

// ACSJ - 31/03/2005 - Mostra a mensagem caso não exista dados - INICIO
if .not. Work->( Eof() ) .and. .not. Work->( Bof() )
   EA150REL(aDados,aRCampos,oMark)
Else
   MsgInfo(STR0036) // "Nao ha dados p/ serem listados !!!"
Endif
 // ---------------------------------------------------------- - FIM

Return .T.

*--------------------------------*
Static Function GeraQuery()
*--------------------------------*
Local cQuery, cCondDel:= " AND EDD.D_E_L_E_T_ <>'*' "

cQuery := " SELECT DISTINCT * FROM "+RetSqlName('EDD')+ " EDD "
cQuery += " WHERE EDD.EDD_FILIAL ='"+cFilEDD+"' "
cQuery += " AND EDD.EDD_DTRE > '"+DTOS(dDtIniRe)+"' "
cQuery += " AND EDD.EDD_DTRE < '"+DTOS(dDtFimRe)+"' "
cQuery += If(TcSrvType()<>"AS/400",cCondDel,"")

If !Empty(cAto)
   cQuery +=" AND EDD.EDD_AC = '"+cAto+"' "
Endif

If !Empty(cPreemb)
   cQuery +=" AND EDD.EDD_PREEMB = '"+cPreemb+"' "
Endif

cQuery+=" ORDER BY EDD.EDD_AC"

cQuery:=ChangeQuery(cQuery)
TcQuery cQuery ALIAS (cAliasEDD) NEW

If Select(cAliasEDD) <> 0
   TCSETFIELD(cAliasEDD,"EDD_DTREG","D")
   TCSETFIELD(cAliasEDD,"EDD_DTRE","D")
Endif

Return .T.

*------------------------------*
Static Function EA150CriaWork()
*------------------------------*
aEstru := {}
AADD(aEstru,{ "EDD_PD"    , AVSX3("EDD_PD", 02)    , AVSX3("EDD_PD", 03)    , AVSX3("EDD_PD", 04)})
AADD(aEstru,{ "EDD_AC"    , AVSX3("EDD_AC", 02)    , AVSX3("EDD_AC", 03)    , AVSX3("EDD_AC", 04)})
AADD(aEstru,{ "EDD_HAWB"  , AVSX3("EDD_HAWB", 02)  , AVSX3("EDD_HAWB", 03)  , AVSX3("EDD_HAWB", 04)})
AADD(aEstru,{ "EDD_PO_NUM", AVSX3("EDD_PO_NUM", 02), AVSX3("EDD_PO_NUM", 03), AVSX3("EDD_PO_NUM", 04)})
AADD(aEstru,{ "EDD_INVOIC", AVSX3("EDD_INVOIC", 02), AVSX3("EDD_INVOIC", 03), AVSX3("EDD_INVOIC", 04)})
AADD(aEstru,{ "EDD_PREEMB", AVSX3("EDD_PREEMB", 02), AVSX3("EDD_PREEMB", 03), AVSX3("EDD_PREEMB", 04)})
AADD(aEstru,{ "EDD_PEDIDO", AVSX3("EDD_PEDIDO", 02), AVSX3("EDD_PEDIDO", 03), AVSX3("EDD_PEDIDO", 04)})
AADD(aEstru,{ "EDD_PROD"  , AVSX3("EDD_PROD", 02)  , AVSX3("EDD_PROD", 03)  , AVSX3("EDD_PROD", 04)})
AADD(aEstru,{ "EDD_ITEM"  , AVSX3("EDD_ITEM", 02)  , AVSX3("EDD_ITEM", 03)  , AVSX3("EDD_ITEM", 04)})
AADD(aEstru,{ "EDD_DTREG" , AVSX3("EDD_DTREG", 02) , AVSX3("EDD_DTREG", 03) , AVSX3("EDD_DTREG", 04)})
AADD(aEstru,{ "EDD_DTRE"  , AVSX3("EDD_DTRE", 02)  , AVSX3("EDD_DTRE", 03)  , AVSX3("EDD_DTRE", 04)})
AADD(aEstru,{ "EDD_QTD"   , AVSX3("EDD_QTD", 02)   , AVSX3("EDD_QTD", 03)   , AVSX3("EDD_QTD", 04)})
AADD(aEstru,{ "EDD_QTD_EX", AVSX3("EDD_QTD_EX", 02), AVSX3("EDD_QTD_EX", 03), AVSX3("EDD_QTD_EX", 04)})
AADD(aEstru,{ "EDD_DI_NUM", AVSX3("W6_DI_NUM", 02) , AVSX3("W6_DI_NUM", 03) , AVSX3("W6_DI_NUM", 04)})
AADD(aEstru,{ "EDD_RE"    , AVSX3("EE9_RE", 02)    , AVSX3("EE9_RE", 03)    , AVSX3("EE9_RE", 04)})
AADD(aEstru,{ "EDD_SEQUEN", AVSX3("EDD_SEQUEN", 02), AVSX3("EDD_SEQUEN", 03), AVSX3("EDD_SEQUEN", 04)})
AADD(aEstru,{ "EDD_POSICA", AVSX3("EDD_POSICA", 02), AVSX3("EDD_POSICA", 03), AVSX3("EDD_POSICA", 04)})
AADD(aEstru,{ "EDD_UM"    , AVSX3("W8_UNID", 02)   , AVSX3("W8_UNID", 03)   , AVSX3("W8_UNID", 04)})
Aadd(aEstru,{ "ED3_UMPROD", AVSX3("ED3_UMPROD",02),  AVSX3("ED3_UMPROD",03),  AVSX3("ED3_UMPROD",04)})
Aadd(aEstru,{ "ED4_UMITEM", AVSX3("ED4_UMITEM",02),  AVSX3("ED4_UMITEM",03),  AVSX3("ED4_UMITEM",04)})

//AADD(aEstru,{ "EDD_MENSA" , "C", 50, 0})

cNomArq:=E_CriaTrab(,aEstru,"Work")
IndRegua("Work",cNomArq+TEORDBAGEXT(),"EDD_AC+DTOS(EDD_DTREG)+EDD_RE")//AAF 30/06/05 - Adicionado data do registro e nr. do RE

Return .T.

*------------------------------*
Static Function EA150GRVWORK()
*------------------------------*
Local cFilEE9:= xFilial("EE9")
Local cFilSW6:= xFilial("SW6")
Local cFilED2:= xFilial("ED2")

bWhile:={||(cAliasEDD)->EDD_FILIAL==cFilEDD}
cChave:=cFilEDD

EDD->(dbSetOrder(1))
SW6->(dbSetOrder(1))
EE9->(dbSetOrder(2))

WORK->(avzap())

If !lTop
   If !Empty(cAto) .And. Empty(cPreemb)
      bWhile:={||(cAliasEDD)->EDD_FILIAL+(cAliasEDD)->EDD_AC==cFilEDD+cAto}
      cChave:=cFilEDD+cAto
   ElseIf !Empty(cAto) .And. !Empty(cPreemb)
      bWhile:={||(cAliasEDD)->EDD_FILIAL+(cAliasEDD)->EDD_AC+(cAliasEDD)->EDD_PREEMB==cFilEDD+cAto+cPreemb}
      cChave:=cFilEDD+cAto+cPreemb
   ElseIf Empty(cAto) .And. !Empty(cPreemb)
      bWhile:={||(cAliasEDD)->EDD_FILIAL+(cAliasEDD)->EDD_PREEMB==cFilEDD+cPreemb}
      cChave:=cFilEDD+cPreemb
      (cAliasEDD)->(dbSetOrder(2))
   Endif
   (cAliasEDD)->(DbSeek(cChave))
Endif

ED3->(DBSetOrder(2))
ED4->(DBSetOrder(2))

//** AAF 16/10/2006
//If lDiExt - NOPADO POR AOM - 04/11/10
   ED8->( dbSetOrder(4) )
   cFilED8 := xFilial("ED8")
//EndIf
//**

Do While (cAliasEDD)->(!EOF()) .And. If(!lTop, Eval(bWhile), .T.)
   
   //EE9->(dbseek(cFilEE9+(cAliasEDD)->EDD_PREEMB+(cAliasEDD)->EDD_PEDIDO+(cAliasEDD)->EDD_SEQUEN))
   EE9->(dbseek(iF(lMultifil,(cAliasEDD)->EDD_FILEXP,cFilEE9)+(cAliasEDD)->EDD_PREEMB+(cAliasEDD)->EDD_PEDIDO+(cAliasEDD)->EDD_SEQUEN))
      
   ED3->(DBSeek( xFilial("ED3") + (cAliasEDD)->EDD_AC + (cAliasEDD)->EDD_SEQSIE ))
   ED4->(DBSeek( xFilial("ED4") + (cAliasEDD)->EDD_AC + (cAliasEDD)->EDD_SEQSII )) 
   
   Work->(dbAppend())
   
   Work->EDD_PD    := (cAliasEDD)->EDD_PD
   Work->EDD_AC    := (cAliasEDD)->EDD_AC
   Work->EDD_PO_NUM:= (cAliasEDD)->EDD_PO_NUM
   Work->EDD_INVOIC:= (cAliasEDD)->EDD_INVOIC
   Work->EDD_PREEMB:= (cAliasEDD)->EDD_PREEMB
   Work->EDD_PEDIDO:= (cAliasEDD)->EDD_PEDIDO
   Work->EDD_SEQUEN:= (cAliasEDD)->EDD_SEQUEN
   Work->EDD_POSICA:= (cAliasEDD)->EDD_POSICA
   Work->EDD_PROD  := (cAliasEDD)->EDD_PROD
   Work->EDD_ITEM  := (cAliasEDD)->EDD_ITEM
   Work->EDD_DTREG := (cAliasEDD)->EDD_DTREG
   Work->EDD_QTD   := (cAliasEDD)->EDD_QTD
   Work->EDD_QTD_EX:= (cAliasEDD)->EDD_QTD_EX
   Work->EDD_DTRE  := (cAliasEDD)->EDD_DTRE   

   //** AAF 16/10/2006
   If Empty((cAliasEDD)->EDD_PO_NUM) .AND. ED8->( dbSeek(cFilED8+(cAliasEDD)->(AllTrim(EDD_HAWB)+EDD_POSICA)) ) // lDiExt .AND. - NOPADO POR AOM - 04/11/10  
      Work->EDD_HAWB  := "DI Externa"
      Work->EDD_DI_NUM:= ED8->ED8_DI_NUM
   //ElseIf SW6->(dbseek(cFilSW6+(cAliasEDD)->EDD_HAWB))
   ElseIf SW6->(dbseek(If(lMultiFil,(cAliasEDD)->EDD_FILEXP,cFilSW6)+(cAliasEDD)->EDD_HAWB)) //AJP 27/06/2007
      Work->EDD_HAWB  := (cAliasEDD)->EDD_HAWB
      Work->EDD_DI_NUM:= SW6->W6_DI_NUM
   EndIf
   //**
   
   Work->EDD_RE    := EE9->EE9_RE
   WORK->ED3_UMPROD:= ED3->ED3_UMPROD
   WORK->ED4_UMITEM:= ED4->ED4_UMITEM
   
   (cAliasEDD)->(dbSkip())

Enddo

Return .T.

*----------------------------------------------*
Static Function EA150REL(aDados,aRCampos,oMark)
*----------------------------------------------*
If DTOC(dDtIniRe) <> "01/01/50" .And. DTOC(dDtFimRe) <> "31/12/99"
   cSay:= STR0023+DTOC(dDtIniRe)+STR0024+DTOC(dDtFimRe) //"Período de "###" até "
ElseIf DTOC(dDtIniRe) <> "01/01/50" .And. DTOC(dDtFimRe) = "31/12/99"
   cSay:= STR0025+DTOC(dDtIniRe) //"Período - desde "
ElseIf DTOC(dDtIniRe) = "01/01/50" .And. DTOC(dDtFimRe) <> "31/12/99"
   cSay:= STR0026+DTOC(dDtFimRe) //"Período - até "
Else
   cSay:= STR0027 //"Período de __/__/__ até __/__/__"
Endif

aDados[7]:= If(!Empty(cAto), STR0028+cAto, STR0029)+Space(10)+If(!Empty(cPreemb), STR0030+cPreemb, STR0031)+Space(105)+cSay //"Ato Concessório "###"Ato Concessório - Todos"###"Pedido Exp. "###"Pedido Exp. - Todos"


E_Report(aDados,aRCampos)

Return .T.                                      

*-----------------------------*
Static Function EA150MENSA()
*-----------------------------*
If !lPrim
   Work->(dbSkip(-1))
Endif

If !lPrim
   If Work->EDD_QTD < 0
      PulaLinha()
      @ Linha, 001 PSAY STR0032+Alltrim(Transf(ABS(Work->EDD_QTD), cPictQtd))+STR0033 //"Mensagem - Alterar a Quantidade no Drawback. Acrescente "###" na Qtde. Importada para a perfeita apropriação do Ato Concessório."
      PulaLinha()
      @ Linha,000 PSAY __PrtThinline()
      Work->(dbSkip())
      PulaLinha()     
   ElseIf !lPrim
      Work->(dbSkip())
   Endif
Endif

lPrim:= .F.

If cGrupo <> WORK->EDD_AC
   cGrupo := WORK->EDD_AC
   Linha += 2
   @Linha,001 PSay "Ato Concessorio : " + WORK->EDD_AC
Endif
                                    
Return .T.

*--------------------------*
Static Function PulaLinha()
*--------------------------*
IF Linha > 55
   Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
   Linha := 09
Else
   If Linha = 08
      Linha+=2
   Else
      Linha++
   Endif
Endif

Return .T.
