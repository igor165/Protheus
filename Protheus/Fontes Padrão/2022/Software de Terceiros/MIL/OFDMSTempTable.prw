#include "protheus.ch"

Function OFDMSTempTable()
Return()

CLASS OFDMSTempTable

	Data cAlias
	Data cNomeArquivos
	Data oObjTable
	Data aVetCampos
	Data aVetIndices
	Data cMetodo // Criada propriedade por compatibilidade da versao 11

	Data _InsertString

	METHOD New() CONSTRUCTOR
	METHOD AddField()
	METHOD SetVetCampos()
	METHOD AddIndex()
	METHOD CreateTable()
	METHOD GetRealName()
	METHOD CloseTable()

	METHOD ExecSQL()
	METHOD InsertSQL()
	METHOD ClearTable()

	METHOD GetAlias()

	METHOD _AtuInsertString()

ENDCLASS

/*/{Protheus.doc} New
//Inicialização da Classe
@author Fernando Vitor Cavani
@since 06/06/2018
@version 1.0
@type function
/*/
METHOD New() Class OFDMSTempTable
	Self:cAlias      := GetNextAlias()
	Self:aVetIndices := {}
	Self:_InsertString := ""
Return

METHOD AddField(cIDFIELD, cTIPO, nTAMANHO, nDECIMAL ) Class OFDMSTempTable
	AADD( self:aVetCampos, { cIDFIELD, cTIPO, nTAMANHO, nDECIMAL } )
Return


METHOD SetVetCampos( aAuxVetCampos ) Class OFDMSTempTable
	self:aVetCampos := aClone(aAuxVetCampos)
Return

/*/{Protheus.doc} AddIndex
//Criação de Índice
@author Fernando Vitor Cavani
@since 06/06/2018
@version 1.0
@param cNomIndex, caractere, nome
@param aFieldIndex, vetor, campos
@type function
/*/
METHOD AddIndex(cNomIndex, aFieldIndex) Class OFDMSTempTable

	Default cNomIndex := "IND" + StrZero(Len( self:aVetIndices ), 2)

	AADD( self:aVetIndices, { cNomIndex, aClone(aFieldIndex) } )
Return

/*/{Protheus.doc} CreateTable
//Criação da Tabela Temporária
@author Fernando Vitor Cavani
@since 06/06/2018
@version 1.0
@param lCompartilhado, lógico, compartilhar
@type function
/*/
METHOD CreateTable(lCompartilhado) CLASS OFDMSTempTable
	Local nPos

	Default lCompartilhado := Nil // Criado parâmetro por compatibilidade da versao 11

	Self:oObjTable := FWTemporaryTable():New( Self:cAlias )
	Self:oObjTable:SetFields( Self:aVetCampos )

	For nPos := 1 to Len(self:aVetIndices)
		Self:oObjTable:AddIndex( self:aVetIndices[ nPos, 1 ], self:aVetIndices[ nPos, 2 ])
	Next nPos

	Self:oObjTable:Create()
Return

Method GetAlias() CLASS OFDMSTempTable
Return self:cAlias

/*/{Protheus.doc} GetRealName
//Nome Real da Tabela Temporária
@author Fernando Vitor Cavani
@since 12/06/2018
@version 1.0
@type function
/*/
METHOD GetRealName() CLASS OFDMSTempTable
Return Self:oObjTable:GetRealName()

/*/{Protheus.doc} CloseTable
//Fechamento da Tabela Temporária
@author Fernando Vitor Cavani
@since 06/06/2018
@version 1.0
@type function
/*/
Method CloseTable() Class OFDMSTempTable
	(Self:cAlias)->(dbCloseArea())
	Self:oObjTable:Delete()
Return


Method InsertSQL(cParSQL, lDelete) CLASS OFDMSTempTable

	Local lRet

	If Empty(self:_InsertString)
		self:_AtuInsertString()
	EndIf
	//cParSQL := self:_InsertString + ChangeQuery(cParSQL)
	cParSQL := self:_InsertString + cParSQL
	lRet := self:ExecSQL(cParSQL)

Return lRet

Method _AtuInsertString() CLASS OFDMSTempTable
	Local nPosCampos

	self:_InsertString := "INSERT INTO " + self:oObjTable:GetRealName() + " ("

	For nPosCampos := 1 to Len(self:aVetCampos)
		self:_InsertString += self:aVetCampos[nPosCampos, 1] + ","
	Next nPosCampos
	self:_InsertString := substr( self:_InsertString, 1 , len(self:_InsertString) - 1 ) + ") "

Return

Method ClearTable() CLASS OFDMSTempTable
	Local cParSQL := "TRUNCATE TABLE " + self:oObjTable:GetRealName()
	Local lRet

	lRet := self:ExecSQL(cParSQL)

Return lRet

Method ExecSQL(cSQL) class OFDMSTempTable

	lRet := ( TcSQLExec(cSQL) >= 0)
	If lRet == .f.
		If AVISO("Atenção", "Erro ao executar instrução SQL." + CRLF + CRLF + "Erro: " + tcSQLError() + CRLF + CRLF + "Comando" + CRLF + cSQL , { "Copiar Instrução", "Fechar" }, 3) == 1
			CopytoClipBoard(cSQL)
		EndIf
	
	EndIf
Return lRet