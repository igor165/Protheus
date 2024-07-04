#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA578.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA578
Tabela 24 - Agentes Nocivos e Atividades - Aposentadoria Especial

@author Fabio Mendonça
@since 04/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA578()

	Local   oBrw :=  FWmBrowse():New()

	oBrw:SetDescription(STR0001)    //" Agentes Nocivos e Atividades - Aposentadoria Especial "
	oBrw:SetAlias( 'V5Y')
	oBrw:SetMenuDef('TAFA578' )
	oBrw:Activate() 

Return Nil

//-------------------------------------------------------------------      
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio Mendonça
@since 04/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA578" )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio Mendonça
@since 04/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStruV5Y := FwFormStruct( 1, "V5Y" )
    Local oModel   := MpFormModel():New( "TAFA578" )

    oModel:AddFields( "MODEL_V5Y", /*cOwner*/, oStruV5Y )
    oModel:GetModel ( "MODEL_V5Y" ):SetPrimaryKey( { "V5Y_FILIAL", "V5Y_ID" } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio Mendonça
@since 04/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local   oModel      :=  FWLoadModel( 'TAFA578' )
    Local   oStruV5Y    :=  FWFormStruct( 2, 'V5Y' )
    Local   oView       :=  FWFormView():New()

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_V5Y', oStruV5Y, 'MODEL_V5Y' )

    oView:EnableTitleView( 'VIEW_V5Y', STR0001 )    //" Agentes Nocivos e Atividades - Aposentadoria Especial "
    oView:CreateHorizontalBox( 'FIELDSV5Y', 100 )
    oView:SetOwnerView( 'VIEW_V5Y', 'FIELDSV5Y' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida. - Tabela 24

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@author Fabio Mendonça
@since 04/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp as Numeric, nVerAtu as Numeric)

	Local aHeader as Array
	Local aBody   as Array
	Local aRet    as Array

    aHeader := {}
	aBody   := {}
	aRet    := {}

	nVerAtu := 1032.08

	If nVerEmp < nVerAtu

		aAdd( aHeader, "V5Y_FILIAL" )
		aAdd( aHeader, "V5Y_ID"     )
		aAdd( aHeader, "V5Y_CODIGO" )
		aAdd( aHeader, "V5Y_DESCRI" )
		aAdd( aHeader, "V5Y_VALIDA" )
        aAdd( aHeader, "V5Y_ALTCON" )	
		
		aAdd( aBody, { "", "000001" , "01.01.001" , "ARSÊNIO E SEUS COMPOSTOS"                                                                                                                                          , ""} )
		aAdd( aBody, { "", "000002" , "01.02.001" , "ASBESTOS (OU AMIANTO)"                                                                                                                                             , ""} )
		aAdd( aBody, { "", "000003" , "01.03.001" , "BENZENO E SEUS COMPOSTOS TÓXICOS (EXCETO OS ABAIXO ESPECIFICADOS, QUE CONSTAM EXPRESSAMENTE NO ANEXO IV DO DECRETO 3.048/1999)"                                    , ""} )
        aAdd( aBody, { "", "000004" , "01.03.002" , "ESTIRENO (VINILBENZENO)"                                                                                                                                           , ""} )
        aAdd( aBody, { "", "000005" , "01.04.001" , "BERÍLIO E SEUS COMPOSTOS TÓXICOS"                                                                                                                                  , ""} )
        aAdd( aBody, { "", "000006" , "01.05.001" , "BROMO E SEUS COMPOSTOS TÓXICOS"                                                                                                                                    , ""} )
        aAdd( aBody, { "", "000007" , "01.06.001" , "CÁDMIO E SEUS COMPOSTOS TÓXICOS"                                                                                                                                   , ""} )
        aAdd( aBody, { "", "000008" , "01.07.001" , "CARVÃO MINERAL E SEUS DERIVADOS"                                                                                                                                   , ""} )
        aAdd( aBody, { "", "000009" , "01.08.001" , "CHUMBO E SEUS COMPOSTOS TÓXICOS"                                                                                                                                   , ""} )
        aAdd( aBody, { "", "000010" , "01.09.001" , "CLORO E SEUS COMPOSTOS TÓXICOS (EXCETO OS ABAIXO ESPECIFICADOS, QUE CONSTAM EXPRESSAMENTE NO ANEXO IV DO DECRETO 3.048/1999)"                                      , ""} )
        aAdd( aBody, { "", "000011" , "01.09.002" , "METILENO-ORTOCLOROANILINA, MOCA® (4,4'-METILENO-BIS-(2-CLOROANILINA), MBOCA®)"                                                                                     , ""} )
        aAdd( aBody, { "", "000012" , "01.09.003" , "BIS (CLORO METIL) ÉTER, CLOROMETILETER, (ÉTER BIS (CLOROMETÍLICO) OU ÉTER METÍLICO DE CLOROMETILA)"                                                                , "20220703", 1032.05} )
        aAdd( aBody, { "", "000013" , "01.09.004" , "BISCLOROETILETER (ÉTER DICLOROETÍLICO)"                                                                                                                            , ""} )
        aAdd( aBody, { "", "000014" , "01.09.005" , "CLORAMBUCIL (CLOROAMBUCIL)"                                                                                                                                        , ""} )
        aAdd( aBody, { "", "000015" , "01.09.006" , "CLOROPRENO"                                                                                                                                                        , ""} )
        aAdd( aBody, { "", "000016" , "01.10.001" , "CROMO E SEUS COMPOSTOS TÓXICOS"                                                                                                                                    , ""} )
        aAdd( aBody, { "", "000017" , "01.11.001" , "DISSULFETO DE CARBONO"                                                                                                                                             , ""} )
        aAdd( aBody, { "", "000018" , "01.12.001" , "FÓSFORO E SEUS COMPOSTOS TÓXICOS"                                                                                                                                  , ""} )
		aAdd( aBody, { "", "000019" , "01.13.001" , "IODO"                                                                                                                                                              , ""} )
        aAdd( aBody, { "", "000020" , "01.14.001" , "MANGANÊS E SEUS COMPOSTOS"                                                                                                                                         , ""} )
        aAdd( aBody, { "", "000021" , "01.15.001" , "MERCÚRIO E SEUS COMPOSTOS"                                                                                                                                         , ""} )
        aAdd( aBody, { "", "000022" , "01.16.001" , "NÍQUEL E SEUS COMPOSTOS TÓXICOS"                                                                                                                                   , ""} )
        aAdd( aBody, { "", "000023" , "01.17.001" , "PETRÓLEO, XISTO BETUMINOSO, GÁS NATURAL E SEUS DERIVADOS"                                                                                                          , ""} )
        aAdd( aBody, { "", "000024" , "01.18.001" , "SÍLICA LIVRE"                                                                                                                                                      , ""} )
        aAdd( aBody, { "", "000025" , "01.19.001" , "BUTADIENO-ESTIRENO "                                                                                                                                               , ""} )
        aAdd( aBody, { "", "000026" , "01.19.002" , "ACRILONITRILA"                                                                                                                                                     , ""} )
        aAdd( aBody, { "", "000027" , "01.19.003" , "1-3-BUTADIENO"                                                                                                                                                     , ""} )
        aAdd( aBody, { "", "000028" , "01.19.004" , "MERCAPTANOS (TIÓIS)"                                                                                                                                               , ""} )
        aAdd( aBody, { "", "000029" , "01.19.005" , "N-HEXANO"                                                                                                                                                          , ""} )
        aAdd( aBody, { "", "000030" , "01.19.006" , "DIISOCIANATO DE TOLUENO (TDI)"                                                                                                                                     , ""} )
        aAdd( aBody, { "", "000031" , "01.19.007" , "AMINAS AROMÁTICAS"                                                                                                                                                 , ""} )
        aAdd( aBody, { "", "000032" , "01.19.008" , "AMINOBIFENILA"                                                                                                                                                     , "20220703", 1032.05} )
        aAdd( aBody, { "", "000033" , "01.19.009" , "AURAMINA"                                                                                                                                                          , ""} )
        aAdd( aBody, { "", "000034" , "01.19.010" , "AZATIOPRINA"                                                                                                                                                       , ""} )
        aAdd( aBody, { "", "000035" , "01.19.011" , "1-4-BUTANODIOL"                                                                                                                                                    , ""} )
        aAdd( aBody, { "", "000036" , "01.19.012" , "DIMETANOSULFONATO (MIRELAN)"                                                                                                                                       , ""} )
        aAdd( aBody, { "", "000037" , "01.19.013" , "CICLOFOSFAMIDA"                                                                                                                                                    , ""} )
        aAdd( aBody, { "", "000038" , "01.19.014" , "DIETILETIL-BESTROL"                                                                                                                                                , ""} )
        aAdd( aBody, { "", "000039" , "01.19.015" , "ACRONITRILA"                                                                                                                                                       , ""} )
        aAdd( aBody, { "", "000040" , "01.19.016" , "NITRONAFTILAMINA"                                                                                                                                                  , ""} )
        aAdd( aBody, { "", "000041" , "01.19.017" , "4-DIMETIL-AMINOAZOBENZENO"                                                                                                                                         , ""} )
        aAdd( aBody, { "", "000042" , "01.19.018" , "BENZOPIRENO"                                                                                                                                                       , ""} )
        aAdd( aBody, { "", "000043" , "01.19.019" , "BETA-PBISCLOROMEROPIOLACTONA (BETA-PROPIOLACTONA)"                                                                                                                 , ""} )
        aAdd( aBody, { "", "000044" , "01.19.020" , "BISCLOROMETIL"                                                                                                                                                     , "20220703", 1032.05} )
        aAdd( aBody, { "", "000045" , "01.19.021" , "DIANIZIDINA"                                                                                                                                                       , ""} )
        aAdd( aBody, { "", "000046" , "01.19.022" , "DIETILSULFATO"                                                                                                                                                     , ""} )
        aAdd( aBody, { "", "000047" , "01.19.023" , "DIMETILSULFATO "                                                                                                                                                   , ""} )
        aAdd( aBody, { "", "000048" , "01.19.024" , "ETILENOAMINA"                                                                                                                                                      , ""} )
        aAdd( aBody, { "", "000049" , "01.19.025" , "ETILENOTIUREIA"                                                                                                                                                    , ""} )
        aAdd( aBody, { "", "000050" , "01.19.026" , "FENACETINA"                                                                                                                                                        , ""} )
        aAdd( aBody, { "", "000051" , "01.19.027" , "IODETO DE METILA"                                                                                                                                                  , ""} )
        aAdd( aBody, { "", "000052" , "01.19.028" , "ETILNITROSUREIA"                                                                                                                                                   , ""} )
        aAdd( aBody, { "", "000053" , "01.19.029" , "NITROSAMINA"                                                                                                                                                       , ""} )
        aAdd( aBody, { "", "000054" , "01.19.030" , "ORTOTOLUIDINA"                                                                                                                                                     , ""} )
        aAdd( aBody, { "", "000055" , "01.19.031" , "OXIMETALONA (OXIME-TALONA)"                                                                                                                                        , ""} )
        aAdd( aBody, { "", "000056" , "01.19.032" , "PROCARBAZINA"                                                                                                                                                      , ""} )
        aAdd( aBody, { "", "000057" , "01.19.033" , "PROPANOSULTONA"                                                                                                                                                    , ""} )
        aAdd( aBody, { "", "000058" , "01.19.034" , "ÓXIDO DE ETILENO"                                                                                                                                                  , ""} )
        aAdd( aBody, { "", "000059" , "01.19.035" , "ESTILBENZENO"                                                                                                                                                      , "20220809", 1032.08} )
        aAdd( aBody, { "", "000060" , "01.19.036" , "CREOSOTO"                                                                                                                                                          , ""} )
        aAdd( aBody, { "", "000061" , "01.19.037" , "4-AMINODIFENIL"                                                                                                                                                    , "20220703", 1032.05} )
        aAdd( aBody, { "", "000062" , "01.19.038" , "BENZIDINA"                                                                                                                                                         , ""} )
        aAdd( aBody, { "", "000063" , "01.19.039" , "BETANAFTILAMINA"                                                                                                                                                   , ""} )
        aAdd( aBody, { "", "000064" , "01.19.040" , "1-CLORO-2,4-NITRODIFENIL"                                                                                                                                          , ""} )
        aAdd( aBody, { "", "000065" , "01.19.041" , "3-POXIPRO-PANO"                                                                                                                                                    , ""} )
        aAdd( aBody, { "", "000066" , "02.01.001" , "RUÍDO"                                                                                                                                                             , ""} )
        aAdd( aBody, { "", "000067" , "02.01.002" , "VIBRAÇÕES LOCALIZADAS (MÃO-BRAÇO)"                                                                                                                                 , ""} )
        aAdd( aBody, { "", "000068" , "02.01.003" , "VIBRAÇÃO DE CORPO INTEIRO (ACELERAÇÃO RESULTANTE DE EXPOSIÇÃO NORMALIZADA - AREN)"                                                                                 , ""} )
        aAdd( aBody, { "", "000069" , "02.01.004" , "VIBRAÇÃO DE CORPO INTEIRO (VALOR DA DOSE DE VIBRAÇÃO RESULTANTE - VDVR)"                                                                                           , ""} )
        aAdd( aBody, { "", "000070" , "02.01.005" , "TRABALHOS COM PERFURATRIZES E MARTELETES PNEUMÁTICOS"                                                                                                              , ""} )
        aAdd( aBody, { "", "000071" , "02.01.006" , "RADIAÇÕES IONIZANTES"                                                                                                                                              , ""} )
        aAdd( aBody, { "", "000072" , "02.01.007" , "EXTRAÇÃO E BENEFICIAMENTO DE MINERAIS RADIOATIVOS"                                                                                                                 , ""} )
        aAdd( aBody, { "", "000073" , "02.01.008" , "ATIVIDADES EM MINERAÇÕES COM EXPOSIÇÃO AO RADÔNIO"                                                                                                                 , ""} )
        aAdd( aBody, { "", "000074" , "02.01.009" , "REALIZAÇÃO DE MANUTENÇÃO E SUPERVISÃO EM UNIDADES DE EXTRAÇÃO, TRATAMENTO E BENEFICIAMENTO DE MINERAIS RADIOATIVOS COM EXPOSIÇÃO ÀS RADIAÇÕES IONIZANTES"          , ""} )
        aAdd( aBody, { "", "000075" , "02.01.010" , "OPERAÇÕES COM REATORES NUCLEARES OU COM FONTES RADIOATIVAS"                                                                                                        , ""} )
        aAdd( aBody, { "", "000076" , "02.01.011" , "TRABALHOS REALIZADOS COM EXPOSIÇÃO AOS RAIOS ALFA, BETA, GAMA E X, AOS NÊUTRONS E ÀS SUBSTÂNCIAS RADIOATIVAS PARA FINS INDUSTRIAIS, TERAPÊUTICOS E DIAGNÓSTICOS"   , ""} )
        aAdd( aBody, { "", "000077" , "02.01.012" , "FABRICAÇÃO E MANIPULAÇÃO DE PRODUTOS RADIOATIVOS"                                                                                                                  , ""} )
        aAdd( aBody, { "", "000078" , "02.01.013" , "PESQUISAS E ESTUDOS COM RADIAÇÕES IONIZANTES EM LABORATÓRIOS"                                                                                                      , ""} )
        aAdd( aBody, { "", "000079" , "02.01.014" , "TRABALHOS COM EXPOSIÇÃO AO CALOR ACIMA DOS LIMITES DE TOLERÂNCIA ESTABELECIDOS NA NR-15, DA PORTARIA 3.214/1978"                                                   , ""} )
        aAdd( aBody, { "", "000080" , "02.01.015" , "PRESSÃO ATMOSFÉRICA ANORMAL"                                                                                                                                       , ""} )
        aAdd( aBody, { "", "000081" , "02.01.016" , "TRABALHOS EM CAIXÕES OU CÂMARAS HIPERBÁRICAS"                                                                                                                      , ""} )
        aAdd( aBody, { "", "000082" , "02.01.017" , "TRABALHOS EM TUBULÕES OU TÚNEIS SOB AR COMPRIMIDO"                                                                                                                 , ""} )
        aAdd( aBody, { "", "000083" , "02.01.018" , "OPERAÇÕES DE MERGULHO COM O USO DE ESCAFANDROS OU OUTROS EQUIPAMENTOS"                                                                                             , ""} )
        aAdd( aBody, { "", "000084" , "03.01.001" , "TRABALHOS EM ESTABELECIMENTOS DE SAÚDE COM CONTATO COM PACIENTES PORTADORES DE DOENÇAS INFECTOCONTAGIOSAS OU COM MANUSEIO DE MATERIAIS CONTAMINADOS"               , ""} )
        aAdd( aBody, { "", "000085" , "03.01.002" , "TRABALHOS COM ANIMAIS INFECTADOS PARA TRATAMENTO OU PARA O PREPARO DE SORO, VACINAS E OUTROS PRODUTOS"                                                             , ""} )
        aAdd( aBody, { "", "000086" , "03.01.003" , "TRABALHOS EM LABORATÓRIOS DE AUTÓPSIA, DE ANATOMIA E ANÁTOMO-HISTOLOGIA"                                                                                           , ""} )
        aAdd( aBody, { "", "000087" , "03.01.004" , "TRABALHO DE EXUMAÇÃO DE CORPOS E MANIPULAÇÃO DE RESÍDUOS DE ANIMAIS DETERIORADOS"                                                                                  , ""} )
        aAdd( aBody, { "", "000088" , "03.01.005" , "TRABALHOS EM GALERIAS, FOSSAS E TRANQUES DE ESGOTO"                                                                                                                , ""} )
        aAdd( aBody, { "", "000089" , "03.01.006" , "ESVAZIAMENTO DE BIODIGESTORES"                                                                                                                                     , ""} )
        aAdd( aBody, { "", "000090" , "03.01.007" , "COLETA E INDUSTRIALIZAÇÃO DO LIXO"                                                                                                                                 , ""} )
        aAdd( aBody, { "", "000091" , "04.01.001" , "MINERAÇÃO SUBTERRÂNEA CUJAS ATIVIDADES SEJAM EXERCIDAS AFASTADAS DAS FRENTES DE PRODUÇÃO"                                                                          , ""} )
        aAdd( aBody, { "", "000092" , "04.01.002" , "TRABALHOS EM ATIVIDADES PERMANENTES NO SUBSOLO DE MINERAÇÕES SUBTERRÂNEAS EM FRENTE DE PRODUÇÃO "                                                                  , ""} )
        aAdd( aBody, { "", "000093" , "05.01.001" , "AGENTES NOCIVOS NÃO CONSTANTES NO ANEXO IV DO DECRETO 3.048/1999 E INCLUÍDOS POR FORÇA DE DECISÃO JUDICIAL OU ADMINISTRATIVA "                                     , ""} )
        aAdd( aBody, { "", "000094" , "09.01.001" , "AUSÊNCIA DE AGENTE NOCIVO OU DE ATIVIDADES PREVISTAS NO ANEXO IV DO DECRETO 3.048/1999"                                                                            , ""} )

        //NOTA TÉCNICA S-1.0 Nº 05/2022
        aAdd( aBody, { "", "000095", "01.09.003", "BIS (CLORO METIL) ÉTER, CLOROMETILETER, (ÉTER BIS (CLOROMETÍLICO) OU ÉTER METÍLICO DE CLOROMETILA), BISCLOROMETIL"                                                   , "", 1032.05 } )
        aAdd( aBody, { "", "000096", "01.19.008", "AMINOBIFENILA (4-AMINODIFENIL)"                                                                                                                                      , "", 1032.05 } )

        //NOTA TÉCNICA S-1.0 Nº 06/2022
        aAdd( aBody, { "", "000097", "01.09.035", "ESTILBENZENO (ETILBENZENO)"                                                                                                                                          , "", 1032.08 } )

		aAdd( aRet, { aHeader, aBody } )

	EndIf

Return aRet
	