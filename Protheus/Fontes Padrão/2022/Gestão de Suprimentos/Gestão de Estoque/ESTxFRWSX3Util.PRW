#INCLUDE "PROTHEUS.CH"

/*
este classe foi criada para encapsular a classe FWSX3Util do framework para quando a mesma não existir na lib podemos
fazer o mesmo tratamento através de busca direta no SX3.

Esta classe foi criada para uso das rotinas do modulo de ESTOQUE e ACD e somente de uso privado do desenvolvimento do produto.

*/

Function ESTFwSX3Util(); Return .T.

class ESTFwSX3Util
	static method xGetDescription(cField) 
	static method xGetAllFields(cAlias,lVirtual) 
	static method xGetAllGroupFields(cSXGGroup )
	static method xGetFieldType( cField )
	static method xGetOwner( cField )
endclass

/*/{Protheus.doc} xGetOwner
//TODO Metodo Responsavel por Retornar Se o Campo e de Sistema ou de Usuario
@author Paulo V. Beraldo
@since Abr/2020
@version 1.0
@return characters, descrição do campo informado
@param cField, characters, Nome do campo
@type function
/*/
method xGetOwner(cField) class ESTFwSX3Util
Local aArea		:= GetArea()
Local cRet		:= ''
Local aAreaSX3	:= {}

// a classe FwSX3Util do framework existe e deve ser tratada nela
If isFrame()
	cRet := FWSX3Util():GetOwner( cField )
Else
	aAreaSX3 := SX3->( GetArea() )
	cRet := GetSx3Cache( cField, "X3_PROPRI" )
	RestArea( aAreaSX3 )

EndIf

RestArea( aArea )
Return cRet


/*/{Protheus.doc} xGetDescription
//TODO Busca pela descrição do campo informado de acordo com o idioma utilizado
@author reynaldo
@since 22/04/2019
@version 1.0
@return characters, descrição do campo informado
@param cField, characters, Nome do campo
@type function
/*/
method xGetDescription(cField) class ESTFwSX3Util
Local aAreaSX3
Local cSaveAlias
Local cRetDesc

// a classe FwSX3Util do framework existe e deve ser tratada nela
If isFrame()
	cRetDesc := FWSX3Util():GetDescription(cField)
Else
	cField := PADR(cField,Len(SX3->X3_CAMPO))
	cSaveAlias := Alias()
	dbSelectArea("SX3")
	aAreaSX3 := GetArea()
	dbSetOrder(2) // X3_CAMPO
	cRetDesc := IIf( dbSeek(cField), X3Descric(), "" )
	RestArea(aAreaSX3)

	If !Empty(cSaveAlias)
		dbSelectArea(cSaveAlias)
	EndIf
EndIf

return cRetDesc

/*/{Protheus.doc} xGetAllFields
//TODO Busca os campos do alias da tabela informado, considerando os campo virtuais (X3_CONTEXT)ou não
@author reynaldo
@since 22/04/2019
@version 1.0
@return Array, Nome dos campos do alias da tabela
@param cAlias, characters, Alias da tabela 
@param lVirtual, logical, Considera os campos virtuais ou não
@type function
/*/
method xGetAllFields(cAlias,lVirtual) class ESTFwSX3Util
Local aAreaSX3
Local cSaveAlias
Local aFields

DEFAULT lVirtual := .T.

// a classe FwSX3Util do framework existe e deve ser tratada nela
If isFrame()
	aFields := FWSX3Util():GetAllFields(cAlias,lVirtual)
Else
	aFields := {}
	cAlias := PADR(cAlias,Len(SX3->X3_ARQUIVO))
	dbSelectArea("SX3")
	aAreaSX3 := GetArea()
	dbSetOrder(1) // X3_ARQUIVO
	dbSeek(cAlias)
	While !EOF() .AND. cAlias == SX3->X3_ARQUIVO
	
		If SX3->X3_CONTEXT == "V"
			If lVirtual
				aAdd(aFields ,SX3->X3_CAMPO)
			EndIf
		Else
			aAdd(aFields ,SX3->X3_CAMPO)
		EndIf
		dbSkip()
	End
	RestArea(aAreaSX3)
	
	If !Empty(cSaveAlias)
		dbSelectArea(cSaveAlias)
	EndIf
EndIf
return aFields

/*/{Protheus.doc} xGetAllGroupFields
//TODO Busca os campos que pertencem ao grupo de campo informado
@author reynaldo
@since 22/04/2019
@version 1.0
@return array, Nome dos campos que utilizam o codigo de grupo de campos informado
@param cSXGGroup, characters, Código do grupo de campo
@type function
/*/
method xGetAllGroupFields(cSXGGroup) class ESTFwSX3Util
Local aAreaSX3
Local aAreaSXG
Local cSaveAlias
Local aFields

// a classe FwSX3Util do framework existe e deve ser tratada nela
If isFrame()
	aFields := FWSX3Util():GetAllGroupFields(cSXGGroup)
Else
	aFields := {}
	cSXGGroup := PADR(cSXGGroup,Len(SX3->X3_GRPSXG))
	cSaveAlias := Alias()
	dbSelectArea("SXG")
	aAreaSXG := GetArea()
	dbSetOrder(1) // XG_GRUPO
	If dbSeek(cSXGGroup)
		dbSelectArea("SX3")
		aAreaSX3 := GetArea()
		dbSetOrder(3) // X3_GRPSXG
		dbSeek(cSXGGroup)
		While !EOF() .AND. cSXGGroup == SX3->X3_GRPSXG
			aAdd(aFields ,SX3->X3_CAMPO)
			dbSkip()
		End
		RestArea(aAreaSX3)
	EndIf
	RestArea(aAreaSXG)

	If !Empty(cSaveAlias)
		dbSelectArea(cSaveAlias)
	EndIf
EndIf
return aFields

/*/{Protheus.doc} xGetFieldType
//TODO Buca o tipo de dado do campo informado
@author reynaldo
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cField, characters, Tipo de dado do campo D-Data, C-Caracter, N-numerico, L-Logico
@type function
/*/
method xGetFieldType(cField) class ESTFwSX3Util
Local aAreaSX3
Local cSaveAlias
Local cType

// a classe FwSX3Util do framework existe e deve ser tratada nela
If isFrame()
	cType := FWSX3Util():GetFieldType(cField)
Else
	cField := PADR(cField,Len(SX3->X3_CAMPO))
	cSaveAlias := Alias()
	dbSelectArea("SX3")
	aAreaSX3 := GetArea()
	dbSetOrder(2) // X3_CAMPO
	If dbSeek(cField)
		cType := X3_TIPO
	EndIf
	RestArea(aAreaSX3)

	If !Empty(cSaveAlias)
		dbSelectArea(cSaveAlias)
	EndIf
EndIf

return cType

/*/{Protheus.doc} isFrame
//TODO retorna se a lib do repositorio contem a claase FWSX3UTIL()
@author reynaldo
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function isFrame()
Local lFrame

	lFrame := LibVersion() > "20180823"

Return lFrame


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
