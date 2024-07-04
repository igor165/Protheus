#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE  "GPEM561.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    	Ё GPEM561    Ё Autor Ё Flavio  Correa       	      Ё Data Ё 22/12/16 Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o 	Ё ManutenГЦo de Pensao - DIRF                               			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   	Ё GPEM561()                                                    			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      	Ё Generico ( DOS e Windows )                                   			Ё╠╠
╠╠цдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.               			Ё╠╠
╠╠цдддддддддддддбддддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador  Ё Data     Ё FNC		Ё  Motivo da Alteracao                      	Ё╠╠
╠╠цддддддддддддеддддддддедддддддддддддддддддеддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁClaudinei S. Ё03/02/2017ЁMRH-6204  	ЁAjuste em CargaGrid() para carregar somente um	Ё╠╠
╠╠Ё             Ё          Ё          	Ёregistro de cada beneficiАrio.					Ё╠╠
╠╠цдддддддддддддеддддддддддеддддддддддддддддеддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юдддддддддддддаддддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function GPEM561()

Local oMBrowse
Local cFiltraRh

oMBrowse := FWMBrowse():New()

oMBrowse:SetAlias("SRA")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //"PensЦo BeneficiАrios"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFiltraRh := CHKRH("GPEM560","SRA","1")
oMBrowse:SetFilterDefault( cFiltraRh )

oMBrowse:Activate()

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ModelDef 		ЁAutorЁ  Flavio  Correa  Ё Data Ё22/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Modelagem da gravacao.                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM561                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ModelDef()

Local oModel
Local oStructSRA
Local oStructSM8
Local oStructSRQ

// Criacao do Objeto de Modelagem de dados da tabela SR4 //
oModel     := MPFormModel():New("GPEM561", Nil, NIL, {|oModel| M561Commit(oModel)})
oModel:SetDescription( OemToAnsi(STR0001)) //"PensЦo BeneficiАrios"

// Estrutura de campos do Model //
oStructSRA := FWFormStruct(1, "SRA", { |cCampo| Gpm561SRAStru(cCampo) })
oModel:AddFields("GPEM561_MSRA", NIL, oStructSRA)
oModel:GetModel( "GPEM561_MSRA" ):SetDescription( OemToAnsi(STR0001) ) //"PensЦo BeneficiАrios"
oModel:GetModel( "GPEM561_MSRA" ):SetOnlyQuery(.T.)
oModel:GetModel( "GPEM561_MSRA" ):SetOnlyView(.T.)

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Estrutura de campos do Model (SRQ) Beneficiarios						 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

//oStructSRQ := FWFormStruct(1, "SRQ",{|cCampo| AllTrim(cCampo)+"|" $ "RQ_FILIAL|RQ_MAT|RQ_NOME|RQ_CIC|RQ_ORDEM|RQ_DTINI|RQ_DTFIM|RQ_RELDEP|"})
oStructSRQ := FWFormStruct(1, "SRQ",{|cCampo| Gpm561SRQStru(cCampo)})
oModel:AddGrid("GPEM561_MSRQ", "GPEM561_MSRA", oStructSRQ,,,,,{|oGrid|CargaGrid(oGrid)})
oModel:GetModel( "GPEM561_MSRQ" ):SetDescription( OemToAnsi(STR0005) ) //'BeneficiАrios
oModel:GetModel( "GPEM561_MSRQ" ):SetNoInsertLine(.T.)
oModel:GetModel( "GPEM561_MSRQ" ):SetNoUpdateLine(.T.)
oModel:GetModel( "GPEM561_MSRQ" ):SetNoDeleteLine(.T.)
oModel:SetRelation( "GPEM561_MSRQ", { { 'RQ_FILIAL', 'SRA->RA_FILIAL' }, { 'RQ_MAT', 'SRA->RA_MAT' } }, SRQ->( IndexKey( 1 ) ) )

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Estrutura de campos do Model (SM8)									 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oStructSM8 := FWFormModelStruct():New()
M561Str(1,oStructSM8)
oModel:AddGrid("GPEM561_MSM8", "GPEM561_MSRQ", oStructSM8 , NIL, NIL, NIL, NIL, {|oGrid,lCopia| LoadSM8(oGrid,lCopia) } )
oModel:GetModel( "GPEM561_MSM8" ):SetDescription( OemToAnsi(STR0006) ) //"PensЦo"
oModel:GetModel( "GPEM561_MSM8" ):SetOptional(.T.)
oModel:GetModel( "GPEM561_MSM8" ):SetNoInsertLine(.T.)
oModel:GetModel( "GPEM561_MSM8" ):SetNoDeleteLine(.T.)
oModel:SetRelation( "GPEM561_MSM8", { { 'M8_FILIAL', 'SRL->RL_FILIAL' }, { 'M8_MAT', 'SRL->RL_MAT' } , {'TMP_CODBEN' , "RQ_ORDEM"}, {'TMP_ANO' , 'cAno'}, {'TMP_CODRET' , 'SRL->RL_CODRET'} }, SM8->( IndexKey( 1 ) ) )

oModel:SetPrimaryKey({})

Return( oModel )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef  		ЁAutorЁ  Flavio  Correa  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Interface com o Usuario                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM561                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ViewDef()

Local oView
Local oModel
Local oStructSRA
Local oStructSM8
Local oStructSRQ
Local lCpoDep  := SRQ->( ColumnPos("RQ_RELDEP") <> 0 )

// Vincular o View ao Model //
oModel := FWLoadModel("GPEM561")

// Criacao da Interface //
oView := FWFormView():New()
oView:SetModel(oModel)

// Criacao do Cabecalho - SRA (Funcionario) //
oStructSRA := FWFormStruct(2, "SRA", { |cCampo| Gpm561SRAStru(cCampo) })
oStructSRA:SetNoFolder()
oView:AddField("GPEM561_VSRA", oStructSRA, "GPEM561_MSRA" )

// Criacao do GRID - SRQ Beneficiarios //
oStructSRQ:= FWFormStruct(2, 'SRQ',{|cCampo| AllTrim(cCampo)+"|" $ "RQ_FILIAL|RQ_MAT|RQ_NOME|RQ_CIC|RQ_ORDEM|"+If(lCpoDep,"RQ_RELDEP|","")})
oStructSRQ:RemoveField("RQ_MAT")
oView:AddGrid("GPEM561_VSRQ", oStructSRQ, "GPEM561_MSRQ" )


// Criacao do GRID - SM8 Pensao Beneficiarios //
oStructSM8 := FWFormViewStruct():New()
M561Str(2,oStructSM8)//FWFormStruct(2, 'SM8')
oStructSM8:RemoveField("TMP_MAT")
oStructSM8:RemoveField("TMP_CODRET")
oStructSM8:RemoveField("TMP_ANO")
oStructSM8:RemoveField("TMP_MES")
oStructSM8:RemoveField("TMP_CODBEN")
oStructSM8:RemoveField("TMP_FILIAL")
oView:AddGrid("GPEM561_VSM8", oStructSM8, "GPEM561_MSM8" )

// Desenho da Tela //
oView:CreateHorizontalBox("SRA_HEAD", 17)
oView:CreateHorizontalBox("SRQ_GRID", 28)
oView:CreateHorizontalBox("SM8_GRID", 55)


oView:SetOwnerView( "GPEM561_VSRA", "SRA_HEAD" )
oView:SetOwnerView( "GPEM561_VSRQ", "SRQ_GRID" )
oView:SetOwnerView( "GPEM561_VSM8", "SM8_GRID" )

oView:EnableTitleView( "GPEM561_VSRA", OemToAnsi(STR0007) ) //"FuncionАrios"
oView:EnableTitleView( "GPEM561_VSRQ", OemToAnsi(STR0005) ) //"Beneficiarios"
oView:EnableTitleView( "GPEM561_VSM8", OemToAnsi(STR0006) ) //"PensЦo"

Return oView

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gpm561SRAStru	ЁAutorЁ  Flavio  Correa  Ё Data Ё20/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSelecionar os campos para a estrutura do SRA                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM561                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpm561SRAStru( cCampo )
	Local lRet := .F.

	cCampo := AllTrim( cCampo )
	If cCampo $ 'RA_MAT*RA_NOME'
		lRet := .T.
	EndIf

Return lRet

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Flavio  Correa  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCriacao do Menu do Browse.                                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM561                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.GPEM561" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.GPEM561" 		OPERATION 4 ACCESS 0				//'Alterar'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} M561Str
Estrutura da tabela SM8, para model e view
@author Flavio S. Correa
@since 21/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function M561Str(nTipo,oStruct)
Local aArea    := GetArea()
Local bValid   := Nil
Local bWhen    := Nil
Local bRelac   := Nil
Local aTit 		:= {}
Local nI		:= 1

aAdd( aTit, { 'Filial'				,'Filial'				,'TMP_FILIAL'		, "C", FWGETTAMFILIAL		, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )
aAdd( aTit, { 'Matricula'			,'Matricula'			,'TMP_MAT'			, "C", TamSx3("RA_MAT")[1]	, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )
aAdd( aTit, { 'Cod Benef.'			,'Cod Benef.'			,'TMP_CODBEN'		, "C", 2					, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )
aAdd( aTit, { 'MЙs'					,'MЙs'					,'TMP_MES'			, "C", 2					, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )
aAdd( aTit, { 'MЙs'					,'MЙs'					,'TMP_DESMES'		, "C", 10					, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )
aAdd( aTit, { 'Cod. RetenГЦo'		,'Cod. RetenГЦo'		,'TMP_CODRET'		, "C", 4					, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )
aAdd( aTit, { 'Ano'					,'Ano'					,'TMP_ANO'			, "C", 4					, 0 ,"@!"					,,/*cBox*/,.F./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )
aAdd( aTit, { 'Dt. Pagto'			,'Dt. Pagto'			,'TMP_DTPGTO'		, "D", 8					, 0 ,"@!"					,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )
aAdd( aTit, { 'PensЦo'				,'PensЦo'				,'TMP_VALC'			, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )
aAdd( aTit, { 'PensЦo 13'			,'PensЦo 13'			,'TMP_VALC1'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )
aAdd( aTit, { 'PensЦo PLR'			,'PensЦo PLR'			,'TMP_VALC3'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )
aAdd( aTit, { 'PensЦo RRA'			,'PensЦo RRA'			,'TMP_VALC2'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )
aAdd( aTit, { 'PensЦo Exig. Sups.'	,'PensЦo Exig. Sups.'	,'TMP_VAL8'			, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )
aAdd( aTit, { 'PensЦo Exig. Sups 13','PensЦo Exig. Sups 13'	,'TMP_VAL81'		, "N", 15					, 2 ,"@E 999,999,999.99 "	,,/*cBox*/,.T./*Editavel*/,"GET",bRelac/*inicializacao*/,.F. /*virtual*/,bWhen,bValid} )


For nI := 1 To Len(aTit)
	If nTipo = 1
		oStruct:AddField( ;
			aTit[nI][1]           , ;              // [01] Titulo do campo
			aTit[nI][2]           , ;              // [02] ToolTip do campo
			aTit[nI][3]           , ;              // [03] Id do Field
			aTit[nI][4]           , ;              // [04] Tipo do campo
			aTit[nI][5]           , ;              // [05] Tamanho do campo
			aTit[nI][6]           , ;              // [06] Decimal do campo
			aTit[nI][15]          , ;              // [07] Code-block de validaГЦo do campo
			aTit[nI][14]          , ;              // [08] Code-block de validaГЦo When do campo
			aTit[nI][9]           , ;              // [09] Lista de valores permitido do campo
			.F.                   , ;              // [10] Indica se o campo tem preenchimento obrigatСrio
			aTit[nI][12]          , ;              // [11] Code-block de inicializacao do campo
			NIL                   , ;              // [12] Indica se trata-se de um campo chave
			Nil                   , ;              // [13] Indica se o campo nЦo pode receber valor em uma operaГЦo de update.
			aTit[nI][13] )          		           // [14] Indica se o campo И virtual
	Else
		oStruct:AddField( 				      ;
		   		aTit[nI][3]                 , ;              // [01] Campo
				alltrim(strzero(nI+3,2))  	, ;              // [02] Ordem
				aTit[nI][1]                 , ;              // [03] Titulo
				aTit[nI][1]                 , ;              // [04] Descricao
				NIL                    		, ;              // [05] Help
				aTit[nI][11]                , ;              // [06] Tipo do campo   COMBO, Get ou CHECK
				aTit[nI][7]                 , ;              // [07] Picture
				                       		, ;              // [08] PictVar
				                  			, ;              // [09] F3
				aTit[nI][10]   	            , ;              // [10] Editavel
				                       		, ;              // [11] Folder
				                       		, ;              // [12] Group
				aTit[nI][9]                 , ;              // [13] Lista Combo
				                            , ;              // [14] Tam Max Combo
				                            , ;              // [15] Inic. Browse
				aTit[nI][13])                                // [16] Virtual

	EndIf

Next nI

RestArea( aArea )

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadSM8
Load do model SM8
@author Flavio S. Correa
@since 21/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadSM8(oGrid,lCopia)
Local aRet       	:= {}
Local aArea      	:= GetArea()
Local nI			:= 1
Local cAliasTmp		:= GetNextAlias()
Local oSRQ			:= oGrid:GetModel("GPEM561_MSRQ"):GetModel("GPEM561_MSRQ")
Local cBen			:= oSRQ:getvalue("RQ_ORDEM")
Local aMeses		:= {"Janeiro", "Fevereiro", "MarГo", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro","Dezembro" }  //"Janeiro", "Fevereiro"... "Dezembro"
Local aPos			:= {"C","C1","C3","C2","8","81"}
Local nPosIni		:= 8
Local nPos			:= 0

BEGINSQL ALIAS cAliasTmp
	column M8_DTPGTO as date
	SELECT *
	FROM %table:SM8% SM8
	WHERE SM8.%notDel%
	AND M8_FILIAL = %exp:SRL->RL_FILIAL%
	AND M8_MAT = %exp:SRL->RL_MAT%
	AND M8_CODBEN = %exp:cBen%
	AND M8_ANO	 = %exp:cAno%
	AND M8_CODRET = %exp:SRL->RL_CODRET%
ENDSQL

For nI := 1 To 12
	Aadd(aRet, {nI, {SRL->RL_FILIAL,SRL->RL_MAT,cBen,strzero(nI,2),aMeses[nI],SRL->RL_CODRET,cAno,ctod(" /  / "),0,0,0,0,0,0 } } )
Next nI

While !(cAliasTmp)->(Eof())
	nPos := aScan(aPos,{ |x| x==Alltrim((cAliasTmp)->M8_TIPOREN)})
	aRet[Val((cAliasTmp)->M8_MES)][2][nPosIni+nPos] += (cAliasTmp)->M8_VALOR
	aRet[Val((cAliasTmp)->M8_MES)][2][8] :=(cAliasTmp)->M8_DTPGTO
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

RestArea( aArea )
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} M561Commit
Grava Model
@author Flavio S. Correa
@since 21/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function M561Commit(oModel)
Local aArea		:= GetArea()
Local oSRQ		:= oModel:GetModel( 'GPEM561_MSRQ' )
Local oTMP		:= oModel:GetModel( 'GPEM561_MSM8' )
Local nLenSRQ	:= oSRQ:Length()
Local nLenTMP	:= oTMP:Length()
Local aRend		:= {"C","C1","C3","C2","8","81"}
Local nX		:= 1
Local nY		:= 1
Local nZ		:= 1

dbSelectArea("SM8")
SM8->(dbSetOrder(1))

If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	For nX := 1 To nLenSRQ
		oSRQ:GoLine( nX )
		For nY := 1 To nLenTMP
			oTMP:GoLine( nY )
			If oTMp:IsUpdated()
				For nZ := 1 To Len(aRend)
					//M8_FILIAL+M8_MAT+M8_CPFBEN+M8_CODBEN+M8_CODRET+M8_ANO+M8_MES+M8_TIPOREN
					If SM8->(dbSeek(oTMP:GetValue("TMP_FILIAL")+oTMP:GetValue("TMP_MAT")+oSRQ:GetValue("RQ_CIC")+oTMP:GetValue("TMP_CODBEN")+oTMP:GetValue("TMP_CODRET")+cANo+oTMP:GetValue("TMP_MES")+padr(aRend[nZ],2)    ) )
						RecLock("SM8",.F.)
							SM8->M8_VALOR := oTMP:GetValue("TMP_VAL"+aRend[nZ])
							SM8->M8_DTPGTO:= oTmp:GetValue("TMP_DTPGTO")
						SM8->(msUnlock())
					Else
						If oTMP:GetValue("TMP_VAL"+aRend[nZ]) > 0
							RecLock("SM8",.T.)
								SM8->M8_FILIAL 	:= oTMP:GetValue("TMP_FILIAL")
								SM8->M8_MAT		:= oTMP:GetValue("TMP_MAT")
								SM8->M8_CPFBEN 	:= oSRQ:GetValue("RQ_CIC")
								SM8->M8_CODBEN 	:= oTMP:GetValue("TMP_CODBEN")
								SM8->M8_CODRET	:= oTMP:GetValue("TMP_CODRET")
								SM8->M8_MES		:= oTMP:GetValue("TMP_MES")
								SM8->M8_ANO	 	:= cAno
								SM8->M8_TIPOREN := aRend[nZ]
								SM8->M8_VALOR  	:= oTMP:GetValue("TMP_VAL"+aRend[nZ])
								SM8->M8_DTPGTO 	:= oTmp:GetValue("TMP_DTPGTO")
							SM8->(msUnlock())
						EndIf
					EndIf
				Next nZ
			EndIf
		Next nY
	Next nX
EndIf

RestArea(aArea)
Return( .T. )

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммямммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁCargaGrid  ╨Autor  ЁFlavio Correa      ╨ Data Ё  09/01/2017 ╨╠╠
╠╠лммммммммммьмммммммммммймммммммомммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁCarrega RH4												  ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁSIGAGPE                                                     ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Static Function CargaGrid(oGrid)

Local aAreaSRA	:= SRA->( GetArea() )
Local aRet 		:= {}
Local aRet2		:= {}
Local nX		:= 0
Local nPosCampo	:= oGrid:GetIdField("RQ_DTFIM")
Local nPosNome	:= oGrid:GetIdField("RQ_NOME")
Local nPosOrdem	:= oGrid:GetIdField("RQ_ORDEM")
Local cCampo	:= ""
Local cNome		:= ""
Local nPosRet	:= 0

SRA->( dbSetOrder(1) )
SRA->( dbSeek( SRL->RL_FILIAL + SRL->RL_MAT ) )

aRet2 := FormLoadGrid(oGrid)
For nX:= 1 to Len(aRet2)
	cCampo	:= aRet2[nX][2][nPosCampo]
	cNome	:= aRet2[nX][2][nPosNome]
	nPosRet	:= aScan(aRet,{ |x| x[2][nPosNome] == aRet2[nX,2,nPosNome] .AND. x[2][nPosOrdem] == aRet2[nX,2,nPosOrdem]})
	If nPosRet == 0 .And. ( Empty(cCampo) .Or. (Year(cCampo) >= Val(cAno) .Or. (Year(cCampo) == (Val(cAno)-1) .ANd. Month(cCampo) == 12)) )
		aAdd(aRet,aClone(aRet2[nX]))
	Endif
Next

RestArea(aAreaSRA)

Return aRet

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gpm561SRQStru	ЁAutorЁ  Silvia Taguti   Ё Data Ё14/02/2019Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSelecionar os campos para a estrutura do SRQ                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM561                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpm561SRQStru( cCampo )

Local lRet := .F.
Local lCpoDep  := SRQ->( ColumnPos("RQ_RELDEP") <> 0 )
Local cCampos1  := 'RQ_FILIAL|RQ_MAT|RQ_NOME|RQ_CIC|RQ_ORDEM|RQ_DTINI|RQ_DTFIMP|'
Local cCampos2  := 'RQ_FILIAL|RQ_MAT|RQ_NOME|RQ_CIC|RQ_ORDEM|RQ_DTINI|RQ_DTFIM|RQ_RELDEP|'

	cCampo := AllTrim( cCampo )

	If cCampo $ If(lCpoDep, cCampos2, cCampos1)
		lRet := .T.
	EndIf

Return lRet
