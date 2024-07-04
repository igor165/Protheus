#include "Totvs.ch"
#include "OFValLicenca.ch"

/*/
{Protheus.doc} OFValLicenca
Classe de validação do uso e existência de licenças nas rotinas do DMS.
@type   Function
@author Otávio Favarelli
@since  19/10/2021
@param  nil
@return nil
/*/
Class OFValLicenca

	Method New() CONSTRUCTOR
	Static Method ValidaLicencaDMS()
	
EndClass

/*/
{Protheus.doc} ValidaLicencaDMS
Método que realiza a validação de chamadas das rotinas do DMS para verificação do uso correto das licenças.
@type   Function
@author Otávio Favarelli
@since  19/10/2021
@param  nil
@return nil
/*/
Method ValidaLicencaDMS() Class OFValLicenca
	Local lAmiin

	FwBlkUserFunction(.t.)
	lAmiin := AMIIn(11,14,41) // 11=Veiculos | 14=Oficina | 41=Auto Pecas
	FwBlkUserFunction(.f.)

	If !lAmiin
		Aviso(STR0001,STR0002,{STR0003}) // Impossível Continuar! | As rotinas dos módulos de Varejo Automotivo – DMS só podem ser acessadas diretamente nestes módulos (SIGAOFI, SIGAVEI e SIGAPEC), que necessitam de licenciamento específico. | OK
	EndIf

Return lAmiin
