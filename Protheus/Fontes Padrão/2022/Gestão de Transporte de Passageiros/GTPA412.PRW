#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#include "GTPA412.CH"

//------------------------------------------------------------------------------
/* /{Protheus.doc} 
Browse da Comissões de Agências  
@type Function
@author jacomo.fernandes
@since 15/12/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Function GTPA412()
Local oBrowse   := FWLoadBrw('GTPA412')

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
Local oBrowse   := FWMBrowse():New()

oBrowse:SetAlias('G5D')

oBrowse:SetDescription(STR0001)//"Comissões de Agência"

oBrowse:SetFilterDefault("!Empty(G5D_AGENCI)")

oBrowse:SetOnlyFields( {"G5D_CODIGO","G5D_AGENCI","G5D_DESAGE"})

oBrowse:AddLegend("G5D_STATUS == '2' "  , "GREEN"   ,STR0015)//"Ativo"
oBrowse:AddLegend("G5D_STATUS <> '2' "  , "RED"     ,STR0016)//"Inativo" 

Return oBrowse
//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author jacomo.fernandes
@since 15/01/2020
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

    ADD OPTION aRotina TITLE STR0008	ACTION 'VIEWDEF.GTPA412' OPERATION 2 ACCESS 0//'Visualizar'
    ADD OPTION aRotina TITLE STR0009	ACTION 'VIEWDEF.GTPA412' OPERATION 3 ACCESS 0//'Incluir'
    ADD OPTION aRotina TITLE STR0010    ACTION 'VIEWDEF.GTPA412' OPERATION 4 ACCESS 0//'Alterar'
    ADD OPTION aRotina TITLE STR0011    ACTION 'VIEWDEF.GTPA412' OPERATION 5 ACCESS 0//'Excluir'
    ADD OPTION aRotina TITLE STR0012	ACTION 'VIEWDEF.GTPA412' OPERATION 8 ACCESS 0//'Imprimir'
    ADD OPTION aRotina TITLE STR0080	ACTION 'GTPA412A()'      OPERATION 8 ACCESS 0 //'Copiar Comissão'

Return aRotina
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 15/01/2020
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel   := Nil
Local oStruG5D := FWFormStruct(1,'G5D')
Local oStruGQ4 := FWFormStruct(1,'GQ4')
Local oStruG5E := FWFormStruct(1,'G5E')
Local oStruGIH := FWFormStruct(1,'GIH')
Local oStrG5LB := FWFormStruct(1,'G5L')
Local oStrG5LD := FWFormStruct(1,'G5L')
Local oStruGIU := FWFormStruct(1,'GIU') //Encomendas
Local bPosVld  := {|oMdl| ModelPosVld(oMdl)}
Local bPreLine := {|oModel,nLine,cAction,cField,uValue| MdlPreLine(oModel,nLine,cAction,cField,uValue)}

SetModelStruct(oStruG5D, oStruGQ4, oStruG5E, oStruGIH, oStrG5LB, oStrG5LD, oStruGIU)

oModel := MPFormModel():New('GTPA412',/*bPreValid*/, bPosVld/*bPost*/, /*bCommit*/)

oModel:AddFields('G5DMASTER',/*cOwner*/ ,oStruG5D)
oModel:AddGrid('GQ4DETAIL'  ,'G5DMASTER',oStruGQ4,/*bPreLine*/,/*bPosLine*/ ,/*bPreVld*/,/*bPosVld*/ ,/*bLoad*/)
oModel:AddGrid('G5EDETAIL'  ,'GQ4DETAIL',oStruG5E,/*bPreLine*/,/*bPosLine*/ ,/*bPreVld*/,/*bPosVld*/ ,/*bLoad*/)
oModel:AddGrid('GIHDETAIL'  ,'G5DMASTER',oStruGIH,/*bPreLine*/,/*bPosLine*/ ,/*bPreVld*/,/*bPosVld*/ ,/*bLoad*/)
oModel:AddGrid('G5LBONIF'   ,'G5DMASTER',oStrG5LB,  bPreLine  ,/*bPosLine*/ ,/*bPreVld*/,/*bPosVld*/ ,/*bLoad*/)	
oModel:AddGrid('G5LDESCO'   ,'G5DMASTER',oStrG5LD,  bPreLine  ,/*bPosLine*/ ,/*bPreVld*/,/*bPosVld*/ ,/*bLoad*/)	
oModel:AddGrid('GIUDETAIL'  ,'G5DMASTER',oStruGIU,/*bPreLine*/,/*bPosLine*/ ,/*bPreVld*/,/*bPosVld*/ ,/*bLoad*/)

oModel:SetRelation('GQ4DETAIL', { { 'GQ4_FILIAL', 'xFilial( "GQ4" )' }, { 'GQ4_CODG5D', 'G5D_CODIGO' } }, GQ4->( IndexKey( 1 ) ) )
oModel:SetRelation('G5EDETAIL', { { 'G5E_FILIAL', 'xFilial( "G5E" )' }, { 'G5E_CODG5D', 'G5D_CODIGO' }, { 'G5E_CODGQ4', 'GQ4_TPVEND' },;
                                  { 'G5E_TPCALC', 'GQ4_TPCALC' }, { 'G5E_ORIGEM', 'GQ4_ORIGEM' },{ 'G5E_STATUS', 'GQ4_STATUS' }  }, G5E->( IndexKey( 1 ) ) )
oModel:SetRelation('GIHDETAIL', { { 'GIH_FILIAL', 'xFilial( "GIH" )' }, { 'GIH_CODG5D', 'G5D_CODIGO' } }, GIH->( IndexKey( 1 ) ) )		
oModel:SetRelation('G5LBONIF' , { { 'G5L_FILIAL', 'xFilial( "G5L" )' }, { 'G5L_CODIGO', 'G5D_CODIGO' }, { 'G5L_AGENCI', 'G5D_AGENCI' },{"G5L_BONDES" , "'1'"} }, G5L->( IndexKey( 1 ) ) )
oModel:SetRelation('G5LDESCO' , { { 'G5L_FILIAL', 'xFilial( "G5L" )' }, { 'G5L_CODIGO', 'G5D_CODIGO' }, { 'G5L_AGENCI', 'G5D_AGENCI' },{"G5L_BONDES" , "'2'"} }, G5L->( IndexKey( 1 ) ) )
oModel:SetRelation( 'GIUDETAIL', { { 'GIU_FILIAL', 'xFilial( "GIU" )' }, { 'GIU_CODG5D', 'G5D_CODIGO' } }, GIU->( IndexKey( 1 ) ) )

oModel:SetPrimaryKey({"G5D_FILIAL","G5D_CODIGO"})

oModel:GetModel( 'GQ4DETAIL' ):SetUniqueLine( { 'GQ4_TPVEND','GQ4_ORIGEM', 'GQ4_STATUS' } )
oModel:GetModel( 'G5EDETAIL' ):SetUniqueLine( { 'G5E_CODGQC' } )
oModel:GetModel( 'GIHDETAIL' ):SetUniqueLine( { 'GIH_CODGYA' } )
oModel:GetModel( 'G5LBONIF'  ):SetUniqueLine( { 'G5L_TIPO' } )
oModel:GetModel( 'G5LDESCO'  ):SetUniqueLine( { 'G5L_TIPO' } )
oModel:GetModel( 'GIUDETAIL' ):SetUniqueLine(  { 'GIU_TOMADO', 'GIU_TPCOBR', 'GIU_ACAO' } )

oModel:GetModel( 'GQ4DETAIL' ):SetOptional( .T. )
oModel:GetModel( 'G5EDETAIL' ):SetOptional( .T. )
oModel:GetModel( 'GIHDETAIL' ):SetOptional( .T. )	
oModel:GetModel( 'G5LBONIF'  ):SetOptional( .T. )
oModel:GetModel( 'G5LDESCO'  ):SetOptional( .T. )
oModel:GetModel( 'GIUDETAIL' ):SetOptional( .T. )

oModel:SetDescription(STR0052)//"Comissões de Agência"
oModel:GetModel( 'GQ4DETAIL' ):SetDescription(STR0003) //"Tipos de Vendas Padrão"
oModel:GetModel( 'G5EDETAIL' ):SetDescription(STR0004) //"Comissões de Agência"
oModel:GetModel( 'GIHDETAIL' ):SetDescription(STR0048)//"Tp.Doc x Comissão"
oModel:GetModel( 'G5LBONIF'  ):SetDescription(STR0049)//"Bonificações"
oModel:GetModel( 'G5LDESCO'  ):SetDescription(STR0050)//"Descontos"
oModel:GetModel( 'GIUDETAIL' ):SetDescription(STR0051)//"Encomendas"

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
	oModel:SetErrorMessage(cMdlId,,cMdlId,,"ModelPosVld",cMsgErro,cMsgSol)
Endif

Return lRet

/*/{Protheus.doc} VldPreLine
(long_description)
@type function
@author jacomo.fernandes
@since 25/01/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param nLine, numérico, (Descrição do parâmetro)
@param cAction, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uValue, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function MdlPreLine(oMdl,nLine,cAction,cField,uValue)
Local lRet		:= .T.
Local oModel    := oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local aDataMdl	:= nil
Local cMsgErro  := ""
Local cSolucao  := ""

If cMdlId == "G5LBONIF" .OR. cMdlId == "G5LDESCO"

	If lRet .and. (cAction == "DELETE" .or. cAction == "UNDELETE")
		aDataMdl := oMdl:GetData()
		aDataMdl[nLine][3] := If(cAction == "DELETE",.T.,.F.)
		
        CalcVlrAdc(oMdl)
	Endif

Endif


If !lRet .and. !Empty(cMsgErro)
    oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,'VldPreLine',cMsgErro,cSolucao)
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
Static Function SetModelStruct(oStruG5D, oStruGQ4, oStruG5E, oStruGIH, oStrG5LB, oStrG5LD, oStruGIU)
Local bFldVld := {|oMdl, cField, uNewValue, uOldValue| FieldValid(oMdl, cField, uNewValue, uOldValue)}
Local bWhen   := {|oMdl, cField, uVal| FieldWhen(oMdl, cField, uVal)}
Local bTrig   := {|oMdl, cField, uVal| FieldTrigger(oMdl, cField, uVal)}
Local bInit   := {|oMdl, cField, uVal, nLine, uOldValue| FieldInit(oMdl, cField, uVal, nLine, uOldValue)}

If ValType(oStruG5D) == "O"
    oStruG5D:SetProperty('*'            , MODEL_FIELD_OBRIGAT   , .F. )
    oStruG5D:SetProperty('G5D_CODIGO'   , MODEL_FIELD_OBRIGAT   , .T. )
    oStruG5D:SetProperty('G5D_AGENCI'   , MODEL_FIELD_OBRIGAT   , .T. )
    
    oStruG5D:SetProperty('G5D_CODIGO'   , MODEL_FIELD_WHEN      , bWhen)
    oStruG5D:SetProperty('G5D_AGENCI'   , MODEL_FIELD_WHEN      , bWhen)
    oStruG5D:SetProperty('G5D_GERTIT'   , MODEL_FIELD_WHEN      , bWhen)

    oStruG5D:SetProperty('G5D_AGENCI'   , MODEL_FIELD_VALID     , bFldVld )
    oStruG5D:SetProperty('G5D_STATUS'   , MODEL_FIELD_VALID     , bFldVld )
    
    oStruG5D:SetProperty('G5D_STATUS'   , MODEL_FIELD_INIT      , bInit)
    
    oStruGQ4:AddTrigger("G5D_AGENCI"    , "G5D_AGENCI"  ,{||.T.}, bTrig )
    oStruGQ4:AddTrigger("G5D_RESPON"    , "G5D_RESPON"  ,{||.T.}, bTrig )
    oStruGQ4:AddTrigger("G5D_FORNEC"    , "G5D_FORNEC"  ,{||.T.}, bTrig )
    oStruGQ4:AddTrigger("G5D_LJFORN"    , "G5D_LJFORN"  ,{||.T.}, bTrig )

Endif

If ValType(oStruGQ4) == "O"
    oStruGQ4:AddTrigger("GQ4_TPCALC"    , "GQ4_TPCALC"  ,{||.T.}, bTrig )

    oStruGQ4:SetProperty('*'          	, MODEL_FIELD_VALID   	, {||.T.} )
    oStruGQ4:SetProperty('GQ4_COMISS'   , MODEL_FIELD_VALID     , bFldVld)
    oStruGQ4:SetProperty('GQ4_IMPOST'   , MODEL_FIELD_VALID     , bFldVld)

    oStruGQ4:SetProperty('GQ4_TPCALC'   , MODEL_FIELD_VALUES    , RetCboxFld('GQ4_TPCALC'))

    oStruGQ4:SetProperty('*'	       	, MODEL_FIELD_OBRIGAT 	, .F.)
    oStruGQ4:SetProperty('GQ4_TPCALC'  	, MODEL_FIELD_OBRIGAT 	, .T.)
    oStruGQ4:SetProperty('GQ4_TPVEND'  	, MODEL_FIELD_OBRIGAT 	, .T.)
    oStruGQ4:SetProperty('GQ4_STATUS'   , MODEL_FIELD_OBRIGAT   , .T.)
    oStruGQ4:SetProperty('GQ4_ORIGEM'   , MODEL_FIELD_OBRIGAT   , .T.)

    oStruGQ4:SetProperty('GQ4_COMISS' 	, MODEL_FIELD_WHEN   	, bWhen )
    oStruGQ4:SetProperty('GQ4_IMPOST' 	, MODEL_FIELD_WHEN   	, bWhen )
    
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


If ValType(oStrG5LB) == "O"
    oStrG5LB:SetProperty('G5L_TIPO' 	, MODEL_FIELD_VALID, bFldVld )
    oStrG5LB:SetProperty('G5L_VALOR' 	, MODEL_FIELD_VALID, bFldVld )
    
    oStrG5LB:SetProperty('G5L_BONDES'	, MODEL_FIELD_INIT, bInit )
    oStrG5LB:SetProperty("G5L_DESCTP"	, MODEL_FIELD_INIT, bInit )
    
    oStrG5LB:SetProperty("G5L_TIPO"    , MODEL_FIELD_OBRIGAT   , .T.)
    oStrG5LB:SetProperty("G5L_VALOR"   , MODEL_FIELD_OBRIGAT   , .T.)

    oStrG5LB:AddTrigger("G5L_VALOR"    , "G5L_VALOR"  ,{||.T.}, bTrig )
Endif

If ValType(oStrG5LD) == "O"
    oStrG5LD:SetProperty('G5L_TIPO' 	, MODEL_FIELD_VALID, bFldVld )
    oStrG5LD:SetProperty('G5L_VALOR' 	, MODEL_FIELD_VALID, bFldVld )
    
    oStrG5LD:SetProperty('G5L_BONDES'	, MODEL_FIELD_INIT, bInit )
    oStrG5LD:SetProperty("G5L_DESCTP"	, MODEL_FIELD_INIT, bInit )
    
    oStrG5LB:SetProperty("G5L_TIPO"    , MODEL_FIELD_OBRIGAT   , .T.)
    oStrG5LB:SetProperty("G5L_VALOR"   , MODEL_FIELD_OBRIGAT   , .T.)

    oStrG5LD:AddTrigger("G5L_VALOR"    , "G5L_VALOR"  ,{||.T.}, bTrig )
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

    If oStruGIU:HasField("GIU_MOTORI")
	    oStruGIU:RemoveField("GIU_MOTORI")
    EndIf

    If oStruGIU:HasField("GIU_ITEM")
        oStruGIU:RemoveField("GIU_ITEM")
    EndIf

    If oStruGIU:HasField("GIU_CODREQ")
        oStruGIU:RemoveField("GIU_CODREQ")
    EndIf

    If oStruGIU:HasField("GIU_DESREQ")
        oStruGIU:RemoveField("GIU_DESREQ")
    EndIf

    If oStruGIU:HasField("GIU_DTINIC")
        oStruGIU:RemoveField("GIU_DTINIC")
    EndIf

    If oStruGIU:HasField("GIU_DTFIM")
        oStruGIU:RemoveField("GIU_DTFIM")
    EndIf
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
    Case cField == "G5D_AGENCI" 
        If !GtpExistCpo('GI6',uNewValue)
            lRet        := .F.
            cMsgErro    := "Registro não encontrado ou se encontra bloqueado"
            cMsgSol     := "Verifique os dados informados"
        ElseIf !VldAgenc(oMdl,@cMsgErro,@cMsgSol)
            lRet        := .F.
        ElseIf oMdl:GetValue('G5D_STATUS') == '2' .and. !VldCadUnq(oMdl)
            lRet        := .F.
            cMsgErro    := "Já existe um cadastro ativo para o tipo de recurso"
            cMsgSol     := "Altere o cadastro existente ou mude o tipo de recurso"
        Endif
    Case cField == "G5D_STATUS"
        If uNewValue == '2' .and. !VldCadUnq(oMdl)
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
            cMsgErro    := STR0053//"Valor informado não pode ser negativo"
            cMsgSol     := STR0054//"Informe um valor maior que 0"
        ElseIf uNewValue > 100
            lRet        := .F.
            cMsgErro    := STR0055//"Valor informado não pode maior que 100%"
            cMsgSol     := STR0056//"Informe um valor menor que 100%"
        Endif
    Case cField == "G5L_TIPO"
        If !GtpExistCpo('G5K',uNewValue)
            lRet        := .F.
            cMsgErro    := "Registro não encontrado ou se encontra bloqueado"
            cMsgSol     := "Verifique os dados informados"
        ElseIf oMdl:GetValue("G5L_BONDES") <> Posicione('G5K',1,xFilial('G5K')+uNewValue,"G5K_TIPO") 
            lRet        := .F.
            cMsgErro    := "Código informado não representa a finalidade correspondente"
            cMsgSol     := "Selecione um código correspondente ao tipo de valor"
        Endif

    Case cField == "G5L_VALOR"
        If uNewValue < 0
            lRet        := .F.
            cMsgErro    := STR0053//"Valor informado não pode ser negativo"
            cMsgSol     := STR0054//"Informe um valor maior que 0"
        Endif
EndCase


If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

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
Local aAreaAux  := Nil

Do Case
    Case cField == "G5D_AGENCI"
        DbSelectArea('GI6')
        aAreaAux := GI6->(GetArea())
        If GI6->(DbSeek(xFilial('GI6')+uVal ))
            oMdl:SetValue("G5D_DESAGE",GI6->GI6_DESCRI)
            oMdl:SetValue("G5D_GERTIT",GI6->GI6_TIPO <> '1')
            oMdl:SetValue("G5D_FORNEC",GI6->GI6_FORNEC)
            oMdl:SetValue("G5D_LJFORN",GI6->GI6_LOJA)
        Endif
    Case cField == "G5D_RESPON"
        oMdl:SetValue('G5D_NRESPO',Posicione('GYG',1,xFilial('GYG')+uVal,'GYG_NOME'))

    Case cField == "G5D_FORNEC"
        oMdl:SetValue('G5D_LJFORN','')

    Case cField == "G5D_LJFORN"
        oMdl:SetValue('G5D_DFORNE',Posicione('SA2',1,xFilial('SA2')+oMdl:GetModel('G5D_FORNEC')+uVal,'A2_NOME'))
           
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

    Case cField == "G5L_VALOR"
        CalcVlrAdc(oMdl )
EndCase

GtpDestroy(aAreaAux)
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
    Case cField == "G5D_AGENCI"
        lRet := lInsert
        SetVlrAdic(oMdl:GetModel())
    Case cField == "G5D_GERTIT"
        lRet :=  Posicione('GI6',1,xFilial('GI6')+ oModel:GetModel('G5DMASTER'):GetValue('G5D_AGENCI'),'GI6_TIPO' ) == '2'
    Case cField == "GQ4_COMISS"
        lRet := oMdl:GetValue('GQ4_TPCALC') <> "1"
    Case cField == "GQ4_IMPOST"
        lRet := oMdl:GetValue('GQ4_TPCALC') <> "1"
    Case cMdlId == 'G5EDETAIL'
        lRet := oModel:GetModel('GQ4DETAIL'):GetValue('GQ4_TPCALC') == "1"
EndCase

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

    Case cField == "G5L_BONDES"
        If oMdl:GetId() == 'G5LBONIF'
            uRet := '1'
        Else
            uRet := '2'
        Endif
    Case cField == "G5L_DESCTP"
        If !lInsert 
            uRet := Posicione("G5K",1,xFilial("G5K")+G5L->G5L_TIPO ,"G5K_DESCRI" )
        Else
            uRet := ""
        Endif

EndCase

Return uRet
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
Local cCodGI6   := oMdl:GetValue('G5D_AGENCI')
Local cCodG5D   := oMdl:GetValue('G5D_CODIGO')

BeginSql Alias cTmpAlias
    Select Count(G5D_CODIGO) as QTD
    From %Table:G5D% G5D
    Where
        G5D.G5D_FILIAL = %xFilial:G5D%
        AND G5D.G5D_AGENCI = %Exp:cCodGI6%
        AND G5D.G5D_CODIGO <> %Exp:cCodG5D%
        AND G5D.G5D_STATUS = '2'
        AND G5D.%NotDel%
EndSql

lRet := (cTmpAlias)->QTD == 0

(cTmpAlias)->(DbCloseArea())

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
        //aAdd(aRet,"9="+"Ambos"           )//"Ambos"        
        aAdd(aRet,"0="+STR0057 )//"Remetente"    
        aAdd(aRet,"3="+STR0058 )//"Destinatário" 
        
    Case cField == "GIU_TPCOBR"
        //aAdd(aRet,"0="+"Ambos"           )//"Ambos"   
        aAdd(aRet,"1="+"Dinheiro" )//"Dinheiro"  
        aAdd(aRet,"2="+"Cartão" )//"Cartão"  
        aAdd(aRet,"3="+STR0060 )//"Faturado"
        
    Case cField == "GIU_ACAO"
        //aAdd(aRet,"0="+"Todos"           )//"Todos"        
        aAdd(aRet,"1="+STR0061 )//"Postagem"     
        aAdd(aRet,"2="+STR0062 )//"Retirada"     
        aAdd(aRet,"3="+STR0063 )//"Recebimento"  
        
    Case cField == "GIU_MSBLQL"
        aAdd(aRet,"1="+STR0064 )//"Sim"
        aAdd(aRet,"2="+STR0065 )//"Não"

    Case cField == "GQ4_TPCALC"
        aRet := GtpxCbox("GQ4_TPCALC")
        
EndCase

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface 

@sample		ViewDef()

@return		oView		Retorna objeto da interface

@author	 Wanderley Monteiro da Silva  
@since	 03/07/2015 
@version	P12

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView	        := FWFormView():New()
Local oModel        := FWLoadModel('GTPA412')
Local oStruG5D      := FWFormStruct(2,'G5D')
Local oStruGQ4      := FWFormStruct(2,'GQ4')
Local oStruG5E      := FWFormStruct(2,'G5E')
Local oStruGIH      := FWFormStruct(2,'GIH')
Local oStrG5LB      := FWFormStruct(2,'G5L')
Local oStrG5LD      := FWFormStruct(2,'G5L')
Local oStruGIU      := FWFormStruct(2,'GIU')
Local oStruG5DB     := FWFormStruct(2,'G5D',{|cCampo| ( AllTrim(cCampo) $ "G5D_BONIFI,G5D_DESCON") })
Local bFldAction    := {|oView| oView:Refresh() }

SetViewStruct(oStruG5D,oStruGQ4,oStruG5E,oStruGIH,oStrG5LB,oStrG5LD,oStruG5DB,oStruGIU)

oView:SetModel(oModel)
        
oView:AddField( 'VIEW_G5D'  , oStruG5D , 'G5DMASTER'    )
oView:AddGrid(  'VIEW_GQ4'  , oStruGQ4 , 'GQ4DETAIL'    )
oView:AddGrid(  'VIEW_G5E'  , oStruG5E , 'G5EDETAIL'    )
oView:AddGrid(  'VIEW_GIH'  , oStruGIH , 'GIHDETAIL'    )
oView:AddGrid(  'VIEW_G5LB' , oStrG5LB , 'G5LBONIF'     )
oView:AddGrid(  'VIEW_G5LD' , oStrG5LD , 'G5LDESCO'     )
oView:AddField( 'VIEW_G5DB' , oStruG5DB, 'G5DMASTER'    ) 
oView:AddGrid(  'VIEW_GIU'  , oStruGIU , 'GIUDETAIL'    )

oView:AddIncrementField('VIEW_G5LB','G5L_SEQUEN')
oView:AddIncrementField('VIEW_G5LD','G5L_SEQUEN')
oView:AddIncrementField('VIEW_GIU' ,'GIU_SEQUEN')

oView:CreateHorizontalBox('CABEC' ,40)//Campos do cabeçalho G5D
oView:CreateHorizontalBox('DETALHE' ,60)//Conterá as opções 'tipo de vendas', bonificações e outros.

oView:CreateFolder('PASTAS','DETALHE')

oView:AddSheet('PASTAS','ABABILHETES',STR0066)//"Bilhetes"
oView:CreateVerticalBox( 'BOX_GQ4', 50, , , 'PASTAS', 'ABABILHETES')
oView:CreateVerticalBox( 'BOX_G5E', 50, , , 'PASTAS', 'ABABILHETES')

oView:AddSheet('PASTAS','ABATIPODOC',STR0067)//"Tipos de Documentos"
oView:CreateVerticalBox( 'BOX_GIH', 100, , , 'PASTAS', 'ABATIPODOC')


oView:AddSheet('PASTAS','ABAENCOMENDAS',STR0068)//"Encomendas"
oView:CreateVerticalBox( 'BOX_GIU', 100, , , 'PASTAS', 'ABAENCOMENDAS')

oView:AddSheet('PASTAS','ABAVALADC',STR0069)//"Valores Adicionais"
oView:CreateHorizontalBox('BOX_G5DB', 20, , , 'PASTAS', 'ABAVALADC')
oView:CreateHorizontalBox('BOX_VLRADC', 80, , , 'PASTAS', 'ABAVALADC')

oView:CreateVerticalBox( 'BOX_G5LB', 50,'BOX_VLRADC' , , 'PASTAS', 'ABAVALADC')
oView:CreateVerticalBox( 'BOX_G5LD', 50,'BOX_VLRADC' , , 'PASTAS', 'ABAVALADC')

oView:SetOwnerView('VIEW_G5D' ,'CABEC' )//G5D
oView:SetOwnerView('VIEW_GIH' ,'BOX_GIH' )//Tipo de Documento
oView:SetOwnerView('VIEW_GQ4' ,'BOX_GQ4' )//Tipo de Vendas 
oView:SetOwnerView('VIEW_G5E' ,'BOX_G5E' )//Tipo de Linhas
oView:SetOwnerView('VIEW_GIU' ,'BOX_GIU' )//Grid Encomendas
oView:SetOwnerView('VIEW_G5LB','BOX_G5LB')//Grid Bonificações
oView:SetOwnerView('VIEW_G5LD','BOX_G5LD')//Grid Descontos
oView:SetOwnerView('VIEW_G5DB','BOX_G5DB')//Descontos e Bonificações totalizadores

oView:EnableTitleView('VIEW_GQ4'  ,STR0005)//"Tipos de Vendas"
oView:EnableTitleView('VIEW_G5E'  ,STR0006)//"Categorias"
oView:EnableTitleView('VIEW_G5LB' ,STR0070)//"Bonificações"
oView:EnableTitleView('VIEW_G5LD' ,STR0071)//"Despesas"

oView:SetViewAction( 'DELETELINE'   , bFldAction )
oView:SetViewAction( 'UNDELETELINE' , bFldAction )

oView:SetFieldAction("G5D_AGENCI"   ,bFldAction)
oView:SetFieldAction("G5D_RESPON"   ,bFldAction)
oView:SetFieldAction("G5D_FORNEC"   ,bFldAction)
oView:SetFieldAction("G5D_LJFORN"   ,bFldAction)
oView:SetFieldAction("GQ4_TPCALC"   ,bFldAction)
oView:SetFieldAction("G5E_CODGQC"   ,bFldAction)
oView:SetFieldAction("GIH_CODGYA"   ,bFldAction)
oView:SetFieldAction("G5L_VALOR"    ,bFldAction)

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
Static Function SetViewStruct(oStruG5D,oStruGQ4,oStruG5E,oStruGIH,oStrG5LB,oStrG5LD,oStruG5DB,oStruGIU)

If ValType(oStruG5D) == "O"
    oStruG5D:RemoveField('G5D_GERACI')
    oStruG5D:RemoveField('G5D_TIPREC')
    oStruG5D:RemoveField('G5D_DTPREC')
    oStruG5D:RemoveField('G5D_BONIFI')
    oStruG5D:RemoveField('G5D_DESCON')
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
     
    
Endif

If ValType(oStruGIH) == "O"
    oStruGIH:RemoveField('GIH_CODG5D')

    oStruGIH:SetProperty("GIH_CODGYA",MVC_VIEW_LOOKUP,"GYA")
    
    oStruGIH:SetProperty("GIH_DESGYA", MVC_VIEW_CANCHANGE, .F.)
    
Endif

If ValType(oStrG5LB) == "O"
    oStrG5LB:RemoveField('G5L_CODIGO')
    oStrG5LB:RemoveField('G5L_AGENCI')
    oStrG5LB:RemoveField('G5L_BONDES')
    
    oStrG5LB:SetProperty("G5L_TIPO",MVC_VIEW_LOOKUP,"G5KG5L")
    
    oStrG5LB:SetProperty("G5L_SEQUEN", MVC_VIEW_CANCHANGE, .F.)
    oStrG5LB:SetProperty("G5L_DESCTP", MVC_VIEW_CANCHANGE, .F.)
    
Endif

If ValType(oStrG5LD) == "O"
    oStrG5LD:RemoveField('G5L_CODIGO')
    oStrG5LD:RemoveField('G5L_AGENCI')
    oStrG5LD:RemoveField('G5L_BONDES')

    oStrG5LD:SetProperty("G5L_TIPO",MVC_VIEW_LOOKUP,"G5KG5L")

    oStrG5LD:SetProperty("G5L_SEQUEN", MVC_VIEW_CANCHANGE, .F.)
    oStrG5LD:SetProperty("G5L_DESCTP", MVC_VIEW_CANCHANGE, .F.)

Endif

If ValType(oStruG5DB) == "O"
    oStruG5DB:SetProperty("G5D_DESCON", MVC_VIEW_CANCHANGE, .F.)
    oStruG5DB:SetProperty("G5D_BONIFI", MVC_VIEW_CANCHANGE, .F.)
    
Endif

If ValType(oStruGIU) == "O"
    oStruGIU:SetProperty("GIU_TOMADO"   , MVC_VIEW_COMBOBOX, RetCboxFld("GIU_TOMADO"))
    oStruGIU:SetProperty("GIU_TPCOBR"   , MVC_VIEW_COMBOBOX, RetCboxFld("GIU_TPCOBR"))
    oStruGIU:SetProperty("GIU_ACAO"     , MVC_VIEW_COMBOBOX, RetCboxFld("GIU_ACAO"  ))
    oStruGIU:SetProperty("GIU_MSBLQL"   , MVC_VIEW_COMBOBOX, RetCboxFld("GIU_MSBLQL"))

    If oStruGIU:HasField("GIU_MOTORI")
	    oStruGIU:RemoveField("GIU_MOTORI")
    EndIf

    If oStruGIU:HasField("GIU_ITEM")
        oStruGIU:RemoveField("GIU_ITEM")
    EndIf

    If oStruGIU:HasField("GIU_CODREQ")
        oStruGIU:RemoveField("GIU_CODREQ")
    EndIf

    If oStruGIU:HasField("GIU_DESREQ")
        oStruGIU:RemoveField("GIU_DESREQ")
    EndIf

    If oStruGIU:HasField("GIU_DTINIC")
        oStruGIU:RemoveField("GIU_DTINIC")
    EndIf

    If oStruGIU:HasField("GIU_DTFIM")
        oStruGIU:RemoveField("GIU_DTFIM")
    EndIf
Endif

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} VldAgenc
Valida o código da agência informado e se existe cadastro de comissão ativo.
@type function
@author crisf
@since 23/10/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function VldAgenc(oMdl,cMsgErro,cMsgSol)
Local lRet      := .T.
Local aAreaGI6  := GI6->(GetArea())
Local cCodAgen  := oMdl:GetValue('G5D_AGENCI')

dbSelectArea("GI6")
GI6->(dbSetORder(1))
If GI6->(dbSeek(xFilial('GI6')+cCodAgen))

    
    If GI6->GI6_TIPO == '1' //Se agência for própria
        If GI6->GI6_RECCOM <> '1' //Somente de o responsavel receber comissão poderá ser cadastrada
            lRet        := .F.
            cMsgErro    := STR0074
            cMsgSol     := STR0075
        ElseIf Empty(GI6->GI6_COLRSP) //Precisa ter um colaborador responsavel pela agencia para realizar o cadastro
            lRet        := .F.
            cMsgErro    := "Colaborador responsável não definido na agência"
            cMsgSol     := "Verifique o cadastro da agência"
        Endif

    //Se a agência for terceirizada, verifica se o código do fornecedor esta preenchido
    Elseif  GI6->GI6_TIPO == '2' .AND. (Empty(GI6->GI6_FORNEC) .OR. Empty(GI6->GI6_LOJA)) 
        lRet        := .F.
        cMsgErro    := STR0076
        cMsgSol     := STR0077

    EndIf

EndIf

RestArea(aAreaGI6)
GtpDestroy(aAreaGI6)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CalcVlrAdc
(long_description)
@type function
@author crisf
@since 23/10/2017
@version 1.0
@param oModelGrid, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------
Static Function CalcVlrAdc(oMdl)
Local oModel    := oMdl:GetModel()
Local oMdlG5D   := oModel:GetModel("G5DMASTER")
Local cMdlId    := oMdl:GetId()
Local n1        := 0
Local nTot      := 0

For n1 := 1 To oMdl:Length()
    If !oMdl:IsDeleted(n1)
        nTot += oMdl:GetValue("G5L_VALOR",n1)
    Endif
Next

If cMdlId == "G5LBONIF"
    oMdlG5D:SetValue("G5D_BONIFI",nTot)
Else
    oMdlG5D:SetValue("G5D_DESCON",nTot)
Endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetVlrAdic
(long_description)
@type function
@author flavio.martins
@since 08/09/2021
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------
Static Function SetVlrAdic(oModel)
Local cAgencia := oModel:GetModel('G5DMASTER'):GetValue('G5D_AGENCI')
Local cComFch := ''
Local lSet := .F.

If GI6->(FieldPos('GI6_COMFCH')) > 0
    cComFch := Posicione("GI6",1,xFilial("GI6")+cAgencia,"GI6_COMFCH")
EndIf

If cComFch == '1' //Sim
    lSet := .T.
Endif

oModel:GetModel('G5LBONIF'):SetNoInsertLine(lSet)
oModel:GetModel('G5LDESCO'):SetNoInsertLine(lSet)
oModel:GetModel('G5LBONIF'):SetNoUpdateLine(lSet)
oModel:GetModel('G5LDESCO'):SetNoUpdateLine(lSet)

Return
