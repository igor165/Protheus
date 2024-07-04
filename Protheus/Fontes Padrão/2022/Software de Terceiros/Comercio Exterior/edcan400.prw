#include "EDCAN400.ch"
#include "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"


#define GERAR    2
#define ESTORNAR 5

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2


/*
Programa        : EDCAN400.PRW
Objetivo        : Anuencia automática para produtos Anuentes
Autor           : Gustavo Carreiro
Data/Hora       : 
Obs.            : 
*/

*-----------------*
Function EDCAN400()
*-----------------*
Private aTabelas:={}, aBotoes:={}
Private cCadastro := STR0001 //"Anuencia Automatica"
Private cFilSW2:=xFilial("SW2"), cFilSW5:=xFilial("SW5"), cFilSW4:=xFilial("SW4")
Private cFilSW3:=xFilial("SW3")
Private cMarca := GetMark(), lInverte := .F.
Private aSelCpos:={}, aSemSX3SW3:={}
Private aRotina :=  MenuDef()

If AmIin(50)

   Processa({|| IniCpos()}   ,STR0005) //"Inicializando Ambiente"
   Processa({|| AN400Works()},STR0005) //"Inicializando Ambiente"

   SW2->(dbSetOrder(1))
   mBrowse(,,,,"SW2")

   AN400DelWorks()

EndIf

Return .T.

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 03/02/07 - 17:10
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := {}

AADD(aRotina,{ STR0002 ,"AxPesqui"  ,0,1})//"Pesquisar"
AADD(aRotina,{ STR0003 ,"AN400Manut",0,2})//"Gerar Anuencia"
AADD(aRotina,{ STR0020 ,"AN400Manut",0,5})//"Estorna Anuencia"

   If(EasyEntryPoint("EDCAN400"),ExecBlock("EDCAN400",.F.,.F.,"MBROWSE"),)

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("DAN400MNU")
	aRotAdic := ExecBlock("DAN400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
*-----------------------------------*
Function AN400Manut(cAlias,nReg,nOpc)
*-----------------------------------*
Local oDlg, bOk := {||nOpcao:=1,oDlg:End()}, nOpcao:=0
Local aBotao:={}
LOCAL lResult := .f.
Private oMark, aHeader := {}, aCampos := ARRAY(0)
Private aDelWkSW3:={}

Aadd(aBotao,{"LBTIK",{|| Processa({|| AN400Marca(.T.,nOpc)}, STR0019),WorkSW3->(dbGoTop()) },STR0019}) //"Marca/Desmarca Todos"

oMainWnd:ReadClientCoords()//So precisa declarar uma vez para o programa todo

Processa({|| LimpaTabelas() },STR0006) //"Criando Arquivos Temporarios"
dbSelectArea("SW2")
aGets:={}
aTela:={}

Processa({|| AN400GrvWorks(nOpc)}, STR0007) //"Gravando Arquivos Temporarios"

If !WorkSW3->(BOF()) .and. !WorkSW3->(EOF())

   DEFINE MSDIALOG oDlg TITLE STR0008 FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO ;
   oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL
   
      nLinha := (oDlg:nClientHeight-4)/2
      oMark:= MsSelect():New("WorkSW3","MARCA",,aSelCpos,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL})
      oMark:bAval:={|| AN400Marca(.F.,nOpc)}
	  oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| Eval(bOk) },{||nOpcao:=0,oDlg:End()},,aBotao)) //LRL 25/05/04 - Alinhamento MDI //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   If nOpcao = 1
      Begin TransAction
         If nOpc = 2
            Processa({|| lResult := GeraAnuencia()}   ,STR0016) //"Gerando Anuencia"
         Else
            Processa({|| lResult := ExcluiAnuencia()} ,STR0021) //"Excluindo Anuência(s)"
         EndIf
      End TransAction
      if lResult   // By A. Caetano Jr. - 08/12/2003 - Verifica se realmente foi processado algo.
         If nOpc = 2
            MsgInfo(STR0018+Alltrim(SW4->W4_PGI_NUM)) //"Anuencia Automatica efetuada com sucesso. PLI Nro. "
         Else
            MsgInfo(STR0022) //"Exclusão efetuada com sucesso."
         EndIf
	  Endif    
      SW4->(DbSetOrder(1))
      If SW4->(DbSeek(xFilial("SW4") + WorkSW3->W3_PGI_NUM))
         SW4->(MsUnlock())
      Endif
   Else
      SW4->(DbSetOrder(1))
      If SW4->(DbSeek(xFilial("SW4") + WorkSW3->W3_PGI_NUM))
         SW4->(MsUnlock())
      Endif
   EndIf
Else
   Help(" ",1,"AVG0005187") //MsgInfo(STR0014) //"Nenhum item deste P.O. selecionado para Anuencia Automatica."
EndIf

Return .T.

*-----------------------*
Static Function IniCpos()
*-----------------------*

ProcRegua(2)

IncProc(STR0005) //"Inicializando Ambiente"
AADD(aSemSX3SW3,{"MARCA","C",2,0})
AADD(aSemSX3SW3,{"W3_COD_I","C",AVSX3("W3_COD_I",3),0})
AADD(aSemSX3SW3,{"W3_SI_NUM","C",AVSX3("W3_SI_NUM",3),0})
AADD(aSemSX3SW3,{"W3_CC","C",AVSX3("W3_CC",3),0})
AADD(aSemSX3SW3,{"W3_PO_NUM","C",AVSX3("W3_PO_NUM",3),0})
AADD(aSemSX3SW3,{"W3_QTDE","N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)})
AADD(aSemSX3SW3,{"W3_SALDO_Q","N",AVSX3("W3_SALDO_Q",3),AVSX3("W3_SALDO_Q",4)})
AADD(aSemSX3SW3,{"W3_SALDO_O","N",AVSX3("W3_SALDO_Q",3),AVSX3("W3_SALDO_Q",4)})
AADD(aSemSX3SW3,{"W3_SLDCONV","N",AVSX3("W3_SALDO_Q",3),AVSX3("W3_SALDO_Q",4)})
AADD(aSemSX3SW3,{"W3_POSICAO","C",AVSX3("W3_POSICAO",3),0})
AADD(aSemSX3SW3,{"W3_PGI_NUM","C",AVSX3("W3_PGI_NUM",3),0})
AADD(aSemSX3SW3,{"W3_RECNO" ,"N",10,0})
//TRP - 03/02/07 - Campos do WalkThru
AADD(aSemSX3SW3,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3SW3,{"TRB_REC_WT","N",10,0})


If(EasyEntryPoint("EDCAN400"),ExecBlock("EDCAN400",.F.,.F.,"aSemSX3"),)

IncProc(STR0005) //"Inicializando Ambiente"
aSelCpos:={   {"MARCA"     ,,""},;
              {"W3_COD_I"  ,,AVSX3("W3_COD_I",5),AVSX3("W3_COD_I",6)},;
              {"W3_SI_NUM" ,,AVSX3("W3_SI_NUM",5),AVSX3("W3_SI_NUM",6)},;
              {"W3_CC"     ,,AVSX3("W3_CC",5),AVSX3("W3_CC",6)},;
              {"W3_QTDE"   ,,AVSX3("W3_QTDE",5),AVSX3("W3_QTDE",6)},;
              {"W3_SALDO_Q",,AVSX3("W3_SALDO_Q",5),AVSX3("W3_SALDO_Q",6)},;
              {"W3_SLDCONV",,"Qtde. p/ Anuencia",AVSX3("W3_SALDO_Q",6)},;
              {"W3_POSICAO",,AVSX3("W3_POSICAO",5),AVSX3("W3_POSICAO",6)} }

If(EasyEntryPoint("EDCAN400"),ExecBlock("EDCAN400",.F.,.F.,"aSelCpos"),)

Return .T.

*-------------------*
Function AN400Works()
*-------------------*
Local FileWork1, FileWork2
//Private aHeader[0], aCampos:={}//Array(SW3->(fCount())) //E_CriaTrab utiliza

ProcRegua(3)

//WorkSW3
IncProc(STR0009) //"Criando Arquivo Temporario"
FileWork1:=E_CriaTrab(,aSemSX3SW3,"WorkSW3")
Aadd(aTabelas,{"WorkSW3",FileWork1})
FileWork2:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork2})

IncProc(STR0010+"1") //"Criando Indice Temporario "
IndRegua("WorkSW3",FileWork1+TEOrdBagExt(),"W3_COD_I")
IncProc(STR0010+"2") //"Criando Indice Temporario "
IndRegua("WorkSW3",FileWork2+TEOrdBagExt(),"W3_PO_NUM+W3_POSICAO")

SET INDEX TO (FileWork1+TEOrdBagExt()),(FileWork2+TEOrdBagExt())

Return .T.

*---------------------------------*
Static Function AN400GrvWorks(nOpc)
*---------------------------------*
Local lGrv:=.T.
ProcRegua(1)

//WorkSW3
IncProc(STR0011) //"Processando..."
SW5->(dbSetOrder(8))
dbSelectArea("SW3")
SW3->(dbSetOrder(8))
If SW3->(dbSeek(cFilSW3+SW2->W2_PO_NUM))
   Do While !SW3->(EOF()) .and. SW3->W3_FILIAL==cFilSW3 .and. SW3->W3_PO_NUM==SW2->W2_PO_NUM
   
      If nOpc = 2
         If SW3->W3_SEQ = 0 .and. SW3->W3_SALDO_Q > 0 .and. SW3->W3_FLUXO = "1"
            WorkSW3->(RecLock("WorkSW3",.T.))
            WorkSW3->W3_COD_I   := SW3->W3_COD_I
            WorkSW3->W3_SI_NUM  := SW3->W3_SI_NUM
            WorkSW3->W3_CC      := SW3->W3_CC
            WorkSW3->W3_PO_NUM  := SW3->W3_PO_NUM
            WorkSW3->W3_QTDE    := SW3->W3_QTDE
            WorkSW3->W3_SALDO_Q := SW3->W3_SALDO_Q
            WorkSW3->W3_SALDO_O := SW3->W3_SALDO_Q
            WorkSW3->W3_SLDCONV := 0
            WorkSW3->W3_POSICAO := SW3->W3_POSICAO
            WorkSW3->W3_RECNO   := SW3->(RECNO())
            WorkSW3->TRB_ALI_WT := "SW3"
            WorkSW3->TRB_REC_WT := SW3->(Recno())
            WorkSW3->(msUnlock())
         EndIf
      Else
         lGrv := .T.
         If SW3->W3_SEQ > 0 .and. SW3->W3_FLUXO = "7"
            SW5->(dbSeek(cFilSW5+SW3->W3_PGI_NUM+SW3->W3_PO_NUM+SW3->W3_POSICAO))
            Do While !SW5->(EOF()) .and. SW5->W5_FILIAL == cFilSW5 .and. SW5->W5_PGI_NUM==SW3->W3_PGI_NUM .and.;
            SW5->W5_PO_NUM==SW3->W3_PO_NUM .and. SW5->W5_POSICAO==SW3->W3_POSICAO
               If SW5->W5_SEQ > 0
                  lGrv := .F.
                  Exit
               EndIf
               SW5->(dbSkip())
            EndDo
            If lGrv
               WorkSW3->(RecLock("WorkSW3",.T.))
               WorkSW3->W3_COD_I   := SW3->W3_COD_I
               WorkSW3->W3_SI_NUM  := SW3->W3_SI_NUM
               WorkSW3->W3_CC      := SW3->W3_CC
               WorkSW3->W3_PO_NUM  := SW3->W3_PO_NUM
               WorkSW3->W3_QTDE    := SW3->W3_QTDE
               WorkSW3->W3_SALDO_Q := SW3->W3_SALDO_Q
               WorkSW3->W3_SALDO_O := SW3->W3_SALDO_Q
               WorkSW3->W3_SLDCONV := 0
               WorkSW3->W3_POSICAO := SW3->W3_POSICAO
               WorkSW3->W3_PGI_NUM := SW3->W3_PGI_NUM
               WorkSW3->W3_RECNO   := SW3->(RECNO())
               WorkSW3->(msUnlock())
            EndIf
         
            //TRP - 05/03/2010 - Tratamento para Multi-usuário no estorno da Anunência Automática.
            SW4->(DbSetOrder(1))
            If SW4->(DbSeek(xFilial("SW4") + WorkSW3->W3_PGI_NUM))
               If !SoftLock("SW4")
                  MsgInfo("Registro está sendo utilizado por outro usuário!")
                  Exit
               Endif
            Endif    
         
         EndIf
      EndIf

      SW3->(dbSkip())
   EndDo
   WorkSW3->(dbGoTop())
EndIf

SW3->(dbSetOrder(1))

Return .T.

*-----------------------------*
Static Function AN400DelWorks()
*-----------------------------*
Local W

FOR W := 1 TO LEN(aTabelas)
   If !Empty(aTabelas[W,1])
      (aTabelas[W,1])->(E_EraseArq(aTabelas[W,2]))
   Else
      FErase(aTabelas[W,2]+TEOrdBagExt())
   EndIf
NEXT
aTabelas:={}

dbSelectArea("SW2")

Return .T.

*----------------------------*
Static Function LimpaTabelas()
*----------------------------*
Local W

ProcRegua(Len(aTabelas))

FOR W := 1 TO LEN(aTabelas)
   IncProc(STR0009+Alltrim(Str(W))) //"Criando Arquivo Temporario "
   If !Empty(aTabelas[W,1])
      (aTabelas[W,1])->(avzap())
   EndIf
NEXT

Return .T.

*------------------------*
Static Function AN400Cad()
*------------------------*
Local nOp:=0
Private nSaldo := WorkSW3->W3_SALDO_Q

DEFINE MSDIALOG oDlg TITLE STR0012 ; //"Entre com o Saldo para Anuencia Automatica"
       FROM 12,08 TO 20,50 OF GetWndDefault()

   @03,02 SAY  "Qtde. p/ Anuencia" of oDlg
   @03,08 MSGET nSaldo PICT AVSX3("W3_SALDO_Q",6) VALID AN400Valid("W3_SLDCONV") SIZE 60,8

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOp:=1,oDlg:End()},{||nOp:=0,oDlg:End()}) CENTERED

If nOp=1
   WorkSW3->(RecLock("WorkSW3",.F.))
   WorkSW3->W3_SLDCONV := nSaldo
   WorkSW3->MARCA      := cMarca
   WorkSW3->W3_SALDO_Q := WorkSW3->W3_SALDO_O - nSaldo
   WorkSW3->(msUnlock())
EndIf

Return .T.

*-------------------------------------*
Static Function AN400Marca(lTodos,nOpc)
*-------------------------------------*
If !lTodos
   If WorkSW3->MARCA<>cMarca
      If nOpc = 2
         AN400Cad()
      Else
         WorkSW3->MARCA := cMarca
      EndIf
   Else
      If nOpc = 2
         WorkSW3->(RecLock("WorkSW3",.F.))
         WorkSW3->MARCA      := ""
         WorkSW3->W3_SLDCONV := 0
         WorkSW3->W3_SALDO_Q := WorkSW3->W3_SALDO_O
         WorkSW3->(msUnlock())
      Else
         WorkSW3->MARCA := ""
      EndIf
   EndIf
Else
   WorkSW3->(dbGoTop())   
   If WorkSW3->MARCA<>cMarca
      Do While !WorkSW3->(EOF())
         If WorkSW3->MARCA<>cMarca
            If nOpc = 2
               WorkSW3->(RecLock("WorkSW3",.F.))
               WorkSW3->MARCA      := cMarca
               WorkSW3->W3_SLDCONV := WorkSW3->W3_SALDO_O
               WorkSW3->W3_SALDO_Q := 0
               WorkSW3->(msUnlock())
            Else
               WorkSW3->MARCA := cMarca
            EndIf
         EndIf
         WorkSW3->(dbSkip())
      EndDo
   Else
      Do While !WorkSW3->(EOF())
         If WorkSW3->MARCA == cMarca
            If nOpc = 2
               WorkSW3->(RecLock("WorkSW3",.F.))
               WorkSW3->MARCA      := ""
               WorkSW3->W3_SLDCONV := 0
               WorkSW3->W3_SALDO_Q := WorkSW3->W3_SALDO_O
               WorkSW3->(msUnlock())
            Else
               WorkSW3->MARCA := ""
            EndIf
         EndIf
         WorkSW3->(dbSkip())
      EndDo
   EndIf
EndIf

/* ISS - 22/03/10 - "Refresh" no MsSelect para que o mesmo mostre imediatamente os registros marcados e desmarcados
                     ao usar a opção "Marca/Desmarca Todos".*/
WorkSW3->(DbGoTop())
oMark:oBrowse:Refresh()

Return .T.

*--------------------------------*
Static Function AN400Valid(cCampo)
*--------------------------------*
Local lRet:=.T.

Do Case
   Case cCampo=="W3_SLDCONV"
      If !Positivo(nSaldo)
         lRet := .F.
      ElseIf nSaldo > WorkSW3->W3_SALDO_O
         nSaldo := WorkSW3->W3_SALDO_O
         Help(" ",1,"AVG0005188",,Trans(WorkSW3->W3_SALDO_O,AVSX3("W3_SALDO_Q",6)),2,20) //MsgInfo(STR0013+Trans(WorkSW3->W3_SALDO_O,AVSX3("W3_SALDO_Q",6)))
         lRet := .F.
      EndIf
EndCase

Return lRet

*----------------------------*
Static Function GeraAnuencia()
*----------------------------*
Local nSeqLI
LOCAL lRet
lRet := .f.

ProcRegua(WorkSW3->(EasyRecCount()))
WorkSW3->(dbGoTop())

//IF !SetMV("MV_SEQ_LI",STRZERO(EasyGParam("MV_SEQ_LI")+1,8,0))
//   Help(" ",1,"AVG0005189") //MsgInfo(STR0017) //"Geracao nao pode ser concluida devido a problema na gravacao da sequencia."   
//Else
   nSeqLi :="*"+EasyGetMVSeq("MV_SEQ_LI")+"*"

   Do While !WorkSW3->(EOF())
      IncProc("Lendo item: "+Alltrim(WorkSW3->W3_COD_I)) //"Lendo item: "
   
      If WorkSW3->MARCA == cMarca

         SW3->(dbGoTo(WorkSW3->W3_RECNO))
         SW3->(RecLock("SW3",.F.))
         SW3->W3_SALDO_Q := WorkSW3->W3_SALDO_Q
         SW3->(msUnlock())

         GrvCapaLI(nSeqLI)
         GrvItensLI(nSeqLI)
         GrvSaidaSW3(nSeqLI)
         lRet := .t.
         
      EndIf
      WorkSW3->(dbSkip())
   EndDo
//Endif      

Return lRet
*------------------------*
FUNCTION GrvCapaLI(nSeqLI)
*------------------------*

IF ! SW4->(DbSeek(cFilSW4+nSeqLI))
   SW4->(RecLock("SW4",.T.))
ELSE
   SW4->(RecLock("SW4",.F.))
ENDIF

SW4->W4_FILIAL  := cFilSW4
SW4->W4_GI_NUM  := nSeqLI
SW4->W4_PGI_NUM := nSeqLI
SW4->W4_PGI_DT  := dDataBase
SW4->W4_IMPORT  := SW2->W2_IMPORT
SW4->W4_CONSIG  := SW2->W2_CONSIG
SW4->W4_FLUXO   := "7"  // 1 - GFC 06/05/04
SW4->W4_DTEDCEX := SW2->W2_PO_DT
SW4->W4_DTSDCEX := SW2->W2_PO_DT
SW4->W4_MOEDA   := SW2->W2_MOEDA
SW4->W4_EMITIDA := "S"
SW4->W4_INLAND  := SW2->W2_INLAND
SW4->W4_FRETEIN := SW2->W2_FRETEIN
SW4->W4_PACKING := SW2->W2_PACKING
SW4->W4_DESCONT := SW2->W2_DESCONT
SW4->W4_OUT_DES := SW2->W2_OUT_DES
SW4->W4_FOB_TOT := SW2->W2_FOB_TOT
SW4->(MsUnlock())

Return .T.

*-------------------------*
FUNCTION GrvItensLI(nSeqLI)
*-------------------------*
SW5->(RecLock("SW5",.T.))

SW5->W5_COD_I   := SW3->W3_COD_I
SW5->W5_FABR    := SW3->W3_FABR
SW5->W5_FABLOJ  := SW3->W3_FABLOJ //LRS - 10/05/2017
SW5->W5_FABR_01 := SW3->W3_FABR_01
SW5->W5_FABR_02 := SW3->W3_FABR_02
SW5->W5_FABR_03 := SW3->W3_FABR_03
SW5->W5_FABR_04 := SW3->W3_FABR_04
SW5->W5_FABR_05 := SW3->W3_FABR_05
SW5->W5_FORN    := SW3->W3_FORN
SW5->W5_FORLOJ  := SW3->W3_FORLOJ //LRS - 10/05/2017
SW5->W5_FLUXO   := "7" // 1 - GFC 06/05/04
SW5->W5_QTDE    := WorkSW3->W3_SLDCONV
SW5->W5_PRECO   := SW3->W3_PRECO
SW5->W5_SALDO_Q := WorkSW3->W3_SLDCONV
SW5->W5_SI_NUM  := SW3->W3_SI_NUM
SW5->W5_PO_NUM  := SW3->W3_PO_NUM
SW5->W5_PGI_NUM := nSeqLI
SW5->W5_DT_EMB  := SW3->W3_DT_EMB
SW5->W5_DT_ENTR := SW3->W3_DT_ENTR
SW5->W5_SEQ     := 0
SW5->W5_CC      := SW3->W3_CC
SW5->W5_REG     := SW3->W3_REG
SW5->W5_POSICAO := SW3->W3_POSICAO
SW5->W5_FILIAL  := cFilSW5
SB1->(dbSeek(xFilial("SB1")+SW3->W3_COD_I))
SW5->W5_PESO    := SB1->B1_PESO

SW5->(MsUnlock())

Return .T.

*--------------------------*
FUNCTION GrvSaidaSW3(nSeqLI)
*--------------------------*
Local MSeq, i

dbSelectArea("SW3")
FOR i := 1 TO SW3->(FCount())
   M->&(FIELDNAME(i)) := FieldGet(i)
NEXT i

MSeq:= BuscaSeq_W3()
SW3->(RecLock("SW3",.T.))

SW3->W3_COD_I   := M->W3_COD_I
SW3->W3_FLUXO   := "7" // 1 - GFC 06/05/04
SW3->W3_QTDE    := WorkSW3->W3_SLDCONV
SW3->W3_PRECO   := M->W3_PRECO
SW3->W3_SALDO_Q := 0
SW3->W3_SI_NUM  := M->W3_SI_NUM
SW3->W3_PO_NUM  := M->W3_PO_NUM
SW3->W3_PGI_NUM := nSeqLI
SW3->W3_DT_EMB  := M->W3_DT_EMB
SW3->W3_DT_ENTR := M->W3_DT_ENTR
SW3->W3_SEQ     := MSeq
SW3->W3_CC      := M->W3_CC
SW3->W3_FABR    := M->W3_FABR
SW3->W3_FABR_01 := M->W3_FABR_01
SW3->W3_FABR_02 := M->W3_FABR_02
SW3->W3_FABR_03 := M->W3_FABR_03
SW3->W3_FABR_04 := M->W3_FABR_04
SW3->W3_FABR_05 := M->W3_FABR_05
SW3->W3_FORN    := M->W3_FORN
SW3->W3_REG     := M->W3_REG
SW3->W3_POSICAO := M->W3_POSICAO
SW3->W3_REG_TRI := M->W3_REG_TRI
SW3->W3_FILIAL := cFilSW3

SW3->(MsUnlock())

Return .T.

*---------------------------*
Static Function BuscaSeq_W3()
*---------------------------*
Local nSeq := 1

SW3->(dbSkip())
Do While !SW3->(EOF()) .and. SW3->W3_FILIAL==cFilSW3 .and. SW3->W3_PO_NUM==M->W3_PO_NUM .and. ;
SW3->W3_POSICAO==M->W3_POSICAO
   nSeq := SW3->W3_SEQ + 1
   SW3->(dbSkip())
EndDo

Return nSeq

*------------------------------*
Static Function ExcluiAnuencia()
*------------------------------*
Local lRet

lRet := .f.

SW5->(dbSetOrder(8))
SW4->(dbSetOrder(1))
SW3->(dbSetOrder(8))

ProcRegua(WorkSW3->(EasyRecCount()))
WorkSW3->(dbGoTop())

Do While !WorkSW3->(EOF())
   IncProc(STR0021) //"Excluindo Anuência(s)"
   
   If WorkSW3->MARCA == cMarca

      SW3->(dbSeek(cFilSW3+WorkSW3->W3_PO_NUM+WorkSW3->W3_POSICAO))
      Do While !SW3->(EOF()) .and. SW3->W3_FILIAL==cFilSW3 .and. SW3->W3_PO_NUM==WorkSW3->W3_PO_NUM .and.;
      SW3->W3_POSICAO==WorkSW3->W3_POSICAO .and. SW3->W3_SEQ <> 0
         SW3->(dbSkip())
      EndDo
      If !SW3->(EOF()) .and. SW3->W3_FILIAL==cFilSW3 .and. SW3->W3_PO_NUM==WorkSW3->W3_PO_NUM .and.;
      SW3->W3_POSICAO==WorkSW3->W3_POSICAO .and. SW3->W3_SEQ = 0
         SW3->(RecLock("SW3",.F.))
         SW3->W3_SALDO_Q += WorkSW3->W3_QTDE
         SW3->(msUnlock())
      EndIf
      
      If SW5->(dbSeek(cFilSW5+WorkSW3->W3_PGI_NUM+WorkSW3->W3_PO_NUM+WorkSW3->W3_POSICAO))
         SW5->(RecLock("SW5",.F.,.T.))
         SW5->(DBDELETE())
         SW5->(msUnlock())
      EndIf
      
      If !SW5->(dbSeek(cFilSW5+WorkSW3->W3_PGI_NUM+WorkSW3->W3_PO_NUM+WorkSW3->W3_POSICAO)) .and.;
      SW4->(dbSeek(cFilSW4+WorkSW3->W3_PGI_NUM))
         SW4->(RecLock("SW4",.F.,.T.))
         SW4->(DBDELETE())
         SW4->(msUnlock())
      EndIf
      
      SW3->(dbGoTo(WorkSW3->W3_RECNO))
      SW3->(RecLock("SW3",.F.,.T.))
      SW3->(DBDELETE())
      SW3->(msUnlock())

      lRet := .t.
         
   EndIf
   WorkSW3->(dbSkip())
EndDo

Return lRet
