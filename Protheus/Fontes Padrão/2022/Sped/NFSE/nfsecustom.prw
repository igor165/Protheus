// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : nfsecustom
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 17/10/17 | TOTVS | Developer Studio | Gerado pelo Assistente de Código
// ---------+-------------------+-----------------------------------------------------------

#include "PROTHEUS.CH"
//Customização para Princesa dos Campos NFS-e Curitiba - NÃO DIVULGAR E NÃO UTILIZAR EM OUTRO CLIENTE
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIGAMATNFSE
Permite a manutenção de dados armazenados em .

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     17/10/2017
/*/
//------------------------------------------------------------------------------------------
CLASS SIGAMATNFSE
	// Declaração das variaveis
	DATA M0_INSCM	as string
	DATA M0_INSC	as string
	DATA M0_CGC		as string
	DATA M0_NOME	as string
	DATA M0_NOMECOM	as string
	DATA M0_CODMUN	as string
	DATA M0_ESTENT	as string
	DATA M0_CODIGO	as string
	DATA M0_CODFIL	as string
	DATA M0_TPINSC	as string
	DATA M0_ENDENT	as string
	DATA M0_CEPENT	as string
	DATA M0_BAIRENT	as string
	DATA M0_CIDENT	as string
	DATA M0_COMPENT	as string
	DATA M0_TEL		as string
	DATA M0_FAX		as string
	DATA M0_NIRE	as string
	DATA M0_DTRE	as date
	DATA M0_ESTCOB	as string
	DATA M0_CIDCOB	as string
	DATA M0_ENDCOB	as string
	DATA M0_COMPCOB	as string
	DATA M0_BAIRCOB	as string
	DATA M0_CEPCOB	as string

	// Declaração dos Métodos da Classe
	METHOD New() CONSTRUCTOR
ENDCLASS

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIGAMATNFSE
Permite a manutenção de dados armazenados em .

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     17/10/2017
/*/
//------------------------------------------------------------------------------------------
METHOD New() Class SIGAMATNFSE
	::M0_INSCM	:= ''
	::M0_INSC	:= ''
	::M0_CGC	:= ''
	::M0_NOME	:= ''
	::M0_NOMECOM:= ''
	::M0_CODMUN	:= ''
	::M0_ESTENT	:= ''
	::M0_CODIGO	:= ''
	::M0_CODFIL	:= ''
	::M0_TPINSC	:= ''
	::M0_ENDENT	:= ''
	::M0_CEPENT	:= ''
	::M0_BAIRENT:= ''
	::M0_CIDENT	:= ''
	::M0_COMPENT:= ''
	::M0_TEL	:= ''
	::M0_FAX	:= ''
	::M0_NIRE	:= ''
	::M0_DTRE	:= ctod( '' )
	::M0_ESTCOB	:= ''
	::M0_CIDENT	:= ''
	::M0_CIDCOB	:= ''
	::M0_ENDCOB	:= ''
	::M0_COMPCOB:= ''
	::M0_BAIRCOB:= ''
	::M0_CEPCOB	:= ''
Return Self
//--< fim de arquivo >----------------------------------------------------------------------
