#Include 'Protheus.ch'
#INCLUDE 'FINA686.CH'

Function FINA686A()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author pequim

@since 11/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

    Local oView
    Local oModel := ModelDef()
    Local oStr3:= FWFormStruct(2, 'FL6')
    Local oStr4:= FWFormStruct(2, 'FLV')

    oView := FWFormView():New()

    oView:SetModel(oModel)
    oView:AddField('FORMFL6' , oStr3,'FL6MASTER' )
    oView:AddGrid('FORMFLV' , oStr4,'FLVDETAIL')

    oStr3:RemoveField( 'FL6_EXTRA3' )
    oStr3:RemoveField( 'FL6_EXTRA2' )
    oStr3:RemoveField( 'FL6_EXTRA1' )
    oStr3:RemoveField( 'FL6_ATIVI' )
    oStr3:RemoveField( 'FL6_MOTIVO' )
    oStr3:RemoveField( 'FL6_BKOFAT' )
    oStr3:RemoveField( 'FL6_FPAGTO' )
    oStr3:RemoveField( 'FL6_IDREMA' )
    oStr3:RemoveField( 'FL6_PARTRE' )
    oStr3:RemoveField( 'FL6_INFORM' )
    oStr3:RemoveField( 'FL6_VINFOR' )
    oStr3:RemoveField( 'FL6_CONFER' )
    oStr3:RemoveField( 'FL6_NOMERE' )
    oStr3:RemoveField( 'FL6_IDRESP' )
    oStr3:RemoveField( 'FL6_PARTSO' )
    oStr3:RemoveField( 'FL6_NOMESO' )
    oStr3:RemoveField( 'FL6_IDSOL' )
    oStr3:RemoveField( 'FL6_CREDIT' )
    oStr3:RemoveField( 'FL6_LOCPAS' )
    oStr3:RemoveField( 'FL6_LOCALI' )
    oStr3:RemoveField( 'FL6_MULTA' )
    oStr3:RemoveField( 'FL6_MENTAR' )
    oStr3:RemoveField( 'FL6_MOETAX' )
    oStr3:RemoveField( 'FL6_TARPRO' )
    oStr3:RemoveField( 'FL6_TARACO' )
    oStr3:RemoveField( 'FL6_TAXSER' )
    oStr3:RemoveField( 'FL6_TAXPAX' )
    oStr3:RemoveField( 'FL6_TARPAX' )
    oStr3:RemoveField( 'FL6_TARREF' )
    oStr3:RemoveField( 'FL6_DTRESE' )
    oStr3:RemoveField( 'FL6_ORIRES' )
    oStr3:RemoveField( 'FL6_TOTFEE' )
    oStr3:RemoveField( 'FL6_IDRESE' )
    oStr3:RemoveField( 'FL6_LICENC' )


    oStr4:RemoveField( 'FLV_ITEM' )
    oStr4:RemoveField( 'FLV_VIAGEM' )

    oView:CreateHorizontalBox( 'BOXFORM1', 30)
    oView:CreateHorizontalBox( 'BOXFORM2', 70)

    oView:SetOwnerView('FORMFLV','BOXFORM2')
    oView:SetOwnerView('FORMFL6','BOXFORM1')

    oView:SetViewProperty('FORMFLV' , 'ONLYVIEW' )

    oView:EnableTitleView('FORMFL6' , STR0062 )		//'Conferências realizadas'


Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author pequim

@since 11/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
    Local oModel
    Local oStr1     := FWFormStruct(1,'FL6')
    Local oStr2     := FWFormStruct(1,'FLV')
    Local nIndFLV	:= Iif(FWSIXUtil():ExistIndex('FLV' , '2'), 2,1)

    oModel := MPFormModel():New('FINA686A')
    oModel:addFields('FL6MASTER',,oStr1)
    oModel:addgrid('FLVDETAIL','FL6MASTER',oStr2)

    oModel:SetRelation('FLVDETAIL', { { 'FLV_FILIAL', 'xFilial("FLV")' }, { 'FLV_VIAGEM', 'FL6_VIAGEM' }, { 'FLV_ITEM', 'FL6_ITEM' },{ 'FLV_STATUS', "'1'" } }, FLV->(IndexKey(nIndFLV)) )

Return oModel


