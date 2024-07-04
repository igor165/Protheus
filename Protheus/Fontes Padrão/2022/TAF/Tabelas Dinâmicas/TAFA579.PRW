#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA579.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA579

@author José Riquelmo - Tabela 25
@since 03/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA579()

	Local   oBrw :=  FWmBrowse():New()

	oBrw:SetDescription(STR0001)    //"Códigos de Incidência Tributária da Rubrica para o IRRF"
	oBrw:SetAlias( 'V5Z')
	oBrw:SetMenuDef('TAFA579')
	oBrw:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author José Riquelmo
@since 03/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA579" )


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author José Riquelmo
@since 03/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruV5Z:= FwFormStruct( 1, "V5Z" )
Local oModel   := MpFormModel():New( "TAFA579" )

oModel:AddFields( "MODEL_V5Z", /*cOwner*/, oStruV5Z )
oModel:GetModel ( "MODEL_V5Z" ):SetPrimaryKey( { "V5Z_FILIAL", "V5Z_ID" } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author José Riquelmo
@since 03/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA579' )
Local   oStruV5Z    :=  FWFormStruct( 2, 'V5Z' )
Local   oView       :=  FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_V5Z', oStruV5Z, 'MODEL_V5Z' )

oView:EnableTitleView( 'VIEW_V5Z', STR0001 )    //"Códigos de Incidência Tributária da Rubrica para o IRRF"
oView:CreateHorizontalBox( 'FIELDSV5Z', 100 )
oView:SetOwnerView( 'VIEW_V5Z', 'FIELDSV5Z' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@author José Riquelmo
@since 03/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1031.54

If nVerEmp < nVerAtu

    aAdd( aHeader, "V5Z_FILIAL" )
    aAdd( aHeader, "V5Z_ID" )
    aAdd( aHeader, "V5Z_CODIGO" )
    aAdd( aHeader, "V5Z_DESCRI" )
    aAdd( aHeader, "V5Z_VALIDA" )
    
    //GRUPO 01 - APOSENTADORIA POR IDADE E TEMPO DE CONTRIBUIÇÃO

    aAdd( aBody, { "", "000001" , "0101" , "APOSENTADORIA POR IDADE E TEMPO DE CONTRIBUIÇÃO - PROVENTOS COM INTEGRALIDADE, REVISÃO PELA PARIDADE" , ""} )
    aAdd( aBody, { "", "000002" , "0102" , "APOSENTADORIA POR IDADE E TEMPO DE CONTRIBUIÇÃO - PROVENTOS PELA MÉDIA, REAJUSTE MANTER VALOR REAL" , ""} )
    aAdd( aBody, { "", "000003" , "0103" , "APOSENTADORIA POR IDADE - PROVENTOS PROPORCIONAIS CALCULADO SOBRE INTEGRALIDADE, REVISÃO PELA PARIDADE" , ""} )
    aAdd( aBody, { "", "000004" , "0104" , "APOSENTADORIA POR IDADE - PROVENTOS PROPORCIONAIS CALCULADO SOBRE A MÉDIA, REAJUSTE MANTER VALOR REAL" , ""} )
    aAdd( aBody, { "", "000005" , "0105" , "APOSENTADORIA COMPULSÓRIA - PROVENTOS PROPORCIONAIS CALCULADO SOBRE INTEGRALIDADE, REVISÃO PELA PARIDADE" , ""} )
    aAdd( aBody, { "", "000006" , "0106" , "APOSENTADORIA COMPULSÓRIA - PROVENTOS PROPORCIONAIS CALCULADO SOBRE A MÉDIA, REAJUSTE MANTER VALOR REAL" , ""} ) 
    aAdd( aBody, { "", "000007" , "0107" , "APOSENTADORIA DE PROFESSOR - PROVENTOS COM INTEGRALIDADE, REVISÃO PELA PARIDADE" , ""} )
    aAdd( aBody, { "", "000008" , "0108" , "APOSENTADORIA DE PROFESSOR - PROVENTOS PELA MÉDIA, REAJUSTE MANTER VALOR REAL" , ""} )
    aAdd( aBody, { "", "000009" , "0109" , "APOSENTADORIA DE SERVIDOR VINCULADO A RPC - PROVENTOS LIMITADOS AO TETO DO RGPS" , ""} )

    // GRUPO 02 - APOSENTADORIA ESPECIAL

    aAdd( aBody, { "", "000010" , "0201" , "APOSENTADORIA ESPECIAL - RISCO" , ""} )
    aAdd( aBody, { "", "000011" , "0202" , "APOSENTADORIA ESPECIAL - EXPOSIÇÃO A AGENTES NOCIVOS" , ""} )
    aAdd( aBody, { "", "000012" , "0203" , "APOSENTADORIA DA PESSOA COM DEFICIÊNCIA" , ""} )
    aAdd( aBody, { "", "000013" , "0204" , "APOSENTADORIA ESPECIAL DO POLICIAL CIVIL" , ""} )
    aAdd( aBody, { "", "000014" , "0205" , "APOSENTADORIA ESPECIAL - RISCO - SERVIDOR VINCULADO A RPC - PROVENTOS LIMITADOS AO TETO DO RGPS" , ""} )
    aAdd( aBody, { "", "000015" , "0206" , "APOSENTADORIA ESPECIAL - EXPOSIÇÃO A AGENTES NOCIVOS - SERVIDOR VINCULADO A RPC - PROVENTOS LIMITADOS AO TETO DO RGPS" , ""} )
    aAdd( aBody, { "", "000016" , "0207" , "APOSENTADORIA DA PESSOA COM DEFICIÊNCIA - SERVIDOR VINCULADO A RPC - PROVENTOS LIMITADOS AO TETO DO RGPS" , ""} )
    aAdd( aBody, { "", "000017" , "0208" , "APOSENTADORIA ESPECIAL DE POLICIAL - SERVIDOR VINCULADO A RPC - PROVENTOS LIMITADOS AO TETO DO RGPS" , ""} )
    
    
    // GRUPO 03 - APOSENTADORIA POR INVALIDEZ/INCAPACIDADE PERMANENTE 

    aAdd( aBody, { "", "000018" , "0301" , "APOSENTADORIA POR INVALIDEZ - PROVENTOS COM INTEGRALIDADE, REVISÃO PELA PARIDADE" , ""} )
    aAdd( ABODY, { "", "000019" , "0302" , "APOSENTADORIA POR INVALIDEZ - PROVENTOS PELA MÉDIA, REAJUSTE MANTER VALOR REAL" , ""} )
    aAdd( ABODY, { "", "000020" , "0303" , "APOSENTADORIA POR INVALIDEZ - PROVENTOS PROPORCIONAIS CALCULADO SOBRE INTEGRALIDADE, REVISÃO PELA PARIDADE" , ""} )
    aAdd( ABODY, { "", "000021" , "0304" , "APOSENTADORIA POR INVALIDEZ - PROVENTOS PROPORCIONAIS CALCULADO SOBRE A MÉDIA, REAJUSTE MANTER VALOR REAL" , ""} )
    aAdd( aBody, { "", "000022" , "0305" , "APOSENTADORIA POR INVALIDEZ - SERVIDOR VINCULADO A RPC - PROVENTOS LIMITADOS AO TETO DO RGPS" , ""} )
    
    // GRUPO 04 - MILITARES (REFORMA)

    aAdd( aBody, { "", "000023" , "0401" , "REFORMA POR INVALIDEZ" , ""} )
    aAdd( aBody, { "", "000024" , "0402" , "REFORMA" , ""} )

    // GRUPO 05 - MILITARES (RESERVA)

    aAdd( aBody, { "", "000025" , "0501" , "RESERVA REMUNERADA COMPULSÓRIA INTEGRAL" , ""} )
    aAdd( aBody, { "", "000026" , "0502" , "RESERVA REMUNERADA INTEGRAL" , ""} )
    aAdd( aBody, { "", "000027" , "0503" , "RESERVA REMUNERADA PROPORCIONAL" , ""} )

    // GRUPO 06 - PENSÃO POR MORTE 

    aAdd( aBody, { "", "000028" , "0601" , "PENSÃO POR MORTE (ART. 40, § 7º, DA CF/1988)" , ""} )
    aAdd( aBody, { "", "000029" , "0602" , "PENSÃO POR MORTE COM PARIDADE, DECORRENTE DO ART. 6º-A DA EC 41/2003" , ""} )
    aAdd( aBody, { "", "000030" , "0603" , "PENSÃO POR MORTE COM PARIDADE, DECORRENTE DO ART. 3º DA EC 47/2005" , ""} )
    aAdd( aBody, { "", "000031" , "0604" , "PENSÃO POR MORTE MILITAR" , ""} )

    // GRUPO 07 - COMPLEMENTAÇÃO DO BENEFÍCIO DO REGIME GERAL DE PREVIDÊNCIA SOCIAL (RGPS) 

    aAdd( aBody, { "", "000032" , "0701" , "COMPLEMENTAÇÃO DE APOSENTADORIA DO RGPS" , ""} )
    aAdd( aBody, { "", "000033" , "0702" , "COMPLEMENTAÇÃO DE PENSÃO POR MORTE DO RGPS" , ""} )

    //GRUPO 08 - BENEFÍCIOS CONCEDIDOS ANTES DA OBRIGATORIEDADE DE ENVIO DOS EVENTOS NÃO PERIÓDICOS PARA ENTES PÚBLICOS NO ESOCIAL (CARGA INICIAL) 
    aAdd( aBody, { "", "000034" , "0801" , "APOSENTADORIA SEM PARIDADE CONCEDIDA ANTES DA OBRIGATORIEDADE DE ENVIO DOS EVENTOS NÃO PERIÓDICOS PARA ENTES PÚBLICOS NO ESOCIAL" , ""} )
    aAdd( aBody, { "", "000035" , "0802" , "APOSENTADORIA COM PARIDADE CONCEDIDA ANTES DA OBRIGATORIEDADE DE ENVIO DOS EVENTOS NÃO PERIÓDICOS PARA ENTES PÚBLICOS NO ESOCIAL" , ""} )
    aAdd( aBody, { "", "000036" , "0803" , "APOSENTADORIA POR INVALIDEZ COM PARIDADE CONCEDIDA ANTES DA OBRIGATORIEDADE DE ENVIO DOS EVENTOS NÃO PERIÓDICOS PARA ENTES PÚBLICOS NO ESOCIAL" , ""} )
    aAdd( aBody, { "", "000037" , "0804" , "APOSENTADORIA POR INVALIDEZ SEM PARIDADE CONCEDIDA ANTES DA OBRIGATORIEDADE DE ENVIO DOS EVENTOS NÃO PERIÓDICOS PARA ENTES PÚBLICOS NO ESOCIAL" , ""} )
    aAdd( aBody, { "", "000038" , "0805" , "TRANSFERÊNCIA PARA RESERVA CONCEDIDA ANTES DA OBRIGATORIEDADE DE ENVIO DOS EVENTOS NÃO PERIÓDICOS PARA ENTES PÚBLICOS NO ESOCIAL" , ""} )
    aAdd( aBody, { "", "000039" , "0806" , "REFORMA CONCEDIDA ANTES DA OBRIGATORIEDADE DE ENVIO DOS EVENTOS NÃO PERIÓDICOS PARA ENTES PÚBLICOS NO ESOCIAL" , ""} )
    aAdd( aBody, { "", "000040" , "0807" , "PENSÃO POR MORTE COM PARIDADE CONCEDIDA ANTES DA OBRIGATORIEDADE DE ENVIO DOS EVENTOS NÃO PERIÓDICOS PARA ENTES PÚBLICOS NO ESOCIAL" , ""} )
    aAdd( aBody, { "", "000041" , "0808" , "PENSÃO POR MORTE SEM PARIDADE CONCEDIDA ANTES DA OBRIGATORIEDADE DE ENVIO DOS EVENTOS NÃO PERIÓDICOS PARA ENTES PÚBLICOS NO ESOCIAL" , ""} )
    aAdd( aBody, { "", "000042" , "0809" , "OUTROS BENEFÍCIOS PREVIDENCIÁRIOS CONCEDIDOS ANTES DA OBRIGATORIEDADE DE ENVIO DOS EVENTOS NÃO PERIÓDICOS PARA ENTES PÚBLICOS NO ESOCIAL" , ""} )
    aAdd( aBody, { "", "000043" , "0810" , "APOSENTADORIA DE PARLAMENTAR - PLANO PRÓPRIO" , ""} )
    aAdd( aBody, { "", "000044" , "0811" , "APOSENTADORIA DE SERVIDOR VINCULADO AO PODER LEGISLATIVO - PLANO PRÓPRIO" , ""} )
    aAdd( aBody, { "", "000045" , "0812" , "PENSÃO POR MORTE - PLANO PRÓPRIO" , ""} )
    
    // GRUPO 09 - BENEFÍCIOS ESPECIAIS COM VÍNCULO PREVIDENCIÁRIO 

    aAdd( aBody, { "", "000046" , "0901" , "BENEFÍCIO ESPECIAL PROPORCIONAL - SERVIDOR PERTENCENTE A RPPS QUE OPTA PELO RPC DA UNIÃO" , ""} )
    aAdd( aBody, { "", "000047" , "0902" , "BENEFÍCIO ESPECIAL PROPORCIONAL - SERVIDOR PERTENCENTE A RPPS QUE OPTA PELO RPC - DEMAIS ENTES DA FEDERAÇÃO, DE ACORDO COM AS DISPOSIÇÕES DAS LEIS ESPECÍFICAS" , ""} )
    aAdd( aBody, { "", "000048" , "0909" , "OUTROS BENEFÍCIOS ESPECIAIS COM VÍNCULO PREVIDENCIÁRIO" , ""} )


    // GRUPO 10 - BENEFÍCIOS ESPECIAIS COM VÍNCULO PREVIDENCIÁRIO 

    aAdd( aBody, { "", "000049" , "1001" , "PENSÃO ESPECIAL SEM VÍNCULO PREVIDENCIÁRIO" , ""} )
    aAdd( aBody, { "", "000050" , "1009" , "OUTROS BENEFÍCIOS SEM VÍNCULO PREVIDENCIÁRIO" , ""} )
    
    // GRUPO 11 - PARLAMENTARES 

    aAdd( aBody, { "", "000051" , "1101" , "APOSENTADORIA VOLUNTÁRIA COM PROVENTOS PROPORCIONAIS AO TEMPO DE MANDATO - LEIS PRÓPRIAS" , ""} )
    aAdd( aBody, { "", "000052" , "1102" , "APOSENTADORIA VOLUNTÁRIA COM PROVENTOS INTEGRAIS AO TEMPO DE MANDATO - LEIS PRÓPRIAS" , ""} )
    aAdd( aBody, { "", "000053" , "1103" , "APOSENTADORIA POR INVALIDEZ PERMANENTE - PROVENTOS INTEGRAIS - LEIS PRÓPRIAS" , ""} )
    aAdd( aBody, { "", "000054" , "1104" , "APOSENTADORIA POR INVALIDEZ PERMANENTE - PROVENTOS PROPORCIONAIS AO TEMPO DE MANDATO - LEIS PRÓPRIAS" , ""} )
    aAdd( aBody, { "", "000055" , "1105" , "PENSÃO POR MORTE DE PARLAMENTAR - LEI ESPECÍFICA" , ""} )
    aAdd( aBody, { "", "000056" , "1106" , "PENSÃO POR MORTE DE PARLAMENTAR - PLANOS ANTERIORES À EC 20/1998" , ""} )

    // NT 04/2021 - S-1.0
    aAdd( aBody, { "", "000057" , "0403" , "REFORMA COMPULSÓRIA PROPORCIONAL" , ""} )
    aAdd( aBody, { "", "000058" , "0404" , "REFORMA COMPULSÓRIA INTEGRAL" , ""} )
    aAdd( aBody, { "", "000059" , "0405" , "REFORMA POR INCAPACIDADE DEFINITIVA" , ""} )
    aAdd( aBody, { "", "000060" , "0504" , "RESERVA REMUNERADA COMPULSÓRIA PROPORCIONAL" , ""} )

    aAdd( aRet, { aHeader, aBody } )

EndIf

Return( aRet )
