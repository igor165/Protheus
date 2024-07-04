#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSA502.CH' 
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA502
Documentos excluídos
@type function
@author Marcelo Radulski Nunes.
@version 12.1.28
@since 20/08/2019
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA502()
Local oMBrowse := Nil
Private aRotina:= MenuDef()	
	oMBrowse:= FwMBrowse():New()
	oMBrowse:SetAlias('DLW')
	oMBrowse:SetDescription(STR0001)
    oMBrowse:SetFilterDefault( "@DLW_MOSTRA = '1' " )  //Categoria Composicao
	oMBrowse:Activate()
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados 
@type function
@author Marcelo Radulski Nunes.
@version 12.1.28
@since 20/08/2019
/*/
//-------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel:= Nil
Local oStructDLW:= FwFormStruct( 1, 'DLW',,)
	oModel:= MpFormModel():New( 'TMSA502', /*bPre*/,/*bPost*/,, /*bCancel*/ )
	oModel:SetDescription( STR0001 )
	oModel:AddFields('MASTER_DLW', Nil, oStructDLW)                                
	oModel:SetPrimaryKey({'DLW_FILIAL','DLW_DOC','DLW_SERIE'})
Return(oModel)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Estrutura de dados 
@type function
@author Marcelo Radulski Nunes.
@version 12.1.28
@since 20/08/2019
/*/
//-------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView    := Nil
Local oModel   := FwLoadModel('TMSA502')
Local oStructDLW:= FwFormStruct( 2, 'DLW' )
	oView:= FwFormView():New()
	oView:SetModel( oModel )
	oView:CreateHorizontalBox( 'TELA' , 65 )	
	oView:CreateHorizontalBox( 'GRIDS' , 35 )

	oView:CreateFolder( "FOLDER", "GRIDS" )
	oView:AddSheet( "FOLDER", "TSHEET1", STR0002)//Composição do frete
	oView:CreateHorizontalBox( 'BOX1', 100, , , 'FOLDER', 'TSHEET1')
	oView:AddSheet( "FOLDER", "TSHEET2", STR0003 )//Livros Fiscais
	oView:CreateHorizontalBox( 'BOX2', 100, , , 'FOLDER', 'TSHEET2')

	oView:AddOtherObject( "OTHER1", { |oPanel| TM502BRWCF(oPanel)} )	
	oView:SetOwnerView( 'OTHER1' , 'BOX1'  )	

	oView:AddOtherObject( "OTHER2", { |oPanel| TM502BRWFI(oPanel)} )	
	oView:SetOwnerView( 'OTHER2' , 'BOX2'  )	

	oView:AddField('VIEW_DLW',oStructDLW, 'MASTER_DLW')
	oView:SetOwnerView('VIEW_DLW', 'TELA')
	oView:SetCloseOnOk({|| .T. })

	oStructDLW:RemoveField( 'DLW_MOSTRA' )
Return( oView)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu 
@type function
@author Marcelo Radulski Nunes.
@version 12.1.28
@since 20/08/2019
/*/
//-------------------------------------------------------------------------------------------------
Static Function Menudef()
Local aRotina := {}	    
	aAdd(aRotina, {STR0004, 'VIEWDEF.TMSA502', 0, 2, 0, NIL}) //Visualizar	
	aAdd(aRotina, {STR0005, 'AxPesqui', 0, 1, 0, .F.}) //Visualizar		
Return aRotina


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM502BRWFI
Monta browse Livros Fiscais, utilizando função padrão : MaFisBrwLivro. 
@type function
@author Marcelo Radulski Nunes.
@version 12.1.28
@since 20/08/2019
/*/
//-------------------------------------------------------------------------------------------------
Function TM502BRWFI(oPanel)
Local oGRDFiscal
Local aRecSF3   := {}
	SF3->(DbSetOrder(4))
	If SF3->(DbSeek(XFilial('SF3')+DLW->DLW_CLIDEV+DLW->DLW_LOJDEV+DLW->DLW_DOC+DLW->DLW_SERIE))	
    	AADD(aRecSF3,SF3->(RecNo()))	
	EndIf	
	oGRDFiscal := MaFisBrwLivro(oPanel,{005,001,310,60},.T.,aRecSF3,.T.)
	oGRDFiscal:Align := CONTROL_ALIGN_ALLCLIENT	
Return oGRDFiscal

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM502BRWCF
Monta browse de composição de frete
@type function
@author Marcelo Radulski Nunes.
@version 12.1.28
@since 21/08/2019
/*/
//-------------------------------------------------------------------------------------------------
Function TM502BRWCF(oPanel)
Local oBrwComFre
Local aHeadComfr := {}
Local aItensComf := {}
	aHeadComfr := {STR0006,STR0007,STR0008,STR0009,STR0010}//#Composicao #Valor #Imposto #Valor + Imposto #Rateio
	oBrwComFre:= TWBrowse():New( 005,001,310,60,,aHeadComfr,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	aItensComf := TM502ARRCF()
	If Empty(aItensComf)
		aItensComf := {{'','','','',''}}
	EndIf	
    oBrwComFre:SetArray(aItensComf) 
	oBrwComFre:bLine := {||{aItensComf[oBrwComFre:nAt,01], aItensComf[oBrwComFre:nAt,02],aItensComf[oBrwComFre:nAt,03],aItensComf[oBrwComFre:nAt,04],aItensComf[oBrwComFre:nAt,05] } } 
	oBrwComFre:Align := CONTROL_ALIGN_ALLCLIENT	
Return oBrwComFre

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM502ARRCF
Monta array de composição de frete
@type function
@author Marcelo Radulski Nunes.
@version 12.1.28
@since 21/08/2019
/*/
//-------------------------------------------------------------------------------------------------
Function TM502ARRCF()
Local aItensComf := {}
Local cDscComp := ''
	DLX->(DbSetOrder(1)) 
	DLX->(MsSeek(cSeek := xFilial('DLX') + DLW->DLW_FILDOC + DLW->DLW_DOC + DLW->DLW_SERIE))
	bWhile := {|| DLX->( ! Eof() .And. DLX->DLX_FILIAL + DLX->DLX_FILDOC + DLX->DLX_DOC + DLX->DLX_SERIE == cSeek ) }
	While Eval( bWhile )
		If	DLX->DLX_CODPAS == 'TF'
			cDscComp := STR0011 //"Total do Frete"
		Else
			cDscComp := Posicione('DT3', 1, xFilial('DT3') + DLX->DLX_CODPAS, 'DT3_DESCRI')
		EndIf
		
		AAdd(aItensComf,{cDscComp,;
						TransForm( DLX->DLX_VALPAS, PesqPict('DLX','DLX_VALPAS') ),;
						TransForm( DLX->DLX_VALIMP, PesqPict('DLX','DLX_VALIMP') ),;
						TransForm( DLX->DLX_VALTOT, PesqPict('DLX','DLX_VALTOT') ),;
						TransForm( DLX->DLX_PERRAT, PesqPict('DLX','DLX_PERRAT') )};
			)

		DLX->(DbSkip())
	EndDo
Return aItensComf