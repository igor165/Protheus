#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA300A.CH"

Static aDados 

/*/{Protheus.doc} GTPA300A
(long_description)
@type  Static Function
@author flavio.martins
@since 29/09/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA300A(oModel)

If oModel <> Nil

	aDados := {}

	If oModel:GetId() == 'GTPA300B'

		aadd(aDados, oModel:GetModel('HEADER'):GetValue('TPVIAGEM'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('DATAINI'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('DATAFIM'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('LINHAINI'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('LINHAFIM'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('CONTRINI'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('CONTRFIM'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('CLIEINI'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('LOJAINI'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('CLIEFIM'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('LOJAFIM'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('EXTRA'))

	ElseIf oModel:GetId() == 'GTPA300C'

		aadd(aDados, oModel:GetModel('HEADER'):GetValue('TPVIAGEM'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('DATAINI'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('DATAFIM'))
		aadd(aDados, '')
		aadd(aDados, PadR('', TamSx3('GYN_LINCOD')[1],'Z'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('CONTRATO'))
		aadd(aDados, oModel:GetModel('HEADER'):GetValue('CONTRATO'))
		aadd(aDados, '')
		aadd(aDados, '')
		aadd(aDados, PadR('', TamSx3('GY0_CLIENT')[1],'Z'))
		aadd(aDados, PadR('', TamSx3('GY0_LOJACL')[1],'Z'))
		aadd(aDados, '1')

	Endif

	FWExecView(STR0001,"VIEWDEF.GTPA300A",MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,40/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,)

Endif

Return

/*/{Protheus.doc}  ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 29/09/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCab	:= FwFormModelStruct():New() 
Local oStruVia	:= FwFormModelStruct():New() 
Local bLoad		:= {|oModel|  GA300ALoad(oModel)}
Local bLoadGrid	:= {|oGrid|  LoadGrid(oGrid)}

oModel := MPFormModel():New("GTPA300A",,,)

SetMdlStruct(oStruVia)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddGrid("GRIDVIA", 'HEADER', oStruVia,,,,,bLoadGrid)

oModel:SetDescription(STR0002) // "Consulta de Viagens"
oModel:GetModel("HEADER"):SetDescription(STR0003)   // "Filtro" 
oModel:GetModel("GRIDVIA"):SetDescription(STR0004)  // "Viagens" 

oModel:GetModel("GRIDVIA"):SetOptional(.T.)

oModel:GetModel("GRIDVIA"):SetOnlyQuery(.T.)
oModel:GetModel("GRIDVIA"):SetOnlyView(.T.)
	
oModel:GetModel("GRIDVIA"):SetNoInsertLine(.T.)
oModel:GetModel("GRIDVIA"):SetNoUpdateLine(.T.)
oModel:GetModel("GRIDVIA"):SetNoDeleteLine(.T.)

oModel:GetModel('GRIDVIA'):SetMaxLine(999999)

oModel:SetPrimaryKey({})

Return(oModel)

/*/{Protheus.doc}  ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 29/09/2020
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/ 
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA300A")
//Local oStruCab	:= FwFormViewStruct():New()
Local oStruVia	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruVia)

oView:SetModel(oModel)

oView:SetDescription(STR0002) // "Consulta de Viagens"

oView:AddGrid("VIEW_VIA", oStruVia, "GRIDVIA" )

oView:CreateHorizontalBox('GRID1', 100)

oView:SetOwnerView('VIEW_VIA','GRID1')

oView:EnableTitleView("VIEW_VIA","Viagens")		// "Viagens"

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:GetViewObj("VIEW_VIA")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_VIA")[3]:SetFilter(.T.)

oView:ShowInsertMsg(.F.)

Return(oView)

/*/{Protheus.doc}  SetMdlStru
(long_description)
@type  Static Function
@author flavio.martins
@since 29/09/2020
@version 1.0
@param oStruct, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetMdlStru(oStruVia)

	If ValType(oStruVia) == "O"

		oStruVia:AddTable("GYNTMP",{},"CONSULTA")
	
		oStruVia:AddField(STR0014,STR0014,"GYN_LINCOD","C",TamSx3('GYN_LINCOD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Cód. Linha"
		oStruVia:AddField(STR0015,STR0015,"GYN_CODGID","C",TamSx3('GYN_CODGID')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Cód. Horário"
		oStruVia:AddField(STR0016,STR0016,"GYN_CODIGO","C",TamSx3('GYN_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Cód. Viagem"
		oStruVia:AddField(STR0023,STR0023,"EXTRA","C",3,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)								//"Viagem Extra"
		oStruVia:AddField(STR0017,STR0017,"GYN_DTINI","D",TamSx3('GYN_DTINI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Data InÃ­cio"
		oStruVia:AddField(STR0019,STR0019,"GYN_HRINI","C",TamSx3('GYN_HRINI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Hora InÃ­cio"
		oStruVia:AddField(STR0018,STR0018,"GYN_DTFIM","D",TamSx3('GYN_DTFIM')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Data Fim"
		oStruVia:AddField(STR0020,STR0020,"GYN_HRFIM","C",TamSx3('GYN_HRFIM')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Hora Fim"
		oStruVia:AddField(STR0021,STR0021,"GYN_DTGER","D",TamSx3('GYN_DTGER')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Data Geração"
		oStruVia:AddField(STR0022,STR0022,"GYN_HRGER","C",TamSx3('GYN_HRGER')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Hora Geraçao"
	
	Endif	
	
Return

/*/{Protheus.doc} SetViewStru
(long_description)
@type  Static Function
@author flavio.martins
@since 29/09/2020
@version 1.0
@param oStruct, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStru(oStruVia)

	If ValType(oStruVia) == "O"

		oStruVia:AddField("GYN_CODIGO","01",STR0016,STR0016,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)		//"Cód. Viagem"
		oStruVia:AddField("GYN_LINCOD","02",STR0014,STR0014,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)		//"Cód. Linha"
		oStruVia:AddField("GYN_CODGID","03",STR0015,STR0015,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)		//"Cód. Horário"
		oStruVia:AddField("EXTRA","04",STR0023,STR0023,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)				//"Viagem Extra"
		oStruVia:AddField("GYN_DTINI","05",STR0017,STR0017,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)		//"Data Iní­cio"
		oStruVia:AddField("GYN_HRINI","06",STR0019,STR0019,{""},"GET","@R 99:99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Hora Iní­cio"
		oStruVia:AddField("GYN_DTFIM","07",STR0018,STR0018,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)		//"Data Fim"
		oStruVia:AddField("GYN_HRFIM","08",STR0020,STR0020,{""},"GET","@R 99:99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Hora Fim"
		oStruVia:AddField("GYN_DTGER","09",STR0021,STR0021,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)		//"Data Geração"
		oStruVia:AddField("GYN_HRGER","10",STR0022,STR0022,{""},"GET","@R 99:99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Hora Geração"

	Endif
	
Return

/*/{Protheus.doc} GA300ALoad
(long_description)
@type  Static Function
@author flavio.martins
@since 29/09/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA300ALoad(oModel)
Local oMdlCab := oModel:GetModel('HEADER')

Return


/*/{Protheus.doc} LoadGrid
(long_description)
@type  Static Function
@author flavio.martins
@since 29/09/2020
@version 1.0
@param oGrid, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function LoadGrid(oGrid)
Local cAliasTmp := GetNextAlias()
Local cTpViagem := ""
Local dDtIni	:= CTOD("  /  /    ")
Local dDtFim    := CTOD("  /  /    ")
Local cLinIni	:= ""
Local cLinFim   := ""
Local cContIni  := ""
Local cContFim  := ""
Local cClieIni  := ""
Local cClieFim  := ""
Local cLojaIni  := ""
Local cLojaFim  := ""
Local cExtra	:= ""
Local aRet		:= {}


If Len(aDados) > 0

	cTpViagem := aDados[1]
	dDtIni    := aDados[2]
	dDtFim    := aDados[3]
	cLinIni   := aDados[4]
	cLinFim   := aDados[5]
	cContIni  := aDados[6]
	cContFim  := aDados[7]
	cClieIni  := aDados[8]
	cLojaIni  := aDados[9]
	cClieFim  := aDados[10]
	cLojaFim  := aDados[11]
	cExtra	  := aDados[12]	

	If aDados[12] == '1'
		cExtra := "%('T')%"
	ElseIf aDados[12] == '2'
		cExtra := "%('F')%"
	ElseIf cExtra == '3'
		cExtra := "%('T','F')%"
	Endif

	BeginSql Alias cAliasTmp

		Column GYN_DTINI as Date
		Column GYN_DTFIM as Date
		Column GYN_DTGER as Date

		SELECT GYN_CODIGO,
			GYN_LINCOD,
			GYN_CODGID,
			GYN_DTINI,
			GYN_DTFIM,
			GYN_HRFIM,
			GYN_HRINI,
			GYN_DTGER,
			GYN_HRGER,
			CASE WHEN GYN_EXTRA = 'T' THEN 'Sim' 
			 ELSE 'Não' END EXTRA, 
			GYN.R_E_C_N_O_
		FROM %Table:GYN% GYN
		INNER JOIN %Table:GYD% GYD ON GYD.GYD_FILIAL = GYN.GYN_FILIAL 
		AND ((GYD.GYD_CODGI2 = GYN.GYN_LINCOD AND GYN.GYN_EXTRA = 'F') OR
     		 (GYN.GYN_LINCOD = '' AND GYN.GYN_EXTRA = 'T'))
		AND GYD.%NotDel% 
		INNER JOIN %Table:GY0% GY0 ON GY0.GY0_FILIAL = GYN_FILIAL 
		AND GY0.GY0_NUMERO = GYD.GYD_NUMERO 
		AND GY0_NUMERO BETWEEN %Exp:cContIni% AND %Exp:cContFim%
		AND GY0.GY0_CLIENT BETWEEN  %Exp:cClieIni% AND %Exp:cClieFim%
		AND GY0.GY0_LOJACL BETWEEN %Exp:cLojaIni% AND %Exp:cLojaFim%
		AND GY0.%NotDel%
		WHERE GYN_FILIAL = %xFilial:GYN%
		AND GYN.GYN_DTINI BETWEEN %Exp:DtoS(dDtIni)% AND %Exp:DtoS(dDtFim)%
		AND GYN.GYN_LINCOD BETWEEN  %Exp:cLinIni% AND %Exp:cLinFim% 
		AND GYN.GYN_EXTRA IN %Exp:cExtra%
		AND GYN.%NotDel%	

	EndSql

	If (cAliasTmp)->(!Eof())
		aRet := FwLoadByAlias(oGrid, cAliasTmp) 
	Endif

Endif
	
Return aRet


