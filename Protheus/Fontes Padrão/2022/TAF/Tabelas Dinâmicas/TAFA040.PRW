#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA040.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA040
Cadastro MVC dos Campos do Cadastro de Participantes

@author Fabio V. Santana
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA040()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Campos do Cadastro de Participantes
oBrw:SetAlias( 'C1R')
oBrw:SetMenuDef( 'TAFA040' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA040" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC1R 	:= 	FWFormStruct( 1, 'C1R' )
Local oModel 	:= 	MPFormModel():New( 'TAFA040' )

oModel:AddFields('MODEL_C1R', /*cOwner*/, oStruC1R)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA040' )
Local 	oStruC1R 	:= 	FWFormStruct( 2, 'C1R' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C1R', oStruC1R, 'MODEL_C1R' )

oView:EnableTitleView( 'VIEW_C1R', STR0001 ) //Campos do Cadastro de Participantes
oView:CreateHorizontalBox( 'FIELDSC1R', 100 )
oView:SetOwnerView( 'VIEW_C1R', 'FIELDSC1R' )

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

nVerAtu := 1016

If nVerEmp < nVerAtu
	aAdd( aHeader, "C1R_FILIAL" )
	aAdd( aHeader, "C1R_ID" )
	aAdd( aHeader, "C1R_CODIGO" )
	aAdd( aHeader, "C1R_NOME" )
	aAdd( aHeader, "C1R_DESCRI" )

	aAdd( aBody, { "", "000001", "002", "CODPAR", "CODIGO DE IDENTIFICACAO DO PARTICIPANTE NO ARQUIVO" } )
	aAdd( aBody, { "", "000002", "003", "NOME", "NOME PESSOAL OU EMPRESARIAL DO PARTICIPANTE." } )
	aAdd( aBody, { "", "000003", "004", "CODPAI", "CODIGO DO PAIS DO PARTICIPANTE, CONFORME A TABELA INDICADA NO ITEM 3.2.1." } )
	aAdd( aBody, { "", "000004", "005", "CNPJ", "CNPJ DO PARTICIPANTE." } )
	aAdd( aBody, { "", "000005", "006", "CPF", "CPF DO PARTICIPANTE." } )
	aAdd( aBody, { "", "000006", "007", "IE", "INSCRICAO ESTADUAL DO PARTICIPANTE." } )
	aAdd( aBody, { "", "000007", "008", "CODMUN", "CODIGO DO MUNICIPIO, CONFORME A TABELA IBGE" } )
	aAdd( aBody, { "", "000008", "009", "SUFRAM", "NUMERO DE INSCRICAO DO PARTICIPANTE NA SUFRAMA" } )
	aAdd( aBody, { "", "000009", "010", "TPLOGR", "TIPO DE LOGRADOURO" } )
	aAdd( aBody, { "", "000010", "011", "END", "LOGRADOURO E ENDERECO DO IMOVEL" } )
	aAdd( aBody, { "", "000011", "012", "NUM", "NUMERO DO IMOVEL" } )
	aAdd( aBody, { "", "000012", "013", "COMPL", "DADOS COMPLEMENTARES DO ENDERECO" } )
	aAdd( aBody, { "", "000013", "014", "TPBAIR", "TIPO DO BAIRRO" } )
	aAdd( aBody, { "", "000014", "015", "BAIRRO", "BAIRRO EM QUE O IMOVEL ESTA SITUADO" } )	
	aAdd( aBody, { "", "000015", "016", "UF", "SIGLA DA UNIDADE DA FEDERACAO DO ESTABELECIMENTO." } )
	aAdd( aBody, { "", "000016", "017", "CEP", "CODIGO DE ENDERECAMENTO POSTAL." } )
	aAdd( aBody, { "", "000017", "018", "DDD", "DDD DO NUMERO DE TELEFONE" } )
	aAdd( aBody, { "", "000018", "019", "FONE", "NUMERO DO TELEFONE." } )
	aAdd( aBody, { "", "000019", "020", "DDDFAX", "DDD DO NUMERO DE FAX" } )
	aAdd( aBody, { "", "000020", "021", "FAX", "NUMERO DO FAX." } )
	aAdd( aBody, { "", "000021", "022", "EMAIL", "ENDERECO DO CORREIO ELETRONICO." } )
	aAdd( aBody, { "", "000022", "023", "DTINCL", "DATA DA INCLUSAO DO PARTICIPANTE NO ERP" } )
	aAdd( aBody, { "", "000023", "024", "PPES", "TIPO DE PESSOA" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )