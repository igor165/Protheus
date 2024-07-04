#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWEDITPANEL.CH'
#Include 'FWBrowse.ch'
#Include 'FINA761.ch'

STATIC __cTipoDC := ""
STATIC __cAba761 := ""
STATIC __cPreDOC := "0"
STATIC __lModif	 := .F.

/*/{Protheus.doc} FINA761PDC
Rotina com pré-documento
@author William Matos 
@since 05/01/2015
@version 1.0
/*/
Function FINA761PDC(cAbaAtiva, cTipoDC, cSituacao, oView, oViewPai, lModified)
Local oModel761 	:= oViewPai:GetModel() //FWModelActive()
Local oAuxFV7		:= oModel761:GetModel('DETFV7')
Local lVisual		:= oModel761:GetOperation() == MODEL_OPERATION_VIEW
Local nOper	 		:= MODEL_OPERATION_INSERT
Local oAux		 	:= Nil
Local aNomPre		:= {{'1','OB'},{'3','GRU'},{'4','GPS'},{'6','DAR'},{'7','DARF'}}
Local cDoc			:= ""
Local nPos			:= 0
Local cFV7Fil		:= FWxFilial("FV7")
Local nTipFor		:= GTpForOrg(oModel761:GetModel('CABDI'):GetValue("FV0_FORNEC"),oModel761:GetModel('CABDI'):GetValue("FV0_LOJA"))

If nTipFor == 0
	Help(" ",1,"PREDOCOB",, STR0232 ,3,1) //"Informe um fornecedor/loja para o documento hábil"
//Carrega o pré-documento conforme a situação informada e tipodc
ElseIf cAbaAtiva == 'DETFV6'
	If nTipFor == 1
		__cPreDOC := '1'
	ElseIf nTipFor == 2
		__cPreDOC := '3'
	EndIf
Else
	__cPreDOC := LoadPreDoc(cSituacao)
EndIf

If EMPTY(__cPreDOC) .AND. !EMPTY(cSituacao)
	Help(" ",1,"PREDOCOB",, STR0131 + cSituacao + " - " + FVJ->FVJ_DESCRI + CRLF + STR0132 + CRLF + STR0133 ,3,1) //"Situação: "#" com Pré-doc do tipo OB."#"Efetuar preenchimento do pré-doc na aba de Dados de Pagamento." 
ElseIf !EMPTY(__cPreDOC) 
	//
	If (nPos := aScan( aNomPre, { |x| AllTrim( x[1] ) ==  AllTrim( __cPreDOC ) } ) )   > 0
		cDoc := aNomPre[nPos][2]
	EndIf
	//
	__cTipoDC := cTipoDC
	__cAba761 := cAbaAtiva
	__lModif	:= lModified
		
	dbSelectArea('FV7')
	If cAbaAtiva == 'DETFV6'
		oAux := oModel761:GetModel("DADOPAGFAV")
	Else
		oAux := oModel761:GetModel(cAbaAtiva)
	EndIf
	
	Do Case
	
		Case cAbaAtiva == 'DETFVB'
	
			If !oAuxFV7:IsEmpty() .AND. oAuxFV7:SeekLine({{'FV7_IDTAB','1'} , {'FV7_ITEDOC', oAux:GetValue('FVB_ITEM') }} )
				If lVisual
					FV7->(dbSeek( xFilial('FV7') + FV0->FV0_CODIGO + '1' + oAux:GetValue('FVB_ITEM')))
					nOper := 1
				Else
					nOper := 4
				EndIf
			EndIf
			
		Case cAbaAtiva == 'DETFV6'
	
			If !oAuxFV7:IsEmpty() .AND. oAuxFV7:SeekLine({{'FV7_IDTAB','2'}, {'FV7_ITEDOC', oAux:GetValue('FV6_ITEM') }} )
				If lVisual
					FV7->(dbSeek( xFilial('FV7') + FV0->FV0_CODIGO + '2' + oAux:GetValue('FV6_ITEM')))
					nOper := 1
				Else
					nOper := 4
				EndIf
			EndIf
	
		Case cAbaAtiva == 'DETFVD'
	
			If !oAuxFV7:IsEmpty() .AND. oAuxFV7:SeekLine({{'FV7_IDTAB','3'} , {'FV7_ITEDOC', oAux:GetValue('FVD_ITEM') }},.T.)
				If lVisual
					FV7->(dbSeek( xFilial('FV7') + FV0->FV0_CODIGO + '3' + oAux:GetValue('FVD_ITEM')))
					nOper := 1
				Else
					nOper := 4
				EndIf
			EndIf
			
		Case cAbaAtiva == 'PCOSITUACA'
	
			If !oAuxFV7:IsEmpty() .AND. oAuxFV7:SeekLine({{'FV7_IDTAB','4'} , {'FV7_ITEDOC', oAux:GetValue('FV2_ITEM') }} )
				If lVisual
					FV7->(dbSeek( xFilial('FV7') + FV0->FV0_CODIGO + '4' + oAux:GetValue('FV2_ITEM')))
					nOper := 1
				Else
					nOper := 4
				EndIf
			EndIf
	
		Case cAbaAtiva == 'DETFV8'
	                                                                                                                    
			If !oAuxFV7:IsEmpty() .AND. oAuxFV7:SeekLine({{'FV7_IDTAB','5'} , {'FV7_SITUAC',cSituacao}} )
				If lVisual
					If FV7->(dbSeek( cFV7Fil + FV0->FV0_CODIGO + '5' ))
						While FV7->(!Eof() .AND. cFV7Fil + FV0->FV0_CODIGO + '5' + cSituacao == FV7_FILIAL + FV7_CODPRO +  FV7_IDTAB + FV7_SITUAC )
							nOper := 1
							Exit
						EndDo
					EndIf
				Else
					nOper := 4
				EndIf
			EndIf
			
	EndCase
		
	FWExecView(STR0107 + cDoc , 'FINA761PDC', nOper, /*oDlg*/, {|| .T. }/*bCloseOnOk*/, /**/ , 30/*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )

	lModified := __lModif 
EndIf

Return

/*/{Protheus.doc} ModelDef
Modelo de dados
@author William Matos 
@since 05/01/2015
@version 1.0
/*/
Static Function ModelDef()
Local oModel761 	:= FWModelActive()
Local oModel 		:= MPFormModel():New('FINA761PDC',/*bPre*/,/*{||F761ValDoc()}*/,{|| F761PDGrava(oModel761) }/*bCommit*/,/*bCancel*/)
Local oStruModel	:= F761PDCEst(1)

oModel:AddFields("PREDOC",/*cOwner*/,oStruModel /*oStruct*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetDescription(STR0107)
oModel:GetModel("PREDOC"):SetOnlyQuery(.T.)
oModel:GetModel("PREDOC"):SetDescription(STR0107)
oModel:SetActivate( {||F761PDCLoad(oModel,oModel761)} )
oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Interface do modelo de dados
@author William Matos 
@since 05/01/2015
@version 1.0
/*/
Static Function ViewDef()

Local oModel 		:= FWLoadModel('FINA761PDC')
Local oView		:= FWFormView():New()
Local oViewStru	:= F761PDCEst(2)

oView:SetModel(oModel)
oView:AddField('VPREDOC' , oViewStru,"PREDOC" ) 
oView:CreateHorizontalBox( 'BOXFORM1', 100)
oView:SetOwnerView('VPREDOC','BOXFORM1')


Return oView

/*/{Protheus.doc} F761PDCEst
Montagem das estruturas dinamicas
@author William Matos 
@since 05/01/2015
@version 1.0
/*/
Function F761PDCEst(nType)
Local oStruct := Nil
Local cCpoOB	:= 'FV7_UGFAVO,FV7_FAVORE,FV7_LOJA,FV7_PROCES,FV7_BCOFAV,FV7_AGEFAV,FV7_CTAFAV,FV7_CTAUG,FV7_AGEUG,FV7_BCOUG,FV7_OBS,FV7_TXCAMB,FV7_TIPOOB,FV7_LISTA,FV7_CIT'
Local cObgOB	:= 'FV7_FAVORE,FV7_LOJA,FV7_CTAFAV,FV7_CTAUG,FV7_OBS,FV7_TIPOOB'
Local cCpoGRU	:= 'FV7_FAVORE,FV7_LOJA,FV7_PROCES,FV7_UGFAVO,FV7_MESCOM,FV7_ANOCOM,FV7_RECURS,FV7_NNUMER,FV7_OBS,FV7_VLRDOC,FV7_VLRABA,FV7_VLRDED,FV7_RECOLH'
Local cObgGRU	:= 'FV7_FAVORE,FV7_LOJA,FV7_UGFAVO,FV7_MESCOM,FV7_ANOCOM,FV7_RECURS,FV7_OBS,FV7_VLRDOC'
Local cCpoGPS	:= 'FV7_PROCES,FV7_RECURS,FV7_MESCOM,FV7_ANOCOM,FV7_OBS,FV7_ADT'
Local cObgGPS	:= 'FV7_RECURS,FV7_MESCOM,FV7_ANOCOM,FV7_OBS'
Local cCpoDAR	:= 'FV7_RECURS,FV7_VALNF,FV7_SERINF,FV7_SBSRNF,FV7_MUNICI,FV7_DTEMNF,FV7_ALIQNF,FV7_NUMNF,FV7_OBS,FV7_MESCOM,FV7_ANOCOM,FV7_UGTMSV'
Local cObgDAR	:= 'FV7_RECURS,FV7_OBS,FV7_MESCOM,FV7_ANOCOM'
Local cCpoDARF:= 'FV7_RECURS,FV7_PROCES,FV7_REFERE,FV7_RDBTAC,FV7_PERCEN,FV7_PERAPU,FV7_OBS'
Local cObgDARF:= 'FV7_RECURS,FV7_PERAPU,FV7_OBS'
Local cObrigat:= 'FV7_IDTAB,FV7_ITEDOC,FV7_PREDOC,FV7_SITUAC'
Local aAux	:= {}
Local nX		:= 0

Default nType := 0

/*
 * Inclusão dos campos virtuais quando for View
 */
cCpoOB	+= ',FV7_NTIPOB'
cCpoGRU	+= ',FV7_NRECUR'
cCpoGPS	+= ',FV7_NRECUR'
cCpoDAR	+= ',FV7_NRECUR'
cCpoDARF += ',FV7_NRECUR'

/* 1=OB;3=GRU;4=GPS;6=DAR;7=DARF */
Do Case
	Case __cPreDOC == '1' 	
		oStruct :=  FWFormStruct(nType, 'FV7',{|x| ALLTRIM(x) $ cCpoOB  + If (nType == 1,cObrigat,"")})
		aAux := StrTokArr(cObgOB,',')
		For nX	:= 1 To Len(aAux)
			oStruct:SetProperty(aAux[nX]  ,MODEL_FIELD_OBRIGAT, .T.)		
	   	Next nX
	   	If nType == 1
			oStruct:AddTrigger('FV7_TIPOOB','FV7_NTIPOB',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('SX5', 1, FWxFilial('SX5') +'0O'+ oModel:GetValue('FV7_TIPOOB') , 'X5_DESCRI')})
			oStruct:SetProperty('FV7_NTIPOB', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "POSICIONE('SX5', 1, xFilial('SX5') + '0O' + FV7->FV7_TIPOOB, 'X5_DESCRI')" ))
		EndIf
	Case __cPreDOC == '3' 
		oStruct :=  FWFormStruct(nType, 'FV7',{|x| ALLTRIM(x) $ cCpoGRU + If (nType == 1,cObrigat,"")})
		aAux := StrTokArr(cObgGRU,',')
		For nX	:= 1 To Len(aAux)
			oStruct:SetProperty(aAux[nX]  ,MODEL_FIELD_OBRIGAT, .T.)		
		Next nX
		If nType == 1
			oStruct:AddTrigger('FV7_RECURS','FV7_NRECUR',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('SX5', 1, FWxFilial('SX5') +'NZ'+ oModel:GetValue('FV7_RECURS') , 'X5_DESCRI')})
			oStruct:SetProperty('FV7_NRECUR', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "POSICIONE('SX5', 1, xFilial('SX5') + 'NZ' + FV7->FV7_RECURS, 'X5_DESCRI')" ))
		EndIf
	Case __cPreDOC == '4' 
		oStruct :=  FWFormStruct(nType, 'FV7',{|x| ALLTRIM(x) $ cCpoGPS + If (nType == 1,cObrigat,"")})
		aAux := StrTokArr(cObgGPS,',')		
		For nX	:= 1 To Len(aAux)
			oStruct:SetProperty(aAux[nX]  ,MODEL_FIELD_OBRIGAT, .T.)		
		Next nX
		If nType == 1
			oStruct:AddTrigger('FV7_RECURS','FV7_NRECUR',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('SX5', 1, FWxFilial('SX5') +'NZ'+ oModel:GetValue('FV7_RECURS') , 'X5_DESCRI')})
			oStruct:SetProperty('FV7_NRECUR', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "POSICIONE('SX5', 1, xFilial('SX5') + 'NZ' + FV7->FV7_RECURS, 'X5_DESCRI')" ))
		EndIf
	Case __cPreDOC == '6' 
		oStruct :=  FWFormStruct(nType, 'FV7',{|x| ALLTRIM(x) $ cCpoDAR + If (nType == 1,cObrigat,"")})	
		aAux := StrTokArr(cObgDAR,',')
	   	For nX	:= 1 To Len(aAux)
			oStruct:SetProperty(aAux[nX]  ,MODEL_FIELD_OBRIGAT, .T.)		
		Next nX
		If nType == 1
			oStruct:AddTrigger('FV7_RECURS','FV7_NRECUR',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('SX5', 1, FWxFilial('SX5') +'NZ'+ oModel:GetValue('FV7_RECURS') , 'X5_DESCRI')})
			oStruct:SetProperty('FV7_NRECUR', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "POSICIONE('SX5', 1, xFilial('SX5') + 'NZ' + FV7->FV7_RECURS, 'X5_DESCRI')" ))
		EndIf
	Case __cPreDOC == '7' 
		oStruct :=  FWFormStruct(nType, 'FV7',{|x| ALLTRIM(x) $ cCpoDARF + If (nType == 1,cObrigat,"")})	
		aAux := StrTokArr(cObgDARF,',')
		For nX	:= 1 To Len(aAux)
			oStruct:SetProperty(aAux[nX]  ,MODEL_FIELD_OBRIGAT, .T.)		
		Next nX
		If nType == 1
			oStruct:AddTrigger('FV7_RECURS','FV7_NRECUR',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('SX5', 1, FWxFilial('SX5') +'NZ'+ oModel:GetValue('FV7_RECURS') , 'X5_DESCRI')})
			oStruct:SetProperty('FV7_NRECUR', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "POSICIONE('SX5', 1, xFilial('SX5') + 'NZ' + FV7->FV7_RECURS, 'X5_DESCRI')" ))
		EndIf
EndCase
	
If nType == 1
	oStruct:AddTrigger('FV7_FAVORE','FV7_LOJA'  ,{ || .T.}/*bPre*/,{ |oModel| GatForn("E2_LOJA")})
EndIf

Return oStruct

/*/{Protheus.doc} F761PDGrava
Gravação no modelo ativo da rotina FINA761.
@author William Matos 
@since 05/01/2015
@version 1.0
/*/
Function F761PDGrava(oModel761)
Local oModelPDC	:= FWModelActive()
Local aPos761		:= oModel761:GetModel('DETFV7'):GetStruct():GetFields()	//Modelo da rotina FINA761
Local aPosPDC		:= oModelPDC:GetModel('PREDOC'):GetStruct():GetFields()	//Modelo Atual.
Local lRet		:= .T.
Local nPos		:= 0
Local nX			:= 0

If oModelPDC:GetOperation() == MODEL_OPERATION_INSERT .AND. !oModel761:GetModel('DETFV7'):IsEmpty()
   oModel761:GetModel('DETFV7'):AddLine()
EndIf   
//
For nX := 1 To Len(aPosPDC)

	If ( nPos := aScan( aPos761, { |x| AllTrim( x[3] ) ==  AllTrim( aPosPDC[nX][3] ) } ) ) > 0

		If !Empty(oModelPDC:GetModel('PREDOC'):GetValue( aPosPDC[nX][3] )) .AND. oModel761:GetModel("DETFV7"):CanSetValue( aPos761[nPos][3] )
			If AllTrim(aPos761[nPos][3]) == "FV7_OBS"
				oModel761:GetModel("DETFV7"):SetValue(aPos761[nPos][3], DecodeUTF8(EncodeUTF8(oModelPDC:GetModel("PREDOC"):GetValue(aPosPDC[nX][3]))))
			Else
				oModel761:GetModel("DETFV7"):SetValue(aPos761[nPos][3], oModelPDC:GetModel("PREDOC"):GetValue(aPosPDC[nX][3]))
			EndIf
			
			__lModif := .T.
		EndIf
		
	EndIf
Next nX

oModelPDC:DeActivate()

Return lRet

/*/{Protheus.doc} F761PDCLoad
Carrega os valores do pré-documento.
@author William Matos 
@since 05/01/2015
@version 1.0
/*/
Function F761PDCLoad(oModel,oModel761)
Local nOper 	  := oModel:GetOperation()
Local aPos761   := oModel761:GetModel('DETFV7'):GetStruct():GetFields()	//Modelo rotina FINA761
Local aPosPDC	  := oModel:GetModel('PREDOC'):GetStruct():GetFields()	//Modelo Atual.
Local oAuxFV7	  := oModel761:GetModel('DETFV7')
Local nX		  := 0
Local cBanco  	:= ""
Local cAgenc	:= ""
Local cConta	:= ""
Local aArea 	:= SA2->(GetArea()) 

DbSelectArea("SA2")
DbSetOrder(1)

SA2->(DbGoTop())

If SA2->(DbSeek(xFilial("SA2")+oModel761:GetModel("DADOPAGFAV"):GetValue('FV6_FAVORE')+oModel761:GetModel("DADOPAGFAV"):GetValue('FV6_LOJA')))
	cBanco := SA2->A2_BANCO
	cAgenc := SA2->A2_AGENCIA 
	cConta := SA2->A2_NUMCON
EndIf


If nOper == MODEL_OPERATION_INSERT

	oModel:LoadValue('PREDOC','FV7_PREDOC', __cPreDOC )
	
	Do Case
		
		Case __cAba761 == 'DETFVB' //Encargos
	
			oModel:LoadValue('PREDOC','FV7_IDTAB' ,'1')
			oModel:LoadValue('PREDOC','FV7_ITEDOC',oModel761:GetModel(__cAba761):GetValue('FVB_ITEM'))
	
		Case __cAba761 == 'DETFV6' //Dados de Pagamento	
		
			oModel:LoadValue('PREDOC','FV7_IDTAB' ,'2')
			oModel:LoadValue('PREDOC','FV7_ITEDOC',oModel761:GetModel("DADOPAGFAV"):GetValue('FV6_ITEM'))
			oModel:LoadValue('PREDOC','FV7_BCOFAV' ,cBanco)	
			oModel:LoadValue('PREDOC','FV7_AGEFAV' ,cAgenc)
			oModel:LoadValue('PREDOC','FV7_CTAFAV' ,cConta)
	
		Case __cAba761 == 'DETFVD' //Dedução		
	
			oModel:LoadValue('PREDOC','FV7_IDTAB' ,'3')
			oModel:LoadValue('PREDOC','FV7_ITEDOC',oModel761:GetModel(__cAba761):GetValue('FVD_ITEM'))
		
		Case __cAba761 == 'PCOSITUACA' //Principal com orçamento
		
			oModel:LoadValue('PREDOC','FV7_IDTAB' ,'4')
			oModel:LoadValue('PREDOC','FV7_ITEDOC',oModel761:GetModel(__cAba761):GetValue('FV2_ITEM'))
	
	
		Case __cAba761 == 'DETFV8' //Sem Orçamento		
	
			oModel:LoadValue('PREDOC','FV7_IDTAB' ,'5')
			oModel:LoadValue('PREDOC','FV7_SITUAC',oModel761:GetModel(__cAba761):GetValue('FV8_SITUAC'))
	EndCase
//Carrega os valores.
Else 
	
	For nX := 1 To Len(aPos761)
	
		If ( nPos := aScan( aPosPDC, { |x| AllTrim( x[3] ) ==  AllTrim( aPos761[nX][3] ) } ) ) > 0
	
			If !Empty(oAuxFV7:GetValue( aPos761[nX][3] )) .AND. oModel:GetModel("PREDOC"):CanSetValue( aPosPDC[nPos][3] )
				If AllTrim(aPosPDC[nPos,3]) == "FV7_OBS"
					oModel:GetModel("PREDOC"):SetValue(aPosPDC[nPos,3], DecodeUTF8(EncodeUTF8(oAuxFV7:GetValue(aPos761[nX,3]))))
				Else
					oModel:GetModel("PREDOC"):SetValue(aPosPDC[nPos,3], oAuxFV7:GetValue(aPos761[nX,3]))
				EndIf
			EndIf
			
		EndIf
	
	Next nX
			
EndIf

RestArea(aArea)

Return .T.

/*/{Protheus.doc} F761Cbox
Carrega combo dinamico para a tabela FV7 - Pre-Doc.
@author William Matos 
@since 05/01/2015
@version 12.1.4
@return cRet Retorna texto para montagem da listagem do combobox de tipos de pré-doc disponíveis para documento hábil.
/*/
Function F761Cbox() 
Local cRet := "0=" + STR0102 + ";1=" + STR0103 + ";2=" + STR0104 + ";3=" +STR0105 
				
If	!Empty(__cPreDOC) .AND. __cPreDOC	== '7' //DARF
	cRet += ";8=" + STR0106
EndIf

Return cRet

/*/{Protheus.doc} ValDatPDC
Valida campos de informações de data do formulário do Pré-doc

@author Marylly Araújo Silva
@since 25/02/2015
@version 12.1.4
@param xValor Valor do campo de data a ser validado
@return lRet Retorna se a validação foi feita corretamente
/*/
Function ValDatPDC()
Local lRet	:= .T.
Local cCpo	:= ReadVar()
Local dData	:= Nil
Local cValue	:= ""

If "FV7_MESCOM" $ AllTrim(cCpo)
	dData := CTOD("01/" + &(AllTrim(cCpo)) + "/" + CVALTOCHAR(Year(DDATABASE)))
	cValue := Month(dData)
	
	If EMPTY(cValue)
		lRet := .F.							
		Help( "", 1, "FV7DATE", , OemToAnsi( STR0159 ), 1, 0 ) //"Mês informado incorreto.<br>Informe novamente o mês."
	EndIf
ElseIf "FV7_ANOCOM" $ AllTrim(cCpo)
	dData := CTOD("01/01/" + &(AllTrim(cCpo)))
	cValue := Year(dData)
	
	If EMPTY(cValue)
		lRet := .F.							
		Help( "", 1, "FV7DATE", , OemToAnsi( STR0160 ), 1, 0 ) //"Ano informado incorreto.<br>Informe novamente o ano."
	EndIf
	
	If lRet .AND. cValue > Year(DDATABASE)
		lRet := .F.							
		Help( "", 1, "FV7DATE", , OemToAnsi( STR0160 ), 1, 0 ) //"Ano informado incorreto.<br>Informe novamente o ano."
	EndIf
	
EndIf
Return lRet
