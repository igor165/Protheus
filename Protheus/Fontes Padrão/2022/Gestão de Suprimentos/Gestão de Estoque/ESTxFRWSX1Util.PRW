#INCLUDE "PROTHEUS.CH"

/*
este classe foi criada para encapsular a classe FWSX1Util do framework para quando a mesma não existir na lib podemos 
fazer o mesmo tratamento através de busca direta no SX1

Esta classe foi criada para uso das rotinas do modulo de ESTOQUE e ACD e somente de uso privado do desenvolvimento do produto.

*/

Function ESTFwSX1Util(); Return .T.

class ESTFwSX1Util
	data lFrame // controla se esta usando a classe FWSX1UTIL ou não
	data oObjSX1 // objeto da classe FWSX1UTIL quando a mesma existir
	data aGroups
	method New() CONSTRUCTOR
	method xAddGroup(cPesqGroup)
	method xSearchGroup()
	method xGetGroup(cPesqGroup)
endclass

/*/{Protheus.doc} new
//TODO Contrutor da classe
@author reynaldo
@since 17/04/2019
@version 1.0

@type method
/*/
method new() class ESTFwSX1Util

// a classe FwSX1Util do framework existe e deve ser tratada nela
::lFrame := LibVersion() >= "20180820"

If ::lFrame
	::oObjSX1 := FWSX1Util():New()
Else
	::aGroups := {}
EndIf

return self

/*/{Protheus.doc} xAddGroup
//TODO Adiciona o codigo do Grupo de Perguntas a ser pesquisado
@author reynaldo
@since 17/04/2019
@version 1.0
@param cPesqGroup, characters, Código(X1_GRUPO) do grupo de perguntas(SX1)
@type method
/*/
method xAddGroup(cPesqGroup) class ESTFwSX1Util
If ::lFrame
	::oObjSX1:AddGroup(cPesqGroup)
Else
	cPesqGroup := PADR(cPesqGroup,Len(SX1->X1_GRUPO))
	aAdd(::aGroups,{cPesqGroup,NIL} )
EndIf
return self

/*/{Protheus.doc} xSearchGroup
//TODO pesquisa os codigos de grupo de peguntas e se encontrar armazena-os
@author reynaldo
@since 17/04/2019
@version 1.0

@type method
/*/
method xSearchGroup() class ESTFwSX1Util
Local cSaveAlias // salva alias corrente
Local nCount 
Local nTotGroup // Total de Grupos a serem pesquisados
Local aAreaSX1
Local nCntPerg

If ::lFrame
	::oObjSX1:SearchGroup()
Else
	nTotGroup := Len(::aGroups)
	cSaveAlias := Alias()
	dbSelectArea("SX1")
	aAreaSX1:= GetArea()
	dbSetOrder(1)
	For nCount := 1 to nTotGroup
		If dbSeek(::aGroups[nCount,1])
			::aGroups[nCount,2] := {}
			While !Eof() .AND. ::aGroups[nCount,1] == SX1->X1_GRUPO
				aAdd(::aGroups[nCount,2],SX1Record():New())  
				nCntPerg := len(::aGroups[nCount,2])
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEF01"   ,SX1->X1_DEF01  )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEF02"   ,SX1->X1_DEF02  )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEF03"   ,SX1->X1_DEF03  )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEF04"   ,SX1->X1_DEF04  )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEF05"   ,SX1->X1_DEF05  )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEFENG1" ,SX1->X1_DEFENG1)
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEFENG2" ,SX1->X1_DEFENG2)
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEFENG3" ,SX1->X1_DEFENG3)
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEFENG4" ,SX1->X1_DEFENG4)
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEFENG5" ,SX1->X1_DEFENG5)
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEFSPA1" ,SX1->X1_DEFSPA1)
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEFSPA2" ,SX1->X1_DEFSPA2)
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEFSPA3" ,SX1->X1_DEFSPA3)
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEFSPA4" ,SX1->X1_DEFSPA4)
				::aGroups[nCount,2,nCntPerg]:Put( "X1_DEFSPA5" ,SX1->X1_DEFSPA5)
				::aGroups[nCount,2,nCntPerg]:Put( "X1_GSC"     ,SX1->X1_GSC    )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_ORDEM"   ,SX1->X1_ORDEM  )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_PERENG"  ,SX1->X1_PERENG )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_PERGUNT" ,SX1->X1_PERGUNT)
				::aGroups[nCount,2,nCntPerg]:Put( "X1_PERSPA"  ,SX1->X1_PERSPA )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_TIPO"    ,SX1->X1_TIPO   )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_VAR01"   ,SX1->X1_VAR01  )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_VAR02"   ,SX1->X1_VAR02  )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_VAR03"   ,SX1->X1_VAR03  )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_VAR04"   ,SX1->X1_VAR04  )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_VAR05"   ,SX1->X1_VAR05  )
				::aGroups[nCount,2,nCntPerg]:Put( "X1_PRESEL"  ,SX1->X1_PRESEL )   
				dbSkip()
			EndDo
		EndIf
	Next nCount
	RestArea(aAreaSX1)

	If ! Empty(cSaveAlias)
		dbSelectArea(cSaveAlias)
	EndIf
EndIf
return self

/*/{Protheus.doc} xGetGroup
//TODO Busca as perguntas do codigo de grupo de perguntas informado
@author reynaldo
@since 17/04/2019
@version 1.0
@return array, As perguntas pertencente ao grupo de perguntas
@param cPesqGroup, characters, Codigo do grupo de perguntas
@type function
/*/
method xGetGroup(cPesqGroup) class ESTFwSX1Util
Local aRetGroup
Local nPosGroup

If ::lFrame
	aRetGroup := ::oObjSX1:GetGroup(cPesqGroup)
Else
	cPesqGroup := PADR(cPesqGroup,Len(SX1->X1_GRUPO))
	// pesquisa na ::aGroups
	nPosGroup := aScan(::aGroups,{|x|x[1]==cPesqGroup})
	If nPosGroup > 0
		aRetGroup := AClone(::aGroups[nPosGroup,2])
	EndIf
EndIf

return aRetGroup 

/*/{Protheus.doc} LibVersion
encapsulamento da funcao do frame que retorna a versão da lib do repositorio
@author reynaldo
@since 11/01/2019
@version 1.0
@return Character, Versão da lib do repositorio

@type function
/*/
Static Function LibVersion()
Local cVersao := ""
/*
* A chamada da funcao __FWLibVersion esta sendo utilizada, conforme acordado com o framework.
* Pois se trata de uma funcao "interna" do framework.
* A função vai estar liberada com o nome de FWLibVersion() na proxima lib
* com versão superior a 20190111
*/
If FindFunction("__FWLibVersion")
	cVersao := __FWLibVersion()
Else
	If FindFunction("FWLibVersion")
		cVersao := FWLibVersion()
	EndIf
EndIf

Return cVersao


/*/{Protheus.doc} SX1Record
//TODO Classe de dados da tabela SX1
@author reynaldo
@since 22/04/2019
@version 1.0
@type class
/*/
class SX1Record
	data cX1_DEF01
	data cX1_DEF02
	data cX1_DEF03
	data cX1_DEF04
	data cX1_DEF05
	data cX1_DEFENG1
	data cX1_DEFENG2
	data cX1_DEFENG3
	data cX1_DEFENG4
	data cX1_DEFENG5
	data cX1_DEFSPA1
	data cX1_DEFSPA2
	data cX1_DEFSPA3
	data cX1_DEFSPA4
	data cX1_DEFSPA5
	data cX1_GSC
	data cX1_ORDEM
	data cX1_PERENG
	data cX1_PERGUNT
	data cX1_PERSPA
	data cX1_TIPO
	data cX1_VAR01
	data cX1_VAR02
	data cX1_VAR03
	data cX1_VAR04
	data cX1_VAR05
	data nX1_PRESEL    

	method New() CONSTRUCTOR
	method Put(cField,uValue)

EndClass

/*/{Protheus.doc} new
//TODO Contrutor da classe
@author reynaldo
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
method new() class SX1Record
Return self

/*/{Protheus.doc} Put
//TODO Armazena o conteudo da pergunta informada
@author reynaldo
@since 22/04/2019
@version 1.0
@param cField, characters, Nome do campo na tabela SX1
@param uValue, undefined, Conteudo a ser armazenado
@type function
/*/
method Put(cField,uValue) class SX1Record

	Do Case
	Case Alltrim(cField) == "X1_DEF01"
		::cX1_DEF01 := uValue
	Case Alltrim(cField) == "X1_DEF02"  
		::cX1_DEF02 := uValue
	Case Alltrim(cField) == "X1_DEF03"  
		::cX1_DEF03 := uValue
	Case Alltrim(cField) == "X1_DEF04"  
		::cX1_DEF04 := uValue
	Case Alltrim(cField) == "X1_DEF05"  
		::cX1_DEF05 := uValue
	Case Alltrim(cField) == "X1_DEFENG1"
		::cX1_DEFENG1 := uValue
	Case Alltrim(cField) == "X1_DEFENG2"
		::cX1_DEFENG2 := uValue
	Case Alltrim(cField) == "X1_DEFENG3"
		::cX1_DEFENG3 := uValue
	Case Alltrim(cField) == "X1_DEFENG4"
		::cX1_DEFENG4 := uValue
	Case Alltrim(cField) == "X1_DEFENG5"
		::cX1_DEFENG5 := uValue
	Case Alltrim(cField) == "X1_DEFSPA1"
		::cX1_DEFSPA1 := uValue
	Case Alltrim(cField) == "X1_DEFSPA2"
		::cX1_DEFSPA2 := uValue
	Case Alltrim(cField) == "X1_DEFSPA3"
		::cX1_DEFSPA3 := uValue
	Case Alltrim(cField) == "X1_DEFSPA4"
		::cX1_DEFSPA4 := uValue
	Case Alltrim(cField) == "X1_DEFSPA5"
		::cX1_DEFSPA5 := uValue
	Case Alltrim(cField) == "X1_GSC"    
		::cX1_GSC := uValue
	Case Alltrim(cField) == "X1_ORDEM"  
		::cX1_ORDEM := uValue
	Case Alltrim(cField) == "X1_PERENG" 
		::cX1_PERENG := uValue
	Case Alltrim(cField) == "X1_PERGUNT"
		::cX1_PERGUNT := uValue
	Case Alltrim(cField) == "X1_PERSPA" 
		::cX1_PERSPA := uValue
	Case Alltrim(cField) == "X1_TIPO"   
		::cX1_TIPO := uValue
	Case Alltrim(cField) == "X1_VAR01"  
		::cX1_VAR01 := uValue
	Case Alltrim(cField) == "X1_VAR02"  
		::cX1_VAR02 := uValue
	Case Alltrim(cField) == "X1_VAR03"  
		::cX1_VAR03 := uValue
	Case Alltrim(cField) == "X1_VAR04"  
		::cX1_VAR04 := uValue
	Case Alltrim(cField) == "X1_VAR05"  
		::cX1_VAR05 := uValue
	Case Alltrim(cField) == "X1_PRESEL" 
		::nX1_PRESEL := uValue
	EndCase
Return self