// ษออออออออหออออออออป
// บ Versao บ 202   บ
// ศออออออออสออออออออผ

#INCLUDE "VEIFUNA.CH"
#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "msgraphi.ch"
#include "Ofixdef.ch"
#INCLUDE "TOPCONN.CH"
                 
/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007637_1"

Static dChatDUtl := Ctod(""), nChatHUtl := 0
Static COMPILE_ELEMENTS  := 10
Static COMPILE_FUNCTION  := 1
Static COMPILE_PRG       := 2
Static COMPILE_SOURCE    := 3
Static COMPILE_OK        := 4
Static COMPILE_ALIAS     := 5
Static COMPILE_RECNO     := 6
Static COMPILE_ERROR_STR := 7
Static COMPILE_ERROR_COL := 8
Static COMPILE_ERROR_LINE:= 9
Static COMPILE_INDICE    := 10
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Statics utilizadas no Processo de Calculo e Na Montagem    deณ
ณ Formulas e Roteiros ( Sao Reinicializadas atraves da  chamadaณ
ณ aa Funcao RstExecCalc()									   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
Static __aMnemonicos	 := {} 					//Array das variaveis usadas no calculo
Static __aLocal			 := {}					//Armazena as Locais para a Montagem das Formulas
Static _aGetTreeErr		 := {}					//Array com os Erros na Montagem das Formulas
Static _aLogExecRot		 := {}					//Array com os Logs na Execucao do Roteiro
Static __aRotErr	     := {}					//Array com os Erros de Roteiro de Calculo
Static __bFunRotExec	 := NIL					//Funcao de Roteiro Compilada
Static __cFunRotExec	 := "__cFunRotExec"		//Funcao de Roteiro a ser Executada
Static __cRotInExec		 := "__cRotInExec"		//Roteiro que esta sendo executado
Static __cGetRotExec	 := "__cGetRotExec"		//Roteiro a Ser Executado
Static __cRotFilial		 := "__cRotFilial"		//Filial Selecao do Roteiro Roteiro
Static __cRpoForm	     := "RpoForm_No_Init"	//Armazena o Nome do Ultimo Rpo de Formulas Utilizado
Static __lEndCalc		 := .F.					//Variavel de Controle de encerramento do calculo tratado na formula
Static __lNoPrcReg		 := .F.					//Variavel de Controle para desprezar o funcionario no calculo
Static __lCriaLocal		 := .T.					//Variavel para Controle de Inclusao de Variaveis Locais
Static __IsInDebbug		 := .F.					//Verifica se Esta em Processo de Debbug
Static __lInitFrm		 := .T.					//Verifica se Deve Inicializar e Compilar as Formulas
Static __oRpoForm		 := NIL					//Objeto Repositorio para a Compilacao das Formulas

///////////////////////////
//Variaveis da funcao de grafico
Static oGrafico
Static oBarGrafico
Static aView2 := {}
//////////////////////////

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_GARANTIบAutor  ณFabio               บ Data ณ  03/29/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica garantia                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_GARANTIA( cChaInt , cTipTem , cGruIte , cCodIte , cCodSer , dDataGar , nKmGar , lTela )

	Local nVar := 0 , dDataPesq := Ctod("  /  /  ") , nKmReq := 0
	Local aArea := {} , aVetGar := {} , lRetorno := .f. , cVerificacao := ""
	Local bTitulo   := {|cCampo| If( SX3->( DbSeek( cCampo ) ) , X3Titulo() , "" )  }
	Local bConteudo := {|x,cCampo| Ascan( aVetGar[x] , cCampo )  }
	Local nDiasGExtend:=0 , nKmGExtend:=0 , lGarExtend:=.f. , lListBox:=.t. , cTitulo:=""
	Default cGruIte := ""
	Default cCodIte := ""
	Default cCodSer := ""
	Default dDataGar:= Ctod("  /  /  ")
	Default nKmGar  := 0
	Default lTela   := .t.

	DbSelectArea("VOI")
	DbSetOrder(1)
	If DbSeek( xFilial("VOI") + cTipTem )
		If !(VOI->VOI_SITTPO$"2/4") // Servico Interno
			Return(.t.)
		EndIf
		If VOI->(FieldPos("VOI_VALGAR")) <> 0
			If VOI->VOI_VALGAR == "0"
				Return .t.
			EndIf
		EndIf
	EndIf

	// Salva posicoes do arquivo
	aArea := sGetArea(aArea,"VV1")
	aArea := sGetArea(aArea,"VO5")
	aArea := sGetArea(aArea,"VV2")
	aArea := sGetArea(aArea,"VE4")
	aArea := sGetArea(aArea,"VVL")
	aArea := sGetArea(aArea,"VEC")
	aArea := sGetArea(aArea,"SBM")
	aArea := sGetArea(aArea,"VO1")
	aArea := sGetArea(aArea,"VOI")
	aArea := sGetArea(aArea,"VSC")
	aArea := sGetArea(aArea,"VOU")
	aArea := sGetArea(aArea,"VOP")
	If !Empty(Alias())
		aArea := sGetArea(aArea,Alias())
	EndIf

	Aadd( aVetGar , {} )  // Cabecalho do veiculo
	Aadd( aVetGar , {} )  // Conteudo do veiculo
	Aadd( aVetGar , {} )  // Cabecalho do list box
	Aadd( aVetGar , {} )  // Conteudo do list box

	// Verifica a garantia do veiculo

	Aadd( aVetGar[2] , {} )

	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek( xFilial("VV1") + cChaInt )

	For nVar := 1 to FCount()
		Aadd( aVetGar[1] , FieldName( nVar ) )
	Next

	For nVar := 1 to FCount()
		Aadd( aVetGar[2,Len(aVetGar[2])] , FieldGet(nVar) )
	Next

	DbSelectArea("VVN")
	DbSetOrder(1)
	If DbSeek( xFilial("VVN") + VV1->VV1_TPGREX + VV1->VV1_CODMAR + VV1->VV1_CODGAR )

		If ( (!Empty(cGruIte).Or.!Empty(cCodIte)) .And. VVN->VVN_COBPEC == "1" ) ;
		.Or. ( !Empty(cCodSer) .And. VVN->VVN_COBSRV == "1" )

			nDiasGExtend := VVN->VVN_PRZGAR
			nKmGExtend	 := VVN->VVN_KILGAR

		EndIf

	EndIf

	DbSelectArea("VO5")
	DbSetOrder(1)
	DbSeek( xFilial("VO5") + cChaInt )

	For nVar := 1 to FCount()
		Aadd( aVetGar[1] , FieldName( nVar ) )
	Next

	For nVar := 1 to FCount()
		Aadd( aVetGar[2,Len(aVetGar[2])] , FieldGet(nVar) )
	Next

	If (!Empty(cCodIte) .or. !Empty(cCodSer)) .and. ( ExistBlock("ITEMSEMGAR") )
		If !ExecBlock("ITEMSEMGAR",.f.,.f.,{cGruIte,cCodIte})
			// Volta posicoes originais
			sRestArea(aArea)
			Return(.t.)
		EndIf
	EndIf

	DbSelectArea("VV2")
	DbSetOrder(1)
	DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD )

	DbSelectArea("VE4")
	DbSetOrder(1)
	DbSeek( xFilial("VE4") + VV1->VV1_CODMAR )

	If VE4->VE4_VDAREV == "1"   			// 1 - Data da venda do veiculo

		dDataPesq := VO5->VO5_DATVEN
		if Empty(dDataPesq)
			dDataPesq := VV1->VV1_DATVEN
		Endif

	ElseIf VE4->VE4_VDAREV == "2"   	// 2 - Data da primeira revisao do veiculo

		dDataPesq := VO5->VO5_PRIREV

	Else			 						      // 3 - Data da entrega do veiculo
		if VV1->(FieldPos("VV1_DATETG")) > 0 .and. !Empty(VV1->VV1_DATETG)
			dDataPesq := VV1->VV1_DATETG
		else
			dDataPesq := VO5->VO5_DATSAI
		endif
	EndIf
	DbSelectArea("VVL")
	DbSetOrder(1)
	If !DbSeek( xFilial("VVL") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD + Dtos( dDataPesq ) , .t. ) ;
	.And. ( VVL->VVL_FILIAL+VVL->VVL_CODMAR+VVL->VVL_MODVEI+VVL->VVL_SEGMOD # xFilial("VVL") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD .Or. VVL->VVL_DATGAR > dDataPesq )

		DbSkip(-1)

	EndIf

	If VVL->VVL_FILIAL+VVL->VVL_CODMAR+VVL->VVL_MODVEI+VVL->VVL_SEGMOD == xFilial("VVL") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD

		// Valida garantia por data
		If !Empty( dDataGar )

			If ( dDataPesq + VVL->VVL_PERGAR ) >= dDataGar    // Garantia Normal

				lRetorno := .t.
				cTitulo  := STR0026

			ElseIf ( dDataPesq + VVL->VVL_PERGAR + nDiasGExtend ) >= dDataGar    // Garantia Extendida

				lRetorno   := .t.
				cTitulo    := STR0026
				lGarExtend := .t.

			EndIf

		EndIf

		// Valida garantia por kilometro
		If !Empty( nKmGar )

			If VVL->VVL_KILGAR >= nKmGar   // Garantia normal

				lRetorno := .t.
				cTitulo  := STR0026

			ElseIf VVL->VVL_KILGAR+nKmGExtend >= nKmGar   // Garantia Extendida

				lRetorno   := .t.
				cTitulo    := STR0026
				lGarExtend := .t.

			EndIf

		EndIf

	EndIf

	// Verifica a garantia da peca ou da venda balcao

	DbSelectArea("VEC")

	For nVar := 1 to FCount()
		Aadd( aVetGar[3] , FieldName( nVar ) )
	Next

	DbSelectArea("VSC")

	For nVar := 1 to FCount()
		Aadd( aVetGar[3] , FieldName( nVar ) )
	Next

	DbSelectArea("SBM")
	DbSetOrder(1)
	DbSeek( xFilial("SBM") + cGruIte )

	If Alltrim( SBM->BM_TIPGRU ) == "2"   // Lubrificante nao tem garantia

		// Volta posicoes originais
		sRestArea(aArea)
		Return(.t.)

	EndIf

	DbSelectArea("VE4")
	DbSetOrder(1)
	DbSeek( xFilial("VE4") + SBM->BM_CODMAR )

	DbSelectArea("VO1")
	//dbClearFilter()
	DbSetOrder(4)
	DbSeek( xFilial("VO1") + cChaInt + "F" )

	Do While !Eof() .And. VO1->VO1_CHAINT + VO1->VO1_STATUS == cChaInt + "F" .And. VO1->VO1_FILIAL == xFilial("VO1")

		// Valida garantia por data
		If !Empty( dDataGar )

			// Pecas
			If !Empty(cGruIte) .Or. !Empty(cCodIte)

				DbSelectArea("VEC")
				DbSetOrder(5)
				DbSeek( xFilial("VEC") + VO1->VO1_NUMOSV )

				Do While !Eof() .And. VEC->VEC_NUMOSV == VO1->VO1_NUMOSV .And. VEC->VEC_FILIAL == xFilial("VEC")

					If VEC->VEC_GRUITE == cGruIte .And. VEC->VEC_CODITE == cCodIte

						DbSelectArea("VOI")
						DbSetOrder(1)
						DbSeek( xFilial("VOI") + VEC->VEC_TIPTEM )

						If VEC->VEC_BALOFI == "O"  // Verifica garantia de peca

							// Salva a data da aplicadacao da peca nao garantia
							If VOI->VOI_SITTPO # "2" .Or. Empty(dDataPesq) .Or. ( dDataPesq + VE4->VE4_PERPEC ) < VEC->VEC_DATVEN

								dDataPesq := VEC->VEC_DATVEN
								aVetGar[4] := {}
								cVerificacao := VEC->VEC_BALOFI
							EndIf

							// Valida garantia por kilometro
							DbSelectArea("VSC")
							DbSetOrder(1)
							If DbSeek( xFilial("VSC") + VO1->VO1_NUMOSV )

								nKmReq := VSC->VSC_KILROD

							EndIf

							// Adiciona no vetor
							DbSelectArea("VEC")

							Aadd( aVetGar[4] , {} )
							For nVar := 1 to Len(aVetGar[3])
								If FieldPos(aVetGar[3,nVar]) # 0
									Aadd( aVetGar[4,Len(aVetGar[4])] , FieldGet(FieldPos(aVetGar[3,nVar])) )
								Else
									Aadd( aVetGar[4,Len(aVetGar[4])] , CriaVar(aVetGar[3,nVar]) )
								EndIf
							Next

						ElseIf VEC->VEC_BALOFI == "B"  // Verifica garantia de peca balcao

							// Salva a data da aplicadacao da peca balcao nao garantia
							If VOI->VOI_SITTPO # "2" .Or. Empty(dDataPesq) .Or. ( dDataPesq + VE4->VE4_PERBAL ) < VEC->VEC_DATVEN

								dDataPesq := VEC->VEC_DATVEN
								aVetGar[4] := {}

							EndIf

							// Adiciona no vetor
							DbSelectArea("VEC")

							Aadd( aVetGar[4] , {} )
							For nVar := 1 to Len(aVetGar[3])
								If FieldPos(aVetGar[3,nVar]) # 0
									Aadd( aVetGar[4,Len(aVetGar[4])] , FieldGet(FieldPos(aVetGar[3,nVar])) )
								Else
									Aadd( aVetGar[4,Len(aVetGar[4])] , CriaVar(aVetGar[3,nVar]) )
								EndIf
							Next

						EndIf

					EndIf

					DbSelectArea("VEC")
					DbSkip()

				EndDo

			EndIf

			// Servicos
			If !Empty(cCodSer)

				DbSelectArea("VSC")
				DbSetOrder(1)
				DbSeek( xFilial("VSC") + VO1->VO1_NUMOSV )

				Do While !Eof() .And. VSC->VSC_NUMOSV == VO1->VO1_NUMOSV .And. VSC->VSC_FILIAL == xFilial("VSC")

					If VSC->VSC_CODSER == cCodSer

						DbSelectArea("VOI")
						DbSetOrder(1)
						DbSeek( xFilial("VOI") + VSC->VSC_TIPTEM )

						// Salva a data da aplicadacao da peca nao garantia
						If VOI->VOI_SITTPO # "2" .Or. Empty(dDataPesq) .Or. ( dDataPesq + VE4->VE4_PERPEC ) < VSC->VSC_DATVEN

							dDataPesq := VSC->VSC_DATVEN
							aVetGar[4] := {}

						EndIf

						nKmReq := VSC->VSC_KILROD

						// Adiciona no vetor
						DbSelectArea("VSC")

						Aadd( aVetGar[4] , {} )
						For nVar := 1 to Len(aVetGar[3])
							If FieldPos(aVetGar[3,nVar]) # 0
								Aadd( aVetGar[4,Len(aVetGar[4])] , FieldGet(FieldPos(aVetGar[3,nVar])) )
							Else
								Aadd( aVetGar[4,Len(aVetGar[4])] , CriaVar(aVetGar[3,nVar]) )
							EndIf
						Next

					EndIf

					DbSelectArea("VSC")
					DbSkip()

				EndDo

			EndIf

		EndIf

		DbSelectArea("VO1")
		DbSkip()

	EndDo

	If cVerificacao == "O"  // Verifica garantia de peca

		// Valida garantia por data
		If !Empty( dDataGar )

			If ( dDataPesq + VE4->VE4_PERPEC ) >= dDataGar

				lRetorno := .t.
				cTitulo  := STR0001

			EndIf

		EndIf

		// Valida garantia por kilometro
		If !Empty( nKmGar )

			If ( nKmReq + VE4->VE4_KILPEC ) >= nKmGar

				lRetorno := .t.
				cTitulo  := STR0001

			EndIf

		EndIf

	ElseIf cVerificacao == "B"             // Verifica garantia de peca BALCAO

		// Valida garantia por data
		If !Empty( dDataGar )

			If ( dDataPesq + VE4->VE4_PERBAL ) >= dDataGar

				lRetorno := .t.
				cTitulo  := STR0027

			EndIf

		EndIf

	EndIf

	DbSelectArea("VOI")
	DbSetOrder(1)
	DbSeek( xFilial("VOI") + cTipTem )

	If ( VOI->VOI_SITTPO # "2" .Or. ( VOI->VOI_SITTPO == "2" .And. Len(aVetGar[4]) # 0 ) )

		If lTela .And. lRetorno

			If Len(aVetGar[4]) # 0

				DbSelectArea("VOI")
				DbSetOrder(1)
				DbSeek( xFilial("VOI") + Alltrim(aVetGar[4,Len(aVetGar[4]), Eval(bConteudo,3,"VEC_TIPTEM") ])+Alltrim(aVetGar[4,Len(aVetGar[4]), Eval(bConteudo,3,"VSC_TIPTEM") ]) )

				If VOI->VOI_SITTPO == "2"
					cTitulo += STR0164
				EndIf

				DbSeek( xFilial("VOI") + cTipTem )

			EndIf

			If Len(aVetGar[4]) == 0

				Aadd( aVetGar[4] , {} )
				For nVar := 1 to Len( aVetGar[3] )
					Aadd( aVetGar[4,Len(aVetGar[4])] , CriaVar(aVetGar[3,nVar]) )
				Next

				lListBox:=.f.

			EndIf

			SX3->(DbSetOrder(2))

			DEFINE MSDIALOG oDlgGarPec TITLE cTitulo From 7,08 to If(lListBox,22,16),75      of oMainWnd //"Peca com garantia - Historico da peca"

			@ 001,004 SAY Eval(bTitulo,"VV1_CHASSI") OF oDlgGarPec PIXEL COLOR CLR_BLUE
			@ 001,037 MSGET aVetGar[2,1, Eval(bConteudo,1,"VV1_CHASSI") ] PICTURE "@!" SIZE 80,10 OF oDlgGarPec PIXEL COLOR CLR_BLACK When .f.

			@ 012,004 SAY Eval(bTitulo,"VV1_PROATU") OF oDlgGarPec PIXEL COLOR CLR_BLUE
			@ 012,037 MSGET aVetGar[2,1, Eval(bConteudo,1,"VV1_PROATU") ] PICTURE "@!" SIZE 40,10 OF oDlgGarPec PIXEL COLOR CLR_BLACK When .f.

			@ 024,004 SAY Eval(bTitulo,"VV1_LJPATU") OF oDlgGarPec PIXEL COLOR CLR_BLUE
			@ 024,037 MSGET aVetGar[2,1, Eval(bConteudo,1,"VV1_LJPATU") ] PICTURE "@!" SIZE 25,10 OF oDlgGarPec PIXEL COLOR CLR_BLACK When .f.

			@ 036,004 SAY Eval(bTitulo,"VV1_KILVEI") OF oDlgGarPec PIXEL COLOR CLR_BLUE
			@ 036,037 MSGET aVetGar[2,1, Eval(bConteudo,1,"VV1_KILVEI") ] PICTURE "@E 99.999.999.999" SIZE 40,10 OF oDlgGarPec PIXEL COLOR CLR_BLACK When .f.

			@ 001,154 SAY Eval(bTitulo,"VO5_DATVEN") OF oDlgGarPec PIXEL COLOR CLR_BLUE
			@ 001,187 MSGET aVetGar[2,1, Eval(bConteudo,1,"VO5_DATVEN") ] PICTURE "D!" SIZE 40,10 OF oDlgGarPec PIXEL COLOR CLR_BLACK When .f.

			@ 012,154 SAY Eval(bTitulo,"VO5_DATSAI") OF oDlgGarPec PIXEL COLOR CLR_BLUE
			@ 012,187 MSGET aVetGar[2,1, Eval(bConteudo,1,"VO5_DATSAI") ] PICTURE "D!" SIZE 40,10 OF oDlgGarPec PIXEL COLOR CLR_BLACK When .f.

			@ 024,154 SAY Eval(bTitulo,"VO5_PRIREV") OF oDlgGarPec PIXEL COLOR CLR_BLUE
			@ 024,187 MSGET aVetGar[2,1, Eval(bConteudo,1,"VO5_PRIREV") ] PICTURE "D!" SIZE 40,10 OF oDlgGarPec PIXEL COLOR CLR_BLACK When .f.

			If lListBox

				@ 048,002 LISTBOX oLbGarPec FIELDS HEADER  (Eval(bTitulo,"VEC_TIPTEM")),;   // "Plano de Revisao: "
				(Eval(bTitulo,"VEC_GRUITE")),;
				(Eval(bTitulo,"VEC_CODITE")),;
				(Eval(bTitulo,"VSC_CODSER")),;
				(Eval(bTitulo,"VEC_QTDITE")),;
				(Eval(bTitulo,"VEC_VALVDA")),;
				(Eval(bTitulo,"VEC_DATVEN")),;
				(Eval(bTitulo,"VSC_KILROD")),;
				(Eval(bTitulo,"VEC_NUMOSV")),;
				(Eval(bTitulo,"VEC_NUMNFI")),;
				(Eval(bTitulo,"VEC_SERNFI"));
				COLSIZES 15,20,50,50,20,35,30,30,30,30,20;
				SIZE 262,050 OF oDlgGarPec ON DBLCLICK FS_COFIOC060( If(Empty(aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VEC_NUMOSV") ]),;
				aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VSC_NUMOSV") ],;
				aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VEC_NUMOSV") ]) ) PIXEL

				oLbGarPec:SetArray(aVetGar[4])
				oLbGarPec:bLine := { || { Alltrim(aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VEC_TIPTEM") ])+Alltrim(aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VSC_TIPTEM") ]) ,;
				aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VEC_GRUITE") ] ,;
				aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VEC_CODITE") ] ,;
				aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VSC_CODSER") ] ,;
				Transform( aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VEC_QTDITE") ] , "@E 999,999,999") ,;
				Transform( If( !Empty(aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VEC_VALVDA") ]),aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VEC_VALVDA") ],aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VSC_VALSER") ]) , "@E 99,999,999.99") ,;
				Dtoc(      If( !Empty(aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VEC_DATVEN") ]) , aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VEC_DATVEN") ] , aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VSC_DATVEN") ] ) ) ,;
				Transform( aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VSC_KILROD") ] , "@E 99,999,999,999") ,;
				Alltrim(aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VEC_NUMOSV") ]) + Alltrim(aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VSC_NUMOSV") ]) ,;
				Alltrim(aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VEC_NUMNFI") ]) + Alltrim(aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VSC_NUMNFI") ]) ,;
				Alltrim(aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VEC_SERNFI") ]) + Alltrim(aVetGar[4,oLbGarPec:nAt, Eval(bConteudo,3,"VSC_SERNFI") ]) }	}

				oDlgGarPec:SetFocus()

			EndIf

			DEFINE SBUTTON FROM If(lListBox,100,51),225 TYPE 2 ACTION (oDlgGarPec:End()) ENABLE OF oDlgGarPec

			ACTIVATE MSDIALOG oDlgGarPec CENTER

		EndIf

		lRetorno := .t.

	Else

		&& Verifica campanha
		DbSelectArea("VOU")
		DbSetOrder(2)
		DbSeek( xFilial("VOU") + VV1->VV1_CHASSI )
		Do While !Eof() .And. VOU->VOU_FILIAL + VOU->VOU_CHASSI == xFilial("VOU")+VV1->VV1_CHASSI

			DbSelectArea("VOP")
			DbSetOrder(1)
			If DbSeek( xFilial("VOP") + VOU->VOU_NUMINT ) ;
			.And. ( Empty(VOP->VOP_DATCAM) .Or. dDataGar >= VOP->VOP_DATCAM ) ;
			.And. ( Empty(VOP->VOP_DATVEN) .Or. dDataGar <= VOP->VOP_DATVEN )

				lRetorno := .t.
				Exit

			EndIf

			DbSelectArea("VOU")
			DbSkip()

		EndDo

	EndIf
	DbSelectarea("VO1")
	dbSetOrder(1)

	// Volta posicoes originais
	sRestArea(aArea)

	If lTela

		If !lRetorno

			Help("   ",1,"VGARNEXIST" )

		ElseIf lGarExtend

			Aviso(STR0002,STR0003+" "+VVN->VVN_DESCRI,{"OK"})

		EndIf

	EndIf

Return( lRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFG_CLAFIS ณ Autor ณ Andre                 ณ Data ณ 08/05/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณVerifica a classificacao fiscal de acordo com a UF          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGeral                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_CLAFIS(cTES)

	Local cRet := "    "
	Local aRet
	Local	cRestoCfo := ""
	Local lInscri := .t.

	dbSelectArea("SF4")
	dbSetOrder(1)
	If (DbSeek(xFilial("SF4")+cTES,.F.))
		cRet := SF4->F4_CF
		aRet := FS_VLCIDEST()
		if cPaisLoc == "BRA"
			if SF4->F4_CODIGO >= "500" // Saida
				cRet := If(SA1->A1_TIPO != "X",iif(aRet[2] == alltrim(GetMv("MV_ESTADO")),SF4->F4_CF,"6"+;
				Subs(SF4->F4_CF,2,LEN(SF4->F4_CF)-1)),"7"+Subs(SF4->F4_CF,2,LEN(SF4->F4_CF)-1))
				cInscri := SA1->A1_INSCR
				lInscri := !(Empty(cInscri).OR."ISENT" $ cInscri)
			Else
				cRet := If(SA2->A2_TIPO != "X",iif(aRet[2] == alltrim(GetMv("MV_ESTADO")),SF4->F4_CF,"2"+;
				Subs(SF4->F4_CF,2,LEN(SF4->F4_CF)-1)),"3"+Subs(SF4->F4_CF,2,LEN(SF4->F4_CF)-1))
			Endif
		EndIf
	Endif
	if cPaisLoc == "BRA"
		If Left(cRet,4) == "6405"
			cRet := "6404"+SubStr(cRet,5)
		Endif
	Endif

	// Manoel (04/02/2010) - Atendento Solicitacao da Shark
	If Left(cRet,1) == "6" .and. GetNewPar( "MV_CONVCFO", "1" ) == "1"
		cRestoCfo := SubStr(cRet,2,Len(cRet)-1)
		If !lInscri
			If AllTrim( cRestoCfo ) == "102"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Caso seja operacao interestadual para nao inscritos        ณ
				//ณ altera o final do CFO de 102 para 108                      ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cRestoCfo := "108" + Space( Len( cRestoCfo ) - 3 )
			ElseIf AllTrim( cRestoCfo ) == "101"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Caso seja operacao interestadual para nao inscritos        ณ
				//ณ altera o final do CFO de 101 para 107                      ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cRestoCfo := "107" + Space( Len( cRestoCfo ) - 3 )
			ElseIf AllTrim( cRestoCfo ) == "106"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Caso seja operacao interestadual para nao inscritos        ณ
				//ณ altera o final do CFO de 106 para 108                      ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cRestoCfo := "108" + Space( Len( cRestoCfo ) - 3 )
			EndIf
			cRet := "6"+cRestoCfo
		EndIf
	Endif

Return( cRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma  ณFG_MARCA  บAutor  ณRicardo Farinelli   บ Data ณ  28/06/01    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para localizar qual e o codigo da marca a que se re-  บฑฑ
ฑฑบ          ณfere uma montadora                                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ cCodPro - C๓digo do Produtivo                               บฑฑ
ฑฑบ__cMontad := Nome da Montadora que se deseja localizar o codigo da marcaบฑฑ
ฑฑบ__cCampo  := Campo a comparar com a marca desejada, se o campo for da   บฑฑ
ฑฑบ             marca deseja retorno = .t., se nao .f.                     บฑฑ
ฑฑบ__lTodos  := se .t. retorna uma string com todos os codigos de marca da บฑฑ
ฑฑบ             marca desejada     					 					   บฑฑ
ฑฑฬออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_MARCA(__cMontad,__cCampo,__lTodos)
	Local __Marca := ""
	Local __nPos := 0
	Local __nPos2 := 0
	Local __cRetorno
	Default __lTodos := .F.

	If (__Marca := GetNewPar("MV_MARCAS","")) == ""
		__Marca := CriaVar("VE1_CODMAR",.F.)
		If __lTodos
			__cRetorno := __Marca
		Elseif !(__cCampo == Nil)
			__cRetorno := .F.
		Else
			__cRetorno := __Marca
		Endif
	Else
		If (__nPos := At(Upper(__cMontad),__Marca)) > 0
			If (__nPos2 := At("]",Substr(__Marca,__nPos,100))) > 0
				__Marca := Substr(__Marca,__nPos,__nPos2-1)
				If __lTodos
					If (__nPos2 := At("=",__Marca)) >0
						__cRetorno := Substr(__Marca,(__nPos2+1),Len(__Marca))
					Else
						__cRetorno := Criavar("VE1_CODMAR")
					Endif
				Else
					If (__nPos2 := At("=",__Marca)) >0
						__cRetorno := Substr(__Marca,(__nPos2+1),3)
						If !(__cCampo == Nil)
							If __cRetorno == &__cCampo
								__cRetorno := .T.
							Else
								__cRetorno := .F.
							Endif
						Endif
					Else
						__cRetorno := Criavar("VE1_CODMAR",.F.)
						If !(__cCampo == Nil)
							__cRetorno := .F.
						Endif
					Endif
				Endif
			Else
				If !(__cCampo == Nil)
					__cRetorno := .F.
				Else
					__cRetorno := Criavar("VE1_CODMAR")
				Endif
			Endif
		Else
			If !(__cCampo == Nil)
				__cRetorno := .F.
			Else
				__cRetorno := Criavar("VE1_CODMAR")
			Endif
		Endif
	Endif

	// Atencao !!
	// Esta funcao pode retornar .T. ou .F. se comparada a marca com as marcas do parametro
	// Ou retornar o Codigo da Marca
	// Ou retornar todos os codigos de marca para a montadora desejada

Return __cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_MONTCODบAutor  ณFabio               บ Data ณ  07/03/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta codigo                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_MONTCOD( cCodigo )

	Local nCod := 0 , cNewCodigo := ""

	For nCod := 1 to Len( cCodigo )

		If !( Substr( cCodigo , nCod , 1 ) $ GetNewPar("MV_SAIBRR","") )

			cNewCodigo += Substr( cCodigo , nCod , 1 )

		EndIf

	Next

Return( cNewCodigo )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFG_INICPO ณAutor  ณValdir              ณ Data ณ 20/08/2001  บฑฑ
ฑฑฬออออออออออุออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRetorna o Valor de um campo desejado		                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณVeiculos,Pecas,Oficina                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_INICPO(cCod,cAlias,nOrdem,cRetorno)
	Local aArea:=GetArea()
	Local nOrd
	Local cReturn := ''
	Default nOrdem := 1

	If cCod == Nil .or. cAlias == Nil .or. cRetorno == Nil .or. Empty(Trim(cCod))
		Return (cReturn)
	EndIf

	If (Type('aCols') == 'A') .and. (Type('N') == 'N') .and. (n > 0 ) .and. (n <= Len(aCols)) .and. (Len(aCols[1]) <> Len(aCols[n]))
		Return (cReturn)
	EndIf

	DbSelectArea(cAlias)
	nOrd := IndexOrd()
	DbSetOrder(nOrdem)
	DbSeek(xFilial()+cCod)
	cReturn:=&cRetorno
	DbSetOrder(nOrd)
	RestArea(aArea)
Return (cReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_AVALCREบAutor  ณFabio               บ Data ณ  08/24/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLevanta valores para avaliacao de credito do cliente        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_AVALCRED( cCodCli , cLoja , lAllRiscos , lRetVet , aRetVet )
	Local nValor  := 0 , aCodSer := {} , aArea := {} , cSele := Alias()
	Local cQuery  := ""
	Local cRetorno:= ""
	Local cQAlVO3 := "SQLVO3" // VO3
	Local cQAlVO4 := "SQLVO4" // VO4
	Local cQAlVS1 := "SQLVS1" // VS1
	Local cCreCli := GetMv("MV_CREDCLI")
	Local aFilAtu   := FWArrFilAtu()
	Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
	Local cBkpFilAnt:= cFilAnt
	Local cFilVS1   := ""
	Local cFilVO3   := ""
	Local cFilVO4   := ""
	Local nCont     := 0
	Local cCondNAO  := GetNewPar("MV_MIL0158","") // Condicoes de Pagamento a descosiderar no levantamento parados titulos do Limite de Credito do Cliente. Separar por /
	
	Local nVlrAux   := 0
	Local nPosVet   := 0
	Default lAllRiscos := .f. // Levanta para Todos os Riscos ? ( Default .f. = somente nao faz para o Risco A )
	Default lRetVet    := .f. // Retorna Vetor com os Orcamento e OSs + Tipo de Tempo com valor de Pe็as e Servi็os ?
	Default aRetVet    := {} // Vetor de Retorno de Orcamento e OSs + Tipo de Tempo com valor de Pe็as e Servi็os

	If !Empty(cCondNAO) // Desconsiderar no Levantamento do Limite de Credito as Condicoes de Pagamento contidas no parametro MV_MIL0158
		If len(cCondNAO) > 1 .and. right(cCondNAO,1) == "/"
			cCondNAO := left(cCondNAO,len(cCondNAO)-1)
		EndIf
	EndIf

	aArea := sGetArea(aArea , "SA1")

	For nCont := 1 to Len(aSM0)

		cFilAnt := aSM0[nCont]

		DbSelectArea("SA1")
		DbSetOrder(1)
		MsSeek(xFilial("SA1")+cCodCli+IIf(cCreCli=="L",cLoja,""))
		If lAllRiscos .or. SA1->A1_RISCO <> "A" // somente levantar valores quando o RISCO do cliente for diferente de "A"

			cFilVS1   := xFilial("VS1")
			cFilVO3   := xFilial("VO3")
			cFilVO4   := xFilial("VO4")

			cQuery := "SELECT DISTINCT VO4.VO4_NUMOSV , VO4.VO4_TIPTEM FROM "+RetSqlName("VO4")+" VO4 "
			cQuery += "INNER JOIN "+RetSQLName("VOI")+" VOI ON VOI.VOI_FILIAL='"+xFilial("VOI")+"' AND VOI.VOI_TIPTEM=VO4.VO4_TIPTEM AND VOI.D_E_L_E_T_=' ' "
			cQuery += "WHERE VO4.VO4_FILIAL='"+cFilVO4+"' AND "
			cQuery += "VO4.VO4_FATPAR='"+cCodCli+"' AND "
			If cCreCli == "L"
				cQuery += "VO4.VO4_LOJA='"+cLoja+"' AND "
			EndIf
			cQuery += "VO4.VO4_DATFEC = '        ' AND VO4.VO4_DATCAN = '        ' AND "
			cQuery += "VOI.VOI_SITTPO='1' AND "
			cQuery += "VO4.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY VO4.VO4_NUMOSV, VO4.VO4_TIPTEM "

			If ExistBlock("PEQRYACR")
				cRetorno := ExecBlock("PEQRYACR",.f.,.f.,{"VO4",cQuery,cCodCli,cLoja}) // Ponto de entrada para manipulacao da query.
				if !Empty(cRetorno)
					cQuery := cRetorno
				Endif
			EndIf
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO4 , .F., .T. )

			cPulaReg := ""

			While !( cQAlVO4 )->( Eof() )

				aCodSer := FMX_CALSER(( cQAlVO4 )->VO4_NUMOSV, ( cQAlVO4 )->VO4_TIPTEM, , , .f., .t., .t., .t., .f., .f.)
				
				nVlrAux := 0
				aEval( aCodSer , { |x| nVlrAux += x[SRVC_VALLIQ] } )   // Valor Srv
				nValor += nVlrAux

				If lRetVet // Retorna Vetor com os Orcamento e OSs + Tipo de Tempo com valor de Pe็as e Servi็os
					nPosVet := aScan(aRetVet, {|x| x[1]+x[2]+x[3]+x[4] == "2" + cFilVO4 + ( cQAlVO4 )->VO4_NUMOSV + ( cQAlVO4 )->VO4_TIPTEM })
					If nPosVet == 0 
						aAdd(aRetVet,{ "2" , cFilVO4 , ( cQAlVO4 )->VO4_NUMOSV , ( cQAlVO4 )->VO4_TIPTEM , 0 , 0 , 0 })
						nPosVet := len(aRetVet)
					EndIf
					aRetVet[nPosVet,6] += nVlrAux // Valor Servicos
					aRetVet[nPosVet,7] += nVlrAux // Valor Total
				EndIf

				( cQAlVO4 )->( DbSkip() )

			EndDo
			( cQAlVO4 )->( DbCloseArea() )

			// Levantamento de pecas Oficina
			cQuery := "SELECT DISTINCT VO3.VO3_NUMOSV, VO3.VO3_TIPTEM FROM "+RetSqlName("VO3")+" VO3 "
			cQuery += "INNER JOIN "+RetSQLName("VOI")+" VOI ON VOI.VOI_FILIAL='"+xFilial("VOI")+"' AND VOI.VOI_TIPTEM=VO3.VO3_TIPTEM AND VOI.D_E_L_E_T_=' ' "
			cQuery += "WHERE VO3.VO3_FILIAL='"+xFilial("VO3")+"' AND "
			cQuery += "VO3.VO3_FATPAR='"+cCodCli+"' AND "
			If cCreCli == "L"
				cQuery += "VO3.VO3_LOJA='"+cLoja+"' AND "
			EndIf
			cQuery += "VO3.VO3_DATFEC = '        ' AND VO3.VO3_DATCAN = '        ' AND "
			cQuery += "VOI.VOI_SITTPO='1' AND "
			cQuery += "VO3.D_E_L_E_T_=' ' "
			If ExistBlock("PEQRYACR")
				cRetorno := ExecBlock("PEQRYACR",.f.,.f.,{"VO3",cQuery,cCodCli,cLoja}) // Ponto de entrada para manipulacao da query.
				if !Empty(cRetorno)
					cQuery := cRetorno
				Endif
			EndIf
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO3 , .F., .T. )

			cPulaReg := ""
			While !( cQAlVO3 )->( Eof() )

				aCodPec := FMX_CALPEC(( cQAlVO3 )->VO3_NUMOSV, ( cQAlVO3 )->VO3_TIPTEM,,,.f.,.t.,.t.,.t.,.t.,.f.,.f.)

				nVlrAux := 0
				aEval( aCodPec , { |x| nVlrAux += x[PECA_VALBRU] - x[PECA_VALDES] } )   // Valor Peca
				nValor += nVlrAux

				If lRetVet // Retorna Vetor com os Orcamento e OSs + Tipo de Tempo com valor de Pe็as e Servi็os
					nPosVet := aScan(aRetVet, {|x| x[1]+x[2]+x[3]+x[4] == "2" + cFilVO3 + ( cQAlVO3 )->VO3_NUMOSV + ( cQAlVO3 )->VO3_TIPTEM })
					If nPosVet == 0 
						aAdd(aRetVet,{ "2" , cFilVO3 , ( cQAlVO3 )->VO3_NUMOSV , ( cQAlVO3 )->VO3_TIPTEM , 0 , 0 , 0 })
						nPosVet := len(aRetVet)
					EndIf
					aRetVet[nPosVet,5] += nVlrAux // Valor Pecas
					aRetVet[nPosVet,7] += nVlrAux // Valor Total
				EndIf

				( cQAlVO3 )->( DbSkip() )

			EndDo
			( cQAlVO3 )->( DbCloseArea() )

			// Levantamento de pecas Balcao / Oficina
			If lRetVet // Retorna Vetor com os Orcamento e OSs + Tipo de Tempo com valor de Pe็as e Servi็os
				cQuery := "SELECT VS3.VS3_NUMORC , SUM(VS3.VS3_VALTOT) AS VLR "
			Else
				cQuery := "SELECT SUM(VS3.VS3_VALTOT) AS VLR "
			EndIf
			cQuery += " FROM "+RetSqlName("VS1")+" VS1 "
			cQuery += "INNER JOIN "+RetSqlName("VS3")+" VS3 ON VS3.VS3_FILIAL=VS1.VS1_FILIAL AND VS3.VS3_NUMORC=VS1.VS1_NUMORC AND VS3.VS3_VALTOT > 0 AND VS3.D_E_L_E_T_=' '"
			cQuery += "LEFT JOIN "+RetSQLName("VOI")+" VOI ON VOI.VOI_FILIAL='"+xFilial("VOI")+"' AND VOI.VOI_TIPTEM=VS1.VS1_TIPTEM AND VOI.D_E_L_E_T_=' ' "
			cQuery += "WHERE VS1.VS1_FILIAL='"+cFilVS1+"' AND "
			cQuery += "VS1.VS1_STATUS NOT IN (' ','X','C','0','I') AND "
			cQuery += "VS1.VS1_CLIFAT='"+cCodCli+"' AND "
			If cCreCli == "L"
				cQuery += "VS1.VS1_LOJA='"+cLoja+"' AND "
			EndIf
			cQuery += "(VS1.VS1_TIPORC='1' OR (VS1.VS1_TIPORC='2' AND VOI.VOI_SITTPO='1')) AND "
			cQuery += " VS1.VS1_DATVAL >= '"+dtos(dDataBase)+"' AND VS1.D_E_L_E_T_=' ' "
			If !Empty(cCondNAO) // Desconsiderar no Levantamento do Limite de Credito as Condicoes de Pagamento contidas no parametro MV_MIL0158
				cQuery += " AND VS1.VS1_FORPAG NOT IN " + FormatIN(cCondNAO,"/") + " "
			EndIf
			If lRetVet // Retorna Vetor com os Orcamento e OSs + Tipo de Tempo com valor de Pe็as e Servi็os
				cQuery += " GROUP BY VS3.VS3_NUMORC "
			EndIf
			If ExistBlock("PEQRYACR")
				cRetorno := ExecBlock("PEQRYACR",.f.,.f.,{"VS1",cQuery,cCodCli,cLoja}) // Ponto de entrada para manipulacao da query.
				if !Empty(cRetorno)
					cQuery := cRetorno
				Endif
			EndIf
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS1 , .F., .T. )
			While !( cQAlVS1 )->( Eof() )

				nVlrAux := ( cQAlVS1 )->( VLR )   // Valor Peca
				nValor += nVlrAux

				If lRetVet // Retorna Vetor com os Orcamento e OSs + Tipo de Tempo com valor de Pe็as e Servi็os
					nPosVet := aScan(aRetVet, {|x| x[1]+x[2]+x[3] == "1" + cFilVS1 + ( cQAlVS1 )->VS3_NUMORC })
					If nPosVet == 0 
						aAdd(aRetVet,{ "1" , cFilVS1 , ( cQAlVS1 )->VS3_NUMORC , "" , 0 , 0 , 0 })
						nPosVet := len(aRetVet)
					EndIf
					aRetVet[nPosVet,5] += nVlrAux // Valor Pecas
					aRetVet[nPosVet,7] += nVlrAux // Valor Total
				EndIf

				( cQAlVS1 )->( DbSkip() )

			EndDo
			( cQAlVS1 )->( DbCloseArea() )

			// Levantamento de servicos Oficina
			If lRetVet // Retorna Vetor com os Orcamento e OSs + Tipo de Tempo com valor de Pe็as e Servi็os
				cQuery := "SELECT VS4.VS4_NUMORC , SUM(VS4.VS4_VALSER) AS VLR "
			Else
				cQuery := "SELECT SUM(VS4.VS4_VALSER) AS VLR "
			EndIf
			cQuery += " FROM "+RetSqlName("VS1")+" VS1 "
			cQuery += "INNER JOIN "+RetSqlName("VS4")+" VS4 ON VS4.VS4_FILIAL=VS1.VS1_FILIAL AND VS4.VS4_NUMORC=VS1.VS1_NUMORC AND VS4.VS4_VALSER > 0 AND VS4.D_E_L_E_T_=' '"
			cQuery += "LEFT JOIN "+RetSQLName("VOI")+" VOI ON VOI.VOI_FILIAL='"+xFilial("VOI")+"' AND "
			if VS1->(FieldPos("VS1_TIPTSV"))>0
				cQuery += "VOI.VOI_TIPTEM=VS1.VS1_TIPTSV AND VOI.D_E_L_E_T_=' ' "
			Else
				cQuery += "VOI.VOI_TIPTEM=VS1.VS1_TIPTEM AND VOI.D_E_L_E_T_=' ' "
			Endif
			cQuery += "WHERE VS1.VS1_FILIAL='"+cFilVS1+"' AND "
			cQuery += "VS1.VS1_STATUS NOT IN (' ','X','C','0','I') AND "
			cQuery += "VS1.VS1_CLIFAT='"+cCodCli+"' AND "
			If cCreCli == "L"
				cQuery += "VS1.VS1_LOJA='"+cLoja+"' AND "
			EndIf
			cQuery += "VS1.VS1_TIPORC='2' AND VOI.VOI_SITTPO='1' AND "
			cQuery += " VS1.VS1_DATVAL >= '"+dtos(dDataBase)+"' AND VS1.D_E_L_E_T_=' ' "
			If !Empty(cCondNAO) // Desconsiderar no Levantamento do Limite de Credito as Condicoes de Pagamento contidas no parametro MV_MIL0158
				cQuery += " AND VS1.VS1_FORPAG NOT IN " + FormatIN(cCondNAO,"/") + " "
			EndIf
			If lRetVet // Retorna Vetor com os Orcamento e OSs + Tipo de Tempo com valor de Pe็as e Servi็os
				cQuery += " GROUP BY VS4.VS4_NUMORC "
			EndIf
			If ExistBlock("PEQRYACR")
				cRetorno := ExecBlock("PEQRYACR",.f.,.f.,{"VS1",cQuery,cCodCli,cLoja}) // Ponto de entrada para manipulacao da query.
				if !Empty(cRetorno)
					cQuery := cRetorno
				Endif
			EndIf
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS1 , .F., .T. )
			While !( cQAlVS1 )->( Eof() )

				nVlrAux := ( cQAlVS1 )->( VLR )   // Valor Servicos
				nValor += nVlrAux

				If lRetVet // Retorna Vetor com os Orcamento e OSs + Tipo de Tempo com valor de Pe็as e Servi็os
					nPosVet := aScan(aRetVet, {|x| x[1]+x[2]+x[3] == "1" + cFilVS1 + ( cQAlVS1 )->VS4_NUMORC })
					If nPosVet == 0 
						aAdd(aRetVet,{ "1" , cFilVS1 , ( cQAlVS1 )->VS4_NUMORC , "" , 0 , 0 , 0 })
						nPosVet := len(aRetVet)
					EndIf
					aRetVet[nPosVet,6] += nVlrAux // Valor Servicos
					aRetVet[nPosVet,7] += nVlrAux // Valor Total
				EndIf

				( cQAlVS1 )->( DbSkip() )

			EndDo
			( cQAlVS1 )->( DbCloseArea() )

		EndIf
	Next
	cFilAnt := cBkpFilAnt

	If Empty(cSele) // Seleciona SA1 quando nao esta posicionado em nenhuma area (ERRO SQL)
		cSele := "SA1"
	EndIf
	DbSelectArea(cSele)
	// Restaura a area
	sRestArea(aArea)
	DbSelectArea(cSele)
Return( nValor )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo    ณ FG_CALTEMณ Autor ณ  Emilton              ณ Data ณ 24/08/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri็ใo ณ Calcula tempo e valores dos produtivos                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cCodPro - C๓digo do Produtivo                              ณฑฑ
ฑฑณ          ณ dDatRef - Data de Refer๊ncia para o Levantamento           ณฑฑ
ฑฑณ          ณ cAssunto- Assunto que a fun็ใo irแ levantar                ณฑฑ
ฑฑณ          ณ           0 - Horas Disponํvel                             ณฑฑ
ฑฑณ          ณ           1 - Horas Padrใo                                 ณฑฑ
ฑฑณ          ณ           2 - Horas Trabalhadas                            ณฑฑ
ฑฑณ          ณ           3 - Horas Extras                                 ณฑฑ
ฑฑณ          ณ           4 - Horas Ausentes                               ณฑฑ
ฑฑณ          ณ           5 - Horas Vendidas                               ณฑฑ
ฑฑณ          ณ           6 - Horas Cobradas - Requisicao                  ณฑฑ
ฑฑณ          ณ           7 - Valor de Venda do Servi็o                    ณฑฑ
ฑฑณ          ณ           8 - Quantidade Requisitada de Pe็as              ณฑฑ
ฑฑณ          ณ           9 - Estoque de Horas Liberadas                   ณฑฑ
ฑฑณ          ณ           A - Estoque de Horas Nao Liberadas               ณฑฑ
ฑฑณ          ณ           B - Formula do Usuario                           ณฑฑ
ฑฑณ          ณ           C - Horas Cobradas - Venda                       ณฑฑ
ฑฑณ          ณ           D - Totalizador de Pecas (Balcao/Oficina)        ณฑฑ
ฑฑณ          ณ               com o parametro cTipTot                      ณฑฑ
ฑฑณ          ณ           E - Totalizador de Pecas por Situacao de Tipo de ณฑฑ
ฑฑณ          ณ               Tempo ou por Tipo de Tempo                   ณฑฑ
ฑฑณ          ณ           F - Total de Passagens                           ณฑฑ
ฑฑณ          ณ           G - Horas Trabalhadas e Fechadas (Audi)          ณฑฑ
ฑฑณ          ณ           I - Horas Vendidas                               ณฑฑ
ฑฑณ          ณ dDatFin - Data Final                                       ณฑฑ
ฑฑณ          ณ dCodFor - Codigo da Formula para levantamento de dados paraณฑฑ
ฑฑณ          ณ           o usuario (Formula tem que retornar numerico)    ณฑฑ
ฑฑณ          ณ cTipTot - Tipo de Total - Sera utilizado para totalizar   -ณฑฑ
ฑฑณ          ณ           servicos e pecas. Se o parametro passado for "A" ณฑฑ
ฑฑณ          ณ           o sistema olhara o parametro cTipAgr para totali-ณฑฑ
ฑฑณ          ณ           zar o os valores de Pecas/Servicos.  Se o parame-ณฑฑ
ฑฑณ          ณ           tro passado for "T" o sistema olhara o parametro ณฑฑ
ฑฑณ          ณ           cTipTem para totalizar os valores de Pecas/Srvc. ณฑฑ
ฑฑณ          ณ           Para os casos de levantamento do total  de passa-ณฑฑ
ฑฑณ          ณ           gens de veiculo, a funcao ira olhar o parametro  ณฑฑ
ฑฑณ          ณ           cTipPas que ira determinar a forma de fazer a   -ณฑฑ
ฑฑณ          ณ           das passagens, se igual a "A" o sistema ira con -ณฑฑ
ฑฑณ          ณ           tar as passagens das OS's abertas no mes, se for ณฑฑ
ฑฑณ          ณ           igual a "F" o sistema contara as OS's fechadas noณฑฑ
ฑฑณ          ณ           mes, respeitando a forma do cTipTot              ณฑฑ
ฑฑณ          ณ           Quando o parametro for "R", o sistema ira dar traณฑฑ
ฑฑณ          ณ           tamento especial para RMS da Volkswagen (Passeio)ณฑฑ
ฑฑณ          ณ           Acompanhando o parametro cAssunto == D a funcao  ณฑฑ
ฑฑณ          ณ           trara o total de pecas balcao quando cTipTot == Bณฑฑ
ฑฑณ          ณ           e quando cTipTot == O trara vlr de pecas oficina ณฑฑ
ฑฑณ          ณ cTipAgr - 1 - Publico                                      ณฑฑ
ฑฑณ          ณ           2 - Garantia                                     ณฑฑ
ฑฑณ          ณ           3 - Interno                                      ณฑฑ
ฑฑณ          ณ           4 - Revisao                                      ณฑฑ
ฑฑณ          ณ cTipTem - Tipo de tempo que se deseja totalizar            ณฑฑ
ฑฑณ          ณ cTipPas - Tipo de Levantamento para contar as passagens dosณฑฑ
ฑฑณ          ณ           na oficina "F" traz fechadas e "A" abertas       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_CALTEM(cCodPro,dDatRef,cAssunto,dDatFin,cCodFor,cTipTot,cTipAgr,cTipTem,cTipPas)

	Local nRet     := 0
	Local aRet     := {}
	Local aRetV    := {}
	
	
	
	
	Local aVerPad  := {}
	Local aVetTra  := {}
	Local ix1      := 0
	Local cSele    := Alias()
	Local dDatIni  := dDatRef

	

	Local MVD_PAR01 := ""
	Local MVD_PAR02 := ""
	Local MVD_PAR03 := ""
	Local MVD_PAR04 := ""
	Local MVD_PAR05 := ""
	Local MVD_PAR06 := ""
	Local MVD_PAR07 := ""
	Local MVD_PAR08 := ""
	Local MVD_PAR09 := ""
	Local MVD_PAR10 := ""
	Local MVD_PAR11 := ""
	Local MVD_PAR12 := ""
	Local MVD_PAR13 := ""
	Local MVD_PAR14 := ""

	Local MVT_PAR01 := ""
	Local MVT_PAR02 := ""
	Local MVT_PAR03 := ""
	Local MVT_PAR04 := ""
	Local MVT_PAR05 := ""
	Local MVT_PAR06 := ""
	Local MVT_PAR07 := ""
	Local MVT_PAR08 := ""
	Local MVT_PAR09 := ""
	Local MVT_PAR10 := ""
	Local MVT_PAR11 := ""
	Local MVT_PAR12 := ""
	Local MVT_PAR13 := ""
	Local MVT_PAR14 := ""
	Local MVT_PAR15 := ""
	Local MVT_PAR16 := ""
	Local MVT_PAR17 := ""
	Local MVT_PAR18 := ""
	Local MVT_PAR19 := ""
	Local MVT_PAR20 := ""
	Local MVT_PAR21 := ""
	Local MVT_PAR22 := ""
	Local MVT_PAR23 := ""
	Local MVT_PAR24 := ""
	Local MVT_PAR25 := ""
	Local MVT_PAR26 := ""

	Local ix1_      := 0
	Local cVar1_    := ""
	Local cVar2_    := ""

	For ix1_ := 1 to 30

		cVar1_ := "MV_PAR"+strzero(ix1_,2)
		If &cVar1_ == Nil
			Exit
		EndIf
		cVar2_  := "MVB_PAR"+strzero(ix1_,2)
		&cVar2_ := &cVar1_

	Next

	Pergunte("OFR170",.F.) // ADO
	MVD_PAR01 := MV_PAR01
	MVD_PAR02 := MV_PAR02
	MVD_PAR03 := MV_PAR03
	MVD_PAR04 := MV_PAR04
	MVD_PAR05 := MV_PAR05
	MVD_PAR06 := MV_PAR06
	MVD_PAR07 := MV_PAR07
	MVD_PAR08 := MV_PAR08
	MVD_PAR09 := MV_PAR09
	MVD_PAR10 := MV_PAR10
	MVD_PAR11 := MV_PAR11
	MVD_PAR12 := MV_PAR12
	MVD_PAR13 := MV_PAR13
	MVD_PAR14 := MV_PAR14

	Pergunte("OFR190",.F.) // ATO
	MVT_PAR01 := MV_PAR01
	MVT_PAR02 := MV_PAR02
	MVT_PAR03 := MV_PAR03
	MVT_PAR04 := MV_PAR04
	MVT_PAR05 := MV_PAR05
	MVT_PAR06 := MV_PAR06
	MVT_PAR07 := MV_PAR07
	MVT_PAR08 := MV_PAR08
	MVT_PAR09 := MV_PAR09
	MVT_PAR10 := MV_PAR10
	MVT_PAR11 := MV_PAR11
	MVT_PAR12 := MV_PAR12
	MVT_PAR13 := MV_PAR13
	MVT_PAR14 := MV_PAR14
	MVT_PAR15 := MV_PAR15
	MVT_PAR16 := MV_PAR16
	MVT_PAR17 := MV_PAR17
	MVT_PAR18 := MV_PAR18
	MVT_PAR19 := MV_PAR19
	MVT_PAR20 := MV_PAR20
	MVT_PAR21 := MV_PAR21
	MVT_PAR22 := MV_PAR22
	MVT_PAR23 := MV_PAR23
	MVT_PAR24 := MV_PAR24
	MVT_PAR25 := MV_PAR25
	MVT_PAR26 := MV_PAR26

	Do Case
		Case cAssunto == "0"  // Horas Disponiveis

		If dDatFin == Nil
			dDatFin := dDatRef
		EndIf

		dbSelectArea("VAI")
		dbSetOrder(1)
		If dbSeek(xFilial("VAI")+cCodPro,.f.) .and. VAI->VAI_FUNPRO == "1"

			For dDatRef := dDatIni to dDatFin

				If !Empty(VAI->VAI_DATDEM) .and. dDatRef > VAI->VAI_DATDEM
					Loop
				EndIf

				//               nRet += FG_TEMPTRA(cCodPro,dDatRef,0,dDatRef,2359,"N",.f.,"D/O")

				DbSelectArea("VOE")
				DbSetOrder(1)
				If !DbSeek(xFilial("VOE")+cCodPro+Dtos(dDatRef),.t.)

					If eof()
						dbskip(-1)
					Endif
					while xFilial("VOE") == VOE->VOE_FILIAL .and. !bof()

						if( VOE->VOE_FILIAL+VOE->VOE_CODPRO # xFilial("VOE")+cCodPro .Or. ;
						( VOE->VOE_FILIAL+VOE->VOE_CODPRO == xFilial("VOE")+cCodPro  .and. VOE->VOE_DATESC > (dDatRef) ))
							DbSkip(-1)
							loop
						EndIf
						Exit

					EndDo

				EndIf

				If VOE->VOE_CODPRO == cCodPro

					DbSelectArea("VOH")
					DbSetOrder(1)
					If DbSeek(xFilial("VOH")+VOE->VOE_CODPER)

						aVetDis := {}
						Aadd( aVetDis ,VOH->VOH_INIPER)
						Aadd( aVetDis ,VOH->VOH_INICF1)
						Aadd( aVetDis ,VOH->VOH_FINCF1)
						Aadd( aVetDis ,VOH->VOH_INIREF)
						Aadd( aVetDis ,VOH->VOH_FINREF)
						Aadd( aVetDis ,VOH->VOH_INICF2)
						Aadd( aVetDis ,VOH->VOH_FINCF2)
						Aadd( aVetDis ,VOH->VOH_FINPER)

						For ix1:=1 to (Len(aVetDis)-1)
							For ix1_:=(ix1+1) to Len(aVetDis)
								If !Empty(aVetDis[ix1]) .And. !Empty(aVetDis[ix1_])
									nRet += FS_VLSERTP(dDatRef,aVetDis[ix1],dDatRef,(aVetDis[ix1_]+If(aVetDis[ix1_]<aVetDis[ix1],2400,0)))
									ix1:=ix1_
									Exit
								EndIf
							Next
						Next

					EndIf

				EndIf

			Next

		EndIf

		Case cAssunto == "1"  // Horas Padrao

		dbSelectArea("VO4")
		dbSetOrder(2)

		If dDatFin == Nil

			//           If dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef))
			dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef))

			While VO4->VO4_CODPRO == cCodPro .And. VO4->VO4_DATINI == dDatRef .And. VO4->VO4_FILIAL == xFilial("VO4") .And. !Eof()

				If !Empty(VO4->VO4_DATCAN)
					dbSelectArea("VO4")
					dbSkip()
					Loop
				EndIf

				Do Case
					Case cTipTot == Nil .or. cTipTot == "G"
					ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
					If ix1 == 0
						aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
						nRet += VO4->VO4_TEMPAD
					EndIf
					Case cTipTot == "A"
					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
					If cTipAgr == VOI->VOI_SITTPO
						ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
						If ix1 == 0
							aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
							nRet += VO4->VO4_TEMPAD
						EndIf
					EndIf
					Case cTipTot == "T"
					If cTipTem == VO4->VO4_TIPTEM
						ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
						If ix1 == 0
							aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
							nRet += VO4->VO4_TEMPAD
						EndIf
					EndIf
				EndCase
				dbSelectArea("VO4")
				dbSkip()

			EndDo

			//           EndIf

		Else

			dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef),.t.)

			While VO4->VO4_CODPRO == cCodPro .And. VO4->VO4_FILIAL == xFilial("VO4") .And. !Eof()

				If !Empty(VO4->VO4_DATCAN)
					dbSelectArea("VO4")
					dbSkip()
					Loop
				EndIf

				If VO4->VO4_DATINI < dDatRef
					dbskip()
					Loop
				EndIf

				If VO4->VO4_DATINI > dDatFin
					Exit
				EndIf

				Do Case
					Case cTipTot == Nil .or. cTipTot == "G"
					ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
					If ix1 == 0
						aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
						nRet += VO4->VO4_TEMPAD
					EndIf
					Case cTipTot == "A"
					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
					If cTipAgr == VOI->VOI_SITTPO
						ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
						If ix1 == 0
							aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
							nRet += VO4->VO4_TEMPAD
						EndIf
					EndIf
					Case cTipTot == "T"
					If cTipTem == VO4->VO4_TIPTEM
						ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
						If ix1 == 0
							aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
							nRet += VO4->VO4_TEMPAD
						EndIf
					EndIf
				EndCase
				dbSelectArea("VO4")
				dbSkip()

			EndDo

		EndIf

		Case cAssunto $ "2/3"  // Horas Trabalhadas/Extras

		aAdd(aRet,{0,0})  // Passagens de Servico Rapido
		aAdd(aRet,{0,0})  // Passagens Internas
		aAdd(aRet,{0,0})  // Passagens Total
		dbSelectArea("VO4")
		dbSetOrder(2)

		If dDatFin == Nil

			//           If dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef))
			dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef))

			While VO4->VO4_CODPRO == cCodPro .And. VO4->VO4_DATINI == dDatRef .And. VO4->VO4_FILIAL == xFilial("VO4") .And. !Eof()

				If !Empty(VO4->VO4_DATCAN)
					dbSkip()
					Loop
				EndIf

				Do Case
					Case cTipTot == Nil .or. cTipTot == "G"

					If cAssunto == "2" .And. VO4->VO4_HOREXT == "O"
						nRet += VO4->VO4_TEMTRA
					EndIf
					If cAssunto == "3" .And. VO4->VO4_HOREXT == "E"
						nRet += VO4->VO4_TEMTRA
					EndIf

					Case cTipTot == "A"

					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
					If cTipAgr == VOI->VOI_SITTPO
						If cAssunto == "2" .And. VO4->VO4_HOREXT == "O"
							nRet += VO4->VO4_TEMTRA
						EndIf
						If cAssunto == "3" .And. VO4->VO4_HOREXT == "E"
							nRet += VO4->VO4_TEMTRA
						EndIf
					EndIf

					Case cTipTot == "T"

					If cTipTem == VO4->VO4_TIPTEM
						If cAssunto == "2" .And. VO4->VO4_HOREXT == "O"
							nRet += VO4->VO4_TEMTRA
						EndIf
						If cAssunto == "3" .And. VO4->VO4_HOREXT == "E"
							nRet += VO4->VO4_TEMTRA
						EndIf
					EndIf

					Case cTipTot == "R"

					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
					DbSelectArea("VOK")
					DbSetOrder(1)
					DbSeek( xFilial("VOK") + VO4->VO4_TIPSER )

					// Considera Hora Extra

					Do Case
						Case VOI->VOI_SITTPO == "3" // .or. VOK->VOK_TIPHOR == "2"

						If VAI->VAI_FUNCAO $ MVT_PAR25
							aRet[02,01] += VO4->VO4_TEMTRA
						EndIf

						If VAI->VAI_FUNCAO $ MVT_PAR26
							aRet[02,02] += VO4->VO4_TEMTRA
						EndIf

						//                          Case VO4->VO4_CODSEC $ MVD_PAR01
						//
						//                               aRet[01,01] += VO4->VO4_TEMTRA
						//                               aRet[01,02] := 0
						//
						//                               dbSelectArea("VO4")
						//                               dbSkip()

						Otherwise

						If VAI->VAI_FUNCAO $ MVT_PAR25
							aRet[03,01] += VO4->VO4_TEMTRA
						EndIf

						If VAI->VAI_FUNCAO $ MVT_PAR26
							aRet[03,02] += VO4->VO4_TEMTRA
						EndIf

					EndCase

				EndCase
				dbSelectArea("VO4")
				dbSkip()

			EndDo

			//EndIf

		Else

			//           If dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef),.t.)
			dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef),.t.)

			While VO4->VO4_CODPRO == cCodPro .And. VO4->VO4_FILIAL == xFilial("VO4") .And. !Eof()

				If !Empty(VO4->VO4_DATCAN)
					dbSkip()
					Loop
				EndIf

				If VO4->VO4_DATINI < dDatRef
					dbskip()
					Loop
				EndIf

				If VO4->VO4_DATINI > dDatFin
					Exit
				EndIf

				Do Case
					Case cTipTot == Nil .or. cTipTot == "G"

					If cAssunto == "2" .And. VO4_HOREXT == "O"
						nRet += VO4->VO4_TEMTRA
					EndIf
					If cAssunto == "3" .And. VO4_HOREXT == "E"
						nRet += VO4->VO4_TEMTRA
					EndIf

					Case cTipTot == "A"

					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
					If cTipAgr == VOI->VOI_SITTPO
						If cAssunto == "2" .And. VO4->VO4_HOREXT == "O"
							nRet += VO4->VO4_TEMTRA
						EndIf
						If cAssunto == "3" .And. VO4->VO4_HOREXT == "E"
							nRet += VO4->VO4_TEMTRA
						EndIf
					EndIf

					Case cTipTot == "T"

					If cTipTem == VO4->VO4_TIPTEM
						If cAssunto == "2" .And. VO4->VO4_HOREXT == "O"
							nRet += VO4->VO4_TEMTRA
						EndIf
						If cAssunto == "3" .And. VO4->VO4_HOREXT == "E"
							nRet += VO4->VO4_TEMTRA
						EndIf
					EndIf

					Case cTipTot == "R"

					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
					DbSelectArea("VOK")
					DbSetOrder(1)
					DbSeek( xFilial("VOK") + VO4->VO4_TIPSER )

					// Considera Hora Extra

					Do Case
						Case VOI->VOI_SITTPO == "3" // .or. VOK->VOK_TIPHOR == "2"

						If VAI->VAI_FUNCAO $ MVT_PAR25
							aRet[02,01] += VO4->VO4_TEMTRA
						EndIf

						If VAI->VAI_FUNCAO $ MVT_PAR26
							aRet[02,02] += VO4->VO4_TEMTRA
						EndIf

						//                            Case VO4->VO4_CODSEC $ MVD_PAR01
						//
						//                                 aRet[01,01] += VO4->VO4_TEMTRA
						//                                 aRet[01,02] := 0

						Otherwise

						If VAI->VAI_FUNCAO $ MVT_PAR25
							aRet[03,01] += VO4->VO4_TEMTRA
						EndIf

						If VAI->VAI_FUNCAO $ MVT_PAR26
							aRet[03,02] += VO4->VO4_TEMTRA
						EndIf

					EndCase

				EndCase
				dbSelectArea("VO4")
				dbSkip()

			EndDo

			//           EndIf

		EndIf

		If cTipTot == "R"
			nRet := aRet
		EndIf

		Case cAssunto == "4"  // Horas Ausentes

		dbSelectArea("VO4")
		dbSetOrder(2)

		If dDatFin == Nil

			//           If dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef))
			dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef))

			While VO4->VO4_CODPRO == cCodPro .And. VO4->VO4_DATINI == dDatRef .And. VO4->VO4_FILIAL == xFilial("VO4") .And. !Eof()

				nRet += VO4->VO4_TEMAUS
				dbSkip()

			EndDo

			//EndIf

		Else

			//           If dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef),.t.)
			dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef),.t.)

			While VO4->VO4_CODPRO == cCodPro .And. VO4->VO4_FILIAL == xFilial("VO4") .And. !Eof()

				If VO4->VO4_DATINI < dDatRef
					dbskip()
					Loop
				EndIf

				If VO4->VO4_DATINI > dDatFin
					Exit
				EndIf
				nRet += VO4->VO4_TEMAUS
				dbSkip()

			EndDo

			//           EndIf

		EndIf

		Case cAssunto == "5"  // Horas Vendidas

		dbSelectArea("VO4")
		dbSetOrder(2)

		If dDatFin == Nil

			//           If dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef))
			dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef))

			While VO4->VO4_CODPRO == cCodPro .And. VO4->VO4_DATINI == dDatRef .And. VO4->VO4_FILIAL == xFilial("VO4") .And. !Eof()

				If !Empty(VO4->VO4_DATCAN)
					dbSelectArea("VO4")
					dbSkip()
					Loop
				EndIf

				Do Case
					Case cTipTot == Nil .or. cTipTot == "G"

					dbSelectArea("VOK")
					dbSetOrder(1)
					If dbSeek(xFilial("VOK")+VO4->VO4_TIPSER)
						If VOK->VOK_INCTEM == "3"
							nRet += VO4->VO4_TEMTRA
						Else
							ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
							If ix1 == 0
								aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
								nRet += VO4->VO4_TEMVEN
							EndIf
						EndIf
					EndIf

					Case cTipTot == "A"

					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
					If cTipAgr == VOI->VOI_SITTPO
						dbSelectArea("VOK")
						dbSetOrder(1)
						If dbSeek(xFilial("VOK")+VO4->VO4_TIPSER)
							If VOK->VOK_INCTEM == "3"
								nRet += VO4->VO4_TEMTRA
							Else
								ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
								If ix1 == 0
									aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
									nRet += VO4->VO4_TEMVEN
								EndIf
							EndIf
						EndIf
					EndIf

					Case cTipTot == "T"

					If cTipTem == VO4->VO4_TIPTEM
						dbSelectArea("VOK")
						dbSetOrder(1)
						If dbSeek(xFilial("VOK")+VO4->VO4_TIPSER)
							If VOK->VOK_INCTEM == "3"
								nRet += VO4->VO4_TEMTRA
							Else
								ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
								If ix1 == 0
									aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
									nRet += VO4->VO4_TEMVEN
								EndIf
							EndIf
						EndIf
					EndIf
				EndCase

				dbSelectArea("VO4")
				dbSkip()

			EndDo

			//           EndIf

		Else

			dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef),.t.)

			While VO4->VO4_CODPRO == cCodPro .And. VO4->VO4_FILIAL == xFilial("VO4") .And. !Eof()

				If !Empty(VO4->VO4_DATCAN)
					dbSelectArea("VO4")
					dbSkip()
					Loop
				EndIf

				If VO4->VO4_DATINI < dDatRef
					dbskip()
					Loop
				EndIf

				If VO4->VO4_DATINI > dDatFin
					Exit
				EndIf

				Do Case
					Case cTipTot == Nil .or. cTipTot == "G"

					dbSelectArea("VOK")
					dbSetOrder(1)
					If dbSeek(xFilial("VOK")+VO4->VO4_TIPSER)
						If VOK->VOK_INCTEM == "3"
							nRet += VO4->VO4_TEMTRA
						Else
							ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
							If ix1 == 0
								aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
								nRet += VO4->VO4_TEMVEN
							EndIf
						EndIf
					EndIf

					Case cTipTot == "A"

					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
					If cTipAgr == VOI->VOI_SITTPO
						dbSelectArea("VOK")
						dbSetOrder(1)
						If dbSeek(xFilial("VOK")+VO4->VO4_TIPSER)
							If VOK->VOK_INCTEM == "3"
								nRet += VO4->VO4_TEMTRA
							Else
								ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
								If ix1 == 0
									aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
									nRet += VO4->VO4_TEMVEN
								EndIf
							EndIf
						EndIf
					EndIf

					Case cTipTot == "T"

					If cTipTem == VO4->VO4_TIPTEM
						dbSelectArea("VOK")
						dbSetOrder(1)
						If dbSeek(xFilial("VOK")+VO4->VO4_TIPSER)
							If VOK->VOK_INCTEM == "3"
								nRet += VO4->VO4_TEMTRA
							Else
								ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
								If ix1 == 0
									aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
									nRet += VO4->VO4_TEMVEN
								EndIf
							EndIf
						EndIf
					EndIf

				EndCase

				dbSelectArea("VO4")
				dbSkip()

			EndDo

		EndIf

		Case cAssunto == "6"  //  Horas Cobradas - Requisicao

		dbSelectArea("VO4")
		dbSetOrder(2)

		If dDatFin == Nil

			//           If dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef))
			dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef))

			While VO4->VO4_CODPRO == cCodPro .And. VO4->VO4_DATINI == dDatRef .And. VO4->VO4_FILIAL == xFilial("VO4") .And. !Eof()

				If !Empty(VO4->VO4_DATCAN)
					dbSkip()
					Loop
				EndIf

				Do Case
					Case cTipTot == Nil .or. cTipTot == "G"

					nRet += VO4->VO4_TEMCOB

					Case cTipTot == "A"

					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
					If cTipAgr == VOI->VOI_SITTPO
						nRet += VO4->VO4_TEMCOB
					EndIf

					Case cTipTot == "T"

					If cTipTem == VO4->VO4_TIPTEM
						nRet += VO4->VO4_TEMCOB
					EndIf

				EndCase
				dbSelectAre("VO4")
				dbSkip()

			EndDo

			//           EndIf

		Else

			//           If dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef),.t.)
			dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef),.t.)

			While VO4->VO4_CODPRO == cCodPro .And. VO4->VO4_FILIAL == xFilial("VO4") .And. !Eof()

				If !Empty(VO4->VO4_DATCAN)
					dbSkip()
					Loop
				EndIf

				If VO4->VO4_DATINI < dDatRef
					dbskip()
					Loop
				EndIf

				If VO4->VO4_DATINI > dDatFin
					Exit
				EndIf

				Do Case
					Case cTipTot == Nil .or. cTipTot == "G"

					nRet += VO4->VO4_TEMCOB

					Case cTipTot == "A"

					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
					If cTipAgr == VOI->VOI_SITTPO
						nRet += VO4->VO4_TEMCOB
					EndIf

					Case cTipTot == "T"

					If cTipTem == VO4->VO4_TIPTEM
						nRet += VO4->VO4_TEMCOB
					EndIf

				EndCase
				dbSelectArea("VO4")
				dbSkip()

			EndDo

			//           EndIf

		EndIf

		Case cAssunto $ "7/C/G/I"  //  7 - Valor de Servi็o Vendido
		//  C - Total de Horas Cobradas por Situacao do Tipo de Tempo e Tipo de Tempo
		//  G - Total de Horas Trabalhadas e Fechadas por Situacao do Tipo de Tempo e Tipo de Tempo
		//  I - Total de Horas Vendidas por Situacao do Tipo de Tempo e Tipo de Tempo

		aAdd(aRetV,0)  // Servicos Rapido
		aAdd(aRetV,0)  // Servicos Gerais
		aAdd(aRetV,0)  // Servicos de Carroceria
		aAdd(aRet,{0,0})
		aAdd(aRet,{0,0})
		aAdd(aRet,{0,0})

		If dDatFin == Nil

			dbSelectArea("VSC")
			dbSetOrder(5)
			dbSeek( xFilial("VSC") + DtoS(dDatRef),.t.)

			While VSC->VSC_FILIAL == xFilial("VSC") .And. !Eof()

				If VSC->VSC_DATVEN < dDatRef
					dbSkip()
					Loop
				EndIf
				If VSC->VSC_DATVEN > dDatRef
					Exit
				EndIf
				If !Empty(cCodPro)
					If VSC->VSC_CODPRO != cCodPro
						dbSkip()
						Loop
					EndIf
				EndIf
				Do Case
					Case cAssunto == "7"

					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VSC->VSC_TIPTEM )
					Do Case
						Case cTipTot == Nil .or. cTipTot == "G"

						if VOI->VOI_SITTPO == "3" // Interno
							VO4->(dbGoTo(val(VSC->VSC_RECVO4)))
							nRet += VO4->VO4_VALINT
						Else
							nRet += VSC->VSC_VALSER
						Endif
						Case cTipTot == "A"

						If cTipAgr == VOI->VOI_SITTPO
							if VOI->VOI_SITTPO == "3" // Interno
								VO4->(dbGoTo(val(VSC->VSC_RECVO4)))
								nRet += VO4->VO4_VALINT
							Else
								nRet += VSC->VSC_VALSER
							EndIf
						Endif
						Case cTipTot == "T"

						If cTipTem == VSC->VSC_TIPTEM
							if VOI->VOI_SITTPO == "3" // Interno
								VO4->(dbGoTo(val(VSC->VSC_RECVO4)))
								nRet += VO4->VO4_VALINT
							Else
								nRet += VSC->VSC_VALSER
							Endif
						EndIf

						Case cTipTot == "R"

						Do Case
							Case VSC->VSC_CODSEC $ MVD_PAR01                                  && Servico Rapido

							if VOI->VOI_SITTPO == "3" // Interno
								VO4->(dbGoTo(val(VSC->VSC_RECVO4)))
								aRetV[01] += VO4->VO4_VALINT
							Else
								aRetV[01] += VSC->VSC_VALSER
							Endif

							// Nฦo existe reparo rapido para Carrocerias

							Case VSC->VSC_CODSEC $ MVD_PAR02 .or. VSC->VSC_CODSEC $ MVD_PAR03 && Servicos Gerais

							if VOI->VOI_SITTPO == "3" // Interno
								VO4->(dbGoTo(val(VSC->VSC_RECVO4)))
								aRetV[02] += VO4->VO4_VALINT
							Else
								aRetV[02] += VSC->VSC_VALSER
							Endif

							Case VSC->VSC_CODSEC $ MVD_PAR04 .or. VSC->VSC_CODSEC $ MVD_PAR05 && Servicos de Carroceria

							if VOI->VOI_SITTPO == "3" // Interno
								VO4->(dbGoTo(val(VSC->VSC_RECVO4)))
								aRetV[03] += VO4->VO4_VALINT
							Else
								aRetV[03] += VSC->VSC_VALSER
							Endif

						EndCase

						nRet := aRetV

					EndCase

					Case cAssunto == "C"

					Do Case
						Case cTipTot == Nil .or. cTipTot == "G"
						nRet += VSC->VSC_TEMCOB
						Case cTipTot == "A"
						DbSelectArea("VOI")
						DbSetOrder(1)
						DbSeek( xFilial("VOI") + VSC->VSC_TIPTEM )
						If cTipAgr == VOI->VOI_SITTPO
							nRet += VSC->VSC_TEMCOB
						EndIf
						Case cTipTot == "T"
						If cTipTem == VSC->VSC_TIPTEM
							nRet += VSC->VSC_TEMCOB
						EndIf
					EndCase

					Case cAssunto == "G"

					Do Case
						Case cTipTot == Nil .or. cTipTot == "G"
						nRet += VSC->VSC_TEMTRA
						Case cTipTot == "A"
						DbSelectArea("VOI")
						DbSetOrder(1)
						DbSeek( xFilial("VOI") + VSC->VSC_TIPTEM )
						If cTipAgr == VOI->VOI_SITTPO
							nRet += VSC->VSC_TEMTRA
						EndIf
						Case cTipTot == "T"
						If cTipTem == VSC->VSC_TIPTEM
							nRet += VSC->VSC_TEMTRA
						EndIf
					EndCase

					Case cAssunto == "I"

					Do Case
						Case cTipTot == Nil .or. cTipTot == "G"

						If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER ) == 0
							aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER)
							nRet += VSC->VSC_TEMVEN
						EndIf

						Case cTipTot == "A"

						DbSelectArea("VOI")
						DbSetOrder(1)
						DbSeek( xFilial("VOI") + VSC->VSC_TIPTEM )
						If cTipAgr == VOI->VOI_SITTPO
							If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER ) == 0
								aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER)
								nRet += VSC->VSC_TEMVEN
							EndIf
						EndIf

						Case cTipTot == "T"

						If cTipTem == VSC->VSC_TIPTEM
							If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER ) == 0
								aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER)
								nRet += VSC->VSC_TEMVEN
							EndIf
						EndIf

						Case cTipTot == "R"

						DbSelectArea("VOI")
						DbSetOrder(1)
						DbSeek( xFilial("VOI") + VSC->VSC_TIPTEM )
						If VOI->VOI_SITTPO != "3"
							If VSC->VSC_CODSEC $ MVD_PAR02 .or. VSC->VSC_CODSEC $ MVD_PAR03
								If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER ) == 0
									aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER)
									aRet[03,01] += VSC->VSC_TEMVEN
								EndIf
							EndIf

							If VSC->VSC_CODSEC $ MVD_PAR04 .or. VSC->VSC_CODSEC $ MVD_PAR05
								If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER ) == 0
									aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER)
									aRet[03,02] += VSC->VSC_TEMVEN
								EndIf
							EndIf
						EndIf

					EndCase

				EndCase
				dbSelectArea("VSC")
				dbSkip()

			EndDo

		Else

			dbSelectArea("VSC")
			dbSetOrder(5)
			dbSeek( xFilial("VSC") + DtoS(dDatRef),.t.)

			While VSC->VSC_FILIAL == xFilial("VSC") .And. !Eof()

				If VSC->VSC_DATVEN < dDatRef
					dbSkip()
					Loop
				EndIf
				If VSC->VSC_DATVEN > dDatFin
					Exit
				EndIf
				If !Empty(cCodPro)
					If VSC->VSC_CODPRO != cCodPro
						dbSkip()
						Loop
					EndIf
				EndIf
				Do Case
					Case cAssunto == "7"

					Do Case
						Case cTipTot == Nil .or. cTipTot == "G"
						nRet += VSC->VSC_VALSER
						Case cTipTot == "A"
						DbSelectArea("VOI")
						DbSetOrder(1)
						DbSeek( xFilial("VOI") + VSC->VSC_TIPTEM )
						If cTipAgr == VOI->VOI_SITTPO
							nRet += VSC->VSC_VALSER
						EndIf
						Case cTipTot == "T"
						If cTipTem == VSC->VSC_TIPTEM
							nRet += VSC->VSC_VALSER
						EndIf

						Case cTipTot == "R"

						Do Case
							Case VSC->VSC_CODSEC $ MVD_PAR01                                  && Servico Rapido

							aRetV[01] += VSC->VSC_VALSER

							// Nฦo existe reparo rapido para Carrocerias

							Case VSC->VSC_CODSEC $ MVD_PAR02 .or. VSC->VSC_CODSEC $ MVD_PAR03 && Servicos Gerais

							aRetV[02] += VSC->VSC_VALSER

							Case VSC->VSC_CODSEC $ MVD_PAR04 .or. VSC->VSC_CODSEC $ MVD_PAR05 && Servicos de Carroceria

							aRetV[03] += VSC->VSC_VALSER

						EndCase

						nRet := aRetV

					EndCase

					Case cAssunto == "C"

					Do Case
						Case cTipTot == Nil .or. cTipTot == "G"
						nRet += VSC->VSC_TEMCOB
						Case cTipTot == "A"
						DbSelectArea("VOI")
						DbSetOrder(1)
						DbSeek( xFilial("VOI") + VSC->VSC_TIPTEM )
						If cTipAgr == VOI->VOI_SITTPO
							nRet += VSC->VSC_TEMCOB
						EndIf
						Case cTipTot == "T"
						If cTipTem == VSC->VSC_TIPTEM
							nRet += VSC->VSC_TEMCOB
						EndIf
					EndCase

					Case cAssunto == "G"

					Do Case
						Case cTipTot == Nil .or. cTipTot == "G"
						nRet += VSC->VSC_TEMTRA
						Case cTipTot == "A"
						DbSelectArea("VOI")
						DbSetOrder(1)
						DbSeek( xFilial("VOI") + VSC->VSC_TIPTEM )
						If cTipAgr == VOI->VOI_SITTPO
							nRet += VSC->VSC_TEMTRA
						EndIf
						Case cTipTot == "T"
						If cTipTem == VSC->VSC_TIPTEM
							nRet += VSC->VSC_TEMTRA
						EndIf
					EndCase

					Case cAssunto == "I"

					Do Case
						Case cTipTot == Nil .or. cTipTot == "G"

						If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER ) == 0
							aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER)
							nRet += VSC->VSC_TEMVEN
						EndIf

						Case cTipTot == "A"

						DbSelectArea("VOI")
						DbSetOrder(1)
						DbSeek( xFilial("VOI") + VSC->VSC_TIPTEM )
						If cTipAgr == VOI->VOI_SITTPO
							If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER ) == 0
								aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER)
								nRet += VSC->VSC_TEMVEN
							EndIf
						EndIf

						Case cTipTot == "T"

						If cTipTem == VSC->VSC_TIPTEM
							If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER ) == 0
								aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER)
								nRet += VSC->VSC_TEMVEN
							EndIf
						EndIf

						Case cTipTot == "R"

						//                              DbSelectArea("VOI")                && Interno tamb้m ้ para ser considerado - Edson 03/05/2002
						//                              DbSetOrder(1)
						//                              DbSeek( xFilial("VOI") + VSC->VSC_TIPTEM )
						//                              If VOI->VOI_SITTPO != "3"
						If VSC->VSC_CODSEC $ MVD_PAR02 .or. VSC->VSC_CODSEC $ MVD_PAR03
							If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER ) == 0
								aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER)
								aRet[03,01] += VSC->VSC_TEMVEN
							EndIf
						EndIf

						If VSC->VSC_CODSEC $ MVD_PAR04 .or. VSC->VSC_CODSEC $ MVD_PAR05
							If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER ) == 0
								aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+VSC->VSC_CODSER)
								aRet[03,02] += VSC->VSC_TEMVEN
							EndIf
						EndIf
						//                              EndIf

					EndCase

				EndCase
				dbSelectArea("VSC")
				dbSkip()

			EndDo

		EndIf

		If cAssunto == "7" .and. cTipTot == "R"
			nRet := aRetV
		EndIf
		If cAssunto == "I" .and. cTipTot == "R"
			nRet := aRet
		EndIf

		Case cAssunto == "8"  // Quantidade de Pe็as Requisitadas

		dbSelectArea("VO2")
		dbSetOrder(3)
		dbSeek(xFilial("VO2") + DtoS(dDatRef),.t.)

		While VO2->VO2_DATREQ == dDatRef .And. VO2->VO2_FILIAL == xFilial("VO2") .And. !Eof()

			If VO2->VO2_TIPREQ == "S"
				dbSkip()
				Loop
			EndIf

			dbSelectArea("VO3")
			dbSetOrder(1)
			dbSeek( xFilial("VO3") + VO2->VO2_NOSNUM )

			While !Eof() .And. VO3->VO3_FILIAL+VO3->VO3_NOSNUM == xFilial("VO3") + VO2->VO2_NOSNUM

				If !Empty(VO3->VO3_DATCAN)
					dbSkip()
					Loop
				EndIf

				If VO3->VO3_PROREQ == cCodPro
					If VO2->VO2_DEVOLU == "1"
						nRet += VO3_QTDREQ
					Else
						nRet -= VO3_QTDREQ
					EndIf
				EndIf
				dbSkip()

			EndDo

			dbSelectArea("VO2")
			dbSkip()

		EndDo

		Case cAssunto $ "9/A"  // Estoque de Horas

		dbSelectArea("VO4")
		dbSetOrder(2)

		If dDatFin == Nil

			//           If dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef),.t.)
			dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef),.t.)

			While VO4->VO4_CODPRO == cCodPro .And. VO4->VO4_DATINI == dDatRef .And. VO4->VO4_FILIAL == xFilial("VO4") .And. !Eof()

				If cAssunto == "9"
					If !Empty(VO4->VO4_DATDIS)  // Despreza as liberadas
						dbSelectArea("VO4")
						dbSkip()
						Loop
					EndIf
				Else
					If Empty(VO4->VO4_DATDIS)  // Despreza as NAO liberadas
						dbSelectArea("VO4")
						dbSkip()
						Loop
					EndIf
				EndIf

				If !Empty(VO4->VO4_DATFEC)  // Despreza as fechadas
					dbSelectArea("VO4")
					dbSkip()
					Loop
				EndIf

				If !Empty(VO4->VO4_DATCAN)  // Despreza as canceladas
					dbSelectArea("VO4")
					dbSkip()
					Loop
				EndIf

				dbSelectArea("VOK")
				dbSetOrder(1)
				If dbSeek(xFilial("VOK")+VO4->VO4_TIPSER)
					If VOK->VOK_INCTEM == "3"
						nRet += VO4->VO4_TEMTRA
					Else
						ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
						If ix1 == 0
							aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
							nRet += VO4->VO4_TEMVEN
						EndIf
					EndIf
				EndIf
				dbSelectArea("VO4")
				dbSkip()

			EndDo

			//           EndIf

		Else

			dbSeek(xFilial("VO4")+cCodPro+Dtos(dDatRef),.t.)

			While VO4->VO4_CODPRO == cCodPro .And. VO4->VO4_FILIAL == xFilial("VO4") .And. !Eof()

				If !Empty(VO4->VO4_DATDIS)  // Despreza as liberadas
					dbSelectArea("VO4")
					dbSkip()
					Loop
				EndIf

				If !Empty(VO4->VO4_DATFEC)  // Despreza as fechadas
					dbSelectArea("VO4")
					dbSkip()
					Loop
				EndIf

				If !Empty(VO4->VO4_DATCAN)  // Despreza as canceladas
					dbSelectArea("VO4")
					dbSkip()
					Loop
				EndIf

				If VO4->VO4_DATINI >= dDatRef .and. VO4->VO4_DATINI <= dDatFin
					dbSelectArea("VOK")
					dbSetOrder(1)
					If dbSeek(xFilial("VOK")+VO4->VO4_TIPSER)
						If VOK->VOK_INCTEM == "3"
							nRet += VO4->VO4_TEMTRA
						Else
							ix1 := aScan(aVerPad, {|x| x[1]+x[2]+x[3] == VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER})
							If ix1 == 0
								aAdd(aVerPad,{VO4->VO4_NOSNUM,VO4->VO4_TIPTEM,VO4->VO4_CODSER})
								nRet += VO4->VO4_TEMVEN
							EndIf
						EndIf
					EndIf
				EndIf
				dbSelectArea("VO4")
				dbSkip()

			EndDo

		EndIf

		Case cAssunto $ "B"  //  Interpreta a formula do usuario

		nRet += FG_FORMULA(cCodFor)

		Case cAssunto == "D" //  Totalizador de Pecas

		If dDatFin == Nil

			dbSelectArea("VEC")
			dbSetOrder(3)
			dbSeek( xFilial("VEC") + DtoS(dDatRef),.t.)

			While VEC->VEC_FILIAL == xFilial("VEC") .And. !Eof()

				If VEC->VEC_DATVEN < dDatRef
					dbSkip()
					Loop
				EndIf
				If VEC->VEC_DATVEN > dDatRef
					Exit
				EndIf
				If VEC->VEC_BALOFI == cTipTot
					If cTipTot == "B"
						DbSelectArea( "VS1" )
						DbSetOrder(1)
						DbSeek( xFilial("VS1") + VEC->VEC_NUMORC, .f. )
						If Alltrim(VS1->VS1_NOROUT) == "2"
							DbSelectArea("VEC")
							DbSkip()
							Loop
						EndIf
						DbSelectArea( "SD2" )
						DbSetOrder(3)
						If !DbSeek( xFilial("SD2") + VEC->VEC_NUMNFI + VEC->VEC_SERNFI + VS1->VS1_CLIFAT + VS1->VS1_LOJA + VEC->VEC_PECINT , .f. )
							DbSelectArea("VEC")
							Dbskip()
							Loop
						EndIf
						DbSelectArea( "SF4" )
						DbSetOrder(1)
						DbSeek( xFilial("SF4") + SD2->D2_TES )
						If SF4->F4_DUPLIC == "N"
							DbSelectArea("VEC")
							DbSkip()
							Loop
						EndIf
						nRet += VEC->VEC_VALVDA
					Else
						nRet += VEC->VEC_VALVDA
					EndIf
				EndIf
				DbSelectArea("VEC")
				dbSkip()

			EndDo

		Else

			dbSelectArea("VEC")
			dbSetOrder(3)
			dbSeek( xFilial("VEC") + DtoS(dDatRef),.t.)

			While VEC->VEC_FILIAL == xFilial("VEC") .And. !Eof()

				If VEC->VEC_DATVEN < dDatRef
					dbSkip()
					Loop
				EndIf
				If VEC->VEC_DATVEN > dDatFin
					Exit
				EndIf
				If VEC->VEC_BALOFI == cTipTot
					If cTipTot == "B"
						DbSelectArea( "VS1" )
						DbSetOrder(1)
						DbSeek( xFilial("VS1") + VEC->VEC_NUMORC, .f. )
						If Alltrim(VS1->VS1_NOROUT) == "2"
							DbSelectArea("VEC")
							DbSkip()
							Loop
						EndIf
						DbSelectArea( "SD2" )
						DbSetOrder(3)
						If !DbSeek( xFilial("SD2") + VEC->VEC_NUMNFI + VEC->VEC_SERNFI + VS1->VS1_CLIFAT + VS1->VS1_LOJA + VEC->VEC_PECINT , .f. )
							DbSelectArea("VEC")
							Dbskip()
							Loop
						EndIf
						DbSelectArea( "SF4" )
						DbSetOrder(1)
						DbSeek( xFilial("SF4") + SD2->D2_TES )
						If SF4->F4_DUPLIC == "N"
							DbSelectArea("VEC")
							DbSkip()
							Loop
						EndIf
						nRet += VEC->VEC_VALVDA
					Else
						nRet += VEC->VEC_VALVDA
					EndIf
				EndIf
				DbSelectArea("VEC")
				dbSkip()

			EndDo

		EndIf

		Case cAssunto == "E" //  Valor de Peca por Situacao do Tipo de Tempo
		//  Valor de Peca por Tipo de Tempo

		If dDatFin == Nil

			dbSelectArea("VEC")
			dbSetOrder(3)
			dbSeek( xFilial("VEC") + DtoS(dDatRef),.t.)

			While VEC->VEC_FILIAL == xFilial("VEC") .And. !Eof()

				If VEC->VEC_BALOFI != "O"
					dbSkip()
					Loop
				EndIf
				If VEC->VEC_DATVEN < dDatRef
					dbSkip()
					Loop
				EndIf
				If VEC->VEC_DATVEN > dDatRef
					Exit
				EndIf
				If cTipTot == "A"
					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VEC->VEC_TIPTEM )
					If cTipAgr == VOI->VOI_SITTPO
						nRet += VEC->VEC_VALVDA
					EndIf
				Else
					If cTipTem == VEC->VEC_TIPTEM
						nRet += VEC->VEC_VALVDA
					EndIf
				EndIf
				dbSelectArea("VEC")
				dbSkip()

			EndDo

		Else

			dbSelectArea("VEC")
			dbSetOrder(3)
			dbSeek( xFilial("VEC") + DtoS(dDatRef),.t.)

			While VEC->VEC_FILIAL == xFilial("VEC") .And. !Eof()

				If VEC->VEC_BALOFI != "O"
					dbSkip()
					Loop
				EndIf
				If VEC->VEC_DATVEN < dDatRef
					dbSkip()
					Loop
				EndIf
				If VEC->VEC_DATVEN > dDatFin
					Exit
				EndIf
				If cTipTot == "A"
					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VEC->VEC_TIPTEM )
					If cTipAgr == VOI->VOI_SITTPO
						nRet += VEC->VEC_VALVDA
					EndIf
				Else
					If cTipTem == VEC->VEC_TIPTEM
						nRet += VEC->VEC_VALVDA
					EndIf
				EndIf
				dbSelectArea("VEC")
				dbSkip()

			EndDo

		EndIf

		Case cAssunto == "F" //  Soma as passagens dos veiculos na oficina

		If cTipPas == "A"   //  Contagem das Passagens pela Data de Abertura

			Do Case
				Case cTipTot == "G"

				dbSelectArea("VO1")
				dbSetOrder(5)
				dbSeek(xFilial("VO1")+DtoS(dDatRef),.t.)

				While VO1->VO1_FILIAL == xFilial("VO1") .And. !Eof()

					If VO1->VO1_DATABE < dDatRef
						dbSkip()
						Loop
					EndIf
					If VO1->VO1_DATABE > dDatFin
						Exit
					EndIf
					nRet ++
					dbSkip()

				EndDo

				Case cTipTot $ "A/T"   && A - Grupo de Tipo de Tempo / T - Tipo de Tempo

				dbSelectArea("VO1")
				dbSetOrder(5)
				dbSeek(xFilial("VO1")+DtoS(dDatRef),.t.)

				While VO1->VO1_FILIAL == xFilial("VO1") .And. !Eof()

					If VO1->VO1_DATABE < dDatRef
						dbSkip()
						Loop
					EndIf
					If VO1->VO1_DATABE > dDatFin
						Exit
					EndIf

					dbSelectArea("VO2")
					dbSetOrder(1)
					dbSeek(xFilial("VO2")+VO1->VO1_NUMOSV)

					While VO2->VO2_DATREQ == dDatRef .And. VO2->VO2_FILIAL == xFilial("VO2") .And. !Eof()

						If VO2->VO2_TIPREQ == "P"

							dbSelectArea("VO3")
							dbSetOrder(1)
							dbSeek( xFilial("VO3") + VO2->VO2_NOSNUM )

							While !Eof() .And. VO3->VO3_FILIAL+VO3->VO3_NOSNUM == xFilial("VO3") + VO2->VO2_NOSNUM

								If !Empty(VO3->VO3_DATCAN) .or. !Empty(VO3->VO3_DATFEC)
									dbSkip()
									Loop
								EndIf

								If cTipTot == "A"
									DbSelectArea("VOI")
									DbSetOrder(1)
									DbSeek( xFilial("VOI") + VO3->VO3_TIPTEM )
									If cTipAgr == VOI->VOI_SITTPO
										If aScan(aVetTra, VO1->VO1_NUMOSV+VO3->VO3_TIPTEM ) == 0
											aAdd(aVetTra, VO1->VO1_NUMOSV+VO3->VO3_TIPTEM)
											nRet ++
										EndIf
									EndIf
								Else
									If cTipTem == VO3->VO3_TIPTEM
										If aScan(aVetTra, VO1->VO1_NUMOSV+VO3->VO3_TIPTEM ) == 0
											aAdd(aVetTra, VO1->VO1_NUMOSV+VO3->VO3_TIPTEM)
											nRet ++
										EndIf
									EndIf
								EndIf

								dbSelectArea("VO3")
								dbSkip()

							EndDo

						Else

							dbSelectArea("VO4")
							dbSetOrder(1)
							dbSeek( xFilial("VO4") + VO2->VO2_NOSNUM )

							While !Eof() .And. VO4->VO4_FILIAL+VO4->VO4_NOSNUM == xFilial("VO4") + VO2->VO2_NOSNUM

								If !Empty(VO4->VO4_DATCAN) .or. !Empty(VO4->VO4_DATFEC)
									dbSkip()
									Loop
								EndIf

								If cTipTot == "A"
									DbSelectArea("VOI")
									DbSetOrder(1)
									DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )
									If cTipAgr == VOI->VOI_SITTPO
										If aScan(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM ) == 0
											aAdd(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM)
											nRet ++
										EndIf
									EndIf
								Else
									If cTipTem == VO4->VO4_TIPTEM
										If aScan(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM ) == 0
											aAdd(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM)
											nRet ++
										EndIf
									EndIf

								EndIf
								dbSelectArea("VO4")
								dbSkip()

							EndDo

						EndIf

						dbSelectArea("VO2")
						dbSkip()

					EndDo

					dbSelectArea("VO1")
					dbSkip()

				EndDo

				Case cTipTot == "R"   && RMS Volkswagen

				aAdd(aRet,{0,0})  // Passagens de Servico Rapido
				aAdd(aRet,{0,0})  // Passagens Internas
				aAdd(aRet,{0,0})  // Passagens Total

				dbSelectArea("VO1")
				dbSetOrder(5)
				dbSeek(xFilial("VO1")+DtoS(dDatRef),.t.)

				While VO1->VO1_FILIAL == xFilial("VO1") .And. !Eof()

					If VO1->VO1_DATABE < dDatRef
						dbSkip()
						Loop
					EndIf
					If VO1->VO1_DATABE > dDatFin
						Exit
					EndIf

					dbSelectArea("VO2")
					dbSetOrder(1)
					dbSeek(xFilial("VO2")+VO1->VO1_NUMOSV)

					While VO2->VO2_DATREQ == dDatRef .And. VO2->VO2_FILIAL == xFilial("VO2") .And. !Eof()

						If VO2->VO2_TIPREQ == "P"

							// Para o RMS de Veกculos de Passeio
							// Nao se Faz contagem de passagens de veiculos
							// pelas pecas.  Inclusive, OS's que somente
							// possuam peas NAO serao consideradas neste
							// levantamento, ocasionando propositadamente
							// valores diferentes ao que apresentados no ADO
							// que marca passagem para veiculos cuja OS nao
							// tenha servicos.  Isso se traduz num erro de
							// operacao do sistema.  Nao est  sendo filtrado
							// no ADO pois o total de pecas deste tipo de si-
							// tuacao deixaria de ser apresentado causando
							// diferenca entre o ADO e o Relatorio de Posicao
							// de vendas e resultado

						Else

							dbSelectArea("VO4")
							dbSetOrder(1)
							dbSeek( xFilial("VO4") + VO2->VO2_NOSNUM )

							While !Eof() .And. VO4->VO4_FILIAL+VO4->VO4_NOSNUM == xFilial("VO4") + VO2->VO2_NOSNUM

								If !Empty(VO4->VO4_DATCAN) .or. !Empty(VO4->VO4_DATFEC)
									dbSkip()
									Loop
								EndIf

								DbSelectArea("VOI")
								DbSetOrder(1)
								DbSeek( xFilial("VOI") + VO4->VO4_TIPTEM )

								Do Case
									Case VOI->VOI_SITTPO == "3"

									If VO4->VO4_CODSEC $ MVD_PAR02 .or. VO4->VO4_CODSEC $ MVD_PAR03
										//                                          If aScan(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSEC ) == 0
										//                                             aAdd(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSEC)
										If aScan(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+"1" ) == 0
											aAdd(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+"1")
											aRet[02,01] := aRet[02,01] + 1
										EndIf
									EndIf

									If VO4->VO4_CODSEC $ MVD_PAR04 .or. VO4->VO4_CODSEC $ MVD_PAR05
										//                                          If aScan(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSEC ) == 0
										//                                             aAdd(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSEC)
										If aScan(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+"2" ) == 0
											aAdd(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+"2")
											aRet[02,02] := aRet[02,02] + 1
										EndIf
									EndIf

									dbSelectArea("VO4")
									dbSkip()

									Case VO4->VO4_CODSEC $ MVD_PAR01

									//                                       If aScan(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSEC ) == 0
									//                                          aAdd(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSEC)
									If aScan(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+"1" ) == 0
										aAdd(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+"1")
										aRet[01,01] := aRet[01,01] + 1
										aRet[01,02] := 0
									EndIf

									// Nฦo existe reparo para Carrocerias

									dbSelectArea("VO4")
									dbSkip()

									Otherwise

									If VO4->VO4_CODSEC $ MVD_PAR02 .or. VO4->VO4_CODSEC $ MVD_PAR03
										//                                          If aScan(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSEC ) == 0
										//                                             aAdd(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSEC)
										If aScan(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+"1" ) == 0
											aAdd(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+"1")
											aRet[03,01] := aRet[03,01] + 1
										EndIf
									EndIf

									If VO4->VO4_CODSEC $ MVD_PAR04 .or. VO4->VO4_CODSEC $ MVD_PAR05
										//                                          If aScan(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSEC ) == 0
										//                                             aAdd(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSEC)
										If aScan(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+"2" ) == 0
											aAdd(aVetTra, VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+"2")
											aRet[03,02] := aRet[03,02] + 1
										EndIf
									EndIf

									dbSelectArea("VO4")
									dbSkip()

								EndCase

							EndDo

						EndIf

						dbSelectArea("VO2")
						dbSkip()

					EndDo

					dbSelectArea("VO1")
					dbSkip()

				EndDo

				If cTipTot == "R"
					nRet := aRet
				EndIf

			EndCase

		Else  // Contagem das Passagens pela Data do Fechamento

			aAdd(aRet,{0,0})  // Passagens de Servico Rapido
			aAdd(aRet,{0,0})  // Passagens Internas
			aAdd(aRet,{0,0})  // Passagens Total

			dbSelectArea("VEC")
			dbSetOrder(3)
			dbSeek( xFilial("VEC") + DtoS(dDatRef),.t.)

			While VEC->VEC_FILIAL == xFilial("VEC") .And. !Eof()

				If VEC->VEC_BALOFI != "O"
					dbSkip()
					Loop
				EndIf
				If VEC->VEC_DATVEN < dDatRef
					dbSkip()
					Loop
				EndIf
				If VEC->VEC_DATVEN > dDatFin
					Exit
				EndIf
				Do Case
					Case cTipTot == "G"
					If aScan(aVetTra, VEC->VEC_NUMOSV ) == 0
						aAdd(aVetTra, VEC->VEC_NUMOSV)
						nRet ++
					EndIf
					Case cTipTot == "A"
					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VEC->VEC_TIPTEM )
					If cTipAgr == VOI->VOI_SITTPO
						If aScan(aVetTra,  VEC->VEC_NUMOSV+VEC->VEC_TIPTEM ) == 0
							aAdd(aVetTra, VEC->VEC_NUMOSV+VEC->VEC_TIPTEM)
							nRet ++
						EndIf
					EndIf
					Case cTipTot == "T"
					If cTipTem == VEC->VEC_TIPTEM
						If aScan(aVetTra,  VEC->VEC_NUMOSV+VEC->VEC_TIPTEM ) == 0
							aAdd(aVetTra,  VEC->VEC_NUMOSV+VEC->VEC_TIPTEM)
							nRet ++
						EndIf
					EndIf
					Case cTipTot == "R"

					// Para o RMS de Veกculos de Passeio
					// Nao se Faz contagem de passagens de veiculos
					// pelas pecas.  Inclusive, OS's que somente
					// possuam peas NAO serao consideradas neste
					// levantamento, ocasionando propositadamente
					// valores diferentes ao que apresentados no ADO
					// que marca passagem para veiculos cuja OS nao
					// tenha servicos.  Isso se traduz num erro de
					// operacao do sistema.  Nao est  sendo filtrado
					// no ADO pois o total de pecas deste tipo de si-
					// tuacao deixaria de ser apresentado causando
					// diferenca entre o ADO e o Relatorio de Posicao
					// de vendas e resultado

				EndCase
				dbSelectArea("VEC")
				dbSkip()

			EndDo

			dbSelectArea("VSC")
			dbSetOrder(5)
			dbSeek( xFilial("VSC") + DtoS(dDatRef),.t.)

			While VSC->VSC_FILIAL == xFilial("VSC") .And. !Eof()

				If VSC->VSC_DATVEN < dDatRef
					dbSkip()
					Loop
				EndIf
				If VSC->VSC_DATVEN > dDatFin
					Exit
				EndIf

				DbSelectArea("VOI")
				DbSetOrder(1)
				DbSeek( xFilial("VOI") + VSC->VSC_TIPTEM )

				Do Case
					Case cTipTot == "G"

					If aScan(aVetTra, VSC->VSC_NUMOSV ) == 0
						aAdd(aVetTra, VSC->VSC_NUMOSV)
						nRet ++
					EndIf

					Case cTipTot == "A"

					DbSelectArea("VOI")
					DbSetOrder(1)
					DbSeek( xFilial("VOI") + VSC->VSC_TIPTEM )
					If cTipAgr == VOI->VOI_SITTPO
						If aScan(aVetTra,  VSC->VSC_NUMOSV+VSC->VSC_TIPTEM ) == 0
							aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM)
							nRet ++
						EndIf
					EndIf

					Case cTipTot == "T"

					If cTipTem == VSC->VSC_TIPTEM
						If aScan(aVetTra,  VSC->VSC_NUMOSV+VSC->VSC_TIPTEM ) == 0
							aAdd(aVetTra,  VSC->VSC_NUMOSV+VSC->VSC_TIPTEM)
							nRet ++
						EndIf
					EndIf

					Case cTipTot == "R"

					Do Case
						Case VOI->VOI_SITTPO == "3"

						If VSC->VSC_CODSEC $ MVD_PAR02 .or. VSC->VSC_CODSEC $ MVD_PAR03
							If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+"1" ) == 0
								aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+"1")
								aRet[02,01] := aRet[02,01] + 1
							EndIf
						EndIf

						If VSC->VSC_CODSEC $ MVD_PAR04 .or. VSC->VSC_CODSEC $ MVD_PAR05
							If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+"2" ) == 0
								aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+"2")
								aRet[02,02] := aRet[02,02] + 1
							EndIf
						EndIf

						Case VSC->VSC_CODSEC $ MVD_PAR01

						If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+"1" ) == 0
							aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+"1")
							aRet[01,01] := aRet[01,01] + 1
							aRet[01,02] := 0
						EndIf

						// Nฦo existe reparo para Carrocerias

						Otherwise

						If VSC->VSC_CODSEC $ MVD_PAR02 .or. VSC->VSC_CODSEC $ MVD_PAR03
							If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+"1" ) == 0
								aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+"1")
								aRet[03,01] := aRet[03,01] + 1
							EndIf
						EndIf

						If VSC->VSC_CODSEC $ MVD_PAR04 .or. VSC->VSC_CODSEC $ MVD_PAR05
							If aScan(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+"2" ) == 0
								aAdd(aVetTra, VSC->VSC_NUMOSV+VSC->VSC_TIPTEM+"2")
								aRet[03,02] := aRet[03,02] + 1
							EndIf
						EndIf

					EndCase

				EndCase
				dbSelectArea("VSC")
				dbSkip()

			EndDo

			If cTipTot == "R"
				nRet := aRet
			EndIf

		EndIf
	EndCase

	For ix1_ := 1 to 30

		cVar2_ := "MVB_PAR"+strzero(ix1_,2)
		If &cVar2_ == Nil
			Exit
		EndIf
		cVar1_  := "MV_PAR"+strzero(ix1_,2)
		&cVar1_ := &cVar2_

	Next
	If !Empty(cSele)
		dbSelectArea(cSele)
	EndIf

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFG_CALEST ณ Autor ณ  Andre Luis Almeida   ณ Data ณ 15/07/02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Calcula Estoque / Total de Compras                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cAssunto- Assunto que a funcao ira levantar                ณฑฑ
ฑฑณ          ณ           0 - Estoque Medio                                ณฑฑ
ฑฑณ          ณ           1 - Custo Vendas                                 ณฑฑ
ฑฑณ          ณ           2 - Total de Compras                             ณฑฑ
ฑฑณ          ณ dDatIni - Data Inicial para o Levantamento                 ณฑฑ
ฑฑณ          ณ dDatFin - Data Final                                       ณฑฑ
ฑฑณ          ณ cTipPec - Tipo de Pecas                                    ณฑฑ
ฑฑณ          ณ           O - Originais                                    ณฑฑ
ฑฑณ          ณ           N - Nao-Originais                                ณฑฑ
ฑฑณ          ณ           G - Geral (Originais e Nao-Originais)            ณฑฑ
ฑฑณ          ณ cTipVBO - Tipo de Vendas                                   ณฑฑ
ฑฑณ          ณ           B - Balcao                                       ณฑฑ
ฑฑณ          ณ           O - Oficina                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_CALEST(cAssunto,dDatIni,dDatFin,cTipPec,cTipVBO)
	Local nRet := 0
	Local cGRPSBM := ""
	Local cQuery  := ""
	Local cQAlEST := "SQL_ESTQ"
	If cAssunto # "0"
		If dDatIni == Nil
			dDatIni := cTod("01/01/1900")
			If dDatFin == Nil
				dDatFin := dDataBase
			EndIf
		Else
			If dDatFin == Nil
				dDatFin := dDatIni
			EndIf
		EndIf
	EndIf
	DbSelectArea( "SBM" )
	DbSetOrder(1)
	DbSeek( xFilial("SBM") , .t. )
	While !eof() .and. SBM->BM_FILIAL == xFilial("SBM")
		If Alltrim(SBM->BM_TIPGRU) $ "1/5/6"
			If cTipPec == "G" .or. cTipPec == Nil // Pecas Originais ou Nao-Originais
				cGRPSBM += "'"+SBM->BM_GRUPO+"',"
			ElseIf cTipPec == "O" // Pecas Originais
				If SBM->BM_PROORI == "1"
					cGRPSBM += "'"+SBM->BM_GRUPO+"',"
				EndIf
			ElseIf cTipPec == "N" // Pecas Nao-Originais
				If SBM->BM_PROORI == "0"
					cGRPSBM += "'"+SBM->BM_GRUPO+"',"
				EndIf
			EndIf
		EndIf
		DbSelectArea("SBM")
		Dbskip()
	EndDo
	cQuery  := ""
	cQAlEST := "SQL_ESTQ"
	If Empty(cGRPSBM)
		cGRPSBM := "'',"
	EndIf
	Do Case
		Case cAssunto == "0"  // Estoque Medio
		#IFDEF TOP
		cQuery := "SELECT SB1.B1_COD , SB2.B2_CM1 , SB2.B2_QATU FROM "+RetSqlName("SB1")+" SB1 , "+RetSqlName("SB2")+" SB2 "
		cQuery += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB2.B2_FILIAL='"+xFilial("SB2")+"' AND SB1.B1_COD=SB2.B2_COD AND "
		cQuery += "SB1.B1_GRUPO IN ("+left(cGRPSBM,len(cGRPSBM)-1)+") AND SB1.D_E_L_E_T_=' ' AND SB2.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlEST , .F., .T. )
		Do While !( cQAlEST )->( Eof() )
			nRet += ( ( cQAlEST )->( B2_CM1 ) * ( cQAlEST )->( B2_QATU ) )
			( cQAlEST )->( DbSkip() )
		EndDo
		( cQAlEST )->( dbCloseArea() )
		#ELSE
		DbSelectArea( "SB2" )
		DbSetOrder(1)
		DbSeek( xFilial("SB2") , .t. )
		While !eof() .and. SB2->B2_FILIAL == xFilial("SB2")
			DbSelectArea( "SB1" )
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + SB2->B2_COD , .t. )
			If SB1->B1_GRUPO $ cGRPSBM
				nRet += (SB2->B2_CM1 * SB2->B2_QATU)
			EndIf
			DbSelectArea("SB2")
			Dbskip()
		EndDo
		#ENDIF
		Case cAssunto == "1"  // Custo Vendas
		#IFDEF TOP
		cQuery := "SELECT VEC.VEC_NUMORC , VEC.VEC_NUMNFI , VEC.VEC_SERNFI , VEC.VEC_PECINT , VEC.VEC_CUSTOT FROM "+RetSqlName("VEC")+" VEC WHERE VEC.VEC_FILIAL='"+xFilial("VEC")+"' AND "
		cQuery += "VEC.VEC_DATVEN>='"+dtos(dDatIni)+"' AND VEC.VEC_DATVEN<='"+dtos(dDatFin)+"' AND VEC.VEC_BALOFI='"+cTipVBO+"' AND VEC.VEC_GRUITE IN ("+left(cGRPSBM,len(cGRPSBM)-1)+") AND VEC.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlEST , .F., .T. )
		Do While !( cQAlEST )->( Eof() )
			If cTipVBO == "B"   // Balcao
				DbSelectArea("VS1")
				DbSetOrder(1)
				DbSeek( xFilial("VS1") + ( cQAlEST )->( VEC_NUMORC ), .f. )
				If Alltrim(VS1->VS1_NOROUT) == "2"
					( cQAlEST )->( DbSkip() )
					Loop
				EndIf
				DbSelectArea( "SD2" )
				DbSetOrder(3)
				If !DbSeek( xFilial("SD2") + ( cQAlEST )->( VEC_NUMNFI ) + ( cQAlEST )->( VEC_SERNFI ) + VS1->VS1_CLIFAT + VS1->VS1_LOJA + ( cQAlEST )->( VEC_PECINT ) , .f. )
					( cQAlEST )->( DbSkip() )
					Loop
				EndIf
				DbSelectArea( "SF4" )
				DbSetOrder(1)
				DbSeek( xFilial("SF4") + SD2->D2_TES )
				If SF4->F4_DUPLIC == "N"
					( cQAlEST )->( DbSkip() )
					Loop
				EndIf
				nRet += ( cQAlEST )->( VEC_CUSTOT )
			ElseIf cTipVBO == "O"   // Oficina
				nRet += ( cQAlEST )->( VEC_CUSTOT )
			EndIf
			( cQAlEST )->( DbSkip() )
		EndDo
		( cQAlEST )->( dbCloseArea() )
		#ELSE
		DbSelectArea( "VEC" )
		DbSetOrder(3)
		DbSeek( xFilial("VEC") + Dtos(dDatIni) , .t. )
		While !eof() .and. VEC->VEC_FILIAL == xFilial("VEC") .and. VEC->VEC_DATVEN <= dDatFin
			If VEC->VEC_BALOFI == cTipVBO
				If cTipVBO == "B"   // Balcao
					DbSelectArea("VS1")
					DbSetOrder(1)
					DbSeek( xFilial("VS1") + VEC->VEC_NUMORC, .f. )
					If Alltrim(VS1->VS1_NOROUT) == "2"
						DbSelectArea("VEC")
						DbSkip()
						Loop
					EndIf
					DbSelectArea( "SD2" )
					DbSetOrder(3)
					If !DbSeek( xFilial("SD2") + VEC->VEC_NUMNFI + VEC->VEC_SERNFI + VS1->VS1_CLIFAT + VS1->VS1_LOJA + VEC->VEC_PECINT , .f. )
						DbSelectArea("VEC")
						Dbskip()
						Loop
					EndIf
					DbSelectArea( "SF4" )
					DbSetOrder(1)
					DbSeek( xFilial("SF4") + SD2->D2_TES )
					If SF4->F4_DUPLIC == "N"
						DbSelectArea("VEC")
						DbSkip()
						Loop
					EndIf
					If VEC->VEC_GRUITE $ cGRPSBM
						nRet += VEC->VEC_CUSTOT
					EndIf
				ElseIf cTipVBO == "O"   // Oficina
					If VEC->VEC_GRUITE $ cGRPSBM
						nRet += VEC->VEC_CUSTOT
					EndIf
				EndIf
			EndIf
			DbSelectArea("VEC")
			DbSkip()
		EndDo
		#ENDIF
		Case cAssunto == "2"  // Total de Compras
		#IFDEF TOP
		cQuery := "SELECT SD1.D1_TOTAL FROM "+RetSqlName("SD1")+" SD1 WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_EMISSAO>='"+dtos(dDatIni)+"' AND "
		cQuery += "SD1.D1_EMISSAO<='"+dtos(dDatFin)+"' AND SD1.D1_GRUPO IN ("+left(cGRPSBM,len(cGRPSBM)-1)+") AND SD1.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlEST , .F., .T. )
		Do While !( cQAlEST )->( Eof() )
			nRet += ( cQAlEST )->( D1_TOTAL )
			( cQAlEST )->( DbSkip() )
		EndDo
		( cQAlEST )->( dbCloseArea() )
		#ELSE
		DbSelectArea( "SD1" )
		DbSetOrder(3)
		DbSeek( xFilial("SD1") + Dtos(dDatIni) , .t. )
		While !eof() .and. SD1->D1_FILIAL == xFilial("SD1") .and. SD1->D1_EMISSAO <= dDatFin
			If SD1->D1_GRUPO $ cGRPSBM
				nRet += SD1->D1_TOTAL
			EndIf
			DbSelectArea("SD1")
			Dbskip()
		EndDo
		#ENDIF
	EndCase
Return nRet

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFG_TRVM410 ณ Autor ณ Valdir F. Silva       ณ Data ณ 13.09.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Tratamento de DEAD-LOCK - Arquivo SB2                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณaProdutos  : Array com o Codigo do produto e Local           ณฑฑ
ฑฑณ          ณ					aProdutos[x,1]:=Codigo do produto	 	   ณฑฑ
ฑฑณ          ณ					aProdutos[x,2]:=Local 					   ณฑฑ
ฑฑณ          ณcTipoPed   : Tipo de Pedido que sera passado ao MATA410()    ณฑฑ
ฑฑณ          ณcCliFor    : Codigo do Clicente ou Fornecedor				   ณฑฑ
ฑฑณ          ณcLojCliFor : Loja do Cliente ou Fornecedor                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGestao de Concessionarias                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_TRVM410(aProdutos,cTipoPed,cCliFor,cLojCliFor)
	Local nI     := 0
	Local aTrava := {}
	Local lTrava := .T.
	If __TTSInUse
		For nI := 1 to Len(aProdutos)
			AADD(aTrava,aProdutos[nI,1]+aProdutos[nI,2])
		Next
		If cTipoPed $ "DB"
			lTrava := MultLock("SB2",aTrava,1) .And.;
			MultLock("SA2",{cCliFor+cLojCliFor},1) .And.;
			MultLock("SA2",{cCliFor+cLojCliFor},1)
		Else
			lTrava := MultLock("SB2",aTrava,1) .And.;
			MultLock("SA1",{cCliFor+cLojCliFor},1) .And.;
			MultLock("SA1",{cCliFor+cLojCliFor},1)
		EndIf
		If !lTrava
			SB2->(MsRUnLock())
			SA1->(MsRUnLock())
			SA2->(MsRUnLock())
		EndIf
		Return lTrava
	Else
		Return lTrava
	EndIf
Return lTrava

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ FG_AALTER ณ Autor ณ Fabio                 ณ Data ณ 28/09/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Travamento de aCols para Chaves ja gravadas                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณcAliasCh - Alias a ser pesquisado                            ณฑฑ
ฑฑณ          ณnLenAcols- Numero de Linhas ja preenchidas                   ณฑฑ
ฑฑณ          ณoNomObj  - Nome do Objeto da GetDados a ser tratado          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGestao de Concessionarias                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_AALTER(cAliasCh,nLenaCols,oNomObj,aVetHeader)
	Local aArea       := {}
	Local cSele       := Alias()
	Local cVarCh      := ""
	Local aAlter      := {}
	
	Local nAlterHeader:=0
	Local aVHeaderW  := If(aVetHeader != Nil,aClone(aVetHeader),aClone(aHeader))
	aArea := sGetArea(aArea , "SIX")
	DbSelectArea("SIX")
	DbSetOrder(1)
	If DbSeek( cAliasCh + "1" )
		cVarCh := Alltrim( SIX->CHAVE )
	Else
		cVarCh := &(cAliasCh+"->(IndexKey())")
	EndIf
	Aadd(aAlter,{})
	Aadd(aAlter,{})
	For nAlterHeader:=1 to Len(aVHeaderW)
		If !( Alltrim( aVHeaderW[nAlterHeader,2] ) $ cVarCh )
			Aadd(aAlter[1],aVHeaderW[nAlterHeader,2] )
		EndIf
		Aadd(aAlter[2],aVHeaderW[nAlterHeader,2] )
	Next
	If nLenaCols >= n
		oNomObj:aAlter := oNomObj:oBrowse:aAlter := aClone(aAlter[1])
	Else
		oNomObj:aAlter := oNomObj:oBrowse:aAlter := aClone(aAlter[2])
	EndIf
	// Volta posicoes originais
	sRestArea(aArea)
	If !Empty(cSele)
		DbSelectArea(cSele)
	EndIf

Return

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ FG_EK     ณ Autor ณ Fabio / Emilton       ณ Data ณ 28/09/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Travamento de Enchoice de chaves ja gravadas quando houver  ณฑฑ
ฑฑณ          ณ mais de um campo na chave                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณcAliasCpo- Alias a ser pesquisado                            ณฑฑ
ฑฑณ          ณcChaveCpo- Chave a ser pesquisada p/ validacao               ณฑฑ
ฑฑณ          ณnIndice  - Numero do indice a ser pesquisado                 ณฑฑ
ฑฑณ          ณcHelp    - Nome do help a ser apresentado caso haja duplicid ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGestao de Concessionarias                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_EK(cAliasCpo,cChaveCpo,nIndice,cHelp)

	Local aArea   := {}
	Local cVarch  := ""
	Local ix1     := 0
	Local cCpoWrk := ""
	Local lRet    := .f.
	Local cKeyWrk := ""

	cHelp   := If(cHelp#NIL,cHelp,"EXISTCHAV")
	nIndice := If(nIndice#NIL,nIndice,1)

	aArea := sGetArea(aArea , "SIX")
	If !Empty(Alias())
		aArea := sGetArea(aArea , Alias())
	EndIf

	DbSelectArea("SIX")
	DbSetOrder(1)
	If DbSeek( cAliasCpo + Str(nIndice,1) )
		cVarCh := Alltrim( SIX->CHAVE )
	Else
		cVarCh := &(cAliasCpo+"->( IndexKey() )" )
	EndIf

	cChaveCpo := If(cChaveCpo != NIL,cChaveCpo,cVarCh)

	For ix1:=1 to Len(cChaveCpo)

		If Substr(cChaveCpo,ix1,1) != "+"
			cCpoWrk += Substr(cChaveCpo,ix1,1)
		EndIf

		If Substr(cChaveCpo,ix1,1) == "+"

			If Type("M->"+cCpoWrk) != "U" .And. !("FILIAL"$Upper(Alltrim(cCpoWrk)))

				cKeyWrk += "M->"+cCpoWrk+If(ix1 != Len(cChaveCpo),"+","")

				If Empty( &("M->"+cCpoWrk) ) .and. (Right(cChaveCpo,Len(cCpoWrk)) == cCpoWrk)  && Caso na tenha sido todos os campos da chave informado nao sera checado a duplicidade
					lRet := .t.
				EndIf

			EndIf

			cCpoWrk := ""

		EndIf

	Next

	cKeyWrk += "M->"+cCpoWrk

	If !lRet

		DbSelectArea(cAliasCpo)
		DbSetOrder(nIndice)
		If DbSeek( xFilial(cAliasCpo) + &(cKeyWrk) )
			Help("  ",1,cHelp)
			lRet:=.f.
		Else
			lRet:=.t.
		EndIf

	EndIf

	// Volta posicoes originais
	sRestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_OSONLINบAutor  ณFabio               บ Data ณ  05/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra os servisos on line na OS                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_OSONLINE(aChave,lAutomatic)

	Local nPosReg:=0,nTempoTra:=0,cQuebra,aArea:={}
	Local oVerde    := LoadBitmap( GetResources(), "BR_VERDE" )
	Local oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO" )
	Local oAmarelo  := LoadBitmap( GetResources(), "BR_AMARELO" )
	Local oAzul		 := LoadBitmap( GetResources(), "BR_AZUL" )
	Local lLocalPrisma := .t.
	Private aServicos := {}

	aArea := sGetArea(aArea,"VO1")
	aArea := sGetArea(aArea,"VV1")
	aArea := sGetArea(aArea,"VV2")
	aArea := sGetArea(aArea,"SA1")
	aArea := sGetArea(aArea,"VO2")
	aArea := sGetArea(aArea,"VO3")
	aArea := sGetArea(aArea,"VO4")
	aArea := sGetArea(aArea,"VOK")
	aArea := sGetArea(aArea,"VO6")
	aArea := sGetArea(aArea,"VAI")
	If !Empty(Alias())
		aArea := sGetArea(aArea,Alias())
	EndIf

	DbSelectArea("VO1")
	If aChave==Nil

		If RecCount() > 0 .and. AxPesqui() == 0 .Or. !Found()

			sRestArea(aArea)
			Return

		EndIf

		aChave := {}

		Aadd(aChave,IndexOrd())
		Aadd(aChave,&(IndexKey()) )

	EndIf

	lAutomatic := If(lAutomatic#NIL,lAutomatic,.f.)

	DbSelectArea("VO1")
	DbSetOrder( aChave[1] )
	If !DbSeek( aChave[2] )

		If aChave[1]==7
			DbSelectArea("VO4")
			DbSetOrder(9)
			If !DbSeek( aChave[2] )

				sRestArea(aArea)
				Return

			EndIf

			DbSelectArea("VO2")
			DbSetOrder(2)
			DbSeek( xFilial("VO2") + VO4->VO4_NOSNUM )

			DbSelectArea("VO1")
			DbSetOrder(1)
			DbSeek( xFilial("VO1") + VO2->VO2_NUMOSV )

		Else

			sRestArea(aArea)
			Return

		EndIf

	EndIf

	If aChave[1]==7 .And. VO1->VO1_FILIAL+VO1->VO1_CODCOR+VO1->VO1_PRISMA # aChave[2]
		lLocalPrisma := .f.
	EndIf

	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)

	DbSelectArea("VV2")
	DbSetOrder(1)
	DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD)

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO)

	// Cria Vetor de servico
	DbSelectArea("VO2")
	DbSetOrder(1)
	DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV+"S")
	Do While !Eof() .And. VO2->VO2_FILIAL == xFilial("VO2") .And. VO2->VO2_NUMOSV ==VO1->VO1_NUMOSV .and. VO2->VO2_TIPREQ == "S"

		DbSelectArea("VO4")
		DbSetOrder(1)
		DbSeek(xFilial("VO4")+VO2->VO2_NOSNUM)
		cQuebra  := ""
		Do While !Eof() .And. VO4->VO4_FILIAL == xFilial("VO4") .And. VO4->VO4_NOSNUM ==VO2->VO2_NOSNUM

			If Empty(VO4->VO4_DATDIS) .And. ( lLocalPrisma .Or. VO4->VO4_FILIAL+VO4->VO4_CODCOR+VO4->VO4_PRISMA == aChave[2] )

				DbSelectArea("VOK")
				DbSetOrder(1)
				DbSeek(xFilial("VOK")+VO4->VO4_TIPSER)
				If VOK->VOK_INCMOB $ "1/3/4"  // 1-Mao-de-Obra/3-Valor livre c/Base na Tabela/4-Retorno de Servico

					If VO4->VO4_TIPTEM+VO4->VO4_CODSER # cQuebra .Or. (Len(aServicos)#0 .And. Ascan(aServicos,{|x| x[1]+x[3] == VO4->VO4_CODSER+VO4->VO4_CODPRO }) == 0)
						Aadd(aServicos,{VO4->VO4_CODSER,Posicione("VO6",1,xFilial("VO6")+VO4->VO4_SERINT,"VO6_DESSER"),VO4->VO4_CODPRO,Posicione("VAI",1,xFilial("VAI")+VO4->VO4_CODPRO,"VAI_NOMTEC"),0,0,0,VO4->VO4_TEMPAD,VO4->VO4_SRVFIN})
						cQuebra   := VO4->VO4_TIPTEM+VO4->VO4_CODSER
					EndIf

					If !Empty(VO4->VO4_CODPRO).And.!Empty(VO4->VO4_DATINI)

						nTempoTra := 0
						If !Empty(VO4->VO4_DATINI) .And. !Empty(VO4->VO4_DATFIN)
							nTempoTra := VO4->VO4_TEMTRA
						Else
							nHora := Val(Substr(time(),1,2)+Substr(time(),4,2))
							nTempoTra := FG_TEMPTRA(VO4->VO4_CODPRO,VO4->VO4_DATINI,VO4->VO4_HORINI,dDataBase,nHora,"N",.f.,"O/E")
						EndIf

						nPosReg := Ascan(aServicos,{|x| x[1] == VO4->VO4_CODSER })

						nTempoTra := nTempoTra + aServicos[nPosReg,5]

						Do While nPosReg>0.And.nPosReg<=Len(aServicos).And.aServicos[nPosReg,1] == VO4->VO4_CODSER

							aServicos[nPosReg,5] := nTempoTra
							aServicos[nPosReg,6] := VO4->VO4_TEMPAD

							If aServicos[nPosReg,5] > aServicos[nPosReg,6]
								aServicos[nPosReg,7] := aServicos[nPosReg,5]-aServicos[nPosReg,6]
							EndIf

							nPosReg++

						EndDo

					EndIf

				EndIf

			EndIf

			DbSelectArea("VO4")
			DbSkip()

		EndDo

		DbSelectArea("VO2")
		DbSkip()

	EndDo

	If Len(aServicos) == 0
		Aadd(aServicos,{" "," "," "," ",0,0,0,0,""})
	EndIf

	DEFINE MSDIALOG oDlgBox TITLE STR0004+" - "+aChave[2] From 3,0 to 25,70 of oMainWnd  //"Box da oficina"

	@ 002,002 SCROLLBOX oSBox VERTICAL SIZE 72,275 OF oDlgBox BORDER PIXEL

	@ 001,005 SAY STR0006 Font TFont():New( "System", 8, 12 ) SIZE 100,15 OF oSbox PIXEL COLOR CLR_BLUE //"Ordem Srv"
	@ 001,045 SAY VO1->VO1_NUMOSV Font TFont():New( "System", 8, 12 ) PICTURE "@!" SIZE 100,15 OF oSbox PIXEL COLOR CLR_RED

	@ 011,005 SAY STR0007 Font TFont():New( "System", 8, 12 ) SIZE 50,15 OF oSbox PIXEL COLOR CLR_BLUE //"Dt Abertura"
	@ 011,045 SAY VO1->VO1_DATABE Font TFont():New( "System", 8, 12 ) PICTURE "@D" SIZE 50,15 OF oSbox PIXEL COLOR CLR_RED
	@ 011,145 SAY STR0008 Font TFont():New( "System", 8, 12 ) SIZE 50,15 OF oSbox PIXEL COLOR CLR_BLUE //"Hr Abertura"
	@ 011,185 SAY VO1->VO1_HORABE Font TFont():New( "System", 8, 12 ) PICTURE "@E 99:99" SIZE 50,15 OF oSbox PIXEL COLOR CLR_RED
	@ 021,005 SAY STR0023 Font TFont():New( "System", 8, 12 ) SIZE 50,15 OF oSbox PIXEL COLOR CLR_BLUE //"Dt Abertura"
	@ 021,045 SAY VO1->VO1_DATENT Font TFont():New( "System", 8, 12 ) PICTURE "@D" SIZE 50,15 OF oSbox PIXEL COLOR CLR_RED
	@ 021,145 SAY STR0024 Font TFont():New( "System", 8, 12 ) SIZE 50,15 OF oSbox PIXEL COLOR CLR_BLUE //"Hr Abertura"
	@ 021,185 SAY VO1->VO1_HORENT Font TFont():New( "System", 8, 12 ) PICTURE "@E 99:99" SIZE 50,15 OF oSbox PIXEL COLOR CLR_RED

	@ 031,005 SAY STR0009 Font TFont():New( "System", 8, 12 ) SIZE 100,15 OF oSbox PIXEL COLOR CLR_BLUE //"Chassi"
	@ 031,045 SAY VV1->VV1_CHASSI Font TFont():New( "System", 8, 12 ) PICTURE "@!" SIZE 150,15 OF oSbox PIXEL COLOR CLR_RED
	@ 041,005 SAY STR0010  Font TFont():New( "System", 8, 12 ) SIZE 100,15 OF oSbox PIXEL COLOR CLR_BLUE //"Marca"
	@ 041,045 SAY VV1->VV1_CODMAR Font TFont():New( "System", 8, 12 ) PICTURE "@!" SIZE 15,15 OF oSbox PIXEL COLOR CLR_RED
	@ 051,005 SAY STR0011 Font TFont():New( "System", 8, 12 ) SIZE 100,15 OF oSbox PIXEL COLOR CLR_BLUE //"Modelo"
	@ 051,045 SAY VV1->VV1_MODVEI Font TFont():New( "System", 8, 12 ) PICTURE "@!" SIZE 150,15 OF oSbox PIXEL COLOR CLR_RED
	@ 051,145 SAY STR0012 Font TFont():New( "System", 8, 12 ) SIZE 100,15 OF oSbox PIXEL COLOR CLR_BLUE //"Descricao"
	@ 051,185 SAY VV2->VV2_DESMOD Font TFont():New( "System", 8, 12 ) PICTURE "@!" SIZE 150,15 OF oSbox PIXEL COLOR CLR_RED
	@ 061,005 SAY STR0013 Font TFont():New( "System", 8, 12 ) SIZE 100,15 OF oSbox PIXEL COLOR CLR_BLUE //"Cliente"
	@ 061,045 SAY VO1->VO1_PROVEI+Space(5)+VO1->VO1_LOJPRO Font TFont():New( "System", 8, 12 ) PICTURE "@!" SIZE 100,15 OF oSbox PIXEL COLOR CLR_RED
	@ 061,145 SAY STR0014 Font TFont():New( "System", 8, 12 ) SIZE 100,15 OF oSbox PIXEL COLOR CLR_BLUE //"Nome"
	@ 061,185 SAY SA1->A1_NREDUZ Font TFont():New( "System", 8, 12 ) PICTURE "@!" SIZE 150,15 OF oSbox PIXEL COLOR CLR_RED

	@ 75,001 TO 149,277 LABEL STR0015 OF oDlgBox PIXEL //"Servicos"

	@ 80,004 LISTBOX oLbServicos FIELDS HEADER  (""),;
	(STR0016),; //"Servico"
	(STR0012),; //"Descricao"
	(STR0017),; //"Mecanico"
	(STR0014),; //"Nome"
	(STR0018),; //"Tp Pad"
	(STR0019); //"Tp Estourado"
	COLSIZES 10,40,60,30,60,30,30;
	SIZE 271,57 OF oDlgBox PIXEL

	oLbServicos:SetArray(aServicos)
	oLbServicos:bLine := { || {  If(aServicos[oLbServicos:nAt,9]=="1",oAzul,If(!Empty(aServicos[oLbServicos:nAt,3]),If(!Empty(aServicos[oLbServicos:nAt,7]),oVermelho,oVerde ),oAmarelo)) ,;
	aServicos[oLbServicos:nAt,1] ,;
	aServicos[oLbServicos:nAt,2] ,;
	aServicos[oLbServicos:nAt,3] ,;
	aServicos[oLbServicos:nAt,4] ,;
	Transform( aServicos[oLbServicos:nAt,8] , "@R 99:99" ) ,;
	Transform( aServicos[oLbServicos:nAt,7] , "@R 999:99" ) }}

	@ 140,003 BITMAP oVVerde RESOURCE "BR_VERDE" OF oDlgBox NOBORDER SIZE 10,10 when .f. PIXEL
	@ 140,015 SAY STR0020 OF oDlgBox SIZE 52,08 PIXEL  //"Em andamento"
	@ 140,080 BITMAP oVAmarelo RESOURCE "BR_AMARELO" OF oDlgBox NOBORDER SIZE 10,10 when .f. PIXEL
	@ 140,092 SAY STR0005 OF oDlgBox SIZE 52,08 PIXEL  //"Parado"
	@ 140,152 BITMAP oVVermelho RESOURCE "BR_VERMELHO" OF oDlgBox NOBORDER SIZE 10,10 when .f. PIXEL
	@ 140,165 SAY STR0021 OF oDlgBox SIZE 52,08 PIXEL  //"Estourado"
	@ 140,212 BITMAP oVAzul RESOURCE "BR_AZUL" OF oDlgBox NOBORDER SIZE 10,10 when .f. PIXEL
	@ 140,225 SAY STR0025 OF oDlgBox SIZE 52,08 PIXEL  //"Estourado"


	DEFINE SBUTTON FROM 150,240 TYPE 2 ACTION (nTecla := 1,oDlgBox:End()) ENABLE OF oDlgBox

	If lAutomatic
		DEFINE TIMER oTime1Box INTERVAL (GETMV("MV_TEMPBOX")*100) ACTION oDlgBox:End() OF oDlgBox
		oTime1Box:lActive := .t.
	EndIf

	ACTIVATE MSDIALOG oDlgBox CENTER

	sRestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_PESQTABบAutor  ณRicardo Farinelli   บ Data ณ  10/17/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a verificacao no sx3 se o dado passado no parametro  บฑฑ
ฑฑบ          ณexiste. Este pode ser um alias ou um campo especifico.      บฑฑ
ฑฑบ          ณUtilizar esta funcao para implementacoes de novas rotinas noบฑฑ
ฑฑบ          ณdecorrer de uma versao.                                     บฑฑ
ฑฑบParametrosณuChave = Alias do arquivo ou um nome de campo ou um array   บฑฑ
ฑฑบ          ณ         contendo varios campos                             บฑฑ
ฑฑบUso       ณGestao de Concessionarias                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_PESQTAB(uChave)
	Local nwnk , nTipo , lRet := .T. , aOrd := {}
	aOrd := SGetArea()
	SX3->(SGetArea(aOrd))

	If ValType(uChave)=="C"
		nTipo := Iif(Len(Alltrim(uChave))==3,1,2)
		If nTipo == 1
			SX3->(DbsetOrder(1))
			If !SX3->(Dbseek(uChave))
				lRet := .F.
			Else
				If Sele(uChave)== 0
					DbselectArea(uChave)
				Endif
			Endif
		Else
			SX3->(DbsetOrder(2))
			If !SX3->(Dbseek(uChave))
				lRet := .F.
			Else
				Dbselectarea(SX3->X3_ARQUIVO)
				If FieldPos(uChave) == 0
					lRef := .F.
				Endif
			Endif
		Endif
	Elseif ValType(uChave)=="A"
		For nwnk := 1 To Len(uChave)
			SX3->(DbsetOrder(2))
			If !SX3->(Dbseek(uChave[nwnk]))
				lRet := .F.
				Exit
			Else
				Dbselectarea(SX3->X3_ARQUIVO)
				If FieldPos(uChave[nwnk]) == 0
					lRef := .F.
					Exit
				Endif
			Endif
		Next
	Endif
	If !lRet
		Help(" ",1,"CPOINEXIS")
	Endif

	SRestArea(aOrd)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_RASTRO บAutor  ณFabio               บ Data ณ  10/19/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออ ออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida lote CTL                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_RASTRO(cGruIte,cCodIte,nQtd,cLoteCTL,cNumLote,cSerLote,cLOCALI2,cParLocal)

	Local aArea		:= {}
	Local lRetorna := .t. , nSaldo:=0

	Default nQtd:=0
	Default cLoteCTL := ""
	Default cNumLote := ""

	aArea	:= sGetArea(aArea,"SB1")
	If !Empty(Alias())
		aArea	:= sGetArea(aArea,Alias())
	EndIf

	DbSelectArea("SB1")
	DbSetOrder(7)
	MsSeek( xFilial("SB1") + cGruIte + cCodIte )

	If cSerLote # NIL .And. cLOCALI2 == NIL

		DbSelectArea("SB5")
		DbSetOrder(1)
		DbSeek( xFilial("SB5") + SB1->B1_COD )

		cLOCALI2 := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")

	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se o Produto possui rastreabilidade                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Rastro(SB1->B1_COD)
		Help( " ", 1, "NAORASTRO" )
		lRetorna := .F.
	Else
		// Lote/SubLote
		If Rastro(SB1->B1_COD,"L") .And. !Empty(cNumLote)
			Help( " ", 1, "NAORASTRO" )
			lRetorna := .F.
		EndIf

		// Serie do Lote
		If cSerLote # NIL .And. !MtAvlNSer(SB1->B1_COD,cSerLote,nQtd)
			lRetorna:=.F.
		EndIf

		If lRetorna
			nSaldo := SldAtuEst(SB1->B1_COD, IIf( cParLocal == NIL , FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") , cParLocal) ,nQtd,cLoteCTL,cNumLote,cLOCALI2,cSerLote)
			If ( nQtd > nSaldo )
				Help(" ",1,"A440ACILOT")
				lRetorna  := .F.
			EndIf
		EndIf

	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRestaura a Entrada da Rotina                                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	sRestArea(aArea)

Return(lRetorna)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_VERFORGARบAutor  ณAndre/Emilton     บ Data ณ  10/19/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออ ออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida formula de garantia, evitando que caia o sistema     บฑฑ
ฑฑบ          ณcaso se constate uma nao conformidade na mesma              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_VERFORGAR(cFormula)
	Local   bBlock   := ErrorBlock(),bErro := ErrorBlock( { |e| lRetorno := .f. , FGX_CheckBug(e) })
	Private lRetorno := .t.
	Private cFor

	cFor := cFormula
	cResult := &cFor

	If !lRetorno
		If !(ValType(cResult) $ "NCLD")
			lRetorno := .f.
		EndIf
	Endif

	ErrorBlock(bBlock)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_chkerforบAutor  ณAndre/Emilton      บ Data ณ  10/19/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออ ออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida formula de garantia, evitando que caia o sistema     บฑฑ
ฑฑบ          ณcaso se constate uma nao conformidade na mesma              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ChkErVFor(e)
	Local lRet := .t.
	if e:gencode > 0
		Help( " ",1,"FORGARINV",,e:Description)
		lRet     :=.f.
		lRetorno := .f.
	Else
		lRetorno := .t.
	Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_TRANSACบAutor  ณFabio               บ Data ณ  10/27/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณControla transaction                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณcPrograma=Programa que esta sendo controlado transacao      บฑฑ
ฑฑบ          ณcRotina=Rotina que sera controlada                          บฑฑ
ฑฑบ          ณnCount=contador de controle para a quantidade de vez que ja บฑฑ
ฑฑบ          ณ       foram executadas                                     บฑฑ
ฑฑบ          ณnRegistro=Registro de controle do arquivo "Recno"           บฑฑ
ฑฑบ          ณlFim=.t. para quando terminar a transacao                   บฑฑ
ฑฑบ          ณcRetorno="N" Retorna o registro da ultima execucao          บฑฑ
ฑฑบ          ณ         "L" Retorna se finaliza a transacao                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_TRANSACTION(cPrograma,cRotina,nCount,nRegistro,lFim,cRetorno)

	Local xRetorno , cSele:=Alias()
	Default cPrograma:=""
	Default cRotina  :=""
	Default nCount   :=0
	Default nRegistro:=0
	Default lFim     :=.t.
	Default cRetorno :="N"

	cPrograma := Alltrim(cPrograma)+Space(Len(VH8->VH8_NOMPRO)-Len(Alltrim(cPrograma)))
	cRotina   := Alltrim(cRotina)+Space(Len(VH8->VH8_NUMPRO)-Len(Alltrim(cRotina)))

	If lFim
		nRegistro:=0
	EndIf

	DbSelectArea("VH8")
	DbSetOrder(1)
	DbSeek( xFilial("VH8")+cPrograma+cRotina )

	RecLock("VH8",!Found())

	VH8->VH8_FILIAL:=xFilial("VH8")
	VH8->VH8_NOMPRO:=cPrograma
	VH8->VH8_NUMPRO:=cRotina
	If ((xRetorno:=(nCount >= 500)) .Or. lFim)
		VH8->VH8_ULTREG:=nRegistro
	EndIf

	MsUnLock()

	xRetorno:=!xRetorno
	If cRetorno == "N"
		xRetorno:=VH8->VH8_ULTREG
	EndIf
	If len(cSele) > 0
		DbSelectArea(cSele)
	EndIf

Return(xRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_STATUS บAutor  ณRicardo Farinelli   บ Data ณ  04/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o sistema esta utilizando controle de Status de บฑฑ
ฑฑบ          ณveiculos e retorna o status conforme os parametros passados.บฑฑ
ฑฑบParametros|cChassi = opcional. Se passado acha o chassi interno e gravaบฑฑ
ฑฑบ          |          codigo do status                                  บฑฑ
ฑฑบ          |cTipo   = E = status para entrada de veiculo                บฑฑ
ฑฑบ          |          O = status para abertura de ordem de servico      บฑฑ
ฑฑบ          |          F = status para fecham.  de ordem de servico      บฑฑ
ฑฑบ          |          S = status para saida de veiculo                  บฑฑ
ฑฑบ          |          X = apenas verifica se utiliza status ou nao      บฑฑ
ฑฑบ          |          C = apaga status do veiculo                       บฑฑ
ฑฑบRetorno   |1a opcao: Retornar o codigo do status desejado com o seguin-บฑฑ
ฑฑบ          |          te exemplo:  cCod := FG_STATUS(,"E")              บฑฑ
ฑฑบ          |2a opcao: Gravar o codigo do status desejado com o seguinte บฑฑ
ฑฑบ          |          exemplo: VV1_STATUS := FG_STATUS("00000001","E")  บฑฑ
ฑฑบ          |3a opcao: Retornar se esta sendo utilizado controle de      บฑฑ
ฑฑบ          |          status de veiculos com o seguinte exemplo:        บฑฑ
ฑฑบ          |          If FG_STATUS(,"X") == .T.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_STATUS(cChassi,cTipo)
	Local aAlias := SGetArea()
	If cChassi == Nil
		Do Case
			Case cTipo == "X"
			Return (GETMV("MV_VEIST",,"N") == "S")
			Case cTipo == "E"
			Return GETMV("MV_VEISTE",,"00")
			Case cTipo == "S"
			Return GETMV("MV_VEISTS",,"00")
			Case cTipo == "O"
			Return GETMV("MV_VEISTO",,"00")
			Case cTipo == "F"
			Return GETMV("MV_VEISTF",,"00")
		EndCase
	Else
		sGetArea(aAlias,"VV1")
		DbselectArea("VV1")
		DbsetOrder(1) // por chassi
		If Dbseek(xFilial("VV1")+cChassi)
			Reclock("VV1",.F.)
			VV1->VV1_STATUS := 	IIf(cTipo == "E",GETMV("MV_VEISTE",,"00"),;
			Iif(cTipo == "S",GETMV("MV_VEISTS",,"00"),;
			Iif(cTipo == "O",GETMV("MV_VEISTO",,"00"),;
			Iif(cTipo == "F",GETMV("MV_VEISTF",,"00"),"  "))))
			MsUnlock()
		Endif
		SRestArea(aAlias)
	Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_STATOK บAutor  ณRicardo Farinelli   บ Data ณ  04/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna se o veiculo pode ou nao ser utilizado em uma proposบฑฑ
ฑฑบ          ณta                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_STATOK()
	Local lRet := .T.
	If VAE->(Dbseek(xFilial("VAE")+VV1->VV1_STATUS))
		If VAE->VAE_LIBSP == "0"
			lRet := .F.
		Endif
	Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFG_GRVLOJA ณ Autor ณ Valdir F. Silva       ณ Data ณ 13.09.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Gravacao do orcamento no Loja                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณaCabec     : Array com o Cabecalho                           ณฑฑ
ฑฑณ			 ณaItens     : Array com os Itens                              ณฑฑ
ฑฑณ          ณaPag       : Array com o Cabecalho                           ณฑฑ
ฑฑณ          ณlExclui    : Se .T. Exclui o Orcamento                       ณฑฑ
ฑฑณ          ณcOrcamento : Numero do Orcamento p/ Excluir ou Incluir       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGestao de Concessionarias                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_GRVLOJA(aCabec,aItens,aPag,lExclui,cOrcamento)
	Local lRet      := .T.
	Local nX
	Local aAreaSB1  := GetArea("SB1")
	Local aArea     := GetArea()
	Local lNovo     := .F.
	Local cConfVenda:= Replicate("S",12)
	Local nCheck    := 2
	Local cItem     := ""
	Private cTipoCli:= ""
	Default lExclui := .F.
	Default aPag := {}
	If lExclui
		DbSelectArea("SL1")
		DbSetOrder(1)
		If DbSeek(xFilial("SL1")+cOrcamento)
			If !Empty(L1_DOC+L1_SERIE)
				Help(' ',1, 'PEDIJAFEC')
				lRet := .f.
			Else
				//Apaga SL2 Itens
				DbSelectArea("SL2")
				DbSetOrder(1)
				DbSeek(xFilial("SL2")+SL1->L1_NUM)
				While !Eof() .and. xFilial("SL2") == L2_FILIAL .and. L2_NUM == SL1->L1_NUM
					RecLock("SL2",.F.,.T.)
					DbDelete()
					MsUnlock()
					DbSkip()
				EndDo

				//Apaga SL4 Pagamentos
				DbSelectArea("SL4")
				DbSetOrder(1)
				DbSeek(xFilial("SL4")+SL1->L1_NUM)
				While !Eof() .and. xFilial("SL4") == L4_FILIAL .and. L4_NUM == SL1->L1_NUM
					RecLock("SL4",.F.,.T.)
					DbDelete()
					MsUnlock()
					DbSkip()
				EndDo

				//Apaga SL1 Cabec
				DbSelectArea("SL1")
				RecLock("SL1",.F.,.T.)
				DbDelete()
				MsUnlock()
				DbSkip()
			EndIf
		Else
			Help(' ',1, 'NAOEXISTE')
			lRet := .f.
		EndIf
	Else
		// Gravando na configuracao se imprime NF ou Cupom Fiscal
		// nCheck = 1 -> Cupom Fiscal (ECF) "S"
		// nCheck = 2 -> Nota Fiscal        "S"
		cConfVenda := Subs(cConfVenda,1,7)+If(nCheck==1,"S","N")+If(nCheck==2,"S","N")+Subs(cConfVenda,10,3)
		//	cConfVenda := 	"SSSSSSSSNSSS" // Luis - Verificar se atende ECF
		//Posiciona no Cliente
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+aCabec[01]+aCabec[02])

		if ExistBlock("VLOJA1A")
			ExecBlock("VLOJA1A",.f.,.f.)
		EndIf

		if Empty(cTipoCli)
			cTipoCli := SA1->A1_TIPO
		Endif

		//Posiciona no Vendedor
		DbSelectArea("SA3")
		DbSetOrder(1)
		If !Empty(aCabec[03])
			DbSeek(xFilial("SA3")+aCabec[03])
		Else
			DbSeek(xFilial("SA3")+GetMv("MV_VENDPAD"))
		EndIf

		DbSelectArea("SL1")
		DbSetOrder(1)
		cOrcamento := CriaVar("L1_NUM")
		lNovo := .T.
		ConfirmSx8()

		//Inicia a Inclusao no SL1 - Cabec
		RecLock("SL1",.T.)
		L1_FILIAL 	:= xFilial("SL1")
		L1_NUM    	:= cOrcamento
		L1_CLIENTE 	:= aCabec[01]
		L1_LOJA     := aCabec[02]
		L1_VEND   	:= aCabec[03]
		L1_EMISSAO 	:= dDataBase
		L1_DTLIM   	:= dDataBase+GetNewPar("MV_DTLIMIT",0)//aCabec[04]
		L1_VEND2   	:= SA3->A3_SUPER
		L1_VEND3    := SA3->A3_GEREN
		L1_COMIS   	:= SA3->A3_COMIS
		L1_CONFVEN 	:= cConfVenda
		L1_IMPRIME 	:= Str(nCheck,1)+"S"
		L1_OPERACA  := " "
		L1_TIPOCLI  := cTipoCli
		L1_VALICM   := Round(aCabec[05],2)
		L1_VALISS  	:= Round(aCabec[06],2)
		L1_VALIPI   := Round(aCabec[07],2)
		L1_DESCONT 	:= 0 // Round(aCabec[08],MsDecimais(1))
		L1_VLRLIQ  	:= Round(aCabec[09]-aCabec[08],2)
		L1_VLRTOT  	:= Round(aCabec[09]-aCabec[08],2)
		L1_VALMERC  := Round(aCabec[09],2)
		// 	L1_VALMERC  := Round(aCabec[09]-aCabec[08],2)
		L1_VALBRUT  := Round(aCabec[09]-aCabec[08],2)
		L1_VEICTIP	:= aCabec[10]
		L1_VEIPESQ  := aCabec[11]
		L1_CONDPG   := Iif(len(aCabec) > 11 , aCabec[12], RetCondVei())
		IF len(aCabec) > 12 .and. aCabec[13] <> "" .and. FIELDPOS(L1_CLIENT) = 0 .and. FIELDPOS(L1_LOJENT) = 0
			L1_CLIENT := aCabec[13]
			L1_LOJENT := aCabec[14]
		EndIf
		if len(aCabec) > 14
			L1_FRETE  	:= aCabec[15]
			L1_SEGURO   := Round(aCabec[16],2)
			L1_DESPESA  := Round(aCabec[17],2)
		Endif

		// grava campos faltantes...luis
		L1_ENTRADA := Round(aCabec[09]-aCabec[08],2)
		L1_DINHEIR := Round(aCabec[09]-aCabec[08],2)
		L1_PARCELA := aCabec[20]
		L1_VALICM := Round(aCabec[21],2)
		L1_FORMPG := aCabec[22]
		L1_VLRDEBI := Round(aCabec[23],2)
		L1_HORA := aCabec[24]
		L1_TIPODES := aCabec[25]
		L1_ESTACAO := aCabec[26]
		If ValType(aCabec[27]) != "U" .and. ValType(aCabec[28]) != "U"
			L1_VEND2 := aCabec[27] // Vendedor 2
			L1_VEND3 := aCabec[28] // Vendedor 3
		Endif
		L1_ITEMSD1 := "000000"
		L1_BRICMS  := Round(aCabec[29],2)
		L1_ICMSRET := Round(aCabec[30],2)
		MsUnlock()

		//Inicio da Gravacao do SL2 - Itens
		DbSelectArea("SL2")
		DbSetOrder(1)
		cItem := StrZero(1,Len(SL2->L2_ITEM))
		For nX:= 1 To Len(aItens)
			If aItens[nX,04] > 0
				RecLock("SL2",.T.)
				L2_FILIAL  := xFilial("SL2")
				L2_NUM	  := cOrcamento
				L2_PRODUTO := aItens[nX,01] //Produto ->B1_COD
				// L2_BCONTA  := aItens[nX,01] //Cod.Barras -> B1_COD
				L2_ITEM	  := cItem //Numero do item - sequencial por orcamento
				L2_DESCRI  := aItens[nX,02] //Descricao do produto -> B1_DESC
				L2_QUANT	  := Round(aItens[nX,03],2) //Quantidade
				L2_VRUNIT  := Round(aItens[nX,04],2) //Valor Unitario (Liquido -> Abatido os descontos)
				L2_VLRITEM := Round(aItens[nX,05],2) //Valor do Item (Liquido  -> Abatido os descontos)
				L2_LOCAL   := aItens[nX,06] //Almoxarifado
				L2_UM	     := aItens[nX,07] //Unidade de medida
				L2_DESC    := Round(aItens[nX,08],2) //Desconto em percentual
				L2_VALDESC := Round(aItens[nX,09],2) //Desconto em valor
				L2_TES     := aItens[nX,10] //Tipo de E/S
				L2_CF	     := aItens[nX,11] //Codigo Fiscal (Tabela 13 SX5)
				L2_VALIPI  := Round(aItens[nX,12],2) //Valor do IPI
				L2_VALICM  := Round(aItens[nX,13],2) //Valor de ICM
				L2_VALISS  := Round(aItens[nX,14],2) //Valor do ISS
				L2_BASEICM := Round(aItens[nX,15],2) //Base ICMS
				L2_PRCTAB  := Round(aItens[nX,16],2) //Preco Tabela
				L2_VEND    :=If(!Empty(aCabec[03]),aCabec[3],GetMv("MV_VENDPAD"))	    //Vendedor
				L2_VENDIDO := " "	          // "N" -> Orcamento em aberto nao foi vendido
				L2_GRADE   := "N"           //Grade    "N"
				L2_TABELA  := "1"	          //Tabela Preco -> 1
				L2_EMISSAO := dDataBase     //Dt Emissao
				L2_LOTECTL := aItens[nX,17] //Lote
				L2_NLOTE   := aItens[nX,18] //Sub Lote
				L2_LOCALIZ := aItens[nX,19] //Localizacao
				L2_NSERIE  := aItens[nX,20] //Numero Serie

				// grava campos faltantes...luis
				L2_VALPS2 := Round(aItens[nX,21],2)
				L2_VALCF2 := Round(aItens[nX,22],2)
				L2_BASEPS2 := Round(aItens[nX,23],2)
				L2_BASECF2 := Round(aItens[nX,24],2)
				L2_ALIQPS2 := Round(aItens[nX,25],2)
				L2_ALIQCF2 := Round(aItens[nX,26],2)
				L2_SEGUM  := aItens[nX,27]
				L2_BRICMS  := Round(aItens[nX,28],2)
				L2_ICMSRET := Round(aItens[nX,29],2)
				If Len(aItens[nx]) >= 30
					L2_SITTRIB := aItens[nX,30]
				Endif
				L2_ITEMSD1 := strzero(nX,6)

				If ( ExistBlock("GRVITLOJA") )
					ExecBlock("GRVITLOJA",.f.,.f.,{aItens,aCabec,nX})
				EndIf

			EndIf
			cItem := Soma1(cItem)
			MsUnlock()
		Next
		//Inicio da gravacao do SL4 - Parcelas
		If ValType(aPag) == "A" .and. Len(aPag) > 0
			DbSelectArea("SL4")
			DbSetOrder(1)
			For nX:= 1 To Len(aPag)
				RecLock("SL4",.T.)
				L4_FILIAL  := xFilial("SL4") //Filial
				L4_NUM     := cOrcamento     //Numero do Orcamento
				L4_DATA    := aPag[nX,1]    //Data p/ Pagamento
				L4_VALOR   := aPag[nX,2]    //Valor
				L4_FORMA   := aPag[nX,3]    //Forma Pgto      -- MV_MOEDA1 MV_SIMB1 -- (R$) CH, CC FI (TABELA 24 SX5)
				L4_ADMINIS := aPag[nX,4]    //Administradora  -- (SAE) CODIGO - NOME     (999 - XXXXXXXX)
				L4_MOEDA   := 1
				MsUnlock()
			Next
		Else
			DbSelectArea("SL4")
			DbSetOrder(1)
			RecLock("SL4",.T.)
			L4_FILIAL  := xFilial("SL4")
			L4_NUM     := cOrcamento
			L4_DATA    := dDataBase
			L4_VALOR   := aCabec[09]-aCabec[08]
			L4_FORMA   := AllTrim(GetMv("MV_SIMB1"))
			L4_ADMINIS := ""
			L4_MOEDA   := 1
			MsUnlock()
		EndIf

		If lNovo .and. __lSx8
			ConfirmSX8()
		EndIf
	EndIf
	RestArea(aAreaSB1)
	RestArea(aArea)
Return lRet

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFG_DEVLOJA ณ Autor ณ Valdir F. Silva       ณ Data ณ 23.10.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณGravacao do Numero da nota e pedido orcamento do Loja        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณcTipo     : Tipo de gravacao (Quem Gravou)                   ณฑฑ
ฑฑณ			 ณcPesq     : Chave a pesquisar nos arquivos do OFI,VEI,PEC	   ณฑฑ
ฑฑณ          ณcNota     : Numero da nota gravado no Loja                   ณฑฑ
ฑฑณ          ณcSerie    : Serie da nota gravado no loja                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGestao de Concessionarias                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_DEVLOJA(cTipo,cPesq,cNota,cSerie,lCancel)
	Local lRet         := .t.
	Local cCombust     := GetMv("MV_COMBUS") // para tratamento do Lubrificante na CD6 (SEFAZ)
	Local nRecVV0      := 0

	Private lOM150Auto := .t.
	Default cNota      := ""
	Default lCancel    := .f.

	cSlvAlias := Alias()
	nRecSF2 := SF2->(RecNo())
	nRecSD2 := SD2->(RecNo())
	nRecSE1 := SE1->(RecNo())
	nRecSB1 := SB1->(RecNo())
	nRecCD6 := CD6->(RecNo())

	conout("FG_DEVLOJA - ENTRADA DA FUNCAO - EXECAUTO LOJA701:  "+Dtoc(dDataBase)+" - "+Time())

	If cTipo == "1" // Balcao
		If lCancel // Cancelar
			lRet := OM220CANC(SL1->L1_NUM,cNota) // Verifica/Cancela Orcamento
			// cRetRes := OX001RESITE(VS1->VS1_NUMORC,.t.) // RETIRADO POIS QUANDO EXCLUI A NOTA PELO FATURAMENTO JA RESERVA O ITEM AUTOMATICAMENTE - THIAGO/MANOEL
			// VS1->VS1_STATUS := "F"
			//if Empty(cRetRes)
			//	lRet := .f.
			//Endif

			// -----------------------------------------------
			// Grava็ใo do STATUS DA RESERVA no VS1 (VS1_STARES)
			// -----------------------------------------------
			if VS1->(FieldPos("VS1_STARES")) > 0
				cAliasLD := GetNextAlias()
				cQuery := "SELECT R_E_C_N_O_ RECVS1 FROM "+RetSqlName("VS1")
				cQuery += " WHERE VS1_FILIAL ='"+xFilial("VS1")+"'"
				cQuery += " AND VS1_PESQLJ ='"+SL1->L1_NUM+"' AND D_E_L_E_T_ =  ' '"

				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasLD, .F., .T. )
				//
				while !((cAliasLD)->(eof()))
					DBSelectArea("VS1")
					DBGoTo((cAliasLD)->(RECVS1))

					lTemResS := .f.
					lNTemRes := .f.

					DBSelectArea("VS3")
					DBSetOrder(1)
					DBSeek(xFilial("VS3")+ VS1->VS1_NUMORC)
					//
					cFaseOrc := OI001GETFASE(__cUserId,2)
					nPosR := At("R",cFaseOrc)
					//
					DBSelectArea("VS3")
					while !eof() .and. xFilial("VS3") + VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
						if 	Alltrim(VS3->VS3_RESERV) == "1"
							lTemResS := .t.
						else
							lNTemRes := .t.
						endif
						DBSkip()
					enddo
					reclock("VS1",.f.)
					if nPosR > 0
						VS1->VS1_STARES := "1"
					elseif lTemResS .and. lNTemRes
						VS1->VS1_STARES := "2"
					elseif lTemResS .and. !lNTemRes
						VS1->VS1_STARES := "1"
					else
						VS1->VS1_STARES := "3"
					endif
					msunlock()
					(cAliasLD)->(DBSKip())
				enddo
				(cAliasLD)->(DBCloseArea())
			endif
			// -----------------------------------------------
			// Grava็ใo do STATUS DA RESERVA no VS1 (VS1_STARES)
			// -----------------------------------------------
		Else

			conout("FG_DEVLOJA - ENTRADA NA FUNCAO - EXECAUTO LOJA701:  "+Dtoc(dDataBase)+" - "+Time())

			If !Empty(cNota)
				//Atualiza Orcamento
				dbSelectArea("VS1")
				dbSetOrder(1)
				If dbSeek(xFilial("VS1")+Trim(cPesq))

					conout("FG_DEVLOJA - GRAVACAO DA NF/SERIE NA TABELA VS1 (UNICO) - EXECAUTO LOJA701:  "+Dtoc(dDataBase)+" - "+Time())

					RecLock("VS1",.F.)
					VS1->VS1_NUMNFI := cNota
					VS1->VS1_SERNFI := cSerie
					if FieldPos("VS1_SDOC") > 0
						VS1->VS1_SDOC := FGX_UFSNF(cSerie)
					EndIF
					if VS1->(FieldPos("VS1_STARES")) > 0 .and. !Empty(cNota)
						VS1->VS1_STARES := "3"
					endif
					MsUnlock()
					cAliasLD := GetNextAlias()
					cQuery := "SELECT R_E_C_N_O_ RECVS1 FROM "+RetSqlName("VS1")
					cQuery += " WHERE VS1_FILIAL ='"+VS1->VS1_FILIAL+"'"
					cQuery += " AND VS1_PESQLJ ='"+VS1->VS1_PESQLJ+"' AND D_E_L_E_T_ =  ' '"
					cQuery += " AND R_E_C_N_O_ <> "+ Alltrim(STR(VS1->(RecNo())))
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasLD, .F., .T. )
					//
					cSerLJG := VS1->VS1_SERNFI
					cNumLJG := VS1->VS1_NUMNFI

					conout("FG_DEVLOJA - GRAVACAO DA NF/SERIE NA TABELA VS1 (AGRUPADO) - EXECAUTO LOJA701:  "+Dtoc(dDataBase)+" - "+Time())

					while !((cAliasLD)->(eof()))
						DBSelectArea("VS1")
						DBGoTo((cAliasLD)->(RECVS1))
						reclock("VS1",.f.)
						VS1->VS1_NUMNFI = cNumLJG
						VS1->VS1_SERNFI = cSerLJG
						if FieldPos("VS1_SDOC") > 0
							VS1->VS1_SDOC := FGX_UFSNF(cSerLJG)
						Endif
						msunlock()
						(cAliasLD)->(DBSkip())
					enddo
					(cAliasLD)->(DBCloseArea())
				endif

				conout("FG_DEVLOJA - GRAVACAO DA AVALICAO DE PECAS (VEC) - EXECAUTO LOJA701:  "+Dtoc(dDataBase)+" - "+Time())

				// Gera Avaliacao de Venda de pecas
				FM_GVECVSC(cNota,cSerie,"VEC")
				//
				cPrefixo := GetNewPar("MV_PREFBAL","BAL")
				dbSelectArea("SF2")
				dbSetOrder(1)
				if dbSeek(xFilial("SF2")+cNota+cSerie)

					conout("FG_DEVLOJA - GRAVACAO DO PREFORI DA NOTA - EXECAUTO LOJA701:  "+Dtoc(dDataBase)+" - "+Time())

					RecLock("SF2",.f.)
					SF2->F2_PREFORI := cPrefixo
					MsUnlock()
				Endif
				dbSelectArea("SE1")
				dbSetOrder(2) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				dbSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+cNota)

				conout("FG_DEVLOJA - GRAVACAO DO PREFORI DO TITULO - EXECAUTO LOJA701:  "+Dtoc(dDataBase)+" - "+Time())

				While !SE1->(Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") ;
				.and. SE1->E1_CLIENTE == SF2->F2_CLIENTE ;
				.and. SE1->E1_LOJA == SF2->F2_LOJA ;
				.and. SE1->E1_PREFIXO == SF2->F2_PREFIXO ;
				.and. SE1->E1_NUM == cNota
					RecLock("SE1",.f.)
					SE1->E1_PREFORI := cPrefixo
					MsUnlock()
					SE1->(dbSkip())
				End
			EndIf
		EndIf
	ElseIf cTipo == "2" // Oficina
		If lCancel // Cancelar
			// Cancelado NF/CF e orcamento continua no loja com status de Aberto
			If !Empty(cNota)
				lRet := FMX_LJCAN( SL1->L1_NUM )
				// Cancelado Orcamento do Loja, Cancelar Fechamento de OS .
			Else
				lRet := OM150CANC(SL1->L1_NUM)
			Endif
		Else
			If !Empty(cNota)
				lRet := FMX_LJFAT( SL1->L1_NUM , cPesq, cNota , cSerie, SL1->L1_EMISNF)
				cPrefixo := GetNewPar("MV_PREFOFI","OFI")
				dbSelectArea("SF2")
				dbSetOrder(1)
				if dbSeek(xFilial("SF2")+cNota+cSerie)
					RecLock("SF2",.f.)
					SF2->F2_PREFORI := cPrefixo
					MsUnlock()
				Endif
				dbSelectArea("SE1")
				dbSetOrder(2) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				dbSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+cNota)
				While !SE1->(Eof()) .and. SE1->E1_FILIAL == xFilial("SE1") ;
				.and. SE1->E1_CLIENTE == SF2->F2_CLIENTE ;
				.and. SE1->E1_LOJA == SF2->F2_LOJA ;
				.and. SE1->E1_PREFIXO == SF2->F2_PREFIXO ;
				.and. SE1->E1_NUM == cNota
					RecLock("SE1",.f.)
					SE1->E1_PREFORI := cPrefixo
					MsUnlock()
					SE1->(dbSkip())
				End
			EndIf
		EndIf
	ElseIf cTipo == "3" // Veiculo

		If lCancel // Cancelar
			//
			conout("FG_DEVLOJA - CANCELAMENTO DO ORCAMENTO NO LOJA - VEICULOS - EXECAUTO LOJA701:  "+Dtoc(dDataBase)+" - "+Time())
			//
			If !Empty(cNota)
				
				lRet := .f.

			Else // Nใo possui NF

				cQuery := "SELECT R_E_C_N_O_ RECVV0 "
				cQuery += "  FROM " + RetSqlName("VV0")
				cQuery += " WHERE VV0_FILIAL = '" + xFilial("VV0") + "' "
				cQuery += "   AND VV0_PESQLJ = '" + SL1->L1_NUM + "' "
				cQuery += "   AND D_E_L_E_T_ = ' '"
				nRecVV0 := FM_SQL( cQuery )

				If nRecVV0 > 0

					DbSelectArea("VV0")
					DbGoTo( nRecVV0 )
					// Limpar o c๓digo referente ao loja (VV0_PESQLJ)
					RecLock("VV0",.f.)
						VV0->VV0_PESQLJ := ""
					MsUnLock()
					// Voltar o Atendimento para Pre-Aprovado (VV9_STATUS=“O”)
					DbSelectArea("VV9")
					DbSetOrder(1)
					If DbSeek( VV0->VV0_FILIAL + VV0->VV0_NUMTRA )
						RecLock("VV9",.f.)
							VV9->VV9_STATUS := "O" // Status Pre-Aprovado
						MsUnLock()
					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

	// Tratamento da CD6
	If cTipo $ "1/2" .and. !lCancel .and. !Empty(cNota) // So gera para 1-Balcao, 2-Oficina e criacao de nota (!lCancel) e variavel cNota preenchida
		If SB1->(FieldPos("B1_CODSIMP")) <> 0

			C0G->(DbSetOrder(7))

			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSelectArea("SD2")
			DbSetOrder(3)
			DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
			While SD2->D2_FILIAL == xFilial("SD2") .AND. SD2->D2_DOC == SF2->F2_DOC .AND. SD2->D2_SERIE==SF2->F2_SERIE .AND. SD2->D2_CLIENTE == SF2->F2_CLIENTE .AND. SD2->D2_LOJA == SF2->F2_LOJA

				If Alltrim(SD2->D2_GRUPO) $ cCombust


					DbSelectArea("SB1")
					DbSeek(xFilial("SB1")+SD2->D2_COD)

					C0G->(DbSeek(xFilial("C0G")+SB1->B1_CODSIMP))

					DbSelectArea("CD6")
					DbSeek(xFilial("CD6")+"S"+ SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM+SD2->D2_COD)
					
					RecLock("CD6",!Found())
					CD6_FILIAL := xFilial("CD6")
					CD6_TPMOV  := "S"
					CD6_DOC    := SD2->D2_DOC
					CD6_SERIE  := SD2->D2_SERIE
					if FieldPos('CD6_SDOC') > 0
						CD6->CD6_SDOC := SD2->D2_SDOC
					EndIf
					CD6_CLIFOR := SD2->D2_CLIENTE
					CD6_LOJA   := SD2->D2_LOJA
					CD6_ITEM   := SD2->D2_ITEM
					CD6_COD    := SD2->D2_COD
					CD6_UFCONS := SF2->F2_EST
					CD6_CODANP := SB1->B1_CODSIMP
					CD6_DESANP := C0G->C0G_DESCRI
					MsUnlock()
				Endif

				SD2->(DbSkip())

			Enddo

		Endif
	Endif
	//

	SF2->(DbGoTo(nRecSF2))
	SD2->(DbGoTo(nRecSD2))
	SE1->(DbGoTo(nRecSE1))
	SB1->(DbGoTo(nRecSB1))
	CD6->(DbGoTo(nRecCD6))

	If !Empty(cSlvAlias)
		DbSelectArea(cSlvAlias)
	Else
		DbSelectArea("SL1")
	EndIf

	conout("FG_DEVLOJA - SAIDA DA FUNCAO - EXECAUTO LOJA701:  "+Dtoc(dDataBase)+" - "+Time())

Return(lRet)

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFG_PREFIXO ณ Autor ณ Valdir F. Silva       ณ Data ณ 01.11.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณDevolve o prefixo conforme o modulo						   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณcCondicao  : Tipo de gravacao (Quem Gravou)		           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGestao de Concessionarias                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_PREFIXO(cCondicao)
	Local cRet := ""

	If cCondicao == "1"
		cRet := GetNewPar("MV_PREFBAL","BAL")
	ElseIf cCondicao == "2"
		cRet := GetNewPar("MV_PREFOFI","OFI")
	ElseIf cCondicao == "3"
		cRet := GetNewPar("MV_PREFVEI","VEI")
	EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_X3ORD  บAutor  ณRicardo Farinelli   บ Data ณ  01/18/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o Vetor para rotinas automaticas conforme a ordem do  บฑฑ
ฑฑบ          ณSX3                                                         บฑฑ
ฑฑบParametrosณcTipo  = se eh um vetor de itens ou um de cabecalho         บฑฑ
ฑฑบParametrosณnMantem= Opcional, indica ate que item devera ser fixo      บฑฑ
ฑฑบParametrosณaVetor = Vetor com os campos passados                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_X3ORD(cTipo,nMantem,aVetor)
	Local ii, aVetor2 := {}, nwnk,aVetor3 := {},aAlias := SGetArea(), aVetor4 := {}, aVetor5 := {}
	Default nMantem := 0
	DbselectArea("SX3")
	DbSetOrder(2)

	If cTipo=="I"
		For ii := 1 to Len(aVetor)
			aVetor4 := aClone(aVetor[ii])
			For nwnk := 1 To Len(aVetor4)
				If Dbseek(aVetor4[nwnk,1])
					aadd(aVetor2,{aVetor4[nwnk,1],aVetor4[nwnk,2],aVetor4[nwnk,3],SX3->X3_ORDEM})
				Endif
			Next
			Asort(aVetor2,,,{|x,y| x[4] < y[4]})
			For nwnk := 1 To nMantem
				Aadd(aVetor3,{aVetor4[nwnk,1],aVetor4[nwnk,2],aVetor4[nwnk,3]})
				nwnk2 := Ascan(aVetor2,{|x| x[1]==aVetor4[nwnk,1] })
				If nwnk2 > 0
					Adel(aVetor2,nwnk2)
					aSize(aVetor2,Len(aVetor2)-1)
				Endif
			Next

			For nwnk := 1 To Len(aVetor2)
				AAdd(aVetor3,{aVetor2[nwnk,1],aVetor2[nwnk,2],aVetor2[nwnk,3]})
			Next
			Aadd(aVetor5,aClone(aVetor3))
			aVetor2:={}
			aVetor3:={}
		Next
		aVetor := aClone(aVetor5)
	Elseif cTipo =="C"
		For nwnk := 1 To Len(aVetor)
			If Dbseek(aVetor[nwnk,1])
				aadd(aVetor2,{aVetor[nwnk,1],aVetor[nwnk,2],aVetor[nwnk,3],SX3->X3_ORDEM})
			Endif
		Next
		Asort(aVetor2,,,{|x,y| x[4] < y[4]})
		For nwnk := 1 To nMantem
			Aadd(aVetor3,{aVetor[nwnk,1],aVetor[nwnk,2],aVetor[nwnk,3]})
			nwnk2 := Ascan(aVetor2,{|x| x[1]==aVetor[nwnk,1] })
			If nwnk2 > 0
				Adel(aVetor2,nwnk2)
				aSize(aVetor2,Len(aVetor2)-1)
			Endif
		Next

		For nwnk := 1 To Len(aVetor2)
			AAdd(aVetor3,{aVetor2[nwnk,1],aVetor2[nwnk,2],aVetor2[nwnk,3]})
		Next
		aVetor := aClone(aVetor3)
	Endif
	SRestArea(aAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFG_GRVCAMP ณ Autor ณ Valdir F. Silva       ณ Data ณ 26.03.02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Grava campanha do veiculo						           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGestao de Concessionarias                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_GRVCAMP()
	Local aArea := GetArea()

	DbSelectArea("VV1")
	DbSetOrder(2)

	DbSelectArea("VOU")
	DbSetOrder(1)

	DbSelectArea("VOP")
	DbSetOrder(2)
	DbSeek(xFilial("VOP")+"1")

	While !VOP->(Eof()) .and. VOP->VOP_FILIAL == xFilial("VOP") .and. VOP->VOP_TIPPEN == "1"
		If M->VO1_CHASSI >= VOP->VOP_CHAINI .and. M->VO1_CHASSI <= VOP->VOP_CHAFIN .and. !Empty(M->VO1_CHASSI) .and. ;
		dDataBase <= VOP->VOP_DATVEN .and. !VOU->(DbSeek(xFilial("VOU")+VOP->VOP_NUMINT+M->VO1_CHASSI))

			Reclock("VOU",.T.)
			VOU->VOU_FILIAL := xFilial("VOU")
			VOU->VOU_NUMINT := VOP->VOP_NUMINT
			VOU->VOU_CHASSI := M->VO1_CHASSI
			VOU->(MsRUnLock())

		Else
			If VV1->(dbSeek(xFilial("VV1")+cChassi))

				if VV1->VV1_CHARED >= VOP->VOP_CHAINI .and. VV1->VV1_CHARED <= VOP->VOP_CHAFIN .and. !Empty(M->VO1_CHASSI) .and. ;
				dDataBase <= VOP->VOP_DATVEN .and. !VOU->(DbSeek(xFilial("VOU")+VOP->VOP_NUMINT+ VV1->VV1_CHARED ))  // maza usa chared no VOU
					Reclock("VOU",.T.)
					VOU->VOU_FILIAL := xFilial("VOU")
					VOU->VOU_NUMINT := VOP->VOP_NUMINT
					VOU->VOU_CHASSI := VV1->VV1_CHARED
					VOU->(MsRUnLock())
				EndIf

			EndIf
		EndIf
		DbSkip()
	EndDo
	VOP->(DbSetOrder(1))
	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_PULACPOบAutor  ณFabio               บ Data ณ  12/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTrata campos visuais da getdados para nao posicionamento no บฑฑ
ฑฑบ			 ณ	mesmo 												      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_PULACPO(oGetObj,aHeaderCpo)

	Local nPulaCpo:=0
	Default aHeaderCpo:=aHeader

	For nPulaCpo:=oGetObj:oBrowse:nColPos to Len(aHeader)

		If Posicione("SX3",2,aHeaderCpo[nPulaCpo,2],"X3_VISUAL") # "V"
			oGetObj:oBrowse:nColPos := nPulaCpo
			Exit
		EndIf

	Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_SEMAFORบAutor  ณFabio               บ Data ณ  03/28/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLoca arquivo para uso mono                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_SEMAFORO( cIdentificador , cOperacao )

	Local lRetLock:=.t. , cTextoHelp:=""

	Default cIdentificador := ""
	Default cOperacao      := "T"

	DbSelectArea("VH9")
	DbSetOrder(1)
	If !DbSeek( xFilial("VH9") + cIdentificador )
		RecLock("VH9",.t.)
		VH9->VH9_FILIAL := xFilial("VH9")
		VH9->VH9_PREFIX := cIdentificador
		MsUnLock()
	EndIf

	If Upper( cOperacao ) == "T"

		Do While !( lRetLock := MsRLock(Recno()) )

			cTextoHelp := ""
			cTextoHelp += STR0203 + chr(13) + chr(13)
			cTextoHelp += STR0204+ Repl(".",11) + ":  " + VH9->VH9_USUARI + chr(13)
			cTextoHelp += STR0205       + Repl(".",15) + ":  " + Dtoc(VH9->VH9_DATOPE) + chr(13)
			cTextoHelp += STR0206       + Repl(".",15) + ":  " + Transform(VH9->VH9_HOROPE,"@R 99:99:99") + chr(13)
			cTextoHelp += STR0207+ Repl(".",01) + ":  " + Transform( FG_CALCTIME( Val( Substr(Time(),1,2) + Substr(Time(),4,2) + Substr(Time(),7,2) ) - VH9->VH9_HOROPE ) , "@R 99:99:99") + chr(13)
			cTextoHelp += STR0208      + Repl(".",12) + ":  " + VH9->VH9_ROTINA + chr(13)

			If !MsgYesNoTimer(cTextoHelp,(STR0209))
				Exit
			EndIf

		EndDo

		If lRetLock

			VH9->VH9_DATOPE := dDataBase
			VH9->VH9_HOROPE := Val( Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2) )
			VH9->VH9_USUARI := Substr( cUsuario ,7,15)
			VH9->VH9_ROTINA := ProcName(1)
			MsRUnlock(RecNo())

			MsRLock(Recno())

		EndIf

	ElseIf Substr( cUsuario ,7,15) == VH9->VH9_USUARI

		VH9->VH9_DATOPE := Ctod("  /  /  ")
		VH9->VH9_HOROPE := 0
		VH9->VH9_USUARI := ""
		VH9->VH9_ROTINA := ""
		MsRUnlock(RecNo())

	EndIf

Return( lRetLock )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_CALCTIMบAutor  ณFabio               บ Data ณ  04/23/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjusta o tempo calculado                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_CALCTIME(nHora)

	Local nHr := 0 , nMin := 0 , nSeg := 0 , nHoraRet := 0

	nHr  := Val(Substr(Str(nHora,6),1,2))
	nMin := Round( Val(Substr(Str(nHora,6),3,2)) / 0.6 , 0 )
	nSeg := Round( Val(Substr(Str(nHora,6),5,2)) / 0.6 , 0 )

	nMin += Val( Substr( StrZero(nSeg,3) ,1,1) )
	nSeg := Round( Val( Substr( StrZero(nSeg,3) ,2,2) ) * 0.6 , 0 )

	nHr  += Val( Substr( StrZero(nMin,3) ,1,1) )
	nMin := Round( Val( Substr( StrZero(nMin,3) ,2,2) ) * 0.6 , 0 )

	nHoraRet := Val( StrZero(nHr,2) + StrZero(nMin,2) + StrZero(nSeg,2) )

Return(nHoraRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_ROTAUTOบAutor  ณFabio               บ Data ณ  05/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de validacao e gravacao automatica                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_ROTAUTO(aRotAuto,nOpc,cTudOk)

	Local lRetAuto := .f. , aArqUtilit:={} , aValidGet:={} , nVal:=0 , nVal1:=0 , cAliasAuto:=""
	Local aArea:={} , nPosReg:=0

	Default aRotAuto := {}
	Default nOpc      := 3
	Default cTudOk    := "AllwaysTrue()"

	aArea := sGetArea(aArea,"SX3")
	If !Empty(Alias())
		aArea := sGetArea(aArea,Alias())
	EndIf

	For nVal:=1 to Len(aRotAuto)

		aValidGet :={}
		aArqUtilit:={}
		For nVal1:=1 to Len( aRotAuto[ nVal ] )

			DbSelectArea("SX3")
			DbSetOrder(2)
			DbSeek( aRotAuto[ nVal , nVal1 , 1 ] )

			cAliasAuto := SX3->X3_ARQUIVO

			If Len(aArqUtilit) == 0 .Or. Ascan( aArqUtilit , cAliasAuto ) == 0

				DbSelectArea("SX3")
				DbSetOrder(1)
				DbSeek(cAliasAuto)
				While !Eof().And.( x3_arquivo == cAliasAuto )

					M->&(SX3->X3_CAMPO)	 := CriaVar(SX3->X3_CAMPO)

					If X3USO(x3_usado).And.cNivel>=x3_nivel

						Aadd(aValidGet,{ SX3->X3_CAMPO , M->&(SX3->X3_CAMPO) , SX3->X3_VALID , .t. })

					Endif

					DbSelectArea("SX3")
					dbSkip()

				EndDo

				Aadd( aArqUtilit , cAliasAuto )

			EndIf

		Next

		For nVal1:=1 to Len(aValidGet)

			DbSelectArea( Posicione("SX3",2,aValidGet[nVal1,1],"X3_ARQUIVO") )

			If nOpc # 3 .And. FieldPos( aValidGet[nVal1,1] ) # 0

				aValidGet[nVal1,2] := FieldGet( FieldPos( aValidGet[nVal1,1] ) )

			Else

				aValidGet[nVal1,2] := CriaVar( aValidGet[nVal1,1] )

			EndIf

			If ( nPosReg := Ascan( aRotAuto[nVal] , {|x| x[1] == aValidGet[nVal1,1] }) ) # 0

				aValidGet[nVal1,2] := aRotAuto[ nVal , nPosReg , 2 ]

				If aRotAuto[ nVal , nPosReg , 3 ] # NIL .And. !Empty( aRotAuto[ nVal , nPosReg , 3 ] )

					If !Empty( aValidGet[nVal1,3] )
						aValidGet[nVal1,3] := Alltrim( aValidGet[nVal1,3] ) + ".And."
					EndIf

					aValidGet[nVal1,3] := Alltrim( aValidGet[nVal1,3] ) + aRotAuto[ nVal , nPosReg , 3 ]

				EndIf

			EndIf

			M->&(aValidGet[nVal1,1]) := aValidGet[nVal1,2]

		Next

		If MsVldGAuto(aValidGet)

			For nVal1:=1 to Len(aArqUtilit)

				DbSelectArea( aArqUtilit[nVal1] )

				If !( lRetAuto := ( AxIncluiAuto( Alias() , cTudOk ,, nOpc , RecNo() ) <= 1 ) )

					Exit

				EndIf

			Next

		Else

			lRetAuto := .f.

		EndIf

		If !lRetAuto
			Exit
		EndIf

	Next

	&& Volta posicoes originais
	sRestArea(aArea)

Return( lRetAuto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_AXPESQUบAutor  ณFabio               บ Data ณ  06/17/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPesquisa nos arquivo                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณVetor aPesquisa com os conteudos.                           บฑฑ
ฑฑบ          ณAlias = Alias do arquivo de pesquisa                        บฑฑ
ฑฑบ          ณOrdem = Ordem que relaciona o arquivo ( Arq. mBrowse )      บฑฑ
ฑฑบ          ณChave = Chave com os campo que posiciona no Arq. ( Arq.Brow)บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_AXPESQUISA()

	Local lRet := .f. , aOrd := {} , aOrdCombo := {}, nPesq:=0 , cOrd := "" , cCampo := Space(40) ,;
	cAliasPesq := Alias() , nOrdPesq := IndexOrd()
	Local aArqOld := {}
	Local indexCount := 0

	aArqOld := {{ Alias() , 0 , "" }}
	If Type( "aPesquisa" ) # "U"
		For nPesq:=1 To Len(aPesquisa)
			Aadd( aArqOld , aPesquisa[nPesq] )
		Next
	EndIf

	For nPesq:=1 To Len(aArqOld)

		DbSelectArea("SIX")
		DbSetOrder(1)
		DbSeek( aArqOld[nPesq,1] )

		indexCount := 0
		Do While !Eof() .And. SIX->INDICE == aArqOld[nPesq,1]

			indexCount++

			Aadd( aOrdCombo , SIX->DESCRICAO )
			Aadd( aOrd    , { aArqOld[nPesq,1] , indexCount , SIX->CHAVE , SIX->DESCRICAO , aArqOld[nPesq,2] , aArqOld[nPesq,3] } )

			If cAliasPesq == aArqOld[nPesq,1] .And. nOrdPesq == Val(SIX->ORDEM)
				cOrd := SIX->DESCRICAO
			EndIf

			DbSelectArea("SIX")
			DbSkip()

		EndDo

	Next

	If Len( aOrdCombo ) # 0

		DEFINE MSDIALOG oDlgPesq TITLE (STR0210) FROM 00,00 TO 100,490 of oMainWnd PIXEL  //"Pesquisa"

		@ 05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrdCombo SIZE 206,36 PIXEL OF oDlgPesq FONT oDlgPesq:oFont

		@ 22,05 MSGET oObjCbave VAR cCampo SIZE 206,10 PIXEL of oDlgPesq

		DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlgPesq ENABLE ACTION (lRet := .T.,oDlgPesq:End())
		DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlgPesq ENABLE ACTION oDlgPesq:End()

		ACTIVATE MSDIALOG oDlgPesq CENTER

		If lRet

			lRet := .f.

			If ( nPesq := Ascan( aOrdCombo , cOrd ) ) # 0

				DbSelectArea(aOrd[nPesq,1])
				DbSetOrder(aOrd[nPesq,2])

				lRet := DbSeek( xFilial(aOrd[nPesq,1]) + cCampo , .t. )

				If !Empty(aOrd[nPesq,5])

					DbSelectArea(cAliasPesq)
					DbSetOrder(aOrd[nPesq,5])

					lRet := DbSeek( xFilial(cAliasPesq) + &(aOrd[nPesq,6]) , .t. )

				EndIf

			EndIf

		EndIf

	EndIf

Return(lRet)

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ FG_OICFORD ณ Autor ณ Andre Luis Almeida    ณ Data ณ 30/10/02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Importa Requisicao de peca Fabrica FORD                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_OICFORD()

	Local ni, x := 0
	Local cDiretTxt := Alltrim(VE4->VE4_DIRFAB)
	Local cDiretorio:= Alltrim( Substr( VE4->VE4_DIRFAB , 1 , Rat(ALLTRIM(" \ "),VE4->VE4_DIRFAB) ) )
	Local cStringTxt := "" , cArquivo := ""

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta Vetor com os Arquivos do Diretorio                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	aArqTxt := {}
	aArqTxt := Directory(cDiretTxt,"D")

	If len(aArqTxt) == 0
		MsgStop((STR0137))  // Nao foi possivel abrir o arquivo texto. Operacao cancelada !
		Return
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Abre Arquivo binario e faz leitura                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//cString := space(200)
	aPecas := {}

	For x:=1 to Len(aArqTxt)

		cArquivo := Alltrim( cDiretorio ) + Alltrim( aArqTxt[x,1] )

		If !File(cArquivo)
			Loop
		EndIf

		FT_FUSE( cArquivo )
		FT_FGOTOP()

		ni   := 0
		nPos := 0
		cCod := ""
		cDes := ""
		cQtd := ""

		While !FT_FEOF()

			cStringTxt := FT_FREADLN()

			nPos := At(CHR(9),cStringTxt)
			cCod := Substr(cStringTxt,1,nPos-1)

			cStringTxt := Substr(cStringTxt,nPos+1)

			For ni:=1 to nPos-1
				If Substr(cCod,ni,1) $ " /"
					cCod := Substr(cCod,1,ni-1)+Substr(cCod,ni+1)
					ni--
				EndIf
			Next

			nPos := At(CHR(9),cStringTxt)
			cDes := Substr(cStringTxt,1,nPos-1)

			cStringTxt := Substr(cStringTxt,nPos+1)

			nPos := At(CHR(9),cStringTxt)
			cQtd := Substr(cStringTxt,1,nPos-1)

			Aadd(aPecas,{aArqTxt[x,1],Alltrim(cCod),Alltrim(cDes),Alltrim(cQtd)})

			FT_FSKIP()

		End

	Next

	FT_FUSE()

Return(aPecas)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ FG_CMONTH  ณ Autor ณ Andre Luis Almeida    ณ Data ณ 26/12/02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Retorna String com a Descricao do MES                        ณฑฑ
ฑฑณParametrosณ dData  = Data a retornar a descricao do MES                  ณฑฑ
ฑฑณ          ณ nMes   = Nro do Mes a retornar a descricao do MES            ณฑฑ
ฑฑณ          ณ lAbrev = Descricao abreviada (3 primeiros caracteres) ?      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_CMONTH(dData,nMes,lAbrev)
	Default dData  := ctod("")
	Default nMes   := 0
	Default lAbrev := .f.
	If nMes == 0 .and. !Empty(dData)
		nMes := month(dData)
	EndIf
	Do Case
		Case nMes == 1
		Return IIf(lAbrev,left(STR0152,3),STR0152) //  Janeiro
		Case nMes == 2
		Return IIf(lAbrev,left(STR0153,3),STR0153) //  Fevereiro
		Case nMes == 3
		Return IIf(lAbrev,left(STR0154,3),STR0154) //  Marco
		Case nMes == 4
		Return IIf(lAbrev,left(STR0155,3),STR0155) //  Abril
		Case nMes == 5
		Return IIf(lAbrev,left(STR0156,3),STR0156) //  Maio
		Case nMes == 6
		Return IIf(lAbrev,left(STR0157,3),STR0157) //  Junho
		Case nMes == 7
		Return IIf(lAbrev,left(STR0158,3),STR0158) //  Julho
		Case nMes == 8
		Return IIf(lAbrev,left(STR0159,3),STR0159) //  Agosto
		Case nMes == 9
		Return IIf(lAbrev,left(STR0160,3),STR0160) //  Setembro
		Case nMes == 10
		Return IIf(lAbrev,left(STR0161,3),STR0161) //  Outubro
		Case nMes == 11
		Return IIf(lAbrev,left(STR0162,3),STR0162) //  Novembro
		Case nMes == 12
		Return IIf(lAbrev,left(STR0163,3),STR0163) //  Dezembro
	EndCase
Return( "" )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFG_CDATAS ณ Autor ณ  Andre Luis Almeida   ณ Data ณ 13/08/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Calcula Datas: dias a mais e a menos                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_CDATAS
	Private dDtInic := dDataBase
	Private dDtFin1 := dDataBase
	Private dDtFin2 := dDataBase
	Private cDtInic := cDtFin11 := cDtFin22 := FS_DIASEMANA(dDataBase)
	Private cDtFin1 := cDtFin2  := Transform(dDataBase,"@D")
	Private nDias   := 0
	DEFINE FONT oFnt NAME "Arial" SIZE 08,15 BOLD
	DEFINE MSDIALOG oDatas FROM 000,000 TO 008,050 TITLE STR0165 OF oMainWnd
	@ 009,006 SAY STR0166 SIZE 120,08 OF oDatas PIXEL COLOR CLR_BLUE
	@ 007,055 MSGET oDtInic VAR dDtInic PICTURE "@D" VALID FS_M_CDATAS(1) SIZE 40,08 OF oDatas PIXEL COLOR CLR_BLUE
	@ 009,095 SAY cDtInic SIZE 100,08 OF oDatas PIXEL COLOR CLR_BLUE
	@ 022,006 SAY STR0167 SIZE 120,08 OF oDatas PIXEL COLOR CLR_BLUE
	@ 020,055 MSGET oDias VAR nDias PICTURE "999999" VALID FS_M_CDATAS(2) SIZE 20,08 OF oDatas PIXEL COLOR CLR_BLUE
	@ 022,083 SAY STR0168 SIZE 40,08 OF oDatas PIXEL COLOR CLR_BLUE
	@ 035,006 SAY STR0169 SIZE 120,08 OF oDatas PIXEL COLOR CLR_BLUE
	@ 035,055 SAY cDtFin1  SIZE 100,08 OF oDatas PIXEL FONT oFnt COLOR CLR_RED
	@ 035,095 SAY cDtFin11 SIZE 100,08 OF oDatas PIXEL COLOR CLR_BLUE
	@ 048,006 SAY STR0170 SIZE 120,08 OF oDatas PIXEL COLOR CLR_BLUE
	@ 048,055 SAY cDtFin2  SIZE 100,08 OF oDatas PIXEL FONT oFnt COLOR CLR_RED
	@ 048,095 SAY cDtFin22 SIZE 100,08 OF oDatas PIXEL COLOR CLR_BLUE
	@ 018,138 BUTTON oCalc PROMPT (STR0171) OF oDatas SIZE 53,11 PIXEL  ACTION (FS_M_CDATAS(2),oDias:SetFocus())
	@ 038,138 BUTTON oSair PROMPT (STR0172) OF oDatas SIZE 53,11 PIXEL  ACTION (oDatas:End())
	@ 002,003 TO 059,196 LABEL "" OF oDatas PIXEL
	ACTIVATE MSDIALOG oDatas CENTER
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFS_M_CDATASณ Autor ณ  Andre Luis Almeida   ณ Data ณ 13/08/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Calcula Datas: dias a mais e a menos                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_M_CDATAS(ni)
	If ni == 1
		nDias := dDtInic - dDataBase
	EndIf
	cDtInic := FS_DIASEMANA(dDtInic)
	dDtFin1 := dDtInic + nDias
	cDtFin1 := Transform(dDtFin1,"@D")
	cDtFin11:= FS_DIASEMANA(dDtFin1)
	dDtFin2 := dDtInic - nDias
	cDtFin2 := Transform(dDtFin2,"@D")
	cDtFin22:= FS_DIASEMANA(dDtFin2)
	oDatas:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFS_DIASEMANAณ Autor ณ  Andre Luis Almeida   ณ Data ณ 13/08/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Dia da semana					                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DIASEMANA(dDt)
	Local cRet := ""
	Do Case
		Case Dow(dDt) == 1
		cRet := STR0173
		Case Dow(dDt) == 2
		cRet := STR0174
		Case Dow(dDt) == 3
		cRet := STR0175
		Case Dow(dDt) == 4
		cRet := STR0176
		Case Dow(dDt) == 5
		cRet := STR0177
		Case Dow(dDt) == 6
		cRet := STR0178
		Case Dow(dDt) == 7
		cRet := STR0179
	EndCase
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    | FG_CKCLINI ณ Autor ณ Andre Luis Almeida  ณ Data ณ 19/10/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Checa/Mostra Nivel de Importacia do Cliente para o usuario ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Geral                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_CKCLINI(cCliLoj,lRetorno,lSemMos)
	Local aArea     := {}
	Local lAtual    := .f.
	Local OXFig
	Local lMostra   := .f.
	Local cHrMin    := left(time(),5)
	Local cPRW      := FunName()
	Local aTit      := {{.f.,"","","","",CtoD(""),CtoD(""),0,0}}
	Local aNCC      := {{"","","","",CtoD(""),CtoD(""),0,0}}
	Local aPos      := {}
	Local nValor    := 0
	Local nDif      := 0
	Local nValVenc  := 0
	Local nx        := 0
	
	Local aTotaliz   := {}

	Local cQuery    := ""
	Local cAliasSE1 := "SQLSE1"
	Local aFilAtu   := FWArrFilAtu()
	Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
	Local cBkpFilAnt:= cFilAnt
	Local nCont     := 0
	Local lCredCli  := GetMV("MV_CREDCLI") == "L" //Credito por Loja
	Local nA1LC     := 0
	Local nValCre   := 0
	Local nSalCre   := 0

	Local oVerde    := LoadBitmap( GetResources(), "BR_VERDE" )
	Local oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO" )
	

	DEFAULT lSemMos  := .f. // Mostra sempre, independente do Parametro MV_CKCLINR
	DEFAULT lRetorno := .t.
	DEFAULT aSelFil	 := {} // Vetor carregado do MATA - Altera็ใo FAIXA 3

	DEFINE FONT oFCliNIR NAME "Arial" SIZE 08,15 BOLD
	dbSelectArea("SX6")
	dbSetOrder(1)
	lMostra := Getmv("MV_CKCLIXX",.T.)
	
	If lMostra
		// Salva posicoes originais dos Arquivos
		aArea := sGetArea(aArea,"VCF")
		aArea := sGetArea(aArea,"VCB")
		aArea := sGetArea(aArea,"SA1")
		aArea := sGetArea(aArea,"VAI")
		If !Empty(Alias())
			aArea := sGetArea(aArea,Alias())
		EndIf

		cQryCli := " SELECT SA1.A1_COD "
		
		If lCredCli // Credito por loja
			cQryCli += ", SA1.A1_LOJA "
		EndIf

		cQryCli += ", SUM(SA1.A1_LC) AS A1_LC"
		cQryCli += " FROM " + RetSqlName("SA1") + " SA1 "
		cQryCli += " WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQryCli +=	 " AND SA1.A1_COD = '"    + Left(cCliLoj,TamSX3("A1_COD")[1]) + "' "
		
		If lCredCli // Credito por loja
			cQryCli += " AND SA1.A1_LOJA = '" + Right(cCliLoj,TamSX3("A1_LOJA")[1]) + "' "
		EndIf

		cQryCli +=	 " AND SA1.D_E_L_E_T_ = ' ' "
		cQryCli +=	 " GROUP BY SA1.A1_COD "
		
		If lCredCli // Credito por loja
			cQryCli += ", SA1.A1_LOJA"
		EndIf

		TcQuery cQryCli New Alias "TMPA1"
		
		nA1LC := TMPA1->A1_LC

		TMPA1->(DbCloseArea())


		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1") + cCliLoj )
		//
		lMosTelaPE := .f.
		//
		If ( ExistBlock("VFATECLI") )
			lMosTelaPE := ExecBlock("VFATECLI",.f.,.f.,{lMosTelaPE})
		EndIf
		If Alltrim(GetMV("MV_CKCLIXX")) # Alltrim( cPRW +" "+ cHrMin +" "+ __CUSERID +" "+ cCliLoj )
			DbSelectArea("VCF")
			DbSetOrder(1)
			If DbSeek( xFilial("VCF") + cCliLoj ) // Posiciona nos dados do Cliente
				If VCF->VCF_NIVIMP $ GetNewPar("MV_CKCLINI","AA") // Verifica o nivel do Cliente se esta no Parametro
					lAtual := .t.
					DbSelectArea("VCB")
					DbSetOrder(1)
					DbSeek(xFilial("VCB") + VCF->VCF_AREVEN )
					DbSelectArea("VAI")
					DbSetOrder(4)
					DbSeek( xFilial("VAI") + __CUSERID )
					DEFINE MSDIALOG oCliNI FROM 000,000 TO 011,055 TITLE (STR0180+VCF->VCF_NIVIMP) OF oMainWnd
					@ 016,015 SAY VAI->VAI_NOMUSU SIZE 180,08 OF oCliNI PIXEL COLOR CLR_RED FONT oFCliNIR
					DEFINE SBUTTON FROM 013,333 TYPE 15 ENABLE OF oCliNI // Botao VISUALIZAR
					DEFINE SBUTTON FROM 013,175 TYPE 1 ACTION (oCliNI:End()) ENABLE OF oCliNI // Botao OK
					@ 033,015 SAY (STR0181+"( "+VCF->VCF_NIVIMP+" )") SIZE 180,08 OF oCliNI PIXEL COLOR CLR_BLUE FONT oFCliNIR
					If !Empty(VCF->VCF_AREVEN)
						@ 045,015 SAY (STR0182+VCF->VCF_AREVEN+" - "+VCB->VCB_DESREG) SIZE 180,08 OF oCliNI PIXEL COLOR CLR_BLUE FONT oFCliNIR
					EndIf
					@ 060,015 SAY SA1->A1_NOME SIZE 180,08 OF oCliNI PIXEL COLOR CLR_HBLUE FONT oFCliNIR
					@ 005,007 TO 077,211 LABEL "" OF oCliNI PIXEL // Caixa Sair
					ACTIVATE MSDIALOG oCliNI CENTER
				EndIf
			EndIf

			If lSemMos .or. SA1->A1_RISCO $ GetNewPar("MV_CKCLINR","E") .or. lMosTelaPE // Verifica o risco do Cliente se esta no Parametro

				nQtd      := 0
				nValor    := 0
				nValCre   := 0
				nValVenc  := 0

				If xFilial("SE1") <> xFilial("SD2") .or.; // quando os tํtulos sใo compartilhados OU
				 ( xFilial("SA1") == xFilial("SD2") .and. xFilial("SE1") == xFilial("SD2") ) // quando o Cadastro de Cliente e Titulos sใo Exclusivos
				 // ้ feita a leitura apenas UMA vez do SE1 da FILIAL LOGADA
					aSM0 := {}
					aadd(aSM0,cFilAnt) 
				Endif

				If VALTYPE(aSelFil) == "A" .And. Len(aSelFil) > 0 
					For nx:=1 to Len(aSelFil)
						If Ascan(aSM0,{|x|x == aSelFil[nx]}) == 0
							Aadd(aSM0,aSelFil[nx]) 
						Endif
					Next nx
				Endif 

				For nCont := 1 to Len(aSM0)
					cFilAnt := aSM0[nCont]
					
					cQuery := " SELECT SE1.E1_FILIAL , "
					cQuery +=       " SE1.E1_TIPO , "
					cQuery +=       " SE1.E1_NUM , "
					cQuery +=       " SE1.E1_PARCELA , "
					cQuery +=       " SE1.E1_EMISSAO , "
					cQuery +=       " SE1.E1_VENCREA , "
					cQuery +=       " SE1.E1_VALOR, "
					cQuery +=       " SE1.E1_SALDO "
					cQuery += " FROM " + RetSqlName( "SE1" ) + " SE1 "
					cQuery += " WHERE SE1.E1_FILIAL = '"  + xFilial("SE1") + "' AND "
					cQuery +=       " SE1.E1_CLIENTE = '" + SA1->A1_COD    + "' AND "
					
					If lCredCli // Credito por loja
						cQuery +=       " SE1.E1_LOJA = '"    + SA1->A1_LOJA   + "' AND "
					EndIf
					
					cQuery +=       " SE1.E1_SALDO <> 0 AND "
					cQuery +=       " SE1.D_E_L_E_T_=' ' "
					cQuery += " ORDER BY SE1.E1_FILIAL , SE1.E1_VENCREA , SE1.E1_NUM , SE1.E1_PARCELA "

					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSE1, .T., .T. )
					Do While !( cAliasSE1 )->( Eof() )
						If ( cAliasSE1 )->E1_TIPO $ 'NCC.RA '
							if len(aNCC) == 1 .and. Empty(aNCC[1,2])
								aNCC := {}
							Endif
							aadd(aNCC,{( cAliasSE1 )->E1_FILIAL,( cAliasSE1 )->E1_TIPO,( cAliasSE1 )->E1_NUM,( cAliasSE1 )->E1_PARCELA,stod(( cAliasSE1 )->E1_EMISSAO),stod(( cAliasSE1 )->E1_VENCREA),( cAliasSE1 )->E1_VALOR,( cAliasSE1 )->E1_SALDO})
							nValCre += ( cAliasSE1 )->E1_SALDO
						Else
							if len(aTit) == 1 .and. Empty(aTit[1,3])
								aTit := {}
							Endif
							aadd(aTit,{ IIF(stod(( cAliasSE1 )->E1_VENCREA) < dDataBase,.t.,.f.), ( cAliasSE1 )->E1_FILIAL,( cAliasSE1 )->E1_TIPO,( cAliasSE1 )->E1_NUM,( cAliasSE1 )->E1_PARCELA,stod(( cAliasSE1 )->E1_EMISSAO),stod(( cAliasSE1 )->E1_VENCREA),( cAliasSE1 )->E1_VALOR,( cAliasSE1 )->E1_SALDO})
							nQtd++
							nValor += ( cAliasSE1 )->E1_SALDO
							If stod(( cAliasSE1 )->E1_VENCREA) < dDataBase
								nValVenc += ( cAliasSE1 )->E1_SALDO
							Endif
						EndIf
						dbSelectArea(cAliasSE1)
						( cAliasSE1 )->(dbSkip())
					Enddo
					( cAliasSE1 )->(dbCloseArea())
					dbSelectArea("SE1")

				Next
				cFilAnt := cBkpFilAnt
				lAtual := .t.
				//
				If GetNewPar("MV_MIL0074","0") $ "0/N" // NAO mostra Titulos de Credito do Cliente (default)
					aAdd(aPos,{110,003,345,119})
					aAdd(aPos,{000,000,000,000})
				Else // Mostra Titulos de Credito do Cliente
					aAdd(aPos,{110,003,345,054})
					aAdd(aPos,{176,003,345,054})
				EndIf
				//
				DEFINE MSDIALOG oCliNR FROM 000,000 TO 031,088 TITLE (STR0259+SA1->A1_RISCO) OF oMainWnd
				@ 015,014 BITMAP OXFig RESOURCE "SVM" OF oCliNR PIXEL ADJUST NOBORDER SIZE 40,40
				@ 020,060 SAY (STR0260+SA1->A1_RISCO+STR0261) SIZE 140,08 OF oCliNR PIXEL COLOR CLR_HRED FONT oFCliNIR
				@ 040,060 SAY SA1->A1_NOME SIZE 140,08 OF oCliNR PIXEL COLOR CLR_HBLUE FONT oFCliNIR
				@ 061,015 SAY STR0262+Dtoc(SA1->A1_VENCLC) SIZE 140,08 OF oCliNR PIXEL COLOR CLR_BLUE FONT oFCliNIR
				@ 005,005 TO 077,200 LABEL "" OF oCliNR PIXEL // Caixa Sair
				DEFINE SBUTTON FROM 059,166 TYPE 1 ACTION oCliNR:End() ENABLE OF oCliNR // Botao OK
				//
				nDif := ( nA1LC - nValor )
				aAdd(aTotaliz,{ Alltrim(STR0270) , nA1LC  })
				aAdd(aTotaliz,{ Alltrim(STR0272) , nValor })
				aAdd(aTotaliz,{ Alltrim(STR0271) , nDif   })
				If FM_PILHA("OXA016M") // OFIXA016 - Liberacao de Credito Orcamento
					aAdd(aTotaliz,{ Alltrim(STR0273) , VS1->VS1_VTOTNF })
				EndIf
				If aPos[2,1] > 0
					nSalCre := nDif+nValCre
					aAdd(aTotaliz,{ STR0307 , nValCre })
					aAdd(aTotaliz,{ STR0308 , nSalCre })
				Endif
				aAdd(aTotaliz,{ STR0309 , nValVenc })
				aAdd(aTotaliz,{ STR0312 , FG_AVALCRED( SA1->A1_COD , SA1->A1_LOJA , .t. ) }) // Andamento (OS+Orc)

				@ 081,005 BUTTON oVAndamento PROMPT STR0311 OF oCliNR SIZE 195,10 PIXEL ACTION OFIC160(SA1->A1_COD,SA1->A1_LOJA) // Visualiza Or็amentos e Ordens de Servi็os em Andamento

				oLbTotal := TWBrowse():New(005,205,143,100,,,,oCliNR,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
				oLbTotal:nAT := 1
				oLbTotal:SetArray(aTotaliz)
				oLbTotal:AddColumn( TCColumn():New( STR0257 , { || aTotaliz[oLbTotal:nAt,1] }                               ,,,,"LEFT" ,65,.F.,.F.,,,,.F.,) ) // Descricao
				oLbTotal:AddColumn( TCColumn():New( STR0269 , { || Transform(aTotaliz[oLbTotal:nAt,2],"@E 999,999,999.99") },,,,"RIGHT",65,.F.,.F.,,,,.F.,) ) // Valor
				//
				@ aPos[1,1]-8,aPos[1,2] SAY Alltrim(STR0263) SIZE 140,08 OF oCliNR PIXEL COLOR CLR_HBLUE FONT oFCliNIR
				@ aPos[1,1]-8,110 BITMAP oVerm RESOURCE "BR_VERMELHO" OF oCliNR NOBORDER SIZE 10,10 when .f. PIXEL
				@ aPos[1,1]-8,120 SAY STR0309 SIZE 80,08 OF oCliNR PIXEL COLOR CLR_BLUE //"Vencidos"
				@ aPos[1,1]-8,160 BITMAP oVerd RESOURCE "BR_VERDE" OF oCliNR NOBORDER SIZE 10,10 when .f. PIXEL
				@ aPos[1,1]-8,170 SAY STR0310 SIZE 80,08 OF oCliNR PIXEL COLOR CLR_BLUE //"a Vencer"
				@ aPos[1,1]-0,aPos[1,2] LISTBOX oLbx1 FIELDS HEADER "",STR0264,STR0306,STR0265,STR0266,STR0267,STR0268,STR0269,Alltrim(STR0271) COLSIZES 10,40,30,40,40,40,40,50,50 SIZE aPos[1,3],aPos[1,4] OF oCliNR PIXEL
				oLbx1:SetArray(aTit)
				oLbx1:bLine := { || { IIF(aTit[oLbx1:nAt,1],oVermelho,oVerde),aTit[oLbx1:nAt,2] , aTit[oLbx1:nAt,3] , aTit[oLbx1:nAt,4] , aTit[oLbx1:nAt,5] , aTit[oLbx1:nAt,6] , aTit[oLbx1:nAt,7], transform(aTit[oLbx1:nAt,8],"@E 999,999,999.99"), transform(aTit[oLbx1:nAt,9],"@E 999,999,999.99")  }}
				If aPos[2,1] > 0
					@ aPos[2,1]-8,aPos[2,2] SAY Alltrim(STR0299) SIZE 140,08 OF oCliNR PIXEL COLOR CLR_HBLUE FONT oFCliNIR
					@ aPos[2,1]-0,aPos[2,2] LISTBOX oLbx2 FIELDS HEADER STR0264,STR0306,STR0265,STR0266,STR0267,STR0268,STR0269,Alltrim(STR0271) COLSIZES 40,30,40,40,40,40,50,50 SIZE aPos[2,3],aPos[2,4] OF oCliNR PIXEL
					oLbx2:SetArray(aNCC)
					oLbx2:bLine := { || { aNCC[oLbx2:nAt,1] , aNCC[oLbx2:nAt,2] , aNCC[oLbx2:nAt,3] , aNCC[oLbx2:nAt,4] , aNCC[oLbx2:nAt,5] , aNCC[oLbx2:nAt,6] , transform(aNCC[oLbx2:nAt,7],"@E 99,999,999,999.99"), transform(aNCC[oLbx2:nAt,8],"@E 999,999,999.99")  }}
				EndIf
				ACTIVATE MSDIALOG oCliNR CENTER
			EndIf
			If lAtual
				PutMv("MV_CKCLIXX",cPRW +" "+ cHrMin +" "+ __CUSERID +" "+ cCliLoj)
			EndIf
		EndIf
		// Volta posicoes originais dos Arquivos
		sRestArea(aArea)
	EndIf
Return(lRetorno)

Function ExistSX3(campo)
	Local lRet
	dbSelectArea("SX3")
	dbSetOrder(2)
	lRet := dbSeek(campo)
	dbSetOrder(1)
Return(lRet)

Function FS_VLCIDEST(nArq)
	Local lVAMCidA1 := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
	Local lVAMCidA2 := If(SA2->(FieldPos("A2_IBGE"))>0,.t.,.f.)
	Local aRet := {}
	Default nArq := 1
	Do Case
		Case nArq == 1
		if lVAMCidA1 .And. FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
			aadd(aRet,VAM->VAM_DESCID)
			aadd(aRet,VAM->VAM_ESTADO)
		Else
			aadd(aRet,SA1->A1_MUN)
			aadd(aRet,SA1->A1_EST)
		Endif
		Case nArq == 2
		if lVAMCidA2 .and. FG_SEEK("VAM","SA2->A2_IBGE",1,.f.)
			aadd(aRet,VAM->VAM_DESCID)
			aadd(aRet,VAM->VAM_ESTADO)
		Else
			aadd(aRet,SA2->A2_MUN)
			aadd(aRet,SA2->A2_EST)
		Endif
		Case nArq == 3 // Cliente SA1
		aRet := .t.
		If lVAMCidA1 .and. !Empty(M->A1_MUN)
			DbSelectArea("VAM")
			DbSetOrder(2)
			If DbSeek(xFilial("VAM")+left(M->A1_MUN+space(40),len(VAM->VAM_DESCID))+M->A1_EST)
				M->A1_EST  := VAM->VAM_ESTADO
				M->A1_IBGE := VAM->VAM_IBGE
			Else
				If DbSeek(xFilial("VAM")+left(M->A1_MUN+space(40),len(VAM->VAM_DESCID))+If(ReadVar()="M->A1_EST",M->A1_EST,""))
					M->A1_EST  := VAM->VAM_ESTADO
					M->A1_IBGE := VAM->VAM_IBGE
				Else
					aRet := .f.
				EndIf
			EndIf
		Endif
		Case nArq == 4 // Cliente IBGE
		aRet := .t.
		If lVAMCidA1
			DbSelectArea("VAM")
			DbSetOrder(1)
			If DbSeek(xFilial("VAM")+M->A1_IBGE)
				M->A1_MUN := VAM->VAM_DESCID
				M->A1_EST := VAM->VAM_ESTADO
			Else
				M->A1_MUN := space(len(M->A1_MUN))
				M->A1_EST := space(2)
			EndIf
		Endif
		Case nArq == 5 // Fornecedor SA2
		aRet := .t.
		If lVAMCidA2 .and. !Empty(M->A2_MUN)
			DbSelectArea("VAM")
			DbSetOrder(2)
			If DbSeek(xFilial("VAM")+left(M->A2_MUN+space(40),len(VAM->VAM_DESCID))+M->A2_EST)
				M->A2_EST  := VAM->VAM_ESTADO
				M->A2_IBGE := VAM->VAM_IBGE
			Else
				If DbSeek(xFilial("VAM")+left(M->A2_MUN+space(40),len(VAM->VAM_DESCID))+If(ReadVar()="M->A2_EST",M->A2_EST,""))
					M->A2_EST  := VAM->VAM_ESTADO
					M->A2_IBGE := VAM->VAM_IBGE
				Else
					aRet := .f.
				EndIf
			EndIf
		EndIf
		Case nArq == 6 // Fornecedor IBGE
		aRet := .t.
		If lVAMCidA2
			DbSelectArea("VAM")
			DbSetOrder(1)
			If DbSeek(xFilial("VAM")+M->A2_IBGE)
				M->A2_MUN := VAM->VAM_DESCID
				M->A2_EST := VAM->VAM_ESTADO
			Else
				M->A2_MUN := space(len(M->A2_MUN))
				M->A2_EST := space(2)
			EndIf
		Endif
	EndCase
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_MARSRV บAutor  ณFabio               บ Data ณ  01/17/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosiciona no VO6 usando ou nao a marca                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_MARSRV( cCodMarSrv, cCodSrv )

	Local cRet := Space(TamSX3("VO6_CODMAR")[1])
	Local cAliasOld := Alias()
	Local cQuery, cSQLVO6 := "SQLTVO6"

	Default cCodSrv := &(ReadVar())

	cQuery := "SELECT VO6_CODMAR "
	cQuery +=  " FROM " + RetSQLName("VO6")
	cQuery += " WHERE VO6_FILIAL = '" + xFilial("VO6") + "'"
	cQuery +=   " AND VO6_CODMAR IN " + FormatIN(cCodMarSrv+","+cRet,",")
	cQuery +=   " AND VO6_CODSER = '" + cCodSrv + "'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VO6_CODMAR DESC" // Ordena decrescente, pois os serv. com marca tem prioridade
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVO6 , .F., .T. )
	if !(cSQLVO6)->(Eof())
		cRet := (cSQLVO6)->(VO6_CODMAR)
	endif
	(cSQLVO6)->(dbCloseArea())
	If !Empty(cAliasOld)
		DbSelectArea(cAliasOld)
	EndIf
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_MARGSRVบAutor  ณFabio               บ Data ณ  01/17/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosiciona no VOS usando ou nao a marca                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_MARGSRV( cCodMarSrv, cCodGruSrv )

	Local cRet := Space(TamSX3("VOS_CODMAR")[1])
	Local cQuery

	Default cCodGruSrv := &(ReadVar())

	cQuery := "SELECT VOS_CODMAR "
	cQuery +=  " FROM " + RetSQLName("VOS")
	cQuery += " WHERE VOS_FILIAL = '" + xFilial("VOS") + "'"
	cQuery +=   " AND VOS_CODMAR IN " + FormatIN(cCodMarSrv+","+cRet,",")
	cQuery +=   " AND VOS_CODGRU = '" + cCodGruSrv + "'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VOS_CODMAR DESC" // Ordena decrescente, pois os serv. com marca tem prioridade
	cRet := FM_SQL(cQuery)

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ   LOAD   บ Autor ณFabio               บ Data ณ  05/30/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inicializacao dos modulos Oficina / Veiculos / Pecas       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEILOAD(oDlgName,oTimeName)
	FS_QTDVAI() // Verificar a existencia do registro do VAI para o usuario logado
	FS_WARNDPM() // Da mensagens relacionadas a DPM para usuแrio admin do dpm (configurado no VAI)
	FS_VX5() // Valida tabelas gen้ricas que devem estar populadas
	FS_DESPREC() // Somente para Veiculos - Verifica se as Despesas e Receitas estao agrupadas na Entrada por Compra
	If ExistBlock("PEMILINI")
		ExecBlock("PEMILINI",.f.,.f.) // Ponto de entrada chamado na Entrada do Sistema
	EndIf
Return

Function PECLOAD(oDlgName,oTimeName)
	FS_QTDVAI() // Verificar a existencia do registro do VAI para o usuario logado
	FS_WARNDPM() // Da mensagens relacionadas a DPM para usuแrio admin do dpm (configurado no VAI)
	FS_VX5() // Valida tabelas gen้ricas que devem estar populadas
	If ExistBlock("PEMILINI")
		ExecBlock("PEMILINI",.f.,.f.) // Ponto de entrada chamado na Entrada do Sistema
	EndIf
Return

Function OFILOAD(oDlgName,oTimeName)
	FS_QTDVAI() // Verificar a existencia do registro do VAI para o usuario logado
	FS_WARNDPM() // Da mensagens relacionadas a DPM para usuแrio admin do dpm (configurado no VAI)
	FS_VX5() // Valida tabelas gen้ricas que devem estar populadas
	If ExistBlock("PEMILINI")
		ExecBlock("PEMILINI",.f.,.f.) // Ponto de entrada chamado na Entrada do Sistema
	EndIf
Return

/*/{Protheus.doc} FS_VX5
Verifica se as tabelas genericas necessแrias estao criadas no sistema.
@author Rubens
@since 20/09/2017
@version 1.0

@type function
/*/
Static Function FS_VX5()
	If "OFIOA560VL" $ AllTrim(GetSX3Cache("VO1_TPATEN","X3_VALID"))
		dbSelectArea("VX5")
		cSQL := ;
			" SELECT COUNT(*)" +;
			  " FROM " + RetSQLName("VX5") +;
			 " WHERE VX5_FILIAL = '" + xfilial("VX5") + "'" +;
			   " AND VX5_CHAVE = '050' " +;
			   " AND D_E_L_E_T_ = ' '"
		If FM_SQL(cSQL) == 0
			MsgInfo(STR0305,STR0002) // "O sistema foi atualizado com novos registros na tabela VX5. Desta forma, antes de prosseguir com a utiliza็ใo do sistema, ้ necessแrio que a rotina Tab Gener Conces. (OFIOA560) seja acessada para que estes registros sejam inclusos na tabela VX5. Em caso de d๚vidas, entre em contato com o seu departamento responsแvel pelo Protheus."
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณ FS_QTDVAI บ Autor ณ Andre Luis Almeida บ Data ณ  22/06/11   บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณ Verificar a existencia do registro do VAI p/ usuario logado บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_QTDVAI()
	Local cQuery  := "SELECT COUNT(*) AS QTD FROM "+RetSQLName("VAI")+" VAI WHERE VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODUSR='"+__CUSERID+"' AND VAI.D_E_L_E_T_=' '"
	Local nQtdVAI := FM_SQL(cQuery)
	If nQtdVAI == 0
		AVISO(STR0002, STR0289 , { "Ok" } , 3)
	ElseIf nQtdVAI > 1
		MsgInfo(STR0290,STR0002) // Usuario com mais de um registro no cadastro de Equipe Tecnica! / Atencao!
	EndIf
	If GetNewPar("MV_VEICULO","N") <> "S"
		MsgInfo(STR0295,STR0002)
	EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณ FS_WARNDPMบ Autor ณ Vinicus Gati   บ Data ณ  28/10/15       บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณ Da mensagens importantes e urgentes relacionadas ao DPM     บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_WARNDPM()
	Local cQuery     := "SELECT VAI_ADMDPM FROM "+RetSQLName("VAI")+" VAI WHERE VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODUSR='"+__CUSERID+"' AND VAI.D_E_L_E_T_=' '"
	Local lFldAdmDPM := VAI->(FIELDPOS("VAI_ADMDPM")) > 0
	Local cMessages  := ""

	If lFldAdmDPM .AND. ALLTRIM(FM_SQL(cQuery)) == '1'
		oDpm := DMS_DPM():New()
		If ! oDpm:Alerted(dDatabase)
			cMessages := oDpm:GetImportantMessages(dDataBase)
			If !Empty(cMessages)
				Alert(cMessages)
				oLogger := DMS_Logger():New()
				oLogger:LogToTable({;
				{'VQL_AGROUP', 'DPM'     },;
				{'VQL_TIPO'  , 'ALERTA_1'},;
				{'VQL_DADOS' , __cUserID } ;
				})
			EndIf
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} FS_DESPREC
	VVD - Verifica se Desp/Rec estao agrupadas na Entrada por Compra
	
	@type function
	@author Andre Luis Almeida
	@since 28/04/2020
/*/
Static Function FS_DESPREC()
Local lVVD_FILUCP := VVD->(FieldPos("VVD_FILUCP")) <> 0
Local cQuery    := ""
Local cFilVVD   := ""
Local cAliasVVD := "SQLVVD_AJ"
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
		MsgInfo(STR0313,STR0002) // Hแ necessidade de processar os registros para Agrupar as Despesas e Receitas de Veiculos na Entrada por Compra. Acesse a rotina Despesas/Receitas (VEIVM040), clique em Outras A็๕es -> Agrupar Desp/Rec na Entrada por Compra / Atencao
	EndIf
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_AddPrgCบAutor  ณMicrosiga / Fabio   บ Data ณ  05/31/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta vetor para compilacao                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_AddPrgCompile( aPrgsCompile , cFunction , cPrgFile , cSrc , cAlias , nRecno , nIndice )
	Local nPrgsCompile
	DEFAULT aPrgsCompile := {}
	aAdd( aPrgsCompile , Array( COMPILE_ELEMENTS ) )
	nPrgsCompile := Len( aPrgsCompile )
	aPrgsCompile[ nPrgsCompile , COMPILE_FUNCTION	]	:= cFunction
	aPrgsCompile[ nPrgsCompile , COMPILE_PRG		]	:= cPrgFile
	aPrgsCompile[ nPrgsCompile , COMPILE_SOURCE		]	:= cSrc
	aPrgsCompile[ nPrgsCompile , COMPILE_OK			]	:= .F.
	aPrgsCompile[ nPrgsCompile , COMPILE_ALIAS		]	:= cAlias
	aPrgsCompile[ nPrgsCompile , COMPILE_RECNO		]	:= nRecno
	aPrgsCompile[ nPrgsCompile , COMPILE_ERROR_STR	]	:= ""
	aPrgsCompile[ nPrgsCompile , COMPILE_ERROR_COL	]	:= 0
	aPrgsCompile[ nPrgsCompile , COMPILE_ERROR_LINE	]	:= 0
	aPrgsCompile[ nPrgsCompile , COMPILE_INDICE		]	:= nIndice
Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_CompileบAutor  ณMicrosiga / Fabio   บ Data ณ  05/31/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCompila programa                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_Compile( oRpoForm , aPrgsCompile , lCompile , aMsgErr )
	Local cSrc
	Local cPrgFile
	Local cFunction
	Local cSourcePath
	Local lCompileOk
	Local nPrg
	Local nPrgs
	Local nSrcChkSum

	Begin Sequence

		aMsgErr := {}

		IF !( lCompileOk := !Empty( aPrgsCompile ) )
			Break
		EndIF

		IF !( lCompileOk := FG_RpoFormInit() )
			aAdd( aMsgErr , STR0211 )
			Break
		EndIF

		DEFAULT oRpoForm	:= FG_GetRpoObj()

		IF !( oRpoForm:StartBuild( .T. ) )
			aAdd( aMsgErr , STR0212 )			//"Nao Foi Possivel Compilar a Formula:"
			aAdd( aMsgErr , STR0213 )			//"Rpo em uso por Outro Processo."
			aAdd( aMsgErr , oRpoForm:ErrStr )
			Break
		EndIF

		DEFAULT lCompile	:= .T.

		nPrgs := Len( aPrgsCompile )
		For nPrg := 1 To nPrgs

			cFunction	:= aPrgsCompile[ nPrg , 1 ]
			cPrgFile	:= aPrgsCompile[ nPrg , 2 ]

			IF ( lCompile )

				cSrc		:= aPrgsCompile[ nPrg , 3 ]
				nSrcChkSum	:= oRpoForm:ChkSum( cSrc )

				IF !( lCompileOk := oRpoForm:Compile( cPrgFile , cSrc , 0, nSrcChkSum ) )
					FG_RotAddErr( "Error Prg:" 	+ cPrgFile		 		  )
					FG_RotAddErr( "Error Str:" 	+ oRpoForm:ErrStr 		  )
					FG_RotAddErr( "Error Col:" 	+ Str( oRpoForm:ErrCol  ) )
					FG_RotAddErr( "Error Line:" 	+ Str( oRpoForm:ErrLine ) )
					//		   		ConOut( "Error Prg:" 	+ cPrgFile		 		  )
					//		   		ConOut( "Error Str:" 	+ oRpoForm:ErrStr 		  )
					//		   		ConOut( "Error Col:" 	+ Str( oRpoForm:ErrCol  ) )
					//		   		ConOut( "Error Line:" 	+ Str( oRpoForm:ErrLine ) )
					aPrgsCompile[ nPrg , COMPILE_ERROR_STR 	] := oRpoForm:ErrStr
					aPrgsCompile[ nPrg , COMPILE_ERROR_COL 	] := oRpoForm:ErrCol
					aPrgsCompile[ nPrg , COMPILE_ERROR_LINE	] := oRpoForm:ErrLine
				EndIF

			ElseIF IsFunction( cFunction )

				cPrgFile := ( cFunction + ".PRW" )

				IF ( lCompileOk := (;
				oRpoForm:RemProg( cPrgFile );
				.and.;
				!IsFunction( cFunction );
				);
				)

					IF !Empty( cSourcePath := FG_GetRpoForm( .F. , .T. ) )
						cPrgFile := ( cSourcePath + ( cFunction + ".PRW" ) )
						FileErase( cPrgFile )
					EndIF

					//"O Progama"###"Foi Removido Com Sucesso..."
					FG_RotAddErr( STR0214 + " " + cPrgFile + " " + STR0215 )
					//				ConOut( "O Progama" + " " + cPrgFile + " " + "Foi Removido Com Sucesso..." )

				EndIF

			EndIF

			aPrgsCompile[ nPrg , COMPILE_OK ] := lCompileOk

		Next nPrg

		oRpoForm:EndBuild()

	End Sequence

Return( lCompileOk )

Function FG_GetRpoObj()
	FG_RpoFormInit()
Return( __oRpoForm )

Function FG_RpoFormInit( cGetRpoForm , lClose )
	Local lRpoFormInit	:= .T.
	Local lIsObject
	Local lGetNew
	DEFAULT __cRpoForm := "RpoForm_No_Init"

	Begin Sequence

		cGetRpoForm := FG_GetRpoForm( .T. )
		IF !( lRpoFormInit := !Empty( cGetRpoForm ) )
			Break
		EndIF

		IF (;
		( lIsObject := ( ValType( __oRpoForm ) == "O" ) );
		.and.;
		!( lGetNew := (;
		( __cRpoForm <> cGetRpoForm );
		.or.;
		!__oRpoForm:Open( cGetRpoForm );
		);
		);
		)
			If !( lClose )
				Break
			EndIf
		EndIF

		DEFAULT lClose := .F.

		IF (;
		( lIsObject );
		.and.;
		(;
		( lGetNew );
		.or.;
		( lClose );
		);
		)
			__oRpoForm:Close()
			__oRpoForm := NIL
			IF ( lClose )
				Break
			EndIF
		EndIF

		__cRpoForm		:= cGetRpoForm
		__oRpoForm		:= Rpo():New()
		lRpoFormInit	:= __oRpoForm:Open( cGetRpoForm )
		IF !( lRpoFormInit )
			lIsObject := ( ValType( __oRpoForm ) == "O" )
			IF ( lIsObject )
				__oRpoForm:Close()
			EndIF
			__oRpoForm := NIL
			__cRpoForm := "RpoForm_No_Init"
		EndIF

	End Sequence

Return( lRpoFormInit )

Function FG_GetRpoForm( lGetRpoName , lGetPathSource )
	Local cRpoName			:= ""
	Local cSourcePath		:= ""
	Local cGetRpoForm		:= GetPvProfString( GetEnvServer() , "SourcePath" , "" , GetAdv97() )
	Local lMakeOk			:= .F.
	DEFAULT lGetRpoName 	:= .F.
	DEFAULT lGetPathSource  := .F.
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณTrocar as barras para evitar inconsistencia no Linux 				    ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
	cGetRpoForm := StrTran(cGetRpoForm, AllTrim(" / "), AllTrim(" \ ") )
	IF ( SubStr( cGetRpoForm , -1 ) <> ALLTRIM(" \ ") )
		cGetRpoForm += " \ "
	EndIF
	cRpoName	:= ( "rpofrm" + cEmpAnt )
	cGetRpoForm += cRpoName
	cGetRpoForm := Lower( cGetRpoForm )
	IF !( lMakeOk := lIsDir( cGetRpoForm ) )
		/*/
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณFoi utilizado o parametro 1 no MakeDir para criar diretorio "fora" do  ณ
		ณservidor, pois esta se passando todo o caminho do path e nao a partir  ณ
		ณdele. Com esta funcionalidade sempre sera criado no server mesmo que   ณ
		ณC:\                                                                    ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
		lMakeOk := ( MakeDir( cGetRpoForm ,1) == 0 )
	EndIF
	cSourcePath := "\source"
	IF !( lMakeOk := lIsDir( cGetRpoForm + cSourcePath ) )
		lMakeOk := ( MakeDir( cGetRpoForm + cSourcePath, 1 ) == 0 )
	EndIF
	IF !( lMakeOk )
		//"Nao Foi Possivel Criar o Diretorio:"###"Para a Compilacao das Formulas
		FG_AddTreeErr( STR0216 + " " + cGetRpoForm + " " + STR0217 )
		cGetRpoForm := ""
	ElseIF ( lGetRpoName )
		cGetRpoForm += ( ALLTRIM(" \ ") + cRpoName + ".rpo" )
	ElseIF ( lGetPathSource )
		cSourcePath += AllTrim(" \ ")
		cGetRpoForm += cSourcePath
	EndIF
Return( cGetRpoForm )

Static Function FG_AddTreeErr( cErr )
	Local aErr
	Local nErr		:= Len( cErr )
	DEFAULT _aGetTreeErr := {}
	IF ( nErr > 220 )
		aErr := {}
		While ( nErr > 220 )
			aAdd( aErr , SubStr( cErr , 1 , 220 ) )
			cErr := SubStr( cErr , 221 )
			IF ( ( nErr := Len( cErr ) ) < 220 )
				aAdd( aErr , cErr )
				Exit
			EndIF
		End While
		aEval( aErr , { |cErr| FG_AddTreeErr( cErr ) } )
	ElseIF ( aScan( _aGetTreeErr , { |x| x == cErr } ) == 0 )
		aAdd( _aGetTreeErr , cErr )
	EndIF
Return( NIL )

Function FG_RotAddErr( cErr )
	Local aErr
	Local nErr		:= Len( cErr )
	DEFAULT __aRotErr := {}
	IF ( nErr > 220 )
		aErr := {}
		While ( nErr > 220 )
			aAdd( aErr , SubStr( cErr , 1 , 220 ) )
			cErr := SubStr( cErr , 221 )
			IF ( ( nErr := Len( cErr ) ) < 220 )
				aAdd( aErr , cErr )
				Exit
			EndIF
		End While
		aEval( aErr , { |cErr| FG_RotAddErr( cErr ) } )
	ElseIF ( aScan( __aRotErr , { |x| x == cErr } ) == 0 )
		aAdd( __aRotErr , cErr )
	EndIF
Return( NIL )

Function FG_RotGetErr()
	Local aRotErr
	DEFAULT __aRotErr	:= {}
	aRotErr		:= aClone( __aRotErr )
	__aRotErr	:= {}
Return( aClone( aRotErr ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณFG_VLGRITบ Autor ณ Andre Luis Almeida บ Data ณ  16/10/06   บฑฑ
ฑฑฬอออออออออุอออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricaoณVerifica se existe o Grupo/Item no Cadastro SBM/SB1/VEH    บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_VLGRIT(cGruItem)
	Local aArea:=GetArea()
	Local lRet := .f.
	DbSelectArea("SBM")
	DbSetOrder(1)
	If DbSeek( xFilial("SBM") + left(cGruItem,4) )
		lRet := .t.
	Else
		DbSelectArea("VEH")
		DbSetOrder(1)
		If DbSeek( xFilial("VEH") + left(cGruItem,4) )
			lRet := .t.
		EndIf
	EndIf
	If len(cGruItem) > 4
		lRet := .f.
		DbSelectArea("SB1")
		DbSetOrder(7)
		If DbSeek( xFilial("SB1") + cGruItem )
			lRet := .t.
		Else
			DbSelectArea("VEH")
			DbSetOrder(1)
			If DbSeek( xFilial("VEH") + cGruItem )
				lRet := .t.
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณFG_POSSB1บ Autor ณ Andre Luis Almeida บ Data ณ  23/01/07   บฑฑ
ฑฑฬอออออออออุอออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricaoณPosiciona no SB1 - FG_POSSB1("x","y","z")                  บฑฑ
ฑฑบ         ณ x - variavel para posicionamento. ex: "M->VPD_COD"        บฑฑ
ฑฑบ         ณ y - campo de retorno para variavel "x". ex: "SB1->B1_COD" บฑฑ
ฑฑบ         ณ z - grupo do item pesquisa qdo CODITE. ex: "M->VS3_GRUITE"บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบPesquisa ณ B1_CODBAR , B1_CODORIG, B1_CODSECU, B1_CODITE, B1_COD     บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_POSSB1(cPos,cRet,cGrp)
	Local lRet     := .f.
	Local _aGruIte  := {}
	Local _cGruIte  := ""
	Local _cCodIte  := ""
	Local cQuery   := ""
	Local cQuery1  := ""
	Local cQAlSB1  := "SQLSB1"
	Local cFilSB1  := xFilial("SB1")
	Local cFilSBM  := xFilial("SBM")
	
	Local cSQLSBM  := RetSqlName("SBM")
	Local cPesqSB1 := ""
	Local oSqlHelper := DMS_SqlHelper():New()
	local nRecno := 0
	local cLocBZ := ""
	Default cPos   := ReadVar()
	Default cRet   := "SB1->B1_CODITE"
	Default cGrp   := ""
	cPesqSB1 := &cPos
	If !Empty(cPesqSB1)
		cQuery1 := "SELECT SB1.R_E_C_N_O_ SB1RECNO FROM " + oSqlHelper:NoLock("SB1")
		cQuery1 += "JOIN "+cSQLSBM+" SBM ON (SBM.BM_FILIAL='"+cFilSBM+"' AND SBM.BM_GRUPO=SB1.B1_GRUPO AND SBM.BM_TIPGRU NOT IN ('4','7') AND SBM.D_E_L_E_T_=' ') " // Nao considerar SB1 de 4-SERVICOS e 7-VEICULOS
		cQuery1 += "WHERE SB1.B1_FILIAL='"+cFilSB1+"' AND "
		DbSelectArea("SB1")
		cPesqSB1 += space(30)
		cQuery := cQuery1+"SB1.B1_CODBAR='"+left(cPesqSB1,TamSx3("B1_CODBAR")[1])+"' AND SB1.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSB1, .F., .T. )
		If ( cQAlSB1 )->( SB1RECNO ) > 0
			lRet := .t.
			SB1->( DbGoto( ( cQAlSB1 )->( SB1RECNO ) ) )
		EndIf
		( cQAlSB1 )->( dbCloseArea() )
		If !lRet // PROCURA PELO B1_CODORIG
			If	SB1->(FieldPos("B1_CODORIG")) # 0
				cQuery := cQuery1+"SB1.B1_CODORIG='"+left(cPesqSB1,TamSx3("B1_CODORIG")[1])+"' AND SB1.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSB1, .F., .T. )
				If ( cQAlSB1 )->( SB1RECNO ) > 0
					lRet := .t.
					SB1->( DbGoto( ( cQAlSB1 )->( SB1RECNO ) ) )
				EndIf
				( cQAlSB1 )->( dbCloseArea() )
			EndIf
			If !lRet // PROCURA PELO B1_CODSECU
				If SB1->(FieldPos("B1_CODSECU")) # 0
					cQuery := cQuery1+"SB1.B1_CODSECU='"+left(cPesqSB1,TamSx3("B1_CODSECU")[1])+"' AND SB1.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSB1, .F., .T. )
					If ( cQAlSB1 )->( SB1RECNO ) > 0
						lRet := .t.
						SB1->( DbGoto( ( cQAlSB1 )->( SB1RECNO ) ) )
					EndIf
					( cQAlSB1 )->( dbCloseArea() )
				EndIf
			EndIf
		EndIf
		If !lRet // PROCURA PELO B1_CODITE
			_aGruIte := {}
			_cGruIte := &cGrp
			_cCodIte := &cPos
			cArqProd := SuperGetMV("MV_ARQPROD",.F.,"SB1")

			lFullMatch := .f.
			if Empty(_cGruIte)
				lFullMatch := FM_SQL(" SELECT count(*) from "+oSqlHelper:NoLock("SB1")+" WHERE B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = '"+_cCodIte+"' AND D_E_L_E_T_ = ' ' ") == 1
			else
				lFullMatch := FM_SQL(" SELECT count(*) from "+oSqlHelper:NoLock("SB1")+" WHERE B1_FILIAL = '"+xFilial('SB1')+"' AND B1_GRUPO = '"+_cGruIte+"' AND B1_COD = '"+_cCodIte+"' AND D_E_L_E_T_ = ' ' ") == 1
			endif

			cQuery := "    SELECT SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC , SB1.B1_COD , SB1.B1_FABRIC, BZ_LOCPAD, B1_LOCPAD "
			cQuery += "      FROM " + oSqlHelper:NoLock("SB1")
			cQuery += "      JOIN " + oSqlHelper:NoLock("SBM") + " ON SBM.BM_FILIAL='"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_TIPGRU NOT IN ('4','7') AND SBM.D_E_L_E_T_ = ' ' " // Nao considerar SB1 de 4-SERVICOS e 7-VEICULOS
			cQuery += " LEFT JOIN " + oSqlHelper:NoLock("SBZ") + " ON BZ_FILIAL = '"+xFilial('SBZ')+"' AND  BZ_COD = B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
			cQuery += "     WHERE SB1.B1_FILIAL='"+cFilSB1+"'  "
			If ! Empty(_cGruIte)
				cQuery += " AND SB1.B1_GRUPO = '"+_cGruIte+"' "
			EndIf
			if lFullMatch
				cQuery += " AND SB1.B1_CODITE LIKE '"+_cCodIte+"' "
			else
				cQuery += " AND SB1.B1_CODITE LIKE '"+alltrim(_cCodIte)+"%' "
			endif
			cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSB1, .F., .T. )

			If ! (cQAlSB1)->(Eof())
				lRet := .t.
				Do While !( cQAlSB1 )->( Eof() )
					if empty((cQAlSB1)->(BZ_LOCPAD))
						cLocBZ := (cQAlSB1)->(B1_LOCPAD)
					endif
					cLocal := IIF(cArqProd == "SBZ", cLocBZ, (cQAlSB1)->(B1_LOCPAD))  // no caso aqui do possb1 nใo precisa de tanta logica de locali2... s๓ join com bz e jแ era
					nSaldo := OX001SLDPC( xFilial("SB2") + (cQAlSB1)->B1_COD + cLocal)
					Aadd(_aGruIte,{ ;
						(cQAlSB1)->(B1_GRUPO   ),;
						(cQAlSB1)->(B1_CODITE  ),;
						(cQAlSB1)->(B1_DESC    ),;
						(cQAlSB1)->(B1_COD     ),;
						(cQAlSB1)->(B1_FABRIC  ),;
						nSaldo;
					})
					( cQAlSB1 )->( DbSkip() )
				EndDo
			EndIf
			( cQAlSB1 )->( dbCloseArea() )

			DbSelectArea("SB1")
			DbSetOrder(1)
			If len(_aGruIte) == 1
				If !DbSeek(cFilSB1+_aGruIte[1,4])
					lRet := .f.
				EndIf
			ElseIf len(_aGruIte) > 1
				lRet := .f.
				DEFINE MSDIALOG oGruIte TITLE (STR0221) From 00,00 to 17,70 of oMainWnd
				@ 002,002 LISTBOX oLbGruIte FIELDS HEADER (STR0218),;  //Grupo
				(STR0219),;  //Codigo Item
				(STR0220),;  //Descricao
				(STR0274),; //Fabricante
				(Alltrim(STR0271)) ; //Saldo
				COLSIZES 20,50,80,70,30 SIZE 274,124 OF oGruIte PIXEL ON DBLCLICK (DbSeek(cFilSB1+_aGruIte[oLbGruIte:nAt,4]),lRet:=.t.,oGruIte:End())
				oLbGruIte:SetArray(_aGruIte)
				oLbGruIte:bLine := { || {_aGruIte[oLbGruIte:nAt,1],;
				_aGruIte[oLbGruIte:nAt,2] ,;
				_aGruIte[oLbGruIte:nAt,3] ,;
				_aGruIte[oLbGruIte:nAt,5] ,;
				_aGruIte[oLbGruIte:nAt,6] }}
				ACTIVATE MSDIALOG oGruIte CENTER
			Else
				cQuery := cQuery1+"SB1.B1_COD='"+left(cPesqSB1,TamSx3("B1_COD")[1])+"' AND SB1.D_E_L_E_T_=' '"
				nRecno := FM_SQL(cQuery)
				If valtype(nRecno) == "N" .and. nRecno > 0
					lRet := .t.
					SB1->(DbGoto(nRecno))
				EndIf
			EndIf
		EndIf
		DbSelectArea("SB1")
		DbSetOrder(1) // B1_FILIAL+B1_COD
		If lRet
			&(cPos) := &(cRet)
			If !Empty(cGrp)
				&(cGrp) := SB1->B1_GRUPO
			EndIf
		Else
			dbGoBottom() // DbSeek("XXXXXXXXXXXXXX") // Posicionar em Final de Arquivo
		EndIf
	EndIf
Return(lRet)

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ FG_OIC     ณ Autor ณ Fabio                 ณ Data ณ 25/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Imporata Requisicao de peca Fabrica CD Volksvagen            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_OICGM()
	Local x := 0
	Local cDiretTxt := Alltrim(VE4->VE4_DIRFAB)
	Local cDiretorio:= Alltrim( Substr( VE4->VE4_DIRFAB , 1 , Rat( AllTrim(" \ "),VE4->VE4_DIRFAB) ) )
	Local cStringTxt := "" , cArquivo := ""
	Local ni := 0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta Vetor com os Arquivos do Diretorio                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aArqTxt := {}
	aArqTxt := Directory(cDiretTxt,"D")
	If len(aArqTxt) == 0
		MsgStop((STR0137))  // Nao foi possivel abrir o arquivo texto. Operacao cancelada !
		Return
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Abre Arquivo binario e faz leitura                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//cString := space(200)
	aPecas := {}

	For x:=1 to Len(aArqTxt)

		cArquivo := Alltrim( cDiretorio ) + Alltrim( aArqTxt[x,1] )

		If !File(cArquivo)
			Loop
		EndIf

		FT_FUSE( cArquivo )
		FT_FGOTOP()

		ni   := 0
		nPos := 0
		cCod := ""

		While !FT_FEOF()

			cStringTxt := FT_FREADLN()
			if Substr(cStringTxt,1,2) == "01"

				cCod := Substr(cStringTxt,VE4->VE4_CODINI,VE4->VE4_CODTAM)
				nPos := Len(cCod)
				For ni:=1 to nPos
					If Substr(cCod,ni,1) $ " /"
						cCod := Substr(cCod,1,ni-1)+Substr(cCod,ni+1)
						ni--
					EndIf
				Next

				Aadd(aPecas,{aArqTxt[x,1],Alltrim(cCod),Alltrim(Substr(cStringTxt,VE4->VE4_DESINI,VE4->VE4_DESTAM)),Alltrim(Substr(cStringTxt,VE4->VE4_QTDINI,VE4->VE4_QTDTAM))})
			Endif
			FT_FSKIP()

		End

	Next

	FT_FUSE()

Return(aPecas)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFG_ORCVER ณ Autor ณ Andre                 ณ Data ณ 08/05/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณConsulta o orcamento e seus produtos e servicos             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGeral                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_ORCVER(cNumOrc)
	Local nTotDes := 0
	Local nTotPec := 0
	Local nTotSrv := 0
	Local nTotOrc := 0
	Local nLinhas := 999
	Local bCampo  := { |nCPO| Field(nCPO) }
	Local nCntFor := 0
	Local _ni := 0
	Private nP := 1
	Private nS := 1

	dbSelectArea("VS1")
	dbSetOrder(1)
	if dbSeek(xFilial("VS1")+cNumOrc)

		nOpc := 2
		Inclui := .f.
		if Type("aRotina") == "U"
			aRotina := { {"" ,"", 0 , 1},;
			{ "" ,"", 0 , 2},;
			{ "" ,"", 0 , 3},;
			{ "","" , 0 , 2}}
		Endif

		RegToMemory("VS1",.T.)

		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("VS1")
		aPriEnc := {}
		While x3_arquivo == "VS1" .and. !eof()
			if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. !AllTrim(x3_campo) $ [VS1_VALDES#VS1_DESACE#VS1_ICMCAL#VS1_VTOTNF#VS1_VALFRE#VS1_VALSEG#VS1_DEPTO #VS1_BRICMS#VS1_BASIPI]
				AADD(aPriEnc,x3_campo)
				if x3_campo <> "VS1_NUMORC"
					wVar := "M->"+x3_campo
					&wVar:= CriaVar(x3_campo)
				Endif
			Endif
			dbSkip()
		EndDo

		DbSelectArea("VS1")
		For nCntFor := 1 TO FCount()
			M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
		Next

		//Servicos

		nUsadoS:=0
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("VS4")
		aHeaderS:={}
		While !Eof().And.(x3_arquivo=="VS4")
			If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( ! Trim(SX3->X3_CAMPO) $ "VS4_NUMORC" )
				nUsadoS++
				Aadd(aHeaderS,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
				wVar := "M->"+x3_campo
				&wVar := CriaVar(x3_campo)
			Endif
			dbSkip()
		EndDo

		// Monta aCols de Servicos

		aColsS:={}
		DbSelectArea("VS4")
		DbSetOrder(1)
		DbSeek(xFilial("VS4")+VS1->VS1_NUMORC)
		While VS4->VS4_FILIAL == xFilial("VS4") .and. VS4->VS4_NUMORC == VS1->VS1_NUMORC .and. !eof()
			AADD(aColsS,Array(nUsadoS+1))
			For _ni:=1 to nUsadoS
				aColsS[Len(aColsS),_ni]:=If(aHeaderS[_ni,10] # "V",FieldGet(FieldPos(aHeaderS[_ni,2])),CriaVar(aHeaderS[_ni,2]))
			Next
			aColsS[Len(aColsS),nUsadoS+1]:=.F.
			nTotDes += VS4->VS4_VALDES
			nTotSrv += VS4->VS4_VALTOT
			nTotOrc += VS4->VS4_VALTOT
			DbSkip()
		EndDo

		if Len(aColsS) == 0
			aColsS:={Array(nUsadoS+1)}
			aColsS[1,nUsadoS+1]:=.F.
			For _ni:=1 to nUsadoS
				aColsS[1,_ni]:=CriaVar(aHeaderS[_ni,2])
			Next
		Endif

		//Pecas

		nUsadoP:=0
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("VS3")
		aHeaderP:={}
		While !Eof().And.(x3_arquivo=="VS3")
			If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( ! Trim(SX3->X3_CAMPO) $ "VS3_NUMORC" )
				nUsadoP++
				Aadd(aHeaderP,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
				wVar := "M->"+x3_campo
				&wVar := CriaVar(x3_campo)
			Endif
			dbSkip()
		EndDo

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Monta o aCols Pecas                                          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aColsP := {}
		DbSelectArea("VS3")
		DbSetOrder(1)
		DbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
		While VS3->VS3_FILIAL == xFilial("VS3") .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC .and. !eof()
			AADD(aColsP,Array(nUsadoP+1))
			For _ni:=1 to nUsadoP
				aColsP[Len(aColsP),_ni]:=If(aHeaderP[_ni,10] # "V",FieldGet(FieldPos(aHeaderP[_ni,2])),CriaVar(aHeaderP[_ni,2]))
			Next
			aColsP[Len(aColsP),nUsadoP+1]:=.F.

			nTotDes += VS3->VS3_VALDES
			nTotPec += (VS3->VS3_VALPEC*VS3->VS3_QTDITE)
			nTotOrc := nTotPec+nTotSrv - nTotDes
			nTotOrc += VS1->VS1_DESACE
			nTotOrc += VS1->VS1_VALSEG
			nTotOrc += VS1->VS1_VALFRE
			DbSkip()
		EndDo

		if Len(aColsP) == 0
			aColsP:={Array(nUsadoP+1)}
			aColsP[1,nUsadoP+1]:=.F.
			For _ni:=1 to nUsadoP
				aColsP[1,_ni]:=CriaVar(aHeaderP[_ni,2])
			Next
		Endif

		DbSelectArea("VV1")
		DbSetOrder(1)
		DbSeek(xFilial("VV1")+VS1->VS1_CHAINT)

		M->VS1_GETKEY := VV1->VV1_CHASSI
		M->VS1_CHASSI := VV1->VV1_CHASSI
		M->VS1_CHAINT := VV1->VV1_CHAINT
		M->VS1_PLAVEI := VV1->VV1_PLAVEI
		M->VS1_CODFRO := VV1->VV1_CODFRO
		M->VS1_CODMAR := VV1->VV1_CODMAR

		//FG_SEEK("SA1","VS1->VS1_CLIFAT",1,.f.)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+VS1->VS1_CLIFAT)

		M->VS1_NCLIFT := SA1->A1_NOME
		M->VS1_ENDCLI := SA1->A1_END
		M->VS1_CIDCLI := SA1->A1_MUN
		M->VS1_ESTCLI := SA1->A1_EST
		M->VS1_FONCLI := SA1->A1_TEL

		//if FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.) .and. M->VS1_TIPORC == "2"
		//
		//	FG_SEEK("VV2","VV1->VV1_CODMAR+VV1->VV1_MODVEI",1,.f.)
		//	FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
		//	FG_SEEK("SA1","VV1->VV1_PROATU",1,.f.)

		DbSelectArea("VO5")
		DbSetOrder(1)
		If DbSeek(xFilial("VO5")+VV1->VV1_CHAINT) .and. M->VS1_TIPORC == "2"

			DbSelectArea("VV2")
			DbSetOrder(1)
			DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD)
			DbSelectArea("VVC")
			DbSetOrder(1)
			DbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI)
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+VV1->VV1_PROATU)

			M->VS1_DESMAR := VE1->VE1_DESMAR
			M->VS1_DESMOD := VV2->VV2_DESMOD
			M->VS1_CHAINT := VV1->VV1_CHAINT
			M->VS1_CHASSI := VV1->VV1_CHASSI
			M->VS1_PLAVEI := VV1->VV1_PLAVEI
			M->VS1_CODFRO := VV1->VV1_CODFRO
			M->VS1_FABMOD := VV1->VV1_FABMOD
			M->VS1_DESCOR := VVC->VVC_DESCRI
			M->VS1_PROVEI := SA1->A1_COD
			M->VS1_NOMPRO := SA1->A1_NOME
			M->VS1_ENDPRO := SA1->A1_END
			M->VS1_CIDPRO := SA1->A1_MUN
			M->VS1_ESTPRO := SA1->A1_EST
			M->VS1_FONPRO := SA1->A1_TEL
		EndIf

		// Variavel que controla cliente periodico
		if VS1->VS1_NOROUT == "1"
			cForPeri := SA1->A1_COND
		Endif

		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek(xFilial("SA3")+VS1->VS1_CODVEN)
		cCodVen := SA3->A3_COD
		M->VS1_NOMVEN := SA3->A3_NOME

		DEFINE MSDIALOG oOrcVerb FROM 000,000 TO 027,079 TITLE STR0222 OF oMainWnd //"Orcamentos"

		aTela := {}
		aGets := {}
		dbSelectArea("VS1")
		Zero()
		oGetMGet:= MsMGet():New("VS1",0,2,,,,aPriEnc,{014,002,085,312},,2,,,,oOrcVerb,,.T.,.F.)

		aHeader  := aClone(aHeaderP)
		aCols    := aClone(aColsP)
		n := 1
		oGetPecas                    := MsGetDados():New(087,001,145,310,2,"AllwaysTrue()","AllwaysTrue()","",.T.,,,,nLinhas,"AllwaysTrue()",,,,oOrcVerb)
		oGetPecas:oBrowse:default()
		oGetPecas:oBrowse:bGotFocus  := {|| n := nP, aCols := Aclone(aColsP), aHeader := Aclone(aHeaderP), oGetPecas:oBrowse:Refresh()}
		oGetPecas:oBrowse:bLostFocus := {|| nP := n, aColsP := Aclone(aCols), aHeaderP := Aclone(aHeader)}

		aHeader := aClone(aHeaderS)
		aCols   := aClone(aColsS)
		n := 1
		oGetSrvcs                    := MsGetDados():New(147,001,204,310,2,"AllwaysTrue()","AllwaysTrue()","",.T.,,,,nLinhas,"AllwaysTrue()",,,,oOrcVerb)
		oGetSrvcs:oBrowse:default()
		oGetSrvcs:oBrowse:bGotFocus  := {|| n := nS, aCols := Aclone(aColsS), aHeader := Aclone(aHeaderS), oGetSrvcs:oBrowse:Refresh()}
		oGetSrvcs:oBrowse:bLostFocus := {|| nS := n, aColsS := Aclone(aCols), aHeaderS := Aclone(aHeader)}

		ACTIVATE MSDIALOG oOrcVerb CENTER ON INIT (EnchoiceBar(oOrcVerb,{|| nOpca := 1,oOrcVerb:End()},{|| nOpca := 2,oOrcVerb:End()},1))

	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_GRAFICOบAutor  ณFabio               บ Data ณ  06/20/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta grafico                                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ1- Objeto para montar o grafico - Nao obrigatorio           บฑฑ
ฑฑบ          ณ2- Titulo do grafico                                        บฑฑ
ฑฑบ          ณ3- Linha                                                    บฑฑ
ฑฑบ          ณ4- Coluna                                                   บฑฑ
ฑฑบ          ณ5- Tamanho                                                  บฑฑ
ฑฑบ          ณ6- Largura                                                  บฑฑ
ฑฑบ          ณ7- Conteudo do grafico                                      บฑฑ
ฑฑบ          ณ   Aadd(aContg, {  9, "A A" , })                            บฑฑ
ฑฑบ          ณ   Aadd(aContg, { 14, "B B" , })                            บฑฑ
ฑฑบ          ณ8- Grafico inicial                                          บฑฑ
ฑฑบ          ณ9- Mostra botoes                                            บฑฑ
ฑฑบ          ณ10 Legenda                                                  บฑฑ
ฑฑบ          ณ   Aadd(aLegenda, { "Serie 1", .T. })                       บฑฑ
ฑฑบ          ณ   Aadd(aLegenda, { "Serie 2", .F. })                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_GRAFICO(oDlgGrafico,cTitGrafico,nLing,nColg,nTamg,nLargg,aContg,nGrafIni,lMostraBut,aLegenda)
	Local lDlgMonta := .t.
	Local aObjects := {} , aPosObj := {} , aInfo := {} , aSizeAut := MsAdvSize() // Variaveis para posicionamento de Tela
	Private oPizza, lMostraPizza := .t.
	Default cTitGrafico := STR0223        && Titulo
	Default nLing       := 23                  && Linha
	Default nColg       := 1                   && Coluna
	Default nTamg       := 166                 && Tamanho
	Default nLargg      := 392                 && Largura
	Default aContg      := {}                  && Conteudo
	Default nGrafIni    := 1                   && Grafico Inicial
	Default lMostraBut  := .t.                 && Mostra Botoes
	Default aLegenda    := {}
	If oDlgGrafico # NIL
		lDlgMonta := .f.
	EndIf
	If lDlgMonta
		// Configura os tamanhos dos objetos
		aObjects := {}
		AAdd( aObjects, { 010 , 010 , .T., .T. } )  // EnchoiceBar
		aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
		aPosObj := MsObjSize (aInfo, aObjects, .t.)
		nLing   := aPosObj[1,1] // Linha Inicial
		nColg   := aPosObj[1,2] // Coluna Inicial
		nTamg   := aPosObj[1,3]-nLing // Tamanho
		nLargg  := aPosObj[1,4]-nColg // Largura
		DEFINE MSDIALOG oDlgGrafico FROM aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE cTitGrafico PIXEL
	EndIf
	If Len(aContg) == 0
		Aadd(aContg, { 0, 0, NIL })
	EndIf

	FS_ADDGRAF(nGrafIni,aContg,cTitGrafico,nLing,nColg,nTamg,nLargg,oDlgGrafico,aLegenda)

	If ( oBarGrafico == NIL .Or. lDlgMonta	) .And. lMostraBut

		DEFINE BUTTONBAR oBarGrafico SIZE 25,25 3D OF oDlgGrafico

		If lDlgMonta
			DEFINE BUTTON RESOURCE "FINAL" OF oBarGrafico GROUP ACTION (oDlgGrafico:End()) TOOLTIP (STR0224) //"Abandona"
		EndIf

		If lMostraBut
			DEFINE BUTTON RESOURCE "LINE"  OF oBarGrafico GROUP ACTION (FS_ADDGRAF(1,aContg,cTitGrafico,nLing,nColg,nTamg,nLargg,oDlgGrafico,aLegenda)) TOOLTIP (STR0225) //"Gr fico de Linha"
			DEFINE BUTTON RESOURCE "GRAF3D" OF oBarGrafico       ACTION 	(FS_ADDGRAF(4,aContg,cTitGrafico,nLing,nColg,nTamg,nLargg,oDlgGrafico,aLegenda))	TOOLTIP (STR0226)  //"Gr ficos Tridimensionais"
			DEFINE BUTTON RESOURCE "S4WB013N" Var oPizza OF oBarGrafico    ACTION (FS_ADDGRAF(10,aContg,cTitGrafico,nLing,nColg,nTamg,nLargg,oDlgGrafico,aLegenda))	TOOLTIP (STR0227) //"Gr fico Pizza"
			DEFINE BUTTON RESOURCE "AREA"  OF oBarGrafico       ACTION (FS_ADDGRAF(2,aContg,cTitGrafico,nLing,nColg,nTamg,nLargg,oDlgGrafico,aLegenda))	TOOLTIP (STR0228) //"Gr fico de Barras"
			DEFINE BUTTON RESOURCE "BAR"  OF oBarGrafico       ACTION (FS_ADDGRAF(3,aContg,cTitGrafico,nLing,nColg,nTamg,nLargg,oDlgGrafico,aLegenda))	TOOLTIP (STR0229) //"Gr fico de Area"
		EndIf

		aView2 := {}
		Aadd(aView2,{cTitGrafico,cTitGrafico,cTitGrafico})

		DEFINE BUTTON RESOURCE "PRINT02"  OF oBarGrafico     ACTION (CtbGrafPrint(oGrafico,cTitGrafico,{cTitGrafico },aView2,,, { 1, ((oGrafico:nRight - oGrafico:nLeft) * 2),((oGrafico:nBottom - oGrafico:nTop) * 2) } ))	TOOLTIP ("Imprimir") //"Imprimir"
		DEFINE BUTTON RESOURCE "PMSMAIS"  OF oBarGrafico     ACTION 	(oGrafico:ZoomIn()) 	TOOLTIP (STR0230)  //"Ampliar"
		DEFINE BUTTON RESOURCE "PMSMENOS" OF oBarGrafico     ACTION 	(oGrafico:ZoomOut())	TOOLTIP (STR0231)  //"Reduzir"

		If !lMostraPizza .And. oPizza # NIL
			oPizza:Disable()
		EndIf

	EndIf

	If lDlgMonta
		ACTIVATE MSDIALOG oDlgGrafico
	EndIf

Return( oGrafico )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFS_ADDGRAFณ Autor ณ Fabio                 ณ Data ณ 08/05/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณLevanta a maior quantidade de series.                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ADDGRAF(nSerie,aContg,cTitGrafico,nLing,nColg,nTamg,nLargg,oDlgGrafico,aLegenda)

	Local nConta := 0, nCorSeq := 0, nNroSeries := 1, nNro := 1,nNro1 := 0, aSeries := {}
	Local aCorGraf := { CLR_GREEN,CLR_YELLOW,CLR_RED,CLR_CYAN,CLR_BLUE,CLR_HRED,CLR_BROWN,CLR_HGRAY,CLR_LIGHTGRAY,;
	CLR_GRAY,CLR_HBLUE,CLR_HGREEN,CLR_HCYAN,CLR_BLACK,CLR_HMAGENTA,CLR_MAGENTA,CLR_WHITE }

	@ nLing,nColg MSGRAPHIC oGrafico SIZE nLargg,nTamg OF oDlgGrafico PIXEL

	oGrafico:SetMargins( 2, 6, 6,6 )
	oGrafico:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGrafico:SetTitle( cTitGrafico, "" , CLR_BLACK , A_CENTER  , GRP_TITLE )
	oGrafico:SetLegenProp( GRP_SCRBOTTOM, CLR_WHITE, GRP_SERIES, .T. )
	oGrafico:l3D := .T.

	&& Levanta a maior quantidade de series.
	For nConta:=1 to Len(aContg)

		If ( Len(aSeries) == 0 .Or. ((nNro := Ascan(aSeries,{ |x| x[1] == aContg[nConta,2] })) == 0 ) )
			Aadd( aSeries, { aContg[nConta,2], 0 , 0})
			nNro := Len(aSeries)
		EndIf

		aSeries[nNro,2] += 1

		If aSeries[nNro,2] > nNroSeries
			nNroSeries := aSeries[nNro,2]
		EndIf

	Next

	If nNroSeries > 1
		lMostraPizza := .f.
	EndIf

	&& Cria series de acordo com a quantidade levantada.
	For nConta:=1 to nNroSeries
		&("nSerie"+StrZero(nConta,3))	:= oGrafico:CreateSerie( nSerie , If( nConta <= Len(aLegenda), aLegenda[nConta,1],nil) ,, If( nConta <= Len(aLegenda), aLegenda[nConta,2],nil)  )
	Next

	For nNro := 1 to Len(aSeries)

		If nNroSeries > 1
			nCorSeq := 0
		EndIf

		For nConta:=1 to Len(aContg)

			If aContg[nConta,2] == aSeries[nNro,1]

				If aContg[nConta,3] == NIL
					nCorSeq += 1
					If nCorSeq > Len(aCorGraf)
						nCorSeq := 1
					EndIf
				EndIf

				If ValType(aContg[nConta,1]) # "N"
					MsgStop(STR0232+aContg[nConta,1],STR0002)
					Exit
				EndIf

				aSeries[nNro,3] += 1

				oGrafico:Add( &("nSerie"+StrZero(aSeries[nNro,3],3)) ,aContg[nConta,1],aContg[nConta,2], If(aContg[nConta,3]==NIL,aCorGraf[nCorSeq],aContg[nConta,3]) )

			EndIf

		Next

		For nNro1:=(aSeries[nNro,2]+1) to nNroSeries

			nCorSeq += 1
			If nCorSeq > Len(aCorGraf)
				nCorSeq := 1
			EndIf

			aSeries[nNro,3] += 1
			oGrafico:Add( &("nSerie"+StrZero(aSeries[nNro,3],3)) ,0,aSeries[nNro,1], aCorGraf[nCorSeq] )

		Next

	Next

	oGrafico:Align := CONTROL_ALIGN_ALLCLIENT
	oGrafico:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFG_NEWGRAFณ Autor ณ Andre Luis Almeida    ณ Data ณ 30/03/16 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Nova Funcao de Grafico BARRAS                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_NEWGRAF(oDlgGrafico,cTitGrafico,aIteGrafico,lLegenda,cPicture)
	Local lDlgMonta := .t.
	Local nConta    := 0
	Local aObjects  := {} , aPosObj := {} , aInfo := {} , aSizeAut := MsAdvSize(.f.) // Variaveis para posicionamento de Tela
	Default cTitGrafico := STR0223 // Titulo
	Default aIteGrafico := {}      // Conteudo
	Default lLegenda    := .f.     // Mostra Legenda ?
	Default cPicture    := ""      // Mascara
	If oDlgGrafico # NIL
		lDlgMonta := .f.
	EndIf
	If lDlgMonta
		// Configura os tamanhos dos objetos
		aObjects := {}
		AAdd( aObjects, { 010 , 010 , .T., .T. } )  // EnchoiceBar
		aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
		aPosObj := MsObjSize (aInfo, aObjects, .f.)
		DEFINE MSDIALOG oDlgGrafico FROM aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE cTitGrafico PIXEL
		@ aPosObj[1,1],aPosObj[1,2] SCROLLBOX oScrollGraf SIZE aPosObj[1,3]-aPosObj[1,1],aPosObj[1,4] OF oDlgGrafico BORDER PIXEL
	EndIf
	If Len(aIteGrafico) == 0
		Aadd(aIteGrafico, { 0, 0, NIL })
	EndIf
	oGrafico := FWChartFactory():New()
	oGrafico := oGrafico:getInstance( BARCHART ) // cria objeto FWChartBar/*Valores do getInstance:BARCHART  -  cria objeto FWChartBarBARCOMPCHART -  cria objeto FWChartBarCompLINECHART -  cria objeto FWChartLinePIECHART - cria objeto FWChartPie*/
	If lDlgMonta
		oGrafico:init( oScrollGraf , .F. )
	Else
		oGrafico:init( oDlgGrafico , .F. )
	EndIf
	oGrafico:setTitle( cTitGrafico , CONTROL_ALIGN_CENTER )
	If lLegenda
		oGrafico:setLegend( CONTROL_ALIGN_LEFT )
		oGrafico:setMask( " *@* " )
	EndIf
	If !Empty(cPicture)
		oGrafico:setPicture( cPicture )
	EndIf
	For nConta := 1 to Len(aIteGrafico)
		oGrafico:addSerie( aIteGrafico[nConta,2] , aIteGrafico[nConta,1] )
	Next
	oGrafico:build()
	If lDlgMonta
		oScrollGraf:LREADONLY := .T.
		ACTIVATE MSDIALOG oDlgGrafico
	EndIf
Return( oGrafico )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_CONVSQLบAutor  ณLuis Delorme        บ Data ณ  16/08/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConverte funcoes especificas utilizadas em queries          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ1- Funcao a ser convertida                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_CONVSQL(cFunc)
	Local cSGBD := TcGetDb()
	Local cRet := ""
	If "MSSQL" $ cSGBD
		If cFunc == "SUBS"
			cRet := "SUBSTRING"
		ElseIf cFunc == "CONCATENA"
			cRet := "+"
		EndIf
	ElseIf cSGBD == "DB2"
		If cFunc == "SUBS"
			cRet := "SUBSTR"
		ElseIf cFunc == "CONCATENA"
			cRet := "+"
		EndIf
	ElseIf cSGBD == "ORACLE"
		If cFunc == "SUBS"
			cRet := "SUBSTR"
		ElseIf cFunc == "CONCATENA"
			cRet := "||"
		EndIf
	Else
		If cFunc == "SUBS"
			cRet := "SUBSTR"
		ElseIf cFunc == "CONCATENA"
			cRet := "+"
		EndIf
	EndIf
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ M_CDEPRO ณ Autor ณ  Luis Delorme         ณ Data ณ 10/11/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Descricao dos itens para o OFIOM110                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_CDEPRO(cItem, nQtdLev)
	Local aCompras := {}
	Local aVendas  := {}
	Default nQtdLev := 10
	DbSelectArea("SB1")
	DbSetOrder(1)
	if DbSeek(xFilial("SB1")+cItem)
		cProd := Alltrim(SB1->B1_GRUPO)+" "+Alltrim(SB1->B1_CODITE)+" "+Alltrim(SB1->B1_DESC)
		cPecRef := ""
		// Andre Luis Almeida - 06/07/2004 - Mostra ultimas compras. Igual Sugestao de Compras //
		DbSelectArea( "SD1" )
		DbSetOrder(7) // D1_FILIAL+D1_COD+D1_LOCAL+DTOS(D1_DTDIGIT)+D1_NUMSEQ
		DbSeek( xFilial("SD1") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") +  dtos(dDataBase+1) , .t. )
		If !Bof()
			DbSkip(-1)
		EndIf
		While !Bof() .and. SD1->D1_FILIAL == xFilial("SD1") .and. SB1->B1_COD == SD1->D1_COD
			DbSelectArea( "SF4" )
			DbSetOrder(1)
			DbSeek( xFilial("SF4") + SD1->D1_TES )
			If SF4->F4_ESTOQUE == "S" .and. SF4->F4_DUPLIC == "S" .and. SF4->F4_OPEMOV == "01" //01 = COMPRA
				DbSelectArea( "SA2" )
				DbSetOrder(1)
				DbSeek( xFilial("SA2") + SD1->D1_FORNECE + SD1->D1_LOJA )
				aadd(aCompras,{Transform(SD1->D1_DTDIGIT,"@D"),SD1->D1_CUSTO,SD1->D1_QUANT,Transform((((SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_ICMSRET+SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA)-SD1->D1_VALDESC)/SD1->D1_QUANT),"@E 99999,999.99"),Transform((SD1->D1_PICM),"@E 99.9"),left(SA2->A2_NOME,25),SA2->A2_EST})
			EndIf
			if Len(aCompras) >= nQtdLev
				Exit
			Endif
			DbSelectArea( "SD1" )
			DbSkip(-1)
		EndDo
		// Andre Luis Almeida - 13/02/2009 - Mostra ultimas vendas. Igual a Compras //
		DbSelectArea("SD2")
		DbSetOrder(6) // D2_FILIAL+D2_COD+D2_LOCAL+DTOS(D2_EMISSAO)+D2_NUMSEQ
		DbSeek( xFilial("SD2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") +  dtos(dDataBase+1) , .t. )
		If !Bof()
			DbSkip(-1)
		EndIf
		While !Bof() .and. SD2->D2_FILIAL == xFilial("SD2") .and. SB1->B1_COD == SD2->D2_COD
			DbSelectArea( "SF4" )
			DbSetOrder(1)
			DbSeek( xFilial("SF4") + SD2->D2_TES )
			If SF4->F4_ESTOQUE == "S" .and. SF4->F4_DUPLIC == "S" .and. SF4->F4_OPEMOV == "05"//05 = VENDA
				DbSelectArea( "SA1" )
				DbSetOrder(1)
				DbSeek( xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA )
				aadd(aVendas,{Transform(SD2->D2_EMISSAO,"@D"),SD2->D2_PRCVEN,SD2->D2_QUANT,Transform(SD2->D2_TOTAL+SD2->D2_DESPESA+SD2->D2_SEGURO+SD2->D2_VALFRE,"@E 99999,999.99"),Transform(SB1->B1_PICM,"@E 99.9"),subs(SA1->A1_NOME,1,25),SA1->A1_EST})
			EndIf
			if Len(aVendas) >= nQtdLev
				Exit
			Endif
			DbSelectArea( "SD2" )
			DbSkip(-1)
		EndDo
		if Len(aCompras) = 0
			aadd(aCompras,{"","","","","",""})
		Endif
		if Len(aVendas) = 0
			aadd(aVendas,{"","","","","",""})
		Endif
		Asort(aCompras,,,{|x,y| DTOS(CTOD(x[1])) > DTOS(CTOD(y[1])) })
		Asort(aVendas,,,{|x,y| DTOS(CTOD(x[1])) > DTOS(CTOD(y[1])) })
		DEFINE MSDIALOG oDescr FROM 000,000 TO 22,66 TITLE STR0192 OF oMainWnd
		@ 007,006 SAY STR0193 SIZE 60,08 OF oDescr PIXEL COLOR CLR_BLUE
		@ 007,030 SAY (cProd) SIZE 500,08 OF oDescr PIXEL COLOR CLR_BLUE
		@ 019,030 SAY (cPecRef) SIZE 500,08 OF oDescr PIXEL COLOR CLR_BLUE
		@ 002,003 TO 18,205 LABEL "" OF oDescr PIXEL
		@ 005,210 BUTTON oSair PROMPT (STR0172) OF oDescr SIZE 43,11 PIXEL  ACTION (oDescr:End())
		@ 022,003 LISTBOX oLbCom FIELDS HEADER (STR0194),(STR0195),(STR0197),(STR0198),(STR0199),(STR0201),(STR0202) COLSIZES 30,40,15,40,20,80,10 SIZE 258,070 OF oDescr PIXEL
		oLbCom:SetArray(aCompras)
		oLbCom:bLine := { || { aCompras[oLbCom:nAt,1] , aCompras[oLbCom:nAt,2] , aCompras[oLbCom:nAt,3] , aCompras[oLbCom:nAt,4] , aCompras[oLbCom:nAt,5] , aCompras[oLbCom:nAt,6] }}
		@ 096,003 LISTBOX oLbVen FIELDS HEADER (STR0194),(STR0196),(STR0197),(STR0198),(STR0199),(STR0013),(STR0202) COLSIZES 30,40,15,40,20,80,10 SIZE 258,070 OF oDescr PIXEL
		oLbVen:SetArray(aVendas)
		oLbVen:bLine := { || { aVendas[oLbVen:nAt,1] , aVendas[oLbVen:nAt,2] , aVendas[oLbVen:nAt,3] , aVendas[oLbVen:nAt,4] , aVendas[oLbVen:nAt,5] , aVendas[oLbVen:nAt,6]}}
		ACTIVATE MSDIALOG oDescr CENTER
	Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณFG_ABRETAB()บ Autor ณ Andre Luis Almeida บ Data ณ  10/09/07  บฑฑ
ฑฑฬอออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricaoณ Abertura das Tabelas mais utilizadas por modulo             บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_ABRETAB(cMod)
	Local cTab := "SA1/SA3/SB1/SB2/SB5/SBF/SBL/SBM/SD1/SD2/SD3/SF1/SF2/SF3/VAI/VE1/VE2/VE8/VEB/VEG/VEH/VEL/VFB/VS1/VS3/VS4/VS9/VSE/VSO/VSP/VZB/" // Auto-Pecas
	If cMod == "OFI"
		cTab := "SA1/SA3/SB1/SB2/SB5/SBF/SBL/SBM/SD1/SD2/SD3/SF1/SF2/SF3/VAI/VE1/VE2/VE8/VEB/VEG/VEH/VEL/VFB/VJ9/VO1/VO2/VO3/VO4/VO6/VO7/VOI/VOK/VS1/VS3/VS4/VS9/VSE/VSO/VSP/VZB/" // Oficina
	ElseIf cMod == "VEI"
		cTab := "SA1/SA3/SB1/SB2/SB5/SD1/SD2/SD3/SF1/SF2/SF3/VAI/VAS/VAT/VE1/VE2/VE8/VEB/VEH/VFB/VS9/VSO/VSP/VV0/VV1/VV2/VV6/VV9/VVA/VVC/VVF/VVR/VVT/VZB/" // Veiculos
	EndIf
	If left(GetNewPar("MV_ABRETAB","N"),1)=="S"
		Processa( {|| FS_ABRETAB(cTab) } )
	EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณFS_ABRETAB  บ Autor ณ Andre Luis Almeida บ Data ณ  10/09/07  บฑฑ
ฑฑฬอออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricaoณ Abre tabela										          บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ABRETAB(cTab)
	Local ni := 0
	Local nt := len(cTab)/4
	ProcRegua(nt)
	For ni := 1 to nt
		IncProc( STR0200+" "+substr(cTab,1,3) )
		DbSelectArea(substr(cTab,1,3))
		cTab := substr(cTab,5)
	Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ STATUSVEI    ณ Autor ณ ANDRE             ณ Data ณ 08/03/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Modifica o status do atendimento dependendo da operacao    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function STATUSVEI(cAtendimento,cOpcao)
	//Registro do atendimento
	DbSelectArea("VV9")
	DbSetOrder(1)
	if DbSeek(xFilial("VV9")+cAtendimento)
		RecLock("VV9",.f.)
		VV9->VV9_STATUS := cOpcao
		MsUnlock()
	Endif
	if cOpcao == "P"
		//Ponto de entrada para avisar vendedor que foi liberado
		If ExistBlock("PEDLIB011")
			ExecBlock("PEDLIB011",.f.,.f.)
		Endif
	Endif
	if cOpcao == "L"
		//Ponto de entrada para avisar vendedor que foi liberado
		If ExistBlock("AVILIB011")
			ExecBlock("AVILIB011",.f.,.f.)
		Endif
	Endif
Return

Function FG_VALFIS(cOpc)

	Local cont
	Default cOpc := "B"
	If !MaFisFound('NF')
		MsgStop(STR0275,STR0002)
		return .f.
	endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณIndica os valores do cabecalho               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	if cOpc == "B"
		MaFisAlt("NF_FRETE",M->VS1_VALFRE)
		MaFisAlt("NF_SEGURO",M->VS1_VALSEG)
		MaFisAlt("NF_DESPESA",M->VS1_DESACE)
		for cont := 1 to len(aCols)
			if !Empty(aCols[cont,FG_POSVAR("VS3_CODTES","aHeaderP")])
				MaFisalt("IT_TES",aCols[cont,FG_POSVAR("VS3_CODTES","aHeaderP")],cont)
			Endif
		Next
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta a tela de exibicao dos valores fiscais ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE MSDIALOG oDlg TITLE (STR0276) FROM 09,00 TO 28,80 //"Planilha Financeira"
	//oFolder := TFolder():New(001,001,aTitles,{"HEADER"},oDlg,,,, .T., .F.,315,140)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFolder 1                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MaFisRodape(1,oDlg,,{005,001,310,60},Nil,.T.)
	@ 070,005 SAY RetTitle("F2_FRETE")		SIZE 40,10 PIXEL OF oDlg
	@ 070,105 SAY RetTitle("F2_SEGURO")		SIZE 40,10 PIXEL OF oDlg
	@ 070,205 SAY RetTitle("F2_DESCONT")	SIZE 40,10 PIXEL OF oDlg
	@ 085,005 SAY RetTitle("F2_FRETAUT")	SIZE 40,10 PIXEL OF oDlg
	@ 085,105 SAY RetTitle("F2_DESPESA")	SIZE 40,10 PIXEL OF oDlg
	@ 085,205 SAY RetTitle("F2_VALFAT")		SIZE 40,10 PIXEL OF oDlg
	@ 070,050 MSGET MaFisRet(,"NF_FRETE")		PICTURE PesqPict("SF2","F2_FRETE",16,2)		SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 070,150 MSGET MaFisRet(,"NF_SEGURO")  	PICTURE PesqPict("SF2","F2_SEGURO",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 070,250 MSGET MaFisRet(,"NF_DESCONTO")	PICTURE PesqPict("SF2","F2_DESCONTO",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 085,050 MSGET MaFisRet(,"NF_AUTONOMO")	PICTURE PesqPict("SF2","F2_FRETAUT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 085,150 MSGET MaFisRet(,"NF_DESPESA")  PICTURE PesqPict("SF2","F2_DESPESA",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 085,250 MSGET MaFisRet(,"NF_BASEDUP")  PICTURE PesqPict("SF2","F2_VALFAT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 105,005 TO 106,310 PIXEL OF oDlg
	@ 110,005 SAY (STR0277)   SIZE 40,10 PIXEL OF oDlg //"Total da Nota"
	@ 110,050 MSGET MaFisRet(,"NF_TOTAL")      PICTURE Iif(cPaisLoc=="CHI",TM(0,16,NIL),PesqPict("SF2","F2_VALBRUT",16,2)) SIZE 50,07 PIXEL WHEN .F. OF oDlg
	@ 110,270 BUTTON (STR0172)	SIZE 040,11 FONT oDlg:oFont ACTION oDlg:End() OF oDlg PIXEL		//"Sair"

	ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFG_PLAFIN ณ Autor ณ Andre                 ณ Data ณ28.05.2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณFuncao de calculo dos impostos contidos no pedido de venda   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ nOpc                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณEsta funcao efetua os calculos de impostos (ICMS,IPI,ISS,etc)ณฑฑ
ฑฑณ          ณcom base nas funcoes fiscais, a fim de possibilitar ao usua- ณฑฑ
ฑฑณ          ณrio o valor de desembolso financeiro.                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FG_PLAFIN()

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_CONSRV บAutor  ณFabio               บ Data ณ  02/25/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta F3 dependendo da marca da concessionaria           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_CONSRV()

	Local cConsulta := "VO6   "
	Local nRecVO6   := 0

	If ReadVar() == "M->VS4_CODSER"
		dbSelectArea("VV1")
		dbSetOrder(2)
		dbSeek(xFilial("VV1")+M->VS1_CHASSI)
		DbSelectArea("VE1")
		DBSetOrder(1)
		DBSeek(xFilial("VE1")+M->VS1_CODMAR)
	endif

	If VE1->VE1_CODMAR == FG_MARCA("CHEVROLET",,.f.)
		OFIOC250()
	ElseIf VE1->VE1_CODMAR == FG_MARCA("SCANIA",,.f.)
		OFIOC210()
	Else
		If ReadVar() == "M->VS4_CODSER"
			cConsulta := "VOB   "
		ElseIf ReadVar() == "M->VSM_CODSER"
			cConsulta := "V6Q   "
		EndIf
		ASAVRET:=  SAVECPORETFWGET()
		IIF(CONPAD1(,,,cConsulta,___OGET:CRETF3,,,ReadVar(),___OGET, EVAL(___OGET:BSETGET) ),(nRecVO6 := VO6->(Recno()) ,___OGET:LMODIFIED:= .T., GETF3RETFWGET(___OGET:OWND,___OGET:HWND,cConsulta)),)
		ACPORET := ACLONE(ASAVRET)
		If nRecVO6 # 0
			VO6->( DbGoTo( nRecVO6	) )
		EndIf
	EndIf
	if VO6->(eof())
		&(ReadVar()) := SPACE(TamSX3("VS4_CODSER")[1])
		return .f.
	endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ VEIVC090 ณ Autor ณ  Andre Luis Almeida   ณ Data ณ 13/03/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Consulta Veiculos do Cliente (VV1)                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_CONSAC8(cPFilial,cPCodCli,cPLojCli)
	Private aAuxRot := aclone(aRotina)
	Private cCadastro:= ""
	Private aAC8Contat := {}
	Private aTELA[0][0]
	Private aGETS[0]
	Default cPFilial := ""
	Default cPCodCli := ""
	Default cPLojCli := ""
	aRotina := {{"","AxPesqui", 0 , 1 , , .F.},;		//"Pesquisar"
	{"","TK010Con", 0 , 2 , , .T.} }	 	//"Consulta"
	nOpc := 2
	nOpcG := 2
	Inclui := .t.
	Altera := .f.
	aCampos := {}
	If Empty(cPCodCli)
		MsgStop(STR0184,STR0002)
		Return()
	EndIf
	DbSelectArea("AC8")
	DbSetOrder(2)
	DbSeek( xFilial("AC8")+"SA1"+cPFilial+cPCodCli+cPLojCli)
	while !eof() .and.  Alltrim(xFilial("AC8")+"SA1"+cPFilial+cPCodCli+cPLojCli) == Alltrim(AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT)
		DbSelectArea("SU5")
		DbSetOrder(1)
		DbSeek(xFilial("SU5")+ AC8->AC8_CODCON)
		aAdd(aAC8Contat,{U5_CODCONT,U5_CONTAT,U5_DDD,U5_FONE,U5_CELULAR, SU5->(RECNO())})
		DbSelectArea("AC8")
		DbSkip()
	enddo
	if Len(aAc8Contat) == 0
		MsgStop(STR0185,STR0002)
		Return()
	EndIf
	cCodSU5 := ""
	nPosSU5 := 0
	DEFINE MSDIALOG oAC8Cont FROM 000,000 TO 020,70 TITLE (STR0186) OF oMainWnd
	@ 001,001 LISTBOX oLbSU5 FIELDS HEADER (STR0187),(STR0188),(STR0189),(STR0190),(STR0191) COLSIZES 20,80,10,40,40 SIZE 276,135 OF oAC8Cont PIXEL // ON DBLCLICK (cCodSU5:=aAc8Contat[oLbSU5:nAt,1], nPosSU5 :=aAc8Contat[oLbSU5:nAt,6], oAC8Cont:End())
	oLbSU5:SetArray(aAc8Contat)
	oLbSU5:bLine := { || { aAc8Contat[oLbSU5:nAt,1] ,;
	aAc8Contat[oLbSU5:nAt,2] ,;
	aAc8Contat[oLbSU5:nAt,3] ,;
	aAc8Contat[oLbSU5:nAt,4] ,;
	aAc8Contat[oLbSU5:nAt,5] }}

	DEFINE SBUTTON FROM 138,218 TYPE 1  ACTION  (cCodSU5:=aAc8Contat[oLbSU5:nAt,1], nPosSU5 :=aAc8Contat[oLbSU5:nAt,6], oAC8Cont:End()) ENABLE OF oAC8Cont
	DEFINE SBUTTON FROM 138,248 TYPE 2  ACTION (oAC8Cont:End()) ENABLE OF oAC8Cont
	ACTIVATE MSDIALOG oAC8Cont CENTER
	if Empty(cCodSU5)
		return
	endif
	DBSelectArea("SU5")
	DBGoto(nPosSU5)
	TK010Con()
	aRotina := aclone(aAuxRot)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFG_FILLIB ณ Autor ณ Andre                 ณ Data ณ 21/05/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณRetorna string com as empresas/filiais que o usuario pode   ณฑฑ
ฑฑณ          ณacessar                                                     ณฑฑ
ฑฑณ          ณ Parametros:                                                ณฑฑ
ฑฑณ          ณ 1 - retorna filiais (ex: 01/02/03)                         ณฑฑ
ฑฑณ          ณ 2 - retorna empresas/filiais (ex 0101/0102/0103)           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGeral                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_FilLib(nTipo)

	Local cont
	Local cFil := ""
	Local aEmprFil
	Default nTipo := 1

	If FindFunction( "FWLoadSM0" )
		aEmprFil := FWLOADSM0()
		For cont := 1 to len(aEmprFil)
			If aEmprFil[cont,11] // Empresa/Filial permitida para o usuario
				if nTipo == 1
					cFil := cFil + aEmprFil[cont,2]+'/'
				else
					cFil := cFil + aEmprFil[cont,1]+aEmprFil[cont,2]+'/'
				endif
			EndIf
		Next
	Else
		For cont := 1 to len(aEmpresas)
			if nTipo == 1
				cFil := cFil + substr(aEmpresas[cont],3,2)+'/'
			else
				cFil := cFil + substr(aEmpresas[cont],1,4)+'/'
			endif
		Next
	EndIf

Return(cFil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncaoณFG_PREGRUณAutorณ Andre Luis Almeida / Luis DelormeณDataณ30/05/08ณฑฑ
ฑฑรฤฤฤฤฤฤมฤฤฤยฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณFuncao a ser chamada na formula retorna o preco aplicado    ณฑฑ
ฑฑณ          ณpor grupo                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGeral                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_PREGRU(cFormDef)
	Local nRetVal := 0
	Default cFormDef := ""
	DBSelectArea("SBM")
	DBSetOrder(1)
	DBSeek(xFilial("SBM")+SB1->B1_GRUPO)
	If !Empty(SBM->BM_FORMUL)
		nRetVal := FG_FORMULA(SBM->BM_FORMUL)
	ElseIf cFormDef <> ""
		nRetVal := &(cFormDef)
	Else
		nRetVal := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1")
	EndIf
Return(nRetVal)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncaoณFG_VPREGRUณAutorณAndre Luis Almeida / Luis DelormeณDataณ02/06/08ณฑฑ
ฑฑรฤฤฤฤฤฤมฤฤฤยฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณFuncao a ser chamada no valid do grupo. Verifica se a funcaoณฑฑ
ฑฑณ          ณFG_PREGRU foi chamada de forma errada (recursividade inf.)  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGeral                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_VPREGRU()
	Local lRet := .t.
	DbSelectArea("VEG")
	DbSetOrder(1)
	If DbSeek(xfilial("VEG")+M->BM_FORMUL)
		If "FG_PREGRU" $ VEG_FORMUL .or. "FG_FORMULA" $ VEG_FORMUL
			lRet:= .f.
			MsgStop(STR0237+" FG_PREGRU() "+STR0238+" FG_FORMULA().",STR0239)//A Formula escolhida nao pode conter a funcao # ou # Atencao
		EndIf
	endif
return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncaoณFG_UPDMIL ณAutorณAndre Luis Almeida / Luis DelormeณDataณ02/06/08ณฑฑ
ฑฑรฤฤฤฤฤฤมฤฤฤยฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Funcao chamada toda vez que o usuario entra no Modulo de   ณฑฑ
ฑฑณ          ณ VEICULOS, PECAS ou OFICINA, para validar se foi rodado     ณฑฑ
ฑฑณ          ณ o UPD referente ao Modulo.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณGeral                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_UPDMIL(cTipo)
	Local lRet := .t.
	Local cUPDVEI := "     "
	Local cUPDPEC := "     "
	Local cUPDOFI := "     "
	Local cUPD    := ""
	If !SX6->(DbSeek(xFilial("SX6")+"MV_UPDMIL "))
		lRet := .f.
	Else
		If cTipo == "VEI"
			if !Empty(cUPDVEI)
				If !(cUPDVEI $ SX6->X6_CONTEUD)
					lRet := .f.
				EndIf
			endif
		ElseIf cTipo == "PEC"
			if !Empty(cUPDPEC)
				If !(cUPDPEC $ SX6->X6_CONTEUD)
					lRet := .f.
				EndIf
			endif
		Else//If cTipo == "OFI"
			if !Empty(cUPDOFI)
				If !(cUPDOFI $ SX6->X6_CONTEUD)
					lRet := .f.
				EndIf
			endif
		EndIf
	EndIf
	If !lRet
		If cTipo == "VEI"
			cUPD := cUPDVEI
		ElseIf cTipo == "PEC"
			cUPD := cUPDPEC
		Else//If cTipo == "OFI"
			cUPD := cUPDOFI
		EndIf
		if Empty(cUPD)
			lRet := .t.
		else
			MsgAlert(STR0240+cUPD+"'!",STR0239)//Dicionario de dados desatualizado. Favor rodar o 'U_UPD # Atencao
		endif
	EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao   ณFG_POSVEI(x,y)ณ Autor ณ Andre Luis Almeida ณ Data ณ 06/10/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricaoณ Posicionamento do veiculo de diversas maneiras no cad. VV1  ณฑฑ
ฑฑณ         ณ x - variavel para posicionamento. ex:"M->VVG_CHASSI"        ณฑฑ
ฑฑณ         ณ y - campo de retorno para variavel "x". ex:"VV1->VV1_CHASSI"ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSequenciaณ 1 - Placa ou Chassi ou Frota ( VV1_PLAVEI / VV1_CHASSI /...)ณฑฑ
ฑฑณ   da    ณ 2 - Chassi Interno ( VV1_CHAINT )                           ณฑฑ
ฑฑณPesquisa ณ 3 - Serie ( VV1_SERMOT )                                    ณฑฑ
ฑฑณ         ณ 4 - Nome do Cliente                                         ณฑฑ
ฑฑณ         ณ 5 - Modelo do Veiculo                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_POSVEI(cCampo,cRet)
	Local lRet     := .f. // Retorno Funcao
	Local lVerMod  := .t. // Verifica Modelo
	Local cQAlVV1  := "SQLVV1"
	Local cQAlSA1  := "SQLSA1"
	Local cQAlVV2  := "SQLVV2"
	Local cQuery   := ""
	Local cQuerySA1:= ""
	Local cQueryVV2:= ""
	Local cQuerAux := ""
	Local lAchouVV1:= .f.
	Local aVV1     := {}
	Local cPesq    := &(cCampo)
	Local _cPlaVei := ""
	Local _cChassi := ""
	Local _cCodFro := ""
	Local _cChaInt := ""
	Local _cSerMot := ""
	Local nTam     := 0
	Local aSA1     := {}
	Local aVV2     := {}

	Default cRet   := "VV1->VV1_CHASSI"
	If Empty(cPesq)
		Return(.t.)
	EndIf
	//
	nTam := TamSX3("VV1_CHASSI")[1]
	_cChassi := left(Alltrim(cPesq)+space(nTam),nTam)
	//
	nTam := TamSX3("VV1_PLAVEI")[1]
	If nTam >= Len(Alltrim(cPesq))
		_cPlaVei := left(Alltrim(cPesq)+space(nTam),nTam)
	Else
		_cPlaVei := ".f."
	EndIf
	nTam := TamSX3("VV1_CODFRO")[1]
	If nTam >= Len(Alltrim(cPesq))
		_cCodFro := left(Alltrim(cPesq)+space(nTam),nTam)
	Else
		_cCodFro := ".f."
	EndIf
	nTam := TamSX3("VV1_CHAINT")[1]
	If nTam >= Len(Alltrim(cPesq))
		_cChaInt := left(Alltrim(cPesq)+space(nTam),nTam)
	Else
		_cChaInt := ".f."
	EndIf
	nTam := TamSX3("VV1_SERMOT")[1]
	If nTam >= Len(Alltrim(cPesq))
		_cSerMot := left(Alltrim(cPesq)+space(nTam),nTam)
	Else
		_cSerMot := ".f."
	EndIf
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	cQuerAux := "SELECT DISTINCT VV1.VV1_CHASSI , VV1.VV1_CHAINT , VV1.VV1_PLAVEI , VV1.VV1_FABMOD , VV1.VV1_CODFRO , VV1.VV1_SERMOT , VV1.VV1_SITVEI , "
	cQuerAux += "VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV2.VV2_DESMOD , VV1.VV1_CORVEI , VVC.VVC_DESCRI , VV1.VV1_PROATU , VV1.VV1_LJPATU , SA1.A1_NOME "
	cQuerAux += "FROM "+RetSqlName("VV1")+" VV1 "
	cQuerAux += "LEFT JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.VV2_SEGMOD=VV1.VV1_SEGMOD AND VV2.D_E_L_E_T_=' ' ) "
	cQuerAux += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VV1.VV1_PROATU AND SA1.A1_LOJA=VV1.VV1_LJPATU AND SA1.D_E_L_E_T_=' ' ) "
	cQuerAux += "LEFT JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
	cQuerAux += "WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.D_E_L_E_T_=' 'AND "
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////
	// Pesquisa pela Placa ou Chassi ou Frota   //
	//////////////////////////////////////////////
	SBM->(DbSetOrder(1))
	SBM->(MsSeek( xFilial("SBM") + left(Alltrim(GetNewPar("MV_GRUVEI","VEI"))+space(4),4) ))
	cQuery := cQuerAux + "( "
	If _cPlaVei <> ".f."
		cQuery += "VV1.VV1_PLAVEI='"+_cPlaVei+"' OR "
	EndIf
	cQuery += "VV1.VV1_CHASSI='"+_cChassi+"' OR "
	If SBM->BM_LENREL # 99
		cQuery += "VV1.VV1_CHASSI LIKE '%"+Alltrim(cPesq)+"' OR VV1.VV1_CHASSI LIKE '%"+Alltrim(cPesq)+" %' "
	Else
		cQuery += "VV1.VV1_CHASSI LIKE '%"+Alltrim(cPesq)+"%' "
	EndIf
	If _cCodFro <> ".f."
		cQuery += " OR VV1.VV1_CODFRO='"+_cCodFro+"' "
	EndIf
	cQuery += ") "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. )
	If ( cQAlVV1 )->( Eof())
		( cQAlVV1 )->( dbCloseArea() )
	Else
		lAchouVV1 := .t.
	EndIf
	If !lAchouVV1 .and. _cChaInt <> ".f." // caso nao encontre
		//////////////////////////////////////////
		// Pesquisa pelo Chassi Interno         //
		//////////////////////////////////////////
		cQuery := cQuerAux + " VV1.VV1_CHAINT='"+_cChaInt+"' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. )
		If ( cQAlVV1 )->( Eof())
			( cQAlVV1 )->( dbCloseArea() )
		Else
			lAchouVV1 := .t.
		EndIf
	EndIf
	If !lAchouVV1 .and. _cSerMot <> ".f." // caso nao encontre
		//////////////////////////////////////////
		// Pesquisa pela Serie Motor            //
		//////////////////////////////////////////
		cQuery := cQuerAux + " VV1.VV1_SERMOT='"+_cSerMot+"' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. )
		If ( cQAlVV1 )->( Eof())
			( cQAlVV1 )->( dbCloseArea() )
		Else
			lAchouVV1 := .t.
		EndIf
	EndIf
	If !lAchouVV1 // caso nao encontre
		//////////////////////////////////////////
		// Pesquisa pelo Nome do Cliente        //
		//////////////////////////////////////////
		cQuerySA1 := "SELECT SA1.A1_COD , SA1.A1_LOJA , SA1.A1_NOME , SA1.A1_CGC, "
		cQuerySA1 += "A1_END, A1_MUN CIDADE, A1_EST UF "
		cQuerySA1 += "FROM "+RetSqlName("SA1")+" SA1 "
		cQuerySA1 += "WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_NOME LIKE '%"+Alltrim(cPesq)+"%' AND SA1.D_E_L_E_T_=' ' ORDER BY SA1.A1_NOME"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuerySA1 ), cQAlSA1, .F., .T. )
		Do While !( cQAlSA1 )->( Eof())
			Aadd(aSA1,{;
				( cQAlSA1 )->( A1_COD ),;
				( cQAlSA1 )->( A1_LOJA ),;
				AllTrim(( cQAlSA1 )->( A1_NOME )),;
				Transform(( cQAlSA1 )->( A1_CGC ),IIf(Len(Alltrim(( cQAlSA1 )->( A1_CGC )))>12,"@R 99.999.999/9999-99","@R 999.999.999-99")),;
				AllTrim(( cQAlSA1 )->( A1_END )),;
				AllTrim(( cQAlSA1 )->( CIDADE )),;
				( cQAlSA1 )->( UF )})
			( cQAlSA1 )->( DbSkip() )
		EndDo
		( cQAlSA1 )->( dbCloseArea() )
		If len(aSA1)>0
			If FG_POSSA1(aSA1)
				lVerMod := .f.
				DbSelectarea("SA1")
				cQuery := cQuerAux + "VV1.VV1_PROATU='"+SA1->A1_COD+"' AND VV1.VV1_LJPATU='"+SA1->A1_LOJA+"'"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. )
				If ( cQAlVV1 )->( Eof())
					( cQAlVV1 )->( dbCloseArea() )
				Else
					lAchouVV1 := .t.
				EndIf
			EndIf
		EndIf
	EndIf
	If !lAchouVV1 .and. lVerMod // caso nao encontre
		//////////////////////////////////////////
		// Pesquisa pelo Modelo do Veiculo      //
		//////////////////////////////////////////
		cQueryVV2 := "SELECT VV2.VV2_CODMAR , VV2.VV2_MODVEI , VV2.VV2_DESMOD FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_DESMOD LIKE '%"+Alltrim(cPesq)+"%' AND VV2.D_E_L_E_T_=' ' ORDER BY VV2.VV2_CODMAR , VV2.VV2_DESMOD"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryVV2 ), cQAlVV2, .F., .T. )
		Do While !( cQAlVV2 )->( Eof())
			Aadd(aVV2,{ ( cQAlVV2 )->( VV2_CODMAR ) , ( cQAlVV2 )->( VV2_MODVEI ) , ( cQAlVV2 )->( VV2_DESMOD ) })
			( cQAlVV2 )->( DbSkip() )
		EndDo
		( cQAlVV2 )->( dbCloseArea() )
		If len(aVV2)>0
			If FG_POSVV2(aVV2)
				dbSelectarea("VV2")
				cQuery := cQuerAux + "VV1.VV1_CODMAR='"+VV2->VV2_CODMAR+"' AND VV1.VV1_MODVEI='"+VV2->VV2_MODVEI+"' AND VV1.VV1_SEGMOD='"+VV2->VV2_SEGMOD+"'"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1, .F., .T. )
				If ( cQAlVV1 )->( Eof())
					( cQAlVV1 )->( dbCloseArea() )
				Else
					lAchouVV1 := .t.
				EndIf
			EndIf
		EndIf
	EndIf
	If lAchouVV1
		/////////////////////////////////////////////
		// Monta Vetor com os Veiculos encontrados //
		/////////////////////////////////////////////
		Do While !( cQAlVV1 )->( Eof())
			Aadd(aVV1,{	( cQAlVV1 )->( VV1_CHAINT ),;
			( cQAlVV1 )->( VV1_PLAVEI ),;
			( cQAlVV1 )->( VV1_CHASSI ),;
			( cQAlVV1 )->( VV1_CODMAR )+" "+IIf(!Empty(( cQAlVV1 )->( VV2_DESMOD )),( cQAlVV1 )->( VV2_DESMOD ),( cQAlVV1 )->( VV1_MODVEI )),;
			left(IIf(!Empty(( cQAlVV1 )->( VVC_DESCRI )),( cQAlVV1 )->( VVC_DESCRI ),( cQAlVV1 )->( VV1_CORVEI )),12),;
			( cQAlVV1 )->( VV1_FABMOD ),;
			X3CBOXDESC("VV1_SITVEI",( cQAlVV1 )->( VV1_SITVEI )),;
			( cQAlVV1 )->( VV1_CODFRO ),;
			( cQAlVV1 )->( VV1_SERMOT ),;
			( cQAlVV1 )->( VV1_PROATU )+"-"+( cQAlVV1 )->( VV1_LJPATU )+" "+left(( cQAlVV1 )->( A1_NOME ),25)})
			( cQAlVV1 )->( DbSkip() )
		EndDo
		( cQAlVV1 )->( dbCloseArea() )
	EndIf
	DbSelectArea("VV1")
	DbSetOrder(1)
	If Len(aVV1) > 0
		If Len(aVV1)==1
			DBSeek(xFilial("VV1")+aVV1[1,1])
			lRet := .t.
		Else
			lRet := FG_POSVV1(aVV1)
		EndIf
	EndIf
	If lRet
		&(cCampo) := &(cRet)
	EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณFG_POSVV1บ Autor ณ Luis Delorme       บ Data ณ  06/06/08   บฑฑ
ฑฑฬอออออออออุอออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบParametroณ Recebe vetor contendo informacoes do Veiculo              บฑฑ
ฑฑบ aVV1[n,01]ณ Chassi.Int.                                             บฑฑ
ฑฑบ aVV1[n,02]ณ Placa                                                   บฑฑ
ฑฑบ aVV1[n,03]ณ Chassi                                                  บฑฑ
ฑฑบ aVV1[n,04]ณ Marca/Modelo                                            บฑฑ
ฑฑบ aVV1[n,05]ณ Cor                                                     บฑฑ
ฑฑบ aVV1[n,06]ณ Fab/Mod                                                 บฑฑ
ฑฑบ aVV1[n,07]ณ Situacao do Veiculo ( Estoque / Transito / ... )        บฑฑ
ฑฑบ aVV1[n,08]ณ Frota                                                   บฑฑ
ฑฑบ aVV1[n,09]ณ Serie                                                   บฑฑ
ฑฑบ aVV1[n,10]ณ Prop.Atual                                              บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_POSVV1(aVV1)
	Local lRet      := .f.
	Local nLinha    := 0
	Local nCntFor   := 0
	Local aObjects  := {} , aInfo := {}, aPos := {}
	Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Local aBotARel  := {} // Botoes Acoes Relacionadas
	Local cFiltrar  := space(20)
	Local aFiltrar  := {"1="+STR0302,"2="+STR0301,"3="+STR0300} // "Marca/Modelo" , "Chassi" , "Placa"
	Local cFil      := space(50)
	Private aVV1Fil := aClone(aVV1) // Vetor somente com os Registros do Filtro
	Private aVV1Tot := aClone(aVV1) // Vetor com Todos os Registros
	AADD(aBotARel, {"E5",{|| VEIVC140(aVV1Fil[oLbVV1:nAt,3], aVV1Fil[oLbVV1:nAt,1]) },( STR0297 )} ) // Rastreamento
	If len(aVV1Fil) > 0
		AAdd( aObjects, { 01 , 26 , .T. , .F. } ) // Filtro
		AAdd( aObjects, { 01 , 10 , .T. , .T. } ) // ListBox

		// Fator de reducao de 90%
		For nCntFor := 1 to Len(aSizeHalf)
			aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.9)
		Next
		aInfo := {aSizeHalf[1] , aSizeHalf[2] , aSizeHalf[3] , aSizeHalf[4] , 2 , 2 }
		aPos := MsObjSize( aInfo, aObjects )
		DEFINE MSDIALOG oVV1Obj FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0241 OF oMainWnd PIXEL // Veiculos
		@ aPos[1,1],aPos[1,2] TO aPos[1,3],aPos[1,4] LABEL "" OF oVV1Obj PIXEL

		@ aPos[1,1]+009 , aPos[1,2]+005 SAY STR0303 OF oVV1Obj PIXEL COLOR CLR_BLUE
		@ aPos[1,1]+008 , aPos[1,2]+025 MSCOMBOBOX oFiltrar  VAR cFiltrar ITEMS aFiltrar SIZE 90,10 OF oVV1Obj PIXEL
		@ aPos[1,1]+008 , aPos[1,2]+120 MSGET oFil VAR cFil SIZE 150,08 OF oVV1Obj PIXEL
		@ aPos[1,1]+008 , aPos[1,2]+275 BUTTON oBtFiltra PROMPT "Ok" OF oVV1Obj SIZE 25,10 PIXEL ACTION Processa( {|| FS_FILVV1(cFiltrar,cFil)}, "" , "", .T.)

		@ aPos[2,1],aPos[2,2] LISTBOX oLbVV1 FIELDS HEADER STR0242,STR0243,STR0244,STR0245,STR0246,STR0247,STR0298,STR0291,STR0296,STR0248 ; // Chassi.Int. / Placa / Chassi / Marca/Modelo / Cor / Fab/Mod / Situacao / Frota / Serie /Prop.Atual
													COLSIZES 30,33,65,65,40,30,35,35,35,150 SIZE @ aPos[2,4],aPos[2,3]-aPos[2,1] OF oVV1Obj PIXEL ON DBLCLICK ( nLinha := oLbVV1:nAt , lRet:=.t. , oVV1Obj:End() )
		oLbVV1:SetArray(aVV1Fil)
		oLbVV1:bLine := { || { 	aVV1Fil[oLbVV1:nAt,1] , ;
				 				Transform(aVV1Fil[oLbVV1:nAt,2],PesqPict("VV1","VV1_PLAVEI")) , ;
								aVV1Fil[oLbVV1:nAt,3] ,;
								aVV1Fil[oLbVV1:nAt,4] ,;
								aVV1Fil[oLbVV1:nAt,5] ,;
								Transform(aVV1Fil[oLbVV1:nAt,6],PesqPict("VV1","VV1_FABMOD")) ,;
								aVV1Fil[oLbVV1:nAt,7] ,;
								aVV1Fil[oLbVV1:nAt,8] ,;
								aVV1Fil[oLbVV1:nAt,9] ,;
								aVV1Fil[oLbVV1:nAt,10] }}
		oLbVV1:bHeaderClick := {|oObj,nCol| FS_ORDPVV1(nCol,aVV1Fil) , } // Ordenar Listbox
		ACTIVATE MSDIALOG oVV1Obj ON INIT EnchoiceBar(oVV1Obj,{ || ( nLinha := oLbVV1:nAt , lRet := .t. , oVV1Obj:End() ) }, { || oVV1Obj:End() },,aBotARel) CENTER
		DbSelectArea("VV1")
		DbSetOrder(1)
		If lRet .and. nLinha > 0
			DbSeek(xFilial("VV1")+aVV1Fil[nLinha,1])
		EndIf
	EndIf
Return(lRet)
//////////////////////////////////
// Ordernar ListBox de Veiculos //
//////////////////////////////////
Static Function FS_ORDPVV1(nCol,aVV1Fil)
	Asort(aVV1Fil,,,{|x,y| x[nCol] < y[nCol] })
	oLbVV1:Refresh()
	oLbVV1:SetFocus()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณFG_POSSA1บ Autor ณ Rafael             บ Data ณ  16/10/08   บฑฑ
ฑฑฬอออออออออุอออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบParametroณ Recebe vetor contendo informacoes do Cliente              บฑฑ
ฑฑบ aSA1[,1]ณ Codigo                                                    บฑฑ
ฑฑบ aSA1[,2]ณ Loja                                                      บฑฑ
ฑฑบ aSA1[,3]ณ Nome                                                      บฑฑ
ฑฑบ aSA1[,4]ณ CPF/CNPJ                                                  บฑฑ
ฑฑบ aSA1[,5]ณ Endere็o                                                  บฑฑ
ฑฑบ aSA1[,6]ณ Cidade                                                    บฑฑ
ฑฑบ aSA1[,7]ณ Estado                                                    บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_POSSA1(aSA1)
	Local lRet    := .f.
	Local nLinha    := 0
	Local nCntFor   := 0
	Local aObjects  := {} , aInfo := {}, aPos := {}
	Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox dos Veiculos
	// Fator de reducao de 0.7
	For nCntFor := 1 to Len(aSizeHalf)
		aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.7)
	Next
	aInfo := {aSizeHalf[1] , aSizeHalf[2] , aSizeHalf[3] , aSizeHalf[4] , 2 , 2 }
	aPos := MsObjSize( aInfo, aObjects )
	DEFINE MSDIALOG oSA1Obj FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0249 OF oMainWnd PIXEL // Clientes
	@ aPos[1,1]+005,aPos[1,2] LISTBOX oLbSA1 FIELDS HEADER STR0250,STR0251,STR0252,STR0253,STR0314,STR0315,STR0316 ;	// Codigo / Loja / Nome / CPF/CNPJ / Endere็o / Cidade / Estado
	COLSIZES 25,15,160,40 SIZE @ aPos[1,4]-001,aPos[1,3]-015 OF oSA1Obj PIXEL ON DBLCLICK ( nLinha := oLbSA1:nAt , lRet:=.t. , oSA1Obj:End() )
	oLbSA1:SetArray(aSA1)
	oLbSA1:bLine := { || { aSA1[oLbSA1:nAt,1] , aSA1[oLbSA1:nAt,2] , aSA1[oLbSA1:nAt,3] , aSA1[oLbSA1:nAt,4], aSA1[oLbSA1:nAt,5], aSA1[oLbSA1:nAt,6], aSA1[oLbSA1:nAt,7] }}
	ACTIVATE MSDIALOG oSA1Obj ON INIT EnchoiceBar(oSA1Obj,{ || ( nLinha := oLbSA1:nAt , lRet := .t. , oSA1Obj:End() ) }, { || oSA1Obj:End() },,) CENTER
	DbSelectArea("SA1")
	DbSetOrder(1)
	If lRet .and. nLinha > 0
		DbSeek(xFilial("SA1")+aSA1[nLinha,1]+aSA1[nLinha,2])
	EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณFG_POSVV2บ Autor ณ Andre Luis Almeida บ Data ณ  30/10/08   บฑฑ
ฑฑฬอออออออออุอออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบParametroณ Recebe vetor contendo informacoes do Modelo               บฑฑ
ฑฑบ aVV2[,1]ณ Marca                                                     บฑฑ
ฑฑบ aVV2[,2]ณ Modelo                                                    บฑฑ
ฑฑบ aVV2[,3]ณ Descricao                                                 บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_POSVV2(aVV2)
	Local lRet    := .f.
	Local nLinha    := 0
	Local nCntFor   := 0
	Local aObjects  := {} , aInfo := {}, aPos := {}
	Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox dos Veiculos
	// Fator de reducao de 0.7
	For nCntFor := 1 to Len(aSizeHalf)
		aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.7)
	Next

	aInfo := {aSizeHalf[1] , aSizeHalf[2] , aSizeHalf[3] , aSizeHalf[4] , 2 , 2 }
	aPos := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oVV2Obj FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0254 OF oMainWnd PIXEL // Modelos

	@ aPos[1,1]+005,aPos[1,2] LISTBOX oLbVV2 FIELDS HEADER STR0255,STR0256,STR0257 ;	// Marca / Modelo / Descricao
		COLSIZES 25,15,150 SIZE @ aPos[1,4]-001,aPos[1,3]-015 OF oVV2Obj PIXEL ON DBLCLICK ( nLinha := oLbVV2:nAt , lRet:=.t. , oVV2Obj:End() )
		oLbVV2:SetArray(aVV2)
		oLbVV2:bLine := { || { aVV2[oLbVV2:nAt,1] , aVV2[oLbVV2:nAt,2] , aVV2[oLbVV2:nAt,3] }}

	ACTIVATE MSDIALOG oVV2Obj ON INIT EnchoiceBar(oVV2Obj,{ || ( nLinha := oLbVV2:nAt , lRet := .t. , oVV2Obj:End() ) }, { || oVV2Obj:End() },,) CENTER
	
	DbSelectArea("VV2")
	DbSetOrder(1)
	If lRet .and. nLinha > 0
		DbSeek(xFilial("VV2")+aVV2[nLinha,1]+aVV2[nLinha,2])
	EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFG_CHEREV บAutor  ณThiago              บ Data ณ  08/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao usada para validar se a revisao do veiculo esta exce-บฑฑ
ฑฑบ          ณdida do limite permitido.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FG_CHEREV(cMarPes,cCodSer,cSrvAdi,cCodApl,cContro,lMsg)

	Default cMarPes := VV1->VV1_CODMAR
	Default cCodSer := VO6->VO6_CODSER
	Default cSrvAdi := VJ9->VJ9_SRVADI
	Default cCodApl := Substr(VV1->VV1_CHASSI,4,4)+Space(2)
	Default cContro := VJ9->VJ9_CONTRO
	Default lMsg    := .t.
	if VO6->VO6_AGRSER <> "S"       //Antonio - o operador logico estava invertido - Fnc 14308
		Return(.t.)                  //          somente passar servicos de revisao onde VO6_AGRSER=="S"
	Endif

	If VO6->(FieldPos("VO6_KMINI")) # 0 .AND. VO6->(FieldPos("VO6_KMFIN")) # 0  .AND. VO6->(FieldPos("VO6_LIMITE")) # 0
		if FUNNAME() $ "OFIOM030,OFIOM010"
			DbSelectArea("VOI")
			DbSetOrder(1)
			DbSeek( xFilial("VOI") + M->VO4_TIPTEM)
		Else
			DbSelectArea("VOI")
			DbSetOrder(1)
			DbSeek( xFilial("VOI") + M->VS1_TIPTEM)
		Endif
		//			if VOI->VOI_SITTPO == "4"

		if FUNNAME() $ "OFIOM030,OFIOM010"
			DbSelectArea("VVL")
			DbSetOrder(1)
			DbSeek( xFilial("VVL") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD )
			If (VO1->VO1_KILOME < VO6->VO6_KMINI .or. VO1->VO1_KILOME > VO6->VO6_KMFIN .and. !Empty(VO6->VO6_KMFIN)) .or. /***/((VV1->VV1_DATVEN+VVL->VVL_PERGAR+VO6->VO6_LIMITE < ddatabase) )  // * antonio - alterado operador logigo - fnc 14308
				MsgStop(STR0233+" - "+VO6->VO6_CODSER,STR0002)                                                                                                        //              ou uma situacao ou outra
				Return(.f.)
			Endif
		Else
			DbSelectArea("VVL")
			DbSetOrder(1)
			DbSeek( xFilial("VVL") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD )
			if !Empty(M->VS4_CODSER) .and. (M->VS1_KILOME < VO6->VO6_KMINI .or. M->VS1_KILOME > VO6->VO6_KMFIN  .and. !Empty(VO6->VO6_KMFIN)) .or. ((VV1->VV1_DATVEN+VVL->VVL_PERGAR+VO6->VO6_LIMITE < ddatabase) )
				MsgStop(STR0233+" - "+VO6->VO6_CODSER,STR0002)
				//			aCols[n,4] := ""
				Return(.f.)
			Endif
		Endif
	Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TELDP   บAutor  ณManoel Filho       บ Data ณ  20/05/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua alteracao no SE1,VS9 e SE5 (se houver bx Automat.)   บฑฑ
ฑฑบ          ณ para retencao do PIS/COFINS/CSLL quando Servicos            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FM_TELDP()

	Local nOpcaTD :=0
	nAcreBol  := 0
	M->VS1_DESACE := 0

	//cDepto := M->VS1_DEPTO // Criada a Tabela 99 no SX5 (Departamento de PECAS)

	while .t.

		DEFINE MSDIALOG oDlgTD TITLE (STR0258) FROM  1,10 TO 6,65 OF oMainWnd//Departamento

		@ 17, 004 SAY (STR0258)  OF odlgTD PIXEL COLOR CLR_BLACK //Departamento
		@ 17, 044 MSGET oDepto VAR cDepto PICTURE "!!" F3 "99" VALID (!Empty(cDepto) .and. ExistCpo("SX5","99"+cDepto) ) SIZE 40,4  OF odlgTD PIXEL COLOR CLR_BLACK

		ACTIVATE MSDIALOG oDlgTD CENTER ON INIT EnchoiceBar(oDlgTD,{||nOpcaTD := 1,oDlgTD:End()},{||nOpcaTD := 2,If(!Empty(cDepto),oDlgTD:End(),.f.)})

		If Empty(cDepto)
			loop
		Else
			If nOpcaTD == 1
				Return .t.
			Else
				Return .f.
			Endif
		Endif

	Enddo

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FILVV1  บAutor  ณThiago			  บ Data ณ  27/03/17   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua filtro na funcao de relacionar o chassi do veiculo.  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_FILVV1(cFiltrar,cFil)

Local nPos      := 0
Local nColFiltro

aVV1Fil := {} // Limpar Vetor com os Filtros

If Empty(cFil)
	aVV1Fil := aClone(aVV1Tot) // Todos os Registros
Else
	Do Case
		Case cFiltrar == "1" ; nColFiltro := 4 // "Marca/Modelo"
		Case cFiltrar == "2" ; nColFiltro := 3 // "Chassi"
		Case cFiltrar == "3" ; nColFiltro := 2 // "Placa"
	End Do
	For nPos := 1 to Len(aVV1Tot)
		if Alltrim(cFil) $ aVV1Tot[ nPos , nColFiltro ]
			Aadd(aVV1Fil, aCLone(aVV1Tot[ nPos ]) )
		EndIf
	Next nPos
Endif
if Len(aVV1Fil) == 0
	MsgInfo(STR0304)
	aVV1Fil := aClone(aVV1Tot)
Endif
oLbVV1:SetArray(aVV1Fil)
oLbVV1:bLine := { || { 	aVV1Fil[oLbVV1:nAt,1] , ;
						Transform(aVV1Fil[oLbVV1:nAt,2],PesqPict("VV1","VV1_PLAVEI")) , ;
						aVV1Fil[oLbVV1:nAt,3] ,;
						aVV1Fil[oLbVV1:nAt,4] ,;
						aVV1Fil[oLbVV1:nAt,5] ,;
						Transform(aVV1Fil[oLbVV1:nAt,6],PesqPict("VV1","VV1_FABMOD")) ,;
						aVV1Fil[oLbVV1:nAt,7] ,;
						aVV1Fil[oLbVV1:nAt,8] ,;
						aVV1Fil[oLbVV1:nAt,9] ,;
						aVV1Fil[oLbVV1:nAt,10] }}
oLbVV1:Refresh()
Return(.t.)
