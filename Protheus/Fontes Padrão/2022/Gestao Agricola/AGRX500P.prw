#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "AGRX500P.ch"

/*/{Protheus.doc} AX500PSVen
Fun��o chamada na sa�da por venda com lan�amento de produ��o
@author silvana.torres
@since 10/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cNumOP, characters, descricao
@type function
/*/
Function AX500PSVen(cNumOP)
	Local lRet		:= .T.

	//Verifica se Lan�a produ��o (flag no tipo de opera��o)
   	If AGRX500LP(NJJ->NJJ_TOETAP)
	
		IF .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_LOCAL)
			if Empty(cNumOP)
				//-- Gera ordem de produ��o
				Processa({|| lRet := A500GERAOP(@cNumOP, NJJ->NJJ_CODPRO, NJJ->NJJ_PSLIQU, NJJ->NJJ_LOCAL, 3) }, STR0002 , STR0001 )	//"Gerando Ordem de Produ��o..."###"Aguarde"
			endIf
				
			//-- Realiza o apontamento da OP 
			If lRet
				Processa({|| lRet := A500APROD(cNumOP, NJJ->NJJ_CODROM, NJJ->NJJ_CODPRO, NJJ->NJJ_PSLIQU, NJJ->NJJ_LOCAL, 3) }, STR0003, STR0001 ) //"Movimentando Ordem de Produ��o..."###"Aguarde"
			EndIf
		endIf
	EndIf
	
Return lRet