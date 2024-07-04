#INCLUDE "PCOA035.ch"
#INCLUDE "PROTHEUS.CH"
/*
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOA035  ณ AUTOR ณ Guilherme C. Leal     ณ DATA ณ 26.11.2003 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa para cadastro de processos                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOA035                                                      ณฑฑ
ฑฑณ_DESCRI_  ณ Programa para cadastro de processos, pontos de lancamentos   ณฑฑ
ฑฑณ_DESCRI_  ณ e pontos de bloqueio.                                        ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao podera ser utilizada com a sua chamada normal    ณฑฑ
ฑฑณ          ณ partir do Menu ou a partir de uma funcao pulando assim o     ณฑฑ
ฑฑณ          ณ browse principal e executando a chamada direta da rotina     ณฑฑ
ฑฑณ          ณ selecionada.                                                 ณฑฑ
ฑฑณ          ณ Exemplo: PCOA035(2) - Executa a chamada da funcao de visua-  ณฑฑ
ฑฑณ          ณ                        zacao da rotina.                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_PARAMETR_ณ ExpN1 : Chamada direta sem passar pela mBrowse               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA035DLG   บAutor  ณGuilherme C. Leal   บ Data ณ  11/26/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- บฑฑ
ฑฑบ          ณ zacao                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona botoes do usuario na EnchoiceBar                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock( "PCOA0352" )
	//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//P_Eณ Ponto de entrada utilizado para inclusao de botoes de usuarios         ณ
	//P_Eณ na tela de processos                                                   ณ
	//P_Eณ Parametros : Nenhum                                                    ณ
	//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
	//P_Eณ  Ex. :  User Function PCOA0352                                         ณ
	//P_Eณ         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          ณ
	//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If ValType( aUsButtons := ExecBlock( "PCOA0352", .F., .F. ) ) == "A"
		aButtons := {}
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

DEFINE MSDIALOG oDlg TITLE STR0007 FROM 0,0 TO 480,640 PIXEL //"Cadastro de Bloqueios"
oDlg:lMaximized := .T.

// Carrega dados do AK8 para memoria
RegToMemory("AK8",INCLUI)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Enchoice com os dados do Processo                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oEnchAK8 := MSMGet():New('AK8',,nCallOpcx,,,,,{0,0,(oDlg:nClientHeight/6)-12,(oDlg:nClientWidth/2)},,,,,,oDlg,,,,,,.T.,,,)
oEnchAK8:oBox:Align := CONTROL_ALIGN_TOP

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Folder com Pontos de Bloqueio                                          ณ
//ณ Pontos de Lancamento tem tela especifica                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oFolder  := TFolder():New(oDlg:nHeight/6,0,{/*STR0008,*/STR0009},{''},oDlg,1,,,.T.,,(oDlg:nWidth/2),oDlg:nHeight/3,) //"Pontos de Lan็amento"###"Pontos de Bloqueio"
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Panel para colocar botoes no folder de Pontos de Bloqueio              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

AADD(aButtons, {"NOTE"		,{|| A035Bloqueio(oGdAKA,nCallOpcx) }, STR0015 } )	//"Configura็ใo do Lan็amento de Bloqueio"
AADD(aButtons, {"CADEADO"		,{|| A035Pontos(oGdAKA,nCallOpcx) }, STR0016 } )	//"Configura็ใo dos Bloqueios Ativos"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ GetDados com os Pontos de Lancamento          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nCallOpcx = 3 .Or. nCallOpcx = 4
	nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nGetD := 0
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aHeader do AKA                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeadAKA := GetaHeader("AKA")
nLenAKA  := Len(aHeadAKA) + 1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do aCols do AKA                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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

// Verifica se nใo foi criada nenhuma linha para o aCols
If Len(aColsAKA) = 0
	AAdd(aColsAKA,Array( nLenAKA ))
	nLinAKA++
 
		// Varre o aHeader para preencher o acols
	AEval(aHeadAKA, {|x,y| aColsAKA[nLinAKA][y] := IIf(Upper(AllTrim(x[2])) == "AKA_ITEM", StrZero(1,Len(AKA->AKA_ITEM)),CriaVar(AllTrim(x[2])) ) })

	// Deleted
	aColsAKA[nLinAKA][nLenAKA] := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ GetDados com os Pontos de Bloqueio            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A035Ok   บAutor  ณGuilherme C. Leal   บ Data ณ  11/26/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao do botao OK da enchoice bar, valida e faz o         บฑฑ
ฑฑบ          ณ tratamento adequado das informacoes.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A035Vld  บAutor  ณGuilherme C. Leal   บ Data ณ  11/26/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de validacao dos campos.                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Codigos de 0 a 4999 sao reservados para lancamentos internos,     ณ
//ณ os demais podem ser usados em customizacoes                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If Val(M->AK8_CODIGO) < 900000
	If nCallOpcx = 3
		MsgInfo(STR0011) //"O c๓digo utilizado deve ser maior que 900000."
		Return .F.
	ElseIf nCallOpcx = 4
		If !(MsgYesNo(STR0012)) //"O processo atual ้ padrใo, voc๊ tem certeza que deseja salvar as altera็๕es?"
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA035PontosบAutor  ณGuilherme C. Leal   บ Data ณ  11/26/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a chamada da A060Dlg para edicao dos tipos de bloqueio บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A035Pontos(oGdAKA,nCallOpcx)
Local nPosDesc := AScan(oGdAKA:aHeader,{|x| Upper(AllTrim(x[2])) == "AKA_DESCRI" })
Local lRet     := .F.
Local nLin     := oGdAKA:oBrowse:nAt

If Empty(nLin)
	Return .F.
EndIf

If nLin > Len(oGdAKA:CARGO)
	MsgInfo(STR0013) //"O Registro atual ainda nใo foi salvo. Salve-o antes de editar seus lan็amentos."
	Return .F.
EndIf
If nPosDesc <= 0
	MsgInfo(STR0014) //"O campo 'AKA_DESCRI' nใo estแ habilitado, favor contactar o suporte Microsiga para que o campo seja habilitado."
	Return .F.
EndIf

AKA->(DbGoto(oGdAKA:CARGO[nLin]))
If AKA->(EOF()) .OR. AKA->(BOF())
	Return .F.
EndIf

lRet := PCOA060( If(nCallOpcx == 2 .OR. nCallOpcx == 5, 2,3) )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA035Bloqueio บAutor  ณPaulo Carnelossi บ Data ณ  11/26/03   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a chamada da A050Dlg para edicao dos lancamentos  de   บฑฑ
ฑฑบ          ณ bloqueio                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A035Bloqueio(oGdAKA,nCallOpcx)

Local nPosDesc := AScan(oGdAKA:aHeader,{|x| Upper(AllTrim(x[2])) == "AKA_DESCRI" })
Local lRet     := .F.
Local nLin     := oGdAKA:oBrowse:nAt

If Empty(nLin)
	Return .F.
EndIf

If nLin > Len(oGdAKA:CARGO)
	MsgInfo(STR0013) //"O Registro atual ainda nใo foi salvo. Salve-o antes de editar seus lan็amentos."
	Return .F.
EndIf
If nPosDesc <= 0
	MsgInfo(STR0014) //"O campo 'AKA_DESCRI' nใo estแ habilitado, favor contactar o suporte Microsiga para que o campo seja habilitado."
	Return .F.
EndIf

AKA->(DbGoto(oGdAKA:CARGO[nLin]))
If AKA->(EOF()) .OR. AKA->(BOF())
	Return .F.
EndIf

lRet := PCOA070( If(nCallOpcx == 2 .OR. nCallOpcx == 5, 2,3) )


Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Ana Paula N. Silva    ณ Dataณ17/11/06   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ     
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados         ณฑฑ 
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()
Local aUsRotina := {}
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;    	//"Pesquisar"
							{ STR0003, 		"A035DLG" , 0 , 2},;    	//"Visualizar"
							{ STR0004, 		"A035DLG" , 0 , 3},;	  	//"Incluir"
							{ STR0005, 		"A035DLG" , 0 , 4},; 		//"Alterar"
							{ STR0006, 		"A035DLG" , 0 , 5}} 		//"Excluir"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Adiciona botoes do usuario no aRotina                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PCOA0351" )
		//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ณ
		//P_Eณ browse da tela de processos                                            ณ
		//P_Eณ Parametros : Nenhum                                                    ณ
		//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
		//P_Eณ               Ex. :  User Function PCOA0351                            ณ
		//P_Eณ                      Return {{"Titulo", {|| U_Teste() } }}             ณ
		//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ValType( aUsRotina := ExecBlock( "PCOA0351", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf

Return(aRotina)
