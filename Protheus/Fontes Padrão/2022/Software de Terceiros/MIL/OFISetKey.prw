#include "totvs.ch"

/*/{Protheus.doc} OFISetKey
	Função para verificação da existência da classe OFISetKey
	@author       Fernando Vitor Cavani
	@since        26/06/2018
	@version      1.0
/*/
Function OFISetKey()
Return()

/*/{Protheus.doc} OFISetKey
	Classe para auxiliar a manipulação das teclas de atalho (F4-F11)
	@author       Fernando Vitor Cavani
	@since        26/06/2018
	@version      1.0
/*/
Class OFISetKey
	Data aBkpSetKey

	Method New() CONSTRUCTOR
	Method Backup()
	Method Restore()
EndClass

Method New() Class OFISetKey
Return Self

/*/{Protheus.doc} Backup
	Backup das teclas de atalho (F4-F11) e limpeza das SetKey()
	@author       Fernando Vitor Cavani
	@since        26/06/2018
	@version      1.0
	@type function
/*/
Method Backup() Class OFISetKey
	Local nVK_F := 0
	Local cBL_F := ""
	Local aVK_F := {}

	For nVK_F := 115 To 122 // F4 - F11
		cBL_F := SetKey(nVK_F) // Retorna o bloco de código e já limpa a tecla "F" correspondente
		If cBL_F <> NIL
			// Salvando as teclas e blocos de código
			AADD(aVK_F, {nVK_F, cBL_F})
		EndIf
	Next

	If !Empty(aVK_F)
		Self:aBkpSetKey := aVK_F
	EndIf
Return

/*/{Protheus.doc} Restore
	Retorno das teclas de atalho (F4-F11)
	@author       Fernando Vitor Cavani
	@since        26/06/2018
	@version      1.0
	@type function
/*/
Method Restore() Class OFISetKey
	Local nVK_F := 0

	If !Empty(Self:aBkpSetKey)
		For nVK_F := 1 To Len(Self:aBkpSetKey) // Todas as teclas "F + numeral" encontradas
			// Retornando as teclas e blocos de código
			SETKEY(Self:aBkpSetKey[nVK_F, 1], Self:aBkpSetKey[nVK_F, 2])
		Next
	EndIf

	// Limpeza da variável array
	Self:aBkpSetKey := aSize(Self:aBkpSetKey, 0)
Return