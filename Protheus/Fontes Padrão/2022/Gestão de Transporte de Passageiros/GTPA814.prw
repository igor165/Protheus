#Include "GTPA814.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} GTPA814
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTPA814()

	FwExecView(STR0001,"VIEWDEF.GTPA814",MODEL_OPERATION_INSERT,,{|| .T.},/*bOk*/) //"Recebimento"
		
Return 

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCab	:= FwFormModelStruct():New() 
Local oStruLin	:= FwFormModelStruct():New()
Local oStruCte	:= FwFormModelStruct():New() 
Local oStruMdf	:= FwFormModelStruct():New() 

oModel := MPFormModel():New("GTPA814",,,)

SetMdlStru(oStruCab,oStruLin,oStruCte,oStruMdf)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,)
oModel:AddGrid( 'GRIDLIN', 'HEADER', oStruLin,,,,,)
oModel:AddGrid( 'GRIDMDFE', 'GRIDLIN', oStruMdf,,,,,)
oModel:AddGrid( 'GRIDCTE', 'GRIDMDFE', oStruCte,,,,,)

oModel:SetDescription(STR0002) //"CT-e X Manifesto"
oModel:GetModel("HEADER"):SetDescription(STR0003)  //"Filtro"
oModel:GetModel("GRIDLIN"):SetDescription(STR0004)  //"Linhas"
oModel:GetModel("GRIDMDFE"):SetDescription("MDF-E") 
oModel:GetModel("GRIDCTE"):SetDescription("CT-E") 

oModel:GetModel("GRIDLIN"):SetOptional(.T.)
oModel:GetModel("GRIDMDFE"):SetOptional(.T.)
oModel:GetModel("GRIDCTE"):SetOptional(.T.)

oModel:GetModel("GRIDLIN"):SetNoInsertLine(.T.)
oModel:GetModel("GRIDMDFE"):SetNoInsertLine(.T.)
oModel:GetModel("GRIDCTE"):SetNoInsertLine(.T.)
oModel:GetModel("GRIDLIN"):SetNoUpdateLine(.T.)
oModel:GetModel("GRIDMDFE"):SetNoUpdateLine(.T.)
oModel:GetModel("GRIDCTE"):SetNoUpdateLine(.T.)
oModel:GetModel("GRIDLIN"):SetNoDeleteLine(.T.)
oModel:GetModel("GRIDMDFE"):SetNoDeleteLine(.T.)
oModel:GetModel("GRIDCTE"):SetNoDeleteLine(.T.)

oModel:SetPrimaryKey({})

oModel:SetCommit({|oModel| G814Commit(oModel)})

Return(oModel)

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA814")
Local oStruCab	:= FwFormViewStruct():New()
Local oStruLin	:= FwFormViewStruct():New()
Local oStruCte	:= FwFormViewStruct():New()
Local oStruMdf	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruCab,oStruLin,oStruCte,oStruMdf)

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:SetDescription(STR0005) //"Seleção de CT-e"

oView:AddField('VIEW_HEADER', oStruCab, 'HEADER'  )
oView:AddGrid( "VIEW_LIN"   , oStruLin, "GRIDLIN" )
oView:AddGrid( "VIEW_MDFE"  , oStruMdf, "GRIDMDFE")
oView:AddGrid( "VIEW_CTE"   , oStruCte, "GRIDCTE" )

oView:CreateHorizontalBox('FILTRO', 15)
oView:CreateHorizontalBox('GRID1', 40)
oView:CreateHorizontalBox('GRID2', 45)

oView:CreateVerticalBox('BOX_LIN',31,'GRID1')
oView:CreateVerticalBox('BOX_SEP',01,'GRID1')
oView:CreateVerticalBox('BOX_CTE',68,'GRID1')

oView:SetOwnerView('VIEW_HEADER','FILTRO')
oView:SetOwnerView('VIEW_LIN','BOX_LIN')
oView:SetOwnerView('VIEW_MDFE','BOX_CTE')
oView:SetOwnerView('VIEW_CTE','GRID2')

oView:EnableTitleView("VIEW_HEADER",STR0003) //"Filtro"
oView:EnableTitleView("VIEW_LIN",STR0004)    //"Linhas"
oView:EnableTitleView("VIEW_MDFE","MDF-e")
oView:EnableTitleView("VIEW_CTE","CT-e")

oView:AddUserButton( STR0006, "", {|| GA814Pesq(oModel)},,VK_F5)  //"Pesquisar"

oView:ShowInsertMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStru
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oStruCab, object, descricao
@param oStruLin, object, descricao
@param oStruCte, object, descricao
@param oStruMdf, object, descricao
@type function
/*/
Static Function SetMdlStru(oStruCab,oStruLin,oStruCte,oStruMdf)
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

	oStruCab:AddField(STR0007, STR0008,"AGENCIA" ,"C",TamSx3('GI6_CODIGO')[1],0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.T.,.T.) //"Agencia" //"Cód.Agencia"
	oStruCab:AddField(STR0009, STR0009,"DAGENCI" ,"C",TamSx3('GI6_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0009 //"Descrição"
	oStruCab:AddField(STR0010, STR0010,"DTCTEINI","D",8                      ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0010 //"Data De"
	oStruCab:AddField(STR0011, STR0011,"DTCTEFIM","D",8                      ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0011 //"Data Ate"

	oStruLin:AddField(""     , ""     , "GI2_MARK"  ,"L",1                      ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)
	oStruLin:AddField(STR0013, STR0012, "GI2_COD"   ,"C",TamSx3('GI2_COD'   )[1],0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.F.,.T.) //"Cód.Linha" //"Cod.Linha"
	oStruLin:AddField(STR0014, STR0014, "GI2_PREFIX","C",TamSx3('GI2_PREFIX')[1],0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.T.,.F.) //STR0014 //"Prefixo"
	oStruLin:AddField(STR0015, STR0015, "GI2_NUMLIN","C",TamSx3('GI2_NUMLIN')[1],0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.T.,.T.) //STR0015 //"Num.Linha"

	oStruCte:AddField(""     , ""     , "G99_MARK"  ,"L",1                      ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)
	oStruCte:AddField(STR0016, STR0017, "G99_CODIGO","C",TamSx3('G99_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Cod.CTe" //"Cód.CTe"
	oStruCte:AddField(STR0018, STR0018, "G99_DTEMIS","D",TamSx3('G99_DTEMIS')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0018 //"Data Emissão"
	oStruCte:AddField(STR0019, STR0019, "G99_HREMIS","C",TamSx3('G99_HREMIS')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0019 //"Hora Emissão"
	oStruCte:AddField(STR0020, STR0020, "G99_DTPREV","D",TamSx3('G99_DTPREV')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0020 //"Prev.Entrega"
	oStruCte:AddField(STR0021, STR0021, "G99_HRPREV","C",TamSx3('G99_HRPREV')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0021 //"Hora Prev."
	oStruCte:AddField(STR0022, STR0022, "NOMEREM"   ,"C",TamSx3('A1_NOME'   )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0022 //"Remetente"
	oStruCte:AddField(STR0054 ,STR0054 ,"TPCLIREM"  ,"C",TamSx3('A1_PESSOA' )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)
	oStruCte:AddField(STR0023, STR0023, "DOCCLIREM" ,"C",TamSx3('A1_CGC'    )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0023 //"Doc. Cliente"
	oStruCte:AddField(STR0024, STR0024, "NOMEDES"   ,"C",TamSx3('A1_NOME'   )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0024 //"Destinatário"
	oStruCte:AddField(STR0025, STR0025, "G99_CODREC","C",TamSx3('G99_CODREC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0025 //"Cód.Receb."
	oStruCte:AddField(STR0026, STR0026, "GI6_DESCRI","C",TamSx3('GI6_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0026 //"Descr.Receb."
	oStruCte:AddField(STR0027, STR0027, "G99_CODPRO","C",TamSx3('G99_CODPRO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0027 //"Cód.Prod."
	oStruCte:AddField(STR0028, STR0028, "B1_DESC"   ,"C",TamSx3('B1_DESC'   )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0028 //"Descr.Prod."
	oStruCte:AddField(STR0029, STR0029, "G99_PESO"  ,"N",TamSx3('G99_PESO'  )[1],4,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0029 //"Peso"
	oStruCte:AddField(STR0030, STR0030, "G99_PESCUB","N",TamSx3('G99_PESCUB')[1],4,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0030 //"Peso Cub."
	oStruCte:AddField(STR0031, STR0031, "G99_QTDVO" ,"N",TamSx3('G99_QTDVO' )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0031 //"Qtd. Vol."
	oStruCte:AddField(STR0032, STR0032, "G99_VALOR" ,"N",TamSx3('G99_VALOR' )[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0032 //"Valor Serv."
	oStruCte:AddField(STR0033, STR0034, "G99_CHVCTE","C",TamSx3('G99_CHVCTE')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Chave CTE." //"Chave CTE"
	oStruCte:AddField(STR0035, STR0035, "GIJ_CNPJSE","C",TamSx3('GIJ_CNPJSE')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0035 //"Cnpj Seg."
	oStruCte:AddField(STR0036, STR0036, "GIJ_NOMESE","C",TamSx3('GIJ_NOMESE')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0036 //"Nome Seg."
	oStruCte:AddField(STR0037, STR0037, "GIJ_NUMAPO","C",TamSx3('GIJ_NUMAPO')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0037 //"Núm.Apólice"
	oStruCte:AddField(STR0038, STR0038, "GIJ_NUMAVB","C",TamSx3('GIJ_NUMAVB')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0038 //"Núm.Averb."

	oStruMdf:AddField(""     , ""     , "GI9_MARK"  ,"L",1                      ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)
	oStruMdf:AddField(STR0039, STR0039, "GI9_CODIGO","C",TamSx3('GI9_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0039 //"Cod. MDF-e"
	oStruMdf:AddField(STR0040, STR0040, "GI9_NUMERO","C",TamSx3('GI9_NUMERO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0040 //"Número"
	oStruMdf:AddField(STR0041, STR0041, "GI9_DTCRIA","D",TamSx3('GI9_DTCRIA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0041 //"Data Criação"
	oStruMdf:AddField(STR0018, STR0018, "GI9_EMISSA","D",TamSx3('GI9_EMISSA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0018 //"Data Emissão"
	oStruMdf:AddField(STR0019, STR0019, "GI9_HORAEM","C",TamSx3('GI9_HORAEM')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0019 //"Hora Emissão"
	oStruMdf:AddField(STR0042, STR0042, "GI9_CODEMI","C",TamSx3('GI9_CODEMI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0042 //"Emissor"
	oStruMdf:AddField(STR0009, STR0009, "GI9_DESEMI","C",TamSx3('GI9_DESEMI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0009 //"Descrição"
	oStruMdf:AddField(STR0043, STR0043, "GI9_CODREC","C",TamSx3('GI9_CODREC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0043 //"Recebedor"
	oStruMdf:AddField(STR0009, STR0009, "GI9_DESREC","C",TamSx3('GI9_DESREC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0009 //"Descrição"
	oStruMdf:AddField(STR0044, STR0044, "GI9_UFINI" ,"C",TamSx3('GI9_UFINI' )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0044 //"UF Carreg."
	oStruMdf:AddField(STR0046, STR0045, "GI9_VIAGEM","C",TamSx3('GI9_VIAGEM')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Cód.Viagem" //"Cod.Viagem"
	oStruMdf:AddField(STR0047, STR0047, "GI9_VEICUL","C",TamSx3('GI9_VEICUL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0047 //"Cód.Veic."
	oStruMdf:AddField(STR0048, STR0048, "GI9_PLACA" ,"C",TamSx3('GI9_PLACA' )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0048 //"Placa"
	oStruMdf:AddField(STR0049, STR0049, "GI9_TARAVE","N",TamSx3('GI9_TARAVE')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //STR0049 //"Tara"


    oStruCab:SetProperty('AGENCIA' , MODEL_FIELD_VALID, bFldVld )
    oStruCab:SetProperty('DTCTEINI', MODEL_FIELD_VALID, bFldVld )
    oStruCab:SetProperty('DTCTEFIM', MODEL_FIELD_VALID, bFldVld )

	oStruLin:AddTrigger("GI2_MARK","GI2_MARK",{ || .T. },bTrig)
	oStruMdf:AddTrigger("GI9_MARK","GI9_MARK",{ || .T. },bTrig)
	oStruCab:AddTrigger("AGENCIA" ,"AGENCIA" ,{ || .T. },bTrig)

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Função responsavel pela validação dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet      := .T.
Local oModel    := oMdl:GetModel()
Local cMdlId    := oMdl:GetId()
Local cMsgErro  := ""
Local cMsgSol   := ""

Do Case
    Case cField == "AGENCIA"
        lRet := ValidUserAg(oMdl,cField,uNewValue,uOldValue)
        
    Case cField == "DTCTEINI" .OR. cField == "DTCTEFIM"
        lRet := GxVldData(oMdl:GetValue("DTCTEINI"),oMdl:GetValue("DTCTEFIM"),@cMsgErro)
    
EndCase


If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif


Return lRet

/*/{Protheus.doc} SetViewStru
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oStruCab, object, descricao
@param oStruLin, object, descricao
@param oStruCte, object, descricao
@param oStruMdf, object, descricao
@type function
/*/
Static Function SetViewStru(oStruCab,oStruLin,oStruCte,oStruMdf)

	If ValType(oStruCab) == "O"
	
		oStruCab:AddField("AGENCIA" ,"01",STR0008,STR0008,{""},"GET","@!",NIL,"GI6ENC",.T.,NIL,NIL,{},NIL,NIL,.F.) //STR0008 //"Cód.Agencia"
		oStruCab:AddField("DAGENCI" ,"02",STR0009  ,STR0009  ,{""},"GET","@!",NIL,""      ,.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0009 //"Descrição"
		oStruCab:AddField("DTCTEINI","03",STR0010    ,STR0010    ,{""},"GET",""  ,NIL,""      ,.T.,NIL,NIL,{},NIL,NIL,.F.) //STR0010 //"Data De"
		oStruCab:AddField("DTCTEFIM","04",STR0011   ,STR0011   ,{""},"GET",""  ,NIL,""      ,.T.,NIL,NIL,{},NIL,NIL,.F.) //STR0011 //"Data Ate"

	Endif
	
	If ValType(oStruLin) == "O"
	
		oStruLin:AddField("GI2_MARK"  ,"01",""          ,""          ,{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)
		oStruLin:AddField("GI2_COD"   ,"02",STR0012 ,STR0012 ,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0012 //"Cód.Linha"
		oStruLin:AddField("GI2_PREFIX","03",STR0014   ,STR0014   ,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0014 //"Prefixo"
		oStruLin:AddField("GI2_NUMLIN","04",STR0050,STR0050,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0050 //"Num. Linha"

	Endif

	If ValType(oStruCte) == "O"
	
		oStruCte:AddField("G99_MARK"  ,"01",""     ,""     ,{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)
		oStruCte:AddField("G99_CODIGO","02",STR0051,STR0051,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0051 //"Cód.CTE"
		oStruCte:AddField("G99_DTEMIS","03",STR0018,STR0018,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0018 //"Data Emissão"
		oStruCte:AddField("G99_HREMIS","04",STR0019,STR0019,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0019 //"Hora Emissão"
		oStruCte:AddField("G99_DTPREV","05",STR0052,STR0052,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0052 //"Prev.Entr."
		oStruCte:AddField("G99_HRPREV","06",STR0053,STR0053,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0053 //"Hora Entr."
		oStruCte:AddField("NOMEREM"   ,"07",STR0022,STR0022,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0022 //"Remetente"
		oStruCte:AddField("TPCLIREM"  ,"08",STR0054,STR0054,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0054 //"Tp. Cliente"
		oStruCte:AddField("DOCCLIREM" ,"09",STR0023,STR0023,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0023 //"Doc. Cliente"
		oStruCte:AddField("NOMEDES"   ,"10",STR0024,STR0024,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0024 //"Destinatário"
		oStruCte:AddField("G99_CODREC","11",STR0025,STR0025,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0025 //"Cód.Receb."
		oStruCte:AddField("GI6_DESCRI","12",STR0026,STR0026,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0026 //"Descr.Receb."
		oStruCte:AddField("G99_CODPRO","13",STR0027,STR0027,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0027 //"Cód.Prod."
		oStruCte:AddField("B1_DESC"   ,"14",STR0028,STR0028,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0028 //"Descr.Prod."
		oStruCte:AddField("G99_PESO"  ,"15",STR0029,STR0029,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0029 //"Peso"
		oStruCte:AddField("G99_PESCUB","16",STR0030,STR0030,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0030 //"Peso Cub."
		oStruCte:AddField("G99_QTDVO" ,"17",STR0031,STR0031,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0031 //"Qtd. Vol."
		oStruCte:AddField("G99_VALOR" ,"18",STR0032,STR0032,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0032 //"Valor Serv."
		oStruCte:AddField("G99_CHVCTE","19",STR0034,STR0033,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Chave CTE." //"Chave CTE"
		oStruCte:AddField("GIJ_CNPJSE","20",STR0035,STR0035,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0035 //"Cnpj Seg."
		oStruCte:AddField("GIJ_NOMESE","21",STR0036,STR0036,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0036 //"Nome Seg."
		oStruCte:AddField("GIJ_NUMAPO","22",STR0037,STR0037,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0037 //"Núm.Apólice"
		oStruCte:AddField("GIJ_NUMAVB","23",STR0038,STR0038,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0038 //"Núm.Averb."
		
	Endif
	
	If ValType(oStruMdf) == "O"
	
		oStruMdf:AddField("GI9_MARK"  ,"01",""     ,""     ,{""},"GET","@!"   ,NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)	
		oStruMdf:AddField("GI9_CODIGO","02",STR0039,STR0039,{""},"GET","@!"   ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0039 //"Cod. MDF-e"
		oStruMdf:AddField("GI9_NUMERO","03",STR0040,STR0040,{""},"GET","@!"   ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0040 //"Número"
		oStruMdf:AddField("GI9_VIAGEM","04",STR0046,STR0046,{""},"GET","@!"   ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0046 //"Cod.Viagem"
		oStruMdf:AddField("GI9_VEICUL","05",STR0047,STR0047,{""},"GET","@!"   ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0047 //"Cód.Veic."
		oStruMdf:AddField("GI9_PLACA" ,"06",STR0048,STR0048,{""},"GET","@!"   ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0048 //"Placa"
		oStruMdf:AddField("GI9_EMISSA","07",STR0018,STR0018,{""},"GET",""     ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0018 //"Data Emissão"
		oStruMdf:AddField("GI9_HORAEM","08",STR0019,STR0019,{""},"GET","99:99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0019 //"Hora Emissão"
		oStruMdf:AddField("GI9_CODEMI","09",STR0042,STR0042,{""},"GET","@!"   ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0042 //"Emissor"
		oStruMdf:AddField("GI9_DESEMI","10",STR0009,STR0009,{""},"GET","@!"   ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0009 //"Descrição"
		oStruMdf:AddField("GI9_CODREC","09",STR0043,STR0043,{""},"GET","@!"   ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0043 //"Recebedor"
		oStruMdf:AddField("GI9_DESREC","10",STR0009,STR0009,{""},"GET","@!"   ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0009 //"Descrição"
		oStruMdf:AddField("GI9_UFINI" ,"11",STR0044,STR0044,{""},"GET","@!"   ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0044 //"UF Carreg."
		oStruMdf:AddField("GI9_TARAVE","12",STR0049,STR0049,{""},"GET",""     ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0049 //"Tara"
		oStruMdf:AddField("GI9_DTCRIA","13",STR0041,STR0041,{""},"GET",""     ,NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //STR0041 //"Data Criação"
		
	Endif

Return

/*/{Protheus.doc} GA810ATrig
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param uVal, characters, descricao
@param cOldValue, characters, descricao
@type function
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
Local lRet 		 := .T.
Local oView		 := FwViewActive()
Local nLnPos	 := IIF(cField != 'AGENCIA',oMdl:GetLine(),0)
Local nX		 := 0

Do case
    
case  cField == 'AGENCIA'
	oMdl:SetValue("DAGENCI",Posicione('GI6', 1, xFilial('GI6')+uVal, 'GI6_DESCRI'))

case cField == 'GI9_MARK'

	nLnPos := oMdl:GetLine()
	
	If uVal
		
		For nX := 1 To oMdl:Length()
		
			oMdl:GoLine(nX)
		
			If ((oMdl:GetLine() <> nLnPos) .And. oMdl:GetValue(cField))
				G814SetMark(oMdl, nX, .F.)
				oMdl:LoadValue(cField,.F.)
			Endif
	
		Next
		
		oMdl:GoLine(nLnPos)
		G814SetMark(oMdl, nLnPos, .T.)

	Else
		G814SetMark(oMdl, nLnPos, .F.)
		oMdl:SetValue(cField,.F.)
	Endif
CASE cField == 'G99_MARK' 

	nLnPos := oMdl:GetLine()

	If uVal

		For nX := 1 To oMdl:Length()
		
			oMdl:GoLine(nX)
			
			If ((oMdl:GetLine() <> nLnPos) .And. oMdl:GetValue(cField))
				oMdl:LoadValue(cField,.F.)
			Endif
		
		Next

	Endif 

	oMdl:GoLine(nLnPos)
EndCase

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
Static Function G814SetMark(oMdl, nLnPos, lMark)
Local oModel	:= oMdl:GetModel()
Local nX		:= 0

	For nX := 1 To oModel:GetModel("GRIDCTE"):Length() 
			
		oModel:GetModel("GRIDCTE"):GoLine(nX)
		oModel:GetModel("GRIDCTE"):LoadValue('G99_MARK',.F.)

	Next
	oModel:GetModel("GRIDMDFE"):GoLine(nLnPos)
	
	If !(lMark)
		For nX := 1 To oModel:GetModel("GRIDMDFE"):Length() 
		
			oModel:GetModel("GRIDMDFE"):GoLine(nX)
			oModel:GetModel("GRIDMDFE"):LoadValue('GI9_MARK',lMark)
	
		Next
	Endif
	For nX := 1 To oModel:GetModel("GRIDCTE"):Length() 
		
		oModel:GetModel("GRIDCTE"):GoLine(nX)
		oModel:GetModel("GRIDCTE"):LoadValue('G99_MARK',lMark)

	Next
	oModel:GetModel("GRIDMDFE"):GoLine(nLnPos)
	oModel:GetModel("GRIDCTE"):GoLine(1)

Return

/*/{Protheus.doc} GA814Pesq
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function GA814Pesq(oModel)
Local lRet := .T.
Local cAliasG99	:= GetNextAlias()
Local oMdlHead	:= oModel:GetModel('HEADER')
Local oMdlLin	:= oModel:GetModel('GRIDLIN')
Local oMdlCte	:= oModel:GetModel('GRIDCTE')
Local oMdlMDFE	:= oModel:GetModel('GRIDMDFE')
Local cAgencia	:= oMdlHead:GetValue('AGENCIA')
Local dDtCteIni	:= oMdlHead:GetValue('DTCTEINI')
Local dDtCteFim	:= oMdlHead:GetValue('DTCTEFIM')
Local cWhere    := ""

oMdlLin:SetNoInsertLine(.F.)
oMdlLin:SetNoUpdateLine(.F.)
oMdlLin:SetNoDeleteLine(.F.)
oMdlMDFE:SetNoInsertLine(.F.)
oMdlMDFE:SetNoUpdateLine(.F.)
oMdlMDFE:SetNoDeleteLine(.F.)
oMdlCte:SetNoInsertLine(.F.)
oMdlCte:SetNoUpdateLine(.F.)
oMdlCte:SetNoDeleteLine(.F.)

oMdlLin:ClearData()


If !(EMPTY(dDtCteIni))
	cWhere := " AND G99.G99_DTEMIS >= '"+DtoS(dDtCteIni)+"'"
EndIf

If !(EMPTY(dDtCteFim))
	cWhere := " AND G99.G99_DTEMIS <= '"+DtoS(dDtCteFim)+"'"
EndIf

cWhere := "%" + cWhere + "%"

BeginSql  Alias cAliasG99

    SELECT DISTINCT
        GI2.GI2_COD
        , GI2.GI2_PREFIX
        , GI2.GI2_NUMLIN
        , GYN.GYN_CODIGO
        , GYN.GYN_DTINI
        , GYN.GYN_HRINI
        , GYN.GYN_DTFIM
        , GYN.GYN_HRFIM
        , GYN.GYN_CONF 
        , GI9.GI9_CODIGO
        , GI9.GI9_NUMERO
        , GI9.GI9_DTCRIA
        , GI9.GI9_EMISSA
        , GI9.GI9_HORAEM
        , GI9.GI9_CODEMI
        , GI9.GI9_CODREC
        , GI9.GI9_UFINI 
        , GI9.GI9_VIAGEM
        , GI9.GI9_VEICUL
        , GI9.GI9_PLACA 
        , GI9.GI9_TARAVE
        , G99.G99_CODIGO
        , G99.G99_DTEMIS
        , G99.G99_HREMIS
        , G99.G99_DTPREV
        , G99.G99_HRPREV
        , G99.G99_CODREC
        , G99.G99_PESO
        , G99.G99_PESCUB
        , G99.G99_CODPRO
        , G99.G99_QTDVO
        , G99.G99_VALOR
        , G99.G99_CHVCTE
        , SB1.B1_DESC
        , GI6.GI6_DESCRI
        , GIJ.GIJ_CNPJSE
        , GIJ.GIJ_NOMESE
        , GIJ.GIJ_NUMAPO
        , GIJ.GIJ_NUMAVB
        , SA1REM.A1_NOME   NOMEREM
        , SA1REM.A1_PESSOA TPCLIREM
        , SA1REM.A1_CGC    DOCCLIREM
        , SA1DES.A1_NOME   NOMEDES
	FROM %Table:G99% G99
        INNER JOIN %Table:G9Q% G9Q ON 
            G9Q.G9Q_FILIAL = G99.G99_FILIAL
            AND G9Q.G9Q_CODIGO = G99.G99_CODIGO
            AND G9Q.G9Q_AGEDES = %Exp:cAgencia%
            AND G9Q.%NotDel%
        INNER JOIN %Table:GI2% GI2 ON 
            GI2.GI2_FILIAL = %xFilial:GI2% 
            AND GI2.GI2_COD = G9Q.G9Q_CODLIN
            AND GI2.GI2_HIST = '2'
            AND GI2.%NotDel%
        INNER JOIN %Table:SB1% SB1 ON 
            SB1.B1_FILIAL =  %xFilial:SB1% 
            AND SB1.B1_COD = G99.G99_CODPRO
            AND SB1.%NotDel%
        INNER JOIN %Table:GI6% GI6 ON 
            GI6.GI6_FILIAL = G99.G99_FILIAL
            AND GI6.GI6_CODIGO = G99.G99_CODREC
            AND GI6.%NotDel%
        INNER JOIN %Table:SA1% SA1REM ON 
            SA1REM.A1_FILIAL = %xFilial:SA1%
            AND SA1REM.A1_COD = G99.G99_CLIREM 
            AND SA1REM.A1_LOJA = G99.G99_LOJREM
            AND SA1REM.%NotDel%
        INNER JOIN %Table:SA1% SA1DES ON 
            SA1DES.A1_FILIAL = %xFilial:SA1%
            AND SA1DES.A1_COD = G99.G99_CLIDES 
            AND SA1DES.A1_LOJA = G99.G99_LOJDES
            AND SA1DES.%NotDel%
        INNER JOIN %Table:GIJ% GIJ ON 
            GIJ.GIJ_FILIAL = G99_FILIAL
            AND GIJ.GIJ_CODIGO = G99.G99_CODIGO 
            AND GIJ.GIJ_MSBLQL = '2'
            AND GIJ.%NotDel%
        LEFT JOIN %Table:GYN% GYN ON 
            GYN.GYN_FILIAL = GI2.GI2_FILIAL
            AND GYN.GYN_LINCOD = GI2.GI2_COD
            AND GYN.%NotDel%	
        LEFT JOIN %Table:GQE% GQE ON 
            GQE_FILIAL = GYN.GYN_FILIAL
            AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
            AND GQE.GQE_TRECUR = '2'
            AND GQE.%NotDel%
        INNER JOIN %Table:GIF% GIF ON 
            GIF.GIF_FILIAL = G99.G99_FILIAL
            AND GIF.GIF_CODG99 = G99.G99_CODIGO
            AND GIF.%NotDel%
        INNER JOIN %Table:GI9% GI9 ON
            GI9.GI9_FILIAL = G99.G99_FILIAL
            AND GI9.GI9_VIAGEM = GYN.GYN_CODIGO
            AND GI9.GI9_CODIGO = GIF.GIF_CODIGO
            AND GI9.GI9_STATUS = '1'
            AND GI9.%NotDel%
        
    WHERE 
        G99.G99_FILIAL = %xFilial:G99% 
	  	AND G99.G99_AVERBA = '2'
	  	AND G99.G99_STATRA in ('2','4') //Autorizado ou contigencia
		AND G99.G99_STAENC = '2'
		AND G99.G99_CHVCTE = GIF.GIF_CHCTE
		AND G99.G99_CODIGO = GIF.GIF_CODG99
		AND G99.%NotDel%
		%Exp:cWhere%
	
	ORDER BY GI2.GI2_COD, GYN.GYN_CODIGO, G99.G99_CODIGO

EndSql

If (cAliasG99)->(EOF())
    FwAlertHelp(STR0065,STR0065,STR0056)//"Não foram encontrados nenhum dados com os parametros informados"#"Altere os dados para filtro ou verifique se o registro de fato exista"#"Atenção!!"
Endif

While !(cAliasG99)->(Eof())

	If !(oMdlLin:SeekLine({{"GI2_COD",(cAliasG99)->GI2_COD}}))

		If !(oMdlLin:IsEmpty())
			oMdlLin:AddLine()
		Endif
		
		oMdlLin:SetValue('GI2_COD'   ,(cAliasG99)->GI2_COD   )
		oMdlLin:SetValue('GI2_PREFIX',(cAliasG99)->GI2_PREFIX)
		oMdlLin:SetValue('GI2_NUMLIN',(cAliasG99)->GI2_NUMLIN)
		
	Endif
	
	If !(oMdlMDFE:SeekLine({{"GI9_CODIGO",(cAliasG99)->GI9_CODIGO}}))
	
		If !(oMdlMDFE:IsEmpty())
			oMdlMDFE:AddLine()
		Endif
		
		oMdlMDFE:SetValue('GI9_CODIGO' , (cAliasG99)->GI9_CODIGO                                                  )
		oMdlMDFE:SetValue('GI9_NUMERO' , (cAliasG99)->GI9_NUMERO                                                  )
		oMdlMDFE:SetValue('GI9_DTCRIA' , STOD((cAliasG99)->GI9_DTCRIA)                                            )
		oMdlMDFE:SetValue('GI9_EMISSA' , STOD((cAliasG99)->GI9_EMISSA)                                            )
		oMdlMDFE:SetValue('GI9_HORAEM' , (cAliasG99)->GI9_HORAEM                                                  )
		oMdlMDFE:SetValue('GI9_CODEMI' , (cAliasG99)->GI9_CODEMI                                                  ) 
		oMdlMDFE:SetValue('GI9_DESEMI' , Posicione('GI6', 1, xFilial('GI6')+(cAliasG99)->GI9_CODEMI, 'GI6_DESCRI'))
		oMdlMDFE:SetValue('GI9_CODREC' , (cAliasG99)->GI9_CODREC                                                  ) 
		oMdlMDFE:SetValue('GI9_DESREC' , Posicione('GI6', 1, xFilial('GI6')+(cAliasG99)->GI9_CODREC, 'GI6_DESCRI'))
		oMdlMDFE:SetValue('GI9_UFINI ' , (cAliasG99)->GI9_UFINI                                                   )
		oMdlMDFE:SetValue('GI9_VIAGEM' , (cAliasG99)->GI9_VIAGEM                                                  )
		oMdlMDFE:SetValue('GI9_VEICUL' , (cAliasG99)->GI9_VEICUL                                                  )
		oMdlMDFE:SetValue('GI9_PLACA ' , (cAliasG99)->GI9_PLACA                                                   )
		oMdlMDFE:SetValue('GI9_TARAVE' , (cAliasG99)->GI9_TARAVE                                                  )
		
	Endif

	If !(oMdlCte:SeekLine({{"G99_CODIGO",(cAliasG99)->G99_CODIGO}}))
	
		If !(oMdlCte:IsEmpty())
			oMdlCte:AddLine()
		Endif

		oMdlCte:SetValue('G99_CODIGO', (cAliasG99)->G99_CODIGO      )
		oMdlCte:SetValue('G99_DTEMIS', StoD((cAliasG99)->G99_DTEMIS))
		oMdlCte:SetValue('G99_HREMIS', (cAliasG99)->G99_HREMIS      )
		oMdlCte:SetValue('G99_DTPREV', StoD((cAliasG99)->G99_DTPREV))
		oMdlCte:SetValue('G99_HRPREV', (cAliasG99)->G99_HRPREV      )
		oMdlCte:SetValue('G99_CODPRO', (cAliasG99)->G99_CODPRO      )
		oMdlCte:SetValue('B1_DESC'   , (cAliasG99)->B1_DESC         )
		oMdlCte:SetValue('G99_PESO'  , (cAliasG99)->G99_PESO        )
		oMdlCte:SetValue('G99_PESCUB', (cAliasG99)->G99_PESCUB      )
		oMdlCte:SetValue('G99_QTDVO' , (cAliasG99)->G99_QTDVO       )
		oMdlCte:SetValue('G99_VALOR' , (cAliasG99)->G99_VALOR       )
		oMdlCte:SetValue('G99_CODREC', (cAliasG99)->G99_CODREC      )
		oMdlCte:SetValue('G99_CHVCTE', (cAliasG99)->G99_CHVCTE      )
		oMdlCte:SetValue('GI6_DESCRI', (cAliasG99)->GI6_DESCRI      )
		oMdlCte:SetValue('GIJ_CNPJSE', (cAliasG99)->GIJ_CNPJSE      )
		oMdlCte:SetValue('GIJ_NOMESE', (cAliasG99)->GIJ_NOMESE      )
		oMdlCte:SetValue('GIJ_NUMAPO', (cAliasG99)->GIJ_NUMAPO      )
		oMdlCte:SetValue('GIJ_NUMAVB', (cAliasG99)->GIJ_NUMAVB      )
		oMdlCte:SetValue('NOMEREM'   , (cAliasG99)->NOMEREM         )
		oMdlCte:SetValue('TPCLIREM'  , (cAliasG99)->TPCLIREM        )
		oMdlCte:SetValue('DOCCLIREM' , (cAliasG99)->DOCCLIREM       )
		oMdlCte:SetValue('NOMEDES'   , (cAliasG99)->NOMEDES         )
		
	Endif
	
	(cAliasG99)->(dbSkip())

End

oMdlLin:GoLine(1)
oMdlMDFE:GoLine(1)
oMdlCte:GoLine(1)

oMdlLin:SetNoInsertLine(.T.)
oMdlLin:SetNoDeleteLine(.T.)
oMdlMDFE:SetNoInsertLine(.T.)
oMdlMDFE:SetNoDeleteLine(.T.)
oMdlCte:SetNoInsertLine(.T.)
oMdlCte:SetNoDeleteLine(.T.)

(cAliasG99)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} G814Commit
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function G814Commit(oModel)
Local lRet 		:= .T.

FwMsgRun(, {|| lRet := ProcCommit(oModel) }, ,STR0055)  //"Processando..."
	
Return lRet

/*/{Protheus.doc} ProcCommit
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function ProcCommit(oModel)
Local lRet 		:= .F.
Local oMdlCab	:= oModel:GetModel("HEADER")
Local oMdlLin	:= oModel:GetModel("GRIDLIN")
Local oMdlCte	:= oModel:GetModel("GRIDCTE")
Local oMdlMdfe	:= oModel:GetModel("GRIDMDFE")
Local nX		:= 0
Local nLineMdfe := 0
Local cAgencia  := oMdlCab:GetValue("AGENCIA")

If oMdlLin:SeekLine({{"GI2_MARK",.T.}},.F.,.T.)

	If !(oMdlMdfe:SeekLine({{"GI9_MARK",.T.}},.F.,.T.))
	
		FwAlertWarning(STR0057, STR0056)  //'Atenção!' //'Nenhum MDF-e foi selecionado'
		Return .F.
	
	Endif
	
	nLineMdfe := oMdlMdfe:GetLine()

	For nX := 1 To oMdlCte:Length()

		If oMdlCte:GetValue('G99_MARK',nX)
			
			//Valida encerramento do MDF-e
			If oMdlMdfe:GetValue("GI9_CODREC",nLineMdfe) == cAgencia
				lRet := Gtp814ValMdfe(cAgencia)
				If !lRet
					Aviso(STR0058) //"Não foi possível encerrar o MDF-e."
				EndIf
			ElseIf oMdlCte:GetValue("G99_CODREC",nLineMdfe) == cAgencia
				lRet := .T.
			Else
				lRet := .F.
				Aviso(STR0059) //"Não foi possível efetuar o recebimento no sistema."
			EndIf

			If lRet
				//Altera o status da encomenda
				Gtp801AtuSta(oMdlCte:GetValue("G99_CODIGO",nX),"4",oMdlMdfe:GetValue("GI9_VIAGEM",nLineMdfe),cAgencia)
				//Envia o email para os clientes da encomenda
				GA814MontMail(oMdlCte:GetValue("G99_CODIGO",nX))
			EndIf
		Endif
	
	Next 
	
Else
	FwAlertWarning(STR0060, STR0056)  //'Não há dados selecionados' //'Atenção!'
	lRet := .F.
Endif

Return lRet

/*/{Protheus.doc} Gtp814ValMdfe
(long_description)
@type  Static Function
@author user
@since 04/12/2019
@version version
@param cAgencia, param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function Gtp814ValMdfe(cAgencia)
Local lRet := .T.
Local oModel	:= FwLoadModel('GTPA813E')
Local oModelGik := oModel:GetModel("GIKMASTER")

oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()  

lRet := oModelGik:SetValue("GI6_CODIGO",cAgencia)

If lRet .AND. oModel:VldData()
	oModel:CommitData()
Else
	lRet := .F.		
EndIf
oModel:Deactivate()  
oModel:Destroy()
GtpDestroy(oModel)

Return lRet

/*/{Protheus.doc} GA814MontMail
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function GA814MontMail(cCodG99)
Local cQuery    := ""
Local cBody     := ""
Local nI        := 0
Local cAliasG99 := GetNextAlias()
Local lEnvMail  := GtpGetRules('ENVIAEMAIL', .F., , ".T.")
Local aMails    := {}
Local aChvCte   := {}
Local lUsrEmail := ExistBlock("GA814SendMail")

If lEnvMail
	If GxVldParEmail()
		G99->(DbSetOrder(1))
		If G99->(DbSeek(xFilial('G99') + cCodG99))
			BeginSql  Alias cAliasG99
				SELECT G99.G99_CHVCTE
					, G99.G99_CODREC
					, GI6.GI6_DESCRI
					, SA1REM.A1_NOME   NOMEREM
					, SA1REM.A1_EMAIL  EMAILCLIREM
					, SA1DES.A1_NOME   NOMEDES
					, SA1DES.A1_EMAIL  EMAILCLIDES
				FROM %Table:G99% G99
				INNER JOIN %Table:GI6% GI6 ON
					GI6.GI6_FILIAL = %xFilial:GI6%
					AND GI6.GI6_CODIGO = G99.G99_CODREC
				INNER JOIN %Table:SA1% SA1REM ON
					SA1REM.A1_FILIAL     = %xFilial:SA1%
					AND SA1REM.A1_COD    = G99.G99_CLIREM
					AND SA1REM.A1_LOJA   = G99.G99_LOJREM
					AND SA1REM.%NotDel%
				INNER JOIN %Table:SA1% SA1DES ON
					SA1DES.A1_FILIAL     = %xFilial:SA1%
					AND SA1DES.A1_COD    = G99.G99_CLIDES
					AND SA1DES.A1_LOJA   = G99.G99_LOJDES
					AND SA1DES.%NotDel%
				WHERE G99.%NotDel%
					AND G99.G99_FILIAL = %xFilial:G99%
					AND G99.G99_CODIGO = %Exp:cCodG99%
			EndSql

			While !(cAliasG99)->(Eof())
				AADD(aChvCte,{(cAliasG99)->G99_CHVCTE,(cAliasG99)->NOMEDES,(cAliasG99)->GI6_DESCRI})
				AADD(aMails,{(cAliasG99)->EMAILCLIREM,(cAliasG99)->EMAILCLIDES})
				(cAliasG99)->(dbSkip())
			End

			(cAliasG99)->(dbCloseArea())

			cQuery := "SELECT G9R.G9R_ITEM "
			cQuery += ", G9R.G9R_DESCRI   "
			cQuery += " FROM "+RetSqlName("G99")+" G99 "
			cQuery += " INNER JOIN "+RetSqlName("G9R")+" G9R  "
			cQuery += " ON G9R.D_E_L_E_T_ = ' ' "
			cQuery += " AND G9R.G9R_FILIAL = G99.G99_FILIAL "
			cQuery += " AND G9R.G9R_CODIGO = G99.G99_CODIGO "
			cQuery += " WHERE G99.D_E_L_E_T_ = ' ' "
			cQuery += " AND G99.G99_CODIGO = '" + cCodG99 + "' "

			For nI := 1 To Len(aChvCte)
				If lUsrEmail
					cBody := ExecBlock("GA814SendMail", .f., .f., {cQuery,aChvCte[nI,1],aChvCte[nI,2],aChvCte[nI,3]})
				Else
					cBody := GA814EnvMail(cQuery,aChvCte[nI,1],aChvCte[nI,2],aChvCte[nI,3])
				Endif
			Next

			// Dispara os e-mails individualmente para cada destinatário 
			For nI:= 1 to Len(aMails)
				aValid := AClone(GTPXEnvMail( "noreply@totvs.com.br", aMails[nI,2], aMails[nI,1], "", STR0061, cBody, {})) //"Recebimento da encomenda"
				If !(Len(aValid) > 0)
					lRet := .F.
				EndIf
			Next nI
		EndIf
	Else
		FwAlertHelp("Parâmetros de email não cadastrados","Informe-os para realizar o envio de email","Atenção!!")
	EndIf
EndIf


Return

/*/{Protheus.doc} GA814EnvMail
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 28/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function GA814EnvMail(cQuery,cChvCte,cNomeCl,cNomeAg)
Local aStruct       := {}
Local nI            := 1
Local cHeader       := ""
Local cBody         := ""
Local cRows         := ""
Local cAliasQuery   := GetNextAlias()
Local lOdd          := .F.

cBody += '<body>'
cBody += "<br>"
cBody += "<p>"
cBody += "<b>" + AllTrim(cNomeCl) + ", </b>" 
cBody += "</p>"
cBody += "<p>" 
cBody += STR0062 + "<b>" + AllTrim(cNomeAg) + "</b>"//"Encomenda pronta para entrega, favor se direcionar para agencia."
cBody += "</p>" 
cBody += "<br>"
cBody += "<p>"
cBody += STR0063//"Chave SEFAZ da encomenda: "
cBody += "<b>" + cChvCte + "</b>"
cBody += "</p>" 
cBody += "<br>"


cBody += '<table style="margin-top:50px; border-style:outset; width: 100%; font-family:arial, helvetica, sans-serif;border: 1px solid #08667E;">'
// Roda query no alias cAliasQuery
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQuery, .T., .T.)

// Armazena resultset no array aStruct
aStruct := (cAliasQuery)->(DbStruct())
// Inicia linha do cabeçalho
cBody += "<tr>"

// Percorre e cria campos do cabeçalho como table headers 
For nI := 1 to Len(aStruct)  
    cHeader += '<th style="border: 1px solid #08667E;background-color: #08667E; color: #FFF;text-align: left; padding: 8px;">'
    cHeader += AllTrim(RetTitle((cAliasQuery)->(aStruct[nI][1])) )
    cHeader += "</th>"
Next nI

// Adiciona cabeçalho da tabela 
cBody += cHeader

// Fecha linha de cabeçalho
cBody += "</tr>"

// Percorre resultset e cria os table datas correspondentes com os formatos dos campos
While ((cAliasQuery)->(!Eof()))
    
    If !lOdd
        cRows += "<tr>"
    Else
        cRows += '<tr style= "background-color: #B2BABB;">'
    Endif
    lOdd := !lOdd
    
    For nI := 1 to Len(aStruct)
        cRows += '<td style="border: 1px solid #08667E;text-align: left; padding: 8px;color: #555; font-weight:bold">' 
		If Len(TamSx3(aStruct[nI][1])) >= 3
		// Caso o campo seja uma data
			If TamSx3(aStruct[nI][1])[3] == "D"
				cRows += AllToChar( StoD( (cAliasQuery)->(&(aStruct[nI][1])) ) )
			Else
			    // Caso o campo possua uma picture
				If !Empty(cPicture := AvSx3(aStruct[nI][1] , 6 /*Picture*/) )
					cRows +=  AllToChar(Transform((cAliasQuery)->(&(aStruct[nI][1])) ,cPicture))
				Else
			    // Se o campo não possuir picture
				cRows +=  AllToChar((cAliasQuery)->(&(aStruct[nI][1])))
				Endif   
			Endif
		Else
			cRows +=  AllToChar((cAliasQuery)->(&(aStruct[nI][1])))
		EndIf
		cRows += "</td>" 
	Next nI
	
	cRows += "</tr>"
	(cAliasQuery)->(DBSkip())
End

// Fecha tabela
cBody += cRows 

cBody += "</table>"

cBody += "<br>"
cBody += "<p>" 
cBody += '<i>'+STR0064+'</i>' //"Este e-mail foi enviado de um endereço de notificação, que não esta habilitado a receber mensagens. Por Favor, não responda esta mensagem."
cBody += "</p>"
cBody += '</body>'

(cAliasQuery)->(DbCloseArea())

Return cBody
