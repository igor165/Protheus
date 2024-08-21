#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

Static cTitulo := "Histórico Integração API"
User Function VAFINI01()
    Local aArea   		:= FwGetArea()
    Local oBrowse  		:= NIL

    SetFunName("VAFINI01")
	
    oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "SE2" )
	oBrowse:SetDescription( cTitulo )
	oBrowse:SetFilterDefault( "E2_XRCNZE2 > 0" )
    
    oBrowse:AddLegend( "E2_XSTAPI == 'ER'"          , "RED"     , "ERRO INTEGRACAO COM O BANCO")
    oBrowse:AddLegend( "E2_XSTAPI == 'OK'"          , "GREEN"   , "FINALIZADO COM SUCESSO")
    oBrowse:AddLegend( "!(E2_XSTAPI $ ('OK,ER')) "  , "WHITE"   , "TITULO NAO ENVIADO")
	
	oBrowse:Activate()
	
	FwRestArea(aArea)
Return

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE 'Chamar API' 	   ACTION 'U_FI01CAP()'      OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' 	   ACTION 'VIEWDEF.VAFINI01' OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE 'Alterar'	 	   ACTION 'VIEWDEF.VAFINI01' OPERATION 4 ACCESS 0
Return aRotina
Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStField 		:= nil
	Local oStSE2 		:= FWFormStruct(1, 'SE2')
	Local oStZE2 		:= FWFormStruct(1, 'ZE2')
	Local oStSE5 		:= FWFormStruct(1, 'SE5')
 	Local aCpSE5		:= {}
	Local aZE2Rel		:= {}
	Local aSE5Rel		:= {}
	Local nI

    oStField := FWFormModelStruct():New()

    oStField:addTable("", {"C_STRING1"}, "Visualização", {|| ""})
    oStField:addField("String 01", "texto", "C_STRING1", "C", 15)
	
	oStSE5:AddField('OK', ' ', 'OK', 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, ".F."))
	
	aCpSE5 := oStSE5:aFields
	For nI := 1 to Len(aCpSE5)
		if oStSE5:aFields[nI][03] != 'OK'
			oStSE5:aFields[nI][08] := {|| .F.}
			oStSE5:aFields[nI][10] := .F.
		endif 
	next nI
    
    //Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('FINI01')
	
	oModel:AddFields('FAKEM',/*cOwner*/   ,oStField, /* <bPre > */, /* <bPost > */, {|| LoadFake()}/* <bLoad > */)
	oModel:AddGrid('SE2DETAIL',"FAKEM"    ,oStSE2,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,{|oModel| LoadSE2(oModel)}/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	oModel:AddGrid('ZE2DETAIL','SE2DETAIL',oStZE2,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	oModel:AddGrid('SE5DETAIL','SE2DETAIL',oStSE5,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	
	oModel:GetModel('SE2DETAIL'):SetOptional(.T.)
	oModel:GetModel('ZE2DETAIL'):SetOptional(.T.)

	oModel:GetModel('SE2DETAIL'):SetOptional(.T.)
	oModel:GetModel('ZE2DETAIL'):SetOptional(.T.)
	oModel:GetModel('SE5DETAIL'):SetOptional(.T.)

	aadd(aZE2Rel, {'ZE2_FILIAL' ,'E2_FILIAL' })
	aadd(aZE2Rel, {'ZE2_PREFIX' ,'E2_PREFIXO'})
	aadd(aZE2Rel, {'ZE2_NUM'    ,'E2_NUM'    })
	aadd(aZE2Rel, {'ZE2_PARCEL' ,'E2_PARCELA'})
	aadd(aZE2Rel, {'ZE2_TIPO'   ,'E2_TIPO'   })
	aadd(aZE2Rel, {'ZE2_FORNEC' ,'E2_FORNECE'})
	aadd(aZE2Rel, {'ZE2_LOJA'   ,'E2_LOJA'   })

	aadd(aSE5Rel, {'E5_FILIAL'  ,'E2_FILIAL' })
	aadd(aSE5Rel, {'E5_PREFIXO' ,'E2_PREFIXO'})
	aadd(aSE5Rel, {'E5_NUMERO'  ,'E2_NUM'    })
	aadd(aSE5Rel, {'E5_PARCELA' ,'E2_PARCELA'})
	aadd(aSE5Rel, {'E5_TIPO'    ,'E2_TIPO'   })
	aadd(aSE5Rel, {'E5_CLIFOR'  ,'E2_FORNECE'})
	aadd(aSE5Rel, {'E5_LOJA'    ,'E2_LOJA'   })

    oModel:SetRelation('ZE2DETAIL', aZE2Rel, ZE2->(IndexKey(1)))
    
    oModel:SetRelation('SE5DETAIL', aSE5Rel, SE5->(IndexKey(7)))
	
	oModel:SetPrimaryKey( {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"} )

	oModel:SetDescription(cTitulo)
	oModel:GetModel('FAKEM'):SetDescription('Hide')
	oModel:GetModel('SE2DETAIL'):SetDescription('Titulos a Pagar')
	oModel:GetModel('ZE2DETAIL'):SetDescription('Log Integração')
	oModel:GetModel('SE5DETAIL'):SetDescription('Baixa de Titulos')

Return oModel
Static Function ViewDef()
	Local oView		    := Nil
	Local oModel	    := FWLoadModel("VAFINI01")
	Local oStField 		:= nil
	Local oStSE2 	    := FWFormStruct(2, 'SE2')
	Local oStZE2 	    := FWFormStruct(2, 'ZE2')
	Local oStSE5 	    := FWFormStruct(2, 'SE5')

    oStField := FWFormViewStruct():New()
    oStField:addField("C_STRING1", "01" , "String 01", "texto", , "C" )

	oStSE5:AddField( 'OK','01','OK','OK',, 'Check')

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField( 'CAB'       , oStField , 'FAKEM' )
	oView:AddGrid( 'VIEW_SE2'   , oStSE2 , 'SE2DETAIL' )
	oView:AddGrid( 'VIEW_ZE2'   , oStZE2 , 'ZE2DETAIL' )
	oView:AddGrid( 'VIEW_SE5'   , oStSE5 , 'SE5DETAIL' )
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('BOX_HIDE'  , 0 )
	oView:CreateHorizontalBox('BOX_SE2'  , 50 )
	oView:CreateHorizontalBox('BOX_GRID' , 50 )
	
    oView:CreateVerticalBox( 'BOX_ZE2', 50, 'BOX_GRID' )
    oView:CreateVerticalBox( 'BOX_BTN', 5 , 'BOX_GRID' )
    oView:CreateVerticalBox( 'BOX_SE5', 45, 'BOX_GRID' )

	oView:AddOtherObject("BUTTON",{|o1Panel,o1OtherObject| CriaBtn(o1Panel,o1OtherObject)})
	
	//Amarrando a view com as box
	oView:SetOwnerView('CAB'	    ,'BOX_HIDE' )
	oView:SetOwnerView('BUTTON'		,'BOX_BTN' )
	oView:SetOwnerView('VIEW_SE2'	,'BOX_SE2' )
	oView:SetOwnerView('VIEW_ZE2'	,'BOX_ZE2' )
	oView:SetOwnerView('VIEW_SE5'	,'BOX_SE5')

	oView:EnableTitleView('BUTTON'  ,'_________________________')
	oView:EnableTitleView('VIEW_SE2','Titulos a Pagar')
	oView:EnableTitleView('VIEW_ZE2','Log Integração')
	oView:EnableTitleView('VIEW_SE5','Baixa de Titulos')

Return oView
Static Function LoadFake()
Return {"Fake"}
Static Function LoadSE2(oModel)
    Local aArea     := FwGetArea()
    Local oStruct   := oModel:GetStruct()
    Local aData     := {}
    Local nI 
    Local aAux		:= oStruct:GetFields()
    
	aAdd(aData,{{SE2->(Recno())},{}})

	For nI := 1 to Len(aAux)
		if !(aAux[nI][14])
			aAdd(aData[Len(aData)][2],SE2->&(aAux[nI][3]))
		else //CAMPO VIRTUAL
			if aAux[nI][4] == 'C'
				aAdd(aData[Len(aData)][2],"")
			elseif aAux[nI][4] == 'D'
				aAdd(aData[Len(aData)][2],cToD("//"))
			elseif aAux[nI][4] == 'N'
				aAdd(aData[Len(aData)][2],0)
			endif
		endif
	Next nI

    FwRestArea(aArea)
Return aData

Static Function CriaBtn(o1Panel,o1OtherObject)
	Local nWidth  := o1Panel:NCLIENTWIDTH / 2
	Local nHeight := o1Panel:NHEIGHT / 2
	
	Private oBtn := Array(2)

	@(nHeight - 25),nWidth - 10 BTNBMP oBtn[1]  RESOURCE "PESQUISA" 	SIZE 25,25 ACTION Enviar() OF o1Panel
	@(nHeight + 25),nWidth - 10 BTNBMP oBtn[2]  RESOURCE "ENVIAR" 		SIZE 25,25 ACTION Consultar() OF o1Panel

	oBtn[1]:cToolTip := "Consultar"
	oBtn[2]:cToolTip := "Enviar"

Return 

Static Function Enviar()
	Local oModel 	:= FwModelActivate()
	Local oMdlSE5	:= oModel:GetModel("SE5DETAIL")
	Local nI
	Local cChave 	:= ""

	For nI := 1 To oMdlSE5:Length()
		oMdlSE5:Goline(nI)
		if oMdlSE5:GetValue("OK")
			cChave := FwxFilial("SE5") +;
					oMdlSE5:GetValue("E5_PREFIXO") +;
					oMdlSE5:GetValue("E5_PARCELA") +;
					oMdlSE5:GetValue("E5_TIPO") +;
					oMdlSE5:GetValue("E5_CLIFOR") +;
					oMdlSE5:GetValue("E5_LOJA")
					//oMdlSE5:GetValue("E5_NUMERO") +;
		endif 
	Next nI 

Return

Static Function Consultar()
	Local oModel 	:= FwModelActivate()
	Local oMdlSE5	:= oModel:GetModel("SE5DETAIL")
	Local nI
	Local cChave 	:= ""

	For nI := 1 To oMdlSE5:Length()
		oMdlSE5:Goline(nI)
		if oMdlSE5:GetValue("OK")
			cChave := FwxFilial("SE5") +;
					oMdlSE5:GetValue("E5_PREFIXO") +;
					oMdlSE5:GetValue("E5_PARCELA") +;
					oMdlSE5:GetValue("E5_TIPO") +;
					oMdlSE5:GetValue("E5_CLIFOR") +;
					oMdlSE5:GetValue("E5_LOJA")
					//oMdlSE5:GetValue("E5_NUMERO") +;
		endif 
	Next nI 
Return
Static Function criaButtonSel(oPanel,oOtherObject)
    TButton():New( 01, 10, "OK Todos",oPanel,{|| SelGrid(oOtherObject)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
Return
//User FUnction FI01CAP()
//    Local cChave := SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
//Return
