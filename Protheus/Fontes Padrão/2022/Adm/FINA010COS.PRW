#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'FINA010.ch'

#DEFINE SOURCEFATHER "FINA010"

Static lFWCodFil := .T.

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA010COS
Cadastro de Natureza localizado para COSTA RICA.

O fonte contém browse, menu, model e view propria, todos herdados do FINA010. 
Qualquer regra que se aplique somente para o COSTA RICA deve ser definida aqui.

As validações e integrações realizadas após/durante a gravação estão definidas nos eventos do modelo, 
na classe FINA010EVCOS.

@type function
@author Rodrigo Oliveira
@since 18/05/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Function FINA010COS() 
Local oBrowse		As Object 
PRIVATE cCadastro 	As Character

	oBrowse		 := BrowseDef()
	cCadastro	 := OemToAnsi(STR0006) //"Atualiza‡„o de Naturezas"
	oBrowse:Activate()
	
Return
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Define o browse padrão para o cadastro de natureza.

@type function
 
@author Rodrigo Oliveira
@since 01/06/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function BrowseDef() As Object 
Local oBrowse 	As Object 

	oBrowse:= FwLoadBrw(SOURCEFATHER)

Return oBrowse	
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o model padrão para o cadastro de natureza.

@type function
 
@author Rodrigo Oliveira
@since 01/06/2017
@version P12.1.17 
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef() As Object 
Local oModel 	As Object 
Local oStrFRN	As Object
Local bValidIMP	As Block 
Local bValInIMP	As Block 
Local bValidSEQ	As Block 
Local bValInSEQ	As Block 
Local bValWhSEQ	As Block 
Local bVlWhISEQ	As Block 

	oModel	  := FWLoadModel(SOURCEFATHER)
	
	//Instancia o objeto FINA010EVCOS	
	oEvent  := FINA010EVCOS():New(oModel)

	oStrFRN	  := FWFormStruct(1,"FRN")
	bValidIMP := FWBuildFeature( STRUCT_FEATURE_VALID, "StaticCall(FINA010COS,VLDFRNCpos,1)" )
	bValInIMP := FWBuildFeature( STRUCT_FEATURE_VALID, "StaticCall(FINA010COS,VLDFRNCpos,2)" )
	bValidSEQ := FWBuildFeature( STRUCT_FEATURE_VALID, "StaticCall(FINA010COS,VLDFRNCpos,3)" )
	bValInSEQ := FWBuildFeature( STRUCT_FEATURE_VALID, "StaticCall(FINA010COS,VLDFRNCpos,4)" )
	bValWhSEQ := FWBuildFeature( STRUCT_FEATURE_WHEN , "StaticCall(FINA010COS,VLDFRNCpos,5)" )
	bVlWhISEQ := FWBuildFeature( STRUCT_FEATURE_WHEN , "StaticCall(FINA010COS,VLDFRNCpos,6)" )	
	oStrFRN:SetProperty('FRN_IMPOST'	,MODEL_FIELD_VALID,bValidIMP)
	oStrFRN:SetProperty('FRN_INCIMP'	,MODEL_FIELD_VALID,bValInIMP)
	oStrFRN:SetProperty('FRN_SEQ'		,MODEL_FIELD_VALID,bValidSEQ)
	oStrFRN:SetProperty('FRN_INCSEQ'	,MODEL_FIELD_VALID,bValInSEQ)
	oStrFRN:SetProperty('FRN_SEQ'		,MODEL_FIELD_WHEN ,bValWhSEQ)
	oStrFRN:SetProperty('FRN_INCSEQ'	,MODEL_FIELD_WHEN ,bVlWhISEQ)
	oStrFRN:SetProperty( 'FRN_CODNAT'	, MODEL_FIELD_OBRIGAT, .F.)
		
	oModel:AddGrid('FRNDETAIL','SEDMASTER',oStrFRN)
	oModel:SetRelation( 'FRNDETAIL', { { 'FRN_FILIAL', 'xFilial( "FRN" )' }, { 'FRN_CODNAT', 'ED_CODIGO' } }, FRN->( IndexKey( 1 ) ) )
	
	//Preenchimento da grid opscional
	oModel:GetModel( 'FRNDETAIL' ):SetOptional( .T. )

	//Instalação do evento FINA010EVCOS
	oModel:InstallEvent("COSTARICA",,oEvent)
	
Return oModel
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view padrão para o cadastro de natureza.

@type function
 
@author Rodrigo Oliveira
@since 01/06/2017
@version P12.1.17 
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ViewDef() As Object
Local oView 	As Object
Local oStruFRN 	As Object

	oView	 := FWLoadView(SOURCEFATHER)
	oStruFRN := FWFormStruct( 2, 'FRN', { |cCampo| cCampo != 'FRN_CODNAT' } )

	oView:AddGrid( 'VIEW_FRN', oStruFRN, 'FRNDETAIL' )
	oView:CreateHorizontalBox( 'SUPERIOR', 65, 'BOXMAIN' )
	oView:CreateHorizontalBox( 'INFERIOR', 35, 'BOXMAIN' )

	oView:SetOwnerView( 'SEDMASTER', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_FRN', 'INFERIOR' )

	oView:EnableTitleView('VIEW_FRN', STR0055 ) 
	
	oStruFRN:SetProperty( 'FRN_SEQ' , MVC_VIEW_LOOKUP, "FRMSQ1")

Return oView
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define o menu padrão para o cadastro de natureza.

@type function
 
@author Rodrigo Oliveira
@since 01/06/2017
@version P12.1.17 
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MenuDef() As Object
Local aRotina As Array
	
	aRotina := FWLoadMenuDef(SOURCEFATHER)

Return aRotina
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VLDFRNCpos
Rotina responsavel por validar os campos da FRN

@type Function
@author jose.aribeiro
@since 30/05/2017
@version 12.1.17
@param nCampo, numerico, Informa qual o numero do campo que esta sendo verificado
@return lRet, Logico, Retorna .T. para validado e .F. para nao validado
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function VLDFRNCpos(nCampo) As Logical
Local oModel	 As Object
Local oModelFRN	 As Object
Local oModelSED	 As Object
Local lRet		 As Logical

	oModel		 := FwModelActivate()
	oModelFRN	 := oModel:GetModel("FRNDETAIL")
	oModelSED	 := oModel:GetModel("SEDMASTER")
	lRet		 := .T.
	DbSelectArea("FRM")
	FRM->(DbSetOrder(2))
	If(nCampo == 1 .Or. nCampo == 2)
		If((nCampo == 1 .And. FRM->(MsSeek(xFilial("FRM") + oModelFRN:GetValue("FRN_IMPOST")))) .Or.;
		   (nCampo == 2 .And. FRM->(DbSeek(xFilial("FRM") + oModelFRN:GetValue("FRN_INCIMP")))))
			If(FRM->FRM_MSBLQL <> "1")
				If!((oModelSED:GetValue("ED_USO") $ "24" .And. FRM->FRM_CARTEI $ "13") .OR. (oModelSED:GetValue("ED_USO") $ "13" .and. FRM->FRM_CARTEI $ "23"))

					HELP(' ',1,"HELP" ,STR0041,STR0044,1,0)
					lRet:= .F.

				EndIf
			Else

				HELP(' ',1,"HELP" ,STR0027,STR0045,1,0)
				lRet:= .F.

			EndIf
		Else

			HELP(' ',1,"REGNOIS" )
			lRet:= .F.

		EndIf
	ElseIf(nCampo == 3 .Or. nCampo == 4)
		If!((nCampo == 3 .And. FRM->(DbSeek(xFilial("FRM") + oModelFRN:GetValue("FRN_IMPOST") + oModelFRN:GetValue("FRN_SEQ")))) .Or.;
			(nCampo == 4 .And. FRM->(DbSeek(xFilial("FRM") +  oModelFRN:GetValue("FRN_INCIMP") + oModelFRN:GetValue("FRN_SEQ")))))

			HELP(" " , 1 , "REGNOIS")	
		
		Else
			If!(FRM->FRM_MSBLQL <> "1" .And. FRM->FRM_BLOQ <> "1")

				Help(" ",1,"HELP",STR0027,STR0049,1,0)
			
			Else
				If!(oModelSED:GetValue("ED_USO") $ "24" .And. FRM->FRM_CARTEI $ "13") .OR. (oModelSED:GetValue("ED_USO") $ "13" .And. FRM->FRM_CARTEI $ "23")

					Help(" ",1,"HELP",STR0041,STR0048,1,0)

				Else	
					If(FRM->FRM_FIMVIG < dDataBase)

						Help(" ",1,"HELP",STR0046,STR0047,1,0)

					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet
