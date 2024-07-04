#INCLUDE 'GTPA415.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWBROWSE.CH'

//------------------------------------------------------------------------------  
/*/{Protheus.doc} GTPA415

Cálculo de Comissão por Tipo de Recurso

@sample 	GTPA415()

@author	Flavio Martins
@since	 	27/11/2017 
@version	P12  
@comments  
/*///------------------------------------------------------------------------------

Function GTPA415()
Local oBrowse   as Object
Local lVldDic   as Logical

lVldDic := VldDic()

If lVldDic
    oBrowse := FWLoadBrw('GTPA415')
    
    oBrowse:Activate()
    
    oBrowse:Destroy()

Endif

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
Local oBrowse       :=  FWMBrowse():New()
Local cLegYellow    := "Empty(GQ6_EXPFOL) .AND. Empty(GQ6_SIMULA) .AND. GQ6_VTCOMI <> 0"
Local cLegGreen     := "!Empty(GQ6_EXPFOL) .AND. Empty(GQ6_SIMULA)"
Local cLegBlack     := "GQ6_VTCOMI <= 0"

oBrowse:SetAlias('GQ6')
oBrowse:SetDescription(STR0001) //'Cálculo de Comissão'

oBrowse:AddLegend(cLegYellow ,"YELLOW"	, STR0012) // "Pendente de integração com o RH"
oBrowse:AddLegend(cLegGreen  ,"GREEN"	, STR0013) // "Comissão integrada com o RH")
oBrowse:AddLegend(cLegBlack  ,"BLACK"	, STR0014)  // "Cálculo sem valores de comissão"                                                                                                                                                                                                                                                                                                                                                                                                    

oBrowse:SetOnlyFields( {"GQ6_CODIGO","GQ6_DATADE","GQ6_DATATE","GQ6_TIPREC","GQ6_DTPREC","GQ6_EXPFOL","GQ6_COLDE","GQ6_COLATE"} ) 

oBrowse:SetFilterDefault("GQ6_TPCOMI = '2'")

Return oBrowse
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu
@sample		MenuDef()
@return		aRotina   Array contendo as opções do Menu                                                                                                                          
@author	Flavio Martins
@since	 	27/11/2017 
@version	P12
/*///-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA415' OPERATION 2 ACCESS 0//'Visualizar'
	ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA415' OPERATION 8 ACCESS 0//'Imprimir'
	ADD OPTION aRotina TITLE STR0006    ACTION 'GA415Proc()'     OPERATION 3 ACCESS 0 //'Comissões de Colaboradores'
	ADD OPTION aRotina TITLE STR0018    ACTION 'TP415RH()'       OPERATION 3 ACCESS 0//'Exportação Folha Pgto.'
	ADD OPTION aRotina TITLE STR0007    ACTION 'VIEWDEF.GTPA415' OPERATION 5 ACCESS 0//'Excluir'
	
Return aRotina


//------------------------------------------------------------------------------
/* /{Protheus.doc} VldDic

@type Function
@author jacomo.fernandes
@since 06/01/2020
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldDic()
Local lRet := .T.

If !GTPxVldDic("GQ6",,.F.,.T.);
    .and. GTPxVldDic("GIZ",,.T.,.T.);
    .and. GTPxVldDic("GQ9",,.F.,.T.);
    .and. GTPxVldDic("GQ7",,.F.,.T.);
    .and. GTPxVldDic("GZL",,.F.,.T.);
    .and. GTPxVldDic("GIV",,.T.,.T.);
    .and. GTPxVldDic("GIX",,.T.,.T.)

    FwAlertHelp("Não foi criado o dicionário referente à Encomendas","Atualize seu dicionário para utilizar essa rotina","Atenção!!")
    lRet := .F.
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@sample		ModelDef()
@return		oModel 		Objeto do Model
@author	Flavio Martins
@since	 	27/11/2017 
@version	P12
/*///-------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := NIL
Local oStruGQ6  := FWFormStruct(1,'GQ6') //Cabeçalho
Local oStruGIZ  := FWFormStruct(1,'GIZ') //Colaborador
Local oStruGQ9  := FWFormStruct(1,"GQ9")//Itens de Venda
Local oStruGQ7  := FWFormStruct(1,"GQ7")//Tipos de Linhas
Local oStruGZL	:= FWFormStruct(1,"GZL")//Taxas
Local oStruGIV  := FWFormStruct(1,"GIV")//Soma Encomendas 
Local oStruGIX  := FWFormStruct(1,"GIX")//Comissões x Encomendas
Local oStruGIC  := FwFormModelStruct():New()
Local bLoad		:= {|oMdl| ModelLoad(oMdl) }
Local bCommit	:= {|oMdl| ModelCommit(oMdl) }
Local bVldActiv := {|oModel| GA415VldAct(oModel)}

SetModelStruct(oStruGQ6,oStruGIZ,oStruGQ9,oStruGQ7,oStruGZL,oStruGIV,oStruGIX,oStruGIC)

oModel := MPFormModel():New('GTPA415')

oModel:SetCommit(bCommit)

oModel:AddFields('GQ6MASTER',/*cOwner*/,oStruGQ6)
oModel:AddGrid("GIZDETAIL"  ,"GQ6MASTER", oStruGIZ,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,/*bLoad*/	)//Colaboradores
oModel:AddGrid("GQ9DETAIL"  ,"GIZDETAIL", oStruGQ9,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,/*bLoad*/	)//Tipos de Vendas
oModel:AddGrid("GQ7DETAIL"  ,"GQ9DETAIL", oStruGQ7,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,/*bLoad*/	)//Tipos de Linhas
oModel:AddGrid("GZLDETAIL"  ,"GIZDETAIL", oStruGZL,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,/*bLoad*/	 )//Taxas
oModel:AddGrid("GIVDETAIL"  ,"GIZDETAIL", oStruGIV,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,/*bLoad*/	)//Comissões x Tipos
oModel:AddGrid("GIXDETAIL"  ,"GIZDETAIL", oStruGIX,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,/*bLoad*/	)//Comissões x Encomendas
oModel:AddGrid("GICDETAIL"  ,"GQ6MASTER", oStruGIC,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,bLoad 		)//Comissões x Bilhetes
 

oModel:SetRelation('GIZDETAIL'  ,{{'GIZ_FILIAL','xFilial("GIZ")'},{'GIZ_CODGQ6','GQ6_CODIGO'},{'GIZ_SIMULA','GQ6_SIMULA'}}  ,GIZ->(IndexKey(1)))
oModel:SetRelation('GQ9DETAIL'  ,{{'GQ9_FILIAL','xFilial("GQ9")'},{'GQ9_CODGQ6','GQ6_CODIGO'},{'GQ9_SIMULA','GQ6_SIMULA'},{'GQ9_CODGYG','GIZ_CODGYG'}}  ,GQ9->(IndexKey(1)))
oModel:SetRelation('GQ7DETAIL'  ,{{'GQ7_FILIAL','xFilial("GQ7")'},{'GQ7_CODGQ6','GQ6_CODIGO'},{'GQ7_SIMULA','GQ6_SIMULA'},{'GQ7_CODGYG','GIZ_CODGYG'};
                                                                 ,{'GQ7_TPCALC','GQ9_TPCALC'},{'GQ7_CODTPV','GQ9_CODTPV'};
                                                                 ,{'GQ7_STATUS','GQ9_STATUS'},{'GQ7_ORIGEM','GQ9_ORIGEM'}}  ,GQ7->(IndexKey(1)))
oModel:SetRelation('GZLDETAIL'  ,{{'GZL_FILIAL','xFilial("GZL")'},{'GZL_CODGQ6','GQ6_CODIGO'},{'GZL_SIMULA','GQ6_SIMULA'},{'GZL_CODGYG','GIZ_CODGYG'}}  ,GZL->(IndexKey(1)))
oModel:SetRelation('GIVDETAIL'  ,{{'GIV_FILIAL','xFilial("GIV")'},{'GIV_CODGQ6','GQ6_CODIGO'},{'GIV_SIMULA','GQ6_SIMULA'},{'GIV_CODGYG','GIZ_CODGYG'}}  ,GIV->(IndexKey(1)))
oModel:SetRelation('GIXDETAIL'  ,{{'GIX_FILIAL','xFilial("GIX")'},{'GIX_CODGQ6','GQ6_CODIGO'},{'GIX_SIMULA','GQ6_SIMULA'},{'GIX_CODGYG','GIZ_CODGYG'},{'GIX_SEQUEN','GIV_SEQUEN'}}  ,GIX->(IndexKey(1)))


oModel:GetModel('GQ9DETAIL'):SetOptional( .T. )
oModel:GetModel('GQ7DETAIL'):SetOptional( .T. )
oModel:GetModel('GZLDETAIL'):SetOptional( .T. )
oModel:GetModel('GIVDETAIL'):SetOptional( .T. )
oModel:GetModel('GIXDETAIL'):SetOptional( .T. )
oModel:GetModel('GICDETAIL'):SetOptional( .T. )

oModel:SetPrimaryKey({"GQ6_FILIAL","GQ6_CODIGO"})

oModel:SetDescription(STR0001)	//"Cálculo de Comissão"
oModel:GetModel("GQ6MASTER"):SetDescription(STR0001                 )//"Cálculo de Comissão"
oModel:GetModel("GIZDETAIL"):SetDescription("Colaboradores"         )//"Colaboradores" 
oModel:GetModel("GQ9DETAIL"):SetDescription("Tipos de Vendas"       )//"Tipos de Vendas" 
oModel:GetModel("GQ7DETAIL"):SetDescription("Tipos de Linhas"       )//"Tipos de Linhas" 
oModel:GetModel("GZLDETAIL"):SetDescription("Taxas"                 )//"Taxas" 
oModel:GetModel("GIVDETAIL"):SetDescription("Encomendas"            )//"Encomendas" 
oModel:GetModel("GIXDETAIL"):SetDescription("Comissões x Encomendas")//"Comissões x Encomendas" 
oModel:GetModel("GICDETAIL"):SetDescription("Comissões x Bilhetes"	)//"Comissões x Encomendas" 

oModel:SetVldActivate(bVldActiv)

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct(oStruGQ6,oStruGIZ,oStruGQ9,oStruGQ7,oStruGIV,oStruGIX)

@type Static Function
@author jacomo.fenandes
@since 07/01/2020
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStruGQ6,oStruGIZ,oStruGQ9,oStruGQ7,oStruGZL,oStruGIV,oStruGIX,oStruGIC)

If ValType(oStruGQ6) = "O"
    oStruGQ6:SetProperty('GQ6_CODIGO',MODEL_FIELD_INIT,{|| GtpXeNum('GQ6','GQ6_CODIGO')})
    If oStruGQ6:HasField('GQ6_TPCOMI')
        oStruGQ6:SetProperty('GQ6_TPCOMI',MODEL_FIELD_INIT,{||'2'})
    Endif

Endif

If ValType(oStruGIZ) = "O"
    GTPxCriaCpo(oStruGIZ,{"GYG_NOME"},.T.)
    oStruGIZ:SetProperty("GYG_NOME", MODEL_FIELD_INIT,{|| Posicione('GYG',1,xFilial('GYG')+GIZ->GIZ_CODGYG,'GYG_NOME') })
Endif

If ValType(oStruGQ9) = "O"

Endif

If ValType(oStruGQ7) = "O"
    GTPxCriaCpo(oStruGQ7,{"GQC_DESCRI"},.T.)
    oStruGQ7:SetProperty("GQC_DESCRI", MODEL_FIELD_INIT,{|| Posicione('GQC',1,xFilial('GQC')+GQ7->GQ7_CODGQC,'GQC_DESCRI') })
	oStruGQ7:SetProperty('GQ7_CODTPV'   , MODEL_FIELD_OBRIGAT, .F.)
	oStruGQ7:SetProperty('GQ7_ORIGEM'   , MODEL_FIELD_OBRIGAT, .F.)

Endif


If ValType(oStruGZL) = "O"
    oStruGZL:SetProperty("GZL_DESCRI"	, MODEL_FIELD_INIT,{||IIF(!Empty(GZL->GZL_CODGIH),Posicione("GYA",1,xFilial("GYA")+GZL->GZL_CODGIH ,"GYA_DESCRI" ),"") } )
Endif

If ValType(oStruGIV) == "O"
    If oStruGIV:HasField('GIV_TOMADO')
        oStruGIV:SetProperty('GIV_TOMADO'   ,MODEL_FIELD_VALUES  , RetFldCbox('GIV_TOMADO'))
    Endif
    
    If oStruGIV:HasField('GIV_TPCOBR')
        oStruGIV:SetProperty('GIV_TPCOBR'   ,MODEL_FIELD_VALUES  , RetFldCbox('GIV_TPCOBR'))
    Endif
    
    If oStruGIV:HasField('GIV_ACAO')
        oStruGIV:SetProperty('GIV_ACAO'     ,MODEL_FIELD_VALUES  , RetFldCbox('GIV_ACAO'  ))
    Endif
Endif

If ValType(oStruGIC) = "O"
    GTPxCriaCpo(oStruGIC,{"GIC_CODIGO","GIC_CODGQ6","GIC_PERCOM","GIC_PERIMP","GIC_VALCOM","GIC_VALIMP"},.T.)
	oStruGIC:SetProperty("*",MODEL_FIELD_VALID,{||.T.})
Endif

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} RetFldCbox

@type Static Function
@author jacomo.fernandes
@since 09/01/2020
@version 1.0
@param cField, character, (Descrição do parâmetro)
@return aCbox, return_description
/*/
//------------------------------------------------------------------------------
Static Function RetFldCbox(cField)
Local aCbox     := {}
Do Case
      Case cField == "GIV_TOMADO"
        aAdd(aCbox,"0="+"Remetente"      )//"Remetente"
        aAdd(aCbox,"3="+"Destinatário"   )//"Destinatário"
        
    Case cField == "GIV_TPCOBR"
        aAdd(aCbox,"1="+"Dinheiro"   )//"Dinheiro"
        aAdd(aCbox,"2="+"Cartão"     )//"Cartão"
        aAdd(aCbox,"3="+"Faturado"   )//"Faturado"
        
    Case cField == "GIV_ACAO"
        aAdd(aCbox,"1="+"Postagem"       )//"Postagem"
        aAdd(aCbox,"2="+"Retirada"       )//"Retirada"
        aAdd(aCbox,"3="+"Recebimento"    )//"Recebimento"
        
EndCase

Return aCbox

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelLoad

@type Function
@author jacomo.fernandes
@since 08/01/2020
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function ModelLoad(oMdl)
Local aRet		:= {}
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local nOpc		:= oModel:GetOperation()
Local cAliasTmp	:= ""

If cMdlId == "GICDETAIL" .and. nOpc == MODEL_OPERATION_DELETE
	cAliasTmp := LoadGIC(oModel)
	aRet	:= FwLoadByAlias(oMdl,cAliasTmp)
	(cAliasTmp)->(DbCloseArea())
Endif

Return aRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelCommit

@type Function
@author jacomo.fernandes
@since 08/01/2020
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function LoadGIC(oModel)
Local cAliasTmp := GetNextAlias()
Local oMdlGQ6	:= oModel:GetModel('GQ6MASTER')

BeginSql Alias cAliasTmp
	Select 
		'' AS GIC_CODGQ6,
		0 as GIC_PERCOM,
		0 as GIC_PERIMP,
		0 as GIC_VALCOM,
		0 as GIC_VALIMP,
		GIC.R_E_C_N_O_ 
	From %Table:GIC% GIC
	Where
		GIC.GIC_FILIAL = %xFilial:GIC%
		AND GIC.GIC_CODGQ6 = %Exp:oMdlGQ6:GetValue('GQ6_CODIGO')%
		AND GIC.%NotDel%
	Order by GIC.GIC_FILIAL,GIC.GIC_CODGQ6,GIC.R_E_C_N_O_
EndSql

Return cAliasTmp
//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelCommit

@type Function
@author jacomo.fernandes
@since 08/01/2020
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function ModelCommit(oModel)
Local lRet      := .T.
Local oMdlGQ6   := oModel:GetModel('GQ6MASTER')
Local oMdlGIC   := oModel:GetModel('GICDETAIL')
Local nOpc      := oModel:GetOperation()
Local n1        := 0
Local nRecno    := 0
Local nPerCom   := 0
Local nPerImp   := 0
Local nValCom   := 0
Local nValImp   := 0
Local aNewFlds  := {'GQ6_PERFOL', 'GQ6_VRBCOM', 'GQ6_VRBDSR'}
Local cCodGQ6   := ''
Local cVrbCom   := ''
Local cVrbDSR   := ''
Local cPerFol   := ''

Begin Transaction
    
    If nOpc == MODEL_OPERATION_INSERT;
        .or. nOpc == MODEL_OPERATION_DELETE

        For n1 := 1 To oMdlGIC:Length()
			If !oMdlGIC:IsDeleted(n1)

                nRecno    := oMdlGIC:GetDataId(n1)
                cCodGQ6   := oMdlGIC:GetValue('GIC_CODGQ6',n1)
                nPerCom   := oMdlGIC:GetValue('GIC_PERCOM',n1)
                nPerImp   := oMdlGIC:GetValue('GIC_PERIMP',n1)
                nValCom   := oMdlGIC:GetValue('GIC_VALCOM',n1)
                nValImp   := oMdlGIC:GetValue('GIC_VALIMP',n1)
				AtualizaGIC(nRecno,cCodGQ6,nPerCom,nPerImp,nValCom,nValImp)

            Endif

        Next

        If nOpc == MODEL_OPERATION_DELETE
            cCodGQ6 := oMdlGQ6:GetValue('GQ6_CODIGO')
         
            If  GTPxVldDic('GQ6', aNewFlds, .F., .T.)
                cVrbCom := oMdlGQ6:GetValue('GQ6_VRBCOM')
                cVrbDSR := oMdlGQ6:GetValue('GQ6_VRBDSR')
                cPerFol := oMdlGQ6:GetValue('GQ6_PERFOL')
            Endif

            lRet := DelVrbSRK(cCodGQ6, cVrbCom, cVrbDSR, cPerFol)

        Endif 

    Endif

    If !(lRet)
        DisarmTransaction()
    Else
        FwFormCommit(oModel)    
    Endif

End Transaction

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface 
@sample		ViewDef()
@return		oView		Retorna objeto da interface
@author	Flavio Martins
@since	 	27/11/2017 
@version	P12
/*///-------------------------------------------------------------------
Static Function ViewDef()
Local oView     := FWFormView():New()
Local oModel    := FWLoadModel('GTPA415')

Local oStruGQ6  := FWFormStruct(2,'GQ6') //Cabeçalho
Local oStruGIZ  := FWFormStruct(2,'GIZ') //Colaborador
Local oStruGQ9  := FWFormStruct(2,"GQ9")//Itens de Venda
Local oStruGQ7  := FWFormStruct(2,"GQ7")//Tipos de Linhas
Local oStruGZL  := FWFormStruct(2,"GZL")//Tipos de Linhas
Local oStruGIV  := FWFormStruct(2,"GIV")//Soma Encomendas 

SetViewStruct(oStruGQ6,oStruGIZ,oStruGQ9,oStruGQ7,oStruGZL,oStruGIV)

oView:SetModel(oModel)

oView:AddField( "VIEW_GQ6"   , oStruGQ6  , "GQ6MASTER"   )//Comissões
oView:AddGrid(  "VIEW_GIZ"   , oStruGIZ  , "GIZDETAIL"   )//Colaboradores
oView:AddGrid(  "VIEW_GQ9"   , oStruGQ9  , "GQ9DETAIL"   )//Tp Vendas
oView:AddGrid(  "VIEW_GQ7"   , oStruGQ7  , "GQ7DETAIL"   )//Tipos de Linhas
oView:AddGrid(  "VIEW_GZL"   , oStruGZL  , "GZLDETAIL"   )//Tipos de Linhas
oView:AddGrid(  "VIEW_GIV"   , oStruGIV  , "GIVDETAIL"   )//Encomendas

oView:CreateHorizontalBox('BOX_GQ6'     ,20)
oView:CreateHorizontalBox('BOX_GIZ'     ,30)
oView:CreateHorizontalBox('BOX_DETAIL'  ,50)


oView:CreateFolder("PASTAS","BOX_DETAIL" )
oView:AddSheet("PASTAS","ABAVENDAS"     ,"Bilhetes"   )//"Bilhetes"
oView:AddSheet("PASTAS","ABATAXAS"      ,"Taxas"      )//"Taxas"
oView:AddSheet("PASTAS","ABAENCOMENDAS" ,"Encomendas" )//"Encomendas"


oView:CreateVerticalBox("BOX_GQ9"       ,050,,,"PASTAS","ABAVENDAS"    )
oView:CreateVerticalBox("BOX_GQ7"       ,050,,,"PASTAS","ABAVENDAS"    )
oView:CreateHorizontalBox("BOX_GZL"     ,100,,,"PASTAS","ABATAXAS"     )
oView:CreateHorizontalBox("BOX_GIV"     ,100,,,"PASTAS","ABAENCOMENDAS")

oView:SetOwnerView("VIEW_GQ6","BOX_GQ6")
oView:SetOwnerView("VIEW_GIZ","BOX_GIZ")
oView:SetOwnerView("VIEW_GQ9","BOX_GQ9")
oView:SetOwnerView("VIEW_GQ7","BOX_GQ7")
oView:SetOwnerView("VIEW_GZL","BOX_GZL")
oView:SetOwnerView("VIEW_GIV","BOX_GIV")

oView:EnableTitleView('VIEW_GIZ',"Colaboradores")
oView:EnableTitleView('VIEW_GQ9',"Por tipo de Venda")
oView:EnableTitleView('VIEW_GQ7',"Por tipo de Linha")

Return oView

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetViewStruct(oStruGQ6,oStruGIZ,oStruGQ9,oStruGQ7,oStruGIV)

@type Static Function
@author jacomo.fernandes
@since 07/01/2020
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStruGQ6,oStruGIZ,oStruGQ9,oStruGQ7,oStruGZL,oStruGIV)
Local aFldAux   := {}
Local cFields   := ""
Local nX        := 0

If ValType(oStruGQ6) = "O"
    aFldAux := aClone(oStruGQ6:GetFields())
    cFields := "GQ6_CODIGO|GQ6_TIPREC|GQ6_DTPREC|GQ6_DATADE|GQ6_DATATE|GQ6_COLDE|GQ6_COLATE|GQ6_FORMUL|GQ6_DFORMU|GQ6_EXPFOL"
    For nX := 1 to Len(aFldAux)

        If  !(aFldAux[nX][1] $ cFields) 
            oStruGQ6:RemoveField(aFldAux[nX][1])	
        Endif
            
    Next 

Endif

If ValType(oStruGIZ) = "O" .AND. GTPxVldDic("GIZ",,.T.,.T.)
    GTPxCriaCpo(oStruGIZ,{'GYG_NOME'},.F.)
    
    oStruGIZ:SetProperty("GIZ_CODGYG"   ,MVC_VIEW_ORDEM,'01')
    oStruGIZ:SetProperty("GYG_NOME"     ,MVC_VIEW_ORDEM,'02')
    oStruGIZ:SetProperty("GIZ_VTVEND"   ,MVC_VIEW_ORDEM,'03')
    oStruGIZ:SetProperty("GIZ_VTTAXA"   ,MVC_VIEW_ORDEM,'04')
    oStruGIZ:SetProperty("GIZ_VTENCO"   ,MVC_VIEW_ORDEM,'05')
    oStruGIZ:SetProperty("GIZ_VTCOMI"   ,MVC_VIEW_ORDEM,'06')
    oStruGIZ:SetProperty("GIZ_VTIMPO"   ,MVC_VIEW_ORDEM,'07')

Endif

If ValType(oStruGQ9) = "O"
    oStruGQ9:RemoveField("GQ9_CODGQ6")
    oStruGQ9:RemoveField("GQ9_SIMULA")
    oStruGQ9:RemoveField("GQ9_VCANCE")
    
    oStruGQ9:SetProperty("GQ9_TPCALC"   ,MVC_VIEW_ORDEM,'01')
    oStruGQ9:SetProperty("GQ9_CODTPV"   ,MVC_VIEW_ORDEM,'02')
    oStruGQ9:SetProperty("GQ9_STATUS"   ,MVC_VIEW_ORDEM,'03')
    oStruGQ9:SetProperty("GQ9_ORIGEM"   ,MVC_VIEW_ORDEM,'04')
    oStruGQ9:SetProperty("GQ9_PCOMIS"   ,MVC_VIEW_ORDEM,'05')
    oStruGQ9:SetProperty("GQ9_PIMPOS"   ,MVC_VIEW_ORDEM,'06')
    oStruGQ9:SetProperty("GQ9_VALTOT"   ,MVC_VIEW_ORDEM,'07')
    oStruGQ9:SetProperty("GQ9_VIMPOS"   ,MVC_VIEW_ORDEM,'08')
    oStruGQ9:SetProperty("GQ9_VCOMIS"   ,MVC_VIEW_ORDEM,'09')

    oStruGQ9:SetProperty("GQ9_CODTPV"   ,MVC_VIEW_COMBOBOX,GTPXCBOX('GIC_TIPO'))

Endif

If ValType(oStruGQ7) = "O"
    oStruGQ7:RemoveField("GQ7_CODGQ6")
    oStruGQ7:RemoveField("GQ7_SIMULA")
    oStruGQ7:RemoveField("GQ7_CODTPV")
    oStruGQ7:RemoveField("GQ7_TPCALC")
    oStruGQ7:RemoveField("GQ7_ORIGEM")
    oStruGQ7:RemoveField("GQ7_STATUS")
    oStruGQ7:RemoveField("GQ7_VCANCE")
	
	GTPxCriaCpo(oStruGQ7,{"GQC_DESCRI"},.F.)

    oStruGQ7:SetProperty("GQ7_CODGQC"   ,MVC_VIEW_ORDEM,'01')
    oStruGQ7:SetProperty("GQC_DESCRI"   ,MVC_VIEW_ORDEM,'02')
    oStruGQ7:SetProperty("GQ7_PCOMIS"   ,MVC_VIEW_ORDEM,'03')
    oStruGQ7:SetProperty("GQ7_PIMPOS"   ,MVC_VIEW_ORDEM,'04')
    oStruGQ7:SetProperty("GQ7_VALTOT"   ,MVC_VIEW_ORDEM,'05')
    oStruGQ7:SetProperty("GQ7_VCOMIS"   ,MVC_VIEW_ORDEM,'06')
    oStruGQ7:SetProperty("GQ7_VIMPOS"   ,MVC_VIEW_ORDEM,'07')

Endif

If ValType(oStruGZL) == "O"
    oStruGZL:RemoveField("GZL_CODGQ6")
    oStruGZL:RemoveField("GZL_SIMULA")
    
Endif

If ValType(oStruGIV) == "O"
    If oStruGIV:HasField('GIV_TOMADO')
        oStruGIV:SetProperty('GIV_TOMADO'   ,MVC_VIEW_COMBOBOX  , RetFldCbox('GIV_TOMADO'))
    Endif
    
    If oStruGIV:HasField('GIV_TPCOBR')
        oStruGIV:SetProperty('GIV_TPCOBR'   ,MVC_VIEW_COMBOBOX  , RetFldCbox('GIV_TPCOBR'))
    Endif
    
    If oStruGIV:HasField('GIV_ACAO')
        oStruGIV:SetProperty('GIV_ACAO'     ,MVC_VIEW_COMBOBOX  , RetFldCbox('GIV_ACAO'  ))
    Endif
Endif

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GA415Proc()
Rotina responsável pelo Calculo das comissões de colaboradores
@sample		GA415Proc()
@author	Flavio Martins
@since	 	27/11/2017 
@version	P12
/*///-------------------------------------------------------------------
Function GA415Proc()

Local aArea := GetArea()
Local cPerg := 'GTPA415A'
Local lRet  := .T.

If Pergunte(cPerg,.T.)
    
    FwMsgRun(,{|| lRet := G415ExclGQ6(MV_PAR01) },"Exclusão de simulações","Excluindo simulações..." )

    FwMsgRun(,{|| lRet := lRet .and. G415CalcCom() },"Calculo de comissões","Calculando comissões..." )

    //Realiza o calculo de comissões
    If lRet
        FWExecView("","VIEWDEF.GTPA415",MODEL_OPERATION_VIEW,,{|| .T.})
    Endif
Else
    FWAlertHelp(STR0020, STR0021)//"Rotina cancelada pelo usuário."##"Preencher parametros e clicar no botão OK."		
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} G415CalcCom
Realiza o cálculo da comissão conforme parametros informados
@sample		ModelDef()
@return		oModel 		Objeto do Model
@author	Flavio Martins
@since	 	27/11/2017 
@version	P12
/*///-------------------------------------------------------------------
Static Function G415CalcCom()
Local oModel		:= Nil
Local oMdlGQ6		:= Nil
Local cCodG5D		:= ""
Local cTipRec		:= MV_PAR01
Local cColabDe	    := MV_PAR02
Local cColabAte	    := MV_PAR03
Local cDataDe		:= MV_PAR04
Local cDataAte	    := MV_PAR05
Local cFormula	    := MV_PAR06
Local aFormula	    := {}
Local lRet			:= .T.

If !VldTpRecurs(cTipRec,@cCodG5D)
	lRet := .F.
Endif

//Carrega a formula cadastrada
If lRet .and. !VldFormula(cFormula,aFormula) 
    lRet := .F.
EndIf

If lRet
	oModel		:= FwLoadModel("GTPA415")
	oModel:SetOperation(MODEL_OPERATION_INSERT)

	If oModel:Activate() 
		oMdlGQ6		:= oModel:GetModel('GQ6MASTER')

		oMdlGQ6:SetValue("GQ6_CODG5D"   , cCodG5D   )
		oMdlGQ6:SetValue("GQ6_COLDE"    , cColabDe  )
		oMdlGQ6:SetValue("GQ6_COLATE"   , cColabAte )
		oMdlGQ6:SetValue("GQ6_DATADE"   , cDataDe   )
		oMdlGQ6:SetValue("GQ6_DATATE"   , cDataAte  )
		oMdlGQ6:SetValue("GQ6_TIPREC"   , cTipRec   )
		oMdlGQ6:SetValue("GQ6_FORMUL"   , cFormula  )
		oMdlGQ6:SetValue("GQ6_GERTIT"   , .F.       )
		

		FwMsgRun(,{|| lRet := lRet .and. SetBilhetes(oModel,aFormula) },"Comissões de bilhetes","Calculando comissões de bilhetes..." )
        
        FwMsgRun(,{|| lRet := lRet .and. SetTaxas(oModel,aFormula) },"Comissões de Taxas","Calculando comissões de Taxas..." )

		FwMsgRun(,{|| lRet := lRet .and. SetEncomendas(oModel,aFormula) },"Comissões de Encomendas","Calculando comissões de Encomendas..." )

		If lRet .and. oMdlGQ6:GetValue('GQ6_VTCOMI') > 0

			If !(oModel:VldData() .and. oModel:CommitData())
				JurShowErro( oModel:GetErrormessage() )	
				lRet := .F.
			Endif

		Else
			lRet	:= .F.
			FwAlertHelp("Não houve valores para serem comissionados","Verifique os dados informado","Atenção!!")
		Endif
	Else
		JurShowErro( oModel:GetErrormessage() )	
	Endif

	oModel:DeActivate()
	oModel:Destroy()
Endif
	
Return lRet

/*/{Protheus.doc} SetBilhetes(oModel, aFormula)
Pesquisa e atualiza os bilhetes que compoem o calculo de comissão
@sample		ModelDef()
@return		oModel 		Objeto do Model
@author	Flavio Martins
@since	 	27/11/2017 
@version	P12
/*///-------------------------------------------------------------------
Static Function SetBilhetes(oModel, aFormula)
Local oMdlGQ6		:= oModel:GetModel('GQ6MASTER')
Local oMdlGIZ		:= oModel:GetModel('GIZDETAIL')
Local oMdlGQ9		:= oModel:GetModel('GQ9DETAIL')
Local oMdlGQ7		:= oModel:GetModel('GQ7DETAIL')
Local oMdlGIC		:= oModel:GetModel('GICDETAIL')
Local cCodGQ6		:= oMdlGQ6:GetValue('GQ6_CODIGO')
Local cAliasGIC		:= GetTmpGIC(oMdlGQ6)
Local lQtdBil       := GQ9->(FieldPos('GQ9_QTDBIL')) .And. GQ7->(FieldPos('GQ7_QTDBIL')) 
Local nVlrImpost	:= 0
Local nVlrComiss	:= 0

Local lRet			:= .T.

While (cAliasGIC)->(!Eof())	
	If !Empty(oMdlGIC:GetValue('GIC_CODIGO'))
		oMdlGIC:AddLine()
	Endif
	
	nVlrImpost := Round( ((cAliasGIC)->VALORTOTAL*(cAliasGIC)->IMPOSTO)/100   ,2)
    nVlrComiss := Round( (((cAliasGIC)->VALORTOTAL-nVlrImpost)*(cAliasGIC)->COMISSAO)/100   ,2)

	oMdlGIC:SetDataId((cAliasGIC)->GICRECNO)
    oMdlGIC:SetValue("GIC_CODGQ6",cCodGQ6)
	oMdlGIC:SetValue("GIC_CODIGO",(cAliasGIC)->GIC_CODIGO	)
	oMdlGIC:SetValue("GIC_PERCOM",(cAliasGIC)->COMISSAO		)
	oMdlGIC:SetValue("GIC_PERIMP",(cAliasGIC)->IMPOSTO		)
	oMdlGIC:SetValue("GIC_VALIMP",nVlrImpost)
	oMdlGIC:SetValue("GIC_VALCOM",nVlrComiss)
	

	If !oMdlGIZ:SeekLine({{'GIZ_CODGYG',(cAliasGIC)->GYG_CODIGO}})
		If !Empty(oMdlGIZ:GetValue('GIZ_CODGYG'))
			oMdlGIZ:AddLine()
		Endif
		oMdlGIZ:SetValue('GIZ_CODGYG',(cAliasGIC)->GYG_CODIGO)
	Endif

	If !oMdlGQ9:SeekLine({  {"GQ9_TPCALC",(cAliasGIC)->GQ4_TPCALC},;
							{"GQ9_CODTPV",Padr((cAliasGIC)->GQ4_TPVEND,TamSx3('GQ9_CODTPV')[1])},;
                            {"GQ9_STATUS",(cAliasGIC)->GQ4_STATUS},;
							{"GQ9_ORIGEM",(cAliasGIC)->GQ4_ORIGEM};
						})
		If !Empty(oMdlGQ9:GetValue('GQ9_TPCALC'))
			oMdlGQ9:AddLine()
		Endif
		oMdlGQ9:SetValue('GQ9_TPCALC',(cAliasGIC)->GQ4_TPCALC	)
		oMdlGQ9:SetValue('GQ9_CODTPV',(cAliasGIC)->GQ4_TPVEND	)
		oMdlGQ9:SetValue('GQ9_STATUS',(cAliasGIC)->GQ4_STATUS	)
		oMdlGQ9:SetValue('GQ9_ORIGEM',(cAliasGIC)->GQ4_ORIGEM	)
		If (cAliasGIC)->GQ4_TPCALC == "2" //Por Venda
            oMdlGQ9:SetValue('GQ9_PCOMIS',(cAliasGIC)->COMISSAO     )
            oMdlGQ9:SetValue('GQ9_PIMPOS',(cAliasGIC)->IMPOSTO      )
            If lQtdBil
                oMdlGQ9:SetValue('GQ9_QTDBIL',oMdlGQ9:GetValue('GQ9_QTDBIL')+1  )
            Endif
        Endif
	Endif

	If (cAliasGIC)->GQ4_TPCALC == "1" //Por Tipo de Linha
        If !oMdlGQ7:SeekLine({ {"GQ7_CODGQC",(cAliasGIC)->G5E_CODGQC}}) 
			If !Empty(oMdlGQ7:GetValue("GQ7_CODGQC"))
				oMdlGQ7:AddLine()
			Endif
			oMdlGQ7:SetValue("GQ7_CODGQC",(cAliasGIC)->G5E_CODGQC	)
			oMdlGQ7:SetValue('GQ7_PCOMIS',(cAliasGIC)->COMISSAO     )
			oMdlGQ7:SetValue('GQ7_PIMPOS',(cAliasGIC)->IMPOSTO      )
		Endif

		oMdlGQ7:SetValue('GQ7_VALTOT',oMdlGQ7:GetValue('GQ7_VALTOT')+(cAliasGIC)->VALORTOTAL	)
		oMdlGQ7:SetValue('GQ7_VIMPOS',oMdlGQ7:GetValue('GQ7_VIMPOS')+nVlrImpost					)
		oMdlGQ7:SetValue('GQ7_VCOMIS',oMdlGQ7:GetValue('GQ7_VCOMIS')+nVlrComiss					)
        If lQtdBil
            oMdlGQ7:SetValue('GQ7_QTDBIL',oMdlGQ7:GetValue('GQ7_QTDBIL')+1  )
        Endif
	Else//Por Tipo de Venda
		oMdlGQ9:SetValue('GQ9_VALTOT',oMdlGQ9:GetValue('GQ9_VALTOT')+(cAliasGIC)->VALORTOTAL	)
        oMdlGQ9:SetValue('GQ9_VIMPOS',oMdlGQ9:GetValue('GQ9_VIMPOS')+nVlrImpost					)
        oMdlGQ9:SetValue('GQ9_VCOMIS',oMdlGQ9:GetValue('GQ9_VCOMIS')+nVlrComiss					)
	Endif

	oMdlGIZ:SetValue('GIZ_VTVEND',oMdlGIZ:GetValue('GIZ_VTVEND')+(cAliasGIC)->VALORTOTAL 	)
	oMdlGIZ:SetValue('GIZ_VTIMPO',oMdlGIZ:GetValue('GIZ_VTIMPO')+nVlrImpost					)
	oMdlGIZ:SetValue('GIZ_VTCOMI',oMdlGIZ:GetValue('GIZ_VTCOMI')+nVlrComiss					)
	

	oMdlGQ6:SetValue("GQ6_VTVEND",oMdlGQ6:GetValue("GQ6_VTVEND")+(cAliasGIC)->VALORTOTAL	)
	oMdlGQ6:SetValue("GQ6_VTIMPO",oMdlGQ6:GetValue("GQ6_VTIMPO")+nVlrImpost					)
	oMdlGQ6:SetValue("GQ6_VTCOMI",oMdlGQ6:GetValue("GQ6_VTCOMI")+nVlrComiss					)
	
	(cAliasGIC)->(dbSkip())
	If oModel:HasErrorMessage()
		lRet := .F.
		Exit
	Endif
EndDo	
		
(cAliasGIC)->(DbCloseArea())


Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetTmpGIC

@type Static Function
@author jacomo.fernandes
@since 08/01/2020
@version 1.0
@param oMdlGQ6, object, (Descrição do parâmetro)
@return cTmpAlias, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GetTmpGIC(oMdlGQ6)
Local cAliasTmp	:= GetNextAlias()
Local cCodG5D	:= oMdlGQ6:GetValue("GQ6_CODG5D")
Local cTpRec	:= oMdlGQ6:GetValue("GQ6_TIPREC")
Local cColabDe	:= oMdlGQ6:GetValue("GQ6_COLDE")
Local cColabAte	:= oMdlGQ6:GetValue("GQ6_COLATE")
Local dDtIni	:= oMdlGQ6:GetValue("GQ6_DATADE")
Local dDtFim	:= oMdlGQ6:GetValue("GQ6_DATATE")

BeginSql Alias cAliasTmp
	Select 
		GYG.GYG_CODIGO,
		GIC.GIC_CODIGO,
		GQ4.GQ4_TPCALC,
		GQ4.GQ4_TPVEND,
		GQ4.GQ4_STATUS,
		GQ4.GQ4_ORIGEM,
		IsNull(G5E_CODGQC,'') As G5E_CODGQC,
		IsNull(G5E_IMPOST,GQ4_IMPOST) As IMPOSTO,
		IsNull(G5E_COMISS,GQ4_COMISS) As COMISSAO,
		(Case
			When GIC.GIC_VLACER <> 0 
				then (GIC.GIC_VLACER - 
						GIC.GIC_TAX -
						GIC.GIC_PED - 
						GIC.GIC_SGFACU - 
						GIC.GIC_OUTTOT)
			When GIC.GIC_REQTOT <> 0 
				then (GIC.GIC_REQTOT - 
						GIC.GIC_TAX -
						GIC.GIC_PED - 
						GIC.GIC_SGFACU - 
						GIC.GIC_OUTTOT)
			Else GIC.GIC_TAR
		End) As VALORTOTAL,
		GIC.R_E_C_N_O_ GICRECNO
	From %Table:GQ4% GQ4
		INNER JOIN %Table:GYG% GYG ON
			GYG.GYG_FILIAL = %xFilial:GYG%
			AND GYG.GYG_RECCOD = %Exp:cTpRec%
			AND GYG.GYG_CODIGO BETWEEN %Exp:cColabDe% AND %Exp:cColabAte%
			AND GYG.GYG_FUNCIO <> ''
			AND GYG.%NotDel%
		LEFT JOIN %Table:G5E% G5E ON
			G5E.G5E_FILIAL = GQ4.GQ4_FILIAL
			AND G5E.G5E_CODG5D = GQ4.GQ4_CODG5D
			AND G5E.G5E_CODGQ4 = GQ4.GQ4_TPVEND
			AND G5E.G5E_TPCALC = GQ4.GQ4_TPCALC
			AND G5E.G5E_ORIGEM = GQ4.GQ4_ORIGEM
			AND G5E.G5E_STATUS = GQ4.GQ4_STATUS
			AND G5E.%NotDel%
		INNER JOIN %Table:GIC% GIC ON
			GIC.GIC_FILIAL = %xFilial:GIC%
			AND GIC.GIC_DTVEND BETWEEN %Exp:dDtIni% AND %Exp:dDtFim%
			AND GIC.GIC_CONFER = '2'
			AND GIC.GIC_TIPO = GQ4.GQ4_TPVEND
			AND GIC.GIC_STATUS = GQ4.GQ4_STATUS
			AND GIC.GIC_ORIGEM = GQ4.GQ4_ORIGEM
			AND GIC.GIC_COLAB = GYG.GYG_CODIGO
			AND GIC.%NotDel%
			AND GIC.GIC_CODGQ6 = ''
		INNER JOIN %Table:GI2% GI2 ON
			GI2.GI2_FILIAL = GIC.GIC_FILIAL
			AND GI2.GI2_COD = GIC.GIC_LINHA
			AND GI2.GI2_HIST = '2'
			AND GI2.GI2_TIPLIN = (Case GQ4.GQ4_TPCALC
									When '1' Then G5E.G5E_CODGQC
									Else GI2.GI2_TIPLIN
								End)
			AND GI2.%NotDel%
	Where 
		GQ4.GQ4_FILIAL = %xFilial:GQ4%
		AND GQ4_CODG5D = %Exp:cCodG5D%
		AND GQ4.%NotDel%
	Order By GYG.GYG_CODIGO,GQ4.GQ4_TPCALC,GQ4.GQ4_TPVEND,GQ4.GQ4_STATUS,GQ4.GQ4_ORIGEM,G5E_CODGQC,GIC.R_E_C_N_O_

EndSql

Return cAliasTmp

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetTaxas(oModel,aFormula)

@type Static Function
@author jacomo.fernandes
@since 09/01/2020
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function SetTaxas(oModel,aFormula)
Local lRet          := .T.
Local oMdlGQ6       := oModel:GetModel('GQ6MASTER')
Local oMdlGIZ       := oModel:GetModel('GIZDETAIL')
Local oMdlGZL       := oModel:GetModel("GZLDETAIL") //Taxas
Local cAliasG57     := GetTmpG57(oMdlGQ6)

Local nVlrImpost    := 0
Local nVlrComiss    := 0

While (cAliasG57)->(!Eof())
    If !oMdlGIZ:SeekLine({{'GIZ_CODGYG',(cAliasG57)->GYG_CODIGO}})
		If !Empty(oMdlGIZ:GetValue('GIZ_CODGYG'))
			oMdlGIZ:AddLine()
		Endif
		oMdlGIZ:SetValue('GIZ_CODGYG',(cAliasG57)->GYG_CODIGO)
	Endif

    If !oMdlGZL:SeekLine({  {"GZL_CODGIH",(cAliasG57)->GIH_CODGYA}})
		If !Empty(oMdlGZL:GetValue('GZL_CODGIH'))
			oMdlGZL:AddLine()
		Endif
		oMdlGZL:SetValue('GZL_CODGIH',(cAliasG57)->GIH_CODGYA	)
	Endif
    
    nVlrImpost := Round( ((cAliasG57)->VALORTOTAL*(cAliasG57)->GIH_IMPOST)/100   ,2)
    nVlrComiss := Round( (((cAliasG57)->VALORTOTAL-nVlrImpost)*(cAliasG57)->GIH_COMISS)/100   ,2)

    oMdlGZL:SetValue('GZL_PCOMIS',(cAliasG57)->GIH_COMISS )
    oMdlGZL:SetValue('GZL_PIMPOS',(cAliasG57)->GIH_IMPOST )
    oMdlGZL:SetValue('GZL_VLRTOT',(cAliasG57)->VALORTOTAL  )
    oMdlGZL:SetValue('GZL_VLIMPO',nVlrImpost )
    oMdlGZL:SetValue('GZL_VLCOMI',nVlrComiss )

    oMdlGIZ:SetValue('GIZ_VTTAXA',oMdlGIZ:GetValue('GIZ_VTTAXA')+(cAliasG57)->VALORTOTAL 	)
	oMdlGIZ:SetValue('GIZ_VTIMPO',oMdlGIZ:GetValue('GIZ_VTIMPO')+nVlrImpost					)
	oMdlGIZ:SetValue('GIZ_VTCOMI',oMdlGIZ:GetValue('GIZ_VTCOMI')+nVlrComiss					)
	

	oMdlGQ6:SetValue("GQ6_VTTAXA",oMdlGQ6:GetValue("GQ6_VTTAXA")+(cAliasG57)->VALORTOTAL	)
	oMdlGQ6:SetValue("GQ6_VTIMPO",oMdlGQ6:GetValue("GQ6_VTIMPO")+nVlrImpost					)
	oMdlGQ6:SetValue("GQ6_VTCOMI",oMdlGQ6:GetValue("GQ6_VTCOMI")+nVlrComiss					)
	
	(cAliasG57)->(dbSkip())
	If oModel:HasErrorMessage()
		lRet := .F.
		Exit
	Endif

End

(cAliasG57)->(DbCloseArea())

Return lRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} GetTmpG57

@type Static Function
@author jacomo.fernandes
@since 08/01/2020
@version 1.0
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function GetTmpG57(oMdlGQ6)
Local cAliasTmp := GetNextAlias()
Local cCodG5D	:= oMdlGQ6:GetValue("GQ6_CODG5D")
Local cTpRec	:= oMdlGQ6:GetValue("GQ6_TIPREC")
Local cColabDe	:= oMdlGQ6:GetValue("GQ6_COLDE")
Local cColabAte	:= oMdlGQ6:GetValue("GQ6_COLATE")
Local dDtIni	:= oMdlGQ6:GetValue("GQ6_DATADE")
Local dDtFim	:= oMdlGQ6:GetValue("GQ6_DATATE")

BeginSql Alias cAliasTmp
    Select 
        GYG.GYG_CODIGO,
        GIH.GIH_CODGYA,
        GIH.GIH_COMISS,
        GIH.GIH_IMPOST,
        COUNT(G57.G57_NUMMOV) AS QTD,
        SUM(Case 
                When G57.G57_VALACE > 0
                    THEN G57.G57_VALACE
                Else G57.G57_VALOR
            End) AS VALORTOTAL
    From %Table:GIH% GIH
        INNER JOIN %Table:GYG% GYG ON	
            GYG.GYG_FILIAL = %xFilial:GYG%
            AND GYG.GYG_CODIGO BETWEEN %Exp:cColabDe% AND %Exp:cColabAte%
            AND GYG.GYG_RECCOD = %Exp:cTpRec%
            AND GYG.GYG_FUNCIO <> ''
            AND GYG.%NotDel%
        INNER JOIN %Table:G57% G57 ON	
            G57.G57_FILIAL = %xFilial:G57%
            AND G57.G57_TIPO = GIH.GIH_CODGYA
            AND G57.G57_EMISSA BETWEEN %Exp:dDtIni% AND %Exp:dDtFim%
            AND G57.G57_EMISSO = GYG.GYG_CODIGO
            AND G57.G57_CONFER = '2'
            AND G57.%NotDel%
    WHERE
        GIH.GIH_FILIAL = %xFilial:GIH%
        AND GIH.GIH_CODG5D = %Exp:cCodG5D%
        AND GIH.%NotDel%
    GROUP BY 
        GYG.GYG_CODIGO,
        GIH.GIH_CODGYA, 
        GIH.GIH_COMISS, 
        GIH.GIH_IMPOST

EndSql

Return cAliasTmp

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetEncomendas

@type Static Function
@author jacomo.fernandes
@since 02/01/2020
@version 1.0
@param oSay, object, (Descrição do parâmetro)
@param oModel, object, (Descrição do parâmetro)
@param aFormula, array, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function SetEncomendas(oModel,aFormula)
Local lRet       := .T.
Local oMdlGQ6    := oModel:GetModel("GQ6MASTER") //Cabeçalho
Local oMdlGIZ    := oModel:GetModel("GIZDETAIL") //Colaboradores
Local oMdlGIV    := oModel:GetModel("GIVDETAIL") //Soma Encomendas
Local oMdlGIX    := oModel:GetModel("GIXDETAIL") //Comissão x Encomendas
Local cTmpGIU    := GetTmpGIU(oMdlGQ6)

Local nVlrImpost := 0
Local nVlrComiss := 0
Local nQtd       := 0

While (cTmpGIU)->(!Eof())
    
    If !oMdlGIZ:SeekLine({{'GIZ_CODGYG',(cTmpGIU)->GYG_CODIGO}})
		If !Empty(oMdlGIZ:GetValue('GIZ_CODGYG'))
			oMdlGIZ:AddLine()
		Endif
		oMdlGIZ:SetValue('GIZ_CODGYG',(cTmpGIU)->GYG_CODIGO)
	Endif


	If !oMdlGIV:SeekLine({{"GIV_TOMADO",(cTmpGIU)->GIU_TOMADO},{"GIV_TPCOBR",(cTmpGIU)->GIU_TPCOBR},{"GIV_ACAO",(cTmpGIU)->GIU_ACAO}})
		If !Empty(oMdlGIV:GetValue("GIV_TOMADO")) 
			oMdlGIV:AddLine()
		EndIf
		oMdlGIV:SetValue('GIV_SEQUEN'	,StrZero(oMdlGIV:Length(),TamSx3('GIV_SEQUEN')[1]))

		oMdlGIV:SetValue('GIV_TOMADO'	,(cTmpGIU)->GIU_TOMADO	)
		oMdlGIV:SetValue('GIV_TPCOBR'	,(cTmpGIU)->GIU_TPCOBR	)
		oMdlGIV:SetValue('GIV_ACAO'		,(cTmpGIU)->GIU_ACAO	)
		oMdlGIV:SetValue('GIV_PERCOM'	,(cTmpGIU)->GIU_COMISS	)
		oMdlGIV:SetValue('GIV_PERIMP'	,(cTmpGIU)->GIU_IMPOST	)
	Endif

    //Verifica se a encomenda ja existe para contabilizar a quantidade de encomendas
    If !oMdlGIX:SeekLine({{"GIX_CODG99",(cTmpGIU)->G99_CODIGO}},,.F.)
        nQtd := 1
    Else
        nQtd := 0
    Endif

	If !Empty(oMdlGIX:GetValue("GIX_CODG99")) 
		oMdlGIX:AddLine()
	EndIf
		
	nVlrImpost := Round(((cTmpGIU)->GIY_VALOR*(cTmpGIU)->GIU_IMPOST )/100 ,2)
    nVlrComiss := Round((((cTmpGIU)->GIY_VALOR-nVlrImpost)*(cTmpGIU)->GIU_COMISS )/100 ,2)

	oMdlGIX:SetValue('GIX_CODG99'	,(cTmpGIU)->G99_CODIGO  )
	oMdlGIX:SetValue('GIX_CODGIR'	,(cTmpGIU)->GIR_SEQ     )
	oMdlGIX:SetValue('GIX_CODGIY'	,(cTmpGIU)->GIY_IDORIG  )
	oMdlGIX:SetValue('GIX_VLRENC'	,(cTmpGIU)->GIY_VALOR   )
	oMdlGIX:SetValue('GIX_VLRIMP'	,nVlrImpost             )
	oMdlGIX:SetValue('GIX_VLRCOM'	,nVlrComiss             )


	oMdlGIV:SetValue('GIV_VLRENC'	,oMdlGIV:GetValue('GIV_VLRENC')+(cTmpGIU)->GIY_VALOR 	)
	oMdlGIV:SetValue('GIV_VLRIMP'	,oMdlGIV:GetValue('GIV_VLRIMP')+nVlrImpost 				)
	oMdlGIV:SetValue('GIV_VLRCOM'	,oMdlGIV:GetValue('GIV_VLRCOM')+nVlrComiss 				)
	oMdlGIV:SetValue('GIV_QTDENC'	,oMdlGIV:GetValue('GIV_QTDENC')+nQtd					)

    oMdlGIZ:SetValue('GIZ_VTENCO'   ,oMdlGIZ:GetValue('GIZ_VTVEND')+(cTmpGIU)->GIY_VALOR 	)
	oMdlGIZ:SetValue('GIZ_VTIMPO'   ,oMdlGIZ:GetValue('GIZ_VTIMPO')+nVlrImpost				)
	oMdlGIZ:SetValue('GIZ_VTCOMI'   ,oMdlGIZ:GetValue('GIZ_VTCOMI')+nVlrComiss				)

	oMdlGQ6:SetValue('GQ6_VTENCO'	, oMdlGQ6:GetValue('GQ6_VTENCO')+(cTmpGIU)->GIY_VALOR	)
	oMdlGQ6:SetValue('GQ6_VTCOMI'	, oMdlGQ6:GetValue('GQ6_VTCOMI')+nVlrComiss 			)
	oMdlGQ6:SetValue('GQ6_VTIMPO'	, oMdlGQ6:GetValue('GQ6_VTIMPO')+nVlrImpost 			)

    (cTmpGIU)->(DbSkip())
    If oModel:HasErrorMessage()
		lRet := .F.
		Exit
	Endif
End

(cTmpGIU)->(DbCloseArea())



Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetTmpGIU

@type Static Function
@author jacomo.fernandes
@since 02/01/2020
@version 1.0
@param oMdlGQ6, object, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Static Function GetTmpGIU(oMdlGQ6)
Local cTmpGiu   := GetNextAlias()
Local cCodG5D	:= oMdlGQ6:GetValue('GQ6_CODG5D')
Local cTpRec	:= oMdlGQ6:GetValue('GQ6_TIPREC')
Local cColabDe  := oMdlGQ6:GetValue('GQ6_COLDE')
Local cColabAte := oMdlGQ6:GetValue('GQ6_COLATE')


BeginSql Alias cTmpGiu

    Select 
        GYG.GYG_CODIGO,
        GIU.GIU_TOMADO,
        GIU.GIU_TPCOBR,
        GIU.GIU_ACAO,
        GIU.GIU_COMISS,
        GIU.GIU_IMPOST,
        G99.G99_CODIGO,
        GIR.GIR_SEQ,
        GIY.GIY_IDORIG,
        GIY.GIY_VALOR
    From %Table:GIU% GIU
        INNER JOIN %Table:GYG% GYG ON
            GYG.GYG_FILIAL = %xFilial:GYG%
            AND GYG.GYG_CODIGO BETWEEN %Exp:cColabDe% AND %Exp:cColabAte%
            AND GYG.GYG_RECCOD = %Exp:cTpRec%
            AND GYG.GYG_FUNCIO <> %Exp:Space(TamSx3('GYG_FUNCIO')[1])%
            AND GYG.GYG_USR <> %Exp:Space(TamSx3('GYG_USR')[1])%
            AND GYG.%NotDel%
        INNER JOIN %Table:G99% G99 ON
            G99.G99_FILIAL = %xFilial:G99%
            AND G99.G99_STATRA  = '2'
            AND G99.G99_TIPCTE <> '2'
            AND G99.G99_COMPLM <> 'I'
            AND G99.%NotDel%
            AND G99.G99_USUINC = (Case GIU.GIU_ACAO
                                    When '1' then GYG.GYG_USR
                                    Else G99.G99_USUINC
                                End)
            AND G99.G99_USURET = (Case GIU.GIU_ACAO
                                    When '2' then GYG.GYG_USR
                                    Else G99.G99_USURET 
                                End)
            AND G99.G99_STAENC = (Case GIU.GIU_ACAO
                                    When '2' then '5'
                                    Else G99.G99_STAENC
                                End)
        INNER JOIN %Table:GIR% GIR ON
            GIR.GIR_FILIAL = G99.G99_FILIAL
            AND GIR.GIR_CODIGO = G99.G99_CODIGO
            AND GIR.GIR_TOMADO = GIU.GIU_TOMADO
            AND GIR.GIR_TIPPAG = GIU.GIU_TPCOBR
            AND GIR.%NotDel%
        INNER JOIN %Table:GIY% GIY ON
            GIY.GIY_FILIAL = G99.G99_FILIAL
            AND GIY.GIY_CODIGO = G99.G99_CODIGO
            AND GIY.GIY_SEQ = GIR.GIR_SEQ
            AND GIY.%NotDel%
        INNER JOIN %Table:G6X% G6X ON
            G6X.G6X_FILIAL = %xFilial:G6X%
            AND G6X.G6X_AGENCI = (CASE G99.G99_TOMADO 
                                        When '0' then G99.G99_CODEMI 
                                        Else G99.G99_CODREC 
                                END)
            AND G6X.G6X_NUMFCH = G99.G99_NUMFCH
            and G6X.G6X_STATUS NOT IN ('1','5')	//RADU: Ajustado para ficha Reaberta - 25/11/21
            AND G6X.%NotDel%
        INNER JOIN %Table:G9Q% G9Q ON
            G9Q.G9Q_FILIAL = G99.G99_FILIAL
            AND G9Q.G9Q_CODIGO = G99.G99_CODIGO
            AND G9Q.%NotDel%
            AND G9Q.G9Q_USUREC = (Case GIU.GIU_ACAO
                                    When '3' then GYG.GYG_USR
                                    Else G9Q.G9Q_USUREC
                                End)
            AND G9Q.G9Q_STAENC = (Case 
                                    When GIU.GIU_ACAO = '3' and G9Q_STAENC in ('3','4') 
                                        then G9Q_STAENC
                                    When GIU.GIU_ACAO = '3' and G9Q_STAENC not in ('3','4') 
                                        then ''
                                    Else G9Q_STAENC
                                End)
        LEFT JOIN (
                Select
                    GIZ.GIZ_CODGYG,
                    GIV.GIV_TOMADO,
                    GIV_ACAO,
                    GIV_TPCOBR,
                    GIX_CODG99,
                    GIX_CODGIR,
                    GIX_CODGIY
                From %Table:GQ6% GQ6
                    INNER JOIN %Table:GIZ% GIZ ON
                        GIZ.GIZ_FILIAL = GQ6.GQ6_FILIAL
                        AND GIZ.GIZ_CODGQ6 = GQ6.GQ6_CODIGO
                        AND GIZ.%NotDel%
                    INNER JOIN %Table:GIV% GIV ON
                        GIV.GIV_FILIAL = GQ6.GQ6_FILIAL
                        AND GIV_CODGQ6 = GQ6.GQ6_CODIGO
                        AND GIV_SIMULA = GQ6.GQ6_SIMULA
                        AND GIV.GIV_CODGYG = GIZ.GIZ_CODGYG
                        AND GIV.%NotDel%
                    INNER JOIN %Table:GIX% GIX ON
                        GIX.GIX_FILIAL = GQ6.GQ6_FILIAL
                        AND GIX.GIX_CODGQ6 = GIV.GIV_CODGQ6
                        AND GIX.GIX_SEQUEN = GIV.GIV_SEQUEN
                        AND GIX.%NotDel%
                Where
                    GQ6.GQ6_FILIAL = %xFilial:GQ6%
                    AND GQ6.GQ6_TIPREC = %Exp:cTpRec%
                    AND GQ6.GQ6_SIMULA = %Exp:Space(TamSx3('GQ6_SIMULA')[1])%
                    AND GQ6.%NotDel%
        ) TMP ON
            TMP.GIV_TOMADO = GIU.GIU_TOMADO
            and TMP.GIV_ACAO = GIU.GIU_ACAO
            AND TMP.GIV_TPCOBR = GIU.GIU_TPCOBR
            AND TMP.GIX_CODG99 = G99.G99_CODIGO
            AND TMP.GIX_CODGIR = GIR.GIR_SEQ
            AND TMP.GIX_CODGIY = GIY.GIY_IDORIG
            AND TMP.GIZ_CODGYG = GYG.GYG_USR

    Where
        GIU_FILIAL = %xFilial:GIU%
        AND GIU_CODG5D = %Exp:cCodG5D%
        AND GIU.GIU_MSBLQL = '2'
        AND GIU.%NotDel%
        AND TMP.GIX_CODGIY IS NULL

EndSql

Return cTmpGiu

//------------------------------------------------------------------------------
/* /{Protheus.doc} G415ExclGQ6
Exclui as comissões que não foram exportadas para a folha de pagamento
@type Function
@author jacomo.fernandes
@since 08/01/2020
@version 1.0
@param cTipRec, character, (Descrição do parâmetro)
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function G415ExclGQ6(cTipRec)
Local oModel    := FwLoadModel('GTPA415')
Local cAliasGQ6 := GetNextAlias()
Local oGtpLog   := GtpLog():New("Exclusão de comissão por Tipo de Recurso")
Local lRet      := .T.

BeginSQL alias cAliasGQ6    

    SELECT 
        GQ6.R_E_C_N_O_ AS GQ6RECNO
    FROM %Table:GQ6% GQ6
    WHERE 
        GQ6_FILIAL	= %xFilial:GQ6%
        AND GQ6_TIPREC = %Exp:cTipRec%
        AND GQ6_EXPFOL = ''
        AND GQ6.%NotDel%		

EndSQL		

(cAliasGQ6)->(DbGoTop())

oModel:SetOperation(MODEL_OPERATION_DELETE)

dbSelectArea('GQ6')

While !(cAliasGQ6)->(Eof())	
    GQ6->(DbGoTo((cAliasGQ6)->GQ6RECNO))

    If oModel:Activate()
        If !(oModel:VldData() .AND. oModel:CommitData() )
            oGtpLog:SetText(GTPGetErrorMsg(oModel))
            lRet := .F.
        Endif
        oModel:DeActivate()
    Endif

    (cAliasGQ6)->(dbSkip())

EndDo

(cAliasGQ6)->(DBCloseArea())	

If !lRet .and. oGtpLog:HasInfo()
    oGtpLog:ShowLog()
Endif

oModel:Destroy()
oGtpLog:Destroy()

GtpDestroy(oModel)
GtpDestroy(oGtpLog)
	
Return lRet
 
//------------------------------------------------------------------------------
/* /{Protheus.doc} AtualizaGIC

@type Static Function
@author jacomo.fernandes
@since 07/01/2020
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function AtualizaGIC(nRecno,cCodGQ6,nPerCom,nPerImp,nValCom,nValImp)
Default nRecno  := 0
Default cCodGQ6 := ""
Default nPerCom := 0
Default nPerImp := 0
Default nValCom := 0
Default nValImp := 0

If nRecno > 0
    GIC->(DbGoTo(nRecno))

    GIC->(RecLock('GIC',.F.))
        GIC->GIC_CODGQ6 := cCodGQ6
        GIC->GIC_PERCOM := nPerCom
        GIC->GIC_PERIMP := nPerImp
        GIC->GIC_VALCOM := nValCom
        GIC->GIC_VALIMP := nValImp
    GIC->(MsUnlock())
Endif

Return 

 //------------------------------------------------------------------- 
/*/{Protheus.doc} TP415RH
Efetua a exportação dos registros de comissão para os lançamentos futuros da folha
@type function
@author Flavio Martins
@since 25/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/ //-------------------------------------------------------------------  
Function TP415RH()
Local cAliasTmp	:= GetNextAlias()
Local lRet			:= .T.
Local cCdComDe	    := ''
Local cCdComAt	    := ''
Local cTpRecDe	    := ''
Local cTpRecAte	    := ''
Local cColabDe	    := ''
Local cColabAte	    := ''
Local cSRVCom 	    := ''
Local cSRVDSR		:= ''
Local aExpFol		:= {}
Local nExpFol		:= 0
Local nGrvFol		:= 0
Local cPerFol       := ''
	
	//Pergunte
 	If Pergunte("GTPA415B",.T.)
	 			
		cCdComDe	:= MV_PAR01
		cCdComAt	:= MV_PAR02
		cTpRecDe	:= MV_PAR03
		cTpRecAte	:= MV_PAR04
		cColabDe	:= MV_PAR05
		cColabAte	:= MV_PAR06
 			
 		cSRVCom	:= AllTrim(GTPGetRules("VRBAGCOMSN"))
 		cSRVDSR	:= AllTrim(GTPGetRules("VRBAGCMDSR"))
		
			
		Begin Transaction 
			
				
		BeginSQL alias cAliasTmp    
			
			SELECT 
				GQ6.GQ6_CODIGO, 
				GYG.GYG_FUNCIO,
				GYG.GYG_FILSRA,
				SUM(GIC.GIC_VALCOM) VALCOM FROM %Table:GQ6% GQ6
			INNER JOIN  %Table:GIC% GIC ON 
                GIC.GIC_FILIAL = %xFilial:GIC%
				AND GIC.GIC_CODGQ6 = GQ6.GQ6_CODIGO 
                AND GIC.%NotDel%
			INNER JOIN 	%Table:GYG% GYG ON 
                GYG.GYG_FILIAL = %xFilial:GYG%
				AND GYG.GYG_CODIGO = GIC.GIC_COLAB
                AND GYG.%NotDel%
			WHERE 
				GQ6.GQ6_FILIAL = %xFilial:GQ6%
                AND GQ6.GQ6_CODIGO BETWEEN %Exp:cCdComDe% AND %Exp:cCdComAt%
				AND GQ6.%NotDel% 
				AND GQ6.GQ6_EXPFOL = '' 
				AND GYG.GYG_RECCOD BETWEEN %Exp:cTpRecDe% AND %Exp:cTpRecAte%
				AND GIC.GIC_COLAB BETWEEN %Exp:cColabDe% AND %Exp:cColabAte%
			GROUP BY 
				GQ6.GQ6_CODIGO, 
				GYG.GYG_FUNCIO, 
				GYG.GYG_FILSRA
			
		EndSQL
			
		(cAliasTmp)->(DbGoTop())
	
		While !(cAliasTmp)->(Eof())	
			
			aAdd(aExpFol,{(cAliasTmp)->GYG_FUNCIO, cSRVCom, (cAliasTmp)->VALCOM,(cAliasTmp)->GYG_FILSRA})
				
			(cAliasTmp)->(dbSkip())
				
		EndDo
			
 		if Len(aExpFol) > 0
	 			
			//Solicita a gravação de lançamentos futuros na folha de pagamento referente a comissão normal 			
			For nExpFol	:= 1 To Len(aExpFol)
	 			
				FWMsgRun( ,{||  lRet	:= TPExpGPE(aExpFol[nExpFol],,@cPerFol)}, STR0008, STR0028) //"Aguarde...", "Incluindo informações no lançamentos futuros da folha de pagamento..."
	 				
				if !lRet
	 				
					DisarmTransaction()
	 				
				Else
	 				
					nGrvFol	:= nGrvFol+1
	 				
	 			EndIf
	 				
	 		Next nExpFol
	 		
 			//Atualizo os Processamentos de Comissões de Agência
	 		If lRet
		 		
	 			FWMsgRun( ,{||  lRet := G415AtuExp(cCdComDe, cCdComAt, cTpRecDe, cTpRecAte, cColabDe, cColabAte, cSRVCom, cSRVDSR,cPerFol)}, STR0008, STR0029) // "Aguarde...", "Atualizando a data de exportação das comissões..."
		 			
				If !lRet
	 				
					DisarmTransaction()
				
				Endif
				
	 		EndIf	
			 		
 		Else
	 		
 			FWAlertHelp(STR0030, STR0031) // "Para os parametros informados não existem registros.", "Preencher os parametros e clicar no botão OK ou verifique quais comissões estão pendentes."	
 			//"Para os parametros informados não existem registros."##"Preencher os parametros e clicar no botão OK ou verifique
 			// quais comissões estão pendentes."	
 		EndIf
	 		
 		(cAliasTmp)->(dbCloseArea())
	 		
 		If lRet
 		
	 		FWAlertSuccess( STR0033, STR0034) //"Exportação de Comissão finalizada."## "Exportação"
	 	
	 	Endif

	 	End Transaction	
	 	
 	Else
	 	
 		FWAlertHelp(STR0035, STR0036) //"Rotina cancelada pelo usuário.", "Preencher os parametros e clicar no botão OK."		
	 		
 	EndIf
	 
 Return
 
 //------------------------------------------------------------------- 
/*/{Protheus.doc} G415AtuExp(cComDe, cComAte, cTpRecDe, cTpRecAte, cColabDe, cColabAte)
Atualiza os cálculos de comissão com a data de exportação para folha de pagamento
@type function
@author Flavio Martins
@since 25/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/ //-------------------------------------------------------------------  

Static Function G415AtuExp(cComDe, cComAte, cTpRecDe, cTpRecAte, cColabDe, cColabAte, cSRVCom, cSRVDSR, cPerFol)

Local lRet			:= .T.
Local cAliasTmp	    := GetNextAlias()
Local oModel		:= FWLoadModel('GTPA415')
Local oMdlGQ6		:= oModel:GetModel("GQ6MASTER")
Local aNewFlds      := {'GQ6_PERFOL', 'GQ6_VRBCOM', 'GQ6_VRBDSR'}

BeginSQL Alias cAliasTmp    
		
	SELECT DISTINCT(GQ6.GQ6_CODIGO) GQ6_CODIGO 
	FROM %Table:GQ6% GQ6	
	INNER JOIN %Table:GIC% GIC 
		ON GIC.GIC_CODGQ6 = GQ6.GQ6_CODIGO AND GIC.%NotDel%
	INNER JOIN %Table:GYG% GYG 
		ON GYG.GYG_CODIGO = GIC.GIC_COLAB
	WHERE GQ6.GQ6_CODIGO BETWEEN %Exp:cComDe% AND %Exp:cComAte%
	AND GQ6.%NotDel% 
	AND GQ6.GQ6_EXPFOL = '' 
	AND GYG.GYG_RECCOD BETWEEN %Exp:cTpRecDe% AND %Exp:cTpRecAte%
	AND GIC.GIC_COLAB BETWEEN %Exp:cColabDe% AND %Exp:cColabAte%
		
EndSQL
		
(cAliasTmp)->(DbGoTop())

oModel:SetOperation(MODEL_OPERATION_UPDATE)

dbSelectArea('GQ6')

GQ6->(dbSetOrder(1))

While !(cAliasTmp)->(Eof())	

	oModel:Activate()
	
	oMdlGQ6:SetValue("GQ6_EXPFOL", dDataBase)

    If  GTPxVldDic('GQ6', aNewFlds, .F., .T.)
        oMdlGQ6:SetValue("GQ6_PERFOL", cPerFol)
        oMdlGQ6:SetValue("GQ6_VRBCOM", cSRVCom)
        oMdlGQ6:SetValue("GQ6_VRBDSR", cSRVDSR)
    Endif
		
		If oModel:VldData()
			FwFormCommit(oModel)
		Else
			JurShowErro( oModel:GetModel():GetErrormessage())	
			lRet := .F.
		Endif
		
		oModel:Deactivate()
				
		(cAliasTmp)->(dbSkip())
				
	EndDo
	
	(cAliasTmp)->(DbCloseArea())
	
	oModel:Destroy()
 
Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldTpRecurs(cTipRec)

@type Static Function
@author jacomo.fernandes
@since 08/01/2020
@version 1.0
@param cTipRec, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function VldTpRecurs(cTipRec,cCodG5D)
Local lRet		:= .T.
Local cAliasTmp	:= GetNextAlias()
Default cCodG5D	:= ""

BeginSql Alias cAliasTmp
	Select G5D.G5D_CODIGO
	From %Table:G5D% G5D
	Where
		G5D.G5D_FILIAL = %xFilial:G5D%
		AND G5D.G5D_TIPREC <> %Exp:Space(TamSx3('G5D_TIPREC')[1])%
		AND G5D.G5D_TIPREC = %Exp:cTipRec%
		AND G5D.G5D_STATUS = '2'
		AND G5D.%NotDel%
EndSql

If (cAliasTmp)->(!Eof())
	cCodG5D	:= (cAliasTmp)->G5D_CODIGO
Else
	lRet := .F.
	FwAlertHelp("Tipo de Recurso informado não possuí configurações cadastradas","Verifique as informações necessárias","Atenção!!")
Endif

(cAliasTmp)->(DbCloseArea())


Return lRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} VldFormula
Função responsavel para validar e retornar a formula cadastrada
@type Static Function
@author jacomo.fernandes
@since 20/12/2019
@version 1.0
@param cCodForm, character, (Descrição do parâmetro)
@return lRet, Retorno lógico
/*/
//------------------------------------------------------------------------------
Static Function VldFormula(cCodForm,aFormula)
Local lRet      := .T.
Local aAreaGQ5  := nil

If !Empty(cCodForm)
    aAreaGQ5	:= GQ5->(GetArea())
    //Pré validação 
    dbSelectArea("GQ5")
    GQ5->(dbSetOrder(1))
    If GQ5->(dbSeek(xFilial("GQ5")+cCodForm))
        //Se a formula para agência = Tp.Comissão = 1
        If GQ5->GQ5_TPCOMI == '2' 
            TP413XmlArray(cCodForm, aFormula)
            //Caso a formula não esteja associada a um cadastro de comissão de agência ou não seja preennchida, o calculo de comissão
            //será efetuado com regras simples descritas na evidência de teste 
            If Len(aFormula) == 0 .AND. !MsgYesNo( "Fórmula não encontrada. Deseja continuar?"  ) // "Fórmula não encontrada. Deseja continuar?" 
                lRet := .T.
            EndIf
        Else
            lRet := .F.
            FWAlertHelp( "Fórmula para calaborador", "Informar um código de fórmula com o campo 'Tp.Comissão' igual a Colaborador.","Atenção!!" )	
        EndIf
    Else
        lRet := .F.
        FwAlertHelp("Formula informada não encontrada","Verifique os dados informados","Atenção!!")
    EndIf
    RestArea(aAreaGQ5)

Endif

GtpDestroy(aAreaGQ5)

Return lRet

/*/{Protheus.doc} GA415VldAct
Validação da ativação do modelo
@type function
@author flavio.martins
@since 27/03/2020
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA415VldAct(oModel)
Local lRet		:= .T.
Local aNewFlds  := {'GQ6_PERFOL', 'GQ6_VRBCOM', 'GQ6_VRBDSR'}
Local cCodGQ6   := GQ6->GQ6_CODIGO
Local cVrbCom   := ''
Local cVrbDSR   := ''
Local cPerFol   := ''

If  oModel:GetOperation() == MODEL_OPERATION_DELETE

    If  GTPxVldDic('GQ6', aNewFlds, .F., .T.)
        cVrbCom := GQ6->GQ6_VRBCOM
        cVrbDSR := GQ6->GQ6_VRBDSR
        cPerFol := GQ6->GQ6_PERFOL
    Endif

    If !(VldDelCalc(cCodGQ6, cVrbCom, cVrbDSR, cPerFol))
        lRet := .F.
        oModel:SetErrorMessage(oModel:GetId(), ,oModel:GetId(), , "GA415VldAct", STR0037, STR0038) //"Cálculo não pode ser excluído, as verbas já constam no fechamento do RH.", "Entre em contato com o RH."
    Endif

Endif

Return lRet

/*/{Protheus.doc} VldDelCalc(oModel)
Valida se as verbas já foram lançadas na folha
@type function
@author flavio.martins
@since 27/03/2020
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldDelCalc(cCodGQ6, cVrbCom, cVrbDSR, cPerFol)
Local lRet      := .T.
Local cAliasTmp	:= GetNextAlias()

BeginSql Alias cAliasTmp

    SELECT COALESCE(COUNT(SRD.RD_PD), 0) SRDTOT,
           COALESCE(COUNT(SRC.RC_PD), 0) SRCTOT
    FROM   %Table:GQ6% GQ6 
        INNER JOIN  %Table:GIZ% GIZ 
                ON GIZ.GIZ_FILIAL = %xFilial:GIZ% 
                    AND GIZ.GIZ_CODGQ6 = GQ6.GQ6_CODIGO 
                    AND GIZ.%NotDel% 
        INNER JOIN  %Table:GYG% GYG 
                ON GYG.GYG_FILIAL = %xFilial:GYG%  
                    AND GYG.GYG_CODIGO = GIZ.GIZ_CODGYG 
                    AND GYG.%NotDel%  
        LEFT JOIN  %Table:SRD% SRD 
                ON SRD.RD_FILIAL = GYG.GYG_FILSRA  
                    AND SRD.RD_MAT = GYG.GYG_FUNCIO 
                    AND SRD.RD_PERIODO = %Exp:cPerFol%
                    AND (SRD.RD_PD = %Exp:cVrbCom% 
                        OR SRD.RD_PD = %Exp:cVrbDSR%)
                    AND SRD.%NotDel%  
        LEFT JOIN  %Table:SRC% SRC 
                ON SRC.RC_FILIAL = GYG.GYG_FILSRA
                    AND SRC.RC_MAT = GYG.GYG_FUNCIO 
                    AND SRC.RC_PERIODO = %Exp:cPerFol%
                    AND (SRC.RC_PD = %Exp:cVrbCom% 
                        OR SRC.RC_PD = %Exp:cVrbDSR%)
                    AND SRC.%NotDel%  
    WHERE   GQ6.GQ6_FILIAL = %xFilial:GQ6%  
        AND GQ6.GQ6_CODIGO = %Exp:cCodGQ6% 
        AND GQ6.GQ6_EXPFOL > '' 
        AND GQ6.%NotDel%  

EndSql

lRet := ((cAliasTmp)->SRDTOT == 0 .And. (cAliasTmp)->SRcTOT == 0 )

(cAliasTmp)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} DelVrbSRK(oModel)
Exclui as verbas da tabela SRK
@type function
@author flavio.martins
@since 27/03/2020
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DelVrbSRK(cCodGQ6, cVrbCom, cVrbDSR, cPerFol)
Local lRet      := .T.
Local cAliasTmp := GetNextAlias()
Local aCab      := {}
Local aItem     := {}  
Local aItens    := {}
Local aLog      := {}

Private lMsErroAuto := .F.

BeginSql Alias cAliasTmp

SELECT 
  RK_FILIAL, 
  RK_MAT, 
  RK_PD, 
  RK_VALORTO, 
  RK_PARCELA, 
  RK_PERINI, 
  RK_DOCUMEN 
FROM 
  %Table:GQ6% GQ6 
  INNER JOIN %Table:GIZ% GIZ ON GQ6.GQ6_FILIAL = %xFilial:GQ6%
  AND GIZ.GIZ_CODGQ6 = GQ6.GQ6_CODIGO 
  AND GIZ.%NotDel%
  INNER JOIN %Table:GYG% GYG ON GYG.GYG_FILIAL = %xFilial:GYG%
  AND GYG.GYG_CODIGO = GIZ.GIZ_CODGYG 
  AND GYG.%NotDel%
  INNER JOIN %Table:SRK% SRK ON SRK.RK_FILIAL = GYG.GYG_FILSRA
  AND SRK.RK_MAT = GYG.GYG_FUNCIO 
  AND (SRK.RK_PD = %Exp:cVrbCom% 
       OR SRK.RK_PD = %Exp:cVrbDSR%) 
  AND SRK.RK_PERINI = %Exp:cPerFol%
  AND SRK.%NotDel% 
WHERE 
  GQ6.GQ6_FILIAL = %xFilial:GQ6%
  AND GQ6.GQ6_CODIGO = %Exp:cCodGQ6% 
  AND GQ6.GQ6_EXPFOL > ' ' 
  AND GQ6.%NotDel%

EndSql

While (cAliasTmp)->(!(Eof()))

    aCab    := {}
    aItem   := {}
    aItens  := {}

    Aadd(aCab, {"RA_FILIAL"    , (cAliasTmp)->RK_FILIAL    , nil})
    Aadd(aCab, {"RA_MAT"       , (cAliasTmp)->RK_MAT       , nil})
    
    Aadd(aItem,{"RK_PD"        , (cAliasTmp)->RK_PD        , nil})
    Aadd(aItem,{"RK_DOCUMEN"   , (cAliasTmp)->RK_DOCUMEN   , nil})
    Aadd(aItem,{"RK_VALORTO"   , (cAliasTmp)->RK_VALORTO   , nil})
    Aadd(aItem,{"RK_PARCELA"   , (cAliasTmp)->RK_PARCELA   , nil})

    aAdd(aItens, aItem)

    MsExecAuto({|a, b, c| GPEA110(a, b, c) }, 5, aCab, aItens)

    If lMsErroAuto .And. !(IsBlind())
        aLog := getAutoGrLog()
        MostraErro()
    EndIf

    (cAliasTmp)->(dbSkip())

End

(cAliasTmp)->(dbCloseArea())

Return lRet

