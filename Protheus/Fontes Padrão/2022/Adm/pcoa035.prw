#INCLUDE "PCOA035.ch"
#INCLUDE "PROTHEUS.CH"
/*
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOA035  � AUTOR � Guilherme C. Leal     � DATA � 26.11.2003 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa para cadastro de processos                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOA035                                                      潮�
北砡DESCRI_  � Programa para cadastro de processos, pontos de lancamentos   潮�
北砡DESCRI_  � e pontos de bloqueio.                                        潮�
北砡FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    潮�
北�          � partir do Menu ou a partir de uma funcao pulando assim o     潮�
北�          � browse principal e executando a chamada direta da rotina     潮�
北�          � selecionada.                                                 潮�
北�          � Exemplo: PCOA035(2) - Executa a chamada da funcao de visua-  潮�
北�          �                        zacao da rotina.                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOA035(nCallOpcx)
Private cCadastro	:= STR0001 //"Cadastro de Processos de Sistema"
Private aRotina := MenuDef()

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil
		A035DLG("AK8",AK8->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AK8")
	EndIf
EndIf
	
Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨035DLG   篈utor  矴uilherme C. Leal   � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- 罕�
北�          � zacao                                                      罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function A035DLG(cAlias,nRecnoAK8,nCallOpcx)
Local oDlg
Local lCancel  := .F.
Local aButtons := {}
Local aUsButtons := {}
Local oEnchAK8
Local oFolder

Local oGdAKA
Local aHeadAKA
Local aColsAKA
Local nLenAKA   := 0 // Numero de campos em uso no AKA
Local nLinAKA   := 0 // Linha atual do acols
Local aRecAKA   := {} // Recnos dos registros

Local nGetD

Local oBarAKA
Local oBtnAKA
Local oBtnAKI

Private INCLUI  := (nCallOpcx = 3)

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

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Adiciona botoes do usuario na EnchoiceBar                              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock( "PCOA0352" )
	//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//P_E� Ponto de entrada utilizado para inclusao de botoes de usuarios         �
	//P_E� na tela de processos                                                   �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
	//P_E�  Ex. :  User Function PCOA0352                                         �
	//P_E�         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          �
	//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

	If ValType( aUsButtons := ExecBlock( "PCOA0352", .F., .F. ) ) == "A"
		aButtons := {}
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

DEFINE MSDIALOG oDlg TITLE STR0007 FROM 0,0 TO 480,640 PIXEL //"Cadastro de Bloqueios"
oDlg:lMaximized := .T.

// Carrega dados do AK8 para memoria
RegToMemory("AK8",INCLUI)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Enchoice com os dados do Processo                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oEnchAK8 := MSMGet():New('AK8',,nCallOpcx,,,,,{0,0,(oDlg:nClientHeight/6)-12,(oDlg:nClientWidth/2)},,,,,,oDlg,,,,,,.T.,,,)
oEnchAK8:oBox:Align := CONTROL_ALIGN_TOP

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Folder com Pontos de Bloqueio                                          �
//� Pontos de Lancamento tem tela especifica                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oFolder  := TFolder():New(oDlg:nHeight/6,0,{/*STR0008,*/STR0009},{''},oDlg,1,,,.T.,,(oDlg:nWidth/2),oDlg:nHeight/3,) //"Pontos de Lan鏰mento"###"Pontos de Bloqueio"
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Panel para colocar botoes no folder de Pontos de Bloqueio              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

AADD(aButtons, {"NOTE"		,{|| A035Bloqueio(oGdAKA,nCallOpcx) }, STR0015 } )	//"Configura玢o do Lan鏰mento de Bloqueio"
AADD(aButtons, {"CADEADO"		,{|| A035Pontos(oGdAKA,nCallOpcx) }, STR0016 } )	//"Configura玢o dos Bloqueios Ativos"

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� GetDados com os Pontos de Lancamento          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If nCallOpcx = 3 .Or. nCallOpcx = 4
	nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nGetD := 0
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Montagem do aHeader do AKA                                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
aHeadAKA := GetaHeader("AKA")
nLenAKA  := Len(aHeadAKA) + 1

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Montagem do aCols do AKA                                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
aColsAKA := {}
DbSelectArea("AKA")
DbSetOrder(1)
DbSeek(xFilial()+AK8->AK8_CODIGO)

While nCallOpcx != 3 .And. !Eof() .And. (AKA->AKA_FILIAL + AKA->AKA_PROCES == xFilial() + AK8->AK8_CODIGO)
	AAdd(aColsAKA,Array( nLenAKA ))
	nLinAKA++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAKA, {|x,y| aColsAKA[nLinAKA][y] := IIf(x[10] == "V", CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) ) })

	// Deleted
	aColsAKA[nLinAKA][nLenAKA] := .F.

	// Adiciona o Recno no aRec
	AAdd( aRecAKA, AKA->( Recno() ) )
	
	DbSkip()
EndDo

// Verifica se n鉶 foi criada nenhuma linha para o aCols
If Len(aColsAKA) = 0
	AAdd(aColsAKA,Array( nLenAKA ))
	nLinAKA++
 
		// Varre o aHeader para preencher o acols
	AEval(aHeadAKA, {|x,y| aColsAKA[nLinAKA][y] := IIf(Upper(AllTrim(x[2])) == "AKA_ITEM", StrZero(1,Len(AKA->AKA_ITEM)),CriaVar(AllTrim(x[2])) ) })

	// Deleted
	aColsAKA[nLinAKA][nLenAKA] := .F.
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� GetDados com os Pontos de Bloqueio            �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
oGdAKA:= MsNewGetDados():New(0,0,100,100,nGetd,,,"+AKA_ITEM",,,9999,,,,oFolder:aDialogs[1],aHeadAKA,aColsAKA)
oGdAKA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGdAKA:CARGO := AClone(aRecAKA)

// Quando nao for MDI chama centralizada.
If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(A035Ok(nCallOpcx,oEnchAK8,oGdAKA),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons,,,,, .F. )
Else
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(A035Ok(nCallOpcx,oEnchAK8,oGdAKA),oDlg:End(),) },{|| lCancel := .T., oDlg:End() },,aButtons,,,,, .F. )
EndIf

If lCancel
	RollBackSX8()
EndIf


Return !lCancel

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � A035Ok   篈utor  矴uilherme C. Leal   � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcao do botao OK da enchoice bar, valida e faz o         罕�
北�          � tratamento adequado das informacoes.                       罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A035Ok(nCallOpcx,oEnchAK8,oGdAKA)
Local nI
Local cCampo
If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If !A035Vld(nCallOpcx,oEnchAK8,oGdAKA)
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
	MsUnlock()
	
	// Grava Pontos de Bloqueio
	For nI := 1 To Len(oGdAKA:aCols)
		If oGdAKA:aCols[nI][Len(oGdAKA:aCols[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AKA",.T.)
		EndIf
		
		// Varre o aHeader e grava com base no acols
		AEval(oGdAKA:aHeader,{|x,y| FieldPut(FieldPos(x[2]), oGdAKA:aCols[nI][y] ) })
		
		Replace AKA_FILIAL With xFilial()
		Replace AKA_PROCES With AK8->AK8_CODIGO

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
	MsUnlock()

	// Grava Pontos de Bloqueio
	For nI := 1 To Len(oGdAKA:aCols)
		If nI <= Len(oGdAKA:Cargo) .And. oGdAKA:Cargo[nI] > 0
			AKA->(DbGoto(oGdAKA:Cargo[nI]))
			Reclock("AKA",.F.)
		Else
			If oGdAKA:aCols[nI][Len(oGdAKA:aCols[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AKA",.T.)
			EndIf
		EndIf
	
		If oGdAKA:aCols[nI][Len(oGdAKA:aCols[nI])] // Verifica se a linha esta deletada
			AKA->(DbDelete())
		Else
			// Varre o aHeader e grava com base no acols
			AEval(oGdAKA:aHeader,{|x,y| FieldPut(FieldPos(x[2]), oGdAKA:aCols[nI][y] ) })

			Replace AKA_FILIAL With xFilial()
			Replace AKA_PROCES With AK8->AK8_CODIGO

		EndIf
		MsUnlock()
	Next nI

ElseIf nCallOpcx = 5 // Exclusao
	// Exclui Processo
	Reclock("AK8",.F.)
	AK8->(DbDelete())
	MsUnLock()

	// Exclui Pontos de Bloqueio
	For nI := 1 To Len(oGdAKA:aCols)
		If nI <= Len(oGdAKA:Cargo) .And. oGdAKA:Cargo[nI] > 0
			AKA->(DbGoto(oGdAKA:Cargo[nI]))
			Reclock("AKA",.F.)
			AKA->(DbDelete())
			MsUnLock()
		EndIf		
	Next nI
	AKC->(DbSetOrder(1))

EndIf

If __lSX8
	ConfirmSX8()
EndIf

Return .T.

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � A035Vld  篈utor  矴uilherme C. Leal   � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcao de validacao dos campos.                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A035Vld(nCallOpcx,oEnchAK8,oGdAKA)
Local nI
If (nCallOpcx = 3 .Or. nCallOpcx = 4) .And. !Obrigatorio(oEnchAK8:aGets,oEnchAK8:aTela)
	Return .F.
EndIf

If nCallOpcx = 5   //exclusao

	AKB->(dbSetOrder(1))
	If AKB->(DbSeek(xFilial()+M->AK8_CODIGO))
		Aviso(STR0017, STR0018, {"Ok"})//"Atencao"###"Nao pode ser excluido, pois existem pontos de Lancamentos."
		Return .F.
	EndIf

EndIf		  

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Codigos de 0 a 4999 sao reservados para lancamentos internos,     �
//� os demais podem ser usados em customizacoes                       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

If Val(M->AK8_CODIGO) < 900000
	If nCallOpcx = 3
		MsgInfo(STR0011) //"O c骴igo utilizado deve ser maior que 900000."
		Return .F.
	ElseIf nCallOpcx = 4
		If !(MsgYesNo(STR0012)) //"O processo atual � padr鉶, voc� tem certeza que deseja salvar as altera珲es?"
			Return .F.
		EndIf
	EndIf
EndIf

For nI := 1 To Len(oGdAKA:aCols)
	// Busca por campos obrigatorios que nao estjam preenchidos
	nPosField := AScanx(oGdAKA:aHeader,{|x,y| x[17] .And. Empty(oGdAKA:aCols[nI][y]) })
	If nPosField > 0
		SX2->(dbSetOrder(1))
		SX2->(MsSeek("AKD"))
		HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+ STR0019 + AllTrim(oGdAKA:aHeader[nPosField][1]) + STR0020 +Str(nI,3,0),3,1) //"Campo: "###"Linha: "
		Return .F.
	EndIf
Next nI

Return .T.
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨035Pontos篈utor  矴uilherme C. Leal   � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Faz a chamada da A060Dlg para edicao dos tipos de bloqueio 罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A035Pontos(oGdAKA,nCallOpcx)
Local nPosDesc := AScan(oGdAKA:aHeader,{|x| Upper(AllTrim(x[2])) == "AKA_DESCRI" })
Local lRet     := .F.
Local nLin     := oGdAKA:oBrowse:nAt

If Empty(nLin)
	Return .F.
EndIf

If nLin > Len(oGdAKA:CARGO)
	MsgInfo(STR0013) //"O Registro atual ainda n鉶 foi salvo. Salve-o antes de editar seus lan鏰mentos."
	Return .F.
EndIf
If nPosDesc <= 0
	MsgInfo(STR0014) //"O campo 'AKA_DESCRI' n鉶 est� habilitado, favor contactar o suporte Microsiga para que o campo seja habilitado."
	Return .F.
EndIf

AKA->(DbGoto(oGdAKA:CARGO[nLin]))
If AKA->(EOF()) .OR. AKA->(BOF())
	Return .F.
EndIf

lRet := PCOA060( If(nCallOpcx == 2 .OR. nCallOpcx == 5, 2,3) )

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯屯退屯屯屯脱屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨035Bloqueio 篈utor  砅aulo Carnelossi � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯屯褪屯屯屯拖屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Faz a chamada da A050Dlg para edicao dos lancamentos  de   罕�
北�          � bloqueio                                                   罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A035Bloqueio(oGdAKA,nCallOpcx)

Local nPosDesc := AScan(oGdAKA:aHeader,{|x| Upper(AllTrim(x[2])) == "AKA_DESCRI" })
Local lRet     := .F.
Local nLin     := oGdAKA:oBrowse:nAt

If Empty(nLin)
	Return .F.
EndIf

If nLin > Len(oGdAKA:CARGO)
	MsgInfo(STR0013) //"O Registro atual ainda n鉶 foi salvo. Salve-o antes de editar seus lan鏰mentos."
	Return .F.
EndIf
If nPosDesc <= 0
	MsgInfo(STR0014) //"O campo 'AKA_DESCRI' n鉶 est� habilitado, favor contactar o suporte Microsiga para que o campo seja habilitado."
	Return .F.
EndIf

AKA->(DbGoto(oGdAKA:CARGO[nLin]))
If AKA->(EOF()) .OR. AKA->(BOF())
	Return .F.
EndIf

lRet := PCOA070( If(nCallOpcx == 2 .OR. nCallOpcx == 5, 2,3) )


Return lRet


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Ana Paula N. Silva    � Data�17/11/06   潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�     
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados         潮� 
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Static Function MenuDef()
Local aUsRotina := {}
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;    	//"Pesquisar"
							{ STR0003, 		"A035DLG" , 0 , 2},;    	//"Visualizar"
							{ STR0004, 		"A035DLG" , 0 , 3},;	  	//"Incluir"
							{ STR0005, 		"A035DLG" , 0 , 4},; 		//"Alterar"
							{ STR0006, 		"A035DLG" , 0 , 5}} 		//"Excluir"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario no aRotina                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ExistBlock( "PCOA0351" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de processos                                            �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA0351                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If ValType( aUsRotina := ExecBlock( "PCOA0351", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf

Return(aRotina)
