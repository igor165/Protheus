#INCLUDE "HSPAHA95.ch"
#include "protheus.CH"
#include "colors.CH"

STATIC cCodEndAnt := ""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA95  บ Autor ณ Marcelo Jose       บ Data ณ  03/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELACIONAMENTO PRONTUARIO x ENDERECOS                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
FUNCTION HSPAHA95()

Private oListB, oMarcaT , oDlg, oSay1, oSay2, oSay0
Private cAlias95A := "QRY95A"
Private cDescEnd  := ""
Private cEndereco := Space( (TamSx3("GSB_CODEND")[1]) )
Private oTik      := LoadBitmap(GetResources(), "LBTIK")
Private oNo       := LoadBitmap(GetResources(), "LBNO")
Private aCGSB     := {}
Private cCadastro := STR0001 //"Relacionamento de Prontuario x Enderecos"
Private cDelFunc  := ".T."   // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString   := "GSB"
Private cPerg     := "HSPA95"
Private cGsDCtrl  := ""
Private cGsDTipo  := ""


Private aRotina   := MenuDef()
dbSelectArea("GSB")
dbSetOrder(1)

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A95    บ Autor ณ Mario Arizono      บ Data ณ  05/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Prontuario X Endereco                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_A95(cAlias, nReg, nOpc)
 Local nGDOpc := IIf(aRotina[nOpc, 4] == 3, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local nOpcA  := 0
 Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {}

 Private aTela := {}, aGets := {}
 Private oGSB

 RegToMemory("GSB", aRotina[nOpc,4]==3)

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 100, .T., .T. } )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 nOpcA := 0
 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel
  oGSB := MsMGet():New("GSB", nReg, nOpc,,,,, aPObjs[1],,,,,,oDlg )
  oGSB:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		oGSB:AENTRYCTRLS[aScan(oGSB:aGets, {| aVet | "GSB_CODEND" 				$ aVet})]:BGOTFOCUS := {||	cCodEndAnt	:= M->GSB_CODEND}

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela) .AND. IIF(nOpc == 3, FS_VLDTIP(),.T.) , oDlg:End(), nOpcA := 0)}, ;
                                                  {|| nOpcA := 0, oDlg:End()} )

 If nOpcA == 1
  Begin Transaction
   FS_GRVA95(nOpc)
  End Transaction
 Else
 	UnLockByName("A95GSD" + M->GSB_CODEND, .T., .T., .F.)
 Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VLDA95 บ Autor ณ Mario Arizono      บ Data ณ  05/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para validacao dos campos.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_VLDA95()

 Local lRet := .T., aArea := GetArea()
 If FunName() <> "HSPAHM41"
  If ReadVar() == "M->GSB_CODEND"

   If !(lRet :=  HS_SEEKRET("GSD","M->GSB_CODEND",1,.F.,"GSB_DESEND","GSD_DESEND"))
    HS_MsgInf(STR0007, STR0010, STR0012) //"Endere็o invalido"##"Atencao"##"Valida็ใo do endere็o"
   Endif

   If lRet
    If GSD->GSD_EATIVO == "0"
     If GSD->GSD_STATUS == "1"
      If GSD->GSD_ENDTIP == "1"
       HS_MsgInf(STR0030, STR0010, STR0031)//"Endereco Ocupado...Operacao cancelada."###"Atencao"###"Inclusใo nใo Permitida"
       lRet := .F.
      Endif
     Else
      DbSelectArea("GSB")
      DbSetOrder(1)
	 If !(GSB->(FieldPos("GSB_REGATE")) > 0) .and. DBSeek(xFilial("GSB") + M->GSB_REGGER + M->GSB_CODEND)
       HS_MsgInf(STR0011, STR0010, STR0031) //"Relacionamento Prontuario x Endereco ja existente..."###"Atencao"###"Inclusใo nใo Permitida"
       lRet := .F.
      Else
       dbSelectArea("GSD")
       dbSetOrder(1)
       DBSeek(xFilial("GSD") + M->GSB_CODEND)
       If GSD->GSD_ENDTIP <> "1"
        If Substr(M->GSB_REGGER, len(GSB->GSB_REGGER), 1) <> GSD->GSD_TERMIN .AND. GSD->GSD_ENDTIP == "2"  .AND. !EMPTY(M->GSB_REGGER)
         HS_MsgInf(STR0013, STR0010, STR0031) //"Termina็ใo do endere็o precisa ser a mesma da termina็ใo do prontuแrio"###"Atencao"###"Inclusใo nใo Permitida"
         lRet := .F.
        Else
         M->GSB_TIPEND := GSD->GSD_TIPEND
        Endif
       Endif
      EndIf
     EndIf
    Else
     HS_MsgInf(STR0039, STR0010, STR0031)//"Endere็o nใo pode estar desativado"###"Atencao"###"Inclusใo nใo Permitida"
     lRet := .F.
    Endif
   Endif


   // Destrava o registro (endereco) digitado anteriormente //
   If !Empty(cCodEndAnt)
   	UnLockByName("A95GSD" + cCodEndAnt, .T., .T., .F.)
   EndIf

   // Verifica se o registro esta bloqueado (pasta), caso nao esteja, entao bloqueia //
 		If (lRet .And. GSD->GSD_ENDTIP == "1")
 			If !(lRet := LockByName("A95GSD" + M->GSB_CODEND, .T., .T., .F.))
					HS_MsgInf(STR0045, STR0010, STR0046) //"Este endere็o jแ esta reservado por outro usuแrio."###"Aten็ใo"###"Registro Bloqueado"
 			EndIf
 		EndIf

   If !lRet
    M->GSB_DESEND := SPACE(LEN(GSD->GSD_DESEND))
   Endif
  ElseIf ReadVar() == "M->GSB_REGGER"

   If !(lRet := HS_SEEKRET("GBH","M->GSB_REGGER",1,.F.,"GSB_NOMPAC","GBH_NOME"))
    HS_MsgInf(STR0033, STR0010,STR0038)//"Prontuแrio invแlido"###"Aten็ใo"###"Valida็ใo do paciente"
   Else
    DbSelectArea("GSB")
    DbSetOrder(1)
			If GSB->(FieldPos("GSB_REGATE")) < 0 .And. DBSeek(xFilial("GSB") + M->GSB_REGGER + M->GSB_CODEND)
     HS_MsgInf(STR0011, STR0010, STR0031) //"Relacionamento Prontuario x Endereco ja existente..."###"Atencao"###"Inclusใo nใo Permitida"
     lRet := .F.
    Else
     dbSelectArea("GSD")
     dbSetOrder(1)
     If DBSeek(xFilial("GSD") + M->GSB_CODEND)
      If Substr(M->GSB_REGGER, len(GSB->GSB_REGGER), 1) <> GSD->GSD_TERMIN .AND. GSD->GSD_ENDTIP == "2"
       HS_MsgInf(STR0013, STR0010, STR0031)//"Termina็ใo do endere็o precisa ser a mesma da termina็ใo do prontuแrio"###"Atencao"###"Inclusใo nใo Permitida"
       lRet := .F.
      Endif
     Endif
    Endif
   Endif
  Endif
 Endif
 RestArea(aArea)
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRVA95 บ Autor ณ Mario Arizono      บ Data ณ  05/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gravacao dos campos                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GRVA95(nOpc)
Local aArea:= GetArea()

If aRotina[nOpc, 4] == 3
	HS_INCGSB(M->GSB_CODEND, M->GSB_TIPEND)
ElseIf aRotina [nOpc, 4] == 5 .AND. FS_EXCA95(GSB->GSB_REGGER, GSB->GSB_CODEND)
	RecLock("GSB", .F.)
	DbDelete()
	MsUnlock()
	WriteSx2("GSB")
Endif

RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_EXCA95 บ Autor ณ Mario Arizono      บ Data ณ  05/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao para delecao dos registros.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_EXCA95(cRegger, cCodend)
 Local lRet := .T., aArea:= GetArea()

 dbSelectArea("GSA")
 dbSetOrder(7)

 If DBSeek(xFilial("GSA") + cRegger + cCodend )
  HS_MsgInf(STR0009, STR0010, STR0032) //"Existe movimentacao para este relacionamento. Nao pode excluir."###"Atencao""Exclusใo nใo Permitida"
  lRet := .F.
 EndIf

 If lRet
  dbSelectArea("GSD")
  dbSetOrder(1)
  If DBSeek(xFilial("GSD") + cCodend )
   If GSD->GSD_ENDTIP == "1"
    RecLock("GSD", .F.)
      GSD->GSD_STATUS := "0"
      GSD->GSD_TIPEND := SPACE(LEN(GSD->GSD_TIPEND))
     MsUnLock()
   Endif
  EndIf
 EndIf
 RestArea(aArea)
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_INCGSB บ Autor ณ Mario Arizono      บ Data ณ  05/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para gravacao dos registros na GSB e GSD.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_INCGSB(cCodend, cTipEnd)
Local aArea := GetArea()

DbSelectArea("GSB")

RecLock("GSB", .T.)
	HS_GrvCpo("GSB")
	GSB->GSB_FILIAL := xFilial("GSB")
	GSB->GSB_LOGARQ := HS_LOGARQ()
MsUnLock()

DbSelectArea("GSD")
	DbSetOrder(1)
 	If DbSeek(xFilial("GSD") + cCodend)
  	If GSD->GSD_ENDTIP == "1"
   		RecLock("GSD", .F.)
    		GSD->GSD_STATUS := "1"   // Na Inclusao do (prontuarioxendereco) O status do endereco sera ocupado p/(pasta)
    		GSD->GSD_TIPEND := cTipend
   		MsUnLock()
   		UnLockByName("A95GSD" + cCodend, .T., .T., .F.)
  	Endif
Endif
RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDTIP บ Autor ณ Mario Arizono      บ Data ณ  05/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida Campo tipo de endereco na inclusao.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_VLDTIP()
 Local   lRet:= .T.
 Local aArea := GetArea()
 Local cQry := "", cEndTip := "", cTipEnd := ""

 DbSelectArea("GSD")
 DbSetOrder(1)
 If Dbseek(xFilial("GSD") + M->GSB_CODEND)
  If GSD->GSD_ENDTIP == "1" .AND. EMPTY(M->GSB_TIPEND)
   HS_MSGINF (STR0040, STR0010, STR0012)//"Preencha o campo tipo do endere็o"##"Atencao"##"Validacao Endere็o"
   lRet := .F.
  Endif
 Endif

//TGTZQ6 :: nao permitir que seja inserido dois numeros de prontuarios iguais
DbSelectArea("GSB")
DbSetOrder(1) //GSB_FILIAL+GSB_REGGER+GSB_CODEND+GSB_REGATE
If (GSB->(MsSeek(xFilial("GSB")+M->GSB_REGGER)))
	HS_MSGINF (STR0047, STR0010, STR0048)//"Numero de prontuario ja existe."##"Atencao"##"Validacao de Prontuario"
	lRet := .F.
EndIf

 /*
 Nao deve permitir a inclusao de um endereco para um prontuario QUE JA TENHA um endereco com o
 MESMO TIPO DE CONTROLE (Multi-prontuแrio, Pasta e Termina็ใo), e MESMO TIPO DE ENDEREวO (Hospitalar, Ambulatorial e
 Pronto Atendimento) E QUE ESTEJA ATIVO - Solicitacao BOPS: 103904;
 */
 If lRet
		// Ja esta posicionada pela rotina acima //
		cEndTip := GSD->GSD_ENDTIP
		cTipEnd := IIf(GSD->GSD_ENDTIP == "1", M->GSB_TIPEND, GSD->GSD_TIPEND)

		cQry := " SELECT COUNT(*) nTotReg "
		cQry += " FROM " + RetSqlName("GSB") + " GSB "
		cQry += " JOIN " + RetSqlName("GSD") + " GSD "
		cQry += "  ON GSB.GSB_CODEND = GSD.GSD_CODEND	AND GSD.GSD_FILIAL = '" + xFilial("GSD") + "' "
		cQry += " AND GSD.D_E_L_E_T_ <> '*' "
		cQry += " AND GSD.GSD_TIPEND = '" + cTipEnd + "' "
		cQry += " AND GSD.GSD_ENDTIP = '" + cEndTip + "' "
		cQry += " AND GSD.GSD_EATIVO = '0' "
		cQry += " WHERE GSB.GSB_FILIAL = '" + xFilial("GSB") + "'	AND GSB.D_E_L_E_T_ <> '*' "
		cQry += "   AND GSB.GSB_REGGER = '" + M->GSB_REGGER + "' "
		If GSB->(FieldPos("GSB_REGATE")) > 0
			cQry += "   AND GSB.GSB_REGATE = '" + M->GSB_REGATE + "' "
		Endif

		cQry := ChangeQuery(cQry)
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQry), 'QRYTOT', .F., .T.)
		dbSelectArea("QRYTOT")
		DbGoTop()
		If (QRYTOT->nTotReg > 0)
			lRet := MsgYesNo("O Prontuแrio informado jแ esta relacionado com um endere็o com tipo de controle [" + AllTrim(HS_RDescrB("GSD_ENDTIP", cEndTip)) + "] e tipo de endere็o [" + AllTrim(HS_RDescrB("GSD_TIPEND", cTipEnd)) + "], Deseja cadastrar outro com as mesmas informa็๕es ?", "Aten็ใo")
		EndIf
  dbCloseArea()
 EndIf

 RestArea(aArea)
Return(lRet)

/************************************ GERA  ENDERECO PARA MULTI-PRONTUARIO E TERMINACAO***********************************/
Function HS_GerMul(cAlias, nReg, nOpc)

 Local nGDOpc   := GD_INSERT + GD_UPDATE + GD_DELETE
 Local cCodPac  := ""
 Local cListB   := " "
 Local cArqOld  := ""
 Local nOpcA    := 0
 Local aSize    := {}
 Local aObjects := {}
 Local cCampo   := Space(100), oCbx, aCbx := {}, aSix := {}, cOrd := "", oBigGet
 Private oEnder, oDescri
 Private cCodEnd  := CriaVar("GSD_CODEND")
 Private cDesEnd  := SPACE(LEN(GSD->GSD_DESEND))
 Private aCodEnd  := HS_CfgSx3("GSB_CODEND")
 Private cEndTip  := "", cEndCod := "", cTermin := ""
 Private cTipAte  := ""

 If !Pergunte(cPerg,.T.)
 	return( Nil )
 EndIf
 cTipAte := ALLTRIM(STR(MV_PAR05))

 Processa({||FS_MontMul()})

 If EMPTY(aCGSB)
 	HS_MsgInf(STR0034, STR0010, STR0035)  //"Nao encontrou Prontuarios sem Endereco..."###"Atencao"###"Gera็ใo de Endere็o para os prontuarios com controle do tipo Multi e Termina็ใo"
  Return(Nil)
 EndIf

 //Preenche a chave da pesquisa no Combo
 aAdd(aSix, {STR0014, "1"}) //"Prontuario"
 aAdd(aCbx, STR0014) //"Prontuario"

 aSize    := MsAdvSize(.T.)
 AAdd( aObjects, { 100, 015, .T., .T., .T. } )
 AAdd( aObjects, { 100, 070, .T., .T. } )
 AAdd( aObjects, { 100, 015, .T., .T., .T. } )
 aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs    := MsObjSize( aInfo, aObjects, .T. )

 cGsDCtrl := "02" //Filtra os enderecos multi-prontuarios e Terminacao Ativos
 cGsDTipo := STR(MV_PAR05,1,0) // Filtra enderecos ambulatorio , PA, Internacao

 DEFINE MSDIALOG oDlg FROM 0,0 TO 400,945 PIXEL TITLE STR0041
  oPEnd	:=	tPanel():New(aPObjs[1, 1], aPObjs[1, 2],, oDlg,,,,,, aPObjs[1, 3], aPObjs[1, 4])
  oPEnd:Align := CONTROL_ALIGN_TOP
  oSay1        := tSay():New(23,10,{|| STR0020 },oDlg,,,,,,.T.,,,130,10)
  oSay0        := tSay():New(36,43,{|| STR0021 },oDlg,,,,,,.T.,,,130,10)  //"Descricao do Endereco ..: "
  @ 020, 110 MsGet oEnder VAR cCodEnd VALID FS_VldEnd(cCodEnd, @cDesEnd) F3 aCodEnd[SX3->(FieldPos("X3_F3"))] Picture aCodEnd[SX3->(FieldPos("X3_PICTURE"))] OF oDlg Pixel
	 @ 035, 110 MsGet oDescri VAR cDesEnd OF oDlg Pixel
		oDescri:lReadOnly := .T.

  @ aPObjs[2,1]+40,aPObjs[2,2] LISTBOX oListB VAR cListB FIELDS HEADER " ",STR0014,STR0015,STR0016,STR0017; //"Prontuario"###"Paciente"###"Endereco"###"Descricao"
   SIZE 505,245  OF oDlg PIXEL ON DBLCLICK(FS_Marc(oListB, aCGSB))
  oListB:SetArray( aCGSB )
  oListB:bLine := {|| { IIf( !aCGSB[oListB:nAt, 1], oNo, oTik),aCGSB[oListB:nAt, 2], aCGSB[oListB:nAt, 3], aCGSB[oListB:nAt, 4], aCGSB[oListB:nAt, 5]}}
  olistB:Align := CONTROL_ALIGN_ALLCLIENT
  oMarcaT      := { {"checked", {|| FS_Mtodos(oListB,aCGSB) }, STR0018, STR0019} }  //"Marca/Desmarca Todos ou Inverte selecao"###"Selecao"

  oPPesq	:=	tPanel():New(aPObjs[3, 1], aPObjs[3, 2],, oDlg,,,,,, aPObjs[3, 3], aPObjs[3, 4])
  oPPesq:Align := CONTROL_ALIGN_BOTTOM

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, oDlg:End()  }, {|| nOpcA := 0, oDlg:End() },,oMarcaT)

 If nOpcA == 1
  Begin Transaction
  Processa( {||  FS_GraEnd() } )
  End Transaction
 EndIf

 cGsDCtrl := ""
 cGsDTipo := ""

Return(Nil)

/*************************************** SELECIONA PACIENTES SEM ENDERECOS  ***************************************/
Static Function FS_MontMul()
 Local bAdiciona :={||IncProc(STR0022+(cAlias95A)->GCY_REGGER),   AADD(aCGSB,{ .F.,(cAlias95A)->GCY_REGGER ,(cAlias95A)->GCY_NOME ,"",""} ),   DbSkip() } //"Prontuario No. => "
 aCGSB     := {}
 	#IFDEF TOP

  If TcSrvType() != "AS/400"
   cQuery := "SELECT DISTINCT "
	  cQuery += "GCY.GCY_FILIAL, GCY.GCY_REGGER GCY_REGGER, "
	  cQuery += "GCY.GCY_NOME GCY_NOME "
	  cQuery += "FROM "+RetSqlName("GCY") + " GCY "
	  cQuery += "WHERE "
	  cQuery += "GCY.GCY_FILIAL =  '" + xFilial( "GCY" ) + "' AND "
   cQuery += "GCY.D_E_L_E_T_ <> '*' "
   cQuery += "AND NOT EXISTS "
   cQuery += "(SELECT GSB_REGGER FROM " + RetSqlName("GSB") + " WHERE GSB_FILIAL = '" + xFilial("GSB") + "'"
   cQuery += " AND GCY_REGGER = GSB_REGGER)"

   If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
    cQuery += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	  EndIf
   If !Empty(MV_PAR03)
    cQuery += " AND GCY.GCY_LOCATE = '" + MV_PAR03 + "'"
	 	EndIf
	 	If !Empty(MV_PAR04)
    cQuery += " AND GCY.GCY_CODCRM = '" + MV_PAR04 + "'"
	 	EndIf
   If MV_PAR05 == 1
 	  cQuery += " AND GCY.GCY_ATENDI = '1'"
 	 ElseIf MV_PAR05 == 2
 	  cQuery += " AND GCY.GCY_ATENDI = '2'"
   ElseIf MV_PAR05 == 3
 	  cQuery += " AND GCY.GCY_ATENDI = '0'"
   EndIf

   cQuery += " ORDER BY GCY_FILIAL, GCY_NOME"
   cQuery := ChangeQuery(cQuery)
	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias95A,.F.,.F.)
	  DbSelectArea(cAlias95A)
	  ProcRegua(1000)
   dBGotop()
   While !Eof()

    Eval(bAdiciona)

   EndDo
   DbSelectArea(cAlias95A)
 	 dbCloseArea()
  EndIf
	#ENDIF

 dbSelectArea("GSB")
 dbSetOrder(1)

Return(Nil)
/*******************************************  MARCA LINHAS NO BROWSE  *********************************************/
Static Function FS_Marc(oListB, aCGSB)
 Local bMarque := {||aCGSB[oListB:nAt, 1] := !aCGSB[oListB:nAt, 1], oListB:Refresh()}

 If Empty(cEndTip)
  HS_MsgInf(STR0042,STR0028, STR0019 )//"Endereco Nao selecionado..."##"Atencao..."##"Selecao"
  Return(Nil)
 Endif
 If cEndTip == "2" .AND. aCGSB[oListB:nAt, 1] == .F.
  If Substr(aCGSB[oListB:nAt, 2], len(GSB->GSB_REGGER), 1) <> cTermin
   HS_MsgInf(STR0013, STR0010,STR0019)// "Termina็ใo do endere็o precisa ser a mesma da termina็ใo do prontuแrio"##"Atencao..."##"Selecao"
   Return(Nil)
  Endif
 Endif
 If Len(aCGSB) > 0
  Eval ( bMarque )
 EndIf

Return(Nil)
/********************************************* MARCA TODOS NO BROWSE  ********************************************/
Static Function FS_Mtodos(oListB,aCGSB)
 Local nCtaMarca, bMarque:={|| oListB:nAt := nCtaMarca, aCGSB[oListB:nAt, 1] := !aCGSB[oListB:nAt, 1]}, bRestObj:={||oListB:Refresh(),oListB:nAt := 1}

 If Empty(cEndTip)
  HS_MsgInf(STR0042,STR0028, STR0019 )//"Endereco Nao selecionado..."##"Atencao..."##"Selecao"
  Return(Nil)
 Endif

 For nCtaMarca := 1 to Len(aCGSB)
 If cEndTip == "2" .AND. aCGSB[nCtaMarca, 1] == .F.
  If Substr(aCGSB[nCtaMarca, 2], len(GSB->GSB_REGGER), 1) <> cTermin
   Loop
  Endif
 Endif
  Eval ( bMarque )
 Next
 Eval ( bRestObj)
Return(Nil)

/******************************************* SELECIONA O ENDERECO PARA INCLUSAO  **********************************/
Static Function FS_VldEnd(cCodigo, cDescEnd)
Local lRet := .T.
Local aArea := GetArea()

 If Empty(cCodigo)
 	HS_MsgInf(STR0027, STR0028, STR0019) //"Codigo do Endereco Invalido"###"Atencao..."###"Selecao"
 	Return(.F.)
 Else
  cDescEnd := HS_IniPadr("GSD",1,cCodigo,"GSD_DESEND",,.F.)
  cEndTip  := GSD->GSD_ENDTIP
  If cEndTip == "2"
   cTermin := GSD->GSD_TERMIN
  Endif
  If Empty(cDescEnd)
   HS_MsgInf(STR0029, STR0028, STR0019) //"Codigo do Endereco Nao Encontrado"###"Atencao..."###"Selecao"
   lRet := .F.
  ElseIf cEndTip == "1"
   HS_MsgInf(STR0043, STR0028, STR0019) //"Controle do endere็o nใo pode ser do tipo pasta"###"Atencao..."###"Selecao"
   lRet := .F.
  ElseIf GSD->GSD_EATIVO == "1"
   HS_MsgInf(STR0039, STR0028, STR0019) //"Endere็o nใo pode estar desativado"###"Atencao..."###"Selecao"
   lRet := .F.
  ElseIf !Empty(cTipAte) .AND. GSD->GSD_TIPEND <> cTipAte
   HS_MsgInf(STR0044, STR0028, STR0019) //"Tipo de endere็o tem que ser igual ao tipo escolhido no grupo de perguntas"###"Atencao..."###"Selecao"
   lRet := .F.
  EndIf
 Endif

 If lRet
  oEnder:Disable()
 EndIf
 RestArea(aArea)
Return(lRet)

/******************************************** GRAVA AS SELECOES DE PACIENTES COM ENDERECO *************************/
Static Function FS_GraEnd()
 Local nCtafor := 1
 Local aArea := GetArea()

 If !Empty(cCodEnd)
  If Len(aCGSB) > 0

   dbSelectArea("GSB")

   ProcRegua(Len(aCGSB))

   For nCtaFor := 1 to Len(aCGSB)

    If aCGSB[nCtaFor,1]
     IncProc("Prontuario => "+aCGSB[nCtaFor,2] )
     RecLock("GSB", .T.)
      GSB->GSB_FILIAL := xFilial("GSB")
      GSB->GSB_REGGER := aCGSB[nCtaFor,2]
      GSB->GSB_CODEND := cCodEnd
      GSB->GSB_DESEND := cDesEnd
      GSB->GSB_LOGARQ := HS_LOGARQ()
     MsUnLock()
    EndIf
   Next
  EndIf
 Else
 	HS_MsgInf(STR0023, STR0010, STR0036)  //"NAO Foi Escolhido Endereco...Operacao cancelada."###"Atencao"###"Sele็ใo de Paciente(s)"
 EndIf
 RestArea(aArea)
Return(Nil)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑ      chama etiqueta do SPP                                              ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
FUNCTION HS_ETQSAME()
 Local cNomeEtq := ALLTRIM(GETMV("MV_ETIQSAM"))
 IF !Empty(cNomeEtq)
  /* 1o. parametro nome da etiqueta*/
  /* 2o. parametro matriz com: 1=qtde de cada etiq. parametro pergunta de/ate */
  HSPAHR71(cNomeEtq,{1, GSB->GSB_REGGER, GSB->GSB_CODEND} )
 Else
  HS_MsgInf(STR0026, STR0010, STR0037)   //"O nome da etiqueta NAO esta informado no parametro MV_ETIQSAM...Operacao cancelada."###"Atencao"###"Chama etiqueta do SPP"
 EndIf
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ATICPO บ Autor ณ Mario Arizono      บ Data ณ  05/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que habilitao o campo tipo de endereco.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_ATICPO(cCodend)
 Local aArea := GetArea()
 Local lRet  := .T.

 DbSelectArea("GSD")
 DbSetOrder(1)
 If DbSeek(xFilial("GSD") + cCodend)
  If GSD->GSD_ENDTIP <> "1"
   lRet := .F.
  Endif
 Else
  lRet := .F.
 Endif
 RestArea(aArea)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ENDERB บAutor  ณSaude               บ Data ณ  11/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o Prontuario X Endereco X Registro Atendimento       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function  HS_ENDERB()
Local lRet:=.T.

DbSelectArea("GSB")
DbSetOrder(1)

 If DBSeek(xFilial("GSB") + M->GSB_REGGER + M->GSB_CODEND + M->GSB_REGATE)
 	HS_MsgInf(STR0011, STR0010, STR0031) //"Relacionamento Prontuario x Endereco ja existente..."###"Atencao"###"Inclusใo nใo Permitida"
 	lRet := .F.
 Endif

Return(lret)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 06/06/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRot1     := {{STR0024,"HSPAHRDD()"  , 0, 3},;  //"Atendimento"
                      {STR0014 ,"HSPAHRC3()"  , 0, 3}}  //"Prontuario"

Local aRotina :=	{{STR0002,"AxPesqui"    ,0, 1, 0, nil},; //"Pesquisar"
                     {STR0003,"AxVisual"    ,0, 2, 0, nil},; //"Visualizar"
                     {STR0004,"HS_A95"      ,0, 3, 0, nil},; //"Incluir"
                     {STR0006,"HS_A95"      ,0, 5, 0, nil},; //"Excluir"
                     {STR0005,"HS_GerMul"   ,0, 4, 0, nil},; //"Relac. Multi/Term"
                     {STR0025,"HS_ETQSAME()",0, 3, 0, nil},; //"Etiqueta"
                     {STR0008,aRot1         ,0, 6, 0, nil}}  //"Extrato"
Return(aRotina)
