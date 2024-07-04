#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA109.CH"
#DEFINE PULALINHA CHR(13)+CHR(10)  

Function PCPA109()
	Local oDlgUpd
	Local aCoors   := FWGetDialogSize( oMainWnd )	
	Local nLargura := aCoors[4]
	Local nHeight  := aCoors[3]
	Local lIntgSFC := Iif(SuperGetMV("MV_INTSFC",.F.,0)==1,.T.,.F.)
	Local aDesTab := {}
	Local aSubTab := {}
	Local nI
	Local nX

	Private aTabsFil := {}
			
	//Lista de folders com filtros que aparecerão... Para adicionar, basta colocar mais uma posição no array. NENHUMA OUTRA ALTERAÇÃO NECESSARIA
	aAdd(aTabsFil, {"SB1",STR0032,{}}) //"Produto"
	aAdd(aTabsFil, {"NNR",STR0033,{}}) //"Local de Estoque"
	If !lIntgSFC
		aAdd(aTabsFil, {"SH1",STR0034,{}}) //"Recurso"
		aAdd(aTabsFil, {"SH4",STR0080,{}}) //"Ferramenta"
	Else
		aAdd(aTabsFil, {"CYB", STR0050,{}}) //"Máquina"
	EndIf
	aAdd(aTabsFil, {"SC2",STR0035,{}}) //"Ordem de Produção"
	aAdd(aTabsFil, {"SG2",STR0049,{}}) //"Roteiros"
	aAdd(aTabsFil, {"SG1",STR0048,{}}) //"Estrutura"
	aAdd(aTabsFil, {"SBE",STR0051,{}}) //"Endereço"
	
	If lIntgSFC
		aAdd(aTabsFil, {"CYH", STR0034,{}}) //Recurso
	EndIf 
	
	aAdd(aTabsFil, {"SF5",STR0065,{}}) //"Movimentos e transferência"
	aAdd(aTabsFil, {"SB2",STR0070,{"SB8","SBF"}}) // "Saldo estoque"
	
	If SOE->(ColumnPos("OE_MEMO1"))
		aAdd(aTabsFil, {"SEGURANCA","Segurança",{}}) //"Segurança"
	EndIf

	validTabs(@aDesTab)
	GeraReg()

	DEFINE DIALOG oDlgUpd TITLE STR0001 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL //"Parâmetros de integração Pc-Factory"
	
	dbSelectArea("SOD")
	SOD->(dbSeek(xFilial("SOD")))
		
	//----------------
	//Painel principal
	//----------------
	oScroll := TScrollArea():New(oDlgUpd,01,01,100,100)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT
	
	nHeight := (nHeight/2) - 30
	If nHeight < 285
		nHeight := 285
	EndIf
	
	oPanelSup := TPanel():New( 01, 01, ,oDlgUpd, , , , , , nLargura/2, nHeight, .F.,.F. )
	oScroll:SetFrame( oPanelSup ) 
	
	//Combo indica se integração esta ativa
	@ 07,05 SAY oAcao VAR GetTitulo("OD_ATIVO")+":" OF oPanelSup PIXEL 	
	aAtivo := {'1='+STR0002,'2='+STR0003} //"Ativo" "Não Ativo"
	cAtivo := SOD->OD_ATIVO
  	oAtivo := TComboBox():New(06,34,{|u|if(PCount()>0,cAtivo:=u,cAtivo)},aAtivo,90,10,oPanelSup,,{||},,,,.T.,,,,,,,,,'cAtivo')
	
	//Caminho para requisição de integração
	@ 20,05 SAY oAcao VAR GetTitulo("OD_CAMINHO")+":" OF oPanelSup PIXEL 
	cCaminho := SOD->OD_CAMINHO
	@ 18,34 MSGET cCaminho SIZE 320,10 OF oPanelSup PIXEL 
	@ 18,359 BUTTON oBtnTes PROMPT STR0004 SIZE 60,12 ACTION (TestLink()) OF oPanelSup PIXEL //"Diagnosticar"

	//Combo indica se gera xml com log da integração
	@ 33,05 SAY oAcao VAR GetTitulo("OD_GERAXML")+":" OF oPanelSup PIXEL
	aGeraXML := {'1='+STR0006,'2='+STR0007}
	cGeraXML := SOD->OD_GERAXML
	//AtiEnvPen(cGeraXML,oEnviados,oPendencia)
  	oGeraXML := TComboBox():New(32,34,{|u|if(PCount()>0,cGeraXML:=u,cGeraXML)},aGeraXML,90,10,oPanelSup,,{|| .T.},,,,.T.,,,,,,,,,'cGeraXML')

	//Enviados
	@ 46,05 SAY oAcao VAR GetTitulo("OD_DIRENV")+":" OF oPanelSup PIXEL
	cEnviados := SOD->OD_DIRENV
	oEnviados := TGet():New( 44,34,{|u| if( PCount() > 0, cEnviados := u, cEnviados ) },oPanelSup,320,10,"@!",,0,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F.,,cEnviados ,,,, )
	@ 44,359 BUTTON oBtnEnv PROMPT STR0005 SIZE 60,12 ACTION (cTemp := SelectFile("diretorio.xml"), If(Empty(cTemp),Nil,cEnviados := cTemp)) OF oPanelSup PIXEL//"Escolher Pasta" 
	
	//Pendência
	@ 60,05 SAY oAcao VAR GetTitulo("OD_DIRPEND")+":" OF oPanelSup PIXEL
	cPendencia := SOD->OD_DIRPEND
	oPendencia := TGet():New( 58,34,{|u| if( PCount() > 0, cPendencia := u, cPendencia ) },oPanelSup,320,10,"@!",,0,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F.,,cPendencia,,,, )
	@ 58,359 BUTTON oBtnPen PROMPT STR0005 SIZE 60,12 ACTION (cTemp := SelectFile("diretorio.xml"), If(Empty(cTemp),Nil,cPendencia := cTemp)) OF oPanelSup PIXEL//"Escolher Pasta"

	oTFolder := TFolder():New( 85,1,aDesTab,,oPanelSup,,,,.T.,,(nLargura/2) - 5, 200 )

	aObjFil := {}

	For nI := 1 To Len(aTabsFil)
		aAdd(aObjFil,PCPA109F():New(aTabsFil[nI][1],oTFolder:aDialogs[nI]))
	Next

	For nI := 1 To Len(aObjFil)
		CarFiltro(aObjFil[nI])
		For nX := 1 To Len(aObjFil[nI]:aSubFolder)
			CarFiltro(aObjFil[nI]:aSubFolder[nX])
		Next nX
	Next nI

	bConfClk := {|| If(PCPA109POS(oDlgUpd),oDlgUpd:End(),Nil)}
	bCancClk := {|| oDlgUpd:End()}

	ACTIVATE MSDIALOG oDlgUpd On Init EnchoiceBar(oDlgUpd,bConfClk,bCancClk) CENTERED

Return Nil
//-------------------------------------------------------------------
Static Function validTabs(aTabelas)
	Local nI

	dbSelectArea("SX2")
	SX2->(dbSetOrder(1))

    For nI := 1 To Len(aTabsFil)
    	
    	If aTabsFil[nI][1] == "SEGURANCA" .Or. SX2->(dbSeek(aTabsFil[nI][1]))
    		aAdd(aTabelas,aTabsFil[nI][2])
    	Else
			aDel(aTabsFil,nI)
			aSize(aTabsFil,Len(aTabsFil)-1)
    	EndIf

    Next

Return Nil
//-------------------------------------------------------------------
Static Function WSTest()

	//Instancia o WS Client do PPI
	oWsPPI := WSPCFactory():New()
   
	//Carrega os parâmetros do WS 
	aRetPar := oWsPPI:getLinks(AllTrim(cCaminho))
	If aRetPar[1]
		MSGINFO(STR0066 ,STR0067) //"Conexão com o WebService realizada com Sucesso!" / "Sucesso"
	Else
		alert(aRetPar[2])
	EndIf

Return Nil
//-------------------------------------------------------------------
Static Function TestLink()

	If Findfunction("DGMES")
		DGMES()
	Else	
		MsgRun(STR0068 ,STR0069,{|| WSTest() }) //"Conectando ao link informado..." //"Aguarde"
	EndIf

Return Nil
//-------------------------------------------------------------------
Static Function GetTitulo(cCampo)
	Local cTitulo := ""

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	
	If SX3->(dbSeek(cCampo))
		cTitulo := AllTrim(X3Titulo())
	EndIf

Return cTitulo
//-------------------------------------------------------------------
Static Function ArrTokStr(aArray,cGlue)
	Local cString := ""
	Local nI

	For nI := 1 To (Len(aArray)-1)
		cString := cString + aArray[nI] + cGlue
	Next

	cString := cString + aArray[Len(aArray)]
Return cString
//-------------------------------------------------------------------
//Select File - Seleciona Arquivo
//-------------------------------------------------------------------
Static Function SelectFile(cFormatFile) 
	cFile := cGetFile("|" + cFormatFile + "|",STR0013,0,,.F.,512,.T.,.T.)//"Selecione uma pasta para gravar o arquivo"

	aChave := StrTokArr(cFile,"\")
	If Len(aChave) > 1
		aDel(aChave,Len(aChave))
		aSize(aChave,Len(aChave)-1)
		cFile := ArrTokStr(aChave,"\") + "\"
	EndIf
Return cFile
//----------------------------------------------
Static Function CarFiltro(oFiltro)
	dbSelectArea("SOE")
	SOE->(dbSeek(xFilial("SOE")+oFiltro:cTabela))
	oFiltro:SetValue(SOE->OE_FILTRO)

	If AllTrim(oFiltro:cTabela) == "SB2"
		If Empty(SOE->OE_PARINTG)
			oFiltro:nParTab := .T.
		Else
			oFiltro:nParTab := Iif(AllTrim(SOE->OE_PARINTG)=="1",.T.,.F.)
		EndIf
	Else
		oFiltro:nParTab := Iif(!Empty(SOE->OE_PARINTG),Val(SOE->OE_PARINTG),Nil)
		If AllTrim(oFiltro:cTabela) == "SC2" .And. (Empty(oFiltro:nParTab) .Or. oFiltro:nParTab == Nil)
			oFiltro:nParTab := 1
		EndIf
	EndIf	
	If !Empty(SOE->OE_VAR1)
		If AllTrim(oFiltro:cTabela) == "SC2"
			oFiltro:cVar1 := Val(SOE->OE_VAR1)
		ElseIf AllTrim(oFiltro:cTabela) == "SB2"
			oFiltro:cVar1 := Iif(AllTrim(SOE->OE_VAR1)=="1",.T.,.F.)
		Else
			oFiltro:cVar1 := SOE->OE_VAR1
		EndIf
	EndIf
	If !Empty(SOE->OE_VAR2)
		If AllTrim(oFiltro:cTabela) $ "SB2|SC2"
			oFiltro:cVar2 := Iif(AllTrim(SOE->OE_VAR2)=="1",.T.,.F.)
		Else
			oFiltro:cVar2 := SOE->OE_VAR2
		EndIf
	EndIf
	If !Empty(SOE->OE_VAR3)
		If AllTrim(oFiltro:cTabela) == "SB2"
			oFiltro:cVar3 := Iif(AllTrim(SOE->OE_VAR3)=="1",.T.,.F.)
		Else
			oFiltro:cVar3 := SOE->OE_VAR3
		EndIf
	EndIf

	If SOE->(ColumnPos("OE_VAR4")) .And. !Empty(SOE->OE_VAR4)
		If AllTrim(oFiltro:cTabela) == "SC2"
			oFiltro:cVar4 := Iif(AllTrim(SOE->OE_VAR4)=="1",.T.,.F.)
		Else
			oFiltro:cVar4 := SOE->OE_VAR4
		EndIf
	EndIf

	If AllTrim(SOE->OE_TABELA) == "SEGURANCA"
		If SOE->(ColumnPos("OE_MEMO1"))
			oFiltro:cChar1 := PadR(SOE->OE_CHAR1,100)
			oFiltro:cMemo1 := PadR(SOE->OE_MEMO1,1000)
		EndIf
	EndIf

Return Nil
//----------------------------------------------
Static Function GeraRegSOE(cTabela)

	dbSelectArea("SOE")
	If !SOE->(dbSeek(xFilial("SOE")+cTabela))
		RecLock('SOE',.T.)

		SOE->OE_FILIAL  := xFilial('SOE')
		SOE->OE_TABELA  := cTabela
		If AllTrim(cTabela) == "SB2"
			SOE->OE_PARINTG := "0"
		ElseIf AllTrim(cTabela) == "SC2"
			SOE->OE_PARINTG := "1"
		EndIf
		
		If cTabela == "SB2"
			SOE->OE_VAR1 := "0"
			SOE->OE_VAR2 := "0"
			SOE->OE_VAR3 := "0"
		EndIf
		If cTabela == "SC2"
			SOE->OE_VAR1 := "1"
			SOE->OE_VAR2 := "0"
		EndIf
		MsUnLock()
	EndIf

Return Nil
//----------------------------------------------
Static Function GeraReg()
	Local nI
	Local nX
	dbSelectArea("SOD")
	If !SOD->(dbSeek(xFilial("SOD")))
		RecLock('SOD',.T.)
		
		SOD->OD_FILIAL  := xFilial('SOD')
		SOD->OD_ATIVO   := "2"
		SOD->OD_GERAXML := "2"
		
		MsUnLock()
	EndIf
	
	For nI := 1 To Len(aTabsFil)
		GeraRegSOE(aTabsFil[nI][1])
		For nX := 1 To Len(aTabsFil[nI][3])
			GeraRegSOE(aTabsFil[nI][3][nX])
		Next nX 
	Next
	
Return Nil
//----------------------------------------------
Static Function GravaFiltro(oFiltro)

	dbSelectArea("SOE")
	SOE->(dbSeek(xFilial("SOE")+oFiltro:cTabela))
	
	RecLock('SOE',.F.)
	SOE->OE_FILTRO  := oFiltro:cFiltro
	If ValType(oFiltro:nParTab) == "N"
		SOE->OE_PARINTG := Iif(!Empty(oFiltro:nParTab),cValToChar(oFiltro:nParTab),"")
	ElseIf ValType(oFiltro:nParTab) == "L"
		SOE->OE_PARINTG := Iif(oFiltro:nParTab,"1","0")
	Else
		SOE->OE_PARINTG := Iif(!Empty(oFiltro:nParTab),oFiltro:nParTab,"")
	EndIf
	If ValType(oFiltro:cVar1) == "L"
		SOE->OE_VAR1 := Iif(oFiltro:cVar1,"1","0")
	Else
		If !Empty(oFiltro:cVar1)
			If ValType(oFiltro:cVar1) == "C"
				SOE->OE_VAR1 := oFiltro:cVar1
			Else
				SOE->OE_VAR1 := cValToChar(oFiltro:cVar1)
			EndIf
		Else
			SOE->OE_VAR1 := " "
		EndIf
	EndIf
	
	If ValType(oFiltro:cVar2) == "L"
		SOE->OE_VAR2 := Iif(oFiltro:cVar2,"1","0")
	Else
		If !Empty(oFiltro:cVar2)
			If ValType(oFiltro:cVar2) == "C"
				SOE->OE_VAR2 := oFiltro:cVar2
			Else
				SOE->OE_VAR2 := cValToChar(oFiltro:cVar2)
			EndIf
		Else
			SOE->OE_VAR2 := " "
		EndIf
	EndIf
	If ValType(oFiltro:cVar3) == "L"
		SOE->OE_VAR3 := Iif(oFiltro:cVar3,"1","0")
	Else
		If !Empty(oFiltro:cVar3)
			If ValType(oFiltro:cVar3) == "C"
				SOE->OE_VAR3 := oFiltro:cVar3
			Else
				SOE->OE_VAR3 := cValToChar(oFiltro:cVar3)
			EndIf
		Else
			SOE->OE_VAR3 := " "
		EndIf
	EndIf

	If AllTrim(oFiltro:cTabela) == "SEGURANCA"
		If SOE->(ColumnPos("OE_CHAR1"))
			SOE->OE_CHAR1 := oFiltro:cChar1
			SOE->OE_MEMO1 := oFiltro:cMemo1
		EndIf
	EndIf

	If AllTrim(oFiltro:cTabela) == "SC2"
		If ValType(oFiltro:cVar4) == "L"
			If SOE->(ColumnPos("OE_VAR4"))
				SOE->OE_VAR4 := Iif(oFiltro:cVar4,"1","0")
			EndIf
		Endif
	EndIf
	
	If AllTrim(oFiltro:cTabela) == "SF5"
		If SOE->(ColumnPos("OE_VAR4"))
			SOE->OE_VAR4 := oFiltro:cVar4
		EndIf
	EndIf

	MsUnLock()

Return Nil
//----------------------------------------------
Function PCPA109POS()
	Local lRet := .T.
	Local nI   := 0
	Local nX   := 0

	If AllTrim(cGeraXML) == "1"
		If (Empty(cEnviados) .Or. Empty(cPendencia))
			Help( ,, 'Help',, STR0092, 1, 0 ) //"Quando parametrizado para gerar XML, é necessário informar os caminhos para geração dos XML's."
			Return .F.
		EndIf
		If !ExistDir( cEnviados )
			Help( ,, 'Help',, STR0093, 1, 0 ) //"Diretório parametrizado para os XML's enviados é inválido."
			Return .F.
		EndIf
		If !ExistDir( cPendencia )
			Help( ,, 'Help',, STR0094, 1, 0 ) //"Diretório parametrizado para os XML's pendentes é inválido."
			Return .F.
		EndIf
	EndIf

	//Grava Informações gerais
	dbSelectArea("SOD")
	SOD->(dbSeek(xFilial("SOD")))
		
	RecLock("SOD",.F.)
	
	SOD->OD_ATIVO   := cAtivo
	SOD->OD_CAMINHO := cCaminho
	SOD->OD_GERAXML := cGeraXML
	SOD->OD_DIRENV  := cEnviados
	SOD->OD_DIRPEND := cPendencia
	 
	MsUnLock()
	
	//Grava Informações das tabelas
	For nI := 1 To Len(aObjFil)
		GravaFiltro(aObjFil[nI])
		For nX := 1 To Len(aObjFil[nI]:aSubFolder)
			GravaFiltro(aObjFil[nI]:aSubFolder[nX])
		Next nX
	Next nI

Return lRet
//----------------------------------------------
Static Function AtiEnvPen(cVal,oEnviados,oPendencia)

	If cVal == "1"
		oEnviados:bWhen  := {|| .T.}
		oPendencia:bWhen := {|| .T.}
	Else
		oEnviados:bWhen  := {|| .F.}
		oPendencia:bWhen := {|| .F.}
	EndIf

Return .T.
//----------------------------------------------
Static Function PrintVar(xVar,nNivel)
	Local nI
	Default nNivel := 0

	If nNivel == 0
		//conout(" ")
		//conout("[PrintVar]")
	EndIf 

	If ValType(xVar) == "A"
		//conout(Space(nNivel*2)+"array(")
		For nI := 1 To Len(xVar)
			PrintVar(xVar[nI],nNivel+1)
		Next
		//conout(Space(nNivel*2)+")")
	Else
		If ValType(xVar) == "N"
			xVar := AllTrim(Str(xVar))
			//conout(Space(nNivel*2)+xVar)
		ElseIf ValType(xVar) == "U"
			//conout(Space(nNivel*2)+"Nil")
		ElseIf ValType(xVar) == "L"
			If xVar
				//conout(Space(nNivel*2)+".T.")
			Else
				//conout(Space(nNivel*2)+".F.")
			EndIf
		Else
			//conout(Space(nNivel*2)+"'"+xVar+"'")
		EndIf
	EndIf
Return .T.
//---------------------------------------------------------
Function IsNumDot(cString)
	Local nI
	Local cChar := ""
	
	If Len(cString) == 0
		Return .F.
	EndIf

	For nI := 1 To Len(cString)
		cChar := SubStr(cString,nI,1)
		If !IsDigit( cChar ) .And. cChar != "."
			//conout(cChar)
			Return .F.
		EndIf
	Next

Return .T.

//---------------------------------------------------------
// Validação do tipo de movimento (SF5)
//---------------------------------------------------------
Static Function vldTpMvto(cTipo,cCod)
	Local lRet := .T.
	Local aAreaSF5 := SF5->(GetArea())
	If !Empty(cCod)
		dbSelectArea("SF5")
		SF5->(dbSetOrder(1))
		If SF5->(dbSeek(xFilial("SF5")+cCod))
			If cTipo == "EP" .Or. cTipo == "C" .Or. cTipo == "EE"
				If cCod > "500"
					Help( ,, 'Help',, STR0064, 1, 0 ) //"Tipo de movimento inválido. Para movimento de entrada, utilize os tipos de movimento de '0' até '500'."
					lRet := .F.
				Else
					If SF5->F5_TIPO != "P" .And. cTipo == "EP"
						Help( ,, 'Help',, STR0087, 1, 0 ) //"Tipo de movimento inválido. Para movimento de entrada, deve ser utilizado movimentação do tipo 'Produção'."
						lRet := .F.
					ElseIf SF5->F5_TIPO != "D" .And. cTipo == "C"
						Help( ,, 'Help',, STR0088, 1, 0 ) //"Tipo de movimento inválido. Para movimento de co-produto, deve ser utilizado movimentação do tipo 'Devolução'."
						lRet := .F.
					ElseIf cTipo == "C" .And. SF5->F5_ATUEMP != "S"
						Help( ,, 'Help',, STR0089, 1, 0 ) // "Tipo de movimento inválido. Para movimento de co-produto, deve ser utilizado movimentação com atualização de empenho."
						lRet := .F.
					ElseIf SF5->F5_TIPO != "D" .And. cTipo == "EE"
						Help( ,, 'Help',, STR0101, 1, 0 ) //"Tipo de movimento inválido. Para movimento de entrada Estoque, deve ser utilizado movimentação do tipo 'Devolução'."
						lRet := .F.
					EndIf
				EndIf
			Else
				If cCod < "501"
					Help( ,, 'Help',, STR0063, 1, 0 ) //"Tipo de movimento inválido. Para movimento de saída, utilize os tipos de movimento de '501' até '999'."
					lRet := .F.
				EndIf
			EndIf
			If SF5->F5_VAL == "S"
				Help( ,, 'Help',, STR0078, 1, 0 ) //"Tipo de movimento não pode ser Valorizado."
				lRet := .F.
			EndIf	
		Else
			Help( ,, 'Help',, STR0062, 1, 0 ) //"Tipo de movimento não cadastrado."
			lRet := .F.
		EndIf
	EndIf
	SF5->(RestArea(aAreaSF5))
Return lRet

//---------------------------------------------------------
// Classe construtura de filtro paras tabelas
//---------------------------------------------------------
Class PCPA109F
	//Método construtor da classe
	Method New(cTabela,oDlg,lSinc) Constructor

	//Propriedades
	Data cTabela 
	Data cCampos
	Data aCampos
	Data cOperadores
	Data aOperadores
	Data cExpressao
	Data cFiltro
	Data nParAberto
	Data cLastEvent
	Data nParTab
	Data cVar1
	Data cVar2
	Data cVar3
	Data cVar4
	Data cChar1
	Data cMemo1
	Data aSubFolder
	Data lExec

	//Métodos
	Method vAdicionar()
	Method Adicionar()
	Method Limpar()
	Method vAbrePar()
	Method vFechaPar()
	Method vAndOr()
	Method AbrePar()
	Method FechaPar()
	Method And()
	Method Or()
	Method SetValue(cString)
	Method PosValid()
	Method BusStruct(cTabela)
	Method FiltroPadr(cTabela, oDlg, lSinc)
EndClass
//---------------------------------------------------------
// Método construtor
//---------------------------------------------------------
Method New(cTabela,oDlg,lSinc) Class PCPA109F
	Local oGroup
	Local aItens := {STR0052, STR0053, STR0054} //"Não integra"|"Gera pendência"|"Integra"
	Local cMsg := ""
	Local oFolderB2
	Local aFolderB2 := {STR0071,STR0072,STR0073} //"Estoque" / "Lote" / "Endereço"
	Local oCheck1, oCheck2, oCheck3, oCheck4
	Local nTam := 0
	
	Default lSinc := .F.
	
	Self:cTabela := cTabela
	Self:Limpar()
	Self:aSubFolder := {}
	
	If cTabela == "SF5"
		Self:cVar1 := Space(TamSX3("F5_CODIGO")[1])
		Self:cVar2 := Space(TamSX3("F5_CODIGO")[1])
		Self:cVar3 := Space(TamSX3("F5_CODIGO")[1])
		Self:cVar4 := Space(TamSX3("F5_CODIGO")[1])
		
		If oDlg != Nil
			@ 05,05 SAY oAcao VAR STR0056 OF oDlg PIXEL //"Tipo de movimento de entrada:"
			@ 03,105 MSGET Self:cVar1 SIZE 30,10 OF oDlg PIXEL Picture "@!" F3 "SF5" Valid vldTpMvto("EP",Self:cVar1)
			
			@ 20,05 SAY oAcao VAR STR0055 OF oDlg PIXEL //"Tipo de movimento de saída:"
			@ 17,105 MSGET Self:cVar2 SIZE 30,10 OF oDlg PIXEL Picture "@!" F3 "SF5" Valid vldTpMvto("S",Self:cVar2)
			
			@ 35,05 SAY oAcao VAR STR0086 OF oDlg PIXEL //"Tipo de movimento Co-Produto:"
			@ 31,105 MSGET Self:cVar3 SIZE 30,10 OF oDlg PIXEL Picture "@!" F3 "SF5" Valid vldTpMvto("C",Self:cVar3)
			If SOE->(ColumnPos("OE_VAR4"))
				@ 50,05 SAY oAcao VAR STR0100 OF oDlg PIXEL //"Tipo de movimento de entrada Estoque:"
				@ 46,105 MSGET Self:cVar4 SIZE 30,10 OF oDlg PIXEL Picture "@!" F3 "SF5" Valid vldTpMvto("EE",Self:cVar4)
			EndIf
		EndIf
		
	ElseIf cTabela == "SB2"
		If lSinc
			nTam := 190
		Else
			nTam := 180
		EndIf
		If oDlg == Nil
			Self:FiltroPadr("SB2", Nil, lSinc)
			
			aAdd(Self:aSubFolder,PCPA109F():New("SB8", Nil,lSinc))
			aAdd(Self:aSubFolder,PCPA109F():New("SBF", Nil,lSinc))
			Self:cVar1 := .T.
			Self:cVar2 := .T.
			Self:nParTab := .T.
			Self:cVar3 := .T.
		Else
			oFolderB2 := TFolder():New( 0,0,aFolderB2,,oDlg,,,,.F.,,260,nTam)
			Self:FiltroPadr("SB2", oFolderB2:aDialogs[1], lSinc)
			
			aAdd(Self:aSubFolder,PCPA109F():New("SB8",oFolderB2:aDialogs[2],lSinc))
			aAdd(Self:aSubFolder,PCPA109F():New("SBF",oFolderB2:aDialogs[3],lSinc))
			oGroup  := TGroup():New(08,265,60,368,STR0074,oDlg,,,.T.) //"Movimentação"
			
			Self:cVar1 := .T.
			oCheck1 := TCheckBox():New(19,268,STR0075,,oGroup,80,,,,,,,,) //'Nota fiscal de entrada'
			oCheck1:bSetGet := {|| Self:cVar1}
			oCheck1:bLClicked := {|| Self:cVar1:=!Self:cVar1}
			
			Self:cVar2 := .T.
			oCheck2 := TCheckBox():New(29,268,STR0076,,oGroup,80,,,,,,,,) //'Nota fiscal de venda'
			oCheck2:bSetGet := {|| Self:cVar2}
			oCheck2:bLClicked := {|| Self:cVar2:=!Self:cVar2}
			
			Self:nParTab := .T.
			oCheck3 := TCheckBox():New(39,268,STR0077,,oGroup,80,,,,,,,,) //'Movimentações internas'
			oCheck3:bSetGet := {|| Self:nParTab}
			oCheck3:bLClicked := {|| Self:nParTab:=!Self:nParTab}
			
			Self:cVar3 := .T.
			oCheck4 := TCheckBox():New(49,268,STR0079,,oGroup,80,,,,,,,,) //'Implantação de saldo'
			oCheck4:bSetGet := {|| Self:cVar3}
			oCheck4:bLClicked := {|| Self:cVar3:=!Self:cVar3}
		EndIf
		
	ElseIf cTabela == "SEGURANCA"
		Self:cChar1 := Space(254)
		Self:cMemo1 := Space(1000)
		
		If oDlg != Nil
			@ 05,05 SAY oAcao VAR STR0098 OF oDlg PIXEL //"Usuário:"
			@ 03,30 MSGET Self:cChar1 SIZE 100,10 OF oDlg PIXEL
			
			@ 20,05 SAY oAcao VAR STR0099 OF oDlg PIXEL //"Senha:"
			@ 17,30 MSGET Self:cMemo1 SIZE 100,10 OF oDlg PIXEL PASSWORD
		EndIf
	Else
		Self:FiltroPadr(cTabela, oDlg, lSinc)
		
		//Se for a tabela SC2, adiciona as informações do parâmetro de integração com o MRP.
		If AllTrim(cTabela) == "SC2" .And. FunName() == "PCPA109"
			cMsg := STR0037 //"1 - Não integra. O MRP não irá fazer nenhum processo. As ordens não serão enviadas, na inclusão e exclusão."
			cMsg += PULALINHA+STR0038 //"  Poderá ser usada a rotina de sincronização - PCPA111 para enviar posteriormente as ordens geradas pelo MRP."
			cMsg += PULALINHA+STR0039 //"  Nessa situação, não terá como integrar as ordens que foram excluídas pelo MRP."
			cMsg += PULALINHA+STR0040 //"2 - Gera pendência. O MRP irá fazer a integração, porém não será de forma on-line."
			cMsg += PULALINHA+STR0041 //"  Serão registradas pendências de integração para que sejam processadas posteriormente"
			cMsg += PULALINHA+STR0042 //"  pela rotina de gerenciamento de pendência - PCPA110."
			cMsg += PULALINHA+STR0043 //"  Serão registradas pendências das ordens criadas e excluídas."
			cMsg += PULALINHA+STR0044 //"3 - Integra. O MRP irá fazer integração no momento da criação ou exclusão da OP. "
			cMsg += PULALINHA+STR0045 //"  Deverá enviar ao WebService, porém não poderá emitir mensagem de retorno. "
			cMsg += PULALINHA+STR0046 //"  Toda e qualquer situação deverá gerar pendência."
	
			oGroup := TGroup():New(10,250,50,350,STR0047/*'MRP'*/,oDlg,,,.T.)
			oRadio := TRadMenu():New(18,255,aItens,,oGroup,,,,,cMsg,,,70,12,,,,.T.)
			oRadio:bSetGet := {|u|Iif (PCount()==0,Self:nParTab,Self:nParTab:=u)}
	      
			aItens := {STR0059, STR0058, STR0102 } //"BackFlush" "Consumo Real" 'Consumo Real/Atu Empe'
	      
			cMsg := STR0060 //"BackFlush: Sempre irá realizar a baixa dos componentes conforme o definido na engenharia."
			cMsg += PULALINHA+STR0061 //"Consumo Real: Irá consumir conforme a lista de componentes que foi recebida."
			cMsg += PULALINHA+STR0103 //"Atu Empe: Irá consumir conforme a lista de componentes que foi recebida e se a quantidade a ser "
			cMsg += PULALINHA+STR0104 //" requisitada for maior que o saldo empenhado será ajustada automaticamente a quantidade do empenho. "
	      
			Self:cVar1 := 1
	      
			oGroup  := TGroup():New(55,250,95,350,STR0057,oDlg,,,.T.) //'Consumo de componentes'
			oRadio2 := TRadMenu():New(63,255,aItens,,oGroup,,,,,cMsg,,,70,20,,,,.T.)
			oRadio2:bSetGet := {|u|Iif (PCount()==0,Self:cVar1,Self:cVar1:=u)}
	      
			cMsg := STR0083 //"Indica se o filtro definido no folder 'Roteiros' deverá ser considerado na geração das operações da ordem de produção."
	      
			oGroup  := TGroup():New(100,250,120,350,STR0084,oDlg,,,.T.) //"Operações"
	      
			Self:cVar2 := .F.
			oCheck1 := TCheckBox():New(110,265,STR0085,,oGroup,80,,,,,,,,,,cMsg) //"Filtra operações?"
			oCheck1:bSetGet := {|| Self:cVar2}
			oCheck1:bLClicked := {|| Self:cVar2:=!Self:cVar2}
	      
			oGroup  := TGroup():New(125,250,150,350,STR0090,oDlg,,,.T.) //"Refugo"
			Self:cVar3 := Space(TamSX3("NNR_CODIGO")[1])
			@ 137,262 SAY oAcao VAR STR0091 OF oDlg PIXEL //"Local:"
			@ 135,280 MSGET Self:cVar3 SIZE 30,10 OF oDlg PIXEL F3 "NNR" Valid Iif(!Empty(Self:cVar3),ExistCpo("NNR",Self:cVar3,1),.T.) PICTURE "@!"
	      

			If SOE->(ColumnPos("OE_VAR4"))
				cMsg := STR0097 //"Indica se haverá integração com o APS"

				oGroup  := TGroup():New(155,250,175,350,STR0095,oDlg,,,.T.) //"APS"
				Self:cVar4 := .F.
				oCheck2 := TCheckBox():New(165,265,STR0096,,oGroup,80,,,,,,,,,,cMsg) //"Integra ordens do APS?"
				oCheck2:bSetGet := {|| Self:cVar4}
				oCheck2:bLClicked := {|| Self:cVar4:=!Self:cVar4}
			EndIf
		EndIf
	EndIf

Return Self
//---------------------------------------------------------
// Busca os campos da tabela
//---------------------------------------------------------
Method BusStruct() Class PCPA109F
	Local nI

	//{{Campos},{Tipo}}
	Self:aCampos := {{},{}}

	dbSelectArea(Self:cTabela)
	aStruct := dbStruct()
	
	For nI := 1 To Len(aStruct)
		aAdd(Self:aCampos[1],aStruct[nI][1])
		aAdd(Self:aCampos[2],aStruct[nI][2])
	Next

Return Nil
//---------------------------------------------------------
// Validação do botão Adicionar
//---------------------------------------------------------
Method vAdicionar() Class PCPA109F
	If Self:cLastEvent == "adicionar" .Or. Self:cLastEvent == "fechaparenteses"
		Return .F.
	EndIf
Return .T.
//---------------------------------------------------------
// Evento do Clique do botão Adicionar
//---------------------------------------------------------
Method Adicionar() Class PCPA109F
	Local nI
	Local cOperador := ""
	Local cExpressao := ""

	For nI := 1 To Len(Self:aOperadores[1])
		If Self:aOperadores[1][nI] == Self:cOperadores
			cOperador := Self:aOperadores[2][nI]
			Exit
		EndIf
	Next
	
	For nI := 1 To Len(Self:aCampos[1])
		If Self:aCampos[1][nI] == Self:cCampos
			cExpressao := Self:aCampos[2][nI]
			Exit
		EndIf
	Next
	
	If cExpressao == "C"
		Do Case
           Case cOperador == "1$" .Or. cOperador == "!1$"
              cExpressao := '"%' + AllTrim(Self:cExpressao) + '%"'
           /*Case cOperador == '2$' .Or. cOperador == '!2$'
              cExpressao := '"'+AllTrim(Self:cExpressao)+'"'
              cExpressao := StrTran(cExpressao,',','","')*/
           Otherwise
              cExpressao := '"' + AllTrim(Self:cExpressao) + '"'
		End
	ElseIf cExpressao == "N"
		If !IsNumDot( AllTrim(Self:cExpressao) )
			alert(STR0014) //"A expressão informada não é um valor numérico!"
			Return Nil
		Else
			cExpressao := AllTrim(Self:cExpressao)
		EndIf
	ElseIf cExpressao == "D"
		If Empty(Self:cExpressao) .Or. !IsNumeric( AllTrim(Self:cExpressao) ) .Or. Len(AllTrim(Self:cExpressao)) != 8
			alert(STR0015) //"A expressão informada não é uma data válida, utilize o padrão YYYYMMDD!"
			Return Nil
		Else 
			Do Case
			   Case cOperador == '1$' .Or. cOperador == "!1$"
			      cExpressao := '"%' + AllTrim(Self:cExpressao) + '%"'
			   /*Case cOperador == '2$' .Or. cOperador == '!2$'
			      cExpressao := '"'+AllTrim(Self:cExpressao)+'"'
                  cExpressao := StrTran(cExpressao,',','","')*/
			   OtherWise
			      cExpressao := '"' + AllTrim(Self:cExpressao) + '"'
			End
		EndIf
	EndIf

	If cOperador == '1$'
		Self:cFiltro := Self:cFiltro + " " + Self:cCampos + ' LIKE ' + cExpressao
	ElseIf cOperador == '!1$'
		Self:cFiltro := Self:cFiltro + " " + Self:cCampos + ' NOT LIKE ' + cExpressao
	/*ElseIf cOperador == '2$'
		Self:cFiltro := Self:cFiltro + " " + Self:cCampos + " IN (" + cExpressao + ")"
	ElseIf cOperador == '!2$'
		Self:cFiltro := Self:cFiltro + " " + Self:cCampos + " NOT IN (" + cExpressao + ")"*/
	Else 
		Self:cFiltro := Self:cFiltro + " " + Self:cCampos + " " + cOperador + " " + cExpressao
	EndIf
	
	Self:cLastEvent := "adicionar"

Return Nil
//---------------------------------------------------------
// Evento do clique do botão Limpar
//---------------------------------------------------------
Method Limpar() Class PCPA109F

	Self:cFiltro := ""
	Self:cLastEvent := "operador"
	Self:nParAberto := 0

Return Nil
//---------------------------------------------------------
// Validação do botão "("
//---------------------------------------------------------
Method vAbrePar() Class PCPA109F
	If Self:cLastEvent == "adicionar" .Or. Self:cLastEvent == "fechaparenteses"
		Return .F.
	EndIf
Return .T.
//---------------------------------------------------------
// Validação do botão ")"
//---------------------------------------------------------
Method vFechaPar() Class PCPA109F
	If Self:nParAberto <= 0 .Or. Self:cLastEvent == "operador"
		Return .F.
	EndIf
Return .T.
//---------------------------------------------------------
// Validação dos botões "and" e "or"
//---------------------------------------------------------
Method vAndOr() Class PCPA109F
	If Self:cLastEvent != "adicionar" .And. Self:cLastEvent != "fechaparenteses"
		Return .F.
	EndIf
Return .T.
//---------------------------------------------------------
// Evento do clique do botão "("
//---------------------------------------------------------
Method AbrePar() Class PCPA109F
	Self:nParAberto := Self:nParAberto + 1
	Self:cFiltro := Self:cFiltro + " ("
	Self:cLastEvent := "abreparenteses"
Return .T.
//---------------------------------------------------------
// Evento do clique do botão ")"
//---------------------------------------------------------
Method FechaPar() Class PCPA109F
	Self:nParAberto := Self:nParAberto - 1
	Self:cFiltro := Self:cFiltro + ") "
	Self:cLastEvent := "fechaparenteses"
Return .T.
//---------------------------------------------------------
// Evento do clique do botão "and"
//---------------------------------------------------------
Method And() Class PCPA109F
	Self:cFiltro := Self:cFiltro + " AND "
	Self:cLastEvent := "operador"
Return .T.
//---------------------------------------------------------
// Evento do clique do botão "or"
//---------------------------------------------------------
Method Or() Class PCPA109F
	Self:cFiltro := Self:cFiltro + " OR "
	Self:cLastEvent := "operador"
Return .T.
//---------------------------------------------------------
// Insere no memo um valor já existente de filtro
//---------------------------------------------------------
Method SetValue(cString) Class PCPA109F	
	If !Empty(cString)
		Self:cFiltro := cString
		Self:cLastEvent := "adicionar"
	EndIf
Return .T.
//---------------------------------------------------------
// Valida se a informação do filtro é consistente
//---------------------------------------------------------
Method PosValid() Class PCPA109F	
	If Empty(Self:cFiltro) .Or. (Self:cLastEvent != "operador" .And. Self:cLastEvent != "abreparenteses" .And. Self:nParAberto == 0)
		Return .T.
	EndIf
Return .F.

//---------------------------------------------------------
// Monta a tela padrão de filtro
//---------------------------------------------------------
Method FiltroPadr(cTabela, oDlg, lSinc) Class PCPA109F
	Local nPos := 0
	Local oChkExec
	
	Self:BusStruct()
	
	If lSinc .And. cTabela $ "SB2|SB8|SBF"
		nPos := 20
		Self:lExec := .T.
		If oDlg != Nil
			oChkExec := TCheckBox():New(05,05,STR0081,,oDlg,80,,,,,,,,) //"Processar"
			oChkExec:bSetGet := {|| Self:lExec}
			oChkExec:bLClicked := {|| Self:lExec:=!Self:lExec}
		EndIf
	Else
	   nPos := 12
	EndIf
	
	Self:cCampos:= Self:aCampos[1][1]
	Self:aOperadores:= {;
		{;
			STR0022,STR0023,STR0024,;	//'Igual a','Diferente de','Menor que'
			STR0025,STR0026,STR0027,;	//'Menor ou igual que','Maior que','Maior ou igual que'
			STR0028,STR0029/*,STR0030,STR0031*/;	//'Contém a expressão','Não contém',"Está contido em",'Não contido em'
		},;
		{'=','<>','<','<=','>','>=','1$','!1$'/*,'2$','!2$'*/};
	}
	Self:cOperadores:= Self:aOperadores[1][1]
	Self:cExpressao := Space(255)
	
	If oDlg != Nil
		//Campos
		@ nPos,05 SAY oAcao VAR STR0018+":" OF oDlg PIXEL //"Campos"
		oCombo1 := TComboBox():New(nPos+8,05,{|u|if(PCount()>0,Self:cCampos:=u,Self:cCampos)},;
		Self:aCampos[1],60,20,oDlg,,{||};
		,,,,.T.,,,,,,,,,'Self:cCampos')
		
		//Operadores
		@ nPos,70 SAY oAcao VAR STR0019+":" OF oDlg PIXEL //"Operadores"
		oCombo2 := TComboBox():New(nPos+8,70,{|u|if(PCount()>0,Self:cOperadores:=u,Self:cOperadores)},;
		Self:aOperadores[1],70,20,oDlg,,{||};
		,,,,.T.,,,,,,,,,'Self:cOperadores')
		
		//Expressao
		@ nPos,145 SAY oAcao VAR STR0020+":" OF oDlg PIXEL //"Expressão"
		@ nPos+8,145 MSGET Self:cExpressao SIZE 100,14 OF oDlg PIXEL Picture "@!"

		//Botoes
		@ nPos+26,05  BUTTON oBtnAvanca PROMPT STR0016  SIZE 60,12 WHEN (Self:vAdicionar()) ACTION (Self:Adicionar()) OF oDlg PIXEL
		@ nPos+26,70  BUTTON oBtnAvanca PROMPT STR0017  SIZE 60,12 ACTION (Self:Limpar()) OF oDlg PIXEL
		@ nPos+26,135 BUTTON oBtnAvanca PROMPT "(" WHEN (Self:vAbrePar()) SIZE 12,12 ACTION (Self:AbrePar()) OF oDlg PIXEL
		@ nPos+26,152 BUTTON oBtnAvanca PROMPT ")" WHEN (Self:vFechaPar()) SIZE 12,12 ACTION (Self:FechaPar()) OF oDlg PIXEL
		@ nPos+26,169 BUTTON oBtnAvanca PROMPT "and" WHEN (Self:vAndOr()) SIZE 12,12 ACTION (Self:And()) OF oDlg PIXEL
		@ nPos+26,186 BUTTON oBtnAvanca PROMPT "or" WHEN (Self:vAndOr()) SIZE 12,12 ACTION (Self:Or()) OF oDlg PIXEL
		
		//Filtro Memo
		@ nPos+43,05 SAY oAcao VAR STR0021+":" OF oDlg PIXEL //"Filtro"
		@ nPos+51,05 GET oMemo2 VAR Self:cFiltro OF oDlg MEMO WHEN (.F.) PIXEL SIZE 240,90// FONT (TFont():New('Verdana',,-12,.T.))
	EndIf

Return Nil