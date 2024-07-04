#INCLUDE "pcoa463.ch"
#INCLUDE "PROTHEUS.CH"

/*
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA463  ³ AUTOR ³ Paulo Carnelossi      ³ DATA ³ 26/03/08   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa para manutencao Relacionamento entre Grupos Verbas  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA463                                                      ³±±
±±³_DESCRI_  ³ Programa para manutencao de Relacionamento Entre Grupo Verbas³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal    ³±±
±±³          ³ partir do Menu ou a partir de uma funcao pulando assim o     ³±±
±±³          ³ browse principal e executando a chamada direta da rotina     ³±±
±±³          ³ selecionada.                                                 ³±±
±±³          ³ Exemplo: PCOA463(2) - Executa a chamada da funcao de visua-  ³±±
±±³          ³                        zacao da rotina.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Chamada direta sem passar pela mBrowse               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PCOA463(nCallOpcx, lAuto, lProc)
Local xOldInt
Local lOldAuto
Local lRet := .T.

Default lProc := .F.

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	If !lProc
		__cInternet := 'AUTOMATICO'
	Endif
EndIf

Private cCadastro	:= STR0001 //"Roteiro Verbas Salariais Relacionadas"
Private aRotina := MenuDef()

dbSelectArea("AMA")
dbSetOrder(1)

If nCallOpcx <> Nil
	lRet := A463DLG("AMA",AMA->(RecNo()),nCallOpcx,lAuto)

Else
	cFiltro	:= PcoFilConf("AMA")
	
	If !Empty(cFiltro)
		MBrowse(6,1,22,75,"AMA",,,,,,,,,,,,,,cFiltro)
	EndIf
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A463DLG   ºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- º±±
±±º          ³ zacao                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A463DLG(cAlias,nRecnoAMA,nCallOpcx,lAuto)
Local oDlg
Local lCancel  := .F.
Local aButtons	:= {}
Local aUsButtons := {}
Local oEnchAMA

Local aHeadAM7
Local aHeadAMA
Local aColsAM7
Local nLenAM7   := 0 // Numero de campos em uso no AM7
Local nLinAM7   := 0 // Linha atual do acols
Local aRecAM7   := {} // Recnos dos registros
Local nGetD

Local aCposEnch
Local aUsField
Local aAreaAMA := AMA->(GetArea()) // Salva Area do AMA
Local aAreaAM7 := AM7->(GetArea()) // Salva Area do AM7

Local aEnchAuto  // Array com as informacoes dos campos da enchoice qdo for automatico 
Local aGetDAuto  // Array com as informacoes dos campos da getdados qdo for automatico
Local xOldInt
Local lOldAuto
Local lOk := .F.
Local nX
Local cIdGrup
Local lProc := .F.
Local bConfirma := {|| lOk := A463Ok(nCallOpcx,oGdAM7:Cargo,aEnchAuto,oGdAM7:aCols,oGdAM7:aHeader,aGetDAuto), If(lOk, oDlg:End(),NIL) }
Local bCancela 	:= {|| lCancel := .T., oDlg:End() }
Local aCposVisual := {}
Local nPos_Sequen

If ValType(lAuto) != "L"
	lAuto := .F.
EndIf

Private INCLUI  := (nCallOpcx = 3)

Private oGdAM7
PRIVATE aTELA[0][0],aGETS[0]

If lAuto

	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	If !lProc
		__cInternet := 'AUTOMATICO'
	Endif
	
EndIf

If lAuto .And. nCallOpcx != 4
	Return .F.
EndIf

If nCallOpcx != 3 .And. ValType(nRecnoAMA) == "N" .And. nRecnoAMA > 0

	DbSelectArea(cAlias)
	DbGoto(nRecnoAMA)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoAMA)))
		Return .F.
	EndIf
	aAreaAMA := AMA->(GetArea()) // Salva Area do AM7 por causa do Recno e do Indice
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOA4632" )

	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para inclusao de botoes de usuarios         ³
	//P_E³ na tela de Relacionamento entre Grupos de Grupos de Verbas             ³
	//P_E³ Parametros : Nenhum                                                    ³
	//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
	//P_E³  Ex. :  User Function PCOA4632                                         ³
	//P_E³         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If ValType( aUsButtons := ExecBlock( "PCOA4632", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

If !lAuto
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 480,650 PIXEL  //"Roteiro Verbas Salariais Relacionadas"
	oDlg:lMaximized := .T.
EndIf

aCposEnch := {"AMA_CODIGO","AMA_DESCRI","AMA_VARCOD","AMA_TPCOD","NOUSER"}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para adicionar campos no cabecalho                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOA4633" )                                                 

	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para adicionar campos no cabecalho          ³
	//P_E³ Parametros : Nenhum                                                    ³
	//P_E³ Retorno    : Array contendo as os campos a serem adicionados           ³
	//P_E³               Ex. :  User Function PCOA4633                            ³
	//P_E³                      Return {"AM7_FIELD1","AM7_FIELD2"}                ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType( aUsField := ExecBlock( "PCOA4633", .F., .F. ) ) == "A"
		AEval( aUsField, { |x| AAdd( aCposEnch, x ) } )
	EndIf
	
EndIf

// Carrega dados do AMA para memoria
RegToMemory("AMA",INCLUI)

If INCLUI
	If !Empty(MV_PAR02)
		M->AMA_TPCOD	:= MV_PAR02
	Endif
	
	If !Empty(MV_PAR03)
		M->AMA_VARCOD	:= MV_PAR03
	Endif
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do AM7                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadAM7 := GetaHeader("AM7",,{"AM7_IDGRUP","AM7_DESCRI"},@aGetDAuto,aCposVisual, .T. /*lWalk_Thru*/)

If !lAuto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enchoice com os dados dos Lancamentos                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEnchAMA := MSMGet():New('AMA',,nCallOpcx,,,,aCposEnch,{0,0,40,40},,,,,,oDlg,,,,,,,,,)
	oEnchAMA:oBox:Align := CONTROL_ALIGN_TOP
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do AMA                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadAMA := GetaHeader("AMA",, aCposEnch ,@aEnchAuto,aCposVisual, .T. /*lWalk_Thru*/)

nLenAM7  := Len(aHeadAM7) + 1

nPos_ALI_WT := AScan(aHeadAM7,{|x| Upper(AllTrim(x[2])) == "AM7_ALI_WT"})
nPos_REC_WT := AScan(aHeadAM7,{|x| Upper(AllTrim(x[2])) == "AM7_REC_WT"})
nPos_Sequen := AScan(aHeadAM7,{|x| Upper(AllTrim(x[2])) == "AM7_SEQUEN"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols do AM7                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aColsAM7 := {}
DbSelectArea("AM7")
DbSetOrder(1)
DbSeek(xFilial()+AMA->AMA_CODIGO)

cIdGrup := AM7->AM7_FILIAL + AM7->AM7_IDGRUP
While nCallOpcx != 3 .And. !Eof() .And. AM7->AM7_FILIAL + AM7->AM7_IDGRUP == cIdGrup
	AAdd(aColsAM7,Array( nLenAM7 ))
	nLinAM7++
	
	// Varre o aHeader para preencher o acols
	AEval(aHeadAM7, {|x,y| aColsAM7[nLinAM7][y] := If(Alltrim(x[2])$"AM7_ALI_WT|AM7_REC_WT",NIL,If(x[10] == "V" , CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) )) })
	
	If nPos_ALI_WT > 0
		aColsAM7[nLinAM7][nPos_ALI_WT] := "AM7"
	EndIf
	
	If nPos_REC_WT > 0
		aColsAM7[nLinAM7][nPos_REC_WT] := AM7->(Recno())
	EndIf
	
	// Deleted
	aColsAM7[nLinAM7][nLenAM7] := .F.
	AAdd( aRecAM7, AM7->( Recno() ) )
	
	AM7->(DbSkip())
	
EndDo

// Verifica se não foi criada nenhuma linha para o aCols
If Len(aColsAM7) = 0
	AAdd(aColsAM7,Array( nLenAM7 ))
	nLinAM7++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAM7, {|x,y| aColsAM7[nLinAM7][y] := If( ! (x[2]$"AM7_ALI_WT|AM7_REC_WT"), CriaVar(AllTrim(x[2])), NIL) } )
	
	If nPos_Sequen > 0
		aColsAM7[nLinAM7][nPos_Sequen] := StrZero(1, Len(AM7->AM7_SEQUEN))
	EndIf
	
	If nPos_ALI_WT > 0
		aColsAM7[nLinAM7][nPos_ALI_WT] := "AM7"
	EndIf
	
	If nPos_REC_WT > 0
		aColsAM7[nLinAM7][nPos_REC_WT] := 0
	EndIf
	
	// Deleted
	aColsAM7[nLinAM7][nLenAM7] := .F.
EndIf

If !lAuto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ GetDados com os Lancamentos                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nCallOpcx = 3 .Or. nCallOpcx = 4
		nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
	Else
		nGetD := 0
	EndIf
	oGdAM7:= MsNewGetDados():New(0,0,100,100,nGetd,"AM7LinOK",,"+AM7_SEQUEN",,,9999,,,,oDlg,aHeadAM7,aColsAM7)
	oGdAM7:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGdAM7:CARGO := AClone(aRecAM7)
	
	aButtons := aClone(AddToExcel(aButtons,{ 	{"ENCHOICE",,oEnchAMA:aGets,oEnchAMA:aTela},;
	{"GETDADOS",,oGdAM7:aHeader,oGdAM7:aCols} } ))
	
	If nCallOpcx != 3
		AMA->(RestArea(aAreaAMA)) // Retorna Area para que os dados da enchoice aparecam corretos
		oEnchAMA:Refresh()
	EndIf
	
	// Quando nao for MDI chama centralizada.
	If SetMDIChild()
		ACTIVATE MSDIALOG oDlg ON INIT ( oGdAM7:oBrowse:Refresh(), EnchoiceBar( oDlg, bConfirma, bCancela, , aButtons) )
	Else
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oGdAM7:oBrowse:Refresh(),EnchoiceBar( oDlg, bConfirma, bCancela, , aButtons) )
	EndIf
Else
	lCancel := ! A463Ok(nCallOpcx,aRecAM7,aEnchAuto,aColsAMA,aHeadAMA,aGetDAuto)
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

RestArea(aAreaAM7)
RestArea(aAreaAMA)
Return !lCancel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A463Ok   ºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao do botao OK da enchoice bar, valida e faz o         º±±
±±º          ³ tratamento adequado das informacoes.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A463Ok(nCallOpcx,aRecAM7,aEnchAuto,aColsAM7,aHeadAM7,aGetDAuto)
Local nI
Local nX
Local aValor
Local aAreaAM7	:= AM7->(GetArea())
Local lRegravou	:=	.F.
Local nPosField

If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If INCLUI
	If ! ExistChav('AM7',M->AMA_CODIGO)
		Return .F.
	Endif
Endif

If ! A463Vld(nCallOpcx,aRecAM7,aEnchAuto,aColsAM7,aHeadAM7,aGetDAuto)
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao ou acao programada por usuario         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOA4634" )
	If !ExecBlock("PCOA4634",.f.,.f.,{nCallOpcx,aEnchAuto,aColsAM7,aHeadAM7,aGetDAuto})
		Return .F.
	EndIf
EndIf

AM7->(DbSetOrder(1))

If nCallOpcx = 3 // Inclusao
    
	AMA->(Reclock("AMA",.T.))
	// Grava Campos do Cabecalho
	For nX := 1 To Len(aEnchAuto)
		nPosField := AMA->(FieldPos(aEnchAuto[nX][2]))
		If nPosField > 0
			AMA->(FieldPut(nPosField,&("M->"+aEnchAuto[nX][2])))
		EndIf
	Next nX
    
	// Grava campos que nao estao disponiveis na tela
	Replace AMA->AMA_CFGPLN With AMB->AMB_CODIGO
	Replace AMA->AMA_FILIAL With xFilial("AMA")
	If aScan(aEnchAuto, {|x| Alltrim(Upper(x[2]))=="AMA_TPCOD" } ) == 0
		Replace AMA->AMA_TPCOD With M->AMA_TPCOD
	EndIf
			
	AMA->(MsUnlock())


	// Grava Ítens do Roteiro
	For nI := 1 To Len(aColsAM7)			
	
		If aColsAM7[nI][Len(aColsAM7[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AM7",.T.)
		EndIf
		
		// Varre o aHeader e grava com base no acols
		AEval(aHeadAM7,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsAM7[nI][y])), ) })
		
		
		// Grava campos que nao estao disponiveis na tela
		AM7_FILIAL := xFilial("AM7")		
		AM7_IDGRUP := M->AMA_CODIGO
		AM7_DESCR  := M->AMA_DESCRI
		MsUnlock()
		
	Next nI
	
ElseIf nCallOpcx = 4 // Alteracao	
    
	If AMA->(dbSeek(xfilial("AMA") + M->AMA_CODIGO))
		// Grava Campos do Cabecalho
		Reclock("AMA",.F.)
		For nX := 1 To Len(aEnchAuto)
			nPosField := FieldPos(aEnchAuto[nX][2])
			If nPosField > 0
				FieldPut(nPosField,&( "M->" + aEnchAuto[nX][2] ))
			EndIf
		Next nX     
		MsUnlock()
	EndIf	

	// Grava Ítens do Roteiro
	For nI := 1 To Len(aColsAM7)
		
		lRegravou	:=	.F.
		If nI <= Len(aRecAM7) .And. aRecAM7[nI] > 0
			AM7->(DbGoto(aRecAM7[nI]))
			If aColsAM7[nI][Len(aColsAM7[nI])]
				lRegravou	:=	.T.
			EndIf
			Reclock("AM7",.F.)
		Else
			If aColsAM7[nI][Len(aColsAM7[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AM7",.T.)
			EndIf
			lRegravou := .T.
		EndIf
		
		If aColsAM7[nI][Len(aColsAM7[nI])] // Verifica se a linha esta deletada
			AM7->(DbDelete())
		Else
			
			// Varre o aHeader e grava com base no acols
			AEval(aHeadAM7,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsAM7[nI][y])), ) })		
			
			// Grava campos que nao estao disponiveis na tela
			AM7_FILIAL :=  xFilial("AM7") 
			AM7_IDGRUP :=  M->AMA_CODIGO
			AM7_DESCRI :=  M->AMA_DESCRI
			MsUnlock()
			
			
			dbSelecTArea("AM7")
			
		EndIf
		
	Next nI
	
ElseIf nCallOpcx = 5 // Exclusao

	// Exclui Cabeçalho	
	If AMA->(dbSeek(xfilial("AMA") + M->AMA_CODIGO))
		Reclock("AMA",.F.)
		AMA->(DbDelete())
		MsUnlock()
	Endif	

	// Exclui Ítens do Roteiro
	For nI := 1 To Len(aColsAM7)
		
		If nI <= Len(aRecAM7) .And. aRecAM7[nI] > 0
			AM7->(DbGoto(aRecAM7[nI]))
			
			Reclock("AM7",.F.)
			AM7->(DbDelete())
			MsUnLock()
		EndIf		
		
	Next nI
	
	
EndIf

AM7->(RestArea(aAreaAM7))

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A463Vld  ºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de validacao dos campos.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A463Vld(nCallOpcx,aRecAM7,aEnchAuto,aColsAM7,aHeadAM7)
Local nI

If !(nCallOpcx = 3 .Or. nCallOpcx = 4 .Or. nCallOpcx = 5)
	Return .T.
EndIf

If ( AScan(aEnchAuto,{|x| If(Alltrim(x[2])$"AMA_ALI_WT|AMA_REC_WT", .F., x[17] .And. Empty( &( "M->" + x[2] ) ) ) } ) > 0 )
	HELP("  ",1,"OBRIGAT")
	Return .F.
EndIf

For nI := 1 To Len(aColsAM7)
	If ! aColsAM7[nI,Len(aHeadAM7)+1] //valida somente os que nao estao deletados
		// Busca por campos obrigatorios que nao estejam preenchidos
		nPosField := AScanx(aHeadAM7,{|x,y| if(Alltrim(x[2])$"AM7_ALI_WT|AM7_REC_WT", .F. , x[17] .And. Empty(aColsAM7[nI][y])) })
		If nPosField > 0
			SX2->(dbSetOrder(1))
			SX2->(MsSeek("AM7"))
			HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0002+ AllTrim(aHeadAM7[nPosField][1])+CHR(10)+CHR(13)+STR0003+Str(nI,3,0),3,1)  //"Campo: "###"Linha: "
			Return .F.
		EndIf
	EndIf
Next nI

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoxGD1LinOK³ Autor ³ Edson Maricate      ³ Data ³ 17-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da LinOK da Getdados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AM7LinOK()
Local lRet			:= .T.

If !aCols[n][Len(aCols[n])]
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os campos obrigatorios do SX3.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		lRet := MaCheckCols(aHeader,aCols,n)
	EndIf
	
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³17/11/06 ³±±
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
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
Local aUsRotina := {}
Local aRotina 	:= {		{ STR0004	,		"AxPesqui" , 0 , 1, ,.F.},; //"Pesquisar"
{ STR0005	, 		"A463DLG"  , 0 , 2},; //"Visualizar"
{ STR0006	, 		"A463DLG"  , 0 , 3},; //"Incluir"
{ STR0007	, 		"A463DLG"  , 0 , 4},; //"Alterar"
{ STR0008	, 		"A463DLG"  , 0 , 5};  //"Excluir"
}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario no aRotina                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOA4631" )
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
	//P_E³ browse da tela de lançamentos                                          ³
	//P_E³ Parametros : Nenhum                                                    ³
	//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
	//P_E³               Ex. :  User Function PCOA4631                            ³
	//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType( aUsRotina := ExecBlock( "PCOA4631", .F., .F. ) ) == "A"
		AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
	EndIf
EndIf
Return(aRotina)