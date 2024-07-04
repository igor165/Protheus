#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA224.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA224
Cadastro MVC da Parte do Corpo Atingida

@author Anderson Costa
@since 08/08/2013
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA224()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Cadastro da Parte do Corpo Atingida"
oBrw:SetAlias( 'C8I')
oBrw:SetMenuDef( 'TAFA224' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 08/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA224" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 08/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC8I  :=  FWFormStruct( 1, 'C8I' )
Local oModel    :=  MPFormModel():New( 'TAFA224' )

oModel:AddFields('MODEL_C8I', /*cOwner*/, oStruC8I)
oModel:GetModel('MODEL_C8I'):SetPrimaryKey({'C8I_FILIAL', 'C8I_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 08/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA224' )
Local   oStruC8I    :=  FWFormStruct( 2, 'C8I' )
Local   oView       :=  FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C8I', oStruC8I, 'MODEL_C8I' )

oView:EnableTitleView( 'VIEW_C8I', STR0001 )    //"Cadastro da Parte do Corpo Atingida"
oView:CreateHorizontalBox( 'FIELDSC8I', 100 )
oView:SetOwnerView( 'VIEW_C8I', 'FIELDSC8I' )

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

nVerAtu := 1031.34

If nVerEmp < nVerAtu
	aAdd( aHeader, "C8I_FILIAL" )
	aAdd( aHeader, "C8I_ID" )
	aAdd( aHeader, "C8I_CODIGO" )
	aAdd( aHeader, "C8I_DESCRI" )
	aAdd( aHeader, "C8I_VALIDA" )

	aAdd( aBody, { "", "000001", "753030000", "CRANIO (INCLUSIVE ENCEFALO)", "" } )
	aAdd( aBody, { "", "000002", "753050000", "OUVIDO (EXTERNO, MEDIO, INTERNO, AUDICAO E EQUILIBRIO)", "" } )
	aAdd( aBody, { "", "000003", "753070100", "OLHO (INCLUSIVE NERVO OTICO E VISAO)", "" } )
	aAdd( aBody, { "", "000004", "753070300", "NARIZ (INCLUSIVE FOSSAS NASAIS, SEIOS DA FACE E OLFATO)", "" } )
	aAdd( aBody, { "", "000005", "753070500", "BOCA (INCLUSIVE LABIOS, DENTES, LINGUA, GARGANTA E PALADAR)", "" } )
	aAdd( aBody, { "", "000006", "753070700", "MANDIBULA (INCLUSIVE QUEIXO)", "" } )
	aAdd( aBody, { "", "000007", "753070800", "FACE, PARTES MULTIPLAS (QUALQUER COMBINACAO DAS PARTES ACIMA)", "" } )
	aAdd( aBody, { "", "000008", "753080000", "CABECA, PARTES MULTIPLAS (QUALQUER COMBINACAO DAS PARTES ACIMA)", "" } )
	aAdd( aBody, { "", "000009", "753090000", "CABECA, NIC", "" } )
	aAdd( aBody, { "", "000010", "753510000", "BRACO (ENTRE O PUNHO A O OMBRO)", "" } )
	aAdd( aBody, { "", "000011", "753510200", "BRACO (ACIMA DO COTOVELO)", "" } )
	aAdd( aBody, { "", "000012", "754000000", "PESCOCO", "" } )
	aAdd( aBody, { "", "000013", "755010400", "COTOVELO", "" } )
	aAdd( aBody, { "", "000014", "755010600", "ANTEBRACO (ENTRE O PUNHO E O COTOVELO)", "" } )
	aAdd( aBody, { "", "000015", "755030000", "PUNHO", "" } )
	aAdd( aBody, { "", "000016", "755050000", "MAO (EXCETO PUNHO OU DEDOS)", "" } )
	aAdd( aBody, { "", "000017", "755070000", "DEDO", "" } )
	aAdd( aBody, { "", "000018", "755080000", "MEMBROS SUPERIORES, PARTES MULTIPLAS (QUALQUER COMBINACAO DAS PARTES ACIMA)", "" } )
	aAdd( aBody, { "", "000019", "755090000", "MEMBROS SUPERIORES, NIC", "" } )
	aAdd( aBody, { "", "000020", "756020000", "OMBRO", "" } )
	aAdd( aBody, { "", "000021", "756030000", "TORAX (INCLUSIVE ORGAOS INTERNOS)", "" } )
	aAdd( aBody, { "", "000022", "756040000", "DORSO (INCLUSIVE MUSCULOS DORSAIS, COLUNA E MEDULA ESPINHAL)", "" } )
	aAdd( aBody, { "", "000023", "756050000", "ABDOME (INCLUSIVE ORGAOS INTERNOS)", "" } )
	aAdd( aBody, { "", "000024", "756060000", "QUADRIS (INCLUSIVE PELVIS, ORGAOS PELVICOS E NADEGAS)", "" } )
	aAdd( aBody, { "", "000025", "756070000", "TRONCO, PARTE MULTIPLAS (QUALQUER COMBINACAO DAS PARTES ACIMA)", "" } )
	aAdd( aBody, { "", "000026", "756090000", "TRONCO, NIC", "" } )
	aAdd( aBody, { "", "000027", "757010000", "PERNA (ENTRE O TORNOZELO E A PELVIS)", "" } )
	aAdd( aBody, { "", "000028", "757010200", "COXA", "" } )
	aAdd( aBody, { "", "000029", "757010400", "JOELHO", "" } )
	aAdd( aBody, { "", "000030", "757010600", "PERNA (DO TORNOZELO, EXCLUSIVE, AO JOELHO, EXCLUSIVE)", "" } )
	aAdd( aBody, { "", "000031", "757030000", "ARTICULACAO DO TORNOZELO", "" } )
	aAdd( aBody, { "", "000032", "757050000", "PE (EXCETO ARTELHOS)", "" } )
	aAdd( aBody, { "", "000033", "757070000", "ARTELHO", "" } )
	aAdd( aBody, { "", "000034", "757080000", "MEMBROS INFERIORES, PARTES MULTIPLAS (QUALQUER COMBINACAO DAS PARTES ACIMA)", "" } )
	aAdd( aBody, { "", "000035", "757090000", "MEMBROS INFERIORES, NIC", "" } )
	aAdd( aBody, { "", "000036", "758000000", "PARTES MULTIPLAS - APLICA-SE QUANDO MAIS DE UMA PARTE IMPORTANTE DO CORPO FOR AFETADA, COMO POR EXEMPLO, UM BRACO E UMA PERNA", "" } )
	aAdd( aBody, { "", "000037", "758500000", "SISTEMAS E APARELHOS - APLICA-SE QUANDO O FUNCIONAMENTO DE TODO UM SISTEMA OU APARELHO DO CORPO HUMANO FOR AFETADO, SEM LESAO ESPECIFICA DE QUALQUER OUTRA PARTE, COMO NO CASO DO ENVENENAMENTO, ACAO CORROSIVA QUE AFETE OR", "" } )
	aAdd( aBody, { "", "000038", "758520000", "APARELHO CIRCULATORIO", "" } )
	aAdd( aBody, { "", "000039", "758530000", "APARELHO RESPIRATORIO", "" } )
	aAdd( aBody, { "", "000040", "758540000", "SISTEMA NERVOSO", "" } )
	aAdd( aBody, { "", "000041", "758550000", "APARELHO DIGESTIVO", "" } )
	aAdd( aBody, { "", "000042", "758560000", "APARELHO GENITO-URINARIO", "" } )
	aAdd( aBody, { "", "000043", "758570000", "SISTEMA MUSCULO-ESQUELETICO", "" } )
	aAdd( aBody, { "", "000044", "758590000", "SISTEMAS E APARELHOS, NIC", "" } )
	aAdd( aBody, { "", "000045", "759000000", "LOCALIZAÇÃO DA LESÃO, NIC", "" } ) 

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
