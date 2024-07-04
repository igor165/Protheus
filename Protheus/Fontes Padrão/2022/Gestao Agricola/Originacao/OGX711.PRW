#INCLUDE "Protheus.ch"
#INCLUDE "OGX711.ch"

/*{Protheus.doc} OGX711
Exibe os Documentos da Instrução de Embarque
@author jean.schulze
@since 29/11/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodInstr, characters, descricao
@type function
*/
Function OGX711(cCodInstr)
	Local oBrowseNLL := nil
	
	oBrowseNLL := FWMBrowse():New()
	oBrowseNLL:SetAlias( "NLL" )
	oBrowseNLL:SetFilterDefault( "NLL_CODINE = '"+cCodInstr+"'" )
	oBrowseNLL:SetMenuDef("OGX711")
	oBrowseNLL:SetDescription( STR0001 + " " + cCodInstr ) //"Instrução de Embarque - Mercado Externo"
	oBrowseNLL:Activate()	

Return .t.

/*{Protheus.doc} MenuDef
Menu do Browser de Documentos
@author jean.schulze
@since 29/11/2018
@version 1.0
@return ${return}, ${return_description}

@type function
*/
Static Function MenuDef()
	Local aRotina  := {}
	aAdd( aRotina, { STR0002, "OGX711VIEW(NLL->NLL_URLDOC)", 0, 2, 0, .F. } ) //Visualizar
Return( aRotina )


/*{Protheus.doc} OGX711VIEW
Chama o navegador para abrir o link do documento.
@author jean.schulze
@since 29/11/2018
@version 1.0
@return ${return}, ${return_description}
@param cUrl, characters, descricao
@type function
*/
Function OGX711VIEW(cUrl)
	ShellExecute( "open", cUrl, "", "", 5 )
return .t.


/*{Protheus.doc} fRetContat
//TODO Descrição auto-gerada.
@author jean.schulze
@since 28/11/2018
@version 1.0
@return ${return}, ${return_description}
@param cTabela, characters, descricao
@param cCodigo, characters, descricao 
@param aListUser, array, descricao
@type function
*/
Static Function fRetContat(cTabela, cCodigo, aListUser )
	Local   cAliasN9L := GetNextAlias()		
	Default aListUser := {}
	
	cCodigo := cCodigo + "%"
	
	BeginSql Alias cAliasN9L
		SELECT N9L_CODUSU
		  FROM %Table:N9L% N9L
		INNER JOIN %Table:AC8% AC8 ON AC8.AC8_FILENT = N9L.N9L_FILIAL 
							 	  AND AC8.AC8_CODCON = N9L.N9L_CODCON
							 	  AND N9L.%notDel%	
		WHERE AC8.AC8_FILIAL = %xFilial:AC8%
		  AND AC8.AC8_ENTIDA = %Exp:cTabela%
		  AND AC8.AC8_CODENT LIKE %Exp:cCodigo%	
		  AND AC8.%notDel%
		GROUP BY N9L_CODUSU  
	EndSQL
	
	while (cAliasN9L)->(!Eof())
		aAdd(aListUser, UsrRetMail((cAliasN9L)->N9L_CODUSU)) //pega pelo cadastro de usuários
		(cAliasN9L)->(dbSkip())
	enddo
	
return aListUser