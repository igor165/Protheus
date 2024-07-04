#INCLUDE "Eicqc210.ch"
#INCLUDE "Average.ch"
//#include "FiveWin.ch"
#DEFINE INCLUSAO   3
#DEFINE ALTERACAO  4
#DEFINE EXCLUSAO   5
#DEFINE VISUAL_DEL "2,5"
#DEFINE ALTE_EXCLU "4,5"
#DEFINE AVALIA     6
#DEFINE CANCELA    7
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ EICQC210 ³ Autor ³ AVERAGE-ALEX WALLAUER ³ Data ³ 22/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Programa de Cotacao de Precos                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*------------------*
Function EICQC210()
*------------------*
LOCAL  nOldArea:=SELECT(),I
Private lIntLogix := EasyGParam("MV_EIC_EAI",,.F.)    // Sandro Silva - REQ03   - 13/05/2014
If lIntLogix
   EICQC400()
   Return NIL
EndIf
PRIVATE aTela := {}, aGets := {},aWork:= {}
PRIVATE aRotina := MenuDef(.T.)//BHF - 25/06/2008 - Parâmetro para lMBrowse

PRIVATE cCadastro := OemtoAnsi(STR0007) //"Cota‡Æo de Precos"
PRIVATE cTitulo   := OemtoAnsi(STR0008) //"Quadro de Concorrˆncia"
PRIVATE aCampos   :={}, cNomArqWS, cNomArqWT, aDeletados:={}
Private aButtons:={} // FSM - 11/07/11

// PLB 20/09/07 - Verifica se existe tratamento de Incoterm na Cotação
Private lIncoterm := SWT->( FieldPos("WT_INCOTER") > 0  .And.  FieldPos("WT_VL_UNIT") > 0 )


PRIVATE aSemSX3WT:={ {"WT_DESCR"  ,"C",40,0} ,;
                     {"WT_DESCR_P","C",40,0},;
                     {"WT_DESCRFO","C",40,0},;
                     {"WT_DESCRFA","C",40,0},;
                     {"WT_RECNO"  ,"N",07,0},;
                     {"WT_QTDE"   ,"N",AVSX3("WS_QTDE",3),AVSX3("WS_QTDE",4)},;
                     {"WT_CIF"    ,"N",17,2},;
                     {"WT_CLASS"  ,"C",02,0},;
                     {"WT_CIF_P"  ,"N",17,2},;
                     {"WT_DT_NEC" ,"D",08,0},;
                     {"WT_REPRES" ,"C",52,0},;
                     {"WT_FONES"  ,"C",28,0},;
                     {"WT_FAX"    ,"C",30,0},;
                     {"WT_DES_PAG","C",36,0},;
                     {"WT_CONTATO","C",50,0},;
                     {"WT_NR_CONC","C",06,0},;
                     {"WT_RECNO2" ,"N",05,0}}

                     aWork := AddCpoUser(aWork,"SWT","1") //LRS 10/03/2015 - Array de campo de usuario.

                     For I := 1 To Len(aWork)
                        AADD(aSemSX3WT,{aWork[I],AVSX3(aWork[I],2),AVSX3(aWork[I],3),AVSX3(aWork[I],4)})
                     Next

                     If SWT->(FieldPos("WT_DTNECES")) # 0
                        AADD(aSemSX3WT,{"WT_DTNECES","D",08,0})
                     EndIf

                     AADD(aSemSX3WT,{"TRB_ALI_WT","C",03,0}) //TRP - 25/01/07 - Campos do WalkThru
                     AADD(aSemSX3WT,{"TRB_REC_WT","N",10,0})

//IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"ADSTRUWT"),)	//ASR 28/07/05

PRIVATE aSemSx3WS:={ {"WS_UNI"    ,"C",03,0},;
                     {"WS_RECNO"  ,"N",07,0},;
                     {"TRB_ALI_WT","C",03,0},; //TRP - 25/01/07 - Campos de WalkThru
                     {"TRB_REC_WT","N",10,0}}

//MUDANÇA DE LOCAL PONTO DE ENTRADA - LAM 26/05/06
IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"ADSTRUWT"),)	//ASR 28/07/05

PRIVATE cFilSWR:=xFilial("SWR"),cFilSWS:=xFilial("SWS"),cFilSWT:=xFilial("SWT")
PRIVATE cFilSW1:=xFilial("SW1"),cFilSA5:=xFilial("SA5"),cFilSB1:=xFilial("SB1")
PRIVATE aHeader[0],nUsado:=0,lBrow:=.T.
PRIVATE cPicQtde  :=ALLTRIM(X3Picture("WS_QTDE"))
PRIVATE cPicPeso  :=AVSX3("B1_PESO",6)
PRIVATE cPicFOBUni:=ALLTRIM(X3Picture("WT_FOB_UNI"))
PRIVATE cPicFreKG :=ALLTRIM(X3Picture("WT_FRE_KG"))
PRIVATE cPicSeguro:=ALLTRIM(X3Picture("WT_SEGURO"))
PRIVATE cPicUltFob:=AVSX3("WT_ULT_FOB" ,6)
PRIVATE cPicCIF   :="@E 99,999,999,999,999.99"
Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictQtde := ALLTRIM(X3Picture("W3_QTDE"))
PRIVATE cNo6CdxWT	//ASR 28/07/05

//*********************************************WORK1 ITENS
aCampos:=ARRAY(SWS->(FCOUNT()))
cNomArqWS:=E_CriaTrab("SWS",aSemSx3WS,"Work1")
IF EasyGParam("MV_EIC0052",,.T.) //MCF 29/12/2014
	IndRegua("Work1",cNomArqWS+TEOrdBagExt(),"WS_COD_I")
Else
	IndRegua("Work1",cNomArqWS+TEOrdBagExt(),"WS_COD_I+DTOS(WS_DTNECES)")
Endif

SET INDEX TO (cNomArqWS+TEOrdBagExt())

//*********************************************WORK2 FORNECEDORES
aCampos:=ARRAY(SWT->(FCOUNT()))
cNomArqWT:=E_CriaTrab("SWT",aSemSx3WT,"Work2")
IF EasyGParam("MV_EIC0052",,.T.) .OR. SWT->(FieldPos("WT_DTNECES")) == 0  //MCF 29/12/2014
   IndRegua("Work2",cNomArqWT+TEOrdBagExt(),"WT_COD_I")
Else
   IndRegua("Work2",cNomArqWT+TEOrdBagExt(),"WT_COD_I+DTOS(WT_DTNECES)")
EndIf

cNo1CdxWT:=E_Create({},.F.)//APENAS GERA UM NOME PARA O INDICE 2

If EICLOJA()
   If EasyGParam("MV_EIC0052",,.T.) .OR. SWT->(FieldPos("WT_DTNECES")) == 0
      IndRegua("Work2",cNo1CdxWT+TEOrdBagExt(),"WT_FORN+WT_FORLOJ+WT_COD_I")
   Else
      IndRegua("Work2",cNo1CdxWT+TEOrdBagExt(),"WT_FORN+WT_FORLOJ+WT_COD_I+DTOS(WT_DTNECES)")
   EndIf
Else
   IndRegua("Work2",cNo1CdxWT+TEOrdBagExt(),"WT_FORN+WT_COD_I")
Endif

cNo2CdxWT:=E_Create({},.F.)//APENAS GERA UM NOME PARA O INDICE 3
IndRegua("Work2",cNo2CdxWT+TEOrdBagExt(),"WT_COD_I+STR(WT_CIF,17,2)")

cNo3CdxWT:=E_Create({},.F.)//APENAS GERA UM NOME PARA O INDICE 4

If EICLOJA()
   IndRegua("Work2",cNo3CdxWT+TEOrdBagExt(),"WT_CLASS+WT_FORN+WT_FORLOJ")
Else
   IndRegua("Work2",cNo3CdxWT+TEOrdBagExt(),"WT_CLASS+WT_FORN")
Endif

cNo4CdxWT:=E_Create({},.F.)//APENAS GERA UM NOME PARA O INDICE 5
IndRegua("Work2",cNo4CdxWT+TEOrdBagExt(),"WT_COD_I+DTOS(WT_DT_FORN)")

cNo5CdxWT:=E_Create({},.F.)//APENAS GERA UM NOME PARA O INDICE 6
IndRegua("Work2",cNo5CdxWT+TEOrdBagExt(),"WT_COD_I+STR(WT_FOB_TOT,15,5)")

IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"IND_AVALIA"),)	//ASR 28/07/05

Work2->(OrdListClear())//O set index depende da opcao escolida - manutencao ou avalia

//*********************************************WORK3 FORNECEDORES
aCampos:=ARRAY(SWT->(FCOUNT()))
cNomArq2WT:=E_CriaTrab("SWT",aSemSx3WT,"Work3")

If EICLOJA()
   IndRegua("Work3",cNomArq2WT+TEOrdBagExt(),"WT_FORN+WT_FORLOJ+WT_FABR+WT_FABLOJ")
Else
   IndRegua("Work3",cNomArq2WT+TEOrdBagExt(),"WT_FORN+WT_FABR")
Endif

SET INDEX TO (cNomArq2WT+TEOrdBagExt())

SA5->(DBSETORDER(2))
SY7->(DBSETORDER(3))

DbSelectArea("SWR")

mBrowse( 6, 1,22,75,"SWR")

Work1->(E_EraseArq(cNomArqWS))
Work2->(E_EraseArq(cNomArqWT,cNo1CdxWT))
Work3->(E_EraseArq(cNomArq2WT))

FErase(cNo2CdxWT+TEOrdBagExt())
FErase(cNo3CdxWT+TEOrdBagExt())
FErase(cNo4CdxWT+TEOrdBagExt())
FErase(cNo5CdxWT+TEOrdBagExt())

SA5->(DBSETORDER(1))
SY7->(DBSETORDER(1))
DBSELECTAREA(nOldArea)
Return .T.


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 25/01/07 - 14:10
*/
Static Function MenuDef(lMBrowse)//BHF - 25/06/2008 - Inclusão do parâmetro lMBrowse
Local aRotAdic := {}
Local aRotina :=  { { STR0001   ,"AxPesqui"   , 0 , 1},; //"&Pesquisar"
                    { STR0002   ,"QCMANSWR"   , 0 , 2},; //"&Visual"
                    { STR0003   ,"QCMANSWR"   , 0 , 3},; //"&Inclui"
                    { STR0004   ,"QCMANSWR"   , 0 , 4/*, 20*/ },; //"&Altera"
                    { STR0005   ,"QCMANSWR"   , 0 , 5/*, 21*/ } } //"&Exclui"
                    //LRS - 19/04/2017 - Nopado o quinto parametro do arotina para não ter problemas caso o usuario tenha a rotina 20 e 21 bloqueadas

If Select("SX6") > 0 .AND. !EasyGParam("MV_EIC_EAI",,.F.)
   aAdd(aRotina, { STR0006   ,"QC210Avalia", 0 , 6, 21 } )  //"Ava&lia"
EndIf

//Default lMBrowse := .F. - Nopado pois é necessário retornar todas as opções da rotina. Apenas o menufuncional não pode exibi-las (funcao GETMENUDEF é do menu funcional).
Default lMBrowse := OrigChamada()

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IQC210MNU")
	aRotAdic := ExecBlock("IQC210MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"  //LRS
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf
// If SWR->(FieldPos("WR_STATUS")) > 0 ==>BHF - 25/06/2008 - Alteração
If lMbrowse .and. SWR->(FieldPos("WR_STATUS")) > 0
   aAdd(aRotina, { STR0152   ,"QCMANSWR"   , 0 , 7, 21 })  //"Cancela" -  TLM 28/05/2008
EndIf

Return aRotina
*--------------------------------------*
FUNCTION QCManSWR(cAlias,nReg,nOpc)
*--------------------------------------*
LOCAL oDlg, I, cTitulo:= OemtoAnsi(STR0009) //"Quadro de Concorrˆncia - "
LOCAL oEnCh1
Local lLoop // RA - 06/11/2003 - O.S. 1061/03
Local lDt_CONC //LRL 30/01/04 -Data de Criação esta Ok
Local aWork :={} //LRS 10/03/2015
Local nPosBt
Local aButtonsIt :={}//aButtons a ser utilizado para a tela de Itens
Local aButtonsFo :={}//aButtons a ser utilizado para a tela de Fornecedores
Private aCamposWT :={} //DFS - 05/02/10 - Troca de Local para Private, para uso no ponto de entrada
PRIVATE lExecuta := .T. //ASR 13/01/2006
PRIVATE nUsado:=0, oObj, aHeader[0], lAlterou:=.F., dDataEnt
PRIVATE nOpca:=0, cMarca:=GetMark(), lInverte:=.F., lWork1:=.T., lInclusao:=.F.
PRIVATE aDeletWS:={}, aDeletWT:={}, cTipo:="", cTit:=""
PRIVATE aCamposWS:={}
PRIVATE lExclui:=.F.
PRIVATE bPart_Number:={|| IF(!EMPTY(Work3->WT_FABR),;
                      BuscaPart_N(xFilial("SA5")+Work3->WT_COD_I+Work3->WT_FABR+Work3->WT_FORN,IF(EICLoja(), Work3->WT_FORLOJ, ""),If(EICLoja(), Work3->WT_FABLOJ, "")), Nil)}

aTela := {}
aGets := {}

AADD(aCamposWS,{"WS_COD_I"    ,"",STR0010}) //"Produto"
AADD(aCamposWS,{"WS_DESCR"    ,"",STR0011}) //"Descrição"
AADD(aCamposWS,{"WS_QTDE"     ,"",STR0012 ,cPicQtde }) //"Quantidade"
AADD(aCamposWS,{"WS_PESO"     ,"",STR0013,cPicPeso}) //"Peso Total "
AADD(aCamposWS,{"WS__CC"      ,"",STR0014}) //"C.C."
AADD(aCamposWS,{"WS_SI_NUM"   ,"",STR0015}) //"S.I."
AADD(aCamposWS,{"WS_DTNECES"  ,"",STR0016}) //"Dt.Prev."

AADD(aCamposWT,{"WT_FORN"    ,"",STR0017}) //"Cod. Forn."
AADD(aCamposWT,{"WT_DESCRFO" ,"",STR0018}) //"Fornecedor"
AADD(aCamposWT,{bPart_Number ,"",STR0019}) //"Part Number"
AADD(aCamposWT,{"WT_ORIGEM"  ,"",STR0020 }) //"Origem"
//** PLB 20/09/07
//AADD(aCamposWT,{"WT_MOEDA"   ,"",STR0021}) //"Moeda FOB"
If lIncoterm
   AADD(aCamposWT,{"WT_INCOTERM","",STR0149})  // "Incoterm"
EndIf
AADD(aCamposWT,{"WT_MOEDA"   ,"",STR0021}) //"Moeda Neg."
If lIncoterm
   AADD(aCamposWT,{"WT_VL_UNIT","",STR0148,cPicFOBUni})  // "Cond.Venda Unit"
EndIf
//**
AADD(aCamposWT,{"WT_FOB_UNI" ,"",STR0022 ,cPicFOBUni}) //"FOB Unit."
AADD(aCamposWT,{"WT_MOE_FRE" ,"",STR0023}) //"Moeda Frete"
AADD(aCamposWT,{"WT_FRE_KG"  ,"",STR0024,cPicFreKG}) //"Frete Total"
AADD(aCamposWT,{"WT_SEGURO"  ,"",STR0025     ,cPicSeguro}) //"Seguro"
AADD(aCamposWT,{"WT_ULT_ENT" ,"",STR0026}) //"Dt Ult Compra"
AADD(aCamposWT,{"WT_ULT_FOB" ,"",STR0027,cPicUltFob}) //"Vr Ultima Compra"
AADD(aCamposWT,{"WT_FOB_TOT" ,"",STR0028,cPicFOBUni}) //"FOB Total"
AADD(aCamposWT,{{||TRANS(Work3->WT_COD_PAG,'@R 9.9.999')+' '+TRANS(Work3->WT_DIASPAG,'999')} ,"","Cond Pagto"})
AADD(aCamposWT,{"WT_DT_FORN" ,"",STR0029}) //"Data Entr."
AADD(aCamposWT,{"WT_FABR"    ,"",STR0030}) //"Cod. Fabr."
AADD(aCamposWT,{"WT_DESCRFA" ,"",STR0031}) //"Fabricante"

aWork := AddCpoUser(aWork,"SWT","2") //LRS 10/03/2015 - Array de campo usuario.

For I := 1 To Len(aWork)
    AADD(aCamposWT,{aWork[I][1],"",aWork[I][3],aWork[I][4]})
Next

EICAddLoja(aCamposWT, "WT_FORLOJ", Nil, STR0017)
//DFS - Ponto de entrada para adicionar campos no Array aCamposWT
If EasyEntryPoint("EICQC210")
   ExecBlock("EICQC210",.F.,.F.,"ADD_CAMPOS_WT")
EndIf

IF STR(nOpc,1)$'245'// Visual,Altera,Deleta
   dbSelectArea("SWS")
   dbSetOrder(1)
   SWS->(dbSeek(cFilSWS+SWR->WR_NR_CONC))
   If EOF()
      Help(" ",1,"EICSEMIT")
      Return .T.
   Endif
   dbSelectArea("SWT")
   dbSetOrder(1)
   SWS->(dbSeek(cFilSWT+SWR->WR_NR_CONC))
ENDIF

//TRP-14/05/07-Inclusão de campos incluidos pelo configurador e que forem usados, no array da msselect.
//aOrd := SaveOrd("SX3",1)
//SX3->(dbSeek("SWS"))


   //While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SWS"
      //If SX3->X3_PROPRI=="U" .AND. Ascan(aCamposWS, {|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)})==0 .AND. X3Uso(SX3->X3_USADO)
         //aAdd(aCamposWS,{SX3->X3_CAMPO,"",AVSX3(SX3->X3_CAMPO,AV_TITULO),AVSX3(SX3->X3_CAMPO,AV_PICTURE)})
      //EndIF
      //SX3->(dbSkip())
   //Enddo
//RestOrd(aOrd)

aCamposWS:= AddCpoUser(aCamposWS,"SWS","2")

aCamposWT:= AddCpoUser(aCamposWT,"SWT","2")

dbSelectArea("SWR")
FOR I := 1 TO FCount()
    IF nOpc=INCLUSAO
       M->&(FIELDNAME(i))   := CRIAVAR(FIELDNAME(i))
    ELSE
       M->&(EVAL({|nCPO|Field(nCPO)},i)) := FieldGet(i)
    ENDIF
NEXT

// RA - 06/11/2003 - O.S. 1061/03 - Inicio
If Inclui .And. GetNewPar("MV_NRCO",.F.)
   M->WR_NR_CONC := "." // Inicializado para passar pela validacao da primeira tela
EndIf
// RA - 06/11/2003 - O.S. 1061/03 - Final

DBSELECTAREA('Work1')//LRS - 20/02/2015 - Correção de Duplicação de registro dentro da cotação de preço no S.I.
Avzap('Work1')
DBSELECTAREA('Work2')
DBSETINDEX(cNomArqWT+TEOrdBagExt())
DBSETINDEX(cNo1CdxWT+TEOrdBagExt())
Avzap('Work2')

// TLM 28/05/2008 - Tratamento para o a rotina Cancela no menu da mBrowse.
If SWR->(FieldPos("WR_STATUS")) > 0
   If SWR->WR_STATUS == '*' .And.  ( nOpc == ALTERACAO  .Or. nOpc == AVALIA .Or. nOpc == CANCELA )  // TLM
      MsgInfo(STR0153,"Atenção")   //"Essa contação está foi cancelada","Atenção"
      return
   EndIf
EndIf
IF nOpc # INCLUSAO

   Processa({||QC210GrvWorks()},STR0032) //"Processando Registros da Concorrencia"
   IF Work1->(Easyreccount("Work1")) == 0
      Help(" ",1,"EA200SEMIT")
      dbSelectArea("SWR")
      Return .T.
   ENDIF

ENDIF
Work1->(DBGoTop())
Work2->(DBGoTop())
aButtons:={}
IF lWork1
   Aadd(aButtons,{"EDIT",{||nOpca:=7,oDlg:End()},STR0143})
ENDIF

IF STR(nOpc,1) $ '2,5'
   IF lWork1
      Aadd(aButtons,{"RELATORIO",{||nOpca:=3,oDlg:End()},STR0034})
   ENDIF
ELSEIF nOpc # 6
   Aadd(aButtons,{"EDIT",{||nOpca:=1,oDlg:End()} ,STR0105}) //"Inclusão"
   Aadd(aButtons,{"IC_17",{||nOpca:=2,oDlg:End()} ,STR0106}) //"Alteração"
   Aadd(aButtons,{"EXCLUIR",{||nOpca:=5,oDlg:End()} ,STR0107 }) //"Exclusão"
   IF lWork1
      Aadd(aButtons,{"RELATORIO",{||nOpca:=3,oDlg:End()},STR0034})
      Aadd(aButtons,{"NOTE",{||nOpca:=8,oDlg:End()},STR0108})
      IF(EasyEntryPoint("EICQC210"),ExecBlock("EICQC210",.F.,.F.,"BTINCLUI"),) //JWJ 01/08/05
   ENDIF
ELSEIF nOpc == 6
	IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"BTAVALIA"),)	//ASR 28/07/05
ENDIF
aButtonsIt := aClone(aButtons)
aButtonsFo := aClone(aButtons)
If (nPosBt := aScan(aButtonsFo, {|x| Alltrim(x[3]) == STR0034 })) > 0
    aDel(aButtonsFo, nPosBt)
    aSize(aButtonsFo, Len(aButtonsFo)-1)
EndIf
WHILE .T.
     nOpca := 0
     cCadastro:=IF(lWork1,STR0033,STR0034) //"Itens"###"Fornecedores"

     oMainWnd:ReadClientCoors()
     DEFINE MSDIALOG oDlg TITLE cTitulo+cCadastro;
            FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
                     OF oMainWnd PIXEL

     aTela := {}
     aGets := {}
     nUsado:=0

     IF lWork1
        aButtons := aButtonsIt
        lBrow:=.F.

        nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
        oEnCh1 := MsMGet():New( cAlias, nReg,nOpc,,,,,{ 15,  1, nMeio-1 , (oDlg:nClientWidth-4)/2 }, , 3)

        aEnchCampo:={"WS_COD_I","WS_DESCR","WS_QTDE",;
                     "WS__CC","WS_SI_NUM","WS_DTNECES"}

        //TRP-14/05/07-Inclusão de campos incluidos pelo configurador e que forem usados, no array da enchoice.
        //aOrd := SaveOrd("SX3",1)
        //SX3->(dbSeek("SWS"))
        //While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SWS"
           //If SX3->X3_PROPRI=="U" .AND. Ascan(aEnchCampo,Alltrim(SX3->X3_CAMPO))==0 .AND. X3Uso(SX3->X3_USADO)
              //aAdd(aEnchCampo,AllTrim(SX3->X3_CAMPO))
           //EndIF
           //SX3->(dbSkip())
        //Enddo
        //RestOrd(aOrd)
        dbSelectArea("Work1")
        cWork :="Work1"; cArea:="SWS"
        cTit  :=ALLTRIM(OemtoAnsi(STR0035)+M->WR_NR_CONC) //"Item da Concorrˆncia "
        aValid:={"1","2","3","4","5"}
        IF(EasyEntryPoint("EICQC210"),ExecBlock("EICQC210",.F.,.F.,"ALTERA_ORDEM"),)
        Work1->(oObj:=MsSelect():New("Work1",,,aCamposWS,@lInverte,@cMarca,{nMeio,1,if(SetMdiChild(),(oDlg:nClientHeight+86)/2,(oDlg:nClientHeight-6)/2),(oDlg:nClientWidth+4)/2})) //LRL 16/03/04 - o tamanho da tela é diferente no MDI

        oObj:bAval:={||IF(STR(nOpc,1)$'34',nOpca:=2,nOpca:=4),oDlg:End()}
        oObj:oBrowse:bwhen:={||(dbSelectArea("Work1"),.t.)}

     ELSE
        aButtons := aButtonsFo
        dbSelectArea("Work1")
        FOR I := 1 TO FCount()
            M->&(FIELDNAME(I)) :=FIELDGET(I)
        NEXT

        aEnchWork1:={"WS_COD_I","WS_DESCR","WS_QTDE","WS_PESO",;
                     "WS__CC","WS_SI_NUM","WS_DTNECES"}

        nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
        oEnCh1 := MsMGet():New("SWS",Work1->(RECNO()),4,,,,,{15,1,nMeio-1, (oDlg:nClientWidth-2)/2},{},3)

        DBSelectArea("Work3")

        If Empty(Work3->(DbFilter())) .AND. SWT->(FieldPos("WT_DTNECES")) # 0 .AND. EasyGParam("MV_EIC0052",,.T.) //LRS - 26/04/2017
            Work3->(DBGoTop())
            While !(Work3->(EOF()))

                If Empty(Work3->WT_DTNECES)
                    Work3->WT_DTNECES = Work1->WS_DTNECES
                EndIf

                Work3->(DbSkip())
            End While
            Work3->(DBGoTop())

            cFiltro := Work1->WS_DTNECES
            SET FILTER TO Work3->WT_DTNECES == cFiltro
        EndIf

        cWork     :="Work3";  cArea:="SWT"
        cTit      :=ALLTRIM(STR0036+Work3->WT_COD_I) //"Fornecedor do Item "
        aValid    :={"9","10","11","12","13","14","15"}
        If lIncoterm  // PLB 20/09/07
           aEnchCampo := { "WT_FORN"  , "WT_FORNOME", "WT_FOB_TOT", "WT_FABR" , "WT_FABRNOM", "WT_DT_FORN", "WT_ORIGEM" ,  ;
                           "WT_SEGURO", "WT_COD_PAG", "WT_DIASPAG", "WT_MOEDA", "WT_VL_UNIT", "WT_INCOTER", "WT_FOB_UNI",  ;
                           "WT_MOE_FRE", "WT_FRE_KG" }

           EICAddLoja(aEnchCampo, "WT_FORLOJ", Nil, "WT_FORN")
           EICAddLoja(aEnchCampo, "WT_FABLOJ", Nil, "WT_FABR")

           aEnchCampo := AddCpoUser(aEnchCampo,"SWT","1") //LRS 10/03/2015 - Array de campo de usuario.

        Else
           aEnchCampo:={"WT_FORN","WT_FORNOME","WT_FOB_TOT","WT_FABR","WT_FABRNOM",;
                        "WT_DT_FORN","WT_ORIGEM","WT_SEGURO","WT_COD_PAG","WT_DIASPAG",;
                        "WT_MOEDA","WT_FOB_UNI","WT_MOE_FRE","WT_FRE_KG"}

           aEnchCampo := AddCpoUser(aEnchCampo,"SWT","1") //LRS 10/03/2015 - Array de campo de usuario.

           EICAddLoja(aEnchCampo, "WT_FORLOJ", Nil, "WT_FORN")
           EICAddLoja(aEnchCampo, "WT_FABLOJ", Nil, "WT_FABR")

        EndIf

        Work3->(oObj:=MsSelect():New("Work3",,,aCamposWT,@lInverte,@cMarca,{nMeio,1,if(SetMdiChild(),(oDlg:nClientHeight+86)/2,(oDlg:nClientHeight-2)/2),(oDlg:nClientWidth-2)/2}))
        oObj:bAval:={||IF(STR(nOpc,1)$'34',nOpca:=2,nOpca:=4),oDlg:End()}
        oObj:oBrowse:bwhen:={||(dbSelectArea("Work3"),.T.)}
        oObj:oBrowse:Refresh()
     ENDIF
     If nOpc == 7
        Activate Msdialog oDlg on Init EnchoiceBar(oDlg,{|| nOpca:= 9, oDlg:End()},{|| oDlg:End()} )
     Else
        oDlg:lMaximized:=.T.
	 oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	 oObj:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
     ACTIVATE MSDIALOG oDlg  ON INIT ;
             ( EnchoiceBar(oDlg,{|| IF(!STR(nOpc,1)$VISUAL_DEL.AND.QC210EndValid({"7","8"})      ,(nOpca:=6,oDlg:End()),;
                                    IF( STR(nOpc,1)$VISUAL_DEL.AND.(lExclui:=QCConfDel(nOpc,.F.)),(nOpca:=6,oDlg:End()),))},;
                                 {||nOpca:=0,oDlg:End()},,aButtons)) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
     EndIf

     If !Empty(Work3->(DbFilter())) .AND. SWT->(FieldPos("WT_DTNECES")) # 0
        Work3->(DbClearFilter())
     EndIf

     IF(EasyEntryPoint("EICQC210"),ExecBlock("EICQC210",.F.,.F.,"ANTES_GRAVA"),)
     DO CASE
        CASE nOpca == 0 //Botao Sair
             IF lWork1; EXIT; ELSE; lWork1:=.T.; LOOP; ENDIF

        CASE nOpca == 1 //Botao Inclusao <Ctrl+V>
             cTipo:=STR0037 //" - Inclusão"
             QC210Manut(3)   
             (cWork)->(DBGoTop())
             LOOP

        CASE nOpca == 2 //Botao Alteracao <Ctrl+A>
             cTipo:=STR0038 //" - Alteração"
             QC210Manut(4)   ; LOOP

        CASE nOpca == 3 //Botao Trocar Work <Ctrl+F>

             IF Empty(Work2->WT_NR_CONC) .AND. !EMPTY(Work2->WT_COD_I)//LRS - 27/06/2015
                Work2->WT_NR_CONC := M->WR_NR_CONC
             EndIF

             IF Work1->(BOF()) .AND. Work1->(EOF())
                Help("", 1, "AVG0000475")//"NÆo existe item para incluir Fornecedores"###"Aviso"
                LOOP
             ENDIF
             IF !STR(nOpc,1)$VISUAL_DEL .AND. EMPTY(M->WR_VIA)
                Help("", 1, "AVG0000476")//"Via de Transporte nÆo preenchida"###"Aviso"
                LOOP
             ENDIF

             dbSelectArea("Work3") ; AvZap()
             Processa({||QC210Grv3Work(.F.)},STR0042+Work1->WS_COD_I ) //"Processando Fornecedores do Item "
             Work3->(DBGoTop()); lWork1:=.F.; lAlterou:=.F. ; LOOP

        CASE nOpca == 4 //2CLICK Visualisar
             cTipo:=STR0043 //" - Visualisar"
             QC210Manut(2)   ; LOOP

        CASE nOpca == 5 //Botao Exclusao
             cTipo:=STR0044 //" - Exclusão"
             QC210Manut(5)   ; LOOP

        CASE nOpca == 6 //Botao OK
             ***********************************
             //LRL 30/01/04 - Validação da Data de Entrada contra Data de Entrega
             If Inclui
                If ValType(dDataEnt) <> "U"
                  If !E_PERIODO_OK(M->WR_DT_CONC,dDataEnt) //
                    Help(" ",1,"AVG0005370")
                    Loop
                  EndIf
                EndIF
             Else
                SWT->(dbSetOrder(1))
                SWT->(DBSEEK(cFilSWT+M->WR_NR_CONC))
                If(E_PERIODO_OK(M->WR_DT_CONC,SWT->WT_DT_FORN),lDt_CONC:=.T.,lDt_CONC:=.F.)
                If !ldt_conc
                     Help(" ",1,"AVG0005370")
                     Loop
                EndIf
             EndIf
             ******************************************
             IF STR(nOpc,1)$'34'

                IF lWork1
                   IF Work1->(BOF()) .AND. Work1->(EOF())
                      Help("", 1, "AVG0000477")//"Concorrˆncia nÆo pode ser gravada sem itens"###"Aviso"
                      LOOP
                   ENDIF
                   Begin Transaction
                   // RA - 06/11/2003 - O.S. 1061/03 - Inicio
                   // Processa({||QC210Grava(cAlias,nOpc)},STR0046 ) //"Gravando Informacoes da Concorrencia"
                   If Inclui .And. GetNewPar("MV_NRCO",.F.)
                      lLoop := .F.
                      Do While !lLoop

                         Processa({|| (lLoop:=QC210Grava(cAlias,nOpc)) },STR0046 ) //"Gravando Informacoes da Concorrencia"
                      EndDo
                   Else
                      Processa({||QC210Grava(cAlias,nOpc)},STR0046 ) //"Gravando Informacoes da Concorrencia"
                   EndIf
                   // RA - 06/11/2003 - O.S. 1061/03 - Final
                   End Transaction
                ELSE
                   Processa({||QC210Grv3Work(.T.)},STR0042+Work1->WS_COD_I ) //"Processando Fornecedores do Item "
                   lAlterou:=.F.; lWork1:=.T.; LOOP
                ENDIF

             ELSEIF nOpc = EXCLUSAO

                IF lWork1
                   IF lExclui
                      Processa({||QC210Exclui()},STR0047) //"Excluindo Registros"
                   ENDIF
                ELSE
                   lWork1:=.T.; LOOP
                ENDIF

             ELSEIF !lWork1
                lWork1:=.T.; LOOP
             ENDIF

        CASE nOpca == 7 //Botao IMPRESSAO

             lExecuta := .T.  //ASR 13/01/2006
			 IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"REL_AVALIA"),)	//ASR 28/07/05
			 IF lExecuta == .T.  //ASR 13/01/2006
			    EICQC251Rel(nOpc)
			 ENDIF
             LOOP

        CASE nOpca == 8 //Botao Itens\Forn.
             QC210PrUni(nOpc)
             LOOP

        CASE nOpca == 9  // TLM 28/05/2008 - Tratamento para cancelar a contação.
             If SWR->(FieldPos("WR_STATUS")) > 0
                If MsgYesNo("Deseja realmente cancelar a contação ?","Atenção")
                   Reclock("SWR",.F.)
                   SWR->WR_STATUS:='*'
                   SWR->(MSUNLOCK())
                EndIf
             EndIf
     ENDCASE

     EXIT

ENDDO

IF(EasyEntryPoint("EICQC210"),ExecBlock("EICQC210",.F.,.F.,"DEPOIS_GRAVA"),)
DBSELECTAREA('Work2') ; AvZap()
OrdListClear()
lBrow:=.T.
dbSelectArea("SWR")
Return 0

*-------------------------*
Function QC210Manut(nOpc)
*-------------------------*
LOCAL I, nFconut:=(cWork)->(FCount()), nOpc1:=0, lExclui:=.F.
PRIVATE oDlg1, nUsado:=0, aHeader[0], lPreenche:=.T.
PRIVATE nReg1:=(cWork)->(RECNO())
PRIVATE oEnch1
Private lMostrou := .F.
aTela := {}
aGets := {}
dbSelectArea(cWork)
IF STR(nOpc,1) $ ALTE_EXCLU
   IF (cWork)->(EOF()) .AND. (cWork)->(BOF())
      Help("", 1, "AVG0000478")//"NÆo existe Registros para a op‡Æo"###"Aviso"
      RETURN .T.
   ENDIF
ENDIF

lInclusao:=.F.

IF nOpc = INCLUSAO
   lInclusao:=.T.
   (cWork)->(DBGOBOTTOM())
   (cWork)->(DBSKIP())
ENDIF

FOR I := 1 TO nFconut
    M->&(FIELDNAME(I)) :=FIELDGET(I)
NEXT

WHILE .T.
    nOpc1 := 0

    DEFINE MSDIALOG oDlg1 TITLE cTit+cTipo FROM 9,0 TO 26,80 OF oMainWnd
    //A opcao 4 no parametro 3, e a array vazia no parametro 8, ‚ para aparecer os dados na opcao visual e exclusao AWR 31/8/98

	oEnCh1:=MsMGet():New(cArea, nReg1 ,IF(STR(nOpc,1)$VISUAL_DEL,4,nOpc), , , ,aEnchCampo,{15,1,(oDlg1:nClientHeight-2)/2,(oDlg1:nClientWidth-2)/2},IF(STR(nOpc,1)$VISUAL_DEL,{},), 3 )

	IF nOpc # INCLUSAO .AND. cWork="Work3"

       IF SA2->(DBSEEK(xFilial()+M->WT_FORN+EicRetLoja("M","WT_FORLOJ")))
          M->WT_FORNOME:=SA2->A2_NREDUZ
       ENDIF

       IF SA2->(DBSEEK(xFilial()+M->WT_FABR+EicRetLoja("M","WT_FABLOJ")))
          M->WT_FABRNOM:=SA2->A2_NREDUZ
       ENDIF

    ENDIF

	oEnch1:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

    ACTIVATE MSDIALOG oDlg1 ON INIT ;
             (EnchoiceBar(oDlg1,{||IF(!STR(nOpc,1)$VISUAL_DEL.AND.QC210EndValid(aValid),(nOpc1:=1,oDlg1:End()),;
                                  IF(STR(nOpc,1)$VISUAL_DEL.AND.(lExclui:=QCConfDel(nOpc,.T.)),(nOpc1:=1,oDlg1:End()),) )},;
                               {||nOpc1:=0,oDlg1:End()}) )CENTERED  //LRL 20/04/04 Alinahemnto MDi //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

    IF nOpc1 == 0; EXIT; ENDIF

    dbSelectArea(cWork)

    IF lWork1

       IF nOpc = EXCLUSAO

          QC210Del1Work(lExclui)

       ELSEIF !STR(nOpc,1) $ VISUAL_DEL

          IF !EMPTY(M->WS__CC) .AND. nOpc = INCLUSAO
             Processa({||QC210Itens(nOpc)},STR0049) //"Gravando Itens da S.I."
          ELSEIF !STR(nOpc,1)$VISUAL_DEL
             IF nOpc = INCLUSAO
                Work1->(DBAPPEND())
             ELSE
                Work1->(DBGOTO(nReg1))
             ENDIF
             FOR I := 1 TO nFconut
                 Work1->(FieldPut(I,M->&(FIELDNAME(I)) ))
             NEXT
             Work1->TRB_ALI_WT:= "SWS"
             Work1->TRB_REC_WT:= SWS->(Recno())
             QC210Links("","",Work1->WS_COD_I,Work1->WS_DTNECES,Work1->WS_QTDE,"",nOpc,"",,SW0->W0_MOEDA) // GFP - 24/07/2013
          ENDIF

       ENDIF

    ELSE

       IF nOpc = EXCLUSAO
          QC210Del1Work(lExclui)
       ELSEIF !STR(nOpc,1)$VISUAL_DEL
          lAlterou:=.T.
          QC210For(nOpc)
       ENDIF

    ENDIF

    EXIT

ENDDO

IF nOpc = EXCLUSAO
   (cWork)->(DBSKIP())
   IF (cWork)->(EOF())
      (cWork)->(DBSKIP(-1))
   ENDIF
ELSE
   (cWork)->(DBGOTO(nReg1))
ENDIF

RETURN .T.

*----------------------------*
Function QC210Relacao(cQual)
*----------------------------*
LOCAL cRet

DO CASE
   CASE cQual = 1

        SY1->(DBSETORDER(1))
        SY1->(DBSEEK(xFilial()+M->WR_COMPRA))
        cRet:= SY1->Y1_NOME

   CASE cQual = 2

        SYT->(DBSETORDER(1))
        SYT->(DBSEEK(xFilial()+M->WR_IMPOR))
        cRet:= SYT->YT_NOME_RE

   CASE cQual = 3

        SYT->(DBSETORDER(1))
        SYQ->(DBSEEK(xFilial()+M->WR_VIA))
        cRet:= SYQ->YQ_DESCR

ENDCASE

RETURN cRet

*----------------------------*
Function QC210EndValid(aValid)
*----------------------------*
Local I
IF !Obrigatorio(aGets,aTela)
   RETURN .F.
ENDIF
FOR I := 1 TO LEN(aValid)
   IF !QC210Val(aValid[I],.T.)
     RETURN .F.
   ENDIF
NEXT
RETURN .T.

*----------------------------*
Function QCConfDel(nOpc,lItem)
*----------------------------*
IF (lWork1 .OR. lItem) .AND. nOpc = EXCLUSAO
   IF MSGYESNO(STR0050,STR0051) = .T. //'Confirma Exclusão ? '###'Excluir'
      RETURN .T.
   ENDIF
   RETURN .F.
ENDIF

RETURN .T.

*----------------------------*
Function QC210Del1Work(lExclui)
*----------------------------*
IF lExclui

   IF lWork1

      IF Work1->WS_RECNO # 0
         AADD(aDeletWS,Work1->WS_RECNO)
      ENDIF

      Work2->(DBSEEK(Work1->WS_COD_I))
      DO WHILE Work2->WT_COD_I == Work1->WS_COD_I
         QC210Del2Work("Work2")
         Work2->(DBSKIP())
      ENDDO

      Work1->(DBDELETE())

   ELSE
      lAlterou:=.T.
      QC210Del2Work("Work3")
   ENDIF
ENDIF
lRefresh:=.t.

//oObj:oBrowse:Refresh()
RETURN .T.
*----------------------------*
Function QC210Del2Work(cWork)
*----------------------------*
IF (cWork)->WT_RECNO # 0
   IF ASCAN(aDeletWT,(cWork)->WT_RECNO)=0
      AADD(aDeletWT,(cWork)->WT_RECNO)
   ENDIF
ENDIF
(cWork)->(DBDELETE())

RETURN .T.

*----------------------------*
Function QC210For(nOpc)
*----------------------------*
LOCAL I, nFconut:=Work3->(FCount())

IF nOpc = INCLUSAO
   Work3->(DBAPPEND())
ELSE
   Work3->(DBGOTO(nReg1))
ENDIF
FOR I := 1 TO nFconut
    Work3->(FieldPut(I,M->&(FIELDNAME(I)) ))
NEXT
Work3->WT_NR_CONC := M->WR_NR_CONC //AAF 13/01/2017 - Garantir que esteja sempre preenchido.
Work3->TRB_ALI_WT:= "SWT"
Work3->TRB_REC_WT:= SWT->(Recno())
IF SY6->(DBSEEK(xFilial()+Work3->WT_COD_PAG+STR(Work3->WT_DIASPAG,3)))
   Work3->WT_DES_PAG:=SY6->(MSMM(SY6->Y6_DESC_P,40,1))
ENDIF

IF nOpc = INCLUSAO
   Work3->WT_COD_I    := Work1->WS_COD_I

   Work3->WT_DESCRFO  := BuscaF_F(Work3->WT_FORN,,IF(EICLOJA(),Work3->WT_FORLOJ,""))


   If EICLOJA()
      IF(Work2->(DBSEEK(Work3->WT_FORN+Work3->WT_FORLOJ+Work3->WT_COD_I)),QC210Representante(),)
   Else
      IF(Work2->(DBSEEK(Work3->WT_FORN+Work3->WT_COD_I)),QC210Representante(),)
   Endif

   IF EICLOJA()
      Work3->WT_DESCRFA  := BuscaFabr_For(Work3->WT_FABR+Work3->WT_FABLOJ)
   ELSE
      Work3->WT_DESCRFA  := BuscaFabr_For(Work3->WT_FABR)
   ENDIF

   If EasyGParam("MV_EIC0052",,.T.) .And. SWT->(FieldPos("WT_DTNECES")) # 0
        Work3->WT_DTNECES := Work1->WS_DTNECES
   EndIf

   IF SA5->(DBSEEK(cFilSA5+Work3->WT_COD_I+Work3->WT_FORN+EicRetLoja("Work3","WT_FORLOJ")))
      Work3->WT_ULT_ENT := SA5->A5_ULT_ENT
      Work3->WT_ULT_FOB := SA5->A5_ULT_FOB
   ENDIF

ENDIF

// NOVO PONTO DE ENTRADA - LAM - 26/05/06
IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"INCLUI_FORN"),)

RETURN .T.

*--------------------------------*
Function QC210Grv3Work(lAtuWork2)
*--------------------------------*
LOCAL nCont:=0

Work2->(DBSETORDER(1))
Work2->(DBSEEK(Work1->WS_COD_I))
Work2->(DBEVAL({||++nCont},,{||Work2->WT_COD_I == Work1->WS_COD_I}))

IF lAtuWork2 .AND. lAlterou

   ProcRegua(nCont*2)
   Work2->(DBSEEK(Work1->WS_COD_I))
  	// NOVO PONTO DE ENTRADA - LAM - 26/05/06
   lSair := .F.
   IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"ACERTA_WORK"),)
   IF !lSair //LAM - 26/05/06
  	 Work2->(DBEVAL({||IncProc(STR0052),; //"Processando Registros"
         Work2->(DBDELETE())},;
         {||.T.},{||Work2->WT_COD_I == Work1->WS_COD_I}))

     Work3->(DBEVAL({||IncProc(STR0052),; //"Processando Registros"
         Work2->(DBAPPEND()),;
         QC210Append("Work2","Work3")}))
         Work2->TRB_ALI_WT:= "SWT"
         Work2->TRB_REC_WT:= SWT->(Recno())
   ENDIF

ELSEIF !lAtuWork2
   ProcRegua(nCont)
   Work2->(DBSEEK(Work1->WS_COD_I))
	// NOVO PONTO DE ENTRADA - LAM - 26/05/06
   lSair := .F.
   IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"CARREGA_WORK3"),)
   IF !lSair //LAM - 26/05/06
	   Work2->(DBEVAL({||IncProc(STR0052),; //"Processando Registros"
       Work3->(DBAPPEND()),;
       QC210Append("Work3","Work2"),;
       Work2->TRB_ALI_WT:= "SWT",;
       Work2->TRB_REC_WT:= SWT->(Recno())},;
       {||.T.},{||Work2->WT_COD_I == Work1->WS_COD_I}))
 	ENDIF

ENDIF

RETURN .T.

*-------------------------------------*
Function QC210Append(cAlias1,cAlias2)
*-------------------------------------*
LOCAL aConta:=(cAlias1)->(FCOUNT()), I

FOR I := 1 TO aConta

   (cAlias1)->(FieldPut(I,(cAlias2)->(FIELDGET(I))))

NEXT

RETURN .T.
*--------------------------------*
Function QC210Grava(cAlias,nOpc)
*--------------------------------*
LOCAL I,Ind
Local nRecno // RA - 06/11/2003 - O.S. 1061/03

dbSelectArea(cAlias)

ProcRegua((LEN(aDeletWS)+LEN(aDeletWT)+Work1->(Easyreccount("Work1"))+Work2->(Easyreccount("Work2"))))

// RA - 06/11/2003 - O.S. 1061/03 - Inicio
If Inclui .And. GetNewPar("MV_NRCO",.F.)
   M->WR_NR_CONC := GetSxeNum("SWR","WR_NR_CONC")
   ConfirmSX8()
   If(EasyEntryPoint("EICQC210"),ExecBlock("EICQC210",.F.,.F.,"CTRL_CO"),)
   nRecno := SWR->( Recno() )
   If DbSeek(cFilSWR+M->WR_NR_CONC)
      SWR->( DbGoto(nRecno) )
      Return .F.
   EndIf
   SWR->( DbGoto(nRecno) )
EndIf
// RA - 06/11/2003 - O.S. 1061/03 - Final

E_Grava(cAlias,IF(nOpc=INCLUSAO,.T.,.F.))//Grava SWR

FOR I=1 to LEN(aDeletWS)
    IncProc(STR0053) //"Atualizando Itens da Concorrencia"
    SWS->(DBGOTO(aDeletWS[I]))
    RecLock("SWS",.F.)
    SWS->(DBDELETE())
    SWS->(MSUNLOCK())
NEXT

FOR I=1 to LEN(aDeletWT)
    IncProc(STR0054) //"Atualizando Fornecedores dos Itens"
    SWT->(DBGOTO(aDeletWT[I]))
    RecLock("SWT",.F.)
    SWT->(DBDELETE())
    SWT->(MSUNLOCK())
NEXT

Work1->(DBGOTOP())

WHILE ! Work1->(EOF())

    IncProc(STR0055) //"Gravando Itens da Concorrencia"
    IF nOpc=ALTERACAO .AND. Work1->WS_RECNO # 0
       SWS->(DBGOTO(Work1->WS_RECNO))
       RecLock("SWS",.F.)
    ELSE
       RecLock("SWS",.T.)
    ENDIF

    nFCont:=SWS->(FCount())

    FOR Ind := 1 TO nFCont
        IF "FILIAL" $ SWS->(Field(Ind))
           SWS->(FieldPut(Ind,xFilial()))
        ELSEIF "NR_CONC" $ SWS->(Field(Ind))
           SWS->(FieldPut(Ind,SWR->WR_NR_CONC))
        ELSE
           cCampo:=SWS->(FieldName(Ind))//Atencao work1 nao tem as mesmas posicoes de campos que o sws
           SWS->( FieldPut( Ind,Work1->( FIELDGET(FIELDPOS(cCampo)) ) ) )
        ENDIF
    NEXT

    SWS->(MSUNLOCK())

    Work1->(DBSKIP())

ENDDO

Work2->(DBGOTOP())

WHILE ! Work2->(EOF())

	// NOVO PONTO DE ENTRADA - LAM - 26/05/06
	lSair := .F.
	IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"TESTA_ALT"),)
	If lSair
  		Work2->(DBSKIP()) ; LOOP
	EndIf

    IncProc(STR0056) //"Gravando Fornecedores dos Itens"
    IF nOpc=ALTERACAO .AND. Work2->WT_RECNO # 0
       SWT->(DBGOTO(Work2->WT_RECNO))
       RecLock("SWT",.F.)
    ELSE
       RecLock("SWT",.T.)
    ENDIF
    //** - BHF - 19/11/08 - Gravação generalizada.
    /*
    nFCont:=SWT->(FCount())

    FOR Ind := 1 TO nFCont
        IF "FILIAL" $ SWT->(Field(Ind))
           SWT->(FieldPut(Ind,xFilial()))
        ELSEIF "NR_CONC" $ SWT->(Field(Ind))
           SWT->(FieldPut(Ind,SWR->WR_NR_CONC))
        ELSE
           cCampo:=SWT->(FieldName(Ind))//Atencao work2 nao tem as mesmas posicoes de campos que o SWT
           SWT->( FieldPut( Ind,Work2->( FIELDGET(FIELDPOS(cCampo)) ) ) )
        ENDIF
    NEXT
    */
    SWT->WT_FILIAL  := xFilial("SWT")
    If SWT->(FieldPos("WT_NR_CONC")) > 0
       SWT->WT_NR_CONC := SWR->WR_NR_CONC
    EndIf
    AvReplace("Work2","SWT")
    //** - BHF
    SWT->(MSUNLOCK())

    Work2->(DBSKIP())

ENDDO

(cAlias)->(MsUnlock())

// RA - 06/11/2003 - O.S. 1061/03 - Inicio
If Inclui .And. GetNewPar("MV_NRCO",.F.)
   MsgInfo(STR0140+M->WR_NR_CONC,STR0059) //"Numero da Concorrencia: "###"Atencao"
EndIf
// RA - 06/11/2003 - O.S. 1061/03 - Final

IF(EasyEntryPoint("EICQC210"),ExecBlock("EICQC210",.F.,.F.,"GRAVA_OK"),)

RETURN .T.

*-----------------------------*
Function QC210Itens(nOpc)
*-----------------------------*
LOCAL cCCusto:=M->WS__CC, cSi:=M->WS_SI_NUM,;
      nCont:=0, nTemSaldo:=.F.

SW1->(DBEVAL({||++nCont},,{||SW1->W1_CC == cCCusto .AND. SW1->W1_SI_NUM == cSi .AND. cFilSW1 = SW1->W1_FILIAL}))

SW1->(DBSEEK(cFilSW1+cCCusto+cSi))

ProcRegua(nCont)

DO WHILE !SW1->(EOF()) .AND. SW1->W1_CC == cCCusto .AND. SW1->W1_SI_NUM == cSi .AND. cFilSW1 = SW1->W1_FILIAL

   IncProc(STR0057+SW1->W1_CC+' '+SW1->W1_SI_NUM) //"Gravando S.I. No "

   IF SW1->W1_SEQ <> 0    ; SW1->(DBSKIP()) ; LOOP ; ENDIF
   IF SW1->W1_SALDO_Q = 0 ; SW1->(DBSKIP()) ; LOOP ; ENDIF

   nTemSaldo:=QC210Links(cCCusto,cSi,SW1->W1_COD_I,SW1->W1_DTENTR_,SW1->W1_SALDO_Q,SW1->W1_FABR,nOpc,SW1->W1_FORN, "SW1",SW0->W0_MOEDA) // GFP - 04/07/2013

   SW1->(DBSKIP())

ENDDO

IF !nTemSaldo
   Help("", 1, "AVG0000479")//"NÆo h  saldos para esta S.I."###"Atenção"
   RETURN .F.
ENDIF

RETURN .T.

*--------------------------------------------------------------------------------------------*
Function QC210Links(cCCusto,cSi,cCod_Item,dDTnecess,nQtde,cFabr,nOpc,cFornec, cAlias, cMoeda)     // GFP - 04/07/2013
*--------------------------------------------------------------------------------------------*
Local cSeek := "" //MCF - 29/12/2014
Private c_CCusto   := cCCusto
Private c_Si       := cSi
Private c_Cod_Item := cCod_Item
Private d_DTnecess := dDTnecess
Private n_Qtde     := nQtde
Private c_Fabr     := cFabr
Private n_Opc      := nOpc
Private c_Fornec   := cFornec
Default cAlias := ""
SA5->(DBSETORDER(2))
SB1->(DBSETORDER(1))
SB1->(DBSEEK(cFilSB1+cCod_Item))

IF EasyGParam("MV_EIC0052",,.T.) //MCF - 29/12/2014
	cSeek := ALLTRIM(cCod_Item)
Else
	cSeek := ALLTRIM(cCod_Item+DTOS(dDTnecess))
Endif

IF (nOpc = INCLUSAO .AND. EMPTY(cCCusto)) .OR. !Work1->(DBSEEK(cSeek))  //MCF - 29/12/2014

   IF !EMPTY(cCCusto)
      Work1->(DBAPPEND())
      Work1->WS__CC     := cCCusto
      Work1->WS_SI_NUM  := cSi
      Work1->WS_COD_I   := cCod_Item
      Work1->WS_QTDE    := nQtde
      Work1->WS_DTNECES := dDTnecess
      // RA - 18/11/2003 - O.S. 1244/03 - INICIO
      Work1->WS_PESO    := B1PESO(Work1->WS__CC, Work1->WS_SI_NUM, Work1->WS_COD_I, 1) * nQtde // Utiliza sempre o 1o registro do produto da SI
      Work1->TRB_ALI_WT:= "SWS"
	  Work1->TRB_REC_WT:= SWS->(Recno())
      //TRP-15/05/07
      aOrd := SaveOrd("SX3",1)
      If SX3->(dbSeek("SWS")) .And. cAlias == "SW1"
         While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SWS"
            If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO)
               cCampo := StrTran(SX3->X3_CAMPO, "WS", "W1")
               If SW1->(FieldPos(cCampo)) > 0
                  Eval(FieldWBlock(SX3->X3_CAMPO, Select("Work1")),  Eval(FieldWBlock(cCampo, Select("SW1"))))
               EndIf
            EndIF
            SX3->(dbSkip())
         Enddo
      EndIf
      RestOrd(aOrd)
	  // NOVO PONTO DE ENTRADA - LAM - 26/05/06
	  IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"GRAVA_1REG"),)
      If GetNewPar("MV_UNIDCOM",2) == 2 .And. Work1->WS_PESO <> (SB1->B1_PESO * nQtde)
         Work1->WS_UNI  := SB1->B1_SEGUM
      Else
         Work1->WS_UNI  := SB1->B1_UM
      EndIf
   ELSE
      //TRP-15/05/07
      aOrd := SaveOrd("SX3",1)
      If SX3->(dbSeek("SWS")) .And. cAlias == "SW1"
         While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SWS"
            If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO)
               If Work1->(FieldPos(SX3->X3_CAMPO)) > 0 .And. M->(Type(SX3->X3_CAMPO)) == SX3->X3_TIPO
                  Eval(FieldWBlock(SX3->X3_CAMPO, Select("Work1")), Eval(MemVarBlock(SX3->X3_CAMPO)))
               EndIf
            EndIF
            SX3->(dbSkip())
         Enddo
      EndIf
      RestOrd(aOrd)
		// NOVO PONTO DE ENTRADA - LAM - 26/05/06
	  lSair := .F.
      IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"MAIS_3COND"),)
      IF !lSair
      	Work1->WS_PESO := SB1->B1_PESO * nQtde
      	Work1->WS_UNI  := SB1->B1_UM
      ENDIF
      // RA - 18/11/2003 - O.S. 1244/03 - FINAL
   ENDIF
   Work1->WS_DESCR   := MSMM(SB1->B1_DESC_I,40,1)


   IF SA5->(DBSEEK(cFilSA5+cCod_item))

      DO WHILE ! SA5->(EOF()) .AND. SA5->A5_PRODUTO == cCod_item  .AND. cFilSA5 = SA5->A5_FILIAL

         IF !EMPTY(cFabr) .AND. SA5->A5_FABR # cFabr
            SA5->(DBSKIP())
            LOOP
         ENDIF

         IF !EMPTY(cFornec) .AND. SA5->A5_FORNECE # cFornec
            SA5->(DBSKIP())
            LOOP
         ENDIF

         Work2->(DBSETORDER(2))
         If EasyGParam("MV_EIC0052",,.T.) .OR. SWT->(FieldPos("WT_DTNECES")) == 0
            lAchou := Work2->(DBSEEK(SA5->A5_FORNECE+EICRetLoja("SA5","A5_LOJA")+cCod_item))
         Else
            lAchou := Work2->(DBSEEK(SA5->A5_FORNECE+EICRetLoja("SA5","A5_LOJA")+cCod_item+DTOS(dDTnecess)))
         EndIf

            IF !lAchou
               Work2->(DBAPPEND())
                Work2->WT_NR_CONC := M->WR_NR_CONC //LRS
                Work2->WT_COD_I   := cCod_item
                Work2->WT_FORN    := SA5->A5_FORNECE
                Work2->WT_DESCRFO := BuscaF_F(SA5->A5_FORNECE,,IF(EICLOJA(),SA5->A5_LOJA,"")); QC210Representante()
                Work2->WT_FABR    := SA5->A5_FABR
                Work2->WT_DESCRFA := BuscaF_F(SA5->A5_FABR,,IF(EICLOJA(),SA5->A5_LOJA,""))
                Work2->WT_ULT_FOB := SA5->A5_ULT_FOB
                Work2->WT_ULT_ENT := SA5->A5_ULT_ENT
                If SWT->(FieldPos("WT_DTNECES")) # 0
                   Work2->WT_DTNECES := dDTnecess
                EndIf
                Work2->TRB_ALI_WT:= "SWT"
                Work2->TRB_REC_WT:= SWT->(Recno())
                If EICLoja()
                   Work2->WT_FORLOJ  := SA5->A5_LOJA
                   Work2->WT_FABLOJ  := SA5->A5_LOJA
                EndIF
                Work2->WT_MOEDA  := cMoeda  // GFP - 04/07/2013
            ENDIF



  			// NOVO PONTO DE ENTRADA - LAM - 26/05/06
			IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"GRAVA_2REG"),)

         SA5->(DBSKIP())

      ENDDO

   ENDIF

ELSE

   IF !EasyGParam("MV_EIC0052",,.T.) //MCF - 29/12/2014
      cSeek := ALLTRIM(cCod_Item+DTOS(dDTnecess))
   Endif

   lSair := .F.
   IF(EasyEntryPoint("EICQC210"),ExecBlock("EICQC210",.F.,.F.,"LINKS_ACM_PROD"),) //OMJ 29/12/05
   // Ponto de Entrada para nao Acumular no mesmo produto. Lançar uma linha diferente.
   If lSair
      Work2->(DBSETORDER(1))
      RETURN .T.
   EndIf

   IF nOpc = INCLUSAO .AND. !EMPTY(cCCusto)
      IF Work1->WS__CC == cCCusto .AND. Work1->WS_SI_NUM == cSi
         Work1->WS_QTDE += nQtde
         Work1->WS_PESO := B1PESO(Work1->WS__CC, Work1->WS_SI_NUM, Work1->WS_COD_I, 1) * Work1->WS_QTDE // Utiliza sempre o 1o registro do produto da SI // RA - 18/11/2003  - O.S. 1244/03
      ELSE
         IF MSGYESNO(STR0060+ALLTRIM(cCod_item)+STR0061,STR0062) == .T. //"Acumular quantidade do Produto "###" que j  existe  ?"###"Quantidades "
            Work1->WS_QTDE += nQtde
            Work1->WS_PESO := B1PESO(Work1->WS__CC, Work1->WS_SI_NUM, Work1->WS_COD_I, 1) * Work1->WS_QTDE // Utiliza sempre o 1o registro do produto da SI // RA - 18/11/2003 - O.S. 1244/03
         ENDIF
      ENDIF
   ELSE

      // RA - 18/11/2003 - O.S. 1244/03 - INICIO
      If Empty(Work1->WS__CC)
         Work1->WS_PESO := SB1->B1_PESO * nQtde
      Else
         Work1->WS_PESO := B1PESO(Work1->WS__CC, Work1->WS_SI_NUM, Work1->WS_COD_I, 1) * nQtde // Utiliza sempre o 1o registro do produto da SI // RA - 18/11/2003 - O.S. 1244/03
      Endif
      // RA - 18/11/2003 - O.S. 1244/03 - FINAL

   ENDIF

ENDIF

Work2->(DBSETORDER(1))

RETURN .T.

*-----------------------*
FUNCTION QC210GrvWorks()
*-----------------------*
LOCAL nCont:=0, aWork:= {},I //LRS 10/03/2015

SB1->(DBSETORDER(1))

SWS->(DBSEEK(cFilSWS+SWR->WR_NR_CONC))
SWS->(DBEVAL({||++nCont},,{||SWS->WS_NR_CONC == SWR->WR_NR_CONC .AND. SWS->WS_FILIAL == cFilSWS}))

SWT->(DBSEEK(cFilSWT+SWR->WR_NR_CONC))
SWT->(DBEVAL({||++nCont},,{||SWT->WT_NR_CONC == SWR->WR_NR_CONC .AND. SWT->WT_FILIAL == cFilSWT}))

ProcRegua(nCont)

SWS->(DBSEEK(cFilSWS+SWR->WR_NR_CONC))

DO WHILE SWS->(!EOF()) .AND. SWS->WS_NR_CONC == SWR->WR_NR_CONC .AND. SWS->WS_FILIAL == cFilSWS

   IncProc(STR0063+SWS->WS_COD_I) //"Processando Item "
   SB1->(DBSEEK(cFilSB1+SWS->WS_COD_I))

   Work1->(DBAPPEND())
   Work1->WS__CC     := SWS->WS__CC
   Work1->WS_SI_NUM  := SWS->WS_SI_NUM
   Work1->WS_COD_I   := SWS->WS_COD_I
   Work1->WS_DESCR   := MSMM(SB1->B1_DESC_I,40,1)
   Work1->WS_QTDE    := SWS->WS_QTDE
   Work1->WS_DTNECES := SWS->WS_DTNECES
   Work1->TRB_ALI_WT := "SWS"
   Work1->TRB_REC_WT := SWS->(Recno())
   // RA - 18/11/2003 - O.S. 1244/03 - INICIO
   If Empty(Work1->WS__CC)
      Work1->WS_PESO := SB1->B1_PESO * SWS->WS_QTDE
   Else
      Work1->WS_PESO := B1PESO(Work1->WS__CC, Work1->WS_SI_NUM, Work1->WS_COD_I, 1) * SWS->WS_QTDE // Utiliza sempre o 1o registro do produto da SI // RA - 18/11/2003 - O.S. 1244/03
   Endif
   If GetNewPar("MV_UNIDCOM",2) == 2 .And. !Empty(Work1->WS__CC) .And. Work1->WS_PESO <> (SB1->B1_PESO * SWS->WS_QTDE)
      Work1->WS_UNI  := SB1->B1_SEGUM
   Else
      Work1->WS_UNI  := SB1->B1_UM
   EndIf
   // RA - 18/11/2003 - O.S. 1244/03 - FINAL
   Work1->WS_RECNO   := SWS->(RECNO())

   //TRP-14/05/07- Gravação na work1 dos campos incluidos pelo configurador e que forem usados.
   aOrd := SaveOrd("SX3",1)
   SX3->(dbSeek("SWS"))
   While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SWS"
      If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO)
         Eval(FieldWBlock(SX3->X3_CAMPO, Select("Work1")),  Eval(FieldWBlock(SX3->X3_CAMPO, Select("SWS"))))
      EndIF
      SX3->(dbSkip())
   Enddo
   RestOrd(aOrd)
   // NOVO PONTO DE ENTRADA - LAM - 26/05/06
   IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"CARREGA_WORK1"),)

   SWS->(DBSKIP())

ENDDO

SWT->(DBSEEK(cFilSWT+SWR->WR_NR_CONC))
SA5->(DBSETORDER(2))
DO WHILE SWT->(!EOF()) .AND. SWT->WT_NR_CONC == SWR->WR_NR_CONC .AND. SWT->WT_FILIAL == cFilSWT

   IncProc(STR0064+SWT->WT_FORN) //"Processando Fornecedor "
   SY6->(DBSEEK(xFilial()+SWT->WT_COD_PAG+STR(SWT->WT_DIASPAG,3)))
   SYR->(DBSEEK(xFilial()+SWR->WR_VIA+SWT->WT_ORIGEM+SWR->WR_DESTINO))
   SA5->(DBSEEK(cFilSA5+SWT->WT_COD_I+SWT->WT_FORN+EicRetLoja("SWT","WT_FORLOJ")))
   Work1->(DBSEEK(SWT->WT_COD_I))

   Work2->(DBAPPEND())
   Work2->WT_COD_I    := SWT->WT_COD_I
   Work2->WT_ORIGEM   := SWT->WT_ORIGEM
   Work2->WT_FORN     := SWT->WT_FORN
   IF EICLOJA()
      Work2->WT_FORLOJ   := SWT->WT_FORLOJ
   Endif
   IF EICLOJA()
      Work2->WT_DESCRFO  := BuscaF_F(SWT->WT_FORN,,SWT->WT_FORLOJ); QC210Representante()
   Else
      Work2->WT_DESCRFO  := BuscaF_F(SWT->WT_FORN,,""); QC210Representante()
   Endif

   Work2->WT_FABR     := SWT->WT_FABR

   IF EICLOJA()
      Work2->WT_FABLOJ := SWT->WT_FABLOJ
   ENDIF

   IF EICLOJA()
      Work2->WT_DESCRFA  := BuscaF_F(SWT->WT_FABR,,SWT->WT_FABLOJ); QC210Representante()
   Else
      Work2->WT_DESCRFA  := BuscaF_F(SWT->WT_FABR,,""); QC210Representante()
   Endif

   If SWT->(FieldPos("WT_DTNECES")) # 0
      Work2->WT_DTNECES := SWT->WT_DTNECES
   EndIf
   Work2->WT_DESCRFA  := BuscaF_F(SWT->WT_FABR,,IF(EICLOJA(),SWT->WT_FORLOJ,""))
   Work2->WT_MOEDA    := SWT->WT_MOEDA
   Work2->WT_FOB_UNI  := SWT->WT_FOB_UNI
   Work2->WT_FRE_KG   := SWT->WT_FRE_KG
   Work2->WT_SEGURO   := SWT->WT_SEGURO
   Work2->WT_DT_FORN  := SWT->WT_DT_FORN
   Work2->WT_COD_PAG  := SWT->WT_COD_PAG
   Work2->WT_DIASPAG  := SWT->WT_DIASPAG
   Work2->WT_RECNO    := SWT->(RECNO())
   Work2->WT_DES_PAG  := SY6->(MSMM(SY6->Y6_DESC_P,40,1))
   Work2->WT_MOE_FRE  := SYR->YR_MOEDA
   Work2->WT_ULT_ENT  := SA5->A5_ULT_ENT
   Work2->WT_ULT_FOB  := SA5->A5_ULT_FOB
   Work2->WT_FOB_TOT  := Work2->WT_FOB_UNI * Work1->WS_QTDE

   Work2->WT_NR_CONC  := SWT->WT_NR_CONC //AAF 13/01/2017 - Garantir que esteja sempre preenchido.

   Work2->TRB_ALI_WT  := "SWT"
   Work2->TRB_REC_WT  := SWT->(Recno())

   aWork := AddCpoUser(aWork,"SWT","1") //LRS - 18/04/2017 //LRS 10/03/2015 - Adicionando dados na Work2 que replica para Work3

   For i := 1 to Len(aWork)
      &("Work2->"+aWork[I]) := &("SWT->"+aWork[I])
   Next

   //** PLB 20/09/07
   If lIncoterm
      Work2->WT_INCOTER := SWT->WT_INCOTER
      Work2->WT_VL_UNIT := SWT->WT_VL_UNIT
   EndIf
   //**
   // NOVO PONTO DE ENTRADA - LAM - 26/05/06
   IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"CARREGA_WORK2"),)

   SWT->(DBSKIP())

ENDDO


RETURN .T.

*---------------------*
Function QC210Exclui()
*---------------------*
LOCAL nCont:=0

SWS->(DBSEEK(cFilSWS+SWR->WR_NR_CONC))
SWS->(DBEVAL({||++nCont},,{||SWS->WS_NR_CONC == SWR->WR_NR_CONC .AND. SWS->WS_FILIAL == cFilSWS}))

SWT->(DBSEEK(cFilSWT+SWR->WR_NR_CONC))
SWT->(DBEVAL({||++nCont},,{||SWT->WT_NR_CONC == SWR->WR_NR_CONC .AND. SWT->WT_FILIAL == cFilSWT}))

ProcRegua(nCont)
nPos:=SWS->(FIELDPOS("WS_COD_I"))
SWS->(DBSEEK(cFilSWS+SWR->WR_NR_CONC))
SWS->(DBEVAL({||QC210Deleta("SWS")},,{||SWS->WS_NR_CONC == SWR->WR_NR_CONC .AND. SWS->WS_FILIAL == cFilSWS}))

nPos:=SWT->(FIELDPOS("WT_COD_I"))
SWT->(DBSEEK(cFilSWT+SWR->WR_NR_CONC))
SWT->(DBEVAL({||QC210Deleta("SWT")},,{||SWT->WT_NR_CONC == SWR->WR_NR_CONC .AND. SWT->WT_FILIAL == cFilSWT}))

nPos:=SWR->(FIELDPOS("WR_NR_CONC"))
QC210Deleta("SWR")

RETURN .T.

*----------------------------*
Function QC210Deleta(cAlias)
*----------------------------*
IncProc(STR0065+(cAlias)->(FIELDGET(nPos))) //"Excluindo Item "
(cAlias)->(RecLock(cAlias,.F.,.T.))
(cAlias)->(DBDELETE())
(cAlias)->(MsUnlock())
RETURN .T.

*------------------------------*
Function QC210Val(MFlag,lEnd)
*------------------------------*
LOCAL nRecno, lExiste, lProcessa, uDado, cAlias:=Alias(), lGravou:=.F., cCond
Local nValFrete := 0

IF(lEnd=NIL,lEnd:=.F.,)

DO CASE
   CASE MFlag == '1'

        IF !EMPTY(M->WS__CC) .AND. !ExistCpo("SY3",M->WS__CC)
           RETURN .F.
        ENDIF

   CASE MFlag == '2'

        IF !EMPTY(M->WS__CC) .AND. EMPTY(M->WS_SI_NUM)
           Help("", 1, "AVG0000480")//'N£mero da S.I. nÆo preenchido '###"Atenção"
           RETURN .F.
        ELSEIF ! EMPTY(M->WS_SI_NUM) .AND. EMPTY(M->WS__CC)
           Help("", 1, "AVG0000481")//"Unidade Requisitante não preenchida"###"Atenção"
           RETURN .F.
        ENDIF

        IF EMPTY(M->WS_SI_NUM); RETURN .T.; ENDIF

        SW1->(dbSetOrder(1))
        IF !SW1->(DBSEEK(cFilSW1+M->WS__CC+M->WS_SI_NUM))
           Help("", 1, "AVG0000482")//"S.I. não cadastrada para essa Unidade Requisitante"###"Informação"
           RETURN .F.
        ENDIF

        IF lInclusao
           nRecno   := Work1->(RECNO())
           lProcessa:= .T.
           lExiste  := .F.
           Work1->(DBGOTOP())
           Processa({||Work1->(DBEVAL({||IF(lProcessa,ProcRegua(Work1->(Easyreccount("Work1"))),),;
                                       IncProc(STR0070) ,; //"Processando Arquivo Temporário..."
                                       lProcessa:=.F. ,;
                                       IF(M->WS__CC==Work1->WS__CC.AND.;
                                          Work1->WS_SI_NUM==M->WS_SI_NUM,lExiste:=.T.,)}))})
           Work1->(DBGOTO(nRecno))
           IF lExiste
              Help("", 1, "AVG0000483")//'Solicita‡Æo j  cadastrada para esta Cota‡Æo'###"Atenção"
              RETURN .F.
           ELSE
              If !lEnd
                 If lMostrou = .F.
                 		MSGINFO(STR0154)  // "Esta solicitacao ainda não foi lançada nesta cotação e pode ser cotada! Confirme a inclusao do item." // igor chiba 07/05/2009
                     lMostrou := .T.
                 EndIF
              EndIf
           ENDIF
        ENDIF


   CASE MFlag == '3'

        IF !QC210VAL("6")
           RETURN .T.
        ENDIF

        IF EMPTY(M->WS_COD_I)
           Help("", 1, "AVG0000484")//'C¢digo do Produto nÆo preenchido'###"Atenção"
           RETURN .F.
        ENDIF

        IF ! SB1->(DBSEEK(cFilSB1+M->WS_COD_I))
           Help("", 1, "AVG0000485")//'Produto não encontrado no cadastro'###"Informação"
           RETURN .F.
        ENDIF

        nRecno:=Work1->(RECNO())
        IF lInclusao .AND. Work1->(DBSEEK(M->WS_COD_I))
           Help("", 1, "AVG0000486")//'Produto j  cadastrado para esta Cota‡Æo'###"Informação"
           Work1->(DBGOTO(nRecno))
           RETURN .F.
        ENDIF
        Work1->(DBGOTO(nRecno))
        M->WS_DESCR:= MSMM(SB1->B1_DESC_I,40,1)



   CASE MFlag == '4'

        IF EMPTY(M->WS_QTDE) .AND. !lInclusao
           Help("", 1, "AVG0000487")//'Quantidade não Preenchida'###"Atenção"
           RETURN .F.
        ENDIF

   CASE MFlag == '5'

        IF !QC210VAL("6")
           RETURN .T.
        ENDIF

        IF EMPTY(M->WS_DTNECES)
           Help("", 1, "AVG0000488")//'Data da Necessidade nção preenchida'###"Atenção"
           RETURN .F.
        ENDIF

        IF M->WS_DTNECES < dDataBase
           Help("", 1, "AVG0000489")//'Data da Necessidade menor que a data de Hoje'###"Atenção"
           RETURN .F.
        ENDIF

   CASE MFlag == '6'

        IF (!EMPTY(M->WS__CC) .OR. !EMPTY(M->WS_SI_NUM)) .AND. lInclusao
           RETURN .F.
        ENDIF

   CASE MFlag == '7'

        IF ! ExistCpo('SYQ',M->WR_VIA)
           RETURN .F.
        ENDIF
        SYR->(DBSEEK(xFilial()+M->WR_VIA))
        IF !lEnd
           M->WR_DESTINO:=SYR->YR_DESTINO
        ENDIF
        M->WR_VIADESC:=SYQ->YQ_DESCR
        lRefresh:=.T.

   CASE MFlag == '8'

        SYR->(DBSETORDER(2))
        IF ! ExistCpo('SYR',M->WR_VIA+M->WR_DESTINO)
           SYR->(DBSETORDER(1))
           RETURN .F.
        ENDIF
        SYR->(DBSETORDER(1))

   CASE MFlag == '9'

        IF EMPTY(M->WT_FORN)
           Help("", 1, "AVG0000490")//MsgInfo(STR0078,STR0059) //'Fornecedor não preenchido'###"Atenção"
           RETURN .F.
        ENDIF

        IF ! SA2->(DBSEEK(xFilial()+M->WT_FORN/*+EicRetLoja("M","WT_FORLOJ")*/))
           Help("", 1, "AVG0000491")//"Fornecedor não cadastrado"###"Informação"
           RETURN .F.
        ELSEIF Left(SA2->A2_ID_FBFN,1) == '1'
           Help("", 1, "AVG0000492")//'C¢digo nÆo se refere a Fornecedor'###"Informação"
           RETURN .F.
        ELSE
           IF Work3->(DBSEEK(M->WT_FORN+EicRetLoja("M","WT_FORLOJ"))) .AND. lInclusao
              Help("", 1, "AVG0000493")//'Fornecedor j  cadastrado p/ a Cota‡Æo deste Produto'###"Informação"
              RETURN .F.
           ENDIF
           If EICLoja()
              If !Empty(EicRetLoja("M","WT_FORLOJ")) .And. SA2->(DBSEEK(xFilial()+M->WT_FORN+EicRetLoja("M","WT_FORLOJ")))
                 M->WT_FORNOME:=SA2->A2_NREDUZ
              EndIf
           Else
              M->WT_FORNOME:=SA2->A2_NREDUZ
           EndIF
        ENDIF
        SA5->(DBSETORDER(2))
        //IF !lEnd .AND. SA5->(DBSEEK(cFilSA5+Work3->WT_COD_I+M->WT_FORN))
        IF !lEnd .AND. SA5->(DBSEEK(cFilSA5+Work3->WT_COD_I+M->WT_FORN+EicRetLoja("M","WT_FORLOJ")))
           M->WT_FABR:=SA5->A5_FABR
           IF EICLOJA()
              M->WT_FABLOJ := SA5->A5_LOJA
           ENDIF
        ENDIF

        If EICLoja() .And. !Empty(M->WT_FORLOJ) .And. !ExistCpo("SA2", M->(WT_FORN+WT_FORLOJ))
           Return .F.
        EndIf


   CASE MFlag == '10'

        IF EMPTY(M->WT_FABR)
           RETURN .T.
        ENDIF
        IF ! SA2->(DBSEEK(xFilial()+M->WT_FABR))
           Help("", 1, "AVG0000494")//"Fabricante não cadastrado"###"Informação"
           RETURN .F.
        ELSEIF Left(SA2->A2_ID_FBFN,1) == '2'
           Help("", 1, "AVG0000495")//'C¢digo nÆo se refere a Fabricante'###"Informação"
           RETURN .F.
        ENDIF
        If EICLoja()
           If !Empty(EicRetLoja("M","WT_FORLOJ")) .And. SA2->(DBSEEK(xFilial()+M->WT_FABR+EicRetLoja("M","WT_FABLOJ")))
              M->WT_FABRNOM:=SA2->A2_NREDUZ
           EndIf
        Else
           M->WT_FABRNOM:=SA2->A2_NREDUZ
        EndIf

        If EICLoja() .And. !Empty(M->WT_FABLOJ) .And. !ExistCpo("SA2", M->(WT_FABR+WT_FABLOJ))
           Return .F.
        EndIf


   CASE MFlag == '11'

        IF EMPTY(M->WT_ORIGEM)
           Help("", 1, "AVG0000496")//'Origem não preenchida'###"Atenção"
           RETURN .F.
        ENDIF

        SYR->(DBSETORDER(1))
        IF ! SYR->(DBSEEK(xFilial()+M->WR_VIA+M->WT_ORIGEM+M->WR_DESTINO))
           Help("", 1, "AVG0000497")//'Origem não cadastrada para esta Via e Destino'###"Informação"
           RETURN .F.
        ENDIF
        IF !lEnd
           IF lInclusao .OR. M->WT_ORIGEM # Work3->WT_ORIGEM
              IF M->WR_TIP_FRE == 'CC'
                 M->WT_FRE_KG := TabFre(Work1->WS_PESO)
                 M->WT_MOE_FRE:= SYR->YR_MOEDA
              ENDIF
              M->WT_MOEDA := SYR->YR_MOEDA
              SA5->(DBSETORDER(3))
              //IF SA5->(DbSeek(xFilial()+Work3->WT_COD_I+M->WT_FABR+M->WT_FORN)) .AND.;
              If EICSFabFor(xFilial("SA5")+Work3->WT_COD_I+M->WT_FABR+M->WT_FORN, EICRetLoja("M", "WT_FABLOJ"), EICRetLoja("M", "WT_FORLOJ"))
                 M->WT_MOEDA := SA5->A5_MOE_US
                 M->WT_FOB_UNI := SA5->A5_VLCOTUS
                 //** PLB 20/09/07
                 If lIncoterm  .And.  M->WT_FOB_UNI > 0
                    M->WT_VL_UNIT := M->WT_FOB_UNI
                    QC210VAL('23')  // Validação do campo WT_VL_UNIT
                 EndIf
                 //**
              ENDIF
           ENDIF
           SA5->(DBSETORDER(2))
           lRefresh:=.T.

        ENDIF

   CASE MFlag == '12'

        IF EMPTY(M->WT_FOB_UNI) .AND. !lInclusao
           Help("", 1, "AVG0000498")//'FOB Unit rio nÆo preenchido'###"Atenção"
           RETURN .F.
        ENDIF
        IF !lEnd
           M->WT_SEGURO :=IF(!EMPTY(M->WR_PER_SEG), M->WT_FOB_UNI * (M->WR_PER_SEG/100) * Work1->WS_QTDE,0)
           M->WT_FOB_TOT:=M->WT_FOB_UNI * Work1->WS_QTDE
           lRefresh:=.T.

        ENDIF

   CASE MFlag == '13'

//      IF !EMPTY(M->WT_FRE_KG) .AND. M->WR_TIP_FRE == 'PP'
//         E_Msg(STR0087,1) //'Valor de Frete nÆo deve ser preenchido ( Pre-Paid )'
//         RETURN .F.
//      ENDIF
//      IF EMPTY(M->WT_FRE_KG) .AND.  lInclusao ; RETURN .T. ; ENDIF
//      IF EMPTY(M->WT_FRE_KG) .AND. !lInclusao .AND. M->WR_TIP_FRE== 'CC'
//         E_Msg(STR0088,1) ; RETURN .F. //'Frete nÆo preenchido'
//      ENDIF

      //** PLB 20/09/07
      If lIncoterm  .And.  !lEnd
         If !Empty(M->WT_INCOTER)  .And.  !Empty(M->WT_VL_UNIT)
            If QC210FreIn(M->WT_INCOTER)
               nValFrete := M->WT_FRE_KG / Work1->WS_QTDE
               If !Empty(M->WT_MOE_FRE)  .And.  !Empty(M->WT_MOEDA)  .And.  !( M->WT_MOE_FRE == M->WT_MOEDA )
                  nValFrete := nValFrete * BuscaTaxa(M->WT_MOE_FRE,dDataBase,,.F.) / BuscaTaxa(M->WT_MOEDA,dDataBase,,.F.)
               EndIf
               nValFrete := Round(nValFrete,5)
            Else
               nValFrete := 0
            EndIf
            M->WT_FOB_UNI := M->WT_VL_UNIT - nValFrete
            Return QC210VAL('12')  // Validação do campo WT_FOB_UNI (FOB Unitário)
         EndIf
      EndIf
      //**

   CASE MFlag == '14'

        IF EMPTY(M->WT_COD_PAG) .AND. !lInclusao
           Help("", 1, "AVG0000499")//'Condição de Pagamento não preenchida'###"Atenção"
           RETURN .F.
        ENDIF
        nRecno:=SY6->(RECNO()); cCond:=SY6->Y6_COD
        IF !EMPTY(M->WT_COD_PAG) .AND. !SY6->(DBSEEK(xFilial()+M->WT_COD_PAG))
           Help("", 1, "AVG0000500")//'Condição de Pagamento não Cadastrada'###"Informação"
           RETURN .F.
        ENDIF

        IF cCond = SY6->Y6_COD
           SY6->(DBGOTO(nRecno))
        ENDIF

        IF !lEnd
           M->WT_DIASPAG:=SY6->Y6_DIAS_PA
           lRefresh:=.T.

        ENDIF

   CASE MFlag == '15'

        IF EMPTY(M->WT_MOEDA) .AND.  lInclusao ; RETURN .T. ; ENDIF
        IF EMPTY(M->WT_MOEDA) .AND. !lInclusao
           Help("", 1, "AVG0000501")//'Moeda do Fob não preenchida'###"Atenção"
           RETURN .F.
        ENDIF
        SYE->(DBSETORDER(2))
        IF ! SYE->(DBSEEK(xFilial()+M->WT_MOEDA))
           SYE->(DBSETORDER(1))
           Help("", 1, "AVG0000502")//'Moeda do Fob sem taxa de conversão'###"Informação"
           RETURN .F.
        ENDIF
        SYE->(DBSETORDER(1))

        IF !lEnd
           IF lInclusao .OR. M->WT_MOEDA # Work3->WT_MOEDA
              SA5->(DBSETORDER(3))
              //IF SA5->(DbSeek(xFilial()+Work3->WT_COD_I+M->WT_FABR+M->WT_FORN)) .AND.;
              If EICSFabFor(xFilial("SA5")+Work3->WT_COD_I+M->WT_FABR+M->WT_FORN, EICRetLoja("M", "WT_FABLOJ"), EICRetLoja("M", "WT_FORLOJ")) .AND.;
                 M->WT_MOEDA == SA5->A5_MOE_US
                 M->WT_FOB_UNI := SA5->A5_VLCOTUS
                 //** PLB 20/09/07
                 If lIncoterm
                    M->WT_VL_UNIT := M->WT_FOB_UNI
                    QC210VAL('23')  // Validação do campo WT_VL_UNIT
                 EndIf
                 //**
              ENDIF
           ENDIF
           //** PLB 20/09/07
           If lIncoterm
              If !Empty(M->WT_INCOTER)  .And.  !Empty(M->WT_VL_UNIT)
                 If QC210FreIn(M->WT_INCOTER)
                    nValFrete := M->WT_FRE_KG / Work1->WS_QTDE
                    If !Empty(M->WT_MOE_FRE)  .And.  !( M->WT_MOE_FRE == M->WT_MOEDA )
                       nValFrete := nValFrete * BuscaTaxa(M->WT_MOE_FRE,dDataBase,,.F.) / BuscaTaxa(M->WT_MOEDA,dDataBase,,.F.)
                    EndIf
                    nValFrete := Round(nValFrete,5)
                 Else
                    nValFrete := 0
                 EndIf
                 M->WT_FOB_UNI := M->WT_VL_UNIT - nValFrete
                 Return QC210VAL('12')  // Validação do campo WT_FOB_UNI (FOB Unitário)
              EndIf
           EndIf
           //**
         ENDIF

   CASE MFlag == '16'

        IF EMPTY(cCodMen)
           Help("", 1, "AVG0000503")//'C¢digo nÆo preenchido'###"Atenção"
           RETURN .F.
        ENDIF
        SY7->(DBSETORDER(3))//No F3 Troca a ordem //Y7_FILIAL + Y7_POGI + Y7_COD
        IF !SY7->(DBSEEK(xFilial()+AvKey("2","Y7_POGI")+cCodMen))
           //Help("", 1, "AVG0000504")//'C¢digo nÆo cadastrado'###"Informação"
           EasyHelp(STR0155,STR0040,STR0156)//"Código de Mensagem não cadastrado ou Tipo de Mensagem inválida."###"Aviso"###"Verifique se o Código da Mensagem existe e se o Tipo de Mensagem é igual a 2 (Texto p/ Request for Quotation)"
           RETURN .F.
        ENDIF

   CASE MFlag == '17'

        IF EMPTY(cCodForn)
           Help("", 1, "AVG0000490")//'Fornecedor não preenchido'###"Atenção"
           RETURN .F.
        ENDIF

        IF !SA2->(DBSEEK(xFilial()+cCodForn))
           Help("", 1, "AVG0000491")//"Fornecedor não cadastrado"###"Informação"
           RETURN .F.
        ELSEIF Left(SA2->A2_ID_FBFN,1) == '1'
           Help("", 1, "AVG0000492")//'C¢digo nÆo se refere a Fornecedor'###"Informação"
           RETURN .F.
        ELSE
           IF !Work2->(DBSEEK(cCodForn))
              Help("", 1, "AVG0000505")//'Fornecedor nÆo cadastrado nesta Concorrˆncia'###"Informação"
              RETURN .F.
           ENDIF
        ENDIF

   CASE MFlag == '18'

        IF EMPTY(cPrecoUni)
           Help("", 1, "AVG0000498")//'FOB Unit rio nÆo preenchido'###"Atenção"
           RETURN .F.
        ELSEIF cPrecoUni < 0
           Help("", 1, "AVG0000506")//'FOB Unit rio nÆo pode ser negativo'###"Atenção"
           RETURN .F.
        ENDIF

   CASE MFlag == '19'

        IF EMPTY(cUR)
           cSI:=SPACE(LEN(SWS->WS_SI_NUM))
           RETURN .T.
        ENDIF

        IF !SY3->(DBSEEK(xFilial()+cUR))
           Help("", 1, "AVG0000507")//"Unidade Requisitante não cadastrada"###"Informação"
           RETURN .F.
        ENDIF

        IF !TRB->(DBSEEK(cUR))
           Help("", 1, "AVG0000508")//"U.R. não pertence a essa Cotação"###"Informação"
           RETURN .F.
        ENDIF

        cSI:=TRB->WS_SI_NUM //JVR - 15/04/2009

   CASE MFlag == '20'

        IF EMPTY(cSI); RETURN .T.; ENDIF

        IF !SW0->(DBSEEK(xFilial()+cUR+cSI))
           Help("", 1, "AVG0000482")//"S.I. não cadastrada para essa Unidade Requisitante"###"Informação"
           RETURN .F.
        ENDIF

        IF !TRB->(DBSEEK(cUR+cSI))
           Help("", 1, "AVG0000509")//"S.I. não pertence a essa Cotação"###"Informação"
           RETURN .F.
        ENDIF

        cUR:=TRB->WS__CC //JVR - 15/04/2009

   CASE MFlag == '21'

        IF EMPTY(cUR); RETURN .T.; ENDIF

        IF !TRB->(DBSEEK(cUR))
           Help("", 1, "AVG0000510")//"Unidade Requisitante nÆo pertence a essa Concorrˆncia"###"Informação"
           RETURN .F.
        ENDIF

        IF EMPTY(cSI); RETURN .T.; ENDIF

        IF !TRB->(DBSEEK(cUR+cSI))
           Help("", 1, "AVG0000511")//"S.I. nÆo pertence a essa Concorrˆncia"###"Informação"
           RETURN .F.
        ENDIF

   CASE MFlag == '22'

        IF !EMPTY(M->WS_COD_I) .AND. lInclusao
           RETURN .F.
        ENDIF


   //** PLB 20/09/07

   //--------------------------  Validação dos novos campos para tratamento de Incoterm ---------------------------------------//

   // Valor Unitário na Condição de Venda
   CASE MFlag == '23'

      If !lEnd
         If Empty(M->WT_VL_UNIT)
            Help(" ",1,"AVG0005247") // "Valor deve ser maior que zero."
            Return .F.
         Else
            If !Empty(M->WT_INCOTER)  .And.  QC210FreIn(M->WT_INCOTER)
               nValFrete := M->WT_FRE_KG / Work1->WS_QTDE
               If !Empty(M->WT_MOE_FRE)  .And.  !Empty(M->WT_MOEDA)  .And.  !( M->WT_MOE_FRE == M->WT_MOEDA )
                  nValFrete := nValFrete * BuscaTaxa(M->WT_MOE_FRE,dDataBase,,.F.) / BuscaTaxa(M->WT_MOEDA,dDataBase,,.F.)
               EndIf
               nValFrete := Round(nValFrete,5)
            Else
               nValFrete := 0
            EndIf
            M->WT_FOB_UNI := M->WT_VL_UNIT - nValFrete
         EndIf
         Return QC210VAL('12')  // Validação do campo WT_FOB_UNI (FOB Unitário)
      EndIf


   // Incoterm
   CASE MFlag == '24'
      If !lEnd
         If !Empty(M->WT_INCOTER)  .And.  !Empty(M->WT_VL_UNIT)
            If QC210FreIn(M->WT_INCOTER)
               nValFrete := M->WT_FRE_KG / Work1->WS_QTDE
               If !Empty(M->WT_MOE_FRE)  .And.  !Empty(M->WT_MOEDA)  .And.  !( M->WT_MOE_FRE == M->WT_MOEDA )
                  nValFrete := nValFrete * BuscaTaxa(M->WT_MOE_FRE,dDataBase,,.F.) / BuscaTaxa(M->WT_MOEDA,dDataBase,,.F.)
               EndIf
               nValFrete := Round(nValFrete,5)
            Else
               nValFrete := 0
            EndIf
            M->WT_FOB_UNI := M->WT_VL_UNIT - nValFrete
            Return QC210VAL('12')  // Validação do campo WT_FOB_UNI (FOB Unitário)
         EndIf
      EndIf


   CASE MFlag == '25'
      If nPrecoUni <= 0
         Help(" ",1,"AVG0005247")  // "Valor deve ser maior que zero."
         Return .F.
      Else
         If QC210FreIn(cIncoterm)
            nFOBUni := nPrecoUni - nFreteUni
         Else
            nFOBUni := nPrecoUni
         EndIf
      EndIf


   CASE MFlag == '26'
      If nFOBUni <= 0
         Help(" ",1,"AVG0005247")  // "Valor deve ser maior que zero."
         Return .F.
      Else
         If QC210FreIn(cIncoterm)
            nPrecoUni := nFOBUni + nFreteUni
         Else
            nPrecoUni := nFOBUni
         EndIf
      EndIf


   //**

ENDCASE
RETURN .T.


*----------------------------------------------------------------------*
FUNCTION QCBarCap(nOpc,oDlg,bOk,bCancel)
*----------------------------------------------------------------------*
LOCAL bSet15, bSet24, lOk
LOCAL lVolta:=.F., Ind, I

//Private oBar - FSM - 11/07/2011

aButtons:={}

IF lWork1
   Aadd(aButtons,{"EDIT",{||nOpca:=7,oDlg:End()},STR0143})
ENDIF

IF STR(nOpc,1) $ '2,5'
   IF lWork1
      Aadd(aButtons,{"RELATORIO",{||nOpca:=3,oDlg:End()},STR0034})
   ENDIF
ELSEIF nOpc # 6
   Aadd(aButtons,{"EDIT",{||nOpca:=1,oDlg:End()} ,STR0105}) //"Inclusão"
   Aadd(aButtons,{"IC_17",{||nOpca:=2,oDlg:End()} ,STR0106}) //"Alteração"
   Aadd(aButtons,{"EXCLUIR",{||nOpca:=5,oDlg:End()} ,STR0107 }) //"Exclusão"
   IF lWork1
      Aadd(aButtons,{"RELATORIO",{||nOpca:=3,oDlg:End()},STR0034})
      Aadd(aButtons,{"NOTE",{||nOpca:=8,oDlg:End()},STR0108})
      IF(EasyEntryPoint("EICQC210"),ExecBlock("EICQC210",.F.,.F.,"BTINCLUI"),) //JWJ 01/08/05
   ENDIF
ELSEIF nOpc == 6
	IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"BTAVALIA"),)	//ASR 28/07/05
ENDIF
RETURN

*--------------------------------------*
FUNCTION QC210Avalia(cAlias,nReg,nOpc)
*--------------------------------------*
LOCAL oDlg, I, cTitulo:= OemtoAnsi(STR0110) //"Avalia‡Æo do Quadro de Concorrˆncia"
LOCAL oObj
LOCAL oEnCh1
Local bOk := {||nOpca:=7,oDlg:End()} //FSM - 11/07/11
Local bCancel := {||nOpca:=0,oDlg:End()} //FSM - 11/07/11

PRIVATE aCamposWT:={}	//JWJ 03/08/05 - Chamado 015441
PRIVATE nUsado:=0, aHeader[0], nOpca:=0
PRIVATE cUR, cSI, cTipo, lWork1:=.T.
PRIVATE bPart_Number

IF EICLOJA()
   bPart_Number:={||QC210BuscaPN(Work2->WT_COD_I,Work2->WT_FORN,Work2->WT_FABR,Work2->WT_FORLOJ,Work2->WT_FABLOJ)}
ELSE
   bPart_Number:={||QC210BuscaPN(Work2->WT_COD_I,Work2->WT_FORN,Work2->WT_FABR,"","")}
ENDIF

aTela := {}
aGets := {}
dbSelectArea("SWS")
dbSetOrder(1)
SWS->(dbSeek(cFilSWS+SWR->WR_NR_CONC))
If EOF()
   Help(" ",1,"EICSEMIT")
   Return .T.
Endif
SWT->(dbSetOrder(1))
SWT->(dbSeek(cFilSWT+SWR->WR_NR_CONC))

If SWR->(FieldPos("WR_STATUS")) > 0  // TLM 28/05/2008
   If SWR->WR_STATUS == '*'
      MsgInfo(STR0153,"Atenção") //"Essa contação está cancelada, Atenção"
      return
   EndIf
EndIf
IF !QC210GetTipo()
   Return .T.
Endif

AADD(aCamposWT,{"WT_COD_I" ,"",STR0111}) //"Cod. Prod."
AADD(aCamposWT,{{||LEFT(Work2->WT_DESCR,35)},"",STR0010}) //"Produto"
AADD(aCamposWT,{bPart_Number ,"",STR0139})//"Part Number"
AADD(aCamposWT,{"WT_QTDE"    ,"",STR0012 ,cPicQtde }) //"Quantidade"
AADD(aCamposWT,{"WT_CLASS"   ,"",STR0112,"99" }) //"Class"
AADD(aCamposWT,{"WT_FORN"    ,"",STR0017}) //"Cod. Forn."
AADD(aCamposWT,{{||LEFT(Work2->WT_DESCRFO,35)},"",STR0018}) //"Fornecedor"
AADD(aCamposWT,{"WT_FABR"    ,"",STR0030}) //"Cod. Fabr."
AADD(aCamposWT,{{||LEFT(Work2->WT_DESCRFA,35)} ,"",STR0031}) //"Fabricante"
AADD(aCamposWT,{"WT_FOB_UNI" ,"",STR0113,cPicFOBUni}) //"FOB Unitario"
AADD(aCamposWT,{"WT_FOB_TOT" ,"",STR0028,cPicFOBUni}) //"FOB Total"
AADD(aCamposWT,{"WT_FRE_KG"  ,"",STR0024,cPicFreKG}) //"Frete Total"
AADD(aCamposWT,{"WT_SEGURO"  ,"",STR0025     ,cPicSeguro}) //"Seguro"
AADD(aCamposWT,{"WT_CIF"     ,"",STR0114,cPicCIF }) //"Vl. C.I.F."
AADD(aCamposWT,{"WT_CIF_P"   ,"",STR0115,"@E 9,999.99"}) //"% Var"
AADD(aCamposWT,{{||TRANS(Work2->WT_COD_PAG,'@R 9.9.999')+'  '+TRANS(Work2->WT_DIASPAG,'999')} ,"",STR0116}) //"Cond Pagto"
AADD(aCamposWT,{"WT_DESCR_P" ,"",STR0011}) //"Descrição"
AADD(aCamposWT,{"WT_DT_FORN" ,"",STR0029}) //"Data Entr."

EICAddLoja(aCamposWT, "WT_FORLOJ", Nil, STR0017)
EICAddLoja(aCamposWT, "WT_FABLOJ", Nil, STR0030)

IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"ADIC_COLS"),)	//ASR 28/07/05

DBSELECTAREA('Work2')
DBSETINDEX(cNo2CdxWT+TEOrdBagExt())//CIF
DBSETINDEX(cNo3CdxWT+TEOrdBagExt())//CLASS
IF cTipo = "3"//Por Data de Entrega
   DBSETINDEX(cNo4CdxWT+TEOrdBagExt())
ELSEIF cTipo = "2"//Por Valor FOB Total
   DBSETINDEX(cNo5CdxWT+TEOrdBagExt())
ELSE
	IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"ORD_AVALIA"),)	//ASR 28/07/05
ENDIF

AvZap()
dbSetOrder(1)

Processa({||QC210GeraWork()},STR0117) //"Processando Itens da Cotação"

IF Work2->(Easyreccount("Work2")) == 0
   Help(" ",1,"EA200SEMIT")
   dbSelectArea("SWR")
   Return .T.
ENDIF

aCamposWt:= AddCpoUser(aCamposWt,"SWT","2")

dbSelectArea("SWR")
FOR I := 1 TO FCount()
    M->&(EVAL({|nCPO|Field(nCPO)},i)) := FieldGet(i)
NEXT

WHILE .T.

   DBSELECTAREA("Work2")
   DBSETORDER(IF(cTipo#"1",3,1))
   DBGOTOP()
   nOpca := 0

   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE cTitulo;
                FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
                   OF oMainWnd PIXEL

   aTela := {}
   aGets := {}

   nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )

   Work2->(oObj:=MsSelect():New("Work2",,,aCamposWt,.T.,"X",{nMeio,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2}))

   oEnCh1 := MsMGet():New( cAlias, nReg,2,,,,,{ 15,  1,nMeio-1 , (oDlg:nClientWidth-4)/2  },,3)

   //FSM - 11/07/2011
   QCBarCap(nOpc,oDlg,bOk,bCancel)

   oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oObj:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT



   //FSM - 11/07/2011
   ACTIVATE MSDIALOG oDlg ON INIT ;
                          (EnchoiceBar(oDlg, bOk, bCancel,, aButtons)) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   /*
               (QCBarCap(nOpc,oDlg,{||nOpca:=7,oDlg:End()},;
                                  {||nOpca:=0,oDlg:End()}), oEnch1:oBox:Align := CONTROL_ALIGN_TOP,;
                                   oObj:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT )
     */
   IF(EasyEntryPoint("EICQC210"), EXECBLOCK("EICQC210",.F.,.F.,"FIM_DLG_AVALIA"), )		//JWJ 04/08/05

   IF nOpca == 7
      EICQC251Rel(nOpc)
      LOOP
   ENDIF

   EXIT

ENDDO

DBSELECTAREA('Work2') ; AvZap()
OrdListClear()

dbSelectArea("SWR")
Return 0

*-------------------------*
Function QC210GetTipo()
*-------------------------*
LOCAL nOpca:=0

LOCAL nLin:=20, nColS:=7,nColG:=64,OldArea:=SELECT()
Local oPanel
PRIVATE nExec:=0, oDlg
PRIVATE aTipo:={STR0118      ,; //"1 - Por Valor CIF"
                STR0119,; //"2 - Por Valor FOB Total"
                STR0120} //"3 - Por Data de Entrega"

IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"IT_AVALIA"),)

cUR  :=SPACE(LEN(Work1->WS__CC))
cSI  :=SPACE(LEN(Work1->WS_SI_NUM))
cTipo:=STR0118 //"1 - Por Valor CIF"

//\\\\\\\\\\\\\\\/////////////// Help F4
aHeader:={}
aCampos:={"WS__CC","WS_SI_NUM"}
aSemSX3:={}
AADD(aSemSX3,{"TRB_ALI_WT","C",03,0}) //TRP - 25/01/07 - Campos do WalkThru
AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
cTRB:=E_CriaTrab(,aSemSX3)

IndRegua("TRB",cTRB+TEOrdBagExt(),"WS__CC+WS_SI_NUM")

bGrava :={||IF(!EMPTY(SWS->WS__CC),;
               (IF(!TRB->(DBSEEK(SWS->WS__CC+SWS->WS_SI_NUM)),;
                (TRB->(DBAPPEND()),;
                 TRB->WS__CC   :=SWS->WS__CC,;
                 TRB->WS_SI_NUM:=SWS->WS_SI_NUM,;
                 TRB->TRB_ALI_WT  := "SWS",;
                 TRB->TRB_REC_WT  := SWS->(Recno()) ),)),)}

SWS->(DBSEEK(cFilSWS+SWR->WR_NR_CONC))
SWS->(DBEVAL(bGrava,,{||SWS->WS_NR_CONC == SWR->WR_NR_CONC .AND. SWS->WS_FILIAL == cFilSWS}))

SETKEY(VK_F4,{||QC210Help()})
/////////////////\\\\\\\\\\\\\\\ Help F4
DO WHILE .T.

   nExec:=0
   nLin :=20

   DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0121) From 0,0 To 15,50 OF oMainWnd //"Sele‡Æo da Avalia‡Æo"
      oPanel:=	TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
      @ nLin,nColS SAY STR0122 SIZE 50,8 OF oPanel PIXEL //"Unidade Requ."
      @ nLin,nColG MSGET cUR PICTURE "@!" VALID QC210Val("19") SIZE 30,8 OF oPanel PIXEL
      @ nLin,nColG+60 SAY "(F4-Help)" SIZE 40,8 OF oPanel PIXEL////// Help F4  SO.:0026 OS.:0247/02 FCD
      nLin:=nLin+13

      @ nLin,nColS SAY OemToAnsi(STR0123) SIZE 32,8 OF oPanel PIXEL //"S.I. N§"
      @ nLin,nColG MSGET cSI PICTURE "@!" VALID QC210Val("20") SIZE 52,8 OF oPanel WHEN !EMPTY(cUR) PIXEL
      @ nLin,nColG+70 SAY "(F4-Help)" SIZE 40,8 OF oPanel PIXEL ////// Help F4 SO.:0026 OS.:0247/02 FCD
      nLin:=nLin+13

      @ nLin,nColS SAY OemToAnsi(STR0124)SIZE 70,8 OF oPanel PIXEL //"Tipo de Apura‡Æo"
      @ nLin,nColG COMBOBOX cTipo ITEMS aTipo SIZE 80,50  OF oPanel  PIXEL

   ACTIVATE MSDIALOG oDlg ON INIT ;
            EnchoiceBar(oDlg,{||IF(QC210Val("21"),(nExec:=1,oDlg:End()),)},;
                             {||nExec:=0,oDlg:End()}) CENTERED

   IF nExec == 2
      LOOP
   ENDIF

   TRB->(E_EraseArq(cTRB))
   DBSELECTAREA(OldArea)
   SETKEY(VK_F4,{||.T.})
   EXIT

ENDDO

IF nExec == 0
   RETURN .F.
ENDIF

RETURN .T.

//\\\\\\\\\\\\\\\/////////////// Help F4
*---------------------*
FUNCTION QC210Help()
*---------------------*
LOCAL bOK,oDlg2
LOCAL oPanel

dbSelectArea("TRB")
dbGoTop()

cVar:=UPPER(ReadVar())

IF cVar=="CUR"
   cTit:=OemToAnsi(STR0125)+ALLTRIM(SWR->WR_NR_CONC) //"Consulta U.R. da Cota‡Æo: "
   bOK:={||cUR:=TRB->WS__CC,oDlg2:End()}
ELSEIF cVar=="CSI"
   cTit:=OemToAnsi(STR0126)+ALLTRIM(SWR->WR_NR_CONC) //"Consulta S.I. da Cota‡Æo: "
   bOK:={||cSI:=TRB->WS_SI_NUM,oDlg2:End()}
ELSE
   RETURN NIL
ENDIF

nExec:=2
//oDlg:End()  - GFC 21/12/03 Comentado pois causava inconsistencia.

DEFINE MSDIALOG oDlg2 TITLE cTit From 0,0 To 10,45 OF oMainWnd

   oMark:=MsSelect():New("TRB",,,{{"WS__CC"   ,,"Unid. Requ."},;
                                  {"WS_SI_NUM",,"Solic. Imp."}},,,{10,6,70,120})
   oMark:bAval:=bOK

   @ 00,00 MsPanel oPanel Prompt "" Size 35,80 of oDlg2

   DEFINE SBUTTON FROM 2,2 TYPE 1 ACTION (EVAL(bOK)) ENABLE OF oPanel Pixel
   DEFINE SBUTTON FROM 25,2 TYPE 2 ACTION oDlg2:End() ENABLE OF oPanel Pixel

ACTIVATE MSDIALOG oDlg2 CENTERED on Init (oPanel:Align := CONTROL_ALIGN_RIGHT, oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT)

Return .T.
/////////////////\\\\\\\\\\\\\\\ Help F4

*---------------------*
FUNCTION QC210GeraWork
*---------------------*
LOCAL TSeguro := TFreTotal := TFobTotal := 0
LOCAL nCont:=0, nContAux,cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")
PRIVATE lAchou, TReg, cSINUM, nCond //LAM - 26/05/06

SWS->(DBSEEK(cFilSWS+SWR->WR_NR_CONC))
SWS->(DBEVAL({||++nCont},,{||SWS->WS_NR_CONC == SWR->WR_NR_CONC .AND. SWS->WS_FILIAL == cFilSWS}))

ProcRegua(nCont)
nCont:=0

SWT->(DBSETORDER(1)) //(2))  // Nopado por GFP - 14/06/2013 - Indices 1 e 2 da tabela SWT ficam iguais após execução do UILOJAEIC
SWS->(DBSEEK(cFilSWS+SWR->WR_NR_CONC))

DO WHILE SWS->(!EOF()) .AND. SWS->WS_NR_CONC == SWR->WR_NR_CONC .AND. SWS->WS_FILIAL == cFilSWS

   IncProc(STR0127+SWS->WS_COD_I) //"Processando Item No: "

   // NOVO PONTO DE ENTRADA - LAM - 26/05/06
   lSair := .F.
   lAchou:= .T.
   IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"WRK_AVALIA"),)

   IF !lSair //LAM - 26/05/06
	   IF !SWT->(DBSEEK(cFilSWT+SWS->WS_NR_CONC+SWS->WS_COD_I))
   	   SWS->(DBSKIP()) ; LOOP
	   ENDIF
   ENDIF
   IF !lAchou
      SWS->(DBSKIP()); LOOP
   ENDIF

   IF !EMPTY(cUR) .AND. cUR # SWS->WS__CC
      SWS->(DBSKIP()) ; LOOP
   ENDIF

   IF !EMPTY(cSI) .AND. cSI # SWS->WS_SI_NUM
      SWS->(DBSKIP()) ; LOOP
   ENDIF

   SY6->(DBSEEK(xFilial()+SWT->WT_COD_PAG+STR(SWT->WT_DIASPAG,3)))
   SB1->(DBSEEK(cFilSB1+SWS->WS_COD_I))

   DO WHILE SWT->(!EOF()) .AND. SWT->WT_NR_CONC == SWS->WS_NR_CONC .AND. SWT->WT_COD_I = SWS->WS_COD_I .AND. SWT->WT_FILIAL == cFilSWT
      SY6->(DBSEEK(xFilial()+SWT->WT_COD_PAG+STR(SWT->WT_DIASPAG,3)))

	  // NOVO PONTO DE ENTRADA - LAM - 26/05/06
	  nCond := 0
	  IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"MAIS_COND"),)

   	  IF nCond == 1
         EXIT
      ELSEIF nCond == 2
	     SWT->(DBSKIP()); LOOP
      ENDIF

      SYR->(DBSEEK(xFilial()+SWR->WR_VIA+SWT->WT_ORIGEM+SWR->WR_DESTINO))

      TFobTotal := SWS->WS_QTDE   * (SWT->WT_FOB_UNI * BuscaTaxa(SWT->WT_MOEDA,SWR->WR_DT_CONC,,.F.) / ;
                                                       BuscaTaxa(cMoedaDolar,SWR->WR_DT_CONC,,.F.))

      TFreTotal := SWT->WT_FRE_KG * BuscaTaxa(SYR->YR_MOEDA,SWR->WR_DT_CONC,,.F.) / ;
                                    BuscaTaxa(cMoedaDolar,SWR->WR_DT_CONC,,.F.)

      TSeguro   := SWT->WT_SEGURO * BuscaTaxa(SWT->WT_MOEDA,SWR->WR_DT_CONC,,.F.) / ;
                                    BuscaTaxa(cMoedaDolar,SWR->WR_DT_CONC,,.F.)
      nCont++
      Work2->(DBAPPEND())
      Work2->WT_COD_I  := SWS->WS_COD_I
      Work2->WT_DESCR  := MSMM(SB1->B1_DESC_I,40,1)
      Work2->WT_DESCR_P:= MSMM(SB1->B1_DESC_P,40,1)
      Work2->WT_QTDE   := SWS->WS_QTDE
      Work2->WT_FORN   := SWT->WT_FORN
      If SWT->(FieldPos("WT_DTNECES")) # 0
         Work2->WT_DTNECES := SWS->WS_DTNECES
      EndIf
      If EICLOJA()
         Work2->WT_FORLOJ := SWT->WT_FORLOJ
      Endif
      Work2->WT_DESCRFO:= BuscaF_F(SWT->WT_FORN,,IF(EICLOJA(),SWT->WT_FORLOJ,""))
      Work2->WT_FABR   := SWT->WT_FABR
      If EICLOJA()
         Work2->WT_FABLOJ := SWT->WT_FABLOJ
      Endif
      Work2->WT_DESCRFA:= BuscaF_F(SWT->WT_FABR,,IF(EICLOJA(),SWT->WT_FORLOJ,""))
      Work2->WT_FOB_UNI:= (TFobTotal/SWS->WS_QTDE)
      Work2->WT_FOB_TOT:= TFobTotal
      Work2->WT_FRE_KG := TFreTotal
      Work2->WT_SEGURO := TSeguro
      Work2->WT_CIF    := TFobTotal+TFreTotal+TSeguro
      Work2->WT_COD_PAG:= SWT->WT_COD_PAG
      Work2->WT_DIASPAG:= SWT->WT_DIASPAG
      Work2->WT_DT_NEC := SWS->WS_DTNECES
      Work2->WT_DES_PAG:= SY6->(MSMM(SY6->Y6_DESC_P,25,1))
      Work2->WT_DT_FORN:= SWT->WT_DT_FORN
      Work2->WT_RECNO  := SWT->(RECNO())

	  Work2->WT_NR_CONC  := SWT->WT_NR_CONC //AAF 13/01/2017 - Garantir que esteja sempre preenchido.

	  Work2->TRB_ALI_WT:= "SWT"
	  Work2->TRB_REC_WT:= SWT->(Recno())

	  IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"ALIM_COLS"),)	//ASR 28/07/05

      SWT->(DBSKIP())

   ENDDO

   SWS->(DBSKIP())

ENDDO


Work2->(dbSetOrder(IF(cTipo#"1",3,1)))
Work2->(DBGOTOP())

ProcRegua(nCont)

WHILE Work2->(!EOF())

   TItem     := Work2->WT_COD_I
   TColocacao:= 1
   // NOVO PONTO DE ENTRADA - LAM - 26/05/06
   IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"SALVA_REG"),)

   WHILE Work2->(!EOF()) .AND. Work2->WT_COD_I = TItem
	  // NOVO PONTO DE ENTRADA - LAM - 26/05/06
	  lSair := .F.
	  IF(EasyEntryPoint("EICQC210"),EXECBLOCK("EICQC210",.F.,.F.,"MAIS_2COND"),)

      IF lSair
        EXIT
	  ENDIF

     IncProc(STR0128+SWS->WS_COD_I) //"Classificando Item No: "

     Work2->WT_CLASS := StrZero(TColocacao,2)
     TColocacao ++

     IF Val(Work2->WT_CLASS) = 1
        Work2->WT_CIF_P := 0
        TValor := Work2->WT_CIF
     ELSE
        Work2->WT_CIF_P := ((Work2->WT_CIF/TValor) -1) * 100
        IF Work2->WT_CIF_P >= 999.99
           Work2->WT_CIF_P := 999.99
        ELSEIF Work2->WT_CIF_P < 0
           Work2->WT_CIF_P := 0
        ENDIF
     ENDIF

     Work2->(DBSKIP())

   ENDDO

ENDDO

RETURN NIL

*----------------------------*
FUNCTION QC210Representante()
*----------------------------*
IF EMPTY(SA2->A2_REPRES)
   Work2->WT_REPRES  := ALLTRIM(SA2->A2_NOME)
   Work2->WT_FONES   := ALLTRIM(SA2->A2_TEL)
   Work2->WT_FAX     := ALLTRIM(SA2->A2_FAX)
   Work2->WT_CONTATO := ALLTRIM(SA2->A2_CONTATO)
ELSE
   Work2->WT_REPRES  := ALLTRIM(SA2->A2_REPRES)
   Work2->WT_FONES   := ALLTRIM(SA2->A2_REPRTEL)
   Work2->WT_FAX     := ALLTRIM(SA2->A2_REPRFAX)
   Work2->WT_CONTATO := ALLTRIM(SA2->A2_REPCONT)
ENDIF
RETURN NIL


*-------------------------*
Function QC210PrUni(nOpc)
*-------------------------*
LOCAL oDlg, nOpca:=0, cDescr:="", aCamposWT:={}
LOCAL nCont:=0, bGrava, oObj
LOCAL oPanel
Local aOrd := SaveOrd("SXB")
Private cCodForn, cCodLoja

IF (Work1->(EOF()) .AND. Work1->(BOF())) .OR.;
   (Work2->(EOF()) .AND. Work2->(BOF()))
   Help("", 1, "AVG0000478")//"NÆo existe Registros para a op‡Æo"###"Aviso"
   RETURN
ENDIF

Work2->(DBSETORDER(2))
cCodForn:=SPACE(LEN(SWT->WT_FORN))
IF EICLOJA()
   cCodLoja:=SPACE(LEN(SWT->WT_FORLOJ))
ENDIF

/*
DEFINE MSDIALOG oDlg TITLE STR0129 From 0,0 To 07,45 OF oMainWnd //"Itens do Fornecedor..."

   @ 20,7 SAY OemToAnsi(STR0130) SIZE 70,8 PIXEL //"C¢digo do Fornecedor "

   //ASK 17/09/2007 Consulta padrão alterada de SA2 para EIB, chama no SXB a RE QC210SA5F3()
   SXB->(DbSetOrder(1))
   If SXB->(DbSeek("EIB"+Space(3)+"1"))
      @ 20,72 MSGET cCodForn F3 "EIB" PICTURE "@!" SIZE 42,8  OF oDlg PIXEL
   Else
      @ 20,72 MSGET cCodForn F3 "SA2" PICTURE "@!" SIZE 42,8  OF oDlg PIXEL
   EndIf
   RestOrd(aOrd)

ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||IF(QC210Val("17"),(nOpca:=1,oDlg:End()),)},;
                          {||nOpca:=0,oDlg:End()}) CENTERED
*/

If EICLOJA()
   If EICTelaLoja(@cCodForn, @cCodLoja, "SA2A", 'QC210Val("17")')
      nOpcA := 1
   Endif
Else
   If EICTelaLoja(@cCodForn, @cCodLoja, "SA2", 'QC210Val("17")')
      nOpcA := 1
   Endif
Endif

IF nOpca = 0
   Work2->(DBSETORDER(1))
   RETURN
ENDIF

AADD(aCamposWT,{"WT_COD_I"   ,"",STR0111}) //"Cod. Prod."
AADD(aCamposWT,{{||LEFT(Work3->WT_DESCR,30)},"",STR0010}) //"Produto"
AADD(aCamposWT,{"WT_ORIGEM"  ,"",STR0020 }) //"Origem"
//** PLB 20/09/07
//AADD(aCamposWT,{"WT_MOEDA"   ,"",STR0021}) //"Moeda FOB"
If lIncoterm
   AADD(aCamposWT,{"WT_INCOTERM","",STR0149})  // "Incoterm"
EndIf
AADD(aCamposWT,{"WT_MOEDA"   ,"",STR0021}) //"Moeda Neg."
If lIncoterm
   AADD(aCamposWT,{"WT_VL_UNIT","",STR0148,cPicFOBUni})  // "Cond.Venda Unit"
EndIf
//**
AADD(aCamposWT,{"WT_FOB_UNI" ,"",STR0022 ,cPicFOBUni}) //"FOB Unit."
AADD(aCamposWT,{"WT_FOB_TOT" ,"",STR0028,cPicFOBUni}) //"FOB Total"
AADD(aCamposWT,{"WT_FABR"    ,"",STR0030}) //"Cod. Fabr."
AADD(aCamposWT,{{||LEFT(Work3->WT_DESCRFA,15)} ,"",STR0031}) //"Fabricante"
AADD(aCamposWT,{"WT_MOE_FRE" ,"",STR0023}) //"Moeda Frete"
AADD(aCamposWT,{"WT_FRE_KG"  ,"",STR0024,cPicFreKG}) //"Frete Total"
AADD(aCamposWT,{"WT_SEGURO"  ,"",STR0025     ,cPicSeguro}) //"Seguro"
AADD(aCamposWT,{{||TRANS(Work3->WT_COD_PAG,'@R 9.9.999')+' '+TRANS(Work3->WT_DIASPAG,'999')} ,"",STR0116}) //"Cond Pagto"
AADD(aCamposWT,{"WT_ULT_ENT" ,"",STR0026}) //"Dt Ult Compra"
AADD(aCamposWT,{"WT_ULT_FOB" ,"",STR0027,cPicUltFob}) //"Vr Ultima Compra"
AADD(aCamposWT,{"WT_DT_FORN" ,"",STR0029}) //"Data Entr."

EICAddLoja(aCamposWT, "WT_FABLOJ", Nil, STR0030)
DBSELECTAREA('Work3') ; AvZap()

Work2->(DBSEEK(cCodForn+IIf(EICLoja(),cCodLoja,"")))
Work2->(DBEVAL({||nCont++},,{||Work2->WT_FORN = cCodForn .and. If(EICLOJA(),Work2->WT_FORLOJ = cCodLoja,.T.)}))
Work2->(DBSEEK(cCodForn+IIf(EICLoja(),cCodLoja,"")))
cDescr:=Work2->WT_DESCRFO
bGrava:={||IncProc(STR0052),; //"Processando Registros"
           Work3->(DBAPPEND())             ,;
           QC210Append("Work3","Work2")    ,;
           Work2->TRB_ALI_WT:= "SWT"         ,;
           Work2->TRB_REC_WT:= SWT->(Recno()),;
           Work1->(DBSEEK(Work3->WT_COD_I)),;
           Work3->WT_DESCR:=Work1->WS_DESCR,;
           Work3->WT_RECNO2:=Work2->(RECNO())}

Processa({||ProcRegua(nCont),;
            Work2->(DBEVAL(bGrava,,{||Work2->WT_FORN = cCodForn .and. If(EICLOJA(),Work2->WT_FORLOJ = cCodLoja,.T.)}))},;
         STR0032) //"Processando Registros da Concorrencia"

Work2->(DBSETORDER(1))
Work1->(DBGOTOP())

IF Work3->(Easyreccount("Work3")) == 0
   Help(" ",1,"EA200SEMIT")
   Return
ENDIF

aCamposWT:= AddCpoUser(aCamposWT,"SWT","2")

Work3->(DBGOTOP())
DBSelectArea("Work3")

WHILE .T.

   nOpca := 0

   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE STR0131+ALLTRIM(cCodForn)+" - "+cDescr; //"Itens do Fornecedor: "
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
                   OF oMainWnd PIXEL


           Work3->(oObj:=MsSelect():New("Work3",,,aCamposWT,.T.,"X",{19,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2}))

     @ 00,00 MsPanel oPanel Prompt "" Size 60,24 of oDlg

     @ 05,(oDlg:nClientWidth-4)/2-130 BUTTON OemToAnsi(STR0132); //"Alterar FOB Unitario"
                             SIZE 51,11 ACTION (nOpca:=2,oDlg:End()) OF oPanel PIXEL
     @ 05,(oDlg:nClientWidth-4)/2-70  BUTTON STR0133 SIZE 29,11 ACTION (nOpca:=1,oDlg:End()) OF oPanel PIXEL //"Grava"
     @ 05,(oDlg:nClientWidth-4)/2-30  BUTTON STR0134  SIZE 29,11 ACTION (nOpca:=0,oDlg:End()) OF oPanel PIXEL //"Sair"
     oDlg:lMaximized:=.T.
	 oPanel:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	 oObj:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT


   //ACTIVATE MSDIALOG oDlg on Init (oPanel:Align := CONTROL_ALIGN_TOP, oObj:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
     ACTIVATE MSDIALOG oDlg
   DO CASE
      CASE nOpca = 0
           EXIT
      CASE nOpca = 1
           Processa({||QC210GrvPrUni()},STR0032) //"Processando Registros da Concorrencia"
           EXIT
      CASE nOpca = 2
           // PLB 20/09/07
           If lIncoterm
              QC210GetVlUni()
           Else
              QC210GetPrUni()
           EndIf
   ENDCASE

ENDDO

Work1->(DBGOTOP())

Return

//*** ASK 17/09/2007 - Rotina Externa chamada na consulta padrão EIB, no F3 "Itens/Forn" traz todos possíveis
//fornecedores dos itens da cotação(Work1), de acordo com o cadastro Prod/Forn (SA5)
*--------------------*
FUNCTION QC210SA5F3()
*--------------------*
Local lRet := .F.
Local oDlgF3, Tb_Campos:={}, cOldArea:= Alias()
Local bSetF3:= SetKey(VK_F3)
Local oSeek,cSeek,oOrdem,cOrd,aOrdem:={}
Local nOldInd:= SA5->( IndexOrd() )
Local nRec
Local aCamposSa5 := {}
Local aOrd := SaveOrd({"SA5","Work1"})

Private lInverte := .F.
Private cMarca := GetMark(), aheader:={}  ,aCampos := {}
Private cFilSA2:= xFilial("SA2")

Begin Sequence

   AADD(aCamposSA5,{"A5_FORNECE"   ,"C",  6 , 0 }) //"Cod. Forn."
   If EICLoja()
      AADD(aCamposSA5,{"A5_LOJA"      ,"C", Avsx3("A5_LOJA",AV_TAMANHO) , 0 }) //"Loja" -  TLM 07/03/2008 - Alterado de 2 p/ utilizar a função AvSX3.
   EndIf
   AADD(aCamposSA5,{"A5_NOMEFOR"   ,"C", 40 , 0 }) //"Nome Forn."
   AADD(aCamposSA5,{"A5_PRODUTO"   ,"C", 15 , 0 }) //"Produto"

   cFileWork1 := E_CriaTrab(,aCamposSA5,"Work4")
   If EICLoja()
      IndRegua("Work4",cFileWork1 + TEOrdBagExt(),"A5_FORNECE+A5_LOJA")
   Else
      IndRegua("Work4",cFileWork1 + TEOrdBagExt(),"A5_FORNECE")
   EndIf

   cFileWork2 := E_Create(,.F.)
   IndRegua("Work4",cFileWork2 + TEOrdBagExt(),"A5_NOMEFOR")

   SET INDEX TO (cFileWork1 + TEOrdBagExt()),(cFileWork2 + TEOrdBagExt())

   SA5->(DbSetOrder(2))

   Work1->(DbGoTop())

   DO WHILE Work1->(!EOF())
      SA5->(DbSeek(xFilial("SA5") + Work1->WS_COD_I))
      Do While SA5->(!EOF()) .And. SA5->A5_FILIAL = xFilial("SA5") .And. SA5->A5_PRODUTO == Work1->WS_COD_I
         If Work4->(DbSeek(SA5->A5_FORNECE+EICRetLoja("SA5","A5_LOJA")))
            SA5->(DbSkip())
            LOOP
         EndIf

         Work4->(DBAPPEND())
         Work4->A5_FORNECE  := SA5->A5_FORNECE
         If EICLoja()
            Work4->A5_LOJA     := SA5->A5_LOJA
         EndIf
         Work4->A5_NOMEFOR  := SA5->A5_NOMEFOR
         Work4->A5_PRODUTO  := SA5->A5_PRODUTO

         SA5->(DbSkip())
      EndDo
      Work1->(DbSkip())
   EndDo

   Work4->(DbGoTop())

   IF Work4->(EOF()) .Or. Work4->(BOF())
      Help("", 1, "AVG0000547")//MsgInfo(STR0133) //"Nao ha Fabricantes e Fornecedores cadastrados para este produto"
      BREAK
   ENDIF

   cTitulo:=STR0134+STR0136 //"Consulta Padrao de Itens'Fornecedores'

   //evitar recursividade
   Set Key VK_F3 TO

   bReturn:={||cCodForn:=Work4->A5_FORNECE,oDlgF3:End()}

   cSeek := Space(45)
   aAdd(aOrdem,STR0017+" + "+"Loja")//"Código"###"Loja"
   aAdd(aOrdem,STR0018+" + "+"Loja")//"Fornecedor"###"Loja"

   AADD(Tb_Campos,{"A5_FORNECE" ,,STR0017}) //"Código"
   If EICLoja()
      AADD(Tb_Campos,{"A5_LOJA",,"Loja"}) //"Loja"
   EndIf
   AADD(Tb_Campos,{"A5_NOMEFOR",,STR0018}) //"Fornecedor"

   DEFINE MSDIALOG oDlgF3 TITLE STR0018 FROM 62,15 TO 310,460 OF oMainWnd PIXEL //"Fornecedor"

   oMark:= MsSelect():New("Work4",,,TB_Campos,@lInverte,@cMarca,{10,12,80,186})
   oMark:baval:= {|| lRet:=.T., Eval(bReturn) }

   @ 091, 14 SAY "Pesquisar por:" SIZE 42,7 OF oDlgF3 PIXEL //"Pesquisar por:"
   @ 090, 59 COMBOBOX oOrdem VAR cOrd ITEMS aOrdem SIZE 119, 42 OF oDlgF3 PIXEL ON CHANGE;
     (SEEKF3(oMARK,,oOrdem),Work4->(DbGoTop()), oMark:oBrowse:Refresh())

   @ 104, 14 SAY "Localizar" SIZE 32, 7 OF oDlgF3 PIXEL //"Localizar"
   @ 104, 58 MSGET oSeek VAR cSeek SIZE 120, 10 OF oDlgF3 PIXEL
   oSeek:bChange := {|nChar|Work4->(SEEKF3(oMARK,RTrim(oSeek:oGet:Buffer)))}

   DEFINE SBUTTON FROM 10,187 TYPE 1 ACTION (Eval(oMark:baval)) ENABLE OF oDlgF3 PIXEL
   DEFINE SBUTTON FROM 25,187 TYPE 2 ACTION (oDlgF3:End()) ENABLE OF oDlgF3 PIXEL

   ACTIVATE MSDIALOG oDlgF3

END SEQUENCE

   Work4->(E_EraseArq(cFileWork1,cFileWork2))

   SA5->( dbSetOrder(nOldInd) )
   SET FILTER TO
   dbSelectArea(cOldArea)
   RestOrd(aOrd,.T.)
   SetKey(VK_F3,bSetF3)

Return lRet
//***
*-------------------------*
Function QC210GetPrUni()
*-------------------------*
LOCAL oDlg, nOpca:=0, cPrAtual

cPrAtual:=cPrecoUni:=Work3->WT_FOB_UNI

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0135)+; //"FOB Unit rio do Item: "
                     Work3->WT_COD_I+" - "+LEFT(Work3->WT_DESCR,20) From 0,0 To 09,45 OF oMainWnd

   @ 20,40  SAY STR0136  SIZE 32,8 PIXEL //"Novo"
   @ 20,104 SAY STR0137 SIZE 32,8 PIXEL //"Atual"
   @ 33, 7  SAY OemToAnsi(STR0138) SIZE 40,8 PIXEL //"FOB Unit rio"

   @ 33,40  MSGET cPrecoUni PICTURE cPicFOBUni SIZE 50,8  OF oDlg PIXEL
   @ 33,104 MSGET cPrAtual  PICTURE cPicFOBUni SIZE 50,8  OF oDlg  WHEN .F. PIXEL

ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||IF(QC210Val("18"),(nOpca:=1,oDlg:End()),)},;
                          {||nOpca:=0,oDlg:End()}) CENTERED

IF nOpca = 0
   RETURN
ENDIF

Work1->(DBSEEK(Work3->WT_COD_I))
Work3->WT_FOB_UNI:=cPrecoUni
Work3->WT_SEGURO :=IF(!EMPTY(M->WR_PER_SEG),Work3->WT_FOB_UNI * (M->WR_PER_SEG/100) * Work1->WS_QTDE,0)
Work3->WT_FOB_TOT:=Work3->WT_FOB_UNI * Work1->WS_QTDE

RETURN

*-------------------------*
Function QC210GrvPrUni()
*-------------------------*
bGrava:={||IncProc(STR0052),; //"Processando Registros"
           Work2->(DBGOTO(Work3->WT_RECNO2)),;
           QC210Append("Work2","Work3")}

ProcRegua(Work3->(Easyreccount("Work3")))

IF EasyEntryPoint("ICPADQC0")
  ExecBlock("ICPADQC0",.T.,.T.,1)
ENDIF
Work3->(DBEVAL(bGrava))

RETURN
*--------------------------------------------------------------*
Static Function QC210BuscaPN(cItem,cForn,cFabr,cLojFor,cLojFab)
*--------------------------------------------------------------*
Default cLojFor:= ""
Default cLojFab:= ""

SA5->(DBSETORDER(3))

If !Empty(cLojFor) .and. !Empty(cLojFab)
   IF !EICSFabFor(xFilial("SA5")+cItem+cFabr+cForn, cLojFab,cLojFor)
      IF !EICSFabFor(xFilial("SA5")+cItem+cFabr,cLojFab)
         SA5->(DBSETORDER(2))
         SA5->(DbSeek(xFilial()+cItem+cForn+cLojFor))
      ENDIF
   ENDIF

Else
   IF !SA5->(DbSeek(xFilial()+cItem+cFabr+cForn))

      IF !SA5->(DbSeek(xFilial()+cItem+cFabr))

         SA5->(DBSETORDER(2))
         SA5->(DbSeek(xFilial()+cItem+cForn+cLojFor))
      ENDIF
   ENDIF
ENDIF

SA5->(DBSETORDER(2))
RETURN SA5->A5_CODPRF

Function ValDtEnt()
dDataENt:=M->WT_DT_FORN
If !E_PERIODO_OK(M->WR_DT_CONC,M->WT_DT_FORN) //
  Help(" ",1,"AVG0005370")                    //LRL 26/01/2004  "Data de Entrega menor q a Data de Criação####Informe a data de Entrega mair que a de Criação
  RETURN .F.                                  //
EndIf
Return .T.


*-------------------------*
Function QC210GetVlUni()
*-------------------------*
 Local oDlg      := NIL  ,;
       nOpca     := 0
Local oPanel

 Private cIncoterm := ""   ,;
         nPrAtual  := 0    ,;
         nPrecoUni := 0    ,;
         nFOBAtual := 0    ,;
         nFOBUni   := 0    ,;
         nFreteUni := 0


   Work1->( DBSeek(Work3->WT_COD_I) )

   cIncoterm := Work3->WT_INCOTERM
   nPrAtual  := nPrecoUni := Work3->WT_VL_UNIT
   nFOBAtual := nFOBUni   := Work3->WT_FOB_UNI
   nFreteUni := Work3->WT_FRE_KG / Work1->WS_QTDE
   If Work3->( !Empty(WT_MOE_FRE)  .And.  !Empty(WT_MOEDA)  .And.  !( WT_MOE_FRE == WT_MOEDA ) )
      nFreteUni := nFreteUni * BuscaTaxa(Work3->WT_MOE_FRE,dDataBase,,.F.) / BuscaTaxa(Work3->WT_MOEDA,dDataBase,,.F.)
   EndIf
   nFreteUni := Round(nFreteUni,5)

   Begin Sequence

      DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0135)+; //"FOB Unitario do Item: "
                        Work3->WT_COD_I+" - "+LEFT(Work3->WT_DESCR,20) From 0,0 To IIF(QC210FreIn(cIncoterm),20,12),50 OF oMainWnd
         
         oPanel:=	TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.)
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
         
         @ 16,40  SAY STR0136 SIZE 32,8 OF oPanel PIXEL  //"Novo"
         @ 16,120 SAY STR0137 SIZE 32,8 OF oPanel PIXEL  //"Atual"

         @ 29, 7  SAY STR0151 SIZE 40,8 OF oPanel PIXEL  //"Cond.Venda"
         @ 29,40  MSGET nPrecoUni PICTURE cPicFOBUni SIZE 66,8 VALID QC210VAL('25') OF oPanel  PIXEL HASBUTTON
         @ 29,120 MSGET nPrAtual  PICTURE cPicFOBUni SIZE 66,8 OF oPanel  WHEN .F. PIXEL HASBUTTON

         @ 42, 7  SAY STR0138 SIZE 40,8 OF oPanel PIXEL  // "FOB Unitario"
         @ 42,40  MSGET nFOBUni   PICTURE cPicFOBUni SIZE 66,8 VALID QC210VAL('26') OF oPanel  PIXEL HASBUTTON
         @ 42,120 MSGET nFOBAtual PICTURE cPicFOBUni SIZE 66,8 OF oPanel WHEN .F. PIXEL HASBUTTON

         If QC210FreIn(cIncoterm)

            @ 65,71  SAY STR0149 SIZE 25,8 OF oPanel PIXEL  // "Incoterm"
            @ 65,120 MSGET cIncoterm SIZE 56,8 OF oPanel  WHEN .F. PIXEL

            @ 78,25  SAY STR0150 SIZE 80,8 OF oPanel PIXEL  // "Frete Unitario na Moeda Neg."
            @ 78,120 MSGET nFreteUni PICTURE cPicFOBUni SIZE 66,8 OF oPanel  WHEN .F. PIXEL HASBUTTON
         EndIf

      ACTIVATE MSDIALOG oDlg ON INIT ;
               EnchoiceBar(oDlg,{||(nOpca:=1,oDlg:End())},;
                                {||nOpca:=0,oDlg:End()}) CENTERED

      If nOpca == 1
         Work3->WT_VL_UNIT := nPrecoUni
         Work3->WT_FOB_UNI := nFOBUni
         Work3->WT_SEGURO  := IIF(!EMPTY(M->WR_PER_SEG),Work3->WT_FOB_UNI * (M->WR_PER_SEG/100) * Work1->WS_QTDE,0)
         Work3->WT_FOB_TOT := Work3->WT_FOB_UNI * Work1->WS_QTDE
      EndIf


   End Sequence


Return NIL


*-----------------------------------------------*
Static Function QC210FreIn(cIncoterm)
*-----------------------------------------------*

 Local lFreteInc := .F.

 Default cIncoterm := ""


   If !Empty(cIncoterm)
      If AvRetInco(AllTrim(cIncoterm),"CONTEM_FRETE")/* FSM - 28/12/10 */ //cIncoterm $ "CFR/CIF/CIP/CPT/DAF/DDP/DEQ/DES/DDU"
         lFreteInc := .T.
      EndIf
   EndIf

Return lFreteInc

Function QC210Status(cCampo)
*-----------------------------------------------*

Local cRet := ""
Default cCampo :=""

   Do Case
      Case cCampo == "WR_DESC_ST"
         If SWR->(FieldPos("WR_STATUS")) > 0
            If (Type("M->WR_STATUS") == "C" .And. M->WR_STATUS == "*") .Or. SWR->WR_STATUS == "*"
               cRet := "CANCELADO"
            EndIf
         EndIf

   EndCase

Return cRet
*----------------------------------------------------------------------------*
*                      FIM DO PROGRAMA EICQC210.PRW                          *
*----------------------------------------------------------------------------*

