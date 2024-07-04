#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Fechamento de Frete"
/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author Igor Gomes Oliveira 
    @since 02/06/2023
    @version 1.0
    @param 
    @return 
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function VAFATI04()
	Local aArea		:= FWGetArea()
	Local oBrowse
	Private nTotEmb := 0 //Total embarque	
	Private nTotDes := 0 //Total desembarque
	Private aCTE 	:= {}
	

	//Cria um browse para a ZNP, filtrando somente a tabela 00 (cabeçalho das tabelas
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZFF")
	oBrowse:SetDescription(cTitulo)
	//oBrowse:SetFilterDefault("ZNP->ZNP_CODIGO == '00'")
	oBrowse:Activate()

	//SetFunName(cFunBkp)
    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 		:= nil
	Local oStru   		:= FWFormStruct(1, 'ZFF')
	Local oCte 			:= FWFormStruct(1, 'TempCte')
	Local bPos 			:= {|| U_FATI04S()}
	Local nI
	Local aGatilhos		:= {}

	//Criando o FormModel, adicionando o Cabeçalho e Grid

	oCte 	:= GetModelCte(oModel, oCte)

	aAdd(aGatilhos, FWStruTriggger( "CBC_LOJA",;     	//Campo Origem
                                    "CBC_NOME",;     	//Campo Destino
                                	"SA2->A2_NOME",;			//Regra de Preenchimento
                                    .T.,;           	//Irá Posicionar?
                                    "SA2",;            	//Alias de Posicionamento
                                    1,;             	//Índice de Posicionamento
                                    'xFilial("SA2")+M->CBC_FORNEC+M->CBC_LOJA',;            	//Chave de Posicionamento
                                    NIL,;           	//Condição para execução do gatilho
                                    "01");          	//Sequência do gatilho
    )

    For nI := 1 To Len(aGatilhos)
        oCte:AddTrigger(  aGatilhos[nI][01],; //Campo Origem
                            aGatilhos[nI][02],; //Campo Destino
                            aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
                            aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next

	oModel := MPFormModel():New("FATI04M",,bPos)

	oModel:AddFields("ZFFMASTER",/*cOwner*/  ,oStru		, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddGrid('FORMGridM', 'ZFFMASTER'	, oCte, /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */, {|| U_I04LOAD()})

	//oModel:AddFields("EMBARQUE"		,'ZFFMASTER' ,oStEmbarque, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	//oModel:AddFields("DESEMBARQUE"	,'ZFFMASTER' ,oStDesembar, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
    //oModel:SetRelation( 'ID_M_GRD1', {{'ID','ID'}}, (cAlisGr1)->(IndexKey(1)))

	oModel:SetPrimaryKey({ })

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZFFMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	oModel:GetModel("FORMGridM"):SetDescription("Grid do Cadastro "+cTitulo)
	oModel:GetModel('FORMGridM'):SetOptional(.T.)
	
	//oModel:GetModel("EMBARQUE"):SetDescription("Formulário do Embarque "+cTitulo)
	//oModel:GetModel("DESEMBARQUE"):SetDescription("Formulário do Desembarque "+cTitulo)

Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAFATI04")
    Local oStru     	:= FWFormStruct(2, "ZFF", {|cCampo| !(AllTrim(cCampo) $ "ZFF_NCTE|ZFF_SCTE|ZFF_DTDESE|ZFF_HRDESE|ZFF_DATA|ZFF_HREMB|ZFF_BOIS|ZFF_VACAS|ZFF_BUFALO|ZFF_TOURO|ZFF_NOVILH|ZFF_EMPE|ZFF_CAIDOS|ZFF_EMERGE|ZFF_MORTO" )} )
	Local oStEmbarque	:= FWFormStruct(2, 'ZFF', {|cCampo| AllTrim(cCampo) $ "ZFF_DATA|ZFF_HREMB|ZFF_BOIS|ZFF_VACAS|ZFF_BUFALO|ZFF_TOURO|ZFF_NOVILH"})
	Local oStDesembar	:= FWFormStruct(2, 'ZFF', {|cCampo| AllTrim(cCampo) $ "ZFF_DTDESE|ZFF_HRDESE|ZFF_EMPE|ZFF_CAIDOS|ZFF_EMERGE|ZFF_MORTO"})
	Local oCte 			:= FWFormStruct(2, 'TempCte')
	Local oView

	oCte := GetVGridCte(oModel, oCte)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZFF", oStru 		, "ZFFMASTER")
	oView:AddField("VIEW_EMB", oStEmbarque 	, "ZFFMASTER")
	oView:AddField("VIEW_DES", oStDesembar 	, "ZFFMASTER")
	oView:AddGrid("GRID_CTE" , oCte 		, "FORMGridM") 
	
	oView:CreateHorizontalBox('CABEC', 70 )
	oView:CreateHorizontalBox('RODAP', 30 )
	
	oView:CreateFolder('ABA01','CABEC')
	oView:CreateFolder('PASTARODAPE','RODAP')
	oView:AddSheet('PASTARODAPE','ABAEMBARQUE'	,"Embarque e Desembarque")
	oView:AddSheet('PASTARODAPE','ABACTE'		,"Dados da CTE")

    oView:CreateVerticalBox( "EMBA_SEL", 50,,, 'PASTARODAPE','ABAEMBARQUE')
    oView:CreateVerticalBox( "DESE_SEL", 50,,, 'PASTARODAPE','ABAEMBARQUE')
    oView:CreateHorizontalBox( "GRID_SEL", 100,,, 'PASTARODAPE','ABACTE')
	
	oView:SetOwnerView("VIEW_ZFF"	 , "CABEC")
	oView:SetOwnerView("VIEW_EMB"	 , "EMBA_SEL")
	oView:SetOwnerView("VIEW_DES"	 , "DESE_SEL")
	oView:SetOwnerView("GRID_CTE"	 , "GRID_SEL")
	
	oView:EnableTitleView('VIEW_ZFF' , cTitulo)
	oView:EnableTitleView('VIEW_EMB' , 'Embarque')
	oView:EnableTitleView('VIEW_DES' , 'Desembarque')
	oView:EnableTitleView('GRID_CTE' , "CTE")
	
	//SetKey( VK_F10, {|oView| aCTE := U_VAFATI05()} )
	
	oView:SetCloseOnOk( { |oView| .T. } )
Return oView

Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.VAFATI04' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.VAFATI04' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.VAFATI04' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.VAFATI04' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 
Return aRot
User Function FATI04M()
	Local aParam 	:= PARAMIXB
	Local xRet 		:= .T.
	Local oObj 		:= ''
	Local cIdPonto 	:= ''
	//Local cTotEmb	:= 0

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]

		if cIdPonto == 'FORMCOMMITTTSPRE'
			if nTotEmb < nTotDes
				MsgAlert("Quantidade total do Embarque menor que o Desembarque.", "Atenção...")
				xRet := .F.
			elseif nTotEmb > nTotDes
				MsgAlert("Quantidade total do Desembarque menor que o Embarque.", "Atenção...")
				xRet := .F.
			endif
		endif
	endif
Return xRet
//Criar Campos virtuais para CTE
Static Function GetModelCte(oModel, oCte)
	oCte:AddField('Item'		, 'Item'  		, 'CBC_ITEM' 	, 'C', 2					    , 0, /* Validação  */,,{},.F., {|| U_I04INC() }		,.F.,.F.,.T.,)
	oCte:AddField('Fornecedor'	, 'Fornecedor' 	, 'CBC_FORNEC'	, 'C', TamSX3("A2_COD")[1] 	  	, 0, /* Validação  */,,{},.F.,{|| U_I04IFOR() }		,.F.,.F.,.T.,)
	oCte:AddField('Loja'		, 'Loja'		, 'CBC_LOJA'	, 'C', TamSX3("A2_LOJA")[1]	  	, 0, /* Validação  */,,{},.F.,{|| U_I04IFOR() }		,.F.,.F.,.T.,)
	oCte:AddField('Nome'		, 'Nome'		, 'CBC_NOME'	, 'C', TamSX3("A2_NOME")[1]	  	, 0, /* Validação  */,,{},.F.,{|| U_I04IFOR() }		,.F.,.F.,.T.,)
	oCte:AddField('Doc' 		, 'Doc'   		, 'CBC_DOC'  	, 'C', TamSX3("F1_DOC")[1]    	, 0, {|| U_I04CTE()} ,,{},.F.,/* Iniciador Padrão */,.F.,.F.,.T.,)
	oCte:AddField('Serie'		, 'Serie' 		, 'CBC_SERIE'	, 'C', TamSX3("F1_SERIE")[1]  	, 0, /* Validação  */,,{},.F.,/* Iniciador Padrão */,.F.,.F.,.T.,)
	oCte:AddField('Valor'		, 'Valor' 		, 'CBC_VALOR'	, 'N', TamSX3("F1_VALBRUT")[1]	, 0, /* Validação  */,,{},.F.,/* Iniciador Padrão */,.F.,.F.,.T.,)
Return oCte

Static Function GetVGridCte(oModel, oCte)
	oCte:AddField('CBC_ITEM' 	, '1', 'Item' 		, 'Item' 		,{}, 'C',""					,/* bPictVar */,/* cLookUp */,.F.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_FORNEC'	, '2', 'Fornecedor'	, 'Fornecedor'	,{}, 'C',""					,/* bPictVar */,'SA2'		 ,.T.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_LOJA'	, '3', 'Loja'		, 'Loja'		,{}, 'C',""					,/* bPictVar */,/* cLookUp */,.T.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_NOME'	, '4', 'Nome'		, 'Nome'		,{}, 'C',""					,/* bPictVar */,/* cLookUp */,.F.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_DOC'  	, '5', 'Doc'  		, 'Doc'  		,{}, 'C',""					,/* bPictVar */, 'SF1'		 ,.T.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_SERIE'	, '6', 'Serie'		, 'Serie'		,{}, 'C',""					,/* bPictVar */,/* cLookUp */,.F.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_VALOR'	, '7', 'Valor'		, 'Valor'		,{}, 'N',"@E 999,999.999"	,/* bPictVar */,/* cLookUp */,.F.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
Return oCte

//Validação dos campos ZFF_DATA e ZFF_DTDESE
User Function FAT04DT()
	Local oModel		:= FWModelActive()
	Local oStruct 		:= oModel:GetModel("ZFFMASTER")
	Local lRet 			:= .T. 
	Local cCampo 		:= SubS( ReadVar(), At(">", ReadVar())+1 )
	Local cDt 			:= &(ReadVar())

	if cCampo == 'ZFF_DATA'
		if cDt > dDataBase
			lRet := .F.
			oModel:SetErrorMessage("","","","","Data Inválida", 'Data de Embarque não pode ser maior que a data atual!', "") 
		elseif !EMPTY(oStruct:GetValue("ZFF_DTDESE"))
			if cDt > oStruct:GetValue("ZFF_DTDESE")
				lRet := .F.
				oModel:SetErrorMessage("","","","","Data Inválida", 'Data de Embarque não pode ser maior que a data de desembarque!', "") 
			endif 
		endif
	else
		if cDt > dDataBase
			lRet := .F. 
			oModel:SetErrorMessage("","","","","Data Inválida", 'Data de Desembarque não pode ser maior que a data atual!', "")
		elseif !EMPTY(oStruct:GetValue("ZFF_DATA"))
			if cDt < oStruct:GetValue("ZFF_DATA")
				lRet := .F.
				oModel:SetErrorMessage("","","","","Data Inválida", 'Data de Desembarque não pode ser menor que a data de Embarque!', "") 
			endif 
		endif
	endif
Return lRet
//Carga do submodelo FORMGridM
User Function I04LOAD()
	Local oModel	:= FWModelActive()
	Local oStruct 	:= oModel:GetModel("ZFFMASTER")
	Local aArea		:= GetArea()
	Local aRet 		:= {}
	//Local nI 		:= 0
	Local cQry 		:= ''
	Local nValor	:= 0 
	cQry := " SELECT *  " + CRLF 
	cQry += " FROM "+RetSqlName("ZFI")+"  " + CRLF 
	cQry += " WHERE ZFI_FILIAL 	= '"+FWxFilial("ZFI")+"' " + CRLF 
	cQry += " AND ZFI_CODIGO	= '"+oStruct:GetValue("ZFF_CODIGO")+"' " + CRLF 
	cQry += " AND ZFI_PLACA		= '"+oStruct:GetValue("ZFF_PLCVL")+"' " + CRLF 
	cQry += " AND D_E_L_E_T_	= '' " + CRLF 

	mpSysOpenQuery(cQry,"TMP")

	DBSELECTAREA( "SF1" )
	DBSETORDER( 2 )
	
	while !TMP->(EOF())

		IF DbSeek(FwxFilial("SF1")+;
			TMP->ZFI_FORNEC+;
			TMP->ZFI_LOJA+;
			TMP->ZFI_DOC )
			
			nValor := SF1->F1_VALBRUT
		else 
			nValor := 0 
		ENDIF 
		aAdd(aRet,{Val(TMP->ZFI_ITEM),{	TMP->ZFI_ITEM,;
										TMP->ZFI_FORNEC,;
										TMP->ZFI_LOJA,;
										iif(!Empty(TMP->ZFI_FORNEC),Posicione("SA2",1,FwxFilial("SA2")+TMP->ZFI_FORNEC+TMP->ZFI_LOJA,"A2_NOME"),"")	,;
										TMP->ZFI_DOC,;
										TMP->ZFI_SERIE,;
										nValor}})
	
		TMP->(DbSkip())
	end

	SF1->(DBCLOSEAREA())
	//iif(!Empty(TMP->ZFI_FORNEC),Posicione("SF1",2,FwxFilial("SF1")+TMP->ZFI_FORNEC+TMP->ZFI_LOJA+TMP->ZFI_DOC,"F1_VALBRUT"),"0")
	TMP->(DBCLOSEAREA())
	RestArea(aArea)
Return aRet
//Validação dos campos ZFF_HREMB e ZFF_HRDESE
User Function FAT04HR()
	Local oModel		:= FWModelActive()
	Local oStruct 		:= oModel:GetModel("ZFFMASTER")
	Local lRet 			:= .T.
	Local cCampo 		:= SubStr(ReadVar(),4,len(ReadVar()))
	Local cHora			:= &(ReadVar())
	
	IF Left(cHora,2)>='00' .And. Left(cHora,2)<='24' .And. Right(cHora,2)>='00' .And. Right(cHora,2)<='59'
		if Left(cHora,2)<='24' .and. Right(cHora,2)=='00'
			if cCampo == "ZFF_HRDESE"
				IF oStruct:GetValue("ZFF_DATA") == oStruct:GetValue("ZFF_DTDESE")
					if Left(cHora,2) < Left(oStruct:GetValue("ZFF_HREMB"),2) // hora de Embarque maior que o desembarque com data no mesmo dia
						lRet := .F.
					elseif Left(cHora,2) == Left(oStruct:GetValue("ZFF_HREMB"),2) .and. Right(cHora,2) <= Right(oStruct:GetValue("ZFF_HREMB"),2) // hora de desembarque maior que o Embarque com data no mesmo dia
						lRet := .F.
					ENDIF
				ENDIF
			ELSEIF cCampo == "ZFF_HREMB"
				IF oStruct:GetValue("ZFF_DATA") == oStruct:GetValue("ZFF_DTDESE")
					if Left(cHora,2) > Left(oStruct:GetValue("ZFF_HRDESE"),2) // hora de Embarque maior que o desembarque com data no mesmo dia
						lRet := .F.
					elseif Left(cHora,2) == Left(oStruct:GetValue("ZFF_HRDESE"),2) .and. Right(cHora,2) >= Right(oStruct:GetValue("ZFF_HRDESE"),2) // hora de Embarque maior que o desembarque com data no mesmo dia
						lRet := .F.
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	else
		lRet := .F.
	endif
Return lRet
User Function FATI04S()
	Local oModel		:= FWModelActive()
	Local oStruct		:= oModel:GetModel("ZFFMASTER")
	Local oGrid			:= oModel:GetModel("FORMGridM")
	Local nOpc			:= oModel:GetOperation()
	Local lRet 			:= .T.
	Local nI

	if oStruct:GetValue("ZFF_EMPE") +;
		oStruct:GetValue("ZFF_CAIDOS") +;
		oStruct:GetValue("ZFF_EMERGE") +;
		oStruct:GetValue("ZFF_MORTO") != oStruct:GetValue("ZFF_QTDE")
		
		oModel:SetErrorMessage("","","","","Quantidade Inválida", 'Quantidade de desembarque não corresponde a quantidade total do embarque.', "") 
		lRet := .F.
	else
		if nOpc == 3 .or. nOpc == 4 // ALTERAÇÃO E EXCLUSÃO.
			//if oStruct:VldData()
				//RecLock("ZFF", lRecLock := !DBSeek(FWxFilial("ZFF") + oStruct:GetValue("ZFF_CODIGO")))
/* 					ZFF->ZFF_FILIAL	:= FWxFilial("ZFF")
					ZFF->ZFF_CODIGO	:= oStruct:GetValue("ZFF_CODIGO")
					ZFF->ZFF_PLCVL 	:= oStruct:GetValue("ZFF_PLCVL")
					ZFF->ZFF_ICTA1 	:= oStruct:GetValue("ZFF_ICTA1")
					ZFF->ZFF_PLCC1 	:= oStruct:GetValue("ZFF_PLCC1")
					ZFF->ZFF_ICTA2 	:= oStruct:GetValue("ZFF_ICTA2")
					ZFF->ZFF_PLCC2 	:= oStruct:GetValue("ZFF_PLCC2")
					ZFF->ZFF_ICTA3 	:= oStruct:GetValue("ZFF_ICTA3")
					ZFF->ZFF_NUMMIN	:= oStruct:GetValue("ZFF_NUMMIN")
					ZFF->ZFF_MOTOR 	:= oStruct:GetValue("ZFF_MOTOR")
					ZFF->ZFF_FORNEC	:= oStruct:GetValue("ZFF_FORNEC")
					ZFF->ZFF_FLOJA	:= oStruct:GetValue("ZFF_FLOJA")
					ZFF->ZFF_ORIGEM	:= oStruct:GetValue("ZFF_ORIGEM")
					ZFF->ZFF_RLOJA 	:= oStruct:GetValue("ZFF_RLOJA")
					ZFF->ZFF_DESTIN	:= oStruct:GetValue("ZFF_DESTIN")
					ZFF->ZFF_DLOJA 	:= oStruct:GetValue("ZFF_DLOJA")
					ZFF->ZFF_MUN   	:= oStruct:GetValue("ZFF_MUN")
					ZFF->ZFF_DATA  	:= oStruct:GetValue("ZFF_DATA")
					ZFF->ZFF_HREMB 	:= oStruct:GetValue("ZFF_HREMB")
					ZFF->ZFF_DTDESE	:= oStruct:GetValue("ZFF_DTDESE")
					ZFF->ZFF_HRDESE	:= oStruct:GetValue("ZFF_HRDESE")
					ZFF->ZFF_KM    	:= oStruct:GetValue("ZFF_KM")
					ZFF->ZFF_VLKM  	:= oStruct:GetValue("ZFF_VLKM")
					ZFF->ZFF_VFRETE	:= oStruct:GetValue("ZFF_VFRETE")
					ZFF->ZFF_PEDAGI	:= oStruct:GetValue("ZFF_PEDAGI")
					ZFF->ZFF_VCOMP  := oStruct:GetValue("ZFF_VCOMP")
					ZFF->ZFF_ICMSF 	:= oStruct:GetValue("ZFF_ICMSF") */

					DBSELECTAREA( "ZFI" )
					DBSETORDER( 2 )
					//ZFI_FILIAL+ZFI_CODIGO+ZFI_ITEM
					For nI := 1 to oGrid:GetQtdLine()
						oGrid:GoLine(nI)

						IF oGrid:IsDeleted()
							if ZFI->(DBSeek(FWxFilial("ZFI") + oStruct:GetValue("ZFF_CODIGO") + oGrid:GetValue("CBC_ITEM")))
								ZFI->(RECLOCK('ZFI',.F.))
									ZFI->(DbDelete())
								ZFI->(MSUNLOCK())
							endif
						elseif !EMPTY(oGrid:GetValue("CBC_DOC"))
							RecLock("ZFI", lRecLock := !DBSeek(FWxFilial("ZFI") + oStruct:GetValue("ZFF_CODIGO") + oGrid:GetValue("CBC_ITEM") ))
								ZFI->ZFI_FILIAL := FwXFilial("ZFI")
								ZFI->ZFI_CODIGO := oStruct:GetValue("ZFF_CODIGO")
								ZFI->ZFI_ITEM   := oGrid:GetValue("CBC_ITEM")
								ZFI->ZFI_DOC 	:= oGrid:GetValue("CBC_DOC")
								ZFI->ZFI_SERIE  := oGrid:GetValue("CBC_SERIE")
								ZFI->ZFI_PLACA  := oStruct:GetValue("ZFF_PLCVL")
								ZFI->ZFI_FORNEC := oGrid:GetValue("CBC_FORNEC")
								ZFI->ZFI_LOJA  	:= oGrid:GetValue("CBC_LOJA")
							ZFI->( MsUnlock() )
						endif 
						
					Next nI
					
					ZFI->(DBCLOSEAREA(  ))		
					/* ZFF->ZFF_NCTE  	:= cCte */
					/* ZFF->ZFF_SCTE  	:= cSerie */
/* 					ZFF->ZFF_BOIS  	:= oStruct:GetValue("ZFF_BOIS")
					ZFF->ZFF_BUFALO	:= oStruct:GetValue("ZFF_BUFALO")
					ZFF->ZFF_VACAS 	:= oStruct:GetValue("ZFF_VACAS")
					ZFF->ZFF_TOURO 	:= oStruct:GetValue("ZFF_TOURO")
					ZFF->ZFF_NOVILH	:= oStruct:GetValue("ZFF_NOVILH")
					ZFF->ZFF_EMPE  	:= oStruct:GetValue("ZFF_EMPE")
					ZFF->ZFF_CAIDOS	:= oStruct:GetValue("ZFF_CAIDOS")
					ZFF->ZFF_EMERGE	:= oStruct:GetValue("ZFF_EMERGE")
					ZFF->ZFF_QTDE  	:= oStruct:GetValue("ZFF_QTDE")
					ZFF->ZFF_OBS   	:= oStruct:GetValue("ZFF_OBS")
					ZFF->ZFF_MORTO 	:= oStruct:GetValue("ZFF_MORTO") */
				//MsUnlock()
			//endif	
		elseif nOpc == 5 //DELETE

			DBSELECTAREA( "ZFI" )
			DBSETORDER( 2 )
			For nI := 1 to oGrid:GetQtdLine()
				oGrid:GoLine(nI)
				if ZFI->(DBSeek(FWxFilial("ZFI") + oStruct:GetValue("ZFF_CODIGO") + oGrid:GetValue("CBC_ITEM")))
					ZFI->(RECLOCK('ZFI',.F.))
						ZFI->(DbDelete())
					ZFI->(MSUNLOCK())
				endif
			Next nI
			ZFI->(DBCLOSEAREA())

/* 			if ZFF->(DBSeek(FWxFilial("ZFF") + oStruct:GetValue("ZFF_CODIGO")))
				ZFF->(RECLOCK('ZFF',.F.))
					ZFF->(DbDelete())
				ZFF->(MSUNLOCK())
			endif */
		endif
	endif
Return lRet
//Quantidade Embarque
User Function ATI04QT()
	Local oModel		:= FWModelActive()
	Local oStruct		:= oModel:GetModel("ZFFMASTER")
	Local lRet 			:= .T.

	if &(ReadVar()) >= 0
		oStruct:SetValue("ZFF_QTDE",;
			oStruct:GetValue("ZFF_BOIS")  +;
			oStruct:GetValue("ZFF_VACAS") +;
			oStruct:GetValue("ZFF_BUFALO")+;
			oStruct:GetValue("ZFF_TOURO") +;
			oStruct:GetValue("ZFF_NOVILH"))
	else
		lRet := .F.
	endif
Return lRet
//Gatilho para preencher campos do frete, pega os dados do ultimo frete da placa informada e preenche os campos
User Function I04PLC()
	Local oModel	:= FWModelActive()
	Local oStruct	:= oModel:GetModel("ZFFMASTER")
	Local aArea 	:= GetArea()
	Local cQry  	:= ''
	Local cRet 		:= ''

	cQry := " SELECT TOP 1 " +CRLF
	cQry += " * FROM "+RetSqlName("ZFF")+"" +CRLF
	cQry += " WHERE ZFF_PLCVL = '"+ALLTRIM(oStruct:GetValue("ZFF_PLCVL"))+"' " +CRLF
	cQry += " AND D_E_L_E_T_ = '' " +CRLF
	cQry += " ORDER BY ZFF_PLCVL DESC " +CRLF

	mpSysOpenQuery(cQry,"TMP")

	if !TMP->(EOF())
		cRet := TMP->ZFF_PLCC1
		//oStruct:SetValue("ZFF_PLCC1"  ,TMP->ZFF_PLCC1)
		oStruct:SetValue("ZFF_PLCC2"  ,TMP->ZFF_PLCC2)
		oStruct:SetValue("ZFF_MOTOR " ,TMP->ZFF_MOTOR)
		oStruct:SetValue("ZFF_ORIGEM" ,TMP->ZFF_ORIGEM)
		oStruct:SetValue("ZFF_MUN"	  ,TMP->ZFF_MUN   )
	endif

	TMP->(DBCLOSEAREA())
	RestArea(aArea)
Return cRet
//Gatilho para CTE e Valores
User Function I04CTE()
	Local aArea 	:= GetArea()
	Local oModel	:= FWModelActive()
	Local oGrid 	:= oModel:GetModel("FORMGridM")
	Local nRet 		:= 0
	Local cCte  	:= StrZero( Val(&(ReadVar())),TamSx3("F1_DOC")[1])
	//F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC

	DBSELECTAREA( "SF1" )
	DBSETORDER( 2 )

	if DbSeek(FwxFilial("SF1")+;
		AllTrim(oGrid:GetValue("CBC_FORNEC"))+;
		AllTrim(oGrid:GetValue("CBC_LOJA"))+;
		cCte )
		
		nRet := SF1->F1_VALBRUT

		oGrid:SetValue("CBC_SERIE" ,SF1->F1_SERIE)
		oGrid:SetValue("CBC_VALOR" ,SF1->F1_VALBRUT)
		oGrid:LoadValue("CBC_DOC"  ,cCte)
	else
	oModel:SetErrorMessage("","","","","Valor Invalido", 'CTE não existe para esse fornecedor!', "") 
	EndIf

	SF1->(DBCLOSEAREA())

	RestArea(aArea)
Return nRet
/* Iniciador para o campo CBC_FORNEC, CBC_LOJA E CBC_NOME na estrutura da GRID */
User Function I04IFOR()
	Local oModel		:= FWModelActive()
	Local oStruct 		:= oModel:GetModel("ZFFMASTER")
	Local oGrid 		:= oModel:GetModel("FORMGridM")
	Local cRet 			:= ""
	Local cCampo 		:= ReadVar()
	
	
	if oGrid:GetQtdLine() == 0
		if !EMPTY(oStruct:GetValue("ZFF_FORNEC"))
			IF cCampo == 'CBC_FORNEC'	
				cRet := oStruct:GetValue("ZFF_FORNEC")
			elseif cCampo == 'CBC_LOJA'
				cRet := oStruct:GetValue("ZFF_FLOJA")
			else
				cRet := POSICIONE("SA2",1, FwXFilial("SA2")+oStruct:GetValue("ZFF_FORNEC")+oStruct:GetValue("ZFF_FLOJA "),"A2_NOME")
			endif
		endif
	else
		IF cCampo == 'CBC_FORNEC'	
			cRet := oGrid:GetValue("CBC_FORNEC")
		elseif cCampo == 'CBC_LOJA'
			cRet := oGrid:GetValue("CBC_LOJA")
		else
			cRet := POSICIONE("SA2",1, FwXFilial("SA2")+oGrid:GetValue("CBC_FORNEC")+oGrid:GetValue("CBC_LOJA"),"A2_NOME")
		endif 
	endif 

Return cRet
/* Incrementador para o campo item na grid */
User Function I04INC()
	Local oModel	:= FWModelActive()
	Local oGrid 	:= oModel:GetModel("FORMGridM")
	Local cRet 		:= ""
	Local aSaveLines 	:= FWSaveRows()	

	if oGrid:GetQtdLine() == 0
		cRet := StrZero(oGrid:GetQtdLine() + 1,2)
	else 
		cRet := StrZero(Val(oGrid:GetValue("CBC_ITEM"))+1,2)
	endif 
	FWRestRows( aSaveLines )
Return cRet := StrZero(oGrid:GetQtdLine() + 1,2)

/* Remover zeros a esquerda */
User Function zTiraZeros(cTexto)
    Local aArea     := GetArea()
    Local cRetorno  := ""
    Local lContinua := .T.
    Default cTexto  := ""
 
    //Pegando o texto atual
    cRetorno := Alltrim(cTexto)
 
    //Enquanto existir zeros a esquerda
    While lContinua
        //Se a priemira posição for diferente de 0 ou não existir mais texto de retorno, encerra o laço
        If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0
            lContinua := .f.
        EndIf
         
        //Se for continuar o processo, pega da próxima posição até o fim
        If lContinua
            cRetorno := Substr(cRetorno, 2, Len(cRetorno))
        EndIf
    EndDo
     
    RestArea(aArea)
Return cRetorno

User Function I04VMIN()
	Local aArea 	:= GetArea()
	Local oModel	:= FWModelActive()
	Local oStruct	:= oModel:GetModel("ZFFMASTER")
	Local cQry 		:= ""
	Local lRet 		:= .T.
	
	cQry := "SELECT *  " + CRLF
	cQry += " FROM "+RetSqlName("ZFF")+" " + CRLF
	cQry += " WHERE ZFF_FILIAL = '"+FWxFilial("ZFF")+"' " + CRLF
	cQry += " AND ZFF_NUMMIN = '"+oStruct:GetValue("ZFF_NUMMIN")+"' " + CRLF
	cQry += " AND D_E_L_E_T_ = '' " + CRLF

	mpSysOpenQuery(cQry,"TMP")

	IF !TMP->(EOF())
		lRet := .F.
		oModel:SetErrorMessage("","","","","Valor Inválido", 'Minuta já está cadastrada no código: ' + TMP->ZFF_CODIGO + ', Para a placa: ' + TMP->ZFF_PLCVL, "") 
	ENDIF 

	TMP->(DBCLOSEAREA())
	RestArea(aArea)
Return lRet
//VIncular CTEs á fretes já cadastrados
/* Static Function VinculaFrete()
	Local aArea			:= GetArea()
	Local oDlg, oLbx
    Local aCpos  		:= {}
    Local aRet   		:= {}
    Local _cQry  		:= ""
    Local lRet   		:= .F.
	Local oModel		:= FWModelActive()
	Local oStruct		:= oModel:GetModel("ZFFMASTER")
	Local oGrid 		:= oModel:GetModel("FORMGridM")

	_cQry := "  SELECT ZFF_CODIGO " + CRLF
	_cQry += " 	,   ZFF_ORIGEM " + CRLF
	_cQry += " 	,   ZFF_RLOJA " + CRLF
	_cQry += " 	,	ZFF_PLCVL " + CRLF
	_cQry += " 	,	ZFF_DTDESE " + CRLF
	_cQry += " FROM "+RetSqlName("ZFF")+" ZFF " + CRLF
	_cQry += " LEFT JOIN "+RetSqlName("ZFI")+" ZFI ON ZFF_FILIAL = ZFI_FILIAL  " + CRLF
	_cQry += " AND ZFF_CODIGO = ZFI_CODIGO " + CRLF
	_cQry += " AND ZFI.D_E_L_E_T_ = '' " + CRLF
	_cQry += " WHERE ZFF_FILIAL = '"+FWxFilial("ZFF")+"' " + CRLF
	_cQry += " AND ZFF_ORIGEM = '"+oStruct:GetValue("ZFF_ORIGEM")+"' " + CRLF
	_cQry += " AND ZFF_RLOJA  = '"+oStruct:GetValue("ZFF_RLOJA")+"' " + CRLF
	_cQry += " AND ZFF.D_E_L_E_T_ = '' " + CRLF
	_cQry += " ORDER BY 5 DESC  " + CRLF

	mpSysOpenQuery(_cQry,"TMP")

	While !TMP->(EOF())
        aAdd(aCpos,{TMP->ZFF_CODIGO,;
				    TMP->ZFF_ORIGEM,;
				    TMP->ZFF_RLOJA,;
				    Posicione("SA2",1,FWxFilial("SA2"+oStruct:GetValue("ZFF_ORIGEM")+oStruct:GetValue("ZFF_RLOJA"),"A2_NOME")),;
				    TMP->ZFF_PLCVL,;
					TMP->ZFF_DTDESE})
        TMP->(dbSkip())
    End
    TMP->(dbCloseArea())

	fMontaTela(aCpos)

	IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
	    MemoWrite(StrTran(cArquivo,".xml","")+"SR4_"+cValToChar(dDataBase)+".sql" , _cQry)
    ENDIF

//	oView:Refresh()
	RestArea(aArea)
Return */
/* Gatilho para o campo loja do Fornecedor */  
User Function I04FORN()
	Local oModel	:= FWModelActive()
	Local oStruct	:= oModel:GetModel("ZFFMASTER")
	Local oGrid 	:= oModel:GetModel("FORMGridM")
	Local cRet 		:= ''

	cRet := Posicione("SA2",1,FwXFilial("SA2")+oStruct:GetValue("ZFF_FORNEC")+oStruct:GetValue("ZFF_RLOJA"),"A2_NOME")

	if oGrid:GetQtdLine() == 1
		if EMPTY(oGrid:GetValue("CBC_DOC"))
			oGrid:SetValue("CBC_FORNEC"	,oStruct:GetValue("ZFF_FORNEC"))
			oGrid:SetValue("CBC_LOJA"	,oStruct:GetValue("ZFF_RLOJA"))
			oGrid:SetValue("CBC_NOME"	,cRet)
		endif 
	endif 
	
Return  cRet
