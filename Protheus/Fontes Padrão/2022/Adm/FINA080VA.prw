#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWEDITPANEL.CH'
#Include 'FINA080VA.CH'

Static __lAutoVA := .F.

/*/{Protheus.doc}ViewDef
Detalhamento dos valores acessórios.
@author William Matos
@since  20/08/2015
@version 12
/*/
Function FINA080VA()

Local aEnableButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Local nOK				:= 0
Local oModelVA			:= Nil

If !ValType(cOldVA) == 'U' .AND. !Empty(cOldVA)
	oModelVA := FWLoadModel("FINA080VA")
	oModelVA:SetOperation( MODEL_OPERATION_UPDATE )
	oModelVA:Activate()
	oModelVA:LoadXMLData( cOldVA )
	nOK := FWExecView( STR0001/*Alteração*/,"FINA080VA", MODEL_OPERATION_UPDATE,/**/,/**/,/**/,55,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/, oModelVA )
Else
	nOK := FWExecView( STR0001/*Alteração*/,"FINA080VA", MODEL_OPERATION_UPDATE,/**/,/**/,/**/,55,aEnableButtons)
EndIf

Return nOK

/*/{Protheus.doc}ViewDef
Interface.
@author William Matos
@since  19/08/2015
@version 12
/*/
Static Function ViewDef()

Local oView  		:= FWFormView():New()
Local oModel 		:= FWLoadModel("FINA080VA")
Local oFK7	 		:= FWFormStruct(2,'FK7')
Local oSE2	 		:= FWFormStruct(2,'SE2', { |x| ALLTRIM(x) $ 'E2_NUM, E2_PARCELA, E2_PREFIXO, E2_TIPO, E2_FORNECE, E2_LOJA,E2_NATUREZ, E2_EMISSAO, E2_VENCREA, E2_SALDO, E2_VALOR' } )
Local oFKD	 		:= FWFormStruct(2,'FKD', { |x| ALLTRIM(x) $ 'FKD_CODIGO, FKD_DESC, FKD_TPVAL,FKD_VALOR,FKD_VLCALC,FKD_VLINFO' })

oFKD:SetProperty('*',          MVC_VIEW_CANCHANGE, .F.)
oFKD:SetProperty('FKD_VLINFO', MVC_VIEW_CANCHANGE, .T.)
//
oView:SetModel( oModel )
oView:AddField("VIEWSE2",oSE2,"SE2MASTER")
oView:AddGrid("VIEWFKD",oFKD,"FKDDETAIL")
//
oView:SetViewProperty("VIEWSE2","SETLAYOUT",{FF_LAYOUT_HORZ_DESCR_TOP ,1})
//
oView:CreateHorizontalBox( 'BOXSE2', 35 )
oView:CreateHorizontalBox( 'BOXFKD', 65 )
//
oView:SetOwnerView('VIEWSE2', 'BOXSE2')
oView:SetOwnerView('VIEWFKD', 'BOXFKD')
//
oView:ShowUpdateMsg(.F.)
oView:EnableTitleView('VIEWSE2' , STR0002 /*'Contas a Pagar'*/ )
oView:EnableTitleView('VIEWFKD' , STR0003 /*'Valores Acessórios'*/ )
oView:SetOnlyView( 'VIEWSE2' )

Return oView

/*/{Protheus.doc}ModelDef
Modelo de dados.
@author William Matos
@since  19/08/2015
@version 12
/*/
Static Function ModelDef()

Local oModel 	:= MPFormModel():New('FINA080VA',/*Pre*/,/*Pos*/,{|| FN080VAGrv()}/*Commit*/)
Local oSE2	 	:= FWFormStruct(1, 'SE2')
Local oFKD		:= FWFormStruct(1, 'FKD')
Local oFK7		:= FWFormStruct(1, 'FK7')
Local aAuxFK7	:= {}
Local aAuxFKD	:= {}
Local bInitDesc := FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_DESC"),"")')
Local bInitVal  := FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_TPVAL"),"")')

oSE2:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)

oFKD:AddTrigger( "FKD_CODIGO", "FKD_TPVAL",  {|| .T. }, {|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_TPVAL")})
oFKD:AddTrigger( "FKD_CODIGO", "FKD_DESC",   {|| .T. }, {|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_DESC")})
oFKD:AddTrigger( "FKD_CODIGO", "FKD_PERIOD", {|| .T. }, {|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_PERIOD")})

oFK7:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
oFKD:SetProperty('FKD_DESC' ,  MODEL_FIELD_INIT, bInitDesc )
oFKD:SetProperty('FKD_TPVAL',  MODEL_FIELD_INIT, bInitVal  )

//
oModel:AddFields("SE2MASTER",/*cOwner*/	, oSE2)
oModel:AddGrid("FK7DETAIL","SE2MASTER"  , oFK7)
oModel:AddGrid("FKDDETAIL","SE2MASTER" , oFKD)
//
oModel:SetPrimaryKey({'E2_FILIAL','E2_PREFIXO','E2_NUM','E2_PARCELA','E2_TIPO','E2_FORNECE','E2_LOJA'})
//
oModel:GetModel( 'FKDDETAIL' ):SetUniqueLine( { 'FKD_CODIGO' } )
aAdd( aAuxFK7, {"FK7_FILIAL","xFilial('FK7')"} )
aAdd( aAuxFK7, {"FK7_ALIAS","'SE2'"})
aAdd( aAuxFK7, {"FK7_CHAVE","E2_FILIAL + '|' + E2_PREFIXO + '|' + E2_NUM + '|' + E2_PARCELA + '|' + E2_TIPO + '|' + E2_FORNECE + '|' + E2_LOJA"})
oModel:SetRelation("FK7DETAIL", aAuxFK7 , FK7->(IndexKey(2) ) )
//
aAdd(aAuxFKD, {"FKD_FILIAL", "xFilial('FKD')"})
aAdd(aAuxFKD, {"FKD_IDDOC", "FK7_IDDOC"})
oModel:SetRelation("FKDDETAIL", aAuxFKD , FKD->(IndexKey(1) ) )
//
oModel:GetModel( 'FKDDETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK7DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FK7DETAIL' ):SetOnlyQuery( .T. ) //Gravação é realizada pela função FINGRVFK7
oModel:GetModel( 'SE2MASTER' ):SetOnlyQuery( .T. )	// VA

//Se o model for chamado via adapter de baixas.
If FwIsInCallStack("FINI080")
	oModel:GetModel( "FKDDETAIL" ):SetNoInsertLine(.F.)
	oModel:GetModel( "FKDDETAIL" ):SetNoDeleteLine(.T.)
Else
	oModel:GetModel( "FKDDETAIL" ):SetNoInsertLine(.T.)
	oModel:GetModel( "FKDDETAIL" ):SetNoDeleteLine(.T.)
Endif	
oModel:SetActivate( { |oModel| FN080VAInfo(oModel) } )


Return oModel

//-----------------------------------------------------------------------------
/*/{Protheus.doc}FN080VAGrv
Gravação do modelo de dados.
@author William Matos
@since  19/08/2015
@version 12
/*/
//-----------------------------------------------------------------------------
Function FN080VAGrv()

Local oModel := FWModelActive()
Local oAux	 := oModel:GetModel("FKDDETAIL")
Local nX 	 := 0

cOldVA := oModel:GetXMLData(,,,,, .T.)  //GetXMLData( lDetail, nOperation, lXSL, lVirtual, lDeleted, lEmpty, lDefinition, cXMLFile, lPK, lPKEncoded, aFilterFields, lFirstLevel, lInternalID)
nVA := 0
For nX := 1 To oAux:Length()
	nVA += oAux:GetValue("FKD_VLINFO", nX)
Next nX

Return .T.


//-----------------------------------------------------------------------------
/*/{Protheus.doc}FN080VAInfo
Calculo dos VAs no load do Model da Baixa CP
@author  Marcos Gomes
@since   17/09/2018
@version 12
/*/	
//-----------------------------------------------------------------------------
Function FN080VAInfo( oModel )
	Local oSubFKD  := oModel:GetModel("FKDDETAIL")
	Local nTamFKD  := oSubFKD:Length()
	Local nX	   := 0
	Local nVlAces  := 0
	Local lRet	   := .F.
	Local aArea	   := GetArea()
	Local cCodVA   := oSubFKD:GetValue("FKD_CODIGO")
	Local lCanBx   := FwIsInCallStack("FA080CAN")
	Local dDtBaixa := Iif( Type("dBaixa") == "U", dDataBase, dBaixa )
	Local nMoedBco := Iif( Type("nMoedaBco") == "U", 1, nMoedaBco )
	Local nTaxMoed := 1
	
	If Type("nTxMoeda") == "U" 
		If SE2->E2_MOEDA > 1
			nTaxMoed := RecMoeda(dDtBaixa,SE2->E2_MOEDA)
		Endif
	Else
		nTaxMoed := nTxMoeda
	Endif	
	
	cOldVA := Iif( Type("cOldVA") == 'U', "", cOldVA )
	
	If Empty(cOldVa) .And. !lCanBx
	
		dbSelectArea("FKC")
		FKC->( dbSetOrder( 1 ) ) //FKC_FILIAL+FKC_CODIGO
		
		nVA := 0
		For nX := 1 To nTamFKD
		
	 		oSubFKD:GoLine( nX )
	 		cCodVA	:= oSubFKD:GetValue("FKD_CODIGO")
	 		
			If !oSubFKD:IsDeleted() .And. FKC->( MSSeek( FWxFilial("FKC") + cCodVA ) )
				lRet := .T.
				If !__lAutoVA
					nVlAces := FValAcess( SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NATUREZ,/*lBaixados*/, cCodVa, "P", dDTBaixa,/*aValAces*/, SE2->E2_MOEDA, nMoedBco, nTaxMoed )
					oModel:LoadValue( "FKDDETAIL", "FKD_VLCALC", nVlAces )
					oModel:LoadValue( "FKDDETAIL", "FKD_VLINFO", nVlAces )
				Else
					If Empty( oModel:GetValue( "FKDDETAIL", "FKD_DTBAIX" ) ) .Or. oModel:GetValue( "FKDDETAIL", "FKD_PERIOD" ) <> "1" //Se o VA de período único já foi baixado, então não considera novamente no valor de VA da nova baixa
						nVlAces := oModel:GetValue( "FKDDETAIL", "FKD_VLINFO" )
					EndIf
				EndIf
				
				nVA += nVlAces
			EndIf
		Next nX
	EndIf
				
	RestArea( aArea )
Return lRet

