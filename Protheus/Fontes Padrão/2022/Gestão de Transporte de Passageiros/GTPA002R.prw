#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA002R.CH'

Static nLinMark    := 0
Static __RECNOGI2 := 0

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA002R()
Chama a tela Replica do Perfil de Alocação.
@type 	Function
@author	Lucas Brustolin -  Inovação
@since	07/07/2017
@version version
@param	
@return 
@example GTPA002R(oVew)
/*/
//-------------------------------------------------------------------
Function GTPA002R()

Local lRet :=  .T.

__RECNOGI2 := GI2->( Recno() ) 

If __RECNOGI2 <> 0

	DbSelectArea("GYM") // Recursos por linha
	GYM->(DbSetOrder(2))

	If GYM->( DbSeek(xFilial("GI2") + GI2->GI2_COD) )
		if !IsBlind()
			FWExecView(STR0011,"VIEWDEF.GTPA002R", MODEL_OPERATION_UPDATE,,{|| .T.})	//"Perfil Alocação"
		EndIf
	Else
		Help( ,, 'Help',"GTPA002R", STR0010, 1, 0 )//"Linha selecionada não possui perfil de alocação configurado."
		lRet := .F.	
	EndIf
Else	
	HELP(" ",1,"ARQVAZIO")
	lRet := .F.
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

@sample  	ModelDef()

@return  	oModel - Objeto do Model

@author	Lucas Brustolin -  Inovação
@since		07/07/2017
@version 	P12
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
		
Local oModel		:= Nil
Local oStruDe	    := FWFormStruct( 1,"GI2",{ |x| ALLTRIM(x)+"|" $ "GI2_COD|" } , .F.) //Tabela de Linhas
Local oStruPara		:= FWFormStruct( 1,"GI2",{ |x| ALLTRIM(x)+"|" $ "GI2_COD|" } , .F.) //Tabela de Linhas
Local bPosValid		:= {|oModel| TP002RTdOk(oModel)}
Local bCommit		:= {|oModel| TP002RCommit(oModel)} 	//Commit do Model

nLinMark    :=  0


//-- Add campo virtual Descrição Linha
GA002StrGI2(oStruDe,"GTPA002R","M")
GA002StrGI2(oStruPara,"GTPA002R","M")

// Adiciona o marcador de seleção dos equipamentos
oStruPara:AddField( '   ', ; // cTitle // 'Mark'
				STR0001, ; // cToolTip // 'Mark' //#Marque a(s) Trecho(s) 
				'GI2_FLAG', ; // cIdField
				'L', ; // cTipo
				1, ; // nTamanho
				0, ; // nDecimal
				{|oModel, cCampo, xValueNew, nLine, xValueOld| vldMark(oModel, cCampo, xValueNew, nLine, xValueOld) }, ; // bValid
				{||	.T.},; // bWhen
				Nil, ; // aValues/
				Nil, ; // lObrigat
				Nil, ; // bInit
				Nil, ; // lKey
				.F., ; // lNoUpd
				.T. ) // lVirtual


oModel := MPFormModel():New('GTPA002R',/*bPreValid*/, bPosValid , bCommit)

oModel:AddFields("GI2MASTER", /*cOwner*/, oStruDe,/*bLinePre*/)
oModel:AddGrid('GI2DETAIL','GI2MASTER', oStruPara)

oModel:SetDescription(STR0001)//"Replicar - "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
oModel:GetModel("GI2MASTER"):SetDescription(STR0002) // "Replicar perfil da linha:"
oModel:GetModel('GI2DETAIL'):SetDescription(STR0003)//"Para:"

oModel:GetModel('GI2MASTER'):SetOnlyQuery(.T.)
oModel:GetModel('GI2DETAIL'):SetOnlyQuery(.T.)

oModel:SetActivate({|oModel| TP002RLoad(oModel,"GI2MASTER","GI2DETAIL")})

//Define chave unica
oModel:SetPrimaryKey({"GI2_FILIAL","GI2_COD"})

Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

@sample  	ViewDef()

@return  	oView - Objeto do View

@author	Lucas Brustolin -  Inovação
@since		07/07/2017
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= Nil
Local oModel	:= FWLoadModel('GTPA002R')
Local oStruDe	:= FWFormStruct( 2,"GI2", { |x| ALLTRIM(x)+"|" $ "GI2_COD|" } , .F.) //Tabela de Linhas
Local oStruPara	:= FWFormStruct( 2,"GI2", { |x| ALLTRIM(x)+"|" $ "GI2_COD|" } , .F.) //Tabela de Linhas


//-- Add campo virtual Descrição Linha
GA002StrGI2(oStruDe,"GTPA002R","V")
GA002StrGI2(oStruPara,"GTPA002R","V")

oStruPara:AddField( 'GI2_FLAG', ; // cIdField
				'01', ; // cOrdem
				'   ', ; // cTitulo // 'Mark'
				STR0004, ; // cDescric // 'Mark' //#"Marque o(s) Trecho(s) " 
				{STR0005,STR0006}, ; // aHelp : 'Marque os itens que deseja aplicar'  ' ### 'a configuração.'    
				'CHECK', ; // cType
				'@!', ; // cPicture
				Nil, ; // nPictVar
				Nil, ; // Consulta F3
				.T., ; // lCanChange
				'' , ; // cFolder
				Nil, ; // cGroup
				Nil, ; // aComboValues
				Nil, ; // nMaxLenCombo
				Nil, ; // cIniBrow
				.T., ; // lVirtual
				Nil ) // cPictVar


oView := FWFormView():New()

oView:SetModel(oModel)	

oView:SetFieldAction( 'GI2_FLAG', { |oView, cIDView, cField, xValue| oView:Refresh() } )

oView:AddField('GI2MASTER',oStruDe)	
oView:AddGrid('GI2DETAIL',oStruPara)	

oView:CreateHorizontalBox('SUPERIOR',20)	
oView:CreateHorizontalBox('INFERIOR',80)

oView:SetOwnerView('GI2MASTER','SUPERIOR')
oView:SetOwnerView('GI2DETAIL','INFERIOR')	

// Liga a identificacao do componente
oView:EnableTitleView('GI2MASTER' )
oView:EnableTitleView('GI2DETAIL' )

oView:AddUserButton( STR0007 , "FILTRO"	, {|oView| TP002RMkAll(oView) } ) 

Return ( oView )



//-------------------------------------------------------------------
/*/{Protheus.doc} TP002RCommit
Rotina para gravação do modelo de dados.

@param oModel - Modelo de dados

@sample  TP002RCommit(oModel)

@return  lRet = .T.  Gravação realizada.

@author	Lucas Brustolin -  Inovação
@since		09/07/2017
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function TP002RCommit(oModel)

//-- SubModelos do cadastro  (Replica - Perfil)
//-- Perfil de Alocação
Local oFieldGI2 		:= oModel:GetModel('GI2MASTER')
Local oGridPara 		:= oModel:GetModel('GI2DETAIL')
//-- SubModelos do cadastro de linhas
//-- Perfil de Alocação
Local oMdlAux		:= Nil
Local oMdl002		:= Nil

//-- Variaveis controle
Local aReplicar		:= {}
Local cCodLinha		:= ""
Local cCodGYM		:= ""
Local cFolderGrid	:= ""
Local cLinhaDe		:= ""
Local lRet 			:= .T.
//-- Variaveis contadoras

Local n1			:= 0
Local n2			:= 0
Local n3			:= 0
Local n4			:= 0


If oModel:GetOperation() == MODEL_OPERATION_UPDATE

	// -----------------------------------------------------------------------------+	
	// RECUPERA O ITEM DA SECAO DE COPIA E OS ITENS DE REPLICA (Trechos COM MARCAÇÃO)|
	// -----------------------------------------------------------------------------+	
	cLinhaDe	:= oFieldGI2:GetValue("GI2_COD")	
	// Carrega itens que receberão a configuração do Item Copia
	oGridPara:GoLine(1)	
	For n1 := 1 To oGridPara:Length()
		If oGridPara:GetValue("GI2_FLAG", n1)
			Aadd(aReplicar, oGridPara:GetValue("GI2_COD", n1) )
		EndIf
		oGridPara:GoLine(n1)
	Next n1

	
	// -------------------------------------------------------------------------------------------------+
	// COPIA OS DADOS DA SEÇÃO COPIA, RECURSOS DA SECAO SELECIONADA COM SUAS RESPECTIVAS CARACTERISTICAS|
	// -------------------------------------------------------------------------------------------------+
	DbSelectArea("GI2")
	DbSetOrder(1)
	oMdlAux	 := FWLoadModel("GTPA002P") // Recupera o modelo (LINHAS)
	//Posiciona na linha que sera copiada as configuracoes (Recursos x Caracteristicas)
	If GI2->( DBSeek(xFilial("GI2") + cLinhaDe ) )		
		oMdlAux:SetOperation(MODEL_OPERATION_UPDATE)
		oMdlAux:Activate()

		// -----------------------------------------------------------------+
		// GRAVA OS DADOS DA SECAO COPIA PARA AS LINHAS MARCADAS (REPLICAS) |
		// -----------------------------------------------------------------+	
		If oMdlAux:IsActive()

			DbSelectArea("GI2")
			DBSetOrder(1)
			
			oMdl002 := FWLoadModel('GTPA002P')
			// Loop com as Linhas que foram marcadas(Check). 
			For n1 := 1 To Len(aReplicar)				

				cCodLinha := aReplicar[n1]

				If GI2->( DbSeek(xFilial("GI2") + cCodLinha ) )
					oMdl002:SetOperation(MODEL_OPERATION_UPDATE)
					oMdl002:Activate()	
									
					oMdl002:GetModel('GYMGRID'):DelAllLine()
					
					// --------------------------------------------------+	
					//  LOOP PARA COPIAR OS DADOS DE ORIGEM PARA DESTINO |
					// --------------------------------------------------+				
					For n2 := 1 To oMdlAux:GetModel('GYMGRID'):Length()						
						oMdlAux:GetModel('GYMGRID'):GoLine(n2)
						
						cCodGYM := GetSX8num("GYM","GYM_CODIGO")
						If oMdl002:GetModel('GYMGRID'):IsDeleted() .or. !Empty(oMdl002:GetModel('GYMGRID'):GetValue('GYM_CODIGO'))
							oMdl002:GetModel('GYMGRID'):AddLine()
						EndIf
						oMdl002:GetModel('GYMGRID'):LoadValue('GYM_CODIGO'	, cCodGYM )
						oMdl002:GetModel('GYMGRID'):LoadValue('GYM_RECCOD'	, oMdlAux:GetModel('GYMGRID'):GetValue('GYM_RECCOD',n2) )
						oMdl002:GetModel('GYMGRID'):LoadValue('GYM_OBG'		, oMdlAux:GetModel('GYMGRID'):GetValue('GYM_OBG',n2) )
						oMdl002:GetModel('GYMGRID'):LoadValue('GYM_ORIGEM'	, "GI2" )
						oMdl002:GetModel('GYMGRID'):LoadValue('GYM_CODENT'	, cCodLinha )	
						
						For n3 := 1 To 5
							
							cFolderGrid	:= AllTrim("GYJGRID_"  + AllTrim( Str(n3)) )

							For n4 := 1 To oMdlAux:GetModel(cFolderGrid):Length()
								If !Empty(oMdl002:GetModel(cFolderGrid):GetValue('GYJ_CODGYM'))
									oMdl002:GetModel(cFolderGrid):AddLine()
								EndIf
								oMdl002:GetModel(cFolderGrid):LoadValue('GYJ_CODGYM', cCodGYM )
								oMdl002:GetModel(cFolderGrid):LoadValue('GYJ_TIPO'	, AllTrim( Str(n3) ) )
								oMdl002:GetModel(cFolderGrid):LoadValue('GYJ_CHAVE'	, oMdlAux:GetModel(cFolderGrid):GetValue('GYJ_CHAVE',n4) )
							Next n4
						Next n3
					Next n2

					// --------------------------------+	
					// Realiza a gravação da alteração |
					// --------------------------------+
					If oMdl002:VldData()   	
						oMdl002:CommitData()
						oMdl002:DeActivate() 
					Else
						JurShowErro( oMdl002:GetModel():GetErrormessage() )	
						lRet := .F.
					EndIf 
				EndIf
			Next n1
			//Desativa e Destroi Modelo Auxiliar
			oMdlAux:DeActivate()
			oMdlAux:Destroy()
		Endif
	EndIf
EndIf

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldMark
	valida a marcação do registro e elimina uma marcação anterior
@sample 	VldMark()
@since		07/07/2017        
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function VldMark( oGridPara, cCampo, xValueNew, nLine, xValueOld )

Local nLinAtual	:= 0
Local lRet       	:= .T. 


If lRet .And. xValueNew
	nLinAtual   := oGridPara:GetLine()
	
	If nLinAtual <> nLinMark 
	
		If nLinMark <> 0
			oGridPara:GoLine( nLinMark )
			oGridPara:SetValue('GI2_FLAG', .T. ) // desmarca o item anterior
		EndIf
		
		oGridPara:GoLine( nLinAtual )  // retorna ao item posicionado antes
		
	EndIf
	
	nLinMark := nLinAtual
Else
	nLinMark := 0
EndIf

oGridPara:GoLine( 1 ) 

Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At825ATdOk
	Valida a seleção de pelo menos 1 item para realizar a reserva
@sample 	TP002RTdOk(oModel)
@since		07/07/2017        
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function TP002RTdOk(oModel)

Local lRet := nLinMark <> 0

If !lRet
	Help(,,'GTPA002R',,STR0009,1,0)  // 'Não foi selecionado item para a reserva'
EndIf

Return( lRet )


//------------------------------------------------------------------------------
/*/{Protheus.doc} TP002RMkAll
	Marca ou desmarca todos os registros da grid
@sample 	TP002RMkAll(oView)
@since		07/07/2017       
@version	P12
/*/
//------------------------------------------------------------------------------
Function TP002RMkAll(oView)

Local lRet 		    := .T.
Local oModel 	    := FWModelActive()
Local oGridPara	:= oModel:GetModel('GI2DETAIL')
Local nI		    := 1

For nI := 1 To oGridPara:Length()
	oGridPara:GoLine( nI )
	If oGridPara:GetValue("GI2_FLAG")
		oGridPara:SetValue("GI2_FLAG", .F.)
	Else
		oGridPara:SetValue("GI2_FLAG", .T.)
	EndIf
Next nI

Return( lRet )
							 		


//------------------------------------------------------------------------------
/*/{Protheus.doc} TP002RLoad
 Faz a carga dos dados para tela Replica do Perfil de Alocação
@sample 	TP002RTdOk(oModel)
@since		07/07/2017        
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function TP002RLoad(oModel,cIdSubMdl,cIdSubMdl_Para )
Local cAliasGI2		:= GetNextAlias()
Local cLinhaDe		:= ""
Local lRet			:= .T.
Local lFirst		:= .T.

If GI2->( Recno() ) <> __RECNOGI2
	GI2->( DbGoto(__RECNOGI2) )
EndIf 

cLinhaDe := GI2->GI2_COD 

If oModel:GetOperation() == MODEL_OPERATION_UPDATE

    DbSelectArea("GYM")
    GYM->(DbSetOrder(2))
	
    If GYM->( DbSeek(xFilial("GI2") + cLinhaDe) )

        oModel:GetModel(cIdSubMdl):LoadValue("GI2_COD",GI2->GI2_COD)
        oModel:GetModel(cIdSubMdl):LoadValue("DSCLINHA",TPNomeLinh(oModel:GetModel(cIdSubMdl):GetValue("GI2_COD")))

        oModel:GetModel(cIdSubMdl_Para):GoLine(1)

		BeginSql Alias cAliasGI2

			SELECT 
				GI2_COD 
			FROM 
				%Table:GI2% GI2
			WHERE
				GI2.GI2_FILIAL = %xFilial:GI2%
				AND GI2.GI2_HIST = '2'
				AND GI2.%NotDel%

		EndSql

		While (cAliasGI2)->(!Eof())

			If (cAliasGI2)->GI2_COD <> cLinhaDe

				If !lFirst
					oModel:GetModel(cIdSubMdl_Para):AddLine()
				EndIf
					
				oModel:GetModel(cIdSubMdl_Para):LoadValue("GI2_COD",(cAliasGI2)->GI2_COD)
				oModel:GetModel(cIdSubMdl_Para):LoadValue("DSCLINHA",TPNomeLinh((cAliasGI2)->GI2_COD))
				lFirst := .F.
			EndIf

			(cAliasGI2)->(dbSkip())

		End

		(cAliasGI2)->(dbCloseArea())

    Else
        Help( ,, 'Help',"GTPA002R", STR0010, 1, 0 )//"Linha selecionada não possui perfil de alocação configurado."
        lRet := .F.
    EndIf

EndIf



Return(lRet)