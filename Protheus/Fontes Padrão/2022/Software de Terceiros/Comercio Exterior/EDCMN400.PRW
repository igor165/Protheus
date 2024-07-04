//Programador: Alcir Alves
//Manutenção de DIs externas - ED8
//Data: 28-12-05
#INCLUDE "EDCMN400.CH"
#include "AVERAGE.CH"
#INCLUDE "FILEIO.CH"

#define VISUALIZAR 2
#define INCLUIR    3
#define ALTERAR    4
#define ESTORNAR   5

#define GENERICO     "06"
#define NCM_GENERICA "99999999"


// *----------------------------------------------------------------------------------------------
Function EDCMN400(A_alias,A_rec,A_tipo,aCabx,nOpcao)
// *----------------------------------------------------------------------------------------------
LOCAL nVolta
Local cAlias     := "ED8"
Local cExpFilter := ""
Local lTemFiltro := .F.
Local lTop       := .F.
Local lExpTop    := .T.
Local i := 0

Private aTela[0][0]
Private aGets[0]
Private aCampos:= Array( ED8->(FCount()))
Private aHeader:={},Arq_n
PRIVATE cMarca
Private cFilED8 := xfilial("ED8")
private aButtons:={}
private Arotina:=MenuDef()
private Ccadastro:=STR0008 //"Manutenção de DI´s"
Private lAcMod:=.F. //Defice se os campos AC e SEQSIS poderão ser alterados
Private cFilSyt:=xfilial("SYT")
Private lMUserEDC := FindFunction("EDCMultiUser")

If lMUserEDC
   Private oMUserEDC := EDCMultiUser():Novo()
EndIf

// BAK - ExecAuto da Manutencao de DI
Private aCabAuto := aCabx
Private nOpcAuto := nOpcao
Private lManDIAuto := Type("nOpcAuto") == "N" .And. Type("aCabAuto") == "A"

ChkFile("SYP") //AAF 10/01/05 - Verifica se a tabela com os memos está aberta.
ChkFile("SJ5") //AAF 10/01/05 - Verifica se a tabela de conversão de unidades está aberta.

oMainWnd:ReadClientCoords()
lInvert:=.t.
cMarca:=GetMark()
nVolta := 0

#IFDEF TOP
   lTop := .T.
#ELSE
   lTop := .F.
#ENDIF


// BAK - ExecAuto da Manutencao de DI
If !lManDIAuto

   //Verifica se a tabela já possui filtro
   lTemFiltro := !Empty( (cAlias)->( DBFilter() ) )

   If !lTop  .Or.  lTemFiltro  // Caso a tabela ja esteja filtrada efetua o DBFilter() normalmente
         lExpTop := .F.
   EndIf

   If lExpTop
      cExpFilter := cAlias+"_DI_NUM <> '" + space(AVSX3("ED8_DI_NUM",AV_TAMANHO)) + "'"
   Else
      cExpFilter := cAlias+"->"+cAlias + "_DI_NUM <> '" + space(AVSX3("ED8_DI_NUM",AV_TAMANHO)) + "'"
   EndIf

   //Adiciona um novo filtro junto com que já existia
   If lTemFiltro
      cExpFilter := "("+(cAlias)->(DbFilter())+") .And. ("+cExpFilter+")"
      (cAlias)->(DbClearFilter())
   EndIf

   //Filtro
   If !Empty(cExpFilter)
      (cAlias)->(dbSetFilter(&("{|| " + cExpFilter + " }"), cExpFilter))
   EndIf

   //DEFINE MSDIALOG oDlg TITLE Ccadastro FROM oMainWnd:nTop + 130, oMainWnd:nLeft + 5 TO oMainWnd:nHeight-100, oMainWnd:nWidth-100 OF oMainWnd PIXEL
   MBrowse(0,0,455,325,"ED8",nil)
   (cAlias)->( DBClearFilter() )
   //ACTIVATE MSDIALOG oDlg centered ON INIT EnchoiceBar( oDlg, {||nVolta:=1,oDlg:End()}, {||oDlg:End()},,aButtons)
Else

    If nOpcAuto == 6
       If EasySeekAuto("ED8",aCabAuto,4)
          mBrowseAuto(nOpcAuto,aCabAuto,"ED8",.F.)
       EndIf
    EndIf

EndIf

return .t.

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 31/01/07 - 17:27
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := {}

aadd(Arotina,{STR0001,"AxPesqui",0,1}) //"Pesquisar"
aadd(Arotina,{STR0002,"EDCCAD400",0,2}) //"Visualizar"  //AxVisual
aadd(Arotina,{STR0003,"EDCCAD400",0,3}) //"Incluir"
aadd(Arotina,{STR0004,"EDCCAD400",0,4}) //"Alterar"
aadd(Arotina,{STR0005,"EDCCAD400",0,5}) //"Excluir"
aadd(Arotina,{STR0006,"EDCCOM400",0,6}) //"Compr. do A.C."

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("DMN400MNU")
	aRotAdic := ExecBlock("DMN400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina


// *----------------------------------------------------------------------------------------------
Function EDCCAD400(A_alias,A_rec,A_tipo)
// *----------------------------------------------------------------------------------------------
//PRIVATE lInvert
local oObj
LOCAL cTrab
LOCAL nVolta
LOCAL aPos
LOCAL oDlg
Local i
Local lAC := .F.
Local aCpoNoShow:= {"ED8_DES_DI"}

//AOM - 19/10/10 - Campos da tabela ED8 que nao serão apresentados na Manutenção de DI`s Externas
Local aCpoDI   := {"ED8_FORN", "ED8_LOJA", "ED8_PEDIDO" }, aCpoShow := {}
Local nPosDI   := 0
Local cCampo   := ""


//VARIAVEIS DA WORK
Private aCampos	 := Array( SA2->(FCount()))
Private aHearder,Arq_n
aHeader:={}
PRIVATE cMarca
private aButtons:={}

Private aAltera := {"ED8_NF"    ,"ED8_SERIE" ,"ED8_EMISSA",;                                       //Nota Fiscal
                    "ED8_ARMDES","ED8_MRCDES","ED8_INLAND","ED8_OUTDES","ED8_DESCNT","ED8_PACKIN"} //Despesas

lInvert:=.t.
cMarca:=GetMark()
aPos   := {}
nVolta := 0
nOrder := ED8->( IndexOrd() )
nPosED8:= ED8->( RecNo()    )

IF !EMPTY(ED8->ED8_AC) .AND. !EMPTY(ED8->ED8_SEQSIS) .and. (A_tipo==4 .or. A_tipo==5)
	lAC := .T.
	//MSGSTOP(STR0007) //"Este ato esta sendo utilizado em uma comprovação de DI, estorne a comprovação para modificações."
	//AxVisual(A_alias,A_rec,2)
	//return .t.
ENDIF
If A_Tipo==5
   If !( Empty(ED8->ED8_AC) .AND. Empty(ED8->ED8_SEQSIS) .AND. Empty(ED8->ED8_ISETOT) )
      MsgStop(STR0025)//"Item não pode ser excluido pois possui movimentação"
      RETURN .T.
   EndIf
EndIf

// ** PLB 27/11/06 - Verifica se é possivel bloquear os registros necessários para Alt./Exc. da DI Externa
If ( A_Tipo == ALTERAR  .Or.  A_Tipo == ESTORNAR )  .And.  lMUserEDC  .And.  !oMUserEDC:Reserva("DI_EXT","ALT/EXC")
   Return .T.
EndIf
// **

For i := 1 to ED8->(FCount())
   If A_tipo == 3                        // Inclusão
      M->&(ED8->(FieldName(i))):= CriaVar(ED8->(FieldName(i)))
   Else
	  M->&(ED8->(FieldName(i))):= ED8->(FieldGet(i))
   Endif

   //AOM - 19/10/10
   cCampo := ED8->(FieldName(i))
   If (nPosDI := aScan(aCpoDI,{|x| x == ED8->(FieldName(i))})) == 0
      SX3->(DbSetOrder(2))
      If SX3->(DbSeek(AvKey(cCampo,"X3_CAMPO"))) .And. !Empty(SX3->X3_FOLDER) .And. X3Usado(cCampo)
	     AADD(aCpoShow,cCampo)
	  EndIf
   EndIf
Next

If A_tipo<>3 //AOM - 03/08/2011
   M->ED8_DES_VM :=MSMM(ED8->ED8_DES_DI,AVSX3("ED8_DES_VM",AV_TAMANHO),,,LERMEMO)
Else
   M->ED8_DES_VM := Space(AVSX3("ED8_DES_VM",AV_TAMANHO))
endif

If ED8->(FieldPos("ED8_SEQMI")) > 0
   aAdd(aCpoNoShow,"ED8_SEQMI")
EndIf

//Adicionando campo virtual
//Campo virtual para descrição
AADD(aCpoShow,"ED8_DES_VM")

//Campos que não devem ser exibidos (códigos dos campos memos)
For i:= 1 To Len(aCpoNoShow)
   nPosDI:= AScan(aCpoShow, aCpoNoShow[i])
   If nPosDi > 0
      ADel(aCpoShow,nPosDi)
      ASize(aCpoNoShow, Len(aCpoNoShow) -1)
   EndIf
Next

DEFINE MSDIALOG oDlg TITLE Ccadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL//oMainWnd:nTop + 130, oMainWnd:nLeft + 5 TO oMainWnd:nHeight-150, oMainWnd:nWidth-320 OF oMainWnd PIXEL
   aPos := {15,1,(oDlg:nClientHeight - 4)/2,(oDlg:nClientWidth - 4)/2} // ocupa todo o  espaço da janela
   //@ oMainWnd:nTop + 130, oMainWnd:nLeft + 5 TO oMainWnd:nTop + 700, oMainWnd:nLeft + 1018 DIALOG oDlg title="Teste de enchoice"
   dbselectarea("ED8")
   aGets:= {}
   aTela:= {}
   oEnch := MsMGet():New("ED8",A_rec,A_tipo,nil,nil,nil,aCpoShow,aPos,If(lAC,aAltera,))
   oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
ACTIVATE MSDIALOG oDlg centered ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .AND. EDC_ED8EXT(A_tipo),(nVolta:=1,oDlg:End()),nVolta := 0)},{||oDlg:End()})  //EnchoiceBar( oDlg, {||nVolta:=1,oDlg:End()}, {||oDlg:End()},,aButtons)

//nvolta : retorno
IF NVOLTA==1
	EDCSALVACAD(A_tipo,"ED8")
ENDIF

If lMUserEDC
   oMUserEDC:Fim()  // PLB 27/11/06 - Solta registros presos e reinicializa objeto
EndIf
ED8->( dbSetOrder(nOrder) )
ED8->( dbGoTo(nPosED8)    )

return .t.

// *----------------------------------------------------------------------------------------------
FUNCTION EDCSALVACAD(A_TIPO2,A_alias)
// *----------------------------------------------------------------------------------------------
Local i
Local a_altera:={}
Local lRet := .T. //AAF 17/10/2006

If A_Tipo2 == 2
   Return .F.
EndIf

Begin TransAction

   If A_Tipo2 == 3               // Inclusao
      RecLock("ED8",.T.)
      ED8->ED8_FILIAL := xfilial("ED8")
   ElseIf A_Tipo2 == 4 .or. A_tipo2==5          // Alteracao //exclusao
      RecLock("ED8",.F.)

      If A_tipo2 == 5
         aAdd(a_altera,{"ED8",(ED8->ED8_DI_NUM+ED8->ED8_ADICAO+ED8->ED8_POSDI),"E","","","",ddatabase,(TIME()),cUserName})
         MSMM(ED8->ED8_DES_DI,,,,2)
         ED8->( dbdelete() )
         ED8->( MsUnlock() )
         //Grava  no log a alteracao
         EDCLOG400(a_altera[1,1],a_altera[1,2],a_altera[1,3],a_altera[1,4],a_altera[1,5],a_altera[1,6],a_altera[1,7],a_altera[1,8],a_altera[1,9])
         //
         lRet := .F.
      EndIf

      If A_tipo2 == 4
         //AAF - 08/02/06 - Atualiza a Anterioridade
         MN400AtuAC()
      EndIf

   EndIf

   If lRet
      For i := 1 to M->(FCount())
         //Grava  no log a alteracao
         if A_Tipo2 == 4 .AND. ED8->&( FieldName(i) ) <> M->&(FieldName(i))
            aadd(a_altera,{"ED8",(ED8->ED8_DI_NUM+ED8->ED8_ADICAO+ED8->ED8_POSDI),"A",ED8->(FieldName(i)),ED8->&(FieldName(i)),M->&(FieldName(i)),ddatabase,(TIME()),cUserName})
         endif
         //
         //MSMM(,TamSx3("JDL_DISSER")[1],,aMemo[nJDL][2],1,,,"JDL","JDL_MEMO1")
         ED8->&( FieldName(i) ) := M->&( FieldName(i))
      Next

      If A_Tipo2 == 3
         aadd(a_altera,{"ED8",(M->ED8_DI_NUM+M->ED8_ADICAO+M->ED8_POSDI),"I","","","",ddatabase,(TIME()),cUserName})
      EndIf
      If A_Tipo2 == 4
         For i:=1 To Len(a_altera)
            EDCLOG400(a_altera[i,1],a_altera[i,2],a_altera[i,3],a_altera[i,4],a_altera[i,5],a_altera[i,6],a_altera[i,7],a_altera[i,8],a_altera[i,9])
         Next
      Endif
      //endif
      If A_Tipo2 == 4 .or. A_tipo2==3         //Inclusão // Alteracao
         MSMM(ED8->ED8_DES_DI,,,M->ED8_DES_VM,1,,,"ED8","ED8_DES_DI")
      EndIf
      ED8->ED8_FILIAL := xfilial("ED8")
      ED8->( MsUnlock())
   EndIf

End TransAction

Return .T.

// *----------------------------------------------------------------------------------------------
Function EDCCOM400()
// *----------------------------------------------------------------------------------------------
Local gAC,gSAC
Local nOp:=0
Local aEstru := {}

// BAK - Reapuracao Manutenção de DI
Local lManutDIAuto  := Type("lManDIAuto") == "L" .And. lManDIAuto

Private cItens:=""
Private oDlgSer

If !lManutDIAuto
   Private M->ED8_AC     := ED8->ED8_AC //space(AVSX3("ED8_AC",3))
   Private M->ED8_SEQSIS := ED8->ED8_SEQSIS //space(AVSX3("ED8_SEQSIS",3))
   Private M->ED8_EMISSA := ED8->ED8_EMISSA
   Private M->ED8_DTREG  := ED8->ED8_DTREG
Else
   Private M->ED8_AC     := aCabAuto[aScan(aCabAuto, {|x| "ED8_AC" == AllTrim(Upper(x[1]))})][2]
   Private M->ED8_SEQSIS := aCabAuto[aScan(aCabAuto, {|x| "ED8_SEQSIS" == AllTrim(Upper(x[1]))})][2]
   Private M->ED8_EMISSA := aCabAuto[aScan(aCabAuto, {|x| "ED8_EMISSA" == AllTrim(Upper(x[1]))})][2]
   Private M->ED8_DTREG  := aCabAuto[aScan(aCabAuto, {|x| "ED8_DTREG" == AllTrim(Upper(x[1]))})][2]
EndIf

/*
DEFINE MSDIALOG oDlgSer TITLE "Confirmação de AC." FROM 0,0 TO 100,280 PIXEL OF oDlgSer
@ 008, 005 SAY "AC.:" PIXEL OF oDlgSer
@ 008,35 MSGET cAC SIZE 020,10 OF oDlgSer  PIXEL
@ 020, 005 SAY "Seq. Sis: " PIXEL OF oDlgSer
@ 020,35 MSGET cSAC	SIZE 020,10 OF oDlgSer  PIXEL

ACTIVATE MSDIALOG oDlgSer CENTER
*/

   If EMPTY(ED8->ED8_LI_NUM)
      If lManutDIAuto
         EasyHelp(STR0022)
	  Else
	     MSGSTOP(STR0022) //"Para comprovação de AC será necessário o preenchimento do campo Numero da LI."
      EndIf
      Return .f.
   EndIf

   If EMPTY(ED8->ED8_DTLI)
      If lManutDIAuto
	     EasyHelp(STR0023)
   	  Else
         MSGSTOP(STR0023) //"Para comprovação de AC será necessário o preenchimento do campo Data da LI."
      EndIf
      Return .f.
   EndIf

   //RecLock("ED8",.F.)
   // ** PLB 27/11/06 - Verifica se é possivel bloquear os registros necessários para Comprovação
   If lMUserEDC  .And.  !oMUserEDC:Reserva("DI_EXT","COMPROVA")
      Return .F.
   EndIf
   // **

   //campos necessários para funcinamento correto dos F3´s ED4 e E29
   AADD(aEstru,{ "WKTEC" ,  AVSX3("ED8_NCM",2) , AVSX3("ED8_NCM",3), AVSX3("ED8_NCM",4)})
   cNomArq1:=E_CriaTrab("",aEstru,"Work")
   Work->(dbappend())
   Work->WKTEC:=ED8->ED8_NCM
   cItens:=ED8->ED8_COD_I
   M->ED8_COD_I := ED8->ED8_COD_I // DFS - Criação de valor para variável de memória
   cItens+="///"+IG400BuscaItem("I",ED8->ED8_COD_I,,ED8->ED8_AC)  // PLB 16/11/06 - Item genérico
   //

   If !lManutDIAuto
      DEFINE MSDIALOG oDlgSer TITLE STR0009 FROM 12,05 TO 20,50 OF oMainWnd    //"Confirmação de AC."
         @01,02 SAY AVSX3("ED0_AC",5) SIZE 50,8
         @01,07 MSGET M->ED8_AC F3 "ED4" SIZE 80,8
         @02,02 SAY STR0010 SIZE 50,8 //"Seq. A.C. "
         @02,07 MSGET M->ED8_SEQSIS F3 "E29" SIZE 80,8 //F3 "E29"
         @ 045, 045 BUTTON "&Ok"  SIZE 30,12 OF oDlgSer PIXEL ACTION IIF(M->ED8_AC == ED8->ED8_AC .AND. M->ED8_SEQSIS == ED8->ED8_SEQSIS,oDlgSer:End(),(IIF(EDCCOM_VAL(),EDCCMP(),)))  // GFP - 09/10/2012
         @ 045, 075 BUTTON "&Sair" SIZE 30,12 OF oDlgSer PIXEL ACTION oDlgSer:End()
      ACTIVATE MSDIALOG oDlgSer CENTERED //ON INIT EnchoiceBar(oDlgSer,{||nOp:=1,oDlgSer:End()},{||nOp:=0,oDlgSer:End()}) CENTERED
      //ON INIT EnchoiceBar(oDlgAC,{||nOpcao:=1,ED4->( dbSetOrder(2) ),(Empty(cAC) .OR. (ExistCpo("ED4",cAc+cSeqSis,2) .AND. ED4->( dbSeek(cFilED4+cAc+cSeqSis) ))) .AND. If(ValidaAC("ALTERAR",cItem),oDlgAC:End(),nOpcao:=0)},{||nOpcao:=0,oDlgAC:End()}) CENTERED
   Else

      EDCCOM_VAL()
      EDCCMP()

   EndIf

   Work->(dbclosearea())
   If lMUserEDC
      oMUserEDC:Fim()  // PLB 27/11/06 - Solta registros presos e reinicializa objeto
   EndIf

//ED8->( MsUnlock() )
return .t.

// *----------------------------------------------------------------------------------------------
Static Function EDCCMP(cOpca,cAlias)
// *----------------------------------------------------------------------------------------------
// BAK - Reapuracao Manutenção de DI
Local lManutDIAuto  := Type("lManDIAuto") == "L" .And. lManDIAuto

If ED8->(ED8_AC+ED8_SEQSIS) !=  M->ED8_AC + M->ED8_SEQSIS

   Begin TransAction

      //If (!empty(ED8->ED8_AC) .and. !empty(M->ED8_AC)) .AND. (ED8->ED8_AC==M->ED8_AC .AND. ED8->ED8_SEQSIS==M->ED8_SEQSIS)
      //   oDlgSer:End()
      //   lRet := .F.
      //EndIf

      RecLock("ED8",.F.)

      // ** AAF 13/01/06 - Campos a Gravar na Comprovação.
      ED8->ED8_VL_AC  := ED8->ED8_VALEMB

      If ED0->ED0_TIPOAC<>GENERICO .or. ED4->ED4_NCM<>NCM_GENERICA
         ED8->ED8_QT_AC  := AVTransUnid(ED8->ED8_UM,ED4->ED4_UMITEM,ED8->ED8_COD_I,ED8->ED8_QTD,.T.)
         ED8->ED8_QT_AC2 := ED8->ED8_QTDNCM
      EndIf
      // **

      ED8->ED8_AC:= M->ED8_AC
      ED8->ED8_SEQSIS:=M->ED8_SEQSIS

      ED8->( MsUnLock() )

      If !lManutDIAuto
         MsgInfo(STR0015) //"Operação realizada com sucesso!"
      EndIf

   End TransAction

EndIf

If !lManutDIAuto
   oDlgSer:End()
EndIf

Return .T.

// *----------------------------------------------------------------------------------------------
Static Function EDCVAL(cOpca,cAlias)
// *----------------------------------------------------------------------------------------------
Local lReto := .T., nQtdAux:=0, nValAux:=0

// BAK - Reapuracao Manutenção de DI
Local lManutDIAuto  := Type("lManDIAuto") == "L" .And. lManDIAuto
Local lSemVerif := IsInCallStack("EasyDesEDC") // BAK - Se a chamada da função for pela EasyEDCApu, não pode ocorrer a verificação de saldo

// nQtdOld:=0, nPos
//Local aSaldoAC:={}

ED0->(dbSeek(xFilial("ED0")+M->ED8_AC))
If cOpca == "V"
   If !Empty(ED0->ED0_DT_ENC)
      If !lManutDIAuto
	     MSGSTOP(STR0016)
      Else
         EasyHelp(STR0016) //"A.C. Encerrado"
      EndIf
      RETURN .F.
   EndIf
EndIf

If Empty(M->ED8_SEQSIS)
   ED4->(dbSetOrder(7))
   ED4->(dbSeek(xFilial("ED4")+M->ED8_AC+ED8->ED8_NCM+ED8->ED8_COD_I+ED8->ED8_UMNCM))
Else
   ED4->(dbSetOrder(2))
   ED4->(dbSeek(xFilial("ED4")+M->ED8_AC+M->ED8_SEQSIS))
ENDIF

ED0->( dbSetOrder(1) )
ED0->( dbSeek(xFilial("ED0")+ED4->ED4_PD) )

If cAlias == "ED8"
	If cOpca == "V"       //Valida
		IF ED4->(EOF())
  	       If !lManutDIAuto
			  MSGSTOP(STR0017) //"A.C. - Posição SEM CADASTRO"
		   Else
		      EasyHelp(STR0017)
     	   EndIf
		   RETURN .F.
		ENDIF

		If ED4->ED4_NCM <> ED8->ED8_NCM .AND. ED4->ED4_NCM <> NCM_GENERICA
           If !lManutDIAuto
			  MSGSTOP(STR0026)//"A NCM desta posição de Saldo é diferente da NCM da DI."
		   Else
			  EasyHelp(STR0026)//"A NCM desta posição de Saldo é diferente da NCM da DI."
		   EndIf
		   Return .F.
		EndIf

		If lSemVerif
		   Return .T.
		EndIf

		If ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
   		   If AvVldUn(ED4->ED4_UMITEM) // -- MPG - 06/02/2018
              nQtdAux := ED8->ED8_QTD * ED8->ED8_PESO
		   Else
   		      nQtdAux := AVTransUnid(ED8->ED8_UMNCM,ED4->ED4_UMITEM,ED4->ED4_ITEM,ED8->ED8_QTDNCM,.F.)
	   	   EndIf
		   nValAux := ED8->ED8_VALEMB
		EndIf

		If ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
           If ED4->ED4_QT_LI < nQtdAux
              If !lManutDIAuto
                 MSGSTOP(STR0018)//"Quantidade da LI inferior a quantidade a dar baixa"
			  Else
			     EasyHelp(STR0018)//"Quantidade da LI inferior a quantidade a dar baixa"
			  EndIf
              RETURN .F.
           EndIf
        Endif

         If ED4->ED4_QT_DI < nQtdAux
             If !lManutDIAuto
  	            MSGSTOP(STR0019)
	         Else
			    EasyHelp(STR0019) //"Quantidade da DI inferior a quantidade a dar baixa"
             EndIf
             RETURN .F.
         Endif

         nPesoAux:=IIf( AvVldUn(ED4->ED4_UMNCM) ,ED8->ED8_QTD * ED8->ED8_PESO,ED8->ED8_QTDNCM) // -- MPG - 06/02/2018
         if ED4->ED4_SNCMLI < nPesoAux
            If !lManutDIAuto
               MSGSTOP(STR0020)//"Saldo da LI inferior a quantidade a dar baixa"
            Else
               EasyHelp(STR0020)
            EndIf
            RETURN .F.
         endif

         if ED4->ED4_SNCMDI < nPesoAux
            If !lManutDIAuto
			   MSGSTOP(STR0021)//"Saldo da DI inferior a quantidade a dar baixa"
			Else
			   EasyHelp(STR0021)
            EndIf
            RETURN .F.
         endif

		If (ED4->ED4_VL_LI < ED8->ED8_VALEMB) .AND. !MsgYesNo(STR0027+Chr(13)+Chr(10)+;//"Não há saldo de valor suficiente para fazer esta comprovação. Deseja continuar?"
		                                                      STR0028+Alltrim(TransForm(ED8->ED8_VALEMB,AvSX3("ED8_VALEMB",6)))+Chr(13)+Chr(10)+;//"Valor da Comprovação: US$ "
		                                                      STR0029+AllTrim(TransForm(ED4->ED4_VL_LI,AvSX3("ED4_VL_LI",6))))//"Saldo de Valor: US$ "
		   RETURN .F.
		EndIf

		//nPos := ASCAN(aSaldoAC,{|X| X[1]==ED4->ED4_AC .and. X[2]==ED4->ED4_SEQSIS .and. X[5]==cAlias})
		// If nPos > 0
		//    nQtdAux += aSaldoAC[nPos,3]
		//    nValAux += aSaldoAC[nPos,4]
		//  EndIf
		/*
		nQtdOld := ED8->ED8_QTDNCM
		If (ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA) .and.;
		((ED4->ED4_QT_LI + nQtdOld) < nQtdAux .or. (ED4->ED4_QT_DI +nQtdOld) < nQtdAux)
		MSGSTOP("Não foi possivel alterar o cadastro, quantidade NCM não confere")
		RETURN .F.
		ElseIf ED0->ED0_TIPOAC == GENERICO .and. ED4->ED4_NCM = NCM_GENERICA .and.;
		((ED4->ED4_VL_LI + ED8->ED8_VALORI)< nValAux .or. (ED4->ED4_VL_DI + ED8->ED8_VALORI) < nValAux)
		MSGSTOP("Não foi possivel alterar o cadastro, quantidade NCM não confere")
		RETURN .F.
		EndIf

		If lReto
		nQtdAux -= nQtdOld
		nValAux -= ED8->ED8_VALORI
		If nPos > 0
		aSaldoAC[nPos,3] := nQtdAux
		aSaldoAC[nPos,4] := nValAux
		Else
		AADD(aSaldoAC,{ED4->ED4_AC,ED4->ED4_SEQSIS,nQtdAux,nValAux,cAlias})
		EndIf
		EndIf
		*/

	ElseIf cOpca == "D"      //Devolve
		IF ED4->(EOF())
			lReto :=.F.
			RETURN .F.
		ENDIF

		//AOM - 30/09/10
		AC400EstSld(ED8->ED8_QTD, ED8->ED8_UM, ED8->ED8_PESO , ED8->ED8_VALORI, ED8->ED8_MOEDA, M->ED8_AC, M->ED8_SEQSIS,.T.,.T.,.T.,{{ED8->ED8_UMNCM,ED8->ED8_QTDNCM}},,,.F.)

		//NOPADO POR AOM - 30/09/10 - Sera utilizada a função AC400EstSld para estornar os saldos e quantidades do Ato

		/*If ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
   		If ED4->ED4_UMITEM == "KG" .or. ED4->ED4_UMITEM == "10"
	   		nQtdAux := ED8->ED8_QTD * ED8->ED8_PESO
		   Else
   			nQtdAux := AVTransUnid(ED8->ED8_UMNCM,ED4->ED4_UMITEM,ED4->ED4_ITEM,(ED8->ED8_QTDNCM),.F.)
	   	EndIf
		EndIf


		ED4->(RECLOCK("ED4",.F.))
		ED4->ED4_VL_LI  +=  ED8->ED8_VALEMB //VALOR EM DOLAR
		ED4->ED4_VL_DI  +=  ED8->ED8_VALEMB //VALOR EM DOLAR

		If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
			ED4->ED4_QT_LI  += nQtdAux
			ED4->ED4_QT_DI  += nQtdAux
			If ED4->ED4_UMNCM == "KG" .or. ED4->ED4_UMNCM == "10"
				ED4->ED4_SNCMLI += ED8->ED8_QTD * ED8->ED8_PESO
				ED4->ED4_SNCMDI += ED8->ED8_QTD * ED8->ED8_PESO
			Else
				ED4->ED4_SNCMLI += ED8->ED8_QTDNCM //AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQtdAux)
				ED4->ED4_SNCMDI += ED8->ED8_QTDNCM //AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQtdAux)
			EndIf

		EndIf

		ED4->(msUnlock())*/

		If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
		   Reclock("ED8",.F.)
	       ED8->ED8_VL_AC  := 0 //VALOR EM DOLAR
	       ED8->ED8_QT_AC  := 0 //QUANTIDADE DE COMPRA
		   ED8->ED8_QT_AC2 := 0 //QUANTIDADE DE COMPRA
		   ED8->(MSUNLOCK())
		EndIf

		//AAF - 08/02/06 - Atualiza a Anterioridade
		M->ED8_AC := ""
		MN400AtuAC()

	ElseIf cOpca == "B"      //Baixa
		IF ED4->(EOF())
			lReto :=.F.
			RETURN .F.
		ENDIF

		//AOM - 30/09/10
		AC400BxSld(ED8->ED8_QTD, ED8->ED8_UM, ED8->ED8_PESO , ED8->ED8_VALORI, ED8->ED8_MOEDA, M->ED8_AC,M->ED8_SEQSIS,.T.,.T.,.T.,{{ED8->ED8_UMNCM,ED8->ED8_QTDNCM}},,,.F.)


	   //NOPADO POR AOM - 30/09/10 - Sera utilizada a função AC400BxSld para baixa dos saldos e quantidades do Ato

	  /*If ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
   		If ED4->ED4_UMITEM == "KG" .or. ED4->ED4_UMITEM == "10"
	   		nQtdAux := ED8->ED8_QTD * ED8->ED8_PESO
		   Else
   			nQtdAux := AVTransUnid(ED8->ED8_UMNCM,ED4->ED4_UMITEM,ED4->ED4_ITEM,(ED8->ED8_QTDNCM),.F.)
	   	EndIf
      EndIf



		ED4->(RECLOCK("ED4",.F.))
		ED4->ED4_VL_LI  -=  ED8->ED8_VALEMB //VALOR EM DOLAR
		ED4->ED4_VL_DI  -=  ED8->ED8_VALEMB //VALOR EM DOLAR

		If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
			ED4->ED4_QT_LI  -= nQtdAux
			ED4->ED4_QT_DI  -= nQtdAux
			If ED4->ED4_UMNCM == "KG" .or. ED4->ED4_UMNCM == "10"
				ED4->ED4_SNCMLI -= ED8->ED8_QTD * ED8->ED8_PESO
				ED4->ED4_SNCMDI -= ED8->ED8_QTD * ED8->ED8_PESO
			Else
				ED4->ED4_SNCMLI -= ED8->ED8_QTDNCM //AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQtdAux)
				ED4->ED4_SNCMDI -= ED8->ED8_QTDNCM //AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQtdAux)
			EndIf

		EndIf

		ED4->(msUnlock())*/

	    If ED0->ED0_TIPOAC <> GENERICO .or. Alltrim(ED4->ED4_NCM) <> NCM_GENERICA
           Reclock("ED8",.F.)
	  	   ED8->ED8_VL_AC  :=  ED8->ED8_VALEMB //VALOR EM DOLAR
		   ED8->ED8_QT_AC := ED8->ED8_QTD //QUANTIDADE DE COMPRA
		   ED8->ED8_QT_AC2:= ED8->ED8_QTDNCM //QUANTIDADE DE COMPRA
		   ED8->(MSUNLOCK())
		EndIf

		//AAF - 08/02/06 - Atualiza a Anterioridade
		MN400AtuAC()

	EndIf
EndIf

return .t.


// *----------------------------------------------------------------------------------------------
Function EDC_ED8EXT(A_tipoT)
// *----------------------------------------------------------------------------------------------
Local lRet:=.T.
Local lManutDIAuto  := Type("lManDIAuto") == "L" .And. lManDIAuto

if A_tipoT==3
    ED8->(DBSETORDER(4))
    IF ED8->(DBSEEK(XFILIAL("ED8")+M->ED8_DI_NUM+M->ED8_ADICAO+M->ED8_POSDI))
       If !lManutDIAuto
          MSGSTOP(STR0024) //"Já existe uma D.I. para o mesmo Numero,Adicao e Posição."
       Else
          EasyHelp(STR0024)
       EndIf
       lRet:=.F.
    else
       IndRegua("sw8","SW8MN400"+TEOrdBagExt(),"W8_HAWB+W8_ADICAO+W8_POSICAO")
       IF SW8->(DBSEEK(XFILIAL("SW8")+M->ED8_DI_NUM+M->ED8_ADICAO+M->ED8_POSDI))
          If !lManutDIAuto
             MSGSTOP(STR0024) //"Já existe uma D.I. para o mesmo Numero,Adicao e Posição."
          Else
            EasyHelp(STR0024)               
          EndIf
          lRet:=.F.
       ENDIF
    Endif
Endif

    /*AOM - Verifica o parametro MV_ANT_IMP se a data da gravação da anterioridade será
      através da nota ou DI, se for da nota a data da nota deve estar preenchida.*/
      If EasyGParam("MV_ANT_IMP",,"1") == "1" .And. (Empty(M->ED8_NF) .Or. Empty(M->ED8_EMISSA) .Or. Empty(M->ED8_SERIE))
         If !lManutDIAuto
            MSGSTOP(STR0030)//"Preencher os campos referentes a nota fiscal ou alterar o pametro 'MV_ANT_IMP' para o conteudo '2' para que a gravação da anterioridade seja feita pelos dados da DI. "
         Else
            EasyHelp(STR0030)//"Preencher os campos referentes a nota fiscal ou alterar o pametro 'MV_ANT_IMP' para o conteudo '2' para que a gravação da anterioridade seja feita pelos dados da DI. "               
         EndIf
         lRet:=.F.
      EndIf

return lRet

*----------------------------------------------------------------------------------------------*
Function MN400GrvAnt(nOpc,cAntHawb,cAntPO,cAntInv,cAntItem,cAntPos,cAntPGI,cAntQtd,cAntData)
*----------------------------------------------------------------------------------------------*
// BAK - Reapuracao Manutenção de DI
Local lSeek := .F.
Local lCompNacion := AvFlags("SEQMI") .And. Empty(cAntHawb) .And. !Empty(cAntPO)

Default cAntData := dDataBase

 //AOM - 23/11/2011
 Default cAntHawb:= Space(AVSX3("EDD_HAWB"  ,AV_TAMANHO))
 Default cAntPO  := Space(AVSX3("EDD_PO_NUM",AV_TAMANHO))
 Default cAntInv := Space(AVSX3("EDD_INVOIC",AV_TAMANHO))
 Default cAntItem:= Space(AVSX3("EDD_ITEM"  ,AV_TAMANHO))
 Default cAntPos := Space(AVSX3("EDD_POSICA",AV_TAMANHO))
 Default cAntPGI := Space(AVSX3("EDD_PGI_NU",AV_TAMANHO))
 Default cAntQtd := Space(AVSX3("EDD_QTD"   ,AV_TAMANHO))


If lCompNacion
   EDD->(DbSetOrder(4))
Else
   EDD->(DbSetOrder(2))
EndIf

If nOpc = 1 .Or. nOpc = 3       //INCLUIR ou Alteração
   lSeek := EDD->(dbSeek(xFilial("EDD")+AvKey(cAntHawb,"EDD_HAWB")+AvKey(cAntInv,"EDD_INVOIC")+AvKey(cAntPO,"EDD_PO_NUM")+cAntPos+cAntPGI))
   EDD->(RecLock("EDD",!lSeek))
   EDD->EDD_FILIAL := xFilial("EDD")
   EDD->EDD_AC     := ED4->ED4_AC
   EDD->EDD_PD     := ED4->ED4_PD
   EDD->EDD_HAWB   := cAntHawb //M->W6_HAWB
   EDD->EDD_PO_NUM := cAntPO //Work_SW8->WKPO_NUM
   EDD->EDD_INVOIC := cAntInv //Work_SW8->WKINVOICE
   EDD->EDD_ITEM   := cAntItem //Work_SW8->WKCOD_I
   EDD->EDD_POSICA := cAntPos //Work_SW8->WKPOSICAO
   EDD->EDD_PGI_NU := cAntPGI //Work_SW8->WKPGI_NUM
   IF lCompNacion
      EDD->EDD_SEQMI := ED4->ED4_SEQMI
   ELSE
      EDD->EDD_SEQSII := ED4->ED4_SEQSIS
   ENDIF
   EDD->EDD_QTD    := cAntQtd //If(cAlias="Work",Work_SW8->WKQT_AC,SW8->W8_QT_AC)
   EDD->EDD_DTREG  := cAntData //dDataReg
   EDD->EDD_QTD_OR := cAntQtd //If(cAlias="Work",Work_SW8->WKQT_AC,SW8->W8_QT_AC)
   EDD->(MsUnlock())
ElseIf nOpc = 2   //EXCLUIR

   If EDD->(dbSeek(xFilial("EDD")+AvKey(cAntHawb,"EDD_HAWB")+AvKey(cAntInv,"EDD_INVOIC")+AvKey(cAntPO,"EDD_PO_NUM")+cAntPos+cAntPGI))
      EDD->(RecLock("EDD",.F.))
      EDD->(dbDelete())
      EDD->(MsUnlock())
   EndIf
//ElseIf nOpc = 3   //Alteração
//   If EDD->(dbSeek(cSeekEDD))//EDD->(dbSeek(xFilial("EDD")+AvKey(cAntHawb,"EDD_HAWB")+AvKey(cAntInv,"EDD_INVOIC")+AvKey(cAntPO,"EDD_PO_NUM")+cAntPos+cAntPGI))
//      EDD->(RecLock("EDD",.F.))
//      EDD->EDD_DTREG := cAntData
//      EDD->(MsUnlock())
//   EndIf
EndIf

Return .T.

//AAF - 08/02/2006 - Anterioridade Drawback
****************************
Static Function MN400AtuAC()
****************************
// BAK - Reapuracao Manutenção de DI
If ED0->ED0_MODAL == "1"


   If EasyGParam("MV_ANT_IMP",,"1") == "2"

      If !Empty(ED8->ED8_AC) .AND. Empty(M->ED8_AC)     //Estorno da Comprovação.
         MN400GrvAnt(2,ED8->ED8_DI_NUM+ED8->ED8_ADICAO,""/*PONUM*/,ED8->ED8_INVOIC,ED8->ED8_COD_I,ED8->ED8_POSDI,ED8->ED8_LI_NUM,ED8->ED8_QT_AC,M->ED8_DTREG)
      ElseIf Empty(ED8->ED8_AC) .AND. !Empty(M->ED8_AC) //Comprovação.
         MN400GrvAnt(1,ED8->ED8_DI_NUM+ED8->ED8_ADICAO,""/*PONUM*/,ED8->ED8_INVOIC,ED8->ED8_COD_I,ED8->ED8_POSDI,ED8->ED8_LI_NUM,ED8->ED8_QT_AC,M->ED8_DTREG)
      ElseIf !Empty(ED8->ED8_AC) .AND. M->ED8_EMISSA <> ED8->ED8_EMISSA //Alteração da Data NF.
         MN400GrvAnt(3,ED8->ED8_DI_NUM+ED8->ED8_ADICAO,""/*PONUM*/,ED8->ED8_INVOIC,ED8->ED8_COD_I,ED8->ED8_POSDI,ED8->ED8_LI_NUM,ED8->ED8_QT_AC,M->ED8_DTREG)
      EndIf
   ElseIf EasyGParam("MV_ANT_IMP",,"1") == "1"

      If (!Empty(ED8->ED8_AC) .AND. Empty(M->ED8_AC)) .OR. ( !Empty(ED8->ED8_EMISSA) .AND. Empty(M->ED8_EMISSA))    //Estorno da Comprovação.
         MN400GrvAnt(2,ED8->ED8_DI_NUM+ED8->ED8_ADICAO,""/*PONUM*/,ED8->ED8_INVOIC,ED8->ED8_COD_I,ED8->ED8_POSDI,ED8->ED8_LI_NUM,ED8->ED8_QT_AC, M->ED8_EMISSA)
      ElseIf ( Empty(ED8->ED8_AC) .AND. !Empty(M->ED8_AC) ) .OR. ( Empty(ED8->ED8_EMISSA) .AND. !Empty( M->ED8_EMISSA) )//Comprovação.
         MN400GrvAnt(1,ED8->ED8_DI_NUM+ED8->ED8_ADICAO,""/*PONUM*/,ED8->ED8_INVOIC,ED8->ED8_COD_I,ED8->ED8_POSDI,ED8->ED8_LI_NUM,ED8->ED8_QT_AC, M->ED8_EMISSA)
      ElseIf !Empty(ED8->ED8_AC) .AND.  M->ED8_EMISSA <> ED8->ED8_EMISSA //Alteração da Data NF.
         MN400GrvAnt(3,ED8->ED8_DI_NUM+ED8->ED8_ADICAO,""/*PONUM*/,ED8->ED8_INVOIC,ED8->ED8_COD_I,ED8->ED8_POSDI,ED8->ED8_LI_NUM,ED8->ED8_QT_AC, M->ED8_EMISSA)
      EndIf
   EndIf

EndIf

Return .T.

****************************
Static Function EDCCOM_VAL()
****************************
Local cAC_OLD,cSAC_OLD, lRet := .T.
Local lSemVerif := IsInCallStack("EasyDesEDC") // BAK - Se a chamada da função for pela EasyEDCApu, não pode ocorrer a verificação de saldo
Local lTpOcor   := EDD->(FIELDPOS("EDD_CODOCO")) > 0 .And. EDD->(FIELDPOS("EDD_DESTIN")) > 0 //AOM - 22/06/2012 - Campos para gravação de Itens comprados na Anterioridade

// BAK - Reapuracao Manutenção de DI
Local lManutDIAuto  := Type("lManDIAuto") == "L" .And. lManDIAuto

   Begin Sequence

      If !Empty(M->ED8_AC)  .And.  Empty(M->ED8_SEQSIS)
         If !lManutDIAuto
            MsgStop(STR0011)
         Else
            EasyHelp(STR0011) //"O campos A.C e Seq.AC devem estar preenchidos simultaneamentes, ou totalmente em branco"
         EndIf
         lRet :=  .F.
         Break
      EndIf

      If Empty(M->ED8_AC)  .And.  !Empty(M->ED8_SEQSIS)
         If !lManutDIAuto
            MsgStop(STR0012)
         Else
            EasyHelp(STR0012) //"O campos 'A.C' e 'Seq.AC' devem estar preenchidos simultaneamentes, ou totalmente em branco"
         EndIf
         M->ED8_AC     := Space(AVSX3("ED8_AC"    ,3))
         M->ED8_SEQSIS := Space(AVSX3("ED8_SEQSIS",3))
         lRet := .F.
         Break
      Endif

      If !lSemVerif  .And. !EasyGParam("MV_EDC0009",,.F.)//AOM 19/12/2011
         EDD->( dbSetOrder(2) )
         EDD->(dbSeek(xFilial("EDD")+AvKey(ED8->ED8_DI_NUM+ED8->ED8_ADICAO,"EDD_HAWB")+AvKey(ED8->ED8_INVOIC,"EDD_INVOIC")+Avkey("","EDD_PO_NUM")+Avkey(ED8->ED8_POSDI,"EDD_POSICA")+AvKey(ED8->ED8_LI_NUM,"EDD_PGI_NU")))
         Do While !EDD->( EoF() ) .AND. EDD->( EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU )  ==;
                                           xFilial("EDD")+AvKey(ED8->ED8_DI_NUM+ED8->ED8_ADICAO,"EDD_HAWB")+AvKey(ED8->ED8_INVOIC,"EDD_INVOIC")+Avkey("","EDD_PO_NUM")+Avkey(ED8->ED8_POSDI,"EDD_POSICA")+AvKey(ED8->ED8_LI_NUM,"EDD_PGI_NU")

           If (!Empty(EDD->EDD_PREEMB) .Or. !Empty(EDD->EDD_PEDIDO) .Or. (lTpOCor .And. !Empty(EDD->EDD_CODOCO)) )  //AOM - 23/11/2011 - Tratamento para considerar Vendas para exportadores.
              If !lManutDIAuto
                 MsgStop(STR0031)//"Comprovação não pode ser estornada pois mantém associação de anterioridade com exportação ou Vendas para Exportadores"
              Else
                 EasyHelp(STR0031)//"Comprovação não pode ser estornada pois mantém associação de anterioridade com exportação ou Vendas para Exportadores"
              EndIf
              M->ED8_AC     := ED8->ED8_AC
              M->ED8_SEQSIS := ED8->ED8_SEQSIS
              lRet := .F.
              Break
           EndIf

           EDD->( dbSkip() )
         EndDo
      EndIf

      If lMUserEDC  .And.  !oMUserEDC:Reserva("DI_EXT","GRV_COMPROVA")
         lRet := .F.
         Break
      EndIf

      If (!empty(ED8->ED8_AC) .and. empty(M->ED8_AC))  //.or. (empty(ED8->ED8_AC) .and. !empty(cAC))
         //cVal:=EDCVAL("V","ED8")
         M->ED8_AC     := ED8->ED8_AC
         M->ED8_SEQSIS := ED8->ED8_SEQSIS
         ED4->(dbSetOrder(2))
         If !ED4->(dbSeek(xFilial("ED4")+M->ED8_AC+M->ED8_SEQSIS))
            If !lManutDIAuto
               MsgStop(STR0013) //"A.C. não possue registros de saldos"
            Else
               EasyHelp(STR0013)
            EndIf
            M->ED8_AC:=space(AVSX3("ED8_AC",3))
            M->ED8_SEQSIS:=space(AVSX3("ED8_SEQSIS",3))
            lRet := .F.
            Break
         EndIf
         EDCVAL("D","ED8")
         M->ED8_AC:=""
         M->ED8_SEQSIS:=""
      Else
         ED4->(dbSetOrder(2))
         If !ED4->(dbSeek(xFilial("ED4")+M->ED8_AC+M->ED8_SEQSIS))
            If !lManutDIAuto
               MsgStop(STR0013) //"A.C. não possue registros de saldos"
            Else
               EasyHelp(STR0013)
            EndIf
            M->ED8_AC:=space(AVSX3("ED8_AC",3))
            M->ED8_SEQSIS:=space(AVSX3("ED8_SEQSIS",3))
            lRet := .F.
            Break
         ElseIf !EDCVAL("V","ED8")
            If !lManutDIAuto
               MsgStop(STR0014) //"Não há saldo disponivel para esta comprovação."
            Else
               EasyHelp(STR0014)
            EndIf
            M->ED8_AC:=space(AVSX3("ED8_AC",3))
            M->ED8_SEQSIS:=space(AVSX3("ED8_SEQSIS",3))
            lRet := .F.
            Break
         //IF EDCVAL("V","ED8")
         ElseIf (!EMPTY(M->ED8_AC) .AND. !EMPTY(M->ED8_SEQSIS)) .AND. (ED8->ED8_AC#M->ED8_AC .OR. ED8->ED8_SEQSIS#M->ED8_SEQSIS)
            //cVal:=EDCVAL("V","ED8")
            cAC_OLD:=M->ED8_AC
            cSAC_OLD:=M->ED8_SEQSIS
            M->ED8_AC:=ED8->ED8_AC
            M->ED8_SEQSIS:= ED8->ED8_SEQSIS
            EDCVAL("D","ED8")
            M->ED8_AC:=cAC_OLD
            M->ED8_SEQSIS:=cSAC_OLD
            EDCVAL("B","ED8")
         EndIf
         //endif
      EndIf

   End Sequence

Return lRet




/*
Funcao      : EDCF3ED4()
Parametros  : cRetorno
Retorno     : cRetorno
Objetivos   : Executar F3 do SXB ED4B
Autor       : Allan Oliveira Monteiro
Data/Hora   : 19/10/10 - 16:12
Obs.        :
*/
*------------------*
Function EDCF3ED4()
*------------------*
Local cRetorno:= ""

If IsInCallStack("EDCNF400")
   cRetorno:= ConPad1(,,,'ED4A',,)
Else
   cRetorno:= ConPad1(,,,'ED4',,)
Endif

Return cRetorno

/*
Funcao      : FiltroED4()
Parametros  : cRetorno
Retorno     : cRetorno
Objetivos   : Executar F3 do SXB ED4
Autor       : Allan Oliveira Monteiro
Data/Hora   : 19/10/10 - 16:12
Obs.        :
*/
*------------------*
Function FiltroED4()
*------------------*
Local cFiltro := ".T."
Local cNcm:= ""

//MFR 29/04/2019 OSSME-2916
If isMemVar("lAcMod")  .And. lAcMod
   cFiltro := "!Empty(ED4->ED4_AC) .AND. (ED4->ED4_ITEM $ cItens .or. Left(ED4->ED4_NCM,8) == '99999999' .or. (ED4->ED4_NCM== Work->WKTEC .and. Empty(ED4->ED4_ITEM))) .AND. ((ED4->ED4_QT_LI >0 .and. ED4->ED4_SNCMLI >0 ) .and. ED4->ED4_DT_VAL >= DDATABASE) .And. (Empty(ED4->ED4_IMPORT) .Or. ED4->ED4_IMPORT == 'S' )"
EndIf
Return &(cFiltro)
