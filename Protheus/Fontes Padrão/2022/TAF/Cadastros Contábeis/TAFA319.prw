#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA319.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA319
Identificação do Período e Forma de Apuração do IRPJ e da CSLL das 
 Empresas Tributadas pelo Lucro Real

@author Anderson Costa
@since 19/05/2014
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA319()

Local oBrw := FWmBrowse():New()

oBrw:SetDescription(STR0001) //"Identificação da Apuração IRPJ e CSLL Empresa Lucro Real"
oBrw:SetAlias('CEA')
oBrw:SetMenuDef( 'TAFA319' )
CEA->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf319Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA319" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCEA := FWFormStruct( 1, 'CEA' )
Local oStruCEB := FWFormStruct( 1, 'CEB' )
Local oStruCEC := FWFormStruct( 1, 'CEC' )
Local oModel := MPFormModel():New( 'TAFA319' , , , {|oModel| SaveModel(oModel)})

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruCEA:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oStruCEB:SetProperty( "CEB_REGECF", MODEL_FIELD_INIT, { |oModel| Iif( oModel:GetId() == "MODEL_CEB_01", "01",;
                                                                  Iif( oModel:GetId() == "MODEL_CEB_02", "02",;
                                                                  Iif( oModel:GetId() == "MODEL_CEB_03", "03",;
                                                                  Iif( oModel:GetId() == "MODEL_CEB_04", "04",;
                                                                  Iif( oModel:GetId() == "MODEL_CEB_05", "05",;
                                                                  Iif( oModel:GetId() == "MODEL_CEB_06", "07",;
                                                                  Iif( oModel:GetId() == "MODEL_CEB_07", "08", "09" ) ) ) ) ) ) ) } )

oStruCEB:SetProperty( "CEB_CODLAN", MODEL_FIELD_VALID , { |oModel| Iif( oModel:GetId() == "MODEL_CEB_01", xFunVldCmp( "CH6", 2, PadR( "N500", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ) ),;
                                                                    Iif( oModel:GetId() == "MODEL_CEB_02", xFunVldCmp( "CH6", 2, PadR( "N600", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ) ),;
                                                                    Iif( oModel:GetId() == "MODEL_CEB_03", xFunVldCmp( "CH6", 2, PadR( "N610", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ) ),;
                                                                    Iif( oModel:GetId() == "MODEL_CEB_04", xFunVldCmp( "CH6", 2, PadR( "N620", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ) ),;
                                                                    Iif( oModel:GetId() == "MODEL_CEB_05", xFunVldCmp( "CH6", 2, PadR( CH6->CH6_CODREG, TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ) ),;
                                                                    Iif( oModel:GetId() == "MODEL_CEB_06", xFunVldCmp( "CH6", 2, PadR( "N650", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ) ),;
                                                                    Iif( oModel:GetId() == "MODEL_CEB_07", xFunVldCmp( "CH6", 2, PadR( "N660", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ) ), xFunVldCmp( "CH6", 2, PadR( "N670", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ) ) ) ) ) ) ) ) ) } )

oStruCEB:AddTrigger( "CEB_CODLAN", "CEB_DCODLA",, { |oModel| Iif( oModel:GetId() == "MODEL_CEB_01", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N500", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_DESCRI" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEB_02", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N600", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_DESCRI" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEB_03", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N610", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_DESCRI" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEB_04", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N620", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_DESCRI" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEB_05", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( CH6->CH6_CODREG, TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_DESCRI" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEB_06", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N650", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_DESCRI" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEB_07", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N660", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_DESCRI" ), Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N670", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_DESCRI" ) ) ) ) ) ) ) ) } )

oStruCEB:AddTrigger( "CEB_CODLAN", "CEB_IDCODL",, { |oModel| Iif( oModel:GetId() == "MODEL_CEB_01", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N500", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_ID" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEB_02", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N600", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_ID" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEB_03", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N610", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_ID" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEB_04", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N620", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_ID" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEB_05", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( CH6->CH6_CODREG, TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_ID" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEB_06", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N650", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_ID" ),;
                                                              Iif( oModel:GetId() == "MODEL_CEB_07", Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N660", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_ID" ), Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "N670", TamSX3( "CH6_CODREG" )[1] ) + oModel:GetValue( "CEB_CODLAN" ), "CH6_ID" ) ) ) ) ) ) ) ) } )

oModel:AddFields('MODEL_CEA', /*cOwner*/, oStruCEA)

oModel:AddGrid("MODEL_CEB_01","MODEL_CEA",oStruCEB)
oModel:GetModel("MODEL_CEB_01"):SetOptional(.T.)
oModel:GetModel("MODEL_CEB_01"):SetLoadFilter({{"CEB_REGECF", "'01'"}})
oModel:GetModel("MODEL_CEB_01"):SetUniqueLine({"CEB_REGECF", "CEB_IDCODL"})

oModel:AddGrid("MODEL_CEB_02","MODEL_CEA",oStruCEB)
oModel:GetModel("MODEL_CEB_02"):SetOptional(.T.)
oModel:GetModel("MODEL_CEB_02"):SetLoadFilter({{"CEB_REGECF", "'02'"}})
oModel:GetModel("MODEL_CEB_02"):SetUniqueLine({"CEB_REGECF", "CEB_IDCODL"})

oModel:AddGrid("MODEL_CEB_03","MODEL_CEA",oStruCEB)
oModel:GetModel("MODEL_CEB_03"):SetOptional(.T.)
oModel:GetModel("MODEL_CEB_03"):SetLoadFilter({{"CEB_REGECF", "'03'"}})
oModel:GetModel("MODEL_CEB_03"):SetUniqueLine({"CEB_REGECF", "CEB_IDCODL"})

oModel:AddGrid("MODEL_CEB_04","MODEL_CEA",oStruCEB)
oModel:GetModel("MODEL_CEB_04"):SetOptional(.T.)
oModel:GetModel("MODEL_CEB_04"):SetLoadFilter({{"CEB_REGECF", "'04'"}})
oModel:GetModel("MODEL_CEB_04"):SetUniqueLine({"CEB_REGECF", "CEB_IDCODL"})

oModel:AddGrid("MODEL_CEB_05","MODEL_CEA",oStruCEB)
oModel:GetModel("MODEL_CEB_05"):SetOptional(.T.)
oModel:GetModel("MODEL_CEB_05"):SetLoadFilter({{"CEB_REGECF", "'05'"}})
oModel:GetModel("MODEL_CEB_05"):SetUniqueLine({"CEB_REGECF", "CEB_IDCODL"})

oModel:AddGrid("MODEL_CEB_06","MODEL_CEA",oStruCEB)
oModel:GetModel("MODEL_CEB_06"):SetOptional(.T.)
oModel:GetModel("MODEL_CEB_06"):SetLoadFilter({{"CEB_REGECF", "'07'"}})
oModel:GetModel("MODEL_CEB_06"):SetUniqueLine({"CEB_REGECF", "CEB_IDCODL"})

oModel:AddGrid("MODEL_CEB_07","MODEL_CEA",oStruCEB)
oModel:GetModel("MODEL_CEB_07"):SetOptional(.T.)
oModel:GetModel("MODEL_CEB_07"):SetLoadFilter({{"CEB_REGECF", "'08'"}})
oModel:GetModel("MODEL_CEB_07"):SetUniqueLine({"CEB_REGECF", "CEB_IDCODL"})

oModel:AddGrid("MODEL_CEB_08","MODEL_CEA",oStruCEB)
oModel:GetModel("MODEL_CEB_08"):SetOptional(.T.)
oModel:GetModel("MODEL_CEB_08"):SetLoadFilter({{"CEB_REGECF", "'09'"}})
oModel:GetModel("MODEL_CEB_08"):SetUniqueLine({"CEB_REGECF", "CEB_IDCODL"})

oModel:AddGrid("MODEL_CEC","MODEL_CEA",oStruCEC)
oModel:GetModel("MODEL_CEC"):SetOptional(.T.)
oModel:GetModel("MODEL_CEC"):SetUniqueLine({"CEC_SEQREG"})
oModel:GetModel('MODEL_CEC'):SetNoInsertLine(.T.)

oModel:GetModel('MODEL_CEA'):SetPrimaryKey({'CEA_DTINI','CEA_DTFIN','CEA_IDPERA'})

oModel:SetRelation("MODEL_CEB_01",{ {"CEB_FILIAL","xFilial('CEB')"}, {"CEB_ID","CEA_ID"} },CEB->(IndexKey(1)) )
oModel:SetRelation("MODEL_CEB_02",{ {"CEB_FILIAL","xFilial('CEB')"}, {"CEB_ID","CEA_ID"} },CEB->(IndexKey(1)) )
oModel:SetRelation("MODEL_CEB_03",{ {"CEB_FILIAL","xFilial('CEB')"}, {"CEB_ID","CEA_ID"} },CEB->(IndexKey(1)) )
oModel:SetRelation("MODEL_CEB_04",{ {"CEB_FILIAL","xFilial('CEB')"}, {"CEB_ID","CEA_ID"} },CEB->(IndexKey(1)) )
oModel:SetRelation("MODEL_CEB_05",{ {"CEB_FILIAL","xFilial('CEB')"}, {"CEB_ID","CEA_ID"} },CEB->(IndexKey(1)) )
oModel:SetRelation("MODEL_CEB_06",{ {"CEB_FILIAL","xFilial('CEB')"}, {"CEB_ID","CEA_ID"} },CEB->(IndexKey(1)) )
oModel:SetRelation("MODEL_CEB_07",{ {"CEB_FILIAL","xFilial('CEB')"}, {"CEB_ID","CEA_ID"} },CEB->(IndexKey(1)) )
oModel:SetRelation("MODEL_CEB_08",{ {"CEB_FILIAL","xFilial('CEB')"}, {"CEB_ID","CEA_ID"} },CEB->(IndexKey(1)) )

oModel:SetRelation("MODEL_CEC",{ {"CEC_FILIAL","xFilial('CEC')"}, {"CEC_ID","CEA_ID"} },CEC->(IndexKey(1)) )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 19/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FWLoadModel( 'TAFA319' )
Local oStruCEA := FWFormStruct( 2, 'CEA' )

Local oStruCEB1 := FWFormStruct( 2, 'CEB' )
Local oStruCEB2 := FWFormStruct( 2, 'CEB' )
Local oStruCEB3 := FWFormStruct( 2, 'CEB' )
Local oStruCEB4 := FWFormStruct( 2, 'CEB' )
Local oStruCEB5 := FWFormStruct( 2, 'CEB' )
Local oStruCEB6 := FWFormStruct( 2, 'CEB' )
Local oStruCEB7 := FWFormStruct( 2, 'CEB' )
Local oStruCEB8 := FWFormStruct( 2, 'CEB' )

Local oStruCEC := FWFormStruct( 2, 'CEC' )
Local oView    := FWFormView():New()

oStruCEB1:SetProperty( "CEB_CODLAN" , MVC_VIEW_LOOKUP , "CH6A" )
oStruCEB2:SetProperty( "CEB_CODLAN" , MVC_VIEW_LOOKUP , "CH6B" )
oStruCEB3:SetProperty( "CEB_CODLAN" , MVC_VIEW_LOOKUP , "CH6C" )
oStruCEB4:SetProperty( "CEB_CODLAN" , MVC_VIEW_LOOKUP , "CH6D" )
oStruCEB5:SetProperty( "CEB_CODLAN" , MVC_VIEW_LOOKUP , "CH6E" )
oStruCEB6:SetProperty( "CEB_CODLAN" , MVC_VIEW_LOOKUP , "CH6F" )
oStruCEB7:SetProperty( "CEB_CODLAN" , MVC_VIEW_LOOKUP , "CH6G" )
oStruCEB8:SetProperty( "CEB_CODLAN" , MVC_VIEW_LOOKUP , "CH6H" )

/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel )

oView:AddField( 'VIEW_CEA', oStruCEA, 'MODEL_CEA' )
oView:EnableTitleView( 'VIEW_CEA', STR0001 )    //"Identificação da Apuração IRPJ e CSLL Empresa Lucro Real"

oView:AddGrid("VIEW_CEB1",oStruCEB1,"MODEL_CEB_01")
oView:EnableTitleView("VIEW_CEB1",STR0002) //"Demonstração do Lucro da Exploração"
oView:AddGrid("VIEW_CEB2",oStruCEB2,"MODEL_CEB_02")
oView:EnableTitleView("VIEW_CEB2",STR0003) //"Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real"
oView:AddGrid("VIEW_CEB3",oStruCEB3,"MODEL_CEB_03")
oView:EnableTitleView("VIEW_CEB3",STR0004) //"Informações da Base de Cálculo dos incentivos Fiscais"
oView:AddGrid("VIEW_CEB4",oStruCEB4,"MODEL_CEB_04")
oView:EnableTitleView("VIEW_CEB4",STR0005) //"Cálculo do IRPJ Mensal por Estimativa"
oView:AddGrid("VIEW_CEB5",oStruCEB5,"MODEL_CEB_05")
oView:EnableTitleView("VIEW_CEB5",STR0006) //"Cálculo do IRPJ Com Base no Lucro Real"
oView:AddGrid("VIEW_CEB6",oStruCEB6,"MODEL_CEB_06")
oView:EnableTitleView("VIEW_CEB6",STR0007) //"Base Cálc. CSLL após Compens. Base Negativa"
oView:AddGrid("VIEW_CEB7",oStruCEB7,"MODEL_CEB_07")
oView:EnableTitleView("VIEW_CEB7",STR0008) //"Cálculo da CSLL Mensal por Estimativa"
oView:AddGrid("VIEW_CEB8",oStruCEB8,"MODEL_CEB_08")
oView:EnableTitleView("VIEW_CEB8",STR0009) //"Cálculo da CSLL Com Base no Lucro Real"

oView:AddGrid("VIEW_CEC",oStruCEC,"MODEL_CEC")
oView:AddIncrementField( "VIEW_CEC", "CEC_SEQREG" )
oView:EnableTitleView("VIEW_CEC",STR0011) //"Inf. Base de Cálc. Incentivos Fiscais"

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",28)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") //CEA 

oView:CreateHorizontalBox("PAINEL_INFERIOR",72)
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR") //CEB - CEC  

oView:AddSheet("FOLDER_INFERIOR","ABA01",STR0011) //"Base de Cálculo do IRPJ sobre o Lucro Real após as Compensações de Prejuízos"
oView:CreateHorizontalBox("PAINEL_INFO_BC",100,,,"FOLDER_INFERIOR","ABA01")
oView:CreateFolder("FOLDER_INFO_BC","PAINEL_INFO_BC") // CEC

oView:AddSheet("FOLDER_INFERIOR","ABA02",STR0010) //"Registros Genéricos – Bloco N" 
oView:CreateHorizontalBox("PAINEL_BLOCO_N",100,,,"FOLDER_INFERIOR","ABA02")
oView:CreateFolder("FOLDER_BLOCO_N","PAINEL_BLOCO_N") //CEB 

oView:AddSheet("FOLDER_BLOCO_N","ABA01",STR0002) //"Demonstração do Lucro da Exploração"
oView:CreateHorizontalBox("PAINEL_1",100,,,"FOLDER_BLOCO_N","ABA01")
oView:AddSheet("FOLDER_BLOCO_N","ABA02",STR0003) //"Cálculo da Isenção e Redução do Imposto Sobre o Lucro Real"
oView:CreateHorizontalBox("PAINEL_2",100,,,"FOLDER_BLOCO_N","ABA02")
oView:AddSheet("FOLDER_BLOCO_N","ABA03",STR0004) //"Informações da Base de Cálculo dos incentivos Fiscais"
oView:CreateHorizontalBox("PAINEL_3",100,,,"FOLDER_BLOCO_N","ABA03")
oView:AddSheet("FOLDER_BLOCO_N","ABA04",STR0005) //"Cálculo do IRPJ Mensal por Estimativa"
oView:CreateHorizontalBox("PAINEL_4",100,,,"FOLDER_BLOCO_N","ABA04")
oView:AddSheet("FOLDER_BLOCO_N","ABA05",STR0006) //"Cálculo do IRPJ Com Base no Lucro Real"
oView:CreateHorizontalBox("PAINEL_5",100,,,"FOLDER_BLOCO_N","ABA05")
oView:AddSheet("FOLDER_BLOCO_N","ABA06",STR0007) //"Base de Cálculo da CSLL após as compensações da Base de Cálculo Negativa"
oView:CreateHorizontalBox("PAINEL_6",100,,,"FOLDER_BLOCO_N","ABA06")
oView:AddSheet("FOLDER_BLOCO_N","ABA07",STR0008) //"Cálculo da CSLL Mensal por Estimativa"
oView:CreateHorizontalBox("PAINEL_7",100,,,"FOLDER_BLOCO_N","ABA07")
oView:AddSheet("FOLDER_BLOCO_N","ABA08",STR0009) //"Cálculo da CSLL Com Base no Lucro Real"
oView:CreateHorizontalBox("PAINEL_8",100,,,"FOLDER_BLOCO_N","ABA08")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CEA', 'PAINEL_PRINCIPAL' )   

oView:SetOwnerView( 'VIEW_CEB1', 'PAINEL_1' ) 
oView:SetOwnerView( 'VIEW_CEB2', 'PAINEL_2' ) 
oView:SetOwnerView( 'VIEW_CEB3', 'PAINEL_3' ) 
oView:SetOwnerView( 'VIEW_CEB4', 'PAINEL_4' ) 
oView:SetOwnerView( 'VIEW_CEB5', 'PAINEL_5' ) 
oView:SetOwnerView( 'VIEW_CEB6', 'PAINEL_6' )
oView:SetOwnerView( 'VIEW_CEB7', 'PAINEL_7' )
oView:SetOwnerView( 'VIEW_CEB8', 'PAINEL_8' )

oView:SetOwnerView( 'VIEW_CEC', 'PAINEL_INFO_BC' ) 

/*-----------------------------------------------------------------------------------
Esconde campos de controle interno
-------------------------------------------------------------------------------------*/
oStruCEA:RemoveField('CEA_ID')
oStruCEA:RemoveField('CEA_IDPERA')

oStruCEB1:RemoveField('CEB_REGECF')
oStruCEB1:RemoveField('CEB_IDCODL')

oStruCEB2:RemoveField('CEB_REGECF')
oStruCEB2:RemoveField('CEB_IDCODL')

oStruCEB3:RemoveField('CEB_REGECF')
oStruCEB3:RemoveField('CEB_IDCODL')

oStruCEB4:RemoveField('CEB_REGECF')
oStruCEB4:RemoveField('CEB_IDCODL')

oStruCEB5:RemoveField('CEB_REGECF')
oStruCEB5:RemoveField('CEB_IDCODL')

oStruCEB6:RemoveField('CEB_REGECF')
oStruCEB6:RemoveField('CEB_IDCODL')

oStruCEB7:RemoveField('CEB_REGECF')
oStruCEB7:RemoveField('CEB_IDCODL')

oStruCEB8:RemoveField('CEB_REGECF')
oStruCEB8:RemoveField('CEB_IDCODL')

If TAFColumnPos( "CEB_ORIGEM" )
	oStruCEB1:RemoveField( "CEB_ORIGEM" )
	oStruCEB2:RemoveField( "CEB_ORIGEM" )
	oStruCEB3:RemoveField( "CEB_ORIGEM" )
	oStruCEB4:RemoveField( "CEB_ORIGEM" )
	oStruCEB5:RemoveField( "CEB_ORIGEM" )
	oStruCEB6:RemoveField( "CEB_ORIGEM" )
	oStruCEB7:RemoveField( "CEB_ORIGEM" )
	oStruCEB8:RemoveField( "CEB_ORIGEM" )
EndIf

oStruCEC:RemoveField('CEC_SEQREG')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Anderson Costa
@Since 19/05/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation	:=	oModel:GetOperation()
Local cRet			:=	.T.
Local nCont		:=	0
Local nI			:=	0

//Conto o número de registros na aba 06
For nI := 1 to Len( oModel:aAllSubmodels[7]:aDataModel )
	If oModel:aAllSubmodels[7]:aDataModel[nI,3] == .F. //Verifico se a linha não está deletada
		nCont++
	EndIf
Next nI

If nCont > 1
	oModel:SetErrorMessage( ,,,,, "A aba 'Base CSLL após Compens. Base Negativa' não pode conter múltiplos registros. ", "Insira apenas um registro de informação nesta aba",, )
	cRet := .F.
Else

	Begin Transaction
		If nOperation == MODEL_OPERATION_UPDATE
			//Função responsável por setar o status do registro para branco
			TAFAltStat( "CEA", " " )
		EndIf

		FwFormCommit( oModel )

	End Transaction

EndIf

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf319Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacos 
caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 19/05/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf319Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""
Local lValida		:= .F.
Local cKey		:= ""
Local nVFinor  := 0
Local nVFINAM  := 0
Local nSubTotal:= 0
Local nVFinor  := 0
Local nPerSub	 := 0
                 
Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := CEA->( Recno() )

lValida := ( CEA->CEA_STATUS $ ( " |1" ) )

If lValida
	
	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(CEA->CEA_DTINI)                                           
		AADD(aLogErro,{"CEA_DTINI","000003","CEA",nRecno}) //STR0003 - "Data inconsistente ou vazia." 
	EndIf
	
	If Empty(CEA->CEA_DTFIN)                                            
		Aadd(aLogErro,{"CEA_DTFIN","000003","CEA",nRecno}) //STR0003 - "Data inconsistente ou vazia." 
	EndIf

	If Empty(CEA->CEA_IDPERA)                                            
		Aadd(aLogErro,{"CEA_IDPERA","000001","CEA",nRecno}) //STR0001 - "Campo inconsistente ou vazio." 
	EndIf
	
	//------------------
	// Consultas padrão
	//------------------
	If !Empty(CEA->CEA_IDPERA)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CEA->CEA_IDPERA
		xVldECFTab("CAH",cChave,1,,@aLogErro,{ "CEA", "CEA_IDPERA", nRecno })
	EndIf	
	
	If CEA->CEA_DTINI > CEA->CEA_DTFIN
		AADD(aLogErro,{"CEA_DTFIN","000032","CEA",nRecno}) //STR0032 - "A data de saldo final dever ser maior ou igual a data saldo inicial."
	Endif
	
	//VALIDA_PERIODO
	xVldECFReg( cAlias,"VALIDA_PERIODO", @aLogErro,{CEA->CEA_DTINI,CEA->CEA_DTFIN,CEA->CEA_IDPERA})

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO CEB³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	CEB->( DBSetOrder(1) )
	
	cKey := CEA->CEA_ID
	If CEB->( MsSeek( xFilial("CEB") + cKey ) )

		Do While !CEB->( Eof() ) .And. cKey == CEB->CEB_ID

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(CEB->CEB_IDCODL)
				AADD(aLogErro,{"CEB_IDCODL","000001","CEA",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty( CEB->CEB_IDCODL )
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CEB->CEB_IDCODL
				xVldECFTab( "CH6", cChave, 1,, @aLogErro, { "CEA", "CEB_CODLAN", nRecno } )
			EndIf

			CEB->( DbSkip() )
		EndDo
	EndIf
	//ÚÄÄÄÄÄÄÄ¿
	//³FIM CEB³
	//ÀÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO CEC³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	CEC->( DBSetOrder(1) )
	cKey := CEA->CEA_ID
	If CEC->( MsSeek( xFilial("CEC") + cKey ) )

		Do While !CEC->( Eof() ) .And. cKey == CEC->CEC_ID

			//---------------------
			// Campos obrigatórios
			//---------------------
			If CEC->CEC_PFINOR == 0
				AADD(aLogErro,{"CEC_PFINOR","000001","CEA",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			
			Elseif CEC->CEC_PFINOR < 0 .OR. CEC->CEC_PFINOR > 100
				AADD(aLogErro,{"CEC_PFINOR","000056","CEA",nRecno}) //STR0056 - "O Valor Percentual deve estar compreendido entre 0 e 100"			
		
			EndIf
			
			If CEC->CEC_PFINAN == 0
				AADD(aLogErro,{"CEC_PFINAN","000001","CEA",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			
			Elseif CEC->CEC_PFINAN < 0 .OR. CEC->CEC_PFINAN > 100
				AADD(aLogErro,{"CEC_PFINAN","000056","CEA",nRecno}) //STR0056 - "O Valor Percentual deve estar compreendido entre 0 e 100"			
		
			EndIf			
			
			nVFinor:= ROUND( ( CEC->CEC_BCALC * CEC->CEC_PFINOR ) / 100 , 2 )
			If CEC->CEC_VFINOR == 0
				AADD(aLogErro,{"CEC_VFINOR","000001","CEA",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			
			Elseif nVFinor <> Round( CEC->CEC_VFINOR , 2 )
				AADD(aLogErro,{"CEC_VFINOR","000057","CEA",nRecno}) //STR0057 - "O 'Val. FINOR' deve corresponder ao resultado da multiplicação de 'Perc. FINOR' por 'B.de Calculo' "   				
			EndIf
			
			nVFINAM:= ROUND( ( CEC->CEC_PFINAN * CEC->CEC_BCALC ) / 100 ,2 )
			If CEC->CEC_VFINAN == 0
				AADD(aLogErro,{"CEC_VFINAN","000001","CEA",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			
			Elseif nVFINAM <> Round(CEC->CEC_VFINAN,2)
				AADD(aLogErro,{"CEC_VFINAN","000059","CEA",nRecno}) //STR0059 - "O 'Val. FINAM' deve corresponder ao resultado da multiplicação de 'Perc. FINAM' por 'B.de Calculo'"   				
			EndIf
			
			nVFUNRES:= ROUND( ( CEC->CEC_PFUNRE * CEC->CEC_BCALC ) / 100 , 2 )
						
			nSubTotal:= ROUND( ( CEC->CEC_VFINAN + CEC->CEC_VFINOR ) , 2 )
						
			nTotal:= ROUND( ( CEC->CEC_VFINOR + CEC->CEC_VFINAN + CEC->CEC_VFUNRE ) , 2 )
			If nTotal == 0
				AADD(aLogErro,{"CEC_TOTAL","000001","CEA",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			
			Elseif nTotal <> Round(CEC->CEC_TOTAL,2)
				AADD(aLogErro,{"CEC_TOTAL","000061","CEA",nRecno}) //STR0061 - "O 'Total' deve corresponder a soma dos valores de 'Val. FINOR', 'Val. FINAM' e 'Val. FUNRES' "   				
			EndIf
			
			nPerSub:= ROUND( ( CEC->CEC_SUBTOT / CEC->CEC_BCALC ) * 100  , 2 )
						
			
			CEC->( DbSkip() )
		EndDo
	EndIf
	//ÚÄÄÄÄÄÄÄ¿
	//³FIM CEC³
	//ÀÄÄÄÄÄÄÄÙ


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "CEA", cStatus )

Else
	aAdd( aLogErro, { "CEA_ID", "000017", "CEA", nRecno } ) //STR0017 - Registro já validado.
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)