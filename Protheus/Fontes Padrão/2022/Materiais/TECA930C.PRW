#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA930C.CH"

Static cCompet := ""
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA930C

@description  Excedentes na Apuração

@author	boiani
@since	17/10/2021
/*/
//------------------------------------------------------------------------------
Function TECA930C(oView)
Local oMdl930
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,STR0001},{.T.,STR0002},;
                  {.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} //"Salvar"#"Cancelar"
Local cValCompet := MV_PAR04
Local cValContrt := MV_PAR01
Default oView := nil

If VALTYPE(oView) == 'O'
    oMdl930 := oView:GetModel()
    If oMdl930:GetOperation() != MODEL_OPERATION_INSERT
        cValContrt := oMdl930:GetValue("TFVMASTER","TFV_CONTRT")
        cValCompet := TecBDt2Cmp(oMdl930:GetValue("TFVMASTER","TFV_DTINI"))
    EndIf
EndIf

DbSelectArea("TFJ")
TFJ->( DbSetOrder( 5 ) )  // TFJ_FILIAL + TFJ_CONTRT + TFJ_CONREV
TFJ->( DbSeek( xFilial("TFJ") + cValContrt + Posicione("CN9",7,xFilial("CN9")+cValContrt+"05","CN9_REVISA") ) )

cCompet := cValCompet

FwExecView( STR0003, "VIEWDEF.TECA930C", MODEL_OPERATION_VIEW,/*oOwner*/, {||.T.}, /*bOk*/, 45, aButtons ) //"Itens Excedentes"

cCompet := ""

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Modelo da interface

@author	boiani
@since	17/10/2021
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel   := Nil
Local oStrTFJ  := FWFormStruct(1,'TFJ', { |x| ALLTRIM(x) $ 'TFJ_CODIGO|TFJ_CONTRT|TFJ_CONREV' })
Local oStrTGT  := FWFormStruct(1,'TGT')

oModel := MPFormModel():New('TECA930C')
oModel:AddFields('TFJMASTER',,oStrTFJ,)

oModel:AddGrid( 'TGTDETAIL', 'TFJMASTER', oStrTGT, /*prelin*/, , Nil, Nil, {|oModel|AtLoadTGT(oModel)})

oModel:SetRelation('TGTDETAIL', {{ 'TGT_FILIAL', 'xFilial("TGT")' }, { 'TGT_CODTFJ', 'TFJ_CODIGO' }}, TGT->(IndexKey(2)) )

oModel:GetModel('TFJMASTER'):SetDescription(STR0004) //"Orçamento de serviços"
oModel:GetModel('TGTDETAIL'):SetDescription(STR0005) //"Custos"

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	boiani
@since	17/10/2021
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := ModelDef() 
Local oStrTFJ  := FWFormStruct(2,'TFJ', {|cCampo| AllTrim(cCampo) $ 'TFJ_CODIGO|TFJ_CONTRT|TFJ_CONREV'})
Local oStrTGT  := FWFormStruct(2,'TGT')
Local oView    := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_TFJ' ,oStrTFJ, 'TFJMASTER')	
oView:AddGrid('VIEW_TGT' ,oStrTGT, 'TGTDETAIL')

oView:CreateHorizontalBox('CIMA',0)
oView:CreateHorizontalBox('MEIO',100)

oStrTGT:RemoveField("TGT_CODIGO")

oView:SetOwnerView('VIEW_TFJ','CIMA' )
oView:SetOwnerView('VIEW_TGT','MEIO')

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} AtLoadTGT
	Bloco de load do grid TGTDETAIL

@author	boiani
@since	17/10/2021
/*/
//-------------------------------------------------------------------
Function AtLoadTGT(oModel)
Local cAliasTGT := GetNextAlias()
Local cCodOrc := TFJ->TFJ_CODIGO
Local cExcedente := "1"
Local oStru   := oModel:GetStruct()
Local aFields := {}
Local aAux := {}
Local aRet := {}
Local nI
Local aAreaX3 := SX3->(GetArea())
Local cField

BeginSql Alias cAliasTGT
	SELECT * FROM  %table:TGT% TGT
    WHERE TGT.TGT_FILIAL = %xFilial:TGT%
        AND TGT.TGT_CODTFJ = %Exp:cCodOrc%
        AND TGT.TGT_COMPET = %Exp:cCompet%
        AND TGT.TGT_EXCEDT = %Exp:cExcedente%
        AND TGT.%notDel%
EndSql

If (cAliasTGT)->(!Eof())
	aFields := oStru:GetFields()
	nLenFlds := Len(aFields)
	SX3->(DbSetOrder(2))

	While (cAliasTGT)->(!Eof())
        TGT->(DbGoTo((cAliasTGT)->R_E_C_N_O_))
        aAux := Array(nLenFlds)

		For nI := 1 To nLenFlds
            cField := aFields[nI, MODEL_FIELD_IDFIELD]
            aAux[nI] := (cAliasTGT)->&(cField)
            If cField == "TGT_TPITEM"
                If aAux[nI] == 'TFF'
                    aAux[nI] := "RH"
                ElseIf aAux[nI] == 'TFH'
                    aAux[nI] := "MC"
                ElseIf aAux[nI] == 'TFG'
                    aAux[nI] := "MI"
                EndIf
            EndIf
		Next nI

        Aadd(aRet,{(cAliasTGT)->R_E_C_N_O_,aAux})
        (cAliasTGT)->(DbSkip())
    End
EndIf
(cAliasTGT)->(DbCloseArea())
RestArea(aAreaX3)

Return aRet
