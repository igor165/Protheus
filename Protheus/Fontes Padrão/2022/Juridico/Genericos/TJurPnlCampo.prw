#INCLUDE "PROTHEUS.CH"

#DEFINE _FILIAL 1
#DEFINE _COD    2
#DEFINE _DESC   3
#DEFINE _TABELA 4
#DEFINE _CAMPO  5
#DEFINE _WHERE  6
#DEFINE _PROPRI 7
#DEFINE _F3DIF  8
#DEFINE _F3CONS 9
#DEFINE _VALID  10
#DEFINE _F3MULT 11

//-------------------------------------------------------------------
/*/{Protheus.doc} TJurPnlCampo
CLASS TJurPnlCampo

@author Felipe Bonvicini Conti
@since 16/09/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function __JurPnlCampo() // Function Dummy
ApMsgInfo( 'JurPnlCampo -> Utilizar Classe ao inves da funcao' )
Return NIL

CLASS TJurPnlCampo

	DATA oWnd
	DATA oPanel
	DATA oCampo
	DATA cDescCampo
	DATA cNomeTab
	DATA cNomeCampo
	DATA cCodCampo
	DATA nRow
	DATA nCol
	DATA nWidth
	DATA nHeight
	DATA Valor
	DATA VlrDefault
	DATA lVisible
	DATA lEnable
	DATA cTipoCampo
	DATA lAlterado
	DATA aInfoCampo
	DATA aDadosCpoNVH
	DATA ClassName
	DATA bGotFocus
	DATA bLostFocus
	DATA nAlign
	DATA lLabel
	DATA nTop
	DATA ValorOld
	DATA bChangeUsr
	DATA lActivated
	DATA cTipoCpo
	DATA ValidCpo
	DATA bHelp
	DATA cF3
	DATA bF3
	DATA bValid
	DATA lbChanged
	DATA cListItens
	DATA lF3Multi
	DATA bF3Multi
	DATA bF3Simp
	DATA cWhere
	DATA lAltLote
	DATA lCboxEmpty
	DATA lObfuscate

	METHOD Initialize(nRow, nCol, nWidth, nHeight, oWnd, cSay, cCodCampo, bGotFocus, bLostFocus, xSugestao, lVisible, lEnable, cF3, nAlign, cListItens, lAltLote, lCboxEmpty, lObfuscate) CONSTRUCTOR
	METHOD New(nRow, nCol, nWidth, nHeight, oWnd, cSay, cCodCampo, bGotFocus, bLostFocus, xSugestao, lVisible, lEnable, cF3, nAlign, cListItens, lAltLote, lCboxEmpty, lObfuscate)
	METHOD Activate()
	METHOD Enable()
	METHOD Disable()
	METHOD Visible()
	METHOD Destroy()
	METHOD Refresh()
	METHOD SetAlign()
	METHOD SetF3()
	METHOD GetF3()
	METHOD SetbF3()
	METHOD Limpar()
	METHOD Clear()
	METHOD IsChanged()
	METHOD SetChange()
	METHOD SetGotFocus()
	METHOD SetLostFocus()
	METHOD SetLabelVisible()
	METHOD ClassName()
	METHOD ClassNameCpo()
	METHOD SetValue()
	METHOD Changing()
	METHOD GetValue()
	METHOD GetValueOld()
	METHOD GetValueDefault()
	METHOD SetFocus()
	METHOD SetValueOld()
	METHOD SetHelp()
	METHOD Hide()
	METHOD Show()
	METHOD SetValid()
	METHOD Change()
	METHOD RunSetGet()
	METHOD GetListItens()
	METHOD SetListItens()
	METHOD EnableF3Multi()
	METHOD DisableF3Multi()
	METHOD IsF3Multi()
	METHOD GetTable()
	METHOD GetNameField()
	METHOD GetWhere()
	METHOD GetTypeField()
	METHOD SetWhen( bWhen )
	METHOD IsModified()

ENDCLASS

METHOD Initialize(nRow, nCol, nWidth, nHeight, oWnd, cSay, cCodCampo, bGotFocus, bLostFocus, xSugestao, lVisible, lEnable, cF3, nAlign, cListItens, lAltLote, lCboxEmpty, lObfuscate) Class TJurPnlCampo

	Default bGotFocus  	:= {|| }
	Default bLostFocus 	:= {|| }
	Default xSugestao  	:= ""
	Default lVisible   	:= .T.
	Default lEnable	   	:= .T.
	Default cF3        	:= ""
	Default nAlign     	:= ""
	Default cListItens 	:= ""
	Default lAltLote    := .F.
	Default lCboxEmpty  := .T.
	Default lObfuscate  := .F.

	Self:SetListItens(cListItens)

	Self:oWnd         := oWnd
	Self:aDadosCpoNVH := GetDadosCampo(cCodCampo)
	Self:cCodCampo    := Self:aDadosCpoNVH[_COD]
	Self:cDescCampo   := AllTrim(IIF(Empty(cSay), cSay := Self:aDadosCpoNVH[_DESC], cSay))
	Self:cNomeTab	  := Self:aDadosCpoNVH[_TABELA]
	Self:cNomeCampo   := Self:aDadosCpoNVH[_CAMPO]
	Self:aInfoCampo   := GetInfSX3(Self:cNomeCampo, cSay, xSugestao, Self:GetListItens())
	Self:nRow         := nRow
	Self:nCol         := nCol
	Self:nWidth       := nWidth
	Self:nHeight      := nHeight
	Self:Valor        := IIF(Empty(xSugestao) .AND. !Empty(Self:cNomeCampo) , CriaVar( Self:cNomeCampo, .F. ), TransCpo(xSugestao, Self:aInfoCampo[2], Self:aInfoCampo[3]))
	Self:lVisible     := lVisible
	Self:lEnable      := lEnable
	Self:lAlterado    := .F.
	Self:bGotFocus    := IIF(Empty(bGotFocus), {|| }, bGotFocus)
	Self:bLostFocus   := IIF(Empty(bLostFocus), {|| }, bLostFocus)
	Self:nAlign       := nAlign
	Self:bChangeUsr   := {|| }
	Self:lActivated   := .F.
	Self:lCboxEmpty   := lCboxEmpty
	Self:lObfuscate   := lObfuscate
	Self:cTipoCpo     := Self:aInfoCampo[2] // Tipo do Campo
	Self:ValidCpo     := Self:aDadosCpoNVH[_VALID] // Valid do Campo
	Self:cF3          := IIF(!Empty(cF3), cF3, Self:aDadosCpoNVH[_F3CONS] )
	Self:bF3          := Nil
	Self:bValid       := {|| }
	Self:lbChanged    := .F.
	Self:lF3Multi     := Self:aDadosCpoNVH[_F3MULT]
	Self:bF3Multi     := {|| JbF3LUpMul(Self:cF3, Self:oCampo, @Self:Valor) }
	Self:bF3Simp      := {|| JbF3LookUp(Self:cF3, Self:oCampo, @Self:Valor) }
	Self:cWhere       := Self:aDadosCpoNVH[_WHERE]
	Self:lAltLote		:= .F.
	Self:lLabel 		:= !Self:aInfoCampo[2] == 'L' .AND. !Empty( Self:cDescCampo )

	Self:SetHelp()

Return Self

//Este METHOD foi mantido apenas para compatibilidade.
METHOD New(nRow, nCol, nWidth, nHeight, oWnd, cSay, cCodCampo, bGotFocus, bLostFocus, xSugestao, lVisible, lEnable, cF3, nAlign, cListItens, lAltLote, lCboxEmpty, lObfuscate) Class TJurPnlCampo

	Self:Initialize(nRow, nCol, nWidth, nHeight, oWnd, cSay, cCodCampo, bGotFocus, bLostFocus, xSugestao, lVisible, lEnable, cF3, nAlign, cListItens, lAltLote, lCboxEmpty, lObfuscate)
	Self:Activate()

Return Self

METHOD Activate() Class TJurPnlCampo
Local cTextHtml
// Tratativa para montagem em smartclientHTML - Pesquisa Multipla
	If GetRemoteType() == 5
		If Self:IsF3Multi()
			cTextHtml := '<table border=0 cellpadding=0 cellspacing=0>'  //retirados os espaços antes do inicio das tags, pois estava afetando o layout no webapp versão 4.2
			cTextHtml +=   '<tr>'
			cTextHtml +=     '<td rowspan="3" width=99.8% align="left" style="color:red">' + AllTrim(Self:cDescCampo) + '</td>'
			cTextHtml +=   '</tr> '
			cTextHtml +=   '</table>'
		Endif
	Else
		If Self:IsF3Multi()
			cTextHtml := '<table border=0 cellpadding=0 cellspacing=0>'
			cTextHtml +=   '<tr>'
			cTextHtml +=     '<td rowspan="3" width=99.8% align="left">' + AllTrim(Self:cDescCampo) + '</td>'
			cTextHtml +=     '<td style="color: white"> . </td>'
			cTextHtml +=   '</tr>'
			cTextHtml +=   '<tr> '
			cTextHtml +=     '<td style="color: white"> . </td> '
			cTextHtml +=   '</tr>'
			cTextHtml +=   '<tr> '
			cTextHtml +=     '<td width=10 style="color: red"> _ </td> '
			cTextHtml +=   '</tr> '
			cTextHtml += '</table>'
		EndIf
	EndIf

	Self:oPanel := tSay():New(Self:nRow,Self:nCol,{|| },Self:oWnd,,/*TFont*/,,,,.T., /*rgb(0,58,94)*/,,Self:nWidth,Self:nHeight,,,,,,Self:IsF3Multi()/*lHtml*/) // #003a5e

	If Self:IsF3Multi()
		Self:oPanel:SetText( cTextHtml )
	Else
		Self:oPanel:SetText( Self:cDescCampo )
	EndIf

	If !Empty(Self:nAlign)
		Self:oPanel:Align := Self:nAlign
	EndIF

	Self:oPanel:lTransparent := .F.

	Do Case
		Case Self:aInfoCampo[2] == 'M'
			IIf ( Self:lLabel, Self:nTop := 8, Self:nTop := 1 )

			Self:oCampo := tMultiget():New(Self:nTop,0,{|| },Self:oPanel,Self:nWidth,Self:nHeight-9,,,,,,.T.,,,/*bChange*/,,/*ReadOnly*/!Self:lEnable)

			If !Self:lLabel
				Self:oCampo:Align := CONTROL_ALIGN_ALLCLIENT
			EndIF
			If Self:lObfuscate .AND. GetRpoRelease() >= "12.1.027"
				Self:oCampo:lObfuscate := Self:lObfuscate
			EndIf

		Case Self:aInfoCampo[2] == 'L'
			Self:oCampo := TCheckBox():New(Self:nTop,0, Self:cDescCampo,{|| },Self:oPanel,Self:nWidth,Self:nHeight,,,,,,,,.T.,,,)
			Self:oCampo:Align := CONTROL_ALIGN_BOTTOM

		Otherwise
			IIf (Self:lLabel, (Self:nTop := 9, Self:nHeight := Self:nHeight-11, Self:nWidth := Self:nWidth-2 ), (Self:nTop := 1, Self:nHeight := Self:nHeight-11))

			IF !Empty(Self:aInfoCampo[12])
				Self:oCampo := tComboBox():New(Self:nTop ,0,{|u|if(PCount()>0,Self:Valor:=u,Self:Valor)},GetItems(Self:aInfoCampo[12], Self:lCboxEmpty),;
																	  Self:nWidth,Self:nHeight,Self:oPanel,,{||/*Ação*/},,,,.T.,,,,,,,,,'Self:Valor')
			Else
				Self:oCampo := TGet():New(Self:nTop ,0,{|| },Self:oPanel,Self:nWidth,Self:nHeight,Self:aInfoCampo[6],;
																 ,0,,,.F.,,.T.,,.F.,/*{ || !Self:lEnable }*/,.F.,.F.,,/*ReadOnly*/!Self:lEnable,.F.,Self:GetF3(),'Self:Valor',,,,.T.)
				If Self:lObfuscate .AND. GetRpoRelease() >= "12.1.027"
					Self:oCampo:lObfuscate := Self:lObfuscate
				EndIf
			EndIf
			//Self:oCampo:Align := CONTROL_ALIGN_BOTTOM
	EndCase

	Self:VlrDefault        := Self:Valor
	Self:ValorOld          := Self:Valor
	Self:ClassName         := "TJURPNLCAMPO" // Self:oCampo:ClassName()
	Self:oCampo:bGotFocus  := Self:bGotFocus
	Self:oCampo:bLostFocus := Self:bLostFocus
	Self:oCampo:bSetGet	   := {|u| Self:RunSetGet(u) }
	Self:oCampo:bChange	   := {|| Self:Change() }
	Self:oCampo:cReadVar   := IIF(Empty(Self:cNomeCampo), Self:cNomeCampo, "M->"+Self:cNomeCampo)
	Self:oCampo:bHelp      := {|| EVal(Self:bHelp)}
	Self:oCampo:bValid     := Self:bValid
	Self:nRow              := Self:oPanel:nTop
	Self:nCol              := Self:oPanel:nLeft
	Self:nWidth            := Self:oPanel:nWidth
	Self:nHeight           := Self:oPanel:nHeight

	Self:lActivated := .T.

	If !Self:lVisible
		Self:Visible(Self:lVisible)
	EndIf

	Self:Enable(Self:lEnable)

Return Nil

Method RunSetGet(u) Class TJurPnlCampo
Local xRet

	If Pcount()>0 .And. !(u == Nil)
		If Self:SetValueOld(Self:Valor)
			Self:Valor := u
			Self:lbChanged := .F.
			Self:Change()
		EndIf
	EndIf

	xRet := Self:Valor

Return xRet

Method Change() Class TJurPnlCampo
Local lRet := .T.

  If !Self:lbChanged
		lRet := Self:Changing() .And. Eval(Self:bChangeUsr)
		Self:lbChanged := .T.
	EndIf

Return lRet

Method Changing() Class TJurPnlCampo

	If Self:cTipoCpo == ValType(Self:Valor)
		Self:lAlterado := !(Self:Valor == Self:ValorOld)
	Else
		Self:lAlterado := .T.
	EndIF

Return Self:lAlterado

METHOD Enable(lEnable) Class TJurPnlCampo
Local lRet := .F.
Default lEnable := .T.
	If ValType(lEnable) == "L" .And. ::lActivated
  	::lEnable := lEnable
	  if lEnable
	    ::oPanel:Enable()
	  Else
	    ::oPanel:Disable()
	  EndIF
	  lRet := .T.
	EndIf
Return lRet

METHOD Disable(lEnable) Class TJurPnlCampo
Default lEnable := .F.
Return Self:Enable(lEnable)

METHOD Visible(lVisible) Class TJurPnlCampo
Default lVisible := .T.
	If ValType(lVisible) == "L" .And. ::lActivated
		::lVisible := lVisible
	  if ::lVisible
	    if (::oPanel!=Nil)
	    	::oPanel:Show()
	    Endif
	  Else
	    if (::oPanel!=Nil)
	    	::oPanel:Hide()
	    Endif
	  EndIF
	EndIf
Return Nil

METHOD Destroy() Class TJurPnlCampo
	If ::lActivated
		::Visible(.F.)
		if (::oCampo != NIl)
			::oCampo:bSetGet := {|| }
			::oCampo:bChange := {|| }
		Endif
	EndIf
	if (Self:oPanel != NIl)
		Self:oPanel:FreeChildren()
	Endif
	//FreeObj(Self)
Return NIL

METHOD Refresh() Class TJurPnlCampo
Local lAllClient := !Empty(Self:nAlign) .And. Self:nAlign == CONTROL_ALIGN_ALLCLIENT

	If Self:lActivated
		If !lAllClient
		  Self:oPanel:nTop    := Self:nRow
		  Self:oPanel:nLeft   := Self:nCol
		  Self:oPanel:nWidth  := Self:nWidth
		  Self:oPanel:nHeight := Self:nHeight
			Self:SetAlign(Self:nAlign)
		EndIf
	  Self:oPanel:Refresh()
	  Self:oCampo:Refresh()
	EndIf

Return NIL

METHOD SetAlign(nAlign) Class TJurPnlCampo
Local lRet := .F.
	If ValType(nAlign) == "N"
		If ::lActivated
			::oPanel:Align := nAlign
		EndIf
		::nAlign := nAlign
		lRet := .T.
	EndIf
Return lRet

METHOD SetF3(cF3) Class TJurPnlCampo
Local lRet := .F.

Default cF3 := ""

	If ValType(cF3) == "C"
		If !Empty(cF3)
			Self:aDadosCpoNVH[_F3DIF] := .T. // Irá usar F3 informado
			Self:cF3 := cF3

			If ::lF3Multi .And. Empty(Self:bF3) .And. !lAltLote
				Self:SetbF3() // Forço adicionar o bloco Self:bF3Multi dentro da Self:bF3()
			EndIf

			If ::lActivated
				Self:oCampo:cF3 := Self:cF3
			EndIf
		Else
			Self:aDadosCpoNVH[_F3DIF] := .F.
			Self:cF3 := cF3
		EndIf
		lRet := .T.
	EndIf

Return lRet

METHOD GetF3() Class TJurPnlCampo
Local cRet := ""

	If ::aDadosCpoNVH[_F3DIF] // Tem F3
		IF !Empty(Self:cF3) // Usa F3 Informado
			cRet := Self:cF3
		EndIf
	Else
		If !Empty(::aInfoCampo[8]) // Pega do SX3
			Self:cF3 := ::aInfoCampo[8]
			cRet := Self:cF3
		EndIf
	EndIf

Return cRet

METHOD SetbF3(bF3) Class TJurPnlCampo
Local lRet := .F.

Default bF3 := {|| }

	If !Empty(bF3) .And. ValType(bF3) == "B"

		If Self:lF3Multi .And. !Empty(Self:cF3)
			Self:bF3 := {|| Eval(Self:bF3Multi), Eval(bF3)}
		/*Else
			Self:bF3 := {|| Eval(Self:bF3Simp), Eval(bF3)}*/
		EndIf

		If ::lActivated .And. !Empty(Self:cF3)
			Self:oCampo:bF3 := Self:bF3
			lRet            := .T.
		EndIf
	EndIf

Return lRet

METHOD Limpar() Class TJurPnlCampo
Local lRet := .T.

	::Valor := CriaVar( ::cNomeCampo, .F. )

	If !Empty(::Valor)
		lRet := .F.
	EndIF

Return lRet

METHOD Clear() Class TJurPnlCampo
Return Self:Limpar()

METHOD IsChanged() Class TJurPnlCampo
	If ::Valor != ::ValorOld
		::lAlterado := .T.
		::ValorOld := ::Valor
	Else
		::lAlterado := .F.
	EndIf
Return ::lAlterado

METHOD SetChange(bChangeX) Class TJurPnlCampo
Local lRet := .F.

Default bChangeX := {|| }

	If !Empty(bChangeX) .And. ValType(bChangeX) == "B"
		Self:bChangeUsr := bChangeX
		lRet := .T.
	EndIf

Return lRet

METHOD SetGotFocus(bGotFocus) Class TJurPnlCampo
Local lRet := .F.

Default bGotFocus := {|| }

	If !Empty(bGotFocus) .And. ValType(bGotFocus) == "B"
		Self:bGotFocus := bGotFocus
		If ::lActivated
			Self:oCampo:bGotFocus := Self:bGotFocus
		EndIf
		lRet := .T.
	EndIf

Return lRet

METHOD SetLostFocus(bLostFocus) Class TJurPnlCampo
Local lRet := .F.

Default bLostFocus := {|| }

	If !Empty(bLostFocus) .And. ValType(bLostFocus) == "B"
		Self:bLostFocus := bLostFocus
		If ::lActivated
			Self:oCampo:bLostFocus := Self:bLostFocus
		EndIf
		lRet := .T.
	EndIf

Return lRet

METHOD SetLabelVisible(lVisible) Class TJurPnlCampo
Default lVisible := .T.

	If Valtype(lVisible) == "L"
		Self:lLabel := lVisible
	EndIf

Return Nil

METHOD ClassName() Class TJurPnlCampo
Return Upper(Self:ClassName)

METHOD ClassNameCpo() Class TJurPnlCampo
Return UPPER(	Self:oCampo:ClassName())

METHOD SetValue(xValor, xValorOld) Class TJurPnlCampo
Local lRet := .T.

Default xValor    := Self:Valor
Default xValorOld := Self:ValorOld

	If Self:cTipoCpo <> ValType(xValor)
		xValor := TransCpo(xValor, Self:cTipoCpo)
	EndIf

	If xValor <> Self:Valor
		lRet := (Self:Valor := xValor) == xValor
	EndIf

	If lRet .And. Self:cTipoCpo <> ValType(xValorOld) .And. xValorOld <> Self:ValorOld
		lRet := (Self:ValorOld := xValorOld) == xValorOld
	EndIf

	If lRet
		Self:Refresh()
	EndIf

Return lRet

METHOD GetValue() Class TJurPnlCampo
Return Self:Valor

METHOD GetValueOld() Class TJurPnlCampo
Return Self:ValorOld

METHOD GetValueDefault() Class TJurPnlCampo
Return Self:VlrDefault

METHOD SetValueOld(xValorOld) Class TJurPnlCampo
Default xValorOld := Self:GetValueOld()

	If Self:cTipoCpo <> ValType(xValorOld)
		xValorOld := TransCpo(xValorOld, Self:cTipoCpo)
	EndIf

Return (Self:ValorOld := xValorOld) == xValorOld

METHOD SetFocus() Class TJurPnlCampo
Return Self:oCampo:SetFocus()

METHOD SetHelp(cText) Class TJurPnlCampo
Local lRet := .F.

Default cText := ""
		                                             // Ajuda      // Validação
	Self:bHelp := {|| ShowHelpCpo(Self:cNomeCampo, {cText}, 5, {RemoveKeys(GetCBSource(Self:bChangeUsr))}, 5) }

Return lRet

METHOD Hide() Class TJurPnlCampo
Return Self:Visible(.F.)

METHOD Show() Class TJurPnlCampo
Return Self:Visible(.T.)

METHOD SetValid(bValid) Class TJurPnlCampo
Local lRet := .F.

Default bValid := {|| }

	If !Empty(bValid) .And. ValType(bValid) == "B"
		Self:bValid := bValid
		If ::lActivated
			Self:oCampo:bValid := Self:bValid
		EndIf
		lRet := .T.
	EndIf

Return lRet

METHOD GetListItens() Class TJurPnlCampo
Return Self:cListItens

METHOD SetListItens(cListItens) Class TJurPnlCampo

	If !Empty(cListItens) .And. ValType(cListItens) == "C"
		Self:cListItens := cListItens
	EndIf

Return Self:cListItens == cListItens

METHOD EnableF3Multi(lSet) Class TJurPnlCampo
Default lSet := .T.

	If ValType(lSet) == "L"
		Self:lF3Multi := lSet
		Self:setbF3()
	EndIf

Return Self:lF3Multi

METHOD DisableF3Multi() Class TJurPnlCampo
Return Self:EnableF3Multi(.F.)

METHOD IsF3Multi() Class TJurPnlCampo
Return Self:lF3Multi

METHOD GetTable() Class TJurPnlCampo
Return Self:cNomeTab

METHOD GetNameField() Class TJurPnlCampo
Return Self:cNomeCampo

METHOD GetWhere() Class TJurPnlCampo
Return Self:cWhere

METHOD GetTypeField() Class TJurPnlCampo
Return Self:cTipoCpo

//-------------------------------------------------------------------
/*/{Protheus.doc} SetWhen
Metodo para implementar regras de When no Campos
(o método Enable() não altera em tempo de execução)
Obs: Verificar se o componente ecapsulado (TGet, TCombobox, etc...)
possue a propriedade bWhen() antes de usar o método.

@Param    bWhen Bloco de codigo para o When do campo

@Return   lRet  .T. se o obejeto tem o método bWhen()

@author Luciano Pereira dos Santos
@since 06/06/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetWhen( bWhen ) Class TJurPnlCampo
Local lRet := .T.

Default bWhen := {|| }

If Valtype(Self:oCampo:bWhen) == "B" .and. Valtype(bWhen) == "B"
	Self:oCampo:bWhen := bWhen
	Self:Refresh()
Else
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetWhen
Com base no objeto TControl, indica se o conteúdo da variável
associada ao objeto foi modificado (não diferencia se foi alterado
para o mesmo valor antigo).

@Return lModified, Se foi alterado o valor

@author Bruno Ritter
@since 10/12/2018
/*/
//-------------------------------------------------------------------
METHOD IsModified() Class TJurPnlCampo
	Local lModified := Self:oCampo:lModified

Return lModified

// ---------------------------------------------- FUNCTIONS ---------------------------------------------- \\

Static Function GetDadosCampo(cCodCampo)
Local aRet  := {"","","","","","","",.F.,"","",.F.}
local aArea := GetArea()

Default cCodCampo := ""

	If !Empty(cCodCampo)
		IF Type(cCodCampo) == 'N' .AND. IsPesquisa()
			NVH->(DBSetOrder(1))
			IF NVH->( DBSeek(XFILIAL('NVH') + cCodCampo) )

				aRet := {}
				aADD( aRet, NVH->NVH_FILIAL)
				aADD( aRet, NVH->NVH_COD)
				aADD( aRet, NVH->NVH_DESC)
				aADD( aRet, NVH->NVH_TABELA)
				aADD( aRet, NVH->NVH_CAMPO)
				aADD( aRet, NVH->NVH_WHERE)
				aADD( aRet, NVH->NVH_PROPRI)
				aADD( aRet, NVH->NVH_F3DIF)
				aADD( aRet, NVH->NVH_F3CONS)
				aADD( aRet, "") // Valid
				aADD( aRet, NVH->NVH_F3MULT) // F3 Multi

			EndIf
		Else
			dbSelectArea( 'SX3' )
			SX3->( dbSetOrder(2) )
			If SX3->( dbSeek(cCodCampo) )

				aRet := {}
				aADD( aRet, xFilial(SX3->X3_ARQUIVO) )
				aADD( aRet, "")
				aADD( aRet, AllTrim(X3Titulo()) )
				aADD( aRet, SX3->X3_ARQUIVO)
				aADD( aRet, SX3->X3_CAMPO)
				aADD( aRet, "")
				aADD( aRet, "")
				aADD( aRet, .T.)
				aADD( aRet, SX3->X3_F3)
				aADD( aRet, SX3->X3_VALID) // Valid
				aADD( aRet, .F.) // F3 Multi

			EndIf
		EndIf
	EndIF

	RestArea(aArea)

Return aRet

Static function GetInfSX3(cNomeCampo, cSay, xSugestao, cListItens)
Local aRet := {}
Local nTam := 0

  If !Empty(cNomeCampo)
		aRet := AVSX3(cNomeCampo)
  Else
	If Empty(cListItens)
		nTam := Iif( valtype(xSugestao) == "C", len(xSugestao), 11 )
	Else
		AEval( GetItems(cListItens) , { |cItem| Iif(Len(cItem)> nTam, nTam := Len(cItem), ) } )
	EndIf

  	aAdd( aRet , "" )
  	aAdd( aRet , valtype(xSugestao) )
  	aAdd( aRet , nTam )
  	aAdd( aRet , Iif( valtype(xSugestao) == "N", 2, "" ) )
  	aAdd( aRet , cSay )
  	aAdd( aRet , Iif( valtype(xSugestao) == "N", "@E 99,999,999.99", "") )
  	aAdd( aRet , {|| .T.} )
  	aAdd( aRet , "" )
  	aAdd( aRet , 0 )
  	aAdd( aRet , "" )
  	aAdd( aRet , "S" )
  	aAdd( aRet , cListItens )
  	aAdd( aRet , {|| .T.} )
  	aAdd( aRet , Iif(valtype(xSugestao) == "N", Transform(xSugestao, "@E 99,999,999.99"), xSugestao) )
  	aAdd( aRet , "" )
  EndIF

Return aRet

Static Function TransCpo(xValor, cTipo, nTamanho)
Local Ret   := xValor
Local xTipo := ValType(xValor)

Default nTamanho := 255

	Do case
		Case cTipo == "D" .AND. xTipo == "C"
		  Ret := CToD(xValor)

		Case cTipo == "N" .And. ValType(xValor) <> "N"
		  Ret := VAL(xValor)

		Case cTipo == "C"
			If xTipo == "D"
				Ret := DtoC(xValor)
			Else
			  Ret := SUBSTRING(xValor,1,nTamanho)
			EndIf

		OtherWise // Memo
		  Ret := xValor
	End Case

Return Ret

Static Function GetItems(cItems, lCboxEmpty)
Local cAux := '', aRet := {}
Local nI, nTam := LEN(cItems)

Default lCboxEmpty := .T.

If lCboxEmpty
	aADD(aRet, '')
EndIf

For nI = 1 to nTam
	IF !(SUBSTRING(cItems,nI,1) == ';')
		cAux := cAux + SUBSTRING(cItems,nI,1)
	Else
		aADD(aRet, cAux)
		cAux := ''
	EndIF
Next
aADD(aRet, cAux)

Return aRet

Static Function RemoveKeys(cBloco)
Local cRet := ""
Default cBloco := "{|| }"

	cRet := SubStr(cBloco, At("||", cBloco)+2, LEN(cBloco)-4)

Return cRet