
#INCLUDE "EDCCE400.ch"
#include "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"

#define VISUALIZAR 2
#define INCLUIR    3
#define ALTERAR    4
#define ESTORNAR   5
#define GENERICO     "06"
#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define NCM_GENERICA "99999999"

/*
Programa        : EDCCE400.PRW
Objetivo        : Manutenção de Comprovação Externa
Autor           : Gustavo Carreiro - GFC
Data/Hora       :
Obs.            :
*/

*-----------------------------------------------------------------------------------------------*
Function EDCCE400()
*-----------------------------------------------------------------------------------------------*
Private aBotoes:={}, aBotoes2:={}, aTabelas:={}
Private cCadastro := STR0001 //"Manutencao de Comprovação Externa "
Private cFilED9:=xFilial("ED9"), cFilSA2:=xFilial("SA2"), cFilSB1:=xFilial("SB1")
Private cFilED0:=xFilial("ED0"), cFilED8:=xFilial("ED8"), cFilSYT:=xFilial("SYT")
Private cFilED3:=xFilial("ED3"), cFilED4:=xFilial("ED4")
Private cNomArq, cNomArq1, cNomArq2, cNomArq3, cCnpj:= Space(Len(SYT->YT_CGC))
Private cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1" //Para utilizar produtos de outra Empresa/Filial
Private lAbriuExp := lInverte := .F. , cMarca := GetMark()
Private lTop := .F., cFilSA2Aux:=cFilSA2, aSelCpos9 := aSelCpos8 := {}
Private lAcMod:=.T. //Defice se os campos AC e SEQSIS poderão ser alterados
Private lMUserEDC := FindFunction("EDCMultiUser")
Private aSaldoAC := {} // By JPP - 14/11/2007 - 14:00
Private aRotina := MenuDef()
Private cOrigem := "EDCCE400"
If lMUserEDC
   Private oMUserEDC := EDCMultiUser():Novo()
EndIf
#IFDEF TOP
   lTop := .T.
#ENDIF

If !AvFlags("INDICEED9")
   Return .F.
EndIf

If AmIin(50)
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

   Private lAbriuSA2 := AbreArqExp("SA2",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))),cFilSA2Aux) // Abre arq. SA2 de outra Empresa/Filial de acordo com os parametros.
   If lAbriuSA2
      cFilSA2Aux   := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
      If(Empty(Alltrim(cFilSA2Aux)),cFilSA2Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
   Endif

   Processa({|| CE400Works()}, STR0004) //"Inicializando Ambiente"

   ED0->(dbSetOrder(1))
   mBrowse(,,,,"ED0")

   CE400DelWorks()

   If lAbriuSA2
      FechaArqExp("SA2",.T.)
   Endif

EndIf

Return .T.

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 01/02/07 - 10:02
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := {}

AADD(aRotina,{ STR0002 ,"AxPesqui"    ,0,1}) //"Pesquisar"
AADD(aRotina,{ STR0003 ,"EDCCE400Man" ,0,2}) //"Manutenção"

If(EasyEntryPoint("EDCCE400"),ExecBlock("EDCSE400",.F.,.F.,"MBROWSE"),)

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("DCE400MNU")
	aRotAdic := ExecBlock("DCE400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

*-----------------------------------------------------------------------------------------------*
Function EDCCE400Man(cAlias,nReg,nOpc)
*-----------------------------------------------------------------------------------------------*
Local oDlg, bOk := {||nOpcao:=1,oDlg:End()}, i
Local nInd, nOpcao:=0, bCancel := {||nOpcao:=0,oDlg:End()}, nTela
Local oFld, oFldAC, oFldED8, oFldED9

Local bHide    := {|nTela| If(nTela==3,oMark2:oBrowse:Hide(),;// By JPP - 14/11/2007 - 14:00
                           If(nTela==4,oMark:oBrowse:Hide(),)) }
                           
                          
Local bBarras := {||CE400Bar(oFldAC ,{||If(Obrigatorio(aGets,aTela),Eval(bOk),)},{||If(MsgYesNo("Deseja Realmente Sair?"+Chr(13)+Chr(10)+"Todas as alteracoes serao perdidas."),Eval(bCancel),)}),; // By JPP - 14/11/2007 - 14:00
                    CE400Bar(oFldAC2,{||If(Obrigatorio(aGets,aTela),Eval(bOk),)},{||If(MsgYesNo("Deseja Realmente Sair?"+Chr(13)+Chr(10)+"Todas as alteracoes serao perdidas."),Eval(bCancel),)}),;
                    CE400Bar(oFldED9,{||If(Obrigatorio(aGets,aTela),Eval(bOk),)},{||If(MsgYesNo("Deseja Realmente Sair?"+Chr(13)+Chr(10)+"Todas as alteracoes serao perdidas."),Eval(bCancel),)},,aBotoes),;
                    CE400Bar(oFldED8,{||If(Obrigatorio(aGets,aTela),Eval(bOk),)},{||If(MsgYesNo("Deseja Realmente Sair?"+Chr(13)+Chr(10)+"Todas as alteracoes serao perdidas."),Eval(bCancel),)},,aBotoes2) }

Local bHideAll := {|| Eval(bHide,3), Eval(bHide,4) }

Local bShow := {|nTela,o| if(nTela=3,WorkED9->(dbGoTop()),;
                          if(nTela=4,WorkED8->(dbGoTop()),)),;    //o := if(nTela=3,oMark2,oMark):oBrowse,;
                          o := if(nTela=3,oMark2,oMark):oBrowse,; //o := oMark:oBrowse,; // By JPP - 14/11/2007 - 14:00
                          o:Show(),o:SetFocus() }

Private oMark, oMark2,oEnch, oBtnOk, oBtnCan, oFldAC2 // By JPP - 14/11/2007 - 14:00
Private aHeader := {}, aCAMPOS := ARRAY(0), aDelWkED8:={}, aDelWkED9:={}, oFont, aButtons:= {}

If !CE400Valid("MANUTENCAO")
   Return .T.
EndIf

oMainWnd:ReadClientCoords()//So precisa declarar uma vez para o programa todo

Processa({|| LimpaTabelas() },STR0004) //"Inicializando Ambiente"
dbSelectArea("ED0")
aGets:={}
aTela:={}

//Inicializa Variáveis
If nOpc <> INCLUIR
   cCadastro+=Alltrim(ED0->ED0_AC)
   FOR i := 1 TO FCount()
      M->&(FIELDNAME(i)) := FieldGet(i)
   NEXT i
   IF !EMPTY(ED0->ED0_OBS)
      M->ED0_VM_OBS:= MSMM(ED0->ED0_OBS,60)
   ENDIF
Endif

nOpcao:=0

DEFINE MSDIALOG oDlg TITLE cCadastro FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO ;
oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

   nLinha := (oDlg:nClientHeight-4)/2
   oFld := TFolder():New(1,1,{STR0030,STR0031,STR0032,STR0033},{"AC","CNPJ","EXP","IMP"},oDlg,,,,.T.,.F.,COLUNA_FINAL,nLinha) // "&Ato Concessório"#"&CNPJ Auxiliares"#"&Exportação"#"&Importação" // By JPP - 14/11/2007 - 14:00
   //oFld := TFolder():New(1,1,{STR0030,STR0031,STR0033},{"AC","CNPJ","IMP"},oDlg,,,,.T.,.F.,COLUNA_FINAL,nLinha) // "&Ato Concessório"#"&CNPJ Auxiliares"#"&Exportação"#"&Importação" // By JPP - 14/11/2007 - 14:00

   aEval(oFld:aControls,{|x| x:SetFont(oDlg:oFont) })
   oFldAC  := oFld:aDialogs[1]
   oFldAC2 := oFld:aDialogs[2]
   oFldED9 := oFld:aDialogs[3]
   oFldED8 := oFld:aDialogs[4] //3] // By JPP - 14/11/2007 - 14:00

   // Folder Capa do Ato Concessório
   oEnch:=MsMget():New(cAlias,nReg,nOpc,,,,,{15,1,(oFldAC:nClientHeight-4)/2,COLUNA_FINAL},,3,,,,oFldAC) //LRL 30/04/04

   // Folder CNPJ Auxiliares
   CE400CNPJ(nOpc)

   // Folder Exportação
   // By JPP - 14/11/2007 - 14:00
   nLinha := (oDlg:nClientHeight-6)/2
   oMark2:= MsSelect():New("WorkED9",,,aSelCpos9,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL},,,oFldED9)    //LRL 30/04/04
   oMark2:oBrowse:bWhen:={|| DBSELECTAREA("WorkED9"),.T.}
   oMark2:bAval:={||CE400PEManut(4),WorkED9->(dbGoTop())}
   
   // Folder Importação
   nLinha := (oDlg:nClientHeight-6)/2
   oMark:= MsSelect():New("WorkED8",,,aSelCpos8,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL},,,oFldED8)   //LRL 30/04/04
   oMark:oBrowse:bWhen:={|| DBSELECTAREA("WorkED8"),.T.}
   oMark:bAval:={||CE400PIManut(4),WorkED8->(dbGoTop())}

   Set Filter To
   Processa({|| CE400GrvWorks()}, STR0007) //"Gravando Arquivos Temporarios"

   //Utilizado para a Manutenção dos Itens(ED9)
   AADD(aRotina,{ STR0008  ,"EDCCE400Man" ,0,3}) //"Incluir"
   AADD(aRotina,{ STR0009  ,"EDCCE400Man" ,0,4}) //"Alterar"
   AADD(aRotina,{ STR0010  ,"EDCCE400Man" ,0,5}) //"Estornar"

   Aadd(aBotoes,{"EDIT"    ,{|| CE400PEManut(3), SetKEY(15,oBtnOk:bAction), SetKEY(24,oBtnCan:bAction) }, STR0008,nil}) //"Incluir"
   Aadd(aBotoes,{"IC_17"   ,{|| CE400PEManut(4), SetKEY(15,oBtnOk:bAction), SetKEY(24,oBtnCan:bAction) }, STR0009,nil}) //"Alterar"
   Aadd(aBotoes,{"EXCLUIR" ,{|| CE400PEManut(5), SetKEY(15,oBtnOk:bAction), SetKEY(24,oBtnCan:bAction) }, STR0011,nil}) //"Excluir"
   Aadd(aBotoes,{"BMPCPO"  ,{|| CE400Filtro("ED9"), SetKEY(15,oBtnOk:bAction), SetKEY(24,oBtnCan:bAction) }, STR0012,STR0039}) //"Selecionar Filtro" ,//LRL -17/05/04 "Filtro"

   Aadd(aBotoes2,{"EDIT"    ,{|| CE400PIManut(3), SetKEY(15,oBtnOk:bAction), SetKEY(24,oBtnCan:bAction) }, STR0008,Nil}) //"Incluir"
   Aadd(aBotoes2,{"IC_17"   ,{|| CE400PIManut(4), SetKEY(15,oBtnOk:bAction), SetKEY(24,oBtnCan:bAction) }, STR0009,Nil}) //"Alterar"
   Aadd(aBotoes2,{"EXCLUIR" ,{|| CE400PIManut(5), SetKEY(15,oBtnOk:bAction), SetKEY(24,oBtnCan:bAction) }, STR0011,Nil}) //"Excluir"
   Aadd(aBotoes2,{"BMPCPO"  ,{|| CE400Filtro("ED8"), SetKEY(15,oBtnOk:bAction), SetKEY(24,oBtnCan:bAction) }, STR0012,STR0039}) //"Selecionar Filtro" //LRL -17/05/04 "Filtro"
   
   WorkED8->(DBSETFILTER({||.T. }, ".T."))
   WorkED9->(DBSETFILTER({||.T. }, ".T."))

   Eval(bHideAll)

   oFld:bChange := {|nOption,nOldOption| Eval(bHide,nOldOption),;
                   IF(nOption<>1 .and. nOption<>2,Eval(bShow,nOption),) }
   oDlg:lMaximized:=.T. //LRL 30/04/04 - Maximiliza Janela
   
   
   oFld:Align:=CONTROL_ALIGN_ALLCLIENT          //
   oEnch:oBox:Align:=CONTROL_ALIGN_ALLCLIENT    //  LRL 30/04/04
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT  //  Alinhamento MDI // By JPP - 14/11/2007 - 14:00
   oMark2:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT  //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
ACTIVATE MSDIALOG oDlgA ON INIT ((Eval(bBarras)), oMainWnd:Hide(),;
                                                  oMainWnd:Show(),;
                                                  EnchoiceBar(oDlg, {||If(Obrigatorio(aGets,aTela),Eval(bOk),)},{||If(MsgYesNo("Deseja Realmente Sair?"+Chr(13)+Chr(10)+"Todas as alteracoes serao perdidas."),Eval(bCancel),)},, @aButtons))


If nOpcao = 1
   dbSelectArea("ED0")
   Processa({|| CE400GrvGeral()}, STR0036) //"Gravando Comprovação Externa"
EndIf

If lMUserEDC
   oMUserEDC:Fim()  // PLB 27/11/06 - Solta registros presos e reinicializa objeto
EndIf
aBotoes:={}
aBotoes2:={}
cCadastro := STR0001 //"Manutencao de Comprovação Externa"
//msUnlockAll()

Return .T.

*------------------------------------------------------------------------------------------------*
Function CE400Works()
*------------------------------------------------------------------------------------------------*
Local FileWork1, FileWork2, FileWork3, FileWork4, FileWork5, FileWork6
Local aSemSX3ED9:={}, aSemSX3ED8:={}
Private aHeader[0], aCampos:=Array(ED0->(fCount()))  //E_CriaTrab utiliza

ProcRegua(2)

AADD(aSemSX3ED9,{"ED9_RECNO","N",6,0})
AADD(aSemSX3ED9,{"ED9_QT_AC","N",AVSX3("ED9_QT_AC",3),AVSX3("ED9_QT_AC",4)}) // By JPP - 14/11/2007 - 14:00
AADD(aSemSX3ED9,{"ED9_VL_AC","N",AVSX3("ED9_VL_AC",3),AVSX3("ED9_VL_AC",4)}) // By JPP - 14/11/2007 - 14:00
//AADD(aSemSX3ED9,{"ED9_AC","C",AVSX3("ED9_AC",3),0}) // By JPP - 14/11/2007 - 14:00

If ED9->(FieldPos("ED9_FASEDR")) > 0  
   AADD(aSemSX3ED9,{"ED9_FASEDR",AVSX3("ED9_FASEDR",2),AVSX3("ED9_FASEDR",3),AVSX3("ED9_FASEDR",4)}) // By JPP - 14/11/2007 - 14:00
EndIf

//AADD(aSemSX3ED8,{"ED8_DESCIM","C",AvSx3("ED8_DESCIM",3),0})
AADD(aSemSX3ED8,{"ED8_RECNO" ,"N",6,0})
AADD(aSemSX3ED8,{"ED8_DES_DI" ,"C",6,0})

AADD(aSemSX3ED8,{"ED8_QT_AC","N",AVSX3("ED8_QT_AC",3),AVSX3("ED8_QT_AC",4)})
AADD(aSemSX3ED8,{"ED8_VL_AC","N",AVSX3("ED8_VL_AC",3),AVSX3("ED8_VL_AC",4)})
AADD(aSemSX3ED8,{"ED8_ACISEN","C",AVSX3("ED8_ACISEN",3),AVSX3("ED8_ACISEN",4)})

//AAF 14/08/06 - Verifica se o campo é usado antes de adicionar no array.
If !X3Uso(Posicione("SX3",2,"ED8_SE_USS","X3_USADO"))
   AADD(aSemSX3ED8,{"ED8_SE_USS","N",AVSX3("ED8_SE_USS",3),AVSX3("ED8_SE_USS",4)})
EndIf

//TRP - 03/02/07 - Campos do WalkThru
AADD(aSemSX3ED8,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3ED8,{"TRB_REC_WT","N",10,0})

//AADD(aSemSX3ED8,{"ED8_VL_AC","N",AVSX3("ED8_VL_AC",3),AVSX3("ED8_VL_AC",4)})
//AADD(aSemSX3ED8,{"ED8_AC","C",AVSX3("ED8_AC",3),0})

//WorkED9
IncProc(STR0034+"1") //"Criando Arquivo Temporário - "

aAdd(aSemSX3ED9,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
FileWork1:=E_CriaTrab("ED9",aSemSX3ED9,"WorkED9")

Aadd(aTabelas,{"WorkED9",FileWork1})
FileWork2:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork2})
FileWork3:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork3})

aSelCpos9 := Browse_Cpos("ED9","WorkED9")

IndRegua("WorkED9",FileWork1+TEOrdBagExt(),"ED9_EXPORT+ED9_RE")
IndRegua("WorkED9",FileWork2+TEOrdBagExt(),"ED9_EXPORT")
//IndRegua("WorkED9",FileWork3+OrdBagExt(),"ED9_RE")    

//SET INDEX TO (FileWork1+OrdBagExt()),(FileWork2+OrdBagExt()),(FileWork3+OrdBagExt())
SET INDEX TO (FileWork1+TEOrdBagExt()),(FileWork2+TEOrdBagExt())

//WorkED8
IncProc(STR0034+"2") //"Criando Arquivo Temporário - "

aAdd(aSemSX3ED8,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
FileWork4:=E_CriaTrab("ED8",aSemSX3ED8,"WorkED8")

Aadd(aTabelas,{"WorkED8",FileWork4})
FileWork5:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork5})
FileWork6:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork6})

aSelCpos8 := Browse_Cpos("ED8","WorkED8")

IndRegua("WorkED8",FileWork4+TEOrdBagExt(),"ED8_CNPJIM+ED8_DI_NUM")
IndRegua("WorkED8",FileWork5+TEOrdBagExt(),"ED8_CNPJIM")
//IndRegua("WorkED8",FileWork6+OrdBagExt(),"ED8_DI_NUM")

//SET INDEX TO (FileWork4+OrdBagExt()),(FileWork5+OrdBagExt()),(FileWork6+OrdBagExt())
SET INDEX TO (FileWork4+TEOrdBagExt()),(FileWork5+TEOrdBagExt())

Return .T.

*----------------------------------------------------------------------------------------------*
Static Function CE400GrvWorks()
*----------------------------------------------------------------------------------------------*
Local ED9TotCpos:=ED9->(FCount()), ED8TotCpos:=ED8->(FCount()), cCampo, i

ProcRegua(2)

//WorkED8
IncProc(STR0014) //"Processando..."
dbSelectArea("ED8")
ED8->(dbSetOrder(3))
If ED8->(dbSeek(cFilED8+ED0->ED0_AC))
   Do While !ED8->(EOF()) .And. ED8->ED8_FILIAL==cFilED8 .And. ED8->ED8_AC == ED0->ED0_AC
      WorkED8->(RecLock("WorkED8",.T.))
      FOR i := 1 TO ED8TotCpos
         cCampo:=FIELDNAME(i)
         WorkED8->&(cCampo) := ED8->&(cCampo)
      NEXT i
      WorkED8->ED8_DES_DI:=ED8->ED8_DES_DI
      WorkED8->ED8_RECNO := ED8->(RECNO())
      WorkED8->ED8_AC    := ED0->ED0_AC
      WorkED8->TRB_ALI_WT:= "ED8"
      WorkED8->TRB_REC_WT:= ED8->(Recno())
      WorkED8->(msUnlock())      
      //EDCLOG400((ED8->ED8_CNPJIM+ED8->ED8_LI_NUM+ED8->ED8_DI_NUM+ED8->ED8_ADICAO+ED8->ED8_AC),ddatabase,(TIME()),Substr(cUsuario,7,15),"","","","I","ED8") //Alcir Alves - 28-12-05
      ED8->(dbSkip())
   EndDo	
   WorkED8->(dbGoTop())
EndIf

oMark:oBrowse:Refresh()

//WorkED9
IncProc(STR0014) //"Processando..."
dbSelectArea("ED9")
ED9->(dbSetOrder(3))
If ED9->(dbSeek(cFilED9+ED0->ED0_AC))
   Do While !ED9->(EOF()) .And. ED9->ED9_FILIAL==cFilED9 .And. ED9->ED9_AC == ED0->ED0_AC
      WorkED9->(RecLock("WorkED9",.T.))
      FOR i := 1 TO ED9TotCpos
         cCampo:=FIELDNAME(i)
         WorkED9->&(cCampo) := ED9->&(cCampo)
      NEXT i
      WorkED9->ED9_RECNO := ED9->(RECNO())
      //WorkED9->ED9_AC    := ED0->ED0_AC //JVR - 28/04/10 - Nopado.campo utilizado na manutenção de RE, informaçao ja esta na capa da manutenção de comp. externa.
      WorkED9->(msUnlock())
      ED9->(dbSkip())
   EndDo
   WorkED9->(dbGoTop())
EndIf

//oMark2:oBrowse:Refresh()
   
Return .T.

*---------------------------------------------------------------------------------------------*
Static Function CE400PEManut(nOpca)
*---------------------------------------------------------------------------------------------*
Local oDlg, oEnch, nSelecao:=0, bOk1:={||nSelecao:=1,oDlg:End()}
Local aGetsAux:={}, aTelaAux:={}, nTipo:=nOpca, i, nInd
Local nOldOrd:=WorkED9->(IndexOrd()), nOldOpc:=nOpca //Guarda a Opção devido a problema no Estorno de Itens(Work)

Private nRec:=WorkED9->ED9_RECNO, cTit:= STR0015 //"Manutencao de Itens da Exportação"

If ED0->ED0_MODAL="2"
   MsgInfo(STR0065)//"Não existe comprovação de exportação para ato concessorio modalidade isenção"
   Return .T.
EndIf

aGetsAux := aClone(aGets)
aTelaAux := aClone(aTela)

Set Filter To

Do While .T.

   If nOpca <> INCLUIR
      dbSelectArea("WorkED9")
      If WorkED9->(EasyRecCount()) <= 0 .Or. (WorkED9->(BOF()) .And. WorkED9->(EOF()))
         Help("", 1, "ARQVAZIO")
         Return .T. 
      EndIf
      cTit+=STR0029+Alltrim(WorkED9->ED9_EXPORT) //"Exportador - "
      FOR i := 1 TO FCount()
         M->&(FIELDNAME(i)) := FieldGet(i)
      NEXT i
   Else
      dbSelectArea("ED9")
      FOR nInd := 1 TO FCount()
         M->&(FIELDNAME(nInd)) := CRIAVAR(FIELDNAME(nInd))
      NEXT
      M->ED9_RECNO := 0      
      M->ED9_AC := M->ED0_AC // By JPP - 14/11/2007 - 14:00
   EndIf
   
   aGets:={}
   aTela:={}
   dbSelectArea("WorkED9")
   
   If nOpca = VISUALIZAR
      ED9->(dbGoTo(nRec))
   ElseIf nOpca = ESTORNAR
      nOpca := ALTERAR
   EndIf
             
   DEFINE MSDIALOG oDlg TITLE cTit ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
          OF oMainWnd PIXEL

      nLinha :=(oDlg:nClientHeight-4)/2 

      oEnCh:=MsMGet():New("ED9",nRec,nOpca,,,,,{15,1,nLinha,COLUNA_FINAL},If(nOldOpc=ESTORNAR,{},),3) //LRL 30/04/04
      oDlg:lMaximized:=.T. //Maximiliza Janela
	  oEnch:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||If(nOldOpc=ESTORNAR .or. nOpca=VISUALIZAR .or. (Obrigatorio(aGets,aTela) .and. CE400ACSaldo("V",nOldOpc,"ED9")) ,Eval(bOk1),)},{||nSelecao:=0,oDlg:End()})) //LRL 30/04/04 //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   nOpca := nOldOpc
   nAltQtd := 0
   If nSelecao = 1
      dbSelectArea("WorkED9")
      If nOpca=INCLUIR .or. nOpca=ALTERAR
         WorkED9->(dbSetOrder(1))
         WorkED9->(RecLock("WorkED9",If(nOpca=INCLUIR,.T.,.F.)))         
         FOR i := 1 TO FCount()
            If WorkED9->(FIELDNAME(i)) == "DBDELETE"
               Loop
            Endif   
            WorkED9->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
         NEXT i
      ElseIf nOpca=ESTORNAR
         If MsgYesNo(STR0016) //"Deseja Realmente Excluir este Registro?"
            aAdd(aDelWkED9,WorkED9->ED9_RECNO)
            WorkED9->(RecLock("WorkED9",.F.,.T.))
            WorkED9->(DBDELETE())  
            WorkED9->(DbGoTop())
            oMark:oBrowse:Refresh()
         EndIf
      EndIf   
      WorkED9->(MSUnlock())
   EndIf
   
   If nOpca<>INCLUIR .Or. nSelecao=0      
      oMark:oBrowse:Refresh()
      Exit
   EndIf
   nSelecao := 0

EndDo

aGets := aClone(aGetsAux)
aTela := aClone(aTelaAux)
nSelecao := 0

Return .T.

*----------------------------------------------------------------------------------------------*
Static Function CE400PIManut(nOpca)
*----------------------------------------------------------------------------------------------*
Local oDlg,oEnch, nSelecao:=0, bOk1:={||nSelecao:=1,oDlg:End()}
Local aGetsAux:={}, aTelaAux:={}, nTipo:=nOpca, i, nInd
Local nOldOpc:=nOpca //Guarda a Opção devido a problema no Estorno de Itens(Work)
Local aEstru_t := {}
Private aCampos:= ARRAY(1)
Private nRec:=WorkED8->ED8_RECNO, cTit:= STR0001 //"Manutencao de Ato Concessório/Importador"
Private cItens:=""

aGetsAux := aClone(aGets)
aTelaAux := aClone(aTela)    

Set Filter To

Do While .T.

   If nOpca <> INCLUIR
      dbSelectArea("WorkED8")
      If (WorkED8->(BOF()) .And. WorkED8->(EOF()))
         Help("", 1, "ARQVAZIO")
         Return .T.
      EndIf
      cTit+=STR0029+Alltrim(WorkED8->ED8_AC) //" Ato - "
      FOR i := 1 TO FCount()
         //if (M->&(FIELDNAME(i)))<>"ED8_DES_VM"         
         M->&(FIELDNAME(i)) := FieldGet(i)
         //endif
      NEXT i
      M->ED8_DES_VM:= MSMM(WorkED8->ED8_DES_DI,AVSX3("ED8_DES_VM",AV_TAMANHO),,,LERMEMO)      
      M->ED8_DESCIM:= WorkED8->ED8_DESCIM
   Else        
      dbSelectArea("ED8")
      FOR nInd := 1 TO FCount()
         M->&(FIELDNAME(nInd)) := CRIAVAR(FIELDNAME(nInd))
      NEXT
      M->ED8_RECNO := 0
   EndIf
   
   aGets:={}
   aTela:={}
   dbSelectArea("WorkED8")
   
   If nOpca = VISUALIZAR
      ED8->(dbGoTo(nRec))
   ElseIf nOpca = ESTORNAR
      nOpca:=ALTERAR
   EndIf
   
   DEFINE MSDIALOG oDlg TITLE cTit ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
          OF oMainWnd PIXEL
      ED8->(DBGOTO(nRec))
      //campos necessários para funcinamento correto dos F3´s ED4 e E29
      aEstru_t:={}
      AADD(aEstru_t,{ "WKTEC" ,  AVSX3("ED8_NCM",2) , AVSX3("ED8_NCM",3), AVSX3("ED8_NCM",4)})
 	  cNomArq1:=E_CriaTrab("",aEstru_t,"Work")
	  Work->(dbappend())
	  Work->WKTEC:=ED8->ED8_NCM
      M->ED8_AC := M->ED0_AC
	  cItens:=ED8->ED8_COD_I
	  cItens+="///"+IG400BuscaItem("I",ED8->ED8_COD_I,,M->ED8_AC)  // PLB 16/11/06 - Item genérico
      //
      
      //aCpos := {}
      //aEval(BrowseCpos("ED8"),{|X| aAdd(aCpos,X[1])})
      //aAdd(aCpos,"ED8_SEQSIS")
      
      
      nLinha :=(oDlg:nClientHeight-4)/2
      aAlter := {"ED8_IMPORT","ED8_DESCIM","ED8_CNPJIM","ED8_DI_NUM","ED8_DTREG" ,"ED8_ADICAO","ED8_POSDI" ,"ED8_LI_NUM","ED8_DTLI"  ,"ED8_COD_I" ,"ED8_DESC"  ,"ED8_VALEMB",;
                 "ED8_DES_VM","ED8_NCM"   ,"ED8_PESO"  ,"ED8_UM"    ,"ED8_QTD"   ,"ED8_UMNCM" ,"ED8_QTDNCM","ED8_MOEDA" ,"ED8_TX_MOE","ED8_VALORI","ED8_TX_USS","ED8_SEGURO",;
                 "ED8_NF"    ,"ED8_SERIE" ,"ED8_EMISSA","ED8_SEQSIS","ED8_INVOIC","ED8_MOE_FR","ED8_TX_FR" ,"ED8_FRETE" ,"ED8_MOE_SE","ED8_TX_SE" ,"ED8_SE_USS",;
                 "ED8_MRCDES","ED8_ARMDES","ED8_INLAND","ED8_OUTDES","ED8_DESCNT","ED8_PACKIN","ED8_FOBGER","ED8_VL_AC" ,"ED8_QT_AC" ,"ED8_SALISE","ED8_FASEDR"}
      aADD(aAlter,"ED8_SEQMI")
      oEnCh:=MsMGet():New( "ED8",nRec,nOpca,,,,/*aCpos*/,{15,1,nLinha,COLUNA_FINAL},If(nOldOpc=ESTORNAR,{},aAlter),3) //LRL 30/04/04
      oDlg:lMaximized:=.T. //Maximiliza Janela
      oEnch:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO - Alteração nas propriedades de alinhamento das telas para antes do INIT - 02/01/12     
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||If(nOldOpc=ESTORNAR .or. nOpca=VISUALIZAR .or. (Obrigatorio(aGets,aTela) .and. EDCED8OBR(nOpca) .and. CE400ACSaldo("V",nOldOpc,"ED8") .And. IIF(nOpca==INCLUIR,IIF(lMUserEDC,oMUserEDC:Reserva("COMPROVA_EXT","INC_DI"),.T.),CE400VALID("ALT_DI")) ) ,Eval(bOk1),)},{||nSelecao:=0,oDlg:End()},,,)) //LRL 30/04/04 - Alinhamento MDI
   WORK->(DBCLOSEAREA())
   nOpca := nOldOpc
   If nSelecao = 1
      WorkED8->(dbSetOrder(1))
      dbSelectArea("WorkED8")
      If nOpca==INCLUIR .or. nOpca==ALTERAR
         WorkED8->(RecLock("WorkED8",If(nOpca=INCLUIR,.T.,.F.)))         
         FOR i := 1 TO FCount()
            If WorkED8->(FIELDNAME(i)) $ "DBDELETE,TRB_ALI_WT,TRB_REC_WT"
               Loop
            Endif   
            WorkED8->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
         NEXT i
         //WorkED8->ED8_DES_VM:=MSMM(ED8->ED8_DES_DI,AVSX3("ED8_DES_VM",AV_TAMANHO),,,LERMEMO)
         WorkED8->ED8_DES_DI:=M->ED8_DES_DI         
         If nOpca=INCLUIR
            WorkED8->TRB_ALI_WT:= "ED8"
            WorkED8->TRB_REC_WT:= ED8->(Recno())
         EndIf
         WorkED8->(MSUnlock())
      ElseIf nOpca=ESTORNAR
         If MsgYesNo(STR0016) .And. IIF(lMUSerEDC,oMUserEDC:Reserva("COMPROVA_EXT","ALT/EXC_DI"),.T.) //"Deseja Realmente Excluir este Registro?"
            aAdd(aDelWkED8,WorkED8->ED8_RECNO)
            WorkED8->(RecLock("WorkED8",.F.,.T.))
            WorkED8->(DBDELETE())                
         Endif   
      EndIf
   EndIf
   
   If nOpca<>INCLUIR .or. nSelecao=0      
      oMark:oBrowse:Refresh()
      Exit
   EndIf
   nSelecao := 0
EndDo

aGets := aClone(aGetsAux)
aTela := aClone(aTelaAux)
nSelecao := 0

Return .T.

*----------------------------------------------------------------------------------------------*
Function CE400Bar(oDlg,aOk,bCancel,nOpc,aBotoes)
*----------------------------------------------------------------------------------------------*

IF aBotoes # NIL              
   AAdd(aButtons, {,, oDlg:cTitle, oDlg:cTitle,,, aBotoes})
ENDIF

Return

*-----------------------------------------------------------------------------------------------*
Static Function Browse_Cpos(cAlias,cAliasDad)
*-----------------------------------------------------------------------------------------------*
Local aOrd := SaveOrd("SX3"), aRet := {}, aField

Default cAliasDad := cAlias

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))

Do While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias

   IF SX3->X3_NIVEL > cNivel .or. Upper(SX3->X3_BROWSE) != "S" .or. SX3->X3_CONTEXT == "V" .or. !X3Uso(SX3->X3_USADO)
      SX3->(dbSkip())
      Loop
   Endif
   
   aField := { Alltrim(SX3->X3_CAMPO),"", OemToAnsi(X3TITULO()),Alltrim(SX3->X3_PICTURE) }

   IF aField[1] != Nil
      aAdd(aRet,aField)
   Endif
   
   SX3->(dbSkip())
Enddo

RestOrd(aOrd)

Return aRet

*----------------------------------------------------------------------------------------------*
Static Function CE400GrvGeral()
*----------------------------------------------------------------------------------------------*
Local cCampo, i

Begin TransAction   //Controle de Transação

   ED0->(dbSetOrder(2))
   ED3->(dbSetOrder(2))
   ED4->(dbSetOrder(2))

   ProcRegua(WorkED8->(EasyRecCount())+WorkED9->(EasyRecCount())+LEN(aDelWkED8)+LEN(aDelWkED9)+1)

   //Grava ED8
   dbSelectArea("WorkED8")
   WorkED8->(dbGoTop())
   a_altera:={}
   Do While !WorkED8->(EOF())
      IncProc(STR0035)      //"Gravando Registros da Importação"
      ED8->(DBGOTO(WorkED8->ED8_RECNO))
      IF WorkED8->ED8_RECNO == ED8->(Recno())
         ED8->(RecLock("ED8",.F.))
         CE400AtuAC(ALTERAR,"ED8")
      Else
         aadd(a_altera,{"ED8",(WorkED8->ED8_DI_NUM+WorkED8->ED8_ADICAO+WorkED8->ED8_POSDI),"I","","","",ddatabase,(TIME()),cUserName})
         ED8->(RecLock("ED8",.T.))
         CE400AtuAC(INCLUIR,"ED8")
      Endif
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
    	 // by CAF 30/06/08 if cCampo<>"ED8_RECNO" .AND. cCampo<>"ED8_DES_VM" .AND. cCampo<>"ED8_DESCIM" .AND. cCampo<>"ED8_FOBGER" .AND. cCampo<>"DELETE" .AND. WorkED8->ED8_RECNO == ED8->(Recno()) .AND. (ED8->&(cCampo)<>WorkED8->&(cCampo) )
    	 if ED8->(FieldPos(cCampo)) > 0 .AND. WorkED8->ED8_RECNO == ED8->(Recno()) .AND. (ED8->&(cCampo)<>WorkED8->&(cCampo) )
    	 
          aadd(a_altera,{"ED8",(ED8->ED8_DI_NUM+ED8->ED8_ADICAO+ED8->ED8_POSDI),"A",cCampo,ED8->&(cCampo),WorkED8->&(cCampo),ddatabase,(TIME()),cUserName})
   	     endif
         ED8->&(cCampo) := WorkED8->&(cCampo)
      NEXT i
      ED8->ED8_FILIAL := cFilED8
      ED8->ED8_AC := ED0->ED0_AC
      MSMM(ED8->ED8_DES_DI,,,WorkED8->ED8_DES_VM,1,,,"ED8","ED8_DES_DI")
      ED8->(msUnlock())
      WorkED8->(dbSkip())
   EndDo

   //Apaga Estornados ED8
   For i:=1 to Len(aDelWkED8)
      IncProc(STR0035)      //"Gravando Registros da Importação"
      ED8->(dbGoTo(aDelWkED8[i]))
      If !ED8->(BOF()) .and. !ED8->(EOF())
         aadd(a_altera,{"ED8",(ED8->ED8_DI_NUM+ED8->ED8_ADICAO+ED8->ED8_POSDI),"E","","","",ddatabase,(TIME()),cUserName})
         ED8->(RecLock("ED8",.F.,.T.))
         CE400AtuAC(ESTORNAR,"ED8")
    	 MSMM(ED8->ED8_DES_DI,,,,2) 
         ED8->(DBDELETE())
         ED8->(msUnlock())
      EndIf
   Next i
   WorkED8->(dbSetOrder(1))

   for i:=1 to len(a_altera)
       EDCLOG400(a_altera[i,1],a_altera[i,2],a_altera[i,3],a_altera[i,4],a_altera[i,5],a_altera[i,6],a_altera[i,7],a_altera[i,8],a_altera[i,9])
   next

   //Grava ED9
   dbSelectArea("WorkED9")
   WorkED9->(dbGoTop())

   Do While !WorkED9->(EOF())
      IncProc(STR0013)      //"Gravando Registros da Exportação"
      ED9->(DBGOTO(WorkED9->ED9_RECNO))
      IF WorkED9->ED9_RECNO == ED9->(Recno())
         ED9->(RecLock("ED9",.F.))
         CE400AtuAC(ALTERAR,"ED9")
      Else
         ED9->(RecLock("ED9",.T.))
         CE400AtuAC(INCLUIR,"ED9")
      Endif
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         ED9->&(cCampo) := WorkED9->&(cCampo)
      NEXT i
      ED9->ED9_FILIAL := cFilED9
      ED9->ED9_AC := M->ED0_AC //ED0->ED0_AC // By JPP - 14/11/2007 - 14:00
      ED9->(msUnlock())
      WorkED9->(dbSkip())
   EndDo

   //Apaga Estornados ED9
   For i:=1 to Len(aDelWkED9)
      IncProc(STR0013)      //"Gravando Registros da Exportação"
      ED9->(dbGoTo(aDelWkED9[i]))
      If !ED9->(BOF()) .And. !ED9->(EOF())
         ED9->(RecLock("ED9",.F.,.T.))
         CE400AtuAC(ESTORNAR,"ED9")
         ED9->(DBDELETE())
         ED9->(msUnlock())
      EndIf
   Next i
   WorkED9->(dbSetOrder(1))

   ED0->(dbSetOrder(1))
   ED3->(dbSetOrder(1))
   ED4->(dbSetOrder(1))

End TransAction   //Finaliza Controle de Transação

Return .T.

*----------------------------------------------------------------------------------------------*
Static Function CE400Filtro(cAlias)
*----------------------------------------------------------------------------------------------*
Local nOp:=0
Local bOk := {|| If(!Empty(cCnpj), If(cAlias=="ED9", CE400ValFiltro("ED9"), CE400ValFiltro("ED8")), ), If(lRet,oDlg:End(), lRet:= .T. )}
Local bCancel := {||nOpcao:=0,oDlg:End()}, cFiltro
Private lRet := .T.

If cAlias == "ED8"        
   dbSelectArea("WorkED8")
   cFiltro := WorkED8->(dbFilter())
Else
   dbSelectArea("WorkED9")
   cFiltro := WorkED9->(dbFilter())
Endif           

SET FILTER TO

While .T.        
  
   nOp := 0
   cCnpj:= Space(Len(SYT->YT_CGC))
   
   DEFINE MSDIALOG oDlg TITLE STR0022+If(cAlias=="ED8",STR0038,STR0037); //"Seleção de Filtro - # Exportação/Importação"
       FROM 12,05 TO 21,50 OF GetWndDefault()

   If cAlias == "ED8" .Or. cAlias == "ED9"
      @02,04 SAY   AVSX3("YT_CGC",5) of oDlg
      @02,08 MSGET cCnpj PICT AVSX3("YT_CGC",6) SIZE 60,8 //VALID If(!Empty(cCnpj), If(cAlias=="ED8", CE400ValFiltro("ED8"), CE400ValFiltro("ED9") ), ) SIZE 60,8
   EndIf

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOp:=1, Eval(bOk)},{||nOp:=0,oDlg:End()}) CENTERED

   If nOp=1
      If cAlias == "ED9"
         If !Empty(cCnpj)
            WorkED9->(DBSETFILTER({||ED9_EXPORT=cCnpj }, "ED9_EXPORT='"+cCnpj+"' "))
            WorkED9->(dbGoTop())
            //oMark2:oBrowse:Refresh()
         Else
            WorkED9->(DBSETFILTER({||.T. }, ".T."))
            WorkED9->(dbGoTop())
            //oMark2:oBrowse:Refresh()
         Endif
      Else
         If !Empty(cCnpj)
            WorkED8->(DBSETFILTER({||ED8_CNPJIM=cCnpj }, "ED8_CNPJIM='"+cCnpj+"' "))
            WorkED8->(dbGoTop())
            oMark:oBrowse:Refresh()
         Else
            WorkED8->(DBSETFILTER({||.T. }, ".T."))
            WorkED8->(dbGoTop())
            oMark:oBrowse:Refresh()
         Endif
      EndIf
   ElseIf nOp=0      
      SET FILTER TO &cFiltro      
   EndIf
   
   Exit
EndDo

Return .T.

*-----------------------------------------------------------------------------------------------*
Static Function CE400ValFiltro(cAlias)
*-----------------------------------------------------------------------------------------------*
Local cCarAux

SYT->(dbSetOrder(3))
SA2->(dbSetOrder(3))

If cAlias=="ED8"
   dbSelectArea("WorkED8")
   cCarAux := WorkED8->(dbFilter())

   SET FILTER TO
   
   If SYT->(dbSeek(cFilSYT+cCnpj))
      If SYT->YT_IMP_CON <> "1"
         Help(" ",1,"AVG0005126") //MsgInfo(STR0048) //"Codigo nao se refere a um importador."
         lRet := .F.                  
      Else
         WorkED8->(dbSetOrder(2))
         If !WorkED8->(dbSeek(cCnpj))
            Help(" ",1,"AVG0005254") //"C.N.P.J. não existe na Manutenção da Importação."###"Mensagem"
            lRet := .F.
         EndIf
      EndIf   
   Else
      Help(" ",1,"REGNOIS")
      lRet := .F.
   EndIf
Else
   dbSelectArea("WorkED9")
   cCarAux := WorkED9->(dbFilter())

   SET FILTER TO
   
   If SA2->(dbSeek(cFilSA2Aux+cCnpj))
      WorkED9->(dbSetOrder(2))
      If !WorkED9->(dbSeek(cCnpj))
         Help(" ",1,"AVG0005257") //"C.N.P.J. não existe na Manutenção da Exportação."###"Mensagem"
         lRet := .F.
      EndIf
   Else
      Help(" ",1,"REGNOIS")
      lRet := .F.   
   EndIf
   
Endif

SET FILTER TO &cCarAux 

If lRet == .F.
   cCnpj:= Space(Len(SYT->YT_CGC))
Endif

Return lRet

*-----------------------------------------------------------------------------------------------*
Function CE400VALID(cNomeCampo)
*-----------------------------------------------------------------------------------------------*
Local i
Local lExecAuto := !(Type("aCabAuto") == "U") .And. !(Type("nOpcAuto") == "U")
Local aOrd
Local cBusca := "" 
Local cChave := "" //RRC - 24/05/2012 - Chave de busca na tabela ED4 (Saldo dos Itens a Importar)
Private lRet := .T., nRec
Private cCampo:=cNomeCampo
If(EasyEntryPoint("EDCCE400"),ExecBlock("EDCCE400",.F.,.F.,"VALID"),)

Begin Sequence

If !AvFlags("INDICEED9")
   Return .F.
EndIf

Do Case
   Case cCampo == "MANUTENCAO"
      If Empty(ED0->ED0_AC)
         lRet := .F.
         Help(" ",1,"AVG0005264") //MsgInfo("Pedido não possui nro. de Ato Concessório.")
      ElseIf !Empty(ED0->ED0_DT_ENC)
         lRet := .F.
         Help(" ",1,"AVG0005265") //MsgInfo("Ato Concessório Encerrado.")
      // PLB 27/11/06 - Verifica se é possivel a alteração das DI's Externas
      ElseIf lMUserEDC  .And.  !oMUserEDC:Reserva("COMPROVA_EXT","MANUTENCAO")
         lRet := .F.
      ElseIf EasyGParam("MV_EDC0005",,.F.) .And. ED0->ED0_STATUS == "6"  //ALS - 11/12/2007 Caso Siscomex Web esteja ativado verifica se o Ato foi Deferido
         lRet := .F.   
         MsgStop(STR0047) // "O pedido de AC deve ter o Status de Deferido. "
      EndIf
   Case cCampo == "ED8_SEQSIS"
      M->ED8_NCM := ED4->ED4_NCM
      M->ED8_UMNCM  := ED4->ED4_UMITEM
      
      If IsInCallStack("EDCNF400") //AOM - 30/09/2011
      
         IF Empty(M->ED8_AC) .and. !Empty(M->ED8_SEQSIS)
            If !lExecAuto
               MsgInfo(STR0050,STR0049)//"Informar o Ato Concessório antes da sequência.","Aviso"
            Else
               EasyHelp(STR0050,STR0049)//"Informar o Ato Concessório antes da sequência.","Aviso"
            EndIf  
            M->ED8_SEQSIS := space(AvSX3("ED8_SEQSIS",3)) 
            M->ED8_AC      := space(AvSX3("ED8_AC",3))
            Break  
         EndIf
         
         ED4->(DbSetOrder(2))
         If !(ED4->(DbSeek(xFilial("ED4") + AvKey(M->ED8_AC,"ED8_AC") + AvKey(M->ED8_SEQSIS,"ED8_SEQSIS"))))
            If !lExecAuto
               MsgInfo(STR0051,STR0049)//"A sequencia informada não existe para esse Ato Concessório.","Aviso"
            Else
               EasyHelp(STR0051,STR0049)//"A sequencia informada não existe para esse Ato Concessório.","Aviso"
            EndIf
            lRet := .F.
            Break
         EndIf
         If Empty(M->ED8_COD_I)
            If !lExecAuto
               MsgInfo(STR0052,STR0049)//"Preencher o Código do Item na pasta 'Cadastrais' antes de informar o Ato Concessório e Sequência.","Aviso"
            Else
               EasyHelp(STR0052,STR0049)//"Preencher o Código do Item na pasta 'Cadastrais' antes de informar o Ato Concessório e Sequência.","Aviso"
            EndIf  
                lRet := .F. 
                Break  
         ElseIf AllTrim(M->ED8_COD_I) <> AllTrim(ED4->ED4_ITEM)
            If !lExecAuto
               MsgInfo(STR0053,STR0049)//"O item do Ato Concessório deve ser o mesmo que o informado na pasta 'Cadastrais'.","Aviso"
            Else
               EasyHelp(STR0053,STR0049)//"O item do Ato Concessório deve ser o mesmo que o informado na pasta 'Cadastrais'.","Aviso"
            EndIf  
            lRet := .F.
            Break
         EndIf
         
      EndIf
   
   // GFP - 11/11/11
   Case cCampo == "ED8_SEQMI"
      M->ED8_NCM := ED4->ED4_NCM
      M->ED8_UMNCM  := ED4->ED4_UMITEM
      
      If IsInCallStack("EDCNF400") //AOM - 30/09/2011
      
         IF Empty(M->ED8_AC) .and. !Empty(M->ED8_SEQMI)
            If !lExecAuto
               MsgInfo(STR0050,STR0049)//"Informar o Ato Concessório antes da sequência.","Aviso"
            Else
               EasyHelp(STR0050,STR0049)//"Informar o Ato Concessório antes da sequência.","Aviso"
            EndIf          
            M->ED8_SEQMI := space(AvSX3("ED8_SEQMI",3))
            M->ED8_AC      := space(AvSX3("ED8_AC",3))
            Break  
         EndIf
         
         ED4->(DbSetOrder(8)) // ED4_FILIAL+ED4_AC+ED4_SEQMI

         If !(ED4->(DbSeek(xFilial("ED4") + AvKey(M->ED8_AC,"ED8_AC") + AvKey(M->ED8_SEQMI,"ED8_SEQMI"))))
            If !lExecAuto
               MsgInfo(STR0051,STR0049)//"A sequencia informada não existe para esse Ato Concessório.","Aviso"
            Else
               EasyHelp(STR0051,STR0049)//"A sequencia informada não existe para esse Ato Concessório.","Aviso"
            EndIf
            lRet := .F.
            Break
         EndIf
         If Empty(M->ED8_COD_I)
            If !lExecAuto
               MsgInfo(STR0052,STR0049)//"Preencher o Código do Item na pasta 'Cadastrais' antes de informar o Ato Concessório e Sequência.","Aviso"
            Else
               EasyHelp(STR0052,STR0049)//"Preencher o Código do Item na pasta 'Cadastrais' antes de informar o Ato Concessório e Sequência.","Aviso"
            EndIf             
                lRet := .F. 
                Break  
         ElseIf AllTrim(M->ED8_COD_I) <> AllTrim(ED4->ED4_ITEM)
            If !lExecAuto
               MsgInfo(STR0053,STR0049)//"O item do Ato Concessório deve ser o mesmo que o informado na pasta 'Cadastrais'.","Aviso"
            Else
               EasyHelp(STR0053,STR0049)//"O item do Ato Concessório deve ser o mesmo que o informado na pasta 'Cadastrais'.","Aviso"
            EndIf  
            lRet := .F.
            Break
         EndIf
         
      EndIf
 
   Case cCampo == "ED9_SEQSIS"//JVR - 28/04/10 - validaçAo do campo.
      M->ED9_NCM    := ED3->ED3_NCM
      M->ED9_UMNCM  := ED3->ED3_UMPROD
      
   Case cCampo == "ED9_PROD"
      If (lRet := ExistCpo("SB1",M->ED9_PROD)) //FSM - 14/10/2011
         M->ED9_NCM := Posicione("SB1",1,xFilial("SB1")+M->ED9_PROD,"B1_POSIPI")
         M->ED9_DESC:= SB1->B1_DESC
         
         CE400Valid("ED9_NCM")

      EndIf

   Case cCampo == "ED9_NCM"
   
      If !Empty(M->ED9_NCM) .AND. ExistCpo("SYD",M->ED9_NCM)
         M->ED9_UMNCM  := Posicione("SYD",1,xFilial("SYD")+M->ED9_NCM,"YD_UNID")
         M->ED9_QTDNCM := AVTransUnid(M->ED9_UM,M->ED9_UMNCM,M->ED9_PROD,M->ED9_QTD,.F.)

         //CE400Valid("ED9_UMNCM")
         //CE400Valid("ED9_QTDNCM")
      EndIf
      
   Case cCampo == "ED9_VL_FOB"
      /*
      If M->ED9_TX_MOE <> 0
         M->ED9_VALMOE := M->ED9_VL_FOB * M->ED9_TX_MOE
      ElseIf M->ED9_VALMOE <> 0 .and. M->ED9_VL_FOB <> 0
         M->ED9_TX_MOE := M->ED9_VALMOE / M->ED9_VL_FOB
      EndIf
      */
   Case cCampo == "ED8_VALEMB"
      If M->ED8_TX_MOE <> 0 .AND. M->ED8_TX_USS <> 0 .AND. Empty(M->ED8_VALORI)
         M->ED8_VALORI := M->ED8_VALEMB * M->ED8_TX_USS / M->ED8_TX_MOE
      ElseIf M->ED8_TX_USS <> 0 .and. M->ED8_VALORI <> 0 .AND. Empty(M->ED8_TX_MOE)
         M->ED8_TX_MOE :=  M->ED8_VALEMB * M->ED8_TX_USS / M->ED8_VALORI
      ElseIf M->ED8_VALORI <> 0 .and. M->ED8_TX_MOE <> 0 .AND. Empty(M->ED8_TX_USS)
         M->ED8_TX_USS := M->ED8_VALORI * M->ED8_TX_MOE / M->ED8_VALEMB
      EndIf
      
   Case cCampo == "ED9_TX_MOE"
      
      If !Empty(M->ED9_TX_MOE) .AND. M->ED9_MOEDA == EasyGParam("MV_SIMB2",,"US$") 
         M->ED9_TX_USS := M->ED9_TX_MOE
         
         CE400Valid("ED9_TX_USS")
      EndIf
      
   Case cCampo == "ED9_MOEDA"
      //FSM - 14/10/2011
      If !Empty(M->ED9_MOEDA)
      
         If (lRet := ExistCpo("SYF",M->ED9_MOEDA))
            
            If M->ED9_MOEDA == EasyGParam("MV_SIMB2",,"US$")
               M->ED9_VL_MOE := M->ED9_VL_FOB
               CE400Valid("ED9_VL_MOE")
               CE400Valid("ED9_TX_MOE")
            EndIf

         EndIf
              
      EndIf

   Case cCampo == "ED9_TX_USS"
      If !Empty(M->ED9_TX_USS) .AND. M->ED9_MOEDA == EasyGParam("MV_SIMB2",,"US$")  
         M->ED9_TX_MOE := M->ED9_TX_USS
         
         CE400Valid("ED9_VL_MOE")
      EndIf

   Case cCampo == "ED8_MOD_NF" .Or. cCampo == "ED9_MOD_NF"  //FSM - 06/10/2011
      
        If !Empty( M->&(cCampo) )
            dbSelectArea("SX5")
            SX5->( dbsetorder(1) )
            If SX5->( !dbseek(xFilial() + "42" + AvKey(M->&(cCampo),"X5_CHAVE") ) )
               MsgInfo(STR0063,STR0064) //"Não existe registro relecionado a este código." ### "Atenção"
               lRet := .F.
            EndIf
        EndIf

            
   Case cCampo == "ED8_TX_MOE"
      If M->ED8_VALEMB <> 0 .AND. M->ED8_TX_USS <> 0 .AND. Empty(M->ED8_VALORI)
         M->ED8_VALORI := M->ED8_VALEMB * M->ED8_TX_USS / M->ED8_TX_MOE
      ElseIf M->ED8_VALORI <> 0 .and. M->ED8_TX_USS <> 0 .AND. Empty(M->ED8_VALEMB)
         M->ED8_VALEMB := M->ED8_VALORI * M->ED8_TX_MOE / M->ED8_TX_USS
      ElseIf M->ED8_VALORI <> 0 .and. M->ED8_VALEMB <> 0 .AND. Empty(M->ED8_TX_USS)
         M->ED8_TX_USS := M->ED8_VALORI * M->ED8_TX_MOE / M->ED8_VALEMB
      EndIf
   Case cCampo == "ED8_TX_USS"
      If M->ED8_VALEMB <> 0 .AND. M->ED8_TX_MOE <> 0 .AND. Empty(M->ED8_VALORI)
         M->ED8_VALORI := M->ED8_VALEMB * M->ED8_TX_USS / M->ED8_TX_MOE
      ElseIf M->ED8_VALORI <> 0 .and. M->ED8_TX_MOE <> 0 //.AND. Empty(M->ED8_VALEMB)  - NOPADO POR AOM - 18/11/10
         M->ED8_VALEMB := M->ED8_VALORI * M->ED8_TX_MOE / M->ED8_TX_USS
      ElseIf M->ED8_VALEMB <> 0 .AND. M->ED8_VALORI <> 0 .AND. Empty(M->ED8_TX_MOE)
         M->ED8_TX_MOE :=  M->ED8_VALEMB * M->ED8_TX_USS / M->ED8_VALORI
      EndIf
   Case cCampo == "ED9_VALMOE"
      /*
      If M->ED9_VL_FOB <> 0
         M->ED9_TX_MOE :=  M->ED9_VALMOE / M->ED9_VL_FOB
      ElseIf ED9->ED9_TX_MOE <> 0
         M->ED9_VL_FOB := M->ED9_VALMOE / M->ED9_TX_MOE
      EndIf
      */
   Case cCampo == "ED8_VALORI"
      If M->ED8_VALEMB <> 0 .AND. M->ED8_TX_USS <> 0 .AND. Empty(M->ED8_TX_MOE)
         M->ED8_TX_MOE :=  M->ED8_VALEMB * M->ED8_TX_USS / M->ED8_VALORI
      ElseIf M->ED8_TX_MOE <> 0 .AND. M->ED8_TX_USS <> 0 //.AND. Empty(M->ED8_VALEMB) - NOPADO POR AOM - 18/11/10
         M->ED8_VALEMB := M->ED8_VALORI * M->ED8_TX_MOE / M->ED8_TX_USS
      ElseIf M->ED8_VALEMB <> 0 .AND. M->ED8_TX_MOE <> 0 .AND. Empty(M->ED8_TX_USS)
         M->ED8_TX_USS := M->ED8_VALORI * M->ED8_TX_MOE / M->ED8_VALEMB
      EndIf
   Case cCampo == "ED8_CNPJIM"
      SYT->(dbSetOrder(3))
      If !SYT->(dbSeek(xFilial("SYT")+M->ED8_CNPJIM))
         lRet:=.F.
         Help(" ",1,"AVG0005266") //MsgInfo("CNPJ do Importador não cadastrado.")
      ElseIf SYT->YT_IMP_CON <> "1"
         Help(" ",1,"AVG0005126") //MsgInfo(STR0048) //"Codigo nao se refere a um importador."
         lRet := .F.
      Else
         lRet := .f.
         If M->ED8_CNPJIM == BuscaCNPJ(M->ED8_CNPJIM,.T.)
            lRet := .T.
         EndIf
         If !lRet
            Help(" ",1,"AVG0005267") //MsgInfo("CNPJ do importador não declarado no A.C. para Comprovação Externa.")
         EndIf
      EndIf
      SYT->(dbSetOrder(1))
   Case cCampo == "ED8_IMPORT"
      SYT->( dbSetOrder(1) )
      SYT->( dbSeek(xFilial("SYT")+M->ED8_IMPORT) )
      
      If SYT->YT_IMP_CON <> "1"
         Help(" ",1,"AVG0005126") //"Codigo nao se refere a um importador."
         lRet := .F.
      Else
         M->ED8_DESCIM := Left(SYT->YT_NOME,AvSX3("ED8_DESCIM",3))
         M->ED8_CNPJIM := BuscaCNPJ(M->ED8_IMPORT,.T.)
      EndIf
   Case cCampo == "ED9_EXPORT"
      IF TYPE("cOrigem") = "U"
         cOrigem:="EDCCE400"
      ENDIF
      
      SA2->(dbSetOrder(3))
      If !SA2->(dbSeek(cFilSA2Aux+M->ED9_EXPORT))
         lRet := .F.
         Help(" ",1,"AVG0005268") //MsgInfo("CNPJ do Exportador/Fornecedor não cadastrado.")
      Elseif cOrigem = "EDCCE400"
         lRet := .F.
         If M->ED9_EXPORT == BuscaCNPJ(M->ED0_IMPORT,.T.)
            lRet := .T.
         EndIf
         If !lRet
            For i:=1 to 20
               If M->ED9_EXPORT==M->&("ED0_CNPJ"+Alltrim(Str(i)))
                  lRet:=.T.
                  Exit
               EndIf
            Next
         EndIf
         If !lRet
            Help(" ",1,"AVG0005269") //MsgInfo("CNPJ do Exportador/Fornecedor não declarado no A.C. para Comprovação Externa.")
         EndIf
      Endif

   // ** PLB 27/11/06 - Verifica se é possivel a Alteração de DI's Externas
   Case cCampo == "ALT_DI"
      If M->ED8_PESO != WorkED8->ED8_PESO ;
         .Or. M->ED8_UMNCM != WorkED8->ED8_UMNCM ;
         .Or. M->ED8_QTDNCM != WorkED8->ED8_QTDNCM ;
         .Or. M->ED8_VALEMB != WorkED8->ED8_VALEMB
         
         If lMUserEDC
            lRet := oMUserEDC:Reserva("COMPROVA_EXT","ALT/EXC_DI")
         EndIf
      EndIf

   Case cCampo == "ATU_DI"
      If ED8->ED8_PESO == WorkED8->ED8_PESO ;
         .And. ED8->ED8_UMNCM == WorkED8->ED8_UMNCM ;
         .And. ED8->ED8_QTDNCM == WorkED8->ED8_QTDNCM ;
         .And. ED8->ED8_VALEMB == WorkED8->ED8_VALEMB
         
         lRet := .F.
      EndIf
      
   Case cCampo == "ED8_POSDI" .Or. cCampo == "ED8_PEDIDO"  //AOM - 18/10/10
      If IsInCallStack("EDCNF400") .And. ED8->(FieldPos("ED8_PEDIDO")) > 0
         ED8->(DbSetOrder(5))
         If ED8->(DbSeek(xFilial("ED8")+ AvKey(M->ED8_PEDIDO,"ED8_PEDIDO") + AvKey(M->ED8_POSDI,"ED8_POSDI")))
            MsgInfo(STR0054,STR0049)//"O pedido informado jà existe em outro processo. Informar um novo pedido.","Aviso"
            lRet := .F.
         EndIf
      EndIf
     
   Case cCampo == "ED8_NF" //AOM - 18/10/10

      
   Case cCampo == "ED8_AC" //AOM - 18/10/10
      If IsInCallStack("EDCNF400")
         // GFP - 11/11/11      
         If Empty(M->ED8_AC)
            IF AvFlags("SEQMI") .AND. Empty(M->ED8_DI_NUM)       
               M->ED8_SEQMI := space(AvSX3("ED8_SEQMI",3)) 
            ELSE
               M->ED8_SEQSIS := space(AvSX3("ED8_SEQSIS",3))
            ENDIF
            Break
         EndIf
         
         DbSelectArea("ED0")
         ED0->(DbSetOrder(2))
         If !ED0->(DbSeek(xFilial("ED0") + AvKey(M->ED8_AC,"ED0_AC")))
            If !lExecAuto
               MsgInfo(STR0056,STR0049)//AOM - 30/09/2011 "Ato Concessório informado não cadastrado.","Aviso"
            Else
               EasyHelp(STR0056,STR0049)//AOM - 30/09/2011 "Ato Concessório informado não cadastrado.","Aviso"
            EndIf
            IF AvFlags("SEQMI") .AND. Empty(M->ED8_DI_NUM)       
               M->ED8_SEQMI := space(AvSX3("ED8_SEQMI",3)) 
            ELSE
               M->ED8_SEQSIS := space(AvSX3("ED8_SEQSIS",3))
            ENDIF
            M->ED8_AC      := space(AvSX3("ED8_AC",3)) 
            lRet:=.F.
            Break
         Else  
            //RRC - 15/05/2012 - Não permite associação de um Ato Concessório de saldo inferior ou igual a 0 para Compra Nacional
            If !FindFunction("NF400VerSal")
               If !lExecAuto
                  MsgInfo(STR0070, STR0049) //"Este ambiente está desatualizado e requer atualizações no arquivo EDCNF400.prw. Favor entrar em contato com o suporte Trade-Easy.", "Aviso"  
               Else
                  EasyHelp(STR0070, STR0049) //"Este ambiente está desatualizado e requer atualizações no arquivo EDCNF400.prw. Favor entrar em contato com o suporte Trade-Easy.", "Aviso"  
               EndIf
            Else
               DbSelectArea("ED4")
               aOrd := SaveOrd({"ED4"}) 
               If AvFlags("SEQMI")  
                  ED4->(DbSetOrder(8))
                  cChave := "M->ED8_AC+M->ED8_SEQMI" //Busca pela chave ED4_AC+ED4_SEQMI                  
               Else            
                  ED4->(DbSetOrder(2))
                  cChave := "M->ED8_AC+M->ED8_SEQSIS"//Busca pela chave ED4_AC+ED4_SEQSIS
               EndIf
               If (!Empty(M->ED8_SEQMI) .Or. !Empty(M->ED8_SEQSIS)) .And. ED4->(DbSeek(xFilial("ED4") + &(cChave))) .And. (ED4->ED4_QT_LI <= 0 .Or. !NF400VerSal()) 
                  If !lExecAuto
                     MsgInfo(STR0069, STR0049) //"Ato Concessório não será associado pois não possui saldo suficiente para a operação","Aviso"
                  Else
                     EasyHelp(STR0069, STR0049) //"Ato Concessório não será associado pois não possui saldo suficiente para a operação","Aviso"
                  EndIf  
                  M->ED8_AC    := space(AvSX3("ED8_AC",3))
                  M->ED8_SEQMI := space(AvSX3("ED8_SEQMI",3)) 
                  lRet := .F. 
               EndIf
               
               RestOrd(aOrd,.T.)         
            EndIf    
                    
            If ED0->ED0_MODAL == "2"
               If !lExecAuto
                  MsgInfo(STR0057,STR0049)//"O Ato Concessório informado esta classificado com a modalidade Isenção. Só é permito Ato Concessório com a Modalidade Suspensão","Aviso"
               Else
                  EasyHelp(STR0057,STR0049)//"O Ato Concessório informado esta classificado com a modalidade Isenção. Só é permito Ato Concessório com a Modalidade Suspensão","Aviso"
               EndIf
               IF AvFlags("SEQMI") .AND. Empty(M->ED8_DI_NUM)       
                  M->ED8_SEQMI := space(AvSX3("ED8_SEQMI",3)) 
               ELSE
                  M->ED8_SEQSIS := space(AvSX3("ED8_SEQSIS",3))
               ENDIF 
               M->ED8_AC      := space(AvSX3("ED8_AC",3))
               lRet := .F.
               Break
            EndIf 
         EndIf
               
         If Empty(M->ED8_NF) .Or. Empty(M->ED8_SERIE) .Or. Empty(M->ED8_EMISSA)
            If !lExecAuto
               MsgInfo(STR0062,STR0049)//"Para informar o Ato Concessório é necessario informar os dados da Nota Fista(NF, Serie e Data da Nota).","Aviso"
            Else   
               EasyHelp(STR0062,STR0049)//"Para informar o Ato Concessório é necessario informar os dados da Nota Fista(NF, Serie e Data da Nota).","Aviso"
            EndIf
            IF AvFlags("SEQMI") .AND. Empty(M->ED8_DI_NUM)       
               M->ED8_SEQMI := space(AvSX3("ED8_SEQMI",3)) 
            ELSE
               M->ED8_SEQSIS := space(AvSX3("ED8_SEQSIS",3))
            ENDIF
            M->ED8_AC      := space(AvSX3("ED8_AC",3))
            lRet := .F.
            Break
         EndIf
         
         If Empty(M->ED8_COD_I)
            If !lExecAuto
               MsgInfo(STR0052,STR0049)//"Preencher o Código do Item na pasta 'Cadastrais' antes de informar o Ato Concessório e Sequência.","Aviso"
            Else   
               EasyHelp(STR0052,STR0049)//"Preencher o Código do Item na pasta 'Cadastrais' antes de informar o Ato Concessório e Sequência.","Aviso"
            EndIf
            
            
              
                lRet := .F. 
                Break  
         ElseIf AllTrim(M->ED8_COD_I) <> AllTrim(ED4->ED4_ITEM)
            If !lExecAuto
               MsgInfo(STR0053,STR0049)//"O item do Ato Concessório deve ser o mesmo que o informado na pasta 'Cadastrais'.","Aviso"
            Else   
               EasyHelp(STR0053,STR0049)//"O item do Ato Concessório deve ser o mesmo que o informado na pasta 'Cadastrais'.","Aviso"
            EndIf
              
            lRet := .F.
            Break
         EndIf
         
      EndIf 
      
  Case cCampo == "ED8_FORN" //AOM - 17/11/2010
     If IsInCallStack("EDCNF400")
        DbSelectArea("SA2")
        SA2->(DbSetOrder(1))
        If !SA2->(DbSeek(xFilial("SA2") + AvKey(M->ED8_FORN,"A2_COD"))) 
            MsgInfo(STR0058,STR0049)//"Informar apenas Fornecedores cadastrados.","Aviso"
            lRet := .F.
        ElseIf !(LEFT(SA2->A2_ID_FBFN,1) $ '2/3' )
          MsgInfo(STR0059,STR0049)//"Informar apenas Empresas cadastradas como fornecedores.","Aviso"
          lRet := .F. 
        EndIf
     EndIf 
     
     
   Case cCampo == "ED8_LOJA" //AOM - 17/11/2010
     If IsInCallStack("EDCNF400")
        DbSelectArea("SA2")
        SA2->(DbSetOrder(1))
        If !Empty(M->ED8_FORN)
           If !SA2->(DbSeek(xFilial("SA2") + AvKey(M->ED8_FORN,"A2_COD") + AvKey(M->ED8_LOJA,"A2_LOJA")))
              MsgInfo(STR0060,STR0049)//"Loja não cadastrada para o Fornecedor informado.","Aviso"
              lRet := .F.    
           EndIf
        Else
           MsgInfo(STR0061,STR0049)//"Informar Fornecedor antes do preenchimento da Loja.","Aviso"
        EndIf
     EndIf 
   
   Case cCampo == "ED9_CODEXP" //RRC - 17/04/2012 
      aOrd   := SaveOrd({"SA2"}) 
      cBusca := Posicione("SA2",1,xFilial("SA2")+M->ED9_CODEXP,"A2_LOJA") //Atualiza a 'Loja' para consulta.    
      If Posicione("SA2",1,xFilial("SA2")+M->ED9_CODEXP+cBusca,"A2_TIPO") == "F"
         lRet := .F. 
         Help(,,"Help",,STR0068,1,0)//"Informe um Exportador/Fornecedor do tipo jurídico."
      EndIf              
      RestOrd(aOrd,.T.)
                     
   // **      
EndCase


End Sequence

Return lRet


/*
Programa        : CE400TemSaldo()
Parâmetros      : Não há.
Retorno         : Tipo lógico(.T. para item com saldo)
Objetivo        : Verificar se há saldo para item de importação. Usado no consulta(F3) E29.
Autor           : HFD
Data/Hora       : 03.jun.2009
Obs.            : 720529
*/
Function CE400TemSaldo()
   Local lRet := .F., nQtdOld := 0
   Local aOrd := SaveOrd("ED4")

   If !AvFlags("INDICEED9")
      Return .F.
   EndIf

   WorkED8->(dbGoTop())
   While WorkED8->(!EOF())
      if WorkED8->ED8_COD_I == ED4->ED4_ITEM
         
         //Tratamento para item ainda não gravado no Ato Concessório.
         If WorkED8->ED8_RECNO <> 0
            nQtdOld += WorkED8->ED8_QT_AC
         Else
            nQtdOld += WorkED8->ED8_QTD
         EndIf
      endIf
      WorkED8->(dbSkip())
   endDo
   
   If ED4->ED4_QT_LI > nQtdOld .or. nQtdOld == 0
      lRet := .T.
   endIf
   RestOrd(aOrd)   
   
Return lRet


*-------------------------------------------------------------------------------------------------*
Static Function CE400ACSaldo(cOpca,nTipo,cAlias)
*-------------------------------------------------------------------------------------------------*
//Local lReto := .T./*, nQtdAux:=0, nValAux:=0, nQtdOld:=0, nPos */
Local lReto := .T., nQtdAux:=0, nValAux:=0, nQtdOld:=0, nPos // By JPP - 14/11/2007 - 14:00

If cAlias == "ED9"

   ED0->(dbSetOrder(2))
   ED3->(dbSetOrder(2))

   ED0->(dbSeek(cFilED0+M->ED9_AC))
   //ED3->(dbSeek(cFilED3+M->ED9_AC+M->ED9_POSICA)) 
   //ED3->(dbSeek(cFilED3+M->ED9_AC+StrZero(M->ED9_SEQSIS,4)))
   ED3->(dbSeek(cFilED3+M->ED9_AC+StrZero(If(ValType(M->ED9_SEQSIS)=="N",M->ED9_SEQSIS,Val(M->ED9_SEQSIS)),3)))//JVR - 28/04/10
   

   If cOpca == "V"          //Valida
      If AvVldUn(ED3->ED3_UMPROD) .and. M->ED9_PESO > 0 // -- MPG - 06/02/2018
         nQtdAux := M->ED9_PESO
      Else
         nQtdAux := AVTransUnid(M->ED9_UM,ED3->ED3_UMPROD,ED3->ED3_PROD,M->ED9_QTD,.F.)
      EndIf
      nValAux := M->ED9_VL_FOB

      nPos := ASCAN(aSaldoAC,{|X| X[1]==ED3->ED3_AC .and. X[2]==ED3->ED3_SEQSIS})
      If nPos > 0
         nQtdAux += aSaldoAC[nPos,3]
         nValAux += aSaldoAC[nPos,4]
      EndIf

      If nTipo = INCLUIR
         If ED3->ED3_SALDO < nQtdAux
            MsgInfo(STR0066)//"Quantidade maior que saldo no A.C."
            lReto :=.F.
         EndIf
      Else
         If WorkED9->ED9_RECNO <> 0
            nQtdOld := WorkED9->ED9_QT_AC
         Else
            nQtdOld := WorkED9->ED9_QTD
         EndIf
         If (ED3->ED3_SALDO + nQtdOld) < nQtdAux
            MsgInfo(STR0066)//"Quantidade maior que saldo no A.C."
            lReto :=.F.
         EndIf
      EndIf
      If lReto
         If(nTipo = ALTERAR, nQtdAux-=nQtdOld, )
         //If(nQtdAux < 0, nQtdAux := 0, ) //02.jun.2009 - 720533 - Não deve zerar nQtdAux pois motifica saldo - HFD
         If nPos > 0
            aSaldoAC[nPos,3] := nQtdAux
            aSaldoAC[nPos,4] := nValAux
         Else
            AADD(aSaldoAC,{ED3->ED3_AC,ED3->ED3_SEQSIS,nQtdAux,nValAux})
         EndIf
      EndIf
   //EndIf

   //ED0->(dbSetOrder(1))
   //ED3->(dbSetOrder(1))

   // By JPP - 14/11/2007 - 14:00 /*
   ElseIf cOpca == "D"      //Devolve
      ED3->(RecLock("ED3",.F.))
      ED3->ED3_SALDO += ED9->ED9_QT_AC
      If AvVldUn(ED9->ED9_UM) // -- MPG - 06/02/2018 
         ED3->ED3_SALNCM += ED9->ED9_PESO
      Else
         ED3->ED3_SALNCM += AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,ED3->ED3_PROD,ED9->ED9_QT_AC)
      EndIf
      //If(M->EEC_COBCAM=="1",ED3->ED3_SAL_CO+=EE9->EE9_VL_AC,ED3->ED3_SAL_SE+=EE9->EE9_VL_AC)
      ED3->(msUnlock())
      ED9->ED9_QT_AC := 0
      ED9->ED9_VL_AC := 0
   ElseIf cOpca == "B"      //Baixa
      If  AvVldUn(ED3->ED3_UMPROD) //-- MPG - 06/02/2018 
         nQtdAux := ED9->ED9_PESO
      Else
         nQtdAux := AVTransUnid(Int_SO->NSOUM_NCM,ED3->ED3_UMPROD,ED3->ED3_PROD,Val(Int_SO->NSOQTD_NCM),.F.)
      EndIf
      ED3->(RECLOCK("ED3",.F.))
      //Saldo Valor
      ED3->ED3_SALDO -= nQtdAux
      If AvVldUn(ED9->ED9_UM) // -- MPG - 06/02/2018 
         ED3->ED3_SALNCM -= ED9->ED9_PESO
      Else
         ED3->ED3_SALNCM -= AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,ED3->ED3_PROD,nQtdAux)
      EndIf
      ED9->ED9_QT_AC  := nQtdAux
      ED3->(msUnlock())
   EndIf

ElseIf cAlias == "ED8"
   
   ED0->(dbSetOrder(2))
   ED4->(dbSetOrder(2))

   ED0->(dbSeek(cFilED0+M->ED8_AC))
   ED4->(dbSeek(cFilED4+M->ED8_AC+M->ED8_SEQSIS))

   If cOpca == "V"          //Valida
      If AvVldUn(ED4->ED4_UMITEM) .and. M->ED8_PESO > 0 //-- MPG - 06/02/2018
         nQtdAux := M->ED8_PESO
      Else
         nQtdAux := AVTransUnid(M->ED8_UM,ED4->ED4_UMITEM,ED4->ED4_ITEM,M->ED8_QTD,.F.)
      EndIf
      nValAux := M->ED8_VALEMB
          
      nPos := ASCAN(aSaldoAC,{|X| X[1]==ED4->ED4_AC .and. X[2]==ED4->ED4_SEQSIS})
      If nTipo = INCLUIR//JVR - 28/04/10 - incluido validaçao apenas no incluir.
         If nPos > 0
            nQtdAux += aSaldoAC[nPos,3]
            nValAux += aSaldoAC[nPos,4]
         EndIf

      //If nTipo = INCLUIR
         If (ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA) .and.;
         (ED4->ED4_QT_LI < nQtdAux .or. ED4->ED4_QT_DI < nQtdAux)
            MsgInfo(STR0066)//"Quantidade maior que saldo no A.C."
            lReto :=.F.
         ElseIf ED0->ED0_TIPOAC == GENERICO .and. ED4->ED4_NCM = NCM_GENERICA .and.;
         (ED4->ED4_VL_LI < nValAux .or. ED4->ED4_VL_DI < nValAux)
            MsgInfo(STR0067)//"Valor maior que saldo no A.C."
            lReto :=.F.
         EndIf
      Else
         If WorkED8->ED8_RECNO <> 0
            nQtdOld := WorkED8->ED8_QT_AC
         Else
            nQtdOld := WorkED8->ED8_QTD
         EndIf
         If (ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA) .and.;
         ((ED4->ED4_QT_LI + nQtdOld) < nQtdAux .or. (ED4->ED4_QT_DI +nQtdOld) < nQtdAux)
            MsgInfo(STR0066)//"Quantidade maior que saldo no A.C."
            lReto :=.F.
         ElseIf ED0->ED0_TIPOAC == GENERICO .and. ED4->ED4_NCM = NCM_GENERICA .and.;
         ((ED4->ED4_VL_LI + WorkED8->ED8_VALEMB)< nValAux .or. (ED4->ED4_VL_DI + WorkED8->ED8_VALEMB) < nValAux)
            MsgInfo(STR0067)//"Valor maior que saldo no A.C."
            lReto :=.F.
         EndIf
      EndIf
      If lReto
         If nTipo = ALTERAR
            nQtdAux -= nQtdOld
            nValAux -= WorkED8->ED8_VALEMB
         EndIf
         If(nQtdAux < 0, nQtdAux := 0, )
         If nPos > 0
            aSaldoAC[nPos,3] := nQtdAux
            aSaldoAC[nPos,4] := nValAux
         Else
            AADD(aSaldoAC,{ED4->ED4_AC,ED4->ED4_SEQSIS,nQtdAux,nValAux})
         EndIf
      EndIf
   EndIf

   ED0->(dbSetOrder(1))
   ED4->(dbSetOrder(1))
   
EndIf
// By JPP - 14/11/2007 - 14:00 */
Return lReto

*-----------------------------------------------------------------------------------------------*
Static Function CE400AtuAC(nTipo,cAlias)
*-----------------------------------------------------------------------------------------------*
Local nQtdAux:=0
Local cImport := ""

If cAlias == "ED9"
   If nTipo = ALTERAR .or. nTipo = ESTORNAR      //Devolve
      //ED0->(dbSeek(cFilED0+ED9->ED9_AC))                             
      //ED3->(dbSeek(cFilED3+M->ED9_AC+StrZero(M->ED9_SEQSIS,4)))
      ED3->(dbSeek(cFilED3+ED9->ED9_AC+StrZero(If(ValType(M->ED9_SEQSIS)=="N",M->ED9_SEQSIS,Val(M->ED9_SEQSIS)),3)))//JVR - 28/04/10
      ED3->(RecLock("ED3",.F.))
      ED3->ED3_SALDO += ED9->ED9_QT_AC
      If AvVldUn(ED3->ED3_UMNCM) // -- MPG - 06/02/2018
         ED3->ED3_SALNCM += ED9->ED9_PESO
      Else
         ED3->ED3_SALNCM += AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,ED3->ED3_PROD,ED9->ED9_QT_AC)
      EndIf
      //If(M->EEC_COBCAM=="1",ED3->ED3_SAL_CO+=EE9->EE9_VL_AC,ED3->ED3_SAL_SE+=EE9->EE9_VL_AC)
      ED3->ED3_SAL_CO+=ED9->ED9_VL_AC
      ED3->(msUnlock())
      ED9->ED9_QT_AC := 0
      ED9->ED9_VL_AC := 0
   EndIf

   If nTipo = INCLUIR .or. nTipo = ALTERAR      //Baixa
      //ED0->(dbSeek(cFilED0+WorkED9->ED9_AC))                         
      //ED3->(dbSeek(cFilED3+M->ED9_AC+StrZero(M->ED9_SEQSIS,4)))      
      ED3->(dbSeek(cFilED3+ED0->ED0_AC+StrZero(If(ValType(M->ED9_SEQSIS)=="N",M->ED9_SEQSIS,Val(M->ED9_SEQSIS)),3)))//JVR - 28/04/10
      If AvVldUn(ED3->ED3_UMPROD)  // -- MPG - 06/02/2018
         nQtdAux := WorkED9->ED9_PESO
      Else
         nQtdAux := AVTransUnid(WorkED9->ED9_UM,ED3->ED3_UMPROD,ED3->ED3_PROD,WorkED9->ED9_QTD,.F.)
      EndIf
      ED3->(RECLOCK("ED3",.F.))
      //Saldo Valor
      ED3->ED3_SALDO -= nQtdAux
      If AvVldUn(ED3->ED3_UMNCM)  // -- MPG - 06/02/2018
         ED3->ED3_SALNCM -= WorkED9->ED9_PESO
      Else
         ED3->ED3_SALNCM -= AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,ED3->ED3_PROD,nQtdAux)
      EndIf
      ED3->ED3_SAL_CO    -= WorkED9->ED9_VL_FOB
      WorkED9->ED9_QT_AC := nQtdAux
      WorkED9->ED9_VL_AC := WorkED9->ED9_VL_FOB
      ED3->(msUnlock())
   EndIf
ElseIf cAlias == "ED8"
   If nTipo = ALTERAR .or. nTipo = ESTORNAR      //Devolve
      If nTipo == ESTORNAR  .Or.  CE400VALID("ATU_DI")
         // GFP - 11/11/11
         IF AvFlags("SEQMI")
            cImport := ED8->ED8_IMPORT
         EndIf
         If Empty(ED8->ED8_SEQSIS) .OR. Empty(ED8->ED8_SEQMI)
             ED4->(dbSetOrder(7))
             ED4->(dbSeek(cFilED4+ED8->ED8_AC+ED8->ED8_NCM+ED8->ED8_COD_I+ED8->ED8_UMNCM+cImport))
         Else
             //ED4->(dbSeek(xFilial("ED4")+cAC+cSAC))
             
             IF AvFlags("SEQMI") .AND. Empty(ED8->ED8_DI_NUM)
                ED4->(dbSetOrder(8))  //ED4_FILIAL+ED4_AC+ED4_SEQMI
                ED4->(dbSeek(cFilED4+ED8->ED8_AC+ED8->ED8_SEQMI))
             ELSE   
                ED4->(dbSetOrder(2)) //ED4_FILIAL+ED4_AC+ED4_SEQSIS
                ED4->(dbSeek(cFilED4+ED8->ED8_AC+ED8->ED8_SEQSIS))
             ENDIF
         EndIf       
         
         IF ED4->(EOF())
           RETURN .F.
         ENDIF
         ED4->(RecLock("ED4",.F.))
         If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
            ED4->ED4_QT_LI  += ED8->ED8_QT_AC
            ED4->ED4_QT_DI  += ED8->ED8_QT_AC
            If AvVldUn(ED4->ED4_UMNCM)  //-- MPG - 06/02/2018
               ED4->ED4_SNCMLI += ED8->ED8_PESO
               ED4->ED4_SNCMDI += ED8->ED8_PESO
            Else
               ED4->ED4_SNCMLI += AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,ED8->ED8_QT_AC)
               ED4->ED4_SNCMDI += AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,ED8->ED8_QT_AC)
            EndIf
         EndIf
         ED4->ED4_VL_LI  += ED8->ED8_VL_AC
         ED4->ED4_VL_DI  += ED8->ED8_VL_AC
         ED4->(msUnlock())
      EndIf
      ED8->ED8_QT_AC := 0
      ED8->ED8_VL_AC := 0
   EndIf

   If nTipo = INCLUIR .or. nTipo = ALTERAR      //Baixa
      If nTipo == INCLUIR  .Or.  CE400VALID("ATU_DI")
         // GFP - 11/11/11
         If AvFlags("SEQMI")
            cImport := WorkED8->ED8_IMPORT
         EndIf
         If Empty(ED8->ED8_SEQSIS) .OR. Empty(ED8->ED8_SEQMI)
             ED4->(dbSetOrder(7))
             //ED4->(dbSeek(cFilED4+ED8->ED8_AC+ED8->ED8_NCM+ED8->ED8_COD_I+ED8->ED8_UMNCM))
             ED4->(dbSeek(cFilED4+ED0->ED0_AC+WorkED8->ED8_NCM+WorkED8->ED8_COD_I+WorkED8->ED8_UMNCM+cImport))
         Else
             //ED4->(dbSeek(xFilial("ED4")+cAC+cSAC))
             
             IF AvFlags("SEQMI") .AND. Empty(ED8->HAWB)
                ED4->(dbSetOrder(8)) //ED4_FILIAL+ED4_AC+ED4_SEQMI
                ED4->(dbSeek(cFilED4+ED0->ED0_AC+WorkED8->ED8_SEQMI))
             ELSE             
                ED4->(dbSetOrder(2)) //ED4_FILIAL+ED4_AC+ED4_SEQSIS
                ED4->(dbSeek(cFilED4+ED0->ED0_AC+WorkED8->ED8_SEQSIS))
             ENDIF
         ENDIF        
         IF ED4->(EOF())
           RETURN .F.
         ENDIF     
         If AvVldUn(ED4->ED4_UMITEM)  //-- MPG - 06/02/2018
            nQtdAux := WorkED8->ED8_PESO
         Else
            nQtdAux := AVTransUnid(WorkED8->ED8_UMNCM,ED4->ED4_UMITEM,ED4->ED4_ITEM,WorkED8->ED8_QTDNCM,.F.)
         EndIf
         ED4->(RECLOCK("ED4",.F.))
         ED4->ED4_VL_LI  -=  WorkED8->ED8_VALEMB
         ED4->ED4_VL_DI  -=  WorkED8->ED8_VALEMB
         WorkED8->ED8_VL_AC  :=  WorkED8->ED8_VALEMB
         If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
            ED4->ED4_QT_LI  -= nQtdAux
            ED4->ED4_QT_DI  -= nQtdAux
            If AvVldUn(ED4->ED4_UMNCM)  //-- MPG - 06/02/2018
               ED4->ED4_SNCMLI -= WorkED8->ED8_PESO
               ED4->ED4_SNCMDI -= WorkED8->ED8_PESO
            Else
               ED4->ED4_SNCMLI -= AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQtdAux)
               ED4->ED4_SNCMDI -= AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQtdAux)
            EndIf
            WorkED8->ED8_QT_AC  := nQtdAux
         EndIf
         ED4->(msUnlock())
      EndIf
   EndIf
EndIf

//ED0->(dbGoTo(nRecED0))

Return .T.

*-----------------------------------------------------------------------------------------------*
Static Function CE400DelWorks()
*-----------------------------------------------------------------------------------------------*
Local W

FOR W := 1 TO LEN(aTabelas)
   If !Empty(aTabelas[W,1])
      (aTabelas[W,1])->(E_EraseArq(aTabelas[W,2]))
   Else
      FErase(aTabelas[W,2]+TEOrdBagExt())
   EndIf
NEXT
aTabelas:={}

dbSelectArea("ED0")

Return .T.

*-----------------------------------------------------------------------------------------------*
Static Function LimpaTabelas()
*-----------------------------------------------------------------------------------------------*
Local W

ProcRegua(Len(aTabelas))

FOR W := 1 TO LEN(aTabelas)
   IncProc(STR0030+Alltrim(Str(W))) //"Criando Arquivo Temporario "
   If !Empty(aTabelas[W,1])
      (aTabelas[W,1])->(avzap())
   EndIf
NEXT

Return .T.

*-----------------------------------------------------------------------------------------------*
Static Function CE400CNPJ(nOpc)
*-----------------------------------------------------------------------------------------------*
cLin := 24

@cLin,2 SAY AVSX3("ED0_CNPJ1",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ1 PICTURE AVSX3("ED0_CNPJ1",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ2",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ2 PICTURE AVSX3("ED0_CNPJ2",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ3",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ3 PICTURE AVSX3("ED0_CNPJ3",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ4",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ4 PICTURE AVSX3("ED0_CNPJ4",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ5",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ5 PICTURE AVSX3("ED0_CNPJ5",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ6",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ6 PICTURE AVSX3("ED0_CNPJ6",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ7",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ7 PICTURE AVSX3("ED0_CNPJ7",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ8",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ8 PICTURE AVSX3("ED0_CNPJ8",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ9",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ9 PICTURE AVSX3("ED0_CNPJ9",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ10",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ10 PICTURE AVSX3("ED0_CNPJ10",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

cLin := 24

@cLin,150 SAY AVSX3("ED0_CNPJ11",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ11 PICTURE AVSX3("ED0_CNPJ11",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ12",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ12 PICTURE AVSX3("ED0_CNPJ12",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ13",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ13 PICTURE AVSX3("ED0_CNPJ13",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ14",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ14 PICTURE AVSX3("ED0_CNPJ14",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ15",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ15 PICTURE AVSX3("ED0_CNPJ15",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ16",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ16 PICTURE AVSX3("ED0_CNPJ16",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ17",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ17 PICTURE AVSX3("ED0_CNPJ17",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ18",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ18 PICTURE AVSX3("ED0_CNPJ18",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ19",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ19 PICTURE AVSX3("ED0_CNPJ19",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ20",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ20 PICTURE AVSX3("ED0_CNPJ20",6) SIZE 65,08 PIXEL of oFldAC2 WHEN .F.
cLin += 11

Return .T.

//Verifica os campos obrigatorios apenas na comprovaçao do AC -ED8
*-----------------------------------------------------------------------------------------------*
Static function EDCED8OBR(nOpca)
*-----------------------------------------------------------------------------------------------*
IF EMPTY(M->ED8_AC)
  M->ED8_AC := M->ED0_AC
  //msgstop(STR0045)//"Para a correta comprovação do AC, o campo 'AC' deve ser preenchido."
  //Return .F.                                                                     2
ENDIF
//ED4->(dbSetOrder(1))

//GFP - 11/11/11
IF AvFlags("SEQMI") .AND. Empty(M->ED8_DI_NUM)
   ED4->(dbSetOrder(8))
ELSE
   ED4->(dbSetOrder(2))//JVR - 28/04/10 - alterado o index para 2, para poder executar o seek corretamente.
ENDIF

IF EMPTY(M->ED8_SEQSIS) .OR. EMPTY(M->ED8_SEQMI)
  msgstop(STR0046)//"Para a correta comprovação do AC, o campo 'Seq. AC' deve ser preenchido."
  Return .F. 

//29.mai.2009 - Evita que o usuário entre com uma Seq. inválida - HFD
ELSEIF !ED4->(dbSeek(xFilial("ED4")+Avkey(M->ED8_AC,"ED4_AC")+ IF(AvFlags("SEQMI") .AND. Empty(M->ED8_DI_NUM),Avkey(M->ED8_SEQMI,"ED4_SEQMI"),Avkey(M->ED8_SEQSIS,"ED4_SEQSIS"))))//JVR - 28/04/10 - inserido os AvKey.
  msgStop(STR0048)//"Seq. Ac. não permitida para esse ato concessório" 
  Return .F. 
ENDIF  
If nOpca==INCLUIR//JVR - 28/04/10 - validaçao apenas no incluir.
   EDC_ED8EXT(3)
EndIf
return .T. 

/*
*------------------------------------------*
Static Function BrowseCpos(cAlias,cAliasDad)
*------------------------------------------*
Local aOrd := SaveOrd("SX3")
LOCAL aRet := {}
LOCAL aField

Default cAliasDad := cAlias

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))

Do While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias

   IF SX3->X3_NIVEL > cNivel .or. Upper(SX3->X3_BROWSE) != "S" .or. SX3->X3_CONTEXT == "V"
      SX3->(dbSkip())
      Loop
   Endif
   
   aField := { Alltrim(SX3->X3_CAMPO),"", OemToAnsi(X3TITULO()),Alltrim(SX3->X3_PICTURE) }

   IF aField[1] != Nil
      aAdd(aRet,aField)
   Endif
   
   SX3->(dbSkip())
Enddo

RestOrd(aOrd)

Return aRet
*/
