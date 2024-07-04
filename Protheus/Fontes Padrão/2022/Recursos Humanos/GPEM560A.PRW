#INCLUDE "RWMAKE.CH"      
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "GPEM560.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} VLMVCRSP
Validaรงรฃo de Modelo da rotina de Cadastro de Fatores de Avaliaรงรฃo (RSPA110)

@author raquel.andrade
@since 05/05/2021
@version P12
/*/
//-------------------------------------------------------------------
Function GPEM560A()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SRL")
oBrowse:SetDescription(OemToAnsi(STR0001+" -"+STR0002)) 
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.GPEM560A' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Manutencao' ACTION 'VIEWDEF.GPEM560A' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.GPEM560A' OPERATION 5 ACCESS 0

Return aRotina



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณModelDef   บAutor  ณDeivys Joenck       บ Data ณ  30/08/22   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao do modelo de dados das informa็๕es complementares บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ModelDef()
Local oModel
Local oStructSRL
Local oStructRCS

    Pergunte("GPM560", .F.)
    oStructSRL := FWFormStruct(1,"SRL",{|cCampo| AllTrim(cCampo)+"|" $ "RL_FILIAL|RL_MAT|RL_CODRET|RL_TIPOFJ|RL_CPFCGC|RL_BENEFIC|RL_CGCFONT|RL_NOMFONT|"})
    oStructRCS := FWFormStruct(1,"RCS")
    oStructRCS:RemoveField( "RCS_MAT" )
    oStructRCS:RemoveField( "RCS_TIPOFJ" )
    oStructRCS:RemoveField( "RCS_CPFBEN" )
    oStructRCS:RemoveField( "RCS_CODRET" )
    oStructRCS:RemoveField( "RCS_ANO" )

    oStructRCS:SetProperty( "RCS_ORIGEM", MODEL_FIELD_INIT, { |oModel| '1' } )
    oStructRCS:SetProperty( "RCS_ORIGEM", MODEL_FIELD_WHEN, { |oModel| .F. } )

    oModel:= MpFormModel():New("GPEM560")
    oModel:AddFields("MASTERSRL", /*cOwner*/, oStructSRL , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
    oModel:SetPrimaryKey( {"RL_FILIAL", "RL_MAT"} )

    oModel:GetModel("MASTERSRL"):SetOnlyView( .T. )
    oModel:GetModel("MASTERSRL"):SetOnlyQuery( .T. )

    oModel:AddGrid("DETAILRCS", "MASTERSRL"/*cOwner*/, oStructRCS, , /* bLinePost*/, /*bPre*/, /*bPost*/,/*bLoad*/)
    oModel:GetModel('DETAILRCS'):SetUniqueLine({'RCS_NOME','RCS_CPFCGC','RCS_VERBA','RCS_TIPORE','RCS_DESCRI','RCS_OUTROS'})

    oModel:SetRelation("DETAILRCS",{;
                                        {"RCS_FILIAL",'xFilial("SRL",SRL->RL_FILIAL)'},;
                                        {"RCS_MAT","RL_MAT"},;
                                        {"RCS_TIPOFJ","RL_TIPOFJ"},;
                                        {"RCS_CPFBEN","RL_CPFCGC"},;
                                        {"RCS_CODRET","RL_CODRET"},;
                                        {'RCS_ANO','Strzero(MV_PAR01, 4)'};
                                    },;
                                    RCS->(IndexKey(1)))

Return(oModel)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewDef   บAutor  ณDeivys Joenck       บ Data ณ  30/08/22   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao da tela para informa็๕es complementares           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ViewDef()
Local oModel	 := ModelDef()
Local oStructSRL := Nil
Local oStructRCS := Nil
Local oView	

oView := FWFormView():New()
oView:SetModel(oModel)

oStructSRL := FWFormStruct(2,"SRL",{|cCampo| AllTrim(cCampo)+"|" $ "RL_FILIAL|RL_MAT|RL_CODRET|RL_TIPOFJ|RL_CPFCGC|RL_BENEFIC|RL_CGCFONT|RL_NOMFONT|"})
oStructRCS := FWFormStruct(2,"RCS")
oStructRCS:RemoveField( "RCS_MAT" )
oStructRCS:RemoveField( "RCS_TIPOFJ" )
oStructRCS:RemoveField( "RCS_CPFBEN" )
oStructRCS:RemoveField( "RCS_CODRET" )
oStructRCS:RemoveField( "RCS_ANO" )
oStructSRL:SetNoFolder()
oStructRCS:SetNoFolder()

oView:createHorizontalBox("FORMFIELD",25)
oView:createHorizontalBox("GRID"     ,75)

oView:AddField("MASTERSRL", oStructSRL)
oView:SetOwnerView( "MASTERSRL","FORMFIELD")
oView:SetViewProperty("MASTERSRL","OnlyView")


oView:AddGrid( "DETAILRCS", oStructRCS )
oView:SetOwnerView( "DETAILRCS","GRID")

oView:SetCloseOnOk({ || .T. }) //retira bota salvar e criar novo

Return(oView)

