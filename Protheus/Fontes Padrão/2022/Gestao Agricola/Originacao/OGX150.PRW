#INCLUDE "OGX150.ch"
#include "totvs.ch"

/** {Protheus.doc} OGX150
Rotina responsável por chamar a tela de complemento de notas fiscais de exportação,
informações utilizadas para validação no SPEDNFE.

@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	29/04/2013
@Uso: 		SIGAAGR - Originação de Grãos
@Alterado Por: Marcelo R. Ferrari
@Alterado em: 19/08/2014
*/		
//Programa Original: ARMXPE13

//Chamada HelProg(,"FISTRFNFe") ?????
Function OGX150()
	
	/** Verifico se a nota ja foi impressa, logo os campos abaixo são preenchidos no ato da impressão. **/
	If SF2->F2_FIMP == "S" .Or.  .Not. Empty( SF2->F2_CHVNFE )
		Help( , , STR0001, ,STR0002, 1, 0 ) //"Ajuda"###"Nota Fiscal já transmitida, favor verificar!"
		Return ( .f. )	
	Endif
	
	/** Verifico se o documento é um documento de exportação **/
	If SF2->F2_EST <> "EX"
		Help(, , STR0001, ,STR0003, 1, 0 ) //"Ajuda"###"O complemento é necessário somente em notas de exportação, favor verificar!"
		Return ( .f. )
	Endif
	
	/** É verificado o Alias corrente para executar a rotina de Complemento de Nfs. **/	
	If	Alias() == "SF2"
		Mata926( SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_ESPECIE,SF2->F2_CLIENTE,SF2->F2_LOJA,"S",SF2->F2_TIPO ) 
	ElseIf	Alias() == "SF1"
		Mata926( SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_ESPECIE,SF1->F1_FORNECE,SF1->F1_LOJA,"E",SF1->F1_TIPO ) 
	Else
		Help(, , STR0001, ,STR0004, 1, 0 ) //"Ajuda"###"Opção não disponivel, favor verificar!"
	EndIf

Return