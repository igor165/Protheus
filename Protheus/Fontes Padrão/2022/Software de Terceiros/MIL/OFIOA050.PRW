#include "OFIOA050.CH"
#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA050 ³ Autor ³  Emilton/Fabio        ³ Data ³ 03/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grupo de Ferramentas e Ferramentas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA050()
	Local lVDP_NUMOSV := ( VDP->(FieldPos("VDP_NUMOSV")) <> 0 )
	Private aMemosVO9 := {{"VO9_DESUSO","VO9_USOMEM"}}
	Private aRotina   := MenuDef()
	Private cMVGruFer := GetNewPar("MV_MIL0038", "")
	Private cMVTipFer := GetNewPar("MV_MIL0039", "")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabecalho da tela de atualizacoes                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCadastro := OemToAnsi(STR0006)  // Grupo de Ferramentas & Ferramentas
	Private nUsado := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Verificações de Compatibilidade
	If VD3->(FieldPos("VD3_CODIGO")) <= 0
		MsgStop(STR0007)
		return .F.
	endif

	SetKey(VK_F12, {|| Pergunte("OA050PARS", .T.,,,, .F.)}) // Monta F12 com o pergunte para pegar os parametros

	If OA050ValMVs() == .F. // Obriga o preenchimento dos parametros
		Alert(STR0008)
		Return
	EndIf

	cQryAl001 := GetNextAlias()
	cQuery := "SELECT R_E_C_N_O_ AS RECVD3"
	cQuery += "  FROM "+RetSqlName("VD3")
	cQuery += " WHERE VD3_FILIAL = '" + xFilial("VD3") + "'"
	cQuery += "   AND VD3_CODIGO = ' '"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
	While !(cQryAl001)->(Eof())
		DBSelectArea("VD3")
		DBGoTo((cQryAl001)->( RECVD3 ))
		DBSelectArea("VDP")
		reclock("VDP",.T.)
			VDP->VDP_FILIAL := xFilial("VDP")
			VDP->VDP_CODIGO := GetSXENum('VDP', 'VDP_CODIGO')
			VDP->VDP_TIPMOV := VD3->VD3_TIPMOV
			VDP->VDP_CODPRO := VD3->VD3_CODPRO
			If lVDP_NUMOSV
				VDP->VDP_NUMOSV := VD3->VD3_NUMOSV
				VDP->VDP_TIPTEM := VD3->VD3_TIPTEM
			EndIf
			VDP->VDP_DATMOV := VD3->VD3_DATMOV
		msunlock()
		ConfirmSX8()
		DBSelectArea("VD3")
		reclock("VD3",.F.)
			VD3->VD3_CODIGO := VDP->VDP_CODIGO
			VD3->VD3_SEQUEN := "000001"
		msunlock()
		(cQryAl001)->(dbSkip())
	EndDo
	(cQryAl001)->(dbCloseArea())

	DBSelectArea("VOA")
	mBrowse( 6, 1,22,75,"VOA")
	SetKey(VK_F12,Nil)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³OA050     ºAutor  ³Fabio/Emilton       º Data ³  08/24/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Monta Tela                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OA050(cAlias, nReg, nOpc)
	Local aObjects    := {}, aInfo := {}, aPos := {}
	Local aSizeHalf   := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.T.=TOOLBAR,.F.=SEM TOOLBAR)
	Local bCampo      := { |nCPO| Field(nCPO) } , nCntFor := 0 , _ni := 0
	Local nPosRec     := 0
	Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
	
	Local aButtons  := { { "PESQUISA"   , { || GdSeek(oGetDados,OemtoAnsi(STR0017),,,.T.) }, OemtoAnsi(STR0017), OemtoAnsi(STR0017) } } //"Buscar Ferramenta"

	nLinhas := 9999
	
	Private aCols     := {}, aHeader := {} , aCpoEnchoice  :={}
	Private nLenAcols := 0
	Private aTELA[0][0],aGETS[0]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcoes de acesso para a Modelo 3                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcE := nOpcG := nOpc

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria variaveis M->????? da Enchoice                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory("VOA",.T.)

	aCpoEnchoice := {}
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("VOA")
	While !Eof().and.(x3_arquivo=="VOA")
		If X3USO(x3_usado).and.cNivel >=x3_nivel
			AADD(aCpoEnchoice,x3_campo)
			&("M->"+x3_campo):= CriaVar(x3_campo)
		Endif
		dbSkip()
	EndDo
	If !(Inclui)
		DbSelectArea("VOA")
		For nCntFor := 1 TO FCount()
			M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
		Next
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aHeader e aCols da GetDados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado := 0
	dbSelectArea("SX3")
	dbSeek("VO9")
	aHeader := {}
	While !Eof().And.(x3_arquivo=="VO9")
		If (X3USO(x3_usado) .And. cNivel>=x3_nivel .And. !x3_campo $ [VO9_GRUFER/VO9_DESGRU]) .or. Iif((GetNewPar("MV_MIL0076","S") == "S"),.f.,x3_campo=="VO9_QTDFER")
			nUsado := nUsado + 1
			Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
			&("M->"+x3_campo) := CriaVar(x3_campo)
		Endif
		dbSkip()
	EndDo

	// Inclui coluna de registro atraves de funcao generica
	dbSelectArea("VO9")
	ADHeadRec("VO9",aHeader)
	// Posicao do registro
	nPosRec := Len(aHeader)
	nUsado  := Len(aHeader)

	aCols:={}
	dbSelectArea("VO9")
	dbSetOrder(3)
	dbSeek(xFilial()+M->VOA_GRUFER)

	If nOpc == 3 .Or. !Found()
		aCols:={Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
		For _ni := 1 to nUsado
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := 0
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VO9"
			Else
				aCols[1,_ni] := CriaVar(aHeader[_ni,2])
			EndIf
		Next
	Else
		While !eof() .And. VO9->VO9_FILIAL == xFilial("VO9") .and. M->VOA_GRUFER == VO9->VO9_GRUFER
			AADD(aCols,Array(nUsado+1))
			For _ni := 1 to nUsado
				If IsHeadRec(aHeader[_ni,2])
					aCols[Len(aCols),_ni] := VO9->(RecNo())
				ElseIf IsHeadAlias(aHeader[_ni,2])
					aCols[Len(aCols),_ni] := "VO9"
				Else
					if aHeader[_ni,10] != "V"
						aCols[Len(aCols),_ni] := VO9->&(aHeader[_ni,2])
					elseIf Empty(aHeader[_ni,11]) // x3_relacao
						do case
							case aHeader[_ni,2] == "VO9_DESUSO"
								aCols[Len(aCols),_ni] := E_MSMM(VO9->VO9_USOMEM,70)
							case aHeader[_ni,2] == "VO9_DESPRO"
								aCols[Len(aCols),_ni] := Posicione("SB1",1, xFilial("SB1")+VO9->VO9_CODPRO,"B1_DESC")
						end do
					else
						aCols[Len(aCols),_ni] := &(aHeader[_ni,11])  // x3_relacao
					endif
				EndIf
			Next
			aCols[Len(aCols),nUsado+1] := .F.
			dbSkip()
		EndDo
		nLenaCols := Len(aCols)
	Endif

	If Len(aCols)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a Modelo 3                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTitulo        := STR0006   // Grupo de Ferramentas & Ferramentas
		cAliasEnchoice := "VOA"
		cAliasGetD     := "VO9"
		cLinOk         := "FG_OBRIGAT()"
		cTudOk         := "AllwaysTrue()"
		cFieldOk       := "FG_MEMVAR()"
		
		SETKEY( VK_F11, { || GdSeek(oGetDados,OemtoAnsi(STR0017),,,.T.) })

		aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
		aAdd( aObjects, { 0 ,  40 , .T. , .F. } ) // Enchoice
		aAdd( aObjects, { 0 , 100 , .T. , .T. } ) // MsGetDados

		aPos := MsObjSize( aInfo, aObjects )

		DEFINE MSDIALOG oOFIOA050 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE cTitulo OF oMainWnd PIXEL
		
		EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{aPos[1,1],aPos[1,2],aPos[1,3],aPos[1,4]},,3,,,,,,.F.)
		
		oGetDados := MsGetDados():New(aPos[2,1],aPos[2,2],aPos[2,3],aPos[2,4],nOpcG,cLinOk,cTudOk,"",IIf(nOpcG > 2 .and. nOpcG < 5,.T.,.F.),,,,nLinhas,cFieldOk)
		
		//oGetDados:oBrowse:bChange    := {|| FG_AALTER("VO9",nLenaCols,oGetDados) }
		oGetDados:oBrowse:bChange := { || OA050BChange() }
		ACTIVATE MSDIALOG oOFIOA050 ON INIT EnchoiceBar(oOFIOA050,{|| IIf(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_OA050GRA(nOpc),oOFIOA050:End(),.F.) },{|| oOFIOA050:End() },,aButtons) CENTER

		SetKey(VK_F11, Nil )

	Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FS_OOA050 ºAutor  ³Fabio               º Data ³  08/24/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Verifica duplicidade                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OOA050()
	If ReadVar() == "M->VO9_CODFER" .And. (Fg_Seek("VO9","M->VOA_GRUFER+M->VO9_CODFER",3,.F.) .Or. Ascan(aCols,{|x| x[FG_POSVAR("VO9_CODFER")] == M->VO9_CODFER }) # 0)
		Help("  ",1,"EXISTCHAV")
		Return(.F.)
	EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FS_OA050GRºAutor  ³Fabio               º Data ³  08/24/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Grava Ferramentas                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OA050GRA(nOpc)
	Private lMsFinalAuto := .T., lMsHelpAuto := .T.
	If !FS_VGRAOA050( nOpc , .T. )
		MostraErro()
		Return( .F. )
	EndIf
	Begin Transaction
	FS_VGRAOA050(nOpc)
	End Transaction
	lMsHelpAuto := .F.
	lMsFinalAuto := .F.
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VGRAOA050³ Autor ³  Emilton/Fabio      ³ Data ³ 03/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da Gravacao                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VGRAOA050( nOpc , lValid )
	LOCAL lRet := .T. , i := 0 , aVetValid := {}, nPos := 0
	LOCAL nIdxCodPro    := FG_POSVAR('VO9_CODPRO')

	Private lMsHelpAuto := .T.
	lValid := IIf( lValid == NIL , .F. , lValid )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executar processamento                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc # 2
		dbselectArea("VOA")
		DbSetOrder(1)
		dbseek(xFilial("VOA")+M->VOA_GRUFER)
		// Grava arquivo pai
		If Inclui .or. Altera
			If !lValid
				If !RecLock("VOA", !Found() )
					Help("  ",1,"REGNLOCK")
					lRet := .F.
					DisarmTransaction()
					Break
				EndIf
				FG_GRAVAR("VOA")
				MsUnlock()
			EndIf
		EndIf
		// Grava arquivo filho
		for i:=1 to len(aCols)
			If i > nLenaCols .AND. aCols[i, Len(aCols[i])]
				Loop
			EndIf
			dbselectArea("VO9")
			dbSetOrder(3)
			dbseek(xFilial("VO9") + M->VOA_GRUFER + aCols[i,FG_POSVAR("VO9_CODFER")])
			If (Inclui .OR. Altera) .AND. !aCols[i,Len(aCols[i])]
				If !lValid
					If !RecLock("VO9", !Found() )
						Help("  ",1,"REGNLOCK")
						lRet := .F.
						DisarmTransaction()
						Break
					EndIf
					FG_GRAVAR("VO9",aCols,aHeader,i)

					If Empty( aCols[i,nIdxCodPro] )                           // posição que deve conter o código do SB1 se o usuario escolheu
						lGerou := OA050GERARB1( M->VOA_GRUFER, aCols[i] ) // Gera SB1
						If lGerou == .F.                                        // Algum erro na geração do SB1
							DisarmTransaction()
							Break
						Else // Preenchendo os dados do produto recem criado
							VO9->VO9_CODPRO := SB1->B1_COD
						EndIf
					EndIf

					VO9->VO9_FILIAL := xFilial("VO9")
					VO9->VO9_GRUFER := M->VOA_GRUFER
					cVar := aMemosVO9[1][2]
					If (nPos := Ascan(aHeader,{|x| Upper(x[2]) == [VO9_DESUSO]})) > 0
						cVar := aCols[i,nPos]
					Endif
					MSMM(,TamSx3("VO9_DESUSO")[1],,cVar,1,,,"VO9","VO9_USOMEM")
					MsUnlock()
				EndIf
			ElseIf Found()
				If lValid
					aVetValid := {}
					Aadd(aVetValid, { "VO8" , "VO8_CODFER" , aCols[I,FG_POSVAR("VO9_CODFER")] , NIL } )
					Aadd(aVetValid, { "VD3" , "VD3_CODFER" , aCols[I,FG_POSVAR("VO9_CODFER")] , NIL } )
					If !FG_DELETA(aVetValid)
						Return( .F. )
					EndIf
				Else
					// Deleta
					If !RecLock("VO9",.F.,.T.)
						Help("  ",1,"REGNLOCK")
						lRet := .F.
						DisarmTransaction()
						Break
					EndIf
					dbdelete()
					MsUnlock()
					WriteSx2("VO9")
				EndIf
			Endif
		Next
		// Exclui arquivo pai
		DbSelectArea("VOA")
		If !(Inclui .Or. Altera) .And. Found()
			// Deleta
			If !RecLock("VOA",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .F.
				DisarmTransaction()
				Break
			EndIf
			dbdelete()
			MsUnlock()
			WriteSx2("VOA")
		Endif
	Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³  Emilton/Fabio        ³ Data ³ 03/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta aRotina ( MENUDEF )                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
	Local aRotina := { ;
		{ STR0001 ,"axPesqui", 0 , 1},;	// Pesquisar
		{ STR0002 ,"OA050"   , 0 , 2},;	// Visualizar
		{ STR0003 ,"OA050"   , 0 , 3},;	// Incluir
		{ STR0004 ,"OA050"   , 0 , 4},;	// Alterar
		{ STR0005 ,"OA050"   , 0 , 5} ; // Excluir
	}
Return aRotina 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OA050VQTD ³ Autor ³ Andre Luis Almeida   ³ Data ³ 01/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a ALTERACAO da quantidade de ferramenta             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OA050VQTD()
	Local lRet := .F.
	If OM450VQTD(M->VO9_QTDFER,aCols[n,FG_POSVAR("VO9_CODFER")],"","") // Valida MOVIMENTACOES da ferramenta
		lRet := .T.
	Else
		M->VO9_QTDFER := VO9->VO9_QTDFER // Volta a qtde que esta no arquivo
	EndIf
Return(lRet)


/*/{Protheus.doc} OA050ValMVs

	Verifica se existe algum parametro necessario para geração do SB1 que não foi preenchido via F12

	@author       Vinicius Gati
	@since        07/05/2014
	@description  Valida se os parametros F12 estao todos preenchidos
/*/
Static Function OA050ValMVs()
	Local lOk := .T.
	//Verifica se existe algum parametro necessario para geração do SB1 que não foi preenchido via F12
	If Empty(cMVGruFer) .OR. Empty(cMVTipFer)
		lOk := .F.
	EndIf
Return lOk

/*/{Protheus.doc} OA050GERARB1

	Gera um SB1 para uso na ferramenta

	@author       Vinicius Gati
	@since        07/05/2014
	@description Uma ferramenta necessita de um SB1 para controle de estoque, na tela é possível escolher um SB1 existente ou delegar essa criação para o sistema.
	@param        cGruFer, String, Grupo da ferramenta utilizado para gerar um codigo para o SB1
	@param        aData, Array, Contém os dados da ferramenta usados na criação do SB1
/*/
Function OA050GERARB1(cGrpFer, aData)
	Local lOperOk := .F. // Controla se está tudo ok ou se algum erro ocorreu
	nOpcA         := 3   // Usado na integração 3 cria novo registro, 4 faria update o que não convém nesse cadastro
	nIdxLocPad    := FG_POSVAR('VO9_LOCPAD')
	nIdxCodFer    := FG_POSVAR('VO9_CODFER')
	nIdxDesFer    := FG_POSVAR('VO9_DESFER')

	Pergunte("OA050PARS",.f.) // Renova os MVS_

	If Empty(cMVGruFer) .AND. Empty(cMVTipFer) // Verifica se os parameros foram preenchidos
		return .F.
	EndIf

	aB1Data := {;
		{ "B1_COD"     , GetSXENum("SB1","B1_COD")						         , Nil },;
		{ "B1_CODITE"  , ALLTRIM(cGrpFer) + ALLTRIM(aData[nIdxCodFer]) , Nil },;
		{ "B1_GRUPO"   , cMVGruFer                                     , Nil },;
		{ "B1_DESC"    , ALLTRIM(aData[nIdxDesFer])                    , Nil },;
		{ "B1_TIPO"    , cMVTipFer                                     , Nil },;
		{ "B1_UM"      , "UN"                                          , Nil },;
		{ "B1_LOCPAD"  , aData[nIdxLocPad]                             , Nil },;
		{ "B1_FILIAL"  , xFilial("SB1")                                , Nil } ;
	}

	lMsErroAuto := .F. // controle de erros usado na integracao

	//Ponto de Entrada p/ Atualizar o Cadastro de Produto
	If ExistBlock("OA050GB1") // Usado para alterar/adicionar os dados do B1 em caso de customização do B1
		aB1Data := ExecBlock( "OA050GB1", .F., .F., { aB1Data } )
	EndIf

	MSExecAuto({|x,y| mata010(x,y)},aB1Data,nOpcA)

	If lMsErroAuto
		MostraErro()
		Help(" ",1,"ERROCADPRO") // Erro no Cadastro da Ferramenta no SB1
		lMsErroAuto := .F.
		lOperOk     := .F.
	Else
		lOperOk := .T.
	Endif
Return lOperOk

/*/{Protheus.doc} OA050LOK
	Gera um SB1 para uso na ferramenta

	@author       Vinicius Gati
	@since        07/05/2014
	@description  Uma ferramenta necessita de um SB1 para controle de estoque, na tela é possível escolher um SB1 existente ou delegar essa criação para o sistema.
/*/
Function OA050BChange()
	Local nIdxLocPad := 1
	If ! Empty(oGetDados) // Verificação se o oGetDados existe pois este evento é disparado em momentos inoportunos 
		nIdxLocPad := FG_POSVAR('VO9_LOCPAD')
		Pergunte("OA050PARS",.f.) // Renova os MVS_
		
		If Empty( aCols[oGetDados:oBrowse:nAt, nIdxLocPad] )
			aCols[oGetDados:oBrowse:nAt, nIdxLocPad] := MV_PAR01
			oGetDados:oBrowse:Refresh()
		EndIf
	EndIf
Return 

/*/{Protheus.doc} OFA0500016_ValidaCodigoDaFerramenta
Validações Gerais com o Código da Ferramenta
@author Fernando Vitor Cavani
@since 03/01/2019
@version undefined
@type function
@return lRet, Lógico, Retorno .t. ou .f.
/*/
Function OFA0500016_ValidaCodigoDaFerramenta()
Local nLinha := 0

// Código não Informado
If !NaoVazio()
	Return .F.
EndIf

If Type("aCols") == "U"
	// Verificação se NÃO existe aCols
	If !OFA0500026_CodigoDaFerramentaCadastrado()
		Return .F.
	EndIf
Else
	// Verificação se existe aCols
	If aCols[oGetDados:oBrowse:nAt, FG_POSVAR("VO9_REC_WT")] <> 0
		// Verificação de Linha Cadastrada
		If aCols[oGetDados:oBrowse:nAt, FG_POSVAR("VO9_CODFER")] == M->VO9_CODFER
			Return .T.
		Else
			// Não alterar Código Cadastrado
			Help("  ", 1, "EXISTCHAV",, M->VOA_GRUFER + " " + aCols[oGetDados:oBrowse:nAt, FG_POSVAR("VO9_CODFER")], 4, 1)
			Return .F.
		EndIf
	Else
		// Verificação de Nova Linha
		If !OFA0500026_CodigoDaFerramentaCadastrado()
			Return .F.
		EndIf

		// Verificação de Código da Ferramenta já Informada
		nLinha := aScan(aCols, {|x| x[1] == M->VO9_CODFER})
		If nLinha <> 0 .And. nLinha <> oGetDados:oBrowse:nAt
			Help("  ", 1, "EXISTCHAV",, M->VOA_GRUFER + " " + aCols[nLinha, FG_POSVAR("VO9_CODFER")], 4, 1)
			Return .F.
		EndIf
	EndIf
EndIf
Return .T.

/*/{Protheus.doc} OFA0500026_CodigoDaFerramentaCadastrado
Verificação de Código da Ferramenta já Cadastrado
@author Fernando Vitor Cavani
@since 03/01/2019
@version undefined
@type function
@return lRet, Lógico, Retorno .t. ou .f.
/*/
Function OFA0500026_CodigoDaFerramentaCadastrado()
Local cSql, cGruDupl := ""

cSql := " SELECT VO9.VO9_GRUFER FROM " + RetSQLName("VO9") + " VO9 "
cSql += " WHERE VO9.VO9_FILIAL = '" + xFilial("VO9") + "' "
cSql += "   AND VO9.VO9_CODFER = '" + M->VO9_CODFER + "' "
cSql += "   AND VO9.D_E_L_E_T_ = ' ' "

cGruDupl := FM_SQL(cSql)
If !Empty(cGruDupl)
	Help("  ", 1, "EXISTCHAV",, cGruDupl + " " + M->VO9_CODFER, 4, 1)
	Return .F.
EndIf
Return .T.