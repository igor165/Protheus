#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/********************************************************************************##
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP23.prw Autor: PHILIPE.POMPEU Data:05/10/2015 	       	   ***
***********************************************************************************
***Descrição..: Gerador dos Períodos      										   ***
***********************************************************************************
***Uso........:        																   ***
***********************************************************************************
***Parâmetros.:		${param}, ${param_type}, ${param_descr}               	   ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                          	   ***
***********************************************************************************
***					ALTERAÇÕES FEITAS DESDE A CONSTRUÇÃO INICIAL       			   ***
***********************************************************************************
***Chamado....:                                                    			   ***
**********************************************************************************/
User Function RHIMP23()
	Local aTabelas	:= {"RCF","RCG","RCH","RFQ"}
	Local cEmpOrig	:= Nil
	Private cAnoMes := Substr( Dtos(dDatabase) , 1, 6)	
	
	SM0->(DbGoTop())	
	while ( SM0->(!Eof()) )
	
		U_RHPREARE(SM0->M0_CODIGO,SM0->M0_CODFIL,'','',.T.,.T.,"RHIMP23",aTabelas,"GPE",{},"Períodos")	
		if(cEmpOrig <> xFilial("RCH"))		
			cEmpOrig := xFilial("RCH")
			MsAguarde( {||GpeConvPER()} , "Gerando Períodos["+ cEmpOrig +"]")
		endIf	
		
		SM0->(dbSkip())
	EndDo
	
Return(.T.)
