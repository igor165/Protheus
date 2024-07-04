// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 32     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "VEIVM040.CH"
#include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM040 ³ Autor ³  Manoel               ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Despesas/Receitas com o Veiculo                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcao  = nOpc (Visualizar/Alterar)                        ³±±
±±³          ³ cChaInt = Chassi Interno do Veiculo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM040(nOpcao,cChaInt,cNumTra,cFilEnt,cTraCpa)
Local nOpcVM040 := 2 // Visualizar
Private aRotina := MenuDef()
Private cVarFilEnt := ""
Private cCadastro := OemToAnsi(STR0006) && Lancto de Despesas/Receitas com Veiculos //"Lancto de Despesas com o Veiculo"
Private lVVD_FILENT := VVD->(FieldPos("VVD_FILENT")) <> 0
Default nOpcao  := 0
Default cChaInt := ""
Default cNumTra := ""
Default cFilEnt := ""
Default cTraCpa := ""
VAI->(Dbsetorder(4))
VAI->(DbSeek(xFilial("VAI")+__cUserID))
cTransacao := cNumTra
cFEntrada  := cFilEnt
cTCompra   := cTraCpa

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcao == 0
	DbSelectArea("VV1")
	DbSetOrder(2)
	mBrowse( 6, 1,22,75,"VV1")
Else // Chama automaticamente o ALTERAR/VISUALIZAR do Lancamento de DESPESAS/RECEITAS do Veiculo
	If Type("Inclui") == "U"
		Inclui := ( nOpcao == 3 ) // Variavel utilizada na funcao VM040()
	EndIf
	// ( Incluir ou Alterar ) e Usuario tem permissao para Incluir/Alterar as Despesas/Receitas
	If ( nOpcao == 3 .or. nOpcao == 4 ) .and. VAI->VAI_DESREC == "1"
		nOpcVM040 := 4 // Alterar
	EndIf
	DbSelectArea("VV1")
	DbSetOrder(1)
	If DbSeek(xFilial("VV1")+cChaInt)
		VM040("VV1",VV1->(RECNO()),nOpcVM040) // Alterar
	EndIf
	//
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM040 ³ Autor ³  Manoel               ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Despesas c/Veiculos                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                                 
Function VM040(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects  := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {} 
Local aSizeAut  := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntSiz   := 0
Local nOpcRadio := 1
Local lVeiBloq  := .f.
Local cChaInt   := VV1->VV1_CHAINT
Local oVeiculos := DMS_Veiculo():New()
//Local nTam := 0
//
Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor, _ni
Private aHeadDesp := {}; aHeadRece := {};aColsDesp := {}; aColsRece := {}; aHeader := {}; aCols := {}
Private M->VVD_TIPOPE := ""
Private lAbortPrint := .f.
Private cParPrg     := "3"
Private cTipFat     := "0"
Private cTipSai     := "0"              
Private aTela[0][0], aGets[0]
Private laColsR     := .f.
Private laColsD     := .f.
Private lMSHelpAuto := .f., lMsFinalAuto := .f.
Private lMsErroAuto := .f.
Private oGetDesp
Private oGetRece

nOpcx := nOpc

If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	If VAI->(FieldPos("VAI_DESREC")) <> 0
		If VAI->VAI_DESREC <> "1"
			MsgStop(STR0015,STR0011) // Usuario sem permissao! / Atencao
			Return()
		EndIf
	EndIf

	lVeiBloq := oVeiculos:Bloqueado(cChaInt)
EndIf

If !(lVeiBloq)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PE inicial ( manipula o nOpc da rotina de despesa/receita )      ³
	//³ 0 - nao executa rotina de despesa/receita                        ³
	//³ 2 - visualiza registros de despesa/receita                       ³
	//³ 3 - inclui registros de despesa/receita                          ³
	//³ 4 - altera registros de despesa/receita                          ³
	//³ 5 - exclui registros de despesa/receita                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("VM040INI")
		nOpc := ExecBlock("VM040INI",.f.,.f., { nOpc } )
		If nOpc == 0 // Se retornar 0, nao executa rotina
			Return()
		EndIf
	EndIf

	nOpcE := 2
	if nOpc == 3
		nOpcG := 3
	Elseif nOpc == 4
		nOpcG := 3
	Elseif nOpc == 2
		nOpcG := 2
	Else
		nOpcG := 5
	Endif

	aColsDesp:={}
	aColsRece:={}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria variaveis M->????? da Enchoice                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	if FM_PILHA("VEIXA018")
	inclui := .f.
	Endif   
	if !inclui 
		RegToMemory("VV1",.T.)
	Endif

	aCpoEnchoice  :={}

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("VV1")
	While !Eof().and.(x3_arquivo=="VV1")
		If X3USO(x3_usado).and.x3_nivel>0 .and. Alltrim(X3_Campo) $ "VV1_CHASSI#VV1_CODMAR#VV1_MODVEI#VV1_DESMOD#VV1_CORVEI#VV1_DESCOR#VV1_PLAVEI"
			AADD(aCpoEnchoice,x3_campo)
		Endif
		if inclui
			wVar := "M->"+x3_campo
			&wVar:= CriaVar(x3_campo)
		Endif
		DbSkip()
	End
	DbSelectArea("VV1")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aHeader e aCols da GetDados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsadoD:=0
	nUsadoR:=0
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("VVD")
	aHeadDesp:={}
	aHeadRece:={}
	While !Eof().And.(x3_arquivo=="VVD")

		If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !(Alltrim(x3_campo)+"/" $ [VVD_CHAINT/VVD_TRACPA/VVD_CODCLI/VVD_NOMCLI/VVD_TIPOPE/VVD_LOJACL/VVD_FILUCP/VVD_TRAUCP/])
			nUsadoD++
			Aadd(aHeadDesp,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
			//      if inclui
			wVar  := "M->"+x3_campo
			&wVar := CriaVar(x3_campo)
			//      Endif
		Endif
	
		If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !(Alltrim(x3_campo)+"/" $ [VVD_CHAINT/VVD_TRACPA/VVD_CODFOR/VVD_LOJA/VVD_NOMFOR/VVD_TIPOPE/VVD_FILUCP/VVD_TRAUCP/])
			nUsadoR++
			Aadd(aHeadRece,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
			if inclui .or. altera
				wVar  := "M->"+x3_campo
				&wVar := CriaVar(x3_campo)
			Endif
		Endif
	
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSkip()
	End              

	cVarFilEnt := M->VV1_FILENT
	if Empty(cVarFilEnt)
		cVarFilEnt := xFilial("VVD")
	Endif

	if nOpc <> 2
		nOpcRadio := 2
	Else
		if !Empty(cTransacao) .and. !Empty(cFEntrada) .and. !Empty(cTCompra)
			nOpcRadio := 4
		Endif
	Endif
	FS_FILTRO(@nOpcRadio)

	if nOpc == 3     
		dbSelectArea("VVD")
		dbSetOrder(1)
		if dbSeek(cVarFilEnt+M->VV1_TRACPA+M->VV1_CHAINT)
			nOpc := 4
			nOpcG := 4
			nOpcE := 2
		Endif
	Endif

	aColsCompD := aClone(aColsDesp)
	aColsCompR := aClone(aColsRece)

	If Len(aHeadDesp) > 0 .and. Len(aHeadRece) > 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a Modelo 3                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTitulo       :=OemToAnsi(STR0006) //"Lancto de Despesas com o Veiculo"
		cAliasEnchoice:="VV1"
		cAlias        :="VVD"
		cLinOk        :="FG_OBRIGAT() .And. FS_VExpCpg()"
		cTudOk        :="FS_VExpCpg() .And. FG_OBRIGAT() .And.  AllwaysTrue()"
		cFieldOk      :="FG_MEMVAR() .AND. FS_VALCAMPOS()" 
		nLinhas       := 999
		nOpca         := 0
		n             := 1 

		// Configura os tamanhos dos objetos
		aObjects := {}
		AAdd( aObjects, { 5, 66, .T. , .F. } )  	//Label Superior
		AAdd( aObjects, { 1, 10, .T. , .T. } )  	//list box 

		aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
		aPosObj := MsObjSize (aInfo, aObjects,.F.)    

		DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

		if nOpc <> 2
			EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{aPosObj[1,1]+3,aPosObj[1,2]+1,aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.,,,.t.)
		Else		
			@ aPosObj[1,1]+3, aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,2]+144 LABEL "" OF oDlg PIXEL

			if !Empty(cTransacao) .and. !Empty(cFEntrada) .and. !Empty(cTCompra)    
				nOpcRadio := 4
				@ aPosObj[1,1]+9,aPosObj[1,2]+3 RADIO oRadio VAR nOpcRadio 3D SIZE 145,10 PROMPT STR0016,STR0017,STR0020,STR0018+"("+cTransacao+")" OF oDlg PIXEL ON CHANGE FS_FILTRO(@nOpcRadio) // Todos os lançamentos / Últimos lançamentos / Lançamentos desde a Ultima Entrada por Compra / Lançamentos do Atendimento 
			Else
				@ aPosObj[1,1]+9,aPosObj[1,2]+3 RADIO oRadio VAR nOpcRadio 3D SIZE 145,10 PROMPT STR0016,STR0017,STR0020 OF oDlg PIXEL ON CHANGE FS_FILTRO(@nOpcRadio) // Todos os lançamentos / Últimos lançamentos / Lançamentos desde a Ultima Entrada por Compra
			Endif
			EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{aPosObj[1,1]+3,aPosObj[1,2]+145,aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.,,,.t.)
		Endif
		
		SetEnch("")
		@ aPosObj[2,1],aPosObj[2,2] FOLDER oFolder SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] OF oDlg PROMPTS STR0007,STR0008 PIXEL //"Despesas"###"Receitas"
	
		//Abas do Folder
		FG_INIFOLDER("oFolder")
		FS_ABA(1)
		oGetDesp  := MsGetDados():New(001,001,aPosObj[2,3]-aPosObj[2,1]-20,aPosObj[2,4]-4,nOpcG,cLinOk,cTudOk,"",.T.,,,,nLinhas,cFieldOk,,,,oFolder:aDialogs[1])

		FS_ABA(2)
		oGetRece  := MsGetDados():New(001,001,aPosObj[2,3]-aPosObj[2,1]-20,aPosObj[2,4]-4,nOpcG,cLinOk,cTudOk,"",.T.,,,,nLinhas,cFieldOk,,,,oFolder:aDialogs[2])

		oFolder:bSetOption := {|| FS_SETOPT(oFolder:nOption) }
		oFolder:bChange    := {|| FS_ABA(oFolder:nOption) }
		oGetDesp:oBrowse:bDelete    := {|| fs_delete()}
		ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{ || FS_SETOPT(oFolder:nOption),IIf(FS_VExpCpg().and.VM040TudOK(),Processa({|| FS_GrvVM040(), oDlg:End()}),.F.)},{|| oDlg:End() }), FS_ABA(1))

	Endif
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GrvVM040³ Autor ³  Manoel               ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de Gravacao                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GrvVM040()
Local cQAlias     := "SQLALIAS"
Local cQuery      := ""
Local nRecVVA     := 0
Local lRet        := .t.
Local lDifD       := .f.
Local lDifR       := .f.
Local nCont       := 0
Local nJ          := 0
Local nY          := 0
Local aAuxRetorno := {}
Local nDCliAtu    := 0
Local nRCliAtu    := 0
Local cVVAFil     := ""
//
Local nDR         := 0
Local nValorDR    := 0
Local cSQL        := {}
Local cFiltro     := ""
//
Local lVVD_FILUCP := VVD->(FieldPos("VVD_FILUCP")) <> 0
Local aMovAux     := {}
Local cFilUCp     := "" // Filial da Ultima Entrada por Compra
Local cTraUCp     := "" // Tracpa da Ultima Entrada por Compra
//
Private aColsDR   := {}
Private aHeadDR   := {}

FS_SETOPT(oFolder:nOption)

ProcRegua(3)
lMsHelpAuto := .T.

Begin Transaction

if Len(aColsCompD) < Len(aColsDesp)
	lDifD := .t.
Else
	For nCont = 1 to Len(aColsDesp)
		For nJ = 1 to Len(aHeadDesp)+1
			If aColsDesp[nCont,nJ] != aColsCompD[nCont,nJ]
				lDifD := .t.
				nJ := Len(aHeadDesp)+1
			Endif
		Next
	Next
Endif

if Len(aColsCompR) < Len(aColsRece)
	lDifR := .t.
Else
	For nCont = 1 to Len(aColsRece)
		For nJ = 1 to Len(aHeadRece)+1
			If aColsRece[nCont,nJ] != aColsCompR[nCont,nJ]
				lDifR := .t.
				nJ := Len(aHeadRece)+1
			Endif
		Next
	Next
Endif

If lVVD_FILUCP
	cFilUCp := VV1->VV1_FILENT // Ultima Filial de Entrada
	cTraUCp := VV1->VV1_TRACPA // Ultimo TraCpa de Entrada
	aMovAux := FGX_VEIMOVS( VV1->VV1_CHASSI , "E" , "0" ) // Retorna a ultima Entrada por Compra do Veiculo
	If len(aMovAux) > 0
		cFilUCp := aMovAux[1,2] // Ultima Filial de Entrada por Compra
		cTraUCp := aMovAux[1,3] // Ultimo TraCpa de Entrada por Compra
	EndIf
EndIf

For nDr := 1 to 2

	aColsDR := {}
	aHeadDR := {}
	
	If nDr == 1 .and. nOpcG # 2 .and. lDifD

			aColsDR := aClone(aColsDesp)
			aHeadDR := aClone(aHeadDesp)

		ContasPagar()
		
		IncProc(STR0009) //"Atualizando Dados de Despesas"

	ElseIf nDR == 2 .and. nOpcG # 2 .and. lDifR

			aColsDR := aClone(aColsRece)
			aHeadDR := aClone(aHeadRece)

		ContasReceber()
		
		IncProc(STR0012) //"Atualizando Dados de Receitas"

	Else

		Loop

	Endif

	If lAbortPrint
		If MsgYesNo(OemToAnsi(STR0010),OemToAnsi(STR0011)) //"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
			Help("  ",1,"M160PROABO")
			lRet := .f.
			DisarmTransaction()
			Break
		Else
			lAbortPrint := .F.
		EndIf
	EndIf
	
	For nCont:=1 to len(aColsDR)
		If aColsDR[nCont,FG_POSVAR("VVD_VALOR","aHeadDesp")] == 0 .or. Empty(aColsDR[nCont,FG_POSVAR("VVD_CODIGO","aHeadDR")])
			loop
		Endif

		cVarFilEnt := M->VV1_FILENT
		if Empty(cVarFilEnt)
			cVarFilEnt := xFilial("VVD")
		Endif

		cSQL := "SELECT R_E_C_N_O_ RECVVD"
		cSQL += " FROM " + RetSQLName("VVD") + " VVD "
		If !lVVD_FILENT
			cSQL += " WHERE VVD.VVD_FILIAL = '" + cVarFilEnt + "'" // antes do VVD_FILENT
		Else
			cSQL += " WHERE ( ( VVD.VVD_FILIAL = '" + xFilial("VVD") + "' AND VVD.VVD_FILENT = '" + cVarFilEnt + "' ) " // novos registros
			cSQL += "       OR (VVD.VVD_FILIAL = '" + cVarFilEnt + "' AND VVD.VVD_FILENT = ' ' ) ) " // registro antigos
		Endif
		cSQL += "  AND VVD.VVD_TRACPA  = '" + M->VV1_TRACPA + "'"
		cSQL += "  AND VVD.VVD_CHAINT  = '" + M->VV1_CHAINT + "'"
		cSQL += "  AND VVD.VVD_TIPOPE  = '" + Iif(nDR == 1, "0", "1") + "'"
		cSQL += "  AND VVD.VVD_CODIGO  = '" + aColsDR[nCont, FG_POSVAR("VVD_CODIGO", 'aHeadDR')] + "'"
		cSQL += "  AND VVD.VVD_DATADR  = '" + dtos(aColsDR[nCont, FG_POSVAR("VVD_DATADR", 'aHeadDR')]) + "'"
		cSQL += "  AND VVD.VVD_NUMOSV  = '" + aColsDR[nCont, FG_POSVAR("VVD_NUMOSV", 'aHeadDR')] + "'"
		cSQL += "  AND VVD.D_E_L_E_T_  = ' '"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| PE para alteração da Query para Posicionamento da tabela VVD    |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("VM040PGR")
			aRetPGR := ExecBlock("VM040PGR",.f.,.f., { cSQL , If(nDR==1,"D","R"),nCont, aColsDR[nCont,FG_POSVAR("VVD_VALOR","aHeadDR")] } )
			If ValType(aRetPGR) == "A"
				cSQL     := aRetPGR[1]
				nValorDR := aRetPGR[2]
			Endif
		EndIf                      
		
		nRecNo := FM_SQL(cSQL)      
		if nRecNo == 0 
			wProcura := .f.
		Else
			wProcura := .t.
			VVD->(DbGoto(nRecNo))
		Endif

		If nOpcG == 3 .or. nOpcg == 4
			If aColsDR[nCont,len(aColsDR[nCont])] 
				If wProcura
					RecLock("VVD",.F.,.T.)
					DbDelete()
					MsUnlock()
					WriteSx2("VVD")
				EndIf
				
				If ExistBlock("VM040DEL")
					VM040028_PEVM040DEL(aHeadDR,aColsDR,nDR)
				EndIf  				
			Else
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| PE antes da gravação da VVD	para despesa                         |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("VM040AGD")
					aAuxRetorno := ExecBlock("VM040AGD",.f.,.f., { aHeadDR,aColsDR } )
					If ValType(aAuxRetorno) == "A"
						aHeadDR 	:= aClone(aAuxRetorno[1])
						aColsDR 	:= aClone(aAuxRetorno[2])
						aAuxRetorno := {}
					Endif
				EndIf                      
				
				If nValorDR == 0
					For nY:=1 to len(aColsDR)
						if !aColsDR[nCont,len(aColsDR[nCont])] .and. aColsDR[nY,FG_POSVAR("VVD_CODIGO",'aHeadDR')] == aColsDR[nCont,FG_POSVAR("VVD_CODIGO",'aHeadDR')] .and. dtos(aColsDR[nY,FG_POSVAR("VVD_DATADR",'aHeadDR')]) == dtos(aColsDR[nCont,FG_POSVAR("VVD_DATADR",'aHeadDR')]) .and. aColsDR[nY,FG_POSVAR("VVD_NUMOSV",'aHeadDR')] == aColsDR[nCont,FG_POSVAR("VVD_NUMOSV",'aHeadDR')] 
							nValorDR += aColsDR[nY,FG_POSVAR("VVD_VALOR",'aHeadDR')] 
						Endif					
					Next
				Endif
								
				RecLock("VVD",If(wProcura,.F.,.T.))
				FG_GRAVAR("VVD",aColsDR,aHeadDR,nCont)
				VVD->VVD_TIPOPE := Iif(nDR == 1, "0", "1")
				If lVVD_FILENT
					VVD->VVD_FILIAL := xFilial("VVD")
					VVD->VVD_FILENT := VV1->VV1_FILENT
				Else
					VVD->VVD_FILIAL := VV1->VV1_FILENT
				Endif
				VVD->VVD_CHAINT := VV1->VV1_CHAINT
				VVD->VVD_TRACPA := VV1->VV1_TRACPA
				VVD->VVD_VALOR  := nValorDR
				If FG_POSVAR("VVD_EXPCPG","aHeadDR") > 0
					VVD->VVD_EXPCPG := aColsDR[nCont,FG_POSVAR("VVD_EXPCPG","aHeadDR")] //'1'
				EndIf
				If lVVD_FILUCP
					VVD->VVD_FILUCP := cFilUCp // Filial da ultima Entrada por Compra
					VVD->VVD_TRAUCP := cTraUCp // Tracpa da ultima Entrada por Compra
				EndIf
				MsUnlock()
			Endif
		Endif
		nValorDR := 0 
	Next

Next

If nOpcG == 3 .or. nOpcg == 4
    //
	cVarFilEnt := VV1->VV1_FILENT
	if Empty(cVarFilEnt)
		cVarFilEnt := xFilial("VVD")
	Endif
	cFiltro := "SELECT SUM(VVD_VALOR) AS VALOR FROM "+RetSQLName("VVD")
	If !lVVD_FILENT
		cFiltro += " WHERE VVD_FILIAL = '" + cVarFilEnt + "'" // antes do VVD_FILENT
	Else
		cFiltro += " WHERE ( ( VVD_FILIAL = '" + xFilial("VVD") + "' AND VVD_FILENT = '" + cVarFilEnt + "' ) " // novos registros
		cFiltro += "       OR (VVD_FILIAL = '" + cVarFilEnt + "' AND VVD_FILENT = ' ' ) ) " // registro antigos
	Endif
	cFiltro += " AND VVD_TRACPA='"+VV1->VV1_TRACPA+"' "
	cFiltro += " AND VVD_CHAINT='"+VV1->VV1_CHAINT+"' "
	cFiltro += " AND D_E_L_E_T_=' ' "

	nDCliAtu := FM_SQL(cFiltro+"AND VVD_TIPOPE='0'")
	nRCliAtu := FM_SQL(cFiltro+"AND VVD_TIPOPE='1'")
	//
	DbSelectArea("VVA")
	DbSetOrder(1)
	nRecVVA := VVA->(RecNo())
	////////////////////////////////////////
	// Levanta todas as Filiais do VVA    //
	////////////////////////////////////////
	cVVAFil := ""
	cQuery  := "SELECT DISTINCT VVA_FILIAL FROM "+RetSQLName("VVA")+" WHERE D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	While !( cQAlias )->( Eof() )
		cVVAFil += "'"+( cQAlias )->( VVA_FILIAL )+"',"
		( cQAlias )->( dbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
	cVVAFil := IIf(!Empty(cVVAFil),left(cVVAFil,len(cVVAFil)-1),"'"+xFilial("VVA")+"'")
	//
	cQuery := "SELECT VVA.R_E_C_N_O_ RECVVA FROM "+RetSqlName("VVA")+" VVA "
	cQuery += "WHERE VVA.VVA_FILIAL IN ("+cVVAFil+") AND VVA.VVA_CHAINT='"+VV1->VV1_CHAINT+"' AND "
	cQuery += "VVA.VVA_FILENT='"+cVarFilEnt+"' AND VVA.VVA_TRACPA='"+VV1->VV1_TRACPA+"' AND VVA.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	Do While !( cQAlias )->( Eof() )
		DbSelectArea("VVA")
		DbGoTo(( cQAlias )->( RECVVA ))
		RecLock("VVA",.f.)
			VVA->VVA_DESVEI := nDCliAtu
			VVA->VVA_RECVEI := nRCliAtu
			VVA->VVA_TOTDES := VVA->VVA_DESVEI+VVA->VVA_DESCLI+VVA->VVA_SEGVIA+VVA->VVA_VALASS+VVA->VVA_VALREV+VVA->VVA_ASSIMP+VVA->VVA_DESFIX
			VVA->VVA_LUCLQ1 := VVA->VVA_LUCBRU-VVA->VVA_JUREST-VVA->VVA_ACESSO-VVA->VVA_VDESCO-VVA->VVA_DESCLI-VVA->VVA_SEGVIA-VVA->VVA_VALASS-VVA->VVA_VALREV-VVA->VVA_DESVEI-VVA->VVA_ASSIMP-VVA->VVA_COMVDE-VVA->VVA_COMGER-VVA->VVA_COMPAT
			VVA->VVA_LUCLQ2 := VVA->VVA_LUCLQ1-VVA->VVA_DESFIX+(VVA->VVA_REDCUS+VVA->VVA_RECVEI-VVA->VVA_DSPFIN)
		MsUnlock()
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
	//
	DbSelectArea("VVA")
	If nRecVVA > 0
		DbGoTo(nRecVVA)
	EndIf
	//
	If ExistBlock("VM040ALT")
		For nDr := 1 to 2
			If nDr == 1
				VM040038_PEVM040ALT(aHeadDesp,aColsDesp,nDr)
			Else
				VM040038_PEVM040ALT(aHeadRece,aColsRece,nDr)
			EndIf
		Next
	EndIf                      

Elseif nOpcG == 5
	if (Len(aColsDesp) > 1) .or. (Len(aColsDesp) == 1 .and. !Empty(aColsDesp[1,FG_POSVAR("VVD_DATADR","aHeadDesp")]))
		For nCont = 1 to Len(aColsDesp)
			If aColsDesp[nCont,FG_POSVAR("VVD_EXPCPG","aHeadDesp")] == "1"
				aVetDesp := {}
				aAdd(aVetDesp,{"E2_FILIAL"   ,xFilial("SE2"),nil}) 
				aAdd(aVetDesp,{"E2_PREFIXO"  ,aColsDesp[nCont,FG_POSVAR("VVD_SERNFI","aHeadDesp")],nil}) // C3
				aAdd(aVetDesp,{"E2_NUM"      ,aColsDesp[nCont,FG_POSVAR("VVD_NUMTIT","aHeadDesp")],nil}) // C6
				aAdd(aVetDesp,{"E2_TIPO"     ,aColsDesp[nCont,FG_POSVAR("VVD_TIPTIT","aHeadDesp")],nil}) // C3
				aAdd(aVetDesp,{"E2_NATUREZ"  ,aColsDesp[nCont,FG_POSVAR("VVD_NATURE","aHeadDesp")],nil}) // C10
				aAdd(aVetDesp,{"E2_PARCELA"  ,aColsDesp[nCont,FG_POSVAR("VVD_NUMPAR","aHeadDesp")],nil})   
				aAdd(aVetDesp,{"E2_FORNECE"  ,aColsDesp[nCont,FG_POSVAR("VVD_CODFOR","aHeadDesp")],nil}) // C6
				aAdd(aVetDesp,{"E2_LOJA"     ,aColsDesp[nCont,FG_POSVAR("VVD_LOJA"  ,"aHeadDesp")],nil}) // C2
				aAdd(aVetDesp,{"E2_EMISSAO"  ,aColsDesp[nCont,FG_POSVAR("VVD_DATADR","aHeadDesp")],nil}) // D8
				aAdd(aVetDesp,{"E2_VENCTO"   ,aColsDesp[nCont,FG_POSVAR("VVD_DATVEN","aHeadDesp")],nil}) // D8
				aAdd(aVetDesp,{"E2_VALOR"    ,aColsDesp[nCont,FG_POSVAR("VVD_VALOR" ,"aHeadDesp")],nil}) // N17 2
				aAdd(aVetDesp,{"E2_VLCRUZ"   ,aColsDesp[nCont,FG_POSVAR("VVD_VALOR" ,"aHeadDesp")],nil}) // N17 2   //Incluido pelo Alfredo
				If Len(aVetDesp) > 0 
					pergunte("FIN050",.F.)
					MSExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp,,5)
					if LMsErroAuto
						Help(" ",1,"ERROGERACP") // Erro na Geracao do Contas a Pagar
						DisarmTransaction()
						Break
					Endif 
				Endif	
	      Endif
		Next	    
	Endif
	if (Len(aColsRece) > 1) .or. (Len(aColsRece) == 1 .and. !Empty(aColsRece[1,FG_POSVAR("VVD_DATADR","aHeadDesp")]))
		For nCont = 1 to Len(aColsRece)  
			If aColsRece[nCont,FG_POSVAR("VVD_EXPCPG","aHeadRece")] == "1"
				aTitulo := {}
				aAdd(aTitulo,{"E1_PREFIXO",aColsRece[nCont,FG_POSVAR("VVD_SERNFI","aHeadRece")],nil})
				aadd(aTitulo,{"E1_NUM"    ,aColsRece[nCont,FG_POSVAR("VVD_NUMTIT","aHeadRece")],nil})
				aadd(aTitulo,{"E1_PARCELA",aColsRece[nCont,FG_POSVAR("VVD_NUMPAR","aHeadRece")],nil})
				aadd(aTitulo,{"E1_TIPO"   ,aColsRece[nCont,FG_POSVAR("VVD_TIPTIT","aHeadRece")],nil})
				aadd(aTitulo,{"E1_NATUREZ",aColsRece[nCont,FG_POSVAR("VVD_NATURE","aHeadRece")],nil})
				aadd(aTitulo,{"E1_CLIENTE",aColsRece[nCont,FG_POSVAR("VVD_CODCLI","aHeadRece")],nil})
				aadd(aTitulo,{"E1_LOJA"   ,aColsRece[nCont,FG_POSVAR("VVD_LOJACL","aHeadRece")],nil})
				aadd(aTitulo,{"E1_EMISSAO",aColsRece[nCont,FG_POSVAR("VVD_DATADR","aHeadRece")],nil})
				aadd(aTitulo,{"E1_VENCTO" ,aColsRece[nCont,FG_POSVAR("VVD_DATVEN","aHeadRece")],nil})
				aadd(aTitulo,{"E1_VENCREA",aColsRece[nCont,FG_POSVAR("VVD_DATVEN","aHeadRece")],nil})
				aadd(aTitulo,{"E1_VALOR"  ,aColsRece[nCont,FG_POSVAR("VVD_VALOR" ,"aHeadRece")],nil})
			
				If Len(aTitulo) > 0
					pergunte("FIN040",.F.)
					MSExecAuto({|x,y| FINA040(x,y)},aTitulo,5)
					If lMsErroAuto
						DisarmTransaction()
						Break
					EndIf 
				EndIf
			Endif	
		Next
	Endif

	cSQL := "SELECT R_E_C_N_O_ RECVVD"
	cSQL += " FROM " + RetSQLName("VVD") + " VVD "
	If !lVVD_FILENT
		cSQL += " WHERE VVD.VVD_FILIAL = '" + cVarFilEnt + "'" // antes do VVD_FILENT
	Else
		cSQL += " WHERE ( ( VVD.VVD_FILIAL = '" + xFilial("VVD") + "' AND VVD.VVD_FILENT = '" + cVarFilEnt + "' ) " // novos registros
		cSQL += "       OR (VVD.VVD_FILIAL = '" + cVarFilEnt + "' AND VVD.VVD_FILENT = ' ' ) ) " // registro antigos
	Endif
	cSQL += "  AND VVD.VVD_TRACPA  = '" + M->VV1_TRACPA + "'"
	cSQL += "  AND VVD.VVD_CHAINT  = '" + M->VV1_CHAINT + "'"
	cSQL += "  AND VVD.D_E_L_E_T_  = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cQAlias, .T., .T. )
	While !( cQAlias )->( Eof() )
		dbSelectArea("VVD")
		DbGoTo(( cQAlias )->( RECVVD ))
		RecLock("VVD",.F.,.T.)
		DbDelete()
		MsUnlock()
		WriteSx2("VVD")
		( cQAlias )->( dbSkip() )
	Enddo	

	If ExistBlock("VM040DEL")
		For nDr := 1 to 2
			If nDr == 1
				VM040028_PEVM040DEL(aHeadDesp,aColsDesp,nDr)
			Else
				VM040028_PEVM040DEL(aHeadRece,aColsRece,nDr)
			EndIf
		Next
	EndIf   
	( cQAlias )->( dbCloseArea() )
Endif

End Transaction

if lMsErroAuto
	MostraErro()
	lMSHelpAuto := .f.
	lMSErroAuto := .f.
	lRet := .f.
Endif

Return(lRet)

//////////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ContasPagar ³ Autor ³  Manoel               ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Contas a Pagar.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ContasPagar()

Local lRet      := .t.
Local aVetDesp  := {}
Local i  
Local lExcluido := .f.
Local cSQL      := ""
 
IncProc(STR0013) //"Gerando Contas a Pagar"
If lAbortPrint
	If MsgYesNo(OemToAnsi(STR0010),OemToAnsi(STR0011)) // Tem certeza que deseja abortar esta operacao ? / Atencao
		Help("  ",1,"M160PROABO")
		lRet := .f.
		DisarmTransaction()
		Break
	Else
		lAbortPrint := .F.
	EndIf
EndIf

if nOpcG # 3
	DbSelectArea("VVD")
	If FG_POSVAR("VVD_EXPCPG","aHeadDesp") > 0
		For i:=1 to Len(aColsDesp)
			If aColsDesp[i,FG_POSVAR("VVD_EXPCPG","aHeadDesp")] == "1" .and. aColsDesp[i,len(aColsDesp[i])] // Deletar o registro no contas a pagar
				aVetDesp:={}
				cVarFilEnt := VV1->VV1_FILENT
				if Empty(cVarFilEnt)
					cVarFilEnt := xFilial("VVD")
				Endif
				If !lVVD_FILENT
					lKey := VVD->(DbSeek(cVarFilEnt+VV1->VV1_TRACPA+VV1->VV1_CHAINT+"0"+aColsDesp[i,FG_POSVAR("VVD_CODIGO",'aHeadDesp')]+dtos(aColsDesp[i,FG_POSVAR("VVD_DATADR",'aHeadDesp')])))
				Else
					cSQL := "SELECT R_E_C_N_O_ RECVVD"
					cSQL += " FROM " + RetSQLName("VVD") + " VVD "
					cSQL += " WHERE ( ( VVD.VVD_FILIAL = '" + xFilial("VVD") + "' AND VVD.VVD_FILENT = '" + cVarFilEnt + "' ) " // novos registros
					cSQL += "       OR (VVD.VVD_FILIAL = '" + cVarFilEnt + "' AND VVD.VVD_FILENT = ' ' ) ) " // registro antigos
					cSQL += "  AND VVD.VVD_TRACPA  = '" + VV1->VV1_TRACPA + "'"
					cSQL += "  AND VVD.VVD_CHAINT  = '" + VV1->VV1_CHAINT + "'"
					cSQL += "  AND VVD.VVD_TIPOPE  = '0'"
					cSQL += "  AND VVD.VVD_CODIGO  = '" + aColsDesp[i,FG_POSVAR("VVD_CODIGO",'aHeadDesp')] + "'"
					cSQL += "  AND VVD.VVD_DATADR  = '" + dtos(aColsDesp[i,FG_POSVAR("VVD_DATADR",'aHeadDesp')]) + "'"
					cSQL += "  AND VVD.D_E_L_E_T_  = ' '"
					If FM_SQL(cSQL) > 0
						lKey := .t.
					Endif
				Endif
				if lKey
					aAdd(aVetDesp,{"E2_FILIAL"   ,xFilial("SE2"),nil}) 
					aAdd(aVetDesp,{"E2_PREFIXO"  ,aColsDesp[i,FG_POSVAR("VVD_SERNFI","aHeadDesp")],nil}) // C3
					aAdd(aVetDesp,{"E2_NUM"      ,aColsDesp[i,FG_POSVAR("VVD_NUMTIT","aHeadDesp")],nil}) // C6
					aAdd(aVetDesp,{"E2_TIPO"     ,aColsDesp[i,FG_POSVAR("VVD_TIPTIT","aHeadDesp")],nil}) // C3
					aAdd(aVetDesp,{"E2_NATUREZ"  ,aColsDesp[i,FG_POSVAR("VVD_NATURE","aHeadDesp")],nil}) // C10
					aAdd(aVetDesp,{"E2_PARCELA"  ,aColsDesp[i,FG_POSVAR("VVD_NUMPAR","aHeadDesp")],nil})   
					aAdd(aVetDesp,{"E2_FORNECE"  ,aColsDesp[i,FG_POSVAR("VVD_CODFOR","aHeadDesp")],nil}) // C6
					aAdd(aVetDesp,{"E2_LOJA"     ,aColsDesp[i,FG_POSVAR("VVD_LOJA"  ,"aHeadDesp")],nil}) // C2
					aAdd(aVetDesp,{"E2_EMISSAO"  ,aColsDesp[i,FG_POSVAR("VVD_DATADR","aHeadDesp")],nil}) // D8
					aAdd(aVetDesp,{"E2_VENCTO"   ,aColsDesp[i,FG_POSVAR("VVD_DATVEN","aHeadDesp")],nil}) // D8
					aAdd(aVetDesp,{"E2_VALOR"    ,aColsDesp[i,FG_POSVAR("VVD_VALOR" ,"aHeadDesp")],nil}) // N17 2
					aAdd(aVetDesp,{"E2_VLCRUZ"   ,aColsDesp[i,FG_POSVAR("VVD_VALOR" ,"aHeadDesp")],nil}) // N17 2   //Incluido pelo Alfredo
					If Len(aVetDesp) > 0 
						pergunte("FIN050",.F.)
						MSExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp,,5)
						if LMsErroAuto
							Help(" ",1,"ERROGERACP") // Erro na Geracao do Contas a Pagar
							DisarmTransaction()
							Break
						Endif 
						lExcluido := .t.
					Endif
				Endif
			Endif
		Next
	Endif
Endif

DbSelectArea("VVD")
If FG_POSVAR("VVD_GERTIT","aHeadDesp") > 0
	For i:=1 to Len(aColsDesp)
		aVetDesp:={}
		if aColsDesp[i,len(aColsDesp[i])] .and. !lExcluido //aColsDesp Deletado     
 			if !Empty(aColsDesp[i,FG_POSVAR("VVD_SERNFI","aHeadDesp")]+aColsDesp[i,FG_POSVAR("VVD_NUMTIT","aHeadDesp")])
				dbSelectArea("SE2")
				dbSetOrder(1)
				if !dbSeek(xFilial("SE2")+aColsDesp[i,FG_POSVAR("VVD_SERNFI","aHeadDesp")]+aColsDesp[i,FG_POSVAR("VVD_NUMTIT","aHeadDesp")]+aColsDesp[i,FG_POSVAR("VVD_NUMPAR","aHeadDesp")]+;
								aColsDesp[i,FG_POSVAR("VVD_TIPTIT","aHeadDesp")]+aColsDesp[i,FG_POSVAR("VVD_CODFOR","aHeadDesp")]+aColsDesp[i,FG_POSVAR("VVD_LOJA"  ,"aHeadDesp")])
					Loop
				Endif
			Else
				Loop
			Endif		
			aAdd(aVetDesp,{"E2_FILIAL"   ,xFilial("SE2"),nil}) 
			aAdd(aVetDesp,{"E2_PREFIXO"  ,aColsDesp[i,FG_POSVAR("VVD_SERNFI","aHeadDesp")],nil}) // C3
			aAdd(aVetDesp,{"E2_NUM"      ,aColsDesp[i,FG_POSVAR("VVD_NUMTIT","aHeadDesp")],nil}) // C6
			aAdd(aVetDesp,{"E2_TIPO"     ,aColsDesp[i,FG_POSVAR("VVD_TIPTIT","aHeadDesp")],nil}) // C3
			aAdd(aVetDesp,{"E2_NATUREZ"  ,aColsDesp[i,FG_POSVAR("VVD_NATURE","aHeadDesp")],nil}) // C10
			aAdd(aVetDesp,{"E2_PARCELA"  ,aColsDesp[i,FG_POSVAR("VVD_NUMPAR","aHeadDesp")],nil})  
			aAdd(aVetDesp,{"E2_FORNECE"  ,aColsDesp[i,FG_POSVAR("VVD_CODFOR","aHeadDesp")],nil}) // C6
			aAdd(aVetDesp,{"E2_LOJA"     ,aColsDesp[i,FG_POSVAR("VVD_LOJA"  ,"aHeadDesp")],nil}) // C2
			aAdd(aVetDesp,{"E2_EMISSAO"  ,aColsDesp[i,FG_POSVAR("VVD_DATADR","aHeadDesp")],nil}) // D8
			aAdd(aVetDesp,{"E2_VENCTO"   ,aColsDesp[i,FG_POSVAR("VVD_DATVEN","aHeadDesp")],nil}) // D8
			aAdd(aVetDesp,{"E2_VALOR"    ,aColsDesp[i,FG_POSVAR("VVD_VALOR" ,"aHeadDesp")],nil}) // N17 2
			aAdd(aVetDesp,{"E2_VLCRUZ"   ,aColsDesp[i,FG_POSVAR("VVD_VALOR" ,"aHeadDesp")],nil}) // N17 2   //Incluido pelo Alfredo
			If Len(aVetDesp) > 0 
				pergunte("FIN050",.F.)
				MSExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp,,5)
				if LMsErroAuto
					Help(" ",1,"ERROGERACP") // Erro na Geracao do Contas a Pagar
					DisarmTransaction()
					Break
				Endif 
			Endif
			loop
		Endif	
		
		If aColsDesp[i,FG_POSVAR("VVD_GERTIT","aHeadDesp")] == "1" .and. aColsDesp[i,FG_POSVAR("VVD_EXPCPG","aHeadDesp")] <> "1"
			aAdd(aVetDesp,{"E2_PREFIXO"  ,aColsDesp[i,FG_POSVAR("VVD_SERNFI","aHeadDesp")],nil}) // C1
			aAdd(aVetDesp,{"E2_NUM"      ,aColsDesp[i,FG_POSVAR("VVD_NUMTIT","aHeadDesp")],nil}) // C6
			aAdd(aVetDesp,{"E2_TIPO"     ,aColsDesp[i,FG_POSVAR("VVD_TIPTIT","aHeadDesp")],nil}) // C3
			aAdd(aVetDesp,{"E2_NATUREZ"  ,aColsDesp[i,FG_POSVAR("VVD_NATURE","aHeadDesp")],nil}) // C10
			aAdd(aVetDesp,{"E2_PARCELA"  ,aColsDesp[i,FG_POSVAR("VVD_NUMPAR","aHeadDesp")],nil}) 
			aAdd(aVetDesp,{"E2_FORNECE"  ,aColsDesp[i,FG_POSVAR("VVD_CODFOR","aHeadDesp")],nil}) // C6
			aAdd(aVetDesp,{"E2_LOJA"     ,aColsDesp[i,FG_POSVAR("VVD_LOJA"  ,"aHeadDesp")],nil}) // C2
			aAdd(aVetDesp,{"E2_EMISSAO"  ,aColsDesp[i,FG_POSVAR("VVD_DATADR","aHeadDesp")],nil}) // D8
			aAdd(aVetDesp,{"E2_VENCTO"   ,aColsDesp[i,FG_POSVAR("VVD_DATVEN","aHeadDesp")],nil}) // D8
			aAdd(aVetDesp,{"E2_VALOR"    ,aColsDesp[i,FG_POSVAR("VVD_VALOR" ,"aHeadDesp")],nil}) // N17 2
			aAdd(aVetDesp,{"E2_VLCRUZ"   ,aColsDesp[i,FG_POSVAR("VVD_VALOR" ,"aHeadDesp")],nil}) // N17 2   //Incluido pelo Alfredo
			If Len(aVetDesp) > 0
				pergunte("FIN050",.F.)
				MSExecAuto({|x| FINA050(x)},aVetDesp)
				if LMsErroAuto
					Help(" ",1,"ERROGERACP") // Erro na Geracao do Contas a Pagar
					DisarmTransaction()
					Break
				Endif
				aColsDesp[i,FG_POSVAR("VVD_EXPCPG","aHeadDesp")] := "1"
			Endif
		Endif
	Next
Endif

Return(lRet)

////////////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ContasReceber³ Autor ³  Manoel               ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Contas a Receber.                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßÜßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ContasReceber()

Local lRet    := .t.
Local aTitulo := {}
Local i 
Local lExcluido := .f.

IncProc(STR0014) //"Gerando Contas a Receber"
If lAbortPrint
	If MsgYesNo(OemToAnsi(STR0010),OemToAnsi(STR0011)) //"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
		Help("  ",1,"M160PROABO")
		lRet := .f.
		DisarmTransaction()
		Break
	Else
		lAbortPrint := .F.
	EndIf
EndIf

if nOpcG # 3
	DbSelectArea("VVD")
	If FG_POSVAR("VVD_EXPCPG","aHeadRece") > 0
		For i:=1 to Len(aColsRece)  
			if aColsRece[i,Len(aColsRece[i])]
				Loop
			Endif	
			If aColsRece[i,FG_POSVAR("VVD_EXPCPG","aHeadRece")] == "1" .and. aColsRece[i,len(aColsRece[i])]
				aTitulo:={}
				cVarFilEnt := VV1->VV1_FILENT
				if Empty(cVarFilEnt)
					cVarFilEnt := xFilial("VVD")
				Endif
				If !lVVD_FILENT
					lKey := VVD->(DbSeek(cVarFilEnt+VV1->VV1_TRACPA+VV1->VV1_CHAINT+"1"+aColsRece[i,FG_POSVAR("VVD_CODIGO")]+dtos(aColsRece[i,FG_POSVAR("VVD_DATADR")])))
				Else
					cSQL := "SELECT R_E_C_N_O_ RECVVD"
					cSQL += " FROM " + RetSQLName("VVD") + " VVD "
					cSQL += " WHERE ( ( VVD.VVD_FILIAL = '" + xFilial("VVD") + "' AND VVD.VVD_FILENT = '" + cVarFilEnt + "' ) " // novos registros
					cSQL += "       OR (VVD.VVD_FILIAL = '" + cVarFilEnt + "' AND VVD.VVD_FILENT = ' ' ) ) " // registro antigos
					cSQL += "  AND VVD.VVD_TRACPA  = '" + VV1->VV1_TRACPA + "'"
					cSQL += "  AND VVD.VVD_CHAINT  = '" + VV1->VV1_CHAINT + "'"
					cSQL += "  AND VVD.VVD_TIPOPE  = '1'"
					cSQL += "  AND VVD.VVD_CODIGO  = '" + aColsRece[i,FG_POSVAR("VVD_CODIGO",'aHeadDesp')] + "'"
					cSQL += "  AND VVD.VVD_DATADR  = '" + dtos(aColsRece[i,FG_POSVAR("VVD_DATADR",'aHeadDesp')]) + "'"
					cSQL += "  AND VVD.D_E_L_E_T_  = ' '"
					If FM_SQL(cSQL) > 0
						lKey := .t.
					Endif
				Endif
				if lKey
					aAdd(aTitulo,{"E1_PREFIXO",aColsRece[i,FG_POSVAR("VVD_SERNFI","aHeadRece")],nil})
					aadd(aTitulo,{"E1_NUM"    ,aColsRece[i,FG_POSVAR("VVD_NUMTIT","aHeadRece")],nil})
					aadd(aTitulo,{"E1_PARCELA",aColsRece[i,FG_POSVAR("VVD_NUMPAR","aHeadRece")],nil})
					aadd(aTitulo,{"E1_TIPO"   ,aColsRece[i,FG_POSVAR("VVD_TIPTIT","aHeadRece")],nil})
					aadd(aTitulo,{"E1_NATUREZ",aColsRece[i,FG_POSVAR("VVD_NATURE","aHeadRece")],nil})
					aadd(aTitulo,{"E1_CLIENTE",aColsRece[i,FG_POSVAR("VVD_CODCLI","aHeadRece")],nil})
					aadd(aTitulo,{"E1_LOJA"   ,aColsRece[i,FG_POSVAR("VVD_LOJACL","aHeadRece")],nil})
					aadd(aTitulo,{"E1_EMISSAO",aColsRece[i,FG_POSVAR("VVD_DATADR","aHeadRece")],nil})
					aadd(aTitulo,{"E1_VENCTO" ,aColsRece[i,FG_POSVAR("VVD_DATVEN","aHeadRece")],nil})
					aadd(aTitulo,{"E1_VENCREA",aColsRece[i,FG_POSVAR("VVD_DATVEN","aHeadRece")],nil})
					aadd(aTitulo,{"E1_VALOR"  ,aColsRece[i,FG_POSVAR("VVD_VALOR" ,"aHeadRece")],nil})
					
					If Len(aTitulo) > 0
						pergunte("FIN040",.F.)
						MSExecAuto({|x,y| FINA040(x,y)},aTitulo,5)
						If lMsErroAuto
							DisarmTransaction()
							Break
						EndIf 
						lExcluido := .t.
					EndIf
				Endif
			Endif
		Next
	Endif
Endif

DbSelectArea("VVD")
If FG_POSVAR("VVD_EXPCPG","aHeadRece") > 0
	For i:=1 to Len(aColsRece)
		aTitulo:={}
		if aColsRece[i,len(aColsRece[i])] .and. !lExcluido //aColsRece Deletado   
 			if !Empty(aColsRece[i,FG_POSVAR("VVD_SERNFI","aHeadDesp")]+aColsRece[i,FG_POSVAR("VVD_NUMTIT","aHeadDesp")])
				dbSelectArea("SE1")
				dbSetOrder(2)
				if !dbSeek(xFilial("SE1")+aColsRece[i,FG_POSVAR("VVD_CODCLI","aHeadRece")]+aColsRece[i,FG_POSVAR("VVD_LOJACL","aHeadRece")]+aColsRece[i,FG_POSVAR("VVD_SERNFI","aHeadRece")]+;
						aColsRece[i,FG_POSVAR("VVD_NUMTIT","aHeadRece")]+aColsRece[i,FG_POSVAR("VVD_NUMPAR","aHeadRece")]+aColsRece[i,FG_POSVAR("VVD_TIPTIT","aHeadRece")])
					Loop
				Endif
			Else
				Loop
			Endif		
			aAdd(aTitulo,{"E1_PREFIXO",aColsRece[i,FG_POSVAR("VVD_SERNFI","aHeadRece")],nil})
			aadd(aTitulo,{"E1_NUM"    ,aColsRece[i,FG_POSVAR("VVD_NUMTIT","aHeadRece")],nil})
			aadd(aTitulo,{"E1_PARCELA",aColsRece[i,FG_POSVAR("VVD_NUMPAR","aHeadRece")],nil})
			aadd(aTitulo,{"E1_TIPO"   ,aColsRece[i,FG_POSVAR("VVD_TIPTIT","aHeadRece")],nil})
			aadd(aTitulo,{"E1_NATUREZ",aColsRece[i,FG_POSVAR("VVD_NATURE","aHeadRece")],nil})
			aadd(aTitulo,{"E1_CLIENTE",aColsRece[i,FG_POSVAR("VVD_CODCLI","aHeadRece")],nil})
			aadd(aTitulo,{"E1_LOJA"   ,aColsRece[i,FG_POSVAR("VVD_LOJACL","aHeadRece")],nil})
			aadd(aTitulo,{"E1_EMISSAO",aColsRece[i,FG_POSVAR("VVD_DATADR","aHeadRece")],nil})
			aadd(aTitulo,{"E1_VENCTO" ,aColsRece[i,FG_POSVAR("VVD_DATVEN","aHeadRece")],nil})
			aadd(aTitulo,{"E1_VENCREA",aColsRece[i,FG_POSVAR("VVD_DATVEN","aHeadRece")],nil})
			aadd(aTitulo,{"E1_VALOR"  ,aColsRece[i,FG_POSVAR("VVD_VALOR" ,"aHeadRece")],nil})
			
			If Len(aTitulo) > 0
				pergunte("FIN040",.F.)
				MSExecAuto({|x,y| FINA040(x,y)},aTitulo,5)
				If lMsErroAuto
					DisarmTransaction()
					Break
				EndIf
			EndIf
			loop
		Endif
		If aColsRece[i,FG_POSVAR("VVD_GERTIT","aHeadRece")] == "1" .and. aColsRece[i,FG_POSVAR("VVD_EXPCPG","aHeadRece")] <> "1"
			aadd(aTitulo,{"E1_PREFIXO" ,aColsRece[i,FG_POSVAR("VVD_SERNFI","aHeadRece")],nil})
			aadd(aTitulo,{"E1_NUM"	   ,aColsRece[i,FG_POSVAR("VVD_NUMTIT","aHeadRece")],nil})
			aadd(aTitulo,{"E1_PARCELA" ,aColsRece[i,FG_POSVAR("VVD_NUMPAR","aHeadRece")],nil})
			aadd(aTitulo,{"E1_TIPO"    ,aColsRece[i,FG_POSVAR("VVD_TIPTIT","aHeadRece")],nil})
			aadd(aTitulo,{"E1_NATUREZ" ,aColsRece[i,FG_POSVAR("VVD_NATURE","aHeadRece")],nil})
			aadd(aTitulo,{"E1_CLIENTE" ,aColsRece[i,FG_POSVAR("VVD_CODCLI","aHeadRece")],nil})
			aadd(aTitulo,{"E1_LOJA"	   ,aColsRece[i,FG_POSVAR("VVD_LOJACL","aHeadRece")],nil})
			aadd(aTitulo,{"E1_EMISSAO" ,aColsRece[i,FG_POSVAR("VVD_DATADR","aHeadRece")],nil})
			aadd(aTitulo,{"E1_VENCTO"  ,aColsRece[i,FG_POSVAR("VVD_DATVEN","aHeadRece")],nil})
			aadd(aTitulo,{"E1_VENCREA" ,aColsRece[i,FG_POSVAR("VVD_DATVEN","aHeadRece")],nil})
			aadd(aTitulo,{"E1_VALOR"   ,aColsRece[i,FG_POSVAR("VVD_VALOR" ,"aHeadRece")],nil}) 
			aadd(aTitulo,{"E1_ORIGEM"  , "MATA460"              					    ,nil})
			
			If Len(aTitulo) > 0
				pergunte("FIN040",.F.)
				MSExecAuto({|x| FINA040(x)},aTitulo)
				If lMsErroAuto
					DisarmTransaction()
					Break
				EndIf
			EndIf
			aColsRece[i,FG_POSVAR("VVD_EXPCPG","aHeadRece")] := "1"
		EndIf
	Next
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AtraCols040  ³ Autor ³  Manoel               ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tratamento do aCols.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßÜßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function  AtraCols040()

Local lRet := .t.

// Atribui valor nas descricoes de Despesas e Nomes de Fornecedores
If Readvar() == "M->VVD_CODIGO"
	FG_Seek("VV5","M->VVD_TIPOPE+M->VVD_CODIGO",1,.f.)
	acols[n,FG_POSVAR("VVD_DESCRI")] := VV5->VV5_DESCRI
	VVD->(DbSetOrder(1))
	cVarFilEnt := M->VV1_FILENT
	if Empty(cVarFilEnt)
		cVarFilEnt := xFilial("VVD")
	Endif
	If Empty(M->VVD_CODIGO)
		lRet := .f.
	Else
		lRet := .t.
	Endif
ElseIf readvar() == "M->VVD_NUMNFI"
	aCols[n,FG_POSVAR("VVD_NUMTIT")] := M->VVD_NUMNFI
Else   //M->VVD_LOJA ou VVD_LOJACL
	if M->VVD_TIPOPE == "0"
		acols[n,FG_POSVAR("VVD_NOMFOR")] := SA2->A2_NREDUZ
	Else
		acols[n,FG_POSVAR("VVD_NOMCLI")] := SA1->A1_NREDUZ
	Endif
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ABA    ºAutor  ³Fabio               º Data ³  08/10/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla abas                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Oficina                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ABA(nAba)

aCols   := {}
aHeader := {}

If nAba == 1
	
	aheader := Aclone( aHeadDesp )
	aCols   := Aclone( aColsDesp )
	
	If Type("oGetDesp") # "U" .And. Type("oGetRece") # "U"
		oGetRece:oBrowse:Disable()
		oGetDesp:oBrowse:Enable()
		n := oGetDesp:oBrowse:nAt
		oGetDesp:oBrowse:Refresh()
	EndIf
	
	M->VVD_TIPOPE := "0"
	
Else
	
	aheader := Aclone( aHeadRece )
	aCols   := Aclone( aColsRece )
	
	If Type("oGetDesp") # "U" .And. Type("oGetRece") # "U"
		oGetDesp:oBrowse:Disable()
		oGetRece:oBrowse:Enable()
		n := oGetRece:oBrowse:nAt
		oGetRece:oBrowse:Refresh()
	EndIf
	
	M->VVD_TIPOPE := "1"
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_SETOPT ºAutor  ³Manoel              º Data ³  10/01/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida mudanca de aba                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Sigavei                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SETOPT(nAba)

//Local nColuna := 0

&& Verifica caso tenha sido digitado algum conteudo na linha se todo os campos obrigatorios foram informados
//For nColuna := 1 to Len(aHeader)

//    If !Empty(aCols[n,nColuna])
//       If !FG_OBRIGAT()
//          Return(.f.)
//       Else
//          Exit
//       EndIf
//    EndIf

//Next

If nAba == 1
	
	aHeadDesp   := Aclone( aHeader )
	aColsDesp   := Aclone( aCols )
	
Else
	
	aHeadRece := Aclone( aHeader )
	aColsRece   := Aclone( aCols )
	
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VM040LINOKºAutor  ³Ricardo Farinelli   º Data ³  11/28/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a linha digitada                                     º±±
±±ºParametros³lLinok - se foi chamado pelo linok                          º±±
±±º          ³nx     - linha atual do acols a                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VM040LINOK(lLInok,nx)
Local nwnk := 0
Default nx := n
Default lLinok := .F.
n := nx

If aCols[n,len(acols[n])] .or. (nOpcX == 2 .or. nOpcX == 5) .or. (Len(aCols) == 1 .and. !lLinok)
	Return (.T.)
Endif

For nwnk := 1 To Len(aCols)
	If aCols[nwnk,Len(aCols[nwnk])]
		Loop
	Endif
	If !FG_OBRIGAT()
		Return .F.
	Endif
Next

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VM040TUDOKºAutor  ³Ricardo Farinelli   º Data ³  11/28/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a tela digitada                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM040TUDOK()
Local nwnk, nwnk2

For nwnk := 1 To 2
	oFolder:nOption := nwnk
	For nwnk2 :=1 to Len(aCols)
		If !VM040LINOK(,nwnk2)
			Return .F.
		Endif
	Next
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PE Tudo Ok ( validacao no Tudo OK da janela )                    ³
//³ .T. - continua gravacao das despesas/receitas                    ³
//³ .F. - cancela gravacao das despesas/receitas                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("VM040TOK")
	Return ( ExecBlock("VM040TOK",.f.,.f., { aClone(aCols) } ) )
EndIf
//

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MenuDef  ºAutor  ³Ricardo Farinelli   º Data ³  11/28/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Menu aRotina                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {{ OemToAnsi(STR0001) ,"axPesqui", 0 , 1},;   	// Pesquisar
{ OemToAnsi(STR0002) ,"Vm040", 0 , 2},;    // Visualizar
{ OemToAnsi(STR0003) ,"Vm040", 0 , 3},;    // Incluir
{ OemToAnsi(STR0004) ,"Vm040", 0 , 4},;   	// Alterar
{ OemToAnsi(STR0005) ,"Vm040", 0 , 5},;   	// Excluir
{ OemToAnsi(STR0021) ,"VEIVA690", 0 , 5},;	//Despesa Veiculos
{ OemToAnsi(STR0022) ,"VM040011_AjustaUltimaCompra()", 0 , 4} } // Agrupar Desp/Rec na Entrada por Compra
Return aRotina


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_VExpCpg³ Autor ³ Antonio Carlos (Boby) ³ Data ³ 01/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verificar Campo Obrigatorio qdo muda de linha quando campo ³±±
±±³          ³ ExpCPG for igual a Sim                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Siga Veiculos                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function FS_VExpCpg()

Local aArea := GetArea()         
Local lRet  := .T.
Local nI    := 0


IF	M->VVD_TIPOPE == "1"         //Receitas
	
	For nI:=1 to Len(aColsRece)  
		if aColsRece[nI,Len(aColsRece[nI])]
			Loop
		Endif	
		If ni <> n
			If aColsRece[nI,FG_POSVAR("VVD_GERTIT","aHeadRece")] == "1" .and. aColsRece[nI,FG_POSVAR("VVD_EXPCPG","aHeadRece")] <> "1"
				If Empty(aColsRece[nI,FG_POSVAR("VVD_NUMTIT")])
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_NUMTIT"),4,1 )
					lRet  := .F.
					Exit
				EndIf
				
				If Empty(aColsRece[nI,FG_POSVAR("VVD_NUMNFI")]+aColsRece[nI,FG_POSVAR("VVD_SERNFI")])
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_NUMNFI")+RetTitle("VVD_SERNFI"),4,1 )
					lRet  := .F.
					Exit
				EndIf
				
				If Empty(aColsRece[nI,FG_POSVAR("VVD_CODCLI")]+aColsRece[nI,FG_POSVAR("VVD_LOJACL")])
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_CODCLI")+RetTitle("VVD_LOJACL"),4,1 )
					lRet  := .F.
					Exit
				EndIf
				
				If	Empty(aColsRece[nI,FG_POSVAR("VVD_TIPTIT")])
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_TIPTIT"),4,1 )
					lRet  := .F.
					Exit
				EndIf
				
				If	Empty(aColsRece[nI,FG_POSVAR("VVD_NATURE")])
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_NATURE"),4,1 )
					lRet  := .F.
					Exit
				EndIf
				
				If	aColsRece[nI,FG_POSVAR("VVD_VALOR")] == 0
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_VALOR"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			EndIf
		Else
			If M->VVD_GERTIT == "1" .and. M->VVD_EXPCPG <> "1"
				If Empty(M->VVD_NUMTIT)
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_NUMTIT"),4,1 )
					lRet  := .F.
					Exit
				EndIf
				
				If Empty(M->VVD_NUMNFI+M->VVD_SERNFI)
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_NUMNFI")+RetTitle("VVD_SERNFI"),4,1 )
					lRet  := .F.
					Exit
				EndIf
				
				If Empty(M->VVD_CODCLI+M->VVD_LOJACL)
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_CODCLI")+RetTitle("VVD_LOJACL"),4,1 )
					lRet  := .F.
					Exit
				EndIf
				
				If	Empty(M->VVD_TIPTIT)
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_TIPTIT"),4,1 )
					lRet  := .F.
					Exit
				EndIf
				
				If	Empty(M->VVD_NATURE)
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_NATURE"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			
				If M->VVD_VALOR == 0
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_VALOR"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			Else
				if !Empty(M->VVD_DATADR)
					If Empty(M->VVD_DATVEN)
						Help(" ",1,"OBRIGAT2",,RetTitle("VVD_DATVEN"),4,1 )
						lRet  := .F.
						Exit
					EndIf
					If Empty(M->VVD_CODIGO)
						Help(" ",1,"OBRIGAT2",,RetTitle("VVD_CODIGO"),4,1 )
						lRet  := .F.
						Exit
					EndIf
					If M->VVD_VALOR == 0
						Help(" ",1,"OBRIGAT2",,RetTitle("VVD_VALOR"),4,1 )
						lRet  := .F.
						Exit
					EndIf
			   Endif
			Endif
		Endif
	Next
	
ELSE
	
	For nI:=1 to Len(aColsDesp)
		if aColsDesp[nI,Len(aColsDesp[nI])]
			Loop
		Endif	
		If ni <> n
			If aColsDesp[nI,FG_POSVAR("VVD_GERTIT","aHeadDesp")] == "1" .and. aColsDesp[nI,FG_POSVAR("VVD_EXPCPG","aHeadDesp")] <> "1"
				If Empty(aColsDesp[nI,FG_POSVAR("VVD_NUMTIT")])
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_NUMTIT"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			
				If Empty(aColsDesp[nI,FG_POSVAR("VVD_NUMNFI")]+aColsDesp[nI,FG_POSVAR("VVD_SERNFI")])
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_NUMNFI")+RetTitle("VVD_SERNFI"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			
				If	Empty(aColsDesp[nI,FG_POSVAR("VVD_CODFOR")]+aColsDesp[nI,FG_POSVAR("VVD_LOJA")])
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_CODFOR")+RetTitle("VVD_LOJA"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			
				If	Empty(aColsDesp[nI,FG_POSVAR("VVD_TIPTIT")])
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_TIPTIT"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			
				If	Empty(aColsDesp[nI,FG_POSVAR("VVD_NATURE")])
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_NATURE"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			
				If aColsDesp[nI,FG_POSVAR("VVD_VALOR")] == 0
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_VALOR"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			EndIf
		Else
			If M->VVD_GERTIT == "1" .and. M->VVD_EXPCPG <> "1"
				If Empty(M->VVD_NUMTIT)
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_NUMTIT"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			
				If Empty(M->VVD_NUMNFI+M->VVD_SERNFI)
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_NUMNFI")+RetTitle("VVD_SERNFI"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			
				If	Empty(M->VVD_CODFOR+M->VVD_LOJA)
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_CODFOR")+RetTitle("VVD_LOJA"),4,1 )
					lRet  := .F.
					Exit
				EndIf
				
				If	Empty(M->VVD_TIPTIT)
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_TIPTIT"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			
				If	Empty(M->VVD_NATURE)
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_NATURE"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			
				If M->VVD_VALOR == 0
					Help(" ",1,"OBRIGAT2",,RetTitle("VVD_VALOR"),4,1 )
					lRet  := .F.
					Exit
				EndIf
			Else
				if !Empty(M->VVD_DATADR)
					If Empty(M->VVD_DATVEN)
						Help(" ",1,"OBRIGAT2",,RetTitle("VVD_DATVEN"),4,1 )
						lRet  := .F.
						Exit
					EndIf
					If Empty(M->VVD_CODIGO)
						Help(" ",1,"OBRIGAT2",,RetTitle("VVD_CODIGO"),4,1 )
						lRet  := .F.
						Exit
					EndIf
					If M->VVD_VALOR == 0
						Help(" ",1,"OBRIGAT2",,RetTitle("VVD_VALOR"),4,1 )
						lRet  := .F.
						Exit
					EndIf
			   Endif
			EndIf
		Endif
	Next
	
EndIf
	
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VALCAMPOS ³ Autor ³  Manoel               ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de campos.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßÜßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALCAMPOS()
if !Empty(aCols[n,fg_posvar("VVD_CODVRE","aHeader")])
   Return(.f.)
Endif   

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_DELETE    ³ Autor ³  Manoel               ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Delete. 					                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßÜßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_DELETE()

if !Empty(aCols[n,fg_posvar("VVD_CODVRE","aHeader")]) 
   aCols[n,Len(aCols[n])] := .f.
Else
   if aCols[n,Len(aCols[n])] == .f.
      aCols[n,Len(aCols[n])] := .t.   
   Else
      aCols[n,Len(aCols[n])] := .f.   
   Endif
Endif
oGetDesp:oBrowse:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VM040TIP	   ³ Autor ³  Thiago               ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do campo tipo.                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßÜßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM040TIP() 
Local cParcSE2 := 1
Local cParcSE1 := 1  
Local lAchou1 := .f.
Local lAchou2 := .f.
Local i := 0

IF	M->VVD_TIPOPE == "0"         //Receitas


	dbSelectArea("SE2")
	dbSetOrder(1)
	if dbSeek(xFilial("SE2")+M->VVD_SERNFI+M->VVD_NUMTIT)
       While !Eof() .and. xFilial("SE2") == SE2->E2_FILIAL .and. M->VVD_SERNFI+M->VVD_NUMTIT == SE2->E2_PREFIXO+SE2->E2_NUM
	      if M->VVD_TIPTIT <> SE2->E2_TIPO .or. M->VVD_CODFOR <> SE2->E2_FORNECE .or. M->VVD_LOJA <> SE2->E2_LOJA
	          dbSkip()  
	          Loop
	      Endif    
          cParcSE2 += 1    
          lAchou1 := .t.
          dbSelectArea("SE2")
          dbSkip()  
       Enddo   
	Endif 

	nPos := Ascan(aCols,{ |x| x[fg_posvar("VVD_SERNFI","aHeader")]+x[fg_posvar("VVD_NUMTIT","aHeader")]+x[fg_posvar("VVD_TIPTIT","aHeader")]+x[fg_posvar("VVD_CODFOR","aHeader")]+x[fg_posvar("VVD_LOJA","aHeader")] == M->VVD_SERNFI+M->VVD_NUMTIT+M->VVD_TIPTIT+M->VVD_CODFOR+M->VVD_LOJA})
    if nPos > 0 
       For i := 1 to Len(aCols) 
			if aCols[i,fg_posvar("VVD_EXPCPG","aHeader")] <> "1"
				nPos := Ascan(aCols,{ |x| x[fg_posvar("VVD_SERNFI","aHeader")]+x[fg_posvar("VVD_NUMTIT","aHeader")]+x[fg_posvar("VVD_TIPTIT","aHeader")]+Alltrim(x[fg_posvar("VVD_NUMPAR","aHeader")])+x[fg_posvar("VVD_CODFOR","aHeader")]+x[fg_posvar("VVD_LOJA","aHeader")] == M->VVD_SERNFI+M->VVD_NUMTIT+M->VVD_TIPTIT+Alltrim(str(cParcSE2))+M->VVD_CODFOR+M->VVD_LOJA})
				if !lAchou1 
					if nPos > 0 .and. nPos <> n
		    	        cParcSE2 += 1
					Else
		        	    Exit
					Endif
				Endif	
	       		lAchou1 := .f.
       		Endif
       Next
    Endif

	M->VVD_NUMPAR := Alltrim(str(cParcSE2))
	aCols[n,fg_posvar("VVD_NUMPAR","aHeader")] := M->VVD_NUMPAR         

Else
	dbSelectArea("SE1")
	dbSetOrder(2)
	if dbSeek(xFilial("SE1")+M->VVD_CODCLI+M->VVD_LOJACL+M->VVD_SERNFI+M->VVD_NUMTIT)
       While !Eof() .and. xFilial("SE1") == SE1->E1_FILIAL .and. M->VVD_CODCLI+M->VVD_LOJACL+M->VVD_SERNFI+M->VVD_NUMTIT == SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
          if M->VVD_TIPTIT <> SE1->E1_TIPO
    	      dbSkip()
         	  Loop                                 
          Endif 	  
          cParcSE1 += 1
          lAchou2 := .t.
          dbSelectArea("SE1")
          dbSkip()
       Enddo   
	Endif          
	
	nPos := Ascan(aCols,{ |x| x[fg_posvar("VVD_CODCLI","aHeader")]+x[fg_posvar("VVD_LOJACL","aHeader")]+x[fg_posvar("VVD_SERNFI","aHeader")]+x[fg_posvar("VVD_NUMTIT","aHeader")]+x[fg_posvar("VVD_TIPTIT","aHeader")] == M->VVD_CODCLI+M->VVD_LOJACL+M->VVD_SERNFI+M->VVD_NUMTIT+M->VVD_TIPTIT})
    if nPos > 0 
       For i := 1 to Len(aCols) 
			if aCols[i,fg_posvar("VVD_EXPCPG","aHeader")] <> "1"
				nPos := Ascan(aCols,{ |x| x[fg_posvar("VVD_CODCLI","aHeader")]+x[fg_posvar("VVD_LOJACL","aHeader")]+x[fg_posvar("VVD_SERNFI","aHeader")]+x[fg_posvar("VVD_NUMTIT","aHeader")]+Alltrim(x[fg_posvar("VVD_NUMPAR","aHeader")])+x[fg_posvar("VVD_TIPTIT","aHeader")] == M->VVD_CODCLI+M->VVD_LOJACL+M->VVD_SERNFI+M->VVD_NUMTIT+Alltrim(str(cParcSE1))+M->VVD_TIPTIT})
				if !lAchou2 
					if nPos > 0 .and. nPos <> n
		    	        cParcSE1 += 1
					Else
		        	    Exit
					Endif
				Endif	
	       		lAchou2 := .f.
       		Endif
       Next
    Endif

	M->VVD_NUMPAR := Alltrim(str(cParcSE1))
	aCols[n,fg_posvar("VVD_NUMPAR","aHeader")] := M->VVD_NUMPAR
Endif	

Return(.t.)
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_FILTRO	   ³ Autor ³  Thiago               ³ Data ³ 14/01/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtra Despesas/Receitas do Veiculo.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßÜßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRO(nOpcRadio)
Local _ni       := 0     
Local cAliasVVD := "SQLVVD"  
Local cFiltro   := ""
Local cFilVVD   := ""
Local cQuery    := ""
Local aMovAux   := {}
Local lVVD_FILUCP := VVD->(FieldPos("VVD_FILUCP")) <> 0
Local lOkFiltro := .t.

aColsDesp := {}
aColsRece := {}

If nOpcRadio == 1 .or. nOpcRadio == 3  // Todos os Lançamentos ou Referente a Ultima Entrada por Compra
	cQuery := "SELECT DISTINCT VVD_FILIAL FROM "+RetSqlName("VVD")+" WHERE D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVVD , .F., .T. )
	While !( cAliasVVD )->( Eof() )
		cFilVVD += "'"+( cAliasVVD )->( VVD_FILIAL )+"',"
		( cAliasVVD )->( dbSkip() )
	EndDo
	( cAliasVVD )->( dbCloseArea() )
	If !Empty(cFilVVD)
		cFilVVD := left(cFilVVD,len(cFilVVD)-1)
	Else
		cFilVVD := "'"+xFilial("VVD")+"'"
	EndIf
	cFiltro += "VVD.VVD_FILIAL IN ("+cFilVVD+") AND "
Else
	If !lVVD_FILENT
		cFiltro += "VVD.VVD_FILIAL = '" + IIf(nOpcRadio == 2,cVarFilEnt,cFEntrada) + "' AND " // antes do VVD_FILENT
	Else
		cFiltro += " ( ( VVD.VVD_FILIAL = '" + xFilial("VVD") + "' AND VVD.VVD_FILENT = '" + IIf(nOpcRadio == 2,cVarFilEnt,cFEntrada) + "' ) " // novos registros
		cFiltro += " OR (VVD.VVD_FILIAL = '" + IIf(nOpcRadio == 2,cVarFilEnt,cFEntrada) + "' AND VVD.VVD_FILENT = ' ' ) ) AND " // registro antigos
	Endif
EndIf
//
cQuery := "SELECT VVD.R_E_C_N_O_ AS VVDRECNO , SA2.A2_NREDUZ , SA1.A1_NREDUZ "
cQuery += "FROM "
cQuery += RetSqlName( "VVD" ) + " VVD " 
cQuery += "LEFT JOIN "+RetSQLName("SA2")+" SA2 ON  SA2.A2_FILIAL  = '"+xFilial("SA2")+"' AND SA2.A2_COD = VVD.VVD_CODFOR AND SA2.A2_LOJA = VVD.VVD_LOJA   AND VVD.VVD_TIPOPE = '0' AND SA2.D_E_L_E_T_=' ' "
cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON  SA1.A1_FILIAL  = '"+xFilial("SA1")+"' AND SA1.A1_COD = VVD.VVD_CODCLI AND SA1.A1_LOJA = VVD.VVD_LOJACL AND VVD.VVD_TIPOPE = '1' AND SA1.D_E_L_E_T_=' ' "
cQuery += "WHERE "+cFiltro+" VVD.VVD_CHAINT = '"+M->VV1_CHAINT+"' AND " 
Do Case
	Case nOpcRadio == 2 // Últimos lançamentos
		cQuery += " VVD.VVD_TRACPA = '"+M->VV1_TRACPA+"' AND "
	Case nOpcRadio == 3 // Referente aos lançamentos desde a Ultima Entrada por Compra
		If lVVD_FILUCP
			aMovAux := FGX_VEIMOVS( M->VV1_CHASSI , "E" , "0" ) // Retorna a ultima Entrada por Compra do Veiculo
			If len(aMovAux) > 0
				cQuery += " VVD.VVD_FILUCP  = '" + aMovAux[1,2] + "' AND " // Ultima Filial de Entrada por Compra
				cQuery += " VVD.VVD_TRAUCP  = '" + aMovAux[1,3] + "' AND " // Ultimo TraCpa de Entrada por Compra
			Else
				VV1->(DbSetOrder(1))
				If VV1->(DbSeek(xFilial("VV1")+M->VV1_CHAINT))
					cQuery += " VVD.VVD_FILUCP  = '" + VV1->VV1_FILENT + "' AND " // Ultima Filial de Entrada
					cQuery += " VVD.VVD_TRAUCP  = '" + VV1->VV1_TRACPA + "' AND " // Ultimo TraCpa de Entrada
				Else
					lOkFiltro := .f.
				EndIf
			EndIf
		Else
			lOkFiltro := .f.
		EndIf
		If !lOkFiltro
			MsgInfo(STR0019,STR0011) // Não existem dados para esta Consulta. / Atencao
			oRadio:Refresh() // Não retirar pq é necessário refresh antes de passar para outra opção do radio
			nOpcRadio := 1 // Volta para "Todos os Lançamentos" pq é quando não existe Dados para "Lançamentos desde a Ultima Entrada por Compra"
			oRadio:Refresh()
		EndIf
	Case nOpcRadio == 4 // Lançamentos do Atendimento
		cQuery += " VVD.VVD_TRACPA = '"+cTCompra+"' AND "
EndCase
cQuery += "VVD.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVVD, .T., .T. )

Do While !( cAliasVVD )->( Eof() )

	DbSelectArea("VVD")
	DBGoto(( cAliasVVD )->(VVDRECNO))

	if VVD->VVD_TIPOPE == "0" // Despesas
		laColsD := .t.
		AADD(aColsDesp,Array(nUsadoD+1))
		For _ni:=1 to nUsadoD
			aColsDesp[Len(aColsDesp),_ni]:=If(aHeadDesp[_ni,10] # "V",FieldGet(FieldPos(aHeadDesp[_ni,2])),CriaVar(aHeadDesp[_ni,2]))
		Next
		aColsDesp[Len(aColsDesp),nUsadoD+1]:=.F.
		aColsDesp[len(aColsDesp),FG_POSVAR("VVD_NOMFOR",'aHeadDesp')] := ( cAliasVVD )->A2_NREDUZ
	Else // VVD->VVD_TIPOPE == "1" // Receitas
		laColsR := .t.
		AADD(aColsRece,Array(nUsadoR+1))
		For _ni:=1 to nUsadoR
			aColsRece[Len(aColsRece),_ni]:=If(aHeadRece[_ni,10] # "V",FieldGet(FieldPos(aHeadRece[_ni,2])),CriaVar(aHeadRece[_ni,2]))
		Next
		aColsRece[Len(aColsRece),nUsadoR+1]:=.F.
		aColsRece[len(aColsRece),FG_POSVAR("VVD_NOMCLI",'aHeadRece')] := ( cAliasVVD )->A1_NREDUZ
	Endif  
	dbSelectArea(cAliasVVD)
	( cAliasVVD )->(DbSkip())
Enddo                    
( cAliasVVD )->(dbCloseArea())


if !laColsD
	aColsDesp:={Array(nUsadoD+1)}
	aColsDesp[1,nUsadoD+1]:=.F.
	For _ni:=1 to nUsadoD
		aColsDesp[1,_ni]:=CriaVar(aHeadDesp[_ni,2])
	Next
Endif

if !laColsR
	aColsRece:={Array(nUsadoR+1)}
	aColsRece[1,nUsadoR+1]:=.F.
	For _ni:=1 to nUsadoR
		aColsRece[1,_ni]:=CriaVar(aHeadRece[_ni,2])
	Next
Endif

if Type("oGetDesp") # "U" .And. Type("oGetRece") # "U"      
	n := oGetDesp:oBrowse:nAt := 1
	oGetDesp:oBrowse:Refresh()
	n := oGetRece:oBrowse:nAt := 1
	oGetRece:oBrowse:Refresh()
Endif
      
if Type("oFolder:nOption") # "U" 
	FS_ABA(oFolder:nOption)
Else
	FS_ABA(1)
Endif	

Return

/*/{Protheus.doc} VM040011_AjustaUltimaCompra
	VVD - Processa os registros de Despesas e Receitas para agrupar na Entrada por Compra
	
	@type function
	@author Andre Luis Almeida
	@since 28/04/2020
/*/
Function VM040011_AjustaUltimaCompra()
Local lVVD_FILUCP := VVD->(FieldPos("VVD_FILUCP")) <> 0
Local cQuery    := ""
Local cFilVVD   := ""
Local cAliasVVD := "SQLVVD_AJ"
Local aMovAux   := {}
Local nCntFor   := 0
Local lAux      := .f.
Local cAux      := "INICIAL"
Local cAuxFil   := ""
Local cAuxNro   := ""
If lVVD_FILUCP
	If xFilial("VV1") <> xFilial("VVD")
		cQuery := "SELECT DISTINCT VVD_FILIAL"
		cQuery += "  FROM "+RetSqlName("VVD")
		cQuery += " WHERE D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVVD , .F., .T. )
		While !( cAliasVVD )->( Eof() )
			cFilVVD += "'"+( cAliasVVD )->( VVD_FILIAL )+"',"
			( cAliasVVD )->( dbSkip() )
		EndDo
		( cAliasVVD )->( dbCloseArea() )
	EndIf
	If !Empty(cFilVVD)
		cFilVVD := left(cFilVVD,len(cFilVVD)-1)
	Else
		cFilVVD := "'"+xFilial("VVD")+"'"
	EndIf
	DbSelectArea("VVD")
	cQuery := "SELECT COUNT(*) AS QTD"
	cQuery += "  FROM "+RetSqlName("VVD")
	cQuery += " WHERE VVD_FILIAL IN ("+cFilVVD+")"
	cQuery += "   AND VVD_FILUCP = ' '"
	cQuery += "   AND VVD_TRAUCP = ' '"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	If FM_SQL(cQuery) > 0
		If !MsgYesNo(STR0023,STR0011) // Deseja processar os registros de Despesas e Receitas para agrupar na Entrada por Compra? / Atencao
			Return
		EndIf
		cQuery := "SELECT VV1.VV1_CHASSI , VV1.VV1_FILENT , VV1.VV1_TRACPA ,"
		cQuery += "       CASE WHEN VVD.VVD_FILENT = ' ' THEN VVD.VVD_FILIAL ELSE VVD.VVD_FILENT END AS FILIALVVD ,"
		cQuery += "       VVD.VVD_TRACPA , VVD.R_E_C_N_O_ AS RECVVD "
		cQuery += "  FROM "+RetSqlName("VVD")+" VVD "
		cQuery += "  JOIN "+RetSqlName("VV1")+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VVD.VVD_CHAINT AND VV1.D_E_L_E_T_ = ' ' )"
		cQuery += " WHERE VVD.VVD_FILIAL IN ("+cFilVVD+")"
		cQuery += "   AND VVD.VVD_FILUCP = ' '"
		cQuery += "   AND VVD.VVD_TRAUCP = ' '"
		cQuery += "   AND VV1.VV1_CHASSI <> ' '"
		cQuery += " ORDER BY VV1.VV1_CHASSI"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVVD , .F., .T. )
		While !( cAliasVVD )->( Eof() )
			If cAux <> ( cAliasVVD )->( VV1_CHASSI )
				cAux := ( cAliasVVD )->( VV1_CHASSI )
				aMovAux := FGX_VEIMOVS( ( cAliasVVD )->( VV1_CHASSI ) , "E" , "0" ) // Retorna a ultima Entrada por Compra do Veiculo
				If len(aMovAux) > 1 // Possui mais de uma Entrada por Compra
					aMovAux := FGX_VEIMOVS( ( cAliasVVD )->( VV1_CHASSI ) , "E" , ) // Retorna todas as Entradas
				EndIf
			EndIf
			If len(aMovAux) == 0 // Não teve Entrada por Compra
				cAuxFil := ( cAliasVVD )->( VV1_FILENT ) // Ultima Filial de Entrada
				cAuxNro := ( cAliasVVD )->( VV1_TRACPA ) // Ultimo TraCpa de Entrada
			ElseIf len(aMovAux) == 1 // Teve apenas uma Entrada por Compra
				cAuxFil := aMovAux[1,2] // Ultima Filial de Entrada por Compra
				cAuxNro := aMovAux[1,3] // Ultimo TraCpa de Entrada por Compra
			Else
				lAux := .f.
				cAuxFil := ( cAliasVVD )->( VV1_FILENT ) // Ultima Filial de Entrada
				cAuxNro := ( cAliasVVD )->( VV1_TRACPA ) // Ultimo TraCpa de Entrada
				For nCntFor := 1 to len(aMovAux)
					If !lAux .and. ( cAliasVVD )->( FILIALVVD )+( cAliasVVD )->( VVD_TRACPA ) == aMovAux[nCntFor,2]+aMovAux[nCntFor,3] // Entrada por Compra tem que ser anterior ao igual a linha das Movimentacoes do Veiculo
						lAux := .t.
					EndIf
					If lAux .and. aMovAux[nCntFor,1] == "0" // Entrada por Compra
						cAuxFil := aMovAux[nCntFor,2] // Ultima Filial de Entrada por Compra
						cAuxNro := aMovAux[nCntFor,3] // Ultimo TraCpa de Entrada por Compra
						Exit
					EndIf
				Next
			EndIf
			If Empty(cAuxFil+cAuxNro)
				cAuxFil := "ZZ" // Este Registro vai ser descondiderado
			EndIf
			DbSelectArea("VVD")
			DbGoto( ( cAliasVVD )->( RECVVD ) )
			RecLock("VVD",.f.)
				VVD->VVD_FILUCP := cAuxFil
				VVD->VVD_TRAUCP := cAuxNro
			MsUnLock()
			( cAliasVVD )->( dbSkip() )
		EndDo
		( cAliasVVD )->( dbCloseArea() )
		cQuery := "SELECT CASE WHEN VVD_FILENT = ' ' THEN VVD_FILIAL ELSE VVD_FILENT END AS FILIALVVD ,"
		cQuery += "       VVD_TRACPA , R_E_C_N_O_ AS RECVVD"
		cQuery += "  FROM "+RetSqlName("VVD")
		cQuery += " WHERE VVD_FILIAL IN ("+cFilVVD+")"
		cQuery += "   AND VVD_FILUCP = ' '"
		cQuery += "   AND VVD_TRAUCP = ' '"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVVD , .F., .T. )
		While !( cAliasVVD )->( Eof() )
			cAuxFil := ( cAliasVVD )->( FILIALVVD )
			cAuxNro := ( cAliasVVD )->( VVD_TRACPA ) 
			If Empty(cAuxFil+cAuxNro)
				cAuxFil := "ZZ" // Este Registro vai ser descondiderado
			EndIf
			DbSelectArea("VVD")
			DbGoto( ( cAliasVVD )->( RECVVD ) )
			RecLock("VVD",.f.)
				VVD->VVD_FILUCP := cAuxFil
				VVD->VVD_TRAUCP := cAuxNro
			MsUnLock()
			( cAliasVVD )->( dbSkip() )
		EndDo
		( cAliasVVD )->( dbCloseArea() )
		MsgInfo(STR0024,STR0011) // Processamento executado com sucesso! / Atencao
	Else
		MsgInfo(STR0025,STR0011) // Processamento já foi executado anteriormente, não há necessidade de execucão. / Atencao
	EndIf
EndIf
Return

/*/{Protheus.doc} VM040028_PEVM040DEL 
	Chama ponto de entrada VM040DEL 	
	@type function
	@author Matheus Teixeira
	@since 16/08/2021
/*/
Static Function VM040028_PEVM040DEL(aHead,aCols,nAba) 

ExecBlock("VM040DEL",.f.,.f., { aHead,aCols,nAba } )

Return 

/*/{Protheus.doc} VM040038_PEVM040ALT 
	Chama ponto de entrada VM040ALT 	
	@type function
	@author Matheus Teixeira
	@since 16/08/2021
/*/
Static Function VM040038_PEVM040ALT(aHead,aCols,nAba) 

ExecBlock("VM040ALT",.f.,.f., { aHead,aCols,nAba } )

Return 