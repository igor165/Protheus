#include 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA580G.CH"
#DEFINE NPOS_HRFLEX 01
#DEFINE NPOS_HRINIFLX 01
#DEFINE NPOS_HRFIMFLX 02

Static cRetF3 := ""
//-------------------------------------------------------------------
/*/{Protheus.doc} TECA580G
	Rotina de cadastro de Manutenções Programadas

@author	boiani
@since 26/11/2019
/*/
//-------------------------------------------------------------------
Function TECA580G()
Local oBrw := FwMBrowse():New()
Local aCampos := At580GCampo()

Private aRotina	:= MenuDef()
oBrw:SetAlias('TDX')
oBrw:SetFields(aCampos)
oBrw:SetOnlyFields( { 'TDX_COD', 'TDX_CODTDW', 'TDX_TURNO', 'TDX_SEQTUR', 'TDX_TIPO', 'TDX_STATUS' } )
oBrw:SetDescription( OEmToAnsi( STR0001) ) //"Manutenções Programadas"
If !IsBlind()
	oBrw:Activate()
EndIf	

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Menudef
	Opções de menu da rotina

@author	boiani
@since 26/11/2019
/*/
//-------------------------------------------------------------------
Static Function Menudef()
Local aMenu := {}

ADD OPTION aMenu Title STR0002 Action 'VIEWDEF.TECA580G' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aMenu Title STR0003 Action 'VIEWDEF.TECA580G' OPERATION 4 ACCESS 0 //'Alterar'

Return aMenu
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados

@author	boiani
@since 26/11/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel := Nil
Local oStrTDX 	:= FWFormStruct(1,"TDX")
Local oStrTGW 	:= FWFormStruct(1,"TGW")
Local oStrTXH 	:= FWFormStruct(1,"TXH")
Local lDescLoc	:= oStrTXH:HasField('TXH_DESLOC')

xAux := FwStruTrigger( 'TXH_MANUT', 'TXH_DSMANU',;
	'Posicione("ABN",1,xFilial("ABN") + FwFldGet("TXH_MANUT")+"04","ABN_DESC")', .F. )
	oStrTXH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXH_CODTFF', 'TXH_DSCTFF',;
	'At580GTgDs()', .F. )
	oStrTXH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXH_CODTCU', 'TXH_DSTCU',;
	'Posicione("TCU",1,xFilial("TCU") + FwFldGet("TXH_CODTCU"),"TCU_DESC")', .F. )
	oStrTXH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	
xAux := FwStruTrigger( 'TXH_MANUT', 'TXH_HORAIN',;
	'At580GTgHr("TXH_HORAIN")', .F. )
	oStrTXH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXH_MANUT', 'TXH_HORAFI',;
	'At580GTgHr("TXH_HORAFI")', .F. )
	oStrTXH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXH_CODTFF', 'TXH_HORAIN',;
	'At580GTgHr("TXH_HORAIN")', .F. )
	oStrTXH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXH_CODTFF', 'TXH_HORAFI',;
	'At580GTgHr("TXH_HORAFI")', .F. )
	oStrTXH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXH_CODTCU', 'TXH_HORAIN',;
	'At580GTgHr("TXH_HORAIN")', .F. )
	oStrTXH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TXH_CODTCU', 'TXH_HORAFI',;
	'At580GTgHr("TXH_HORAFI")', .F. )
	oStrTXH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

If lDescLoc
	xAux := FwStruTrigger( 'TXH_CODTFF', 'TXH_DESLOC',;
		'At580GDesL()', .F. )
		oStrTXH:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])	
EndIf

oModel := MPFormModel():New("TECA580G", /*bPreValidacao*/, {|oModel| At580GTdOk(oModel) }, /*bCommit*/, /*bCancel*/ )
oModel:AddFields("TDXMASTER", /*cOwner*/, oStrTDX, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid("TGWDETAIL", "TDXMASTER", oStrTGW,/*bLinePre*/, /*bLinePost*/,/*bPreVal*/,,{|oModel|AtLoadTGW(oModel)})
oModel:SetRelation("TGWDETAIL",{{"TGW_FILIAL","xFilial('TGW')"},{"TGW_EFETDX","TDX_COD"}},TGW->(IndexKey(1)))

oModel:AddGrid("TXHDETAIL", "TGWDETAIL", oStrTXH,/*bLinePre*/, /*bLinePost*/,/*bPreVal*/,,/*bCarga*/)
oModel:SetRelation("TXHDETAIL",{{"TXH_FILIAL","xFilial('TXH')"},{"TXH_CODPAI","TGW_COD"}},TXH->(IndexKey(2)))

oModel:SetDescription(STR0001) //"Manutenções Programadas"

oStrTDX:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
oStrTGW:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)

oStrTDX:SetProperty("*", MODEL_FIELD_WHEN,  {||.F.})
oStrTGW:SetProperty("*", MODEL_FIELD_WHEN,  {||.F.})

oStrTXH:SetProperty('TXH_MANUT' ,MODEL_FIELD_VALID,{|oModel,cField,xNewValue| At580GVMnt(oModel,cField,xNewValue)})
oStrTXH:SetProperty('TXH_CODTFF',MODEL_FIELD_VALID,{|oModel,cField,xNewValue| At580GVTff(oModel,cField,xNewValue)})
oStrTXH:SetProperty('TXH_CODTCU',MODEL_FIELD_VALID,{|oModel,cField,xNewValue| At580GVTcu(oModel,cField,xNewValue)})

If At580GMtFil()
	oStrTXH:SetProperty('TXH_MTFIL',MODEL_FIELD_VALID,{|oModel,cField,xNewValue| At580GVFil(oModel,cField,xNewValue)})
Endif

oModel:getModel('TXHDETAIL'):SetOptional(.T.)

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	boiani
@since 29/05/2019
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView := NIL
Local oModel := ModelDef()
Local oStrTDX := FWFormStruct( 2, "TDX" )
Local oStrTGW := FWFormStruct( 2, "TGW" )
Local oStrTXH := FWFormStruct( 2, "TXH" )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_TDX', oStrTDX, 'TDXMASTER' )
oView:AddGrid('VIEW_TGW' , oStrTGW, 'TGWDETAIL')
oView:AddGrid('VIEW_TXH' , oStrTXH, 'TXHDETAIL')

oStrTDX:RemoveField('TDX_QUANT')
oStrTGW:RemoveField('TDX_STATUS')
oStrTGW:RemoveField('TGW_COBTDX')
oStrTGW:RemoveField('TGW_COBTIP')
oStrTGW:RemoveField('TGW_EFETDX')
oStrTXH:RemoveField('TXH_CODPAI')
oStrTXH:RemoveField('TXH_CODIGO')

If isInCallStack("At580MPlRo")
	oStrTXH:RemoveField('TXH_CODTCU')
	oStrTXH:RemoveField('TXH_DSTCU')
EndIf

If At580GMtFil()
	oStrTXH:SetProperty( "TXH_MTFIL", MVC_VIEW_LOOKUP	, "SM0")
	oStrTXH:SetProperty( "TXH_MTFIL", MVC_VIEW_ORDEM	, "07" )
Endif

oView:CreateHorizontalBox( 'TOP'   , 18 )
oView:CreateHorizontalBox( 'MIDDLE', 45 )
oView:CreateHorizontalBox( 'BOTTOM', 37 )

oView:SetOwnerView( "VIEW_TDX", "TOP" )
oView:SetOwnerView( "VIEW_TGW", "MIDDLE" )
oView:SetOwnerView( "VIEW_TXH", "BOTTOM" )

oView:EnableTitleView('VIEW_TGW',STR0004) //"Dia Trabalhado"
oView:EnableTitleView('VIEW_TXH',STR0005) //"Manutenção de Hora Extra"

oView:AddUserButton(STR0040, "", { || At580GRpl()  }) //"Replicar Manutenções"
oView:AddUserButton(STR0049,"", {|| At580DlMt()}) //"Excluir manutenções"

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} AtLoadTGW
	Bloco de load da grid TDX

@author	boiani
@since 29/05/2019
/*/
//-------------------------------------------------------------------
Function AtLoadTGW(oMdl)
Local aRet := {}
Local cAliasTGW := GetNextAlias()
Local nLenFlds := 0
Local aAux := {}
Local oModel := oMdl:GetModel()
Local oMdlTDX := oModel:GetModel('TDXMASTER')
Local cCodTDX := oMdlTDX:GetValue('TDX_COD')
Local oStru   := oMdl:GetStruct()
Local nI := 1
Local aAreaX3 := SX3->(GetArea())
Local aFields := {}
Local cWhere	:= ""

If IsInCallStack("At580MPlRo")
	cWhere := "% AND TGW.TGW_STATUS = '2' %"
Else
	cWhere := "% AND TGW.TGW_STATUS = '1' %"
EndIf

BeginSql Alias cAliasTGW
	SELECT * FROM  %table:TGW% TGW
			WHERE TGW.TGW_FILIAL = %xFilial:TGW%
				AND TGW.TGW_EFETDX = %Exp:cCodTDX%
				AND TGW.%notDel%
				%Exp:cWhere%
EndSql

If (cAliasTGW)->(!Eof())

	aFields := oStru:GetFields()
	nLenFlds := Len(aFields)
	SX3->(DbSetOrder(2))
	
	While (cAliasTGW)->(!Eof())
		TGW->(DbGoTo((cAliasTGW)->R_E_C_N_O_))
		aAux := Array(nLenFlds)
		
		For nI := 1 To nLenFlds
			cField := aFields[nI, MODEL_FIELD_IDFIELD]
			If !aFields[nI, MODEL_FIELD_VIRTUAL]

				If aFields[nI, MODEL_FIELD_TIPO] $ 'C|N|L'
					aAux[nI] := (cAliasTGW)->&(cField)
				ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'M'
					aAux[nI] := TGW->&(cField)
				ElseIf aFields[nI, MODEL_FIELD_TIPO] == 'D'
					aAux[nI] := STOD((cAliasTGW)->&(cField))
				EndIf
			EndIf

		Next nI
		Aadd(aRet,{(cAliasTGW)->R_E_C_N_O_,aAux})
		(cAliasTGW)->(DbSkip())
	EndDo
EndIf
RestArea(aAreaX3)
(cAliasTGW)->(DbCloseArea())

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} At580GCampo
	Adiciona os campos "Descrição da Escala" e "Sequência" no Browse

@author	boiani
@since 29/05/2019
/*/
//-------------------------------------------------------------------
Static Function At580GCampo()
Local aRet := {}

aAdd( aRet, { STR0006 	,{ || (POSICIONE("TDW",1,xFilial("TDW")+TDX->TDX_CODTDW, "TDW_DESC")) } , "C" , Alltrim(GetSx3Cache( "TDW_DESC", "X3_PICTURE" )) , 0 , TamSX3("TDW_DESC")[1] , 0 , , , , , , , } ) //"Descrição da Escala"
aAdd( aRet, { STR0007 	,{ || (TDX->TDX_SEQTUR) } , "C" , Alltrim(GetSx3Cache( "TDX_SEQTUR", "X3_PICTURE" )) , 0 , TamSX3("TDX_SEQTUR")[1] , 0 , , , , , , , } ) //"Sequência"


Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} InitDados

@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação

@author	boiani
@since	26/11/2019
/*/
//-------------------------------------------------------------------
Static Function InitDados(oModel)
Local aArea 		:= GetArea()
Local aSaveLines 	:= FWSaveRows()
Local cFilBkp	    := cFilAnt
Local lMtFilTFF 	:= At580GMtFil()
Local nX
Local nY
Local oMdlTXH 		:= oModel:GetModel("TXHDETAIL")
Local oMdlTGW 		:= oModel:GetModel("TGWDETAIL")
Local lDescLoc		:= oMdlTXH:HasField('TXH_DESLOC')

For nY := 1 To oMdlTGW:Length()
	oMdlTGW:GoLine(nY)
	For nX := 1 To oMdlTXH:Length()
		oMdlTXH:GoLine(nX)
		If !EMPTY(oMdlTXH:GetValue("TXH_MANUT"))
			oMdlTXH:LoadValue('TXH_DSMANU',Posicione("ABN",1,xFilial("ABN") + oMdlTXH:GetValue("TXH_MANUT")+"04","ABN_DESC"))
		EndIf
		If !EMPTY(oMdlTXH:GetValue("TXH_CODTFF"))
			If lMtFilTFF .And. !Empty(oMdlTXH:GetValue("TXH_MTFIL")) .And. cFilAnt <> oMdlTXH:GetValue("TXH_MTFIL")
				cFilAnt := oMdlTXH:GetValue("TXH_MTFIL")
			Endif
			oMdlTXH:LoadValue('TXH_DSCTFF',Posicione("SB1",1,xFilial("SB1") + Posicione("TFF",1,xFilial("TFF") + oMdlTXH:GetValue("TXH_CODTFF"),"TFF_PRODUT"),"B1_DESC"))
			If lDescLoc
				oMdlTXH:LoadValue('TXH_DESLOC',Posicione("ABS",1,xFilial("ABS") + Posicione("TFF",1,xFilial("TFF") + oMdlTXH:GetValue("TXH_CODTFF"),"TFF_LOCAL"),"ABS_DESCRI"))
			EndIf
			If lMtFilTFF .And. !Empty(oMdlTXH:GetValue("TXH_MTFIL")) .And. cFilBkp <> cFilAnt
				cFilAnt := cFilBkp
			Endif
		EndIf
		If !EMPTY(oMdlTXH:GetValue("TXH_CODTCU"))
			oMdlTXH:LoadValue('TXH_DSTCU',Posicione("TCU",1,xFilial("TCU") + oMdlTXH:GetValue("TXH_CODTCU"),"TCU_DESC"))
		EndIf
	Next nX
Next nY

oMdlTGW:SetNoInsertLine(.T.)
oMdlTGW:SetNoDeleteLine(.T.)
oMdlTGW:SetNoUpdateLine(.T.)

FWRestRows( aSaveLines )
RestArea(aArea)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} At58gGera

@description Executa a criação das manutenções de H.E. dentro de uma barra de load
@author	boiani
@since	26/11/2019
/*/
//-------------------------------------------------------------------
Function At58gGera(aAgendas, cEscala, cCodTFF, aFeriados, cAtendFlex, cDefConF, cCodRt, cItemRt, nGrupo)
Local nTotal 	:= 0
Local oDlg		:= nil
Local oSayMtr	:= nil
Local oMeter	:= nil
Local nMeter	:= 0
Local aManut	:= {}

Default aAgendas    := {}
Default aFeriados   := {}
Default cAtendFlex	:= ""
Default cDefConF	:= ""
Default cCodRt 		:= ""
Default cItemRt		:= ""
Default nGrupo		:= 0

nTotal := LEN(aAgendas)

If isBlind()
	aManut := LoadHE(aAgendas,cEscala,cCodTFF,/*oDlg*/,/*oMeter*/,aFeriados,cAtendFlex,cDefConF,cCodRt,cItemRt,nGrupo)
Else
	DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0008 //"Carregando manutenções programadas"
		oSayMtr := tSay():New(10,10,{||STR0009},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
		oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.)
		
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (aManut := LoadHE(aAgendas,cEscala,cCodTFF,@oDlg,@oMeter,aFeriados,cAtendFlex,cDefConF,cCodRt,cItemRt,nGrupo))
EndIf

nTotal 	:= LEN(aManut)
oDlg	:= nil
oSayMtr	:= nil
nMeter	:= 0

If isBlind()
	InsertHE(aManut)
Else
	DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0010 //"Inserindo manutenções programadas"
		oSayMtr := tSay():New(10,10,{||STR0009},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
		oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg,220,10,,.T.)
		
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( InsertHE(aManut,@oDlg,@oMeter) )
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadHE

@description Compara as agendas inseridas com o cadastro de manutenções
	planejadas e retorna em um array de duas posições Agendas x Manut.Planejada
@author	boiani
@since	26/11/2019
/*/
//-------------------------------------------------------------------
Static Function LoadHE(aAgendas,cEscala,cCodTFF,oDlg,oMeter, aFeriados, cAtendFlex, cDefConF, cCodRt, cItemRt, nGrupo )
Local lLoadBar := .F.
Local lDiaFeriad := .F.
Local cQry := GetNextAlias()
Local aMntTXH := {} 
Local nX
Local nY
Local nAux
Local nAuxTDY	:= 0
Local aRet := {}
Local aBkpTXH := {}
Local cFeriad
Local cSpaceTCU := SPACE(TamSX3("TCU_COD")[1])
Local cSpaceTFF := SPACE(TamSX3("TFF_COD")[1]) 
Local lGsGeHor	:= SuperGetMV('MV_GSGEHOR',,.F.)
Local cSlcGsHr	:= ""
Local cLeftGsHr := ""
Local cCodAtd	:= ""
Local dDtIniRf 	:= sTod("")
Local dDtFimRf 	:= sTod("")
Local cSql		:= ""
Local cCondition := ""
Local lMtFilTFF := At580GMtFil()
Local lMV_GSLOG   := SuperGetMV('MV_GSLOG',,.F.)
Local lFeriad   := TXH->( ColumnPos("TXH_FERIAD")) > 0
Local lEntra1	:= .F.
Local lEntra2	:= .F.
Local lEntra3	:= .F.
Local lEntra4	:= .F.
Local lRota		:= isInCallStack("At581Efet") .Or. isInCallStack("At581dYCmt")
Local lAvulso	:= isInCallStack("AT190GCmt")
Local oGsLog	:= nil
Local aExecs	:= LoadExcec(cEscala)
Local nHe		:= 0
Local nHS		:= 0
Local nHrTDYe 	:= 0
Local nHrTDYs 	:= 0
Local lManutPl	:= ExistBlock("At580GHE")
Local lRtVaga	:= FindFunction('At581RtVag') .And. At581RtVag()
Default oDlg 	:= nil
Default oMeter 	:= nil
Default aFeriados 	:= {}
Default cAtendFlex  := "" 
Default cDefConF 	:= "" 
Default cCodRt 		:= "" 
Default cItemRt 	:= ""
Default nGrupo		:= 0

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

If lMV_GSLOG
	oGsLog  := GsLog():new()
	oGsLog:addLog("TECA580GLoadHE", STR0054 + cEscala ) //"Escala: "
	oGsLog:addLog("TECA580GLoadHE", STR0055 + cCodTFF ) //"Código da TFF: "
EndIf

If !(lRtVaga .And. IsInCallStack("At581GrMnt"))
	If !lAvulso
		If lGsGeHor
			DbSelectArea("TGY")
			If (lGsGeHor := TGY->(ColumnPos("TGY_ENTRA1")) > 0)

				If !Empty(aAgendas)
					cCodAtd 	:= aAgendas[1,3]
					dDtIniRf 	:= aAgendas[1,10]
					dDtFimRf 	:= aAgendas[Len(aAgendas),10]
					If lMV_GSLOG
						oGsLog:addLog("TECA580GLoadHE", STR0056 + cCodAtd ) //"Atendente: "
						oGsLog:addLog("TECA580GLoadHE", STR0057 + DTOC(dDtIniRf) ) //"Data Início: "
						oGsLog:addLog("TECA580GLoadHE", STR0058 + DTOC(dDtFimRf) ) //"Data Fim: "
					EndIf
				Endif

				cSlcGsHr := ",TGY.TGY_ENTRA1,"
				cSlcGsHr += " TGY.TGY_SAIDA1,"
				cSlcGsHr += " TGY.TGY_ENTRA2,"
				cSlcGsHr += " TGY.TGY_SAIDA2,"
				cSlcGsHr += " TGY.TGY_ENTRA3,"
				cSlcGsHr += " TGY.TGY_SAIDA3,"
				cSlcGsHr += " TGY.TGY_ENTRA4,"
				cSlcGsHr += " TGY.TGY_SAIDA4 "
						
				cLeftGsHr := " JOIN "+RetSqlName("TGY")+" TGY ON TGY.TGY_FILIAL = '" + xFilial("TGY") + "'"
				cLeftGsHr +=	" AND TGY.TGY_ESCALA = TDX.TDX_CODTDW"
				cLeftGsHr +=	" AND TGY.TGY_CODTFF = '" + cCodTFF + "'"
				If lRota
					If !Empty(cAtendFlex)
						cLeftGsHr +=	" AND TGY.TGY_ATEND  = '" + cAtendFlex + "'"
					Endif
				Else
					cLeftGsHr +=	" AND TGY.TGY_ATEND  = '" + cCodAtd + "'"
				EndIf
				cLeftGsHr +=	" AND '" + dTos(dDtIniRf) + "' BETWEEN TGY.TGY_DTINI AND TGY.TGY_DTFIM"
				cLeftGsHr +=	" AND '" + dTos(dDtFimRf) + "' BETWEEN TGY.TGY_DTINI AND TGY.TGY_DTFIM"
				cLeftGsHr +=	" AND TGY.TGY_ULTALO <> ''"
				cLeftGsHr +=	" AND TGY.D_E_L_E_T_ = ''"

			Endif
		Endif

		cSql += "SELECT TXH.TXH_CODTCU, "
		cSql +=	"TXH.TXH_CODTFF,"
		cSql +=	"TXH.TXH_HORAFI,"
		cSql +=	"TXH.TXH_HORAIN,"
		cSql +=	"TXH.TXH_MANUT,"
		cSql +=	"TXH.TXH_CODPAI,"
		cSql +=	"TXH.TXH_CODIGO,"
		If lFeriad
			cSql +=	"TXH.TXH_FERIAD,"
		EndIf
		cSql +=	"TDX.TDX_COD,"
		cSql +=	"TDX.TDX_SEQTUR,"
		cSql +=	"TGW.TGW_DIASEM,"
		cSql +=	"TGW.TGW_HORINI,"
		cSql +=	"TGW.TGW_HORFIM "
		If !Empty(cSlcGsHr)
			cSql += cSlcGsHr + " "
		EndIf
		If lMtFilTFF 
			cSql +=	",TXH.TXH_MTFIL "
		Endif
		cSql += "FROM "+retSqlName("TXH")+" TXH "
		cSql += "JOIN "+retSqlName("TGW")+" TGW "
		cSql += "ON TGW.TGW_FILIAL = '"+xFilial('TGW')+"' AND "
		cSql += "TGW.TGW_COD = TXH.TXH_CODPAI "
		cSql += "JOIN "+retSqlName("TDX")+" TDX ON "
		cSql += "TDX.TDX_FILIAL = '"+xFilial('TDX')+"' AND "
		cSql += "TDX.TDX_COD = TGW.TGW_EFETDX "
		If !Empty(cLeftGsHr)
			cSql += cLeftGsHr
		EndIf
		If lRota .AND. lGsGeHor
			cSql += " JOIN " + retSqlName("TGX") + " TGX "
			cSql += " ON TGX.TGX_FILIAL = '" + xFilial("TGX") + "' "
			cSql += " AND TGX.TGX_CODTDW = TDX.TDX_CODTDW "
			cSql += " AND TGX.TGX_ITEM = TGW.TGW_COBTDX "
			cSql += " AND TGX.D_E_L_E_T_ = ' ' "
			cSql += " JOIN " + retSqlName("TGZ") + " TGZ "
			cSql += " ON TGZ.TGZ_FILIAL = '" + xFilial("TGZ")  + "' "
			cSql += " AND TGZ.TGZ_CODTFF = '" + cCodTFF + "' "
			cSql += " AND TGZ.TGZ_ATEND = '" + cCodAtd + "' "
			cSql += " AND TGZ.D_E_L_E_T_ = ' ' "
			If TW0->(ColumnPos("TW0_TIPO")) > 0
				cSql += " JOIN " + RetSqlName("TW0") + " TW0 "
				cSql += " ON TW0.TW0_COD = TGZ.TGZ_CODTW0 "
				cSql += " AND TW0.TW0_FILIAL = '" + xFilial("TW0") + "' "
				cSql += " AND TW0.TW0_TIPO = '1' "
				cSql += " AND TW0.D_E_L_E_T_ = ' ' "
			EndIf
		EndIf
		cSql += "WHERE TXH.TXH_FILIAL = '"+xFilial('TXH')+"' "
		cSql += "AND TXH.D_E_L_E_T_ = ' ' "
		cSql += "AND TGW.D_E_L_E_T_ = ' ' "
		cSql += "AND TDX.TDX_CODTDW = '"+cEscala+"' "

		If lMtFilTFF
			cSql += "AND ( TXH.TXH_MTFIL = '"+cFIlAnt+"' OR TXH.TXH_MTFIL = '' ) "
			cSql += "ORDER BY TXH.TXH_MTFIL DESC "
		Endif

		cSql := ChangeQuery(cSql)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cQry, .F., .T.)

		If lMV_GSLOG
			oGsLog:addLog("TECA580GLoadHE", REPLICATE("-",20) + CRLF)
		EndIf

		DbSelectArea("TXH")
		TXH->(DbSetOrder(1))

		DbSelectArea("SPJ")
		SPJ->(DbSetOrder(1))

		DbSelectArea("TGW")
		TGW->(DbSetOrder(1))
		While !(cQry)->(EOF())
			
			If lGsGeHor .And. !Empty((cQry)->(TGY_ENTRA1))

				nAux := At580GEnSa(	(cQry)->(TDX_COD)	,;
									(cQry)->(TGW_DIASEM),;
									(cQry)->(TGW_HORINI),;
									(cQry)->(TGW_HORFIM) )

				cHrIni	:= (cQry)->(&("TGY_ENTRA"+cValToChar(nAux)))
				cHrFim	:= (cQry)->(&("TGY_SAIDA"+cValToChar(nAux)))
				If (cQry)->(TGW_HORINI) <> TecConvHr((cQry)->(TXH_HORAIN))
					cHrIni := IntToHora(Round((HoraToInt((cQry)->(TXH_HORAIN))-HoraToInt(TecConvHr((cQry)->(TGW_HORINI))))+HoraToInt(cHrIni),2))
				Endif
				
				If (cQry)->(TGW_HORFIM) <> TecConvHr((cQry)->(TXH_HORAFI))
					cHrFim := IntToHora(Round((HoraToInt((cQry)->(TXH_HORAFI))-HoraToInt(TecConvHr((cQry)->(TGW_HORFIM))))+HoraToInt(cHrFim),2))
				Endif
						
				AADD(aMntTXH, {(cQry)->(TXH_CODTCU),;	//[1]
								(cQry)->(TXH_CODTFF),;	//[2]
								cHrFim,;				//[3]
								cHrIni,;				//[4]
								(cQry)->(TXH_MANUT),;	//[5]
								(cQry)->(TDX_SEQTUR),;	//[6]
								(cQry)->(TGW_DIASEM),;	//[7]
								TecConvHr((cQry)->(&("TGY_ENTRA"+cValToChar(nAux)))),;	//[8]
								TecConvHr((cQry)->(&("TGY_SAIDA"+cValToChar(nAux)))),;  //[9]
								Iif(lMtFilTFF ,(cQry)->(TXH_MTFIL),""),; //[10]
								IIF(lFeriad, IIF(EMPTY((cQry)->(TXH_FERIAD)),"3",(cQry)->(TXH_FERIAD)), "3"),;	//[11]
								(cQry)->(TXH_CODPAI),;  //[12]
								(cQry)->(TXH_CODIGO)})  //[13]

			Else
				AADD(aMntTXH, {(cQry)->(TXH_CODTCU),;	//[1]
								(cQry)->(TXH_CODTFF),;	//[2]
								(cQry)->(TXH_HORAFI),;	//[3]
								(cQry)->(TXH_HORAIN),;	//[4]
								(cQry)->(TXH_MANUT),;	//[5]
								(cQry)->(TDX_SEQTUR),;	//[6]
								(cQry)->(TGW_DIASEM),;	//[7]
								(cQry)->(TGW_HORINI),;	//[8]
								(cQry)->(TGW_HORFIM),;	//[9]
								Iif(lMtFilTFF ,(cQry)->(TXH_MTFIL),""),; 	//[10]
								IIF(lFeriad, IIF(EMPTY((cQry)->(TXH_FERIAD)),"3",(cQry)->(TXH_FERIAD)), "3"),; 	//[11]
								(cQry)->(TXH_CODPAI),;  //[12]
								(cQry)->(TXH_CODIGO)})  //[13]

			Endif
			(cQry)->(DbSkip())

			If lMV_GSLOG
				oGsLog:addLog("TECA580GLoadHE", "TXH_CODTCU: " + aMntTXH[LEN(aMntTXH)][1] )
				oGsLog:addLog("TECA580GLoadHE", "TXH_CODTFF: " + aMntTXH[LEN(aMntTXH)][2] )
				oGsLog:addLog("TECA580GLoadHE", "TXH_HORAFI: " + aMntTXH[LEN(aMntTXH)][3] )
				oGsLog:addLog("TECA580GLoadHE", "TXH_HORAIN: " + aMntTXH[LEN(aMntTXH)][4] )
				oGsLog:addLog("TECA580GLoadHE", "TXH_MANUT: " + aMntTXH[LEN(aMntTXH)][5] )
				oGsLog:addLog("TECA580GLoadHE", "TDX_SEQTUR: " + aMntTXH[LEN(aMntTXH)][6] )
				oGsLog:addLog("TECA580GLoadHE", "TGW_DIASEM: " + aMntTXH[LEN(aMntTXH)][7] )
				oGsLog:addLog("TECA580GLoadHE", "TGW_HORINI: " + cValToChar(aMntTXH[LEN(aMntTXH)][8]) )
				oGsLog:addLog("TECA580GLoadHE", "TGW_HORFIM: " + cValToChar(aMntTXH[LEN(aMntTXH)][9]) )
				oGsLog:addLog("TECA580GLoadHE", "TXH_MTFIL: " + aMntTXH[LEN(aMntTXH)][10] )
				oGsLog:addLog("TECA580GLoadHE", REPLICATE("-",20) + CRLF)
			EndIf

		EndDo 

		(cQry)->(DbCloseArea())
	Else
		aMntTXH := GetManutPla()
	EndIf
Else
	If !Empty(aAgendas)
		dDtIniRf := aAgendas[1,10]
		dDtFimRf := aAgendas[Len(aAgendas),10]
	Endif
Endif

If lRtVaga
	 GetMntRtVg(@aMntTXH,cCodTFF,cDefConF,dDtIniRf,dDtFimRf,cCodRt,cItemRt,nGrupo)
Endif
/*
aAgendas[x]
	[x][01] = RECNO())
	[x][02] = ABB->ABB_CODIGO
	[x][03] = ABB->ABB_CODTEC
	[x][04] = ABB->ABB_HRINI
	[x][05] = ABB->ABB_HRFIM
	[x][06] = ABB->ABB_TIPOMV
	[x][07] = ABB->ABB_DTINI
	[x][08] = ABB->ABB_DTFIM
	[x][09] = Sequência
	[x][10] = TDV_DTREF
*/
For nX := 1 To LEN(aAgendas)
	nAux := 0
	nAuxTDY := 0
	lDiaFeriad := .F.
	cCondition := "3"
	aBkpTXH := ACLONE(aMntTXH)
	lEntra1	:= .F.
	lEntra2	:= .F.
	lEntra3	:= .F.
	lEntra4	:= .F.
	nHe		:= 0
	nHS		:= 0
	nHrTDYe := 0
	nHrTDYs := 0

	If lMV_GSLOG
		oGsLog:addLog("TECA580GLoadHE", STR0059 + aAgendas[nX][9] ) //"Sequência: "
		oGsLog:addLog("TECA580GLoadHE", STR0060 + aAgendas[nX][4] ) //"Hora Ini.: "
		oGsLog:addLog("TECA580GLoadHE", STR0061 + aAgendas[nX][5] ) //"Hora Fim.: "
		oGsLog:addLog("TECA580GLoadHE", STR0062 + DTOC(aAgendas[nX][10]) ) //"Data: "
		oGsLog:addLog("TECA580GLoadHE", STR0063 + aAgendas[nX][6] ) //"Cód. Movimentação: "
		oGsLog:addLog("TECA580GLoadHE", CRLF)
	EndIf
	If lFeriad .AND. !EMPTY(aFeriados)
		If ASCAN(aFeriados,{|a| a[6][1][1] == aAgendas[nX][2]}) > 0
			lDiaFeriad := .T.
		EndIf
	EndIf

	If lDiaFeriad
		cCondition := "1|3"
	Else
		cCondition := "2|3"
	EndIf

	//Verificar se existe exceções para aplicar manutenções planejadas
	If !Empty(aExecs)
		If lDiaFeriad
			cFeriad := '1'
		Else
			cFeriad := '2'
		EndIF

		If (nAuxTDY := ASCAN(aExecs, {|a| a[11] == cFeriad .AND.;
						((lEntra1 := (aAgendas[nX][4] == TecNumToHr(a[3]) .AND. aAgendas[nX][5] == TecNumToHr(a[4]))) ;
					.OR. (lEntra2 := (aAgendas[nX][4] == TecNumToHr(a[5]) .AND. aAgendas[nX][5] == TecNumToHr(a[6]))) ; 
					.OR. (lEntra3 := (aAgendas[nX][4] == TecNumToHr(a[7]) .AND. aAgendas[nX][5] == TecNumToHr(a[8]))) ; 
					.OR. (lEntra4 := (aAgendas[nX][4] == TecNumToHr(a[9]) .AND. aAgendas[nX][5] == TecNumToHr(a[10])))) .AND. ;
						a[13] == aAgendas[nX][9] .AND. cValToChar(DOW(aAgendas[nX][10])) == a[1] ;
					})) > 0
			For nY := 1 To LEN(aMntTXH)
				If aMntTXH[nY][06] == aAgendas[nX][09] .AND. SPJ->(MsSeek(xFilial("SPJ") + aExecs[nAuxTDY][12] + aAgendas[nX][9] + cValToChar(DOW(aAgendas[nX][10])))) .And.;
					TGW->(MsSeek(xFilial("TGW") + aMntTXH[nY][12]))
					If lEntra1
						nHe := SPJ->PJ_ENTRA1
						nHS := SPJ->PJ_SAIDA1
						nHrTDYe := aExecs[nAuxTDY][3]
						nHrTDYs := aExecs[nAuxTDY][4]
					ElseIf lEntra2
						nHe := SPJ->PJ_ENTRA2
						nHS := SPJ->PJ_SAIDA2
						nHrTDYe := aExecs[nAuxTDY][5]
						nHrTDYs := aExecs[nAuxTDY][6]
					ElseIf lEntra3
						nHe := SPJ->PJ_ENTRA3
						nHS := SPJ->PJ_SAIDA3
						nHrTDYe := aExecs[nAuxTDY][7]
						nHrTDYs := aExecs[nAuxTDY][8]
					ElseIf lEntra4
						nHe := SPJ->PJ_ENTRA4
						nHS := SPJ->PJ_SAIDA4
						nHrTDYe := aExecs[nAuxTDY][9]
						nHrTDYs := aExecs[nAuxTDY][10]
					EndIf
					If TGW->TGW_HORINI == nHe .AND.;
							TGW->TGW_HORFIM == nHS .AND.;
								TGW->TGW_DIASEM == aExecs[nAuxTDY][1] .AND.;
									TXH->(MsSeek(xFilial("TXH") + aMntTXH[nY][13]))

						cHrIni	:= TecNumToHr(nHrTDYe)
						cHrFim	:= TecNumToHr(nHrTDYs)	

						If TGW->TGW_HORINI <> TecConvHr(TXH->TXH_HORAIN)
							cHrIni := IntToHora(Round((HoraToInt(TXH->TXH_HORAIN)-HoraToInt(TecConvHr(TGW->TGW_HORINI)))+HoraToInt(cHrIni),2))
						Endif
						
						If TGW->TGW_HORFIM <> TecConvHr(TXH->TXH_HORAFI)
							cHrFim := IntToHora(Round((HoraToInt(TXH->TXH_HORAFI)-HoraToInt(TecConvHr(TGW->TGW_HORFIM)))+HoraToInt(cHrFim),2))
						Endif
						
						aMntTXH[nY][8] := nHrTDYe
						aMntTXH[nY][9] := nHrTDYs
						aMntTXH[nY][3] := cHrFim
						aMntTXH[nY][4] := cHrIni
					EndIf
				Endif
			Next nY
		EndIf
	EndIf

	If ASCAN(aMntTXH, {|a| a[6] == aAgendas[nX][9] .AND.;
							TecNumToHr(a[8]) == aAgendas[nX][4] .AND.;
							TecNumToHr(a[9]) == aAgendas[nX][5] .AND.;
							cValToChar(DOW(aAgendas[nX][10])) == a[7] }) > 0

		If (nAux := ASCAN(aMntTXH, {|a| TecNumToHr(a[8]) == aAgendas[nX][4] .AND.;
		 								TecNumToHr(a[9]) == aAgendas[nX][5] .AND.;
		 								cValToChar(DOW(aAgendas[nX][10])) == a[7] .AND.;
		 								cCodTFF == a[2] .AND.;
		 								aAgendas[nX][6] == a[1] .AND.;
		 								a[6] == aAgendas[nX][9] .AND.;
										a[11] $ cCondition})) == 0

		 	If (nAux := ASCAN(aMntTXH, {|a| TecNumToHr(a[8]) == aAgendas[nX][4] .AND.;
		 								TecNumToHr(a[9]) == aAgendas[nX][5] .AND.;
		 								cValToChar(DOW(aAgendas[nX][10])) == a[7] .AND.;
		 								cCodTFF == a[2] .AND.;
		 								(cSpaceTCU == a[1] .OR. EMPTY(a[1])) .AND.;
		 								a[6] == aAgendas[nX][9] .AND.;
										a[11] $ cCondition})) == 0
			 	
				 If (nAux := ASCAN(aMntTXH, {|a| TecNumToHr(a[8]) == aAgendas[nX][4] .AND.;
			 								TecNumToHr(a[9]) == aAgendas[nX][5] .AND.;
			 								cValToChar(DOW(aAgendas[nX][10])) == a[7] .AND.;
			 								(cSpaceTFF == a[2] .OR. EMPTY(a[2])) .AND.;
			 								aAgendas[nX][6] == a[1] .AND.;
			 								a[6] == aAgendas[nX][9] .AND.;
											a[11] $ cCondition})) == 0
			 	
				 	nAux := ASCAN(aMntTXH, {|a| TecNumToHr(a[8]) == aAgendas[nX][4] .AND.;
			 								TecNumToHr(a[9]) == aAgendas[nX][5] .AND.;
			 								cValToChar(DOW(aAgendas[nX][10])) == a[7] .AND.;
			 								(cSpaceTFF == a[2] .OR. EMPTY(a[2])) .AND.;
			 								(cSpaceTCU == a[1] .OR. EMPTY(a[1])) .AND.;
			 								a[6] == aAgendas[nX][9] .AND.;
											a[11] $ cCondition})
			 	Endif
		 	EndIf
		EndIf
	EndIf
	If nAux > 0
		If lAvulso
			If AT190GManP(aAgendas[nX][10])
				AADD(aRet, {aAgendas[nX], aMntTXH[nAux]})
			EndIf
		Else
			AADD(aRet, {aAgendas[nX], aMntTXH[nAux]})
		EndIf
		If lMV_GSLOG
			oGsLog:addLog("TECA580GLoadHE", STR0064 + DTOC(aAgendas[nX][10]) + STR0065 +CRLF) //"Agenda " ## " adicionada para processamento."
		EndIf
	EndIf
	//Incluir as manutenções de hora extra para o efetivo cobrir o almocista/jantista
	If lLoadBar
		oMeter:Set(nX)
		oMeter:Refresh()
	EndIf
	aMntTXH := ACLONE(aBkpTXH)
	If lManutPl
		aRet := Execblock("At580GHE",.F.,.F.,{aAgendas[nX],aMntTXH,aRet})
	Endif
Next nX

If lLoadBar
	oDlg:End()
EndIf

If lMV_GSLOG
	oGsLog:printLog("TECA580GLoadHE")
EndIf

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} InsertHE

@description Insere as manutenções de H.E. 
@author	boiani
@since	26/11/2019
/*/
//-------------------------------------------------------------------
Static Function InsertHE(aManut,oDlg,oMeter)
Local nX
Local nY
Local oMdl550
Local oModel := FwModelActive()
Local nDiasINI := 0
Local nDiasFIM := 0
Local nFail := 0
Local aErrors := {}
Local aErroMVC := {}
Local cMsg := ""
Local lMtFilTFF := At580GMtFil()
Local cFilBkp := cFilAnt
Default oDlg := nil
Default oMeter := nil

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

If !EMPTY(aManut)
	oMdl550 := FwLoadModel("TECA550")
EndIf

For nX := 1 To Len(aManut)

	If lMtFilTFF .And. !Empty(aManut[nX][2][10]) .And. cFilAnt <> aManut[nX][2][10]
		cFilBkp	:= cFilAnt
		cFilAnt := aManut[nX][2][10]
	Endif
	
	nDiasFIM := 0
	nDiasINI := 0
	
	IF VAL(STRTRAN(aManut[nX][2][4],":",".")) > aManut[nX][2][8]
		nDiasINI := -1
	EndIF
	IF VAL(STRTRAN(aManut[nX][2][3],":",".")) < aManut[nX][2][9]
		nDiasFIM := 1
	EndIF
	ABB->(DbGoTo(aManut[nX][1][1]))

	ABQ->(DbSetOrder(1))
	ABQ->(MsSeek(xFilial("ABQ") + ABB->ABB_IDCFAL))

	TFF->(DbSetOrder(1))
	TFF->(MsSeek(xFilial("TFF") + ABQ->ABQ_CODTFF))
	
	At550SetAlias("ABB")
	At550SetGrvU(.T.)

	oMdl550:SetOperation( MODEL_OPERATION_INSERT)
	
	If (lRet := oMdl550:Activate())
		lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_MOTIVO", aManut[nX][2][5])
		lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_DTINI", (aManut[nX][1][7] + nDiasINI))
		lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_HRINI", aManut[nX][2][4] )
		lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_DTFIM", (aManut[nX][1][8] + nDiasFIM))
		lRet := lRet .AND. oMdl550:SetValue("ABRMASTER","ABR_HRFIM", aManut[nX][2][3] )
		If lRet
			Begin Transaction
				If !oMdl550:VldData() .OR. !oMdl550:CommitData()
					nFail++
					aErroMVC := oMdl550:GetErrorMessage()
					AADD(aErrors, {	 STR0011 + ' [' + AllToChar( aErroMVC[1] ) + ']',;	//"Id do formulário de origem:"
									STR0012 + ' [' + AllToChar( aErroMVC[2] ) + ']',;	//"Id do campo de origem:"
									STR0013 + ' [' + AllToChar( aErroMVC[3] ) + ']',;	//"Id do formulário de erro:"
									STR0014 + ' [' + AllToChar( aErroMVC[4] ) + ']',;	//"Id do campo de erro:"
									STR0015 + ' [' + AllToChar( aErroMVC[5] ) + ']',;	//"Id do erro:"
									STR0016 + ' [' + AllToChar( aErroMVC[6] ) + ']',;	//"Mensagem do erro:"
									STR0017 + ' [' + AllToChar( aErroMVC[7] ) + ']',;	//"Mensagem da solução:"
									STR0018 + ' [' + AllToChar( aErroMVC[8] ) + ']',;	//"Valor atribuído:"
									STR0019 + ' [' + AllToChar( aErroMVC[9] ) + ']';	//"Valor anterior:"
									})
					DisarmTransacation()
				EndIf
			End Transaction
		Else
			nFail++
			aErroMVC := oMdl550:GetErrorMessage()
			AADD(aErrors, {	 STR0011 + ' [' + AllToChar( aErroMVC[1] ) + ']',;	//"Id do formulário de origem:"
							STR0012 + ' [' + AllToChar( aErroMVC[2] ) + ']',;	//"Id do campo de origem:"
							STR0013 + ' [' + AllToChar( aErroMVC[3] ) + ']',;	//"Id do formulário de erro:"
							STR0014 + ' [' + AllToChar( aErroMVC[4] ) + ']',;	//"Id do campo de erro:"
							STR0015 + ' [' + AllToChar( aErroMVC[5] ) + ']',;	//"Id do erro:"
							STR0016 + ' [' + AllToChar( aErroMVC[6] ) + ']',;	//"Mensagem do erro:"
							STR0017 + ' [' + AllToChar( aErroMVC[7] ) + ']',;	//"Mensagem da solução:"
							STR0018 + ' [' + AllToChar( aErroMVC[8] ) + ']',;	//"Valor atribuído:"
							STR0019 + ' [' + AllToChar( aErroMVC[9] ) + ']';	//"Valor anterior:"
							})
		EndIf
	Else
		nFail++
		aErroMVC := oMdl550:GetErrorMessage()
		AADD(aErrors, {	 STR0011 + ' [' + AllToChar( aErroMVC[1] ) + ']',;	//"Id do formulário de origem:"
						STR0012 + ' [' + AllToChar( aErroMVC[2] ) + ']',;	//"Id do campo de origem:"
						STR0013 + ' [' + AllToChar( aErroMVC[3] ) + ']',;	//"Id do formulário de erro:"
						STR0014 + ' [' + AllToChar( aErroMVC[4] ) + ']',;	//"Id do campo de erro:"
						STR0015 + ' [' + AllToChar( aErroMVC[5] ) + ']',;	//"Id do erro:"
						STR0016 + ' [' + AllToChar( aErroMVC[6] ) + ']',;	//"Mensagem do erro:"
						STR0017 + ' [' + AllToChar( aErroMVC[7] ) + ']',;	//"Mensagem da solução:"
						STR0018 + ' [' + AllToChar( aErroMVC[8] ) + ']',;	//"Valor atribuído:"
						STR0019 + ' [' + AllToChar( aErroMVC[9] ) + ']';	//"Valor anterior:"
						})
	EndIf
	If lLoadBar
		oMeter:Set(nX)
		oMeter:Refresh()
	EndIf
	oMdl550:DeActivate()

	If lMtFilTFF .And. !Empty(aManut[nX][2][10]) .And. cFilAnt <> cFilBkp
		cFilAnt := cFilBkp
	Endif
Next nX

If lLoadBar
	oDlg:End()
EndIf

If VALTYPE(oModel) == 'O'
	FwModelActive(oModel)
Endif

If !EMPTY(aErrors)
	cMsg += STR0020 + " " + cValToChar(Len(aManut)) + CRLF	//"Total de Manutenções Programadas processadas:"
	cMsg += STR0021 + " " + cValToChar(Len(aManut) - nFail) + CRLF	//"Total de Manutenções Programadas incluídas:"
	cMsg += STR0022 + " " + cValToChar(nFail) + CRLF + CRLF	//"Total de Manutenções Programadas não incluídas:"
	cMsg += STR0023 + CRLF + CRLF	//"As Manutenções Programadas abaixo não foram inseridas: "
	For nX := 1 To LEN(aErrors)
		For nY := 1 To LEN(aErrors[nX])
			cMsg += aErrors[nX][nY] + CRLF
		Next
		cMsg += CRLF + REPLICATE("-",30) + CRLF
	Next
	If !ISBlind()
		AtShowLog(cMsg,STR0001,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.)	//"Manutenções Programadas"
	EndIf
EndIf

At550Reset()
At550SetAlias("")
At550SetGrvU(.F.)

Return aErrors
//-------------------------------------------------------------------
/*/{Protheus.doc} At580GVMnt

@description Valid do campo TXH_MANUT
@author	boiani
@since	26/11/2019
/*/
//-------------------------------------------------------------------
Function At580GVMnt(oModel,cField,xNewValue)
Local lRet := .T.
Local aArea := GetArea()
Default xNewValue := ""

If !EMPTY(xNewValue)
	ABN->(DbSetOrder(1))
	If !(lRet := (ABN->(DbSeek(xFilial("ABN")+xNewValue+"04"))))
		Help( " ", 1, "At580GVMnt", , STR0024, 1 ) //"Necessário informar um código de manutenção (ABN_CODIGO) correspondente a uma Hora Extra"
	EndIf
EndIf
RestArea(aArea)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} At580GVTcu

@description Valid do campo TXH_CODTCU
@author	boiani
@since	26/11/2019
/*/
//-------------------------------------------------------------------
Function At580GVTcu(oModel,cField,xNewValue)
Local lRet := .T.
Local aArea := GetArea()
Default xNewValue := ""

If !EMPTY(xNewValue)
	TCU->(DbSetOrder(1))
	If !(lRet := (TCU->(DbSeek(xFilial("TCU")+xNewValue))) .AND. TCU->TCU_EXALOC == '1')
		Help( " ", 1, "At580GVTcu", , STR0025, 1 ) //"Necessário informar um código de movimentação (TCU_COD) de alocação (TCU_EXALOC = 1)"
	EndIf
EndIf
RestArea(aArea)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} At580GVTff

@description Valid do campo TXH_CODTFF
@author	boiani
@since	26/11/2019
/*/
//-------------------------------------------------------------------
Function At580GVTff(oModel,cField,xNewValue)
Local lRet := .T.
Local cQry := GetNextAlias()
Local aArea := GetArea()
Local cSpcCTR := Space(TamSx3("CN9_NUMERO")[1])
Local cFilBkp := cFilAnt
Local lMtFilTFF  := At580GMtFil() .And. !Empty(oModel:GetValue("TXH_MTFIL")) 

Default xNewValue := ""

If !EMPTY(xNewValue)

	If lMtFilTFF .And. cFilAnt <> oModel:GetValue("TXH_MTFIL")
		cFilBkp := cFilAnt
		cFilAnt := oModel:GetValue("TXH_MTFIL")
	Endif

	BeginSQL Alias cQry
		SELECT 1
		FROM %Table:TFF% TFF
		JOIN %Table:TFL% TFL ON
			TFF.TFF_CODPAI = TFL.TFL_CODIGO AND
			TFL.TFL_FILIAL = %xFilial:TFL% AND
			TFL.%NotDel%
		JOIN %Table:TFJ% TFJ ON
			TFL.TFL_CODPAI = TFJ.TFJ_CODIGO AND
			TFJ.TFJ_FILIAL = %xFilial:TFJ% AND
			TFJ.%NotDel%
		WHERE TFF_FILIAL = %xFilial:TFF%
			AND TFF_COD = %Exp:xNewValue%
			AND TFJ.TFJ_STATUS = '1'
			AND TFJ.TFJ_CONTRT != %Exp:cSpcCTR% 
			AND TFF.%NotDel%
	EndSQL
	
	If !(lRet := !((cQry)->(EOF())))
		Help( " ", 1, "At580GVTff", , STR0026, 1 ) //"Código do posto (TFF_COD) inválido."
	EndIf
	
	(cQry)->(DbCloseArea())

	If lMtFilTFF .And. cFilAnt <> cFilBkp
		cFilAnt := cFilBkp
	Endif

EndIf

RestArea(aArea)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} At580GTgHr

@description Inicializa os campos TXH_HORAIN e TXH_HORAFI automaticamente
	com o mesmo valor da Escala. 
@author	boiani
@since	26/11/2019
/*/
//-------------------------------------------------------------------
Function At580GTgHr(cField)
Local cRet := ""
Local oModel := FwModelActive()
Local oMdlTGW := oModel:GetModel("TGWDETAIL") 

If !EMPTY(FwFldGet(cField))
	cRet := FwFldGet(cField)
Else
	If cField == "TXH_HORAIN"
		cRet := TecNumToHr(oMdlTGW:GetValue("TGW_HORINI"))
	ElseIF cField == "TXH_HORAFI"
		cRet := TecNumToHr(oMdlTGW:GetValue("TGW_HORFIM"))
	EndIf
Endif

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} At580gRF3

@description Variavel Static utilizada no F3 do Código do posto
@author	boiani
@since	26/11/2019
/*/
//-------------------------------------------------------------------
Function At580gRF3()

Return cRetF3
//-------------------------------------------------------------------
/*/{Protheus.doc} At580gCons

@description Monta a consulta padrão (F3) específica
@author	boiani
@since	26/11/2019
/*/
//-------------------------------------------------------------------
Function At580gCons(cTipo)
Local cSpcCTR := Space(TamSx3("CN9_NUMERO")[1])
Local cTitle
Local aSeek := {}
Local aIndex := {}
Local cQry
Local cAls := GetNextAlias()
Local nSuperior
Local nEsquerda
Local nInferior
Local nDireita
Local oDlgEscTela
Local oBrowse
Local lRet := .F.
Local oModel := FwModelActive()
Local cEscala := oModel:GetValue("TDXMASTER","TDX_CODTDW")
Local cFilBkp := cFilAnt
Local lMtFilTFF  := At580GMtFil() .And. !Empty(oModel:GetValue("TXHDETAIL","TXH_MTFIL")) 

If cTipo == "TFF"
	cTitle := STR0027 //"Posto de Trabalho"

	If lMtFilTFF .And. cFilAnt <> oModel:GetValue("TXHDETAIL","TXH_MTFIL")
		cFilBkp := cFilAnt
		cFilAnt := oModel:GetValue("TXHDETAIL","TXH_MTFIL")
	Endif
	
	Aadd( aSeek, { STR0028, {{"","C",TamSX3("TFF_COD")[1],0,STR0028,,}} } )		//"Código do Posto" # "Código do Posto"
	Aadd( aSeek, { STR0029, {{"","C",TamSX3("B1_COD")[1],0,STR0029,,}} } )		//"Código do Produto" # "Código do Produto"
	Aadd( aSeek, { STR0030, {{"","C",TamSX3("B1_DESC")[1],0,STR0030,,}} } )		//"Descrição" # "Descrição"
	Aadd( aSeek, { STR0031, {{"","C",TamSX3("TFF_CONTRT")[1],0,STR0031,,}} } )	//"Contrato" # "Contrato"
	Aadd( aSeek, { STR0032, {{"","C",TamSX3("ABS_DESCRI")[1],0,STR0032,,}} } )	//"Descrição do Posto" # "Descrição do Posto"

	Aadd( aIndex, "TFF_COD" )
	Aadd( aIndex, "B1_COD" )
	Aadd( aIndex, "B1_DESC" )
	Aadd( aIndex, "TFF_CONTRT" )
	Aadd( aIndex, "ABS_DESCRI" )
	Aadd( aIndex, "TFF_FILIAL")  // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último

	cQry := " SELECT TFF.TFF_FILIAL, TFF.TFF_COD, SB1.B1_COD, SB1.B1_DESC, TFF.TFF_CONTRT, ABS.ABS_DESCRI, TFF.TFF_PERINI, TFF.TFF_PERFIM, TFF.TFF_QTDVEN "
	cQry += " FROM " + RetSqlName("TFF") + " TFF "
	cQry += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = TFF.TFF_PRODUT AND "
	cQry += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
	cQry += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	cQry += " AND TFL.D_E_L_E_T_ = ' ' "
	cQry += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
	cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
	cQry += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
	cQry += " AND TFJ.D_E_L_E_T_ = ' ' "
	cQry += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQry += " AND TFJ.TFJ_STATUS = '1' "
	cQry += " AND TFJ.TFJ_CONTRT <> '" + cSpcCTR + "' "
	cQry += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS ON TFL.TFL_LOCAL = ABS.ABS_LOCAL AND "
	cQry += " ABS.ABS_FILIAL = '" + xFilial("ABS") + "' AND ABS.D_E_L_E_T_ = ' ' "
	cQry += " WHERE TFF.TFF_FILIAL = '" +  xFilial('TFF') + "' AND "
	cQry += " TFF.D_E_L_E_T_ = ' ' AND "
	cQry += " ( TFF.TFF_ESCALA = '"+cEscala+"' OR TFF.TFF_ESCALA = '"+Space(LEN(cEscala))+"' ) "
EndIf

nSuperior := 0
nEsquerda := 0

If !IsBlind()
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

	If cTipo $ "TFF"
		oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->TFF_COD, lRet := .T. ,oDlgEscTela:End()})
		oBrowse:AddButton( OemTOAnsi(STR0033), {|| cRetF3  := (oBrowse:Alias())->TFF_COD, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
	EndIf

	oBrowse:AddButton( OemTOAnsi(STR0034),  {|| cRetF3  := "", oDlgEscTela:End() } ,, 2 )	//"Cancelar"	
	oBrowse:DisableDetails()

	If cTipo $ "TFF"
		ADD COLUMN oColumn DATA { ||  TFF_COD  		} TITLE STR0028 SIZE TamSX3("TFF_COD")[1] OF oBrowse
		ADD COLUMN oColumn DATA { ||  STOD(TFF_PERINI ) 	} TITLE STR0035 SIZE TamSX3("TFF_PERINI")[1] OF oBrowse //"Período Inicial"
		ADD COLUMN oColumn DATA { ||  STOD(TFF_PERFIM ) 	} TITLE STR0036 SIZE TamSX3("TFF_PERFIM")[1] OF oBrowse //"Período Final"
		ADD COLUMN oColumn DATA { ||  TFF_QTDVEN  	} TITLE GetSX3Cache( "TFF_QTDVEN", "X3_DESCRIC" ) SIZE TamSX3("TFF_QTDVEN")[1] OF oBrowse
		ADD COLUMN oColumn DATA { ||  B1_COD 		} TITLE STR0029 SIZE TamSX3("B1_COD")[1] OF oBrowse
		ADD COLUMN oColumn DATA { ||  B1_DESC  		} TITLE STR0037 SIZE TamSX3("B1_DESC")[1] OF oBrowse //"Descrição do Serviço"
		ADD COLUMN oColumn DATA { ||  TFF_CONTRT  	} TITLE STR0031 SIZE TamSX3("TFF_CONTRT")[1] OF oBrowse
		ADD COLUMN oColumn DATA { ||  ABS_DESCRI  	} TITLE STR0038 SIZE TamSX3("ABS_DESCRI")[1] OF oBrowse //"Descrição do Local"
	EndIf
	oBrowse:Activate()

	ACTIVATE MSDIALOG oDlgEscTela CENTERED
EndIf

If cTipo $ "TFF" .And. lMtFilTFF .And. cFilAnt <> cFilBkp
	cFilAnt := cFilBkp
Endif

Return( lRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} At580GTdOk

@description posValid do modelo
@author	boiani
@since	26/11/2019
/*/
//-------------------------------------------------------------------
Function At580GTdOk(oModel)
Local lRet := .T.
Local nX
Local nY
Local oMdlTGW := oModel:GetModel('TGWDETAIL')
Local oMdlTXH := oModel:GetModel('TXHDETAIL')
Local lMtFilTFF := At580GMtFil()

For nX := 1 To oMdlTGW:Length()
	oMdlTGW:GoLine(nX)
	For nY := 1 To oMdlTXH:Length()
		oMdlTXH:GoLine(nY)
		If !EMPTY(oMdlTXH:GetValue('TXH_CODIGO')) .And. !oMdlTXH:IsDeleted()
			If TecNumToHr(oMdlTGW:GetValue("TGW_HORINI")) == oMdlTXH:GetValue("TXH_HORAIN") .AND.;
					TecNumToHr(oMdlTGW:GetValue("TGW_HORFIM")) == oMdlTXH:GetValue("TXH_HORAFI")
				lRet := .F.
				Help( " ", 1, "At580GTdOk", , STR0039, 1 ) //"Necessário informar um horário diferente do horário da Escala."
				Exit
			EndIf
			If lMtFilTFF .And. !Empty(oMdlTXH:GetValue("TXH_MTFIL")) .And. Empty(oMdlTXH:GetValue("TXH_CODTFF"))
				lRet := .F.
				Help( , , "At580GTdOk", , STR0050, 1, 0,,,,,,{STR0051}) //"O campo Fil. Sistema esta preenchido e o campo Cód. Posto esta vazio."##"Preencha o campo Cód. Posto."
				Exit
			Endif
		EndIf
	Next nY
	If !lRet
		Exit
	EndIf
Next nX

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At580GRpl

@description Realiza replica dos horários
@author	fabiana.silva
@since	09/03/2020
/*/
//-------------------------------------------------------------------

Static function At580GRpl(lView)

Local oModel 	:= FWModelActive()
Local aTDHDet 	:= {}
Local aTGWKey 	:= {}
Local aLinha 	:= {}
Local aSaveRows := {}
Local oView 	:= NIL
Local oMdlTGW 	:= oModel:GetModel("TGWDETAIL")
Local oMdlTXH 	:= oModel:GetModel("TXHDETAIL")
Local cNoCpos 	:= "TXH_FILIAL+TXH_CODIGO+TXH_CODPAI"
Local lSucess 	:= .T.
Local lEqual 	:= .T.
Local nLinTGW 	:= 0
Local nZ 		:= 0
Local nC 		:= 0
Local nX 		:= 0
Local lMtFilTFF := At580GMtFil()

Default lView := .T.

If oModel:GetOperation() ==  MODEL_OPERATION_UPDATE .OR. oModel:GetOperation() == MODEL_OPERATION_INSERT
	aSaveRows := FwSaveRows()

	If !oMdlTGW:IsEmpty() .AND.  !oMdlTXH:IsEmpty() 
		nLinTGW := oMdlTGW:GetLine()
		
		aAdd(aTGWKey, {"TGW_HORINI",  oMdlTGW:GetValue("TGW_HORINI")})
		aAdd(aTGWKey, {"TGW_HORFIM", oMdlTGW:GetValue("TGW_HORFIM")})
		aAdd(aTGWKey, {"TGW_STATUS", oMdlTGW:GetValue("TGW_STATUS")})

		oMdlTXH:GoLine(1)
		aTDHDet := {}
		For nC := 1 to oMdlTXH:Length()
			oMdlTXH:GoLine(nC)
			If !oMdlTXH:IsEmpty()  .AND. !oMdlTXH:IsDeleted()
				aLinha := {}
				For nX := 1 to Len(oMdlTXH:aHeader)
					If !oMdlTXH:aHeader[nX][02] $ cNoCpos
						aAdd(aLinha,  { oMdlTXH:aHeader[nX][02] , oMdlTXH:GetValue(oMdlTXH:aHeader[nX][02])})
					EndIf
				Next nX 
				aAdd(aTDHDet,  aClone(aLinha))
			EndIf
		Next 
		oMdlTGW:GoLine(1)

		If lSucess
			For nC := 1 to oMdlTGW:Length()
				If nC <> nLinTGW
					oMdlTGW:GoLine(nC)
					lEqual := .T.
					aEval(aTGWKey, {|l| lEqual := lEqual .AND. l[2] == oMdlTGW:GetValue(l[1])} )
					If lEqual
						For nX := 1 to Len(aTDHDet)
							If lMtFilTFF .And. oMdlTXH:SeekLine({{"TXH_MANUT", aTDHDet[nX][01][2]},{"TXH_CODTFF",aTDHDet[nX][05][2]},{"TXH_CODTCU",aTDHDet[nX][07][2]},{"TXH_MTFIL",aTDHDet[nX][09][2]} } ) .Or. ;
							 	(!lMtFilTFF .And. oMdlTXH:SeekLine({{"TXH_MANUT", aTDHDet[nX][01][2]},{"TXH_CODTFF",aTDHDet[nX][05][2]},{"TXH_CODTCU",aTDHDet[nX][07][2]} } ))
								For nZ := 1 to Len(aTDHDet[nX])
									If !aTDHDet[nX][nZ][02] $ "TXH_MANUT+TXH_DSMANU"
										oMdlTXH:LoadValue(aTDHDet[nX][nZ][01],aTDHDet[nX][nZ][02] )
									EndIf
								Next nZ
							Else
								If oMdlTXH:Length() == 1 .AND. Empty(oMdlTXH:GetValue('TXH_MANUT'))
									oMdlTXH:GoLine(1)
								Else
									oMdlTXH:GoLine(oMdlTXH:AddLine())
								EndIf

								For nZ := 1 to Len(aTDHDet[nX])
									oMdlTXH:LoadValue(aTDHDet[nX][nZ][01], aTDHDet[nX][nZ][02] )
								Next nZ
							EndIf
						Next nX 
					EndIf
				EndIf
			Next
		EndIf
	EndIf

	If lView
		oView := FwViewActive()
		oView:Refresh("VIEW_TGW")
	EndIf

	FwRestRows(aSaveRows)

	If lSucess
		MsgInfo(STR0041) //"Horários replicados com sucesso."
	else
		Help(,1,"At580GRpl",,STR0042, 1)  //"Falha  na replicação dos horários."
	EndIf
Else
	Help(,1,"At580GRpl",,STR0043, 1) //"Função somente permitida para as operações de inclusão e alteração" 
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At580GEnSa

@description Garante o numero da entrada e saida.
@author	Serviços
@since	18/03/2020
/*/
//-------------------------------------------------------------------
Function At580GEnSa(cCodTDX,cDiaSem,cHrIni,cHrFim)
Local nRet 		:= 0
Local cQry 		:= GetNextAlias()

BeginSQL Alias cQry
	SELECT TGW.TGW_HORINI,
		   TGW.TGW_HORFIM
	  FROM %Table:TGW% TGW
	 WHERE TGW.TGW_FILIAL = %xFilial:TGW%
	  	AND TGW.TGW_EFETDX = %Exp:cCodTDX%
	  	AND TGW.TGW_DIASEM = %Exp:cDiaSem%
		AND TGW.TGW_STATUS <> '3'
		AND TGW.%NotDel%
	ORDER BY TGW.TGW_COD
EndSQL

While !(cQry)->(EOF())
	nRet++
	IF (cQry)->(TGW_HORINI) == cHrIni .And. (cQry)->(TGW_HORFIM) == cHrFim
		Exit
	Endif
	(cQry)->(DbSkip())
EndDo

(cQry)->(DbCloseArea())

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At580DlMt

@description Realiza a exclusão em lote das manutenções planejadas
@author	Diego Bezerra
@since	03/04/2020
/*/
//-------------------------------------------------------------------
Static function At580DlMt()

Local oModel 	:= FWModelActive()
Local oMdlTGW 	:= oModel:GetModel("TGWDETAIL")
Local oMdlTXH 	:= oModel:GetModel("TXHDETAIL")
Local nX 		:= 0
Local nC 		:= 0
Local nDeleted	:= 0

If MsgYesNo(STR0044) //#"Deseja excluir todas as manutenções planejadas para essa escala?"
	For nC := 1 to oMdlTGW:Length()
		oMdlTGW:GoLine(nC)
		nX  := 1
		For nX := 1 to oMdlTXH:Length()
			oMdlTXH:GoLine(nX)
			If !oMdlTXH:IsEmpty()
				nDeleted ++
				oMdlTXH:DeleteLine()
			EndIf
		Next nX 
	Next nC

	If nDeleted > 0
		MsgInfo(STR0045+cValToChar(nDeleted)+STR0046) //"Foram excluidas "# " programações de manutenção."
	Else
		Help(,1,"At580DlMt",,STR0047, 1) //"Não existem programações para serem excluídas." 
	EndIf
Else
	Help(,1,"At580DlMt",,STR0048, 1) //"Operação cancelada.Nenhum registro foi excluído." 
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At580GMtFil
 
@description Campo de Multi-Filial do Sistema.
@author	Kaique Schiller
@since	19/05/2020
/*/
//-------------------------------------------------------------------
Static Function At580GMtFil()
Return TXH->( ColumnPos("TXH_MTFIL")) > 0

//-------------------------------------------------------------------
/*/{Protheus.doc} At580GVFil
 
@description Validação da Filial do sistema com a filial da TFF - Posto
@author	Kaique Schiller
@since	19/05/2020
/*/
//-------------------------------------------------------------------
Function At580GVFil(oModel,cField,xNewValue)
Local aAreaTFF := TFF->(GetArea())
Local lRet 	   := .T.
Local cFilBkp  := cFilAnt

If !Empty(xNewValue) 
	If ExistCpo("SM0",cEmpAnt+xNewValue)
		DbSelectArea("TFF")
		TFF->(DbSetOrder(1))
		If !Empty(oModel:GetValue("TXH_CODTFF"))
			cFIlAnt := xNewValue
			If !TFF->(DbSeek(xFilial("TFF")+oModel:GetValue("TXH_CODTFF")))
				lRet := .F.
				Help(,1,"At580GVFil",,STR0053, 1) //"Não é possível encontrar a filial relacionada a esse código de posto, informe um código de filial válido."
			Endif
			cFilAnt := cFilBkp
		Endif
	Endif
Endif

RestArea(aAreaTFF)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At580GTgDs
 
@description Gatilho de descrição do produto do posto.
@author	Kaique Schiller
@since	19/05/2020
/*/
//-------------------------------------------------------------------
Function At580GTgDs()
Local oModel 	:= FwModelActive()
Local oMdlTXH 	:= oModel:GetModel("TXHDETAIL")
Local lMtFilTFF := At580GMtFil() .And. !Empty(oMdlTXH:GetValue("TXH_MTFIL"))
Local cFilBkp   := cFilAnt
Local cRetDesc	:= ""

If lMtFilTFF .And. cFilAnt <> oMdlTXH:GetValue("TXH_MTFIL")
	cFilAnt := oMdlTXH:GetValue("TXH_MTFIL")
Endif

cRetDesc := Posicione("SB1",1,xFilial("SB1") + Posicione("TFF",1,xFilial("TFF") + oMdlTXH:GetValue("TXH_CODTFF"),"TFF_PRODUT"),"B1_DESC")

If lMtFilTFF .And. cFilBkp <> cFilAnt
	cFilAnt := cFilBkp
Endif

Return cRetDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} At580GDesL
 
@description Gatilho de descrição do local de atendimento do posto.
@author	Augusto Albuquerque
@since	27/05/2020
/*/
//-------------------------------------------------------------------
Function At580GDesL()
Local oModel 	:= FwModelActive()
Local oMdlTXH 	:= oModel:GetModel("TXHDETAIL")
Local lMtFilTFF := At580GMtFil() .And. !Empty(oMdlTXH:GetValue("TXH_MTFIL"))
Local cFilBkp   := cFilAnt
Local cCodTFF	:= oMdlTXH:GetValue("TXH_CODTFF")
Local cRetDesc	:= ""

If !Empty(cCodTFF)
	If lMtFilTFF .And. cFilAnt <> oMdlTXH:GetValue("TXH_MTFIL")
		cFilAnt := oMdlTXH:GetValue("TXH_MTFIL")
	Endif

	cRetDesc := Posicione("ABS",1,xFilial("ABS") + Posicione("TFF",1,xFilial("TFF") + cCodTFF,"TFF_LOCAL"),"ABS_DESCRI")

	If lMtFilTFF .And. cFilBkp <> cFilAnt
		cFilAnt := cFilBkp
	Endif
EndIf
Return cRetDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadExcec
 
@description Seleciona as exceções gerais e de feriados.
@author	Kaique Schiller
@since	09/12/2020
/*/
//-------------------------------------------------------------------
Static Function LoadExcec(cEscala)
Local cSql := ""
Local cAliasQry := ""
Local aRet := {}
Local lTDY_APLMAN := TDY->(ColumnPos("TDY_APLMAN")) > 0

If lTDY_APLMAN .Or. IsBlind()
	cSql += " SELECT TDY_DIASEM, "
	cSql += " TDY_CODTDX, "
	cSql += " TDY_ENTRA1, "
	cSql += " TDY_SAIDA1, "
	cSql += " TDY_ENTRA2, "
	cSql += " TDY_SAIDA2, "
	cSql += " TDY_ENTRA3, "
	cSql += " TDY_SAIDA3, "
	cSql += " TDY_ENTRA4, "
	cSql += " TDY_SAIDA4, "
	cSql += " TDY_FERIAD, "
	cSql += " TDX_TURNO, "
	cSql += " TDX_SEQTUR "
	cSql += " FROM " + RetSqlName("TDY") + " TDY "
	cSql += " INNER JOIN " + RetSqlName("TDX") + " TDX "
	cSql += " ON TDY.TDY_CODTDX = TDX.TDX_COD "
	cSql += " AND TDX.TDX_FILIAL = '" + xFilial('TDX') + "' "
	cSql += " AND TDX.D_E_L_E_T_ = ' ' "
	cSql += " AND TDX.TDX_CODTDW = '" + cEscala + "' "
	cSql += " WHERE "
	cSql += " TDY.TDY_FILIAL = '" + xFilial('TDY') + "' "
	If !IsBlind()
		cSql += " AND TDY.TDY_APLMAN = '1' "
	EndIf	
	cSql += " AND TDY.D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

	While !(cAliasQry)->(EOF())
		AADD(aRet, {;
			(cAliasQry)->TDY_DIASEM,; //1
			(cAliasQry)->TDY_CODTDX,; //2
			(cAliasQry)->TDY_ENTRA1,; //3
			(cAliasQry)->TDY_SAIDA1,; //4
			(cAliasQry)->TDY_ENTRA2,; //5
			(cAliasQry)->TDY_SAIDA2,; //6
			(cAliasQry)->TDY_ENTRA3,; //7
			(cAliasQry)->TDY_SAIDA3,; //8
			(cAliasQry)->TDY_ENTRA4,; //9
			(cAliasQry)->TDY_SAIDA4,; //10
			(cAliasQry)->TDY_FERIAD,; //11
			(cAliasQry)->TDX_TURNO,;  //12
			(cAliasQry)->TDX_SEQTUR;  //13
		})
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(DbCloseArea())
Endif

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} At580Gini
 
@description Seleciona as exceções gerais e de feriados.
@author	Matheus Goncalves
@since	27/04/2021
/*/
//-------------------------------------------------------------------
Function At580Gini(oModel)
	InitDados(oModel)
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} At580gExe
 
@description Seleciona as exceções gerais e de feriados.
@author	Matheus Goncalves
@since	27/04/2021
/*/
//-------------------------------------------------------------------
Function At580GLoad(cEscala)
	LoadExcec(cEscala)
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMntRtVg
 
@description Preenche o array com as manutenções para cobrir o Almocista/Jantista da rota de cobertura.
@author	Kaique Schiller
@since	15/10/2021
/*/
//-------------------------------------------------------------------
Static Function GetMntRtVg(aMntTXH,cCodTFF,cDefConF,dDtIniRf,dDtFimRf,cCodRt,cItemRt,nGrupo)
Local cSql 		:= ""
Local cAliasQry := ""
Local cCodTDW	:= ""
Local cCodHE 	:= ""
Local cHrIntIn 	:= ""
Local cHrIntSa	:= ""
Local nHorIniOr := 0
Local nHorFimOr := 0
Local cCodTCU   := Space(TamSx3("TXH_CODTCU")[1])
Local cCdPaiTXH := Space(TamSx3("TXH_CODPAI")[1])
Local cCodTXH	:= Space(TamSx3("TXH_CODIGO")[1])
Local cHrIni	:= ""
Local cHrFim	:= ""
Local lGsGeHor	:= FindFunction("TecXHasEdH") .And. TecXHasEdH()
Local cQryTGY	:= ""
Local aHorFlex  := {}
Local nX		:= 0
Local cDiaSem	:= ""
Local lStatus 	:= TW0->( ColumnPos('TW0_STATUS')) > 0
Default aMntTXH  := {}
Default cCodTFF  := ""
Default cDefConF := ""
Default cCodRt   := ""
Default cItemRt  := ""
Default nGrupo	:= 0

cSql := " SELECT TW1_CODHE, TW1_CODTDX, TW1_HORINI, TW1_HORFIM, TW1_GRUPO "
cSql += " FROM " + RetSqlName("TW1") + " TW1 "
cSql += " INNER JOIN " + RetSqlName("TW0") + " TW0 "
cSql += " ON TW0.TW0_COD = TW1.TW1_CODTW0 "
cSql += " AND TW0.TW0_FILIAL = '" + xFilial('TW0') + "' "
cSql += " AND TW0.D_E_L_E_T_ = ' ' "
cSql += " WHERE "
cSql += " TW1.TW1_FILIAL = '" + xFilial('TW1') + "' "
If !Empty(cCodRt)
	cSql += " AND TW1.TW1_CODTW0 = '" + cCodRt + "' "
Endif
If !Empty(cItemRt)
	cSql += " AND TW1.TW1_COD = '" + cItemRt + "' "
Endif
cSql += " AND TW1.TW1_CODTFF = '" + cCodTFF + "' "
cSql += " AND TW1.TW1_CODTDX = '" + cDefConF + "' "
If nGrupo <> 0
	cSql +=	" AND TW1.TW1_GRUPO  = " + cValToChar(nGrupo)
Endif
cSql += " AND TW0.TW0_VAGA = '1' "
cSql += " AND (TW0.TW0_TIPO = '2' OR TW0.TW0_TIPO = '3') "
If lStatus
	cSql += " AND TW0.TW0_STATUS <> '2' "
Endif
cSql += " AND TW1.D_E_L_E_T_ = ' ' "

cSql := ChangeQuery(cSql)
cAliasQry := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

//Após selecionar o posto de cobertura
If !(cAliasQry)->(EOF())

	cCodTDW := Posicione("TFF",1,xFilial("TFF")+cCodTFF,"TFF_ESCALA")
	cCodHE 	:= (cAliasQry)->TW1_CODHE
	cCodTDX := (cAliasQry)->TW1_CODTDX
	cHrIntIn := TecConvHr((cAliasQry)->TW1_HORINI)
	cHrIntSa := TecConvHr((cAliasQry)->TW1_HORFIM)
	nGrupo 	 := (cAliasQry)->TW1_GRUPO
	
	(cAliasQry)->(DbCloseArea())
	
	cSql := " SELECT TDX.TDX_COD, "
	cSql +=	" TDX.TDX_SEQTUR, "
	cSql +=	" TGW.TGW_DIASEM, "
	cSql +=	" TGW.TGW_HORINI, "
	cSql +=	" TGW.TGW_HORFIM, "
	cSql +=	" TGW.TGW_COBTIP, "
	cSql +=	" TGW.TGW_STATUS "
	cSql += " FROM " + RetSqlName("TGW") + " TGW "
	cSql += " INNER JOIN " + RetSqlName("TDX") + " TDX "
	cSql += " ON TDX.TDX_FILIAL = '"+xFilial('TDX')+"' "
	cSql += " AND TDX.TDX_COD = TGW.TGW_EFETDX "
	cSql += " AND TDX.D_E_L_E_T_ = ' ' "
	cSql += " WHERE "
	cSql += " TGW.TGW_FILIAL = '" + xFilial('TGW') + "' "
	cSql += " AND TGW.D_E_L_E_T_ = ' ' "
	cSql += " AND TDX.TDX_CODTDW = '" + cCodTDW + "' "
	cSql += " ORDER BY TGW.TGW_EFETDX, TGW.TGW_DIASEM "
	cSql := ChangeQuery(cSql)
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

	If lGsGeHor
		cSql := " SELECT TGY.TGY_ENTRA1,"
		cSql += " TGY.TGY_SAIDA1,"
		cSql += " TGY.TGY_ENTRA2,"
		cSql += " TGY.TGY_SAIDA2,"
		cSql += " TGY.TGY_ENTRA3,"
		cSql += " TGY.TGY_SAIDA3,"
		cSql += " TGY.TGY_ENTRA4,"
		cSql += " TGY.TGY_SAIDA4 "			
		cSql += " FROM "+RetSqlName("TGY")+" TGY "
		cSql += " WHERE TGY.TGY_FILIAL = '" + xFilial("TGY") + "'"
		cSql +=	" AND TGY.TGY_ESCALA = '" + cCodTDW  + "'"
		cSql +=	" AND TGY.TGY_CODTDX = '" + cDefConF + "'"
		cSql +=	" AND TGY.TGY_CODTFF = '" + cCodTFF  + "'"
		cSql +=	" AND TGY.TGY_GRUPO  = " + cValToChar(nGrupo)
		cSql +=	" AND '" + dTos(dDtIniRf) + "' BETWEEN TGY.TGY_DTINI AND TGY.TGY_DTFIM"
		cSql +=	" AND '" + dTos(dDtFimRf) + "' BETWEEN TGY.TGY_DTINI AND TGY.TGY_DTFIM"
		cSql += " AND TGY.TGY_ULTALO >= '" + dTos(dDtFimRf) + "' "
		cSql +=	" AND TGY.D_E_L_E_T_ = ''"
		cSql := ChangeQuery(cSql)
		cQryTGY := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cQryTGY, .F., .T.)
 		If (cQryTGY)->(!Eof())
			Aadd(aHorFlex, {{(cQryTGY)->TGY_ENTRA1,(cQryTGY)->TGY_SAIDA1 },;
							{(cQryTGY)->TGY_ENTRA2,(cQryTGY)->TGY_SAIDA2 },;
							{(cQryTGY)->TGY_ENTRA3,(cQryTGY)->TGY_SAIDA3 },;
							{(cQryTGY)->TGY_ENTRA4,(cQryTGY)->TGY_SAIDA4 }})
		Endif
		(cQryTGY)->(DbCloseArea())
	 Endif
		
	While (cAliasQry)->(!Eof())
		If (cAliasQry)->TGW_STATUS $ "1|2"
			If (cAliasQry)->(TGW_DIASEM) == cDiaSem
				nX++
			Else
				nX := 1
			Endif
			cHrIni := TecConvHr((cAliasQry)->(TGW_HORINI))
			cHrFim := TecConvHr((cAliasQry)->(TGW_HORFIM))
			nHorIniOr := (cAliasQry)->(TGW_HORINI)
			nHorFimOr := (cAliasQry)->(TGW_HORFIM)

			If lGsGeHor .And. !Empty(aHorFlex) .And. Len(aHorFlex[1,nX]) >= 2
				If !Empty(aHorFlex[NPOS_HRFLEX,nX,NPOS_HRINIFLX]) .And.;
				 	!Empty(aHorFlex[NPOS_HRFLEX,nX,NPOS_HRFIMFLX])
					If cHrIni <> aHorFlex[NPOS_HRFLEX,nX,NPOS_HRINIFLX]
						cHrIni := aHorFlex[NPOS_HRFLEX,nX,NPOS_HRINIFLX]
						nHorIniOr := TecConvHr(aHorFlex[NPOS_HRFLEX,nX,NPOS_HRINIFLX])
					Endif
					If cHrFim <> aHorFlex[NPOS_HRFLEX,nX,NPOS_HRFIMFLX]
						cHrFim := aHorFlex[NPOS_HRFLEX,nX,NPOS_HRFIMFLX]
						nHorFimOr := TecConvHr(aHorFlex[NPOS_HRFLEX,nX,NPOS_HRFIMFLX])
					Endif
				Endif
			Endif
		Endif
		If (cAliasQry)->TGW_STATUS == "3" .And. (nHorIniOr <> 0 .Or. nHorFimOr <> 0)
			If cHrIntIn == "00:00" .And. cHrIntSa == "00:00"
				cHrIntIn := TecConvHr((cAliasQry)->(TGW_HORINI))
				cHrIntSa := TecConvHr((cAliasQry)->(TGW_HORFIM))
			Endif
			cHrFimEx := IntToHora((HoraToInt(cHrFim)+(HoraToInt(cHrIntSa)-HoraToInt(cHrIntIn))))
 			If (cAliasQry)->TGW_COBTIP $ "2|3"
				
				AADD(aMntTXH, { cCodTCU,; 					//[1] TXH_CODTCU
								cCodTFF,;					//[2] Hora inicial original
								cHrFimEx,;  				//[3] Hora final com hora extra
								cHrIni,;					//[4] Hora incial original
								cCodHE,;					//[5] Codigo da Hora extra
								(cAliasQry)->(TDX_SEQTUR),;	//[6] Sequência do turno
								(cAliasQry)->(TGW_DIASEM),;	//[7] Dia da semana
								nHorIniOr,;					//[8] Hora inicial original
								nHorFimOr,; 				//[9] Hora final original
								"",; 						//[10] TXH_MTFIL
								"3",;						//[11] TXH_FERIAD
								cCdPaiTXH,;  				//[12] TXH_CODPAI
								cCodTXH })  				//[13] TXH_CODIGO				
								
				nHorIniOr := 0
				nHorFimOr := 0
				cHrIni := ""
				cHrFim := ""
			Endif
		Endif
		cDiaSem := (cAliasQry)->(TGW_DIASEM)
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Else
	(cAliasQry)->(DbCloseArea())
Endif

Return .T.
