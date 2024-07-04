#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA984A.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA984A
@description	Facilitador
@sample	 		TECA984A()
@author			Kaique Schiller
@since			30/06/2022
/*/
//------------------------------------------------------------------------------
Function TECA984A()
Local oMBrowse := FWmBrowse():New()

oMBrowse:SetAlias("TXR")
oMBrowse:SetDescription(STR0001)	// "Facilitador"
oMBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@description	Define o menu funcional.
@sample	 		MenuDef()
@return			Opções da Rotina.
@author			Kaique Schiller
@since			30/06/2022
/*/

//------------------------------------------------------------------------------
Static Function MenuDef(aRotina)
Default	aRotina	:= {}

ADD OPTION aRotina TITLE STR0002  ACTION "PesqBrw"          OPERATION 1                      ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TECA984A" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TECA984A" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TECA984A" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TECA984A" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // "Excluir"
ADD OPTION aRotina TITLE STR0007  ACTION "VIEWDEF.TECA984A" OPERATION 9                      ACCESS 0 // "Copiar"

Return(aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description	Definição do Model
@sample	 		ModelDef()
@author			Kaique Schiller
@since			30/06/2022
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oStrTXR	:= FWFormStruct( 1, "TXR")
Local oStrTXS 	:= FWFormStruct( 1, "TXS")
Local oStrTXT 	:= FWFormStruct( 1, "TXT")
Local oStrTXU 	:= FWFormStruct( 1, "TXU")
Local oStrTXV 	:= FWFormStruct( 1, "TXV")
Local oStrTXW 	:= FWFormStruct( 1, "TXW")
Local oModel
Local xAux

xAux := FwStruTrigger( 'TXR_CODAA0', 'TXR_DSCAA0', 'Posicione("AA0",1,xFilial("AA0")+FwFldGet("TXR_CODAA0"),"AA0_DESCRI")', .F. )
	oStrTXR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_CODPRD', 'TXS_DESCRI', 'Posicione("SB1",1,xFilial("SB1")+FwFldGet("TXS_CODPRD"),"B1_DESC")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_FUNCAO', 'TXS_DESFUN', 'Posicione("SRJ",1,xFilial("SRJ")+FwFldGet("TXS_FUNCAO"),"RJ_DESC")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_TURNO', 'TXS_DESTUR', 'Posicione("SR6",1,xFilial("SR6")+FwFldGet("TXS_TURNO"),"R6_DESC")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_ESCALA', 'TXS_DSCESC', 'Posicione("TDW",1,xFilial("TDW")+FwFldGet("TXS_ESCALA"),"TDW_DESC")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_CARGO', 'TXS_DSCCAR', 'Posicione("SQ3",1,xFilial("SQ3")+FwFldGet("TXS_CARGO"),"Q3_DESCSUM")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_QUANTS', 'TXS_TOTRH', 'FwFldGet("TXS_QUANTS")*FwFldGet("TXS_VLUNIT")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_VLUNIT', 'TXS_TOTRH', 'FwFldGet("TXS_QUANTS")*FwFldGet("TXS_VLUNIT")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXR_TOTRH', 'TXR_TOTGER', 'FwFldGet("TXR_TOTRH")+FwFldGet("TXR_TOTMI")+FwFldGet("TXR_TOTMC")+FwFldGet("TXR_TOTUNI")+FwFldGet("TXR_TOTARM")', .F. )
	oStrTXR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXR_TOTMI', 'TXR_TOTGER', 'FwFldGet("TXR_TOTRH")+FwFldGet("TXR_TOTMI")+FwFldGet("TXR_TOTMC")+FwFldGet("TXR_TOTUNI")+FwFldGet("TXR_TOTARM")', .F. )
	oStrTXR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXR_TOTMC', 'TXR_TOTGER', 'FwFldGet("TXR_TOTRH")+FwFldGet("TXR_TOTMI")+FwFldGet("TXR_TOTMC")+FwFldGet("TXR_TOTUNI")+FwFldGet("TXR_TOTARM")', .F. )
	oStrTXR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXR_TOTUNI', 'TXR_TOTGER', 'FwFldGet("TXR_TOTRH")+FwFldGet("TXR_TOTMI")+FwFldGet("TXR_TOTMC")+FwFldGet("TXR_TOTUNI")+FwFldGet("TXR_TOTARM")', .F. )
	oStrTXR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXR_TOTARM', 'TXR_TOTGER', 'FwFldGet("TXR_TOTRH")+FwFldGet("TXR_TOTMI")+FwFldGet("TXR_TOTMC")+FwFldGet("TXR_TOTUNI")+FwFldGet("TXR_TOTARM")', .F. )
	oStrTXR:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_TOTRH', 'TXS_TOTGER', 'FwFldGet("TXS_TOTRH")+FwFldGet("TXS_TOTMI")+FwFldGet("TXS_TOTMC")+FwFldGet("TXS_TOTUNI")+FwFldGet("TXS_TOTARM")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_TOTMI', 'TXS_TOTGER', 'FwFldGet("TXS_TOTRH")+FwFldGet("TXS_TOTMI")+FwFldGet("TXS_TOTMC")+FwFldGet("TXS_TOTUNI")+FwFldGet("TXS_TOTARM")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_TOTMC', 'TXS_TOTGER', 'FwFldGet("TXS_TOTRH")+FwFldGet("TXS_TOTMI")+FwFldGet("TXS_TOTMC")+FwFldGet("TXS_TOTUNI")+FwFldGet("TXS_TOTARM")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_TOTUNI', 'TXS_TOTGER', 'FwFldGet("TXS_TOTRH")+FwFldGet("TXS_TOTMI")+FwFldGet("TXS_TOTMC")+FwFldGet("TXS_TOTUNI")+FwFldGet("TXS_TOTARM")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_TOTARM', 'TXS_TOTGER', 'FwFldGet("TXS_TOTRH")+FwFldGet("TXS_TOTMI")+FwFldGet("TXS_TOTMC")+FwFldGet("TXS_TOTUNI")+FwFldGet("TXS_TOTARM")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXT_QUANTS', 'TXT_TOTMI', 'FwFldGet("TXT_QUANTS")*FwFldGet("TXT_VLUNIT")', .F. )
	oStrTXT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXT_TOTMI', 'TXT_TOTMI', 'At984aGtTt("TXTDETAIL","TXT_TOTMI","TXSDETAIL","TXS_TOTMI")', .F. )
	oStrTXT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXU_TOTMC', 'TXU_TOTMC', 'At984aGtTt("TXUDETAIL","TXU_TOTMC","TXSDETAIL","TXS_TOTMC")', .F. )
	oStrTXU:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXV_TOTUNI', 'TXV_TOTUNI', 'At984aGtTt("TXVDETAIL","TXV_TOTUNI","TXSDETAIL","TXS_TOTUNI")', .F. )
	oStrTXV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXW_TOTARM', 'TXW_TOTARM', 'At984aGtTt("TXWDETAIL","TXW_TOTARM","TXSDETAIL","TXS_TOTARM")', .F. )
	oStrTXW:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_TOTRH', 'TXS_TOTRH', 'At984aGtTt("TXSDETAIL","TXS_TOTRH","TXRMASTER","TXR_TOTRH")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_TOTMI', 'TXS_TOTMI', 'At984aGtTt("TXSDETAIL","TXS_TOTMI","TXRMASTER","TXR_TOTMI")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_TOTMC', 'TXS_TOTMC', 'At984aGtTt("TXSDETAIL","TXS_TOTMC","TXRMASTER","TXR_TOTMC")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_TOTUNI', 'TXS_TOTUNI', 'At984aGtTt("TXSDETAIL","TXS_TOTUNI","TXRMASTER","TXR_TOTUNI")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_TOTARM', 'TXS_TOTARM', 'At984aGtTt("TXSDETAIL","TXS_TOTARM","TXRMASTER","TXR_TOTARM")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_TOTPLA', 'TXS_GERPLA', 'FwFldGet("TXS_QUANTS")*FwFldGet("TXS_TOTPLA")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_QUANTS', 'TXS_GERPLA', 'FwFldGet("TXS_QUANTS")*FwFldGet("TXS_TOTPLA")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXS_GERPLA', 'TXS_GERPLA', 'At984aGtTt("TXSDETAIL","TXS_GERPLA","TXRMASTER","TXR_GERPLA")', .F. )
	oStrTXS:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'TXT_VLUNIT', 'TXT_TOTMI', 'FwFldGet("TXT_QUANTS")*FwFldGet("TXT_VLUNIT")', .F. )
	oStrTXT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXU_QUANTS', 'TXU_TOTMC', 'FwFldGet("TXU_QUANTS")*FwFldGet("TXU_VLUNIT")', .F. )
	oStrTXU:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXU_VLUNIT', 'TXU_TOTMC', 'FwFldGet("TXU_QUANTS")*FwFldGet("TXU_VLUNIT")', .F. )
	oStrTXU:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXV_QUANTS', 'TXV_TOTUNI', 'FwFldGet("TXV_QUANTS")*FwFldGet("TXV_VLUNIT")', .F. )
	oStrTXV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXV_VLUNIT', 'TXV_TOTUNI', 'FwFldGet("TXV_QUANTS")*FwFldGet("TXV_VLUNIT")', .F. )
	oStrTXV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXW_QUANTS', 'TXW_TOTARM', 'FwFldGet("TXW_QUANTS")*FwFldGet("TXW_VLUNIT")', .F. )
	oStrTXW:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXW_VLUNIT', 'TXW_TOTARM', 'FwFldGet("TXW_QUANTS")*FwFldGet("TXW_VLUNIT")', .F. )
	oStrTXW:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXT_CODPRD', 'TXT_DESCRI', 'Posicione("SB1",1,xFilial("SB1")+FwFldGet("TXT_CODPRD"),"B1_DESC")', .F. )
	oStrTXT:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXU_CODPRD', 'TXU_DESCRI', 'Posicione("SB1",1,xFilial("SB1")+FwFldGet("TXU_CODPRD"),"B1_DESC")', .F. )
	oStrTXU:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXV_CODPRD', 'TXV_DESCRI', 'Posicione("SB1",1,xFilial("SB1")+FwFldGet("TXV_CODPRD"),"B1_DESC")', .F. )
	oStrTXV:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXW_ITEARM', 'TXW_CODPRD', '""', .F. )
	oStrTXW:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXW_ITEARM', 'TXW_DESCRI', '""', .F. )
	oStrTXW:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXW_CODPRD', 'TXW_DESCRI', 'Posicione("SB1",1,xFilial("SB1")+FwFldGet("TXW_CODPRD"),"B1_DESC")', .F. )
	oStrTXW:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

oModel := MPFormModel():New("TECA984A", /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )
oModel:AddFields("TXRMASTER",/*cOwner*/,oStrTXR, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription(STR0008) //"Facilitador"

oModel:AddGrid("TXSDETAIL","TXRMASTER",oStrTXS,{|oMdl, nLine, cAcao, cCampo, xValue, xOldValue| PreLinTXS(oMdl, nLine, cAcao, cCampo, xValue, xOldValue)},{|oMdl| PosLinTXS(oMdl)} ,,, /*bCarga*/)
oModel:SetRelation("TXSDETAIL", {{"TXS_FILIAL","xFilial('TXS')"}, {"TXS_CODTXR","TXR_CODIGO"}}, TXS->(IndexKey(1)))

oModel:AddGrid("TXTDETAIL","TXSDETAIL",oStrTXT,{|oMdl, nLine, cAcao, cCampo, xValue, xOldValue| PreLinTXT(oMdl, nLine, cAcao, cCampo, xValue, xOldValue)},{|oMdl| PosLinTXT(oMdl)},,, /*bCarga*/)
oModel:SetRelation("TXTDETAIL", {{"TXT_FILIAL","xFilial('TXT')"}, {"TXT_CODTXS","TXS_CODIGO"}}, TXT->(IndexKey(1)))

oModel:AddGrid("TXUDETAIL","TXSDETAIL",oStrTXU,{|oMdl, nLine, cAcao, cCampo, xValue, xOldValue| PreLinTXU(oMdl, nLine, cAcao, cCampo, xValue, xOldValue)},{|oMdl| PosLinTXU(oMdl)},,, /*bCarga*/)
oModel:SetRelation("TXUDETAIL", {{"TXU_FILIAL","xFilial('TXU')"}, {"TXU_CODTXS","TXS_CODIGO"}}, TXU->(IndexKey(1)))

oModel:AddGrid("TXVDETAIL","TXSDETAIL",oStrTXV,{|oMdl, nLine, cAcao, cCampo, xValue, xOldValue| PreLinTXV(oMdl, nLine, cAcao, cCampo, xValue, xOldValue)},{|oMdl| PosLinTXV(oMdl)},,, /*bCarga*/)
oModel:SetRelation("TXVDETAIL", {{"TXV_FILIAL","xFilial('TXV')"}, {"TXV_CODTXS","TXS_CODIGO"}}, TXV->(IndexKey(1)))

oModel:AddGrid("TXWDETAIL","TXSDETAIL",oStrTXW,{|oMdl, nLine, cAcao, cCampo, xValue, xOldValue| PreLinTXW(oMdl, nLine, cAcao, cCampo, xValue, xOldValue)},{|oMdl| PosLinTXW(oMdl)},,, /*bCarga*/)
oModel:SetRelation("TXWDETAIL", {{"TXW_FILIAL","xFilial('TXW')"}, {"TXW_CODTXS","TXS_CODIGO"}}, TXW->(IndexKey(1)))

oModel:GetModel("TXSDETAIL"):SetFldNoCopy( { "TXS_CODIGO" } )
oModel:GetModel("TXTDETAIL"):SetFldNoCopy( { "TXT_CODIGO" } )
oModel:GetModel("TXUDETAIL"):SetFldNoCopy( { "TXU_CODIGO" } )
oModel:GetModel("TXVDETAIL"):SetFldNoCopy( { "TXV_CODIGO" } )
oModel:GetModel("TXWDETAIL"):SetFldNoCopy( { "TXW_CODIGO" } )

oModel:GetModel('TXTDETAIL'):SetOptional(.T.)
oModel:GetModel('TXUDETAIL'):SetOptional(.T.)
oModel:GetModel('TXVDETAIL'):SetOptional(.T.)
oModel:GetModel('TXWDETAIL'):SetOptional(.T.)

Return(oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description	Definição da View
@sample	 		ViewDef()
@author			Kaique Schiller
@since			30/06/2022
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView  
Local oModel  := FWLoadModel("TECA984A")
Local oStrTXR := FWFormStruct( 2,"TXR")  
Local oStrTXS := FWFormStruct( 2,"TXS",{ | cCampo | !(AllTrim(cCampo) $ "TXS_CODTXR|TXS_CALCMD|TXS_PLACOD|TXS_PLAREV") })
Local oStrTXT := FWFormStruct( 2,"TXT",{ | cCampo | !(AllTrim(cCampo) $ "TXT_CODTXS") })
Local oStrTXU := FWFormStruct( 2,"TXU",{ | cCampo | !(AllTrim(cCampo) $ "TXU_CODTXS") })
Local oStrTXV := FWFormStruct( 2,"TXV",{ | cCampo | !(AllTrim(cCampo) $ "TXV_CODTXS") })
Local oStrTXW := FWFormStruct( 2,"TXW",{ | cCampo | !(AllTrim(cCampo) $ "TXW_CODTXS") })

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_TXR",oStrTXR, "TXRMASTER")
oView:AddGrid("VIEW_TXS" ,oStrTXS, "TXSDETAIL")
oView:AddGrid("VIEW_TXT" ,oStrTXT, "TXTDETAIL")
oView:AddGrid("VIEW_TXU" ,oStrTXU, "TXUDETAIL")
oView:AddGrid("VIEW_TXV" ,oStrTXV, "TXVDETAIL")
oView:AddGrid("VIEW_TXW" ,oStrTXW, "TXWDETAIL")

oView:CreateHorizontalBox( "TOP"   , 30 )
oView:CreateHorizontalBox( "MIDDLE", 70 )

oView:CreateFolder( "ABAS", "MIDDLE")
oView:AddSheet("ABAS","ABA01",STR0009)  // "Recursos Humanos"

oView:CreateHorizontalBox( "ID_ABA01" , 050,,, "ABAS", "ABA01" ) // Define a área de Postos
oView:CreateHorizontalBox( 'ID_ABA02A', 050,,, 'ABAS', 'ABA01' ) // área dos acionais relacionados com RH

oView:CreateFolder( "ABASRH", "ID_ABA02A")
oView:AddSheet('ABASRH','RH_ABA02',STR0010) // 'Materiais de Implantação'
oView:CreateHorizontalBox( 'ID_RH_02' , 100,,, 'ABASRH','RH_ABA02' ) 

oView:AddSheet('ABASRH','RH_ABA03',STR0011) // "Material de Consumo"
oView:CreateHorizontalBox( 'ID_RH_03' , 100,,, 'ABASRH','RH_ABA03' ) 

oView:AddSheet('ABASRH','RH_ABA04',STR0012) // "Uniforme"
oView:CreateHorizontalBox( 'ID_RH_04' , 100,,, 'ABASRH','RH_ABA04' ) 

oView:AddSheet('ABASRH','RH_ABA05',STR0013) // "Armamento"
oView:CreateHorizontalBox( 'ID_RH_05' , 100,,, 'ABASRH','RH_ABA05' ) 

oView:SetOwnerView("VIEW_TXR"	,"TOP")			// Cabeçalho
oView:SetOwnerView("VIEW_TXS"	,"ID_ABA01")	// Grid de Postos
oView:SetOwnerView("VIEW_TXT"	,"ID_RH_02")	// Grid de Materiais de Implanatação
oView:SetOwnerView("VIEW_TXU"	,"ID_RH_03")	// Grid de Materiais de Consumo
oView:SetOwnerView("VIEW_TXV"	,"ID_RH_04")	// Grid de Uniforme
oView:SetOwnerView("VIEW_TXW"	,"ID_RH_05")	// Grid de Armamento

oView:AddUserButton(STR0016,"",{|oModel| AT352TDX(oModel,.T.)},,,) //"Vinculo de Beneficios"
oView:AddUserButton(STR0019,"",{|oModel| At984aPlPc(oModel,oView)},,,) // "Planilha de Preço

Return(oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDefA
@description	Retorno para o Menudef 
@sample	 		MenuDefA()
@author			Kaique Schiller
@since			30/06/2022
/*/
//------------------------------------------------------------------------------
Function MenuDefA(aRotina)
Return MenuDef(aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTXS
@description	Validação do pos linha da tabela TXS
@sample	 		PosLinTXS()
@author			Kaique Schiller
@since			30/06/2022
/*/
//------------------------------------------------------------------------------
Function PosLinTXS(oMdl)
Local lRet 	:= .T.

If Empty(oMdl:GetValue("TXS_CODPRD"))
	Help(,, "PosLinTXS",,STR0014,1,0,,,,,,{STR0015})//#"Campo de produto não foi preenchido." #"Realize o preenchimento do campo"
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTXT
@description	Validação do pos linha da tabela TXT
@sample	 		PosLinTXT()
@author			Kaique Schiller
@since			30/06/2022
/*/
//------------------------------------------------------------------------------
Function PosLinTXT(oMdl)
Local lRet 	:= .T.

If Empty(oMdl:GetValue("TXT_CODPRD"))
	Help(,, "PosLinTXT",,STR0014,1,0,,,,,,{STR0015})//#"Campo de produto não foi preenchido." #"Realize o preenchimento do campo"
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTXU
@description	Validação do pos linha da tabela TXU
@sample	 		PosLinTXU()
@author			Kaique Schiller
@since			30/06/2022
/*/
//------------------------------------------------------------------------------
Function PosLinTXU(oMdl)
Local lRet 	:= .T.

If Empty(oMdl:GetValue("TXU_CODPRD"))
	Help(,, "PosLinTXU",,STR0014,1,0,,,,,,{STR0015})//#"Campo de produto não foi preenchido." #"Realize o preenchimento do campo"
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTXV
@description	Validação do pos linha da tabela TXV
@sample	 		PosLinTXV()
@author			Kaique Schiller
@since			30/06/2022
/*/
//------------------------------------------------------------------------------
Function PosLinTXV(oMdl)
Local lRet 	:= .T.

If Empty(oMdl:GetValue("TXV_CODPRD"))
	Help(,, "PosLinTXV",,STR0014,1,0,,,,,,{STR0015})//#"Campo de produto não foi preenchido." #"Realize o preenchimento do campo"
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTXW
@description	Validação do pos linha da tabela TXW
@sample	 		PosLinTXW()
@author			Kaique Schiller
@since			30/06/2022
/*/
//------------------------------------------------------------------------------
Function PosLinTXW(oMdl)
Local lRet 	:= .T.

If Empty(oMdl:GetValue("TXW_CODPRD"))
	Help(,, "PosLinTXW",,STR0014,1,0,,,,,,{STR0015})//#"Campo de produto não foi preenchido." #"Realize o preenchimento do campo"
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tec984AImp
@description	Função de importação dos itens de RH
@sample	 		Tec984AImp(oModelFull,oModelTWO,oModelTFF,oMdlFac,cCodTWO,cCodFac,cItem,nQuant)
@author			Luiz Gabriel
@since			05/08/2022
/*/
//------------------------------------------------------------------------------
Function Tec984AImp(oModelFull,oModelTWO,oModelTFF,oMdlFac,cCodTWO,cCodFac,cItem,nQuant)
Local nY		:= 0
Local oMdlTXS 	:= oMdlFac:GetModel("TXSDETAIL")
Local lRet		:= .T.
Local lSetValue := .T.
Local lGsOrcUnif := FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma := FindFunction("TecGsArma") .And. TecGsArma()

For nY := 1 To oMdlTXS:Length()
	oMdlTXS:GoLine( nY )
	If !Empty( oMdlTXS:GetValue("TXS_CODPRD") )
		//Percorrer o modelo para ver se já adicionou aquele facilitador
		If !oModelTFF:SeekLine( { { 'TFF_CHVTWO', ;
				cCodFac + oMdlTXS:GetValue('TXS_CODIGO') + oModelTWO:GetValue('TWO_ITEM') } ,;
				{'TFF_CODTWO',cCodTWO }})
			If oModelTFF:Length() > 1 .Or. !Empty( oModelTFF:GetValue("TFF_PRODUT") )
				If nY <= oMdlTXS:Length()
					oModelTFF:AddLine()
					cItem := Soma1(cItem)
				EndIf
			Else 
				cItem := Soma1(cItem)
			EndIf
		Else 
			cItem := oModelTFF:GetValue("TFF_ITEM")
		EndIf
		nNumItem := nQuant * oMdlTXS:GetValue('TXS_QUANTS')
		cChvItem	:= cCodFac + oMdlTXS:GetValue('TXS_CODIGO') + oModelTWO:GetValue('TWO_ITEM')
		lSetValue := oModelTFF:SetValue('TFF_ITEM', cItem)
		lSetValue := lSetValue .And. oModelTFF:SetValue('TFF_CODTWO', cCodTWO)
		lSetValue := lSetValue .And. oModelTFF:SetValue('TFF_CHVTWO', cChvItem)
		lSetValue := lSetValue .And. oModelTFF:SetValue('TFF_QTDVEN', nNumItem)

		// Só atribui quando tem conteúdo
		If !Empty(oMdlTXS:GetValue('TXS_CODPRD'))
			lSetValue := lSetValue .And. oModelTFF:SetValue('TFF_PRODUT', oMdlTXS:GetValue('TXS_CODPRD'))
		EndIf

		If oMdlTXS:GetValue('TXS_VLUNIT') > 0
			lSetValue := lSetValue .And. oModelTFF:SetValue('TFF_PRCVEN', oMdlTXS:GetValue('TXS_VLUNIT'))
		EndIf 

		If !Empty(oMdlTXS:GetValue('TXS_FUNCAO'))
			lSetValue := lSetValue .And. oModelTFF:SetValue('TFF_FUNCAO', oMdlTXS:GetValue('TXS_FUNCAO'))
		EndIf

		If !Empty(oMdlTXS:GetValue('TXS_TURNO'))
			lSetValue := lSetValue .And. oModelTFF:SetValue('TFF_TURNO'	, oMdlTXS:GetValue('TXS_TURNO'))
		EndIf

		If !Empty(oMdlTXS:GetValue('TXS_ESCALA'))
			lSetValue := lSetValue .And. oModelTFF:SetValue('TFF_ESCALA'	, oMdlTXS:GetValue('TXS_ESCALA'))
		EndIf

		If !(Empty(oMdlTXS:GetValue('TXS_CARGO')) )
			lSetValue := lSetValue .And. oModelTFF:SetValue('TFF_CARGO', oMdlTXS:GetValue('TXS_CARGO'))
		EndIf

		If !(Empty(oMdlTXS:GetValue('TXS_TES')) )
			lSetValue := lSetValue .And. oModelTFF:SetValue('TFF_TESPED', oMdlTXS:GetValue('TXS_TES'))
		EndIf
		
		If !(Empty(oMdlTXS:GetValue('TXS_CALCMD')) )
			lSetValue := lSetValue .And. oModelTFF:SetValue('TFF_CALCMD', oMdlTXS:GetValue('TXS_CALCMD'))
		EndIf

		If TFF->( ColumnPos('TFF_TOTPLA') ) .And. !(Empty(oMdlTXS:GetValue('TXS_TOTPLA')) )
			lSetValue := lSetValue .And. oModelTFF:SetValue('TFF_TOTPLA', oMdlTXS:GetValue('TXS_TOTPLA'))
		EndIf
		If lSetValue
			//Verifica a existencia de M.I
			lSetValue := At984AMat(oModelFull,oMdlFac,oModelTWO,oMdlTXS:GetValue('TXS_CODIGO'),"TXT","TFG",nQuant,cCodTWO)
		EndIf 

		If lSetValue
			//Verifica a existencia de M.I
			lSetValue := At984AMat(oModelFull,oMdlFac,oModelTWO,oMdlTXS:GetValue('TXS_CODIGO'),"TXU","TFH",nQuant,cCodTWO)
		EndIf 

		If lSetValue .And. lGsOrcUnif
			lSetValue := At984AUnif(oModelFull,oMdlFac,oModelTWO,oMdlTXS:GetValue('TXS_CODIGO'),nQuant,cCodTWO)
		EndIf 

		If lSetValue .And. lGsOrcArma
			lSetValue := At984AArm(oModelFull,oMdlFac,oModelTWO,oMdlTXS:GetValue('TXS_CODIGO'),nQuant,cCodTWO)
		EndIf 
	EndIf
Next nY		

oModelTFF:GoLine(1)

If !lSetValue .And. !IsBlind()
	AtErroMvc(oModelFull)
	MostraErro()
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At984AMat
@description	Função de importação dos materiais M.I/M.C
@sample	 		At984AMat(oModelFull,oMdlFac,oModelTWO,cCodRH,cTabFac,cTabMat,nQuant,cCodTWO)
@author			Luiz Gabriel
@since			05/08/2022
/*/
//------------------------------------------------------------------------------
Static Function At984AMat(oModelFull,oMdlFac,oModelTWO,cCodRH,cTabFac,cTabMat,nQuant,cCodTWO)
Local lSetValue 	:= .T.
Local nY 			:= 0
Local nNumItem 		:= 0
Local cChvItem 		:= ""
Local cItem			:= Replicate("0", TamSx3(cTabMat +"_ITEM")[1]  )
Local oModGridOrc	:= Nil
Local oModFacMat	:= oMdlFac:GetModel(cTabFac+'DETAIL')

If cTabMat == "TFG"
	oModGridOrc := oModelFull:GetModel('TFG_MI')
ElseIf cTabMat == "TFH"
	oModGridOrc := oModelFull:GetModel('TFH_MC')
EndIf 

//Caso o Grid ja possua itens MI / MC, ajusta o campo ITEM para adicionar os produtos do facilitador
If !oModGridOrc:IsEmpty()
	oModGridOrc:GoLine(oModGridOrc:Length())
	cItem := oModGridOrc:GetValue(cTabMat+'_ITEM')
EndIf

For nY := 1 To oModFacMat:Length()
	oModFacMat:GoLine( nY )
	If !Empty(oModFacMat:GetValue(cTabFac+'_CODPRD'))
		
		If !oModGridOrc:SeekLine( { { cTabMat+'_CHVTWO' , ;
				cCodFac + oModFacMat:GetValue(cTabFac+'_CODIGO') + oModelTWO:GetValue('TWO_ITEM') } ,;
				{cTabMat+'_CODTWO',cCodTWO }} )
			//Verificar se não encontrou o facilitardor adicionar uma linha nova com as informações
			If oModGridOrc:Length() > 1 .Or. !Empty( oModGridOrc:GetValue(cTabMat+"_PRODUT") )
				If nY <= oModFacMat:Length()
					oModGridOrc:AddLine()
					cItem := Soma1(cItem)
				EndIf
			Else 
				cItem := Soma1(cItem)
			EndIf
		Else 
			cItem := oModGridOrc:GetValue(cTabMat+'_ITEM')
		EndIf

		nNumItem := nQuant * oModFacMat:GetValue(cTabFac+'_QUANTS')
		cChvItem	:= cCodFac + oModFacMat:GetValue(cTabFac+'_CODIGO') + oModelTWO:GetValue('TWO_ITEM')
		lSetValue := oModGridOrc:SetValue(cTabMat+'_ITEM', cItem)
		lSetValue := lSetValue .And. oModGridOrc:SetValue(cTabMat+'_CODTWO', cCodTWO)
		lSetValue := lSetValue .And. oModGridOrc:SetValue(cTabMat+'_CHVTWO', cChvItem)
		
		If !Empty(oModFacMat:GetValue(cTabFac+'_CODPRD'))
			lSetValue := lSetValue .And. oModGridOrc:SetValue(cTabMat+'_PRODUT', oModFacMat:GetValue(cTabFac+'_CODPRD'))
		EndIf
		lSetValue := lSetValue .And. oModGridOrc:SetValue(cTabMat+'_QTDVEN', nNumItem)
		
		If oModFacMat:GetValue(cTabFac+'_VLUNIT') > 0
			lSetValue := lSetValue .And. oModGridOrc:SetValue(cTabMat+'_PRCVEN', oModFacMat:GetValue(cTabFac+'_VLUNIT'))
		EndIf

		If !Empty(oModFacMat:GetValue(cTabFac+'_TES'))
			lSetValue := lSetValue .And. oModGridOrc:SetValue(cTabMat+'_TESPED', oModFacMat:GetValue(cTabFac+'_TES'))
		EndIf
	EndIf
Next nY

oModGridOrc:GoLine(1)

Return lSetValue

//------------------------------------------------------------------------------
/*/{Protheus.doc} At984AUnif
@description	Função de importação dos Uniformes
@sample	 		At984AUnif(oModelFull,oMdlFac,oModelTWO,cCodRH,nQuant,cCodTWO)
@author			Luiz Gabriel
@since			05/08/2022
/*/
//------------------------------------------------------------------------------
Static Function At984AUnif(oModelFull,oMdlFac,oModelTWO,cCodRH,nQuant,cCodTWO)
Local lSetValue 	:= .T.
Local nY 			:= 0
Local nNumItem 		:= 0
Local cChvItem 		:= ""
Local oModGridOrc	:= oModelFull:GetModel('TXPDETAIL')
Local oModFacMat	:= oMdlFac:GetModel('TXVDETAIL')
Local cItem			:= oModGridOrc:GetValue('TXP_CODIGO') //Replicate("0", TamSx3("TXP_CODIGO")[1]  )

//Caso o Grid ja possua itens, ajusta o campo ITEM para adicionar os produtos do facilitador
If !oModGridOrc:IsEmpty()
	oModGridOrc:GoLine(oModGridOrc:Length())
	cItem := oModGridOrc:GetValue('TXP_CODIGO')
EndIf

For nY := 1 To oModFacMat:Length()
	oModFacMat:GoLine( nY )
	If !Empty(oModFacMat:GetValue('TXV_CODPRD'))

		If !oModGridOrc:SeekLine( { { 'TXP_CHVTWO' , ;
				 cCodFac + oModFacMat:GetValue('TXV_CODIGO') + oModelTWO:GetValue('TWO_ITEM') } ,;
				 {'TXP_CODTWO', cCodTWO} } )
			//Verificar se não encontrou o facilitardor adicionar uma linha nova com as informações
			If oModGridOrc:Length() > 1 .Or. !Empty( oModGridOrc:GetValue("TXP_CODUNI") )
				If nY <= oModFacMat:Length()
					oModGridOrc:AddLine()
					cItem := Soma1(cItem)
				EndIf
			Else 
				cItem := Soma1(cItem)
			EndIf
		Else 
			cItem := oModGridOrc:GetValue('TXP_CODIGO')
		EndIf

		nNumItem := nQuant * oModFacMat:GetValue('TXV_QUANTS')
		cChvItem	:= cCodFac + oModFacMat:GetValue('TXV_CODIGO') + oModelTWO:GetValue('TWO_ITEM')
		lSetValue := oModGridOrc:SetValue('TXP_CODIGO', cItem)
		lSetValue := lSetValue .And. oModGridOrc:SetValue('TXP_CODTWO', cCodTWO)
		lSetValue := lSetValue .And. oModGridOrc:SetValue('TXP_CHVTWO', cChvItem)
		
		If !Empty(oModFacMat:GetValue('TXV_CODPRD'))
			lSetValue := lSetValue .And. oModGridOrc:SetValue('TXP_CODUNI', oModFacMat:GetValue('TXV_CODPRD'))
		EndIf
		
		lSetValue := lSetValue .And. oModGridOrc:SetValue('TXP_QTDVEN', nNumItem)
		
		If oModFacMat:GetValue('TXV_VLUNIT') > 0
			lSetValue := lSetValue .And. oModGridOrc:SetValue('TXP_PRCVEN', oModFacMat:GetValue('TXV_VLUNIT'))
		EndIf

	EndIf
Next nY

oModGridOrc:GoLine(1)


Return lSetValue

//------------------------------------------------------------------------------
/*/{Protheus.doc} At984AArm
@description	Função de importação dos Armamentos
@sample	 		At984AArm(oModelFull,oMdlFac,oModelTWO,cCodRH,nQuant,cCodTWO)
@author			Luiz Gabriel
@since			05/08/2022
/*/
//------------------------------------------------------------------------------
Static Function At984AArm(oModelFull,oMdlFac,oModelTWO,cCodRH,nQuant,cCodTWO)
Local lSetValue 	:= .T.
Local nY 			:= 0
Local nNumItem 		:= 0
Local cChvItem 		:= ""
Local oModGridOrc	:= oModelFull:GetModel('TXQDETAIL')
Local oModFacMat	:= oMdlFac:GetModel('TXWDETAIL')
Local cItem			:= oModGridOrc:GetValue('TXQ_CODIGO') //Replicate("0", TamSx3("TXP_CODIGO")[1]  )

//Caso o Grid ja possua itens, ajusta o campo ITEM para adicionar os produtos do facilitador
If !oModGridOrc:IsEmpty()
	oModGridOrc:GoLine(oModGridOrc:Length())
	cItem := oModGridOrc:GetValue('TXQ_CODIGO')
EndIf

For nY := 1 To oModFacMat:Length()
	oModFacMat:GoLine( nY )
	If !Empty(oModFacMat:GetValue('TXW_CODPRD'))

		If !oModGridOrc:SeekLine( { { 'TXQ_CHVTWO' , ;
				cCodFac + oModFacMat:GetValue('TXW_CODIGO') + oModelTWO:GetValue('TWO_ITEM') } ,;
				{'TXQ_CODTWO' , cCodTWO } } )
			//Verificar se não encontrou o facilitardor adicionar uma linha nova com as informações
			If oModGridOrc:Length() > 1 .Or. !Empty( oModGridOrc:GetValue("TXQ_CODPRD") )
				If nY <= oModFacMat:Length()
					oModGridOrc:AddLine()
					cItem := Soma1(cItem)
				EndIf
			Else 
				cItem := Soma1(cItem)
			EndIf
		Else 
			cItem := oModGridOrc:GetValue('TXQ_CODIGO')
		EndIf

		nNumItem := nQuant * oModFacMat:GetValue('TXW_QUANTS')
		cChvItem	:= cCodFac + oModFacMat:GetValue('TXW_CODIGO') + oModelTWO:GetValue('TWO_ITEM')
		lSetValue := oModGridOrc:SetValue('TXQ_CODIGO', cItem)
		lSetValue := lSetValue .And. oModGridOrc:SetValue('TXQ_CODTWO', cCodTWO)
		lSetValue := lSetValue .And. oModGridOrc:SetValue('TXQ_CHVTWO', cChvItem)
		
		If !Empty(oModFacMat:GetValue('TXW_ITEARM'))
			lSetValue := lSetValue .And. oModGridOrc:SetValue('TXQ_ITEARM', oModFacMat:GetValue('TXW_ITEARM'))
		EndIf

		If !Empty(oModFacMat:GetValue('TXW_CODPRD'))
			lSetValue := lSetValue .And. oModGridOrc:SetValue('TXQ_CODPRD', oModFacMat:GetValue('TXW_CODPRD'))
		EndIf
		
		lSetValue := lSetValue .And. oModGridOrc:SetValue('TXQ_QTDVEN', nNumItem)
		
		If oModFacMat:GetValue('TXW_VLUNIT') > 0
			lSetValue := lSetValue .And. oModGridOrc:SetValue('TXQ_PRCVEN', oModFacMat:GetValue('TXW_VLUNIT'))
		EndIf

	EndIf
Next nY

oModGridOrc:GoLine(1)

Return lSetValue

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tec984ADel
@description	Função de exclusão das linhas do facilitador de linhas de RH
@sample	 		Tec984ADel(oModelFull,oModelTWO,oModelTFF,oModelFac,cCodFac,cCodTWO,lAlterTWO)
@author			Luiz Gabriel
@since			05/08/2022
/*/
//------------------------------------------------------------------------------
Function Tec984ADel(oModelFull,oModelTWO,oModelTFF,oModelFac,cCodFac,cCodTWO,lAlterTWO) 
Local nY		:= 0
Local oMdlTXR 	:= Nil
Local oMdlFac	:= Nil
Local oMdlTXS 	:= Nil 
Local lRet		:= .T.
Local lSetValue := .T.
Local lGsOrcUnif := FindFunction("TecGsUnif") .And. TecGsUnif()
Local lGsOrcArma := FindFunction("TecGsArma") .And. TecGsArma()

oMdlTXR := Iif(lAlterTWO,Tec984aLFac(oModelTWO,cCodFac), oModelFac)
oMdlFac	:= oMdlTXR
oMdlTXS := oMdlFac:GetModel("TXSDETAIL")

For nY := 1 To oMdlTXS:Length()
	oMdlTXS:GoLine( nY )
	If !Empty( oMdlTXS:GetValue("TXS_CODPRD") )
		//Percorrer o modelo para ver se já adicionou aquele facilitador
		If oModelTFF:SeekLine( { { 'TFF_CHVTWO', ;
				cCodFac + oMdlTXS:GetValue('TXS_CODIGO') + oModelTWO:GetValue('TWO_ITEM')},;
				{'TFF_CODTWO',cCodTWO }})
			If !Empty( oModelTFF:GetValue("TFF_PRODUT") )
				lSetValue := oModelTFF:DeleteLine()
			EndIf
		EndIf

		If lSetValue
			//Verifica a existencia de M.I
			lSetValue := At984ADelMa(oModelFull,oMdlFac,oModelTWO,oMdlTXS:GetValue('TXS_CODIGO'),"TXT","TFG",cCodTWO)
		EndIf 

		If lSetValue
			//Verifica a existencia de M.I
			lSetValue := At984ADelMa(oModelFull,oMdlFac,oModelTWO,oMdlTXS:GetValue('TXS_CODIGO'),"TXU","TFH",cCodTWO)
		EndIf 

		If lSetValue .And. lGsOrcUnif
			lSetValue := At984ADelUn(oModelFull,oMdlFac,oModelTWO,oMdlTXS:GetValue('TXS_CODIGO'),cCodTWO)
		EndIf 

		If lSetValue .And. lGsOrcArma
			lSetValue := At984ADelAr(oModelFull,oMdlFac,oModelTWO,oMdlTXS:GetValue('TXS_CODIGO'),cCodTWO)
		EndIf
	EndIf
Next nY		

oModelTFF:GoLine(1)

If !lSetValue .And. !IsBlind()
	AtErroMvc(oModelFull)
	MostraErro()
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At984ADelMa
@description	Função de exclusão das linhas do facilitador de materiais de M.I/M.C
@sample	 		At984ADelMa(oModelFull,oMdlFac,oModelTWO,cCodRH,cTabFac,cTabMat,cCodTWO)
@author			Luiz Gabriel
@since			05/08/2022
/*/
//------------------------------------------------------------------------------
Static Function At984ADelMa(oModelFull,oMdlFac,oModelTWO,cCodRH,cTabFac,cTabMat,cCodTWO)
Local lSetValue 	:= .T.
Local nY 			:= 0
Local oModGridOrc	:= Nil
Local oModFacMat	:= oMdlFac:GetModel(cTabFac+'DETAIL')

If cTabMat == "TFG"
	oModGridOrc := oModelFull:GetModel('TFG_MI')
ElseIf cTabMat == "TFH"
	oModGridOrc := oModelFull:GetModel('TFH_MC')
EndIf 

For nY := 1 To oModFacMat:Length()
	oModFacMat:GoLine( nY )
	If !Empty(oModFacMat:GetValue(cTabFac+'_CODPRD'))		
		//Posiciona na linha a ser deletada
		If oModGridOrc:SeekLine( { { cTabMat+'_CHVTWO' , ;
				cCodFac + oModFacMat:GetValue(cTabFac+'_CODIGO') + oModelTWO:GetValue('TWO_ITEM') },;
				{cTabMat+'_CODTWO',cCodTWO} } )
			If oModGridOrc:Length() > 1 .Or. !Empty( oModGridOrc:GetValue(cTabMat+"_PRODUT") )
				If !Empty( oModGridOrc:GetValue(cTabMat+"_PRODUT") )
					lSetValue := oModGridOrc:DeleteLine()
				EndIf
			EndIf
		EndIf
	EndIf
Next nY

oModGridOrc:GoLine(1)

Return lSetValue

//------------------------------------------------------------------------------
/*/{Protheus.doc} At984ADelUn
@description	Função de exclusão das linhas do facilitador de Uniforme
@sample	 		At984ADelUn(oModelFull,oMdlFac,oModelTWO,cCodRH,cCodTWO)
@author			Luiz Gabriel
@since			05/08/2022
/*/
//------------------------------------------------------------------------------
Static Function At984ADelUn(oModelFull,oMdlFac,oModelTWO,cCodRH,cCodTWO)
Local lSetValue 	:= .T.
Local nY 			:= 0
Local oModGridOrc	:= oModelFull:GetModel('TXPDETAIL')
Local oModFacMat	:= oMdlFac:GetModel('TXVDETAIL')

For nY := 1 To oModFacMat:Length()
	oModFacMat:GoLine( nY )
	If !Empty(oModFacMat:GetValue('TXV_CODPRD'))

		If oModGridOrc:SeekLine( { { 'TXP_CHVTWO' , ;
				cCodFac + oModFacMat:GetValue('TXV_CODIGO') + oModelTWO:GetValue('TWO_ITEM') },;
				{'TXP_CODTWO',cCodTWO} } )
			If oModGridOrc:Length() > 1 .Or. !Empty( oModGridOrc:GetValue("TXP_CODUNI") )
				If !Empty( oModGridOrc:GetValue("TXP_CODUNI") )
					lSetValue := oModGridOrc:DeleteLine()
				EndIf
			EndIf
		EndIf
	EndIf
Next nY

oModGridOrc:GoLine(1)

Return lSetValue

//------------------------------------------------------------------------------
/*/{Protheus.doc} At984ADelAr
@description	Função de exclusão das linhas do facilitador de Armamento
@sample	 		At984ADelAr(oModelFull,oMdlFac,oModelTWO,cCodRH,cCodTWO)
@author			Luiz Gabriel
@since			05/08/2022
/*/
//------------------------------------------------------------------------------
Static Function At984ADelAr(oModelFull,oMdlFac,oModelTWO,cCodRH,cCodTWO)
Local lSetValue 	:= .T.
Local nY 			:= 0
Local oModGridOrc	:= oModelFull:GetModel('TXQDETAIL')
Local oModFacMat	:= oMdlFac:GetModel('TXWDETAIL')

For nY := 1 To oModFacMat:Length()
	oModFacMat:GoLine( nY )
	If !Empty(oModFacMat:GetValue('TXW_CODPRD'))

		If oModGridOrc:SeekLine( { { 'TXQ_CHVTWO' , ;
				cCodFac + oModFacMat:GetValue('TXW_CODIGO') + oModelTWO:GetValue('TWO_ITEM') } ,;
				{'TXQ_CODTWO',cCodTWO} } )
			//Verificar se não encontrou o facilitardor adicionar uma linha nova com as informações
			If oModGridOrc:Length() > 1 .Or. !Empty( oModGridOrc:GetValue("TXQ_CODPRD") )
				If !Empty( oModGridOrc:GetValue("TXQ_CODPRD") )
					lSetValue := oModGridOrc:DeleteLine()
				EndIf
			EndIf
		EndIf
	EndIf
Next nY

oModGridOrc:GoLine(1)

Return lSetValue

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tec984aLFac
@description	Função para carregar o modelo do facilitador a ser substituido
@sample	 		Tec984aLFac(oModelTWO,cCodFac)
@author			Luiz Gabriel
@since			05/08/2022
/*/
//------------------------------------------------------------------------------
Static Function Tec984aLFac(oModelTWO,cCodFac)
Local oMdlTXR := Nil

TXR->(dbSetOrder(1))//TXR_FILIAL+TXR_CODIGO
If TXR->(dbSeek(xFilial("TXR") + cCodFac)) //Necessario posicionar para realizar load da TXR
	TXS->(dbSetOrder(2))
	If TXS->(dbSeek(xFilial("TXS") + cCodFac))
		oMdlTXR := FwLoadModel("TECA984A")
		oMdlTXR:SetOperation(MODEL_OPERATION_VIEW)
		oMdlTXR:Activate()
		FwModelActive( oModelTWO:GetModel() )
	EndIf	
EndIf 

Return oMdlTXR

//------------------------------------------------------------------------------
/*/{Protheus.doc} At984aPlPc
	Planilha de preço
@sample At984aPlPc()
@author Kaique Schiller
@since	13/07/2022       
/*/
//------------------------------------------------------------------------------
Static Function At984aPlPc(oModel,oView)
Default oModel := Nil
Default oView := Nil

Return TECA998(oModel,oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At984aGtTt
	Gatilho de totais
@sample At984aGtTt()
@author Kaique Schiller
@since	13/07/2022       
/*/
//------------------------------------------------------------------------------
Function At984aGtTt(cDtlVlr,cCmpVlr,cDltTot,cCmpTot,nVlrSub,cAcao)
Local oModel := FwModelActive()
Local oMdlTot := oModel:GetModel(cDltTot)
Local oMdlVlr := oModel:GetModel(cDtlVlr)
Local nX := 0
Local nTot := 0
Local aSaveRows := {}
Default nVlrSub := 0
Default cAcao := ""
aSaveRows := FwSaveRows()
For nX := 1 To oMdlVlr:Length()
	oMdlVlr:Goline(nX)
	If !oMdlVlr:IsDeleted()
		nTot += oMdlVlr:GetValue(cCmpVlr)
	Endif
Next nX
If cAcao == "DELETE"
	oMdlTot:SetValue(cCmpTot,nTot-nVlrSub)
Elseif cAcao == "UNDELETE"
	oMdlTot:SetValue(cCmpTot,nTot+nVlrSub)
Else
	oMdlTot:SetValue(cCmpTot,nTot)
Endif
FWRestRows( aSaveRows )
Return 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTXS
	Prelinha de Totais de RH
@sample PreLinTXS()
@author Kaique Schiller
@since	16/08/2022       
/*/
//------------------------------------------------------------------------------
Function PreLinTXS(oMdl, nLine, cAcao, cCampo, xValue, xOldValue)

If cAcao == "DELETE"
	At984aGtTt("TXSDETAIL","TXS_TOTRH" ,"TXRMASTER","TXR_TOTRH" ,oMdl:GetValue("TXS_TOTRH") ,cAcao)
	At984aGtTt("TXSDETAIL","TXS_TOTMI" ,"TXRMASTER","TXR_TOTMI" ,oMdl:GetValue("TXS_TOTMI") ,cAcao)
	At984aGtTt("TXSDETAIL","TXS_TOTMC" ,"TXRMASTER","TXR_TOTMC" ,oMdl:GetValue("TXS_TOTMC") ,cAcao)
	At984aGtTt("TXSDETAIL","TXS_TOTUNI","TXRMASTER","TXR_TOTUNI",oMdl:GetValue("TXS_TOTUNI"),cAcao)
	At984aGtTt("TXSDETAIL","TXS_TOTARM","TXRMASTER","TXR_TOTARM",oMdl:GetValue("TXS_TOTARM"),cAcao)
	At984aGtTt("TXSDETAIL","TXS_GERPLA","TXRMASTER","TXR_GERPLA",oMdl:GetValue("TXS_GERPLA"),cAcao)
Elseif cAcao == "UNDELETE"
	At984aGtTt("TXSDETAIL","TXS_TOTRH" ,"TXRMASTER","TXR_TOTRH" ,oMdl:GetValue("TXS_TOTRH") ,cAcao)
	At984aGtTt("TXSDETAIL","TXS_TOTMI" ,"TXRMASTER","TXR_TOTMI" ,oMdl:GetValue("TXS_TOTMI") ,cAcao)
	At984aGtTt("TXSDETAIL","TXS_TOTMC" ,"TXRMASTER","TXR_TOTMC" ,oMdl:GetValue("TXS_TOTMC") ,cAcao)
	At984aGtTt("TXSDETAIL","TXS_TOTUNI","TXRMASTER","TXR_TOTUNI",oMdl:GetValue("TXS_TOTUNI"),cAcao)
	At984aGtTt("TXSDETAIL","TXS_TOTARM","TXRMASTER","TXR_TOTARM",oMdl:GetValue("TXS_TOTARM"),cAcao)
	At984aGtTt("TXSDETAIL","TXS_GERPLA","TXRMASTER","TXR_GERPLA",oMdl:GetValue("TXS_GERPLA"),cAcao)
Endif

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTXT
	Prelinha de Totais de MI
@sample PreLinTXT()
@author Kaique Schiller
@since	16/08/2022       
/*/
//------------------------------------------------------------------------------
Function PreLinTXT(oMdl, nLine, cAcao, cCampo, xValue, xOldValue)

If cAcao == "DELETE"
	At984aGtTt("TXTDETAIL","TXT_TOTMI","TXSDETAIL","TXS_TOTMI",oMdl:GetValue("TXT_TOTMI"),cAcao)
Elseif cAcao == "UNDELETE"
	At984aGtTt("TXTDETAIL","TXT_TOTMI","TXSDETAIL","TXS_TOTMI",oMdl:GetValue("TXT_TOTMI"),cAcao)
Endif

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTXU
	Prelinha de Totais de MC
@sample PreLinTXU()
@author Kaique Schiller
@since	16/08/2022       
/*/
//------------------------------------------------------------------------------
Function PreLinTXU(oMdl, nLine, cAcao, cCampo, xValue, xOldValue)

If cAcao == "DELETE"
	At984aGtTt("TXUDETAIL","TXU_TOTMC","TXSDETAIL","TXS_TOTMC",oMdl:GetValue("TXU_TOTMC"),cAcao)
Elseif cAcao == "UNDELETE"
	At984aGtTt("TXUDETAIL","TXU_TOTMC","TXSDETAIL","TXS_TOTMC",oMdl:GetValue("TXU_TOTMC"),cAcao)
Endif

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTXV
	Prelinha de Totais de Uniforme
@sample PreLinTXV()
@author Kaique Schiller
@since	16/08/2022       
/*/
//------------------------------------------------------------------------------
Function PreLinTXV(oMdl, nLine, cAcao, cCampo, xValue, xOldValue)

If cAcao == "DELETE"
	At984aGtTt("TXVDETAIL","TXV_TOTUNI","TXSDETAIL","TXS_TOTUNI",oMdl:GetValue("TXV_TOTUNI"),cAcao)
Elseif cAcao == "UNDELETE"
	At984aGtTt("TXVDETAIL","TXV_TOTUNI","TXSDETAIL","TXS_TOTUNI",oMdl:GetValue("TXV_TOTUNI"),cAcao)
Endif

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTXW
	Prelinha de Totais de Armamento
@sample PreLinTXW()
@author Kaique Schiller
@since	16/08/2022       
/*/
//------------------------------------------------------------------------------
Function PreLinTXW(oMdl, nLine, cAcao, cCampo, xValue, xOldValue)

If cAcao == "DELETE"
	At984aGtTt("TXWDETAIL","TXW_TOTARM","TXSDETAIL","TXS_TOTARM",oMdl:GetValue("TXW_TOTARM"),cAcao)
Elseif cAcao == "UNDELETE"
	At984aGtTt("TXWDETAIL","TXW_TOTARM","TXSDETAIL","TXS_TOTARM",oMdl:GetValue("TXW_TOTARM"),cAcao)
Endif

Return .T.                                                                                                                                                                 

//--------------------------------------------------------------------------------
/*/{Protheus.doc} AT984VldF
L
@description validação do campo TXS_FUNCAO 
@author Vitor kwon
@since  12/08/2022
/*/
//--------------------------------------------------------------------------------
Function AT984VldF(cBaseOP,cFuncao)
Local lRet := BaseCCTF3(cBaseOP,cFuncao) 

If !lRet
	Help(,, "AT894MSG",,STR0017,1,0,,,,,,{STR0018})
Endif

Return lRet	
