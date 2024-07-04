#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA219.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

Static oGrid
Static cLoadFilter
Static cPalavraChv
Static cCajuri
Static aSiglas

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA219
Rotina de geração de assuntos jurídicos a partir das Distribuições que
foram importadas da Kurrier.

@author	Rafael tenorio da Costa 
@since 	13/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA219()

Local aArea := GetArea()
Local lEnd  := .F.

Private lAbortPrint := .F. //Indica se a operação foi cancelada. Usada para controlar a opção de cancelar da funcionalidade PROCESSA

	oGrid := Nil
	
	DbSelectArea("NZZ")
	NZZ->( DbSetOrder(4) )	//NZZ_FILIAL + NZZ_STATUS + NZZ_COD
	NZZ->( DbGoTop() )

	oGrid := FWGridProcess():New("JURA219", STR0001, STR0002 + CRLF + STR0014, {|lEnd| ProcPerg(@lEnd)}, "JURA219"/*Pergunte*/)	//"Importação de Distribuições"		"Está rotina é responsável por gerenciar as interações sobre as distribuições já recebidas."		"Por favor, selecione os parâmetros."
	oGrid:SetMeters(1)
	oGrid:Activate()
	
	oGrid:IsFinished()
	
	If lEnd
		oGrid:Destroy()
	EndIf		
	FreeObj( oGrid )
	oGrid := Nil

	RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcPerg
Rotina que valida os filtros e inicia a rotina de importação de 
distribuições

@return lContinua

@author Rafael Tenorio da Costa
@since 16/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcPerg(lEnd)

	Local aArea     := GetArea()
	Local lContinua := .T.
	Local cMensagem := ""
	Local aBotoes   := {{.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,"Confirmar"}, {.T.,"Fechar"}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.F.,Nil}}

	/*	
	VERSAO 11
	O array aEnableButtons tem por padrão 14 posições: aBotoes
	1 - Copiar
	2 - Recortar
	3 - Colar
	4 - Calculadora
	5 - Spool
	6 - Imprimir
	7 - Confirmar
	8 - Cancelar
	9 - WalkTrhough
	10 - Ambiente
	11 - Mashup
	12 - Help
	13 - Formulário HTML
	14 - ECM
	*/
	
	Private cTipoAJ		:= MV_PAR04
	Private cTipoAsJ 	:= MV_PAR04
	Private c162TipoAs	:= MV_PAR04
	
	//Obtem o assunto pai para continuar as validações
	If c162TipoAs > "050"
		c162TipoAs := JurGetDados("NYB", 1, xFilial("NYB") + c162TipoAs, "NYB_CORIG")
	EndIf

	oGrid:SetMaxMeter(5, 1, STR0001)	//"Importação de Distribuições"
	
	//Valida parâmetros
	Do Case
		Case Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. (MV_PAR01 > MV_PAR02) .Or. (MV_PAR02 - MV_PAR01 > 35) 
			cMensagem := STR0025	//"Preencha um período, com no máximo 35 dias de intervalo" 
			lContinua := .F.
		Case Empty(cTipoAJ)
			cMensagem := STR0024	//"Preencha um tipo de assunto jurídico válido" 
			lContinua := .F.
		Case Empty( JurGetDados("NYB", 1 , xFilial("NYB") + cTipoAJ, "NYB_DESC") )	//NYB_FILIAL+NYB_COD
			cMensagem := STR0036	//"Tipo de assunto jurídico inválido" 
			lContinua := .F.
	End Case		

	//Apresenta distribuicoes
	If lContinua
		FWExecView( STR0003/*cTitulo*/, "JURA219"/*cPrograma*/, MODEL_OPERATION_UPDATE/*nOperation*/,  /*oDlg*/, {|| .T.}/*bCloseOnOK*/, {|| .T.}/*bOk*/, /*nPercReducao*/,  aBotoes/*aEnableButtons*/, {|| .T.}/*bCancel*/, /*cOperatId*/,  /*cToolBar*/, /*oModelAct*/)	//"Alterar"
		lEnd := .T.
	Else
		JurMsgErro(cMensagem)
	EndIf	

	RestArea( aArea )

Return lContinua

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

@author André Spirigoni
@since 24/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0019 , "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0020 , "VIEWDEF.JURA219", 0, 2, 0, NIL } ) // "Visualizar"
	aAdd( aRotina, { STR0021 , "VIEWDEF.JURA219", 0, 3, 0, NIL } ) // "Incluir"
	aAdd( aRotina, { STR0022 , "VIEWDEF.JURA219", 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { STR0023 , "VIEWDEF.JURA219", 0, 5, 0, NIL } ) // "Excluir"
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de importação de documentos

@author André Spirigoni
@since 24/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel     := FWLoadModel( "JURA219" )
	Local oStrResumo := FWFormStruct( 2, "NZZ" )
	Local oStrResA1  := FWFormStruct( 2, "NZZ" )
	Local oStrResA2  := FWFormStruct( 2, "NZZ" )
	Local oStrResA3  := FWFormStruct( 2, "NZZ" )
	Local oStructNSZ := Nil
	Local oStructNUQ := Nil
	Local oStructNT9 := Nil	
	Local oStructNT4 := FWFormStruct( 2, "NT4", {|cCampo| AllTrim(cCampo) $ "NT4_DESC|NT4_DTANDA|NT4_CATO|NT4_DATO"})
	Local oStructNTA := FWFormStruct( 2, "NTA", {|cCampo| AllTrim(cCampo) $ "NTA_CTIPO|NTA_DTIPO|NTA_DTFLWP|NTA_CRESUL|NTA_DRESUL|NTA_DESC"})
	Local oView      := Nil
	Local aCampos    := {}
	
	If oGrid <> Nil
		oGrid:SetIncMeter(1)
	Endif

	//Carrega os campos da aba campos obrigatorios e campos do tipo assunto juridico
	aCampos := {}
	aCampos := J95NuzCpo(cTipoAJ, "NSZ")
	oStructNSZ := FWFormStruct( 2, "NSZ", {|cCampo| !(JurX3Info(cCampo, "X3_AGRUP") $ "001|005") .And. ( x3Obrigat(cCampo) .Or. cCampo == "NSZ_HCITAC" .Or. Ascan(aCampos,cCampo) > 0 )} )	//Retira os campos do agrupamento de Resumo e Valores

	aCampos := {}
	aCampos := J95NuzCpo(cTipoAJ, "NUQ")
	oStructNUQ := FWFormStruct( 2, "NUQ", {|cCampo| x3Obrigat(cCampo) .Or. (Ascan(aCampos,cCampo) > 0 .And. cCampo <> "NUQ_TLOC3N") } )

	aCampos := {}
	aCampos := J95NuzCpo(cTipoAJ, "NT9")
	oStructNT9 := FWFormStruct( 2, "NT9", {|cCampo| x3Obrigat(cCampo) .Or. Ascan(aCampos,cCampo) > 0} )	

	//Campos virtuais
	oStrResA1:AddField( ;
	"NZZ__TICK"      , ;             // [01] Campo
	'01'             , ;             // [02] Ordem
	''               , ;             // [03] Titulo
	''               , ;             // [04] Descricao
	, ;                              // [05] Help
	'CHECK'          , ;             // [06] Tipo do campo   COMBO, Get ou CHECK
	''               , ;             // [07] Picture
	, ;					             // [08] PictVar
	''               )               // [09] F3

	oStrResA3:AddField( ;
	"NZZ__TICK"      , ;             // [01] Campo
	'01'             , ;             // [02] Ordem
	''               , ;             // [03] Titulo
	''               , ;             // [04] Descricao
	, ;                              // [05] Help
	'CHECK'          , ;             // [06] Tipo do campo   COMBO, Get ou CHECK
	''               , ;             // [07] Picture
	, ;             				 // [08] PictVar
	''               )               // [09] F3

	oStrResumo:AddField( ;
	"NZZ__QTREC"       , ;          // [01] Campo
	'01'               , ;          // [02] Ordem
	STR0004            , ;          // [03] Titulo 		//"Qtd. Recebidas"
	STR0005            , ;          // [04] Descricao 	//"Qtd Distribuições Recebidas"
	, ;                             // [05] Help
	'GET'              , ;          // [06] Tipo do campo   COMBO, Get ou CHECK
	'@!'               , ;          // [07] Picture
	, ;                             // [08] PictVar
	''                 )            // [09] F3

	oStrResumo:AddField( ;
	"NZZ__QTIMP"       , ;           // [01] Campo
	'02'               , ;           // [02] Ordem
	STR0006            , ;           // [03] Titulo 	//"Qtd. Importadas"
	STR0007            , ;           // [04] Descricao 	//"Qtd Distribuições Importadas"
	, ;                              // [05] Help
	'GET'              , ;           // [06] Tipo do campo   COMBO, Get ou CHECK
	'@!'               , ;           // [07] Picture
	, ;                              // [08] PictVar
	''                 )             // [09] F3

	oStrResumo:AddField( ;
	"NZZ__QTEXC"       , ;         // [01] Campo
	'03'               , ;         // [02] Ordem
	STR0008            , ;         // [03] Titulo 		//"Qtd. Excluídas"
	STR0009            , ;         // [04] Descricao 	//"Qtd Distribuições Excluídas"
	, ;                            // [05] Help
	'GET'              , ;         // [06] Tipo do campo   COMBO, Get ou CHECK
	'@!'               , ;         // [07] Picture
	, ;                            // [08] PictVar
	''                 )           // [09] F3

	oStructNTA:AddField( ;
	"NTA__SIGLA"       , ;         // [01] Campo
	'XX'               , ;         // [02] Ordem
	RetTitle("NTE_SIGLA")   			, ;     // [03] Titulo
	JurX3Info("NTE_SIGLA", "X3_DESCRIC"), ;     // [04] Descricao
	, ;                            // [05] Help
	'GET'              , ;         // [06] Tipo do campo   COMBO, Get ou CHECK
	'@S10'             , ;         // [07] Picture
	, ;                            // [08] PictVar
	'RD0ATV'             )         // [09] F3
	
	//Remove os campos do cabeçalho
	oStrResumo:RemoveField("NZZ_COD")
	oStrResumo:RemoveField("NZZ_STATUS")
	oStrResumo:RemoveField("NZZ_LOGIN")
	oStrResumo:RemoveField("NZZ_CAJURI")
	oStrResumo:RemoveField("NZZ_ESCRI")
	oStrResumo:RemoveField("NZZ_DTDIST")
	oStrResumo:RemoveField("NZZ_DTREC")
	oStrResumo:RemoveField("NZZ_TERMO")
	oStrResumo:RemoveField("NZZ_TRIBUN")
	oStrResumo:RemoveField("NZZ_FORUM")
	oStrResumo:RemoveField("NZZ_VARA")
	oStrResumo:RemoveField("NZZ_CIDADE")
	oStrResumo:RemoveField("NZZ_ESTADO")
	oStrResumo:RemoveField("NZZ_ADVOGA")

	If ( oStrResumo:HasField("NZZ_ERRO") )
		oStrResumo:RemoveField("NZZ_ERRO")
	EndIf

	//Ordena os campos do resumo
	oStrResumo:SetProperty( "NZZ_NUMPRO", MVC_VIEW_ORDEM, '04' )
	oStrResumo:SetProperty( "NZZ_VALOR"	, MVC_VIEW_ORDEM, '05' )
	oStrResumo:SetProperty( "NZZ_OCORRE", MVC_VIEW_ORDEM, '06' )
	oStrResumo:SetProperty( "NZZ_REU"	, MVC_VIEW_ORDEM, '07' )
	oStrResumo:SetProperty( "NZZ_AUTOR"	, MVC_VIEW_ORDEM, '08' )
	
	oStrResumo:SetProperty("NZZ__QTEXC", MVC_VIEW_INSERTLINE, .T.)
	oStrResumo:SetProperty("NZZ_OCORRE", MVC_VIEW_INSERTLINE, .T.)

	//Remove os campos da aba distribuições recebidas
	oStrResA1:RemoveField("NZZ_STATUS")
	oStrResA1:RemoveField("NZZ_LOGIN")
	oStrResA1:RemoveField("NZZ_CAJURI")	
	oStrResA1:RemoveField("NZZ_ESCRI")
	oStrResA1:RemoveField("NZZ_TERMO")
	oStrResA1:RemoveField("NZZ_LINK")

	If ( oStrResA1:HasField("NZZ_ERRO") )
		oStrResA1:RemoveField("NZZ_ERRO")
	EndIf
	
	//Tamanho das colunas das distribuições recebidas
	oStrResA1:SetProperty( "NZZ_COD"   , MVC_VIEW_WIDTH, 100 )
	oStrResA1:SetProperty( "NZZ_DTDIST", MVC_VIEW_WIDTH, 100 )
	oStrResA1:SetProperty( "NZZ_DTREC" , MVC_VIEW_WIDTH, 100 )
	oStrResA1:SetProperty( "NZZ_TRIBUN", MVC_VIEW_WIDTH, 100 )
	oStrResA1:SetProperty( "NZZ_NUMPRO", MVC_VIEW_WIDTH, 150 )
	oStrResA1:SetProperty( "NZZ_OCORRE", MVC_VIEW_WIDTH, 350 )
	oStrResA1:SetProperty( "NZZ_REU"   , MVC_VIEW_WIDTH, 200 )
	oStrResA1:SetProperty( "NZZ_AUTOR" , MVC_VIEW_WIDTH, 200 )
	oStrResA1:SetProperty( "NZZ_FORUM" , MVC_VIEW_WIDTH, 200 )
	oStrResA1:SetProperty( "NZZ_VARA"  , MVC_VIEW_WIDTH, 300 )
	oStrResA1:SetProperty( "NZZ_CIDADE", MVC_VIEW_WIDTH, 150 )
	oStrResA1:SetProperty( "NZZ_ADVOGA", MVC_VIEW_WIDTH, 200 )
	
	//Remove os campos da aba distribuições importadas
	oStrResA2:RemoveField("NZZ_STATUS")
	oStrResA2:RemoveField("NZZ_LOGIN")
	oStrResA2:RemoveField("NZZ_ESCRI")
	oStrResA2:RemoveField("NZZ_TERMO")
	oStrResA2:RemoveField("NZZ_LINK")

	If ( oStrResA2:HasField("NZZ_ERRO") )
		oStrResA2:RemoveField("NZZ_ERRO")
	EndIf
	
	//Tamanho das colunas das distribuições importadas
	oStrResA2:SetProperty( "NZZ_COD"   , MVC_VIEW_WIDTH, 100 )
	oStrResA2:SetProperty( "NZZ_CAJURI", MVC_VIEW_WIDTH, 100 )
	oStrResA2:SetProperty( "NZZ_DTDIST", MVC_VIEW_WIDTH, 100 )
	oStrResA2:SetProperty( "NZZ_DTREC" , MVC_VIEW_WIDTH, 100 )
	oStrResA2:SetProperty( "NZZ_TRIBUN", MVC_VIEW_WIDTH, 100 )
	oStrResA2:SetProperty( "NZZ_NUMPRO", MVC_VIEW_WIDTH, 150 )
	oStrResA2:SetProperty( "NZZ_OCORRE", MVC_VIEW_WIDTH, 350 )
	oStrResA2:SetProperty( "NZZ_REU"   , MVC_VIEW_WIDTH, 200 )
	oStrResA2:SetProperty( "NZZ_AUTOR" , MVC_VIEW_WIDTH, 200 )
	oStrResA2:SetProperty( "NZZ_FORUM" , MVC_VIEW_WIDTH, 200 )
	oStrResA2:SetProperty( "NZZ_VARA"  , MVC_VIEW_WIDTH, 300 )
	oStrResA2:SetProperty( "NZZ_CIDADE", MVC_VIEW_WIDTH, 150 )
	oStrResA2:SetProperty( "NZZ_ADVOGA", MVC_VIEW_WIDTH, 200 )
	
	//Remove os campos da aba distribuições excluidas
	oStrResA3:RemoveField("NZZ_STATUS")
	oStrResA3:RemoveField("NZZ_LOGIN")
	oStrResA3:RemoveField("NZZ_CAJURI")	
	oStrResA3:RemoveField("NZZ_ESCRI")
	oStrResA3:RemoveField("NZZ_TERMO")
	oStrResA3:RemoveField("NZZ_LINK")	

	If ( oStrResA3:HasField("NZZ_ERRO") )
		oStrResA3:RemoveField("NZZ_ERRO")
	EndIf
	
	//Tamanho das colunas das distribuições excluídas
	oStrResA3:SetProperty( "NZZ_COD"   , MVC_VIEW_WIDTH, 100 )
	oStrResA3:SetProperty( "NZZ_DTDIST", MVC_VIEW_WIDTH, 100 )
	oStrResA3:SetProperty( "NZZ_DTREC" , MVC_VIEW_WIDTH, 100 )
	oStrResA3:SetProperty( "NZZ_TRIBUN", MVC_VIEW_WIDTH, 100 )
	oStrResA3:SetProperty( "NZZ_NUMPRO", MVC_VIEW_WIDTH, 150 )
	oStrResA3:SetProperty( "NZZ_OCORRE", MVC_VIEW_WIDTH, 350 )
	oStrResA3:SetProperty( "NZZ_REU"   , MVC_VIEW_WIDTH, 200 )
	oStrResA3:SetProperty( "NZZ_AUTOR" , MVC_VIEW_WIDTH, 200 )
	oStrResA3:SetProperty( "NZZ_FORUM" , MVC_VIEW_WIDTH, 200 )
	oStrResA3:SetProperty( "NZZ_VARA"  , MVC_VIEW_WIDTH, 300 )
	oStrResA3:SetProperty( "NZZ_CIDADE", MVC_VIEW_WIDTH, 150 )
	oStrResA3:SetProperty( "NZZ_ADVOGA", MVC_VIEW_WIDTH, 200 )
	
	//Remove os campos da aba campos obrigatorios
	oStructNSZ:RemoveField("NSZ_COD" )
	oStructNSZ:RemoveField("NSZ_CPART1")
	oStructNSZ:RemoveField("NSZ_CPART2")
	oStructNSZ:RemoveField("NSZ_CPART3")
	oStructNSZ:RemoveField("NSZ_CRESCO")
	oStructNSZ:RemoveField("NSZ_CODRES")
	oStructNSZ:RemoveField("NSZ_TIPOAS")
	oStructNSZ:RemoveField("NSZ_DTINCL")
	oStructNSZ:RemoveField("NSZ_USUINC")

	oStructNT9:RemoveField("NT9_COD")
	oStructNT9:RemoveField("NT9_CAJURI")
	oStructNT9:RemoveField("NT9_PRINCI")
		
	//Ordena a posição dos campos da NSZ do agrupamento Valores
	J95PosCpVl(oStructNSZ)
		
	//Faz as configurações dos envolvidos verificando se esta ativo o cadastro tabelado de envolvidos 
	J95EnvTab(oStructNT9)
	
	oStructNUQ:RemoveField("NUQ_COD")
	oStructNUQ:RemoveField("NUQ_CAJURI")
	oStructNUQ:RemoveField("NUQ_INSATU")
	oStructNUQ:RemoveField("NUQ_NUMANT")
	oStructNUQ:RemoveField("NUQ_NUMPRO")
	
	//Remove os campos da aba andamentos
	oStructNT4:RemoveField("NT4_COD")
	oStructNT4:RemoveField("NT4_CAJURI")
	
	//Ordena os campos da aba andamentos
	oStructNT4:SetProperty( "NT4_DTANDA", MVC_VIEW_ORDEM, '01' )
	oStructNT4:SetProperty( "NT4_CATO"	, MVC_VIEW_ORDEM, '02' )
	oStructNT4:SetProperty( "NT4_DATO"	, MVC_VIEW_ORDEM, '03' )
	oStructNT4:SetProperty( "NT4_DESC"	, MVC_VIEW_ORDEM, '04' )
	
	//Tamanho fixo para campos do andamento
	oStructNT4:SetProperty( "NT4_DTANDA", MVC_VIEW_WIDTH, 100 )
	oStructNT4:SetProperty( "NT4_CATO"	, MVC_VIEW_WIDTH, 70  )
	oStructNT4:SetProperty( "NT4_DATO"	, MVC_VIEW_WIDTH, 200 )
	
	//Remove os campos da aba follow-ups
	oStructNTA:RemoveField("NTA_COD")
	oStructNTA:RemoveField("NTA_CAJURI")
	
	//Ordena os campos da aba follow-ups
	oStructNTA:SetProperty( "NTA_DTFLWP", MVC_VIEW_ORDEM, '01' )
	oStructNTA:SetProperty( "NTA_CTIPO"	, MVC_VIEW_ORDEM, '02' )
	oStructNTA:SetProperty( "NTA_DTIPO"	, MVC_VIEW_ORDEM, '03' )
	oStructNTA:SetProperty( "NTA_CRESUL", MVC_VIEW_ORDEM, '04' )
	oStructNTA:SetProperty( "NTA_DRESUL", MVC_VIEW_ORDEM, '05' )
	oStructNTA:SetProperty( "NTA__SIGLA", MVC_VIEW_ORDEM, '06' )
	oStructNTA:SetProperty( "NTA_DESC"	, MVC_VIEW_ORDEM, '07' )
	
	//Tamanho fixo para campos do follow-ups
	oStructNTA:SetProperty( "NTA_DTFLWP", MVC_VIEW_WIDTH, 90  )
	oStructNTA:SetProperty( "NTA_CTIPO"	, MVC_VIEW_WIDTH, 70  )
	oStructNTA:SetProperty( "NTA_DTIPO"	, MVC_VIEW_WIDTH, 200 )
	oStructNTA:SetProperty( "NTA_CRESUL", MVC_VIEW_WIDTH, 80  )
	oStructNTA:SetProperty( "NTA_DRESUL", MVC_VIEW_WIDTH, 200 )
	oStructNTA:SetProperty( "NTA__SIGLA", MVC_VIEW_WIDTH, 70  )
	
	//Carrega os titulos dos campos da tabela NUZ
	JGetNmFld(oStructNSZ, cTipoAsJ, c162TipoAs)
	JGetNmFld(oStructNT9, cTipoAsJ, c162TipoAs)
	JGetNmFld(oStructNUQ, cTipoAsJ, c162TipoAs)
	JGetNmFld(oStructNT4, cTipoAsJ, c162TipoAs)
	JGetNmFld(oStructNTA, cTipoAsJ, c162TipoAs)

	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	//Aba de Resumo
	oView:AddField("JURA219_FIELDNZZ"	, oStrResumo, "NZZMASTER"	)
	oView:AddGrid( "JURA219_GRIDNZZ_1"	, oStrResA1	, "NZZDETAIL1"	)
	oView:AddGrid( "JURA219_GRIDNZZ_2"	, oStrResA2	, "NZZDETAIL2"	)
	oView:AddGrid( "JURA219_GRIDNZZ_3"	, oStrResA3	, "NZZDETAIL3"	)
	
	//Aba de campos obrigatorios	
	oView:AddField("JURA219_FIELDNSZ"	, oStructNSZ, "NSZMASTER"	)
	oView:AddGrid( "JURA219_GRIDNT9"	, oStructNT9, "NT9DETAIL"  	)
	oView:AddGrid( "JURA219_GRIDNUQ"	, oStructNUQ, "NUQDETAIL"	)	
	
	//Aba de andamentos \ follow-ups	
	oView:AddGrid( "JURA219_GRIDNT4"	, oStructNT4, "NT4MASTER" 	)
	oView:AddGrid( "JURA219_GRIDNTA"	, oStructNTA, "NTAMASTER" 	)

	//Cria folder
	oView:CreateFolder("FOLDER")
	
	//Cria aba de Resumo
	oView:AddSheet("FOLDER", "ABA_F01", STR0017)	//"Resumo"
	
	oView:CreateHorizontalBox( "BOX_F01_CAB" , 40, , , "FOLDER", "ABA_F01")
	oView:CreateHorizontalBox( "BOX_F01_ABAS", 60, , , "FOLDER", "ABA_F01")
	
	oView:CreateFolder("FOLDER_F01_ABAS", "BOX_F01_ABAS")

	oView:AddSheet("FOLDER_F01_ABAS", "ABA_F01_A01", STR0012, { || AtuResumo(oView, 'NZZDETAIL1') } ) 	//"Distribuições recebidas"
	oView:AddSheet("FOLDER_F01_ABAS", "ABA_F01_A02", STR0011, { || AtuResumo(oView, 'NZZDETAIL2') } )	//"Distribuições importadas"
	oView:AddSheet("FOLDER_F01_ABAS", "ABA_F01_A03", STR0013, { || AtuResumo(oView, 'NZZDETAIL3') } ) 	//"Distribuições excluídas"

	oView:CreateHorizontalBox("BOX_F01_A01", 100,,, "FOLDER_F01_ABAS", "ABA_F01_A01")
	oView:CreateHorizontalBox("BOX_F01_A02", 100,,, "FOLDER_F01_ABAS", "ABA_F01_A02")
	oView:CreateHorizontalBox("BOX_F01_A03", 100,,, "FOLDER_F01_ABAS", "ABA_F01_A03")	

	oView:SetOwnerView("JURA219_FIELDNZZ" , "BOX_F01_CAB")
	oView:SetOwnerView("JURA219_GRIDNZZ_1", "BOX_F01_A01")
	oView:SetOwnerView("JURA219_GRIDNZZ_2", "BOX_F01_A02")
	oView:SetOwnerView("JURA219_GRIDNZZ_3", "BOX_F01_A03")
	
	oView:EnableTitleView( "JURA219_FIELDNZZ", STR0001 ) //"Distribuições"
	
	oView:SetNoInsertLine("NZZDETAIL1")
	oView:SetNoInsertLine("NZZDETAIL2")
	oView:SetNoInsertLine("NZZDETAIL3")
	
	oView:SetNoDeleteLine("NZZDETAIL1")
	oView:SetNoDeleteLine("NZZDETAIL2")
	oView:SetNoDeleteLine("NZZDETAIL3")
	
	oView:SetViewProperty("NZZDETAIL1", "CHANGELINE", {{ |oView, cViewID| AtuResumo(oView, cViewID) }} )
	oView:SetViewProperty("NZZDETAIL2", "CHANGELINE", {{ |oView, cViewID| AtuResumo(oView, cViewID) }} )
	oView:SetViewProperty("NZZDETAIL3", "CHANGELINE", {{ |oView, cViewID| AtuResumo(oView, cViewID) }} )
	
	oView:SetViewProperty("NZZDETAIL2", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| AbrePro(oFormulario,cFieldName,nLineGrid,nLineModel)}})
	
	//Cria aba de Campos Obrigatórios
	oView:AddSheet('FOLDER', 'ABA_F02', STR0026)	//"Campos Obrigatórios"
	oView:CreateHorizontalBox("BOX_F02_NSZ", 50,,, "FOLDER", "ABA_F02")
	oView:CreateHorizontalBox("BOX_F02_NT9", 30,,, "FOLDER", "ABA_F02")
	oView:CreateHorizontalBox("BOX_F02_NUQ", 20,,, "FOLDER", "ABA_F02")
	
	oView:SetOwnerView("JURA219_FIELDNSZ", "BOX_F02_NSZ")
	oView:SetOwnerView("JURA219_GRIDNT9" , "BOX_F02_NT9")
	oView:SetOwnerView("JURA219_GRIDNUQ" , "BOX_F02_NUQ")	
	
	oView:EnableTitleView( "JURA219_FIELDNSZ", STR0029 ) //"Assuntos Jurídicos"
	oView:EnableTitleView( "JURA219_GRIDNT9" , STR0031 ) //"Envolvidos"
	oView:EnableTitleView( "JURA219_GRIDNUQ" , STR0030 ) //"Instâncias"
	
	oView:SetNoDeleteLine("NUQDETAIL")
	
	oView:SetViewProperty("NT9DETAIL", "GRIDVSCROLL", {.F.})
	oView:SetViewProperty("NUQDETAIL", "GRIDVSCROLL", {.F.})
	
	//Forca atualiza o grid, por causa da limitação da quantidade de linhas
	oView:SetViewProperty("NT9DETAIL", "CHANGELINE", {{ |oView, cViewID| oView:Refresh(cViewID) }} )
	oView:SetViewProperty("NUQDETAIL", "CHANGELINE", {{ |oView, cViewID| oView:Refresh(cViewID) }} )
	
	//Cria aba de Andamentos \ Follow-ups
	oView:AddSheet('FOLDER', 'ABA_F03', STR0027 + " \ " + STR0028)	//"Andamentos \ Follow-ups"
	oView:CreateHorizontalBox("BOX_F03_NT4", 50,,, "FOLDER", "ABA_F03")
	oView:CreateHorizontalBox("BOX_F03_NTA", 50,,, "FOLDER", "ABA_F03")
	
	oView:SetOwnerView("JURA219_GRIDNT4", "BOX_F03_NT4")
	oView:SetOwnerView("JURA219_GRIDNTA", "BOX_F03_NTA")
	
	oView:EnableTitleView("JURA219_GRIDNT4", STR0027) //"Andamentos"
	oView:EnableTitleView("JURA219_GRIDNTA", STR0028) //"Follow-ups"
	
	oView:SetUseCursor( .T. )
	oView:EnableControlBar( .T. )

	oView:AddUserButton( STR0032, "BUDGET", { |oView| PalavraChv(oView) } )                       //"Palavra Chave"
	oView:AddUserButton( STR0079, "BUDGET", { |oView| Processa( {|| CallFill95(oView) } ) } )     //"Importar Manual"	
	oView:AddUserButton( STR0107, "BUDGET", { |oView| Processa( {|| ImportDist(oView,.T.) } ) } ) //"Importar Incidente"
	oView:AddUserButton( STR0023, "BUDGET", { |oView| ExcluiDist(oView)} )                        //"Excluir Distri."
	oView:AddUserButton( STR0018, "BUDGET", { |oView| RestDist(oView)} )                          //"Restaurar Distri."
	oView:AddUserButton( STR0093, "BUDGET", { |oView| JA219Export(oView)} )                       //"Exportar Recebidas"	
	oView:AddUserButton( STR0102, "BUDGET", { |oView| Processa( {|| AbrirDocs(oView)} ) } )       //"Abrir Documentos"	
	oView:AddUserButton( STR0101, "BUDGET", { |oView| Processa( {|| BaixarDocs(oView)} ) } )      //"Baixar Documentos"
	oView:AddUserButton( STR0104, "BUDGET", { |oView, oBotao | J219Marcar(oView, oBotao) } )      //"Marcar Todos"
	oView:AddUserButton( STR0052, "BUDGET", { |oView| Processa( {|| AtuTela(oView, .T.)} ) } )    //"Limpa Tela"

	oView:AddUserButton( STR0078, "BUDGET", { |oView| FiltraDist(oView) } ,,,,.T.)                       //"Filtrar Distribuições"
	oView:AddUserButton( STR0033, "BUDGET", { |oView| Processa( {|| CriaModelo(oView)} ) } ,,,,.T.)      //"Salvar Modelo"
	oView:AddUserButton( STR0034, "BUDGET", { |oView| Processa( {|| CarregaMod(oView) } ) } ,,,,.T.)     //"Carregar Modelo"
	oView:AddUserButton( STR0035, "BUDGET", { |oView| Processa( {|| ImportDist(oView) } ) } ,,,,.T.)     //"Importar"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de importação de documentos

@author André Spirigoni
@since 24/02/14
@version 1.0

@obs NZZMASTER - Dados de importação de documentos

/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := NIL
	Local oStrResumo := FWFormStruct( 1, "NZZ" )
	Local oStrResA1  := FWFormStruct( 1, "NZZ" )
	Local oStrResA2  := FWFormStruct( 1, "NZZ" )
	Local oStrResA3  := FWFormStruct( 1, "NZZ" )
	Local oStructNSZ := FWFormStruct( 1, "NSZ" )
	Local oStructNUQ := FWFormStruct( 1, "NUQ" )
	Local oStructNT9 := FWFormStruct( 1, "NT9" )	
	Local oStructNT4 := FWFormStruct( 1, "NT4", {|cCampo| x3Obrigat(cCampo) .Or. AllTrim(cCampo) $ "NT4_DESC|NT4_DTANDA|NT4_CATO|NT4_DATO"})
	Local oStructNTA := FWFormStruct( 1, "NTA", {|cCampo| x3Obrigat(cCampo) .Or. AllTrim(cCampo) $ "NTA_CTIPO|NTA_DTIPO|NTA_DTFLWP|NTA_CRESUL|NTA_DRESUL|NTA_DESC"})
	Local lObrigEsc  := SuperGetMV("MV_JFTJURI",, "2" ) == "1"		//Define se o campo de escritorio sera obrigatorio
	Local lDistRec   := J219VldPar('MV_PAR05')
		
		oGrid:SetIncMeter(1)
	
	//Inicializa variavel statica
	cCajuri := Space( TamSx3("NSZ_COD")[1] )
	
	oStrResA1:AddField( ;
	""               , ;               // [01] Titulo do campo
	"Check"          , ;               // [02] ToolTip do campo
	"NZZ__TICK"      , ;               // [03] Id do Field
	"L"              , ;               // [04] Tipo do campo
	1                , ;               // [05] Tamanho do campo
	0                , ;               // [06] Decimal do campo
	, ; 							   // [07] Code-block de validação do campo
	, ;                                // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.              )                 // [10] Indica se o campo tem preenchimento obrigatório   ]

	oStrResA3:AddField( ;
	""               , ;               // [01] Titulo do campo
	"Check"          , ;               // [02] ToolTip do campo
	"NZZ__TICK"      , ;               // [03] Id do Field
	"L"              , ;               // [04] Tipo do campo
	1                , ;               // [05] Tamanho do campo
	0                , ;               // [06] Decimal do campo
	, ;                                // [07] Code-block de validação do campo
	, ;                                // [08] Code-block de validação When do campo
	, ;                                // [09] Lista de valores permitido do campo
	.F.              )                 // [10] Indica se o campo tem preenchimento obrigatório   ]
	
	oStrResumo:AddField(	;
	STR0004             , ;               	// [01] Titulo do campo 	//"Qtd. Recebidas"
	STR0005  			, ;               	// [02] ToolTip do campo 	//"Qtd Distribuições Recebidas"
	"NZZ__QTREC"        , ;               	// [03] Id do Field
	"C"                 , ;               	// [04] Tipo do campo
	7                   , ;               	// [05] Tamanho do campo
	0					, ;               	// [06] Decimal do campo
						, ;   				// [07] Code-block de validação do campo
	{||.F.}				, ;               	// [08] Code-block de validação When do campo
						, ; 				// [09] Lista de valores permitido do campo
	.F.                 )	               	// [10] Indica se o campo tem preenchimento obrigatório
	
	oStrResumo:AddField(	;
	STR0006             , ;               	// [01] Titulo do campo 	//"Qtd. Importadas"
	STR0007  			, ;               	// [02] ToolTip do campo 	//"Qtd Distribuições Importadas"
	"NZZ__QTIMP"        , ;               	// [03] Id do Field
	"C"                 , ;               	// [04] Tipo do campo
	7                   , ;               	// [05] Tamanho do campo
	0					, ;               	// [06] Decimal do campo
						, ;   				// [07] Code-block de validação do campo
	{||.F.}				, ;               	// [08] Code-block de validação When do campo
						, ; 				// [09] Lista de valores permitido do campo
	.F.                 )	               	// [10] Indica se o campo tem preenchimento obrigatório

	oStrResumo:AddField(	;
	STR0008             , ;               	// [01] Titulo do campo 	//"Qtd. Excluídas"
	STR0009  			, ;               	// [02] ToolTip do campo 	//"Qtd Distribuições Excluídas"
	"NZZ__QTEXC"        , ;               	// [03] Id do Field
	"C"                 , ;               	// [04] Tipo do campo
	7                   , ;               	// [05] Tamanho do campo
	0					, ;               	// [06] Decimal do campo
						, ;   				// [07] Code-block de validação do campo
	{||.F.}				, ;               	// [08] Code-block de validação When do campo
						, ; 				// [09] Lista de valores permitido do campo
	.F.                 )	               	// [10] Indica se o campo tem preenchimento obrigatório
	
	//Campo utilizado no modelo de processos.
	oStructNSZ:AddField(	;
	""               	, ;					// [01] Titulo do campo
	""		          	, ;               	// [02] ToolTip do campo
	"NSZ__CMOD"      	, ;               	// [03] Id do Field
	"C"              	, ;               	// [04] Tipo do campo
	6                	, ;               	// [05] Tamanho do campo
	0                	, ;               	// [06] Decimal do campo
						, ; 				// [07] Code-block de validação do campo
						, ;                	// [08] Code-block de validação When do campo
						, ;                	// [09] Lista de valores permitido do campo
	.F.              	)                 	// [10] Indica se o campo tem preenchimento obrigatório   ]

	oStructNTA:AddField(	;
	RetTitle("NTE_SIGLA")	, ;               	// [01] Titulo do campo
	RetTitle("NTE_SIGLA")	, ;               	// [02] ToolTip do campo
	"NTA__SIGLA"        	, ;               	// [03] Id do Field
	"C"                 	, ;               	// [04] Tipo do campo
	TamSx3("NTE_SIGLA")[1]	, ;               	// [05] Tamanho do campo
	TamSx3("NTE_SIGLA")[2]	, ;               	// [06] Decimal do campo
	{|| VldSigla() }		, ;//{|| JurGetDados("RD0", 9, xFilial("RD0") + FwFldGet("NTA__SIGLA"), "RD0_TPJUR") == "1" }	, ;	// [07] Code-block de validação do campo
	{||.T.}					, ;               	// [08] Code-block de validação When do campo
							, ; 				// [09] Lista de valores permitido do campo
	.T.                 	)	               	// [10] Indica se o campo tem preenchimento obrigatório
	
	//Tira a obrigatoriedade de alguns campos do model da tela
	oStructNSZ:SetProperty("NSZ_COD"   , MODEL_FIELD_OBRIGAT, .F.)
	oStructNSZ:SetProperty("NSZ_DTINCL", MODEL_FIELD_OBRIGAT, .F.)
	oStructNSZ:SetProperty("NSZ_USUINC", MODEL_FIELD_OBRIGAT, .F.)
	oStructNSZ:SetProperty("NSZ_SITUAC", MODEL_FIELD_OBRIGAT, .F.)
	oStructNSZ:SetProperty("NSZ_CESCRI", MODEL_FIELD_OBRIGAT, lObrigEsc)
	
	oStructNT9:SetProperty("NT9_CAJURI", MODEL_FIELD_OBRIGAT, .F.)
	oStructNT9:SetProperty("NT9_CTPENV", MODEL_FIELD_OBRIGAT, .F.)
	
	oStructNUQ:SetProperty("NUQ_CAJURI", MODEL_FIELD_OBRIGAT, .F.)
	oStructNUQ:SetProperty("NUQ_NUMPRO", MODEL_FIELD_OBRIGAT, .F.)
	oStructNUQ:SetProperty("NUQ_CCOMAR", MODEL_FIELD_OBRIGAT, .F.)
	oStructNUQ:SetProperty("NUQ_CLOC2N", MODEL_FIELD_OBRIGAT, .F.)
	oStructNUQ:SetProperty("NUQ_CLOC3N", MODEL_FIELD_OBRIGAT, .F.)
	
	oStructNT4:SetProperty("NT4_CAJURI", MODEL_FIELD_OBRIGAT, .F.)
	
	oStructNTA:SetProperty("NTA_CAJURI", MODEL_FIELD_OBRIGAT, .F.)

	//Força campos memos a serem apresentados como caracteres
	oStructNT4:SetProperty("NT4_DESC", MODEL_FIELD_TIPO		, "C")
	oStructNT4:SetProperty("NT4_DESC", MODEL_FIELD_TAMANHO	, 500)
	oStructNTA:SetProperty("NTA_DESC", MODEL_FIELD_TIPO		, "C")
	oStructNTA:SetProperty("NTA_DESC", MODEL_FIELD_TAMANHO	, 500)

	//Inicializa campos
	oStructNT9:SetProperty("NT9_PRINCI", MODEL_FIELD_INIT, {|| '1'			})	//1=Principal 2=Não
	oStructNUQ:SetProperty("NUQ_INSATU", MODEL_FIELD_INIT, {|| '1' 			})	//1=Sim
	oStructNUQ:SetProperty("NUQ_INSTAN", MODEL_FIELD_INIT, {|| '1' 			})	//1=1ª Instância
	oStructNTA:SetProperty("NTA_DTFLWP", MODEL_FIELD_INIT, {|| dDataBase 	})
	If oStructNTA:HasField("NTA_DTLIMT")
		oStructNTA:SetProperty("NTA_DTLIMT", MODEL_FIELD_INIT, {|| dDataBase+1 	})
	EndIf	
	
	//Acerta validações	
	oStructNSZ:SetProperty("NSZ_CCLIEN" , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "Vazio() .Or. ExistCpo('SA1', M->NSZ_CCLIEN, 1)") )
	oStructNSZ:SetProperty("NSZ_LCLIEN" , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "Vazio().Or.( ExistCpo('SA1', M->NSZ_CCLIEN + M->NSZ_LCLIEN, 1) .And. JVldClRst(M->NSZ_CCLIEN, M->NSZ_LCLIEN) .And. J219CliNt9() )") )
	
	oStructNT9:SetProperty("NT9_CTPENV" , MODEL_FIELD_VALID,  {|| Vazio() .Or. ( ExistCpo('NQA', FwFldGet("NT9_CTPENV"),1) .And. JURA105TE2() .And. JurVldRest('NQA', FwFldGet("NT9_CTPENV")) ) })
	oStructNUQ:SetProperty("NUQ_CTIPAC" , MODEL_FIELD_VALID,  {|| Vazio() .Or. ( ExistCpo('NQU', FwFldGet("NUQ_CTIPAC"),1) .AND. J183VLNQU('NUQDETAIL', 'NUQ_CNATUR') .AND. JurVldRest('NQU', FwFldGet("NUQ_CTIPAC")) ) })
	
	//----------------------------------------------
	//Monta o modelo do formulário
	//----------------------------------------------
	oModel:= MPFormModel():New("JURA219", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	
	oModel:SetDescription(STR0001) 	//"Importação de Distribuições"

	//Aba resumo
	oModel:AddFields("NZZMASTER", Nil, oStrResumo, /*Pre-Validacao*/, /*Pos-Validacao*/)
	oModel:AddGrid("NZZDETAIL1", "NZZMASTER" /*cOwner*/, oStrResA1, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/)
	oModel:AddGrid("NZZDETAIL2", "NZZMASTER" /*cOwner*/, oStrResA2, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/)
	oModel:AddGrid("NZZDETAIL3", "NZZMASTER" /*cOwner*/, oStrResA3, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/)

	oModel:SetRelation( "NZZDETAIL1", { { "NZZ_FILIAL", "XFILIAL('NZZ')" } }, NZZ->( IndexKey( 1 ) ) )
	oModel:SetRelation( "NZZDETAIL2", { { "NZZ_FILIAL", "XFILIAL('NZZ')" } }, NZZ->( IndexKey( 1 ) ) )
	oModel:SetRelation( "NZZDETAIL3", { { "NZZ_FILIAL", "XFILIAL('NZZ')" } }, NZZ->( IndexKey( 1 ) ) )
	
	oModel:GetModel("NZZMASTER"):SetDescription(STR0015) 	//"Informações das Distribuições"
	oModel:GetModel("NZZDETAIL1"):SetDescription(STR0012) 	//"Distribuições recebidas"
	oModel:GetModel("NZZDETAIL2"):SetDescription(STR0011) 	//"Distribuições importadas"
	oModel:GetModel("NZZDETAIL3"):SetDescription(STR0013) 	//"Distribuições excluidas"

	oModel:SetOptional( "NZZDETAIL2" , .T. )
	oModel:SetOptional( "NZZDETAIL3" , .T. )
	
	//Aba campos obrigatorios
	oModel:AddFields("NSZMASTER", "NZZMASTER" /*cOwner*/, oStructNSZ, /*Pre-Validacao*/, /*Pos-Validacao*/)
	oModel:AddGrid( "NT9DETAIL"	, "NZZMASTER" /*cOwner*/, oStructNT9, /*bLinePre*/, {|oX, oY| VlLiPosNT9(oX, oY)}/*bLinePost*/	, /*bPre*/, /*bPost*/ )
	oModel:AddGrid( "NUQDETAIL"	, "NZZMASTER" /*cOwner*/, oStructNUQ, /*bLinePre*/, /*bLinePost*/								, /*bPre*/, /*bPost*/ )

	oModel:SetRelation( "NSZMASTER", { { "NSZ_FILIAL", "XFILIAL('NSZ')" }, { "NSZ_COD"   , "'"+cCajuri+"'" } }, NSZ->( IndexKey( 1 ) ) )	//NSZ_FILIAL+NSZ_COD
	oModel:SetRelation( "NT9DETAIL", { { "NT9_FILIAL", "XFILIAL('NT9')" }, { "NT9_CAJURI", "'"+cCajuri+"'" } }, NT9->( IndexKey( 2 ) ) )	//NT9_FILIAL+NT9_CAJURI
	oModel:SetRelation( "NUQDETAIL", { { "NUQ_FILIAL", "XFILIAL('NUQ')" }, { "NUQ_CAJURI", "'"+cCajuri+"'" } }, NUQ->( IndexKey( 1 ) ) )	//NUQ_FILIAL+NUQ_CAJURI	
	
	oModel:GetModel("NSZMASTER"):SetDescription(STR0029)	//"Assuntos Jurídicos"
	oModel:GetModel("NT9DETAIL"):SetDescription(STR0031)	//"Envolvidos"
	oModel:GetModel("NUQDETAIL"):SetDescription(STR0030)	//"Instâncias"		
	
	oModel:GetModel( "NT9DETAIL" ):SetUniqueLine( { "NT9_COD" } )
	oModel:GetModel( "NUQDETAIL" ):SetUniqueLine( { "NUQ_COD" } )	
	
	oModel:GetModel( "NT9DETAIL" ):SetMaxLine(3)
	oModel:GetModel( "NUQDETAIL" ):SetMaxLine(1)
	
	//Aba andamentos
	oModel:AddGrid("NT4MASTER" , "NZZMASTER" /*cOwner*/, oStructNT4, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/)
	oModel:SetRelation( "NT4MASTER", { { "NT4_FILIAL", "XFILIAL('NT4')" }, { "NT4_CAJURI", "'"+cCajuri+"'" } }, NT4->( IndexKey( 2 ) ) )	//NT4_FILIAL+NT4_CAJURI
	oModel:GetModel("NT4MASTER"):SetDescription(STR0027)	//"Andamentos"
	oModel:SetOptional( "NT4MASTER" , .T. )

	//Aba follow-ups
	oModel:AddGrid("NTAMASTER" , "NZZMASTER" /*cOwner*/, oStructNTA, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/)
	oModel:SetRelation( "NTAMASTER", { { "NTA_FILIAL", "XFILIAL('NTA')" }, { "NTA_CAJURI", "'"+cCajuri+"'" } }, NTA->( IndexKey( 2 ) ) )	//NTA_FILIAL+NTA_CAJURI
	oModel:GetModel("NTAMASTER"):SetDescription(STR0028)	//"Follow-ups"
	oModel:SetOptional( "NTAMASTER" , .T. )
	
	//Carrega filtro
	If lDistRec
		cLoadFilter := " AND NZZ_DTDIST >= '" + DtoS(MV_PAR01) + "' AND NZZ_DTDIST <= '" + DtoS(MV_PAR02) + "' " //Data da Distribuição
	Else
		cLoadFilter := " AND NZZ_DTREC >= '" + DtoS(MV_PAR01) + "' AND NZZ_DTREC <= '" + DtoS(MV_PAR02) + "' " //Data do Recebimento
	EndIf
	
	If !Empty(MV_PAR03)
		cLoadFilter += " AND NZZ_LOGIN = '" + AllTrim(MV_PAR03) + "' "
	EndIf
	
	//Filtro das palavras chave
	cPalavraChv := ""

	oModel:GetModel( 'NZZDETAIL1' ):SetLoadFilter( , "NZZ_STATUS = '1'" + cLoadFilter + cPalavraChv )
	oModel:GetModel( 'NZZDETAIL2' ):SetLoadFilter( , "NZZ_STATUS = '2'" + cLoadFilter )
	oModel:GetModel( 'NZZDETAIL3' ):SetLoadFilter( , "NZZ_STATUS = '3'" + cLoadFilter )

	//Define que nao permitira a alteração dos dados
	oModel:GetModel("NZZMASTER"):SetOnlyView(.T.)

	oModel:SetVldActivate( {|oModel| FazFiltro(oModel)} )

	oModel:SetActivate( {|oModel| CarDefault(oModel)} )
	
	JurSetRules(oModel, "NZZMASTER", , "NZZ")
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} FazFiltro
Faz o filtro do model quando for ativado.

@param  oModel - Model que esta sendo ativo
@author Rafael Tenorio da Cost
@since 	25/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FazFiltro(oModel)

	oGrid:SetIncMeter(1)

	//Filtro utiliza para trazer a tela sempre preechida, depois de ter cido feito uma vez 	
	oModel:SetRelation( "NSZMASTER", { { "NSZ_FILIAL", "XFILIAL('NSZ')" }, { "NSZ_COD"   , "'"+cCajuri+"'" } }, NSZ->( IndexKey( 1 ) ) )	//NSZ_FILIAL+NSZ_COD
	oModel:SetRelation( "NUQDETAIL", { { "NUQ_FILIAL", "XFILIAL('NUQ')" }, { "NUQ_CAJURI", "'"+cCajuri+"'" } }, NUQ->( IndexKey( 1 ) ) )	//NUQ_FILIAL+NUQ_CAJURI
	oModel:SetRelation( "NT9DETAIL", { { "NT9_FILIAL", "XFILIAL('NT9')" }, { "NT9_CAJURI", "'"+cCajuri+"'" } }, NT9->( IndexKey( 2 ) ) )	//NT9_FILIAL+NT9_CAJURI
	oModel:SetRelation( "NT4MASTER", { { "NT4_FILIAL", "XFILIAL('NT4')" }, { "NT4_CAJURI", "'"+cCajuri+"'" } }, NT4->( IndexKey( 2 ) ) )	//NT4_FILIAL+NT4_CAJURI
	oModel:SetRelation( "NTAMASTER", { { "NTA_FILIAL", "XFILIAL('NTA')" }, { "NTA_CAJURI", "'"+cCajuri+"'" } }, NTA->( IndexKey( 2 ) ) )	//NTA_FILIAL+NTA_CAJURI

	//Aplica filtro de distribuições
	oModel:GetModel( 'NZZDETAIL1' ):SetLoadFilter( , "NZZ_STATUS = '1'" + cLoadFilter + cPalavraChv )
	oModel:GetModel( 'NZZDETAIL2' ):SetLoadFilter( , "NZZ_STATUS = '2'" + cLoadFilter )
	oModel:GetModel( 'NZZDETAIL3' ):SetLoadFilter( , "NZZ_STATUS = '3'" + cLoadFilter )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CarDefault
Carrega default dos campos.

@param  oModel - Model que esta sendo ativo
@author Rafael Tenorio da Costa
@since 	09/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarDefault(oModel)

	Local oModelNTA := oModel:GetModel("NTAMASTER")
	Local nLinhaNTA := oModelNTA:nLine
	Local nCont     := 0
	
	//Carrega valor default de alguns campos
	oModel:LoadValue("NSZMASTER", "NSZ_TIPOAS", cTipoAJ )
	oModel:LoadValue("NSZMASTER", "NSZ_HCITAC", '2' 	)	//2=Não
	oModel:LoadValue("NSZMASTER", "NSZ_LITISC", '2'		)	//2=Não
	
	//Carrega instancia atual
	oModel:GetModel("NUQDETAIL"):LoadValue("NUQ_INSATU", "1")

	//Carrega as siglas dos follow-ups
	If aSiglas <> Nil 
		For nCont:=1 To Len(aSiglas)
			If oModelNTA:Length() >= nCont .And. !Empty(aSiglas[nCont])
				oModelNTA:GoLine(nCont)
				oModelNTA:LoadValue("NTA__SIGLA", aSiglas[nCont])
			EndIf
		Next nCont

		oModelNTA:GoLine(nLinhaNTA)
	EndIf	

	//Atualiza o field de resumo da NZZ
	AtuResumo()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuResumo
Atualiza o field de resumo da NZZ

@param  oView	- View de dados de distribuicao
@param  cViewID - Id da View de dados de distribuicao
@author Rafael Tenorio da Costa
@since 	19/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuResumo(oView, cViewID)

	Local oModel   := FwModelActive()
	Local oMdl01   := oModel:GetModel( "NZZDETAIL1")
	Local oMdl02   := oModel:GetModel( "NZZDETAIL2")
	Local oMdl03   := oModel:GetModel( "NZZDETAIL3")
	Local cQtRec   := "0"
	Local cQtImp   := "0"
	Local cQtExc   := "0"
	Local cNumPro  := ""
	Local cReu     := ""
	Local cAutor   := ""
	Local cOcorre  := ""
	Local nValor   := 0
	Local lCpoLink := .F.
	Local cLinks   := ""
	Local dDtAud	:= cTod("  /  /  ")
	Local cHrAud 	:= ""
	Local lCmpAudi  := .F.
	
	Default cViewID := "NZZDETAIL1"
	
	//Verifica se tem o campo de Link
	If oModel:GetModel(cViewID):HasField("NZZ_LINK")
		lCpoLink := .T.
	EndIf
	
	lCmpAudi := oModel:GetModel(cViewID):HasField("NZZ_DTAUDI") .AND. oModel:GetModel(cViewID):HasField("NZZ_HRAUDI") 
	oGrid:SetIncMeter(1)  
	
	//"Qtd. Recebidas"
	If oMdl01:Length() > 0 .And. !oMdl01:isEmpty() .And. !Empty(oMdl01:GetValue("NZZ_COD"))
		cQtRec :=  cValToChar( oMdl01:Length(.T.) )
	EndIf
	
	//"Qtd. Importadas"
	If oMdl02:Length() > 0 .And. !oMdl02:isEmpty() .And. !Empty(oMdl02:GetValue("NZZ_COD"))
		cQtImp :=  cValToChar( oMdl02:Length(.T.) )
	EndIf		
	
	//"Qtd. Excluídas"
	If oMdl03:Length() > 0 .And. !oMdl03:isEmpty() .And. !Empty(oMdl03:GetValue("NZZ_COD"))
		cQtExc := cValToChar( oMdl03:Length(.T.) )
	EndIf		

	oModel:LoadValue('NZZMASTER', 'NZZ__QTREC'	, cQtRec ) 
	oModel:LoadValue('NZZMASTER', 'NZZ__QTIMP'	, cQtImp )
	oModel:LoadValue('NZZMASTER', 'NZZ__QTEXC'	, cQtExc )
	
	If oModel:GetModel(cViewID):Length() > 0
		cNumPro := oModel:GetValue(cViewID, 'NZZ_NUMPRO')
		cReu 	:= oModel:GetValue(cViewID, 'NZZ_REU')
		cAutor 	:= oModel:GetValue(cViewID, 'NZZ_AUTOR')
		cOcorre	:= oModel:GetValue(cViewID, 'NZZ_OCORRE')
		nValor 	:= oModel:GetValue(cViewID, 'NZZ_VALOR')
		
		If lCpoLink
			cLinks := oModel:GetValue(cViewID, "NZZ_LINK")
		EndIf
		
		If lCmpAudi
			dDtAud 	:= oModel:GetValue(cViewID, 'NZZ_DTAUDI')
			cHrAud	:= oModel:GetValue(cViewID, 'NZZ_HRAUDI')
		EndIf
	EndIf
	
	oModel:LoadValue('NZZMASTER', 'NZZ_NUMPRO'	, cNumPro)
	oModel:LoadValue('NZZMASTER', 'NZZ_REU'		, cReu)
	oModel:LoadValue('NZZMASTER', 'NZZ_AUTOR'	, cAutor)
	oModel:LoadValue('NZZMASTER', 'NZZ_OCORRE'	, cOcorre)
	oModel:LoadValue('NZZMASTER', 'NZZ_VALOR'	, nValor)
	
	If lCpoLink
		oModel:LoadValue('NZZMASTER', 'NZZ_LINK', cLinks)
	EndIf
	
	If lCmpAudi
		oModel:LoadValue('NZZMASTER', 'NZZ_DTAUDI'	, dDtAud)
		oModel:LoadValue('NZZMASTER', 'NZZ_HRAUDI'	, cHrAud)
	EndIf
	
	If oView <> Nil
		oView:Refresh("NZZMASTER")
	EndIf	
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiDist
Rotina para excluir distribuições recebidas.

@param  oView	- View de dados
@author Rafael Tenorio da Costa
@since 	18/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ExcluiDist(oView)

	Local oModel     := FwModelActive()
	Local cDetail    := BuscaModel(oView:GetFolderActive("FOLDER_F01_ABAS", 2)[2])
	Local oModelDet  := oModel:GetModel( cDetail )
	Local nI         := 0
	Local nCount     := 0
	Local aSaveLines := FWSaveRows()

	If cDetail == "NZZDETAIL1"
	
		For nI := 1 To oModelDet:Length()
			If oModelDet:GetValue("NZZ__TICK", nI)
				nCount++
				oModelDet:GoLine(nI)

				//Atualiza distribuição
				AtuDistri(oModelDet, "3")	//3=Excluída
			Endif
		Next nI

		If nCount > 0
			Processa( {|| AtuTela(oView)} )
			
			//Posiciona na aba de "Resumo"
			oView:SelectFolder("FOLDER", STR0017, 2)	//"Resumo"
			
			//Posiciona na aba de "Distribuições excluidas"
			oView:SelectFolder("FOLDER_F01_ABAS", STR0013, 2)	//"Distribuições excluidas"
		Endif
	Else
		Alert(STR0016)		//"Operação não permitida para distribuição nesta situação."
	Endif

	FWRestRows( aSaveLines )
	
	Asize(aSaveLines, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RestDist
Rotina para restaurar distribuições excluidas.

@param  oView - View de dados
@author Rafael Tenorio da Costa
@since 	18/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RestDist(oView)

	Local oModel     := FwModelActive()
	Local cDetail    := BuscaModel(oView:GetFolderActive("FOLDER_F01_ABAS", 2)[2])
	Local oModelDet  := oModel:GetModel( cDetail )
	Local nI         := 0
	Local nCount     := 0
	Local aSaveLines := FWSaveRows()

	If cDetail == "NZZDETAIL3"
		For nI := 1 To oModelDet:Length()
			If oModelDet:GetValue("NZZ__TICK", nI)
				nCount++
				oModelDet:GoLine(nI)

				//Atualiza distribuição
				AtuDistri(oModelDet, "1")	//1=Recebida
			Endif
		Next

		If nCount > 0
			Processa( {|| AtuTela(oView)} )
			
			//Posiciona na aba de "Resumo"
			oView:SelectFolder("FOLDER", STR0017, 2)	//"Resumo"
			
			//Posiciona na aba de "Distribuições recebidas"
			oView:SelectFolder("FOLDER_F01_ABAS", STR0012, 2)	//"Distribuições recebidas"
		Endif
	Else
		Alert(STR0016)		//"Operação não permitida para distribuição nesta situação."
	Endif

	FWRestRows( aSaveLines )
	
	Asize(aSaveLines, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaModel()
Retorna o detail da aba que está ativa na aba resumo.

@param  cAba	- Descrição da aba que esta posicionada
@return cDetail	- Indica detail em evidência
@author Rafael Tenorio da Costa
@since 	18/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BuscaModel(cAba)

	Local cDetail := ""

	Do Case
		Case cAba == STR0012		//"Distribuições recebidas"
			cDetail := "NZZDETAIL1"
		Case cAba == STR0011		//"Distribuições importadas"
			cDetail := "NZZDETAIL2"
		Case cAba == STR0013		//"Distribuições excluídas"
			cDetail := "NZZDETAIL3"
	End Case

Return cDetail

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTela
Atualiza a tela com os dados que foram alterados 

@param  oView 	- View de dados
@param  lLimpa	- Define se as abas campos obrigatorios, andamentos e follow-ups devem ser limpos
@author Rafael Tenorio da Costa
@since 	25/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuTela(oView, lLimpa)

	Local oModel   := FwModelActive()
	
	Default lLimpa := .F.

	ProcRegua(0)

	//Limpa variaveis staticas, para não posicionar em nenhum registro na aba campos obrigatorios, andamentos e follow-ups
	If lLimpa
		aSiglas := Nil
		cCajuri := Space( TamSx3("NSZ_COD")[1] )
	EndIf
	
	IncProc(STR0043)		//"Atualizando informações na tela"
	oModel:Deactivate()
	DbSelectArea("NZZ")
	oModel:Activate()
	oView:Refresh()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J219FilNzp()
Retorna o filtro para a consulta padrao NZP.
Uso: Consulta da NZP

@return cFiltro - Filtro que sera aplicado na consulta padrao.
@author Rafael Tenorio da Costa
@since 	18/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J219FilNzp()

	Local cFiltro := "1|3"
	
	If IsInCallStack("JURA219")
		cFiltro := "2|3"
	EndIf	

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} FiltraDist
Abre tela com a consulta a tabela NS8, para selecionar as palavras 
que irão filtrar as distribuições recebidas.

@param  oView - View de dados
@author Rafael Tenorio da Costa
@since 	30/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FiltraDist(oView)

	Local aArea         := GetArea()
	Local oDlg          := Nil
	Local cTitulo       := STR0042 + " " + STR0012	//"Filtro de"		//"Distribuições recebidas"
	Local aCabPaChv     := {"", STR0041}			//"Palavra - Chave"
	Local oCheck        := LoadBitmap( GetResources(), "CHECKED" )      // Legends : CHECKED  / LBOK  /LBTIK
	Local oNoCheck      := LoadBitmap( GetResources(), "UNCHECKED" )    // Legends : UNCHECKED /LBNO
	Local oFWLayer      := Nil
	Local oPnlAcima     := Nil
	Local oPnlAbaixo    := Nil
	Local oPalavraChv   := Nil
	Local cDigitadas    := ""	
	Local aPalavras     := {}
	Local lPalavras     := .F.

	//Carrega palavras chave
	DbSelectArea("NS8")  	//Palavra-Chave
	NS8->( DbSetOrder(2) )	//NS8_FILIAL+NS8_DESCHV
	NS8->( DbGoTop() )

	Do While !Eof()
		If !Empty(NS8->NS8_DESCHV)
			aadd(aPalavras, {.F., NS8->NS8_DESCHV})
			lPalavras := .T.
		EndIf

		NS8->( DbSkip() )
	EndDo
	
	If !lPalavras
		Aadd(aPalavras, {.F., ""})
	EndIf

	//Monta a tela para usuario visualizar consulta
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 6,6 TO 300,550 PIXEL

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg, .F., .F.)

	//Painel Superior
	oFWLayer:AddLine('ACIMA', 60, .F.)
	oFWLayer:AddCollumn('ALL', 100, .T., 'ACIMA')
	oPnlAcima := oFWLayer:GetColPanel( 'ALL', 'ACIMA' )

	// Painel Inferior
	oFWLayer:AddLine('ABAIXO', 40, .F. )
	oFWLayer:AddCollumn('ALL' , 100, .T., 'ABAIXO')
	oPnlAbaixo := oFWLayer:GetColPanel('ALL' , 'ABAIXO')

	//------------------------- Acima -------------------------------------------------------------------------------------------------
	oListBox1 := TwBrowse():New(005,003,Int(oPnlAcima:nWidth/2.05),Int(oPnlAcima:nHeight/2.1),,aCabPaChv,,oPnlAcima,,,,,,,,,,,,.T.,,.T.,,.F.,,,)
	oListBox1:SetArray( aPalavras )
	oListBox1:bLine := {|| {If(aPalavras[oListBox1:nAt,1], oCheck , oNoCheck ), aPalavras[oListBox1:nAt,2]}}
	If  lPalavras
		oListBox1:BLDblClick := {|| aPalavras[ oListBox1:nAt , 1 ] := !aPalavras[ oListBox1:nAt , 1 ] , oListBox1:Refresh()}
	EndIf

	//------------------------- Abaixo -----------------------------------------------------------------------------------------------------
	@ 005,005 Say STR0040 Size 200,008 Color CLR_BLUE PIXEL OF oPnlAbaixo		//"DIGITE AS PALAVRAS-CHAVES SEPARADAS POR VÍRGULA:"
	@ 015,003 Get oPalavraChv Var cDigitadas Memo Size Int(oPnlAbaixo:nWidth/2.05),015 Pixel Of oPnlAbaixo

	@ 035,189 Button STR0038 Size 037, 012 PIXEL OF oPnlAbaixo ACTION ( FilPChave(oView, aPalavras, cDigitadas), oDlg:End() )		//"Filtrar"
	@ 035,234 Button STR0039 Size 037, 012 PIXEL OF oPnlAbaixo ACTION oDlg:End()		//"Cancelar"

	ACTIVATE MSDIALOG oDlg CENTER
	
	oFWLayer:Destroy()
	FreeObj( oFWLayer )
	oFWLayer   := Nil
	oPnlAbaixo := Nil
	oListBox1  := Nil

	Asize(aCabPaChv, 0)
	Asize(aPalavras, 0)

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FilPChave
Gera filtro com palavras chave e palavras digitadas.  

@param  oView 		- View de dados
@param  aPalavras	- Palavras chaves selecionadas
@param  cDigitadas	- Palavras digitadas
@author Rafael Tenorio da Costa
@since 	30/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FilPChave(oView, aPalavras, cDigitadas)

	Local aArea  := GetArea()
	Local aAux   := StrToKarr( cDigitadas, ",")
	Local cBusca := ""
	Local nCont  := 0
	
	//Limpa variavel statica que tem o filtro de palavra chave
	cPalavraChv := ""
	
	//Palavras chave selecionadas
	For nCont:=1 To Len(aPalavras)

		//Verifica se a palavra chave foi selecionada	
		If aPalavras[nCont][1]
				
			cBusca := AllTrim( Upper(aPalavras[nCont][2]) )
			
			cPalavraChv += " AND (	 NZZ_ESCRI  LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_TERMO  LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_TRIBUN LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_OCORRE LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_REU    LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_AUTOR  LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_FORUM  LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_VARA   LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_CIDADE LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_ESTADO LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_ADVOGA LIKE '%" + cBusca + "%'	) "
		EndIf
	Next nCont
	
	//Palavras digitadas
	For nCont:=1 To Len(aAux)
	
		cBusca := AllTrim( Upper(aAux[nCont]) )
		
		If !Empty(cBusca)
		
			cPalavraChv += " AND (	 NZZ_ESCRI  LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_TERMO  LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_TRIBUN LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_OCORRE LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_REU    LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_AUTOR  LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_FORUM  LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_VARA   LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_CIDADE LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_ESTADO LIKE '%" + cBusca + "%'"
			cPalavraChv += 		" OR NZZ_ADVOGA LIKE '%" + cBusca + "%'	) "
		EndIf
	Next nCont
	
	//Posiciona na aba de "Resumo"
	oView:SelectFolder("FOLDER", STR0017, 2)	//"Resumo"
	
	//Posiciona na aba de "Distribuições recebidas"
	oView:SelectFolder("FOLDER_F01_ABAS", STR0012, 2)	//"Distribuições recebidas"

	//Atualiza dados da tela	
	Processa( {|| AtuTela(oView)} )
	
	RestArea( aArea )
	
	Asize(aAux, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AbreJura95
Abre o JURA095 para que seja possivel o usuario criar modelo ou 
alterar o processo.

@param  oView - View de dados
@author Rafael Tenorio da Costa
@since  30/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AbreJura95(oView, nOpcao)

	Local aArea    := GetArea()
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()
	Local oModel   := FwModelActive()
	Local cTipo    := IIF(nOpcao == 3, STR0021, STR0022)	//"Incluir"		//"Alterar" 
	
	//Carrega o tipo do assunto juridico para salvar no modelo
	oModel:LoadValue("NSZMASTER", "NSZ_TIPOAS", cTipoAJ)

	ProcRegua(0)
	
	//JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName("JURA095") 	//Isto serve para o filtro de tela ter sua própia configuração

	//Abre tela de assunto juridico em inclusão para salvar o modelo do processo
	IncProc(STR0037 + STR0029)				//"Carregando..."		//"Assuntos Jurídicos"
	FWExecView(cTipo, "JURA095", nOpcao)

	SetFunName( cFunName )
	AcBrowse := cAceAnt
	
	FWModelActive(oModel, .T.)

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaMod
Carrega dados salvo no modelo para o NSZ, NUQ, NT9.

@param  oView - View de dados
@author Rafael Tenorio da Costa
@since  31/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarregaMod(oView)

	Local aArea  := GetArea()
	Local oModel := FwModelActive()
	
	If MsgYesNo(STR0053, STR0034)	//"Está rotina irá substituir os dados da tela, por um modelo de assunto jurídico já existente. Confirma ?"		//"Carrega Modelo"
	
		ProcRegua(0)
		
		//Limpa model
		AtuTela(oView, .T.)
		
		IncProc(STR0037 + STR0034)		//"Carregando..."		//"Carregar Modelo"
		oModel := ProcCarMod(oModel, cTipoAJ)
		
		FWModelActive(oModel,.T.)
		
		//Posiciona na primeira linha do envolvido e da instancia
		oModel:GetModel("NT9DETAIL"):GoLine( 1 )
		oModel:GetModel("NUQDETAIL"):GoLine( 1 )
		
		//Posiciona na aba de "Campos Obrigatórios"
		oView:SelectFolder("FOLDER", STR0026, 2)	//"Campos Obrigatórios"
	EndIf
	
	FWModelActive(oModel,.T.)
	
	RestArea( aArea )
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ImportDist
Carrega dados salvo no modelo para o NSZ, NUQ, NT9.

@param  oView - View de dados
@author Rafael Tenorio da Costa
@since  31/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ImportDist(oView,lIncidente)
Local aArea      := GetArea()
Local oModel     := FwModelActive()
Local oModelDet  := Nil
Local nLinha     := 0
Local cProcesso  := ""
Local lGravou    := .F.
Local lContinua  := .F.
Local oSaveModel := FWModelActive()			// Alterado apôs analise em conjunto com o Ernani Forastieri.
Local nLinhaAtu  := 0
Local lNT4       := .F.
Local lNTA       := .F.
Local nQtdLinhas := 0
Local nQtdDisImp := 0
Local nImportado := 0
Local lImportou  := .F.
Local cErrosArq  := ""
Local cData      := ''
Local cTexto     := ''
Local cHora      := ""
Local lImpDocFlg := .T.

Default lIncidente := .F.

	ProcRegua(0)
	
	//Efetua pre validações
	If ValidaImp(oView, oModel)
	
		oModelDet := oModel:GetModel( "NZZDETAIL1" )
		nLinhaAtu := oModelDet:nLine
		
		//Verifica se tem andamento
		lNT4 := !oModel:GetModel("NT4MASTER"):IsEmpty()
		
		//Verifica se tem follow-ups
		lNTA := !oModel:GetModel("NTAMASTER"):IsEmpty()
		
		//Carrega quantidade de linas
		nQtdLinhas := oModelDet:Length()
		
		//Carrega quantidade de distribuições para importação
		oModelDet:GoLine( 1 )
		For nLinha:=1 To nQtdLinhas
			If oModelDet:GetValue("NZZ__TICK", nLinha)
				nQtdDisImp++
			EndIf
		Next nLinha
	
		oModelDet:GoLine( 1 )
		For nLinha:=1 To nQtdLinhas 
		
			If oModelDet:GetValue("NZZ__TICK", nLinha)
			
				//"Carregando..."	//"#1 processo(s) de #2"
				nImportado++
				IncProc( I18n(STR0037 + STR0051, {cValToChar(nImportado), cValToChar(nQtdDisImp)}) ) 
			
				cProcesso := ""
				oModelDet:GoLine(nLinha)
				
				Begin Transaction
			
					If oModelDet:HasField("NZZ_DTAUDI") .and. !Empty(oModelDet:GetValue("NZZ_DTAUDI", nLinha))//Verifica se a data de audiencia esta preenchida
						cData  := DtoS(oModelDet:GetValue("NZZ_DTAUDI", nLinha))
						cTexto := oModelDet:GetValue("NZZ_OCORRE", nLinha)
						
						If oModelDet:HasField("NZZ_HRAUDI")
							cHora  := oModelDet:GetValue("NZZ_HRAUDI", nLinha)
						EndIf
					EndIf
					
					
					//Grava processo
					If ( lGravou := GravaPro(oModel, @cProcesso,cData, cHora, cTexto ) )
						//Vincula Incidente
						If (lIncidente .And. lGravou) 
							lGravou := PsqProcOri(cProcesso)
						EndIf


						
						//Grava andamento
						If lNT4
							lGravou := GravaAnd(oModel, cProcesso)
						EndIf	
								
						//Grava follow-up
						If lGravou .And. lNTA
							lGravou := GravaFw(oModel, cProcesso)
						EndIf	
							
						//Atualiza o status das distribuicoes para 2=Importado
						 If lGravou .And. ( lGravou := AtuDistri(oModelDet, "2", cProcesso) )
								 
						 	//Atualiza variavel static
						 	lImportou := .T.
						 	cCajuri   := cProcesso
						 	
						 	While __lSX8
								ConfirmSX8()
							EndDo
						EndIf
					EndIf

				End Transaction

				//Para integração com o Fluig, considerar a pergunta Baixar Docs 1=Sim/ 2=Não
				If !Empty(MV_PAR06) .And. AllTrim( SuperGetMv('MV_JDOCUME', ,'1') )=='3'
					lImpDocFlg := (CVALTOCHAR(MV_PAR06) == '1')
				EndIf
				
				//Baixa os arquivos relacionados a Distribuição
				If oModelDet:HasField("NZZ_LINK") .And. lGravou .And. !Empty( oModelDet:GetValue("NZZ_LINK") ) .And. lImpDocFlg
					cErrosArq += BaixaArqs( oModelDet:GetValue("NZZ_COD"), oModelDet:GetValue("NZZ_LINK") )
				EndIf
				
				//Verifica se houve erro
				If !lGravou
					Exit
				EndIf
			Endif
			
		Next nLinha
		
		//Verifica se teve algum erro
		If !Empty(cErrosArq)
			cErrosArq := STR0094 + CRLF + CRLF + cErrosArq	//"Os arquivos aqui listados não foram baixados, verifique!"
			JurErrLog(cErrosArq, STR0095)					//"Arquivos não baixados"
		EndIf

		//Volta para o model da tela
		FWModelActive(oSaveModel,.T.)
		
		//Atualizando tela se importou alguma distribuicao
		If lImportou
			AtuTela(oView, .T.)
		EndIf	
		
		If lGravou
		
			//Posiciona na aba de "Resumo"
			oView:SelectFolder("FOLDER", STR0017, 2)	//"Resumo"
	
			//Posiciona na aba de "Distribuições importadas"
			oView:SelectFolder("FOLDER_F01_ABAS", STR0011, 2)	//"Distribuições importadas"
			
			//Posiciona na ultima distribuição que foi importada
			oModel:GetModel("NZZDETAIL2"):SeekLine( { {"NZZ_CAJURI", cProcesso} } )
			
			MsgInfo(I18n(STR0047, {cValToChar(nImportado)}))		//"#1 Processo(s) incluído(s) com sucesso."
		Else
		
			While __lSX8
				RollBackSX8()
			EndDo
		
			//Posiciona na aba de "Campos Obrigatórios"
			oView:SelectFolder("FOLDER", STR0026, 2)	//"Campos Obrigatórios"
		EndIf
		
		//Retorna para linha selecionada
		oModelDet:GoLine( nLinhaAtu )
		
		//Limpa mensagem de erro
		oModel:GetErrorMessage(.T.)	
	Endif

	FWModelActive(oSaveModel,.T.)
	
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaPro
Rotina que valida e gerar o assunto juridico com base no model do JURA095.

@param  oModel  - Modelo com dos dados da tela
@param  cProcesso - Codigo do processo que sera gerado
@param  lRetorno - Indica se gerado o processo
@param  cData - Data da audiência quando houver
@param  cHora - Hora da audiência quando houver
@param  cTexto - Texto p/ fup da audiência quando houver

@author Rafael Tenorio da Costa
@since 	01/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaPro(oModel, cProcesso,cData, cHora, cTexto)
Local aArea      := GetArea()
Local aAreaNSZ   := NSZ->( GetArea() )
Local aAreaNUQ   := NUQ->( GetArea() )
Local aAreaNT9   := NT9->( GetArea() )
Local lRetorno   := .T.
Local oModelNSZ  := Nil
Local cCobjet    := ''
Local cCareaj    := ''
Local cTpAss     := ''
Local aErroFwAut := {}
			
	Default cData  := ""
	Default cHora  := ""
	Default cTexto := ""

	oModelNSZ := FWLoadModel("JURA095")

	oModelNSZ:SetOperation(MODEL_OPERATION_INSERT)
	
	oModelNSZ:Activate()
	
	//Carrega assunto juridico	
	oModelNSZ := AtuDadoPro(oModel, oModelNSZ, "NSZMASTER", @lRetorno)
	
	//Carrega instancia	
	If lRetorno
		oModelNSZ := AtuDadoPro(oModel, oModelNSZ, "NUQDETAIL", @lRetorno)
	EndIf	
	
	//Carrega envolvidos
	If lRetorno
		oModelNSZ := AtuDadoPro(oModel, oModelNSZ, "NT9DETAIL", @lRetorno)
	EndIf
	
	//Atualiza assunto juridico com dados da distribuição
	If lRetorno
		oModelNSZ := CarregaDis(oModel, oModelNSZ, @lRetorno)
	EndIf

	//Grava assunto juridico		
	If lRetorno		

		If ( lRetorno := oModelNSZ:VldData() )
	
			If (lRetorno := oModelNSZ:CommitData() )
				cProcesso := oModelNSZ:GetValue("NSZMASTER", "NSZ_COD")
			EndIf	

		EndIf
	EndIf
	
	If lRetorno
		cCobjet:= oModelNSZ:GetValue("NSZMASTER","NSZ_COBJET")
		cCareaj:= oModelNSZ:GetValue("NSZMASTER","NSZ_CAREAJ")
		cTpAss := oModelNSZ:GetValue("NSZMASTER","NSZ_TIPOAS")

		aErroFwAut := JAINCFWAUT('3',cProcesso,cCobjet,cCareaj,cTpAss,cData, cHora)

		If Len(aErroFwAut) > 1
			JurMsgErro(STR0099,aErroFwAut[6])

		ElseIf !aErroFwAut[1]
			// Gravação do Follow-up de Audiencia.
			If !Empty(cData)
				lRetorno := GravaFw(oModel, cProcesso, cData, cHora, cTexto, .T.)
			EndIf
		EndIf
	EndIf

	//Exibe mensagem de erro
	If !lRetorno
		//JurShowErro( oModelNSZ:GetModel():GetErrormessage() )
		JurMsgErro(STR0062)	//"Não foi possível incluir o processo."
	EndIf

	oModelNSZ:Deactivate()	
	oModelNSZ:Destroy()

	RestArea( aAreaNT9 )
	RestArea( aAreaNUQ )
	RestArea( aAreaNSZ )
	RestArea( aArea )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuDadoPro
Atualiza dados no model do JURA095 para gerar o assunto juridico.  

@param  oModel 	   	- Modelo com dos dados da tela
@param  oModelNSZ  	- Modelo do JURA095 onde estao os dados para gravacao
@param  cNomeModel 	- Id do modelo que sera atualizado
@param  lRetorno   	- Indica se atualizado corretamentos os campos
@return	oModelNSZ	- Modelo do JURA095 com os dados atualizados
@author Rafael Tenorio da Costa
@since 	01/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuDadoPro(oModel, oModelNSZ, cNomeModel, lRetorno)

	Local oStructAux := Nil
	Local aCampos    := {}
	Local nCampo     := 0
	Local cCampo     := ""
	Local lAlt       := .F.
	Local xConteudo  := ""
	Local nLinha     := 0
	Local lGrid      := (cNomeModel $ "NUQDETAIL|NT9DETAIL")

	//Carrega campos da estrutura utilizada na tela do JURA219
	oStructAux  := oModel:GetModel(cNomeModel):GetStruct()
	aCampos		:= oStructAux:GetFields()	//Array com os campos da estrutura

	If !lGrid

		//Atualiza dados da NSZ
		For nCampo:=1 To Len(aCampos)

			lAlt      := .T.
			cCampo    := AllTrim( aCampos[nCampo][3] )
			xConteudo := oModel:GetValue(cNomeModel, cCampo)

			//Campos que não seram atualizados
			If cCampo $ "NSZ_COD"
				lAlt := .F.
			EndIf

			//Atualiza dados	
			If lAlt .And. !Empty(xConteudo)
				oModelNSZ:LoadValue(cNomeModel, cCampo, xConteudo)
			EndIf

		Next nCampo

	Else

		//Atualiza dados da NUQ\NT9
		For nLinha:=1 To oModel:GetModel(cNomeModel):Length()

			If !oModel:GetModel(cNomeModel):IsDeleted(nLinha) //valida se a linha não esta deletada
				If nLinha > 1
					If oModelNSZ:GetModel(cNomeModel):AddLine() < nLinha
						lRetorno := .F.
						Exit
					EndIf	
				EndIf

				//Processa os campos
				For nCampo:=1 to Len(aCampos)

					lAlt   := .T.
					cCampo := AllTrim( aCampos[nCampo][3] )

					//Campos que não serão atualizados
					If cCampo $ "NT9_CAJURI|NT9_COD|NUQ_CAJURI|NUQ_COD"
						lAlt := .F.
					EndIf

					//Verifica se campo pode ser alterado
					If lAlt
						xConteudo := oModel:GetModel(cNomeModel):GetValue(cCampo, nLinha)

						//Atualiza dados
						If !Empty(xConteudo)
							oModelNSZ:GetModel(cNomeModel):LoadValue(cCampo, xConteudo)
						EndIf
					Endif
				Next nCampo

				If !lRetorno
					Exit
				EndIf
			Endif
		Next nLinha

	EndIf

Return oModelNSZ

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaAnd  
Rotina para gerar o andamentos

@param  oModel 	  - Modelo com os dados da tela
@param  cProcesso - Codigo do processo que foi gerado
@return lRetorno  - Indica se foi gerado corretamente os andamentos
@author Rafael Tenorio da Costa
@since 	01/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaAnd(oModel, cProcesso)

	Local aArea      := GetArea()
	Local aAreaNT4   := NT4->( GetArea() )
	Local oStructAux := Nil
	Local aCampos    := {}
	Local nCampo     := 0
	Local cCampo     := ""
	Local lAlt       := .F.
	Local xConteudo  := ""
	Local nLinha     := 0
	Local lRetorno   := .T.
	Local oModelNT4  := Nil

	oModelNT4 := FWLoadModel("JURA100")
	
	//Carrega campos da estrutura utilizada na tela do JURA219
	oStructAux  := oModel:GetModel("NT4MASTER"):GetStruct()
	aCampos		:= oStructAux:GetFields()	//Array com os campos da estrutura

	//Atualiza dados da NUQ\NT9
	For nLinha:=1 To oModel:GetModel("NT4MASTER"):Length()
	
		//Verifica se a linha esta deletada
		If !oModel:GetModel("NT4MASTER"):IsDeleted(nLinha)
		
			oModelNT4:SetOperation(MODEL_OPERATION_INSERT)
		
			oModelNT4:Activate()
		
			oModelNT4:LoadValue("NT4MASTER", "NT4_CAJURI", cProcesso)
		
			//Processa os campos
			For nCampo:=1 to Len(aCampos)
			
				lAlt   := .T.
				cCampo := AllTrim( aCampos[nCampo][3] )
				
				//Campos que não serão alterados
				If cCampo $ "NT4_CAJURI|NT4_COD"
					lAlt := .F.
				EndIf 
				
				//Verifica se campo pode ser alterado
				If lAlt
					xConteudo := oModel:GetModel("NT4MASTER"):GetValue(cCampo, nLinha)
				
					//Atualiza dados	
					If !Empty(xConteudo)
					
						If !( lRetorno := oModelNT4:SetValue("NT4MASTER", cCampo, xConteudo) )
							Exit
						EndIf
					EndIf
				Endif
			Next nCampo
			
			If lRetorno
			
				//Valida andamento
				If ( lRetorno := oModelNT4:VldData() )
			
					//Grava andamento
					If ( lRetorno := oModelNT4:CommitData() )
	
						//Confirma andamentos que foram incluidos
						If __lSX8
							ConfirmSX8()
						EndIf
					EndIf
				EndIf
			EndIf
			
			oModelNT4:Deactivate()
			
			//Verifica se teve algum erro
			If !lRetorno
	
				//Volta numeracao do andamento
				If __lSX8
					RollBackSX8()
				EndIf
	
				Exit
			EndIf
			
		EndIf
		
	Next nLinha
	
	//Exibe mensagem de erro
	If !lRetorno
		//JurShowErro( oModelNT4:GetModel():GetErrormessage() )
		JurMsgErro(STR0063)		//"Não foi possível incluir o andamento."
	EndIf
	
	oModelNT4:Destroy()	

	RestArea( aAreaNT4 )
	RestArea( aArea )
	
Return lRetorno	

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaFw  
Rotina para gerar os follow-ups

@param  oModel 	  - Modelo com os dados da tela
@param  cProcesso - Codigo do processo que foi gerado
@param  cData     - Data da Audiencia
@param  cHora     - Hora da Audiencia
@param  cTexto    - Texto para o Follow-up
@param  lAbreTela - Valida se tem que executar o ExecView

@return lRetorno  - Indica se foi gerado corretamente os follow-ups
@author Rafael Tenorio da Costa
@since 	01/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaFw(oModel, cProcesso, cData, cHora, cTexto, lAbreTela)

Local aArea      := GetArea()
Local aAreaNTA   := NT4->( GetArea() )
Local oStructAux := Nil
Local aCampos    := {}
Local nCampo     := 0
Local cCampo     := ""
Local lAlt       := .F.
Local xConteudo  := ""
Local nLinha     := 0
Local lRetorno   := .T.
Local oModelNTA  := Nil

	Default cData     := ""
	Default cHora     := ""
	Default lAbreTela := .F.
	Default cTexto	  := ""
    oModelNTA := FWLoadModel("JURA106")

	// Quando é audiencia, não busca as informações do Grid de Fup.
	If Empty(cData) .OR. Empty(cHora) .Or. Empty(cTexto)
		//Carrega campos da estrutura utilizada na tela do JURA219
		oStructAux  := oModel:GetModel("NTAMASTER"):GetStruct()
		aCampos     := oStructAux:GetFields()	//Array com os campos da estrutura
	EndIf	

	//Inicializa variavel static
	aSiglas  := {}

	//Atualiza dados da NUQ\NT9
	For nLinha := 1 To oModel:GetModel("NTAMASTER"):Length()
		//Verifica se a linha esta deletada
		If !oModel:GetModel("NTAMASTER"):IsDeleted(nLinha)

			oModelNTA:SetOperation(MODEL_OPERATION_INSERT)
			oModelNTA:Activate()
			oModelNTA:LoadValue("NTAMASTER", "NTA_CAJURI", cProcesso)
			
			oModelNTA:LoadValue("NTAMASTER", "NTA_DTFLWP", SToD(cData))
			oModelNTA:LoadValue("NTAMASTER", "NTA_HORA", SubStr(cHora, 1,2) + SubStr(cHora, 4,2))
			oModelNTA:LoadValue("NTAMASTER", "NTA_DESC", cTexto)
			
			If oModelNTA:GetModel("NTEDETAIL"):HasField("NTE_CAJURI")
				oModelNTA:GetModel("NTEDETAIL"):LoadValue("NTE_CAJURI", cProcesso)
			EndIf	
		
			//Processa os campos
			For nCampo:=1 to Len(aCampos)
			
				lAlt   := .T.
				cCampo := AllTrim( aCampos[nCampo][3] )
				
				//Campos que nao seram alterados
				If cCampo $ "NTA_CAJURI|NTA_COD"
					lAlt := .F.
				EndIf 
				
				//Verifica se campo pode ser alterado
				If lAlt
					xConteudo := oModel:GetModel("NTAMASTER"):GetValue(cCampo, nLinha)
				
					//Atualiza dados	
					If !Empty(xConteudo)
						
						If cCampo == "NTA__SIGLA"
							If !( lRetorno := oModelNTA:GetModel("NTEDETAIL"):SetValue("NTE_SIGLA", xConteudo) )
								Exit
							Else
								//Quarda as siglas para serem utilizadas na reabertura da tela
								Aadd(aSiglas, xConteudo)
							EndIf
						Else
							If !( lRetorno := oModelNTA:SetValue("NTAMASTER", cCampo, xConteudo) )
								Exit
							EndIf
						EndIf	
						
					EndIf
				Endif
			Next nCampo
			// Caso necessite interação do usuário, abre a tela
			If lAbreTela
				FWExecView( STR0021/*cTitulo*/, "JURA106"/*cPrograma*/, MODEL_OPERATION_INSERT,  /*oDlg*/, , , /*nPercReducao*/, /*aEnableButtons*/, {|| .T.}/*bCancel*/, /*cOperatId*/,  /*cToolBar*/, oModelNTA/*oModelAct*/)	//"Incluir"
			Else			
				If lRetorno
					//Valida follow-up
					If ( lRetorno := oModelNTA:VldData() )
				
						//Grava follow-up
						If ( lRetorno := oModelNTA:CommitData() )
						
							If __lSX8
								ConfirmSX8()
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			oModelNTA:Deactivate()
			
			//Verifica se teve algum erro
			If !lRetorno
				//Volta ao default da variavel static
				aSiglas := Nil
			
				//Volta numeracao follow-ups
				If __lSX8
					RollBackSX8()
				EndIf
			
				Exit
			EndIf
		EndIf
	Next nLinha
	
	//Exibe mensagem de erro
	If !lRetorno
		JurMsgErro(STR0064)		//"Não foi possível incluir o follow-up."
	EndIf
	
	oModelNTA:Destroy()

	RestArea( aAreaNTA )
	RestArea( aArea )
	
Return lRetorno	

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuDistri 
Atualiza status da distribuicao.
Feito desta maneira porque era apenas 1 campo e tambem para não mexer
no model do JURA219, para ele ficar exclusivo para interações na tela.

@param  oModelDet - Modelo NZZDETAIL? que deve ser atualizado
@param  cStatus   - Status que deve ser atualizado
@param  cProcesso - Codigo do assunto juridico gerado, quando for importação de distribuição
@return lGravou   - Indica se o registros foi atualizado
@author Rafael Tenorio da Costa
@since 	02/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuDistri(oModelDet, cStatus, cProcesso)

	Local aArea     := GetArea()
	Local aAreaNZZ  := NZZ->( GetArea() )
	Local nRecnoNZZ := oModelDet:GetDataID()
	Local lGravou   := .F.
	
	Default cProcesso := ""
	
	NZZ->( DbGoTo(nRecnoNZZ) )
	If !NZZ->( Eof() )
		lGravou := RecLock("NZZ", .F.)
			NZZ->NZZ_STATUS := cStatus
			
			If !Empty(cProcesso)
				NZZ->NZZ_CAJURI := cProcesso 
			EndIf
			 
		NZZ->( MsUnLock() )	
	EndIf

	RestArea( aAreaNZZ )
	RestArea( aArea )

Return lGravou

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaDis
Rotina que carrega informações da distribuição no processo que sera gerado.

@param  oModel 	   - Modelo com os dados da tela
@param  oModelNSZ  - Modelo da JURA095 que sera gravado
@param  lRetorno   - Inidica se as atualização foram feitas corretamente
@return oModelNSZ  - Modelo da JURA095 atualizado com os dados da distribuição
@author Rafael Tenorio da Costa
@since 	07/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarregaDis(oModel, oModelNSZ, lRetorno)
Local oModelNZZ1 := oModel:GetModel("NZZDETAIL1")
Local cNumCaso   := oModel:GetValue("NSZMASTER", "NSZ_NUMCAS")
Local xConteudo  := "" 
Local lReuSemCli := .F.
Local lAutor     := .F.

	//preenche no detalhe do processo a ocorrência da distribuição.
	oModelNSZ := SetOcorDet( oModelNZZ1, oModelNSZ )
	
	//Carrega numero do processo
	If lRetorno
		
		//Tira pontos e traços
		xConteudo := oModelNZZ1:GetValue("NZZ_NUMPRO")
		xConteudo := StrTran(xConteudo, "-", "")
		xConteudo := StrTran(xConteudo, ".", "")
		If !Empty( xConteudo )
			lRetorno := oModelNSZ:GetModel("NUQDETAIL"):SetValue("NUQ_NUMPRO", xConteudo)
		EndIf	
	EndIf

	//Atualiza data de distribuição na instância
	If lRetorno
		xConteudo := oModelNZZ1:GetValue("NZZ_DTDIST")
		lRetorno := oModelNSZ:GetModel("NUQDETAIL"):SetValue("NUQ_DTDIST", xConteudo)
	EndIf
	
	//Carrega comarca, foro, vara
	If lRetorno
		oModelNSZ := CarComarca( oModelNZZ1, oModelNSZ, @lRetorno )
	EndIf
	
	//Carrega cliente e envolvido
	If lRetorno	
		oModelNSZ := CarCliente( oModelNZZ1, oModelNSZ, cNumCaso, @lRetorno, @lReuSemCli, @lAutor )
	EndIf
	
	//Carrega parte contraria envolvido polo ativo
	If lRetorno	.And. !lAutor
		oModelNSZ := CarPartCon( oModelNZZ1, oModelNSZ, @lRetorno, "NZZ_AUTOR", "1", {"autor", "reclamante"})
	EndIf

	//Carrega parte contraria envolvido polo Passivo
	If lRetorno	.And. lReuSemCli
		oModelNSZ := CarPartCon( oModelNZZ1, oModelNSZ, @lRetorno, "NZZ_REU", "2", {"reu", "reclamada"}, lReuSemCli )
	EndIf
	
	//Carrega parte contraria envolvido terceiro interessado
	If lRetorno	
		oModelNSZ := CarPartCon( oModelNZZ1, oModelNSZ, @lRetorno, "NZZ_ADVOGA", "3", {"advogado parte contraria"} )
	EndIf



	//Carrega valor
	If lRetorno
		 
		If oModelNZZ1:GetValue("NZZ_VALOR") > 0 
			If ( lRetorno := oModelNSZ:SetValue("NSZMASTER", "NSZ_VLCAUS", oModelNZZ1:GetValue("NZZ_VALOR")) )
			
				If Empty( oModelNSZ:GetValue("NSZMASTER", "NSZ_DTCAUS") )
					lRetorno := oModelNSZ:SetValue("NSZMASTER", "NSZ_DTCAUS", dDataBase)
				EndIf
				
				If Empty( oModelNSZ:GetValue("NSZMASTER", "NSZ_CMOCAU") )
					lRetorno := oModelNSZ:SetValue("NSZMASTER", "NSZ_CMOCAU", "01")
				EndIf
			EndIf
		EndIf	
	EndIf

Return oModelNSZ

//-------------------------------------------------------------------
/*/{Protheus.doc} SetOcorDet
Adiciona a ocorrência da Distribuição no detalhe do processo.

@param  oModelNZZ1 - Modelo com os dados da distribuição que esta selecionada
@param  oModelNSZ  - Modelo da JURA095 que sera gravado

@return oModelNSZ  - Modelo da JURA095 atualizado com os dados da distribuição

@since   22/04/2020
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function SetOcorDet( oModelNZZ1, oModelNSZ )
Local cDetalhe  := ""
Local cTipoAcao := oModelNZZ1:GetValue("NZZ_OCORRE")
	
	If !Empty( cTipoAcao )
		//Atualiza o detalhamento do objeto
		If oModelNSZ:GetModel("NSZMASTER"):HasField("NSZ_DETALH")
			cDetalhe := oModelNSZ:GetValue("NSZMASTER", "NSZ_DETALH")
			
			oModelNSZ:LoadValue("NSZMASTER", "NSZ_DETALH", cDetalhe + CRLF + cTipoAcao)
		EndIf
	EndIf

Return oModelNSZ

//-------------------------------------------------------------------
/*/{Protheus.doc} CarComarca
Carrega comarca, foro, vara 

@param  oModelNZZ1 - Modelo com os dados da distribuição que esta selecionada
@param  oModelNSZ  - Modelo da JURA095 que sera gravado
@param  lRetorno   - Inidica se as atualização foram feitas corretamente
@return oModelNSZ  - Modelo da JURA095 atualizado com os dados da distribuição
@author Rafael Tenorio da Costa
@since 	07/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarComarca( oModelNZZ1, oModelNSZ, lRetorno )

	Local aArea     := GetArea()
	Local cQuery    := ""
	Local cComarca  := oModelNZZ1:GetValue("NZZ_CIDADE")	
	Local cUF       := oModelNZZ1:GetValue("NZZ_ESTADO")
	Local cForum    := oModelNZZ1:GetValue("NZZ_FORUM")
	Local cVara     := oModelNZZ1:GetValue("NZZ_VARA")
	Local aRetorno  := {}
	Local nCont     := 0
	Local cErro     := ""
	Local cComarNSZ := oModelNSZ:GetValue("NUQDETAIL", "NUQ_CCOMAR")	
	Local cForumNSZ := oModelNSZ:GetValue("NUQDETAIL", "NUQ_CLOC2N")
	Local cVaraNSZ  := oModelNSZ:GetValue("NUQDETAIL", "NUQ_CLOC3N")
	Local aReplace	:= {}
	
	Aadd(aReplace, {"'°','o'", "'°',''"})
	Aadd(aReplace, {"'º','o'", "'º',''"})
	Aadd(aReplace, {"'ª','a'", "'ª',''"})
	
	//Verifica se a comarca do processo já esta preenchida pelo CNJ ou pela aba Campos Obrigatórios
	If !Empty(cComarNSZ)
		Aadd(aRetorno, {cComarNSZ} )
		
	//Procura comarca com a descrição da Distribuição
	ElseIf !Empty(cComarca) .And. !Empty(cUF) 

		//Limpa conteudo do campo
		cComarca := StrTran( StrTran( StrTran(cComarca, '°','') ,'º',''), 'ª','')
		cComarca := AllTrim( StrTran( Lower( JurLmpCpo(cComarca) ), "#", " ") )   
		cUF 	 := AllTrim( StrTran( Lower( JurLmpCpo(cUF) ), "#", " ") )

		//Carrega comarca
		cQuery := " SELECT NQ6_COD"	
		cQuery += " FROM " + RetSqlName("NQ6")
		cQuery += " WHERE NQ6_FILIAL = '" + xFilial("NQ6") + "'"
		cQuery += 	" AND " + JurFormat("NQ6_DESC", .T./*lAcentua*/, .T./*lPontua*/) + " LIKE '" + cComarca + "%'"
		cQuery += 	" AND " + JurFormat("NQ6_UF"  , .T./*lAcentua*/, .T./*lPontua*/) + " LIKE '" + cUF + "%'"
		cQuery += 	" AND D_E_L_E_T_ = ' ' "

		aRetorno := JurSQL(cQuery, "NQ6_COD", /*lCommit*/, aReplace)
	EndIf

	If Len(aRetorno) == 0
		lRetorno := .F.

		//Seta o erro se não for importação manual
		If !IsInCallStack("SugInfoProc")
			cErro	 := STR0082		//"Cidade\UF da Distribuição e Comarca na aba Campos Obrigatórios não foram localizados" 
			oModelNSZ:SetErrorMessage( /*cIdForm*/, /*cIdField*/, /*cIdFormErr*/, "NUQ_CCOMAR", /*cId*/,;
					   					cErro	  , /*cSolucao*/, /*xValue*/	, /*xOldValue*/	 )
		EndIf
	Else

		cComarca := AllTrim( aRetorno[1][1] ) 
		aRetorno := {}
		
		//Verifica se o forum do processo já esta preenchido pelo CNJ ou pela aba Campos Obrigatórios
		If !Empty(cForumNSZ)
			Aadd(aRetorno, {cForumNSZ} )
		
		//Procura forum com a descrição da Distribuição
		ElseIf !Empty(cForum)
		
			cForum := StrTran( StrTran( StrTran(cForum, '°','') ,'º',''), 'ª','')
			cForum := StrTran( Upper(cForum), "FORO", "")		//Retira a palavra foro por causa da integração CNJ
			cForum := AllTrim( StrTran( Lower( JurLmpCpo(cForum) ), "#", " ") )
			
			//Carrega foro
			cQuery := " SELECT NQC_COD"
			cQuery += " FROM " + RetSqlName("NQC")
			cQuery += " WHERE NQC_FILIAL = '" + xFilial("NQC")+ "'" 
			cQuery += 	" AND NQC_CCOMAR = '" + cComarca + "'"
			cQuery += 	" AND " + JurFormat("NQC_DESC", .T./*lAcentua*/, .T./*lPontua*/) + " LIKE '%" + cForum + "%'"
			cQuery += 	" AND D_E_L_E_T_ = ' ' "

			aRetorno := JurSQL(cQuery, "NQC_COD", /*lCommit*/, aReplace)
		EndIf
	
		If Len(aRetorno) == 0
			lRetorno := .F.

			//Seta o erro se não for importação manual
			If !IsInCallStack("SugInfoProc")

				cErro	 := STR0083		//"Forum da Distribuição e Foro na aba Campos Obrigatórios não foram localizados"
				oModelNSZ:SetErrorMessage( /*cIdForm*/, /*cIdField*/, /*cIdFormErr*/, "NUQ_CLOC2N", /*cId*/,;
							   				cErro	  , /*cSolucao*/, /*xValue*/	, /*xOldValue*/	 )
			EndIf
		Else

			cForum 	 := AllTrim( aRetorno[1][1] )  
			aRetorno := {}
			
			//Verifica se a vara do processo já esta preenchida pelo CNJ ou pela aba Campos Obrigatórios
			If !Empty(cVaraNSZ)
				Aadd(aRetorno, {cVaraNSZ} )
			
			//Procura vara com a descrição da Distribuição
			ElseIf !Empty(cVara)
			
				cVara := StrTran( StrTran( StrTran(cVara, '°','') ,'º',''), 'ª','')
				cVara := AllTrim( StrTran( Lower( JurLmpCpo(cVara) ), "#", " ") )
				cVara := SubStr( AllTrim( cVara ), 1, TamSx3("NQE_DESC")[1] )			//Faz isso para pesquisar corretamente caso tenha incluído a vara pela importação de alguma outra distribuição
				
				cQuery := " SELECT NQE_COD"
				cQuery += " FROM " + RetSqlName("NQE")
				cQuery += " WHERE NQE_FILIAL = '" + xFilial("NQE") + "'" 
				cQuery += 	" AND NQE_CLOC2N = '" + cForum + "'"
				cQuery += 	" AND " + JurFormat("NQE_DESC", .T./*lAcentua*/, .T./*lPontua*/) + " LIKE '%" + cVara + "%'"
				cQuery += 	" AND D_E_L_E_T_ = ' '"
	
				aRetorno := JurSQL(cQuery, "NQE_COD", /*lCommit*/, aReplace)
			EndIf
			
			If Len(aRetorno) > 0
				cVara := AllTrim( aRetorno[1][1] )
			Else
				//Cadastra a vara
				cVara := J219IncNQE( cComarca, cForum, SubStr( AllTrim(oModelNZZ1:GetValue("NZZ_VARA")), 1, TamSx3("NQE_DESC")[1] ), @lRetorno)	
			EndIf 
			
			If lRetorno
				cVara := AllTrim( cVara )
				
				aRetorno := {}
				Aadd(aRetorno, {"NUQ_CCOMAR", cComarca})
				Aadd(aRetorno, {"NUQ_CLOC2N", cForum  })
				Aadd(aRetorno, {"NUQ_CLOC3N", cVara	  })
	
				For nCont:=1 To Len(aRetorno)
				
					If !( oModelNSZ:SetValue("NUQDETAIL", aRetorno[nCont][1], aRetorno[nCont][2]) )
						lRetorno := .F.
						Exit
					EndIf	
				Next nCont
			EndIf
			
		EndIf
			
	EndIf
	
	RestArea( aArea )
	
Return oModelNSZ

//-------------------------------------------------------------------
/*/{Protheus.doc} CarCliente
Carrega cliente no processo e nos envolvidos 

@param  oModelNZZ1 - Modelo com os dados da distribuição que esta selecionada
@param  oModelNSZ  - Modelo da JURA095 que sera gravado
@param  cNumCaso   - Numero do caso da tela
@param  lRetorno   - Inidica se as atualização foram feitas corretamente
@return oModelNSZ  - Modelo da JURA095 atualizado com os dados da distribuição
@author Rafael Tenorio da Costa
@since 	08/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarCliente( oModelNZZ1, oModelNSZ, cNumCaso, lRetorno, lSemCli, lAutor )

	Local aArea     := GetArea()
	Local cQueryPad := ""
	Local cQuery    := ""
	Local cReu      := oModelNZZ1:GetValue("NZZ_REU")
	Local cAutor    := oModelNZZ1:GetValue("NZZ_AUTOR")
	Local oModelNT9 := oModelNSZ:GetModel("NT9DETAIL")
	Local cCodCli   := ""	
	Local cLojCli   := ""
	Local cNomeCli  := "" 
	Local aRetorno  := {}
	Local nCont     := 0
	Local nQtdLinhas:= 0
	Local nLinhaAtu := oModelNT9:nLine
	Local aAuxBaVe  := StrToKarr( cReu, "|")			//Existe momentos que esta vindo este caractere no campo reu
	Local cErro     := ""
	Local cTipoEnv  := ""
	Local cPolo     := "" 
	Local lPrincipal := .F. //valida se já existe

	Default lSemCli  := .F.
	Default lAutor   := .F.

	If !Empty(cReu)
	
		//Não encontrou o cliente, carrega todos para selecionar
		
		aRetorno := J219SqlCli(cReu)

		If Len(aRetorno) == 0
			lSemCli := .T.	
			aRetorno := J219SqlCli(cAutor,@cQueryPad)

			If Len(aRetorno) > 0
				lAutor := .T.
			Else
				aRetorno := JurSQL(cQueryPad, {"NUH_COD", "NUH_LOJA", "A1_NOME"})
			EndIf

		EndIf
		
		If Len(aRetorno) > 0

			For nCont:=1 To oModelNT9:Length()
				If !oModelNT9:isEmpty(nCont) .And. !oModelNT9:IsDeleted(nCont)
					If oModelNT9:GetValue("NT9_TIPOEN") == Iif(lAutor,'1','2') .And. oModelNT9:GetValue("NT9_PRINCI") == '1'
						lPrincipal = .T.
					Endif
				Endif
			Next nCont

			//Verifica se o cliente da tela foi retornado pela consulta
			nPosCli := Ascan(aRetorno, {|x| x[1] == oModelNSZ:GetValue("NSZMASTER", "NSZ_CCLIEN") .And.;
											x[2] == oModelNSZ:GetValue("NSZMASTER", "NSZ_LCLIEN")})
			If nPosCli > 0
				cCodCli := aRetorno[nPosCli][1]
				cLojCli := aRetorno[nPosCli][2]
				cNomeCli:= aRetorno[nPosCli][3]
			Else		
			
				//Se for importação manual não apresenta tela para selecionar O cliente
				If IsInCallStack("SugInfoProc")

					cCodCli := aRetorno[1][1]
					cLojCli := aRetorno[1][2]
					cNomeCli:= aRetorno[1][3]
					
					If Empty(oModelNSZ:GetValue("NSZMASTER", "NSZ_CCLIEN")) .And. !Empty(cCodCli)//preenche o cliente se ele não foi preenchido
						lRetorno := oModelNSZ:SetValue("NSZMASTER", "NSZ_CCLIEN", cCodCli)
						
						If lRetorno
							lRetorno := oModelNSZ:SetValue("NSZMASTER", "NSZ_LCLIEN", cLojCli)
						EndIf
					EndIf
				Else

				//Seleciona o cliente
				nPosCli := IIF(Len(aRetorno) > 1, SelCliente(aRetorno), 1)
				cCodCli := aRetorno[nPosCli][1]
				cLojCli := aRetorno[nPosCli][2]
				cNomeCli:= aRetorno[nPosCli][3]
				
				If Empty(oModelNSZ:GetValue("NSZMASTER", "NSZ_CCLIEN")) //preenche o cliente se ele não foi preenchido
					lRetorno := oModelNSZ:SetValue("NSZMASTER", "NSZ_CCLIEN", cCodCli)
					
					If lRetorno
						lRetorno := oModelNSZ:SetValue("NSZMASTER", "NSZ_LCLIEN", cLojCli)
					EndIf
				EndIf
			EndIf
		EndIf
			
		//Valida preenchimento do num caso
		If lRetorno
			lRetorno := BuscaNVE(@oModelNSZ, cNomeCli, cNumCaso)
		EndIf
				
		If lRetorno

			//Envolvido com Entidade
			If SuperGetMV('MV_JENVENT',, '2') == "1"
			
				If !oModelNT9:SeekLine( {{"NT9_ENTIDA", "SA1"}, {"NT9_CEMPCL", cCodCli}, {"NT9_LOJACL", cLojCli}} ) 
				
					//Adiciona nova linha
					nQtdLinhas := oModelNT9:Length()
					If oModelNT9:AddLine() < nQtdLinhas
						lRetorno := .F.
					Else
						lRetorno := oModelNT9:SetValue('NT9_ENTIDA', "SA1")	
					EndIf
				EndIf
				
				If lRetorno
					J105SetDados("SA1", cCodCli + cLojCli)
					
					lRetorno := oModelNT9:SetValue('NT9_CODENT', cCodCli + cLojCli)
				EndIf
			Else
			
				If !oModelNT9:SeekLine( {{"NT9_TIPOCL", "1"}, {"NT9_CEMPCL", cCodCli}, {"NT9_LOJACL", cLojCli}} )
				
					//Adiciona nova linha
					nQtdLinhas := oModelNT9:Length()
					If oModelNT9:AddLine() < nQtdLinhas
						lRetorno := .F.
					Else
						lRetorno := oModelNT9:SetValue('NT9_TIPOCL', "1")
					EndIf
				
					If lRetorno .And. ( lRetorno := oModelNT9:SetValue('NT9_CEMPCL', cCodCli) )
						lRetorno := oModelNT9:SetValue('NT9_LOJACL', cLojCli)
					EndIf
					
					oModelNT9:LoadValue('NT9_TFORNE', "2")
				EndIf
			EndIf
				
			//Atualiza o tipo de envolvimento caso não tenha sido preenchido]
			If lRetorno .And. Empty( oModelNT9:GetValue("NT9_CTPENV") )

				cPolo := oModelNT9:GetValue("NT9_TIPOEN")
				cPolo := IIF( Empty(cPolo), "2", cPolo)		//Polo Passivo
					
				If lAutor
					cPolo  := "1"
					cTpEnv := "autor"
				Else	
					cTpEnv := "reu"
				EndIf

				If ( lRetorno := oModelNT9:SetValue('NT9_TIPOEN', cPolo) )
					
					cTipoEnv := J219GetNQA( {cTpEnv}, cPolo )
						
					If !Empty(cTipoEnv)
						lRetorno := oModelNT9:SetValue('NT9_CTPENV', cTipoEnv)
					Else
						lRetorno := .F.
						cErro	 := STR0084		//"Tipo de envolvimento do cliente não preenchido, e não foi localizado um tipo de envolvimento com a descrição Réu." 
						oModelNSZ:SetErrorMessage( , , , "NT9_CTPENV", , cErro, , , )
						EndIf
					EndIf
				EndIf
				
				If lRetorno 
					If (oModelNT9:Length() > 1)
						oModelNT9:LoadValue("NT9_PRINCI", IIF(lPrincipal,"2","1"))	//1=Sim
					else
						oModelNT9:LoadValue("NT9_PRINCI", "1")//1=Sim
					EndIf
				EndIf
			EndIf
		EndIf
	
	Else
		lRetorno := .F.
		cErro 	 := I18n(STR0085, {oModelNZZ1:GetValue("NZZ_COD")} )	//"Distribuição #1 sem Réu preenchido!"
		oModelNSZ:SetErrorMessage( /*cIdForm*/, /*cIdField*/, /*cIdFormErr*/, /*cIdFieldErr*/, /*cId*/,;
					   				cErro	  , /*cSolucao*/, /*xValue*/	, /*xOldValue*/	 )
	EndIf

	RestArea( aArea )

Return oModelNSZ

//-------------------------------------------------------------------
/*/{Protheus.doc} CarPartCon
Carrega parte contraria nos envolvidos 

@param  oModelNZZ1 - Modelo com os dados da distribuição que esta selecionada
@param  oModelNSZ  - Modelo da JURA095 que sera gravado
@param  lRetorno   - Inidica se as atualização foram feitas corretamente
@return oModelNSZ  - Modelo da JURA095 atualizado com os dados da distribuição
@author Rafael Tenorio da Costa
@since 	08/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarPartCon( oModelNZZ1, oModelNSZ, lRetorno, cCampo, cTipoInt, aBusNQA, lReuSemCli )

	Local aArea      := GetArea()
	Local cQuery     := ""
	Local cAutor     := oModelNZZ1:GetValue(cCampo)
	Local cNome      := "" 
	Local oModelNT9  := oModelNSZ:GetModel("NT9DETAIL")
	Local aRetorno   := {}
	Local nCont      := 0
	Local nQtdLinhas := 0
	Local cTipoEnv   := ""
	Local nLinhaAtu  := oModelNT9:nLine
	Local aAuxBaVe   := {} 
	Local lEnvEnt    := ( SuperGetMV('MV_JENVENT',, '2') == "1" ) //Envolvido pela entidade
	Local lAchou     := .F.
	Local aChave     := {}	
	Local lPrincipal := .F.
	Local cEntidade  := "SRA"

	Default lReuSemCli := .F.
	

	For nCont:=1 To oModelNT9:Length()
		If !oModelNT9:isEmpty(nCont) .And. !oModelNT9:IsDeleted(nCont)
			If (oModelNT9:GetValue("NT9_TIPOEN") == cTipoInt) .And. (oModelNT9:GetValue("NT9_PRINCI") == '1')
				lPrincipal = .T.
			Endif
		Endif
	Next nCont

	aAuxBaVe := StrToKarr( cAutor, "|") //Existe momentos que esta vindo este caractere no campo autor ou advogado

	If !Empty(cAutor) 
	
		//Busca Funcionário
		cQuery := " SELECT RA_MAT, RA_NOME" 
		cQuery += " FROM " + RetSqlName("SRA")
		cQuery += " WHERE RA_FILIAL = '" + xFilial("SRA") + "'"
		cQuery += 	" AND ( "
		
		//Pega todas as partes contrarias
		For nCont:=1 To Len(aAuxBaVe)
			If !Empty(aAuxBaVe[nCont])
				//Limpa conteudo do campo
				cAutor := AllTrim( StrTran( Lower( JurLmpCpo(aAuxBaVe[nCont]) ), "#", " ") )
				cAutor := SubStr( cAutor, 1, TamSx3("RA_NOME")[1] )				
	
				cQuery += JurFormat("RA_NOME", .T./*lAcentua*/, .T./*lPontua*/) + " LIKE '%" + cAutor + "%' OR "			
			EndIf	 
		Next nCont
		
		cQuery := 	SubStr(cQuery, 1, Len(cQuery)-3)	//Tira ultimo OR
		cQuery += 	" ) "
		cQuery += 	" AND D_E_L_E_T_ = ' '"
		
		aRetorno := JurSQL(cQuery, {"RA_MAT", "RA_NOME"})
	
		If Len(aRetorno) == 0 //Busca parte contraria

			cEntidade := "NZ2"

			cQuery := " SELECT NZ2_COD, NZ2_NOME" 
			cQuery += " FROM " + RetSqlName("NZ2")
			cQuery += " WHERE NZ2_FILIAL = '" + xFilial("NZ2") + "'"
			cQuery += 	" AND ( "
			
			//Pega todas as partes contrarias
			For nCont:=1 To Len(aAuxBaVe)
				If !Empty(aAuxBaVe[nCont])
					//Limpa conteudo do campo
					cAutor := AllTrim( StrTran( Lower( JurLmpCpo(aAuxBaVe[nCont]) ), "#", " ") )
					cAutor := SubStr( cAutor, 1, TamSx3("NZ2_NOME")[1] )				
		
					cQuery += JurFormat("NZ2_NOME", .T./*lAcentua*/, .T./*lPontua*/) + " LIKE '%" + cAutor + "%' OR "			
				EndIf	 
			Next nCont
			
			cQuery := 	SubStr(cQuery, 1, Len(cQuery)-3)	//Tira ultimo OR
			cQuery += 	" ) "
			cQuery += 	" AND D_E_L_E_T_ = ' '"
			
			aRetorno := JurSQL(cQuery, {"NZ2_COD", "NZ2_NOME"})

		EndIf

		If Len(aRetorno) > 0
			cAutor := aRetorno[1][1]
			cNome  := AllTrim(aRetorno[1][2])
		Else
			cNome	:= SubStr( AllTrim(aAuxBaVe[1]), 1, TamSx3("NZ2_NOME")[1] )		//Cria cadastro com o primeiro nome
			
			If lEnvEnt
				//Incluir parte contraria
				cAutor := GravaNZ2( cNome )
			EndIf
		EndIf	
		
		//Verifica se encontrou a parte contraria
		If Empty(cAutor)
		
			lRetorno := .F.
		Else
		
			cAutor := AllTrim( cAutor )
			
			If lEnvEnt
				aChave := { {"NT9_ENTIDA", cEntidade}, {"NT9_TIPOEN", cTipoInt}, {"NT9_CODENT", cAutor} } 
			Else
				aChave := { {"NT9_ENTIDA", cEntidade}, {"NT9_TIPOEN", cTipoInt}, {"NT9_NOME", cNome} }
			EndIf
			
			//Verifica se a parte contraria ja esta no envolvido
			If oModelNT9:SeekLine( aChave )
			
				lAchou := .T.
				
				If lEnvEnt
					J105SetDados(cEntidade, cAutor)
					lRetorno := oModelNT9:SetValue('NT9_CODENT', cAutor)
				Else
					lRetorno := oModelNT9:SetValue('NT9_NOME', cNome)				
				EndIf
			EndIf
				
			//Inclui parte contraria nos envolvidos
			If !lAchou
						
				//Adiciona nova linha
				nQtdLinhas := oModelNT9:Length()
				If oModelNT9:AddLine() < nQtdLinhas
					lRetorno := .F.
				Else
	
					//Busca tipo de envolvido
					cTipoEnv := J219GetNQA( aBusNQA, cTipoInt )
					
					//Inclui envolvido da parte contraria
					aRetorno := {}
					
					//Envolvido pela Entidade
					If lEnvEnt
						Aadd(aRetorno, {"NT9_ENTIDA", cEntidade })
						Aadd(aRetorno, {'NT9_CODENT', cAutor    })
						
						J105SetDados(cEntidade, cAutor)
						
					Else
						Aadd(aRetorno, {"NT9_TIPOCL", "2"	})	//2=Não
						Aadd(aRetorno, {'NT9_TFORNE', "2"	})	//2=Não
						Aadd(aRetorno, {'NT9_NOME'	, cNome	})
						Aadd(aRetorno, {'NT9_TIPOP'	, "1"	})	//1=Fisica
					EndIf
						
					Aadd(aRetorno, {'NT9_PRINCI', "1"      })	//1=Sim
					Aadd(aRetorno, {"NT9_TIPOEN", cTipoInt })	//1=Polo Ativo	ou 3=Terceiro Interessado
					Aadd(aRetorno, {"NT9_CTPENV", cTipoEnv })
		
					For nCont:=1 To Len(aRetorno)
					
						If !( oModelNT9:SetValue(aRetorno[nCont][1], aRetorno[nCont][2]) )
							lRetorno := .F.
							Exit
						EndIf
					Next nCont
					
				EndIf
			Endif
			
			If lPrincipal .Or. lReuSemCli
				oModelNT9:LoadValue("NT9_PRINCI", "2")	//1=Sim
			EndIf
			
			//Valida linha
			If lRetorno
				lRetorno := oModelNT9:VldLineData()
			EndIf							
					
			//Volta para linha atual
			oModelNT9:GoLine(nLinhaAtu)
		EndIf
	EndIf	

	RestArea( aArea )

Return oModelNSZ

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaNZ2
Incluir envolvido na NZ2 - parte contrarias. 

@param  cDescricao - Nome do envolvido que sera incluido
@return cCodigo	   - Codigo do envolvido gerado
@author Rafael Tenorio da Costa
@since 	07/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaNZ2( cDescricao )

	Local oSaveModel := FWModelActive()			// Alterado apôs analise em conjunto com o Ernani Forastieri. 
	Local oModelNZ2  := Nil
	Local lRetorno   := .F.
	Local cCodigo    := ""
	
	oModelNZ2 := FWLoadModel( 'JURA184' )
	oModelNZ2:SetOperation( 3 )
	oModelNZ2:Activate()
	
	If ( lRetorno := oModelNZ2:SetValue('NZ2MASTER', 'NZ2_NOME', AllTrim(cDescricao)) )
	 
		If ( lRetorno := oModelNZ2:SetValue('NZ2MASTER', 'NZ2_TIPOP', '1') )	//1=Fisica
		
			If ( lRetorno := oModelNZ2:SetValue('NZ2MASTER', 'NZ2_CGC', "00000000000") )	//Cpf
			
				If ( lRetorno := oModelNZ2:VldData() )
					lRetorno := oModelNZ2:CommitData()	
				EndIf
			EndIf
		EndIf
	EndIf		 
	
	If lRetorno
		cCodigo := oModelNZ2:GetValue("NZ2MASTER", "NZ2_COD")
	Else
		//JurShowErro( oModelNZ2:GetErrorMessage() )
		JurMsgErro(STR0065)		//"Não foi possível incluir o envolvido(parte contraria)."
	EndIf
	
	oModelNZ2:DeActivate()
	oModelNZ2:Destroy()
	
	FWModelActive(oSaveModel,.T.)

Return cCodigo

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaImp
Faz algumas pre-validações antes de fazer a importação das distribuições. 

@param  oView	 - View ativa
@param  oModel 	 - Modelo com os dados da tela
@return lRetorno - Inidica que a tela foi preechida corretamente
@author Rafael Tenorio da Costa
@since 	08/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidaImp(oView, oModel)

	Local lRetorno  := .F.
	Local oModelDet := oModel:GetModel("NZZDETAIL1")
	Local oModelNT9 := oModel:GetModel("NT9DETAIL")
	Local oModelNUQ := oModel:GetModel("NUQDETAIL")
	Local oModelNT4 := oModel:GetModel("NT4MASTER")
	Local oModelNTA := oModel:GetModel("NTAMASTER")
	Local nCont     := 0
	
	IncProc( STR0044 )	//"Validando informações da tela"
	
	//Verifica se foi selecionado algum registro na aba distribuições recebidas
	If !( lRetorno := oModelDet:SeekLine( {{"NZZ__TICK", .T.}} ) )

		JurMsgErro(STR0054)		//"Não foi selecionada nenhuma distribuição para importação."
		
		//Posiciona na aba de "Resumo"
		oView:SelectFolder("FOLDER", STR0017, 2)	//"Resumo"
		
		//Posiciona na aba de "Distribuições recebidas"
		oView:SelectFolder("FOLDER_F01_ABAS", STR0012, 2)	//"Distribuições recebidas"
	EndIf
	
	//Verifica se existe tipo de envolvimento para advogado
	If lRetorno
		oModelDet:Goline(1)
		For nCont:=1 To oModelDet:Length()
			If oModelDet:GetValue("NZZ__TICK", nCont) .And. !Empty( oModelDet:GetValue("NZZ_ADVOGA", nCont) )
				If Empty( J219GetNQA( {"advogado parte contraria"}, "3" ) )
					lRetorno := .F.
					JurMsgErro(STR0073)		//"Por favor, cadastre um Tipo de Envolvimento com descrição (ADVOGADO PARTE CONTRARIA), como terceiro interessado."
				EndIf
			EndIf
		Next nCont
	EndIf
	
	//Valida preenchimento dos envolvidos
	If lRetorno	
		If !oModelNT9:IsEmpty()
			For nCont:=1 To oModelNT9:Length()
				If !oModelNT9:IsDeleted(nCont)
					oModelNT9:GoLine(nCont)
					If !( lRetorno := oModelNT9:VldLineData() )
						JurMsgErro(STR0061) //"Preencha corretamente os envolvidos"
						Exit
					EndIf
				EndIf
			Next nCont
		EndIf
		
		//Valida se existe o tipo de envolvimento 'autor' ou 'reclamante' quando não existir NZ2 cadastrada nos envolvidos
		If lRetorno .And. !oModelNT9:SeekLine( { {"NT9_ENTIDA", "NZ2"} } ) .And. Empty( J219GetNQA( {"autor", "reclamante"}, "1" ) )
			lRetorno := .F.
			JurMsgErro(STR0060)		//"Por favor, cadastre um Tipo de Envolvimento com descrição (AUTOR ou RECLAMANTE), como polo ativo."
		EndIf
	EndIf
	
	//Valida preenchimento das instancias
	If lRetorno
		If oModelNUQ:IsEmpty() .Or. Empty(oModelNUQ:GetValue("NUQ_INSTAN")) .Or.  Empty(oModelNUQ:GetValue("NUQ_CNATUR"))
			lRetorno := .F.
			JurMsgErro(STR0030 + STR0055 ) //"Instâncias"	//" não preenchidos."
		EndIf
	EndIf
	
	//Valida preenchimento dos andamentos	
	If lRetorno
	
		For nCont:=1 To oModelNT4:Length()
			If !oModelNT4:IsDeleted(nCont)
				oModelNT4:GoLine(nCont)
				If !Empty(oModelNT4:GetValue("NT4_DESC")) .Or. !Empty(oModelNT4:GetValue("NT4_CATO"))
					If !oModelNT4:VldLineData()
						lRetorno := .F.
						JurMsgErro(STR0050 + STR0027)	//"Preencha a Aba "		//"Andamentos"
						Exit
					EndIf	
				EndIf
			EndIf
		Next nCont

	EndIf

	//Valida preenchimento dos follow-ups	
	If lRetorno
	
		For nCont:=1 To oModelNTA:Length()
			If !oModelNTA:IsDeleted(nCont)
				oModelNTA:GoLine(nCont)
				If !Empty(oModelNTA:GetValue("NTA_CTIPO")) .Or. !Empty(oModelNTA:GetValue("NTA_CRESUL")) .Or. !Empty(oModelNTA:GetValue("NTA_DESC")) .Or. !Empty(oModelNTA:GetValue("NTA__SIGLA"))
					If !oModelNTA:VldLineData()
						lRetorno := .F.
						JurMsgErro(STR0050 + STR0028)	//"Preencha a Aba "		//"Follow-ups"
						Exit
					EndIf	
				EndIf
			EndIf
		Next nCont
		
	EndIf

Return lRetorno

//------------------------------------------------------------------
/*/{Protheus.doc} ValPosNT9
Valida linha do grid NT9

@param 	oModeNT9 - Model da NT9
@param	nLinha 	 - Linha que esta sendo validada
@return lRetorno - .T./.F. 
@author Rafael Tenorio da Costa
@since 09/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VlLiPosNT9( oModelNT9, nLinha )
	
	Local lRetorno   := .T.
	Local cEntidade  := ""
	Local nCont      := 0	
	Local cTipoCl    := ""
	Local cTForne    := ""	
	Local aSaveLines := FWSaveRows()

	//Verifica se os envolvidos não estam utilizando a entidade
	If SuperGetMV('MV_JENVENT',, '2') == "2"
	
		//Tratamento necessario para o corregamento do cliente e partes contrarias da distribuição
		cTipoCl := oModelNT9:GetValue("NT9_TIPOCL") 
		cTForne := oModelNT9:GetValue("NT9_TFORNE")
		
		//Cliente
		If cTipoCl == "1" .And. (Empty(cTForne) .Or. cTForne == "2")  
			cEntidade := "SA1"
			
		//Parte contraria	
		ElseIf cTipoCl == "2" .And. (Empty(cTForne) .Or. cTForne == "2")
			cEntidade := "NZ2"
		EndIf
		
		oModelNT9:LoadValue("NT9_ENTIDA", cEntidade)
	EndIf

	FwRestRows(aSaveLines)
	
Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J219IncNQE
Incluir vara/camara na NQE. 

@param  cComarca   - Comarca que tera vara cadastrada
@param  cForo	   - Foro que tera vara cadastrada
@param  cDescricao - Descrição da vara que sera cadastrada
@return cCodigo	   - Codigo da vara cadastrada
@author Rafael Tenorio da Costa
@since 	16/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J219IncNQE( cComarca, cForo, cDescricao, lRetorno )

	Local aArea      := GetArea()
	Local aAreaNQ6   := NQ6->( GetArea() )
	Local aAreaNQC   := NQC->( GetArea() )
	Local oSaveModel := FWModelActive()			// Alterado apôs analise em conjunto com o Ernani Forastieri. 
	Local oJURA005   := Nil
	Local oModelNQE  := Nil
	Local cCodigo    := ""
	
	DbSelectArea("NQ6")
	NQ6->( DbSetOrder(1) )	//NQ6_FILIAL+NQ6_COD
	If NQ6->( DbSeek(xFilial("NQ6") + cComarca) )
	
		DbSelectArea("NQC")
		NQC->( DbSetOrder(1) )	//NQC_FILIAL+NQC_COD
		If NQC->( DbSeek(xFilial("NQC") + cForo) )

			oJURA005 := FWLoadModel( 'JURA005' )
			oJURA005:SetOperation( 4 )
			oJURA005:Activate()
			
			//Posiciona no foro do model
			If oJURA005:GetModel("NQC2NIVEL"):SeekLine( { {"NQC_COD", cForo} } )
			
				oModelNQE := oJURA005:GetModel("NQE3NIVEL")
				
				oModelNQE:AddLine()
				
				If ( lRetorno := oModelNQE:SetValue("NQE_DESC", cDescricao) )
				 
					If ( lRetorno := oJURA005:VldData() )
						cCodigo  := oModelNQE:GetValue("NQE_COD")
						lRetorno := oJURA005:CommitData()
					EndIf
				EndIf
				
				If !lRetorno
					//JurShowErro( oJURA005:GetErrorMessage() )
					JurMsgErro(STR0066)		//"Não foi possível incluir a vara."
				EndIf
			
			EndIf
			
			oJURA005:DeActivate()
			oJURA005:Destroy()
			
		EndIf
	EndIf
	
	RestArea( aAreaNQC )
	RestArea( aAreaNQ6 )
	RestArea( aArea )
	
	FWModelActive(oSaveModel,.T.)

Return cCodigo

//-------------------------------------------------------------------
/*/{Protheus.doc} AbrePro
Abre o JURA095 editando o processo que foi importado. 

@param  oFormulario - Objeto do Tipo FWFormGrid
@param  cFieldName  - Nome do campo do model
@param  nLineGrid   - Linha selecionada do Grid, pode não corresponder
					  a do modelo, caso o mesmo esteja filtrado
@param  nLineModel  - Linha Correspondente no Model

@return lRetorno	-
@author Rafael Tenorio da Costa
@since 	16/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AbrePro(oFormulario, cFieldName, nLineGrid, nLineModel)

	Local aArea      := GetArea()
	Local aAreaNSZ   := NSZ->( GetArea() )
	Local lRetorno   := .T.
	Local oModelNZZ2 := oFormulario:GetModel("NZZDETAIL2")
	
	DbSelectArea("NSZ")
	NSZ->( DbSetOrder(1) )	//NSZ_FILIAL+NSZ_COD
	If NSZ->( DbSeek(xFilial("NSZ") + oModelNZZ2:GetValue("NZZ_CAJURI") ))
		Processa( {|| AbreJura95( , 4)} )
	EndIf

	RestArea( aAreaNSZ )
	RestArea( aArea )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J219GetNQA
Retorna o tipo de envolvimento da parte contraria 

@param cCodigo 	- Codigo do tipo de envolvimento
@param cPolo	- Define o polo 1=Polo Ativo, 3=Terceiro Interessado 
@author Rafael Tenorio da Costa
@since 	16/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J219GetNQA( aBusca, cPolo )

	Local aArea     := GetArea()
	Local cCodigo   := ""
	Local cQuery    := ""
	Local aRetorno  := {}
	Local nCont     := 0
	
	For nCont:=1 To Len(aBusca)

		aRetorno := {}
		
		cQuery := " SELECT NQA_COD" 
		cQuery += " FROM " + RetSqlName("NQA")
		cQuery += " WHERE NQA_FILIAL = '" + xFilial( "NQA" ) + "'" 
		cQuery += 	" AND " + JurFormat("NQA_DESC", .T./*lAcentua*/, .T./*lPontua*/) + " LIKE '%" + aBusca[nCont] + "%'"
		
		If cPolo == "1"
			cQuery += 	" AND NQA_POLOAT = '1' "	//1=Polo Ativo = Sim
		ElseIf cPolo == "2"		
			cQuery += 	" AND NQA_POLOPA = '1' "	//2=Polo Passivo = Sim
		Else	
			cQuery += 	" AND NQA_TERCIN = '1' "	//1=Terceiro Interessado = Sim
		EndIf	
		
		cQuery += 	" AND D_E_L_E_T_ = ' ' "
		
		aRetorno := JurSQL(cQuery, {"NQA_COD"})
	
		If Len(aRetorno) > 0
			cCodigo := aRetorno[1][1]
			Exit
		EndIf	
	Next nCont		

	RestArea( aArea )

Return cCodigo

//-------------------------------------------------------------------
/*/{Protheus.doc} SelCliente
Rotina que apresenta tela para selecionar o cliente 

@param cCodigo - Codigo do tipo de envolvimento
@author Rafael Tenorio da Costa
@since 	16/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SelCliente(aClientes)

	Local oDlg          := Nil
	Local cTitulo       := STR0068	//"Selecine o Cliente"
	Local aCabecalho    := {STR0069, STR0070, STR0071}		//"Código"	//"Loja"	//"Nome"
	Local oCheck        := LoadBitmap( GetResources(), "CHECKED" )      // Legends : CHECKED  / LBOK  /LBTIK
	Local oNoCheck      := LoadBitmap( GetResources(), "UNCHECKED" )    // Legends : UNCHECKED /LBNO
	Local oFWLayer      := Nil
	Local oPnlAcima     := Nil
	Local oPnlAbaixo    := Nil
	Local nPosCli       := 1

	//Monta a tela para usuario visualizar consulta
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 6,6 TO 300,550 PIXEL

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg, .F., .F.)

	//Painel Superior
	oFWLayer:AddLine('ACIMA', 80, .F.)
	oFWLayer:AddCollumn('ALL', 100, .T., 'ACIMA')
	oPnlAcima := oFWLayer:GetColPanel( 'ALL', 'ACIMA' )

	// Painel Inferior
	oFWLayer:AddLine('ABAIXO', 20, .F. )
	oFWLayer:AddCollumn('ALL' , 100, .T., 'ABAIXO')
	oPnlAbaixo := oFWLayer:GetColPanel('ALL' , 'ABAIXO')

	//------------------------- Acima -------------------------------------------------------------------------------------------------
	oListBox1 := TwBrowse():New(005,003,Int(oPnlAcima:nWidth/2.05),Int(oPnlAcima:nHeight/2.1),,aCabecalho,,oPnlAcima,,,,,,,,,,,,.T.,,.T.,,.F.,,,)
	oListBox1:SetArray( aClientes )

	oListBox1:bLine := {|| {aClientes[oListBox1:nAt,1], aClientes[oListBox1:nAt,2], aClientes[oListBox1:nAt,3]}}

	//------------------------- Abaixo -----------------------------------------------------------------------------------------------------
	@ 005,189 Button STR0067 Size 037, 012 PIXEL OF oPnlAbaixo ACTION ( nPosCli := oListBox1:nAt, IIF(nPosCli > 0, oDlg:End(), ) )		//"Confirma"	

	ACTIVATE MSDIALOG oDlg CENTER
	
	oFWLayer:Destroy()
	FreeObj( oFWLayer )
	oFWLayer   := Nil
	oPnlAbaixo := Nil
	oListBox1  := Nil

Return nPosCli

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaNVE
Rotina que busca num caso para o cliente desde que exista.  

@param  oModelNSZ - O model da JURA095
@param  cNomeCli  - Nome do cliente da distribuicao 
@param  cNumCaso  - Numero do caso da tela
@author Rafael Tenorio da Costa
@since 	17/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BuscaNVE(oModelNSZ, cNomeCli, cNumCaso)

	Local aArea    := GetArea()
	Local lRetorno := .T.
	Local cQuery   := ""
	Local aRetorno := {}
	Local cCodCli  := ""
	Local cLojCli  := ""
	Local cErro    := ""
	
	//Verifica se o num caso esta vazio e não é cliente com geracao de caso automatico		
	If Empty( oModelNSZ:GetValue("NSZMASTER", "NSZ_NUMCAS") ) .And. JA095CAut()
	
		cCodCli	:= oModelNSZ:GetValue("NSZMASTER", "NSZ_CCLIEN")
		cLojCli	:= oModelNSZ:GetValue("NSZMASTER", "NSZ_LCLIEN")
	
		cQuery += " SELECT NVE_NUMCAS" 
		cQuery += " FROM " + RetSqlName("NVE")
		cQuery += " WHERE NVE_FILIAL = '" + xFilial( "NVE" ) + "'"
		cQuery +=   " AND NVE_NUMCAS = '" + cNumCaso + "'" 
		cQuery += 	" AND NVE_CCLIEN = '" + cCodCli + "'"
		cQuery += 	" AND NVE_LCLIEN = '" + cLojCli + "'"
		cQuery += 	" AND NVE_SITUAC = '1'"		//1=Andamento
		cQuery += 	" AND D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY NVE_NUMCAS"  
		
		aRetorno := JurSQL(cQuery, {"NVE_NUMCAS"})
	
		If Len(aRetorno) > 0
			lRetorno := oModelNSZ:SetValue("NSZMASTER", "NSZ_NUMCAS", aRetorno[1][1])
		Else
			lRetorno := .F.
			cErro	 := I18n(STR0072, {cNomeCli})	//"Número do Caso inválido, para o cliente #1" 
			oModelNSZ:SetErrorMessage( /*cIdForm*/, /*cIdField*/, /*cIdFormErr*/, /*cIdFieldErr*/, /*cId*/,;
			 						   cErro	  , /*cSolucao*/, /*xValue*/	, /*xOldValue*/	 )
		EndIf
	EndIf
	
	RestArea( aArea )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} VldSigla()
Função para validar o campo virtual NTA__SIGLA  

@return	lRetorno - .T.\.F.
@author Rafael Tenorio da Costa
@since 	22/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldSigla()

	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local oModelNTA := oModel:GetModel("NTAMASTER")
	Local lRetorno  := .T.

	lRetorno := JurGetDados("RD0", 9, xFilial("RD0") + oModelNTA:GetValue("NTA__SIGLA"), "RD0_TPJUR") == "1"

	RestArea( aArea )
	
Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCarMod(oModel, cTipoAssun, cCodMod)
Função para incluir um processo com as informações do modelo selecionado,
função parecida com o metodo J162IncMod da classe TJurPesqAsj.
Uso Geral.

@Param 	oModel		- Modelo de dados do assunto juridico
@Param 	cTipoAssun	- Codigo do tipo de assunto juridico
@Param 	cCodMod		- Codigo do modelo que sera utilizado para carregar o processo 
@Return oModel		- Modelo com os campos ja carregados  
@author Rafael Tenorio da Costa
@since 	31/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcCarMod(oModel, cTipoAssun, cCodMod)

	Local aArea      := GetArea()
	Local aAreaNZ4   := NZ4->( GetArea() )
	Local dValor     := Nil
	Local oStructNXX := Nil
	Local lUpd       := .F.
	Local nI         := 0
	Local nJ         := 0
	Local aDetail    := {}
	
	Default cCodMod	:= ""
	
	//Caso não seja informado o codigo do modelo sera apresentada a tela para selecionar
	If Empty(cCodMod)
		cCodMod := SelModelo(cTipoAssun)
	EndIf
	
	If !Empty(cCodMod)
	
		DbSelectArea("NZ4")
		NZ4->(DbSetOrder(1))
		If NZ4->(dbSeek(xFilial('NZ4')+cCodMod))
			
			While NZ4->(!Eof()) .And. NZ4->NZ4_CMOD == cCodMod .And. NZ4->NZ4_FILIAL == xFilial('NZ4')
				dValor := Alltrim(NZ4->NZ4_VALORC)
				If NZ4->NZ4_TIPO == "D"
					dValor := CTOD(Alltrim(dValor))
				EndIf
				If NZ4->NZ4_TIPO == "N"
					dValor := Val(Alltrim(dValor))
				EndIf
				
				lGrid    := (AllTrim(NZ4->NZ4_NOMEMD) $ "NT9DETAIL/NUQDETAIL/NT4MASTER/NTAMASTER")
				
				If !lGrid
					oStructNXX := oModel:GetModel(AllTrim(NZ4->NZ4_NOMEMD)):GetStruct() 
					lUpd := oStructNXX:GetProperty(Alltrim(NZ4->NZ4_NOMEC), MODEL_FIELD_NOUPD)//Verifica os campos que não podem ser editados
		
					If !lUpd
						oModel:SetValue(AllTrim(NZ4->NZ4_NOMEMD),AllTrim(NZ4->NZ4_NOMEC), dValor)
					Endif
				
					NZ4->(dbSkip())
				
				Else
		
					cModelGrv 	:= NZ4->NZ4_NOMEMD
					cItem 		:= NZ4->NZ4_ITEM
					aAux		:= {}
					aDetail		:= {}			
		 			While NZ4->(!Eof()) .And. NZ4->NZ4_CMOD == cCodMod .And. NZ4->NZ4_FILIAL == xFilial('NZ4') .And. AllTrim(NZ4->NZ4_NOMEMD) == AllTrim(cModelGrv) 
						
						dValor := Alltrim(NZ4->NZ4_VALORC)
						If NZ4->NZ4_TIPO == "D"
							dValor := CTOD(Alltrim(dValor))
						EndIf
						If NZ4->NZ4_TIPO == "N"
							dValor := Val(Alltrim(dValor))
						EndIf
		
						If cItem == NZ4->NZ4_ITEM
							aAdd( aAux, { AllTrim(NZ4->NZ4_NOMEC), dValor } )
						Else
							aAdd(aDetail, aAux)
							aAux := {}
							cItem := NZ4->NZ4_ITEM
							aAdd( aAux, { AllTrim(NZ4->NZ4_NOMEC), dValor } )
						EndIf
						
						NZ4->(dbSkip())
					EndDo
					aAdd(aDetail, aAux)
					
					oStructNXX 	:= oModel:GetModel(AllTrim(cModelGrv)):GetStruct() 
					aAux	 	:= oStructNXX:GetFields()
		
					For nI := 1 To Len( aDetail )
				
						If oModel:GetModel(AllTrim(cModelGrv)):GetQtdLine() > 1 .Or. !( oModel:GetModel(AllTrim(cModelGrv)):IsEmpty(1) ) 	
							oModel:GetModel(AllTrim(cModelGrv)):AddLine()
						EndIf
		
						For nJ := 1 To Len( aDetail[nI] )
		
							lUpd := oStructNXX:GetProperty(Alltrim(aDetail[nI][nJ][1]), MODEL_FIELD_NOUPD)//Verifica os campos que não podem ser editados
		
							If !lUpd
								oModel:SetValue(AllTrim(cModelGrv),aDetail[nI][nJ][1], aDetail[nI][nJ][2])
							Endif
						Next nJ
				
					Next nI
		
				EndIf
		
			EndDo
			
			//Carrega codigo do modelo
			oModel:SetValue("NSZMASTER", "NSZ__CMOD", cCodMod)
		EndIf
	EndIf
	
	RestArea(aArea)
	RestArea(aAreaNZ4)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} SelModelo(cTipoAssun)
Função utilizada para apresentar os modelos para inclusão de processos, 
dependendo do assunto juridico.
Mesma função do metodo SelModel da TJurPesqAsj
Uso J219CarMod.

@param 	cTipoAj - Tipo de assunto juridico selecionado pelo usuario (entre os que ele esta autorizado a utilizar).
@author Rafael Tenorio da Costa
@since 	31/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SelModelo(cTipoAssun)

	Local aArea      := GetArea()
	Local cIdBrowse  := ""
	Local cIdRodape  := ""
	Local cModelo    := ""
	Local oBrowse    := Nil
	Local oDlgTpAS   := Nil 
	Local oTela      := Nil
	Local oPnlBrw    := Nil
	Local oPnlRoda   := Nil
	Local oBtnOk     := Nil
	Local oBtnCancel := Nil
	
	Define MsDialog oDlgTpAS FROM 0, 0 To 400, 800 Title STR0074 Pixel style DS_MODALFRAME		//"Selecione o Modelo
	
	oTela     := FWFormContainer():New( oDlgTpAS )
	cIdBrowse := oTela:CreateHorizontalBox( 84 )
	cIdRodape := oTela:CreateHorizontalBox( 16 )
	oTela:Activate( oDlgTpAS, .F. )
	oPnlBrw   := oTela:GeTPanel( cIdBrowse )
	oPnlRoda  := oTela:GeTPanel( cIdRodape )
	
	//-------------------------------------------------------------------
	// Define o Browse
	//-------------------------------------------------------------------
	oBrowse := FWMBrowse():New()
	oBrowse:SetOwner( oPnlBrw )
	oBrowse:SetMenuDef( '' )
	oBrowse:ForceQuitButton() 
	oBrowse:SetAlias("NZ3")
	oBrowse:SetDescription('') 		//"Selecione o modelo
		
	//Adiciona um filtro ao browse
	oBrowse:SetFilterDefault( "NZ3_TIPOAS = '"+cTipoAssun+"' .AND. NZ3_TIPO = '2'"	)
	
	//Seta o duplo clique 
	oBrowse:SetDoubleClick( {||cModelo := AllTrim(NZ3->NZ3_COD),oDlgTpAS:End()} )
	
	//Desliga a exibição dos detalhes
	oBrowse:DisableDetails()
	oBrowse:Activate()
	
	//Botão Ok
	@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 16 Button oBtnOk  Prompt STR0067;		//"Confirma"
	Size 30 , 12 Of oPnlRoda Pixel Action ( cModelo := AllTrim(NZ3->NZ3_COD), oDlgTpAS:End())
	
	//Botão Cancelar
	@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 68 Button oBtnCancel Prompt STR0039;		//"Cancelar"
	Size 30 , 12 Of oPnlRoda Pixel Action ( cModelo := "", oDlgTpAS:End() )
	
	//Botão Excluir
	@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 120 Button oBtnCancel Prompt STR0023;	//"Excluir"
	Size 30 , 12 Of oPnlRoda Pixel Action ( cModelo := AllTrim(NZ3->NZ3_COD), IIF( ExcModelo(cModelo), oDlgTpAS:End(), ) )
	
	//-------------------------------------------------------------------
	// Ativação do janela
	//-------------------------------------------------------------------
	Activate MsDialog oDlgTpAS Centered
	
	RestArea(aArea)

Return cModelo

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaModelo
Cria um modelo com os dados do processo, andamento e follow-up

@param  oView - View de dados
@author Rafael Tenorio da Costa
@since  24/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaModelo(oView)

	Local aArea     := GetArea()
	Local oModel    := FwModelActive()
	Local aModelos  := {}

	ProcRegua(0)
	
	//Carrega models que irão gerar o modelo
					//Modelo	, Grid
	Aadd(aModelos, {"NSZMASTER"	, .F.})
	Aadd(aModelos, {"NT9DETAIL"	, .T.})
	Aadd(aModelos, {"NUQDETAIL"	, .T.})
	Aadd(aModelos, {"NT4MASTER"	, .T.})
	Aadd(aModelos, {"NTAMASTER"	, .T.})
	
	//Cria modelo com os dados da tela
	IncProc(STR0037 + STR0033)		//"Carregando..."		//"Criar Modelo"
	J095SvMod(oModel, aModelos, "2")

	FWModelActive(oModel, .T.)

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcModelo(cCodMod)
Função para excluir um modelo, função parecida com o metodo J162ExcMod.

@param	cCodMod  Codigo do modelo para inclusão de 
@author Rafael Tenorio da Costa
@since  24/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ExcModelo(cCodMod)

	Local aArea    := GetArea()
	Local aAreaNZ3 := NZ3->( GetArea() )
	Local aAreaNZ4 := NZ4->( GetArea() )
	Local lExcluiu := .F.

	If !Empty( cCodMod )
	
		If MsgYesNo(STR0075, STR0076)	//"Tem certeza que deseja excluir o modelo ?"	//"Exclusão de modelo"
	
			DbSelectArea("NZ3")
			NZ3->(DbSetOrder(1))
			If NZ3->(dbSeek(xFilial('NZ3')+cCodMod))
				Reclock( "NZ3", .F. )
				NZ3->( dbDelete() )
				MsUnLock()
			EndIf
			
			DbSelectArea("NZ4")
			NZ4->(DbSetOrder(1))
			If NZ4->(dbSeek(xFilial("NZ4")+cCodMod))
				While NZ4->(!Eof()) .And. NZ4->NZ4_CMOD == cCodMod .And. NZ4->NZ4_FILIAL == xFilial("NZ4")
					Reclock( "NZ4", .F. )
					NZ4->( dbDelete() )
					NZ4->( MsUnLock() )
					NZ4->( DbSkip() )
				End
			EndIf
			
			lExcluiu := .T.
			MsgInfo(STR0077)	//"Modelo excluído"
		EndIf
	EndIf
	
	RestArea(aAreaNZ4)
	RestArea(aAreaNZ3)
	RestArea(aArea)

Return lExcluiu

//-------------------------------------------------------------------
/*/{Protheus.doc} PalavraChv
Função que chama a JURA182 - Palavra Chave

@author Rafael Tenorio da Costa
@since 13/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PalavraChv(oView)
	
	Local aArea    := GetArea()
	Local aAreaNZZ := NZZ->( GetArea() )
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()
	Local oModel   := FwModelActive()

	// JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA182' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA182

	JURA182()

	SetFunName( cFunName )
	AcBrowse := cAceAnt

	FwModelActive(oModel, .T.)

	RestArea( aAreaNZZ )
	RestArea( aArea ) 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CallFill95
Função principal para abrir a JURA095 com os dados de cada distribuição selecionada

Uso Geral

@Return nil
@author Willian Kazahaya
@since 22/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CallFill95(oView)
Local oModel    := FwModelActive()
Local oModelDet := oModel:GetModel("NZZDETAIL1")
Local aArea     := GetArea()
Local aAreaNZZ  := NZZ->( GetArea() )
Local cNszCod   := ""
Local lContProc := .T.
Local nI        := 0
Local cErrosArq := ""
Local cData     := ""
Local cTexto    := ""
Local cHora     := ""

	ProcRegua(0) 
	For nI := 1 To oModelDet:Length()
		If oModelDet:GetValue("NZZ__TICK", nI)

			// Caso o processo a ser incluido anteriormente foi cancelado, verifica se ainda irá incluir os novos processos 
			If !lContProc
				lContProc := (MsgYesNo(STR0080,STR0081))
			EndIf
			
			If (lContProc) 
				oModelDet:GoLine(nI)
				
				//Chama a criação do modelo dando as sugestões conforme o que esta na distribuição
				cNszCod := SugInfoProc(oModelDet)

				If !Empty( cNszCod )

					If oModelDet:HasField("NZZ_DTAUDI") .and. !Empty(oModelDet:GetValue("NZZ_DTAUDI", nI))//Verifica se a data de audiencia esta preenchida
						cData  := DtoS(oModelDet:GetValue("NZZ_DTAUDI", nI))
						cTexto := oModelDet:GetValue("NZZ_OCORRE", nI)

						If oModelDet:HasField("NZZ_HRAUDI")
							cHora  := oModelDet:GetValue("NZZ_HRAUDI", nI)
						EndIf
					EndIf				

					// Gravação do Follow-up de Audiencia.
					If !Empty(cData)
						GravaFw(oModel, cNszCod, cData, cHora, cTexto, .T.)
					EndIf

					//Atualiza distribuição
					AtuDistri(oModelDet, "2", cNszCod)
					lContProc := .T.
					cCajuri   := cNszCod

					//Baixa os arquivos relacionados a Distribuição
					If oModelDet:HasField("NZZ_LINK") .And. !Empty( oModelDet:GetValue("NZZ_LINK") )
						cErrosArq += BaixaArqs( oModelDet:GetValue("NZZ_COD"), oModelDet:GetValue("NZZ_LINK") )
					EndIf
				Else
					lContProc := .F.
				EndIf
			Else
				oView:DeActivate(.T.)
				oView:Activate() 

				Exit
			EndIf
		Endif
	Next
	
	//Verifica se teve algum erro
	If !Empty(cErrosArq)
		cErrosArq := STR0094 + CRLF + CRLF + cErrosArq	//"Os arquivos aqui listados não foram baixados, verifique!"
		JurErrLog(cErrosArq, STR0095)					//"Arquivos não baixados"
	EndIf

	oView:DeActivate(.T.)
	oView:Activate() 
	
	FWModelActive(oModel,.T.)
	
	RestArea( aAreaNZZ )
	RestArea( aArea )
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SugInfoProc(oModelDet)
Função que irá chamar a JURA095 com os dados da Distribuição já sugeridos

Uso Geral

@Param oModelDet = Grid do modelo atual 
@Return cNszCod  = Codigo do processo criado

@author Willian Kazahaya
@since 22/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SugInfoProc(oModelDet)

	Local oModelNew  := FWLoadModel('JURA095')
	Local xConteudo 
	Local cNumCaso   := ""
	Local cNszCod    := ""
	Local cCobjet    := ''
	Local cCareaj    := ''
	Local cTpAss     := ''
	Local bCloseOnOk := {|oModelNew| cNszCod:=oModelNew:GetValue("NSZMASTER","NSZ_COD"), .T.}
	Local bOk        := {|oModelNew| IIF(J219VlImMa(oModelNew),(cNszCod:=oModelNew:GetValue("NSZMASTER","NSZ_COD"), cCobjet:= oModelNew:GetValue("NSZMASTER","NSZ_COBJET"), cCareaj:= oModelNew:GetValue("NSZMASTER","NSZ_CAREAJ"), cTpAss:= oModelNew:GetValue("NSZMASTER","NSZ_TIPOAS"), .T.), .F.) }
	Local lReturn    := .F.
	Local nRet       := 1
	Local oStructNUQ := oModelNew:GetModel("NUQDETAIL"):GetStruct()
	Local cDetCaso   := oModelDet:GetValue("NZZ_OCORRE") 
	Local cData      := ''
	Local lReuSemCli := .F.
	Local lAutor     := .F.


	If oModelDet:HasField("NZZ_DTAUDI")
		cData := DtoS( oModelDet:GetValue("NZZ_DTAUDI") )
	EndIf

	//Tira a obrigatoriedade do campo
	oStructNUQ:SetProperty("NUQ_CNATUR", MODEL_FIELD_OBRIGAT, .F.)
	oStructNUQ:SetProperty("NUQ_CTIPAC", MODEL_FIELD_OBRIGAT, .F.)
		
	// Processo de inclusão
	oModelNew:SetOperation(MODEL_OPERATION_INSERT)
	
	// Ativação do fonte
	oModelNew:Activate()
	
	lReturn := oModelNew:SetValue("NSZMASTER", "NSZ_TIPOAS", cTipoAsJ)

	//Carrega cliente e envolvido
	oModelNew := CarCliente( oModelDet, oModelNew, cNumCaso, @lReturn, @lReuSemCli, @lAutor )
	
	//Carrega parte contraria envolvido polo ativo
	If !lAutor
		oModelNew := CarPartCon( oModelDet, oModelNew, @lReturn, "NZZ_AUTOR", "1", {"autor", "reclamante"} )
	EndIf

	//Carrega parte contraria envolvido polo Passivo
	If lReuSemCli
		oModelNew := CarPartCon( oModelDet, oModelNew, @lReturn, "NZZ_REU", "2", {"reu", "reclamada"}, lReuSemCli )
	EndIf
	//Carrega parte contraria envolvido terceiro interessado
	oModelNew := CarPartCon( oModelDet, oModelNew, @lReturn, "NZZ_ADVOGA", "3", {"advogado parte contraria"} )

	//Carrega campos essenciais para a instância
	oModelNew:GetModel("NUQDETAIL"):SetValue("NUQ_INSATU", "1")	//1=Sim
	oModelNew:GetModel("NUQDETAIL"):SetValue("NUQ_INSTAN", "1")	//1=1ª Instância

	//Carrega numero do processo
	//Tira pontos e traços
	xConteudo := oModelDet:GetValue("NZZ_NUMPRO")
	xConteudo := StrTran(xConteudo, "-", "")
	xConteudo := StrTran(xConteudo, ".", "")
	If !Empty( xConteudo )
		lReturn := oModelNew:GetModel("NUQDETAIL"):SetValue("NUQ_NUMPRO", xConteudo)
	EndIf
	
	//Carrega comarca
    oModelNew := CarComarca(oModelDet, oModelNew, @lReturn)	
	
	//Carrega valor
	If oModelDet:GetValue("NZZ_VALOR") > 0
		lReturn := oModelNew:SetValue("NSZMASTER", "NSZ_VLCAUS", oModelDet:GetValue("NZZ_VALOR"))
	EndIf

	//Carrega detalhe	
	If !Empty( cDetCaso )
		lReturn := oModelNew:SetValue("NSZMASTER", "NSZ_DETALH", cDetCaso)
	EndIf

	nRet := FWExecView( STR0021/*cTitulo*/, "JURA095"/*cPrograma*/, MODEL_OPERATION_INSERT,  /*oDlg*/, bCloseOnOk, bOk, /*nPercReducao*/, /*aEnableButtons*/, {|| .T.}/*bCancel*/, /*cOperatId*/,  /*cToolBar*/, oModelNew/*oModelAct*/)	//"Incluir"
	
	oModelNew:Deactivate()
	oModelNew:Destroy()
	oModelNew := Nil
		
	If nRet == 1
		cNszCod := ""
	Else
		If !Empty(cData)
			aErro := JAINCFWAUT('3',cNszCod,cCobjet,cCareaj,cTpAss)
			If Len(aErro) > 1
				JurMsgErro(STR0099, aErro[6])
				lRet := .F.
			EndIf
		EndIf
	Endif
			                                   
Return cNszCod

//-------------------------------------------------------------------
/*/{Protheus.doc} J219CliNt9()
Atualiza cliente no envolvido

@return  lRet
@since   04/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J219CliNt9()

Local lRet      := .T.
Local oModel    := FWModelActive()
Local oModelNT9 := oModel:GetModel("NT9DETAIL")
Local nI        := 0
Local cTipoEnv  := ""
Local lEnvEnt	:= SuperGetMV('MV_JENVENT',, '2') == "1"
  
//Verifica se não é a rotina que carrega o modelo
If oModelNT9 <> Nil .And. !IsInCallStack("CarregaMod")

	//Verifica se encontra o cliente
	lAchou := ( lEnvEnt .And. oModelNT9:SeekLine({{"NT9_ENTIDA", "SA1"}}) ) .Or. ( !lEnvEnt .And. oModelNT9:SeekLine({{"NT9_TIPOCL", "1"}}) ) 
	
	//Adiciona linha nos envolvidos
	If !lAchou
		oModelNT9:AddLine()
	EndIf
	
	//Atualiza cliente nos envolvidos
	If lEnvEnt 
		J105SetDados("SA1", FwFldGet("NSZ_CCLIEN") + FwFldGet("NSZ_LCLIEN"))
		
		oModelNT9:SetValue("NT9_ENTIDA", "SA1")
		oModelNT9:SetValue("NT9_CODENT", FwFldGet("NSZ_CCLIEN") + FwFldGet("NSZ_LCLIEN"))
	Else
		oModelNT9:SetValue("NT9_TIPOCL", "1")	//Cliente
	EndIf	
		
	oModelNT9:SetValue("NT9_TIPOEN" , "2")	//Polo Passivo		
		
	cTipoEnv := J219GetNQA( {"reu"}, oModelNT9:GetValue("NT9_TIPOEN"))
	If !Empty(cTipoEnv)
		oModelNT9:SetValue("NT9_CTPENV", cTipoEnv)	//Polo Ativo
	EndIf	

	oModelNT9:SetValue("NT9_CEMPCL", FwFldGet("NSZ_CCLIEN"))
	oModelNT9:SetValue("NT9_LOJACL", FwFldGet("NSZ_LCLIEN"))
	oModelNT9:LoadValue("NT9_NOME" , AllTrim(SA1->A1_NOME) )	//Força a atualização do nome, que não estava sendo atualizado em alguns momentos
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J219VlImMa()
Validação da importação manual

@return  lRetorno - Validação Ok
@since   04/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J219VlImMa(oModelNew)

	Local lRetorno  := .T.
	Local oModelNUQ := oModelNew:GetModel("NUQDETAIL")
	
	If oModelNUQ:SeekLine( {{"NUQ_CNATUR", Space(TamSx3("NUQ_CNATUR")[1])}} ) .Or. oModelNUQ:SeekLine( {{"NUQ_CTIPAC", Space(TamSx3("NUQ_CTIPAC")[1])}} )
		lRetorno := .F.
		JurMsgErro( I18n(STR0086, {J95TitCpo("NUQ_CNATUR", cTipoAsJ), J95TitCpo("NUQ_CTIPAC", cTipoAsJ)}) )		//"Campos da Instância #1 ou #2 inválidos, verifique!"
	EndIf
	
Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} BaixarDocs
Baixa os documentos de uma distribuição ja importada

@author  Rafael Tenorio da Costa
@since 	 11/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BaixarDocs(oView)

	Local oModel	:= FwModelActive()
	Local oModelDet	:= Nil
	Local cDetail   := BuscaModel(oView:GetFolderActive("FOLDER_F01_ABAS", 2)[2])	
	Local cErrosArq := ""
	
	If cDetail == "NZZDETAIL2"

		ProcRegua(0)
		IncProc(STR0096)	//"Baixando arquivos "
		
		oModelDet := oModel:GetModel(cDetail)
		
		//Baixa os arquivos relacionados a Distribuição
		If oModelDet:HasField("NZZ_LINK") .And. !Empty( oModelDet:GetValue("NZZ_LINK") )
		
			cCajuri   := oModelDet:GetValue("NZZ_CAJURI")		
		
			cErrosArq := BaixaArqs(oModelDet:GetValue("NZZ_COD"), oModelDet:GetValue("NZZ_LINK"))
		EndIf		
		
		If !Empty(cErrosArq)
			cErrosArq := STR0094 + CRLF + CRLF + cErrosArq	//"Os arquivos aqui listados não foram baixados, verifique!"
			JurErrLog(cErrosArq, STR0095)					//"Arquivos não baixados"
		Endif

	Else
		Alert(STR0016)	//"Operação não permitida para distribuição nesta situação."
	Endif
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA219Export(oView)
Gera a exportação dos resultados das distribuições recebidas

@param oView

@author Beatriz Gomes
@since  13/03/2018
@version 1.0
/*/
//--------------------------------------------------------
Static Function JA219Export(oView)

	Local oExcel  	:= FWMSEXCEL():New()
	Local aCamps  	:= {}
	Local aDados  	:= {}
	Local nI,nX   	:= 0
	Local nTipo   	:= 0
	Local oDetail 	:= oView:getModel("NZZDETAIL1")
	Local cExtens 	:= STR0100 + " XLS | *.xls"		//"Arquivo"
	Local lHtml   	:= (GetRemoteType() == 5) 		//Valida se o ambiente é SmartClientHtml
	Local cArq    	:= ""
	Local cFunction	:= "CpyS2TW"
	Local cPathS	:= "\SPOOL\" 					//Caminho onde o arquivo será gerado no servidor 
	Local cNome     := "" 							//Nome do arquivo que o usuário escolheu	
	//Escolha o local para salvar o arquivo
	//Se for o html, não precisa escolher o arquivo
	If !lHtml
		cArq := cGetFile(cExtens, STR0087, , 'C:\', .F., nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE), .F.)	//"Salvar como"
	Else
		cArq := cPathS + JurTimeStamp(1) + "_" + STR0001 + "_" + RetCodUsr()	//"Distribuições"
	Endif
	
	If At(".xls",cArq) == 0
		cArq += ".xls"
	Endif

	//Gerando o arquivo
	oExcel:AddworkSheet(STR0012)		//"Distribuições recebidas"
	oExcel:AddTable (STR0012,STR0001)	//"Distribuições recebidas"	//"Distribuições"

	For nI := 1 To Len(oDetail:aHeader)
		If oDetail:aHeader[nI][8] <> 'L'
			If oDetail:aHeader[nI][8] == 'C'
				nTipo := 1
			ElseIf oDetail:aHeader[nI][8] == 'N'
				nTipo := 2
			Else
				nTipo := 4
			EndIf
			oExcel:AddColumn(STR0012,STR0001,oDetail:aHeader[nI][1],2,nTipo,.F.)
			aAdd(aCamps,{oDetail:aHeader[nI][1]/*Titulo*/,oDetail:aHeader[nI][2]/*Campo*/})
		EndIF
	Next nI

	For nX := 1 To Len(oDetail:aDataModel)
		For nI := 1 To Len(aCamps)
			aAdd(aDados,oDetail:GetValue(aCamps[nI][2],nX))
		Next nI
		oExcel:AddRow(STR0012,STR0001,aDados)	//"Distribuições recebidas"	//"Distribuições"
		aDados :={}
	Next nX
	
	oExcel:Activate()
	
	If oExcel:GetXMLFile(cArq)
		If !lHtml
		
			If ApMsgYesNo(I18n(STR0088,{cArq}))	//"Deseja abrir o arquivo #1 ?"
				If !File(cArq)
					ApMsgYesNo(I18n(STR0089,{cArq}))	//"O arquivo #1 não pode ser aberto "
				Else
					nRet := ShellExecute('open', cArq , '', "C:\", 1)
				EndIf
			EndIf
			
		ElseIf FindFunction(cFunction)
			//Executa o download no navegador do cliente
			nRet := CpyS2TW(cArq,.T.)
			If nRet == 0
				MsgAlert(STR0092 + cArq)	//"Arquivo gerado com sucesso, caminho: "
			Else
				JurMsgErro(STR0091)	//"Erro ao efetuar o download do arquivo"
			EndIf
		Endif
	Else
		JurMsgErro(STR0090)	//"Erro ao gerar arquivo"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AbrirDocs
Abre os arquivos relecionados no campo NZZ_LINK 

@author  Rafael Tenorio da Costa
@since 	 11/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AbrirDocs(oView)

	Local oModel	:= FwModelActive()
	Local cDetail   := BuscaModel(oView:GetFolderActive("FOLDER_F01_ABAS", 2)[2])
	Local cLinks	:= ""
	Local aArquivos := {}
	Local nQtdArqs  := 0
	Local nArq		:= 0
	
	If oModel:GetModel(cDetail):Length() > 0
	
		cLinks := oModel:GetModel(cDetail):GetValue("NZZ_LINK")
	
		If !Empty(cLinks)
		
			ProcRegua(0)
			
			aArquivos := StrTokArr( AllTrim(cLinks), "|")
			nQtdArqs  := Len(aArquivos)
	
			For nArq:=1 To nQtdArqs
				IncProc(STR0103)	//"Abrindo arquivos"
				ShellExecute("open", aArquivos[nArq], "", "", SW_SHOW)
			Next nArq
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BaixaArqs
Baixa os arquivos relacionados a Distribuição

@author  Rafael Tenorio da Costa
@since 	 07/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BaixaArqs(cCodDis, cLinks)

	Local cUser     := AllTrim( SuperGetMv("MV_JDISUSR", .T., "") )	//Usuário teste distribuicao	aeseletropaulo
	Local cPwd      := AllTrim( SuperGetMv("MV_JDISPWD", .T., "") ) //Senha teste:  jkl_&mx%v@2018	aeseletropaulo
	Local oRest     := Nil
	Local aHeader   := {}
	Local aArquivos := {}
	Local nArq      := 0
	Local nQtdArqs  := 0
	Local cPath     := ""
	Local cNomeArq  := ""
	Local cDownload := ""
	Local nHandle   := ""
	Local lErro     := .F.
	Local cErros    := ""
	Local cTemp     := MsDocPath() + "\distribuições\"
	
	if !Empty(cUser)
		aHeader   := {"Authorization: Basic " + Encode64(cUser + ":" + cPwd)}
	EndIf
	
	If !Empty(cLinks)

		aArquivos := StrTokArr( AllTrim(cLinks), "|")
		nQtdArqs  := Len(aArquivos)

		If nQtdArqs > 0
			//Não é necessario passar o host porque o SetPath tera o caminha absoluto
			oRest := FWRest():New("")
			ProcRegua(nQtdArqs)
		EndIf

		For nArq:=1 To nQtdArqs

			IncProc( I18n(STR0097, {cValToChar(nArq) + "/" + cValToChar(nQtdArqs), cCodDis}) )		//"Baixando arquivos #1 - Distribuição: #2"

			lErro	 := .F.
			cPath 	 := AllTrim( aArquivos[nArq] )
			cNomeArq := AllTrim( SubStr(cPath, Rat("/", cPath) + 1) )
			
			cPath    := substr(cpath, 1, Rat("/", cPath))
			cPath    += FWURIEncode(cNomeArq)
			
			//Verifica se já existe o arquivos
			If !J26aExiNum("NSZ", xFilial("NSZ"), cCajuri, cNomeArq)

				oRest:SetPath(cPath)
	
				If oRest:Get(aHeader)
	
					//Download do arquivo
					cDownload := oRest:GetResult()
	
					//Verifica se diretorio temporario existe
					If !JurMkDir(cTemp)
						lErro := .T.
					EndIf
	
					//Grava arquivo no servidor
					If !lErro .And. ( nHandle := FCreate(cTemp + cNomeArq, FC_NORMAL) ) < 0
						lErro := .T.
					EndIf
	
					If !lErro
						If FWrite(nHandle, cDownload) < Len(cDownload)
							lErro := .T.
						EndIf
	
						If !lErro .And. !FClose(nHandle)
							lErro := .T.
						EndIf
					EndIf
	
					If lErro
						cErros += " - " + J026aErrAr( FError() ) + " - " + cPath + CRLF
					Else
	
						//Anexa documento ao processo
						aRetAnx := J026Anexar("NSZ", xFilial("NSZ"), cCajuri, cCajuri, cTemp + cNomeArq)
	
						If aRetAnx[1]
							FErase(cTemp + cNomeArq)
						Else
							cErros += " - " + aRetAnx[2] + " - " + cPath + CRLF
						EndIf
					EndIf
	
				Else
	
				   cErros += " - " + oRest:GetLastError() + " - " + cPath + CRLF
				Endif
			
			EndIf

		Next nArq

		If !Empty(cErros)
			cErros := STR0098 + cCodDis + CRLF + cErros + CRLF		//"Distribuição: "
		EndIf
	EndIf

	FwFreeObj(oRest)

Return cErros

///-------------------------------------------------------------------
/*/{Protheus.doc} J20Marcar(oView, oBotao)
Menu da rotina para marcar todos os registros do Grid.

@Param  oView  Objeto da View
@Param  oBotao Objeto do AddUserButon

@Return Nil

@author Luciano Pereira dos Santos
@since 19/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J219Marcar(oView, oBotao)
Local oMenuAnexo  := Nil
Local oMenuItem   := {}
	
	oMenu := MenuBegin(,,,, .T.,,oBotao, )
	aAdd( oMenuItem, MenuAddItem( STR0104,,, .T.,,,, oMenuAnexo, {|| J219Mark(oView, '1') } ,,,,, {||.T.} )) // "Marcar Todos"
	aAdd( oMenuItem, MenuAddItem( STR0105,,, .T.,,,, oMenuAnexo, {|| J219Mark(oView, '2') } ,,,,, {||.T.} )) // "Desmarcar Todos"
	aAdd( oMenuItem, MenuAddItem( STR0106,,, .T.,,,, oMenuAnexo, {|| J219Mark(oView, '3') } ,,,,, {||.T.} )) // "Inverter Seleção"
	MenuEnd()
	
	oMenu:Activate( 10, 10, oBotao )

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} J219Mark(oView, cOpcao)
Rotina para marcar todos os registros do Grid.

@Param  oView  Objeto da View
@Param  cOpcao  '1'- Marca; '2'- Desmarca; '3'-Inverte

@Return lRet  .T. se conseguiu marcar os itens esperados

@author Luciano Pereira dos Santos
@since 19/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J219Mark(oView, cOpcao)
Local lRet      := .T.
Local lMarca    := .T.
Local oModel    := oView:GetModel()
Local oModelNZZ := Nil
Local cAba      := oView:GetFolderActive("FOLDER_F01_ABAS", 2)[2] //Descrição da aba
Local cModelId  := ""
Local nI        := 0
Local nNZZLine  := 0

Default cOpcao := "1"
	
	Do Case
		Case cAba == STR0012		//"Distribuições recebidas"
			cModelId := "NZZDETAIL1"
		Case cAba == STR0013		//"Distribuições excluídas"
			cModelId := "NZZDETAIL3"
	End Case
	
	If !Empty(cModelId)
		oModelNZZ := oModel:GetModel(cModelId)
		nNZZLine  := oModelNZZ:GetLine()
		If !oModelNZZ:IsEmpty()
			For nI := 1 to oModelNZZ:GetQtdLine()
				oModelNZZ:Goline(nI)
				If !oModelNZZ:IsDeleted(nNZZLine)
					If cOpcao == '1'
						lMarca := .T.
					ElseIf cOpcao == '2'
						lMarca := .F.
					ElseIf cOpcao == '3'
						lMarca := !oModelNZZ:GetValue("NZZ__TICK")
					EndIf
	
					If !(lRet := oModelNZZ:SetValue("NZZ__TICK", lMarca))
						Exit
					EndIf
				EndIf
			Next nI
			oModelNZZ:Goline(nNZZLine)
			oView:Refresh(cModelId)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J219SqlCli(cCampo, cQueryPad)
Rotina que retorna os clientes correspondentes ao nome pesquisado

@Param  cCampo  Clientes separados por pipe "|"
@Param  cQueryPad Query Padrão a ser retornada por referência

@Return array com os clientes encontrados

@author Ronaldo Gonçalves de Oliveira
@since 11/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J219SqlCli(cCampo, cQueryPad)

Local cQuery      := ""
Local nCont       := 0
Local aAuxBaVe    := StrToKarr( cCampo, "|")

Default cQueryPad := ""
Default cCampo    := ""

	//Busca cliente
		cQueryPad := " SELECT NUH_COD, NUH_LOJA, A1_NOME" 
		cQueryPad += " FROM " + RetSqlName("SA1") + " SA1"
		cQueryPad += " INNER JOIN " + RetSqlName("NUH") + " NUH"
		cQueryPad += " ON A1_FILIAL = NUH_FILIAL AND A1_COD = NUH_COD AND A1_LOJA = NUH_LOJA AND SA1.D_E_L_E_T_ = NUH.D_E_L_E_T_"
		cQueryPad += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
		cQueryPad += 	" AND SA1.D_E_L_E_T_ = ' '"
		
		cQuery := cQueryPad
		cQuery += 	" AND ( "
		
		//Pega todos os reus
		For nCont:=1 To Len(aAuxBaVe)
			If !Empty(aAuxBaVe[nCont])
				//Limpa conteudo do campo
				cCampo := AllTrim( StrTran( Lower( JurLmpCpo(aAuxBaVe[nCont]) ), "#", " ") )
				
				cQuery += JurFormat("A1_NOME"  , .T., .T., , ,.T.) + " LIKE '%" + cCampo + "%' OR "
				cQuery += JurFormat("A1_NREDUZ", .T., .T., , ,.T.) + " LIKE '%" + cCampo + "%' OR "
			EndIf	 
		Next nCont
		
		cQuery :=	SubStr(cQuery, 1, Len(cQuery)-3)	//Tira ultimo OR
	 	cQuery +=	" )" 
		
Return JurSQL(cQuery, {"NUH_COD", "NUH_LOJA", "A1_NOME"})

//-------------------------------------------------------------------
/*/{Protheus.doc} J219VLDPAR
Valida MV_PARXX

@param cMvPArXX - Parametro para verificação

@author  Ricardo Rampazzo e Lucivan Correia
@since   05/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J219VldPar(cMvPArXX)
Local lRet := .F.

	If Type(cMvPArXX) != "U"
		lRet := .T.
	EndIf

	If lRet
		If cValToChar(cMvPArXX) == 'MV_PAR05' //Define se o filtro de datas será feito pela data de recebimento ou pela data de distribuição. 1 - Recebimento, 2 - Distribuição
			lRet := CVALTOCHAR(MV_PAR05) == '2' 
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JDistReceb
Busca as informações das distribuições com status 1=Recebida

@since 	04/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JDistReceb( cNumProc )

Local aArea 	 := GetArea()
Local cAliasNZZ  := GetNextAlias()
Local cAliasCTO  := GetNextAlias()
Local cCodigoTpA := "" //-- Tipo de Ação
Local cDataDistr := "" //-- Data da Distribuição da Instância
Local cEscritor  := "" //-- Escritório
Local cMoeda     := ""
Local cQuery     := ""
Local cPK        := ""
Local aDadosForm := {}
Local aDadosCFV  := {}
Local aDadosCLI  := {}
Local aPAtivo    := {}
Local aPassivo   := {}
Local aTerceiro  := {}
Local aNT9       := {}

Default cNumProc := " "

	//Busca a moeda
	cQuery := "SELECT CTO_MOEDA FROM " + RetSqlName("CTO") 
	cQuery += " WHERE CTO_SIMB = 'R$' AND D_E_L_E_T_ = ' ' "  
	cQuery +=   " AND CTO_FILIAL = '" + xFilial("CTO") + "' "
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasCTO, .T., .F. )	

		If !(cAliasCTO)->(Eof())
			cMoeda := Alltrim((cAliasCTO)->CTO_MOEDA)
		EndIf

	(cAliasCTO)->(dbCloseArea())

	//-- Busca pela Distribuição a partir do numero do processo
	cQuery := " SELECT NZZ.* FROM " + RetSqlName("NZZ") + " NZZ "
	cQuery += " WHERE (NZZ_COD = '" + cNumProc + "' OR  NZZ_NUMPRO = '" + cNumProc + "')" 
	cQuery +=   " AND NZZ_FILIAL = '"+ xFilial("NZZ") + "' "
	cQuery +=   " AND NZZ.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasNZZ, .T., .F. )

		If !(cAliasNZZ)->(Eof())
			
			//-- Data da Distribuição da Instância
			cDataDistr := Alltrim((cAliasNZZ)->NZZ_DTDIST)

			//-- Numero do Processo
			cNumProc := (cAliasNZZ)->NZZ_NUMPRO
			cNumProc := StrTran(cNumProc, "-", "")
			cNumProc := StrTran(cNumProc, ".", "")

			cPK := (cAliasNZZ)->NZZ_FILIAL + (cAliasNZZ)->NZZ_COD

			//-- Comarca / Foro / Vara
			aDadosCFV := aClone(GetCFV({;
								cPK                     ,;
								(cAliasNZZ)->NZZ_NUMPRO ,;
								(cAliasNZZ)->NZZ_CIDADE ,;
								(cAliasNZZ)->NZZ_FORUM  ,;
								(cAliasNZZ)->NZZ_VARA   ,;
								(cAliasNZZ)->NZZ_ESTADO  ;
							}))

			//-- Tipo de Ação
			cCodigoTpA := JTipoAcao( Alltrim((cAliasNZZ)->NZZ_OCORRE) )
			
			//-- Escritório
			cEscritor := (cAliasNZZ)->NZZ_ESCRI

			//-- Busca Cliente e Envolvido
			aDadosCLI := aClone( JCliNZZ((cAliasNZZ)->NZZ_REU, (cAliasNZZ)->NZZ_AUTOR) )

			//Busca Parte contraria envolvido polo ativo
			aPAtivo := aClone( JSeekPartC((cAliasNZZ)->NZZ_AUTOR, "1", {"autor", "reclamante"}) )
			aAdd( aNT9, aClone(aPAtivo)   )
			aSize(aPAtivo, 0)

			//Carrega parte contraria envolvido polo Passivo
			aPassivo := aClone( JSeekPartC((cAliasNZZ)->NZZ_REU, "2", {"reu", "reclamada"}) )
			aAdd( aNT9, aClone(aPassivo)  )
			aSize(aPassivo, 0)

			//Carrega parte contraria envolvido terceiro interessado
			aTerceiro := aClone( JSeekPartC((cAliasNZZ)->NZZ_ADVOGA, "3", {"advogado parte contraria"}) )
			aAdd( aNT9, aClone(aTerceiro) )
			aSize(aTerceiro, 0)

			aAdd( aDadosForm, cEscritor    ) //-- Tipo de Ação
			aAdd( aDadosForm, cNumProc     ) //-- Numero do Processo
			aAdd( aDadosForm, cDataDistr   ) //-- Data da Distribuição
			
			If Len(aDadosCFV) > 0
				aAdd( aDadosForm, IIF( VALTYPE(aDadosCFV[1]) <> 'U', aDadosCFV[1], ""  ) ) //-- Comarca
				aAdd( aDadosForm, IIF( VALTYPE(aDadosCFV[2]) <> 'U', aDadosCFV[2], ""  ) ) //-- Foro
				aAdd( aDadosForm, IIF( VALTYPE(aDadosCFV[3]) <> 'U', aDadosCFV[3], ""  ) ) //-- Vara
				aAdd( aDadosForm, Encode64(ALLTRIM((cAliasNZZ)->NZZ_VARA ) ) )                       //-- Descrição da Vara
			Else
				aAdd( aDadosForm, ""  )
				aAdd( aDadosForm, ""  )
				aAdd( aDadosForm, ""  )
				aAdd( aDadosForm, ALLTRIM((cAliasNZZ)->NZZ_VARA )  )  
			EndIf
			
			If Len(aDadosCLI) > 0 
				aAdd( aDadosForm, IIF( VALTYPE(aDadosCLI[1]) <> 'U' , aDadosCLI[1], ""  ) )	//-- Dados Cliente - Codigo
				aAdd( aDadosForm, IIF( VALTYPE(aDadosCLI[2]) <> 'U', aDadosCLI[2], ""  ) )	//-- Dados Cliente - Loja
				aAdd( aDadosForm, IIF( VALTYPE(aDadosCLI[3]) <> 'U', aDadosCLI[3], ""  ) )	//-- Dados Cliente - Descrição

			Else
				aAdd( aDadosForm, ""  )
				aAdd( aDadosForm, ""  )
				aAdd( aDadosForm, ""  )
			EndIf
			
			aAdd( aDadosForm, aNT9         ) //-- Dados dos Envolvidos
			aAdd( aDadosForm, cCodigoTpA   ) //-- Codigo do Tipo de ação

			//-- Valor e data da Causa
			cVlrCausa := (cAliasNZZ)->NZZ_VALOR

			aAdd( aDadosForm, (cAliasNZZ)->NZZ_VALOR )               //-- Valor da causa
			aAdd( aDadosForm, cMoeda )                  //-- Moeda da causa
			aAdd( aDadosForm, (cAliasNZZ)->NZZ_DTAUDI ) // Data Audiência
			aAdd( aDadosForm, (cAliasNZZ)->NZZ_HRAUDI ) // Hora Audiência
			aAdd( aDadosForm, (cAliasNZZ)->NZZ_COD )    // código NZZ

		EndIf

	(cAliasNZZ)->(dbCloseArea())

	//-- Monta Json com as informações resgatadas.
	oResponse := J219json(aDadosForm)

	RestArea(aArea)

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} JTipoAcao( cTipoAcao )
Busca Tipo de Ação

@since 	04/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JTipoAcao( cTipoAcao )

Local aArea      := GetArea()
Local cQuery     := ""
Local cProcura   := ""
Local cCodTpAcao := ""
Local aRetorno   := {}
Local aAuxBaVe   := {}
Local nCont      := 0	
	
	If !Empty( cTipoAcao )	
		cTipoAcao := StrTran(cTipoAcao, "-", "|")
		cTipoAcao := StrTran(cTipoAcao, ",", "|")
		cTipoAcao := StrTran(cTipoAcao, "/", "|")
		aAuxBaVe  := StrToKarr(cTipoAcao, "|")		//Na maioria das vezes esta vindo este caractere no campo ocorrencia para separar a ocorrencia
		
		cQuery += " SELECT NQU_COD" 
		cQuery += " FROM " + RetSqlName("NQU")
		cQuery += " WHERE NQU_FILIAL = '" + xFilial( "NQU" ) + "'" 
		cQuery += 	" AND D_E_L_E_T_ = ' ' "
		cQuery += 	" AND ( "
		
		//Pega todas as ocorrencias
		For nCont:=1 To Len(aAuxBaVe)
			If !Empty(aAuxBaVe[nCont])
				//Limpa conteudo do campo
				cProcura := AllTrim( StrTran( Lower( JurLmpCpo(aAuxBaVe[nCont]) ), "#", " ") )
				
				cQuery += JurFormat("NQU_DESC", .T./*lAcentua*/, .T./*lPontua*/) + " LIKE '%" + cProcura + "%' OR "
			EndIf	 
		Next nCont
		
		//Tira ultimo OR
		cQuery := SubStr(cQuery, 1, Len(cQuery)-3)
	 	cQuery += " )" 
		
		aRetorno := JurSQL(cQuery, {"NQU_COD"})
		
		If Len(aRetorno) > 0 
			cCodTpAcao := aRetorno[1][1]
		Else
			cCodTpAcao := ""
		EndIf
	EndIf
	
	RestArea( aArea )

Return cCodTpAcao

//-------------------------------------------------------------------
/*/{Protheus.doc} JComForVar( cTipoAcao )
Busca Comarca, Foro e Vara

@param aDadosCFV  - Dados de Comarca / Foro / Vara
		 aDadosCFV[1] - Comarca - NZZ_CIDADE
		 aDadosCFV[2] - UF      - NZZ_ESTADO
		 aDadosCFV[3] - Foro    - NZZ_FORUM
		 aDadosCFV[4] - Vara    - NZZ_VARA
		 
@since 	04/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JComForVar( aDadosCFV )
Local aArea     := GetArea()
Local aReplace  := {}
Local aComFoVar := {}
Local aRetorno  := {}
Local cQuery    := ""
Local cComarca  := AllTrim(aDadosCFV[1])
Local cUF       := AllTrim(aDadosCFV[2])
Local cForum    := AllTrim(aDadosCFV[3])
Local cVara     := AllTrim(aDadosCFV[4])

	Aadd(aReplace, {"'°','o'", "'°',''"})
	Aadd(aReplace, {"'º','o'", "'º',''"})
	Aadd(aReplace, {"'ª','a'", "'ª',''"})
	
	//-- Busca Comarca
	If !Empty(cComarca)
		//-- Limpa conteudo do campo
		cComarca := StrTran( StrTran( StrTran(cComarca, '°','') ,'º',''), 'ª','')
		cComarca := AllTrim( StrTran( Lower( JurLmpCpo(cComarca) ), "#", " ") )
		cUF 	 := AllTrim( StrTran( Lower( JurLmpCpo(cUF) ), "#", " ") )
		
		cQuery := " SELECT NQ6_COD"	
		cQuery += " FROM " + RetSqlName("NQ6")
		cQuery += " WHERE NQ6_FILIAL = '" + xFilial("NQ6") + "'"
		cQuery += 	" AND " + JurFormat("NQ6_DESC", .T./*lAcentua*/, .T./*lPontua*/) + " LIKE '" + cComarca + "%'"
		cQuery += 	" AND " + JurFormat("NQ6_UF"  , .T./*lAcentua*/, .T./*lPontua*/) + " LIKE '" + cUF + "%'"
		cQuery += 	" AND D_E_L_E_T_ = ' ' "
	
		aRetorno := JurSQL(cQuery, "NQ6_COD", /*lCommit*/, aReplace)
		
		If Len(aRetorno) > 0 
			cComarca := AllTrim( aRetorno[1][1] )
		Else
			cComarca := ""
		EndIf
		
		aSize(aRetorno,0)
		cQuery := ""
	EndIf
	
	//-- Busca Foro - Procura forum com a descrição da Distribuição
	If !Empty(cForum)
		cForum := StrTran( StrTran( StrTran(cForum, '°','') ,'º',''), 'ª','')
		cForum := StrTran( Upper(cForum), "FORO", "")			//Retira a palavra foro por causa da integração CNJ
		cForum := AllTrim( StrTran( Lower( JurLmpCpo(cForum) ), "#", " ") )
		
		cQuery := " SELECT NQC_COD"
		cQuery += " FROM " + RetSqlName("NQC")
		cQuery += " WHERE NQC_FILIAL = '" + xFilial("NQC")+ "'" 
		cQuery += 	" AND NQC_CCOMAR = '" + cComarca + "'"
		cQuery += 	" AND " + JurFormat("NQC_DESC", .T./*lAcentua*/, .T./*lPontua*/) + " LIKE '%" + cForum + "%'"
		cQuery += 	" AND D_E_L_E_T_ = ' ' "
	
		aRetorno := JurSQL(cQuery, "NQC_COD", /*lCommit*/, aReplace)
		If Len(aRetorno) > 0 
			cForum := AllTrim( aRetorno[1][1] )
		Else
			cForum := ""
		EndIf
		aSize(aRetorno,0)
		cQuery := ""
	EndIf

	//-- Busca Vara
	If !Empty(cVara)
		cVara := StrTran( StrTran( StrTran(cVara, '°','') ,'º',''), 'ª','')
		cVara := AllTrim( StrTran( Lower( JurLmpCpo(cVara) ), "#", " ") )
		cVara := SubStr( AllTrim( cVara ), 1, TamSx3("NQE_DESC")[1] ) //Faz isso para pesquisar corretamente caso tenha incluído a vara pela importação de alguma outra distribuição
		
		cQuery := " SELECT NQE_COD"
		cQuery += " FROM " + RetSqlName("NQE")
		cQuery += " WHERE NQE_FILIAL = '" + xFilial("NQE") + "'"
		cQuery += 	" AND NQE_CLOC2N = '" + cForum + "'"
		cQuery += 	" AND " + JurFormat("NQE_DESC", .T./*lAcentua*/, .T./*lPontua*/) + " LIKE '%" + cVara + "%'"
		cQuery += 	" AND D_E_L_E_T_ = ' '"

		aRetorno := JurSQL(cQuery, "NQE_COD", /*lCommit*/, aReplace)
		cQuery := ""
		
		//-- Se não tem, cadastra a VARA
		If Len(aRetorno) > 0
			cVara := AllTrim( aRetorno[1][1] )
		Else
			If !Empty(aDadosCFV[4])
				cVara := J219IncNQE( cComarca, cForum, AllTrim(aDadosCFV[4]), .T. )
			EndIf
		EndIf
		
		If !Empty(cVara)
			cVara := AllTrim( cVara )
			aSize(aRetorno,0)
		Else
			cVara := ""
		EndIf
	
	EndIf

	aAdd(aComFoVar, cComarca )
	aAdd(aComFoVar, cForum   )
	aAdd(aComFoVar, cVara    )

	RestArea(aArea)

Return aComFoVar

//-------------------------------------------------------------------
/*/{Protheus.doc} JCliNZZ
Busca Cliente no processo e nos envolvidos 

@since 	08/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCliNZZ( cReu, cAutor )
Local aRetorno  := {}
Local aDadosNZZ := {}
Local nX        := 0

	aRetorno := JSeekCli(ALLTRIM(cReu))

	If Len(aRetorno) > 0

		For nX := 1 To Len(aRetorno)
			aAdd( aDadosNZZ, aRetorno[nX][1] )
			aAdd( aDadosNZZ, aRetorno[nX][2] )
			aAdd( aDadosNZZ, aRetorno[nX][3] )		
		Next

	EndIf

Return aDadosNZZ

//-------------------------------------------------------------------
/*/{Protheus.doc} JSeekCli(cDescCli)
Rotina que retorna os clientes de acordo com o nome pesquisado

@since 05/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JSeekCli( cDescCli )

Local cQuery      := ""
Local cQueryPad   := ""
Local nCont       := 0
Local aAuxBaVe    := StrToKarr( cDescCli, "|")

Default cDescCli    := ""

	//Busca cliente
		cQueryPad := " SELECT NUH_COD, NUH_LOJA, A1_NOME" 
		cQueryPad += " FROM " + RetSqlName("SA1") + " SA1"
		cQueryPad += " INNER JOIN " + RetSqlName("NUH") + " NUH"
		cQueryPad += " ON A1_COD = NUH_COD AND A1_LOJA = NUH_LOJA AND SA1.D_E_L_E_T_ = NUH.D_E_L_E_T_"
		cQueryPad += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
		cQueryPad += 	" AND SA1.D_E_L_E_T_ = ' '"
		
		cQuery := cQueryPad
		
		If !Empty(cDescCli)
			cQuery += 	" AND ( "
			
			//Pega todos os reus
			For nCont:=1 To Len(aAuxBaVe)
				If !Empty(aAuxBaVe[nCont])				
					//Limpa conteudo do campo
					cDescCli := AllTrim( StrTran( Lower( JurLmpCpo(aAuxBaVe[nCont]) ), "#", " ") )
					
					cQuery += JurFormat("A1_NOME"  , .T., .T.) + " LIKE '%" + cDescCli + "%' OR "
					cQuery += JurFormat("A1_NREDUZ", .T., .T.) + " LIKE '%" + cDescCli + "%' OR "
				EndIf	 
			Next nCont
			
			cQuery :=	SubStr(cQuery, 1, Len(cQuery)-3)	//Tira ultimo OR
		 	cQuery +=	" )" 
		 EndIf
		
Return JurSQL(cQuery, {"NUH_COD", "NUH_LOJA", "A1_NOME"})

//-------------------------------------------------------------------
/*/{Protheus.doc} JSeekPartC
Busca parte contraria nos envolvidos 

@since 	05/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JSeekPartC( cAutor, cTipoInt, aBusNQA ) 
Local aArea     := GetArea()
Local lEnvEnt   := ( SuperGetMV('MV_JENVENT',, '2') == "1" )	//Envolvido pela entidade
Local cQuery    := ""
Local cNome     := ""
Local cTipoEnv  := ""
Local cCpfCnpj  := ""
Local cDescEnvo := ""
Local nCont     := 0
Local lAchou    := .F.
Local aRetorno  := {}
Local aAuxBaVe  := {}
Local aDadosAut := {}
Local aDadosNZ2 := {}
Local aEnvNome  := {}
Local aDadosRet := {}

	aAuxBaVe := StrToKarr( cAutor, "|")

	If !Empty(cAutor)
		//Busca parte contraria
		cQuery := " SELECT NZ2_COD, NZ2_NOME, NZ2_CGC" 
		cQuery += " FROM " + RetSqlName("NZ2")
		cQuery += " WHERE NZ2_FILIAL = '" + xFilial("NZ2") + "'"
		cQuery += 	" AND ( "

		//Busca todas as partes contrarias
		For nCont:=1 To Len(aAuxBaVe)
			If !Empty(aAuxBaVe[nCont])
				//Limpa conteudo do campo
				cAutor := AllTrim( StrTran( Lower( JurLmpCpo(aAuxBaVe[nCont]) ), "#", " ") )
				cAutor := SubStr( cAutor, 1, TamSx3("NZ2_NOME")[1] )
	
				cQuery += JurFormat("NZ2_NOME", .T./*lAcentua*/, .T./*lPontua*/) + " LIKE '%" + cAutor + "%' OR "			
			EndIf
		Next nCont
		
		cQuery := 	SubStr(cQuery, 1, Len(cQuery)-3) //Tira ultimo OR
		cQuery += 	" ) "
		cQuery += 	" AND D_E_L_E_T_ = ' '"
		
		aRetorno := JurSQL(cQuery, {"NZ2_COD", "NZ2_NOME", "NZ2_CGC"})

	EndIf
	
	//-- Verifica se existe parte contrária - caso não exista, INCLUI
	If Len(aRetorno) > 0
		cAutor := aRetorno[1][1]
		cNome  := AllTrim(aRetorno[1][2])
		cCpfCnpj := aRetorno[1][3]
	Else
		cNome	:= SubStr( AllTrim(aAuxBaVe[1]), 1, TamSx3("NZ2_NOME")[1] )		//Cria cadastro com o primeiro nome
		
		If lEnvEnt .And. !Empty(cNome)
			aAdd(aDadosNZ2, "00000000000" )	 //-- CPF / CNPJ
			aAdd(aDadosNZ2, cNome         )	 //-- Nome
			aAdd(aDadosNZ2, ""            )	 //-- E-mail

			cAutor   := J268GrvNZ2(.F., aDadosNZ2) // Incluir parte contraria
			cCpfCnpj := "00000000000"
		EndIf
	EndIf

	//Verifica se encontrou a parte contraria
	If !Empty(cAutor)
		cAutor := AllTrim( cAutor )
		
		If lEnvEnt
			aDadosAut := { "NZ2", cTipoInt, cAutor }
		Else
			aDadosAut := { "NZ2", cTipoInt, cNome }
		EndIf
	
		//Inclui parte contraria nos envolvidos
		If !lAchou
			//Busca tipo de envolvido
			cTipoEnv := J219GetNQA( aBusNQA, cTipoInt )
			
			//Inclui envolvido da parte contraria
			aSize(aRetorno, 0 )
			
			//Envolvido pela Entidade
			Aadd(aEnvNome, "NZ2" )
			Aadd(aEnvNome, cAutor)
			Aadd(aEnvNome, "1"      ) //-- NT9_PRINCI - 1=Sim
			Aadd(aEnvNome, cTipoInt ) //-- NT9_TIPOEN - 1=Polo Ativo / 2=Polo Passivo / 3=Terceiro Interessado
			Aadd(aEnvNome, cTipoEnv ) //-- NT9_CTPENV - Cod. do tipo de Envolvimento
			
			//-- Busca a descrição do Tipo de Envolvimento
			DbSelectArea("NQA")
			NQA->(DbSetOrder(1))
			If DbSeek(xFilial('NQA')+cTipoEnv)
				cDescEnvo := ALLTRIM(NQA->NQA_DESC)
			EndIf
			NQA->(DbCloseArea())
			
			Aadd(aEnvNome, IIF( !Empty(cDescEnvo), cDescEnvo, "") ) //-- NT9_DESCEN - Descrição do tipo de Envolvimento - Reu / Reclamante / etc
			
		EndIf
	EndIf

RestArea( aArea )
	
aAdd( aDadosRet, cNome        ) //-- Nome
aAdd( aDadosRet, cCpfCnpj     ) //-- CPF / CNPJ
aAdd( aDadosRet, aEnvNome   )   //-- Dados da Entidade do Envolvido ( Entidade / Codigo / Principal? / Tipo de Envolv  / Tipo de Envolvido)

Return aDadosRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J219json( aRet )

Monta o JSON que será enviado para o TOTVS LEGAL para realizar
o pré-cadastro de processo

@param	aRet = Informações que foram coletadas da NZZ

@since 	05/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J219json( aRet )


Local oResponse := JsonObject():New()
Local nX        := 0
	
	//-- Json com os dados das Distribuições com status "Recebida"
	oResponse := {}
	aAdd(oResponse, JSonObject():New())	
	
	oResponse[1]['Envolvidos'] := {}
	
	oResponse[1]['NSZ_ESCRIT'] := AllTrim(JurEncUTF8( aRet[1] ))  //-- Escritório
	oResponse[1]['NSZ_NUMPRO'] := JurEncUTF8( aRet[2] )           //-- Numero do Processo
	oResponse[1]['NUQ_DTDIST'] := aRet[3]                         //-- Data de Distribuição
	oResponse[1]['NUQ_CCOMAR'] := aRet[4]                         //-- Comarca
	oResponse[1]['NUQ_CLOC2N'] := aRet[5]                         //-- Foro
	oResponse[1]['NUQ_CLOC3N'] := aRet[6]                         //-- Vara
	oResponse[1]['NUQ_TLOC3N'] := aRet[7]                         //-- Vara
	oResponse[1]['NSZ_CCLIEN'] := aRet[8]                         //-- Cod Cliente
	oResponse[1]['NSZ_LCLIEN'] := aRet[9]                         //-- Loja Cliente
	oResponse[1]['NSZ_DCLIEN'] := JurEncUTF8( ALLTRIM(aRet[10] )) //-- Descrição / Razão Social
	//-- Parte contraria Polo Ativo / Polo Passivo / Terceiro Interessado
	For nX := 1 To Len(aRet[11])
		If !Empty(aRet[11][nX][1]) .and. !Empty(aRet[11][nX][2])
			aAdd(oResponse[1]['Envolvidos'], JSonObject():New())
			aTail(oResponse[1]['Envolvidos'])['NT9_NOMEEN'] := JurEncUTF8( aRet[11][nX][1] )    //-- Nome
			aTail(oResponse[1]['Envolvidos'])['NT9_CGC']    := aRet[11][nX][2]                  //-- CPF / CNPJ
			aTail(oResponse[1]['Envolvidos'])['NT9_ENTIDA'] := aRet[11][nX][3][1]               //-- Entidade
			aTail(oResponse[1]['Envolvidos'])['NT9_CODENT'] := aRet[11][nX][3][2]               //-- Codigo da Entidade
			aTail(oResponse[1]['Envolvidos'])['NT9_PRINCI'] := aRet[11][nX][3][3]               //-- Principal (1=Sim/2=Nao)
			aTail(oResponse[1]['Envolvidos'])['NT9_TIPOEN'] := aRet[11][nX][3][4]               //-- Polo do Envolvido (1=Polo Ativo)
			aTail(oResponse[1]['Envolvidos'])['NT9_CTPENV'] := aRet[11][nX][3][5]               //-- Cod Tipo de Envolvimento
			aTail(oResponse[1]['Envolvidos'])['NT9_DESCEN'] := JurEncUTF8( aRet[11][nX][3][6] ) //-- Descrição do Tipo de Envolvimento
		EndIf
	Next nX
	
	oResponse[1]['NUQ_CTIPAC'] := aRet[12]                                    //-- Cod. Tipo de Ação
	oResponse[1]['NSZ_VLCAUS'] := aRet[13]                                    //-- Valor da causa
	oResponse[1]['NSZ_CMOCAU'] := aRet[14]                                    //-- Moeda da causa
	oResponse[1]['NZZ_DTAUDI'] := aRet[15]                                    //-- Data Audiência
	oResponse[1]['NZZ_HRAUDI'] := aRet[16]                                    //-- Hora Audiência
	oResponse[1]['NZZ_COD']    := aRet[17]                                    //-- código
	
Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} PsqProcOri (cCajuri)
Tela de pesquisa para vincular incidente ao processo origem

@param Código do Processo Incidente

@Return .T.
@since 26/09/2019
@version 1.0 
/*/ 
//-------------------------------------------------------------------

Static Function PsqProcOri(cCajuri)
Local aCabecalho := {}
Local aTxtMem    := {}
Local aVetor     := {}
Local cAutor     := CriaVar('NT9_NOME', .F.)
Local cCaso      := CriaVar('NSZ_NUMCAS', .F.)
Local cCAutor    := ""
Local cClient    := CriaVar('NSZ_CCLIEN', .F.)
Local cCNumPro   := ""
Local cComarca   := CriaVar('NUQ_CCOMAR', .F.)
Local cCReu      := ""
Local cCTpAcao   := ""
Local cForo      := CriaVar('NUQ_CLOC2N', .F.)
Local cLoja      := CriaVar('NSZ_LCLIEN', .F.)
Local cProces    := CriaVar('NUQ_NUMPRO', .F.)
Local cQuery     := ""
Local cReu       := CriaVar('NT9_NOME', .F.)
Local cTpAcao    := CriaVar('NUQ_CTIPAC', .F.)
Local cVar       := ""
Local cVara      := CriaVar('NUQ_CLOC3N', .F.)
Local lHab       := .T.
Local oAutor     := Nil
Local oCaso      := Nil
Local oCAutor    := Nil
Local oClient    := Nil
Local oCNumPro   := Nil
Local oComarca   := Nil
Local oCReu      := Nil
Local oCTpAcao   := Nil
Local oDlgVinc   := Nil
Local oForo      := Nil
Local oLbx       := Nil
Local oLoja      := Nil
Local oNo        := LoadBitmap( GetResources(), "LBNO" )
Local oOk        := LoadBitmap( GetResources(), "LBOK" )
Local oProces    := Nil
Local oReu       := Nil
Local oTpAcao    := Nil
Local oVara      := Nil

	cQuery:= " SELECT NSZ_NUMPRO, NSZ_PATIVO, NSZ_PPASSI, NQU_DESC "
	cQuery+= "FROM "+RetSqlName("NSZ") 
	cQuery+= " INNER JOIN " +RetSqlName("NUQ")+ " ON (NSZ_COD = NUQ_CAJURI AND NSZ_FILIAL = NUQ_FILIAL)
	cQuery+=   " LEFT JOIN " +RetSqlName("NQU")+ " ON (NQU_COD = NUQ_CTIPAC )
	cQuery+= " WHERE NSZ_COD = '"+ cCajuri+ "'"
	cQuery+= " AND NSZ_FILIAL = '" +xFilial('NSZ')+ "'"

	aCabecalho := JurSql(cQuery,{"NSZ_NUMPRO", "NQU_DESC", "NSZ_PATIVO", "NSZ_PPASSI" })
	
	If Len(aCabecalho) > 0
		cCNumPro := aCabecalho[1][1]
		cCTpAcao := aCabecalho[1][2]
		cCAutor  := aCabecalho[1][3]
		cCReu    := aCabecalho[1][4]
	EndIf
	//Linha Vazia do Grid
	aadd(aVetor,{.F., "", "", "", "", ""})

	DEFINE MSDIALOG oDlgVinc TITLE STR0108 FROM 218,178 TO 705,964 PIXEL STYLE DS_MODALFRAME//"Vincular incidente ao processo origem"
	//Cabeçalho Processo
	@ 005,005 Say STR0107 Size 092,008 PIXEL OF oDlgVinc
	
	@ 017,005 Say STR0121 Size 092,008 PIXEL OF oDlgVinc
	@ 025,005 MsGet oCNumPro Var cCNumPro When .F. Size 92,008 PIXEL OF oDlgVinc

	@ 017,102 Say STR0115 Size 092,008 PIXEL OF oDlgVinc
	@ 025,102 MsGet oCTpAcao Var cCTpAcao When .F. Size 092,008 PIXEL OF oDlgVinc

	@ 017,199 Say STR0113 Size 092,008 PIXEL OF oDlgVinc
	@ 025,199 MsGet oCAutor	Var cCAutor When .F. Size 092,008 PIXEL OF oDlgVinc

	@ 017,295 Say STR0114 Size 092,008 PIXEL OF oDlgVinc
	@ 025,295 MsGet oCReu Var cCReu When .F. Size 092,008 PIXEL OF oDlgVinc

	//Pesquisa
	@ 050,005 Say STR0123 Size 092,008 PIXEL OF oDlgVinc

	//Cliente 
	@ 062,005 Say STR0109 Size 092,008 PIXEL	OF oDlgVinc
	@ 070,005 MsGet oClient	Var cClient Picture "@!" F3 "SA1" When lHab	Size 092,008 PIXEL 	OF oDlgVinc HasButton

	//Loja
	@ 062,102 Say STR0110 Size 092,008 PIXEL	OF oDlgVinc
	@ 070,102 MsGet oLoja Var cLoja	Picture "@!" When lHab	Size 092,008 PIXEL OF oDlgVinc

	//Caso
	@ 062,199 Say STR0111 Size 092,008 PIXEL	OF oDlgVinc
	@ 070,199 MsGet oCaso Var cCaso F3 "NVEXML" When lHab Size 092,008 PIXEL OF oDlgVinc HasButton

	//Processo   
	@ 062,295 Say STR0121 Size 092,008 PIXEL OF oDlgVinc
	@ 070,295 MsGet oProces Var cProces When lHab Size 092,008 PIXEL OF oDlgVinc

	//Comarca 
	@ 082,005 Say STR0116 Size 092,008 PIXEL OF oDlgVinc
	@ 090,005 MsGet oComarca Var cComarca F3 "NQ6" When lHab	Size 092,008 PIXEL 	OF oDlgVinc HasButton

	//Foro / Tribunal
	@ 082,102 Say STR0117 Size 092,008 PIXEL OF oDlgVinc
	@ 090,102 MsGet oForo 	 Var cForo F3 "NQCXML" When lHab Size 092,008 PIXEL 	OF oDlgVinc HasButton

	//Vara / Órgão
	@ 082,199 Say STR0118 Size 092,008 PIXEL	OF oDlgVinc
	@ 090,199 MsGet oVara Var cVara F3 "NQEXML"  When lHab Size 092,008 PIXEL  OF oDlgVinc HasButton

	@ 082,295 Say STR0115 Size 092,008 PIXEL OF oDlgVinc
	@ 090,295 MsGet oTpAcao Var cTpAcao F3 "NQU" When lHab	Size 092,008 PIXEL 	OF oDlgVinc HasButton

	//Autor 
	@ 102,005 Say STR0113 Size 092,008 PIXEL OF oDlgVinc
	@ 110,005 MsGet oAutor Var cAutor When lHab Size 092,008 PIXEL OF oDlgVinc

	//Réu 
	@ 102,102 Say STR0114 Size 092,008 PIXEL OF oDlgVinc
	@ 110,102 MsGet oReu Var cReu When lHab Size 092,008 PIXEL OF oDlgVinc


	
	//Botão Limpar
	@ 145,315 BUTTON STR0119 SIZE 33,12 ;
		ACTION (cClient:=Space(50), cProces:=Space(50), cAutor:=Space(50), cReu:=Space(50),	cLoja := Space(2), cTpAcao:=Space(50), cCaso:=Space(50), cComarca:=Space(50), cForo:=Space(50), cVara:=Space(50),;
				oClient:Refresh(), oLoja:Refresh(), oProces:Refresh(), oAutor:Refresh(), oReu:Refresh(), oTpAcao:Refresh(), oCaso:Refresh(), oComarca:Refresh(),oForo:Refresh(), oVara:Refresh()) PIXEL OF oDlgVinc// Limpar //"&Limpar"

	//Botão Pesquisar
	@ 145,357 BUTTON STR0120 SIZE 33,12 ;
		ACTION ((aTxtMem := PesqVinc(cClient,cLoja,cProces,cAutor,cReu,cTpAcao,cCaso,cComarca,cForo,cVara,@oLbx,@aVetor,"","",cCajuri))) PIXEL OF oDlgVinc//"Pesquisar"

	//Grid
	@ 165,005 LISTBOX oLbx VAR cVar FIELDS HEADER " ", STR0121,STR0122,STR0113,STR0114,STR0115; //#"Num.Processo"#"Cód.Interno"#Autor"#"Réu"#"Tipo de Ação"
		SIZE 385,060 OF oDlgVinc PIXEL ON dblClick( SetChecked(@aVetor, @oLbx) )
		oLbx:SetArray( aVetor )
		oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),aVetor[oLbx:nAt,2],aVetor[oLbx:nAt,3],aVetor[oLbx:nAt,4],aVetor[oLbx:nAt,5],aVetor[oLbx:nAt,6]}}

	//Botão Ok
	DEFINE SBUTTON FROM 230,365 TYPE 1 ;
		ACTION ((cClient:=Space(50), cProces:=Space(50), cAutor:=Space(50), cReu:=Space(50), cLoja := Space(2), cTpAcao:=Space(50), cCaso:=Space(50), cComarca:=Space(50), cForo:=Space(50), cVara:=Space(50),; //limpa campos
				oClient:Refresh(), oLoja:Refresh(), oProces:Refresh(), oAutor:Refresh(), oReu:Refresh(), oTpAcao:Refresh(), oCaso:Refresh(), oComarca:Refresh(),oForo:Refresh(), oVara:Refresh()),; //Refresh de objetos
				VincIncid(aVetor,cCajuri),; //Vincula Processo
				oDlgVinc:End()) ENABLE 	OF oDlgVinc  
	
	//Botão Cancelar
	DEFINE SBUTTON FROM 230,335 TYPE 2 ACTION (oDlgVinc:End()) ENABLE 	OF oDlgVinc

	oDlgVinc:LESCCLOSE := .F. 
	ACTIVATE MSDIALOG oDlgVinc CENTERED

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VincIncid (aVetor, cCajuri)
Vincula o incidente ao processo principal

@param aVetor  Array com o grid da tela de pesquisa
@param cCajuri Código do processo Incidente

@since 26/09/2019
@version 1.0 
/*/ 
//-------------------------------------------------------------------
Static Function VincIncid(aVetor, cCajuri)
Local aArea      := GetArea()
Local cCajuriOri := ""
Local cFil       := xFilial('NSZ')
Local cFilOri    := ""
Local lRet       := .F.
Local nI         := 0

	If Len(aVetor) > 0
		For nI := 1 To Len(aVetor)
			If (aVetor[nI][1]) // Se for o registro selecionado
				DbSelectArea("NSZ")
				NSZ->( DbSetOrder(1) )	//NSZ_FILIAL + NSZ_COD

				If NSZ->(dbSeek(cFil + cCajuri)) // Valida se o Incidente já foi cadastrado 
					cFilOri    := aVetor[nI][7]
					cCajuriOri := aVetor[nI][3]

					If  lIncdtTOK(cCajuriOri, cCajuri) // Valida se o Vínculo pode ser efetuado
							RecLock('NSZ', .F.)
							NSZ->NSZ_FPRORI := cFilOri
							NSZ->NSZ_CPRORI := cCajuriOri
							NSZ->( dbCommit() )
							NSZ->( MsUnlock() )
							lRet := .T.
					Endif
				EndIf

			EndIf
		Next
	EndIf

	If !(lRet)
		JurMsgErro(STR0124)
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetChecked(aVetor, oLbx)
Marca a linha selecionada e impede que mais de uma linha seja marcada.

@param aVetor  Array com o grid da tela de pesquisa
@param oLbx Linha do grig para marcar

@since 26/09/2019
@version 1.0 
/*/ 
//-------------------------------------------------------------------
Static Function SetChecked(aVetor, oLbx)

	If (aVetor[oLbx:nAt,1])
		aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1]
	ElseIf(aScan(aVetor,{|x| x[1]==.T.})>0)
		MsgAlert( STR0125 ,"")
	else
		aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1]
	EndIf
Return Nil

