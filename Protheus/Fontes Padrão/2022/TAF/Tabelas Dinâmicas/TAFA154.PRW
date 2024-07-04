#INCLUDE "PROTHEUS.CH"                             
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA154.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA154
Cadastro de Ajustes da Apuração (IPI)

@author Marcio Nunes
@since 05/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA154()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Ajustes da Apuração (IPI)
oBrw:SetAlias( 'C1B')
oBrw:SetMenuDef( 'TAFA154' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA154" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC1B 	:= 	FWFormStruct( 1, 'C1B' )
Local oModel 	:= 	MPFormModel():New( 'TAFA154' )

oModel:AddFields('MODEL_C1B', /*cOwner*/, oStruC1B)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA154' )
Local 	oStruC1B 	:= 	FWFormStruct( 2, 'C1B' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C1B', oStruC1B, 'MODEL_C1B' )

oView:EnableTitleView( 'VIEW_C1B', STR0001 ) //Cadastro de Ajustes da Apuração (IPI)
oView:CreateHorizontalBox( 'FIELDSC1B', 100 )
oView:SetOwnerView( 'VIEW_C1B', 'FIELDSC1B' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1003

If nVerEmp < nVerAtu
	aAdd( aHeader, "C1B_FILIAL" )
	aAdd( aHeader, "C1B_ID" )
	aAdd( aHeader, "C1B_CODIGO" )
	aAdd( aHeader, "C1B_DESCRI" )
	aAdd( aHeader, "C1B_VALIDA" )

	aAdd( aBody, { "", "000001", "001", "ESTORNO DE DEBITO; C; MONTANTE DO DEBITO DO IPI ESTORNADO", "" } )
	aAdd( aBody, { "", "000003", "002", "CREDITO RECEBIDO POR TRANSFERENCIA; C; MONTANTE DOS CREDITOS DO IPI RECEBIDOS POR TRANSFERENCIA, DE OUTRO(S) ESTABELECIMENTO(S) DA MESMA EMPRESA", "" } )
	aAdd( aBody, { "", "000002", "010", "CREDITO PRESUMIDO DE IPI - RESSARCIMENTO DO PIS/PASEP E DA COFINS - LEI Nº 9.363/1996; C; VALOR DO CREDITO PRESUMIDO DE IPI DECORRENTE DO RESSARCIMENTO DO PIS/PASEP E DA COFINS NAS OPERACOES DE EXPORTACAO DE PRODUTOS IND", "" } )
	aAdd( aBody, { "", "000004", "011", "CREDITO PRESUMIDO DE IPI -RESSARCIMENTO DO PIS/PASEP E DA COFINS -LEI Nº 10.276/2001; C; VALOR DO CREDITO PRESUMIDO DE IPI DECORRENTE DO RESSARCIMENTO DO PIS/PASEP E DA COFINS NAS OPERACOES DE EXPORTACAO DE PRODUTOS INDU", "" } )
	aAdd( aBody, { "", "000005", "012", "CREDITO PRESUMIDO DE IPI -REGIOES INCENTIVADAS -LEI Nº 9.826/1999; C; VALOR DO CREDITO PRESUMIDO RELATIVO AO IPI INCIDENTE NAS SAIDAS, DO ESTABELECIMENTO INDUSTRIAL, DOS PRODUTOS CLASSIFICADOS NAS POSICOES 8702 A 8704 DA", "" } )
	aAdd( aBody, { "", "000006", "013", "CREDITO PRESUMIDO DE IPI-FRETE-MP2.158/2001; C; VALOR DO CREDITO PRESUMIDO DE IPI RELATIVAMENTE A PARCELA DO FRETE COBRADO PELA PRESTACAO DO SERVICO DE TRANSPORTE DOS PRODUTOS CLASSIFICADOS NOS CODIGOS 8433.53.00, 8433.5", "" } )
	aAdd( aBody, { "", "000007", "019", "CREDITO PRESUMIDO DE IPI - OUTROS; C; OUTROS VALORES DE CREDITO PRESUMIDO DE IPI", "" } )
	aAdd( aBody, { "", "000008", "098", "CREDITOS DECORRENTES DE MEDIDA JUDICIAL; C; VALORES DE CREDITO DE IPI DECORRENTES DE MEDIDA JUDICIAL", "" } )
	aAdd( aBody, { "", "000009", "099", "OUTROS CREDITOS; C; MONTANTE DE OUTROS CREDITOS DO IPI", "" } )
	aAdd( aBody, { "", "000010", "101", "ESTORNO DE CREDITO; D; MONTANTE DO CREDITO DO IPI ESTORNADO", "" } )
	aAdd( aBody, { "", "000011", "102", "TRANSFERENCIA DE CREDITO; D; MONTANTE DO CREDITO DO IPI TRANSFERIDO NO PERIODO, PARA OUTRO(S) ESTABELECIMENTO(S) DA MESMA EMPRESA, CONFORME PREVISTO NA LEGISLACAO TRIBUTARIA.", "" } )
	aAdd( aBody, { "", "000012", "103", "RESSARCIMENTO / COMPENSACAO DE CREDITOS; D; MONTANTE DO CREDITO DO IPI, PLEITEADO, JUNTO A SRF/MF", "" } )
	aAdd( aBody, { "", "000013", "199", "OUTROS DEBITOS; D; MONTANTE DE OUTROS DEBITOS DO IPI", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )