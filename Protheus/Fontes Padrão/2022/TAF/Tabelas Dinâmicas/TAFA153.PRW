#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA153.CH"                                            
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA153
Cadastro MVC - Cadastro de Sub Sub-Grupo ANP

@author Mauro A. Goncalves
@since 06/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA153()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Sub Sub-Grupo ANP
oBrw:SetAlias( 'C0F')
oBrw:SetMenuDef( 'TAFA153' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 06/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA153" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 06/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC0F 	:= 	FWFormStruct( 1, 'C0F' )
Local oModel 	:= 	MPFormModel():New( 'TAFA153' )

oModel:AddFields('MODEL_C0F', /*cOwner*/, oStruC0F)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 06/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA153' )
Local 	oStruC0F 	:= 	FWFormStruct( 2, 'C0F' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0F', oStruC0F, 'MODEL_C0F' )

oView:EnableTitleView( 'VIEW_C0F', STR0001 ) //Cadastro de Sub Sub-Grupo ANP
oView:CreateHorizontalBox( 'FIELDSC0F', 100 )
oView:SetOwnerView( 'VIEW_C0F', 'FIELDSC0F' )

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

nVerAtu := 1032.06

If nVerEmp < nVerAtu
	aAdd( aHeader, "C0F_FILIAL" )
	aAdd( aHeader, "C0F_ID" )
	aAdd( aHeader, "C0F_CODIGO" )
	aAdd( aHeader, "C0F_DESCRI" )
	aAdd( aHeader, "C0F_ALTCON" )

	aAdd( aBody, { "", "000001", "001", "ADITIVOS" } )
	aAdd( aBody, { "", "000002", "002", "AGUA" } )
	aAdd( aBody, { "", "000003", "003", "ALCOOL ETILICO ANIDRO" } )
	aAdd( aBody, { "", "000004", "004", "ALCOOL ETILICO HIDRATADO" } )
	aAdd( aBody, { "", "000005", "005", "BACIA DE ALAGOAS/SERGIPE" } )
	aAdd( aBody, { "", "000006", "006", "BACIA DE CAMAMU" } )
	aAdd( aBody, { "", "000007", "007", "BACIA DE CAMPOS" } )
	aAdd( aBody, { "", "000008", "008", "BACIA DE MUCURI" } )
	aAdd( aBody, { "", "000009", "009", "BACIA DE SANTOS" } )
	aAdd( aBody, { "", "000010", "010", "BACIA DO CEARA" } )
	aAdd( aBody, { "", "000011", "011", "BACIA DO ESPIRITO SANTO" } )
	aAdd( aBody, { "", "000012", "012", "BACIA DO RECONCAVO" } )
	aAdd( aBody, { "", "000013", "013", "BACIA DO SOLIMOES" } )
	aAdd( aBody, { "", "000014", "014", "BACIA POTIGUAR" } )
	aAdd( aBody, { "", "000015", "015", "BIODIESEL" } )
	aAdd( aBody, { "", "000016", "016", "C2" } )
	aAdd( aBody, { "", "000017", "017", "C3" } )
	aAdd( aBody, { "", "000018", "018", "C4" } )
	aAdd( aBody, { "", "000019", "019", "CAMAMU" } )
	aAdd( aBody, { "", "000020", "020", "CONDENSADOS DA AFRICA" } )
	aAdd( aBody, { "", "000021", "021", "CONDENSADOS DA AMERICA DO NORTE & CARIBE" } )
	aAdd( aBody, { "", "000022", "022", "CONDENSADOS DA AMERICA DO SUL" } )
	aAdd( aBody, { "", "000023", "023", "CONDENSADOS DA ASIA" } )
	aAdd( aBody, { "", "000024", "024", "CONDENSADOS DA EUROPA E EX-URSS" } )
	aAdd( aBody, { "", "000025", "025", "CONDENSADOS DA OCEANIA" } )
	aAdd( aBody, { "", "000026", "026", "CONDENSADOS DO ORIENTE MEDIO" } )
	aAdd( aBody, { "", "000027", "027", "COQUE" } )
	aAdd( aBody, { "", "000028", "028", "ENXOFRE" } )
	aAdd( aBody, { "", "000029", "029", "GAS COMBUSTIVEL" } )
	aAdd( aBody, { "", "000030", "030", "GAS NATURAL" } )
	aAdd( aBody, { "", "000031", "031", "GASOLEOS" } )
	aAdd( aBody, { "", "000032", "032", "GASOLINA A" } )
	aAdd( aBody, { "", "000033", "033", "GASOLINA C" } )
	aAdd( aBody, { "", "000034", "034", "GASOLINAS DE AVIACAO" } )
	aAdd( aBody, { "", "000035", "035", "GRAXAS" } )
	aAdd( aBody, { "", "000036", "036", "HIDROGONIO" } )
	aAdd( aBody, { "", "000037", "037", "INDUSTRIALIZADOS" } )
	aAdd( aBody, { "", "000038", "038", "INSUMOS NCO REGULADOS" } )
	aAdd( aBody, { "", "000039", "039", "LIQUIDO DE GAS NATURAL" } )
	aAdd( aBody, { "", "000040", "040", "MACROCRISTALINAS" } )
	aAdd( aBody, { "", "000041", "041", "MATERIAIS GRAXOS" } )
	aAdd( aBody, { "", "000042", "042", "MICROCRISTALINAS" } )
	aAdd( aBody, { "", "000043", "043", "MISTURA" } )
	aAdd( aBody, { "", "000044", "044", "MISTURA C3 - C4" } )
	aAdd( aBody, { "", "000045", "045", "MOTORES 2 TEMPOS" } )
	aAdd( aBody, { "", "000046", "046", "MOTORES 4 TEMPOS" } )
	aAdd( aBody, { "", "000047", "047", "NAFTA FORA DE ESPECIFICACAO" } )
	aAdd( aBody, { "", "000048", "048", "NAFTA PETROQUIMICA" } )
	aAdd( aBody, { "", "000049", "049", "NAFTONICOS - GRUPO I" } )
	aAdd( aBody, { "", "000050", "050", "NATURAIS" } )
	aAdd( aBody, { "", "000051", "051", "OLEO COMBUSTIVEL A - ALTO TEOR DE ENXOFRE" } )
	aAdd( aBody, { "", "000052", "052", "OLEO COMBUSTIVEL B - BEIXO TEOR DE ENXOFRE" } )
	aAdd( aBody, { "", "000053", "053", "OLEO DIESEL ESPECIAIS" } )
	aAdd( aBody, { "", "000054", "054", "OLEO DIESEL INTERIOR - ALTO TEOR DE ENXOFRE" } )
	aAdd( aBody, { "", "000055", "055", "OLEO DIESEL MARITIMO" } )
	aAdd( aBody, { "", "000056", "056", "OLEO DIESEL S500" } )
	aAdd( aBody, { "", "000057", "057", "OLEOS BASICOS - GRUPO II" } )
	aAdd( aBody, { "", "000058", "058", "OLEOS BASICOS - GRUPO III" } )
	aAdd( aBody, { "", "000059", "059", "OLEOS COMBUSTIVEIS MARITIMOS" } )
	aAdd( aBody, { "", "000060", "060", "OLEOS DIESEL ESPECIAIS" } )
	aAdd( aBody, { "", "000061", "061", "OLEOS DIESEL METROPOLITANO - BAIXO TEOR DE ENXaFRE" } )
	aAdd( aBody, { "", "000062", "062", "OLEOS LUBRIFICANTES ACABADOS" } )
	aAdd( aBody, { "", "000063", "063", "OLEOS LUBRIFICANTES FERROVIARIOS" } )
	aAdd( aBody, { "", "000064", "064", "OLEOS LUBRIFICANTES INDUSTRIAIS" } )
	aAdd( aBody, { "", "000065", "065", "OLEOS LUBRIFICANTES MARITIMOS" } )
	aAdd( aBody, { "", "000066", "066", "OLEOS LUBRIFICANTES PARA AVIACAO" } )
	aAdd( aBody, { "", "000067", "067", "OLEOS LUBRIFICANTES USADOS OU CONTAMINADOS" } )
	aAdd( aBody, { "", "000068", "068", "OUTRAS GASOLINAS" } )
	aAdd( aBody, { "", "000069", "069", "OUTRAS GASOLINAS AUTOMOTIVAS" } )
	aAdd( aBody, { "", "000070", "070", "OUTRAS NAFTAS" } )
	aAdd( aBody, { "", "000071", "071", "OUTRAS PARAFINAS" } )
	aAdd( aBody, { "", "000072", "072", "OUTROS ALCOOIS" } )
	aAdd( aBody, { "", "000073", "073", "OUTROS ASFALTOS" } )
	aAdd( aBody, { "", "000074", "074", "OUTROS CONDENSADOS" } )
	aAdd( aBody, { "", "000075", "075", "OUTROS DERIVADOS LEVES" } )
	aAdd( aBody, { "", "000076", "076", "OUTROS DERIVADOS MEDIOS" } )
	aAdd( aBody, { "", "000077", "077", "OUTROS DERIVADOS PESADOS" } )
	aAdd( aBody, { "", "000078", "078", "OUTROS GASES" } )
	aAdd( aBody, { "", "000079", "079", "OUTROS GASES LIQUEFEITOS" } )
	aAdd( aBody, { "", "000080", "080", "OUTROS INSUMOS BRUTOS" } )
	aAdd( aBody, { "", "000081", "081", "OUTROS OLEOS COMBUSTIVEIS" } )
	aAdd( aBody, { "", "000082", "082", "OUTROS OLEOS DIESEL" } )
	aAdd( aBody, { "", "000083", "083", "OUTROS OLEOS LUB. PARAF. E GRAXAS" } )
	aAdd( aBody, { "", "000084", "084", "OUTROS OLEOS LUBRIFICANTES AUTOMOTIVOS" } )
	aAdd( aBody, { "", "000085", "085", "OUTROS OLEOS LUBRIFICANTES BASICOS - GRUPO VI" } )
	aAdd( aBody, { "", "000086", "086", "OUTROS PETROLEOS IMPORTADOS" } )
	aAdd( aBody, { "", "000087", "087", "OUTROS PETROLEOS NACIONAIS" } )
	aAdd( aBody, { "", "000088", "088", "OUTROS QUEROSENES" } )
	aAdd( aBody, { "", "000089", "089", "OUTROS SUB-PRODUTOS" } )
	aAdd( aBody, { "", "000090", "090", "PARAFINICOS - GRUPO I" } )
	aAdd( aBody, { "", "000091", "091", "PETROLEOS DA AFRICA" } )
	aAdd( aBody, { "", "000092", "092", "PETROLEOS DA AMERICA DO NORTE & CARIBE" } )
	aAdd( aBody, { "", "000093", "093", "PETROLEOS DA AMERICA DO SUL" } )
	aAdd( aBody, { "", "000094", "094", "PETROLEOS DA ASIA" } )
	aAdd( aBody, { "", "000095", "095", "PETROLEOS DA EUROPA E EX-URSS" } )
	aAdd( aBody, { "", "000096", "096", "PETROLEOS DA OCEANIA" } )
	aAdd( aBody, { "", "000097", "097", "PETROLEOS DO ORIENTE MEDIO" } )
	aAdd( aBody, { "", "000098", "098", "PRODUTOS PARA REPROCESSAMENTO" } )
	aAdd( aBody, { "", "000099", "099", "QUEROSENES DE AVIACAO" } )
	aAdd( aBody, { "", "000100", "100", "QUEROSENES ILUMINANTES" } )
	aAdd( aBody, { "", "000101", "101", "RERREFINADOS" } )
	aAdd( aBody, { "", "000102", "102", "RESIDUOS PESADOS" } )
	aAdd( aBody, { "", "000103", "103", "SINTETICOS - GRUPO IV" } )
	aAdd( aBody, { "", "000104", "104", "SINTETICOS - GRUPO V" } )
	aAdd( aBody, { "", "000105", "105", "SOLVENTES ALIFATICOS" } )
	aAdd( aBody, { "", "000106", "106", "SOLVENTES AROMATICOS" } )
	aAdd( aBody, { "", "000107", "107", "TERRA BAHIA CATU" } )
	aAdd( aBody, { "", "000108", "108", "TRANSMISSCO AUTOMATICA" } )
	aAdd( aBody, { "", "000109", "109", "TRANSMISSOES E SISTEMAS HIDRAULICOS" } )
	aAdd( aBody, { "", "000110", "110", "VASELINA" } )
	aAdd( aBody, { "", "000111", "111", "XISTO" } )
	aAdd( aBody, { "", "000112", "112", "MATÉRIA - PRIMA DE 1ª GERAÇÃO",1032.06 } )
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
