#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "GTPA042B.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	jacomo.fernandes
@since		29/07/17
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel    := MPFormModel():New('GTPA042B', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
Local oStruGY6	:= FWFormStruct(1,'GY6')
Local xAux      := {}

xAux := FwStruTrigger( 'GY6_ENTID1', 'GY6_NOMEN1', 'GTPX2Name( M->GY6_ENTID1 )', .F. )
oStruGY6:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'GY6_CAMPO1', 'GY6_TITCP1', ' GTPX3TIT(M->GY6_CAMPO1)', .F. )
oStruGY6:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'GY6_ENTID2', 'GY6_NOMEN2', 'GTPX2Name( M->GY6_ENTID2 )', .F. )
oStruGY6:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'GY6_CAMPO2', 'GY6_TITCP2', 'GTPX3TIT(M->GY6_CAMPO2)', .F. )
oStruGY6:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

oStruGY6:SetProperty( 'GY6_ENTID1',MODEL_FIELD_VALID,{|oMdl,cField,cNewValue,cOldValue|Ga042bVld(oMdl,cField,cNewValue,cOldValue) } )
oStruGY6:SetProperty( 'GY6_ENTID2',MODEL_FIELD_VALID,{|oMdl,cField,cNewValue,cOldValue|Ga042bVld(oMdl,cField,cNewValue,cOldValue) } )

oStruGY6:SetProperty( 'GY6_CAMPO1',MODEL_FIELD_VALID,{|oMdl,cField,cNewValue,cOldValue|Ga042bVld(oMdl,cField,cNewValue,cOldValue) } )
oStruGY6:SetProperty( 'GY6_CAMPO2',MODEL_FIELD_VALID,{|oMdl,cField,cNewValue,cOldValue|Ga042bVld(oMdl,cField,cNewValue,cOldValue) } )

oStruGY6:SetProperty( 'GY6_CONTEU',MODEL_FIELD_VALID,{|oMdl,cField,cNewValue,cOldValue|Ga042bVld(oMdl,cField,cNewValue,cOldValue) } )

oStruGY6:SetProperty('GY6_TIPOFI',MODEL_FIELD_INIT,{||'1'})

oModel:AddFields('GY6MASTER',/*cOwner*/,oStruGY6)
oModel:SetDescription(STR0001)//'Filtros'
oModel:SetPrimaryKey({})

Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	jacomo.fernandes
@since		29/07/17
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA042B')
Local oView		:= FWFormView():New()
Local oStruGY6	:= FWFormStruct(2, 'GY6')
Local aOperad   := NIL

oView:SetModel(oModel)

GTPXRmvFld(oStruGY6,'GY6_SEQ')
GTPXRmvFld(oStruGY6,'GY6_TIPOFI')
GTPXRmvFld(oStruGY6,'GY6_DESCRI')
GTPXRmvFld(oStruGY6,'GY6_CONDIC')
GTPXRmvFld(oStruGY6,'GY6_CONTEU')

aOperad := GTPXCBox('GY6_OPERAD')
If Len(aOperad) > 0
    aDel(aOperad,8)
    aDel(aOperad,7)
    aSize(aOperad,6)
Endif

oStruGY6:SetProperty('GY6_OPERAD',MVC_VIEW_COMBOBOX,aOperad)

oView:AddField('VIEW_GY6' ,oStruGY6,'GY6MASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetDescription(STR0001)//'Filtros'
oView:SetOwnerView('VIEW_GY6','TELA')

Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} Ga042bVld(a,b,c,d,e)
description
@author  author

@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function Ga042bVld(oMdl,cField,cNewValue,cOldValue, lAut)
Local lRet      := .T.
Local oModel    := NIL
Local cErro     := ""
Local cSolucao  := ""
Local cCampo    := ""
Local aCampo    := nil
Local cValue    := ""
Local cPict     := ""
Local cSx3Arq   := ""

Default lAut    := .F.

if !lAut
    oModel    := oMdl:GetModel()
EndIf

If cField == 'GY6_ENTID1' .or. cField == 'GY6_ENTID2' 
    SX2->(DbSetOrder(1))
    If lAut .OR. !Ga042VldEnt(oMdl,cField,cNewValue,2)
        lRet    := .F.
    ElseIf !Empty(cNewValue) .and. oMdl:GetValue('GY6_ENTID1') == oMdl:GetValue('GY6_ENTID2')
        cErro   := STR0002//'Já existe essa entidade selecionada'
        cSolucao:= STR0003//'Selecione outra entidade'
        lRet    := .F.
    Endif
ElseIf cField == 'GY6_CAMPO1' .or. cField == 'GY6_CAMPO2' 
    SX3->(DbSetOrder(2))
    If lAut .OR. !SX3->(DbSeek(cNewValue))
        cErro   := STR0004//'Campo informado não existe'
        cSolucao:= STR0005//'Selecione um campo existente'
        lRet    := .F.
    Else
        
        cSx3Arq := GetSx3Cache(cNewValue,"X3_ARQUIVO")

        If cField == 'GY6_CAMPO1' .and. cSx3Arq <> oMdl:GetValue('GY6_ENTID1') 
            lRet    := .F.
        Elseif cField == 'GY6_CAMPO2' .and. cSx3Arq <> oMdl:GetValue('GY6_ENTID2') 
            lRet    := .F.
        Endif
        If !lRet
            cErro   := STR0006//'Campo informado não é da mesma entidade '
            cSolucao:= STR0007//'Selecione um campo da mesma entidade'
        Endif
    Endif
ElseIf cField == 'GY6_CONTEU'
    if !lAut
        cCampo := oMdl:GetValue('GY6_CAMPO1')
    EndIf
    cValue := AllTrim(cNewValue)
    
    If lAut .OR. oMdl:GetValue('GY6_TIPOFI') == '1'
        If !Empty(cValue)
            aCampo := TamSx3(cCampo)
            If aCampo[3] == "C"
                If Len(cValue) > aCampo[1] 
                    lRet := .F.
                Endif
            Elseif aCampo[3] == "N"
                If cValue == "0"
                    lRet := .T.
                ElseIf Val(cValue) == 0
                    lRet := .F.
                ElseIf Len(cValue) > aCampo[1] 
                    lRet := .F.
                Endif
                If lRet 
                    cPict := PesqPict(oMdl:GetValue('GY6_ENTID1'),cCampo)
                    If !Empty(cPict)
                        cNewValue := Transform(Val(cValue),cPict,aCampo[1],aCampo[2])
                    Endif
                
                Endif
            Elseif aCampo[3] == "D"
                If Len(cValue) <> 8 .and. Len(cValue) <> 10
                    lRet := .F.
                ElseIf Len(cValue) == 8 .or. Len(cValue) == 10
                    If At("/",cValue) == 0
                        If lRet := ValType(StoD(cValue)) <> "U" .and. StoD(cValue) <> StoD('')
                            cNewValue := DtoC(StoD(cValue))
                        Endif
                    Else
                        If lRet := ValType(CtoD(cValue)) <> "U" .and. CtoD(cValue) <> CtoD('')
                            cNewValue := DtoC(CtoD(cValue))
                        Endif
                    Endif
                Endif
            Elseif aCampo[3] == "L"
                If Len(cValue) <> 1 .and. Len(cValue) <> 3
                    lRet := .F.
                ElseIf cValue <> ".T."  .and. cValue <> "T" .and.  cValue <> "1" .and.  cValue <> "V"  .and. cValue <> ".F."  .and. cValue <> "F" .and.  cValue <> "0"
                    lRet := .F.
                ElseIf cValue == ".T." .or. cValue == "T" .or. cValue == "1" .or. cValue == "V" 
                    cNewValue := "T"
                ElseIf cValue == ".F." .or. cValue == "F" .or. cValue == "2" .or. cValue == "0"
                    cNewValue := "F"
                Endif
            Endif
        Endif
    ElseIf Empty(cNewValue)
        lRet := .F.
    Endif

    If lRet
        if !lAut
            lRet := oMdl:LoadValue(cField,cNewValue)
        EndIf
    Else
        cErro   := STR0008//'Conteudo do campo invalido'
        cSolucao:= STR0009//'Informe um valor valido para o campo referenciado'
    Endif
Endif

If !lRet .and. !Empty(cErro)
    If !lAut
        oModel:SetErrorMessage(oModel:GetId(),cField,oModel:GetId(),cField,"Ga042bVld",cErro,cSolucao,cNewValue,cOldValue)
    EndIf
Endif

Return lRet
