#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#INCLUDE "VEIA090.CH"

Function VEIA090()

	Local oBrowse

	If GetNewPar("MV_MIL0122", "0") == "1" .and. Empty(GetNewPar("MV_MIL0123", ""))
		FMX_HELP( "VA090ERR01", STR0001, STR0002) // "Imobilização integrada com ativo fixo, mas tipo de movimentação não foi configurado." - "Verifique o conteúdo do parâmetro MV_MIL0123."  
		Return .f.
	EndIf

	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VV1')
	oBrowse:SetDescription(STR0014) // 'Veículos'

	oBrowse:SetOnlyFields({'VV1_CHAINT','VV1_CODMAR','VV1_DESMAR','VV1_CHASSI','VV1_MODVEI','VV1_DESMOD','VV1_COMMOD','VV1_FABMOD','VV1_PLAVEI','VV1_PROATU','VV1_LJPATU','VV1_NOMPRO','VV1_SITVEI','VV1_RENAVA'})

	oBrowse:AddFilter(STR0003,"@ VV1_IMOBI = '1' OR (VV1_ESTVEI = '0' AND ( ( VV1_SITVEI='0' AND VV1_TRACPA<>' ' ) OR VV1_SITVEI IN ('2','8') ))",.t.,.t.,) // 'Veiculos em Estoque'

	oBrowse:AddLegend( 'VV1_IMOBI $ " 0"' , 'BR_VERDE'    , STR0004 ) // "Não Imobilizado"
	oBrowse:AddLegend( 'VV1_IMOBI == "1"' , 'BR_VERMELHO' , STR0005 ) // "Imobilizado"

	oBrowse:Activate()

Return()

/*/{Protheus.doc} MenuDef
Menu
@author Rubens
@since 28/12/2018
@version 1.0

@type function
/*/
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0006 ACTION 'VA0900013_Imobilizar' OPERATION 4 ACCESS 0 // 'Imobilizar'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VA0900033_CancImobilizacao' OPERATION 4 ACCESS 0 // 'Cancelar'
Return aRotina

Function VA0900013_Imobilizar(cAlias,nReg,nOpc)

	Local oModel070
	Local cDocSD3

	If ! VXI00101_ValidaVeiculo(VV1->VV1_CHAINT)
		Return .f.
	EndIf

	If VV1->VV1_IMOBI == "1"
		FMX_HELP("VX090ERR01",STR0008) // "Veículo já imobilizado."
		Return .f.
	EndIf

	If ! MsgYesNo(STR0009, STR0010 ) // "Imobilizar veículo?"
		Return .f.
	EndIf

	CursorWait()
	oModel070 := FWLoadModel( 'VEIA070' )
	oModel070:SetOperation( MODEL_OPERATION_UPDATE )
	If ! oModel070:Activate()
		MostraErro()
		CursorArrow()
		Return .f.
	EndIf


	Begin Transaction
	Begin Sequence

		If ! VXI00101_ValidaVeiculo(oModel070:GetValue("MODEL_VV1","VV1_CHAINT"))
			Break
		EndIf
	
		If ! oModel070:SetValue("MODEL_VV1","VV1_IMOBI","1")
			Break
		EndIf

		If ! Empty(GetNewPar("MV_MIL0123", ""))
			If ! VA0900023_MovEstoque(@cDocSD3)
				Break
			EndIf

			If ! oModel070:SetValue("MODEL_VV1","VV1_IMOFD3",xFilial("SD3"))
				Break
			EndIf

			If ! oModel070:SetValue("MODEL_VV1","VV1_IMOSD3",cDocSD3)
				Break
			EndIf
		EndIf

		If oModel070:VldData()
			oModel070:CommitData()
		Else
			Break
		EndIf

	Recover
		DisarmTransaction()
		MsUnlockAll()
		aErro := oModel070:GetErrorMessage()
		AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
		AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
		AutoGrLog( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
		MostraErro()

		Return .f.

	End Sequence
	End Transaction

	CursorArrow()

Return.t.

Static Function VA0900023_MovEstoque(cDocSD3)

	Local aItensNew
	Local lRet := .T.

	Local aCab241 := {}
	Local aItens241 := {}

	Private N := 1

	If ! FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT)
		Return .f.
	EndIf

	aItensNew := {}

	cDocSD3  := Criavar("D3_DOC")
	cDocSD3	:= IIf( Empty(cDocSD3) , NextNumero("SD3",2,"D3_DOC",.T.) , cDocSD3)
	cDocSD3	:= A261RetINV(cDocSD3)

	aCab241 := {{ "D3_DOC"     , cDocSD3 , NIL },;
					{ "D3_TM"      , GetNewPar("MV_MIL0123", "") , NIL },;
					{ "D3_EMISSAO" , dDataBase , Nil } }

	AADD( aItens241,{ { "D3_COD"    , SB1->B1_COD    , NIL },; // Veiculo
							{ "D3_QUANT"  , 1              , NIL },;
							{ "D3_LOCAL"  , SB1->B1_LOCPAD , NIL } } )
	lMsHelpAuto := .t.
	lMsErroAuto := .f.
	MSExecAuto({|x,y,z| Mata241(x,y,z)},aCab241,aItens241,Nil)
	If lMsErroAuto
//		MostraErro()
		lRet := .f.
	EndIf

Return lRet

Function VA0900033_CancImobilizacao()

	Local oModel070
	//Local cDocSD3

	If VV1->VV1_IMOBI <> "1"
		FMX_HELP("VX090ERR02",STR0011) // "Veículo não é imobilizado."
		Return .f.
	EndIf

	If ! MsgYesNo(STR0012, STR0010) // "Confirma estorno de imobilização?"
		Return .f.
	EndIf

	CursorWait()
	oModel070 := FWLoadModel( 'VEIA070' )
	oModel070:SetOperation( MODEL_OPERATION_UPDATE )
	If ! oModel070:Activate()
		MostraErro()
		CursorArrow()
		Return .f.
	EndIf


	Begin Transaction
	Begin Sequence
	
		If ! VA0900043_EstornaMovImobilizacao(oModel070)
			Break
		EndIf

		oModel070:SetValue("MODEL_VV1","VV1_IMOBI","0")
		oModel070:SetValue("MODEL_VV1","VV1_IMOFD3"," ")
		oModel070:SetValue("MODEL_VV1","VV1_IMOSD3"," ")

		If oModel070:VldData()
			oModel070:CommitData()
		Else
			Break
		EndIf

	Recover
		DisarmTransaction()
		MsUnlockAll()
		aErro := oModel070:GetErrorMessage()
		AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
		AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
		AutoGrLog( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
		MostraErro()

		Return .f.

	End Sequence
	End Transaction

	CursorArrow()

Return


Static Function VA0900043_EstornaMovImobilizacao(oModel070)

	Local lRet := .T.

	Local aCab241 := {}
	Local aItens241 := {}
	Local cBkpFilAnt := cFilAnt

	Private N := 1

	If ! Empty(oModel070:GetValue("MODEL_VV1","VV1_IMOFD3"))
		cFilAnt := oModel070:GetValue("MODEL_VV1","VV1_IMOFD3")
	EndIf

	lRet := FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT)


	If lRet .and. ! Empty(oModel070:GetValue("MODEL_VV1","VV1_IMOSD3"))
		SD3->(dbSetOrder(2))
		If ! SD3->(dbSeek(xFilial("SD3") + oModel070:GetValue("MODEL_VV1","VV1_IMOSD3") ))
			FMX_HELP("VA090ERR02",STR0013 + CRLF + RetTitle("VV1_IMOSD3") + ": " + oModel070:GetValue("MODEL_VV1","VV1_IMOSD3") ) // "Movimentação de imobilização não encontrada."
			lRet := .f.
		EndIf
	EndIf

	If lRet
		lMsHelpAuto := .t.
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z| Mata241(x,y,z)},aCab241,aItens241,6)
		If lMsErroAuto
			MostraErro()
			lRet := .f.
		EndIf
	EndIf

	cFilAnt := cBkpFilAnt

Return lRet