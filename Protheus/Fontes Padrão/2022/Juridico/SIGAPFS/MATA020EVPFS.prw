#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "MATA020PFS.CH"

// Função apenas para o inspetor de objetos e validar a existência da função com FindFunction no MATA020
Function MATA020PFS()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA020EVPFS
Classe responsável pelo evento das regras de negócio de Fornecedores 
do SIGAPFS.

@author  Jorge Martins
@since   25/02/2021
/*/
//-------------------------------------------------------------------
Class MATA020EVPFS From FwModelEvent

	Method New()
	Method InTTS()
	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe FWModelEvent

@author  Jorge Martins
@since   25/02/2021
/*/
//-------------------------------------------------------------------
Method New() Class MATA020EVPFS
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit após 
as gravações porém antes do final da transação.

@param oModel - Modelo de dados de Fornecedores.
@param cID    - Identificador do modelo.

@author  Jorge Martins
@since   25/02/2021
/*/
//-------------------------------------------------------------------
Method InTTS(oModel, cID) Class MATA020EVPFS
Local nOpc := oModel:GetOperation()
	
	// Grava na fila de sincronização - Integração LegalDesk
	J170GRAVA("SA2", xFilial("SA2") + SA2->A2_COD + SA2->A2_LOJA, Alltrim(Str(nOpc)))

	If nOpc == MODEL_OPERATION_DELETE .And. FindFunction("JExcAnxSinc")
		JExcAnxSinc("SA2", SA2->A2_COD + SA2->A2_LOJA) // Exclui os anexos vinculados ao fornecedor e registra na fila de sincronização
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J020InCpoM
Inclui campos no model através da função AddField

@param  oModel , Modelo de Fornecedores (SA2)
@param  oStruct, FWFormStruct da tabela de Fornecedores (SA2)

@author Jorge Martins
@since  17/01/2022

@obs    Função utilizada no ModelDef do fonte MATA020
/*/
//-------------------------------------------------------------------
Function J020InCpoM(oModel, oStruct)
Local aArea   := Nil
Local nI      := 0
Local aCampos := {}
Local aTam    := {}
Local cCampo  := ""
Local cTitulo := ""

	If AliasInDic("OI0") .And. SuperGetMV("MV_JINTGPE", .F., "1") == "2"
		aArea := GetArea()
		//               Campo Virtual   Campo Origem   Título          Validação                   Inicializador Padrão
		aAdd( aCampos, {'A2__VERBA',     'RV_COD',      STR0001,        { || J020SetVal(@oModel) }, { || J020IniPad('A2__VERBA' , oModel) } } ) //'Cód. Verba'
		aAdd( aCampos, {'A2__DVERBA',    'RV_DESC',     STR0002,        { || .T. }                , { || J020IniPad('A2__DVERBA', oModel) } } ) //'Desc. Verba'

		For nI := 1 To Len(aCampos)
			cCampo  := aCampos[nI][2]
			cTitulo := aCampos[nI][3]
			aTam    := TamSx3(cCampo)

			oStruct:AddField( ;
			cTitulo                             , ; // [01] Titulo do campo // "Importar Arquivo"
			GetSx3Cache(cCampo, 'X3_DESCRIC')   , ; // [02] ToolTip do campo // "Importar Arquivo"
			aCampos[nI][1]                      , ; // [03] Id do Field
			aTam[3]                             , ; // [04] Tipo do campo
			aTam[1]                             , ; // [05] Tamanho do campo
			aTam[2]                             , ; // [06] Decimal do campo
			aCampos[nI][4]                      , ; // [07] Code-block de validação do campo
												, ; // [08] Code-block de validação When do campo
												, ; // [09] Lista de valores permitido do campo
			.F.                                 , ; // [10] Indica se o campo tem preenchimento obrigatório
			aCampos[nI][5]                      , ; // [11] Bloco de código de inicializacao do campo
												, ; // [12] Indica se trata-se de um campo chave
												, ; // [13] Indica se o campo não pode receber valor em uma operação de update
			.T.                                  ) // [14] Indica se o campo é virtual
		Next
		RestArea(aArea)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J020InCpoV
Inclui campos no view através da função AddField

@param  oView  , Objeto de View de Fornecedores (SA2)
@param  oStruct, FWFormStruct da tabela de Fornecedores (SA2)

@author Jorge Martins
@since  17/01/2022

@obs    Função utilizada na ViewDef do fonte MATA020
/*/
//-------------------------------------------------------------------
Function J020InCpoV(oView, oStruct)
Local aArea   := Nil
Local nI      := 0
Local aCampos := {}
Local aLgpd   := {}
Local cCampo  := ""
Local cTitulo := ""

	If AliasInDic("OI0") .And. SuperGetMV("MV_JINTGPE", .F., "1") == "2"
		aArea := GetArea()
		//               Campo virtual Campo Origem  Título         When  F3     Ordem
		aAdd( aCampos, {'A2__VERBA',   'RV_COD',     STR0001,       .T.,  "SRV", "ZY"}) //'Cód. Verba'
		aAdd( aCampos, {'A2__DVERBA',  'RV_DESC',    STR0002,       .F.,  ""   , "ZZ"}) //'Desc. Verba'

		For nI := 1 To Len(aCampos)
			cCampo  := aCampos[nI][2]
			cTitulo := aCampos[nI][3]
			oStruct:AddField( ;
			aCampos[nI][1]                      , ; // [01] Campo
			aCampos[nI][6]                      , ; // [02] Ordem
			cTitulo                             , ; // [03] Titulo
			GetSx3Cache(cCampo, 'X3_DESCRIC')   , ; // [04] Descricao
												, ; // [05] Help
			'GET'                               , ; // [06] Tipo do campo   COMBO, Get ou CHECK
			'@X'                                , ; // [07] Picture
												, ; // [08] PictVar
			aCampos[nI][5]                      , ; // [09] F3
			aCampos[nI][4]                      , ; // [10] When
			"1"                                 , ; // [11] Folder
												, ; // [12] Group
												, ; // [13] Lista Combo
												, ; // [14] Tam Max Combo
												, ; // [15] Inic. Browse
			.T.                                 ) // [16] Virtual
			aAdd(aLgpd, {aCampos[nI][1], aCampos[nI][2]})
		Next

		IIf(FindFunction("JPDOfusca"), JPDOfusca(@oStruct, aLgpd), Nil)
		RestArea(aArea)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J020SetRel
Seta a relação da tabela OI0 - Fornecedor x Verba com a SA2

@param  oModel, Modelo de dados de Fornecedores

@author Jorge Martins
@since  17/01/2022

@obs    Função utilizada no ModelDef do fonte MATA020
/*/
//-------------------------------------------------------------------
Function J020SetRel(oModel)

	If AliasInDic("OI0") .And. ChkFile("OI0") .And. SuperGetMV("MV_JINTGPE", .F., "1") == "2" // Fornecedor x Verba
		oModel:AddFields("OI0DETAIL", "SA2MASTER", FWFormStruct(1, "OI0"))
		oModel:SetRelation("OI0DETAIL", {{"OI0_FILIAL", "xFilial('SA2')"}, {"OI0_FORNEC", "A2_COD"}, {"OI0_LOJA", "A2_LOJA"}}, OI0->(IndexKey(1)))
		oModel:GetModel("OI0DETAIL"):SetOptional(.T.)
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J020SetVal
Preenche os valores dos campos de verba na tabela OI0 após
o preenchimento do campo virtual posicionado na SA2

@param  oModel, Modelo de dados de Fornecedores

@return lRet  , Se .T. indica que os valores foram setados corretamente

@author Jorge Martins
@since  17/01/2022
/*/
//-------------------------------------------------------------------
Static Function J020SetVal(oModel)
Local cVerba     := oModel:GetValue("SA2MASTER", "A2__VERBA") // Verba
Local cDescVerba := ""
Local lRet       := .F.

	If Empty(cVerba) // Se estiver limpando o campo de Verba
		lRet := .T.
		oModel:SetValue("OI0DETAIL" , "OI0_VERBA" , "") // Limpa o campo real de verba
		oModel:LoadValue("SA2MASTER", "A2__DVERBA", "") // Limpa o campo virtual de descrição da verba

	Else
		lRet := oModel:SetValue("OI0DETAIL", "OI0_VERBA", cVerba) // Preenche o campo real de verba
		If lRet // Caso seja uma verba válida
			cDescVerba := JurGetDados("SRV", 1, xFilial("SRV") + cVerba, {"RV_DESC"})
			If !Empty(cDescVerba)
				oModel:LoadValue("SA2MASTER", "A2__DVERBA", cDescVerba) // Preenche o campo virtual de descrição da verba
			EndIf
		EndIf
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} J020IniPad
Inicializador padrão dos campos virtuais

@param  cCampo, Campo que será preenchido
@param  oModel, Modelo de dados do participante

@return cRet,   Conteúdo do campo

@author Jorge Martins
@since  17/01/2022
/*/
//-------------------------------------------------------------------
Static Function J020IniPad(cCampo, oModel)
Local cRet   := ""
Local cVerba := ""

	If oModel:GetOperation() <> MODEL_OPERATION_INSERT
		cVerba := JurGetDados("OI0", 1, SA2->(A2_FILIAL + A2_COD + A2_LOJA), "OI0_VERBA")

		If cCampo == 'A2__VERBA'
			cRet := cVerba
		ElseIf cCampo == 'A2__DVERBA' .And. !Empty(cVerba)
			cRet := JurGetDados("SRV", 1, xFilial("SRV") + cVerba, "RV_DESC")
		EndIf
	EndIf

Return cRet
