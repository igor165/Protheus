#include "GTPA414.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//------------------------------------------------------------------------------
/* /{Protheus.doc} 
Browse da Comissões de colaboradores  
@type Function
@author jacomo.fernandes
@since 15/12/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Function GTPA414()
Local   oBrowse   := FWLoadBrw('GTPA414')

oBrowse:Activate()

oBrowse:Destroy()

GTPDestroy(oBrowse)

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} BrowseDef
Definições de Browse
@type Function
@author jacomo.fernandes
@since 15/12/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef()
Local   oBrowse   :=  FWMBrowse():New()

oBrowse:SetAlias('G5D')

oBrowse:SetDescription(STR0001)//"Comissões de Agência"

oBrowse:SetFilterDefault("!Empty(G5D_TIPREC)")

oBrowse:SetOnlyFields( {"G5D_CODIGO","G5D_TIPREC","G5D_DTPREC"})

oBrowse:AddLegend("G5D_STATUS == '2' "	, "GREEN"	,STR0016)//"Ativo"
oBrowse:AddLegend("G5D_STATUS <> '2' "	, "RED"		,STR0017)//"Inativo" 

Return oBrowse

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author jacomo.fernandes
@since 15/12/2019
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

    ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.GTPA414' OPERATION 2 ACCESS 0	//'Visualizar'
    ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.GTPA414' OPERATION 3 ACCESS 0	//'Incluir'
    ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.GTPA414' OPERATION 4 ACCESS 0	//'Alterar'
    ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.GTPA414' OPERATION 5 ACCESS 0	//'Excluir'
    ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.GTPA414' OPERATION 8 ACCESS 0	//'Imprimir'

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 15/12/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := Nil
Local oStruG5D  := FWFormStruct(1,'G5D',{|cCampo| (AllTrim(cCampo) $ "G5D_CODIGO,G5D_TIPREC,G5D_DTPREC,G5D_STATUS") })
Local oStruGQ4  := FWFormStruct(1,'GQ4')
Local oStruG5E  := FWFormStruct(1,'G5E')
Local oStruGIH	:= FWFormStruct(1,'GIH')
Local oStruGIU  := FWFormStruct(1,'GIU')

Local bPosVld   := {|oMdl| ModelPosVld(oMdl)}
Local bPosLine  := {|oMdl,nLin| MdlPosLine(oMdl,nLin)}

SetModelStruct(oStruG5D,oStruGQ4,oStruG5E,oStruGIH,oStruGIU)

oModel := MPFormModel():New('GTPA414',/*bPreValid*/, bPosVld, /*bCommit*/)

oModel:AddFields('G5DMASTER',/*cOwner*/  , oStruG5D, /*bPre*/, /*bPosVld*/, /*bLoad*/)
oModel:AddGrid('GQ4DETAIL'  ,'G5DMASTER' , oStruGQ4, /*bPreLine*/, bPosLine, /*bPre*/, /*bPosVld*/, /*bLoad*/)
oModel:AddGrid('G5EDETAIL'  ,'GQ4DETAIL' , oStruG5E, /*bPreLine*/, /*bPosLine*/, /*bPre*/, /*bPosVld*/, /*bLoad*/)
oModel:AddGrid('GIHDETAIL'  ,'G5DMASTER' , oStruGIH, /*bPreLine*/, /*bPosLine*/, /*bPre*/, /*bPosVld*/, /*bLoad*/)
oModel:AddGrid('GIUDETAIL'  ,'G5DMASTER' , oStruGIU, /*bPreLine*/, /*bPosLine*/, /*bPre*/, /*bPosVld*/, /*bLoad*/)


oModel:SetRelation( 'GQ4DETAIL', { { 'GQ4_FILIAL', 'xFilial( "GQ4" )' }, { 'GQ4_CODG5D', 'G5D_CODIGO' } }, GQ4->( IndexKey( 1 ) ) )
oModel:SetRelation( 'G5EDETAIL', { { 'G5E_FILIAL', 'xFilial( "G5E" )' }, { 'G5E_CODG5D', 'G5D_CODIGO' }, { 'G5E_CODGQ4', 'GQ4_TPVEND' },{ 'G5E_TPCALC', 'GQ4_TPCALC' }, { 'G5E_ORIGEM', 'GQ4_ORIGEM' }, { 'G5E_STATUS', 'GQ4_STATUS' }  }, G5E->( IndexKey( 1 ) ) )
oModel:SetRelation( 'GIHDETAIL', { { 'GIH_FILIAL', 'xFilial( "GIH" )' }, { 'GIH_CODG5D', 'G5D_CODIGO' } }, GIH->( IndexKey( 1 ) ) )		
oModel:SetRelation( 'GIUDETAIL', { { 'GIU_FILIAL', 'xFilial( "GIU" )' }, { 'GIU_CODG5D', 'G5D_CODIGO' } }, GIU->( IndexKey( 1 ) ) )

oModel:SetPrimaryKey({"G5D_FILIAL","G5D_CODIGO"})

oModel:GetModel( 'GQ4DETAIL' ):SetUniqueLine(  { 'GQ4_TPVEND', 'GQ4_ORIGEM', 'GQ4_TPCALC', 'GQ4_STATUS' } )
oModel:GetModel( 'G5EDETAIL' ):SetUniqueLine( { 'G5E_CODGQC' } )
oModel:GetModel( 'GIHDETAIL' ):SetUniqueLine( { 'GIH_CODGYA' } )
oModel:GetModel( 'GIUDETAIL' ):SetUniqueLine(  { 'GIU_TOMADO', 'GIU_TPCOBR', 'GIU_ACAO' } )

oModel:GetModel( 'GQ4DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'G5EDETAIL' ):SetOptional( .T. )
oModel:GetModel( 'GIHDETAIL' ):SetOptional( .T. )	
oModel:GetModel( 'GIUDETAIL' ):SetOptional( .T. )	


oModel:SetDescription(STR0001) //"Comissões de Colaboradores"
oModel:GetModel( 'G5DMASTER' ):SetDescription(STR0001)//"Comissões de Colaboradores"
oModel:GetModel( 'GQ4DETAIL' ):SetDescription(STR0035)//"Tipos de Venda"
oModel:GetModel( 'G5EDETAIL' ):SetDescription(STR0036)//"Tipos de Linhas"
oModel:GetModel( 'GIHDETAIL' ):SetDescription("Tp.Doc x Comissão")//"Tp.Doc x Comissão"
oModel:GetModel( 'GIUDETAIL' ):SetDescription(STR0037)//"Encomendas"

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelPosVld

@type Static Function
@author jacomo.fernandes
@since 14/01/2020
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function ModelPosVld(oModel)
Local lRet      := .T.
Local oMdlGQ4   := oModel:GetModel( 'GQ4DETAIL' )
Local oMdlG5E   := oModel:GetModel( 'G5EDETAIL' )
Local oMdlGIH   := oModel:GetModel( 'GIHDETAIL' )
Local oMdlGIU   := oModel:GetModel( 'GIUDETAIL' )
Local cMdlId    := oModel:GetId()
Local cMsgErro  := ""
Local cMsgSol   := ""

If oModel:GetOperation() <> MODEL_OPERATION_DELETE
    If (oMdlGQ4:IsEmpty() .or. oMdlGQ4:Length(.T.) == 0);
    .and. (oMdlG5E:IsEmpty() .or. oMdlG5E:Length(.T.) == 0);
    .and. (oMdlGIH:IsEmpty() .or. oMdlGIH:Length(.T.) == 0);
    .and. (oMdlGIU:IsEmpty() .or. oMdlGIU:Length(.T.) == 0);

        lRet     := .F.
        cMsgErro := "Não foi definido nenhuma configuração de comissão"
        cMsgSol  := "Informe pelo menos uma configuração de comissão para continuar"
    Endif
Endif

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,,cMdlId,,"MdlPosLine",cMsgErro,cMsgSol)
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} MdlPosLine

@type Function
@author 
@since 14/01/2020
@version 1.0
@param , character, (Descrição do parâmetro)
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function MdlPosLine(oMdl,nLin)
Local lRet      := .T.
Local oModel    := oMdl:GetModel()
Local cMdlId    := oMdl:GetId()
Local cField    := ""
Local cMsgErro  := ""
Local cMsgSol   := ""

If cMdlId == "GQ4DETAIL"
    If !oMdl:IsDeleted(nLin) .and. oMdl:GetValue('GQ4_TPCALC',nLin) == "2"
        If Empty(oMdl:GetValue('GQ4_COMISS',nLin)) 
            lRet    := .F.
            cField  := 'GQ4_COMISS'
        Elseif Empty(oMdl:GetValue('GQ4_IMPOST',nLin))
            lRet    := .F.
            cField  := 'GQ4_IMPOST'
        Endif

        If !lRet
            cMsgErro  := I18n("Quando o tipo de Calculo for por tipo de venda, o campo #1 se torna obrigatório",{FwX3Titulo(cField)})
            cMsgSol   := "Preencha o valor ou altere o tipo de calculo"
        Endif
    Endif

Endif
If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"MdlPosLine",cMsgErro,cMsgSol)
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct

@type Static Function
@author jacomo.fernandes
@since 15/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStruG5D,oStruGQ4,oStruG5E,oStruGIH,oStruGIU)
Local bFldVld   := {|oMdl,cField,uNewValue,uOldValue| FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bWhen     := {|oMdl,cField,uVal| FieldWhen(oMdl,cField,uVal) }
Local bTrig     := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal) }
Local bInit     := {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue) }


If ValType(oStruG5D) == "O"
    oStruG5D:SetProperty('*'            , MODEL_FIELD_OBRIGAT   , .F. )
    oStruG5D:SetProperty('G5D_CODIGO'   , MODEL_FIELD_OBRIGAT   , .T. )
    oStruG5D:SetProperty('G5D_TIPREC'   , MODEL_FIELD_OBRIGAT   , .T. )
    
    oStruG5D:SetProperty('G5D_CODIGO'   , MODEL_FIELD_WHEN      , bWhen)
    oStruG5D:SetProperty('G5D_TIPREC'   , MODEL_FIELD_WHEN      , bWhen)
    
    oStruG5D:SetProperty('G5D_STATUS'   , MODEL_FIELD_INIT      , bInit )
    
    oStruG5D:SetProperty('G5D_STATUS'   , MODEL_FIELD_VALID     , bFldVld)
    oStruG5D:SetProperty('G5D_TIPREC'   , MODEL_FIELD_VALID     , bFldVld)
   
Endif

If ValType(oStruGQ4) == "O"
    oStruGQ4:AddTrigger("GQ4_TPCALC"    , "GQ4_TPCALC"  ,{||.T.}, bTrig )
    
    oStruGQ4:SetProperty('*'            , MODEL_FIELD_VALID     , {||.T.})
    oStruGQ4:SetProperty('GQ4_COMISS'   , MODEL_FIELD_VALID     , bFldVld)
    oStruGQ4:SetProperty('GQ4_IMPOST'   , MODEL_FIELD_VALID     , bFldVld)
    
    oStruGQ4:SetProperty('GQ4_TPCALC'   , MODEL_FIELD_VALUES    , RetCboxFld('GQ4_TPCALC'))
    
    oStruGQ4:SetProperty('*'            , MODEL_FIELD_OBRIGAT   , .F.)
    oStruGQ4:SetProperty('GQ4_TPCALC'   , MODEL_FIELD_OBRIGAT   , .T.)
    oStruGQ4:SetProperty('GQ4_TPVEND'   , MODEL_FIELD_OBRIGAT   , .T.)
    oStruGQ4:SetProperty('GQ4_STATUS'   , MODEL_FIELD_OBRIGAT   , .T.)
    oStruGQ4:SetProperty('GQ4_ORIGEM'   , MODEL_FIELD_OBRIGAT   , .T.)
    
    oStruGQ4:SetProperty('GQ4_COMISS'   , MODEL_FIELD_WHEN      , bWhen)
    oStruGQ4:SetProperty('GQ4_IMPOST'   , MODEL_FIELD_WHEN      , bWhen)
    
Endif

If ValType(oStruG5E) == "O"
    oStruG5E:SetProperty('*'            , MODEL_FIELD_OBRIGAT   , .F.)
    oStruG5E:SetProperty('G5E_CODGQC'   , MODEL_FIELD_OBRIGAT   , .T.)
    oStruG5E:SetProperty('G5E_COMISS'   , MODEL_FIELD_OBRIGAT   , .T.)
    oStruG5E:SetProperty('G5E_IMPOST'   , MODEL_FIELD_OBRIGAT   , .T.)

    oStruG5E:SetProperty('*'            , MODEL_FIELD_WHEN      , bWhen)
    
    oStruG5E:SetProperty('G5E_COMISS'   , MODEL_FIELD_VALID     , bFldVld)
    oStruG5E:SetProperty('G5E_IMPOST'   , MODEL_FIELD_VALID     , bFldVld)
    
    oStruG5E:AddTrigger("G5E_CODGQC"    , "G5E_CODGQC"          , {||.T.}, bTrig )
Endif


If ValType(oStruGIH) == "O"
    oStruGIH:SetProperty("GIH_DESGYA"   , MODEL_FIELD_INIT      , bInit)
    
    oStruGIH:SetProperty("GIH_COMISS"   , MODEL_FIELD_OBRIGAT   , .F.)
    //oStruGIH:SetProperty("GIH_IMPOST"   , MODEL_FIELD_OBRIGAT   , .T.)
    
    oStruGIH:SetProperty('GIH_CODGYA'   , MODEL_FIELD_VALID     , bFldVld)
    oStruGIH:SetProperty('GIH_COMISS'   , MODEL_FIELD_VALID     , bFldVld)
    oStruGIH:SetProperty('GIH_IMPOST'   , MODEL_FIELD_VALID     , bFldVld)

    oStruGIH:AddTrigger("GIH_CODGYA"    , "GIH_CODGYA"  ,{||.T.}, bTrig )

Endif

If ValType(oStruGIU) == "O"
    oStruGIU:SetProperty('GIU_MSBLQL'   , MODEL_FIELD_INIT      , bInit)
    
    oStruGIU:SetProperty('GIU_COMISS'   , MODEL_FIELD_VALID     , bFldVld )
    oStruGIU:SetProperty('GIU_IMPOST'   , MODEL_FIELD_VALID     , bFldVld )

    oStruGIU:SetProperty("GIU_TOMADO"   , MODEL_FIELD_VALUES    , RetCboxFld("GIU_TOMADO"))
    oStruGIU:SetProperty("GIU_TPCOBR"   , MODEL_FIELD_VALUES    , RetCboxFld("GIU_TPCOBR"))
    oStruGIU:SetProperty("GIU_ACAO"     , MODEL_FIELD_VALUES    , RetCboxFld("GIU_ACAO"  ))
    oStruGIU:SetProperty("GIU_MSBLQL"   , MODEL_FIELD_VALUES    , RetCboxFld("GIU_MSBLQL"))

    oStruGIU:SetProperty('GIU_COMISS'   , MODEL_FIELD_OBRIGAT   , .T.)

Endif

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
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
	Case Empty(uNewValue)
		lRet := .T.
    Case cField == "G5D_TIPREC" .or. cField == "G5D_STATUS"
        If cField == "G5D_TIPREC" .and. !GtpExistCpo('GYK',uNewValue)
            lRet        := .F.
            cMsgErro    := "Registro não encontrado ou se encontra bloqueado"
            cMsgSol     := "Verifique os dados informados"
        
        Endif

        If oMdl:GetValue('G5D_STATUS') == '2' .and. !VldCadUnq(oMdl)
            lRet        := .F.
            cMsgErro    := "Já existe um cadastro ativo para o tipo de recurso"
            cMsgSol     := "Altere o cadastro existente ou mude o tipo de recurso"
        Endif
        
    Case cField == "GIH_CODGYA"
        If !GtpExistCpo('GYA',uNewValue)
            lRet        := .F.
            cMsgErro    := "Registro não encontrado ou se encontra bloqueado"
            cMsgSol     := "Verifique os dados informados"
        Endif
    Case cField == "GIU_COMISS" .or. cField == "GIU_IMPOST";
        .or. cField == "GIH_COMISS" .or. cField == "GIH_IMPOST";
        .or. cField == "G5E_COMISS" .or. cField == "G5E_IMPOST";
        .or. cField == "GQ4_COMISS" .or. cField == "GQ4_IMPOST"

        If uNewValue < 0
            lRet        := .F.
            cMsgErro    := STR0038//"Valor informado não pode ser negativo"
            cMsgSol     := STR0039//"Informe um valor maior que 0"
        ElseIf uNewValue > 100
            lRet        := .F.
            cMsgErro    := STR0040//"Valor informado não pode maior que 100%"
            cMsgSol     := STR0041//"Informe um valor menor que 100%"
        Endif
EndCase


If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldCadUnq

@type Function
@author jacomo.fernandes
@since 14/01/2020
@version 1.0
@param oMdl, Object, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldCadUnq(oMdl)
Local lRet      := .T.
Local cTmpAlias := GetNextAlias()
Local cTpRec    := oMdl:GetValue('G5D_TIPREC')
Local cCodG5D   := oMdl:GetValue('G5D_CODIGO')

BeginSql Alias cTmpAlias
    Select Count(G5D_CODIGO) as QTD
    From %Table:G5D% G5D
    Where
        G5D.G5D_FILIAL = %xFilial:G5D%
        AND G5D.G5D_TIPREC = %Exp:cTpRec%
        AND G5D.G5D_CODIGO <> %Exp:cCodG5D%
        AND G5D.G5D_STATUS = '2'
        AND G5D.%NotDel%
EndSql

lRet := (cTmpAlias)->QTD == 0

(cTmpAlias)->(DbCloseArea())

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldInit
Função responsavel pelo inicializador dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Local uRet		:= uVal
Local oModel	:= oMdl:GetModel()
Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT

Do Case 
	Case cField == "G5D_STATUS"
		uRet := '2'
    Case cField == "GIH_DESGYA"
        If !lInsert
            uRet  := Posicione("GYA",1,xFilial("GYA")+GIH->GIH_CODGYA ,"GYA_DESCRI" )
        Else 
            uRet  := ""
        Endif
    Case cField == "GIU_MSBLQL"
        uRet := "2"
EndCase

Return uRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função responsavel pelo gatilho dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)
Local oModel    := oMdl:GetModel()
Local oMdlG5E   := nil

Do Case
    Case cField == "GQ4_TPCALC"
        oMdlG5E     := oModel:GetModel('G5EDETAIL')

        oMdl:ClearField("GQ4_COMISS")
        oMdl:ClearField("GQ4_IMPOST")
        
        If !oMdlG5E:IsEmpty()
            GTPxClearData(oMdlG5E,.F.,.F.,.F.)
        Endif

    Case cField == "G5E_CODGQC"
        oMdl:SetValue('G5E_GQCDES', Posicione('GQC',1,xFilial('GQC')+uVal,"GQC_DESCRI") )
        
    Case cField == "GIH_CODGYA"
        oMdl:SetValue('GIH_DESGYA', Posicione('GYA',1,xFilial('GYA')+uVal,"GYA_DESCRI") )
EndCase

Return uVal

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldWhen
Função responsavel pelo When dos Campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param uVal, character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldWhen(oMdl,cField,uVal)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetID()
Local nOpc		:= oModel:GetOperation()
Local lTrig		:= FwIsInCallStack('FIELDTRIGGER')
Local lInsert	:= nOpc == MODEL_OPERATION_INSERT

Do Case
	Case lTrig
		lRet := .T.

    Case cField == "G5D_CODIGO"
        lRet := .F.
    Case cField == "G5D_TIPREC"
        lRet := lInsert
    Case cField == "GQ4_COMISS"
        lRet := oMdl:GetValue('GQ4_TPCALC') <> "1"
    Case cField == "GQ4_IMPOST"
        lRet := oMdl:GetValue('GQ4_TPCALC') <> "1"
    Case cMdlId == 'G5EDETAIL'
        lRet := oModel:GetModel('GQ4DETAIL'):GetValue('GQ4_TPCALC') == "1"
EndCase

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} RetCboxFld

@type Static Function
@author jacomo.fernandes
@since 15/12/2019
@version 1.0
@param cField, character, (Descrição do parâmetro)
@return aRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function RetCboxFld(cField)
Local aRet  := {}
Do Case
    Case cField == "GIU_TOMADO"
        //aAdd(aRet,"0="+"Ambos" )//"Ambos"
        aAdd(aRet,"0="+STR0042 )//"Remetente"
        aAdd(aRet,"3="+STR0043 )//"Destinatário"
        
    Case cField == "GIU_TPCOBR"
        //aAdd(aRet,"0="+"Ambos" )//"Ambos"
        aAdd(aRet,"1="+"Dinheiro" )//"Dinheiro"
        aAdd(aRet,"2="+"Cartão" )//"Cartão"
        aAdd(aRet,"3="+STR0045 )//"Faturado"
        
    Case cField == "GIU_ACAO"
        //aAdd(aRet,"0="+"Todos"           )//"Todos"
        aAdd(aRet,"1="+STR0046 )//"Postagem"
        aAdd(aRet,"2="+STR0047 )//"Retirada"
        aAdd(aRet,"3="+STR0048 )//"Recebimento"
        
    Case cField == "GIU_MSBLQL"
        aAdd(aRet,"1="+STR0049 )//"Sim"
        aAdd(aRet,"2="+STR0050 )//"Não"

    Case cField == "GQ4_TPCALC"
        aRet := GtpxCbox("GQ4_TPCALC")
EndCase

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface 

@sample		ViewDef()

@return		oView		Retorna objeto da interface

@author	 SI4503 - Marcio Martins Pereira  
@since	 19/01/2016 
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView         := FWFormView():New()
Local oModel        := FWLoadModel('GTPA414')
Local oStruG5D      := FWFormStruct(2,'G5D',{|cCampo| (AllTrim(cCampo) $ "G5D_CODIGO,G5D_TIPREC,G5D_DTPREC,G5D_STATUS") })
Local oStruGQ4      := FWFormStruct(2,'GQ4')
Local oStruG5E      := FWFormStruct(2,'G5E')
Local oStruGIH      := FWFormStruct(2,'GIH')
Local oStruGIU      := FWFormStruct(2,'GIU')
Local bFldAction    := {|oView| oView:Refresh() }

SetViewStruct(oStruG5D,oStruGQ4,oStruG5E,oStruGIH,oStruGIU)

oView:SetModel(oModel)

oView:AddField('VIEW_G5D' , oStruG5D , 'G5DMASTER' )
oView:AddGrid('VIEW_GQ4'  , oStruGQ4 , 'GQ4DETAIL' )
oView:AddGrid('VIEW_G5E'  , oStruG5E , 'G5EDETAIL' )
oView:AddGrid('VIEW_GIH'  , oStruGIH , 'GIHDETAIL' )
oView:AddGrid('VIEW_GIU'  , oStruGIU , 'GIUDETAIL' )

oView:CreateHorizontalBox( 'CABEC'	  , 20 )//Cabeçalho 
oView:CreateHorizontalBox( 'DETALHE' , 80 )//Detalhes

oView:CreateFolder('PASTAS','DETALHE')

oView:AddSheet('PASTAS','ABABILHETES',STR0051)//"Bilhetes"
oView:CreateVerticalBox( 'BOX_GQ4', 50, , , 'PASTAS', 'ABABILHETES')
oView:CreateVerticalBox( 'BOX_G5E', 50, , , 'PASTAS', 'ABABILHETES')

oView:AddSheet('PASTAS','ABATIPODOC',"Tipos de Documentos")//"Tipos de Documentos"
oView:CreateVerticalBox( 'BOX_GIH', 100, , , 'PASTAS', 'ABATIPODOC')

oView:AddSheet('PASTAS','ABAENCOMENDAS',STR0052)//"Encomendas"
oView:CreateVerticalBox( 'BOX_GIU', 100, , , 'PASTAS', 'ABAENCOMENDAS')

oView:SetOwnerView( 'VIEW_G5D' , 'CABEC'   )//Cabeçalho
oView:SetOwnerView( 'VIEW_GQ4' , 'BOX_GQ4' )//Itens  de Venda
oView:SetOwnerView( 'VIEW_G5E' , 'BOX_G5E' )//Tipos de Linhas
oView:SetOwnerView( 'VIEW_GIH' , 'BOX_GIH' )//Tipo de Documento
oView:SetOwnerView( 'VIEW_GIU' , 'BOX_GIU' )//Tipos de Linhas

oView:EnableTitleView( 'VIEW_GQ4' ,STR0007 )	// 'Tipos de Vendas'
oView:EnableTitleView( 'VIEW_G5E' ,STR0008 )	// 'Tipos de Linha'

oView:AddIncrementField('VIEW_GIU','GIU_SEQUEN')

oView:SetFieldAction('GQ4_TPCALC',bFldAction)
oView:SetFieldAction('G5E_CODGQC',bFldAction)
oView:SetFieldAction('GIH_CODGYA',bFldAction)

Return oView

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetViewStruct

@type Static Function
@author jacomo.fernandes
@since 15/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStruG5D,oStruGQ4,oStruG5E,oStruGIH,oStruGIU)

If ValType(oStruG5D) == "O"
    oStruG5D:SetProperty("G5D_TIPREC",MVC_VIEW_LOOKUP,"GYK")
    
Endif

If ValType(oStruGQ4) == "O"
    oStruGQ4:RemoveField('GQ4_CODG5D')

    oStruGQ4:SetProperty("GQ4_TPCALC",MVC_VIEW_ORDEM,"01")
    oStruGQ4:SetProperty("GQ4_TPVEND",MVC_VIEW_ORDEM,"02")
    oStruGQ4:SetProperty("GQ4_STATUS",MVC_VIEW_ORDEM,"03")
    oStruGQ4:SetProperty("GQ4_ORIGEM",MVC_VIEW_ORDEM,"04")
    oStruGQ4:SetProperty("GQ4_COMISS",MVC_VIEW_ORDEM,"05")
    oStruGQ4:SetProperty("GQ4_IMPOST",MVC_VIEW_ORDEM,"06")

Endif

If ValType(oStruG5E) == "O"
    oStruG5E:RemoveField('G5E_CODG5D')
    oStruG5E:RemoveField('G5E_CODGQ4')
    oStruG5E:RemoveField('G5E_TPCALC')
    oStruG5E:RemoveField('G5E_ORIGEM')
    oStruG5E:RemoveField('G5E_STATUS')
    
    oStruG5E:SetProperty("G5E_CODGQC",MVC_VIEW_LOOKUP,"GQC")
    
    oStruG5E:SetProperty("G5E_GQCDES",MVC_VIEW_CANCHANGE,.F.)
Endif

If ValType(oStruGIH) == "O"
    oStruGIH:RemoveField('GIH_CODG5D')

    oStruGIH:SetProperty("GIH_CODGYA",MVC_VIEW_LOOKUP,"GYA")

    oStruGIH:SetProperty("GIH_DESGYA", MVC_VIEW_CANCHANGE, .F.)
    
Endif

If ValType(oStruGIU) == "O"
    oStruGIU:SetProperty("GIU_TOMADO"   , MVC_VIEW_COMBOBOX, RetCboxFld("GIU_TOMADO"))
    oStruGIU:SetProperty("GIU_TPCOBR"   , MVC_VIEW_COMBOBOX, RetCboxFld("GIU_TPCOBR"))
    oStruGIU:SetProperty("GIU_ACAO"     , MVC_VIEW_COMBOBOX, RetCboxFld("GIU_ACAO"  ))
    oStruGIU:SetProperty("GIU_MSBLQL"   , MVC_VIEW_COMBOBOX, RetCboxFld("GIU_MSBLQL"))
    
Endif

Return 
