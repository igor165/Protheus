 #INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA177.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA177
Cadastro MVC de Tipos de Creditos de ICMS

@author Danilo L Zanaga
@since 10/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA177()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de Tipos de Creditos de ICMS
oBrw:SetAlias( 'C4Z')
oBrw:SetMenuDef( 'TAFA177' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Danilo L Zanaga
@since 10/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA177" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Danilo L Zanaga
@since 10/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC4Z 	:= 	FWFormStruct( 1, 'C4Z' )
Local oModel 	:= 	MPFormModel():New( 'TAFA177' )

oModel:AddFields('MODEL_C4Z', /*cOwner*/, oStruC4Z)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Danilo L Zanaga
@since 10/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA177' )
Local 	oStruC4Z 	:= 	FWFormStruct( 2, 'C4Z' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C4Z', oStruC4Z, 'MODEL_C4Z' )

oView:EnableTitleView( 'VIEW_C4Z', STR0001 ) //Cadastro de Tipos de Creditos de ICMS
oView:CreateHorizontalBox( 'FIELDSC4Z', 100 )
oView:SetOwnerView( 'VIEW_C4Z', 'FIELDSC4Z' )

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

nVerAtu := 1010

If nVerEmp < nVerAtu
	aAdd( aHeader, "C4Z_FILIAL" )
	aAdd( aHeader, "C4Z_ID" )
	aAdd( aHeader, "C4Z_CODIGO" )
	aAdd( aHeader, "C4Z_DESCRI" )
	aAdd( aHeader, "C4Z_VALIDA" )

	aAdd( aBody, { "", "000001", "AC01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000002", "AC21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000003", "AC41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000004", "AC61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000005", "AC81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000006", "AC99", "OUTROS", "" } )
	aAdd( aBody, { "", "000007", "AL01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000008", "AL21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000009", "AL41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000010", "AL61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000011", "AL81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000012", "AL99", "OUTROS", "" } )
	aAdd( aBody, { "", "000013", "AM01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000014", "AM21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000015", "AM41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000016", "AM61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000017", "AM81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000018", "AM99", "OUTROS", "" } )
	aAdd( aBody, { "", "000019", "AP01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000020", "AP21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000021", "AP41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000022", "AP61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000023", "AP81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000024", "AP99", "OUTROS", "" } )
	aAdd( aBody, { "", "000025", "BA01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000026", "BA21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000027", "BA41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000028", "BA61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000029", "BA81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000030", "BA99", "OUTROS", "" } )
	aAdd( aBody, { "", "000031", "CE01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000032", "CE21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000033", "CE41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000034", "CE61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000035", "CE81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000036", "CE99", "OUTROS", "" } )
	aAdd( aBody, { "", "000037", "DF01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000038", "DF21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000039", "DF41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000040", "DF61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000041", "DF81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000042", "DF99", "OUTROS", "" } )
	aAdd( aBody, { "", "000043", "ES01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000044", "ES21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000045", "ES41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000046", "ES61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000047", "ES81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000048", "ES99", "OUTROS", "" } )
	aAdd( aBody, { "", "000049", "GO01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000050", "GO21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000051", "GO41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000052", "GO61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000053", "GO81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000054", "GO99", "OUTROS", "" } )
	aAdd( aBody, { "", "000055", "MA01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000056", "MA21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000057", "MA41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000058", "MA61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000059", "MA81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000060", "MA99", "OUTROS", "" } )
	aAdd( aBody, { "", "000061", "MG01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000062", "MG21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000063", "MG41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000064", "MG61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000065", "MG81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000066", "MG99", "OUTROS", "" } )
	aAdd( aBody, { "", "000067", "MS01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000068", "MS21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000069", "MS41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000070", "MS61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000071", "MS81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000072", "MS99", "OUTROS", "" } )
	aAdd( aBody, { "", "000073", "MT01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000074", "MT21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000075", "MT41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000076", "MT61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000077", "MT81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000078", "MT99", "OUTROS", "" } )
	aAdd( aBody, { "", "000079", "PA01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000080", "PA21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000081", "PA41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000082", "PA61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000083", "PA81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000084", "PA99", "OUTROS", "" } )
	aAdd( aBody, { "", "000085", "PB01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000086", "PB21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000087", "PB41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000088", "PB61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000089", "PB81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000090", "PB99", "OUTROS", "" } )
	aAdd( aBody, { "", "000091", "PE01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000092", "PE21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000093", "PE41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000094", "PE61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000095", "PE81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000096", "PE99", "OUTROS", "" } )
	aAdd( aBody, { "", "000097", "PI01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000098", "PI21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000099", "PI41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000100", "PI61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000101", "PI81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000102", "PI99", "OUTROS", "" } )
	aAdd( aBody, { "", "000103", "PR01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000104", "PR21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000105", "PR41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000106", "PR61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000107", "PR81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000108", "PR99", "OUTROS", "" } )
	aAdd( aBody, { "", "000109", "RJ01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000110", "RJ21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000111", "RJ41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000112", "RJ61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000113", "RJ81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000114", "RJ99", "OUTROS", "" } )
	aAdd( aBody, { "", "000115", "RN01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000116", "RN21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000117", "RN41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000118", "RN61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000119", "RN81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000120", "RN99", "OUTROS", "" } )
	aAdd( aBody, { "", "000121", "RO01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000122", "RO21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000123", "RO41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000124", "RO61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000125", "RO81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000126", "RO99", "OUTROS", "" } )
	aAdd( aBody, { "", "000127", "RR01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000128", "RR21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000129", "RR41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000130", "RR61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000131", "RR81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000132", "RR99", "OUTROS", "" } )
	aAdd( aBody, { "", "000133", "RS01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000134", "RS21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000135", "RS41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000136", "RS61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000137", "RS81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000138", "RS99", "OUTROS", "" } )
	aAdd( aBody, { "", "000139", "SC01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000140", "SC21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000141", "SC41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000142", "SC61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000143", "SC81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000144", "SC99", "OUTROS", "" } )
	aAdd( aBody, { "", "000145", "SE01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000146", "SE21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000147", "SE41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000148", "SE61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000149", "SE81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000150", "SE99", "OUTROS", "" } )
	aAdd( aBody, { "", "000151", "SP01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000152", "SP21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000153", "SP41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000154", "SP61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000155", "SP81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000156", "SP99", "OUTROS", "" } )
	aAdd( aBody, { "", "000157", "TO01", "DEDUCAO", "" } )
	aAdd( aBody, { "", "000158", "TO21", "COMPENSACAO", "" } )
	aAdd( aBody, { "", "000159", "TO41", "TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000160", "TO61", "RESTITUICAO", "" } )
	aAdd( aBody, { "", "000161", "TO81", "ESTORNO", "" } )
	aAdd( aBody, { "", "000162", "TO99", "OUTROS", "" } )

	aAdd( aBody, { "", "000163", "MG02", "Utilização de crédito limitado para abatimento de saldo devedor", "" } )
	aAdd( aBody, { "", "000164", "MG03", "Utilização de crédito para abatimento de saldo devedor na apuração de ICMS operações próprias", "" } )
	aAdd( aBody, { "", "000165", "MG22", "Utilização de crédito para pagamento de crédito tributário", "" } )
	aAdd( aBody, { "", "000166", "MG23", "Utilização de crédito para pagamento de ICMS importação de ativo permanente", "" } )
	aAdd( aBody, { "", "000167", "MG24", "Utilização de crédito para pagamento de ICMS dif. alíquota de mercadoria p/ ativo permanente", "" } )
	aAdd( aBody, { "", "000168", "MG42", "Crédito transferido para pagamento de cotas / ações", "" } )
	aAdd( aBody, { "", "000169", "MG43", "Crédito transferido para aquisição de ativo permanente", "" } )
	aAdd( aBody, { "", "000170", "MG44", "Crédito transferido para aquisição de material de construção", "" } )
	aAdd( aBody, { "", "000171", "MG45", "Crédito transferido para aquisição de mercadoria", "" } )
	aAdd( aBody, { "", "000172", "MG46", "Crédito transferido para distribuidor de energia/comunicação ou consorciado", "" } )
	aAdd( aBody, { "", "000173", "MG47", "Crédito transferido para estabelecimento de mesma titularidade situado no Estado", "" } )
	aAdd( aBody, { "", "000174", "MG48", "Crédito transferido para outro contribuinte mineiro", "" } )
	aAdd( aBody, { "", "000175", "MG49", "Crédito transferido para contribuinte mineiro p/ instalação ou expansão do estabelecimento", "" } )
	aAdd( aBody, { "", "000176", "MG50", "Crédito transferido para estabelecimento de mesma titularidade p/ pgto. de créd. tributário", "" } )
	aAdd( aBody, { "", "000177", "MG51", "Crédito transferido para outro contribuinte mineiro para pgto. de crédito tributário", "" } )
	aAdd( aBody, { "", "000178", "MG52", "Crédito transferido para outro contribuinte mineiro para pgto. de ICMS importação", "" } )
	aAdd( aBody, { "", "000179", "MG53", "Crédito transferido para contribuinte paulista - Prot. ICMS 12/84", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
