#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA810A.CH"


/*/{Protheus.doc} GTPA810A
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTPA810A()
Local aEnableButtons := GtpBtnView()
	
	FwExecView(STR0001,"VIEWDEF.GTPA810A",MODEL_OPERATION_INSERT,,,,,aEnableButtons,,,,) //"Inclusão"
		
Return 

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCab	:= FwFormModelStruct():New() 
Local oStruLin	:= FwFormModelStruct():New()
Local oStruCte	:= FwFormModelStruct():New() 
Local oStruVia	:= FwFormModelStruct():New() 
Local bLoad		:= {|oModel|  GA810ALoad(oModel)}

oModel := MPFormModel():New("GTPA810A",,,)

SetMdlStru(oStruCab,oStruLin,oStruCte,oStruVia)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddGrid( 'GRIDLIN', 'HEADER', oStruLin,,,,,)
oModel:AddGrid( 'GRIDCTE', 'GRIDLIN', oStruCte,,,,,)
oModel:AddGrid( 'GRIDVIA', 'GRIDLIN', oStruVia,,,,,)

oModel:SetDescription("CT-e X Manifesto")
oModel:GetModel("HEADER"):SetDescription(STR0001) 	//"Filtro" 
oModel:GetModel("GRIDLIN"):SetDescription(STR0002)	//"Linhas" 
oModel:GetModel("GRIDCTE"):SetDescription(STR0004)	//"CT-E" 
oModel:GetModel("GRIDVIA"):SetDescription(STR0005)	//"Viagens") 

oModel:GetModel("GRIDLIN"):SetOptional(.T.)
oModel:GetModel("GRIDCTE"):SetOptional(.T.)
oModel:GetModel("GRIDVIA"):SetOptional(.T.)

oModel:GetModel("GRIDLIN"):SetNoInsertLine(.T.)
oModel:GetModel("GRIDCTE"):SetNoInsertLine(.T.)
oModel:GetModel("GRIDVIA"):SetNoInsertLine(.T.)
oModel:GetModel("GRIDLIN"):SetNoUpdateLine(.T.)
oModel:GetModel("GRIDCTE"):SetNoUpdateLine(.T.)
oModel:GetModel("GRIDVIA"):SetNoUpdateLine(.T.)
oModel:GetModel("GRIDLIN"):SetNoDeleteLine(.T.)
oModel:GetModel("GRIDCTE"):SetNoDeleteLine(.T.)
oModel:GetModel("GRIDVIA"):SetNoDeleteLine(.T.)

oStruCab:SetProperty('CODAGE', MODEL_FIELD_VALID, {|oMdl,cField,cNewValue,cOldValue| ValidUserAg(oMdl,cField,cNewValue,cOldValue) } )
oStruVia:SetProperty('GYN_MARK',MODEL_FIELD_VALID,{|oMdl,cField,cNewValue,cOldValue|GA810AVld(oMdl,cField,cNewValue,cOldValue)})

oStruLin:AddTrigger("GI2_MARK","GI2_MARK",{ || .T. }, { |oMdl,cField,xVal|GA810ATrig(oMdl,cField,xVal)})
oStruVia:AddTrigger("GYN_MARK","GYN_MARK",{ || .T. }, { |oMdl,cField,xVal|GA810ATrig(oMdl,cField,xVal)})

oStruCab:SetProperty("DTCTEINI", MODEL_FIELD_INIT, {|| dDataBase })
oStruCab:SetProperty("DTCTEFIM", MODEL_FIELD_INIT, {|| dDataBase })
oStruCab:SetProperty("DTENVINI", MODEL_FIELD_INIT, {|| dDataBase })
oStruCab:SetProperty("DTENVFIM", MODEL_FIELD_INIT, {|| dDataBase })

oModel:SetPrimaryKey({})

oModel:SetCommit({|oModel| G810ACommit(oModel)})

Return(oModel)

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA810A")
Local oStruCab	:= FwFormViewStruct():New()
Local oStruLin	:= FwFormViewStruct():New()
Local oStruCte	:= FwFormViewStruct():New()
Local oStruVia	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruCab,oStruLin,oStruCte,oStruVia)

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:SetDescription(STR0007) //"Manifesto - CT-e"

oView:AddField('VIEW_HEADER' ,oStruCab,'HEADER')
oView:AddGrid("VIEW_LIN", oStruLin, "GRIDLIN" )
oView:AddGrid("VIEW_CTE", oStruCte, "GRIDCTE" )
oView:AddGrid("VIEW_VIA", oStruVia, "GRIDVIA" )

oView:CreateHorizontalBox('FILTRO', 20)
oView:CreateHorizontalBox('GRID1', 50)
oView:CreateHorizontalBox('GRID2', 30)

oView:CreateVerticalBox('BOX_LIN',31,'GRID1')
oView:CreateVerticalBox('BOX_SEP',01,'GRID1')
oView:CreateVerticalBox('BOX_CTE',68,'GRID1')

oView:SetOwnerView('VIEW_HEADER','FILTRO')
oView:SetOwnerView('VIEW_LIN','BOX_LIN')
oView:SetOwnerView('VIEW_CTE','BOX_CTE')
oView:SetOwnerView('VIEW_VIA','GRID2')

oView:EnableTitleView("VIEW_HEADER",STR0001)	//"Filtro"
oView:EnableTitleView("VIEW_LIN",STR0002)		//"Linhas"
oView:EnableTitleView("VIEW_CTE",STR0004)		//"CT-e"
oView:EnableTitleView("VIEW_VIA",STR0005)		//"Viagens"

oView:AddUserButton(STR0008, "", {|| GA810APesq(oModel)},,VK_F5) //"Pesquisar"

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:ShowInsertMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStru
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oStruCab, object, descricao
@param oStruLin, object, descricao
@param oStruCte, object, descricao
@param oStruVia, object, descricao
@type function
/*/
Static Function SetMdlStru(oStruCab,oStruLin,oStruCte,oStruVia)

	If ValType(oStruCab) == "O"
	
		oStruCab:AddField(STR0009,STR0009,"CODAGE","C"	,TamSx3('GI6_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Código da Agência"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0059,STR0059,"DESAGE","C"	,TamSx3('GI6_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Descr. Agência"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0010,STR0010,"DTCTEINI","D",8,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 						//"Data Encomenda De"
		oStruCab:AddField(STR0011,STR0011,"DTCTEFIM","D",8,0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.)					//"Data Encomenda Até"
		oStruCab:AddField(STR0012,STR0012,"DTENVINI","D",8,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)						//"Data de Viagem De"
		oStruCab:AddField(STR0013,STR0013,"DTENVFIM","D",8,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)						//"Data de Viagem Até"
		oStruCab:AddField(STR0014,STR0014,"SERIEDE","C",3,0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.)					//"Série De"
		oStruCab:AddField(STR0015,STR0015,"SERIEATE","C",3,0,{|| .T.},{|| .T.},{},.F.,	NIL,.F.,.T.,.T.)					//"Série Ate"		

		oStruCab:AddTrigger("CODAGE","CODAGE",{ || .T. }, { |oMdl,cField,xVal|GA810ATrig(oMdl,cField,xVal)})
		
	Endif	
	
	If ValType(oStruLin) == "O"
	
		oStruLin:AddField("",		"",		"GI2_MARK","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)
		oStruLin:AddField(STR0016,STR0016,	"GI2_COD","C",TamSx3('GI2_COD')[1],0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.F.,.T.)		//"Cód. Linha"
		oStruLin:AddField(STR0017,STR0017,"GI2_PREFIX","C",TamSx3('GI2_PREFIX')[1],0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.T.,.F.)	//"Prefixo"
		oStruLin:AddField(STR0018,STR0018,"GI2_NUMLIN","C",TamSx3('GI2_NUMLIN')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Nr. Linha"
	
	Endif						
	
	If ValType(oStruCte) == "O"
	
		oStruCte:AddField("","","G99_MARK","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)
		oStruCte:AddField(STR0019,STR0019,"G99_CODIGO","C",TamSx3('G99_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Cód. Enc."
		oStruCte:AddField(STR0020,STR0020,"G99_DTEMIS","D",TamSx3('G99_DTEMIS')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Dt. Emissão"	
		oStruCte:AddField(STR0021,STR0021,"G99_HREMIS","C",TamSx3('G99_HREMIS')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Hr. Emissão"
		oStruCte:AddField(STR0022,STR0022,"G99_DTPREV","D",TamSx3('G99_DTPREV')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Dt.Prev.Entr."
		oStruCte:AddField(STR0023,STR0023,"G99_HRPREV","C",TamSx3('G99_HRPREV')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Hr.Prev.Entr."
		oStruCte:AddField(STR0024,STR0024,"NOMEREM","C",TamSx3('A1_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		//"Nome Remet."
		oStruCte:AddField(STR0025,STR0025,"TPCLIREM","C",TamSx3('A1_PESSOA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		//"Tipo Remet."
		oStruCte:AddField(STR0026,STR0026,"DOCCLIREM","C",TamSx3('A1_CGC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		//"Doc. Remet."
		oStruCte:AddField(STR0027,STR0027,"NOMEDES","C",TamSx3('A1_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		//"Nome Dest."	
		oStruCte:AddField(STR0028,STR0028,"G99_CODREC","C",TamSx3('G99_CODREC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Ag.Receb."
		oStruCte:AddField(STR0029,STR0029,"GI6_DESCRI","C",TamSx3('GI6_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Nome Receb."
		oStruCte:AddField(STR0030,STR0030,"G99_CODPRO","C",TamSx3('G99_CODPRO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Cód.Prod."
		oStruCte:AddField(STR0031,STR0031,"B1_DESC","C",TamSx3('B1_DESC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		//"Descr.Prod."
		oStruCte:AddField(STR0032,STR0032,"G99_PESO","N",TamSx3('G99_PESO')[1],4,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		//"Peso"
		oStruCte:AddField(STR0033,STR0033,"G99_PESCUB","N",TamSx3('G99_PESCUB')[1],4,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Peso Cubado"
		oStruCte:AddField(STR0034,STR0034,"G99_QTDVO","N",TamSx3('G99_QTDVO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Qtd.Volumes"
		oStruCte:AddField(STR0035,STR0035,"G99_VALOR","N",TamSx3('G99_VALOR')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Vlr.Serviço"
		oStruCte:AddField(STR0036,STR0036,"G99_CHVCTE","C",TamSx3('G99_CHVCTE')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Chave CT-e"
		oStruCte:AddField(STR0037,STR0037,"GIJ_NOMESE","C",TamSx3('GIJ_NOMESE')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Nome Segur."
		oStruCte:AddField(STR0038,STR0038,"GIJ_CNPJSE","C",TamSx3('GIJ_CNPJSE')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Cnpj Segur."
		oStruCte:AddField(STR0039,STR0039,"GIJ_NUMAPO","C",TamSx3('GIJ_NUMAPO')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Núm.Apólice"
		oStruCte:AddField(STR0040,STR0040,"GIJ_NUMAVB","C",TamSx3('GIJ_NUMAVB')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Núm.Averb."

	Endif						

	If ValType(oStruVia) == "O"
	
		oStruVia:AddField("","","GYN_MARK","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)
		oStruVia:AddField(STR0041,STR0041,"GYN_CODIGO","C",TamSx3('GYN_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Cód. Viagem"
		oStruVia:AddField(STR0042,STR0042,"GYN_DTINI","D",TamSx3('GYN_DTINI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Data Início"
		oStruVia:AddField(STR0043,STR0043,"GYN_HRINI","C",TamSx3('GYN_HRINI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Hora Início"
		oStruVia:AddField(STR0044,STR0044,"GYN_DTFIM","D",TamSx3('GYN_DTFIM')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Data Fim"
		oStruVia:AddField(STR0045,STR0045,"GYN_HRFIM","C",TamSx3('GYN_HRFIM')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Hora Fim"
		oStruVia:AddField(STR0046,STR0046,"GYN_CONF","C",TamSx3('GYN_CONF')[1],0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.T.,.T.)		//"Sts. Viagem"
		oStruVia:AddField(STR0047,STR0047,"T9_CODBEM","C",TamSx3('T9_CODBEM')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Cód. Veic."
		oStruVia:AddField(STR0048,STR0048,"T9_NOME","C",TamSx3('T9_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		//"Descr.Veic."
		oStruVia:AddField(STR0049,STR0049,"T9_PLACA","C",TamSx3('T9_PLACA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	//"Placa"
		oStruVia:AddField(STR0050,STR0050,"DA3_TARA","N",TamSx3('DA3_TARA')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		//"Tara"
	
	Endif	
	
Return

/*/{Protheus.doc} SetViewStru
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oStruCab, object, descricao
@param oStruLin, object, descricao
@param oStruCte, object, descricao
@param oStruVia, object, descricao
@type function
/*/
Static Function SetViewStru(oStruCab,oStruLin,oStruCte,oStruVia)

	If ValType(oStruCab) == "O"
	
		oStruCab:AddField("CODAGE","01",STR0009,STR0009,{""},"GET","@!",NIL,"GI6ENC",.T.,NIL,NIL,{},NIL,NIL,.F.)		//"Cód. Agência"
		oStruCab:AddField("DESAGE","02",STR0059,STR0059,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)				//"Descr. Agência"
		oStruCab:AddField("DTCTEINI","03",STR0010,STR0010,{""},"GET","",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)				//"Data Encomenda De"
		oStruCab:AddField("DTCTEFIM","04",STR0011,STR0011,{""},"GET","",NIL,"",.T.,NIL,NIL,{},	NIL,NIL,.F.)			//"Data Encomenda Até"
		oStruCab:AddField("DTENVINI","05",STR0012,STR0012,{""},"GET","",	NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)			//"Data Viagem De
		oStruCab:AddField("DTENVFIM","06",STR0013,STR0013,{""},"GET","",	NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)			//"Data Viagem Até"
		oStruCab:AddField("SERIEDE","07",STR0014,STR0014,{""},"GET","@!",NIL,	"G99SER",.T.,NIL,NIL,{},NIL,NIL,.F.)	//"Série De"
		oStruCab:AddField("SERIEATE","08",STR0015,STR0015,{""},"GET","@!",NIL,"G99SER",.T.,NIL,NIL,{},NIL,NIL,.F.)		//"Série Até"

	Endif
	
	If ValType(oStruLin) == "O"
	
		oStruLin:AddField("GI2_MARK","01","","",{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)
		oStruLin:AddField("GI2_COD","02",STR0016,STR0016,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)				//"Cód. Linha"
		oStruLin:AddField("GI2_PREFIX","03",STR0017,STR0017,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Prefixo"
		oStruLin:AddField("GI2_NUMLIN","04",STR0018,STR0018,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Nr. Linha"

	Endif
	
	If ValType(oStruCte) == "O"
	
		oStruCte:AddField("G99_MARK","01","","",{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)
		oStruCte:AddField("G99_CODIGO","02",STR0019,STR0019,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Cód. Enc."
		oStruCte:AddField("G99_DTEMIS","03",STR0020,STR0020,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Dt. Emissão"
		oStruCte:AddField("G99_HREMIS","04",STR0021,STR0021,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Hr. Emissão"
		oStruCte:AddField("G99_DTPREV","05",STR0022,STR0022,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Dt.Prev.Entr."
		oStruCte:AddField("G99_HRPREV","06",STR0023,STR0023,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Hr.Prev.Entr."
		oStruCte:AddField("NOMEREM","07",STR0024,STR0024,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)				//"Nome Remet."
		oStruCte:AddField("TPCLIREM","08",STR0025,STR0025,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Tipo Remet."
		oStruCte:AddField("DOCCLIREM","09",STR0026,STR0026,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Doc. Remet."
		oStruCte:AddField("NOMEDES","10",STR0027,STR0027,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)				//"Nome Dest."
		oStruCte:AddField("G99_CODREC","11",STR0028,STR0028,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Ag.Receb."
		oStruCte:AddField("GI6_DESCRI","12",STR0029,STR0029,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Nome Receb."
		oStruCte:AddField("G99_CODPRO","13",STR0030,STR0030,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Cód.Prod."
		oStruCte:AddField("B1_DESC","14",STR0031,STR0031,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)				//"Descr.Prod."
		oStruCte:AddField("G99_PESO","15",STR0032,STR0032,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Peso"
		oStruCte:AddField("G99_PESCUB","16",STR0033,STR0033,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Peso Cubado"
		oStruCte:AddField("G99_QTDVO","17",STR0034,STR0034,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Qtd.Volumes"
		oStruCte:AddField("G99_VALOR","18",STR0035,STR0035,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Vlr.Serviço"
		oStruCte:AddField("G99_CHVCTE","19",STR0036,STR0036,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Chave CT-e"
		oStruCte:AddField("GIJ_CNPJSE","20",STR0037,STR0037,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Nome Segur."
		oStruCte:AddField("GIJ_NOMESE","21",STR0038,STR0038,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Cnpj Segur."
		oStruCte:AddField("GIJ_NUMAPO","22",STR0039,STR0039,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Núm.Apólice"
		oStruCte:AddField("GIJ_NUMAVB","23",STR0040,STR0040,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Núm.Averb."
		
	Endif
	
	If ValType(oStruVia) == "O"
	
		oStruVia:AddField("GYN_MARK","01","","",{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)	
		oStruVia:AddField("GYN_CODIGO","02",STR0041,STR0041,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Cód. Viagem"
		oStruVia:AddField("GYN_DTINI","03",STR0042,STR0042,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Data Início"
		oStruVia:AddField("GYN_HRINI","04",STR0043,STR0043,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Hora Início"
		oStruVia:AddField("GYN_DTFIM","05",STR0044,STR0044,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Data Fim"
		oStruVia:AddField("GYN_HRFIM","06",STR0045,STR0045,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Hora Fim"
		oStruVia:AddField("GYN_CONF","07",STR0046,STR0046,{""},"COMBO","@!",NIL,"",.F.,NIL,NIL,{STR0051,STR0052,STR0053},NIL,NIL,.F.)	//"Sts. Viagem" "1=Confirmado" "2=Não Confirmado" "3=Confirmado Parcialmente"
		oStruVia:AddField("T9_CODBEM","08",STR0047,STR0047,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Cód. Veic."
		oStruVia:AddField("T9_NOME","09",STR0048,STR0048,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)				//"Descr. Veic."
		oStruVia:AddField("T9_PLACA","10",STR0049,STR0049,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Placa"
		oStruVia:AddField("DA3_TARA","11",STR0050,STR0050,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			//"Tara"

	Endif
	
Return

/*/{Protheus.doc} GA810AVld
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param cNewValue, characters, descricao
@param cOldValue, characters, descricao
@type function
/*/
Static Function GA810AVld(oMdl,cField,cNewValue,cOldValue)
Local lRet := .T.

If cField == 'GYN_MARK' .And. cNewValue .And. oMdl:GetValue('GYN_CONF') != '1'
	
	lRet := .F.
	oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField, "GA810AVld",STR0054,STR0055) //"Apenas viagens confirmadas podem ser selecionadas", "Selecione uma viagem confirmada"

Endif

Return lRet

/*/{Protheus.doc} GA810ATrig
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param cNewValue, characters, descricao
@param cOldValue, characters, descricao
@type function
/*/
Static Function GA810ATrig(oMdl,cField,cNewValue,cOldValue)
Local lRet 		:= .T.
Local oView		:= FwViewActive()
Local nLnPos	:= 0
Local nX		:= 0

If cField == 'CODAGE'

	oMdl:SetValue('DESAGE',Posicione('GI6', 1, xFilial('GI6')+oMdl:GetValue('CODAGE'),'GI6_DESCRI'))

Endif

If cField == 'GI2_MARK'

	nLnPos := oMdl:GetLine()
	
	If cNewValue
		
		For nX := 1 To oMdl:Length()
		
			oMdl:GoLine(nX)
		
			If ((oMdl:GetLine() <> nLnPos) .And. oMdl:GetValue(cField))
				G810SetMark(oMdl, nX, .F.)
				oMdl:LoadValue(cField,.F.)
			Endif
	
		Next
		
		oMdl:GoLine(nLnPos)
		G810SetMark(oMdl, nLnPos, .T.)

	Else
		G810SetMark(oMdl, nLnPos, .F.)
		oMdl:SetValue(cField,.F.)
	Endif

ElseIf cField == 'GYN_MARK' 

	nLnPos := oMdl:GetLine()

	If cNewValue

		For nX := 1 To oMdl:Length()
		
			oMdl:GoLine(nX)
			
			If ((oMdl:GetLine() <> nLnPos) .And. oMdl:GetValue(cField))
				oMdl:LoadValue(cField,.F.)
			Endif
		
		Next

	Endif 

	oMdl:GoLine(nLnPos)
	
Endif

oView:Refresh()

Return lRet

/*/{Protheus.doc} G810SetMark
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}
@param nLnPos, numeric, descricao
@param lMark, logical, descricao
@type function
/*/
Static Function G810SetMark(oMdl, nLnPos, lMark)
Local oModel	:= oMdl:GetModel()
Local nX		:= 0

	oModel:GetModel("GRIDLIN"):GoLine(nLnPos)
	
	If !(lMark)
		For nX := 1 To oModel:GetModel("GRIDVIA"):Length() 
		
			oModel:GetModel("GRIDVIA"):GoLine(nX)
			oModel:GetModel("GRIDVIA"):LoadValue('GYN_MARK',lMark)
	
		Next
	Endif

	For nX := 1 To oModel:GetModel("GRIDCTE"):Length()

		oModel:GetModel("GRIDCTE"):GoLine(nX)
		oModel:GetModel("GRIDCTE"):LoadValue('G99_MARK',lMark)

	Next
	
	oModel:GetModel("GRIDCTE"):GoLine(1)
	oModel:GetModel("GRIDVIA"):GoLine(1)

Return

/*/{Protheus.doc} GA810ALoad
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function GA810ALoad(oModel)
Local oMdlCab := oModel:GetModel('HEADER')

Return

/*/{Protheus.doc} GA810APesq
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function GA810APesq(oModel)
Local lRet := .T.
Local cAliasG99	:= GetNextAlias()
Local oMdlHead	:= oModel:GetModel('HEADER')
Local oMdlLin	:= oModel:GetModel('GRIDLIN')
Local oMdlVia	:= oModel:GetModel('GRIDVIA')
Local oMdlCte	:= oModel:GetModel('GRIDCTE')
Local cAgencia	:= oMdlHead:GetValue('CODAGE')
Local cDtCteIni	:= oMdlHead:GetValue('DTCTEINI')
Local cDtCteFim	:= oMdlHead:GetValue('DTCTEFIM')
Local cDtEnvIni	:= oMdlHead:GetValue('DTENVINI')
Local cDtEnvFim	:= oMdlHead:GetValue('DTENVFIM')
Local cSerieDe	:= oMdlHead:GetValue('SERIEDE')
Local cSerieAte	:= oMdlHead:GetValue('SERIEATE')
Local cExprSer	:= ''

oMdlLin:SetNoInsertLine(.F.)
oMdlLin:SetNoUpdateLine(.F.)
oMdlLin:SetNoDeleteLine(.F.)
oMdlVia:SetNoInsertLine(.F.)
oMdlVia:SetNoUpdateLine(.F.) 
oMdlVia:SetNoDeleteLine(.F.)
oMdlCte:SetNoInsertLine(.F.)
oMdlCte:SetNoUpdateLine(.F.)
oMdlCte:SetNoDeleteLine(.F.)

If !(Empty(cSerieDe)) .And. !(Empty(cSerieAte))
	cExprSer := "% AND G99.G99_SERIE BETWEEN '" + cSerieDe + "' AND '" + cSerieAte + "'%"
Else
	cExprSer = '%%'
Endif

oMdlLin:ClearData()

BeginSql  Alias cAliasG99

	SELECT GI2.GI2_COD,
	       GI2.GI2_PREFIX,
	       GI2.GI2_NUMLIN,
	       GYN.GYN_CODIGO, 
	       GYN.GYN_DTINI, 
	       GYN.GYN_HRINI, 
	       GYN.GYN_DTFIM,
	       GYN.GYN_HRFIM,
	       GYN.GYN_CONF,
	       ST9.T9_CODBEM,
	       ST9.T9_NOME,
	       ST9.T9_PLACA,
	       DA3.DA3_TARA,
	       G99.G99_CODIGO,
	       G99.G99_DTEMIS,
	       G99.G99_HREMIS,
	       G99.G99_DTPREV,
	       G99.G99_HRPREV,
	       G99.G99_CODREC,
	       G99.G99_PESO,
	       G99.G99_PESCUB,
	       G99.G99_CODPRO,
	       G99.G99_QTDVO,
	       G99.G99_VALOR,
	       G99.G99_CHVCTE,
	       SB1.B1_DESC,
	       GI6.GI6_DESCRI,
           GIJ.GIJ_CNPJSE,
           GIJ.GIJ_NOMESE,
           GIJ.GIJ_NUMAPO,
           GIJ.GIJ_NUMAVB,
	       SA1REM.A1_NOME NOMEREM,
	       SA1REM.A1_PESSOA TPCLIREM,
	       SA1REM.A1_CGC DOCCLIREM,
	       SA1DES.A1_NOME NOMEDES
	FROM %Table:G99% G99
	INNER JOIN %Table:G9Q% G9Q ON G9Q.G9Q_FILIAL = G99.G99_FILIAL
	AND G9Q.G9Q_CODIGO = G99.G99_CODIGO
	AND G9Q.%NotDel%
	INNER JOIN %Table:GI2% GI2 ON GI2.GI2_FILIAL = %xFilial:GI2% 
	AND GI2.GI2_COD = G9Q.G9Q_CODLIN
	AND GI2.GI2_HIST = '2'
	AND GI2.%NotDel%
	INNER JOIN %Table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
	AND SB1.B1_COD = G99.G99_CODPRO
	AND SB1.%NotDel%
	INNER JOIN %Table:GI6% GI6 ON GI6.GI6_FILIAL = G99.G99_FILIAL
	AND GI6.GI6_CODIGO = G99.G99_CODREC
	AND GI6.%NotDel%
	INNER JOIN %Table:SA1% SA1REM ON SA1REM.A1_FILIAL = %xFilial:SA1%
	AND SA1REM.A1_COD = G99.G99_CLIREM 
	AND SA1REM.A1_LOJA = G99.G99_LOJREM
	AND SA1REM.%NotDel%
	INNER JOIN %Table:SA1% SA1DES ON SA1DES.A1_FILIAL = %xFilial:SA1%
	AND SA1DES.A1_COD = G99.G99_CLIDES 
	AND SA1DES.A1_LOJA = G99.G99_LOJDES
	AND SA1DES.%NotDel%
	INNER JOIN %Table:GIJ% GIJ ON GIJ.GIJ_FILIAL = %xFilial:GIJ%
	AND GIJ.GIJ_CODIGO = G99.G99_CODIGO 
	AND GIJ.GIJ_MSBLQL = '2'
	AND GIJ.%NotDel%
	LEFT JOIN %Table:GYN% GYN ON GYN.GYN_FILIAL = GI2.GI2_FILIAL
	AND GYN.GYN_LINCOD = GI2.GI2_COD
	AND GYN.GYN_DTINI BETWEEN %Exp:cDtEnvIni% AND %Exp:cDtEnvFim%
	AND GYN.%NotDel%	
	LEFT JOIN %Table:GQE% GQE ON GQE_FILIAL = GYN.GYN_FILIAL
	AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
	AND GQE.GQE_TRECUR = '2'
	AND GQE.%NotDel%
	LEFT JOIN %Table:ST9% ST9 ON ST9.T9_FILIAL = %xFilial:ST9%
	AND ST9.T9_CODBEM = GQE.GQE_RECURS 
	AND ST9.%NotDel%
	LEFT JOIN %Table:DA3% DA3 ON DA3.DA3_FILIAL = %xFilial:DA3%
	AND DA3.DA3_CODBEM = ST9.T9_CODBEM
	AND DA3.%NotDel%
	WHERE G99.G99_FILIAL = %xFilial:G99% 
	  %Exp:cExprSer%
	  AND G99.G99_CODEMI = %Exp:cAgencia%
	  AND G99.G99_DTEMIS BETWEEN %Exp:cDtCteIni% AND %Exp:cDtCteFim%
	  
//  AND G99.G99_SERIE BETWEEN %Exp:cSerieDe% AND %Exp:cSerieAte%
	  AND G99.G99_AVERBA = '2'
	  AND G99.G99_STATRA = '2'
	  AND G99.G99_STAENC = '1'
	  AND G99.%NotDel%
	  GROUP BY GI2.GI2_COD, 
				GI2.GI2_PREFIX, 
				GI2.GI2_NUMLIN, 
				GYN.GYN_CODIGO,
				GYN.GYN_DTINI, 
				GYN.GYN_HRINI, 
				GYN.GYN_DTFIM, 
				GYN.GYN_HRFIM,
				GYN.GYN_CONF,
				ST9.T9_CODBEM,
				ST9.T9_NOME,
				ST9.T9_PLACA,
				DA3.DA3_TARA,
		        G99.G99_CODIGO,
		        G99.G99_DTEMIS,
		        G99.G99_HREMIS,
		        G99.G99_DTPREV,
		        G99.G99_HRPREV,
		        G99.G99_CODREC,
		        G99.G99_PESO,
		        G99.G99_PESCUB,
		        G99.G99_CODPRO,
		        G99.G99_QTDVO,
		        G99.G99_VALOR,
		        G99.G99_CHVCTE,
		        SB1.B1_DESC,
		        GI6.GI6_DESCRI,
		        GIJ.GIJ_CNPJSE,
		        GIJ.GIJ_NOMESE,
		        GIJ.GIJ_NUMAPO,
		        GIJ.GIJ_NUMAVB,
		        SA1REM.A1_NOME,
		        SA1REM.A1_PESSOA,
		        SA1REM.A1_CGC,
		        SA1DES.A1_NOME
	ORDER BY GI2.GI2_COD, GYN.GYN_CODIGO, G99.G99_CODIGO

EndSql

While !(cAliasG99)->(Eof())

	If !(oMdlLin:SeekLine({{"GI2_COD",(cAliasG99)->GI2_COD}}))

		If !(oMdlLin:IsEmpty())
			oMdlLin:AddLine()
		Endif
		
		oMdlLin:SetValue('GI2_COD',(cAliasG99)->GI2_COD)
		oMdlLin:SetValue('GI2_PREFIX',(cAliasG99)->GI2_PREFIX)
		oMdlLin:SetValue('GI2_NUMLIN',(cAliasG99)->GI2_NUMLIN)
		
	Endif
	
	If !(oMdlVia:SeekLine({{"GYN_CODIGO",(cAliasG99)->GYN_CODIGO}}))
	
		If !(oMdlVia:IsEmpty())
			oMdlVia:AddLine()
		Endif
		
		oMdlVia:SetValue('GYN_CODIGO', (cAliasG99)->GYN_CODIGO)
		oMdlVia:SetValue('GYN_DTINI', StoD((cAliasG99)->GYN_DTINI))
		oMdlVia:SetValue('GYN_HRINI', (cAliasG99)->GYN_HRINI)
		oMdlVia:SetValue('GYN_DTFIM', StoD((cAliasG99)->GYN_DTFIM))
		oMdlVia:SetValue('GYN_HRFIM', (cAliasG99)->GYN_HRFIM)
		oMdlVia:SetValue('GYN_CONF', (cAliasG99)->GYN_CONF)
		oMdlVia:SetValue('T9_CODBEM', (cAliasG99)->T9_CODBEM)
		oMdlVia:SetValue('T9_NOME', (cAliasG99)->T9_NOME)
		oMdlVia:SetValue('T9_PLACA', (cAliasG99)->T9_PLACA)
		oMdlVia:SetValue('DA3_TARA', (cAliasG99)->DA3_TARA)
		
	Endif
	
	If !(oMdlCte:SeekLine({{"G99_CODIGO",(cAliasG99)->G99_CODIGO}}))
	
		If !(oMdlCte:IsEmpty())
			oMdlCte:AddLine()
		Endif

		oMdlCte:SetValue('G99_CODIGO', (cAliasG99)->G99_CODIGO)
		oMdlCte:SetValue('G99_DTEMIS', StoD((cAliasG99)->G99_DTEMIS))
		oMdlCte:SetValue('G99_HREMIS', (cAliasG99)->G99_HREMIS)
		oMdlCte:SetValue('G99_DTPREV', StoD((cAliasG99)->G99_DTPREV))
		oMdlCte:SetValue('G99_HRPREV', (cAliasG99)->G99_HRPREV)
		oMdlCte:SetValue('G99_CODPRO', (cAliasG99)->G99_CODPRO)
		oMdlCte:SetValue('B1_DESC', (cAliasG99)->B1_DESC)
		oMdlCte:SetValue('G99_PESO', (cAliasG99)->G99_PESO)
		oMdlCte:SetValue('G99_PESCUB', (cAliasG99)->G99_PESCUB)
		oMdlCte:SetValue('G99_QTDVO', (cAliasG99)->G99_QTDVO)
		oMdlCte:SetValue('G99_VALOR', (cAliasG99)->G99_VALOR)
		oMdlCte:SetValue('G99_CODREC', (cAliasG99)->G99_CODREC)
		oMdlCte:SetValue('G99_CHVCTE', (cAliasG99)->G99_CHVCTE)
		oMdlCte:SetValue('GI6_DESCRI', (cAliasG99)->GI6_DESCRI)
		oMdlCte:SetValue('GIJ_CNPJSE', (cAliasG99)->GIJ_CNPJSE)
		oMdlCte:SetValue('GIJ_NOMESE', (cAliasG99)->GIJ_NOMESE)
		oMdlCte:SetValue('GIJ_NUMAPO', (cAliasG99)->GIJ_NUMAPO)
		oMdlCte:SetValue('GIJ_NUMAVB', (cAliasG99)->GIJ_NUMAVB)
		oMdlCte:SetValue('NOMEREM', (cAliasG99)->NOMEREM)
		oMdlCte:SetValue('TPCLIREM', (cAliasG99)->TPCLIREM)
		oMdlCte:SetValue('DOCCLIREM', (cAliasG99)->DOCCLIREM)
		oMdlCte:SetValue('NOMEDES', (cAliasG99)->NOMEDES)
		
	Endif
	
	(cAliasG99)->(dbSkip())

End

oMdlLin:GoLine(1)

oMdlLin:SetNoInsertLine(.T.)
oMdlLin:SetNoDeleteLine(.T.)
oMdlVia:SetNoInsertLine(.T.)
oMdlVia:SetNoDeleteLine(.T.)
oMdlCte:SetNoInsertLine(.T.)
oMdlCte:SetNoDeleteLine(.T.)

(cAliasG99)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} G810ACommit
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function G810ACommit(oModel)
Local oView		:= FwViewActive()
Local lRet 		:= .T.
Local oMdlCab	:= oModel:GetModel("HEADER")
Local oMdlLin	:= oModel:GetModel("GRIDLIN")
Local oMdlCte	:= oModel:GetModel("GRIDCTE")
Local oMdlVia	:= oModel:GetModel("GRIDVIA")
Local oMdl810	:= FwLoadModel("GTPA810")
Local oMdlGI9	:= oMdl810:GetModel("MASTERGI9")
Local oMdlGIF1	:= oMdl810:GetModel("DETAILGIF1")
Local aAreaSM0	:= SM0->(GetArea())
Local cCodMun	:= ""
Local nX		:= 0
Local nPesoTot	:= 0
Local nValTot	:= 0


If oMdlLin:SeekLine({{"GI2_MARK",.T.}},.F.,.T.)

	If !(oMdlVia:SeekLine({{"GYN_MARK",.T.}},.F.,.T.))
	
		oMdl810:DeActivate()
		FwAlertWarning(STR0056,STR0057)//'Nenhuma viagem foi selecionada', 'Atenção!' 
		Return .F.
	
	Endif
	
	oMdl810:SetOperation(MODEL_OPERATION_INSERT)
	oMdl810:Activate()

	oMdlGI9:SetValue('GI9_CODEMI', oMdlCab:GetValue('CODAGE'))
	oMdlGI9:SetValue('GI9_VEICUL', oMdlVia:GetValue('T9_CODBEM'))
	oMdlGI9:SetValue('GI9_PLACA', Substr(oMdlVia:GetValue('T9_PLACA'),1,7))
	oMdlGI9:SetValue('GI9_TARAVE', oMdlVia:GetValue('DA3_TARA'))

	For nX := 1 To oMdlCte:Length()
	
		If oMdlCte:GetValue('G99_MARK',nX)
		
			If !(oMdlGIF1:IsEmpty())
				oMdlGIF1:AddLine()
			Endif
			
			dbSelectArea('GI6')
			GI6->(dbSetOrder(1))
			
			If dbSeek(xFilial('GI6')+oMdlCte:GetValue('G99_CODREC',nX))
				cCodMun := Posicione('SM0', 1, cEmpAnt+GI6->GI6_FILRES, 'M0_CODMUN')
			Endif
			
		    oMdlGIF1:SetValue('GIF_VALOR' , oMdlCte:GetValue('G99_VALOR',nX))
		    oMdlGIF1:SetValue('GIF_PESO'  , oMdlCte:GetValue('G99_PESO',nX))
		    oMdlGIF1:LoadValue('GIF_MARK'  , .T.)
			oMdlGIF1:SetValue('GIF_CODMUN', cCodMun)
			oMdlGIF1:SetValue('GIF_CODG99', oMdlCte:GetValue('G99_CODIGO',nX)) 
		    oMdlGIF1:SetValue('GIF_CHCTE' , oMdlCte:GetValue('G99_CHVCTE',nX)) 
		    oMdlGIF1:SetValue('GIF_CNPJ'  , oMdlCte:GetValue('GIJ_CNPJSE',nX)) 
		    oMdlGIF1:SetValue('GIF_NOMESE', oMdlCte:GetValue('GIJ_NOMESE',nX)) 
		    oMdlGIF1:SetValue('GIF_NAPOLI', oMdlCte:GetValue('GIJ_NUMAPO',nX)) 
		    oMdlGIF1:SetValue('GIF_NAVERB', oMdlCte:GetValue('GIJ_NUMAVB',nX))
		    oMdlGIF1:SetValue('GIF_TPCLIE', oMdlCte:GetValue('TPCLIREM',nX))
		    oMdlGIF1:SetValue('GIF_DOCCLI', oMdlCte:GetValue('DOCCLIREM',nX))

		//	nPesoTot += oMdlGIF1:GetValue('GIF_PESO', nX)
		//	nValTot  += oMdlGIF1:GetValue('GIF_VALOR', nX)

	    Endif
	
	Next

	oMdlGI9:SetValue('GI9_PCARGA', nPesoTot)
	oMdlGI9:SetValue('GI9_VCARGA', nValTot)

	oMdlGIF1:GoLine(1)

	AddCte(oMdl810)

	oMdlGI9:SetValue('GI9_VIAGEM', oMdlVia:GetValue('GYN_CODIGO'))
	
	oView:ButtonCancelAction()
	
	FwExecView( "Inclusão" , "VIEWDEF.GTPA810", 3, , {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , oMdl810)	

Else
	FwAlertWarning(STR0058,STR0057) //'Não há dados selecionados', 'Atenção!' 
	lRet := .F.
Endif

oMdl810:DeActivate()

RestArea(aAreaSM0)

Return lRet

/*/{Protheus.doc} AddCte
//TODO Descrição auto-gerada.
@author flavio.martins
@since 29/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function AddCte(oModel)
Local aSM0      := SM0->(GetArea())   
Local cAliasG99	:= GetNextAlias()
Local oMdlGIF1	:= oModel:GetModel("DETAILGIF1")
Local oMdlGIF2	:= oModel:GetModel("DETAILGIF2")
Local cAgencia	:= oModel:GetModel("MASTERGI9"):GetValue('GI9_CODEMI')
Local cCodCte	:= oMdlGIF1:GetValue('GIF_CODG99')
Local cCodMun	:= ""
Local cCodLin	:= ""
Local nX		:= 0

dbSelectArea('G99')
dbSelectArea('G9Q')
	
G99->(dbSetOrder(1))
G9Q->(dbSetOrder(1))
	
If G99->(dbSeek(xFilial('G99')+cCodCte)) .And. G9Q->(dbSeek(xFilial('G9Q')+G99->G99_CODIGO))
	cCodLin := G9Q->G9Q_CODLIN
Endif
	
BeginSql Alias cAliasG99
	
	SELECT G99.G99_CODIGO,
			G99.G99_CODREC,
	       G99.G99_CHVCTE,
	       G99.G99_VALOR,
	       G99.G99_PESO,
	       GIJ.GIJ_NUMAVB,
	       GIJ.GIJ_NUMAPO,
	       GIJ.GIJ_NOMESE,
	       GIJ.GIJ_CNPJSE,
	       SA1.A1_PESSOA,
	       SA1.A1_CGC
	FROM %Table:G99% G99
	INNER JOIN %Table:G9Q% G9Q ON G9Q.G9Q_FILIAL = G99.G99_FILIAL
	AND G9Q.G9Q_CODIGO = G99.G99_CODIGO
	AND G9Q.G9Q_CODLIN = %Exp:cCodLin%
	AND G9Q.%NotDel%
	INNER JOIN %Table:GIJ% GIJ ON GIJ.GIJ_FILIAL = %xFilial:GIJ%
	AND GIJ.GIJ_CODIGO = G99_CODIGO
	AND GIJ.GIJ_MSBLQL = '2'
	AND GIJ.%NotDel%
	INNER JOIN %Table:SA1% SA1 ON SA1.A1_FILIAL = %xFilial:SA1%
	AND SA1.A1_COD = G99.G99_CLIREM
	AND SA1.A1_LOJA = G99.G99_LOJREM
	AND SA1.%NotDel%
	WHERE G99.G99_FILIAL = %xFilial:G99%
	  AND G99.G99_CODEMI = %Exp:cAgencia%
	  AND G99.G99_AVERBA = '2'
	  AND G99.G99_STATRA = '2'
	  AND G99.G99_STATRA != '8'
	  AND G99.G99_STAENC = '1'
	  AND G99.%NotDel%
		  
EndSql
		
While !(cAliasG99)->(Eof())
	
	If !(oMdlGIF1:SeekLine({{"GIF_CODG99",(cAliasG99)->G99_CODIGO}}))
		
		dbSelectArea('GI6')
		GI6->(dbSetOrder(1))
					
		If dbSeek(xFilial('GI6')+(cAliasG99)->G99_CODREC)
			cCodMun := Posicione('SM0', 1, cEmpAnt+GI6->GI6_FILRES, 'M0_CODMUN')
		Endif
		
		If !(oMdlGIF2:IsEmpty())
			oMdlGIF2:AddLine()
		Endif
			
		oMdlGIF2:SetValue('GIF_MARK'  , .F.)
		oMdlGIF2:SetValue('GIF_CODMUN', cCodMun)
		oMdlGIF2:SetValue('GIF_FILIAL', xFilial('GIF'))
		oMdlGIF2:SetValue('GIF_CODG99', (cAliasG99)->G99_CODIGO) 
		oMdlGIF2:SetValue('GIF_CHCTE' , (cAliasG99)->G99_CHVCTE) 
		oMdlGIF2:SetValue('GIF_CNPJ'  , (cAliasG99)->GIJ_CNPJSE) 
		oMdlGIF2:SetValue('GIF_NOMESE', (cAliasG99)->GIJ_NOMESE) 
		oMdlGIF2:SetValue('GIF_NAPOLI', (cAliasG99)->GIJ_NUMAPO) 
		oMdlGIF2:SetValue('GIF_NAVERB', (cAliasG99)->GIJ_NUMAVB) 
		oMdlGIF2:SetValue('GIF_TPCLIE', (cAliasG99)->A1_PESSOA) 
		oMdlGIF2:SetValue('GIF_DOCCLI', (cAliasG99)->A1_CGC) 
		oMdlGIF2:SetValue('GIF_VALOR' , (cAliasG99)->G99_VALOR) 
		oMdlGIF2:SetValue('GIF_PESO'  , (cAliasG99)->G99_PESO) 
		
	Endif
		
	(cAliasG99)->(dbSkip())
		
End

oMdlGIF2:GoLine(1)
	
If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	
	For nX := 1 To oMdlGIF1:Length()
			
		oMdlGIF1:GoLine(nX)
		oMdlGIF1:LoadValue('GIF_MARK',.T.)
			
	Next
	
	oMdlGIF1:GoLine(1)
	
Endif
	
(cAliasG99)->(dbCloseArea())

RestArea(aSM0)

Return 
