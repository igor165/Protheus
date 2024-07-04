#INCLUDE "EDCDR150.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"


#define VISUALIZAR 2
#define INCLUIR    3
#define ALTERAR    4
#define ESTORNAR   5
#define AJ         STR0001 //"AJUSTE"
#define DE         STR0002 //"DEFERIMENTO"
#define GENERICO      "06"
#define NCM_GENERICA  "99999999"

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2


/*
Programa        : EDCDR150.PRW
Objetivo        : Reabilitação de Saldos de A.C. - EDCCA150
                  Deferimento de L.I.            - EDCDF150
Autor           : Gustavo Carreiro - GFC
Data/Hora       :
Obs.            :
*/

*-----------------------------------------------------------------------------------------------*
Function EDCCA150()
*-----------------------------------------------------------------------------------------------*
EDCDR150(STR0001) //"AJUSTE"
Return .T.

*-----------------------------------------------------------------------------------------------*
Function EDCDF150()
*-----------------------------------------------------------------------------------------------*
EDCDR150(STR0002) //"DEFERIMENTO"
Return .T.

*-----------------------------------------------------------------------------------------------*
Function EDCDR150(cTip)
*-----------------------------------------------------------------------------------------------*
Private aBotoes:={}, aBotoes2:={}, aTabelas:={}
Private cArqRpt, cTitRpt, cSeqRel:="", aRetCrw, cCadastro
Private cFilED0:=xFilial("ED0"), cFilSYT:=xFilial("SYT"), cFilED4:=xFilial("ED4")
Private cFilSW5:=xFilial("SW5"), cFilSW4:=xFilial("SW4"), cFilSWP:=xFilial("SWP")
Private cFilEIS:=xFilial("EIS"), cFilSA6:=xFilial("SA6"), cFilSW8:=xFilial("SW8")
Private lInverte := .F., cMarca := GetMark(), cNomDbfC := "EDCDR1" 
Private aSelCpos := {}, aArqs:={}, cNomDbfD := "EDCDR2", cFilED2:=xFilial("ED2")
Private aCamposC := {}, aCamposD:={}, cTipo := cTip
Private  aRotina:= MenuDef(ProcName(1))
sx3->(dbSetOrder(2))
Private lMultiFil  := VerSenha(115)  ;
                      .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EE9","X2_MODO") == "E" ;
                      .And.  Posicione("SX2",1,"SW8","X2_MODO") == "E" ;
                      .And.  SX3->(DbSeek("ED1_FILORI"));
                      .And.  SX3->(DbSeek("ED2_FILORI"));
                      .And.  SX3->(DbSeek("EDD_FILIMP"));
                      .And.  SX3->(DbSeek("EDD_FILEXP"))
Private aFil := IIF(lMultiFil,AvgSelectFil(.F.,,"ED0"),{cFilED0})

If !AvFlags("INDICEED9")
   Return .F.
EndIf

If AmIin(50)

   cCadastro := If(cTipo==AJ,STR0003,STR0004) //"Reabilitação de Saldos do A.C."###"Análise/Deferimento de LI"
   
   Processa({|| DR150Works()}, STR0007) //"Inicializando Ambiente"
      
   ED0->(DbSetFilter({|| ED0->ED0_MODAL = "2" }, "ED0->ED0_MODAL = '2'"))

   ED0->(dbSetOrder(1))
   mBrowse(,,,,"ED0")
   
   Set Filter To

   DR150DelWorks()

EndIf

Return .T.
 

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 31/01/07 - 14:27
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina  := {}
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

AADD(aRotina,{ STR0005  ,"AxPesqui"    ,0,1}) //"Pesquisar"
AADD(aRotina,{ STR0006  ,"EDCDR150Man" ,0,2}) //"Manutenção"
   
If(EasyEntryPoint("EDCDR150"),ExecBlock("EDCDR150",.F.,.F.,"MBROWSE"),)

If cOrigem $ "EDCCA150" // Reabilitação de Saldos de A.C.
   If EasyEntryPoint("DCA150MNU")
	  aRotAdic := ExecBlock("DCA150MNU",.f.,.f.)
	  If ValType(aRotAdic) == "A"
         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
      EndIf
   EndIf
ElseIf cOrigem $ "EDCDF150" //Deferimento de L.I.
   If EasyEntryPoint("DDF150MNU")
	  aRotAdic := ExecBlock("DDF150MNU",.f.,.f.)
	  If ValType(aRotAdic) == "A"
         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
      EndIf
   EndIf 
EndIf

Return aRotina

*-----------------------------------------------------------------------------------------------*
Function EDCDR150Man(cAlias,nReg,nOpc)
*-----------------------------------------------------------------------------------------------*
Local oDlg, nInd, nOp
Private oMark, oBtnOk, oBtnCan
Private aHeader := {}, aCAMPOS := ARRAY(0), oFont

If Empty(ED0->ED0_AC)
   Help(" ",1,"AVG0005262") //MsgInfo(STR0009) //"Nenhum LI relacionado ao A.C."
   Return .T.
EndIf

oMainWnd:ReadClientCoords()//So precisa declarar uma vez para o programa todo

Processa({|| LimpaTabelas() },STR0007) //"Inicializando Ambiente"

Processa({|| DR150GrvWorks()}, STR0008) //"Gravando Arquivo Temporario"

If WorkLI->(EOF()) .and. WorkLI->(BOF())
   Help(" ",1,"AVG0005262") //MsgInfo(STR0009) //"Nenhum LI relacionado ao A.C."
Else

   cSEQREL :=GetSXENum("SY0","Y0_SEQREL")
   CONFIRMSX8()
   aRetCrw := CrwNewFile(aArqs)

   DEFINE MSDIALOG oDlg TITLE cCadastro FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO ;
   oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

      nLinha := (oDlg:nClientHeight-6)/2
      oMark:= MsSelect():New("WorkLI","WK_MARCA",,aSelCpos,@lInverte,@cMarca,{15,1,nLinha,COLUNA_FINAL})
      oMark:oBrowse:bWhen:={|| DBSELECTAREA("WorkLI"),.T.}
      oMark:bAval:={|| DR150Marca(.F.)}

      Aadd(aBotoes,{"PESQUISA",{|| DR150PesqLI() }, STR0010,STR0048}) //"Pesquisar LI" - //LRL 17/05/04 - "Pesquisa"
      Aadd(aBotoes,{"LBTIK"   ,{|| Processa({|| DR150Marca(.T.)},STR0011),WorkLI->(dbGoTop()) },STR0011,STR0049}) //"Marca/Desmarca Todos"###"Marca/Desmarca Todos" - //LRL 17/05/04  "Todos"
      oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOp:=1,oDlg:End()},{||nOp:=0,oDlg:End()},,aBotoes)) //LRL 30/04/04 - ALinhamento MDI //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   If nOp = 1
      DR150Confirma()
   Else
      CrwCloseFile(aRetCrw,.T.) // Fecha e apaga os arquivos temporarios do Crystal...
   EndIf
EndIf

aBotoes:={}
cCadastro := If(cTipo==AJ,STR0003,STR0004) //"Reabilitação de Saldos do A.C."###"Análise/Deferimento de LI"
msUnlockAll()

Return .T.

*------------------------------------------------------------------------------------------------*
Function DR150Works()
*------------------------------------------------------------------------------------------------*
Local FileWork1, FileWork2, FileWork3, FileWork4, FileWork5, FileWork6
Local aSemSX3:={}
Private aHeader[0], aCampos:=Array(ED0->(fCount()))  //E_CriaTrab utiliza

ProcRegua(2)

aSemSX3 := {{"WK_MARCA"  ,"C",Len(cMarca),0},;
            {"WK_REGIST" ,"C",AVSX3("WP_REGIST",3),0},;
            {"WK_NCM"    ,"C",AVSX3("WP_NCM",3),0},;
            {"WK_PGI_NUM","C",AVSX3("WP_PGI_NUM",3),0},;
            {"WK_SEQ_LI" ,"C",AVSX3("WP_SEQ_LI",3),0},;
            {"WK_DT_ENVD","D",AVSX3("WP_DT_ENVD",3),0},;
            {"WK_IMPORT" ,"C",AVSX3("W4_IMPORT",3),0}}

aCamposC := {{"WK_SEQREL  ","C", 08,0},;
             {"WK_CABEI   ","C", AVSX3("YT_CIDADE",3)+35,0},;
             {"WK_BANCO   ","C", AVSX3("A6_NOME",3),0},;
             {"WK_ENDB    ","C", AVSX3("A6_END",3),0},;
             {"WK_MUNB    ","C", AVSX3("A6_MUN",3)+3+AVSX3("A6_EST",3),0},;
             {"WK_ATT     ","C", 40,0},;
             {"WK_ASSUNTO ","C", 80,0},;
             {"WK_IMP     ","C", AVSX3("YT_NOME",3),0},;
             {"WK_IMPR    ","C", AVSX3("YT_NOME_RE",3),0},;
             {"WK_IMP1    ","C", 200,0},;
             {"WK_IMP2    ","C", 150,0},;
             {"WK_CGCI    ","C", 24,0},;
             {"WK_AC      ","C", 16,0},;
             {"WK_SOLIC   ","C", 150,0},;
             {"WK_FAX     ","C", AVSX3("YT_FAX_IMP",3),0},;
             {"WK_CC      ","C", AVSX3("A6_NUMCON",3),0},;
             {"WK_AG      ","C", AVSX3("A6_AGENCIA",3),0},;
             {"WK_ASS     ","C", 200,0},;
             {"WK_FLAG    ","C", 01,0},;
             {"WK_USI     ","C", 40,0}}

aCamposD := {{"WKD_SEQREL  ","C", 08,0},;
             {"WKD_LI      ","C", AVSX3("WP_REGIST",3)+2,0},;  //+2 por causa da Picture
             {"WKD_NCM     ","C", AVSX3("WP_NCM",3)+2,0},;     //+2 por causa da Picture
             {"WKD_LISUB   ","C", 100,0},;
             {"WKD_IMP     ","C", AVSX3("YT_NOME_RE",3),0}}

IF Select("WorkId") > 0
   cArqRpt := WorkId->EEA_ARQUIV
   cTitRpt := AllTrim(WorkId->EEA_TITULO)
Else
   cArqRpt := "EDCDR150.rpt"
   If cTipo == AJ
      cTitRpt := STR0012 //"Relatório de Reabilitação de Saldo de A.C."
   Else
      cTitRpt := STR0013 //"Relatório de Análise/Deferimento de LI"
   EndIf
Endif

AADD(aArqs,{cNomDbfC,aCamposC,"CAB","WK_SEQREL"})
AADD(aArqs,{cNomDbfD,aCamposD,"DET","WKD_SEQREL"})

IncProc(STR0014+"1") //"Criando Arquivo Temporário - "

//WorkLI

If lMultiFil //AJP 02/07/2007
   aSelCpos := { {"WK_MARCA"   ,,""},;
                 {"WK_FILIAL",,3},;
                 {"WK_REGIST"  ,,AVSX3("WP_REGIST" ,5)},;
                 {"WK_DT_ENVD" ,,AVSX3("WP_DT_ENVD",5)},;
                 {{|| DR150Busca("IMP")} ,,AVSX3("W4_IMPORT" ,5)},;
                 {"WK_PGI_NUM" ,,AVSX3("WP_PGI_NUM",5)},;
                 {"WK_SEQ_LI"  ,,AVSX3("WP_SEQ_LI" ,5)} }
Else
   aSelCpos := { {"WK_MARCA"   ,,""},;
                 {"WK_REGIST"  ,,AVSX3("WP_REGIST" ,5)},;
                 {"WK_DT_ENVD" ,,AVSX3("WP_DT_ENVD",5)},;
                 {{|| DR150Busca("IMP")} ,,AVSX3("W4_IMPORT" ,5)},;
                 {"WK_PGI_NUM" ,,AVSX3("WP_PGI_NUM",5)},;
                 {"WK_SEQ_LI"  ,,AVSX3("WP_SEQ_LI" ,5)} }
EndIf
//TRP - 02/01/07 - Campos do WalkThru
AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

IncProc(STR0014+"2") //"Criando Arquivo Temporário - "
FileWork1:=E_CriaTrab("SWP",aSemSX3,"WorkLI")
Aadd(aTabelas,{"WorkLI",FileWork1})
FileWork2:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork2})
/*FileWork3:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork3})*/

IndRegua("WorkLI",FileWork1+TEOrdBagExt(),"WK_REGIST")
IndRegua("WorkLI",FileWork2+TEOrdBagExt(),"WK_MARCA+WK_REGIST")
//IndRegua("WorkLI",FileWork3+OrdBagExt(),"ED9_RE")

SET INDEX TO (FileWork1+TEOrdBagExt()),(FileWork2+TEOrdBagExt())//,(FileWork3+OrdBagExt())

Return .T.

*----------------------------------------------------------------------------------------------*
Static Function DR150GrvWorks()
*----------------------------------------------------------------------------------------------*
Local aLis := {}
Local nFilInd :=0
ProcRegua(1)

SW4->(dbSetOrder(1))
SWP->(dbSetOrder(1))
SW5->(dbSetOrder(9))
ED2->(dbSetOrder(1))

For nFilInd :=1 to Len(aFil)
   If lMultiFil
      cFilSW5 := aFil[nFilInd]
      cFilSWP := aFil[nFilInd]
      cFilSW4 := aFil[nFilInd]
   EndIf

   SW5->(dbSeek(cFilSW5+ED0->ED0_AC))

   Do While !SW5->(EOF()) .and. SW5->W5_FILIAL == cFilSW5 .and. SW5->W5_AC == ED0->ED0_AC
    
      If SWP->(dbSeek(cFilSWP+SW5->W5_PGI_NUM+SW5->W5_SEQ_LI)) .and.;
         !Empty(SWP->WP_REGIST) .and. (aScan(aLis,SWP->WP_REGIST)) = 0 .and.;
         If(cTipo==AJ,!Empty(SWP->WP_DT_ENVD),.T.)
         SW4->(dbSeek(cFilSW4+SW5->W5_PGI_NUM))
         WorkLI->(RecLock("WorkLI",.T.))
         If cTipo == DE .and. Empty(SWP->WP_DT_ENVD)
            WorkLI->WK_MARCA   := cMarca
         Else
            WorkLI->WK_MARCA   := Space(Len(cMarca))
         EndIf              
         If (lMultiFil,WorkLI->WK_FILIAL  := aFil[nFilInd],)
         WorkLI->WK_REGIST  := SWP->WP_REGIST
         WorkLI->WK_PGI_NUM := SWP->WP_PGI_NUM
         WorkLI->WK_SEQ_LI  := SWP->WP_SEQ_LI
         WorkLI->WK_DT_ENVD := SWP->WP_DT_ENVD
         WorkLI->WK_NCM     := SWP->WP_NCM
         WorkLI->WK_IMPORT  := SW4->W4_IMPORT
         aAdd(aLis,SWP->WP_REGIST)
      WorkLI->TRB_ALI_WT:= "SWP"
      WorkLI->TRB_REC_WT:= SWP->(Recno())
         WorkLI->(msUnlock())
      EndIf
      SW5->(dbSkip())
   EndDo
Next
SW5->(dbSetOrder(1))

WorkLI->(dbGoTop())

IncProc(STR0015) //"Processando..."

Return .T.

*----------------------------------------------------------------------------------------------*
Static Function DR150Confirma()
*----------------------------------------------------------------------------------------------*
Local nOp:=0, aUsi:={}, cCargo, cMail
Private M->A6_COD:=Space(Len(SA6->A6_COD))
Private cATT:=Space(40), cUsi

PswOrder(2)
If PswSeek( cUserName, .T. )
   aUsi   := PswRet()
   cUsi   := aUsi[1][4] // Retorna nome completo do usuário
   cCargo := aUsi[1][13]
   cMail  := aUsi[1][14]
EndIf

WorkLI->(dbSetOrder(2))
If WorkLI->(dbSeek(cMarca))

   DEFINE MSDIALOG oDlg TITLE STR0016 ; //"Dados da Impressão"
          FROM 12,03 TO 22,55 /*12,05 TO 22,50*/ OF oMainWnd   // GFP - 27/09/2011 - Ajuste de janela para servir as versões 11.0 e 11.5

      @02,02 SAY   STR0045  of oDlg  //"Cód. Banco"
      @02,08 MSGET M->A6_COD F3 "BCO" PICT AVSX3("A6_COD",6) VALID ExistCpo("SA6",M->A6_COD) SIZE 60,8
      @03,02 SAY   STR0017 of oDlg   //"Att"
      @03,08 MSGET cATT VALID !Empty(cATT) SIZE 60,8
      @04,02 SAY   STR0046  of oDlg  //"Assinatura"
      @04,08 MSGET cUsi SIZE 80,8

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOp:=1,oDlg:End()},{||nOp:=0,oDlg:End()}) CENTERED

   If nOp=1
      Processa({|| DR150GrvRel()}, If(cTipo==AJ,STR0018,STR0019)) //"Processando Reabilitação de Saldos"###"Processando Análise/Deferimento"
      CrwPreview(aRetCrw,cArqRpt,cTitRpt,cSeqRel)
   Else
      CrwCloseFile(aRetCrw,.T.) // Fecha e apaga os arquivos temporarios do Crystal...
   EndIf
Else
   Help(" ",1,"AVG0005263") //MsgInfo(STR0020) //"Nenhum registro marcado para impressão"
   CrwCloseFile(aRetCrw,.T.) // Fecha e apaga os arquivos temporarios do Crystal...
EndIf

WorkLI->(dbSetOrder(1))

Return .T.

*-----------------------------------------------------------------------------------------------*
Static Function DR150DelWorks()
*-----------------------------------------------------------------------------------------------*
Local W

FOR W := 1 TO LEN(aTabelas)
   If aTabelas[W,2] <> NIL
      If !Empty(aTabelas[W,1])
         (aTabelas[W,1])->(E_EraseArq(aTabelas[W,2]))
      Else
         FERASE(aTabelas[W,2]+TEOrdBagExt())
      EndIf
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

*------------------------------------------------------------------------------------------------*
Static Function DR150Busca(cCampo)
*------------------------------------------------------------------------------------------------*
Local xRet
If cCampo == "IMP"
   SYT->(dbSeek(cFilSYT+SW4->W4_IMPORT))
   xRet := SYT->YT_NOME
EndIf
Return xRet

*------------------------------------------------------------------------------------------------*
Static Function DR150GetLiSub()
*------------------------------------------------------------------------------------------------*
Local cRet:=""

EIS->(dbSetOrder(1))
SW5->(dbSetOrder(7))
If lMultiFil //AJP 02/07/2007
   cFilSW5 := WorkLI->WK_FILIAL
   cFilEIS := WorkLI->WK_FILIAL
EndiF

SW5->(dbSeek(cFilSW5+WorkLI->WK_PGI_NUM+WorkLI->WK_SEQ_LI))
Do While !SW5->(EOF()) .and. cFilSW5==SW5->W5_FILIAL .and. SW5->W5_PGI_NUM==WorkLI->WK_PGI_NUM .and.;
SW5->W5_SEQ_LI == WorkLI->WK_SEQ_LI
   EIS->(dbSeek(cFilEIS+SW5->W5_PO_NUM+SW5->W5_COD_I+SW5->W5_POSICAO))
   Do While !EIS->(EOF()) .and. EIS->EIS_FILIAL == cFilEIS .and. ;
   EIS->EIS_PO_NUM == SW5->W5_PO_NUM .and. EIS->EIS_COD_I == SW5->W5_COD_I .AND. EIS->EIS_POSICA == SW5->W5_POSICAO
      cRet := EIS->EIS_REGIST
   EIS->(dbSkip())
   EndDo
   SW5->(dbSkip())
EndDo

SW5->(dbSetOrder(1))

Return cRet

*-------------------------------------------------------------------------------------------------*
Static Function DR150Marca(lTodos)
*-------------------------------------------------------------------------------------------------*
Local cCheck

If lTodos
   WorkLI->(dbGoTop())
   cCheck := If(WorkLI->WK_MARCA==cMarca,Space(Len(cMarca)),cMarca)
   Do While !WorkLI->(EOF())
      WorkLI->(RecLock("WorkLI",.F.))
      WorkLI->WK_MARCA := cCheck
      WorkLI->(msUnlock())
      WorkLI->(dbSkip())
   EndDo
   WorkLI->(dbGoTop())
Else
   WorkLI->(RecLock("WorkLI",.F.))
   WorkLI->WK_MARCA := If(WorkLI->WK_MARCA==cMarca,Space(Len(cMarca)),cMarca)
   WorkLI->(msUnlock())
EndIf

Return .T.

*-------------------------------------------------------------------------------------------------*
Static Function DR150GrvRel()
*-------------------------------------------------------------------------------------------------*
Local aMeses, cData
Local cPictCep:= AVSX3("YT_CEP",6), cPictCgc:= AVSX3("YT_CGC",6)
Local cPictConta:= AVSX3("A6_NUMCON",6), cPictAg:= AVSX3("A6_AGENCIA",6)
Local cPictReg:= AVSX3("WP_REGIST",6), cPictNcm:= AVSX3("YD_TEC",6)

Begin TransAction

ProcRegua(2)

aMeses:= {STR0021, STR0022, STR0023, STR0024, STR0025, STR0026, STR0027, STR0028, STR0029, STR0030, STR0031, STR0032} //"Janeiro"###"Fevereiro"###"Marco"###"Abril"###"Maio"###"Junho"###"Julho"###"Agosto"###"Setembro"###"Outubro"###"Novembro"###"Dezembro"
cData := StrZero(Day(dDataBase),2)+STR0033+Alltrim(aMeses[Month(dDataBase)])+; //" de "
         STR0033+Str(Year(dDataBase),4)+"." //" de "
SYT->(dbSeek(cFilSYT+ED0->ED0_IMPORT))
SA6->(dbSeek(cFilSA6+M->A6_COD))
CAB->(RecLock("CAB",.T.))
CAB->WK_SEQREL  := cSeqRel
CAB->WK_CABEI   := Alltrim(Upper(Left(SYT->YT_CIDADE,1)))+Alltrim(Lower(SubStr(SYT->YT_CIDADE,2,Len(SYT->YT_CIDADE))))+", "+cData
CAB->WK_BANCO   := Alltrim(SA6->A6_NOME)
CAB->WK_ENDB    := Alltrim(SA6->A6_END)
CAB->WK_MUNB    := Alltrim(SA6->A6_MUN) + " / " + Alltrim(SA6->A6_EST)
CAB->WK_ATT     := cATT
CAB->WK_ASSUNTO := If(cTipo==AJ,STR0034,STR0035) //"Reabilitação de Saldo do A.C."###"Solicitação de Anuência DRAWBACK"
CAB->WK_IMP     := SYT->YT_NOME
CAB->WK_IMPR    := SYT->YT_NOME_RE
CAB->WK_IMP1    := Alltrim(Left(SYT->YT_ENDE,1))+Alltrim(Lower(SubStr(SYT->YT_ENDE,2,Len(SYT->YT_ENDE))))+", "+Alltrim(Str(SYT->YT_NR_END))+" - "+;
                   Alltrim(Left(SYT->YT_BAIRRO,1))+Alltrim(Lower(SubStr(SYT->YT_BAIRRO,2,Len(SYT->YT_BAIRRO))))+STR0036+Alltrim(Trans(SYT->YT_CEP,cPictCep))+" - "+; //" - CEP: "
                   Alltrim(Left(SYT->YT_CIDADE,1))+Alltrim(Lower(SubStr(SYT->YT_CIDADE,2,Len(SYT->YT_CIDADE))))+"/"+Alltrim(SYT->YT_ESTADO)
CAB->WK_IMP2    := STR0037+Alltrim(SYT->YT_TEL_IMP)+STR0038+Alltrim(SYT->YT_FAX_IMP) //"Tel "###" - Fax "

CAB->WK_CGCI    := STR0047+Alltrim(Trans(SYT->YT_CGC,cPictCgc)) //"CNPJ: "
CAB->WK_AC      := Left(ED0->ED0_AC,4)+"-"+Substr(ED0->ED0_AC,5,2)+"/"+Substr(ED0->ED0_AC,7,6)+"-"+Right(ED0->ED0_AC, 1)//Trans(ED0->ED0_AC,AVSX3("ED0_AC",6))
If cTipo==AJ
   CAB->WK_SOLIC:= STR0040 //"Vimos através da presente, solicitar a esta Secretaria reabilitação de saldo do A.C. correspondente a(s) L.I.(s) abaixo relacionada(s):" //STR0040 //"Vimos pôr meio desta solicitar reabilitação de saldo dos A.C.s correspondentes ao LI abaixo relacionado:"
Else
   CAB->WK_SOLIC:= STR0041 //"Vimos através da presente, solicitar a esta Secretaria a Anuência na(s) L.I.(s) abaixo relacionada(s):" //STR0041 //"Vimos pôr meio desta solicitar análise/deferimento do LI abaixo relacionado:"
EndIf

CAB->WK_ASS    := cUsi
CAB->WK_FAX    := Alltrim(SA6->A6_FAX) //Alltrim(SYT->YT_FAX_IMP)
CAB->WK_CC     := Trans(SA6->A6_NUMCON, cPictConta)
CAB->WK_AG     := Trans(SA6->A6_AGENCIA, cPictAg)

CAB->(msUnlock())
IncProc(STR0042) //"Capa do Relatório"

ED4->(dbSetOrder(2))
SW5->(dbSetOrder(7))
SW8->(dbSetOrder(5))
Do While !WorkLI->(EOF()) .and. WorkLI->WK_MARCA == cMarca
   SYT->(dbSeek(cFilSYT+WorkLI->WK_IMPORT))
   DET->(RecLock("DET",.T.))
   DET->WKD_SEQREL := cSeqRel
   DET->WKD_LI     := Trans(WorkLI->WK_REGIST,cPictReg)
   DET->WKD_NCM    := Trans(WorkLI->WK_NCM, cPictNcm)
   DET->WKD_LISUB  := DR150GetLiSub()
   DET->WKD_IMP    := SYT->YT_NOME_RE
   DET->(msUnlock())
   If cTipo == AJ
      DR150Saldos()
   Else
      DR150DtEnv()
   EndIf
   WorkLI->(dbSkip())
EndDo
ED4->(dbSetOrder(1))
SW5->(dbSetOrder(1))
SW8->(dbSetOrder(1))
IncProc(STR0043) //"Itens do Relatório"

End TransAction

Return .T.

*------------------------------------------------------------------------------------------------*
Static Function DR150Saldos()
*------------------------------------------------------------------------------------------------*
Local cItem

If lMultiFil //AJP 02/07/2007
   cFilSW5 := WorkLI->WK_FILIAL
   cFilSW4 := WorkLI->WK_FILIAL
   cFilSW8 := WorkLI->WK_FILIAL
EndIf
SW5->(dbSeek(cFilSW5+WorkLI->WK_PGI_NUM+WorkLI->WK_SEQ_LI))
Do While !SW5->(EOF()) .and. cFilSW5==SW5->W5_FILIAL .and. SW5->W5_PGI_NUM==WorkLI->WK_PGI_NUM .and.;
SW5->W5_SEQ_LI == WorkLI->WK_SEQ_LI

   cItem := SW5->W5_COD_I

   If ED4->(dbSeek(cFilED4+SW5->W5_AC+SW5->W5_SEQSIS))
      ED4->(RecLock("ED4",.F.))
      //** PLB 14/11/06 - Verifica Alternativos
      If cItem != ED4->ED4_ITEM
         cItem := IG400BuscaItem("I",cItem,ED4->ED4_PD)
      EndIf
      //**
      If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
         ED4->ED4_QT_LI  += SW5->W5_QT_AC
         If AvVldUn(ED4->ED4_UMNCM) // -- MPG - 06/02/2018
            ED4->ED4_SNCMLI += SW5->W5_PESO
         Else
            ED4->ED4_SNCMLI += AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,cItem,SW5->W5_QT_AC)
         EndIf
      EndIf
      ED4->ED4_VL_LI  += SW5->W5_VL_AC
      SW5->(RecLock("SW5",.F.))
      SW5->W5_AC := ""
      SW5->W5_SEQSIS := ""
      SW5->W5_QT_AC := 0
      SW5->W5_VL_AC := 0
      SW5->(msUnlock())

      SWP->(dbSeek(cFilSWP+SW5->W5_PGI_NUM+SW5->W5_SEQ_LI))
      SWP->(RecLock("SWP",.F.))
      SWP->WP_AC := ""
      SWP->(msUnlock())

      SW8->(dbSeek(cFilSW8+ED0->ED0_AC+SW5->W5_COD_I))
      Do While !SW8->(EOF()) .and. SW8->W8_FILIAL == cFilSW8 .and. SW8->W8_AC==ED0->ED0_AC .and.;
      SW8->W8_COD_I == SW5->W5_COD_I
         If SW8->W8_PGI_NUM == SW5->W5_PGI_NUM .and. SW8->W8_PO_NUM == SW5->W5_PO_NUM .and.;
         SW8->W8_POSICAO == SW5->W5_POSICAO
            If ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
               ED4->ED4_QT_DI  += SW8->W8_QT_AC
               If AvVldUn(ED4->ED4_UMNCM) // -- MPG - 06/02/2018
                  ED4->ED4_SNCMDI += SW5->W5_PESO
               Else
                  ED4->ED4_SNCMDI += AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,cItem,SW8->W8_QT_AC)
               EndIf
            EndIf
            ED4->ED4_VL_DI  += SW8->W8_VL_AC
            SW8->(RecLock("SW8",.F.))
            SW8->W8_AC := ""
            SW8->W8_SEQSIS := ""
            SW8->W8_QT_AC := 0
            SW8->W8_VL_AC := 0
            SW8->(msUnlock())
         EndIf
         SW8->(dbSkip())
      EndDo

      ED4->(msUnlock())
   EndIf
   SW5->(dbSkip())
EndDo

Return .T.

*-----------------------------------------------------------------------------------------------*
Static Function DR150DtEnv()
*-----------------------------------------------------------------------------------------------*
If lMultiFil //AJP 02/07/2007
   cFilSWP := WorkLI->WK_FILIAL
EndiF
SWP->(dbSeek(cFilSWP+WorkLI->WK_PGI_NUM+WorkLI->WK_SEQ_LI))
SWP->(RecLock("SWP",.F.))
SWP->WP_DT_ENVD := dDataBase
SWP->(msUnlock())
Return .T.

*------------------------------------------------------------------------------------*
Static Function DR150PesqLI()
*------------------------------------------------------------------------------------*
Local nOrd:=WorkLI->(IndexOrd()), nRec:=WorkLI->(RecNo())
Local cLi:= Space(Len(SWP->WP_REGIST)), nOp:=0

While .T.

   nOp := 0

   DEFINE MSDIALOG oDlg TITLE STR0044; //"Pesquisa de L.I."
       FROM 12,05 TO 21,50 OF GetWndDefault()

   @02,02 SAY   AVSX3("WP_REGIST",5) of oDlg
   @02,08 MSGET cLi PICT AVSX3("WP_REGIST",6) SIZE 60,8

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOp:=1,oDlg:End()},{||nOp:=0,oDlg:End()}) CENTERED

   If nOp=1
      WorkLI->(dbSetOrder(1))
      If WorkLI->(dbSeek(cLi))
         oMark:oBrowse:Refresh()
      Else
         Help(" ",1,"AVG0005270") // "O número da L.I. não foi encontrado."
         WorkLI->(dbGotop())
         oMark:oBrowse:Refresh()
      Endif
   EndIf

   Exit
EndDo

WorkLI->(dbSetOrder(nOrd))

Return .T.
