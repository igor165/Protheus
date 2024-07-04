#INCLUDE "PCOA160.ch"
#INCLUDE "PROTHEUS.CH"

/*
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA160  ³ AUTOR ³ Paulo Carnelossi      ³ DATA ³ 12/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa para cadastro configuracoes visao gerencial PCO     ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA160                                                      ³±±
±±³_DESCRI_  ³ Programa para cadastro de configuracoes de visoes gerenciais ³±±
±±³_DESCRI_  ³ utilizado no modulo SIGAPCO                                  ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal    ³±±
±±³          ³ partir do Menu ou a partir de uma funcao pulando assim o     ³±±
±±³          ³ browse principal e executando a chamada direta da rotina     ³±±
±±³          ³ selecionada.                                                 ³±±
±±³          ³ Exemplo: PCOA160(2) - Executa a chamada da funcao de visua-  ³±±
±±³          ³                        zacao da rotina.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Chamada direta sem passar pela mBrowse               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA160(nCallOpcx)
Private cCadastro	:= STR0008 //"Cadastro de Configuracoes de Visao Gerencial - PCO"
Private aRotina := MenuDef()	
Private cPlano := Space(2)
Private cCodigo := Space(Len(CV0->CV0_CODIGO))

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )	
	A160Popula()

	If nCallOpcx <> Nil
		A160DLG("AKL",AKL->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AKL")
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A160DLG   ºAutor  ³Paulo Carnelossi    º Data ³  12/11/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- º±±
±±º          ³ zacao                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A160DLG(cAlias,nRecnoAKL,nCallOpcx)
Local oDlg
Local lCancel  := .F.
Local aButtons := {}
Local aUsButtons := {}
Local oEnchAKL
Local oFolder

Local aHeadAKM
Local aColsAKM
Local nLenAKM   := 0 // Numero de campos em uso no AKM
Local nLinAKM   := 0 // Linha atual do acols
Local aRecAKM   := {} // Recnos dos registros
Local nGetD

Private oGdAKM
Private INCLUI  := (nCallOpcx = 3)

If !AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	Return .F.
EndIf

//Botão habilitado somente na inclusão
If nCallOpcx = 3
	aAdd( aButtons,  { "BMPCPO",{|| a160Suges(nCallOpcx, aHeadAKM, oGdAKM ) },STR0029,STR0030 } )  //"Preencher Campos Conforme Cubo"##"Cpo/Cubo"
EndIf

If nCallOpcx == 3 .OR. nCallOpcx == 4
	aAdd( aButtons,  { "BMPCPO",{|| a160ConsPad(nCallOpcx, aHeadAKM, oGdAKM ) },STR0031,STR0032 } )   //"Consulta Padrao Filtro"##"Cons.Padrao"
EndIf

If nCallOpcx != 3 .And. ValType(nRecnoAKL) == "N" .And. nRecnoAKL > 0
	DbSelectArea(cAlias)
	DbGoto(nRecnoAKL)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoAKL)))
		Return .F.
	EndIf
EndIf


If (nCallOpcx == 4 .Or. nCallOpcx == 5) .And. AKL->AKL_SYSTEM == "1" //Tab.Sistema
	MsgInfo(STR0007,STR0001) //"Nao deve ser alterado ou excluido."##"Registro de Configuração de Sistema"
	Return .F.
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOA1602" )
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para inclusao de botoes de usuarios         ³
	//P_E³ na tela de processos                                                   ³
	//P_E³ Parametros : Nenhum                                                    ³
	//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
	//P_E³  Ex. :  User Function PCOA1602                                         ³
	//P_E³         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ValType( aUsButtons := ExecBlock( "PCOA1602", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

DEFINE MSDIALOG oDlg TITLE STR0008 FROM 0,0 TO 480,640 PIXEL //"Cadastro de Configuracoes de Visao Gerencial - PCO"
oDlg:lMaximized := .T.

// Carrega dados do AKL para memoria
RegToMemory("AKL",INCLUI)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice com os dados do Processo                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnchAKL := MSMGet():New('AKL',,nCallOpcx,,,,,{0,0,(oDlg:nClientHeight/6)-12,(oDlg:nClientWidth/2)},,,,,,oDlg,,,,,,.T.,,,)
oEnchAKL:oBox:Align := CONTROL_ALIGN_TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder com os Pontos de Lancamento e Pontos de Bloqueio                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder  := TFolder():New(oDlg:nHeight/6,0,{STR0009},{''},oDlg,1,,,.T.,,(oDlg:nWidth/2),oDlg:nHeight/3,) //"Parametros da Configuracao"
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do AKM                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadAKM := GetaHeader("AKM")
nLenAKM  := Len(aHeadAKM) + 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols do AKM                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsAKM := {}
DbSelectArea("AKM")
DbSetOrder(1)
DbSeek(xFilial()+AKL->AKL_CONFIG)
If nCallOpcx != 3
	While !Eof() .And. AKM->AKM_FILIAL + AKM->AKM_CONFIG == xFilial() + AKL->AKL_CONFIG
		AAdd(aColsAKM,Array( nLenAKM ))
		nLinAKM++
		// Varre o aHeader para preencher o acols
		AEval(aHeadAKM, {|x,y| aColsAKM[nLinAKM][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })
	
		// Deleted
		aColsAKM[nLinAKM][nLenAKM] := .F.
		
		// Adiciona o Recno no aRec
		AAdd( aRecAKM, AKM->( Recno() ) )
		
		AKM->(DbSkip())
	EndDo
EndIf

// Verifica se não foi criada nenhuma linha para o aCols
If Len(aColsAKM) = 0
	AAdd(aColsAKM,Array( nLenAKM ))
	nLinAKM++

	// Varre o aHeader para preencher o acols
	AEval(aHeadAKM, {|x,y| aColsAKM[nLinAKM][y] := IIf(Upper(AllTrim(x[2])) == "AKM_ITEM", StrZero(1,Len(AKM->AKM_ITEM)),CriaVar(AllTrim(x[2])) ) })

	// Deleted
	aColsAKM[nLinAKM][nLenAKM] := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados com os Pontos de Lancamento          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCallOpcx = 3 .Or. nCallOpcx = 4
	nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nGetD := 0
EndIf

oGdAKM:= MsNewGetDados():New(0,0,100,100,nGetd,,,"+AKM_ITEM",,,9999,,,,oFolder:aDialogs[1],aHeadAKM,aColsAKM)
oGdAKM:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGdAKM:CARGO := AClone(aRecAKM)

// Quando nao for MDI chama centralizada.
If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(A160Ok(nCallOpcx,oEnchAKL,oGdAKM),(A160Grv(nCallOpcx,oEnchAKL,oGdAKM),oDlg:End()),) },{|| lCancel := .T., oDlg:End() },,aButtons)
Else
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(A160Ok(nCallOpcx,oEnchAKL,oGdAKM),(A160Grv(nCallOpcx,oEnchAKL,oGdAKM),oDlg:End()),) },{|| lCancel := .T., oDlg:End() },,aButtons)
EndIf

Return !lCancel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A160Ok   ºAutor  ³Paulo Carnelossi    º Data ³  12/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao do botao OK da enchoice bar, valida e faz o         º±±
±±º          ³ tratamento adequado das informacoes.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A160Ok(nCallOpcx,oEnchAKL,oGdAKM)
Local lRet := .F.

If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	lRet := .T.
EndIf

If !A160Vld(nCallOpcx,oEnchAKL,oGdAKM)
	lRet := .F. 
Else
	lRet := .T. 
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A160Grv  ºAutor  ³Paulo Carnelossi    º Data ³  12/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de gravacao das configuracoes de visao gerencial ao º±±
±±º          ³ pressionar o botao OK da enchoice bar.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A160Grv(nCallOpcx,oEnchAKL,oGdAKM)
Local nI
Local cCampo

If nCallOpcx = 3 // Inclusao

	// Grava cabecalho
	Reclock("AKL",.T.)
	For nI := 1 To FCount()
		cCampo := Upper(AllTrim(FieldName(nI)))
		If cCampo == "AKL_FILIAL"
			FieldPut(nI,xFilial())
		Else
			FieldPut(nI, &("M->" + cCampo))
		EndIf
	Next nI
	MsUnlock()
	
	// Grava Itens dos parametros de visao gerencial
	For nI := 1 To Len(oGdAKM:aCols)
		If oGdAKM:aCols[nI][Len(oGdAKM:aCols[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AKM",.T.)
		EndIf

		// Varre o aHeader e grava com base no acols
		AEval(oGdAKM:aHeader,{|x,y| FieldPut(FieldPos(x[2]), oGdAKM:aCols[nI][y] ) })

		Replace AKM_FILIAL With xFilial()
		Replace AKM_CONFIG With AKL->AKL_CONFIG

		MsUnlock()

	Next nI
	
ElseIf nCallOpcx = 4 // Alteracao

	// Grava Cabecalho - alteracao
	Reclock("AKL",.F.)
	For nI := 1 To FCount()
		cCampo := Upper(AllTrim(FieldName(nI)))
		If cCampo == "AKL_FILIAL"
			FieldPut(nI,xFilial())
		Else
			FieldPut(nI, &("M->" + cCampo))
		EndIf
	Next nI
	MsUnlock()

	// Grava Itens dos parametros de visao gerencial
	For nI := 1 To Len(oGdAKM:aCols)
		If nI <= Len(oGdAKM:Cargo) .And. oGdAKM:Cargo[nI] > 0
			AKM->(DbGoto(oGdAKM:Cargo[nI]))
			Reclock("AKM",.F.)
		Else
			If oGdAKM:aCols[nI][Len(oGdAKM:aCols[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AKM",.T.)
			EndIf
		EndIf
	
		If oGdAKM:aCols[nI][Len(oGdAKM:aCols[nI])] // Verifica se a linha esta deletada
			AKM->(DbDelete())
		Else
			// Varre o aHeader e grava com base no acols
			AEval(oGdAKM:aHeader,{|x,y| FieldPut( FieldPos(x[2]) , oGdAKM:aCols[nI][y] ) })
			Replace AKM_FILIAL With xFilial()
			Replace AKM_CONFIG With AKL->AKL_CONFIG

		EndIf

		MsUnlock()
	Next nI

ElseIf nCallOpcx = 5 // Exclusao

	// Exclui Itens dos parametros de visao gerencial
	For nI := 1 To Len(oGdAKM:aCols)
		If nI <= Len(oGdAKM:Cargo) .And. oGdAKM:Cargo[nI] > 0
			AKM->(DbGoto(oGdAKM:Cargo[nI]))
			Reclock("AKM",.F.)
			AKM->(DbDelete())
			MsUnLock()
		EndIf		
	Next nI

	// Exclui Cabecalho
	Reclock("AKL",.F.)
	AKL->(DbDelete())
	MsUnLock()

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A160Vld  ºAutor  ³Paulo Carnelossi    º Data ³  12/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de validacao dos campos.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A160Vld(nCallOpcx,oEnchAKL,oGdAKM)
Local nI
If (nCallOpcx = 3 .Or. nCallOpcx = 4) .And. ;
	!Obrigatorio(oEnchAKL:aGets,oEnchAKL:aTela)
	Return .F.
EndIf

For nI := 1 To Len(oGdAKM:aCols)
	// Busca por campos obrigatorios que nao estjam preenchidos
	nPosField := AScanx(oGdAKM:aHeader,{|x,y| x[17] .And. Empty(oGdAKM:aCols[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("AKD"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0010 + AllTrim(oGdAKM:aHeader[nPosField][1]) + STR0011+Str(nI,3,0),3,1) //"Campo: "###"Linha: " //"Campo: "###"Linha: "
		Return .F.
	EndIf
Next nI

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PcoVazio
Verifica se campo esta vazio
@author TOTVS
@since 01/01/80
@version P12
/*/
//-------------------------------------------------------------------
Function PcoVazio(cCampo, oGetDados, nLin)
Local nCampo
Local lRet := .F. 

DEFAULT oGetDados := oGdAKM
DEFAULT nLin := oGdAKM:nAt

nCampo := aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == cCampo})

If nCampo > 0
	lRet := Empty(oGdAKM:Acols[nLin, nCampo])
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PcoX3Filtro
Retorna alias da tabela
@author TOTVS
@since 01/01/80
@version P12
/*/
//-------------------------------------------------------------------
Function PcoX3Filtro(oGetDados, nLin)
Local cCampo, cCpoAux := "", nCampo
Local cAliasRet := ""

DEFAULT oGetDados := oGdAKM
DEFAULT nLin := oGdAKM:nAt

cCampo := ReadVar()
cCampo := StrTran(cCampo, "M->","")

If cCampo == "AKM_CPOREF"
   cCpoAux := "AKM_ENTSIS"
ElseIf cCampo == "AKM_CPOFIL"
   cCpoAux := "AKM_ENTFIL"
EndIf

If !Empty(cCpoAux)   

	nCampo := aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == cCpoAux})

	If nCampo > 0
		cAliasRet := oGdAKM:Acols[nLin, nCampo]
	EndIf

EndIf

Return(Padr(cAliasRet,3))

//-------------------------------------------------------------------
/*/{Protheus.doc} A160ValCpo
Valida se campo existe no dicionario
@author TOTVS
@since 01/01/80
@version P12
/*/
//-------------------------------------------------------------------
Function A160ValCpo()
Local lRet := .F.
Local cContCpo

cContCpo := &(ReadVar())

SX3->(dbSetOrder(2))
lRet := SX3->(dbSeek(cContCpo))
SX3->(dbSetOrder(1))

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} A160Popula
Popula as tabelas AKL/AKM para codigos reservados 001 ; 002 ; 004 ; 005
@author TOTVS
@since 01/01/80
@version P12
/*/
//-------------------------------------------------------------------
Function A160Popula()
Local nX, nY, nQt, cItem
Local aAuxAKM := {}, aTabAKM := {} 
Local c_Desc := ""
Local c_Alias := ""
Local c_CpoMov := ""
Local n_PosIni := 0 
Local n_QtdDig := 0
Local c_CpFilt := ""
Local c_ConPad := ""
Local lContinua := .T.
Local aTabAux := {}

Static nQtdEntid  
             
// Verifica a quantidade de entidades contabeis
If nQtdEntid == NIL
	If cPaisLoc == "RUS" 
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
	Else
	nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf 
EndIf

dbSelectArea("AKM")
dbSetOrder(1)

dbSelectArea("AKL")
dbSetOrder(1)


If !dbSeek(xFilial("AKL")+"001") .And. ;
	AKM->(! dbSeek(xFilial("AKM")+"001"))
	RecLock("AKL", .T.)
	AKL_FILIAL := xFilial("AKL")
	AKL_CONFIG := "001"
	AKL_DESCRI := STR0012 //"VISAO ORCAMENTARIA"
	AKL_SYSTEM := "1"
	AKL_UTILIZ := "1"
	MsUnLock()
	
	aAuxAKM := {}
	aAdd(aAuxAKM, {'AKM_CONFIG' , '001'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '01'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0013}) //'Planilha Orct.      '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AK1  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AK1_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AK1  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AK1_CODIGO'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AK1  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '1'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"                            "'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {}
	aAdd(aAuxAKM, {'AKM_CONFIG' , '001'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '02'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0019 }) //'Versao'
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AKE  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AKE_REVISA'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AK2  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AK2_VERSAO'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AKE1'})
	aAdd(aAuxAKM, {'AKM_TIPO' , '1'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"                            "'})
	aAdd(aTabAKM, aAuxAKM)

	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '001'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '03'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0014}) //'Conta Orcamentaria  '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AK5  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AK5_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AK2  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AK2_CO    '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AK5  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '001'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '04'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0015}) //'Classe Orcamentaria '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AK6  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AK6_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AK2  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AK2_CLASSE'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AK6  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '001'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '05'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0020 })//'Operacao'
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AKF  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AKF_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AK2  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AK2_OPER'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AKF  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)

	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '001'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '06'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0016}) //'Centro Custo        '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'CTT  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'CTT_CUSTO '})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AK2  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AK2_CC    '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'CTT  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '001'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '07'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0017}) //'Item Contabil(CTB)  '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'CTD  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'CTD_ITEM  '})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AK2  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AK2_ITCTB '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'CTD  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '001'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '08'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0018}) //'Classe Valor(CTB)   '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'CTH  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'CTH_CLVL  '})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AK2  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AK2_CLVLR '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'CTH  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	//INSERIR UNIDADE ORCAMENTARIA E TODAS AS NOVAS ENTIDADES CRIADAS PELO WIZARD  
	// Verifica a existencia da Unidade Orcamentaria na base do cliente
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '001'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '09'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0026}) //"Unidade Orcamentaria"
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AMF  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AMF_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AK2  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AK2_UNIORC'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AMF  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM) 
		
	If (nQtdEntid > 4)   
		cItem := '09'
		// Inclui novas entidades
		For nQt := 5 To nQtdEntid 
			dbSelectArea("CT0")
			dbSetOrder(1)
			
			dbSeek(xFilial("CT0")+STRZERO(nQt,2)) 
		
			cItem := Soma1(cItem)
			aAuxAKM := {} 
			aAdd(aAuxAKM, {'AKM_CONFIG' , '001'})
			aAdd(aAuxAKM, {'AKM_ITEM' , cItem})
			aAdd(aAuxAKM, {'AKM_TITULO' , CT0->CT0_DESC}) 
			aAdd(aAuxAKM, {'AKM_ENTSIS' , CT0->CT0_ALIAS})
			aAdd(aAuxAKM, {'AKM_CPOREF' , CT0->CT0_CPOCHV})
			aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AK2  '})
			aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AK2_ENT'+STRZERO(nQt,2)})
			aAdd(aAuxAKM, {'AKM_CONPAD' , CT0->CT0_F3ENTI})
			aAdd(aAuxAKM, {'AKM_TIPO' , '2'}) 
			aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
			aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
			
			aAdd(aTabAKM, aAuxAKM) 
		Next
	EndIf   
	
	dbSelectArea("AKM")
	
	For nX := 1 TO Len(aTabAKM)
		RecLock("AKM", .T.)
		AKM->AKM_FILIAL := xFilial("AKM")
		For nY := 1 TO Len(aTabAKM[nX])
			If (nPos := FieldPos(aTabAKM[nX][nY][1])) > 0
				FieldPut(nPos, aTabAKM[nX][nY][2])
			EndIf
		Next
		MsUnLock()	
	Next

EndIf

aAuxAKM := {}
aTabAKM := {} 

If !dbSeek(xFilial("AKL")+"002") .And. ;
	AKM->(! dbSeek(xFilial("AKM")+"002"))
	RecLock("AKL", .T.)
	AKL_FILIAL := xFilial("AKL")
	AKL_CONFIG := "002"
	AKL_DESCRI := STR0021//"CONF.RESERVADA P/ INCL.MOVTO-SIMULACAO"
	AKL_SYSTEM := "1"
	AKL_UTILIZ := "2"

	MsUnLock()
	
	aAuxAKM := {}
	aAdd(aAuxAKM, {'AKM_CONFIG' , '002'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '01'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0013}) //'Planilha Orct.      '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AK1  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AK1_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CODPLA'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AK1  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '1'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"                            "'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {}
	aAdd(aAuxAKM, {'AKM_CONFIG' , '002'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '02'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0019 }) //'Versao'
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AKE  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AKE_REVISA'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_VERSAO'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AKE1'})
	aAdd(aAuxAKM, {'AKM_TIPO' , '1'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"                            "'})
	aAdd(aTabAKM, aAuxAKM)

	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '002'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '03'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0014}) //'Conta Orcamentaria  '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AK5  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AK5_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CO    '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AK5  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '002'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '04'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0015}) //'Classe Orcamentaria '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AK6  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AK6_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CLASSE'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AK6  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '002'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '05'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0020 })//'Operacao'
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AKF  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AKF_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_OPER'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AKF  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)

	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '002'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '06'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0016}) //'Centro Custo        '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'CTT  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'CTT_CUSTO '})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CC    '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'CTT  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '002'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '07'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0017}) //'Item Contabil(CTB)  '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'CTD  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'CTD_ITEM  '})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_ITCTB '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'CTD  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '002'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '08'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0018}) //'Classe Valor(CTB)   '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'CTH  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'CTH_CLVL  '})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CLVLR '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'CTH  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '002'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '09'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0022 }) //'Periodo '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AKD'})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AKD_DATA'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD'})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_DATA'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , ''})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '""'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"31/12/10"'})
	aAdd(aTabAKM, aAuxAKM)   
	

	//INCLUIR UNIDADE ORCAMENTARIA E AS NOVAS ENTIDADES CRIADAS PELO WIZARD  
	// Verifica a existencia da Unidade Orcamentaria na base do cliente
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '002'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '10'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0026}) //"Unidade Orcamentaria"
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AMF  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AMF_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_UNIORC'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AMF  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM) 
		
	If (nQtdEntid > 4)   
		cItem := '10'
		// Inclui novas entidades
		For nQt := 5 To nQtdEntid
			    
			aAuxAKM := {}
			dbSelectArea("CT0")
			dbSetOrder(1)                                 
				
			dbSeek(xFilial("CT0")+STRZERO(nQt,2)) 
			
			cItem := Soma1(cItem)
			aAdd(aAuxAKM, {'AKM_CONFIG' , '002'})
			aAdd(aAuxAKM, {'AKM_ITEM' , cItem})
			aAdd(aAuxAKM, {'AKM_TITULO' , CT0->CT0_DESC}) 
			aAdd(aAuxAKM, {'AKM_ENTSIS' , CT0->CT0_ALIAS})
			aAdd(aAuxAKM, {'AKM_CPOREF' , CT0->CT0_CPOCHV})
			aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
			aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_ENT'+STRZERO(nQt,2)})
			aAdd(aAuxAKM, {'AKM_CONPAD' , CT0->CT0_F3ENTI})
			aAdd(aAuxAKM, {'AKM_TIPO' , '2'})  
				
			aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
			aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
				
			aAdd(aTabAKM, aAuxAKM) 
		Next                                       
	EndIf 
	
	dbSelectArea("AKM")
	
	For nX := 1 TO Len(aTabAKM)
		RecLock("AKM", .T.)
		AKM->AKM_FILIAL := xFilial("AKM")
		For nY := 1 TO Len(aTabAKM[nX])
			If (nPos := FieldPos(aTabAKM[nX][nY][1])) > 0
				FieldPut(nPos, aTabAKM[nX][nY][2])
			EndIf
		Next
		MsUnLock()	
	Next

EndIf

aAuxAKM := {}
aTabAKM := {} 

If cPaisLoc == 'BRA' .And. 	AKL->( ! dbSeek(xFilial("AKL")+"004")) .And. ;
							AKM->( ! dbSeek(xFilial("AKM")+"004"))
	RecLock("AKL", .T.)
	AKL_FILIAL := xFilial("AKL")
	AKL_CONFIG := "004"
	AKL_DESCRI := STR0033 //"PARAMETROS RECEITAS-MCASP" 
	AKL_SYSTEM := "1"  //mudar para 1 qdo terminar desenvolvimento
	AKL_UTILIZ := "4"

	MsUnLock()
	
	aAuxAKM := {}
	aAdd(aAuxAKM, {'AKM_CONFIG' , '004'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '01'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0013}) //'Planilha Orct.      '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AK1  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AK1_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CODPLA'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AK1  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '1'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"                            "'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {}
	aAdd(aAuxAKM, {'AKM_CONFIG' , '004'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '02'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0019 }) //'Versao'
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AKE  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AKE_REVISA'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_VERSAO'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AKE1'})
	aAdd(aAuxAKM, {'AKM_TIPO' , '1'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"                            "'})
	aAdd(aTabAKM, aAuxAKM)

	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '004'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '03'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0014}) //'Conta Orcamentaria  '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AK5  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AK5_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CO    '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AK5  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '004'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '04'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0015}) //'Classe Orcamentaria '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AK6  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AK6_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CLASSE'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AK6  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '004'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '05'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0020 })//'Operacao'
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AKF  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AKF_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_OPER'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AKF  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)

	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '004'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '06'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0016}) //'Centro Custo        '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'CTT  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'CTT_CUSTO '})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CC    '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'CTT  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '004'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '07'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0017}) //'Item Contabil(CTB)  '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'CTD  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'CTD_ITEM  '})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_ITCTB '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'CTD  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '004'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '08'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0018}) //'Classe Valor(CTB)   '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'CTH  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'CTH_CLVL  '})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CLVLR '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'CTH  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	//INCLUIR UNIDADE ORCAMENTARIA E AS NOVAS ENTIDADES CRIADAS PELO WIZARD  
	// Verifica a existencia da Unidade Orcamentaria na base do cliente
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '004'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '09'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0026}) //"Unidade Orcamentaria"
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AMF  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AMF_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_UNIORC'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AMF  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM) 

	//tipo de saldo
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '004'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '10'})
	aAdd(aAuxAKM, {'AKM_TITULO' , "Tipo de Saldo"}) //"Tipo de Saldo"
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AL2  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AL2_TPSALD'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_TPSALD'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AL2A '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '1'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"                            "'})
	aAdd(aTabAKM, aAuxAKM) 

	cItem := '10'

	If (nQtdEntid > 4)   
		// Inclui novas entidades
		For nQt := 5 To nQtdEntid
			    
			aAuxAKM := {}
			dbSelectArea("CT0")
			dbSetOrder(1)                                 
				
			dbSeek(xFilial("CT0")+STRZERO(nQt,2)) 
			
			cItem := Soma1(cItem)
			aAdd(aAuxAKM, {'AKM_CONFIG' , '004'})
			aAdd(aAuxAKM, {'AKM_ITEM' , cItem})
			aAdd(aAuxAKM, {'AKM_TITULO' , CT0->CT0_DESC}) 
			aAdd(aAuxAKM, {'AKM_ENTSIS' , CT0->CT0_ALIAS})
			aAdd(aAuxAKM, {'AKM_CPOREF' , CT0->CT0_CPOCHV})
			aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
			aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_ENT'+STRZERO(nQt,2)})
			aAdd(aAuxAKM, {'AKM_CONPAD' , CT0->CT0_F3ENTI})
			aAdd(aAuxAKM, {'AKM_TIPO' , '2'})  
				
			aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
			aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
				
			aAdd(aTabAKM, aAuxAKM) 
			
		Next                                       
	EndIf 

	// aqui colocar os segmentos da receita para mcasp
	// Classificadores da Receita Orçamentária, criar uma tela específica para cada classificador:
	//
	// 1 – Categoria Econômica: (1 dígito) – Portaria 387/2019
	// 2 – Origem: (1 dígito) – Portaria 387/2019
	// 3 – Espécie: (1 dígito) – Portaria 387/2019
	// 4 – Desdobramento para identificação de peculiaridades da receita: (4 dígitos) – Portaria 387/2019
	// 5 – Tipo: (1 dígito) – Portaria 387/2019
	If AliasInDic("A1G") .And. AliasInDic("A1H")
		A1H->( dbSetOrder(1) )
		A1G->( dbSetOrder(1) )

		For nQt := 1 To 5
				lContinua := .T.

				c_Desc := ""
				c_Alias := "A1H"
				c_CpoMov := "AKD_CO"
				c_CpFilt := "AKD_CO"
				c_ConPad := "A1HXB"

                c_Tabela := ""
				c_Radica := ""
				n_PosIni := 1
				n_QtdDig := 1


				If     nQt == 1
					
					aAuxAKM := {}

					If A1G->( dbSeek( xFilial("A1G")+"CE" ))
						c_Desc := STR0034//"Categoria Economica"
						c_CpoMov := A1G->A1G_CAMPO
						c_CpFilt := A1G->A1G_CAMPO
						c_Tabela := A1G->A1G_CODTAB
						n_PosIni := If(Empty(A1G->A1G_INICPO), 1, A1G->A1G_INICPO)
						n_QtdDig := If(Empty(A1G->A1G_DIGCPO), 99, A1G->A1G_DIGCPO) 

						c_Radica := ""
						If A1H->( dbSeek( xFilial("A1H")+A1G->A1G_CODTAB ))
							c_Radica := A1H->A1H_RADCHV
						EndIf
					Else
						lContinua := .F.
					EndIf

					If lContinua
						A160Fill( "004", aAuxAKM, aTabAKM, @cItem, c_Desc, c_Alias, c_CpoMov, c_CpFilt, c_ConPad, c_Tabela, c_Radica, n_PosIni, n_QtdDig )
					EndIf

				ElseIf nQt == 2

					aTabAux := { "O1", "O2" }	
					For nX := 1 TO Len(aTabAux)

						aAuxAKM := {}
					
						If A1G->( dbSeek( xFilial("A1G")+aTabAux[nX] )) 
							c_Desc := STR0035 //"Origem"
							c_CpoMov := A1G->A1G_CAMPO
							c_CpFilt := A1G->A1G_CAMPO
							c_Tabela := A1G->A1G_CODTAB
							n_PosIni := If(Empty(A1G->A1G_INICPO), 1, A1G->A1G_INICPO)
							n_QtdDig := If(Empty(A1G->A1G_DIGCPO), 99, A1G->A1G_DIGCPO) 

							c_Radica := ""
							If A1H->( dbSeek( xFilial("A1H")+A1G->A1G_CODTAB))
								c_Radica := A1H->A1H_RADCHV
							EndIf							
						Else
							lContinua := .F.
						EndIf

						If lContinua
							A160Fill( "004", aAuxAKM, aTabAKM, @cItem, c_Desc, c_Alias, c_CpoMov, c_CpFilt, c_ConPad, c_Tabela, c_Radica, n_PosIni, n_QtdDig )
						EndIf
						
					Next


				ElseIf nQt == 3

					aTabAux := { "E1", "E2", "E3", "E4", "E5", "E6", "E7", "E9", "F1", "F2", "F3", "F4", "F9" }	
					For nX := 1 TO Len(aTabAux)

						aAuxAKM := {}

						If A1G->( dbSeek( xFilial("A1G")+aTabAux[nX] ))
							c_Desc := STR0036 //"Especie"
							c_CpoMov := A1G->A1G_CAMPO
							c_CpFilt := A1G->A1G_CAMPO
							c_Tabela := A1G->A1G_CODTAB
							n_PosIni := If(Empty(A1G->A1G_INICPO), 1, A1G->A1G_INICPO)
							n_QtdDig := If(Empty(A1G->A1G_DIGCPO), 99, A1G->A1G_DIGCPO) 

							c_Radica := ""
							If A1H->( dbSeek( xFilial("A1H")+A1G->A1G_CODTAB))
								c_Radica := A1H->A1H_RADCHV
							EndIf
						Else
							lContinua := .F.
						EndIf


						If lContinua
							A160Fill( "004", aAuxAKM, aTabAKM, @cItem, c_Desc, c_Alias, c_CpoMov, c_CpFilt, c_ConPad, c_Tabela, c_Radica, n_PosIni, n_QtdDig )
						EndIf
						
					Next

				ElseIf nQt == 4
					Loop
				ElseIf nQt == 5

					aAuxAKM := {}

					If A1G->( dbSeek( xFilial("A1G")+"TP" ))
						c_Desc := STR0037 //"Tipo"
						c_CpoMov := A1G->A1G_CAMPO
						c_CpFilt := A1G->A1G_CAMPO
						c_Tabela := A1G->A1G_CODTAB
						n_PosIni := If(Empty(A1G->A1G_INICPO), 1, A1G->A1G_INICPO)
						n_QtdDig := If(Empty(A1G->A1G_DIGCPO), 99, A1G->A1G_DIGCPO) 

						c_Radica := ""
						If A1H->( dbSeek( xFilial("A1H")+A1G->A1G_CODTAB))
							c_Radica := A1H->A1H_RADCHV
						EndIf
					Else
						lContinua := .F.
					EndIf
	
					If lContinua
						A160Fill( "004", aAuxAKM, aTabAKM, @cItem, c_Desc, c_Alias, c_CpoMov, c_CpFilt, c_ConPad, c_Tabela, c_Radica, n_PosIni, n_QtdDig )
					EndIf
 
				EndIf
		
		Next
	EndIf	

	dbSelectArea("AKM")
	
	For nX := 1 TO Len(aTabAKM)
		RecLock("AKM", .T.)
		AKM->AKM_FILIAL := xFilial("AKM")
		For nY := 1 TO Len(aTabAKM[nX])
			If (nPos := FieldPos(aTabAKM[nX][nY][1])) > 0
				FieldPut(nPos, aTabAKM[nX][nY][2])
			EndIf
		Next
		MsUnLock()	
	Next

EndIf

aAuxAKM := {}
aTabAKM := {} 

If cPaisLoc == 'BRA' .And. 	AKL->( ! dbSeek(xFilial("AKL")+"005")) .And. ;
							AKM->( ! dbSeek(xFilial("AKM")+"005"))
	RecLock("AKL", .T.)
	AKL_FILIAL := xFilial("AKL")
	AKL_CONFIG := "005"
	AKL_DESCRI := STR0038 //"PARAMETROS DESPESAS-MCASP"
	AKL_SYSTEM := "1"  //mudar para 1 qdo terminar desenvolvimento
	AKL_UTILIZ := "4"

	MsUnLock()
	
	aAuxAKM := {}
	aAdd(aAuxAKM, {'AKM_CONFIG' , '005'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '01'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0013}) //'Planilha Orct.      '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AK1  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AK1_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CODPLA'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AK1  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '1'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"                            "'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {}
	aAdd(aAuxAKM, {'AKM_CONFIG' , '005'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '02'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0019 }) //'Versao'
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AKE  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AKE_REVISA'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_VERSAO'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AKE1'})
	aAdd(aAuxAKM, {'AKM_TIPO' , '1'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"                            "'})
	aAdd(aTabAKM, aAuxAKM)

	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '005'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '03'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0014}) //'Conta Orcamentaria  '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AK5  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AK5_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CO    '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AK5  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '005'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '04'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0015}) //'Classe Orcamentaria '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AK6  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AK6_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CLASSE'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AK6  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '005'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '05'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0020 })//'Operacao'
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AKF  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AKF_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_OPER'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AKF  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)

	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '005'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '06'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0016}) //'Centro Custo        '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'CTT  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'CTT_CUSTO '})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CC    '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'CTT  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '005'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '07'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0017}) //'Item Contabil(CTB)  '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'CTD  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'CTD_ITEM  '})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_ITCTB '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'CTD  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '005'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '08'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0018}) //'Classe Valor(CTB)   '
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'CTH  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'CTH_CLVL  '})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_CLVLR '})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'CTH  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM)
	
	//INCLUIR UNIDADE ORCAMENTARIA E AS NOVAS ENTIDADES CRIADAS PELO WIZARD  
	// Verifica a existencia da Unidade Orcamentaria na base do cliente
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '005'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '09'})
	aAdd(aAuxAKM, {'AKM_TITULO' , STR0026}) //"Unidade Orcamentaria"
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AMF  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AMF_CODIGO'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_UNIORC'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AMF  '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '2'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
	aAdd(aTabAKM, aAuxAKM) 

	//tipo de saldo
	aAuxAKM := {} 
	aAdd(aAuxAKM, {'AKM_CONFIG' , '005'})
	aAdd(aAuxAKM, {'AKM_ITEM' , '10'})
	aAdd(aAuxAKM, {'AKM_TITULO' , "Tipo de Saldo"}) //"Tipo de Saldo"
	aAdd(aAuxAKM, {'AKM_ENTSIS' , 'AL2  '})
	aAdd(aAuxAKM, {'AKM_CPOREF' , 'AL2_TPSALD'})
	aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
	aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_TPSALD'})
	aAdd(aAuxAKM, {'AKM_CONPAD' , 'AL2A '})
	aAdd(aAuxAKM, {'AKM_TIPO' , '1'})
	aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
	aAdd(aAuxAKM, {'AKM_VALFIM' , '"                            "'})
	aAdd(aTabAKM, aAuxAKM) 

	cItem := '10'

	If (nQtdEntid > 4)   
		// Inclui novas entidades
		For nQt := 5 To nQtdEntid
			    
			aAuxAKM := {}
			dbSelectArea("CT0")
			dbSetOrder(1)                                 
				
			dbSeek(xFilial("CT0")+STRZERO(nQt,2)) 
			
			cItem := Soma1(cItem)
			aAdd(aAuxAKM, {'AKM_CONFIG' , '005'})
			aAdd(aAuxAKM, {'AKM_ITEM' , cItem})
			aAdd(aAuxAKM, {'AKM_TITULO' , CT0->CT0_DESC}) 
			aAdd(aAuxAKM, {'AKM_ENTSIS' , CT0->CT0_ALIAS})
			aAdd(aAuxAKM, {'AKM_CPOREF' , CT0->CT0_CPOCHV})
			aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD  '})
			aAdd(aAuxAKM, {'AKM_CPOFIL' , 'AKD_ENT'+STRZERO(nQt,2)})
			aAdd(aAuxAKM, {'AKM_CONPAD' , CT0->CT0_F3ENTI})
			aAdd(aAuxAKM, {'AKM_TIPO' , '2'})  
				
			aAdd(aAuxAKM, {'AKM_VALINI' , '"                            "'})
			aAdd(aAuxAKM, {'AKM_VALFIM' , '"zzzzzzzzzzzzzzzzzzzzzzzzzzzz"'})
				
			aAdd(aTabAKM, aAuxAKM) 
			
		Next                                       
	EndIf 

	// aqui colocar os segmentos da despesas para mcasp
	// Classificadores da Despesa Orçamentária, criar uma tela específica para cada classificador:
	//
	// 1 – Órgão: Unidade Orçamentária + Unidade Executora (6 dígitos) – Campos distintos - Específico
	// 2 – Função: (2 dígitos) – Portaria 42/1999
	// 3 – Sub Função: (3 dígitos) – Portaria 42/1999
	// 4 – Programas: (4 dígitos) - Específico
	// 5 – Ação (4 dígitos) - Específico
	// 6 – Categoria Econômica ( 1 dígito) – Lei 4.320/64
	// 7 – Grupo da Despesa ( 1 dígito) – Lei 4.320/64
	// 8 – Modalidade de Aplicação (2 dígitos) – Lei 4.320/64
	// 9 – Elemento da despesa (2 dígitos) – Lei 4.320/64
	// 10 – Sub Elemento da Despesa - Específico
	// 11 – Fonte de Recurso - Específico
	// 12 – Código de Aplicação - Específico

	If AliasInDic("A1G") .And. AliasInDic("A1H")
		A1H->( dbSetOrder(1) )
		A1G->( dbSetOrder(1) )

		For nQt := 1 To 10
				lContinua := .T.

				c_Desc := ""
				c_Alias := "A1H"
				c_CpoMov := "AKD_CO"
				c_CpFilt := "AKD_CO"
				c_ConPad := "A1HXB"

                c_Tabela := ""
				c_Radica := ""
				n_PosIni := 1
				n_QtdDig := 1


				If     nQt == 1
						Loop
				
				ElseIf nQt == 2
		
					aAuxAKM := {}

					If A1G->( dbSeek( xFilial("A1G")+"FC" ))
						c_Desc := STR0039 //"Função"
						c_CpoMov := A1G->A1G_CAMPO
						c_CpFilt := A1G->A1G_CAMPO
						c_Tabela := A1G->A1G_CODTAB
						n_PosIni := If(Empty(A1G->A1G_INICPO), 1, A1G->A1G_INICPO)
						n_QtdDig := If(Empty(A1G->A1G_DIGCPO), 99, A1G->A1G_DIGCPO) 

						c_Radica := ""
						If A1H->( dbSeek( xFilial("A1H")+A1G->A1G_CODTAB ))
							c_Radica := A1H->A1H_RADCHV
						EndIf
					Else
						lContinua := .F.
					EndIf

					If lContinua
						A160Fill( "005", aAuxAKM, aTabAKM, @cItem, c_Desc, c_Alias, c_CpoMov, c_CpFilt, c_ConPad, c_Tabela, c_Radica, n_PosIni, n_QtdDig )
					EndIf

				ElseIf nQt == 3

		
					aAuxAKM := {}

					If A1G->( dbSeek( xFilial("A1G")+"SB" ))
						c_Desc := STR0040 //"Sub Função"
						c_CpoMov := A1G->A1G_CAMPO
						c_CpFilt := A1G->A1G_CAMPO
						c_Tabela := A1G->A1G_CODTAB
						n_PosIni := If(Empty(A1G->A1G_INICPO), 1, A1G->A1G_INICPO)
						n_QtdDig := If(Empty(A1G->A1G_DIGCPO), 99, A1G->A1G_DIGCPO) 

						c_Radica := ""
						If A1H->( dbSeek( xFilial("A1H")+A1G->A1G_CODTAB ))
							c_Radica := A1H->A1H_RADCHV
						EndIf
					Else
						lContinua := .F.
					EndIf

					If lContinua
						A160Fill( "005", aAuxAKM, aTabAKM, @cItem, c_Desc, c_Alias, c_CpoMov, c_CpFilt, c_ConPad, c_Tabela, c_Radica, n_PosIni, n_QtdDig )
					EndIf

				ElseIf nQt == 4

					Loop

				ElseIf nQt == 5

					aAuxAKM := {}

					If A1G->( dbSeek( xFilial("A1G")+"DE" ))
						c_Desc := STR0041 //"Categoria Economica Despesas"
						c_CpoMov := A1G->A1G_CAMPO
						c_CpFilt := A1G->A1G_CAMPO
						c_Tabela := A1G->A1G_CODTAB
						n_PosIni := If(Empty(A1G->A1G_INICPO), 1, A1G->A1G_INICPO)
						n_QtdDig := If(Empty(A1G->A1G_DIGCPO), 99, A1G->A1G_DIGCPO) 

						c_Radica := ""
						If A1H->( dbSeek( xFilial("A1H")+A1G->A1G_CODTAB ))
							c_Radica := A1H->A1H_RADCHV
						EndIf
					Else
						lContinua := .F.
					EndIf

					If lContinua
						A160Fill( "005", aAuxAKM, aTabAKM, @cItem, c_Desc, c_Alias, c_CpoMov, c_CpFilt, c_ConPad, c_Tabela, c_Radica, n_PosIni, n_QtdDig )
					EndIf

				ElseIf nQt == 6

					aAuxAKM := {}

					If A1G->( dbSeek( xFilial("A1G")+"GD" ))
						c_Desc := STR0042 //"Grupo de Despesas"
						c_CpoMov := A1G->A1G_CAMPO
						c_CpFilt := A1G->A1G_CAMPO
						c_Tabela := A1G->A1G_CODTAB
						n_PosIni := If(Empty(A1G->A1G_INICPO), 1, A1G->A1G_INICPO)
						n_QtdDig := If(Empty(A1G->A1G_DIGCPO), 99, A1G->A1G_DIGCPO) 

						c_Radica := ""
						If A1H->( dbSeek( xFilial("A1H")+A1G->A1G_CODTAB ))
							c_Radica := A1H->A1H_RADCHV
						EndIf
					Else
						lContinua := .F.
					EndIf

					If lContinua
						A160Fill( "005", aAuxAKM, aTabAKM, @cItem, c_Desc, c_Alias, c_CpoMov, c_CpFilt, c_ConPad, c_Tabela, c_Radica, n_PosIni, n_QtdDig )
					EndIf

				ElseIf nQt == 7

					aAuxAKM := {}

					If A1G->( dbSeek( xFilial("A1G")+"MA" ))
						c_Desc := STR0043 //"Modalidade da Aplicacao"
						c_CpoMov := A1G->A1G_CAMPO
						c_CpFilt := A1G->A1G_CAMPO
						c_Tabela := A1G->A1G_CODTAB
						n_PosIni := If(Empty(A1G->A1G_INICPO), 1, A1G->A1G_INICPO)
						n_QtdDig := If(Empty(A1G->A1G_DIGCPO), 99, A1G->A1G_DIGCPO) 

						c_Radica := ""
						If A1H->( dbSeek( xFilial("A1H")+A1G->A1G_CODTAB ))
							c_Radica := A1H->A1H_RADCHV
						EndIf
					Else
						lContinua := .F.
					EndIf

					If lContinua
						A160Fill( "005", aAuxAKM, aTabAKM, @cItem, c_Desc, c_Alias, c_CpoMov, c_CpFilt, c_ConPad, c_Tabela, c_Radica, n_PosIni, n_QtdDig )
					EndIf

				ElseIf nQt == 8

					aAuxAKM := {}

					If A1G->( dbSeek( xFilial("A1G")+"SE" ))
						c_Desc := STR0044 //"Elemento/Sub-Elemento da Despesa"
						c_CpoMov := A1G->A1G_CAMPO
						c_CpFilt := A1G->A1G_CAMPO
						c_Tabela := A1G->A1G_CODTAB
						n_PosIni := If(Empty(A1G->A1G_INICPO), 1, A1G->A1G_INICPO)
						n_QtdDig := If(Empty(A1G->A1G_DIGCPO), 99, A1G->A1G_DIGCPO) 

						c_Radica := ""
						If A1H->( dbSeek( xFilial("A1H")+A1G->A1G_CODTAB ))
							c_Radica := A1H->A1H_RADCHV
						EndIf
					Else
						lContinua := .F.
					EndIf

					If lContinua
						A160Fill( "005", aAuxAKM, aTabAKM, @cItem, c_Desc, c_Alias, c_CpoMov, c_CpFilt, c_ConPad, c_Tabela, c_Radica, n_PosIni, n_QtdDig )
					EndIf

				ElseIf nQt == 9

					aAuxAKM := {}

					If A1G->( dbSeek( xFilial("A1G")+"FR" ))
						c_Desc := STR0045 //"Fonte de Recurso"
						c_CpoMov := A1G->A1G_CAMPO
						c_CpFilt := A1G->A1G_CAMPO
						c_Tabela := A1G->A1G_CODTAB
						n_PosIni := If(Empty(A1G->A1G_INICPO), 1, A1G->A1G_INICPO)
						n_QtdDig := If(Empty(A1G->A1G_DIGCPO), 99, A1G->A1G_DIGCPO) 

						c_Radica := ""
						If A1H->( dbSeek( xFilial("A1H")+A1G->A1G_CODTAB ))
							c_Radica := A1H->A1H_RADCHV
						EndIf
					Else
						lContinua := .F.
					EndIf

					If lContinua
						A160Fill( "005", aAuxAKM, aTabAKM, @cItem, c_Desc, c_Alias, c_CpoMov, c_CpFilt, c_ConPad, c_Tabela, c_Radica, n_PosIni, n_QtdDig )
					EndIf

				ElseIf nQt == 10

					aAuxAKM := {}

					If A1G->( dbSeek( xFilial("A1G")+"CA" ))
						c_Desc := STR0046 //"Codigo de Aplicacao"
						c_CpoMov := A1G->A1G_CAMPO
						c_CpFilt := A1G->A1G_CAMPO
						c_Tabela := A1G->A1G_CODTAB
						n_PosIni := If(Empty(A1G->A1G_INICPO), 1, A1G->A1G_INICPO)
						n_QtdDig := If(Empty(A1G->A1G_DIGCPO), 99, A1G->A1G_DIGCPO) 

						c_Radica := ""
						If A1H->( dbSeek( xFilial("A1H")+A1G->A1G_CODTAB ))
							c_Radica := A1H->A1H_RADCHV
						EndIf
					Else
						lContinua := .F.
					EndIf

					If lContinua
						A160Fill( "005", aAuxAKM, aTabAKM, @cItem, c_Desc, c_Alias, c_CpoMov, c_CpFilt, c_ConPad, c_Tabela, c_Radica, n_PosIni, n_QtdDig )
					EndIf

				EndIf
		
		Next
	EndIf	

	dbSelectArea("AKM")
	
	For nX := 1 TO Len(aTabAKM)
		RecLock("AKM", .T.)
		AKM->AKM_FILIAL := xFilial("AKM")
		For nY := 1 TO Len(aTabAKM[nX])
			If (nPos := FieldPos(aTabAKM[nX][nY][1])) > 0
				FieldPut(nPos, aTabAKM[nX][nY][2])
			EndIf
		Next
		MsUnLock()	
	Next

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A160Popula
Popula as tabelas AKL/AKM para codigos reservados 001 ; 002 ; 004 ; 005
@author TOTVS
@since 01/01/80
@version P12
/*/
//-------------------------------------------------------------------

Static Function A160Fill( cConfig, aAuxAKM, aTabAKM, cItem, c_Desc, c_Alias, c_CpoMov, c_CpFilt, c_ConPad, c_Tabela, c_Radica, n_PosIni, n_QtdDig )

cItem := Soma1(cItem)
aAdd(aAuxAKM, {'AKM_CONFIG' , cConfig })
aAdd(aAuxAKM, {'AKM_ITEM' , cItem })
aAdd(aAuxAKM, {'AKM_TITULO' , c_Desc }) 
aAdd(aAuxAKM, {'AKM_ENTSIS' , c_Alias })
aAdd(aAuxAKM, {'AKM_CPOREF' , c_CpoMov })
aAdd(aAuxAKM, {'AKM_ENTFIL' , 'AKD' })
aAdd(aAuxAKM, {'AKM_CPOFIL' , c_CpFilt })
aAdd(aAuxAKM, {'AKM_CONPAD' , c_ConPad })

aAdd(aAuxAKM, {'AKM_CODTAB' , c_Tabela })
aAdd(aAuxAKM, {'AKM_RADCHV' , c_Radica })
aAdd(aAuxAKM, {'AKM_INICPO' , n_PosIni })
aAdd(aAuxAKM, {'AKM_DIGCPO' , n_QtdDig })

aAdd(aAuxAKM, {'AKM_TIPO' , '2'})  
	
aAdd(aAuxAKM, {'AKM_VALINI' , '"'+Replicate(" ", n_QtdDig)+'"'})
aAdd(aAuxAKM, {'AKM_VALFIM' , '"'+Replicate("Z", n_QtdDig)+'"' })
	
aAdd(aTabAKM, aAuxAKM)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} a160Suges
Preenche o grid de acordo com cubo digitado 
@author TOTVS
@since 01/01/80
@version P12
/*/
//-------------------------------------------------------------------

Static Function a160Suges(nCallOpcx, aHeadAKM, oGdAKM )
Local nLin   := 1
Local aArea := GetArea()
Local aAreaAKW := AKW->(GetArea())
Local nPosItem		:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_ITEM"})
Local nPosTitle		:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_TITULO"})
Local nPosEntSis	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_ENTSIS"})
Local nPosCpoRef	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_CPOREF"})
Local nPosEntFil	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_ENTFIL"})
Local nPosCpoFil	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_CPOFIL"})
Local nPosConPad	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_CONPAD"})
Local nPosTipo		:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_TIPO"})
Local nPosValIni	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_VALINI"})
Local nPosValFim	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_VALFIM"})
Local nPosTipoCp	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_TIPOCP"})
Local nPosTamanh	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_TAMANH"})
Local nPosDecima	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_DECIMA"})
Local nPosPictur	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_PICTUR"})
//novos campos para MCASP TABELA / RADICAL / POS INI / QTD DIGITO DEIXAR VAZIO TODOS OS CAMPOS
Local nPosTabela	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_CODTAB"})
Local nPosRadChv	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_RADCHV"})
Local nPosIniCpo	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_INICPO"})
Local nPosDigCpo	:= aScan(aHeadAKM,{|x| AllTrim(x[2]) == "AKM_DIGCPO"})

If nCallOpcx  == 3
	If Empty(M->AKL_CUBE)
		Aviso(STR0023, STR0025,{"Ok"})//"Atencao"###"Deve ser informado o codigo do cubo gerencial."
		Return
    EndIf
    
    dbSelectArea("AKW")
    dbSetOrder(1)
    If !dbSeek(xFilial("AKW")+M->AKL_CUBE)
		Aviso(STR0023, STR0024,{"Ok"})//"Atencao"###"Cubo nao existente. Verifique! "
    	Return
    EndIf
    
    While AKW->(!Eof() .AND. AKW_FILIAL+AKW_COD=xFilial("AKW")+M->AKL_CUBE)	
	    	
    	If nLin > 1 .And. Len(oGdAKM:aCols) < nLin
			AAdd(oGdAKM:aCols,Array( Len(aHeadAKM)+1 ))
			oGdAKM:aCols[nLin][Len(aHeadAKM)+1] := .F.
		EndIf
    	
    	//primeira linha do acols ja existe-somente substituir valores
		oGdAKM:aCols[nLin][nPosItem]	:= StrZero(Val(AKW->AKW_NIVEL),Len(AKM->AKM_ITEM))
		oGdAKM:aCols[nLin][nPosTitle]	:= AKW->AKW_DESCRI
		oGdAKM:aCols[nLin][nPosEntSis]	:= AKW->AKW_ALIAS
		oGdAKM:aCols[nLin][nPosCpoRef]	:= Subs(AKW->AKW_RELAC,6)
		oGdAKM:aCols[nLin][nPosEntFil]	:= LEFT(AKW->AKW_CHAVER,3)
		oGdAKM:aCols[nLin][nPosCpoFil]	:= SUBS(AKW->AKW_CHAVER,6)
		oGdAKM:aCols[nLin][nPosConPad]	:= AKW->AKW_F3
		oGdAKM:aCols[nLin][nPosTipo]	:= "2"
		oGdAKM:aCols[nLin][nPosValIni]	:= '"'+Space(AKW->AKW_TAMANH)+'"'
		oGdAKM:aCols[nLin][nPosValFim]	:= '"'+Repl("z", AKW->AKW_TAMANH)+'"'

		oGdAKM:aCols[nLin][nPosTipoCp]	:= "1"
		oGdAKM:aCols[nLin][nPosTamanh]	:= 0
		oGdAKM:aCols[nLin][nPosDecima]	:= 0
		oGdAKM:aCols[nLin][nPosPictur]	:= ""

		//novos campos para MCASP TABELA / RADICAL / POS INI / QTD DIGITO DEIXAR VAZIO TODOS OS CAMPOS
		oGdAKM:aCols[nLin][nPosTabela]	:= Space(Len(AKM->AKM_CODTAB))
		oGdAKM:aCols[nLin][nPosRadChv]	:= Space(Len(AKM->AKM_RADCHV))
		oGdAKM:aCols[nLin][nPosIniCpo]	:= 0
		oGdAKM:aCols[nLin][nPosDigCpo]	:= 0

        nLin++
		AKW->(dbSkip())
	
	End

EndIf

RestArea(aAreaAKW)
RestArea(aArea)

Return 




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³11/12/06 ³±±
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
							{ STR0003, 	"A160DLG" , 0 , 2},;    //"Visualizar"
							{ STR0004,	"A160DLG" , 0 , 3},;	  //"Incluir"
							{ STR0005, 	"A160DLG" , 0 , 4},; //"Alterar"
							{ STR0006, 	"A160DLG" , 0 , 5},; //"Excluir"
							{ STR0047,  "A160CPY" , 0 , 6}} //"Copiar"

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario no aRotina                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA1601" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
		//P_E³ browse da tela de processos                                            ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
		//P_E³               Ex. :  User Function PCOA1601                            ³
		//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA1601", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} Pcoa160Whe
Condicao para permitir ou nao edicao de campo

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function Pcoa160Whe(nPar)
Local lRet := .T.

Default nPar := 0

If nPar == 1
	lRet := Alltrim(GdFieldGet("AKM_ENTSIS")) == "A1H"
ElseIf nPar == 2
	lRet := Alltrim(GdFieldGet("AKM_ENTSIS")) == "A1H" .And. !Empty(GdFieldGet("AKM_CODTAB"))
ElseIf nPar == 3
	lRet := Alltrim(GdFieldGet("AKM_ENTSIS")) == "A1H" .And. !Empty(GdFieldGet("AKM_CODTAB")) .And. !Empty(GdFieldGet("AKM_RADCHV"))
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} Pco160X3
Consulta padrao especifica para listar os campos da tabelas relacionadas

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function Pco160X3()

Local lRet	  := .T.
Local nOpcA   := 0
Local cVar	  := ReadVar()
Local nTam	  := Len(&cVar)
Local oDlgCons
Local oGetCons   
Local aSx3Fields := {}
Local nAt,nX
Local cCpoX3 := "AKD_CODPLA|AKD_VERSAO|AKD_CO|AKD_CLASSE|AKD_OPER|AKD_CC|AKD_ITCTB|AKD_CLVLR|AKD_UNIORC|AKD_ENT05|AKD_ENT06|AKD_ENT07|AKD_ENT08|AKD_ENT09|AKD_TPSALD"
Local oStrucTab	:= NIL
Local cCpoAnt   := &cVar
Local cAliTab   := ''

If cVar == 'M->AKM_CPOREF'
	cAliTab := Alltrim(GdFieldGet("AKM_ENTSIS"))
Else
	cAliTab := Alltrim(GdFieldGet("AKM_ENTFIL"))
EndIf

If cVar == 'M->AKM_CPOREF'  //SOMENTE CAMPO REFERENCIA PRECISA REATRIBUIR STRING CONTENDO CAMPOS
	If 		cAliTab == 'AK1'
		cCpoX3 := '|AK1_CODIGO'

	ElseIf 	cAliTab == 'AKE'
		cCpoX3 := '|AKE_REVISA'

	ElseIf 	cAliTab == 'AK5'
		cCpoX3 := '|AK5_CODIGO'

	ElseIf 	cAliTab == 'AK6'
		cCpoX3 := '|AK6_CODIGO'

	ElseIf 	cAliTab == 'AKF'
		cCpoX3 := '|AKF_CODIGO'

	ElseIf 	cAliTab == 'CTT'
		cCpoX3 := '|CTT_CUSTO'

	ElseIf 	cAliTab == 'CTD'
		cCpoX3 := '|CTD_ITEM'  

	ElseIf 	cAliTab == 'CTH'
		cCpoX3 := '|CTH_CLVL'  

	ElseIf 	cAliTab == 'AMF'
		cCpoX3 := '|AMF_CODIGO'

	ElseIf 	cAliTab == 'CV0'
		cCpoX3 := '|CV0_CODIGO'

	ElseIf 	cAliTab == 'AL2'
		cCpoX3 := '|AL2_TPSALD'

	Else
		cCpoX3 := ""

	EndIf

EndIf

oStrucTab	:= FWFormStruct(2,cAliTab)

For nX := 1 to Len(oStrucTab:aFields)

		If !Empty(cCpoX3) .And. ! ( AllTrim(oStrucTab:aFields[nX,1]) $ cCpoX3 )
			Loop
		EndIf

		aAdd(aSx3Fields, {Nil, Nil, Nil}) 
		aSX3Fields[Len(aSx3Fields)][1] := oStrucTab:aFields[nX,1]
		aSX3Fields[Len(aSx3Fields)][2] := PadR( oStrucTab:aFields[nX,3], 15)
		aSX3Fields[Len(aSx3Fields)][3] := oStrucTab:aFields[nX,4]
			
Next nX

Define MsDialog oDlgCons Title If(cVar=='AKM_CPOREF',STR0048, STR0049) From 000, 000 To 450, 800 PIXEL //"Consulta de Campos Tabelas Relacionadas", "Consulta de campos Mov.Orçamentario"

	Define Font oFont Name 'Courier New' Size 0, -12		
	oGetCons := TCBrowse():New( 000, 000, 545, 200,, { If(cVar=='AKM_CPOREF',STR0050, STR0051), STR0052, STR0053 },,;    //"Campos Tabelas Relacionadas", ##"Campos Mov.Orct."##"Título"##"Descrição"
	                            oDlgCons,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  	

	oGetCons:SetArray(aSx3Fields)
	oGetCons:bLine := {||{	aSx3Fields[oGetCons:nAt,1],aSx3Fields[oGetCons:nAt,2],aSx3Fields[oGetCons:nAt,3]}} 	                            
	oGetCons:blDblClick := {||nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End()}

	@208,310 BUTTON STR0054 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End())	//"Confirmar"
	@208,360 BUTTON STR0055 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 0, oDlgCons:End())	//"Cancelar"

Activate MsDialog oDlgCons Centered

If nOpcA == 1 
	&cVar := aSx3Fields[nAt,1]
	&cVar += Space(nTam-Len(&cVar))
Else
	//recupera o que estava anteriormente
	&cVar := cCpoAnt
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Pco160XB
Consulta padrao especifica para listar os campos da tabelas de Receitas ou Despesas MCASP

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function Pco160XB()

Local lRet	  := .T.
Local nOpcA   := 0
Local cVar	  := ReadVar()
Local nTam	  := Len(&cVar)
Local oDlgCons
Local oGetCons   
Local aTabRecDes := {}

Local cCpoAnt   := &cVar
Local cCodTab   := ""
Local cRadical  := ""


If cVar == 'M->AKM_VALINI' .OR. cVar == 'M->AKM_VALFIM'
	cCodTab := Alltrim(GdFieldGet("AKM_CODTAB"))
	cRadical := Alltrim(GdFieldGet("AKM_RADCHV"))
	aTabRecDes := Pco160Tbl(cCodTab, cRadical)
Else
	aAdd( aTabRecDes, { "NO_APLY", "Nao se Aplica"})
EndIf

Define MsDialog oDlgCons Title STR0056 From 000, 000 To 450, 800 PIXEL //"Consulta de Tabelas Rec.Desp."

	Define Font oFont Name 'Courier New' Size 0, -12		
	oGetCons := TCBrowse():New( 000, 000, 545, 200,, { STR0057, STR0058 },,;    //"Codigo"##"Descrição"
	                            oDlgCons,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  	

	oGetCons:SetArray(aTabRecDes)
	oGetCons:bLine := {||{	aTabRecDes[oGetCons:nAt,1],aTabRecDes[oGetCons:nAt,2] } } 	                            
	oGetCons:blDblClick := {||nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End()}

	@208,310 BUTTON STR0054 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End())	//"Confirmar"
	@208,360 BUTTON STR0055 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 0, oDlgCons:End())	//"Cancelar"

Activate MsDialog oDlgCons Centered

If nOpcA == 1 
	&cVar := aTabRecDes[nAt,1]
	&cVar += Space(nTam-Len(&cVar))
	A1H->( dbGoto(aTabRecDes[nAt,3]) )
Else
	//recupera o que estava anteriormente
	&cVar := cCpoAnt
	lRet := .F.
EndIf

Return lRet




//-------------------------------------------------------------------
/*/{Protheus.doc} Pco160Tbl
Retorna um array com codigo/descricao da tabelas de Receitas ou Despesas MCASP

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function Pco160Tbl(cCodTab, cRadical)
Local aArea := GetArea()
Local cQuery := ""
Local aRetorno := {}
Local cAliasTmp := CriaTrab(,.F.)

cQuery += " SELECT A1H_ITECHV, A1H_CHVCNT, R_E_C_N_O_ RECTAB "
cQuery += " FROM " + RetSqlName("A1H")
cQuery += " WHERE "
cQuery +=  "      A1H_FILIAL = '"+xFilial("A1H")+"' " 
cQuery += "   AND A1H_CODTAB = '"+cCodTab+"' " 
cQuery += "   AND A1H_RADCHV =  '"+cRadical+"' " 
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY A1H_ITECHV "

cQuery := ChangeQuery( cQuery )

//abre a query com mesmo alias da dimensao
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .T. )
While (cAliasTmp)->( ! Eof() )
	aAdd( aRetorno, { (cAliasTmp)->A1H_ITECHV, (cAliasTmp)->A1H_CHVCNT, (cAliasTmp)->RECTAB } )
	(cAliasTmp)->( dbSkip() )
EndDo

(cAliasTmp)->( DBCloseArea() )

RestArea(aArea)

Return(aRetorno)
//-------------------------------------------------------------------
/*/{Protheus.doc} a160ConsPad
Consulta padrao de acordo a linha do Grid

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function a160ConsPad(nCallOpcx, aHeadAKM, oGdAKM )
Local xRet := ""
Local cConsulta := ""
Local nPosCPad :=0
Local nLinGd := 1
Local nPosCpo := 0
Local nPosIni := 0
Local nPosFim := 0
Local nPosEnt := 0
Local nPosRef := 0
Local cTabEnt := ""
Local cCpoRef := ""
Local nPosFlt := 0

nLinGd := oGdAKM:oBrowse:nAt
nPosCpo := oGdAKM:oBrowse:ColPos()

nPosCPad := Ascan(oGdAKM:aHeader, {|x| Upper(AllTrim(x[2])) == "AKM_CONPAD" })

If nPosCPad != 0 .And. !Empty(oGdAKM:aCols[nLinGd, nPosCPad])

	nPosEnt := Ascan(oGdAKM:aHeader, {|x| Upper(AllTrim(x[2])) == "AKM_ENTSIS" })
	nPosRef := Ascan(oGdAKM:aHeader, {|x| Upper(AllTrim(x[2])) == "AKM_CPOREF" })
	cTabEnt := Alltrim(oGdAKM:aCols[nLinGd, nPosEnt])
	cCpoRef := Alltrim(oGdAKM:aCols[nLinGd, nPosRef])

	nPosFlt := Ascan(oGdAKM:aHeader, {|x| Upper(AllTrim(x[2])) == "AKM_CPOFIL" })

	nPosIni := Ascan(oGdAKM:aHeader, {|x| Upper(AllTrim(x[2])) == "AKM_VALINI" })
	nPosFim := Ascan(oGdAKM:aHeader, {|x| Upper(AllTrim(x[2])) == "AKM_VALFIM" })

	If nPosCpo == nPosIni .OR. nPosCpo == nPosFim
	
		cConsulta := oGdAKM:aCols[nLinGd, nPosCPad]

		If Alltrim(cConsulta) == "A1HXB"
			//Necessario acertar retorno da funcao ReadVar()
			If nPosCpo == nPosIni
				M->AKM_VALINI := oGdAKM:aCols[nLinGd, nPosIni]
				__READVAR := "M->AKM_VALINI"
			ElseIf nPosCpo == nPosFim
				M->AKM_VALFIM := oGdAKM:aCols[nLinGd, nPosFim]
				__READVAR := "M->AKM_VALFIM"
			EndIf
			//variaveis privates necessarias pois utiliza gdFieldGet
			N := nLinGd
			AHEADER := ACLONE(aHeadAKM)
			ACOLS := ACLONE(oGdAKM:aCols)
		ElseIf Alltrim(cConsulta) == 'CV0'
			cPlano := Right( Alltrim(oGdAKM:aCols[nLinGd, nPosFlt]), 2)
			If nPosCpo == nPosIni
				cCodigo := oGdAKM:aCols[nLinGd, nPosIni]
			Else
				cCodigo := oGdAKM:aCols[nLinGd, nPosFim]
			EndIf
		EndIf
		
		If ConPad1( , , , cConsulta , , , .F. )
			If Alltrim(cConsulta) == "A1HXB"
				oGdAKM:aCols[nLinGd, nPosCpo] := '"'+ Alltrim(A1H->A1H_ITECHV) + '"'
			Else
				oGdAKM:aCols[nLinGd, nPosCpo] := '"' + &(cTabEnt+"->"+cCpoRef) + '"'
			EndIf
		EndIf
	Else
		HELP("  ",1,"NO_CONPAD",,STR0059, 1, 0 )  //"Consulta Padrao - Posicionar em um dos campos: Valor Inicio ou Valor Final."
	EndIf

EndIf
Return(xRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A160CPY   ºAutor  ³Paulo Carnelossi    º Data ³  12/11/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Copia do Registro Posicionado AKL / AKM                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A160CPY(cAlias,nRecnoAKL,nCallOpcx)
Local cCfgAKL := ""
Local cCfgNew := Space(Len(AKL->AKL_CONFIG))
Local aParam  := {}
Local aRet    := { cCfgNew }
Local aTabAKL := {}
Local aTabAKM := {}
Local aAuxAKM := {}
Local nX
Local nI
Local cCampo  := ""
Local aAreaAKL := AKL->( GetArea() )
Local lRet    := .T.

Private INCLUI  := .F.

dbSelectArea("AKL")
dbSetOrder(1)
cCfgAKL := AKL->AKL_CONFIG

aAdd(aParam,{1,STR0060+cCfgAKL+STR0061,cCfgNew,,,,,180,.T.})  //"Copiar Cfg.: "##" >> Nova Config.Parametros Visão"

If Parambox(aParam,STR0062,@aRet,,,.T.,,,,,.F.,.F.)  //"Parametros Visão"
	cCfgNew := aRet[1]
Else
	lRet := .F.
EndIf

If lRet .And. AKL->( dbSeek( xFilial("AKL") + cCfgNew ) )
	Help(" ",1,"JAGRAVADO")
	lRet := .F.
EndIf

//nao retirar RestArea da AKL para voltar ao registro original antes do dbseek
RestArea( aAreaAKL )

If lRet
	For nX := 1 To FCount()
		aAdd(aTabAKL, { FieldName(nX), FieldGet(nX) })
		If FieldName(nX) == 'AKL_CONFIG'
			aTabAKL[Len(aTabAKL), 2] := cCfgNew
		EndIf
	Next

	dbSelectArea("AKM")
	dbSetOrder(1)

	dbSeek( xFilial("AKM") + cCfgAKL )

	While AKM->( ! Eof() .And. AKM_FILIAL+AKM_CONFIG == xFilial("AKM") + cCfgAKL )

		aAuxAKM := {}
		For nX := 1 To FCount()
			aAdd(aAuxAKM, { FieldName(nX), FieldGet(nX) })
			If FieldName(nX) == 'AKM_CONFIG'
				aAuxAKM[Len(aAuxAKM), 2] := cCfgNew
			EndIf
		Next

		aAdd( aTabAKM, aClone(aAuxAKM) )

		AKM->( dbSkip() )

	EndDo

	//Gravação da tabela AKL / AKM
	Reclock("AKL",.T.)
	For nX := 1 To FCount()
		cCampo := Upper(AllTrim(FieldName(nX)))
		If cCampo == "AKL_FILIAL"
			FieldPut( nX, xFilial("AKL") )
		ElseIf cCampo == "AKL_SYSTEM"
			FieldPut( nX,  "2" )
		Else
			FieldPut( nX, aTabAKL[nX, 2] )
		EndIf
	Next nX
	MsUnlock()

	// Grava itens
	For nX := 1 To Len(aTabAKM)
			
		Reclock("AKM",.T.)

		For nI := 1 To FCount()
			cCampo := Upper(AllTrim(FieldName(nI)))
			If cCampo == "AKM_FILIAL"
				FieldPut( nI, xFilial("AKM") )
			Else
				FieldPut( nI, aTabAKM[nX, nI, 2] )
			EndIf
		Next

		Replace AKM_CONFIG With cCfgNew
		MsUnlock()

	Next nX


	MsgInfo("", STR0063 + cCfgNew + STR0064 )  //"Nova Configuracao de Parametros: "##" Copiado com sucesso! "

EndIf

Return(lRet)