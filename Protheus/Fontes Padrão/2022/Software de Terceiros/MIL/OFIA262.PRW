#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA262.CH"

Function OFIA262(cFilDefault, cViewDefault)

	Local oBrw262
	Local oTableAtt
	Local aArea := GetArea()

	Local oSizePrinc
	//Local oSizeFiltro
	Local oInterfHelper := DMS_InterfaceHelper():New()

	Default cFilDefault := ""
	Default cViewDefault := ""

	oSizePrinc := oInterfHelper:CreateDefSize(;
		.f. ,;
		{ { "BROWSE" , 100 , 035,.T., .T. }  ,;
		  { "CABEC"  ,  03 ,  15,.T., .F. }  ,; // Cabecalho
		  { "GETLOG" , 100 , 200,.T., .F. } },;
		,;
		,;
		)
	oSizePrinc:Process()

	oInterfHelper:nOpc := 3

	oInterfHelper:SetDefSize(oSizePrinc)
	oOIA262 := oInterfHelper:CreateDialog(STR0001) // "Consulta Log Rest"
	oOIA262:lEscClose := .t.

	aDivLog := { ;
		{ "ESQUERDA" , 050, 050 , .T. , .T. } ,; // REQUEST
		{ "DIREITA"  , 050, 050 , .T. , .T. }  ; // RETURN
	}

	oSizeCabec := oInterfHelper:CreateDefSize(.f., aDivLog, oSizePrinc:GetNextCallArea("CABEC"))
	oSizeCabec:lLateral := .t. // Calcula em colunas
	oSizeCabec:Process()

	oSizeLog := oInterfHelper:CreateDefSize(.f., aDivLog, oSizePrinc:GetNextCallArea("GETLOG"))
	oSizeLog:lLateral := .t. // Calcula em colunas
	oSizeLog:Process()

	oInterfHelper:Clean()
	oInterfHelper:SetDefSize(oSizeCabec,"ESQUERDA")
	oInterfHelper:CreateTPanel({{"TEXTO",STR0003} , {"COR", CLR_WHITE } , { "FUNDO", RGB( 10 , 114 , 140 ) } })//"Request"

	oInterfHelper:Clean()
	oInterfHelper:SetDefSize(oSizeCabec,"DIREITA")
	oInterfHelper:CreateTPanel({{"TEXTO",STR0004}  , {"COR", CLR_WHITE } , { "FUNDO", RGB( 10 , 114 , 140 ) } })//"Return"

	oInterfHelper:Clean()
	oInterfHelper:SetDefSize(oSizePrinc,"BROWSE")
	oPanBrowse := oInterfHelper:CreateTPanel()

	oInterfHelper:Clean()

	oInterfHelper:SetDefSize(oSizeLog,"ESQUERDA")
	oInterfHelper:SetPrefixo("PAR")
	oInterfHelper:AddMGet( "VK5_REQHEA" , { { "X3_VISUAL" , "V" } } )
	oInterfHelper:AddMGet( "VK5_REQBOD" , { { "X3_VISUAL" , "V" } } )
	oEnchReq := oInterfHelper:CreateMSMGet(.f., { {"COLUNA", .t. }})

	oInterfHelper:Clean()

	oInterfHelper:SetDefSize(oSizeLog,"DIREITA")
	oInterfHelper:SetPrefixo("PAR")
	oInterfHelper:AddMGet( "VK5_RESHEA" , { { "X3_VISUAL" , "V" } } )
	oInterfHelper:AddMGet( "VK5_RESBOD" , { { "X3_VISUAL" , "V" } } )
	oEnchRet := oInterfHelper:CreateMSMGet(.f., { {"COLUNA", .t. }})

	oBrw262 := BrowseDef()

	oTableAtt := TableAttDef()
	oBrw262:SetAttach(.T.)
	oBrw262:SetViewsDefault(oTableAtt:aViews)

	If ! Empty(cViewDefault)
		oBrw262:SetIdViewDefault(cViewDefault)
	EndIf

	If ! Empty(cFilDefault)
		oBrw262:SetFilterDefault(cFilDefault)
	EndIf

	oBrw262:SetOwner(oPanBrowse)

	oBrw262:bChange := { || OA2620033_AtuMSMGet() }
	
	oBrw262:Activate()

	ACTIVATE MSDIALOG oOIA262 ON INIT IIf( ! VK5->(Eof()) , OA2620033_AtuMSMGet() , )

	RestArea( aArea )

Return

Static Function MenuDef()
	Local aRotOA262 := {}
	ADD OPTION aRotOA262 TITLE STR0005 ACTION 'VIEWDEF.OFIA262' OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotOA262 TITLE STR0006 ACTION 'OA2620013_RemoverLOG' OPERATION 4 ACCESS 0 // "Remover LOG"
Return aRotOA262

Static Function TableAttDef()

	Local oMobView
	Local oSOView
	Local oSOLocView

	local aFldView := {"VK5_ORIGEM","VK5_MESSAG","VK5_ORITAB","VK5_ORIKEY","VK5_RESCOD","VK5_DATINC","VK5_DATALT"}

	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("VK5")

	oMobView := FWDSView():New()
	oMobView:SetName(STR0007)
	oMobView:SetID("MOBILE")
	oMobView:SetOrder(3)
	oMobView:SetCollumns(aFldView)
	oMobView:SetPublic( .T. )
	oMobView:AddFilter("Mobile", "VK5_DATTYP = '00'")
	oTableAtt:AddView(oMobView)

	oSOView := FWDSView():New()
	oSOView:SetName(STR0008)
	oSOView:SetID("SO_SMO")
	oSOView:SetOrder(3)
	oSOView:SetCollumns(aFldView)
	oSOView:SetPublic( .T. )
	oSOView:AddFilter("SO", "VK5_DATTYP = '01'")
	oTableAtt:AddView(oSOView)
	
	oSOLocView := FWDSView():New()
	oSOLocView:SetName(STR0009)
	oSOLocView:SetID("SO_SMO_LOC")
	oSOLocView:SetOrder(3)
	oSOLocView:SetCollumns(aFldView)
	oSOLocView:SetPublic( .T. )
	oSOLocView:AddFilter("SO", "VK5_DATTYP = '01' .AND. VK5_MESSAG $ '01/02/03'")
	oTableAtt:AddView(oSOLocView)

	oDTFView := FWDSView():New()
	oDTFView:SetName(STR0010)
	oDTFView:SetID("DTF")
	oDTFView:SetOrder(3)
	oDTFView:SetCollumns(aFldView)
	oDTFView:SetPublic( .T. )
	oDTFView:AddFilter("DTF", "VK5_DATTYP = '02'")
	oTableAtt:AddView(oDTFView)

Return oTableAtt

Static Function BrowseDef()

	Local oBrowse := FWMBrowse():New()

	dbSelectArea("VK5")
	dbSetOrder(3)

	oBrowse:SetAlias('VK5')
	oBrowse:SetDescription( STR0001 ) // "Consulta Log Rest"
	oBrowse:SetMenuDef("OFIA262")
	oBrowse:DisableDetails()

Return oBrowse

Static Function ModelDef()

	Local oModel

	Local oCabVK5 := FWFormStruct( 1, 'VK5' )

	oModel := MPFormModel():New( 'OFIA262', /* bPre */, /* bPost */ , /* bCommit */ ,  /* bCancel */ )
	oModel:AddFields('VK5' , /* cOwner */ , oCabVK5   , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )

	oModel:SetDescription(STR0002) // 'Consulta de LOG do WS'
	oModel:GetModel('VK5'):SetDescription('Model VK5') // 'Model Master'

Return oModel

Static Function ViewDef()

	Local oModel := FWLoadModel( 'OFIA262' )
	Local oView  := Nil
	Local aFields := {}
	Local nPosFields

	Local oCabStru  := FWFormStruct( 2, 'VK5' )

	oCabStru:AddGroup("DADOS",STR0011,"",2)//"Dados"
	aFields := oCabStru:GetFields()
	For nPosFields := 1 to Len(aFields)
		If aFields[nPosFields,MVC_VIEW_IDFIELD] $ "VK5_REQHEA/VK5_REQBOD/VK5_RESHEA/VK5_RESBOD"
		Else
			oCabStru:SetProperty( aFields[nPosFields,MVC_VIEW_IDFIELD] , MVC_VIEW_GROUP_NUMBER , "DADOS" )
		EndIf
	next nPosFields

	oCabStru:AddGroup(STR0003,STR0012,"",2)//"Request" //"Requisição"
	oCabStru:SetProperty( "VK5_REQHEA" , MVC_VIEW_GROUP_NUMBER , STR0003 )//"Request"
	oCabStru:SetProperty( "VK5_REQBOD" , MVC_VIEW_GROUP_NUMBER , STR0003 )//"Request"

	oCabStru:AddGroup(STR0004,STR0013,"",2)//"Return" //"Resposta"
	oCabStru:SetProperty( "VK5_RESHEA" , MVC_VIEW_GROUP_NUMBER , STR0004  )//"Return"
	oCabStru:SetProperty( "VK5_RESBOD" , MVC_VIEW_GROUP_NUMBER , STR0004  )//"Return"

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField( 'VK5'  , oCabStru  , 'VK5' )

	oView:CreateHorizontalBox('TELA_VK5', 100)
	oView:SetOwnerView('VK5','TELA_VK5')

Return oView


Function OA2620013_RemoverLOG()

	Local aParamBox := {}
	Local aRet := {}
	Local cExecSQL := ""

	Private cFiltroVX5 := "083"

	aAdd(aParamBox,{ 1 , STR0014         , CtoD(" "),"@D","","",".T.",50,.T.}) // Data Inicial
	aAdd(aParamBox,{ 1 , STR0015         , CtoD(" "),"@D","","",".T.",50,.T.}) // Data Final
	aAdd(aParamBox,{ 2 , RetTitle("VK5_DATTYP") , "" , OFIOA560PCB( "084" , TamSX3("VK5_DATTYP")[1] ) , 80 , "" , .t.  }) // Tipo de dados
	aAdd(aParamBox,{ 2 , RetTitle("VK5_ORIGEM") , "" , OFIOA560PCB( "085" , TamSX3("VK5_ORIGEM")[1] ) , 80 , "" , .t.  }) // Origem
	aAdd(aParamBox,{ 1 , RetTitle("VK5_MESSAG") , Space(TamSX3("VK5_MESSAG")[1]) ,"@!","","VX5AUX",".T.",30,.F.}) // Data Final

	If ! ParamBox(aParamBox,"",@aRet,,,,,,,,.F.) // Filtros
		Return .t.
	EndIf

	cExecSQL := "DELETE FROM " + RetSQLName("VK5") +;
		" WHERE VK5_FILIAL = '" + xFilial("VK5") + "'" +;
		  " AND VK5_DATINC BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' " +;
		  IIf( ! Empty(MV_PAR03) , " AND VK5_DATTYP = '" + MV_PAR03 + "'" , "" ) +;
		  IIf( ! Empty(MV_PAR04) , " AND VK5_ORIGEM = '" + MV_PAR04 + "'" , "" ) +;
		  IIf( ! Empty(MV_PAR05) , " AND VK5_MESSAG = '" + MV_PAR05 + "'" , "" )

	If TcSqlExec(cExecSQL) < 0
		FMX_HELP(STR0016 + CRLF + TCSQLError())//"Erro na execução da instrução SQL."
		Return .F.
	EndIf
Return


Static Function OA2620033_AtuMSMGet()

	M->PAR_REQHEA := VK5->VK5_REQHEA
	M->PAR_REQBOD := VK5->VK5_REQBOD
	M->PAR_RESHEA := VK5->VK5_RESHEA
	M->PAR_RESBOD := VK5->VK5_RESBOD

	oEnchRet:Refresh()
	oEnchReq:Refresh()
Return