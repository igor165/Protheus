#INCLUDE "AGRA601.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} AGRA601A
//TODO Descrição auto-gerada.
@author bruna.rocio
@since 27/04/2016
@version undefined

@type function
/*/
Function AGRA601A()

Return .T.

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna o modelo de visualização da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 08/11/2012
@Uso: AGRA601
/*/
//-----------------------------------------------------------
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( 'AGRA601' )
	Local oStruDXL 
	Local cVisualOP	:= ""

	Pergunte('AGRA60102', .F.)
	cVisualOP := MV_PAR01       
		
	if !IsIncallStack("AGR601ALT")
		oStruDXL := FwFormStruct( 2, 'DXL', {|cCampo| !(cCampo $ 'DXL_STATUS|DXL_OK')} )
	else
		oStruDXL := FwFormStruct( 2, 'DXL')
		oStruDXL:SetProperty( '*' ,MVC_VIEW_CANCHANGE, .t.)	
	endif
	oView := FwFormView():New()

	oView:SetModel( oModel )

	oView:AddField( 'VIEW_DXL', oStruDXL, 'DXLMASTER' )
	
	If .Not. ExistBlock('AGR601P1')
		//--Caso o parametro "MV_AGRPRFA" estiver como .T. habilita os campos LOTE - SUBLOTE e 
		//--- habilita o campo virtual de OP == somente quando a opção do F12 for OP por Fardão = 1-Sim
		If SuperGetMV("MV_AGRPRFA",.F.,.F.)  .And. (cVisualOP = 1 )
			//--Campo virtual de OP
			oStruDXL:AddField(/*cIdField*/"DXL_OP",;
							  /*cOrdem*/'40',;
							  /*cTitulo*/STR0053,;
							  /*cDescric*/STR0052,;
							  /*aHelp*/,;
							  /*cType*/"Get",;
							  /*cPicture*/"@!",;
							  /*bPictVar*/,;
							  /*cLookUp*/'SC2',;
							  /*lCanChange*/.T.,;
							  /*cFolder*/,;
							  /*cGroup*/,;
							  /*aComboValues*/ ,;
							  /*nMaxLenCombo*/,;
							  /*cIniBrow*/,;
							  /*lVirtual*/.T.,;
							  /*cPictVar*/,;
							  /*lInsertLine*/.F.,;
							  /*nWidth*/)
		EndIf
	EndIf
		
	oView:CreateHorizontalBox( 'TOTAL', 100 )

	oView:SetOwnerView( 'VIEW_DXL', 'TOTAL' )

Return oView
