#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF90.CH"
#INCLUDE "FWMVCDEF.CH"

Static lTMS3GFE := TmsIntGFE('02')
Static lContDoc := SuperGetMv("MV_CONTDOC",.F.,.F.)
Static lPosVia  := .T.

/*{Protheus.doc} TMSAF90
Viagem Modelo 3
@type Function
@author Valdemar Roberto Mognon
@since 24/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAF90()
(examples)
@see (links_or_references)
*/
Function TMSAF90()
Local cCadastro := STR0001	//-- "Carregamento da Viagem Modelo 3"
Local cPerg     := "TMSAF90"
Local aSetKey   := {}

Private aRotina := MenuDef()

Aadd(aSetKey,{VK_F12,{|| Pergunte(cPerg,.T.)}})

TmsKeyOn(aSetKey)
oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DM6")
oBrowse:SetDescription(cCadastro)

oBrowse:Activate()

TmsKeyOff(aSetKey)

Return

/*{Protheus.doc} MenuDef
Definição do aRotina (Menu funcional)
@type Static Function
@author Valdemar Roberto Mognon
@since 24/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example MenuDef()
(examples)
@see (links_or_references)
*/
Static Function MenuDef()
Local aRotina := {{STR0002,"AxPesqui"       ,0,1,0,.F.} ,;	//-- Pesquisar
				  {STR0003,"VIEWDEF.TMSAF90",0,2,0,.T.} ,;	//-- Visualizar
				  {STR0004,"VIEWDEF.TMSAF90",0,3,0,.T.} ,;	//-- Incluir
				  {STR0009,"VIEWDEF.TMSAF90",0,4,0,.T.} ,;	//-- Alterar
				  {STR0005,"VIEWDEF.TMSAF90",0,5,0,.T.}}	//-- Excluir

Return (aRotina)

/*{Protheus.doc} ModelDef
Definição do Modelo
@type Static Function
@author Valdemar Roberto Mognon
@since 27/07/2020
@version P12 R12.1.20
@param param, param_type, param_descr
@return return, return_type, return_description
@example ModelDef()
(examples)
@see (links_or_references)
*/
Static Function ModelDef()
Local oModel
Local oStruCDM6  := FwFormStruct(1,"DM6")
Local oStruIDM7  := FwFormStruct(1,"DM7")
Local oStruIDTA  := FwFormStruct(1,"DTA")
Local oStruIDYD  := FwFormStruct(1,"DYD")
Local bLinPreDTA := {|oModel,nLine,cAction,cIDField,xValue,xCurrentValue| TMSAF90Lin(oModel,nLine,cAction,cIDField,xValue,xCurrentValue)}
Local bCommit    := {|oModel| TMSAF90Grv(oModel)}
Local bPosVld    := {|oModel| TMF90VldDUD(oModel)}

//-- Remove campos das Model
RemoveFld(oStruIDM7,{"DM7_FILORI","DM7_VIAGEM"})
RemoveFld(oStruIDTA,{"DTA_FILORI","DTA_VIAGEM","DTA_ESTCAR","DTA_LOCAL" ,"DTA_LOCALI","DTA_PESO"  ,"DTA_SERTMS","DTA_TIPTRA","DTA_FILDPC",;
					 "DTA_CODVEI","DTA_MODVEI","DTA_CODRB1","DTA_MODRB1","DTA_CODRB2","DTA_MODRB2","DTA_CODRB3","DTA_MODRB3",;
					 "DTA_PESOM3","DTA_METRO3","DTA_VALMER","DTA_VALFRE","DTA_PESLIQ","DTA_UNITIZ","DTA_CODANA","DTA_SDOC",;
					 "DTA_TIPAGD","DTA_DATAGD","DTA_PRDAGD","DTA_INIAGD","DTA_FIMAGD"  })

RemoveFld(oStruIDYD,{"DYD_NUMAGD","DYD_ITEAGD","DYD_MOTAGD","DYD_DTCAGD","DYD_USUAGD","DYD_NOMUSR","DYD_FILDOC","DYD_DOC",;   
"DYD_SERIE" ,"DYD_CLIREM","DYD_LOJREM","DYD_NOMREM","DYD_CLIDES","DYD_LOJDES","DYD_NOMDES","DYD_CDRORI",;
"DYD_CDRDES","DYD_FILORI","DYD_DATEMI","DYD_FILDES","DYD_DIAATR","DYD_DATREF"})

//-- Fixa os Whens dos campos
FixWhen(oStruIDTA,"TMSAF90Whe('DTA')","DTA")

//-- Fixa os Valids dos campos
FixValid(oStruIDTA,"TMSAF90Vld('DTA')","DTA")

//-- Altera estrutura dos campos
AltStruc(oStruIDTA,{{"DTA_VEICAR",{{3,"0"}}}})

//-- Monta gatilhos
MntTrigger(oStruIDTA,{{{"DTA_FILDOC","DTA_DOC","DTA_SERIE"},{"DTA_QTDVOL","DTA_FILDCA","DTA_SERIE"}}})

oModel := MpFormModel():New("TMSAF90",/*bPreValidacao*/, bPosVld, bCommit,/*bCancel*/)

oModel:SetDescription(STR0006)	//-- "Carregamento"

//-- Cabeçalho do Carregamento
oModel:AddFields("MdFieldDM6",,oStruCDM6,,,)
oModel:SetPrimaryKey({"DM6_FILORI","DM6_VIAGEM"})
oModel:GetModel("MdFieldDM6"):SetDescription(STR0006)	//-- "Carregamento"

//-- Grid dos Veículos
oModel:AddGrid("MdGridDM7","MdFieldDM6",oStruIDM7,/*bLinPre*/,/*bLinPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDM7",{{"DM7_FILIAL","xFilial('DM7')"},;
								 {"DM7_FILORI","DM6_FILORI"},;
								 {"DM7_VIAGEM","DM6_VIAGEM"}},;
								 DM7->(IndexKey(1)))
oModel:GetModel("MdGridDM7"):SetOnlyView(.T.)
oModel:GetModel("MdGridDM7"):SetDescription(STR0008)	//-- "Veículos"

//-- Grid dos Documentos
oModel:AddGrid("MdGridDTA","MdGridDM7",oStruIDTA,bLinPreDTA,/*bLinPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDTA",{{"DTA_FILIAL","xFilial('DTA')"},;
								 {"DTA_FILORI","DM6_FILORI"},;
								 {"DTA_VIAGEM","DM6_VIAGEM"},;
								 {"DTA_CODVEI","DM7_CODVEI"}},;
								 DTA->(IndexKey(5)))
oModel:GetModel("MdGridDTA"):SetOptional(.T.)
oModel:GetModel("MdGridDTA"):SetUniqueLine({"DTA_FILDOC","DTA_DOC","DTA_SERIE"})
oModel:GetModel("MdGridDTA"):SetDescription(STR0007)	//-- "Documentos"


//-- Grid de Agendamento de Entrega
oModel:AddGrid("MdGridDYD","MdGridDTA",oStruIDYD,/*bLinPre*/,/*bLinPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDYD",{{"DYD_FILIAL","xFilial('DYD')"},;
								 {"DYD_FILDOC","DTA_FILDOC"},;
								 {"DYD_DOC","DTA_DOC"},;
								 {"DYD_SERIE","DTA_SERIE"}},;
								 DYD->(IndexKey(2)))
oModel:GetModel("MdGridDYD"):SetOnlyView(.T.)
oModel:GetModel("MdGridDYD"):SetOnlyQuery(.T.)
oModel:GetModel("MdGridDYD"):SetOptional(.T.)
oModel:GetModel("MdGridDYD"):SetDescription(STR0016) //Agendamento de Entrega

oModel:SetVldActivate({|oModel| TMF90PrVld(oModel)})

oModel:SetActivate({|oModel| TMSAF90ACT(oModel)})

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@type Static Function
@author Valdemar Roberto Mognon
@since 27/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example ViewDef()
(examples)
@see (links_or_references)
*/
Static Function ViewDef()
Local oModel    := FwLoadModel("TMSAF90")
Local oView
Local oStruCDM6 := FwFormStruct(2,"DM6")
Local oStruIDM7 := FwFormStruct(2,"DM7")
Local oStruIDTA := FwFormStruct(2,"DTA")
Local oStruIDYD := FwFormStruct(2,"DYD")

//-- Remove campos das Views
RemoveFld(oStruIDM7,{"DM7_FILORI","DM7_VIAGEM"})
RemoveFld(oStruIDTA,{"DTA_FILORI","DTA_VIAGEM","DTA_ESTCAR","DTA_LOCAL" ,"DTA_LOCALI","DTA_PESO"  ,"DTA_SERTMS","DTA_TIPTRA","DTA_FILDPC",;
					 "DTA_CODVEI","DTA_MODVEI","DTA_CODRB1","DTA_MODRB1","DTA_CODRB2","DTA_MODRB2","DTA_CODRB3","DTA_MODRB3",;
					 "DTA_PESOM3","DTA_METRO3","DTA_VALMER","DTA_VALFRE","DTA_PESLIQ","DTA_UNITIZ","DTA_CODANA","DTA_SDOC",;
					 "DTA_TIPAGD","DTA_DATAGD","DTA_PRDAGD","DTA_INIAGD","DTA_FIMAGD"  })

RemoveFld(oStruIDYD,{"DYD_NUMAGD","DYD_ITEAGD","DYD_MOTAGD","DYD_DTCAGD","DYD_USUAGD","DYD_NOMUSR","DYD_FILDOC","DYD_DOC",;   
"DYD_SERIE" ,"DYD_CLIREM","DYD_LOJREM","DYD_NOMREM","DYD_CLIDES","DYD_LOJDES","DYD_NOMDES","DYD_CDRORI",;
"DYD_CDRDES","DYD_FILORI","DYD_DATEMI","DYD_FILDES","DYD_DIAATR","DYD_DATREF"})

oStruIDYD:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)

oView := FwFormView():New()
oView:SetModel(oModel)

oView:CreateHorizontalBox("Viagem",010)
oView:CreateHorizontalBox("Veiculos",025)
oView:CreateHorizontalBox("Documentos",040)
oView:CreateHorizontalBox("AgendaEntr",025)

oView:CreateVerticalBox("Doctos_Butt", 3,"Documentos")
oView:CreateVerticalBox("Doctos_List",97,"Documentos")

oView:AddField("VwFieldDM6",oStruCDM6,"MdFieldDM6")
oView:SetOwnerView("VwFieldDM6","Viagem")

oView:AddGrid("VwGridDM7",oStruIDM7,"MdGridDM7")
oView:SetOwnerView("VwGridDM7","Veiculos")
oView:EnableTitleView("VwGridDM7",STR0008)	//-- "Veículos"

oView:AddGrid("VwGridDTA",oStruIDTA,"MdGridDTA")
oView:SetOwnerView("VwGridDTA","Doctos_List")
oView:EnableTitleView("VwGridDTA",STR0007)	//-- "Documentos"

oView:AddGrid("VwGridDYD",oStruIDYD,"MdGridDYD")
oView:SetOwnerView("VwGridDYD","AgendaEntr")
oView:EnableTitleView("VwGridDYD",STR0016)	 //Agendamento de Entrega

oView:AddOtherObject("VwDoctos",{|oPanel| TF90Doctos(oPanel)})
oView:AddOtherObject("VwCodBar",{|oPanel| TF90CodBar(oPanel)})
oView:SetOwnerView("VwDoctos","Doctos_Butt")
oView:SetOwnerView("VwCodBar","Doctos_Butt")

Return oView

/*{Protheus.doc} RemoveFld
Remove fieldes de uma View
@type Static Function
@author Valdemar Roberto Mognon
@since 27/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example RemoveFld(oStruct,aFields)
(examples)
@see (links_or_references)
*/
Static Function RemoveFld(oStruct,aCampos)
Local nCntFor1 := 0

Default oStruct := Nil
Default aCampos := {}

For nCntFor1 := 1 To Len(aCampos)
	&("oStruct:RemoveField('" + aCampos[nCntFor1] + "')")
Next nCntFor1

Return

/*{Protheus.doc} AltStruc
Altera estrutura dos campos
@type Static Function
@author Valdemar Roberto Mognon
@since 01/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example AltStruc(oStruct,aCampos (cCampo,(1=Valid / 2=When / 3=IniPad / 4=PictVar / 5=Obrigat),cExpressao))
(examples)
@see (links_or_references)
*/
Static Function AltStruc(oStruct,aCampos)
Local bCodigo  := Nil
Local nCntFor1 := 0
Local nCntFor2 := 0

Default oStruc  := Nil
Default aCampos := {}

For nCntFor1 := 1 To Len(aCampos)
	For nCntFor2 := 1 To Len(aCampos[nCntFor1,2])
		If aCampos[nCntFor1,2,nCntFor2,1] == 5
			bCodigo := aCampos[nCntFor1,2,nCntFor2,2]
		Else
			bCodigo := FWBuildFeature(Iif(aCampos[nCntFor1,2,nCntFor2,1] == 1,STRUCT_FEATURE_VALID,;
									  Iif(aCampos[nCntFor1,2,nCntFor2,1] == 2,STRUCT_FEATURE_WHEN,;
									  Iif(aCampos[nCntFor1,2,nCntFor2,1] == 3,STRUCT_FEATURE_INIPAD,;
									  Iif(aCampos[nCntFor1,2,nCntFor2,1] == 4,STRUCT_FEATURE_PICTVAR,Nil)))),aCampos[nCntFor1,2,nCntFor2,2])
		EndIf
				
		oStruct:SetProperty(aCampos[nCntFor1,1],Iif(aCampos[nCntFor1,2,nCntFor2,1] == 1,MODEL_FIELD_VALID,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 2,MODEL_FIELD_WHEN,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 3,MODEL_FIELD_INIT,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 4,MODEL_FIELD_PICTVAR,;
												Iif(aCampos[nCntFor1,2,nCntFor2,1] == 5,MODEL_FIELD_OBRIGAT,Nil))))),bCodigo)
	Next nCntFor2
Next nCntFor1

Return

/*{Protheus.doc} FixWhen
Altera estrutura dos campos
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example FixWhen(oStruct,cFuncao)
(examples)
@see (links_or_references)
*/
Static Function FixWhen(oStruct,cFuncao,cTabela)
Local nCntFor1 := 0
Local aCampos  := {}
Local bCodigo

Default oStruct := Nil
Default cFuncao := ""
Default cTabela := ""

aCampos := oStruct:GetFields()
bCodigo := FWBuildFeature(STRUCT_FEATURE_WHEN,cFuncao)

For nCntFor1 := 1 To Len(aCampos)
	oStruct:SetProperty(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],MODEL_FIELD_WHEN,bCodigo)
Next nCntFor1

Return

/*{Protheus.doc} FixValid
Altera estrutura dos campos
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example FixValid(oStruct,cFuncao)
(examples)
@see (links_or_references)
*/
Static Function FixValid(oStruct,cFuncao,cTabela)
Local nCntFor1 := 0
Local aCampos  := {}
Local bCodigo
Local lFixValid:= .T.
 
Default oStruct := Nil
Default cFuncao := ""
Default cTabela := ""

aCampos := oStruct:GetFields()
bCodigo := FWBuildFeature(STRUCT_FEATURE_VALID,cFuncao)

For nCntFor1 := 1 To Len(aCampos)
	lFixValid := "TMSA210" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_VALID")))
	If lFixValid
		oStruct:SetProperty(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],MODEL_FIELD_VALID,bCodigo)
	EndIf
Next nCntFor1

Return

/*{Protheus.doc} TMSAF90Whe
Valida when dos campos do carregamento da viagem modelo 3
@type Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF90Whe(cOrigem)
Local lRet := .T.

Default cOrigem := ""

If cOrigem == "DTA"
	lRet := WhenDTA()
EndIf

Return lRet

/*{Protheus.doc} WhenDTA
Executa o when dos campos da DTA
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WhenDTA()
Local lRet       := .T.
Local cCampo     := ReadVar()

If AllTrim(cCampo) $ "M->DTA_SEQDTW"
	lRet := WheSeqDTW()
ElseIf AllTrim(cCampo) $ "M->DTA_FILDPC"
	lRet := WheFilDPC()
ElseIf AllTrim(cCampo) $ "M->DTA_QTDVOL"
	lRet := WheQtdVol()
ElseIf AllTrim(cCampo) $ "M->DTA_VEICAR"
	lRet := WheVeiCar()
ElseIf AllTrim(cCampo) $ "M->DTA_ORIGEM"
	lRet := WheOrigem()
EndIf

Return lRet

/*{Protheus.doc} WheSeqDTW
Executa o when do campo DTA_SEQDTW
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WheSeqDTW()
Local lRet := .T.

Return lRet

/*{Protheus.doc} WheFilDPC
Executa o when do campo DTA_FILDPC
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WheFilDPC()
Local lRet := .F.

Return lRet

/*{Protheus.doc} WheQtdVol
Executa o when do campo DTA_QTDVOL
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WheQtdVol()
Local lRet    := .T.
Local aAreas  := {DT6->(GetArea()),GetArea()}

DT6->(dbSetOrder(1))
If DT6->(DbSeek(xFilial("DT6") + FwFldGet("DTA_FILDOC") + FwFldGet("DTA_DOC") + FwFldGet("DTA_SERIE")))
	If DT6->DT6_TIPTRA != StrZero(4,Len(DC5->DC5_TIPTRA))	//-- Transporte Internacional
		Help("",1,"TMSAF9001")	//-- "Nao é permitido efetuar carregamento parcial no transporte nacional."
		lRet := .F.
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} WheVeiCar
Executa o when do campo DTA_VEICAR
@type Static Function
@author Valdemar Roberto Mognon
@since 29/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WheVeiCar()
Local lRet    := .T.

Return lRet

/*{Protheus.doc} WheOrigem
Executa o when do campo DTA_ORIGEM
@type Static Function
@author Valdemar Roberto Mognon
@since 29/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WheOrigem()
Local lRet      := .T.
Local aAreas    := {GetArea()}
Local cQuery    := ""
Local cAliasDUD := GetNextAlias()

cQuery := " SELECT DUD.DUD_MANIFE,DUD.DUD_FILDOC,DUD.DUD_DOC,DUD.DUD_SERIE,DTX.DTX_VIAGEM,DTX.DTX_IDIMDF "

cQuery += "   FROM " + RetSQLName("DUD") + " DUD "

cQuery += "  INNER JOIN " + RetSQLName("DTX") + " DTX "
cQuery += " 	ON DTX.DTX_FILIAL = '" + xFilial("DTX") + "' "
cQuery += "    AND DTX.DTX_FILMAN = '" + cFilAnt  + "' "
cQuery += "    AND DTX.DTX_FILORI = DUD.DUD_FILORI "
cQuery += "    AND DTX.DTX_VIAGEM = DUD.DUD_VIAGEM "
cQuery += "    AND DTX.DTX_TIPMAN = '2' "
cQuery += "    AND DTX.DTX_IDIMDF = '100' "
cQuery += "    AND DTX.D_E_L_E_T_ = ' ' "

cQuery += "	 WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "    AND DUD.DUD_FILORI = '" + FwFldGet("DM6_FILORI") + "' "
cQuery += "    AND DUD.DUD_VIAGEM = '" + FwFldGet("DM6_VIAGEM") + "' "
cQuery += "    AND DUD.DUD_FILDOC = '" + FwFldGet("DTA_FILDOC") + "' "
cQuery += "    AND DUD.DUD_DOC    = '" + FwFldGet("DTA_DOC") + "' "
cQuery += "    AND DUD.DUD_SERIE  = '" + FwFldGet("DTA_SERIE") + "' "
cQuery += "    AND DUD.DUD_MANIFE <> ' ' "
cQuery += "    AND DUD.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasDUD,.F.,.T.)
				
If (cAliasDUD)->(!Eof())
	lRet := .F.
EndIf

(cAliasDUD)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSAF90Vld
Valida campos do carregamento da viagem modelo 3
@type Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF90Vld(cOrigem,cCampo)
Local lRet := .T.

Default cOrigem := ""
Default cCampo  := ReadVar()

If cOrigem == "DM6"
	lRet := ValidDM6(cCampo)
ElseIf cOrigem == "DTA"
	lRet := ValidDTA(cCampo)
EndIf

Return lRet

/*{Protheus.doc} ValidDM6
Valida campos da DM6
@type Static Function
@author Valdemar Roberto Mognon
@since 30/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ValidDM6(cCampo)
Local lRet := .T.

Default cCampo := ReadVar()

If AllTrim(cCampo) $ "M->DM6_FILORI|M->DM6_VIAGEM"
	lRet := VldViagem()
EndIf

Return lRet

/*{Protheus.doc} ValidDTA
Valida campos da DTA
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ValidDTA(cCampo)
Local lRet := .T.

Default cCampo := ReadVar()

If AllTrim(cCampo) $ "M->DTA_FILDOC|M->DTA_DOC|M->DTA_SERIE"
	lRet := VldDocto()
ElseIf AllTrim(cCampo) $ "M->DTA_VEICAR"
	lRet := VldVeiCar()
EndIf

Return lRet

/*{Protheus.doc} VldViagem
Valida os campos DM6_FILORI e DM6_VIAGEM
@type Static Function
@author Valdemar Roberto Mognon
@since 30/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function VldViagem()
Local lRet      := .T.
Local aAreas    := {DTQ->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasDUD := ""

If !Empty(FwFldGet("DM6_FILORI")) .And. !Empty(FwFldGet("DM6_VIAGEM"))
	DTQ->(DbSetOrder(2))
	If !DTQ->(DbSeek(xFilial("DTQ") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM")))
		Help("",1,"TMSAF9003")	//-- Viagem não existe.
		lRet := .F.
	Else
		TF64AltVia()
		If TF64GetSt("nTipAltVia") == 0	//-- Não é operação com Passagem em Cliente ou Ponto de Apoio
			If !DTQ->DTQ_STATUS $ "1,4" .And. DTQ->DTQ_TIPVIA != StrZero(4,Len(DTQ->DTQ_TIPVIA)) 
				Help("",1,"TMSAF9004")	//-- Viagem não esta aberta ou com chegada em filial.
				lRet := .F.
			EndIf
		Else	//-- É operação com Passagem em Cliente ou Ponto de Apoio
			If !DTQ->DTQ_STATUS $ "1,2" .Or. DTQ->DTQ_TIPVIA != StrZero(1,Len(DTQ->DTQ_TIPVIA)) .And.  DTQ->DTQ_TIPVIA != StrZero(4,Len(DTQ->DTQ_TIPVIA))
				Help("",1,"TMSAF9010")	//-- Operação com passagem em cliente ou ponto de apoio somente permitida com viagem normal e em trânsito.
				lRet := .F.
			EndIf
		EndIf
	EndIf
	//-- Verifica se existem documentos para serem carregados
	If lRet
		cAliasDUD := GetNextAlias()
		cQuery := " SELECT 1 QTDDOC "
		
		cQuery += "   FROM " + RetSQLName("DUD") + " DUD "
		
		cQuery += "  WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "    AND DUD.DUD_FILORI = '" + FwFldGet("DM6_FILORI") + "' "
		cQuery += "    AND DUD.DUD_VIAGEM = '" + FwFldGet("DM6_VIAGEM") + "' "
		cQuery += "    AND DUD.D_E_L_E_T_ = ' ' "

		cQuery += "    AND NOT EXISTS (SELECT 1 
		cQuery += "                      FROM " + RetSQLName("DTA") + " DTA "
		cQuery += "                     WHERE DTA.DTA_FILIAL = '" + xFilial("DTA") + "' "
		cQuery += "                       AND DTA.DTA_FILDOC = DUD_FILDOC "
		cQuery += "                       AND DTA.DTA_DOC    = DUD_DOC "
		cQuery += "                       AND DTA_SERIE      = DUD_SERIE "
		cQuery += "                       AND DTA_FILORI     = '" + FwFldGet("DM6_FILORI") + "' "
		cQuery += "                       AND DTA_VIAGEM     = '" + FwFldGet("DM6_VIAGEM") + "' "
		cQuery += "                       AND DTA.D_E_L_E_T_ = ' ')"
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDUD,.F.,.T.)
						
		If (cAliasDUD)->(Eof()) .Or. Empty((cAliasDUD)->QTDDOC)
			Help("",1,"TMSAF9005")	//-- Viagem não possui documentos para carregar.
			lRet := .F.	
		EndIf		
		(cAliasDUD)->(DbCloseArea())
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} VldDocto
Valida os campos DTA_FILDOC, DTA_DOC e DTA_SERIE
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function VldDocto()
Local lRet     := .T.
Local lTMSCTe  := SuperGetMv("MV_TMSCTE",.F.,.F.)
Local aAreas   := {DUD->(GetArea()),GetArea()}
Local aValAgend:= {}

If !Empty(FwFldGet("DTA_FILDOC")) .And. !Empty(FwFldGet("DTA_DOC")) .And. !Empty(FwFldGet("DTA_SERIE"))
	If lContDoc
		lRet := TmsConTran(FwFldGet("DTA_FILDOC"),FwFldGet("DTA_DOC"),FwFldGet("DTA_SERIE"),.T.)
	EndIf

	If lRet
		If FwFldGet("DTA_SERIE") == "COL"
			Help("",1,"TMSAF9011")	//-- "Documentos do tipo coleta não poderão ser carregados."
			lRet := .F.
		EndIf
	EndIf

	//-- Checar o Status do Documento no Processo CT-e. - DT6_IDRCTE == 100 ("Autorizado o uso do CT-e") - DTP_TIPLOT == 3 (Eletronico) 4 Para CT-e Unico
	If lRet
		If lTMSCTe
			DTP->(dbSetOrder(2))
			If DTP->(MsSeek(xFilial("DTP") + DT6->(DT6_FILORI + DT6_LOTNFC))) .And. (DTP->DTP_TIPLOT == StrZero(3,Len(DTP->DTP_TIPLOT)) .Or. DTP->DTP_TIPLOT == StrZero(4,Len(DTP->DTP_TIPLOT)))
				lRet :=	Alltrim(DT6->DT6_IDRCTE) $ "100:136" .Or. !Empty(DT6->DT6_CHVCTG)
	    	    //-- Documento nao estando com alguma das nao conformidades validadas acima mas é um dos seguintes tipos, o processo sera autorizado a dar continuidade
	    	    If !lRet .And. (Alltrim(DT6->DT6_DOCTMS) == StrZero(5,Len(DT6->DT6_DOCTMS)) .Or. ;	//-- Nota Fiscal de Serv. de Transp.
	                            Alltrim(DT6->DT6_DOCTMS) == Replicate("D",Len(DT6->DT6_DOCTMS)) .Or. ;	//-- Nota Fiscal de Reentrega
	                            Alltrim(DT6->DT6_DOCTMS) == Replicate("F",Len(DT6->DT6_DOCTMS)) .Or. ;	//-- Nota Fiscal de Armazenagem
	                            Alltrim(DT6->DT6_DOCTMS) == Replicate("G",Len(DT6->DT6_DOCTMS)))	//-- Nota Fiscal de Complemento
					lRet := .T.
	    	    EndIf
	    	    If !lRet
					Help("",1,"TMSA21025")	//-- "CT-e não autorizado ou não enviado para Sefaz."
					lRet := .F.
				EndIf
			EndIf
		EndIf	
	EndIf

	If lRet
		DUD->(DbSetOrder(1))
		If !DUD->(DbSeek(xFilial("DUD") + FwFldGet("DTA_FILDOC") + FwFldGet("DTA_DOC") + FwFldGet("DTA_SERIE") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM")))
			Help("",1,"TMSAF9002")	//-- "Documento não está indicado para carregamento nesta vigem."
			lRet := .F.
		Else
			//Agendamento de Entrega
			If DUD->DUD_SERTMS == StrZero(3,Len(DUD->DUD_SERTMS))
				aValAgend := TMSAgdVgVl(DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE,dDataBase,SubStr(Time(),1,5) )
				If !aValAgend[1] 
					Help( ,, 'HELP',, aValAgend[2], 1, 0) 
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aValAgend)
Return lRet

/*{Protheus.doc} VldVeiCar
Valida os campos DTA_VEICAR
@type Static Function
@author Valdemar Roberto Mognon
@since 31/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function VldVeiCar()
Local lRet   := .T.
Local cValid := "0"

If !Empty(FwFldGet("DM7_CODRB1"))
	cValid := cValid + "1"
	If !Empty(FwFldGet("DM7_CODRB2"))
		cValid := cValid + "2"
		If !Empty(FwFldGet("DM7_CODRB3"))
			cValid := cValid + "3"
		EndIf
	EndIf
EndIf

lRet := FwFldGet("DTA_VEICAR") $ cValid

Return lRet

/*{Protheus.doc} MntTrigger
Monta gatilhos do carregamento da viagem modelo 3
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function MntTrigger(oStruct,aTrigger)
Local cDominio  := ""
Local cContra   := ""
Local nCntFor1  := 0
Local nCntFor2  := 0
Local nCntFor3  := 0
Local aAux      := {}

Default oStruct  := Nil
Default aTrigger := {}

For nCntFor1 := 1 To Len(aTrigger)
	For nCntFor2 := 1 To Len(aTrigger[nCntFor1,1])
		cDominio := aTrigger[nCntFor1,1,nCntFor2]
		For nCntFor3 := 1 To Len(aTrigger[nCntFor1,2])
			cContra := aTrigger[nCntFor1,2,nCntFor3]

			aAux :=(FwStruTrigger(cDominio	,; // Campo de Dominio
								  cContra	,; // Campo de ContraDominio
								  "TMSAF90GAT('" + cDominio + "', '" + cContra + "')"	,; // Regra de Preenchimento
								  ,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
								  ,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
								  ,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
								  ,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
								  )) // Condição para execução do gatilho (Opcional)

			oStruct:AddTrigger(aAux[1],;	//-- [01] Id do campo de origem
							   aAux[2],;	//-- [02] Id do campo de destino
							   aAux[3],;	//-- [03] Bloco de codigo de validação da execução do gatilho
							   aAux[4])		//-- [04] Bloco de codigo de execução do gatilho
		Next nCntFor3
	Next nCntFor2
Next nCntFor1

FwFreeArray(aAux)

Return

/*{Protheus.doc} TMSAF90GAT
Monta gatilhos dos campos da DTA
@type Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF90GAT(cCampo,cDest)
Local xRet := Nil

Default cCampo := ReadVar()
Default cDest  := ""

If cCampo $ "DM6_FILORI|DM6_VIAGEM"
	xRet:= GatViagem(cCampo,cDest)
ElseIf cCampo $ "DTA_FILDOC|DTA_DOC|DTA_SERIE"
	xRet:= GatDocto(cCampo,cDest)
EndIf

Return xRet 

/*{Protheus.doc} GatViagem
Gatilhos dos campos DTA_FILORI e DTA_VIAGEM
@type Static Function
@author Valdemar Roberto Mognon
@since 30/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function GatViagem(cCampo,cDest)
Local xRet      := Nil
Local aAreas    := {DM7->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasDTR := ""
Local oModel    := FwModelActive()
Local oMdGrdDM7 := oModel:GetModel("MdGridDM7")
Local oStrucDM7 := oMdGrdDM7:GetStruct()
Local aCampos   := Aclone(oStrucDM7:GetFields())
Local nCntFor1  := 0
Local nQtdLin   := 0

If !Empty(FwFldGet("DM6_FILORI")) .And. !Empty(FwFldGet("DM6_VIAGEM"))

	//-- Verifica se o veiculo da viagem já consta na DM7
	DM7->(DbSetOrder(1))
	If !DM7->(DbSeek(xFilial("DM7") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM")))

		//-- Le veiculos da viagem
		cAliasDTR := GetNextAlias()
		cQuery := " SELECT DTR.DTR_ITEM DM7_ITEDTR,DTR.DTR_CODVEI DM7_CODVEI,DA3VEI.DA3_DESC DM7_MODVEI,DTR.DTR_CODRB1 DM7_CODRB1,DA3RB1.DA3_DESC DM7_MODRB1,"
		cQuery += "                                DTR.DTR_CODRB2 DM7_CODRB2,DA3RB2.DA3_DESC DM7_MODRB2,DTR.DTR_CODRB3 DM7_CODRB3,DA3RB3.DA3_DESC DM7_MODRB3 "
		
		cQuery += "   FROM " + RetSQLName("DTR") + " DTR "
	
		cQuery += "   JOIN " + RetSQLName("DA3") + " DA3VEI "
		cQuery += "     ON DA3VEI.DA3_FILIAL = '" + xFilial("DA3") + "' "
		cQuery += "    AND DA3VEI.DA3_COD    = DTR.DTR_CODVEI "
		cQuery += "    AND DA3VEI.D_E_L_E_T_ = ' ' "
	
		cQuery += "   LEFT OUTER JOIN " + RetSQLName("DA3") + " DA3RB1 "
		cQuery += "     ON DA3RB1.DA3_FILIAL = '" + xFilial("DA3") + "' "
		cQuery += "    AND DA3RB1.DA3_COD    = DTR.DTR_CODRB1 "
		cQuery += "    AND DA3RB1.D_E_L_E_T_ = ' ' "
	
		cQuery += "   LEFT OUTER JOIN " + RetSQLName("DA3") + " DA3RB2 "
		cQuery += "     ON DA3RB2.DA3_FILIAL = '" + xFilial("DA3") + "' "
		cQuery += "    AND DA3RB2.DA3_COD    = DTR.DTR_CODRB2 "
		cQuery += "    AND DA3RB2.D_E_L_E_T_ = ' ' "
	
		cQuery += "   LEFT OUTER JOIN " + RetSQLName("DA3") + " DA3RB3 "
		cQuery += "     ON DA3RB3.DA3_FILIAL = '" + xFilial("DA3") + "' "
		cQuery += "    AND DA3RB3.DA3_COD    = DTR.DTR_CODRB3 "
		cQuery += "    AND DA3RB3.D_E_L_E_T_ = ' ' "
		
		cQuery += "  WHERE DTR.DTR_FILIAL = '" + xFilial("DTR") + "' "
		cQuery += "    AND DTR.DTR_FILORI = '" + FwFldGet("DM6_FILORI") + "' "
		cQuery += "    AND DTR.DTR_VIAGEM = '" + FwFldGet("DM6_VIAGEM") + "' "
		cQuery += "    AND DTR.D_E_L_E_T_ = ' ' "
		cQuery += "  ORDER BY DM7_ITEDTR "
	
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTR,.F.,.T.)
						
		If (cAliasDTR)->(!Eof())
			oMdGrdDM7:SetOnlyView(.F.)
			oMdGrdDM7:SetNoInsertLine(.F.)
			While (cAliasDTR)->(!Eof())
				If nQtdLin == 0
					nQtdLin := 1
				Else
					nQtdLin ++
					oMdGrdDM7:Addline()
				EndIf
				oMdGrdDM7:Goline(nQtdLin)
				For nCntFor1 := 1 To Len(aCampos)
					If aCampos[nCntFor1,MODEL_FIELD_IDFIELD] != "DM7_FILIAL"
						oMdGrdDM7:LoadValue(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],(cAliasDTR)->&(aCampos[nCntFor1,MODEL_FIELD_IDFIELD]))
					EndIf
				Next nCntFor1
				(cAliasDTR)->(DbSkip())
			EndDo
			oMdGrdDM7:SetOnlyView(.T.)
		EndIf		
		(cAliasDTR)->(DbCloseArea())
	
		//-- Remonta tela de veiculos carregados
		oMdGrdDM7:GoLine(1)
		
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
FwFreeArray(aCampos)

Return xRet

/*{Protheus.doc} GatDocto
Gatilhos dos campos DTA_FILDOC, DTA_DOC e DTA_SERIE
@type Static Function
@author Valdemar Roberto Mognon
@since 28/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function GatDocto(cCampo,cDest)
Local xRet     := Nil
Local aAreas   := {DYD->(GetArea()),DTQ->(GetArea()),DT6->(GetArea()),GetArea()}
Local aFilDca  := {}

If !Empty(FwFldGet("DTA_FILDOC")) .And. !Empty(FwFldGet("DTA_DOC")) .And. !Empty(FwFldGet("DTA_SERIE"))
	DT6->(DbSetOrder(1))
	If DT6->(DbSeek(xFilial("DT6") + FwFldGet("DTA_FILDOC") + FwFldGet("DTA_DOC") + FwFldGet("DTA_SERIE")))
		If "DTA_QTDVOL" $ cDest
			xRet := DT6->DT6_QTDVOL
		ElseIf "DTA_FILDCA" $ cDest
			DTQ->(DbSetOrder(2))
			If DTQ->(DbSeek(xFilial("DTQ") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM")))
				If DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))
					aFilDca := TMSRegDca(DTQ->DTQ_ROTA,,.T.)
				Else            
					aFilDca := TMSRegDca(DTQ->DTQ_ROTA,DT6->DT6_CDRCAL,.F.)
		            If Empty(aFilDca) 
						aFilDca := TMSRegDca(DTQ->DTQ_ROTA,,.F.)
					EndIf
				EndIf
				xRet := Iif(Len(aFilDca) == 1,aFilDca[1,3],Space(Len(DTA->DTA_FILDCA)))
			EndIf
		ElseIf cDest $ "DTA_SERIE" 
			xRet:= DT6->DT6_SERIE
			//--- Agendamento de Entrega
			If DT6->DT6_SERTMS == StrZero(3,Len(DT6->DT6_SERTMS)) .And. !Empty(DT6->DT6_NUMAGD)
				TF65AgdEnt(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,2)
			EndIf
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return xRet

/*{Protheus.doc} TMSAF90Grv
Tratamento da gravação, alteração e exclusão
@type Function
@author Valdemar Roberto Mognon
@since 03/08/2020
@version version
@param modelo, fechamento automático (1=Sim / 2=Não)
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF90Grv(oModel)
Local nOperation := oModel:GetOperation()
Local lRet       := .T.
Local lFechou    := .T.
Local cQuery     := ""
Local aAreas     := {DTQ->(GetArea()),GetArea()}
Local lVgeAntiga := (Left(FunName(),7) == "TMSA140" .Or. Left(FunName(),7) == "TMSA141" .Or. Left(FunName(),7) == "TMSA143" .Or. ;
					 Left(FunName(),7) == "TMSA144" .Or. Left(FunName(),7) == "TMSA360")

Default oModel  := FWModelActive()

Begin Transaction

	lRet := FwFormCommit(oModel)

	If lRet .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
		DTQ->(DbSetOrder(2))
		If DTQ->(DbSeek(xFilial("DTQ") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM")))
	
			cQuery := " UPDATE " + RetSqlName("DTA")
			cQuery += "    SET DTA_SERTMS = '" + DTQ->DTQ_SERTMS + "', "
			cQuery += "        DTA_TIPTRA = '" + DTQ->DTQ_TIPTRA + "' "
			cQuery += "  WHERE DTA_FILIAL = '" + xFilial("DTA") + "'"
			cQuery += "    AND DTA_FILORI = '" + DTQ->DTQ_FILORI + "' "
			cQuery += "    AND DTA_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
			cQuery += "    AND D_E_L_E_T_ = ' ' "
	
			If TCSqlExec(cQuery) != 0
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf

	If lRet 
		lRet := GravaDUD(oModel,nOperation)
	EndIf
	If lRet
		lRet := GravaDT6(oModel,nOperation)
	EndIf

	If !lRet
		DisarmTransaction()
		Break
	EndIf

	//-- Fechamento automático
	If !lVgeAntiga .And. DTQ->DTQ_TIPVIA != StrZero(3,Len(DTQ->DTQ_TIPVIA)) .And. DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))	//-- Viagem diferente de planejada e em aberto
		If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
			lFechou := TMSAF69(2,"TMSAF90",nOperation,)
		EndIf
	EndIf
		
End Transaction

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} GravaDUD
Grava os campos da DUD na gravação, alteração e exclusão do carregamento
@type Static Function
@author Valdemar Roberto Mognon
@since 03/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function GravaDUD(oModel,nOperation)
Local lRet       := .T.
Local nCntFor1   := 0
Local nCntFor2   := 0
Local nAltViagem := 0
Local aAreas     := {DUD->(GetArea()),GetArea()}
Local cStatus    := ""
Local cStaAnt    := ""
Local oMdlGrdDM7
Local oMdlGrdDTA
Local cFilDca    := Space(Len(DUD->DUD_FILDCA))
Local lAtuGFE    := .F.
Local lGerOper	 := SuperGetMV("MV_GEROPER",,.T.)	//-- Verifica se devera gerar as operacoes
Local lServic    := .T.
Local aServic    := {}

Default oModel     := FWModelActive()
Default nOperation := 0

oMdlGrdDM7 := oModel:GetModel("MdGridDM7")
oMdlGrdDTA := oModel:GetModel("MdGridDTA")

DUD->(DbSetOrder(1))

For nCntFor1 := 1 To oMdlGrdDM7:Length()
	oMdlGrdDM7:GoLine(nCntFor1)
	
	For nCntFor2 := 1 To oMdlGrdDTA:Length()
		oMdlGrdDTA:GoLine(nCntFor2)
		cStatus := ""
		lAtuGFE := .F.
	
		If nOperation == MODEL_OPERATION_DELETE .Or. (nOperation == MODEL_OPERATION_UPDATE .And. oMdlGrdDTA:IsDeleted())
			If DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))
				cStaAnt := StrZero(2,Len(DUD->DUD_STATUS))
				cStatus := StrZero(2,Len(DUD->DUD_STATUS))
			ElseIf DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))
				cStaAnt := StrZero(3,Len(DUD->DUD_STATUS))
				cStatus := StrZero(1,Len(DUD->DUD_STATUS))
			Else
				cStaAnt := StrZero(3,Len(DUD->DUD_STATUS))
				cStatus := StrZero(3,Len(DUD->DUD_STATUS))
			EndIf

		ElseIf (nOperation == MODEL_OPERATION_INSERT .And. !oMdlGrdDTA:IsDeleted()) .Or. (nOperation == MODEL_OPERATION_UPDATE .And. !oMdlGrdDTA:IsDeleted())
			cStaAnt := StrZero(1,Len(DUD->DUD_STATUS))
			If DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))
				cStatus := StrZero(2,Len(DUD->DUD_STATUS))
			Else
				cStatus := StrZero(3,Len(DUD->DUD_STATUS))
			EndIf
			cFilDca := oMdlGrdDTA:GetValue('DTA_FILDCA')
		EndIf
	
		If !Empty(cStatus)
			If DUD->(DbSeek(xFilial("DUD") + FwFldGet("DTA_FILDOC") + FwFldGet("DTA_DOC")  + FwFldGet("DTA_SERIE") + FwFldGet("DM6_FILORI") + ;
											 FwFldGet("DM6_VIAGEM")))

				If DUD->DUD_STATUS == cStaAnt
				
					If lTMS3GFE 
						If DTQ->DTQ_PAGGFE == StrZero(1, Len(DTQ->DTQ_PAGGFE) ) .And. DTQ->DTQ_SERTMS == StrZero(2, Len(DTQ->DTQ_SERTMS) ) .And. Empty(DUD->DUD_NUMRED) 
							lAtuGFE:= .T.
						EndIf
					EndIf
	
					RecLock("DUD",.F.)
					DUD->DUD_STATUS := cStatus
					DUD->DUD_FILDCA := cFilDca
					
					If lAtuGFE
						GrvDUDGFE(cStatus,cFilDca)					
					EndIf
	
					DUD->(MsUnlock())
	
					//-- Adiciona servicos a serem executados
	/*				lServic:= .T.
					If cStatus == StrZero(1,Len(DUD->DUD_STATUS)) //Estorno do Carregamento
						If DUD->DUD_FILDOC == DUD->DUD_FILORI
							lServic:= .F.
						EndIf
					EndIf
					If lServic
						If Ascan( aServic, DUD->DUD_SERVIC ) == 0
							Aadd( aServic, DUD->DUD_SERVIC )
						EndIf
					EndIf*/
				
					//---- Atualiza campos da DM8
					If lAtuGFE
						TF67AtuDM8(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,DUD->DUD_FILORI,DUD->DUD_VIAGEM)
					EndIf
                EndIf
			EndIf
		EndIf
	Next nCntFor2

Next nCntFor1

//If lGerOper 
//	TF90SeqDTW(aServic,FwFldGet("DM6_FILORI"),FwFldGet("DM6_VIAGEM"))
//EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} GrvDUDGFE
Grava os campos da DUD referente a Integração TMS x GFE
@type Static Function
@author Katia
@since 13/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
*/
Static Function GrvDUDGFE(cStatus,cFilDca)
Local aAreaSM0:= SM0->(GetArea())

Default cStatus:= ""
Default cFilDca:= ""

If cStatus == StrZero(3,Len(DUD->DUD_STATUS))  //Carregado
	DUD->DUD_UFDES  := NoAcentoCte(Posicione("SM0",1,cEmpAnt+cFilDca,"M0_ESTENT"))
	DUD->DUD_CDMUND := Substr(NoAcentoCte(Posicione("SM0",1,cEmpAnt+cFilDca,"M0_CODMUN")),3)
	DUD->DUD_CEPDES := NoAcentoCte(Posicione("SM0",1,cEmpAnt+cFilDca,"M0_CEPENT"))
Else
	DUD->DUD_UFDES  := Space(Len(DUD->DUD_UFDES))
	DUD->DUD_CDMUND := Space(Len(DUD->DUD_CDMUND))
	DUD->DUD_CEPDES := Space(Len(DUD->DUD_CEPDES))
EndIf

RestArea(aAreaSM0)
FwFreeArray(aAreaSM0)
Return Nil

/*{Protheus.doc} TmsCarMod3
Indica se é carregamento modelo 3
@type Function
@author Valdemar Roberto Mognon
@since 12/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TmsCarMod3()
Local lRet		:= .F. 
Local oModel	:= Nil

If Left(FunName(),7) == 'TMSAF90' .Or. IsInCallStack("TMSAF90")
	lRet	:= .T. 
Else
	oModel	:= FwModelActive()
	If oModel <> Nil .And. AllTrim(Upper(oModel:cID)) == 'TMSAF90' .And. oModel:IsActive()  //--- Carregamento Modelo 3
		lRet	:= .T. 
	EndIf
EndIf

Return lRet 

/*{Protheus.doc} Tmsaf90Act
Executa a pr-e-validação do modelo principal
@type Function
@author Valdemar Roberto Mognon
@since 13/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function Tmsaf90Act(oModel)
Local lPainel    := IsInCallStack("TMSAF76")
Local oMdlFldDM6

Default oModel := FwModelActive()

//-- Inicia os campos de filial de origem e viagem quando a rotina for chamada do carregamento e for inclusão de um carregamento novo
If TmsVgeMod3() .Or. lPainel
	oMdlFldDM6 := oModel:GetModel("MdFieldDM6")
	If oMdlFldDM6:GetOperation() == 3
		oMdlFldDM6:SetValue("DM6_FILORI",DTQ->DTQ_FILORI)
		oMdlFldDM6:SetValue("DM6_VIAGEM",DTQ->DTQ_VIAGEM)
	EndIf
EndIf

Return

/*{Protheus.doc} GravaDT6
Grava os campos da DT6 na gravação, alteração e exclusão do carregamento
@type Static Function
@author Valdemar Roberto Mognon
@since 18/08/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function GravaDT6(oModel,nOperation)
Local lRet       := .T.
Local nCntFor1   := 0
Local nCntFor2   := 0
Local aAreas     := {DT6->(GetArea()),GetArea()}
Local oMdlGrdDM7
Local oMdlGrdDTA
Local cStatus    := ""
Local cFilOri    := ""
Local cViagem    := ""

Default oModel     := FWModelActive()
Default nOperation := 0

oMdlGrdDM7 := oModel:GetModel("MdGridDM7")
oMdlGrdDTA := oModel:GetModel("MdGridDTA")

DT6->(DbSetOrder(1))

For nCntFor1 := 1 To oMdlGrdDM7:Length()
	oMdlGrdDM7:GoLine(nCntFor1)
	
	For nCntFor2 := 1 To oMdlGrdDTA:Length()
		oMdlGrdDTA:GoLine(nCntFor2)
	
		If nOperation == MODEL_OPERATION_DELETE .Or. (nOperation == MODEL_OPERATION_UPDATE .And. oMdlGrdDTA:IsDeleted())
			cStatus := StrZero(1,Len(DT6->DT6_STATUS))
			cFilOri := Space(Len(DT6->DT6_FILVGA))
			cViagem := Space(Len(DT6->DT6_NUMVGA))
		ElseIf (nOperation == MODEL_OPERATION_INSERT .And. !oMdlGrdDTA:IsDeleted()) .Or. (nOperation == MODEL_OPERATION_UPDATE .And. !oMdlGrdDTA:IsDeleted())
			If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS))	//-- Viagem Transporte
				cStatus := StrZero(2,Len(DT6->DT6_STATUS))	//-- Carregado
			ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))	//-- Viagem Entrega
				cStatus := StrZero(6,Len(DT6->DT6_STATUS))	//-- Indicado para Entrega
			EndIf
			cFilOri := DTQ->DTQ_FILORI
			cViagem := DTQ->DTQ_VIAGEM
		EndIf
	
		If DT6->(DbSeek(xFilial("DT6") + FwFldGet("DTA_FILDOC") + FwFldGet("DTA_DOC")  + FwFldGet("DTA_SERIE")))
			RecLock("DT6",.F.)
			DT6->DT6_STATUS := cStatus
			DT6->DT6_FILVGA := cFilOri
			DT6->DT6_NUMVGA := cViagem
			DT6->(MsUnlock())
		EndIf
	Next nCntFor2

Next nCntFor1

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMF90PrVld
Grava os campos da DT6 na gravação, alteração e exclusão do carregamento
@type Static Function
@author Valdemar Roberto Mognon
@since 03/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TMF90PrVld(oModel)
Local lRet       := .T.
Local lCont      := .T.
Local aManifes   := {}
Local aAreas     := {DTQ->(GetArea()),GetArea()}
Local nOperation := 0

Default oModel  := FwModelActive()

nOperation := oModel:GetOperation()

If nOperation != MODEL_OPERATION_VIEW .And. nOperation != MODEL_OPERATION_INSERT
	//-- Posiciona na viagem
	If lPosVia
		DTQ->(DbSetOrder(2))
		lCont := (DTQ->(DbSeek(xFilial("DTQ") + DM6->(DM6_FILORI + DM6_VIAGEM))))
	EndIf
    
	If lCont
		//-- Verifica o status da viagem
		If !DTQ->DTQ_STATUS $ "1,2,4" .AND. !FunName()=="TMSA210"
		Help("", 1,"TMSAF9012")	//-- "Viagem não está aberta, em trânsito ou com chegada em filial."
			lRet := .F.
		EndIf
		
		//-- Verifica se permite o estorno do carregamento
		If lRet .And. nOperation == MODEL_OPERATION_DELETE
			lRet := TMSChkViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,.T.,.F.,.F.,,.F.,.F.,,.T.,,,.F.,.T.)
		EndIf
		
		//-- Verifica se possui manifestos com cancelamento não transmitidos
		If lRet
			lRet := !TMF90CnMan(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,@aManifes,.T.)
		EndIf
		
		//-- Verifica se possui manifestos com encerramento não transmitidos
		If lRet .And. nOperation == MODEL_OPERATION_DELETE
			lRet := !TMF90EnMan(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,@aManifes,.F.)
		EndIf

		//-- Verifica se todos os Lotes da Viagem estao calculados 
		If lRet 
			lRet:= TF64VldLot(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,"'3'")  //3-Calculado
			If !lRet 				
				CheckHLP("PTMSAF9009",{"Existem Lotes vinculados a essa "," viagem. Não será permitido efetuar o estorno"," do carregamento da viagem."},{""},{""},.T.)
				Help("", 1,"TMSAF9009")	//-- "Existem Lotes vinculados a essa viagem. Não será permitido efetuar o estorno do carregamento da viagem."
			EndIf
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMF90CnMan
Busca se a viagem possui manifestos com cancelamento não transmitido
@type Static Function
@author Valdemar Roberto Mognon
@since 03/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TMF90CnMan(cFilOri,cViagem,aManifes,lMstrErro,nLoop,cFilMan)
Local aAreas     := {GetArea()}
Local aAreaSM0   := {}
Local aMDFeCan   := {}
Local lContinua  := .F.
Local lRet       := .F.
Local cQuery     := ""
Local cAliasDYN  := ""
Local cErro      := ""
Local cTitFilMan := ""
Local cTitManife := ""
Local cTitSerMan := ""
Local cTitRTCMDF := ""
Local cFilBak    := cFilAnt
Local lMDFeAut   := SuperGetMV("MV_MDFEAUT",,.F.) .And. ExistFunc("TmsMDFeAut")

Default cFilOri  := ""
Default cViagem  := ""
Default aManifes := {}
Default lMsgErr  := .T.
Default nLoop    := 1
Default cFilMan  := ""

//-- Busca os titulos dos campos 
cTitFilMan  := FWX3Titulo("DTX_FILMAN")
cTitManife  := FWX3Titulo("DTX_MANIFE")
cTitSerMan  := FWX3Titulo("DTX_SERMAN")
cTitRTCMDF  := FWX3Titulo("DYN_RTCMDF") 

If (lMDFeAut .Or. ExistFunc("TmsAutViag")) .And. FindFunction("TMA190Srv")  //Verifica o serviço de transporte da viagem
	lMDFeAut:= TMA190Srv(cFilOri,cViagem)
EndIf

cAliasDYN := GetNextAlias()
cQuery += "SELECT DYN_FILMAN,DYN_MANIFE,DYN_SERMAN,DYN_VIAGEM,DYN_RTCMDF  "
cQuery += "  FROM " + RetSQLName("DYN") + " DYN "
cQuery += " WHERE DYN_FILIAL = '" + xFilial("DYN") + "' "
cQuery += "       AND DYN_FILORI = '" + cFilOri + "' "
cQuery += "       AND DYN_VIAGEM = '" + cViagem + "' "
cQuery += "       AND DYN_STCMDF <> '2' "	//2-Autorizado
If !Empty(cFilMan)
	cQuery += "       AND DYN_FILMAN = '" + cFilMan + "' " 
EndIf
cQuery += "       AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDYN,.F.,.T.)

While (cAliasDYN)->(!Eof())
    lRet := .T.

	If lMDFeAut .And. nLoop == 1
		Aadd(aMDFeCan,{(cAliasDYN)->DYN_FILMAN,(cAliasDYN)->DYN_MANIFE,(cAliasDYN)->DYN_MANIFE,(cAliasDYN)->DYN_SERMAN,(cAliasDYN)->DYN_VIAGEM,""})
	Else
		Aadd(aManifes,{(cAliasDYN)->DYN_FILMAN,(cAliasDYN)->DYN_MANIFE,(cAliasDYN)->DYN_SERMAN,(cAliasDYN)->DYN_RTCMDF})

		If lMsgErr
			cErro += cTitFilMan +  " : " + (cAliasDYN)->DYN_FILMAN + " | "
			cErro += cTitManife +  " : " + (cAliasDYN)->DYN_MANIFE + " | "
			cErro += cTitSerMan +  " : " + (cAliasDYN)->DYN_SERMAN + " | "
			cErro += cTitRTCMDF +  " : " + (cAliasDYN)->DYN_RTCMDF + CRLF + CRLF
		EndIf
	EndIf
	(cAliasDYN)->(DbSkip())
EndDo

(cAliasDYN)->(DbCloseArea())

If Len(aMDFeCan) > 0
	//-- Alterar o conteudo da variavel cFilAnt
	aAreaSM0  := SM0->(GetArea())
	cFilAnt   := Posicione("SM0",1,cEmpAnt + aMDFeCan[Len(aMDFeCan),1],"FWCODFIL()")
	lContinua := TmsMDFeAut(aMDFeCan,3) //-- Transmite o cancelamento do MDF-e
	If lContinua
		TmsLimpDUD(cFilOri,cViagem,aMDFeCan)	//-- Limpar a DUD
	EndIf
	cFilAnt := Posicione("SM0",1,cEmpAnt + cFilBak,"FWCODFIL()")
	RestArea(aAreaSM0)
EndIf

If !lMDFeAut .Or. nLoop > 1
	// Exibe a mensagem de erro.
	If lRet .AND. lMsgErr
		AutoGrLog(STR0012 + CRLF)	//-- "Não poderá ser realizado o estorno do carregamento, pois os seguintes manifestos possuem cancelamento não transmitido:"
		AutoGrLog( cErro )
    	MostraErro()
	EndIf
Else
	lRet := TMF90CnMan(cFilOri,cViagem,aManifes,lMsgErr,++nLoop)
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMF90EnMan
Busca se a viagem possui manifestos com encerramento não transmitido
@type Static Function
@author Valdemar Roberto Mognon
@since 03/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TMF90EnMan(cFilOri,cViagem,aManifes,lMstrErro,nLoop,cFilMan)
Local aAreas     := {GetArea()}
Local aAreaSM0   := {}
Local aMDFeEnc   := {}
Local lContinua  := .F.
Local lRet       := .F.
Local cQuery     := ""
Local cAliasDTX  := ""
Local cErro      := ""
Local cTitFilMan := ""
Local cTitManife := ""
Local cTitSerMan := ""
Local cTitSTFMDF := ""
Local cFilBak    := cFilAnt
Local lUFAtiv    := DTX->(ColumnPos("DTX_UFATIV")) > 0
Local lMDFeAut   := SuperGetMV("MV_MDFEAUT",,.F.) .And. ExistFunc("TmsMDFeAut")	

Default cFilOri   := ""
Default cViagem   := ""
Default aManifes  := {}
Default lMstrErro := .T.
Default nLoop     := 1
Default cFilMan   := ""

//--  Busca os titulos dos campos 
cTitFilMan  := FWX3Titulo("DTX_FILMAN")
cTitManife  := FWX3Titulo("DTX_MANIFE")
cTitSerMan  := FWX3Titulo("DTX_SERMAN")
cTitSTFMDF  := FWX3Titulo("DTX_STFMDF")

cAliasDTX := GetNextAlias()
cQuery += "SELECT DTX_FILMAN,DTX_FILORI,DTX_MANIFE,DTX_SERMAN,DTX_VIAGEM,DTX_STFMDF "
If lUfAtiv 							
	cQuery += ",DTX_UFATIV "
EndIf
cQuery += "  FROM " + RetSQLName("DTX") + " DTX "
cQuery += " WHERE DTX_FILIAL = '" + xFilial("DTX") + "' "
cQuery += "       AND DTX_FILORI = '" + cFilOri + "' "
cQuery += "       AND DTX_VIAGEM = '" + cViagem + "' "
cQuery += "       AND DTX_STFMDF <> '2' "	//-- Encerramento não Autorizado
cQuery += "       AND DTX_STIMDF = '2' "	//-- Envio Autorizado
If !Empty(cFilMan)
	cQuery += "       AND DTX_FILMAN = '" + cFilMan + "' "
EndIf
cQuery += "       AND D_E_L_E_T_ = ' ' "
cQuery += "       AND NOT EXISTS (SELECT 1 "
cQuery += "                         FROM " + RetSqlName("DYN") + " DYN "
cQuery += "                        WHERE DYN.DYN_FILIAL = '" + xFilial("DYN") + "' "
cQuery += "                          AND DYN.DYN_FILORI = '" + cFilOri + "' "
cQuery += "                          AND DYN.DYN_VIAGEM = '" + cViagem + "' "
cQuery += "                          AND DYN.DYN_STCMDF <> '2' "	//-- Cancelamento não Autorizado
If !Empty(cFilMan)
	cQuery += "                          AND DYN.DYN_FILMAN = '" + cFilMan + "' "
EndIf
cQuery += "                          AND DYN.D_E_L_E_T_ = ' ' )"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDTX,.F.,.T.)

While (cAliasDTX)->(!Eof())
    lRet := .T.
	
	If (lMDFeAut .Or. ExistFunc("TmsAutViag")) .And. FindFunction("TMA190Srv")  //Verifica o serviço de transporte da viagem
		lMDFeAut:= TMA190Srv((cAliasDTX)->DTX_FILORI,(cAliasDTX)->DTX_VIAGEM)
	EndIf

	If lMDFeAut .And. nLoop == 1
		Aadd(aMDFeEnc,{(cAliasDTX)->DTX_FILMAN,(cAliasDTX)->DTX_MANIFE,(cAliasDTX)->DTX_MANIFE,(cAliasDTX)->DTX_SERMAN,(cAliasDTX)->DTX_VIAGEM,Iif(lUFAtiv,(cAliasDTX)->DTX_UFATIV,"")})
	Else
		Aadd(aManifes,{(cAliasDTX)->DTX_FILMAN,(cAliasDTX)->DTX_MANIFE,(cAliasDTX)->DTX_SERMAN,(cAliasDTX)->DTX_STFMDF})
						
		If lMstrErro
			cErro += cTitFilMan +  " : " + (cAliasDTX)->DTX_FILMAN + " | "
			cErro += cTitManife +  " : " + (cAliasDTX)->DTX_MANIFE + " | "
			cErro += cTitSerMan +  " : " + (cAliasDTX)->DTX_SERMAN + " | "
			cErro += cTitSTFMDF +  " : " + (cAliasDTX)->DTX_STFMDF + CRLF + CRLF
		EndIf
	EndIf
	(cAliasDTX)->(DbSkip())
EndDo

(cAliasDTX)->(DbCloseArea())
	
If Len(aMDFeEnc) > 0
	//-- Alterar o conteudo da variavel cFilAnt
	aAreaSM0  := SM0->(GetArea())
	cFilAnt   := Posicione("SM0",1,cEmpAnt + aMDFeEnc[Len(aMDFeEnc),1],"FWCODFIL()")
	lContinua := TmsMDFeAut(aMDFeEnc, 2)	//-- Transmite o Encerramento do MDF-e
	If lContinua
		TmsLimpDUD(cFilOri,cViagem,aMDFeEnc)	//-- Limpar a DUD
	EndIf
	cFilAnt := Posicione("SM0",1,cEmpAnt+cFilBak,"FWCODFIL()")
	RestArea(aAreaSM0)
EndIf 
	
If !lMDFeAut .Or. nLoop > 1
	// Exibe a mensagem de erro.
	If lRet .AND. lMstrErro
		AutoGrLog(STR0013 + CRLF)	//-- "Não poderá ser realizado o estorno do carregamento, pois os seguintes manifestos possuem encerramento não transmitido:"
		AutoGrLog(cErro)
    	MostraErro()
	EndIf
Else
	lRet := TMF90EnMan(cFilOri,cViagem,aManifes,lMstrErro,++nLoop)
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSAF90Lin
Chama Pre Validação da Linha dos Documentos
@type Function
@author Valdemar Roberto Mognon
@since 03/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF90Lin(oModel,nLine,cAction,cIDField,xValue,xCurrentValue)
Local lRet := .T.

lRet:= LinePreDTA(oModel,nLine,cAction,cIDField,xValue,xCurrentValue)

Return lRet

/*{Protheus.doc} LinePreDTA
Pre Valida Linha dos Documentos
@type Function
@author Valdemar Roberto Mognon
@since 03/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function LinePreDTA(oMdlGridDTA,nLine,cAction,cIDField,xValue,xCurrentValue)
Local lRet   := .T.
Local aAreas := {DTQ->(GetArea()),GetArea()}

If cAction == "DELETE"
	DTQ->(DbSetOrder(2))
	If DTQ->(DbSeek(xFilial("DTQ") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM"))) .And. !DTQ->DTQ_STATUS $ "1,2,4"
		Help("", 1,"TMSAF9012")	//-- "Viagem não está aberta, em trânsito ou com chegada em filial."
		lRet:= .F.
	EndIf
	
	If lRet
		If lContDoc
			TmsConTran(FwFldGet("DTA_FILDOC"),FwFldGet("DTA_DOC"),FwFldGet("DTA_SERIE"),.F.)
		EndIf
	EndIf
	
	If FwFldGet("DTA_FILATU") != cFilAnt
		Help("", 1,"TMSAF9007")	//-- "Somente é permitido o estorno do carregamento de documentos da filial atual."
		lRet:= .F.
	EndIf
ElseIf cAction == "UNDELETE"
	If lContDoc
		lRet := TmsConTran(FwFldGet("DTA_FILDOC"),FwFldGet("DTA_DOC"),FwFldGet("DTA_SERIE"),.T.)
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSAF90Set
Seta valor em variável estatica
@type Function
@author Valdemar Roberto Mognon
@since 08/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF90Set(cVar,xCont)

&(cVar) := xCont

Return


/*{Protheus.doc} TF90GerOpe
Gera operacoes de transporte, Obtendo sequencia para operaçôes de "carregamento"
@type Function
@author Katia
@since 14/09/2020
@version version
@param cFilOri,cViagem
@return 
*/
Function TF90GerOpe(cFilOri,cViagem,aNewDoc)
Local cSequen    := ""
Local cAtvChgApo := SuperGetMv("MV_ATVCHPA",,"")	//-- Atividade de Chegada no Ponto de Apoio
Local cAtvChgCli := SuperGetMv("MV_ATVCHGC",,"")	//-- Atividade de Chegada em Cliente
Local cQuery     := ""
Local cAliasNew  := ""
Local cOrigem    := ""
Local cOpeDoc    := ""
Local cSeekDTW   := ""
Local aCabDTW    := {}
Local aAreas     := {DTW->(GetArea()),GetArea()}
Local nCntFor1   := 0
Local nAltViagem := 0

Default cFilOri := ""
Default cViagem := ""
Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default aNewDoc := {}

//-- Verifica se a Rota é de Ponto de Apoio
nAltViagem := TF64GetSt("nTipAltVia")

If nAltViagem == 2 .Or. nAltViagem == 3	//-- Passagem em Cliente ou Ponto de Apoio
	//-- Obtendo sequencia para operaçôes de "carregamento"
	DTW->(DbSetOrder(1))
	DTW->(DbSeek(cSeekDTW := xFilial("DTW") + cFilOri + cViagem))
	While DTW->(!Eof()) .And. DTW->(DTW_FILIAL + DTW_FILORI + DTW_VIAGEM) == cSeekDTW
		If !Empty(DTW->DTW_SEQUEN) .And. DTW->DTW_STATUS == "1"
			DTW->(DbSkip(-1))
			cSequen := DTW->DTW_SEQUEN
			Exit
		EndIf
		DTW->(DbSkip())
	EndDo

	cAliasNew := GetNextAlias()
	cQuery := "SELECT DTW.DTW_IDDTW "
	cQuery += "  FROM " + RetSqlName("DTW") + " DTW "
	cQuery += " WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
	cQuery += "   AND DTW.DTW_FILORI = '" + cFilOri + "' "
	cQuery += "   AND DTW.DTW_VIAGEM = '" + cViagem + "' "
	If nAltViagem == 2	//-- Chegada em cliente
		cQuery += "   AND DTW.DTW_ATIVID = '" + cAtvChgCli + "' "
		cQuery += "   AND DTW.DTW_CODCLI = '" + aNewDoc[1,1] + "' "
		cQuery += "   AND DTW.DTW_LOJCLI = '" + aNewDoc[1,2] + "' "
	ElseIf nAltViagem == 3	//-- Chegada em ponto de apoio
		cQuery += "   AND DTW.DTW_ATIVID = '" + cAtvChgApo + "' "
	EndIf
	cQuery += "   AND DTW.DTW_STATUS = '2' "
	cQuery += "   AND DTW.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY DTW.DTW_IDDTW DESC"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
	If (cAliasNew)->(!Eof()) .And. ExistFunc("Tmsa351DLT")
		Aadd(aCabDTW,{"DTW_FILORI",cFilOri               ,Nil})
		Aadd(aCabDTW,{"DTW_VIAGEM",cViagem               ,Nil}) 
		Aadd(aCabDTW,{"DTW_IDDTW" ,(cAliasNew)->DTW_IDDTW,Nil}) 
		cOrigem	:= "2"	//-- Viagem em Trânsito
		For nCntFor1 := 1 To Len(aNewDoc)
			If aNewDoc[nCntFor1,7] == "COL"
				cOpeDoc	:= "3"	//-- Coleta
			Else 
				cOpeDoc	:= "2"	//-- Emissão
			EndIf 
			Tmsa351DLT(aCabDTW,4,cFilOri,cViagem,(cAliasNew)->DTW_IDDTW,aNewDoc[nCntFor1,5],aNewDoc[nCntFor1,6],aNewDoc[nCntFor1,7],cOrigem,cOpeDoc)
		Next nCntFor1
	EndIf
	(cAliasNew)->(DbCloseArea())

	If nAltViagem == 2	//-- Passagem em cliente
		aNewDoc := aSort(aNewDoc,,,{|x,y| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + x[7] < y[1] + y[2] + y[3] + y[4] + y[5] + y[6] + y[7]})
		//-- Remetente
		If !Empty(aNewDoc[1,1]) .And. !Empty(aNewDoc[1,2])
			TF90GerDTW(aNewDoc[1,5],aNewDoc[1,6],aNewDoc[1,7],cFilOri,cViagem,aNewDoc[1,1],aNewDoc[1,2],.T.)
		EndIf
		For nCntFor1 := 1 To Len(aNewDoc)
			//-- Destinatario
			If !((Empty(aNewDoc[nCntFor1,3]) .Or. Empty(aNewDoc[nCntFor1,4])) .And. aNewDoc[nCntFor1,7] == "COL" .And. !Empty(cSequen) .And. Len(cSequen) > 1) .And. Empty(aNewDoc[nCntFor1,8]) .And. Empty(aNewDoc[nCntFor1,9])
				TF90GerDTW(aNewDoc[nCntFor1,5],aNewDoc[nCntFor1,6],aNewDoc[nCntFor1,7],cFilOri,cViagem,aNewDoc[nCntFor1,3],aNewDoc[nCntFor1,4],.F.)
			EndIf
		Next nCntFor1
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TF90GerDTW
Realiza geração das operações (DTW)
@type function
@author Caio Murakami
@version 12
@param  
@since 11/03/2019
@return lRet True ou False
Função extraida do TMSA210.PRW (A210GerDTW)
/*/
//-------------------------------------------------------------------------------------------------
Static Function TF90GerDTW( cFilDoc , cDoc , cSerie , cFilOri , cViagem  , cCodCli , cLojCli , lRemet )
Local cQuery		:= ""
Local cAliasNew		:= ""
Local cAtivChg		:= SuperGetMv("MV_ATIVCHG",,"")
Local cAtvSaiCli	:= SuperGetMv('MV_ATVSAIC',,'')//-- Atividade de Saída do cliente
Local cAtvChgCli	:= SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada em Cliente
Local cAtivOld  	:= ""
Local cServic		:= ''
Local aCab			:= {}
Local cSequen		:= "0"
Local aSequen		:= {}
Local nSequen		:= 0
Local lGeraCar		:= .F. 
Local cHoraPre		:= ""
Local dDataPre		:= dDataBase
Local nA			:= 0 
Local nContr		:= 0
Local lUFAtiv   	:= DTW->(ColumnPos("DTW_UFATIV")) > 0
Local lRet			:= .T.
Local lcriaDLT		:= .F.
Local lIdDTW		:= DTW->(ColumnPos("DTW_IDDTW")) > 0 
Local cOpeDoc		:= ""
Local cIdDTW		:= ""
Local cOrigem		:= ""
Local cAliasDTW		:= ""
Local cQueryDTW		:= ""
Local aCabDTW		:= {}
Local aArea			:= GetArea()
Local lContinua		:= .F. 
Local oDadosViag    := Nil
Local aDocs		    := {}
Local nPStatus      := 0
Local nPCliExp      := 0
Local nPLojExp      := 0
Local nPCliRem      := 0
Local nPLojRem      := 0
Local nPCliDes      := 0
Local nPLojDes      := 0
Local nPFilDoc      := 0
Local nPDoc         := 0
Local nPSerie       := 0
Local cServEnt      := Padr(SuperGetMV("MV_SVCENT",,""),Len(DC5->DC5_SERVIC))
Local cSerTMS       := ""
Local cTipTra       := ""

Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""
Default cFilOri		:= ""
Default cViagem		:= ""
Default cCodCli		:= ""
Default cLojCli		:= ""
Default lRemet		:= .F. 

DTW->(dbSetOrder(1))
If DTW->(MsSeek(xFilial('DTW')+ cFilOri + cViagem ))
	If(!Empty(DTW->DTW_SEQUEN))	
		While DTW->( DTW_VIAGEM == cViagem )
			If DTW->(DTW_STATUS == "1")
				DTW->(DbSkip(-1))
				cSequen := DTW->DTW_SEQUEN
				DTW->(DbSkip())
				Exit
			EndIf
			DTW->(DbSkip())
		EndDo
		DTW->(DbSkip())
	EndIf
EndIf

lContinua	:=	TF90VldDTW( cFilOri , cViagem , cCodCli , cLojCli , lRemet )

If lContinua

    oDadosViag	:= TMSBCADadosTMS():New(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,,.F.)
    oDadosViag:AddCustomerTrip(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)			
    oDadosViag:AddDocs(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)	
    aDocs 		:= oDadosViag:GetDocs()

	cSerTMS := DTQ->DTQ_SERTMS
	cTipTra := DTQ->DTQ_TIPTRA

    cQuery := "SELECT DC5.DC5_SERVIC, DC5.DC5_TAREFA, DC6.DC6_ATIVID "
    cQuery += "FROM " + RetSqlName("DC5") + " DC5 "
    cQuery += "INNER JOIN " + RetSqlName("DC6") + " DC6 "
    cQuery += "ON DC5.DC5_FILIAL = '" + xFilial("DC5") + "' "
    cQuery += "AND DC6.DC6_FILIAL = '" + xFilial("DC6") + "' "
    cQuery += "AND DC5.DC5_TAREFA = DC6.DC6_TAREFA "
    cQuery += "AND DC5.D_E_L_E_T_ = ' ' "
    cQuery += "AND DC6.D_E_L_E_T_ = ' ' "
    cQuery += "WHERE DC5.DC5_SERVIC = '" + Iif(Empty(cSequen) .OR. cSequen == "0" .OR. DTQ->DTQ_STATUS == "1", cServEnt, DA8->DA8_SERVIC) + "' "

    If !Empty(cSequen) .AND. Len(cSequen) > 1
        cQuery += "AND DC6.DC6_ATIVID IN ('" + cAtvSaiCli + "', '" + cAtvChgCli + "') "
        DTW->(dbSetOrder(4))
        If DTW->(MsSeek(xFilial('DTW')+ cFilOri + cViagem + cAtivChg))
            nSequen := Val(DTW->DTW_SEQUEN)
            nSequen -= 10
            cSequen := StrZero(nSequen, Len(DTW->DTW_SEQUEN) )
        EndIf
    EndIf

    cQuery += "AND NOT EXISTS ("
    cQuery += 	"SELECT DTW.DTW_VIAGEM "
    cQuery += 	"FROM " + RetSqlName("DTW") + " DTW "
    cQuery += 	"WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
    cQuery += 	"AND DTW.DTW_FILORI = '" + cFilOri + "' "
    cQuery += 	"AND DTW.DTW_VIAGEM = '" + cViagem + "' "
    cQuery += 	"AND DTW.DTW_SERVIC = DC5.DC5_SERVIC "
    cQuery += 	"AND DTW.DTW_TAREFA = DC5.DC5_TAREFA "
    cQuery += 	"AND DTW.DTW_ATIVID = DC6.DC6_ATIVID "
    cQuery += 	"AND DTW.DTW_CODCLI = '" + cCodCli + "' "
    cQuery += 	"AND DTW.DTW_LOJCLI = '" + cLojCli + "' "
    cQuery += 	"AND DTW.DTW_STATUS = '1' "
    cQuery += 	"AND DTW.D_E_L_E_T_ = ' ') ORDER BY DC6.DC6_ORDEM"

    cQuery := ChangeQuery(cQuery)

    cAliasNew := GetNextAlias()
    DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

    // Caso já existam as operações do cliente e não estejam apontadas.
    If (cAliasNew)->(Eof()) .AND. lRemet .AND. DTQ->DTQ_STATUS == StrZero(2, Len(DTQ->DTQ_STATUS))
        (cAliasNew)->(dbCloseArea())
        // Não for uma solicitação de coleta.
        If cSerie <> "COL"
            cQuery := 	"SELECT DTW.R_E_C_N_O_ DTWRECNO "
            cQuery += 	"FROM " + RetSqlName("DTW") + " DTW "
            cQuery += 	"WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
            cQuery += 	"AND DTW.DTW_FILORI = '" + cFilOri + "' "
            cQuery += 	"AND DTW.DTW_VIAGEM = '" + cViagem + "' "
            cQuery += 	"AND DTW.DTW_CODCLI = '" + cCodCli + "' "
            cQuery += 	"AND DTW.DTW_LOJCLI = '" + cLojCli + "' "
            cQuery += 	"AND DTW.DTW_ATIVID = '" + cAtvChgCli + "' "
            cQuery += 	"AND DTW.DTW_STATUS = '1' "
            cQuery += 	"AND DTW.D_E_L_E_T_ = ' '"
            cAliasNew := GetNextAlias()
            DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

            If (cAliasNew)->(!Eof())
                DTW->(dbGoto((cAliasNew)->DTWRECNO))
                RecLock("DTW", .F.)
                DTW->DTW_DATINI := dDataBase
                DTW->DTW_HORINI := StrTran(Left(Time(), 5), ":", "")
                DTW->DTW_DATREA := dDataBase
                DTW->DTW_HORREA := StrTran(Left(Time(), 5), ":", "")
                DTW->DTW_STATUS := StrZero(2, Len(DTW->DTW_STATUS))
                    
                If DTW->(ColumnPos("DTW_SYSDAT")) > 0 .AND. DTW->(ColumnPos("DTW_SYSHOR")) > 0
                    DTW->DTW_SYSDAT := dDataBase
                    DTW->DTW_SYSHOR := StrTran(Time(), ":", "")
                EndIf
                cIdDTW := DTW->DTW_IDDTW
                DTW->(MsUnlock())
            EndIf
            (cAliasNew)->(dbCloseArea())

            If AliasInDic("DLT") .And. Len(aDocs) > 0 .And. !Empty(cIdDTW)
                // Monta os dados para montar a DLT
                If IsInCallStack("TMSAF60") .Or. Left(FunName(),7) == "TMSAF90" 
                    cOrigem	:= "2" //-- Viagem em Trânsito
                Else
                    cOrigem	:= "1" //-- Fechamento
                EndIf

                Aadd( aCabDTW, {'DTW_FILORI'	, cFilOri   , Nil})
                Aadd( aCabDTW, {'DTW_VIAGEM'	, cViagem   , Nil}) 
                Aadd( aCabDTW, {'DTW_IDDTW'	    , cIdDTW    , Nil}) 

                For nA := 1 To Len(aDocs)
                    nPStatus := aScan(aDocs[nA], {|x| x[1] == "DT6_STATUS"})
                    nPCliExp := aScan(aDocs[nA], {|x| x[1] == "DT6_CLIEXP"})
                    nPLojExp := aScan(aDocs[nA], {|x| x[1] == "DT6_LOJEXP"})
                    nPCliRem := aScan(aDocs[nA], {|x| x[1] == "DT6_CLIREM"})
                    nPLojRem := aScan(aDocs[nA], {|x| x[1] == "DT6_LOJREM"})
                    nPCliDes := aScan(aDocs[nA], {|x| x[1] == "DT6_CLIDES"})
                    nPLojDes := aScan(aDocs[nA], {|x| x[1] == "DT6_LOJDES"})
                    nPFilDoc := aScan(aDocs[nA], {|x| x[1] == "DT6_FILDOC"})
                    nPDoc    := aScan(aDocs[nA], {|x| x[1] == "DT6_DOC"})
                    nPSerie  := aScan(aDocs[nA], {|x| x[1] == "DT6_SERIE"})
                    If nPStatus > 0 .AND. nPCliExp > 0 .AND. nPLojExp > 0 .AND.; 
                        nPCliRem > 0 .AND. nPLojRem > 0 .AND.; 
                        nPCliDes > 0 .AND. nPLojDes > 0 .AND.; 
                        nPFilDoc > 0 .AND. nPDoc > 0 .AND. nPSerie > 0 .AND.; 
                        aDocs[nA][nPStatus][2] $ "1,6" .AND.; 
                        (cCodCli + cLojCli == aDocs[nA][nPCliRem][2] + aDocs[nA][nPLojRem][2] .OR.; 
                        cCodCli + cLojCli == aDocs[nA][nPCliDes][2] + aDocs[nA][nPLojDes][2] .OR.; 
                        cCodCli + cLojCli == aDocs[nA][nPCliExp][2] + aDocs[nA][nPLojExp][2]) //Documento em aberto
                        If aDocs[nA][nPSerie][2] == "COL"
                            cOpeDoc	:= "3" // Coleta
                        ElseIf cCodCli + cLojCli == aDocs[nA][nPCliRem][2] + aDocs[nA][nPLojRem][2] .OR. cCodCli + cLojCli == aDocs[nA][nPCliExp][2] + aDocs[nA][nPLojExp][2]
                            cOpeDoc	:= "2" // Emissão
                        Else
                            cOpeDoc	:= "1" // Entrega
                        EndIf 
                        
                        Tmsa351DLT(aCabDTW, 4, cFilOri , cViagem, cIdDTW, aDocs[nA][nPFilDoc][2], aDocs[nA][nPDoc][2], aDocs[nA][nPSerie][2], cOrigem, cOpeDoc)
                        
                    EndIf
                Next nAux
                aSize(aCabDTW,0)
                lcriaDLT := .F.
            EndIf
        EndIf
    Else
        While (cAliasNew)->(!Eof())

            //-- Nao gera operacoes de "Carregamento" nas "Viagens de Socorro"
            //-- pois o carregamento ja ocorreu na viagem original.
            If DTQ->DTQ_TIPVIA == "4" .And. (cServEnt == cServic .Or. !lGeraCar)
                (cAliasNew)->(dbSkip())
                Loop
            EndIf
            
            cHoraPre := Time()
            cAtivOld := ""
            
            // Viagem criada pelo painel, chama a rotina de carregamento duas vezes
            // Verifica se as operações desta Tarefa x Atividade já foram criadas
            IF IsInCallStack("TMSF76Via") .And. IsInCallStack("TMSF76Crg")
                DTW->(dbSetOrder(2))  // DTW_FILIAL + DTW_SERTMS + DTW_TIPTRA + DTW_FILORI + DTW_VIAGEM + DTW_SEQUEN
                If DTW->(MsSeek(xFilial('DTW') + cSerTms + cTipTra + cFilOri +  cViagem ))
                    (cAliasNew)->(dbSkip())
                    Loop
                EndIf
            Endif
                
            //-- Calcula a data e hora prevista
            SomaDiaHor( @dDataPre, @cHoraPre, TmsHrToInt(DC6->DC6_DURAC) )
            //-- Verificando se a sequencia obtida pode ser utilizada sem duplicidade.
            cSequen := Soma1(cSequen)
            DTW->(dbSetOrder(1))
            DTW->(MsSeek(xFilial('DTW')+cFilOri + cViagem +cSequen))
            If Empty(aSequen)
                If( cSequen == DTW->DTW_SEQUEN )					//-- Monta o array aSequen com sequencia inicial
                    While ( DTW->DTW_VIAGEM == M->DTA_VIAGEM )
                        Aadd( aSequen, { Soma1(DTW->DTW_SEQUEN)	, DTW->(RECNO()) } )
                        DTW->(DbSkip())
                    EndDo
                    nContr++
                EndIf
            Else
                For nA := 1 To Len(aSequen)								//-- Adciona no array aSequen a quantidade de ocorrências
                    aSequen[nContr][1] := Soma1(aSequen[nContr][1])	//-- que foram incluidas para que elas sejam incluidas 
                    DTW->(DbSkip())										//-- entre as ocorrências que já existiam.
                    nContr++
                Next nA
                nContr := 1
            EndIf

            If cAtivOld != (cAliasNew)->DC6_ATIVID	
                cAtivOld := (cAliasNew)->DC6_ATIVID	
                //-- Gravando DTW
                aCab := {}
                Aadd( aCab, { 'DTW_FILORI'	, cFilOri										, Nil } )
                Aadd( aCab, { 'DTW_VIAGEM'	, cViagem										, Nil } )
                Aadd( aCab, { 'DTW_SEQUEN'	, PADL(cSequen,TAMSX3("DTW_SEQUEN")[1],"0"), Nil } )
                Aadd( aCab, { 'DTW_DATPRE'	, dDataPre									, Nil } )
                Aadd( aCab, { 'DTW_HORPRE'	, StrTran(Left(cHoraPre,5),':','')			, Nil } )
                Aadd( aCab, { 'DTW_SERVIC'	, (cAliasNew)->DC5_SERVIC					, Nil } )
                Aadd( aCab, { 'DTW_TAREFA'	, (cAliasNew)->DC5_TAREFA					, Nil } )
                Aadd( aCab, { 'DTW_ATIVID'	, (cAliasNew)->DC6_ATIVID					, Nil } )
                Aadd( aCab, { 'DTW_SERTMS'	, cSerTms									, Nil } )
                Aadd( aCab, { 'DTW_TIPTRA'	, cTipTra									, Nil } )
                Aadd( aCab, { 'DTW_TIPOPE'	, StrZero(1,TAMSX3("DTW_STATUS")[1])		, Nil } ) // Tipo de Operacao == "Carregamento"
                
                If (cAliasNew)->DC6_ATIVID $ cAtvChgCli .And. lRemet .AND. cSerie <> "COL"

                    Aadd( aCab, { 'DTW_DATINI'	, dDataBase			, Nil } )
                    Aadd( aCab, { 'DTW_HORINI'	, StrTran(Left(Time(),5),':','')	, Nil } )
                    Aadd( aCab, { 'DTW_DATREA'	, dDataBase			, Nil } )
                    Aadd( aCab, { 'DTW_HORREA'	, StrTran(Left(Time(),5),':','')	, Nil } )
                    Aadd( aCab, { 'DTW_STATUS'	, StrZero(2,Len(DTW->DTW_STATUS))	, Nil } ) //-- 2 = Encerrada
                        
                    If DTW->(ColumnPos("DTW_SYSDAT")) > 0 .And. DTW->(ColumnPos("DTW_SYSHOR")) > 0
                        AAdd(aCab, {'DTW_SYSDAT', dDataBase})
                        AAdd(aCab, {'DTW_SYSHOR', StrTran(Time(), ":", "")})
                    EndIf

                Else
                    Aadd( aCab, { 'DTW_DATREA'	, Ctod('')							, Nil } )
                    Aadd( aCab, { 'DTW_HORREA'	, ''										, Nil } )
                    Aadd( aCab, { 'DTW_STATUS'	, StrZero(1,TAMSX3("DTW_STATUS")[1])		, Nil } )
                EndIf
                
                If lIdDTW 
                    cIdDTW := Tm351IdDTW( cFilOri , cViagem 	)
                    Aadd( aCab, { 'DTW_IDDTW'	, cIdDTW																		, Nil } )
                EndIf

                If (cAliasNew)->DC6_ATIVID $ (cAtvSaiCli + "," + cAtvChgCli)
                    
                    Aadd( aCab, { 'DTW_CODCLI'	, cCodCli						, Nil } )
                    Aadd( aCab, { 'DTW_LOJCLI'	, cLojCli						, Nil } )

                    If lUFAtiv
                        DUY->( dbSetOrder(1) )
                        If DUY->(MsSeek(xFilial("DUY")+ Iif(lRemet,DT6->DT6_CDRORI,DT6->DT6_CDRCAL) ))   
                            Aadd( aCab, { 'DTW_UFATIV'	, DUY->DUY_EST						, Nil } )
                        EndIf
                    EndIf

                    If (cAliasNew)->DC6_ATIVID == cAtvChgCli .And. AliasInDic("DLT")
                        lcriaDLT := .T.
                    EndIF 

                EndIf

                //--Cria a DTW
                lRet := TMSCriaDTW( aCab )

                If lRet .And. lcriaDLT .AND. Len(aDocs) > 0
                    // Monta os dados para montar a DLT
                    If IsInCallStack("TMSAF60") .Or. Left(FunName(),7) == "TMSAF90" 
                        cOrigem	:= "2" //-- Viagem em Trânsito
                    Else
                        cOrigem	:= "1" //-- Fechamento
                    EndIf
                    
                    Aadd( aCabDTW, { 'DTW_FILORI'	, DTQ->DTQ_FILORI	, Nil } )
                    Aadd( aCabDTW, { 'DTW_VIAGEM'	, DTQ->DTQ_VIAGEM	, Nil } ) 
                    Aadd( aCabDTW, { 'DTW_IDDTW'	, cIdDTW					, Nil } ) 

                    For nA := 1 To Len(aDocs)
                        nPStatus := aScan(aDocs[nA], {|x| x[1] == "DT6_STATUS"})
                        nPCliExp := aScan(aDocs[nA], {|x| x[1] == "DT6_CLIEXP"})
                        nPLojExp := aScan(aDocs[nA], {|x| x[1] == "DT6_LOJEXP"})
                        nPCliRem := aScan(aDocs[nA], {|x| x[1] == "DT6_CLIREM"})
                        nPLojRem := aScan(aDocs[nA], {|x| x[1] == "DT6_LOJREM"})
                        nPCliDes := aScan(aDocs[nA], {|x| x[1] == "DT6_CLIDES"})
                        nPLojDes := aScan(aDocs[nA], {|x| x[1] == "DT6_LOJDES"})
                        nPFilDoc := aScan(aDocs[nA], {|x| x[1] == "DT6_FILDOC"})
                        nPDoc    := aScan(aDocs[nA], {|x| x[1] == "DT6_DOC"})
                        nPSerie  := aScan(aDocs[nA], {|x| x[1] == "DT6_SERIE"})
                        If nPStatus > 0 .AND. nPCliExp > 0 .AND. nPLojExp > 0 .AND.; 
                            nPCliRem > 0 .AND. nPLojRem > 0 .AND.; 
                            nPCliDes > 0 .AND. nPLojDes > 0 .AND.; 
                            nPFilDoc > 0 .AND. nPDoc > 0 .AND. nPSerie > 0 .AND.; 
                            aDocs[nA][nPStatus][2] $ "1,6" .AND.; 
                            (cCodCli + cLojCli == aDocs[nA][nPCliRem][2] + aDocs[nA][nPLojRem][2] .OR.; 
                            cCodCli + cLojCli == aDocs[nA][nPCliDes][2] + aDocs[nA][nPLojDes][2] .OR.; 
                            cCodCli + cLojCli == aDocs[nA][nPCliExp][2] + aDocs[nA][nPLojExp][2]) //Documento em aberto
                            If aDocs[nA][nPSerie][2] == "COL"
                                cOpeDoc	:= "3" // Coleta
                            ElseIf cCodCli + cLojCli == aDocs[nA][nPCliRem][2] + aDocs[nA][nPLojRem][2] .OR. cCodCli + cLojCli == aDocs[nA][nPCliExp][2] + aDocs[nA][nPLojExp][2]
                                cOpeDoc	:= "2" // Emissão
                            Else
                                cOpeDoc	:= "1" // Entrega
                            EndIf 
                            
                            Tmsa351DLT(aCabDTW, 4, cFilOri , cViagem, cIdDTW, aDocs[nA][nPFilDoc][2], aDocs[nA][nPDoc][2], aDocs[nA][nPSerie][2], cOrigem, cOpeDoc)
                            
                        EndIf
                    Next nAux
                    aSize(aCabDTW,0)
                    lcriaDLT := .F.
                EndIf 
            EndIf

            //-- Grava nas ocorrências exixtentes da DTW a nova sequencia.
            For nA := 1 To Len(aSequen)
                DbSelectArea ("DTW")
                DbGoTo(aSequen[nA][2])
                RecLock("DTW", .F.)
                DTW->DTW_SEQUEN := aSequen[nA][1]
                MsUnLock()
            Next nA
                
            (cAliasNew)->(dbSkip())
        EndDo

        (cAliasNew)->(dbCloseArea())

    EndIf

    oDadosViag := Nil
    FreeObj(oDadosViag)
    aSize(aDocs, 0)
	aDocs := Nil

EndIf

//--Verifica o ID da DTW do Cliente destinatário caso já exista e seja inclusão de novo documento na viagem em trânsito para gravar o ponto de entrega da DLT.
If AliasInDic("DLT") .And. DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))
	
	cAliasDTW := GetNextAlias()
	cQueryDTW := 	"SELECT DTW.DTW_IDDTW "
	cQueryDTW += 	"FROM " + RetSqlName("DTW") + " DTW "
	cQueryDTW += 	"WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
	cQueryDTW += 	"AND DTW.DTW_FILORI = '" + cFilOri + "' "
	cQueryDTW += 	"AND DTW.DTW_VIAGEM = '" + cViagem + "' "
	cQueryDTW += 	"AND DTW.DTW_ATIVID = '" + cAtvChgCli + "' "
	cQueryDTW += 	"AND DTW.DTW_CODCLI = '" + cCodCli + "' "
	cQueryDTW += 	"AND DTW.DTW_LOJCLI = '" + cLojCli + "' "
	cQueryDTW += 	"AND DTW.DTW_STATUS = '1' "
	cQueryDTW += 	"AND DTW.D_E_L_E_T_ = ' ' "
	cQueryDTW := ChangeQuery(cQueryDTW)
	cAliasDTW := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQueryDTW),cAliasDTW,.F.,.T.)

	DLT->(DbSetOrder(1))
	If !DLT->(MsSeek(xFilial("DLT") + cFilOri + cViagem+ (cAliasDTW)->DTW_IDDTW + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE )) 
		DTW->(DbSetOrder(9))
		If DTW->(MsSeek(xFilial("DTW") + cFilOri + cViagem + (cAliasDTW)->DTW_IDDTW )) 
			Aadd( aCabDTW, { 'DTW_FILORI'	, cFilOri		, Nil } )
			Aadd( aCabDTW, { 'DTW_VIAGEM'	, cViagem		, Nil } ) 
			Aadd( aCabDTW, { 'DTW_IDDTW'	, (cAliasDTW)->DTW_IDDTW	, Nil } ) 

			Tmsa351DLT(aCabDTW, 4, cFilOri, cViagem, (cAliasDTW)->DTW_IDDTW , DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, "2", "1") // Entrega
			(cAliasDTW)->(dbSkip())	
			//--Limpa o Array
			aSize(aCabDTW,0)
		EndIf  
	EndIf 

	(cAliasDTW)->( dbCloseArea() )

EndIf 

					
RestArea(aArea)
Return


//--------------------------------------------------------------------------
/*/{Protheus.doc} TF90VldDTW
Realiza validações para verificar se será permitido o apontamento
@type function
@author Caio Murakami
@version 12
@param  
@since 27/03/2019
@return lRet True ou False
Função extraida do fonte TMSA210.PRW (A210VldDTW())
/*/
//---------------------------------------------------------------------------
Static Function TF90VldDTW( cFilOri , cViagem , cCodCli , cLojCli , lRemet )
Local lRet			:= .T. 
Local aAreaDTW		:= DTW->(GetArea())
Local aArea			:= GetArea()
Local cAtvSaiCli	:= SuperGetMv('MV_ATVSAIC',,'')//-- Atividade de Saída do cliente
Local cAtvChgCli	:= SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada em Cliente
Local cQuery		:= ""
Local cAliasQry		:= GetNextAlias()
Local nContChg		:= 0
Local nContSai		:= 0

Default cFilOri		:= ""
Default cViagem		:= ""
Default cCodCli		:= ""
Default cLojCli		:= ""
Default lRemet		:= .F. 

cQuery	:= " SELECT DTW_ATIVID , COUNT(*) CONTADOR "
cQuery	+= " FROM " + RetSQLName("DTW") + " DTW "
cQuery	+= " WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
cQuery	+= " 	AND DTW_FILORI	= '" + cFilOri + "' "
cQuery	+= " 	AND DTW_VIAGEM 	= '" + cViagem + "' "
cQuery	+= "	AND DTW_CODCLI	= '" + cCodCli + "' "
cQuery	+= "	AND DTW_LOJCLI  = '" + cLojCli + "' "
cQuery	+= " 	AND DTW_ATIVID	IN ('" + cAtvChgCli + "' , '" + cAtvSaiCli + "'  ) " 
cQuery	+= "	AND DTW_STATUS = '2' "
cQuery	+= "	AND DTW_DATREA <> '' "
cQuery 	+= " 	AND DTW.D_E_L_E_T_ = '' "
cQuery	+= " 	GROUP BY DTW_ATIVID "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

While (cAliasQry)->( !Eof() )
	
	If (cAliasQry)->DTW_ATIVID == cAtvChgCli
		nContChg += (cAliasQry)->CONTADOR  
	ElseIf (cAliasQry)->DTW_ATIVID == cAtvSaiCli
		nContSai +=  (cAliasQry)->CONTADOR  
	EndIf
	
	(cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->( dbCloseArea() )

If nContSai <> nContChg 
	lRet	:= .F. 
EndIf

RestArea(aAreaDTW)
RestArea(aArea)
Return lRet

/*{Protheus.doc} TF90Doctos
Botão que aciona tela para seleção múltipla de documentos
@type Static Function
@author Valdemar Roberto Mognon
@since 23/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF90Doctos(oPanel)
Local oTBitmap1	:= Nil 

oTBitmap1 := TBitmap():New(20,03,260,184,,"BMPVISUAL",.T.,oPanel,{|| TF90LstDoc()},,.F.,.F.,,,.F.,,.T.,,.F.)
oTBitmap1:lAutoSize := .T.

Return NIL

/*{Protheus.doc} TF90CodBar
Botão que aciona tela para seleção de documentos por código de barras
@type Static Function
@author Valdemar Roberto Mognon
@since 23/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF90CodBar(oPanel)
Local oTBitmap1	:= Nil 

oTBitmap1 := TBitmap():New(35,03,260,184,,"MDIRUN",.T.,oPanel,{|| TF90BipCod()},,.F.,.F.,,,.F.,,.T.,,.F.)
oTBitmap1:lAutoSize := .T.

Return Nil

/*{Protheus.doc} GravaDUD
Valida o se o estorno do carregamento não tem manifesto gerado.
@type Static Function
@author Fabio Marchiori Sampaio
@since 07/07/2021
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TMF90VldDUD(oModel)
Local lRet       := .T.
Local nCntFor1   := 0
Local nCntFor2   := 0
Local aAreas     := {DUD->(GetArea()),GetArea()}
Local oMdlGrdDM7
Local oMdlGrdDTA
Local nOperation := oModel:GetOperation()

Default oModel     := FWModelActive()

If (nOperation == 5) //Validar o Estorno do Carregamento

	oMdlGrdDM7 := oModel:GetModel("MdGridDM7")
	oMdlGrdDTA := oModel:GetModel("MdGridDTA")

	For nCntFor1 := 1 To oMdlGrdDM7:Length()
		oMdlGrdDM7:GoLine(nCntFor1)
		
		For nCntFor2 := 1 To oMdlGrdDTA:Length()
			oMdlGrdDTA:GoLine(nCntFor2)

			DUD->(DbSetOrder(1))
			If DUD->(DbSeek(xFilial("DUD") + FwFldGet("DTA_FILDOC") + FwFldGet("DTA_DOC") + FwFldGet("DTA_SERIE") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM")))
				If Empty(DUD->DUD_MANIFE) 
					lRet := .T.			
				Else
					Help("", 1, "TMSA21008",,DUD->DUD_FILDOC+' '+DUD->DUD_DOC+' '+DUD->DUD_SERIE,3,1) // "Documento ja manifestado, nao e permitido efetuar o estorno."
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nCntFor2

	Next nCntFor1

	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

EndIf

Return lRet
