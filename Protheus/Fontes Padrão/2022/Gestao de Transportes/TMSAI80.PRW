#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAI80.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSAI80
Configuração das Integrações
@type Function
@author Valdemar Roberto Mognon
@since 23/02/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI80()
(examples)
@see (links_or_references)
*/
Function TMSAI80()
Local oBrowse := Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DN0")
oBrowse:SetMenuDef("TMSAI80")
oBrowse:SetDescription(STR0001)	//-- Configuração das Integrações
oBrowse:Activate()

Return

/*{Protheus.doc} MenuDef
    Definição do aRotina (Menu funcional)
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 23/02/2022
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example MenuDef()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0	//-- Pesquisar
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAI80" OPERATION 2 ACCESS 0	//-- Visualizar
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSAI80" OPERATION 3 ACCESS 0	//-- Incluir
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAI80" OPERATION 4 ACCESS 0	//-- Alterar
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSAI80" OPERATION 5 ACCESS 0	//-- Excluir

Return (aRotina)

/*{Protheus.doc} ModelDef
Definição do Modelo
@type Static Function
@author Valdemar Roberto Mognon
@since 23/02/2022
@version P12 R12.1.20
@param param, param_type, param_descr
@return return, return_type, return_description
@example ModelDef()
(examples)
@see (links_or_references)
*/

Static Function ModelDef()
Local oModel	:= Nil
Local oStruDN0	:= FwFormStruct(1,"DN0")
Local oStruDLZ	:= FwFormStruct(1,"DLZ")
Local oStruDN1	:= FwFormStruct(1,"DN1")
Local oStruDND	:= Nil
Local lDND		:= AliasInDic("DND")

If lDND
	oStruDND := FwFormStruct(1,"DND")
EndIf

oModel := MpFormModel():New("TMSAI80", /*bPreValidacao*/, /*bPreValidacao*/, /*bCommit*/ , /*bCancel*/ )
oModel:SetDescription(STR0001)	//-- Configuração das Integrações

//-- Cabeçalho
oModel:AddFields("MdFieldDN0",,oStruDN0,,,)
oModel:SetPrimaryKey({"DN0_CODIGO"})
oModel:GetModel("MdFieldDN0"):SetDescription(STR0001)	//-- Configuração das Integrações

//-- Itens
//-- CheckList
oModel:AddGrid("MdGridDLZ","MdFieldDN0",oStruDLZ,,,, {|oMdl| TMSAI80Vld(oMdl) } )
oModel:SetRelation("MdGridDLZ",{{"DLZ_FILIAL","xFilial('DLZ')"},;
								{"DLZ_CODCON","DN0_CODIGO"}},;
								DLZ->(IndexKey(4)))
oModel:GetModel("MdGridDLZ"):SetDescription(STR0007)	//-- CheckList
oModel:GetModel("MdGridDLZ"):SetUniqueLine({"DLZ_SEQUEN"})
oModel:GetModel('MdGridDLZ'):SetOptional(.T.)

//-- Coleta/Entrega
oModel:AddGrid("MdGridDN1","MdFieldDN0",oStruDN1,,,, {|oMdl| TMSAI80Vld(oMdl) } )
oModel:SetRelation("MdGridDN1",{{"DN1_FILIAL","xFilial('DN1')"},;
								{"DN1_CODCON","DN0_CODIGO"}},;
								DN1->(IndexKey(1)))
oModel:GetModel("MdGridDN1"):SetDescription(STR0008)	//-- Coleta/Entrega
oModel:GetModel("MdGridDN1"):SetUniqueLine({"DN1_SEQUEN"})
oModel:GetModel('MdGridDN1'):SetOptional(.T.)

If lDND
	//-- Portal Logistico
	oModel:AddGrid( "MdGridDND", "MdFieldDN0", oStruDND, , , , { |oMdl| TMSAI80Vld(oMdl) } )
	oModel:SetRelation("MdGridDND", {	{ "DND_FILIAL", "xFilial('DND')"},;
										{ "DND_CODCON", "DN0_CODIGO"	} },;
									DND->( IndexKey(1) ) )
	oModel:GetModel("MdGridDND"):SetDescription(STR0023)	//-- Portal Logistico
	oModel:GetModel("MdGridDND"):SetUniqueLine({"DND_SEQUEN"})
	oModel:GetModel('MdGridDND'):SetOptional(.T.)
EndIf

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@type Static Function
@author Valdemar Roberto Mognon
@since 23/02/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example ViewDef()
(examples)
@see (links_or_references)
*/

Static Function ViewDef()
Local oModel	:= FwLoadModel("TMSAI80")
Local oStruDN0	:= FwFormStruct(2,"DN0")
Local oStruDLZ	:= FwFormStruct(2,"DLZ")
Local oStruDN1	:= FwFormStruct(2,"DN1")
Local oView		:= Nil
Local oStruDND	:= Nil
Local lDND		:= AliasInDic("DND")

If lDND
	oStruDND := FwFormStruct(2,"DND")
EndIf

oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define o tamanho da tela principal
oView:CreateHorizontalBox("Cabecalho",025)
oView:CreateHorizontalBox("Itens"    ,075)

//-- Cria área da tabela pai
oView:AddField("VwFieldDN0",oStruDN0,"MdFieldDN0") 
oView:EnableTitleView("VwFieldDN0",STR0001)	//-- Configuração das Integrações
oView:SetOwnerView("VwFieldDN0","Cabecalho")

//-- Cria o Folder dos Itens
oView:CreateFolder("Folder1","Itens")

//-- Cria Abas do Folder dos Itens
oView:AddSheet("Folder1","Sheet1_Folder1",STR0007)	//-- CheckList
oView:AddSheet("Folder1","Sheet2_Folder1",STR0008)	//-- Coleta/Entrega

If lDND
	oView:AddSheet("Folder1","Sheet3_Folder1",STR0023)	//-- Coleta/Entrega
EndIf

//-- Define os Boxes das Abas do Folder dos Itens
oView:CreateHorizontalBox("BoxItensDLZ",100,,,"Folder1","Sheet1_Folder1")
oView:CreateHorizontalBox("BoxItensDN1",100,,,"Folder1","Sheet2_Folder1")

If lDND
	oView:CreateHorizontalBox("BoxItensDND",100,,,"Folder1","Sheet3_Folder1")
EndIf

//-- Cria área das tabelas filhas
//-- CheckList
oView:AddGrid("VwGridDLZ",oStruDLZ,"MdGridDLZ")
oView:EnableTitleView("VwGridDLZ",STR0007)	//-- CheckList
oView:SetOwnerView("VwGridDLZ","BoxItensDLZ")
oView:AddIncrementField("VwGridDLZ","DLZ_SEQUEN")

//-- Coleta/Entrega
oView:AddGrid("VwGridDN1",oStruDN1,"MdGridDN1")
oView:EnableTitleView("VwGridDN1",STR0008)	//-- Coleta/Entrega
oView:SetOwnerView("VwGridDN1","BoxItensDN1")
oView:AddIncrementField("VwGridDN1","DN1_SEQUEN")

If lDND
	//-- Portal Logistica
	oView:AddGrid( "VwGridDND", oStruDND, "MdGridDND" )
	oView:EnableTitleView( "VwGridDND", STR0023 )	//-- Coleta/Entrega
	oView:SetOwnerView( "VwGridDND", "BoxItensDND" )
	oView:AddIncrementField( "VwGridDND", "DND_SEQUEN" )
EndIf

oView:AddUserButton( STR0009, "", { |oView| TMSAI80BTo(oView) }, , , { MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE } )	//-- Teste Token

Return oView

/*{Protheus.doc} TMSAI80BTo
Definição do Botão do Teste do Token
@type Static Function
@author Valdemar Roberto Mognon
@since 24/02/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI80BTo()
(examples)
@see (links_or_references)
*/
Static Function TMSAI80BTo(oView)
Local aResult := {}
Local cAlias  := ""
Local oToken, oModel
Local cClientID,cSecret,cACRval,cUserName,cPass,cUrlToke

DEFAULT oView := FWViewActive()

	cAlias := SubStr(oView:GetCurrentSelect()[1],7,3)

	If cAlias $ "DLZ:DN1:DND"

		oModel := oView:GetModel("MdGrid"+cAlias)

		cClientID := AllTrim( oModel:GetValue( cAlias + "_ID"		) )
		cSecret   := AllTrim( oModel:GetValue( cAlias + "_SECRET"	) )
		cACRval   := AllTrim( oModel:GetValue( cAlias + "_TENANT"	) )
		cUserName := AllTrim( oModel:GetValue( cAlias + "_USER"		) )
		cPass     := AllTrim( oModel:GetValue( cAlias + "_PASSW"	) )
		cUrlToke  := AllTrim( oModel:GetValue( cAlias + "_URLTOK"	) )

		oToken := TMSBCACOLENT():New(cAlias)
		Processa({|lEnd| aResult := oToken:GetToken(cClientID,cSecret,cACRval,cUserName,cPass,cUrlToke,.F.) },,STR0010,.T.)	//-- Processando...

		If aResult[1]		
			MsgInfo(STR0011 + SubStr(aResult[2],1,50),STR0012)	//-- Resultado
		Else
			MsgStop(oToken:last_error + CRLF + oToken:desc_error,STR0012)	//-- Resultado
		EndIf

	EndIf

Return

/*{Protheus.doc} TMSAI80VlA
Valida ativação de configuração.
Não pode haver mais de uma configuração ativa para o mesmo módulo (por filial no caso de exclusivo)
@author Carlos A. Gomes Jr.
@since 18/03/2022
*/
Function TMSAI80VlA()
Local aAreas  := { GetArea("DN0"), GetArea() }
Local lRet    := .T.

	If M->DN0_ATIVO == "1"
		DN0->(DbSetOrder(2))
		If DN0->(MsSeek(xFilial("DN0")+StrZero(M->DN0_CODMOD,TamSX3("DN0_CODMOD")[1])+"1")) .And. M->DN0_CODIGO != DN0->DN0_CODIGO
			Help( '', 1, "TMSAI8001", , STR0014, 1,,,,,,, {STR0015 + DN0->DN0_CODIGO + STR0016} )	//-- "Não pode haver mais de uma configuração ativa para o mesmo módulo." # "Desative a configuração: " # " antes de continuar."
			lRet := .F.
		EndIf
	EndIf
	
	AEval( aAreas, {|aArea| RestArea(aArea) } )

Return lRet

/*{Protheus.doc} TMSAI80Vld()
Validação 
@author Carlos A. Gomes Jr.
@since 18/03/2022
*/
Function TMSAI80Vld(oModel)
Local nLin       := 0
Local lRet       := .T.
Local nQtdAtivo  := 0
Local cFolder    := ""

	If oModel:cID == "MdGridDLZ"
		cAlias  := "DLZ"
		cFolder := STR0017	//-- "Checklist"
	ElseIf oModel:cID == "MdGridDN1"
		cAlias  := "DN1"
		cFolder := STR0018	//-- "Coleta/Entrega"
	ElseIf oModel:cID == "MdGridDND"
		cAlias  := "DND"
		cFolder := STR0023	//-- "Coleta/Entrega"
	EndIf

	For nLin := 1 To oModel:Length()
		oModel:GoLine(nLin)
		If !oModel:IsDeleted()
			If oModel:GetValue(cAlias+"_MSBLQL") == "2"
				nQtdAtivo++
			EndIf
		EndIf
		If nQtdAtivo > 1
			Help( '', 1, "TMSAI8002", , STR0019, 1,,,,,,, {STR0020 + cFolder + STR0021 + oModel:GetValue(cAlias+"_SEQUEN")  + STR0022} )	//-- "Não pode haver mais de uma seuquencia não bloqueada." # "Na Pasta " # " ative o bloqueio da sequencia: " # " para continuar."
			lRet := .F.
			Exit
		EndIf
	Next


Return lRet

/*{Protheus.doc} TMSAI80Val
Valida campos
@type Static Function
@author Valdemar Roberto Mognon
@since 03/05/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI80Val()
(examples)
@see (links_or_references)
*/
Function TMSAI80Val(cCampo)
Local lRet     := .T.
Local cContVar := ""
Default cCampo := ReadVar()

	If !Vazio() .And. cCampo $ "M->DN1_OCOENT:M->DN1_OCNFEC:M->DN1_OCNAVA:M->DN1_OCNFAL:M->DN1_OCNREC:M->DN1_OCNOUT:M->DN1_OCOCOL:M->DN1_OCNCOL"
		DT2->(DbSetOrder(1))
		cContVar := &(cCampo)
		If DT2->(MsSeek(xFilial("DT2")+cContVar))
			If DT2->DT2_ATIVO == StrZero(2,Len(DT2->DT2_ATIVO))
				Help("",1,"TMSAI8001")	//-- A ocorrência deve estar ativa.
				lRet := .F.
			ElseIf DT2->DT2_CATOCO == StrZero(2,Len(DT2->DT2_CATOCO))
				Help("",1,"TMSAI8003")	//-- A ocorrência deve ser da categoria por viagem.
				lRet := .F.
			ElseIf DT2->DT2_SERTMS == StrZero(2,Len(DT2->DT2_SERTMS))
				Help("",1,"TMSAI8010")	//-- Somente são aceitas ocorrências de coleta ou de entrega.
				lRet := .F.
			ElseIf !Empty(DT2->DT2_SERTMS) .And. (DT2->DT2_SERTMS == StrZero(1,Len(DT2->DT2_SERTMS)) .Or. DT2->DT2_SERTMS == StrZero(3,Len(DT2->DT2_SERTMS)))
				If cCampo $ "M->DN1_OCOCOL:M->DN1_OCNCOL"
					If DT2->DT2_SERTMS == StrZero(3,Len(DT2->DT2_SERTMS))
						Help("",1,"TMSAI8009")	//-- A ocorrência deve ser de coleta.
						lRet := .F.
					EndIf
				ElseIf DT2->DT2_SERTMS == StrZero(1,Len(DT2->DT2_SERTMS))
					Help("",1,"TMSAI8002")	//-- A ocorrência deve ser de entrega.
					lRet := .F.
				EndIf
			EndIf
			
			If lRet
				If cCampo $ "M->DN1_OCOENT:M->DN1_OCOCOL" .And. DT2->DT2_TIPOCO != StrZero(1,Len(DT2->DT2_TIPOCO))
					Help("",1,"TMSAI8004")	//-- A ocorrência deve ser do tipo que encerra processo.
					lRet := .F.
				ElseIf cCampo $ "M->DN1_OCNFEC:M->DN1_OCNOUT:M->DN1_OCNCOL" .And. DT2->DT2_TIPOCO != StrZero(4,Len(DT2->DT2_TIPOCO))
					Help("",1,"TMSAI8005")	//-- A ocorrência deve ser do tipo que retorna documento.
					lRet := .F.
				ElseIf cCampo $ "M->DN1_OCNAVA:M->DN1_OCNFAL:M->DN1_OCNREC"
					If DT2->DT2_TIPOCO != StrZero(6,Len(DT2->DT2_TIPOCO))
						Help("",1,"TMSAI8011")	//-- A ocorrência deve ser do tipo gera pendência.
						lRet := .F.
					ElseIf cCampo $ "M->DN1_OCNFAL" .And. DT2->DT2_TIPPND != StrZero(1,Len(DT2->DT2_TIPPND))
						Help("",1,"TMSAI8006")	//-- A ocorrência deve ser do tipo que gera pendência com tipo de pendência igual a "falta".
						lRet := .F.
					ElseIf cCampo $ "M->DN1_OCNAVA" .And. DT2->DT2_TIPPND != StrZero(2,Len(DT2->DT2_TIPPND))
						Help("",1,"TMSAI8007")	//-- A ocorrência deve ser do tipo que gera pendência e com tipo de pendência igual a avaria.
						lRet := .F.
					ElseIf cCampo $ "M->DN1_OCNREC" .And. DT2->DT2_TIPPND != StrZero(4,Len(DT2->DT2_TIPPND))
						Help("",1,"TMSAI8008")	//-- A ocorrência deve ser do tipo que gera pendência e com tipo de pendência igual a "retorno ao cliente".
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet
