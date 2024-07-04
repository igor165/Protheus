// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 0     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Veivm005.ch"
#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM005 ³ Autor ³ Andre                 ³ Data ³ 18/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Devolucao da SAIDA de veiculos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM005
Private lGspInUse	:= .t.
Private cNfiOri, cSerOri
Private cEstFor, cLojFor, nOpcMnu
Private cChaInt, cChassi, cCodTes, nCusVei, nVBaIcm, nAliIcm, nTotIcm, cAlmVei, cNota, cSerie, cNumero
Private cGruVei      := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Private lAbortPrint  := .f.
Private aRotina      := MenuDef()
Private lChaTemp     := .f.
Private lMSErroAuto  := .f.
Private lMSHelpAuto  := .t.
Private bRefresh     := { || .t. }
Private aIteParc     := {{cTod(""),0}}
Private cBIcm0       := FlagQtVei := .t.
Private cOpeMov      := Subs(OemToAnsi(STR0022),1,1)  // Devolucao
Private cCadastro    := OemToAnsi(STR0002)
Private oFonte       := TFont():New( "Arial", 6, 12 )
Private oFnt6        := TFont():New( "Times New Roman", 7, 17 )
Private M->VVF_QTDVEI := 1
Private lMudouNum := .f.

aCampoVV1 := {}
FlagQtVei := .t.
Inclui    := .t.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VV0")
cIndex    := CriaTrab(nil,.f.)
cKey      := IndexKey()
if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) == "S"
	cCondicao := 'VV0->VV0_SITNFI $ "12" .and. !Empty(VV0->VV0_NUMNFI) .and. VV0->VV0_TIPFAT <> "2" .and. VV0->VV0_OPEMOV = "0"'
else
	cCondicao := '!Empty(VV0->VV0_NUMPED) .and. VV0->VV0_SITNFI $ "12" .and. !Empty(VV0->VV0_NUMNFI) .and. VV0->VV0_TIPFAT <> "2" .and. VV0->VV0_OPEMOV = "0"'
endif

IndRegua("VV0",cIndex,"VV0_FILIAL+DtoS(VV0_DATMOV)",,cCondicao,OemToAnsi(STR0018))  //Aguarde Filtrando Registros...
DbSelectArea("VV0")
nIndex := RetIndex("VV0")
#IFNDEF TOP
	DbSetIndex(cIndex+OrdBagExt())
#ENDIF
DbSetOrder(nIndex+1)

mBrowse( 6, 1,22,75,"VV0",,,,"!VV0->VV0_SITNFI == '2'")

DbSelectArea("VV0")
RetIndex()
DbsetOrder(1)

#IFNDEF TOP
	If File(cIndex+OrdBagExt())
		fErase(cIndex+OrdBagExt())
	Endif
#ENDIF

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DEVVEI   ³ Autor ³  Manoel               ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de Entrada de Veiculos (por Devolucao)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DEVVEI(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor  := 0

Private oDesTes, cDesTes, cNota, cSerie
Private cNTran := VV0->VV0_NUMTRA
Private oDatEmi, dDatEmi
Private aMemos  := {{"VVF_OBSMEM","VVF_OBSERV"}}
Private cObserv := E_MSMM(VVF->VVF_OBSMEM,68)

if VV0->(EOF())
	Return .t.
Endif

//Zera as variaveis fiscais
MaFisEnd()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Inclui
	DbSelectArea("SX3")
	DbSeek("VVF")
	While !Eof().and.(x3_arquivo=="VVF")
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
		DbSkip()
	EndDo
Else
	RegToMemory("VVF",.f.)
	DbSelectArea("VVF")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Inclui
	DbSelectArea("SX3")
	DbSeek("VVG")
	While !Eof().and.(x3_arquivo=="VVG")
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
		DbSkip()
	EndDo
Else
	DbSelectArea("VVG")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

Do Case
	Case nOpc == 2
		Private cTipoNF := "V" // Veiculo
		DbSelectArea("SF2")
		DbSetOrder(1)
		if DbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
			ImpNotaPS() // Consulta da Nota Fiscal
		Endif
	Case nOpc == 3  // Devolucao
		
		if VV0->VV0_SITNFI == "2" .and. nOpc == 3
			MsgInfo(STR0055 ,STR0009) //Nota Fiscal ja foi Devolvida... - Atencao
			Return .f.
		Endif
		
		DbSelectArea("CTT")
		DbSetOrder(1)
		
		// Posiciona no Item da Nota de Saida
		DbSelectArea("VVA")
		DbSetOrder(1)
		DbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
		
		cChassi := VVA->VVA_CHASSI
		cChaInt := VVA->VVA_CHAINT
		
		dDatEmi := dDataBase
		cCodTes := Space(3)
		cCenCus := Space(9)
		cCodDes := VV0->VV0_CODCLI
		cLojDes := VV0->VV0_LOJA
		cNomDes := ""
		cDesTes := ""
		cDesCC  := ""
		FS_VALCLI(1)
		FS_VALCLI(2)
		nOpca   := 2
		
		DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0056) FROM  02,01 TO 14,50 OF oMainWnd  //Dados da Devolucao
		
		@ 017,014 SAY OemToAnsi(STR0057)  OF oDlg PIXEL COLOR CLR_BLUE //Cliente
		@ 017,064 MSGET oCodDes VAR cCodDes PICTURE "@9" VALID FS_VALCLI(1) F3 "VSC" SIZE 40,4  OF oDlg PIXEL COLOR CLR_BLACK when .f.
		@ 017,114 MSGET oLojDes VAR cLojDes PICTURE "@9" VALID FS_VALCLI(2) SIZE 2,4  OF oDlg PIXEL COLOR CLR_BLACK when .f.
		@ 030,014 SAY oNomDes VAR cNomDes OF oDlg PIXEL SIZE 84,6 COLOR CLR_BLUE
		
		@ 040,014 SAY OemToAnsi(STR0058)  OF oDlg PIXEL COLOR CLR_BLUE              // TES
		@ 040,064 MSGET oCodTes VAR cCodTes PICTURE "@!" VALID FS_VALTES(cCodTes) F3 "SF4" SIZE 43,4 OF oDlg PIXEL COLOR CLR_BLACK
		@ 053,014 SAY oDesTes VAR cDesTes SIZE 160,8 OF oDlg PIXEL COLOR CLR_BLUE   // Descricao do TES
		
		@ 063,014 SAY OemToAnsi(STR0059)  OF oDlg PIXEL COLOR CLR_BLUE              // Centro de Custo
		@ 063,064 MSGET oCenCus VAR cCenCus PICTURE "@!" VALID FS_VALCC() F3 "CTT" SIZE 43,4 OF oDlg PIXEL COLOR CLR_BLACK
		@ 076,014 SAY oCenCus VAR cDesCC SIZE 160,8 OF oDlg PIXEL COLOR CLR_BLUE   // Descricao do Centro de Custo
		
		@ 5000,5000 BUTTON oBtnFoco PROMPT "" OF oDlg ACTION (.T.) PIXEL
		
		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||nOpca := 1,oDlg:End()},{||nOpca := 2,oDlg:End()})
		
		if nOpca <> 1
			Return .t.
		Endif
		
		if Empty(cCodDes)
			MsgInfo(STR0060 ,STR0009)//E necessario informar o codigo do Destinatario... - Atencao
			Return .f.
		Endif
		
		if Empty(cCodTes)
			MsgInfo(STR0061 ,STR0009)//E necessario informar o Tipo de Entrada (TES)... - Atencao
			Return .f.
		Endif
		
		FS_MEMORET()
		
		M->VVF_FORPRO := "0" // Nao
		cNumNota := Space(09)
		cSerNota := Space(03)
		nOpca_   := 0
		DEFINE MSDIALOG oDlgPerg TITLE OemtoAnsi(STR0062) FROM  02,04 TO 15,28 OF oMainWnd   //"Tipo de Inclusao"
		
		nCkPerg1 := 1
		@ 005,005 RADIO oRadio1 VAR nCkPerg1 3D SIZE 70,10 PROMPT;
			OemToAnsi(STR0063), OemToAnsi(STR0064);  //Formulario proprio - Formulario do cliente
			OF oDlgPerg PIXEL ON CHANGE (iif(nCkPerg1==2,(oScroll2:lVisible := .t.),(oScroll2:lVisible := .f.)))

		if VVF->(FieldPos("VVF_ESPECI")) <> 0 
			If !Empty(GetNewPar("MV_ESPECNF","NF") )           //Fnc 27513
//				M->VVF_ESPECI := GetNewPar("MV_ESPECNF","NF")
				M->VVF_ESPECI := GETNewPar("MV_ESPECNF","NF")+space(len(M->VVF_ESPECI)-len(GetNewPar("MV_ESPECNF","NF")))
			EndIf
			@ 029, 005 SAY RetTitle("VVF_ESPECI") OF oDlgPerg PIXEL   //Especid NF
			@ 028, 040 MSGET oEspNF VAR M->VVF_ESPECI PICTURE "@!" SIZE 40,4 F3 "42" VALID (Vazio() .or. ExistCpo("SX5","42"+M->VVF_ESPECI)) OF oDlgPerg PIXEL COLOR CLR_BLACK HASBUTTON
		endif
		
		@ 040, 000 SCROLLBOX oScroll2 VERTICAL SIZE 40,100 OF oDlgPerg NOBORDER PIXEL
		
		@ 001, 005 SAY oEmissao VAR OemToAnsi(STR0065)  OF oScroll2 PIXEL   //Emissao
		@ 001, 035 MSGET oDatEmi VAR dDatEmi PICTURE "@D" SIZE 40,4  OF oScroll2 PIXEL COLOR CLR_BLACK
		@ 014, 005 Say STR0066  OF oScroll2 PIXEL //Nota
		@ 014, 035 MSGET oNumNota VAR cNumNota PICTURE "999999999"  SIZE 45,4  OF oScroll2 PIXEL  COLOR CLR_BLACK
		@ 026, 005 Say STR0067 OF oScroll2 PIXEL //Serie
		@ 026, 035 MSGET oSerNota VAR cSerNota PICTURE "@!" SIZE 25,4  OF oScroll2 PIXEL  COLOR CLR_BLACK
		oScroll2:lVisible := .f.
		
		@ 081,005 BUTTON oOk  PROMPT OemToAnsi(STR0068) OF oDlgPerg SIZE 43,11 PIXEL ACTION (nOpca_ := 1,oDlgPerg:End()) //Confirma
		@ 081,048 BUTTON oNo  PROMPT OemToAnsi(STR0069)  OF oDlgPerg SIZE 43,11 PIXEL ACTION (nOpca_ := 2,oDlgPerg:End()) //Cancela
		
		oOk:SetFocus()
		
		ACTIVATE MSDIALOG oDlgPerg CENTER
		
		if nOpca_ != 1
			Return( .f. )
		Endif
		
		if nCkPerg1 == 1
			M->VVF_FORPRO := "1" // Sim
			If FM_NRNFFP(1) // 1a Chamada da tela que verifica NF quando Formulario Proprio
				return .f.
			Endif
			If FM_NRNFFP(2) // 2a Chamada da tela que verifica NF quando Formulario Proprio
				return .f.
			Endif
			cNumNota := cNota
			if cNumNota == NIL
//				lNF := Sx5NumNota(cSerie, Nil, GetNewPar("MV_TPNRNFS","1"))
				lNF := Sx5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))
				if lNF
					cSerNota := cSerie
					cNumNota := cNumero
					cNota    := cNumero
				endif		
			endif
		Else
			if !Empty(cNumNota)
				M->VVF_FORPRO := "0" // Nao
				cNota  := cNumNota
				cSerie := cSerNota
			Else
				MsgInfo(STR0070 ,STR0009)//Informe a numeracao da NF... - Atencao
				Return( .f. )
			Endif
		Endif
		
		// Executa a Devolucao do Veiculo
		Processa( {|| INTDEV() } )
		
		// Ponto de Entrada Depois da Gravacao da Nota Fiscal
		If ExistBlock("VM005DNF")
			ExecBlock("VM005DNF",.f.,.f.)
		EndIf
		
		
	Case nOpc == 4  // Devolucao
		
		if !Empty(VV0->VV0_TRADEV)
			// Posicionar no VVF
			DbSelectArea("VVF")
			DbSetOrder(1)
			DbSeek(xFilial("VVF")+VV0->VV0_TRADEV)
			
			DbSelectArea("VVA")
			DbSetOrder(1)
			DbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
			
			dbSelectArea("VV1")
			dbSetOrder(1)
			if dbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
				if VV1->VV1_SITVEI == "1"
					MsgInfo(STR0071 ,STR0009)//Este Veiculo encontra-se vendido, esta operacao nao podera ser concluida... - Atencao
					Return (.f.)
				Endif
			Endif
			
			Processa({|| FS_CANDEVSAI() })
			
			// Ponto de Entrada Depois do Cancelamento da Nota Fiscal
			If ExistBlock("VM005CNF")
				ExecBlock("VM005CNF",.f.,.f.)
			EndIf
			
		Else
			MsgInfo(STR0072 ,STR0009)//Nota Fiscal nao foi Devolvida... - Atencao
		Endif
		
EndCase

Return( .t. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |FS_CANDEVSAI³ Autor ³Andre                ³ Data ³ 28/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cancela devolucao de saida                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CANDEVSAI()
lMsErroAuto := .f.                                  
if MsgYesNo(STR0073 +" "+VVF->VVF_NUMNFI+" "+ STR0074 +" "+VVF->VVF_SERNFI+" ?",STR0075) //Confirma Cancelamento da NF de Devolucao nro - Serie - Ok!
	FS_CANCENT()
	if !lMsErroAuto
		Begin Transaction
		DbSelectArea("VV0")
		DbSetOrder(1)
		if DbSeek(xFilial("VV0")+cNTran)
			RecLock("VV0",.f.)
			VV0->VV0_SITNFI := "1" // Normal
			VV0->VV0_DATUSU := Dtos(dDataBase)+"-"+__cUserID
			VV0->VV0_TRADEV := ""
			MsUnlock()
		Endif
		End Transaction
	endif
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VALTES ³ Autor ³  Andre                ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao do TES digitado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALTES(cTes)

Local lRet := .t.

if Val(cTes) > 500
	lRet := .f.
Endif

if SF4->(DbSeek(xFilial("SF4")+cTes))
	if lRet
		cDesTes := SF4->F4_TEXTO
		oDesTes:Refresh()
	Else
		MsgInfo(OemtoAnsi(STR0024),OemtoAnsi(STR0009))
	Endif
Else
	lRet := .f.
Endif

cEstoque := SF4->F4_ESTOQUE
nRecSF4  := SF4->(recno())

SF4->(DbSeek(xFilial("SF4")+VVA->VVA_CODTES))
If cEstoque == "S" .and. SF4->F4_ESTOQUE == "N"
	MsgInfo(STR0076 ,STR0009)//A SAIDA deste veiculo utilizou TES que NAO MOVIMENTA ESTOQUE! Nao pode ser devolvido com TES que MOVIMENTA ESTOQUE! - Atencao
	lRet := .f.
ElseIf cEstoque == "N" .and. SF4->F4_ESTOQUE == "S"
	MsgInfo(STR0077 ,STR0009)//A SAIDA deste veiculo utilizou TES que MOVIMENTA ESTOQUE! Nao pode ser devolvido com TES que NAO MOVIMENTA ESTOQUE! - Atencao
	lRet := .f.
Endif

SF4->(DbGoTo(nRecSF4))

Return (lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ INTDEV   ³ Autor ³ Andre                 ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de Entrada de Veiculos (por Devolucao)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function INTDEV(cAlias,nReg,nOpc)
Local _ni := 0
Local lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)

lstatus:=.f.
ProcRegua(3)
IncProc(OemtoAnsi(STR0078))   //Gerando Nota Fiscal de Devolucao...

Begin Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do VV1                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbselectArea("VV1")
DbsetOrder(1)
DbSeek(xFilial("VV1")+VVA->VVA_CHAINT)

DbSelectArea("SF2")
DbSetOrder(1)
DbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
//
DbSelectArea("SD2")
DbSetOrder(3)
DbSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
//

if VV1->VV1_ESTVEI == "0" //Veiculo Novo
	cAlmVei := GetMv("MV_LOCVEIN")
Else
	cAlmVei := GetMv("MV_LOCVEIU")
Endif

DbSelectArea("SF4")
DbSetOrder(1)
DbSeek(xFilial("SF4")+cCodTes)
DbSelectArea("VV1")
RecLock("VV1",.f.)
if SF4->F4_ESTOQUE == "S"
	VV1->VV1_SITVEI := "0"  // Em Estoque
Else
	VV1->VV1_SITVEI := " "  // Manoel - 21/02/2005 - Quando Tes nao movimentar ESTOQUE
Endif

VV1->VV1_PROATU := VV1->VV1_PROANT
VV1->VV1_LJPATU := VV1->VV1_LJPANT
VV1->VV1_PROANT := ""
VV1->VV1_LJPANT := ""
VV1->VV1_RESERV := ""

FG_Seek("SA1","SM0->M0_CGC",3,.f.)
cConces := SA1->A1_COD
FG_Seek("VE4","VV1->VV1_CODMAR")
cCodFab := VE4->VE4_CODFAB+VE4->VE4_LOJA
FG_Seek("SA1","cCodFab",1,.f.)
cNomFab := SA1->A1_NREDUZ
VV1->VV1_NOMANT := SA1->A1_NOME
VV1->VV1_ENDANT := SA1->A1_END
If lA1_IBGE
	VAM->(DbSetOrder(1))
	VAM->(Dbseek(xFilial("VAM")+SA1->A1_IBGE))
	VV1->VV1_CIDANT := VAM->VAM_DESCID
	VV1->VV1_ESTANT := VAM->VAM_ESTADO
Else
	VV1->VV1_CIDANT := SA1->A1_MUN
	VV1->VV1_ESTANT := SA1->A1_EST
EndIf
VV1->VV1_CEPANT := SA1->A1_CEP
VV1->VV1_DOCIND := SA1->A1_CGC
VV1->VV1_LOCPAD := cAlmVei
MsUnlock()

// Controle de status de veiculos
If lStatus
	FG_STATUS(VV1->VV1_CHAINT,"E")
Endif

cAlmVei := VV1->VV1_LOCPAD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do VVF                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M->VVF_TRACPA := GetSxENum("VVF","VVF_TRACPA")

//luis

cCodFor := VV0->VV0_CODCLI
cLoja   := VV0->VV0_LOJA

If !MaFisFound('NF')
	If !Empty(cLoja)
		MaFisIni(cCodFor,cLoja,'C','D',NIL,MaFisRelImp("VEIVM015",{"SF1","SD1"}))
	EndIf
EndIf

n:=1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SD1")
aHeader:={}
While !Eof().And.(x3_arquivo=="VVG")
	if ( X3USO(x3_usado).And.cNivel>=x3_nivel )
		nUsado:=nUsado+1
		aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	&("M->"+x3_campo) := CriaVar(x3_campo)
	DbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Arquivo de Produtos < SB1 >                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbselectArea("SB1")
DbSetOrder(7)
DbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aCols da GetDados                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols:={Array(nUsado+1)}
aCols[1,nUsado+1]:=.F.
For _ni:=1 to nUsado
	aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
Next

//MaFisRef("IT_PRODUTO","VVG00",VV1->VV1_CHAINT)
MaFisRef("IT_PRODUTO","VVG00",SB1->B1_COD)
MaFisRef("IT_TES","VVG00",cCodTes)
MaFisRef("IT_SERORI","VVG00",SD2->D2_SERIE)
MaFisRef("IT_NFORI","VVG00",SD2->D2_DOC)
MaFisRef("IT_VALMERC","VVG00",SD2->D2_PRCVEN)

// MaFisLoad("IT_RECORI",SD2->(RecNo()),1)


// Manoel - 29/Set/2004 - Aliq. de Icm da nota de Origem e' o correto
//MaFisRef("IT_ALIQICM","VVG00",VVA->VVA_ALIICM)

nBaseIcm := MaFisRet(1,"IT_BASEICM")
nAliqIcm := MaFisRet(1,"IT_ALIQICM")
nValoIcm	:= MaFisRet(1,"IT_VALICM")

nBaseIpi := MaFisRet(1,"IT_BASEIPI")
nAliqIpi := MaFisRet(1,"IT_ALIQIPI")
nValoIpi	:= MaFisRet(1,"IT_VALIPI")

nBaseST := MaFisRet(1,"IT_BASESOL")
nValoST := MaFisRet(1,"IT_VALSOL")

dDataTmp := dDataBase
if M->VVF_FORPRO == "0" // Nao
	dDataTmp := dDatemi
Endif

cCondVei1 := RetCondVei()
 



//Calculo do Custo do Veiculo
FG_Seek("VV1","VVA->VVA_CHAINT",1,.f.)
// Manoel - 15/03/2010 - possibilitar a continuidade do processo qdo nao houver NF de Entrada no nosso Modulo 
// Isso se da nos casos de implantacao onde foi necessario criar estoque (SB2) mas nao foi criado VVF e VVG
//if !FG_Seek("VVG","VVA->VVA_CHAINT",2,.f.)
//	MsgInfo(STR0079 ,STR0009)//Chassi nao possui nota de entrada relacionada - Atencao
//	DisarmTransaction()
//	Break
//Endif
if !FG_Seek("VVG","VVA->VVA_CHAINT",2,.f.)
	DbselectArea("SB1")
	DbSetOrder(7)
	DbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
	DbselectArea("SB2")
	DbSetOrder(1)
	If DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
		nCusVei := SB2->B2_CM1
	Else
		MsgInfo(STR0079 ,STR0009)//Chassi nao possui nota de entrada relacionada - Atencao
		DisarmTransaction()
		Break
	Endif
	
Else
	cTraCpa := VVG->VVG_TRACPA
	While !Eof() .and. VVG->VVG_CHAINT == VV1->VV1_CHAINT .and. VVG->VVG_FILIAL == xFilial("VVG")
		cTraCpa := VVG->VVG_TRACPA
		dbSelectArea("VVG")
		dbSkip()
	Enddo
	FG_Seek("VVG","cTraCpa+VVA->VVA_CHAINT",1,.f.)
	
	FG_Seek("VE4","VV1->VV1_CODMAR")
	FG_Seek("VVH","VVG->VVG_CODIND",1,.f.)
	
	//Posiciona no VVF Original
	FG_Seek("VVF","VVG->VVG_TRACPA",1,.f.)
	nVTotDsp    := (VVF->VVF_TOTSEG + VVF->VVF_TOTFRE + VVF->VVF_DESACE) / VVF->VVF_QTDVEI
	
	DbSelectArea("VVG")
	nCusVei := 0
	if VVG->VVG_ESTVEI == "0" //Novo
		If !Empty(VV2->VV2_FORCUS)       //Modelo do Veiculo
			nCusVei := FG_FORMULA(VV2->VV2_FORCUS)
		ElseIf !Empty(VE4->VE4_FORCTB)   //Parametros da Montadora do Custo Contabil
			nCusVei := FG_FORMULA(VE4->VE4_FORCTB)
		Endif
	Else
		cFor := GetMv("MV_VUCCTB")
		if !Empty(cFor)
			nCusVei := FG_FORMULA(cFor)
		Endif
	Endif
	if nCusVei <= 0
		nCusVei := VVG->VVG_VCNVEI
	Endif
	
	nCusVei := nCusVei+VVG->VVG_VALFRE
	
Endif
//Volta p/ o VVF atual
//FG_Seek("VVF","cTraCpa",1,.f.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Arquivo de Produtos < SB1 >                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))

dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
dbSetOrder(1)

IncProc(OemtoAnsi(STR0078 )) //Gerando Nota Fiscal de Devolucao...

// Cria Vetor de Itens para o MATA100 (Nota Fiscal de Entrada)
aIteTempNFE := {}
aCabNfe     := {}

aAdd(aIteTempNFE,{"D1_ITEM"    ,"01",Nil})
aAdd(aIteTempNFE,{"D1_NFORI"   ,SD2->D2_DOC,Nil})
aAdd(aIteTempNFE,{"D1_SERIORI" ,SD2->D2_SERIE,Nil})
//aAdd(aIteTempNFE,{"D1_ITEMORI" ,SD2->D2_ITEM,Nil}) // Retirado quando devolucao de VEICULO, pois o aCols no MATA103 estava preenchendo errado com isso nao validava a saida corretamente.
aAdd(aIteTempNFE,{"D1_COD"     ,SD2->D2_COD,Nil})
aAdd(aIteTempNFE,{"D1_UM"      ,"UN",Nil})
aAdd(aIteTempNFE,{"D1_QUANT"   ,1,Nil})
aAdd(aIteTempNFE,{"D1_VUNIT"   ,SD2->D2_PRCVEN,Nil})
aAdd(aIteTempNFE,{"D1_TOTAL"   ,SD2->D2_TOTAL,Nil})
aAdd(aIteTempNFE,{"D1_VALIPI"  ,SD2->D2_VALIPI,Nil})
aAdd(aIteTempNFE,{"D1_VALICM"  ,SD2->D2_VALICM,Nil})
aAdd(aIteTempNFE,{"D1_BASEIPI" ,SD2->D2_BASEIPI,Nil})
aAdd(aIteTempNFE,{"D1_BASEICM" ,SD2->D2_BASEICM,Nil})
aAdd(aIteTempNFE,{"D1_CUSTO"   ,nCusVei,Nil})
aAdd(aIteTempNFE,{"D1_TES"     ,cCodTes,Nil})
aAdd(aIteTempNFE,{"D1_CF"      ,SF4->F4_CF,Nil})
aAdd(aIteTempNFE,{"D1_CC"      ,cCenCus,Nil})
aAdd(aIteTempNFE,{"D1_LOCAL"   ,cAlmVei,Nil})
//aAdd(aIteTempNFE,{"D1_LOCPAD"  ,cAlmVei,Nil})
aAdd(aIteTempNFE,{"D1_EMISSAO" ,dDataTmp,Nil})
aAdd(aIteTempNFE,{"D1_DTDIGIT" ,dDataBase,Nil})
aAdd(aIteTempNFE,{"D1_BRICMS" ,SD2->D2_BRICMS,Nil})
aAdd(aIteTempNFE,{"D1_ICMSRET" ,SD2->D2_ICMSRET,Nil})


cTipoN := "D" // Devolucao

if M->VVF_FORPRO == "0" // Formulario Proprio = Nao
	cFormul := "N"
Else
	cFormul := "S"
Endif

//if M->VVF_FORPRO == "1" //Formulario Proprio = Sim
//	cNota := ""
//Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rubens - 17/03/2010                                  ³
//³Gravar o VVF_ESPECI se o usuario nao especificar nada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if VVF->(FieldPos("VVF_ESPECI")) <> 0 
	if Empty(M->VVF_ESPECI)
		M->VVF_ESPECI := GetNewPar("MV_ESPECNF","NF")
	endif
else
	M->VVF_ESPECI := GetNewPar("MV_ESPECNF","NF")
endif

SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA))

aAdd(aCabNFE,{"F1_TIPO"    ,cTipoN         ,Nil})
aAdd(aCabNFE,{"F1_ESPECIE" ,M->VVF_ESPECI  ,Nil})
//aAdd(aCabNFE,{"F1_ESPECIE" ,GetNewPar("MV_ESPECNF","NF"),Nil})
//aAdd(aCabNFE,{"F1_ESPECIE" ,"NF"           ,Nil})
aAdd(aCabNFE,{"F1_FORMUL"  ,cFormul        ,Nil})
aAdd(aCabNFE,{"F1_DOC"     ,cNota,Nil})
aAdd(aCabNFE,{"F1_SERIE"   ,cSerie,Nil})
aAdd(aCabNFE,{"F1_EMISSAO" ,dDataTmp,Nil})
aAdd(aCabNFE,{"F1_DTDIGIT" ,dDataBase,Nil})
aAdd(aCabNFE,{"F1_RECBMTO" ,dDataBase,Nil})
aAdd(aCabNFE,{"F1_FORNECE" ,cCodDes        ,Nil})
aAdd(aCabNFE,{"F1_LOJA   " ,cLojDes        ,Nil})
aAdd(aCabNFE,{"F1_COND"    ,cCondVei1,Nil})
aAdd(aCabNFE,{"F1_VALMERC" ,SF2->F2_VALMERC,Nil})
aAdd(aCabNFE,{"F1_VALBRUT" ,SF2->F2_VALBRUT,Nil})
aAdd(aCabNFE,{"F1_BRICMS"  ,SF2->F2_BRICMS,Nil})
aAdd(aCabNFE,{"F1_ICMSRET" ,SF2->F2_ICMSRET,Nil})
aAdd(aCabNFE,{"F1_EST"     ,SA1->A1_EST    ,Nil})

//Chamada do MATA103 (Nota Fiscal de Entrada)
lMsHelpAuto := .t.
lMsErroAuto := .f.

lInclui := inclui
inclui  := .t.
nAnt    := MAFISSAVE()
MAFISEND()
MSExecAuto({|x,y| MATA103(x,y)},aCabNFE,{aIteTempNFE},3)
MAFISRESTORE(nAnt)
inclui := lInclui

cNota := SF1->F1_DOC
//if cNota <> SF1->F1_DOC .or. SF1->F1_SERIE <> cSerie
//	MsgInfo("Violacao na aquisicao do numero da NF.","Atencao")
//	DisarmTransaction()
//	Break
//Endif
//MsgInfo("NF :" + SF1->F1_DOC,"Atencao")
//DisarmTransaction()
//break

if lMsErroAuto
	DisarmTransaction()
	Break
Endif

DBSelectARea("SF1")
reclock("SF1",.f.)
SF1->F1_TIPO := "D"
msunlock()
DBSelectARea("SD1")
reclock("SD1",.f.)
SD1->D1_TIPO := "D"
msunlock()

//      
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+SD1->D1_COD)
//
FM_LOCVZL(1)
//

DbSelectArea("VVF")
RecLock("VVF",.t.)
cTraCpa := GetSxENum("VVF","VVF_TRACPA")
FG_GRAVAR("VVF")
VVF->VVF_FILIAL := xFilial("VVF")
VVF->VVF_TRACPA := cTraCpa
VVF->VVF_SITNFI := "1"       // Nota Fiscal de Devolucao Valida
VVF->VVF_NUMPED := ""
VVF->VVF_OPEMOV := cOpeMov   // Devolucao
VVF->VVF_QTDVEI := 1
VVF->VVF_DTHEMI := Dtoc(dDataBase) + [/] + Time()
VVF->VVF_NUMTRA := VV0->VV0_NUMTRA
VVF->VVF_FORPRO := M->VVF_FORPRO
VVF->VVF_DATMOV := dDataBase
VVF->VVF_DATFAB := dDataTmp
VVF->VVF_DATEMI := dDataTmp
VVF->VVF_CODFOR := VV0->VV0_CODCLI
VVF->VVF_LOJA   := VV0->VV0_LOJA
VVF->VVF_NUMNFI := SF1->F1_DOC
VVF->VVF_SERNFI := SF1->F1_SERIE
VVF->VVF_FORPAG := cCondVei1
VVF->VVF_VALMOV := VV0->VV0_VALMOV
VVF->VVF_QTDVEI := 1
VVF->VVF_DTHEMI := Dtoc(dDataBase) + [/] + Time()
VVF->VVF_NUMTRA := VV0->VV0_NUMTRA
VVF->VVF_CONFRE := 0
VVF->VVF_TOTSEG := 0
VVF->VVF_TOTFRE := 0
VVF->VVF_ICMRET := 0
//ICM
VVF->VVF_VBAICM := SF2->F2_BASEICM
VVF->VVF_ALIICM := SD2->D2_PICM  // <<---Luis: Muito errado. Campo desnecessario
VVF->VVF_TOTICM := SF2->F2_VALICM
//IPI
VVF->VVF_VBAIPI := SF2->F2_BASEIPI
VVF->VVF_ALIIPI := SD2->D2_IPI  // <<---Luis: Muito errado. Campo desnecessario
VVF->VVF_VALIPI := SF2->F2_VALIPI
MSMM(,TamSx3("VVF_OBSERV")[1],,cObserv,1,,,"VVF","VVF_OBSMEM")
ConfirmSx8("VVF")
MsUnlock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do VVG                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbselectArea("VVG")
RecLock("VVG",.t.)
VVG->VVG_FILIAL := xFilial("VVG")
VVG->VVG_TRACPA := VVF->VVF_TRACPA
VVG->VVG_CHAINT := VV1->VV1_CHAINT
VVG->VVG_CHASSI := VV1->VV1_CHASSI
VVG->VVG_CODTES := cCodTes
VVG->VVG_VCNVEI := nCusVei
VVG->VVG_CENCUS := cCenCus
VVG->VVG_REDCUS := VVA->VVA_REDCUS
VVG->VVG_SEGVIA := VVA->VVA_SEGVIA
VVG->VVG_VALASS := VVA->VVA_VALASS
VVG->VVG_VALREV := VVA->VVA_VALREV
VVG->VVG_VALFRE := 0
VVG->VVG_ASSIMP := VVA->VVA_ASSIMP
VVG->VVG_ESTVEI := VVA->VVA_ESTVEI
VVG->VVG_CODIND := VVA->VVA_CODIND
VVG->VVG_CODORI := VVA->VVA_CODORI
VVG->VVG_VALUNI := VVA->VVA_VALMOV
VVG->VVG_LOCPAD := cAlmVei
VVG->VVG_SITTRI := SB1->B1_ORIGEM
//ICM
VVG->VVG_VBAICM := SD2->D2_BASEICM
VVG->VVG_ALIICM := SD2->D2_PICM
VVG->VVG_ICMCOM := SD2->D2_VALICM
//IPI
VVG->VVG_VBAIPI := SD2->D2_BASEIPI
VVG->VVG_ALIIPI := SD2->D2_IPI
VVG->VVG_VALIPI := SD2->D2_VALIPI
MsUnlock()

dbSelectarea("SF1")
dbSetOrder(1)
RecLock("SF1",.f.)
SF1->F1_VALMERC := SF2->F2_VALMERC
SF1->F1_VALBRUT := SF2->F2_VALBRUT
MsUnlock()

dbSelectarea("SD1")
dbSetOrder(1)
if DbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI)
	RecLock("SD1",.f.)
	SD1->D1_CC := cCenCus
	MsUnlock()
Endif

DbSelectArea("SE1")
DbSetOrder(1)
reclock("SE1",.f.)
	E1_VENCTO := ddatabase
	E1_VENCREA := ddatabase
msunlock()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do VV0                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Marca Nota de Saida como devolvida
dbSelectArea("VV0")
RecLock("VV0",.f.)
VV0->VV0_SITNFI := "2"  //Devolvida
VV0->VV0_DATUSU := Dtos(dDataBase)+"-"+__cUserID
VV0->VV0_TRADEV := VVF->VVF_TRACPA
MsUnlock()

End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
MsRUnLock()

// Atualiza Ultima Movimentacao do Veiculo e Proprietario Atual
FGX_AMOVVEI(xFilial("VV1"),VV1->VV1_CHASSI)

if !lMsErroAuto
	if VVF->VVF_FORPRO == "1" // Formulario Proprio
		if ExistBlock("NFENTVEI")
			IncProc(OemtoAnsi(STR0080))//Imprimindo Nota Fiscal...
			ExecBlock("NFENTVEI",.f.,.f.,{VVF->VVF_NUMNFI,VVF->VVF_SERNFI,VVF->VVF_CODFOR,VVF->VVF_LOJA})
		Endif
	Endif
Else
	MostraErro()
Endif

Return( .t. )


//////////////////////////////
Static Function FS_VALCLI(nOp)

Local lRet := .t.

DbSelectArea("SA1")
DbSetOrder(1)
if nOp == 1
	if DbSeek(xFilial("SA1")+cCodDes)
		cNomDes := SA1->A1_NOME
	Else
		MsgInfo(STR0081,STR0009)//Destinatario nao Cadastrado... - Atencao
		lRet := .f.
	Endif
Else
	if DbSeek(xFilial("SA1")+cCodDes+cLojDes)
		cNomDes := SA1->A1_NOME
	Else
		MsgInfo(STR0081,STR0009)//Destinatario nao Cadastrado... - Atencao
		lRet := .f.
	Endif
Endif


Return(lRet)

Function FS_VALCC()
Local lRet := .t.

if !Empty(cCenCus)
   if (CTT->(dbseek( xFilial("CTT")+cCenCus)))
	  (cDesCC := CTT->CTT_DESC01)
      lRet := .t.
   Else  
	  lRet := .f.
   Endif   
Else
   lRet := .t.
Endif	   
//if lRet
//	(cDesCC := CTT->CTT_DESC01)
//Endif

Return(lRet)


// Funcao para o top do filtro da mbrowse
Function vm005Top()
Return (xFilial('VV0')+'0')

// Funcao para o bottom do filtro da mbrowse
Function vm005Bottom()
Return (xFilial('VV0')+'2')

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VM005LEG   ³ Autor ³ Ricardo Farinelli    ³ Data ³ 11/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³VEIVM005                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM005LEG()
Local aLegenda := 	{{'BR_VERDE'		,STR0082},; //Disponivel para Devolver
					 {'BR_VERMELHO'		,STR0083}} //Ja Devolvida

BrwLegenda(cCadastro,STR0084 ,aLegenda) //Legenda

Return .T.

Static Function MenuDef()
Local aRotina := {{ OemtoAnsi(STR0003),"axPesqui", 0 , 1},;   // Pesquisar
{ OemtoAnsi(STR0001),"DEVVEI", 0 , 2},;   		// Vizualizar
{ OemtoAnsi(STR0023),"DEVVEI", 0 , 4},;   		// Devolucao
{ OemtoAnsi(STR0004),"DEVVEI", 0 , 4},;  		// Cancelar
{ OemtoAnsi(STR0084),"VM005LEG", 0 , 2},;  	// Legenda
{ 			STR0085 ,"VM005_LVEI" , 0 , 2}}   //Pesquisa Chassi
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM005_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 08/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM005_LVEI()
Local nOpca := 0
Local nEmpAtu := SM0->(RecNo())
Local cEmpAtu := SM0->M0_CODIGO
Private aEmpAtu  := {}
Private aLevPesq := {{"","","",ctod(""),"",0,""}}
Private cLevChas := left(space(50),len(VV1->VV1_CHASSI))
Private overd := LoadBitmap( GetResources() , "BR_VERDE" )
Private overm := LoadBitmap( GetResources() , "BR_VERMELHO" )
DbSelectArea("SM0")
DbGoTop()
Do While !Eof()
	if SM0->M0_CODIGO == cEmpAtu
		aAdd( aEmpAtu , { SM0->M0_CODFIL , SM0->M0_FILIAL } )
	EndIf
	DbSkip()
EndDo
DbSelectArea("SM0")
DbGoTo(nEmpAtu)
DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0086) FROM  01,05 TO 17,70 OF oMainWnd  //Pesquisa Chassi
@ 003,004 SAY STR0087 SIZE 80,7 OF oLevPesq PIXEL COLOR CLR_BLUE //Veiculo:
@ 002,025 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
@ 002,212 BUTTON oNo PROMPT OemToAnsi(STR0088) OF oLevPesq SIZE 43,11 PIXEL ACTION (nOpca := 0, oLevPesq:End()) //SAIR
@ 015,002 LISTBOX oLbLevPesq FIELDS HEADER OemToAnsi(""),;
OemToAnsi(STR0089),; 	//Filial
OemToAnsi(STR0090),;	//Dt.Movimento
OemToAnsi(STR0091),; 	//NF/Serie
OemToAnsi(STR0092),;	//Vlr Venda
OemToAnsi(STR0057);		//Cliente
COLSIZES 10,35,35,25,40,150 SIZE 253,104 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]<>"2",oVerd,oVerm),;
aLevPesq[oLbLevPesq:nAt,03],;
Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
aLevPesq[oLbLevPesq:nAt,05],;
FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
aLevPesq[oLbLevPesq:nAt,07] }}
ACTIVATE MSDIALOG oLevPesq CENTER
dbSelectArea("VV0")
if nOpca > 0 .and. Len(aLevPesq) >= nOpca
	//posiciona no registro
	dbSetOrder(1)//NUMTRA
	DbSeek(left(aLevPesq[nOpca,3],2)+ aLevPesq[nOpca,1])
endif
Return

Static Function FS_LEVVEI()
Local cEmpAtu := ""
Local nEmpAtu := 0
Local lOk := .t.
Local cQuery := ""
Local cQAlVV0 := "SQLVV0"
Local cFilLibs := ""
Local nNUMPED := len(VV0->VV0_NUMPED)
Local nNUMNFI := len(VV0->VV0_NUMNFI)
If !Empty(cLevChas)
	aLevPesq := {}
	cQuery := "SELECT VV0.VV0_NUMTRA , VV0.VV0_SITNFI , VV0.VV0_FILIAL , VV0.VV0_DATMOV , VV0.VV0_VALMOV , VV0.VV0_CODCLI , VV0.VV0_LOJA , VV0.VV0_NUMNFI , VV0.VV0_SERNFI FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VVA")+" VVA WHERE "
	cQuery += "VVA.VVA_CHASSI='"+cLevChas+"' AND VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND "
	cFilLibs := FG_FilLib(2) // retorna apenas filiais que o usuario pode acessar
	If len(cFilLibs) > 1
		cQuery += "VV0.VV0_FILIAL IN ("
		While len(cFilLibs) > 1
			If SM0->M0_CODIGO == left(cFilLibs,2)
				cQuery += "'"+substr(cFilLibs,3,2)+"',"
			EndIf
			cFilLibs := substr(cFilLibs,6)
		EndDo
		cQuery := left(Alltrim(cQuery),len(Alltrim(cQuery))-1)+") AND "
	EndIf
	if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S"
		cQuery += "VV0.VV0_NUMPED<>'"+ space(nNUMPED)+ "' AND "
	endif
	cQuery += "VV0.VV0_SITNFI IN ('1','2') AND VV0.VV0_NUMNFI<>'"+ space(nNUMNFI)+"' AND VV0.VV0_TIPFAT<>'2' AND VV0.VV0_OPEMOV='0' AND VV0.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' ' ORDER BY VV0.VV0_DATMOV "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0, .F., .T. )
	Do While !( cQAlVV0 )->( Eof() )
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + ( cQAlVV0 )->( VV0_CODCLI ) + ( cQAlVV0 )->( VV0_LOJA ) )
		cEmpAtu := ""
		nEmpAtu := Ascan(aEmpAtu,{|x| x[1] == ( cQAlVV0 )->( VV0_FILIAL ) })
		If nEmpAtu > 0
			cEmpAtu := left(aEmpAtu[nEmpAtu,2],15)
		EndIf
		aAdd(aLevPesq,{ ( cQAlVV0 )->( VV0_NUMTRA ) , ( cQAlVV0 )->( VV0_SITNFI ) , ( cQAlVV0 )->( VV0_FILIAL )+"-"+cEmpAtu , stod(( cQAlVV0 )->( VV0_DATMOV )) , ( cQAlVV0 )->( VV0_NUMNFI )+"-"+( cQAlVV0 )->( VV0_SERNFI ) , ( cQAlVV0 )->( VV0_VALMOV ) , ( cQAlVV0 )->( VV0_CODCLI )+"-"+( cQAlVV0 )->( VV0_LOJA )+" "+SA1->A1_NOME })
		( cQAlVV0 )->( DbSkip() )
	EndDo
	( cQAlVV0 )->( dbCloseArea() )
	If len(aLevPesq) <= 0
		MsgAlert(STR0093 +" "+cLevChas,STR0009)//Nenhuma NF Venda encontrada para o Chassi - Atencao
		aLevPesq := {{"","","",ctod(""),"",0,""}}
		lOk := .f.
	EndIf
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]<>"2",oVerd,oVerm),;
	aLevPesq[oLbLevPesq:nAt,03],;
	Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
	aLevPesq[oLbLevPesq:nAt,05],;
	FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
	aLevPesq[oLbLevPesq:nAt,07] }}
	oLbLevPesq:SetFocus()
	oLbLevPesq:Refresh()
	If !lOk
		oLevChas:SetFocus()
	EndIf
EndIf
Return
