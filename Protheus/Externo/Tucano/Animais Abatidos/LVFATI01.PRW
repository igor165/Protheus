#INCLUDE 'PROTHEUS.CH'
#include "fwmvcdef.ch"

Static cTitulo := "Planejamento Anual Confinamento"

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
	Local aZEGRel	:= {}
	Local aAux		:= {}
	Local nI

	aAdd(aAux, FwStruTrigger("ZEF_NUMANI" 	,"ZEF_NUMANI","U_I01GATI()"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_PERIOD" 	,"ZEF_PERIOD","U_I01GATI()"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_PESOKG" 	,"ZEF_PESOKG","U_I01GATI()"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_GMD" 		,"ZEF_GMD"	 ,"U_I01GATI()"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_RENDIM" 	,"ZEF_RENDIM","U_I01GATI()"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_VLRVEN" 	,"ZEF_VLRVEN","U_I01GATI()"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_VLRENT" 	,"ZEF_VLRENT","U_I01GATI()"									,.F. ,"",0,"" ,NIL, "01" ))
	aAdd(aAux, FwStruTrigger("ZEF_COPCAB" 	,"ZEF_COPCAB","U_I01GATI()"									,.F. ,"",0,"" ,NIL, "01" ))

	For nI := 1 to Len(aAux)
		oStrCab:AddTrigger(aAux[nI,1], aAux[nI,2], aAux[nI,3], aAux[nI,4])
	next nI

	aAux := {}

	aadd(aAux, FwStruTrigger("ZEG_KGDIA" 	,"ZEG_KGTOTA","U_I01KTOT()"													 ,.F. ,"",0,"" ,NIL, "01" ))
	aadd(aAux, FwStruTrigger("ZEG_KGDIA" 	,"ZEG_VLRDIA","M->ZEG_KGDIA * M->ZEG_VLRUNI"								 ,.F. ,"",0,"" ,NIL, "02" ))
	aadd(aAux, FwStruTrigger("ZEG_VLRUNI" 	,"ZEG_VLRTOT","M->ZEG_VLRUNI * M->ZEG_KGTOTA"								 ,.F. ,"",0,"" ,NIL, "01" ))
	aadd(aAux, FwStruTrigger("ZEG_VLRUNI" 	,"ZEG_VLRDIA","M->ZEG_VLRUNI * M->ZEG_KGDIA"								 ,.F. ,"",0,"" ,NIL, "02" ))
	aadd(aAux, FwStruTrigger("ZEG_VLRUNI" 	,"ZEG_VLRDIA","U_I01KTOT()"													 ,.F. ,"",0,"" ,NIL, "03" ))
	aadd(aAux, FwStruTrigger("ZEG_PRODUT" 	,"ZEG_DESC"  ,"Posicione('SB1',1,FwXFilial('SB1')+ M->ZEG_PRODUT, 'B1_DESC')",.F. ,"",0,"" ,NIL, "02" ))

	For nI := 1 to Len(aAux)
		oStrGrid:AddTrigger(aAux[nI,1], aAux[nI,2], aAux[nI,3], aAux[nI,4])
	next nI
	
	oStrCab:SetProperty('ZEF_CODIGO', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(INCLUI,GETSX8NUM("ZEF","ZEF_CODIGO"),ZEF->ZEF_CODIGO)')) //Inicializador Padr„o
	oStrCab:SetProperty('ZEF_DATA'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(INCLUI,Date(),ZEF->ZEF_DATA)')) //Inicializador Padr„o
	
	oStrGrid:SetProperty('ZEG_FILIAL' , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,ZEF->ZEF_FILIAL,M->ZEF_FILIAL)")) //Inicializador Padr„o
	oStrGrid:SetProperty('ZEG_CODIGO' , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,ZEF->ZEF_CODIGO,M->ZEF_CODIGO)")) //Inicializador Padr„o
	oStrGrid:SetProperty('ZEG_DESC'   , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "Posicione('SB1',1,FwXFilial('SB1')+ ZEG->ZEG_PRODUT, 'B1_DESC')")) //Inicializador Padr„o

	oStrGrid:SetProperty('ZEG_PRODUT', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'ExistCpo("SB1") .and. U_I01VldP()')) //Modo de EdiÁ„o
	
	//Criando o FormModel, adicionando o Cabe√É¬ßalho e Grid
	oModel := MPFormModel():New("FATI01",/* bVldPre */, /* bVldPos */ /*Pos-Validacao*/, /* bVldCom */ /*Commit*/,/*Cancel*/)

	oModel:AddFields("ZEFMASTER",/*cOwner*/ 	,oStrCab)
	oModel:AddGrid('ZEGDETAIL'	,'ZEFMASTER'	,oStrGrid,/* {|| U_I01LPRE()} */, /* {|| U_I01LOK()} */,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner √É¬© para quem pertence

    aAdd(aZEGRel, {'ZEG_FILIAL', 'Iif(!INCLUI, ZEF->ZEF_FILIAL, FWxFilial("ZEF"))' } )
	aAdd(aZEGRel, {'ZEG_CODIGO', 'Iif(!INCLUI, ZEF->ZEF_CODIGO, M->ZEF_CODIGO)' } )

    oModel:SetRelation('ZEGDETAIL', aZEGRel, ZEG->(IndexKey(1))) //IndexKey -> quero a ordena√ß√£o e depois filtrado
	oModel:GetModel('ZEGDETAIL'):SetUniqueLine({"ZEG_FILIAL","ZEG_CODIGO","ZEG_ITEM"})	//N√£o repetir informa√ß√µes ou combina√ß√µes {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey( {"ZEG_FILIAL","ZEG_CODIGO"} )

    oModel:AddCalc('TOTAIS', 'ZEFMASTER', 'ZEGDETAIL', 'ZEG_KGDIA' , 'XX_KGDIA' , 'SUM', , , "Total Kg/Cab/Dia:")
    oModel:AddCalc('TOTAIS', 'ZEFMASTER', 'ZEGDETAIL', 'ZEG_KGTOTA', 'XX_KGTOTA', 'SUM', , , "Total Kg:")
    oModel:AddCalc('TOTAIS', 'ZEFMASTER', 'ZEGDETAIL', 'ZEG_VLRDIA', 'XX_VLRDIA', 'SUM', , , "Total Vlr Dia:")
    oModel:AddCalc('TOTAIS', 'ZEFMASTER', 'ZEGDETAIL', 'ZEG_VLRTOT', 'XX_VLRTOT', 'SUM', , , "Total Vlr Total:")

	//Setando outras informa√É¬ß√É¬µes do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:GetModel("ZEFMASTER"):SetDescription("Dados da "+cTitulo)
	oModel:GetModel("ZEGDETAIL"):SetDescription("Grid da  "+cTitulo)
	
Return oModel

Static Function ViewDef()
	Local oModel    := FWLoadModel("LVFATI01")
	Local oStrCab   := FWFormStruct(2, 'ZEF')
	Local oStrGrid  := FWFormStruct(2, 'ZEG')
	Local oStrTot   := FWCalcStruct(oModel:GetModel('TOTAIS'))
	Local oView     := FWFormView():New()

	oStrGrid:SetProperty('ZEG_PRODUT', MVC_VIEW_LOOKUP , 'SB1') //TÌtulo do campo
 
    //oModel :=
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZEF", oStrCab  , "ZEFMASTER")
	oView:AddGrid('VIEW_ZEG' , oStrGrid , 'ZEGDETAIL')
	oView:AddField('VIEW_TOT' , oStrTot  , 'TOTAIS')

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
			oTot 		:= oModel:GetModel("TOTAIS")
			nOpc 		:= oGrid:GetOperation()
			nLines 		:= oGrid:Length()
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

			IF nVlrDia > 0
				oCab:LoadValue("ZEF_CUSCAB",Round(nVlrDia,2))
	
				oCab:LoadValue("ZEF_CUSOPA",Round(nVlrDia,2) + oCab:GetValue("ZEF_COPCAB"))
				
				oCab:LoadValue("ZEF_CUSTOA",Round((Round(nVlrDia,2) + oCab:GetValue("ZEF_COPCAB")) * (oCab:GetValue("ZEF_PERIOD") / Round(oCab:GetValue("ZEF_QTDARR"),2)),2))
				
				oCab:LoadValue("ZEF_VLRALI",Round(oCab:GetValue("ZEF_PERIOD") * Round(nVlrDia,2),2))
				
				oCab:LoadValue("ZEF_DESTOT",oCab:GetValue("ZEF_VLRALI") + oCab:GetValue("ZEF_VLRCEN") +;
											(oCab:GetValue("ZEF_COPCAB") * oCab:GetValue("ZEF_PERIOD")))
				
				oCab:LoadValue("ZEF_RECLIQ",oCab:GetValue("ZEF_RECEIT") - oCab:GetValue("ZEF_DESTOT"))
				
				oCab:LoadValue("ZEF_RECTOT",oCab:GetValue("ZEF_RECLIQ") * oCab:GetValue("ZEF_NUMANI"))

			endIf
		elseif Alltrim(cIdPonto) == "FORMPRE" .and. cIdModel == 'ZEGDETAIL' .AND. cIdIXB5 == 'UNDELETE' 
			oModel 	 	:= FwModelActivate()
			oCab 		:= oModel:GetModel("ZEFMASTER")
			oGrid 		:= oModel:GetModel("ZEGDETAIL")
			oTot 		:= oModel:GetModel("TOTAIS")
			nOpc 		:= oGrid:GetOperation()
			nLines 		:= oGrid:Length()
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

			IF nVlrDia > 0
				oCab:LoadValue("ZEF_CUSCAB",Round(nVlrDia,2))
	
				oCab:LoadValue("ZEF_CUSOPA",Round(nVlrDia,2) + oCab:GetValue("ZEF_COPCAB"))

				oCab:LoadValue("ZEF_CUSTOA",Round((Round(nVlrDia,2) + oCab:GetValue("ZEF_COPCAB")) * (oCab:GetValue("ZEF_PERIOD") / Round(oCab:GetValue("ZEF_QTDARR"),2)),2))
				
				oCab:LoadValue("ZEF_VLRALI",Round(oCab:GetValue("ZEF_PERIOD") * Round(nVlrDia,2),2))
				
				oCab:LoadValue("ZEF_DESTOT",oCab:GetValue("ZEF_VLRALI") + oCab:GetValue("ZEF_VLRCEN")+;
											(oCab:GetValue("ZEF_COPCAB") * oCab:GetValue("ZEF_PERIOD")))
				
				oCab:LoadValue("ZEF_RECLIQ",oCab:GetValue("ZEF_RECEIT") - oCab:GetValue("ZEF_DESTOT"))
				
				oCab:LoadValue("ZEF_RECTOT",oCab:GetValue("ZEF_RECLIQ") * oCab:GetValue("ZEF_NUMANI"))

			endIf
		endif
	endif 
	FWRestRows( aSaveLines )
Return xRet
//gatilho ZEG_KGDIA -> ZEG_KGTOTA
//gatilho ZEG_VLRUNI -> ZEG_VLRTOT
User Function I01KTOT()
	Local oModel 	:= FWModelActive()
	Local oCab		:= oModel:GetModel("ZEFMASTER") 
	Local oGrid 	:= oModel:GetModel("ZEGDETAIL")
	Local oTot		:= oModel:GetModel("TOTAIS") 
	Local nRet 		:= 0

	if ReadVar() == 'M->ZEG_KGDIA'
		nRet := oGrid:GetValue("ZEG_KGDIA") * oCab:GetValue("ZEF_PERIOD") * oCab:GetValue("ZEF_NUMANI")
		oGrid:LoadValue("ZEG_VLRTOT",nRet * oGrid:GetValue("ZEG_VLRUNI"))
	elseif ReadVar() == 'M->ZEG_VLRUNI'
		nRet := oGrid:GetValue("ZEG_KGDIA") * oGrid:GetValue("ZEG_VLRUNI")
	elseif ReadVar() ==  'M->ZEG_VLRTOT'
		nRet := oGrid:GetValue("ZEG_KGDIA") * oGrid:GetValue("ZEG_VLRUNI")
	endif

	oCab:LoadValue("ZEF_CUSCAB",Round(oTot:GetValue("XX_VLRDIA"),2))

	oCab:LoadValue("ZEF_CUSOPA",Round(oTot:GetValue("XX_VLRDIA"),2) + oCab:GetValue("ZEF_COPCAB"))
	
	oCab:LoadValue("ZEF_CUSTOA",(Round(oTot:GetValue("XX_VLRDIA"),2) + oCab:GetValue("ZEF_COPCAB")) * (oCab:GetValue("ZEF_PERIOD") / Round(oCab:GetValue("ZEF_QTDARR"),2)))
	
	oCab:LoadValue("ZEF_VLRALI",Round(oCab:GetValue("ZEF_PERIOD") * Round(oTot:GetValue("XX_VLRDIA"),2),2))
	
	oCab:LoadValue("ZEF_DESTOT",oCab:GetValue("ZEF_VLRALI") + oCab:GetValue("ZEF_VLRCEN")+;
								(oCab:GetValue("ZEF_COPCAB") * oCab:GetValue("ZEF_PERIOD")))
	
	oCab:LoadValue("ZEF_RECLIQ",oCab:GetValue("ZEF_RECEIT") - oCab:GetValue("ZEF_DESTOT"))
	
	oCab:LoadValue("ZEF_RECTOT",oCab:GetValue("ZEF_RECLIQ") * oCab:GetValue("ZEF_NUMANI"))
Return nRet
User Function I01VldP()
	Local oModel 	:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZEGDETAIL") 
	Local nLine 	:= oGrid:GetLine()
	Local nLinTot	:= oGrid:Length()
	Local nI
	Local cProduto 	:= oGrid:GetValue("ZEG_PRODUT")
	Local lRet 		:= .T.

	For nI := 1 to nLinTot
		if nI != nLine 
			oGrid:GoLine(nI)
			if !oGrid:isDeleted()
				if cProduto == oGrid:GetValue("ZEG_PRODUT")
					oModel:SetErrorMessage("","","","","HELP", 'Produto j· cadastrado1', "Produto j· inserido na linha: "+AllTrim(Str(nI))+" - Item:" + oGrid:GetValue("ZEG_ITEM") )
					lRet := .F. 
				endif 
			endif 
		endif
	Next nI 
	oGrid:GoLine(nLine)
Return lRet 	

User Function I01Gati()
	Local oModel 	:= FWModelActive()
	Local oView 	:= FWViewActive()
	Local oCab		:= oModel:GetModel("ZEFMASTER")
	Local oGrid 	:= oModel:GetModel("ZEGDETAIL")
	Local oTot		:= oModel:GetModel("TOTAIS") 
	Local cCampo 	:= SubStr(ReadVar(),4,Len(ReadVar()))
	Local nRet 		:= oCab:GetValue(cCampo)
	Local nI 

	oCab:LoadValue("ZEF_NUMANI",oCab:GetValue("ZEF_NUMANI"))
	
	oCab:LoadValue("ZEF_PERIOD",oCab:GetValue("ZEF_PERIOD"))

	if cCampo $ 'ZEF_NUMANI|ZEF_PERIOD'
		For nI := 1 to oGrid:Length()
			oGrid:GoLine(nI)

			oGrid:LoadValue("ZEG_KGTOTA", oGrid:GetValue("ZEG_KGDIA") * oCab:GetValue("ZEF_NUMANI") * oCab:GetValue("ZEF_PERIOD"))
			oGrid:LoadValue("ZEG_VLRDIA", oGrid:GetValue("ZEG_VLRUNI") * oGrid:GetValue("ZEG_KGDIA"))
			oGrid:LoadValue("ZEG_VLRTOT", Round(oGrid:GetValue("ZEG_KGTOTA") * oGrid:GetValue("ZEG_VLRUNI"),2))
		Next nI
	endif
	
	oCab:LoadValue("ZEF_PESOKG",oCab:GetValue("ZEF_PESOKG"))
	
	oCab:LoadValue("ZEF_PESOAR",oCab:GetValue("ZEF_PESOKG") / 30)

	oCab:LoadValue("ZEF_GMD",oCab:GetValue("ZEF_GMD"))

	oCab:LoadValue("ZEF_RENDIM",oCab:GetValue("ZEF_RENDIM"))
	
	oCab:LoadValue("ZEF_PESOF",oCab:GetValue("ZEF_PESOKG") +;
							  (oCab:GetValue("ZEF_PERIOD") * oCab:GetValue("ZEF_GMD") ))
	
	oCab:LoadValue("ZEF_PESOFC",oCab:GetValue("ZEF_PESOF") * oCab:GetValue("ZEF_RENDIM") / 100 / 15)
	
	oCab:LoadValue("ZEF_QTDARR",oCab:GetValue("ZEF_PESOFC") - oCab:GetValue("ZEF_PESOAR"))
	
	oCab:LoadValue("ZEF_CUSTOA",Round((oCab:GetValue("ZEF_COPCAB") + oCab:GetValue("ZEF_CUSCAB")) * oCab:GetValue("ZEF_PERIOD") / Round(oCab:GetValue("ZEF_QTDARR"),2),2))
	
	oCab:LoadValue("ZEF_VLRVEN",oCab:GetValue("ZEF_VLRVEN"))

	oCab:LoadValue("ZEF_VLRENT",oCab:GetValue("ZEF_VLRENT"))
	
	oCab:LoadValue("ZEF_CUSCAB",Round(oTot:GetValue("XX_VLRDIA"),2))

	oCab:LoadValue("ZEF_COPCAB",oCab:GetValue("ZEF_COPCAB"))

	oCab:LoadValue("ZEF_CUSOPA",oCab:GetValue("ZEF_COPCAB") + oCab:GetValue("ZEF_CUSCAB"))
	
	oCab:LoadValue("ZEF_VLRCEN",oCab:GetValue("ZEF_VLRENT") * oCab:GetValue("ZEF_PESOAR"))

	oCab:LoadValue("ZEF_VLRALI",Round(oCab:GetValue("ZEF_PERIOD") * oTot:GetValue("XX_VLRDIA"),2))
	
	oCab:LoadValue("ZEF_RECEIT",oCab:GetValue("ZEF_PESOFC") * oCab:GetValue("ZEF_VLRVEN"))

	oCab:LoadValue("ZEF_DESTOT",oCab:GetValue("ZEF_VLRALI") + oCab:GetValue("ZEF_VLRCEN") + (oCab:GetValue("ZEF_COPCAB") * oCab:GetValue("ZEF_PERIOD")))

	oCab:LoadValue("ZEF_RECLIQ",oCab:GetValue("ZEF_RECEIT") - oCab:GetValue("ZEF_DESTOT"))

	oCab:LoadValue("ZEF_RECTOT",oCab:GetValue("ZEF_RECLIQ") * oCab:GetValue("ZEF_NUMANI"))

	oView:Refresh()
Return nRet
