// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 42     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEIVA020.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVA020 ³ Autor ³  MIL                  ³ Data ³ 01/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Modelos de Ve¡culos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA020

Private cGruVei := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Private aCampos := {}
Private aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := (STR0006) // Cadastro de Modelos de Veiculos

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de Veiculos, Oficina ou Auto-Peças //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(11,14,41) .or. !FMX_AMIIn({"VEIVA020"})
	Return()
EndIf

mBrowse( 6, 1,22,75,"VV2")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VALSEG ºAutor  ³Fabio               º Data ³  03/01/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Valida o Segmento do modelo                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALSEG()

if Posicione("VE4",1, xFilial("VE4") + M->VV2_CODMAR , "VE4_SEGMOD" ) == "1" .And. Empty( M->VV2_SEGMOD )
	Help("  ",1,"SEGMODNVAL")
	Return( .f. )
EndIf

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA020     ºAutor  ³Fabio               º Data ³  10/05/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Monta Tela                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA020(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local i        := 0
Local aOrdem   := {}
Local nCntFor  := 0
Local _ni      := 0
Local aAux     := {}
Local n        := 0
Local nn       := 0
Local aSizeAut	:= MsAdvSize(.t.)
Local aObjects := {}

Private oGetGar, oGetAce, oGetKit, oGetPrc, oGetBon, oGetIte, oFolder
Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice :={} , nControlAba := 1
Private aColsGar := {}, aHeaderGar := {}, aColsAce := {}, aHeaderAce := {},;
aColsKit := {}, aHeaderKit := {}, aColsPrc := {}, aHeaderPrc := {}, aColsBon := {}, aHeaderBon := {},;
aColsIte := {}, aHeaderIte := {}, aHeaderFat := {},aColsFat := {}
Private cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk , nLinhas := 0
Private nOpcX := nOpc
Private cCampo := ""

AAdd( aObjects, { 0,	70, .T., .T. } )
// Tela Dois - Folder (Pecas e Servicos) - Tamanho vertical VARIAVEL
AAdd( aObjects, { 0,	30, .T., .T. } )
//
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }// Tamanho total da tela
aPosObj := MsObjSize( aInfo, aObjects ) // Monta objetos conforme especificacoes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VV2",.t.)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VV2")
While !Eof().And.(x3_arquivo=="VV2")
	If X3USO(x3_usado).And.cNivel>=x3_nivel
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+x3_campo):= CriaVar(x3_campo)
	DbSkip()
Enddo

If nOpc # 3
	DbSelectArea("VV2")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
EndIf

nOpcE := nOpc
nOpcG := nOpc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Faturamento Direto
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VZP")
While !Eof().And.(x3_arquivo=="VZP")
	if !(Alltrim(x3_campo) $ [VZP_CODMAR/VZP_MODVEI/VZP_SEGMOD/VZP_DESMOD]) .And. X3USO(x3_usado).And.cNivel>=x3_nivel
		Aadd(aHeaderFat,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_f3, x3_context,x3cbox(), x3_relacao } )
	Endif
	&("M->"+x3_campo) := CriaVar(x3_campo)
	DbSkip()
Enddo
dbSelectArea("VZP")
//ADHeadRec("VZP",aHeaderFat)

// Acessorios
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VVM")
While !Eof().And.(x3_arquivo=="VVM")
	if !(Alltrim(x3_campo) $ [VVM_CODMAR/VVM_MODVEI/VVM_SEGMOD/VVM_DESMOD]) .and. X3USO(x3_usado) .and. cNivel>=x3_nivel
		Aadd(aHeaderAce,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_f3, x3_context,x3cbox(), x3_relacao } )
	Endif
	&("M->"+x3_campo) := CriaVar(x3_campo)
	DbSkip()
Enddo
dbSelectArea("VVM")
//ADHeadRec("VVM",aHeaderAce)

// Garantia
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VVL")
While !Eof().And.(x3_arquivo=="VVL")
	if !(Alltrim(x3_campo) $ [VVL_CODMAR/VVL_MODVEI/VVL_SEGMOD/VVL_DESMOD]) .And. X3USO(x3_usado).And.cNivel>=x3_nivel
		Aadd(aHeaderGar,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_f3, x3_context,x3cbox(), x3_relacao } )
	Endif
	&("M->"+x3_campo) := CriaVar(x3_campo)
	DbSkip()
Enddo
dbSelectArea("VVL")
// Preco
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VVP")
While !Eof().And.(x3_arquivo=="VVP")
	If !(Alltrim(x3_campo) $ [VVP_CODMAR/VVP_DESMAR/VVP_MODVEI/VVP_SEGMOD/VVP_DESMOD/VVP_DATUSU]) .And. X3USO(x3_usado).And.cNivel>=x3_nivel
		Aadd(aHeaderPrc,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_f3, x3_context,x3cbox(), x3_relacao } )
	Endif
	&("M->"+x3_campo) := CriaVar(x3_campo)
	DbSkip()
Enddo
dbSelectArea("VVP")

// Itens da Entrega
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VAG")
While !Eof().And.(x3_arquivo=="VAG")
	If !(Alltrim(x3_campo) $ "VAG_CODMAR/VAG_MODVEI/VAG_SEGMOD") .And. X3USO(x3_usado).And.cNivel>=x3_nivel
		Aadd(aHeaderIte,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_f3, x3_context,x3cbox(), x3_relacao } )
	Endif
	&("M->"+x3_campo) := CriaVar(x3_campo)
	DbSkip()
Enddo
dbSelectArea("VAG")
//ADHeadRec("VAG",aHeaderIte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aCols da getdados                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsGar :={}
aColsAce :={}
aColsKit :={}
aColsPrc :={}
aColsIte :={}
aColsFat :={}

// Faturamento Direto
DbSelectArea("VZP")
DbSetOrder(1)
DbSeek( xFilial() + M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD )

Do While !eof() .And. VZP->VZP_CODMAR + VZP->VZP_MODVEI + VZP->VZP_SEGMOD == M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD ;
	.And. VZP->VZP_FILIAL == xFilial("VZP")
	
	AADD(aColsFat,Array(Len(aHeaderFat)+1))
	For _ni:=1 to Len(aHeaderFat)
		
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderFat[_ni,2])
			aColsFat[Len(aColsFat),_ni] := VZP->(RecNo())
		ElseIf IsHeadAlias(aHeaderFat[_ni,2])
			aColsFat[Len(aColsFat),_ni] := "VZP"
		Else
			aColsFat[Len(aColsFat),_ni]:=If(aHeaderFat[_ni,10] # "V",FieldGet(FieldPos(aHeaderFat[_ni,2])),CriaVar(aHeaderFat[_ni,2]))
		EndIf
		
	Next
	aColsFat[Len(aColsFat),Len(aHeaderFat)+1]:=.F.
	
	DbSelectArea("VZP")
	DbSkip()
	
EndDo

naColsFat := Len(aColsFat)

If Len(aColsFat) == 0
	
	aColsFat:={Array(Len(aHeaderFat)+1)}
	aColsFat[1,Len(aHeaderFat)+1]:=.F.
	
	For _ni:=1 to Len(aHeaderFat)
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderFat[_ni,2])
			aColsFat[Len(aColsFat),_ni] := 0
		ElseIf IsHeadAlias(aHeaderFat[_ni,2])
			aColsFat[Len(aColsFat),_ni] := "VZP"
		Else
			aColsFat[1,_ni]:=CriaVar(aHeaderFat[_ni,2])
		EndIf
	Next
	
EndIf


// Garantia
DbSelectArea("VVL")
DbSetOrder(1)
DbSeek( xFilial() + M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD )

Do While !eof() .And. VVL->VVL_CODMAR + VVL->VVL_MODVEI + VVL->VVL_SEGMOD == M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD ;
	.And. VVL->VVL_FILIAL == xFilial("VVL")
	
	AADD(aColsGar,Array(Len(aHeaderGar)+1))
	For _ni:=1 to Len(aHeaderGar)
		
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderGar[_ni,2])
			aColsGar[Len(aColsGar),_ni] := VVL->(RecNo())
		ElseIf IsHeadAlias(aHeaderGar[_ni,2])
			aColsGar[Len(aColsGar),_ni] := "VVL"
		Else
			aColsGar[Len(aColsGar),_ni]:=If(aHeaderGar[_ni,10] # "V",FieldGet(FieldPos(aHeaderGar[_ni,2])),CriaVar(aHeaderGar[_ni,2]))
		EndIf
		
	Next
	aColsGar[Len(aColsGar),Len(aHeaderGar)+1]:=.F.
	
	DbSelectArea("VVL")
	DbSkip()
	
EndDo

naColsGar := Len(aColsGar)

If Len(aColsGar) == 0
	
	aColsGar:={Array(Len(aHeaderGar)+1)}
	aColsGar[1,Len(aHeaderGar)+1]:=.F.
	
	For _ni:=1 to Len(aHeaderGar)
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderGar[_ni,2])
			aColsGar[Len(aColsGar),_ni] := 0
		ElseIf IsHeadAlias(aHeaderGar[_ni,2])
			aColsGar[Len(aColsGar),_ni] := "VVL"
		Else
			aColsGar[1,_ni]:=CriaVar(aHeaderGar[_ni,2])
		EndIf
	Next
	
EndIf

// Acessorios
DbSelectArea("VVM")
DbSetOrder(1)
DbSeek( xFilial("VVM") + M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD )

Do While !eof() .And. VVM->VVM_CODMAR + VVM->VVM_MODVEI + VVM->VVM_SEGMOD == M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD ;
	.And. VVM->VVM_FILIAL == xFilial("VVM")
	
	AADD(aColsAce,Array(Len(aHeaderAce)+1))
	For _ni:=1 to Len(aHeaderAce)
		
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderAce[_ni,2])
			aColsAce[Len(aColsAce),_ni] := VVM->(RecNo())
		ElseIf IsHeadAlias(aHeaderAce[_ni,2])
			aColsAce[Len(aColsAce),_ni] := "VVM"
		Else
			aColsAce[Len(aColsAce),_ni]:=If(aHeaderAce[_ni,10] # "V",FieldGet(FieldPos(aHeaderAce[_ni,2])),CriaVar(aHeaderAce[_ni,2]))
		EndIf
		
	Next
	aColsAce[Len(aColsAce),Len(aHeaderAce)+1]:=.F.
	
	DbSelectArea("VVM")
	DbSkip()
	
EndDo

naColsAce := Len(aColsAce)
If Len(aColsAce) == 0
	aColsAce:={Array(Len(aHeaderAce)+1)}
	aColsAce[1,Len(aHeaderAce)+1]:=.F.
	For _ni:=1 to Len(aHeaderAce)
		
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderAce[_ni,2])
			aColsAce[Len(aColsAce),_ni] := 0
		ElseIf IsHeadAlias(aHeaderAce[_ni,2])
			aColsAce[Len(aColsAce),_ni] := "VVM"
		Else
			aColsAce[1,_ni]:=CriaVar(aHeaderAce[_ni,2])
		EndIf
		
	Next
EndIf

// Preco
DbSelectArea("VVP")
DbSetOrder(1)
DbSeek( xFilial() + M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD )

Do While !eof() .And. VVP->VVP_CODMAR + VVP->VVP_MODVEI + VVP->VVP_SEGMOD == M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD ;
	.And. VVP->VVP_FILIAL == xFilial("VVP")
	
	AADD(aColsPrc,Array(Len(aHeaderPrc)+1))
	For _ni:=1 to Len(aHeaderPrc)
		
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderPrc[_ni,2])
			aColsPrc[Len(aColsPrc),_ni] := VVP->(RecNo())
		ElseIf IsHeadAlias(aHeaderPrc[_ni,2])
			aColsPrc[Len(aColsPrc),_ni] := "VVP"
		Else
			aColsPrc[Len(aColsPrc),_ni]:=If(aHeaderPrc[_ni,10] # "V",FieldGet(FieldPos(aHeaderPrc[_ni,2])),CriaVar(aHeaderPrc[_ni,2]))
		EndIf
		
	Next
	aColsPrc[Len(aColsPrc),Len(aHeaderPrc)+1]:=.F.
	
	DbSelectArea("VVP")
	DbSkip()
	
EndDo

nAcolsPrc := Len(aColsPrc)

If Len(aColsPrc) == 0
	
	aColsPrc:={Array(Len(aHeaderPrc)+1)}
	aColsPrc[1,Len(aHeaderPrc)+1]:=.F.
	
	For _ni:=1 to Len(aHeaderPrc)
		
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderPrc[_ni,2])
			aColsPrc[Len(aColsPrc),_ni] := 0
		ElseIf IsHeadAlias(aHeaderPrc[_ni,2])
			aColsPrc[Len(aColsPrc),_ni] := "VVP"
		Else
			aColsPrc[1,_ni]:=CriaVar(aHeaderPrc[_ni,2])
		EndIf
		
	Next
	
EndIf


// Itens Check-list Entrega

DbSelectArea("VAG")
DbSetOrder(1)
DbSeek( xFilial() + M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD )

Do While !eof() .And. VAG->VAG_CODMAR + VAG->VAG_MODVEI + VAG->VAG_SEGMOD == M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD ;
	.And. VAG->VAG_FILIAL == xFilial("VAG")
	
	AADD(aColsIte,Array(Len(aHeaderIte)+1))
	For _ni:=1 to Len(aHeaderIte)
		
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderIte[_ni,2])
			aColsIte[Len(aColsIte),_ni] := VAG->(RecNo())
		ElseIf IsHeadAlias(aHeaderIte[_ni,2])
			aColsIte[Len(aColsIte),_ni] := "VAG"
		Else
			aColsIte[Len(aColsIte),_ni]:=If(aHeaderIte[_ni,10] # "V",FieldGet(FieldPos(aHeaderIte[_ni,2])),CriaVar(aHeaderIte[_ni,2]))
		EndIf
		
	Next
	aColsIte[Len(aColsIte),Len(aHeaderIte)+1]:=.F.
	
	DbSelectArea("VAG")
	DbSkip()
	
EndDo

naColsIte := Len(aColsIte)

If Len(aColsIte) == 0
	aColsIte:={Array(Len(aHeaderIte)+1)}
	aColsIte[1,Len(aHeaderIte)+1]:=.F.
	For _ni:=1 to Len(aHeaderIte)
		
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeaderIte[_ni,2])
			aColsIte[Len(aColsIte),_ni] := 0
		ElseIf IsHeadAlias(aHeaderIte[_ni,2])
			aColsIte[Len(aColsIte),_ni] := "VAG"
		Else
			aColsIte[1,_ni]:=CriaVar(aHeaderIte[_ni,2])
		EndIf
		
	Next
EndIf

DbSelectArea("VV2")
DbSetOrder(1)
DbSeek( xFilial("VV2") + M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD )

DbSelectArea("VE1")
DbSetOrder(1)
DbSeek(xFilial("VE1")+M->VV2_CODMAR)
DbSelectArea("VVR")
DbSetOrder(1)
DbSeek(xFilial("VE1")+M->VV2_CODMAR)

aheader := Aclone( aHeaderGar )
aCols   := Aclone( aColsGar )
n := Len(aCols)

If Len( aHeaderGar ) > 0 .And. Len( aHeaderAce ) > 0 .And. Len( aHeaderPrc ) > 0 .And. Len(aHeaderIte) > 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo       :=STR0006
	cAliasEnchoice:="VV2"
	cAliasGetD    :="VVL"
	cLinOk        :="FS_VP020()"
	cTudOk        :="FS_VP020()"
	cFieldOk      :="FG_MEMVAR() .And. FS_VA020VALID(oFolder:nOption)"   // Faltava validacao dos campos - Antonio - fnc
	nLinhas       := 99
	aTitles       := {STR0009,STR0008,STR0007,STR0013,STR0016 } // ,STR0017}
	&& Monta arquivo para nao dar problema na hora de montar a tela
	aOrdem := {}
	i := 0
	Aadd(aOrdem, { "oGetGar" , 1 , Len(aHeaderGar) } )
	Aadd(aOrdem, { "oGetAce" , 2 , Len(aHeaderAce) } )
	//	Aadd(aOrdem, { "oGetKit" , 3 , Len(aHeaderKit) } )
	Aadd(aOrdem, { "oGetPrc" , 3 , Len(aHeaderPrc) } )
	//	Aadd(aOrdem, { "oGetBon" , 5 , Len(aHeaderBon) } )
	Aadd(aOrdem, { "oGetIte" , 4 , Len(aHeaderIte) } )
	
	
	oDlg := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cTitulo,,,,,,,,,.t.)
	
	oEnch := MSMGet():New( cAliasEnchoice ,nReg,nOpcE,,,,aCpoEnchoice, aPosObj[1],,2,,,cTudOk,oDlg,.f.,.t.,.f.,"",.t., .f.)
	
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{}, oDlg,,,,.t.,.f.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
	
	
	oGetPrc:= MsNewGetDados():New(0,0,aPosObj[2,3]-aPosObj[2,1]-14 ,aPosObj[2,4]-aPosObj[2,2],iif(nopcg==2,0,GD_INSERT+GD_UPDATE+GD_DELETE),cLinOK,cTudOk,,,,nLinhas,cFieldOk,,,oFolder:aDialogs[1],aHeaderPrc,aColsPrc )
	oGetAce:= MsNewGetDados():New(0,0,aPosObj[2,3]-aPosObj[2,1]-14 ,aPosObj[2,4]-aPosObj[2,2],iif(nopcg==2,0,GD_INSERT+GD_UPDATE+GD_DELETE),cLinOK,cTudOk,,,,nLinhas,cFieldOk,,,oFolder:aDialogs[2],aHeaderAce,aColsAce )
	oGetGar:= MsNewGetDados():New(0,0,aPosObj[2,3]-aPosObj[2,1]-14 ,aPosObj[2,4]-aPosObj[2,2],iif(nopcg==2,0,GD_INSERT+GD_UPDATE+GD_DELETE),cLinOK,cTudOk,,,,nLinhas,cFieldOk,,,oFolder:aDialogs[3],aHeaderGar,aColsGar )
	oGetIte:= MsNewGetDados():New(0,0,aPosObj[2,3]-aPosObj[2,1]-14 ,aPosObj[2,4]-aPosObj[2,2],iif(nopcg==2,0,GD_INSERT+GD_UPDATE+GD_DELETE),cLinOK,cTudOk,,,,nLinhas,cFieldOk,,,oFolder:aDialogs[4],aHeaderIte,aColsIte )
	oGetFat:= MsNewGetDados():New(0,0,aPosObj[2,3]-aPosObj[2,1]-14 ,aPosObj[2,4]-aPosObj[2,2],iif(nopcg==2,0,GD_INSERT+GD_UPDATE+GD_DELETE),cLinOK,cTudOk,,,,nLinhas,cFieldOk,,,oFolder:aDialogs[5],aHeaderFat,aColsFat )
	
	ACTIVATE MSDIALOG oDlg ON INIT ( EnChoiceBar(oDlg,{|| nOpca := 1,If(obrigatorio(aGets,aTela).and. &(cTudOk) .And. FS_GRAMODELO( nOpc ) , oDlg:End(), nOpca:=0 ) } , {||nOpca := 0,oDlg:End()}))
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIPA840  ºAutor  ³Microsiga           º Data ³  08/17/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava Modelo                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAMODELO( nOpc )
Local nReg := 0
Private lMsHelpAuto := .t., lMsFinalAuto := .f.

if nOpc == 3
	If !FG_EK("VV2")
		MsgInfo(STR0018)
		Return(.f.)
	EndIf
Endif

If !FS_VALGRAMODELO( nOpc , .t. )
	
	MostraErro()
	Return( .f. )
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rafael 22/12³
//³00000030624 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nReg := 1 to Len(oGetPrc:aCols)
	if (nOpc == 3 .or. nOpc == 4) .and. Empty( oGetPrc:aCols[nReg,FG_POSVAR("VVP_DATPRC","aHeaderPrc")]) .and. (!Empty( oGetPrc:aCols[nReg,FG_POSVAR("VVP_CUSTAB","aHeaderPrc")]) .or. !Empty( oGetPrc:aCols[nReg,FG_POSVAR("VVP_VALTAB","aHeaderPrc")]) )
		MsgAlert(STR0014,STR0015)//Necessário informar a data de validade - Aba Preços # Atencao
		Return(.f.)
	EndIf
Next

Begin Transaction

FS_VALGRAMODELO( nOpc )

End Transaction

lMsHelpAuto := .f.

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALGRAMODELO ³ Autor ³  MIL           ³ Data ³ 01/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao Modelos de Ve¡culos                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALGRAMODELO( nOpc , lValid )

Local lFGS      := ( SB1->(FieldPos("B1_FAMAPL")) > 0 .and. SB1->(FieldPos("B1_GRUAPL")) > 0 .and. SB1->(FieldPos("B1_SUBAPL")) > 0 ) // Filtro por Familia/Grupo/SubGrupo
Local lVQQ      := ( AliasInDic("VQQ") .and. VQQ->(FieldPos("VQQ_GRUVEI")) > 0 )
Local cQuery    := ""
Local cQAlSQL   := "SQLVQQ"
Local nReg      := 0
Local aVetValid := {}

Private lMsErroAuto := .f. , lMsHelpAuto := .t.

lValid := If( lValid == NIL , .f. , lValid )

If nOpc == 2
	Return(.t.)
EndIf

DbSelectArea("VV2")
DbSetOrder(1)
DbSeek( xFilial("VV2") + M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD )

If nOpc # 5
	
	If !lValid
	
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Se opcao Alterar + utiliza Familia/Grupo/SubGrupo + existe o campo VQQ_GRUVEI + mudou o Grupo de Modelo //
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		If nOpc == 4 .and. lFGS .and. lVQQ .and. VV2->VV2_GRUMOD <> M->VV2_GRUMOD
			cQuery := "SELECT R_E_C_N_O_ RECVQQ FROM "+RetSQLName("VQQ")+" WHERE VQQ_FILIAL='"+xFilial("VQQ")+"' AND VQQ_CODMAR='"+VV2->VV2_CODMAR+"' AND VQQ_MODVEI='"+VV2->VV2_MODVEI+"' AND D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
			While !( cQAlSQL )->( Eof() )
				DbSelectArea("VQQ")
				DbGoTo(( cQAlSQL )->( RECVQQ ))
				RecLock("VQQ",.f.)
					VQQ->VQQ_GRUVEI := M->VV2_GRUMOD
				MsUnLock()
				( cQAlSQL )->( DbSkip() )
			EndDo
			( cQAlSQL )->( DbCloseArea() )
		EndIf
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Incluir/Alterar Tabela VV2 - Modelos de Veiculos                                                        //
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		DbSelectArea("VV2")
		RecLock("VV2", !Found() )
		FG_GRAVAR("VV2")
		MsUnLock()
		
	EndIf
	
ElseIf Found()
	
	If lValid
		
		Aadd(aVetValid, {"VF6", 1 , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		Aadd(aVetValid, {"VF7", 1 , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		Aadd(aVetValid, {"VF8", 1 , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		Aadd(aVetValid, {"VO7", 2 , VV2->VV2_CODMAR+VV2->VV2_MODVEI+VV2->VV2_SEGMOD , NIL } )
		Aadd(aVetValid, {"VO8", 2 , VV2->VV2_CODMAR+VV2->VV2_MODVEI+VV2->VV2_SEGMOD , NIL } )
		Aadd(aVetValid, {"VV1", 3 , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		Aadd(aVetValid, {"VC3" , "VC3_CODMAR+VC3_MODVEI" , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		Aadd(aVetValid, {"VC4" , "VC4_CODMAR+VC4_MODVEI" , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		Aadd(aVetValid, {"VC6" , "VC6_CODMAR+VC6_MODVEI" , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		Aadd(aVetValid, {"VCC" , "VCC_CODMAR+VCC_MODVEI" , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		Aadd(aVetValid, {"VF0" , "VF0_CODMAR+VF0_MODVEI" , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		Aadd(aVetValid, {"VFC" , "VFC_CODMAR+VFC_MODVEI" , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		Aadd(aVetValid, {"VFD" , "VFD_CODMAR+VFD_MODVEI" , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		Aadd(aVetValid, {"VO6" , "VO6_CODMAR+VO6_MODVEI+VO6_SEGMOD" , VV2->VV2_CODMAR+VV2->VV2_MODVEI+VV2->VV2_SEGMOD , NIL } )
		If VVA->(FieldPos("VVA_CODMAR")) > 0
			Aadd(aVetValid, {"VVA" , "VVA_CODMAR+VVA_MODVEI" , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		EndIf
		Aadd(aVetValid, {"VDM" , "VDM_CODMAR+VDM_MODVEI" , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		If lFGS // utiliza Familia/Grupo/SubGrupo
			Aadd(aVetValid, {"VQQ" , "VQQ_CODMAR+VQQ_MODVEI" , VV2->VV2_CODMAR+VV2->VV2_MODVEI , NIL } )
		EndIf
		
		If !FG_DELETA( aVetValid )
			Return( .f. )
		EndIf
		
	Else
		
		&& Deleta Modelo
		RecLock("VV2",.F.,.T.)
		dbdelete()
		MsUnlock()
		WriteSx2("VV2")
		
	EndIf
	
EndIf


If !lValid
	
	&& Grava Garantia do modelo
	For nReg := 1 to Len(oGetGar:aCols)
		
		DbSelectArea("VVL")
		DbSetOrder(1)
		DbSeek( xFilial("VVL") + M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD + Dtos( oGetGar:aCols[nReg,FG_POSVAR("VVL_DATGAR","aHeaderGar")] ) )
		
		If nOpc # 5 .And. !oGetGar:aCols[nReg,Len(oGetGar:aCols[nReg])] .And. !Empty( oGetGar:aCols[nReg,FG_POSVAR("VVL_DATGAR","aHeaderGar")] )
			
			RecLock("VVL", !Found() )
			FG_GRAVAR("VVL",oGetGar:aCols,aHeaderGar,nReg)
			VVL->VVL_FILIAL := xFilial("VVL")
			VVL->VVL_CODMAR := M->VV2_CODMAR
			VVL->VVL_MODVEI := M->VV2_MODVEI
			VVL->VVL_SEGMOD := M->VV2_SEGMOD
			MsUnLock()
			
		ElseIf Found() .and. Len(oGetGar:aCols) >= nReg
			
			&& Deleta Servico
			RecLock("VVL",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VVL")
			
		EndIf
		
	Next
	
	&& Grava Acessorios
	For nReg := 1 to Len(oGetAce:aCols)
		
		DbSelectArea("VVM")
		DbSetOrder(1)
		DbSeek( xFilial("VVM") + M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD + oGetAce:aCols[nReg,FG_POSVAR("VVM_CODOPC","aHeaderAce")] )
		
		If nOpc # 5 .And. !oGetAce:aCols[nReg,Len(oGetAce:aCols[nReg])] .And. !Empty( oGetAce:aCols[nReg,FG_POSVAR("VVM_CODOPC","aHeaderAce")] )
			
			RecLock("VVM", !Found() )
			FG_GRAVAR("VVM",oGetAce:aCols,aHeaderAce,nReg)
			VVM->VVM_FILIAL := xFilial("VVM")
			VVM->VVM_CODMAR := M->VV2_CODMAR
			VVM->VVM_MODVEI := M->VV2_MODVEI
			VVM->VVM_SEGMOD := M->VV2_SEGMOD
			VVM->VVM_CODOPC := oGetAce:aCols[nReg,FG_POSVAR("VVM_CODOPC","aHeaderAce")]
			MsUnLock()
			
		ElseIf Found() .and. len(oGetAce:aCols) >= nReg
			
			&& Deleta Servico
			RecLock("VVM",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VVM")
			
		EndIf
		
	Next
	
	&& Grava Preco
	For nReg := 1 to Len(oGetPrc:aCols)
		
		DbSelectArea("VVP")
		DbSetOrder(1)
		DbSeek( xFilial("VVP") + M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD + Dtos( oGetPrc:aCols[nReg,FG_POSVAR("VVP_DATPRC","aHeaderPrc")] ) )
		
		If nOpc # 5 .And. !oGetPrc:aCols[nReg,Len(oGetPrc:aCols[nReg])] .And. !Empty( oGetPrc:aCols[nReg,FG_POSVAR("VVP_DATPRC","aHeaderPrc")] )
			
			RecLock("VVP", !Found() )
			FG_GRAVAR("VVP",oGetPrc:aCols,aHeaderPrc,nReg)
			VVP->VVP_FILIAL := xFilial("VVP")
			VVP->VVP_CODMAR := M->VV2_CODMAR
			VVP->VVP_MODVEI := M->VV2_MODVEI
			VVP->VVP_SEGMOD := M->VV2_SEGMOD
			VVP->VVP_DATUSU := Dtos(dDataBase)+"-"+__cUserID
			MsUnLock()
			
		ElseIf Found() .and. len(oGetPrc:aCols) >= nReg
			
			&& Deleta Servico
			RecLock("VVP",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VVP")
			
		EndIf
		
	Next

	&& Grava Itens Entrega
	For nReg := 1 to Len(oGetIte:aCols)
		
		DbSelectArea("VAG")
		DbSetOrder(1)
		DbSeek( xFilial("VAG") + M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD + oGetIte:aCols[nReg,FG_POSVAR("VAG_CODIGO","aHeaderIte")] )
		
		If nOpc # 5 .And. !oGetIte:aCols[nReg,Len(oGetIte:aCols[nReg])] .And. !Empty( oGetIte:aCols[nReg,FG_POSVAR("VAG_CODIGO","aHeaderIte")] )
			
			RecLock("VAG", !Found() )
			FG_GRAVAR("VAG",oGetIte:aCols,aHeaderIte,nReg)
			VAG->VAG_CODMAR := M->VV2_CODMAR
			VAG->VAG_MODVEI := M->VV2_MODVEI
			VAG->VAG_SEGMOD := M->VV2_SEGMOD
			MsUnLock()
			
		ElseIf Found() .and. Len(oGetIte:aCols) >= nReg
			
			&& Deleta Servico
			RecLock("VAG",.F.,.T.)
			dbdelete()
			MsUnlock()
			
		EndIf
		
	Next
	
	&& Grava Tipos de Venda Direta
	
	For nReg := 1 to Len(oGetFat:aCols)
		
		DbSelectArea("VZP")
		DbSetOrder(1)
		DbSeek( xFilial("VZP") + M->VV2_CODMAR + M->VV2_MODVEI + M->VV2_SEGMOD + oGetFat:aCols[nReg,FG_POSVAR("VZP_TIPO","aHeaderFat")] + oGetFat:aCols[nReg,FG_POSVAR("VZP_SEQUEN","aHeaderFat")] )
		
		If nOpc # 5 .And. !oGetFat:aCols[nReg,Len(oGetFat:aCols[nReg])] .And. !Empty( oGetFat:aCols[nReg,FG_POSVAR("VZP_TIPO","aHeaderFat")]) .And. !Empty( oGetFat:aCols[nReg,FG_POSVAR("VZP_SEQUEN","aHeaderFat")] )
			
			RecLock("VZP", !Found() )
			FG_GRAVAR("VZP",oGetFat:aCols,aHeaderFat,nReg)
			VZP->VZP_FILIAL := xFilial("VZP")
			VZP->VZP_CODMAR := M->VV2_CODMAR
			VZP->VZP_MODVEI := M->VV2_MODVEI
			VZP->VZP_SEGMOD := M->VV2_SEGMOD
			MsUnLock()
			
		ElseIf Found() .and. Len(oGetFat:aCols) >= nReg
			
			&& Deleta Servico
			RecLock("VZP",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VZP")
			
		EndIf
		
	Next
	
EndIf

Return( !lMsErroAuto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VA020VAºAutor  ³Fabio               º Data ³  08/19/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida Duplicidade                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VA020VALID(nAba)

Local i := 0
lAchou := .f.

If (      ReadVar() $ "M->VVL_DATGAR" .And. Ascan(oGetGar:aCols,{|x| x[FG_POSVAR("VVL_DATGAR","aHeaderGar")] == M->VVL_DATGAR }) # 0 ) ;
	.Or. ( ReadVar() $ "M->VVM_CODOPC" .And. Ascan(oGetAce:aCols,{|x| x[FG_POSVAR("VVM_CODOPC","aHeaderAce")] == M->VVM_CODOPC }) # 0 ) ;
	.Or. ( ReadVar() $ "M->VVP_DATPRC" .And. Ascan(oGetPrc:aCols,{|x| x[FG_POSVAR("VVP_DATPRC","aHeaderPrc")] == M->VVP_DATPRC }) # 0 ) ;
	.Or. ( ReadVar() $ "M->VAG_CODIGO" .And. Ascan(oGetIte:aCols,{|x| x[FG_POSVAR("VAG_CODIGO","aHeaderIte")] == M->VAG_CODIGO }) # 0 )
	
	if nAba == 2
		For i := 1 to Len(oGetAce:aCols)
			if oGetAce:aCols[i,1] == M->VVM_CODOPC .and. oGetAce:nAt <> i
				if oGetAce:aCols[i,Len(oGetAce:aCols[i])] == .t.
					lAchou := .t.
				Else
					lAchou := .f.
					oGetAce:aCols[n,1] := ""
					oGetAce:aCols[n,2] := ""
				Endif
			Endif
		Next
	Endif
	if lAchou == .f.
		Help("  ",1,"EXISTCHAV")
		oGetAce:oBrowse:SetFocus()
		Return(.f.)
	Endif
	
ElseIf ReadVar() $ "M->VZP_TIPO"
	
	If Empty(oGetFat:aCols[oGetFat:nAt,FG_POSVAR("VZP_SEQUEN","aHeaderFat")])
		If oGetFat:nAt == 1
			oGetFat:aCols[oGetFat:nAt,FG_POSVAR("VZP_SEQUEN","aHeaderFat")] := "001"
		Else
			cPosAnt := "000"
			For i := 1 to Len(oGetFat:aCols)
				if oGetFat:aCols[i,1] == M->VZP_TIPO
					If oGetFat:aCols[i,FG_POSVAR("VZP_SEQUEN","aHeaderFat")] > cPosAnt
						cPosAnt := oGetFat:aCols[i,FG_POSVAR("VZP_SEQUEN","aHeaderFat")]
					Endif
					If cPosAnt == "000"
						oGetFat:aCols[oGetFat:nAt,FG_POSVAR("VZP_SEQUEN","aHeaderFat")] := "001"
					Else
						oGetFat:aCols[oGetFat:nAt,FG_POSVAR("VZP_SEQUEN","aHeaderFat")] := Strzero(val(cPosAnt)+1,TamSx3("VZP_SEQUEN")[1])
					Endif
				Endif
			Next
			If Empty(oGetFat:aCols[oGetFat:nAt,FG_POSVAR("VZP_SEQUEN","aHeaderFat")])
				oGetFat:aCols[oGetFat:nAt,FG_POSVAR("VZP_SEQUEN","aHeaderFat")] := "001"
			EndIf
		Endif
	EndIf
	
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VP020  ºAutor  ³Fabio               º Data ³  08/19/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla Pastas                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VP020()

Local ix1  := 0
Local lValid := .f.
local nCntFor

If nOpcX == 5 .or. nOpcX == 2
	Return (.T.)
Endif

If oFolder:nOption == 3
	FG_MEMVAR(aHeaderGar,oGetGar:aCols,oGetGar:nAt)
	If Len(oGetGar:aCols) == 1
		If !Empty(oGetGar:aCols[1,FG_POSVAR("VVL_DATGAR","aHeaderGar")]) .or. (oGetGar:aCols[1,FG_POSVAR("VVL_PERGAR","aHeaderGar")] > 0) .or. (oGetGar:aCols[1,FG_POSVAR("VVL_KILGAR","aHeaderGar")] > 0)
			lValid := .t.
		Endif
	ElseIf Len(oGetGar:aCols) > 1
		lValid := .t.
	EndIf
ElseIf oFolder:nOption == 2
	FG_MEMVAR(aHeaderAce,oGetAce:aCols,oGetAce:nAt)
	If Len(oGetAce:aCols) == 1
		If !Empty(oGetAce:aCols[1,FG_POSVAR("VVM_CODOPC","aHeaderAce")])
			lValid := .t.
		Endif
	Elseif Len(oGetAce:aCols) > 1
		lValid := .t.
	EndIf
ElseIf oFolder:nOption == 1
	FG_MEMVAR(aHeaderPrc,oGetPrc:aCols,oGetPrc:nAt)
	If Len(oGetPrc:aCols) == 1
		If !Empty(oGetPrc:aCols[1,FG_POSVAR("VVP_DATPRC","aHeaderPrc")]) .or. (oGetPrc:aCols[1,FG_POSVAR("VVP_CUSTAB","aHeaderPrc")] > 0) .or. (oGetPrc:aCols[1,FG_POSVAR("VVP_VALTAB","aHeaderPrc")] > 0)
			lValid := .t.
		Endif
	ElseIf Len(oGetPrc:aCols) > 1
		lValid := .t.
	EndIf
ElseIf oFolder:nOption == 4
	FG_MEMVAR(aHeaderIte,oGetIte:aCols,oGetIte:nAt)
	If Len(oGetIte:aCols) == 1
		If !Empty(oGetIte:aCols[1,FG_POSVAR("VAG_CODIGO","aHeaderIte")])
			lValid := .t.
		Endif
	Elseif Len(oGetIte:aCols) > 1
		lValid := .t.
	EndIf
ElseIf oFolder:nOption == 5
	FG_MEMVAR(aHeaderFat,oGetFat:aCols,oGetFat:nAt)
	If Len(oGetFat:aCols) == 1
		If oGetFat:aCols[1,FG_POSVAR("VZP_VALVEN","aHeaderFat")] > 0
			lValid := .t.
		Endif
	Elseif Len(oGetFat:aCols) > 1
		lValid := .t.
	EndIf
EndIf

If lvalid
	
	If oFolder:nOption == 3
		
		For ix1 := 1 to len(oGetGar:aCols)
			If oGetGar:aCols[ix1,len(aHeaderGar)+1]
				loop
			EndIf
			if oGetGar:aCols[ix1,FG_POSVAR("VVL_PERGAR","aHeaderGar")] == 0 .or. oGetGar:aCols[ix1,FG_POSVAR("VVL_KILGAR","aHeaderGar")] == 0
				Help(" ",1,"OBRIGAT",,OemToAnsi(STR0011),4,1) // "-> Pasta Garantia"
				Return .f.
			Endif
			
			If oGetGar:nAt#ix1 .And. oGetGar:aCols[ix1,FG_POSVAR("VVL_DATGAR","aHeaderGar")] == M->VVL_DATGAR
				Help("  ",1,"EXISTCHAV")
				Return( .f. )
			EndIf
		Next
		
		For nCntFor:=1 to Len(aHeaderGar)
			If X3Obrigat(aHeaderGar[nCntFor,2])  .and. (Empty(oGetGar:aCols[oGetGar:nAt,nCntFor]))
				Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderGar[nCntFor,2]),4,1)
				Return .f.
			EndIf
		Next
		
	Elseif oFolder:nOption == 2
		
		For ix1 := 1 to len(oGetAce:aCols)
			If oGetAce:aCols[ix1,len(aHeaderAce)+1]
				loop
			EndIf
			If oGetAce:nAt#ix1 .And. oGetAce:aCols[ix1,FG_POSVAR("VVM_CODOPC","aHeaderAce")] == M->VVM_CODOPC
				Help("  ",1,"EXISTCHAV")
				Return( .f. )
			EndIf
		Next
		
		For nCntFor:=1 to Len(aHeaderAce)
			If X3Obrigat(aHeaderAce[nCntFor,2])  .and. (Empty(oGetAce:aCols[oGetAce:nAt,nCntFor]))
				Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderAce[nCntFor,2]),4,1)
				Return .f.
			EndIf
		Next
		
	Elseif oFolder:nOption == 1
		
		For ix1 := 1 to len(oGetPrc:aCols)
			
			If oGetPrc:aCols[ix1,len(aHeaderPrc)+1]
				loop
			EndIf
			If oGetPrc:nAt#ix1 .And. oGetPrc:aCols[ix1,FG_POSVAR("VVP_DATPRC","aHeaderPrc")] == M->VVP_DATPRC
				Help("  ",1,"EXISTCHAV")
				Return( .f. )
			EndIf
		Next
		
		For nCntFor:=1 to Len(aHeaderPrc)
			If X3Obrigat(aHeaderPrc[nCntFor,2])  .and. (Empty(oGetPrc:aCols[oGetPrc:nAt,nCntFor]))
				Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderPrc[nCntFor,2]),4,1)
				Return .f.
			EndIf
		Next
		
	Elseif oFolder:nOption == 4
		
		For ix1 := 1 to len(oGetIte:aCols)
			If oGetIte:aCols[ix1,len(aHeaderIte)+1]
				loop
			EndIf
			If oGetIte:nAt#ix1 .And. oGetIte:aCols[ix1,FG_POSVAR("VAG_CODIGO","aHeaderIte")] == M->VAG_CODIGO
				Help("  ",1,"EXISTCHAV")
				Return( .f. )
			EndIf
		Next
		
		For nCntFor:=1 to Len(aHeaderIte)
			If X3Obrigat(aHeaderIte[nCntFor,2])  .and. (Empty(oGetIte:aCols[oGetIte:nAt,nCntFor]))
				Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderIte[nCntFor,2]),4,1)
				Return .f.
			EndIf
		Next
		
	Elseif oFolder:nOption == 5
		
		If !oGetFat:aCols[oGetFat:nAt,Len(aHeaderFat)+1]
			For nCntFor:=1 to Len(aHeaderFat)
				If X3Obrigat(aHeaderFat[nCntFor,2])  .and. (Empty(oGetFat:aCols[oGetFat:nAt,nCntFor]))
					Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderFat[nCntFor,2]),4,1)
					Return .f.
				EndIf
			Next
		EndIf
		
	Endif
	
EndIf

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VP020G ºAutor  ³Fabio               º Data ³  08/19/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla Pastas                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VP020G()

Local nRegGar := 0
Local nRegAce := 0
Local nRegPrc := 0
Local nRegIte := 0
Local ix1     := 0

FG_MEMVAR()

oFolder:nOption := 3
For ix1 := 1 to len(oGetGar:aCols)
	
	If oGetGar:aCols[ix1,len(aHeaderGar)+1]
		loop
	EndIf
	
	If oGetGar:aCols[ix1,FG_POSVAR("VVL_DATGAR","aHeaderGar")] == M->VVL_DATGAR
		nRegGar ++
		If nRegGar > 1
			Help("  ",1,"EXISTCHAV")
			Return( .f. )
		EndIf
	Else
		Loop
	EndIf
	
Next

oFolder:nOption := 2
For ix1 := 1 to len(oGetAce:aCols)
	
	If oGetAce:aCols[ix1,len(aHeaderAce)+1]
		loop
	EndIf
	
	If oGetAce:aCols[ix1,FG_POSVAR("VVM_CODOPC","aHeaderAce")] == M->VVM_CODOPC
		nRegAce ++
		If nRegAce > 1
			Help("  ",1,"EXISTCHAV")
			Return( .f. )
		EndIf
	Else
		Loop
	EndIf
	
Next

oFolder:nOption := 1
For ix1 := 1 to len(oGetPrc:aCols)
	
	If oGetPrc:aCols[ix1,len(aHeaderPrc)+1]
		loop
	EndIf
	
	If oGetPrc:aCols[ix1,FG_POSVAR("VVP_DATPRC","aHeaderPrc")] == M->VVP_DATPRC
		nRegPrc ++
		If nRegPrc > 1
			Help("  ",1,"EXISTCHAV")
			Return( .f. )
		EndIf
	Else
		Loop
	EndIf
	
Next

oFolder:nOption := 4
For ix1 := 1 to len(oGetIte:aCols)
	
	If oGetIte:aCols[ix1,len(aHeaderIte)+1]
		loop
	EndIf
	
	If oGetIte:aCols[ix1,FG_POSVAR("VAG_CODIGO","aHeaderIte")] == M->VAG_CODIGO
		nRegIte ++
		If nRegIte > 1
			Help("  ",1,"EXISTCHAV")
			Return( .f. )
		EndIf
	Else
		Loop
	EndIf
	
Next

oFolder:nOption := 5
For ix1 := 1 to len(oGetFat:aCols)
	
	If oGetFat:aCols[ix1,len(aHeaderFat)+1]
		loop
	EndIf
	
	If oGetFat:aCols[ix1,FG_POSVAR("VZP_CODIGO","aHeaderFat")] == M->VZP_CODIGO
		nRegIte ++
		If nRegIte > 1
			Help("  ",1,"EXISTCHAV")
			Return( .f. )
		EndIf
	Else
		Loop
	EndIf
	
Next
oFolder:nOption := 1
Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Fabio               º Data ³  03/01/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Menu						                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {	{ OemToAnsi(STR0001),"AxPesqui", 0 , 1},;  // Pesquisar
					{ OemToAnsi(STR0002),"VA020"   , 0 , 2},;  // Visualizar
					{ OemToAnsi(STR0003),"VA020"   , 0 , 3},;  // Incluir
					{ OemToAnsi(STR0004),"VA020"   , 0 , 4},;  // Alterar
					{ OemToAnsi(STR0005),"VA020"   , 0 , 5},;  // Excluir
					{ STR0019,"VA020REPL"   , 0 , 6}}   // Replicar Comercializa
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA020SEEK ºAutor  ³Fabio               º Data ³  03/01/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Posicionamento nas tabelas                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA020SEEK(nOpc)

Local lRet := .t.
Local aArea := GetArea()
Default nOpc := 1

if nOpc == 1
	dbSelectArea("VE1")
	dbSetOrder(1)
	if (lRet := dbSeek(xFilial("VE1")+M->VV2_CODMAR))
		M->VV2_DESMAR := VE1->VE1_DESMAR
	Endif
ElseIf nOpc == 2
	dbSelectArea("VVR")
	dbSetOrder(2)
	if (lRet := dbSeek(xFilial("VVR")+M->VV2_CODMAR+M->VV2_GRUMOD))
		M->VV2_DESGRU := VVR->VVR_DESCRI
	Endif
ElseIf nOpc == 3
	dbSelectArea("VVX")
	dbSetOrder(1)
	lRet := (dbSeek(xFilial("VVX")+M->VV2_CODMAR+M->VV2_SEGMOD) .AND. FG_EK("VV2"))
Endif

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA020DESC ºAutor  ³Fabio               º Data ³  03/01/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³levanta a descricao do item.                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA020DESC(cCodIte)

Default cCodIte := ""

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA020REPL ºAutor  ³Thiago              º Data ³  24/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Replica campo COMERCIALIZA.                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA020REPL()   
Local cQAlSQL := "SQLVVR"
Local nCntTam := 0 
Local nOpca   := 1  
Private cComerc   := space(10)
Private lMarcar  := .f.
Private oOk 	  := LoadBitmap( GetResources(), "LBTIK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" ) 
Private aGrpMod := {{.f.,"","",""}}  
Private aModVei := {{.f.,"","","","",""}}  
//variaveis controle de janela
Private aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {} 
Private aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 1, 20, .T. , .F. } )  
AAdd( aObjects, { 1, 80, .T. , .T. } )  
AAdd( aObjects, { 1, 80, .T. , .T. } )  

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)

cQuery := "SELECT DISTINCT VVR.VVR_CODMAR , VVR.VVR_GRUMOD , VVR.VVR_DESCRI FROM "+RetSqlName("VVR")+" VVR "
cQuery += "INNER JOIN "+RetSQLName("VV2")+" VV2 ON  VV2.VV2_FILIAL  = VVR.VVR_FILIAL AND VV2.VV2_CODMAR = VVR.VVR_CODMAR AND "
cQuery += "VV2.VV2_GRUMOD = VVR.VVR_GRUMOD AND VV2.D_E_L_E_T_=' ' "
cQuery += "WHERE VVR.VVR_FILIAL='"+xFilial("VVR")+"' AND "
cQuery += "VVR.D_E_L_E_T_=' ' ORDER BY VVR.VVR_CODMAR , VVR.VVR_GRUMOD , VVR.VVR_DESCRI "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )

	if Len(aGrpMod) == 1 .and. Empty(aGrpMod[1,2])
		aGrpMod := {}
	Endif	
	AAdd( aGrpMod, { .f. , ( cQAlSQL )->VVR_CODMAR , ( cQAlSQL )->VVR_GRUMOD , ( cQAlSQL )->VVR_DESCRI } )  

	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )

DEFINE MSDIALOG oDlgMod TITLE STR0019 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

@ aPos[1,1],aPos[1,2] TO aPos[1,3],aPos[1,1]+100 LABEL "" OF oDlgMod PIXEL 
@ aPos[1,1]+005,aPos[1,2]+004 SAY STR0025 OF oDlgMod PIXEL
@ aPos[1,1]+004,aPos[1,2]+039 MSCOMBOBOX oCombo   VAR cComerc ITEMS {"",STR0026,STR0027} SIZE 045,10 OF oDlgMod PIXEL


@ aPos[2,1],aPos[2,2] TO aPos[2,3],aPos[2,4] LABEL STR0020 OF oDlgMod PIXEL 

@ aPos[2,1]+007,aPos[2,2]+001 LISTBOX oLbox1 FIELDS HEADER "",;
					STR0021,; //"Marca      "
					STR0022,; //"Grp Modelo      "
					STR0023; //"Descricao  "
					COLSIZES 10,20,35,40 ;
					SIZE aPos[2,4]-004,(aPos[2,3]-aPos[2,1])-008 PIXEL ON DBLCLICK FS_SELGRP(oLbox1:nAt)
      
oLbox1:SetArray(aGrpMod)
oLbox1:bLine := { || {  IIf(aGrpMod[oLbox1:nAt,1],oOk,oNo) ,;
						  	  aGrpMod[oLbox1:nAt,02] ,;
						  	  aGrpMod[oLbox1:nAt,03] ,;
							  aGrpMod[oLbox1:nAt,04] }}


@ aPos[3,1],aPos[3,2]-005 TO aPos[3,3],aPos[3,4] LABEL STR0024 OF oDlgMod PIXEL 

@ aPos[3,1]+007,aPos[3,2]+001 LISTBOX oLbox2 FIELDS HEADER "",;          
					STR0021,; //"Marca      "
					STR0022,; //"Grp Modelo      "
					STR0024,; //"Grp Modelo      "
					STR0023,; //"Descricao  "
					STR0025; //"Comercializa"
					COLSIZES 10,20,35,30,40,40 ;
					SIZE aPos[3,4]-004,(aPos[3,3]-aPos[3,1])-008 PIXEL ON DBLCLICK FS_SELMOD(oLbox2:nAt)

oLbox2:SetArray(aModVei)
oLbox2:bLine := { || {  IIf(aModVei[oLbox2:nAt,1],oOk,oNo) ,;
						  	  aModVei[oLbox2:nAt,02] ,;
						  	  aModVei[oLbox2:nAt,03] ,;
						  	  aModVei[oLbox2:nAt,04] ,;
						  	  aModVei[oLbox2:nAt,05] ,;
							  aModVei[oLbox2:nAt,06] }}
oLbox2:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lMarcar := !lMarcar , FS_TIK(lMarcar) ) , ) , }

ACTIVATE MSDIALOG oDlgMod CENTER ON INIT EnchoiceBar(oDlgMod,{|| Iif(FS_COMERC(),VA020REPL(),.f.) } , {|| oDlgMod:End() })

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_SELGRP  ºAutor  ³ Thiago            º Data ³  24/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona Grupo do Modelo.                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SELGRP(nLin)   
Local cSQL := "SQLVV2"   
Local _i   := 0

aGrpMod[nLin,1] := !aGrpMod[nLin,1]     

if aGrpMod[nLin,1]
	cQuery := "SELECT VV2.VV2_CODMAR , VV2.VV2_GRUMOD , VV2.VV2_MODVEI , VV2.VV2_DESMOD , VV2.VV2_COMERC "
	cQuery += "FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND "
	cQuery += "VV2.VV2_CODMAR='"+aGrpMod[nLin,2]+"' AND VV2.VV2_GRUMOD = '"+aGrpMod[nLin,3]+"' AND VV2.D_E_L_E_T_=' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQL , .F., .T. )
	While !( cSQL )->( Eof() )
		if Len(aModVei) == 1 .and. Empty(aModVei[1,2])
			aModVei := {}
		Endif	    
		if ( cSQL )->VV2_COMERC == "0"
			cComercializ := STR0027
		Elseif ( cSQL )->VV2_COMERC == "1"
			cComercializ := STR0026
		Else
			cComercializ := ""
		Endif		
		AAdd( aModVei, { .f. , ( cSQL )->VV2_CODMAR , ( cSQL )->VV2_GRUMOD , ( cSQL )->VV2_MODVEI , ( cSQL )->VV2_DESMOD , cComercializ } )  

		( cSQL )->( DbSkip() )
	EndDo
	( cSQL )->( DbCloseArea() )
Else
 	nPos := aScan(aModVei,{|x| x[2]+x[3] == aGrpMod[nLin,2]+aGrpMod[nLin,3]}) 
 	cMarca  := aGrpMod[nLin,2]  
 	cGrpMod := aGrpMod[nLin,3]  
 	While .t. 
	 	nPos := aScan(aModVei,{|x| x[2]+x[3] == aGrpMod[nLin,2]+aGrpMod[nLin,3]}) 
	 	if nPos > 0 
			aDel(aModVei,nPos)
			aSize(aModVei, Len(aModVei)-1)
		Else
			Exit
		Endif	
 	Enddo
Endif

oLbox1:Refresh()   
oLbox2:SetArray(aModVei)
oLbox2:bLine := { || {  IIf(aModVei[oLbox2:nAt,1],oOk,oNo) ,;
						  	  aModVei[oLbox2:nAt,02] ,;
						  	  aModVei[oLbox2:nAt,03] ,;
						  	  aModVei[oLbox2:nAt,04] ,;
						  	  aModVei[oLbox2:nAt,05] ,;
							  aModVei[oLbox2:nAt,06] }}
oLbox2:Refresh()   

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_SELMOD  ºAutor  ³ Thiago            º Data ³  24/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona Modelo.                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SELMOD(nLin)   

aModVei[nLin,1] := !aModVei[nLin,1]     

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TIK     ºAutor  ³ Thiago            º Data ³  24/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Marca listbox.  	                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK( lMarcar )
Local ni := 0
For ni := 1 to Len(aModVei)
	If lMarcar
		aModVei[ni,1] := .t.
	Else
		aModVei[ni,1] := .f.
	EndIf
Next
oLbox2:SetFocus()
oLbox2:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_COMERC ºAutor  ³ Thiago            º Data ³  04/04/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava campo comercializa.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_COMERC() 
Local _y := 0  
Local lMark := .f.


if Alltrim(cComerc) == ""
	MsgStop(STR0028)
	Return(.f.)
Endif
if !MsgYesNo(STR0029,STR0015)
	Return(.f.)
Endif	      
For _y := 1 to Len(aModVei)
	if aModVei[_y,1]
		cQuery := "SELECT R_E_C_N_O_ AS RECVV2 "
		cQuery += "FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND "
		cQuery += "VV2.VV2_CODMAR='"+aModVei[_y,2]+"' AND VV2.VV2_GRUMOD = '"+aModVei[_y,3]+"' AND VV2.VV2_MODVEI = '"+aModVei[_y,4]+"' AND "
		cQuery += "VV2.D_E_L_E_T_=' ' "
		nRec := FM_SQL(cQuery)
		DbSelectArea("VV2")
		DBGoto(nRec)
		RecLock("VV2", .F.)  
		if cComerc == STR0026
			VV2->VV2_COMERC := "1"
		Else
			VV2->VV2_COMERC := "0"
		Endif	        
		MsUnlock()
		lMark := .t.
	Endif		
Next
if !lMark      
	MsgStop(STR0030)
	Return(.f.)
Endif
MsgInfo(STR0031)      

oDlgMod:End()

Return(.t.)