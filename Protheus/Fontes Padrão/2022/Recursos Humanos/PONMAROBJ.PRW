#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PONMAROBJ

@author		Igor Franzoi
@since		04/08/2010
@version	1.0
@return		NIL
@obs		Controle dos campos do SP0 - Relógio de Ponto
/*/
//-------------------------------------------------------------------
class PONMAROBJ

	data cFilRFE	//Codigo Filial
	data cMatRFE	//Matricula do Funcionario
	data dDatRFE	//
	
	data cCodREP	//Codigo do REP
	data cEmpREP	//Codigo da Empresa
	data cIprREP	//Endereco IP do relógio        	
	data nPorREP	//Porta de enderecamento do Relogio
	data cHASH		//	
	
	Method New()
	Method setVarMem()
	Method setVarFie()	
	
endclass

//-------------------------------------------------------------------
/*/{Protheus.doc} New()

@author		Igor Franzoi
@since		04/08/2010
@version	1.0
@return		NIL
@obs		Controle dos campos do SP0 - Relógio de Ponto
/*/
//-------------------------------------------------------------------
Method New() class PONMAROBJ

	::cCodREP	:= Space( GetSx3Cache( "P0_REP" 	, "X3_TAMANHO" ) )	//Codigo do REP
	::cEmpREP	:= cEmpAnt												//Codigo da Empresa
	::cIprREP	:= Space( GetSx3Cache( "RFL_ENDIP" 	, "X3_TAMANHO" ) ) //Endereco IP do relógio        	
	::nPorREP	:= Space( GetSx3Cache( "RFL_PORTA" 	, "X3_TAMANHO" ) ) //Porta de enderecamento do Relogio
	::cHASH	:= Space( GetSx3Cache( "RFL_HASH" 	, "X3_TAMANHO" ) ) //
	
Return (Nil)