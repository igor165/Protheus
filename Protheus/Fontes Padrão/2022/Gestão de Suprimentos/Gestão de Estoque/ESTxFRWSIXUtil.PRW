#INCLUDE "PROTHEUS.CH"

/*
este classe foi criada para encapsular a classe FWSIXUtil do framework para quando a mesma não existir na lib podemos
fazer o mesmo tratamento através de busca direta no SIX ( SINDEX ).
Esta classe foi criada para uso das rotinas do modulo de ESTOQUE e ACD e somente de uso privado do desenvolvimento do produto.
*/

Function ESTFwSIXUtil(); Return .T.

Class ESTFwSIXUtil
    Static Method xExistIndex( xAlias, xOrder, lNickName )
EndClass

/*/{Protheus.doc} xExistIndex
//TODO Verifica se Existe o Indice na Base de Dados
@author Paulo V. Beraldo
@since Ago/2019
@version 1.0
@return Boolean, Retorna true (.T.) se Existir e false (.F.) quando não existir
@param xAlias   , characters, Alias da Tabela
@param xOrder   , characters, Ordem ou NickName do Indice
@param lNickName, Boolean, Se Deve Procurar pelo NickName
@type function
/*/
Method xExistIndex( xAlias, xOrder, lNickName ) class ESTFwSIXUtil
Local lRet      := .F.
Local aArea     := GetArea()
Local aSixArea  := SIX->( GetArea() )

Default xAlias      := ''
Default xOrder      := ''
Default lNickName   := .F.

dbSelectArea( 'SIX' )
SIX->( dbSetOrder( 1 ) )

If isFrame()
	lRet := FWSixUtil():ExistIndex( xAlias , xOrder , lNickname )
Else
    If SIX->( dbSeek( xAlias ) )
        While SIX->( !Eof() ) .And. SIX->INDICE == xAlias
            If !Alltrim( xOrder ) == AllTrim( IIf( lNickname , SIX->NICKNAME , SIX->ORDEM ) )
                SIX->( dbSkip() ) ; Loop
            Else
                lRet := .T.
                Exit
            EndIf

            SIX->( dbSkip() )
        EndDo
    EndIf
EndIf

RestArea( aSixArea )
RestArea( aArea )
Return lRet

/*/{Protheus.doc} isFrame
//TODO retorna se a lib do repositorio contem a claase FWSX3UTIL()
@author reynaldo
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function isFrame()
Return( LibVersion() > "20180823" ) 

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