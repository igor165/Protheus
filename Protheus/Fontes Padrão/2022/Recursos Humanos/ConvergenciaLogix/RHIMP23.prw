#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/********************************************************************************##
***********************************************************************************
***********************************************************************************
***Func�o.....: RHIMP23.prw Autor: PHILIPE.POMPEU Data:05/10/2015 	       	   ***
***********************************************************************************
***Descri��o..: Gerador dos Per�odos      										   ***
***********************************************************************************
***Uso........:        																   ***
***********************************************************************************
***Par�metros.:		${param}, ${param_type}, ${param_descr}               	   ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                          	   ***
***********************************************************************************
***					ALTERA��ES FEITAS DESDE A CONSTRU��O INICIAL       			   ***
***********************************************************************************
***Chamado....:                                                    			   ***
**********************************************************************************/
User Function RHIMP23()
	Local aTabelas	:= {"RCF","RCG","RCH","RFQ"}
	Local cEmpOrig	:= Nil
	Private cAnoMes := Substr( Dtos(dDatabase) , 1, 6)	
	
	SM0->(DbGoTop())	
	while ( SM0->(!Eof()) )
	
		U_RHPREARE(SM0->M0_CODIGO,SM0->M0_CODFIL,'','',.T.,.T.,"RHIMP23",aTabelas,"GPE",{},"Per�odos")	
		if(cEmpOrig <> xFilial("RCH"))		
			cEmpOrig := xFilial("RCH")
			MsAguarde( {||GpeConvPER()} , "Gerando Per�odos["+ cEmpOrig +"]")
		endIf	
		
		SM0->(dbSkip())
	EndDo
	
Return(.T.)
