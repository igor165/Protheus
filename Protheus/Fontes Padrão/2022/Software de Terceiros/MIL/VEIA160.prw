//Bibliotecas
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#Include 'VEIA160.CH'

Static oTabTmp := NIL

/*/{Protheus.doc} VEIA160

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
 
Function VEIA160()
	
	Local cAliasTmp

	Local aSeeks := {}
	Local aIndice := {}
	Local aColFiltro := {}
	Local aColTab := {}
	Local cCamposQuery := ""
	Local cFiltro   := ""
	Local aSize     := FWGetDialogSize( oMainWnd )
	
	Private aRegSel   := {}

	Private cMark      := GetMark()
	
	cFiltro := "@ VQ0_CODVJQ <> ' ' AND NOT EXISTS( "
	cFiltro += "SELECT VJR.VJR_CODVQ0 FROM " + RetSqlName("VJR") + " VJR "
	cFiltro += "WHERE VJR.VJR_FILIAL = '" + xFilial("VJR") + "' "
	cFiltro +=  " AND VJR.VJR_CODVQ0 = VQ0_CODIGO "
	cFiltro +=  " AND VJR.VJR_DATVIS <> ' ' "
	cFiltro +=  " AND VJR.D_E_L_E_T_ = ' ' "
	cFiltro += ")"
	oDlgOA120 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], "Painel", , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

		oWorkArea := FWUIWorkArea():New( oDlgOA120 )
		
		oWorkArea:CreateHorizontalBox( "LINE01", 49 ) // -1 para nao estourar 100% da tela ( criando scroll lateral )
		oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
		oWorkArea:CreateHorizontalBox( "LINE02", 50 )
		oWorkArea:SetBoxCols( "LINE02", { "OBJ2" } )

		oWorkArea:Activate()

		oBrwVQ0 := FwMBrowse():New()
		oBrwVQ0:SetOwner(oWorkarea:GetPanel("OBJ1"))
		oBrwVQ0:SetDescription( STR0001 ) //Dados do Pedido
		oBrwVQ0:SetAlias('VQ0')
		oBrwVQ0:AddMarkColumns( { || VA1600095_ColBMark() },{ || VA1600025_MarkRegistro( oBrwVQ0, "VJR" ) }, {|| VA1600035_MarkAllRegistro( oBrwVQ0 , "VJR" ), oBrwVQ0:Refresh() } )
		oBrwVQ0:AddStatusColumns({|| VA1600045_ColunaStatus() }, {|| VA1600055_LegendaStatus() })

		oBrwVQ0:lChgAll := .T.//nao apresentar a tela para informar a filial

		oBrwVQ0:SetFilterDefault( cFiltro )
		oBrwVQ0:DisableDetails()
		oBrwVQ0:ForceQuitButton(.T.)
		oBrwVQ0:Activate()

		oBrwVJR := FwMBrowse():New()
		oBrwVJR:SetOwner(oWorkarea:GetPanel("OBJ2"))
		oBrwVJR:SetDescription( STR0002 ) //"Dados da Fabrica"
		oBrwVJR:SetMenuDef( '' )
		oBrwVJR:SetAlias('VJR')
		oBrwVJR:DisableLocate()
		oBrwVJR:DisableDetails()
		oBrwVJR:SetAmbiente(.F.)
		oBrwVJR:SetWalkthru(.F.)
		oBrwVJR:SetInsert(.f.)
		oBrwVJR:SetUseFilter()
		oBrwVJR:lOptionReport := .f.
		oBrwVJR:Activate()

		oRelacPed:= FWBrwRelation():New()
		oRelacPed:AddRelation( oBrwVQ0 , oBrwVJR , {{ "VJR_FILIAL", "xFilial('VJR')" }, { "VJR_CODVQ0", "VQ0_CODIGO" } })
		oRelacPed:Activate()

	oDlgOA120:Activate( , , , , , , ) //ativa a janela

Return NIL
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  03/09/2016                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
  
Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções
	ADD OPTION aRotina TITLE STR0003 ACTION 'VA1600065_Historico()' OPERATION 2 ACCESS 0 // 'Hist. Import.'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VA1600075_MarcaVisto()' OPERATION 4 ACCESS 0 //'Marcar como Visto'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VA1600105_LimpaHistorico()' OPERATION 4 ACCESS 0 //'Limpar Histórico'
	ADD OPTION aRotina TITLE STR0022 ACTION 'VA160011A_CallDTF()' OPERATION 4 ACCESS 0 //'Importa DTF'

Return aRotina

/*/{Protheus.doc} VEIA160

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1600015_Query(cCampos,cTipo)

	Local cQuery  := ""
	Local cPedido := ""
	Local cOrdGrp := ""
	Local cOrdNum := ""
	
	VJR->(DbSeek(xFilial("VJR")+VQ0->VQ0_CODIGO))

	cPedido := VJR->VJR_ORDNUM
	cOrdGrp := Subs(cPedido,1,GeTSX3Cache("VJQ_ORDGRP","X3_TAMANHO"))
	cOrdNum := Subs(cPedido,GeTSX3Cache("VJQ_ORDGRP","X3_TAMANHO")+1,GeTSX3Cache("VJQ_ORDNUM","X3_TAMANHO"))

	Default cTipo   := ""
	Default cCampos := "*"

	cQuery := "SELECT " + cCampos
	cQuery += " FROM " + RetSqlName("VJQ") + " VJQ "
	cQuery += "WHERE VJQ.VJQ_FILIAL = '" + xFilial("VJQ") + "' "
	cQuery +=  " AND VJQ.VJQ_ORDGRP = '" + cOrdGrp + "' "
	cQuery +=  " AND VJQ.VJQ_ORDNUM = '" + cOrdNum + "' "
	cQuery +=  " AND VJQ.VJQ_RCRDTP = '" + cTipo + "' "
	cQuery +=  " AND VJQ.D_E_L_E_T_ = ' ' "

Return cQuery

/*/{Protheus.doc} VEIA160

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1600025_MarkRegistro( oMarkBrow , cAliasTmp )

	Local lRet := .T.
	
	If aScan(aRegSel,{|x| x[1] == VQ0->VQ0_CODIGO }) == 0
		aAdd(aRegSel, { VQ0->VQ0_CODIGO })
	Else
		aDel(aRegSel,aScan(aRegSel,{|x| x[1] == VQ0->VQ0_CODIGO }))
		aSize(aRegSel, Len(aRegSel) - 1)
	EndIf

Return( Nil )

/*/{Protheus.doc} VEIA160

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1600035_MarkAllRegistro( oMarkBrow , cAliasTmp )

Local aArea 	 := GetArea()
Local aAreaAlias := VQ0->( GetArea() )
Local lMarca	 := .F.

VQ0->( DbGoTop() )

While VQ0->( !EOF() )

	If aScan(aRegSel,{|x| x[1] == VQ0->VQ0_CODIGO }) == 0
		aAdd(aRegSel, { VQ0->VQ0_CODIGO })
	Else
		aDel(aRegSel,aScan(aRegSel,{|x| x[1] == VQ0->VQ0_CODIGO }))
		aSize(aRegSel, Len(aRegSel) - 1)
	EndIf
	VQ0->( DbSkip() )

EndDo

RestArea( aAreaAlias ) 
RestArea( aArea )

Return( Nil )

/*/{Protheus.doc} VEIA160

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1600045_ColunaStatus()
	
	// Variável do Retorno
	Local cImgRPO := ""

	cAlVJR := 'TABVJR'
	BeginSql alias cAlVJR
		SELECT
			VJR.VJR_STAIMP
		FROM
			%table:VJR% VJR
		WHERE
			VJR.VJR_FILIAL = %xfilial:VJR% AND
			VJR.VJR_CODVQ0 = %exp:VQ0->VQ0_CODIGO% AND
			VJR.%notDel%
	EndSql
	//-- Define Status do registro
	If (cAlVJR)->VJR_STAIMP == "0"
		cImgRpo := "BR_VERDE"
	ElseIf (cAlVJR)->VJR_STAIMP == "1"
		cImgRpo := "BR_AZUL"
	EndIf

	(cAlVJR)->(dbCloseArea())
	
Return cImgRPO

/*/{Protheus.doc} VEIA160

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1600055_LegendaStatus()

	// Array das Legendas
	Local aLegenda := {	{"BR_VERDE" , STR0006 }, ; //"Incluído"
						{"BR_AZUL"  , STR0007 } } //"Alterado"

	//-- Define Status do registro
	BrwLegenda( STR0008 , STR0009 ,aLegenda )	//"Pedidos de Maquinas" / "Legenda"

Return .T.

/*/{Protheus.doc} VEIA160

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1600065_Historico()

	Local cFiltro := ""

	Local cPedido := ""
	Local cOrdGrp := ""
	Local cOrdNum := ""
	Local aSize     := FWGetDialogSize( oMainWnd )

	VJR->(DbSeek(xFilial("VJR")+VQ0->VQ0_CODIGO))

	cPedido := VJR->VJR_ORDNUM
	cOrdGrp := Subs(cPedido,1,GeTSX3Cache("VJQ_ORDGRP","X3_TAMANHO"))
	cOrdNum := Subs(cPedido,GeTSX3Cache("VJQ_ORDGRP","X3_TAMANHO")+1,GeTSX3Cache("VJQ_ORDNUM","X3_TAMANHO"))

	oDlgHist := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0010 , , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

		oWorkA := FWUIWorkArea():New( oDlgHist )
		
		oWorkA:CreateHorizontalBox( "LINE01", 50 ) // -1 para nao estourar 100% da tela ( criando scroll lateral )
		oWorkA:SetBoxCols( "LINE01", { "OBJ1" } )
		oWorkA:CreateHorizontalBox( "LINE02", 50 )
		oWorkA:SetBoxCols( "LINE02", { "OBJ2" } )

		oWorkA:Activate()
	
		cFiltro := "@ VJQ_ORDGRP = '" + cOrdGrp + "' AND VJQ_ORDNUM = '" + cOrdNum + "' AND VJQ_RCRDTP = '1'"

		oBrwVJQ := FwMBrowse():New()
		oBrwVJQ:SetOwner(oWorkA:GetPanel("OBJ1"))
		oBrwVJQ:SetAlias('VJQ')
		oBrwVJQ:SetDescription( STR0011 + " - " + STR0012 + VQ0->VQ0_NUMPED ) // "Histórico de Importação" / "Pedidos "
		oBrwVJQ:SetMenuDef( '' )
		oBrwVJQ:AddFilter( STR0012 + VQ0->VQ0_NUMPED , cFiltro,.t.,.t.,) // "Pedidos "
		oBrwVJQ:DisableLocate()
		oBrwVJQ:DisableDetails()
		oBrwVJQ:SetAmbiente(.F.)
		oBrwVJQ:SetWalkthru(.F.)
		oBrwVJQ:SetInsert(.f.)
		oBrwVJQ:SetUseFilter()
		oBrwVJQ:lOptionReport := .f.
		oBrwVJQ:Activate()

		oFolder :=  tFolder():New(30,0,{ STR0013 , STR0014 , STR0015 , STR0016 , STR0017 },{"G1","G2","G3","G4","G5"},oWorkA:GetPanel("OBJ2"),)
		oFolder:Align := CONTROL_ALIGN_ALLCLIENT

		// Aba 1
		oBrwAba1:= VA1600085_ConfigBrowse("2")

		oBrwVJQ1 := FWmBrowse():New()

		oBrwAba1:SetBrwOwner(oBrwVJQ1)
		oBrwAba1:AddBrwColumn()

		oBrwVJQ1:SetAlias(oBrwAba1:GetAlias())
		oBrwVJQ1:SetOwner(oFolder:aDialogs[1])
		oBrwVJQ1:SetDescription( STR0018 ) // "Dados Importados"
		oBrwVJQ1:SetMenuDef("")
		oBrwVJQ1:DisableLocate()
		oBrwVJQ1:DisableDetails()
		oBrwVJQ1:SetAmbiente(.F.)
		oBrwVJQ1:SetWalkthru(.F.)
		oBrwVJQ1:SetInsert(.f.)
		oBrwVJQ1:SetUseFilter()
		oBrwVJQ1:lOptionReport := .f.
		oBrwVJQ1:SetQueryIndex(oBrwAba1:_aIndex)
		oBrwVJQ1:Activate()

		oRlcVJQ1:= FWBrwRelation():New()
		oRlcVJQ1:AddRelation( oBrwVJQ , oBrwVJQ1 , { { "VJQ_ORDGRP", "VJQ_ORDGRP" }, { "VJQ_ORDNUM", "VJQ_ORDNUM" }, { "VJQ_CODIGO", "VJQ_CODIGO" } })
		oRlcVJQ1:Activate()

		// Aba 2
		oBrwAba2 := VA1600085_ConfigBrowse("3")

		oBrwVJQ2 := FWmBrowse():New()

		oBrwAba2:SetBrwOwner(oBrwVJQ2)
		oBrwAba2:AddBrwColumn()

		oBrwVJQ2:SetAlias(oBrwAba2:GetAlias())
		oBrwVJQ2:SetOwner(oFolder:aDialogs[2])
		oBrwVJQ2:SetDescription( STR0018 )
		oBrwVJQ2:SetMenuDef("")
		oBrwVJQ2:DisableLocate()
		oBrwVJQ2:DisableDetails()
		oBrwVJQ2:SetAmbiente(.F.)
		oBrwVJQ2:SetWalkthru(.F.)
		oBrwVJQ2:SetInsert(.f.)
		oBrwVJQ2:SetUseFilter()
		oBrwVJQ2:lOptionReport := .f.
		oBrwVJQ2:SetQueryIndex(oBrwAba2:_aIndex)
		oBrwVJQ2:Activate()

		oRlcVJQ2:= FWBrwRelation():New()
		oRlcVJQ2:AddRelation( oBrwVJQ , oBrwVJQ2 , { { "VJQ_ORDGRP", "VJQ_ORDGRP" }, { "VJQ_ORDNUM", "VJQ_ORDNUM" }, { "VJQ_CODIGO", "VJQ_CODIGO" } })
		oRlcVJQ2:Activate()

		// Aba 3
		oBrwAba3 := VA1600085_ConfigBrowse("4")

		oBrwVJQ3 := FWmBrowse():New()

		oBrwAba3:SetBrwOwner(oBrwVJQ3)
		oBrwAba3:AddBrwColumn()

		oBrwVJQ3:SetAlias(oBrwAba3:GetAlias())
		oBrwVJQ3:SetOwner(oFolder:aDialogs[3])
		oBrwVJQ3:SetDescription( STR0018 )
		oBrwVJQ3:SetMenuDef("")
		oBrwVJQ3:DisableLocate()
		oBrwVJQ3:DisableDetails()
		oBrwVJQ3:SetAmbiente(.F.)
		oBrwVJQ3:SetWalkthru(.F.)
		oBrwVJQ3:SetInsert(.f.)
		oBrwVJQ3:SetUseFilter()
		oBrwVJQ3:lOptionReport := .f.
		oBrwVJQ3:SetQueryIndex(oBrwAba2:_aIndex)
		oBrwVJQ3:Activate()

		oRlcVJQ3:= FWBrwRelation():New()
		oRlcVJQ3:AddRelation( oBrwVJQ , oBrwVJQ3 , { { "VJQ_ORDGRP", "VJQ_ORDGRP" }, { "VJQ_ORDNUM", "VJQ_ORDNUM" }, { "VJQ_CODIGO", "VJQ_CODIGO" } })
		oRlcVJQ3:Activate()

		// Aba 4
		oBrwAba4 := VA1600085_ConfigBrowse("5")

		oBrwVJQ4 := FWmBrowse():New()

		oBrwAba4:SetBrwOwner(oBrwVJQ4)
		oBrwAba4:AddBrwColumn()

		oBrwVJQ4:SetAlias(oBrwAba4:GetAlias())
		oBrwVJQ4:SetOwner(oFolder:aDialogs[4])
		oBrwVJQ4:SetDescription( STR0018 )
		oBrwVJQ4:SetMenuDef("")
		oBrwVJQ4:DisableLocate()
		oBrwVJQ4:DisableDetails()
		oBrwVJQ4:SetAmbiente(.F.)
		oBrwVJQ4:SetWalkthru(.F.)
		oBrwVJQ4:SetInsert(.f.)
		oBrwVJQ4:SetUseFilter()
		oBrwVJQ4:lOptionReport := .f.
		oBrwVJQ4:SetQueryIndex(oBrwAba4:_aIndex)
		oBrwVJQ4:Activate()

		oRlcVJQ4:= FWBrwRelation():New()
		oRlcVJQ4:AddRelation( oBrwVJQ , oBrwVJQ4 , { { "VJQ_ORDGRP", "VJQ_ORDGRP" }, { "VJQ_ORDNUM", "VJQ_ORDNUM" }, { "VJQ_CODIGO", "VJQ_CODIGO" } })
		oRlcVJQ4:Activate()

		// Aba 5
		oBrwAba5 := VA1600085_ConfigBrowse("6")

		oBrwVJQ5 := FWmBrowse():New()

		oBrwAba5:SetBrwOwner(oBrwVJQ5)
		oBrwAba5:AddBrwColumn()

		oBrwVJQ5:SetAlias(oBrwAba5:GetAlias())
		oBrwVJQ5:SetOwner(oFolder:aDialogs[5])
		oBrwVJQ5:SetDescription( STR0018 )
		oBrwVJQ5:SetMenuDef("")
		oBrwVJQ5:DisableLocate()
		oBrwVJQ5:DisableDetails()
		oBrwVJQ5:SetAmbiente(.F.)
		oBrwVJQ5:SetWalkthru(.F.)
		oBrwVJQ5:SetInsert(.f.)
		oBrwVJQ5:SetUseFilter()
		oBrwVJQ5:lOptionReport := .f.
		oBrwVJQ5:SetQueryIndex(oBrwAba5:_aIndex)
		oBrwVJQ5:Activate()

		oRlcVJQ5:= FWBrwRelation():New()
		oRlcVJQ5:AddRelation( oBrwVJQ , oBrwVJQ5 , { { "VJQ_ORDGRP", "VJQ_ORDGRP" }, { "VJQ_ORDNUM", "VJQ_ORDNUM" }, { "VJQ_CODIGO", "VJQ_CODIGO" } })
		oRlcVJQ5:Activate()

	oDlgHist:Activate( , , , , , , ) //ativa a janela

	oBrwAba1:DelTrabTmp()
	oBrwAba2:DelTrabTmp()
	oBrwAba3:DelTrabTmp()
	oBrwAba4:DelTrabTmp()
	oBrwAba5:DelTrabTmp()

Return .T.

/*/{Protheus.doc} VEIA160

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1600075_MarcaVisto()

Local ni := 0

	For ni := 1 to len(aRegSel)
		VJR->(DbSeek(xFilial("VJR")+aRegSel[ni,1]))
		RecLock("VJR",.f.)
			VJR->VJR_DATVIS := dDataBase
		MsUnLock()
	Next

Return .T.

/*/{Protheus.doc} VEIA160

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1600085_ConfigBrowse(cTipo)
	Local cCampos := ""
	Local cCpoMostra := ""
	Local oBrwAba
	
	cCpoMostra := "VJQ_FILIAL|"
	cCpoMostra += "VJQ_CODIGO|"
	cCpoMostra += "VJQ_SEQUEN|"
	cCpoMostra += "VJQ_NTWCOD|"
	cCpoMostra += "VJQ_RCRDTP|"
	cCpoMostra += "VJQ_ORDGRP|"
	cCpoMostra += "VJQ_ORDNUM|"

	If cTipo == "2"
		cCpoMostra += "VJQ_SHIPAC|"
		cCpoMostra += "VJQ_ORDCOS|"
		cCpoMostra += "VJQ_ORDLIS|"
		cCpoMostra += "VJQ_ORDCOD|"
		cCpoMostra += "VJQ_ORDTP|"
		cCpoMostra += "VJQ_MODNUM|"
		cCpoMostra += "VJQ_MODSUF|"
		cCpoMostra += "VJQ_ATTQNT|"
		cCpoMostra += "VJQ_ORDDES|"
		cCpoMostra += "VJQ_PCITPE|"
		cCpoMostra += "VJQ_EFFDAT|"
		cCpoMostra += "VJQ_CGCODE"
	ElseIf cTipo == "3"
		cCpoMostra += "VJQ_SHIPAC|"
		cCpoMostra += "VJQ_SOLDAC|"
		cCpoMostra += "VJQ_ORDCOD|"
		cCpoMostra += "VJQ_DESMOD|"
		cCpoMostra += "VJQ_MAKE"
	ElseIf cTipo == "4"
		cCpoMostra += "VJQ_QUOTNR|"
		cCpoMostra += "VJQ_QUOTST|"
		cCpoMostra += "VJQ_EVNTID|"
		cCpoMostra += "VJQ_CCGDAT|"
		cCpoMostra += "VJQ_FACTDT|"
		cCpoMostra += "VJQ_RQDLDT|"
		cCpoMostra += "VJQ_SHIPDT|"
		cCpoMostra += "VJQ_ENTDAT"
	ElseIf cTipo == "5"
		cCpoMostra += "VJQ_PRODUC"
	ElseIf cTipo == "6"
		cCpoMostra += "VJQ_CCGNAM|"
		cCpoMostra += "VJQ_DLVDAT|"
		cCpoMostra += "VJQ_RTLDAT|"
		cCpoMostra += "VJQ_ORDTYP|"
		cCpoMostra += "VJQ_ORDTOT|"
		cCpoMostra += "VJQ_ORDFRT|"
		cCpoMostra += "VJQ_ORDCOM|"
		cCpoMostra += "VJQ_ORDTAX"
	EndIf

	oBrwAba := OFBrowseStruct():New({"VJQ"})

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("VJQ")
	While !Eof() .And. (x3_arquivo == "VJQ")
		If X3USO(x3_usado) .and. x3_campo $ cCpoMostra
			oBrwAba:AddField( x3_campo )
			If Empty(cCampos)
				cCampos += x3_campo
			Else
				cCampos += "," + x3_campo
			EndIf
		EndIf
		dbSkip()
	EndDo

	oBrwAba:AddIndex( "VJQ_CODIGO+VJQ_SEQUEN+VJQ_ORDNUM" )
	oBrwAba:CriaTabTmp()
	oBrwAba:LoadData( VA1600015_Query(cCampos,cTipo) )

Return oBrwAba

/*/{Protheus.doc} VEIA160

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1600095_ColBMark()
	Local lRet := 'LBNO'
	
	If aScan(aRegSel,{|x| x[1] == VQ0->VQ0_CODIGO }) > 0
		lRet := 'LBOK'
	EndIf
	
Return lRet

/*/{Protheus.doc} VEIA160

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1600105_LimpaHistorico()

	Local cString := ""
	Local aParamBox := {}
	Local aRet := {}
	Local MV_PAR01 := StoD("")

	aAdd(aParamBox,{1, STR0019 , MV_PAR01 , "@D" , "MV_PAR01 < dDataBase" ,"","",50,.f.})
	If ParamBox(aParamBox, STR0020 ,@aRet,,,,,,,,.F.,.F.)
		cString := "DELETE FROM " + RetSqlName("VJQ") + " WHERE VJQ_FILIAL = '" + xFilial("VJQ") + "' AND VJQ_DATIMP <= '" + DtoS(aRet[1]) + "' "
		TCSqlExec(cString)
		MsgInfo( STR0021 )
	EndIf

Return

/*/{Protheus.doc} VA160011A_CallDTF

@author Jose Silveira
@since 30/09/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA160011A_CallDTF()

	Private oDTFConfig := OFJDDTFConfig():New()
	Private oRetAPiG := OFJDDTF():New("GET")
	
	oDTFConfig:GetConfig()

	oRetAPiG:getDTFList_Service("RECEIPTS_",oDTFConfig:getCGPoll())

	MsgInfo( STR0023 )

Return
