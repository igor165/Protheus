#include "PMSA103.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA103  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutecao de Tarefas do Orcamento de Projetos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fabio Jadao   ³23/06/03³065006³Inclusao do ponto de entrada A103LINOK1   ³±±
±±³              ³        ³      ³para validacao da linha do aCols no orca- ³±±
±±³              ³        ³      ³mento.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PMSA103(nCallOpcx,aGetCpos,cNivTrf,lRefresh)

Local nRecAF2
Local lContinua		:= .T.

PRIVATE cCadastro	:= STR0001 //"Tarefas do Orcamento"
PRIVATE aRotina := MenuDef()

Default lRefresh := .F.

SaveInter()
If AMIIn(44) .And. !PMSBLKINT()
	If nCallOpcx == Nil
		mBrowse(6,1,22,75,"AF2")
	Else
		If nCallOpcx == 4 .Or. nCallOpcx == 5
			lContinua	:= !VldOrcPMS()
		Endif
		If lContinua
			cNivTrf := Soma1(cNivTrf)
			nRecAF2 := PMS103Dlg("AF2",AF2->(RecNo()),nCallOpcx,,,aGetCpos,cNivTrf,@lRefresh)
		Else
			Help(Nil, Nil, "VLDORCPMS", Nil,;
				STR0032,; // #"Esta operação não pode ser realizada, pois este orçamento foi gerado a partir de uma Proposta Comercial"
			  	1, 0, NIL, NIL, NIL, NIL, NIL,;
			  	{STR0033}) // #"Execute esta operação a partir da Proposta Comercial/Serviço."
		Endif
	EndIf
EndIf
RestInter()
Return nRecAF2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS103Dlg³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ³±±
±±³          ³ de Tarefas de Orcamentos de Projetos.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS103Dlg(cAlias,nReg,nOpcx,xreserv,yreserv,aGetCpos,cNivTrf,lRefresh)

Local cCombo1		:= ''
Local nMoedaVis		:= 1
Local aList			:= {{SPACE(2),SPACE(55),SPACE(5),0,0}}
Local aLegenda		:= {''}
Local oDlg

Local l103Inclui	:= .F.
Local l103Visual	:= .F.
Local l103Altera	:= .F.
Local l103Exclui	:= .F.
Local lContinua		:= .T.
Local nOpc			:= 0
Local aSize			:= {}
Local aObjects		:= {}
Local aInfo 		:= {}
Local aPosObj       := {}
Local aCombo1		:= {}
Local aAuxCombo1	:= {}
Local aGetEnch
Local aButtons  := {}
Local aPages	:= {}
Local aRecAF3	:= {}
Local aRecAF4	:= {}
Local aRecAF5	:= {}
Local aRecAF7	:= {}
Local aRecAJ1	:= {}
Local aTitles	:= { STR0008,; //'Recursos'
					 STR0009,; //'Despesas'
					 STR0027} //"Relac.Tarefas"
//					 STR0028 } //"Relac.EDT"

Local nPosCpo
Local cCpo
Local nRecAF2
Local aAuxArea

Local oListBox
Local oListBox2
Local aRecAF32 := {}

Local aTmpSV5 := {}
Local aTmp2SV5 := {}
Local aInfTela := {}

Local aAF3Field := {}

Local nx := 0
Local ny := 0
Local ni := 0
    
Local lPms103msg

PRIVATE oGD[5]
PRIVATE aSavN		:= {1,1,1,1,1}
PRIVATE aHeaderSV	:= {{},{},{},{},{}}
PRIVATE aColsSV	    := {{},{},{},{},{}}
PRIVATE oEnch
PRIVATE oFolder
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE 	cSavScrVT,;
			cSavScrVP,;
			cSavScrHT,;
			cSavScrHP,;
			CurLen,;
			nPosAtu:=0,;
			nPosAnt:=9999,;
			nColAnt:=9999
			
PRIVATE bResumoRfsh := {||A103ResRfsh(@aList,@oListBox,nMoedaVis,@aLegenda,@oListBox2,@oListBox)}
PRIVATE bGraficoRfsh:= {||Nil}

DEFAULT cNivTrf := "001"
	aAdd(aTitles, STR0031)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Array contendo as moedas do sistema          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx := 1 to ContaMoeda()
	If l103Visual .or. xMoeda(1,1,nx,dDataBase) > 0
		aADD(aCombo1,STR(nx,1)+":"+SuperGetMv("MV_MOEDA"+STR(nx,1)))
		aADD(aAuxCombo1,nx)
	EndIf
	If nx == nMoedaVis
		cCombo1 := aCombo1[nx]
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case aRotina[nOpcx][4] == 2
		l103Visual := .T.
	Case aRotina[nOpcx][4] == 3
		l103Inclui	:= .T.
		Inclui 		:= .T.
		Altera 		:= .F.
	Case aRotina[nOpcx][4] == 4
		l103Altera	:= .T.
		Inclui 		:= .F.
		Altera 		:= .T.
	Case aRotina[nOpcx][4] == 5
		l103Exclui	:= .T.
		l103Visual	:= .T.
EndCase

If l103Inclui
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o evento de Inclusao na Fase atual.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !PmsVldFase("AF1",AF1->AF1_ORCAME,"15")
		lContinua := .F.
	EndIf
EndIf

If l103Altera
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o evento de Alteracao na Fase atual.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !PmsVldFase("AF1",AF1->AF1_ORCAME,"18")
		lContinua := .F.
	EndIf
EndIf

If l103Exclui
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o evento de Exclusao no Fase atual.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !PmsVldFase("AF1",AF1->AF1_ORCAME,"14")
		lContinua := .F.
	EndIf
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as variaveis de memoria AF2                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory("AF2",l103Inclui)
	If l103Inclui
		M->AF2_NIVEL  := cNivTrf
		M->AF2_VERSAO := AF1->AF1_VERSAO
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento do array aGetCpos com os campos Inicializados do AF2    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aGetCpos <> Nil
		aGetEnch	:= {}
		dbSelectArea("SX3")
		dbSetOrder(1)
		DbSeek("AF2")
		While !Eof() .and. SX3->X3_ARQUIVO == "AF2"
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
				nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
				If nPosCpo > 0
					If aGetCpos[nPosCpo][3]
						aAdd(aGetEnch,AllTrim(X3_CAMPO))
					EndIf
				Else
					aAdd(aGetEnch,AllTrim(X3_CAMPO))
				EndIf
			EndIf
			dbSkip()
		End
		For nx := 1 to Len(aGetCpos)
			cCpo	:= "M->"+Trim(aGetCpos[nx][1])
			&cCpo	:= aGetCpos[nx][2]
		Next nx
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeaderAF3                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AF3")
	While !EOF() .And. (x3_arquivo == "AF3")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. !(AllTrim(X3_CAMPO)$"AF3_RECURS")
			aAdd( aAF3Field ,x3_campo)
		Endif
		dbSkip()
	End
	If ExistBlock("PMA103Prd")
		aAF3Field := ExecBlock("PMA103Prd", .T., .T., {aAF3Field})
	EndIf

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AF3")
	While !EOF() .And. (x3_arquivo == "AF3")
		If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. !(AllTrim(X3_CAMPO)$"AF3_RECURS") ;
		   .AND. aScan(aAF3Field, { |x| Upper(AllTrim(x)) == Upper(AllTrim(X3_CAMPO))}) > 0
		   
			AADD(aHeaderSV[1],{ TRIM(x3titulo()), x3_campo, x3_picture,  ;
				                x3_tamanho, x3_decimal, x3_valid,        ;
				                x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	EndDo
    	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeaderAF4                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AF4")
	While !EOF() .And. (x3_arquivo == "AF4")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[2],{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	End
    	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeaderAF7                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AF7")
	
	While !EOF() .And. (x3_arquivo == "AF7")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[3],{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader AJ1                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AJ1")
	While !EOF() .And. (x3_arquivo == "AJ1")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[5],{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSkip()
	End
    	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader AF3                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		aAF3Field := {}
		// estes campos devem ser apresentados no browse
		aTmpSV5	:= {"AF3_ITEM"   ,"AF3_RECURS" ,"AF3_QUANT" ,"AF3_PRODUT" ,"AF3_DESCRI" ;
		           ,"AF3_MOEDA"	 ,"AF3_SIMBMO" ,"AF3_CUSTD" ,"AF3_SEGUM"	 ,"AF3_QTSEGU" ; 
		           ,"AF3_ACUMUL" }

		If ExistBlock("PMA103Rec")
			aTmpSV5 := ExecBlock("PMA103Rec", .T., .T., {aTmpSV5})
		EndIf
	
		// estes campos devem ser apresentados no browse
		aTmp2SV5 := {"AF3_AQUISI", "AF3_CAPM3", "AF3_COEFMA", "AF3_COMBUS", "AF3_COMPOS", "AF3_CSTUNI",;
		             "AF3_DEPREC", "AF3_DMTX"  , "AF3_EMPOLA", "AF3_FILIAL", ;
		             "AF3_HORANO", "AF3_JUROS" , "AF3_MANUT" , "AF3_MATERI", "AF3_MDO"   ,;
		             "AF3_MT"    , "AF3_ORCAME",  "AF3_PHM3"  , "AF3_POTENC", ;
		             "AF3_RECPAI", "AF3_RESIDU", "AF3_TAREFA", "AF3_TCDM"  , "AF3_TPERC" , "AF3_TPTOT" ,;
		             "AF3_UM"    , "AF3_VALCOM", "AF3_VELO"  , "AF3_VIDAUT"}
	
		For nx := 1 to Len(aTmpSV5)
			SX3->(dbSetOrder(2))
			If SX3->(dbSeek(aTmpSV5[nx]))
				aAdd(aAF3Field, x3_campo)
			EndIf
		Next

		dbSetOrder(1)
		dbSeek("AF3")
		While !EOF() .And. (x3_arquivo == "AF3")
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
				AScan(aTmp2SV5, { |x| Upper(AllTrim(x)) == Upper(AllTrim(X3_CAMPO))}) == 0 .And. ;
				AScan(aTmpSV5,  { |x| Upper(AllTrim(x)) == Upper(AllTrim(X3_CAMPO))}) == 0
				aAdd(aAF3Field, x3_campo)
			Endif
			dbSkip()
		End
		If ExistBlock("PMA103Rec")
			aAF3Field := ExecBlock("PMA103Rec", .T., .T., {aAF3Field})
		EndIf
		
		// para obedecer a ordem das colunas que é diferente
		For nX := 1 To Len(aTmpSV5)
			SX3->(dbSetOrder(2))
			If SX3->(dbSeek(aTmpSV5[nx]))
				AADD(aHeaderSV[4],{ TRIM(x3titulo()), x3_campo, x3_picture,;
					x3_tamanho, x3_decimal, x3_valid,;
					x3_usado, x3_tipo, x3_arquivo,x3_context } )
			EndIf
		Next nX
		
		dbSetOrder(1)
		dbSeek("AF3")
		While !EOF() .And. (x3_arquivo == "AF3")
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
				AScan(aTmpSV5,  { |x| Upper(AllTrim(x)) == Upper(AllTrim(X3_CAMPO))}) == 0 .And. ;
				aScan(aAF3Field, { |x| Upper(AllTrim(x)) == Upper(AllTrim(X3_CAMPO))}) > 0
				
				AADD(aHeaderSV[4],{ TRIM(x3titulo()), x3_campo, x3_picture,;
					x3_tamanho, x3_decimal, x3_valid,;
					x3_usado, x3_tipo, x3_arquivo,x3_context } )
				
			Endif
			dbSkip()
		End
	

	If !l103Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trava o registro do AF2 - Alteracao,Visualizacao       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l103Altera.Or.l103Exclui
			If !SoftLock("AF2")
				lContinua := .F.
			Else
				nRecAF2 := AF2->(RecNo())
			Endif
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aColsAF3                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF3")
		dbSetOrder(1)
		dbSeek(xFilial()+AF2->AF2_ORCAME+AF2->AF2_TAREFA)
		While !Eof() .And. AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_TAREFA==xFilial("AF3")+AF2->AF2_ORCAME+AF2->AF2_TAREFA.And.lContinua
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trava o registro do AF3 - Alteracao,Exclusao           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (Empty(AF3->AF3_RECURS))
			If l103Altera.Or.l103Exclui
				If !SoftLock("AF3")
					lContinua := .F.
				Else
					aAdd(aRecAF3,RecNo())
				Endif
			EndIf
			aADD(aColsSV[1],Array(Len(aHeaderSV[1])+1))
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial()+AF3->AF3_PRODUT))
			For ny := 1 to Len(aHeaderSV[1])
				If ( aHeaderSV[1][ny][10] != "V")
					aColsSV[1][Len(aColsSV[1])][ny] := FieldGet(FieldPos(aHeaderSV[1][ny][2]))
				Else
					Do Case
						Case AllTrim(aHeaderSV[1][ny][2]) == "AF3_TIPO"
							aColsSV[1][Len(aColsSV[1])][ny] := SB1->B1_TIPO
						Case AllTrim(aHeaderSV[1][ny][2]) == "AF3_UM"
							aColsSV[1][Len(aColsSV[1])][ny] := SB1->B1_UM
						Case AllTrim(aHeaderSV[1][ny][2]) == "AF3_SEGUM"
							aColsSV[1][Len(aColsSV[1])][ny] := SB1->B1_SEGUM
						Case AllTrim(aHeaderSV[1][ny][2]) == "AF3_DESCRI"
							aColsSV[1][Len(aColsSV[1])][ny] := SB1->B1_DESC
						Case AllTrim(aHeaderSV[1][ny][2]) == "AF3_SIMBMO"
							aColsSV[1][Len(aColsSV[1])][ny] := SuperGetMv("MV_SIMB"+AllTrim(Str(AF3->AF3_MOEDA,2,0)))
						OtherWise
							aColsSV[1][Len(aColsSV[1])][ny] := CriaVar(aHeaderSV[1][ny][2])
					EndCase
				EndIf
				aColsSV[1][Len(aColsSV[1])][Len(aHeaderSV[1])+1] := .F.
			Next ny
			EndIf
			dbSkip()
		EndDo
	EndIf

	If Empty(aColsSV[1])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aColsAF3            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aColsSV[1],Array(Len(aHeaderSV[1])+1))
		For ny := 1 to Len(aHeaderSV[1])
			If Trim(aHeaderSV[1][ny][2]) == "AF3_ITEM"
				aColsSV[1][1][ny] 	:= "01"
			Else
				aColsSV[1][1][ny] := CriaVar(aHeaderSV[1][ny][2])
			EndIf
			aColsSV[1][1][Len(aHeaderSV[1])+1] := .F.
		Next ny
	EndIf

	If !l103Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aColsAF3                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
			dbSelectArea("AF3")
			dbSetOrder(1)
			dbSeek(xFilial() + AF2->AF2_ORCAME + AF2->AF2_TAREFA)
			While !Eof() .And. AF3->AF3_FILIAL + AF3->AF3_ORCAME + AF3->AF3_TAREFA == ;
			                   xFilial("AF3")  + AF2->AF2_ORCAME + AF2->AF2_TAREFA ;
			                   .And.lContinua
				If !Empty(AF3->AF3_RECURS)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Trava o registro do AF3 - Alteracao,Exclusao           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If l103Altera.Or.l103Exclui
						If !SoftLock("AF3")
							lContinua := .F.
						Else
							aAdd(aRecAF32,RecNo())
						Endif
					EndIf
					aADD(aColsSV[4],Array(Len(aHeaderSV[4])+1))
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial()+AF3->AF3_PRODUT))
					For ny := 1 to Len(aHeaderSV[4])
						If ( aHeaderSV[4][ny][10] != "V")
							aColsSV[4][Len(aColsSV[4])][ny] := FieldGet(FieldPos(aHeaderSV[4][ny][2]))
						Else
							Do Case
								Case AllTrim(aHeaderSV[4][ny][2]) == "AF3_TIPO"
									aColsSV[4][Len(aColsSV[4])][ny] := SB1->B1_TIPO
								Case AllTrim(aHeaderSV[4][ny][2]) == "AF3_UM"
									aColsSV[4][Len(aColsSV[4])][ny] := SB1->B1_UM
								Case AllTrim(aHeaderSV[4][ny][2]) == "AF3_SEGUM"
									aColsSV[4][Len(aColsSV[4])][ny] := SB1->B1_SEGUM
								Case AllTrim(aHeaderSV[4][ny][2]) == "AF3_DESCRI"
									If Empty(AF3->AF3_RECURS)									
										aColsSV[4][Len(aColsSV[4])][ny] := SB1->B1_DESC
									Else
										aColsSV[4][Len(aColsSV[4])][ny] := Posicione("AE8",1,xFilial("AE8") + AF3->AF3_RECURS,"AE8_DESCRI")
									EndIf
								OtherWise
									aColsSV[4][Len(aColsSV[4])][ny] := CriaVar(aHeaderSV[4][ny][2])
							EndCase
						EndIf
						aColsSV[4][Len(aColsSV[4])][Len(aHeaderSV[4])+1] := .F.
					Next ny
				EndIf
				dbSkip()
			EndDo
	EndIf
	If Empty(aColsSV[4])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aColsAF3            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aColsSV[4],Array(Len(aHeaderSV[4])+1))
		For ny := 1 to Len(aHeaderSV[4])
			Do Case
				Case AllTrim(aHeaderSV[4][ny][2]) == "AF3_ITEM"
					aColsSV[4][1][ny] 	:= "01"

				Case Alltrim(aHeaderSV[4][ny][2]) == "AF3_SIMBMO"
					aColsSV[4][Len(aColsSV[4])][ny] := SuperGetMv("MV_SIMB"+Alltrim(Str(1,2,0)))
			
      	Otherwise
					If aHeaderSV[4][ny][10] <> "V"
						aColsSV[4][1][ny] := CriaVar(aHeaderSV[4][ny][2])
					EndIf
			EndCase

			aColsSV[4][1][Len(aHeaderSV[4])+1] := .F.
		Next ny
	EndIf
	If !l103Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aColsAF4                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF4")
		dbSetOrder(1)
		dbSeek(xFilial()+AF2->AF2_ORCAME+AF2->AF2_TAREFA)
		While !Eof() .And. AF4->AF4_FILIAL+AF4->AF4_ORCAME+AF4->AF4_TAREFA==xFilial("AF4")+AF2->AF2_ORCAME+AF2->AF2_TAREFA.And.lContinua
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trava o registro do AF4 - Alteracao,Exclusao           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103Altera.Or.l103Exclui
				If !SoftLock("AF4")
					lContinua := .F.
				Else
					aAdd(aRecAF4,RecNo())
				Endif
			EndIf
			aADD(aColsSV[2],Array(Len(aHeaderSV[2])+1))
			For ny := 1 to Len(aHeaderSV[2])
				If ( aHeaderSV[2][ny][10] != "V")
					aColsSV[2][Len(aColsSV[2])][ny] := FieldGet(FieldPos(aHeaderSV[2][ny][2]))
				Else
					Do Case
						Case Alltrim(aHeaderSV[2][ny][2]) == "AF4_DESCTP"
							aColsSV[2][Len(aColsSV[2])][ny] := X5DESCRI()
						Case Alltrim(aHeaderSV[2][ny][2]) == "AF4_SIMBMO"
							aColsSV[2][Len(aColsSV[2])][ny] := SuperGetMv("MV_SIMB"+Alltrim(STR(AF4->AF4_MOEDA,2,0)))
						OtherWise
							aColsSV[2][Len(aColsSV[2])][ny] := CriaVar(aHeaderSV[2][ny][2])
					EndCase
				EndIf
				aColsSV[2][Len(aColsSV[2])][Len(aHeaderSV[2])+1] := .F.
			Next ny
			dbSkip()
		EndDo
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem de uma linha em branco no aColsAF4            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aColsSV[2])
		aadd(aColsSV[2],Array(Len(aHeaderSV[2])+1))
		For ny := 1 to Len(aHeaderSV[2])
			If Trim(aHeaderSV[2][ny][2]) == "AF4_ITEM"
				aColsSV[2][1][ny] 	:= "01"
			Else
				aColsSV[2][1][ny] := CriaVar(aHeaderSV[2][ny][2])
			EndIf
			aColsSV[2][1][Len(aHeaderSV[2])+1] := .F.
		Next ny
	EndIf   	

	If !l103Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aColsAF7                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF7")
		dbSetOrder(1)
		dbSeek(xFilial()+AF2->AF2_ORCAME+AF2->AF2_TAREFA)
		While !Eof() .And. AF7->AF7_FILIAL+AF7->AF7_ORCAME+AF7->AF7_TAREFA==xFilial("AF7")+AF2->AF2_ORCAME+AF2->AF2_TAREFA.And.lContinua
			aAuxArea := AF2->(GetArea())
			AF2->(dbSetOrder(1))
			AF2->(dbSeek(xFilial()+AF7->AF7_ORCAME+AF7->AF7_PREDEC))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trava o registro do AF7 - Alteracao,Exclusao           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103Altera.Or.l103Exclui
				If !SoftLock("AF7")
					lContinua := .F.
				Else
					aAdd(aRecAF7,RecNo())
				Endif
			EndIf
			aADD(aColsSV[3],Array(Len(aHeaderSV[3])+1))
			For ny := 1 to Len(aHeaderSV[3])
				If ( aHeaderSV[3][ny][10] != "V")
					aColsSV[3][Len(aColsSV[3])][ny] := FieldGet(FieldPos(aHeaderSV[3][ny][2]))
				Else
					Do Case
						Case AllTrim(aHeaderSV[3][ny][2]) == "AF7_DESCRI"
							aColsSV[3][Len(aColsSV[3])][ny] := AF2->AF2_DESCRI
						OtherWise
							aColsSV[3][Len(aColsSV[3])][ny] := CriaVar(aHeaderSV[3][ny][2])
					EndCase
				EndIf
				aColsSV[3][Len(aColsSV[3])][Len(aHeaderSV[3])+1] := .F.
			Next ny
			RestArea(aAuxArea)
			dbSelectArea("AF7")
			dbSkip()    
		EndDo
	EndIf

	If Empty(aColsSV[3])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aColsAF7            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aColsSV[3],Array(Len(aHeaderSV[3])+1))
		For ny := 1 to Len(aHeaderSV[3])
			If Trim(aHeaderSV[3][ny][2]) == "AF7_ITEM"
				aColsSV[3][1][ny] 	:= "01"
			Else
				aColsSV[3][1][ny] := CriaVar(aHeaderSV[3][ny][2])
			EndIf
			aColsSV[3][1][Len(aHeaderSV[3])+1] := .F.
		Next ny
	EndIf

	If !l103Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aCols AJ1                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AJ1")
		dbSetOrder(1)
		dbSeek(xFilial()+AF2->AF2_ORCAME+AF2->AF2_TAREFA)
		While !Eof() .And. AJ1->AJ1_FILIAL+AJ1->AJ1_ORCAME+AJ1->AJ1_TAREFA==xFilial("AJ1")+AF2->AF2_ORCAME+AF2->AF2_TAREFA.And.lContinua
			aAuxArea := AF5->(GetArea())
			AF5->(dbSetOrder(1))
			AF5->(dbSeek(xFilial()+AJ1->AJ1_ORCAME+AJ1->AJ1_PREDEC))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trava o registro do AJ1 - Alteracao,Exclusao           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103Altera.Or.l103Exclui
				If !SoftLock("AJ1")
					lContinua := .F.
				Else
					aAdd(aRecAJ1,RecNo())
				Endif
			EndIf
			aADD(aColsSV[5],Array(Len(aHeaderSV[5])+1))
			For ny := 1 to Len(aHeaderSV[5])
				If ( aHeaderSV[5][ny][10] != "V")
					aColsSV[5][Len(aColsSV[5])][ny] := FieldGet(FieldPos(aHeaderSV[5][ny][2]))
				Else
					Do Case
						Case AllTrim(aHeaderSV[5][ny][2]) == "AJ1_DESCRI"
							aColsSV[5][Len(aColsSV[5])][ny] := AF5->AF5_DESCRI
						OtherWise
							aColsSV[5][Len(aColsSV[5])][ny] := CriaVar(aHeaderSV[5][ny][2])
					EndCase
				EndIf
				aColsSV[5][Len(aColsSV[5])][Len(aHeaderSV[5])+1] := .F.
			Next ny
			RestArea(aAuxArea)
			dbSelectArea("AJ1")
			dbSkip()    
		EndDo
	EndIf

	If Empty(aColsSV[5])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aCols AJ1           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aColsSV[5],Array(Len(aHeaderSV[5])+1))
		For ny := 1 to Len(aHeaderSV[5])
			If Trim(aHeaderSV[5][ny][2]) == "AJ1_ITEM"
				aColsSV[5][1][ny] 	:= "01"
			Else
				aColsSV[5][1][ny] := CriaVar(aHeaderSV[5][ny][2])
			EndIf
			aColsSV[5][1][Len(aHeaderSV[5])+1] := .F.
		Next ny
	EndIf

	DbSelectArea("AF2")
    
	If ExistBlock("PMS103MSG")
		lPms103msg := EXECBLOCK("PMS103MSG", .F.,.F.)
		If ValType(lPms103msg) == "L"
			lContinua := lPms103msg
		EndIf
	EndIf
	
	If lContinua
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o calculo automatico de dimensoes de objetos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize := MsAdvSize(,.F.,400)
		aObjects := {} 
		
		AAdd( aObjects, { 100, 100 , .T., .T. } )
		AAdd( aObjects, { 100, 100 , .T., .T. } )
		
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
		aPosObj := MsObjSize( aInfo, aObjects )

		DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+aRotina[nOpcx,01] From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
    	
			oEnch := MsMGet():New("AF2",AF2->(RecNo()),nOpcx,,,,,aPosObj[1],aGetEnch,3,,,,oDlg)

			oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,, .T., .T.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
			oFolder:bSetOption:={|nFolder| A103SetOption(nFolder,oFolder:nOption) }

			For ni := 1 to Len(oFolder:aDialogs)
				DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
			Next	
		 	dbSelectArea("SX2")
		
			oFolder:aDialogs[1]:oFont := oDlg:oFont
			aHeader		:= aClone(aHeaderSV[1])
			aCols		:= aClone(aColsSV[1])
			oGD[1]		:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A103GD1LinOk","A103GD1TudOk","+AF3_ITEM", PmsVldFase("AF1",AF2->AF2_ORCAME,"29",.F.).And.!l103Visual,,1,,990,,,,"A103GDDel(1)",oFolder:aDialogs[1])
			oGD[1]:oBrowse:bDrawSelect	:= {|| A103SVCols(@aHeaderSV, @aColsSV, @aSavN, 1)}		
			
			oFolder:aDialogs[2]:oFont := oDlg:oFont
			aHeader		:= aClone(aHeaderSV[2])
			aCols		:= aClone(aColsSV[2])
			oGD[2]		:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A103GD2LinOk","A103GD2TudOK","+AF4_ITEM", PmsVldFase("AF1",AF2->AF2_ORCAME,"32",.F.).And.!l103Visual,,1,,990,,,,"A103GDDel(2)",oFolder:aDialogs[2])
			oGD[2]:oBrowse:lDisablePaint := .T.
			oGD[2]:oBrowse:bDrawSelect	:= {|| A103SVCols(@aHeaderSV, @aColsSV, @aSavN, 2)}					

			oFolder:aDialogs[3]:oFont := oDlg:oFont
			aHeader		:= aClone(aHeaderSV[3])
			aCols		:= aClone(aColsSV[3])
			oGD[3]		:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A103GD3LinOk","A103GD3TudOK","+AF7_ITEM", PmsVldFase("AF1",AF2->AF2_ORCAME,"35",.F.),,1,,990,,,,,oFolder:aDialogs[3])
			oGD[3]:oBrowse:lDisablePaint := .T.
			oGD[3]:oBrowse:bDrawSelect	:= {|| A103SVCols(@aHeaderSV, @aColsSV, @aSavN, 3)}					
		
//			oFolder:aDialogs[5]:oFont := oDlg:oFont
//			aHeader		:= aClone(aHeaderSV[5])
//			aCols		:= aClone(aColsSV[5])
//			oGD[5]		:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A103GD4LinOk","A103GD4TudOK","+AJ1_ITEM", PmsVldFase("AF1",AF2->AF2_ORCAME,"35",.F.),,1,,990,,,,,oFolder:aDialogs[5])
//			oGD[5]:oBrowse:lDisablePaint := .T.
			oFolder:aDialogs[4]:oFont := oDlg:oFont
			aHeader		         := aClone(aHeaderSV[4])
			aCols		           := aClone(aColsSV[4])
			oGD[4]		         := MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A103GD4LinOk","A103GD4TudOK","+AF3_ITEM", PmsVldFase("AF1",AF2->AF2_ORCAME,"35",.F.),,1,,990,"A103GD4FieldOk",,,"A103GDDel(4)",oFolder:aDialogs[4])
			oGD[4]:oBrowse:lDisablePaint := .T. 
			oGD[4]:oBrowse:bDrawSelect := {|| A103SVCols(@aHeaderSV, @aColsSV, @aSavN, 4)}
			
			aHeader		:= aClone(aHeaderSV[1])
			aCols		:= aClone(aColsSV[1])


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica a existencia do ponto de entrada dos botoes de usuarios.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("PMA103BTN")
				aButtons:= ExecBlock("PMA103BTN",.F.,.F.,{aButtons})
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica a existencia do ponto de entrada do template para os botoes de usuarios.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistTemplate("PMA103BTN")
				aButtons:= ExecTemplate("PMA103BTN",.F.,.F.,{aButtons})
			EndIf

			aInfTela := {	{"ENCHOICE",cCadastro,oEnch:aGets,oEnch:aTela },;
			                {"GETDADOS",aTitles[1],aHeaderSV[1],aColsSV[1]},;
			                {"GETDADOS",aTitles[2],aHeaderSV[2],aColsSV[2]},;
			                {"GETDADOS",aTitles[3],aHeaderSV[3],aColsSV[3]} } 
			                
				aAdd( aInfTela ,{"GETDADOS",aTitles[4],aHeaderSV[4],aColsSV[4]} )
		
			aButtons := AddToExcel(aButtons,aInfTela )


		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||EncChgFoco(oEnch),If(Obrigatorio(aGets,aTela).And.;
								AGDTudok(1).And.;
								AGDTudok(2).And.;
								AGDTudok(3) .And.  AGDTudok(4) .And.Chk103CCTOk(),;
								(nOpc:=1,oDlg:End()),Nil)},{||oDlg:End()},,aButtons)
		FATPDLogUser("PMS103DLG")
		// Não deve aplicar refresh na visualizacao do orcamento (arvore/planilha)
		lRefresh := .F.
		dbSelectArea("AF2")
		If (nOpc == 1) .And. (l103Inclui .Or. l103Altera .Or. l103Exclui)
			// Aplicar refresh na visualizacao do orcamento (arvore/planilha)
			lRefresh := .T.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se existe o ponto de entrada para a permissao ou bloqueio³
			//³da inclusao,alteracao,exclusao da Tarefa.                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do Case
				Case l103Inclui
					If ExistBlock("PMA103INC")
						If !ExecBlock("PMA103INC",.F.,.F.)
							Return(nRecAF2)
						EndIf
					EndIf

				Case l103Altera
					If ExistBlock("PMA103ALT")
						If !ExecBlock("PMA103ALT",.F.,.F.)
							Return(nRecAF2)
						EndIf
					EndIf

				Case l103Exclui
					If ExistBlock("PMA103DEL")
						If !ExecBlock("PMA103DEL",.F.,.F.)
							Return(nRecAF2)
						EndIf
					EndIf
			EndCase

			Begin Transaction
				Processa({||PMS103Grava(l103Exclui,1,@nRecAF2,aRecAF3,aRecAF4,aRecAF5,aRecAF7,aRecAJ1,aRecAF32)},STR0026) //"Gravando Estrutura..."
		    End Transaction
		EndIf
		
		If ExistBlock("PMA103FI")
			ExecBlock("PMA103FI",.F.,.F.,{l103Inclui,l103Altera,l103Exclui,(nOpc == 1)})
		EndIf
			
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava Todos os Registros                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()


Return nRecAF2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103SetOption³ Autor ³ Edson Maricate     ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A103SetOption(nFolder,nOldFolder)
           
If nOldFolder <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nOldFolder])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva o conteudo da GetDados se existir              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsSV[nOldFolder]		:= aClone(aCols)
	aHeaderSV[nOldFolder]	:= aClone(aHeader)
	aSavN[nOldFolder]		:= n
	oGD[nOldFolder]:oBrowse:lDisablePaint := .T.
EndIf

If nFolder!=Nil.And.nFolder <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nFolder])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura o conteudo da GetDados se existir           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGD[nFolder]:oBrowse:lDisablePaint := .F.
	aCols	:= aClone(aColsSV[nFolder])
	aHeader := aClone(aHeaderSV[nFolder])
	n		:= aSavN[nFolder]
	oGD[nFolder]:oBrowse:Refresh()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se esta chamando o Folder de Resumos        ³
//³ e executa o Refresh.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GD1LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 1.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103GD1LinOk(lTdOk)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet 		:= MaCheckCols(aHeader,aCols,n)
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="AF3_ITEM"})

Local lTudoOk	:= Iif(ValType(lTdOk)<>"L", .F., lTdOk)
Local lAtuCust	:= .F.

If Inclui .And. lRet .And. ! aCols[n][Len(aCols[n])]
	lRet := PmsVldFase("AF1",M->AF2_ORCAME,"27")
ElseIf Altera .And. lRet .And. ! aCols[n][Len(aCols[n])]
	AF3->(dbSetOrder(1))
  	If AF3->(dbSeek(xFilial()+M->AF2_ORCAME+M->AF2_TAREFA+aCols[n][nPosItem]))
		lRet := PmsVldFase("AF1",M->AF2_ORCAME,"28")
	Else
		lRet := PmsVldFase("AF1",M->AF2_ORCAME,"27")
	EndIf
EndIf
//Para que chame a atualização de custo a linha posicionada deve estar dentro do array de linhas alteradas
If !lTudoOk .And. ValType(lTdOk)=="O" .And. Len(LTDOK:OMOTHER:ALASTEDIT) > 0 .And. aScan(LTDOK:OMOTHER:ALASTEDIT,LTDOK:NAT) > 0
	lAtuCust := .T.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o custo da tarefa.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("CCTAF2CUSTO")
	ExecTemplate("CCTAF2CUSTO",.F.,.F.,{1})
Else 
	If !lTudoOk // no tudook já teremos um FOR das linhas do acols Faremos agora o total da tarefa no final do tudok
		If lAtuCust
			aRetCus	:= PmsAF2CusTrf(1)
			M->AF2_CUSTO  := aRetCus[1]
			M->AF2_CUSTO2 := aRetCus[2]
			M->AF2_CUSTO3 := aRetCus[3]
			M->AF2_CUSTO4 := aRetCus[4]
			M->AF2_CUSTO5 := aRetCus[5]
			If cPaisLoc == "BOL"                                                                                                             
				M->AF2_VALIT  := (M->AF2_IT*(M->AF2_VALBDI+M->AF2_VALUTI+M->AF2_CUSTO))/100
				M->AF2_VALUTI := (M->AF2_UTIL*(M->AF2_VALBDI+M->AF2_VALIT+M->AF2_CUSTO))/100
			EndIf		
			M->AF2_VALBDI:= aRetCus[1]*IIf(M->AF2_BDI <> 0,M->AF2_BDI,PmsGetBDIPad('AF2',M->AF2_ORCAME,,M->AF2_EDTPAI, M->AF2_UTIBDI ))/100
			M->AF2_TOTAL := aRetCus[1]+M->AF2_VALBDI+IIf(cPaisLoc=="BOL",M->AF2_VALIT+M->AF2_VALUTI,0)
		EndIf   		                                                
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a existencia de ponto de entrada na validacao da linha no aCols de produtos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("A103LINOK1")
   lRet := ExecBlock("A103LINOK1",.F.,.F.,{lRet})
EndIf
// Este ponto de entrada deve retornar o conteudo de lRet para validar ou nao a linha do aCols.

oEnch:Refresh()

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GD1TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 1.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103GD1TudOk()

Local nx
Local lRet := .T.
Local nPosProd	:= aScan(aHeader,{|x|AllTrim(x[2])=="AF3_PRODUT"})
Local nPosQT	:= aScan(aHeader,{|x|AllTrim(x[2])=="AF3_QUANT"})
Local nSavN	:= n

For nx := 1 to Len(aCols)
	n	:= nx
	If !Empty(aCols[n][nPosProd]) .Or. !Empty(aCols[n][nPosQT])
		If !A103GD1LinOk(.T.)
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

If lRet
	aRetCus	:= PmsAF2CusTrf(1)
	M->AF2_CUSTO  := aRetCus[1]
	M->AF2_CUSTO2 := aRetCus[2]	
	M->AF2_CUSTO3 := aRetCus[3]	
	M->AF2_CUSTO4 := aRetCus[4]						
	M->AF2_CUSTO5 := aRetCus[5]   
	If cPaisLoc == "BOL"
		M->AF2_VALIT  := (M->AF2_IT*(M->AF2_VALBDI+M->AF2_VALUTI+M->AF2_CUSTO))/100   
		M->AF2_VALUTI := (M->AF2_UTIL*(M->AF2_VALBDI+M->AF2_VALIT+M->AF2_CUSTO))/100  
	EndIf
	M->AF2_VALBDI:= aRetCus[1]*IIf(M->AF2_BDI <> 0,M->AF2_BDI,PmsGetBDIPad('AF2',M->AF2_ORCAME,,M->AF2_EDTPAI, M->AF2_UTIBDI ))/100
	M->AF2_TOTAL := aRetCus[1]+M->AF2_VALBDI+IIf(cPaisLoc == "BOL",M->AF2_VALIT+M->AF2_VALUTI,0)           
 
Endif   

n	:= nSavN

oEnch:Refresh()

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GD2TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 2.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103GD2TudOk()
Local nx := 0

Local nPosDescri:= aScan(aHeader,{|x|AllTrim(x[2])=="AF4_DESCRI"})
Local nPosValor	:= aScan(aHeader,{|x|AllTrim(x[2])=="AF4_VALOR"})
Local nSavN	:= n
Local lRet	:= .T.

For nx := 1 to Len(aCols)
	n	:= nx
	If !Empty(aCols[n][nPosDescri]).Or.!Empty(aCols[n][nPosValor])
		If !A103GD2LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next
	
n	:= nSavN

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GD3TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 3.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103GD3TudOk()
Local nx := 0
Local nPosPredec	:= aScan(aHeader,{|x|AllTrim(x[2])=="AF7_PREDEC"})
Local nSavN			:= n
Local lRet			:= .T.

For nx := 1 to Len(aCols)
	n	:= nx
	If !Empty(aCols[n][nPosPredec])
		If !A103GD3LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next
	
n	:= nSavN

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GD4TudOk³ Autor ³ Adriano Ueda        ³ Data ³ 20-04-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 4.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A103GD4TudOk()

Local nx
Local lRet := .T.
Local nPosRec	:= aScan(aHeader,{|x|AllTrim(x[2])=="AF3_RECURS"})
Local nPosQT	:= aScan(aHeader,{|x|AllTrim(x[2])=="AF3_QUANT"})
Local nSavN	:= n

For nx := 1 to Len(aCols)
	n	:= nx
	If !(aCols[n][Len(aHeader)+1]) .And. (!Empty(aCols[n][nPosRec]) .Or. !Empty(aCols[n][nPosQT]))
		If !A103GD4LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

n	:= nSavN

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GD4LinOk³ Autor ³ Adriano Ueda        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 5.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA203                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103GD4LinOk()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea     := GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local aAreaSX2	:= SX2->(GetArea())
Local lRet      := .T.
Local nPosItem  := aScan(aHeader,{|x| AllTrim(x[2])=="AF3_ITEM"})
Local nPosRec   := aScan(aHeader,{|x| AllTrim(x[2])=="AF3_RECURS"})
//Local nPosDtPrf	:= aScan(aHeader,{|x| AllTrim(x[2])=="AF3_DATPRF"})
Local nPosQt    := aScan(aHeader,{|x| AllTrim(x[2])=="AF3_QUANT"})
Local nPosCampo := 0

If !(aCols[n][Len(aHeader)+1])
	If Empty(aCols[n][nPosRec]) /*.Or. Empty(aCols[n][nPosDtPrf]) */ .Or. (aCols[n][nPosQt] == 0)
		Do Case
			Case Empty(aCols[n][nPosRec])
				nPosCampo:= nPosRec
			/*Case Empty(aCols[n][nPosDtPrf])
				nPosCampo:= nPosDtPrf*/
			Case (aCols[n][nPosQt] == 0)
				nPosCampo:= nPosQt
		EndCase
	
		SX3->(dbSetOrder(2))
		SX3->(MsSeek(aHeader[nPosCampo][2]))
		SX2->(dbSetOrder(1))
		SX2->(MsSeek(SX3->X3_ARQUIVO))
		Help("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+"Campo: "+X3DESCRIC()+CHR(10)+CHR(13)+"Linha: "+Str(n,3,0),3,1) //"Campo: "###"Linha: "
		lRet:= .F.
	EndIf
	
	If Inclui .And. lRet .And. ! aCols[n][Len(aCols[n])]
		lRet := PmsVldFase("AF1",M->AF2_ORCAME,"27")
	ElseIf Altera .And. lRet .And. ! aCols[n][Len(aCols[n])]
		AF3->(dbSetOrder(1))
	  	If AF3->(dbSeek(xFilial()+M->AF2_ORCAME+M->AF2_TAREFA+aCols[n][nPosItem]))
			lRet := PmsVldFase("AF1",M->AF2_ORCAME,"28")
		Else
			lRet := PmsVldFase("AF1",M->AF2_ORCAME,"27")
		EndIf
	EndIf
EndIf

If ExistTemplate("CCTAF2CUSTO")
	ExecTemplate("CCTAF2CUSTO",.F.,.F.,{4})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o custo da tarefa.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetCus	:= PmsAF2CusTrf(4)
	M->AF2_CUSTO := aRetCus[1]
	M->AF2_CUSTO2 := aRetCus[2]	
	M->AF2_CUSTO3 := aRetCus[3]	
	M->AF2_CUSTO4 := aRetCus[4]						
	M->AF2_CUSTO5 := aRetCus[5]   
	If cPaisLoc == "BOL"
		M->AF2_VALIT  := (M->AF2_IT*(M->AF2_VALBDI+M->AF2_VALUTI+M->AF2_CUSTO))/100   
		M->AF2_VALUTI := (M->AF2_UTIL*(M->AF2_VALBDI+M->AF2_VALIT+M->AF2_CUSTO))/100  
	EndIf	
	M->AF2_VALBDI:= aRetCus[1]*IIf(M->AF2_BDI <> 0,M->AF2_BDI,PmsGetBDIPad('AF2',M->AF2_ORCAME,,M->AF2_EDTPAI, M->AF2_UTIBDI  ) )/100
	M->AF2_TOTAL := aRetCus[1]+M->AF2_VALBDI+IIf(cPaisLoc == "BOL",M->AF2_VALIT+M->AF2_VALUTI,0)   
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a existencia de ponto de entrada na validacao da linha no aCols de produtos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("A103LINOK4")
   lRet := ExecBlock("A103LINOK4",.F.,.F.,{lRet})
EndIf

RestArea(aAreaSX2)
RestArea(aAreaSX3)
RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GD2LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 2.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103GD2LinOk()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet 		:= MaCheckCols(aHeader,aCols,n)
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="AF4_ITEM"})

If Inclui .And. lRet .And. ! aCols[n][Len(aCols[n])]
	lRet := PmsVldFase("AF1",M->AF2_ORCAME,"30")
ElseIf Altera .And. lRet .And. ! aCols[n][Len(aCols[n])]
	AF4->(dbSetOrder(1))
  	If AF4->(dbSeek(xFilial()+M->AF2_ORCAME+M->AF2_TAREFA+aCols[n][nPosItem]))
		lRet := PmsVldFase("AF1",M->AF2_ORCAME,"31")
	Else
		lRet := PmsVldFase("AF1",M->AF2_ORCAME,"30")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o custo da tarefa.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o custo da tarefa.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("CCTAF2CUSTO")
	ExecTemplate("CCTAF2CUSTO",.F.,.F.,{2})
Else
	aRetCus	:= PmsAF2CusTrf(2)
	M->AF2_CUSTO := aRetCus[1]
	M->AF2_CUSTO2 := aRetCus[2]	
	M->AF2_CUSTO3 := aRetCus[3]	
	M->AF2_CUSTO4 := aRetCus[4]						
	M->AF2_CUSTO5 := aRetCus[5]
	If cPaisLoc == "BOL"
		M->AF2_VALIT  := (M->AF2_IT*(M->AF2_VALBDI+M->AF2_VALUTI+M->AF2_CUSTO))/100   
		M->AF2_VALUTI := (M->AF2_UTIL*(M->AF2_VALBDI+M->AF2_VALIT+M->AF2_CUSTO))/100  
	EndIf		
	M->AF2_VALBDI:= aRetCus[1]*IIf(M->AF2_BDI <> 0,M->AF2_BDI,PmsGetBDIPad('AF2',M->AF2_ORCAME,,M->AF2_EDTPAI, M->AF2_UTIBDI ))/100
	M->AF2_TOTAL := aRetCus[1]+M->AF2_VALBDI+IIf(cPaisLoc == "BOL",M->AF2_VALIT+M->AF2_VALUTI,0) 
EndIf
	

oEnch:Refresh()

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GD3LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 3.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103GD3LinOk()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet 		:= MaCheckCols(aHeader,aCols,n)
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="AF7_ITEM"})
Local aArea     := GetArea()
Local aAreaAF7  := AF7->(GetArea())

If Inclui .And. lRet .And. ! aCols[n][Len(aCols[n])]
	lRet := PmsVldFase("AF1",M->AF2_ORCAME,"33")
ElseIf Altera .And. lRet .And. ! aCols[n][Len(aCols[n])]
	AF7->(dbSetOrder(1))
  	If AF7->(dbSeek(xFilial()+M->AF2_ORCAME+M->AF2_TAREFA+aCols[n][nPosItem]))
		lRet := PmsVldFase("AF1",M->AF2_ORCAME,"34")
	Else
		lRet := PmsVldFase("AF1",M->AF2_ORCAME,"33")
	EndIf
EndIf

If !Pms103Loop(M->AF2_ORCAME,aCols[n][2],M->AF2_TAREFA)
	Aviso(STR0030, STR0029, {"Ok"})
	lRet := .F.
EndIf

restArea(aAreaAF7)
restArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GD5TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 4.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103GD5TudOk()
Local nx := 0
Local nPosPredec	:= aScan(aHeader,{|x|AllTrim(x[2])=="AJ1_PREDEC"})
Local nSavN			:= n
Local lRet			:= .T.

For nx := 1 to Len(aCols)
	n	:= nx
	If !Empty(aCols[n][nPosPredec])
		If !A103GD5LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next
	
n	:= nSavN

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GD5LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 4.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103GD5LinOk()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet 		:= MaCheckCols(aHeader,aCols,n)
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="AJ1_ITEM"})

If Inclui .And. lRet .And. ! aCols[n][Len(aCols[n])]
	lRet := PmsVldFase("AF1",M->AF2_ORCAME,"33")
ElseIf Altera .And. lRet .And. ! aCols[n][Len(aCols[n])]
	AJ1->(dbSetOrder(1))
  	If AJ1->(dbSeek(xFilial()+M->AF2_ORCAME+M->AF2_TAREFA+aCols[n][nPosItem]))
		lRet := PmsVldFase("AF1",M->AF2_ORCAME,"34")
	Else
		lRet := PmsVldFase("AF1",M->AF2_ORCAME,"33")
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS103Grava³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a gravacao do Orcamento.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA103                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS103Grava(lDeleta,nRecAF1,nRecAF2,aRecAF3,aRecAF4,aRecAF5,aRecAF7,aRecAJ1, aRecAF32)

Local lAltera	:= (nRecAF2!=Nil)
Local bCampo 	:= {|n| FieldName(n) }
Local nX        := 0
Local nCntFor   := 0
Local nCntFor2  := 0
Local nPosProd	:= aScan(aHeaderSV[1],{|x|AllTrim(x[2])=="AF3_PRODUT"})
Local nPosDescri:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AF4_DESCRI"})
Local nPosPrd	:= aScan(aHeaderSV[3],{|x|AllTrim(x[2])=="AF7_PREDEC"})
Local nPosPrd4	:= aScan(aHeaderSV[5],{|x|AllTrim(x[2])=="AJ1_PREDEC"})
Local nPosRecurs:= aScan(aHeaderSV[4],{|x|AllTrim(x[2])=="AF3_RECURS"})
Local cChave    := ""
Local nOpcMemo  := 0

	ProcRegua(Len(aColsSV[1])+Len(aColsSV[2])+Len(aColsSV[3])+Len(aColsSV[5]))
	
	If !lDeleta
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o arquivo de de Tarefas do Orcamento           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAltera
			AF2->(dbGoto(nRecAF2))
			RecLock("AF2",.F.)
		Else
			RecLock("AF2",.T.)
		EndIf
		For nx := 1 TO FCount()
			FieldPut(nx,M->&(EVAL(bCampo,nx)))
		Next nx
		AF2->AF2_FILIAL := xFilial("AF2")
		MsUnlock()	
	
		If Type(M->AF2_CODMEM) <> Nil
			cChave := M->AF2_CODMEM
		EndIf
		If Empty(M->AF2_OBS) .And. lAltera
			nOpcMemo := 2 // Deleta Campo Memo
		Else
			nOpcMemo := 1 // Mantem funcionamento anterior
		EndIf
	
		MSMM(cChave ,TamSx3("AF2_OBS")[1] ,,M->AF2_OBS ,nOpcMemo ,,,"AF2" ,"AF2_CODMEM")
		nRecAF2	:= AF2->(RecNo())
		cOrcame := AF2->AF2_ORCAME
		cEDTPai := AF2->AF2_EDTPAI
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava arquivo AF3 (Despesas)                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF3")
		For nCntFor := 1 to Len(aColsSV[1])
			If !aColsSV[1][nCntFor][Len(aHeaderSV[1])+1]
				If !Empty(aColsSV[1][nCntFor][nPosProd])
					If nCntFor <= Len(aRecAF3)
						dbGoto(aRecAF3[nCntFor])
						RecLock("AF3",.F.)
					Else
						RecLock("AF3",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[1])
				      If ( aHeaderSV[1][nCntFor2][10] != "V" )
							AF3->(FieldPut(FieldPos(aHeaderSV[1][nCntFor2][2]),aColsSV[1][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AF3->AF3_FILIAL	:= xFilial("AF3")
					AF3->AF3_ORCAME	:= AF2->AF2_ORCAME
					AF3->AF3_TAREFA	:= AF2->AF2_TAREFA
					AF3->AF3_VERSAO	:= AF2->AF2_VERSAO
					MsUnlock()
				EndIf
			Else
				If nCntFor <= Len(aRecAF3)
					dbGoto(aRecAF3[nCntFor])
					RecLock("AF3",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
	
			IncProc()
		Next nCntFor
	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava arquivo AF4 (Despesas)                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF4")
		For nCntFor := 1 to Len(aColsSV[2])
			If !aColsSV[2][nCntFor][Len(aHeaderSV[2])+1]
				If !Empty(aColsSV[2][nCntFor][nPosDescri])
					If nCntFor <= Len(aRecAF4)
						dbGoto(aRecAF4[nCntFor])
						RecLock("AF4",.F.)
					Else
						RecLock("AF4",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[2])
						If ( aHeaderSV[2][nCntFor2][10] != "V" )
							AF4->(FieldPut(FieldPos(aHeaderSV[2][nCntFor2][2]),aColsSV[2][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AF4->AF4_FILIAL	:= xFilial("AF4")
					AF4->AF4_ORCAME	:= AF2->AF2_ORCAME
					AF4->AF4_TAREFA	:= AF2->AF2_TAREFA
					MsUnlock()
				EndIf
			Else
				If nCntFor <= Len(aRecAF4)
					dbGoto(aRecAF4[nCntFor])
					RecLock("AF4",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
		
			IncProc()
		
		Next nCntFor
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava arquivo AF7 (Predecessoras)                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF7")
		For nCntFor := 1 to Len(aColsSV[3])
			If !aColsSV[3][nCntFor][Len(aHeaderSV[3])+1]
				If !Empty(aColsSV[3][nCntFor][nPosPrd])
					If nCntFor <= Len(aRecAF7)
						dbGoto(aRecAF7[nCntFor])
						RecLock("AF7",.F.)
					Else
						RecLock("AF7",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[3])
						If ( aHeaderSV[3][nCntFor2][10] != "V" )
							AF7->(FieldPut(FieldPos(aHeaderSV[3][nCntFor2][2]),aColsSV[3][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AF7->AF7_FILIAL	:= xFilial("AF7")
					AF7->AF7_ORCAME	:= AF2->AF2_ORCAME
					AF7->AF7_TAREFA	:= AF2->AF2_TAREFA
					MsUnlock()
				EndIf
			Else
				If nCntFor <= Len(aRecAF7)
					dbGoto(aRecAF7[nCntFor])
					RecLock("AF7",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
			IncProc()
		Next nCntFor
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava arquivo AJ1 (Predecessoras)                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AJ1")
		For nCntFor := 1 to Len(aColsSV[5])
			If !aColsSV[5][nCntFor][Len(aHeaderSV[5])+1]
				If !Empty(aColsSV[5][nCntFor][nPosPrd4])
					If nCntFor <= Len(aRecAJ1)
						dbGoto(aRecAJ1[nCntFor])
						RecLock("AJ1",.F.)
					Else
						RecLock("AJ1",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[5])
						If ( aHeaderSV[5][nCntFor2][10] != "V" )
							AJ1->(FieldPut(FieldPos(aHeaderSV[5][nCntFor2][2]),aColsSV[5][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AJ1->AJ1_FILIAL	:= xFilial("AJ1")
					AJ1->AJ1_ORCAME	:= AF2->AF2_ORCAME
					AJ1->AJ1_TAREFA	:= AF2->AF2_TAREFA
					MsUnlock()
				EndIf
			Else
				If nCntFor <= Len(aRecAJ1)
					dbGoto(aRecAJ1[nCntFor])
					RecLock("AJ1",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
	
			IncProc()
	
		Next nCntFor
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava arquivo AF3 (Recursos)                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AF3")
			For nCntFor := 1 to Len(aColsSV[4])
				If !aColsSV[4][nCntFor][Len(aHeaderSV[4])+1]
					If !Empty(aColsSV[4][nCntFor][nPosRecurs])
						AE8->(dbSetOrder(1))
						AE8->(dbSeek(xFilial()+aColsSV[4][nCntFor][nPosRecurs]))
						If nCntFor <= Len(aRecAF32)
							dbGoto(aRecAF32[nCntFor])
							RecLock("AF3",.F.)
						Else
							RecLock("AF3",.T.)
						EndIf
						For nCntFor2 := 1 To Len(aHeaderSV[4])
							If ( aHeaderSV[4][nCntFor2][10] != "V" )
								AF3->(FieldPut(FieldPos(aHeaderSV[4][nCntFor2][2]),aColsSV[4][nCntFor][nCntFor2]))
							EndIf
						Next nCntFor2
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Calcula a quantidade de horas do recurso.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						AF3->AF3_FILIAL	:= xFilial("AF3")
						AF3->AF3_ORCAME	:= AF2->AF2_ORCAME
						AF3->AF3_TAREFA	:= AF2->AF2_TAREFA
						MsUnlock()
					EndIf
				Else
					If nCntFor <= Len(aRecAF32)
						dbGoto(aRecAF32[nCntFor])
						RecLock("AF3",.F.,.T.)
						dbDelete()
						MsUnlock()
					EndIf
				EndIf
			Next nCntFor	
			
	
		PmsAvalAF2("AF2")
		
		If ExistBlock("PMA103GRV")
			ExecBlock("PMA103GRV",.F.,.F.)
		EndIf
	
		If ExistTemplate("CCT103GRV")
			ExistTemplate("CCT103GRV",.F.,.F.)
		EndIf
	
	Else
		IncProc()
		MaExclAF2(,,nRecAF2)
		
	EndIf

Return 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AGDTudOk³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao auxiliar utilizada pela EnchoiceBar para executar a   ³±±
±±³          ³ TudOk da GetDados                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Validacao TudOk da Getdados                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AGDTudok(nGetDados)
Local aSavCols		:= aClone(aCols)
Local aSavHeader	:= aClone(aHeader)
Local nSavN			:= n
Local lRet			:= .T.

Eval(oFolder:bSetOption)
oGD[nGetDados]:oBrowse:lDisablePaint := .F.

aCols			:= aClone(aColsSV[nGetDados])
aHeader			:= aClone(aHeaderSV[nGetDados])
n				:= aSavN[nGetDados]
oFolder:nOption	:= nGetDados

Do Case
	Case nGetDados == 1
		lRet := A103GD1Tudok()
	Case nGetDados == 2
		lRet := A103GD2Tudok()	
	Case nGetDados == 3
		lRet := A103GD3Tudok()	
	Case nGetDados == 4
		lRet := A103GD4Tudok()
	Case nGetDados == 5
		lRet := A103GD5Tudok()	
EndCase


aColsSV[nGetDados] := aClone(aCols)
aHeaderSV[nGetDados] := aClone(aHeader)

If nGetDados != oFolder:nOption
	aCols	:= aClone(aSavCols)
	aHeader	:= aClone(aSavHeader)
	n		:= nSavN
EndIf

Return lRet 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103Resumo³ Autor ³ Fernando Dourado      ³ Data ³ 25-04-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que cria a tela de resumos de custos do orcamento     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A103ResRfsh(aList,oList,nMoedaVis,aLegenda,oListBox2,oListBox)

Local nPosCod	:= aScan(aHeaderSV[1],{|x|AllTrim(x[2])=="AF3_PRODUT"})
Local nPosQT	:= aScan(aHeaderSV[1],{|x|AllTrim(x[2])=="AF3_QUANT"})
Local nPosCust  := aScan(aHeaderSV[1],{|x|AllTrim(x[2])=="AF3_CUSTD"})
Local nPosMCus  := aScan(aHeaderSV[1],{|x|AllTrim(x[2])=="AF3_MOEDA"})
//Local nPosIt	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AF4_ITEM"})
Local nPosTP	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AF4_TIPOD"})
Local nPosMoeda	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AF4_MOEDA"})
Local nPosVal	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AF4_VALOR"})
Local nTotal	:= 0                        
Local nx		:= 0
Local nQuant    := 0
Local nValor	:= 0

aList 		:= {}
aLegenda	:= {}

//Itens
For nx := 1 to Len(aColsSV[1])
	If !aColsSV[1][nx][Len(aColsSV[1][nx])]
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+aColsSV[1][nx][nPosCod])
			nQuant:= PmsAF3Quant(M->AF2_ORCAME,M->AF2_TAREFA,aColsSV[1][nx][nPosCod],M->AF2_QUANT,aColsSV[1][nx][nPosQT])
			
			A103AddList(@aList,SB1->B1_TIPO,nQuant*aColsSV[1][nx][nPosCust],aColsSV[1][nx][nPosMCus],nMoedaVis,@nTotal,@aLegenda)
		EndIf
	EndIf
Next

//Despesas
For nx := 1 to Len(aColsSV[2])
	If !aColsSV[2][nx][Len(aColsSV[2][nx])] .And. !Empty(aColsSV[2][nx][nPosTp]) .And. ;
		!Empty(aColsSV[2][nx][nPosVal])
		
		nValor:= PmsAF4Valor(M->AF2_QUANT,aColsSV[2][nx][nPosVal])
		A103AddList(@aList,aColsSV[2][nx][nPosTp],nValor,aColsSV[2][nx][nPosMoeda],nMoedaVis,@nTotal,@aLegenda)
	EndIf
Next

If Empty(aList)
	aList			:= {{'','','',0,0}}
	aLegenda		:= {''}
Else
	aAdd(aList,{'','','','',' '})
	aAdd(aList,{'..',STR0019,Alltrim(SuperGetMv('MV_SIMB'+Alltrim(STR(nMoedaVis,2,0)))),nTotal,100}) //'TOTAL DO ORCAMENTO '
EndIf

oListBox:SetArray(aList)
oListBox:bLine := { || {aList[oListBox:nAT][1],;
						aList[oListBox:nAT][2],;
						aList[oListBox:nAT][3],;
						If(ValType(aList[oListBox:nAT][4])=="N",Transform(aList[oListBox:nAT][4],"@E 999,999,999.99"),aList[oListBox:nAT][4]),;
						If(ValType(aList[oListBox:nAT][5])=="N",Transform(aList[oListBox:nAT][5],"@E 999.99"),aList[oListBox:nAT][5])}}
oListBox:Refresh()						

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103Resumo³ Autor ³ Fernando Dourado      ³ Data ³ 25-04-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que cria a tela de resumos de custos do orcamento     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A103AddList(aList,cTipo,nCusto,nMoedaCusto,nMoedaVis,nTotal,aLegenda)

Local nList

cTipo := Alltrim(cTipo)
nList:=aScan(aList,{|x| x[1] == cTipo })
If nList > 0
	aList[nList][4] += xMoeda(nCusto,nMoedaCusto,nMoedaVis,dDataBase)
	nTotal += xMoeda(nCusto,nMoedaCusto,nMoedaVis,dDataBase)
Else
	dbSelectArea("SX5")
	dbSeek(xFilial()+"02"+cTipo)
	aAdd(aList,{cTipo,X5Descri(),Alltrim(SuperGetMv('MV_SIMB'+Alltrim(STR(nMoedaVis,2,0)))),xMoeda(nCusto,nMoedaCusto,nMoedaVis,dDataBase),0})
	aAdd(aLegenda,cTipo+'  : '+X5DESCRI())
	nTotal += aList[Len(aList)][4]
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms103Qt  ³ Autor ³ Fernando Dourado      ³ Data ³ 25-04-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que converte as 1a. -> 2a. unidade de medida		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pms103Qt()

Local nPosQTSeg := aScan(aHeader,{|x| AllTrim(x[2])=="AF3_QTSEGU"})
Local nPosProdut:= aScan(aHeader,{|x| AllTrim(x[2])=="AF3_PRODUT"})
Local nQuant := &(ReadVar())
Local nRet 	:= ConvUM(aCols[n][nPosProdut],nQuant,0,2)
If nRet > 0
	aCols[n][nPosQtSeg] := nRet 
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms1032Qt ³ Autor ³ Fernando Dourado      ³ Data ³ 25-04-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que converte as 2a. -> 1a. unidade de medida		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pms1032Qt()

Local nPosQuant := aScan(aHeader,{|x| AllTrim(x[2])=="AF3_QUANT"})
Local nPosProdut:= aScan(aHeader,{|x| AllTrim(x[2])=="AF3_PRODUT"})
Local nQuant2 := &(ReadVar())
Local nRet 		:= ConvUM(aCols[n][nPosProdut],0,nQuant2,1)

If nRet > 0
	aCols[n][nPosQuant] := nRet
EndIf


Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS103PRED³ Autor ³ Edson Maricate        ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da Predecessora da tarefa.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA103                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS103PRED()
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cPredec	:= &(ReadVar())

If !Empty(cPredec)
	If cPredec!=M->AF2_TAREFA
		lRet := ExistCpo("AF2",M->AF2_ORCAME+cPredec,1)
	Else
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS103PRDE³ Autor ³ Edson Maricate        ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da Predecessora da tarefa ( EDT )         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA103                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS103PrdE()
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cPredec	:= &(ReadVar())

If !Empty(cPredec)
	If cPredec!=M->AF2_EDTPAI
		lRet := ExistCpo("AF5",M->AF2_ORCAME+cPredec,2)
	Else
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GDDel    ³ Autor ³Fabio Rogerio Pereira³ Data ³01-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a exclusao do item da getdados						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103				                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103GDDel(nGet)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente valida a exclusao de itens para opcao diferente de Visualizar.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (oGD[nGet]:nOpc <> 2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o custo da tarefa.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistTemplate("CCTAF2CUSTO")
		ExecTemplate("CCTAF2CUSTO",.F.,.F.,{nGet})
	Else
		aRetCus	:= PmsAF2CusTrf(nGet)
		M->AF2_CUSTO := aRetCus[1]
		M->AF2_CUSTO2 := aRetCus[2]	
		M->AF2_CUSTO3 := aRetCus[3]	
		M->AF2_CUSTO4 := aRetCus[4]
		M->AF2_CUSTO5 := aRetCus[5]   
		If cPaisLoc == "BOL"
			M->AF2_VALIT  := (M->AF2_IT*(M->AF2_VALBDI+M->AF2_VALUTI+M->AF2_CUSTO))/100   
			M->AF2_VALUTI := (M->AF2_UTIL*(M->AF2_VALBDI+M->AF2_VALIT+M->AF2_CUSTO))/100  
		EndIf
		M->AF2_VALBDI:= aRetCus[1]*IIf(M->AF2_BDI <> 0,M->AF2_BDI,PmsGetBDIPad('AF2',M->AF2_ORCAME,,M->AF2_EDTPAI, M->AF2_UTIBDI ) )/100
		M->AF2_TOTAL := aRetCus[1]+M->AF2_VALBDI+IIf(cPaisLoc == "BOL",M->AF2_VALIT+M->AF2_VALUTI,0)  
	
	EndIf
		

	oEnch:Refresh()
EndIf

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms103Loop³ Autor ³ Adriano Ueda          ³ Data ³ 22-04-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se existe alguma referencia circular no orcamento.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms103Loop(cOrc,cTarefa,cTskChk)
Local lRet 		:= .T.
Local aArea 	:= GetArea()
Local aAreaAF7	:= AF7->(GetArea())

dbSelectArea("AF7")
AF7->(dbSetOrder(1))
AF7->(dbSeek(xFilial("AF7")+cOrc+cTarefa))

While lRet .And. !Eof() .And. xFilial("AF7")+cOrc+cTarefa==;
					AF7_FILIAL+AF7_ORCAME+AF7_TAREFA
	If AF7->AF7_PREDEC == cTskChk
		lRet := .F.
		Exit
	EndIf
	lRet := Pms103Loop(AF7->AF7_ORCAME,AF7->AF7_PREDEC,cTskChk)
	dbSelectArea("AF7")
	dbSkip()
End

RestArea(aAreaAF7)
RestArea(aArea)

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GD4FieldOk³ Autor ³ Edson Maricate    ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao Field Ok na GetDados 4                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA103                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103GD4FieldOk()
Local cCampo		:= ReadVar()
Local lRet			:= .T.
Local nPosRec		:= aScan(aHeader,{|x|AllTrim(x[2])=="AF3_RECURS"})
Local nPosProd		:= aScan(aHeader,{|x|AllTrim(x[2])=="AF3_PRODUT"})
Local nPosCUSTD		:= aScan(aHeader,{|x|AllTrim(x[2])=="AF3_CUSTD"})
Local nPosQt		:= aScan(aHeader,{|x|AllTrim(x[2])=="AF3_QUANT"})
Local nPosDescri	:= aScan(aHeader,{|x|AllTrim(x[2])=="AF3_DESCRI"})
Local nPosMoeda		:= aScan(aHeader,{|x|AllTrim(x[2])=="AF3_MOEDA"})

Do Case
	Case cCampo == "M->AF3_RECURS"
	   If ! Empty(M->AF3_RECURS)
			AE8->(dbSetOrder(1))
			AE8->(dbSeek(xFilial()+M->AF3_RECURS))
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial()+AE8->AE8_PRODUT))
			aCols[n][nPosDescri] := AE8->AE8_DESCRI
			If !Empty(AE8->AE8_PRODUT)
				aCols[n][nPosProd] 		:= AE8->AE8_PRODUT
				aCols[n][nposCustD]		:= RetFldProd(SB1->B1_COD,"B1_CUSTD")
			EndIf
			If !Empty(AE8->AE8_VALOR)
				aCols[n][nposCustD]		:= AE8->AE8_VALOR
			EndIf
			If Empty(AE8->AE8_PRODUT) .And. Empty(AE8->AE8_VALOR)
				aCols[n][nPosProd] 		:= CriaVar("AE8_PRODUT")
				aCols[n][nposCustD]		:= CriaVar("B1_CUSTD")
			EndIf
		Else
			M->AF3_RECURS           := CriaVar(cCampo)
			aCols[n][nPosRec] 		:= CriaVar(cCampo)
			aCols[n][nPosProd] 		:= CriaVar("AE8_PRODUT")
			aCols[n][nposCustD]		:= CriaVar("B1_CUSTD")
			aCols[n][nPosDescri]	:= CriaVar("B1_DESC")
		EndIf
		
//		aCols[n][nPosQt]		:= 0
		
	Case cCampo == "M->AF3_QUANT"
		AE8->(dbSetOrder(1))
		If AE8->(dbSeek(xFilial()+aCols[n][nPosRec]))
			aCols[n][nPosQt] 		:= &cCampo
		Else
			M->AF3_QUANT            := 0
			aCols[n][nPosQt]		:= 0
		EndIf
	Case cCampo == "M->AF3_CUSTD"
		aCols[n][nposCustD] := &cCampo
	
	Case cCampo == "M->AF3_MOEDA"
		aCols[n][nposMoeda] := &cCampo
	
EndCase

If ExistTemplate("CCTAF2CUSTO")
	ExecTemplate("CCTAF2CUSTO",.F.,.F.,{4})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o custo da tarefa.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetCus	:= PmsAF2CusTrf(4)
	M->AF2_CUSTO := aRetCus[1]
	M->AF2_CUSTO2 := aRetCus[2]	
	M->AF2_CUSTO3 := aRetCus[3]	
	M->AF2_CUSTO4 := aRetCus[4]						
	M->AF2_CUSTO5 := aRetCus[5]               
	If cPaisLoc == "BOL"
		M->AF2_VALIT  := (M->AF2_IT*(M->AF2_VALBDI+M->AF2_VALUTI+M->AF2_CUSTO))/100   
		M->AF2_VALUTI := (M->AF2_UTIL*(M->AF2_VALBDI+M->AF2_VALIT+M->AF2_CUSTO))/100  
	EndIf
	M->AF2_VALBDI:= aRetCus[1]*IIf(M->AF2_BDI <> 0,M->AF2_BDI,PmsGetBDIPad('AF2',M->AF2_ORCAME,,M->AF2_EDTPAI, M->AF2_UTIBDI ) )/100
	M->AF2_TOTAL := aRetCus[1]+M->AF2_VALBDI+IIf(cPaisLoc == "BOL",M->AF2_VALIT+M->AF2_VALUTI,0)	 	  

EndIf	

Return lRet

Function Chk103CCTOk()

If ExistTemplate("CCTAF2Calc")
	ExecTemplate("CCTAF2Calc",.F.,.F.,{oFolder:nOption})
EndIf

Return .T. 

Function A103SVCols(aHeaderSV,aColsSV,aSavN,nGetDados)

If nGetDados <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nGetDados])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva o conteudo da GetDados se existir              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsSV[nGetDados]		:= aClone(aCols)
	aHeaderSV[nGetDados]	:= aClone(aHeader)
	aSavN[nGetDados]		:= n
	
	aCols			:= aColsSV[nGetDados]
	aHeader			:= aHeaderSV[nGetDados]
	n      			:= aSavN[nGetDados]
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³30/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,"AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
							{ STR0003,"PMS103Dlg", 0 , 2},; //"Visualizar"
							{ STR0004,"PMS103Dlg", 0 , 3},; //"Incluir"
							{ STR0005,"PMS103Dlg", 0 , 4},; //"Alterar"
							{ STR0006,"PMS103Dlg", 0 , 5},; //"Excluir"
							{ STR0007,"MSDOCUMENT",0,4 }} //"Conhecimento"
Return(aRotina)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

//------------------------------------------------------------------
/*/{Protheus.doc} VldOrcPMS()
	Verifica se orçamento foi gerado a partir de uma Proposta comercial.

	@sample		VldOrcPMS()	
	@author 	Squad CRM & Faturamento
	@since 		04/03/2020
	@version 	P12
	@return 	lRet , Lógico , Se orçamento gerado a partir da proposta retorna verdadeiro.
/*/
//-------------------------------------------------------------------
Static Function VldOrcPMS()

	Local aArea			:= GetArea()
	Local cAliasADZ		:= GetNextAlias()
	Local cOrcamento	:= AF5->AF5_ORCAME
	Local lOrcsPms		:= SuperGetMV('MV_ORCSPMS',.F.,.F.)
	Local lRet			:= .F.

	If lOrcsPms
		BeginSql Alias cAliasADZ
		SELECT
			ADZ_PMS
		FROM 
			%table:ADZ% ADZ
		WHERE 
			ADZ_FILIAL = %xfilial:ADZ%
			AND ADZ.ADZ_PMS = %exp:cOrcamento%
			AND ADZ.%notDel%
    	EndSQL

		If (cAliasADZ)->(!Eof())
			lRet := .T.
		Endif

		(cAliasADZ)->(DbCloseArea())
	Endif

	RestArea(aArea)
	aSize(aArea, 0)

Return lRet 