#INCLUDE "UBAA130.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

Static __SXBCdN80


/*/{Protheus.doc} UBAA130
//Tela especifica de Regras de Emblocamento
@author carlos.augusto
@since 29/10/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function UBAA130()
	Local oMBrowse	:= Nil
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N80" )
	oMBrowse:SetMenuDef( "UBAA130" )
	oMBrowse:SetFilterDefault(" N80_TIPEMB == '1' .And. N80_ATIVO == '1'")
	oMBrowse:SetDescription( STR0001 ) //"Gerar Regra de Emblocamento Específico"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
Return( Nil )


/*/{Protheus.doc} MenuDef
@author carlos.augusto
@since 29/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()
	Local aRotina 	:= {}

	aAdd( aRotina, { STR0003   , "ViewDef.UBAA130"			, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004   , "ViewDef.UBAA130"			, 0, 9, 0, Nil } ) //"Copiar"
	aAdd( aRotina, { STR0007   , "ViewDef.UBAA130"			, 0, 5, 0, Nil } ) //"Excluir"
	
Return( aRotina )


/*/{Protheus.doc} ModelDef
@author carlos.augusto
@since 29/10/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ModelDef()
	Local oModel := FwLoadModel("UBAA060") 
Return( oModel )


/*/{Protheus.doc} ViewDef
@author carlos.augusto
@since 29/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()
	Local oView		:= FWLoadView('UBAA060')
Return( oView )



/*/{Protheus.doc} UBAA130SXB
@author carlos.augusto
@since 29/10/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function UBAA130SXB()
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oPnDown   := Nil
	Local oSize     := Nil
	Local oMBrowse	:= Nil
	Private _lRet 	    := .f.
	
	__SXBCdN80 := ""
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3] *0.8, oSize:aWindSize[4]*0.8, STR0005, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Regras de Emblocamento Específico"

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	oFWLayer:AddLine( 'UP', 10, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )

	oFWLayer:AddLine( 'DOWN', 90, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'DOWN' )
	
	oPnDown := TPanel():New( oSize:GetDimension("ALL","LININI"), oSize:GetDimension("ALL","COLINI"), ,oDlg, , , , , ,oSize:GetDimension("ALL","COLEND")/1.26, oSize:GetDimension("ALL","LINEND") * 0.62)

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N80" )
	oMBrowse:SetMenuDef( "UBAA130" )
	oMBrowse:SetOnlyFields( { 'N80_FILIAL', 'N80_CODIGO', 'N80_NMEMBL','N80_TPCLAS' } )
	oMBrowse:SetDescription(STR0006) //"Selecionar Regra Específica de Emblocamento"
	oMBrowse:SetFilterDefault(" (N80_TIPEMB == '1' .Or. N80_TIPEMB == '3') .And. N80_ATIVO == '1'")
	oMBrowse:DisableDetails()
	oMBrowse:SetExecuteDef(99)
	oMBrowse:SetDoubleClick( {|| __SXBCdN80 := N80->N80_CODIGO, oDlg:End() })
	oMBrowse:Activate(oPnDown)
		
	oDlg:Activate( , , , .t., { || .t.,  }, , { || EnchoiceBar(oDlg,{|| _lRet := .t. ,oDlg:End()},{||  oDlg:End() },,/* @aButtons */,,,.f.,.f.,.f.,.t.,.f.) } )
	 
	if _lRet
		__SXBCdN80 := N80->N80_CODIGO
	endif 
	
	RestArea(aArea)
 
return .t.


/*/{Protheus.doc} UBAA130RET
@author carlos.augusto
@since 29/10/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function UBAA130RET()
	Local lRetorno  := ""
	lRetorno := __SXBCdN80
return lRetorno       

                                                                                                                                                                                                                                   