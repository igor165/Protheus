#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA840.CH"

Static cAliasTMP
Static cTrab
Static 	__oModelCopy

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    	Ё GPEA840    Ё Autor Ё Leandro Drumond       	      Ё Data Ё 18/06/12 Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o 	Ё Cadastro de RRA                                              			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   	Ё GPEA840()                                                    			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      	Ё Generico ( DOS e Windows )                                   			Ё╠╠
╠╠цдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.               			Ё╠╠
╠╠цдддддддддддддбддддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador  Ё Data     Ё FNC			Ё  Motivo da Alteracao                      Ё╠╠
╠╠цдддддддддддддеддддддддддеддддддддддддддддеддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁCecilia Carv.Ё15/05/2014ЁTPPCSB          ЁIncluido o fonte da 11 para a 12 e efetuadaЁ╠╠
╠╠Ё             Ё          Ё                Ё a limpeza.                                Ё╠╠
╠╠ЁPaulo O I   Ё13/04/2017ЁDRHPAG-239      ЁMelhoria -  remoГЦo de dependencias do ctreeЁ╠╠
╠╠юдддддддддддддаддддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function GPEA840()

Local oMBrowse
Local cFiltraRh
Local aOfusca	:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel	:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})

Private lOfusca		:= Len(aFldRel) > 0
Private oTmpTable 	:= Nil

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("SRA")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //'ManutenГЦo de RRA'

GpLegMVC(@oMBrowse)	// Adicionar a Legenda no Browse

//Cria arquivo temporario
cAliasTMP := fCriaTMP()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFiltraRh := CHKRH("GPEA840","SRA","1")
cFiltraRh += IF(!Empty(cFiltraRh),'.and. RA_CATFUNC != "A"','RA_CATFUNC != "A"')

oMBrowse:SetFilterDefault( cFiltraRh )
oMBrowse:Activate()

fDelTMP( cAliasTMP )

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ModelDef 		ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Modelagem da gravacao.                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA840                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ModelDef()

Local oModel
Local oStructSRA
Local oStructRF1
Local oStructRFC
Local cAliasTMP := If( valType(cAliasTMP) == "U" , fCriaTMP(), cAliasTMP)
Local bValActivate 	:= { || fLoadRF1(cAliasTMP) }
Local bActivate 	:= { |oModel| Gp840ActMod(oModel) }

// Criacao do Objeto de Modelagem de dados da tabela RFC //
oModel:= MPFormModel():New("GPEA840", NIL, NIL, {|oModel| GPEA840Commit(oModel)})
oModel:SetDescription( OemToAnsi(STR0001) ) //'ManutenГЦo de RRA'
oModel:SetVldActivate(bValActivate)
oModel:SetActivate( bActivate )

// Estrutura de campos do Model //
oStructSRA := FWFormStruct(1, "SRA", { |cCampo| Gpa840SRAStru(cCampo) })
oModel:AddFields("GPEA840_MSRA", NIL, oStructSRA)
oModel:GetModel( "GPEA840_MSRA" ):SetDescription( OemToAnsi(STR0001) ) //'ManutenГЦo de RRA'
oModel:GetModel( "GPEA840_MSRA" ):SetOnlyQuery(.T.)
oModel:GetModel( "GPEA840_MSRA" ):SetOnlyView(.T.)

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Estrutura de campos do Model (RF1)Complementos Trabalhistas			 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oStructRF1 := DefStrModel( cAliasTMP )

oModel:AddGrid("GPEA840_MTMP", "GPEA840_MSRA", oStructRF1,, { |oModel| .T. },,,{|oGrid| A840Carga(oGrid) }/*bLoad*/)  
oModel:GetModel( "GPEA840_MTMP" ):SetDescription( OemToAnsi(STR0008) )
oModel:GetModel( "GPEA840_MTMP" ):SetOptional( .T. )
oModel:GetModel( "GPEA840_MTMP" ):SetOnlyView( .T. )
oModel:GetModel( "GPEA840_MTMP" ):SetNoInsertLine( .T. )
oModel:GetModel( "GPEA840_MTMP" ):SetNoDeleteLine( .T. )
oModel:GetModel( "GPEA840_MTMP" ):SetNoUpdateLine( .T. )

oModel:SetRelation( "GPEA840_MTMP", { { "TMP_FILIAL", 'SRA->RA_FILIAL' } , { "TMP_MAT", 'SRA->RA_MAT' } }, (cAliasTMP)->( IndexKey( 1 ) ) )

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Estrutura de campos do Model (RFC)Sintetica RRA						 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oStructRFC := FWFormStruct(1, "RFC")
oModel:AddGrid("GPEA840_MRFC", "GPEA840_MTMP", oStructRFC,, { |oModel| .T./*LinhaOK*/ })
oModel:GetModel( "GPEA840_MRFC" ):SetDescription( OemToAnsi(STR0009) )
oModel:GetModel( "GPEA840_MRFC" ):SetOptional( .T. )
oModel:GetModel( "GPEA840_MRFC" ):SetNoInsertLine( .T. )
oModel:SetRelation( "GPEA840_MRFC", { { "RFC_FILIAL", 'SRA->RA_FILIAL' } ,{ "RFC_MAT", 'SRA->RA_MAT' } , { "RFC_IDCMPL", 'TMP_IDCMPL' } }, RFC->( IndexKey( 1 ) ) )

oStructRFC:SetProperty( 'RFC_DATPGT' 	, MODEL_FIELD_WHEN ,{ |oModel| When_NotEdit(oModel, "GPEA840_MRFC") })
oStructRFC:SetProperty( 'RFC_DATARQ' 	, MODEL_FIELD_WHEN ,{ |oModel| When_NotEdit(oModel, "GPEA840_MRFC") })
oStructRFC:SetProperty( 'RFC_PD' 		, MODEL_FIELD_WHEN ,{ |oModel| When_NotEdit(oModel, "GPEA840_MRFC") })
oStructRFC:SetProperty( 'RFC_SEQ' 		, MODEL_FIELD_WHEN ,{ |oModel| When_NotEdit(oModel, "GPEA840_MRFC") })
oStructRFC:SetProperty( 'RFC_PARC' 		, MODEL_FIELD_WHEN ,{ |oModel| When_NotEdit(oModel, "GPEA840_MRFC") })
oStructRFC:SetProperty( 'RFC_MESES' 	, MODEL_FIELD_WHEN ,{ |oModel| When_NotEdit(oModel, "GPEA840_MRFC") })
oStructRFC:SetProperty( 'RFC_SEMANA' 	, MODEL_FIELD_WHEN ,{ |oModel| When_NotEdit(oModel, "GPEA840_MRFC") })

Return( oModel )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef  		ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Interface com o Usuario                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA840                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ViewDef()

Local oView 
Local oModel
Local oStructSRA
Local oStructRF1
Local oStructRFC

// Vincular o View ao Model //
oModel := FWLoadModel("GPEA840")	

// Criacao da Interface //
oView := FWFormView():New()
oView:SetModel(oModel)

// Criacao do Cabecalho - SRA (Funcionario) //
oStructSRA := FWFormStruct(2, "SRA", { |cCampo| Gpa840SRAStru(cCampo) })
oStructSRA:SetNoFolder()
oView:AddField("GPEA840_VSRA", oStructSRA, "GPEA840_MSRA" )

// Criacao do GRID - SR4 (Sintetico RRA) //
oStructRF1 := DefStrView()

oView:AddGrid("GPEA840_VTMP", oStructRF1, "GPEA840_MTMP" )
oStructRF1:RemoveField( "TMP_FILIAL" )
oStructRF1:RemoveField( "TMP_MAT" )

// Criacao do GRID - RFC (Sintetico RRA) //
oStructRFC := FWFormStruct(2, "RFC")
oView:AddGrid("GPEA840_VRFC", oStructRFC, "GPEA840_MRFC" )
oStructRFC:RemoveField( "RFC_FILIAL" )
oStructRFC:RemoveField( "RFC_MAT" )
oStructRFC:RemoveField( "RFC_EMPRES" )

// Desenho da Tela //
oView:CreateHorizontalBox("SRA_HEAD", 12)
oView:CreateHorizontalBox("TMP_GRID", 25)
oView:CreateHorizontalBox("RFC_GRID", 63)

oView:CreateVerticalBox( 'RFC_IDCMPL', 100, 'RFC_GRID' )

oView:SetOwnerView( "GPEA840_VSRA", "SRA_HEAD" )
oView:SetOwnerView( "GPEA840_VTMP", "TMP_GRID" )
oView:SetOwnerView( "GPEA840_VRFC", "RFC_IDCMPL" )                    

oView:EnableTitleView( "GPEA840_VTMP", OemToAnsi(STR0008) ) //"Complementos Trabalhistas"
oView:EnableTitleView( "GPEA840_VRFC", OemToAnsi(STR0009) ) //"Itens dos complementos trabalhistas"

Return oView

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё DefStrModel	ЁAutorЁ  Leandro Drumond  Ё Data Ё03/07/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMonta estrutura temporaria							      	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA840                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function DefStrModel( cAlias )

Local aArea    := GetArea()
Local bValid   := { || }
Local bWhen    := { || }
Local bRelac   := { || }


oStruct := FWFormModelStruct():New()

//-------------------------------------------------------------------
// Tabela
//-------------------------------------------------------------------
oStruct:AddTable( 	cAlias		                					, ;	// [01] Alias da tabela
					StrTokArr( "TMP_FILIAL+TMP_IDCMPL", ' + ' ) 	, ;	// [02] Array com os campos que correspondem a primary key
					"Complementos" )               					// [03] DescriГЦo da tabela


//-------------------------------------------------------------------
// Indices
//-------------------------------------------------------------------
oStruct:AddIndex( 	1	      						, ;     // [01] Ordem do indice
					"01"   							, ;     // [02] ID
					"TMP_FILIAL+TMP_IDCMPL"    		, ;     // [03] Chave do indice
					"Filial+Complemento" 			, ;     // [04] DescriГЦo do indice
					""       						, ;    	// [05] ExpressЦo de lookUp dos campos de indice (SIX_F3)
					"" 								, ;    	// [06] Nickname do indice
					.T. )      								// [07] Indica se o indice pode ser utilizado pela interface

//-------------------------------------------------------------------
// Campos
//-------------------------------------------------------------------
bValid := { |A,B,C,D| FwInitCpo(A,B,C), lRetorno := .T., FwCloseCpo( A, B, C, lRetorno ), lRetorno }

bWhen  := NIL
bRelac := NIL
				//Titulo ,ToolTip,Id do Field	,Tipo	,Tamanho		,Decimal,Valid,When	,Combo	,Obrigatorio	,Init	,Chave	,Altera	,Virtual
oStruct:AddField(STR0010,STR0010,'TMP_FILIAL'	,'C'	,FWGETTAMFILIAL	,0	,bValid,bWhen	,{}		,.F.			,bRelac	,NIL	,NIL	,.F.)   //Filial
oStruct:AddField(STR0017,STR0017,'TMP_MAT'		,'C'	,6				,0	,bValid,bWhen	,{}		,.F.			,bRelac	,NIL	,NIL	,.F.)	//Matricula
oStruct:AddField(STR0011,STR0011,'TMP_IDCMPL'	,'C'	,6				,0	,bValid,bWhen	,{}		,.F.			,bRelac	,NIL	,NIL	,.F.)	//Complemento
oStruct:AddField(STR0012,STR0012,'TMP_DESC'		,'C'	,50				,0	,bValid,bWhen	,{}		,.F.			,bRelac	,NIL	,NIL	,.F.)	//Descricao
oStruct:AddField(STR0013,STR0013,'TMP_PRONUM'	,'C'	,6				,0	,bValid,bWhen	,{}		,.F.			,bRelac	,NIL	,NIL	,.F.)	//Processo
oStruct:AddField(STR0014,STR0014,'TMP_AAMMI'	,'C'	,6				,0	,bValid,bWhen	,{}		,.F.			,bRelac	,NIL	,NIL	,.F.)	//Mes/Ano Inicial
oStruct:AddField(STR0015,STR0015,'TMP_AAMMF'	,'C'	,6				,0	,bValid,bWhen	,{}		,.F.			,bRelac	,NIL	,NIL	,.F.)	//Mes/Ano Final
oStruct:AddField(STR0016,STR0016,'TMP_TPARC'	,'N'	,2				,0	,bValid,bWhen	,{}		,.F.			,bRelac	,NIL	,NIL	,.F.)	//Parcelas

RestArea( aArea )

Return oStruct

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё DefStrView		ЁAutorЁ  Leandro Drumond  Ё Data Ё22/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMonta estrutura temporaria							      	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM910                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function DefStrView()
Local oStruct   := FWFormViewStruct():New()
               //Campo			,Ordem	,Titulo		,Descricao	,Help,Tipo 	,Picture               	,PictVar,F3,Editavel,Folder	,Group	,Combo	,Tam.Combo 	, Init. , Virtual
oStruct:AddField('TMP_FILIAL'	,'01'	,STR0010	,STR0010	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_MAT'		,'02'	,STR0017	,STR0017	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_IDCMPL'	,'03'	,STR0011	,STR0011	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_DESC'		,'04'	,STR0012	,STR0012	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_PRONUM'	,'05'	,STR0013	,STR0013	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_AAMMI'	,'06'	,STR0014	,STR0014	,NIL ,'C'	,'999999'				,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_AAMMF'	,'07'	,STR0015	,STR0015	,NIL ,'C'	,'999999'				,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_TPARC'	,'08'	,STR0016	,STR0016	,NIL ,'N'	,'99'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)

Return oStruct

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GPEA840Commit  ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁGravacao das informacoes com as validacoes pertinentes      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA840                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function GPEA840Commit(oModel)

Local nOperation

__oModelCopy:DeActivate()

nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE

	FWFormCommit(oModel)
	
// Tratamento de exclusЦo
ElseIf nOperation == MODEL_OPERATION_DELETE
	
	FWFormCommit(oModel)

EndIf
	
Return( .T. )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gpa840SRAStru	ЁAutorЁ  Leandro Drumond  Ё Data Ё20/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSelecionar os campos para a estrutura do SRA                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA840                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpa840SRAStru( cCampo )
	Local lRet := .F.
	
	cCampo := AllTrim( cCampo )
	If cCampo $ 'RA_MAT*RA_NOME*RA_ADMISSA' 
		lRet := .T.
	EndIf
	
Return lRet

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gp840ActMod	ЁAutorЁLeandro Drumond    Ё Data Ё04/07/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁReplicando o Model para comparacao dos dados                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA840                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gp840ActMod(oModel)
	Local nOperation	:= oModel:GetOperation()
	
	__oModelCopy:= FWLoadModel("GPEA840")
	__oModelCopy:SetOperation(nOperation)
	__oModelCopy:SetActivate({|| .T.}) 
	__oModelCopy:Activate() 
	
Return( .T. )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё When_NotEdit   ЁAutorЁ  Leandro Drumond  Ё Data Ё20/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁPermite somente digitacao em inclusao                       Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA840                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function When_NotEdit(oStruct, cModel)
	Local lRet	:= .T.
	
	Local nCpyLines
	
	Local oCpyStru := __oModelCopy:GetModel( cModel )
	
	nCpyLines	:= oCpyStru:Length()
	                                   
	If oStruct:GetLine() <= nCpyLines .And. !oStruct:IsInserted()
		lRet := .F.
	EndIf

Return( lRet )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fCriaTMP  		ЁAutorЁ  Leandro Drumond  Ё Data Ё03/07/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCria o arquivo temporario							      	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA840                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fCriaTMP()
	Local aArea     := GetArea()
Local aCampos   := {}

Local cAliasTRB := "TMP"
Local aOrdem := {}
	
aAdd(aCampos, {'TMP_FILIAL'	, "C", FWGETTAMFILIAL		, 0})	
aAdd(aCampos, {'TMP_MAT'	, "C", TamSx3("RA_MAT")[1]	, 0})
aAdd(aCampos, {'TMP_IDCMPL'	, "C", 6					, 0})
aAdd(aCampos, {'TMP_DESC'	, "C", 50					, 0})
aAdd(aCampos, {'TMP_PRONUM'	, "C", 6					, 0})
aAdd(aCampos, {'TMP_AAMMI'	, "C", 6					, 0})
aAdd(aCampos, {'TMP_AAMMF'	, "C", 6					, 0})
aAdd(aCampos, {'TMP_TPARC'	, "N", 2					, 0})

If Select(cAliasTRB)>0
	dbSelectArea(cAliasTRB)
	dbCloseArea()
EndIf

//Efetua a criacao do arquivo temporario
oTmpTable := FWTemporaryTable():New(cAliasTRB)
oTmpTable:SetFields( aCampos ) 
	
aOrdem	:=	{"TMP_FILIAL","TMP_MAT","TMP_IDCMPL"}

oTmpTable:AddIndex("IND", aOrdem)
oTmpTable:Create() 

RestArea( aArea )

Return cAliasTRB

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fDelTMP   		ЁAutorЁ  Leandro Drumond  Ё Data Ё03/07/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁExclui o arquivo temporario							      	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA840                                                     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддadminдддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fDelTMP(cAlias)
Local aArea := GetArea()

If oTmpTable <> Nil   
	oTmpTable:Delete()  
	oTmpTable := Nil 
EndIf

RestArea(aArea)

Return .T.

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fLoadRF1  		ЁAutorЁ  Leandro Drumond  Ё Data Ё03/07/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCarrega dados da RF1      							      	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA840                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fLoadRF1( cAlias )
Local cIdCmpl	:= ''
Local lRet 		:= .T.
If Select(cAlias)>0
	dbSelectArea(cAlias)
	dbCloseArea()
	fDelTMP(cAlias)
	cAlias := fCriaTMP()
EndIf

DbSelectArea("RF1")
DbSetOrder(RetOrdem("RF1","RF1_FILIAL+RF1_IDCMPL"))

DbSelectArea("RFC")
DbSetOrder(RetOrdem("RFC","RFC_FILIAL+RFC_MAT+RFC_IDCMPL"))

If RFC->(DbSeek(SRA->RA_FILIAL+SRA->RA_MAT))
	While(RFC->(!Eof() .and. RFC_FILIAL + RFC_MAT == SRA->RA_FILIAL+SRA->RA_MAT ))
 		If cIdCmpl <> RFC->RFC_IDCMPL
	 		If RF1->(dbSeek(xFilial("RF1")+RFC->RFC_IDCMPL))
				Reclock( cAlias, .T.)
				(cAlias)->TMP_FILIAL 	:= SRA->RA_FILIAL
				(cAlias)->TMP_MAT 		:= SRA->RA_MAT
				(cAlias)->TMP_IDCMPL 	:= RF1->RF1_IDCMPL
				(cAlias)->TMP_DESC 		:= RF1->RF1_DESC
				(cAlias)->TMP_PRONUM	:= RF1->RF1_PRONUM
				(cAlias)->TMP_AAMMI 	:= RF1->RF1_AAMMI
				(cAlias)->TMP_AAMMF 	:= RF1->RF1_AAMMF
				(cAlias)->TMP_TPARC 	:= RF1->RF1_TPARC
			EndIf
			cIdCmpl := RFC->RFC_IDCMPL
		EndIf
		RFC->(DbSkip())
	EndDo
Else
	lRet := .F.
	Help( ,, STR0018,,STR0019,1,0 )  //Atencao // NЦo hА dados para serem exibidos
EndIf

Return lRet

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCriacao do Menu do Browse.                                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA840                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.GPEA840" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.GPEA840" 		OPERATION 4 ACCESS 0				//'Alterar'  
	ADD OPTION aRotina TITLE STR0020  ACTION 'A840Gera()'			OPERATION 4 ACCESS 0 				//'Gerar Registros'

Return aRotina


//**************************************************************
/*/{Protheus.doc} A840Carga
FunГЦo para carregar dados da tabela temporАria no grid do modelo.
@author		esther.viveiro
@since		17/08/2048
@version	P12.1.17

@sample 	A840Carga( oGrid )
@param	    oGrid 	Obejto tipo grid onde os dados serЦo carregados.
@return		aRet, array, conteЗdo a ser carregado no grid.
/*/
Static Function A840Carga(oGrid)
Local aRet 	:= {}
Local cAliasTMP := "TMP"

/*
[n] 
[n][1] ExpN: Id do registro (RecNo)
[n][2] Array com os dados, os dados devem seguir exatamente a mesma ordem da estrutura de dados
*/
DbSelectArea(cAliasTMP)
DbSetOrder(RetOrdem("TMP","TMP_FILIAL+TMP_MAT+TMP_IDCMPL"))
TMP->(DbGoTop())
	nLinha := 1
	While TMP->(!Eof())
		aAdd(aRet, {nLinha, {TMP->TMP_FILIAL,TMP->TMP_MAT,TMP->TMP_IDCMPL,TMP->TMP_DESC,TMP->TMP_PRONUM,TMP->TMP_AAMMI,TMP->TMP_AAMMF,TMP->TMP_TPARC}})
		TMP->(DbSkip())
		nLinha++
	EndDo

Return aRet

/*/{Protheus.doc} A840Gera
	(Gera registros de RRA de valores negociados sem incidencias)
	@type  Function
	@author Emerson Grassi Rocha
	@since 10/09/2020
	@version 1.0
	@return Nil
/*/
Function A840Gera()

Local aArea 	:= GetArea()	// Area atual

Private cPerg 	:= 'GPA840'

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Carrega parametros.														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
// MV_PAR01 - Complemento Trab.?
// MV_PAR02 - Filial
// MV_PAR03 - C.Custo
// MV_PAR04 - Matricula
// MV_PAR05 - Nome
// MV_PAR06 - SituaГЦo
// MV_PAR07 - Periodo
// MV_PAR08 - Verba

dbSelectArea("SX1")
dbSetOrder(1)

If SX1->(dbSeek(cPerg))
	Pergunte( cPerg, .F. )
Else
	Help("", 1, OemToAnsi(STR0018), Nil, STR0021, 1, 0 ) // "Atencao" // 'Grupo de Perguntas "GPA840" deve ser criado."'
	Return
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta tela de dialogo.													Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCadastro	:= OemToAnsi( STR0001 ) //'ManutenГЦo de RRA'

cDescricao 	:= OemToAnsi( STR0022 ) //'GeraГЦo de RRA'

bProcesso 	:= {|oSelf| GPRRAGRV(oSelf) }
//cFilAnt 	:= cFilAnterior

tNewProcess():New( "GPEA840", cCadastro, bProcesso, cDescricao, cPerg,,.T.,20,cDescricao,.T.)

RestArea( aArea )

Return Nil

/*/{Protheus.doc} GpRRAGrv
	(Grava registros de RRA na RFC)
	@type  Function
	@author Emerson Grassi Rocha
	@since 10/09/2020
	@version 1.0
	@return Nil
/*/
Static Function GpRRAGrv(oSelf)

	Local aArea 	:= GetArea()
	Local aLogRFC	:= {}
	Local aTitleLog	:= {}
	Local cIdCmpl	:= MV_PAR01
	Local cSitFunc	:= MV_PAR06
	Local cPeriodo	:= MV_PAR07
	Local cVerba	:= MV_PAR08
	Local cFilAux	:= ''
	Local cFilRF1	:= ''
	Local nParcelas	:= 0
	Local nPos		:= 0
	Local cAliasSRA	:= "QSRA"
	Local cSit		:= ""
	Local cMatAux	:= ""
	Local cCC		:= ""
	Local nParc		:= 1	//Verificar
	Local cEmpAnt	:= ""
	Local nValor	:= 0
	Local cProcesso	:= ""
	Local cRoteiro	:= ""
	Local cItem		:= ""
	Local cCLVL		:= ""
	Local cDepto	:= ""
	Local cPosto	:= ""
	Local dDataArq	
	Local dDataPag
	Local cFilRange	:= ""
	Local cCCRange	:= ""
	Local cMatRange	:= ""
	Local cNomeRange:= ""
	Local cSitRange	:= ""
	Local cWhere	:= ""
	Local _nQtd		:= 0
	Local lVazio 	:= .T.

	MakeSqlExpr( "GPCR11" ) //Transforma perguntas do tipo Range em expressao SQL

	cFilRange	:=	MV_PAR02
	cCCRange	:= 	MV_PAR03
	cMatRange	:= 	MV_PAR04
	cNomeRange	:= 	MV_PAR05
	cSitRange	:= 	MV_PAR06

	If Empty( cIdCmpl )
		Help("", 1, OemToAnsi(STR0018), Nil, STR0023, 1, 0 ) //"Atencao" // 'Preencha o parБmetro "Complemento"'
		Return
	EndIf

	If Empty(cPeriodo)
		Help("", 1, OemToAnsi(STR0018), Nil, STR0024, 1, 0 ) //"Atencao" // 'Preencha o parБmetro "Periodo"'
		Return
	EndIf
	
	DbSelectArea('RF1')
	RF1->(DbSetOrder(1))

	If !Empty(cFilRange)
		cWhere += cFilRange + " AND "
	EndIf

	If !Empty(cCCRange)
		cWhere += cCCRange + " AND "
	EndIf

	If !Empty(cMatRange)
		cWhere += cMatRange + " AND "
	EndIf

	If !Empty(cNomeRange)
		cWhere += cNomeRange + " AND "
	EndIf

	For nPos := 1 To Len(cSitFunc)
		If substr(cSitFunc,nPos,1) <> "*"
			cSit += "'" + substr(cSitFunc,nPos,1) + "',"
		EndIf
	Next nPos
	If Len(cSit)>1
		cSit := substr(cSit,1,Len(cSit)-1)
		cWhere += " RA_SITFOLH IN("+cSit+") AND "
		nPos := 0
	EndIf

	cWhere		:= "%" + cWhere + "%"

	If Select("QSRA") > 0
		QSRA->( dbCloseArea() )
	EndIF

	BeginSql alias cAliasSRA
	SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_CC,RA_ITEM,RA_CLVL,RA_DEPTO, R_E_C_N_O_ RECNO,RA_DEPIR
	FROM %table:SRA% SRA
	WHERE  %exp:cWhere%
	SRA.%notDel%
	ORDER BY RA_FILIAL, RA_MAT
	EndSql

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona ponteiros do arquivo SRA.										Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea(cAliasSRA)
	Count To _nQtd
	dbSelectArea(cAliasSRA)
	(cAliasSRA)->( DbGoTop() )

	oSelf:SetRegua1(_nQtd)

	Do While (cAliasSRA)->( !Eof() )

		dbSelectArea("SRA")
		SRA->(dbGoto((cAliasSRA)->RECNO))
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Movimenta cursor para movimentacao da barra.							Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		oSelf:IncRegua1( (cAliasSRA)->RA_FILIAL + ' - ' + (cAliasSRA)->RA_MAT + ' - ' + If(lOfusca, "", (cAliasSRA)->RA_NOME) )

		If cFilAux <> (cAliasSRA)->RA_FILIAL
		
			If !Empty(cIdCmpl) .and. ( cFilRF1 <> xFilial('RF1',(cAliasSRA)->RA_FILIAL) .or. Empty(cFilAux) )
				cFilRF1 := xFilial('RF1',(cAliasSRA)->RA_FILIAL)

				If !RF1->((DbSeek(cFilRF1+cIdCmpl)))
					If ( nPos := Ascan( aTitleLog, {|x| x == STR0026 + ": " } ) ) == 0 	//"Complemento nЦo encontrado"
						aAdd(aTitleLog, STR0026 + ": " ) 								//"Complemento nЦo encontrado"
					    aAdd(aLogRFC,{cFilRF1 + " - " + cIdCmpl})
					Else
						aAdd(aLogRFC[nPos],cFilRF1 + " - " + cIdCmpl)
					EndIf
					(cAliasSRA)->(dbSkip())
					Loop
				Else
					nParcelas := Max(RF1->RF1_TPARC,1)
				EndIf
			EndIf
			cFilAux := (cAliasSRA)->RA_FILIAL
			cMatAux	:= (cAliasSRA)->RA_MAT
			cCC		:= (cAliasSRA)->RA_CC
			cItem	:= (cAliasSRA)->RA_ITEM
			cCLVL	:= (cAliasSRA)->RA_CLVL
			cDepto	:= (cAliasSRA)->RA_DEPTO
		EndIf

		// InformaГУes do SRD
		dbSelectArea("SRD")
		dbSetOrder(1)	
		SRD->(dbSetOrder(1))
		If SRD->(dbSeek(xFilial("SRD")+cMatAux+cPeriodo+cVerba))
			nValor		:= SRD->RD_VALOR
			dDataArq	:= SRD->RD_DATARQ	
			dDataPag	:= SRD->RD_DATPGT 	
			cProcesso	:= SRD->RD_PROCES
			cRoteiro	:= SRD->RD_ROTEIR
			cPosto 		:= SRD->RD_POSTO
			cEmpAnt		:= SRD->RD_EMPRESA

			// Grava o Id Complementar na SRD para geraГЦo do RRA
			RecLock("SRD", .F.)
				SRD->RD_IDCMPL	:= cIdCmpl
			SRD->(MsUnLock())
		Else
			(cAliasSRA)->(dbSkip())
			Loop
		EndIf

		//Grava RFC
		dbSelectArea("RFC")
		dbSetOrder(1)

		lNewRFC := !(DbSeek(cFilAux+cMatAux+cIdCmpl+cPeriodo))
		RecLock("RFC",lNewRFC)
			RFC->RFC_FILIAL	:= cFilAux
			RFC->RFC_MAT	:= cMatAux
			RFC->RFC_PD		:= cVerba
			RFC->RFC_CC		:= cCC
			RFC->RFC_SEQ	:= AllTrim(Str(nParc))
			RFC->RFC_EMPRES	:= cEmpAnt
			RFC->RFC_PARC	:= nParc
			RFC->RFC_MESES	:= nParcelas
			RFC->RFC_VALOR	:= nValor
			RFC->RFC_IDCMPL	:= cIdCmpl
			RFC->RFC_DATARQ	:= dDataArq
			RFC->RFC_DATPGT	:= dDataPag
			RFC->RFC_RRA	:= "1"
			RFC->RFC_PROCES	:= cProcesso
			RFC->RFC_ROTEIR	:= cRoteiro
			RFC->RFC_PERIOD	:= cPeriodo
			RFC->RFC_ITEM	:= cItem
			RFC->RFC_CLVL	:= cCLVL
			RFC->RFC_DEPTO	:= cDepto
		RFC->(MsUnLock())

		lVazio := .F.
				
		(cAliasSRA)->(DbSkip())
	EndDo
	(cAliasSRA)->(DbCloseArea())

	If lVazio
		aAdd(aTitleLog, STR0027) //"Nenhum registro de RRA foi gerado"
		aAdd(aLogRFC,{' '})
	EndIf

	//зддддддддддддддддддддддддддддддддддддд©
	//Ё Chama rotina de Log de Ocorrencias. Ё
	//юддддддддддддддддддддддддддддддддддддды
	fMakeLog(aLogRFC,aTitleLog,,,"DS"+DTOS(dDataBase),STR0025,"M","P",,.F.) //"LOG de Ocorrencias"

	RestArea(aArea)

Return Nil
