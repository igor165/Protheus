#INCLUDE "PCOA210.ch"
#INCLUDE "PROTHEUS.CH"


Static aCombo := NIL
Static cConteudo := NIL
Static aSelOpc := {}

/*
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA210  ³ AUTOR ³ Paulo Carnelossi      ³ DATA ³ 25/08/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa para manutencao restricao de acessos usuarios as    ³±±
±±³          ³ entidades                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA210                                                      ³±±
±±³_DESCRI_  ³ Programa para manutencao restricao de acessos usuarios as    ³±±
±±³          ³ entidades                                                    ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal    ³±±
±±³          ³ partir do Menu ou a partir de uma funcao pulando assim o     ³±±
±±³          ³ browse principal e executando a chamada direta da rotina     ³±±
±±³          ³ selecionada.                                                 ³±±
±±³          ³ Exemplo: PCOA210(2) - Executa a chamada da funcao de visua-  ³±±
±±³          ³                        zacao da rotina.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Chamada direta sem passar pela mBrowse               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA210(nCallOpcx,lAuto,aCposVs, nUtiliz)


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

Default nUtiliz := 1


Private aCposVisual	:= aCposVs
Private cCadastro	:= STR0001 //"Manutenção de Restricao de Usuarios as Entidades"
Private aRotina := MenuDef()

	dbSelectArea("AL6")
	dbSetOrder(1)
	If nCallOpcx <> Nil
		lRet := A210DLG("AL6",AL6->(RecNo()),nCallOpcx,,,lAuto, nUtiliz)
	Else
		mBrowse(6,1,22,75,"AL6",,,,,,PCOA210Leg() )
	EndIf


lMsHelpAuto := lOldAuto
__cInternet := xOldInt

aCombo := NIL
cConteudo := NIL
aSelOpc := {}

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A210DLG   ºAutor  ³Paulo Carnelossi    º Data ³  25/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- º±±
±±º          ³ zacao                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A210DLG(cAlias,nRecnoAL6,nCallOpcx,cR1,cR2,lAuto,nUtiliz)
Local oDlg
Local lCancel  := .F.
Local aButtons	:= {{"PESQUISA",{||PcoA210Pesq() },STR0014,STR0013} } //"Consulta Padrao"###"Pesquisa"
Local aUsButtons := {}
Local oEnchAL6

Local aHeadAL7
Local aColsAL7
Local nLenAL7   := 0 // Numero de campos em uso no AL7
Local nLinAL7   := 0 // Linha atual do acols
Local aRecAL7   := {} // Recnos dos registros
Local nGetD
Local cEntidade
Local aCposEnch
Local aUsField
Local aAreaAL6 := AL6->(GetArea()) // Salva Area do AL6
Local aAreaAL7 := AL7->(GetArea()) // Salva Area do AL6
Local aEnchAuto  // Array com as informacoes dos campos da enchoice qdo for automatico
Local xOldInt
Local lOldAuto
Local nRecAL6 := nRecnoAL6
Local aCpos_Nao := {}
Local oSize
Local nLinIni := 0 
Local nColIni := 0 
Local nLinEnd := 0
Local nColEnd := 0 

DEFAULT nUtiliz := 1

Private INCLUI  := (nCallOpcx = 3)
Private oGdAL7
PRIVATE aTELA[0][0],aGETS[0]

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

If nCallOpcx != 3 .And. ValType(nRecnoAL6) == "N" .And. nRecnoAL6 > 0
	DbSelectArea(cAlias)
	DbGoto(nRecnoAL6)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoAL6)))
		Return .F.
	EndIf
	aAreaAL6 := AL6->(GetArea()) // Salva Area do AL6 por causa do Recno e do Indice
EndIf

If nCallOpcx == 5 .And. AL6->AL6_ATIVO == "1"
	Aviso(STR0007, STR0009, {"Ok"}, 2)// "Atenção"### "Exclusao nao permitida. Devera ser inativado o uso desta restricao."
	Return .F.
EndIf

If nUtiliz == 2 .OR. nUtiliz == 3
	aAdd(aCpos_Nao, "AL6_CPOITE")
	aAdd(aCpos_Nao, "AL6_CPOMOV")
Else
	If (nCallOpcx == 4 .Or. nCallOpcx == 5) .And. nUtiliz == 1
		If Alltrim(AL6->AL6_ENTIDA) == "AL3"
		   Aviso(STR0007, STR0017,{"Ok"})//"Atencao"###"Para manutencao de acesso na entidade AL3 utilizar rotina Restricao Acesso a Configuracao de Cubos."
		   Return .F.
		EndIf   
	EndIf
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOA2102" )
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para inclusao de botoes de usuarios         ³
	//P_E³ na tela de configuracao dos lancamentos                                ³
	//P_E³ Parametros : Nenhum                                                    ³
	//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
	//P_E³  Ex. :  User Function PCOA2102                                         ³
	//P_E³         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ValType( aUsButtons := ExecBlock( "PCOA2102", .F., .F. ) ) == "A"
		aButtons := {}
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

If !lAuto
	oSize := FwDefSize():New(.T.,,,)
	oSize:AddObject( "CABECALHO",  100, 40, .T., .T. ) 
	oSize:AddObject( "GETDADOS" ,  100, 60, .T., .T. ) 
	oSize:lProp 	:= .T. 
	oSize:Process() 
	
	DEFINE MSDIALOG oDlg TITLE STR0010 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enchoice com os dados do Processo                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLinIni := oSize:GetDimension("CABECALHO","LININI") 
	nColIni := oSize:GetDimension("CABECALHO","COLINI") 
	nLinEnd := oSize:GetDimension("CABECALHO","LINEND")
	nColEnd := oSize:GetDimension("CABECALHO","COLEND") 
EndIf

aCposEnch := PcoCpoEnchoice("AL6", aCpos_Nao)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para adicionar campos no cabecalho                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOA2103" )
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para adicionar campos no cabecalho          ³
	//P_E³ Parametros : Nenhum                                                    ³
	//P_E³ Retorno    : Array contendo as os campos a serem adicionados           ³
	//P_E³               Ex. :  User Function PCOA2103                            ³
	//P_E³                      Return {"AL6_FIELD1","AL6_FIELD2"}                ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType( aUsField := ExecBlock( "PCOA2103", .F., .F. ) ) == "A"
		AEval( aUsField, { |x| AAdd( aCposEnch, x ) } )
	EndIf
EndIf
 
// Carrega dados do AL6 para memoria
RegToMemory("AL6",INCLUI)


If nCallOpcx == 3
	If nUtiliz == 2 //se inclusao e restricao configuracao cubo
		M->AL6_ENTIDA := PadR("AL3", Len(AL6->AL6_ENTIDA))
		M->AL6_CONPAD := PadR("AL31", Len(AL6->AL6_CONPAD))
		M->AL6_NOMENT := Posicione("SX2", 1, M->AL6_ENTIDA, "X2NOME()")
		M->AL6_TAMANH := Len(AL3->AL3_CONFIG+AL3->AL3_CODIGO)
		M->AL6_UTILIZ := "2"
	ElseIf nUtiliz == 3 //se inclusao e restricao configuracao cubo
		M->AL6_ENTIDA := PadR("AKN", Len(AL6->AL6_ENTIDA))
		M->AL6_CONPAD := PadR("AKN", Len(AL6->AL6_CONPAD))
		M->AL6_NOMENT := Posicione("SX2", 1, M->AL6_ENTIDA, "X2NOME()")
		M->AL6_TAMANH := Len(AKN->AKN_CODIGO)
		M->AL6_UTILIZ := "3"
	EndIf
EndIf

If !lAuto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enchoice com os dados dos Lancamentos                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If nCallOpcx == 2 .OR. nCallOpcx == 5
		oEnchAL6 := MSMGet():New('AL6',,4/*nCallOpcx*/,,,,aCposEnch,{nLinIni,nColIni,nLinEnd,nColEnd},,,,,,oDlg,,,,,,,,,)
	Else
		oEnchAL6 := MSMGet():New('AL6',,nCallOpcx,,,,aCposEnch,{nLinIni,nColIni,nLinEnd,nColEnd},,,,,,oDlg,,,,,,,,,)
	EndIf
	oEnchAL6:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	If nCallOpcx <> 3
		If ( nPos := aScan(oEnchAL6:aGets, {|x|"AL6_CONPAD" $x}) ) > 0
			oEnchAL6:AENTRYCTRLS[nPos]:nAt := Pco210SlF3()
			If nCallOpcx == 2 .OR. nCallOpcx == 5
				oEnchAL6:Disable()
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do AL7                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadAL7 := GetaHeader("AL7",,aCposEnch,@aEnchAuto,aCposVisual)
nLenAL7  := Len(aHeadAL7) + 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols do AL7                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aColsAL7 := {}

If !INCLUI
	DbSelectArea("AL7")
	DbSetOrder(1)
	DbSeek(xFilial()+AL6->AL6_ENTIDADE)
	
	cEntidade := AL6->AL6_FILIAL + AL6->AL6_ENTIDADE
	While nCallOpcx != 3 .And. !Eof() .And. AL7->AL7_FILIAL + AL7->AL7_ENTIDADE == cEntidade
		AAdd(aColsAL7,Array( nLenAL7 ))
		nLinAL7++
		// Varre o aHeader para preencher o acols
		AEval(aHeadAL7, {|x,y| aColsAL7[nLinAL7][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })
	
		// Deleted
		aColsAL7[nLinAL7][nLenAL7] := .F.
		
		// Adiciona o Recno no aRec
		AAdd( aRecAL7, AL7->( Recno() ) )
		
		AL7->(DbSkip())
		
	EndDo
EndIf

// Verifica se não foi criada nenhuma linha para o aCols
If Len(aColsAL7) = 0
	AAdd(aColsAL7,Array( nLenAL7 ))
	nLinAL7++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAL7, {|x,y| aColsAL7[nLinAL7][y] := IIf(Upper(AllTrim(x[2])) == "AL7_ID", StrZero(1,Len(AL7->AL7_ID)),CriaVar(AllTrim(x[2])) ) })
	
	// Deleted
	aColsAL7[nLinAL7][nLenAL7] := .F.
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

	oGdAL7:= MsNewGetDados():New(3,3,oSize:GetDimension("GETDADOS","YSIZE") - 16,oSize:GetDimension("GETDADOS","XSIZE") - 4,nGetd,"AL7LinOK",,"+AL7_ID",,,9999,,,,oDlg,aHeadAL7,aColsAL7)
	oGdAL7:oBrowse:Align := CONTROL_ALIGN_BOTTOM
	oGdAL7:CARGO := AClone(aRecAL7)
	oGdAL7:oBrowse:Refresh()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(obrigatorio(aGets,aTela) .And. A210Ok(nCallOpcx,nRecAL6,oGdAL7:Cargo,aEnchAuto,oGdAL7:aCols,oGdAL7:aHeader),oDlg:End(),Nil)},{|| lCancel := .T., oDlg:End() },,aButtons)

	
Else
	lCancel := !A210Ok(nCallOpcx,nRecAL6,aRecAL7,aEnchAuto,aColsAL7,aHeadAL7,lAuto)
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

RestArea(aAreaAL7)
RestArea(aAreaAL6)
Return !lCancel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A210Ok   ºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao do botao OK da enchoice bar, valida e faz o         º±±
±±º          ³ tratamento adequado das informacoes.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A210Ok(nCallOpcx,nRecAL6,aRecAL7,aEnchAuto,aColsAL7,aHeadAL7,lAuto)
Local nI
Local nX
Local aAreaAL7	:= AL7->(GetArea())
Local aAreaAL6	:= AL6->(GetArea())
Local aRecAux   := aClone(aRecAL7)
Local bCampo 	:= {|n| FieldName(n) }

If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If !A210Vld(nCallOpcx,aRecAL7,aEnchAuto,aColsAL7,aHeadAL7)
	Return .F.
EndIf

AL6->(DbSetOrder(1))
AL7->(DbSetOrder(1))

If nCallOpcx = 3 // Inclusao
	dbSelectArea("AL6")
	Reclock("AL6",.T.)
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
	AL6->AL6_FILIAL := xFilial("AL6")
	MsUnlock()	

	// Grava Lancamentos
	For nI := 1 To Len(aColsAL7)
		If aColsAL7[nI][Len(aColsAL7[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AL7",.T.)
		EndIf

		// Varre o aHeader e grava com base no acols
		AEval(aHeadAL7,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsAL7[nI][y])), ) })

		// Grava campos que nao estao disponiveis na tela
		Replace AL7_FILIAL With xFilial()
		Replace AL7_ENTIDA With AL6->AL6_ENTIDA
		Replace AL7_TAMANH With AL6->AL6_TAMANH
		MsUnlock()
		
	Next nI
	
ElseIf nCallOpcx = 4 // Alteracao

	dbSelectArea("AL6")
	dbGoto(nRecAL6)
	Reclock("AL6",.F.)

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
	dbSelectArea("AL7")
	//primeiro exclui os registros
	For nI := 1 TO Len(aRecAux)
		dbGoto(aRecAux[nI])
		Reclock("AL7",.F.)
		dbDelete()
		MsUnlock()
    Next
	//depois grava novos registros	
	For nI := 1 To Len(aColsAL7)
		If aColsAL7[nI][Len(aColsAL7[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AL7",.T.)
		EndIf

		// Varre o aHeader e grava com base no acols
		AEval(aHeadAL7,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsAL7[nI][y])), ) })

		// Grava campos que nao estao disponiveis na tela
		Replace AL7_FILIAL With xFilial()
		Replace AL7_ENTIDA With AL6->AL6_ENTIDA
		Replace AL7_TAMANH With AL6->AL6_TAMANH
		MsUnlock()
		
	Next nI

ElseIf nCallOpcx = 5 // Exclusao

	// Grava Lancamentos
	For nI := 1 To Len(aRecAL7)
		dbGoto(aRecAL7[nI])
		Reclock("AL7",.F.)
		dbDelete()
		MsUnlock()
	Next nI
	
	dbSelectArea("AL6")
	dbGoto(nRecAL6)
	Reclock("AL6",.F.)
	dbDelete()
	MsUnlock()

EndIf

AL7->(RestArea(aAreaAL7))
AL6->(RestArea(aAreaAL6))

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A210Vld  ºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de validacao dos campos.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A210Vld(nCallOpcx,aRecAL7,aEnchAuto,aColsAL7,aHeadAL7)
Local nI
Local nPosTipo
If !(nCallOpcx = 3 .Or. nCallOpcx = 4 .Or. nCallOpcx = 6)
	Return .T.
EndIf


If ( AScan(aEnchAuto,{|x| x[17] .And. Empty( &( "M->" + x[2] ) ) } ) > 0 )
	HELP("  ",1,"OBRIGAT")
	Return .F.
EndIf

For nI := 1 To Len(aColsAL7)
	// Busca por campos obrigatorios que nao estejam preenchidos
	nPosField := AScanx(aHeadAL7,{|x,y| x[17] .And. Empty(aColsAL7[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("AL7"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0015+ AllTrim(aHeadAL7[nPosField][1])+CHR(10)+CHR(13)+STR0016+Str(nI,3,0),3,1) //"Campo: "###"Linha: "
		Return .F.
	EndIf
Next nI

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AL7LinOK    ³ Autor ³ Paulo Carnelossi    ³ Data ³ 25/08/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da LinOK da Getdados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AL7LinOK()
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
±±³Fun‡„o    ³PCOA210Leg³ Autor ³ Paulo Carnelossi      ³ Data ³ 25/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta as legendas da mBrowse.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOA210Leg                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Acaa170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PCOA210Leg(cAlias)
Local aLegenda := 	{ 	{"BR_VERDE"   , STR0011 },; //"Restrição Ativa"
						{"BR_VERMELHO", STR0012 } }//"Restrição Inativa"
Local aRet := {}
aRet := {}
	
If cAlias == Nil
	Aadd(aRet, { 'AL6->AL6_ATIVO == "1"', aLegenda[1][1] } )
	Aadd(aRet, { 'AL6->AL6_ATIVO == "2"', aLegenda[2][1] } )
Else
	BrwLegenda(cCadastro,STR0008, aLegenda) //"Legenda"
Endif

Return aRet


Function PcoA210Pesq(o)
Local cContConPad
Local lContinua := .T.

If Alltrim(oGdAL7:aHeader[oGdAL7:oBrowse:ColPos][2]) == "AL7_FX_INI" .Or. ;
	Alltrim(oGdAL7:aHeader[oGdAL7:oBrowse:ColPos][2]) == "AL7_FX_FIN"
	dbSelectArea("SXB")
	dbSetOrder(1)

	If dbSeek(PadR(M->AL6_CONPAD, Len(SXB->XB_ALIAS))+;
				PadR("5", Len(SXB->XB_TIPO))+;
				PadR("01", Len(SXB->XB_SEQ))+;
				PadR(" ", Len(SXB->XB_COLUNA)))
		cContConPad := M->AL6_ENTIDA+"->("+SXB->XB_CONTEM+")"
				
		If ConPad1( , , , PadR(M->AL6_CONPAD, Len(SXB->XB_ALIAS)), , , .F. )
			oGdAL7:aCols[oGdAL7:nAt][oGdAL7:oBrowse:ColPos]:= &(cContConPad)
		EndIf	
	EndIf
EndIf

Return		


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoAcess_CfgCuboºAutor ³Paulo Carnelossi º Data ³ 11/11/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de manutencao do cadastro de restricao de acesso paraº±±
±±º          ³configuracao de cubo (nOpcx = 0 Inclusao/Alteracao          º±±
±±º          ³                      nOpcx = 5 Exclusao)                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAcess_CfgCubo(nOpcx)
Local lAcessoCube
Local nUtiliz := 2
DEFAULT nOpcx := 0

dbSelectArea("AL6")
dbSetOrder(1)

lAcessoCube := dbSeek(xFilial("AL6")+"AL3")

If nOpcx == 0
	If ! lAcessoCube
		PCOA210(3,,, nUtiliz)   //inclusao
	Else
		PCOA210(4,,, nUtiliz)   //alteracao
	EndIf
ElseIf nOpcx == 5
	If lAcessoCube
		PCOA210(5,,, nUtiliz)  //exclusao
	Else
		Aviso(STR0007, STR0020, {"Ok"})  //"Atencao"###"Restricao de acesso a configuracao de cubo nao encontrada."
	EndIf	
EndIf

Return


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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoVisao_Acesso ºAutor ³Paulo Carnelossi º Data ³ 18/11/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de manutencao do cadastro de restricao de acesso paraº±±
±±º          ³visao gerencial (nOpcx = 0 Inclusao/Alteracao               º±±
±±º          ³                      nOpcx = 5 Exclusao)                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoVisao_Acesso(nOpcx)
Local lAcessoVisao
Local nUtiliz := 3
DEFAULT nOpcx := 0

dbSelectArea("AL6")
dbSetOrder(1)

lAcessoVisao := dbSeek(xFilial("AL6")+"AKN")

If nOpcx == 0
	If ! lAcessoVisao
		PCOA210(3,,, nUtiliz)   //inclusao
	Else
		PCOA210(4,,, nUtiliz)   //alteracao
	EndIf
ElseIf nOpcx == 5
	If lAcessoVisao
		PCOA210(5,,, nUtiliz)  //exclusao
	Else
		Aviso(STR0007, STR0021, {"Ok"})  //"Atencao"###"Restricao de acesso a visao gerencial nao encontrada."
	EndIf	
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³29/11/06 ³±±
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
Local aUsRotina := {}
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	    "A210DLG"  , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"A210DLG"  , 0 , 3},;	  //"Incluir"
							{ STR0005, 		"A210DLG"  , 0 , 4},; //"Alterar"
							{ STR0006, 		"A210DLG"  , 0 , 5},; //"Excluir"
							{ STR0008, 		"PCOA210Leg"  , 0 , 2, ,.F.}} //"Legenda"

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario no aRotina                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA2101" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
		//P_E³ browse da tela de lançamentos                                          ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
		//P_E³               Ex. :  User Function PCOA2101                            ³
		//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA2101", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)



//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³ Funcao Pco210Combo() para realizar  consulta padrao     ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±

Function Pco210Combo()
Local cRetorno:= ""
Local nX:= 0
Local cDescri:= ""
Local cCodigo:= ""

If aCombo == NIL
	aCombo:= SeleF3()
EndIf

If cConteudo == NIL
	For nX:=1 to Len(aCombo)
	
		cCodigo:= Subs(aCombo[nX],1, At("-",aCombo[nX])-2 )
		cDescri:= Subs(aCombo[nX],At("-",aCombo[nX])+1 )
		If Empty(cCodigo)
			cCodigo := Space(6)
			cDescri := "Consulta Não Selecionada"
		EndIf
		
		cRetorno += PadR(cCodigo,6)+"="+Alltrim(cDescri) + If(nX == Len(aCombo),"", ";")
	
	Next
	
	cConteudo := cRetorno
Else
	cRetorno := cConteudo
EndIf

Return cRetorno 



Static Function Pco210SlF3()
Local cCodigo := Space(6)
Local nRet    := 1
Local nX
Local nPosArray := 0

If aCombo == NIL
	aCombo:= SeleF3()
EndIf

If ( nPosArray := aScan( aSelOpc, {|x| Alltrim(x[1]) == Alltrim(AL6->AL6_CONPAD) } ) ) == 0

	For nX:=1 to Len(aCombo)
	
		cCodigo:= Subs(aCombo[nX],1, At("-",aCombo[nX])-2 )
		If Empty(cCodigo) .And. Empty(Alltrim(AL6->AL6_CONPAD))
			nRet := 1
			Exit
		Else
			If Alltrim(cCodigo) == Alltrim(AL6->AL6_CONPAD)
				nRet := nX
				Exit
			EndIf
		EndIf
	Next
	aAdd(aSelOpc ,  { cCodigo, nRet} ) 
	
Else
	nRet := aSelOpc[nPosArray,2]
EndIf


Return(nRet)




