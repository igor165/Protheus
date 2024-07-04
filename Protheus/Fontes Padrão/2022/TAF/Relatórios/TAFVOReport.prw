#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFVOReport
@type			class
@description	Objeto ( Value Object ) para utilização nos relatórios totalizadores.
@author			Victor A. Barbosa
@since			27/05/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Class TAFVOReport From LongClassName

	Data cIndApu
	Data cPeriodo
	Data cCPF
	Data cNome
	Data cRecibo
	Data aAnalitico

	Method New() Constructor
	Method SetIndApu()
	Method SetPeriodo()
	Method SetCPF()
	Method SetNome()
	Method SetRecibo()
	Method SetAnalitico()
	Method GetIndApu()
	Method GetPeriodo()
	Method GetCPF()
	Method GetNome()
	Method GetRecibo()
	Method GetAnalitico()
	Method Clear()

EndClass

//---------------------------------------------------------------------
/*/{Protheus.doc} New
@type			method
@description	Retorna a instância do objeto.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@return			self - Objeto para utilização nos relatórios totalizadores
/*/
//---------------------------------------------------------------------
Method New() Class TAFVOReport

self:cIndApu	:=	""
self:cPeriodo	:=	""
self:cCPF		:=	""
self:cNome		:=	""
self:cRecibo	:=	""
self:aAnalitico	:=	{}

Return( self )

//---------------------------------------------------------------------
/*/{Protheus.doc} SetIndApu
@type			method
@description	Seta a propriedade do Indicador do Período.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@param			cIndApu - Indicador do Período
/*/
//---------------------------------------------------------------------
Method SetIndApu( cIndApu ) Class TAFVOReport

self:cIndApu := cIndApu

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} SetPeriodo
@type			method
@description	Seta a propriedade do Período.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@param			cPeriodo - Período
/*/
//---------------------------------------------------------------------
Method SetPeriodo( cPeriodo ) Class TAFVOReport

self:cPeriodo := cPeriodo

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} SetCPF
@type			method
@description	Seta a propriedade do CPF.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@param			cCPF - CPF do Trabalhador
/*/
//---------------------------------------------------------------------
Method SetCPF( cCPF ) Class TAFVOReport

self:cCPF := cCPF

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} SetNome
@type			method
@description	Seta a propriedade do Nome.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@param			cNome - Nome do Trabalhador
/*/
//---------------------------------------------------------------------
Method SetNome( cNome ) Class TAFVOReport

self:cNome := cNome

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} SetRecibo
@type			method
@description	Seta a propriedade do Recibo.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@param			cRecibo - Recibo do Evento
/*/
//---------------------------------------------------------------------
Method SetRecibo( cRecibo ) Class TAFVOReport

self:cRecibo := cRecibo

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} SetAnalitico
@type			method
@description	Adiciona o array com os dados analiticos/valores.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@param			aAnalitico - Array com os dados analíticos/valores
/*/
//---------------------------------------------------------------------
Method SetAnalitico( aAnalitico ) Class TAFVOReport

self:aAnalitico := aAnalitico

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GetIndApu
@type			method
@description	Busca a propriedade do Indicador do Período.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@return			self:cIndApu - Indicador do Período
/*/
//---------------------------------------------------------------------
Method GetIndApu() Class TAFVOReport
Return( self:cIndApu )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetPeriodo
@type			method
@description	Busca a propriedade do Período.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@return			self:cPeriodo - Período
/*/
//---------------------------------------------------------------------
Method GetPeriodo() Class TAFVOReport
Return( self:cPeriodo )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetCPF
@type			method
@description	Busca a propriedade do CPF.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@return			self:cCPF - CPF do Trabalhador
/*/
//---------------------------------------------------------------------
Method GetCPF() Class TAFVOReport
Return( self:cCPF )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetNome
@type			method
@description	Busca a propriedade do Nome.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@return			self:cNome - Nome do Trabalhador
/*/
//---------------------------------------------------------------------
Method GetNome() Class TAFVOReport
Return( self:cNome )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetRecibo
@type			method
@description	Busca a propriedade do Recibo.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@return			self:cRecibo - Recibo do Evento
/*/
//---------------------------------------------------------------------
Method GetRecibo() Class TAFVOReport
Return( self:cRecibo )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetAnalitico
@type			method
@description	Busca o array com os dados analiticos/valores.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@return			self:aAnalitico - Array com os dados analíticos/valores
/*/
//---------------------------------------------------------------------
Method GetAnalitico() Class TAFVOReport
Return( self:aAnalitico )

//---------------------------------------------------------------------
/*/{Protheus.doc} Clear
@type			method
@description	Zera os atributos.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Method Clear() Class TAFVOReport

self:cIndApu	:=	""
self:cPeriodo	:=	""
self:cCPF		:=	""
self:cNome		:=	""
self:cRecibo	:=	""
self:aAnalitico	:=	{}

Return()