#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM910.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    	Ё GPEM910    Ё Autor Ё Leandro Drumond       	      Ё Data Ё 22/06/12 Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o 	Ё ManutenГЦo de RRA - Dissidio                                 			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   	Ё GPEM910()                                                    			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      	Ё Generico ( DOS e Windows )                                   			Ё╠╠
╠╠цдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.               			Ё╠╠
╠╠цдддддддддддддбддддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador  Ё Data     Ё FNC	    Ё  Motivo da Alteracao                      Ё╠╠
╠╠цдддддддддддддеддддддддддеддддддддддддддддеддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁCecilia Car. Ё15/05/2014ЁTPPCSB          ЁIncluido o fonte da 11 para a 12 e efetuadaЁ╠╠
╠╠Ё             Ё          Ё                Ё a limpeza.                                Ё╠╠
╠╠JТnatas A.   Ё05/01/2017 Ё    MRH-4752    ЁCompatibilizaГЦo fontes DIRF P118->P1217   Ё╠╠
╠╠              Ё          Ё                ЁIncluida nova tela de Pensao(GPEM561 ) ref.Ё╠╠
╠╠Ё             Ё          Ё                Ё2016 em diante e retirada a informaГЦo de  Ё╠╠
╠╠Ё             Ё          Ё                Ёpensao da tela principal da DIRF, RRA e    Ё╠╠
╠╠Ё             Ё          Ё                ЁinformaГУes complementares                 Ё╠╠
╠╠ЁPaulo O I    Ё13/04/2017ЁDRHPAG-239      ЁMelhoria - remoГЦo de dependencias do ctreeЁ╠╠
╠╠юдддддддддддддаддддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function GPEM910()

Local oMBrowse
Local cFiltraRh

oMBrowse := FWMBrowse():New()

oMBrowse:SetAlias("SRL")
oMBrowse:SetDescription(OemToAnsi("RRA")) //'Cadastro de Complementos Trabalhistas'

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFiltraRh := CHKRH("GPEM910","SRL","1")
oMBrowse:SetFilterDefault( cFiltraRh )

oMBrowse:Activate()

Return   

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ModelDef 		ЁAutorЁ  Leandro Drumond  Ё Data Ё22/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Modelagem da gravacao.                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM910                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ModelDef()

Local oModel
Local oStructSRL
Local oStructRFI
Local oStructSR4

If Type("lUpdRRA") == "U"
	lUpdRRA := .T.
EndIf

// Criacao do Objeto de Modelagem de dados da tabela SR4 //
oModel     := MPFormModel():New("GPEM910", NIL, NIL, {|oModel| GPEM910Commit(oModel)})
oModel:SetDescription( OemToAnsi(STR0001) ) //'Rendimentos Recebidos Acumuldamente'

// Estrutura de campos do Model //
oStructSRL := FWFormStruct(1, "SRL", { |cCampo| Gpm910SRLStru(cCampo) })
oModel:AddFields("GPEM910_MSRL", NIL, oStructSRL)
oModel:GetModel( "GPEM910_MSRL" ):SetDescription( OemToAnsi(STR0001) ) //'Rendimentos Recebidos Acumuldamente'
oModel:GetModel( "GPEM910_MSRL" ):SetOnlyQuery(.T.)
oModel:GetModel( "GPEM910_MSRL" ):SetOnlyView(.T.)

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Estrutura de campos do Model (RFI)Complementos Trabalhistas			 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oStructRFI := FWFormStruct(1, "RFI")          

oModel:AddGrid("GPEM910_MRFI", "GPEM910_MSRL", oStructRFI,, { |oModel| .T. },, { |oModel| .T. } )
oModel:GetModel( "GPEM910_MRFI" ):SetDescription( OemToAnsi(STR0008) ) //'Complementos Trabalhistas'
oModel:GetModel( "GPEM910_MRFI" ):SetNoInsertLine( .T. )
oModel:GetModel( "GPEM910_MRFI" ):SetNoDeleteLine( .T. )

oStructRFI:SetProperty( '*' , MODEL_FIELD_WHEN, { || .T. } )

oStructRFI:SetProperty( 'RFI_MAT'  , MODEL_FIELD_OBRIGAT,.F.)
oStructRFI:SetProperty( 'RFI_TIPOFJ'  ,MODEL_FIELD_OBRIGAT,.F.)
oStructRFI:SetProperty( 'RFI_CPFCGC'  ,MODEL_FIELD_OBRIGAT,.F.)
oStructRFI:SetProperty( 'RFI_CODRET'  ,MODEL_FIELD_OBRIGAT,.F.)
oStructRFI:SetProperty( 'RFI_IDCMPL'  ,MODEL_FIELD_OBRIGAT,.F.)   
oStructRFI:SetProperty( 'RFI_RETRRA'  ,MODEL_FIELD_OBRIGAT,.F.)

If !lUpdRRA
	oModel:GetModel( "GPEM910_MRFI" ):SetNoUpdateLine(.T.)
EndIf

oModel:SetRelation( "GPEM910_MRFI", { { 'RFI_FILIAL', 'xFilial("RFI",SRL->RL_FILIAL)' } , { 'RFI_MAT', 'SRL->RL_MAT' } , {'RFI_CODRET' , 'SRL->RL_CODRET'} }, RFI->( IndexKey( 1 ) ) )
oModel:SetPrimaryKey({})

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Estrutura de campos do Model (SR4)Sintetica RRA						 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
oStructSR4 := DefStrModel()

oStructSR4:SetProperty( 'TMP_RENDTR', MODEL_FIELD_WHEN, { |oModel| When_NotEdit(oModel, "GPEM910_MSR4") } )
oStructSR4:SetProperty( 'TMP_RENDIS', MODEL_FIELD_WHEN, { |oModel| When_NotEdit(oModel, "GPEM910_MSR4") } )
oStructSR4:SetProperty( 'TMP_PREVOF', MODEL_FIELD_WHEN, { |oModel| When_NotEdit(oModel, "GPEM910_MSR4") } )
oStructSR4:SetProperty( 'TMP_PENSAO', MODEL_FIELD_WHEN, { |oModel| When_NotEdit(oModel, "GPEM910_MSR4") } )
oStructSR4:SetProperty( 'TMP_IMPRET', MODEL_FIELD_WHEN, { |oModel| When_NotEdit(oModel, "GPEM910_MSR4") } )
oStructSR4:SetProperty( 'TMP_DESPJU', MODEL_FIELD_WHEN, { |oModel| When_NotEdit(oModel, "GPEM910_MSR4") } )
oStructSR4:SetProperty( 'TMP_QTDMES', MODEL_FIELD_WHEN, { |oModel| When_NotEdit(oModel, "GPEM910_MSR4") } )

oModel:AddGrid("GPEM910_MSR4", "GPEM910_MRFI" /*cOwner*/, oStructSR4 , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,{|oGrid| fLoadSR4(oGrid)}/*bLoad*/)

oModel:GetModel( "GPEM910_MSR4" ):SetDescription( OemToAnsi(STR0009) )//'Rendimentos'
oModel:GetModel( "GPEM910_MSR4" ):SetOptional( .T. )
oModel:GetModel( "GPEM910_MSR4" ):SetNoInsertLine( .T. )
oModel:GetModel( "GPEM910_MSR4" ):SetNoDeleteLine( .T. )

If !lUpdRRA
	oModel:GetModel( "GPEM910_MSR4" ):SetNoUpdateLine(.T.)
EndIf

oModel:SetRelation( "GPEM910_MSR4", { { "TMP_MAT", 'RFI_MAT' } , { "TMP_IDCMPL", 'RFI_IDCMPL' } , { "TMP_CODRET", 'RFI_CODRET' } } )

Return( oModel )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef  		ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Interface com o Usuario                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM910                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ViewDef()

Local oView 
Local oModel
Local oStructSRL
Local oStructRFI
Local oStructSR4

// Vincular o View ao Model //
oModel := FWLoadModel("GPEM910")	

// Criacao da Interface //
oView := FWFormView():New()
oView:SetModel(oModel)

// Criacao do Cabecalho - SRL (Funcionario) //
oStructSRL := FWFormStruct(2, "SRL", { |cCampo| Gpm910SRLStru(cCampo) })
oStructSRL:SetNoFolder()
oView:AddField("GPEM910_VSRL", oStructSRL, "GPEM910_MSRL" )

// Criacao do GRID - RFI (Complementos trabalhistas) //
oStructRFI := FWFormStruct(2, 'RFI')
oView:AddGrid("GPEM910_VRFI", oStructRFI, "GPEM910_MRFI" )

oStructRFI:RemoveField("RFI_FILIAL")
oStructRFI:RemoveField("RFI_MAT")
oStructRFI:RemoveField("RFI_CODRET")
oStructRFI:RemoveField("RFI_RETRRA")
oStructRFI:RemoveField("RFI_CPFCGC")
oStructRFI:RemoveField("RFI_TIPOFJ")
oStructRFI:RemoveField("RFI_ORIGEM")
oStructRFI:RemoveField("RFI_PAIS")
oStructRFI:RemoveField("RFI_NIFEX")

// Criacao do GRID - SR4 (Sintetico RRA) //
oStructSR4 := DefStrView( 'SR4' )

oView:AddGrid("GPEM910_VSR4", oStructSR4, "GPEM910_MSR4" )
oStructSR4:RemoveField( "TMP_FILIAL" )
oStructSR4:RemoveField( "TMP_MAT" )
oStructSR4:RemoveField( "TMP_MES" )
oStructSR4:RemoveField( "TMP_IDCMPL" )
oStructSR4:RemoveField( "TMP_CODRET" )
oStructSR4:RemoveField( "TMP_ANO" )
oStructSR4:RemoveField( "TMP_UFIR" )
If cAno >="2016"
	oStructSR4:RemoveField( "TMP_PENSAO" )
EndIf
oView:SetFieldAction( 'TMP_RENDTR', { |oView, cIDView, cField, xValue| SR4_When( oView, cIDView, cField, xValue, oModel ) } ) 
oView:SetFieldAction( 'TMP_RENDIS', { |oView, cIDView, cField, xValue| SR4_When( oView, cIDView, cField, xValue, oModel ) } ) 
oView:SetFieldAction( 'TMP_PREVOF', { |oView, cIDView, cField, xValue| SR4_When( oView, cIDView, cField, xValue, oModel ) } ) 
oView:SetFieldAction( 'TMP_PENSAO', { |oView, cIDView, cField, xValue| SR4_When( oView, cIDView, cField, xValue, oModel ) } ) 
oView:SetFieldAction( 'TMP_IMPRET', { |oView, cIDView, cField, xValue| SR4_When( oView, cIDView, cField, xValue, oModel ) } ) 
oView:SetFieldAction( 'TMP_DESPJU', { |oView, cIDView, cField, xValue| SR4_When( oView, cIDView, cField, xValue, oModel ) } ) 

// Desenho da Tela //
oView:CreateHorizontalBox("SRL_HEAD", 12)
oView:CreateHorizontalBox("RFI_GRID", 25)
oView:CreateHorizontalBox("TMP_GRID", 63)

oView:CreateVerticalBox( 'TMP_IDCMPL', 100, 'TMP_GRID' )

oView:SetOwnerView( "GPEM910_VSRL", "SRL_HEAD" )
oView:SetOwnerView( "GPEM910_VRFI", "RFI_GRID" )
oView:SetOwnerView( "GPEM910_VSR4", "TMP_IDCMPL" )

oView:EnableTitleView( "GPEM910_VRFI", OemToAnsi(STR0008) ) //"Complementos Trabalhistas"
oView:EnableTitleView( "GPEM910_VSR4", OemToAnsi(STR0009) ) //"Rendimentos"

Return oView

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё DefStrModel	ЁAutorЁ  Leandro Drumond  Ё Data Ё22/06/2012Ё
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
Static Function DefStrModel(  )

Local aArea    := GetArea()
Local bValid   := { || }
Local bWhen    := { || }
Local bRelac   := { || }


oStruct := FWFormModelStruct():New()


//-------------------------------------------------------------------
// Campos
//-------------------------------------------------------------------
bValid := { |A,B,C,D| FwInitCpo(A,B,C), lRetorno := .T., FwCloseCpo( A, B, C, lRetorno ), lRetorno }

bWhen  := NIL
bRelac := NIL
				//Titulo ,ToolTip,Id do Field	,Tipo, Tamanho				, Decimal,Valid,When	,Combo	,Obrigatorio	,Init	,Chave	,Altera	,Virtual
oStruct:AddField(STR0010, STR0010, 'TMP_FILIAL'	, 'C', FWGETTAMFILIAL		, 0, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)   //Filial
oStruct:AddField(STR0011, STR0011, 'TMP_MAT'	, 'C', TamSx3("RA_MAT")[1]	, 0, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)	//MatrМcula
oStruct:AddField(STR0012, STR0012, 'TMP_MES'	, 'C', 2					, 0, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)	//MЙs
oStruct:AddField(STR0012, STR0012, 'TMP_DESMES'	, 'C', 10					, 0, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .T.)	//MЙs
oStruct:AddField(STR0013, STR0013, 'TMP_IDCMPL'	, 'C', 6					, 0, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)	//Id.Complemento
oStruct:AddField(STR0014, STR0014, 'TMP_DTPGTO'	, 'D', 8					, 0, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)	//Data
oStruct:AddField(STR0015, STR0015, 'TMP_RENDTR'	, 'N', 15					, 2, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)	//Rendimento TributАvel
oStruct:AddField(STR0016, STR0016, 'TMP_RENDIS'	, 'N', 15					, 2, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)	//Rend. Isento MolИstia Grave
oStruct:AddField(STR0017, STR0017, 'TMP_PREVOF'	, 'N', 15					, 2, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)	//PrevidЙncia Oficial
oStruct:AddField(STR0018, STR0018, 'TMP_PENSAO'	, 'N', 15					, 2, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)	//PensЦo AlimentМcia
oStruct:AddField(STR0019, STR0019, 'TMP_IMPRET'	, 'N', 15					, 2, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)	//Imposto Retido
oStruct:AddField(STR0020, STR0020, 'TMP_DESPJU'	, 'N', 15					, 2, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)	//Despesas AГЦo Judicial
oStruct:AddField(STR0021, STR0021, 'TMP_QTDMES'	, 'N', 2					, 0, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)  	//Quantidade de Meses
oStruct:AddField(STR0022, STR0022, 'TMP_CODRET'	, 'C', 4					, 0, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)	//Cod.Ret.
oStruct:AddField(STR0036, STR0036, 'TMP_UFIR'	, 'N', 15					, 2, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)  	//UFIR
oStruct:AddField(STR0037, STR0037, 'TMP_ANO'	, 'C', 4					, 0, bValid, bWhen, {}, .F., bRelac, NIL, NIL, .F.)	//Ano

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
Static Function DefStrView(  )
Local oStruct   := FWFormViewStruct():New()
               //Campo			,Ordem	,Titulo		,Descricao	,Help,Tipo 	,Picture               	,PictVar,F3,Editavel,Folder	,Group	,Combo	,Tam.Combo 	, Init. , Virtual
oStruct:AddField('TMP_FILIAL'	,'01'	,STR0010	,STR0010	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_MAT'		,'02'	,STR0011	,STR0011	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_MES'		,'03'	,STR0012	,STR0012	,NIL ,'C'	,'99'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_DESMES'	,'04'	,STR0012	,STR0012	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_IDCMPL'	,'05'	,STR0013	,STR0013	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_DTPGTO'	,'06'	,STR0014	,STR0014	,NIL ,'D'	,''						,NIL	,'',.T.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_RENDTR'	,'07'	,STR0015	,STR0015	,NIL ,'N'	,'@E 999,999,999,999.99',NIL	,'',.T.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_RENDIS'	,'08'	,STR0016	,STR0016	,NIL ,'N'	,'@E 999,999,999,999.99',NIL	,'',.T.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_PREVOF'	,'09'	,STR0017	,STR0017	,NIL ,'N'	,'@E 999,999,999,999.99',NIL	,'',.T.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_PENSAO'	,'10'	,STR0018	,STR0018	,NIL ,'N'	,'@E 999,999,999,999.99',NIL	,'',.T.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_IMPRET'	,'11'	,STR0019	,STR0019	,NIL ,'N'	,'@E 999,999,999,999.99',NIL	,'',.T.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_DESPJU'	,'12'	,STR0020	,STR0020	,NIL ,'N'	,'@E 999,999,999,999.99',NIL	,'',.T.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_QTDMES'	,'13'	,STR0021	,STR0021	,NIL ,'N'	,'99'					,NIL	,'',.T.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_CODRET'  	,'14'	,STR0022	,STR0022	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.T.)
oStruct:AddField('TMP_UFIR'  	,'15'	,STR0036	,STR0036	,NIL ,'C'	,'@E 999,999,999,999.99',NIL	,'',.F.		,''		,''		,{}		,0			,''		,.T.)
oStruct:AddField('TMP_ANO'  	,'16'	,STR0037	,STR0037	,NIL ,'C'	,'9999'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.T.)

Return oStruct


/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fLoadSR4  		ЁAutorЁ  Leandro Drumond  Ё Data Ё22/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCarrega dados da SR4      							      	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM910                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fLoadSR4( oGrid )
Local aArea  	:= GetArea()
Local aAreaSR4	:= SR4->( GetArea() )
Local aAreaRFI	:= RFI->( GetArea() )
Local aMes   	:= {STR0023,STR0024,STR0025,STR0026,STR0027,STR0028,;	//"Janeiro	"###"Fevereiro  "###"Marco      "###"Abril      "###"Maio       "###"Junho      "
                 	STR0029,STR0030,STR0031,STR0032,STR0033,STR0034}	//"Julho	"###"Agosto     "###"Setembro   "###"Outubro    "###"Novembro   "###"Dezembro   "
Local cIndTemp	:= ''
Local dDataPag	:= CtoD('')
Local nX
Local nRendTr	:= 0
Local nRendis	:= 0
Local nPreVof	:= 0
Local nPensao	:= 0
Local nImpRet	:= 0
Local nDespJu	:= 0
Local nMeses	:= 0
Local nPos		:= 0
Local aRet		:= {}
Local oModel	:= oGrid:GetModel()
Local oRFI		:= oModel:getmodel("GPEM910_MRFI")
DbSelectArea("SR4")
DbSetOrder(RetOrdem("SR4","R4_FILIAL+R4_MAT+R4_IDCMPL+R4_CODRET+R4_MES+R4_ANO+R4_TIPOREN"))

If RFI->(DbSeek(xFilial('RFI')+SRL->RL_MAT+oRFI:GEtvalue("RFI_IDCMPL")+oRFI:GEtvalue("RFI_CODRET")))
	While(RFI->(!Eof() .and. RFI_FILIAL + RFI_MAT+RFI_IDCMPL+RFI_CODRET == xFilial("RFI")+SRL->RL_MAT+oRFI:GEtvalue("RFI_IDCMPL")+oRFI:GEtvalue("RFI_CODRET") ))
		For nX:= 1 to 12
			Aadd(aRet, {0, {	RFI->RFI_FILIAL,;
					RFI->RFI_MAT,;
				 	StrZero( nX , 02 ),;
				 	aMes[nX],;
				 	RFI->RFI_IDCMPL,;
				 	,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	RFI->RFI_CODRET,;
				 	0,;
				 	cAno } } )	
		Next nX
		//Cria linha TOTAL
		Aadd(aRet, {0, {	RFI->RFI_FILIAL,;
					RFI->RFI_MAT,;
				 	StrZero( 13 , 02 ),;
				 	STR0035,;
				 	RFI->RFI_IDCMPL,;
				 	,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	RFI->RFI_CODRET,;
				 	0,;
				 	cAno } } )	
 		If SR4->(dbSeek(xFilial("SR4")+RFI->RFI_MAT+RFI->RFI_IDCMPL+RFI->RFI_CODRET))
			While(SR4->(!Eof() .and. R4_FILIAL + R4_MAT + R4_IDCMPL + R4_CODRET == xFilial("SR4")+RFI->RFI_MAT+RFI->RFI_IDCMPL+RFI->RFI_CODRET ))
				If ( SR4->R4_TIPOREN $ 'A1|B2|B3|C2|D2|I1') .and. SR4->R4_ANO == cAno
					aRet[Val(SR4->R4_MES)][1] 	:= SR4->(Recno()) 
					aRet[Val(SR4->R4_MES)][2][6]:= SR4->R4_DTPGT
					aRet[Val(SR4->R4_MES)][2][7]+= If( SR4->R4_TIPOREN == 'A1' , SR4->R4_VALOR , 0 )
					aRet[Val(SR4->R4_MES)][2][8]+= If( SR4->R4_TIPOREN == 'I1' , SR4->R4_VALOR , 0 )
					aRet[Val(SR4->R4_MES)][2][9]+= If( SR4->R4_TIPOREN == 'B2' , SR4->R4_VALOR , 0 )
					aRet[Val(SR4->R4_MES)][2][10]+= If( SR4->R4_TIPOREN == 'C2' , SR4->R4_VALOR , 0 )
					aRet[Val(SR4->R4_MES)][2][11]+= If( SR4->R4_TIPOREN == 'D2' , SR4->R4_VALOR , 0 )
					aRet[Val(SR4->R4_MES)][2][12]+= If( SR4->R4_TIPOREN == 'B3' , SR4->R4_VALOR , 0 )
					aRet[Val(SR4->R4_MES)][2][13]:= SR4->R4_MESES
					aRet[Val(SR4->R4_MES)][2][16]:=  SR4->R4_ANO
					nRendTr	+= If( SR4->R4_TIPOREN == 'A1' , SR4->R4_VALOR , 0 )
					nRendis	+= If( SR4->R4_TIPOREN == 'I1' , SR4->R4_VALOR , 0 )
					nPreVof	+= If( SR4->R4_TIPOREN == 'B2' , SR4->R4_VALOR , 0 )
					nPensao	+= If( SR4->R4_TIPOREN == 'C2' , SR4->R4_VALOR , 0 )
					nImpRet	+= If( SR4->R4_TIPOREN == 'D2' , SR4->R4_VALOR , 0 )
					nDespJu	+= If( SR4->R4_TIPOREN == 'B3' , SR4->R4_VALOR , 0 )
					nMeses	:= SR4->R4_MESES
				EndIf
				SR4->(DbSkip())
			EndDo
             //Inclui TOTAIS
			aRet[13][2][6]:= dDataPag
			aRet[13][2][7]+= nRendTr
			aRet[13][2][8]+= nRendis
			aRet[13][2][9]+= nPreVof
			aRet[13][2][10]+= nPensao
			aRet[13][2][11]+= nImpRet
			aRet[13][2][12]+= nDespJu
			aRet[13][2][13]:= nMeses
		EndIf
		
	   	RFI->(DbSkip())
	EndDo
Else
For nX:= 1 to 12
		Aadd(aRet, {0, {	Space(FwGetTamFilial),;
					Space(TamSX3("RL_MAT")[1]),;
				 	StrZero( nX , 02 ),;
				 	aMes[nX],;
				 	Space(TamSX3("R4_IDCMPL")[1]),;
				 	,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	 Space(TamSX3("RL_CODRET")[1]),;
				 	0,;
				 	cAno } } )	
	Next nX
	Aadd(aRet, {0, {	Space(FwGetTamFilial),;
					Space(TamSX3("RL_MAT")[1]),;
				 	StrZero( 13 , 02 ),;
				 	STR0035,;
				 	Space(TamSX3("R4_IDCMPL")[1]),;
				 	,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	0,;
				 	 Space(TamSX3("RL_CODRET")[1]),;
				 	0,;
				 	cAno } } )	
EndIf
	

RestArea(aAreaSR4)
RestArea(aAreaRFI)
RestArea(aArea)

Return aRet

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GPEM910Commit  ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁGravacao das informacoes com as validacoes pertinentes      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM910                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function GPEM910Commit(oModel)

Local oModelRFI	:= oModel:GetModel( 'GPEM910_MRFI' )
oModelRFI:LoadValue( 'RFI_FILIAL', SRL->RL_FILIAL )
oModelRFI:LoadValue( 'RFI_MAT'	 , SRL->RL_MAT )
oModelRFI:LoadValue( 'RFI_CODRET', SRL->RL_CODRET )
oModelRFI:LoadValue( 'RFI_CPFCGC', SRL->RL_CPFCGC )
oModelRFI:LoadValue( 'RFI_ORIGEM', "1" )
oModelRFI:LoadValue( 'RFI_RETRRA', "1889" )
oModelRFI:LoadValue( 'RFI_TIPOFJ', SRL->RL_TIPOFJ )

fGravaSR4(oModel)
FWFormCommit(oModel)
	
Return( .T. )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё SR4_When		ЁAutorЁ  Leandro Drumond  Ё Data Ё25/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁWhen				                                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM910                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function SR4_When( oView, cIDView, cField, xValue, oModel )
Local lRet 	 	:= .T.
Local nX
Local nTotal 	:= 0
Local nLines 	:= 0
Local nLineBkp	:= 0
Local oModelTMP := oModel:GetModel( 'GPEM910_MSR4' )
Local oViewTMP	:= FWViewActive()

nLineBkp		:= oModelTMP:nLine

If !(oModelTMP:nLine == 13)

	nLines := oModelTMP:Length() - 1
	
	For nX := 1  to nLines
		oModelTMP:GoLine( nX )
	    If !oModelTMP:IsDeleted()
	    	nTotal += oModelTMP:GetValue( cField )
	    EndIf
	Next nX
	
	oModelTMP:GoLine(nLines+1)
	oModelTMP:LoadValue(cField , nTotal)
	oModelTMP:GoLine(nLineBkp)
	oViewTMP:Refresh()
	
EndIf

Return lRet
/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gpm910SRLStru	ЁAutorЁ  Leandro Drumond  Ё Data Ё20/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSelecionar os campos para a estrutura do SRL                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM910                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpm910SRLStru( cCampo )
	Local lRet := .F.
	
	cCampo := AllTrim( cCampo )
	If cCampo $ 'RL_MAT*RL_BENEFIC' 
		lRet := .T.
	EndIf
	
Return lRet

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё When_NotEdit   ЁAutorЁ  Leandro Drumond  Ё Data Ё26/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁVerifica permissao para inclusao/alteracao                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM910                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function When_NotEdit(oModel, cModel)
	Local lRet	:= .T.
	
	//Nao permite digitacao na linha TOTAIS
	If oModel:GetLine() == 13
		lRet := .F.
	EndIf

Return( lRet )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё fGravaSR4      ЁAutorЁ  Leandro Drumond  Ё Data Ё26/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁTransfere informacaoes do temporario para SR4               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM910                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function fGravaSR4(oModel)
Local aArea		:= GetArea()
Local aTipoRen	:= {"A1","I1","B2","C2","D2","B3"}
Local aCpoRen	:= {"TMP_RENDTR","TMP_RENDIS","TMP_PREVOF","TMP_PENSAO","TMP_IMPRET","TMP_DESPJU"}
Local oModelTMP := oModel:GetModel( 'GPEM910_MSR4' )
Local oModelRFI	:= oModel:GetModel( 'GPEM910_MRFI' )
Local cFilRFI	:= oModelRFI:GetValue( 'RFI_FILIAL' )
Local cMat		:= oModelRFI:GetValue( 'RFI_MAT' )
Local cIdCmpl	:= oModelRFI:GetValue( 'RFI_IDCMPL' )
Local cCodRet	:= oModelRFI:GetValue( 'RFI_CODRET' )
Local cCpfCgc	:= oModelRFI:GetValue( 'RFI_CPFCGC' )
Local cOrigem	:= oModelRFI:GetValue( 'RFI_ORIGEM' )
Local nLines	:= oModelTMP:Length() - 1
Local nX		:= 0
Local nY		:= 0
Local nValor	:= 0
Local lUpdate	:= .F.

DbSelectArea('SR4')
DbSetOrder(RetOrdem("SR4","R4_FILIAL+R4_MAT+R4_IDCMPL+R4_CODRET+R4_MES+R4_ANO+R4_TIPOREN"))

For nX := 1  to nLines
	oModelTMP:GoLine( nX )
    If !oModelTMP:IsDeleted()
		For nY := 1 to Len(aTipoRen)
			lUpdate	:= SR4->(DbSeek(cFilRFI+cMat+cIdcmpl+cCodRet+oModelTMP:GetValue( 'TMP_MES' )+oModelTMP:GetValue( 'TMP_ANO' )+aTipoRen[nY]))
			nValor 	:= oModelTMP:GetValue( aCpoRen[nY] )
			
			If nValor > 0
				Reclock( "SR4", !lUpdate)
				If !lUpdate
					SR4->R4_FILIAL 	:= cFilRFI
					SR4->R4_MAT		:= cMat
					SR4->R4_CPFCGC	:= cCpfCgc
					SR4->R4_MES		:= oModelTMP:GetValue( 'TMP_MES' )
					SR4->R4_ANO		:= oModelTMP:GetValue( 'TMP_ANO' )
					SR4->R4_TIPOREN	:= aTipoRen[nY]
					SR4->R4_CODRET	:= cCodRet
					SR4->R4_UFIR	:= oModelTMP:GetValue( 'TMP_UFIR' )
					SR4->R4_ORIGEM 	:= cOrigem
					SR4->R4_IDCMPL	:= cIdCmpl
				EndIf
				
				SR4->R4_DTPGT	:= oModelTMP:GetValue( 'TMP_DTPGTO' )
				SR4->R4_MESES 	:= oModelTMP:GetValue( 'TMP_QTDMES' )
				SR4->R4_VALOR	:= nValor
				

				SR4->(MsUnlock())
			ElseIf lUpdate
				Reclock( "SR4", !lUpdate)
				SR4->(dbDelete())
				SR4->(MsUnlock())
			EndIf		
			
		Next nY
    EndIf
Next nX
	
RestArea(aArea)

Return Nil

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCriacao do Menu do Browse.                                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEM910                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.GPEM910" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.GPEM910" 		OPERATION 4 ACCESS 0				//'Alterar'  

Return aRotina
