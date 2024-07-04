#include "protheus.ch"

/*/{Protheus.doc} OFFornecedor
	@author       Andre Luis Almeida
	@since        24/04/2019
	@description  Classe de Fornecedor
/*/
Class OFFornecedor
	Method New() CONSTRUCTOR
	Method Bloqueado()
EndClass

/*/{Protheus.doc} New
	Construtor simples OFFornecedor

	@author Andre Luis Almeida
	@since 24/04/2019
/*/
Method New() CLASS OFFornecedor
Return SELF

/*/{Protheus.doc} Bloqueado
	Verifica se o Fornecedor esta bloqueado e mostra mensagem caso precise

	@author Andre Luis Almeida
	@since 24/04/2019
	@version undefined
	@param cA2_COD, characters, Codigo do Fornecedor
	@param cA2_LOJA, characters, Loja do Fornecedor
	@param lShowHlp, logical, Se deve ou nao mostrar mensagem de erro
	@return lBloq, logical, Se Fornecedor esta ou nao bloqueado
	@type function
/*/
Method Bloqueado(cA2_COD, cA2_LOJA, lShowHlp) Class OFFornecedor
	Local cMsg       := ""
	Local lBloq      := .F.
	Local aArea      := GetArea()
	Local aAreaA2    := SA2->(GetArea())
	Default lShowHlp := .T.

	dbSelectarea('SA2')
	dbSetOrder(1)
	msSeek(xFilial('SA2') + cA2_COD + cA2_LOJA)

	if SA2->( Found() ) .AND. SA2->A2_MSBLQL == '1'
		lBloq := .T.
	end

	if lBloq .AND. lShowHlp
		cMsg := chr(13) + chr(10) + "SA2" + chr(13) + chr(10)
		cMsg += RetTitle("A2_COD")  + ":" + SA2->A2_COD  + chr(13) + chr(10)
		cMsg += RetTitle("A2_LOJA") + ":" + SA2->A2_LOJA + chr(13) + chr(10)
		HELP(" ",1,"REGBLOQ",,cMsg,3,1)
	end

	RestArea( aAreaA2 )
	RestArea( aArea   )
Return lBloq