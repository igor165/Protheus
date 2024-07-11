#INCLUDE 'PROTHEUS.CH'
#include "fwmvcdef.ch"

Static cTitulo := "Projeção de consumo dieta confinamento"

User Function LVFATI01()
    Local aArea   		:= FwGetArea()
    Local oModel  		:= NIL
	Local cFunBkp 		:= FunName()  
    
    SetFunName("LVFATI01")
	
    oModel := FWMBrowse():New()
	oModel:SetAlias( "ZEF" )
	oModel:SetDescription( cTitulo )
	oModel:Activate()
	
    SetFunName(cFunBkp)
	FwRestArea(aArea)
Return 

Static Function MenuDef()
	Local aRot := {}
	
	ADD OPTION aRot TITLE 'Visualizar' 		ACTION 'VIEWDEF.LVFATI01' 			OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    		ACTION 'VIEWDEF.LVFATI01' 			OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    		ACTION 'VIEWDEF.LVFATI01' 			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    		ACTION 'VIEWDEF.LVFATI01' 			OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot


Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStrCab   := FWFormStruct(1, 'ZEF')
	Local oStrGrid  := FWFormStruct(1, 'ZEG')
	Local oStrTot  	:= FWFormStruct(1, 'Total')
	Local aZEGRel	:= {}
	Local aAux		:= {}
	Local nI

	oStrTot 	:= GetModelCabec(oModel, oStrTot)

	aAdd(aAux, FwStruTrigger("ZEF_PESOKG" 	,"ZEF_PESOAR","&(ReadVar()) / 30 "												,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_GMD" 		,"ZEF_PESOF" ,"M->ZEF_PESOKG + (M->ZEF_PERIOD * &(ReadVar()) )"					,.F. ,"",0,"" ,NIL, "01" ))
	//aAdd(aAux, FwStruTrigger("ZEF_PESOF" 	,"ZEF_PESOFC","(&(ReadVar()) * M->ZEF_RENDIM) / 100 / 15"						,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_RENDIM" 	,"ZEF_PESOFC","(&(ReadVar()) * M->ZEF_PESOF) / 100 / 15"						,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_PESOFC" 	,"ZEF_QTDARR","&(ReadVar()) - M->ZEF_PESOAR"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_CUSCAB" 	,"ZEF_CUSOPA","&(ReadVar()) + M->ZEF_COPCAB"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_COPCAB" 	,"ZEF_CUSOPA","&(ReadVar()) + M->ZEF_CUSCAB"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_CUSOPA" 	,"ZEF_CUSTOA","&(ReadVar()) * (M->ZEF_PERIOD / M->ZEF_QTDARR )"					,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_VLRENT" 	,"ZEF_VLRCEN","&(ReadVar()) * M->ZEF_PESOAR"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_VLRVEN" 	,"ZEF_RECEIT","&(ReadVar()) * M->ZEF_PESOFC"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_VLRCEN" 	,"ZEF_DESTOT","M->ZEF_VLRALI + &(ReadVar()) + (M->ZEF_COPCAB * M->ZEF_PERIOD)"	,.F. ,"",0,"" ,NIL, "02" ))
	aAdd(aAux, FwStruTrigger("ZEF_RECLIQ" 	,"ZEF_RECTOT","&(ReadVar()) * M->ZEF_NUMANI"									,.F. ,"",0,"" ,NIL, "01" ))

	For nI := 1 to Len(aAux)
		oStrCab:AddTrigger(aAux[nI,1], aAux[nI,2], aAux[nI,3], aAux[nI,4])
	next nI

	aAux := {}

	aadd(aAux, FwStruTrigger("ZEG_KGDIA" 	,"ZEG_KGTOTA","U_I01KTOT()"													,.F. ,"",0,"" ,NIL, "01" ))
	aadd(aAux, FwStruTrigger("ZEG_KGDIA" 	,"ZEG_VLRDIA","&(ReadVar()) * M->ZEG_VLRUNI"								,.F. ,"",0,"" ,NIL, "02" ))
	aadd(aAux, FwStruTrigger("ZEG_VLRUNI" 	,"ZEG_VLRTOT","&(ReadVar()) * M->ZEG_KGTOTA"								,.F. ,"",0,"" ,NIL, "01" ))
	aadd(aAux, FwStruTrigger("ZEG_VLRUNI" 	,"ZEG_VLRDIA","U_I01VTOT()"													,.F. ,"",0,"" ,NIL, "02" ))
	aadd(aAux, FwStruTrigger("ZEG_VLRDIA" 	,"ZEG_VLRUNI","U_I01VLR()"													,.F. ,"",0,"" ,NIL, "02" ))
	aadd(aAux, FwStruTrigger("ZEG_PRODUT" 	,"ZEG_DESC"  ,"Posicione('SB1',1,FwXFilial('SB1')+ &(ReadVar()), 'B1_DESC')",.F. ,"",0,"" ,NIL, "02" ))

	For nI := 1 to Len(aAux)
		oStrGrid:AddTrigger(aAux[nI,1], aAux[nI,2], aAux[nI,3], aAux[nI,4])
	next nI

	oStrCab:SetProperty('ZEF_NUMANI', MODEL_FIELD_OBRIGAT, .T.) 
	oStrCab:SetProperty('ZEF_PERIOD', MODEL_FIELD_OBRIGAT, .T.) 
	oStrCab:SetProperty('ZEF_PESOKG', MODEL_FIELD_OBRIGAT, .T.) 
	oStrCab:SetProperty('ZEF_GMD'	, MODEL_FIELD_OBRIGAT, .T.) 
	oStrCab:SetProperty('ZEF_RENDIM', MODEL_FIELD_OBRIGAT, .T.) 
	oStrCab:SetProperty('ZEF_VLRVEN', MODEL_FIELD_OBRIGAT, .T.) 
	oStrCab:SetProperty('ZEF_VLRENT', MODEL_FIELD_OBRIGAT, .T.) 
	oStrCab:SetProperty('ZEF_COPCAB', MODEL_FIELD_OBRIGAT, .T.) 
	
	oStrCab:SetProperty('ZEF_CODIGO', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(INCLUI,GETSX8NUM("ZEF","ZEF_CODIGO"),ZEF->ZEF_CODIGO)')) //Inicializador Padrão
	oStrCab:SetProperty('ZEF_DATA'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(INCLUI,Date(),ZEF->ZEF_DATA)')) //Inicializador Padrão
	
	oStrCab:SetProperty('ZEF_PESOAR', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
    oStrCab:SetProperty('ZEF_PESOF'	, MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
    oStrCab:SetProperty('ZEF_PESOFC', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
    oStrCab:SetProperty('ZEF_QTDARR', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
    oStrCab:SetProperty('ZEF_CUSTOA', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
    oStrCab:SetProperty('ZEF_CUSCAB', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
    oStrCab:SetProperty('ZEF_CUSOPA', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
    oStrCab:SetProperty('ZEF_VLRCEN', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
    oStrCab:SetProperty('ZEF_VLRALI', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
    oStrCab:SetProperty('ZEF_RECEIT', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
    oStrCab:SetProperty('ZEF_DESTOT', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
    oStrCab:SetProperty('ZEF_RECLIQ', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
    oStrCab:SetProperty('ZEF_RECTOT', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
    
	oStrGrid:SetProperty('ZEG_PRODUT', MODEL_FIELD_OBRIGAT, .T.) 
	oStrGrid:SetProperty('ZEG_KGDIA' , MODEL_FIELD_OBRIGAT, .T.) 
	oStrGrid:SetProperty('ZEG_VLRUNI', MODEL_FIELD_OBRIGAT, .T.) 
	
	oStrGrid:SetProperty('ZEG_DESC'   , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "Posicione('SB1',1,FwXFilial('SB1')+ ZEG->ZEG_PRODUT, 'B1_DESC')")) //Inicializador Padrão
	
	oStrGrid:SetProperty('ZEG_DESC'	 , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
	oStrGrid:SetProperty('ZEG_KGTOTA', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
	oStrGrid:SetProperty('ZEG_VLRDIA', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
	oStrGrid:SetProperty('ZEG_VLRTOT', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
	
	oStrGrid:SetProperty('ZEG_PRODUT', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'ExistCpo("SB1") .and. U_I01VldP()')) //Modo de Edição
	
	//Criando o FormModel, adicionando o CabeÃƒÂ§alho e Grid
	oModel := MPFormModel():New("FATI01",/* bVldPre */, /* bVldPos */ /*Pos-Validacao*/, /* bVldCom */ /*Commit*/,/*Cancel*/)

	oModel:AddFields("ZEFMASTER",/*cOwner*/ ,oStrCab  )
	oModel:AddGrid('ZEGDETAIL','ZEFMASTER',oStrGrid,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner ÃƒÂ© para quem pertence
	oModel:AddGrid('TOTDETAIL','ZEFMASTER',oStrTot,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner ÃƒÂ© para quem pertence

    aAdd(aZEGRel, {'ZEG_FILIAL', 'ZEF_FILIAL' } )
	aAdd(aZEGRel, {'ZEG_CODIGO', 'ZEF_CODIGO' } )	

//   aAdd(aZEGRel, {'ZEG_FILIAL', 'Iif(!INCLUI, ZEF->ZEF_FILIAL   , M->ZEF_FILIAL)' } )
//	aAdd(aZEGRel, {'ZEG_CODIGO', 'Iif(!INCLUI, ZEF->ZEF_CODIGO   , M->ZEF_CODIGO)' } )

    oModel:SetRelation('ZEGDETAIL', aZEGRel, ZEG->(IndexKey(2))) //IndexKey -> quero a ordenaÃ§Ã£o e depois filtrado
	oModel:GetModel('ZEGDETAIL'):SetUniqueLine({"ZEG_FILIAL","ZEG_CODIGO","ZEG_ITEM"})	//NÃ£o repetir informaÃ§Ãµes ou combinaÃ§Ãµes {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})

	oModel:GetModel('TOTDETAIL'):SetOptional(.T.)
	oModel:GetModel('TOTDETAIL'):SetNoDeleteLine(.T.)

	//Setando outras informaÃƒÂ§ÃƒÂµes do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:GetModel("ZEFMASTER"):SetDescription("Dados da "+cTitulo)
	oModel:GetModel("ZEGDETAIL"):SetDescription("Grid da  "+cTitulo)
	oModel:GetModel("TOTDETAIL"):SetDescription("Total da "+cTitulo)
	
Return oModel

Static Function ViewDef()
	Local oModel    := FWLoadModel("LVFATI01")
	Local oStrCab   := FWFormStruct(2, 'ZEF')
	Local oStrGrid  := FWFormStruct(2, 'ZEG')
	Local oStrTot  	:= FWFormStruct(2, 'Total')
	Local oView     := FWFormView():New()

	oStrTot := GetViewCabec(oModel,oStrTot)

	oStrGrid:SetProperty('ZEG_PRODUT', MVC_VIEW_LOOKUP , 'SB1') //Título do campo
 
    //oModel :=
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZEF" , oStrCab  , "ZEFMASTER")
	oView:AddGrid('VIEW_ZEG' , oStrGrid , 'ZEGDETAIL')
	oView:AddGrid('VIEW_TOT' , oStrTot , 'TOTDETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('BOX_CAB'	, 50)
	oView:CreateHorizontalBox('BOX_GRID', 35)
	oView:CreateHorizontalBox('BOX_TOT'	, 15)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZEF'  	,'BOX_CAB'	)
	oView:SetOwnerView('VIEW_ZEG'  	,'BOX_GRID'	)
	oView:SetOwnerView('VIEW_TOT'  	,'BOX_TOT'	)

	oView:SetCloseOnOk( { |oView| .T. } )

	oView:AddIncrementField( 'VIEW_ZEG', 'ZEG_ITEM' )

    oView:EnableTitleView('VIEW_ZEF', 'Indicadores') 
    oView:EnableTitleView('VIEW_ZEG', 'Insumos') 
    oView:EnableTitleView('VIEW_TOT', 'Total') 

Return oView

User Function FATI01()
	Local aParam 		:= PARAMIXB
	Local xRet 			:= .T.
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local cIdIXB5		:= ''
	Local cIdIXB4		:= ''
	Local oModel 	 	:= nil
	Local oCab			:= nil
	Local oGrid 		:= nil
	Local aSaveLines 	:= FWSaveRows()
	Local nOpc, nI 
	Local nLinAtu,nLines
	Local nKgDia := nKgTot := nVlrDia := nVlrTot := 0
	
	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		if len(aParam) >= 4
			cIdIXB4  := aParam[4]
		endif 

		if len(aParam) >= 5
			cIdIXB5  := aParam[5]
		endif 

		if Alltrim(cIdPonto) == "FORMPRE" .and. cIdModel == 'ZEGDETAIL' .AND. cIdIXB5 == 'DELETE' 
			oModel 	 	:= FwModelActivate()
			oCab 		:= oModel:GetModel("ZEFMASTER")
			oGrid 		:= oModel:GetModel("ZEGDETAIL")
			oTot 		:= oModel:GetModel("TOTDETAIL")
			nOpc 		:= oGrid:GetOperation()
			nLines 		:= oGrid:GetQtdLine()
			nLinAtu		:= oGrid:GetLine()

			For nI := 1 to nLines
				oGrid:GoLine(nI)
				IF nLinAtu != nI
					If !oGrid:isDeleted()
						nKgDia 	+= oGrid:GetValue("ZEG_KGDIA")
						nKgTot 	+= oGrid:GetValue("ZEG_KGTOTA")
						nVlrDia += oGrid:GetValue("ZEG_VLRDIA")
						nVlrTot += oGrid:GetValue("ZEG_VLRTOT")
					endif
				endif
			Next nI 

			oTot:GoLine(1)
			oTot:LoadValue("TOT_KGDIA" , nKgDia  )
			oTot:LoadValue("TOT_KGTOTA", nKgTot  )
			oTot:LoadValue("TOT_VLRDIA", nVlrDia )
			oTot:LoadValue("TOT_VLRTOT", nVlrTot )

			IF nVlrDia > 0
				oCab:LoadValue("ZEF_CUSCAB",nVlrDia)
	
				oCab:LoadValue("ZEF_CUSOPA",nVlrDia + oCab:GetValue("ZEF_COPCAB"))
				
				oCab:LoadValue("ZEF_CUSTOA",(nVlrDia + oCab:GetValue("ZEF_COPCAB")) * (oCab:GetValue("ZEF_PERIOD") / oCab:GetValue("ZEF_QTDARR")))
				
				oCab:LoadValue("ZEF_VLRALI",oCab:GetValue("ZEF_PERIOD") * nVlrDia)
				
				oCab:LoadValue("ZEF_DESTOT",(oCab:GetValue("ZEF_PERIOD") * nVlrDia) +;
											oCab:GetValue("ZEF_VLRCEN") +;
											(oCab:GetValue("ZEF_COPCAB") * oCab:GetValue("ZEF_PERIOD")))
				
				oCab:LoadValue("ZEF_RECLIQ",oCab:GetValue("ZEF_RECEIT") - oCab:GetValue("ZEF_DESTOT"))
				
				oCab:LoadValue("ZEF_RECTOT",oCab:GetValue("ZEF_RECLIQ") * oCab:GetValue("ZEF_NUMANI"))


			endIf
		elseif Alltrim(cIdPonto) == "FORMPRE" .and. cIdModel == 'ZEGDETAIL' .AND. cIdIXB5 == 'UNDELETE' 
			oModel 	 	:= FwModelActivate()
			oCab 		:= oModel:GetModel("ZEFMASTER")
			oGrid 		:= oModel:GetModel("ZEGDETAIL")
			oTot 		:= oModel:GetModel("TOTDETAIL")
			nOpc 		:= oGrid:GetOperation()
			nLines 		:= oGrid:GetQtdLine()
			nLinAtu		:= oGrid:GetLine()

			For nI := 1 to nLines
				oGrid:GoLine(nI)
				IF nLinAtu == nI
					nKgDia 	+= oGrid:GetValue("ZEG_KGDIA")
					nKgTot 	+= oGrid:GetValue("ZEG_KGTOTA")
					nVlrDia += oGrid:GetValue("ZEG_VLRDIA")
					nVlrTot += oGrid:GetValue("ZEG_VLRTOT")
				else
					If !oGrid:isDeleted()
						nKgDia 	+= oGrid:GetValue("ZEG_KGDIA")
						nKgTot 	+= oGrid:GetValue("ZEG_KGTOTA")
						nVlrDia += oGrid:GetValue("ZEG_VLRDIA")
						nVlrTot += oGrid:GetValue("ZEG_VLRTOT")
					endif
				endif
			Next nI 

			oTot:GoLine(1)
			oTot:LoadValue("TOT_KGDIA" , nKgDia  )
			oTot:LoadValue("TOT_KGTOTA", nKgTot  )
			oTot:LoadValue("TOT_VLRDIA", nVlrDia )
			oTot:LoadValue("TOT_VLRTOT", nVlrTot )

			IF nVlrDia > 0
				oCab:LoadValue("ZEF_CUSCAB",nVlrDia)
	
				oCab:LoadValue("ZEF_CUSOPA",nVlrDia + oCab:GetValue("ZEF_COPCAB"))
				
				oCab:LoadValue("ZEF_CUSTOA",(nVlrDia + oCab:GetValue("ZEF_COPCAB")) * (oCab:GetValue("ZEF_PERIOD") / oCab:GetValue("ZEF_QTDARR")))
				
				oCab:LoadValue("ZEF_VLRALI",oCab:GetValue("ZEF_PERIOD") * nVlrDia)
				
				oCab:LoadValue("ZEF_DESTOT",(oCab:GetValue("ZEF_PERIOD") * nVlrDia) +;
											oCab:GetValue("ZEF_VLRCEN") +;
											(oCab:GetValue("ZEF_COPCAB") * oCab:GetValue("ZEF_PERIOD")))
				
				oCab:LoadValue("ZEF_RECLIQ",oCab:GetValue("ZEF_RECEIT") - oCab:GetValue("ZEF_DESTOT"))
				
				oCab:LoadValue("ZEF_RECTOT",oCab:GetValue("ZEF_RECLIQ") * oCab:GetValue("ZEF_NUMANI"))


			endIf
		endif
	endif 
	FWRestRows( aSaveLines )
Return xRet
Static Function GetModelCabec(oModel,oStrTot)     
	oStrTot:AddField( 'Codigo' 		, 'Codigo' 		, 'TOT_CODIGO' 	, 'C' , TamSx3("ZEG_CODIGO")[1] ,TamSx3("ZEG_CODIGO")[2] 	,Nil,Nil,NIL,.F.,													,.F.,.T.)
	oStrTot:AddField( 'Item' 		, 'Item' 		, 'TOT_ITEM' 	, 'C' , TamSx3("ZEG_ITEM")[1] 	,TamSx3("ZEG_ITEM")[2]  	,Nil,Nil,NIL,.F.,													,.F.,.T.)
	oStrTot:AddField( 'Produto' 	, 'Produto' 	, 'TOT_PRODUT' 	, 'C' , TamSx3("ZEG_PRODUT")[1] ,TamSx3("ZEG_PRODUT")[2] 	,Nil,Nil,NIL,.F.,													,.F.,.T.)
	oStrTot:AddField( 'Produto' 	, 'Produto' 	, 'TOT_DESC' 	, 'C' , TamSx3("ZEG_DESC")[1] 	,TamSx3("ZEG_DESC")[2]  	,Nil,Nil,NIL,.F.,													,.F.,.T.)
	oStrTot:AddField( 'Kg/Cab/Dia' 	, 'Kg/Cab/Dia' 	, 'TOT_KGDIA' 	, 'N' , TamSx3("ZEG_KGDIA")[1]  ,TamSx3("ZEG_KGDIA")[2] 	,Nil,Nil,NIL,.F.,FwBuildFeature(STRUCT_FEATURE_INIPAD, "U_I01ITO()"),.F.,.T.)
	oStrTot:AddField( 'Kg Total' 	, 'Kg Total' 	, 'TOT_KGTOTA' 	, 'N' , TamSx3("ZEG_KGTOTA")[1] ,TamSx3("ZEG_KGTOTA")[2] 	,Nil,Nil,NIL,.F.,FwBuildFeature(STRUCT_FEATURE_INIPAD, "U_I01ITO()"),.F.,.T.)
	oStrTot:AddField( 'Vlr Unitario', 'Vlr Unitario', 'TOT_VLRUNI' 	, 'N' , TamSx3("ZEG_VLRUNI")[1] ,TamSx3("ZEG_VLRUNI")[2] 	,Nil,Nil,NIL,.F.,													,.F.,.T.)
	oStrTot:AddField( 'Vlr Dia' 	, 'Vlr Dia' 	, 'TOT_VLRDIA' 	, 'N' , TamSx3("ZEG_VLRDIA")[1] ,TamSx3("ZEG_VLRDIA")[2] 	,Nil,Nil,NIL,.F.,FwBuildFeature(STRUCT_FEATURE_INIPAD, "U_I01ITO()"),.F.,.T.)//FwBuildFeature(STRUCT_FEATURE_INIPAD, "U_I01ITO()")
	oStrTot:AddField( 'Vlr Total' 	, 'Vlr Total' 	, 'TOT_VLRTOT' 	, 'N' , TamSx3("ZEG_VLRTOT")[1] ,TamSx3("ZEG_VLRTOT")[2] 	,Nil,Nil,NIL,.F.,FwBuildFeature(STRUCT_FEATURE_INIPAD, "U_I01ITO()"),.F.,.T.)
Return oStrTot

Static Function GetViewCabec(oModel,oStrTot)
	oStrTot:AddField( 'TOT_CODIGO' 	, '1' , 'Codigo' 		, 'Codigo' 		,nil, 'C', 							,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_ITEM' 	, '2' , 'Item' 			, 'Item' 		,nil, 'C', 							,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_PRODUT' 	, '3' , 'Produto' 		, 'Produto' 	,nil, 'C', 							,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_DESC' 	, '4' , 'Produto' 		, 'Produto' 	,nil, 'C', 							,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_KGDIA' 	, '5' , 'Kg/Cab/Dia'	, 'Kg/Cab/Dia' 	,nil, 'N',X3Picture( "ZEG_KGDIA" ) 	,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_KGTOTA' 	, '6' , 'Kg Total'		, 'Kg Total'	,nil, 'N',X3Picture( "ZEG_KGTOTA" ) ,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_VLRUNI' 	, '7' , 'Vlr Unitario' 	, 'Vlr Unitario',nil, 'N', 							,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
   	oStrTot:AddField( 'TOT_VLRDIA' 	, '8' , 'Vlr Dia' 		, 'Vlr Dia' 	,nil, 'N',X3Picture( "ZEG_VLRDIA" ) ,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_VLRTOT' 	, '9' , 'Vlr Total' 	, 'Vlr Total' 	,nil, 'N',X3Picture( "ZEG_VLRTOT" ) ,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
Return oStrTot
//gatilho ZEG_KGDIA -> ZEG_KGTOTA
User Function I01KTOT()
	Local oModel 		:= FWModelActive()
	Local oCab		:= oModel:GetModel("ZEFMASTER") 
	Local oGrid		:= oModel:GetModel("ZEGDETAIL") 
	Local oTot		:= oModel:GetModel("TOTDETAIL") 
	Local nI 
	Local nLin 		:= oGrid:GetQtdLine()
	Local nLinAtu 	:= oGrid:GetLine()
	Local nKgDia 	:= nKgTot 	:= 0
	Local nRet 		:= &(ReadVar()) * oCab:GetValue("ZEF_PERIOD") * oCab:GetValue("ZEF_NUMANI")

	For nI := 1 to nLin
		oGrid:GoLine(nI)
		if !oGrid:isDeleted()
			nKgDia += oGrid:GetValue("ZEG_KGDIA")
			nKgTot += oGrid:GetValue("ZEG_KGTOTA")
		endif 
	next nI

	oTot:GoLine(1)
	oTot:LoadValue("TOT_KGDIA" ,nKgDia)
	oTot:LoadValue("TOT_KGTOTA",nKgTot)

	oGrid:GoLine(nLinAtu)
Return nRet
//gatilho ZEG_VLRUNI -> ZEG_VLRTOT
User Function I01VTOT()
	Local oModel 		:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZEGDETAIL") 
	Local oTot		:= oModel:GetModel("TOTDETAIL") 
	Local nI 
	Local nLin 		:= oGrid:GetQtdLine()
	Local nLinAtu 	:= oGrid:GetLine()
	Local nVlrDia 	:= nVlrTot 	:= 0
	Local nRet 		:= oGrid:GetValue("ZEG_VLRUNI")  * oGrid:GetValue("ZEG_KGDIA")

	For nI := 1 to nLin
		oGrid:GoLine(nI)
		if !oGrid:isDeleted()
			nVlrDia += oGrid:GetValue("ZEG_VLRDIA")
			nVlrTot += oGrid:GetValue("ZEG_VLRTOT")
		endIf
	next nI

	oTot:GoLine(1)
	oTot:LoadValue("TOT_KGDIA" ,nVlrDia)
	oTot:LoadValue("TOT_KGTOTA",nVlrTot)

	oGrid:GoLine(nLinAtu)
Return nRet

//gatilho ZEG_VLRUNI -> ZEG_VLRDIA
User Function I01ITO()
	Local oModel 	:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZEGDETAIL") 
	Local nI 
	Local cCampo	:= 'ZEG' + (Substr( ReadVar(), At('->', ReadVar())+5 ))
	Local nLin 		:= oGrid:GetQtdLine()
	Local nSoma 	:= 0

	For nI := 1 to nLIN
		nSoma += oGrid:GetValue(cCampo)
	Next nI

Return nSoma 

User Function I01VLR()
	Local oModel 	:= FWModelActive()
	Local oCab		:= oModel:GetModel("ZEFMASTER") 
	Local oGrid		:= oModel:GetModel("ZEGDETAIL") 
	Local nRet 		:= oGrid:GetValue("ZEG_VLRUNI") // ALTERAR PARA 4 
	Local nI 
	Local nLinAtu	:= oGrid:GetLine()
	Local nLin		:= oGrid:GetQtdLine()
	Local nSum		:= 0
	
	For nI := 1 to nLin
		oGrid:GoLine(nI)
		if !oGrid:isDeleted()
			nSum += oGrid:GetValue("ZEG_VLRDIA")
		endif
	Next nI

	if nSum > 0 
		oCab:LoadValue("ZEF_CUSCAB",nSum)
		
		oCab:LoadValue("ZEF_CUSOPA",nSum + oCab:GetValue("ZEF_COPCAB"))
		
		oCab:LoadValue("ZEF_CUSTOA",(nSum + oCab:GetValue("ZEF_COPCAB")) * (oCab:GetValue("ZEF_PERIOD") / oCab:GetValue("ZEF_QTDARR")))
		
		oCab:LoadValue("ZEF_VLRALI",oCab:GetValue("ZEF_PERIOD") * nSum)
		
		oCab:LoadValue("ZEF_DESTOT",(oCab:GetValue("ZEF_PERIOD") * nSum) +;
									 oCab:GetValue("ZEF_VLRCEN") +;
									 (oCab:GetValue("ZEF_COPCAB") * oCab:GetValue("ZEF_PERIOD")))
		
		oCab:LoadValue("ZEF_RECLIQ",oCab:GetValue("ZEF_RECEIT") - oCab:GetValue("ZEF_DESTOT"))
		
		oCab:LoadValue("ZEF_RECTOT",oCab:GetValue("ZEF_RECLIQ") * oCab:GetValue("ZEF_NUMANI"))

	endif 

	oGrid:GoLine(nLinAtu)

Return nRet

User Function I01VldP()
	Local oModel 	:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZEGDETAIL") 
	Local nLine 	:= oGrid:GetLine()
	Local nLinTot	:= oGrid:GetQtdLine()
	Local nI 
	Local cProduto 	:= &(ReadVar())
	Local lRet 		:= .T. 

	For nI := 1 to nLinTot
		if nI != nLine 
			oGrid:GoLine(nI)
			if !oGrid:isDeleted()
				if cProduto == oGrid:GetValue("ZEG_PRODUT")
					oModel:SetErrorMessage("","","","","HELP", 'Produto já cadastrado1', "Produto já inserido na linha: "+AllTrim(Str(nI))+" - Item:" + oGrid:GetValue("ZEG_ITEM") )
					lRet := .F. 
				endif 
			endif 
		endif 
	Next nI 
	oGrid:GoLine(nLine)
Return lRet 	
