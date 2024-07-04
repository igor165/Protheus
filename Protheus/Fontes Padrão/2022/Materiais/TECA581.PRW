#include "TECA581.CH"
#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"

//Status do orçamento de serviços
#DEFINE DEF_TW0_ATIVO   "1"		//TW0_STATUS - Ativo
#DEFINE DEF_TW0_INATIVO "2"		//TW0_STATUS - Inativo

Static cRetCodTFF	:= ""
Static cRetF3		:= ""
Static aRotasCb		:= {}

//----------------------------------------------------------
/*/{Protheus.doc} TECA581
@description	Rota de cobertura do Almocista/Jantista
@return	 	NIL
@author	 	Serviço
@since			19/06/2015
@version		P12
/*/
//----------------------------------------------------------
Function TECA581()
Local oMBrowse

oMBrowse	:= FWmBrowse():New()
oMBrowse:SetAlias("TW0")
oMBrowse:SetDescription(STR0001)   // "Rota de Cobertura"

If TW0->( ColumnPos('TW0_STATUS')) > 0
	oMBrowse:AddLegend("EMPTY(TW0->TW0_STATUS) .OR. TW0->TW0_STATUS == '" + DEF_TW0_ATIVO + "'","BR_VERDE",STR0118) //"Rota de Cobertura Ativa"
	oMBrowse:AddLegend("TW0->TW0_STATUS == '" + DEF_TW0_INATIVO + "'","BR_VERMELHO",STR0119) //"Rota de Cobertura Inativa"
EndIf 

oMBrowse:Activate()

Return
//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
@description	MenuDef da Rota de cobertura 
@sample		MenuDef()
@return 		aExp1: Array com as rotinas específicas
@author 		Serviços
@since 			03/08/2015
@version		P12
/*/
//----------------------------------------------------------
Static Function MenuDef()

Local aRotina 	:= FwMVCMenu("TECA581")
Local aRtnCust	:= {}

If SuperGetMV("MV_GSROTA",,.F.)
	ADD OPTION aRotina Title STR0023 ACTION "At581Alc()" OPERATION 2 ACCESS 0 // "Movimentar"
Else
	ADD OPTION aRotina Title STR0023 ACTION "At581MvRmv('MV')" OPERATION 2 ACCESS 0 // "Movimentar"
Endif
ADD OPTION aRotina Title STR0024 ACTION "At581MvRmv('RE')" OPERATION 2 ACCESS 0 // "Remover "
ADD OPTION aRotina Title STR0093 ACTION "At581MvRmv('CA')" OPERATION 2 ACCESS 0 // "Cancelamento de Agenda"
ADD OPTION aRotina Title STR0115 ACTION "At581MvRmv('TR')" OPERATION 2 ACCESS 0 // "Troca de Cobertura"
ADD OPTION aRotina Title STR0120 Action 'AT581Ativ()'   OPERATION 4 ACCESS 0 	//"Inativar / Ativar" //'Ativar / Inativar'
If ExistFunc('AT581ADef')
	ADD OPTION aRotina Title STR0139 ACTION "At581MLote()" OPERATION 2 ACCESS 0 // "Movimentação em Lote"
EndIf 

If ExistBlock("AT581MNU")
	aRtnCust := ExecBlock("AT581MNU",.F.,.F.,{aRotina})
	If ValType(aRtnCust) == "A"
		aRotina := aClone(aRtnCust)
    EndIf
EndIf

Return aRotina
//----------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description	Model - Relacionamentos - Rota de cobertura 
@return		oExp1: Modelo MVC da Rota de cobertura
@author		Serviços
@since			19/06/2015
@version		P12
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStrTW0 	:= FWFormStruct(1,"TW0")
Local oStrTW1 	:= FWFormStruct(1,"TW1")
Local oStrABB	:= Nil
Local bPosValid	:= {|oModel| At581PosVl(oModel)}
Local bLinePost	:= {|a,b|At581LnPos(a,b)}
Local bLinePre	:= {|oModel,nLine,cAcao,cCampo, xValue, xOldValue| At581PLine(oModel,nLine,cAcao,cCampo, xValue, xOldValue)}
Local aAux		:= {}
Local lMvGsRota := At581GsRota() .And. (IsInCallStack("At581Alc") .Or. IsInCallStack("At581ARtLt"))
Local lRotaVaga	:= At581RtVag()
Local bCommit 	:= {|oModel| At581Cmt(oModel) }

oStrTW1:AddField(STR0091,STR0091,"TW1_DTINI","D",8,0,/*bValid*/,/*bWhen*/, /*aValues*/,.F.,/*bINIT*/,/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Per. Ini."
oStrTW1:AddField(STR0092,STR0092,"TW1_DTFIM","D",8,0,/*bValid*/,/*bWhen*/, /*aValues*/,.F.,/*bINIT*/,/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Per. Fin."

If lMvGsRota 
	oStrABB	:= FWFormModelStruct():New()	
	oStrABB:AddTable("   ",{}, "   ")
	oStrTW0:AddField(STR0091,STR0091,"DET_DTINI","D",8,0,/*bValid*/,/*bWhen*/, /*aValues*/,.F.,/*bINIT*/,/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Per. Ini."
	oStrTW0:AddField(STR0092,STR0092,"DET_DTFIM","D",8,0,/*bValid*/,/*bWhen*/, /*aValues*/,.F.,/*bINIT*/,/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Per. Fin."
	oStrTW1:AddField(STR0234,STR0234,"TW1_DETALH","C",185,0,/*bValid*/,/*bWhen*/, /*aValues*/,.F.,/*bINIT*/,/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Detalhes"
	
	aAux := FwStruTrigger( 'DET_DTINI', 'DET_DTINI','At581Load(!IsInCallStack("At581ARtLt") .And. !IsInCallStack("At581AlcTr"))', .F. )
		oStrTW0:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

	aAux := FwStruTrigger( 'DET_DTFIM', 'DET_DTFIM','At581Load(!IsInCallStack("At581ARtLt") .And. !IsInCallStack("At581AlcTr"))', .F. )
		oStrTW0:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

	aAux := FwStruTrigger( 'TW0_ATEND', 'TW0_NOME','Posicione("AA1",1,xFilial("AA1")+FwFldGet("TW0_ATEND"),"AA1_NOMTEC")', .F. )
		oStrTW0:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

	oStrTW1:AddField(STR0227,STR0227,"TW1_STATUS","BT",1,0,{||At581LgCob("TW1_STATUS")} ,/*bWhen*/, /*aValues*/,.F.,{|| "BR_VERMELHO"},/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Status"
	oStrABB:AddField(STR0227,STR0227,"ABB_STATUS","BT",1,0,{||At581LgCob("ABB_STATUS")} ,/*bWhen*/, /*aValues*/,.F.,,/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Status"
	oStrABB:AddField(STR0228,STR0228,"ABB_DTREF","D",8,0,/*bValid*/,/*bWhen*/, /*aValues*/,.F.,/*bINIT*/,/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Data Ref."
	oStrABB:AddField(STR0229,STR0229,"ABB_SEMANA","C",15,0,/*bValid*/,/*bWhen*/, /*aValues*/,.F.,/*bINIT*/,/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Dia Semana"
	oStrABB:AddField(STR0230,STR0230,"ABB_HRINI","C",5,0,/*bValid*/,/*bWhen*/, /*aValues*/,.F.,/*bINIT*/,/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Hora Ini."
	oStrABB:AddField(STR0231,STR0231,"ABB_HRFIM","C",5,0,/*bValid*/,/*bWhen*/, /*aValues*/,.F.,/*bINIT*/,/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Hora Fin."
	oStrABB:AddField(STR0232,STR0232,"ABB_SEQ","C",2,0,/*bValid*/,/*bWhen*/, /*aValues*/,.F.,/*bINIT*/,/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Sequência"
	oStrABB:AddField(STR0233,STR0233,"ABB_DSCONF","C",35,0,/*bValid*/,/*bWhen*/, /*aValues*/,.F.,/*bINIT*/,/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Desc. Conflito"
	If TW0->(ColumnPos("TW0_VAGA") > 0)
		oStrTW0:SetProperty("TW0_VAGA",    MODEL_FIELD_WHEN,  {||.F.})
	Endif
Endif

If TW1->(ColumnPos("TW1_FILTFF") > 0)
	aAux := FwStruTrigger( 'TW1_CODTFF', 'TW1_FILTFF','TFF->TFF_FILIAL', .T., "TFF", 1, 'xFilial("TFF")+FwFldGet("TW1_CODTFF")')
	oStrTW1:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4]) 
Endif

oModel := MPFormModel():New("TECA581", /*bPreValidacao*/, bPosValid, bCommit, /*bCancel*/ )
oModel:AddFields("TW0MASTER", /*cOwner*/, oStrTW0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Relacionamento das tabelas
oModel:AddGrid("TW1DETAIL", "TW0MASTER", oStrTW1,bLinePre, bLinePost,/*bPreVal*/ , , /*bLoad*/)
oModel:SetRelation("TW1DETAIL", {{"TW1_FILIAL", "xFilial('TW0')"}, {"TW1_CODTW0", "TW0_COD"}}, TW1->(IndexKey(1)))

If lMvGsRota
	oModel:AddGrid("ABBDETAIL", "TW1DETAIL", oStrABB )
	oModel:GetModel('ABBDETAIL'):SetDescription("Agendas")	//"Agendas"
	oModel:GetModel('ABBDETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel("ABBDETAIL"):SetOptional(.T.)
	oModel:GetModel("TW1DETAIL"):SetOptional(.T.)
Endif

oModel:GetModel('TW0MASTER'):SetDescription(STR0001)	//"Rota de Cobertura"
oModel:GetModel('TW1DETAIL'):SetDescription("Itens")	//"Itens"

oStrTW0:SetProperty("TW0_COD",    MODEL_FIELD_WHEN,  {||.F.})
oStrTW1:SetProperty("TW1_COD",    MODEL_FIELD_WHEN,  {||.F.})
oStrTW1:SetProperty("TW1_CODTFF", MODEL_FIELD_VALID, {|oModTW1| At581VlTFF(oModTW1)})
oStrTW1:SetProperty("TW1_CODTGX", MODEL_FIELD_VALID, {|oModTW1| At581VlEsc(oModTW1)})
oStrTW1:SetProperty("TW1_GRUPO",  MODEL_FIELD_VALID, {|oModTW1| At581VlGrp(oModTW1)})
oStrTW1:SetProperty("TW1_CODTW0", MODEL_FIELD_INIT,  {|oMdl| oMdl:GetModel():GetModel("TW0MASTER"):GetValue("TW0_COD")})

If lRotaVaga
	oStrTW0:SetProperty('TW0_VAGA' ,MODEL_FIELD_VALID,{|oModel | VldRtVaga(oModel) })
	If FindFunction("At580GVMnt")
		oStrTW1:SetProperty('TW1_CODHE' ,MODEL_FIELD_VALID,{|oModel,cField,xNewValue| At580GVMnt(oModel,cField,xNewValue)})
	Endif
	oStrTW1:SetProperty('TW1_CODTDX' ,MODEL_FIELD_VALID,{|oModel| CheckTDX(oModel)})
Endif

oModel:GetModel("TW0MASTER"):SetFldNoCopy( { "TW0_DESC", "TW0_ATEND" } )
oModel:GetModel("TW1DETAIL"):SetFldNoCopy( { "TW1_COD" , "TW1_SEQ" } )

oModel:GetModel("TW1DETAIL"):SetOptional(.T.)

oModel:GetModel("TW1DETAIL"):SetUniqueLine({"TW1_CODTFF", "TW1_CODTGX", "TW1_GRUPO","TW1_TURNO","TW1_SEQ"})

oModel:SetActivate({|oModel| InitDados(oModel)})

Return oModel

//----------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description	View - Relacionamentos - Gestão de Escalas 
@sample		ViewDef()
@return		oExp1: View da Rota de cobertura
@author		Serviços
@since			19/06/2015
@version		P12
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel  := FWLoadModel("TECA581")
Local oStrTW0 := FWFormStruct(2, "TW0")
Local oStrTW1 := FWFormStruct(2, "TW1", {|cCpo| !( AllTrim(cCpo)$"TW1_CODTW0")})
Local oStrDet := Nil 
Local oStrABB := Nil
Local lTW0_TIPO := TW0->(ColumnPos("TW0_TIPO") > 0)
Local lTW1_MOV := TW0->(ColumnPos("TW1_MOV") > 0)
Local lTW1_ATDTGY := TW1->(ColumnPos("TW1_ATDTGY") > 0)
Local cSeqTipo := "99"
Local lMvGsRota := At581GsRota() .And. (IsInCallStack("At581Alc") .Or. IsInCallStack("At581ARtLt"))
Local lRotaVaga	:= At581RtVag() .And. TW0->TW0_VAGA == "1"

If lMvGsRota
	oStrDet	:= FWFormViewStruct():New()
	oStrABB := FWFormViewStruct():New()
	oStrDet:AddField("DET_DTINI","01",STR0091,STR0091,{},"D",,Nil,Nil,.T.,"",Nil,Nil,Nil,Nil,.T.,Nil) //"Per. Ini."
	oStrDet:AddField("DET_DTFIM","02",STR0092,STR0092,{},"D",,Nil,Nil,.T.,"",Nil,Nil,Nil,Nil,.T.,Nil) //"Per. Fin."
	oStrTW1:AddField("TW1_STATUS","01",STR0227,STR0227,{},"BT",,Nil,Nil,.T.,"",Nil,Nil,Nil,Nil,.T.,Nil) //"Status"
	oStrTW1:AddField("TW1_DETALH","Z5",STR0234,STR0234,{},"C",,Nil,Nil,.F.,"",Nil,Nil,Nil,Nil,.T.,Nil)  //"Detalhes"
	oStrABB:AddField("ABB_STATUS","01",STR0227,STR0227,{},"BT",,Nil,Nil,.T.,"",Nil,Nil,Nil,Nil,.T.,Nil) //"Status"
	oStrABB:AddField("ABB_DSCONF","07",STR0233,STR0233,{},"C",,Nil,Nil,.F.,"",Nil,Nil,Nil,Nil,.T.,Nil) //"Desc. Conflito"
	oStrTW0:SetProperty("TW0_ATEND" , MVC_VIEW_CANCHANGE, .T. )
	oStrTW0:SetProperty("TW0_ATEND" ,MVC_VIEW_LOOKUP, "AA1")
	oStrABB:AddField("ABB_DTREF","02",STR0228,STR0228,{},"D",,Nil,Nil,.T.,"",Nil,Nil,Nil,Nil,.T.,Nil) //"Data Ref."
	oStrABB:AddField("ABB_SEMANA","03",STR0229,STR0229,{},"C",,Nil,Nil,.T.,"",Nil,Nil,Nil,Nil,.T.,Nil) //"Dia Semana"
	oStrABB:AddField("ABB_HRINI","04",STR0230,STR0230,{},"C",,Nil,Nil,.T.,"",Nil,Nil,Nil,Nil,.T.,Nil) //"Hora Ini."
	oStrABB:AddField("ABB_HRFIM","05",STR0231,STR0231,{},"C",,Nil,Nil,.T.,"",Nil,Nil,Nil,Nil,.T.,Nil) //"Hora Fin."
	oStrABB:AddField("ABB_SEQ","06",STR0232,STR0232,{},"C",,Nil,Nil,.T.,"",Nil,Nil,Nil,Nil,.T.,Nil) // "Sequência"
Endif

If lTW0_TIPO
	cSeqTipo := oStrTW0:GetProperty('TW0_TIPO', MVC_VIEW_ORDEM)
Else
	cSeqTipo := oStrTW0:GetProperty('TW0_NOME', MVC_VIEW_ORDEM)
EndIf

oStrTW0:SetNoFolder()

oStrTW1:AddField("TW1_DTINI" ,"Z1",STR0091,STR0091,{},"D",,Nil,Nil,.F.,"",Nil,Nil,Nil,Nil,.T.,Nil)
oStrTW1:AddField("TW1_DTFIM" ,"Z2",STR0092,STR0092,{},"D",,Nil,Nil,.F.,"",Nil,Nil,Nil,Nil,.T.,Nil)
oStrTW1:SetProperty("TW1_HORINI", MVC_VIEW_ORDEM, "Z3")
oStrTW1:SetProperty("TW1_HORFIM", MVC_VIEW_ORDEM, "Z4")

If lTW1_MOV
	oStrTW1:RemoveField("TW1_MOV")
EndIf

If lTW1_ATDTGY .AND. !TecXHasEdH()
	oStrTW1:RemoveField("TW1_ATDTGY")
EndIf

oView	:= FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_TW0", oStrTW0, 'TW0MASTER')
oView:AddGrid("VIEW_TW1", oStrTW1 , 'TW1DETAIL')

If lMvGsRota
	oView:AddField("VIEW_DET", oStrDet, 'TW0MASTER')
	oView:AddGrid("VIEW_ABB" , oStrABB, 'ABBDETAIL')

	oView:CreateHorizontalBox("SUPERIOR" , 30)
	oView:CreateHorizontalBox("INFERIOR1", 25)
	oView:CreateHorizontalBox('INFERIOR2', 20)
	oView:CreateHorizontalBox("INFERIOR3", 25)

	oView:SetOwnerView("VIEW_DET", "INFERIOR2")
	oView:SetOwnerView("VIEW_ABB", "INFERIOR3")
	If !lRotaVaga
		If !IsInCallStack("At581AlcTr")
			oView:AddOtherObject("PROJETAR",{|oPanel| at581ExPj(oPanel) })
			oView:SetOwnerView("PROJETAR","INFERIOR2")
		Endif
		oView:AddOtherObject("GRAVAR",{|oPanel| at581ExGv(oPanel) })
		oView:SetOwnerView("GRAVAR","INFERIOR2")
	Endif
	oView:EnableTitleView("VIEW_DET", "Agendas") //"Agenda"
Else
	oView:CreateHorizontalBox("SUPERIOR" , 30)
	oView:CreateHorizontalBox("INFERIOR1", 70)
Endif

oView:SetOwnerView("VIEW_TW0", "SUPERIOR")
oView:SetOwnerView("VIEW_TW1", "INFERIOR1")

oView:EnableTitleView('VIEW_TW0',"Atendente") //"Atendente"
oView:EnableTitleView('VIEW_TW1',"Postos") //"Posto"

If !lMvGsRota
	oView:AddUserButton(STR0002, STR0002, {|oView| At581FilRegiao()}) // "Filtra Região" ## "Filtra Região"
	oView:AddUserButton(STR0003, STR0003, {|oView| At581PostoFun()})  // "Vis. Posto X Func." ## "Vis. Posto X Func."
Endif

Return oView
//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
@description	Inicializa as informações de status dos contratos
@sample		InitDados(oMdlGer)
@param			oExp1: Objeto geral do model que será alterado
@return		Nil 
@author		Serviços
@since			07/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oMdlGer)

Local oMdlTW1	:= oMdlGer:GetModel('TW1DETAIL')
Local oMdlTW0	:= oMdlGer:GetModel('TW0MASTER')
Local aSaveRows	:= {}
Local aDatasTW1 := {}
Local nI		:= 0
Local cCodTFF	:= ""
Local cLocal	:= ""
Local cABSDescr	:= ""
Local cCodTDW	:= ""
Local cEscala	:= ""
Local cRegiao	:= ""
Local cCodSup	:= ""
Local cNomSup	:= ""
Local cFilBkp	:= cFilAnt
Local cComTW1 	:= FwModeAccess("TW1",1) +  FwModeAccess("TW1",2) + FwModeAccess("TW1",3)
Local cComTGZ 	:= FwModeAccess("TGZ",1) +  FwModeAccess("TGZ",2) + FwModeAccess("TGZ",3)
Local cComTFF	:= FwModeAccess("TFF",1) +  FwModeAccess("TFF",2) + FwModeAccess("TFF",3)
Local lFilTff	:= TW1->(ColumnPos("TW1_FILTFF") > 0)
Local lMtFIl	:= cComTFF == "EEE" .AND. (LEN(STRTRAN( cComTW1  , "E" )) > LEN(STRTRAN(  cComTGZ  , "E" ))) .AND. lFilTff
Local lMvGsRota := At581GsRota() .And. IsInCallStack("At581Alc")
Local oStrTW0	:= Nil
Local oStrTW1	:= Nil
Local oStrABB	:= Nil

If	oMdlGer:GetOperation() == MODEL_OPERATION_UPDATE .OR.;
	oMdlGer:GetOperation() == MODEL_OPERATION_VIEW .OR. oMdlGer:GetOperation() == MODEL_OPERATION_INSERT
	
	// Esse próximo looping de inicializador dos campos da tabela TW1 deverá ser executado apenas quando a operação 
	// do modelo (MVC)  estiver definido como ALTERAÇÃO ou VISUALIZAÇÃO.  O tratamento para a inicialização  desses 
	// campos da tabela TW1 para a operação de EXCLUSÃO está sendo realizado no controle do dicionário de dados SX3 
	// e a função At581GInit(), pois na operação de EXCLUSÃO não são permitidos os métodos SETVALUE e LOADVALUE.
	aSaveRows	:= FwSaveRows()
	For nI := 1 to oMdlTW1:Length()
		oMdlTW1:GoLine(nI)
		cCodTFF	:= oMdlTW1:GetValue("TW1_CODTFF")
		If lMtFIl .AND. !EMPTY(oMdlTW1:GetValue("TW1_FILTFF"))
			cFilAnt := oMdlTW1:GetValue("TW1_FILTFF")
		EndIf
		If !Empty(cCodTFF)
			cLocal		:= Posicione("TFF",1,xFilial("TFF")+cCodTFF,"TFF_LOCAL")
			cABSDescr	:= Posicione("ABS",1,xFilial("ABS")+cLocal, "ABS_DESCRI")
			cCodTDW	:= Posicione("TFF",1,xFilial("TFF")+cCodTFF,"TFF_ESCALA")
			cEscala	:= Posicione("TDW",1,xFilial("TDW")+cCodTDW,"TDW_DESC")
			cRegiao	:= Posicione("ABS",1,xFilial("ABS")+cLocal, "ABS_REGIAO")
			cCodSup	:= Posicione("TGS",3,xFilial("TGS")+cRegiao,"TGS_SUPERV")
			cNomSup	:= Posicione("AA1",1,xFilial("AA1")+cCodSup,"AA1_NOMTEC")
			If	oMdlGer:GetOperation() == MODEL_OPERATION_UPDATE
				oMdlTW1:SetValue("TW1_CODABS", cLocal)			//Local
				oMdlTW1:SetValue("TW1_LOCAL",  cABSDescr)		//Descrição do local
				oMdlTW1:SetValue("TW1_CODTDW", cCodTDW)		//Código da escala
				oMdlTW1:SetValue("TW1_ESCALA", cEscala)		//Descrição da escala
				oMdlTW1:SetValue("TW1_CODSUP", cCodSup)		//Código do supervisor
				oMdlTW1:SetValue("TW1_SUPERV", cNomSup)		//Nome do supervisor
			Else
				oMdlTW1:LoadValue("TW1_CODABS", cLocal)		//Local
				oMdlTW1:LoadValue("TW1_LOCAL",  cABSDescr)	//Descrição do local
				oMdlTW1:LoadValue("TW1_CODTDW", cCodTDW)		//Código da escala
				oMdlTW1:LoadValue("TW1_ESCALA", cEscala)		//Descrição da escala
				oMdlTW1:LoadValue("TW1_CODSUP", cCodSup)		//Código do supervisor
				oMdlTW1:LoadValue("TW1_SUPERV", cNomSup)		//Nome do supervisor
			EndIf

			aDatasTW1 := RetDtRota(cCodTFF,;
						oMdlTW0:GetValue("TW0_COD"),;
						oMdlTW0:GetValue("TW0_ATEND"),;
						oMdlTW1:GetValue("TW1_CODTGX"),;
						cCodTDW,;
						IIF(lFilTff , oMdlTW1:GetValue("TW1_FILTFF"), xFilial("TFF")) )

			oMdlTW1:LoadValue("TW1_DTINI", aDatasTW1[1])
			oMdlTW1:LoadValue("TW1_DTFIM", aDatasTW1[2])
		EndIf
	Next nI
	FwRestRows(aSaveRows)
EndIf

If lMvGsRota
	oMdlGer:GetModel("ABBDETAIL"):SetNoInsertLine(.F.)
	oMdlGer:GetModel("ABBDETAIL"):SetNoDeleteLine(.F.)
	oStrTW0 := oMdlGer:GetModel("TW0MASTER"):GetStruct()
	oStrTW1 := oMdlGer:GetModel("TW1DETAIL"):GetStruct()
	oStrABB := oMdlGer:GetModel("ABBDETAIL"):GetStruct()
	oStrTW0:SetProperty("TW0_ATEND",MODEL_FIELD_WHEN, {|oMdl| aT581WhAtd(oMdl:GetModel():GetModel("TW0MASTER"):GetValue("TW0_COD")) } )
	oStrTW0:SetProperty("TW0_DESC", MODEL_FIELD_WHEN,  {|| .F. })
	oStrTW1:SetProperty('*' ,MODEL_FIELD_WHEN,{|| .F. })
	oStrTW1:SetProperty("TW1_STATUS" ,MODEL_FIELD_WHEN,{|| .T. })
	oStrTW1:SetProperty("TW1_DETALH" ,MODEL_FIELD_WHEN,{|| .T. })
 	oStrABB:SetProperty('*' ,MODEL_FIELD_WHEN,{|| .F. })
	oStrABB:SetProperty("ABB_STATUS" ,MODEL_FIELD_WHEN,{|| .T. })
	oStrABB:SetProperty("ABB_DSCONF" ,MODEL_FIELD_WHEN,{|| .T. })
	oMdlGer:GetModel("TW1DETAIL"):SetNoInsertLine(.T.)
	oMdlGer:GetModel("TW1DETAIL"):SetNoDeleteLine(.T.)
	oMdlGer:GetModel("ABBDETAIL"):SetNoInsertLine(.T.)
	oMdlGer:GetModel("ABBDETAIL"):SetNoDeleteLine(.T.)
Endif

cFilAnt := cFilBkp

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581GInit
@description	Inicializa as informações dos detalhes da rota de cobertura para a operação de EXCLUSÃO
@sample		At581GInit(cCampo)
@param			cExp1: Campo a ser inicializado com o conteúdo
@return		cExp1: Conteúdo do inicializador do campo a ser exibido ao usuário
@author		Serviços
@since			07/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function At581GInit(cCampo)
Local oMdlGer	:= FwModelActive()
Local xAux		:= ""
Local cRet		:= ""

Default cCampo	:= ""

If	oMdlGer:GetOperation() == MODEL_OPERATION_DELETE
	// Esses inicializadores dos campos da tabela TW1 deverá ser executado apenas quando a operação do modelo (MVC) 
	// estiver definido como EXCLUSÃO,  pois quando a mesma dor ALTERAÇÃO ou VISUALIZAÇÃO,  o preenchimento  desses
	// campos estão sendo realizados pela InitDados()
	Do Case
		Case	cCampo == "TW1_LOCAL"
			xAux	:= Posicione("TFF",1,xFilial("TFF")+TW1->TW1_CODTFF,"TFF_LOCAL")
			cRet	:= Posicione("ABS",1,xFilial("ABS")+xAux,           "ABS_DESCRI")
		Case	cCampo == "TW1_ESCALA"
			xAux	:= Posicione("TFF",1,xFilial("TFF")+TW1->TW1_CODTFF,"TFF_ESCALA")
			cRet	:= Posicione("TDW",1,xFilial("TDW")+xAux,           "TDW_DESC")
		Case	cCampo == "TW1_CODSUP"
			xAux	:= Posicione("TFF",1,xFilial("TFF")+TW1->TW1_CODTFF,"TFF_LOCAL")
			xAux	:= Posicione("ABS",1,xFilial("ABS")+xAux,           "ABS_REGIAO")
			cRet	:= Posicione("TGS",3,xFilial("TGS")+xAux,           "TGS_SUPERV")
		Case	cCampo == "TW1_SUPERV"
			xAux	:= At581GInit("TW1_CODSUP")
			cRet	:= Posicione("AA1",1,xFilial("AA1")+xAux,"AA1_NOMTEC")
	EndCase
EndIf

Return cRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} At581PLine
@description	Pré-Validação das linhas da rota de cobertura
@sample			At581PLine(oModel,nLine,cAcao,cCampo)

@return			lExp1: .T.=Pré-validação do modelo OK // .F.=Pré-validação do modelo possui inconsistências
@author			Serviços
@since			01/20/2019
/*/
//------------------------------------------------------------------------------
Function At581PLine(oModel,nLine,cAcao,cCampo, xValue, xOldValue)
Local lRet		:= .T.
Local aAreaTFF	:= TFF->(GetArea())
Local cContrt	:= ""
Local cCodTFF	:= oModel:GetValue("TW1_CODTFF")
Local cMov		:= IIF( TW1->(ColumnPos("TW1_MOV")) > 0, oModel:GetValue("TW1_MOV"), "")
Local cMsg		:= ""

//Não permite deletar linhas onde a TFF está em revisão
If oModel:GetOperation() == MODEL_OPERATION_UPDATE 
	If cAcao == 'DELETE' 
		If cMov == "2"
			cContrt := Posicione("TFF",1,xFilial("TFF")+cCodTFF,"TFF_CONTRT")
			If At580BSit(cContrt) == "2"
				cMsg := STR0094 //"Não é permitida a exclusão de um item em revisão"
				lRet	:= .F.
			EndIf
		ElseIf cMov == "1"
			lRet := .F.
			cMsg := STR0113 //"Não é possivel excluir uma linha já movimentada"
		EndIf	
	ElseIf cAcao == "CANSETVALUE" .And. cMov == "1"
		If !(cCampo $ "TW1_CODHE|TW1_CODTDX")
			lRet := .F.
			cMsg := STR0114 //"Não é possivel alterar uma linha já movimentada"
		Endif
	EndIf
	
EndIf

If !lRet
	Help( ,, "At581PLine",, cMsg, 1, 0 )					
EndIf

RestArea(aAreaTFF)

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} At581PosVl
@description	Movimentação ou Remoção da rota de cobertura
@sample		At581PosVl(oModel)
@param			oExp1: Objeto geral do model que será alterado
@return		lExp1: .T.=Pós-validação do modelo OK // .F.=Pós-validação do modelo possui inconsistências
@author		Serviços
@since			15/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function At581PosVl(oModel)
Local oMdlTW0	:= oModel:GetModel("TW0MASTER")	
Local cRota		:= oMdlTW0:GetValue("TW0_COD")
Local cCodTec	:= oMdlTW0:GetValue("TW0_ATEND")
Local cTmpQry	:= ""
Local lRet		:= .T.
Local lRotaVaga := At581RtVag() .And. oMdlTW0:GetValue("TW0_VAGA") == "1"
Local oMdlTW1	:= oModel:GetModel("TW1DETAIL")	
Local nX		:= 0

If oModel:GetOperation() == MODEL_OPERATION_DELETE

	// Verifica se a rota de cobertura está sendo utilizada por alguma gestão de escalas
	cTmpQry	:= GetNextAlias()
	BeginSql Alias cTmpQry
		SELECT count(*) as REGTGZ
		  FROM %table:TGZ% TGZ
		 WHERE TGZ.TGZ_FILIAL = %xFilial:TGZ%
		   AND TGZ.%NotDel%
		   AND TGZ.TGZ_CODTW0 = %Exp:cRota% 
	EndSql
	If (cTmpQry)->REGTGZ > 0 //Foram encontrados registros de cobertura na Gestão de Escalas que participam do histórico da rota de cobertura
		Help( ,, "At581PosVl",, STR0037, 1, 0 ) // "Não é permitida a exclusão de uma rota de cobertura que tenha sido utilizada em alguma Gestão de Escalas."
		lRet	:= .F.
	EndIf
	
	(cTmpQry)->(DbCloseArea())

	If	lRet
		// Verifica se a rota de cobertura possui um atendente associado
		If	!( Empty(cCodTec) )
			Help( ,, "At581PosVl",, STR0038, 1, 0 ) // "Não é permitida a exclusão de uma rota de cobertura que possua um atendente associado a ela."
			lRet	:= .F.
		EndIf
	EndIf
EndIf

If lRet .And. lRotaVaga
	For nX := 1 To oMdlTW1:Length()
		oMdlTW1:GoLine(nX)
		If Empty(oMdlTW1:GetValue("TW1_CODHE")) .Or. Empty(oMdlTW1:GetValue("TW1_CODTDX")) 
			Help( ,, "At581PosVl",, STR0260, 2 ) // "Não é permitida a exclusão de uma rota de cobertura que possua um atendente associado a ela."
			lRet	:= .F.
			Exit
		Endif
	Next nX
Endif

Return	lRet


//-----------------------------------------------------------------------------
/*/{Protheus.doc} At581MvRmv
@description	Movimentação ou Remoção da rota de cobertura
@sample		At581MvRmv(cTpOper, cRota, cAtuAtend)
@param			cExp1: Tipo de operação ("MV"=Movimentação p/rota de cobertura, ou "RE"=Remoção da rota de cobertura)
@param			cExp2: Rota em que o atendente estará ou está alocado
@param			cExp3: Código do atendente
@return		lExp1: .T.=Processamento realizado // .F.=Processamento não realizado 
@author		Serviços
@since			07/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function At581MvRmv(cTpOper, cRota, cAtuAtend, lAutomato, cAtend, dDtIniRt,dDtFimRt, dDtIniTGZ, dDtFimTGZ)

Local cAtdMvRmv	:= CriaVar("AA1_CODTEC", .F.)
Local cPictAtd	:= PesqPict("AA1", "AA1_CODTEC")
Local oDlg		:= ""
Local cTitulo	:= ""
Local cDesAten	:= ""
Local lWhenAtd	:= .F.
Local lOk		:= .F.
Local lRet		:= .T.
Local aDtIniFim := {sTod(""),sTod("")}
Local cMsg		:= ""
Local lStatus 	:= TW0->( ColumnPos('TW0_STATUS')) > 0
Local cStatus	:= Iif(lStatus,TW0->TW0_STATUS,"")
Local lRotaVaga	:= At581RtVag()

Default cTpOper		:= "MV"
Default cRota		:= TW0->TW0_COD
Default cAtuAtend	:= TW0->TW0_ATEND
Default lAutomato 	:= .F.
Default cAtend		:= ""
Default	dDtIniRt	:= CriaVar("TGZ_DTINI" , .F.)
Default dDtFimRt	:= CriaVar("TGZ_DTFIM" , .F.)
Default dDtIniTGZ	:= CriaVar("TGZ_DTINI" , .F.)
Default dDtFimTGZ 	:= CriaVar("TGZ_DTFIM" , .F.)

If cTpOper == "MV"
	If !lStatus .Or. (Empty(cStatus).Or.cStatus == DEF_TW0_ATIVO)
		lWhenAtd	:= .T.
		cTitulo	:= STR0022	//"Movimentação da Rota de Cobertura"
	Else 
		cMsg := STR0125 //"Não é possivel movimentar rotas inativas"
		lRet := .F.
	EndIf 
ElseIf cTpOper == "TR"
	If !lStatus .Or. (Empty(cStatus).Or.cStatus == DEF_TW0_ATIVO)
		If lRotaVaga .And. TW0->TW0_VAGA == "1"
			lWhenAtd := .T.
			cTitulo	 := STR0261 //"Reativação da Rota de Cobertura"
		Else
			lWhenAtd	:= .F.
			cTitulo	:= STR0116 //"Troca de atendente da Rota de Cobertura"
		Endif
	Else 
		cMsg := STR0126 //"Não é possivel troca de atendentes para rotas inativas"
		lRet := .F.
	EndIf 
Else
	If Empty(cAtuAtend)
		cMsg := STR0095
		lRet := .F.
	Endif
	lWhenAtd  := .F.
	If cTpOper == "RE"
		cTitulo	  := STR0029 //"Remoção da Rota de Cobertura"
	Else
		cTitulo	  := STR0096 //"Cancelamento de Agenda na Rota de Cobertura"
	EndIf	
EndIf

If lRet
	If !Empty(cAtuAtend)
		aDtIniFim := At581DtCob(cRota,cAtuAtend)
		dDtIniRt  := aDtIniFim[1]
		dDtFimRt  := aDtIniFim[2]
		dDtIniTGZ := aDtIniFim[1]
		dDtFimTGZ := aDtIniFim[2]

		cAtdMvRmv	:= cAtuAtend
		cDesAten	:= Posicione("AA1", 1, xFilial("AA1")+cAtdMvRmv, "AA1_NOMTEC")
	EndIf
	
	If !lAutomato
		Define Dialog oDlg Title cTitulo From 000,000 to 220,540 Pixel

			@ 005,005 Say "Data Início" of oDlg Pixel //"Data Início:"
			@ 005,045 MsGet dDtIniRt 	Size 50,0 When iif((cTpOper == "TR" .And. !Empty(cAtuAtend)) .OR. cTpOper == "CA",.T.,lWhenAtd) of oDlg Pixel

			@ 025,005 Say "Data Final" 	of oDlg Pixel //"Data Final:"
			@ 025,045 MsGet dDtFimRt 	Size 50,0 When iif(cTpOper == "CA",.T.,lWhenAtd) of oDlg Pixel
			@ 045,005 Say "Cod. Atend." of oDlg Pixel //"Cod. Atend."
			@ 045,045 MsGet cAtdMvRmv Picture cPictAtd F3 "AA1" Valid IIf(!Empty(cAtdMvRmv) .And. ExistCpo("AA1", cAtdMvRmv),;
		                                                            Eval({|| cDesAten := Posicione("AA1", 1, xFilial("AA1")+cAtdMvRmv, "AA1_NOMTEC"),;
		                                                                     oDesAten:Refresh()}),;
		                                                                     "") When iif(cTpOper == "TR" .And. !Empty(cAtuAtend),.T.,(lWhenAtd .And. Empty(aDtIniFim[1]))) of oDlg Pixel
			@ 065,005 Say "Nome Atend." of oDlg Pixel //Nome Atend.
			@ 065,045 MsGet oDesAten Var cDesAten Size 210,0 When .F. of oDlg Pixel

			Define SButton From 085,200 Type 1 Enable of oDlg Action ( lOk := !Empty(cAtdMvRmv), lOk := lOK .AND. At581Eftv(cTpOper, cRota, dDatabase, cAtdMvRmv, lAutomato, dDtIniRt,dDtFimRt, dDtIniTGZ, dDtFimTGZ,cDesAten), Iif( lOk, oDlg:End(), lOk := .F. ) )
			Define SButton From 085,230 Type 2 Enable of oDlg Action ( lOk := .F., oDlg:End() )

		Activate Dialog oDlg Centered
	Else 
		cDesAten := Posicione("AA1", 1, xFilial("AA1")+cAtend, "AA1_NOMTEC")
		cAtdMvRmv := cAtend
		lOk := .T.
	EndIf
	
	If	lOk
		If	cTpOper == "RE" .AND. Empty(cAtdMvRmv)
			Help( ,, "At581MvRmv",, STR0028, 1, 0 ) //"Não existe atendente preenchido na rota de cobertura. Remoção permitida apenas para rotas que já tenham atendente"
			lRet	:= .F.
		Else
			If lAutomato
				( lRet := At581Efet(cTpOper, cRota, dDatabase, cAtdMvRmv, lAutomato, dDtIniRt,dDtFimRt, dDtIniTGZ, dDtFimTGZ,cDesAten) )
			EndIf
		Endif
	EndIf
Else 
	Help(,, "At581MvRmv",, cMsg, 1, 0 ) 
Endif

Return lRet

//------------------------------------------------------------------------
/*/{Protheus.doc} At581F3TFF
@description	Montagem da consulta específica para o campo TW1_CODTFF (Código RH)
@sample			At581F3TFF()
@return			lExp1: .T.=Registro selecionado na consulta específica // .F.=Registro não selecionado na consulta específica. 
@author			Serviços
@since			03/08/2015 
@version		P12
/*/
//---------------------------
Function At581F3TFF()

Local oMdl		:= FWModelActive()
Local cRegiao	:= At670FilSql(__cUserId, .F., 'SX5', 'A2_')	//Buscar Query do filtro da região
Local cFilReg	:= If(Empty(cRegiao), "%%", "%"+cRegiao+"%")
Local cTitCodTFF:= AllTrim(Posicione("SX3",2,"TW1_CODTFF","X3Titulo()"))
Local cTmpTFF	:= ""
Local aHeader	:= {}
Local aCmpTFF	:= {}
Local lOk		:= .F.
Local oDlgTFF 	//Dialog
Local oPanel 	//Objeto Panel
Local oFooter	//Rodapé
Local oListBox	//Grid campos
Local oOk		//Objeto Confirma
Local oCancel	//Objeto Cancel
Local oMdlTW0	:= oMdl:GetModel("TW0MASTER")
Local lTW0_TIPO := TW0->(ColumnPos("TW0_TIPO")) > 0
Local cTipo		:= IIF(lTW0_TIPO, oMdlTW0:GetValue("TW0_TIPO"), "")
Local dData		:= dDataBase
Local cExpTipo  := " AND TGX.TGX_TIPO = '" + cTipo + "' "
Local lFilTff	:= TW1->(ColumnPos("TW1_FILTFF") > 0)
Local cExpGerVag := "AND TFF.TFF_GERVAG != 2"

If lTW0_TIPO
	cExpTipo := "% " + cExpTipo + "%"
Else
	cExpTipo := "% %"
EndIf

If TecBHasGvg()
	cExpGerVag := "% " + cExpGerVag + "%"
Else
	cExpGerVag := "% %"
EndIf

//montar query
TFF->(DbSetOrder(2)) //TFF_FILIAL+TFF_LOCAL
cTmpTFF	:= GetNextAlias()
BeginSql Alias cTmpTFF
	SELECT DISTINCT TFF.TFF_FILIAL, TFF.TFF_COD, TFF.TFF_LOCAL, TFF.TFF_CONTRT,
	                ABS.ABS_DESCRI, TFF.TFF_PRODUT, SB1.B1_DESC, TFF.TFF_ESCALA, 
	                TDW.TDW_DESC 
	  FROM %table:TFF% TFF
	       Inner join %table:TDW% TDW ON TDW.TDW_FILIAL = %xFilial:TDW%
	                                 AND TDW.%NotDel%
	                                 AND TDW.TDW_COD = TFF.TFF_ESCALA
	       Inner join %table:TGX% TGX ON TGX.TGX_FILIAL = %xFilial:TGX%
	                                 AND TGX.%NotDel%
	                                 AND TGX.TGX_CODTDW = TDW.TDW_COD
	       Inner join %table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
	                                 AND SB1.%NotDel%
	                                 AND SB1.B1_COD = TFF.TFF_PRODUT
	       Inner join %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%
	                                 AND ABS.%NotDel%
	                                 AND ABS.ABS_LOCAL = TFF.TFF_LOCAL
	       Left join  %table:SX5% SX5 ON SX5.X5_FILIAL = %xFilial:SX5%
	                                 AND SX5.%NotDel%
	                                 AND SX5.X5_TABELA = 'A2'
	                                 AND SX5.X5_CHAVE = ABS.ABS_REGIAO
	 WHERE TFF.TFF_FILIAL = %xFilial:TFF%
	   %Exp:cExpTipo%
	   AND TFF.TFF_ENCE   <> '1'
	   AND TFF.TFF_CODSUB = ' '
	   %Exp:cExpGerVag%
	   AND TFF.%NotDel%
	   %Exp:cFilReg%
	   AND EXISTS ( SELECT 1 FROM  %Table:TGY% TGY
                    WHERE TGY.TGY_FILIAL   = %xFilial:TGY%
                        AND TGY.TGY_CODTFF = TFF.TFF_COD
                        AND %Exp:dData% BETWEEN TGY.TGY_DTINI AND TGY.TGY_DTFIM
                        AND TGY.TGY_ULTALO <> %Exp:sTod("")%
                        AND TGY.%NotDel%)

	 ORDER BY %Order:TFF%
EndSql

DbSelectArea(cTmpTFF)
While (cTmpTFF)->(! Eof())
	If lFilTff
		aAdd(aCmpTFF,{	(cTmpTFF)->TFF_FILIAL,; //FIlial
						(cTmpTFF)->TFF_COD,;	//itemRh
						(cTmpTFF)->TFF_CONTRT,;	//Codigo do Contrato
						(cTmpTFF)->TFF_LOCAL,;	//local
						(cTmpTFF)->ABS_DESCRI,;	//descricao local
						(cTmpTFF)->TFF_PRODUT,;	//produto
						(cTmpTFF)->B1_DESC,;	//desc. prodtuto
						(cTmpTFF)->TFF_ESCALA,;	//escala
						(cTmpTFF)->TDW_DESC,;	//desc. escala
						""})

	Else
		aAdd(aCmpTFF,{	(cTmpTFF)->TFF_COD,;	//itemRh
						(cTmpTFF)->TFF_CONTRT,;	//Codigo do Contrato
						(cTmpTFF)->TFF_LOCAL,;	//local
						(cTmpTFF)->ABS_DESCRI,;	//descricao local
						(cTmpTFF)->TFF_PRODUT,;	//produto
						(cTmpTFF)->B1_DESC,;	//desc. prodtuto
						(cTmpTFF)->TFF_ESCALA,;	//escala
						(cTmpTFF)->TDW_DESC,;	//desc. escala
						""})
	Endif

	(cTmpTFF)->(DbSkip())
Enddo
(cTmpTFF)->(DbCloseArea())

//Verificar se existe ifnormação para o filtro
If len(aCmpTFF) > 0
	lOk := .T.
	//	Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela 
	Define MsDialog oDlgTFF Title cTitCodTFF From 000, 000 To 300, 800 Pixel

		//Cria o panel principal
		@ 000, 000 MsPanel oPanel Of oDlgTFF Size 350, 550 // Coordenada para o panel
		oPanel:Align	:= CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

		If lFilTff
			aHeader		:= {STR0117,STR0004,STR0112, STR0005, STR0006, STR0007, STR0008, STR0009, STR0010} //"Filial"#"Item RH"#"Nr. Contrato"#"Local"#"Desc. Local"#"Produto"#"Desc. Produto"#"Escala"#"Desc. Escala"
		Else		
			aHeader		:= {STR0004,STR0112, STR0005, STR0006, STR0007, STR0008, STR0009, STR0010} //"Item RH"#"Nr. Contrato"#"Local"#"Desc. Local"#"Produto"#"Desc. Produto"#"Escala"#"Desc. Escala"
		Endif

		// Criação do grid para o panel	
		oListBox		:= TWBrowse():New( 40,05,204,100, ,aHeader,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,) // Campo#Descricao
		oListBox:SetArray(aCmpTFF) // Atrela os dados do grid com a matriz
		
		If lFilTff
		
			oListBox:bLine		:= {|| {	aCmpTFF[oListBox:nAT][1],;
											aCmpTFF[oListBox:nAT][2],;
											aCmpTFF[oListBox:nAT][3],;
											aCmpTFF[oListBox:nAT][4],;
											aCmpTFF[oListBox:nAT][5],;
											aCmpTFF[oListBox:nAT][6],;
											aCmpTFF[oListBox:nAT][7],;
											aCmpTFF[oListBox:nAT][8],;
											aCmpTFF[oListBox:nAT][9]}} // Indica as linhas do grid
		Else
		
			oListBox:bLine		:= {|| {	aCmpTFF[oListBox:nAT][1],;
											aCmpTFF[oListBox:nAT][2],;
											aCmpTFF[oListBox:nAT][3],;
											aCmpTFF[oListBox:nAT][4],;
											aCmpTFF[oListBox:nAT][5],;
											aCmpTFF[oListBox:nAT][6],;
											aCmpTFF[oListBox:nAT][7],;
											aCmpTFF[oListBox:nAT][8]}} // Indica as linhas do grid
		Endif
		
		oListBox:bLDblClick	:= {|| Eval(oOk:bAction), oDlgTFF:End()} // Duplo clique executa a ação do objeto indicado
		oListBox:Align		:= CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse

		// Cria o panel para os botoes	
		@ 000, 000 MsPanel oFooter Of oDlgTFF Size 000, 010 // Corrdenada para o panel dos botoes (size)
		oFooter:Align	:= CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)

		// Botoes para o grid auxiliar	
		@ 000, 000 Button oCancel Prompt STR0011  Of oFooter Size 030, 000 Pixel //Cancelar
		oCancel:bAction	:= {|| lOk := .F., oDlgTFF:End() }
		oCancel:Align		:= CONTROL_ALIGN_RIGHT

		@ 000, 000 Button oOk     Prompt STR0012 Of oFooter Size 030, 000 Pixel //Confirmar

		If lFilTff
			oOk:bAction		:= {|| lOk := .T., cRetCodTFF := aCmpTFF[oListBox:nAT][2], oDlgTFF:End() } // Acao ao clicar no botao
		Else
			oOk:bAction		:= {|| lOk := .T., cRetCodTFF := aCmpTFF[oListBox:nAT][1], oDlgTFF:End() } // Acao ao clicar no botao
		Endif
		
		oOk:Align			:= CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel

	// Ativa a tela exibindo conforme a coordenada
	Activate MsDialog oDlgTFF Centered

Else
	Help( , , "At581F3TFF", , STR0097, 1, 0 ) //"Não existe informação para essa consulta."
	lOk := .F.
EndIf

Return lOk


//---------------------------------------------
/*/{Protheus.doc} At581GF3TFF 
@description	Retornar o código do item selecionado no browser. 
@sample		At581GF3TFF()
@return		cExp1: Retornará o 'Código RH' selecionado na consulta padrão. 
@author		Serviços
@since			25/06/2015 
@version		P12
/*/
//---------------------------------------------
Function At581GF3TFF()

Return cRetCodTFF

//-----------------------------------------------------------------
/*/{Protheus.doc} At581FilRegiao 
@description	Apresentar a tela de filtro das regiões
@sample		At581FilRegiao()
@return		NIL
@author		Serviços
@since			25/06/2015 
@version		P12
/*/
//--------------------------------------------------------------------
Function At581FilRegiao()

Local aParams	:= {}
Local lUseCombo	:= .F.

//Carrega as regiões do usuário
aParams	:= {'SX5', 'A2_', 'Região', 1, 'X5_FILIAL+X5_TABELA+X5_CHAVE', 'A2', {{'SX5', 1, 'X5_DESCRI'}}, {}, {||.F.}, 'A2', /*VldExtra*/ }  // 'Região'

TECA670(aParams, lUseCombo)

Return


//--------------------------------------------------------------------
/*/{Protheus.doc} At581PostoFun 
@description	Relação de Posto X Funcionário
@sample		At581PostoFun()
@return		NIL
@author		Serviços
@since			03/07/2015 
@version		P12
/*/
//--------------------------------------------------------------------
Function At581PostoFun()

//Carrega amarracao Posto X Funcionário
If !Empty(FwFldGet("TW1_CODTFF"))
	DbSelectArea("TFF")
	TFF->(DbSetOrder(1))
	TFF->(DbSeek(xFilial("TFF")+FwFldGet("TW1_CODTFF")))
	FWExecView(STR0017, "VIEWDEF.TECA580E", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.},{||.T.},/*nReducao*/, /*aButtons*/, {||.T.}/*bCancel*/) //"Posto X Funcionário"
Else
	Help( , , "At581PostoFun", , STR0018, 1, 0 ) //"Informe o campo codigo RH"
EndIf

Return


//--------------------------------------------------------------------
/*/{Protheus.doc} At581VlTFF
@description	Validação do código RH para tipo Almocista ou Jantista.
@sample		At581VlTFF(oModTW1)
@param			oExp1: Objeto Model
@return		lExp1: .T.=Código RH é válido, pois é referente à Almocista ou Jantista // .F.=Código RH não é válido, pois não é referente à Almocista ou Jantista
@author		Serviços
@since			16/06/2016 
@version		P12
/*/
//--------------------------------------------------------------------
Function At581VlTFF(oModTW1)
Local cCodTFF	:= oModTW1:GetValue("TW1_CODTFF")
Local cRegiao	:= At670FilSql(__cUserId, .F., 'SX5', 'A2_')	//Buscar Query do filtro da região
Local cFilReg	:= If(Empty(cRegiao), "%%", "%"+cRegiao+"%")
Local cTmpTFF	:= ""
Local lRet		:= .T.

//verificar se existe escala para este item cobertura TFF
cTmpTFF	:= GetNextAlias()
BeginSql Alias cTmpTFF
	SELECT Count(*) as REGTFF 
	  FROM %table:TFF% TFF
	       Inner join %table:TDW% TDW ON TDW.TDW_FILIAL = %xFilial:TDW%
	                                 AND TDW.%NotDel%
	                                 AND TDW.TDW_COD = TFF.TFF_ESCALA
	       Inner join %table:TGX% TGX ON TGX.TGX_FILIAL = %xFilial:TGX%
	                                 AND TGX.%NotDel%
	                                 AND TGX.TGX_CODTDW = TDW.TDW_COD
	                                 AND TGX.TGX_TIPO IN ('1','2','3')
	       Inner join %table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
	                                 AND SB1.%NotDel%
	                                 AND SB1.B1_COD = TFF.TFF_PRODUT
	       Inner join %table:ABS% ABS ON ABS.ABS_FILIAL = %xFilial:ABS%
	                                 AND ABS.%NotDel%
	                                 AND ABS.ABS_LOCAL = TFF.TFF_LOCAL
	       Left join  %table:SX5% SX5 ON SX5.X5_FILIAL = %xFilial:SX5%
	                                 AND SX5.%NotDel%
	                                 AND SX5.X5_TABELA = 'A2'
	                                 AND SX5.X5_CHAVE = ABS.ABS_REGIAO
	 WHERE TFF.TFF_FILIAL = %xFilial:TFF%
	   AND TFF.%NotDel%
	   %Exp:cFilReg%
	   AND TFF.TFF_COD = %Exp:cCodTFF%
EndSql

DbSelectArea(cTmpTFF)

If (cTmpTFF)->REGTFF == 0
	Help( , , "At581VlTFF", , /*STR0039*/ STR0098, 1, 0 )	//"O Código RH informado não está associado a uma escala com o tipo de cobertura de Almocista, Jantista e Folguista."
	lRet := .F.					
EndIf

(cTmpTFF)->(DbCloseArea())

If lRet .And. TecBHasGvg() .And. Posicione("TFF",1,xFilial("TFF") +cCodTFF,"TFF_GERVAG") == "2"
	lRet := .F.
	Help( , , "At581VlTFF", , STR0238, 1, 0 ) //"Não é possivel selecionar Postos que não geram vaga operacional"
EndIf
Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} At581VlEsc
@description	Validação do código da escala de cobertura  
@sample			At581VlEsc(oModTW1)
@param			oExp1: Objeto Model
@return			lExp1: .T.=Código da escala é válido // .F.=Código da escala não é válido
@author			Serviços
@since			03/08/2015 
@version		P12
/*/
//--------------------------------------------------------------------
Function At581VlEsc(oModTW1)

Local aOldAlias	:= (Alias())->(GetArea())
Local cCodTFF	:= oModTW1:GetValue("TW1_CODTFF")
Local cCodTGX	:= oModTW1:GetValue("TW1_CODTGX")
Local oModel	:= oModTW1:GetModel() 
Local oModTW0	:= oModel:GetModel("TW0MASTER")
Local cTipo		:= IIF(TW0->(ColumnPos("TW0_TIPO") > 0), oModTW0:GetValue("TW0_TIPO"), "")
Local cTmpTGX	:= ""
Local lRet		:= .T.

//verificar se campo esta vazio
If Empty(cCodTFF)
	Help( , , "At581VlEsc", , STR0015, 1, 0 )	//"Informe o Código RH"
	lRet	:= .F.
EndIf

If lRet .And. !Empty(cTipo) .And. TGX->TGX_TIPO <> cTipo
	Help( , , "At581VlEsc", , STR0099, 1, 0 )	//"Não é possível selecionar um tipo diferente do campo TW0_TIPO."
	lRet	:= .F.
Endif

If lRet .And. !Empty(cTipo)
	//verificar se existe escala para este item cobertura TFF
	cTmpTGX	:= GetNextAlias()
	BeginSql Alias cTmpTGX
		SELECT count(*) as REGTGX
		  FROM %table:TGX% TGX
		      INNER JOIN %table:TFF% TFF ON TFF.TFF_FILIAL = %xFilial:TFF%
		                           AND TFF.%NotDel%
		                           AND TFF.TFF_COD = %Exp:cCodTFF%
		                           AND TFF.TFF_ESCALA = TGX.TGX_CODTDW
		 WHERE TGX.TGX_FILIAL = %xFilial:TGX%
		   AND TGX.%NotDel%
		   AND TGX.TGX_COD = %Exp:cCodTGX%
		   AND TGX.TGX_TIPO = %Exp:cTipo%
	EndSql
	DbSelectArea(cTmpTGX)
	If (cTmpTGX)->REGTGX == 0
		Help( , , "At581VlEsc", , STR0016, 1, 0 )	//"Não existe escala de cobertura para este item "
		lRet := .F.					
	EndIf
	(cTmpTGX)->(DbCloseArea())
EndIf

RestArea(aOldAlias)

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} At581VlGrp
@description	Validação do grupo da escala  
@sample		At581VlGrp(oModTW1)
@param			oExp1: Objeto Model
@return		lExp1: .T.=Grupo é válido // .F.=Grupo não é válido
@author		Serviços
@since			17/06/2016 
@version		P12
/*/
//--------------------------------------------------------------------
Function At581VlGrp(oModTW1)
Local cCodTFF	:= oModTW1:GetValue("TW1_CODTFF")
Local nGrupo	:= oModTW1:GetValue("TW1_GRUPO")
Local nGrpLimite:= Posicione("TFF",1,xFilial("TFF")+cCodTFF,"TFF_QTDVEN")
Local lRet		:= .T.

If nGrupo > nGrpLimite
	Help( , , "At581VlGrp", , STR0040, 1, 0 )	//"A quantidade de atendentes (Grupos) ultrapassou o permitido no contrato!"
	lRet := .F.					
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At581Efet
@description	Realiza a efetivação da movimentação ou remoção da rota de cobertura na gestão de escalas
@sample			At581Efet(cTpOper, cRota, cAtuAtend, dData, cAtdMvRmv)
@param			cExp1 - Tipo de operação ("MV"=Movimentar; "RE"=Remover")
@param			cExp2 - Rota em que o atendente estará alocado
@param			dExp3 - Data da efetivação do atendente na rota de cobertura
@param			cExp4 - Código do atendente que será associado ou removido da associação à rota de cobertura
@param			cExp5 - Controle de execução do robô da Automação para execução dos testes
@return			lExp1: .T.=Movimentação/Remoção executada com sucesso // .F.=Movimentação/Remoção não executada
@author			Serviços
@since			15/06/2016
@version		P12
/*/
//------------------------------------------------------------------------------
Function At581Efet(cTpOper, cRota, dData, cAtdMvRmv, lAutomato, dDtIniRt, dDtFimRt, dDtIniTGZ, dDtFimTGZ,lTroca,cMsgShwLog,lMVLote)
Local cTitCodTGX	:= AllTrim(Posicione("SX3",2,"TW1_CODTGX","X3Titulo()"))
Local oModel		:= Nil
Local oMdlTW0		:= Nil
Local oMdlTW1		:= Nil
Local oMdlTFF		:= Nil
Local oMdlTGX		:= Nil
Local oMdlTGZ		:= Nil
Local nInd1			:= 0
Local nInd2			:= 0
Local nTotHrsTrb	:= 0
Local nGrupo		:= 0
Local nHoraIni		:= 0
Local nHoraFim		:= 0
Local cAtuAtend		:= ""
Local cTmpAgenda	:= ""
Local cItem			:= ""
Local cCodTFF		:= ""
Local cCodTGX		:= ""
Local cCodTec		:= ""
Local cLogTGX		:= ""
Local cLogABB		:= ""
Local cSeek			:= ""
Local cComTW1 		:= FwModeAccess("TW1",1) +  FwModeAccess("TW1",2) + FwModeAccess("TW1",3)
Local cComTGZ 		:= FwModeAccess("TGZ",1) +  FwModeAccess("TGZ",2) + FwModeAccess("TGZ",3)
Local cComTFF		:= FwModeAccess("TFF",1) +  FwModeAccess("TFF",2) + FwModeAccess("TFF",3)
Local cFilBkp		:= cFilAnt
Local aDesalocar	:= {}
Local aAgenda		:= {}
Local aCalAtd		:= {}
Local aErro			:= {}
Local aAgCodTec		:= {}
Local aAreaTGZ		:= {}
Local aAgdAtdMnt	:= {}
Local aAgendas		:= {}
Local nX			:= 0
Local nY			:= 0
Local nA			:= 0
Local lCheckDt		:= .F.
Local lAddTGZ		:= .T.
Local lAtualiza		:= .F.
Local lRet			:= .T.
Local lMtFIl		:= cComTFF == "EEE" .AND. (LEN(STRTRAN( cComTW1  , "E" )) > LEN(STRTRAN(  cComTGZ  , "E" ))) .AND. TW1->(ColumnPos("TW1_FILTFF")) > 0
Local lTW1_TURNO 	:= TW1->(ColumnPos("TW1_TURNO")) > 0
Local lTW1_SEQ		:= TW1->(ColumnPos("TW1_SEQ")) > 0
Local lTW1_MOV 		:= TW1->(ColumnPos("TW1_MOV")) > 0
Local dIniRtTFF 	:= NIl
Local dFimRtTFF 	:= NIL
Local dMaiorDt		:= nil
Local lAtendFlex	:= TW1->(ColumnPos("TW1_ATDTGY") > 0) .AND. TecXHasEdH()
Local lSemEftTrn	:= TW0->(ColumnPos("TW0_VLDTEF") > 0)
Local cWhere		:= "%%"
Local lABB_CODTW1	:= ABB->(ColumnPos("ABB_CODTW1") > 0)
Local cDataIniRT	:= ""
Local cDataFimRT	:= ""
Local cMsg			:= ""
Local lRotaVaga		:= .F. 
Local aPostos		:= {}
Default cTpOper		:= "MV"
Default cRota		:= TW0->TW0_COD
Default dData		:= dDataBase
Default cAtdMvRmv	:= ""
Default lAutomato	:= .F.
Default dDtIniRt	:= sTod("")
Default dDtFimRt	:= sTod("")
Default lTroca		:= .F.
Default cMsgShwLog	:= ""		//Variavel para armazenar erros, utilizado Movimentação em Lote
Default lMVLote		:= .F.		//Indica que a chamada foi feita pela movimentação em Lote

//posicionar na TW0
DbSelectArea("TW0")
TW0->(DbSetOrder(1)) //TW0_FILIAL+TW0_COD
TW0->(DbSeek(xFilial("TW0")+cRota))

lRotaVaga := At581RtVag() .And. TW0->TW0_VAGA == "1" .And. lTroca .And. cTpOper == "RE"

cAtuAtend	:= TW0->TW0_ATEND

If Empty(cAtdMvRmv) .AND.  cTpOper $ 'MV|RE|CA' //(cTpOper == "MV" .OR. cTpOper == "RE")
	cAtdMvRmv	:= TW0->TW0_ATEND
EndIf

If cTpOper $ 'RE|CA|MV' .AND. Empty(cAtdMvRmv)
	Help( ,, "At581Efet",, STR0028, 1, 0 ) //"Não existe atendente preenchido na rota de cobertura. Essa ação só será possível com um atendente selecionado."
	lRet	:= .F.
Endif

cDataIniRT := DToC(dDtIniRt)
cDataFimRT := DToC(dDtFimRt)

cMsg := + CRLF + CRLF 
cMsg += STR0174 //"Todos os Postos - Apaga todas as agendas para o atendente  "
cMsg += Alltrim(cAtdMvRmv)
cMsg += STR0175 //" no periodo de "
cMsg += cDataIniRT
cMsg += STR0176 //" até "
cMsg += cDataFimRT
cMsg += + CRLF + CRLF 
cMsg += STR0177 //"Apenas desta Rota - Apaga somente as agendas da rota posicionada "
cMsg += cRota
cMsg += STR0175 //" no periodo de "
cMsg += cDataIniRT
cMsg += STR0176 //" até "
cMsg += cDataFimRT

If lRet .And. cTpOper $ "RE|CA" .And. lABB_CODTW1 .And. !lAutomato
	If !lRotaVaga .Or. IsInCallStack("At020ExcRt")
		If Aviso( STR0168, STR0169 + cMsg ,; //"Exclusão de agendas da rota."#"Como deseja realizar a exclusão?"
					{STR0170,STR0171},3) == 1 //"Todos os postos"#"Apenas desta rota"
			lABB_CODTW1 := .F.
		Endif
	Else
		lABB_CODTW1 := .T.
	Endif
Endif

If lRet

	BEGIN TRANSACTION

		oModel	:= FWLoadModel("TECA581")	//Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
	
		oMdlTW0	:= oModel:GetModel("TW0MASTER")
		oMdlTW1	:= oModel:GetModel("TW1DETAIL")
	
		//===========================================================================================================================
		// Análise geral dos itens da rota "TW1", avaliando se todos os registros são válidos para efetivar a movimentação/remoção...
		//===========================================================================================================================
		For nInd1 := 1 to oMdlTW1:Length()
	
			oMdlTW1:GoLine(nInd1)
			cCodTFF	:= oMdlTW1:GetValue("TW1_CODTFF")
			cCodTGX	:= oMdlTW1:GetValue("TW1_CODTGX")
			nHoraIni := oMdlTW1:GetValue("TW1_HORINI")
			nHoraFim := oMdlTW1:GetValue("TW1_HORFIM")
			If lMtFIl .AND. !EMPTY(oMdlTW1:GetValue("TW1_FILTFF"))
				cFilAnt := oMdlTW1:GetValue("TW1_FILTFF")
			EndIf
			DbSelectArea("TFF")
			TFF->(DbSetOrder(1)) //TFF_FILIAL+TFF_COD
			TFF->(MsSeek(xFilial("TFF")+cCodTFF))
			dIniRtTFF := TFF->TFF_PERINI
			dFimRtTFF := TFF->TFF_PERFIM

			oMdlTFF	:= FWLoadModel("TECA580E")	//Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
			oMdlTFF:SetOperation(MODEL_OPERATION_VIEW)
			oMdlTFF:Activate()
	
			oMdlTGX	:= oMdlTFF:GetModel("TGXDETAIL")
			oMdlTGZ	:= oMdlTFF:GetModel("TGZDETAIL")
			
			// Verificar se existe na Gestão de Escalas a configuração para Almocista, Jantista e Ferista.
			// Posicionar na linha da TGX
			If ! ( oMdlTGX:SeekLine({{"TGX_COD",cCodTGX}}) )
				cLogTGX	+= "- ("+cTitCodTGX+": '"+cCodTGX+"')"+CRLF
				lRet := .F.
			EndIf
			
			//Atualiza a Data Inicial/Final da rota de cobertura, odedecendo a TFF
			dIniRtTFF := Max(dIniRtTFF, dDtIniRt)
			dFimRtTFF := Min(dFimRtTFF, dDtFimRt)
			
			If cTpOper $ 'RE|CA'
				If lRet
					cCodTec	:= If(! Empty(cAtuAtend), cAtuAtend, cAtdMvRmv)
					//Verificar se existe agenda atendida ou com manutenção para o atendente da rota de cobertura.		
					aAgdAtdMnt := At581GAgMA(cCodTFF, cCodTec, dIniRtTFF, dFimRtTFF,Iif(lABB_CODTW1,oMdlTW1:GetValue("TW1_COD"),""))
					For nX := 1 To Len(aAgdAtdMnt)
						If !aAgdAtdMnt[nx,8] .OR. !At680Perm(NIL, __cUserId, "038", .T.)
							lRet	:= .F.
							cLogABB	+= CRLF+"Cod. Rh: " +"["+cCodTFF+"]"+CRLF+CRLF
							cLogABB += "Cod. Agenda: "	+"["+aAgdAtdMnt[nx,1]+"]"
							cLogABB += " Data Início: " +"["+cValTocHar(sTod(aAgdAtdMnt[nx,4]))+"]"
							cLogABB += " Hora Início: " +"["+aAgdAtdMnt[nx,5]+"]"
							cLogABB += " Data Final: " 	+"["+cValTocHar(sTod(aAgdAtdMnt[nx,6]))+"]"
							cLogABB += " Hora Final: " 	+"["+aAgdAtdMnt[nx,7]+"]"
							cLogABB += " Atendida: " 	+"["+Iif(aAgdAtdMnt[nx,2] == "1","Sim","Não")+"]"
							cLogABB += " Manutenção: " 	+"["+Iif(aAgdAtdMnt[nx,3] == "1","Sim","Não")+"]"+CRLF+CRLF
						EndIf
					Next nX

					lRet := lRet .And. At581DlMnt(aAgdAtdMnt,@cMsgShwLog)
					
				EndIf
				
				If lRet .And. cTpOper == "RE"
		
					If lABB_CODTW1
						cWhere := "% AND ABB.ABB_CODTW1 = '"+ oMdlTW1:GetValue("TW1_COD") +"' %"					
					Endif
					
					aAgCodTec	:= {}
		
					cCodTec	:= If(! Empty(cAtuAtend), cAtuAtend, cAtdMvRmv)

					cTmpAgenda	:= GetNextAlias()
				
					BeginSql Alias cTmpAgenda
						SELECT ABB.R_E_C_N_O_ as RECABB
						  FROM %table:ABB% ABB
						       INNER JOIN %table:ABQ% ABQ on %xFilial:ABQ% = ABQ.ABQ_FILIAL
						                                AND ABQ.%NotDel%
						                                AND %xFilial:ABB% = ABQ.ABQ_FILTFF
						                                AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM
						       INNER JOIN %table:TDV% TDV on %xFilial:TDV% = TDV.TDV_FILIAL
							   							AND ABB.ABB_CODIGO = TDV.TDV_CODABB
														AND TDV.%NotDel%
							   INNER JOIN %table:TFF% TFF on TFF.TFF_FILIAL = %xFilial:TFF%
						                                AND TFF.%NotDel%
						                                AND TFF.TFF_COD = ABQ.ABQ_CODTFF
						 WHERE ABB.ABB_FILIAL = %xFilial:ABB%
						   AND ABB.%NotDel%
						   AND ABB.ABB_MANUT  = '2'
						   %Exp:cWhere%
						   AND ABB.ABB_ATENDE = '2'
						   AND ABB.ABB_CODTEC = %Exp:cCodTec%
						   AND TDV_DTREF BETWEEN %Exp:dIniRtTFF% AND %Exp:dFimRtTFF%
						   AND TFF.TFF_COD 	  = %Exp:cCodTFF%
					EndSql
			
					While (cTmpAgenda)->(! Eof())
						If	aScan(aAgCodTec, {|x| x == (cTmpAgenda)->RECABB}) == 0
							aAdd(aAgCodTec,(cTmpAgenda)->RECABB)
						EndIf
						(cTmpAgenda)->(DbSkip())
					EndDo
			
					(cTmpAgenda)->(DbCloseArea())
			
					aDesalocar	:= {}
			
					For nInd2 := 1 to Len(aAgCodTec)
			
						ABB->(DbGoTo(aAgCodTec[nInd2]))
			
						nTotHrsTrb	:= SubtHoras(ABB->ABB_DTINI, ABB->ABB_HRINI, ABB->ABB_DTFIM, ABB->ABB_HRFIM)
						aCalAtd	:= { {		.T.,;
											ABB->ABB_DTINI,;
											ABB->ABB_HRINI,;
											ABB->ABB_DTFIM,;
											ABB->ABB_HRFIM,;
											TxRtDiaSem(ABB->ABB_DTINI),;
											nTotHrsTrb,;
											Posicione("TFF", 1, xFilial("TFF")+cCodTFF, "TFF_SEQTRN") } }
			
						aAgenda	:= {aCalAtd, nTotHrsTrb, 1}
			
						aAdd(aDesalocar, {cCodTec,;
						                  "",;
						                  Posicione("AA1", 1, xFilial("AA1")+cAtuAtend, "AA1_CDFUNC"),;
						                  oMdlTGZ:GetValue("TGZ_TURNO"),;
						                  Posicione("TFF", 1, xFilial("TFF")+cCodTFF, "TFF_FUNCAO"),;
						                  Posicione("TFF", 1, xFilial("TFF")+cCodTFF, "TFF_CARGO"),;
						                  aAgenda[1],;
						                  aAgenda[2],;
						                  aAgenda[3]})
			
					Next nInd2
			
					If !Empty(aDesalocar)
						At330GvDes(aDesalocar)
					Endif
		
				ElseIf lRet .And. cTpOper == "CA"
					lRet := At581ExAg(If(!Empty(cAtuAtend), cAtuAtend, cAtdMvRmv),;
					 												   dDtFimRt,; 
																	   cCodTFF,;
																	   /*cMsg*/,;
																	   dDtIniRt,;
																	   nHoraIni,;
																	   nHoraFim,;
																	   cCodTGX,;
																	   Iif(lABB_CODTW1,oMdlTW1:GetValue("TW1_COD"),""),;
																	   Iif(lAtendFlex , oMdlTW1:GetValue("TW1_ATDTGY"), "" ))
				Endif
			Endif
			If lRotaVaga
				aAdd(aPostos,{	oMdlTW1:GetValue("TW1_CODTFF"),;
								oMdlTW1:GetValue("TW1_CODTDX"),;
								oMdlTW1:GetValue("TW1_GRUPO"),;
								oMdlTW1:GetValue("TW1_CODHE")})	
			Endif
			cFilAnt := cFilBkp
		Next nInd1
		
		If lRet .And. lRotaVaga 
			lRet := At581HeVag(aPostos, dDtIniRt, dDtFimRt, @cMsgShwLog )
		Endif

		//===========================================================================================================================
		// Inicia a efetivação da movimentação/remoção após a análise geral dos itens da rota "TW1" e da confirmação de que todos os
		// registros são válidos
		//===========================================================================================================================
		If	lRet
				
			cCodTec	:= If(! Empty(cAtuAtend), cAtuAtend, cAtdMvRmv)
	
			DbSelectArea("TFF")
			// Le os itens da rota TW1
			For nInd1 := 1 to oMdlTW1:Length()
				
				oMdlTW1:GoLine(nInd1)
	
				cCodTFF	:= oMdlTW1:GetValue("TW1_CODTFF")
				cCodTGX	:= oMdlTW1:GetValue("TW1_CODTGX")
				nGrupo	:= oMdlTW1:GetValue("TW1_GRUPO")
				lAtualiza := .F.

				If lMtFIl .AND. !EMPTY(oMdlTW1:GetValue("TW1_FILTFF"))
					cFilAnt := oMdlTW1:GetValue("TW1_FILTFF")
				EndIf
				// Posiciona na TFF através da TW1 (TW1_CODTFF)
				DbSelectArea("TFF")
				TFF->(DbSetOrder(1)) //TFF_FILIAL+TFF_COD
				TFF->(MsSeek(xFilial("TFF")+cCodTFF))
				dIniRtTFF := TFF->TFF_PERINI
				dFimRtTFF := TFF->TFF_PERFIM

				oMdlTFF	:= FWLoadModel("TECA580E")	//Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
				oMdlTFF:SetOperation(MODEL_OPERATION_UPDATE)
				oMdlTFF:Activate()
	
				oMdlTGX	:= oMdlTFF:GetModel("TGXDETAIL")
				
				//posiciona no Folder Correto
				At580VdFolder({2})
				
				// Posiciona na linha da TGX
				oMdlTGX:SeekLine({{"TGX_COD",cCodTGX}})
	
				// Verificar regras de gravacao e ou alteracao
				// modelo Grid TGZ
				oMdlTGZ	:= oMdlTFF:GetModel("TGZDETAIL")
	
				lAddTGZ 	:= .T.

				//Atualiza a Data Inicial/Final da rota de cobertura, obedecendo a TFF
				dIniRtTFF := Max(dIniRtTFF, dDtIniRt)
				dFimRtTFF := Min(dFimRtTFF, dDtFimRt)

				If	cTpOper == "MV"	// Movimentar
	
					cItem		:= "00"
					cSeek := ""
					For nInd2 := 1 to oMdlTGZ:Length()
						oMdlTGZ:GoLine(nInd2)
	
						//Se encontrar alguma TGZ atualiza as datas de movimentação e não gera uma nova linha.
						If !oMdlTGZ:IsDeleted() .And. oMdlTGZ:GetValue("TGZ_ATEND") == cCodTec .And. oMdlTGZ:GetValue("TGZ_GRUPO") == nGrupo .And.;
						 												  							 oMdlTGZ:GetValue("TGZ_CODTW0") == cRota .And.;
						 												  							(dDtIniTGZ >= oMdlTGZ:GetValue("TGZ_DTINI") .And.;
						 												  							 dDtFimTGZ <= oMdlTGZ:GetValue("TGZ_DTFIM"))
						 	If dDtIniRt <= dDtIniTGZ
						 		lRet := lRet .And. oMdlTGZ:SetValue("TGZ_DTINI",  dDtIniRt)
						 	EndIf

						 	If dDtFimRt >= dDtFimTGZ
						 		lRet := lRet .And. oMdlTGZ:SetValue("TGZ_DTFIM",  dDtFimRt)
						 	EndIf

							lAddTGZ := .F.
							cSeek := xFilial("TGZ")+;
								oMdlTGZ:GetValue("TGZ_ESCALA")+;
								oMdlTGZ:GetValue("TGZ_CODTDX")+;
								cCodTFF+;
								oMdlTGZ:GetValue("TGZ_ITEM")
						Endif												  							 	
	
						cItem	:= Iif(!Empty(oMdlTGZ:GetValue("TGZ_ITEM")), oMdlTGZ:GetValue("TGZ_ITEM"), cItem)	
	
					Next nInd2
	
					If lAddTGZ
						If	!( oMdlTGZ:IsEmpty() )
							lRet := lRet .And. oMdlTGZ:AddLine()
						EndIf
	
						lRet := lRet .And. oMdlTGZ:SetValue("TGZ_ITEM",   Soma1(cItem))
						lRet := lRet .And. oMdlTGZ:SetValue("TGZ_CODTW0", cRota)
						lRet := lRet .And. oMdlTGZ:SetValue("TGZ_DTINI",  dIniRtTFF)
						lRet := lRet .And. oMdlTGZ:SetValue("TGZ_DTFIM",  dFimRtTFF)
						lRet := lRet .And. oMdlTGZ:SetValue("TGZ_GRUPO",  nGrupo)
						lRet := lRet .And. oMdlTGZ:SetValue("TGZ_CODTDX", cCodTGX)
						lRet := lRet .And. oMdlTGZ:SetValue("TGZ_ESCALA", oMdlTW1:GetValue("TW1_CODTDW"))
						lRet := lRet .And. oMdlTGZ:SetValue("TGZ_ATEND",  cAtdMvRmv)
						lRet := lRet .And. oMdlTGZ:SetValue("TGZ_HORINI", oMdlTW1:GetValue("TW1_HORINI"))
						lRet := lRet .And. oMdlTGZ:SetValue("TGZ_HORFIM", oMdlTW1:GetValue("TW1_HORFIM"))
						If lTW1_TURNO
							lRet := lRet .And. oMdlTGZ:LoadValue("TGZ_TURNO", oMdlTW1:GetValue("TW1_TURNO"))
						EndIf
						If lTW1_SEQ 	
							lRet := lRet .And. oMdlTGZ:LoadValue("TGZ_SEQ", oMdlTW1:GetValue("TW1_SEQ"))
						EndIf
						If lRet
							cSeek := xFilial("TGZ")+;
										oMdlTGZ:GetValue("TGZ_ESCALA")+;
										oMdlTGZ:GetValue("TGZ_CODTDX")+;
										cCodTFF+;
										oMdlTGZ:GetValue("TGZ_ITEM")
						Else
							cSeek := ""
						EndIf
					Endif
				Else
				//Remover
					If	!( oMdlTGZ:IsEmpty() )
	
						For nInd2 := 1 to oMdlTGZ:Length()
							oMdlTGZ:GoLine(nInd2)
	
							If cTpOper == 'RE'
								If lTroca .AND. oMdlTGZ:GetValue("TGZ_ATEND") <> cCodTec
									lRet := oMdlTGZ:LoadValue("TGZ_DTFIM",  dDtIniRt - 1)
									lAtualiza := .T.
								EndIf
								
								If !oMdlTGZ:IsDeleted() .And. oMdlTGZ:GetValue("TGZ_ATEND") == cCodTec .And. oMdlTGZ:GetValue("TGZ_GRUPO") == nGrupo .And.;
								 												  							 oMdlTGZ:GetValue("TGZ_CODTW0") == cRota .And.;
								 												  							(dIniRtTFF == oMdlTGZ:GetValue("TGZ_DTINI") .And.;
								 												  							 dFimRtTFF == oMdlTGZ:GetValue("TGZ_DTFIM"))
			
								 	lRet := oMdlTGZ:DeleteLine()
									lAtualiza := .T.
								Endif
							Else
								If cTpOper == 'CA'
									If !oMdlTGZ:IsDeleted() .And. oMdlTGZ:GetValue("TGZ_ATEND") == cCodTec .And. oMdlTGZ:GetValue("TGZ_GRUPO") == nGrupo .And.;
						 												  							 oMdlTGZ:GetValue("TGZ_CODTW0") == cRota .And.;
						 												  							(dDtIniTGZ >= oMdlTGZ:GetValue("TGZ_DTINI") .And.;
						 												  							 dDtFimTGZ <= oMdlTGZ:GetValue("TGZ_DTFIM"))
										If dDtFimRt == dDtFimTGZ .AND. dDtIniRt == dDtIniTGZ
											If At581GsRota()
												lRet := oMdlTGZ:DeleteLine()
											Else
												lRet := lRet .And. oMdlTGZ:SetValue("TGZ_DTFIM", CTOD(""))
											Endif
											lAtualiza := .T.
										Else
											If dDtIniRt == dDtIniTGZ
												lRet := lRet .And. oMdlTGZ:SetValue("TGZ_DTINI",  dDtFimRt + 1)
												lAtualiza := .T.
											EndIf

											If dDtFimRt == dDtFimTGZ
												lRet := lRet .And. oMdlTGZ:SetValue("TGZ_DTFIM",  dDtIniRt - 1)
												lAtualiza := .T.
											EndIf
										EndIf
									EndIf
								Else
									If !oMdlTGZ:IsDeleted() .And. oMdlTGZ:GetValue("TGZ_ATEND") == cCodTec .And. oMdlTGZ:GetValue("TGZ_GRUPO") == nGrupo .And.;
																												oMdlTGZ:GetValue("TGZ_CODTW0") == cRota .And.;
																												(dIniRtTFF == oMdlTGZ:GetValue("TGZ_DTINI") .And.;
																												dFimRtTFF <= oMdlTGZ:GetValue("TGZ_DTFIM"))
										lRet := oMdlTGZ:SetValue("TGZ_DTINI",  dDtFimRt)
										lAtualiza := .T.
									Endif
								EndIf
							EndIf	
							
						Next nInd2
	
					EndIf
				EndIf
				
				If !lAtualiza .AND. !(cTpOper $ 'CA|RE')
					lAtualiza := .T.
				EndIf

				If lAtualiza .AND. lRet
					If (oMdlTFF:VldData() .And. oMdlTFF:CommitData())
						If cTpOper == "MV"
							aAgendas := {}
							lCheckDt := .F.
							dMaiorDt := CTOD("")
							
							//realiza a chamada para realizar a alocação do atendente
							At330AloAut(, , , , , , dIniRtTFF, dFimRtTFF, , , , , , , , cCodTFF,;
							 	Alltrim(cAtdMvRmv),.F., cRota, lMVLote, @aAgendas,;
								 iif(lTW1_SEQ,oMdlTW1:GetValue("TW1_SEQ"),""),;
								 IIF(lAtendFlex, oMdlTW1:GetValue("TW1_ATDTGY"), "" ),;
								 IIF(lSemEftTrn, !EMPTY(oMdlTW0:GetValue("TW0_VLDTEF")) .AND. oMdlTW0:GetValue("TW0_VLDTEF")=='2' ,.F.),oMdlTW1:GetValue("TW1_COD"))
							
							If !EMPTY(aAgendas)
								For nY := 1 To LEN(aAgendas)
									If ASCAN(aAgendas[nY], {|a| a[1] == cAtdMvRmv}) > 0
										For nA := 1 To LEN(aAgendas[nY])
											If EMPTY(dMaiorDt) .OR. aAgendas[nY][nA][10][1][1] > dMaiorDt
												dMaiorDt := aAgendas[nY][nA][10][1][1]
											EndIf
										Next nA
										lCheckDt := .T.
										Exit
									EndIf
									If lCheckDt
										Exit
									EndIf
								Next nY
								If dMaiorDt < dFimRtTFF .AND. !EMPTY(cSeek)
									aAreaTGZ := TGZ->(GetArea())
									If TGZ->(DbSeek(cSeek))
										RecLock("TGZ", .F.)
										TGZ->TGZ_DTFIM := dMaiorDt
										TGZ->(MsUnlock())
										cMsgShwLog += CRLF + STR0142 + TGZ->TGZ_ATEND + STR0143 //"Alocação do atendente " ## " realizada até o dia "
										cMsgShwLog += DtoC(dMaiorDt) + STR0144 + "("+DtoC(dFimRtTFF)+")" + CRLF //" ao invés da data solicitada. "
									EndIf
									RestArea(aAreaTGZ)
								EndIf
							EndIf
						Endif
					Else
						aErro	:= oMdlTFF:GetErrorMessage()
						If !lMVLote
							Help( , , "At581Efet", , aErro[MODEL_MSGERR_MESSAGE], 1, 0 )
						Else
							At581GrLog(aErro,@cMsgShwLog,cCodTFF)
						EndIf 
						Exit
						lRet := .F.
					Endif
				EndIf
				oMdlTFF:DeActivate()
				cFilAnt := cFilBkp
			Next nInd1
						
			If	(lRet .And. cTpOper $ 'MV|RE' .And. RotaAgend(cRota,dDtIniRt,dDtFimRt)) .Or.;
				(At581GsRota() .And. lRet .And. cTpOper $ "CA|RE" .And. !ExistTGZ(cRota,cCodTec))
				// Atualiza o atendente da TW0
				oMdlTW0:SetValue("TW0_ATEND", If( cTpOper == "MV", cAtdMvRmv, "" ))
				If lRotaVaga .And. lTroca
					oMdlTW0:SetValue("TW0_VAGA", "2" )
				Endif
				For nInd1 := 1 to oMdlTW1:Length()
				
					oMdlTW1:GoLine(nInd1)
					
					//Indica que o item foi movimentado
					If lTW1_MOV
						oMdlTW1:SetValue("TW1_MOV", If( cTpOper == "MV", "1", "2" ))
					EndIf
					
				Next nInd1	
				
				If ( lRet := ( oModel:VldData() .And. oModel:CommitData() ) )
					oModel:DeActivate()
				Else
					aErro	:= oModel:GetErrorMessage()
					If !lMVLote
						Help( , , "At581Efet", , aErro[MODEL_MSGERR_MESSAGE], 1, 0 )
					Else
						At581GrLog(aErro,@cMsgShwLog,cCodTFF)
					EndIf 
					DisarmTransaction()
				EndIf
			ElseIf !lRet
				DisarmTransaction()
			EndIf
	
			If (lRet .And. !lAutomato) .Or. (lRet .And. IsInCallStack("At020ExcRt")) 
				If !lTroca .Or. (lTroca .And. cTpOper == "MV")
					If !IsInCallStack("At020ExcRt")
						If !lMVLote 
							MsgInfo(STR0026) //"Rota de cobertura atualizada com sucesso!"
						ElseIf !RotaAgend(cRota,dDtIniRt,dDtFimRt)
							cMsgShwLog		+= STR0179 + CRLF + cLogABB + CRLF + CRLF // "Rota não movimentada, pois não existe agenda para o periodo informado"	
							lRet := .F.
						EndIf
					EndIf		
				EndIf	
			Else
				If !lMVLote
					Help( , , "At581Efet", , STR0027, 1, 0,,,,,,{STR0036})	// "Durante a execução deste procedimento foram encontradas situações que impedem a sua efetivação." ## "Corrija as inconsistências para efetivar o processamento desejado."	
				EndIf 			
			EndIf
		Else
			If	!Empty(cLogTGX) .And. !lAutomato
				cMsgShwLog		+= STR0020 + ":" + CRLF + cLogTGX + CRLF + CRLF	// "Não existe item relacionado na configuração da escala de cobertura"
			EndIf
			
			If	!Empty(cLogABB) .And. !lAutomato
				cMsgShwLog		+= STR0100  + CRLF + cLogABB + CRLF + CRLF // "Foi encontrada uma ou mais agendas atendidas ou com manutenção realizada numa data posterior a este processamento da rota de cobertura:"
			EndIf
			
			If !lAutomato
				cMsgShwLog	:=	If(!(Empty(cMsgShwLog)), STR0034+":" + CRLF + CRLF + cMsgShwLog, "")	// "Inconsistências"
			EndIf
			
			If	!Empty(cMsgShwLog) .And. !lAutomato .And. !lMVLote
				AtShowLog(cMsgShwLog /*<cMemoLog>*/, STR0001 /*<cTitle>*/, /*<lVScroll>*/, /*<lHScroll>*/, .T. /*<lWrdWrap>*/)	//"Rota de Cobertura"
				Help( , , "At581Efet", , STR0035, 1, 0,,,,,,{STR0036})	//	"Não é permitido movimentar ou remover uma rota de cobertura que possua inconsistências." ## "Corrija as inconsistências para efetivar o processamento desejado."
			EndIf
		EndIf

	END TRANSACTION

EndIf

Return	lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581GAgMA
@description	Verifica se existe agendas atendidas ou em manutenção para o atendente da rota.
@sample			At581GAgMA(cCodTFF, cCodTec, dDtIni, dDtFim,cCodTW1)
@return			aRetAgend Array com as agendas atendidas ou em manutenção.
@author			Serviços
@since			01/19/2019
@version		P12
/*/
//------------------------------------------------------------------------------
Static Function At581GAgMA(cCodTFF, cCodTec, dDtIni, dDtFim, cCodTW1)
Local cTmpAgenda	:= ""
Local aRetAgend		:= {}
Local lExlcui		:= .T.
Local cWhereTW1  	:= "%%"

cTmpAgenda	:= GetNextAlias()

If !Empty(cCodTW1)
	cWhereTW1 := "% AND ABB.ABB_CODTW1 = '"+ cCodTW1 +"' %"
Endif

dbSelectArea("ABN")
ABN->(dbSetOrder(1))

BeginSql Alias cTmpAgenda

	SELECT ABB.ABB_CODIGO,
		   ABB.ABB_ATENDE,
		   ABB.ABB_MANUT,
		   ABB.ABB_DTINI,
		   ABB.ABB_HRINI,
		   ABB.ABB_DTFIM,
		   ABB.ABB_HRFIM,
		   ABB.ABB_FILIAL,
		   ABR.ABR_MOTIVO,
		   ABR.R_E_C_N_O_ REC

	  FROM %table:ABB% ABB
	       LEFT JOIN %table:ABQ% ABQ on %xFilial:ABQ% = ABQ.ABQ_FILIAL
	                                AND ABQ.%NotDel%
	                                AND %xFilial:ABB% = ABQ.ABQ_FILTFF
	                                AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM
	       LEFT JOIN %table:TFF% TFF on TFF.TFF_FILIAL = %xFilial:TFF%
	                                AND TFF.%NotDel%
	                                AND TFF.TFF_COD = %Exp:cCodTFF%
	                                AND TFF.TFF_COD = ABQ.ABQ_CODTFF
			LEFT JOIN %table:ABR% ABR on ABR.ABR_FILIAL = %xFilial:ABB%
	                                AND ABR.%NotDel%
	                                AND ABR.ABR_AGENDA = ABB.ABB_CODIGO
	 WHERE ABB.ABB_FILIAL = %xFilial:ABB%
	   %Exp:cWhereTW1%
	   AND ABB.%NotDel%
	   AND ( ABB.ABB_MANUT = '1' OR ABB.ABB_ATENDE = '1' )
	   AND ABB.ABB_CODTEC  = %Exp:cCodTec%
	   AND (ABB.ABB_DTINI >= %Exp:dDtIni% AND ABB.ABB_DTFIM <= %Exp:dDtFim%)

EndSql

While (cTmpAgenda)->(!Eof())

	If !EmpTy((cTmpAgenda)->ABR_MOTIVO) .AND.;
			ABN->(dbSeek(xFilial("ABN", (cTmpAgenda)->ABB_FILIAL)+(cTmpAgenda)->ABR_MOTIVO )) .AND.;
			ABN->ABN_TIPO == "04" // Faz somente para hora extra

		lExlcui := .T.
	Else
		lExlcui := .F.
	EndIf
	
	aAdd( aRetAgend, { 	(cTmpAgenda)->ABB_CODIGO,;
	 					(cTmpAgenda)->ABB_ATENDE,; 
	 					(cTmpAgenda)->ABB_MANUT,;
	 					(cTmpAgenda)->ABB_DTINI,;
	 					(cTmpAgenda)->ABB_HRINI,;
	 					(cTmpAgenda)->ABB_DTFIM,;
	 					(cTmpAgenda)->ABB_HRFIM,;
						lExlcui,;
						(cTmpAgenda)->REC} )

	(cTmpAgenda)->(DbSkip())
EndDo

(cTmpAgenda)->(DbCloseArea())

Return aRetAgend

//-------------------------------------------------------------------
/*/{Protheus.doc} At581LnPos()
@description Validação de linha para não sobrepor os dias e os horários de atendimento conforme o tipo de cobertura, escala, turno e sequencia.

@author Kaique Schiller
@since 22/05/2018
@return cRet
/*/
//------------------------------------------------------------------
Function At581LnPos(oMdl,nLine)
Local lRet	  		:= .T.
Local nX	  		:= 0
Local nY			:= 0
Local cConfCob		:= ""
Local cEscala		:= ""
Local cTurno		:= ""
Local cSeq			:= ""
Local aCobEft		:= {}
Local aCobEftAux	:= {}
Local cDiaSem		:= ""
Local nHrIni		:= 0
Local nHrFim		:= 0
Local lTW1_SEQ := TW1->(ColumnPos("TW1_SEQ")) > 0
Local lTW1_TURNO := TW1->(ColumnPos("TW1_TURNO")) > 0
Local cComTW1 	:= FwModeAccess("TW1",1) +  FwModeAccess("TW1",2) + FwModeAccess("TW1",3)
Local cComTGZ 	:= FwModeAccess("TGZ",1) +  FwModeAccess("TGZ",2) + FwModeAccess("TGZ",3)
Local cComTFF	:= FwModeAccess("TFF",1) +  FwModeAccess("TFF",2) + FwModeAccess("TFF",3)
Local lMtFIl	:= cComTFF == "EEE" .AND. (LEN(STRTRAN( cComTW1  , "E" )) > LEN(STRTRAN(  cComTGZ  , "E" ))) .AND. TW1->(ColumnPos("TW1_FILTFF")) > 0
Local cFilBkp	:= cFilAnt

DbSelectArea("TW1")
TW1->(DbSetOrder(1))

DbSelectArea("TDX")
TDX->(DbSetOrder(1))

For nX := 1 To oMdl:Length()

	oMdl:GoLine(nX)

	If !oMdl:IsDeleted()
		If lMtFIl .AND. !EMPTY(oMdl:GetValue("TW1_FILTFF"))
			cFilAnt := oMdl:GetValue("TW1_FILTFF")
		EndIf
		nHrIni := oMdl:GetValue("TW1_HORINI")
		nHrFim := oMdl:GetValue("TW1_HORFIM")
		
		cConfCob := oMdl:GetValue("TW1_CODTGX")
		cEscala	 := POSICIONE("TGX",1,xFilial("TGX")+cConfCob,"TGX_CODTDW")

		If lTW1_TURNO .and. lTW1_SEQ
			cTurno	 := oMdl:GetValue("TW1_TURNO")
			cSeq	 := oMdl:GetValue("TW1_SEQ")
			If !Empty(cTurno) .And. !Empty(cSeq)
				//Lista os dias e os horários da cobertura.
				aCobEftAux := At581Cob( cEscala, cConfCob, cTurno, cSeq )
				
				If !Empty(aCobEftAux)
					For nY := 1 To Len(aCobEftAux)
						If aCobEftAux[nY,2] == 0 .And. aCobEftAux[nY,3] == 0
							Help( , , "At581LnPos", , STR0101, 1, 0,,,,,,{STR0102}) //"Não é permitido deixar o horário inicio e fim da cobertura zerados."#"Realize o preechimento dos horários da cobertura no cadastro de escalas."
							lRet := .F.
							Exit
						Else
							If nHrIni == 0 .And. nHrFim == 0
								aAdd( aCobEft, { aCobEftAux[nY,1], aCobEftAux[nY,2], aCobEftAux[nY,3] } )
							Else
								aAdd( aCobEft, { aCobEftAux[nY,1], nHrIni, nHrFim } )
							Endif
						Endif
					Next nY
				Else  
					Help( , , "At581LnPos", , STR0059, 1, 0,,,,,,{STR0060}) //"Configuração de Escala não permite esse tipo de cobertura."#"Realize a configuração no cadastro de escalas."
					lRet := .F.
					Exit
				Endif
			Else
				Help( , , "At581LnPos", , STR0103, 1, 0,,,,,,{STR0104}) //"Os campos de Turno e Sequência não foram preenchidos."#"Preencha os campos."
				lRet := .F.
				Exit
			Endif
		EndIf
	Endif
Next nX

cFilAnt := cFilBkp

If !Empty(aCobEft) .And. lRet

	aCobEft := aSort(aCobEft, , ,{|x,y|x[1] < y[1]})
		
	For nX := 1 To Len(aCobEft)

		If cDiaSem <> aCobEft[nX,1]  //Quando o dia for diferente
			cDiaSem := aCobEft[nX,1] //Dia da Semana
			nHrIni 	:= aCobEft[nX,2] //Horário inicio
			nHrFim 	:= aCobEft[nX,3] //Horário fim

		Else //Quando for o mesmo dia, verifica se os horários estão sobrepostos.
			If !(nHrIni >= aCobEft[nX,3] .Or. nHrFim <= aCobEft[nX,2])
				Help( , , "At581LnPos", , STR0061, 1, 0,,,,,,{STR0105 }) //"Conflito no dia e no horário da cobertura."#"Escolha um posto que tem dia ou o horário de atendimento diferente ou informe um horário de entrada e saída corretamente."
				lRet := .F.
				Exit
			Endif
		Endif
	Next nX
Endif

oMdl:Goline(nLine)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At581Cob()
@description Lista a cobertura do efetivo por escala, turno e sequência.

@author Kaique Schiller
@since 22/05/2018
@return cRet
/*/
//------------------------------------------------------------------
Static Function At581Cob( cEscala, cConfCob, cTurno, cSeq )
Local aRet 	  	:= {}
Local cAliasTGW := GetNextAlias()
Local aCobEfe   := {}

BeginSql Alias cAliasTGW

	SELECT 
		TGW.TGW_DIASEM, TGW.TGW_HORINI, TGW.TGW_HORFIM, 
		TGW.TGW_STATUS, TGW.TGW_COBTDX, TGW.TGW_COBTIP
	FROM 
		%table:TGW% TGW
	JOIN %table:TDX% TDX ON 
		TDX.TDX_FILIAL = %xFilial:TDX% AND
		TDX.TDX_CODTDW = %Exp:cEscala% AND
		TDX.TDX_TURNO  = %Exp:cTurno%  AND
		TDX.TDX_SEQTUR = %Exp:cSeq%	   AND
		TDX.%NotDel%
	JOIN %table:TGX% TGX ON
		TGX.TGX_FILIAL = %xFilial:TGX% AND
		TGX.TGX_CODTDW = %Exp:cEscala% AND 
		TGX.TGX_COD	   = %Exp:cConfCob% AND 
		TGX.TGX_ITEM   = TGW.TGW_COBTDX AND
		TGX.%NotDel%
	WHERE
		TGW.TGW_FILIAL = %xFilial:TGW% AND 
		TGW.TGW_EFETDX = TDX.TDX_COD   AND 
		TGW.TGW_COBTDX <> ' ' 		   AND 
		TGW.%NotDel%

EndSql

While (cAliasTGW)->(!Eof())

	aAdd( aCobEfe, { 	(cAliasTGW)->TGW_DIASEM,;	//Dia da Semana
						(cAliasTGW)->TGW_HORINI,;	//Hora Inicio
						(cAliasTGW)->TGW_HORFIM } ) //Hora Final

	(cAliasTGW)->(dbSkip())

EndDo

(cAliasTGW)->(dbCloseArea())

aRet := aCobEfe

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} At581VldSeq()
@description Validação da sequência no cadastro de escala.

@author Kaique Schiller
@since 30/09/2019
@return lRet
/*/
//------------------------------------------------------------------
Function At581VldSeq(cEscala,cTurno,cSeq)
Local lRet 		:= .T.
Local cAliasTDX := GetNextAlias()
Default cEscala	:= ""
Default cTurno	:= ""	
Default cSeq	:= ""

If !Empty(cEscala) .And. !Empty(cTurno) .And. !Empty(cSeq)

	BeginSql Alias cAliasTDX
		SELECT 1
		FROM %table:TDX% TDX
		WHERE TDX.TDX_FILIAL = %xFilial:TDX%
			AND TDX.TDX_CODTDW = %Exp:cEscala%
			AND TDX.TDX_TURNO  = %Exp:cTurno%
			AND TDX.TDX_SEQTUR = %Exp:cSeq%
			AND TDX.%NotDel%
	EndSql

	If (cAliasTDX)->(Eof())
		Help(,,"At581VldSeq",,STR0106, 1, 0,,,,,,{STR0107}) //"Não foi possível encontrar a sequência no cadastro de escalas."##"Informe uma sequência válida."
		lRet := .F.
	Endif
	
	(cAliasTDX)->(dbCloseArea())

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At581UpRot()
@description Atualização do código da TFF na rota de cobertura.

@author luiz.jesus
@since 30/09/2019
@return lRet
/*/
//------------------------------------------------------------------
Function At581UpRot(cCodTFJ)
Local cTmpQry 	:= ""
Local aCodTFF   := At870CodTFF( cCodTFJ )
Local cSqlTFF   := ""
Local nPosTFF   := 0
Local nI		:= 0
Local cWhere	:= ""
Local cTW1EUF	:= FWModeAccess("TW1",1) + FWModeAccess("TW1",2) + FWModeAccess("TW1",3)

If Len(aCodTFF) > 0

	cTmpQry := GetNextAlias()

	If TW1->(ColumnPos("TW1_FILTFF") > 0) .And. cTW1EUF <> "EEE"
		cWhere := " AND TW1.TW1_FILTFF = '"+ xFilial("TFF") +"'"
	Endif

	cWhere := "%"+cWhere+"%"

	cSqlTFF := "%("

	For nI:=1 To Len(aCodTFF)

		cSqlTFF += "'" + aCodTFF[ nI, 1 ] + "'"

		If (nI+1) <= Len(aCodTFF)
			cSqlTFF += ","
		EndIf

	Next nI

	cSqlTFF += ")%"
	
	BeginSql Alias cTmpQry
		SELECT TW1.TW1_CODTFF, 
			TW1.R_E_C_N_O_
		FROM %table:TW1% TW1
		WHERE TW1.TW1_FILIAL   = %xFilial:TW1% 
			%Exp:cWhere% 
			AND TW1.TW1_CODTFF IN %Exp:cSqlTFF% 
			AND TW1.%NotDel%
	EndSql
	
	DbSelectArea("TW1")
	TW1->(DbSetOrder(1))
	While (cTmpQry)->(!Eof())
		TW1->(DBGoTo((cTmpQry)->(R_E_C_N_O_)))
		nPosTFF := aScan( aCodTFF, { |x| x[1] == (cTmpQry)->TW1_CODTFF } )
		If nPosTFF > 0
			RecLock("TW1", .F.)
			TW1->TW1_CODTFF := aCodTFF[ nPosTFF, 2 ]
			TW1->(MsUnlock())
		EndIf	
		(cTmpQry)->(DbSkip())
	EndDo
	
	(cTmpQry)->(DbCloseArea())

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At581DtCob()
@description Seleciona a data de cobertura da TGZ.

@author Kaique Schiller
@since 01/10/2019
@return aDtIniFim
/*/
//------------------------------------------------------------------
Function At581DtCob(cCodRt,cAtend)
Local cAliasTGZ := GetNextAlias()
Local cQry		:= GetNextAlias()
Local aDtIniFim	:= {sTod(""),sTod("")}
Local oModel	:= Nil
Local cSql		:= ""
Local cComTW1 	:= FwModeAccess("TW1",1) +  FwModeAccess("TW1",2) + FwModeAccess("TW1",3)
Local cComTGZ 	:= FwModeAccess("TGZ",1) +  FwModeAccess("TGZ",2) + FwModeAccess("TGZ",3)
Local cComTFF	:= FwModeAccess("TFF",1) +  FwModeAccess("TFF",2) + FwModeAccess("TFF",3)
Local lMtFIl	:= cComTFF == "EEE" .AND. (LEN(STRTRAN( cComTW1  , "E" )) > LEN(STRTRAN(  cComTGZ  , "E" ))) .AND. TW1->(ColumnPos("TW1_FILTFF")) > 0
Local cSpaceFil := SPACE(LEN(cFilAnt))
Default cCodRt := "" 
Default cAtend := ""

If Empty(cCodRt)
	oModel := FwModelActive()
	cCodRt := oModel:GetModel():GetModel("TW0MASTER"):GetValue("TW0_COD")
	cAtend := oModel:GetModel():GetModel("TW0MASTER"):GetValue("TW0_ATEND")
EndIf

If !Empty(cCodRt)
	If lMtFIl
		BeginSQL Alias cQry
			SELECT 1 REC
				FROM %Table:TW1% TW1
				WHERE TW1.TW1_FILIAL = %xFilial:TW1%
				AND TW1.%NotDel%
				AND TW1.TW1_CODTW0 = %Exp:cCodRt%
				AND TW1.TW1_FILTFF = %Exp:cSpaceFil%
		EndSQL
		lMtFIl := (cQry)->(EOF())
		(cQry)->(DbCloseArea())
	EndIf
	
	cSql += " SELECT MIN(TGZ.TGZ_DTINI) TGZ_DTINI, MAX(TGZ.TGZ_DTFIM) TGZ_DTFIM "
	cSql += " FROM " + RetSqlName("TGZ") + " TGZ "
	If lMtFIl .AND. !Empty(cAtend) .AND. !Empty(cCodRt)
		cSql += " INNER JOIN "  + RetSqlName("TW1") + " TW1 ON "
		cSql += " TW1.TW1_CODTW0 = TGZ.TGZ_CODTW0 AND "
		cSql += " TW1.TW1_CODTFF = TGZ.TGZ_CODTFF AND "
		cSql += " TW1.TW1_FILTFF = TGZ.TGZ_FILIAL AND "
		cSql += " TW1.D_E_L_E_T_= ' ' AND "
		cSql += " TW1.TW1_FILIAL = '" + xFilial("TW1") + "' "
	EndIf
	cSql += " WHERE "
	If !lMtFIl
		cSql += " TGZ.TGZ_FILIAL = '" + xFilial("TGZ") + "' AND "
	EndIf
	If !Empty(cCodRt)
		cSql += " TGZ.TGZ_CODTW0 = '"+ cCodRt +"' "
	EndIf 
	If !Empty(cAtend)
		cSql += " AND TGZ.TGZ_ATEND = '"+ cAtend +"' "
	EndIf	
	cSql += " AND TGZ.TGZ_DTINI <> '' "
	cSql += " AND TGZ.D_E_L_E_T_= ' ' "
		
	cSql := ChangeQuery(cSql)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasTGZ, .F., .T.)

	If (cAliasTGZ)->(!Eof())
		aDtIniFim[1] := sTod((cAliasTGZ)->TGZ_DTINI)
		aDtIniFim[2] := sTod((cAliasTGZ)->TGZ_DTFIM)
 	Endif
	
	(cAliasTGZ)->(dbCloseArea())

Endif

Return aDtIniFim

//-------------------------------------------------------------------
/*/{Protheus.doc} At581Eftv()
@description Função com o msgrun da efetivação.

@author Kaique Schiller
@since 01/10/2019
@return lRet
/*/
//------------------------------------------------------------------
Function At581Eftv(cTpOper, cRota, dDatabase, cAtdMvRmv, lAutomato, dDtIniRt,dDtFimRt, dDtIniTGZ, dDtFimTGZ,cDesAten)
Local lRet := .F.
Local lSemEfet := SuperGetMv("MV_GSRTAUT",,.F.)
Local cFIlFun	:= Posicione("AA1", 1, xFilial("AA1")+cAtdMvRmv, "AA1_FUNFIL")
Local cCodFun	:= Posicione("AA1", 1, xFilial("AA1")+cAtdMvRmv, "AA1_CDFUNC")
Local dDtAdmiss  := Posicione("SRA", 1, cFIlFun+cCodFun + cDesAten, "RA_ADMISSA")
Local lVldDt := (dDtAdmiss > dDtIniRt)
local lHasABB := RotaAgend(cRota,dDtIniRt,dDtFimRt) 
Local lRotaVaga := At581RtVag() .And. Posicione("TW0",1,xFilial("TW0")+cRota,"TW0_VAGA") == "1"

DO CASE
	Case cTpOper == "MV" .AND. !lHasABB 
		Help( " ", 1, "NOAGENDA", Nil, STR0178, 2 ) // "Rota não movimentada, pois não existe agenda para o periodo informado"
		lRet := .F.
	Case lVldDt
		Help( " ", 1, "DTADMISS", Nil, STR0173, 2 ) //"Operação não pode ser realizada pois a data inicial é inferior a data de Admissão do atendente"
		lRet := .F.
	Case cTpOper == "MV"
		If !lSemEfet
			MsgRun(STR0109,STR0108,{|| ( lRet := At581Efet(cTpOper, cRota, dDatabase, cAtdMvRmv, lAutomato, dDtIniRt,dDtFimRt,dDtIniTGZ,dDtFimTGZ ) ) }) // "Realizando a movimentação do atendente."##"Aguarde"
		Else
			MsgRun(STR0109,STR0108,{|| ( lRet := At581Mov(cRota, dDatabase, cAtdMvRmv, lAutomato, dDtIniRt,dDtFimRt,dDtIniTGZ,dDtFimTGZ) ) }) // "Realizando a movimentação do atendente."##"Aguarde"
		EndIF
	Case cTpOper == "RE"
		MsgRun(STR0110,STR0108,{|| ( lRet := At581Efet(cTpOper, cRota, dDatabase, cAtdMvRmv, lAutomato, dDtIniRt,dDtFimRt,dDtIniTGZ,dDtFimTGZ ) ) }) // "Realizando a remoção do atendente."#"Aguarde"
	Case cTpOper == "CA"
		MsgRun(STR0111,STR0108,{|| lRet := At581Efet(cTpOper, cRota, dDatabase, cAtdMvRmv, lAutomato, dDtIniRt,dDtFimRt,dDtIniTGZ,dDtFimTGZ )}) // "Realizando o cancelamento da agenda."#"Aguarde"
	Case cTpOper == "TR"
		MsgRun(STR0110,STR0108,{|| ( lRet := At581Efet("RE", cRota, dDatabase, cAtdMvRmv, lAutomato, dDtIniRt,dDtFimRt,dDtIniTGZ,dDtFimTGZ,.T. ) ) })
		If lRet
			If At581GsRota()
				If lRotaVaga
					At581AlcTr(cAtdMvRmv,dDtIniRt,dDtFimRt)
				Else
					MsgRun(STR0109,STR0108,{|| ( lRet := At581ARtLt({cRota,cAtdMvRmv,dDtIniRt,dDtFimRt} )) })
				Endif		
			Else
				MsgRun(STR0109,STR0108,{|| ( lRet := At581Efet("MV", cRota, dDatabase, cAtdMvRmv, lAutomato, dDtIniRt,dDtFimRt,dDtIniTGZ,dDtFimTGZ, .T. ) ) })
			Endif		
		EndIf	
END CASE
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581ExAg

@description Realiza a exclusão das agendas dos atendentes

@param cCodAtend - Código do atendente que terá a agenda excluida
@param dDataIni - Data inicial a ser considerada para exclusão
@param cCodTFF - codigo do posto que terá a agenda excluida
@param cMsg - Mensagem de erro

@return lRet, Logico, Indica se a exclusão foi feita com sucesso

@author	Luiz Gabriel
@since	01/10/2019
/*/
//------------------------------------------------------------------------------
Static Function At581ExAg(cCodAtend, dDataIni, cCodTFF, cMsg, dDtIniRt, cHoraIni, cHoraFim, cCodTGX, cCodTW1,cAtendFlex)
Local lRet := .T.
Local cAliQry := GetNextAlias()
Local cQryTGW	:= GetNextAlias()
Local aMarks := {}
Local aBkpMarks := {}
Local cWhereINI	:= " IN ("
Local cWhereFIM	:= " IN ("
Local cWhereABB := "%%"
Local aHrFlex   := {}
Local nX		:= 0
Local cTipoRt	:= Posicione("TGX", 1,  xFilial("TGX")+cCodTGX, "TGX_TIPO")
Default cMsg		:= ""
Default cHoraIni	:= ""
Default cHoraFim	:= ""
Default cCodTGX		:= ""
Default cCodTW1		:= ""
Default nGrupo		:= ""
Default cAtendFlex	:= ""

aMarks := {}

If !Empty(cCodTW1)
	cWhereABB := "% ABB.ABB_CODTW1 = '"+ cCodTW1 +"' AND %"
Else
	If cHoraIni > 0 .OR. cHoraFim > 0 
		cWhereINI += "'" + TecConvHr(cHoraIni) + "'"
		cWhereFIM += "'" + TecConvHr(cHoraFim) + "'"
	Else
		If cTipoRt == "1"
			aHrFlex := At581HrFlx(cCodTFF,cAtendFlex,nGrupo)
			For nX := 1 To Len(aHrFlex[1]) Step 2
				If !Empty(aHrFlex[1,nX]) .And. !(aHrFlex[1,nX] $ cWhereINI)
					cWhereINI += "'" + aHrFlex[1,nX] + "',"
				EndIf
				If !Empty(aHrFlex[1,nX+1]) .And. !(aHrFlex[1,nX+1] $ cWhereFIM)
					cWhereFIM += "'" + aHrFlex[1,nX+1] + "',"
				EndIf
			Next nX
		Else
			BeginSQL Alias cQryTGW
				Select	TGW.TGW_HORINI, 
						TGW.TGW_HORFIM
				FROM
					%Table:TGW% TGW
				INNER JOIN %Table:TGX% TGX
					ON TGX.TGX_FILIAL = %xFilial:TGX%
					AND TGX.TGX_COD	= %Exp:cCodTGX%
					AND TGX.%NotDel%
				INNER JOIN %Table:TDX% TDX
					ON TDX.TDX_FILIAL = %xFilial:TDX%
					AND TDX.TDX_CODTDW = TGX.TGX_CODTDW
					AND TDX.%NotDel%
				WHERE 
					TGW.TGW_FILIAL = %xFilial:TGW%
					AND TGW.TGW_EFETDX = TDX.TDX_COD
					AND TGW.TGW_COBTDX = TGX.TGX_ITEM
					AND TGW.%NotDel%
			EndSQL
			Do While !(cQryTGW)->(Eof())
				If !(TecConvHr((cQryTGW)->TGW_HORINI) $ cWhereINI)
					cWhereINI += "'" + TecConvHr((cQryTGW)->TGW_HORINI) + "',"
				EndIf
				If !(TecConvHr((cQryTGW)->TGW_HORFIM) $ cWhereFIM)
					cWhereFIM += "'" + TecConvHr((cQryTGW)->TGW_HORFIM) + "',"
				EndIf
				(cQryTGW)->(DbSkip())
			EndDo
			(cQryTGW)->(DbCloseArea())
		Endif
		cWhereINI := SubStr(cWhereINI, 1, Len(cWhereINI)-1)
		cWhereFIM := SubStr(cWhereFIM, 1, Len(cWhereFIM)-1)
	EndIf
	cWhereINI += " )"
	cWhereFIM += " )"
	cWhereABB := "% ABB.ABB_HRINI "+ cWhereINI +" AND "
	cWhereABB += " ABB.ABB_HRFIM "+ cWhereFIM +" AND %"
Endif

BeginSql Alias cAliQry
	 Column ABB_DTINI as Date
	 Column ABB_DTFIM as Date
	 Column ABB_DTREF as Date

	 Select TDV.TDV_DTREF AS ABB_DTREF,
	 		ABB.ABB_CODIGO,
	 		ABB.ABB_DTINI,
	 		ABB.ABB_DTFIM,
	 		ABB.ABB_CODTEC,
	 		ABB.ABB_HRINI,
	 		ABB.ABB_HRFIM,
	 		ABB.ABB_ATENDE,
	 		ABB.ABB_CHEGOU,
	 		ABB.ABB_MANUT,
	 		ABB.ABB_IDCFAL,
	 		ABQ.ABQ_CODTFF,
			ABB.ABB_FILIAL 
	 From
	 	%Table:TDV% TDV,
	 	%Table:ABQ% ABQ,
	 	%Table:ABB% ABB
	 Where
	 	ABB.ABB_CODIGO = TDV.TDV_CODABB AND
	 	TDV.TDV_DTREF <= %exp:dDataIni% AND
		TDV.TDV_DTREF >= %exp:dDtIniRt% AND
	 	TDV.TDV_FILIAL = %xFilial:TDV% AND
	 	TDV.%NotDel% AND
	 	ABQ.ABQ_CONTRT||ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL AND
	 	ABB.ABB_CODTEC =  %Exp:cCodAtend% AND
	 	ABB.ABB_FILIAL = %xFilial:ABB% AND
		%Exp:cWhereABB%
	 	ABB.%NotDel% AND
	 	ABQ.ABQ_CODTFF = %exp:cCodTFF% AND
	 	ABQ.ABQ_FILIAL = %xFilial:ABQ% AND
	 	ABQ.%NotDel%
	 ORDER BY TDV.TDV_DTREF, ABB.ABB_DTINI, ABB.ABB_HRINI, ABB.ABB_DTFIM
	 
EndSql

Do While ! (cAliQry)->(Eof())
	
	AADD(aMarks, {(cAliQry)->ABB_CODIGO,;
				  (cAliQry)->ABB_DTINI,;
				  (cAliQry)->ABB_HRINI,;
				  (cAliQry)->ABB_DTFIM,;
				  (cAliQry)->ABB_HRFIM,;
				  (cAliQry)->ABB_ATENDE,;
				  (cAliQry)->ABB_CHEGOU,;
				  (cAliQry)->ABB_IDCFAL,;
				  (cAliQry)->ABB_DTREF,;
				  .F.,;
				  (cAliQry)->ABQ_CODTFF,;
				  (cAliQry)->ABB_FILIAL })
	
	(cAliQry)->(DbSkip(1))

EndDo

(cAliQry)->(DbCloseArea())

If Len(aMarks) > 0
	aBkpMarks := AClone(At190DSMar())	
	At190DSMar(aMarks)
	lRet := At190DDlt(.F., .T., cCodAtend, @cMsg)
	At190DSMar(aBkpMarks)
EndIf
 				
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581UpTFF

@description Função para atualizar o campo TW1_CODTFF com registros
com codigos não duplicados em outras filiais

@author	Luiz Gabriel
@since 26/03/2020
/*/
//------------------------------------------------------------------------------
Function At581UpTFF()
Local cTmpQry 	:= GetNextAlias()
Local aCodTFF   := At581TFF()
Local cSqlTFF   := ""
Local nI		:= 0
Local lFilTFF	:= TW1->(ColumnPos("TW1_FILTFF") > 0)

cSqlTFF := "%("
If Len(aCodTFF) > 0

	For nI:=1 To Len(aCodTFF)

		cSqlTFF += "'" + aCodTFF[ nI ] + "'"

		If (nI+1) <= Len(aCodTFF)
			cSqlTFF += ","
		EndIf

	Next nI
	cSqlTFF += ")%"


	BeginSql Alias cTmpQry
		SELECT T1.TFF_FILIAL,
			T1.TFF_COD,
			TW1.TW1_COD,
			TW1.R_E_C_N_O_,
			(T2.TFF_FILIAL) as FIL2,
			(T2.TFF_COD) as TFF2 
		FROM  %table:TFF% T1
		LEFT JOIN %table:TFF% T2 on T1.TFF_FILIAL = T2.TFF_FILIAL
									AND T2.%NotDel%
									AND T1.TFF_CONTRT = T2.TFF_CONTRT
									AND T2.TFF_CODSUB = ' ' 
									AND T1.TFF_PRODUT = T2.TFF_PRODUT 
									AND T1.TFF_LOCAL = T2.TFF_LOCAL 
									AND T1.TFF_ITEM = T2.TFF_ITEM
		INNER JOIN %table:TW1% TW1 on T1.TFF_COD = TW1.TW1_CODTFF 
									AND TW1.%NotDel%
		WHERE T1.TFF_CODSUB <> ''
			AND T1.TFF_COD IN %exp:cSqlTFF%
			AND T1.%NotDel%
	EndSql

	DbSelectArea("TW1")
	TW1->(DbSetOrder(1))
	While (cTmpQry)->(!Eof())
		TW1->(DBGoTo((cTmpQry)->(R_E_C_N_O_)))
		RecLock("TW1", .F.)
			TW1->TW1_CODTFF := (cTmpQry)->TFF2
			If lFilTFF
				TW1->TW1_FILTFF := (cTmpQry)->FIL2
			EndIf
		TW1->(MsUnlock())
		(cTmpQry)->(DbSkip())
	EndDo
	(cTmpQry)->(DbCloseArea())
EndIf 

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581TFF

@description Realiza a busca dos registros que não estão duplicados para realizar 
a atualização

@author	Luiz Gabriel
@since 26/03/2020
/*/
//------------------------------------------------------------------------------
Static Function At581TFF()
Local aTFF 		:= {}
Local cAliasTFF	:= ""
Local cTW1EUF	:= FWModeAccess("TW1",1) + FWModeAccess("TW1",2) + FWModeAccess("TW1",3)

If cTW1EUF <> "EEE"
	cAliasTFF	:= GetNextAlias()
	BeginSql Alias cAliasTFF
		SELECT TFF.TFF_COD, Count(TFF_COD) as NumTFF 
		FROM  %table:TFF% TFF
		WHERE 
			TFF. TFF_COD IN (Select TFF_COD 
								FROM %table:TFF% TFF1 
								WHERE TFF1.TFF_COD in (SELECT TW1_CODTFF 
														FROM %table:TW1% TW1 
														WHERE TW1.D_E_L_E_T_ = '') 
								AND TFF1.TFF_CODSUB <> '' 
								AND TFF1.%NotDel%)
		AND TFF.%NotDel%
		GROUP BY TFF.TFF_COD
		Having Count(TFF_COD) = 1
	EndSql

	While (cAliasTFF)->(!Eof())
		aAdd( aTFF, (cAliasTFF)->TFF_COD )
		(cAliasTFF)->(DbSkip())
	EndDo
		
	(cAliasTFF)->(DbCloseArea())

EndIf	

Return aTFF
//-------------------------------------------------------------------
/*/{Protheus.doc} AT581Ativ()
Ativa / Inativa a rota de cobertura

@author Luiz Gabriel
@since 13/05/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function AT581Ativ()
Local lRet 		:= .F.
Local cMsg 		:= ""
Local lStatus	:= TW0->( ColumnPos('TW0_STATUS')) > 0
Local cCodigo	:= Iif(lStatus,TW0->TW0_COD,"")
Local cStatus	:= Iif(lStatus,TW0->TW0_STATUS,"")

If lStatus
	If cStatus == DEF_TW0_INATIVO
		lRet := AT581AltSt(cCodigo, DEF_TW0_ATIVO)
		cMsg := STR0121 //"Ativado"
	ElseIf cStatus == DEF_TW0_ATIVO .Or. Empty(cStatus)
		lRet := AT581AltSt(cCodigo, DEF_TW0_INATIVO)
		cMsg := STR0122 //"Inativado"
	EndIf

	If lRet
		MsgInfo(STR0123 + " " + ALLTRIM(cCodigo) +; //"Rota de Cobertura"
					" " + cMsg + STR0124, STR0120 ) //" com sucesso" ## "Inativar / Ativar"
	EndIf
Else 
	MsgInfo(STR0127, STR0120 ) //"Opção não disponivel nessa versão" ## "Inativar / Ativar"
EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AT581AltSt()
Altera o status da rota de cobertura

@author Luiz Gabriel
@since 13/05/2020

@param cCodRot, string, código da rota de cobertura
@param cNewStatus, string, novo status da rota de cobertura

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AT581AltSt(cCodRot, cNewStatus)
Local aArea := GetArea()
Local lRet := .F.

DbSelectArea("TW0")
DbSetOrder(1)
If ( lRet := TW0->(MsSeek(xFilial("TW0")+cCodRot)) )
	RecLock("TW0", .F.)
		TW0->TW0_STATUS := cNewStatus
	MsUnlock()
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At581MLote()
Abre a tela de movimentação em lote

@author Luiz Gabriel
@since 29/07/2020

/*/
//-------------------------------------------------------------------
Function At581MLote()
Local oModel := NIL
Local aButtons := {}

oModel := FwModelActive()
aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0140},; //"Movimentar"
				{.T.,STR0141},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // "Fechar"

FWExecView( " ", "VIEWDEF.TECA581A", MODEL_OPERATION_INSERT, /*oDlg*/, {||.T.}/*bCloseOk*/,	{||.T.}/*bOk*/,0, aButtons, {||.T.}/*bCancel*/ ) //"Movimentação em Lote"
FwModelActive(oModel)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} At581GrLog()
Cria o texto de log para a movimentação em lote da rota

@author Luiz Gabriel
@since 29/07/2020

/*/
//-------------------------------------------------------------------
Static Function At581GrLog(aErro,cMsgShwLog,cCodTFF, lManut)

Default lManut := .F.
If lManut
	If Empty(cMsgShwLog)
		cMsgShwLog := STR0172 + CRLF + CRLF //"Ocorreram erros ao processar exclusão da manutenção de Hora Extra."
	EndIf
Else
	cMsgShwLog := STR0128+cCodTFF+CRLF		//"Problemas na movimentação do Item RH: "
EndIf

If Len(aErro) > 0
	cMsgShwLog += 	" "+CRLF+STR0129+CRLF; //"Erro na movimentação da Rota"
					+" "+CRLF+STR0130+'['+ AllToChar( aErro[1] )+']'+CRLF;	//"Id do formulário de origem:"
					+" "+STR0131+'['+ AllToChar( aErro[2] ) +']'+CRLF;		//"Id do campo de origem: "
					+" "+STR0132+'['+ AllToChar( aErro[3] ) +']'+CRLF;		//"Id do formulário de erro: "
					+" "+STR0133+'['+ AllToChar( aErro[4] ) +']'+CRLF;		//"Id do campo de erro: "
					+" "+STR0134+'['+ AllToChar( aErro[5] ) +']'+CRLF;		//"Id do erro: "
					+" "+STR0135+'['+ AllToChar( aErro[6] ) +']'+CRLF;		//"Mensagem do erro: "
					+" "+STR0136+'['+ AllToChar( aErro[7] ) +']'+CRLF;		//"Mensagem da solução: "
					+" "+STR0137+'['+ AllToChar( aErro[8] ) +']'+CRLF;		//"Valor atribuído: "
					+" "+STR0138+'['+ AllToChar( aErro[9] ) +']'+CRLF;		//"Valor anterior: "
	    			+CRLF+"---------------------------------------------------"+CRLF+CRLF
EndIf

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} RetDtRota()
@description Seleciona a data de cobertura da TGZ.

@author mateus Boiani
@since 04/08/2020
@return aDtIniFim
/*/
//------------------------------------------------------------------
Static Function RetDtRota(cCodTFF, cCodRt, cAtend, cCodTDX, cEscala, cFilTFF)
Local cAliasTGZ := GetNextAlias()
Local aDtIniFim	:= {sTod(""),sTod("")}
Local cSql := ""
Local cComTW0 := FwModeAccess("TW0",1) +  FwModeAccess("TW0",2) + FwModeAccess("TW0",3)
Local cComTGZ := FwModeAccess("TGZ",1) +  FwModeAccess("TGZ",2) + FwModeAccess("TGZ",3)
Local cComTFF := FwModeAccess("TFF",1) +  FwModeAccess("TFF",2) + FwModeAccess("TFF",3)
Local lMultFil := LEN(STRTRAN( cComTW0  , "E" )) > LEN(STRTRAN(  cComTGZ  , "E" )) .AND. cComTFF == "EEE"

Default cCodTFF := ""
Default cCodRt := "" 
Default cAtend := ""
Default cFilTFF := xFilial("TFF")

If !Empty(cCodRt) .AND. !EMPTY(cAtend) .AND. !EMPTY(cCodTFF) .AND. !EMPTY(cEscala)
	cSql += " SELECT TGZ.TGZ_DTINI, TGZ.TGZ_DTFIM "
	cSql += " FROM " + RetSqlName( "TGZ" ) + " TGZ WHERE "
	If lMultFil
		cSql += " TGZ.TGZ_FILIAL = '" + xFilial("TGZ",cFilTFF) + "'
	Else
		cSql += " TGZ.TGZ_FILIAL = '" + xFilial("TGZ") + "'
	EndIf
	cSql += " AND TGZ.TGZ_CODTW0 = '"+ cCodRt +"' "
	cSql += " AND TGZ.TGZ_ATEND = '"+ cAtend +"' "
	cSql += " AND TGZ.TGZ_ESCALA = '"+ cEscala + "' "
	cSql += " AND TGZ.TGZ_CODTFF = '" + cCodTFF +"' "
	cSql += " AND TGZ.TGZ_CODTDX = '" + cCodTDX + "' "
	cSql += " AND TGZ.D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasTGZ, .F., .T.)

	If (cAliasTGZ)->(!Eof())
		aDtIniFim[1] := sTod((cAliasTGZ)->TGZ_DTINI)
		aDtIniFim[2] := sTod((cAliasTGZ)->TGZ_DTFIM)
 	Endif
	
	(cAliasTGZ)->(dbCloseArea())

Endif

Return aDtIniFim

//-------------------------------------------------------------------
/*/{Protheus.doc} At581AtTGY
@description Função para montar o browse do F3
@return xValue
@author Augusto Albuquerque
@since  22/10/2020
/*/
//------------------------------------------------------------------
Function At581AtTGY()
Local aIndex    := {}
Local aSeek     := {}
Local oModel 	:= FwModelActive()
Local oMdlTW1	:= oModel:GetModel("TW1DETAIL")
Local cQuery	:= ""
Local cProfID	:= "ATETGY"
Local cAlsTGY	:= "ATENDTGY"
Local lRet		:= .T.

Aadd( aSeek, { STR0146, {{"","C",TamSX3("TGY_ATEND")[1],0,STR0146,,"TGY_ATEND"}} } )	//"Codigo do Tec." # "Codigo do Tec."
Aadd( aSeek, { STR0147, {{"","C",TamSX3("AA1_NOMTEC")[1],0,STR0147,,"AA1_NOMTEC"}} } ) //"Nome do Tec."
Aadd( aSeek, { STR0148, {{"","D",TamSX3("TGY_DTINI")[1],0,STR0148,,"TGY_DTINI"}} } ) //"Data Ini"
Aadd( aSeek, { STR0149, {{"","D",TamSX3("TGY_DTFIM")[1],0,STR0149,,"TGY_DTFIM"}} } ) //"Data Fim"
Aadd( aSeek, { STR0150, {{"","D",TamSX3("TGY_ULTALO")[1],0,STR0150,,"TGY_ULTALO"}} } ) //"Data de Ultima Aloc"
Aadd( aSeek, { STR0151, {{"","C",TamSX3("TGY_SEQ")[1],0,STR0151,,"TGY_SEQ"}} } ) //"Ultima Seq. ALoc."
Aadd( aSeek, { STR0152, {{"","C",TamSX3("TDX_SEQTUR")[1],0,STR0152,,"TDX_SEQTUR"}} } ) //"Seq. da Escala"
Aadd( aSeek, { STR0153, {{"","C",TamSX3("TGY_ENTRA1")[1],0,STR0153,,"TGY_ENTRA1"}} } )	//"Hora Ini 1"
Aadd( aSeek, { STR0154, {{"","C",TamSX3("TGY_SAIDA1")[1],0,STR0154,,"TGY_SAIDA1"}} } ) //"Hora Fim 1"
Aadd( aSeek, { STR0155, {{"","C",TamSX3("TGY_ENTRA2")[1],0,STR0155,,"TGY_ENTRA2"}} } )	//"Hora Ini 2"
Aadd( aSeek, { STR0156, {{"","C",TamSX3("TGY_SAIDA2")[1],0,STR0156,,"TGY_SAIDA2"}} } ) //"Hora Fim 2"
Aadd( aSeek, { STR0157, {{"","C",TamSX3("TGY_ENTRA3")[1],0,STR0157,,"TGY_ENTRA3"}} } )	//"Hora Ini 3"
Aadd( aSeek, { STR0158, {{"","C",TamSX3("TGY_SAIDA3")[1],0,STR0158,,"TGY_SAIDA3"}} } ) //"Hora Fim 3"
Aadd( aSeek, { STR0159, {{"","C",TamSX3("TGY_ENTRA4")[1],0,STR0159,,"TGY_ENTRA4"}} } )	//"Hora Ini 4"
Aadd( aSeek, { STR0160, {{"","C",TamSX3("TGY_SAIDA4")[1],0,STR0160,,"TGY_SAIDA4"}} } ) //"Hora Fim 4"

Aadd( aIndex, "TGY_ATEND" )
Aadd( aIndex, "AA1_NOMTEC" )
Aadd( aIndex, "TGY_DTINI" )
Aadd( aIndex, "TGY_DTFIM" )
Aadd( aIndex, "TGY_ULTALO" )
Aadd( aIndex, "TGY_SEQ" )
Aadd( aIndex, "TDX_SEQTUR" )
Aadd( aIndex, "TGY_ENTRA1" )
Aadd( aIndex, "TGY_SAIDA1" )
Aadd( aIndex, "TGY_ENTRA2" )
Aadd( aIndex, "TGY_SAIDA2" )
Aadd( aIndex, "TGY_ENTRA3" )
Aadd( aIndex, "TGY_SAIDA3" )
Aadd( aIndex, "TGY_ENTRA4" )
Aadd( aIndex, "TGY_SAIDA4" )

cQuery := ""
cQuery += " SELECT TGY.TGY_ATEND, AA1.AA1_NOMTEC, TGY.TGY_ENTRA1, TGY.TGY_SAIDA1, "
cQuery += " TGY.TGY_ENTRA2, TGY.TGY_SAIDA2, TGY.TGY_ENTRA3, TGY.TGY_SAIDA3, TGY.TGY_ENTRA4, TGY.TGY_SAIDA4, "
cQuery += " TGY.TGY_ULTALO, TGY.TGY_DTINI, TGY.TGY_DTFIM, TGY.TGY_SEQ, TDX.TDX_SEQTUR  "
cQuery += " FROM " + RetSqlName("TGY") + " TGY "
cQuery += " INNER JOIN " + RetSqlName("AA1") + " AA1 ON "
cQuery += " AA1.AA1_CODTEC = TGY.TGY_ATEND "
cQuery += " AND AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
cQuery += " AND AA1.D_E_L_E_T_ = '' "
cQuery += " INNER JOIN " + RetSqlName("TDX") + " TDX ON "
cQuery += " TDX.TDX_COD = TGY.TGY_CODTDX "
cQuery += " AND TDX.TDX_FILIAL = '" + xFilial("TDX") + "' "
cQuery += " AND TDX.D_E_L_E_T_ = '' "
cQuery += " WHERE "
cQuery += " TGY.TGY_FILIAL = '" + xFilial("TGY") + "' "
cQuery += " AND TGY.TGY_CODTFF = '" + oMdlTW1:GetValue("TW1_CODTFF") + "' "
cQuery += " AND TGY.TGY_GRUPO = '" + cValToChar(oMdlTW1:GetValue("TW1_GRUPO")) + "' "
cQuery += " AND TGY.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)

nSuperior := 0
nEsquerda := 0

nInferior := GetScreenRes()[2] * 0.6
nDireita  := GetScreenRes()[1] * 0.65

DEFINE MSDIALOG oDlgEscTela TITLE STR0161 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Atendentes Efetivos"

oBrowse := FWFormBrowse():New()
oBrowse:SetOwner(oDlgEscTela)
oBrowse:SetDataQuery(.T.)
oBrowse:SetAlias(cAlsTGY)
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetQuery(cQuery)
oBrowse:SetSeek(,aSeek)
oBrowse:SetDescription( STR0161 ) //"Atendentes Efetivos"
oBrowse:SetMenuDef("")
oBrowse:DisableDetails()
oBrowse:SetProfileID(cProfID)

At190SetFlt(aSeek, @oBrowse)

oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->TGY_ATEND, lRet := .T. ,oDlgEscTela:End()})
oBrowse:AddButton( OemTOAnsi(STR0162), {|| cRetF3  := (oBrowse:Alias())->TGY_ATEND, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
oBrowse:AddButton( OemTOAnsi(STR0163),  {|| cRetF3  := "", oDlgEscTela:End() } ,, 2 )	//"Cancelar"
oBrowse:DisableDetails()

	ADD COLUMN oColumn DATA { ||  TGY_ATEND  } TITLE STR0146 SIZE TamSX3("TGY_ATEND")[1] OF oBrowse //"Codigo do Tec."
	ADD COLUMN oColumn DATA { ||  AA1_NOMTEC  } TITLE STR0147 SIZE TamSX3("AA1_NOMTEC")[1] OF oBrowse	//"Nome do Tec."
	ADD COLUMN oColumn DATA { ||  sTod(TGY_DTINI)  } TITLE STR0148 SIZE TamSX3("TGY_DTINI")[1] OF oBrowse //"Data Ini"
	ADD COLUMN oColumn DATA { ||  sTod(TGY_DTFIM)  } TITLE STR0149 SIZE TamSX3("TGY_DTFIM")[1] OF oBrowse //"Data Fim"
	ADD COLUMN oColumn DATA { ||  sTod(TGY_ULTALO)  } TITLE STR0150 SIZE TamSX3("TGY_ULTALO")[1] OF oBrowse //"Data de Ultima Aloc"
	ADD COLUMN oColumn DATA { ||  TGY_SEQ  } TITLE STR0151 SIZE TamSX3("TGY_SEQ")[1] OF oBrowse //"Ultima Seq. ALoc."
	ADD COLUMN oColumn DATA { ||  TDX_SEQTUR  } TITLE STR0152 SIZE TamSX3("TDX_SEQTUR")[1] OF oBrowse //"Seq. da Escala"
	ADD COLUMN oColumn DATA { ||  TGY_ENTRA1  } TITLE STR0153 SIZE TamSX3("TGY_ENTRA1")[1] OF oBrowse	//STR0153
	ADD COLUMN oColumn DATA { ||  TGY_SAIDA1  } TITLE STR0154 SIZE TamSX3("TGY_SAIDA1")[1] OF oBrowse	//"Hora Fim 1"
	ADD COLUMN oColumn DATA { ||  TGY_ENTRA2  } TITLE STR0155 SIZE TamSX3("TGY_ENTRA2")[1] OF oBrowse	//"Hora Ini 2"
	ADD COLUMN oColumn DATA { ||  TGY_SAIDA2  } TITLE STR0156 SIZE TamSX3("TGY_SAIDA2")[1] OF oBrowse	//"Hora Fim 2"
	ADD COLUMN oColumn DATA { ||  TGY_ENTRA3  } TITLE STR0157 SIZE TamSX3("TGY_ENTRA3")[1] OF oBrowse	//"Hora Ini 3"
	ADD COLUMN oColumn DATA { ||  TGY_SAIDA3  } TITLE STR0158 SIZE TamSX3("TGY_SAIDA3")[1] OF oBrowse	//"Hora Fim 3"
	ADD COLUMN oColumn DATA { ||  TGY_ENTRA4  } TITLE STR0159 SIZE TamSX3("TGY_ENTRA4")[1] OF oBrowse	//"Hora Ini 4"
	ADD COLUMN oColumn DATA { ||  TGY_SAIDA4  } TITLE STR0160 SIZE TamSX3("TGY_SAIDA4")[1] OF oBrowse	//"Hora Fim 4"
oBrowse:Activate()

ACTIVATE MSDIALOG oDlgEscTela CENTERED

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At190SetFlt
@description Organização do oBrowse para pesquisa
@return xValue
@author Augusto Albuquerque
@since  22/10/2020
/*/
//------------------------------------------------------------------
Static Function At190SetFlt(aSeek, oBrowse)

Local aFilter := {}
Local nC := 0

For nC := 1 to Len(aSeek)
	If Len(aSeek[nC]) >= 2 .and. Len(aSeek[nC, 02]) == 1 .AND.  Len(aSeek[nC, 02, 01]) >= 7 .and. !Empty(aSeek[nC, 02, 01 ,07])
		If aScan(aFilter, {|f| f[1] == aSeek[nC, 02, 01, 07]}) == 0
			aAdd(aFilter, {aSeek[nC, 02, 01, 07], aSeek[nC, 02,01, 05], aSeek[nC, 02,01, 02], aSeek[nC, 02,01, 03], aSeek[nC, 02,01, 04], IIF(Empty(aSeek[nC, 02,01, 06]), "", aSeek[nC, 02, 01, 06])})
		EndIf
	EndIf
Next nC 


If Len(aFilter) > 0
	oBrowse:SetTemporary(.T.)
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetFilterDefault( "" ) 
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetFieldFilter(aFilter)
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} At581ReF3
@description Retorno do F3
@return xValue
@author Augusto Albuquerque
@since  22/10/2020
/*/
//------------------------------------------------------------------
Function At581ReF3()
Local cRet
cRet := cRetF3
Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT581VldAt
@description Query para verificar se o atendente pertence ao item de RH
@return xValue
@author Augusto Albuquerque
@since  22/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT581VldAt( cAtend )
Local cAliasTGY	:= GetNextAlias()
Local oModel	:= FwModelActive()
Local oMdlTW1	:= oModel:GetModel("TW1DETAIL")	
Local lRet		:= .T.

cAtend := AT190dLimp(cAtend)

If !Empty(cAtend)

	cQuery := ""
	cQuery += " SELECT 1  "
	cQuery += " FROM " + RetSqlName("TGY") + " TGY "
	cQuery += " INNER JOIN " + RetSqlName("AA1") + " AA1 ON "
	cQuery += " AA1.AA1_CODTEC = TGY.TGY_ATEND "
	cQuery += " AND AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
	cQuery += " AND AA1.D_E_L_E_T_ = '' "
	cQuery += " WHERE "
	cQuery += " TGY.TGY_FILIAL = '" + xFilial("TGY") + "' "
	cQuery += " AND TGY.TGY_CODTFF = '" + oMdlTW1:GetValue("TW1_CODTFF") + "' "
	cQuery += " AND TGY.TGY_GRUPO = '" + cValToChar(oMdlTW1:GetValue("TW1_GRUPO")) + "' "
	cQuery += " AND TGY.TGY_ATEND = '" + cAtend + "' "
	cQuery += " AND TGY.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTGY, .F., .T.)

	lRet := (cAliasTGY)->(!Eof())

	(cAliasTGY)->(dbCloseArea())

	If !lRet
		Help(,,"AT581VldAt",,STR0145, 1, 0,,,,,,{STR0164}) //"Não é possivel selecionar um atendente que não faz parte da alocação do posto"  ## "Selecione um atendente que tenha vinculo com o posto"
	EndIf
EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At581Mov

@description Movimenta a Rota sem verificação de TGY

@author	boiani
@since	02/11/2020
/*/
//------------------------------------------------------------------------------
Function At581Mov(cRota, dDatabase, cAtdMvRmv, lAutomato, dDtIniRt,dDtFimRt,dDtIniTGZ,dDtFimTGZ)
Local nX
Local nAux
Local oModel
Local oMdlTW0
Local oMdlTW1
Local aRotas := {}
Local cComTW1 	:= FwModeAccess("TW1",1) +  FwModeAccess("TW1",2) + FwModeAccess("TW1",3)
Local cComTGZ 	:= FwModeAccess("TGZ",1) +  FwModeAccess("TGZ",2) + FwModeAccess("TGZ",3)
Local cComTFF	:= FwModeAccess("TFF",1) +  FwModeAccess("TFF",2) + FwModeAccess("TFF",3)
Local lMtFIl := cComTFF == "EEE" .AND. (LEN(STRTRAN( cComTW1  , "E" )) > LEN(STRTRAN(  cComTGZ  , "E" ))) .AND. TW1->(ColumnPos("TW1_FILTFF")) > 0
Local lRet := .T.

Default cRota		:= TW0->TW0_COD

DbSelectArea("TW0")
TW0->(DbSetOrder(1)) //TW0_FILIAL+TW0_COD
TW0->(DbSeek(xFilial("TW0")+cRota))

oModel	:= FWLoadModel("TECA581")	//Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()

oMdlTW0	:= oModel:GetModel("TW0MASTER")
oMdlTW1	:= oModel:GetModel("TW1DETAIL")

For nX := 1 to oMdlTW1:Length()
	oMdlTW1:GoLine(nX)
	AADD(aRotas, nil)
	nAux := LEN(aRotas)
	aRotas[nAux] := GsAloc():New()
	If lMtFIl
		aRotas[nAux]:defFil(oMdlTW1:GetValue("TW1_FILTFF"))
	EndIF
	aRotas[nAux]:defCob(.T.)
	aRotas[nAux]:defEscala( POSICIONE("TGX",1,xFilial("TGX",IIF(lMtFIl,oMdlTW1:GetValue("TW1_FILTFF"),cFilAnt)) +;
										oMdlTW1:GetValue("TW1_CODTGX"),"TGX_CODTDW") )
	aRotas[nAux]:defPosto(oMdlTW1:GetValue("TW1_CODTFF"))
	aRotas[nAux]:defTec(cAtdMvRmv)
	aRotas[nAux]:defGrupo(oMdlTW1:GetValue("TW1_GRUPO"))
	aRotas[nAux]:defConfal(oMdlTW1:GetValue("TW1_CODTGX"))
	aRotas[nAux]:defDate(dDtIniRt,dDtFimRt)
	aRotas[nAux]:defSeq(oMdlTW1:GetValue("TW1_SEQ"))
	aRotas[nAux]:defTpAlo("001")
	aRotas[nAux]:projAloc()
Next nX

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581Proj

@description Projeção de agenda na rota de cobertura.

@author	boiani
@since	02/11/2020
/*/
//------------------------------------------------------------------------------

Function At581Proj()
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},;
					{.T.,STR0166},{.T.,STR0167},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} //"Salvar"#"Cancelar"

FwExecView( STR0165, "VIEWDEF.TECA581B", MODEL_OPERATION_INSERT, /*oOwner*/, {||.T.}, /*bOk*/, 45, aButtons ) //"Projeção de Rota"

Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RotaAgend
@description Verifica se existe Agenda para a Rota informada
@author Matheus.Goncalves
@since  26/05/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function RotaAgend(cRota,dDtIniRt,dDtFimRt)
Local cQuery	:= ""
Local cAliasABB	:= GetNextAlias()
Local cCodTFF	:= Posicione("TW1", 1,  xFilial("TW1")+cRota, "TW1_CODTFF")
Local cCodEsc	:= Posicione("TFF", 1,  xFilial("TFF")+cCodTFF, "TFF_ESCALA")
Local lRet		:= .T.

cQuery := ""
cQuery += " SELECT 1 "
cQuery += " FROM " + RetSqlName("ABB") + " ABB "
cQuery += " INNER JOIN " + RetSqlName("TGY") + " TGY ON "
cQuery += " TGY.TGY_FILIAL = '" + xFIlial("TGY") + "'  "
cQuery += " AND ABB.ABB_CODTEC = TGY.TGY_ATEND "
cQuery += " AND TGY.D_E_L_E_T_='' "
cQuery += " WHERE "
cQuery += " ABB.ABB_FILIAL = '" + xFIlial("ABB") + "' "
cQuery += " AND TGY.TGY_ESCALA = '" + cCodEsc + "' "
cQuery += " AND TGY.TGY_CODTFF = '" + cCodTFF + "' "
cQuery += " AND ABB.ABB_DTINI BETWEEN '" + DtoS(dDtIniRt) + "' AND '" + DtoS(dDtFimRt) + "' "
cQuery += " AND ABB.D_E_L_E_T_='' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasABB, .F., .T.)
lRet := (cAliasABB)->(!EOF())
(cAliasABB)->(dbCloseArea())

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at581ExGv
Função de Adição do Botão Gravar
@return	aRet - Array dos campos
@author	Kaique Schiller
@since	05/08/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function at581ExGv(oPanel)
Local lLowScreen := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local aTamanho := {}

If lLowScreen
	AADD(aTamanho, 52.00)
Else
	AADD(aTamanho, 44.00)
EndIf

TButton():New( (oPanel:nHeight / 2) - 13, (oPanel:nWidth/2) - aTamanho[1], STR0180 , oPanel, { || FwMsgRun(Nil,{|| At581dYCmt(.T.)}, Nil, STR0181 ) },43,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Gravar"##"Inserindo agenda..."

Return ( Nil )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at581ExPj
Função de Adição do Botão Projetar
@author	Kaique Schiller
@since	05/08/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function at581ExPj(oPanel)
Local lLowScreen := IsBlind() .OR. ((GetScreenRes()[2] <= 800) .AND. (GetScreenRes()[1] <= 1400)) //786 x 1366
Local aTamanho := {}

If lLowScreen
	AADD(aTamanho, 52.00)
Else
	AADD(aTamanho, 44.00)
EndIf

TButton():New( (oPanel:nHeight / 2) - 13, (oPanel:nWidth/2) - ((aTamanho[1]+IIF(!lLowScreen, 5, 0))*2) , STR0182 , oPanel, { || FwMsgRun(Nil,{|| At581YAgen(.T.) }, Nil, STR0183 ) },43,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Projetar"##"Projetando Agenda..."

Return ( Nil )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581YAgen

@description Executa a alocação de acordo com os dados na TW1

@author	boiani
@since	15/01/2020
/*/
//------------------------------------------------------------------------------
Function At581YAgen(lView,cMsg)
Local oModel := FwModelActive()
Local oMdlTW1 := oModel:GetModel("TW1DETAIL")
Local oMdlABB := oModel:GetModel("ABBDETAIL")
Local oView := FwViewActive()
Local oDlg := nil
Local oSayMtr := nil
Local oMeter := nil
Local nMeter := 0
Local lRet	 := .T.
Default lView := .F.
Default cMsg := ""

oMdlABB:SetNoInsertLine(.F.)
oMdlABB:SetNoDeleteLine(.F.)

If checkTGZ(@cMsg) //Valida as linhas da LGY
	If isBlind()
		At581Prj(,,@cMsg,@lRet)
	Else
		DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0209 Style 128 //"Projetar alocações"
			oSayMtr := tSay():New(10,10,{||STR0186},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},oMdlTW1:Length(),oDlg,220,10,,.T.)
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (At581Prj(@oDlg,@oMeter,@cMsg,@lRet))
	Endif
Else
	lRet := .F.	
Endif

oMdlTW1:GoLine(1)
oMdlABB:GoLine(1)

oMdlABB:SetNoInsertLine(.T.)
oMdlABB:SetNoDeleteLine(.T.)

FwModelActive(oModel)

If !isBlind() .And. lView
	oView:Refresh("VIEW_ABB")
	oView:Refresh("VIEW_TW1")
	oView:Refresh("VIEW_TW0")
EndIf
	
Return lRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at581ExPj
Função de Adição do Botão Projetar
@author	Kaique Schiller
@since	05/08/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At581Prj(oDlg,oMeter,cMsg,lRet)
Local oModel 	:= FwModelActive()
Local oMdlTW0	:= oModel:GetModel("TW0MASTER")
Local oMdlTW1	:= oModel:GetModel("TW1DETAIL")
Local oMdlABB	:= oModel:GetModel("ABBDETAIL")
Local cComTW1 	:= FwModeAccess("TW1",1) +  FwModeAccess("TW1",2) + FwModeAccess("TW1",3)
Local cComTGZ 	:= FwModeAccess("TGZ",1) +  FwModeAccess("TGZ",2) + FwModeAccess("TGZ",3)
Local cComTFF	:= FwModeAccess("TFF",1) +  FwModeAccess("TFF",2) + FwModeAccess("TFF",3)
Local lFilTff	:= TW1->(ColumnPos("TW1_FILTFF") > 0)
Local lMtFIl	:= cComTFF == "EEE" .AND. (LEN(STRTRAN( cComTW1  , "E" )) > LEN(STRTRAN(  cComTGZ  , "E" ))) .AND. lFilTff
Local nAux		:= 0
Local nY		:= 0
Local nX		:= 0 
Local nCount 	:= 0
Local lLoadBar  := .F.
Local cAtdTGY	:= ""
Local aHrFlex	:= {}

Default oDlg    := nil
Default oMeter  := nil
Default cMsg    := ""
Default lRet	:= .T.

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

For nX := 1 To LEN(aRotasCb)
If VALTYPE(aRotasCb[nX]) == 'O'
	aRotasCb[nX]:destroy()
	aRotasCb[nX] := nil
EndIf
Next nX
aRotasCb := {}
For nX := 1 to oMdlTW1:Length()
oMdlTW1:GoLine(nX)
AADD(aRotasCb, nil)
nAux := LEN(aRotasCb)
aRotasCb[nAux] := GsAloc():New()
If lMtFIl
	aRotasCb[nAux]:defFil(oMdlTW1:GetValue("TW1_FILTFF"))
EndIF
aRotasCb[nAux]:defCob(.T.)
aRotasCb[nAux]:defRota(oMdlTW1:GetValue("TW1_CODTW0"))
aRotasCb[nAux]:defItemRt(oMdlTW1:GetValue("TW1_COD"))
aRotasCb[nAux]:defEscala( POSICIONE("TGX",1,xFilial("TGX",IIF(lMtFIl,oMdlTW1:GetValue("TW1_FILTFF"),cFilAnt)) +;
									oMdlTW1:GetValue("TW1_CODTGX"),"TGX_CODTDW") )
aRotasCb[nAux]:defPosto(oMdlTW1:GetValue("TW1_CODTFF"))
aRotasCb[nAux]:defTec(oMdlTW0:GetValue("TW0_ATEND"))
aRotasCb[nAux]:defGrupo(oMdlTW1:GetValue("TW1_GRUPO"))
aRotasCb[nAux]:defConfal(oMdlTW1:GetValue("TW1_CODTGX"))
aRotasCb[nAux]:defDate(oMdlTW0:GetValue("DET_DTINI"),oMdlTW0:GetValue("DET_DTFIM"))
aRotasCb[nAux]:defTurno(oMdlTW1:GetValue("TW1_TURNO"))
aRotasCb[nAux]:defSeq(oMdlTW1:GetValue("TW1_SEQ"))
aRotasCb[nAux]:defTpAlo("001")
If TecXHasEdH() .And. oMdlTW0:GetValue("TW0_TIPO") == "1"
	If TW1->(ColumnPos("TW1_ATDTGY") > 0) .And. !Empty(oMdlTW1:GetValue("TW1_ATDTGY"))
		cAtdTGY := oMdlTW1:GetValue("TW1_ATDTGY")			
	Endif
	aHrFlex := At581HrFlx(oMdlTW1:GetValue("TW1_CODTFF"),cAtdTGY,oMdlTW1:GetValue("TW1_GRUPO"))
	If !Empty(aHrFlex)
		aRotasCb[nAux]:defGeHor	({{aHrFlex[1,1],aHrFlex[1,2]},;
								  {aHrFlex[1,3],aHrFlex[1,4]},;
								  {aHrFlex[1,5],aHrFlex[1,6]},;
								  {aHrFlex[1,7],aHrFlex[1,8]}})
	Endif
	aRotasCb[nAux]:defAtdFlx(cAtdTGY)
	cAtdTGY := ""
EndIf
aRotasCb[nAux]:projAloc()
If !EMPTY( aRotasCb[nAux]:defMessage() )
	oMdlTW1:LoadValue("TW1_DETALH", LEFT(aRotasCb[nAux]:defMessage(), 185))
	If !EMPTY(oMdlTW1:GetValue("TW1_DETALH"))
		cMsg += Alltrim(oMdlTW1:GetValue("TW1_DETALH"))+CRLF+CRLF
	EndIf
EndIf
If aRotasCb[nAux]:getConfl()
	oMdlTW1:LoadValue("TW1_STATUS", "BR_PRETO")
ElseIf aRotasCb[nAux]:temBloqueio() .OR. aRotasCb[nAux]:temAviso()
	oMdlTW1:LoadValue("TW1_STATUS", "BR_PINK")
ElseIf !(aRotasCb[nAux]:PermAlocarInter())
	oMdlTW1:LoadValue("TW1_STATUS", "BR_CANCEL")
	lRet := .F.
Else
	oMdlTW1:LoadValue("TW1_STATUS", "BR_AMARELO")
EndIf

If Len(aRotasCb[nAux]:getProj()) > 0
	If !oMdlABB:IsEmpty()
		oMdlABB:ClearData()
		oMdlABB:InitLine()
	Endif
	For nY := 1 To LEN(aRotasCb[nAux]:getProj())
		If aRotasCb[nAux]:getProj()[nY][7] != "FOLGA" .And. aRotasCb[nAux]:getProj()[nY][8] != "FOLGA"
			If oMdlABB:GetMaxLines() < LEN(aRotasCb[nAux]:getProj())
				oMdlABB:SetMaxLine(LEN(aRotasCb[nAux]:getProj()))
			EndIf
			If nY != 1 .And. !oMdlABB:IsEmpty()
				oMdlABB:AddLine()
			EndIf
			oMdlABB:LoadValue("ABB_STATUS", aRotasCb[nAux]:getProj()[nY][1])
			oMdlABB:LoadValue("ABB_DTREF",  aRotasCb[nAux]:getProj()[nY][4])
			oMdlABB:LoadValue("ABB_SEMANA", aRotasCb[nAux]:getProj()[nY][6])
			oMdlABB:LoadValue("ABB_HRINI",  aRotasCb[nAux]:getProj()[nY][7])
			oMdlABB:LoadValue("ABB_HRFIM",  aRotasCb[nAux]:getProj()[nY][8])
			oMdlABB:LoadValue("ABB_SEQ",    aRotasCb[nAux]:getProj()[nY][15])
			oMdlABB:LoadValue("ABB_DSCONF", LEFT(aRotasCb[nAux]:getProj()[nY][23],35))		
		Endif
		If lLoadBar
			oMeter:Set(++nCount)
			oMeter:Refresh()
		EndIf
	Next nY
Else
	oMdlTW1:LoadValue("TW1_STATUS", "BR_CANCEL")
	lRet := .F.
Endif
Next nX
If lLoadBar
oDlg:End()
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581Load

@description Faz a carga dos dados no grid "ABBDETAIL"

@author	Kaique Schiller
@since	05/08/2021
/*/
//------------------------------------------------------------------------------
Function At581Load(lView)
Local oModel    := FwModelActive()
Local oView		:= FwViewActive()
Local oMdlTW0   := oModel:GetModel('TW0MASTER')
Local oMdlTW1   := oModel:GetModel('TW1DETAIL')
Local oMdlABB   := oModel:GetModel('ABBDETAIL')
Local dDataDe   := oMdlTW0:GetValue("DET_DTINI")
Local dDataAte  := oMdlTW0:GetValue("DET_DTFIM")
Local cSql := ""
Local cAliasQry	:= ""
Local nLinha := 1
Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
Local nX	:= 0
Local nLineTW1  := oMdlTW1:GetLine()
Default lView := .F.

oMdlABB:SetNoInsertLine(.F.)
oMdlABB:SetNoDeleteLine(.F.)

//Limpa o array de projeção 
For nX := 1 To LEN(aRotasCb)
	If VALTYPE(aRotasCb[nX]) == 'O'
		aRotasCb[nX]:destroy()
		aRotasCb[nX] := nil
	EndIf
Next nX

aRotasCb := {}

If !EMPTY(dDataDe) .AND. !EMPTY(dDataAte)
	For nX := 1 To oMdlTW1:Length()
		oMdlTW1:GoLine(nX)

		cSql := " SELECT TDV.TDV_DTREF, ABB.ABB_HRINI, ABB.ABB_HRFIM, TDV.TDV_SEQTRN "
		cSql += " FROM " + RetSqlName( "ABB" ) + " ABB INNER JOIN " + RetSqlName( "TDV" ) + " TDV ON "
		cSql += " TDV.D_E_L_E_T_ = ' ' AND "
		If !lMV_MultFil
			cSql += " TDV.TDV_FILIAL = '" + xFilial("TDV") + "' AND "
		Else
			cSql += " " + FWJoinFilial("ABB" , "TDV" , "ABB", "TDV", .T.) + " AND "
		EndIf
		cSql += " TDV.TDV_CODABB = ABB.ABB_CODIGO "
		cSql += " WHERE ABB.D_E_L_E_T_ = ' ' AND "
		If !lMV_MultFil
			cSql += " ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND "
		EndIf
		cSql += " TDV.TDV_DTREF >= '" + DTOS(dDataDe) + "' AND TDV.TDV_DTREF <= '" + DTOS(dDataAte) + "' AND "
		cSql += " ABB.ABB_CODTW1 = '"+oMdlTW1:GetValue("TW1_COD")+"' ORDER BY TDV.TDV_DTREF, ABB.ABB_DTINI , ABB.ABB_HRINI"
		cSql := ChangeQuery(cSql)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

		If !oMdlABB:IsEmpty()
			oMdlABB:ClearData()
			oMdlABB:InitLine()
		Endif
		
		While !(cAliasQry)->(EOF())
			If !oMdlABB:IsEmpty()
				nLinha := oMdlABB:AddLine()
			EndIf
			oMdlABB:GoLine(nLinha)
			oMdlABB:LoadValue("ABB_STATUS", "BR_VERMELHO")
			oMdlABB:LoadValue("ABB_DTREF" , STOD((cAliasQry)->(TDV_DTREF)))
			oMdlABB:LoadValue("ABB_SEMANA", TxRtDiaSem(STOD((cAliasQry)->(TDV_DTREF))))
			oMdlABB:LoadValue("ABB_HRINI" , AllTrim((cAliasQry)->(ABB_HRINI)))
			oMdlABB:LoadValue("ABB_HRFIM" , AllTrim((cAliasQry)->(ABB_HRFIM)))
			oMdlABB:LoadValue("ABB_SEQ"   , AllTrim((cAliasQry)->(TDV_SEQTRN)))

			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
		oMdlABB:GoLine(1)
	Next nX
EndIf

oMdlTW1:GoLine(nLineTW1)

oMdlABB:SetNoInsertLine(.T.)
oMdlABB:SetNoDeleteLine(.T.)

If !IsBlind() .And. lView 
	oView:Refresh('VIEW_TW1')
	oView:Refresh('VIEW_ABB')
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581dYCmt

@description Grava as agendas instanciadas em GsAloc

@author	Kaique Schiller
@since	05/08/2021
/*/
//------------------------------------------------------------------------------
Function At581dYCmt(lView,cMsg)
Local oDlg := nil
Local oSayMtr := nil
Local oMeter := NIL
Local nMeter := 0
Local lRet   := .T.
Default lView := .F.
Default cMsg  := ""

If isBlind()
	GravTGZ(,,@cMsg,@lRet)
Else
	DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0185 Style 128 // "Gravar alocações"
		oSayMtr := tSay():New(10,10,{||STR0186},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
		oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},LEN(aRotasCb),oDlg,220,10,,.T.)
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (GravTGZ(@oDlg,@oMeter,@cMsg,@lRet))
EndIf

At581Load(lView)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GravTGZ

@description Grava a projeção de agenda e a tabela TGZ

@author	Kaique Schiller
@since	05/08/2021
/*/
//------------------------------------------------------------------------------
Static Function GravTGZ(oDlg,oMeter,cMsg,lRet)
Local nX
Local nY
Local nCount := 0
Local nPos := 0
Local oModel := FwModelActive()
Local oMdlTW0 := oModel:GetModel("TW0MASTER")
Local oMdlTW1 := oModel:GetModel("TW1DETAIL")
Local lLoadBar := .F.
Local lPermConfl:= AT680Perm(NIL, __cUserID, "017")
Local lContinua := .T.
Local lAlocConf := .F.
Local nAviso
Local lRotaLote := IsInCallStack("At581ARtLt")
Local lTW1_MOV  := TW1->(ColumnPos("TW1_MOV")) > 0

Default oDlg := nil
Default oMeter := nil
Default cMsg := ""
Default lRet := .T.

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

BEGIN TRANSACTION

For nX := 1 To oMdlTW1:Length()
	oMdlTW1:GoLine(nX)
	If oMdlTW1:GetValue("TW1_STATUS") == "BR_PRETO"
		If !lPermConfl
			If !lRotaLote
				IF !(lContinua := MsgYesNo(STR0187)) //"Existem dias com conflito de alocação e o usuário não possui permissão para alocação. Alocar apenas os dias sem conflito?"
					Help(,,"NOALOC",,STR0188,1,0)	//"Operação de alocação cancelada."
				EndIf
			Else
				cMsg += STR0235+CRLF+CRLF //"Existem dias com conflito de alocação e o usuário não possui permissão para alocação."
				lContinua := .F.
			Endif
			lAlocConf := .F.
		Else
			If !lRotaLote
				nAviso := Aviso(STR0189,;   //"Atenção"
								STR0190,;   //"Um ou mais dias possuem conflito de alocação. Deseja alocar todos os atendentes mesmo com os conflitos ou alocar apenas nos dias disponíveis? Esta opção será aplicada em todos os atendentes."
								{STR0191,;  //"Apenas disponiveis"
								STR0192,;   //"Todos os dias"
								STR0193},2) //"Cancelar"
			Else
				nAviso := 1
			Endif
			If nAviso == 1 //"Apenas disponiveis"
				lContinua := .F.
			ElseIf nAviso == 2 //"Todos os dias"
				lAlocConf := .T.
			ElseIf nAviso == 3 //"Cancelar"
				lAlocConf := .F.
			EndIf
		EndIf
		Exit
	EndIf
Next nX

If !isBlind() .And. lContinua
	For nX := 1 To oMdlTW1:Length()
		oMdlTW1:GoLine(nX)
		If oMdlTW1:GetValue("TW1_STATUS") == "BR_PINK"
			If !lRotaLote
				lContinua := MsgYesNo(STR0194) //"O atendente possui restrições no período. Deseja continuar?"
			Else
				If !lPermConfl
					cMsg += STR0236+CRLF+CRLF //"O atendente possui restrições no período."
					lContinua := .F. 			
				Endif
			Endif
			Exit
		EndIf
	Next nX
EndIf

If lContinua
	For nX := 1 To oMdlTW1:Length()
		nPos := 0
		oMdlTW1:GoLine(nX)
		For nY := 1 TO Len(aRotasCb)
			If VALTYPE(aRotasCb[nY]) == 'O' .AND.;
				aRotasCb[nY]:defRota() == oMdlTW1:GetValue("TW1_CODTW0") .AND.;
				aRotasCb[nY]:defItemRt() == oMdlTW1:GetValue("TW1_COD")
				nPos := nY
				Exit
			EndIf
		Next nY
		If nPos > 0
			If !(oMdlTW1:isDeleted())
				aRotasCb[nPos]:alocaConflitos(lAlocConf)
				If aRotasCb[nPos]:gravaAloc()
					oMdlTW1:LoadValue("TW1_STATUS","BR_VERDE")
					oMdlTW1:LoadValue("TW1_DTINI",oMdlTW0:GetValue("DET_DTINI"))
					oMdlTW1:LoadValue("TW1_DTFIM",oMdlTW0:GetValue("DET_DTFIM"))
					DbSelectArea("TW1")
					TW1->(DbSetOrder(1))
					If TW1->(DbSeek(xFilial("TW1")+oMdlTW1:GetValue("TW1_CODTW0")+oMdlTW1:GetValue("TW1_COD")))
						RecLock("TW1",.F.)
						If !Empty(aRotasCb[nPos]:getLastSeq())
							oMdlTW1:LoadValue("TW1_SEQ",aRotasCb[nPos]:getLastSeq())
							TW1->TW1_SEQ := oMdlTW1:GetValue("TW1_SEQ")
						Endif					
						If lTW1_MOV
							TW1->TW1_MOV := "1"
						Endif
						TW1->(MsUnlock())
					Endif

					DbSelectArea("TW0")
					TW0->(DbSetOrder(1))
					If TW0->(DbSeek(xFilial("TW0")+oMdlTW1:GetValue("TW1_CODTW0")))
						RecLock("TW0",.F.)
						TW0->TW0_ATEND := oMdlTW0:GetValue("TW0_ATEND")
						TW0->(MsUnlock())
					Endif
				Else
					lRet := .F.
					oMdlTW1:LoadValue("TW1_STATUS","BR_LARANJA")
					cMsg += STR0237+oMdlTW1:GetValue("TW1_CODTFF")+CRLF+CRLF //"Não foi possível concluir a gravação das agendas do posto: "
				EndIf
				oMdlTW1:LoadValue("TW1_DETALH",LEFT(aRotasCb[nPos]:defMessage(), 185))
				If Len(Alltrim(aRotasCb[nPos]:defMessage())) > 0
					cMsg += LEFT(aRotasCb[nPos]:defMessage(), 185)+CRLF+CRLF
				Endif
			EndIf
		EndIf
		If lLoadBar
			oMeter:Set(++nCount)
			oMeter:Refresh()
		EndIf
	Next nX
Else
	If !isBlind()
		If !lRotaLote
			MsgAlert(STR0195) //"Operação cancelada."
		Else
			cMsg += STR0195+CRLF+CRLF
		Endif
	EndIf
	lRet := .F.
EndIf

END TRANSACTION

If lLoadBar
	oDlg:End()
EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At581LgCob

@description Legenda do campo STATUS

@author	Kaique Schiller
@since	05/08/2021
/*/
//------------------------------------------------------------------------------
Static Function At581LgCob(cCmpLeg)
Local oLegend := FwLegend():New()

If cCmpLeg == "TW1_STATUS"
	oLegend:Add( "", "BR_VERMELHO", STR0196) //"Não processado"
	oLegend:Add( "", "BR_AMARELO" , STR0197) //"Agenda projetada"
	oLegend:Add( "", "BR_VERDE"   , STR0198) //"Agenda gravada"
	oLegend:Add( "", "BR_PRETO"   , STR0199) //"Conflito de Alocação"
	oLegend:Add( "", "BR_LARANJA" , STR0200) //"Falha na alocação"
	oLegend:Add( "", "BR_CANCEL"  , STR0201) //"Falha na projeção"
	oLegend:Add( "", "BR_PINK"    , STR0202) //"Atendente com Restrição"
ElseIf cCmpLeg == "ABB_STATUS"
	oLegend:Add( "", "BR_VERMELHO", STR0203 ) //"Agenda Gerada"
	oLegend:Add( "", "BR_AMARELO" , STR0204 ) //"Agenda Atendida"
	oLegend:Add( "", "BR_VERDE"   , STR0205 ) //"Agenda Não Gerada"
	oLegend:Add( "", "BR_LARANJA" , STR0206 ) //"Agenda com Manutenção"
	oLegend:Add( "", "BR_PRETO"   , STR0207 ) //"Conflito de Alocação"
EndIf

oLegend:View()

Return(.T.)
//------------------------------------------------------------------------------
/*/{Protheus.doc} At581Alc

@description Alocação de atendente na rota de cobertura.

@author	Kaique Schiller
@since	05/08/2021
/*/
//------------------------------------------------------------------------------
Function At581Alc( lAutomato, bSemTela,cCodTec,dDtIni,dDtFim)
Local oModel := Nil
Local nX := 0
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},; //"Movimentar"
				{.T.,STR0141},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // "Fechar"
Local lOk := .T.
Local cMsg := ""
Local oStrTW0 := Nil

Default lAutomato := .F.
Default bSemTela  := {||.T.}
Default cCodTec   := ""
Default dDtIni    := sTod("")
Default dDtFim    := sTod("")

For nX := 1 To LEN(aRotasCb)
	If VALTYPE(aRotasCb[nX]) == 'O'
		aRotasCb[nX]:destroy()
		aRotasCb[nX] := nil
	EndIf
Next nX
aRotasCb := {}

If lAutomato .Or. !Empty(cCodTec)
	oModel := FwLoadModel("TECA581")
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()
	If !Empty(cCodTec)
		lOk := lOk .And. oModel:SetValue("TW0MASTER","TW0_ATEND",cCodTec)
		lOk := lOk .And. oModel:SetValue("TW0MASTER","DET_DTINI",dDtIni)
		lOk := lOk .And. oModel:SetValue("TW0MASTER","DET_DTFIM",dDtFim)
		lOk := lOk .And. At581YAgen(.F.,@cMsg) //Projeta as agendas da rota.
		If lOk
			oStrTW0 := oModel:GetModel("TW0MASTER"):GetStruct()
			oStrTW0:SetProperty("TW0_ATEND",MODEL_FIELD_WHEN, {|| .F. } )
			oStrTW0:SetProperty("DET_DTINI",MODEL_FIELD_WHEN, {|| .F. } )
			oStrTW0:SetProperty("DET_DTFIM",MODEL_FIELD_WHEN, {|| .F. } )
			FWExecView( STR0208, "VIEWDEF.TECA581", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.}/*bCloseOk*/,	{||.T.}/*bOk*/,0, aButtons, {||.T.} /*bCancel*/, /*cOperatId*/, /*cToolBar*/, oModel ) //"Movimentação"
		Endif
	Endif
	If lAutomato
		Eval( bSemTela, oModel )
	Endif
Else
	oModel := FwModelActive()
	FWExecView( STR0208, "VIEWDEF.TECA581", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.}/*bCloseOk*/,	{||.T.}/*bOk*/,0, aButtons, {||.T.} /*bCancel*/, /*cOperatId*/, /*cToolBar*/, /*oModel*/ ) //"Movimentação"
	FwModelActive(oModel)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581GsRota

@description Validação para a nova rota

@author	Kaique Schiller
@since	05/08/2021
/*/
//------------------------------------------------------------------------------
Function At581GsRota()

Return SuperGetMV("MV_GSROTA",,.F.) .And. ABB->(ColumnPos("ABB_CODTW1") > 0) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581HrFlx

@description Horário flexivel do efetivo na TGY

@author	Kaique Schiller
@since	05/08/2021
/*/
//------------------------------------------------------------------------------
Static Function At581HrFlx(cCodTFF,cAtend,cGrupo)
Local aRetHrFlx := {}
Local cAliasTGY	:= ""
Local cQuery	:= ""

cQuery := " SELECT TGY.TGY_ENTRA1, TGY.TGY_ENTRA2, TGY.TGY_ENTRA3, TGY.TGY_ENTRA4, "
cQuery += " TGY.TGY_SAIDA1, TGY.TGY_SAIDA2, TGY.TGY_SAIDA3, TGY.TGY_SAIDA4"
cQuery += " FROM " + RetSqlName("TGY") + " TGY "
cQuery += " WHERE TGY.TGY_FILIAL = '" + xFilial("TGY") + "' "
cQuery += " AND TGY.TGY_CODTFF = '" + cCodTFF + "' "
cQuery += " AND TGY.TGY_GRUPO = '" + cValToChar(cGrupo) + "' "
cQuery += " AND TGY.D_E_L_E_T_ = '' "
If TW1->(ColumnPos("TW1_ATDTGY") > 0) .AND. !Empty(cAtend)
	cQuery += " AND TGY.TGY_ATEND = '" + cAtend + "' "
EndIf

cAliasTGY := GetNextAlias()

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTGY, .F., .T.)

If (cAliasTGY)->(!Eof())
	aAdd(aRetHrFlx,{ (cAliasTGY)->TGY_ENTRA1 , (cAliasTGY)->TGY_SAIDA1,;
					 (cAliasTGY)->TGY_ENTRA2 , (cAliasTGY)->TGY_SAIDA2,;
					 (cAliasTGY)->TGY_ENTRA3 , (cAliasTGY)->TGY_SAIDA3,;
					 (cAliasTGY)->TGY_ENTRA4 , (cAliasTGY)->TGY_SAIDA4 })
Endif

Return aRetHrFlx

//------------------------------------------------------------------------------
/*/{Protheus.doc} checkTGZ

@description Valida os dados da projeção

@author	Kaique Schiller
@since	03/02/2020
/*/
//------------------------------------------------------------------------------
Static Function checkTGZ(cMsg)
Local lRet := .T.
Local oModel := FwModelActive()
Local oMdlTW0 := oModel:GetModel("TW0MASTER")
Local oMdlTW1 := oModel:GetModel("TW1DETAIL")
Local aSaveLines := FWSaveRows( oModel )
Local nX
Local dDtIniPosto
Local dDtFimPosto
Local lTecXRh 	:= SuperGetMv("MV_TECXRH",,.T.)
Local lGSALCDT 	:= SuperGetMv("MV_GSALCDT",,.F.)
Local lAtdCk	:= .F.
Local cABSRest	:= ""
Local cCtrVig	:= ""
Local cRevVig	:= ""
Local cCodTFL	:= ""
Local lFilTff	:= TW1->(ColumnPos("TW1_FILTFF") > 0)
Local dDtEnce	
Local lEnceDT	:= FindFunction("TecEncDtFt") .AND. TecEncDtFt() 
Default cMsg	:= ""

If lRet .And. !((FindFunction("U_PNMSESC") .And. FindFunction("U_PNMSCAL")) .OR. ( FindFunction( "TecExecPNM" ) .AND. TecExecPNM() ))
	Help( , , "PNMTABC01", Nil, STR0210, 1, 0,,,,,,{STR0211}) //"Funcionalidade de alocação de atendente integrada com o Gestão de Escalas, não disponivel pois não esta com patch aplicado com as configurações do RH (PNMTABC01) e o parametro 'MV_GSPNMTA' está desabilitado." ## "Por favor, aplique o patch para as configurações do RH (PNMTABC01) ou faça ativação do parametro 'MV_GSPNMTA' para utilização."
	lRet := .F.
	cMsg += STR0210+CRLF+STR0211+CRLF+CRLF
EndIf

If !At680Perm(NIL, __cUserId, "039", .T.)
	Help(,1,"ProjAloc",,STR0212, 1)//"Usuário sem permissão de projetar agenda"
	lRet := .F.
	cMsg += STR0212+CRLF+CRLF
EndIf

If Empty(oMdlTW0:GetValue("TW0_ATEND"))
	lRet := .F.
	Help(,1,"ProjAloc",,STR0213, 1) //"Código do atendente não preenchido. Por favor, preencha o código do atendente"
	cMsg += STR0213+CRLF+CRLF
Endif

If lRet
	For nX := 1 To oMdlTW1:Length()
	oMdlTW1:GoLine(nX)
	If oMdlTW1:GetValue("TW1_STATUS") == "BR_CANCEL"
		oMdlTW1:LoadValue("TW1_STATUS", "BR_VERMELHO")
	EndIf
	lAtdCk := !(QryEOF("SELECT 1 REC FROM " + RetSqlName( "TIN" ) + " TIN INNER JOIN " + RetSqlName( "TCT" ) + " TCT "+;
						"ON TCT.TCT_GRUPO = TIN.TIN_GRUPO AND TCT.D_E_L_E_T_ = ' ' AND TCT.TCT_ITEM = '044' AND "+;
						"TCT.TCT_FILIAL = '" + xFilial("TCT", Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1"))) + "' AND TCT.TCT_PODE = '1' WHERE "+;
						"TIN.D_E_L_E_T_ = ' ' AND TIN.TIN_FILIAL = '" + xFilial("TIN", Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1"))) +;
						"' AND TIN.TIN_MSBLQL = '2' AND "+ "TIN.TIN_CODUSR = '" + __cUserId + "' "))
	If Posicione("AA1",1,xFilial("AA1", Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+oMdlTW0:GetValue("TW0_ATEND"),"AA1_ALOCA") == '2'
		oMdlTW1:LoadValue("TW1_DETALH", STR0214) //"Atendente não está disponível para alocação, realize manutenção no cadastro de Atendentes no campo AA1_ALOCA."
		oMdlTW1:LoadValue("TW1_STATUS", "BR_CANCEL")
		lRet := .F.
		cMsg += STR0214+CRLF+CRLF
		Loop
	EndIf
	If (Empty(oMdlTW1:GetValue("TW1_CODTFF")) .OR.;
			Empty(oMdlTW1:GetValue("TW1_GRUPO")) .OR.;
			Empty(oMdlTW0:GetValue("DET_DTINI")) .OR.;
			Empty(oMdlTW0:GetValue("DET_DTFIM")) .OR.;
			Empty(oMdlTW1:GetValue("TW1_SEQ")) .OR.;
			Empty(oMdlTW1:GetValue("TW1_ESCALA")); 
			)
		oMdlTW1:LoadValue("TW1_DETALH", STR0215 ) //"Os campos 'Posto', 'Escala', 'Sequência' ,'Grupo' e o Período de Alocação são obrigatórios para a projeção da agenda"
		oMdlTW1:LoadValue("TW1_STATUS", "BR_CANCEL")
		lRet := .F.
		cMsg += STR0215+CRLF+CRLF
		Loop
	EndIf
	dDtIniPosto := POSICIONE("TFF",1,xFilial("TFF",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+oMdlTW1:GetValue("TW1_CODTFF"),"TFF_PERINI")
	dDtFimPosto := POSICIONE("TFF",1,xFilial("TFF",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+oMdlTW1:GetValue("TW1_CODTFF"),"TFF_PERFIM")
	cFuncAtd	:= POSICIONE("AA1",1,xFilial("AA1",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+oMdlTW0:GetValue("TW0_ATEND"),"AA1_FUNCAO")
	cCodFun		:= POSICIONE("AA1",1,xFilial("AA1",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+oMdlTW0:GetValue("TW0_ATEND"),"AA1_CDFUNC")
	cCodTFL		:= POSICIONE("TFF",1,xFilial("TFF",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+oMdlTW1:GetValue("TW1_CODTFF"),"TFF_CODPAI")
	cLocAbs		:= POSICIONE("TFL",1,xFilial("TFL",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+cCodTFL,"TFL_LOCAL")
	cABSRest	:= POSICIONE("ABS",1,xFilial("ABS",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+cLocAbs,"ABS_RESTEC")
	cCtrVig		:= POSICIONE("TFL",1,xFilial("TFL",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+cCodTFL,"TFL_CONTRT")
	cRevVig		:= POSICIONE("TFL",1,xFilial("TFL",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+cCodTFL,"TFL_CONREV")
	If lEnceDT
		dDtEnce	:=POSICIONE("TFF",1,xFilial("TFF",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+oMdlTW1:GetValue("TW1_CODTFF"),"TFF_DTENCE")	
	EndIf	

	If lEnceDT .AND. POSICIONE("TFF",1,xFilial("TFF",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+oMdlTW1:GetValue("TW1_CODTFF"),"TFF_ENCE") == '1';
		.AND. (oMdlTW0:GetValue("DET_DTINI") >= dDtEnce .OR. oMdlTW0:GetValue("DET_DTFIM") >= dDtEnce) 
			oMdlTW1:LoadValue("TW1_DETALH", STR0263+DToC(dDtEnce)+STR0264) // "Não é possível gerar nova(s) agenda(s), pois o posto possui encerramento para o dia " ## ". Com isso não é possível gerar agenda após essa data."
			oMdlTW1:LoadValue("TW1_STATUS", "BR_CANCEL")
		lRet := .F.	
	Else	
		If TecABBPRHR()
			If TecConvHr(POSICIONE("TFF",1,xFilial("TFF",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+oMdlTW1:GetValue("TW1_CODTFF"),"TFF_QTDHRS")) > 0
				oMdlTW1:LoadValue("TW1_DETALH", STR0216) //"Não é possível realizar Alocação por hora"
				oMdlTW1:LoadValue("TW1_STATUS", "BR_CANCEL")
				lRet := .F.
				cMsg += STR0216+CRLF+CRLF
				Loop
			EndIf
		EndIf

		If oMdlTW0:GetValue("DET_DTINI") > oMdlTW0:GetValue("DET_DTFIM")
			oMdlTW1:LoadValue("TW1_DETALH", STR0217) //"A data de início deve ser menor ou igual a data de término."
			oMdlTW1:LoadValue("TW1_STATUS", "BR_CANCEL")
			lRet := .F.
			cMsg += STR0217+CRLF+CRLF
			Loop
		EndIf

		If !lEnceDT .AND. Posicione("TFF",1,xFilial("TFF",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+oMdlTW1:GetValue("TW1_CODTFF"),"TFF_ENCE") == '1'
			oMdlTW1:LoadValue("TW1_DETALH", STR0218) //"Posto encerrado. Não é possível gerar novas agendas."
			oMdlTW1:LoadValue("TW1_STATUS", "BR_CANCEL")
			lRet := .F.
			cMsg += STR0218+CRLF+CRLF
			Loop
		EndIf

		If EMPTY(dDtIniPosto) .OR. EMPTY(dDtFimPosto)
			oMdlTW1:LoadValue("TW1_DETALH", STR0219 + oMdlTW1:GetValue("TW1_CODTFF"))	//"Não foi possível localizar o Período Inicial (TFF_PERINI) ou o Período Final (TFF_PERFIM) do posto "
			oMdlTW1:LoadValue("TW1_STATUS", "BR_CANCEL")
			lRet := .F.
			cMsg += STR0219 + oMdlTW1:GetValue("TW1_CODTFF")+CRLF+CRLF
			Loop
		EndIf

		If !EMPTY(cCtrVig)
			If POSICIONE("CN9",1,xFilial("CN9",Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")))+cCtrVig+cRevVig,"CN9_SITUAC") != "05" //Contrato em elaboração
				oMdlTW1:LoadValue("TW1_DETALH", STR0220)  //"Contrato em Elaboração não pode ser projetado."
				oMdlTW1:LoadValue("TW1_STATUS", "BR_CANCEL")
				lRet := .F.
				cMsg += STR0220+CRLF+CRLF
				Loop
			EndIf
		EndIf

		If lGSALCDT
			If (oMdlTW0:GetValue("DET_DTINI") < dDtIniPosto .AND. oMdlTW0:GetValue("DET_DTFIM") < dDtIniPosto) .OR.;
				(oMdlTW0:GetValue("DET_DTINI") > dDtFimPosto .AND. oMdlTW0:GetValue("DET_DTFIM") > dDtFimPosto)
				oMdlTW1:LoadValue("TW1_DETALH", STR0221 + dToC(dDtIniPosto) + STR0222 + dToC(dDtFimPosto) + STR0223 ) 
				//"O período de alocação estipulado no posto inicia-se em " # " e encerra-se em " # ". Não é possível projetar agenda fora deste período."
				oMdlTW1:LoadValue("TW1_STATUS", "BR_CANCEL")
				lRet := .F.
				cMsg += STR0221 + dToC(dDtIniPosto) + STR0222 + dToC(dDtFimPosto) + STR0223+CRLF+CRLF
				Loop
			Endif
		Else
			If (oMdlTW0:GetValue("DET_DTINI") < dDtIniPosto .OR. oMdlTW0:GetValue("DET_DTFIM") > dDtFimPosto)
				oMdlTW1:LoadValue("TW1_DETALH", STR0221 + dToC(dDtIniPosto) + STR0222 + dToC(dDtFimPosto) + STR0223 ) 
				//"O período de alocação estipulado no posto inicia-se em " # " e encerra-se em " # ". Não é possível projetar agenda fora deste período."
				oMdlTW1:LoadValue("TW1_STATUS", "BR_CANCEL")
				lRet := .F.
				cMsg += STR0221 + dToC(dDtIniPosto) + STR0222 + dToC(dDtFimPosto) + STR0223+CRLF+CRLF
				Loop
			EndIf
		EndIf

		If !VldEfetv(Iif(lFilTff,oMdlTW1:GetValue("TW1_FILTFF"),xFilial("TW1")),;
						oMdlTW1:GetValue("TW1_CODTFF"),;
						oMdlTW0:GetValue("DET_DTINI"),;
						oMdlTW0:GetValue("DET_DTFIM"),;
						oMdlTW1:GetValue("TW1_GRUPO"),;
						Iif(TW1->(ColumnPos("TW1_ATDTGY") > 0),oMdlTW1:GetValue("TW1_ATDTGY"),""))
			oMdlTW1:LoadValue("TW1_DETALH", STR0224 + oMdlTW1:GetValue("TW1_CODTFF") + STR0225 + dToC(oMdlTW0:GetValue("DET_DTINI")) + STR0226 + dToC(oMdlTW0:GetValue("DET_DTFIM")) + ".")	//"Não foi possível alocar o atendente no posto "##", não existe efetivo alocado no período de: "##" até: "
			oMdlTW1:LoadValue("TW1_STATUS", "BR_CANCEL")
			lRet := .F.
			cMsg +=  STR0224 + oMdlTW1:GetValue("TW1_CODTFF") + STR0225 + dToC(oMdlTW0:GetValue("DET_DTINI")) + STR0226 + dToC(oMdlTW0:GetValue("DET_DTFIM")) + "."+CRLF+CRLF
			Loop
		Endif

		If lAtdCk
			cMsg := TecCkStAt(oMdlTW0:GetValue("TW0_ATEND"), oMdlTW1:GetValue("TW1_CODTFF"), cLocAbs, cFuncAtd, TFF->TFF_FUNCAO, lTecXRh)
		EndIf
	EndIf  
	Next nX	
Endif
FWRestRows( aSaveLines )
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} QryEOF()

Executa uma qry e retorna se EOF

@author	Kaique Schiller
@since 16/08/2021
/*/
//------------------------------------------------------------------------------
Static Function QryEOF(cSql, lChangeQry)
Local lRet := .F.
Local cAliasQry := GetNextAlias()
Default lChangeQry := .T.
If lChangeQry
	cSql := ChangeQuery(cSql)
EndIf
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
lRet := (cAliasQry)->(EOF())
(cAliasQry)->(DbCloseArea())
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} aT581WhAtd()

When do campo de atendente da nova rota

@author	Kaique Schiller
@since 16/08/2021
/*/
//------------------------------------------------------------------------------
Function aT581WhAtd(cCodTW0)
Local lRet := .T.

DbSelectArea("TW0")
TW0->(DbSetOrder(1))
If TW0->(DbSeek(xFilial("TW0")+cCodTW0)) .And. (!Empty(TW0->TW0_ATEND) .Or. !Empty(aRotasCb) )
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldEfetv()

Validação para verificar se existe efetivo no posto.

@author	Kaique Schiller
@since 16/08/2021
/*/
//------------------------------------------------------------------------------
Static Function VldEfetv(cFilTFF,cCodTFF,dDtIni,dDtFim,cGrupo,cAtendFlx)
Local lRet	      := .T.
Local cAliasTGY	  := ""
Local cQuery	  := ""
Default cAtendFlx := ""

cQuery := " SELECT 1 "
cQuery += " FROM " + RetSqlName("TGY") + " TGY "
cQuery += " WHERE TGY.TGY_FILIAL = '" + xFilial("TGY") + "' "
cQuery += " AND TGY.TGY_CODTFF = '" + cCodTFF + "' "
cQuery += " AND TGY.TGY_GRUPO = '" + cValToChar(cGrupo) + "' "
cQuery += " AND '" + dTos(dDtIni) + "' BETWEEN TGY.TGY_DTINI AND TGY.TGY_DTFIM "
cQuery += " AND '" + dTos(dDtFim) + "' BETWEEN TGY.TGY_DTINI AND TGY.TGY_DTFIM "
cQuery += "	AND TGY.TGY_ULTALO >= '" + dTos(dDtFim) + "' "
If TW1->(ColumnPos("TW1_ATDTGY") > 0) .AND. !Empty(cAtendFlx)
	cQuery += " AND TGY.TGY_ATEND = '" + cAtendFlx + "' "
EndIf
cQuery += " AND TGY.D_E_L_E_T_ = '' "

cAliasTGY := GetNextAlias()

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTGY, .F., .T.)

lRet := (cAliasTGY)->(!Eof())

(cAliasTGY)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExistTGZ()

Validação para verificar se o atendente foi removido completamente dessa rota.

@author	Kaique Schiller
@since 04/10/2021
/*/
//------------------------------------------------------------------------------
Static Function ExistTGZ(cCodRt,cAtend)
Local lRet	      := .T.
Local cAliasTGZ	  := ""
Local cQuery	  := ""
Default cCodRt    := ""
Default cAtend    := ""

If !Empty(cCodRt) .And. !Empty(cAtend)
	cQuery := " SELECT 1 "
	cQuery += " FROM " + RetSqlName("TGZ") + " TGZ "
	cQuery += " WHERE TGZ.TGZ_FILIAL = '" + xFilial("TGZ") + "' "
	cQuery += " AND TGZ.TGZ_ATEND = '" + cAtend + "' "
	cQuery += " AND TGZ.TGZ_CODTW0 = '" + cCodRt + "' "
	cQuery += " AND TGZ.D_E_L_E_T_ = '' "

	cAliasTGZ := GetNextAlias()

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTGZ, .F., .T.)

	lRet := (cAliasTGZ)->(!Eof())

	(cAliasTGZ)->(DbCloseArea())
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581RtVag()

@description Validação para a rota vaga

@author	Kaique Schiller
@since 04/10/2021
/*/
//------------------------------------------------------------------------------
Function At581RtVag()

Return TW0->(ColumnPos("TW0_VAGA") > 0) .And. TW1->(ColumnPos("TW1_CODHE") > 0) .And. TW1->(ColumnPos("TW1_CODTDX") > 0)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At581dCons

Construção da consulta especifica para rota de cobertura vaga

@author Kaique Schiller
@since 03/11/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At581dCons(cTipo)
Local oModel      := FwModelActive()
Local oMdlTW1     := oModel:GetModel("TW1DETAIL")
Local cProfID     := ""
Local lRet        := .F.
Local oBrowse     := Nil
Local cAls        := "" 
Local nSuperior   := 0
Local nEsquerda   := 0
Local nInferior   := 0
Local nDireita    := 0
Local cQry        := ""
Local aIndex      := {}
Local aSeek       := {}
Local oDlgEscTela := Nil
Local cTitle      := ""
Local aCmpF3	  := {}
Local nZ		  := 0

If cTipo == "TW1_CODTDX"
	cTitle := STR0259 //"Configuração de Alocação"

	cAls := cTipo
	//Necessario para criação de um ID para cada browse
	cProfID := "CDTDX"

	Aadd( aSeek, { STR0256, {{"","C",TamSX3("TDX_TURNO")[1],0,STR0256,,"TDX_TURNO"}} } ) //"Turno"
	Aadd( aSeek, { STR0257, {{"","C",TamSX3("TDX_SEQTUR")[1],0,STR0257,,"TDX_SEQTUR"}} } ) //"Sequência"
	Aadd( aSeek, { STR0258, {{"","C",TamSX3("R6_DESC")[1],0,STR0258,,"R6_DESC"}} } ) //"Descrição"

	Aadd( aIndex, "TDX_TURNO" )
	Aadd( aIndex, "R6_DESC" )
	Aadd( aIndex, "TDX_FILIAL")

	cQry := " SELECT TDX.TDX_COD COD, TDX.TDX_TURNO, TDX.TDX_SEQTUR, SR6.R6_DESC, TDX.TDX_FILIAL "
	cQry += " FROM " + RetSqlName("TDX") + " TDX "
	cQry += " INNER JOIN " + RetSqlName("SR6") + " SR6 ON "
	cQry += " SR6.R6_TURNO = TDX.TDX_TURNO "
	cQry += " AND SR6.R6_FILIAL = '" + xFilial("SR6") + "' "
	cQry += " AND SR6.D_E_L_E_T_ = ' ' "
	cQry += " WHERE TDX.TDX_FILIAL = '" + xFilial("TDX") + "' "
	cQry += " AND TDX.D_E_L_E_T_ = ' ' " 
	cQry += " AND TDX.TDX_CODTDW = '" + oMdlTW1:GetValue("TW1_CODTDW") + "' "
Endif

nSuperior := 0
nEsquerda := 0
nInferior := GetScreenRes()[2] * 0.6
nDireita  := GetScreenRes()[1] * 0.65

DEFINE MSDIALOG oDlgEscTela TITLE cTitle FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL

oBrowse := FWFormBrowse():New()
oBrowse:SetOwner(oDlgEscTela)
oBrowse:SetDataQuery(.T.)
oBrowse:SetAlias(cAls)
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetQuery(cQry)
oBrowse:SetSeek(,aSeek)
oBrowse:SetDescription(cTitle)
oBrowse:SetMenuDef("")
oBrowse:DisableDetails()
oBrowse:SetProfileID(cProfID)

At190SetFlt(aSeek, @oBrowse)

oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->COD, lRet := .T. ,oDlgEscTela:End()})
oBrowse:AddButton( OemTOAnsi(STR0254), {|| cRetF3  := (oBrowse:Alias())->COD, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
oBrowse:AddButton( OemTOAnsi(STR0255),  {|| cRetF3  := "", oDlgEscTela:End() } ,, 2 )	//"Cancelar"
oBrowse:DisableDetails()

For nZ := 1 To Len(aSeek)
	AADD( aCmpF3, aSeek[nZ][2][1][7])
Next nZ
For nZ := 1  To LEN(aCmpF3)				
	If TamSX3(aCmpF3[nZ])[3] == "D"
		bPoAdd :=  &("{|| STOD(" + aCmpF3[nZ] + ")}")
	Else
		bPoAdd :=  &("{||" + aCmpF3[nZ] + "}")
	EndIf
	ADD COLUMN oColumn DATA bPoAdd TITLE TecTituDes(aCmpF3[nZ], .T. ) SIZE TamSX3(aCmpF3[nZ])[1] OF oBrowse	
Next nZ

oBrowse:Activate()

ACTIVATE MSDIALOG oDlgEscTela CENTERED

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190SetFlt

@description Chama a função que cria os filtros nas consultas padrões
@author	fabiana.silva	
@since	05/03/2020
/*/
//------------------------------------------------------------------------------
Static Function At581SetFlt(aSeek, oBrowse)
Local aFilter := {}
Local nC := 0

For nC := 1 to Len(aSeek)
	If Len(aSeek[nC]) >= 2 .and. Len(aSeek[nC, 02]) == 1 .AND.  Len(aSeek[nC, 02, 01]) >= 7 .and. !Empty(aSeek[nC, 02, 01 ,07])
		If aScan(aFilter, {|f| f[1] == aSeek[nC, 02, 01, 07]}) == 0
			aAdd(aFilter, {aSeek[nC, 02, 01, 07], aSeek[nC, 02,01, 05], aSeek[nC, 02,01, 02], aSeek[nC, 02,01, 03], aSeek[nC, 02,01, 04], IIF(Empty(aSeek[nC, 02,01, 06]), "", aSeek[nC, 02, 01, 06])})
		EndIf
	EndIf
Next nC 

If Len(aFilter) > 0
	oBrowse:SetTemporary(.T.)
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetFilterDefault( "" ) 
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetFieldFilter(aFilter)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckTDX

@description Verifica se o item de Efetivo da Escala é válido

@author	Kaique Schiller
@since	03/11/2021
/*/
//------------------------------------------------------------------------------
Static Function CheckTDX(oMdl)
Local cComTW1 	:= FwModeAccess("TW1",1) +  FwModeAccess("TW1",2) + FwModeAccess("TW1",3)
Local cComTGZ 	:= FwModeAccess("TGZ",1) +  FwModeAccess("TGZ",2) + FwModeAccess("TGZ",3)
Local cComTFF	:= FwModeAccess("TFF",1) +  FwModeAccess("TFF",2) + FwModeAccess("TFF",3)
Local lFilTff	:= TW1->(ColumnPos("TW1_FILTFF") > 0)
Local lMtFIl	:= cComTFF == "EEE" .AND. (LEN(STRTRAN( cComTW1  , "E" )) > LEN(STRTRAN(  cComTGZ  , "E" ))) .AND. lFilTff
Local cTDXCod   := oMdl:GetValue("TW1_CODTDX")
Local cFilTW1   := Iif(lMtFIl,oMdl:GetValue("TW1_FILTFF"),cFilAnt)
Local lRet  := .T.
Local cQry	:= ""

cQry := " SELECT 1 "
cQry += " FROM " + RetSqlName("TDX") + " TDX "
cQry += " WHERE TDX.TDX_FILIAL = '" +  xFilial('TDX',cFilTW1) + "' AND "
cQry += " TDX.D_E_L_E_T_ = ' ' "
If !EMPTY(cTDXCod)
	cQry += " AND TDX.TDX_COD = '" + cTDXCod + "' "
EndIF

If (QryEOF(cQry))
	lRet := .F.
	Help(,,"CheckTDX",,STR0253,1,0) //"Código de Configuração de Alocação de Efetivo não localizado."
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldRtVaga

@description Validação para verifica se a rota esta vaga

@author	Kaique Schiller
@since	03/11/2021
/*/
//------------------------------------------------------------------------------
Static Function VldRtVaga(oMdl)
Local lRet := .T. 

//Se a rota já estiver vaga não é possível alterar
If (oMdl:GetValue("TW0_VAGA") == "2" .Or. Empty(oMdl:GetValue("TW0_VAGA"))) .And. !Empty(oMdl:GetValue("TW0_ATEND")) .And.;
	 Posicione("TW0",1,xFilial("TW0")+oMdl:GetValue("TW0_COD"),"TW0_VAGA") == "1" .And. !IsInCallStack("At581Efet")
	lRet := .F.
	Help(,,"VldRtVaga",,STR0251,1,0) //"Não é possível alterar o campo de rota vaga, realize a troca de efetivo."
Elseif oMdl:GetValue("TW0_VAGA") == "1" .And. Empty(oMdl:GetValue("TW0_ATEND"))
	lRet := .F.
	Help(,,"VldRtVaga",,STR0252,1,0) //"Essa rota não foi movimentada, realize a movimentação para habilitar o campo de rota vaga."
Endif

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At581HeVag

@description Função para exclusão de manutenção para rota vaga
@author	Kaique Schiller
@since	03/11/2021
/*/
//------------------------------------------------------------------------------
Static Function At581HeVag(aPosto,dDtIniRt, dDtFimRt, cMsgShwLog)
Local lOk			:= .T.
Local cAliasQuery	:= ""
Local nSuperior 	:= 0
Local nEsquerda 	:= 0
Local nInferior 	:= 432
Local nDireita  	:= 864
Local aAgdMntEft	:= {}
Local nX			:= 0
Local lRet			:= .T.
Default aPosto		:= {}
Default dDtIniRt	:= ""
Default dDtFimRt	:= ""
Default cMsgShwLog	:= ""

For nX := 1 to Len(aPosto)

	cCodTFF := aPosto[nX,1]
	cCodTDX := aPosto[nX,2]
	nGrupo  := aPosto[nX,3]
	cCodHE  := aPosto[nX,4]
	
	cAliasQuery	:= GetNextAlias()	
	
	BeginSql Alias cAliasQuery

		SELECT ABQ.ABQ_CODTFF,
			   ABB.ABB_CODIGO,
			   ABB.ABB_CODTEC,
			   ABB.ABB_ATENDE,
			   ABB.ABB_MANUT,
			   TDV.TDV_DTREF,
			   ABR.ABR_HRFIMA,
			   ABR.ABR_HRFIM,
			   TGY.TGY_GRUPO,
			   ABR.R_E_C_N_O_ REC
		FROM %table:TGY% TGY
			INNER JOIN %table:ABQ% ABQ on %xFilial:ABQ% = ABQ.ABQ_FILIAL
									AND ABQ.%NotDel%
									AND %xFilial:TGY% = ABQ.ABQ_FILTFF
									AND ABQ.ABQ_CODTFF= TGY.TGY_CODTFF
			INNER JOIN %table:ABB% ABB on ABB.ABB_FILIAL = %xFilial:ABB%
									AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM
									AND ABB.ABB_CODTEC = TGY.TGY_ATEND
									AND ABB.%NotDel%
			INNER JOIN %table:TDV% TDV on TDV.TDV_FILIAL = %xFilial:TDV%
									AND TDV.%NotDel%
									AND TDV.TDV_CODABB = ABB.ABB_CODIGO
			INNER JOIN %table:ABR% ABR on ABR.ABR_FILIAL = %xFilial:ABR%
									AND ABR.%NotDel%
									AND ABR.ABR_AGENDA = TDV.TDV_CODABB
			INNER JOIN %table:ABN% ABN on ABN.ABN_FILIAL = %xFilial:ABN%
									AND ABN.%NotDel%
									AND ABN.ABN_CODIGO = ABR.ABR_MOTIVO
		WHERE TGY.TGY_FILIAL = %xFilial:TGY%
		AND TGY.%NotDel%
		AND TGY.TGY_CODTFF = %Exp:cCodTFF%
		AND TGY.TGY_CODTDX = %Exp:cCodTDX%
		AND TGY.TGY_GRUPO  = %Exp:nGrupo%
		AND ABB.ABB_MANUT  = '1'
		AND ABR.ABR_MOTIVO = %Exp:cCodHE%
		AND TDV.TDV_DTREF BETWEEN  %Exp:dDtIniRt% AND %Exp:dDtFimRt% 
		GROUP BY ABQ.ABQ_CODTFF,
					ABB.ABB_CODIGO,
					ABB.ABB_CODTEC,
					ABB.ABB_ATENDE,
					ABB.ABB_MANUT,
					TDV.TDV_DTREF,
					ABR.ABR_HRFIMA,
					ABR.ABR_HRFIM,
				 TGY.TGY_GRUPO,
					ABR.R_E_C_N_O_
	EndSql

	While ((cAliasQuery)->(!EOF()))

		aAdd(aAgdMntEft, { 	(cAliasQuery)->ABB_CODIGO,;
							(cAliasQuery)->ABB_CODTEC,;
							Posicione("AA1",1,xFilial("AA1")+(cAliasQuery)->ABB_CODTEC,"AA1_NOMTEC"),;
							Stod((cAliasQuery)->TDV_DTREF),;
							(cAliasQuery)->ABR_HRFIMA,;
							(cAliasQuery)->ABR_HRFIM,;
							(cAliasQuery)->ABQ_CODTFF,;
							"",;
							(cAliasQuery)->REC}  )

		(cAliasQuery)->(DbSkip())
	EndDo
	
	(cAliasQuery)->(DbCloseArea())

Next nX

If !Empty(aAgdMntEft)
	DEFINE MSDIALOG oDlgEscTela TITLE STR0239 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Agendas com Manutenção de Hora Extra do Efetivo."
		@ 2, 9 SAY STR0240 SIZE 300, 19 PIXEL //"Existem agendas com manutenção de hora extra dos efetivos para cobrir o Almocista/Jantista no período que a rota está vaga. Gostaria de excluir as manutenções? "
		oListBox := TWBrowse():New(039, 007, 415, 165,,{},,oDlgEscTela,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oListBox:addColumn(TCColumn():New(STR0241 ,&("{|| oListBox:aARRAY[oListBox:nAt,7] }"),,,,,30)) //"Código do RH"
		oListBox:addColumn(TCColumn():New(STR0242 ,&("{|| oListBox:aARRAY[oListBox:nAt,2] }"),,,,,45)) //"Código do Atendente" 
		oListBox:addColumn(TCColumn():New(STR0243 ,&("{|| oListBox:aARRAY[oListBox:nAt,3] }"),,,,,45))   //"Nome do Atendente"
		oListBox:addColumn(TCColumn():New(STR0244 ,&("{|| oListBox:aARRAY[oListBox:nAt,4] }"),,,,,45))  //"Data de Referência"
		oListBox:addColumn(TCColumn():New(STR0245,&("{|| TECCdow(DOW(oListBox:aARRAY[oListBox:nAt,4])) }"),,,,,39))    //"Dia"
		oListBox:addColumn(TCColumn():New(STR0246 ,&("{|| oListBox:aARRAY[oListBox:nAt,5] }"),,,,,39))     //"Horario Inicial"
		oListBox:addColumn(TCColumn():New(STR0247 ,&("{|| oListBox:aARRAY[oListBox:nAt,6] }"),,,,,39))       //"Horario Final"
		oExit := TButton():New( 12, 380, STR0248 ,oDlgEscTela,{|| oListBox:aARRAY := {}, lOk := .T., FwMsgRun(Nil,{|| lRet := At581DlMnt(aAgdMntEft,@cMsgShwLog)}, Nil, STR0250) ,oDlgEscTela:End() }, 38,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Sim" ## "Removendo as manutenções..."
		oExit := TButton():New( 12, 340, STR0249 ,oDlgEscTela,{|| oListBox:aARRAY := {}, lOk := .F., oDlgEscTela:End() }, 38,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Não"
		
		oListBox:SetArray(aAgdMntEft)
		oListBox:Refresh()
	ACTIVATE MSDIALOG oDlgEscTela CENTERED
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581DlMnt

@description Função para exclusão de manutenções
@author	Kaique Schiller
@since	03/11/2021
/*/
//------------------------------------------------------------------------------
Static Function At581DlMnt(aDelMnt,cMsgShwLog)
Local nX			:= 0
Local oMdl550 		:= Nil 
Local aErroMVC 		:= {}
Local nFail			:= 0
Local lRet			:= .T.
Default aDelMnt 	:= {}
Default cMsgShwLog  := {}

Begin Transaction

oMdl550 := FwLoadModel("TECA550")

At550SetAlias("ABB")
At550SetGrvU(.T.)

For nX := 1 To Len(aDelMnt)
	ABB->(DbSetOrder(8))
	ABB->(DbSeek(xFilial("ABB") + aDelMnt[nX][1]))

	DbSelectArea("ABR")
	ABR->(DbGoTo(aDelMnt[nX][9]))

	oMdl550:SetOperation( MODEL_OPERATION_DELETE )
	oMdl550:Activate()

	If !oMdl550:VldData() .OR. !oMdl550:CommitData()
		nFail++
		aErroMVC := oMdl550:GetErrorMessage()
		At581GrLog(aErroMVC,@cMsgShwLog,aDelMnt[nX][7], .T.)
		DisarmTransaction()
		lRet := .F.
		Exit
	EndIf
	oMdl550:DeActivate()
Next nX

At550SetAlias("")
At550SetGrvU(.F.)

End Transaction

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At581Cmt

@description Função para gravaçao da rota de cobertura
@author	Kaique Schiller
@since	29/11/2021
/*/
//------------------------------------------------------------------------------
Function At581Cmt(oModel)
Local lRotaVaga	:= .F. 
Local lRet  	:= .T. 

If At581RtVag() .And.;
	oModel:GetValue("TW0MASTER","TW0_VAGA") == "1" .And.;
	Posicione("TW0",1,xFilial("TW0")+oModel:GetValue("TW0MASTER","TW0_COD"),"TW0_VAGA") <> "1"	
	lRotaVaga := .T.
Endif

lRet := FwFormCommit(oModel)

If lRet .And. lRotaVaga
	At581ExbVg(oModel)
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581ExbVg

@description Exibe a tela para geração de manutenção de hora extra para rota vaga.
@author	Kaique Schiller
@since	29/11/2021
/*/
//------------------------------------------------------------------------------
Static Function At581ExbVg(oModel)
Local nX		:= 0
Local aAtend	:= {}
Local aAgdEfetv := {}
Local oMdlTW1 	:= oModel:GetModel("TW1DETAIL")
Local cCodTFF 	:= ""
Local cCodTDX 	:= ""
Local nGrupo  	:= 0
Local cCodHE  	:= ""
Local dDtIniRt 	:= sTod("")
Local dDtFimRt 	:= sTod("")
Local nSuperior := 0
Local nEsquerda := 0
Local nInferior := 432
Local nDireita  := 864
Local nPos		:= 0

DbSelectArea("ABR")
ABR->(DbSetOrder(1))
For nX := 1 to oMdlTW1:Length()
	oMdlTW1:GoLine(nX)
	If !oMdlTW1:IsDeleted() .And. !Empty(oMdlTW1:GetValue("TW1_CODTFF"))
		cCodTFF := oMdlTW1:GetValue("TW1_CODTFF")
		cCodTDX := oMdlTW1:GetValue("TW1_CODTDX")
		nGrupo  := oMdlTW1:GetValue("TW1_GRUPO")
		cCodHE  := oMdlTW1:GetValue("TW1_CODHE")
		dDtIniRt := oMdlTW1:GetValue("TW1_DTINI")
		dDtFimRt := oMdlTW1:GetValue("TW1_DTFIM")
		cAliasQuery	:= GetNextAlias()
		
		BeginSql Alias cAliasQuery

			SELECT  ABQ.ABQ_CODTFF,
					ABB.ABB_CODIGO,
					ABB.ABB_CODTEC,
					ABB.ABB_HRINI,
					ABB.ABB_HRFIM,
					ABB.ABB_TIPOMV,
					ABB.ABB_DTINI,
					ABB.ABB_DTFIM,
					TDV.TDV_SEQTRN,
					TDV.TDV_DTREF,
					TGY.TGY_DTINI,
					TGY.TGY_ULTALO,
					ABB.R_E_C_N_O_ RECABB
			FROM %table:TGY% TGY
				INNER JOIN %table:ABQ% ABQ on %xFilial:ABQ% = ABQ.ABQ_FILIAL
										AND ABQ.%NotDel%
										AND %xFilial:TGY% = ABQ.ABQ_FILTFF
										AND ABQ.ABQ_CODTFF= TGY.TGY_CODTFF
				INNER JOIN %table:ABB% ABB on ABB.ABB_FILIAL = %xFilial:ABB%
										AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM
										AND ABB.ABB_CODTEC = TGY.TGY_ATEND
										AND ABB.%NotDel%
				INNER JOIN %table:TDV% TDV on TDV.TDV_FILIAL = %xFilial:TDV%
										AND TDV.%NotDel%
										AND TDV.TDV_CODABB = ABB.ABB_CODIGO
			WHERE TGY.TGY_FILIAL = %xFilial:TGY%
				AND TGY.%NotDel%
				AND TGY.TGY_CODTFF = %Exp:cCodTFF%
				AND TGY.TGY_CODTDX = %Exp:cCodTDX%
				AND TGY.TGY_GRUPO  = %Exp:nGrupo%
				AND ABB.ABB_ATIVO = '1'
				AND ( %Exp:dDtIniRt% BETWEEN TGY.TGY_DTINI AND TGY.TGY_ULTALO 
					OR  %Exp:dDtFimRt% BETWEEN TGY.TGY_DTINI AND TGY.TGY_ULTALO )
				AND TDV.TDV_DTREF  > %Exp:dDtFimRt%
			GROUP BY ABQ.ABQ_CODTFF,
				ABB.ABB_CODIGO,
				ABB.ABB_CODTEC,
				ABB.ABB_HRINI,
				ABB.ABB_HRFIM,
				ABB.ABB_TIPOMV,
				ABB.ABB_DTINI,
				ABB.ABB_DTFIM,
				TDV.TDV_SEQTRN,
				TDV.TDV_DTREF,
				TGY.TGY_DTINI,
				TGY.TGY_ULTALO,
				ABB.R_E_C_N_O_ 
			ORDER BY ABQ.ABQ_CODTFF,
				ABB.ABB_CODIGO,
				ABB.ABB_CODTEC
			EndSql

		While ((cAliasQuery)->(!EOF()))
			If !ABR->(MsSeek(xFilial("ABR") + (cAliasQuery)->ABB_CODIGO ))
				If aScan(aAtend, {|x| x[1] == (cAliasQuery)->ABQ_CODTFF .And.;
										x[2] == (cAliasQuery)->ABB_CODTEC .And.;
										x[4] == dDtFimRt .And.;
										x[5] == sTod((cAliasQuery)->TGY_ULTALO) }) == 0

					aAdd(aAtend, { 		(cAliasQuery)->ABQ_CODTFF,;
										(cAliasQuery)->ABB_CODTEC,;
										Posicione("AA1",1,xFilial("AA1")+(cAliasQuery)->ABB_CODTEC,"AA1_NOMTEC"),;
										dDtFimRt,;
										sTod((cAliasQuery)->TGY_ULTALO) } )

					aAdd(aAgdEfetv, { {oMdlTW1:GetValue("TW1_CODTDW"),;
									oMdlTW1:GetValue("TW1_CODTFF"),;
									oMdlTW1:GetValue("TW1_CODTDX"),;
									oMdlTW1:GetValue("TW1_CODTW0"),;
									oMdlTW1:GetValue("TW1_COD")},{} })

					nPos := Len(aAgdEfetv)

				Endif
				If nPos > 0
					aAdd(aAgdEfetv[nPos,2], { (cAliasQuery)->RECABB,;
												(cAliasQuery)->ABB_CODIGO,;
												(cAliasQuery)->ABB_CODTEC,;
												(cAliasQuery)->ABB_HRINI,;
												(cAliasQuery)->ABB_HRFIM,;
												(cAliasQuery)->ABB_TIPOMV,;
												sTod((cAliasQuery)->ABB_DTINI),;
												sTod((cAliasQuery)->ABB_DTFIM),;
												(cAliasQuery)->TDV_SEQTRN,;
												sTod((cAliasQuery)->TDV_DTREF)})		
				Endif
			Endif
			(cAliasQuery)->(DbSkip())
		EndDo
		(cAliasQuery)->(DbCloseArea())
	Endif
Next nX

If !Empty(aAtend)
	DEFINE MSDIALOG oDlgEscTela TITLE STR0265 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Rota Vaga"
		@ 2, 9 SAY STR0266 SIZE 300, 19 PIXEL //"Existem agendas geradas para esses efetivos. Gostaria de gerar manutenções de hora extra para cobrir o Almocista/Jantista no período que a rota está vaga?"
		oListBox := TWBrowse():New(039, 007, 415, 165,,{},,oDlgEscTela,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oListBox:addColumn(TCColumn():New(STR0241 ,&("{|| oListBox:aARRAY[oListBox:nAt,1] }"),,,,,45)) //"Código do RH"
		oListBox:addColumn(TCColumn():New(STR0242 ,&("{|| oListBox:aARRAY[oListBox:nAt,2] }"),,,,,80)) //"Código do Atendente" 
		oListBox:addColumn(TCColumn():New(STR0243 ,&("{|| oListBox:aARRAY[oListBox:nAt,3] }"),,,,,80)) //"Nome do Atendente"
		oListBox:addColumn(TCColumn():New(STR0267 ,&("{|| oListBox:aARRAY[oListBox:nAt,4] }"),,,,,80))  //"Data ínicio "
		oListBox:addColumn(TCColumn():New(STR0268 ,&("{|| oListBox:aARRAY[oListBox:nAt,5] }"),,,,,20))   //"Data final "
		oExit := TButton():New( 12, 380, STR0248 ,oDlgEscTela,{|| oListBox:aARRAY := {}, lOk := .T., FwMsgRun(Nil,{|| At581GrMnt(aAgdEfetv)}, Nil, STR0269 ) ,oDlgEscTela:End() }, 38,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Sim" ## "Gerando manutenções de intrajornada para o efetivo..."
		oExit := TButton():New( 12, 340, STR0249 ,oDlgEscTela,{|| oListBox:aARRAY := {}, lOk := .F., oDlgEscTela:End() }, 38,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Não"
		oListBox:SetArray(aAtend)
		oListBox:Refresh()
	ACTIVATE MSDIALOG oDlgEscTela CENTERED
Endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At581GrMnt

@description Gera as manutenções de hora extra de intrajornada para rota vaga.
@author	Kaique Schiller
@since	29/11/2021
/*/
//------------------------------------------------------------------------------
Static Function At581GrMnt(aAgend)
Local nX := 0
Default aAgend := {}

For nX := 1 to Len(aAgend)
	
	At58gGera(aAgend[nX,2],aAgend[nX,1,1],; //TW1_CODTDW
						   aAgend[nX,1,2],; //TW1_CODTFF
						 ,,aAgend[nX,1,3],; //TW1_CODTDX
						   aAgend[nX,1,4],; //TW1_CODTW0
						   aAgend[nX,1,5])  //TW1_COD
Next nX

Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} At581AlcTr

@description Realocação de rota vaga.
@author	Kaique Schiller
@since	20/01/2022
/*/
//------------------------------------------------------------------------------
Static Function At581AlcTr(cAtdMvRmv,dDtIniRt,dDtFimRt)
Default cAtdMvRmv := ""
Default dDtIniRt := sTod("")
Default dDtFimRt := sTod("")
At581Alc(,,cAtdMvRmv,dDtIniRt,dDtFimRt)
Return
