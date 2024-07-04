#INCLUDE "JURA279.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA279
TOTVS Juridico - Distribuição

@since 08/07/2020
/*/
//-------------------------------------------------------------------
Function JURA279()

Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0001) //-- "Operações para distribuição - TOTVS JURIDICO"
	oBrowse:SetAlias( "NZZ" )
	oBrowse:SetLocate()
	oBrowse:Activate()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura

@since 08/07/2020
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA279", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA279", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA279", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA279", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA279", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados simples de Distribuição.

@since 08/07/2020
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNZZ := FWFormStruct( 1, "NZZ" )

	ClearStatus()

	oStructNZZ:SetProperty( 'NZZ_STATUS', MODEL_FIELD_NOUPD, .F. )
	oStructNZZ:SetProperty( 'NZZ_CAJURI', MODEL_FIELD_NOUPD, .F. )
	oStructNZZ:SetProperty( 'NZZ_CAJURI', MODEL_FIELD_WHEN, {|| .T.} )
	oStructNZZ:SetProperty( 'NZZ_STATUS', MODEL_FIELD_WHEN, {|| .T.} )

	oModel:= MPFormModel():New( "JURA279", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:SetDescription( STR0008 ) //-- "Cadastro de Distribuição"
	
	oModel:AddFields("NZZMASTER", NIL, oStructNZZ, /*Pre-Validacao*/, /*Pos-Validacao*/ )

	oModel:GetModel( "NZZMASTER" ):SetDescription( STR0008 ) //-- "Cadastro de Distribuição"
	JurSetRules( oModel, 'NZZMASTER',, 'NZZ' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Distribuição.

@since 08/07/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA279" )
Local oStructNZZ := FWFormStruct( 2, "NZZ" )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "NZZ_VIEW", oStructNZZ, "NZZMASTER"  )

	oView:SetDescription( STR0008 ) //-- "Operações de Distribuição"

	

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ClearStatus()
Função que limpa o status "Processando" dos registros que ultrapassaram 
10 minutos de precessamento por distribuição

@since 08/07/2020
/*/
//-------------------------------------------------------------------
Static Function ClearStatus()
Local aArea := GetArea()
Local cAlias := GetNextAlias()
Local cQry := ""

	DbSelectArea("NZZ")
	If(NZZ->(FieldPos('NZZ_ERRO')) > 0)

		cQry := "SELECT NZZ_FILIAL, NZZ_COD, NZZ_ERRO FROM "+ RetSqlName('NZZ')
		cQry += " WHERE NZZ_STATUS = '5' AND D_E_L_E_T_ = ' ' AND NZZ_FILIAL = '"+ xFilial('NZZ') + "'"
		cQry += "ORDER BY NZZ_FILIAL, NZZ_COD"
		cQry :=ChangeQuery(cQry)

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQry), cAlias, .F., .F. )

		If ( (cAlias)->(!Eof()) )

			DbSelectArea("NZZ")
			NZZ->(DbSetOrder(1)) //NZZ_FILIAL+NZZ_COD

			While (cAlias)->(!Eof())

				If ( Val( AllTrim( (cAlias)->NZZ_ERRO ) )  < Val( FWTimeStamp(4) ) )

					If dbSeek((cAlias)->NZZ_FILIAL + (cAlias)->NZZ_COD)

						RecLock("NZZ", .F.)
							NZZ->NZZ_STATUS := "1"
							NZZ->NZZ_ERRO := STR0009 //'Erro ao executar a Importação, Verifique o log do sistema'
						NZZ->( MsUnLock() )
					EndIf
				EndIf

				(cAlias)->( dbSkip() )

			End
		EndIf

		(cAlias)->( DbCloseArea() )

	EndIf

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J279SvMdl(lUpdate, aModelo, cNomeModel, cCodMod, cTpAss, cTpModel)
Responsável por salvar ou atualizar um modelo de cadastro de processo
para a rotina de distribuição.

@param aModelo - Estrutura de informação para gravar como modelo:
					aModelo[nIndex][1] = Campo
					aModelo[nIndex][2] = Tipo do campo
					aModelo[nIndex][3] = Valor do campo
					aModelo[nIndex][4] = modelo do campo

@param lUpdate    - É uma atualização ou novo modelo?
@param cNomeModel - Nome do modelo que será criado
@param cCodMod    - Código do modelo para ser atualizado
@param cTpAss     - Assunto jurídico do modelo à ser gravado
@param cTpModel   - Tipo do modelo para ser gravado:
					1 - Assunto Jurídico
					2 - Cadastro rápido do processo

@since 15/10/2020
/*/
//-------------------------------------------------------------------
Function J279SvMdl(aModelo, lUpdate, cNomeModel, cCodMod, cTpAss, cTpModel)
Local aArea      := GetArea()
Local aAreaNZ3   := NZ3->( GetArea() )
Local aAreaNZ4   := NZ4->( GetArea() )
Local nTamCamp   := TamSx3("NZ4_NOMEC")[1]
Local nTamMode   := TamSx3("NZ4_NOMEMD")[1]
Local nTamName   := TamSx3("NZ3_NOME")[1]
Local lExistName := .F.
Local nIndex     := 0
Local nIndice    := 0
Local cCampo     := ''
Local cModelo    := ''
Local cMsgErro   := ''
Local lSeek      := .F.
Local lRet       := .F.

	DbSelectArea("NZ4")
	nIndice := Ordkey(2)

	If !Empty(nIndice)
		lExistName := !Empty( JurGetDados('NZ3',2, xFilial("NZ3") + cTpAss + PADR(cNomeModel, nTamName), "NZ3_COD") )

		If !lExistName .Or. lUpdate
			If !lUpdate
				cCodMod := GetSXENum("NZ3","NZ3_COD")
				lRet := NZ3->(Reclock( "NZ3", .T. ))
					NZ3->NZ3_COD    := cCodMod
					NZ3->NZ3_NOME   := DecodeUTF8(cNomeModel)
					NZ3->NZ3_TIPOAS := cTpAss

					If NZ3->(FieldPos('NZ3_TIPO')) > 0
						NZ3->NZ3_TIPO := cTpModel
					EndIf
				NZ3->(MsUnlock())

				If __lSX8
					ConfirmSX8()
				EndIf
			EndIf

			For nIndex := 1 to Len(aModelo)
				cCampo  := PADR(aModelo[nIndex][1], nTamCamp)
				cModelo := PADR(aModelo[nIndex][4], nTamMode)

				If lUpdate
					NZ4->(DbSetOrder(2))
										// NZ4_FILIAL     + NZ4_CMOD + NZ4_NOMEC + NZ4_NOMEMD
					lSeek := NZ4->(dbSeek( xFilial('NZ4') + cCodMod  + cCampo    + cModelo   ))
				EndIf

				lRet := NZ4->(RecLock('NZ4', !lSeek))
					NZ4->NZ4_CMOD   := cCodMod
					NZ4->NZ4_ITEM   := '01'
					NZ4->NZ4_NOMEC  := AllTrim(cCampo)
					NZ4->NZ4_NOMEMD := AllTrim(cModelo)
					NZ4->NZ4_TIPO   := aModelo[nIndex][2]
					NZ4->NZ4_VALORC := DecodeUTF8(cValToChar(aModelo[nIndex][3]))
				NZ4->(MsUnlock())
			Next
		Else
			lRet     := .F.
			cMsgErro := I18n(STR0010, { cNomeModel })
		EndIf
	EndIf
	
	NZ4->( DbCloseArea() )
	
	RestArea(aAreaNZ4)
	RestArea(aAreaNZ3)
	RestArea(aArea)

Return { lRet, cMsgErro }
