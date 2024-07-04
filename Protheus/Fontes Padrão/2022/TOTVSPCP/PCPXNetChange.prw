#INCLUDE "TOTVS.CH"

Static _lNetChOn := Nil

/*/{Protheus.doc} netChAtivo
Retorna se o Net Change est� ativo no sistema

@author ricardo.prandi	
@since 06/03/2020
@version 12.1.30
@return Logico - Indica se o Net Change est� ativo (.T. - Sim; .F. - N�o)
/*/

Function netChAtivo()

	If _lNetChOn == NIL
		
		_lNetChOn := "2"
		
		If FWAliasInDic("HWL",.F.)
			dbSelectArea("HWL")
			If HWL->(DBSeek(xFilial("HWL")+"1"))
				_lNetChOn := HWL->HWL_NETCH
			EndIf
		EndIf
	EndIf

Return _lNetChOn


/*/{Protheus.doc} gravaHWJ
Grava a produto alterado na tabela do NetChange.

@author ricardo.prandi	
@since 06/03/2020
@version 12.1.30
@param 01 - cProduto - C�digo do Produto que sera gravado
@param 02 - cEvento  - Tipo do evento a ser gravado (1-Altera��o; 2-Exclus�o)
@param 03 - cOrigem  - Origem da altera��o (1-Produtos; 2-Demandas ; 3-Saldos ; 4-OP; 5-SC; 6-Estrutura; 7-Vers�o da Produ��o; 8-SBZ; 9-Empenhos)
@param 04 - cFilProd - C�digo da Filial onde o produto est� sendo alterado
@return Nil
/*/
Function gravaHWJ(cProduto, cEvento, cOrigem, cFilProd)
	Default cFilProd := cFilAnt
	
	//Se j� existir o produto na tabela, n�o tem necessidade de incluir ou atualizar
	If !HWJ->(dbSeek(xFilial("HWJ",cFilProd)+cProduto))
		RecLock("HWJ",1)
			Replace HWJ_FILIAL With xFilial("HWJ",cFilProd)
			Replace HWJ_PROD   With cProduto
			Replace HWJ_ORIGEM With cOrigem
			Replace HWJ_EVENTO With cEvento
		HWJ->(MsUnlock())
	EndIf
Return