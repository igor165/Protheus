#Include 'Protheus.ch'
#INCLUDE "plsxmov.ch"
#include "PLSMGER.CH"
#include "PLSMCCR.CH"
#INCLUDE 'APWEBEX.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRETOFF

Retorna informa寤es dos procedimentos autorizados para a consulta, de acordo com o aDados e aItens

@author Roberto Vanderlei
@since 02/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSRETOFF(cNumAut, cErro)

LOCAL nVlrTPF   	:= 0
local aMatInf 		:= {}
local aEventosAut 	:= {}
local cMsgClient	:= "Guia gerada com Sucesso"
LOCAL lAto			:= .F.
LOCAL dDPrAH		:= CtoD("")
LOCAL nQtdDiAut   	:= 0

Default cErro		:= ""

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Retorno																	 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aRetorno := {IIF(cErro == "", .T., .F.),;																//1
			 cNumAut,; 	 //Pegar da BD5															//2
			 "",;	//3
			 {},;																				//4
			 aEventosAut,;																		//5
			 {},;																				//6
			 nVlrTPF,;																			//7
			 "",;																				//8
			 IIF(cErro == "", "Guia gerada com Sucesso", "Ocorreu um erro: " + cErro),;																		//9
			 aMatInf,;																			//10
			 lAto,;																				//11
			 dDPrAH,;                                                                    		//12
			 AllTrim( Str(nQtdDiAut) ),;                                                   		//13
			 CtoD("") }				  									//14
			 
Return aRetorno