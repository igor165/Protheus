////////////////
// Versao 004 //
////////////////

#include "protheus.ch"

Function VEICLSAA()
Return()

/*/{Protheus.doc} DMS_ArrayHelper

	@author       Vinicius Gati
	@since        02/05/2014
	@description  Helper para manipulação de arrays no protheus
/*/
Class DMS_ArrayHelper
	Method New() CONSTRUCTOR
	Method Join()
	Method Map()
	Method Merge()
	Method LastIndex()
	Method Count()
	Method Select()
	Method Sum()
	Method SumBlk()
	Method Each()
	Method Uniq()
	Method AASCAN()
	Method Eq()
	Method Exists()
	Method GroupBy()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_ArrayHelper
	@author Vinicius Gati
	@since 05/05/2014
/*/
Method New() Class DMS_ArrayHelper
Return SELF

/*/{Protheus.doc} Count
	Usado para contar numero de registros que seja compativel com o retorno do bloco passado por parametro que normalmente é usado para filtro

	@author  Vinicius Gati
	@since   05/05/2014
	@param   bBlock , bloco , Bloco que deve retornar .T. ou .F. para filtrar os dados como um seletor e definir se vai somar +1 ao Count
	@example DMS_DataContainer:Count()

/*/
Method Count(aArr, bBlock) Class DMS_ArrayHelper
	Local nQtd := 0
	If VALTYPE(bBlock) == 'B'
		AEVAL(aArr, { |el| IIF( EVAL(bBlock, el) , nQtd++, Nil ) })
	Else
		nQtd := Len(aArr)
	EndIf
Return nQtd

/*/{Protheus.doc} Exists
	Verifica se um valor X esta contido em um array
	Tomar cuidado com os dados do array, devem ser do mesmo tipo

	@author  Vinicius Gati
	@since   13/06/2017
	@param   aArr, Array, Coleção onde o valor deverá estar contido
	@param   uVal,   Any, Valor que será pesquisado no Array
	@example aArrHlp:Exists({1,2,3,4}, 4) => .T.<br>
	aArrHlp:Exists({1,2,3,4}, 6) => .F.<br>
	aArrHlp:Exists({'arroz','feijão','farofa'}, 'arroz') => .T.<br>

/*/
Method Exists(aArr, uVal) Class DMS_ArrayHelper
	Local nIdx := 1
	For nIdx := 1 to Len(aArr)
		if aArr[nIdx] == uVal
			return .T. // se estiver contido na lista de valores validos
		end
	Next
Return .F.

/*/{Protheus.doc} GroupBy
	Retorna um array agrupando pela coluna e somando as outras caso os valores sejam numericos
	
	@type function
	@author Vinicius Gati
	@since 08/01/2018
/*/
Method GroupBy(aArr, nCol) Class DMS_ArrayHelper
	Local aArrGrp := {}
	Local nX := 1

	For nX := 1 to Len(aArr)
		nIdx := ASCAN(aArrGrp, {|aEl| aEl[1] == aArr[nX, nCol] })
		if nIdx == 0
			AADD(aArrGrp, {aArr[nX, nCol], { aArr[nX] }} )
			loop
		else
			AADD(aArrGrp[nIdx, 2], aArr[nX])
		endif
	next
Return aArrGrp

/*/{Protheus.doc} Join
	Junta os elementos do array como string com a string passada por parametro no cJoinStr

	@author Vinicius Gati
	@since 05/05/2014
	@param aArr    , Array , Array de strings usado para fazer join
	@param cJoinStr, String, String usada no join
	@example 'Gosto de comer:' + Join({'banana', 'maçã', 'uva'}, ', ')
						Returns: 'banana, maçã, uva'
						Same As: 'Gosto de comer:' + 'banana, maçã, uva'
/*/
Method Join(aArr, cJoinStr) Class DMS_ArrayHelper
	Local nIdx := 1
	Local cAux := ''
	For nIdx := 1 To Len(aArr)
		cAux += aArr[nIdx]
		If nIdx < Len(aArr)
			cAux += cJoinStr
		EndIf
//  'Arroz' + ', '(cJoinStr) ...e assim vai...
	Next
Return cAux

/*/{Protheus.doc} Map
	Transforma aArr em outro array modificado de acordo como bBlock

	@author   Vinicius Gati
	@since    05/05/2014
	@param    aArr    , Array, Array que será modificado de acordo com a execução do bloco
	@param    bBlock  , Bloco, String usada no join
	@example  'Gosto de comer:' + Join({'banana', 'maçã', 'uva'}, ', ')
						Returns: 'banana, maçã, uva'
						Same As: 'Gosto de comer:' + 'banana, maçã, uva'
/*/
Method Map(aArr, bBlock) Class DMS_ArrayHelper
	Local aNewArr := {}
	Local nIdx    := 1

	If VALTYPE(bBlock) == 'B'
		For nIdx := 1 To Len(aArr)
			AADD(aNewArr, EVAL(bBlock, aArr[nIdx]))
		Next
	Else
		aNewArr := aArr
	EndIf
Return IIF( Empty(aNewArr), aArr, aNewArr )

/*/{Protheus.doc} Merge
	Faz um merge dos itens do array2 no array1
	
	@type function
	@author Vinicius Gati
	@since 04/10/2017
/*/
Method Merge(aArr1, aArr2) Class DMS_ArrayHelper
	local nIdx := 1
	For nIdx:= 1 to Len(aArr2)
		AADD(aArr1, aArr2[nIdx])
	Next
Return aArr1

/*/{Protheus.doc} LastIndex
	Retorna .T. caso nIdx seja o indice final do array e .F. caso contrario

	@author   Vinicius Gati
	@since    05/05/2014
	@param    nIdx  , numeroico, Indice de teste
	@param    aArr  , Array, Array
	@example  IIF(oArrHlp:LastIndex(nIdx, aArr), .T., .F.) // => .T.
/*/
Method LastIndex(nIdx, aArr) Class DMS_ArrayHelper
Return  nIdx == Len(aArr)

/*/{Protheus.doc} Select
	Avalia os elementos um a um retornando em um array os resultados positivos

	@author   Vinicius Gati
	@since    11/04/2017
	@param    aArr    , Array, Array contendo os dados para filtro
	@param    bBlock  , Bloco, bloco que retorne .T. ou .F. que sera o filtro
/*/
Method Select(aArr, bBlock) Class DMS_ArrayHelper
	Local aRes := {}
	AEVAL(aArr, { |el| IIF(EVAL(bBlock, el), AADD(aRes, el), Nil) })
Return aRes

/*/{Protheus.doc} Sum
	Faz a soma geral do indice de todo o array e retorna o resultado

	@author   Vinicius Gati
	@since    05/05/2014
	@param    aArr    , Array, Array contendo os dados para soma
	@param    bBlock  , Bloco, bloco que retorne .T. ou .F.
	@return   nSum    , Numerico, Soma total do array
/*/
Method Sum(nIdx, aArr, bBlock) Class DMS_ArrayHelper
	Local nSum := 0
	If VALTYPE(bBlock) == 'B'
		AEVAL(aArr, { |el| IIF(EVAL(bBlock, el), nSum += el[nIdx], Nil) })
	Else
		AEVAL(aArr, { |el| nSum += el[nIdx] })
	EndIf
Return nSum

/*/{Protheus.doc} SumBlk
	Função que faz a soma dos itens conforme bloco

	@author   Vinicius Gati
	@since    16/06/17
	@param    aArr    , Array, Array contendo os dados para soma
	@param    bBlock  , Bloco, bloco que retorne um valor que pode ser somado
/*/
Method SumBlk(aArr, bBlock) Class DMS_ArrayHelper
	Local nSum := 0
	AEVAL(aArr, { |el| nSum += EVAL(bBlock, el) })
Return nSum

/*/{Protheus.doc} Each
	Percorre o array executando o bloco para cada item

	@author   Vinicius Gati
	@since    17/04/2017
	@param    aArr    , Array, Array contendo os dados para soma
	@param    bBlock  , Bloco, bloco que será executado
/*/
Method Each(aArr, bBlock)  Class DMS_ArrayHelper
	AEVAL(aArr, { |el| EVAL(bBlock, el) })
Return .T.

/*/{Protheus.doc} Uniq
	Retorna somente valores unicos do array passado por parametro

	@author   Vinicius Gati
	@since    26/04/2017
	@param    aArr    , Array, Array contendo os dados para soma
	@param    bBlock  , Bloco, bloco que será executado
/*/
Method Uniq(aArr) Class DMS_ArrayHelper
	Local aUniq := {}
	Local nIdx  := 1
	Local nI    := 1
	for nIdx := 1 to LEN(aArr)
		oVal := aArr[nIdx]
		if EMPTY(aUniq)
			AADD(aUniq, oVal)
		else
			If VALTYPE(oVal) == "A"
				if ! self:AASCAN(aUniq, oVal)
					AADD(aUniq, oVal)
				end
			else
				nI := ASCAN(aUniq, {|t| t == oVal })
				if nI <= 0
					AADD(aUniq, oVal)
				end
			EndIf
		end
	next
Return aUniq

/*/{Protheus.doc} AASCAN
	Mesma coisa que o ASCAN mas faz com arrays e seus elemetos

	@author   Vinicius Gati
	@since    26/04/2017
	@param    aArr1, Array, Array de arrays para fazer o scan
	@param    aArr2, Array, Array que será procurado dentro do primeiro
/*/
Method AASCAN(aArr1, aArr2) Class DMS_ArrayHelper
Return ASCAN(aArr1, {|el| self:Eq(aArr2, el) }) > 0

/*/{Protheus.doc} eq
	Compara 2 arrays se iguais

	@author   Vinicius Gati
	@since    26/04/2017
	@param    aArr1, Array, array 1
	@param    aArr2, Array, array 2
/*/
Method Eq(aArr1, aArr2) Class DMS_ArrayHelper
	Local lVal := .T.
	AEVAL( aArr1, {|cVal, nIdx| IIF(cVal != aArr2[nIdx], lVal := .F., Nil) })
Return lVal

/*/{Protheus.doc} DMS_AccessControl
	@author       Vinicius Gati
	@since        09/06/2014
	@description  Controle de acesso ao protheus
/*/
Class DMS_AccessControl
	Method New() Constructor
	Method ExclusiveAccess()
	Method LoggedInUsers()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_AccessControl

	@author Vinicius Gati
	@since  09/06/2014
/*/
Method New() Class DMS_AccessControl
Return Self

/*/{Protheus.doc} ExclusiveAccess
	Verifica se existe somente 1 conexão ao servidor(a que está sendo usada)

	@author Vinicius Gati
	@since  21/05/2014
/*/
Method ExclusiveAccess() Class DMS_AccessControl
Return Len( self:LoggedInUsers() ) == 1

/*/{Protheus.doc} LoggedInUsers
	Retorna cada conexão ao protheus server exibindo o nome do usuário

	@author Vinicius Gati
	@since  21/05/2014
/*/
Method LoggedInUsers() Class DMS_AccessControl
	Local aLgUsers := GetUserInfoArray()
	Local nIdx := 1
	Local aUsers := {}
	For nIdx := 1 to Len(aLgUsers)
		AADD( aUsers, aLgUsers[nIdx][1] )
	Next
Return aUsers
