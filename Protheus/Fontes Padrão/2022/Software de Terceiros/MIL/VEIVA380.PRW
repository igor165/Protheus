#include "PROTHEUS.CH"
#include "VEIVA380.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} VEIVA380

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Cadastro de Grupos de Configuração

/*/
Function VEIVA380()
	Private aRotina    := MenuDef()
	Private aVQCCampos := FS_GtCposEnc('VQC')
	Private aHeaderVQD := FS_GtHeader('VQD')
	Private nSxeGet    := 0
	Private INCLUI     := .F.
	Private aTELA[0][0] , aGETS[0] // Variaveis utilizadas pela enchoice que deve existir em todo o contexto
	mBrowse( 6, 1,22,75,"VQC")
Return .T.

/*/{Protheus.doc} MENUDEF

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Menus

/*/
Static Function MenuDef()
Return { ;
	{ STR0001  ,"AxPesqui"  , 0 , 1 },;  // Pesquisar
	{ STR0002  ,"VA380R"    , 0 , 2 },;  // Visualizar
	{ STR0003  ,"VA380C"    , 0 , 3 },;  // Incluir
	{ STR0004  ,"VA380U"    , 0 , 4 },;  // Alterar
	{ STR0005  ,"VA380D"    , 0 , 5 } ;  // Excluir
}

/*/{Protheus.doc} Acao

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Retorna se esta na acao requisitada por parametro

/*/
Static Function Acao(cAcao, nOpc)
	Local lYes := .F.
	Do Case
		Case cAcao == "Pesquisar"  .AND. nOpc == 1
			lYes := .T.
		Case cAcao == "Visualizar" .AND. nOpc == 2
			lYes := .T.
		Case cAcao == "Incluir"    .AND. nOpc == 3
			lYes := .T.
		Case cAcao == "Alterar"    .AND. nOpc == 4
			lYes := .T.
		Case cAcao == "Excluir"    .AND. nOpc == 5
			lYes := .T.
	EndCase
Return lYes

/*/{Protheus.doc} VA380C

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Abre janela em modo Criacao de registro

/*/
Function VA380C(cAlias,nReg,nOpc)
	INCLUI := .T.
	CriaTela(nReg,nOpc)
Return .T.

/*/{Protheus.doc} VA380R

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Abre janela em modo visualizacao de registro

/*/
Function VA380R(cAlias,nReg,nOpc)
	CriaTela(nReg,nOpc)
Return .T.

/*/{Protheus.doc} VA380U

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Abre janela em modo atualizacao de registro

/*/
Function VA380U(cAlias,nReg,nOpc)
	CriaTela(nReg,nOpc)
Return .T.

/*/{Protheus.doc} VA380D

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Abre janela em modo exclusao de registro

/*/
Function VA380D(cAlias,nReg,nOpc)
	CriaTela(nReg,nOpc)
Return .T.

/*/{Protheus.doc} CriaTela

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Cria tela para manutenção dos dados/registros

/*/
Static Function CriaTela(nReg,nOpc)
	Local bCampo         := { |nCPO| Field(nCPO) }
	Local oDlg           := nil
	Local _ni            := 1
	Private cTitulo      := STR0007
	Private oGetDadosVQD := nil
	Private aColsVQD     := {}
	Private aObjects     := {}
	Private aSizeAut     := MsAdvSize(.t.) // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Private aInfo        := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 } // Tamanho total da tela
	Private aPosObj      := {}
	Private cTudOk       := "FG_OBRIGAT()"
	Private cLinOk       := "FG_OBRIGAT()"
	Private cGdTOK       := "AllwaysTrue()"
	Private cFieldOk     := "AllwaysTrue()"
	Private aCols        := { }
	Private aHeader

	INCLUI := ( nOpc == 3 )
	ALTERA := ( nOpc == 4 )

	AAdd( aObjects, { 0, 70, .T., .T. } )
	AAdd( aObjects, { 0, 30, .T., .T. } )
	aPosObj := MsObjSize( aInfo, aObjects ) // Monta objetos conforme especificacoes
	nOpcE   := nOpcx := nOpca := nOpcG := nOpc 
	oDlg := MSDIALOG():New( aSizeAut[7], 0, aSizeAut[6], aSizeAut[5], cTitulo,,,,,,,,, .T.)

	//////////////////////////////////////////
	// Cria variaveis M->????? da Enchoice  //
	//////////////////////////////////////////
	lCriavar := Acao('Incluir', nOpc) // se for inclusao usa criavar senao pega do registro selecionado
	RegToMemory("VQC", lCriavar, lCriavar, lCriavar)
	// Objeto Enchoice
	oEnch := MSMGet():New("VQC", nReg, nOpcE,,,, aVQCCampos, aPosObj[1],, 2,,, cTudOk, oDlg, .f., .t., .f., "", .t., .f.)

	//////////////////////////////////////////
	// Criacao da GetDados                  //
	//////////////////////////////////////////
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("VQD")
	aHeader := {}
	While !Eof().And.(x3_arquivo=="VQD")
		If X3USO(x3_usado) .And. cNivel >= x3_nivel
			Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal,x3_valid, x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv })
		Endif
		dbSkip()
	EndDo
	aHeaderVQD := aHeader
	// Inclui coluna de registro atraves de funcao generica
	dbSelectArea("VQD")
	ADHeadRec("VQD",aHeader)
	// Posicao do registro
	nPosRec := Len(aHeader)
	nUsado  := Len(aHeader)

	aCols:={}
	dbSelectArea("VQD")
	dbSetOrder(2)
	dbSeek(xFilial() + M->VQC_CODIGO)

	If Acao('Alterar', nOpc) // evita gastar valor no sxe
		VA380RBSxe()
	Endif

	If nOpc == 3 .Or. !Found()
		aCols := { Array(nUsado+1) }
		aCols[1,nUsado+1]:=.F.
		For _ni := 1 to nUsado
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := 0
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VQD"
			Else
				aCols[1,_ni] := CriaVar(aHeader[_ni,2])
			EndIf
		Next
	Else
		While !eof() .And. VQD->VQD_FILIAL == xFilial("VQD") .and. M->VQC_CODIGO == VQD->VQD_CODVQC
			RegToMemory("VQD",.T.)
			AADD(aCols,Array(nUsado+1))
			For _ni := 1 to nUsado
				If IsHeadRec(aHeader[_ni,2])
					aCols[Len(aCols),_ni] := VQD->(RecNo())
				ElseIf IsHeadAlias(aHeader[_ni,2])
					aCols[Len(aCols),_ni] := "VQD"
				Else
					aCols[Len(aCols),_ni] := IIf(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
				EndIf
			Next
			aCols[Len(aCols),nUsado+1] := .F.
			dbSkip()
		EndDo
		nLenaCols := Len(aCols)
	Endif

	lIncAlt   := nOpcG > 2 .and. nOpcG < 5 // inclusao ou alteracao
	oGetDados := MsGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcG, cLinOk, cGdTOK, "", IIf(lIncAlt,.T.,.F.),,,,, cFieldOk)
	oGetDados:oBrowse:bChange := { || FG_MEMVAR() }

	ACTIVATE MSDIALOG oDlg ON INIT ( EnChoiceBar(oDlg,	{|| IIF(FS_CONFIRMA(nOpc), oDlg:End(), nil) } ,{|| FS_CANCELA(), oDlg:End() }) )

Return .T.

/*/{Protheus.doc} FS_CONFIRMA

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Acao do botao confirma

/*/
Static Function FS_CONFIRMA(nOpc)
	if nOpc == 5 // Deletando
		Return FS_EXCLUI()
	end
	If obrigatorio(aGets,aTela) .AND. FG_OBRIGAT() .and. VA380031_Valida_MarcaModelo()
		Return FS_SALVAR()
	End
Return .F.

/*/{Protheus.doc} FS_SALVAR

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Grava os dados da tela no banco de dados

/*/
Static Function FS_SALVAR()
	Local nLoop := 1
	Local aVQCStru := FWFormStruct(3, "VQC" , { |x| !AllTrim(x) $ "VQC_FILIAL/" } )
	Begin Transaction
		BEGIN SEQUENCE
			////////////////////////////////////
			// Gravação VQC - Grupo de Config //
			////////////////////////////////////
			DbSelectArea('VQC')
			dbSetOrder(1)
			VQC->(DbSeek(xFilial('VQC') + M->VQC_CODIGO))
			RecLock("VQC", !Found() )
			VQC->VQC_FILIAL := xFilial('VQC')
			For nLoop := 1 to len(aVQCStru[1])
				If !aVQCStru[1,nLoop,14] // Se NAO for campo Virtual
					&("VQC->"+aVQCStru[1,nLoop,3]) := &("M->"+aVQCStru[1,nLoop,3])
				EndIf
			Next
			VQC->(MsUnlock())

			////////////////////////////////////
			// Gravação VQD -          Config //
			////////////////////////////////////
			for nLoop := 1 to Len(aCols)
				VQD->(DbSetOrder(1))
				VQD->(DbSeek( xFilial('VQD') + aCols[nLoop, FG_POSVAR('VQD_CODIGO')] ))
				RecLock("VQD", !VQD->(FOUND()) )
				lDeleted := aCols[nLoop, LEN(aCols[nLoop])]
				if lDeleted
					If !Empty(VQD->VQD_CODIGO) // se estiver deletado mas for um novo registro não precisa fazer nada, pois é só não gravar(ELSE)
						If VA380VQDCanDel(VQD->VQD_CODIGO)
							VQD->(DbDelete())
							VQD->(MsUnlock())
						Else
							MSGInfo(STR0009, STR0019)
						EndIf
					EndIf
				Else
					FG_GRAVAR("VQD", aCols, aHeaderVQD, nLoop)
				Endif
				
			next
		RECOVER
			DisarmTransaction()
			//"Ocorreu um erro ao salvar os dados, por favor verifique sua rede e tente novamente."
			UserException(STR0006 + chr(13) + chr(10) + "Erro: " + __EXCEPTION__->ERROR )
			VA380RBSxe()
		END SEQUENCE

	End Transaction
	VA380CFSxe()

Return .T.

/*/{Protheus.doc} FS_EXCLUI

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Exclui registro selecionado

/*/
Static Function FS_EXCLUI()
	Local nLoop := 1
	Local lOk   := .T.
	Begin Transaction
		BEGIN SEQUENCE
			for nLoop := 1 to Len(aCols)
				VQD->(DbSetOrder(1))
				VQD->(DbSeek( xFilial('VQD') + aCols[nLoop, FG_POSVAR('VQD_CODIGO')] ))
				RecLock("VQD", .F. )
				If VA380VQDCanDel(VQD->VQD_CODIGO)
					VQD->(DbDelete())
				Else
					lOk := .F.
					EXIT
				Endif
			next

			If lOk
				VQD->(MsUnlock())

				DbSelectArea('VQC')
				dbSetOrder(1)
				VQC->(DbSeek(xFilial('VQC') + M->VQC_CODIGO))
				RecLock("VQC", .F. )
				VQC->(DbDelete())
				VQC->(MsUnlock())
			EndIf

			If ! lOk
				DisarmTransaction()
				MSGInfo(STR0009, STR0019)
				Return .F.
			Endif
		RECOVER
			DisarmTransaction()
			//"Ocorreu um erro ao salvar os dados, por favor verifique sua rede e tente novamente."
			UserException(STR0006 + chr(13) + chr(10) + "Erro: " + __EXCEPTION__->ERROR )
		END SEQUENCE
	End Transaction
Return .T.

/*/{Protheus.doc} FS_CANCELA

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Cancela tudo e volta para mbrowse

/*/
Static Function FS_CANCELA()
	DisarmTransaction()
	VA380RBSxe()
Return .T.

/*/{Protheus.doc} FS_GtCposEnc

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Pega campos validos para a enchoice
	@param        cAlias, Alias da tabela 

/*/
Static Function FS_GtCposEnc(cAlias)
	Local aCampos := {}
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("VQC")
	While !Eof() .And. (x3_arquivo == "VQC")
		If X3USO(x3_usado) .And. cNivel >= x3_nivel
			AADD(aCampos, x3_campo)
		Endif
		DbSkip()
	EndDo
Return aCampos

/*/{Protheus.doc} FS_GtCposEnc

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Pega header validos para a getdados
	@param        cAlias, Alias da tabela 

/*/
Static Function FS_GtHeader(cAlias)
	Local aHeader := {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	aHeader := {}
	While !Eof().And.(x3_arquivo==cAlias)
		If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(x3_campo $ [VQD_GRUFER/VQD_DESGRU])
			Aadd(aHeader, { TRIM(X3Titulo()), x3_campo, x3_picture, x3_tamanho, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
//			&("M->"+x3_campo) := CriaVar(x3_campo)
		Endif
		dbSkip()
	EndDo
Return aHeader

/*/{Protheus.doc} FS_GtCposEnc

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Cria tela para customização de Configuração de Veículo
	@param        cAlias, Alias da tabela 
	@param        cChaIntP, Chassi interno do veiculos
	@param        cCodMarP, Marca do Veiculo
	@param        cGruModP, Grupo de Modelo do Veiculo
	@param        aVetConfig, Vetor com informações previas de configuração 
	@example      Os elementos do vetor devem estar no formato: { VQD_CODIGO, VQD_VALCON, VQD_CODVQC }

/*/
Function VA380CONFIG(cChaInt, cCodMarP, cGruModP, aVetConfig, cModVeiP, cSegModP )
	Private oTik         := LoadBitmap( GetResources(), "LBTIK" )
	Private oNaoTik      := LoadBitmap( GetResources(), "LBNO"  )
	Private aObjects     := {}
	Private aSizeAut     := MsAdvSize(.t.) // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Private aInfo        := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 } // Tamanho total da tela
	Private aPosObj      := {}
	Private aAcoesRel    := {}
	Private nGtVlrTabela := 0
	Private nGtVlrConf   := 0
	Private nGtVlrSugVen := 0
	Private aVQDTicados  := IIF(VALTYPE(aVetConfig) == 'A', aVetConfig, {})
	Private nValTab      := VA380VLRTAB(cChaInt)
	Private cCodMar      := cCodMarP
	Private cGruMod      := cGruModP
	Private cModVei      := cModVeiP
	Private cSegMod      := cSegModP
	Private aHlp         := Mil_ArrayHelper():New()
	Private lCancelou    := .F.
	nGtVlrTabela         := nValTab

	// Busca configuração atual do veículo se não foi passada nenhuma por parametro
	if Len(aVQDTicados) <= 0
		aCfgVei     := FS_BusConf(cChaInt)
		if Len(aCfgVei) > 0 // Veículo já tem configuração salva?
			// função map precisa alterar a documentacao, esta errada //
			// funcao map retorna outro array após "rodar" o bloco para cada item do array origem, muito bom quando precisamos transformar dados
			// no caso abaixo transformamos a tabela VQE em dados ticados do veículo no caso a VQD... o metodo se encontra no veixfunb classe Mil_ArrayHelper
			aVQDTicados := aHlp:Map(aCfgVei, {|oCfg| {oCfg:GetValue('VQE_CODVQD'), oCfg:GetValue('VQD_VALCON'), oCfg:GetValue('VQD_CODVQC')} })
		EndIf
	EndIf
	// --- 

	AAdd( aObjects, { 0, 40, .T., .T. } )
	AAdd( aObjects, { 0, 60, .T., .T. } )
	aPosObj := MsObjSize( aInfo, aObjects ) // Monta objetos conforme especificacoes
	
	// Configurações
	DEFINE MSDIALOG oWindow TITLE STR0002 FROM aSizeAut[7], 0 TO aSizeAut[6], aSizeAut[5] OF oMainWnd PIXEL

	@ aPosObj[1,1] + 000 , aPosObj[1,2] + 000 LISTBOX oLbGrupos ;
		FIELDS ;
		HEADER         STR0008,     STR0012,            STR0010;
		COLSIZES          60,         150,                100  ;
		SIZE aPosObj[1,4] - 200, aPosObj[1,3] - aPosObj[1,1] OF oWindow PIXEL ;
		ON DBLCLICK FS_1DblClick() ;
		ON CHANGE { || FS_1Change() }
	oLbGrupos:SetArray( FS_VQCBusca() )
	oLbGrupos:bLine        := FS_1Valores()
	oLbGrupos:bHeaderClick := FS_1HeaderClick()

	@ aPosObj[2,1] + 000 , aPosObj[2,2] + 000 LISTBOX oLbConfigs ;
		FIELDS ;
		HEADER         '',        STR0011,     STR0012, STR0013 ;
		COLSIZES       40,            100,         150,     100 ;
		SIZE aPosObj[2,4] - 5, aPosObj[2,3] - aPosObj[2,1] OF oWindow PIXEL ;
		ON DBLCLICK FS_2DblClick();
		ON CHANGE {|| FS_2Change() }
	oLbConfigs:SetArray({})
	oLbConfigs:bLine        := FS_2Valores()
	oLbConfigs:bHeaderClick := FS_2HeaderClick()


	// Valor Tabela
	@ aPosObj[1,1] + 015 , aPosObj[1,4] - 175 SAY STR0014 OF oWindow PIXEL
	@ aPosObj[1,1] + 012 , aPosObj[1,4] - 085 MSGET oGtVlrTabela VAR nGtVlrTabela PICTURE "@E 999,999,999.99" SIZE 80,08 OF oWindow READONLY PIXEL HASBUTTON
	// Valor Config
	@ aPosObj[1,1] + 035 , aPosObj[1,4] - 175 SAY STR0015 OF oWindow PIXEL
	@ aPosObj[1,1] + 032 , aPosObj[1,4] - 085 MSGET oGtVlrConf   VAR nGtVlrConf   PICTURE "@E 999,999,999.99" SIZE 80,08 OF oWindow READONLY PIXEL HASBUTTON
	// Valor Sug. Venda
	@ aPosObj[1,1] + 055 , aPosObj[1,4] - 175 SAY STR0016 OF oWindow PIXEL
	@ aPosObj[1,1] + 052 , aPosObj[1,4] - 085 MSGET oGtVlrSugVen VAR nGtVlrSugVen PICTURE "@E 999,999,999.99" SIZE 80,08 OF oWindow          PIXEL HASBUTTON

	FS_SumUPD() // atualiza dados pra tela

	ACTIVATE MSDIALOG oWindow ON INIT (EnchoiceBar(oWindow, { || oWindow:End() }, { || oWindow:End(), lCancelou := .T. },,aAcoesRel))

	//VA380GRVCFG( cChaInt, aVQDTicados )
	if lCancelou
		return nil
	end
Return {aVQDTicados, nGtVlrSugVen}

/*/{Protheus.doc} FS_1Change

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Evento change do listbox 1 (usado para buscar os filhos VQD)

/*/
Static Function FS_1Change()
	Local cCodVQC := nil
	if LEN(oLbGrupos:aArray) > 0
		cCodVQC := oLbGrupos:aArray[oLbGrupos:nAt]:GetValue('VQC_CODIGO')
		oLbConfigs:SetArray( FS_VQDBusca(cCodVQC) )
		oLbConfigs:bLine := FS_2Valores()
		oLbConfigs:Refresh()
	EndIf
Return .T.

/*/{Protheus.doc} FS_2Change

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Evento change do listbox 2 (usado para calcular os totais)

/*/
Static Function FS_2Change()
	oLbGrupos:Refresh()
Return .T.

/*/{Protheus.doc} FS_HeaderClick1

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Evento header click do listbox 1

/*/
Static Function FS_1HeaderClick()
Return { |oObj,nCol| }

/*/{Protheus.doc} FS_HeaderClick2

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Evento header click do listbox 2

/*/
Static Function FS_2HeaderClick()
Return { |oObj,nCol| }

/*/{Protheus.doc} FS_Valores1

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Indica os valores mostrados em cada coluna do listbox 2

/*/
Static Function FS_1Valores()
Return  { || IIF(LEN(oLbGrupos:aArray) < oLbGrupos:nAt, {"", "", 3},;
			{ ;
				oLbGrupos:aArray[oLbGrupos:nAt]:GetValue('VQC_CODIGO'),;
				oLbGrupos:aArray[oLbGrupos:nAt]:GetValue('VQC_DESCRI'),;
				FG_AlinVlrs(Transform( FS_1Sum(oLbGrupos:aArray[oLbGrupos:nAt]:GetValue('VQC_CODIGO')), "@E 999,999,999.99"));
			});
		}

/*/{Protheus.doc} FS_Valores2

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Indica os valores mostrados em cada coluna do listbox 2

/*/
Static Function FS_2Valores()
Return  { || IIF(LEN(oLbConfigs:aArray) < oLbConfigs:nAt, {oNaoTik, "", "", ""},;
			{ ;
				IIF( FS_Ticado(oLbConfigs:aArray[oLbConfigs:nAt]:GetValue('VQD_CODIGO')), oTik, oNaoTik ),;
				oLbConfigs:aArray[oLbConfigs:nAt]:GetValue('VQD_CODIGO'),;
				oLbConfigs:aArray[oLbConfigs:nAt]:GetValue('VQD_DESCRI'),;
				FG_AlinVlrs(Transform( oLbConfigs:aArray[oLbConfigs:nAt]:GetValue('VQD_VALCON') , "@E 999,999,999.99")) ;
			}) ;
		}

/*/{Protheus.doc} FS_Ticado

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Verifica se o CODIGO VQC foi selecionado pelo usuário

/*/
Static Function FS_Ticado(cCodVQD)
Return ASCAN( aVQDTicados, {|el| el[1] == cCodVQD } ) > 0

/*/{Protheus.doc} FS_DblClick1

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Evento double click do cabecalho do listbox 1

/*/
Static Function FS_1DblClick()
Return .T.

/*/{Protheus.doc} FS_DblClick2

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Evento double click do cabecalho do listbox 2

/*/
Static Function FS_2DblClick()
	Local oVQD    := oLbConfigs:aArray[oLbConfigs:nAt]
	Local cCodVQC := oVQD:GetValue('VQD_CODVQC')

	If GetNewPar("MV_MIL0165","0") == "0" // Não deixa selecionar mais de um VQD
		//Deletando antigo selecionado , se existir e diferente do que eu quero selecionar/deselecionar
		nPosD := ASCAN(aVQDTicados, {|el| el[3] == cCodVQC .AND. el[1] != oVQD:GetValue('VQD_CODIGO')})
		if nPosD > 0
			ADEL( aVQDTicados, nPosD )
			ASIZE( aVQDTicados, LEN(aVQDTicados) - 1 ) // redefinir array tirando valores nulos pois dão problema nas funcoes 
		EndIf
	EndIf

	If FS_Ticado(oVQD:GetValue('VQD_CODIGO'))
		nPosD := ASCAN( aVQDTicados, { |el| el[1] == oVQD:GetValue('VQD_CODIGO') } )
		ADEL( aVQDTicados, nPosD )
		ASIZE( aVQDTicados, LEN(aVQDTicados) - 1 ) // redefinir array tirando valores nulos pois dão problema nas funcoes 
	Else
		AADD( aVQDTicados, { oVQD:GetValue('VQD_CODIGO'), oVQD:GetValue('VQD_VALCON'), oVQD:GetValue('VQD_CODVQC') } )
	EndIf
	oLbConfigs:Refresh()
	FS_SumUPD()
Return .T.

/*/{Protheus.doc} FS_VQCBusca

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Evento que busca os grupos de configuracao

/*/
Static Function FS_VQCBusca()
	Local aCollection := {}
	Local cAlias      := Alias()
	Local cAliasQ     := GetNextAlias()
	Local cQuery      := ""
	cQuery := " SELECT * FROM " + RetSqlName('VQC') + " VQC"
	cQuery += "  WHERE VQC.VQC_FILIAL = '" + xFilial('VQC') + "'"
	cQuery += "    AND VQC.VQC_CODMAR = '" + cCodMar + "' "
	cQuery += "    AND "
	cQuery += "    (   ( VQC.VQC_MODVEI = '" + cModVei + "' AND VQC.VQC_SEGMOD = '" + cSegMod + "' ) "
	cQuery += "     OR ( VQC.VQC_MODVEI = '" + cModVei + "' AND VQC.VQC_SEGMOD = ' ' ) "
	cQuery += "     OR ( VQC.VQC_GRUMOD = '" + cGruMod + "' ) "
	cQuery += "    )"
	cQuery += "    AND VQC.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQ, .T., .T. )
	Do While !( cAliasQ )->( Eof() )
		oData := Mil_DataContainer():New({;
			{'VQC_FILIAL', ( cAliasQ )->VQC_FILIAL},;
			{'VQC_CODIGO', ( cAliasQ )->VQC_CODIGO},;
			{'VQC_DESCRI', ( cAliasQ )->VQC_DESCRI},;
			{'VQC_GRUMOD', ( cAliasQ )->VQC_GRUMOD},;
			{'VQC_CODMAR', ( cAliasQ )->VQC_CODMAR},;
			{'VQC_MODVEI', ( cAliasQ )->VQC_MODVEI},;
			{'VQC_SEGMOD', ( cAliasQ )->VQC_SEGMOD} ;
		})
		AADD( aCollection, oData )
		( cAliasQ )->( DbSkip() )
	Enddo
	( cAliasQ )->( dbCloseArea() )
	If cAlias <> ""
		DBSelectArea(cAlias)
	EndIf
Return aCollection

/*/{Protheus.doc} FS_BuscaVQD

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Evento que busca os itens de configuracao de um determinado grupo de configuracao

/*/
Static Function FS_VQDBusca(cCodVQC)
	Local aCollection := {}
	Local cAlias      := Alias()
	Local cAliasQ     := GetNextAlias()
	Local cQuery      := ""

	//TODO: Filtrar modelo e marca dos parametros
	cQuery := " SELECT * FROM " + RetSqlName('VQD') + " VQD WHERE VQD.VQD_FILIAL = '" + xFilial('VQD') + "' AND VQD.D_E_L_E_T_ = ' ' "
	cQuery += "    AND VQD.VQD_CODVQC = '" + cCodVQC + "' " 

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQ, .T., .T. )
	Do While !( cAliasQ )->( Eof() )
		oData := Mil_DataContainer():New({;
			{'VQD_FILIAL', ( cAliasQ )->VQD_FILIAL},;
			{'VQD_CODIGO', ( cAliasQ )->VQD_CODIGO},;
			{'VQD_CODVQC', ( cAliasQ )->VQD_CODVQC},;
			{'VQD_DESCRI', ( cAliasQ )->VQD_DESCRI},;
			{'VQD_VALCON', ( cAliasQ )->VQD_VALCON} ;
		})
		AADD( aCollection, oData )

		( cAliasQ )->( DbSkip() )
	Enddo
	( cAliasQ )->( dbCloseArea() )

	If cAlias <> ""
		DBSelectArea(cAlias)
	EndIf
Return aCollection

/*/{Protheus.doc} FS_1Sum

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Mostra a soma dos VQDs ticados no grid de VQCs

/*/
Static Function FS_1Sum(cCodVQC)
	Local nSum  := 0
	Local nLoop := 1
	for nLoop := 1 to Len(aVQDTicados)
		aEl := aVQDTicados[nLoop]
		If aEl[3] == cCodVQC
			nSum += aEl[2]
		EndIf
	next
Return nSum

/*/{Protheus.doc} FS_SumUPD

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Forca atualização dos dados dos grids, e faz a soma geral com dados do veículo.

/*/
Static Function FS_SumUPD(cCodVQC)
	Local nLoop    := 1
	Local nSumConf := 0 // valor total config

	for nLoop := 1 to Len(aVQDTicados)
		aEl := aVQDTicados[nLoop]
		nSumConf += aEl[2]
	next

	nGtVlrSugVen := nSumConf + nValTab
	nGtVlrConf   := nSumConf

	oGtVlrConf:Refresh()
	oGtVlrTabela:Refresh()
	oGtVlrSugVen:Refresh()
	oLbGrupos:Refresh()
	oLbConfigs:Refresh()
Return .T.

/*/{Protheus.doc} VA380GRVCFG

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Função que irá gravar uma configuração associando a determinado veículo(chaint)
	@param        cChaInt , chassi interno do veiculo
	@param        aVetConfig, vetor com configuração
	@param        nSugVdaD, valor digitado de sugestao de venda será jogado no VV1_SUGVDA 
	@example      Os elementos do vetor devem estar no formato: { VQD_CODIGO, VQD_VALCON, VQD_CODVQC }
/*/
Function VA380GRVCFG(cChaInt, aVetConfig, nSugVdaD, cCodPac)
	Local nLoop      := 1
	Local nSumConf   := 0
	Local nValTab    := VA380VLRTAB(cChaInt)
	Local cConfig    := ""
	Local cCfgPacote := ""
	Local cQuery     := ""
	Local cMVMIL0166 := GetNewPar("MV_MIL0166","0") // Tipo de Gravação das Configurações Basicas: 0=VQD_DESCRI (padrão) / 1=VJV_CODOPC / 2=VQD_DESUSR
	Local cMVMIL0167 := GetNewPar("MV_MIL0167","1") // Gravação do Valor Sugerido: 1=Sim (default) / 0=Não
	Local cMVMIL0168 := GetNewPar("MV_MIL0168","0") // Trabalha com Pacote de Configuração ? 1=Sim / 0=Não (default)
	Local lVQE_CODPAC := VQE->(ColumnPos("VQE_CODPAC")) > 0
	Default cCodPac   := ""

	If cMVMIL0166 == "1" .and. VQD->(ColumnPos("VQD_CODVJV")) == 0 // TEMPORARIO - Caso não existir o campo VQD_CODVJV
		cMVMIL0166 := "0"
	ElseIf cMVMIL0166 == "2" .and. VQD->(ColumnPos("VQD_DESUSR")) == 0 // TEMPORARIO - Caso não existir o campo VQD_DESUSR
		cMVMIL0166 := "0"
	EndIf

	If len(aVetConfig) > 0
	
		Begin Transaction

		// Apagar antiga conf completa
		VQE->(dbSetOrder(1))
		VQE->(DbSeek( xFilial('VQE') + cChaInt ))
		While VQE->(!Eof()) .and. VQE->VQE_FILIAL == xFilial('VQE') .and. VQE->VQE_CHAINT == cChaInt
			RecLock('VQE', .F.)
			VQE->(DbDelete())
			VQE->(DbSkip())
		EndDo
		VQE->(MsUnlock())

		If cMVMIL0168 == "1" .and. !Empty(cCodPac) // Trabalha com Pacote de Configuração ? 
			cQuery := "SELECT VN0_CFGBAS "
			cQuery += "  FROM " + RetSqlName("VN0")
			cQuery += " WHERE VN0_FILIAL = '"+xFilial("VN0")+"' "
			cQuery += "   AND VN0_CODIGO = '"+cCodPac+"' "
			cQuery += "   AND VN0_STATUS = '1' "
			cQuery += "   AND D_E_L_E_T_ = ' ' "
			cConfig := cCfgPacote := Alltrim(FM_SQL(cQuery))
		EndIf

		// Grava nova config
		for nLoop := 1 to LEN(aVetConfig)
			If len(aVetConfig[nLoop]) > 0
				aEl := aVetConfig[nLoop]
				nSumConf += aEl[2] // VQD_VALCON
				// Deve gravar VQE assim como os campos referentes no VV1_
				RecLock("VQE", .T.) // Novo registro sempre
				VQE->VQE_CODIGO := criavar('VQE_CODIGO') // Getsxenum esta sendo feito no relacao do campo
				VQE->VQE_FILIAL := xFilial('VQE')
				VQE->VQE_CODVQD := aEl[1]
				VQE->VQE_CHAINT := cChaInt
				If lVQE_CODPAC
					VQE->VQE_CODPAC := cCodPac
				EndIf
				ConfirmSX8()
				VQE->(MsUnlock())

				If Empty(cCfgPacote)
					VQD->(dbSetOrder(1))
					VQD->(DbSeek( xFilial("VQD") + VQE->VQE_CODVQD))
					// controi o campo VV1_CFGBAS e VQ0_CONFIG //
					Do Case
						Case cMVMIL0166 == "0" // Padrão - VQD_DESCRI
							If !Empty(VQD->VQD_DESCRI)
								cConfig += IIf(!Empty(cConfig),", ","")+ALLTRIM(VQD->VQD_DESCRI)
							EndIf
						Case cMVMIL0166 == "1" // Opcionais do VJV - VJV_CODOPC
							If !Empty(VQD->VQD_CODVJV)
								VJV->(dbSetOrder(1))
								If VJV->(DbSeek( xFilial("VJV")+VQD->VQD_CODVJV))
									cConfig += IIf(!Empty(cConfig),", ","")+ALLTRIM(VJV->VJV_CODOPC)
								EndIf
							EndIf
						Case cMVMIL0166 == "2" // Codigos da Conf.Basica VQD - VQD_DESUSR
							If !Empty(VQD->VQD_DESUSR)
								cConfig += IIf(!Empty(cConfig),", ","")+ALLTRIM(VQD->VQD_DESUSR)
							EndIf
					EndCase
				EndIf
			EndIf
		next

		VV1->(DbSetOrder(1))
		If VV1->(DbSeek( xFilial('VV1') + cChaInt ))
			RecLock("VV1", .F.)
			If cMVMIL0168 == "1" // Trabalha com Pacote de Configuração ? 
				VV1->VV1_VALTAB := nSugVdaD
				VV1->VV1_VALCON := 0
				If cMVMIL0167 == "1" // Gravar o Valor Sugerido
					VV1->VV1_SUGVDA := nSugVdaD
				EndIf
			Else
				VV1->VV1_VALTAB := nValTab
				VV1->VV1_VALCON := nSumConf
				If cMVMIL0167 == "1" // Gravar o Valor Sugerido
					if VALTYPE(nSugVdaD) == "N"
						VV1->VV1_SUGVDA := nSugVdaD
					else
						VV1->VV1_SUGVDA := nValTab + nSumConf
					EndIf
				EndIf
			EndIf
			VV1->VV1_CFGBAS := cConfig
			VV1->(MsUnlock())
		Else
			DisarmTransaction() // não foi encontrado chaint deve-se disarmar e retornar false
			Return .F.
		EndIf

		VQ0->(dbSetOrder(3))
		if VQ0->(DbSeek( xFilial('VQ0') + cChaInt ))
			RecLock("VQ0", .F.)
			VQ0->VQ0_CONFIG := cConfig
			VQ0->(MsUnlock())
		endif
	
		End Transaction
	
	EndIf

Return .T.

/*/{Protheus.doc} VA380CFGVEI

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Mostrará detalhes da configuração de um veículo
	@teste        ctrl+f12 = va380cfgvei('000226')
/*/
Function VA380CFGVEI(cChaInt)
	Private oTik         := LoadBitmap( GetResources(), "LBTIK" )
	Private oNaoTik      := LoadBitmap( GetResources(), "LBNO"  )
	Private aObjects     := {{ 0, 20, .T., .T. } , { 0, 80, .T., .T. }}
	Private aSizeAut     := MsAdvSize(.t.) // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Private aInfo        := { aSizeAut[ 1 ]*0.8, aSizeAut[ 2 ]*0.8,aSizeAut[ 3 ]*0.8,aSizeAut[ 4 ]*0.8, 3, 3 } // Tamanho total da tela
	Private aPosObj      := MsObjSize( aInfo, aObjects ) // Monta objetos conforme especificacoes
	Private aAcoesRel    := {}
	Private nValTab      := VA380VLRTAB(cChaInt)
	Private aVQETicados  := {}

	cConfBasica  := Space(255)
	nGtVlrTabela := nValTab
	nGtVlrConf   := 0
	nGtVlrSugVen := 0

	VA380SelVei(cChaInt)
		
	// Configurações
	DEFINE MSDIALOG oWindow TITLE STR0017 FROM aSizeAut[7]*0.8, 0*0.8 TO aSizeAut[6]*0.8, aSizeAut[5]*0.8 OF oMainWnd PIXEL

	// Valor Tabela
	@ aPosObj[1,1] + 005 , aPosObj[1,1] + 005*0.9 SAY STR0014 OF oWindow PIXEL
	@ aPosObj[1,1] + 003 , aPosObj[1,1] + 050*0.9 MSGET oGtVlrTabela VAR nGtVlrTabela PICTURE "@E 999,999,999.99" SIZE 80*0.8,08 OF oWindow READONLY PIXEL HASBUTTON
	// Valor Config
	@ aPosObj[1,1] + 005 , aPosObj[1,1] + 129*0.9 SAY STR0015 OF oWindow PIXEL
	@ aPosObj[1,1] + 003 , aPosObj[1,1] + 191*0.9 MSGET oGtVlrConf   VAR nGtVlrConf   PICTURE "@E 999,999,999.99" SIZE 80*0.8,08 OF oWindow READONLY PIXEL HASBUTTON
	// Valor Sug. Venda
	@ aPosObj[1,1] + 005 , aPosObj[1,1] + 269*0.9 SAY STR0016 OF oWindow PIXEL
	@ aPosObj[1,1] + 003 , aPosObj[1,1] + 340*0.9 MSGET oGtVlrSugVen VAR nGtVlrSugVen PICTURE "@E 999,999,999.99" SIZE 80*0.8,08 OF oWindow READONLY PIXEL HASBUTTON
	
	// Configuracao Basica
	@ aPosObj[1,1] + 018 , aPosObj[1,1] + 000 *0.9 SAY STR0018 OF oWindow PIXEL
	@ aPosObj[1,1] + 016 , aPosObj[1,1] + 50*0.9 MSGET oGtConfBas VAR VV1->VV1_CFGBAS PICTURE "@!" SIZE 325,08 OF oWindow READONLY PIXEL HASBUTTON

	@ aPosObj[2,1] - 100*0.8 , aPosObj[2,2] + 000*0.8 LISTBOX oLbVConf ;
		FIELDS ;
		HEADER    '', STR0008, STR0011, STR0013 ;
		COLSIZES  30,      60,     150,     100 ;
		SIZE aPosObj[2,4], aPosObj[2,3] - aPosObj[2,1] + 85 OF oWindow PIXEL ;
		ON DBLCLICK FS_3DblClick() ;
		ON CHANGE { || FS_3Change() }
	oLbVConf:SetArray(FS_TUPDVQES(cChaInt))
	oLbVConf:bLine        := FS_3Valores()
	oLbVConf:bHeaderClick := FS_3HeaderClick()


	ACTIVATE MSDIALOG oWindow ON INIT (EnchoiceBar(oWindow, { || oWindow:End() }, { || oWindow:End() },,aAcoesRel))

Return .T.

/*/{Protheus.doc} FS_3DblClick

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Mostrará detalhes da configuração de um veículo

/*/
Static Function FS_3DblClick()
	//Local oVQE := oLbVConf:aArray[oLbVConf:nAt]
	Return .T.
	//If FS_TIKVQE(oVQE:GetValue('VQE_CODIGO'))
	//	nPosD := ASCAN( aVQETicados, { |el| el[1] == oVQE:GetValue('VQE_CODIGO') } )
	//	ADEL( aVQETicados, nPosD )
	//	ASIZE( aVQETicados, LEN(aVQETicados) - 1 ) // redefinir array tirando valores nulos pois dão problema nas funcoes 
	//Else
	//	AADD( aVQETicados, { oVQE:GetValue('VQE_CODIGO'), oVQE:GetValue('VQD_VALCON') } )
	//EndIf

	//oLbVConf:Refresh()
	//VA380VQEUPDTOT()
Return .T.

/*/{Protheus.doc} FS_3Valores

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Mostrará detalhes da configuração de um veículo

/*/
Static Function FS_3Valores()
Return  { || IIF(LEN(oLbVConf:aArray) < oLbVConf:nAt, {"", "", "", ""},;
			{ ;
				IIF(FS_TIKVQE(oLbVConf:aArray[oLbVConf:nAt]:GetValue('VQE_CODIGO')), oTik, oNaoTik),;
				oLbVConf:aArray[oLbVConf:nAt]:GetValue('VQC_DESCRI'),;
				oLbVConf:aArray[oLbVConf:nAt]:GetValue('VQD_DESCRI'),;
				FG_AlinVlrs(Transform( oLbVConf:aArray[oLbVConf:nAt]:GetValue('VQD_VALCON') , "@E 999,999,999.99")) ;
			});
		}

/*/{Protheus.doc} FS_TIKVQE

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Retorna .T. ou .F. em caso de VQE tikado ou não
	@return       Boolean , .T. ou .F.

/*/
Static Function FS_TIKVQE(cCodVQE)
// Todos devem mostrar ticados pois a tela é de consulta, porém caso seja 
// necessario no futuro está tudo funcionando normalmente com tik somando totais e etc...
Return .T. //ASCAN( aVQETicados, {|el| el[1] == cCodVQE} ) > 0 

/*/{Protheus.doc} FS_3HeaderClick

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Mostrará detalhes da configuração de um veículo

/*/
Static Function FS_3HeaderClick()
Return {|| {} }

/*/{Protheus.doc} FS_3Change

	@author       Vinicius Gati
	@since        21/11/2014
	@description  Evento change do grid de configurações

/*/
Static Function FS_3Change()
Return .T.

/*/{Protheus.doc} FS_BusConf

	@author       Vinicius Gati
	@since        24/11/2014
	@description  Busca configuração do veículo VQE e retorna os dados necessarios
	@param        cChaInt , Chassi interno do veículo

/*/
Static Function FS_BusConf(cChaInt)
	Local aCollection := {}
	Local cAlias      := Alias()
	Local cAliasQ     := GetNextAlias()
	Local cQuery      := ""

	cQuery := "    SELECT VQE_CODIGO, VQE_CODVQD, VQD_VALCON, VQD_DESCRI, VQC_DESCRI, VQD_VALCON, VQD_CODVQC "
 	cQuery += "      FROM "+ RetSqlName('VQE') +" VQE "
    cQuery += " LEFT JOIN "+ RetSqlName('VQD') +" VQD ON VQE.VQE_CODVQD = VQD.VQD_CODIGO   "
    cQuery += "       AND VQD.D_E_L_E_T_ = ' ' AND VQD.VQD_FILIAL = '"+ xFilial('VQD') +"' "
    cQuery += " LEFT JOIN "+ RetSqlName('VQC') +" VQC ON VQD.VQD_CODVQC = VQC.VQC_CODIGO   "
    cQuery += "       AND VQC.D_E_L_E_T_ = ' ' AND VQC.VQC_FILIAL = '"+ xFilial('VQC') +"' "
	cQuery += "     WHERE VQE.D_E_L_E_T_ = ' ' AND VQE.VQE_FILIAL = '"+ xFilial('VQE') +"' "
	cQuery += "       AND VQE.VQE_CHAINT = '" + cChaInt + "' "

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQ, .T., .T. )
	Do While !( cAliasQ )->( Eof() )
		oData := Mil_DataContainer():New({;
			{'VQE_CODIGO', ( cAliasQ )->VQE_CODIGO},;
			{'VQD_VALCON', ( cAliasQ )->VQD_VALCON},;
			{'VQD_DESCRI', ( cAliasQ )->VQD_DESCRI},;
			{'VQD_CODVQC', ( cAliasQ )->VQD_CODVQC},;
			{'VQE_CODVQD', ( cAliasQ )->VQE_CODVQD},;
			{'VQC_DESCRI', ( cAliasQ )->VQC_DESCRI} ;
		})
		AADD( aCollection, oData )
		( cAliasQ )->( DbSkip() )
	Enddo
	( cAliasQ )->( dbCloseArea() )

	If cAlias <> ""
		DBSelectArea(cAlias)
	EndIf
Return aCollection

/*/{Protheus.doc} FS_TUPDVQES

	@author       Vinicius Gati
	@since        25/11/2014
	@description  Busca configuração do veículo VQE e atualiza dados da tela de acordo com o resultado
					neste caso coloca as configurações como ticadas e atualiza totais
	@param        cChaInt , Chassi interno do veículo

/*/
Static Function FS_TUPDVQES(cChaInt)
	Local aRet  := FS_BusConf(cChaInt)
	Local nLoop := 1

	for nLoop := 1 to len(aRet)
		oData := aRet[nLoop]
		AADD( aVQETicados, { oData:GetValue('VQE_CODIGO'), oData:GetValue('VQD_VALCON') } ) // ao buscar todos entram selecionados(ticados)
	next

	VA380VQEUPDTOT()
Return aRet

/*/{Protheus.doc} VA380VQEUPDTOT

	@author       Vinicius Gati
	@since        24/11/2014
	@description  Busca configuração do veículo VQE
	@param        cChaInt , Chassi interno do veículo

/*/
Static Function VA380VQEUPDTOT()
	Local nSumConf := 0
	Local nLoop := 1
	for nLoop := 1 to Len(aVQETicados)
		aEl := aVQETicados[nLoop]
		nSumConf += aEl[2] // posição 2 = VQD_VALCON
	Next

	nGtVlrConf   := nSumConf
	nGtVlrSugVen := nGtVlrConf + nGtVlrTabela

	oGtVlrTabela:Refresh()
	oGtVlrConf:Refresh()
	oGtVlrSugVen:Refresh()
Return nSumConf

/*/{Protheus.doc} VA380SelVei

	@author       Vinicius Gati
	@since        24/11/2014
	@description  Mantem tabela VV1 posicionada no veículo 
	@param        cChaInt , Chassi interno do veículo

/*/
Static Function VA380SelVei(cChaInt)
	DbSelectArea('VV1')
	dbSetOrder(1)
	VV1->(DbSeek( xFilial('VV1') + cChaInt ))
Return .T.

/*/{Protheus.doc} VA380VLRTAB

	@author       Vinicius Gati
	@since        1/12/2014
	@description  Verifica se veículo tem valor de tabela e o retorna , caso contrario retorna valor de venda. "valor tabela" mesmo que "ja teve configuracao" desse modo deve-se usar o valor deste campo
	@param        cChaInt , Chassi interno do veículo

/*/
Function VA380VLRTAB(cChaInt)
	Local nValTab := 0
	
	DbSelectArea('VV1')
	dbSetOrder(1)
	VV1->(DbSeek( xFilial('VV1') + cChaInt ))
	If ! Empty(VV1->VV1_VALTAB)
		nValTab := VV1->VV1_VALTAB
	Else
		nValTab := FGX_VLRSUGV(cChaInt)
	EndIf
Return nValTab

/*/{Protheus.doc} VA380RBSxe

	@author       Vinicius Gati
	@since        1/12/2014
	@description  Como não se sabe quantos xe foram usados na tela, ao cancelar ou rollback devemos extinguir todos para nao perder numeracao.

/*/
Static Function VA380RBSxe()
	local nLoop := 0
	for nLoop := 50 to 0 step -1
		ROLLBACKSXE()
	next
Return .T.

/*/{Protheus.doc} VA380CFSxe

	@author       Vinicius Gati
	@since        1/12/2014
	@description  confirma sxes

/*/
Static Function VA380CFSxe()
	local nLoop := 0
	for nLoop := 50 to 0 step -1
		ConfirmSX8()
	next
Return .T.

/*/{Protheus.doc} VA380VQCCanDel

	@author       Vinicius Gati
	@since        1/12/2014
	@description  Verifica se foi utilizado e não pode ser exluido retornando false

/*/
Function VA380VQCCanDel(cCodVQC)
	nCount := FM_SQL(" select count(*) from " +RetSqlName('VQD')+ " where VQD_FILIAL = '" +xFilial('VQD')+;
		"' AND D_E_L_E_T_ = ' ' AND VQD_CODVQC = '" + cCodVQC + "'")
Return nCount == 0

/*/{Protheus.doc} VA380VQDCanDel

	@author       Vinicius Gati
	@since        1/12/2014
	@description  Verifica se foi utilizado e não pode ser exluido retornando false

/*/
Function VA380VQDCanDel(cCodVQD)
	nCount := FM_SQL(" select count(*) from " +RetSqlName('VQE')+ " where VQE_FILIAL = '" +xFilial('VQE')+;
		"' AND D_E_L_E_T_ = ' ' AND VQE_CODVQD = '" + cCodVQD + "'")
Return nCount == 0

/*/{Protheus.doc} VA380StrConf

	@author       Vinicius Gati
	@since        19/12/2014
	@description  Retorna configuração do veículo em string, utilizado para mostrar em telas e para gravar os campos da configuracao no VV1 e VQ0

/*/
Function VA380StrConf(cConf, cChaInt)
	Local aHlp    := Mil_ArrayHelper():New()
	Local aCfgVei := FS_BusConf(cChaInt)

	If LEN(aCfgVei) > 0
		aCfgVei := aHlp:Map(aCfgVei, {|oEl| ALLTRIM(oEl:GetValue('VQD_DESCRI')) }) // retorna: {'VQD_DESCRI','VQD_DESCRI','VQD_DESCRI','VQD_DESCRI'}
		Return aHlp:Join(aCfgVei, ', ') // retorna: "VQD_DESCRI, VQD_DESCRI, VQD_DESCRI"
	EndIf
Return cConf // senao retorna cfg basica

/*/{Protheus.doc} VA380011_ValidaVJV

	@author       Andre Luis Almeida
	@since        30/06/2021
	@description  Valida campo de codigo do VIV e preenche demais dados

/*/
Function VA380011_ValidaVJV()
	Local lRet := .t.
	If !Empty(M->VQD_CODVJV)
		lRet := VA380041_Posicionamento_VJU( M->VQD_CODVJV , n )
		If lRet
			M->VQD_BASCOD := VJU->VJU_BASECD
			M->VQD_CODOPC := VJV->VJV_CODOPC
		EndIf
	EndIf
	If !lRet .or. Empty(M->VQD_CODVJV)
		M->VQD_BASCOD := ""
		M->VQD_CODOPC := ""
	EndIf
	aCols[n,FG_POSVAR('VQD_BASCOD')] := M->VQD_BASCOD
	aCols[n,FG_POSVAR('VQD_CODOPC')] := M->VQD_CODOPC
Return lRet

/*/{Protheus.doc} VA380021_F3_VJV

	@author       Andre Luis Almeida
	@since        30/06/2021
	@description  F3 do campo de codigo do VIV

/*/
Function VA380021_F3_VJV()
	Local lRet      := .f.
	Local aSize     := FWGetDialogSize( oMainWnd )
	Local cFiltro   := ""
	Private aRotina := {}

	dbSelectArea("VJV")
	oF3Opc := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0020 , , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Opcionais

	cFiltro := "@ EXISTS ( "
	cFiltro += " SELECT VJU.VJU_CODIGO "
	cFiltro += " FROM " + RetSqlName('VJU') + " VJU "
	cFiltro += " WHERE VJU.VJU_FILIAL = VJV_FILIAL "
	cFiltro += " AND VJU.VJU_CODIGO = VJV_CODVJU "
	cFiltro += " AND VJU.VJU_CODMAR = '"+M->VQC_CODMAR+"'"
	cFiltro += " AND VJU.VJU_GRUMOD = '"+M->VQC_GRUMOD+"'"
	cFiltro += " AND VJU.VJU_MODVEI = '"+M->VQC_MODVEI+"'"
	cFiltro += " AND VJU.VJU_SEGMOD = '"+M->VQC_SEGMOD+"'"
	cFiltro += " AND VJU.D_E_L_E_T_ = ' '"
	cFiltro += ")"

	oBrwOpc := FWMBrowse():New()
	oBrwOpc:SetOwner(oF3Opc)
	oBrwOpc:SetDescription(STR0020) // Opcionais
	oBrwOpc:SetAlias("VJV")
	oBrwOpc:SetFilterDefault( cFiltro )
	oBrwOpc:SetUseFilter()
	oBrwOpc:SetMenuDef("") 
	oBrwOpc:SetDoubleClick( {|| lRet := .t. , oF3Opc:End() } )
	oBrwOpc:AddButton("OK", {|| lRet := .t. , oF3Opc:End() },,2,2)
	oBrwOpc:DisableDetails()
	oBrwOpc:SetAmbiente(.F.)
	oBrwOpc:SetWalkthru(.F.)
	oBrwOpc:ForceQuitButton(.T.)
	oBrwOpc:Activate()
	
	oF3Opc:Activate( , , , , , , ) //ativa a janela

Return lRet

/*/{Protheus.doc} VA380031_Valida_MarcaModelo

	@author       Andre Luis Almeida
	@since        30/06/2021
	@description  Validacao dos VQD

/*/
Static Function VA380031_Valida_MarcaModelo()
Local lRet := .t.
Local nCntFor := 0
For nCntFor := 1 to Len(aCols)
	If !aCols[nCntFor,len(aHeader)+1] // Não esta Deletado
		If aCols[nCntFor, FG_POSVAR('VQD_DIGIMP')] <> "1" .and. !Empty(aCols[nCntFor, FG_POSVAR('VQD_CODVJV')]) // Foi Digitado pelo usuario e possui VQD_CODVJV
			lRet := VA380041_Posicionamento_VJU( aCols[nCntFor, FG_POSVAR('VQD_CODVJV')] , nCntFor )
			If !lRet
				Exit
			EndIf
		EndIf
	EndIf
Next
Return lRet

/*/{Protheus.doc} VA380041_Posicionamento_VJU

	@author       Andre Luis Almeida
	@since        30/06/2021
	@description  Valida Posicionamento no VJU

/*/
Static Function VA380041_Posicionamento_VJU( cCodVJV , nLinha )
Local lRet := .f.
DbSelectArea("VJV")
DbSetOrder(1)
If DbSeek( xFilial("VJV")+cCodVJV)
	DbSelectArea("VJU")
	DbSetOrder(1)
	If DbSeek( xFilial("VJU")+VJV->VJV_CODVJU) .and. M->VQC_CODMAR+M->VQC_GRUMOD+M->VQC_MODVEI+M->VQC_SEGMOD == VJU->VJU_CODMAR+VJU->VJU_GRUMOD+VJU->VJU_MODVEI+VJU->VJU_SEGMOD
		lRet := .t.
	EndIf
EndIf
If !lRet
	MsgStop(STR0021+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Marca/Modelo/Segmento não relacionado ao código informado!
		RetTitle("VQD_CODVJV")+": "+cCodVJV+" ( "+STR0022+": "+Alltrim(str(nLinha))+" )",STR0019) // linha / Atenção
EndIf
Return lRet