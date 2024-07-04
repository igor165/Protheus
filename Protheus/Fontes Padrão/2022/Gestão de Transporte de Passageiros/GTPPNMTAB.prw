#Include 'Protheus.ch'
#Include 'poncalen.ch'

/*/{Protheus.doc} GTPPNMTAB
processamento do calend�rio de acordo com configura��es do GTP
@type  Function
@author user
@since 21/03/2022
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPPNMTAB(aTabCalend, lCriaCalOk, cFil, cMat)
    
Local aCalend 		:= aTabCalend
Local cMatricula 	:= cMat
Local cFilSra	 	:= cFil

//Busca se o que est� em uso � o m�dulo do Gest�o de Transporte de Passageiros	
If ( Valtype(cMatricula) == "C" .And. GTPIsInUse(cFilSra,cMatricula) .And. Len(aCalend) > 0 )	 
	
	If ( FwIsInCallStack("GTPA311") )
		GTPSetCalendPonto(aCalend)
	EndIf

Endif

Return aCalend


//------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIsInUse
Fun��o que valida se o m�dulo SIGAGTP est� sendo utilizado pelo sistema Protheus. Isto porque o Ponto
de Entrada PNMTABC01 que faz uso das fun��es deste arquivo fonte s�o exclusivas para atualizar o array aCalend
de acordo com o m�dulo de Gest�o de Transporte de Passageiros. Por�m o dito ponto de entrada tamb�m pode
ser utilizado pelo m�dulo SIGATEC para atualiza��o de aCalend conforme agendas do m�d. Gest�o de Servi�os. 
@type function
@author Fernando Radu Muscalu
@since 28/01/2015
@version 1.0
@param cMatricula, character, (C�digo da matr�cula do funcion�rio)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GTPIsInUse(cFilSra,cMatricula) 

Local lRet		:= .t.

Local aAreaGYG	:= GYG->(GetArea())

Default cFilSra 	:= SRA->RA_FILIAL
Default cMatricula 	:= SRA->RA_MAT

If ( SX2->(DbSeek("GYG")) .And. Select("GYG") > 0 )
	
	GYG->(DbSetOrder(6)) //GYG_FILIAL, GYG_FILSRA, GYG_FUNCIO
	
	lRet := GYG->(DbSeek(xFilial("GYG") + Padr(cFilSra, TamSx3("GYG_FILSRA")[1]) + Padr(cMatricula, TamSx3("GYG_FUNCIO")[1])))
	
Endif

RestArea(aAreaGYG)

Return(lRet)

/*/{Protheus.doc} GTPExecPNM
Retorna se efetua valida��o ou n�o do ponto vindo do GTP
@type  Function
@author user
@since 21/03/2022
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPExecPNM()
    Local lUsaGtp  := GTPGetRules('ISGTPPNMTA',,,".T.")
Return lUsaGtp
