#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA903A.CH"

/*/{Protheus.doc} GTPA903A
//TODO Descrição auto-gerada.
@author flavio.martins
@since 06/04/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTPA903A(oModel)
Local aEnableButtons 	:= GtpBtnView(.F.)
Local cCliente			:= ''
Local cLoja				:= ''
Local aArea				:= GetArea()
Local cMsgErro 			:= ''

If G900VldDic(@cMsgErro)

	If oModel <> Nil
		cCliente := oModel:GetModel('HEADER'):GetValue('CODCLI')
		cLoja	 := oModel:GetModel('HEADER'):GetValue('LOJCLI')

		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))

		SA1->(dbSeek(xFilial('SA1')+cCliente+cLoja))
		RestArea(aArea)
		FwExecView('Viagens de Contrato',"VIEWDEF.GTPA903A",MODEL_OPERATION_INSERT,,,,/*5*/,aEnableButtons,,,,oModel) //"Viagens de Contrato"
	Endif

Else
    FwAlertHelp(cMsgErro, "Atualize o dicionário para utilizar esta rotina",)	// "Dicionário desatualizado", "Atualize o dicionário para utilizar esta rotina"
Endif 

Return 

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author flavio.martins
@since 06/04/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCab	:= FwFormModelStruct():New() 
Local oStruVia	:= FwFormModelStruct():New() 
Local oStruTot	:= FwFormModelStruct():New() 
Local bLoad		:= {|oModel|  GA903ALoad(oModel)}

oModel := MPFormModel():New("GTPA903A",,,)

SetMdlStru(oStruCab,oStruVia, oStruTot)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddFields("TOTAL", "HEADER", oStruTot,,,/*bLoad*/)

oModel:AddGrid( 'GRIDVIA', 'HEADER', oStruVia,,,,,)

oModel:SetDescription(STR0001)							//"Viagens de Contrato"
oModel:GetModel("HEADER"):SetDescription(STR0002) 	    //"Filtro" 
oModel:GetModel("GRIDVIA"):SetDescription(STR0003)    	//"Viagens" 
oModel:GetModel("TOTAL"):SetDescription(STR0004)		//"Totais" 

oModel:GetModel("GRIDVIA"):SetOptional(.T.)

oModel:GetModel("GRIDVIA"):SetNoInsertLine(.T.)
oModel:GetModel("GRIDVIA"):SetNoUpdateLine(.T.)
oModel:GetModel("GRIDVIA"):SetNoDeleteLine(.T.)

oModel:SetPrimaryKey({})

oModel:SetVldActivate({|oModel| VldActivate(oModel)})

Return(oModel)

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author flavio.martins
@since 06/04/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= ModelDef() 
Local oStruCab	:= FwFormViewStruct():New()
Local oStruVia	:= FwFormViewStruct():New()
Local oStruTot  := FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruCab, oStruVia, oStruTot)

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:SetDescription(STR0039) //"Consulta"

oView:AddField('VIEW_HEADER' ,oStruCab,'HEADER')
oView:AddField('VIEW_TOTAL' ,oStruTot,'TOTAL')
oView:AddGrid("VIEW_VIA", oStruVia, "GRIDVIA" )

oView:CreateHorizontalBox('FILTRO', 25)
oView:CreateHorizontalBox('GRIDVIA', 50)
oView:CreateHorizontalBox('TOTAL', 25)

oView:SetOwnerView('VIEW_HEADER','FILTRO')
oView:SetOwnerView('VIEW_VIA','GRIDVIA')
oView:SetOwnerView('VIEW_TOTAL','TOTAL')

oView:EnableTitleView("VIEW_HEADER"	,STR0002)	//"Filtro"
oView:EnableTitleView("VIEW_VIA"	,STR0003)	//"Viagens"
oView:EnableTitleView("VIEW_TOTAL"	,STR0004)	//"Totais"

oView:AddUserButton(STR0005, "", {|oModel| GA903APesq(oModel)},,VK_F5) //"Pesquisar"

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:ShowInsertMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStru
//TODO Descrição auto-gerada.
@author flavio.martins
@since 06/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oStruCab, object, descricao
@param oStruVia, object, descricao
@type function
/*/
Static Function SetMdlStru(oStruCab, oStruVia, oStruTot)
Local bTrigger  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

	If ValType(oStruCab) == "O"
	
		oStruCab:AddField(STR0006,STR0006,"CODCLI","C"	,TamSx3('A1_COD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 			//"Cliente"
		oStruCab:AddField(STR0007,STR0007,"LOJCLI","C"	,TamSx3('A1_LOJA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 			//"Loja"
		oStruCab:AddField(STR0008,STR0008,"CONTRATODE","C",TamSx3('GY0_NUMERO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 		//"Contrato De"
		oStruCab:AddField(STR0009,STR0009,"CONTRATOATE","C",TamSx3('GY0_NUMERO')[1],0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.)	//"Contrato Até"
        oStruCab:AddField(STR0010,STR0010,"DATADE","D",8,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)								//"Data De"
    	oStruCab:AddField(STR0011,STR0011,"DATAATE","D",8,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)								//"Data Até"
		oStruCab:AddField(STR0012,STR0012,"TIPOVIA","C",1,0,{|| .T.},{|| .T.},{},.F.,	{|| '3'},.F.,.T.,.T.)						//"Viagem Extra"
		oStruCab:AddField(STR0013,STR0013,"LINHADE","C",TamSx3('GI2_COD')[1],0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.)		//"Linha De"		
		oStruCab:AddField(STR0014,STR0014,"LINHAATE","C",TamSx3('GI2_COD')[1],0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.)		//"Linha Até"		
		oStruCab:AddField(STR0040,STR0040,"STATUSVIA","C",1,0,{|| .T.},{|| .T.},{},.F., {|| '1'},.F.,.T.,.T.)						//"Status da Viagem"		

		oStruCab:AddTrigger("CODCLI","CODCLI",{ || .T. }, bTrigger)
		oStruCab:AddTrigger("CONTRATODE","CONTRATODE",{ || .T. }, bTrigger)
		oStruCab:AddTrigger("CONTRATOATE","CONTRATOATE",{ || .T. }, bTrigger)

	Endif	
	
	If ValType(oStruVia) == "O"

		oStruVia:AddField(STR0015,STR0015,"GYN_CODGY0","C",TamSx3('GYN_CODGY0')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Contrato"
		oStruVia:AddField(STR0016,STR0016,"GYN_CODIGO","C",TamSx3('GYN_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Código"
		oStruVia:AddField(STR0012,STR0012,"GYN_EXTRA","C",TamSx3('GYN_EXTRA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		//"Tipo Viagem"
		oStruVia:AddField(STR0041,STR0041,"GYN_FINAL","C",TamSx3('GYN_FINAL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Finalizada"
		oStruVia:AddField(STR0018,STR0018,"GYN_LINCOD","C",TamSx3('GYN_LINCOD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Cód.Linha"
		If GYN->(FIELDPOS("GYN_EXTCMP")) > 0
			oStruVia:AddField(STR0045,STR0045,"GYN_EXTCMP","C",TamSx3('GYN_EXTCMP')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Viagem Extra Sem Linha"
        EndIf
		oStruVia:AddField(STR0019,STR0019,"GYN_DTINI","D",TamSx3('GYN_DTINI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Data Iní­cio"
		oStruVia:AddField(STR0020,STR0020,"GYN_HRINI","C",TamSx3('GYN_HRINI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Hora Início
		oStruVia:AddField(STR0021,STR0021,"GYN_DTFIM","D",TamSx3('GYN_DTFIM')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Data Fim"
		oStruVia:AddField(STR0022,STR0022,"GYN_HRFIM","C",TamSx3('GYN_HRFIM')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Hora Fim"
		oStruVia:AddField(STR0023,STR0023,"GYN_LOCORI","C",TamSx3('GYN_LOCORI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Local Origem"
		oStruVia:AddField(STR0024,STR0024,"GYN_DSCORI","C",TamSx3('GYN_DSCORI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Desc. Origem"
		oStruVia:AddField(STR0025,STR0025,"GYN_LOCDES","C",TamSx3('GYN_LOCDES')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Local Destino"
		oStruVia:AddField(STR0026,STR0026,"GYN_DSCDES","C",TamSx3('GYN_DSCDES')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Desc. Destino"

	Endif	

	If ValType(oStruTot) == "O"
		oStruTot:AddField(STR0027,STR0027,"QTDVIAGEM","N",6,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) // "Qtd. Viagens"
		oStruTot:AddField(STR0028,STR0028,"TOTLINHA","N",12,2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	// "Linhas"
		oStruTot:AddField(STR0029,STR0029,"TOTEXTRA","N",12,2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	// "Extras"
		oStruTot:AddField(STR0030,STR0030,"TOTADIC","N",12,2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	// "Adicionais"
		oStruTot:AddField(STR0031,STR0031,"TOTOPER","N",12,2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	// "Custos"
		oStruTot:AddField(STR0032,STR0032,"TOTGERAL","N",12,2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	// "Geral"

	Endif	

Return

/*/{Protheus.doc} SetViewStru
//TODO Descrição auto-gerada.
@author flavio.martins
@since 06/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oStruCab, object, descricao
@param oStruVia, object, descricao
@type function
/*/
Static Function SetViewStru(oStruCab, oStruVia, oStruTot)

	If ValType(oStruCab) == "O"

		oStruCab:AddField("CODCLI"		,"01",STR0006,STR0006,{""},"GET","@!",NIL,"SA1",.T.,NIL,NIL,{},NIL,NIL,.F.)			//"Cliente"
		oStruCab:AddField("LOJCLI"		,"02",STR0007,STR0007,{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)			//"Loja"
		oStruCab:AddField("CONTRATODE"	,"03",STR0008,STR0008,{""},"GET","@!",NIL,"GQR001",.T.,NIL,NIL,{},NIL,NIL,.F.)		//"Contrato De"
		oStruCab:AddField("CONTRATOATE"	,"04",STR0009,STR0009,{""},"GET","@!",NIL,"GQR001",.T.,NIL,NIL,{},NIL,NIL,.F.)		//"Contrato Até"
		oStruCab:AddField("LINHADE"		,"05",STR0013,STR0013,{""},"GET","",NIL,"GI2GYD",.T.,NIL,NIL,{},NIL,NIL,.F.)		//"Linha De"
		oStruCab:AddField("LINHAATE"	,"06",STR0014,STR0014,{""},"GET","",NIL,"GI2GYD",.T.,NIL,NIL,{},NIL,NIL,.F.)		//"Linha Até"	
		oStruCab:AddField("DATADE"		,"07",STR0010,STR0010,{""},"GET","",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)				//"Data De"
		oStruCab:AddField("DATAATE"		,"08",STR0011,STR0011,{""},"GET","",NIL,"",.T.,NIL,NIL,{},	NIL,NIL,.F.)			//"Data Até" 
		oStruCab:AddField("TIPOVIA"		,"09",STR0012,STR0012,{""},"GET","",NIL,"",.T.,NIL,NIL,{STR0033,STR0034,STR0035},NIL,NIL,.F.)	//"Viagem Extra"
		oStruCab:AddField("STATUSVIA"	,"10",STR0040,STR0040,{""},"GET","",NIL,"",.T.,NIL,NIL,{STR0042,STR0043,STR0044},NIL,NIL,.F.)	//"Status da Viagem"

	Endif
	
	If ValType(oStruVia) == "O"

		oStruVia:AddField("GYN_CODGY0"	,"01",STR0015,STR0015,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Contrato"
		oStruVia:AddField("GYN_CODIGO"	,"02",STR0016,STR0016,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Código"
		oStruVia:AddField("GYN_EXTRA"	,"03",STR0012,STR0012,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{STR0033,STR0034},NIL,NIL,.F.)	//"Tipo Viagem"
		oStruVia:AddField("GYN_FINAL"	,"04",STR0041,STR0041,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{STR0033,STR0034},NIL,NIL,.F.)	//"Finalizada"
		oStruVia:AddField("GYN_LINCOD"	,"05",STR0018,STR0018,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Cód.Linha"
		If GYN->(FIELDPOS("GYN_EXTCMP")) > 0
			oStruVia:AddField("GYN_EXTCMP"	,"06",STR0012,STR0012,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{STR0033,STR0034},NIL,NIL,.F.)	//"Viagem Extra Sem Linha"
		EndIf
		oStruVia:AddField("GYN_DTINI"	,"07",STR0019,STR0019,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Data Iní­cio"
		oStruVia:AddField("GYN_HRINI"	,"08",STR0020,STR0020,{""},"GET","@R 99:99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Hora Iní­cio"
		oStruVia:AddField("GYN_DTFIM"	,"09",STR0021,STR0021,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Data Fim"
		oStruVia:AddField("GYN_HRFIM"	,"10",STR0022,STR0022,{""},"GET","@R 99:99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Hora Fim"
		oStruVia:AddField("GYN_LOCORI"	,"11",STR0023,STR0023,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Local Origem"
		oStruVia:AddField("GYN_DSCORI"	,"12",STR0024,STR0024,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Desc. Origem"
		oStruVia:AddField("GYN_LOCDES"	,"13",STR0025,STR0025,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Local Destino"
		oStruVia:AddField("GYN_DSCDES"	,"14",STR0026,STR0026,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Desc. Destino"

	Endif
	
	If ValType(oStruTot) == "O"
		oStruTot:AddField("QTDVIAGEM"	,"01",STR0027,STR0027,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)				//"Qtd. Viagem"
		oStruTot:AddField("TOTLINHA"	,"02",STR0028,STR0028,{""},"GET","@E 999,999,999.99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Linhas"	
		oStruTot:AddField("TOTEXTRA"	,"03",STR0029,STR0029,{""},"GET","@E 999,999,999.99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Extras"
		oStruTot:AddField("TOTADIC"		,"04",STR0030,STR0030,{""},"GET","@E 999,999,999.99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Adicionais"
		oStruTot:AddField("TOTOPER"		,"05",STR0031,STR0031,{""},"GET","@E 999,999,999.99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Custos"
		oStruTot:AddField("TOTGERAL"	,"06",STR0032,STR0032,{""},"GET","@E 999,999,999.99",NIL,,.F.,NIL,NIL,{},NIL,NIL,.F.)		//"Total Geral"
	Endif
		
Return

/*/{Protheus.doc} VldActivate
//TODO Descrição auto-gerada.
@author flavio.martins
@since 26/01/2022
@version 1.0
@return ${return}, ${return_description}
@param
@type function
/*/
Static Function VldActivate(oModel)
Local lRet      := .T.
Local cMsgErro  := ''

If !G900VldDic(@cMsgErro)
    lRet := .F.
    FwAlertHelp(cMsgErro, "Atualize o dicionário para utilizar esta rotina") // "Atualize o dicionário para utilizar esta rotina" 
Endif

Return lRet

/*/{Protheus.doc} GA810ATrig
//TODO Descrição auto-gerada.
@author flavio.martins
@since 06/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param cNewValue, characters, descricao
@param cOldValue, characters, descricao
@type function
/*/
Static Function FieldTrigger(oMdl,cField,cNewValue,cOldValue)
Local lRet 		:= .T.

If cField == 'CODCLI'
	oMdl:SetValue('CONTRATODE','')
	oMdl:SetValue('CONTRATOATE','')
Endif

If cField $ 'CONTRATODE|CONTRATOATE'
	oMdl:SetValue('LINHADE','')
	oMdl:SetValue('LINHAATE','')
Endif

Return lRet

/*/{Protheus.doc} GA903ALoad
//TODO Descrição auto-gerada.
@author flavio.martins
@since 06/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function GA903ALoad(oModel)
Local oMdlCab := oModel:GetModel('HEADER')

Return

/*/{Protheus.doc} GA903APesq
//TODO Descrição auto-gerada.
@author flavio.martins
@since 06/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Function GA903APesq(oModel)
Local lRet      := .T.
Local cAliasGYN := GetNextAlias()
Local cQuery	:= ''
Local cCliente  := oModel:GetModel('HEADER'):GetValue('CODCLI')
Local cLoja     := oModel:GetModel('HEADER'):GetValue('LOJCLI')
Local cCntrDe   := oModel:GetModel('HEADER'):GetValue('CONTRATODE')
Local cCntrAte  := oModel:GetModel('HEADER'):GetValue('CONTRATOATE')
Local cDataDe   := oModel:GetModel('HEADER'):GetValue('DATADE')
Local cDataAte  := oModel:GetModel('HEADER'):GetValue('DATAATE')
Local cLinhaDe  := oModel:GetModel('HEADER'):GetValue('LINHADE')
Local cLinhaAte := oModel:GetModel('HEADER'):GetValue('LINHAATE')
Local cTipoVia  := oModel:GetModel('HEADER'):GetValue('TIPOVIA')
Local cStatus	:= oModel:GetModel('HEADER'):GetValue('STATUSVIA')
Local cExtra	:= ''
Local cExtSLin  := ''
Local cExtCmp	:= '%,%'

If cTipoVia = '1'
	cQuery := " AND GYN.GYN_EXTRA = 'T' "
ElseIf cTipoVia = '2'
	cQuery := " AND GYN.GYN_EXTRA = 'F' "
Endif

If cStatus = '1'
	cQuery += " AND GYN.GYN_FINAL = '1'"
ElseIf cStatus = '2'
	cQuery += " AND GYN.GYN_FINAL = '2'"
Endif

If Empty(Alltrim(cLinhaAte))
	cLinhaAte:= Replicate('Z',Len(cLinhaAte))
EndIf

cQuery 	:= '%' + cQuery + '%'



oModel:GetModel('GRIDVIA'):SetNoInsertLine(.F.)
oModel:GetModel('GRIDVIA'):SetNoUpdateLine(.F.) 
oModel:GetModel('GRIDVIA'):SetNoDeleteLine(.F.)

oModel:GetModel('GRIDVIA'):ClearData()


If GYN->(FIELDPOS("GYN_EXTCMP")) > 0
	cExtCmp := "%GYN.GYN_EXTCMP,%"
	BeginSql  Alias cAliasGYN

		SELECT GY0.GY0_NUMERO,
			GYN.GYN_CODIGO,
			GYN.GYN_TIPO,
			GYN.GYN_EXTRA,
			GYN.GYN_LINCOD,
			%Exp:cExtCmp%
			GYN.GYN_DTINI,
			GYN.GYN_HRINI,
			GYN.GYN_DTFIM,
			GYN.GYN_HRFIM,
			GYN.GYN_LOCORI,
			GYN.GYN_LOCDES,
			GYN.GYN_FINAL,
			GI1ORI.GI1_DESCRI DSCORI,
			GI1DES.GI1_DESCRI DSCDES
		FROM %Table:GY0% GY0
			INNER JOIN %Table:GYD% GYD ON GYD.GYD_FILIAL =%xFilial:GYD%
				AND GYD.GYD_NUMERO = GY0.GY0_NUMERO
				AND GYD.GYD_REVISA = GY0.GY0_REVISA
				AND GYD.GYD_CODGI2 BETWEEN %Exp:cLinhaDe% AND %Exp:cLinhaAte%
				AND GYD.%NotDel%
			INNER JOIN %Table:GYN% GYN ON GYN.GYN_FILIAL = %xFilial:GYN%
				AND GYN.GYN_CODGY0 = GYD.GYD_NUMERO
				AND GYN.GYN_LINCOD = GYD.GYD_CODGI2
				AND GYN.GYN_DTINI BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
				AND GYN.GYN_TIPO = '3'
				%Exp:cQuery%
				AND GYN.%NotDel%
			INNER JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %xFilial:GI1%
				AND GI1ORI.GI1_COD = GYN.GYN_LOCORI
				AND GI1ORI.%NotDel%
			INNER JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %xFilial:GI1%
				AND GI1DES.GI1_COD = GYN.GYN_LOCDES
				AND GI1DES.%NotDel%
		WHERE 
			GY0.GY0_CLIENT = %Exp:cCliente%
			AND GY0.GY0_LOJACL = %Exp:cLoja%
			AND GY0.GY0_NUMERO BETWEEN %Exp:cCntrDe% AND %Exp:cCntrAte%
			AND GY0.GY0_ATIVO = '1'
			AND GY0.%NotDel%
		
		UNION
		
		SELECT GY0.GY0_NUMERO,
			GYN.GYN_CODIGO,
			GYN.GYN_TIPO,
			GYN.GYN_EXTRA,
			'',
			%Exp:cExtCmp%
			GYN.GYN_DTINI,
			GYN.GYN_HRINI,
			GYN.GYN_DTFIM,
			GYN.GYN_HRFIM,
			GYN.GYN_LOCORI,
			GYN.GYN_LOCDES,
			GYN.GYN_FINAL,
			GI1ORI.GI1_DESCRI DSCORI,
			GI1DES.GI1_DESCRI DSCDES
		FROM %Table:GY0% GY0
			INNER JOIN %Table:GYD% GYD ON GYD.GYD_FILIAL =%xFilial:GYD%
				AND GYD.GYD_NUMERO = GY0.GY0_NUMERO
				AND GYD.GYD_REVISA = GY0.GY0_REVISA
				AND GYD.GYD_CODGI2 BETWEEN %Exp:cLinhaDe% AND %Exp:cLinhaAte%
				AND GYD.%NotDel%
			INNER JOIN %Table:GYN% GYN ON GYN.GYN_FILIAL = %xFilial:GYN%
				AND GYN.GYN_CODGY0 = GYD.GYD_NUMERO
				AND GYN.GYN_DTINI BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
				AND GYN.GYN_TIPO = '2'
				%Exp:cQuery%
				AND GYN.%NotDel%
			INNER JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %xFilial:GI1%
				AND GI1ORI.GI1_COD = GYN.GYN_LOCORI
				AND GI1ORI.%NotDel%
			INNER JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %xFilial:GI1%
				AND GI1DES.GI1_COD = GYN.GYN_LOCDES
				AND GI1DES.%NotDel%
		WHERE 
			GY0.GY0_CLIENT = %Exp:cCliente%
			AND GY0.GY0_LOJACL = %Exp:cLoja%
			AND GY0.GY0_NUMERO BETWEEN %Exp:cCntrDe% AND %Exp:cCntrAte%
			AND GY0.GY0_ATIVO = '1'
			AND GY0.%NotDel%
		ORDER BY GY0.GY0_NUMERO, GYN.GYN_LINCOD, GYN.GYN_CODIGO

	EndSql
else
	BeginSql  Alias cAliasGYN
		SELECT GY0.GY0_NUMERO,
			GYN.GYN_CODIGO,
			GYN.GYN_TIPO,
			GYN.GYN_EXTRA,
			GYN.GYN_LINCOD,
			GYN.GYN_DTINI,
			GYN.GYN_HRINI,
			GYN.GYN_DTFIM,
			GYN.GYN_HRFIM,
			GYN.GYN_LOCORI,
			GYN.GYN_LOCDES,
			GYN.GYN_FINAL,
			GI1ORI.GI1_DESCRI DSCORI,
			GI1DES.GI1_DESCRI DSCDES
		FROM %Table:GY0% GY0
			INNER JOIN %Table:GYD% GYD ON GYD.GYD_FILIAL =%xFilial:GYD%
				AND GYD.GYD_NUMERO = GY0.GY0_NUMERO
				AND GYD.GYD_REVISA = GY0.GY0_REVISA
				AND GYD.GYD_CODGI2 BETWEEN %Exp:cLinhaDe% AND %Exp:cLinhaAte%
				AND GYD.%NotDel%
			INNER JOIN %Table:GYN% GYN ON GYN.GYN_FILIAL = %xFilial:GYN%
				AND GYN.GYN_CODGY0 = GYD.GYD_NUMERO
				AND GYN.GYN_LINCOD = GYD.GYD_CODGI2
				AND GYN.GYN_DTINI BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
				AND GYN.GYN_TIPO = '3'
				%Exp:cQuery%
				AND GYN.%NotDel%
			INNER JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %xFilial:GI1%
				AND GI1ORI.GI1_COD = GYN.GYN_LOCORI
				AND GI1ORI.%NotDel%
			INNER JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %xFilial:GI1%
				AND GI1DES.GI1_COD = GYN.GYN_LOCDES
				AND GI1DES.%NotDel%
		WHERE 
			GY0.GY0_CLIENT = %Exp:cCliente%
			AND GY0.GY0_LOJACL = %Exp:cLoja%
			AND GY0.GY0_NUMERO BETWEEN %Exp:cCntrDe% AND %Exp:cCntrAte%
			AND GY0.GY0_ATIVO = '1'
			AND GY0.%NotDel%
		
		ORDER BY GY0.GY0_NUMERO, GYN.GYN_LINCOD, GYN.GYN_CODIGO

	EndSql
EndIf



If (cAliasGYN)->(Eof())
	SomaTotais(oModel)
	FwAlertHelp(STR0036, STR0037) // "Viagens não encontradas", "Verifique os parâmetros"
	Return
Endif

While !(cAliasGYN)->(Eof())

    If !(oModel:GetModel('GRIDVIA'):IsEmpty())
		oModel:GetModel('GRIDVIA'):AddLine()
	Endif

	cExtra 		:= Iif ((cAliasGYN)->GYN_EXTRA = 'T','1','2')

	If GYN->(FIELDPOS("GYN_EXTCMP")) > 0
		cExtSLin 	:= Iif ((cAliasGYN)->GYN_EXTCMP = 'T','1','2')
		oModel:GetModel('GRIDVIA'):LoadValue('GYN_EXTCMP', cExtSLin)
	EndIf

    oModel:GetModel('GRIDVIA'):LoadValue('GYN_CODGY0', (cAliasGYN)->GY0_NUMERO)
    oModel:GetModel('GRIDVIA'):LoadValue('GYN_CODIGO', (cAliasGYN)->GYN_CODIGO)
    oModel:GetModel('GRIDVIA'):LoadValue('GYN_EXTRA', cExtra)
    oModel:GetModel('GRIDVIA'):LoadValue('GYN_LINCOD', (cAliasGYN)->GYN_LINCOD)
    oModel:GetModel('GRIDVIA'):LoadValue('GYN_DTINI', StoD((cAliasGYN)->GYN_DTINI))
    oModel:GetModel('GRIDVIA'):LoadValue('GYN_HRINI', (cAliasGYN)->GYN_HRINI)
    oModel:GetModel('GRIDVIA'):LoadValue('GYN_DTFIM', StoD((cAliasGYN)->GYN_DTFIM))
    oModel:GetModel('GRIDVIA'):LoadValue('GYN_HRFIM', (cAliasGYN)->GYN_HRFIM)
    oModel:GetModel('GRIDVIA'):LoadValue('GYN_LOCORI', (cAliasGYN)->GYN_LOCORI)
    oModel:GetModel('GRIDVIA'):LoadValue('GYN_DSCORI', (cAliasGYN)->DSCORI)
    oModel:GetModel('GRIDVIA'):LoadValue('GYN_LOCDES', (cAliasGYN)->GYN_LOCDES)
    oModel:GetModel('GRIDVIA'):LoadValue('GYN_DSCDES', (cAliasGYN)->DSCDES)
    oModel:GetModel('GRIDVIA'):LoadValue('GYN_FINAL', (cAliasGYN)->GYN_FINAL)
	
	(cAliasGYN)->(dbSkip())

End

oModel:GetModel('GRIDVIA'):GoLine(1)

oModel:GetModel('GRIDVIA'):SetNoInsertLine(.T.)
oModel:GetModel('GRIDVIA'):SetNoDeleteLine(.T.)

SomaTotais(oModel)

(cAliasGYN)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} SomaTotais
//TODO Descrição auto-gerada.
@author flavio.martins
@since 07/04/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function SomaTotais(oModel)
Local cAliasTmp		:= GetNextAlias()
Local cCliente		:= oModel:GetModel('HEADER'):GetValue('CODCLI')
Local cLoja			:= oModel:GetModel('HEADER'):GetValue('LOJCLI')
Local cDataDe		:= oModel:GetModel('HEADER'):GetValue('DATADE')
Local cDataAte		:= oModel:GetModel('HEADER'):GetValue('DATAATE')
Local cContrDe		:= oModel:GetModel('HEADER'):GetValue('CONTRATODE')
Local cContrAte		:= oModel:GetModel('HEADER'):GetValue('CONTRATOATE')
Local cLinhaDe		:= oModel:GetModel('HEADER'):GetValue('LINHADE')
Local cLinhaAte		:= oModel:GetModel('HEADER'):GetValue('LINHAATE')
Local cTipoVia		:= oModel:GetModel('HEADER'):GetValue('TIPOVIA')
Local cStatus		:= oModel:GetModel('HEADER'):GetValue('STATUSVIA')
Local cQuery		:= ''
Local nQtdVia       := 0
Local nQtdDias      := 0
Local nVlrLinha     := 0
Local nVlrAdic      := 0
Local nVlrOper      := 0
Local nVlrTot       := 0
Local nVlrTotGer    := 0
Local nTotLinha		:= 0
Local nTotVia		:= 0
Local nTotExt		:= 0
Local nTotAdic		:= 0
Local nTotOper		:= 0
Local nTotGer		:= 0
Local aTotais   	:= {}
Local cExtCmp		:= '%%'



If Empty(Alltrim(cLinhaAte))
	cLinhaAte:= Replicate('Z',Len(cLinhaAte))
EndIf

If cTipoVia = '1'
	cQuery := " AND GYN_EXTRA = 'T' "
ElseIf cTipoVia = '2'
	cQuery := " AND GYN_EXTRA = 'F' "
Endif

If cStatus = '1'
	cQuery += " AND GYN_FINAL = '1'"
ElseIf cStatus = '2'
	cQuery += " AND GYN_FINAL = '2'"
Endif

cQuery := '%' + cQuery + '%'

If(GYN->(FIELDPOS("GYN_EXTCMP")) > 0,cExtCmp := "% AND (GYN_LINCOD = GYD.GYD_CODGI2 OR GYN_EXTCMP = 'T')%",cExtCmp := "% AND (GYN_LINCOD = GYD.GYD_CODGI2)%")

BeginSql Alias cAliasTmp

    SELECT GYD.GYD_NUMERO,
           GYD.GYD_CODGYD,
           GYD.GYD_VLRTOT,
           GYD.GYD_VLREXT,
		   GYD.GYD_PRECON,
		   GYD.GYD_VLRACO,
		   (GYD.GYD_KMIDA +
            GYD.GYD_KMVOLT +
            GYD.GYD_KMGRRD +
            GYD.GYD_KMRDGR) AS KMTOTAL,
      (SELECT COALESCE(SUM(GYX_VALTOT), 0) GYX_VALTOT
       FROM %Table:GYX%
       WHERE GYX_FILIAL = GYD.GYD_FILIAL
         AND GYX_CODIGO = GYD.GYD_NUMERO
		 AND GYX_REVISA = GYD.GYD_REVISA
         AND GYX_ITEM = GYD.GYD_CODGYD
         AND %NotDel%) GYX_VALTOT,
      (SELECT COALESCE(SUM(GQZ_VALTOT), 0) GQZ_VALTOT
       FROM %Table:GQZ%
       WHERE GQZ_FILIAL = GYD.GYD_FILIAL
         AND GQZ_CODIGO = GYD.GYD_NUMERO
		 AND GQZ_REVISA = GYD.GYD_REVISA
         AND GQZ_ITEM = GYD.GYD_CODGYD
         AND %NotDel%) GQZ_VALTOT,
      (SELECT COALESCE(SUM(GQJ_VALTOT), 0) GQJ_VALTOT
       FROM %Table:GQJ%
       WHERE GQJ_FILIAL = GYD.GYD_FILIAL
         AND GQJ_CODIGO = GYD.GYD_NUMERO
		 AND GQJ_REVISA = GYD.GYD_REVISA
         AND %NotDel%) GQJ_VALTOT,
      (SELECT COUNT(DISTINCT(GYN_CODIGO)) QTDVIAGENS
       FROM %Table:GYN%
       WHERE GYN_FILIAL = %xFilial:GYN%
         AND GYN_CODGY0 = GYD.GYD_NUMERO
         %Exp:cExtCmp%
         AND GYN_DTINI BETWEEN %Exp:cDataDe%  AND %Exp:cDataAte%
         AND GYN_TIPO IN ('3','2')
		 %Exp:cQuery%
         AND %NotDel%) QTDVIAGENS,
      (SELECT COUNT(DISTINCT(GYN_DTINI)) 
       FROM %Table:GYN%
       WHERE GYN_FILIAL = %xFilial:GYN%
         AND GYN_CODGY0 = GYD.GYD_NUMERO
         %Exp:cExtCmp%
         AND GYN_DTINI BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
         AND GYN_TIPO IN ('3','2')
		 %Exp:cQuery%
         AND %NotDel%) AS QTDDIAS
	FROM %Table:GY0% GY0 
	INNER JOIN %Table:GYD% GYD ON GYD.GYD_FILIAL = GY0.GY0_FILIAL
	AND GYD.GYD_NUMERO = GY0.GY0_NUMERO
	AND GYD.GYD_REVISA = GY0.GY0_REVISA
	AND GYD.GYD_CODGI2 BETWEEN %Exp:cLinhaDe% AND %Exp:cLinhaAte%
	AND GYD.%NotDel%
    WHERE GY0.GY0_FILIAL = %xFilial:GY0%
		AND GY0.GY0_CLIENT = %Exp:cCliente%
		AND GY0.GY0_LOJACL = %Exp:cLoja%
		AND GY0.GY0_NUMERO BETWEEN %Exp:cContrDe% AND %Exp:cContrAte%
		AND GY0.GY0_ATIVO = '1'
		AND GY0.%NotDel%
EndSql

While  !(cAliasTmp)->(Eof())

	If (cAliasTmp)->QTDVIAGENS > 0
		nVlrAdic    := IIF((cAliasTmp)->GYX_VALTOT > 0,(cAliasTmp)->GYX_VALTOT,(cAliasTmp)->GQJ_VALTOT)
		nVlrOper    := (cAliasTmp)->GQZ_VALTOT
		
		If (cAliasTmp)->GYD_PRECON == '1'
			nVlrLinha   := (cAliasTmp)->GYD_VLRTOT
			nVlrTot     := nVlrLinha + nVlrAdic + nVlrOper
			nQtdVia     := (cAliasTmp)->QTDVIAGENS
			nVlrTotGer  := nVlrTot + nVlrAdic + nVlrOper
		ElseIf (cAliasTmp)->GYD_PRECON == '2'
			nVlrLinha   := (cAliasTmp)->GYD_VLRTOT
			nQtdVia     := (cAliasTmp)->QTDVIAGENS
			nVlrTot     := ((nQtdVia * (cAliasTmp)->KMTOTAL) * nVlrLinha + (nQtdVia * (cAliasTmp)->GYD_VLRACO))
			nVlrTotGer  := nVlrTot + nVlrAdic + nVlrOper
		ElseIf (cAliasTmp)->GYD_PRECON == '3'
			nVlrLinha   := (cAliasTmp)->GYD_VLRTOT
			nQtdVia     := (cAliasTmp)->QTDVIAGENS
			nVlrTot     := ((nQtdVia * nVlrLinha) + (nQtdVia * (cAliasTmp)->GYD_VLRACO))
			nVlrTotGer  := nVlrTot + nVlrAdic + nVlrOper
		ElseIf (cAliasTmp)->GYD_PRECON == '4'
			nVlrLinha   := (cAliasTmp)->GYD_VLRTOT
			nQtdDias    := (cAliasTmp)->QTDDIAS
			nQtdVia     := (cAliasTmp)->QTDVIAGENS
			nVlrTot     := ((nQtdDias * nVlrLinha) + (nQtdVia * (cAliasTmp)->GYD_VLRACO))
			nVlrTotGer  := nVlrTot + nVlrAdic + nVlrOper
		Endif

		nTotLinha += nVlrLinha
		nTotVia	  += nQtdVia
		nTotAdic  += nVlrAdic
		nTotOper  += nVlrOper
		nTotGer   += nVlrTotGer
	Endif

	(cAliasTmp)->(dbSkip())

End

oModel:GetModel('TOTAL'):LoadValue('QTDVIAGEM', nTotVia)
oModel:GetModel('TOTAL'):LoadValue('TOTLINHA', nTotLinha)
oModel:GetModel('TOTAL'):LoadValue('TOTEXTRA', nTotExt)
oModel:GetModel('TOTAL'):LoadValue('TOTADIC', nTotAdic)
oModel:GetModel('TOTAL'):LoadValue('TOTOPER', nTotOper)
oModel:GetModel('TOTAL'):LoadValue('TOTGERAL', nTotGer)

(cAliasTmp)->(dbCloseArea())

Return aTotais
