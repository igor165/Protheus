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
	//aAdd(aAux, FwStruTrigger("ZEF_CUSOPA" 	,"ZEF_CUSTOA","&(ReadVar()) * (M->ZEF_PERIOD / M->ZEF_QTDARR )"					,.F. ,"",0,"" ,NIL, "01" ))
	//aAdd(aAux, FwStruTrigger("ZEF_CUSCAB" 	,"ZEF_CUSOPA","&(ReadVar()) - M->ZEF_COPCAB"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_VLRENT" 	,"ZEF_VLRCEN","&(ReadVar()) * M->ZEF_PESOAR"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_VLRVEN" 	,"ZEF_RECEIT","&(ReadVar()) * M->ZEF_PESOFC"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_VLRCEN" 	,"ZEF_DESTOT","M->ZEF_VLRALI + &(ReadVar()) + (M->ZEF_COPCAB * M->ZEF_PERIOD)"	,.F. ,"",0,"" ,NIL, "02" ))
	aAdd(aAux, FwStruTrigger("ZEF_RECLIQ" 	,"ZEF_RECTOT","&(ReadVar()) * M->ZEF_NUMANI"									,.F. ,"",0,"" ,NIL, "01" ))

	For nI := 1 to Len(aAux)
		oStrCab:AddTrigger(aAux[nI,1], aAux[nI,2], aAux[nI,3], aAux[nI,4])
	next nI

	aAux := {}

	aadd(aAux, FwStruTrigger("ZEG_KGDIA" 	,"ZEG_KGTOTA","&(ReadVar()) * M->ZEF_PERIOD * M->ZEF_NUMANI"				,.F. ,"",0,"" ,NIL, "01" ))
	aadd(aAux, FwStruTrigger("ZEG_VLRUNI" 	,"ZEG_VLRTOT","&(ReadVar()) * M->ZEG_KGTOTA"								,.F. ,"",0,"" ,NIL, "01" ))
	aadd(aAux, FwStruTrigger("ZEG_VLRUNI" 	,"ZEG_VLRDIA","M->ZEG_VLRUNI * M->ZEG_KGDIA"													,.F. ,"",0,"" ,NIL, "02" ))
	aadd(aAux, FwStruTrigger("ZEG_VLRDIA" 	,"ZEG_VLRUNI","U_I01VLR()"													,.F. ,"",0,"" ,NIL, "02" ))
	aadd(aAux, FwStruTrigger("ZEG_PRODUT" 	,"ZEG_DESC"  ,"Posicione('SB1',1,FwXFilial('SB1')+ &(ReadVar()), 'B1_DESC')",.F. ,"",0,"" ,NIL, "02" ))

	For nI := 1 to Len(aAux)
		oStrGrid:AddTrigger(aAux[nI,1], aAux[nI,2], aAux[nI,3], aAux[nI,4])
	next nI 

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
    
	oStrGrid:SetProperty('ZEG_CODIGO' , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'M->ZEF_CODIGO')) //Inicializador Padrão
	oStrGrid:SetProperty('ZEG_DESC'   , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "Posicione('SB1',1,FwXFilial('SB1')+ ZEG->ZEG_PRODUT, 'B1_DESC')")) //Inicializador Padrão
	
	oStrGrid:SetProperty('ZEG_DESC'	 , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
	oStrGrid:SetProperty('ZEG_KGTOTA', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
	oStrGrid:SetProperty('ZEG_VLRDIA', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
	oStrGrid:SetProperty('ZEG_VLRTOT', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.')) //Modo de Edição
	
	oStrTot:SetProperty('TOT_KGDIA'   , MODEL_FIELD_INIT, ) //Inicializador Padrão
	oStrTot:SetProperty('TOT_KGTOTA'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "U_I01ITO()")) //Inicializador Padrão
	oStrTot:SetProperty('TOT_VLRDIA'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "U_I01ITO()")) //Inicializador Padrão
	oStrTot:SetProperty('TOT_VLRTOT'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "U_I01ITO()")) //Inicializador Padrão
	//Criando o FormModel, adicionando o CabeÃƒÂ§alho e Grid
	oModel := MPFormModel():New("FATI01",/* bVldPre */, /* bVldPos */ /*Pos-Validacao*/, /* bVldCom */ /*Commit*/,/*Cancel*/)

	oModel:AddFields("ZEFMASTER",/*cOwner*/ ,oStrCab  )
	oModel:AddGrid('ZEGDETAIL','ZEFMASTER',oStrGrid,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner ÃƒÂ© para quem pertence
	oModel:AddGrid('TOTDETAIL','ZEFMASTER',oStrTot,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner ÃƒÂ© para quem pertence

    aAdd(aZEGRel, {'ZEG_FILIAL', 'ZEF_FILIAL' } )
	aAdd(aZEGRel, {'ZEG_CODIGO', 'ZEF_CODIGO' } )

    oModel:SetRelation('ZEGDETAIL', aZEGRel, ZEG->(IndexKey(1))) //IndexKey -> quero a ordenaÃ§Ã£o e depois filtrado
	oModel:GetModel('ZEGDETAIL'):SetUniqueLine({"ZEG_FILIAL","ZEG_CODIGO","ZEG_ITEM"})	//NÃ£o repetir informaÃ§Ãµes ou combinaÃ§Ãµes {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey( {"ZEG_FILIAL","ZEG_CODIGO"} )

	//oModel:GetModel('TOTDETAIL'):SetOptional(.T.)
	//oModel:GetModel('TOTDETAIL'):SetNoInsertLine(.T.)
	//oModel:GetModel('TOTDETAIL'):SetNoDeleteLine(.T.)

	//Setando outras informaÃƒÂ§ÃƒÂµes do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:GetModel("ZEFMASTER"):SetDescription("Dados da "+cTitulo)
	oModel:GetModel("ZEGDETAIL"):SetDescription("Grid da "+cTitulo)
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
Static Function GetModelCabec(oModel,oStrTot)
//oStrGrid:AddField("Codigo",																			// [01]  C   Titulo do campo
//        "Codigo",;                                                                                  // [02]  C   ToolTip do campo
//        "XXCODIGO",;                                                                                // [03]  C   Id do Field
//        "C",;                                                                                       // [04]  C   Tipo do campo
//        04,;                                                                                        // [05]  N   Tamanho do campo
//        0,;                                                                                         // [06]  N   Decimal do campo
//        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
//        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
//        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
//        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
//        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->XXCODIGO" ),;                           // [11]  B   Code-block de inicializacao do campo
//        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
//        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
//        .F.)        
	oStrTot:AddField( '------' 		, '------' 		, 'TOT_CODIGO' 	, 'C' , TamSx3("ZEG_CODIGO")[1] ,TamSx3("ZEG_CODIGO")[2] 	,Nil,Nil,{} ,.F.,,.F.,.T.)
	oStrTot:AddField( '------' 		, '------' 		, 'TOT_ITEM' 	, 'C' , TamSx3("ZEG_ITEM")[1] 	,TamSx3("ZEG_ITEM")[2]  	,Nil,Nil,{} ,.F.,,.F.,.T.)
	oStrTot:AddField( '------' 		, '------' 		, 'TOT_PRODUT' 	, 'C' , TamSx3("ZEG_PRODUT")[1] ,TamSx3("ZEG_PRODUT")[2] 	,Nil,Nil,{} ,.F.,,.F.,.T.)
	oStrTot:AddField( '------' 		, '------' 		, 'TOT_DESC' 	, 'C' , TamSx3("ZEG_DESC")[1] 	,TamSx3("ZEG_DESC")[2]  	,Nil,Nil,{} ,.F.,,.F.,.T.)
	oStrTot:AddField( 'Kg/Cab/Dia' 	, 'Kg/Cab/Dia' 	, 'TOT_KGDIA' 	, 'N' , TamSx3("ZEG_KGDIA")[1] 	,TamSx3("ZEG_KGDIA")[2]  	,Nil,Nil,{} ,.F.,{|| U_I01ITO()},.F.,.T.)
	oStrTot:AddField( 'Kg Total' 	, 'Kg Total' 	, 'TOT_KGTOTA' 	, 'N' , TamSx3("ZEG_KGTOTA")[1] ,TamSx3("ZEG_KGTOTA")[2] 	,Nil,Nil,{} ,.F.,{|| U_I01ITO()},.F.,.T.)
	oStrTot:AddField( '------' 		, '------' 		, 'TOT_VLRUNI' 	, 'N' , TamSx3("ZEG_VLRUNI")[1] ,TamSx3("ZEG_VLRUNI")[2] 	,Nil,Nil,{} ,.F.,,.F.,.T.)
	oStrTot:AddField( 'Vlr Dia' 	, 'Vlr Dia' 	, 'TOT_VLRDIA' 	, 'N' , TamSx3("ZEG_VLRDIA")[1] ,TamSx3("ZEG_VLRDIA")[2] 	,Nil,Nil,{} ,.F.,{|| U_I01ITO()},.F.,.T.)//FwBuildFeature(STRUCT_FEATURE_INIPAD, "U_I01ITO()")
	oStrTot:AddField( 'Vlr Total' 	, 'Vlr Total' 	, 'TOT_VLRTOT' 	, 'N' , TamSx3("ZEG_VLRTOT")[1] ,TamSx3("ZEG_VLRTOT")[2] 	,Nil,Nil,{} ,.F.,{|| U_I01ITO()},.F.,.T.)
Return oStrTot

Static Function GetViewCabec(oModel,oStrTot)
//oStrGrid:AddField(;
//       "XXCODIGO",;                // [01]  C   Nome do Campo
//       "01",;                      // [02]  C   Ordem
//       "Codigo",;                  // [03]  C   Titulo do campo
//       "Codigo",;                  // [04]  C   Descricao do campo
//       Nil,;                       // [05]  A   Array com Help
//       "C",;                       // [06]  C   Tipo do campo
//       "@!",;                      // [07]  C   Picture
//       Nil,;                       // [08]  B   Bloco de PictTre Var
//       Nil,;                       // [09]  C   Consulta F3
//       .T.,;                       // [10]  L   Indica se o campo é alteravel
//       Nil,;                       // [11]  C   Pasta do campo
//       Nil,;                       // [12]  C   Agrupamento do campo
//       Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
//       Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
//       Nil,;                       // [15]  C   Inicializador de Browse
//       Nil,;                       // [16]  L   Indica se o campo é virtual
//       Nil,;                       // [17]  C   Picture Variavel
//       Nil)                        // [18]  L   Indica pulo de linha após o campo
	oStrTot:AddField( 'TOT_CODIGO' 	, '1' , '------' 	, '------' 		,nil, 'C', 							,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_ITEM' 	, '2' , '------' 	, '------' 		,nil, 'C', 							,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_PRODUT' 	, '3' , '------' 	, '------' 		,nil, 'C', 							,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_DESC' 	, '4' , '------' 	, '------' 		,nil, 'C', 							,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_KGDIA' 	, '5' , 'Kg/Cab/Dia', 'Kg/Cab/Dia' 	,nil, 'N',X3Picture( "ZEG_KGDIA" ) 	,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_KGTOTA' 	, '6' , 'Kg Total'	, 'Kg Total'	,nil, 'N',X3Picture( "ZEG_KGTOTA" ) ,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_VLRUNI' 	, '7' , '------' 	, '------' 		,nil, 'N', 							,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
   	oStrTot:AddField( 'TOT_VLRDIA' 	, '8' , 'Vlr Dia' 	, 'Vlr Dia' 	,nil, 'N',X3Picture( "ZEG_VLRDIA" ) ,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
	oStrTot:AddField( 'TOT_VLRTOT' 	, '9' , 'Vlr Total' , 'Vlr Total' 	,nil, 'N',X3Picture( "ZEG_VLRTOT" ) ,Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.,Nil,Nil)
Return oStrTot

//gatilho ZEG_VLRUNI -> ZEG_VLRDIA
User Function I01ITO()
	Local oMdl 		:= FWModelActive()
	Local oGrid		:= oMdl:GetModel("ZEGDETAIL") 
	Local nI 
	Local cCampo	:= 'ZEG' + (Substr( ReadVar(), At('->', ReadVar())+5 ))
	Local nLin 		:= oGrid:GetQtdLine()
	Local nSoma 	:= 0

	For nI := 1 to nLIN
		nSoma += oGrid:GetValue(cCampo)
	Next nI

Return nSoma 

User Function I01VLR()
	Local oMdl 		:= FWModelActive()
	Local oCab		:= oMdl:GetModel("ZEFMASTER") 
	//Local oStrCab 	:= oCab:GetStruct()
	Local oGrid		:= oMdl:GetModel("ZEGDETAIL") 
	Local nRet 		:= oGrid:GetValue("ZEG_VLRUNI") // ALTERAR PARA 4 
	Local nI 
	Local nLinAtu	:= oGrid:GetLine()
	Local nLin		:= oGrid:GetQtdLine()
	Local nSum		:= 0
	
	For nI := 1 to nLin
		oGrid:GoLine(nI)
		nSum += oGrid:GetValue("ZEG_VLRDIA")
	Next nI 


	if nSum > 0 
		oCab:LoadValue("ZEF_CUSCAB",nSum)
		
		oCab:LoadValue("ZEF_CUSOPA",nSum * oCab:GetValue("ZEF_COPCAB"))
		
		oCab:LoadValue("ZEF_CUSTOA",(nSum * oCab:GetValue("ZEF_COPCAB")) * (oCab:GetValue("ZEF_PERIOD") / oCab:GetValue("ZEF_QTDARR")))
		
		oCab:LoadValue("ZEF_VLRALI",oCab:GetValue("ZEF_PERIOD") * nSum)
		
		oCab:LoadValue("ZEF_DESTOT",(oCab:GetValue("ZEF_PERIOD") * nSum) +;
									 oCab:GetValue("ZEF_VLRCEN") +;
									 (oCab:GetValue("ZEF_COPCAB") * oCab:GetValue("ZEF_PERIOD")))
		
		oCab:LoadValue("ZEF_RECLIQ",oCab:GetValue("ZEF_RECEIT") - oCab:GetValue("ZEF_DESTOT"))
		
		oCab:LoadValue("ZEF_RECTOT",oCab:GetValue("ZEF_RECLIQ") * oCab:GetValue("ZEF_NUMANI"))

	endif 

	oGrid:GoLine(nLinAtu)

Return nRet
