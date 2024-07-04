// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 20     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEICC600.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  08/01/2018
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006574_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³VEICC600³ Autor ³ Andre Luis Almeida       ³ Data ³ 10/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Geracao das Listas de Contato para Agendamento(Oficina/CEV) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Oficina/CEV                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICC600()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
////////////////////////////////////////////////////////////////////////////////////////////
Local nTam := 0
Private overde   := LoadBitmap( GetResources(), "BR_verde")
Private overmelho:= LoadBitmap( GetResources(), "BR_vermelho")
Private dDtIni := (dDataBase-day(dDataBase))+1
Private dDtFin := dDataBase
Private dDCIni := ctod("")
Private dDCFin := dDataBase
Private aTipCS := {STR0001 ,STR0002} // Com / Sem
Private cTipCS := STR0001 // Com
Private aTipVP := {STR0003,STR0004} // Venda de / Passagem
Private cTipVP := STR0003 // Venda de
Private aPrefV := {STR0005,STR0006,STR0007} // Balcao / Oficina / Veiculos
Private cPrefV := STR0005 // Balcao
Private aPrefP := {STR0008} // na Oficina
Private cPrefP := STR0008 // na Oficina
Private aConsV := {STR0009,STR0010,STR0011} // Ultima Venda / Primeira Venda / Todas Vendas
Private cConsV := STR0009 // Ultima Venda
Private aConsP := {STR0012,STR0013,STR0014} // Ultima Passagem / Primeira Passagem / Todas Passagens
Private cConsP := STR0012 // Ultima Passagem
Private nVlIni := 0
Private nVlFin := 9999999999.99
Private lVlIni := .t.
Private lVlFin := .t.
Private aVeic  := {STR0015,STR0016,STR0017} // Todos Veiculos / Veiculos Novos / Veiculos Usados
Private cVeic  := STR0015 // Todos Veiculos
Private nCkRad1:= 1
Private aGrp   := {}
Private aMod   := {}
Private cMarca := space(3)
Private lMarcarV := .t.
Private cChaIni:= space(25)
Private cChaFin:= space(25)
Private cAnoIni:= space(8)
Private cAnoFin:= space(8)
Private dDEntI := ctod("")
Private dDEntF := dDataBase
Private cTpVda := " "
Private aTpVda := {}
Private cTpTmp := " "
Private aTpTmp := {}
Private cVend  := space(6)
Private lVend  := .t.
Private lPec   := .t.
Private lSrv   := .t.
Private cGrpPec:= space(4)
Private cCodPec:= space(27)
Private Get_GRUPO:= cGrpPec
Private cCodSrv  := space(15)
Private cTitulo  := ""
Private lA1_IBGE := ( SA1->(FieldPos("A1_IBGE")) > 0 )
Private lDatCad  := ( VCF->(FieldPos("VCF_DATCAD")) > 0 )
Private ctit1 := STR0030 // Veiculos:
Private cTit2 := STR0029 // Considerar:
Private cTit3 := STR0031 // Selecionar Marca:
Private cTit4 := STR0037 // Chassi:  de
Private cTit5 := STR0024 // Ate
Private cTit6 := STR0039 // Ano de fab./mod.: de
Private cTit7 := STR0024 // ate
Private cTit8 := STR0041 // Data da entrega do veiculo: de
Private cTit9 := STR0024 // ate
Private cTit10:= STR0042 // Tipo De Venda:
Private cObjSlv := ""
If type("cObjetiv") == "U"
	cObjetiv := ""
EndIf
cObjSlv := cObjetiv
DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("VV0_CATVEN")
cTpVda := X3CBOX()
aAdd(aTpVda,STR0018) // Todos os Tipos
While len(cTpVda) > 1
	nTam := IIf(at(";",cTpVda)==0,len(cTpVda)+1,at(";",cTpVda))
	aAdd(aTpVda,substr(cTpVda,1,1)+"-"+substr(cTpVda,3,nTam-3))
	cTpVda := Alltrim(substr(cTpVda,nTam+1,len(cTpVda)))
EndDo
DbSeek("VOI_SITTPO")
cTpTmp := X3CBOX()
aAdd(aTpTmp,STR0018) // Todos os Tipos
While len(cTpTmp) > 1
	nTam := IIf(at(";",cTpTmp)==0,len(cTpTmp)+1,at(";",cTpTmp))
	aAdd(aTpTmp,substr(cTpTmp,1,1)+"-"+substr(cTpTmp,3,nTam-3))
	cTpTmp := Alltrim(substr(cTpTmp,nTam+1,len(cTpTmp)))
EndDo
FS_TIK(0) // Carrega Grupos e Modelos

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 40 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oAgOFI TITLE STR0019 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL //Geracao das Listas de Contato para Agendamento

@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,1]+019,aPosObj[1,2]+120 LABEL STR0020  OF oAgOFI PIXEL // Periodo
@ aPosObj[1,1]+008,aPosObj[1,2]+008 SAY STR0023  SIZE 25,10 OF oAgOFI PIXEL COLOR CLR_BLUE // De
@ aPosObj[1,1]+007,aPosObj[1,2]+018 MSGET oDtIni VAR dDtIni VALID (!Empty(dDtIni),FS_VAL600("DT1")) PICTURE "@D" SIZE 40,8 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+008,aPosObj[1,2]+061 SAY STR0024  SIZE 25,10 OF oAgOFI PIXEL COLOR CLR_BLUE // ate
@ aPosObj[1,1]+007,aPosObj[1,2]+073 MSGET oDtFin VAR dDtFin VALID(dDtFin>=dDtIni,FS_VAL600("DT1")) PICTURE "@D" SIZE 40,8 OF oAgOFI PIXEL COLOR CLR_BLUE

If lDatCad
	@ aPosObj[1,1],aPosObj[1,2]+122 TO aPosObj[1,1]+019,aPosObj[1,2]+242 LABEL STR0021 OF oAgOFI PIXEL // Data Cadastro no CEV
	@ aPosObj[1,1]+008,aPosObj[1,2]+130 SAY STR0023  SIZE 25,10 OF oAgOFI PIXEL COLOR CLR_BLUE // De
	@ aPosObj[1,1]+007,aPosObj[1,2]+140 MSGET oDCIni VAR dDCIni VALID (FS_VAL600("DT2")) PICTURE "@D" SIZE 40,8 OF oAgOFI PIXEL COLOR CLR_BLUE WHEN ( cTipCS == STR0001 )
	@ aPosObj[1,1]+008,aPosObj[1,2]+183 SAY STR0024  SIZE 25,10 OF oAgOFI PIXEL COLOR CLR_BLUE // ate
	@ aPosObj[1,1]+007,aPosObj[1,2]+195 MSGET oDCFin VAR dDCFin VALID(dDCFin>=dDCIni,FS_VAL600("DT2")) PICTURE "@D" SIZE 40,8 OF oAgOFI PIXEL COLOR CLR_BLUE WHEN ( cTipCS == STR0001 )
EndIf

@ aPosObj[1,1]+019,aPosObj[1,2] TO aPosObj[1,1]+038,aPosObj[1,2]+137 LABEL STR0026  OF oAgOFI PIXEL // Clientes
@ aPosObj[1,1]+025,aPosObj[1,2]+006 MSCOMBOBOX oTipCS VAR cTipCS ITEMS aTipCS VALID (FS_VAL600("TP1")) SIZE 30,08 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+025,aPosObj[1,2]+037 MSCOMBOBOX oTipVP VAR cTipVP ITEMS aTipVP VALID (FS_VAL600("TP1").and.FS_VAL600("TP2")) SIZE 47,08 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+025,aPosObj[1,2]+085 MSCOMBOBOX oPrefV VAR cPrefV ITEMS aPrefV VALID (FS_VAL600("TP1").and.FS_VAL600("PF1" )) SIZE 50,08 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+025,aPosObj[1,2]+085 MSCOMBOBOX oPrefP VAR cPrefP ITEMS aPrefP VALID FS_VAL600("TP1") SIZE 50,08 OF oAgOFI PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+019,aPosObj[1,2]+139 TO aPosObj[1,1]+038,aPosObj[1,2]+274 LABEL STR0027  OF oAgOFI PIXEL // Valores
@ aPosObj[1,1]+026,aPosObj[1,2]+142 SAY STR0023  SIZE 45,10 OF oAgOFI PIXEL COLOR CLR_BLUE // De
@ aPosObj[1,1]+025,aPosObj[1,2]+150 MSGET oVlIni VAR nVlIni VALID (nVlIni>=0) PICTURE "@E 9999,999,999.99" SIZE 55,8 OF oAgOFI PIXEL COLOR CLR_BLUE WHEN lVlIni
@ aPosObj[1,1]+026,aPosObj[1,2]+206 SAY STR0024  SIZE 25,10 OF oAgOFI PIXEL COLOR CLR_BLUE // ate
@ aPosObj[1,1]+025,aPosObj[1,2]+216 MSGET oVlFin VAR nVlFin VALID (nVlFin>=nVlIni) PICTURE "@E 9999,999,999.99" SIZE 55,8 OF oAgOFI PIXEL COLOR CLR_BLUE WHEN lVlFin

@ aPosObj[1,1]+019,aPosObj[1,2]+276 TO aPosObj[1,1]+038,aPosObj[1,2]+330 LABEL STR0028  OF oAgOFI PIXEL // Vendedor
@ aPosObj[1,1]+025,aPosObj[1,2]+280 MSGET oVend VAR cVend PICTURE "@!" F3 "SA3" VALID ( Empty(cVend) .or. FS_POS("SA3") ) SIZE 47,8 OF oAgOFI PIXEL COLOR CLR_BLUE WHEN lVend

@ aPosObj[2,1],aPosObj[2,2] TO aPosObj[2,3],aPosObj[2,4] LABEL "" OF oAgOFI PIXEL
@ aPosObj[2,1]+004,aPosObj[2,2]+006 SAY oTit2 VAR cTit2 SIZE 45,10 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,1]+003,aPosObj[2,2]+037 MSCOMBOBOX oConsV VAR cConsV ITEMS aConsV SIZE 098,08 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,1]+003,aPosObj[2,2]+037 MSCOMBOBOX oConsP VAR cConsP ITEMS aConsP SIZE 098,08 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,1]+016,aPosObj[2,2]+006 SAY oTit1 VAR ctit1 SIZE 45,10 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,1]+003,aPosObj[2,2]+139 MSCOMBOBOX oVeic VAR cVeic ITEMS aVeic SIZE 066,08 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,1]+003,aPosObj[2,2]+139 MSCOMBOBOX oTpTmp VAR cTpTmp ITEMS aTpTmp SIZE 066,08 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,1]+004,aPosObj[2,2]+206 SAY oTit3 VAR cTit3 SIZE 55,10 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,1]+003,aPosObj[2,2]+251 MSGET oMarVE1 VAR cMarca VALID FS_TIK(9) F3 "VE1" PICTURE "@!" SIZE 20,8 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,1]+027,aPosObj[2,2]+005 RADIO oRadio1 VAR nCkRad1 3D SIZE 35,10 PROMPT STR0032,STR0033 OF oAgOFI PIXEL ON CHANGE FS_TIK(nCkRad1) // Grupos / Modelos
@ aPosObj[2,1]+016,aPosObj[2,2]+037 LISTBOX oLbGrp FIELDS HEADER "",STR0034,STR0035,STR0036 COLSIZES 10,25,40,80 SIZE aPosObj[2,4]-44,aPosObj[2,3]-aPosObj[1,3]-054 OF oAgOFI PIXEL ON DBLCLICK FS_TIK(10) // Marca / Grupo / Descricao
oLbGrp:SetArray(aGrp)
oLbGrp:bLine := { || {IIf(aGrp[oLbGrp:nAt,1],overde,overmelho),;
aGrp[oLbGrp:nAt,2] ,;
aGrp[oLbGrp:nAt,3] ,;
aGrp[oLbGrp:nAt,4] }}
@ aPosObj[2,1]+016,aPosObj[2,2]+037 LISTBOX oLbMod FIELDS HEADER "",STR0034,STR0033,STR0036 COLSIZES 10,25,40,80 SIZE aPosObj[2,4]-44,aPosObj[2,3]-aPosObj[1,3]-054 OF oAgOFI PIXEL ON DBLCLICK FS_TIK(20) // Marca / Modelos / Descricao
oLbMod:SetArray(aMod)
oLbMod:bLine := { || {IIf(aMod[oLbMod:nAt,1],overde,overmelho),;
aMod[oLbMod:nAt,2] ,;
aMod[oLbMod:nAt,3] ,;
aMod[oLbMod:nAt,4] }}
@ aPosObj[2,1]+003,aPosObj[2,4]-60 BUTTON oLegenda  PROMPT STR0054 OF oAgOFI SIZE 58,10 PIXEL  ACTION (OM410LEG()) // << Legenda >>
@ aPosObj[2,1]+019,aPosObj[2,2]+038 CHECKBOX oMarcarV VAR lMarcarV PROMPT "" OF oAgOFI ON CLICK IIf( FS_TIKTUDO( lMarcarV ) , .t. , ( lMarcarV:=!lMarcarV , oMarcarV:Refresh() ) ) SIZE 07,05 PIXEL COLOR CLR_BLUE

@ aPosObj[2,3]-030,006 SAY oTit4 VAR cTit4 SIZE 45,10 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-032,037 MSGET oChaIni VAR cChaIni F3 "VV1" PICTURE "@!" SIZE 70,8 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-030,108 SAY oTit5 VAR cTit5  SIZE 25,10 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-032,118 MSGET oChaFin VAR cChaFin F3 "VV1" PICTURE "@!" SIZE 70,8 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-030,194 SAY oTit6 VAR cTit6 SIZE 60,10 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-032,241 MSGET oAnoIni VAR cAnoIni PICTURE "@R 9999/9999" SIZE 33,8 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-030,280 SAY oTit7 VAR cTit7 SIZE 25,10 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-032,290 MSGET oAnoFin VAR cAnoFin PICTURE "@R 9999/9999" SIZE 33,8 OF oAgOFI PIXEL COLOR CLR_BLUE

@ aPosObj[2,3]-015,006 SAY oTit8 VAR cTit8  SIZE 77,10 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-017,083 MSGET oDEntI VAR dDEntI PICTURE "@D" SIZE 40,8 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-015,124 SAY oTit9 VAR cTit9  SIZE 25,10 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-017,134 MSGET oDEntF VAR dDEntF VALID (dDEntF>=dDEntI) PICTURE "@D" SIZE 40,8 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-015,183 SAY oTit10 VAR cTit10 SIZE 45,10 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-017,222 MSCOMBOBOX oTpVda VAR cTpVda ITEMS aTpVda SIZE 105,08 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-015,037 CHECKBOX oPec VAR lPec PROMPT STR0043  ON CLICK FS_POS("PEC") OF oAgOFI SIZE 35,07 PIXEL COLOR CLR_BLUE // Pecas
@ aPosObj[2,3]-017,066 MSGET oGrpPec VAR cGrpPec PICTURE "@!" F3 "BM2" VALID ( Empty(cGrpPec) .or. FS_POS("SBM") ) SIZE 15,8 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-017,100 MSGET oCodPec VAR cCodPec PICTURE "@!" F3 "B11" VALID ( Empty(cCodPec) .or. FS_POS("SB1") ) SIZE 75,8 OF oAgOFI PIXEL COLOR CLR_BLUE
@ aPosObj[2,3]-015,205 CHECKBOX oSrv VAR lSrv PROMPT STR0044  ON CLICK FS_POS("SRV") OF oAgOFI SIZE 35,07 PIXEL COLOR CLR_BLUE // Servicos
@ aPosObj[2,3]-017,241 MSGET oCodSrv VAR cCodSrv PICTURE "@!" F3 "VO7" VALID ( Empty(cCodSrv) .or. FS_POS("VO6") ) SIZE 75,8 OF oAgOFI PIXEL COLOR CLR_BLUE

FS_VISIBLE(.f.)
oPrefP:lVisible := .f.
oConsP:lVisible := .f.

DEFINE SBUTTON FROM aPosObj[1,1]+004,aPosObj[1,4]-60 TYPE 1 ACTION Processa( {|| FS_FILTRA() } ) ENABLE OF oAgOFI PIXEL
DEFINE SBUTTON FROM aPosObj[1,1]+004,aPosObj[1,4]-30 TYPE 2 ACTION oAgOFI:End() ENABLE OF oAgOFI PIXEL

ACTIVATE MSDIALOG oAgOFI
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_POS ³ Autor ³ Andre Luis Almeida       ³ Data ³ 10/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Validacoes / Posicionamento nas tabelas                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_POS(cTipo)
Local lRet := .f.
Do Case
	Case cTipo == "SA3"
		DbSelectArea("SA3")
		DbSetOrder(1)
		If DbSeek(xFilial("SA3")+cVend)
			lRet := .t.
		EndIf
	Case cTipo == "SBM"
		DbSelectArea("SBM")
		DbSetOrder(1)
		If DbSeek(xFilial("SBM")+cGrpPec)
			lRet := .t.
			lPec := .t.
			oPec:Refresh()
			Get_GRUPO := cGrpPec
			cCodPec := space(27)
			oCodPec:Refresh()
		EndIf
	Case cTipo == "SB1"
		DbSelectArea("SB1")
		If SB1->B1_CODITE == cCodPec
			cGrpPec := SB1->B1_GRUPO
		EndIf
		DbSelectArea("SB1")
		DbSetOrder(7)
		If DbSeek(xFilial("SB1")+cGrpPec+cCodPec)
			lRet := .t.
			lPec := .t.
			oPec:Refresh()
		EndIf
	Case cTipo == "VO6"
		DbSelectArea("VO6")
		DbSetOrder(4)
		If DbSeek(xFilial("VO6")+cCodSrv)
			lRet := .t.
			lSrv := .t.
			oSrv:Refresh()
		EndIf
	Case cTipo == "PEC"
		lRet := .t.
		If !lPec
			cGrpPec := space(4)
			cCodPec := space(27)
		EndIf
		oGrpPec:Refresh()
		oCodPec:Refresh()
	Case cTipo == "SRV"
		lRet := .t.
		If !lSrv
			cCodSrv := space(15)
		EndIf
		oCodSrv:Refresh()
EndCase
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_VAL600³ Autor ³ Andre Luis Almeida      ³ Data ³ 10/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Validacoes / Posicionamento nas tabelas                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VAL600(cTipo)
Local lRet := .t.
Do Case
	Case cTipo == "DT1" // Zera Campos de Calculo das Datas (periodo)
		If dDtIni > dDtFin
			dDtFin := dDtIni
		EndIf
		oDtFin:Refresh()
	Case cTipo == "DT2" // Zera Campos de Calculo das Datas (data cadastro)
		If dDCIni > dDCFin
			dDCFin := dDCIni
		EndIf
		oDCFin:Refresh()
	Case cTipo == "TP1" // WHEN dos Campos
		nVlIni := 0
		nVlFin := 0
		cVend  := space(6)
		lVend  := .f.
		lVlIni := .f.
		lVlFin := .f.
		FS_VISIBLE(.f.)
		cTit2 := ""
		oConsV:lVisible := .f.
		oConsP:lVisible := .f.
		If cTipCS == STR0001 // Com
			nVlFin := 9999999999.99
			cTit2 := STR0029 //Considerar
			lVlIni := .t.
			lVlFin := .t.
			If cTipVP == STR0003 // Venda de
				oConsV:lVisible := .t.
				lVend := .t.
			Else
				oConsP:lVisible := .t.
			EndIf
			If !(cTipVP == STR0003  .and. cPrefV == STR0005 ) // Venda de / Balcao
				FS_VISIBLE(.t.)
			EndIf
		Else
			dDCIni := ctod("")
			dDCFin := dDataBase
		EndIf
	Case cTipo == "TP2" // Tipo: Venda/Passagem
		FS_VISIBLE(.f.)
		If lDatCad
			oDCIni:Refresh()
			oDCFin:Refresh()
		EndIf
		oPrefV:lVisible := .f.
		oPrefP:lVisible := .f.
		oConsV:lVisible := .f.
		oConsP:lVisible := .f.
		lVend := .f.
		If cTipCS == STR0001 // Com
			FS_VISIBLE(.t.)
		EndIf
		If cTipVP == STR0003 // Venda de
			If cTipCS == STR0001 // Com
				lVend := .t.
			EndIf
			oPrefV:lVisible := .t.
			oPrefV:Refresh()
			oPrefV:SetFocus()
			If (cPrefV == STR0005 ) // Balcao
				cTit1 := ""
				cTit3 := ""
				cTit4 := ""
				cTit5 := ""
				cTit6 := ""
				oRadio1:lVisible:= .f.
				oLbGrp:lVisible := .f.
				oLbMod:lVisible := .f.
				oLegenda:lVisible := .f.
				oMarVE1:lVisible := .f.
				oMarcarV:lVisible:=.f.
				oChaIni:lVisible:= .f.
				oChaFin:lVisible:= .f.
				oAnoIni:lVisible:= .f.
				oAnoFin:lVisible:= .f.
			EndIf
			If !(cPrefV == STR0007 ) // Veiculos
				oVeic:lVisible  := .f.
				cTit8 := ""
				cTit9 := ""
				cTit10:= ""
				oDEntI:lVisible := .f.
				oDEntF:lVisible := .f.
				oTpVda:lVisible := .f.
			EndIf
			If !(cPrefP == STR0008 ) // na Oficina
				oTpTmp:lVisible := .f.
				oPec:lVisible   := .f.
				oGrpPec:lVisible:= .f.
				oCodPec:lVisible:= .f.
				oSrv:lVisible   := .f.
				oCodSrv:lVisible:= .f.
			EndIf
			If cTipCS == STR0001 // Com
				oConsV:lVisible := .t.
			EndIf
		Else
			oPrefP:lVisible := .t.
			oPrefP:Refresh()
			oPrefP:SetFocus()
			If cTipCS == STR0001 // Com
				oConsP:lVisible := .t.
			EndIf
		EndIf
	Case cTipo == "PF1" // Prefixo
		FS_VISIBLE(.f.)
		lVlIni := .f.
		lVlFin := .f.
		lVend  := .f.
		If cTipCS == STR0001 // Com
			lVlIni := .t.
			lVlFin := .t.
			If cTipVP == STR0003 // Venda de
				lVend := .t.
			EndIf
			If !(cPrefV == STR0005 ) // Balcao
				FS_VISIBLE(.t.)
			EndIf
		EndIf
EndCase
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_VISIBLE³ Autor ³ Andre Luis Almeida     ³ Data ³ 10/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Altera lVisible dos campos na tela                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VISIBLE(lTp)
cTit1 := ""
cTit8 := ""
cTit9 := ""
cTit10:= ""
If !lTp .or. (cTipVP == STR0003 .and. cPrefV # STR0005 ) // Venda de / Balcao
	cTit3 := IIF(!lTp,"",STR0031) // Selecionar Marca:
	cTit4 := IIF(!lTp,"",STR0037) // Chassi:  de
	cTit5 := IIF(!lTp,"",STR0024) // ate
	cTit6 := IIF(!lTp,"",STR0039) // Ano Fab./Mod.: de
	cTit7 := IIF(!lTp,"",STR0024) // ate
	oRadio1:lVisible := lTp
	oMarVE1:lVisible := lTp
	oMarcarV:lVisible:= lTp
	oChaIni:lVisible := lTp
	oChaFin:lVisible := lTp
	oAnoIni:lVisible := lTp
	oAnoFin:lVisible := lTp
EndIf
If lTp
	cTit1 := STR0030 // Veiculos:
	If (cTipVP == STR0003 .and. cPrefV == STR0007 ) // Venda de / Veiculos
		oVeic:lVisible := .t.
		cTit8 := STR0041 // Data da entrega do veículo: de
		cTit9 := STR0024 // ate
		cTit10:= STR0042 // tipos de venda
		oDEntI:lVisible := .t.
		oDEntF:lVisible := .t.
		oTpVda:lVisible := .t.
	ElseIf (cTipVP == STR0004  .and. cPrefP == STR0008 ) // Passagem / na Oficina
		oTpTmp:lVisible := .t.
		oPec:lVisible   := .t.
		oGrpPec:lVisible:= .t.
		oCodPec:lVisible:= .t.
		oSrv:lVisible   := .t.
		oCodSrv:lVisible:= .t.
	EndIf
	If nCkRad1 == 1
		oLbGrp:lVisible := .t.
		oLegenda:lVisible := .t.
	ElseIf nCkRad1 == 2
		oLbMod:lVisible := .t.
		oLegenda:lVisible := .t.
	EndIf
Else
	oLbGrp:lVisible := .f.
	oLbMod:lVisible := .f.
	oLegenda:lVisible := .f.
	oVeic:lVisible  := .f.
	oTpTmp:lVisible := .f.
	oPec:lVisible   := .f.
	oGrpPec:lVisible:= .f.
	oCodPec:lVisible:= .f.
	oSrv:lVisible   := .f.
	oCodSrv:lVisible:= .f.
	oDEntI:lVisible := .f.
	oDEntF:lVisible := .f.
	oTpVda:lVisible := .f.
EndIf
oAgOFI:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³  FS_TIK  ³ Autor ³ Andre Luis Almeida     ³ Data ³ 10/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Tik radio / Seleciona Grupo/Modelo                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(nTipo)
Local cQuery  := ""
Local cQAlias := "SQLTAB"
Do Case
	Case nTipo == 1 // nCkRad1 == 1
		oLbGrp:lVisible := .t.
		oLbMod:lVisible := .f.
		oLegenda:lVisible := .t.
	Case nTipo == 2 // nCkRad1 == 2
		oLbGrp:lVisible := .f.
		oLbMod:lVisible := .t.
		oLegenda:lVisible := .t.
	Case nTipo == 10
		If !Empty(aGrp[oLbGrp:nAt,2])
			aGrp[oLbGrp:nAt,1]:=!aGrp[oLbGrp:nAt,1]
		EndIf
	Case nTipo == 20
		If !Empty(aMod[oLbMod:nAt,2])
			aMod[oLbMod:nAt,1]:=!aMod[oLbMod:nAt,1]
		EndIf
	Case nTipo == 0 .or. nTipo == 9 // Inicial ou Filtra Marca
		aGrp := {}
		aMod := {}
		cQuery := "SELECT VVR.VVR_CODMAR ,VVR.VVR_GRUMOD , VVR.VVR_DESCRI FROM "+RetSqlName("VVR")+" VVR WHERE VVR.VVR_FILIAL='"+xFilial("VVR")+"' AND "
		If !Empty(cMarca)
			cQuery += "VVR.VVR_CODMAR='"+cMarca+"' AND "
		EndIf
		cQuery += "VVR.D_E_L_E_T_=' ' ORDER BY VVR.VVR_CODMAR , VVR.VVR_GRUMOD "
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		If !( cQAlias )->( Eof() )
			Do While !( cQAlias )->( Eof() )
				Aadd(aGrp,{ lMarcarV ,( cQAlias )->( VVR_CODMAR ),( cQAlias )->( VVR_GRUMOD ),( cQAlias )->( VVR_DESCRI )})
				( cQAlias )->( DbSkip() )
			EndDo
		Else
			Aadd(aGrp,{.f.,"","",""})
		EndIf
		( cQAlias )->( dbCloseArea() )
		cQuery := "SELECT VV2.VV2_CODMAR , VV2.VV2_MODVEI , VV2.VV2_DESMOD FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND "
		If !Empty(cMarca)
			cQuery += "VV2.VV2_CODMAR='"+cMarca+"' AND "
		EndIf
		cQuery += "VV2.D_E_L_E_T_=' ' ORDER BY VV2.VV2_CODMAR , VV2.VV2_MODVEI "
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		If !( cQAlias )->( Eof() )
			Do While !( cQAlias )->( Eof() )
				Aadd(aMod,{ lMarcarV ,( cQAlias )->( VV2_CODMAR ),( cQAlias )->( VV2_MODVEI ),( cQAlias )->( VV2_DESMOD )})
				( cQAlias )->( DbSkip() )
			EndDo
		Else
			Aadd(aMod,{.f.,"","",""})
		EndIf
		( cQAlias )->( dbCloseArea() )
		If nTipo == 9
			oLbGrp:nAt := 1
			oLbGrp:SetArray(aGrp)
			oLbGrp:bLine := { || {IIf(aGrp[oLbGrp:nAt,1],overde,overmelho),;
			aGrp[oLbGrp:nAt,2] ,;
			aGrp[oLbGrp:nAt,3] ,;
			aGrp[oLbGrp:nAt,4] }}
			oLbGrp:Refresh()
			oLbMod:nAt := 1
			oLbMod:SetArray(aMod)
			oLbMod:bLine := { || {IIf(aMod[oLbMod:nAt,1],overde,overmelho),;
			aMod[oLbMod:nAt,2] ,;
			aMod[oLbMod:nAt,3] ,;
			aMod[oLbMod:nAt,4] }}
			oLbMod:Refresh()
		EndIf
EndCase
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_TIKTUDO³ Autor ³ Andre Luis Almeida     ³ Data ³ 10/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Tik total do Grupo/Modelo                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIKTUDO( lMarcar )
Local ni := 0
Default lMarcar := .f.
For ni := 1 to Len(aGrp)
	If !Empty(aGrp[ni,3])
		aGrp[ni,1] := lMarcar
	EndIf
Next
For ni := 1 to Len(aMod)
	If !Empty(aMod[ni,3])
		aMod[ni,1] := lMarcar
	EndIf
Next
lMarcarV := lMarcar
oLbGrp:Refresh()
oLbMod:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_FILTRA³ Autor ³ Andre Luis Almeida     ³ Data ³ 10/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levanta Dados atraves do filtro na tela                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRA()
Local cQuery  := ""
Local cQuery1 := ""
Local cQuery2 := ""
Local cQAlias := "SQLTAB"
Local cQAlAux := "SQLAUX"
Local cCliente:= "INICIAL"
Local _cCodCli:= ""
Local _cLojCli:= ""
Local cSA1    := ""
Local cSA1Nome:= ""
Local cSA1Fone:= ""
Local cChassi := ""
Local aModAux := {}
Local aGrpAux := {}
Local nPos    := 0
Local ni      := 0
Local aClientes := {}
Local lVV1_BLQPRO := ( VV1->(FieldPos("VV1_BLQPRO")) > 0 )
Local nVlrPec := 0
Local nVlrSrv := 0
Local nVlrVei := 0
Local cPrefBal := GetNewPar("MV_PREFBAL","BAL")
Local cPrefOfi := GetNewPar("MV_PREFOFI","OFI")
Local cPrefVei := GetNewPar("MV_PREFVEI","VEI")
cTitulo   := STR0050+" - " // Lista
If nCkRad1 == 1
	For ni := 1 to len(aGrp)
		If aGrp[ni,1]
			Aadd(aGrpAux,{aGrp[ni,2]+aGrp[ni,3]})
		EndIf
	Next
Else // nCkRad1 == 2
	For ni := 1 to len(aMod)
		If aMod[ni,1]
			Aadd(aModAux,{aMod[ni,2]+aMod[ni,3]})
		EndIf
	Next
EndIf
cNFilt := left(STR0050 +Transform(dDataBase,"@D")+space(30),30) // Lista
ProcRegua(4)
IncProc( STR0052 ) // Levantando Clientes...
Do Case
	Case ( cTipCS == STR0001  .and. cTipVP == STR0003  ) // Com / Venda de
		cQuery := "SELECT SF2.F2_CLIENTE , SF2.F2_LOJA , SF2.F2_EMISSAO , SF2.F2_DOC , SF2.F2_SERIE ,"
		cQuery += "       SF2.F2_VALBRUT , SF2.F2_PREFORI "
		cQuery += "FROM "+RetSqlName("SF2")+" SF2 WHERE SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
		If cPrefV == STR0005 // Balcao
			cQuery  += "SF2.F2_PREFORI='"+ cPrefBal +"' AND "
			cTitulo += STR0053 // Clientes com Venda de Balcao
		ElseIf cPrefV == STR0006 // Oficina
			cQuery  += "SF2.F2_PREFORI='"+ cPrefOfi +"' AND "
			cTitulo += STR0051 // Clientes com Venda de Oficina
		Else // cPrefV == STR0007  // Veiculos
			cQuery  += "SF2.F2_PREFORI='"+ cPrefVei +"' AND "
			cTitulo += STR0049 // Clientes com Venda de Veiculos
		EndIf
		cQuery += "SF2.F2_EMISSAO>='"+dtos(dDtIni)+"' AND SF2.F2_EMISSAO<='"+dtos(dDtFin)+"' AND "
		cQuery += "SF2.F2_VALBRUT>="+str(nVlIni,15)+" AND SF2.F2_VALBRUT<="+str(nVlFin,15)+" AND "
		If !Empty(cVend)
			cQuery += "SF2.F2_VEND1='"+ cVend +"' AND "
		EndIf
		cQuery += "SF2.D_E_L_E_T_=' ' ORDER BY SF2.F2_CLIENTE , SF2.F2_LOJA , "
		If cConsV == STR0009 // Ultima Venda
			cQuery += "SF2.F2_EMISSAO desc "
		Else
			cQuery += "SF2.F2_EMISSAO "
		EndIf
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		If !( cQAlias )->( Eof() )
			Do While !( cQAlias )->( Eof() )
				_cCodCli := ( cQAlias )->( F2_CLIENTE )
				_cLojCli := ( cQAlias )->( F2_LOJA )
				cChassi := ""
				//
				nVlrPec := 0
				nVlrSrv := 0
				nVlrVei := 0
				Do Case
					Case cPrefBal == ( cQAlias )->( F2_PREFORI )
						nVlrPec := ( cQAlias )->( F2_VALBRUT )
					Case cPrefOfi == ( cQAlias )->( F2_PREFORI )
						DbSelectArea("VOO")
						DbSetOrder(4)
						MsSeek( xFilial("VOO") + ( cQAlias )->( F2_DOC ) + ( cQAlias )->( F2_SERIE ) )
						nVlrPec := VOO->VOO_TOTPEC
						nVlrSrv := VOO->VOO_TOTSRV
					Case cPrefVei == ( cQAlias )->( F2_PREFORI )
						nVlrVei := ( cQAlias )->( F2_VALBRUT )
				EndCase
				//
				If cPrefV == STR0007 .or. cPrefV == STR0006 // Veiculos / Oficina
					If cPrefV == STR0007 // Veiculos
						DbSelectArea("VV0")
						DbSetOrder(4)
						MsSeek( xFilial("VV0") + ( cQAlias )->( F2_DOC ) + ( cQAlias )->( F2_SERIE ) )
						If cTpVda # STR0018 // Diferente de / Todos os Tipos
							If left(cTpVda,1) #	VV0->VV0_CATVEN
								( cQAlias )->( DbSkip() )
								Loop
							EndIf
						EndIf
						If VV0->VV0_DATENT < dDEntI .or. VV0->VV0_DATENT > dDEntF
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
						DbSelectArea("VVA")
						DbSetOrder(1)
						MsSeek( xFilial("VVA") + VV0->VV0_NUMTRA )
						DbSelectArea("VV1")
						DbSetOrder(1)
						MsSeek( xFilial("VV1") + VVA->VVA_CHAINT )
						If cVeic # STR0015 // Diferente de / Todos Veiculos
							If ( VV1->VV1_ESTVEI == "0" .and. cVeic # STR0016  ) .or. ( VV1->VV1_ESTVEI == "1" .and. cVeic # STR0017 ) // Diferente de / Veiculos Novos // Diferente de / Veiculos Usados
								( cQAlias )->( DbSkip() )
								Loop
							EndIf
						EndIf
					Else //  cPrefV == Oficina
						DbSelectArea("VOO")
						DbSetOrder(4)
						MsSeek( xFilial("VOO") + ( cQAlias )->( F2_DOC ) + ( cQAlias )->( F2_SERIE ) )
						DbSelectArea("VO1")
						DbSetOrder(1)
						MsSeek( xFilial("VO1") + VOO->VOO_NUMOSV )
						DbSelectArea("VV1")
						DbSetOrder(1)
						MsSeek( xFilial("VV1") + VO1->VO1_CHAINT )
					EndIf
					If !Empty(cChaFin)
						If cChaIni > VV1->VV1_CHASSI .or. cChaFin < VV1->VV1_CHASSI
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
					EndIf
					If !Empty(cAnoFin)
						If cAnoIni > VV1->VV1_FABMOD .or. cAnoFin < VV1->VV1_FABMOD
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
					EndIf
					nPos := 0
					If nCkRad1 == 1
						DbSelectArea("VV2")
						DbSetOrder(1)
						DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
						nPos := aScan(aGrpAux, {|x| x[1] == VV1->VV1_CODMAR + VV2->VV2_GRUMOD })
					Else // nCkRad1 == 2
						nPos := aScan(aModAux, {|x| x[1] == VV1->VV1_CODMAR + VV1->VV1_MODVEI })
					EndIf
					If nPos == 0
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
					cChassi := VV1->VV1_CHASSI
					If !Empty(VV1->VV1_PROATU+VV1->VV1_LJPATU)
						_cCodCli := VV1->VV1_PROATU
						_cLojCli := VV1->VV1_LJPATU
					EndIf
				EndIf
				DbSelectArea("VCF")
				DbSetOrder(1)
				If DbSeek( xFilial("VCF") + _cCodCli + _cLojCli )
					If !Empty(VCF->VCF_BLOQAG)
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
					If lDatCad
						If VCF->VCF_DATCAD < dDCIni .or. VCF->VCF_DATCAD > dDCFin
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
					EndIf
				EndIf
				///////////////////////////////////////
				// Veiculo Bloqueado para Prospeccao //
				///////////////////////////////////////
				If lVV1_BLQPRO .and. !Empty(cChassi)
					If VV1->VV1_BLQPRO == "1"
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
				EndIf
				///////////////////////////////////////
				If cConsV # STR0011  // Diferente de / Todas Vendas
					If cCliente == _cCodCli + _cLojCli
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
					cCliente := _cCodCli + _cLojCli
				EndIf
				If cSA1 # _cCodCli + _cLojCli
					cSA1 := _cCodCli + _cLojCli
					DbSelectArea("SA1")
					DbSetOrder(1)
					DbSeek( xFilial("SA1") + cSA1 )
					cSA1Nome := SA1->A1_NOME
					cSA1Fone := ""
					If lA1_IBGE
						DbSelectArea("VAM")
						DbSetOrder(1)
						DbSeek( xFilial("VAM") + SA1->A1_IBGE )
						cSA1Fone := "("+VAM->VAM_DDD+") "
					EndIf
					cSA1Fone += Alltrim(SA1->A1_TEL)
				EndIf
				Aadd(aClientes,{.t. ,;
								Transform(stod(( cQAlias )->( F2_EMISSAO )),"@D") ,;
								_cCodCli ,;
								_cLojCli ,;
								cSA1Nome ,;
								cSA1Fone ,;
								cChassi ,;
								"" ,;
								"" ,;
								0 ,;
								0 ,;
								0 ,;
								0 ,;
								nVlrPec ,;
								nVlrSrv ,;
								nVlrVei })
				( cQAlias )->( DbSkip() )
			EndDo
		EndIf
		( cQAlias )->( dbCloseArea() )
	Case ( cTipCS == STR0002 .and. cTipVP == STR0003 ) // Sem / Venda de
		cQuery1 := "SELECT SF2.F2_DOC FROM "+RetSqlName("SF2")+" SF2 WHERE SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
		If cPrefV == STR0005 // Balcao
			cQuery2 := "SF2.F2_PREFORI='"+ cPrefBal +"' AND "
			cTitulo += STR0048 // Clientes sem Venda de Balcao
		ElseIf cPrefV == STR0006 // Oficina
			cQuery2 := "SF2.F2_PREFORI='"+ cPrefOfi +"' AND "
			cTitulo += STR0047 // Clientes sem Venda de Oficina
		Else // cPrefV == STR0007 // Veiculos
			cQuery2 := "SF2.F2_PREFORI='"+ cPrefVei +"' AND "
			cTitulo += STR0046 // Clientes sem Venda de Veiculos
		EndIf
		cQuery2 += "SF2.F2_EMISSAO>='"+dtos(dDtIni)+"' AND SF2.F2_EMISSAO<='"+dtos(dDtFin)+"' AND SF2.D_E_L_E_T_=' ' "
		If lA1_IBGE
			cQuery := "SELECT SA1.A1_COD , SA1.A1_LOJA , SA1.A1_NOME , SA1.A1_TEL , VAM.VAM_DDD FROM "+RetSqlName("SA1")+" SA1 "
			cQuery += "LEFT OUTER JOIN "+RetSqlName("VAM")+" VAM ON (SA1.A1_IBGE = VAM.VAM_IBGE AND SA1.D_E_L_E_T_ = VAM.D_E_L_E_T_) "
		Else
			cQuery := "SELECT SA1.A1_COD , SA1.A1_LOJA , SA1.A1_NOME , SA1.A1_TEL FROM "+RetSqlName("SA1")+" SA1 "
		EndIf
		cQuery += "WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		If !( cQAlias )->( Eof() )
			Do While !( cQAlias )->( Eof() )
				DbSelectArea("VCF")
				DbSetOrder(1)
				If DbSeek( xFilial("VCF") + ( cQAlias )->( A1_COD ) + ( cQAlias )->( A1_LOJA ) )
					If !Empty(VCF->VCF_BLOQAG)
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
					If lDatCad
						If VCF->VCF_DATCAD < dDCIni .or. VCF->VCF_DATCAD > dDCFin
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
					EndIf
				EndIf
				cQuery := cQuery1+"SF2.F2_CLIENTE='"+( cQAlias )->( A1_COD )+"' AND SF2.F2_LOJA='"+( cQAlias )->( A1_LOJA )+"' AND "+cQuery2
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
				If ( cQAlAux )->( Eof() )
					Aadd(aClientes,{.t.,;
									" " ,;
									( cQAlias )->( A1_COD ) ,;
									( cQAlias )->( A1_LOJA ) ,;
									( cQAlias )->( A1_NOME ) ,;
									IIf(lA1_IBGE,"("+( cQAlias )->( VAM_DDD )+") ","")+( cQAlias )->( A1_TEL ) ,;
									" " ,;
									"" ,;
									"" ,;
									0 ,;
									0 ,;
									0 ,;
									0 ,;
									0 ,;
									0 ,;
									0 })
				EndIf
				( cQAlAux )->( dbCloseArea() )
				( cQAlias )->( DbSkip() )
			EndDo
		EndIf
		( cQAlias )->( dbCloseArea() )
	Case ( cTipCS == STR0001  .and. cTipVP == STR0004  ) // Com / Passagem
		cTitulo += STR0045 // Clientes com Passagem na Oficina
		If lPec
			cQuery := "SELECT VEC.VEC_DATVEN , VEC.VEC_NUMNFI , VEC.VEC_SERNFI , SF2.F2_CLIENTE , SF2.F2_LOJA "
			cQuery += "FROM "+RetSqlName("VEC")+" VEC , "+RetSqlName("SF2")+" SF2 WHERE VEC.VEC_FILIAL='"+xFilial("VEC")+"' AND "
			cQuery += "VEC.VEC_BALOFI='O' AND VEC.VEC_DATVEN>='"+dtos(dDtIni)+"' AND VEC.VEC_DATVEN<='"+dtos(dDtFin)+"' AND "
			cQuery += "SF2.F2_DOC=VEC.VEC_NUMNFI AND SF2.F2_SERIE=VEC.VEC_SERNFI AND SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
			If !Empty(cGrpPec)
				cQuery += "VEC.VEC_GRUITE='"+cGrpPec+"' AND "
			EndIf
			If !Empty(cCodPec)
				cQuery += "VEC.VEC_CODITE='"+cCodPec+"' AND "
			EndIf
			cQuery += "VEC.VEC_VALBRU>="+str(nVlIni,15)+" AND VEC.VEC_VALBRU<="+str(nVlFin,15)+" AND "
			cQuery += "VEC.D_E_L_E_T_=' ' AND SF2.D_E_L_E_T_=' ' ORDER BY SF2.F2_CLIENTE , SF2.F2_LOJA , "
			If cConsP == STR0012 // Ultima Passagem
				cQuery += "VEC.VEC_DATVEN desc "
			Else
				cQuery += "VEC.VEC_DATVEN "
			EndIf
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
			If !( cQAlias )->( Eof() )
				Do While !( cQAlias )->( Eof() )
					_cCodCli := ( cQAlias )->( F2_CLIENTE )
					_cLojCli := ( cQAlias )->( F2_LOJA )
					DbSelectArea("VOO")
					DbSetOrder(4)
					DbSeek( xFilial("VOO") + ( cQAlias )->( VEC_NUMNFI ) + ( cQAlias )->( VEC_SERNFI ) )
					DbSelectArea("VO1")
					DbSetOrder(1)
					DbSeek( xFilial("VO1") + VOO->VOO_NUMOSV )
					DbSelectArea("VV1")
					DbSetOrder(1)
					DbSeek( xFilial("VV1") + VO1->VO1_CHAINT )
					If !Empty(cChaFin)
						If cChaIni > VV1->VV1_CHASSI .or. cChaFin < VV1->VV1_CHASSI
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
					EndIf
					If !Empty(cAnoFin)
						If cAnoIni > VV1->VV1_FABMOD .or. cAnoFin < VV1->VV1_FABMOD
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
					EndIf
					If !Empty(VV1->VV1_PROATU+VV1->VV1_LJPATU)
						_cCodCli := VV1->VV1_PROATU
						_cLojCli := VV1->VV1_LJPATU
					EndIf
					DbSelectArea("VCF")
					DbSetOrder(1)
					If DbSeek( xFilial("VCF") + _cCodCli + _cLojCli )
						If !Empty(VCF->VCF_BLOQAG)
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
						If lDatCad
							If VCF->VCF_DATCAD < dDCIni .or. VCF->VCF_DATCAD > dDCFin
								( cQAlias )->( DbSkip() )
								Loop
							EndIf
						EndIf
					EndIf
					nPos := 0
					If nCkRad1 == 1
						DbSelectArea("VV2")
						DbSetOrder(1)
						DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
						nPos := aScan(aGrpAux, {|x| x[1] == VV1->VV1_CODMAR + VV2->VV2_GRUMOD })
					Else // nCkRad1 == 2
						nPos := aScan(aModAux, {|x| x[1] == VV1->VV1_CODMAR + VV1->VV1_MODVEI })
					EndIf
					If nPos == 0
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
					If cConsP # STR0014 // Diferente de / Todas Passagens
						If cCliente == _cCodCli + _cLojCli
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
						cCliente := _cCodCli + _cLojCli
					EndIf
					cChassi := VV1->VV1_CHASSI
					///////////////////////////////////////
					// Veiculo Bloqueado para Prospeccao //
					///////////////////////////////////////
					If lVV1_BLQPRO
						If VV1->VV1_BLQPRO == "1"
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
					EndIf
					///////////////////////////////////////
					If cSA1 # _cCodCli + _cLojCli
						cSA1 := _cCodCli + _cLojCli
						DbSelectArea("SA1")
						DbSetOrder(1)
						DbSeek( xFilial("SA1") + cSA1 )
						cSA1Nome := SA1->A1_NOME
						cSA1Fone := ""
						If lA1_IBGE
							DbSelectArea("VAM")
							DbSetOrder(1)
							DbSeek( xFilial("VAM") + SA1->A1_IBGE )
							cSA1Fone := "("+VAM->VAM_DDD+") "
						EndIf
						cSA1Fone += Alltrim(SA1->A1_TEL)
					EndIf
					aAdd(aClientes,{.t. ,;
									Transform(stod(( cQAlias )->( VEC_DATVEN )),"@D") ,;
									_cCodCli ,;
									_cLojCli ,;
									cSA1Nome ,;
									cSA1Fone ,;
									cChassi ,;
									"P" ,;
									"" ,;
									0 ,;
									0 ,;
									0 ,;
									0 ,;
									0 ,;
									0 ,;
									0 })
					( cQAlias )->( DbSkip() )
				EndDo
			EndIf
			( cQAlias )->( dbCloseArea() )
		EndIf
		If lSrv
			cQuery := "SELECT VSC.VSC_DATVEN , VSC.VSC_NUMNFI , VSC.VSC_SERNFI , SF2.F2_CLIENTE , SF2.F2_LOJA "
			cQuery += "FROM "+RetSqlName("VSC")+" VSC , "+RetSqlName("SF2")+" SF2 WHERE VSC.VSC_FILIAL='"+xFilial("VSC")+"' AND "
			cQuery += "VSC.VSC_DATVEN>='"+dtos(dDtIni)+"' AND VSC.VSC_DATVEN<='"+dtos(dDtFin)+"' AND "
			cQuery += "SF2.F2_DOC=VSC.VSC_NUMNFI AND SF2.F2_SERIE=VSC.VSC_SERNFI AND SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
			If !Empty(cCodSrv)
				cQuery += "VSC.VSC_CODSER='"+cCodSrv+"' AND "
			EndIf
			cQuery += "VSC.VSC_VALBRU>="+str(nVlIni,15)+" AND VSC.VSC_VALBRU<="+str(nVlFin,15)+" AND "
			cQuery += "VSC.D_E_L_E_T_=' ' AND SF2.D_E_L_E_T_=' ' ORDER BY SF2.F2_CLIENTE , SF2.F2_LOJA , "
			If cConsP == STR0012 // Ultima Passagem
				cQuery += "VSC.VSC_DATVEN desc "
			Else
				cQuery += "VSC.VSC_DATVEN "
			EndIf
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
			If !( cQAlias )->( Eof() )
				Do While !( cQAlias )->( Eof() )
					_cCodCli := ( cQAlias )->( F2_CLIENTE )
					_cLojCli := ( cQAlias )->( F2_LOJA )
					DbSelectArea("VOO")
					DbSetOrder(4)
					DbSeek( xFilial("VOO") + ( cQAlias )->( VSC_NUMNFI ) + ( cQAlias )->( VSC_SERNFI ) )
					DbSelectArea("VO1")
					DbSetOrder(1)
					DbSeek( xFilial("VO1") + VOO->VOO_NUMOSV )
					DbSelectArea("VV1")
					DbSetOrder(1)
					DbSeek( xFilial("VV1") + VO1->VO1_CHAINT )
					If !Empty(cChaFin)
						If cChaIni > VV1->VV1_CHASSI .or. cChaFin < VV1->VV1_CHASSI
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
					EndIf
					If !Empty(cAnoFin)
						If cAnoIni > VV1->VV1_FABMOD .or. cAnoFin < VV1->VV1_FABMOD
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
					EndIf
					If !Empty(VV1->VV1_PROATU+VV1->VV1_LJPATU)
						_cCodCli := VV1->VV1_PROATU
						_cLojCli := VV1->VV1_LJPATU
					EndIf
					DbSelectArea("VCF")
					DbSetOrder(1)
					If DbSeek( xFilial("VCF") + _cCodCli + _cLojCli )
						If !Empty(VCF->VCF_BLOQAG)
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
						If lDatCad
							If VCF->VCF_DATCAD < dDCIni .or. VCF->VCF_DATCAD > dDCFin
								( cQAlias )->( DbSkip() )
								Loop
							EndIf
						EndIf
					EndIf
					nPos := 0
					If nCkRad1 == 1
						DbSelectArea("VV2")
						DbSetOrder(1)
						DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
						nPos := aScan(aGrpAux, {|x| x[1] == VV1->VV1_CODMAR + VV2->VV2_GRUMOD })
					Else // nCkRad1 == 2
						nPos := aScan(aModAux, {|x| x[1] == VV1->VV1_CODMAR + VV1->VV1_MODVEI })
					EndIf
					If nPos == 0
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
					If cConsP # STR0014 // Diferente de / Todas Passagens
						nPos := 0
						nPos := aScan(aClientes, {|x| x[8]+x[3]+[4] == "P" + _cCodCli + _cLojCli })
						If nPos > 0
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
						If cCliente == _cCodCli + _cLojCli
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
						cCliente := _cCodCli + _cLojCli
					EndIf
					cChassi := VV1->VV1_CHASSI
					///////////////////////////////////////
					// Veiculo Bloqueado para Prospeccao //
					///////////////////////////////////////
					If lVV1_BLQPRO
						If VV1->VV1_BLQPRO == "1"
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
					EndIf
					///////////////////////////////////////
					If cSA1 # _cCodCli + _cLojCli
						cSA1 := _cCodCli + _cLojCli
						DbSelectArea("SA1")
						DbSetOrder(1)
						DbSeek( xFilial("SA1") + cSA1 )
						cSA1Nome := SA1->A1_NOME
						cSA1Fone := ""
						If lA1_IBGE
							DbSelectArea("VAM")
							DbSetOrder(1)
							DbSeek( xFilial("VAM") + SA1->A1_IBGE )
							cSA1Fone := "("+VAM->VAM_DDD+") "
						EndIf
						cSA1Fone += Alltrim(SA1->A1_TEL)
					EndIf
					aAdd(aClientes,{.t. ,;
									Transform(stod(( cQAlias )->( VSC_DATVEN )),"@D") ,;
									_cCodCli ,;
									_cLojCli ,;
									cSA1Nome ,;
									cSA1Fone ,;
									cChassi ,;
									"S" ,;
									"" ,;
									0 ,;
									0 ,;
									0 ,;
									0 ,;
									0 ,;
									0 ,;
									0 })
					( cQAlias )->( DbSkip() )
				EndDo
			EndIf
			( cQAlias )->( dbCloseArea() )
		EndIf
		aSort(aClientes,1,,{|x,y| x[3]+x[4] < y[3]+y[4] })
	Case ( cTipCS == STR0002  .and. cTipVP == STR0004  ) // Sem / Passagem
		cTitulo += STR0040 // Clientes sem Passagem na Oficina
		cQuery1 := "SELECT VO1.VO1_NUMOSV FROM "+RetSqlName("VO1")+" VO1 WHERE VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND "
		cQuery2 := "VO1.VO1_DATABE>='"+dtos(dDtIni)+"' AND VO1.VO1_DATABE<='"+dtos(dDtFin)+"' AND VO1.D_E_L_E_T_=' ' "
		If lA1_IBGE
			cQuery := "SELECT SA1.A1_COD , SA1.A1_LOJA , SA1.A1_NOME , SA1.A1_TEL , VAM.VAM_DDD FROM "+RetSqlName("SA1")+" SA1 "
			cQuery += "LEFT OUTER JOIN "+RetSqlName("VAM")+" VAM ON (SA1.A1_IBGE = VAM.VAM_IBGE AND VAM.D_E_L_E_T_=' ' ) "
		Else
			cQuery := "SELECT SA1.A1_COD , SA1.A1_LOJA , SA1.A1_NOME , SA1.A1_TEL FROM "+RetSqlName("SA1")+" SA1 "
		EndIf
		cQuery += "WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		If !( cQAlias )->( Eof() )
			Do While !( cQAlias )->( Eof() )
				DbSelectArea("VCF")
				DbSetOrder(1)
				If DbSeek( xFilial("VCF") + ( cQAlias )->( A1_COD ) + ( cQAlias )->( A1_LOJA ) )
					If !Empty(VCF->VCF_BLOQAG)
						( cQAlias )->( DbSkip() )
						Loop
					EndIf
					If lDatCad
						If VCF->VCF_DATCAD < dDCIni .or. VCF->VCF_DATCAD > dDCFin
							( cQAlias )->( DbSkip() )
							Loop
						EndIf
					EndIf
				EndIf
				cQuery := cQuery1+"VO1.VO1_PROVEI='"+( cQAlias )->( A1_COD )+"' AND VO1.VO1_LOJPRO='"+( cQAlias )->( A1_LOJA )+"' AND "+cQuery2
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
				If ( cQAlAux )->( Eof() )
					aAdd(aClientes,{.t. ,;
									" " ,;
									( cQAlias )->( A1_COD ) ,;
									( cQAlias )->( A1_LOJA ) ,;
									( cQAlias )->( A1_NOME ) ,;
									IIf(lA1_IBGE,"("+( cQAlias )->( VAM_DDD )+") ","")+( cQAlias )->( A1_TEL ) ,;
									" " ,;
									"" ,;
									"" ,;
									0 ,;
									0 ,;
									0 ,;
									0 ,;
									0 ,;
									0 ,;
									0 })
				EndIf
				( cQAlAux )->( dbCloseArea() )
				( cQAlias )->( DbSkip() )
			EndDo
		EndIf
		( cQAlias )->( dbCloseArea() )
EndCase
IncProc( STR0038 ) // Finalizando...
// Objetivo //
cObjetiv := cObjSlv+CHR(13)+CHR(10)
cObjetiv += STR0020+": "+Transform(dDtIni,"@D")+" "+STR0024+" "+Transform(dDtFin,"@D")+CHR(13)+CHR(10) // Periodo / ate
If lDatCad
	cObjetiv += STR0021+": "+Transform(dDCIni,"@D")+" "+STR0024+" "+Transform(dDCFin,"@D")+CHR(13)+CHR(10) // Data Cadastro no CEV / ate
EndIf
cObjetiv += STR0026+" "+cTipCS+" "+cTipVP+" "+IIf(cTipVP==STR0003,cPrefV,cPrefP)+CHR(13)+CHR(10) // Clientes / Venda de
If cTipCS == STR0001 // Com
	cObjetiv += STR0027+": "+Transform(nVlIni,"@E 9999,999,999.99")+" "+STR0024+" "+Transform(nVlFin,"@E 9999,999,999.99") // Valores / ate
	If !Empty(cVend)
		cObjetiv += CHR(13)+CHR(10)+STR0028+": "+cVend // Vendedor
	EndIf
EndIf
//
OFIOM410CLI(aClientes,cTitulo)
IncProc( STR0038 ) // Finalizando...
Return