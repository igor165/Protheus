// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 07     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXA050.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "005227_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXA050 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pedido de Veiculos - Cria VV1 ( VV1_SITVEI == '8' )        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculo                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA050()
Private cCadastro := STR0001 // Pedido de Veiculos
Private aRotina   := MenuDef()

mBrowse( 6, 1,22,75,"VQ0")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA050?  ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualizar / Incluir / Alterar / Excluir                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA050V(cAlias,nReg,nOpc)
nOpc := 2
VXA050(cAlias,nReg,nOpc)
Return()

Function VXA050I(cAlias,nReg,nOpc)
nOpc := 3
VXA050(cAlias,nReg,nOpc)
Return()

Function VXA050A(cAlias,nReg,nOpc)
nOpc := 4
VXA050(cAlias,nReg,nOpc)
Return()

Function VXA050E(cAlias,nReg,nOpc)
nOpc := 5
FS_GRAVAR(nOpc)
Return()

Function VXA050(cAlias,nReg,nOpc)
Local cCpos   := ""
Local bCampo  := { |nCPO| Field(nCPO) }
Local i       := 0
Local nCntFor,_ni := 0
Local aVetCpos := {"",""} // { "Campos customizados na Enchoice VQ0" , "Campos customizados na GetDados VQ0" }
//
Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice := {} , aCpoEditEnch , nControlAba := 1
Private aCols := {} , aHeader := {}, aAlter:={}
Private cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk , nLinhas := 0
Private oAuxEnchoice
Private oAuxGetDados
Private oAuxDlg
Private nUsado  	:= 0
Private nRecVQ0 	:= 0
Private cCodigo 	:= ""
Private lVQ0_SEGMOD := VQ0->(ColumnPos("VQ0_SEGMOD")) > 0
//
If ExistBlock("VXA50CPO")
	aVetCpos := ExecBlock("VXA50CPO",.f.,.f.)
//		aVetCpos[1] -> Campos customizados na Enchoice VQ0. Exemplo: "VQ0_XCUST1,VQ0_XCUST2,..."
//		aVetCpos[2] -> Campos customizados na GetDados VQ0. Exemplo: "VQ0_XCUST3,VQ0_XCUST4,..."
Endif
//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VQ0",.t.)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VQ0")
While !Eof().And.(x3_arquivo=="VQ0")
	If X3USO(x3_usado) .And. cNivel>=x3_nivel .And. Alltrim(x3_campo) $ "VQ0_NUMPED,VQ0_DATPED,VQ0_DATCON,VQ0_CODMAR,VQ0_FLUXO,VQ0_DATFLU,"+IIf(nOpc==3,"VQ0_DATPRE,","")+aVetCpos[1]
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+x3_campo):= CriaVar(x3_campo)
	dbSkip()
End
aadd(aCpoEnchoice,"NOUSER") //ESSE PARAMETRO NAO EXIBI CAMPOS DO USUARIO, SOMENTE SE ESTES EXISTIREM NO VETOR.

cCpos := "VQ0_CHAINT,VQ0_CHASSI,VQ0_DATPRE,"
If nOpc == 3
	nOpcE := 3
	nOpcG := 3
	cCpos := "VQ0_QTDVEI,"
Elseif nOpc == 4
	nOpcE := 4
	nOpcG := 4
Else
	nOpcE := 2
	nOpcG := 2
Endif

M->VV1_CODMAR := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VQ0")
While !Eof().And.(x3_arquivo=="VQ0")
	If X3USO(x3_usado) .And. cNivel>=x3_nivel .And. Alltrim(x3_campo) $ "VQ0_MODVEI,VQ0_SEGMOD,VQ0_DESMOD,VQ0_CORVEI,VQ0_DESCOR,"+cCpos+aVetCpos[2]
		nUsado:=nUsado+1
		aAdd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_f3, x3_context, x3cbox(), x3_relacao } )
		&("M->"+x3_campo) := CriaVar(x3_campo)
		IF SX3->X3_VISUAL <> "V"
			Aadd(aAlter,SX3->X3_CAMPO)
		ENDIF
	Endif
	dbSkip()
End
If !Inclui
	DbSelectArea("VQ0")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
EndIf
 
dbSelectArea("VQ0")
dbSetOrder(1)
dbgotop()
dbSeek(xFilial("VQ0")+M->VQ0_CODIGO)

cCodigo := M->VQ0_CODIGO

nSavRec := recno()

ADHeadRec("VQ0",aHeader)

While !eof() .and. xFilial("VQ0")==VQ0->VQ0_FILIAL .and. VQ0->VQ0_CODIGO == M->VQ0_CODIGO
	//////////////////////////////////////////////////////////////////////////////////////
	// Necessario para montar as variaveis utilizadas no RELACAO dos campos de descricao //
	//////////////////////////////////////////////////////////////////////////////////////
	VV1->(DbSetOrder(1))
	VV1->(DbSeek(xFilial("VV1")+VQ0->VQ0_CHAINT))
	M->VQ0_MODVEI := VV1->VV1_MODVEI
	If lVQ0_SEGMOD
		M->VQ0_SEGMOD := VV1->VV1_SEGMOD
	EndIf
	M->VQ0_CORVEI := VV1->VV1_CORVEI

	
	//////////////////////////////////////////////////////////////////////////////////////
	AADD(aCols,Array(Len(aHeader)+1))
	aCols[Len(aCols),len(aHeader)+1] := .f.
	For _ni := 1 to Len(aHeader)
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := VQ0->(RecNo())
			nRecVQ0 := _ni
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VQ0"
		Else
			aCols[Len(aCols),_ni] := IIf(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
		EndIf
	Next
	DbSelectArea("VQ0")
	DbSkip()
EndDo

dbSelectArea("VQ0")
dbgoto(nSavRec)

If Len(aCols) == 0
	
	aCols := {Array(Len(aHeader)+1)}
	aCols[1,Len(aHeader)+1] := .F.
	For _ni := 1 to Len(aHeader)
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
			nRecVQ0 := _ni
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VQ0"
		Else
			aCols[Len(aCols),_ni] := CriaVar(aHeader[_ni,2])
		EndIf
	Next
	
EndIf

If Len( aCols ) > 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo       := STR0001 // Pedido de Veiculos
	cAliasEnchoice:= "VQ0"
	cAliasGetD    := "VQ0"
	cFieldOk      := "VXA050FOK()"
	nLinhas       := 999
	
	FM_Mod3(cTitulo,cAliasEnchoice,cAliasGetD,@aCpoEnchoice,,@aHeader,@aCols,cFieldOk,,,,nOpcE,nOpcG,,oMainWnd,@oAuxDlg,@oAuxEnchoice,@oAuxGetDados,,,,,,,,25,aAlter)
	oAuxGetDados:oBrowse:bChange := {|| FG_MEMVAR( oAuxGetDados:aHeader , oAuxGetDados:aCols , oAuxGetDados:nAt )}
	oAuxGetDados:oBrowse:bDelete := {|| FS_DELETAR( nOpc ) }
	
	ACTIVATE MSDIALOG oAuxDlg ON INIT EnchoiceBar(oAuxDlg,{|| IIf(FS_GRAVAR(nOpc),oAuxDlg:End(),.f.) },{|| oAuxDlg:End() },,)
	
EndIf


Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXA050 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 12/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem do aRotina (MENUDEF)                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {	{STR0006,"AxPesqui"  ,0,1},; // Pesquisar
					{STR0002,"VXA050V"   ,0,2},; // Visualizar
					{STR0003,"VXA050I"   ,0,3},; // Incluir
					{STR0004,"VXA050A"   ,0,4},; // Alterar
					{STR0005,"VXA050E"   ,0,5},; // Excluir
					{STR0021,"VXA050CADV",0,4}}  // Altera Cad.Veiculo
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA050CADV³ Autor ³ Andre Luis Almeida   ³ Data ³ 12/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama alteracao do Cadastro do Veiculo                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA050CADV(cAlias,nReg,nOpc)
Private cCadastro := STR0021 // Altera Cad.Veiculo
Private aMemos  := {{"VV1_OBSMEM","VV1_OBSERV"}}		// CAMPOS VIRTUAIS DE OBSERVACAO
Private aCampos := {}									// CAMPOS QUE SERAO VISTOS NO BROWSE
DbSelectArea("VV1")
DbSetOrder(1)
If DbSeek(xFilial("VV1")+VQ0->VQ0_CHAINT)
	nOpc := 4
	VXA010A("VV1",VV1->(RecNo()),nOpc)
EndIf
cCadastro := STR0001 // Pedido de Veiculos
DbSelectArea("VQ0")
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VX050ALTCHA³ Autor ³ Andre Luis Almeida   ³ Data ³ 12/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ WHEN do VQ0_CHASSI - verifica se pode alterar o chassi     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX050ALTCHA()
Local lRet := .f.
If Altera
	lRet := .t.
	VV1->(DbSetOrder(1))
	If VV1->(DbSeek(xFilial("VV1")+M->VQ0_CHAINT)) .and. !Empty(VV1->VV1_CHASSI)
		lRet := .f.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VX050MARCA³ Autor ³ Andre Luis Almeida   ³ Data ³ 12/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ VALID do VQ0_CODMAR - MARCA a ser utilizada nos SXB's      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX050MARCA()
Local lRet := .f.
If Inclui
	VE1->(DbSetOrder(1))
	If VE1->(DbSeek(xFilial("VE1")+M->VQ0_CODMAR))
		lRet := .t.
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// A variavel M->VV1_CODMAR eh utilizada na SXB consulta padrao 'MCV' (Modelos)                                       //
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		M->VV1_CODMAR := M->VQ0_CODMAR
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Necessario posicionar no 1o.VV2 da Marca para o VV2->VV2_CODMAR ser utilizado na SXB consulta padrao 'VVC' (Cores) //
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		VV2->(DbSetOrder(1))
		VV2->(DbSeek(xFilial("VV2")+M->VQ0_CODMAR))
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA050FOK ³ Autor ³ Andre Luis Almeida   ³ Data ³ 12/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ FieldOk                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA050FOK()
Local ni   := 0
Local lRet := .t.
Local cReadVar := ReadVar()
If cReadVar $ "M->VQ0_MODVEI/M->VQ0_SEGMOD"
	M->VVQ_DESMOD := ""
	If !Empty(M->VQ0_MODVEI)
		lRet := .f.
		If FGX_VV2(M->VQ0_CODMAR, M->VQ0_MODVEI, Iif(lVQ0_SEGMOD,AllTrim(M->VQ0_SEGMOD), ''))
			lRet := .t.
			M->VVQ_DESMOD := VV2->VV2_DESMOD
		EndIf
	EndIf
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VQ0_DESMOD","oAuxGetDados:aHeader")] := M->VVQ_DESMOD
ElseIf cReadVar == "M->VQ0_CORVEI"
	M->VVQ_DESCOR := ""
	If !Empty(M->VQ0_CORVEI)
		lRet := .f.
		VVC->(DbSetOrder(1))
		If VVC->(DbSeek(xFilial("VVC")+M->VQ0_CODMAR+M->VQ0_CORVEI))
			lRet := .t.
			M->VVQ_DESCOR := VVC->VVC_DESCRI
		EndIf
	EndIf
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VQ0_DESCOR","oAuxGetDados:aHeader")] := M->VVQ_DESCOR
ElseIf cReadVar == "M->VQ0_CHASSI"
	M->VQ0_CHASSI := padr(ltrim(M->VQ0_CHASSI),TamSX3("VV1_CHASSI")[1])
	If !Empty(M->VQ0_CHASSI)
		lRet := .f.
		M->VV1_CHASSI := M->VQ0_CHASSI
		If ExistChav("VV1",M->VV1_CHASSI,2,"EXICHASSI")
			M->VV1_CODMAR := M->VQ0_CODMAR
			M->VV1_MODVEI := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VQ0_MODVEI","oAuxGetDados:aHeader")]
			
			If lVQ0_SEGMOD
				M->VV1_SEGMOD := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VQ0_SEGMOD","oAuxGetDados:aHeader")]
			EndIf
			
			M->VV1_FABMOD := ""
			If VEIVA600()
				lRet := .t.
				For ni := 1 to len(oAuxGetDados:aCols)
					If oAuxGetDados:nAt <> ni
						If Alltrim(M->VV1_CHASSI) == Alltrim(oAuxGetDados:aCols[ni,FG_POSVAR("VQ0_CHASSI","oAuxGetDados:aHeader")])
							MsgStop(STR0015,STR0007) // Chassi de Veiculo ja digitado! / Atencao
							lRet := .f.
							Exit
						EndIf
					EndIf
				Next
			EndIf
		EndIf
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GRAVAR ³ Autor ³ Andre Luis Almeida   ³ Data ³ 12/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravar ( Inclusao / Alteracao / Exclusao )                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAVAR(nOpc)
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cFilSALVA := cFilAnt
Local cFilVVA   := ""
Local cQuery    := ""
Local cSQLAlias := "SQLVVA"
Local nQtd      := 0
Local ni        := 0
Local nReg      := 0
Local lRet      := .t.
Local cMsg      := ""
Local aQUltMov  := {}
Local lCriaVQ0  := .t.
Local lTemVV1   := .f.

if nOpc == 3 .or. nOpc == 4
	If ( VQ0->(FieldPos("VQ0_FLUXO ")) > 0 )
		If M->VQ0_FLUXO == "S" .and. Empty(M->VQ0_DATFLU)
			MsgStop(STR0022,STR0007) // Data que devera constar no Fluxo de Caixa nao informada! / Atencao
			Return .f.			
		EndIf	
	EndIf
EndIf

If nOpc == 3 // Inclusao
	If Empty(M->VQ0_NUMPED)
		lRet := .f.
		MsgStop(STR0008,STR0007) // Numero do Pedido nao informado! / Atencao
	EndIf
	If Empty(M->VQ0_DATPED)
		lRet := .f.
		MsgStop(STR0009,STR0007) // Data do Pedido nao informada! / Atencao
	EndIf
	For nReg := 1 to Len(aCpoEnchoice)
		If aCpoEnchoice[nReg] <> "NOUSER"
			If X3Obrigat(aCpoEnchoice[nReg]) .and. Empty(&("M->"+aCpoEnchoice[nReg]))
				Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(aCpoEnchoice[nReg])) + " (" + aCpoEnchoice[nReg] + ")" ,4,1)
				lRet := .f.
				Exit
			EndIf
    	EndIf
	Next
	If lRet
		For nReg := 1 to Len(oAuxGetDados:aCols)
			If !oAuxGetDados:aCols[nReg,Len(oAuxGetDados:aHeader)+1]
				For ni := 1 to Len(oAuxGetDados:aHeader)
					If X3Obrigat(oAuxGetDados:aHeader[ni,2]) .and. Empty(oAuxGetDados:aCols[nReg,FG_POSVAR(oAuxGetDados:aHeader[ni,2],"oAuxGetDados:aHeader")])
						Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(oAuxGetDados:aHeader[ni,2])) + " (" + oAuxGetDados:aHeader[ni,2] + ")" ,4,1)
						lRet := .f.
						Exit
	    			EndIf
				Next
			EndIf
		Next
	EndIf
	If lRet
		For nReg := 1 to Len(oAuxGetDados:aCols)
			If !oAuxGetDados:aCols[nReg,Len(oAuxGetDados:aHeader)+1]
				If Empty(oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_MODVEI","oAuxGetDados:aHeader")])
					lRet := .f.
					MsgStop(STR0010,STR0007) // Modelo de Veiculo nao informado! / Atencao
					Exit
				EndIf
				If Empty(oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_CORVEI","oAuxGetDados:aHeader")])
					lRet := .f.
					MsgStop(STR0011+" "+STR0012+": "+M->VQ0_CODMAR+" "+Alltrim(oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_MODVEI","oAuxGetDados:aHeader")]),STR0007) // Cor do Veiculo nao informada! / Modelo / Atencao
					Exit
				EndIf
				If oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_QTDVEI","oAuxGetDados:aHeader")] == 0
					lRet := .f.
					MsgStop(STR0013+" "+STR0012+": "+M->VQ0_CODMAR+" "+Alltrim(oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_MODVEI","oAuxGetDados:aHeader")])+" "+Alltrim(oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_CORVEI","oAuxGetDados:aHeader")]),STR0007) // Qtde de Veiculos nao informada! / Modelo / Atencao
					Exit
				EndIf
				If !FGX_VV2(M->VQ0_CODMAR, oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_MODVEI","oAuxGetDados:aHeader")], Iif(lVQ0_SEGMOD,oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_SEGMOD","oAuxGetDados:aHeader")],""))
					lRet := .f.
					MsgStop(STR0014+" "+M->VQ0_CODMAR+" "+Alltrim(oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_MODVEI","oAuxGetDados:aHeader")] + " " + Iif(lVQ0_SEGMOD, AllTrim( + oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_SEGMOD","oAuxGetDados:aHeader")]),"")),STR0007) // Modelo de Veiculo nao encontrado! / Atencao
					Exit
				EndIf
				VVC->(DbSetOrder(1))
				If !VVC->(DbSeek(xFilial("VVC")+M->VQ0_CODMAR+oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_CORVEI","oAuxGetDados:aHeader")]))
					lRet := .f.
					MsgStop(STR0016+" "+M->VQ0_CODMAR+" "+Alltrim(oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_CORVEI","oAuxGetDados:aHeader")]),STR0007) // Cor do Veiculo nao encontrada! / Atencao
					Exit
				EndIf
				nQtd++
			EndIf
		Next
	EndIf
	If lRet .and. nQtd > 0
		M->VQ0_CODIGO := GetSXENum("VQ0","VQ0_CODIGO")
		ConfirmSX8()
		For nReg := 1 to len(oAuxGetDados:aCols)
			If !oAuxGetDados:aCols[nReg,Len(oAuxGetDados:aHeader)+1]
				For nQtd := 1 to oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_QTDVEI","oAuxGetDados:aHeader")]
					M->VV1_CHAINT := GetSXENum("VV1","VV1_CHAINT")
					ConfirmSX8()
					//
					DbSelectArea("VQ0")
					RecLock("VQ0",.t.)
					FG_GRAVAR("VQ0")
					FG_GRAVAR("VQ0",oAuxGetDados:aCols,oAuxGetDados:aHeader,nReg) // Variaveis GetDados
					VQ0->VQ0_FILIAL := xFilial("VQ0")
					VQ0->VQ0_CHAINT := M->VV1_CHAINT
					MsUnLock()
					//
					DbSelectArea("VV1")
					RecLock("VV1",.t.)
					VV1->VV1_FILIAL := xFilial("VV1")
					VV1->VV1_CHAINT := M->VV1_CHAINT
					VV1->VV1_CODMAR := M->VQ0_CODMAR
					VV1->VV1_MODVEI := oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_MODVEI","oAuxGetDados:aHeader")]
					If lVQ0_SEGMOD
						VV1->VV1_SEGMOD := oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_SEGMOD","oAuxGetDados:aHeader")]
					EndIf
					VV1->VV1_CORVEI := oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_CORVEI","oAuxGetDados:aHeader")]
					VV1->VV1_SITVEI := "8" // Pedido
					VV1->VV1_ESTVEI := "0" // Novo
					VV1->VV1_FILENT := xFilial("VVF")
					MsUnlock()
				Next
			EndIf
		Next
	EndIf
ElseIf nOpc == 4 // Alteracao
	For nReg := 1 to Len(aSM0)
		cFilAnt := aSM0[nReg]
		cFilVVA += "'"+xFilial("VVA")+"',"
	Next
	cFilAnt := cFilSALVA
	cFilVVA := left(cFilVVA,len(cFilVVA)-1)
	M->VQ0_CODIGO := cCodigo
	//
	For nReg := 1 to Len(aCpoEnchoice)
		If aCpoEnchoice[nReg] <> "NOUSER"
			If X3Obrigat(aCpoEnchoice[nReg]) .and. Empty(&("M->"+aCpoEnchoice[nReg]))
				Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(aCpoEnchoice[nReg])) + " (" + aCpoEnchoice[nReg] + ")" ,4,1)
				lRet := .f.
				Exit
			EndIf
    	EndIf
	Next
	If lRet
		For nReg := 1 to Len(oAuxGetDados:aCols)
			If !oAuxGetDados:aCols[nReg,Len(oAuxGetDados:aHeader)+1]
				For ni := 1 to Len(oAuxGetDados:aHeader)
					If X3Obrigat(oAuxGetDados:aHeader[ni,2]) .and. Empty(oAuxGetDados:aCols[nReg,FG_POSVAR(oAuxGetDados:aHeader[ni,2],"oAuxGetDados:aHeader")])
						Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(oAuxGetDados:aHeader[ni,2])) + " (" + oAuxGetDados:aHeader[ni,2] + ")" ,4,1)
						lRet := .f.
						Exit
	    			EndIf
				Next
			EndIf
		Next
	EndIf
	If lRet 
		For nReg := 1 to len(oAuxGetDados:aCols)
			DbSelectArea("VQ0")
			lTemVV1  := .f.
			lCriaVQ0 := .t.
			If nRecVQ0 > 0 .and. oAuxGetDados:aCols[nReg,nRecVQ0] > 0
				lCriaVQ0 := .f.
		       	DbGoTo(oAuxGetDados:aCols[nReg,nRecVQ0])
				RecLock("VQ0",.f.)
					FG_GRAVAR("VQ0") // Variaveis da Enchoice
					FG_GRAVAR("VQ0",oAuxGetDados:aCols,oAuxGetDados:aHeader,nReg) // Variaveis GetDados
				MsUnLock()
			EndIf
			If !Empty(oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_CHASSI","oAuxGetDados:aHeader")]) .and. !Empty(oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_CHAINT","oAuxGetDados:aHeader")])
				lTemVV1 := .t.
				DbSelectArea("VV1")
				DbSetOrder(1)
				DbSeek(xFilial("VV1")+oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_CHAINT","oAuxGetDados:aHeader")])
				If Empty(VV1->VV1_CHASSI)
					RecLock("VV1",.f.)
						VV1->VV1_CHASSI := ltrim(oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_CHASSI","oAuxGetDados:aHeader")])
					MsUnLock()
					cQuery := "SELECT VVA.R_E_C_N_O_ AS RECVVA FROM "+RetSQLName("VVA")+" VVA "
					cQuery += "WHERE VVA.VVA_FILIAL IN ("+cFilVVA+") AND VVA.VVA_CHAINT='"+VV1->VV1_CHAINT+"' AND VVA.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
					While !(cSQLAlias)->(Eof())
						DbSelectArea("VVA")
						DbGoto( (cSQLAlias)->( RECVVA ) )
						RecLock("VVA",.f.)
						VVA->VVA_CHASSI := VV1->VV1_CHASSI
						MsUnLock()		
						(cSQLAlias)->(dbSkip())
					EndDo
					(cSQLAlias)->(dbCloseArea())
				EndIf
			ElseIf Empty(oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_CHAINT","oAuxGetDados:aHeader")])
				lTemVV1 := .t.
				M->VV1_CHAINT := GetSXENum("VV1","VV1_CHAINT")
				ConfirmSX8()
				DbSelectArea("VV1")
				RecLock("VV1",.t.)
				VV1->VV1_FILIAL := xFilial("VV1")
				VV1->VV1_CHAINT := M->VV1_CHAINT
				VV1->VV1_CODMAR := M->VQ0_CODMAR
				VV1->VV1_MODVEI := oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_MODVEI","oAuxGetDados:aHeader")]
				If lVQ0_SEGMOD
					VV1->VV1_SEGMOD := oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_SEGMOD","oAuxGetDados:aHeader")]
				EndIf
				VV1->VV1_CORVEI := oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_CORVEI","oAuxGetDados:aHeader")]
				VV1->VV1_CHASSI := ltrim(oAuxGetDados:aCols[nReg,FG_POSVAR("VQ0_CHASSI","oAuxGetDados:aHeader")])
				VV1->VV1_SITVEI := "8" // Pedido
				VV1->VV1_ESTVEI := "0" // Novo
				VV1->VV1_FILENT := xFilial("VVF")
				MsUnlock()
			EndIf
			If lCriaVQ0 // Criar VQ0 
				DbSelectArea("VQ0")
				RecLock("VQ0",.t.)
					FG_GRAVAR("VQ0")
					FG_GRAVAR("VQ0",oAuxGetDados:aCols,oAuxGetDados:aHeader,nReg) // Variaveis GetDados
					VQ0->VQ0_FILIAL := xFilial("VQ0")
				MsUnLock()
			EndIf
			If lTemVV1 .and. Empty(VQ0->VQ0_CHAINT)  // Tem VV1 - Atualiza CHAINT
				DbSelectArea("VQ0")
				RecLock("VQ0",.f.)
					VQ0->VQ0_CHAINT := VV1->VV1_CHAINT
				MsUnLock()
			EndIf
		Next
	EndIf
ElseIf nOpc == 5 // Exclusao
	lRet := .f.
	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1")+VQ0->VQ0_CHAINT)
	If !Empty(VV1->VV1_CHASSI)
		aQUltMov := FM_VEIUMOV( VV1->VV1_CHASSI , "E" , )
		If len(aQUltMov) > 0
			MsgStop(STR0019,STR0007) // Impossivel excluir! Ja existe movimentacao de Entrada para o veiculo.  / Atencao
			Return(.f.)
		EndIf
	EndIf
	cMsg := Alltrim(VV1->VV1_CHASSI)+" - "+;
		VQ0->VQ0_CODMAR+" "+;
		Alltrim(VV1->VV1_MODVEI)+" "+;
		Alltrim(VV1->VV1_SEGMOD)+" "+;
		Alltrim(VV1->VV1_CORVEI)+CHR(13)+CHR(10) +;
		STR0001+": "+VQ0->VQ0_NUMPED+" "+Transform(VQ0->VQ0_DATPED,"@D") // Pedido de Veiculos
	If MsgYesNo(STR0017+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsg,STR0007) // Deseja excluir o Veiculo: / Atencao
		cMsg := ""
		lRet := .t.
		For nReg := 1 to Len(aSM0)
			cFilAnt := aSM0[nReg]
			cFilVVA += "'"+xFilial("VVA")+"',"
		Next
		cFilAnt := cFilSALVA
		cFilVVA := left(cFilVVA,len(cFilVVA)-1)
		cQuery  := "SELECT VV9.VV9_STATUS , VVA.R_E_C_N_O_ AS RECVVA FROM "+RetSQLName("VVA")+" VVA "
		cQuery  += "JOIN "+RetSQLName("VV9")+" VV9 ON ( VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.D_E_L_E_T_=' ' ) "
		cQuery  += "WHERE VVA.VVA_FILIAL IN ("+cFilVVA+") AND VVA.VVA_CHAINT='"+VQ0->VQ0_CHAINT+"' AND VVA.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
		While !(cSQLAlias)->(Eof())
			DbSelectArea("VVA")
			DbGoto( (cSQLAlias)->( RECVVA ) )
			If (cSQLAlias)->( VV9_STATUS ) <> "C" // Cancelado
				cMsg += VVA->VVA_FILIAL+" "+VVA->VVA_NUMTRA+" ( "+(cSQLAlias)->( VV9_STATUS )+" )"+CHR(13)+CHR(10)
				lRet := .f.			
			Else
				RecLock("VVA",.f.,.t.)
					DbDelete()
				MsUnLock()
			EndIf
			(cSQLAlias)->(dbSkip())
		EndDo
		(cSQLAlias)->(dbCloseArea())
		If lRet
			DbSelectArea("VV1")
			RecLock("VV1",.f.,.t.)
				DbDelete()
			MsUnLock()
			DbSelectArea("VQ0")
			RecLock("VQ0",.f.,.t.)
				DbDelete()
			MsUnLock()
			MsgInfo(STR0020,STR0007) // Veiculo excluido com sucesso! / Atencao
		ElseIf !Empty(cMsg)
			MsgStop(STR0018+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsg,STR0007) // Impossivel excluir! Veiculo existente no(s) Atendimento(s):  / Atencao
		EndIf
	EndIf
EndIf

if nOpc == 3 .or. nOpc == 4
	If ExistBlock("VXA50VV1") // PE inclusao/alteracao de informacoes na tabela VV1
		ExecBlock("VXA50VV1",.f.,.f.,{nOpc,VV1->VV1_FILIAL,VV1->VV1_CHAINT})
	EndIf
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_DELETAR³ Autor ³ Andre Luis Almeida   ³ Data ³ 12/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Deletar somente na inclusao                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DELETAR(nOpc)
If nOpc == 3
	oAuxGetDados:aCols[oAuxGetDados:nAt,Len(oAuxGetDados:aHeader)+1] := !oAuxGetDados:aCols[oAuxGetDados:nAt,Len(oAuxGetDados:aHeader)+1]
	oAuxGetDados:Refresh()
EndIf
Return()