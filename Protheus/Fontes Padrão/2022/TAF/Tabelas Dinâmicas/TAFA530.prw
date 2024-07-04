#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA530.CH"


/*/{Protheus.doc} TAFA530
Tabela autocontida criada para evento do e-Social S-5011
@author Victor A. Barbosa
@since 24/01/2018
@version 1.0
@type function
/*/
Function TAFA530()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription( STR0001 ) //"Indicativos de Comercialização"
oBrw:SetAlias( "V3F" )
oBrw:SetMenuDef( "TAFA530" )
V3F->( DBSetOrder( 1 ) )
oBrw:Activate()

Return 


/*/{Protheus.doc} MenuDef
Definição do menu da rotina
@author Victor A. Barbosa
@since 24/01/2018
@version 1.0
@type function
/*/
Static Function MenuDef()
Return xFunMnuTAF( "TAFA530",,,, .T. )


/*/{Protheus.doc} MenuDef
Modelo da rotina
@author Victor A. Barbosa
@since 24/01/2018
@version 1.0
@type function
/*/
Static Function ModelDef()

Local oStruV3F := FwFormStruct( 1, "V3F" )
Local oModel   := MpFormModel():New( "TAFA530" )

oModel:AddFields( "MODEL_V3F", /*cOwner*/, oStruV3F )
oModel:GetModel ( "MODEL_V3F" ):SetPrimaryKey( { "V3F_FILIAL", "V3F_ID" } )

Return( oModel )

/*/{Protheus.doc} MenuDef
View da rotina
@author Victor A. Barbosa
@since 24/01/2018
@version 1.0
@type function
/*/
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA530" )
Local oStruV3F := FwFormStruct( 2, "V3F" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_V3F", oStruV3F, "MODEL_V3F" )
oView:EnableTitleView( "VIEW_V3F", STR0001 ) //"Indicativos de Comercialização"
oView:CreateHorizontalBox( "FIELDSV3F", 100 )
oView:SetOwnerView( "VIEW_V3F", "FIELDSV3F" )

Return( oView )


/*/{Protheus.doc} MenuDef
Função que carrega os dados da autocontida de acordo com a versão do cliente
@author Victor A. Barbosa
@since 24/01/2018
@version 1.0
@type function
/*/
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody		:=	{}
Local aRet		:=	{}

nVerAtu := 1031.32

If nVerEmp < nVerAtu
	aAdd( aHeader, "V3F_FILIAL" )
	aAdd( aHeader, "V3F_ID" )
	aAdd( aHeader, "V3F_CODIGO" )
	aAdd( aHeader, "V3F_DESCRI" )
	aAdd( aHeader, "V3F_VALIDA" )

    aAdd( aBody, { "", "000001", "1" , "1 - dose diária de ruído"                                                   , "" } )
    aAdd( aBody, { "", "000002", "2" , "2 - decibel linear (dB (linear))"                                           , "" } )
    aAdd( aBody, { "", "000003", "3" , "3 - decibel (C) (dB(C))"                                                    , "" } )
    aAdd( aBody, { "", "000004", "4" , "4 - decibel (A) (dB(A))"                                                    , "" } )
    aAdd( aBody, { "", "000005", "5" , "5 - metro por segundo ao quadrado (m/s2)"                                   , "" } )
    aAdd( aBody, { "", "000006", "6" , "6 - metro por segundo elevado a 1,75 (m/s1,75)"                             , "" } )
    aAdd( aBody, { "", "000007", "7" , "7 - parte de vapor ou gás por milhão de partes de ar contaminado (ppm)"     , "" } )
    aAdd( aBody, { "", "000008", "8" , "8 - miligrama por metro cúbico de ar (mg/m3)"                               , "" } )
    aAdd( aBody, { "", "000009", "9" , "9 - fibra por centímetro cúbico (f/cm3)"                                    , "" } )
    aAdd( aBody, { "", "000010", "10", "10 - grau Celsius (ºC)"                                                     , "" } )
    aAdd( aBody, { "", "000011", "11", "11 - metro por segundo (m/s)"                                               , "" } )
    aAdd( aBody, { "", "000012", "12", "12 - porcentual"                                                            , "" } )
    aAdd( aBody, { "", "000013", "13", "13 - lux (lx)"                                                              , "" } )
    aAdd( aBody, { "", "000014", "14", "14 - unidade formadora de colônias por metro cúbico (ufc/m3)"               , "" } )
    aAdd( aBody, { "", "000015", "15", "15 - dose diária"                                                           , "" } )
    aAdd( aBody, { "", "000016", "16", "16 - dose mensal"                                                           , "" } )
    aAdd( aBody, { "", "000017", "17", "17 - dose trimestral"                                                       , "" } )
    aAdd( aBody, { "", "000018", "18", "18 - dose anual"                                                            , "" } )
    aAdd( aBody, { "", "000019", "19", "19 - watt por metro quadrado (W/m2)"                                        , "" } )
    aAdd( aBody, { "", "000020", "20", "20 - ampère por metro (A/m)"                                                , "" } )
    aAdd( aBody, { "", "000021", "21", "21 - militesla (mT)"                                                        , "" } )
    aAdd( aBody, { "", "000022", "22", "22 - microtesla (?T)"                                                       , "" } )
    aAdd( aBody, { "", "000023", "23", "23 - miliampère (mA)"                                                       , "" } )
    aAdd( aBody, { "", "000024", "24", "24 - quilovolt por metro (kV/m)"                                            , "" } )
    aAdd( aBody, { "", "000025", "25", "25 - volt por metro (V/m)"                                                  , "" } )
    aAdd( aBody, { "", "000026", "26", "26 - joule por metro quadrado (J/m2)"                                       , "" } )
    aAdd( aBody, { "", "000027", "27", "27 - milijoule por centímetro quadrado (mJ/cm2)"                            , "" } )
    aAdd( aBody, { "", "000028", "28", "28 - milisievert (mSv)"                                                     , "" } )
    aAdd( aBody, { "", "000029", "29", "29 - milhão de partículas por decímetro cúbico (mppdc)"                     , "" } )
    aAdd( aBody, { "", "000030", "30", "30 - umidade relativa do ar (UR (%))"                                       , "" } )
	
    aAdd( aRet, { aHeader, aBody } )
EndIf

Return aRet 
