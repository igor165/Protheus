
#INCLUDE "PCOA030.ch"
#INCLUDE "PROTHEUS.CH"
/*
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA030  ³ AUTOR ³ Guilherme C. Leal     ³ DATA ³ 26.11.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa para cadastro de processos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA030                                                      ³±±
±±³_DESCRI_  ³ Programa para cadastro de processos, pontos de lancamentos   ³±±
±±³_DESCRI_  ³ e pontos de bloqueio.                                        ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal    ³±±
±±³          ³ partir do Menu ou a partir de uma funcao pulando assim o     ³±±
±±³          ³ browse principal e executando a chamada direta da rotina     ³±±
±±³          ³ selecionada.                                                 ³±±
±±³          ³ Exemplo: PCOA030(2) - Executa a chamada da funcao de visua-  ³±±
±±³          ³                        zacao da rotina.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Chamada direta sem passar pela mBrowse               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA030(nCallOpcx)
Private cCadastro	:= STR0001 //"Cadastro de Processos de Sistema"
Private aRotina := MenuDef()    

If ExistBlock("PCOA030VAR")
	ExecBlock("PCOA030VAR",.F.,.F.)
EndIf

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil
		A030DLG("AK8",AK8->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AK8")
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A030DLG   ºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- º±±
±±º          ³ zacao                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A030DLG(cAlias,nRecnoAK8,nCallOpcx)
Local oDlg
Local lCancel  := .F.
Local aButtons	:= {{"NCO",{|| A030PropLc(@cCposCfg) },STR0015,STR0016}}//"Configuração dos Campos"###"Campos"
Local aUsButtons := {}
Local oEnchAK8
Local oFolder

Local oGdAKB
Local aHeadAKB
Local aColsAKB
Local nLenAKB   := 0 // Numero de campos em uso no AKB
Local nLinAKB   := 0 // Linha atual do acols
Local aRecAKB   := {} // Recnos dos registros
Local nGetD
Local oSize
Local nLinIni := 0 
Local nColIni := 0 
Local nLinEnd := 0 
Local nColEnd := 0 

Local oBarAKB
Local oBtnAKB

Private INCLUI  := (nCallOpcx = 3)
Private cCposCfg := If(Inclui,"",AK8->AK8_PROPLC)

If !AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	Return .F.
EndIf

If nCallOpcx != 3 .And. ValType(nRecnoAK8) == "N" .And. nRecnoAK8 > 0
	DbSelectArea(cAlias)
	DbGoto(nRecnoAK8)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoAK8)))
		Return .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOA0302" )
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para inclusao de botoes de usuarios         ³
	//P_E³ na tela de processos                                                   ³
	//P_E³ Parametros : Nenhum                                                    ³
	//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
	//P_E³  Ex. :  User Function PCOA0302                                         ³
	//P_E³         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ValType( aUsButtons := ExecBlock( "PCOA0302", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

oSize := FwDefSize():New(.T.,,,)
oSize:AddObject( "CABECALHO",  100, 20, .T., .T. ) 
oSize:AddObject( "GETDADOS" ,  100, 80, .T., .T. ) 
oSize:lProp 	:= .T. 
oSize:Process() 

DEFINE MSDIALOG oDlg TITLE STR0007 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4]  PIXEL //"Cadastro de Processos"

// Carrega dados do AK8 para memoria
RegToMemory("AK8",INCLUI)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice com os dados do Processo                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinIni :=   oSize:GetDimension("CABECALHO","LININI") 
nColIni :=  oSize:GetDimension("CABECALHO","COLINI") 
nLinEnd := oSize:GetDimension("CABECALHO","LINEND")
nColEnd := oSize:GetDimension("CABECALHO","COLEND") 

oEnchAK8 := MSMGet():New('AK8',,nCallOpcx,,,,,{nLinIni,nColIni,nLinEnd,nColEnd},,,,,,oDlg,,,,,,.T.,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder com os Pontos de Lancamento                                     ³
//³ Pontos de Bloqueio foi desativada pois tera tela especifica            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinIni :=   oSize:GetDimension("GETDADOS","LININI") 
nColIni :=  oSize:GetDimension("GETDADOS","COLINI") 
nLinEnd := oSize:GetDimension("GETDADOS","LINEND")
nColEnd := oSize:GetDimension("GETDADOS","COLEND") 

oFolder  := TFolder():New(nLinIni,nColIni,{STR0008/*,STR0009*/},{''},oDlg,1,,,.T.,,nColEnd,nLinEnd-80,) //"Pontos de Lançamento"###"Pontos de Bloqueio"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do AKB                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadAKB := GetaHeader("AKB")
nLenAKB  := Len(aHeadAKB) + 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Panel para colocar botoes no folder de Pontos de Lancamento            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

AADD(aButtons, {"NOTE"		, {|| A030Lancto(oGdAKB) }, STR0017 } )	//"Configuração dos Lançamentos"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols do AKB                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsAKB := {}
DbSelectArea("AKB")
DbSetOrder(1)
DbSeek(xFilial()+AK8->AK8_CODIGO)

While nCallOpcx != 3 .And. !Eof() .And. AKB->AKB_FILIAL + AKB->AKB_PROCES == xFilial() + AK8->AK8_CODIGO
	AAdd(aColsAKB,Array( nLenAKB ))
	nLinAKB++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAKB, {|x,y| aColsAKB[nLinAKB][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })

	// Deleted
	aColsAKB[nLinAKB][nLenAKB] := .F.
	
	// Adiciona o Recno no aRec
	AAdd( aRecAKB, AKB->( Recno() ) )
	
	AKB->(DbSkip())
EndDo

// Verifica se não foi criada nenhuma linha para o aCols
If Len(aColsAKB) = 0
	AAdd(aColsAKB,Array( nLenAKB ))
	nLinAKB++

	// Varre o aHeader para preencher o acols
	AEval(aHeadAKB, {|x,y| aColsAKB[nLinAKB][y] := IIf(Upper(AllTrim(x[2])) == "AKB_ITEM", StrZero(1,Len(AKB->AKB_ITEM)),CriaVar(AllTrim(x[2])) ) })

	// Deleted
	aColsAKB[nLinAKB][nLenAKB] := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados com os Pontos de Lancamento          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCallOpcx = 3 .Or. nCallOpcx = 4
	nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nGetD := 0
EndIf
oGdAKB:= MsNewGetDados():New(0,0,100,100,nGetd,,,"+AKB_ITEM",,,9999,,,,oFolder:aDialogs[1],aHeadAKB,aColsAKB)
oGdAKB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGdAKB:CARGO := AClone(aRecAKB)

// Quando nao for MDI chama centralizada. 

If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(A030Ok(nCallOpcx,oEnchAK8,oGdAKB),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons,,,,, .F. )
Else
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(A030Ok(nCallOpcx,oEnchAK8,oGdAKB),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons,,,,, .F. )
EndIf


If lCancel
	RollBackSX8()
EndIf


Return !lCancel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A030Ok   ºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao do botao OK da enchoice bar, valida e faz o         º±±
±±º          ³ tratamento adequado das informacoes.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A030Ok(nCallOpcx,oEnchAK8,oGdAKB)
Local nI
Local cCampo
If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If !A030Vld(nCallOpcx,oEnchAK8,oGdAKB)
	Return .F.
EndIf

If nCallOpcx = 3 // Inclusao

	// Grava Processo
	Reclock("AK8",.T.)
	For nI := 1 To FCount()
		cCampo := Upper(AllTrim(FieldName(nI)))
		If cCampo == "AK8_FILIAL"
			FieldPut(nI,xFilial())
		Else
			FieldPut(nI, &("M->" + cCampo))
		EndIf
	Next nI
	AK8->AK8_PROPLC	:= cCposCfg
	MsUnlock()
	
	// Grava Pontos de Lancamento
	For nI := 1 To Len(oGdAKB:aCols)
		If oGdAKB:aCols[nI][Len(oGdAKB:aCols[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AKB",.T.)
		EndIf

		// Varre o aHeader e grava com base no acols
		AEval(oGdAKB:aHeader,{|x,y| FieldPut(FieldPos(x[2]), oGdAKB:aCols[nI][y] ) })

		Replace AKB_FILIAL With xFilial()
		Replace AKB_PROCES With AK8->AK8_CODIGO

		MsUnlock()

	Next nI
	
ElseIf nCallOpcx = 4 // Alteracao

	// Grava Processo
	Reclock("AK8",.F.)
	For nI := 1 To FCount()
		cCampo := Upper(AllTrim(FieldName(nI)))
		If cCampo == "AK8_FILIAL"
			FieldPut(nI,xFilial())
		Else
			FieldPut(nI, &("M->" + cCampo))
		EndIf
	Next nI
	AK8->AK8_PROPLC	:= cCposCfg	
	MsUnlock()

	// Grava Pontos de Lancamento
	For nI := 1 To Len(oGdAKB:aCols)
		If nI <= Len(oGdAKB:Cargo) .And. oGdAKB:Cargo[nI] > 0
			AKB->(DbGoto(oGdAKB:Cargo[nI]))
			Reclock("AKB",.F.)
		Else
			If oGdAKB:aCols[nI][Len(oGdAKB:aCols[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AKB",.T.)
			EndIf
		EndIf
	
		If oGdAKB:aCols[nI][Len(oGdAKB:aCols[nI])] // Verifica se a linha esta deletada
            // Se houver alguma configuracao de lancamento, apaga.
			If AKC->(DbSeek(xFilial()+AKB->AKB_PROCES+AKB->AKB_ITEM))
				While AKC->(!Eof()) .And. AKC->AKC_FILIAL + AKC->AKC_PROCES + AKC->AKC_ITEM == xFilial("AKC") + AKB->AKB_PROCES + AKB->AKB_ITEM
					Reclock("AKC",.F.)
					AKC->(DbDelete())
					MsUnLock()
					AKC->(DbSkip())
				EndDo
			EndIf
			AKB->(DbDelete())
		Else
			// Varre o aHeader e grava com base no acols
			AEval(oGdAKB:aHeader,{|x,y| FieldPut( FieldPos(x[2]) , oGdAKB:aCols[nI][y] ) })
			Replace AKB_FILIAL With xFilial()
			Replace AKB_PROCES With AK8->AK8_CODIGO

		EndIf

		MsUnlock()
	Next nI

ElseIf nCallOpcx = 5 // Exclusao

	AKC->(DbSetOrder(1))
	// Exclui Pontos de Lancamento
	For nI := 1 To Len(oGdAKB:aCols)
		If nI <= Len(oGdAKB:Cargo) .And. oGdAKB:Cargo[nI] > 0
			AKB->(DbGoto(oGdAKB:Cargo[nI]))

            // Se houver alguma configuracao de lancamento, apaga.
			If AKC->(DbSeek(xFilial()+AKB->AKB_PROCES+AKB->AKB_ITEM))
				While AKC->(!Eof()) .And. AKC->AKC_FILIAL + AKC->AKC_PROCES + AKC->AKC_ITEM == xFilial("AKC") + AKB->AKB_PROCES + AKB->AKB_ITEM
					Reclock("AKC",.F.)
					AKC->(DbDelete())
					MsUnLock()
					
					AKC->(DbSkip())
				EndDo
			EndIf

			Reclock("AKB",.F.)
			AKB->(DbDelete())
			MsUnLock()
		EndIf		
	Next nI

	// Exclui Processo
	Reclock("AK8",.F.)
	AK8->(DbDelete())
	MsUnLock()

EndIf

If __lSX8
	ConfirmSX8()
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A030Vld  ºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de validacao dos campos.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A030Vld(nCallOpcx,oEnchAK8,oGdAKB)
Local nI
If (nCallOpcx = 3 .Or. nCallOpcx = 4) .And. !Obrigatorio(oEnchAK8:aGets,oEnchAK8:aTela)
	Return .F.
EndIf


If nCallOpcx = 5   //exclusao

	AKA->(dbSetOrder(1))
	If AKA->(DbSeek(xFilial()+M->AK8_CODIGO))
	   Aviso(STR0018, STR0019, {"Ok"})//"Atencao"###"Nao pode ser excluido, pois existem pontos de Bloqueio."
		Return .F.
	EndIf

EndIf		  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Codigos de 0 a 4999 sao reservados para lancamentos internos,     ³
//³ os demais podem ser usados em customizacoes                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Val(M->AK8_CODIGO) < 900000
	If nCallOpcx = 3
		MsgInfo(STR0011) //"O código utilizado deve ser maior que 900000."
		Return .F.
	ElseIf nCallOpcx = 4 .Or. nCallOpcx = 5
		If !(MsgYesNo(STR0012 +CRLF+ STR0026)) //"O processo atual é padrão, você tem certeza que deseja salvar as alterações? Obs: O processo padrão será restaurado ao reiniciar o sistema, desfazendo as alterações realizadas."
			Return .F.
		EndIf
	EndIf
EndIf

For nI := 1 To Len(oGdAKB:aCols)
	// Busca por campos obrigatorios que nao estjam preenchidos
	nPosField := AScanx(oGdAKB:aHeader,{|x,y| x[17] .And. Empty(oGdAKB:aCols[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("AKD"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+ STR0020 + AllTrim(oGdAKB:aHeader[nPosField][1]) + STR0021 +Str(nI,3,0),3,1) //"Campo: "###"Linha: "
		Return .F.
	EndIf
Next nI

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A030LanctoºAutor  ³Guilherme C. Leal   º Data ³  11/26/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a chamada da A040Dlg para edicao dos lancammentos      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A030Lancto(oGdAKB)
Local nPosDesc := AScan(oGdAKB:aHeader,{|x| Upper(AllTrim(x[2])) == "AKB_DESCRI" })
Local lRet     := .F.
Local nLin     := oGdAKB:oBrowse:nAt

If Empty(nLin)
	Return .F.
EndIf

If nLin > Len(oGdAKB:CARGO)
	MsgInfo(STR0013) //"O Registro atual ainda não foi salvo. Salve-o antes de editar seus lançamentos."
	Return .F.
EndIf
If nPosDesc <= 0
	MsgInfo(STR0014) //"O campo 'AKB_DESCRI' não está habilitado, favor contactar o suporte Microsiga para que o campo seja habilitado."
	Return .F.
EndIf

AKB->(DbGoto(oGdAKB:CARGO[nLin]))
If AKB->(EOF()) .OR. AKB->(BOF())
	Return .F.
EndIf

lRet := A040DLG("AKB",AKB->(Recno()),4)

Return lRet



Function A030PropLc(cPropri)

Local aArea	:= GetArea()
Local aSX3	:= {}
Local aParamBox	:= {}
Local aRet		:= {}      
Local nx

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AKD")
While !Eof() .and. SX3->X3_ARQUIVO == "AKD"
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel
		aAdd(aSX3,SX3->X3_CAMPO)
		nPos := AT(Alltrim(SX3->X3_CAMPO)+";",cPropri)
		If nPos > 0
			If Substr(cPropri,Len(Alltrim(SX3->X3_CAMPO))+nPos+1,1) == "1"
				lCheck := .T.
			Else
				lCheck := .F.
			EndIf
		Else
			lCheck := .F.
		EndIf
		If Empty(aParamBox)
			aAdd(aParamBox,{ 4 ,STR0022,lCheck,Alltrim(X3DESCRIC()),80 ,""    ,.F.  })//"Campos Visuais ?"
		Else
			aAdd(aParamBox,{ 4 ,"",lCheck,Alltrim(X3DESCRIC()),75 ,""    ,.F.  })
		EndIf
	EndIf
	dbSkip()
End

If ParamBox(aParamBox,STR0023,@aRet)//"Configuração da Tela de Lancamentos"
	cPropri := ""
	For nx := 1 to Len(aRet)
		cPropri += AllTrim(aSX3[nx])+";"+If(aRet[nx],"1","2")+CHR(13)+CHR(10)
	Next
EndIf

RestArea(aArea)
Return cPropri
                



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva    ³ Data ³17/11/06  ³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
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
							{ STR0003, 	"A030DLG" , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"A030DLG" , 0 , 3},;	  //"Incluir"
							{ STR0005, 		"A030DLG" , 0 , 4},; //"Alterar"
							{ STR0006, 		"A030DLG" , 0 , 5}} //"Excluir"

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario no aRotina                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA0301" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
		//P_E³ browse da tela de processos                                            ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
		//P_E³               Ex. :  User Function PCOA0301                            ³
		//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA0301", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf

Return(aRotina)
