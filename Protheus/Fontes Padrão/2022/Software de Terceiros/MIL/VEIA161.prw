//Bibliotecas
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "VEIA161.CH"

/*/{Protheus.doc} VEIA161

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
 
Function VEIA161(cNumPed,lNaoVistos)

	Local aSeeks := {}
	Local aIndice := {}
	Local aColFiltro := {}
	Local aColTab := {}
	Local cCamposQuery := ""
	Local cFiltro   := ""
	Local cFiltroAlt:= ""

	Local oBrwVQ0

	Local aColunasVJS := {}
	Local aCamposVJS  := {}

	Local cAliasTMP := ""

	Local nCorAzul    := RGB(30,144,255)
	Local nCorAmarelo := RGB(255,215,0)
	Local nCorVermelho:= RGB(255,99,71)

	Private oBrwCpoVJS
	Private oBrwVJS

	Private aSize     := FWGetDialogSize( oMainWnd )
	Private aRegSel   := {}
	Private lAplica   := .f.

	Private cCampos   := ""
	Private aVetCpoBrw := {}

	Private aCores    := {nCorAzul,nCorAmarelo,nCorVermelho}

	Default cNumPed   := ""
	Default lNaoVistos := .f.

	lRegNaoVistos	:= lNaoVistos
	cNroPedido		:= cNumPed

	AADD(aColunasVJS,{	GetSX3Cache("VJS_TITCPO","X3_TITULO"),;
							&("{ || GetSX3Cache((oTmpCpo:GetAlias())->VJS_CPOALT,'X3_DESCRIC') }"),;
							"C",;
							"@!",;
							1,;
							30,;
							0,;
							.f. })

	AADD(aCamposVJS, "VJS_TITCPO" )

	cFiltro := " !EMPTY(VQ0_CODVJQ) "

	If !Empty(cNroPedido)
		cFiltro += " .and. VQ0_CODIGO == '" + cNroPedido + "'"
	EndIf

	oDlgOA120 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], "Painel", , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

		oWorkArea := FWUIWorkArea():New( oDlgOA120 )
		
		oWorkArea:CreateHorizontalBox( "LINE01", 30 ) // -1 para nao estourar 100% da tela ( criando scroll lateral )
		oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
		oWorkArea:CreateHorizontalBox( "LINE02", 70 )
		oWorkArea:SetBoxCols( "LINE02", { "OBJ2" } )

		oWorkArea:Activate()

		oWTop	:= oWorkarea:GetPanel("OBJ1")
		oWBot	:= oWorkarea:GetPanel("OBJ2")

		oSplitter := tSplitter():New( 01,01,oWBot,260,184 )
		oSplitter:Align := CONTROL_ALIGN_ALLCLIENT
		
		oPanel1:= tPanel():New(322,02," Painel 01",oSplitter,,,,,,60,60)
		oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
		oPanel2:= tPanel():New(322,02," Painel 02",oSplitter,,,,,,60,80)
		oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

		oBrwVQ0 := FwMBrowse():New()
		oBrwVQ0:SetOwner(oWTop)
		oBrwVQ0:SetDescription( STR0001 )
		oBrwVQ0:SetAlias('VQ0')
		oBrwVQ0:lChgAll := .T.//nao apresentar a tela para informar a filial
		oBrwVQ0:SetFilterDefault( cFiltro )
		oBrwVQ0:DisableDetails()
		oBrwVQ0:ForceQuitButton(.T.)

		oBrwVQ0:AddButton( STR0002 , { || VA1610065_Filter(1) } )
		oBrwVQ0:AddButton( STR0003 , { || VA1610065_Filter(2) } )

		oBrwVQ0:Activate()

		oBrwVJS := FwMBrowse():New()
		oBrwVJS:SetOwner(oPanel1)
		oBrwVJS:SetDescription( STR0004 )
		oBrwVJS:SetMenuDef( '' )
		oBrwVJS:SetAlias('VJS')

		If lRegNaoVistos
			oBrwVJS:AddFilter( STR0003,"@ VJS_REGVIS <> '1'",.f.,.t.,,,,"naovistos")
		EndIf

		oBrwVJS:DisableLocate()
		oBrwVJS:DisableDetails()
		oBrwVJS:SetAmbiente(.F.)
		oBrwVJS:SetWalkthru(.F.)
		oBrwVJS:SetInsert(.f.)
		oBrwVJS:SetUseFilter()
		oBrwVJS:lOptionReport := .f.
		oBrwVJS:SetBlkBackColor( { || VA1610055_AlteraCorLinha()} )
		oBrwVJS:Activate()

		oRelacPed:= FWBrwRelation():New()
		oRelacPed:AddRelation( oBrwVQ0 , oBrwVJS , {{ "VJS_FILIAL", "xFilial('VJS')" }, { "VJS_CODVQ0", "VQ0_CODIGO" } })
		oRelacPed:Activate()

		oTmpCpo := VA1610035_ConfigBrowse()

		cAliasTMP := oTmpCpo:GetAlias()
		oBrwCpoVJS := FwMBrowse():New()

		oTmpCpo:SetBrwOwner(oBrwCpoVJS)
		oTmpCpo:AddBrwColumn()

		oBrwCpoVJS:SetOwner(oPanel2)
		oBrwCpoVJS:SetAlias(cAliasTMP)
		oBrwCpoVJS:SetQueryIndex(oTmpCpo:_aIndex)
		oBrwCpoVJS:SetFields(aColunasVJS)
		oBrwCpoVJS:ColumnsFields(aCamposVJS)
		oBrwCpoVJS:SetDescription( STR0005 )
		oBrwCpoVJS:SetMenuDef( '' )
		oBrwCpoVJS:SetDoubleClick( { || VA1610015_AplicaFiltro((cAliasTMP)->VJS_CPOALT) } )
		oBrwCpoVJS:SetChange( { || VA1610025_LimpaFiltro() } )
		oBrwCpoVJS:DisableLocate()
		oBrwCpoVJS:DisableDetails()
		oBrwCpoVJS:DisableReport()
		oBrwCpoVJS:DisableSeek()
		oBrwCpoVJS:SetAmbiente(.F.)
		oBrwCpoVJS:SetWalkthru(.F.)
		oBrwCpoVJS:SetInsert(.f.)
		oBrwCpoVJS:SetUseFilter()
		oBrwCpoVJS:SetBlkBackColor( { || VA1610055_AlteraCorLinha((cAliasTMP)->VJS_CPOALT)} )
		oBrwCpoVJS:Activate()

		oRPedCpo:= FWBrwRelation():New()
		oRPedCpo:AddRelation( oBrwVQ0 , oBrwCpoVJS , {{ "VJS_CODVQ0", "VQ0_CODIGO" } })
		oRPedCpo:Activate()

	oDlgOA120:Activate( , , , , , , ) //ativa a janela

	oTmpCpo:DelTrabTmp()

Return NIL

Function VA1610015_AplicaFiltro(cCPoFiltro)

	Default cCPoFiltro := ""

	if !Empty(cCPoFiltro)
		oBrwVJS:AddFilter( STR0006 +cCPoFiltro,"@ VJS_CPOALT='"+cCPoFiltro+"'",.f.,.t.,,,,"click")
		oBrwVJS:ExecuteFilter(.t.)
		lAplica := .t.
	EndIf

Return .t.

Function VA1610025_LimpaFiltro()

	If lAplica
		oBrwVJS:DeleteFilter("click")
		oBrwVJS:Refresh()
		lAplica := .f.
	EndIf

Return .t.

Function VA1610035_ConfigBrowse()
	Local cCpoMostra := ""
	Local cNBrowse := ""
	Local oBrwAba

	cCpoMostra := "VJS_CPOALT|"
	cCpoMostra += "VJS_CODVQ0"
	cCpoMostra += "|VJS_REGVIS"

	cNBrowse += "VJS_REGVIS|"

	oBrwAba := OFBrowseStruct():New({"VJS"})

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("VJS")
	While !Eof() .And. (x3_arquivo == "VJS")
		If X3USO(x3_usado) .and. x3_campo $ cCpoMostra

			lBrowse := !( AllTrim(x3_campo) + "|" $ cNBrowse )

			oBrwAba:AddField( x3_campo , , lBrowse )

			If Empty(cCampos)
				cCampos += x3_campo
			Else
				cCampos += "," + x3_campo
			EndIf
		EndIf
		dbSkip()
	EndDo

	oBrwAba:AddIndex( "VJS_CPOALT" )

	oBrwAba:CriaTabTmp()
	oBrwAba:LoadData( VA1610045_Query(cCampos) )

Return oBrwAba

Static Function VA1610045_Query(cCampos)

	Local cQuery := ""

	Default cCampos := "*"

	cQuery := "SELECT " + cCampos
	cQuery += " FROM " + RetSqlName("VJS") + " VJS "
	cQuery += "WHERE VJS.VJS_FILIAL = '" + xFilial("VJS") + "' "
	cQuery +=  " AND VJS.D_E_L_E_T_ = ' ' "
	cQuery +=  "GROUP BY " + cCampos

Return cQuery

Function VA1610055_AlteraCorLinha(cCpoAlt)

	Local cQuery := ""
	Local cOpcCor:= ""
	Local nOpcCor

	Default cCpoAlt := VJS->VJS_CPOALT

	cQuery := "SELECT VJT.VJT_CORCPO "
	cQuery += " FROM " + RetSqlName("VJT") + " VJT "
	cQuery += " WHERE VJT.VJT_FILIAL = '" + xFilial("VJT") + "'"
	cQuery +=	" AND VJT.VJT_ORIGEM = '001'"
	cQuery += 	" AND VJT.VJT_NOMCPO = '" + cCpoAlt + "'"
	cQuery +=	" AND VJT.D_E_L_E_T_ = ' ' "

	cOpcCor := FM_SQL(cQuery)

	If !Empty(cOpcCor)

		nOpcCor := Val(cOpcCor)
		Return aCores[nOpcCor]

	EndIf

Return Nil

Static Function VA1610065_Filter(nTpOpc)

	If nTpOpc == 1
		lRegNaoVistos := .f.

		oBrwVJS:DeleteFilter("naovistos")
		oBrwVJS:Refresh()

		oBrwCpoVJS:DeleteFilter("naovistos")
		oBrwCpoVJS:Refresh()
	Else
		lRegNaoVistos := .t.
		oBrwVJS:AddFilter( STR0003 ,"@ VJS_REGVIS <> '1'",.f.,.t.,,,,"naovistos")
		oBrwVJS:ExecuteFilter( .t. )

		oBrwCpoVJS:AddFilter( STR0003 ,"@ VJS_REGVIS <> '1'",.f.,.t.,,,,"naovistos")
		oBrwCpoVJS:ExecuteFilter( .t. )
	EndIf

Return .t.


Static Function VA1610075_AgrupaRegistro(cConteudo)

	Local lRet := .t.
	Local nPosCpo

	nPosCpo := aScan(aVetCpoBrw,{|x| x == cConteudo})

	if nPosCpo == 0
		aAdd(aVetCpoBrw,cConteudo)
	Else
		lRet := .f.
	EndIf

Return lRet