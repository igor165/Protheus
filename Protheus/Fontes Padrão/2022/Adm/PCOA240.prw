#INCLUDE "PCOA240.ch"
#INCLUDE "PROTHEUS.CH"
/*
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA240  ³ AUTOR ³ Paulo Carnelossi      ³ DATA ³ 25/08/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa para manutencao do cadastro de relatorios           ³±±
±±³          ³ Pre-Configurados                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA240                                                      ³±±
±±³_DESCRI_  ³ Programa para manutencao do cadastro de relatorios           ³±±
±±³          ³ Pre-Configurados                                             ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal    ³±±
±±³          ³ partir do Menu ou a partir de uma funcao pulando assim o     ³±±
±±³          ³ browse principal e executando a chamada direta da rotina     ³±±
±±³          ³ selecionada.                                                 ³±±
±±³          ³ Exemplo: PCOA240(2) - Executa a chamada da funcao de visua-  ³±±
±±³          ³                        zacao da rotina.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Chamada direta sem passar pela mBrowse               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA240(nCallOpcx,lAuto,aCposVs)

Local aUsRotina := {}
Local lRet      := .T.
Local xOldInt
Local lOldAuto

If ValType(lAuto) != "L"
	lAuto := .F.
EndIf

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	__cInternet := 'AUTOMATICO'
EndIf

Private M->AKR_ORCAME := Replicate("Z", Len(AKR->AKR_ORCAME)) //nao retirar pois eh utilizado em alguma consulta padrao F3
Private aCposVisual	:= aCposVs
Private cCadastro	:= STR0001 //"Manutenção do Cadastro de Relatorios Pre-Configurados"
Private aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1},;    //"Pesquisar"
{ STR0003, 	    "A240DLG"  , 0 , 2},;    //"Visualizar"
{ STR0004, 		"A240DLG"  , 0 , 3},;	  //"Incluir"
{ STR0005, 		"A240DLG"  , 0 , 4},; //"Alterar"
{ STR0006, 		"A240DLG"  , 0 , 5} } //"Excluir"

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario no aRotina                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA2401" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
		//P_E³ browse da tela de lançamentos                                          ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
		//P_E³               Ex. :  User Function PCOA2401                            ³
		//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA2401", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
	
	dbSelectArea("ALF")
	dbSetOrder(1)
	If nCallOpcx <> Nil
		lRet := A240DLG("ALF",ALF->(RecNo()),nCallOpcx,,,lAuto)
	Else
		mBrowse(6,1,22,75,"ALF",,,,,, )
	EndIf
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A240DLG   ºAutor  ³Paulo Carnelossi    º Data ³  25/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- º±±
±±º          ³ zacao                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A240DLG(cAlias,nRecnoALF,nCallOpcx,cR1,cR2,lAuto)
Local oDlg
Local lCancel  := .F.
Local aButtons	:= {{"PESQUISA",{||PcoA240Perg() },STR0014,STR0013} } //"Parametros do Relatorio"###"Parametro"
Local aUsButtons := {}
Local oEnchALF

Local aHeadALG
Local aColsALG
Local nLenALG   := 0 // Numero de campos em uso no ALG
Local nLinALG   := 0 // Linha atual do acols
Local aRecALG   := {} // Recnos dos registros
Local nGetD
Local cImpRel
Local aCposEnch
Local aUsField
Local aAreaALF := ALF->(GetArea()) // Salva Area do ALF
Local aAreaALG := ALG->(GetArea()) // Salva Area do ALF
Local aEnchAuto  // Array com as informacoes dos campos da enchoice qdo for automatico
Local xOldInt
Local lOldAuto
Local nRecALF := nRecnoALF
Local aCpos_Nao := {}

Private INCLUI  := (nCallOpcx = 3)
Private oGdALG
Private aTELA[0][0],aGETS[0]
Private lVazio := .T.

If !AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	Return .F.
EndIf

If ValType(lAuto) != "L"
	lAuto := .F.
EndIf

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	__cInternet := 'AUTOMATICO'
EndIf

If lAuto .And. !(nCallOpcx = 4 .Or. nCallOpcx = 6)
	Return .F.
EndIf

If nCallOpcx != 3 .And. ValType(nRecnoALF) == "N" .And. nRecnoALF > 0
	DbSelectArea(cAlias)
	DbGoto(nRecnoALF)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoALF)))
		Return .F.
	EndIf
	aAreaALF := ALF->(GetArea()) // Salva Area do ALF por causa do Recno e do Indice
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOA2402" )
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para inclusao de botoes de usuarios         ³
	//P_E³ na tela de configuracao dos lancamentos                                ³
	//P_E³ Parametros : Nenhum                                                    ³
	//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
	//P_E³  Ex. :  User Function PCOA2402                                         ³
	//P_E³         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If ValType( aUsButtons := ExecBlock( "PCOA2402", .F., .F. ) ) == "A"
		aButtons := {}
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

If !lAuto
	DEFINE MSDIALOG oDlg TITLE STR0010  FROM 0,0 TO 480,650 PIXEL//"Cadastro de Relatorios Pre-Configurados"
	oDlg:lMaximized := .T.
EndIf

aCposEnch := PcoCpoEnchoice("ALF", aCpos_Nao)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para adicionar campos no cabecalho                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOA2403" )
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para adicionar campos no cabecalho          ³
	//P_E³ Parametros : Nenhum                                                    ³
	//P_E³ Retorno    : Array contendo as os campos a serem adicionados           ³
	//P_E³               Ex. :  User Function PCOA2403                            ³
	//P_E³                      Return {"ALF_FIELD1","ALF_FIELD2"}                ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType( aUsField := ExecBlock( "PCOA2403", .F., .F. ) ) == "A"
		AEval( aUsField, { |x| AAdd( aCposEnch, x ) } )
	EndIf
EndIf

// Carrega dados do ALF para memoria
RegToMemory("ALF",INCLUI)

If !lAuto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enchoice com os dados dos Lancamentos                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEnchALF := MSMGet():New('ALF',,nCallOpcx,,,,aCposEnch,{0,0,50,23},,,,,,oDlg,,,,,,,,,)
	oEnchALF:oBox:Align := CONTROL_ALIGN_TOP
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do ALG                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadALG := GetaHeader("ALG",,aCposEnch,@aEnchAuto,aCposVisual)
nLenALG  := Len(aHeadALG) + 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols do ALG                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aColsALG := {}

If !INCLUI
	DbSelectArea("ALG")
	DbSetOrder(1)
	DbSeek(xFilial()+ALF->ALF_PRGREL+ALF->ALF_CFGREL)
	
	cImpRel := ALF->ALF_FILIAL + ALF->ALF_PRGREL + ALF->ALF_CFGREL
	While  ALG->(!Eof() .And. ALG_FILIAL+ALG_PRGREL+ALG_CFGREL == cImpRel)
		AAdd(aColsALG,Array( nLenALG ))
		nLinALG++
		// Varre o aHeader para preencher o acols
		AEval(aHeadALG, {|x,y| aColsALG[nLinALG][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })
		
		// Deleted
		aColsALG[nLinALG][nLenALG] := .F.
		
		// Adiciona o Recno no aRec
		AAdd( aRecALG, ALG->( Recno() ) )
		
		ALG->(DbSkip())
		
	EndDo
	
	If nLinALG != 0
		lVazio := .F.
	EndIf
	
EndIf

// Verifica se não foi criada nenhuma linha para o aCols
If Len(aColsALG) = 0
	AAdd(aColsALG,Array( nLenALG ))
	nLinALG++
	// Varre o aHeader para preencher o acols
	AEval(aHeadALG, {|x,y| aColsALG[nLinALG][y] := IIf(Upper(AllTrim(x[2])) == "ALG_ID", StrZero(1,Len(ALG->ALG_ID)),CriaVar(AllTrim(x[2])) ) })
	
	// Deleted
	aColsALG[nLinALG][nLenALG] := .F.
EndIf

If !lAuto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ GetDados com os Lancamentos                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nGetD := 0
		
	oGdALG:= MsNewGetDados():New(0,0,100,100,nGetd,"ALGLinOK",,/*"+ALG_ID"*/,,,nLinALG/*9999*/,,,,oDlg,aHeadALG,aColsALG)
	oGdALG:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGdALG:CARGO := AClone(aRecALG)
	oGdALG:oBrowse:bGotFocus := {|| A240ValPerg(nCallOpcx, aColsALG, aHeadALG, oGdALG) }
	oGdALG:AddAction("ALG_CNTPER",{|| Pco240Edt(oGdALG) })
	
	// Quando nao for MDI chama centralizada.
	If SetMDIChild()
		ACTIVATE MSDIALOG oDlg ON INIT (oGdALG:oBrowse:Refresh(),EnchoiceBar(oDlg,{|| If(obrigatorio(aGets,aTela).And.A240Ok(nCallOpcx,nRecALF,oGdALG:Cargo,aEnchAuto,oGdALG:aCols,oGdALG:aHeader),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons))
	Else
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oGdALG:oBrowse:Refresh(),EnchoiceBar(oDlg,{|| If(obrigatorio(aGets,aTela).And.A240Ok(nCallOpcx,nRecALF,oGdALG:Cargo,aEnchAuto,oGdALG:aCols,oGdALG:aHeader),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons) )
	EndIf
Else
	lCancel := !A240Ok(nCallOpcx,nRecALF,aRecALG,aEnchAuto,aColsALG,aHeadALG,lAuto)
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

RestArea(aAreaALG)
RestArea(aAreaALF)
Return !lCancel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A240Ok   ºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao do botao OK da enchoice bar, valida e faz o         º±±
±±º          ³ tratamento adequado das informacoes.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A240Ok(nCallOpcx,nRecALF,aRecALG,aEnchAuto,aColsALG,aHeadALG,lAuto)
Local nI
Local nX
Local aAreaALG	:= ALG->(GetArea())
Local aAreaALF	:= ALF->(GetArea())
Local aRecAux   := aClone(aRecALG)
Local bCampo 	:= {|n| FieldName(n) }

If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If !A240Vld(nCallOpcx,aRecALG,aEnchAuto,aColsALG,aHeadALG)
	Return .F.
EndIf

ALF->(DbSetOrder(1))
ALG->(DbSetOrder(1))

If nCallOpcx = 3 // Inclusao
	dbSelectArea("ALF")
	Reclock("ALF",.T.)
	// Grava Campos do Cabecalho
	If lAuto
		For nX := 1 To Len(aEnchAuto)
			FieldPut(FieldPos(aEnchAuto[nX][2]),&( "M->" + aEnchAuto[nX][2] ))
		Next nX
	Else
		For nx := 1 TO FCount()
			FieldPut(nx,M->&(EVAL(bCampo,nx)))
		Next nx
	EndIf
	ALF->ALF_FILIAL := xFilial("ALF")
	MsUnlock()
	
	// Grava Lancamentos
	For nI := 1 To Len(aColsALG)
		If aColsALG[nI][Len(aColsALG[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("ALG",.T.)
		EndIf
		
		// Varre o aHeader e grava com base no acols
		AEval(aHeadALG,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsALG[nI][y])), ) })
		
		// Grava campos que nao estao disponiveis na tela
		Replace ALG_FILIAL With xFilial()
		Replace ALG_PRGREL With ALF->ALF_PRGREL
		Replace ALG_CFGREL With ALF->ALF_CFGREL
		MsUnlock()
		
	Next nI
	
ElseIf nCallOpcx = 4 // Alteracao
	
	dbSelectArea("ALF")
	dbGoto(nRecALF)
	Reclock("ALF",.F.)
	
	// Grava Campos do Cabecalho
	If lAuto
		For nX := 1 To Len(aEnchAuto)
			FieldPut(FieldPos(aEnchAuto[nX][2]),&( "M->" + aEnchAuto[nX][2] ))
		Next nX
	Else
		For nx := 1 TO FCount()
			FieldPut(nx,M->&(EVAL(bCampo,nx)))
		Next nx
	EndIf
	MsUnlock()
	
	// Grava Lancamentos
	dbSelectArea("ALG")
	//primeiro exclui os registros
	For nI := 1 TO Len(aRecAux)
		dbGoto(aRecAux[nI])
		Reclock("ALG",.F.)
		dbDelete()
		MsUnlock()
	Next
	//depois grava novos registros
	For nI := 1 To Len(aColsALG)
		If aColsALG[nI][Len(aColsALG[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("ALG",.T.)
		EndIf
		
		// Varre o aHeader e grava com base no acols
		AEval(aHeadALG,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsALG[nI][y])), ) })
		
		// Grava campos que nao estao disponiveis na tela
		Replace ALG_FILIAL With xFilial()
		Replace ALG_PRGREL With ALF->ALF_PRGREL
		Replace ALG_CFGREL With ALF->ALF_CFGREL
		MsUnlock()
		
	Next nI
	
ElseIf nCallOpcx = 5 // Exclusao
	
	// Grava Lancamentos
	For nI := 1 To Len(aRecALG)
		dbGoto(aRecALG[nI])
		Reclock("ALG",.F.)
		dbDelete()
		MsUnlock()
	Next nI
	
	dbSelectArea("ALF")
	dbGoto(nRecALF)
	Reclock("ALF",.F.)
	dbDelete()
	MsUnlock()
	
EndIf

ALG->(RestArea(aAreaALG))
ALF->(RestArea(aAreaALF))

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A240Vld  ºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de validacao dos campos.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A240Vld(nCallOpcx,aRecALG,aEnchAuto,aColsALG,aHeadALG)
Local nI
Local nPosTipo
If !(nCallOpcx = 3 .Or. nCallOpcx = 4 .Or. nCallOpcx = 6)
	Return .T.
EndIf

Private aCols, aHeader, n

If ( AScan(aEnchAuto,{|x| x[17] .And. Empty( &( "M->" + x[2] ) ) } ) > 0 )
	HELP("  ",1,"OBRIGAT")
	Return .F.
EndIf

For nI := 1 To Len(aColsALG)
	// Busca por campos obrigatorios que nao estejam preenchidos
	nPosField := AScanx(aHeadALG,{|x,y| x[17] .And. Empty(aColsALG[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("ALG"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0015+ AllTrim(aHeadALG[nPosField][1])+CHR(10)+CHR(13)+STR0016+Str(nI,3,0),3,1) //"Campo: "###"Linha: "
		Return .F.
	EndIf
Next nI

//variaveis private para ser utilizado por ALGTudOK()
aCols := aColsALG
aHeader := aHeadALG
n       := 1

Return ALGTudOK()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ALGLinOK    ³ Autor ³ Paulo Carnelossi    ³ Data ³ 25/08/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da LinOK da Getdados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ALGLinOK()
Local lRet			:= .T.
Local nPosObriga
Local nPosPergCt
Local nPosFormul
Local nPosExecuc
Local cContPergt

If !aCols[n][Len(aCols[n])]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os campos obrigatorios do SX3.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		lRet := MaCheckCols(aHeader,aCols,n)
	EndIf
EndIf

If lRet
	//validar se informacao eh obrigatoria em caso positivo verificar campo
	//conteudo do pergunte ou formula do pergunte estao preechidos
	nPosObriga := AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "ALG_OBRIGA"})
	nPosPergCt := AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "ALG_CNTPER"})
	nPosFormul := AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "ALG_FORMUL"})
	nPosExecuc := AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "ALG_EXECUC"})
	If aCols[n, nPosExecuc] == "2"
		lRet := (nPosObriga > 0)
		If lRet .And. aCols[n, nPosObriga] == "1"
			lRet := (nPosPergCt > 0)
			If lRet
				cContPergt := StrTran(aCols[n, nPosPergCt],'"','')
				If Empty(cContPergt)
					lRet := (nPosFormul > 0)
					lRet := lRet .And. ! Empty(aCols[n, nPosFormul])
					If !lRet
						Aviso(STR0007, STR0009, {"Ok"}) //"Atencao"###"Campos Conteudo do Pergunte/Formula nao estao preenchidos e sao obrigatorios! Verifique."
					EndIf
				EndIf
			EndIf	
		EndIf
	EndIf	
EndIf

Return lRet

Function ALGTudOk()
Local lRet := .F.
Local nX, nLinAnt := n

For nX := 1 TO Len(aCols)
	n := nX
	lRet  := ALGLinOK()
	If !lRet
		Exit
	EndIf
Next	

n := nLinAnt

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoCpoEnchoiceºAutor ³Paulo Carnelossi º Data ³  11/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna array com nomes dos campos referente ao alias       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoCpoEnchoice(cAlias, aCpos_Nao)
Local aCampos := {}
Local aArea := GetArea()
Local aAreaSX3 := SX3->(GetArea())

SX3->(DbSetOrder(1))
SX3->(MsSeek(cAlias))

While ! SX3->(Eof()) .And. SX3->x3_arquivo == cAlias
	If X3USO(SX3->x3_usado) .And. cNivel >= SX3->x3_nivel .And. ;
		aScan(aCpos_Nao, AllTrim(SX3->x3_campo))==0
		aAdd(aCampos, AllTrim(SX3->x3_campo))
	EndIf
	SX3->(DbSkip())
EndDo

RestArea(aArea)
RestArea(aAreaSX3)

Return aCampos

Static Function PcoA240Perg()
Pergunte(M->ALF_GRPERG)
Return

Static Function A240ValPerg(nOpcx, aColsALG, aHeadALG)
Local lRet := .F.
Local nLinPerg
Local nLenALG  := Len(aHeadALG) + 1
Local nLinALG  := 0
Local aArea := GetArea()
Local aAreaSX1 := SX1->(GetArea())
Local nPosOrdem := AScan(aHeadALG,{|x| Upper(AllTrim(x[2])) == "ALG_ORDPER"})
Local nPosDescri := AScan(aHeadALG,{|x| Upper(AllTrim(x[2])) == "ALG_DESPER"})

If nOpcx == 3  //inclusao
	//carrega acols com dados do SX1 (Pergunte)
	//carrega o acols baseado no Pergunte
	dbSelectArea("SX1")
	dbSetOrder(1)
	
	If dbSeek(M->ALF_GRPERG+"01")
		If lVazio
			aColsALG := {}
			While SX1->(!Eof() .And. X1_GRUPO == Alltrim(Upper(M->ALF_GRPERG)))
				AAdd(aColsALG,Array( nLenALG ))
				nLinALG++
				
				// Varre o aHeader para preencher o acols
				AEval(aHeadALG, {|x,y| aColsALG[nLinALG][y] := CriaVar(AllTrim(x[2])) })
				
				// Deleted
				aColsALG[nLinALG][nLenALG] := .F.
				
				aColsALG[nLinALG, nPosOrdem] := SX1->X1_ORDEM
				aColsALG[nLinALG, nPosDescri] := X1PERGUNT()
				
				SX1->(dbSkip())
			End
			
			oGdALG:aCols := aColsALG
			oGdALG:oBrowse:Refresh()
			oGdALG:lUpdate := .T.
			lVazio := .F.
			lRet := .T.
		EndIf
	Else
		Aviso(STR0007, STR0011, {"Ok"})//"Atencao"###"Grupo de perguntas do relatorio nao existente! Verifique."
		lRet := .F.
	EndIf
	
	
ElseIf nOpcx == 4  //alteracao
	//valida se numero linhas do acols corresponde ao numero de linhas do pergunte
	nLinPerg := 0
	dbSelectArea("SX1")
	dbSetOrder(1)
	If dbSeek(ALF->ALF_GRPERG+"01")
		While SX1->(!Eof() .And. X1_GRUPO == Alltrim(Upper(ALF->ALF_GRPERG)))
			nLinPerg++
			SX1->(dbSkip())
		End
	EndIf
	
	If Len(aColsALG) == nLinPerg
		oGdALG:lUpdate := .T.
		lRet := .T.
	Else
		Aviso(STR0007, STR0012, {"Ok"})//"Atencao"##"Parametros do relatorio foi alterado ! Verifique."
		lRet := .F.
	EndIf
Else //visualizacao ou exclusao
	lRet := .T.
EndIf

RestArea(aAreaSX1)
RestArea(aArea)

Return(lRet)

Static Function Pco240Edt(oGdALG)
Local oDlg
Local oRect
Local oGet1
Local oBtn
Local cMacro := ''
Local cPict	:= ''
Local nRow   := oGdALG:oBrowse:nAt
Local oOwner := oGdALG:oBrowse:oWnd
Local cValid := 'Eval(bChange)'
Local xValor := NIL
Local cVlrFinal := ""
Local lContinua	:= .T.
Local cTipoEdt := ""
Local lGetAltera := .F.
Local aProprSX1 := A240TpEdic(oGdALG)

xValor := oGdALG:aCols[nRow,oGdALG:oBrowse:ColPos]
cTipoEdt := aProprSX1[1]

If Empty(cTipoEdt)
	Return(xValor)
EndIf

xValor := Alltrim( StrTran(oGdALG:aCols[nRow,oGdALG:oBrowse:ColPos],'"','') )

If aProprSX1[4]=="C"  //se for combo box
	If "]"$xValor
		xValor := Subs(xValor,2,1)
	EndIf	
EndIf

If Empty(xValor)
	If 		cTipoEdt == "C"
		xValor := Space(aProprSX1[2])
	ElseIf 	cTipoEdt == "D"
		xValor := CtoD("  /  /  ")
	Else
		xValor := If(aProprSX1[3]==0, 0, Val( "0."+Repl("0", aProprSX1[3]) ) )
	EndIf
Else
	If 		cTipoEdt == "C"
		xValor := PadR(xValor, aProprSX1[2])
	ElseIf 	cTipoEdt == "D"
		xValor := CtoD(xValor)
	Else
		xValor := Val(xValor)
	EndIf
EndIf
bChange := { ||  xValor := &cMacro }
oRect := tRect():New(0,0,0,0)            // obtem as coordenadas da celula (lugar onde
oGdALG:oBrowse:GetCellRect(oGdALG:oBrowse:nColPos,,oRect)   // a janela de edicao deve ficar)
aDim  := {oRect:nTop,oRect:nLeft,oRect:nBottom,oRect:nRight}

DEFINE MSDIALOG oDlg OF oOwner  FROM 0, 0 TO 0, 0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL

cMacro := "M->CELL"
&cMacro:= xValor

If aProprSX1[4]=="G"
	@ 0,0 MSGET oGet1 VAR &(cMacro) SIZE 0,0 OF oDlg FONT oOwner:oFont PICTURE cPict PIXEL HASBUTTON VALID &cValid
	If !Empty(aProprSX1[6])
		oGet1:cF3 := aProprSX1[6]
	EndIf	
Else   // se nao eh combo
	oGet1:=TComboBox():New( 0, 0, &("{ | u | If( PCount() == 0, M->CELL, M->CELL:=u ) }"),aProprSX1[5], 80, 10, oDlg, ,,       ,,,.T.,,,.F.,&("{||.T.}"),.T.,,)
EndIf	
oGet1:Move(-2,-2, (aDim[ 4 ] - aDim[ 2 ]) + 4, aDim[ 3 ] - aDim[ 1 ] + 4 )

@ 0,0 BUTTON oBtn PROMPT "" SIZE 0,0 OF oDlg
oBtn:bGotFocus := {|| lGetAltera := .T.,oDlg:nLastKey := VK_RETURN, oDlg:End(0)}

oGet1:cReadVar  := cMacro

ACTIVATE MSDIALOG oDlg ON INIT oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

If aProprSX1[4]=="C" .And. ! lGetAltera //Se for combo
	Return(oGdALG:aCols[nRow,oGdALG:oBrowse:ColPos])
EndIf	

If 		cTipoEdt == "C"
	cVlrFinal := '"'+xValor+'"'
ElseIf cTipoEdt == "D"
	cVlrFinal := '"'+DtoC(xValor)+'"'
Else
	If aProprSX1[4]=="C" .And. lGetAltera //Se for combo
		If ValType(M->CELL) != "N"
			xValor := ASCAN(aProprSX1[5], M->CELL)
		Else
			xValor := M->CELL
		EndIf
		If xValor == 0
			xValor := 1 //se digitado valor invalido assume a 1a.opcao do combo
		EndIf
		M->CELL := aProprSX1[5,xValor]
		cVlrFinal := "["+Str(xValor,1)+"] - "+M->CELL
	Else	
		cVlrFinal := '"'+If(aProprSX1[3]==0, ;
						Transform(xValor,Repl("9", aProprSX1[2])),;
						Transform(xValor,Repl("9", aProprSX1[2])+"."+Repl("9",aProprSX1[3])))+'"'
	EndIf
End

oGdALG:aCols[n][oGdALG:oBrowse:nColPos]	:= cVlrFinal
oGdALG:oBrowse:nAt := nRow

SetFocus(oGdALG:oBrowse:hWnd)
oGdALG:oBrowse:Refresh()

Return(cVlrFinal)

Static Function A240TpEdic(oGdALG)
Local aArea := GetArea()
Local aAreaSX1 := SX1->(GetArea())
Local nPosOrdem := AScan(oGdALG:aHeader,{|x| Upper(AllTrim(x[2])) == "ALG_ORDPER"})
Local cTipoEdt := ""
Local nTamanho := 0
Local nDecimal := 0
Local nGerCombo := ""
Local aCombo := {}, cFunc := "", nX, cCombo,cF3,cValid

dbSelectArea("SX1")
dbSetOrder(1)
If dbSeek(M->ALF_GRPERG+oGdAlg:Acols[oGdAlg:oBrowse:nAt, nPosOrdem])
	cTipoEdt 	:= SX1->X1_TIPO
	nTamanho 	:= SX1->X1_TAMANHO
	nDecimal 	:= SX1->X1_DECIMAL
	cF3         := SX1->X1_F3
	cValid      := SX1->X1_VALID
	cGerCombo 	:= SX1->X1_GSC
	If cGerCombo == "C"
		For nX := 1 TO 5
			cFunc := "X1DEF"+StrZero(nX,2)+"()"
			cCombo := &(cFunc)
			If !Empty(cCombo)
				aAdd(aCombo, cCombo)
			EndIf
		Next
		If Empty(aCombo)
			aAdd(aCombo, STR0017)//"Opcao 1"
		EndIf								
	EndIf
EndIf

RestArea(aAreaSX1)
RestArea(aArea)

Return( { cTipoEdt, nTamanho, nDecimal, cGerCombo, aCombo, cF3, cValid} )