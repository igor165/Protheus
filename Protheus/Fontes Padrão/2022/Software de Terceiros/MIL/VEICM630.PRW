#Include "VEICM630.CH"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICM630 | Autor ³ Andre Luis Almeida    ³ Data ³ 22/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro/Manutencao dos Parametros do Sistema SX6          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM630()
Private lVis    := .f.
Private lInc    := .f.
Private lAlt    := .f.
Private lExc    := .f.
Private lGrv    := .f.
Private cOpcao  := ""
Private aCampos := {}
Private aCores  := {{ 'CM630PAR()', 'BR_VERMELHO' },;				// Nao existe o Parametro no SX6
							{'VPC->VPC_PROPRI == "S"', 'BR_VERDE'  } ,;	// Parametro do Sistema
							{'VPC->VPC_PROPRI == "U"', 'BR_LARANJA'} }	// Parametro do Usuario
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0001)
mBrowse( 6, 1,22,75,"VPC",,,,,,aCores)
Return

Function FVCM630V()
	lVis := .t.
	lInc := .f.
	lAlt := .f.
	lExc := .f.
	cOpcao := STR0003
	FS_VCM630("V")
Return

Function FVCM630I()
	lVis := .f.
	lInc := .t.
	lAlt := .f.
	lExc := .f.
	cOpcao := STR0004
	FS_VCM630("I")
Return

Function FVCM630A()
	lVis := .f.
	lInc := .f.
	lAlt := .t.
	lExc := .f.
	cOpcao := STR0005
	FS_VCM630("A")
Return

Function FVCM630E()
	lVis := .f.
	lInc := .t.
	lAlt := .f.
	lExc := .t.
	cOpcao := STR0006
	FS_VCM630("E")
Return

Static Function FS_VCM630(cTp)
Local lOk  := .f.
Private lParam  := .f.
Private lTipo   := .f.
Private lSX6    := .f.
Private lAjuda  := .t.
Private cParam  := space(10)
Private cPropr  := If(__CUSERID=="000000","S","U")
Private cProprD := ""
Private aPropr  := {"U","S"}
Private cTipo   := "C"
Private cTipoD  := ""
Private aTipo   := {"C","N","L","D"}
Private cValid  := space(50)
Private cDesc   := space(50)
Private cDesc1  := space(50)
Private cDesc2  := space(50)
Private cAjuda  := ""
Private cAlterac:= ""
Private cConteud:= space(250)
Private aMemos  := {{"VPC_ALTERO","VPC_ALTERM"}}
lGrv := .f.
DbSelectArea("VPC")
If cTp # "I" // # Incluir
	DbSelectArea("SX6")
	DbSetOrder(1)
	If DbSeek( xFilial("SX6") + VPC->VPC_PARAM )
		lSX6   := .t.
		cParam := SX6->X6_VAR
		cTipo  := SX6->X6_TIPO
		cDesc  := substr(VPC->VPC_DESC,1,50)
		cDesc1 := substr(VPC->VPC_DESC,51,50)
		cDesc2 := substr(VPC->VPC_DESC,101,50)
		cConteud := SX6->X6_CONTEUD
		cPropr := VPC->VPC_PROPRI
		cValid := VPC->VPC_VALID
		cAjuda := Alltrim(VPC->VPC_AJUDA1) + " " + Alltrim(VPC->VPC_AJUDA2)
		cAlterac := E_MSMM(VPC->VPC_ALTERO,70)
	Else
		If	cTp == "A" // Alterar
			If MsgYesNo(STR0011+" '"+Alltrim(VPC->VPC_PARAM)+"' "+STR0012,STR0013)
				cOpcao := STR0004
				lInc   := .f.
				lSX6   := .f.
				lParam := .f.
				lTipo  := .t.
				lGrv   := .t.
			Else
				Return
			EndIf
		EndIf
		cDesc  := substr(VPC->VPC_DESC,1,50)
		cDesc1 := substr(VPC->VPC_DESC,51,50)
		cDesc2 := substr(VPC->VPC_DESC,101,50)
		cParam := VPC->VPC_PARAM
		cPropr := VPC->VPC_PROPRI
		cValid := VPC->VPC_VALID
		cAjuda := Alltrim(VPC->VPC_AJUDA1) + " " + Alltrim(VPC->VPC_AJUDA2)
		cAlterac := E_MSMM(VPC->VPC_ALTERO,70)
	EndIf
	If cTp == "A"
		If VPC->VPC_PROPRI == "U"
			lParam := .t.
			lTipo  := .t.
		EndIf
	EndIf
Else // Incluir
	lInc   := .t.
	lSX6   := .f.
	lParam := .t.
	lTipo  := .t.
	lGrv   := .t.
EndIf

FS_DESC()

DEFINE MSDIALOG oParSis TITLE (STR0001+" - "+cOpcao) From 5,08 to 28,61 of oMainWnd
	@ 006,005 SAY (STR0011+":") SIZE 45,40 OF oParSis  PIXEL COLOR CLR_BLUE
	@ 005,040 MSGET oParam VAR cParam PICTURE "@!" VALID FS_VALPAR() SIZE 40,8 OF oParSis PIXEL COLOR CLR_BLUE WHEN (lParam .and. !(lExc .or. lVis))
	@ 006,105 SAY (STR0014+":") SIZE 45,40 OF oParSis  PIXEL COLOR CLR_BLUE
  	@ 005,140 MSCOMBOBOX oTipo VAR cTipo ITEMS aTipo VALID FS_DESC() SIZE 20,08 OF oParSis PIXEL COLOR CLR_BLUE WHEN (lTipo .and. !(lExc .or. lVis))
	@ 006,160 SAY cTipoD SIZE 25,8 OF oParSis PIXEL COLOR CLR_BLUE
	@ 018,105 SAY (STR0015+":") SIZE 45,40 OF oParSis  PIXEL COLOR CLR_BLUE
  	@ 017,140 MSCOMBOBOX oPropr VAR cPropr ITEMS aPropr VALID FS_DESC() SIZE 20,08 OF oParSis PIXEL COLOR CLR_BLUE WHEN !(lExc .or. lVis) .and. (__CUSERID=="000000") .and. !lAlt
	@ 018,160 SAY cProprD SIZE 25,8 OF oParSis PIXEL COLOR CLR_BLUE
	@ 030,005 SAY (STR0016+":") SIZE 45,40 OF oParSis  PIXEL COLOR CLR_BLUE
	@ 029,040 MSGET oValid VAR cValid PICTURE "@!" SIZE 166,8 OF oParSis VALID FS_VALCONT("V") PIXEL COLOR CLR_BLUE WHEN !(lExc .or. lVis) .and. (__CUSERID=="000000")
	@ 042,005 SAY (STR0017+":") SIZE 45,40 OF oParSis  PIXEL COLOR CLR_BLUE
	@ 041,040 MSGET oConteud VAR cConteud PICTURE "@!" SIZE 166,8 OF oParSis VALID FS_VALCONT("C") PIXEL COLOR CLR_BLUE WHEN !(lExc .or. lVis)
	@ 054,005 SAY (STR0018+":") SIZE 45,40 OF oParSis  PIXEL COLOR CLR_BLUE
	@ 053,040 MSGET oDesc VAR cDesc PICTURE "@!" SIZE 166,8 OF oParSis PIXEL COLOR CLR_BLUE WHEN !(lExc .or. lVis) .and. ((__CUSERID=="000000").or.cPropr=="U")
	@ 062,040 MSGET oDesc1 VAR cDesc1 PICTURE "@!" SIZE 166,8 OF oParSis PIXEL COLOR CLR_BLUE WHEN !(lExc .or. lVis) .and. ((__CUSERID=="000000").or.cPropr=="U")
	@ 071,040 MSGET oDesc2 VAR cDesc2 PICTURE "@!" SIZE 166,8 OF oParSis PIXEL COLOR CLR_BLUE WHEN !(lExc .or. lVis) .and. ((__CUSERID=="000000").or.cPropr=="U")
	@ 082,005 SAY (STR0019+":") SIZE 45,40 OF oParSis PIXEL COLOR CLR_BLUE
   If !(lExc .or. lVis) .and. ((__CUSERID=="000000").or.Empty(cAjuda))
		@ 091,005 GET oAjuda VAR cAjuda OF oParSis MEMO SIZE 200,041 VALID FS_VALAJU() PIXEL COLOR CLR_BLUE
		@ 162,120 BUTTON oOK PROMPT OemToAnsi(STR0020) OF oParSis SIZE 60,10 PIXEL ACTION (lOk:=.t.,oParSis:End()) WHEN !Empty(cParam) .and. lAjuda
		@ 162,030 BUTTON oSair PROMPT OemToAnsi(STR0021) OF oParSis SIZE 60,10 PIXEL ACTION oParSis:End()
	Else
		@ 162,120 BUTTON oOK PROMPT OemToAnsi(STR0020) OF oParSis SIZE 60,10 PIXEL ACTION (lOk:=.t.,oParSis:End()) WHEN !Empty(cParam) .and. lAjuda
		@ 162,030 BUTTON oSair PROMPT OemToAnsi(STR0021) OF oParSis SIZE 60,10 PIXEL ACTION oParSis:End()
		@ 091,005 GET oAjuda VAR cAjuda OF oParSis MEMO SIZE 200,041 PIXEL COLOR CLR_BLUE READONLY MEMO
	EndIf 
	@ 135,005 GET oAlterac VAR cAlterac OF oParSis MEMO SIZE 200,025 PIXEL COLOR CLR_BLUE READONLY MEMO

ACTIVATE MSDIALOG oParSis CENTER 
If lOk .and. cTp # "V"
	If cTp # "E"
		If cTp == "I"
			DbSelectArea("SX6")
			DbSetOrder(1)
			If DbSeek( xFilial("SX6") + cParam )
				lSX6 := .t.
			Else
				lSX6 := .f.
			EndIf
		Else
			DbSelectArea("SX6")
			DbSetOrder(1)
			If DbSeek( xFilial("SX6") + VPC->VPC_PARAM )
				lSX6 := .t.
			Else
				lSX6 := .f.
			EndIf
		EndIf
		If	cTp == "A" .and. lSX6 .and. left(Alltrim(SX6->X6_CONTEUD)+space(250),250) # left(Alltrim(cConteud)+space(250),250)
			cAlterac := left(UsrRetName(__CUSERID)+space(13),13)+" "+Transform(dDataBase,"@D")+"-"+Transform(time(),"@R 99:99")+STR0033+" - "+STR0017+": "+Alltrim(SX6->X6_CONTEUD)+" -> "+Alltrim(cConteud)+CHR(13)+CHR(10)+cAlterac
		EndIf
		If ( cTp == "I" .or. cTp == "A" )
			DbSelectArea("SX6")
			RecLock("SX6",!lSX6)
				SX6->X6_FIL     := xFilial("SX6")
				SX6->X6_VAR     := cParam
				SX6->X6_TIPO    := cTipo
				If lGrv
					SX6->X6_DESCRIC := cDesc
					SX6->X6_DSCSPA  := cDesc
					SX6->X6_DSCENG  := cDesc
					SX6->X6_DESC1   := cDesc1
					SX6->X6_DSCSPA1 := cDesc1
					SX6->X6_DSCENG1 := cDesc1
					SX6->X6_DESC2   := cDesc2
					SX6->X6_DSCSPA2 := cDesc2
					SX6->X6_DSCENG2 := cDesc2
				EndIf
				SX6->X6_CONTEUD := cConteud
				SX6->X6_CONTSPA := cConteud
				SX6->X6_CONTENG := cConteud
			MsUnLock()
		EndIf
		DbSelectArea("VPC")
		RecLock("VPC",lInc)
			VPC->VPC_FILIAL := xFilial("VPC")
			VPC->VPC_PARAM  := cParam
			VPC->VPC_DESC   := cDesc + cDesc1 + cDesc2
			VPC->VPC_PROPRI := cPropr
			VPC->VPC_VALID  := cValid
			VPC->VPC_AJUDA1 := substr(cAjuda,1,250)
			VPC->VPC_AJUDA2 := substr(cAjuda,251,250)
		MsUnLock()
		If cTp == "A"
			DbSelectArea("VPC")
   		RecLock("VPC",.F.)         
				MSMM(,TamSx3("VPC_ALTERM")[1],,cAlterac,1,,,"VPC","VPC_ALTERO")
			MsUnlock()
		EndIf
	Else
		DbSelectArea("VPC")
		If VPC->VPC_PROPRI == "U"
			DbSelectArea("SX6")
			RecLock("SX6",.f.,.t.)
				DbDelete()	
			MsUnLock()
		EndIf
		DbSelectArea("VPC")
		RecLock("VPC",.f.,.t.)          
			DbDelete()
		MsUnLock()
	EndIf
EndIf
Return   

Static Function FS_DESC()
Do Case 
	Case cTipo == "C"
		cTipoD  := STR0022
	Case cTipo == "N"
		cTipoD  := STR0023
	Case cTipo == "L"
		cTipoD  := STR0024
	Case cTipo == "D"
		cTipoD  := STR0025
EndCase
Do Case 
	Case cPropr == "U"
		cProprD  := STR0026
	Case cPropr == "S"
		cProprD  := STR0027
EndCase
Return

Static Function FS_VALCONT(cX)
Local lRet := .t.
Local ni   := 0
Local cS   := ""
Private le     := .f.
Private bBlock := ErrorBlock()
Private bErro  := ErrorBlock( { |e| le:=.t. } )
If cX == "V"
	If !Empty(cValid)
		lRet := .f.
		If Alltrim(cParam) $ Alltrim(cValid)
			cS := "<>=+-/*!#$"
			For ni := 1 to len(cS)
				If substr(cS,ni,1) $ Alltrim(cValid)
					lRet := .t.
					Exit
				EndIf			
			Next
		EndIf
		If !lRet
			MsgInfo(STR0029,STR0013)
		EndIf
	EndIf
ElseIf cX == "C"
	If !Empty(cValid)
		Do Case 
			Case cTipo == "C"
				&(Alltrim(cParam)) := Alltrim(cConteud)
			Case cTipo == "N"
				&(Alltrim(cParam)) := val(Alltrim(cConteud))
			Case cTipo == "L"
				&(Alltrim(cParam)) := &(Alltrim(cConteud))
			Case cTipo == "D"
				&(Alltrim(cParam)) := ctod(Alltrim(cConteud))
		EndCase
		If !&(Alltrim(cValid))
			lRet := .f.
			If le
				MsgStop(STR0030,STR0013)
				cValid:=space(50)
				oValid:SetFocus()
			Else
				MsgInfo(STR0031,STR0013)
			EndIf
		EndIf
	EndIf
EndIf
ErrorBlock(bBlock)
Return(lRet)

Static Function FS_VALPAR()
Local lRet := .t.
If lInc
	DbSelectArea("VPC")
	DbSetOrder(1)
	If DbSeek( xFilial("VPC") + cParam )
		MsgInfo(STR0011+" '"+Alltrim(cParam)+"' "+STR0028,STR0013)
		lRet := .f.
	Else
		DbSelectArea("SX6")
		DbSetOrder(1)
		If DbSeek( xFilial("SX6") + cParam )
			lSX6   := .t.
			cTipo  := SX6->X6_TIPO
			cDesc  := SX6->X6_DESCRIC
			cDesc1 := SX6->X6_DESC1
			cDesc2 := SX6->X6_DESC2
			cConteud := SX6->X6_CONTEUD
			lGrv   := .t.
			cPropr := "S"
			lParam := .f.
			lTipo  := .f.
			FS_DESC()
		EndIf
	EndIf
EndIf
Return(lRet)           
       
Static Function FS_VALAJU()
	lAjuda := .t.
	If len(cAjuda) > 500
		lAjuda := .f.
		MsgAlert(STR0032+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"..."+substr(cAjuda,470,30)+" <-",STR0013)
	EndIf
Return(.t.)

Function CM630PAR()
Local lRet := .f. 
DbSelectArea("SX6")
DbSetOrder(1)
If !DbSeek( xFilial("SX6") + VPC->VPC_PARAM )
	lRet := .t.
EndIf
DbSelectArea("VPC")
Return(lRet)

Function CM630LEG() // Legenda
Local aLegenda  := {{ 'BR_VERDE'  , STR0008 },;	// Parametro do Sistema
						{ 'BR_LARANJA'  , STR0009 },;		// Parametro do Usuario
						{ 'BR_VERMELHO' , STR0010 }}		// Nao existe o Parametro no SX6
BrwLegenda(cCadastro,STR0007,aLegenda)
Return .T.

Static Function MenuDef()
Local aRotina := { { STR0002 ,"AxPesqui", 0 , 1},;		// Pesquisar
                     { STR0003 ,"FVCM630V", 0 , 2},; 	// Visualizar
                     { STR0004 ,"FVCM630I", 0 , 3 },;	// Incluir
                     { STR0005 ,"FVCM630A", 0 , 4 },;	// Alterar
                     { STR0006 ,"FVCM630E", 0 , 5 },;	// Excluir
                     { STR0007 ,"CM630LEG",0, 2,0,.f.}} // Legenda
Return aRotina
