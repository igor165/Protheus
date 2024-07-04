#INCLUDE "JURA095.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "FWMVCDEF.CH"

//*******************************************************************************************
//Campos para montar o grupo de instancia, inclusão de campo NSZ_COD devido validação no SX9
//*******************************************************************************************
#DEFINE CAMPOSCAB 'NSZ_COD|NSZ_DCOMAR|NSZ_NUMPRO|NSZ_DLOC2N|NSZ_DLOC3N|NSZ_DNATUR|NSZ_DTIPAC|NSZ_PATIVO|NSZ_PPASSI|NSZ_DSITUA|NSZ_TIPOPR|'
#DEFINE CAMPOSSOC 'NSZ_COD|NSZ_PATIVO|NSZ_PPASSI|NSZ_DSITUA|'
#DEFINE CAMPOSCON 'NSZ_COD|NSZ_DSITUA|'	//Campos Consultivo que iram aparecer no agrupamento Resumo
//-------------------------------------------
//Cabeçalho dos perfis Contrato e Procurações
//-------------------------------------------

Static cGrpRest  := JurGrpRest()

Static aModelos  := {}   //Modelos do Model com um campo que deve estar preenchido para poder copiar os dados.
Static oModelANT := nil  //Modelo anterior para passagem dos valores para o modelo novo.
Static lCopiou   := .F.  //Controla o Setactive() do modelo para passa os dados do Modelo Anterior ao novo somente uma vez.

Static lXLiminar := .F.  //Variavel para controle de passagem de dados pela FwExecView().
Static cXStatus  := ''   //Variavel para inicializar o Status da liminar pela FwExecView().
Static cXObserv  := ''   //Variavel para inicializar a Observacao da liminar pela FwExecView().

Static lF3AssuJu := .F.	 //Define se foi chamado o F3 do assunto juridico

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA095
  Assuntos Juridicos

@author Romeu Calmon Braga Mendonça
@since 07/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA095(cProcesso)
	Local  oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0007)
	oBrowse:SetAlias( "NSZ" )
	oBrowse:SetLocate()
	oBrowse:DisableDetails()
	oBrowse:SetCacheView(.F.)
	JurSetLeg( oBrowse, "NSZ" )

	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Romeu Calmon Braga Mendonça
@since 07/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA095", 0, 2, 0, NIL } ) // "Visualizar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA095", 0, 3, 0, NIL } ) // "Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA095", 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA095", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Assuntos Juridicos

@author Romeu Calmon Braga Mendonça
@since 07/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local aArea      := GetArea()
Local aAreaNT9   := NT9->(GetArea())
Local aBotoes    := {}
Local alCampos   := {} //Lista de campos que devem ser exibidos na tela.
Local aModActi   := {}
Local oModel     := FWLoadModel( "JURA095" )
Local oView      := Nil
Local oStructNT9 := Nil //Envolvidos
Local oStructNUQ := Nil //Instância
Local oStructNXY := Nil //Aditivos
Local oStructNYJ := Nil //Unidades
Local oStructNYP := Nil //Negociações
Local oStructO05 := Nil //Causa Raizes
Local oStruct    := Nil //Dados principais
Local oModelSAVE := Nil
Local lChgAll    := .F.
Local lNUQ       := .T. // Indica se o Model NUQ está sendo usado, pois caso não esteja configurado nas guias dos assuntos jurídicos não será usado
Local lNT9       := .T. // Indica se o Model NT9 está sendo usado, pois caso não esteja configurado nas guias dos assuntos jurídicos não será usado
Local lNXY       := .T. // Indica se o Model NXY está sendo usado, pois caso não esteja configurado nas guias dos assuntos jurídicos não será usado
Local lNYJ       := .T. // Indica se o Model NYJ está sendo usado, pois caso não esteja configurado nas guias dos assuntos jurídicos não será usado
Local lNYP       := .T.	// Indica se o Model NYP está sendo usado, pois caso não esteja configurado nas guias dos assuntos jurídicos não será usado
Local lO05       := .T.	// Indica se o Model O05 está sendo usado, pois caso não esteja configurado nas guias dos assuntos jurídicos não será usado
Local lCpoEnv    := .F. // Proteção dos fontes - Verifica se o campo de descrição do envolvido existe no dicionário
Local lMultiLim  := SuperGetMv("MV_JMULLIM", , .F.)				//Define se esta ativa a rotina de multi liminares
Local lIntegra   := SuperGetMV("MV_JFTJURI",, "2" ) == "1" //Indica se ha Integracao entre SIGAJURI e SIGAPFS (1=Sim;2=Nao)
Local cJVlProv   := JGetParTpa(cTipoASJ, "MV_JVLPROV", "1")		//Define de onde sera pego o valor da provisao 1 = Processo \ 2 = Objetos
Local cTitulo    := J162GtDscP()
Local cCabec     := ""
Local cTabLog    := ""
Local cTabs      := ""
Local nFlxCorres := SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"

	DbSelectArea("NT9")
	lCpoEnv := ColumnPos('NT9_DENTID') > 0

	lCopiou  := .F.  //Copiar do modelo antigo para o novo

	//Verifica se esta sendo aberto a partir da consulta padrao da tabela NSZ campo de assunto juridico
	If "_CAJURI" $ ReadVar() .Or. IsMemVar("NT2_CAJURI") .Or. IsMemVar("NT3_CAJURI") .Or. IsMemVar("NT4_CAJURI") .Or.;
			IsMemVar("NTA_CAJURI") .Or. IsMemVar("NUN_CAJURI") .Or. IsMemVar("NZG_CAJURI")
		Ja095F3Asj( .T. )
		//Verifica se ja entrou no modo edicao, caso isso tenha acontecido as variaveis ja estao carregadas
		//e no carregamento do modelo JURA095 fora da Pesquisa.
		If IsPesquisa() .Or. Type("cTipoAJ") == "U" .Or. Empty(cTipoAJ)
			cTipoAJ := JurSetTAS(.T.)
		EndIf
		cTipoAsJ   := cTipoAJ
		c162TipoAs := cTipoAJ
	EndIf

	//Se não for relacionado a nenhum assunto jurídico, todos os modelos são inicializados, sem restrição
	If Type("cTipoAsJ") == "U"
		cTabs := 'NUQ|NT9|NXY|NYJ|NYP'
		cTipoAsJ := 'CFG' //Indica que se trata da configuração de papeis de trabalho feitos pelo SIGACFG

		oStructNT9 := FWFormStruct( 2, "NT9" )
		oStructNUQ := FWFormStruct( 2, "NUQ" )
		oStructNXY := FWFormStruct( 2, "NXY" )
		oStructNYJ := FWFormStruct( 2, "NYJ" )
		oStructNYP := FWFormStruct( 2, "NYP" )
		If FWAliasInDic("O05")
			cTabs 	   += '|O05'
			oStructO05 := FWFormStruct(2, "O05")
		EndIf
		oStruct    := FWFormStruct( 2, "NSZ" )
	Else
		cTabs := JA095TabAj(cTipoAsJ)
	EndIf

	If Type("c162TipoAs") == "U"
		c162TipoAs := 'CFG'
	Else
		alCampos := {}
		alCampos := J95NuzCpo(cTipoAsJ,"NSZ")
		cCabec   := IIF(c162TipoAs $ "001/002/003/004/CFG", CAMPOSCAB, IIF(c162TipoAs == "005", CAMPOSCON, CAMPOSSOC))

		//Campo de quantidade de Incidentes
		If c162TipoAs $ "001/002/003/004/008"
			Aadd(alCampos, "NSZ_QTINCI")
		EndIf

		//Campos de quantidade Vinculados e Relacionados
		Aadd(alCampos, "NSZ_QTVINC")
		Aadd(alCampos, "NSZ_QTRELA")

		If lIntegra
			aAdd(alCampos,"NSZ_CESCRI")
		EndIf

		//carrega os dados principais da NSZ
		oStruct  := FWFormStruct( 2, "NSZ", { | cCampo | (x3Obrigat( cCampo ) .Or. AllTrim( cCampo ) $ cCabec .Or. aScan(alCampos,cCampo) > 0 ) } ) //Valida se o campo não está no resumo.
		aSize(alCampos,0)
	EndIf

	//Obtem o assunto pai para continuar as validações
	If c162TipoAs > '050' .And. c162TipoAs != 'CFG'
		c162TipoAs := JurGetDados('NYB', 1, xFilial('NYB') + c162TipoAs, 'NYB_CORIG')
	EndIf

	If !("NUQ" $ cTabs)
		lNUQ := .F.
	Else
		If oStructNUQ == Nil
			alCampos := {}
			alCampos := J95NuzCpo(cTipoAsJ,"NUQ")
			oStructNUQ := FWFormStruct( 2, "NUQ", { | cCampo | x3Obrigat(cCampo) .Or. aScan(alCampos,cCampo) > 0 } ) //Instância
			oStructNUQ:RemoveField( "NUQ_CAJURI" )
			JGetNmFld(oStructNUQ, cTipoAsJ, c162TipoAs)
			aSize(alCampos,0)
		Endif
	EndIf

	If !("NT9" $ cTabs)
		lNT9 := .F.
	Else
		If oStructNT9 == Nil
			alCampos := {}
			alCampos := J95NuzCpo(cTipoAsJ,"NT9")
			oStructNT9 := FWFormStruct( 2, "NT9", { | cCampo | x3Obrigat(cCampo) .Or. aScan(alCampos,cCampo) > 0 } ) //Envolvidos
			oStructNT9:RemoveField( "NT9_CAJURI" )
			JGetNmFld(oStructNT9, cTipoAsJ, c162TipoAs)
			aSize(alCampos,0)
		Endif
	EndIf

	If !("NXY" $ cTabs)
		lNXY := .F.
	Else
		If oStructNXY == Nil
			alCampos := {}
			alCampos := J95NuzCpo(cTipoAsJ,"NXY")
			oStructNXY := FWFormStruct( 2, "NXY", { | cCampo | x3Obrigat(cCampo) .Or. aScan(alCampos,cCampo) > 0 } ) //Aditivos
			oStructNXY:RemoveField( "NXY_CAJURI" )
			JGetNmFld(oStructNXY, cTipoAsJ, c162TipoAs)
			aSize(alCampos,0)
		Endif
	EndIf

	If !("NYJ" $ cTabs)
		lNYJ := .F.
	Else
		If oStructNYJ == Nil
			alCampos := {}
			alCampos := J95NuzCpo(cTipoAsJ,"NYJ")
			oStructNYJ := FWFormStruct( 2, "NYJ", { | cCampo | x3Obrigat(cCampo) .Or. aScan(alCampos,cCampo) > 0 } ) //Unidades
			oStructNYJ:RemoveField( "NYJ_CAJURI" )
			JGetNmFld(oStructNYJ, cTipoAsJ, c162TipoAs)
			aSize(alCampos,0)
		Endif
	EndIf

	If !("NYP" $ cTabs)
		lNYP := .F.
	Else
		if oStructNYP == Nil
			alCampos := {}
			alCampos := J95NuzCpo(cTipoAsJ,"NYP")
			oStructNYP := FWFormStruct( 2, "NYP", { | cCampo | x3Obrigat( PadR( cCampo, 10 ) ) .Or. aScan(alCampos,cCampo) > 0 } )  //Negociações
			oStructNYP:RemoveField( "NYP_CAJURI" )
			JGetNmFld(oStructNYP, cTipoAsJ, c162TipoAs)
			aSize(alCampos,0)
		Endif
	EndIf

	//Causas Raizes
	If !("O05" $ cTabs)
		lO05 := .F.
	Else
		If oStructO05 == Nil
			alCampos := {}
			alCampos := J95NuzCpo(cTipoAsJ, "O05")
			oStructO05 := FWFormStruct( 2, "O05", { | cCampo | x3Obrigat( PadR( cCampo, 10 ) ) .Or. aScan(alCampos,cCampo) > 0 } )
			oStructO05:RemoveField( "O05_CAJURI" )
			JGetNmFld(oStructO05, cTipoAsJ, c162TipoAs)
			aSize(alCampos,0)
		Endif
	EndIf

	oStruct:RemoveField( "NSZ_CPART1" )
	oStruct:RemoveField( "NSZ_CPART2" )
	oStruct:RemoveField( "NSZ_CPART3" )
	oStruct:RemoveField( "NSZ_CRESCO" )
	oStruct:RemoveField( "NSZ_CODRES" )
	oStruct:RemoveField( "NSZ_TIPOAS" )

	If SuperGetMV( 'MV_JFTJURI',, "2" ) == '2'// Se a integração SIGAJURI x SIGAPFS estiver desligada não exibe os campos de contratos
		If oStruct:HasField("NSZ_CCTFAT")
			oStruct:RemoveField( "NSZ_CCTFAT" )
		EndIf
		If oStruct:HasField("NSZ_DCTFAT")
			oStruct:RemoveField( "NSZ_DCTFAT" )
		EndIf
	EndIf

	//1 = Provisão pelo Valores do Processo
	If cJVlProv == "1"

		If oStruct:HasField("NSZ_VLPRPO")
			oStruct:RemoveField( "NSZ_VLPRPO" )
		EndIf

		If oStruct:HasField("NSZ_VLPPOA")
			oStruct:RemoveField( "NSZ_VLPPOA" )
		EndIf

		If oStruct:HasField("NSZ_VLPRRE")
			oStruct:RemoveField( "NSZ_VLPRRE" )
		EndIf

		If oStruct:HasField("NSZ_VLPREA")
			oStruct:RemoveField( "NSZ_VLPREA" )
		EndIf

		If oStruct:HasField("NSZ_VRDPOS")
			oStruct:RemoveField( "NSZ_VRDPOS" )
		EndIf

		If oStruct:HasField("NSZ_VRDREM")
			oStruct:RemoveField( "NSZ_VRDREM" )
		EndIf

	//2 = Provisão pelos Objetos
	Else
		//Deixa campos de valores envolvidos e provisão como visualizar
		J95CPONT9(oStruct, "NSZ_DTENVO")
		J95CPONT9(oStruct, "NSZ_CMOENV")
		J95CPONT9(oStruct, "NSZ_VLENVO")
		J95CPONT9(oStruct, "NSZ_DTPROV")
		J95CPONT9(oStruct, "NSZ_CMOPRO")
		J95CPONT9(oStruct, "NSZ_VLPROV")
	EndIf

	//Multiplas Liminares ativa
	If lMultiLim
		//Desabilita os campos de liminares
		J95CPONT9(oStruct, "NSZ_CSTATL")	//Status Liminar
		J95CPONT9(oStruct, "NSZ_DTINLI")	//Início Vigência da liminar
		J95CPONT9(oStruct, "NSZ_DTFILI")	//Fim Vigência da liminar
		J95CPONT9(oStruct, "NSZ_OBSLIV")	//Observações da liminar em vigor

		oStruct:RemoveField("NSZ_CSITUL")	//Situação Liminar
		oStruct:RemoveField("NSZ_OBSLIR")	//Observações do advogado da liminar
	EndIf

	//Título dos campos da NSZ
	JGetNmFld(oStruct, cTipoAsJ, c162TipoAs)

	//Ordena a posição dos campos da NSZ do agrupamento Valores
	J95PosCpVl(oStruct)

	// Move o DataRVE para o agrupapamento de encerramento
	If (c162TipoAs == "013" .And. oStruct:HasField("NSZ_DTEMIS"))
		oStruct:SetProperty( "NSZ_DTEMIS", MVC_VIEW_GROUP_NUMBER,"005") 
	EndIf

	If lNT9
		// campos são verificados para assuntos que não os possuem na tela
		If (oStructNT9:HasField( "NT9_DTPENV" ))
			oStructNT9:SetProperty( "NT9_DTPENV", MVC_VIEW_WIDTH, 120 )
		Endif
		If (oStructNT9:HasField( "NT9_CEMPCL" ))
			oStructNT9:SetProperty( "NT9_CEMPCL", MVC_VIEW_WIDTH, 70 )
		Endif
		If (oStructNT9:HasField( "NT9_LOJACL" ))
			oStructNT9:SetProperty( "NT9_LOJACL", MVC_VIEW_WIDTH, 70 )
		Endif
		If (oStructNT9:HasField( "NT9_NOME" ))
			oStructNT9:SetProperty( "NT9_NOME",   MVC_VIEW_WIDTH, 180 )
		Endif
		If lCpoEnv
			If (oStructNT9:HasField( "NT9_DENTID" ))
				oStructNT9:SetProperty( "NT9_DENTID", MVC_VIEW_WIDTH, 100 )
			Endif
		EndIf
	EndIf

	If lNUQ
		// campos são verificados para assuntos verficar se existem na tela
		If oStructNUQ:HasField('NUQ_CINSTP')
			oStructNUQ:RemoveField( 'NUQ_CINSTP' )
		EndIf
		If (oStructNUQ:HasField( "NUQ_COD" ))
			oStructNUQ:RemoveField( "NUQ_COD" )
		Endif
		If (oStructNUQ:HasField( "NUQ_INSATU" ))
			oStructNUQ:SetProperty( "NUQ_INSATU", MVC_VIEW_WIDTH, 40 )
		Endif
		If (oStructNUQ:HasField( "NUQ_INSTAN" ))
			oStructNUQ:SetProperty( "NUQ_INSTAN", MVC_VIEW_WIDTH, 40 )
		Endif
		If (oStructNUQ:HasField( "NUQ_NUMPRO" ))
			oStructNUQ:SetProperty( "NUQ_NUMPRO", MVC_VIEW_WIDTH, 150 )
		Endif
		If (oStructNUQ:HasField( "NUQ_NUMANT" ))
			oStructNUQ:SetProperty( "NUQ_NUMANT", MVC_VIEW_WIDTH, 150 )
		Endif
		If (oStructNUQ:HasField( "NUQ_CNATUR" ))
			oStructNUQ:SetProperty( "NUQ_CNATUR", MVC_VIEW_WIDTH, 100 )
		Endif
		If (oStructNUQ:HasField( "NUQ_DNATUR" ))
			oStructNUQ:SetProperty( "NUQ_DNATUR", MVC_VIEW_WIDTH, 150 )
		Endif
		If (oStructNUQ:HasField( "NUQ_CTIPAC" ))
			oStructNUQ:SetProperty( "NUQ_CTIPAC", MVC_VIEW_WIDTH, 100 )
		Endif
		If (oStructNUQ:HasField( "NUQ_DTIPAC" ))
			oStructNUQ:SetProperty( "NUQ_DTIPAC", MVC_VIEW_WIDTH, 150 )
		Endif
	EndIf

	//Faz as configurações dos envolvidos verificando se esta ativo o cadastro tabelado de envolvidos
	If lNT9
		J95EnvTab(oStructNT9)
	EndIf

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetContinuousForm()

	oView:AddField("JURA095_VIEW",oStruct,"NSZMASTER")
	oView:CreateHorizontalBox("MAIN", 50)
	oView:SetOwnerView( "JURA095_VIEW", "MAIN" )

	//Continuação da parte comum (Grids)
	If lNT9
		oView:AddGrid(  "JURA095_GRIDNT9", oStructNT9, "NT9DETAIL"  )
		oView:createHorizontalBox("BOX_NT9" ,200,,.T.)
		oView:SetOwnerView( "JURA095_GRIDNT9", "BOX_NT9"  )
		oView:EnableTitleView( "JURA095_GRIDNT9", IIF(c162TipoAs == '008', STR0129, STR0010) )//"Adm/Part. Acionária"  / "Envolvidos" ) )
	EndIf

	If lNUQ
		oView:AddGrid(  "JURA095_GRIDNUQ", oStructNUQ, "NUQDETAIL"  )
		oView:createHorizontalBox("BOX_NUQ" ,200,,.T.)
		oView:SetOwnerView( "JURA095_GRIDNUQ", "BOX_NUQ"  )
		oView:EnableTitleView( "JURA095_GRIDNUQ", STR0014 ) //"Instâncias"
	EndIf

	If lNYJ
		oView:AddGrid(  "JURA095_GRIDNYJ", oStructNYJ, "NYJDETAIL"  )
		oView:createHorizontalBox("BOX_NYJ" ,200,,.T.)
		oView:SetOwnerView( "JURA095_GRIDNYJ", "BOX_NYJ"  )
		oView:EnableTitleView( "JURA095_GRIDNYJ", STR0130 ) //"Unidades"
	EndIf

	If lNYP
		oView:AddGrid( "JURA095_GRIDNYP", oStructNYP, "NYPDETAIL"  )
		oView:createHorizontalBox("BOX_NYP" ,200,,.T.)
		oView:SetOwnerView( "JURA095_GRIDNYP", "BOX_NYP"  )
		oView:EnableTitleView( "JURA095_GRIDNYP", STR0205 )  //"Negociações"
	EndIf

	If lNXY
		oView:AddGrid(  "JURA095_GRIDNXY", oStructNXY, "NXYDETAIL"  )
		oView:createHorizontalBox("BOX_NXY" ,200,,.T.)
		oView:SetOwnerView( "JURA095_GRIDNXY", "BOX_NXY"  )
		oView:EnableTitleView( "JURA095_GRIDNXY", STR0128 ) // "Aditivos"
		oView:AddIncrementField( 'JURA095_GRIDNXY', 'NXY_COD' )
	EndIf

	If lO05
		oView:AddGrid( "JURA095_GRIDO05", oStructO05, "O05DETAIL"  )
		oView:createHorizontalBox("BOX_O05" ,200,,.T.)
		oView:SetOwnerView( "JURA095_GRIDO05", "BOX_O05"  )
		oView:EnableTitleView( "JURA095_GRIDO05", STR0275 )  //"Causas Raizes"
	EndIf

	// Verificação do Titulo da Tela
	if (Empty(cTitulo))
		cTitulo := STR0007
	Endif

	oView:SetDescription(cTitulo) // "Assuntos Juridicos"

	If Existblock( 'JA95RETBOT' )
		aBotoes := Execblock('JA95RETBOT', .F., .F.)
	EndIf

	//Verifica se esta sendo aberto a partir da consulta padrao da tabela NSZ
	If !Ja095F3Asj()

		if c162TipoAs $ "001/002/003/004/008"
			If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT01"} ) <= 0 ) ) .And. JA162AcRst('01')

				oView:AddUserButton( STR0040, "APTIMG32", { | oView, oBotao |;
				MenuPop(FwFldGet('NSZ_FILIAL'), FwFldGet('NSZ_CPRORI'), FwFldGet('NSZ_COD'), oView, c162TipoAs, oBotao)})

			EndIf
		Endif //"Incidentes"

		If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT02"} ) <= 0 ) ) .And. JA162AcRst('02') .And. NSZ->NSZ_TIPOAS <> '08'
			oView:AddUserButton( STR0064, "GACIMG32", { | oView | oModelSAVE := FWModelActive(), JA095Tela(FwFldGet('NSZ_FILIAL'),;
			FwFldGet('NSZ_COD'),'2',c162TipoAs), FWModelActive(oModelSAVE),oView:Refresh()} )
		EndIf	//"Vinculados"

		If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT03"} ) <= 0 ) ) .And. JA162AcRst('03')
			oView:AddUserButton( STR0016, "CLIPS",    { | oView |IIF( J95AcesBtn(), MenuAnexos(oModel), FWModelActive()) } ,,,,.T.)
		EndIf //"Anexos"

		If  !IsInCallStack('JURA100TOK')
			If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT04"} ) <= 0 ) ) .And. JA162AcRst('04')
				oView:AddUserButton( STR0015, "PCOIMG32",{ |oView| IIF(J95AcesBtn(), (oModelSAVE := FWModelActive(), JCall100(FwFldGet('NSZ_COD'),lChgAll,;
				@oModelSAVE,aModelos,oModel:GetOperation()), FWModelActive(oModelSAVE)),)},,,,.T.)
			EndIf //"Andamentos"
		EndIf

		If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT05"} ) <= 0 ) ) .And. JA162AcRst('05')
			oView:AddUserButton( STR0030, "AGENDA",   { | oView | IIF(J95AcesBtn(), (oModelSAVE := FWModelActive(), JCall106(FwFldGet('NSZ_COD'),lChgAll,oModel:GetOperation()), FWModelActive(oModelSAVE)),)},,,,.T.)
		EndIf //"Follow-ups"

		if c162TipoAs $ "008"
			If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT12"} ) <= 0 ) ) .And. JA162AcRst('15') .And. 'MATRIZ' $ cGrpRest
		// ANALISAR A HIPOTESE DE ADICIONAR A FUNÇÃO J95AcessBtn()
				oView:AddUserButton( STR0132, "GACIMG32", { | oView | oModelSAVE := FWModelActive(), JCall124(FwFldGet('NSZ_COD'),lChgAll), FWModelActive(oModelSAVE)} )
			EndIf
		Endif	//"Concessões"

		If c162TipoAs $ "001/002/003/004"
			If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT06"} ) <= 0 ) ) .And. JA162AcRst('06')
				oView:AddUserButton( STR0031, "BUDGET",   { | oView | IIF(J95AcesBtn(), (oModelSAVE := FWModelActive(), JCall094(FwFldGet('NSZ_COD'),oModelSAVE,/*nAtualiza*/,oModel:GetOperation(),lChgAll), FWModelActive(oModelSAVE)),)})
			EndIf //"Objetos"

			If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT07"} ) <= 0 ) ) .And. JA162AcRst('07')
				oView:AddUserButton( STR0032, "COMPTITL", { | oView | IIF(J95AcesBtn(), (oModelSAVE := FWModelActive(), JCall098(FwFldGet('NSZ_COD'),oModel:GetOperation(),FwFldGet('NSZ_FILIAL'),lChgAll), FWModelActive(oModelSAVE)),) } ,,,,.T.)
			EndIf //"Garantias"

			If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT09"} ) <= 0 ) ) .And. JA162AcRst('09') .And. lNUQ .And. nFlxCorres == 2

				oView:AddUserButton( STR0034, "ESTIMG32", { | oView | IIF(J95AcesBtn(), (oModelSAVE := FWModelActive(), IIF(JA183Cont(FwFldGet('NSZ_COD'), ;
					FwFldGet('NUQ_COD'), FwFldGet('NUQ_CCORRE')), JCall088(FwFldGet('NSZ_COD'), FwFldGet('NUQ_INSTAN'), FwFldGet('NUQ_CCORRE'), ;
					FwFldGet('NUQ_LCORRE'),,,,oModel:GetOperation(), lChgAll),),FWModelActive(oModelSAVE)),)})
			EndIf //"Contr.Corr"

			If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT10"} ) <= 0 ) ) .And. JA162AcRst('10') .AND. SuperGetMV("MV_JFTJURI",, "2" ) == "1"
				oView:AddUserButton( STR0077, "ALT_CAD",  { | oView | IIF(J95AcesBtn(), (MenuFatura()),)} )
			EndIf //"Faturamento"
		Endif

		If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT11"} ) <= 0 ) ) .And. JA162AcRst('11')
			oView:AddUserButton( STR0101,"CTBREPLA", { | oView | IIF(J95AcesBtn(), (J095MenuHist(oView)),)})
		Endif //"Histórico"

		If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT13"} ) <= 0 ) ) .And. JA162AcRst('17')
			oView:AddUserButton( STR0142, "GACIMG32", { | oView | oModelSAVE := FWModelActive(), JA095Tela(FwFldGet('NSZ_FILIAL'), FwFldGet('NSZ_COD'),'3',c162TipoAs), FWModelActive(oModelSAVE),oView:Refresh()} )
		EndIf //"Relacionados"

		If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT15"} ) <= 0 ) ) .And. c162TipoAs $ "001/003"
			oView:AddUserButton( STR0284, "GACIMG32", { | oView | IIF(J95AcesBtn(), (oModelSAVE := FWModelActive(), JCall233(FwFldGet('NSZ_COD'), oModelSAVE), FWModelActive(oModelSAVE)),) } )
		EndIf //"e-Social"
		
		If FWAliasIndic("O11") .AND. (SuperGetMV('MV_JINTVAL',, '2') == '1') // Proteção da tabela Campos Contábeis Complementar
			If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT19"} ) <= 0 ) ) .And. c162TipoAs $ "001/003"
				oView:AddUserButton( STR0304, "", { | oView | IIF(J95AcesBtn(), (oModelSAVE := FWModelActive(), JCall275(FwFldGet('NSZ_COD'), oModelSAVE), FWModelActive(oModelSAVE)),)  } ) 
			EndIf // Campos Contábeis Compl.
		EndIf

		If FWAliasInDic('O0M') .And. FWAliasInDic("O0N")
			If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT16"} ) <= 0 ) ) .And. JA162AcRst('19')
				oView:AddUserButton( STR0285, "AGENDA",   { | oView | IIF(J95AcesBtn(), (oModelSAVE := FWModelActive(), JCall254(FwFldGet('NSZ_COD'),lChgAll,FwFldGet('NSZ_FILIAL')), FWModelActive(oModelSAVE)),)})
			EndIf //"Solicitação Docs"
		EndIf

		If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT14"} ) <= 0 ) )

			aModActi := {}
							//Modelo	, Grid
			Aadd(aModActi, {"NSZMASTER"	, .F.} )
			Aadd(aModActi, {"NT9DETAIL"	, .T.} )
			Aadd(aModActi, {"NUQDETAIL"	, .T.} )
			Aadd(aModActi, {"NYJDETAIL"	, .T.} )
			Aadd(aModActi, {"NXYDETAIL"	, .T.} )
			Aadd(aModActi, {"NYPDETAIL"	, .T.} )
			Aadd(aModActi, {"O05DETAIL"	, .T.} )

			oView:AddUserButton( STR0270, "GACIMG32", { |oView| oModelSAVE := FWModelActive(), IIF(oModelSAVE:GetOperation()<>3, Alert(STR0231),J095SvMod(oModelSAVE, aModActi, "1")) } )	//"Salvar modelo"
		EndIf //"Salvar modelo"

		If !Empty(c162TipoAs)

			If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT08"} ) <= 0 ) ) .And. JA162AcRst('08')
				oView:AddUserButton( STR0033, "LJPRECO",  { | oView | IIF(J95AcesBtn(), (oModelSAVE := FWModelActive(), JCall099(FwFldGet('NSZ_COD'), oModel:GetOperation(), lChgAll), FWModelActive(oModelSAVE)),) } )
			EndIf //"Despesas"
		EndIf

		If lMultiLim .And. c162TipoAs <> "006"
			If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT17"}) <= 0) ) .And. JA162AcRst('20')
				oView:AddUserButton( STR0287, "LJPRECO", { | oView | IIF(J95AcesBtn(), (oModelSAVE := FWModelActive(), JCall260(oModelSAVE, lChgAll), FWModelActive(oModelSAVE)),) } )
			EndIf //"Liminares"
		EndIf

		If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT18"}) <= 0) )
			oView:AddUserButton(STR0299, "INICIAL", { | oView | oModelSAVE := FWModelActive(), JCall268(oModelSAVE)} )
		EndIf //"Carregar Inicial"

		If c162TipoAs $ "005/006" .And. SuperGetMV("MV_JFLUIGA", , "2") == "1"
			oView:AddUserButton( STR0290, "ANALITICO", { | oView | IIF(J95AcesBtn(), (oModelSAVE := FWModelActive(), J95HisFlu(FwFldGet('NSZ_FILIAL'), FwFldGet('NSZ_COD')), FWModelActive(oModelSAVE)),) } )
		EndIf //"Histórico Fluig"
		
		//-- Histórico de Alterações de Processos - Se tem Audit Trail Configurado ou se possui a tabela de log O0X
		If (Findfunction('TCObject')  .AND. TCObject( RetSqlName("NSZ") + "_TTAT_LOG"))	.AND. !(Upper(TcGetDb()) == 'POSTGRES')	
			cTabLog := RetSqlName("NSZ") + "_TTAT_LOG"
		ElseIf  FWAliasInDic("O0X")
			cTabLog := "O0X"			
		EndIf
		
		/* Não tratamos a tabela de Audit Trail com POSTGRES no momento, pois a gravação do dados no campo TTAT_UNQ possui problemas de concatenação  */
		If !Empty( cTabLog )
			oView:AddUserButton( STR0302, "HISTALTPROC",  { | oView | IIF(J95AcesBtn(), (oModelSAVE := FWModelActive(), JURA271( FwFldGet('NSZ_FILIAL'), FwFldGet('NSZ_COD'), cTabLog )), FWModelActive(oModelSAVE)), } ) //- "Histórico de Alterações de Processos"
		EndIf
	EndIf

	If Existblock( 'JA95VIEW' )
		ExecBlock( 'JA95VIEW', .F., .F., oView )
	EndIf

	If !Empty(cGrpRest)// .And. !('MATRIZ' $ cGrpRest)
		If !(JA162AcRst('14',3) .Or. JA162AcRst('14',4) .Or. JA162AcRst('14',5))
			oView:SetViewProperty("*","DISABLELOOKUP")
		EndIf
	Endif

	RestArea( aAreaNT9 )
	RestArea( aArea )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Assuntos Juridicos
@author Romeu Calmon Braga Mendonça
@since 07/07/09
@version 1.0
@obs NSZMASTER - Dados do Assuntos Juridicos
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local aArea      := GetArea()
	Local lTLegal    := JModRst()
	Local oModel     := NIL
	Local oStruct    := FWFormStruct( 1, "NSZ",,,!lTLegal)
	Local oStructNT9 := NIL //Envolvidos
	Local oStructNUQ := NIL //Instâncias
	Local oStructNXY := NIL //Aditivos
	Local oStructNYJ := NIL //Unidades
	Local oStructNYP := NIL //Negociações
	Local oStructO05 := NIL //Causa Raiz


	//*********************************************************************************************
	// Inclusão apenas no model para apagar os registros relacionados ao excluir o registro da NSZ
	//*********************************************************************************************/
	Local cTabs      := ''
	Local lNUQ       := .T. // Indica se o Model NUQ está sendo usado, pois caso não esteja configurado nas guias dos assuntos jurídicos não será usado
	Local lNT9       := .T. // Indica se o Model NT9 está sendo usado, pois caso não esteja configurado nas guias dos assuntos jurídicos não será usado
	Local lNXY       := .T. // Indica se o Model NXY está sendo usado, pois caso não esteja configurado nas guias dos assuntos jurídicos não será usado
	Local lNYJ       := .T. // Indica se o Model NXJ está sendo usado, pois caso não esteja configurado nas guias dos assuntos jurídicos não será usado
	Local lNYP       := .T. // Indica se o Model NXP está sendo usado, pois caso não esteja configurado nas guias dos assuntos jurídicos não será usado
	Local lO05       := .T. // Indica se o Model NXP está sendo usado, pois caso não esteja configurado nas guias dos assuntos jurídicos não será usado

	Local lCpoRateio := .T. // Proteção dos fontes - Verifica se os campos usados para auditoria existem no dicionárioIF JModRst() .AND. !JShowVirtual()
	Local lNUZObrig  := .F.
	
	// Verifica se a coluna NUZ_OBRIGA existe na estrutura da NUZ
	DbSelectArea("NUZ")
	lNUZObrig := NUZ->(ColumnPos("NUZ_OBRIGA"))
	IF lTLegal
		TLegalStruc('NSZ',oStruct)
	Endif

	//Campo utilizado no modelo de processos.
	oStruct:AddField( ;
		""               , ;               // [01] Titulo do campo
	""		          , ;               // [02] ToolTip do campo
	"NSZ__CMOD"      , ;               // [03] Id do Field
	"C"              , ;               // [04] Tipo do campo
	6                , ;               // [05] Tamanho do campo
	0                , ;               // [06] Decimal do campo
	, ; 									// [07] Code-block de validação do campo
	, ;                                // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.              )                 // [10] Indica se o campo tem preenchimento obrigatório   ]

	//Campo utilizado para armazenar o caminho do arquivo da inicial em pdf para gravar na NUM
	oStruct:AddField( ;
		""               , ;               // [01] Titulo do campo
		""		         , ;               // [02] ToolTip do campo
		"NSZ__DIRPDF"    , ;               // [03] Id do Field
		"C"              , ;               // [04] Tipo do campo
		200              , ;               // [05] Tamanho do campo
		0                , ;               // [06] Decimal do campo
		                 , ;               // [07] Code-block de validação do campo
		                 , ;               // [08] Code-block de validação When do campo
		                 , ;               // [09] Lista de valores permitido do campo
		.F.              )                 // [10] Indica se o campo tem preenchimento obrigatório   ]

	oModelANT   := FwModelActive(,.T.)  //Obtem o ultimo modelo ativo, qdo vem do JURA100 pode ser o primeiro Modelo do JURA095.

	If  (ValType(oModelANT) != 'O') .Or. (oModelANT:cID != "JURA095") .Or. IsInCallStack("JA095Tela") .Or. !IsInCallStack("JURA100TOK")
		oModelANT := nil  //Se nao for o modelo do JURA095 anterior anula o modelo ou se a janela de vinculados/relacionados ou incidentes estiver aberta.
	EndIf

	//Verifica se esta sendo aberto a partir da consulta padrao da tabela NSZ campo de assunto juridico
	If !IsInCallStack("JA106ConfNZK") .And.;
			(	"_CAJURI" $ ReadVar() .Or. IsMemVar("NT2_CAJURI") .Or. IsMemVar("NT3_CAJURI") .Or. IsMemVar("NT4_CAJURI") .Or.;
			IsMemVar("NTA_CAJURI") .Or. IsMemVar("NUN_CAJURI") .Or. IsMemVar("NZG_CAJURI")	)

		Ja095F3Asj( .T. )

  		//Verifica se ja entrou no modo edicao, caso isso tenha acontecido as variaveis ja estao carregadas
  		//e no carregamento do modelo JURA095 fora da Pesquisa.
		If IsPesquisa() .Or. Type("cTipoAJ") == "U" .Or. Empty(cTipoAJ)
			cTipoAJ := JurSetTAS(.T.)
		EndIf
		cTipoAsJ	:= cTipoAJ
		c162TipoAs	:= cTipoAJ
	EndIf

	If Type("cTipoAsJ") == "U"

		cTabs := 'NUQ|NT9|NXY|NYJ|NYP'
		If FWAliasInDic("O05")
			cTabs += '|O05'
		EndIf

		cTipoAsJ   := 'CFG' //Indica que se trata da configuração de papeis de trabalho feitos pelo SIGACFG
		c162TipoAs := 'CFG'
	Else
		cTabs := JA095TabAj(cTipoAsJ)
	EndIf
	
	If lNUZObrig
		oStruct := defObriga("NSZ",oStruct)
	Endif

	lNUQ  := "NUQ" $ cTabs
	lNT9  := "NT9" $ cTabs
	lNXY  := "NXY" $ cTabs
	lNYJ  := "NYJ" $ cTabs
	lNYP  := "NYP" $ cTabs
	lO05  := "O05" $ cTabs
	
	lCpoRateio := lNT9

	If (lTLegal .or. lNUQ ) .and. oStructNUQ == Nil
		oStructNUQ := FWFormStruct( 1, "NUQ" ,,,!lTLegal)
		TLegalStruc('NUQ',oStructNUQ)
		
		oStructNUQ:RemoveField( "NUQ_CAJURI" )

		//-- Se o preenchimento de Foro e Vara NÃO forem obrigatórios - Verifica parametro na NZ6
		If JGetParTpa(cTipoAsJ, 'MV_JFORVAR','1') == '2'
			oStructNUQ:SetProperty("NUQ_CLOC2N",MODEL_FIELD_OBRIGAT,.F.)
			oStructNUQ:SetProperty("NUQ_CLOC3N",MODEL_FIELD_OBRIGAT,.F.)
			oStructNUQ:SetProperty("NUQ_DLOC2N",MODEL_FIELD_OBRIGAT,.F.)
			oStructNUQ:SetProperty("NUQ_DLOC3N",MODEL_FIELD_OBRIGAT,.F.)
		EndIf

		If lNUZObrig
			oStructNUQ := defObriga("NUQ",oStructNUQ)
		EndIf
	EndIf
	
	If (lTLegal .or. lNT9) .and. oStructNT9 == Nil
		oStructNT9 := FWFormStruct( 1, "NT9",,,!lTLegal )
		TLegalStruc('NT9',oStructNT9)

		oStructNT9:RemoveField( "NT9_CAJURI" )
		
		If lNUZObrig
			oStructNT9 := defObriga("NT9",oStructNT9)
		EndIf
	EndIf

	If (lTLegal .or. lNXY) .and. oStructNXY == Nil
		oStructNXY := FWFormStruct( 1, "NXY",,,!lTLegal )
		oStructNXY:RemoveField( "NXY_CAJURI" )
		If lNUZObrig
			oStructNXY := defObriga("NXY",oStructNXY)
		EndIf
	EndIf

	If (lTLegal .or. lNYJ) .and. oStructNYJ == Nil
		oStructNYJ := FWFormStruct( 1, "NYJ",,,!lTLegal )
		oStructNYJ:RemoveField( "NYJ_CAJURI" )
		
		If lNUZObrig
			oStructNYJ := defObriga("NYJ",oStructNYJ)
		EndIf
	EndIf

	If (lTLegal .or. lNYP) .and. oStructNYP == Nil
		oStructNYP := FWFormStruct( 1, "NYP",,,!lTLegal )
		oStructNYP:RemoveField( "NYP_CAJURI" )
		If lNUZObrig
			oStructNYP := defObriga("NYP",oStructNYP)
		EndIf
	EndIf

	If (lTLegal .or. lO05) .and. oStructO05 == Nil
		oStructO05 := FWFormStruct( 1, "O05",,,!lTLegal )
		oStructO05:RemoveField( "O05_CAJURI" )
		If lNUZObrig
			oStructO05 := defObriga("O05",oStructO05)
		EndIf
	EndIf

	If c162TipoAs > '050' .And. c162TipoAs != 'CFG'
		c162TipoAs := JurGetDados('NYB', 1, xFilial('NYB') + c162TipoAs, 'NYB_CORIG')
	EndIf

	If SuperGetMV("MV_JFTJURI",, "2" ) == "1" //Indica se ha Integracao entre SIGAJURI e SIGAPFS (1=Sim;2=Nao)
		oStruct:SetProperty("NSZ_CESCRI",MODEL_FIELD_OBRIGAT,.T.)
	EndIf


	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA095", /*Pre-Validacao*/, {|oX| JURA095TOK(oX, lNUQ, lNT9, lNXY, lNYJ, lNYP)}/*Pos-Validacao*/, {|oX| JA095CMT(oX, lCpoRateio, lNUQ)}/*Commit*/, /*Cancel*/)
	oModel:AddFields( "NSZMASTER", NIL, oStruct , /*Pre-Validacao*/,/*Pos-Validacao*/ )

	//--------------------------------------
	//Estrutura para Contratos, Procurações e Societário
	//--------------------------------------
	JurSetRules( oModel, "NSZMASTER",, "NSZ" )

	aModelos := {}  //Ira obter os modelos utilizados pelo usuario para a passagem de valores do Modelo Anterior ao Modelo novo.

	If lTLegal .or. ( lNT9 .and. c162TipoAs != '005' )
		aadd(aModelos, {"NT9DETAIL","NT9_CEMPCL"})

		oModel:AddGrid( "NT9DETAIL", "NSZMASTER" /*cOwner*/, oStructNT9, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
		oModel:GetModel( "NT9DETAIL" ):SetUniqueLine( { "NT9_COD" } )
		oModel:SetRelation( "NT9DETAIL", { { "NT9_FILIAL", "XFILIAL('NT9')" }, { "NT9_CAJURI", "NSZ_COD" } }, NT9->( IndexKey( 1 ) ) )
		JurSetRules( oModel, "NT9DETAIL",, "NT9" )
		oModel:GetModel( "NT9DETAIL" ):SetDescription( If (c162TipoAs $ '008',STR0129 /*"Adm/Part. Acionária"*/,STR0010 /*"Envolvidos"*/) )
		If lTLegal
			oModel:SetOptional( "NT9DETAIL" , .T. )
		Endif
	EndIf

	If lTLegal .or. (lNUQ .and. !(c162TipoAs $ '005/006/007/010/011') )
		aadd(aModelos, {"NUQDETAIL", "NUQ_NUMPRO"})
		
		oModel:AddGrid( "NUQDETAIL", "NSZMASTER" /*cOwner*/, oStructNUQ, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
		oModel:GetModel( "NUQDETAIL" ):SetUniqueLine( { "NUQ_COD" } )
		oModel:SetRelation( "NUQDETAIL", { { "NUQ_FILIAL", "XFILIAL('NUQ')" }, { "NUQ_CAJURI", "NSZ_COD" } }, NUQ->( IndexKey( 1 ) ) )
		JurSetRules( oModel, "NUQDETAIL",, "NUQ" )
		oModel:GetModel( "NUQDETAIL" ):SetDescription( STR0097 ) // "Instâncias"
		If lTLegal
			oModel:SetOptional( "NUQDETAIL" , .T. )
		Endif
	EndIf

	If lTLegal .or. ( lNXY .and. !(c162TipoAs $ '005/007/008/009/011') )
		aadd(aModelos, {"NXYDETAIL", "NXY_ADITIV"})

		oModel:AddGrid( "NXYDETAIL", "NSZMASTER" /*cOwner*/, oStructNXY, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
		oModel:GetModel( "NXYDETAIL" ):SetUniqueLine( { "NXY_COD" } )
		oModel:SetRelation( "NXYDETAIL", { { "NXY_FILIAL", "XFILIAL('NXY')" }, { "NXY_CAJURI", "NSZ_COD" } }, NXY->( IndexKey( 1 ) ) )
		JurSetRules( oModel, "NXYDETAIL",, "NXY" )
		oModel:SetOptional( "NXYDETAIL" , .T. )
		oModel:GetModel( "NXYDETAIL" ):SetDescription( STR0128 ) // "Aditivo"
	EndIf

	If lTLegal .or. ( lNYJ .and. !(c162TipoAs $ '005/006/007/010/011') )
		aadd(aModelos, {"NYJDETAIL", "NYJ_UNIDAD"})

		oModel:AddGrid( "NYJDETAIL", "NSZMASTER" /*cOwner*/, oStructNYJ, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
		oModel:GetModel( "NYJDETAIL" ):SetUniqueLine( { "NYJ_COD" } )
		oModel:SetRelation( "NYJDETAIL", { { "NYJ_FILIAL", "XFILIAL('NYJ')" }, { "NYJ_CAJURI", "NSZ_COD" } }, NYJ->( IndexKey( 1 ) ) )
		oModel:SetOptional( "NYJDETAIL" , .T. )
		JurSetRules( oModel, "NYJDETAIL",, "NYJ" )

		oModel:GetModel( "NYJDETAIL" ):SetDescription( if(c162TipoAs $ '008/009' , STR0130,STR0097) ) // "Unidades" ## "Instâncias"
	EndIf

	If lTLegal .or. ( lNYP .and. !(c162TipoAs $ '005/006/007/008/009/010/011') )
		aadd(aModelos, {"NYPDETAIL", "NYP_DATA"})

		oModel:AddGrid( "NYPDETAIL", "NSZMASTER" /*cOwner*/, oStructNYP, /*bLinePre*/, {|oGridModel, nLinha| J95LPRONYP(oGridModel, nLinha)}/*bLinePost*/, /*bPre*/, /*bPost*/ )
		oModel:GetModel( "NYPDETAIL" ):SetDescription( STR0205 ) // "Negociações"
		oModel:GetModel( "NYPDETAIL" ):SetUniqueLine( { "NYP_COD" } )
		oModel:SetRelation( "NYPDETAIL", { { "NYP_FILIAL", "XFILIAL('NYP')" }, { "NYP_CAJURI", "NSZ_COD" } }, NYP->( IndexKey( 1 ) ) )
		oModel:SetOptional( "NYPDETAIL" , .T. )
		JurSetRules( oModel, "NYPDETAIL",, "NYP" )
	EndIf

	//Será incluindo em todos os assuntos jurídicos desde que esteja configurado
	If (lTLegal .or. lO05)
		aadd(aModelos, {"O05DETAIL", "O05_CCAUSA"})

		oModel:AddGrid( "O05DETAIL", "NSZMASTER" /*cOwner*/, oStructO05, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
		oModel:GetModel( "O05DETAIL" ):SetDescription( STR0275 ) // "Causas Raizes"
		oModel:GetModel( "O05DETAIL" ):SetUniqueLine( If(oStruct:HasField("O05_CCLACA"), { "O05_CCAUSA", "O05_CCLACA" } , { "O05_CCAUSA" } ))
		oModel:SetRelation( "O05DETAIL", { { "O05_FILIAL", "XFILIAL('O05')" }, { "O05_CAJURI", "NSZ_COD" } }, O05->( IndexKey( 1 ) ) )
		oModel:SetOptional( "O05DETAIL" , .T. )
		JurSetRules( oModel, "O05DETAIL",, "O05" )
	EndIf

	If c162TipoAs == '005'
		oModel:SetDescription( STR0114 )   //Consultivo
		oModel:GetModel( "NSZMASTER" ):SetDescription( STR0114 )
	ElseIf c162TipoAs == '006'
		oModel:SetDescription( STR0123 )   //Contratos
		oModel:GetModel( "NSZMASTER" ):SetDescription( STR0123 )
	ElseIf c162TipoAs == '007'
		oModel:SetDescription( STR0124 )  //Procurações
		oModel:GetModel( "NSZMASTER" ):SetDescription( STR0124 )
	ElseIf c162TipoAs == '008'
		oModel:SetDescription( STR0122 )  //Societário
		oModel:GetModel( "NSZMASTER" ):SetDescription( STR0122 )
	ElseIf c162TipoAs == '009'
		oModel:SetDescription( STR0123 )  //Ofícios
		oModel:GetModel( "NSZMASTER" ):SetDescription( STR0123 )
	ElseIf c162TipoAs == '010'
		oModel:SetDescription( STR0172 )  //Licitações
		oModel:GetModel( "NSZMASTER" ):SetDescription( STR0172 )
	ElseIf c162TipoAs == '011'
		oModel:SetDescription( STR0171 )  //Marcas e Patentes
		oModel:GetModel( "NSZMASTER" ):SetDescription( STR0171 )
	Else 
		oModel:SetDescription( STR0008 ) // "Modelo de Dados de Assuntos Juridicos"
		oModel:GetModel( "NSZMASTER" ):SetDescription( STR0009 ) // "Dados de Assuntos Juridicos"
	EndIf

	//Ponte de entrada de ficar ultimo após toda a montagem do model padrão
	If Existblock( 'JA95MOD' )
		ExecBlock( 'JA95MOD', .F., .F., oModel )
	EndIf

	oModel:SetActivate( {|o| J95ACTVMOD(o) .And. J95ACTVNYP(o, lNYP) } )

	// Log de Acesso LGPD
	If FindFunction( 'FWPDLogUser' )
		FWPDLogUser( 'JURA095()' )
	EndIf

	RestArea( aArea )

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} TLegalStruc
Função responsável por setar os campos virtuais no modelo quando vier do totvs legal
@type Static Function
@since 04/03/2022
@version 1.0
@param cTabela, string, tabela para ser manipulada
@param oStruct, object, Estrutura de campos
/*/
//------------------------------------------------------------------------------
Static Function TLegalStruc(cTabela,oStruct)
	Local lTLegal    := JModRst()
	
	If lTLegal
		DO CASE
			CASE cTabela == 'NSZ'
				addFldStruct(oStruct,"NSZ_DCASO")
				addFldStruct(oStruct,"NSZ_SIGLA1")
				addFldStruct(oStruct,"NSZ_SIGLA2")
				addFldStruct(oStruct,"NSZ_SIGLA3")
				addFldStruct(oStruct,"NSZ_DDPSOL")
				addFldStruct(oStruct,"NSZ_DFCORR")
				addFldStruct(oStruct,"NSZ_DCLIEN")
				addFldStruct(oStruct,"NSZ_DAREAJ")
				addFldStruct(oStruct,"NSZ_DPART1")
				addFldStruct(oStruct,"NSZ_DPART2")
				addFldStruct(oStruct,"NSZ_DPART3")
				addFldStruct(oStruct,"NSZ_DTPSOL")
				
			CASE cTabela == 'NT9'
				addFldStruct(oStruct,"NT9_DTPENV")

			CASE cTabela == 'NUQ'
				addFldStruct(oStruct,"NUQ_STATUS")
				addFldStruct(oStruct,"NUQ_DNATUR")
				addFldStruct(oStruct,"NUQ_DTIPAC")
				addFldStruct(oStruct,"NUQ_DCOMAR")
				addFldStruct(oStruct,"NUQ_DLOC2N")
				addFldStruct(oStruct,"NUQ_DLOC3N")
				addFldStruct(oStruct,"NUQ_DCORRE")
		ENDCASE
	EndIf

Return nil
//------------------------------------------------------------------------------
/* /{Protheus.doc} addFldStruct()
Função responsável por setar os campos na estrutura
@type Static Function
@author 
@since 04/03/2022
@version 1.0
@param oStruct, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function addFldStruct(oStruct,cField)
	oStruct:AddField(;
		FWX3Titulo(cField)                                                      , ; // [01] C Titulo do campo
		""                                                                      , ; // [02] C ToolTip do campo
		cField                                                                  , ; // [03] C identificador (ID) do Field
		TamSx3(cField)[3]                                                       , ; // [04] C Tipo do campo
		TamSx3(cField)[1]                                                       , ; // [05] N Tamanho do campo
		TamSx3(cField)[2]                                                       , ; // [06] N Decimal do campo
		FwBuildFeature(STRUCT_FEATURE_VALID,GetSx3Cache(cField,"X3_VALID") )    , ; // [07] B Code-block de validação do campo
		NIL                                                                     , ; // [08] B Code-block de validação When do campoz
		NIL                                                                     , ; // [09] A Lista de valores permitido do campo
		.F.                                                                     , ; // [10] L Indica se o campo tem preenchimento obrigatório
		FwBuildFeature(STRUCT_FEATURE_INIPAD,GetSx3Cache(cField,"X3_RELACAO") ) , ; // [11] B Code-block de inicializacao do campo
		.F.                                                                     , ; // [12] L Indica se trata de um campo chave
		.F.                                                                     , ; // [13] L Indica se o campo pode receber valor em uma operação de update.
		.T.                                                                     ;   // [14] L Indica se o campo é virtual
	)
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} J95IniVar1
Inicializa as variaveis da liminar para a funcao FwExecView
Uso geral.

@author Antonio Carlos Ferreira
@since 07/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95IniVar1(lLiminar, cStatus, cObserv)

	lXLiminar := lLiminar
	cXStatus  := cStatus
	cXObserv  := cObserv

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA095TOK
Valida informações ao salvar.
Uso no cadastro de Assunto Jurídico.

@param 	oModel  	Model a ser verificado
				lNUQ 			Indica se o Model NUQ está sendo usado, pois caso não
									esteja configurado nas guias dos assuntos jurídicos
									não será usado
				lNT9			Indica se o Model NT9 está sendo usado, pois caso não
									esteja configurado nas guias dos assuntos jurídicos
									não será usado
				lNXY			Indica se o Model NXY está sendo usado, pois caso não
									esteja configurado nas guias dos assuntos jurídicos
									não será usado
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 20/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA095TOK(oModel, lNUQ, lNT9, lNXY, lNYJ, lNYP)
Local lRet      := .T.
Local nOpc      := oModel:GetOperation()
Local oModelNUQ := oModel:GetModel('NUQDETAIL')
Local oModelNYP := oModel:GetModel('NYPDETAIL')
Local oModelNT9 := oModel:GetModel('NT9DETAIL')
Local cParam    := AllTrim( SuperGetMv('MV_JDOCUME',,'1'))
Local cTipo     := ''
Local nCt       := 0
Local nVz       := 0                          //Contador auxiliar, exemplo: qtas linhas de uma grid atendem uma determinada condicao.
Local dDataPrev := cTod('')
Local dDtAcordo := cTod('')
Local aArea     := GetArea()
Local aAreaNUQ  := NUQ->(GetArea()) // Tabela de Instâncias
Local aAreaNT9  := NT9->(GetArea()) // Tabela de Envolvidos
Local aAreaNXY  := NXY->(GetArea()) // Tabela de Aditivos
Local aAreaNYJ  := NYJ->(GetArea()) // Tabela de Aditivos
Local aAreaNSZ  := NSZ->(GetArea())
Local aAreaNQS  := NQS->(GetArea())
Local lAnoMesHist := (SuperGetMV('MV_JVLHIST',, '2') == '1')
Local lManual   := .F.
Local lEncerrar := .F.
Local lAchouNQI := .F.
Local cMotivo   := ""
Local oView     := nil
Local nFlxCorres:= SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"
Local lCpoCodWf := .F. // Proteção dos fontes - Verifica se o campo de Cod do Workflow existe no dicionário
Local lCpoTpApr := .F. // Proteção dos fontes - Verifica se o campo de Tipo de Aprovação existe no dicionário
Local lAltLote  := .F.
Local cIntegra  := SuperGetMV("MV_JFTJURI",, "2" ) //Indica se ha Integracao entre SIGAJURI e SIGAPFS (1=Sim;2=Nao)
Local cNYQTipo   := ""
Local nNYPValTot := 0
Local cNYQMoeda  := ""
Local lNYPAcordo := .F.
Local nGerDesNeg := SuperGetMV("MV_JGERDES")
Local cNYQData   := ""
Local cNSZ_COD   := ""
Local cProg      := ''
Local lRest      := IsInCallStack('PUT')
Local lWSTLegal  := JModRst()

	//Verifica se é alteracao em lote
	If IsInCallStack("OpAltLote")
		lAltLote := .T.
	EndIf

	DbSelectArea("NSZ")
	lCpoCodWf := ColumnPos('NSZ_CODWF') > 0
	DbSelectArea("NQS")
	lCpoTpApr := ColumnPos('NQS_TAPROV') > 0

	If  (Type("c162TipoAs") != "C") .Or. Empty(c162TipoAs)
		c162TipoAs := oModel:GetValue("NSZMASTER","NSZ_TIPOAS")
	EndIf

	If nOpc == 3 .Or. nOpc == 4    // Se for Inclusão ou Alteração

		If lRet
			lRet := JA095VlDt1() //Validação de data de vigência, para que não seja maior que a atual
		Endif

		// Verifica se Prognóstico selecionado possui o campo tipo preenchido
		If !JurAuto()
			If !Empty( oModel:GetValue("NSZMASTER","NSZ_CPROGN" )) .And. lRet
				If Empty(JurGetDados('NQ7', 1 , xFilial('NQ7') + oModel:GetValue("NSZMASTER","NSZ_CPROGN" ) , 'NQ7_TIPO'))
					JurMsgErro(STR0281,STR0282,STR0283) 
					/* 	STR0281 'O campo Tipo não esta preenchido no Cadastro do Prognóstico selecionado.'
						STR0282 'Cadastro de Prognóstico Incompleto'
						STR0283 'Acesse o Cadastro de Prognóstico e preencha o campo Tipo com um valor válido.'*/
					lRet:= .F.
				EndIf
			EndIf
		EndIf

		//Valida se o processo foi criado via Fluig e não deixa alterar o Status
		If lRet .AND. lCpoCodWf .AND. oModel:GetModel("NSZMASTER"):HasField("NSZ_CODWF") .AND. oModel:IsFieldUpdated("NSZMASTER","NSZ_SITUAC") .AND. !Empty(oModel:GetValue("NSZMASTER","NSZ_CODWF")) .And. !( IsInCallStack('MTJurEncerraAssJur') ) /*Origem nao é do Webservice Fluig*/
			if !J95WFEnd(oModel:GetValue("NSZMASTER","NSZ_CODWF")) //valida se o workflow não esta encerrado.
				JurMsgErro(STR0260)//"O status do processo não pode ser alterado, porque o processo está pendente no Fluig"
				lRet := .F.
			Endif
		EndIf


		//Limpar campos de valores atualizados quando o tipo de correção for modificado
		If nOpc == 4 .And. lRet // Alteração
			J095FCLMP(oModel:GetModel('NSZMASTER'),"NSZ")
		EndIf

		If lRet .And. (c162TipoAs $ '006\010') .And. lNXY
			lRet := JA095VlDt2(oModel)
		Endif

		If lRet
			lRet :=  J95CPgador()
		EndIf

		If nOpc == 4 .And. cIntegra == '1' .And. (oModel:IsFieldUpdated("NSZMASTER","NSZ_CCLIEN") .Or.;
			oModel:IsFieldUpdated("NSZMASTER","NSZ_LCLIEN") .Or. oModel:IsFieldUpdated("NSZMASTER","NSZ_NUMCAS")) .And.;
			!IsInCallStack('JURA063')
			JurMsgErro(STR0262) //"Alteração de Cliente, Loja e Num. caso só é permitida pela rotina de Remanejamento de Caso quando o SIGAJURI integra com o SIGAPFS, operação cancelada."
			lRet := .F.
		Endif

		If lRet .And. JA095CAut() .And. Empty(oModel:GetValue('NSZMASTER','NSZ_NUMCAS'))
			JurMsgErro(STR0083)			//"É necessário preenchimento do campo de número do caso, verificar"
			lRet := .F.
		Endif

		if lRet
			lRet := JA095VLD() //Validação de grupo, cliente, loja e caso
		Endif

		if lRet
			lRet := JURA95DTEN()
		Endif

		if lRet .And. !(c162TipoAs $ '005') .And. lNT9// Se não forem: Consultivou e Procurações
			lRet := JA105ENVOL() //Validação do grid de envolvidos
		Endif

		If lRet
			lRet := JURA95VCAU()
		EndIf

		If lRet
			lRet := JU95VGAR(oModel)	// Valida os campos Moeda e Valor da Garantia e Obra do grid Aditivo
		EndIf

		If lRet
			lRet := JURA95VPRO()
		EndIf

		If lRet
			lRet := JURA95VALOR()
		EndIf

		If lRet
			lRet := JURA95VHIS()
		EndIf

		If lRet .And. c162TipoAs == '008' //Validação campos de capital
			lRet :=	 JA095VCAPT()

			If lRet .And. lNYJ
				lRet := J095VLDTSC()
			Endif

		Endif

		//Validação Aba Unidades
		If lRet .And. lNYJ
			lRet := JURA95VUNI()
		Endif

		//Valida Correspondente
		If lRet .And. lNUQ .And. nOpc == 4 

			If ! VldCorresp(oModelNUQ)
				lRet := .F.
				JurMsgErro(STR0306,"JURA095", STR0307 ) //"Correspondente inválido para este assunto jurídico", "Verifique as restrições do correspondente escolhido"
			EndIf

		EndIf

		//Verifica se o Fluxo de correspondente é por Follow-up
		If lRet .And. nFlxCorres == 1

			//Valida correspondente na instancia
			If lNUQ
				For nCt := 1 To oModelNUQ:GetQtdLine()
					If (!oModelNUQ:IsDeleted(nCt) .And. nOpc == 3 .AND. (!Empty( oModelNUQ:GetValue('NUQ_CCORRE', nCt) ) .Or.;
							!Empty( oModelNUQ:GetValue('NUQ_LCORRE', nCt))));
							.OR.;
							(!oModelNUQ:IsDeleted(nCt) .AND. nOpc == 4 .AND. (oModelNUQ:IsFieldUpdate('NUQ_CCORRE') .OR. oModelNUQ:IsFieldUpdate('NUQ_LCORRE')))

						JurMsgErro(STR0232)		//"Fluxo de correspondente configurado para ser preenchido no Follow-up, verifique o parametro MV_JFLXCOR."
						lRet := .F.
						Exit
					EndIf
				Next nCt
			EndIf
		EndIf

		If lRet .And. !(c162TipoAs $ "005/006/007/010/011") .And. lNUQ// Se não for dos tipos: Consultivo, Contratos, Procurações
			dDataPrev := JURA95PRVT()

			If oModel:GetValue('NSZMASTER','NSZ_PRETER') <> dDataPrev
				lRet:= oModel:LoadValue('NSZMASTER','NSZ_PRETER', dDataPrev)
			EndIf

			If lRet
				lRet := JA183PRO(nOpc)		//Trava de numero de processo duplicado
			EndIf

			If lRet
				For nCt := 1 To oModelNUQ:GetQtdLine()
					If oModelNUQ:GetValue('NUQ_INSATU', nCt) == '1' .And. !oModelNUQ:IsDeleted(nCt)
						cTipo := JurGetDados('NQ1', 1 , xFilial('NQ1') + oModelNUQ:GetValue('NUQ_CNATUR', nCt) , 'NQ1_TIPO')
					//Gravação do campo de número do processo no campo da NSZ
						oModel:SetValue("NSZMASTER","NSZ_NUMPRO", SubStr(oModelNUQ:GetValue('NUQ_NUMPRO', nCt), 1, TamSX3("NSZ_NUMPRO")[1]) )
						Exit
					EndIf
				Next
			EndIf

			If lRet .And. !(c162TipoAs $ "009")
			//*******************************************************************
			//Verifica se o processo é um desdobramento, para bloqueio de campos
			//*******************************************************************
				If !Empty( FwFldGet('NSZ_CPRORI')) .And. SuperGetMV('MV_JBLQINC',, .T.) == .T.
					If !Empty(FwFldGet('NSZ_COBJET')) .Or. !Empty(FwFldGet('NSZ_CPROGN'))

						JurMsgErro(STR0023 + AllTrim(RetTitle('NSZ_COBJET'))+', '+AllTrim(RetTitle('NSZ_CPROGN')))		// "Este processo é um incidente, não preencher o(s) campo(s) "
						lRet:= .F.
					//se a natureza for recurso ou incidente, não deixar preencher o valor envolvido nem alterar o inestimável
					ElseIf cTipo == '2' .Or. cTipo == '3'

						If FwFldGet('NSZ_VLINES') == '1'
							JurMsgErro(STR0024+RetTitle('NSZ_VLINES'))		// "Este processo é um incidente, alterar o campo "
							lRet:= .F.
						ElseIf !Empty(FwFldGet('NSZ_VLENVO')) .Or. !Empty(FwFldGet('NSZ_DTENVO')) .Or. !Empty(FwFldGet('NSZ_CMOENV'))
							JurMsgErro(STR0023+AllTrim(RetTitle('NSZ_VLENVO'))+','+AllTrim(RetTitle('NSZ_DTENVO'))+','+AllTrim(RetTitle('NSZ_CMOENV')))
							lRet:= .F.
						EndIf
					EndIf

				// Termino da verificação se o processo é um desdobramento
				Endif
			Endif

			If lRet
			//****************************************************************************************************
			// Validar o valor envolvido quando o processo for principal ou, quando for desdobramento e de natureza
			// do tipo natureza
			//****************************************************************************************************
				If lRet .And. ( Empty( FwFldGet('NSZ_CPRORI') )	.Or. ( !Empty( FwFldGet('NSZ_CPRORI') ) .And. cTipo == '1') )
					lRet := JURA95VENV()
				EndIf
			EndIf

		//validação da aba instância
		//<--- Perfis que não possuem aba de instância:
		//<---  (05-Consultivo,06-Contratos,07-Procuracoes,08-Societario(apesar de ser NUQ como Unidades),10- Licitacoes, 11- Marcas e Patentes -->

			If lRet .And. lNUQ
				lRet := JUR183VINS()
			Endif

		//validação da aba de envolvidos
			If lRet .And. lNT9
				lRet := JUR105VNT9()
			Endif

		EndIf

		If lRet .And. !(c162TipoAs $ "005") .And. lNT9
			lRet := JURA105TOK(oModel) //Validação de envolvidos
		EndIf

		//Gravação dos campos de nomes dos envolvidos nos campos da NSZ
		If lRet .And. lNT9
			For nCt := 1 To oModelNT9:GetQtdLine()
				If oModelNT9:GetValue('NT9_PRINCI', nCt) == '1' .And. !oModelNT9:IsDeleted(nCt)
					If oModelNT9:GetValue('NT9_TIPOEN', nCt) == '1'
						oModel:SetValue("NSZMASTER","NSZ_PATIVO",oModelNT9:GetValue('NT9_NOME', nCt))
					ElseIf oModelNT9:GetValue('NT9_TIPOEN', nCt) == '2'
						oModel:SetValue("NSZMASTER","NSZ_PPASSI",oModelNT9:GetValue('NT9_NOME', nCt))
					EndIf
				EndIf
			Next
		EndIf

		//***********************************************************************
		// Verifica se alguma instância foi excluída para excluir os docs anexos
		//***********************************************************************
		If lRet .And. nOpc == 4 .And. !(c162TipoAs $ "005/006/007/010/011") .And. lNUQ
			For nCt := 1 To oModelNUQ:GetQtdLine()
				If oModelNUQ:IsDeleted(nCt)
					If cParam == '1'
						lRet := JurExcAnex('NUQ', oModelNUQ:GetValue("NUQ_COD", nCt))
					Else
						lRet := JurExcAnex('NUQ', oModelNUQ:GetValue("NUQ_COD", nCt), FwFldGet('NSZ_COD'),'2')
					EndIf
				EndIf
			Next
		EndIf

		//***********************************************************************
		// Verifica se o campo de complemento da localização de 3º nível foi
		// preenchido e incluí no cadastro da localização de 3º nível
		//***********************************************************************
		If lRet .And. lNUQ

			If oModelNUQ:HasField('NUQ_TLOC3N')

				For nCt := 1 To oModelNUQ:GetQtdLine()
					If !oModelNUQ:IsDeleted()
						If !Empty(AllTrim(oModelNUQ:GetValue("NUQ_CCOMAR",nCt))) .And. ;
						   !Empty(AllTrim(oModelNUQ:GetValue("NUQ_CLOC2N",nCt))) .And. ;
						   !Empty(AllTrim(oModelNUQ:GetValue("NUQ_TLOC3N",nCt))) .And. ;
						   Empty(AllTrim(oModelNUQ:GetValue("NUQ_CLOC3N",nCt)))

							lRet := JU183ADD3N(@oModelNUQ, AllTrim(oModelNUQ:GetValue("NUQ_CCOMAR", nCt)),AllTrim(oModelNUQ:GetValue("NUQ_CLOC2N", nCt))) //Faz o cadastro da vara quando a vara não for identificada e o usuário tenha preenchido o campo NUQ_TLOC3N
						EndIf
					EndIf
				Next
			EndIf
		EndIf

		//*********************************************************************************************************************
		// Validacao do Acordos - NYP
		//*********************************************************************************************************************
		If lRet .And. lNYP
			nVz := 0
			For nCt := 1 To oModelNYP:GetQtdLine()
				If !( oModelNYP:IsDeleted(nCt) )
					If (oModelNYP:GetValue("NYP_REALIZ", nCt) == "1")
						nVz += 1  //Contar qtos Acordos estao como realizados, permitido somente 1.
						dDtAcordo := oModelNYP:GetValue("NYP_DATA", nCt)  //Data do Acordo
					EndIf
					// Tratamento do parametro MV_JGERDES de geração de despesa ao atualizar o status da negociação
					cNYQTipo := JurGetDados("NYQ",1,xFilial("NYQ")+FwFldGet('NYP_CSTATU'),"NYQ_TIPO")
					If (cNYQTipo == "1")
						nNYPValTot += oModelNYP:GetValue("NYP_VALOR")
						cNYQMoeda  := oModelNYP:GetValue("NYP_CMOEDA")
						cNYQData   := oModelNYP:GetValue("NYP_DATA")
						lNYPAcordo := .T.
					EndIf
				EndIf
			Next nCt

			If (nVz > 1)
				JurMsgErro(STR0206) // "Permitido apenas um acordo como realizado na Aba Acordo! Favor corrigir!"
				lRet:= .F.
			EndIf

			If lRet .And. (nVz == 1) .And. oModel:IsFieldUpdated("NSZMASTER","NSZ_SITUAC") .And. (oModel:GetValue("NSZMASTER","NSZ_SITUAC") == "1") //Processo Encerrado sendo reaberto
				JurMsgErro(STR0225) // "Não é permitido alterar a situação do processo pois já existe acordo realizado"
				lRet:= .F.
			EndIf

			If lRet .And. (nVz == 1) .And. (FwFldGet('NSZ_SITUAC') != '2')  //Acordo realizado e processo nao encerrado!
				lManual := (SuperGetMV('MV_JENCACR',,"2") == "2"/*Manual*/)
				lEncerrar := Iif(!isBlind(),!( lManual ) .Or. ApMsgYesNo(STR0207),.T.)  //"Acordo realizado, deseja encerrar o processo?"
				If lEncerrar
					cMotivo   := Alltrim(SuperGetMV('MV_JTPENAC',,""))
					lAchouNQI := !( Empty(JurGetDados("NQI",1,xFilial("NQI")+cMotivo,"NQI_COD")) )

					If !( lManual ) .And. ( Empty(cMotivo) .Or. !(lAchouNQI) )
						JurMsgErro(STR0208)	// "Parâmetro para configurar o código do motivo do encerramento (MV_JTPENAC) com valor inválido!"
						lRet:= .F.
					Else
						If !IsBlind()
						oView := FwViewActive()
						EndIf
						oModel:SetValue("NSZMASTER","NSZ_SITUAC","2")
						oModel:SetValue("NSZMASTER","NSZ_DETENC",STR0209 + DtoC(dDtAcordo))  //"Acordo realizado em "
						If lAchouNQI
							oModel:SetValue("NSZMASTER","NSZ_CMOENC",cMotivo)
						EndIf

						If !IsBlind()
						oView:Refresh()  //Atualiza os dados na tela

						EndIF
						If lManual .AND. !IsBlind()
							oView:SelectFolder("FOLDER_01",1,2)    //Muda para a aba Processo
							oView:SelectFolder("JURA095_VIEW",3,1) //Muda para a aba Encerramento da aba Processo
							JurMsgOk(STR0210) // "Favor verificar a sugestão de encerramento na Aba Encerramento e, em seguida, confirma novamente os dados para gravação!"
							oModelNYP:SetNoUpdateLine( .T. ) //Nao alterar os campos da grid.
							oModelNYP:SetOnlyView( .T. )     //Somente visualizar a aba de Acordos
							lRet:= .F. //Retorna falso para permanecer na tela.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		//*********************************************************************************************************************
		// Verifica, pelo Parametro: MV_JTVENPR, se é possivel alterar o processo já encerrado, com Tela de justificativa
		//*********************************************************************************************************************
		If lRet
			lRet := JURA95ENC()
		Endif

		//Validação do encerramento dos contratos da instância anterior
		If lRet .And. !(c162TipoAs $ "005/006/007/010/011") .And. lNUQ
			lRet := J183EnCnt(oModel)
		End

		//*********************************************************************************************************************
		// Validacao de Liminar
		//*********************************************************************************************************************
		If  lRet .And. (c162TipoAs == "001"/*Contencioso*/) .And. oModel:GetModel("NSZMASTER"):HasField("NSZ_CSTATL")
			If  (oModel:GetValue("NSZMASTER","NSZ_CSITUL") == "1") //Especifica
				If  Empty(oModel:GetValue("NSZMASTER","NSZ_DTINLI")) .Or. Empty(oModel:GetValue("NSZMASTER","NSZ_DTFILI"))
					JurMsgErro(STR0211)	// "Campos Data de Início e de Término da Liminar devem ser preenchidos quando o campo Situação for igual a Específica!"
					lRet:= .F.
				EndIf
			EndIf

			If lRet .And. oModel:GetModel("NSZMASTER"):HasField("NSZ_DTINLI") .And. oModel:GetModel("NSZMASTER"):HasField("NSZ_DTFILI") .And. !Empty(oModel:GetValue("NSZMASTER","NSZ_DTINLI")) .And. !Empty(oModel:GetValue("NSZMASTER","NSZ_DTFILI"))
				If oModel:GetValue("NSZMASTER","NSZ_DTINLI") > oModel:GetValue("NSZMASTER","NSZ_DTFILI")
					lRet := .F.
					JurMsgErro(STR0218)//"Data de início da liminar deve ser maior que a data de término. Verifique!"
				EndIf
			EndIf

			If lRet .And. oModel:IsFieldUpdated("NSZMASTER","NSZ_SITUAC") .And. (oModel:GetValue("NSZMASTER","NSZ_SITUAC") == "2") //Processo Encerrado
				If !Empty( oModel:GetValue("NSZMASTER","NSZ_CSTATL") ) .And. (oModel:GetValue("NSZMASTER","NSZ_CSTATL") == "1") //Em Vigor
					JurMsgErro(STR0212)	// "Não é Permitido encerrar o processo quando o campo Status da Liminar for igual a 'Em Vigor'!"
					lRet:= .F.
				EndIf
			EndIf
		EndIf

		If lRet .And. oModel:GetModel("NSZMASTER"):HasField("NSZ_VLPROV") .And. oModel:GetModel("NSZMASTER"):HasField("NSZ_CPROGN")
			If Empty(oModel:GetValue('NSZMASTER','NSZ_CPROGN')) .And. !Empty(oModel:GetValue('NSZMASTER','NSZ_VLPROV'))
				JurMsgErro(STR0259)	//"É necessário indicar um prognóstico quando existe valor de provisão. Verifique!"
				lRet:= .F.
			EndIf
		EndIf

		//*********************************************************************************************************************
		// Valor Envolvido - Historico de Movimentacao - NV3
		//*********************************************************************************************************************
		If  lRet .And. oModel:GetModel("NSZMASTER"):HasField("NSZ_VLENVO")
			If  Empty(FwFldGet("NSZ_CFCORR")) .And. (oModel:IsFieldUpdated("NSZMASTER","NSZ_DTENVO") .Or. oModel:IsFieldUpdated("NSZMASTER","NSZ_VLENVO") .OR.;
						oModel:IsFieldUpdated("NSZMASTER","NSZ_CPROGN")) .And. !Empty(FwFldGet("NSZ_DTENVO")) .And. !Empty(FwFldGet("NSZ_VLENVO"))

				cProg := JurGetDados('NQ7', 1, xFilial('NQ7') + oModel:GetValue("NSZMASTER",'NSZ_CPROGN') , 'NQ7_TIPO' )

				lRet := JurHisCont(FwFldGet("NSZ_COD"),,FwFldGet("NSZ_DTENVO"),FwFldGet("NSZ_VLENVO"),'1','8','NSZ', nOpc,,,cProg,,,,,,FwFldGet('NSZ_FILIAL'))
			EndIf
		EndIf

		//*********************************************************************************************************************
		//Bloqueio de Embargo e Alteração do Valor Envolvido
		//*********************************************************************************************************************
		DbSelectArea("NQX")
		If NQX->( FieldPos("NQX_CLMTAL") ) > 0
			If lRet .And. SuperGetMV('MV_JBLQEMB', , '2') == "1" .And. nOpc == 4 .And.;
			   ( oModel:IsFieldUpdated("NSZMASTER","NSZ_VLENVO") .Or. oModel:IsFieldUpdated("NSZMASTER","NSZ_CPROGN") )
				lRet := JA95BLQEMB(oModel)
			EndIf
		EndIf

		If lRet .And. !(isincallstack('AtuVlrPro'))
			lRet := JURSITPROC(oModel:GetValue('NSZMASTER',"NSZ_COD"), 'MV_JTVENPR',oModel:IsFieldUpdated('NSZMASTER','NSZ_SITUAC'), lAltLote)
		EndIf

		//validação de alteração nos valores para atualização do histórico
		If nOpc == 4.And. lAnoMesHist
			J95AltValH(oModel:GetModel('NSZMASTER'),"NSZ")
		EndIf

		//== Tania - 25/07/2012 - Inclusão de rotina para atualização da NSZ - novos campos de sigla do socio e executor
		If lRet .And. ExistBlock("JA162SOEX") .And. nOpc <> 4
			ExecBlock("JA162SOEX",.F.,.F.,{oModel:GetValue('NSZMASTER','NSZ_NUMCAS'),oModel:GetValue('NSZMASTER','NSZ_COD'),nOpc})
		Endif
		//== Tania - fim da rotina

		// Tratamento para geração da despesa. Irá sugerir os dados conforme o parâmetro (MV_JGERDES)
		If lRet .AND. ((FwFldGet('NSZ_SITUAC') == '2') .AND. (NSZ->NSZ_SITUAC != FwFldGet('NSZ_SITUAC')))
			If !Empty(nGerDesNeg) .AND. lNYPAcordo
				If nGerDesNeg == 1 // Negociação
					lNYPAcordo := Iif(!IsBlind(),ApMsgYesNo(STR0277),.T.) //"Existe um acordo cadastrado para este processo. Deseja incluir uma despesa com o valor informado na negociação?"
					nNT3ValGer := nNYPValTot
				ElseIf (nGerDesNeg == 2) // Valor final da causa
					lNYPAcordo := ApMsgYesNo(STR0278) //"Existe um acordo cadastrado para este processo. Deseja incluir uma despesa com o valor total da causa?"
					cNYQMoeda := oModel:GetValue("NSZMASTER","NSZ_CMOCAU")
					cNYQData  := oModel:GetValue("NSZMASTER","NSZ_DTCAUS")

					If oModel:IsFieldUpdated("NSZMASTER","NSZ_VACAUS")
						nNT3ValGer := oModel:GetValue("NSZMASTER","NSZ_VACAUS")
					Else
						nNT3ValGer := oModel:GetValue("NSZMASTER","NSZ_VLCAUS")
					EndIf
				EndIf

				If lNYPAcordo
					cNSZ_COD := oModel:GetValue("NSZMASTER","NSZ_COD")
					J99GerDes(oModel, cNSZ_COD, nNT3ValGer, cNYQMoeda, cNYQData, lNYPAcordo)
				EndIf
			EndIf
		EndIf

		If lRet .And. lNUQ .And. lRest .And. oModelNUQ:HasField('NUQ_CINSTP')
			lRet := VldInstOri(oModelNUQ)
		EndIf
	EndIf

	If nOpc == 5 .And. lRet // 5 -> Exclusão

		BEGIN Transaction

			If lRet
				lRet := JurHisCont(oModel:GetValue("NSZMASTER","NSZ_COD"),,oModel:GetValue("NSZMASTER","NSZ_DTPROV"),oModel:GetValue("NSZMASTER","NSZ_VLPROV"),'1','1','NSZ', nOpc)
			Endif

			//Exclui registros vinculados ao processo.
			If lRet .And. (SuperGetMV('MV_JEXCFLH',, '2') == '1')
				If lWSTLegal .OR. ApMsgNoYes(STR0263)	//"Os registros vinculados ao processo serão excluidos. Deseja continua?"
					Processa( {| | JDelFilho(JURCPOSX9("NSZ"), oModel:GetValue("NSZMASTER", "NSZ_COD"))}, STR0288)	//"Excluindo Processo"
					J95EXCVINC(oModel:GetValue("NSZMASTER","NSZ_COD"))// Exclui Vinculos/Incidentes
				Else
					JurMsgErro(STR0289)		//"Operação cancelada, o processo não será excluído"
					lRet := .F.
				EndIf
			EndIf

			//******************************************************
			// Verifica de incidentes vinculados ao processo
			//******************************************************
			if lRet .And. !(c162TipoAs $ "005/006/007/009/010/011")
				lRet := JA095IncOk(oModel:GetValue("NSZMASTER","NSZ_COD"))
			Endif

			//******************************************************
			// Verifica de vinculo entre processos
			//******************************************************
			If lRet
				lRet := JA095VincOk(oModel:GetValue("NSZMASTER","NSZ_COD"))
			Endif

			If lRet .And. !(c162TipoAs $ "005/006/007/010/011") .And. lNUQ

				//*************************************************
				// Exclui os docs da(s) instância(s) e do processo
				//*************************************************
				For nCt := 1 To oModelNUQ:GetQtdLine()
					Do Case
					Case cParam == '1'
						If !JurExcAnex ('NUQ',oModelNUQ:GetValue("NUQ_COD", nCt ))
							lRet := .F.
							Exit
						EndIf

					Case cParam != '1'
						If !JurExcAnex ('NUQ',oModelNUQ:GetValue("NUQ_COD", nCt ),FwFldGet('NSZ_COD'),'2')
							lRet := .F.
							Exit
						EndIf
					EndCase
				Next
			Endif

			If lRet
				lRet := JurExcAnex('NSZ',oModel:GetValue("NSZMASTER","NSZ_COD"))
			EndIf

			If !lRet
				DisarmTransaction()
			EndIf

		END Transaction

	EndIf

	If nOpc == 4
		if lRet .And. SuperGetMV('MV_JGEDATU',,'2') == '1' .And. oModel:IsFieldUpdated('NSZMASTER','NSZ_SITUAC')
			JA095AtuGed(oModel:GetValue('NSZMASTER','NSZ_COD'), oModel:GetValue('NSZMASTER','NSZ_SITUAC') == '2')
		Endif
	Endif

	//***********************************************************************
	//Verificação da rotina de encerramento automático - Reabertura de caso
	//***********************************************************************
	If lRet .And. SuperGetMV('MV_JENCAUT',, '2') == '1' .And. nOpc == 4 .And. NSZ->NSZ_SITUAC == '2'  .And. FwFldGet('NSZ_SITUAC') == '1'
		JUR095Rea(FwFldGet('NSZ_CCLIEN'),FwFldGet('NSZ_LCLIEN'),FwFldGet('NSZ_NUMCAS'))
	Endif

	//**********************************************************************************************
	// Verificação da rotina de abertura automática de caso - DEIXAR SEMPRE COMO ULTIMA VALIDAÇÃO
	//**********************************************************************************************
	If lRet
		lRet := J95AltNCAut(oModel)
	EndIf

	If lRet .And. (nOpc == 3 .Or. nOpc == 4)
		//*******************************************************************************************************************************
		// Gera tarefas de follow-up para aprovacao no fluig quando nao for uma aprovacao do fluig para Valor de Provisão ou Encerramento
		//*******************************************************************************************************************************
		If lRet .And. lCpoTpApr .And. SuperGetMV('MV_JFLUIGA',,'2') == '1'
			lRet := J95FFluig(oModel, nOpc)
			If lRet .AND. lWSTLegal
				lRet := J95FFluig(oModel, nOpc)
			EndIf
		EndIf

		//*********************************************************************************************************************
		// Zera Provisão quando o processo é encerrado
		//*********************************************************************************************************************
		If lRet .And. FindFunction("JA95ZerPro") .And. oModel:IsFieldUpdated("NSZMASTER", "NSZ_SITUAC") .And. oModel:GetValue("NSZMASTER", "NSZ_SITUAC") == "2"
		   lRet := JA95ZerPro(oModel)
		EndIf
	Endif

	//== Tania - 23/07/2012 - Inclusão de rotina para gravação
	If lRet .And. ExistBlock("JA095SOEX")
		ExecBlock("JA095SOEX",.F.,.F.,{FwFldGet('NSZ_NUMCAS')})
	Endif

	If lRet .And. SuperGetMV('MV_JINTJUR',, '2') == '1'
		JurIntJuri(oModel:GetValue("NSZMASTER","NSZ_COD"),oModel:GetValue("NSZMASTER","NSZ_COD"), "1", Str(nOpc))
	Endif

	RestArea( aAreaNQS )
	RestArea( aAreaNSZ )
	RestArea( aAreaNT9 )
	RestArea( aAreaNUQ )
	RestArea( aAreaNXY )
	RestArea( aAreaNYJ )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuPop(cCajurOri, cCajur, oView, c162TipoAs)
Função utilizada para não permitir que processo seja origem
e incidentes dentro da mesma familia de incidentes.
Uso Geral.

@param cFilOri    - Filial origem 
@param cCajurOri  - Codigo do assunto juridico origem
@param cCajur     - Codigo do assunto juridico
@param oView      - view principal
@param c162TipoAs - Tipo do assunto juridico
@param oBotao     - botÃ£o principal

@author Clóvis Eduardo Teixeira
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuPop( cFilOri, cCajurOri, cCajur, oView, c162TipoAs, oBotao)
Local aMenuItem  := {}
Local oMenu      := Nil

	oMenu := MenuBegin(,,,, .T.,,oBotao, )
		aAdd( aMenuItem, MenuAddItem( STR0062, ,,,,,, oMenu, {|| FWMsgRun( ,{|| JA095Tela(cFilOri, cCajur,'1',c162TipoAs), oView:Refresh() }, , ) } ,,,,, { || .T. } ) )//Abrir lista de incidentes
		aAdd( aMenuItem, MenuAddItem( STR0063, ,,,,,, oMenu, {|| FWMsgRun( ,{|| J183AssOrg(cFilOri, cCajurOri), oView:Refresh() }, , ) } ,,,,, { || .T. } ) )//abrir processo origem 
	MenuEnd()

	oMenu:Activate( 10, 10, oBotao )

Return .F.

Static Function CoordY()
	Local nRet := 280 //720
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nRet := 320 //730
	EndIf
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095Tela(cFilOri, cAssJur, cTela, c162TipoAs)
Função para visualização e alteração do Incidente
@Return lRet .T./.F. As informações são válidas ou não
@sample
@param cAssJur - Código do assunto jurídico
@param cTela   - 1 Incidentes; 2 - Vinculo; 3 - Relacionados
@param c162TipoAs Tipo Assunto Jurídico Pai
@author Clóvis Eduardo Teixeira
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095Tela(cFilOri, cAssJur, cTela, cTipoAJ, nOpc)
	Local aArea      := GetArea()
	Local aAreaNSZ   := NSZ->( GetArea() )
	Local aAreaNT9   := NT9->( GetArea() )
	Local aAreaNUQ   := NUQ->( GetArea() )
	Local cIdBrowse  := ''
	Local cIdRodape  := ''
	Local cTrab      := GetNextAlias()
	Local aCampos    := {}
	Local cTitle     := ''//IIF(cTela == '1', STR0040, STR0066)
	Local oBrowse, oDlg, oTela, oPnlBrw, oPnlRoda
	Local oBtnIncluir, oBtnAlterar, oBtnExcluir, oBtnVincular, oBtnSair, oBtnVisual
	Local cTabPadrao := "NSZ"
	Local oM         := FWModelActive()
	Local ldModel    := .F. //Controla se o model da 95 foi criado e deve ser desativado.
	Local cCodRestr  := "00" // Código da rotina para restrição de ações
	Local nEspButton := 0

	Default nOpc := oM:GetOperation()

	if (oM == Nil) .Or. ((oM:cId != "JURA095") .And. isInCallStack("dblClickBrw")) .Or. (!oM:lActivate .And. oM:cId == "JURA095") // Valida se estamos na tela de pesquisa e se a tela foi aberta do grid.
		//Carrega o modelo do JURA095
		cTipoAsJ := cTipoAJ
		c162TipoAs := cTipoAJ
		INCLUI := (nOpc == 3)
		ALTERA := (nOpc == 4)
		NSZ->(DBSetOrder(1))
		NSZ->(dbSeek(cFilOri + cAssJur))
		oM := FWLoadModel( 'JURA095' )
		oM:SetOperation( nOpc )
		oM:Activate()
		ldModel := .T.
	Endif

	If cTela == '1'
		cTitle := STR0040 // Incidentes
		cCodRestr := "01"
		nEspButton := 073
	ElseIf cTela == '2'
		cTitle := STR0066 // Vinculados
		cCodRestr := "02"
		nEspButton := 073
	Else
		cTitle := STR0137 // Relacionados
		cCodRestr := "17"
		nEspButton := 110
	EndIf

	if nOpc != 3

		//Incidentes
		If cTela == '1' //Verificação do tipo de tela para montagem da query

		/*
		Estrutura aCampos
		1- Campo  2- Título  3- Tabela  4- Apelido tabela  5- Filtro  6- Tabela pai
		7- Apelido tabela pai  8- Nome do campo na consulta (Algum apelido caso necessário)  9- Relacionamento (.T. Join, .F. Outer Join)
		*/

		/*Em alguns casos o título usado não é do próprio campo do grid
		pois algumas tabelas não ficam disponíveis na NUZ.*/

			//Monta o retorno de incidentes passando os filtros
			aCampos := {}

			If cTipoAJ != '008'
				aAdd(aCampos, {"NSZ_FILIAL",J95TitCpo("NSZ_FILIAL",cTipoAJ),"NSZ","NSZ001","NSZ001.NSZ_FILIAL ='"+ cFilOri +"'","NSZ","NSZ001","NSZ_FILIAL",.T.})
				aAdd(aCampos, {"NSZ_COD"   ,J95TitCpo("NSZ_COD"   ,cTipoAJ),"NSZ","NSZ001","NSZ001.NSZ_CPRORI ='" + cAssJur + "'","NSZ","NSZ001","NSZ001.NSZ_COD",.T.})
				aAdd(aCampos, {"NUQ_NUMPRO",J95TitCpo("NUQ_NUMPRO",cTipoAJ),"NUQ","NUQ001","NUQ001.NUQ_INSATU = '1'","NSZ","NSZ001","NUQ_NUMPRO",.T.})
				aAdd(aCampos, {"NUQ_INSTAN",J95TitCpo("NUQ_INSTAN",cTipoAJ),"NUQ","NUQ001","NUQ001.NUQ_INSATU = '1'","NSZ","NSZ001","NUQ_INSTAN",.T.})
				aAdd(aCampos, {"NQU_DESC"  ,J95TitCpo("NUQ_DTIPAC",cTipoAJ),"NQU","NQU001",Nil,"NUQ","NUQ001","NQU_DESC",.T.})
				aAdd(aCampos, {"NSZ_CCLIEN",J95TitCpo("NSZ_CCLIEN",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_CCLIEN",.T.})
				aAdd(aCampos, {"NSZ_LCLIEN",J95TitCpo("NSZ_LCLIEN",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_LCLIEN",.T.})
				aAdd(aCampos, {"NSZ_NUMCAS",J95TitCpo("NSZ_NUMCAS",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_NUMCAS",.T.})
				aAdd(aCampos, {"NSZ_SITUAC",J95TitCpo("NSZ_SITUAC",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_SITUAC",.T.})
				aAdd(aCampos, {"NYB_DESC"  ,J95TitCpo("NSZ_DTIPAS",cTipoAJ),"NYB","NYB001",Nil,"NSZ","NSZ001","NYB_DESC",.T.})
			Else
				aAdd(aCampos, {"NSZ_FILIAL",J95TitCpo("NSZ_FILIAL",cTipoAJ),"NSZ","NSZ001","NSZ001.NSZ_FILIAL ='"+ cFilOri +"'","NSZ","NSZ001","NSZ_FILIAL",.T.})
				aAdd(aCampos, {"NSZ_COD"   ,J95TitCpo("NSZ_COD"   ,cTipoAJ),"NSZ","NSZ001","NSZ001.NSZ_CPRORI ='" + cAssJur + "'","NSZ","NSZ001","NSZ_COD",.T.})
				aAdd(aCampos, {"NSZ_CCLIEN",J95TitCpo("NSZ_CCLIEN",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_CCLIEN",.T.})
				aAdd(aCampos, {"NSZ_LCLIEN",J95TitCpo("NSZ_LCLIEN",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_LCLIEN",.T.})
				aAdd(aCampos, {"NSZ_NUMCAS",J95TitCpo("NSZ_NUMCAS",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_NUMCAS",.T.})
				aAdd(aCampos, {"NSZ_SITUAC",J95TitCpo("NSZ_SITUAC",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_SITUAC",.T.})
				aAdd(aCampos, {"NYJ_NOMEFT",J95TitCpo("NYJ_NOMEFT",cTipoAJ),"NYJ","NYJ001","NYJ001.NYJ_UNIDAD='1'","NSZ","NSZ001","NYJ_NOMEFT",.F., "''"})
				aAdd(aCampos, {"NYJ_CTPSOC",J95TitCpo("NYJ_CTPSOC",cTipoAJ),"NYJ","NYJ001","NYJ001.NYJ_UNIDAD='1'","NSZ","NSZ001","NYJ_CTPSOC",.F., "''"})
				aAdd(aCampos, {"NYB_DESC"  ,J95TitCpo("NSZ_DTIPAS",cTipoAJ),"NYB","NYB001",Nil,"NSZ","NSZ001","NYB_DESC",.T.})
			Endif

		//Vinculados
		ElseIf cTela == '2'

			//Monta o retorno de vinculados passando os filtros
			aCampos := {}

			//Assunto Jurídicos com NUQ
			If cTipoAJ $ "001/002/003/004/009"
				aAdd(aCampos, {"NSZ_FILIAL",J95TitCpo("NSZ_FILIAL",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_FILIAL",.T.})
				aAdd(aCampos, {"NVO_CAJUR2",J95TitCpo("NSZ_COD"   ,cTipoAJ),"NVO","NVO001","NVO001.NVO_CAJUR1 = '" + cAssJur + "' AND NVO001.NVO_CAJUR2 <> NVO001.NVO_CAJUR1","NSZ","NSZ001","NVO_CAJUR2",.T.})
				aAdd(aCampos, {"NUQ_NUMPRO",J95TitCpo("NUQ_NUMPRO",cTipoAJ),"NUQ","NUQ001","NUQ001.NUQ_INSATU = '1'","NSZ","NSZ001","NUQ_NUMPRO",.T.})
				aAdd(aCampos, {"NUQ_INSTAN",J95TitCpo("NUQ_INSTAN",cTipoAJ),"NUQ","NUQ001","NUQ001.NUQ_INSATU = '1'","NSZ","NSZ001","NUQ_INSTAN",.T.})
				aAdd(aCampos, {"NQU_DESC"  ,J95TitCpo("NUQ_DTIPAC",cTipoAJ),"NQU","NQU001",Nil,"NUQ","NUQ001","NQU_DESC",.T.})
				aAdd(aCampos, {"NSZ_CCLIEN",J95TitCpo("NSZ_CCLIEN",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_CCLIEN",.T.})
				aAdd(aCampos, {"NSZ_LCLIEN",J95TitCpo("NSZ_LCLIEN",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_LCLIEN",.T.})
				aAdd(aCampos, {"NSZ_NUMCAS",J95TitCpo("NSZ_NUMCAS",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_NUMCAS",.T.})
				aAdd(aCampos, {"NSZ_SITUAC",J95TitCpo("NSZ_SITUAC",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_SITUAC",.T.})
				aAdd(aCampos, {"NYB_DESC"  ,J95TitCpo("NSZ_DTIPAS",cTipoAJ),"NYB","NYB001",Nil,"NSZ","NSZ001","NYB_DESC",.T.})

			//Societário
			ElseIf cTipoAJ == '008'
				aAdd(aCampos, {"NSZ_FILIAL",J95TitCpo("NSZ_FILIAL",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_FILIAL",.T.})
				aAdd(aCampos, {"NVO_CAJUR2",J95TitCpo("NSZ_COD"   ,cTipoAJ),"NVO","NVO001","NVO001.NVO_CAJUR1 = '" + cAssJur + "' AND NVO001.NVO_CAJUR2 <> NVO001.NVO_CAJUR1","NSZ","NSZ001","NVO_CAJUR2",.T.})
				aAdd(aCampos, {"NSZ_CCLIEN",J95TitCpo("NSZ_CCLIEN",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_CCLIEN",.T.})
				aAdd(aCampos, {"NSZ_LCLIEN",J95TitCpo("NSZ_LCLIEN",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_LCLIEN",.T.})
				aAdd(aCampos, {"NSZ_NUMCAS",J95TitCpo("NSZ_NUMCAS",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_NUMCAS",.T.})
				aAdd(aCampos, {"NSZ_SITUAC",J95TitCpo("NSZ_SITUAC",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_SITUAC",.T.})
				aAdd(aCampos, {"NYJ_NOMEFT",J95TitCpo("NYJ_NOMEFT",cTipoAJ),"NYJ","NYJ001","NYJ001.NYJ_UNIDAD='1'","NSZ","NSZ001","NYJ_NOMEFT",.F., "''"})
				aAdd(aCampos, {"NYJ_CTPSOC",J95TitCpo("NYJ_CTPSOC",cTipoAJ),"NYJ","NYJ001","NYJ001.NYJ_UNIDAD='1'","NSZ","NSZ001","NYJ_CTPSOC",.F., "''"})
				aAdd(aCampos, {"NYB_DESC"  ,J95TitCpo("NSZ_DTIPAS",cTipoAJ),"NYB","NYB001",Nil,"NSZ","NSZ001","NYB_DESC",.T.})

			Else
				aAdd(aCampos, {"NSZ_FILIAL",J95TitCpo("NSZ_FILIAL",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_FILIAL",.T.})
				aAdd(aCampos, {"NVO_CAJUR2",J95TitCpo("NSZ_COD"   ,cTipoAJ),"NVO","NVO001","NVO001.NVO_CAJUR1 = '" + cAssJur + "' AND NVO001.NVO_CAJUR2 <> NVO001.NVO_CAJUR1","NSZ","NSZ001","NVO_CAJUR2",.T.})
				aAdd(aCampos, {"NSZ_CCLIEN",J95TitCpo("NSZ_CCLIEN",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_CCLIEN",.T.})
				aAdd(aCampos, {"NSZ_LCLIEN",J95TitCpo("NSZ_LCLIEN",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_LCLIEN",.T.})
				aAdd(aCampos, {"NSZ_NUMCAS",J95TitCpo("NSZ_NUMCAS",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_NUMCAS",.T.})
				aAdd(aCampos, {"NSZ_SITUAC",J95TitCpo("NSZ_SITUAC",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_SITUAC",.T.})
				aAdd(aCampos, {"NYB_DESC"  ,J95TitCpo("NSZ_DTIPAS",cTipoAJ),"NYB","NYB001",Nil,"NSZ","NSZ001","NYB_DESC",.T.})
			Endif

		//Relacionados
		ElseIf cTela == '3'

			aCampos := {}
			aAdd(aCampos, {"NSZ_FILIAL",J95TitCpo("NSZ_FILIAL",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ_FILIAL",.T.})

			//Monta o retorno de Relacionados passando os filtros
			aAdd(aCampos, {"NXX_CAJURD",J95TitCpo("NSZ_COD"   ,cTipoAJ),"NXX","NXX001","NXX001.NXX_CAJURD = NSZ001.NSZ_COD AND NXX001.NXX_CAJURO = '" + cAssJur + "' ","NSZ","NSZ001","NXX001.NXX_CAJURD",.T.})
			aAdd(aCampos, {"NUQ_NUMPRO",J95TitCpo("NUQ_NUMPRO",cTipoAJ),"NUQ","NUQ001","NUQ001.NUQ_INSATU = '1'","NSZ","NSZ001","NUQ_NUMPRO",.F., "''"})
			aAdd(aCampos, {"NUQ_INSTAN",J95TitCpo("NUQ_INSTAN",cTipoAJ),"NUQ","NUQ001","NUQ001.NUQ_INSATU = '1'","NSZ","NSZ001","NUQ_INSTAN",.F., "''"})
			aAdd(aCampos, {"NQU_DESC"  ,J95TitCpo("NUQ_DTIPAC",cTipoAJ),"NQU","NQU001",Nil                      ,"NUQ","NUQ001","NQU_DESC"  ,.F., "''"})
			aAdd(aCampos, {"NSZ_CCLIEN",J95TitCpo("NSZ_CCLIEN",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ001.NSZ_CCLIEN",.T.})
			aAdd(aCampos, {"NSZ_LCLIEN",J95TitCpo("NSZ_LCLIEN",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ001.NSZ_LCLIEN",.T.})
			aAdd(aCampos, {"NSZ_NUMCAS",J95TitCpo("NSZ_NUMCAS",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ001.NSZ_NUMCAS",.T.})
			aAdd(aCampos, {"NSZ_SITUAC",J95TitCpo("NSZ_SITUAC",cTipoAJ),"NSZ","NSZ001",Nil,"NSZ","NSZ001","NSZ001.NSZ_SITUAC",.T.})
			aAdd(aCampos, {"NYB_DESC"  ,J95TitCpo("NSZ_DTIPAS",cTipoAJ),"NYB","NYB001",Nil,"NSZ","NSZ001","NYB001.NYB_DESC",.T.})
		Endif

		Define MsDialog oDlg FROM 0, 0 To 400, 600 Title cTitle Pixel style DS_MODALFRAME

		oTela     := FWFormContainer():New( oDlg )
		cIdBrowse := oTela:CreateHorizontalBox( 84 )
		cIdRodape := oTela:CreateHorizontalBox( 16 )
		oTela:Activate( oDlg, .F. )

		oPnlBrw   := oTela:GeTPanel( cIdBrowse )
		oPnlRoda  := oTela:GeTPanel( cIdRodape )

	//-------------------------------------------------------------------
	// Define o Browse
	//-------------------------------------------------------------------
		oBrowse := TJurBrowse():New(oPnlBrw)
		oBrowse:SetAlias(cTrab)
		oBrowse:SetDataQueryX3(aCampos,cTabPadrao)
		oBrowse:SetDoubleClick({||JA095ALT(AllTrim((cTrab)->(FieldGet(1))),cTela)})
		oBrowse:Activate()

		If JA162AcRst(cCodRestr)
			//<--- Botão Visualizar --->
			@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + nEspButton Button oBtnVisual Prompt STR0002;
				Size 25 , 12 Of oPnlRoda Pixel Action ( JA095VIS((cTrab)->(FieldGet(1)),AllTrim((cTrab)->(FieldGet(2))), cTela))
			nEspButton += 37

		EndIf

		If JA162AcRst(cCodRestr,4)
			//<--- Botão Alterar --->
			@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + nEspButton Button oBtnAlterar Prompt STR0004;
				Size 25 , 12 Of oPnlRoda Pixel Action ( JA095ALT((cTrab)->(FieldGet(1)), AllTrim((cTrab)->(FieldGet(2))), cTela), oBrowse:DeActivate(.T.), oBrowse:Activate() )
			nEspButton += 37

			If !JA162AcRst('14', 4)
				oBtnAlterar:Disable()
			EndIf
		EndIf

		If JA162AcRst(cCodRestr,3)
			//<--- Botão Vincular --->
			@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + nEspButton Button oBtnVincular Prompt STR0052;
				Size 25 , 12 Of oPnlRoda Pixel Action ( JA095VIN(cFilOri, cAssJur,cTipoAJ, cTela), oBrowse:DeActivate(.T.), oBrowse:Activate())

			nEspButton += 37

			//<---- Botão Incluir ---> desativado por que fere a regra de negócio, não pode ser incluido um processo com o mesmo tipo de assunto jurídico
			If !(cTela == '3') .And. !(cTela == '2' .And.( JGetParTpa(cTipoASJ, "MV_JINVINC", .T.) == .F. ))
				@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + nEspButton Button oBtnIncluir Prompt STR0003;
					Size 25 , 12 Of oPnlRoda Pixel Action (JA095INC(cTipoAJ,,cTela, oM), oBrowse:DeActivate(.T.), oBrowse:Activate())
				nEspButton += 37

				If !JA162AcRst('14', 3)
					oBtnIncluir:Disable()
				EndIf
			Endif
		EndIf

		If JA162AcRst(cCodRestr,5)
			//<---- Botão Desvincular --->
			@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + nEspButton Button oBtnExcluir  Prompt STR0298 ;
				Size 32 , 12 Of oPnlRoda Pixel Action ( JA095DEL((cTrab)->(FieldGet(1)), AllTrim((cTrab)->(FieldGet(2))), cFilOri, cAssJur, cTela), ;
				oBrowse:DeActivate(.T.), oBrowse:Activate() )
			nEspButton += 37

			If !JA162AcRst('14', 5)
				oBtnExcluir:Disable()
			EndIf
		EndIf

		//<---- Botão Sair ---->
		@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + nEspButton Button oBtnSair Prompt STR0051;
			Size 25 , 12 Of oPnlRoda Pixel Action ( oDlg:End() )

		//-------------------------------------------------------------------
		// Ativação do janela
		//-------------------------------------------------------------------
		Activate MsDialog oDlg Centered

		If !isInCallStack("dblClickBrw") //Valida se o usuário não está no grid.
			If (nOpc == 3 .Or. nOpc == 4)

				//<-- Verifica se o campo esta no model 'NSZMASTER' ->
				If oM:GetModel('NSZMASTER'):HasField('NSZ_QTINCI')
					oM:LoadValue('NSZMASTER','NSZ_QTINCI',JA095Qtde(cAssJur,'1'))
				EndIf

				//<-- Verifica se o campo esta no model 'NSZMASTER' ->
				If oM:GetModel('NSZMASTER'):HasField('NSZ_QTVINC')
					oM:LoadValue('NSZMASTER','NSZ_QTVINC',JA095Qtde(cAssJur,'2'))
				EndIf

				//<-- Verifica se o campo esta no model 'NSZMASTER' ->
				If oM:GetModel('NSZMASTER'):HasField('NSZ_QTRELA')
					oM:LoadValue('NSZMASTER','NSZ_QTRELA',JA095Qtde(cAssJur,'3'))
				EndIf
			EndIf
		Endif

	Else
		If cTela == '1'
			JurMsgErro(STR0057) //Para acessar a tela de incidentes é preciso salvar o registro!
		ElseIf cTela == '2'
			JurMsgErro(STR0065) //Para acessar a tela de vinculo é preciso salvar o registro!
		ElseIf cTela == '3'
			JurMsgErro(STR0143) //Para acessar a tela de relacionamentos é preciso salvar o registro!
		Endif
	Endif

	if ldModel //valida se o modelo foi criado apenas para a situação acima e deve ser desativado.
		oM:Deactivate()
	Endif

	RestArea( aAreaNT9 )
	RestArea( aAreaNUQ )
	RestArea( aAreaNSZ )
	RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuAnexos
Monta o menu de opções de anexos
Uso no cadastro de Assunto Jurídico.

@author Juliana Iwayama Velho
@since 11/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function MenuAnexos(oModel)

	JurAnexos("NSZ", NSZ->NSZ_COD, 1)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} CoordXAnex
Monta as coordenadas do menu de anexos
Uso no cadastro de Assunto Jurídico.

@author Juliana Iwayama Velho
@since 11/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CoordXAnex()
	Local nRet := 850
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nRet := 1005
	EndIf
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J095MenuHist(oView)
Monta o menu de opções de Histórico.

@param oView

@author Tiago Martins
@since  25/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095MenuHist(oView)

	Local oMenuItem	 := {}
	Local oModelSAVE
	Local lAnoMes    := (SuperGetMV('MV_JVLHIST',, '2') == '1')

	MENU oMenuHist POPUP
	aAdd( oMenuItem, MenuAddItem( STR0272,,, .T.,,,, oMenuHist, {| oView | oModelSAVE := FWModelActive(), JURA093(FwFldGet('NSZ_COD')), FWModelActive(oModelSAVE) },,,,, { || .T. } ) )
	aAdd( oMenuItem, MenuAddItem( STR0273,,, .T.,,,, oMenuHist, {| oView | oModelSAVE := FWModelActive(), JURA166(FwFldGet('NSZ_COD')), FWModelActive(oModelSAVE)  },,,,, { || .T. } ) )
	If lAnoMes
		aAdd( oMenuItem, MenuAddItem( STR0274,,, .T.,,,, oMenuHist, {| oView | IIF(J95AcesBtn(), (oModelSAVE := FWModelActive(), JCall177(FwFldGet('NSZ_COD'),FwFldGet('NSZ_FILIAL')), FWModelActive(oModelSAVE)),)},,,,, { || .T. } ) ) //"Valores"
	EndIf
ENDMENU

ACTIVATE POPUP oMenuHist AT CoordXHist(), CoordY()
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} CoordXHist()
Coordenadas da opção de Histórico.

@author Tiago Martins
@since  25/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CoordXHist()
	Local nRet := 130
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nRet := 785
	EndIf
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuFatura()
Monta o menu de opções de Faturamento.

@author Tiago Martins
@since 23/01/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function MenuFatura(oView)
	Local oModelSAVE
	Local oMenuFat
	Local oMenuItem	 := {}

	MENU oMenuFat POPUP

	aAdd( oMenuItem, MenuAddItem( STR0105,,, .T.,,,, oMenuFat, { | | oModelSAVE := FWModelActive(), JURA096(FwFldGet('NSZ_CCLIEN'),;
		FwFldGet('NSZ_LCLIEN'),FwFldGet('NSZ_NUMCAS')), FWModelActive(oModelSAVE) },,,,, { || .F. } ) )
	aAdd( oMenuItem, MenuAddItem( STR0106,,, .T.,,,, oMenuFat, { | | oModelSAVE := FWModelActive(), JURA027(FwFldGet('NSZ_CCLIEN'),;
		FwFldGet('NSZ_LCLIEN'),FwFldGet('NSZ_NUMCAS')), FWModelActive(oModelSAVE) },,,,, { || .T. } ) )
	aAdd( oMenuItem, MenuAddItem( STR0109,,, .T.,,,, oMenuFat, { | | oModelSAVE := FWModelActive(), JURA109(FwFldGet('NSZ_CCLIEN'),;
		FwFldGet('NSZ_LCLIEN'),FwFldGet('NSZ_NUMCAS')), FWModelActive(oModelSAVE) },,,,, { || .T. } ) )

ENDMENU
ACTIVATE POPUP oMenuFat AT CoordXAnex(), CoordY()

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095CMT
Funcao para gravar os dados do Modelo

@Param oModel:     Model de dados ativo
@Param lCpoRateio: indica se haverá rateio
@Param lNUQ:       indica se o model tem NUQ

@author Rodrigo Guerato
@since 29/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095CMT( oModel, lCpoRateio, lNUQ )
Local aArea     := GetArea()
Local aAreaNUQ  := NUQ->( GetArea() )
Local aAreaNT9  := NT9->( GetArea() )
Local nOpc      := oModel:GetOperation()
Local oModelNUQ := oModel:GetModel('NUQDETAIL')
Local cCajuri   := oModel:GetValue("NSZMASTER","NSZ_COD")
Local cCobjet   := oModel:GetValue("NSZMASTER","NSZ_COBJET")
Local cCareaj   := oModel:GetValue("NSZMASTER","NSZ_CAREAJ")
Local cTpAss    := oModel:GetValue("NSZMASTER","NSZ_TIPOAS")
Local cDirPdf   := oModel:GetValue("NSZMASTER","NSZ__DIRPDF")
Local cMvJDoc   := SuperGetMV('MV_JDOCUME',,"2")
Local cCodUser  := ""
Local lAltProv  := .F.
Local lRet      := .T.
Local aErro     := {}
Local dDataProv := Date()

	If nOpc == MODEL_OPERATION_UPDATE

		//Verifica se eh reabertura de processo para gravar data de reabetura
		If oModel:GetValue("NSZMASTER", "NSZ_SITUAC") == "1" .And.  NSZ->NSZ_SITUAC == "2" .And. ;
		   oModel:GetModel("NSZMASTER"):HasField("NSZ_DTREAB") // Proteção do fonte
			oModel:SetValue("NSZMASTER", "NSZ_DTREAB", Date())
		EndIf
	EndIf

	//Atualiza valor de provisão na tabela de histórico - NV3
	If lCpoRateio .And. (nOpc == MODEL_OPERATION_UPDATE .OR. nOpc == MODEL_OPERATION_INSERT)
		lRet := JA095AtuPro(oModel, nOpc)
	EndIf

	//Verifica se esta ativada a funcionalidade de andamento automático
	If lNUQ
		DbSelectArea("NUQ")
		If ColumnPos("NUQ_ANDAUT") > 0 .And. JGetParTpa(oModel:GetValue("NSZMASTER", "NSZ_TIPOAS"), "MV_JANDAUT", "2") == "1"
			Processa( {|| VldAndAut(oModel)}, "", STR0269)	//"Atualizando processo no serviço de monitoramento TOTVS"
		EndIf
	EndIf

	//Configura permissões de correspondentes nas pastas dos casos no fluig.
	//Quando tiver alteração e o fluxo de correspondente por Assunto Jurídico e documento no fluig
	If lNUQ .And. cMvJDoc == "3" .And. SuperGetMV("MV_JFLXCOR", , 1) == 2
		J95FAtPeCo(oModel)
	EndIf

	// Valida se houve alteração da provisão 
	If(oModel:GetModel("NSZMASTER"):HasField("NSZ_VLPROV") .And. oModel:GetModel("NSZMASTER"):HasField("NSZ_CPROGN"))
		If( oModel:GetValue("NSZMASTER","NSZ_DTPROV") <> NSZ->NSZ_DTPROV .Or. ;
			oModel:GetValue("NSZMASTER","NSZ_VLPROV") <> NSZ->NSZ_VLPROV .Or. ;
			oModel:GetValue("NSZMASTER","NSZ_CPROGN") <> NSZ->NSZ_CPROGN .Or. ;
			oModel:GetValue("NSZMASTER","NSZ_CFCORR") <> NSZ->NSZ_CFCORR .Or. ;
			oModel:GetValue("NSZMASTER","NSZ_SITUAC") <> NSZ->NSZ_SITUAC )

			dDataProv := NSZ->NSZ_DTPROV
			lAltProv := .T.

		EndIf
	EndIf
	//Realiza a Gravaca do Model
	FwFormCommit( oModel )
	
	If ( nOpc == MODEL_OPERATION_INSERT ) .OR. ( nOpc == MODEL_OPERATION_UPDATE )

		//Realiza as operacoes retiradas do TudoOK
		If oModel:GetValue("NSZMASTER", "NSZ_SITUAC") == "2" //Somente nos casos de encerramento

			If SuperGetMV('MV_JFTJURI',, '1') == '1'  //Integração com SIGAPFS.
				If SuperGetMV('MV_JENCINC',.F.,'2') == '1' //Encerramento automático de incidentes

					/*
						O encerramento automático de incidentes, que encerra seu processo origem e seus incidentes (filhos)
						só acontecerá quando o sistema for usado por um escritório de advocacia (SIGAPFS), pois essa regra
						pode ser usada para fins de faturamento. Por isso o uso do parâmetro de integração com SIGAPFS.
						Essa regra não se aplica para departamentos jurídicos. Portanto quando for encerrado um processo,
						não serão encerrados seus incidentes (filhos), nem o seu processo origem.
					*/

					If !IsInCallStack("JA095Ini")

						/*
							Como os incidentes e processos de origem são encerrados passando pelas validações do modelo, e
							por isso a função de commit é chamada  para cada execução, é necessário travar para que não chame
							novamente a rotina JA095Ini, para que não execute as rotinas de encerramento de forma redundante.
							A rotina deve ser executada somente uma vez.
						*/

						JA095Ini(oModel:GetValue('NSZMASTER','NSZ_COD'))

					EndIf
				Endif
			EndIf

			If lRet .And. SuperGetMV('MV_JENCAUT',.F.,'2') == '1' //Encerramento automático de caso
				lRet := JA095EncAut(oModel)
			Endif
		Endif

		// Ajusta a correção e juros na NV3
		If(lAltProv)
			If !Empty(dDataProv) .And. (JGetParTpa(cTpAss, "MV_JVLPROV", "1") != "2")
				JurHisCont(cCajuri,, dDataProv, 0 , '2', '1', 'NSZ',3)
				JurHisCont(cCajuri,, dDataProv, 0 , '3', '1', 'NSZ',3)
			EndIf

			JURA002( {{cCajuri, xFilial('NSZ')}},{'NSZ'},.F.)
		EndIf

	Endif

	//valida se esta em execução o MILE ou se não existe interface aberta.
	If !JurAuto()
		If ( nOpc == MODEL_OPERATION_INSERT )
			If (SuperGetMV('MV_JPROCFW',.F.,'2') == '1') .And. ApMsgYesNo(STR0226)  //"Deseja cadastrar um follow-up para este processo?"
				FWExecView(STR0003,'JURA106',3,,{||lRet := .T., lRet})  //"Incluir"
			EndIf
		Endif
	EndIf

	If ( nOpc == 3 )
		//Verifica se o campo NSZ__DIRPDF está preenchido, se sim grava na NUM
		If !Empty(cDirPdf)
			J026Anexar("NSZ",xFilial("NSZ"),cCajuri,cCajuri,cDirPdf)
		EndIf
		
		aErro := JAINCFWAUT('1',cCajuri,cCobjet,cCareaj,cTpAss)
	ElseIf nOpc == 4
		If lNUQ .AND. (oModelNUQ:IsFieldUpdate('NUQ_CCORRE') .OR. oModelNUQ:IsFieldUpdate('NUQ_LCORRE'))
			aErro := JAINCFWAUT('2',cCajuri,cCobjet,cCareaj,cTpAss)
		ElseIf oModel:IsFieldUpdate('NSZMASTER','NSZ_CPART1')
			aErro := JAINCFWAUT('4',cCajuri,cCobjet,cCareaj,cTpAss)
		EndIf
	Endif

	If ((Len(aErro) > 1) .And. (nOpc != MODEL_OPERATION_INSERT ))
		JurMsgErro(STR0286,aErro[6])
		lRet := .F.
	EndIF

	//-- Se a tabela existe no ambiente, realiza a gravação dos dados do usuário - Histórico de Alterações de Processos
	If FWAliasInDic("O0X") .AND. Chkfile("O0X")
		cCodUser := __cUserID
		
		O0X->( Reclock( "O0X", .T. ) )
			O0X->O0X_FILIAL := xFilial('O0X')
			O0X->O0X_CODIGO := GETSXENUM("O0X","O0X_CODIGO")
			O0X->O0X_KEY    := xFilial("NSZ") + cCajuri
			O0X->O0X_USER   := UsrRetName( cCodUser )
			O0X->O0X_USERID := cCodUser
			O0X->O0X_DATA   := Date()
			O0X->O0X_HORA   := Time()
		O0X->( MsUnlock() )
		
		If __lSX8
			ConfirmSX8()
		EndIf
	EndIf

	NUQ->( RestArea( aAreaNUQ ) )
	NT9->( RestArea( aAreaNT9 ) )
	RestArea( aArea )
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J95CliCS
Funcao para validar conteudo do cliente com as informações
sobre Caso Automatico

@author Rafael Rezende Costa
@since 12/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95CliCS()

	Local aArea    := GetArea()
	Local aAreaNUH := NUH->(GetArea())
	Local lRet 	 := .T.
	Local cMsgItem := ''
	Local oModel   := FWModelActive()
	Local cCliente := oModel:GetValue("NSZMASTER","NSZ_CCLIEN")
	Local cLoja    := oModel:GetValue("NSZMASTER","NSZ_LCLIEN")
	Local nOper    := oModel:GetOperation()
	Local cIntegra := SuperGetMV("MV_JFTJURI",, "2" ) //Indica se ha Integracao entre SIGAJURI e SIGAPFS (1=Sim;2=Nao)

	If (nOper == 3 .Or. nOper == 4) .And. !Empty(cCliente) .And. !Empty(cLoja)

		DbSelectArea("NUH")
		NUH->( DbSetOrder(1) )	//NUH_FILIAL+NUH_COD+NUH_LOJA
		If !( NUH-> ( DbSeek(xFilial("NUH") + cCliente + cLoja) ) )

			lRet := .F.

			cMsgItem := STR0193+CRLF+CRLF  //"Atenção. Favor complementar as informações do cadastro de cliente para criar o processo. "
			cMsgItem +="  " + RetTitle("NUH_AJNV") 	+ CRLF
			cMsgItem +="  " + RetTitle("NUH_DSPDIS")+ CRLF
			cMsgItem +="  " + RetTitle("NUH_EMFAT")	+ CRLF
			cMsgItem +="  " + RetTitle("NUH_FPAGTO")+ CRLF
			cMsgItem +="  " + RetTitle("NUH_SITCAD")+ CRLF
			cMsgItem +="  " + RetTitle("NUH_SITCLI")+ CRLF
			cMsgItem +="  " + RetTitle("NUH_ATIVO")	+ CRLF
			cMsgItem +="  " + RetTitle("NUH_PERFIL")+ CRLF

			cMsgItem += CRLF + STR0194 + CRLF	//"No cadastro de Clientes."

			JurMsgErro(cMsgItem)

		ElseIf cIntegra == "1" .And. Empty(NUH->NUH_CTABH)
			lRet := .F.
			//"Parametro de integração JURI/PFS ativado!"+ CHR(13)+"Favor complementar o cadastro de cliente com " + "o código da tabela de honorarios !"
			JurMsgErro(STR0198+ CHR(13)+STR0199 + STR0200)
		EndIf
	EndIf

	RestArea(aAreaNUH)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall100
Função que chama a JURA100.

@param 	cProcesso 	Código do Assunto Jurídico \r\n
@param  lPesq   	  .T. - Indica que a rotina foi chamada pela tela de
										Pesquisa(JURA100) ou
										.F. - Indica que a rotina foi chamada por dentro
										do Processo(JURA095) via ações relacionadas

@author André Spirigoni Pinto
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall100(cProcesso, lChgAll, oModel095, aModel095, nOpc, cFiltroAux)

	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()

	Default cFiltroAux := ""

	//JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA100' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA100

	JURA100(cProcesso, lChgAll, oModel095, aModel095, FwFldGet("NSZ_FILIAL"), cFiltroAux)

	//Atualiza Fase Processual
	If oModel095:GetModel("NSZMASTER"):HasField("NSZ_FASEPR") .And. nOpc <> 5
		oModel095:LoadValue("NSZMASTER", "NSZ_FASEPR", JURA100Fase())
	EndIf

	SetFunName( cFunName )
	AcBrowse := cAceAnt
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall098
Função que chama a JURA098.

@param 	cProcesso 	Código do Assunto Jurídico

@author André Spirigoni Pinto
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall098(cProcesso, nOpc, cBrwFilial, lChgAll)
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()

	//JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA098' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA098

	JURA098(cProcesso, cBrwFilial, lChgAll)

	SetFunName( cFunName )
	AcBrowse := cAceAnt
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall106
Função que chama a JURA106.

@param 	cProcesso 	Código do Assunto Jurídico \r\n
@param  lPesq   	  .T. - Indica que a rotina foi chamada pela tela de
										Pesquisa(JURA106) ou
										.F. - Indica que a rotina foi chamada por dentro
										do Processo(JURA095) via ações relacionadas

@author André Spirigoni Pinto
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall106(cProcesso, lChgAll, nOpc)
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()

	//JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA106' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA100

	JURA106(cProcesso, lChgAll, FwFldGet("NSZ_FILIAL"))

	SetFunName( cFunName )
	AcBrowse := cAceAnt
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall124
Função que chama a JURA124.

@param 	cProcesso 	Código do Assunto Jurídico

@author André Spirigoni Pinto
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall124(cProcesso, lChgAll)
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()

	//JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA124' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA098

	JURA124(cProcesso, FwFldGet("NSZ_FILIAL"), lChgAll)

	SetFunName( cFunName )
	AcBrowse := cAceAnt
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall094
Função que chama a JURA094.

@param 	cProcesso 	Código do Assunto Jurídico

@author André Spirigoni Pinto
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall094(cProcesso, oModel095, nAtualiza, nOpc, lChgAll, cFilProc)

	Local aArea      := GetArea()
	Local aAreaNSZ   := NSZ->( GetArea() )
	Local cAceAnt    := AcBrowse
	Local cFunName   := FunName()
	Local lCmpProg   := .F.
	Local lCmpVlPro  := .F.
	Local lCmpVlProA := .F.
	Local lCmpVlPrPo := .F.
	Local lCmpVPrPoA := .F.
	Local lCmpVlPrRe := .F.
	Local lCmpVPrReA := .F.
	Local lCmpVlEnv  := .F.
	Local lCmpVlEnvA := .F.
	Local lCmpVlRdPr := .F.
	Local lCmpVlRdPo := .F.
	Local lCmpVlRdRe := .F.
	Local nVlProvPed := 0
	Local dData      := Date()
	Local cMoeCod    := SuperGetMv("MV_JCMOPRO", .F., "01")		//Código da moeda da provisão
	Local cMoeDesc   := JurGetDados("CTO", 1, xFilial('CTO') + cMoeCod, "CTO_SIMB")
	Local cProg      := ""
	Local aVlEnvol   := {}
	Local cProgOld   := ""
	Local nVProPeOld := 0

	Default cFilProc := FwFldGet("NSZ_FILIAL")

	//JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA094' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA094

	// Pega os valores de provisão antes de entrar na Jura094
	If ( JGetParTpa(cTipoASJ, "MV_JVLPROV", "1") == "2" ) .And. ( JGetParTpa(cTipoASJ, "MV_JVLPROV", "1") == "2" )
		cProgOld := J94ProgObj(cFilProc, cProcesso)
		nVProPeOld:= JA095VlPro()
	EndIf

	If JURA094(cProcesso, oModel095, cFilProc, lChgAll)
		nAtualiza := 2  //Para confirmar no JURA100 que atualizou o registro.

		//Define de onde sera pego o valor da provisao 1 = Processo \ 2 = Objetos
		If JGetParTpa(cTipoASJ, "MV_JVLPROV", "1") == "2"

			//Força o posicionamento da NSZ
			NSZ->( DbSetOrder(1) )	//NSZ_FILIAL + NSZ_COD
			NSZ->( DbSeek(cFilProc + cProcesso) )

			//Verifica se existe os campos de valores no model
			If oModel095 <> Nil
				lCmpProg   := oModel095:GetModel("NSZMASTER"):HasField("NSZ_CPROGN")
				lCmpVlPro  := oModel095:GetModel("NSZMASTER"):HasField("NSZ_VLPROV")
				lCmpVlProA := oModel095:GetModel("NSZMASTER"):HasField("NSZ_VAPROV")
				lCmpVlPrPo := oModel095:GetModel("NSZMASTER"):HasField("NSZ_VLPRPO")
				lCmpVPrPoA := oModel095:GetModel("NSZMASTER"):HasField("NSZ_VLPPOA")
				lCmpVlPrRe := oModel095:GetModel("NSZMASTER"):HasField("NSZ_VLPRRE")
				lCmpVPrReA := oModel095:GetModel("NSZMASTER"):HasField("NSZ_VLPREA")
				lCmpVlEnv  := oModel095:GetModel("NSZMASTER"):HasField("NSZ_VLENVO")
				lCmpVlEnvA := oModel095:GetModel("NSZMASTER"):HasField("NSZ_VAENVO")
				lCmpVlRdPr := oModel095:GetModel("NSZMASTER"):HasField("NSZ_VRDPRO")
				lCmpVlRdPo := oModel095:GetModel("NSZMASTER"):HasField("NSZ_VRDPOS")
				lCmpVlRdRe := oModel095:GetModel("NSZMASTER"):HasField("NSZ_VRDREM")
			EndIf

			//Atualiza o prognóstico que foi atualizado pelos objetos
			If lCmpProg

				cProg := J94ProgObj(cFilProc, cProcesso)
				if cProg <> cProgOld
					If !Empty(cProg) .And. cProg <> oModel095:GetValue("NSZMASTER", "NSZ_CPROGN")
						oModel095:SetValue("NSZMASTER", "NSZ_CPROGN", cProg)
					EndIf
				EndIf
			EndIf

			//Faz a correção de valores
			JURCORVLRS('NSY', , , , .T.)

			//Seta valor de provisao provavel
			If lCmpVlPro

				//Pega valor de provisao
				nVlProvPed := JA095VlPro()
				If nVlProvPed <> nVProPeOld

					If nVlProvPed <> oModel095:GetValue("NSZMASTER", "NSZ_VLPROV")
						oModel095:LoadValue("NSZMASTER", "NSZ_VLPROV", nVlProvPed)
					EndIf

					//Verifica se existe valor de provisão para preencher campos de data e moeda
					If oModel095:GetValue("NSZMASTER", "NSZ_VLPROV") > 0
						oModel095:LoadValue("NSZMASTER", "NSZ_DTPROV", dData	)
						oModel095:LoadValue("NSZMASTER", "NSZ_CMOPRO", cMoeCod	)
						oModel095:LoadValue("NSZMASTER", "NSZ_DMOPRO", cMoeDesc	)
					Else
						oModel095:ClearField("NSZMASTER", "NSZ_DTPROV")
						oModel095:ClearField("NSZMASTER", "NSZ_CMOPRO")
						oModel095:ClearField("NSZMASTER", "NSZ_DMOPRO")
					EndIf

					//Seta valor de provisao atualizado
					If lCmpVlProA
						oModel095:LoadValue("NSZMASTER", "NSZ_VAPROV", JA094VlDis(cProcesso, "1", .T.,,.T.)[1][1])
					EndIf

					//Seta valor de provisao possível
					If lCmpVlPrPo
						oModel095:LoadValue("NSZMASTER", "NSZ_VLPRPO", JA094VlDis(cProcesso, "2", .F.))
					EndIf

					//Seta valor de provisao possível atualizado
					If lCmpVPrPoA
						oModel095:LoadValue("NSZMASTER", "NSZ_VLPPOA", JA094VlDis(cProcesso, "2", .T.,,.T.)[1][1])
					EndIf

					//Seta valor de provisao remoto
					If lCmpVlPrRe
						oModel095:LoadValue("NSZMASTER", "NSZ_VLPRRE", JA094VlDis(cProcesso, "3", .F.))
					EndIf

					//Seta valor de provisao remoto atualizado
					If lCmpVPrReA
						oModel095:LoadValue("NSZMASTER", "NSZ_VLPREA", JA094VlDis(cProcesso, "3", .T.,,.T.)[1][1])
					EndIf
				EndIf
			EndIf

			aVlEnvol := JA094VlEnv(cProcesso, cFilProc)
			//Seta valor do envolvido
			If lCmpVlEnv

				oModel095:LoadValue("NSZMASTER", "NSZ_VLENVO", aVlEnvol[1][1] )

				//Verifica se existe valor de envolvido para preencher campos de data e moeda
				If oModel095:GetValue("NSZMASTER", "NSZ_VLENVO") > 0
					oModel095:LoadValue("NSZMASTER", "NSZ_DTENVO", dData	)
					oModel095:LoadValue("NSZMASTER", "NSZ_CMOENV", cMoeCod	)
					oModel095:LoadValue("NSZMASTER", "NSZ_DMOENV", cMoeDesc	)
				Else
					oModel095:ClearField("NSZMASTER", "NSZ_DTENVO")
					oModel095:ClearField("NSZMASTER", "NSZ_CMOENV")
					oModel095:ClearField("NSZMASTER", "NSZ_DMOENV")
				EndIf
			EndIf

			//Seta valor do envolvido atualizado
			If lCmpVlEnvA
				oModel095:LoadValue("NSZMASTER", "NSZ_VAENVO", aVlEnvol[1][2])
			EndIf

			//Seta valor Redutor dos pedidos (a soma deles) - Provavel
			If lCmpVlRdPr
				oModel095:LoadValue("NSZMASTER", "NSZ_VRDPRO", JA94CALRED(cProcesso,,'1'))
			Endif

			//Seta valor Redutor dos pedidos (a soma deles) - Possivel
			If lCmpVlRdPo
				oModel095:LoadValue("NSZMASTER", "NSZ_VRDPOS", JA94CALRED(cProcesso,,'2'))
			Endif

			//Seta valor Redutor dos pedidos (a soma deles) - Remoto
			If lCmpVlRdRe
				oModel095:LoadValue("NSZMASTER", "NSZ_VRDREM", JA94CALRED(cProcesso,,'3'))
			Endif
		EndIf

	EndIf

	RestArea(aAreaNSZ)
	RestArea(aArea)

	SetFunName( cFunName )
	AcBrowse := cAceAnt

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall099
Função que chama a JURA099.

@param 	cProcesso 	Código do Assunto Jurídico

@author André Spirigoni Pinto
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall099(cProcesso, nOpc, lChgAll)
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()

	//JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA099' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA098

	JURA099(cProcesso, lChgAll, FwFldGet("NSZ_FILIAL"))

	SetFunName( cFunName )
	AcBrowse := cAceAnt
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall088
Função que chama a JURA088.

@param 	cProcesso 	Código do Assunto Jurídico

@author André Spirigoni Pinto
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall088(cProcesso, cInstancia, cCorresp, clCorresp , ljura132 , cTpCont , cReajustado, nOpc, lChgAll)
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()

	//JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA088' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA098

	JURA088(cProcesso, cInstancia, cCorresp, clCorresp, ljura132, cTpCont, cReajustado, lChgAll, FwFldGet("NSZ_FILIAL"))

	SetFunName( cFunName )
	AcBrowse := cAceAnt
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall177
Função que chama a JURA177.

@param 	cProcesso 	Código do Assunto Jurídico
@param 	cBrwFilial 	Filial associada ao assunto jurídico

@author André Spirigoni Pinto
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall177(cProcesso,cBrwFilial)
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()

// JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA177' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA100

	JURA177(cProcesso,cBrwFilial)

	SetFunName( cFunName )
	AcBrowse := cAceAnt

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall233
Função que chama a JURA233.

@param 	cProcesso 	Código do Assunto Jurídico

@author André Spirigoni Pinto
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall233(cCajuri, oModel095)
	Local cAceAnt     := AcBrowse
	Local cFunName    := FunName()
	Local nOpc        := 0
	Local cStr        := ''
	Local lisClose    := .T.
	Local lRet        := .T.
	Local oModelNUQ	  := oModel095:GetModel("NUQDETAIL")
	Local nLinhaAtu	  := oModelNUQ:nLine

	lisClose  := oModel095:GetValue('NSZMASTER','NSZ_SITUAC') <> '2'

	//Posiciona na instância origem\atual
	If !oModelNUQ:SeekLine( { {"NUQ_INSATU", "1"} } )
		JurMsgErro(STR0279)	//"Não foi encontrada a instância origem, verifique!"
		lRet := .F.
	EndIf

	If lRet

		//JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
		AcBrowse := Replicate("x",10)
		SetFunName( 'JURA233' )

		DbSelectArea('O08')
		O08->(dbSetOrder(1))
		If O08->(dbSeek(xFilial('O08') + cCajuri))
			If lisClose
				nOpc:= MODEL_OPERATION_UPDATE
				cStr := STR0004	//"Alterar"
			Else
				nOpc := MODEL_OPERATION_VIEW
				cStr := STR0002	//"Visualizar"
			EndIf
		ElseIf lisClose
			nOpc := MODEL_OPERATION_INSERT
			cStr := STR0003	//"Incluir"
		Else
			ApMsgStop(STR0276)	//"O processo está encerrado, e por esse motivo não é possivel a inclusão do E-Social"
			lRet := .F.
		EndIf

		If lRet

			//Envia a mascara do processo para a tela do e-social
			oModelO08 := FWLoadModel("JURA233")
			oModelO08:SetOperation(nOpc)
			oModelO08:Activate()

			If nOpc == MODEL_OPERATION_INSERT
				oModelO08:SetValue("O08MASTER", "O08_NUMPRO", oModelNUQ:GetValue("NUQ_NUMPRO"))
				oModelO08:SetValue("O08MASTER", "O08_UFVARA", oModelNUQ:GetValue("NUQ_ESTADO"))
				oModelO08:SetValue("O08MASTER", "O08_IDVARA", oModelNUQ:GetValue("NUQ_CCOMAR"))
			EndIf

			FWExecView(cStr, "JURA233", nOpc, , {||lRet := .T., lRet}, , , , , , , oModelO08)
		EndIf

		SetFunName( cFunName )
		AcBrowse := cAceAnt
	EndIf

	//Volta a linha que estava posicionada na instância
	oModelNUQ:GoLine(nLinhaAtu)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall275
Função que chama a JURA275.

@param cCajuri    Código do processo
@param oModel095  Modelo de dados da JURA095

@author Cristiane Nishizaka
@since 10/06/2020
/*/
//-------------------------------------------------------------------
Function JCall275(cCajuri, oModel095)
Local cAceAnt     := AcBrowse
Local cFunName    := FunName()
Local nOpc        := 0
Local cStr        := ''
Local lIsClose    := .T.
Local oModelO11   := Nil

	lIsClose  := oModel095:GetValue('NSZMASTER','NSZ_SITUAC') <> '2'

	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA275' )

	DbSelectArea('O11')
	O11->(dbSetOrder(1))
	If O11->(dbSeek(xFilial('O11') + cCajuri))
		If lIsClose
			nOpc:= MODEL_OPERATION_UPDATE
			cStr := STR0004	//"Alterar"
		Else
			nOpc := MODEL_OPERATION_VIEW
			cStr := STR0002	//"Visualizar"
		EndIf
	ElseIf lIsClose
		nOpc := MODEL_OPERATION_INSERT
		cStr := STR0003	//"Incluir"
	EndIf

	//Envia a mascara do processo para a tela dos campos contábeis complementares
	oModelO11 := FWLoadModel("JURA275")
	oModelO11:SetOperation(nOpc)
	oModelO11:Activate()

	FWExecView(cStr, "JURA275", nOpc, , {||lRet := .T., lRet}, , , , , , , oModelO11)

	SetFunName( cFunName )
	AcBrowse := cAceAnt

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall254
Função que chama a JCall254.

@param 	cProcesso 	Código do Assunto Jurídico
@param 	cBrwFilial 	Filial associada ao assunto jurídico

@author André Spirigoni Pinto
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall254(cProcesso, lChgAll, cFilFiltro)
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()

    // JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA254' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA100

	JURA254(cProcesso, lChgAll, cFilFiltro)

	SetFunName( cFunName )
	AcBrowse := cAceAnt

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall260
Função que chama a rotina de Liminares (JURA260).

@author  Rafael Tenorio da Costa
@since 	 12/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall260(oModel, lChgAll)

	Local aArea      := GetArea()
	Local aAreaNSZ   := NSZ->( GetArea() )
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()
	Local cFilPro  := oModel:GetValue("NSZMASTER", "NSZ_FILIAL")
	Local cCodPro  := oModel:GetValue("NSZMASTER", "NSZ_COD")

	//JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA260' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA098

	//Seta o modelo do JURA095 para atualizações no JURA260
	J260Set095(oModel)

	JURA260(cFilPro, cCodPro, lChgAll)

	SetFunName( cFunName )
	AcBrowse := cAceAnt

	RestArea(aAreaNSZ)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall268
Função que chama a rotina de Leitura de Iniciais (JURA268).

@since 	 18/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall268(oModel)

	If Empty(oModel:GetValue("NSZMASTER", "NSZ__DIRPDF")) .and. oModel:GetOperation()==3
		J268Inic(oModel)
	Elseif oModel:GetOperation()<>3
		ApMsgInfo(STR0301) //"Esta operação é permitida somente na inclusão"
	Else
		ApMsgInfo(STR0300) //"Inicial já carregada para este assunto jurídico"
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J95ACTVMOD
Pré-validação dos dados passando os dados do Modelo Anterior, caso exista.
Uso geral.

@author Antonio Carlos Ferreira
@since 27/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95ACTVMOD(oModelATU)

	If  (oModelANT != nil) .And. !( lCopiou )

		J95COPYMOD(@oModelANT, @oModelATU, "NSZMASTER", aModelos)
		lCopiou := .T.

	EndIf

	//Inicializa os campos da Liminar apos chamada da FwExecView(), quando não for multiplas liminar
	If lXLiminar .And. !SuperGetMv("MV_JMULLIM", , .F.)

		If oModelATU:GetModel("NSZMASTER"):HasField("NSZ_CSTATL")
			oModelATU:LoadValue("NSZMASTER", "NSZ_CSTATL", cXStatus)

			If  (cXStatus == "1") .OR. (cXStatus == "3") //Vigor
				oModelATU:LoadValue("NSZMASTER", "NSZ_OBSLIV", cXObserv)
				oModelATU:ClearField("NSZMASTER", "NSZ_OBSLIR")
			Else
				oModelATU:LoadValue("NSZMASTER", "NSZ_OBSLIR", cXObserv)
				oModelATU:ClearField("NSZMASTER", "NSZ_OBSLIV")
			EndIf
		EndIf

		lXLiminar := .F.  //Anula as variaveis staticas.
		cXStatus  := ""
		cXObserv  := ""
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J95CPONT9
Função que desabilita a edição dos principais campos para forçar
que os usuários utilizem a origem de entidades quando o parâmetro
estiver habilitado.

@return lRet
@author André Spirigoni Pinto
@since 24/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95CPONT9(oStruct, cCampo)
	Local lRet      := .T.

	If oStruct:HasField(cCampo)
		oStruct:SetProperty( cCampo, MVC_VIEW_CANCHANGE, .F. )
	Endif

Return lRet


/*/{Protheus.doc} J095SvMod(oModel)
Função para salvar um modelo com as informações do assunto jurídico que o usuário achar necessário.
Podendo ser utilizado ao realizar a inclusão de um processo.

Uso Geral
@Param oModel  Modelo de dados

@Return

@author Wellington Coelho
@since 09/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095SvMod(oModel, aModActi, cTipo, cNome)
	Local aArea    := GetArea()
	Local aAreaNZ3 := NZ3->( GetArea() )
	Local aAreaNZ4 := NZ4->( GetArea() )
	Local oAux1    := Nil
	Local oStruct1 := Nil
	Local aCampos  := {}
	Local cCodMod  := oModel:GetModel("NSZMASTER"):GetValue("NSZ__CMOD") // carrega o codigo do modelo, quando o processo é aberto utilizando um modelo
	Local lSobres  := .F.
	Local nI       := 0
	Local nX       := 0
	Local lRet     := .T.
	Local lNome    := .T.
	Local lGrid    := .F.
	Local nLine	   := 0
	DEFAULT cNome  := ''//Só vem preenchido quando é automação

	If !Empty(cCodMod)
		lSobres := ApMsgYesNo(STR0227)//"Você deseja sobrescrever o modelo atual?"
	Endif

	if (!lSobres)

		While lRet .And. lNome
			If Empty(cNome)
				cNome   := JurInput(STR0228,STR0229,50,.T.)//"Informe um nome para o modelo:",//"Novo modelo"
			EndIf

			lNome := !Empty(JurGetDados('NZ3',2,xFilial("NZ3") + FwFldGet("NSZ_TIPOAS") + cNome,"NZ3_COD"))
			If !JurAuto() .And. lNome .And. !Empty(cNome)
				JurMsgErro(STR0233)
			Endif

			If Empty(cNome) .OR. (!JurAuto() .And. lNome )
				lRet := .F.
			Endif
		End
		If lRet
			cCodMod := GETSXENUM("NZ3","NZ3_COD")
		
			Reclock( "NZ3", .T. )
			NZ3->NZ3_COD    := cCodMod
			NZ3->NZ3_NOME   := cNome
			NZ3->NZ3_TIPOAS := FwFldGet("NSZ_TIPOAS")
			If NZ3->(FieldPos('NZ3_TIPO')) > 0 //proteção campo novo.
				NZ3->NZ3_TIPO	:= cTipo
			Endif
			NZ3->(MsUnlock())
			If __lSX8
				ConfirmSX8()
			EndIf
		EndIf
	Else // Caso usuario queira sobrescrever todos os registros do modelo são apagados e preenchidos novamente com as informações atuais.
		DbSelectArea("NZ4")
		NZ4->(DbSetOrder(1))
		While NZ4->(dbSeek(xFilial('NZ4')+cCodMod))
			Reclock( "NZ4", .F. )
			NZ4->(dbDelete())
			NZ4->(MsUnLock())
		End
	Endif

	If lRet
		For nX := 1 to len(aModActi)
			oAux1    := oModel:GetModel(aModActi[nX][1]) //Instancia do model ativo
			If	oAux1 <> nil // Verifica se o Grid foi adicionado na View
				lGrid    := aModActi[nX][2]
				oStruct1 := oAux1:GetStruct()
				aCampos  := oStruct1:GetFields() // Array com os campos da estrutura
				For nI := 1 to len(aCampos) // verifica se o campo foi alterado, para adicionar no modelo de processo.
					If AllTrim(aCampos[nI][3]) == "NSZ__CMOD"
						Loop
					Endif
					If oAux1:IsFieldUpdated(aCampos[nI][3]) .AND. !EMPTY(FwFldGet(aCampos[nI][3])) .AND. !lGrid
						Reclock( 'NZ4', .T. )
						NZ4->NZ4_CMOD	  := cCodMod
						NZ4->NZ4_ITEM	:= '01'
						NZ4->NZ4_NOMEMD := aModActi[nX][1]
						NZ4->NZ4_NOMEC  := aCampos[nI][3]
						NZ4->NZ4_TIPO   := aCampos[nI][4]
						If aCampos[nI][4] == "D" //Caso o campo seja do tipo data
							NZ4->NZ4_VALORC := Alltrim(DTOC(FwFldGet(aCampos[nI][3])))
						ElseIf aCampos[nI][4] == "N" //Caso o campo seja do tipo numerico
							NZ4->NZ4_VALORC := Alltrim(STR(FwFldGet(aCampos[nI][3])))
						ElseIf aCampos[nI][4] == "L" //Caso o campo seja do tipo numerico
							NZ4->NZ4_VALORC := Iif( FwFldGet( aCampos[nI][3]),'T','F' )
						Else
							NZ4->NZ4_VALORC := FwFldGet(aCampos[nI][3])
						Endif
						NZ4->(MsUnlock())
					ElseIf lGrid
						For nLine := 1 To oAux1:GetQtdLine()
							If !oAux1:IsDeleted(nLine) .AND. oAux1:IsFieldUpdated(aCampos[nI][3]) .AND. !EMPTY(FwFldGet(aCampos[nI][3]))
								oAux1:nLine := nLine//aqui
								Reclock( 'NZ4', .T. )
								NZ4->NZ4_CMOD	  := cCodMod
								NZ4->NZ4_ITEM	:= StrZero(nLine,2)
								NZ4->NZ4_NOMEMD := aModActi[nX][1]
								NZ4->NZ4_NOMEC  := aCampos[nI][3]
								NZ4->NZ4_TIPO   := aCampos[nI][4]
								If aCampos[nI][4] == "D" //Caso o campo seja do tipo data
									NZ4->NZ4_VALORC := Alltrim(DTOC(FwFldGet(aCampos[nI][3])))
								ElseIf aCampos[nI][4] == "N" //Caso o campo seja do tipo numerico
									NZ4->NZ4_VALORC := Alltrim(STR(FwFldGet(aCampos[nI][3])))
								Else
									NZ4->NZ4_VALORC := FwFldGet(aCampos[nI][3])
								Endif
								NZ4->(MsUnlock())
							EndIF
						Next
					EndIf
				Next
			EndIf
		Next
		If !JurAuto()
			ApMsgInfo(STR0230)//"Modelo salvo com sucesso"
		EndIf
	EndIf
	aSize(aCampos, 0)
	RestArea(aAreaNZ4)
	RestArea(aAreaNZ3)
	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Ja095CorCA
Valida correspondente com a comarca e area.
Uso geral.

@author Rafael Tenorio da Costa
@since 24/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja095CorCA(cCodCor, cLojCor, cAreaJuri, cComarca)

	Local lRetorno 	:= .T.
	Local cTabela	:= ""
	Local cQuery	:= ""
	Local lComarca	:= .F.
	Local cJoin		:= ""
	Local cWhere	:= ""

	If ( !Empty(cCodCor) .Or. !Empty(cLojCor) ) .And. ( !Empty(cAreaJuri) .Or. !Empty(cComarca) )

		cTabela := GetNextAlias()

		cQuery := " SELECT A2_COD, A2_LOJA " + CRLF
		cQuery += " FROM " +RetSqlName("SA2")+ " SA2 " + CRLF

		//Monta join e where da comarca
		If !Empty(cComarca)
			lComarca := .T.

			cJoin	:= " INNER JOIN " +RetSqlName("NU3")+ " NU3 ON A2_COD = NU3_CCREDE AND A2_LOJA = NU3_LOJA " + CRLF
			cWhere	:= " NU3_CCOMAR = '" +cComarca+ "' AND NU3.D_E_L_E_T_ = ' ' " + CRLF
		EndIf

		//Monta join e where da area juridica
		If !Empty(cAreaJuri)

			If lComarca
				cWhere += " AND "
			EndIf

			cJoin	+= CRLF + " INNER JOIN " +RetSqlName("NVI")+ " NVI ON A2_COD = NVI_CCREDE AND A2_LOJA = NVI_CLOJA " + CRLF
			cWhere 	+= CRLF + " NVI_CAREA = '" +cAreaJuri+ "' AND NVI.D_E_L_E_T_ = ' ' " + CRLF
		EndIf

		cQuery += cJoin
		cQuery += " WHERE A2_COD = '"	+cCodCor+ "' AND " + CRLF
		cQuery += 		" A2_LOJA = '" 	+cLojCor+ "' AND " + CRLF
		cQuery += 		" SA2.D_E_L_E_T_ = ' ' AND " + CRLF
		cQuery += cWhere

		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)

		//Verifica se nao encontrou o correspondente
		If (cTabela)->( Eof() )
			lRetorno := .F.
		EndIf

		(cTabela)->( DbCloseArea() )
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Ja095F3Asj
Retorna e Atualiza variavel statica lF3AssuJu, necessaria na consulta do assunto juridico.
Necessaria depois da alteração da view que ira abrir a tabela NSZ - X2_SYSOBJ = JURA095
Uso consulta padrão JURNSZ

@author Rafael Tenorio da Costa
@since 01/07/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja095F3Asj( lAtualiza )
	If lAtualiza <> Nil
		lF3AssuJu := lAtualiza
	EndIf
Return lF3AssuJu

//-------------------------------------------------------------------
/*/{Protheus.doc} J95AltNCAut
Faz as verificação da rotina de abertur automática de caso.
Incluir \ Altera o caso se necessario.

@return lRet
@author Rafael Rezende
@since 07/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95AltNCAut(oModel)
	Local lRet      := .T.
	Local cCliente  := ''
	Local cLoja     := ''
	Local cCajuri   := ''
	Local aTmpError := {}
	Local aDadCaso  := {}
	Local nOpc      := 3
	Local nOpcNVE   := 3
	Local lAtuCaso  := .F.

	Default oModel := FwModelActive()

	//Verifica se é caso automatico  e valida informações do cliente na NUH
	If oModel != Nil .And. (!JA095CAut() .OR. (IsInCallStack("JURA063"))) 
		lRet := J95CliCS()

		If lRet
		
			nOpc := oModel:GetOperation()

			If nOpc == 3
				nOpcNVE  := 3
				lAtuCaso := .T.

			ElseIf nOpc == 4
				nOpcNVE  := 4
				lAtuCaso := .T.

				//Verifica se houve alteração do codigo\loja do cliente para incluir um novo caso
				If ( oModel:IsFieldUpdated("NSZMASTER","NSZ_CCLIEN") .Or. oModel:IsFieldUpdated("NSZMASTER","NSZ_LCLIEN") )

					cCajuri  := oModel:GetValue("NSZMASTER","NSZ_COD")
					cCliente := M->NSZ_CCLIEN
					cLoja	 := M->NSZ_LCLIEN
					aDadCaso := JurGetDados('NSZ', 1 , xFilial('NSZ') + cCajuri, {"NSZ_CCLIEN", "NSZ_LCLIEN", "NSZ_NUMCAS"})

					If ( aDadCaso[1] != cCliente ) .Or. ( aDadCaso[2] != cLoja )
						nOpcNVE := 3
					EndIF

					// Regras de Remanejamento. Somente altera o processo caso Tanto o Cliente Origem quanto Destino for Automático
					If IsInCallStack("JURA063") .And. (!J95CasAut(aDadCaso[1],aDadCaso[2]) .Or. !J95CasAut(cCliente, cLoja))
						lAtuCaso := .F.
					ElseIf IsInCallStack("JURA063") // Caso ambos forem Automáticos. Entra como Alteração se for Remanejamento pois a rotina já cria um novo caso
						nOpcNVE := 4
					EndIf
				EndIf

				//Se o titulo do caso for igual não altera o caso
				If nOpcNVE == 4 .And. AllTrim( JA095TCaso(oModel) ) == AllTrim( oModel:GetValue("NSZMASTER", "NSZ_DCASO") )
					lAtuCaso := .F.
				EndIf
			EndIf

			If (lAtuCaso)
				//Inclui\Altera o caso NVE

				aTmpError := JA095NCaso(nOpcNVE)

				If !( aTmpError[1] )
					lRet := .F.

					If aTmpError[2] == "NVE_SIGLA2"
						JurMsgErro(STR0202 + RetTitle('NUH_SIGLA') + STR0203)					//"Para clientes com geração de 'Caso Automático', será necessário preencher o campo de " + RetTitle('NUH_SIGLA')+ " no cadastro do cliente !"
					Else
						JurMsgErro( AllTrim(aTmpError[2]) + ' - ' + AllTrim(aTmpError[3]) )		//Erro do valid do model da Jura070
					EndIf
				EndIf

			Else

				If nOpc == 4 .And. Empty( oModel:GetValue("NSZMASTER", "NSZ_NUMCAS") )
					lRet := oModel:LoadValue('NSZMASTER', 'NSZ_NUMCAS', aDadCaso[3])
				EndIf
			EndIf
		EndIf
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095VlPro
Retorna o valor da provisao
Uso geral.

@return	nValProvis - Valor da provisao
@author Rafael Tenorio da Costa
@since 12/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095VlPro()
	Local aArea      := GetArea()
	Local aAreaNQ7   := NQ7->(GetArea())
	Local nValProvis := 0
	Local cJVlProv   := JGetParTpa(cTipoASJ, "MV_JVLPROV", "1")		//Define de onde sera pego o valor da provisao 1 = Processo \ 2 = Objetos
	Local lCpoTipo   := .F. // Proteção dos fontes - Verifica se o campo de tipo do follow-up existe no dicionário

	DbSelectArea("NQ7")
	lCpoTipo := ColumnPos('NQ7_TIPO') > 0

	//1 = Valores do Processo
	If cJVlProv == "1" .Or. !lCpoTipo
		nValProvis := FwFldGet("NSZ_VLPROV")

	//2 = Objetos
	ElseIf cJVlProv == "2"
		nValProvis := JA094VlDis( NSZ->NSZ_COD )
	EndIf

	RestArea( aAreaNQ7 )
	RestArea( aArea )

Return nValProvis

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095AtuPro
Atualiza valor de provisão na tabela de histórico - NV3

@Return lRet - .T.\.F.

@author Jorge Luis Branco Martins Junior
@since 25/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA095AtuPro(oModel, nOpc)
	Local aArea     := GetArea()
	Local aAreaNQ7  := NQ7->(GetArea())
	Local lRet      := .T.
	Local cProgn    := ""
	Local oModelNT9 := oModel:GetModel('NT9DETAIL')
	Local nQtdLines := 0
	Local nPorc     := 0
	Local nVal      := 0
	Local nI        := 0
	Local lAltRat   := .F.
	Local aRat      := {}
	Local lCpoTipo  := .F. // Proteção dos fontes - Verifica se o campo de tipo do follow-up existe no dicionário

	DbSelectArea("NQ7")
	lCpoTipo := ColumnPos('NQ7_TIPO') > 0

	Default nOpc    := 4

	//*********************************************************************************************************************
	// Controle do rateio de provisão entre envolvidos
	//*********************************************************************************************************************

	If oModelNT9 <> NIL .And. oModelNT9:HasField("NT9_PRATPR")

		nQtdLines := oModelNT9:GetQtdLine()

		For nI := 1 To nQtdLines
			If (oModelNT9:GetValue('NT9_TIPOCL', nI)) == '1'
				nPorc := (oModelNT9:GetValue('NT9_PRATPR', nI))

				If nPorc > 0
					nVal := oModel:GetValue('NSZMASTER','NSZ_VLPROV') * (nPorc / 100)
					If nOpc == 3 .Or. oModelNT9:IsFieldUpdated("NT9_CEMPCL", nI)
						lAltRat := .T.
					Else
						lAltRat := .F.
					EndIf
					aAdd(aRat,{oModelNT9:GetValue('NT9_CEMPCL', nI), oModelNT9:GetValue('NT9_LOJACL', nI), nVal, lAltRat})
				EndIf

			EndIf
		Next

	EndIf

	//*********************************************************************************************************************
	// Valor de Provisão - Historico de Movimentacao - NV3
	//*********************************************************************************************************************
	If oModel:GetModel("NSZMASTER"):HasField("NSZ_VLPROV") .And. oModel:GetModel("NSZMASTER"):HasField("NSZ_CPROGN")

		If ( nOpc == MODEL_OPERATION_INSERT 							  .Or. ;
		 	 oModel:GetValue("NSZMASTER","NSZ_DTPROV") <> NSZ->NSZ_DTPROV .Or. ;
			 oModel:GetValue("NSZMASTER","NSZ_VLPROV") <> NSZ->NSZ_VLPROV .Or. ;
			 oModel:GetValue("NSZMASTER","NSZ_CPROGN") <> NSZ->NSZ_CPROGN .Or. ;
			 (oModel:GetValue("NSZMASTER","NSZ_SITUAC") == '2' .And. oModel:GetValue("NSZMASTER","NSZ_SITUAC") <> NSZ->NSZ_SITUAC .And. NSZ->NSZ_VLPROV <> 0) )	//Deverá ser adicionado na NV3 registro quando o processo for encerrado

			If lCpoTipo
				cProgn := JurGetDados('NQ7', 1, xFilial('NQ7') + oModel:GetValue("NSZMASTER",'NSZ_CPROGN') , 'NQ7_TIPO' )
			EndIf

			If (SuperGetMV('MV_JFLUIGA',,'2') == '1') .And. cProgn == '2' .And. (JurGetDados('NQ7', 1, xFilial('NQ7') + NSZ->NSZ_CPROGN , 'NQ7_TIPO' ) == '1') //Allteração de prognóstico de provável para possível
				lRet := JurHisCont(oModel:GetValue("NSZMASTER","NSZ_COD"),,oModel:GetValue("NSZMASTER","NSZ_DTPROV"),0,'1','1','NSZ', nOpc,,,'1',,,, AllTrim(oModel:GetValue("NSZMASTER","NSZ_SITUAC")),,FwFldGet('NSZ_FILIAL'))
			Else
				If Len(aRat) > 0 .And. AllTrim(oModel:GetValue("NSZMASTER","NSZ_SITUAC")) == '1' //Se houver rateio da provisão entre envolvidos
					For nI := 1 To Len(aRat)
						lRet := JurHisCont(oModel:GetValue("NSZMASTER","NSZ_COD"),,oModel:GetValue("NSZMASTER","NSZ_DTPROV"),aRat[nI][3],'1','1','NSZ', nOpc,,,cProgn,aRat[nI][1],aRat[nI][2],aRat[nI][4], AllTrim(oModel:GetValue("NSZMASTER","NSZ_SITUAC")),JurGetDados('NQ7', 1, xFilial('NQ7') + NSZ->NSZ_CPROGN , 'NQ7_TIPO' ),FwFldGet('NSZ_FILIAL'))
					Next
				Else
					lRet := JurHisCont(oModel:GetValue("NSZMASTER","NSZ_COD"),,oModel:GetValue("NSZMASTER","NSZ_DTPROV"),oModel:GetValue("NSZMASTER","NSZ_VLPROV"),'1','1','NSZ', nOpc,,,cProgn,,,, AllTrim(oModel:GetValue("NSZMASTER","NSZ_SITUAC")),JurGetDados('NQ7', 1, xFilial('NQ7') + NSZ->NSZ_CPROGN , 'NQ7_TIPO' ),FwFldGet('NSZ_FILIAL'))
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aAreaNQ7 )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J095WhVlPr
Habilita os campos de provisao para alteracao

@Return lRetorno - .T.\.F.

@author Rafael Tenorio da Costa
@since 28/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095WhVlPr()

	Local lRetorno := .T.

	//Verifica se o valor da provisao 1 = Processo ou se for alteracao do fluig
	If !JurAuto() .And. JGetParTpa(cTipoASJ, "MV_JVLPROV", "1") == "2" .And. !IsInCallStack("JA106ConfNZK")
		lRetorno := .F.
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J095AreaC
Preenche o campo de Área com o valor vindo do parâmetro MV_JAREAC.
Usado quando o tipo de assunto jurídico é CONTRATOS.

@Return cRet - Código da Área indicada no parâmetro

@author Jorge Luis Branco Martins Junior
@since 21/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095AreaC()
	Local cRet := ""

	//Verifica se o tipo do assunto jurídico é CONTRATOS, PROCURAÇÕES ou SOCIETÁRIO (pode ser filho também) para preencher o campo de área automáticamente
	// Primeiro verifica se existe parâmetro por assunto jurídico e retorna seu valor.
	// Caso não exista retorna o valor do parâmetro MV_JAREAC que está no SX6

	If Type("c162TipoAs") == "C" .And. !Empty(c162TipoAs) .And. Type("cTipoAJ") == "C" .And. !Empty(cTipoAJ)
		// Assunto deve ser contratos ou procurações - Se for um assunto Filho é verificado o pai é contrato, procurações ou societário
		// c162TipoAs -> Guarda os códigos dos assuntos. Se for um filho ele guarda o código do pai
		// cTipoAJ    -> Guarda os códigos dos assuntos. Se for um filho ele guarda o código do filho
		If c162TipoAs $ "006|007|008"
			cRet := JGetParTpa(cTipoAJ, "MV_JAREAC", "")
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J95AtOrdem
Função que atualiza a ordem dos campos na view.

@param 	oStruct - Struct que ser atualizado
@param 	cCampo  - Nome do campo a ter a ordem mudada
@param 	cOrdem  - Ordem
@author Rafael Tenorio da Costa
@since 	28/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95AtOrdem(oStruct, cCampo, cOrdem)

	If oStruct:HasField(cCampo)
		oStruct:SetProperty(cCampo, MVC_VIEW_ORDEM, cOrdem)
	Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VldAndAut
Faz as atualizações necessarias para a funcionalidade de andamento automatico

@author Rafael Tenorio da Costa
@since 	26/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldAndAut(oModel)

Local aArea		:= GetArea()
Local oModelNUQ	:= oModel:GetModel("NUQDETAIL")
Local nOpc      := oModel:GetOperation()
Local nCont 	:= 1
Local cNumPro	:= ""
Local cUf		:= ""
Local cComarca	:= ""
Local cTribunal	:= ""
Local lVldCNJ 	:= .T.
Local nLinhaAtu	:= oModelNUQ:nLine

	ProcRegua(0)
	IncProc()

	For nCont := 1 To oModelNUQ:Length()

		oModelNUQ:GoLine(nCont)
		IncProc()

		cNumPro := oModelNUQ:GetValue("NUQ_NUMPRO")
		cUf     := oModelNUQ:GetValue("NUQ_ESTADO")
		lVldCNJ := J183VldCnj(cTipoASJ, oModelNUQ:GetValue("NUQ_CNATUR"))

		If !lVldCNJ
			cComarca 	:= oModelNUQ:GetValue("NUQ_CCOMAR")
			cTribunal 	:= oModelNUQ:GetValue("NUQ_CLOC2N")
		EndIf

		If oModelNUQ:IsInserted() 
			oModel:LoadValue("NUQDETAIL", "NUQ_ANDAUT", "1")
		EndIf

		Do Case

			//Inclusões ou Alterações
			Case oModelNUQ:IsFieldUpdated("NUQ_ANDAUT") .And. oModelNUQ:GetValue("NUQ_ANDAUT") == "1"

				If !J223CadPro(cNumPro, cUf, cComarca,, cTribunal, lVldCNJ)
					oModel:LoadValue("NUQDETAIL", "NUQ_ANDAUT", "3")	//Recusado
				EndIf


			//Exclusão de processo ou instância deletada ou o usuário quer retirar o processo do andamento automatico
			Case MODEL_OPERATION_DELETE == nOpc .Or. oModelNUQ:IsDeleted();
				.Or. (oModelNUQ:IsFieldUpdated("NUQ_ANDAUT") .And. oModelNUQ:GetValue("NUQ_ANDAUT") == "2")

				J223ExcPro(cNumPro, lVldCNJ)

			//Encerramento de processo
			Case oModel:IsFieldUpdated("NSZMASTER", "NSZ_SITUAC") .And. oModel:GetValue("NSZMASTER", "NSZ_SITUAC") == "2"

				//Define se para de receber andamento automático quando o processo for encerrado
				If JGetParTpa(oModel:GetValue("NSZMASTER", "NSZ_TIPOAS"), "MV_JANDEXC", "1") == "1"

					If J223ExcPro(cNumPro, lVldCNJ)
						oModel:LoadValue("NUQDETAIL", "NUQ_ANDAUT", "2")
					EndIf

				//Verifica se a instancia deve ser cadastrada na rotina de andamentos automaticos
				ElseIf oModelNUQ:IsFieldUpdated("NUQ_ANDAUT") .And. oModelNUQ:GetValue("NUQ_ANDAUT") == "1"

					If !J223CadPro(cNumPro, cUf, cComarca,, cTribunal, lVldCNJ)
						oModel:LoadValue("NUQDETAIL", "NUQ_ANDAUT", "3")	//Recusado
					EndIf

				EndIf

		End Case

	Next nCont

	//Volta a linha atual
	oModelNUQ:GoLine(nLinhaAtu)

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J95PosCpVl
Define posição dos campos da NSZ do agrupamento de valores.

@param	oStruct - Struct da tabela NSZ
@author Rafael Tenorio da Costa
@since 	07/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95PosCpVl(oStruct)

	//Ordena a posição dos campos do agrupamento Valores
	J95AtOrdem(oStruct, "NSZ_VLINES", "01")

	J95AtOrdem(oStruct, "NSZ_CPROGN", "02")
	J95AtOrdem(oStruct, "NSZ_DPROGN", "03")

	J95AtOrdem(oStruct, "NSZ_CFCORR", "04")
	J95AtOrdem(oStruct, "NSZ_DFCORR", "05")

	J95AtOrdem(oStruct, "NSZ_DTCAUS", "06")
	J95AtOrdem(oStruct, "NSZ_CMOCAU", "07")
	J95AtOrdem(oStruct, "NSZ_DMOCAU", "08")
	J95AtOrdem(oStruct, "NSZ_VLCAUS", "09")
	J95AtOrdem(oStruct, "NSZ_VACAUS", "10")

	J95AtOrdem(oStruct, "NSZ_DTENVO", "11")
	J95AtOrdem(oStruct, "NSZ_CMOENV", "12")
	J95AtOrdem(oStruct, "NSZ_DMOENV", "13")
	J95AtOrdem(oStruct, "NSZ_VLENVO", "14")
	J95AtOrdem(oStruct, "NSZ_VAENVO", "15")

	J95AtOrdem(oStruct, "NSZ_DTHIST", "16")
	J95AtOrdem(oStruct, "NSZ_CMOHIS", "17")
	J95AtOrdem(oStruct, "NSZ_DMOHIS", "18")
	J95AtOrdem(oStruct, "NSZ_VLHIST", "19")
	J95AtOrdem(oStruct, "NSZ_VAHIST", "20")

	J95AtOrdem(oStruct, "NSZ_CPRHIS", "21")
	J95AtOrdem(oStruct, "NSZ_DPRHIS", "22")

	J95AtOrdem(oStruct, "NSZ_DTPROV", "23")
	J95AtOrdem(oStruct, "NSZ_CMOPRO", "24")
	J95AtOrdem(oStruct, "NSZ_DMOPRO", "25")
	J95AtOrdem(oStruct, "NSZ_VLPROV", "26")
	J95AtOrdem(oStruct, "NSZ_VAPROV", "27")

	J95AtOrdem(oStruct, "NSZ_DTJPRO", "28")
	J95AtOrdem(oStruct, "NSZ_VCPROV", "29")
	J95AtOrdem(oStruct, "NSZ_VJPROV", "30")

	//2 = Provisão pelos Objetos
	If JGetParTpa(cTipoASJ, "MV_JVLPROV", "1") == "2"	//Define de onde sera pego o valor da provisao 1 = Processo \ 2 = Objetos
		J95AtOrdem(oStruct, "NSZ_VLPRPO", "31")
		J95AtOrdem(oStruct, "NSZ_VLPPOA", "32")
		J95AtOrdem(oStruct, "NSZ_VLPRRE", "33")
		J95AtOrdem(oStruct, "NSZ_VLPREA", "34")
	EndIf

	J95AtOrdem(oStruct, "NSZ_JUSTIF", "35")
	J95AtOrdem(oStruct, "NSZ_DTULAT", "36")
	J95AtOrdem(oStruct, "NSZ_SAPE"  , "37")
	J95AtOrdem(oStruct, "NSZ_DTUASP", "38")
	J95AtOrdem(oStruct, "NSZ_SJUIZA", "39")
	J95AtOrdem(oStruct, "NSZ_DTUASJ", "40")

	//Campos do tipo assunto juridico de contratos
	J95AtOrdem(oStruct, "NSZ_DTCONT", "41")
	J95AtOrdem(oStruct, "NSZ_CMOCON", "42")
	J95AtOrdem(oStruct, "NSZ_DMOCON", "43")
	J95AtOrdem(oStruct, "NSZ_VLCONT", "44")
	J95AtOrdem(oStruct, "NSZ_VACONT", "45")
	J95AtOrdem(oStruct, "NSZ_MULCON", "46")
	J95AtOrdem(oStruct, "NSZ_CCPCON", "47")
	J95AtOrdem(oStruct, "NSZ_DCPCON", "48")

	//Adiciona quebra de linha para melhor posicionar os campos do agrupamento de Valores
	If oStruct:HasField("NSZ_DPROGN")
    	oStruct:SetProperty('NSZ_DPROGN',MVC_VIEW_INSERTLINE,.T.)
   	Endif

   	If oStruct:HasField("NSZ_VACAUS")
    	oStruct:SetProperty('NSZ_VACAUS',MVC_VIEW_INSERTLINE,.T.)
   	Endif

   	If oStruct:HasField("NSZ_DFCORR")
    	oStruct:SetProperty('NSZ_DFCORR',MVC_VIEW_INSERTLINE,.T.)
   	Endif

   	If oStruct:HasField("NSZ_DPRHIS")
    	oStruct:SetProperty('NSZ_DPRHIS',MVC_VIEW_INSERTLINE,.T.)
   	Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J95EnvTab
Faz as configurações no dos envolvidos verificando se esta ativo
o cadastro tabelado de envolvidos a partir de informacoes de entidades externas.

@param	oStructNT9 - Struct da tabela NT9
@author Rafael Tenorio da Costa
@since 	07/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95EnvTab(oStructNT9)

	//Envolvidos tabelados ativo
	If SuperGetMV('MV_JENVENT',, '2') == "1"

		If (oStructNT9:HasField( "NT9_COD" ))
			oStructNT9:RemoveField( "NT9_COD" )
		Endif

		If (oStructNT9:HasField( "NT9_TIPOCL" ))
			oStructNT9:RemoveField( "NT9_TIPOCL" )
		Endif

		If (oStructNT9:HasField( "NT9_TFORNE" ))
			oStructNT9:RemoveField( "NT9_TFORNE" )
		Endif

		J95CPONT9(oStructNT9, "NT9_CEMPCL")
		J95CPONT9(oStructNT9, "NT9_LOJACL")
		J95CPONT9(oStructNT9, "NT9_CFORNE")
		J95CPONT9(oStructNT9, "NT9_LFORNE")
		J95CPONT9(oStructNT9, "NT9_NOME")

	//valida se os campos estão na tela e caso estejam, retirar os mesmos.
	Else

		If (oStructNT9:HasField( "NT9_ENTIDA" ))
			oStructNT9:RemoveField( "NT9_ENTIDA" )
		Endif

		If (oStructNT9:HasField( "NT9_CODENT" ))
			oStructNT9:RemoveField( "NT9_CODENT" )
		Endif

		If (oStructNT9:HasField( "NT9_DENTID" ))
			oStructNT9:RemoveField( "NT9_DENTID" )
		Endif

	Endif

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} J99GerDes
Geração de despesa a partir do encerramento do processo pelo acordo de sentença

@param oModel Modelo ativo
@param cNSZ_COD codigo do processo
@param nNT3ValGer Valor da despesa
@param cNYQMoeda Moeda
@param cNYQData Data
@param lNYPAcordo verifica se veio do acordo

@author Willian Yoshiaki Kazahaya
@since  21/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J99GerDes(oModel, cNSZ_COD, nNT3ValGer, cNYQMoeda, cNYQData, lNYPAcordo)
Local oModelNew
Local aArea    := GetArea()
Local aAreaNSZ := NSZ->( GetArea() )

	oModelNew   := FWLoadModel('JURA099')
	// Processo de inclusão
	oModelNew:SetOperation(3)
	// Ativação do fonte
	oModelNew:Activate()

	oModelNew:SetValue("NT3MASTER","NT3_CAJURI", cNSZ_COD)
	oModelNew:SetValue("NT3MASTER","NT3_VALOR", nNT3ValGer)
	oModelNew:SetValue("NT3MASTER","NT3_CMOEDA", cNYQMoeda)
	oModelNew:SetValue("NT3MASTER","NT3_DATA", cNYQData)
	If !IsBlind()
	FWExecView(/*cTitulo*/, "JURA099"/*cPrograma*/, 3,  /*oDlg*/, {|| lRet := .T., lRet},, /*nPercReducao*/, /*aEnableButtons*/, {|| .T.}/*bCancel*/, /*cOperatId*/,  /*cToolBar*/, oModelNew/*oModelAct*/)	//"Alterar"
	Else
		oModelNew:SetValue("NT3MASTER","NT3_CTPDES", _cTpDes)
		If oModelNew:VldData()
			oModelNew:CommitData()
		EndIf
	EndIf
	oModelNew:Deactivate()
	oModelNew:Destroy()

	RestArea( aArea )
	RestArea( aAreaNSZ )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095VlCli
Validação do Código do cliente quando os parâmetros MV_JFTJURI e MV_JLOJAUT estão ativos,
para validar o campo de loja antes de ser inserido pelo gatilho

@author Bruno Ritter
@since  26/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095VlCli()
Local lIntegra  := SuperGetMV("MV_JFTJURI",, "2" ) == "1" //Indica se ha Integracao entre SIGAJURI e SIGAPFS (1=Sim;2=Nao)
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT" , .F. , "2" , ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lRet      := .T.

If (lIntegra .AND. cLojaAuto == "1")
	lRet := ExistCpo('SA1',M->NSZ_CCLIEN+JurGetLjAt(),1)

	If lRet
		lRet := JVldClRst(M->NSZ_CCLIEN,JurGetLjAt())
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J95HisFlu
Grava o historio da atividades do Fluig, na forma de Andamentos e apresenta
Para Consultivo e Contratos

@param 	cFilPro	  - Filial do Processo
@param 	cProcesso - Código do Processo

@author  Rafael Tenorio da Costa
@since   27/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95HisFlu(cFilPro, cProcesso)

Local aArea		 := GetArea()
Local aAreaNSZ	 := NSZ->( GetArea() )
Local oModelSAVE := FWModelActive()
Local cIdWf      := JurGetDados("NSZ", 1, cFilPro + cProcesso, "NSZ_CODWF")
Local cTpWf      := Iif(JurGetDados("NSZ", 1, cFilPro + cProcesso, "NSZ_TIPOAS") == "006", "1", "2")
Local aHistorico := {}
Local cDesc		 := ""
Local cHoraSeq 	 := ""
Local dData	 	 := ""
Local cAto		 := SuperGetMv("MV_JATOHIF", , "")
Local aAnds		 := {}
Local aAux		 := {}
Local nCont		 := 0
Local cQuery	 := ""
Local aAuxSLA    := {}
Local aSLA       := {}
Local lSLA       := .F.
Local cDtIni     := ""
Local cHrIni     := ""
Local cDtFim     := "" 
Local cHrFim     := "" 
Local nX         := 1
Local cCodAtiv   := ""
Local nSegSLA    := 0
Local aAtivTempo := {}
Local cCodAnt    := ""
Local lRet       := .T.
Local cExistO0Z  := ""
Local cTipoAs    := ""
Local lWfEnc     := .F.

	If Empty(cAto)
		JurMsgErro( I18n(STR0291, {"(MV_JATOHIF)"}) ) //"Parâmetro não preenchido, histórico não será gerado.#1"
	Else
		lWfEnc := IsInCallStack("get_prochistwf") .Or. J95WFEnd(cIdWf)
		//Pega o historico da atividade
		If !Empty(cIdWf)
			Processa( {|| aHistorico := J95FHisFlu(cIdWf)}, STR0290, STR0292) //"Histórico Fluig" //"Buscando histórico"
		EndIf

		//Carrega andamentos
		For nCont:=1 To Len(aHistorico)

			cHoraSeq := aHistorico[nCont][2] + " - " + aHistorico[nCont][3]
			dData	 := aHistorico[nCont][1]

			cQuery := " SELECT NT4_FILIAL, NT4_COD"
			cQuery += " FROM " + RetSqlName("NT4")
			cQuery += " WHERE NT4_FILIAL = '" + cFilPro 	+ "'"
			cQuery += 	" AND NT4_CAJURI = '" + cProcesso 	+ "'"
			cQuery += 	" AND NT4_DTANDA = '" + DtoS(dData) + "'"
			cQuery += 	" AND NT4_CATO = '"   + cAto 		+ "'"
			cQuery += 	" AND SUBSTRING(" + JurLower("M", "NT4_DESC") + ",1," + cValToChar( Len(cHoraSeq) ) + ") LIKE '" + cHoraSeq + "'"
			cQuery += 	" AND D_E_L_E_T_ = ' '"

			//Verifica se o andamento ja existe
			If Len( JurSQL(cQuery, "*") ) == 0

				cDesc := cHoraSeq 	  				    + CRLF +; //Hora + Sequencia
						 STR0293 + aHistorico[nCont][4] + CRLF +; //"Atividade: "
						 STR0294 + aHistorico[nCont][5] + CRLF +; //"Histórico: "
						 STR0295 + aHistorico[nCont][6]			  //"Observação: "

				aAux  := {}
				Aadd(aAux, {"NT4_CAJURI", cProcesso	} )
				Aadd(aAux, {"NT4_DESC"	, cDesc	   	} )
				Aadd(aAux, {"NT4_DTANDA", dData		} )
				Aadd(aAux, {"NT4_CATO"	, cAto		} )

				Aadd(aAnds, aAux)
			EndIf
			
			// Verificação para inclusão do SLA Jurídico
			If FWAliasIndic("O0Z") .And. FWAliasIndic("O10") .And. lWfEnc
				If IsInCallStack("get_prochistwf") // não verifica se o WF está encerrado, pois o WS já verifica anteriormente
					lSLA := .T.
				Else
					//Garante que o WF ainda não foi processado e que está encerrado
					cExistO0Z := Posicione( "O0Z",2,xFilial("O0Z")+cFilPro+cProcesso, "O0Z_CATIVI" )
					If Empty(cExistO0Z)
						lSLA := .T.
					EndIf
				EndIf

				If lSLA
					cTipoAs := Posicione( "NSZ",1,cFilPro+cProcesso, "NSZ_TIPOAS" )
					CarregaO10(cTipoAs)
					aAuxSLA := {}
					aAdd(aAuxSLA, {aHistorico[nCont][3],;  //Sequencia
									aHistorico[nCont][4],; //Atividade
									aHistorico[nCont][1],; //Data
									aHistorico[nCont][2]}) //Hora

					aAdd(aSLA, aAuxSLA)
				EndIf

			EndIf
		Next nCont

		//Grava andamentos
		If Len(aAnds) > 0
			Processa( {|| J100GrvAnd(aAnds)}, STR0290, STR0296) //"Histórico Fluig" //"Gravando andamentos"
		EndIf

		//Grava SLA por Atividade
		If Len(aSLA) > 0 .And. lSLA
			aAuxSLA := {}
			//Ordena as atividades pela Sequência crescente
			aSLA := aSort(aSLA, , , { | x,y | Val(x[1][1]) < Val(y[1][1]) })
			//Calcula o tempo em segundos de cada atividade do WF
			For nX := 1 To Len( aSLA )
				If !aSLA[nX][1][2] $ "Início/Abrir Solicitação/Fim/Fim com cancelamento de processo/Resposta Aceita" .And. len(aSLA) >= nX+1
					cDtIni := DtoS(aSLA[nX][1][3])   // Data da Atividade
					cHrIni := aSLA[nX][1][4]         // Hora da Atividade
					cDtFim := DtoS(aSLA[nX+1][1][3]) // Data da Próxima Atividade
					cHrFim := aSLA[nX+1][1][4]       // Hora da Próxima Atividade
					// Calcula a diferença em segundos 
					nSegSLA := CalcSLA(cDtIni, cHrIni, cDtFim, cHrFim)
					cCodAtiv := Posicione("O10", 2, xFilial("O10")+cTpWf+AllTrim(aSLA[nX][1][2]), "O10_COD")
					If !Empty(cCodAtiv)
						// Armazena as atividades (código) e o tempo
						aAdd(aAuxSLA, {cCodAtiv, nSegSLA})
					EndIf
					cDtIni := ""
					cHrIni := ""
					cDtFim := ""
					cHrFim := ""
				EndIf
			Next nX
			nX := 1

			aAuxSLA := aSort(aAuxSLA, , , { | x,y | x[1] < y[1] }) // Agrupa por código
			//Acumula o tempo por atividade
			For nX := 1 To Len(aAuxSLA)
				If aAuxSLA[nX][1] <> cCodAnt
					If nX > 1
						// Armazena as atividades (código) e o tempo acumulado
						aAdd(aAtivTempo,{cCodAnt, nSegAux})
					EndIf
					nSegAux := aAuxSLA[nX][2]
				Else
					nSegAux += aAuxSLA[nX][2]
				EndIf
				cCodAnt := aAuxSLA[nX][1]
				If nX == Len(aAuxSLA)
					aAdd(aAtivTempo,{aAuxSLA[nX][1], nSegAux})
				EndIf
			Next nX
			// Grava o SLA Jurídico (O0Z)
			Processa( {|| GrvSLAJur(cFilPro, cProcesso, aAtivTempo)}, STR0290, STR0303) //"Histórico Fluig" //"Gravando SLA Jurídico"
		EndIf

		//Apresenta browser de andamentos com filtro por ato
		If Len( JurSQL(cQuery, "*") ) > 0
			If !JurAuto()
				cFiltroAux := "NT4_CATO == '" + cAto + "'"
				JCall100(cProcesso, .F., @oModelSAVE, aModelos, oModelSAVE:GetOperation(), cFiltroAux)
			EndIf
		Else
			MsgInfo(STR0297) //"Não existe histórico para este processo!"
			lRet := .F.
		EndIf

		FwFreeObj(aHistorico)
		FwFreeObj(aAnds)
		FwFreeObj(aAux)
		FwFreeObj(aSLA)
		FwFreeObj(aAuxSLA)
		FwFreeObj(aAtivTempo)
	EndIf

	RestArea(aAreaNSZ)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} defObriga
Percorre o array de campos e define a obrigatoriedade no modelo

@param cTabela 	 Tabela selecionada
@param oStruct 	 Estrutura da tabela

@Return oModel
@since 15/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function defObriga(cTabela,oStruct)

	Local alCampos
	Local nI

		alCampos := J95NuzCpo(cTipoAsJ,cTabela, ,.T.)

		For nI := 1 To Len(alCampos) 
			If oStruct:HasField(alltrim(alCampos[nI]))
				oStruct:SetProperty(alltrim(alCampos[nI]),MODEL_FIELD_OBRIGAT,.T.)
			elseif oStruct:HasField(alCampos[nI])
				oStruct:SetProperty(alCampos[nI],MODEL_FIELD_OBRIGAT,.T.)
			EndIf
		Next nI

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvSLAJur(cFilPro, cProcesso, aAtivTempo)
Grava o SLA Jurídico

@param cFilPro    Filial do processo
@param cProcesso  Cód. do Assunto Jurídico
@param aAtivTempo Array [1] Código ativiade (O10_COD)
                        [2] Tempo em segundos

@Return .T.
@since 06/05/2020
/*/
//-------------------------------------------------------------------
Static Function GrvSLAJur(cFilPro, cProcesso, aAtivTempo)

Local aArea      := GetArea()
Local aAreaO0Z   := O0Z->( GetArea() )
Local lInc       := .T.
Local nX         := 1

	dbSelectArea("O0Z")
	O0Z->(dbSetOrder( 2 )) //O0Z_FILIAL+O0Z_FILPRO+O0Z_CAJURI+O0Z_CATIVI
	For nX := 1 To Len( aAtivTempo )
		If O0Z->( dbSeek( xFilial( 'O0Z' )+cFilPro+cProcesso+aAtivTempo[nX][1]) )
			lInc := .F.
		EndIf
		Reclock( "O0Z", lInc )
			If lInc
				O0Z->O0Z_COD    := GETSXENUM("O0Z","O0Z_COD",,1)
				O0Z->O0Z_FILPRO := cFilPro
				O0Z->O0Z_CAJURI := cProcesso
				O0Z->O0Z_CATIVI := aAtivTempo[nX][1]
			EndIf
			O0Z->O0Z_SLASEG := aAtivTempo[nX][2]
		O0Z->(MsUnLock())

		If __lSX8
			ConfirmSX8()
		EndIf

		lInc := .T.

	Next nX

	O0Z->(dbCloseArea())

	RestArea(aAreaO0Z)
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcSLA(cDtIni, cHrIni, cDtFim, cHrFim)
Calcula a diferença em minutos entre duas horas.

@param cDtIni     Data da hora inicial
@param cHrIni     Hora inicial
@param cDtFim     Data da hora final
@param cHrFim     Hora final

@Return nTotSec    Diferença em segundos
@since 06/05/2020
/*/
//-------------------------------------------------------------------
Static Function CalcSLA(cDtIni, cHrIni, cDtFim, cHrFim)
Local dDtIni     := ""
Local dDtFim     := ""
Local nHorIni    := 0
Local nMinIni    := 0
Local nSecIni    := 0
Local nHorFim    := 0
Local nMinFim    := 0
Local nSecFim    := 0
Local nTotSec    := 0
Local nSec       := 0
Local n24hrs     := 0
Local nHoras     := 0
Local nMin       := 0


	dDtIni := SToD(cDtIni)
	dDtFim := SToD(cDtFim)
	//Horas
	nHorIni := Val(SubStr(cHrIni,1,2))
	nHorFim := Val(SubStr(cHrFim,1,2))
	//Minutos
	nMinIni := Val(SubStr(cHrIni,4,2))
	nMinFim := Val(SubStr(cHrFim,4,2))
	//Segundos
	nSecIni := Val(SubStr(cHrIni,7,2))
	nSecFim := Val(SubStr(cHrFim,7,2))

	If dDtIni == dDtFim
		n24hrs := 0
	Else
		n24hrs = JurDUteis( dDtIni, dDtFim ) - 1
	EndIf

	//Horas
	If nHorFim == nHorIni
		nHoras := 0
	ElseIf nHorFim > nHorIni
		nHoras := nHorFim - nHorIni
	Else
		nHoras := (24-nHorIni)+nHorFim
	EndIf

	//Minutos
	If nMinIni == nMinFim
		nMin := 0
	ElseIf nMinFim  > nMinIni
		nMin := nMinFim - nMinIni
	Else
		nMin := (60-nMinIni)+nMinFim
	EndIf

	//Segundos
	If nSecIni == nSecFim
		nSec := 0
	ElseIf nSecFim > nSecIni 
		nSec := nSecFim - nSecIni
	Else
		nSec := (60-nSecIni)+nSecFim
	EndIf

	nTotSec := (nHoras + (n24hrs*24)) * 3600 //Horas em segundos
	nTotSec += nMin * 60 //Minutos em segundos
	nTotSec += nSec 
		
Return nTotSec

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaO10()
Faz a carga inicial das atividades do Fluig.
@param cAssJur    Tipo de Workflow 1=Contratos 2=Consultivo

@Return .T.
@since 06/05/2020
/*/
//-------------------------------------------------------------------
Static Function CarregaO10(cAssJur)

Local aArea      := GetArea()
Local aAreaO10   := O10->( GetArea() )
Local cQuery     := ""
Local nX         := 1
Local aO10       := {}
Local cTpWF      := "1"
// aAtiv[x][1] Descrição da atividade
// aAtiv[x][2] Resposabilidade Juridico 1=Sim 2=Não
// aAtiv[x][3] Tipo de Workflow 1=Contratos 2=Consultivo
Local aAtiv      := { {"Abrir Solicitação"                  , "1" , "1"} ,; 
                      {"Análise Documentos"                 , "1" , "1"} ,;
                      {"Revisar Documentos"                 , "2" , "1"} ,;
                      {"Gerar Minuta"                       , "1" , "1"} ,;
                      {"Preenche Minuta"                    , "1" , "1"} ,;
                      {"Valida Minuta"                      , "2" , "1"} ,;
                      {"Gera Minuta Final"                  , "1" , "1"} ,;
                      {"Finaliza Contrato"                  , "2" , "1"} ,;
                      {"Encaminhar para Assinatura Digital" , "1" , "1"} ,;
                      {"Colher Assinatura"                  , "2" , "1"} ,;
                      {"Revisar Assinaturas"                , "1" , "1"} ,;
                      {"Abrir Solicitação"                  , "1" , "2"} ,;
                      {"Responder Solicitação"              , "1" , "2"} ,;
                      {"Revisar Solicitação"                , "1" , "2"} ,;
                      {"Resposta"                           , "1" , "2"} ,;
                      {"Resposta Aceita"                    , "1" , "2"} ,;
                      {"Fim com cancelamento de processo"   , "1" , "2"} }

DEFAULT cAssJur    := "006"

	cQuery:= "SELECT O10_ATIVID"
	cQuery+= "FROM "+ RetSqlName("O10")
	cQuery+= "WHERE D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")
	aO10 := JurSQL(cQuery, "*")

	DBSelectArea("O10")
	Do CASE	
		Case cAssJur == '006'
			cTpWF := "1"
		Case cAssJur == '005'
			cTpWF := "2"
	ENDCASE

	If Len(aO10) > 0
		DBSetOrder(2) //O10_FILIAL+O10_TIPOWF+O10_ATIVID
		For nX := 1 To Len(aAtiv)
			// Inclui as atividades faltantes
			If !( O10->( DBSeek(xFilial("O10")+aAtiv[nX][3]+aAtiv[nX][1] ) ) )
				RecLock("O10", .T.)
					O10->O10_COD    := GETSXENUM("O10","O10_COD",,1)
					O10->O10_ATIVID := aAtiv[nX][1]
					O10->O10_JURIDI := aAtiv[nX][2]
					O10->O10_TIPOWF := aAtiv[nX][3]
				O10->( MsUnlock() )

				If __lSX8
					ConfirmSX8()
				EndIf
			EndIf
		Next nX
	Else
		// Faz a carga inicial
		For nX := 1 To Len(aAtiv)
			RecLock("O10", .T.)
				O10->O10_COD    := GETSXENUM("O10","O10_COD",,1)
				O10->O10_ATIVID := aAtiv[nX][1]
				O10->O10_JURIDI := aAtiv[nX][2]
				O10->O10_TIPOWF := aAtiv[nX][3]
			O10->( MsUnlock() )

			If __lSX8
				ConfirmSX8()
			EndIf
		Next nX
	EndIf

	O10->(DBCloseArea())

	RestArea(aAreaO10)
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldInstOri(oModelNUQ)
Faz a verificação se a instância atual possui relacionamento com 
instâncias filhas.

@param oModelNUQ - Modelo da NUQ

@since 12/06/2020
/*/
//-------------------------------------------------------------------
Static Function VldInstOri(oModelNUQ)
Local lRet    := .T.
Local cQuery  := ''
Local nI      := 0
Local aRegSQL := {}

Default oModelNUQ := Nil

	For nI := 1 To oModelNUQ:Length()
		If oModelNUQ:IsDeleted(nI)
			cQuery := 'SELECT NUQ_NUMPRO '
			cQuery +=        'FROM '+ RetSqlName("NUQ") + ' NUQ '
			cQuery +=        "WHERE NUQ.NUQ_FILIAL = '" + oModelNUQ:GetValue('NUQ_FILIAL',nI) + "'"
			cQuery +=          " AND NUQ.D_E_L_E_T_ = ''"
			cQuery +=          " AND NUQ.NUQ_CINSTP <> ''"
			cQuery +=          " AND NUQ.NUQ_CINSTP = '" + oModelNUQ:GetValue('NUQ_COD',nI) + "'"

			cQuery  := ChangeQuery(cQuery)
			aRegSQL := JurSQL(cQuery, "*")

			If Len(aRegSQL) > 0 .And. !Empty(aRegSQL[1][1])
				lRet := .F.
				JurMsgErro(I18n(STR0305, { JurEncUTF8(AllTrim( aRegSQL[1][1] )) }))
			EndIf
		EndIf
	Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ja095X7Est()
Condição do gatilho da NUQ_CCOMAR.

@since 04/01/2021
/*/
//-------------------------------------------------------------------
Function Ja095X7Est()
Local lWSTLegal := JModRst()
Local lRet := .T.

	If lWSTLegal
		lRet := EMPTY(M->NUQ_ESTADO)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCorresp
Valida os correspondentes de acordo com a atuação

@param oNUQ, object, modelo da NUQ
@return lRet, boolean, Verdadeiro para validado 
/*/
//-------------------------------------------------------------------
Static Function VldCorresp(oNUQ)
Local aAreaSA2 := SA2->(GetArea())
Local cCodCorr := ''
Local cCodLoja := ''
Local nCt      := 0
Local lRet     := .T.
Local cValid   := ""

	For nCt := 1 To oNUQ:GetQtdLine()
		If (lRet .AND. !oNUQ:IsDeleted(nCt) ;
			.AND. (oNUQ:IsFieldUpdate('NUQ_CCORRE', nCt) .OR. oNUQ:IsFieldUpdate('NUQ_LCORRE', nCt));
			.AND. !Empty( oNUQ:GetValue('NUQ_CCORRE', nCt) + oNUQ:GetValue('NUQ_LCORRE', nCt) );
		)

			lRet     := .F.
			cCodCorr := oNUQ:GetValue('NUQ_CCORRE', nCt)
			cCodLoja := oNUQ:GetValue('NUQ_LCORRE', nCt)

			SA2->(DbSetOrder(1))
			
			If SA2->(Dbseek(xFilial('SA2') + cCodCorr + cCodLoja))
				cValid := JA95SA2NUQ(cCodCorr, cCodLoja)
				cValid := StrTran(cValid,'@#','')
				lRet := &(cValid)
			EndIf
		EndIf
	Next nCt

	RestArea(aAreaSA2)

Return lRet
