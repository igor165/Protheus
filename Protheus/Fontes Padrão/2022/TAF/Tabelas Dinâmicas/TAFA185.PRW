#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                                 
#INCLUDE "TAFA185.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA185
Cadastro MVC dos Selo de Controle do IPI 

@author Gustavo G. Rueda
@since 16/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA185()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Selo de Controle do IPI"
oBrw:SetAlias( 'C3U')
oBrw:SetMenuDef( 'TAFA185' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Gustavo G. Rueda
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA185" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Gustavo G. Rueda
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC3U 	:= 	FWFormStruct( 1, 'C3U' )
Local oModel 	:= 	MPFormModel():New( 'TAFA185' )

oModel:AddFields('MODEL_C3U', /*cOwner*/, oStruC3U)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Gustavo G. Rueda
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA185' )
Local 	oStruC3U 	:= 	FWFormStruct( 2, 'C3U' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C3U', oStruC3U, 'MODEL_C3U' )

oView:EnableTitleView( 'VIEW_C3U', STR0001 )	//"Selo de Controle do IPI"
oView:CreateHorizontalBox( 'FIELDSC3U', 100 )
oView:SetOwnerView( 'VIEW_C3U', 'FIELDSC3U' )

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
	aAdd( aHeader, "C3U_FILIAL" )
	aAdd( aHeader, "C3U_ID" )
	aAdd( aHeader, "C3U_CODIGO" )
	aAdd( aHeader, "C3U_DESCRI" )
	aAdd( aHeader, "C3U_VALIDA" )

	aAdd( aBody, { "", "000001", "755311", "Relogios - Verde", "" } )
	aAdd( aBody, { "", "000002", "755312", "Relogios Importado - Vermelho", "" } )
	aAdd( aBody, { "", "000003", "755313", "Relogios Zona Franca Manaus Nacional - Azul", "" } )
	aAdd( aBody, { "", "000004", "755314", "Relogios Zona Franca Manaus Importado - Marrom", "" } )
	aAdd( aBody, { "", "000005", "756401", "Fosforos Importado - Vermelho", "" } )
	aAdd( aBody, { "", "000006", "758501", "Fonograficos - Verde", "" } )
	aAdd( aBody, { "", "000007", "758502", "Fonograficos Importado - Vermelho", "" } )
	aAdd( aBody, { "", "000008", "758503", "Fonograficos Exportacao - Azul-marinho", "" } )
	aAdd( aBody, { "", "000009", "758511", "Audio Visual - Amarelo", "" } )
	aAdd( aBody, { "", "000010", "758512", "Audio Visual Importado - Violeta", "" } )
	aAdd( aBody, { "", "000011", "758513", "Audio Visual Exportacao - Azul", "" } )
	aAdd( aBody, { "", "000012", "861001", "Cigarro - Verde Escuro / marrom", "" } )
	aAdd( aBody, { "", "000013", "861002", "Cigarro - Verde Claro / marrom", "" } )
	aAdd( aBody, { "", "000014", "861003", "Cigarro - Roxa / marrom", "" } )
	aAdd( aBody, { "", "000015", "861004", "Cigarro - Violeta / marrom", "" } )
	aAdd( aBody, { "", "000016", "861005", "Cigarro - Laranja / marrom", "" } )
	aAdd( aBody, { "", "000017", "861006", "Cigarro - Amarela / marrom", "" } )
	aAdd( aBody, { "", "000018", "861009", "Cigarro Estrangeiro - Vermelha / azul", "" } )
	aAdd( aBody, { "", "000019", "861010", 'Cigarro Exportacao tipo "1" - Azul-Marinho / Cinza', "" } )
	aAdd( aBody, { "", "000020", "861011", 'Cigarro Exportacao tipo "2" - Azul-Marinho / Cinza', "" } )
	aAdd( aBody, { "", "000021", "861012", 'Cigarro Exportacao tipo "3" - Verde / Azul', "" } )
	aAdd( aBody, { "", "000022", "971001", "Cigarro - Verde / marrom", "" } )
	aAdd( aBody, { "", "000023", "971002", "Cigarro - Verde Claro / marrom", "" } )
	aAdd( aBody, { "", "000024", "971003", "Cigarro - Azul / marrom", "" } )
	aAdd( aBody, { "", "000025", "971004", "Cigarro - Violeta / marrom", "" } )
	aAdd( aBody, { "", "000026", "971005", "Cigarro - Laranja / marrom", "" } )
	aAdd( aBody, { "", "000027", "971006", "Cigarro - Amarela / marrom", "" } )
	aAdd( aBody, { "", "000028", "971010", 'Cigarro Exportacao tipo "1" - Verde Escuro / marrom', "" } )
	aAdd( aBody, { "", "000029", "971011", 'Cigarro Exportacao tipo "2" - Verde Escuro / marrom', "" } )
	aAdd( aBody, { "", "000030", "971012", 'Cigarro Exportacao tipo "3" - Verde Escuro / marrom', "" } )
	aAdd( aBody, { "", "000031", "972911", "Uisque - Verde / marrom", "" } )
	aAdd( aBody, { "", "000032", "972912", "Uisque - Azul / marrom", "" } )
	aAdd( aBody, { "", "000033", "972913", "Uisque Estrangeiro - Vermelho / marrom", "" } )
	aAdd( aBody, { "", "000034", "972914", "Uisque Estrangeiro - Amarelo / marrom", "" } )
	aAdd( aBody, { "", "000035", "972921", "Uisque Miniatura - Verde / marrom", "" } )
	aAdd( aBody, { "", "000036", "972922", "Uisque Miniatura - Azul / marrom", "" } )
	aAdd( aBody, { "", "000037", "972923", "Uisque Miniatura Estrangeiro - Vermelho / marrom", "" } )
	aAdd( aBody, { "", "000038", "972924", "Uisque Miniatura Estrangeiro - Amarelo / marrom", "" } )
	aAdd( aBody, { "", "000039", "973711", "Bebida Alcoolica - Laranja / marrom", "" } )
	aAdd( aBody, { "", "000040", "973712", "Bebida Alcoolica - Cinza / marrom", "" } )
	aAdd( aBody, { "", "000041", "973713", "Bebida Alcoolica - Marrom / marrom", "" } )
	aAdd( aBody, { "", "000042", "973714", "Bebida Alcoolica - Verde / marrom", "" } )
	aAdd( aBody, { "", "000043", "973715", "Bebida Alcoolica Estrangeira - Vermelho / marrom", "" } )
	aAdd( aBody, { "", "000044", "973716", "Bebida Alcoolica Exportacao - Azul Marinho / marrom", "" } )
	aAdd( aBody, { "", "000045", "973721", "Bebida Alcoolica Miniatura - Verde / marrom", "" } )
	aAdd( aBody, { "", "000046", "973722", "Bebida Alcoolica Miniatura Estrangeira - Vermelho / marrom", "" } )
	aAdd( aBody, { "", "000047", "973723", "Bebida Alcoolica Miniatura Exportacao - Azul Marinho / marrom", "" } )
	aAdd( aBody, { "", "000048", "974511", "Aguardente - Laranja / marrom", "" } )
	aAdd( aBody, { "", "000049", "974512", "Aguardente - Azul / marrom", "" } )
	aAdd( aBody, { "", "000050", "974513", "Aguardente - Violeta / marrom", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )